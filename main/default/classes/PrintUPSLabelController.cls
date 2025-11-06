/*
 * LastModifiedBy - Arshad
 * Date - 26 Sep 2023
 * Reason - to manage return label dynamic for any carrier, also a ups return from fedex & fedex return from ups
 *
 */

 public with sharing class PrintUPSLabelController { 
    
    public String imageURL                                          { get; set; }    
    public String invoiceId                                         { get; set; }    
    public String labelName                                         { get; set; }    
    public String contactId                                         { get; set; }
    public String emailBody                                         { get; set; }
    public String shipmentId                                        { get; set; }
    public String EmailSubject                                      { get; set; }    
    public String toEmail_Address                                   { get; set; }
    public String shiptype                                          { get; set; }
    public Contact currentContact                                   { get; set; } 
    public Organization orgDetails                                  { get; set; }        
    public String ccEmail_Addresses                                 { get; set; }        
    public String templateHtmlBody                                  { get; set; }  
    public List<Attachment> attachList                    { get; set; }    
    public String templateEmailSubject                              { get; set; }  
    public EmailTemplate paidReturnTemplate                         { get; set; } 
    public List<Package_List__c> packListRecords                    { get; set; }
    public Map<Package__c, List<Package_List__c>> packageRecords    { get; set; }           
    public Boolean  showIframe                                     { get; set; }
    public String attIds                                                                                        { get; set; }
    public String shipRecordType                                          { get; set; }
    public PrintUPSLabelController() {
        try {
            attIds = '';
            shipRecordType = '';
            attachList = new List<Attachment>();        
            packageRecords = new Map<Package__c, List<Package_List__c>>();
            if(ApexPages.CurrentPage().getParameters().get('showframe') != null) showIframe =  Boolean.valueOf(ApexPages.CurrentPage().getParameters().get('showframe'));
            else showIframe = false;
            labelName =  ApexPages.CurrentPage().getParameters().get('fileName');
            contactId =  ApexPages.CurrentPage().getParameters().get('contactId');        
            shipmentId = ApexPages.CurrentPage().getParameters().get('shipmentsId'); 
            shiptype = ApexPages.CurrentPage().getParameters().get('shiptype'); 
            
            if(Schema.sObjectType.Organization.isAccessible()) orgDetails = [SELECT Id, Name FROM Organization WHERE Id =: UserInfo.getOrganizationId()];        
            if(Schema.sObjectType.Contact.isAccessible() && contactId != null) if(contactId != '') currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId, Phone, Contact_Numer__c, Company__c From Contact Where Id=:contactId Limit 1];
            if(currentContact != null){ if(currentContact.Id != null){ if(String.isNotEmpty(currentContact.Email)) toEmail_Address = currentContact.Email; } }
            if(labelName != null && labelName != ''){ EmailSubject = 'Shipment - '+labelName;  if(shiptype != null){ if(shiptype != ''){ EmailSubject = 'Shipment - Return Label'; } } } 
            
            emailBody = 'Hi,'+'\n'+'\n'+'Please find the attached Label for the shipment.'+'\n'+'\n'+'Thank you';
            if(shiptype != null){ if(shiptype != ''){  emailBody = 'Hi,'+'\n'+'\n'+'Please find the attached Label for the Return Shipment.'+'\n'+'\n'+'Thank you';  } } 
            
            if(shipmentId != null && labelName != null) { 
                shipRecordType = [Select Id, Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName from ERP7__Shipment__c Where Id =:shipmentId ].RecordType.Name;
                if(Schema.sObjectType.Attachment.isAccessible()) attachList = [select Id, Name, ParentId, ContentType from Attachment where parentId =: String.escapeSingleQuotes(shipmentId) And Name like: '%'+labelName+'%'];
                system.debug('attachList b4~>'+attachList.size());
                if(attachList.size() <= 0 && shiptype != null){
                    if(shiptype != ''){
                        system.debug('labelName before~>'+labelName);
                        if(labelName == 'UPS_Label') labelName = 'Fedex_Label';
                        else if(labelName == 'Fedex_Label') labelName = 'UPS_Label';
                        system.debug('labelName after~>'+labelName);
                        attachList = [select Id, Name, ParentId, ContentType from Attachment where parentId =: String.escapeSingleQuotes(shipmentId) And Name like: '%'+labelName+'%'];
                        system.debug('attachList after~>'+attachList.size());
                        system.debug('Daily Email Message Limit: ' + Limits.getLimitEmailInvocations());
                        system.debug('Remaining Daily Email Message Capacity: ' + (Limits.getLimitEmailInvocations() - Limits.getEmailInvocations()));

                    }
                }
                system.debug('attachList.size() : '+attachList.size());
                if(attachList.size() > 0 && showIframe){
                    for(Attachment att : attachList){
                        if(attIds == '') attIds += att.Id;
                        else attIds = attIds + ',' + att.Id;
                    } 
                }
                if(Schema.sObjectType.Package__c.isAccessible()) {
                    for(Package__c p : [select Name, Sales_Order__r.Ship_To_Address__r.Customer__r.Name, Sales_Order__r.Ship_To_Address__r.Address_Line1__c, Sales_Order__r.Ship_To_Address__r.Address_Line2__c,
                                       Sales_Order__r.Ship_To_Address__r.Address_Line3__c, Sales_Order__r.Ship_To_Address__r.City__c, Sales_Order__r.Ship_To_Address__r.County__c,
                                       Sales_Order__r.Ship_To_Address__r.Country__c, Sales_Order__r.Ship_To_Address__r.Contact__r.Phone, Sales_Order__r.Ship_To_Address__r.Contact__r.Fax,
                                       Sales_Order__r.Ship_To_Address__r.Contact__r.Name, Sales_Order__r.Ship_To_Address__r.Contact__r.Email, Sales_Order__r.Ship_To_Address__r.State__c,
                                       Sales_Order__r.Ship_To_Address__r.Postal_Code__c, Shipment__r.Invoice__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Sales_Order_Line_Item__c, 
                                       Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, 
                                       Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Total_Price__c, Package__r.Weight__c,
                                       Sales_Order_Line_Item__r.ReturnedQuantity__c,  Sales_Order_Line_Item__r.Name, SKU__c, Package_Weight__c,
                                       Sales_Order_Line_Item__r.Description__c From Package_Lists__r) from Package__c Where Shipment__c =: String.escapeSingleQuotes(shipmentId)
                                       And Active__c = true Order by CreatedDate Asc]) {
                     
                         packListRecords = new List<Package_List__c>();
                         for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); }
                         packageRecords.put(p,packListRecords);
                         invoiceId = p.Id;
                    }
                }
                
                system.debug('labelName~>'+labelName);
                system.debug('showIframe~>'+showIframe);
                system.debug('shipRecordType~>'+shipRecordType);
                
                if((labelName == 'Fedex_Label' || labelName == 'UPS_Label') && showIframe && String.isNotEmpty(shipRecordType) && shipRecordType.contains('UPS')){
                    system.debug('inhere showIframe set to false if UPS');
                    showIframe = false;
                }
            }
            imageURL = '/servlet/servlet.FileDownload?file=';
            List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
            if(documentList.size() > 0) imageURL = imageURL + documentList[0].id;            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); }
    }
    
    public void Email_Details(){        
        //try {
            /*To get Email Content Before Sending Email For Preview*/
            paidReturnTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: 'Paid_Return'];
            Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
            String [] toAddresses_test = new String[] {'test@test.com'}; 
            email_Attach.setToAddresses(toAddresses_test);
            email_Attach.setTemplateId(paidReturnTemplate.id);
            email_Attach.setSaveAsActivity(false);                     
            if(currentContact != null) {
                email_Attach.setTargetObjectId(currentContact.id);
                email_Attach.setWhatId(invoiceId);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
                templateEmailSubject = email_Attach.getSubject();
                templateHtmlBody = email_Attach.getHtmlBody();
                Database.rollback(sp); 
            }
        //} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); }
    }
    
    /*
      method for sending email for corresponding contact
    */
    public PageReference sendLabel() {
        try {
            if(toEmail_Address != Null && toEmail_Address != '') {
                PageReference pdf = page.PrintUPSLabel;
                pdf.getParameters().put('val','pdf');            
                PageReference pdf1 = page.ProcessReturn_PackageSlip;
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String [] toAddresses = toEmail_Address.split(','); 
                email.setToAddresses(toAddresses);            
                if(ccEmail_Addresses != null && ccEmail_Addresses != '') { String[] ccEmails = ccEmail_Addresses.split(','); email.setCcAddresses(ccEmails); }
                
                if(emailSubject != null && emailSubject != '') email.setSubject(emailSubject); 
                else email.setSubject(templateEmailSubject);                          
                
                if(emailBody != null && emailBody != '') email.setPlainTextBody(emailBody);
                else email.setHtmlBody(templateHtmlBody);
                   
                email.setBccSender(false);
                email.setUseSignature(false); 
                email.setSenderDisplayName(orgDetails.Name);  
                email.setSaveAsActivity(false);      
                
                //commented and added below code - Arshad 06 Dec 2023
                /*List<Messaging.Emailfileattachment> attachList = new List<Messaging.Emailfileattachment>();
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                String attFileName = '';
                if(String.isNotEmpty(labelName)) attFileName = labelName+'.pdf';
                if(String.isNotEmpty(attFileName)) attach.setFileName(attFileName); else attach.setFileName('Label.pdf'); 
                Blob b = (Test.IsRunningTest()) ? Blob.valueOf('Test Purpose') : pdf.getContentAsPDF();
                attach.setBody(b); 
                attachList.add(attach);
                */
              List<Messaging.Emailfileattachment> attachEmailList = new List<Messaging.Emailfileattachment>();
                if(showIframe == false){
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    String attFileName = '';
                    if(String.isNotEmpty(labelName)) attFileName = labelName+'.pdf';
                    if(String.isNotEmpty(attFileName)) attach.setFileName(attFileName); else attach.setFileName('Label.pdf'); 
                    Blob b = (Test.IsRunningTest()) ? Blob.valueOf('Test Purpose') : pdf.getContentAsPDF();
                    attach.setBody(b); 
                    attachEmailList.add(attach);
                }else if(showIframe){
                    List<Attachment> newAttachList = new List<Attachment>();
                    if(attachList.size() > 0) newAttachList = [Select Id, Name, ParentId, ContentType, Body from Attachment where Id IN: attachList];
                    
                    for(Attachment att : newAttachList){
                        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                        String attFileName = '';
                        if(String.isNotEmpty(labelName)) attFileName = labelName+'.pdf';
                        if(String.isNotEmpty(attFileName)) attach.setFileName(attFileName); else attach.setFileName('Label.pdf'); 
                        attach.setBody(att.Body); 
                        attachEmailList.add(attach);
                    }
                }
                email.setFileAttachments(attachEmailList);

                
                /*
                Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
                attach1.setFileName('Return_Packing_Slip.pdf'); 
                Blob b1 = (Test.IsRunningTest()) ? Blob.valueOf('Test Purpose') : pdf1.getContent(); 
                attach1.setBody(b1);
                attachList.add(attach1);
                */
                
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                if(r.get(0).isSuccess()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Email Sent Successfully'));
                else ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, r.get(0).getErrors()[0].getMessage()));                
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'To Email Address and Email Body is required.'));  
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber())); }         
        return null;            
    }
}