public With Sharing Class PaymentDocument{ 
    public ERP7__Payment__c SO                     { get; set; }
    public String imageURl                             { get; set; } 
    public String SOFields                             { get; set; }
    public String addressFields                        { get; set; } 
    public Organization orgDetails                     { get; set; }  
    public String SONumber                             { get; set; }
    public Contact currentContact                      { get; set; }
    public String  toEmail_id                          { get; set; }
    public String con_AccId                             { get; set; } 
    public String  toCC_id                          { get; set; }
    public String  toBCC_id                          { get; set; }
    public String EmailSubject                         { get; set; }
    public String TextBody                             { get; set; }
    public List<selectoption> AvailableRecipients      { get; set; }
    public List<selectoption> SelectedRecipients       { get; set; }
    public String selectedEmail                        { get; set; }
    public Map<string,string> ccEmails_map             { get; set; }
    public list<String>  ccEmails                      { get; set; } 
    public String contactids                           { get; set; }
    public EmailTemplate SelectEmailTemplate           { get; set; }
    public EmailTemplate MailselectedTemplate          { get; set; }
    public Boolean MailSent                            { get; set; }
    public String sfdcBaseURL                          { get; set; }
    public Boolean isHtmlEmail                         { get; set; }
    public List<SetEmailTemplates__c> EmailTemplates_uniqueName { get; set; }
    public String HtmlBody                             { get; set; }
    public Address__c vendorAddress                     { get; set; }
    public Address__c invoiceAddress                    { get; set; }            
    public Address__c deliveryAddress                   { get; set; }
    public String exceptionMsg                          { get; set; }
    public String ccEmail_Addresses                     { get; set; }
    public String pdf                                  { get; set; }
    public String soname                              { get; set; }
    public String cusId                                { get; set; }
    public string recipientId;
    public string relatedToId;
    public List<ERP7__Voucher__c> vouchers              { get; set; }
    public List<ERP7__Payment_Applied_on_Invoice__c> Invoices              { get; set; }
    public ERP7__Payment__c recipient                           { get; set;}
    public List<ERP7__Debit_Note_Applied_on_Voucher__c > debitNoteList              { get; set; }
    public PaymentDocument() { 
        try {
            debitNoteList = new List<ERP7__Debit_Note_Applied_on_Voucher__c >();
            //vouchers = new List<ERP7__Voucher__c>();
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            
            /* commented this */
            //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('.visual.force.com');
            sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.content.force.com');
            //sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.documentforce.com');
            //
            /* till here */
            
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
            String CustID;
            MailSent = false;
            if(ApexPages.CurrentPage().getParameters().get('Id')!= null) SONumber = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('Id'),'UTF-8');
            //if(System.currentPageReference().getParameters().get('custId')!= null) CustID = EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('custId'),'UTF-8');
            ERP7__Payment__c pp=new ERP7__Payment__c();
            pp=Database.query('select id, name, ERP7__Sales_Order__r.ERP7__Contact__r.Id, ERP7__Sales_Order__c, ERP7__Bill__c, ERP7__Bill__r.ERP7__Purchase_Order__r.ERP7__Vendor_Contact__r.Id, ERP7__Accounts__r.Id from ERP7__Payment__c where (Id = \'' + String.escapeSingleQuotes(SONumber) + '\') Limit 1'); 
            //pp=[select id, name, ERP7__Sales_Order__r.ERP7__Contact__r.Id, ERP7__Sales_Order__c, ERP7__Bill__c, ERP7__Bill__r.ERP7__Purchase_Order__r.ERP7__Vendor_Contact__r.Id, ERP7__Accounts__r.Id from ERP7__Payment__c where Id=:SONumber];
            soname = SONumber;
            if(pp.ERP7__Sales_Order__c != null)
                cusId = pp.ERP7__Sales_Order__r.ERP7__Contact__r.Id;
            if(pp.ERP7__Bill__c != null)
                cusId = pp.ERP7__Bill__r.ERP7__Purchase_Order__r.ERP7__Vendor_Contact__r.Id;
            //String CID=pp.
            SOFields = UtilClass.selectStarFromSObject('ERP7__Payment__c');
            utilClass.FLSCheck(SOFields.split(','),'ERP7__Payment__c');
            addressFields = UtilClass.selectStarFromSObject('Address__c');
            utilClass.FLSCheck(addressFields.split(','),'Address__c');
            if(SONumber != null) SO = getSalesOrder(SONumber);
            SO = pp;
            //if(!Schema.sObjectType.Organization.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Organization.Label));//This was commented on 12/01/24 by Asra after getting confirmation from Imran and Moin
                                                               // } else { orgDetails = [SELECT Id, Name FROM Organization WHERE Id =: UserInfo.getOrganizationId()]; }
            
            //if(cusId != null && cusId != '') {
            if(!Schema.sObjectType.Contact.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Contact.Label));
                                                           } else { 
                                                               currentContact = [Select id, Name, FirstName, LastName ,Email, Fax, AccountId, Phone, Contact_Numer__c, Company__c From Contact Where AccountId =:pp.ERP7__Accounts__c and Email!=null and ERP7__Payment_Remittance__c=true Limit 1]; }
            //}
            if(currentContact != null) {
                toEmail_id = currentContact.Email;
                con_AccId = currentContact.AccountId;
            }
            List<Contact> conList= new List<Contact>();
            conList = [select Id, Name, Email, AccountId from Contact where AccountId=:con_AccId and Email!=null];
            if(conList.size()>0){
                for(Integer i=1;i<conList.size();i++){
                    Integer size=0;
                    size=conList.size();
                    size=size-1;
                    toCC_id+=conList[i].Email;
                    if(size>=i){
                        toCC_id+=',';
                    }
                }
            }
            
            imageURL='/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));
                                                            } else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
                                                                    if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; } } catch(Exception e) { exceptionMethod(e, 'Constructor'); }
        
        /*Querying The Template for Preview and attachment*/
        try{
            EmailTemplates_uniqueName = [Select Template_Unique_Name__c,OrgWideEmailAddress__c,Html_Body__c,TemplateAsAttachment__c,Add_Template_As_Attachment__c From SetEmailTemplates__c where Name ='Payment_Document' limit 1];
            if(EmailTemplates_uniqueName.isEmpty()) {
                EmailTemplates_uniqueName = new  List<SetEmailTemplates__c>();
                EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null,Template_Unique_Name__c = 'Payment_Document',TemplateAsAttachment__c = true,Add_Template_As_Attachment__c=true,Html_Body__c=false));
            }
            if(EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c != null){
                MailselectedTemplate = [select id,Body, Subject,HtmlValue from EmailTemplate where DeveloperName =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c];
                isHtmlEmail =  EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c;}else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'To SetUp  Email Template provide Unique Template Name or Contact your Administrator'));}}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));}
    }
    
    
    public string getRecipientId() {return recipientId; }
    public void setRecipientId(string inString) {
        recipientId = inString;
        List<ERP7__Payment_Applied_on_Voucher__c> pvouList = new List<ERP7__Payment_Applied_on_Voucher__c>();
        pvouList = [select Id, Name, ERP7__Payment__c, ERP7__Voucher__c from ERP7__Payment_Applied_on_Voucher__c where ERP7__Payment__c = :recipientId];
        debitNoteList = [select Id, ERP7__Debit_Note__r.ERP7__Credit_Note_Date__c, Name, ERP7__Debit_Note__c, ERP7__Amount__c, ERP7__Debit_Note__r.ERP7__Credit_Note_Number__c  from ERP7__Debit_Note_Applied_on_Voucher__c  where ERP7__Payment__c = :recipientId];
        
        if(pvouList.size()<=0){
            Invoices = [SELECT id, Name, ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Invoice__r.ERP7__Order__r.Name,ERP7__Invoice__r.ERP7__Order_S__r.Name, ERP7__Invoice__r.ERP7__Due_Date__c, ERP7__Invoice__r.ERP7__Invoice_Amount__c  From ERP7__Payment_Applied_on_Invoice__c  WHERE ERP7__Payment__c = :recipientId];
        }else{
            Set<ID> vouIds = new Set<Id>();
            for(ERP7__Payment_Applied_on_Voucher__c pov : pvouList){
                if(pov.ERP7__Voucher__c != null){
                    vouIds.add(pov.ERP7__Voucher__c);
                }
            }
            vouchers = [SELECT id,name, ERP7__Vendor_invoice_Bill__c,ERP7__Vendor_invoice_Bill__r.ERP7__Purchase_Order__r.Name, ERP7__Vendor_invoice_Bill__r.Name, ERP7__Vendor_invoice_Bill__r.ERP7__Amount__c, ERP7__Vendor_invoice_Bill__r.ERP7__Amount_Paid__c, ERP7__Vendor_invoice_Bill__r.ERP7__Due_Date__c, ERP7__Vendor_invoice_Bill__r.ERP7__Total_Amount__c, ERP7__Amount__c,ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name, ERP7__Payment__c FROM ERP7__Voucher__c WHERE ID IN :vouIds];
        }
        //recipient = [SELECT id,name FROM ERP7__Payment__c WHERE id = :recipientId];
    }
    public void Email_Details(){
        /*To get Email Content Before Sending Email For Preview*/
        try{
            Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
            String [] toAddresses_test = new String[] {'test@test.com'};
                email_Attach.setToAddresses(toAddresses_test);
            email_Attach.setTemplateId(MailselectedTemplate.id);
            email_Attach.setSaveAsActivity(false);                     
            if(currentContact != null) email_Attach.setTargetObjectId(currentContact.id);
            email_Attach.setWhatId(SO.id);
            Savepoint sp = Database.setSavepoint();
            if(currentContact != Null)  Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});
            EmailSubject=email_Attach.getSubject();
            TextBody = email_Attach.getPlainTextBody();
            HtmlBody = email_Attach.getHtmlBody();
            Database.rollback(sp);
            
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
        }
    }
    
    /*
Method For Getting SO Record
*/ 
    public ERP7__Payment__c getSalesOrder(String SONum) {
        ERP7__Payment__c SO;
        try {            
            if(!Schema.sObjectType.ERP7__Payment__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Payment__c.Label));
                                                                    } else { SO = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ', ERP7__Sales_Order__r.ERP7__Contact__r.Id from ERP7__Payment__c where (Id = \'' + String.escapeSingleQuotes(SONum) + '\') Limit 1'); }
            
        }catch(Exception e) {
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
            
            exceptionMethod(e, 'getSalesOrder'); }
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
            String csfdcBaseURL = sendEmailBaseURL;
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            PageReference pageRef;
            if(currentContact!=null) pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+SO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            else pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+SO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            Attachment InvoiceAttachment = new Attachment(Name=SO.Name+'.pdf',contentType='application/pdf',body=pageRef.getContentAsPdf(),ParentId=SO.id);
            if(String.isNotEmpty(toEmail_id)){ Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                              
                                              if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c != null ) {
                                                  orgaddress = [SELECT id From OrgWideEmailAddress Where Address =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].OrgWideEmailAddress__c LIMIT 1];
                                                  if(orgaddress.size() > 0) email.setOrgWideEmailAddressId(orgaddress[0].id);
                                              }
                                              else email.setSenderDisplayName('Aqxolt India Private Limited');
                                              
                                              //email.setCcAddresses(ccemails);
                                              String [] toAddresses = toEmail_id.split(',');email.setToAddresses(toAddresses); 
                                              if(String.isNotEmpty(toCC_id)) {
                                                  String [] toCCAddresses = toCC_id.split(',');
                                                  email.setCcAddresses(toCCAddresses);
                                              }
                                              if(String.isNotEmpty(toBCC_id)) {
                                                  String [] toBCCAddresses = toBCC_id.split(',');
                                                  email.setBccAddresses(toBCCAddresses);
                                              }
                                              //email.setBccSender(false);
                                              email.setUseSignature(false);email.setTreatBodiesAsTemplate(true);email.setSubject(EmailSubject);
                                              
                                              if(!EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Html_Body__c){String HtmlEmailBody = '<pre style="font-size: 14px;font-family: sans-serif;">'+TextBody+'</pre>'; email.setHtmlBody(HtmlEmailBody); }else{email.setHtmlBody(HtmlBody);}
                                              
                                              if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].TemplateAsAttachment__c){
                                                  Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                                  attach.setFileName('Payment :'+SO.Name+'.pdf'); Blob b = InvoiceAttachment.body;
                                                  attach.setBody(b);email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                                              } Messaging.SendEmailResult [] Email_Result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                                              
                                              MailSent = Email_Result.get(0).isSuccess();
                                              
                                              if(MailSent){
                                                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Email Sent Successfully'));
                                              } else{
                                                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Email_Result.get(0).getErrors()[0].getMessage()));
                                              }     
                                             }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
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
            String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            PageReference pageRef;
            //if(currentContact!=null) pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+SO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            //else pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+SO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            
            //pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?pageRef.getContentAsPdf():Blob.valueOf('Test'));
            String ReceiveURL = '/apex/ERP7__PaymentPdf?Id='+soname+'&custId='+cusId;
            
            Page = new PageReference(ReceiveURL);
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
        }
        
        //page.setRedirect(true);
        return Page;
    }
    
}