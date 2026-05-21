public With Sharing class OrderDocument {
 
    
    public Order SO                                     { get; set; }
    public String imageURl                             { get; set; } 
    public String SOFields                             { get; set; }
    public String addressFields                        { get; set; } 
    public Organization orgDetails                     { get; set; }  
    public String SONumber                             { get; set; } public List<selectoption> SelectedRecipients       { get; set; } public String selectedEmail                        { get; set; }
    public Contact currentContact                      { get; set; } public Map<string,string> ccEmails_map             { get; set; } public list<String>  ccEmails                      { get; set; } 
    public String  toEmail_id                          { get; set; } public String EmailSubject                         { get; set; } public String TextBody                             { get; set; }
 
    public String contactids                           { get; set; } public EmailTemplate SelectEmailTemplate           { get; set; } public List<selectoption> AvailableRecipients      { get; set; }
    public EmailTemplate MailselectedTemplate          { get; set; }
    public Boolean MailSent                            { get; set; }
    public String sfdcBaseURL                          { get; set; }
    public Boolean isHtmlEmail                         { get; set; }
    public List<SetEmailTemplates__c> EmailTemplates_uniqueName { get; set; } public String HtmlBody                             { get; set; } public Address__c vendorAddress                     { get; set; }
    public Address__c invoiceAddress                    { get; set; }            
    public Address__c deliveryAddress                   { get; set; } public String exceptionMsg                          { get; set; } public String ccEmail_Addresses                     { get; set; } public String pdf                                  { get; set; }
    public String soname                              { get; set; }
    public String cusId                                { get; set; }
    public String EmailsCC                             { get; set; }
    public OrderDocument() { 
        try {
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            List<Contact> Allcontacts =new List<Contact>();
            String initurl = Label.initURL;
           
            String DestinationURL = Label.DestURL;
           
            //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('.visual.force.com');
          //sfdcBaseURL = sfdcBaseURL.replace('.visualforce.com','.documentforce.com');
            
           	  //sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL); //working in dev org
        //sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
        
        	String sendEmailBaseURL = Label.sendEmailBaseURL; 
         	sfdcBaseURL = sfdcBaseURL.replace(initurl,sendEmailBaseURL);
         	sfdcBaseURL = sfdcBaseURL.replace('--erp7','');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            system.debug('sfdcBaseURL3 '+sfdcBaseURL);
            
            EmailsCC = '';
            AvailableRecipients =new List<selectoption>();
            String CustID;
            MailSent = false;
            if(ApexPages.CurrentPage().getParameters().get('Id')!= null) SONumber = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('Id'),'UTF-8');
            if(System.currentPageReference().getParameters().get('custId')!= null) CustID = EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('custId'),'UTF-8');
            soname = SONumber;
            cusId = CustID;
            /*soname : '+soname);
           cusId : '+cusId); */
            SOFields = UtilClass.selectStarFromSObject('Order');
            utilClass.FLSCheck(SOFields.split(','),'Order');
            addressFields = UtilClass.selectStarFromSObject('Address__c');
            utilClass.FLSCheck(addressFields.split(','),'Address__c');
            if(SONumber != null) SO = getSalesOrder(SONumber);
            
            //if(!Schema.sObjectType.Organization.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Organization.Label));//This was commented on 12/01/24 by Asra after getting confirmation from Imran and Moin
            //} else { orgDetails = [SELECT Id, Name FROM Organization WHERE Id =: UserInfo.getOrganizationId()]; }
                        
            if(CustID != null && CustID != '') {
                if(!Schema.sObjectType.Contact.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Contact.Label));
                } else { currentContact = [Select id, Name, FirstName, LastName ,Email, Fax, AccountId, Phone, ERP7__Contact_Numer__c, ERP7__Company__c From Contact Where Id =: CustID Limit 1]; }
            }/*contact==>'+currentContact*/
            if(currentContact != null) { 
                toEmail_id = currentContact.Email; 
              Allcontacts=[SELECT  id, Name, FirstName, LastName ,Email, AccountId, Phone, ERP7__Contact_Numer__c,ERP7__Company__c FROM Contact where id != :currentContact.id and  AccountId =: currentContact.AccountId];
       		  system.debug('Allcontacts Size:'+Allcontacts.size());
            }
             if(Allcontacts!=null && Allcontacts.size()>0)
                for(Integer i=0;i<Allcontacts.size()&&i<1000;i++){
                    Contact c=Allcontacts[i];
                    if(c.Email != null) AvailableRecipients.add(new SelectOption(c.Email,c.Name));
                    ccEmails_map.put(c.id,c.Email);
                }
            
            
            imageURL='/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));
            } else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
                     if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; } } catch(Exception e) { exceptionMethod(e, 'Constructor'); }
        
        /*Querying The Template for Preview and attachment*/
         try{
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c,OrgWideEmailAddress__c,Html_Body__c,TemplateAsAttachment__c,Add_Template_As_Attachment__c From SetEmailTemplates__c where Name ='Order_Documents' limit 1];
                  
             if(EmailTemplates_uniqueName.isEmpty()) {
                    EmailTemplates_uniqueName = new  List<SetEmailTemplates__c>();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null,Template_Unique_Name__c = 'Order_Documents',TemplateAsAttachment__c = true,Add_Template_As_Attachment__c=true,Html_Body__c=false));
                }
               if(EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c != null){
                    MailselectedTemplate = [select id,Body, Subject,HtmlValue from EmailTemplate where DeveloperName =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c and IsActive = true];
                    isHtmlEmail =  EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c;}else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'To SetUp  Email Template provide Unique Template Name or Contact your Administrator'));}}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));}
    }
    public void assignCC(){
        system.debug('EmailsCC : '+EmailsCC);
    }
    public void Email_Details(){
        /*To get Email Content Before Sending Email For Preview*/
        try{
          Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
         String [] toAddresses_test = new String[] {'test@test.com'};
            /*Inside email currentContact:'+currentContact
            'Inside email SO:'+SO.Id*/
         email_Attach.setToAddresses(toAddresses_test);
         email_Attach.setTemplateId(MailselectedTemplate.id);
         email_Attach.setSaveAsActivity(false);                     
         email_Attach.setTargetObjectId(currentContact.id);
         email_Attach.setWhatId(SO.id);
            
         Savepoint sp = Database.setSavepoint(); if(currentContact.Email != Null)  Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
            /*('email_Attach_Result==>'+email_Attach_Result);*/
            EmailSubject=email_Attach.getSubject();  TextBody = email_Attach.getPlainTextBody(); HtmlBody = email_Attach.getHtmlBody(); Database.rollback(sp);
        
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
    }
    
     /*
      Method For Getting SO Record
    */ 
    public Order getSalesOrder(String SONum) {
        Order SO;
        try {            
            if(!Schema.sObjectType.Order.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Order.Label));
            } else { SO = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ', ERP7__Contact__r.Name from Order where (Id = \'' + String.escapeSingleQuotes(SONum) + '\') Limit 1'); }
            
            if(SO.ERP7__Bill_To_Address__c != null) {
                if(!Schema.sObjectType.Address__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Address__c.Label));
                } else { invoiceAddress = Database.query('Select '+ String.escapeSingleQuotes(addressFields) + ' From Address__c Where (Id = \'' + String.escapeSingleQuotes(SO.ERP7__Bill_To_Address__c) + '\')limit 1'); }
            }
            if(SO.ERP7__Ship_To_Address__c != null) {            
                if(!Schema.sObjectType.Address__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Address__c.Label));
                } else { deliveryAddress = Database.query('Select '+ String.escapeSingleQuotes(addressFields) + ' From Address__c Where (Id = \'' + String.escapeSingleQuotes(SO.ERP7__Ship_To_Address__c) + '\')limit 1'); }}}  catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); exceptionMethod(e, 'getSalesOrder'); }
            
            /*(ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())));*/
            
        return SO;
    }
    
    public void buildCcEmail()
    {
        String[] strArray=contactids.split(','); ccEmails =strArray;
    }
    
     public PageReference sendSO(){
        List<OrgWideEmailAddress> orgaddress = new List<OrgWideEmailAddress>();
        try{
            String sendEmailBaseURL = Label.sendEmailBaseURL; 
            sendEmailBaseURL = sfdcBaseURL.replace(Label.DestURL,sendEmailBaseURL);
             if(!sfdcBaseURL.contains('content')) sendEmailBaseURL = sendEmailBaseURL.replace('--c','');
            system.debug('sendEmailBaseURL'+sendEmailBaseURL);
            //erp-mark-7-dev-ed.file.force.com
            system.debug('sfdcBaseURL : '+sfdcBaseURL);
            String csfdcBaseURL =  sendEmailBaseURL;
            system.debug('csfdcBaseURL'+csfdcBaseURL);
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
                PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+SO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
                 Attachment InvoiceAttachment = new Attachment(Name=SO.Name+'.pdf',contentType='application/pdf',body=pageRef.getContentAsPdf(),ParentId=SO.id);
                 if(String.isNotEmpty(toEmail_id)){ Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                     string senderName = System.Label.SenderDisplayName;
                                                   system.debug('senderName : '+senderName);
                     if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c != null ) { orgaddress = [SELECT id From OrgWideEmailAddress Where Address =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c LIMIT 1]; if(orgaddress.size() > 0) email.setOrgWideEmailAddressId(orgaddress[0].id); } else email.setSenderDisplayName(senderName);
                     if(String.isNotEmpty(EmailsCC)){
                      String[] strArray=EmailsCC.split(',');
                     // ccEmails =strArray;                        
                     email.setCcAddresses(strArray); //ccemails
                    }
                    else email.setCcAddresses(ccemails); String [] toAddresses = toEmail_id.split(',');email.setToAddresses(toAddresses);  email.setBccSender(false);email.setUseSignature(false);email.setTreatBodiesAsTemplate(true);email.setSubject(EmailSubject);
                    
                     if(!EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c){String HtmlEmailBody = '<pre style="font-size: 14px;font-family: sans-serif;">'+TextBody+'</pre>'; email.setHtmlBody(HtmlEmailBody); }else{email.setHtmlBody(HtmlBody);}
                      
                     if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].TemplateAsAttachment__c){ Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment(); attach.setFileName('Sales Order:'+SO.Name+'.pdf'); Blob b = InvoiceAttachment.body; attach.setBody(b);email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                     } Messaging.SendEmailResult [] Email_Result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                     
                     MailSent = Email_Result.get(0).isSuccess();
                
                    if(MailSent){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Email Sent Successfully')); } else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Email_Result.get(0).getErrors()[0].getMessage()));
                    }     
                }
        }
        catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
        return null;
    }
    
    public PageReference Back2SO() {
        PageReference page = new PageReference('/'+SO.Id); return page;  
    } 
    public void exceptionMethod(Exception e, String methodName) {  exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();} 
    
    public pageReference createPDF() {
        PageReference Page;
        try { 
        /*createPDF is called'*/
        String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
        csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
        PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+SO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
       // pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?pageRef.getContentAsPdf():Blob.valueOf('Test'));
            /*soname : '+soname*/
        String ReceiveURL = '/apex/ERP7__OrderPDF?Id='+soname+'&custId='+cusId; Page = new PageReference(ReceiveURL);
        }
        catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
         }
        
        //page.setRedirect(true);
        return Page;
    }
    

}