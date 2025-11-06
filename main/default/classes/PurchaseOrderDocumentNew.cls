public with sharing class PurchaseOrderDocumentNew {
	 public ERP7__PO__c PO                     { get; set; } public String imageURl                             { get; set; } 
    public String POFields                             { get; set; }
    public Organization orgDetails                     { get; set; }  
    public String PONumber                             { get; set; } public String  toCC_id                          { get; set; } public String  toBCC_id                          { get; set; } public String con_AccId                             { get; set; }
    public Contact currentContact                      { get; set; } public String  toEmail_id                          { get; set; }  public String EmailSubject                         { get; set; } public String TextBody                             { get; set; } public List<selectoption> AvailableRecipients      { get; set; }   public List<selectoption> SelectedRecipients       { get; set; } public String selectedEmail                        { get; set; }  public Map<string,string> ccEmails_map             { get; set; }  public list<String>  ccEmails                      { get; set; } 
    public String contactids                           { get; set; }  public EmailTemplate SelectEmailTemplate           { get; set; }
    public EmailTemplate MailselectedTemplate          { get; set; }
    public EmailTemplate EmailedMailselectedTemplate          { get; set; }
    public Boolean MailSent                            { get; set; }
    public String PageWidth                              { get; set; }
    public String sfdcBaseURL                          { get; set; }
    public Boolean isHtmlEmail                         { get; set; }
    public List<ERP7__SetEmailTemplates__c> EmailTemplates_uniqueName { get; set; }  public String HtmlBody                             { get; set; }
    public String exceptionMsg                          { get; set; }  public String ccEmail_Addresses                     { get; set; } public String pdf                                  { get; set; }
    public String poname                              { get; set; }
    public String cusId                                { get; set; }
    public String contactedId                                { get; set; }  public Decimal itemCount                           { get; set; }
    public string recipientId;
    public List<ERP7__Purchase_Line_Items__c> polis   {get; set;}  public ERP7__PO__c poales {get;set;}
    public List<Integer> pageBreakList {get; set;}  public List<ERP7__Purchase_Line_Items__c> poliList   {get; set;}
    public ERP7__PO__c pol {get;set;}
    public Integer requiredPageBreak {get;set;}
    public Integer pageSize {get;set;}
    public Integer pageCount {get;set;}
    public Integer pages {get;set;}
    public Decimal rowHeight {get;set;}  public Decimal rowWiseHeight {get;set;}
    public Map<Integer, String> regMap {get; set;}
     public Map<Integer, Integer> poliLast {get; set;}
    public Map<Integer, Set<ERP7__Purchase_Line_Items__c>> poliMap {get; set;}  public ERP7__Address__c vendorAddress{get;set;} public ERP7__Address__c invoiceAddress{get;set;} public ERP7__Address__c deliveryAddress{get;set;}
     public string addressFields{get;set;}
    
    public PurchaseOrderDocumentNew(){
        try {
             rowHeight = 0;
            pages = 0;
            pageCount = 0;
            requiredPageBreak = 0;
            sfdcBaseURL =System.Url.getOrgDomainUrl().getHost();// URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.content.force.com');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
             String CustID;
            MailSent = false;
             if(ApexPages.CurrentPage().getParameters().get('Id')!= null) PONumber = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('Id'),'UTF-8');
            if(System.currentPageReference().getParameters().get('CustId')!= null) CustID = EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('CustId'),'UTF-8');
             
            poname = PONumber;cusId = CustID ;
            POFields = ERP7.UtilClass.selectStarFromSObject('ERP7__PO__c');ERP7.utilClass.FLSCheck(POFields.split(','),'ERP7__PO__c');
              addressFields=ERP7.UtilClass.selectStarFromSObject('ERP7__Address__c');
            ERP7.utilClass.FLSCheck(addressFields.split(','),'ERP7__Address__c');
            if(PONumber != null) PO = getPurchaseOrder(PONumber); 
            //if(!Schema.sObjectType.Organization.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Organization.Label));//This was commented on 12/01/24 by Asra after getting confirmation from Imran and Moin
            //} else { orgDetails = [SELECT Id, Name FROM Organization WHERE Id =: UserInfo.getOrganizationId()]; }
              if(CustID != null && CustID != '') {
                if(!Schema.sObjectType.Contact.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Contact.Label));
                } else {  currentContact = [Select id, Name, FirstName, LastName ,Email, Fax, AccountId, Phone, ERP7__Contact_Numer__c, ERP7__Company__c From Contact Where Id =: CustID Limit 1];  }
            }           
            itemCount = PO.ERP7__Count_PO_Line_Items__c;  if(currentContact!=null){  toEmail_id=currentContact.Email; con_AccId = currentContact.AccountId; }  List<Contact> conList= new List<Contact>();  conList = [select Id, Name, Email, AccountId from Contact where AccountId=:con_AccId];
                        
            if(conList.size()>0){
                for(Integer i=1;i<conList.size();i++){Integer size=0;size=conList.size();size=size-1;toCC_id+=conList[i].Email;
                    if(size>=i){toCC_id+=','; }} }imageURL='/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label)); } else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; } 
        } catch(Exception e) { exceptionMethod(e, 'Constructor');}
         try{
             EmailTemplates_uniqueName = [Select ERP7__Template_Unique_Name__c, ERP7__OrgWideEmailAddress__c, ERP7__Html_Body__c, ERP7__TemplateAsAttachment__c, ERP7__Add_Template_As_Attachment__c From ERP7__SetEmailTemplates__c where Name ='PurchaseOrderDocNew' limit 1];
             if(EmailTemplates_uniqueName.isEmpty()) {
                 EmailTemplates_uniqueName = new  List<ERP7__SetEmailTemplates__c>();
                 EmailTemplates_uniqueName.add(new ERP7__SetEmailTemplates__c(ERP7__OrgWideEmailAddress__c = null, ERP7__Template_Unique_Name__c = 'PurchaseOrderDocNew',ERP7__TemplateAsAttachment__c = true,ERP7__Add_Template_As_Attachment__c=true,ERP7__Html_Body__c=false));
             }
             if(EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].ERP7__Template_Unique_Name__c != null){
                 MailselectedTemplate = [select id,Body, Subject,HtmlValue from EmailTemplate where DeveloperName =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].ERP7__Template_Unique_Name__c];
                isHtmlEmail =  EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].ERP7__Html_Body__c;}else{ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info,'To SetUp  Email Template provide Unique Template Name or Contact your Administrator'));}}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));}
   
        }
        
       public void Email_Details(){
        /*To get Email Content Before Sending Email For Preview*/
        try{
            Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
            String [] toAddresses_test = new String[] {'test@test.com'};
            email_Attach.setToAddresses(toAddresses_test);
            email_Attach.setTemplateId(MailselectedTemplate.id);
            email_Attach.setSaveAsActivity(false);                     
            email_Attach.setTargetObjectId(currentContact.id);email_Attach.setWhatId(PO.id);Savepoint sp = Database.setSavepoint();
            if(currentContact.Email != Null)  Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
            EmailSubject=email_Attach.getSubject();TextBody = email_Attach.getPlainTextBody();HtmlBody = email_Attach.getHtmlBody();Database.rollback(sp);
        } catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); }
    } 
    
    public ERP7__PO__c getPurchaseOrder(string PONum){
        ERP7__PO__c PO;
        try{
            if(PONum != null){ 
                
                String POFields = ERP7.UtilClass.selectStarFromSObject('ERP7__PO__c');ERP7.utilClass.FLSCheck(POFields.split(','),'ERP7__PO__c');
                //PO = Database.query('select ' + POFields + ', ERP7__Contact__r.Name from ERP7__PO__c where (Id = \'' + String.escapeSingleQuotes(PONum) + '\') Limit 1'); 
        		PO = [select id, ERP7__Total_Amount__c,ERP7__Tax_Amount__c,ERP7__Amount__c, ERP7__Vendor__r.Name,ERP7__Vendor_Contact__r.Name, ERP7__Vendor_Contact__r.Phone, ERP7__Vendor_Contact__r.Email,ERP7__Vendor_Contact__r.Fax,ERP7__Vendor_Address__r.ERP7__Country__c, ERP7__Vendor_Address__r.ERP7__Postal_Code__c,Owner.FirstName, Owner.LastName, ERP7__Payment_Terms__c, ERP7__Project__r.Name, Name, ERP7__Vendor_Address__r.ERP7__State__c, ERP7__Delivery_Address__r.ERP7__State__c, ERP7__Delivery_Address__r.ERP7__Postal_Code__c, ERP7__Delivery_Address__r.ERP7__Address_Line1__c, ERP7__Delivery_Address__r.ERP7__City__c, ERP7__Delivery_Address__r.ERP7__Country__c,ERP7__Customer__c, ERP7__Count_PO_Line_Items__c, ERP7__Vendor_Address__r.ERP7__Address_Line1__c, ERP7__Vendor_Address__r.ERP7__City__c, ERP7__Customer__r.Name, ERP7__Order_Date__c, ERP7__Expected_Delivery_Date__c, ERP7__Expected_Date__c, ERP7__Organisation__r.BillingPostalCode, ERP7__Organisation__r.BillingCountry, ERP7__Organisation__r.BillingState, ERP7__Organisation__r.BillingStreet, ERP7__Organisation__r.BillingCity,ERP7__EmployeeRequester__r.Name,ERP7__EmployeeRequester__r.ERP7__Phone__c,ERP7__EmployeeRequester__r.ERP7__Email__c from ERP7__PO__c where id=:PONum];
                if(PO.ERP7__Invoice_Address__c!=null){  if(!Schema.sObjectType.ERP7__Address__c.isAccessible()) { ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+sObjectType.ERP7__Address__c.Label)); } else {invoiceAddress=Database.query('Select '+String.escapeSingleQuotes(addressFields)+' From ERP7__Address__c Where (Id = \''+String.escapeSingleQuotes(PO.ERP7__Invoice_Address__c)+'\')limit 1'); }
            }
                if(PO.ERP7__Delivery_Address__c!=null){ if(!Schema.sObjectType.ERP7__Address__c.isAccessible()) { ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+sObjectType.ERP7__Address__c.Label)); } else { deliveryAddress=Database.query('Select '+String.escapeSingleQuotes(addressFields)+' From ERP7__Address__c Where (Id = \''+String.escapeSingleQuotes(PO.ERP7__Delivery_Address__c)+'\')limit 1');}
            }
            if(PO.ERP7__Vendor_Address__c!=null){ if(!Schema.sObjectType.ERP7__Address__c.isAccessible()) { ApexPages.addMessage(new  ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+sObjectType.ERP7__Address__c.Label)); }  else{ vendorAddress=Database.query('Select '+String.escapeSingleQuotes(addressFields)+' From ERP7__Address__c Where (Id = \''+String.escapeSingleQuotes(PO.ERP7__Vendor_Address__c)+'\')limit 1'); }
            }
            }
        }
        catch(Exception e){  exceptionMethod(e,'getPurchaseOrder');
        }
        return PO;
    }
     public void buildCcEmail(){ String[] strArray=contactids.split(','); ccEmails =strArray; }
    
      public PageReference sendPO(){
        List<OrgWideEmailAddress> orgaddress = new List<OrgWideEmailAddress>();
        try{
            String csfdcBaseURL = sfdcBaseURL;
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            PageReference pageRef;
            if(ApexPages.currentPage().getParameters().get('val')!=null) pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+contactedId+'&related_to_id='+PO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            else pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+PO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail');
            Attachment InvoiceAttachment = new Attachment(Name=PO.Name+'.pdf',contentType='application/pdf',body=(!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueof('Test'),ParentId=PO.id);
            if(String.isNotEmpty(toEmail_id)){ Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                              if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].ERP7__OrgWideEmailAddress__c != null ) {orgaddress = [SELECT id From OrgWideEmailAddress Where Address =:EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].ERP7__OrgWideEmailAddress__c LIMIT 1];if(orgaddress.size() > 0) email.setOrgWideEmailAddressId(orgaddress[0].id);}else{ email.setSenderDisplayName('Direct Construction Products');String [] toAddresses = toEmail_id.split(',');email.setToAddresses(toAddresses); }
               //email.setBccSender(false);
               if(String.isNotEmpty(toCC_id)) {String [] toCCAddresses = toCC_id.split(',');email.setCcAddresses(toCCAddresses); }
              if(String.isNotEmpty(toBCC_id)) {String [] toBCCAddresses = toBCC_id.split(',');email.setBccAddresses(toBCCAddresses);}
               email.setUseSignature(false);email.setTreatBodiesAsTemplate(true);email.setSubject(EmailSubject);
                
                if(!EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].ERP7__Html_Body__c){ String HtmlEmailBody = '<pre style="font-size: 14px;font-family: sans-serif;">'+TextBody+'</pre>'; email.setHtmlBody(HtmlEmailBody); }else{email.setHtmlBody(HtmlBody);}
                
                if(EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].ERP7__TemplateAsAttachment__c){Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment(); attach.setFileName('Purchase Order:'+PO.Name+'.pdf'); Blob b = InvoiceAttachment.body;attach.setBody(b);email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
                } Messaging.SendEmailResult [] Email_Result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});MailSent = Email_Result.get(0).isSuccess();
                
                if(MailSent){ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Email Sent Successfully'));} else{ ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Email_Result.get(0).getErrors()[0].getMessage()));
                }     
            }
        }
        catch(Exception e){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); }
        return null;
    }
      public pageReference createPDF() {
        String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
        //EmailedMailselectedTemplate =  [select id,Body, Subject,HtmlValue from EmailTemplate where DeveloperName ='SalesOrder_Invoice_Pdf'];
        PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+PO.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
       
        //PageReference pageRef = new PageReference('https://erp-mark-7-dev-ed--c.eu5.content.force.com/email/templaterenderer?base_href=https%3A%2F%2Ferp-mark-7-dev-ed--erp7.eu5.salesforce.com&id=00X24000000gr2qEAA&preview_frame=previewFrame&recipient_type_id=0032400001CNrpLAAT&related_to_id=a0D2400000ZdJDJEA3&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val=null');
        //pageRef.setRedirect(true);
        pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueOf('Test'));
        String ReceiveURL = '/apex/PurchaseOrderDocumentPdf?Id='+PONumber+'&custId='+cusId;
                PageReference Page = new PageReference(ReceiveURL);
                return Page;
       // return page.invoicepdf;
    } 
      public string getRecipientId() {return recipientId; }
     public void setRecipientId(string inString) {
        try{
        recipientId = inString;
        Integer polength=0;
        pages = 0;
        Integer j1=0;
        Integer k1=0;
        Integer l1=0;
        String description = '';
        poliLast = new Map<Integer, Integer>();
        poliMap = new Map<Integer, set<ERP7__Purchase_Line_Items__c>>();
        Set<ERP7__Purchase_Line_Items__c> poli = new Set<ERP7__Purchase_Line_Items__c>();
        regMap = new Map<Integer, String>();
        //pol = [select id, ERP7__Expected_Date__cERP7__Total_Amount__c,ERP7__Customer__r.Phone,ERP7__Tax_Amount__c,ERP7__Amount__c, ERP7__Vendor__r.Name,ERP7__Vendor_Contact__r.Name, ERP7__Vendor_Contact__r.Phone, ERP7__Vendor_Contact__r.Email,ERP7__Vendor_Contact__r.Fax,ERP7__Vendor_Address__r.ERP7__Country__c, ERP7__Vendor_Address__r.ERP7__Postal_Code__c,Owner.FirstName, Owner.LastName, ERP7__Payment_Terms__c, ERP7__Project__r.Name, Name, ERP7__Vendor_Address__r.ERP7__State__c, ERP7__Delivery_Address__r.ERP7__State__c, ERP7__Delivery_Address__r.ERP7__Postal_Code__c, ERP7__Delivery_Address__r.ERP7__Address_Line1__c, ERP7__Delivery_Address__r.ERP7__City__c, ERP7__Delivery_Address__r.ERP7__Country__c,ERP7__Customer__c, ERP7__Count_PO_Line_Items__c, ERP7__Vendor_Address__r.ERP7__Address_Line1__c, ERP7__Vendor_Address__r.ERP7__City__c, ERP7__Customer__r.Name, ERP7__Order_Date__c, ERP7__Expected_Delivery_Date__c, ERP7__Expected_Date__c, ERP7__Organisation__r.BillingPostalCode, ERP7__Organisation__r.BillingCountry, ERP7__Organisation__r.BillingState, ERP7__Organisation__r.BillingStreet, ERP7__Organisation__r.BillingCity,ERP7__EmployeeRequester__r.Name,ERP7__EmployeeRequester__r.ERP7__Phone__c,ERP7__EmployeeRequester__r.ERP7__Email__c from ERP7__PO__c where id=:recipientId];
        pol = [select id, ERP7__Expected_Date__c,ERP7__Order_Date__c,Name,ERP7__Vendor__r.Name,ERP7__Vendor_Contact__r.Name,ERP7__Vendor__r.ERP7__Company__c,ERP7__Vendor_Address__r.ERP7__Address_Line1__c,ERP7__Vendor_Address__r.ERP7__Address_Line2__c,ERP7__Vendor_Address__r.ERP7__Address_Line3__c,ERP7__Vendor_Address__r.ERP7__City__c,ERP7__Vendor_Address__r.ERP7__Country__c,ERP7__Vendor_Address__r.ERP7__Postal_Code__c,ERP7__Vendor_Contact__r.Phone,ERP7__Customer__c,
               ERP7__EmployeeRequester__r.Name,ERP7__Delivery_Address__r.ERP7__Address_Line1__c,ERP7__Delivery_Address__r.ERP7__City__c,ERP7__Delivery_Address__r.ERP7__Country__c,ERP7__EmployeeRequester__r.ERP7__Phone__c,ERP7__EmployeeRequester__r.ERP7__Email__c,ERP7__Customer__r.Name,ERP7__Customer__r.Phone,ERP7__Payment_Terms__c,ERP7__Count_PO_Line_Items__c,ERP7__Total_Due__c,ERP7__Tax_Amount__c,ERP7__Total_Amount__c,ERP7__Delivery_Address__r.ERP7__State__c,
               ERP7__Delivery_Address__r.ERP7__Postal_Code__c,ERP7__Organisation__r.Name,ERP7__Organisation__r.BillingStreet,ERP7__Organisation__r.BillingCity,ERP7__Organisation__r.BillingState,ERP7__Organisation__r.BillingCountry,ERP7__Organisation__r.Phone,ERP7__Organisation__r.ERP7__Email__c,ERP7__Vendor_Address__r.ERP7__County__c,ERP7__Delivery_Address__r.ERP7__Organisation__r.Name,ERP7__Delivery_Address__r.ERP7__Address_Line2__c,ERP7__Delivery_Address__r.ERP7__Address_Line3__c,
               ERP7__Delivery_Address__r.ERP7__County__c,ERP7__Delivery_Address__r.ERP7__Organisation__r.Phone,ERP7__Amount__c,ERP7__Description__c,ERP7__Barcode__c
               from ERP7__PO__c where  id=:recipientId];
            polis = [SELECT id, Name,ERP7__Product__r.Name,ERP7__Unit_Price__c,ERP7__Unit_of_Measure__c,ERP7__Total_Price__c, ERP7__Description__c, ERP7__Quantity__c, ERP7__Product__c,ERP7__Product__r.StockKeepingUnit, ERP7__Sort_Order__c, ERP7__Purchase_Orders__c,ERP7__Product__r.ERP7__UoM__c from ERP7__Purchase_Line_Items__c where ERP7__Purchase_Orders__c=:recipientId order by ERP7__Sort_Order__c];
          //for(ERP7__Purchase_Line_Items__c ss : polis){
          //  if(ss.ERP7__Description__c != null) ss.ERP7__Description__c = ss.ERP7__Description__c.stripHtmlTags();
          // }
        pageBreakList = new List<Integer>(); 
        Boolean page1=true;Boolean page2=true;Boolean page3=true;
         	if(pol.ERP7__Description__c == null){
            for(Integer j=0;j<polis.size();j++){
                Decimal pagelength=0;
                String description1 = '';
                if((polis[j].ERP7__Description__c != null) && (page1)) {
                    description1 = polis[j].ERP7__Description__c;
                    polength = polength + description1.length() + 100;
                    if(polength > 1600){
                        pageBreakList.add(1);
                        page1=false;
                        requiredPageBreak = 1;
                        pagelength = polength - description1.length() - 100;
                        pagelength = 1600 - pagelength;
                        pagelength = pagelength / 2;
                        String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + '- ';
                        }
                        regMap.put(1,data);
                        pages = 1;
                        polength = 0;
                        pagelength=0;
                        poliMap.put(1, poli);
                        j1=j;
                        poli = new set<ERP7__Purchase_Line_Items__c>();
                        break;
                    }else{
                        poli.add(polis[j]);
                    }
                }else{
                    polength = polength + 200;
                    if(polength < 1600) {
                        poli.add(polis[j]);
                    }else{
                        pageBreakList.add(1);
                        page1=false;
                        requiredPageBreak = 1;
                        pagelength = polength - 200;
                        pagelength = 1600 - pagelength;
                        pagelength = pagelength / 2;
                        String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + 'm ';
                        }
                        regMap.put(1,data);
                        pages = 1;
                        polength = 0;
                        pagelength=0;
                        poliMap.put(1, poli);
                        if(j!=0) j1=j;
                        poli = new set<ERP7__Purchase_Line_Items__c>();
                        break;
                    }
                }
                if(j+1==polis.size()){
                    pageBreakList.add(1);
                    page1=false;
                    pagelength = 1600 - polength;
                    pagelength = pagelength/2;
                    String data = '';
                    for(Integer m=0;m<pagelength;m++){
                        data = data + '- ';
                    }
                    regMap.put(1,data);
                    //polength = 0;
                    pagelength=0;
                    poliMap.put(1, poli);
                    j1=j+1;
                    poli = new set<ERP7__Purchase_Line_Items__c>();
                    break;
                }
            }
            
            
            if(pages==1){
                for(Integer k=j1;k<polis.size();k++){
                    Decimal pagelength=0;
                    String description2 = '';
                    if((polis[k].ERP7__Description__c != null) && (page2)){
                        description2 = polis[k].ERP7__Description__c;
                        polength = polength + description2.length() + 100;  
                        if(polength > 1600){
                            pageBreakList.add(2);
                            page2=false;
                            pagelength = polength - description2.length() - 100;
                            pagelength = 1600 - pagelength;
                            String data = '';
                            pagelength = pagelength / 2;
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(2,data);
                            pages = 2;
                            polength = 0;
                            pagelength=0;
                            poliMap.put(2, poli);
                            k1=k;
                            poli = new set<ERP7__Purchase_Line_Items__c>();
                            break;
                        }else{
                            poli.add(polis[k]);
                        }
                    }else{
                        polength = polength + 200;
                        if(polength < 1600) poli.add(polis[k]);
                        else {
                            pageBreakList.add(2);
                            page2=false;
                            pagelength = polength - 200;
                            pagelength = 1600 - pagelength;
                            pagelength = pagelength / 2;
                            String data = '';
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(2,data);
                            //regMap.put(2,pagelength);
                            pages = 2;
                            polength = 0;
                            pagelength=0;
                            poliMap.put(2, poli);
                            k1=k;
                            poli = new set<ERP7__Purchase_Line_Items__c>();
                            break;
                        }
                    }
                    
                    if(k+1==polis.size()){
                        pageBreakList.add(2);
                        page2=false;
                        pagelength = polength;
                        pagelength = 1600 - polength;
                        pages = 2;
                        rowHeight = pagelength;
                        pagelength = pagelength / 2;
                        String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + '- ';
                        }
                        regMap.put(2,data);
                        //regMap.put(2,pagelength);
                        //polength = 0;
                        pagelength=0;
                        poliMap.put(2, poli);
                        k1 = k+1;
                        poli = new set<ERP7__Purchase_Line_Items__c>();
                        break;
                    }
                    
                }
            }   
       if(pages==2){
        for(Integer k=k1;k<polis.size();k++){
                    Decimal pagelength=0;
                    String description2 = '';
                    if((polis[k].ERP7__Description__c != null) && (page2)){
                        description2 = polis[k].ERP7__Description__c;
                        polength = polength + description2.length() + 100;
                        if(polength > 1600){
                            pageBreakList.add(3);
                            page2=false;
                            pagelength = polength - description2.length() - 100;
                            pagelength = 1600 - pagelength;
                            String data = '';
                            pagelength = pagelength / 2;
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(3,data);
                            pages = 3;
                            polength = 0;
                            pagelength=0;
                            poliMap.put(3, poli);
                            k1=k;
                            poli = new set<ERP7__Purchase_Line_Items__c>();
                            break;
                        }else{
                            poli.add(polis[k]);
                        }
                    }else{
                        polength = polength + 200;
                        if(polength < 1600) poli.add(polis[k]);
                        else {
                            pageBreakList.add(3);
                            page2=false;
                            pagelength = polength - 200;
                            pagelength = 1600 - pagelength;
                            pagelength = pagelength / 2;
                            String data = '';
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(3,data);
                            //regMap.put(2,pagelength);
                            pages = 3;
                            polength = 0;
                            pagelength=0;
                            poliMap.put(3, poli);
                            k1=k;
                            poli = new set<ERP7__Purchase_Line_Items__c>();
                            break;
                        }
                    }
                    
                    if(k+1==polis.size()){
                        pageBreakList.add(3);
                        page3=false;
                        pagelength = polength;
                        pagelength = 1600 - polength;
                        rowHeight = pagelength;
                        pagelength = pagelength / 2;
                        String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + '- ';
                        }
                        regMap.put(3,data);
                        //regMap.put(2,pagelength);
                        polength = 0;
                        pagelength=0;
                        poliMap.put(3, poli);
                        pages = 3;
                        poli = new set<ERP7__Purchase_Line_Items__c>();
                        break;
                    }
                    
                }
       }
        pageSize = 2380 - polength;
        pageSize = pageSize / 2;
        PageWidth = '';
        for(Integer m=0;m<pageSize;m++){
            PageWidth = PageWidth + '- ';    
        }
        }else{
              for(Integer j=0;j<polis.size();j++){
                Decimal pagelength=0;
                String description1 = '';
                if((polis[j].ERP7__Description__c != null) && (page1)) {
                    description1 = polis[j].ERP7__Description__c;
                    polength = polength + description1.length() + 100;
                    if(polength > 1600){
                        pageBreakList.add(1);
                        page1=false;
                        requiredPageBreak = 1;
                        pagelength = polength - description1.length() - 100;
                        pagelength = 1600 - pagelength;
                        pagelength = pagelength / 2;
                        String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + '- ';
                        }
                        regMap.put(1,data);
                        pages = 1;
                        polength = 0;
                        pagelength=0;
                        poliMap.put(1, poli);
                        j1=j;
                        poli = new set<ERP7__Purchase_Line_Items__c>();
                        break;
                    }else{
                        poli.add(polis[j]);
                    }
                }else{
                    polength = polength + 200;
                    if(polength < 1600) {
                        poli.add(polis[j]);
                    }else{
                        pageBreakList.add(1);page1=false;requiredPageBreak = 1;pagelength = polength - 200;pagelength = 1600 - pagelength;pagelength = pagelength / 2;String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + 'm ';
                        }
                        regMap.put(1,data);pages = 1;polength = 0;pagelength=0;poliMap.put(1, poli);if(j!=0) j1=j;poli = new set<ERP7__Purchase_Line_Items__c>();break;
                    }
                }
                if(j+1==polis.size()){
                    pageBreakList.add(1);page1=false;pagelength = 1600 - polength;String data = '';pagelength = pagelength / 2;
                    for(Integer m=0;m<pagelength;m++){
                        data = data + '- ';
                    }
                    regMap.put(1,data);pagelength=0;poliMap.put(1, poli);j1=j+1;poli = new set<ERP7__Purchase_Line_Items__c>();break;
                }
            }

            if(pages==1){
                for(Integer k=j1;k<polis.size();k++){
                    Decimal pagelength=0;
                    String description2 = '';
                  
                    if((polis[k].ERP7__Description__c != null) && (page2)){
                        description2 = polis[k].ERP7__Description__c;
                        polength = polength + description2.length() + 100;  
                        if(polength > 1670){
                            pageBreakList.add(2);
                            page2=false;
                            pagelength = polength - description2.length() - 100;
                            pagelength = 1670 - pagelength;
                            String data = '';
                            pagelength = pagelength / 2;
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(2,data);
                            pages = 2;
                            polength = 0;
                            pagelength=0;
                            poliMap.put(2, poli);
                            k1=k;
                            poli = new set<ERP7__Purchase_Line_Items__c>();
                            break;
                        }else{
                            poli.add(polis[k]);
                        }
                    }else{
                        polength = polength + 200;
                        if(polength < 1670) poli.add(polis[k]);
                        else {
                            pageBreakList.add(2);page2=false;pagelength = polength - 200;pagelength = 1670 - pagelength;pagelength = pagelength / 2;String data = '';
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(2,data);pages = 2;polength = 0;pagelength=0;poliMap.put(2, poli);k1=k;poli = new set<ERP7__Purchase_Line_Items__c>();break;
                        }
                    }
                    
                    if(k+1==polis.size()){
                        pageBreakList.add(2);page2=false;pagelength = 2870 - polength;pages = 2;pagelength = pagelength / 2;String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + '- ';
                        }
                        regMap.put(2,data);pagelength=0;poliMap.put(2, poli);k1 = k+1;poli = new set<ERP7__Purchase_Line_Items__c>();break;
                    }
                    
                }
            }   
       if(pages==2){
        for(Integer k=k1;k<polis.size();k++){
                    Decimal pagelength=0;
                    String description2 = '';
                    if((polis[k].ERP7__Description__c != null) && (page2)){
                        description2 = polis[k].ERP7__Description__c;
                        polength = polength + description2.length() + 100;  
                        if(polength > 1600){
                            pageBreakList.add(3);page2=false;pagelength = polength - description2.length() - 100;pagelength = 1600 - pagelength;String data = '';pagelength = pagelength / 2;
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(3,data);pages = 3;polength = 0;pagelength=0;poliMap.put(3, poli);k1=k;poli = new set<ERP7__Purchase_Line_Items__c>();break;
                        }else{
                            poli.add(polis[k]);
                        }
                    }else{
                        polength = polength + 200;
                        if(polength < 1600) poli.add(polis[k]);
                        else {
                            pageBreakList.add(3);page2=false;pagelength = polength - 200;pagelength = 1600 - pagelength;pagelength = pagelength / 2;String data = '';
                            for(Integer m=0;m<pagelength;m++){
                                data = data + 'm ';
                            }
                            regMap.put(3,data);pages = 3;polength = 0;pagelength=0;poliMap.put(3, poli);k1=k;poli = new set<ERP7__Purchase_Line_Items__c>();break;
                        }
                    }
                    
                    if(k+1==polis.size()){
                        pageBreakList.add(3);
                        page3=false;
                        pagelength = polength;
                        pagelength = 1600 - polength;
                        rowHeight = pagelength;
                        pagelength = pagelength / 2;
                        String data = '';
                        for(Integer m=0;m<pagelength;m++){
                            data = data + 'm ';
                        }
                        regMap.put(3,data);
                        //regMap.put(2,pagelength);
                        polength = 0;
                        pagelength=0;
                        poliMap.put(3, poli);
                        pages = 3;
                        poli = new set<ERP7__Purchase_Line_Items__c>();
                        break;
                    }
                    
                }
       }
        pageSize = 1600 - polength;
        pageSize = pageSize / 2;
        PageWidth = '';
        for(Integer m=0;m<pageSize;m++){
            PageWidth = PageWidth + '- ';    
        }  
        }
        /*else if(pages>1) pageSize = 3100;
        else pageSize = 1000;*/
        }catch(Exception e){}
    }
    
    public PageReference Back2PO() { PageReference page = new PageReference('/'+PO.Id); return page; } 
     public void exceptionMethod(Exception e, String methodName) {  exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();} 
}