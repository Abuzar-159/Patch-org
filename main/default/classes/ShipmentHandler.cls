global with sharing class ShipmentHandler {
    
    public Boolean flag                             { get; set; }
    public String shipId; 
    public String errorMsg                          { get; set; }              
    public String retValue;
    public List<Id> packIds;    
    public String signatureURL                      { get; set; }
    public Shipment_Flow__c sf                      { get; set; }          
    public Shipment__c Shipment                     { get; set; } 
    Public Static String ShipRecId                  { get; set; } 
    public String addressFields                     { get; set; } 
    public String packageFields                     { get; set; }    
    public String shipmentFields                    { get; set; }              
    public Boolean signatureFlag                    { get; set; } 
    public Sales_Order__c toAddr                    { get; set; }
    public String recordTypeName                    { get; set; }          
    public String shipmentFlowId                    { get; set; }
    public String pickupRecTypeId                   { get; set; }
    public Address__c fromAddress                   { get; set; }      
    public String dropoffRecTypeId                  { get; set; }    
    public Sales_Order__c fromAddr                  { get; set; } 
    public String packageListFields                 { get; set; }       
    public String deliveryRecTypeId                 { get; set; }
    public String ShipmentRecTypeId                 { get; set; }    
    public List<Package__c> Packages                { get; set; }
    public String shipmentFlowFields                { get; set; } 
    public Address__c shippingAddress               { get; set; }
    public Map<String, String> recordIdMap          { get; set; }          
    public Map<Integer, Boolean> showAndHideMap     { get; set; } 
    public List<Shipment_Flow__c> existingFlows     { get; set; }
    
    public String errormsg2                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    
    /*
      Constructor.
    */
    public ShipmentHandler() {  
        try {
            addressFields = UtilClass.selectStarFromSObject('ERP7__Address__c');
            packageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
            shipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c'); 
            shipmentFlowFields = UtilClass.selectStarFromSObject('ERP7__Shipment_Flow__c');             
            flag = false;                         
            signatureFlag = false;
            packIds = new List<Id>();
            sf = new Shipment_Flow__c();
            Shipment = new Shipment__c();
            ShipRecId = '';
            toAddr = new Sales_Order__c();
            fromAddress = new Address__c();
            fromAddr = new Sales_Order__c(); 
            Packages = new List<Package__c>();
            shippingAddress = new Address__c();
            recordIdMap = new Map<String, String>();             
            showAndHideMap = new Map<Integer, Boolean>();
            existingFlows = new List<Shipment_Flow__c>();
            for(Integer i=1; i<=4; i++) { showAndHideMap.put(i, false); } 
             
             // fetching picklist default values from the object.
            Schema.DescribeFieldResult packType = Shipment__c.UPS_Package_Type__c.getDescribe();
            Shipment.UPS_Package_Type__c = String.valueof(packType.getDefaultValue());
            Schema.DescribeFieldResult unitCode = Shipment__c.Product_Unit_Code__c.getDescribe();
            Shipment.Product_Unit_Code__c = String.valueof(unitCode.getDefaultValue());
            Schema.DescribeFieldResult shipType = Shipment__c.Shipment_Type__c.getDescribe();
            Shipment.Shipment_Type__c = String.valueof(shipType.getDefaultValue());
             // fetching shipment flow record type ids.
            pickupRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment_Flow__c','Pickup');
            dropoffRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment_Flow__c','DropOff');
            deliveryRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment_Flow__c','Delivery');    
             // fetching shipment record type id.
            ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Shipping');          
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
    
    /*
      getter method definitions.
    */
    public List<Id> getpackIds() { return packIds; }
    public void setpackIds(List<Id> s) { if(s != null && s.size() > 0) { packIds = s; if(!flag) init(); } }    
    public String getshipId() { return shipId; }
    public void setshipId(String s) { if(s != null && s != '') { shipId = s; if(!flag) init(); } }    
    public String getretValue() { return retValue; }
    public void setretValue(String s) { retValue = s; } 
    public void fetchSignature() {
    
        List<Attachment> signImage;
        signatureURL='/servlet/servlet.FileDownload?file='; 
        if(shipment.Id != null) signImage = [select Id, parentId, Body, Name From Attachment where ParentId =: shipment.Id  And Name like '%Signature%' order by CreatedDate DESC];  
        if(signImage != null && signImage.size() > 0) { signatureURL += signImage[0].Id; signatureFlag = true; }                
    }
            
    /*
      Init method called after setting the package Id / shipment Id.
    */
    public void init() {
        try {
            if(packIds.size() > 0) {
                String bFilter, sFilter;
                Packages = new List<Package__c>();   
                //List<Package_Details__c> pkgs = [select Id, Name, Shipment_Description__c from Package_Details__c where Shipment_Description__c != null limit 1];
                //if(pkgs != null && pkgs.size() > 0) shipment.Description__c = pkgs[0].Shipment_Description__c;
                     
                for(Package__c p : Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Sales_Order__r.Organisation__c, Sales_Order__r.Organisation_Business_Unit__c, '+
                                   +' Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Work_Order__r.Organisation__c, Work_Order__r.Organisation_Business_Unit__c, Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, '+
                                   +' Purchase_Order__r.Organisation__c, Purchase_Order__r.Organisation_Business_Unit__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, Transfer_Order__r.To_Address__c, Transfer_Order__r.Organisation__c, Transfer_Order__r.Organisation_Business_Unit__c, '+
                                   +' Sales_Order__r.Id, Sales_Order__r.Contact__r.Email, Logistic__r.Sales_Order__c, Sales_Order__r.Contact__r.Phone, Sales_Order__r.Contact__r.Name, Sales_Order__r.Contact__r.Company__c, Work_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, '+
                                   +' Return_Merchandise_Authorisation__r.SO__r.Organisation__c, Return_Merchandise_Authorisation__r.SO__r.Organisation_Business_Unit__c, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, '+
                                   +' (select ' + packageListFields + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__SKU__c, ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.Name, '+
                                   +' ERP7__Work_Order_Line_Items__r.ERP7__Product__r.Name, ERP7__Purchase_Line_Items__r.ERP7__Product__r.Name, ERP7__Transfer_Order_Line_Item__r.ERP7__Products__r.Name, ERP7__RMA_Line_Item__r.ERP7__SOLI__r.ERP7__Product__r.Name, ERP7__Sales_Order_Line_Item__r.ERP7__Base_Price__c, Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Unit_Price__c, '+
                                   +' Purchase_Line_Items__r.Total_Price__c, Purchase_Line_Items__r.Unit_Price__c, RMA_Line_Item__r.Total_Deduction__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Price_Product__c '+
                                   +' From Package_Lists__r) from Package__c where Id In: packIds And Active__c = true')) {                                   
                    Packages.add(p);                 
                }  
                 // generating map of sobject record Ids to associate with shipment record
                if(Packages[0].Logistic__c != null) recordIdMap.put('LO', Packages[0].Logistic__c);
                else if(Packages[0].Sales_Order__c != null) recordIdMap.put('SO', Packages[0].Sales_Order__c);
                else if(Packages[0].Work_Order__c != null) recordIdMap.put('WO', Packages[0].Work_Order__c);
                else if(Packages[0].Purchase_Order__c != null) recordIdMap.put('PO', Packages[0].Purchase_Order__c);
                else if(Packages[0].Transfer_Order__c != null) recordIdMap.put('TO', Packages[0].Transfer_Order__c);
                else if(Packages[0].Return_Merchandise_Authorisation__c != null) recordIdMap.put('SR', Packages[0].Return_Merchandise_Authorisation__c);                   
                 // from address filter
                if(Packages[0].Logistic__r.From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Logistic__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Logistic__r.From_Address__c + '\''; }
                else if(Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c + '\''; }
                else if(Packages[0].Work_Order__r.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Work_Order__r.Billing_Address__c; bFilter = 'Id =\'' + Packages[0].Work_Order__r.Billing_Address__c + '\''; }
                else if(Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c + '\''; }
                else if(Packages[0].Transfer_Order__r.From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Transfer_Order__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Transfer_Order__r.From_Address__c + '\''; }
                else if(Packages[0].Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c + '\''; }
                 // to address filter  
                if(Packages[0].Logistic__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Logistic__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Logistic__r.To_Address__c + '\''; }
                else if(Packages[0].Sales_Order__r.Ship_To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Sales_Order__r.Ship_To_Address__c; sFilter = 'Id =\'' + Packages[0].Sales_Order__r.Ship_To_Address__c + '\''; }
                else if(Packages[0].Work_Order__r.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Work_Order__r.Shipping_Address__c; sFilter = 'Id =\'' + Packages[0].Work_Order__r.Shipping_Address__c + '\''; }
                else if(Packages[0].Purchase_Order__r.Vendor_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Purchase_Order__r.Vendor_Address__c; sFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Vendor_Address__c + '\''; }
                else if(Packages[0].Transfer_Order__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Transfer_Order__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Transfer_Order__r.To_Address__c + '\''; }
                else if(Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c; sFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c + '\''; }
                
                if(bFilter != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' , Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ String.escapeSingleQuotes(bFilter) +' Limit 1');
                if(sFilter != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ String.escapeSingleQuotes(sFilter) +' Limit 1');
                
                
                shipment.Description__c = '';
                if(Packages[0].PO_Reference__c != null && Packages[0].PO_Reference__c != '') shipment.Description__c += Packages[0].PO_Reference__c + ' ';
                if(Packages[0].Description__c != null && Packages[0].Description__c != '') shipment.Description__c += Packages[0].Description__c;
                
                for(Integer i=1; i<=4; i++) { showAndHideMap.put(i, false); } 
                
            } else if(shipId != null && shipId  != '') {
                Packages = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' ,  Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Sales_Order__r.Organisation__c, Sales_Order__r.Organisation_Business_Unit__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Invoice_Address__c, '+
                           +' Sales_Order__r.Id, Work_Order__r.Organisation__c, Work_Order__r.Organisation_Business_Unit__c, Transfer_Order__r.From_Address__c, Purchase_Order__r.Organisation__c, Purchase_Order__r.Organisation_Business_Unit__c, Transfer_Order__r.To_Address__c, Transfer_Order__r.Organisation__c, Transfer_Order__r.Organisation_Business_Unit__c, Sales_Order__r.Channel__c, Work_Order__r.Contact__r.Email, '+
                           +' Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Organisation__c, Return_Merchandise_Authorisation__r.SO__r.Organisation_Business_Unit__c, Sales_Order__r.Contact__r.Email, Sales_Order__r.Contact__r.Phone, Sales_Order__r.Contact__r.Name, Sales_Order__r.Contact__r.Company__c, '+
                           +' Purchase_Order__r.Vendor_Contact__r.Email, Logistic__r.Sales_Order__c, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email from Package__c where Shipment__c =\'' + String.escapeSingleQuotes(shipId) + '\' And Active__c = true');
                                    
                Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1');
                existingFlows = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Shipment__c =\'' + String.escapeSingleQuotes(shipId) + '\' Order By CreatedDate ASC');  

                if(Shipment.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Shipment.Billing_Address__c;
                    fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Billing_Address__c) + '\' Limit 1'); }
                if(Shipment.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Shipment.Shipping_Address__c;
                    shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Shipping_Address__c) + '\' Limit 1'); }           

                for(Integer i=1; i<=4; i++) { if(existingFlows.size() > 0 && i == 4) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
            } flag = true;            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }   
    
    /*
      method for getting from and to address upon change.
    */
    public PageReference fetchAddress() {
        try {
            if(toAddr.Ship_To_Address__c != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(toAddr.Ship_To_Address__c) + '\' Limit 1');  
            if(fromAddr.Bill_To_Address__c != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(fromAddr.Bill_To_Address__c) + '\' Limit 1');            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for returning back to respective flows (SO, WO, PO, TO, SR).
    */
    public PageReference back() { 
        pageReference pg = new pageReference('/apex/ERP7__OutboundLogistics'); 
        pg.setRedirect(true);
        /*if(retValue == 'SO') { pg = new pageReference('/apex/ERP7__Stockdispatching_SalesOrder'); pg.setRedirect(true); }
        else if(retValue == 'WO') { pg = new pageReference('/apex/ERP7__stockdispatching_WorkOrder'); pg.setRedirect(true); }
        else if(retValue == 'PO') { pg = new pageReference('/apex/ERP7__stockdispatching_PurchaseOrder'); pg.setRedirect(true); }
        else if(retValue == 'TO') { pg = new pageReference('/apex/ERP7__stockdispatching_TransferOrder'); pg.setRedirect(true); }
        else if(retValue == 'SR') { pg = new pageReference('/apex/ERP7__Stockdispatching_SalesReturn'); pg.setRedirect(true); }*/
        return pg;
    }
    
    /*
      method used for commiting the details of shipment, shipment flows, and packages to DB
    */
    public PageReference SaveDetails() {
        try {    
            if(Shipment != null) {
                if(Shipment.Name == null) { Shipment.Name.addError('Enter the value'); return null; } 
                else {                
                    if(Schema.sObjectType.Shipment__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Active__c.isUpdateable()) { Shipment.Active__c = true; }     else{ }                   
                    if(Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isUpdateable()) { Shipment.Billing_Address__c = shippingAddress.Id; }   else{ }                     
                    if(Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Shipment.Customer__c == Null){ Shipment.Customer__c = shippingAddress.Customer__c;  } else{ }
                    if(Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isUpdateable()) { Shipment.Customer_Contact__c = shippingAddress.Contact__c; } else{ }
                    if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipment.Status__c = 'Shipped'; }     else{ }                                                                   
                    if(Schema.sObjectType.Shipment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment__c.fields.RecordTypeId.isUpdateable()) { if(ShipmentRecTypeId != null) Shipment.RecordTypeId = ShipmentRecTypeId; } else{ }
                    if(Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isUpdateable()) { Shipment.Shipping_Address__c = shippingAddress.Id; }     else{ }                   
                    
                    if(recordIdMap.get('LO') != null) {
                        //if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'LO-Shipment' ;
                        if(Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable()) { Shipment.Logistic__c = recordIdMap.get('LO'); } else{ }
                        if(Packages[0] != null && Packages.size() > 0){ 
                            if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) { Shipment.Sales_Order__c = Packages[0].Logistic__r.Sales_Order__c;   } else{ }                          
                        }                            
                    
                    } else if(recordIdMap.get('SO') != null) {
                        if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) { Shipment.Name = 'SO-Shipment' ; } else{ }
                        if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) { Shipment.Sales_Order__c = recordIdMap.get('SO');  } else{ }                          
                    
                    } else if(recordIdMap.get('WO') != null) {
                        if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) { Shipment.Name = 'WO-Shipment' ; } 
                        if(Schema.sObjectType.Shipment__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isUpdateable()) { Shipment.Work_Order__c = recordIdMap.get('WO'); } else{ }
                    
                    } else if(recordIdMap.get('PO') != null) {
                        if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) { Shipment.Name = 'PO-Shipment' ; } 
                        if(Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isUpdateable()) { Shipment.Purchase_Orders__c = recordIdMap.get('PO'); } else{ }
                    
                    } else if(recordIdMap.get('TO') != null) {
                        if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) { Shipment.Name = 'TO-Shipment' ; } 
                        if(Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isUpdateable()) { Shipment.Transfer_Order__c = recordIdMap.get('TO'); }
                    
                    } else if(recordIdMap.get('SR') != null) {
                        if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) { Shipment.Name = 'SR-Shipment' ; } 
                        if(Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable()) { Shipment.Return_Merchandise_Authorisation__c = recordIdMap.get('SR'); } 
                    }
                    
                    if(Packages.size() > 0) {
                        if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) { Shipment.Sales_Order__c = Packages[0].Sales_Order__c; } else{ }
                    } 
                    if(Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable() && Schema.sObjectType.Shipment__c.fields.shipment_type__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.shipment_type__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.UPS_Package_Type__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.UPS_Package_Type__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Shipment; }   else{ /* no access*/}
                    
                    
                    id shipmentId = Shipment.Id;
                    Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where Active__c = true And Id=\'' + String.escapeSingleQuotes(shipmentId) + '\'  Limit 1');
                    
                    for(Package__c pac : Packages) {
                        pac.Shipment__c = Shipment.Id;
                        pac.Status__c = Shipment.Status__c;
                        pac.Tracking_Number__c = Shipment.Tracking_Number__c;
                    } 
                    
                    if(Packages.size() > 0) { 
                        if(Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable() && Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Packages; }
                    }
                    
                    // Adding below code to assign tracking number in sales order.
                    ERP7__Sales_Order__c SalesOrder = new ERP7__Sales_Order__c();
                    SalesOrder = Database.query('select Id, Name, ERP7__Tracking_Number__c from ERP7__Sales_Order__c where (Id =\'' + String.escapeSingleQuotes(Packages[0].Sales_Order__r.Id) + '\') Limit 1');
                    
                    if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isUpdateable()) { 
                        if(SalesOrder.ERP7__Tracking_Number__c == null || SalesOrder.ERP7__Tracking_Number__c == '') SalesOrder.ERP7__Tracking_Number__c = Shipment.Tracking_Number__c;
                        else SalesOrder.ERP7__Tracking_Number__c += ', ' + Shipment.Tracking_Number__c;
                    } if(Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; update SalesOrder; }
                    
                    // Additional code ends.
                    
                    
                    
                }
            } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method used for committing shipment flow to DB.
    */
    public PageReference saveShipmentFlows() {
        try {
            if(Shipment.Id != null) { 
                if(recordTypeName == 'Pickup') { 
                    //if(sf.Name == null) { sf.Name.addError('Enter the value.');  return null; }
                    //else { 
                        if(sf.Shipment__c == null) sf.Shipment__c = Shipment.Id; 
                        if(pickupRecTypeId != null) sf.RecordTypeId = pickupRecTypeId;
                    //}
                    
                } else if(recordTypeName == 'DropOff') { 
                    //if(sf.Name == null) { sf.Name.addError('Enter the value.');  return null; }
                    //else { 
                        if(sf.Shipment__c == null) sf.Shipment__c = Shipment.Id; 
                        if(dropoffRecTypeId != null) sf.RecordTypeId = dropoffRecTypeId;
                    //}
                     
                } else if(recordTypeName == 'Delivery') { 
                    if(sf.Name == null) { sf.Name.addError('Enter the value.'); 
                                          fetchSignature();
                                          return null;
                                
                    } else { if(sf.Shipment__c == null) sf.Shipment__c = Shipment.Id;  
                             if(deliveryRecTypeId != null) sf.RecordTypeId = deliveryRecTypeId;
                            if(Shipment.Received_By__c != null && Schema.sObjectType.Shipment__c.fields.Received_By__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Received_By__c.isUpdateable()) { upsert new Shipment__c(Id = Shipment.Id, Received_By__c = Shipment.Received_By__c); } else{ /* not allowed */}
                             fetchSignature(); 
                    }                                            
                } errorMsg = ''; 
                  if(sf != null && Schema.sObjectType.Shipment_Flow__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isUpdateable() && Schema.sObjectType.Shipment_Flow__c.fields.Time__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Time__c.isUpdateable()){hasAccess=true; upsert sf; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                  sf = new Shipment_Flow__c();
                  sf.Time__c = System.Now();                
                  existingFlows = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Shipment__c =\'' + String.escapeSingleQuotes(Shipment.Id) + '\' Order By CreatedDate ASC');
                  for(Integer i=1; i<=4; i++) { if(i==4) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }       
            } else errorMsg = 'Please save shipment details.';            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method used for adding multiple shipment flows to shipment.
    */
    public PageReference NewShipmentFlows() {
        try {             
            sf = new Shipment_Flow__c();            
            sf.Active__c = true;
            sf.Time__c = System.Now();
            ShipRecId = string.valueOf(Shipment.Id); 
                                          
            if(recordTypeName == 'Pickup') for(Integer i=1; i<=4; i++) { if(i==1) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
            else if(recordTypeName == 'DropOff') for(Integer i=1; i<=4; i++) { if(i==2) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); } 
            else if(recordTypeName == 'Delivery') { List<Shipment_Flow__c> sfDelivery;
                if(Shipment.Id != null) { sfDelivery = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Shipment__c =\'' + String.escapeSingleQuotes(Shipment.Id) + '\' And RecordTypeId =\'' + String.escapeSinglequotes(deliveryRecTypeId) + '\' Limit 1');
                                          if(sfDelivery != null && sfDelivery.size() > 0) sf = sfDelivery[0];
                                          fetchSignature();
                } for(Integer i=1; i<=4; i++) { if(i==3) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method used for editing the existing shipment flows from the shipment
    */
    public PageReference editShipmentFlow() {
        try {
            if(shipmentFlowId != null && recordTypeName == 'Pickup') {                
                sf = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Id =\'' + String.escapeSingleQuotes(shipmentFlowId) + '\'');
                for(Integer i=1; i<=4; i++) { if(i==1) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
                
            } else if(shipmentFlowId != null && recordTypeName == 'DropOff') {                 
                sf = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Id =\'' + String.escapeSingleQuotes(shipmentFlowId) + '\'');
                for(Integer i=1; i<=4; i++) { if(i==2) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
                    
            } else if(shipmentFlowId != null && recordTypeName == 'Delivery') {                
                sf = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Id =\'' + String.escapeSingleQuotes(shipmentFlowId) + '\'');
                fetchSignature();
                for(Integer i=1; i<=4; i++) { if(i==3) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method used for cancelling shipment flow.
    */
    public PageReference cancelShipmentFlow() {
        try {
            if(Shipment.Id != null) existingFlows = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Shipment__c =\'' + String.escapeSingleQuotes(Shipment.Id) + '\' Order By CreatedDate ASC');
            if(recordTypeName == 'Pickup' || recordTypeName == 'DropOff' || recordTypeName == 'Delivery') for(Integer i=1; i<=4; i++) { if(i==4) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }   
        
    /*
      method used for removing / deleting the existing shipment flows from the shipment
    */
    public PageReference deleteShipmentFlow() {
        try {
            if(shipmentFlowId != null && shipmentFlowId != ''){ if(Shipment_Flow__c.sObjectType.getDescribe().isDeletable()) { delete new Shipment_Flow__c(Id = shipmentFlowId);} else{ /* no access*/} } 
            existingFlows = Database.query('select ' + String.escapeSingleQuotes(shipmentFlowFields) + ' ,Shipping_point__r.Name, Loading_point__r.Name, RecordType.Name from Shipment_Flow__c where Shipment__c =\'' + String.escapeSingleQuotes(Shipment.Id) + '\' Order By CreatedDate ASC');
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return Null;
    }   
         
    @RemoteAction
    global static string captureSignature(String imageData, String recId, String name) { 
        try {                
            Attachment a = new Attachment(ParentId = recId, Body = EncodingUtil.base64Decode(imageData), ContentType = 'image/png', Name=name);        
            try { if(Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isCreateable() && Schema.sObjectType.Attachment.fields.ContentType.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isCreateable()) { DMLManager.insertAsUser(a);  return 'SUCCESS'; } else { return 'Not allowed to insert';}
                 
            } catch(DMLException ex) { return 'FAILURE'; }      
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
}