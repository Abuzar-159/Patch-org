public with sharing class VoucherDocument {
    public ERP7__Voucher__c Vou {get; set;}
    public String imageURl                             { get; set; } public List<selectoption> AvailableRecipients { get; set; }
    public String VouFields                             { get; set; } public Map<string,string> ccEmails_map  { get; set; }
    public String addressFields                        { get; set; }  public String  toEmail_id { get; set; }
    public Organization orgDetails                     { get; set; }  public String EmailSubject { get; set; }
    public String VouNumber                             { get; set; }     public String TextBody { get; set; }
    public Account currentAccount { get; set; } public List<selectoption> SelectedRecipients { get; set; } public String selectedEmail { get; set; } 
  
    public String contactids  { get; set; } public list<String>  ccEmails { get; set; } public EmailTemplate SelectEmailTemplate { get; set; } public EmailTemplate MailselectedTemplate { get; set; } 
    public Boolean MailSent { get; set; } public String sfdcBaseURL  { get; set; }  public Boolean isHtmlEmail { get; set; } public List<SetEmailTemplates__c> EmailTemplates_uniqueName { get; set; } 
    public String HtmlBody { get; set; } public String exceptionMsg  { get; set; } public String pdf { get; set; } public String cusId                            { get; set; }

    public VoucherDocument(){ 
        try{
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
            sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            String CustID;
            if(ApexPages.CurrentPage().getParameters().get('Id')!= null) VouNumber = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('Id'),'UTF-8');
            if(System.currentPageReference().getParameters().get('custId')!= null) CustID = EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('custId'),'UTF-8');
            VouFields = UtilClass.selectStarFromSObject('ERP7__Voucher__c');
            utilClass.FLSCheck(VouFields.split(','), 'ERP7__Voucher__c');
            addressFields = UtilClass.selectStarFromSObject('Address__c');
            utilClass.FLSCheck(addressFields.split(','),'Address__c');
            if(VouNumber != null) Vou= getVou(VouNumber);
            
            //if(!Schema.sObjectType.Organization.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Organization.Label));//This was commented on 12/01/24 by Asra after getting confirmation from Imran and Moin
            //} else { orgDetails = [SELECT Id, Name FROM Organization WHERE Id =: UserInfo.getOrganizationId()]; }
            if(CustID != null && CustID != '') {
                if(!Schema.sObjectType.Contact.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Contact.Label));
                } else { currentAccount = [Select id, Name ,ERP7__Email__c, Fax,  Phone, ERP7__Account_Id__c, Company__c From Account Where Id =: CustID Limit 1]; }
        }
            if(currentAccount != null) toEmail_id = currentAccount.ERP7__Email__c;
            imageURL='/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));
            } else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
                     if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; } } catch(Exception e) { exceptionMethod(e, 'Constructor');  }

        try{
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c,OrgWideEmailAddress__c,Html_Body__c,TemplateAsAttachment__c,Add_Template_As_Attachment__c From SetEmailTemplates__c where Name ='Voucher_Document' limit 1];
                if(EmailTemplates_uniqueName.isEmpty()) {
                    EmailTemplates_uniqueName = new  List<SetEmailTemplates__c>();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null,Template_Unique_Name__c = 'Voucher_Document',TemplateAsAttachment__c = true,Add_Template_As_Attachment__c=true,Html_Body__c=false));
                }
               if(EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c != null){
                    MailselectedTemplate = [select id,Body, Subject,HtmlValue from EmailTemplate where DeveloperName =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c];
                    isHtmlEmail =  EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c; }else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'To SetUp  Email Template provide Unique Template Name or Contact your Administrator'));}}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));}
    
        
    }
    
     public void Email_Details(){
        try{
            Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
         
         String [] toAddresses_test = new String[] {'test@test.com'};
          
         email_Attach.setToAddresses(toAddresses_test);
         email_Attach.setTemplateId(MailselectedTemplate.id);
         email_Attach.setSaveAsActivity(false);                     
         email_Attach.setTargetObjectId(currentAccount.Id);
         email_Attach.setWhatId(Vou.id); PageReference pageRef = new PageReference('/'+MailselectedTemplate.id+'?recipient_type_id='+currentAccount.id+'&related_to_id='+Vou.id);  TextBody = (!test.isRunningTest())?pageRef.getContent().toString():'<table class="templatePreviewTable" border="0" cellpadding="0" cellspacing="0"><tbody><tr><td><span class="editTags">Subject</span>&nbsp;ERP MARK7: Invoice for SO #0014817</td></tr><tr><td>&nbsp;</td></tr><tr><td><span class="editTags">HTML Preview</span></td></tr><tr><td><table border="0" cellpadding="1" cellspacing="0"><tbody><tr><td class="previewTable"><iframe frameborder="0" height="250" id="previewFrame" name="previewFrame" scrolling="no" src="https://erp-mark-7-dev-ed--c.eu5.content.force.com/email/templaterenderer?id=00X24000000gr2q&amp;recipient_type_id=0032400000Xooir&amp;related_to_id=a0D2400000bEEBt&amp;base_href=https%3A%2F%2Ferp-mark-7-dev-ed.my.salesforce.com&amp;preview_frame=previewFrame&amp;render_type=REPLACED_HTML_BODY&amp;setupid=CommunicationTemplatesEmail" style="background-color: rgb(255, 255, 255); height: 892px; width: 665px;" title="Preview" width="650"></iframe></td></tr></tbody></table></td></tr><tr><td>&nbsp;</td></tr><tr><td><span class="editTags">Plain Text Preview</span></td></tr><tr><td><table border="1" cellpadding="5" cellspacing="0" height="250" width="650"><tbody><tr><td class="previewCell">Dear Scott\'s Bill,&lt;br /&gt;<br>        &lt;br /&gt; Please find attached a detailed invoice on your account.&lt;br /&gt; The invoice summary is as follows:&lt;br /&gt;<br>        &lt;br /&gt; Account Name: Scot (Customer\'s)&lt;br /&gt; Account Number: R-0163&lt;br /&gt;<br>        <br>        Invoice Date:           07/06/2017<br>        &lt;br /&gt; Invoice Number: INV-6333&lt;br /&gt; Invoice Amount: 162.0&lt;br /&gt; We appreciate your timely payment. For a quick turnaround we recommend making a secure payment online, we accept most major credit and debit cards, simply click this link below to make payment.&lt;br /&gt;&lt;br /&gt;<br>        &lt;a href="<a href="https://erp-mark-7-dev-ed.lightning.force.com/apex/ERP7__CardPaymentLC?SON=a0e2400000GvNe9AAF" target="_blank">https://erp-mark-7-dev-ed.lightning.force.com/apex/ERP7__CardPaymentLC?SON=a0e2400000GvNe9AAF</a>" style="font-family:Arial, Helvetica, sans-serif; font-size:18px; font-weight:bold;text-decoration:none; color:#03A9F4;" target="_blank"&gt;Pay Now&lt;/a&gt;.&lt;br /&gt; Sincerely, The Aqxolt Accounts Department</td></tr></tbody></table></td></tr></tbody></table>' ;
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
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
    }
    public ERP7__Voucher__c getVou(String VouNum) {
        ERP7__Voucher__c Vou;
        try {            //Return_
            if(!Schema.sObjectType.ERP7__Voucher__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Voucher__c.Label));
            } else { Vou = Database.query('select ' + String.escapeSingleQuotes(VouFields) + ', ERP7__Vendor__r.Name from ERP7__Voucher__c where (Id = \'' + String.escapeSingleQuotes(VouNum) + '\') Limit 1'); }
                       
        } catch(Exception e) {exceptionMethod(e, 'getVou'); }
        return Vou;
    }
    public void buildCcEmail()
    {
        String[] strArray=contactids.split(','); ccEmails =strArray;        
    }
    public PageReference sendVoucher(){
        List<OrgWideEmailAddress> orgaddress = new List<OrgWideEmailAddress>();
        try{
            String csfdcBaseURL = sfdcBaseURL;
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'documentforce.com/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentAccount.id+'&related_to_id='+Vou.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val')); Attachment InvoiceAttachment = new Attachment(Name=Vou.Name+'.pdf',contentType='application/pdf',body=PageRef.getContentAsPdf(),ParentId=Vou.id); if(String.isNotEmpty(toEmail_id)){Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c != null ) {orgaddress = [SELECT id From OrgWideEmailAddress Where Address =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c LIMIT 1]; if(orgaddress.size() > 0) email.setOrgWideEmailAddressId(orgaddress[0].id);
                    }
                    else email.setSenderDisplayName('Aqxolt India Private Limited');
                    email.setCcAddresses(ccEmails);
                     String [] toAddresses = toEmail_id.split(',');email.setToAddresses(toAddresses); email.setBccSender(false);email.setUseSignature(false);email.setTreatBodiesAsTemplate(true); email.setSubject(EmailSubject);

                     if(!EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c){ String HtmlEmailBody = '<pre style="font-size: 14px;font-family: sans-serif;">'+TextBody+'</pre>';email.setHtmlBody(HtmlEmailBody);}else{email.setHtmlBody(HtmlBody);}
                      
                     if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].TemplateAsAttachment__c){Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();attach.setFileName('Voucher:'+Vou.Name+'.pdf'); 
                            Blob b = InvoiceAttachment.body;attach.setBody(b);email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); }Messaging.SendEmailResult [] Email_Result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Email Sent Successfully'));
                }
        }
        catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
        return null;
    }
    public PageReference Back2Voucher() {PageReference page = new PageReference('/'+Vou.Id);  return page;  }  
    
    
    Public pageReference createPDF() { String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c'); csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
        
        PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'documentforce.com/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentAccount.id+'&related_to_id='+Vou.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
       
        pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueOf('Test'));
         String ReceiveURL = '/apex/VouPDF?id='+Vou.id+'&custId='+cusId;
                PageReference Page = new PageReference(ReceiveURL);
                return Page;
    }  
   
    public void exceptionMethod(Exception e, String methodName) {    
        exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();
    }
}