public with sharing class StockDispatchingController_TO {

    public static Integer toDelIdent                                   { get; set; }          
    public static Integer addRow                                       { get; set; }                          
    public Transfer_Order__c TO                                        { get; set; }            
    public String pack2updateId                                        { get; set; }
    public String shipmentType                                         { get; set; }        
    public String shipmentId                                           { get; set; }
    public Integer nextIdent                                           { get; set; }         
    public String packageId                                            { get; set; }
    public String imageURL                                             { get; set; }       
    public String barcode                                              { get; set; }       
    public String shipId                                               { get; set; }    
    public String retValue                                             { get; set; }            
    Public Boolean scanned                                             { get; set; }     
    public String errorMsg                                             { get; set; }
    public String TOFields                                             { get; set; }
    public String errorMsg1                                            { get; set; }     
    public String errorMsg2                                            { get; set; }     
    public List<Id> toliIds                                            { get; set; }    
    public String TOLIFields                                           { get; set; }
    public String searchText                                           { get; set; }
    public String barcodeLoc                                           { get; set; }  
    public Boolean CreatePack                                          { get; set; }              
    public Boolean isAwaiting                                          { get; set; } 
    public Boolean initialScan                                         { get; set; }    
    public String pkgTypeValue                                         { get; set; }    
    public String orderNumber                                          { get; set; }    
    public Map<Id, Id> stockMap                                        { get; set; }     
    public String barcodeLocMsg                                        { get; set; }
    public String packageFields                                        { get; set; }  
    public String shipmentFields                                       { get; set; }    
    public String warehouseFields                                      { get; set; }   
    public String transferorderId                                      { get; set; }  
    public String ShipmentRecTypeId                                    { get; set; }     
    public String packageListFields                                    { get; set; }
    public List<Package__c> Packages                                   { get; set; }
    public List<Id> selectedPackIds                                    { get; set; }
    public Package__c Package2Create                                   { get; set; }
    public List<Shipment__c> Shipments                                 { get; set; }    
    public List<Package__c> packageList                                { get; set; }    
    public List<Package_List__c> packList                              { get; set; }
    public List<Shipment__c> shipmentList                              { get; set; }                           
    public List<Transfer_Order__c> TOList                              { get; set; }    
    public String PackageCustomSettingFields                           { get; set; }                      
    public List<Package_List__c> packageLists                          { get; set; }                 
    public List<Package_List__c> packListRecords                       { get; set; }
    public List<packageWrapper> packageWrapperList                     { get; set; }  
    public List<Stock_Outward_Line_Item__c> SDLIList                   { get; set; }   
    public List<lineItemWrapper> lineItemWrapperList                   { get; set; }
    public List<Transfer_Order_Line_Items__c> Toliss                   { get; set; }         
    public List<Transfer_Order_Line_Items__c> toliList                 { get; set; }    
    public List<Transfer_Order_Line_Items__c> currentItems             { get; set; }    
    public Map<Package__c, List<Package_List__c>> packageRecords       { get; set; }       
    public Map<Shipment__c, List<Package_List__c>> shipmentRecords     { get; set; } 
    public String sfdcBaseURL                                          { get; set; }
    public Boolean showUPSComponent                                    { get; set; }                                                                     
    public Boolean showFedExComponent                                  { get; set; }                                                                     
    public List<Location__c> SSLList                                   { get; set; }
    public Map<Id, Package__c> packMap                                 { get; set; }        
    public EmailTemplate packingTemplate                               { get; set; } 
    public EmailTemplate shippingTemplate                              { get; set; } 
    public List<StorageContainer__c> binList                           { get; set; }           
    public List<Inventory_Stock__c> WIISList                           { get; set; } 
    public Boolean showInternalShippingComponent                       { get; set; }            
    public String prodFields                                           { get; set; }  
    public PrintBarcodes PB                                            { get; set; }          
    
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
    public Integer rowCounter                                          { get; set; }
    public String siteFields                                           { get; set; } 
    public String locationsFields                                      { get; set; } 
    public String binFields                                            { get; set; }    
    
    public String errormsg3                                            { get; set; }
    public Boolean hasAccess                                           { get; set; }    
           
    /*
      Constructor.
    */
    public StockDispatchingController_TO() {
        try {
            PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');               
            TOFields = UtilClass.selectStarFromSObject('ERP7__Transfer_Order__c');
            utilClass.FLSCheck(TOFields.split(','),'ERP7__Transfer_Order__c');                 
            ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c');
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');    
            TOLIFields = UtilClass.selectStarFromSObject('ERP7__Transfer_Order_Line_Items__c'); 
            utilClass.FLSCheck(TOLIFields.split(','),'ERP7__Transfer_Order_Line_Items__c');   
            PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c'); 
            warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c'); 
            utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c');               
            prodFields = UtilClass.selectStarFromSObject('Product2');
            utilClass.FLSCheck(prodFields.split(','),'Product2');  
            PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');         
            utilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');        
            siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c');         
            utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c');          
            locationsFields = UtilClass.selectStarFromSObject('ERP7__Location__c'); 
            utilClass.FLSCheck(locationsFields.split(','),'ERP7__Location__c');
            binFields = UtilClass.selectStarFromSObject('ERP7__StorageContainer__c');
            utilClass.FLSCheck(binFields.split(','),'ERP7__StorageContainer__c');  
            
            errorMsg = '';
            errorMsg2 = '';
            nextIdent = 0;
            orderNumber = '';             
            //transferorderId = '';
            toliIds = new List<Id>(); 
            showUPSComponent = false;
            showFedExComponent = false;              
            stockMap = new Map<Id, Id>();
            SSLList = new List<Location__c>();                        
            Packages = new List<Package__c>();
            Package2Create = new Package__c();
            Shipments = new List<Shipment__c>();
            showInternalShippingComponent = false;             
            TOList = new List<Transfer_Order__c>();
            tolisWrapperList = new List<newWrapper>(); 
            binList = new List<StorageContainer__c>();
            packageLists = new List<Package_List__c>();                                    
            WIISList = new List<Inventory_Stock__c>();
            toliList = new List<Transfer_Order_Line_Items__c>();
            showSN = false;
            showBatch = false;
            
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visual.force.com');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            imageURL = '/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));
            else { List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
                   if(documentList.size() > 0) imageURL = imageURL + documentList[0].id;  
            } 
            
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
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c,  Channel__c, Site__c, Site__r.Name
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
            
            
            alltransferorders();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for displaying all available transfer orders.
    */
    public void alltransferorders() {
        try {
            Set<Id> toIds = new Set<Id>();
            toWrapperList = new List<Wrappers>();            
            List<Package__c> pkgList = new List<Package__c>();
            toliList = new List<Transfer_Order_Line_Items__c>();
            List<Shipment__c> shipList = new List<Shipment__c>();  
            String transferorderId = ApexPages.currentPage().getParameters().get('toId');  
            if(Schema.sObjectType.Transfer_Order__c.isAccessible()) {
                if(transferorderId != null && transferorderId != '') {
                    TOList = Database.query('select ' + String.escapeSingleQuotes(TOFields) + ' , From_Address__r.Address_Line1__c, From_Address__r.Address_Line2__c, From_Address__r.Address_Line3__c, From_Address__r.City__c, From_Address__r.County__c, From_Address__r.Country__c, From_Address__r.State__c, From_Address__r.Postal_Code__c, To_Address__r.Address_Line1__c, '+
                             +' To_Address__r.Address_Line2__c, To_Address__r.Address_Line3__c, To_Address__r.City__c, To_Address__r.County__c, To_Address__r.Country__c, To_Address__r.State__c, To_Address__r.Postal_Code__c from Transfer_Order__c where (Id =\'' + String.escapeSingleQuotes(transferorderId) + '\' And Active__c = true And Status__c = \'Approved\' And Is_Closed__c = false) And ERP7__Ready_To_Pick_Pack__c = true Order by Expected_Date__c Asc Limit 1');
                } else {             
                    TOList = Database.query('select ' + String.escapeSingleQuotes(TOFields) + ' , From_Address__r.Address_Line1__c, From_Address__r.Address_Line2__c, From_Address__r.Address_Line3__c, From_Address__r.City__c, From_Address__r.County__c, From_Address__r.Country__c, From_Address__r.State__c, From_Address__r.Postal_Code__c, '+
                             +' To_Address__r.Address_Line1__c, To_Address__r.Address_Line2__c, To_Address__r.Address_Line3__c, To_Address__r.City__c, To_Address__r.County__c, To_Address__r.Country__c, To_Address__r.State__c, To_Address__r.Postal_Code__c from Transfer_Order__c where (Active__c = true And Status__c = \'Approved\' And Is_Closed__c = false) And ERP7__Ready_To_Pick_Pack__c = true Order by Expected_Date__c Asc Limit 1000');
                }                
            } for(Transfer_Order__c to: TOList) { toIds.add(to.Id); }
            if(toIds.size() > 0) { if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible()) toliList = Database.query('select ' + String.escapeSingleQuotes(TOLIFields) + ' from Transfer_Order_Line_Items__c where (Transfer_Order__c In : toIds)');
                                   if(Schema.sObjectType.Package__c.isAccessible()) pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Transfer_Order__c In: toIds)');
                                   if(Schema.sObjectType.Shipment__c.isAccessible()) shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Transfer_Order__c In: toIds)');
                for(Transfer_Order__c tos : TOList) { Wrappers wrap = new Wrappers(); 
                    for(Transfer_Order_Line_Items__c toli : toliList) { if(toli.Transfer_Order__c == tos.Id && toli.Picked_Quantity__c != toli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }                     
                    for(Package__c pkg : pkgList) { if(pkg.Transfer_Order__c == tos.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) {  
                        if(ship.Transfer_Order__c == tos.Id) { wrap.isAvailableShipments = true;
                                                               if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++; 
                                                               if(Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isAccessible()) if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;                                           
                      wrap.TO = tos;
                      toWrapperList.add(wrap);
                } } else errorMsg = 'Sorry, no records available to view.';   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for searching TO's upon transferorder / warehouse.
    */        
    public PageReference searchTOs() {
        try {
            Set<Id> toIds = new Set<Id>();            
            toWrapperList = new List<Wrappers>();            
            toList = new List<Transfer_Order__c>();
            List<Package__c> pkgList = new List<Package__c>();
            toliList = new List<Transfer_Order_Line_Items__c>();
            List<Shipment__c> shipList = new List<Shipment__c>();  
            if(searchText != null && searchText != '') {
                String searchString = '%'+String.escapeSingleQuotes(searchText)+'%';
                if(Schema.sObjectType.Transfer_Order__c.isAccessible()) TOList = Database.query('select ' + String.escapeSingleQuotes(TOFields) + ' , From_Address__r.Address_Line1__c, From_Address__r.Address_Line2__c, From_Address__r.Address_Line3__c, From_Address__r.City__c, From_Address__r.County__c, From_Address__r.Country__c, From_Address__r.State__c, From_Address__r.Postal_Code__c, To_Address__r.Address_Line1__c, To_Address__r.Address_Line2__c, '+
                                                                                 +' To_Address__r.Address_Line3__c, To_Address__r.City__c, To_Address__r.County__c, To_Address__r.Country__c, To_Address__r.State__c, To_Address__r.Postal_Code__c from Transfer_Order__c where (Active__c = true And Status__c = \'Approved\' And (Name like: searchString OR From_Site__r.Name like: searchString OR TO_Site__r.Name like: searchString)) Limit 100');
            } else {
                if(Schema.sObjectType.Transfer_Order__c.isAccessible()) TOList = Database.query('select ' + String.escapeSingleQuotes(TOFields) + ' , From_Address__r.Address_Line1__c, From_Address__r.Address_Line2__c, From_Address__r.Address_Line3__c, From_Address__r.City__c, From_Address__r.County__c, From_Address__r.Country__c, From_Address__r.State__c, From_Address__r.Postal_Code__c, '+
                                                                                 +' To_Address__r.Address_Line1__c, To_Address__r.Address_Line2__c, To_Address__r.Address_Line3__c, To_Address__r.City__c, To_Address__r.County__c, To_Address__r.Country__c, To_Address__r.State__c, To_Address__r.Postal_Code__c from Transfer_Order__c where (Active__c = true And Status__c = \'Approved\') Limit 100');
            } for(Transfer_Order__c tos : TOList) { toIds.add(tos.Id); }
            if(toIds.size() > 0) { errorMsg = '';
                if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible()) toliList = Database.query('select ' + String.escapeSingleQuotes(TOLIFields) + ' from Transfer_Order_Line_Items__c where (Transfer_Order__c In : toIds)');
                if(Schema.sObjectType.Package__c.isAccessible()) pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Transfer_Order__c In: toIds)');
                if(Schema.sObjectType.Shipment__c.isAccessible()) shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Transfer_Order__c In: toIds)');
                for(Transfer_Order__c tos : TOList) { Wrappers wrap = new Wrappers(); 
                    for(Transfer_Order_Line_Items__c toli : toliList) { if(toli.Transfer_Order__c == tos.Id && toli.Picked_Quantity__c != toli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }                     
                    for(Package__c pkg : pkgList) { if(pkg.Transfer_Order__c == tos.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) { 
                        if(ship.Transfer_Order__c == tos.Id) { wrap.isAvailableShipments = true;
                                                               if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++; 
                                                               if(Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isAccessible()) if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;                                           
                      wrap.TO = tos;
                      toWrapperList.add(wrap);
                } } else errorMsg = 'Sorry, no records available to view.';   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating barcodes for selected WOLIs
    */
    public PageReference createBarcode() {
        try {                        
            Boolean error = false;
            toliIds = new List<Id>();
            PB = new PrintBarcodes();
            Set<Id> pIds = new Set<Id>();
            toliSelectedWrapperList = new List<Wrappers>();
            PB.BarcodeWrapperList = new List<PrintBarcodes.BarcodeWrapper>();           
            if(toliWrapperList.size() > 0) {
                for(Wrappers wrap : toliWrapperList) { if(wrap.toliSelected == true) { toliIds.add(wrap.toli.Id); pIds.add(wrap.toli.Products__c); toliSelectedWrapperList.add(wrap); } }
                if(toliSelectedWrapperList.size() > 0) { errorMsg = '';
                    List<Product2> prods = Database.query('select ' + String.escapeSingleQuotes(prodFields) +' from Product2 where Id In: pIds');    Map<Id, Product2> pMap = new Map<Id, Product2>(); for(Product2 prod: prods) { pMap.put(prod.Id, prod); }
                    
                    for(Wrappers wrap : toliSelectedWrapperList) { PrintBarcodes.BarcodeWrapper BW;  if(PB.LabelField != Null && PB.LabelField != '') BW = new PrintBarcodes.BarcodeWrapper(wrap.TOLI.Products__r.Barcode__c, wrap.TOLI.Products__r.Name, wrap.TOLI.Products__r.Name); else  BW = new PrintBarcodes.BarcodeWrapper(wrap.TOLI.Products__r.Barcode__c, '' , wrap.TOLI.Products__r.Name); BW.products = pMap.get(wrap.TOLI.Products__c); PB.BarcodeWrapperList.add(BW);
                    } 
                } else { errorMsg = 'Please select a line item to print barcode.'; } } else { errorMsg = 'Items have been picked, please proceed to packing.'; } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return Page.stockdispatching_TO_PrintPickProductsPDF;
    }
    
    /*
      method for redirecting for next tab.
    */
    public PageReference redirect2NextTab() {
        try {
            Boolean error = false;
            showSN = false;
            showBatch = false;
            Set<Id> toIds = new Set<Id>();
            Set<Id> proIds = new Set<Id>();
            Set<Id> assIds = new Set<Id>();
            barcodeLocMsg = barcodeLoc = '';
            SSLList = new List<Location__c>(); 
            toliWrapperList = new List<Wrappers>();
            binList = new List<StorageContainer__c>();
            //PPLIList2Delete = new List<Stock_Outward_Line_Item__c>();
            toSelectedWrapperList = new List<Wrappers>();
            
            
            if(toWrapperList.size() > 0) {
                toSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : toWrapperList) { 
                   if(sow.toSelected == true) { 
                        toIds.add(sow.TO.Id);
                        toSelectedWrapperList.add(sow);
                        if(transferorderId == sow.TO.Id) transferorderId = Null;
                   }
                   if(transferorderId == sow.TO.Id){ toSelectedWrapperList.add(sow); toIds.add(sow.TO.Id); } }} else {for(Wrappers sow : toSelectedWrapperList) {if(sow.toSelected == true) {toIds.add(sow.TO.Id); }
                } 
            } 
            
           
            if(toIds.size() > 0 && !error) { 
                errorMsg = '';
                Set<Id> BLSIds = new Set<Id>();
                Map<Id, Product2> productMap = new Map<Id, Product2>();
                Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>();
                
                toliList = Database.query('select ' + String.escapeSingleQuotes(TOLIFields) + ' ,Transfer_Order__r.Name, Transfer_Order__r.Requested_Date__c, From_Storage__r.Barcode__c, From_Location__r.Barcode__c, Transfer_Order__r.From_Site__r.Barcode__c, Products__r.Name, Transfer_Order__r.Organisation_Business_Unit__c, Products__r.Item_Description__c, Products__r.Special_Instructions__c, Products__r.ERP7__Is_Kit__c, Products__r.ERP7__Kit_Protected__c, Products__r.ERP7__Lot_Tracked__c, Products__r.Serialise__c, Asset__r.Name, Asset__r.Serialise__c, '+
                                                                                            +' Transfer_Order__r.Organisation__c, Products__r.Preview_Image__c, Products__r.Picture__c, Products__r.Weight__c, Products__r.Barcode__c, From_Site__r.Barcode__c from Transfer_Order_Line_Items__c where (Transfer_Order__c In : toIds) order by Transfer_Order__c ASC');                       
                
                for(Transfer_Order_Line_Items__c toli: toliList) { 
                    toliIds.add(toli.Id); 
                    if(toli.Products__c != Null) proIds.add(toli.Products__c);
                    if(toli.Asset__c != Null) assIds.add(toli.Asset__c);
                }
                
                productMap = new Map<Id, Product2>([Select Id, Name, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]);
                assetMap = new Map<Id, Asset__c>([Select Id, Name, Picture__c, Preview_Image__c, Status__c, Item_Description__c, Special_Instructions__c, Weight__c, Barcode__c From Asset__c Where Id In: assIds]);
                    
                Set<Id> WIISIds = new Set<Id>(); 
                for(ERP7__Stock_Outward_Line_Item__c ppli: Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ' from Stock_Outward_Line_Item__c where Transfer_Order_Line_Item__c In: toliIds')) { WIISIds.add(ppli.Site_Product_Service_Inventory_Stock__c);
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
                
                for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                    if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                        batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                        if(!stockBatches.containsKey(InwardLine.ERP7__Product__c)) { 
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            if(!InwardLine.ERP7__Product__r.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                            stockBatches.put(InwardLine.ERP7__Product__c, myBatches);}else{Set<SelectOption> myBatches = stockBatches.get(InwardLine.ERP7__Product__c);  myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); stockBatches.put(InwardLine.ERP7__Product__c, myBatches);
                        }
                        
                    }
                }
                
                for(Transfer_Order_Line_Items__c tolis : toliList) {
                    if(tolis.Products__c != Null){
                        if(!(tolis.Products__r.ERP7__Is_Kit__c && tolis.Explode__c)){
                            Wrappers swrap = new Wrappers(); 
                            swrap.product = productMap.get(tolis.Products__c);
                            swrap.TOLI = tolis; 
                            myStock = 0;  
                            
                            if(tolis.Picked_Quantity__c != null) {
                                if(tolis.Picked_Quantity__c == tolis.Quantity_requested__c) {swrap.raisedQty = Integer.valueof(tolis.Picked_Quantity__c);  swrap.remainingQty = Integer.valueof(tolis.Quantity_requested__c - swrap.raisedQty);
                                } else if(tolis.Picked_Quantity__c < tolis.Quantity_requested__c) {
                                    swrap.raisedQty = Integer.valueof(tolis.Picked_Quantity__c); 
                                    swrap.remainingQty = Integer.valueof(tolis.Quantity_requested__c - swrap.raisedQty);                                      
                                    swrap.requiredQty = Integer.valueof(tolis.Quantity_requested__c - swrap.raisedQty);                                      } } else {swrap.remainingQty = Integer.valueof(tolis.Quantity_requested__c); swrap.requiredQty = Integer.valueof(tolis.Quantity_requested__c);
                            }
                            
                            Set<SelectOption> options1 = new Set <SelectOption>(); 
                            Set<SelectOption> options2 = new Set <SelectOption>();
                            Set<SelectOption> options3 = new Set <SelectOption>(); 
                            Set<SelectOption> address = new Set <SelectOption>(); 
                            for(ERP7__Inventory_Stock__c wiis: WIISLists) {
                                if(wiis.Product__c == tolis.Products__c) {
                                    if(wiis.StorageContainer__c != null) {
                                        swrap.binName = swrap.AddressName = wiis.StorageContainer__c; 
                                        if(wiis.StorageContainer__r.Name != null) options3.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));
                                        if(wiis.StorageContainer__r.Barcode__c != null) { 
                                            address.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c));
                                            myStock += WIIS.Number_of_Item_In_Stock__c; } } else if(wiis.Location__c != null) { swrap.LN = wiis.Location__r.Name; swrap.LocationName = swrap.AddressName  = wiis.Location__c;if(wiis.Location__r.Name != null) options2.add(new SelectOption(wiis.Location__c, wiis.Location__r.Name)); if(wiis.Location__r.Barcode__c != null){address.add(new SelectOption(wiis.Location__c, wiis.Location__r.Barcode__c));  myStock += WIIS.Number_of_Item_In_Stock__c;
                                        }
                                    } else if(wiis.Warehouse__c != null) {swrap.WN = wiis.Warehouse__r.Name; swrap.WarehouseName = swrap.AddressName = wiis.Warehouse__c;if(wiis.Warehouse__r.Name != null) options1.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Name));  if(wiis.Warehouse__r.Barcode__c != null){address.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c));  myStock += WIIS.Number_of_Item_In_Stock__c;
                                        }
                                    }
                                    
                                    stockMap.put(wiis.Product__c, wiis.Id);
                                }
                            }
                            swrap.address.addAll(address);
                            swrap.CurrentWarehouses.addAll(options1); 
                            swrap.CurrentLocations.addAll(options2);    
                            swrap.CurrentBins.addAll(options3); 
                            swrap.inventoryStock = myStock;
                            
                            //swrap.address
                            // First AddressName and it's stock only .......
                            swrap.BatchLotCodes = new List <SelectOption>();   
                            if(stockBatches.ContainsKey(tolis.Products__c)) swrap.BatchLotCodes.addAll(stockBatches.get(tolis.Products__c)); 
                            if(swrap.BatchLotCodes.size() > 0 && tolis.ERP7__Products__r.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                            }
                            else swrap.BatchLotCode = '';
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);
                            
                            if(swrap.raisedQty != swrap.TOLI.Quantity_requested__c) {
                                if(swrap.TOLI.Products__r.Serialise__c){if(swrap.requiredQty > 0) swrap.requiredQty = 1; swrap.serialized = true;  showSN = true;
                                } 
                                
                                if(swrap.BatchLotCodes.size() > 0) showBatch = true;
                                toliWrapperList.add(swrap);
                            }
                            
                        } } else if(tolis.Asset__c != Null && !(tolis.Picked_Quantity__c > 0)){ Wrappers swrap = new Wrappers(); swrap.asset = assetMap.get(tolis.Asset__c); swrap.TOLI = tolis; myStock = 0; if(swrap.toli.Picked_Quantity__c != null) {  if(swrap.toli.Picked_Quantity__c == swrap.toli.Quantity_requested__c) { swrap.raisedQty = Integer.valueof(swrap.toli.Picked_Quantity__c); swrap.remainingQty = Integer.valueof(swrap.toli.Quantity_requested__c - swrap.raisedQty); } else if(swrap.toli.Picked_Quantity__c < swrap.toli.Quantity_requested__c) { swrap.raisedQty = Integer.valueof(swrap.toli.Picked_Quantity__c);  swrap.remainingQty = Integer.valueof(swrap.toli.Quantity_requested__c - swrap.raisedQty);  swrap.requiredQty = Integer.valueof(swrap.toli.Quantity_requested__c - swrap.raisedQty);
                                }
                            } else { swrap.requiredQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? Integer.valueof(swrap.toli.Quantity_requested__c) : 0; 
                                     swrap.remainingQty = (Schema.sObjectType.Stock_Outward_Line_Item__c.Fields.Quantity__c.isAccessible()) ? Integer.valueof(swrap.toli.Quantity_requested__c) : 0; 
                            }
                        
                            Set<SelectOption> options1 = new Set <SelectOption>();  Set<SelectOption> options2 = new Set <SelectOption>();Set<SelectOption> options3 = new Set <SelectOption>(); Set<SelectOption> address = new Set <SelectOption>(); 
                            for(ERP7__Inventory_Stock__c wiis: WIISLists) { if(wiis.Fixed_Asset__c == tolis.Asset__c) {if(wiis.StorageContainer__c != null) {swrap.binName = swrap.AddressName = wiis.StorageContainer__c; 
                                        if(wiis.StorageContainer__r.Name != null) options3.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));if(wiis.StorageContainer__r.Barcode__c != null) {  address.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                        }
                                    } else if(wiis.Location__c != null) {swrap.LN = wiis.Location__r.Name; swrap.LocationName = swrap.AddressName  = wiis.Location__c; if(wiis.Location__r.Name != null) options2.add(new SelectOption(wiis.Location__c, wiis.Location__r.Name));if(wiis.Location__r.Barcode__c != null){address.add(new SelectOption(wiis.Location__c, wiis.Location__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                        }
                                    } else if(wiis.Warehouse__c != null) {swrap.WN = wiis.Warehouse__r.Name; swrap.WarehouseName = swrap.AddressName = wiis.Warehouse__c; if(wiis.Warehouse__r.Name != null) options1.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Name));  if(wiis.Warehouse__r.Barcode__c != null){address.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;
                                        }
                                    }stockMap.put(wiis.Fixed_Asset__c, wiis.Id);
                                }
                            }
                            swrap.address.addAll(address); swrap.CurrentWarehouses.addAll(options1); swrap.CurrentLocations.addAll(options2);  swrap.CurrentBins.addAll(options3);  swrap.inventoryStock = myStock;
                            
                            //swrap.address
                            // First AddressName and it's stock only .......
                            swrap.BatchLotCodes = new List <SelectOption>();   if(stockBatches.ContainsKey(tolis.Products__c)) swrap.BatchLotCodes.addAll(stockBatches.get(tolis.Products__c)); if(swrap.BatchLotCodes.size() > 0 && tolis.Asset__r.ERP7__Lot_Tracked__c == true){swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());}else swrap.BatchLotCode = '';if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);
                            
                            if(swrap.raisedQty != swrap.toli.Quantity_requested__c) {if(swrap.toli.Asset__r.Serialise__c){ if(swrap.requiredQty > 0) swrap.requiredQty = 1; swrap.serialized = true; showSN = true; }  if(swrap.BatchLotCodes.size() > 0) showBatch = true; toliWrapperList.add(swrap);
                            }
                        }
                        
                }
                
                return page.stockdispatching_TO_Pick;} else errorMsg = 'Please select an order to proceed.';} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    public PageReference fetchBinStocks() {
        try {
            List<Wrappers> toliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(rowCounter != null) toliWrap = new List<Wrappers>(); toliWrap.add(toliWrapperList.get(rowCounter));  if(toliWrap != null) { if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label)); else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(toliWrap[0].addressName) + '\' And Active__c = true)'); }
                    
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label)); else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(toliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label)); else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(toliWrap[0].addressName) + '\' And Active__c = true)'); }
                          
                if(binList.size() > 0) {   if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } 
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                    
                    
                    
                     
                          
                    Decimal myStock = 0; if(toliWrap.size() > 0) {
                        Wrappers swrap = toliWrap[0];
                        
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) {   if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }   
                            
                            
                            
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();Set<SelectOption> myBatches = new Set<SelectOption>();if((!swrap.Product.ERP7__Lot_Tracked__c == true )) myBatches.add(new SelectOption('','--None--'));
                            
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){ if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);  myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                }
                            }
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  
                            else {swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.toli.Quantity_requested__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            }
                            swrap.inventoryStock = myStock;swrap.binName = swrap.addressName; swrap.locationName = binList[0].Location__c; swrap.warehouseName = binList[0].Site__c; swrap.WN = binList[0].Site__r.Name; swrap.LN = binList[0].Location__r.Name; swrap.BatchLotCodes = new List<SelectOption>();swrap.BatchLotCodes.addAll(myBatches);
                            if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                            }else swrap.BatchLotCode = '';
                    }
                    
                } else if(SSLList.size() > 0) {                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }

                    Decimal myStock = 0;        if(toliWrap.size() > 0) {
                        Wrappers swrap = toliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { 
                                if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }   
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                }
                            }
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  
                            else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.toli.Quantity_requested__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            swrap.inventoryStock = myStock; swrap.binName = null;swrap.locationName = SSLList[0].Id; swrap.warehouseName = SSLList[0].Site__c;swrap.WN = SSLList[0].Site__r.Name; swrap.LN = SSLList[0].Name;swrap.BatchLotCodes = new List<SelectOption>();swrap.BatchLotCodes.addAll(myBatches);
                            if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue();  swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                            }else swrap.BatchLotCode = '';
                        
                    }
                    
                } else if(siteList.size() > 0) {
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }

                    Decimal myStock = 0;        
                    if(toliWrap.size() > 0) {Wrappers swrap = toliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { 
                                if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                                }
                            } if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  
                            else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.toli.Quantity_requested__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            if(myStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = myStock+swrap.toli.Quantity_requested__c-swrap.raisedQty; 
                            else if(myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                            else swrap.inventoryStock = myStock; swrap.binName = null; swrap.locationName = null; swrap.warehouseName = siteList[0].Id; swrap.WN = siteList[0].Name; swrap.LN = ''; swrap.BatchLotCodes = new List<SelectOption>(); swrap.BatchLotCodes.addAll(myBatches);
                            if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                            } else swrap.BatchLotCode = '';
                        
                    }
                } 
            }                  
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    public PageReference fetchBatchStocks() {
        try {
            List<Wrappers> toliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(rowCounter != null) toliWrap = new List<Wrappers>(); toliWrap.add(toliWrapperList.get(rowCounter));
            if(toliWrap != null) {
                if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
                else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(toliWrap[0].addressName) + '\' And Active__c = true)'); }
                    
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
                else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(toliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
                else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(toliWrap[0].addressName) + '\' And Active__c = true)'); }
                          
                if(binList.size() > 0) {                  
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } 
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                    
                    
                    
                    Decimal myStock = 0;        
                    if(toliWrap.size() > 0) {
                        Wrappers swrap = toliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { 
                                if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }   
                            
                            
                            
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){
                                    batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);  myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                }
                            }
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            }else swrap.inventoryStock = myStock;
                            
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock); else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                            
                    }
                    
                } else if(SSLList.size() > 0) {                   
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }

                    Decimal myStock = 0;        
                    if(toliWrap.size() > 0) {Wrappers swrap = toliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { 
                                if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }   
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));
                                }
                            }
                            
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) {  swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            }else swrap.inventoryStock = myStock;
                            
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock); else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                        
                    } } else if(siteList.size() > 0) {
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }
                                    Decimal myStock = 0;        
                    if(toliWrap.size() > 0) { Wrappers swrap = toliWrap[0];

                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { 
                                if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                                if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);
                                }
                            }   
                            
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock); else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.toli.Quantity_requested__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            }else swrap.inventoryStock = myStock;
                            
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);  else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                            
                            if(swrap.inventoryStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = swrap.inventoryStock+swrap.toli.Quantity_requested__c-swrap.raisedQty; else if( myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                            
                    }
                } 
            }                  
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for updating transfer order line items for selected TOLI's.
    */    
    public PageReference saveTOLIs() {
        try {
            Boolean error = false;
            Set<Id> toIds = new Set<Id>();
            List<Id> assetIds = new List<Id>();
            toliSelectedWrapperList = new List<Wrappers>();
            SDLIList = new List<Stock_Outward_Line_Item__c>(); 
            
            if(toliWrapperList.size() > 0) {          
                for(Wrappers wrap : toliWrapperList) { if(wrap.toliSelected == true) { if(wrap.TOLI.Asset__c != Null){ assetIds.add(wrap.TOLI.Asset__c); }  toIds.add(wrap.toli.Transfer_Order__c); toliSelectedWrapperList.add(wrap); } }
                if(toliSelectedWrapperList.size() > 0) {
                    errorMsg = '';   
                    for(Wrappers wrap : toliSelectedWrapperList) {
                        if(wrap.inventoryStock == 0) { errorMsg = 'Sorry, no available inventory for the selected item to proceed.'; error = true; break; } 
                        else if(wrap.requiredQty > wrap.inventoryStock) { errorMsg = 'Quantity cannot be greater than available stock.'; error = true; break; } 
                        else if(wrap.requiredQty > wrap.remainingQty) { errorMsg = 'Quantity cannot be greater than remaining Quantity.'; error = true; break; }
                        else if(wrap.serialized && (wrap.SerialNumbers.Serial__c == '' || wrap.SerialNumbers.Serial__c == Null)) { errorMsg = 'Required field missing - Serial Number'; error = true; break; }
                    }
                    if(!error) {
                        MAP<Id, Transfer_Order_Line_Items__c> toliMap = new MAP<Id, Transfer_Order_Line_Items__c>();
                        MAP<Id, Asset__c> assetMap = new MAP<Id, Asset__c>([Select Id, Name, Active__c, Barcode__c, Status__c From Asset__c Where Id In :assetIds]);
                        
                        for(Wrappers wrap : toliSelectedWrapperList) {
                            Stock_Outward_Line_Item__c sdlis = new Stock_Outward_Line_Item__c();
                            
                            // creating new stock outward line items
                            if(wrap.toli.Name != null) sdlis.Name = 'STOLI-'+wrap.toli.Name;
                            if(wrap.TOLI.Products__c != Null){ if(stockMap.get(wrap.toli.Products__c) != null) sdlis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.toli.Products__c); sdlis.Product__c = wrap.toli.Products__c;
                            }
                            else if(wrap.TOLI.Asset__c != Null){ sdlis.Fixed_Asset__c = wrap.TOLI.Asset__c; if(stockMap.get(wrap.toli.Asset__c) != null) sdlis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.toli.Asset__c);
                            }
                            if(wrap.requiredQty != null) sdlis.Quantity__c = wrap.requiredQty;
                            if(wrap.requiredQty != null) sdlis.Picked_Quantity__c = wrap.requiredQty;
                            if(wrap.toli.Transfer_Order__c != null) sdlis.Transfer_Order__c = wrap.toli.Transfer_Order__c;
                            sdlis.Transfer_Order_Line_Item__c = wrap.toli.Id;
                            sdlis.Picked_Date__c = System.Now();
                            sdlis.Status__c = 'Committed';
                            sdlis.Active__c = true;              
                            orderNumber = wrap.toli.Transfer_Order__r.Name;
                            if(wrap.SerialNumbers.Serial__c != null) sdlis.Serial__c = wrap.SerialNumbers.Serial__c;
                            if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') sdlis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;
                            
                            if(wrap.toli.Picked_Quantity__c == null) wrap.toli.Picked_Quantity__c = wrap.requiredQty; else wrap.toli.Picked_Quantity__c += wrap.requiredQty;
                            
                            toliMap.put(wrap.TOLI.Id, wrap.TOLI);
                            SDLIList.add(sdlis); 
                        }    
                        if(SDLIList.size() > 0) { 
                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()) { DMLManager.UpsertAsUser(SDLIList);} else{/*no access*/ } if(Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) { upsert toliMap.Values();} else{ /*no access*/ } return redirect2NextTab();
                        }          
                    }  } } else errorMsg = 'Please select a line item to save.'; 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));  }        
        return null;
    }
    
    /*
      method for creating a new package / displaying the existing created packages.      
    */
    public PageReference createPacks() {
        try {
            Set<Id> toIds = new Set<Id>();
            
            if(toWrapperList.size() > 0) {
                toSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : toWrapperList) { 
                   if(sow.toSelected == true) { 
                        toIds.add(sow.TO.Id);
                        toSelectedWrapperList.add(sow);
                        if(transferorderId == sow.TO.Id) transferorderId = Null;
                   }
                   if(transferorderId == sow.TO.Id){ toSelectedWrapperList.add(sow); toIds.add(sow.TO.Id);}
                } } else {for(Wrappers sow : toSelectedWrapperList) {if(sow.toSelected == true) {toIds.add(sow.TO.Id);
                    }
                } 
            } 
            
            if(toIds.size() > 0) {
                toliWrapperList = new List<Wrappers>();
                toliList = new List<Transfer_Order_Line_Items__c>();
                if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible()) { 
                    toliList = Database.query('select ' + String.escapeSingleQuotes(TOLIFields) + ' ,Transfer_Order__r.Name, Transfer_Order__r.Requested_Date__c, From_Storage__r.Barcode__c, From_Location__r.Barcode__c, Transfer_Order__r.From_Site__r.Barcode__c, '+
                                                                                                +' Products__r.Name, Products__r.Preview_Image__c, Products__r.Picture__c, Products__r.Weight__c, Products__r.Barcode__c, Asset__r.Name, ERP7__Products__r.Item_Type__c, Products__r.ERP7__Is_Kit__c, ERP7__Products__r.SKU__c from Transfer_Order_Line_Items__c where (Transfer_Order__c In : toIds) order by Transfer_Order__c ASC'); 
                }
                for(Transfer_Order_Line_Items__c tolis : toliList) {
                    if(tolis.Packed_Quantity__c != tolis.Picked_Quantity__c && tolis.Picked_Quantity__c <= tolis.Quantity_requested__c) {
                        Wrappers swrap = new Wrappers(); 
                        swrap.TOLI = tolis;
                        swrap.isTOLIawaiting = true;
                        if(Schema.sObjectType.Transfer_Order__c.isAccessible() && Schema.sObjectType.Transfer_Order__c.fields.Name.isAccessible()) orderNumber = tolis.Transfer_Order__r.Name;
                        toliWrapperList.add(swrap);
                    }                                            
                }
                if(Schema.sObjectType.Package__c.isAccessible()) { Packages = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Transfer_Order__r.Name, Shipment__r.Name, Shipment__r.Shipment_Date__c, '+
                                                                              +' Shipment__r.Status__c from Package__c where (Active__c = true And Transfer_Order__c In: toIds) Order by Shipment__r.Name, CreatedDate Asc');                       
                } packMap = new Map <Id, Package__c>(Packages); 
                                
                if(Packages.size() > 0 && toliWrapperList.size() > 0) { createPack = true; isAwaiting = true; } else if(Packages.size() > 0) { createPack = false; isAwaiting = true; } else if(toliWrapperList.size() > 0) { createPack = true; isAwaiting = false; }
                
                Set<Id> pkgIds = new Set<Id>();
                if(Packages.size() > 0) { for(Package__c pack: Packages) { pkgIds.add(pack.Id); } }   
                ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');    
                if(Schema.sObjectType.Shipment__c.isAccessible()) Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where (Package__c In: pkgIds And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');
                                                                              
                if(Schema.sObjectType.Package_List__c.isAccessible()) packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c In: pkgIds And Active__c = true) Order by CreatedDate Asc');
                
                //*****************************************************************            
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { lineItemWrapper LW = new lineItemWrapper();  LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm'; else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        if(Schema.sObjectType.Package__c.fields.Package_Quantity__c.isAccessible()) LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }
                
                // ****************************************************************         
                    Package2Create = new Package__c();    
                    if(toIds.size() > 0) Package2Create.Transfer_Order__c = (new list<Id>(toIds))[0];                                
                    if(Schema.sObjectType.Package__c.fields.Weight__c.isAccessible()) Package2Create.Weight__c = 0;
                    if(Schema.sObjectType.Package__c.fields.Declared_Value__c.isAccessible()) Package2Create.Declared_Value__c = 0;                            
                    packageWrapperList = new List<packageWrapper>();
                    Package2Create.Status__c = 'Deposited To Front Desk';
                    if(Packages != null) Package2Create.Name = Package2Create.Barcode__c = Package2Create.Description__c = Package2Create.Name__c = 'TO-Package-'+ Integer.valueof(Packages.size()+1);                    
                    for(Wrappers wrap : toliWrapperList) { 
                        if(wrap.isTOLIawaiting == true) {
                            packageWrapper PW = new packageWrapper();                            
                            PW.pkgSelected = true;
                            PW.Toli = wrap.toli;
                            PW.qtyToPick = wrap.Toli.Picked_Quantity__c;
                            if(wrap.Toli.Picked_Quantity__c != null && wrap.Toli.Packed_Quantity__c != null) PW.qtyToPack = wrap.Toli.Picked_Quantity__c - wrap.Toli.Packed_Quantity__c; else PW.qtyToPack = wrap.Toli.Picked_Quantity__c;
                            
                            if(PW.Toli.Products__r.Weight__c != null) Package2Create.Weight__c += (PW.toli.Products__r.Weight__c * PW.qtyToPack);
                                                                             
                            if(PW.qtyToPack != 0) packageWrapperList.add(PW);
                        }
                    } return Page.stockdispatching_TO_Package; } else errorMsg = 'Please select an order to proceed.';   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }     return null;
    }
    
    /*
      method for re-evaluating the package weight and declared value.
    */
    public PageReference evaluatePackDetails() {
        try {
            errorMsg2 = '';
            Package2Create.Weight__c = Package2Create.Declared_Value__c = 0;
            for(packageWrapper PW : packageWrapperList) { if(PW.toli.Products__r.Weight__c != null) Package2Create.Weight__c += (PW.toli.Products__r.Weight__c * PW.qtyToPack); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'  Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for pre-populating package details from custom settings.
    */
    public PageReference populatePackDetails() {
        try { 
           List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
            if(pkgTypeValue != null && pkgTypeValue != '--None--') {
                if(Schema.sObjectType.Package_Details__c.isAccessible())
                pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\') Limit 1'); 
                if(pkgDetailList.size() > 0) {
                    if(Schema.sObjectType.Package_Details__c.fields.Length__c.isAccessible()) Package2Create.Length__c = pkgDetailList[pkgDetailList.size() - 1].Length__c;
                    if(Schema.sObjectType.Package_Details__c.fields.Width__c.isAccessible()) Package2Create.Width__c = pkgDetailList[pkgDetailList.size() - 1].Width__c;            
                    if(Schema.sObjectType.Package_Details__c.fields.Height__c.isAccessible()) Package2Create.Height__c = pkgDetailList[pkgDetailList.size() - 1].Height__c;
                    if(Schema.sObjectType.Package_Details__c.fields.Weight_Unit__c.isAccessible()) Package2Create.Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].Weight_Unit__c;
                    if(Schema.sObjectType.Package__c.fields.Shipment_Type__c.isAccessible()) Package2Create.Shipment_Type__c = 'UPS';            
                } } else errorMsg2 = 'Sorry, selected package type not available.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for updating package details.
    */
    public PageReference updatePacks() {
        try {
            Boolean error = false; 
            if(packageWrapperList != null) { List<Package_List__c> PLS = new List<Package_List__c>();
                MAP<Id, Transfer_Order_Line_Items__c> toliMap = new MAP<Id, Transfer_Order_Line_Items__c>();
                for(packageWrapper pw: packageWrapperList) {
                    if(pw.qtyToPack > pw.qtyToPick && pw.pkgSelected == true) { errorMsg2 = 'Packed quantity cannot be greater than picked Quantity.'; error = true; break; }
                }
                if(!error) { Package2Create.Active__c = true;
                            if(Package2Create != null) { if(Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()) { DMLManager.upsertAsUser(Package2Create);} else{ /*no access*/ } } 
                    for(Integer i=1; i<=packageWrapperList.size(); i++) {
                        if(packageWrapperList[i-1].pkgSelected == true) { Package_List__c packageList = new Package_List__c();                            
                                                                          packageList.Name = 'Package List - '+i;
                                                                          packageList.Active__c = true;
                                                                          packageList.Package__c = Package2Create.Id;
                                                                          packageList.Quantity__c = packageWrapperList[i-1].qtyToPack;
                                                                          packageList.Transfer_Order__c = packageWrapperList[i-1].toli.Transfer_Order__c;
                                                                          packageList.Transfer_Order_Line_Item__c = packageWrapperList[i-1].toli.Id;
                                                                          if(packageWrapperList[i-1].toli.Packed_Quantity__c == null) packageWrapperList[i-1].toli.Packed_Quantity__c = packageWrapperList[i-1].qtyToPack;
                                                                          else packageWrapperList[i-1].toli.Packed_Quantity__c += packageWrapperList[i-1].qtyToPack;
                                                                            
                                                                          toliMap.put(packageWrapperList[i-1].toli.Id, packageWrapperList[i-1].toli);
                                                                          PLS.add(packageList);
                        }
                    }
                    if(PLS.size() > 0) {
                        if(Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()) { DMLManager.UpsertAsUser(PLS); } else{ /*no access*/ }
                        if(Schema.sObjectType.MRP__c.isCreateable() && Schema.sObjectType.MRP__c.isUpdateable()) { DMLManager.UpsertAsUser(toliMap.Values()); } else{ /*no access*/ }
                    } createPacks(); } } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }        
    
    /*
      method for updating the details of created packages and package list
    */
    public PageReference editPackage() {
        try {
            Set<Id> toIds = new Set<Id>();
            Packages = new List<Package__c>();
            currentItems = new List<Transfer_Order_Line_Items__c>();        
            if(pack2updateId != null) {
                if(Schema.sObjectType.Package__c.isAccessible()) Package2Create = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Shipment__r.Name from Package__c where (Id =\'' + String.escapeSingleQuotes(pack2updateId) + '\')');  
                packMap = new Map <Id, Package__c>(Packages); 
                
                if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible()) currentItems = Database.query('select ' + String.escapeSingleQuotes(TOLIFields) + ' ,Transfer_Order__r.Name, Transfer_Order__r.Ship_Date__c, Products__r.Name, Asset__r.Name, Products__r.Preview_Image__c, '+
                                                                                                  +' Products__r.Picture__c from Transfer_Order_Line_Items__c where (Transfer_Order__c =\'' + String.escapeSingleQuotes(Package2Create.Transfer_Order__c) + '\') order by Transfer_Order__c ASC');                       
                                                                                                  
                if(Schema.sObjectType.Package_List__c.isAccessible()) packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(Package2Create.Id) + '\' And Active__c = true) Order by CreatedDate Asc');
                            
                //*****************************************************************            
                    if(Package2Create != null) Packages.add(Package2Create);
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { lineItemWrapper LW = new lineItemWrapper();  LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm'; else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        if(Schema.sObjectType.Package__c.fields.Package_Quantity__c.isAccessible()) LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }        
                    
                // ****************************************************************            
                    packageWrapperList = new List<packageWrapper>();                                
                    for(Transfer_Order_Line_Items__c toli : currentItems){
                        packageWrapper PW = new packageWrapper();
                        List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                        for(Package_List__c pl : packageLists){
                           if(pl.Transfer_Order_Line_Item__c == toli.Id) {
                                PW.toli = toli;
                                PW.qtyToPick = pl.Quantity__c;
                                if(Schema.sObjectType.Package_List__c.fields.Quantity__c.isAccessible()) PW.qtyToPack = pl.Quantity__c;                                
                                innerPackageWrapper ipw = new innerPackageWrapper();
                                if(Schema.sObjectType.Package_List__c.fields.Package__c.isAccessible()) ipw.pack = String.valueof(pl.Package__c);
                                if(Schema.sObjectType.Package_List__c.fields.Package__c.isAccessible()) ipw.packege = packMap.get(pl.Package__c);
                                ipw.packageList = pl;
                                
                                ipw.packList.add(new SelectOption('','--None--'));
                                if(ipw.packege.Status__c == 'Shipped' || ipw.packege.Status__c == 'Picked Up' || ipw.packege.Status__c == 'Delivered') if(Schema.sObjectType.Package__c.isAccessible() && Schema.sObjectType.Package__c.fields.Name__c.isAccessible()) ipw.packList.add(new SelectOption(String.valueof(ipw.packege.Id),ipw.packege.Name__c)); 
                                
                                for(Package__c P : Packages){
                                    if((P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') && (ipw.packege.Status__c != 'Shipped' && ipw.packege.Status__c != 'Picked Up' && ipw.packege.Status__c != 'Delivered'))
                                    if(Schema.sObjectType.Package__c.isAccessible() && Schema.sObjectType.Package__c.fields.Name__c.isAccessible()) ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c));  
                                } ipwList.add(ipw);
                            }
                        } 
                        if(ipwList.size() > 0) { PW.innerPackList = ipwList; packageWrapperList.add(PW); }
                    } CreatePack = true; isAwaiting = false; } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for deleting created packages
    */
    public PageReference deletePackage() {
        try {
            Set<Id> woliIds = new Set<Id>();
            MAP<Id, Transfer_Order_Line_Items__c> toliMap = new MAP<Id, Transfer_Order_Line_Items__c>();
            if(pack2updateId != null) { 
                List<Package_List__c> packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Transfer_Order_Line_Item__r.Packed_Quantity__c from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack2updateId) + '\' And Active__c = true) Order by CreatedDate Asc');
                for(Package_List__c pls: packList) { toliIds.add(pls.Transfer_Order_Line_Item__c); }
                List<Transfer_Order_Line_Items__c> toliList = Database.query('select ' + String.escapeSingleQuotes(TOLIFields) + ' from Transfer_Order_Line_Items__c where Id In: toliIds');                
                for(Package_List__c pl: packList) {
                    for(Transfer_Order_Line_Items__c tolis: toliList) {
                        if(pl.Transfer_Order_Line_Item__c == tolis.Id) {
                            if(tolis.Packed_Quantity__c != null) {
                                tolis.Packed_Quantity__c = tolis.Packed_Quantity__c - pl.Quantity__c;
                                toliMap.put(tolis.Id, tolis);
                            } break;
                        }
                    }
                }
            }
            if(toliMap.size() > 0 && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Packed_Quantity__c.isCreateable() && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Packed_Quantity__c.isUpdateable()){ upsert toliMap.values(); } else { /* no access*/ }
            if(pack2updateId != null){ if(Package__c.sObjectType.getDescribe().isDeletable()) { delete new Package__c(Id = pack2updateId);} else{ /* no access*/ } }
            createPacks();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for displaying available shipment list from the system.
    */
    public PageReference createShipments() {
        try {
            Set<Id> toIds = new Set<Id>();
            shipmentList = new List<Shipment__c>();
            shipmentWrapperList = new List<Wrappers>();
            
            if(toWrapperList.size() > 0) {
                toSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : toWrapperList) { 
                   if(sow.toSelected == true) { 
                        toIds.add(sow.TO.Id);
                        toSelectedWrapperList.add(sow);
                        if(transferorderId == sow.TO.Id) transferorderId = Null;
                   }
                   if(transferorderId == sow.TO.Id){ toSelectedWrapperList.add(sow); toIds.add(sow.TO.Id);}
                } } else { for(Wrappers sow : toSelectedWrapperList) {  if(sow.toSelected == true) { toIds.add(sow.TO.Id); }
                } 
            }             
            
            if(toIds.size() > 0) {
                if(Schema.sObjectType.Shipment__c.isAccessible()) shipmentList = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' ,RecordType.Name, Transfer_Order__r.Name, Shipping_Address__r.Customer__r.Name, Shipping_Address__r.Address_Line1__c, Shipping_Address__r.Address_Line2__c, Shipping_Address__r.Address_Line3__c, Shipping_Address__r.City__c, Shipping_Address__r.County__c, '+
                                                                                 +' Shipping_Address__r.Country__c, Shipping_Address__r.Contact__r.Phone, Shipping_Address__r.Contact__r.Fax, Shipping_Address__r.Contact__r.Name, Shipping_Address__r.Contact__r.Email, Shipping_Address__r.State__c, Shipping_Address__r.Postal_Code__c from Shipment__c where (Transfer_Order__c In: toIds And Active__c = true) Order by CreatedDate Asc');
                for(Shipment__c shp: shipmentList) { Wrappers wrap = new Wrappers();                    
                                                     wrap.shipM = shp;
                                                     if(wrap.shipM.RecordType.Name == 'UPS Shipping') wrap.shipmentType = 'UPS'; else if(wrap.shipM.RecordType.Name == 'Internal Shipping') wrap.shipmentType = 'Shipment';
                                                     if(shp.ERP7__TrackingNumber__c != null) if(Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isAccessible()) wrap.trackingNo += shp.ERP7__TrackingNumber__c.replace(',','<br/>');
                                                     shipmentWrapperList.add(wrap);
                } return page.stockdispatching_TO_Shipment;} else errorMsg = 'Please select an order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    } 
    
    /*
      method for deleting shipment.
    */
    public PageReference deleteShipment() {
        try {
            if(packageId != null) shipmentWrapperList.remove(Integer.valueof(packageId));
            if(shipmentId != null &&  Shipment__c.sObjectType.getDescribe().isDeletable()) { DMLManager.deleteAsUser(new Shipment__c(Id = shipmentId));} else{ /* no acces */ } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for create transfer order.
    */
    public PageReference createTOs() {
        try {
            TO = new Transfer_Order__c(Status__c='Approved');        
            return Page.stockdispatching_TO_CreateTransferOrder;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'  Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for adding more TOLI rows
    */
    public PageReference addToliWrapperRows() {
        try {
            for(Integer i=0; i<addRow; i++) { tolisWrapperList.add(new newWrapper(nextIdent++)); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting TOLI rows
    */
    public PageReference delToliWrapperRow() {
        try {
            if(toDelIdent != null) tolisWrapperList.remove(toDelIdent);  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for saving TO details
    */
    public PageReference saveTO() {
        try {
            if(TO != null && Schema.sObjectType.Transfer_Order__c.isCreateable() && Schema.sObjectType.Transfer_Order__c.isUpdateable()) {  upsert TO; } else{ /* no acces*/ }
            Toliss = new List<Transfer_Order_Line_Items__c>(); 
            for(newWrapper nwrp: tolisWrapperList) { Transfer_Order_Line_Items__c toli = new Transfer_Order_Line_Items__c();                
                                                     toli = nwrp.tolis;
                                                     toli.Transfer_Order__c = TO.Id;
                                                     Toliss.add(toli);
            } if(Toliss.size() > 0 && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Transfer_Order__c.isUpdateable()){ hasAccess=true; upsert Toliss; }    else{ hasAccess=false; errormsg3='You are not allowed to create or update records'; }
            return Page.stockdispatching_TransferOrder; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
        
    /*
      method for generating picking slip(collection of selected TOLI's) as pdf
    */    
    public PageReference createPickingSlips() {
        String transId;
        try {
            toliSelectedWrapperList = new List<Wrappers>();
            for(Wrappers wrap : toliWrapperList) { transId = wrap.toli.Transfer_Order__c;  if(wrap.toliSelected == true) toliSelectedWrapperList.add(wrap); }
            TO = [Select Id, Name, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__Contact__r.Phone, ERP7__Customer__c, ERP7__Customer__r.Name, ERP7__From_Address__c,
                 ERP7__From_Address__r.ERP7__Address_Line1__c, ERP7__From_Address__r.ERP7__Address_Line2__c, ERP7__From_Address__r.ERP7__Address_Line3__c, 
                 ERP7__From_Address__r.ERP7__City__c, ERP7__From_Address__r.ERP7__Country__c, ERP7__From_Address__r.ERP7__Postal_Code__c,
                 ERP7__Customer__r.ERP7__Company__c, ERP7__To_Address__c, ERP7__To_Address__r.ERP7__Address_Line1__c, ERP7__To_Address__r.ERP7__Address_Line2__c,
                 ERP7__To_Address__r.ERP7__Address_Line3__c, ERP7__To_Address__r.ERP7__City__c, ERP7__To_Address__r.ERP7__Country__c, ERP7__To_Address__r.ERP7__Postal_Code__c
                 From ERP7__Transfer_Order__c where Id=:transId];
            return page.stockdispatching_TO_PickingSlips;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for generating packing label as pdf
    */
    public PageReference createPackingLabels() {
        try {
            String contactId, newPackageId;
            Set<Id> pkgIds = new Set<Id>();
            packageRecords = new Map<Package__c, List<Package_List__c>>();                    
            if(packageId != null && packageId != '') pkgIds.add(packageId);
            for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) pkgIds.add(lw.pack.Id); } 
            if(pkgIds.size() > 0) {         
                for(Package__c p : [select Name, Transfer_Order__r.Contact__c, Transfer_Order__r.Customer__r.Name, Barcode__c, Name__c, Owner.Name, CreatedDate, Weight__c, Transfer_Order__r.To_Address__r.Customer__r.Name,Transfer_Order__r.To_Address__r.Address_Line1__c, Transfer_Order__r.To_Address__r.Address_Line2__c, Transfer_Order__r.To_Address__r.Address_Line3__c,
                                   Transfer_Order__r.To_Address__r.City__c, Transfer_Order__r.To_Address__r.County__c, Transfer_Order__r.To_Address__r.Country__c, Transfer_Order__r.To_Address__r.Contact__r.Phone,Transfer_Order__r.To_Address__r.Contact__r.Fax, Transfer_Order__r.To_Address__r.Contact__r.Name, Transfer_Order__r.To_Address__r.Contact__r.Email, 
                                   Transfer_Order__r.To_Address__r.State__c,Transfer_Order__r.To_Address__r.Postal_Code__c, (Select Id, Name, Active__c, Package__c, Package__r.Name,  Quantity__c, Transfer_Order_Line_Item__c, Package__r.Transfer_Order__c, Transfer_Order_Line_Item__r.Products__r.SKU__c, Transfer_Order_Line_Item__r.Products__r.Name, 
                                   Transfer_Order_Line_Item__r.Quantity_received__c, Transfer_Order_Line_Item__r.Transfer_Order__r.Name, Transfer_Order_Line_Item__r.Quantity_requested__c, Transfer_Order_Line_Item__r.Name, SKU__c, Package_Weight__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {
                     packListRecords = new List<Package_List__c>();for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); } packageRecords.put(p,packListRecords); contactId = p.Transfer_Order__r.Contact__c; newPackageId = p.Id;
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});  Database.rollback(sp);  return page.stockdispatching_TO_PackingSlips;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }    
        return null;
    }
    
    /*
      method for generating packing slip(collection of selected package list) as pdf
    */
    public PageReference createPackingSlips() {
        try {
            String contactId, newPackageId;
            Set<Id> pkgIds = new Set<Id>();
            packageRecords = new Map<Package__c, List<Package_List__c>>();                    
            if(packageId != null && packageId != '') pkgIds.add(packageId);
            for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) pkgIds.add(lw.pack.Id); } 
            if(pkgIds.size() > 0) {         
                for(Package__c p : [select Name, Transfer_Order__r.Contact__c, Transfer_Order__r.Customer__r.Name, Barcode__c, Name__c, Owner.Name, CreatedDate, Weight__c, Transfer_Order__r.To_Address__r.Customer__r.Name,Transfer_Order__r.To_Address__r.Address_Line1__c, Transfer_Order__r.To_Address__r.Address_Line2__c, Transfer_Order__r.To_Address__r.Address_Line3__c, 
                                   Transfer_Order__r.To_Address__r.City__c, Transfer_Order__r.To_Address__r.County__c, Transfer_Order__r.To_Address__r.Country__c, Transfer_Order__r.To_Address__r.Contact__r.Phone,Transfer_Order__r.To_Address__r.Contact__r.Fax,Transfer_Order__r.To_Address__r.Contact__r.Name, Transfer_Order__r.To_Address__r.Contact__r.Email, 
                                   Transfer_Order__r.To_Address__r.State__c,Transfer_Order__r.To_Address__r.Postal_Code__c, (Select Id, Name, Active__c, Package__c, Package__r.Name,  Quantity__c, Transfer_Order_Line_Item__c,Package__r.Transfer_Order__c, Transfer_Order_Line_Item__r.Products__r.SKU__c, Transfer_Order_Line_Item__r.Products__r.Name, 
                                   Transfer_Order_Line_Item__r.Quantity_received__c, Transfer_Order_Line_Item__r.Transfer_Order__r.Name, Transfer_Order_Line_Item__r.Quantity_requested__c, Transfer_Order_Line_Item__r.Name, SKU__c, Package_Weight__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {  packListRecords = new List<Package_List__c>(); for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); }packageRecords.put(p,packListRecords); contactId = p.Transfer_Order__r.Contact__c; newPackageId = p.Id;
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
                Database.rollback(sp); return page.stockdispatching_TO_PackingLists;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for generating shipping slips as pdf to print
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
                List<Package_List__c> packageItemList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Transfer_Order_Line_Item__r.Products__r.SKU__c, Transfer_Order_Line_Item__r.Products__r.Name, Transfer_Order_Line_Item__r.Transfer_Order__r.Name, '+
                                                        +' Transfer_Order_Line_Item__r.Name, Transfer_Order_Line_Item__r.Quantity_received__c,  Package__r.Shipment__c, Package__r.Name from Package_List__c where Package__c In: pkgIds'); 
                for(Shipment__c sh: shipList) { List<Package_List__c> pkgItemList = new List<Package_List__c>();
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});   Database.rollback(sp); return page.stockdispatching_TO_ShippingSlips;    
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    
    public pageReference scannerMethod() {
        try { 
            if(Schema.sObjectType.Transfer_Order__c.isAccessible()) toList = Database.query('select ' + String.escapeSingleQuotes(TOFields) + ' , From_Address__r.Address_Line1__c, From_Address__r.Address_Line2__c, From_Address__r.Address_Line3__c, From_Address__r.City__c, From_Address__r.County__c, From_Address__r.Country__c, From_Address__r.State__c, From_Address__r.Postal_Code__c, '+
                                                                             +' To_Address__r.Address_Line1__c, To_Address__r.Address_Line2__c, To_Address__r.Address_Line3__c, To_Address__r.City__c, To_Address__r.County__c, To_Address__r.Country__c, To_Address__r.State__c, To_Address__r.Postal_Code__c from Transfer_Order__c where (Active__c = true And Status__c = \'Approved\') Limit 100');
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }    
    public pageReference scannerMethodCustom() {
        try {
            errorMsg = barcodeLocMsg = '';
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); }
            else if(mybarcode == 'PICK') { return redirect2NextTab(); }
            else if(mybarcode == 'PACK') { return saveTOLIs(); }
            else if(mybarcode == 'SHIP') { createShipments(); }
            
            List<Site__c> siteList = new List<Site__c>();    
            List<Transfer_Order_Line_Items__c> toliListcheck;        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(Schema.sObjectType.Site__c.isAccessible()) siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.Location__c.isAccessible()) SSLList = [Select Id, Name, Barcode__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.StorageContainer__c.isAccessible()) binList = [Select Id, Name, Barcode__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];                         
            if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible()) toliListcheck = [select Id, Name, Barcode__c, Products__c, Products__r.Barcode__c from Transfer_Order_Line_Items__c where Barcode__c =:barcode.trim() Or Products__r.Barcode__c =:barcode.trim() limit 1];
            
            if(toliListcheck.size() > 0 && barcodeLoc != '' && barcodeLoc != Null){ for(Wrappers W : toliWrapperList){if(!W.toliSelected && W.AddressName==barcodeLoc && (barcode.trim() == W.toli.Barcode__c || barcode.trim() == W.toli.Products__r.Barcode__c)){ barcodeLoc = barcodeLocMsg = ''; W.toliSelected = true; return null;
                    }             
                }
            }              
            for(Wrappers W : toliWrapperList){
                if(!W.toliSelected && ((siteList.size()>0 && W.AddressName == siteList[0].Id) || (SSLList.size()>0 && W.AddressName == SSLList[0].Id) || (binList.size()>0 && W.AddressName == binList[0].Id))) {   barcodeLocMsg = barcodeLoc = ''; integer wCount = 0; String addrs = W.AddressName; for(Wrappers WA : toliWrapperList){ if(addrs == WA.AddressName) wCount+=1; } if(wCount == 1) W.toliSelected = true;  else if(wCount > 1) {   barcodeLocMsg = 'There are multiple products in the stock '; if(siteList.size() > 0) if(Schema.sObjectType.Site__c.fields.Barcode__c.isAccessible()) barcodeLocMsg = barcodeLocMsg+'"'+siteList[0].Barcode__c+'"'+' please scan the product to pick.';  else if(SSLList.size() > 0) if(Schema.sObjectType.Site__c.fields.Barcode__c.isAccessible()) barcodeLocMsg = barcodeLocMsg+'"'+SSLList[0].Barcode__c+'"'+' please scan the product to pick.'; else if(binList.size() > 0)  if(Schema.sObjectType.Site__c.fields.Barcode__c.isAccessible()) barcodeLocMsg = barcodeLocMsg+'"'+binList[0].Barcode__c+'"'+' please scan the product to pick.';  barcodeLoc = W.AddressName;} break;
                }             
            }
            if(TOList.size() > 0) { toWrapperList = new List<Wrappers>();
                for(Transfer_Order__c tos : TOList) { Wrappers wrap = new Wrappers();
                                                      wrap.toSelected = true;
                                                      wrap.TO = tos;
                                                      toWrapperList.add(wrap);
                }    
            } if(barcodeLocMsg == '') saveTOLIs();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }    
    public pageReference scannerMethodCustomPick() {
        try {
            errorMsg = '';
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); }
            else if(mybarcode == 'PICK') { return redirect2NextTab(); }
            else if(mybarcode == 'PACK') { return createPacks(); }
            else if(mybarcode == 'SHIP') { createShipments(); }
            
            if(TOList.size() > 0) {
                if(initialScan != true) { initialScan = true; toWrapperList = new List<Wrappers>(); }
                for(Transfer_Order__c tos : TOList) { boolean exist = false;
                    for(Wrappers w : toWrapperList) { if(tos.Id == w.TO.Id) exist = true; }
                    if(!exist) { Wrappers wrap = new Wrappers();
                                 wrap.toSelected = true;
                                 wrap.TO = tos;
                                 toWrapperList.add(wrap);
                    }
                } } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for generating barcodes from different sObject fields as pdf
    */
    public PageReference createBarcodesPage() {
        return page.stockdispatching_TO_printbarcodes;
    }   
    public PageReference back() {
        pageReference pag = new pageReference('/apex/stockdispatching_Transferorder');
        pag.setRedirect(true);
        return pag;
    }    
    public pageReference createOrder() {   
        pageReference pag = new pageReference('/apex/stockdispatching_Transferorder');
        pag.setRedirect(true);
        return pag;
    } 
    public PageReference createUPSShipment() {
        try {
            String sType = '';
            Boolean error = false;
            selectedPackIds = new List<Id>();            
            if(lineItemWrapperList != null) { 
                for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) { 
                                                                   if(sType == '') sType = lw.pack.Shipment_Type__c;
                                                                   if(sType == lw.pack.Shipment_Type__c) {
                                                                       selectedPackIds.add(lw.pack.Id);
                                                                       if(shipmentType == null) shipmentType = lw.pack.Shipment_Type__c;} else { errorMsg1 = 'You cannot select packages with different shipment type.'; error = true; break; }
                                                               } else { if(packageId != null && packageId != '') selectedPackIds.add(packageId); }
                                                             }                                
            } 
            if(!error) { errorMsg1 = '';
                if(selectedPackIds.size() > 0 && shipmentType == 'UPS') { showUPSComponent = true; shipId = ''; retValue = 'TO'; } 
                else if((shipmentId != null && shipmentId != '') && shipmentType == 'UPS') { showUPSComponent = true; shipId = shipmentId; retValue = 'TO'; }
                else if(selectedPackIds.size() > 0 && shipmentType == 'FedEx') { showFedExComponent = true; shipId = ''; retValue = 'TO'; } 
                else if((shipmentId != null && shipmentId != '') && shipmentType == 'FedEx') { showFedExComponent = true; shipId = shipmentId; retValue = 'TO'; }  
                else if(selectedPackIds.size() > 0 && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = ''; retValue = 'TO'; } 
                else if((shipmentId != null && shipmentId != '') && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = shipmentId; retValue = 'TO'; }
            } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }  
    public PageReference createPackage() { return null; }
            
    /*
      wrapper class definitions
    */
    public static String sortBy                                { get; set; } public static String orderFormat                           { get; set; }public static String prevSortBy                            { get; set; }
    
    public List<Wrappers> toWrapperList                        { get; set; }    
    public List<Wrappers> toliWrapperList                      { get; set; }
    public List<Wrappers> shipmentWrapperList                  { get; set; }     
    public List<Wrappers> toSelectedWrapperList                { get; set; }
    public List<Wrappers> toliSelectedWrapperList              { get; set; }      public List<Wrappers> shipmentSelectedWrapperList          { get; set; }  
    public class Wrappers implements Comparable {    
        public Transfer_Order__c TO                            { get; set; }  
        public Transfer_Order_Line_Items__c TOLI               { get; set; }  
        public String WN                                       { get; set; } 
        public String LN                                       { get; set; } 
        public String SD                                       { get; set; }
        public String batchLotCode                             { get; set; }   
        public String binName                                  { get; set; }
        public String trackingNo                               { get; set; }        
        public String AddressName                              { get; set; }                 
        public Boolean toSelected                              { get; set; }
        public String locationName                             { get; set; } 
        public Boolean toliSelected                            { get; set; }
        public Boolean toliVerified                            { get; set; }
        public Boolean shipSelected                            { get; set; }  
        public String warehouseName                            { get; set; }
        public Boolean isTOLIawaiting                          { get; set; }
        public Shipment__c shipM                               { get; set; }
        public String shipmentType                             { get; set; }
        public Boolean include                                 { get; set; }
        public Integer raisedQty                               { get; set; }
        public Integer requiredQty                             { get; set; }
        public Integer remainingQty                            { get; set; }        
        public Decimal inventoryStock                          { get; set; }                            
        public List<SelectOption> Address                      { get; set; }                        
        public Boolean isAvailablePackages                     { get; set; }
        public Boolean isAvailableShipments                    { get; set; }        
        public Boolean isAllShipmentsDelivered                 { get; set; } 
        public List<SelectOption> CurrentBins                  { get; set; }
        public List<SelectOption> CurrentLocations             { get; set; }
        public List<SelectOption> CurrentWarehouses            { get; set; }
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
            batchLotCode = '';
            trackingNo = '';
            AddressName = '';
            binName = null;
            raisedQty = 0;
            requiredQty = 0;
            remainingQty = 0;
            include = false;  
            isTOLIawaiting = false;
            toSelected = false;
            toliVerified = false;
            shipSelected = false;
            inventoryStock = 0;                  
            locationName = null;             
            warehouseName = null;            
            toliSelected = false;             
            shipM = new Shipment__c();
            TO = new Transfer_Order__c();     
            isAvailablePackages = false;
            isAvailableShipments = false;
            isAllShipmentsDelivered = false;       
            Address = new List<SelectOption>(); 
            CurrentBins = new List<SelectOption>();
            TOLI = new Transfer_Order_Line_Items__c();
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
        public Integer compareTo(Object objToCompare) { if(sortBy == 'WN') { Integer result = WN.compareTo(((Wrappers)objToCompare).WN); return (orderFormat == 'ASC')? result : result * -1; }  else if(sortBy == 'LN') { Integer result = LN.compareTo(((Wrappers)objToCompare).LN); return (orderFormat == 'ASC')? result : result * -1; }  else if(sortBy == 'SD') { Integer result = SD.compareTo(((Wrappers)objToCompare).SD); return (orderFormat == 'ASC')? result : result * -1; }  return 0;  
        }     
    }            
    public class innerPackageWrapper{
        public List<SelectOption> packList               { get; set; }
        public String pack                               { get; set; }
        public Package__c packege                        { get; set; }
        public Package_List__c packageList               { get; set; }
        
        public innerPackageWrapper(){ 
            packege = new Package__c();
            packageList = new Package_List__c();
            packList = new List<SelectOption>();
            pack = '';
        }
    }        
    public class packageWrapper {
        public Decimal qtyToPick                                 { get; set; }   
        public Decimal qtyToPack                                 { get; set; }
        public Boolean pkgSelected                               { get; set; } 
        public Transfer_Order_Line_Items__c TOLI                 { get; set; }
        public List<innerPackageWrapper> innerPackList           { get; set; }        
        
        public packageWrapper(){ 
            qtyToPick = 0;
            qtyToPack = 0;
            pkgSelected = false;
            TOLI = new Transfer_Order_Line_Items__c();
            innerPackList = new List<innerPackageWrapper>();            
        }
    }     
    
    public class lineItemWrapper {
        public Package__c pack                           { get; set; }
        public Shipment__c shipment                      { get; set; }
        public Decimal NoofLineItems                     { get; set; }
        public Boolean sel                               { get; set; }
        public String units                              { get; set; }  
        
        public lineItemWrapper(){
            pack = new Package__c();
            shipment = new Shipment__c();
            sel = false;
            units = '';
            NoofLineItems = 0;
        }
    }
    public List<newWrapper> tolisWrapperList              { get; set; }
    public class newWrapper {
        public Integer ident                              { get; set; } 
        public Transfer_Order_Line_Items__c tolis         { get; set; }
        
        public newWrapper(Integer inIdent) {
            ident = inIdent;
            tolis = new Transfer_Order_Line_Items__c();
        }
    }
}