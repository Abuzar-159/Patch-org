public with sharing class QuotationPDFController {

    
    public Contact currentContact                  { get; set; }  public Address__c billingAddress               { get; set; }   public Quotes__c currentQuote                  { get; set; }
    public Quotes__c currentQuotes                 { get; set; }
    public String quoteFields                      { get; set; }
    public String quoteLineItemFields              { get; set; }   
    public String addressFields                    { get; set; } public Decimal subtotal                        { get; set; } public Decimal discount                        { get; set; }public Decimal Vat                             { get; set; }public Decimal tax                             { get; set; }public Decimal totalDue                        { get; set; }
    public String quoteNumber                      { get; set; }public String imageURl                         { get; set; } 
    public String errorMsg                         { get; set; }public String emailBody                        { get; set; }     
    public String exceptionMsg                     { get; set; }  public String emailSubject                     { get; set; }
    public String toEmail_Address                  { get; set; }public String ccEmail_Addresses                { get; set; }        
    public Organization orgDetails                 { get; set; }public List<Quote_Line_Items__c> currentItems  { get; set; }
    public List<Quote_Line_Items__c> currentItemss { get; set; }       
    
    /*
      Constructor
    */
    public QuotationPDFController() {
        try {
            String CustID;
            if(System.currentPageReference().getParameters().get('custId')!= null) CustID = EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('custId'),'UTF-8');
            if(ApexPages.CurrentPage().getParameters().get('quoteNo')!= null) quoteNumber = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('quoteNo'),'UTF-8');
            QuoteLineItems = new List<LineItemWrapper>();
            currentItemss = new List<Quote_Line_Items__c>(); 
            quoteFields = UtilClass.selectStarFromSObject('ERP7__Quotes__c');
            UtilClass.FlSCheck(quoteFields.split(',') ,'ERP7__Quotes__c');
            addressFields = UtilClass.selectStarFromSObject('ERP7__Address__c');
            UtilClass.FlSCheck(addressFields.split(',') ,'ERP7__Address__c');
            quoteLineItemFields = UtilClass.selectStarFromSObject('ERP7__Quote_Line_Items__c'); 
            UtilClass.FlSCheck(quoteLineItemFields.split(',') ,'ERP7__Quote_Line_Items__c');
            currentQuotes = getCurrentQuotations(quoteNumber);
            if(currentQuotes != null) currentItemss = getCurrentQuoteItemss(currentQuotes.Id);
                        
            //if(!Schema.sObjectType.Organization.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Organization.Label));//This was commented on 12/01/24 by Asra after getting confirmation from Imran and Moin
            //} else { orgDetails = [SELECT Id, Name FROM Organization WHERE Id =: UserInfo.getOrganizationId()]; }
            
            if(CustID != null) {
                if(!Schema.sObjectType.Contact.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Contact.Label));
                } else { currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId, Phone, Contact_Numer__c, Company__c From Contact Where Contact_Numer__c =: CustID Limit 1]; }}   if(currentContact != null) toEmail_Address = currentContact.Email; if(currentItemss.size() > 0) { for(Quote_Line_Items__c qtli : currentItemss){  LineItemWrapper wrap = new LineItemWrapper();     if(Schema.sObjectType.Product2.isAccessible() && Schema.sObjectType.Product2.fields.SKU__c.isAccessible() && Schema.sObjectType.Quote_Line_Items__c.isAccessible()) wrap.code   = qtli.Product__r.SKU__c; if(Schema.sObjectType.Product2.isAccessible() && Schema.sObjectType.Product2.fields.Name.isAccessible() && Schema.sObjectType.Quote_Line_Items__c.isAccessible())wrap.product = qtli.Product__r.Name;if(Schema.sObjectType.Product2.isAccessible() && Schema.sObjectType.Product2.fields.Picture__c.isAccessible() && Schema.sObjectType.Quote_Line_Items__c.isAccessible())wrap.ImagePreview = qtli.Product__r.Picture__c;wrap.BasePrice = (qtli.Base_Price__c);wrap.Discount = (qtli.Discount_Amount__c);wrap.Tax = (qtli.Other_Tax__c);wrap.vat = (qtli.VAT_Amount__c); wrap.TotalPrice = (qtli.Total_Price__c);wrap.quantity = qtli.Quantity__c; QuoteLineItems.add(wrap);  } }subtotal = 0;discount = 0;  tax = 0;vat = 0;if(QuoteLineItems.size() >0) {for(LineItemWrapper l : QuoteLineItems) { if(l.BasePrice != null) subTotal += (l.BasePrice).setScale(2); if(l.Tax != null) tax += l.Tax.setScale(2); if(l.VAT != null) vat += l.VAT.setScale(2); if(l.Discount != null) discount += l.Discount.setScale(2);}}totalDue = (subTotal + tax + vat - Discount).setScale(2);imageURL='/servlet/servlet.FileDownload?file=';if(!Schema.sObjectType.Document.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));} else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];if(documentList.size() > 0) imageURL = imageURL + documentList[0].id;
            }  } catch(Exception e) { exceptionMethod(e, 'Constructor'); }
    }  
    
    /*
      Method for fetching quotation details
    */
    public Quotes__c getCurrentQuotations(String qID) {
        Quotes__c qt;
        try {
            if(!Schema.sObjectType.Quotes__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Quotes__c.Label));
            } else {
                if(qID != null) qt = Database.query('Select '+ String.escapeSingleQuotes(quoteFields) + ', Channel__r.Name From Quotes__c Where (Id = \'' + String.escapeSingleQuotes(qID) + '\')limit 1');
            }
            if(qt != null) {    
                if(!Schema.sObjectType.Address__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Address__c.Label));
                } else { billingAddress = Database.query('Select '+ String.escapeSingleQuotes(addressFields) + ' From Address__c Where (Id = \'' + String.escapeSingleQuotes(qt.Bill_To_Address__c) + '\')limit 1'); }}} catch(Exception e) { exceptionMethod(e, 'getCurrentQuotations'); }
        return qt;
    }
    
    /*
      Method for fetching quote line items
    */
    public List<Quote_Line_Items__c> getCurrentQuoteItemss(Id Ord){
        List<Quote_Line_Items__c> quoteItems;
        try {
            if(Ord != null) {  
                if(!Schema.sObjectType.Quote_Line_Items__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Quote_Line_Items__c.Label));
                } else { quoteItems = Database.query('Select '+ String.escapeSingleQuotes(quoteLineItemFields) + ', Product__r.Name, Product__r.Picture__c, Product__r.SKU__c, '+
                                      +' Quotes__r.Total_Due__c, Quotes__r.Name From Quote_Line_Items__c Where (Quotes__c = \'' + String.escapeSingleQuotes(Ord) + '\')');} }} catch(Exception e) { exceptionMethod(e, 'getCurrentQuoteItemss'); }
        return quoteItems;
    }         
    
    /*
      method for previewing the slip in PDF format
    */
    public PageReference viewQuote() {
        PageReference pdf;
        try {    
            pdf = ApexPages.currentPage();
            pdf.getParameters().put('val','pdf');                        
            pdf.setRedirect(true);} catch(Exception e) { exceptionMethod(e, 'viewQuote'); }
        return pdf;
    }
    
    /*
      Method for sending email for correspondin contact email
    */  
    public PageReference sendProposal() {
        try {
            if(toEmail_Address != Null && toEmail_Address != ''){
                errorMsg = ''; PageReference pdf =  ApexPages.currentPage();pdf.getParameters().put('pdf','true');Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();String [] toAddresses = toEmail_Address.split(',');email.setToAddresses(toAddresses);if(ccEmail_Addresses != null && ccEmail_Addresses != '') {String[] ccEmails = ccEmail_Addresses.split(',');email.setCcAddresses(ccEmails); }if(emailSubject != null && emailSubject != '') email.setSubject(emailSubject);else email.setSubject('Quotation proposal from' + orgDetails.Name);if(emailBody != null && emailBody != '') email.setPlainTextBody(emailBody);else email.setPlainTextBody('Hi '+currentContact.Name+',\n\nPlease find the attachment for Quotation from '+ orgDetails.Name +'. \nYour immediate attention to this Propsal is appreciated.\n\nThanks and Regards,\n' + orgDetails.Name + '.'); email.setBccSender(false);email.setUseSignature(false); email.setSenderDisplayName(orgDetails.Name);  email.setSaveAsActivity(false);   Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();if(currentQuote != null) attach.setFileName(currentQuote.Name+'.pdf'); Blob b = (Test.IsRunningTest()) ? Blob.valueOf('Test Purpose') : pdf.getContent();attach.setBody(b);email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                Attachment attachment = new Attachment(); if(Schema.sObjectType.Attachment.fields.Body.isCreateable()) attachment.Body = b; if(currentQuote != null && Schema.sObjectType.Attachment.fields.Name.isCreateable()) attachment.Name = String.valueOf(currentQuote.Name+'.pdf'); if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable()) attachment.ParentId = currentQuote.id;
                if(Schema.sObjectType.Attachment.isCreateable()){DMLManager.insertAsUser(attachment); } else{ errorMsg ='Not allowed to insert attachment';}  } else errorMsg = System.Label.QuotationPDF_NoContact;   } catch(Exception e) { exceptionMethod(e, 'sendProposal'); }
        return null;
    } 
    
    /*
      method for catching exception messages
    */
    public void exceptionMethod(Exception e, String methodName) {    
        exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();
    }
    
    /*
      wrapper class
    */
    public List<LineItemWrapper> QuoteLineItems   { get; set; }   
    public class LineItemWrapper{
        public String Code                        { get; set; }
        public String Product                     { get; set; }
        public Decimal BasePrice                  { get; set; }
        public String ImagePreview                { get; set; }
        public Decimal Discount                   { get; set; }
        public Decimal Tax                        { get; set; }
        public Decimal Vat                        { get; set; }
        public Decimal TotalPrice                 { get; set; }
        public Decimal quantity                   { get; set; }
        
        public LineItemWrapper(){
            code   = '';
            ImagePreview = '';
            product = '';
            BasePrice = 0;
            Discount = 0;
            Tax = 0;
            Vat = 0;
            TotalPrice = 0;
            quantity = 0;
        }
    }
}