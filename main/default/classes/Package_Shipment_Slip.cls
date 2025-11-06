public with sharing class Package_Shipment_Slip {    
    
    public Date printDate                                     { get; set; }     
    public String emailSubject                                { get; set; }
    public String emailBody                                   { get; set; } 
    public String packageId                                   { get; set; }
    public String contactId                                   { get; set; }
    public String shipmentId                                  { get; set; }
    public String errorMsg                                    { get; set; }    
    public Package__c pack                                    { get; set; } 
    public String imageURL                                    { get; set; }
    public Shipment__c shipment                               { get; set; }
    public String exceptionMsg                                { get; set; } 
    public String packageFields                               { get; set; }
    public String shipmentFields                              { get; set; }
    public String packageListFields                           { get; set; }
    public String toEmail_Address                             { get; set; }
    public String ccEmail_Addresses                           { get; set; } 
    public Organization orgDetails                            { get; set; }   
    public List<Package__c> packageList                       { get; set; }    
    public List<Package_List__c> packList                     { get; set; }   
    
    /*
    Constructor
    */
    public Package_Shipment_Slip() {
        try {
            if(ApexPages.CurrentPage().getParameters().get('PackId')!= null) packageId = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('PackId'),'UTF-8');
            if(ApexPages.CurrentPage().getParameters().get('CustId')!= null) contactId = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('CustId'),'UTF-8');
            if(ApexPages.CurrentPage().getParameters().get('ShipId')!= null) shipmentId = EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('ShipId'),'UTF-8');            
            packageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
            UtilClass.FlSCheck(packageFields.split(',') ,'ERP7__Package__c');
            shipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c');  
            UtilClass.FlSCheck(shipmentFields.split(',') ,'ERP7__Shipment__c');
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');  
            UtilClass.FlSCheck(packageListFields.split(',') ,'ERP7__Package_List__c');
            
            printDate = System.Today();
            packageList = new List<Package__c>();
            packList = new List<Package_List__c>();
            
            imageURL = '/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));
            } else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
                if(documentList.size() > 0) imageURL = imageURL + documentList[0].id;
            }            
            //if(!Schema.sObjectType.Organization.isAccessible()) {//This was commented on 12/01/24 by Asra after getting confirmation from Imran and Moin
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Organization.Label));
            //} else { orgDetails = [SELECT Id, Name FROM Organization WHERE Id =: UserInfo.getOrganizationId()]; }
            
            // block executed when coming from Package object
            if(packageId != null && packageId != '') {
                if(!Schema.sObjectType.Package__c.isAccessible()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                } else {  utilClass.FLSCheck(packageFields.split(','),'ERP7__Package__c');
                    pack = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' ,Sales_Order__r.Ship_To_Address__r.Customer__r.Name, '+
                    +'Sales_Order__r.Ship_To_Address__r.Address_Line1__c, Sales_Order__r.Ship_To_Address__r.Address_Line2__c, '+
                    +'Sales_Order__r.Ship_To_Address__r.Address_Line3__c, Sales_Order__r.Ship_To_Address__r.City__c, '+
                    +'Sales_Order__r.Ship_To_Address__r.County__c, Sales_Order__r.Ship_To_Address__r.Country__c, '+
                    +'Sales_Order__r.Ship_To_Address__r.Contact__r.Phone, Sales_Order__r.Ship_To_Address__r.Contact__r.Fax, '+
                    +'Sales_Order__r.Ship_To_Address__r.Contact__r.Name, Sales_Order__r.Ship_To_Address__r.Contact__r.Email, '+
                    +'Sales_Order__r.Ship_To_Address__r.State__c, Sales_Order__r.Ship_To_Address__r.Postal_Code__c from Package__c where '+
                    +'Id =\'' + String.escapeSingleQuotes(packageId) + '\'');
                }
                if(pack.Sales_Order__r.Ship_To_Address__r.Contact__r.Email != null) { toEmail_Address = pack.Sales_Order__r.Ship_To_Address__r.Contact__r.Email; }
                
                if(!Schema.sObjectType.Package_List__c.isAccessible()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package_List__c.Label));
                } else { utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
                    packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Package__r.Name, Sales_Order_Line_Item__r.Sales_Order__r.Name, '+
                    +'Sales_Order_Line_Item__r.Name, Sales_Order_Line_Item__r.Description__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.IS_KIT__c, '+
                    +'Sales_Order_Line_Item__r.Sales_Order__r.Account__r.Name from Package_List__c where '+
                    +'Package__c =\'' + String.escapeSingleQuotes(packageId) + '\'');
                }
            }        
            
            // block executed when coming from Shipment object
            if(shipmentId != null && shipmentId != '') {
                if(!Schema.sObjectType.Shipment__c.isAccessible()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                } else { utilClass.FLSCheck(shipmentFields.split(','),'ERP7__Shipment__c');
                    shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' ,Shipping_Address__r.Customer__r.Name, Customer_Contact__r.Email, '+
                    +'Shipping_Address__r.Address_Line1__c, Shipping_Address__r.Address_Line2__c, '+
                    +'Shipping_Address__r.Address_Line3__c, Shipping_Address__r.City__c, '+
                    +'Shipping_Address__r.County__c, Shipping_Address__r.Country__c, Shipping_Address__r.State__c, '+
                    +'Shipping_Address__r.Postal_Code__c, Shipping_Address__r.Contact__r.Name, '+
                    +'Shipping_Address__r.Contact__r.Phone, Shipping_Address__r.Contact__r.Fax '+
                    +'from Shipment__c where Id=\'' + String.escapeSingleQuotes(shipmentId) + '\'');
                }
                if(shipment.Customer_Contact__r.Email != null) toEmail_Address = shipment.Customer_Contact__r.Email;
                
                if(!Schema.sObjectType.Package__c.isAccessible()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                } else { utilClass.FLSCheck(packageFields.split(','),'ERP7__Package__c');
                    packageList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' ,Sales_Order__r.Ship_To_Address__r.Customer__r.Name, '+
                    +'Sales_Order__r.Ship_To_Address__r.Address_Line1__c, Sales_Order__r.Ship_To_Address__r.Address_Line2__c, '+
                    +'Sales_Order__r.Ship_To_Address__r.Address_Line3__c, Sales_Order__r.Ship_To_Address__r.City__c, '+
                    +'Sales_Order__r.Ship_To_Address__r.County__c, Sales_Order__r.Ship_To_Address__r.Country__c, '+
                    +'Sales_Order__r.Ship_To_Address__r.Contact__r.Phone, Sales_Order__r.Ship_To_Address__r.Contact__r.Fax, '+
                    +'Sales_Order__r.Ship_To_Address__r.Contact__r.Name, Sales_Order__r.Ship_To_Address__r.Postal_Code__c from Package__c where '+
                    +'Shipment__c =\'' + String.escapeSingleQuotes(shipmentId) + '\'');
                }      
                List<Id> packageIds = new List<Id>();
                for(Package__c p: packageList) { packageIds.add(p.Id); }
                if(!Schema.sObjectType.Package_List__c.isAccessible()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package_List__c.Label));
                } else { utilClass.FLSCheck(packageFields.split(','),'ERP7__Package__c');
                    packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Package__r.Name, Sales_Order_Line_Item__r.Sales_Order__r.Name, Product_Bundle_Kit__r.Name, '+
                    +'Sales_Order_Line_Item__r.Name, Sales_Order_Line_Item__r.Description__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.IS_KIT__c '+
                    +'Sales_Order_Line_Item__r.Sales_Order__r.Customer__r.Name from Package_List__c where '+
                    +'Package__c In: packageIds Order By Package__c');
                }
            }
        } catch(Exception e) { exceptionMethod(e, 'Construtor'); }
    }
    
    /*
    method for previewing the slip in PDF format
    */
    public PageReference viewSlip() {
        PageReference pdf;
        try {    
            pdf = ApexPages.currentPage();
            pdf.getParameters().put('val','pdf');                        
            pdf.setRedirect(true);
        } catch(Exception e) { exceptionMethod(e, 'viewSlip'); }
        return pdf;
    }    
    
    /*
    method for sending email to corresponding contact with an attachment
    */
    public PageReference sendPackagingSlip() {
        try {        
            if(toEmail_Address != Null && toEmail_Address != '') {       
                errorMsg = '';
                PageReference pdf = ApexPages.currentPage();
                pdf.getParameters().put('pdf','true');                        
                
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();             
                String [] toAddresses = toEmail_Address.split(','); 
                email.setToAddresses(toAddresses);
                if(ccEmail_Addresses != null && ccEmail_Addresses != '') {
                    String[] ccEmails = ccEmail_Addresses.split(',');
                    email.setCcAddresses(ccEmails); 
                }
                if(emailSubject != null && emailSubject != '') email.setSubject(emailSubject);             
                else { if(packageId != null && packageId != '') email.setSubject('Packaging slip from' + orgDetails.Name);
                    else if(shipmentId != null && shipmentId != '') email.setSubject('Shipping slip from' + orgDetails.Name);
                }
                if(emailBody != null && emailBody != '') email.setPlainTextBody(emailBody);
                else {
                    if(packageId != null && packageId != '') {
                        email.setPlainTextBody('Hi ,\n\nPlease find the attachment for Package Slip from '+ orgDetails.Name +'. \nYour immediate attention to this slip is appreciated.\n\nThanks and Regards,\n ' + orgDetails.Name + '.');
                    } else if(shipmentId != null && shipmentId != '') {
                        email.setPlainTextBody('Hi ,\n\nPlease find the attachment for Shipping Slip from '+ orgDetails.Name +'. \nYour immediate attention to this slip is appreciated.\n\nThanks and Regards,\n ' + orgDetails.Name + '.');
                    }                                              
                }

                email.setBccSender(false);
                email.setUseSignature(false); 
                email.setSenderDisplayName(orgDetails.Name);  
                email.setSaveAsActivity(false);                     
                
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                if(packageId != null && packageId != '') attach.setFileName('PackageSlip.pdf'); 
                else if(shipmentId != null && shipmentId != '') attach.setFileName('ShipmentSlip.pdf'); 
                Blob b = (Test.IsRunningTest()) ?  Blob.valueOf('Test Purpose') : pdf.getContent();
                
                attach.setBody(b); 
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});                      
                
                // sending email to corresposding contact
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                
                Attachment attachment = new Attachment();                 
                attachment.Body = b; 
                attachment.Name = String.valueOf('PackageSlip.pdf'); 
                if(packageId != null && packageId != '') attachment.ParentId = packageId;
                else if(shipmentId != null && shipmentId != '') attachment.ParentId = shipmentId;                
                if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isCreateable()){ insert attachment; }else{/*Not allowed to insert attachment*/}
                
            } else errorMsg = System.Label.PackageSlip_ErrorMsg;
        } catch(Exception e) { exceptionMethod(e, 'sendPackagingSlip'); }
        return null;
    }
    
    /*
    method for catching exception messages
    */
    public void exceptionMethod(Exception e, String methodName) {    
        exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();
    }
}