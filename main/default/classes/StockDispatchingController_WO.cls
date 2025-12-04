public with sharing class StockDispatchingController_WO {

    public WO__c WO                                                      { get; set; }                       
    public String shipId                                                 { get; set; }    
    public String siteId                                                 { get; set; }               
    public String retValue                                               { get; set; }    
    public String imageURL                                               { get; set; }    
    public List<Id> woliIds                                              { get; set; }    
    public String WOFields                                               { get; set; }
    public String binFields                                              { get; set; }
    public String MRPFields                                              { get; set; }
    public String WOLIFields                                             { get; set; }    
    public String errorMsg                                               { get; set; }
    public String errorMsg1                                              { get; set; }
    public String errorMsg2                                              { get; set; }
    public String searchText                                             { get; set; }                 
    public Integer nextIdent                                             { get; set; }     
    public String packageId                                              { get; set; }
    public String shipmentId                                             { get; set; }
    public String prodFields                                             { get; set; }  
    public String STINLIFields                                           { get; set; }              
    public String shipmentDate                                           { get; set; }
    public String shipmentType                                           { get; set; }        
    public List<WO__c> woList                                            { get; set; }                
    public String siteFields                                             { get; set; }     
    public String SDLIFields                                             { get; set; }
    public Integer rowCounter                                            { get; set; }            
    public String workorderId                                            { get; set; }        
    public String orderNumber                                            { get; set; }
    public Boolean CreatePack                                            { get; set; }              
    public Boolean isAwaiting                                            { get; set; }
    public String pkgTypeValue                                           { get; set; }        
    public Map<Id, Id> stockMap                                          { get; set; }     
    public String pack2updateId                                          { get; set; }
    public Shipment__c uShipment                                         { get; set; }  
    public String channelFields                                          { get; set; }    
    public String PackageFields                                          { get; set; }
    public String ShipmentFields                                         { get; set; }    
    public static Integer addRow                                         { get; set; }       
    public String warehouseFields                                        { get; set; }
    public String POrecordTypeId                                         { get; set; }    
    public String locationsFields                                        { get; set; }
    public Map<Id, Id> dispatchMap                                       { get; set; }                                            
    public List<Id> selectedPackIds                                      { get; set; }
    public String packageListFields                                      { get; set; }
    public String ShipmentRecTypeId                                      { get; set; }
    public static Integer toDelIdent                                     { get; set; }                        
    public List<Location__c> SSLList                                     { get; set; }        
    public Package__c Package2Create                                     { get; set; }  
    public List<Package__c> Packages                                     { get; set; }
    public Boolean showUPSComponent                                      { get; set; }                
    public Boolean showFedExComponent                                    { get; set; }                
    public Map<Id, Package__c> packMap                                   { get; set; }
    public List<Shipment__c> Shipments                                   { get; set; }
    public List<Package__c> packageList                                  { get; set; }    
    public List<Package_List__c> packList                                { get; set; }
    public List<Shipment__c> shipmentList                                { get; set; }         
    public List<Inventory_Stock__c> WIISList                             { get; set; }       
    public String PackageCustomSettingFields                             { get; set; }
    public List<StorageContainer__c> binList                             { get; set; }                          
    public List<Package_List__c> packageLists                            { get; set; }      
    public List<Work_Order_Line_Items__c> Wolis                          { get; set; }         
    public Boolean showInternalShippingComponent                         { get; set; }
    public List<Purchase_Line_Items__c> poliList                         { get; set; }
    public List<Package_List__c> packListRecords                         { get; set; }
    public List<Work_Order_Line_Items__c> woliList                       { get; set; }  
    public List<packageWrapper> packageWrapperList                       { get; set; }     
    public List<lineItemWrapper> lineItemWrapperList                     { get; set; }
    public List<Stock_Outward_Line_Item__c> SDLIList                     { get; set; }    
    public List<Work_Order_Line_Items__c> currentItems                   { get; set; }     
    public List<Stock_Inward_Line_Item__c> spliItemList                  { get; set; }
    public List<Stock_Outward_Line_Item__c> sdliItemList                 { get; set; }    
    public Map<Id, List<Stock_Outward_Line_Item__c>> sdliMap             { get; set; }
    public List<Distribution_Channel__c> DistributionChannels            { get; set; }                     
    public Map<Package__c, List<Package_List__c>> packageRecords         { get; set; }       
    public Map<Shipment__c, List<Package_List__c>> shipmentRecords       { get; set; }            
    public String barcode                                                { get; set; }       
    Public Boolean scanned                                               { get; set; }          
    public String barcodeLoc                                             { get; set; }  
    public String sfdcBaseURL                                            { get; set; }
    public Boolean initialScan                                           { get; set; }
    public String barcodeLocMsg                                          { get; set; }    
    public EmailTemplate packingTemplate                                 { get; set; } 
    public EmailTemplate shippingTemplate                                { get; set; } 
    public PrintBarcodes PB                                              { get; set; }          
    
    public Employees__c Employee                                       { get; set; }
    public List<SelectOption> channelSites                             { get; set; }
    public Id selectedSite                                             { get; set; }
    public List<Stock_Outward_Line_Item__c> PPLIList2Delete            { get; set; }
    public Map<Id, List<Stock_Outward_Line_Item__c>> ppliMap           { get; set; }
    public String PPLIFields                                           { get; set; } 
    public List<Stock_Outward_Line_Item__c> ppliItemList               { get; set; } 
    public List<Stock_Outward_Line_Item__c> PPLIList                   { get; set; }
    public Boolean showSN                                              { get; set; } 
    public Boolean showBatch                                           { get; set; } 
    
    /*
      Constructor.
    */    
    public StockDispatchingController_WO() {
        try { 
            WOFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(WOFields.split(','),'ERP7__WO__c');
            siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c'); 
            utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c');             
            binFields = UtilClass.selectStarFromSObject('ERP7__StorageContainer__c');
            utilClass.FLSCheck(binFields.split(','),'ERP7__StorageContainer__c');
            MRPFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');   
            utilClass.FLSCheck(MRPFields.split(','),'ERP7__MRP__c');               
            PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');     
            ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c');    
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');                
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');    
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c'); 
            channelFields = UtilClass.selectStarFromSObject('ERP7__Distribution_Channel__c');    
            utilClass.FLSCheck(channelFields.split(','),'ERP7__Distribution_Channel__c');        
            SDLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
            utilClass.FLSCheck(SDLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c'); 
            locationsFields = UtilClass.selectStarFromSObject('ERP7__Location__c');    
            utilClass.FLSCheck(locationsFields.split(','),'ERP7__Location__c'); 
            PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c'); 
            warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');     
            utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c');          
            WOLIFields = UtilClass.selectStarFromSObject('ERP7__Work_Order_Line_Items__c');                  
            utilClass.FLSCheck(WOLIFields.split(','),'ERP7__Work_Order_Line_Items__c');          
            STINLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');                  
            utilClass.FLSCheck(STINLIFields.split(','),'ERP7__Stock_Inward_Line_Item__c');          
            prodFields = UtilClass.selectStarFromSObject('Product2');
            utilClass.FLSCheck(prodFields.split(','),'Product2'); 
            PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');         
            utilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');
            
            errorMsg = '';
            nextIdent = 0;  
            woliIds = new List<Id>();
            showUPSComponent = false; 
            showFedExComponent = false;                       
            woList = new List<WO__c>();        
            stockMap = new Map<Id, Id>();             
            dispatchMap = new Map<Id, Id>();
            Package2Create = new Package__c();
            SSLList = new List<Location__c>(); 
            showInternalShippingComponent = false;            
            WIISList = new List<Inventory_Stock__c>();
            binList = new List<StorageContainer__c>();
            wolisWrapperList = new List<newWrapper>();
            poliList = new List<Purchase_Line_Items__c>();
            woliList = new List<Work_Order_Line_Items__c>();
            SDLIList = new List<Stock_Outward_Line_Item__c>();
            spliItemList = new List<Stock_Inward_Line_Item__c>();
            sdliItemList = new List<Stock_Outward_Line_Item__c>();
            sdliMap = new Map<Id, List<Stock_Outward_Line_Item__c>>();
            ppliItemList = new List<Stock_Outward_Line_Item__c>(); 
            PPLIList = new List<Stock_Outward_Line_Item__c>();
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visual.force.com');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            showSN = false;
            showBatch = false;
                        
            imageURL = '/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));
            else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
                   if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; }
                              
            Employee = new Employees__c();
            List<Employees__c> empList = new List<Employees__c>();
            empList = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                         Organisation_Business_Unit__c
                         From Employees__c
                         Where Employee_User__c = : UserInfo.getUserId()
                         Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                Employee = empList[0]; 
                if(Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name
                                                                                    From Distribution_Channel__c
                                                                                    Where Channel__c = : Employee.Channel__c And Active__c = true
                                                                                    Order By ERP7__Primary__c Desc];
                
                    channelSites = new List<SelectOption>();        
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            channelSites.add(new SelectOption(DC.Site__c,DC.Site__r.Name));
                        }
                        selectedSite = DistributionChannels[0].Site__c;
                    } 
                } 
            } 
            
            allWorkOrders(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for displaying all completed work orders
    */   
    public void allWorkOrders() {
        try {
            Set<Id> woIds = new Set<Id>();
            woWrapperList = new List<Wrappers>();
            woliList = new List<Work_Order_Line_Items__c>();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>(); 
            String workorderId = ApexPages.currentPage().getParameters().get('woId'); 
            if(!Schema.sObjectType.WO__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.WO__c.Label));
            else {
                if(workorderId != Null && workorderId != '') {
                    woList = Database.query('select ' + String.escapeSingleQuotes(WOFields) + ' , WO_Supplier__r.Name from WO__c where (Id =\'' + String.escapeSingleQuotes(workorderId) + '\' And Is_Closed__c = false And Active__c = true) And ERP7__Ready_To_Pick_Pack__c = true Order by Expected_Date__c Asc Limit 1');                              
                } else woList = Database.query('select ' + String.escapeSingleQuotes(WOFields) + ' , WO_Supplier__r.Name from WO__c where (Is_Closed__c = false And Active__c = true And Total_Quantity__c > 0) And ERP7__Ready_To_Pick_Pack__c = true Order by Expected_Date__c Asc Limit 1000 ');
            } for(WO__c wos : woList) { woIds.add(wos.Id); }
            if(woIds.size() > 0) {
                if(!Schema.sObjectType.MRP__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.MRP__c.Label));
                else { woliList = Database.query('select ' + String.escapeSingleQuotes(WOLIFields) + ' from Work_Order_Line_Items__c where (Work_Orders__c In : woIds)');  }
                
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else { pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Work_Order__c In: woIds And Shipment__c = null)'); }
                
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Work_Order__c In: woIds)'); }
            }
            if(woList.size() > 0) {
                for(WO__c wos : woList) { Wrappers wrap = new Wrappers();                      
                    for(Work_Order_Line_Items__c woli : woliList) { if(woli.Work_Orders__c == wos.Id && woli.Picked_Quantity__c != woli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }
                    for(Package__c pkg : pkgList) { if(pkg.Work_Order__c == wos.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) { 
                        if(ship.Work_Order__c == wos.Id) { wrap.isAvailableShipments = true;
                                                           if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++; 
                                                           if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;             
                      wrap.WO = wos;
                      woWrapperList.add(wrap);
                } } else errorMsg = 'Sorry, no records available to view.';  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for searching WO's upon work order / supplier.
    */    
    public PageReference searchWOs() {
        try {
            woList = new List<WO__c>();
            Set<Id> woIds = new Set<Id>();
            woWrapperList = new List<Wrappers>();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>();
            if(!Schema.sObjectType.WO__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.WO__c.Label));
            else {  
                if(searchText != null && searchText != '') { String searchString = '%'+String.escapeSingleQuotes(searchText)+'%';
                    woList = Database.query('select ' + String.escapeSingleQuotes(WOFields) + ' , WO_Supplier__r.Name '+
                             +' from WO__c where (Active__c = true And (Is_Closed__c = false And Name like: searchString OR WO_Supplier__r.Name like: searchString) ) Limit 100');
                } else woList = Database.query('select ' + String.escapeSingleQuotes(WOFields) + ' , WO_Supplier__r.Name from WO__c where (Is_Closed__c = false And Active__c = true) Limit 100'); 
            } for(WO__c wos : woList) { woIds.add(wos.Id); }
            if(woIds.size() > 0) {
                if(!Schema.sObjectType.MRP__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.MRP__c.Label));
                else { woliList = Database.query('select ' + String.escapeSingleQuotes(WOLIFields) + ' from Work_Order_Line_Items__c where (Work_Orders__c In : woIds)'); }
                
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else { pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Work_Order__c In: woIds And Shipment__c = null)'); }
                
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Work_Order__c In: woIds)'); }
            }
            if(woList.size() > 0) {
                for(WO__c wos : woList) { Wrappers wrap = new Wrappers();                      
                    for(Work_Order_Line_Items__c woli : woliList) { if(woli.Work_Orders__c == wos.Id && woli.Picked_Quantity__c != woli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }
                    for(Package__c pkg : pkgList) { if(pkg.Work_Order__c == wos.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) { 
                        if(ship.Work_Order__c == wos.Id) { wrap.isAvailableShipments = true;
                                                           if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++; 
                                                           if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;           
                      wrap.WO = wos;
                      woWrapperList.add(wrap);
                } } else errorMsg = 'Sorry, no records available to view.';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating barcodes for selected WOLIs
    */
    public PageReference createBarcode() {
        try {                        
            Boolean error = false;
            woliIds = new List<Id>();
            PB = new PrintBarcodes();
            Set<Id> pIds = new Set<Id>();
            woliSelectedWrapperList = new List<Wrappers>();
            PB.BarcodeWrapperList = new List<PrintBarcodes.BarcodeWrapper>();           
            if(woliWrapperList.size() > 0) {
                for(Wrappers wrap : woliWrapperList) { if(wrap.woliSelected == true) { woliIds.add(wrap.woli.Id); pIds.add(wrap.woli.Product__c); woliSelectedWrapperList.add(wrap); } }
                if(woliSelectedWrapperList.size() > 0) { errorMsg = ''; List<Product2> prods = Database.query('select ' + String.escapeSingleQuotes(prodFields) +' from Product2 where Id In: pIds'); Map<Id, Product2> pMap = new Map<Id, Product2>();
                    for(Product2 prod: prods) { pMap.put(prod.Id, prod); }
                    for(Wrappers wrap : woliSelectedWrapperList) { PrintBarcodes.BarcodeWrapper BW; if(PB.LabelField != Null && PB.LabelField != '') BW = new PrintBarcodes.BarcodeWrapper(wrap.WOLI.Product__r.Barcode__c, wrap.WOLI.Product__r.Name, wrap.WOLI.Product__r.Name); else  BW = new PrintBarcodes.BarcodeWrapper(wrap.WOLI.Product__r.Barcode__c, '' , wrap.WOLI.Product__r.Name); BW.products = pMap.get(wrap.WOLI.Product__c); PB.BarcodeWrapperList.add(BW);
                    } 
                } else { errorMsg = 'Please select a line item to print barcode.'; } } else { errorMsg = 'Items have been picked, please proceed to packing.'; } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return Page.stockdispatching_WO_PrintPickProductsPDF;
    }
    
    /*
      method for redirecting for next tab.
    */
    public PageReference redirect2NextTab() {
        try {
            Boolean error = false;
            String supplierId = '';
            showSN = false;
            showBatch = false;
            Set<Id> woIds = new Set<Id>();
            Set<Id> orgIds = new Set<Id>();
            Set<Id> woliIds = new Set<Id>();
            Set<Id> proIds = new Set<Id>();
            Set<Id> assIds = new Set<Id>();
            barcodeLoc = barcodeLocMsg = ''; 
            SSLList = new List<Location__c>();           
            woliWrapperList = new List<Wrappers>();            
            WIISList = new List<Inventory_Stock__c>(); 
            binList = new List<StorageContainer__c>();
            PPLIList2Delete = new List<Stock_Outward_Line_Item__c>(); 
            
            if(woWrapperList.size() > 0) {
                woSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : woWrapperList) { 
                   if(sow.woSelected == true) { 
                        woIds.add(sow.WO.Id);
                        orgIds.add(sow.WO.Organisation__c);
                        if(sow.WO.WO_Supplier__c != Null) supplierId = sow.WO.WO_Supplier__c;
                        woSelectedWrapperList.add(sow);
                   }
                   if(workorderId == sow.WO.Id){ woSelectedWrapperList.add(sow); }
                }
            } else { for(Wrappers sow : woSelectedWrapperList) {if(sow.woSelected == true) { woIds.add(sow.WO.Id); orgIds.add(sow.WO.Organisation__c); if(sow.WO.WO_Supplier__c != Null) supplierId = sow.WO.WO_Supplier__c;
                    }
                } 
            } 
            //woWrapperList = new List<Wrappers>(); 
            
               
            if(workorderId != null && workorderId != '') woIds.add(workorderId);
            if(woIds.size() > 0) {
                for(Wrappers wrap : woSelectedWrapperList) {
                    if(supplierId !='' && supplierId != wrap.WO.WO_Supplier__c) { errorMsg = 'You cannot select orders with different supplier.'; error = true; break; }
                }
                if(!error) { 
                    errorMsg = '';
                    List<MRP__c> MRPS = new List<MRP__c>();
                    Map<Id, Product2> productMap = new Map<Id, Product2>();
                    Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>();
                    
                    woliList = Database.query('select ' + String.escapeSingleQuotes(woliFields) + ' , Work_Orders__r.Name, Product__r.Name, Product__r.Barcode__c, Product__r.Preview_Image__c, Product__r.Picture__c, Work_Orders__r.Organisation__c, Product__r.Item_Description__c, Product__r.Weight__c, Product__r.Special_Instructions__c, Product__r.ERP7__Is_Kit__c, Product__r.ERP7__Kit_Protected__c, Product__r.ERP7__Lot_Tracked__c, Product__r.Serialise__c, Asset__r.Name, Asset__r.Serialise__c, '+
                               +' Work_Orders__r.Organisation_Business_Unit__c from Work_Order_Line_Items__c where Work_Orders__c In : woIds And Ready_For_Dispatch__c = true order by Work_Orders__c ASC'); 
                    
                    for(Work_Order_Line_Items__c woli: woliList) { woliIds.add(woli.Id); if(woli.Product__c != Null) proIds.add(woli.Product__c); if(woli.Asset__c != Null) assIds.add(woli.Asset__c);
                    }
                    String mrpKit = 'MRP Kit';
                    MRPS = Database.query('select ' + String.escapeSingleQuotes(MRPFields) + ' ,ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Item_Description__c, MRP_Product__r.ERP7__Lot_Tracked__c from MRP__c where Work_Order__c In : woIds And Ready_For_Dispatch__c = true Limit 0');
                    
                    for(MRP__c mrp : MRPS){ if(mrp.ERP7__MRP_Product__c != Null) proIds.add(mrp.ERP7__MRP_Product__c);
                    }
                    
                    productMap = new Map<Id, Product2>([Select Id, Name, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]);
                    assetMap = new Map<Id, Asset__c>([Select Id, Name, Picture__c, Preview_Image__c, Status__c, Item_Description__c, Special_Instructions__c, Weight__c, Barcode__c From Asset__c Where Id In: assIds]);
                    
                    Set<Id> WIISIds = new Set<Id>(); 
                    for(ERP7__Stock_Outward_Line_Item__c ppli: Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ' from Stock_Outward_Line_Item__c where ERP7__Work_Order_Line_Items__c In: woliIds')) { WIISIds.add(ppli.Site_Product_Service_Inventory_Stock__c);
                    } 
                    
                    List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                           +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And ((Product__c In: proIds And Number_of_Item_In_Stock__c > 0) Or Fixed_Asset__c In: assIds) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 
                                                
                      
                    List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                    From ERP7__Stock_Inward_Line_Item__c
                                                                                    Where ERP7__Site_ProductService_InventoryStock__c In: WIISLists And
                                                                                    (ERP7__Product__c In :proIds Or
                                                                                    Fixed_Asset__c In: assIds) And
                                                                                    Active__c = True 
                                                                                    Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                     
                    Decimal myStock = 0;
                    Set<Id> warehouseIds = new Set<Id>();
                    Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();  
                    Map<Id,Id> bin2exclude = new Map<Id,Id>();
                    Map<Id,Id> loc2exclude = new Map<Id,Id>();
                    Map<Id,List<ERP7__Inventory_Stock__c>> productStocks = new Map<Id,List<ERP7__Inventory_Stock__c>>();
                    Map<Id,Set<SelectOption>> stockBatches = new Map<Id,Set<SelectOption>>();
                    
                    for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){if(InwardLine.ERP7__Material_Batch_Lot__c != Null){batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                            if(!stockBatches.containsKey(InwardLine.ERP7__Product__c)) { Set<SelectOption> myBatches = new Set<SelectOption>();
                                if(!InwardLine.ERP7__Product__r.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--')); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); stockBatches.put(InwardLine.ERP7__Product__c, myBatches);
                            }else{Set<SelectOption> myBatches = stockBatches.get(InwardLine.ERP7__Product__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); stockBatches.put(InwardLine.ERP7__Product__c, myBatches);
                            }
                            
                        }
                    }
                    
                    Map<Id, List<MRP__c>> woliMRPS = new Map<Id, List<MRP__c>>(); 
                    
                    for(Work_Order_Line_Items__c solis : woliList) { List<MRP__c> myMRPS = new List<MRP__c>(); for(MRP__c mrp : MRPS) { if(mrp.Work_Order_Line_Items__c == solis.Id){ myMRPS.add(mrp); }
                        } woliMRPS.put(solis.Id,myMRPS);
                    }
                    
                    for(Work_Order_Line_Items__c solis : woliList) {if(solis.Product__c != Null){ if(!(solis.Product__r.ERP7__Is_Kit__c && solis.Explode__c)){ Wrappers swrap = new Wrappers();  swrap.product = productMap.get(solis.Product__c); swrap.WOLI = solis; myStock = 0;
                                if(swrap.woli.Picked_Quantity__c != null) {  if(swrap.woli.Picked_Quantity__c == swrap.woli.Quantity__c) { swrap.raisedQty = Integer.valueof(swrap.woli.Picked_Quantity__c); swrap.remainingQty = Integer.valueof(swrap.woli.Quantity__c - swrap.raisedQty);
                                    } else if(swrap.woli.Picked_Quantity__c < swrap.woli.Quantity__c) { swrap.raisedQty = Integer.valueof(swrap.woli.Picked_Quantity__c); swrap.remainingQty = Integer.valueof(swrap.woli.Quantity__c - swrap.raisedQty); swrap.requiredQty = Integer.valueof(swrap.woli.Quantity__c - swrap.raisedQty);
                                    }} else { swrap.requiredQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? Integer.valueof(swrap.woli.Quantity__c) : 0;  swrap.remainingQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? Integer.valueof(swrap.woli.Quantity__c) : 0; 
                                }
                                Set<SelectOption> options1 = new Set <SelectOption>(); Set<SelectOption> options2 = new Set <SelectOption>();
                                Set<SelectOption> options3 = new Set <SelectOption>(); Set<SelectOption> address = new Set <SelectOption>(); 
                                for(ERP7__Inventory_Stock__c wiis: WIISLists) {
                                    if(wiis.Product__c == solis.Product__c) {
                                        if(wiis.StorageContainer__c != null) { swrap.binName = swrap.AddressName = wiis.StorageContainer__c; 
                                            if(wiis.StorageContainer__r.Name != null) options3.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));
                                            if(wiis.StorageContainer__r.Barcode__c != null) { address.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                            } } else if(wiis.Location__c != null) { swrap.LN = wiis.Location__r.Name; swrap.LocationName = swrap.AddressName  = wiis.Location__c;
                                            if(wiis.Location__r.Name != null) options2.add(new SelectOption(wiis.Location__c, wiis.Location__r.Name));
                                            if(wiis.Location__r.Barcode__c != null){address.add(new SelectOption(wiis.Location__c, wiis.Location__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                            } } else if(wiis.Warehouse__c != null) { swrap.WN = wiis.Warehouse__r.Name; swrap.WarehouseName = swrap.AddressName = wiis.Warehouse__c;
                                            if(wiis.Warehouse__r.Name != null) options1.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Name)); 
                                            if(wiis.Warehouse__r.Barcode__c != null){ address.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                            }
                                        }stockMap.put(wiis.Product__c, wiis.Id);
                                    }
                                } swrap.address.addAll(address); swrap.CurrentWarehouses.addAll(options1); 
                                swrap.CurrentLocations.addAll(options2); swrap.CurrentBins.addAll(options3); 
                                
                                swrap.inventoryStock = myStock;
                                
                                swrap.BatchLotCodes = new List <SelectOption>();   
                                if(stockBatches.ContainsKey(solis.Product__c)) swrap.BatchLotCodes.addAll(stockBatches.get(solis.Product__c)); 
                                if(swrap.BatchLotCodes.size() > 0 && solis.ERP7__Product__r.ERP7__Lot_Tracked__c == true){
                                    swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                                } else swrap.BatchLotCode = '';
                                if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);
                                
                                if(swrap.raisedQty != swrap.WOLI.Quantity__c) { if(swrap.WOLI.Product__r.Serialise__c){ if(swrap.requiredQty > 0) swrap.requiredQty = 1; swrap.serialized = true;
                                        showSN = true;  } if(swrap.BatchLotCodes.size() > 0) showBatch = true; woliWrapperList.add(swrap);
                                } } else { for(MRP__c mrp : woliMRPS.get(solis.Id)){
                                        Wrappers swrap_IN = new Wrappers(); swrap_IN.product = productMap.get(mrp.MRP_Product__c); swrap_IN.WOLI = solis; swrap_IN.MRP = mrp; myStock = 0;
                                        if(swrap_IN.mrp.Picked_Quantity__c != null) { 
                                            if(swrap_IN.mrp.Picked_Quantity__c == swrap_IN.mrp.Total_Amount_Required__c) { swrap_IN.raisedQty = Integer.valueof(swrap_IN.mrp.Picked_Quantity__c); swrap_IN.remainingQty = Integer.valueof(swrap_IN.mrp.Total_Amount_Required__c - swrap_IN.raisedQty);
                                            } else if(swrap_IN.mrp.Picked_Quantity__c < swrap_IN.mrp.Total_Amount_Required__c) {
                                                swrap_IN.raisedQty = Integer.valueof(swrap_IN.mrp.Picked_Quantity__c); swrap_IN.remainingQty = Integer.valueof(swrap_IN.mrp.Total_Amount_Required__c - swrap_IN.raisedQty); swrap_IN.requiredQty = Integer.valueof(swrap_IN.mrp.Total_Amount_Required__c - swrap_IN.raisedQty);
                                            }
                                        } else { swrap_IN.requiredQty = Integer.valueof(swrap_IN.mrp.Total_Amount_Required__c); swrap_IN.remainingQty = Integer.valueof(swrap_IN.mrp.Total_Amount_Required__c); 
                                        } Set<SelectOption> options1_IN = new Set <SelectOption>(); Set<SelectOption> options2_IN = new Set <SelectOption>();
                                        Set<SelectOption> options3_IN = new Set <SelectOption>();Set<SelectOption> address_IN = new Set <SelectOption>(); 
                                        for(ERP7__Inventory_Stock__c wiis: WIISLists) {
                                            if(wiis.Product__c == mrp.MRP_Product__c) {
                                                if(wiis.StorageContainer__c != null) { swrap_IN.binName = swrap_IN.AddressName = wiis.StorageContainer__c; 
                                                    if(wiis.StorageContainer__r.Name != null) options3_IN.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));
                                                    if(wiis.StorageContainer__r.Barcode__c != null) {   address_IN.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                    } } else if(wiis.Location__c != null) { swrap_IN.LN = wiis.Location__r.Name; swrap_IN.LocationName = swrap_IN.AddressName  = wiis.Location__c;
                                                    if(wiis.Location__r.Name != null) options2_IN.add(new SelectOption(wiis.Location__c, wiis.Location__r.Name));
                                                    if(wiis.Location__r.Barcode__c != null){ address_IN.add(new SelectOption(wiis.Location__c, wiis.Location__r.Barcode__c));  myStock += WIIS.Number_of_Item_In_Stock__c;
                                                    }  } else if(wiis.Warehouse__c != null) {
                                                    swrap_IN.WN = wiis.Warehouse__r.Name;  swrap_IN.WarehouseName = swrap_IN.AddressName = wiis.Warehouse__c;
                                                    if(wiis.Warehouse__r.Name != null) options1_IN.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Name)); 
                                                    if(wiis.Warehouse__r.Barcode__c != null){  address_IN.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                                    }
                                                }stockMap.put(wiis.Product__c, wiis.Id);
                                            }
                                        }swrap_IN.address.addAll(address_IN); swrap_IN.CurrentWarehouses.addAll(options1_IN); 
                                        swrap_IN.CurrentLocations.addAll(options2_IN);   swrap_IN.CurrentBins.addAll(options3_IN); 
                                        swrap_IN.inventoryStock = myStock;
                                         swrap_IN.BatchLotCodes = new List <SelectOption>();   if(stockBatches.ContainsKey(mrp.MRP_Product__c)) swrap_IN.BatchLotCodes.addAll(stockBatches.get(mrp.MRP_Product__c)); 
                                        if(swrap_IN.BatchLotCodes.size() > 0 && mrp.MRP_Product__r.ERP7__Lot_Tracked__c == true){swrap_IN.BatchLotCode = swrap_IN.BatchLotCodes[0].getValue(); swrap_IN.inventoryStock = batchAvailStocks.get(swrap_IN.BatchLotCodes[0].getValue());
                                        } else swrap_IN.BatchLotCode = ''; if(swrap_IN.requiredQty >= swrap_IN.inventoryStock) swrap_IN.requiredQty = Integer.valueof(swrap_IN.inventoryStock);
                                        
                                        if(swrap_IN.raisedQty != swrap_IN.mrp.Total_Amount_Required__c){
                                            if(swrap_IN.mrp.MRP_Product__r.Serialise__c){ if(swrap_IN.requiredQty > 0) swrap_IN.requiredQty = 1;  swrap_IN.serialized = true;  showSN = true;
                                            } if(swrap_IN.BatchLotCodes.size() > 0) showBatch = true; woliWrapperList.add(swrap_IN); //swrap.MRPsWrapperList.add(swrap_IN);
                                        }
                                    
                                    }
                                }
                            } else if(solis.Asset__c != Null && !(solis.Picked_Quantity__c > 0)){ Wrappers swrap = new Wrappers(); 
                                //swrap.product = productMap.get(solis.Product__c);
                                swrap.asset = assetMap.get(solis.Asset__c); swrap.WOLI = solis;  myStock = 0;
                                if(swrap.woli.Picked_Quantity__c != null) { 
                                    if(swrap.woli.Picked_Quantity__c == swrap.woli.Quantity__c) {
                                        swrap.raisedQty = Integer.valueof(swrap.woli.Picked_Quantity__c); swrap.remainingQty = Integer.valueof(swrap.woli.Quantity__c - swrap.raisedQty);
                                    } else if(swrap.woli.Picked_Quantity__c < swrap.woli.Quantity__c) {
                                        swrap.raisedQty = Integer.valueof(swrap.woli.Picked_Quantity__c);  swrap.remainingQty = Integer.valueof(swrap.woli.Quantity__c - swrap.raisedQty);    swrap.requiredQty = Integer.valueof(swrap.woli.Quantity__c - swrap.raisedQty);
                                    } } else { swrap.requiredQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? Integer.valueof(swrap.woli.Quantity__c) : 0;  swrap.remainingQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? Integer.valueof(swrap.woli.Quantity__c) : 0; 
                                }
                                Set<SelectOption> options1 = new Set <SelectOption>();  Set<SelectOption> options2 = new Set <SelectOption>();
                                Set<SelectOption> options3 = new Set <SelectOption>();  Set<SelectOption> address = new Set <SelectOption>(); 
                                for(ERP7__Inventory_Stock__c wiis: WIISLists) { if(wiis.Fixed_Asset__c == solis.Asset__c) {
                                        if(wiis.StorageContainer__c != null) { swrap.binName = swrap.AddressName = wiis.StorageContainer__c; 
                                            if(wiis.StorageContainer__r.Name != null) options3.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));
                                            if(wiis.StorageContainer__r.Barcode__c != null) {  address.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                            } } else if(wiis.Location__c != null) { swrap.LN = wiis.Location__r.Name; swrap.LocationName = swrap.AddressName  = wiis.Location__c;
                                            if(wiis.Location__r.Name != null) options2.add(new SelectOption(wiis.Location__c, wiis.Location__r.Name));
                                            if(wiis.Location__r.Barcode__c != null){address.add(new SelectOption(wiis.Location__c, wiis.Location__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                            }
                                        } else if(wiis.Warehouse__c != null) { swrap.WN = wiis.Warehouse__r.Name; swrap.WarehouseName = swrap.AddressName = wiis.Warehouse__c;
                                            if(wiis.Warehouse__r.Name != null) options1.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Name)); 
                                            if(wiis.Warehouse__r.Barcode__c != null){ address.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                            }
                                        }stockMap.put(wiis.Fixed_Asset__c, wiis.Id);
                                    }
                                }  swrap.address.addAll(address); swrap.CurrentWarehouses.addAll(options1); 
                                swrap.CurrentLocations.addAll(options2);     swrap.CurrentBins.addAll(options3); 
                                
                                 swrap.inventoryStock = myStock;
                                swrap.BatchLotCodes = new List <SelectOption>();   
                                if(stockBatches.ContainsKey(solis.Product__c)) swrap.BatchLotCodes.addAll(stockBatches.get(solis.Product__c)); 
                                if(swrap.BatchLotCodes.size() > 0 && solis.Asset__r.ERP7__Lot_Tracked__c == true){  swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                                } else swrap.BatchLotCode = '';  if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);
                                
                                if(swrap.raisedQty != swrap.WOLI.Quantity__c) {
                                    if(swrap.WOLI.Asset__r.Serialise__c){ if(swrap.requiredQty > 0) swrap.requiredQty = 1;
                                        swrap.serialized = true;  showSN = true;
                                    } if(swrap.BatchLotCodes.size() > 0) showBatch = true;  woliWrapperList.add(swrap);
                                }
                            }
                                              
                    }
                    return page.Stockdispatching_WO_Pick; 
                                        
                }  } else errorMsg = 'Please select an order to proceed.';  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
    method for fetching available inventory stocks upon selected address
    */
    public PageReference fetchBinStocks() {
        try {            
            List<Wrappers> woliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(rowCounter != null) woliWrap = new List<Wrappers>(); woliWrap.add(woliWrapperList.get(rowCounter));
            
            if(woliWrap != null) {
                if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
                else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(woliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
                else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(woliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
                else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(woliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(binList.size() > 0) {  if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where '+
                                      '(Storage_StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By CreatedDate ASC');                    
                    } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.Fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                    Decimal myStock = 0; 
                    
                    if(woliWrap.size() > 0) { Wrappers swrap = woliWrap[0];
                        List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                        for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                        }   
                        
                        Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                        Set<SelectOption> myBatches = new Set<SelectOption>(); if((!swrap.Product.ERP7__Lot_Tracked__c == true )) myBatches.add(new SelectOption('','--None--'));
                        
                        for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                            if(InwardLine.ERP7__Material_Batch_Lot__c != Null){batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                            }
                        } if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock); else swrap.requiredQty = Integer.valueof(swrap.woli.Quantity__c);
                           
                        swrap.inventoryStock = myStock; swrap.binName = swrap.addressName; swrap.locationName = binList[0].Location__c;
                        swrap.warehouseName = binList[0].Site__c;  swrap.WN = binList[0].Site__r.Name;  swrap.LN = binList[0].Location__r.Name;
                        
                        swrap.BatchLotCodes = new List<SelectOption>(); swrap.BatchLotCodes.addAll(myBatches);
                        if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                        } else swrap.BatchLotCode = '';
                        
                    }
                
                } else if(SSLList.size() > 0) { if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where '+
                                      '(Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By CreatedDate ASC');                    
                    } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.Fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                   
                    Decimal myStock = 0; 
                    
                    if(woliWrap.size() > 0) { Wrappers swrap = woliWrap[0];
                        List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                        for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                        }   
                        
                        
                        
                        Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>(); Set<SelectOption> myBatches = new Set<SelectOption>();
                        if((!swrap.Product.ERP7__Lot_Tracked__c == true )) myBatches.add(new SelectOption('','--None--'));
                        
                        for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                            if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                                batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                            }
                        }if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = Integer.valueof(swrap.woli.Quantity__c);
                         
                        swrap.inventoryStock = myStock; swrap.binName = null;
                        swrap.locationName = SSLList[0].Id; swrap.warehouseName = SSLList[0].Site__c;
                        swrap.WN = SSLList[0].Site__r.Name; swrap.LN = SSLList[0].Name;
                        
                        swrap.BatchLotCodes = new List<SelectOption>(); swrap.BatchLotCodes.addAll(myBatches);
                        if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                        }  else swrap.BatchLotCode = '';
                    }
                    
                } else if(siteList.size() > 0) {
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where '+
                                      '(Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By CreatedDate ASC');                                        
                    } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.Fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                    Decimal myStock = 0; 
                    
                    if(woliWrap.size() > 0) {
                        Wrappers swrap = woliWrap[0];
                        List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                            From ERP7__Stock_Inward_Line_Item__c
                                                                                            Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                            ERP7__Product__c = :swrap.Product.Id And
                                                                                            Active__c = True
                                                                                            Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                        for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                        }   
                        
                        
                        
                        Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                        Set<SelectOption> myBatches = new Set<SelectOption>();
                        if((!swrap.Product.ERP7__Lot_Tracked__c == true )) myBatches.add(new SelectOption('','--None--'));
                        
                        for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){if(InwardLine.ERP7__Material_Batch_Lot__c != Null){batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                            }
                        }
                        if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = Integer.valueof(swrap.woli.Quantity__c);
                        
                        swrap.inventoryStock = myStock;
                        swrap.binName = null;
                        swrap.locationName = null;
                        swrap.warehouseName = siteList[0].Id;
                        swrap.WN = siteList[0].Name; 
                        swrap.LN = '';
                        
                        swrap.BatchLotCodes = new List<SelectOption>();
                        swrap.BatchLotCodes.addAll(myBatches);
                        if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                        }
                        else swrap.BatchLotCode = '';
                    }
                }
            }    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    public PageReference fetchBatchStocks() {
        try {
            List<Wrappers> woliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(rowCounter != null) woliWrap = new List<Wrappers>(); woliWrap.add(woliWrapperList.get(rowCounter));
            if(woliWrap != null) {
                if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
                else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(woliWrap[0].addressName) + '\' And Active__c = true)'); }
                    
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
                else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(woliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
                else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(woliWrap[0].addressName) + '\' And Active__c = true)'); }
                          
                if(binList.size() > 0) {   if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                    Decimal myStock = 0;        
                    if(woliWrap.size() > 0) { Wrappers swrap = woliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                    From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) {  if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }   
                            
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);  myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                }
                            } if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            } else swrap.inventoryStock = myStock;
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);  else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                            
                    }
                    
                } else if(SSLList.size() > 0) {    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }

                    Decimal myStock = 0;        
                    if(woliWrap.size() > 0) { Wrappers swrap = woliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c 
                                                                                    From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            } Set<SelectOption> myBatches = new Set<SelectOption>(); Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                }
                            }
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            }else swrap.inventoryStock = myStock;
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);  else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                        
                    }
                    
                } else if(siteList.size() > 0) {if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }

                    Decimal myStock = 0;        
                    if(woliWrap.size() > 0) {Wrappers swrap = woliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c
                                                                                            From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                                }
                            }   
                            
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);   else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.woli.Quantity__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            } else swrap.inventoryStock = myStock;
                            
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock); else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                            
                            if(swrap.inventoryStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = swrap.inventoryStock+swrap.woli.Quantity__c-swrap.raisedQty;   else if(myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                            
                    }
                } 
            }  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating stock outward line item for selected WOLIs.
    */
    public PageReference savewolis() {
        try {
            Boolean error = false;
            Set<Id> woIds = new Set<Id>();
            woliIds = new List<Id>();
            List<Id> assetIds = new List<Id>();
            woliSelectedWrapperList = new List<Wrappers>();
            SDLIList = new List<Stock_OutWard_Line_Item__c>();  
            if(woliWrapperList.size() > 0) {
                for(Wrappers wrap : woliWrapperList) { if(wrap.woliSelected == true) { if(wrap.WOLI.Asset__c != Null){ assetIds.add(wrap.WOLI.Asset__c); } woIds.add(wrap.woli.Work_Orders__c); woliIds.add(wrap.woli.Id); woliSelectedWrapperList.add(wrap); } }
                if(woliSelectedWrapperList.size() > 0) { errorMsg = '';
                    for(Wrappers wrap : woliSelectedWrapperList) {
                        if(wrap.inventoryStock == 0) { errorMsg = 'Sorry, no available inventory for the selected item to proceed.'; error = true; break; }
                        else if(wrap.requiredQty > wrap.inventoryStock) { errorMsg = 'Quantity cannot be greater than available stock.'; error = true; break; } 
                        else if(wrap.requiredQty > wrap.remainingQty) { errorMsg = 'Quantity cannot be greater than remaining Quantity.'; error = true; break; }
                        else if(wrap.serialized && (wrap.SerialNumbers.Serial__c == '' || wrap.SerialNumbers.Serial__c == Null)) { errorMsg = 'Required field missing - Serial Number'; error = true; break; }
                    }
                    if(!error) { 
                        
                        if(woliIds.size() > 0) {
                            if(!Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Stock_Outward_Line_Item__c.Label));
                            else { ppliItemList = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ' from Stock_Outward_Line_Item__c where Work_Order_Line_Items__c In : woliIds and Picked_Date__c = null'); }
                        } 
                        MAP<Id, Work_Order_Line_Items__c> woliMap = new MAP<Id, Work_Order_Line_Items__c>(); 
                        MAP<Id, MRP__c> mrpMap = new MAP<Id, MRP__c>();
                        MAP<Id, Asset__c> assetMap = new MAP<Id, Asset__c>([Select Id, Name, Active__c, Barcode__c, Status__c From Asset__c Where Id In :assetIds]);
                                                                 
                        for(Wrappers wrap : woliSelectedWrapperList) {
                            for(Stock_Outward_Line_Item__c ppli: ppliItemList) {
                                if(wrap.WOLI.Product__c != Null){ 
                                    if(wrap.WOLI.Product__c == ppli.Product__c && wrap.WOLI.Id == ppli.Work_Order_Line_Items__c && ppli.Picked_Quantity__c == null) { 
                                        ppli.Quantity__c = ppli.Quantity__c - wrap.requiredQty; PPLIList.add(ppli);
                                        
                                        Stock_Outward_Line_Item__c sdlis = new Stock_Outward_Line_Item__c();
                                        
                                            // creating new stock outward line items
                                            if(wrap.woli.Name != null) sdlis.Name = 'STOLI-'+wrap.woli.Name; 
                                             if(stockMap.get(wrap.woli.Product__c) != null) sdlis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.woli.Product__c);
                                            if(wrap.woli.Product__c != null) sdlis.Product__c = wrap.woli.Product__c; if(wrap.requiredQty != null) sdlis.Quantity__c = wrap.requiredQty;
                                            if(wrap.requiredQty != null) sdlis.Picked_Quantity__c = wrap.requiredQty; if(wrap.woli.Work_Orders__c != null) sdlis.Work_Orders__c = wrap.woli.Work_Orders__c;
                                            sdlis.Work_Order_Line_Items__c = wrap.woli.Id; sdlis.Picked_Date__c = System.Now(); sdlis.Status__c = 'Committed'; sdlis.Active__c = true;  orderNumber = wrap.woli.Work_Orders__r.Name;
                                            
                                            if(wrap.SerialNumbers.Serial__c != null) sdlis.Serial__c = wrap.SerialNumbers.Serial__c; if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') sdlis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;   
                                            if(wrap.woli.Picked_Quantity__c == null) wrap.woli.Picked_Quantity__c = wrap.requiredQty; else wrap.woli.Picked_Quantity__c += wrap.requiredQty;
                                            woliMap.put(wrap.woli.Id, wrap.woli); PPLIList.add(sdlis); 
                                    }
                                }  
                                /*
                                else if((wrap.WOLI.Product__r.ERP7__Is_Kit__c && wrap.WOLI.Explode__c) && wrap.MRP.MRP_Product__c == ppli.Product__c && wrap.WOLI.Id == ppli.Work_Order_Line_Items__c && ppli.Picked_Quantity__c == null) { 
                                    ppli.Quantity__c = ppli.Quantity__c - wrap.requiredQty;                                                                                                                               
                                    PPLIList.add(ppli);
                                    
                                    Stock_Outward_Line_Item__c sdlis = new Stock_Outward_Line_Item__c();
                                    
                                        // creating new stock outward line items
                                        if(wrap.woli.Name != null) sdlis.Name = 'STOLI-'+wrap.woli.Name;
                                        if(wrap.woli.Work_Orders__r.Organisation__c != null) sdlis.Organisation__c = wrap.woli.Work_Orders__r.Organisation__c;
                                        if(wrap.woli.Work_Orders__r.Organisation_Business_Unit__c != null) sdlis.Organisation_Business_Unit__c = wrap.woli.Work_Orders__r.Organisation_Business_Unit__c; 
                                        if(stockMap.get(wrap.MRP.MRP_Product__c) != null) sdlis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.MRP.MRP_Product__c);
                                        if(ppli.Product__c != null) sdlis.Product__c = ppli.Product__c;
                                        if(wrap.requiredQty != null) sdlis.Quantity__c = wrap.requiredQty;
                                        if(wrap.requiredQty != null) sdlis.Picked_Quantity__c = wrap.requiredQty;
                                        if(wrap.woli.Work_Orders__c != null) sdlis.Work_Orders__c = wrap.woli.Work_Orders__c;
                                        sdlis.Work_Order_Line_Items__c = wrap.woli.Id;
                                        sdlis.Picked_Date__c = System.Now();
                                        sdlis.Status__c = 'Committed';
                                        sdlis.Active__c = true;             
                                        orderNumber = wrap.woli.Work_Orders__r.Name;
                                        
                                        if(wrap.MRP.Picked_Quantity__c == null) wrap.MRP.Picked_Quantity__c = wrap.requiredQty;
                                        else wrap.MRP.Picked_Quantity__c += wrap.requiredQty;
                                        mrpMap.put(wrap.mrp.Id, wrap.mrp);
                                        sdlis.MRP_Material_Requirements_Planning__c = wrap.MRP.Id;
                                    PPLIList.add(sdlis);
                                }
                                */
                            
                            else if(wrap.WOLI.Asset__c != Null){ if(wrap.WOLI.Asset__c == ppli.Fixed_Asset__c && wrap.WOLI.Id == ppli.Work_Order_Line_Items__c && ppli.Picked_Quantity__c == null) { 
                                    ppli.Quantity__c = ppli.Quantity__c - wrap.requiredQty; PPLIList.add(ppli);
                                    
                                    Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();  pplis.Name = 'STOLI-' + wrap.WOLI.Name;
                                        if(wrap.WOLI.Product__c != null) pplis.Fixed_Asset__c = ppli.Fixed_Asset__c; if(wrap.requiredQty != null) pplis.Quantity__c = wrap.requiredQty;
                                        if(wrap.requiredQty != null) pplis.Picked_Quantity__c = wrap.requiredQty; pplis.Picked_Date__c = System.Now();
                                        if(wrap.woli.Work_Orders__c != null) pplis.Work_Orders__c = wrap.woli.Work_Orders__c;
                                        pplis.Work_Order_Line_Items__c = wrap.woli.Id; pplis.Status__c = 'Committed'; pplis.Active__c = true; 
                                        if(wrap.SerialNumbers.Serial__c != null) pplis.Serial__c = wrap.SerialNumbers.Serial__c; if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;              
                                        
                                        if(stockMap.get(wrap.WOLI.Asset__c) != null) pplis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.WOLI.Asset__c); if(wrap.WOLI.Picked_Quantity__c == null) wrap.WOLI.Picked_Quantity__c = wrap.requiredQty; else wrap.WOLI.Picked_Quantity__c += wrap.requiredQty; WOLIMap.put(wrap.WOLI.Id, wrap.WOLI);
                                         PPLIList.add(pplis);
                                 }
                            }  
                          }                 
                        }
                        if(PPLIList.size() > 0) { if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Order_Line_Items__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()) { DMLManager.UpsertAsUser(PPLIList); } else{ /*  no access*/ }
                                                 if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Picked_Quantity__c.isUpdateable() && Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()){ upsert woliMap.Values();} else{ /* no access*/ } /*if(Schema.sObjectType.MRP__c.isCreateable() && Schema.sObjectType.MRP__c.isUpdateable()) { DMLManager.upsertAsUser(mrpMap.Values());} */ return redirect2NextTab();
                        }
                    }
                } else errorMsg = 'Please select a line item to save.';  } else errorMsg = 'Items have been picked, please proceed to packing.';  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    
    /*
      method for re-evaluating the package weight and declared value.
    */
    public PageReference evaluatePackDetails() {
        try {
            errorMsg2 = '';
            Package2Create.Weight__c = Package2Create.Declared_Value__c = 0;
            for(packageWrapper PW : packageWrapperList) {
                if(PW.woli.Product__r.Weight__c != null) Package2Create.Weight__c += (PW.woli.Product__r.Weight__c * PW.qtyToPack);
                if(PW.woli.Unit_Price__c != null) Package2Create.Declared_Value__c += (PW.woli.Unit_Price__c * PW.qtyToPack);                    
            } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
      
    /*
      method for pre-populating package details from custom settings.
    */
    public PageReference populatePackDetails() {
        try { 
            List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
            if(pkgTypeValue != null && pkgTypeValue != '--None--') {
                pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from ERP7__Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\') Limit 1'); 
                if(pkgDetailList.size() > 0) {
                    if(Schema.sobjectType.Package__c.fields.Length__c.isAccessible()) Package2Create.Length__c = pkgDetailList[pkgDetailList.size() - 1].Length__c;
                    if(Schema.sobjectType.Package__c.fields.Width__c.isAccessible()) Package2Create.Width__c = pkgDetailList[pkgDetailList.size() - 1].Width__c;            
                    if(Schema.sobjectType.Package__c.fields.Height__c.isAccessible()) Package2Create.Height__c = pkgDetailList[pkgDetailList.size() - 1].Height__c;
                    if(Schema.sobjectType.Package__c.fields.Weight_Unit__c.isAccessible()) Package2Create.Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].Weight_Unit__c;
                    //if(Schema.sobjectType.Package__c.fields.Shipment_Type__c.isAccessible()) Package2Create.Shipment_Type__c = 'UPS';            
                }  } else errorMsg2 = 'Sorry, selected package type not available.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating a new package / displaying the existing created packages
    */
    public PageReference createPacks() {
        try {
            Set<Id> woIds = new Set<Id>();
            // multiple SO to create package
            
            if(woWrapperList.size() > 0) {
                woSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : woWrapperList) { 
                   if(sow.woSelected == true) { 
                        woIds.add(sow.WO.Id);
                        woSelectedWrapperList.add(sow);
                        if(workorderId == sow.WO.Id) workorderId = Null;
                   }
                   if(workorderId == sow.WO.Id){ woSelectedWrapperList.add(sow); woIds.add(sow.WO.Id); }
                }
            } else { for(Wrappers sow : woSelectedWrapperList) { if(sow.woSelected == true) { woIds.add(sow.WO.Id);
                    }
                } 
            } 
            
            
            
            
            if(woIds.size() > 0) {
                woliWrapperList = new List<Wrappers>();
                woliList = new List<Work_Order_Line_Items__c>();
                woliList = Database.query('select ' + String.escapeSingleQuotes(woliFields) + ' ,Work_Orders__r.Name, Product__r.Name, Product__r.Weight__c, Work_Orders__r.WO_Supplier__r.Name, ERP7__Asset__r.Name from Work_Order_Line_Items__c where (Work_Orders__c In : woIds) order by Work_Orders__c ASC');
                for(Work_Order_Line_Items__c wolis : woliList) {
                    if(wolis.Packed_Quantity__c != wolis.Picked_Quantity__c && wolis.Picked_Quantity__c <= wolis.Quantity__c) {
                        Wrappers swrap = new Wrappers(); 
                        swrap.woli = wolis;
                        swrap.isSOLIawaiting = true;
                        orderNumber = wolis.WOrk_Orders__r.Name;
                        woliWrapperList.add(swrap);
                    }
                }
                Packages = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Work_Order__r.Name, Work_Order__r.WO_Supplier__r.Name, Shipment__r.Name, Shipment__r.Shipment_Date__c, Shipment__r.Status__c from Package__c '+
                           +' where (Active__c = true And Work_Order__c In: woIds) Order by Shipment__r.Name, CreatedDate Asc');                       
                packMap = new Map <Id, Package__c>(Packages); 
                
                if(Packages.size() > 0 && woliWrapperList.size() > 0) { createPack = true; isAwaiting = true; }  else if(Packages.size() > 0) { createPack = false; isAwaiting = true; }   else if(woliWrapperList.size() > 0) { createPack = true; isAwaiting = false; }
                
                Set<Id> pkgIds = new Set<Id>();
                if(Packages.size() > 0) { for(Package__c pack: Packages) { pkgIds.add(pack.Id); } }       
                ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');
                Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where'+
                            '(Package__c In: pkgIds And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');
                
                packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c In: pkgIds And Active__c = true) Order by CreatedDate Asc');
                
                //*****************************************************************            
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { lineItemWrapper LW = new lineItemWrapper(); LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm';
                        else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }
                
                // ****************************************************************            
                    Package2Create = new Package__c(); 
                    if(woIds.size() > 0) Package2Create.Work_Order__c = (new list<Id>(woIds))[0];                                
                    Package2Create.Weight__c = 0;
                    Package2Create.Declared_Value__c = 0;                            
                    packageWrapperList = new List<packageWrapper>();
                    Package2Create.Status__c = 'Deposited To Front Desk';
                    if(Packages != null) Package2Create.Name = Package2Create.Barcode__c = Package2Create.Description__c = Package2Create.Name__c = 'WO-Package-'+ Integer.valueof(Packages.size()+1);
                    for(Wrappers wrap : woliWrapperList) { 
                        if(wrap.isSOLIawaiting == true) { packageWrapper PW = new packageWrapper();                            
                            PW.pkgSelected = true;
                            PW.woli = wrap.woli;
                            PW.qtyToPick = wrap.woli.Picked_Quantity__c;
                            if(wrap.woli.Picked_Quantity__c != null && wrap.woli.Packed_Quantity__c != null) PW.qtyToPack = wrap.woli.Picked_Quantity__c - wrap.woli.Packed_Quantity__c;
                            else PW.qtyToPack = wrap.woli.Picked_Quantity__c;
                            
                            if(PW.woli.Product__r.Weight__c != null) Package2Create.Weight__c += (PW.woli.Product__r.Weight__c * PW.qtyToPack);

                            if(PW.woli.Unit_Price__c != null) Package2Create.Declared_Value__c += (PW.woli.Unit_Price__c * PW.qtyToPack);
                            
                            if(PW.qtyToPack != 0) packageWrapperList.add(PW);
                        }
                    } return Page.stockdispatching_WO_Package;    } else errorMsg = 'Please select an order to proceed.';  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for updating the details of created packages and package list
    */
    public PageReference editPackage() {
        try {
            Set<Id> woIds = new Set<Id>();
            Packages = new List<Package__c>();
            currentItems = new List<Work_Order_Line_Items__c>(); 
            if(pack2updateId != null) {
                Package2Create = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Work_Order__r.WO_Supplier__c, Shipment__r.Name from Package__c where (Id =\'' + String.escapeSingleQuotes(pack2updateId) + '\')');  
                packMap = new Map <Id, Package__c>(Packages);
                                                                      
                currentItems = Database.query('select ' + String.escapeSingleQuotes(woliFields) + ' ,Work_Orders__r.Name, Work_Orders__r.WO_Supplier__r.Name, Product__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c, ERP7__Asset__r.Name from Work_Order_Line_Items__c '+
                               +'where (Work_Orders__c =\'' + String.escapeSingleQuotes(Package2Create.Work_Order__c) + '\') order by Work_Orders__c ASC');                       
                    
                packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(Package2Create.Id) + '\' And Active__c = true) Order by CreatedDate Asc');
                
                //*****************************************************************            
                    if(Package2Create != null) Packages.add(Package2Create);
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { lineItemWrapper LW = new lineItemWrapper(); LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm';
                        else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }        
                
                // ****************************************************************            
                    packageWrapperList = new List<packageWrapper>();                                
                    for(Work_Order_Line_Items__c woli : currentItems){
                        packageWrapper PW = new packageWrapper();
                        List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                        for(Package_List__c pl : packageLists){
                           if(pl.Work_Orders__c == woli.Work_Orders__c) { PW.woli = woli;
                                PW.qtyToPick = pl.Quantity__c;
                                PW.qtyToPack = pl.Quantity__c;                                
                                innerPackageWrapper ipw = new innerPackageWrapper();
                                ipw.pack = String.valueof(pl.Package__c);
                                ipw.packege = packMap.get(pl.Package__c);
                                ipw.packageList = pl;
                               
                                for(Package__c P : Packages){
                                    if((P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') && (ipw.packege.Status__c != 'Shipped' && ipw.packege.Status__c != 'Picked Up' && ipw.packege.Status__c != 'Delivered'))
                                    ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c));  
                                } ipwList.add(ipw);
                            }
                        } 
                        if(ipwList.size() > 0) { PW.innerPackList = ipwList; packageWrapperList.add(PW); }
                    } CreatePack = true; isAwaiting = false;    
            }  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for deleting created packages.
    */
    public PageReference deletePackage() {
        try {
            Set<Id> woliIds = new Set<Id>();
            MAP<Id, Work_Order_Line_Items__c> woliMap = new MAP<Id, Work_Order_Line_Items__c>();
            if(pack2updateId != null) {
                List<Package_List__c> packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Work_Order_Line_Items__r.Packed_Quantity__c from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack2updateId) + '\' And Active__c = true) Order by CreatedDate Asc');
                for(Package_List__c pls: packList) { woliIds.add(pls.Work_Order_Line_Items__c); }
                List<Work_Order_Line_Items__c> woliList = Database.query('select ' + String.escapeSingleQuotes(WOLIFields) + ' from Work_Order_Line_Items__c where Id In: woliIds'); 
                for(Package_List__c pl: packList) {
                    for(Work_Order_Line_Items__c wolis: woliList) {
                        if(pl.Work_Order_Line_Items__c == wolis.Id) {
                            if(wolis.Packed_Quantity__c != null) {
                                wolis.Packed_Quantity__c = wolis.Packed_Quantity__c - pl.Quantity__c;
                                woliMap.put(wolis.Id, wolis);
                            } break;
                        }
                    }
                }
            }
            if(woliMap.size() > 0) { if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Packed_Quantity__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Packed_Quantity__c.isUpdateable() && Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) { upsert woliMap.values();} else{ /*no access*/ } } 
            if(pack2updateId != null && Package__c.sObjectType.getDescribe().isDeletable()) { delete new Package__c(Id = pack2updateId);  } else{ /* no access*/ }           
            createPacks();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for updating package details.
    */
    public PageReference updatePacks() {
        try {
            Boolean error = false; 
            if(packageWrapperList != null) {
                List<Package_List__c> PLS = new List<Package_List__c>();
                MAP<Id, Work_Order_Line_Items__c> woliMap = new MAP<Id, Work_Order_Line_Items__c>();
                for(packageWrapper pw: packageWrapperList) {
                    if(pw.qtyToPack > pw.qtyToPick && pw.pkgSelected == true) { errorMsg2 = 'Packed quantity cannot be greater than picked Quantity.'; error = true; break; }
                }
                if(!error) { Package2Create.Active__c = true;
                            if(Package2Create != null) if(Schema.sObjectType.Package__c.fields.Active__c.isCreateable() && Schema.sObjectType.Package__c.fields.Active__c.isUpdateable() && Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()) { DMLManager.upsertAsUser(Package2Create); } else{ /* no access*/ }
                    for(Integer i=1; i<=packageWrapperList.size(); i++) {
                        if(packageWrapperList[i-1].pkgSelected == true) { Package_List__c packageList = new Package_List__c();                            
                                                                          packageList.Name = 'Package List - '+i;
                                                                          packageList.Active__c = true;
                                                                          packageList.Package__c = Package2Create.Id;
                                                                          packageList.Quantity__c = packageWrapperList[i-1].qtyToPack;
                                                                          packageList.Work_Orders__c = packageWrapperList[i-1].woli.work_Orders__c;
                                                                          packageList.Work_Order_Line_Items__c = packageWrapperList[i-1].woli.Id;
                                                                          if(packageWrapperList[i-1].woli.Packed_Quantity__c == null) packageWrapperList[i-1].woli.Packed_Quantity__c = packageWrapperList[i-1].qtyToPack; else packageWrapperList[i-1].woli.Packed_Quantity__c += packageWrapperList[i-1].qtyToPack;
                                                                        
                                                                          woliMap.put(packageWrapperList[i-1].woli.Id, packageWrapperList[i-1].woli);
                                                                          PLS.add(packageList);
                        }
                    }    
                    if(PLS.size() > 0) {
                        if(Schema.sObjectType.Package_List__c.fields.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Work_Order_Line_Items__c.isUpdateable() && Schema.sObjectType.Package_List__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Work_Orders__c.isUpdateable() && Schema.sObjectType.Package_List__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Quantity__c.isUpdateable() && Schema.sObjectType.Package_List__c.fields.Package__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Package__c.isUpdateable() && Schema.sObjectType.Package_List__c.fields.Active__c.isCreateable() && Schema.sObjectType.Package_List__c.fields.Active__c.isUpdateable() && Schema.sObjectType.Package_List__c.fields.Name.isCreateable() && Schema.sObjectType.Package_List__c.fields.Name.isUpdateable() && Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()) { DMLManager.UpsertAsUser(PLS); } else{ /* no access*/ }
                        if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Packed_Quantity__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Packed_Quantity__c.isUpdateable() && Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) { DMLManager.UpsertAsUser(woliMap.Values()); } else{/*no access*/  }
                    } createPacks();      
                }
            } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for displaying available shipment list from the system.
    */
    public PageReference createShipments() {
        try {
            Set<Id> woIds = new Set<Id>();
            shipmentList = new List<Shipment__c>();
            shipmentWrapperList = new List<Wrappers>();
            
            if(woWrapperList.size() > 0) {
                woSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : woWrapperList) { 
                   if(sow.woSelected == true) { 
                        woIds.add(sow.WO.Id);
                        woSelectedWrapperList.add(sow);
                        if(workorderId == sow.WO.Id) workorderId = Null;
                   }
                   if(workorderId == sow.WO.Id){ woSelectedWrapperList.add(sow); woIds.add(sow.WO.Id); }
                }
            } else { for(Wrappers sow : woSelectedWrapperList) { if(sow.woSelected == true) { woIds.add(sow.WO.Id);
                    }
                } 
            } 
            
            
            if(workorderId != null && workorderId != '') woIds.add(workorderId);
            if(woIds.size() > 0) {
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { shipmentList = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' ,RecordType.Name, Sales_Order__r.Name, Work_Order__r.Name, Purchase_Orders__r.Name, Transfer_Order__r.Name, Return_Merchandise_Authorisation__r.Name, Customer__r.Name, Shipping_Address__r.Customer__r.Name, '+
                                      +' Shipping_Address__r.Address_Line1__c, Shipping_Address__r.Address_Line2__c, Shipping_Address__r.Address_Line3__c, Shipping_Address__r.City__c, Shipping_Address__r.County__c, Shipping_Address__r.Country__c, Shipping_Address__r.Contact__r.Phone, '+
                                      +' Shipping_Address__r.Contact__r.Fax, Shipping_Address__r.Contact__r.Name, Shipping_Address__r.Contact__r.Email, Shipping_Address__r.State__c, Shipping_Address__r.Postal_Code__c from Shipment__c where (Work_Order__c In: woIds And Active__c = true) Order by CreatedDate Asc');
                }
                for(Shipment__c shp: shipmentList) { Wrappers wrap = new Wrappers(); wrap.shipM = shp;
                    if(wrap.shipM.RecordType.Name == 'UPS Shipping') wrap.shipmentType = 'UPS'; else if(wrap.shipM.RecordType.Name == 'Fedex Shipping') wrap.shipmentType = 'FedEx';  else if(wrap.shipM.RecordType.Name == 'Internal Shipping') wrap.shipmentType = 'Shipment';
                    if(shp.Tracking_Number__c != null) wrap.trackingNo += shp.Tracking_Number__c.replace(',','<br/>');
                    shipmentWrapperList.add(wrap);
                } return page.stockdispatching_WO_Shipment;} else errorMsg = 'Please select an order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }    
        return null;
    }
    
    /*
      method for deleting shipment
    */
    public PageReference deleteShipment() {
        try {
            if(packageId != null) shipmentWrapperList.remove(Integer.valueof(packageId));
            if(shipmentId != null && Schema.sObjectType.Shipment__c.isDeletable()) { DMLManager.DeleteAsUser(new Shipment__c(Id = shipmentId));} else{ /* no access*/ }} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }    
    
    /*
      method for create work order upon selected sales order line items
    */
    public PageReference createWOs() {
        try {
            WO = new WO__c(Status__c='New');             
            return Page.stockdispatching_WO_CreateWorkOrder;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for adding more WOLI rows
    */
    public PageReference addWoliWrapperRows() {
        try {
            for(Integer i=0; i<addRow; i++) { wolisWrapperList.add(new newWrapper(nextIdent++)); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting WOLI rows
    */
    public PageReference delWoliWrapperRow() {
        try {
            if(toDelIdent != null) wolisWrapperList.remove(toDelIdent);   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for saving WO details
    */    
    public PageReference saveWO() {
        try {
            if(WO != null && Schema.sObjectType.WO__c.isCreateable() && Schema.sObjectType.WO__c.isUpdateable()) { DMLManager.UpsertAsUser(WO);  } else{ /* no access*/ }
            Wolis = new List<Work_Order_Line_Items__c>();       
            for(newWrapper nwrp: wolisWrapperList) { Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c();                
                                                     woli = nwrp.wolis;
                                                     if(Schema.sobjectType.WO__c.isAccessible()) woli.Work_Orders__c = WO.Id;
                                                     Wolis.add(woli);
                                                   } if(Wolis.size() > 0) { if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Work_Orders__c.isUpdateable() && Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) { DMLManager.UpsertAsUser(Wolis);    } else{ /* no access*/ }   }  
            return Page.Stockdispatching_WorkOrder;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for getting organization's currency code.
    */    
    public static String getCurrencyIsoCode(SObject someObject) {
        String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        return currencyIso;
    }
    
    /*
      method for generating picking slip(collection of selected SOLI's) as pdf.
    */        
    public PageReference createPickingSlips() {
        String wOrderId;
        try {
            woliSelectedWrapperList = new List<Wrappers>();
            if(woliWrapperList != null) { for(Wrappers wrap : woliWrapperList) {  wOrderId = wrap.woli.Work_Orders__c;  if(wrap.woliSelected == true) woliSelectedWrapperList.add(wrap); }
                                          WO = [Select Id, Name, ERP7__Billing_Address__c, ERP7__Billing_Address__r.ERP7__Customer__c, ERP7__Billing_Address__r.ERP7__Customer__r.ERP7__Company__c,
                                          ERP7__Billing_Address__r.ERP7__Address_Line1__c, ERP7__Billing_Address__r.ERP7__Address_Line2__c, ERP7__Billing_Address__r.ERP7__Address_Line3__c,  
                                          ERP7__Billing_Address__r.ERP7__City__c, ERP7__Billing_Address__r.ERP7__Country__c, ERP7__Billing_Address__r.ERP7__Active__c, 
                                          ERP7__Billing_Address__r.ERP7__Primary__c, ERP7__Billing_Address__r.ERP7__Is_Billing_Address__c, ERP7__Billing_Address__r.ERP7__Postal_Code__c, ERP7__Shipping_Address__c, ERP7__Shipping_Address__r.ERP7__Address_Line1__c,
                                          ERP7__Shipping_Address__r.ERP7__Address_Line2__c, ERP7__Shipping_Address__r.ERP7__Address_Line3__c, ERP7__Shipping_Address__r.ERP7__City__c, ERP7__Shipping_Address__r.ERP7__Country__c,
                                          ERP7__Shipping_Address__r.ERP7__Customer__r.ERP7__Company__c, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__Contact__r.Phone, ERP7__Shipping_Address__r.ERP7__Postal_Code__c, ERP7__Customer__c, ERP7__Customer__r.ERP7__Company__c From ERP7__WO__c where Id =: wOrderId];   
                                          return page.stockdispatching_WO_PickingSlips;
            } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }   return null;
    }
    
    /*
      method for generating packing label as pdf
    */
    public PageReference createPackingLabels() {
        try {
            String contactId, newPackageId;
            Set<Id> pkgIds = new Set<Id>();
            packageList = new List<Package__c>();
            packList = new List<Package_List__c>();
            packageRecords = new Map<Package__c, List<Package_List__c>>();                    
            if(packageId != null && packageId != '') pkgIds.add(packageId);
            for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) pkgIds.add(lw.pack.Id); }
            if(pkgIds.size() > 0) {  
                for(Package__c p : [select Name, Work_Order__r.Customer__r.Name, Barcode__c, Name__c, Owner.Name, CreatedDate, Weight__c, Work_Order__r.Contact__r.Name, Work_Order__r.Shipping_Address__r.Address_Line1__c, Work_Order__r.Shipping_Address__r.Address_Line2__c, 
                                    Work_Order__r.Shipping_Address__r.Address_Line3__c, Work_Order__r.Shipping_Address__r.City__c, Work_Order__r.Shipping_Address__r.County__c, Work_Order__r.Shipping_Address__r.State__c, Work_Order__r.Shipping_Address__r.Postal_Code__c, 
                                    Work_Order__r.Shipping_Address__r.Country__c, Work_Order__r.Shipping_Address__r.Customer__r.Name, Work_Order__r.Shipping_Address__r.Contact__r.Name, Work_Order__r.Shipping_Address__r.Contact__r.Phone, Work_Order__r.Shipping_Address__r.Contact__r.Fax, 
                                    Description__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Package__r.Work_Order__c, Work_Order_Line_Items__r.Product__r.SKU__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Quantity__c, Work_Order_Line_Items__c, 
                                    Work_Order_Line_Items__r.Work_Orders__r.Name, Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Name, SKU__c, Package_Weight__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {
                     
                     packListRecords = new List<Package_List__c>(); for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); }
                     packageRecords.put(p,packListRecords); contactId = p.Work_Order__r.Contact__c; newPackageId = p.Id;
                }                
                // getting email content before creating a preview
                packingTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: 'Packing_Label'];            
                Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
                String [] toAddresses_test = new String[] {'test@test.com'}; 
                email_Attach.setToAddresses(toAddresses_test);
                email_Attach.setTemplateId(packingTemplate.Id);
                email_Attach.setSaveAsActivity(false);                     
                email_Attach.setTargetObjectId(contactId);
                email_Attach.setWhatId(newPackageId);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});  Database.rollback(sp);
                return page.stockdispatching_WO_PackingSlips;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }    
        return null;
    }
    
    /*
      method for generating packing slip(collection of selected package list) as pdf.
    */    
    public PageReference createPackingSlips() {
        try {
            String contactId, newPackageId;
            Set<Id> pkgIds = new Set<Id>();
            packageRecords = new Map<Package__c, List<Package_List__c>>();                    
            if(packageId != null && packageId != '') pkgIds.add(packageId);
            for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) pkgIds.add(lw.pack.Id); } 
            if(pkgIds.size() > 0) {
                for(Package__c p : [select Name, Work_Order__r.Customer__r.Name, Barcode__c, Name__c, Owner.Name, CreatedDate, Weight__c, Work_Order__r.Contact__r.Name, Work_Order__r.Shipping_Address__r.Address_Line1__c, Work_Order__r.Shipping_Address__r.Address_Line2__c, 
                                    Work_Order__r.Shipping_Address__r.Address_Line3__c, Work_Order__r.Shipping_Address__r.City__c, Work_Order__r.Shipping_Address__r.County__c, Work_Order__r.Shipping_Address__r.State__c, Work_Order__r.Shipping_Address__r.Postal_Code__c, 
                                    Work_Order__r.Shipping_Address__r.Country__c, Work_Order__r.Shipping_Address__r.Customer__r.Name, Work_Order__r.Shipping_Address__r.Contact__r.Name, Work_Order__r.Shipping_Address__r.Contact__r.Phone, Work_Order__r.Shipping_Address__r.Contact__r.Fax, 
                                    Description__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Package__r.Work_Order__c, Work_Order_Line_Items__r.Product__r.SKU__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Quantity__c, Work_Order_Line_Items__c,
                                    Work_Order_Line_Items__r.Work_Orders__r.Name, Work_Order_Line_Items__r.Total_Cost__c,  Work_Order_Line_Items__r.Name, SKU__c, Package_Weight__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {
                     packListRecords = new List<Package_List__c>();  for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); }
                     packageRecords.put(p,packListRecords); contactId = p.Work_Order__r.Contact__c; newPackageId = p.Id;
                }
                // getting email content before creating a preview
                packingTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: 'Packing_Label'];            
                Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
                String [] toAddresses_test = new String[] {'test@test.com'}; 
                email_Attach.setToAddresses(toAddresses_test);
                email_Attach.setTemplateId(packingTemplate.Id);
                email_Attach.setSaveAsActivity(false);                     
                email_Attach.setTargetObjectId(contactId);
                email_Attach.setWhatId(newPackageId);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); Database.rollback(sp);
                
                return page.stockdispatching_WO_PackingLists;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for generating shipping slips as pdf to print.
    */
    public PageReference createShippingSlips() {
        try {
            String contactId, newShipmentId;
            Set<Id> pkgIds = new Set<Id>();
            Set<Id> shipIds = new Set<Id>();                        
            List<Shipment__c> shipList = new List<Shipment__c>();
            shipmentRecords = new Map<Shipment__c, List<Package_List__c>>();
            for(Wrappers wrap: shipmentWrapperList) { 
                // for multiple shipping slips 
                if(wrap.shipSelected) { shipIds.add(wrap.shipM.Id); shipList.add(wrap.shipM); } 
                // for single shipping slips                
                else if(shipmentId == wrap.shipM.Id) shipIds.add(wrap.shipM.Id); shipList.add(wrap.shipM);
            }  
            if(shipIds.size() > 0) {
                for(Package__c pk: Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where Shipment__c In: shipIds')) { pkgIds.add(pk.Id); }
                List<Package_List__c> packageItemList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Name, '+
                                                        +' Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Total_Price__c,  Sales_Order_Line_Item__r.Description__c, Sales_Order_Line_Item__r.Shipping_Amount_Quantity__c, '+
                                                        +' Sales_Order_Line_Item__r.Admin_Shipping_Amount__c, Package__r.Shipment__c, Package__r.Name from Package_List__c where Package__c In: pkgIds');                
                for(Shipment__c sh: shipList) {   
                    List<Package_List__c> pkgItemList = new List<Package_List__c>();
                    Boolean adding = false;
                    for(Package_List__c pkl: packageItemList) { if(pkl.Package__r.Shipment__c == sh.Id) { pkgItemList.add(pkl); adding = true; } }
                    if(adding) shipmentRecords.put(sh, pkgItemList);    
                    newShipmentId = sh.Id;
                    if(sh.Customer_Contact__c != null) contactId = sh.Customer_Contact__c;   
                }
                // getting email content before creating a preview
                shippingTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: 'Shipping_Label'];            
                Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
                String [] toAddresses_test = new String[] {'test@test.com'}; 
                email_Attach.setToAddresses(toAddresses_test);
                email_Attach.setTemplateId(shippingTemplate.Id);
                email_Attach.setSaveAsActivity(false);                     
                email_Attach.setTargetObjectId(contactId);
                email_Attach.setWhatId(newShipmentId);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});Database.rollback(sp);
                return page.stockdispatching_WO_ShippingSlips;        
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      scanner methods upon scanned barcode.
    */
    public PageReference scannerMethod() {
        try { 
            if(!Schema.sObjectType.WO__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.WO__c.Label));
            else { woList = Database.query('select ' + String.escapeSingleQuotes(WOFields) + ' , WO_Supplier__r.Name from WO__c where (Is_Closed__c = false And Active__c = true) Limit 100'); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    public PageReference scannerMethodCustom() {
        try {
            errorMsg = '';
            barcodeLocMsg = '';
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); }
            else if(mybarcode == 'PICK') { return redirect2NextTab(); }
            else if(mybarcode == 'PACK') { return savewolis(); }
            else if(mybarcode == 'SHIP') { createShipments(); }
                        
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<Work_Order_Line_Items__c> woliListcheck = new List<Work_Order_Line_Items__c>();
            
            if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
            else if(Schema.sObjectType.Site__c.isAccessible() && Schema.sObjectType.Site__c.Fields.Name.isAccessible() && Schema.sObjectType.Site__c.Fields.Barcode__c.isAccessible() && Schema.sObjectType.Location__c.Fields.Active__c.isAccessible()) {  
                siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1]; }
            
            if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
            else if(Schema.sObjectType.Location__c.isAccessible() && Schema.sObjectType.Location__c.Fields.Name.isAccessible() && Schema.sObjectType.Location__c.Fields.Active__c.isAccessible() && Schema.sObjectType.Location__c.Fields.Barcode__c.isAccessible()){
                SSLList = [Select Id, Name, Barcode__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1]; }
            
            if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
            else if(Schema.sObjectType.StorageContainer__c.isAccessible() && Schema.sObjectType.StorageContainer__c.Fields.Name.isAccessible() && Schema.sObjectType.StorageContainer__c.Fields.Active__c.isAccessible() && Schema.sObjectType.Location__c.Fields.Barcode__c.isAccessible()){
                binList = [Select Id, Name, Barcode__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1]; }
                        
            if(!Schema.sObjectType.MRP__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.MRP__c.Label));
            else if(Schema.sObjectType.MRP__c.isAccessible() && Schema.sObjectType.MRP__c.Fields.Name.isAccessible() && Schema.sObjectType.MRP__c.Fields.MRP_Product__c.isAccessible() && Schema.sObjectType.Location__c.Fields.Barcode__c.isAccessible()) {
                woliListcheck = [select Id, Name, Barcode__c, Product__c, Product__r.Barcode__c from Work_Order_Line_Items__c where Barcode__c =:barcode.trim() Or Product__r.Barcode__c =:barcode.trim() limit 1]; }
            
            if(woliListcheck.size() > 0 && barcodeLoc != '' && barcodeLoc != Null) {
                for(Wrappers W : woliWrapperList){ if(!W.woliSelected && W.AddressName==barcodeLoc && (barcode.trim() == W.woli.Barcode__c || barcode.trim() == W.woli.Product__r.Barcode__c)){
                        barcodeLoc = barcodeLocMsg = ''; W.woliSelected = true;  return null;
                    }             
                }
            }              
            for(Wrappers W : woliWrapperList){
                if(!W.woliSelected && ((siteList.size()>0 && W.AddressName == siteList[0].Id) || (SSLList.size()>0 && W.AddressName == SSLList[0].Id) || (binList.size()>0 && W.AddressName == binList[0].Id))) { 
                    barcodeLocMsg = barcodeLoc = ''; integer wCount = 0; String addrs = W.AddressName;
                    for(Wrappers WA : woliWrapperList){ if(addrs == WA.AddressName) wCount+=1; } if(wCount == 1) W.woliSelected = true; 
                    else if(wCount > 1) { barcodeLocMsg = 'There are multiple products in the stock ';
                        if(siteList.size() > 0) barcodeLocMsg = barcodeLocMsg+'"'+siteList[0].Barcode__c+'"'+' please scan the product to pick.'; else if(SSLList.size() > 0) barcodeLocMsg = barcodeLocMsg+'"'+SSLList[0].Barcode__c+'"'+' please scan the product to pick.'; else if(binList.size() > 0) barcodeLocMsg = barcodeLocMsg+'"'+binList[0].Barcode__c+'"'+' please scan the product to pick.'; 
                        barcodeLoc = W.AddressName;} break;
                }             
            }
            if(woList.size() > 0) { woWrapperList = new List<Wrappers>();
                for(WO__c sos : WOList) { Wrappers wrap = new Wrappers();
                                          wrap.woSelected = true;
                                          wrap.WO = sos;
                                          woWrapperList.add(wrap);
                }    
            } if(barcodeLocMsg == '') savewolis(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    public pageReference scannerMethodCustomPick() {
        try {
            errorMsg = '';
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); }
            else if(mybarcode == 'PICK') { return redirect2NextTab(); }
            else if(mybarcode == 'PACK') { return savewolis(); }
            else if(mybarcode == 'SHIP') { createShipments(); }
            
            if(WOList.size() > 0) {
                if(initialScan != true) { initialScan = true; woWrapperList = new List<Wrappers>(); }
                for(WO__c sos : WOList) { boolean exist = false;
                    for(Wrappers w : woWrapperList) { if(sos.Id == w.WO.Id) exist = true; }
                    if(!exist) { Wrappers wrap = new Wrappers();
                                 wrap.woSelected = true;
                                 wrap.WO = sos;
                                 woWrapperList.add(wrap);
                    }
                }
            }    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for generating barcodes from different sObject fields as pdf.
    */
    public PageReference createBarcodesPage() {
        return page.stockdispatching_WO_printbarcodes;
    }
    
    /*
      method for redirecting back to ship / pack tab.
    */
    public PageReference back2ShipmentPage() {
        if(ApexPages.currentPage().getParameters().get('shipmentId') != null) return page.stockdispatching_WO_Shipment;
        else if(ApexPages.currentPage().getParameters().get('pack') != null) return page.stockdispatching_WO_Package;
        return null;        
    }        
    public PageReference back() {
        pageReference pag = new pageReference('/apex/ERP7__Stockdispatching_WorkOrder');
        pag.setRedirect(true);
        return pag;
    }
    public pageReference createOrder() {                   
        pageReference pag = new pageReference('/apex/ERP7__Stockdispatching_WorkOrder');
        pag.setRedirect(true);
        return pag;
    }
    public PageReference createPackage() {
        return null;
    }   
    public PageReference createUPSShipment() {
        try {
            String sType = '';
            Boolean error = false;
            selectedPackIds = new List<Id>();            
            if(lineItemWrapperList != null) {
                for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) {if(sType == '') sType = lw.pack.Shipment_Type__c; if(sType == lw.pack.Shipment_Type__c) { selectedPackIds.add(lw.pack.Id); if(shipmentType == null) shipmentType = lw.pack.Shipment_Type__c; } else { errorMsg1 = 'You cannot select packages with different shipment type.'; error = true; break; }
                                                               } else { if(packageId != null && packageId != '') selectedPackIds.add(packageId); }
                                                             } 
            } 
            if(!error) { errorMsg1 = '';
                if(selectedPackIds.size() > 0 && shipmentType == 'UPS') { showUPSComponent = true; shipId = ''; retValue = 'WO'; }
                else if((shipmentId != null && shipmentId != '') && shipmentType == 'UPS') { showUPSComponent = true; shipId = shipmentId; retValue = 'WO'; }
                else if(selectedPackIds.size() > 0 && shipmentType == 'FedEx') { showFedExComponent = true; shipId = ''; retValue = 'WO'; }
                else if((shipmentId != null && shipmentId != '') && shipmentType == 'FedEx') { showFedExComponent = true; shipId = shipmentId; retValue = 'WO'; }
                else if(selectedPackIds.size() > 0 && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = ''; retValue = 'WO'; }
                else if((shipmentId != null && shipmentId != '') && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = shipmentId; retValue = 'WO'; }
            } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
    wrapper class definitions
    */
    public static String sortBy                                { get; set; }
    public static String prevSortBy                            { get; set; }
    public static String orderFormat                           { get; set; }
        
    public List<Wrappers> woWrapperList                        { get; set; }    
    public List<Wrappers> woliWrapperList                      { get; set; }
    public List<Wrappers> shipmentWrapperList                  { get; set; }     
    public List<Wrappers> woSelectedWrapperList                { get; set; }
    public List<Wrappers> woliSelectedWrapperList              { get; set; }         
    public List<Wrappers> shipmentSelectedWrapperList          { get; set; }
    public class Wrappers implements Comparable {    
        public WO__c WO                                        { get; set; }          
        public String WN                                       { get; set; } 
        public String LN                                       { get; set; } 
        public String SD                                       { get; set; }
        public String binName                                  { get; set; }
        public Boolean include                                 { get; set; }
        public Shipment__c shipM                               { get; set; }        
        public String batchLotCode                             { get; set; }           
        public String trackingNo                               { get; set; }        
        public String AddressName                              { get; set; }                 
        public Boolean woSelected                              { get; set; }
        public String locationName                             { get; set; } 
        public Boolean woliSelected                            { get; set; }
        public Boolean shipSelected                            { get; set; }  
        public String warehouseName                            { get; set; }
        public Boolean isSOLIawaiting                          { get; set; }        
        public Integer raisedQty                               { get; set; }
        public String shipmentType                             { get; set; }        
        public Integer requiredQty                             { get; set; }
        public Integer remainingQty                            { get; set; }        
        public Decimal inventoryStock                          { get; set; }        
        public List<SelectOption> Address                      { get; set; }                    
        public Boolean isAvailablePackages                     { get; set; }
        public Boolean isAvailableShipments                    { get; set; }  
        public Boolean isAllShipmentsDelivered                 { get; set; } 
        public Work_Order_Line_Items__c woli                   { get; set; }                                
        public List<SelectOption> CurrentBins                  { get; set; }
        public List<SelectOption> CurrentLocations             { get; set; }
        public List<SelectOption> CurrentWarehouses            { get; set; }
        public Boolean woliVerified                            { get; set; }
        public List<SelectOption> BatchLotCodes                { get; set; }
        public ERP7__MRP__c MRP                                { get; set; }
        public Product2 product                      { get; set; }
        public Asset__c Asset                        { get; set; }
        public List<Wrappers> MRPsWrapperList                  { get; set; }
        public Stock_Outward_Line_Item__c SerialNumbers        { get; set; }
        public Boolean serialized                              { get; set; }
        
                      
        public Wrappers() {
            SD = '';          
            WN = '';     
            LN = '';
            binName = null;
            raisedQty = 0;
            requiredQty = 0;
            remainingQty = 0;
            include = false;                          
            WO = new WO__c();
            trackingNo = '';
            AddressName = '';
            batchLotCode = '';
            inventoryStock = 0;                  
            woSelected = false;
            locationName = null;             
            warehouseName = null;            
            woliSelected = false;
            shipSelected = false;
            woliVerified = false;
            isSOLIawaiting = false;                                    
            shipM = new Shipment__c();
            isAvailablePackages = false;
            isAvailableShipments = false;
            isAllShipmentsDelivered = false;              
            Address = new List<SelectOption>(); 
            woli = new Work_Order_Line_Items__c();                        
            CurrentBins = new List<SelectOption>();
            CurrentLocations = new List<SelectOption>();
            CurrentWarehouses = new List<SelectOption>();
            
            BatchLotCodes = new List<SelectOption>(); 
            MRP = new ERP7__MRP__c(); 
            MRPsWrapperList = new List<Wrappers>(); 
            product = new product2();   
            Asset = new Asset__c();
            serialized = false;
            SerialNumbers = new Stock_Outward_Line_Item__c();                 
        }
        public Integer compareTo(Object objToCompare) {
            if(sortBy == 'WN') { Integer result = WN.compareTo(((Wrappers)objToCompare).WN); return (orderFormat == 'ASC')? result : result * -1; } else if(sortBy == 'LN') { Integer result = LN.compareTo(((Wrappers)objToCompare).LN); return (orderFormat == 'ASC')? result : result * -1; } 
            else if(sortBy == 'SD') { Integer result = SD.compareTo(((Wrappers)objToCompare).SD); return (orderFormat == 'ASC')? result : result * -1; } 
            return 0;  
        }     
    }
    public List<newWrapper> wolisWrapperList              { get; set; }
    public class newWrapper {        
        public Integer ident                              { get; set; } 
        public Work_Order_Line_Items__c wolis             { get; set; }
        
        public newWrapper(Integer inIdent) {
            ident = inIdent;
            wolis = new Work_Order_Line_Items__c();
        }
    }   
    public class innerPackageWrapper{
        public String pack                               { get; set; }        
        public Package__c packege                        { get; set; }
        public List<SelectOption> packList               { get; set; }        
        public Package_List__c packageList               { get; set; }
        
        public innerPackageWrapper() {
            pack = ''; 
            packege = new Package__c();
            packageList = new Package_List__c();
            packList = new List<SelectOption>();            
        }
    }    
    
    public class packageWrapper {
        public Decimal qtyToPick                                 { get; set; }   
        public Decimal qtyToPack                                 { get; set; }
        public Boolean pkgSelected                               { get; set; } 
        public Work_Order_Line_Items__c woli                     { get; set; }
        public List<innerPackageWrapper> innerPackList           { get; set; }        
      
        public packageWrapper(){ 
            qtyToPick = 0;
            qtyToPack = 0;
            pkgSelected = false;
            woli = new Work_Order_Line_Items__c();
            innerPackList = new List<innerPackageWrapper>();
        }
    } 
    
    public class lineItemWrapper {
        public Boolean sel                               { get; set; }
        public String units                              { get; set; }  
        public Package__c pack                           { get; set; }
        public Shipment__c shipment                      { get; set; }
        public Decimal NoofLineItems                     { get; set; }        
        
        public lineItemWrapper(){            
            units = '';
            sel = false;            
            NoofLineItems = 0;
            pack = new Package__c();
            shipment = new Shipment__c();
        }
    }    
}