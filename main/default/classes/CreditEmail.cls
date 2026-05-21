global With Sharing Class CreditEmail{ 
    
    global Invoice__c currentInvoice                   { get; set; }  
    global Invoice__c iv                               { get; set; }  
    global Contact currentContact                      { get; set; }
    global String  toEmail_id                          { get; set; }
    global String  creditNoteId                          { get; set; }
    global String EmailSubject                         { get; set; }
    global String TextBody                             { get; set; }
    global List<selectoption> AvailableRecipients      { get; set; }
    global List<selectoption> SelectedRecipients       { get; set; }
    global String selectedEmail                        { get; set; }
    global Map<string,string> ccEmails_map             { get; set; }
    global list<String>  ccEmails                      { get; set; } 
    global String contactids                           { get; set; }
    global EmailTemplate SelectEmailTemplate           { get; set; }
    global EmailTemplate MailselectedTemplate          { get; set; }
    global Boolean MailSent                            { get; set; }
    global String sfdcBaseURL                          { get; set; }
    global String pdf                          { get; set; }
    global Sales_Order__c so;
    global Boolean isHtmlEmail                         { get; set; }
    global List<SetEmailTemplates__c> EmailTemplates_uniqueName { get; set; }
    global String HtmlBody                             { get; set; }
    global blob pdfContent                             { get; set; }
    global attachment Attachs                          { get; set; }
    global String EmailsCC                             { get; set; }
    global Integer frameHeight                            { get; set; }
    global Integer totalRows                            { get; set; }
    global string pageContent {get; set;}
    global string pageDecodeContent {get; set;}
    global String invname                            { get; set; }
    global String cusId                            { get; set; }
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    global CreditEmail(ApexPages.StandardController controller){
    
    /*Fetching instance Name From SFDC URL*/
     frameHeight = 1000;
     totalRows = 0;
     /*sfdcBaseURL = URL.getSalesforceBaseUrl().getHost(); 
     sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
     sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');*/
      sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            System.debug('sfdcBaseURL'+sfdcBaseURL);
            //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
            //Below works in our erp dev org
            //sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.content.force.com');//need to uncommented
            String initurl;
            if(sfdcBaseURL.contains('.visualforce.com')){
                initurl = Label.initURL;
            }else {
                initurl = Label.initURL2;
            }            
            String DestinationURL = Label.DestURL;
             
         sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL);
            if(sfdcBaseURL.contains('sandbox')){
                sfdcBaseURL = sfdcBaseURL.replace('--c','');
            }
         sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
         sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            system.debug('sfdcBaseURL3 '+sfdcBaseURL);            
           
     AvailableRecipients =new List<selectoption>();
     ccEmails_map=new Map<string,string>();
     ccEmails=new  list<String>();         
    
     EmailsCC='';
     /*CurrentPage Parameters*/     
        creditNoteId = ApexPages.currentPage().getParameters().get('Id');
     String invoiceName = ApexPages.currentPage().getParameters().get('name');
        invname=invoiceName;
     String CustID = System.currentPageReference().getParameters().get('custId');
       // if(System.currentPageReference().getParameters().get('custId')!= null) CustID = EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('custId'),'UTF-8');
        cusId = CustID; 
     try{
         if(CustID == null || CustID == '') ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No Contact assigned on Credit Note'));
         if(invoiceName == null || invoiceName == '') ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No Invoice assigned on Credit Note'));
         
         currentInvoice = getCurrentInv(invoiceName);         
         currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId,Account.Organisation__c, Phone, Contact_Numer__c, Company__c From Contact Where Contact_Numer__c =: CustID OR Id =:CustID Limit 1];
         toEmail_id = currentContact.Email;
         if(currentInvoice.ERP7__Order__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'No Order assigned on Invoice'));
         so = [Select Is_Invoice_Sent__c, ERP7__Total_Number_of_Items__c From Sales_Order__c where id =:currentInvoice.Order__c];  
         iv = [Select Id, ERP7__Total_Number_of_Items__c From Invoice__c where id =:currentInvoice.Id];
         MailSent = false;
         totalRows = Integer.valueof(so.ERP7__Total_Number_of_Items__c);
         frameHeight = frameHeight + (Integer.valueof(so.ERP7__Total_Number_of_Items__c/3)*100);
         
         totalRows = Integer.valueof(iv.ERP7__Total_Number_of_Items__c);
         frameHeight = frameHeight + (Integer.valueof(iv.ERP7__Total_Number_of_Items__c/3)*100);
        List<Contact> Allcontacts=[SELECT  id, Name, FirstName, LastName ,Email, AccountId,Account.Organisation__c, Phone, Contact_Numer__c, Company__c FROM Contact where id != :currentContact.id and  AccountId =: currentContact.AccountId];
        if(Allcontacts!=null && Allcontacts.size()>0)
                for(Integer i=0;i<Allcontacts.size()&&i<1000;i++){
                    Contact c=Allcontacts[i];
                    AvailableRecipients.add(new SelectOption(c.id,c.Name));
                    ccEmails_map.put(c.id,c.Email);
                }
       }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); /*'Exception'+e+e.getLineNumber()*/}
       
     /*Querying The Template for Preview and attachment*/
         try{
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c,OrgWideEmailAddress__c,Html_Body__c,TemplateAsAttachment__c,Add_Template_As_Attachment__c From SetEmailTemplates__c where Name ='Credit_Note_Document' limit 1];
                if(EmailTemplates_uniqueName.isEmpty()) {
                    EmailTemplates_uniqueName = new  List<SetEmailTemplates__c>();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null,Template_Unique_Name__c = 'Credit_Note_Document',TemplateAsAttachment__c = true,Add_Template_As_Attachment__c=true,Html_Body__c=false));
                }
               if(EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c != null){
                    MailselectedTemplate = [select id,Body, Subject,HtmlValue from EmailTemplate where DeveloperName =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c];//: [select id,Body, Subject,HtmlValue from EmailTemplate where DeveloperName = 'SalesOrder_Invoice'];// 'SalesOrder_Invoice'
                    isHtmlEmail =  EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c;
                }
                else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'To SetUp  Email Template provide Unique Template Name or Contact your Administrator'));}
            
         }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); /*'Exception'+e+e.getLineNumber()*/}
      }
    /*
global void Email_Details(){
        try{
        PageReference pageRef = new PageReference('/'+MailselectedTemplate.id+'?recipient_type_id='+currentContact.id+'&related_to_id='+currentInvoice.id);
        TextBody = (!test.isRunningTest())?pageRef.getContent().toString():'<table class="templatePreviewTable" border="0" cellpadding="0" cellspacing="0"><tbody><tr><td><span class="editTags">Subject</span>&nbsp;ERP MARK7: Invoice for SO #0014817</td></tr><tr><td>&nbsp;</td></tr><tr><td><span class="editTags">HTML Preview</span></td></tr><tr><td><table border="0" cellpadding="1" cellspacing="0"><tbody><tr><td class="previewTable"><iframe frameborder="0" height="250" id="previewFrame" name="previewFrame" scrolling="no" src="https://erp-mark-7-dev-ed--c.eu5.content.force.com/email/templaterenderer?id=00X24000000gr2q&amp;recipient_type_id=0032400000Xooir&amp;related_to_id=a0D2400000bEEBt&amp;base_href=https%3A%2F%2Ferp-mark-7-dev-ed.my.salesforce.com&amp;preview_frame=previewFrame&amp;render_type=REPLACED_HTML_BODY&amp;setupid=CommunicationTemplatesEmail" style="background-color: rgb(255, 255, 255); height: 892px; width: 665px;" title="Preview" width="650"></iframe></td></tr></tbody></table></td></tr><tr><td>&nbsp;</td></tr><tr><td><span class="editTags">Plain Text Preview</span></td></tr><tr><td><table border="1" cellpadding="5" cellspacing="0" height="250" width="650"><tbody><tr><td class="previewCell">Dear Scott\'s Bill,&lt;br /&gt;<br>        &lt;br /&gt; Please find attached a detailed invoice on your account.&lt;br /&gt; The invoice summary is as follows:&lt;br /&gt;<br>        &lt;br /&gt; Account Name: Scot (Customer\'s)&lt;br /&gt; Account Number: R-0163&lt;br /&gt;<br>        <br>        Invoice Date:           07/06/2017<br>        &lt;br /&gt; Invoice Number: INV-6333&lt;br /&gt; Invoice Amount: 162.0&lt;br /&gt; We appreciate your timely payment. For a quick turnaround we recommend making a secure payment online, we accept most major credit and debit cards, simply click this link below to make payment.&lt;br /&gt;&lt;br /&gt;<br>        &lt;a href="<a href="https://erp-mark-7-dev-ed.lightning.force.com/apex/ERP7__CardPaymentLC?SON=a0e2400000GvNe9AAF" target="_blank">https://erp-mark-7-dev-ed.lightning.force.com/apex/ERP7__CardPaymentLC?SON=a0e2400000GvNe9AAF</a>" style="font-family:Arial, Helvetica, sans-serif; font-size:18px; font-weight:bold;text-decoration:none; color:#03A9F4;" target="_blank"&gt;Pay Now&lt;/a&gt;.&lt;br /&gt; Sincerely, The Aqxolt Accounts Department</td></tr></tbody></table></td></tr></tbody></table>' ;
        EmailSubject  = TextBody.substringBetween('Subject</span>&nbsp;','</td>');
        TextBody = TextBody.substringBetween('<td class="previewCell">','</td>');
        if(TextBody == null) TextBody = '';
        TextBody = TextBody.replace('"','\'');
        TextBody = TextBody.unescapeHTML3();
        String str = TextBody;
        String strurl = str.substringAfterLast('TARGET=\'_blank\'>');
         strurl = strurl.substringBeforeLast('</A>');
       
        if(String.isNotEmpty(strurl)){
        String lasthref = str.substringAfterLast('href=');
        lasthref = lasthref.substringBeforeLast('id=');
        str = str.replace(lasthref, '"'+strurl+'"');
        }
        TextBody = str;
         }catch(Exception e){
             //'Exception'+e+e.getLineNumber()
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
    }*/
    global void Email_Details(){
        //To get Email Content Before Sending Email For Preview
       try{
         Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
         String [] toAddresses_test = new String[] {'test@test.com'}; 
         email_Attach.setToAddresses(toAddresses_test);
         email_Attach.setTemplateId(MailselectedTemplate.id);
         email_Attach.setSaveAsActivity(false);                     
         email_Attach.setTargetObjectId(currentContact.id); 
         email_Attach.setWhatId(currentInvoice.id);
         Savepoint sp = Database.setSavepoint();
         system.debug('currentContact-->'+currentContact);
         if(currentContact.Email != Null) Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
            EmailSubject=email_Attach.getSubject();
         TextBody = email_Attach.getPlainTextBody();
         HtmlBody = email_Attach.getHtmlBody();
           System.debug('HtmlBody'+HtmlBody);
         Database.rollback(sp); 
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
    }
    global Invoice__c getCurrentInv(String Inv){
        Invoice__c invoice;
        if(Inv != null) { 
            invoice = [SELECT Id, Name, Account__c, Account__r.Name,Organisation__r.name, Invoice_Date__c, Tax_Receipt__c, Paid__c, Order__c,Order__r.Name, 
                       Final_Due_Amount__c, Loyalty_Amount__c, Loyalty_Points__c, Return_Amount__c, Sub_Total_Amount__c
                       FROM Invoice__c WHERE Name =: Inv Limit 1]; 
        }
        return invoice;
    } 
    global void buildCcEmail()
    {
        String[] strArray=contactids.split(',');
        ccEmails =strArray;        
    } 

    global PageReference sendCreditNote(){
        List<OrgWideEmailAddress> orgaddress = new List<OrgWideEmailAddress>();
        try{
                String csfdcBaseURL = sfdcBaseURL;
                csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
                PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+currentInvoice.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
                Attachment InvoiceAttachment = new Attachment(Name=currentInvoice.Name+'.pdf',contentType='application/pdf',body=(!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueof('Test'),ParentId=creditNoteId);
                if(String.isNotEmpty(toEmail_id)){       
                     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                     if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c != null ) {
                         orgaddress = [SELECT id From OrgWideEmailAddress Where Address =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c LIMIT 1];
                         if(orgaddress.size() > 0) email.setOrgWideEmailAddressId(orgaddress[0].id);
                    }
                    else email.setSenderDisplayName('Aqxolt India Private Limited');
                     
                     if(String.isNotEmpty(EmailsCC)){
                      String[] strArray=EmailsCC.split(',');     
                     email.setCcAddresses(strArray); //ccemails
                    }
                     
                     String [] toAddresses = toEmail_id.split(',');
                     email.setToAddresses(toAddresses); 
                     email.setBccSender(false);
                     email.setUseSignature(false);
                     email.setTreatBodiesAsTemplate(true);
                     email.setSubject(EmailSubject);
                    
                     if(!EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c){
                         String HtmlEmailBody = '<pre style="font-size: 14px;font-family: sans-serif;">'+TextBody+'</pre>';
                         email.setHtmlBody(HtmlEmailBody); 
                     }
                     else{email.setHtmlBody(HtmlBody);}
                      
                     if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].TemplateAsAttachment__c){
                            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                            attach.setFileName('Sales Order:'+currentInvoice.Order__r.Name+'.pdf'); 
                            Blob b = InvoiceAttachment.body;
                            attach.setBody(b); 
                            email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                     }
                     Messaging.SendEmailResult [] Email_Result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                    if(InvoiceAttachment!=null){
                        insert InvoiceAttachment;
                    }
                     mailsent = Email_Result.get(0).isSuccess();
                     if(mailsent){
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Email Sent Successfully'));
                         if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Add_Template_As_Attachment__c) if(Schema.SObjectType.Attachment.isCreateable()) { insert InvoiceAttachment; } else { }
                         so.Is_Invoice_Sent__c = true;   
                         if(Schema.sObjectType.Sales_Order__c.fields.Is_Invoice_Sent__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Is_Invoice_Sent__c.isUpdateable()){hasAccess=true; update so;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                     }
                     else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Email_Result.get(0).getErrors()[0].getMessage()));
                       }
                     
                }
        }
        catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
        return null;
    }
       
    global PageReference Back2Invoice() {
        PageReference page = new PageReference('/'+creditNoteId); 
        return page;  
    } 
    
    global pageReference createPDF() {
        /*'createPDF is called'*/
        String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
        csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
        PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+currentInvoice.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
       
       // pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueOf('Test'));
        /*'createPDF pdf==>'+pdf*/
         String ReceiveURL = '/apex/CNPDF?name='+invname+'&custId='+cusId;
                PageReference Page = new PageReference(ReceiveURL);
                return Page;
       
    }  
   
}