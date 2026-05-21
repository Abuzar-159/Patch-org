global with sharing class OutboundLogisticsLCPages {
    public String imageURL                                             { get; set; }
    public PrintBarcodes PB                                            { get; set; }          
    public String errorMsg                                             { get; set; }
    public String loIds                                                { get; set; }
    public String pkIds                                                { get; set; }
    public String shIds                                                { get; set; }
    public List<ERP7__Logistic__c> Logistics                           { get; set; }
    public List< OutboundLogisticsLightning.Wrappers> soliWrapperList  { get; set; }
    public Map<Package__c, List<Package_List__c>> packageRecords       { get; set; }
    public EmailTemplate packingTemplate                               { get; set; }
    public EmailTemplate shippingTemplate                              { get; set; } 
     public EmailTemplate PickingTemplate{ get; set; }
    public Map<Shipment__c, List<Package_List__c>> shipmentRecords     { get; set; }  
   // public String sfdcBaseURL                                          { get; set; } 
    public Integer PackingSlipHeight                                   { get; set; } 
    
     
    global Contact currentContact                                  { get; set; }
    global Sobject Record                                          { get; set; }
    global EmailTemplate MailselectedTemplate                      { get; set; }
    global String sfdcBaseURL                                      { get; set; }
    global Boolean isHtmlEmail                                     { get; set; }
    global List<SetEmailTemplates__c> EmailTemplates_uniqueName    { get; set; }
    global String pdf                                              { get; set; }
    global String renderAs                                         { get; set; }
    global String dataStr                                          { get; set; }
   // global String Id                                               { get; set; }
    global Attachment Attachment                                   { get; set; }
    global String Id { 
        get{ return Id; } 
        set{ 
            try{ Id = ApexPages.CurrentPage().getParameters().get('loIds'); createPickingSlips();// comW = ManageProjects.getAll(Id); 
               } 
                catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        } 
    }
    public string PickSlipHtmlBody  {get;set;}    
    
    global OutboundLogisticsLCPages(ApexPages.StandardController controller){
        try {
            system.debug('OutboundLogisticsLCPages std contrl called');
            if(Id == Null) Id = ApexPages.currentPage().getParameters().get('loIds');
            renderAs = ApexPages.currentPage().getParameters().get('ra');
            dataStr = '';
            List<ERP7__Logistic__c> PJT =  [Select Id, Name, ERP7__Contact__c From ERP7__Logistic__c Where Id =: Id Limit 1];
            if(PJT.size() > 0) Record = PJT[0];
            currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId, Account.Organisation__c, Phone, Contact_Numer__c, Company__c From Contact Where Email != null Limit 1];
            Attachment = new Attachment();
            
            /* Fetching instance Name From SFDC URL */
            //sfdcBaseURL = URL.getSalesforceBaseUrl().getHost();
            //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
            //sfdcBaseURL = sfdcBaseURL.replace('--erp7', '--c');
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            
            system.debug('sfdcBaseURL 1~>'+sfdcBaseURL);
            
            // sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.content.force.com');   //need to uncommented
            String initurl = Label.initURL;
            system.debug('initurl~>'+initurl);
            
            String DestinationURL = Label.DestURL;
            system.debug('DestinationURL~>'+DestinationURL);
            
            //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('.visual.force.com');
            sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL); 
            
            system.debug('sfdcBaseURL 2~>'+sfdcBaseURL);
            
            // need to uncommented
            //  sfdcBaseURL = sfdcBaseURL.replace('.visualforce.com','.documentforce.com');
            sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            system.debug('sfdcBaseURL 3~>'+sfdcBaseURL);
            /* Querying The Template for Preview and attachment */
            if(PJT != null){
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c 
                                                From SetEmailTemplates__c 
                                                where Name = 'Picking_Slip'
                                                limit 1];
                if (EmailTemplates_uniqueName.isEmpty()) {  
                    EmailTemplates_uniqueName = new List < SetEmailTemplates__c > ();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null, Template_Unique_Name__c = 'Picking_Slip', TemplateAsAttachment__c = true,
                        Add_Template_As_Attachment__c = true, Html_Body__c = false));
                }
                List<Attachment> Attachments = [Select Id, Name, ParentId From Attachment Where ParentId =: Id And Name = 'PickingSlip' Order By CreatedDate Asc];
                if(Attachments.size() > 0) Attachment = Attachments[0];
            }
            if (EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c != null) {
                MailselectedTemplate = [select id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = : EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c]; 
                isHtmlEmail = EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Html_Body__c;
            } else { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'To SetUp  Email Template provide Unique Template Name or Contact your Administrator')); }
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); 
        }
        
    }
    
    global pageReference createPDF() {
        try {
            String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            PageReference pageRef = new PageReference('https://'+Label.Host_Path+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+Label.Template_Path+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?pageRef.getContentAsPdf():Blob.valueOf('Test'));
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        if(renderAs == 'pdf') return page.PickSlip;
        else return null;
    } 

    public OutboundLogisticsLCPages() {
         try {
             system.debug('OutboundLogisticsLCPages called');
             Logistics = new List<ERP7__Logistic__c>();
             soliWrapperList = new List< OutboundLogisticsLightning.Wrappers>();
             imageURL = '/servlet/servlet.FileDownload?file=';
             List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
             if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; 
             //sfdcBaseURL = URL.getSalesforceBaseUrl().getHost();
             //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
             //sfdcBaseURL = sfdcBaseURL.replace('erp7','c');
             sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
             system.debug('sfdcBaseURL 1~>'+sfdcBaseURL);
             
             String initurl = Label.initURL;
             String sendEmailBaseURL = Label.sendEmailBaseURL; 
             sfdcBaseURL = sfdcBaseURL.replace(initurl,sendEmailBaseURL);
             if(sfdcBaseURL.contains('--c')){
                 sfdcBaseURL = sfdcBaseURL.replace('--c','');
             }else if(sfdcBaseURL.contains('--erp7')){
                 sfdcBaseURL = sfdcBaseURL.replace('--erp7','');  
             }
             sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
             system.debug('sfdcBaseURL 3~>'+sfdcBaseURL);      
             
             loIds = '';
             if(ApexPages.CurrentPage().getParameters().get('loIds') != Null) loIds = ApexPages.CurrentPage().getParameters().get('loIds');
             system.debug('loIds~>'+loIds);
             pkIds = '';
             if(ApexPages.CurrentPage().getParameters().get('pkIds') != Null) pkIds = ApexPages.CurrentPage().getParameters().get('pkIds');
             
             shIds = '';
             if(ApexPages.CurrentPage().getParameters().get('shIds') != Null) shIds = ApexPages.CurrentPage().getParameters().get('shIds');
             
             packageRecords = new Map<Package__c, List<Package_List__c>>();
             PackingSlipHeight = 500;
         } catch(Exception e) {
             System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); 
         }
    }
    
    public PageReference createBarcodes() {
        try {          
            system.debug('createBarcodes called');
            String prodFields = UtilClass.selectStarFromSObject('Product2');
            //utilClass.FLSCheck(prodFields.split(','),'Product2');
            List<String> LogisticIds = loIds.split(',');
            errorMsg = '';
            Set<Id> pIds = new Set<Id>();
            OutboundLogisticsLightning.comWrap CW = OutboundLogisticsLightning.redirect2NextTab(JSON.Serialize(LogisticIds));
            system.debug('createBarcodes after redirect2NextTab~>'+CW.soliWrapperList.size());
            soliWrapperList = CW.soliWrapperList;
            Logistics = CW.LogisticRecs;
            if(soliWrapperList.size() > 0) {
                PB = new PrintBarcodes();
                PB.BarcodeWrapperList = new List<PrintBarcodes.BarcodeWrapper>();
                for(OutboundLogisticsLightning.Wrappers wrap : soliWrapperList) pIds.add(wrap.loli.Product__c);
                List<Product2> prods = [Select Id, Name, ProductCode, SKU__c, ASIN_Code__c, Colour__c, Item_Type__c, Weight__c, Weight_Dimensions__c, Description, Item_Description__c from Product2 where Id In: pIds]; //Database.query('select ' + String.escapeSingleQuotes(prodFields) +' from Product2 where Id In: pIds');    
                Map<Id, Product2> pMap = new Map<Id, Product2>();
                for(Product2 prod: prods) { pMap.put(prod.Id, prod); }
                for(OutboundLogisticsLightning.Wrappers wrap : soliWrapperList) {
                    PrintBarcodes.BarcodeWrapper BW;
                    if(PB.LabelField != Null && PB.LabelField != '') BW = new PrintBarcodes.BarcodeWrapper(wrap.LOLI.Product__r.Barcode__c, wrap.LOLI.Product__r.Name, wrap.LOLI.Product__r.Name);
                    else  BW = new PrintBarcodes.BarcodeWrapper(wrap.LOLI.Product__r.Barcode__c, '' , wrap.LOLI.Product__r.Name);
                    BW.products = pMap.get(wrap.LOLI.Product__c); PB.BarcodeWrapperList.add(BW);
                } 
                system.debug('createBarcodes PB.BarcodeWrapperList~>'+PB.BarcodeWrapperList.size());
            } else { system.debug('else here createBarcodes empty'); errorMsg = 'Items have been picked, please proceed to packing.'; }
        } catch(Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); 
        }        
        return Null;
    }
    
    public PageReference createPickingSlips() {
        try { 
            system.debug('createPickingSlips called');
            String Picklabelname = Label.Pick_Slip_Label;
            system.debug('Picklabelname~>'+Picklabelname);
            //String prodFields = UtilClass.selectStarFromSObject('Product2');
            //utilClass.FLSCheck(prodFields.split(','),'Product2');
            List<String> LogisticIds = loIds.split(',');
            errorMsg = '';
            Set<Id> pIds = new Set<Id>();
            OutboundLogisticsLightning.comWrap CW = OutboundLogisticsLightning.redirect2NextTab(JSON.Serialize(LogisticIds));
            system.debug('createPickingSlips after redirect2NextTab~>'+CW.soliWrapperList.size());
            soliWrapperList = CW.soliWrapperList;
            Logistics = CW.LogisticRecs;
            //if(soliWrapperList.size() > 0) {
            for(OutboundLogisticsLightning.Wrappers wrap : soliWrapperList) {
                for(OutboundLogisticsLightning.SelectOptions so : wrap.Address) if(so.value == wrap.AddressName) wrap.AddressName = so.label;
                for(OutboundLogisticsLightning.SelectOptions bl : wrap.BatchLotCodes) if(bl.value == wrap.BatchLotCode) wrap.BatchLotCode = bl.label;
            }             
            currentContact = [Select Id, Name, Email From Contact Where Email != null Limit 1];
            String contactId = [Select Id, Name, Email From Contact Where Email != Null Limit 1].Id;
            PickingTemplate = [select Id, Body, Subject, HtmlValue,IsActive from EmailTemplate where DeveloperName =: Picklabelname AND IsActive = true];            
            system.debug('PickingTemplate~>'+PickingTemplate.Id);
            Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
            String [] toAddresses_test = new String[] {'test@test.com'}; 
                email_Attach.setToAddresses(toAddresses_test);
            email_Attach.setTemplateId(PickingTemplate.Id);
            email_Attach.setSaveAsActivity(false);                     
            email_Attach.setTargetObjectId(contactId);
            if(LogisticIds.size() > 0) email_Attach.setWhatId(LogisticIds[0]); //email_Attach.setWhatId(newPackageId); //changed by arshad 02/02/23
            Savepoint sp = Database.setSavepoint();
            Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
            PickSlipHtmlBody = email_Attach.getHtmlBody();
            system.debug('PickSlipHtmlBody~>'+PickSlipHtmlBody);
            Database.rollback(sp);
        } catch(Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); 
        }        
        return null;
    }
    
    public PageReference createPackingLabels() {
        try {
            String contactId, newPackageId;
            List<String> pkgIds = pkIds.split(',');
           
            if(pkgIds.size() > 0) {
                for(Package__c p : [select Id, Name, Deposit_Tag__c, ERP7__Logistic__r.ERP7__Account__c, ERP7__Logistic__r.ERP7__Contact__c, ERP7__Logistic__r.ERP7__Sales_Order__r.Contact__c, Sales_Order__r.Ship_To_Address__r.Customer__r.Name, Sales_Order__r.Ship_To_Address__r.Address_Line1__c, Sales_Order__r.Ship_To_Address__r.Address_Line2__c, Sales_Order__r.Ship_To_Address__r.Address_Line3__c, Sales_Order__r.Ship_To_Address__r.City__c, Sales_Order__r.Ship_To_Address__r.County__c, ERP7__Logistic__r.Account__r.Name, ERP7__Logistic__r.ERP7__Contact__r.Name,
                                   ERP7__Logistic__r.ERP7__To_Address__r.Address_Line1__c, ERP7__Logistic__r.ERP7__To_Address__r.Address_Line2__c, ERP7__Logistic__r.ERP7__To_Address__r.Address_Line3__c, Sales_Order__r.Contact__c, Sales_Order__r.Ship_To_Address__r.Country__c, Sales_Order__r.Ship_To_Address__r.Contact__r.Phone, Sales_Order__r.Ship_To_Address__r.Contact__r.Fax, Sales_Order__r.Ship_To_Address__r.Contact__r.Name, Sales_Order__r.Ship_To_Address__r.Contact__r.Email, Sales_Order__r.Ship_To_Address__r.State__c,
                                   Sales_Order__r.Ship_To_Address__r.Postal_Code__c, ERP7__Logistic__r.ERP7__To_Address__r.City__c, ERP7__Logistic__r.ERP7__To_Address__r.State__c,ERP7__Logistic__r.ERP7__To_Address__r.Postal_Code__c,ERP7__Logistic__r.ERP7__To_Address__r.Country__c,ERP7__Logistic__r.ERP7__To_Address__r.Contact__r.Phone, Barcode__c, Name__c, Sales_Order__r.Account__r.Name, Owner.Name, CreatedDate, Weight__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Sales_Order_Line_Item__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Product__r.SKU__c, 
                                   Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Name, SKU__c, Package_Weight__c, ERP7__Logistic__r.ERP7__Contact__r.Email,
                                   Sales_Order_Line_Item__r.Description__c From ERP7__Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {
                     
                     List<Package_List__c> packListRecords = new List<Package_List__c>();
                     for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); }
                     
                     packageRecords.put(p,packListRecords);
                     contactId = [Select Id, Name, Email From Contact Where Email != Null Limit 1].Id;
                     newPackageId = p.Id;
                }
                
                // getting email content before creating a preview
                EmailTemplate packingTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: 'Packing_Label'];            
                Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
                String [] toAddresses_test = new String[] {'test@test.com'}; 
                email_Attach.setToAddresses(toAddresses_test);
                email_Attach.setTemplateId(packingTemplate.Id);
                email_Attach.setSaveAsActivity(false);                     
                email_Attach.setTargetObjectId(contactId);
                email_Attach.setWhatId(newPackageId);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
                Database.rollback(sp);
            }
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }    
        return null;
    }
    
    public PageReference createPackingSlips() {
        try {
            String contactId, newPackageId;
            String labelname = Label.Packing_slip_name;
            system.debug('labelname~>'+labelname);
            List<String> pkgIds = pkIds.split(',');
            
            if(pkgIds.size() > 0) {
                for(Package__c p : [select Id,Name,Deposit_Tag__c, ERP7__Logistic__r.ERP7__Account__c, ERP7__Logistic__r.ERP7__Contact__c, ERP7__Logistic__r.ERP7__Sales_Order__r.Contact__c, Sales_Order__r.Ship_To_Address__r.Customer__r.Name, Sales_Order__r.Ship_To_Address__r.Address_Line1__c, Sales_Order__r.Ship_To_Address__r.Address_Line2__c, Sales_Order__r.Ship_To_Address__r.Address_Line3__c, Sales_Order__r.Ship_To_Address__r.City__c, Sales_Order__r.Ship_To_Address__r.County__c, ERP7__Logistic__r.Account__r.Name, ERP7__Logistic__r.ERP7__Contact__r.Name,
                                   ERP7__Logistic__r.ERP7__To_Address__r.Address_Line1__c, ERP7__Logistic__r.ERP7__To_Address__r.Address_Line2__c, ERP7__Logistic__r.ERP7__To_Address__r.Address_Line3__c, Sales_Order__r.Contact__c, Sales_Order__r.Ship_To_Address__r.Country__c, Sales_Order__r.Ship_To_Address__r.Contact__r.Phone, Sales_Order__r.Ship_To_Address__r.Contact__r.Fax, Sales_Order__r.Ship_To_Address__r.Contact__r.Name, Sales_Order__r.Ship_To_Address__r.Contact__r.Email, Sales_Order__r.Ship_To_Address__r.State__c,
                                   Sales_Order__r.Ship_To_Address__r.Postal_Code__c, ERP7__Logistic__r.ERP7__To_Address__r.City__c, ERP7__Logistic__r.ERP7__To_Address__r.State__c,ERP7__Logistic__r.ERP7__To_Address__r.Postal_Code__c,ERP7__Logistic__r.ERP7__To_Address__r.Country__c,ERP7__Logistic__r.ERP7__To_Address__r.Contact__r.Phone, Barcode__c, Name__c, Sales_Order__r.Account__r.Name, Owner.Name, CreatedDate, Weight__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Sales_Order_Line_Item__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Product__r.SKU__c, 
                                   Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Name, SKU__c, Package_Weight__c, ERP7__Logistic__r.ERP7__Contact__r.Email,
                                   Sales_Order_Line_Item__r.Description__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {
                     
                     List<Package_List__c> packListRecords = new List<Package_List__c>();
                     for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); PackingSlipHeight += 100; }
                     
                     packageRecords.put(p,packListRecords);
                     contactId = [Select Id, Name, Email From Contact Where Email != Null Limit 1].Id;
                     newPackageId = p.Id;
                }
                // getting email content before creating a preview
                packingTemplate = [select Id, Body, Subject, HtmlValue , IsActive from EmailTemplate where DeveloperName =: labelname AND IsActive = true];            
                Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
                String [] toAddresses_test = new String[] {'test@test.com'}; 
                email_Attach.setToAddresses(toAddresses_test);
                email_Attach.setTemplateId(packingTemplate.Id);
                email_Attach.setSaveAsActivity(false);                     
                email_Attach.setTargetObjectId(contactId);
                email_Attach.setWhatId(newPackageId);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
                Database.rollback(sp);
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    public PageReference createShippingSlips() {
        try {
            String PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c'); 
            String packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
            String ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');
            String  shipslip = Label.Ship_slip_name;
            
            system.debug('shipslip~>'+shipslip);
            
            String contactId, newShipmentId;
            Set<Id> pkgIds = new Set<Id>();
            List<String> shipIds = shIds.split(',');   
            List<Shipment__c> shipList = new List<Shipment__c>();    
            shipmentRecords = new Map<Shipment__c, List<Package_List__c>>();            
             
            if(shipIds.size() > 0) {
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Id In: shipIds)'); 
                for(Package__c pk: Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where Shipment__c In: shipIds')) { pkgIds.add(pk.Id); }
                List<Package_List__c> packageItemList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Name, Sales_Order_Line_Item__r.Quantity__c, '+
                                                        +' Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.Description__c, Sales_Order_Line_Item__r.Shipping_Amount_Quantity__c, Sales_Order_Line_Item__r.Admin_Shipping_Amount__c, Package__r.Shipment__c, Package__r.Name from Package_List__c where Package__c In: pkgIds'); 
                for(Shipment__c sh: shipList) {   
                    List<Package_List__c> pkgItemList = new List<Package_List__c>();
                    Boolean adding = false;
                    for(Package_List__c pkl: packageItemList) { if(pkl.Package__r.Shipment__c == sh.Id) { pkgItemList.add(pkl); adding = true; } }
                    if(adding) shipmentRecords.put(sh, pkgItemList); 
                    newShipmentId = sh.Id; contactId = sh.Customer_Contact__c;
                }
                // getting email content before creating a preview
                shippingTemplate = [select Id, Body, Subject, HtmlValue,IsActive from EmailTemplate where DeveloperName =: shipslip AND IsActive = true];            
                Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
                String [] toAddresses_test = new String[] {'test@test.com'}; 
                email_Attach.setToAddresses(toAddresses_test);
                email_Attach.setTemplateId(shippingTemplate.Id);
                email_Attach.setSaveAsActivity(false);                      
                email_Attach.setTargetObjectId(contactId);
                email_Attach.setWhatId(newShipmentId);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
                Database.rollback(sp);   
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
}