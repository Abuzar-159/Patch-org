public with sharing class StockDispatchingController_SR {
    
    public String shipId                                            { get; set; }    
    public String barcode                                           { get; set; } public String retValue                                          { get; set; }    
    public String errorMsg                                          { get; set; }
    public String imageURL                                          { get; set; }    public String errorMsg1                                         { get; set; }    
    public String errorMsg2                                         { get; set; }    
    public String RMAFields                                         { get; set; }    
    public List<Id> rmaliIds                                        { get; set; }    
    public String searchText                                        { get; set; }
    public String binFields                                         { get; set; }
    public String packageId                                         { get; set; }
    public String shipmentId                                        { get; set; }
    public String siteFields                                        { get; set; }  
    public String barcodeLoc                                        { get; set; }  
    public Boolean CreatePack                                       { get; set; }              
    public Boolean isAwaiting                                       { get; set; } 
    public String sfdcBaseURL                                       { get; set; }
    public String RMALIFields                                       { get; set; }          
    public String orderNumber                                       { get; set; }
    public Integer rowCounter                                       { get; set; }    
    public String shipmentType                                      { get; set; }   
    public String pkgTypeValue                                      { get; set; } public Boolean initialScan                                      { get; set; }
    public String pack2updateId                                     { get; set; }    
    public String barcodeLocMsg                                     { get; set; }    
    public String salesreturnId                                     { get; set; }
    public String PackageFields                                     { get; set; }
    public Map<Id, Id> stockMap                                     { get; set; }
    public String channelFields                                     { get; set; }     
    public String ShipmentFields                                    { get; set; }  
    public String SDLIFields                                        { get; set; }
    public String locationsFields                                   { get; set; }  
    public String warehouseFields                                   { get; set; }
    public String packageListFields                                 { get; set; }             
    public Boolean showUPSComponent                                 { get; set; }
    public Boolean showFedExComponent                               { get; set; }         
    public List<Id> selectedPackIds                                 { get; set; }          
    public Package__c Package2Create                                { get; set; }               
    public List<Location__c> SSLList                                { get; set; }    
    public List<Package__c> Packages                                { get; set; }   
    public List<Shipment__c> Shipments                              { get; set; }      
    public Map<Id, Package__c> packMap                              { get; set; }          
    public EmailTemplate packingTemplate                            { get; set; }
    public List<Shipment__c> shipmentList                           { get; set; } 
    public EmailTemplate shippingTemplate                           { get; set; }        
    public List<RMA_Line_Item__c> rmaliList                         { get; set; }            
    public List<Inventory_Stock__c> WIISList                        { get; set; }   
    public String PackageCustomSettingFields                        { get; set; } 
    public List<StorageContainer__c> binList                        { get; set; }
    public List<Package_List__c> packageLists                       { get; set; }        
    public List<RMA_Line_Item__c> currentItems                      { get; set; }                 public List<Package_List__c> packListRecords                    { get; set; }
    public Boolean showInternalShippingComponent                    { get; set; }    
    public List<packageWrapper> packageWrapperList                  { get; set; }     
    public List<lineItemWrapper> lineItemWrapperList                { get; set; }
    public List<Stock_Outward_Line_Item__c> SDLIList                { get; set; }      
    public List<Return_Merchandise_Authorisation__c> RMAList        { get; set; }
    public List<Distribution_Channel__c> DistributionChannels       { get; set; }         
    public Map<Package__c, List<Package_List__c>> packageRecords    { get; set; }       
    public Map<Shipment__c, List<Package_List__c>> shipmentRecords  { get; set; }        
    public String prodFields                                        { get; set; }  
    public PrintBarcodes PB                                         { get; set; } 
    
    public Employees__c Employee                                       { get; set; }
    public List<SelectOption> channelSites                             { get; set; }
    public Id selectedSite                                             { get; set; }public String selectedOrders                                       { get; set; }
    public Boolean showSN                                              { get; set; } 
    public Boolean showBatch                                           { get; set; }  
    public List<Stock_Outward_Line_Item__c> PPLIList2Delete            { get; set; } 
    public List<Stock_Outward_Line_Item__c> sdliItemList               { get; set; } public ERP7__Return_Merchandise_Authorisation__c RMA               { get; set; }                   
    
    /*
      Constructor.
    */
    public StockDispatchingController_SR() {
        try {                      
            siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c');
            utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c');               
            PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');      
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');               
            ShipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c');              
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');               
            locationsFields = UtilClass.selectStarFromSObject('ERP7__Location__c');          
            utilClass.FLSCheck(locationsFields.split(','),'ERP7__Location__c');                        
            RMALIFields = UtilClass.selectStarFromSObject('ERP7__RMA_Line_Item__c');
            utilClass.FLSCheck(RMALIFields.split(','),'ERP7__RMA_Line_Item__c');                        
            binFields = UtilClass.selectStarFromSObject('ERP7__StorageContainer__c');
            utilClass.FLSCheck(binFields.split(','),'ERP7__StorageContainer__c');                        
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');                        
            warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
            utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c');                        
            channelFields = UtilClass.selectStarFromSObject('ERP7__Distribution_Channel__c'); 
            utilClass.FLSCheck(channelFields.split(','),'ERP7__Distribution_Channel__c');                        
            PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c'); 
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');                        
            RMAFields = UtilClass.selectStarFromSObject('ERP7__Return_Merchandise_Authorisation__c');
            utilClass.FLSCheck(RMAFields.split(','),'ERP7__Return_Merchandise_Authorisation__c');                                        
            prodFields = UtilClass.selectStarFromSObject('Product2');
            utilClass.FLSCheck(prodFields.split(','),'Product2'); 
            SDLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');         
            UtilClass.FlSCheck(SDLIFields.split(',') ,'ERP7__Stock_Outward_Line_Item__c');
                                  
            showUPSComponent = false;
            showFedExComponent = false;
            rmaliIds = new List<Id>();
            stockMap = new Map<Id, Id>();            
            Package2Create = new Package__c();         
            showInternalShippingComponent = false;    
            errorMsg = errorMsg2 = orderNumber = '';                       
            rmaliList = new List<RMA_Line_Item__c>();      
            WIISList = new List<Inventory_Stock__c>();   
            RMAList = new List<Return_Merchandise_Authorisation__c>();
            
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
            
            allReturnOrders(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for displaying all sales return orders which has to be re-send
    */   
    public void allReturnOrders() {        
        try {
            Set<Id> rmaIds = new Set<Id>();
            rmaWrapperList = new List<Wrappers>();
            rmaliList = new List<RMA_Line_Item__c>();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>();  
            String salesreturnId = ApexPages.CurrentPage().getParameters().get('srId'); 
            if(Schema.sObjectType.Return_Merchandise_Authorisation__c.isAccessible()) {
                if(salesreturnId != null && salesreturnId != '') {RMAList = Database.query('select ' + String.escapeSingleQuotes(RMAFields) + ' , SO__r.Ship_To_Address__r.Address_Line1__c, SO__r.Ship_To_Address__r.Address_Line2__c, SO__r.Ship_To_Address__r.Address_Line3__c, SO__r.Ship_To_Address__r.City__c, SO__r.Ship_To_Address__r.County__c, SO__r.Ship_To_Address__r.State__c, SO__r.Ship_To_Address__r.Postal_Code__c, SO__r.Ship_To_Address__r.Country__c, SO__r.Account__r.Name, SO__r.Name, SO__r.Account__c, SO__r.Barcode__c from Return_Merchandise_Authorisation__c where (Active__c = true And Id =\'' + String.escapeSingleQuotes(salesreturnId) + '\') Order By Name limit 1'); 
                } else {
                    RMAList = Database.query('select ' + String.escapeSingleQuotes(RMAFields) + ' , SO__r.Ship_To_Address__r.Address_Line1__c, SO__r.Ship_To_Address__r.Address_Line2__c, SO__r.Ship_To_Address__r.Address_Line3__c, SO__r.Ship_To_Address__r.City__c, SO__r.Ship_To_Address__r.County__c, SO__r.Ship_To_Address__r.State__c, '+
                              +' SO__r.Ship_To_Address__r.Postal_Code__c, SO__r.Ship_To_Address__r.Country__c, SO__r.Account__r.Name, SO__r.Name, SO__r.Account__c, SO__r.Barcode__c from Return_Merchandise_Authorisation__c where (Active__c = true) Order By Name limit 100'); 
                }
            } for(Return_Merchandise_Authorisation__c rma : RMAList) { rmaIds.add(rma.Id); }             
            if(rmaIds.size() > 0) { if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) rmaliList = Database.query('select ' + String.escapeSingleQuotes(RMALIFields) + ' from RMA_Line_Item__c where (Return_Merchandise_Authorisation__c In : rmaIds)');
                                    if(Schema.sObjectType.Package__c.isAccessible()) pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Return_Merchandise_Authorisation__c In: rmaIds)');
                                    if(Schema.sObjectType.Shipment__c.isAccessible()) shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Return_Merchandise_Authorisation__c In: rmaIds)');
                for(Return_Merchandise_Authorisation__c rmas: RMAList) { Wrappers wrap = new Wrappers(); 
                    for(RMA_Line_Item__c ramli: rmaliList) { if(ramli.Return_Merchandise_Authorisation__c == rmas.Id && ramli.Picked_Quantity__c != ramli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }
                    for(Package__c pkg : pkgList) { if(pkg.Return_Merchandise_Authorisation__c == rmas.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0; 
                    for(Shipment__c ship : shipList) { 
                        if(ship.Return_Merchandise_Authorisation__c == rmas.Id) { wrap.isAvailableShipments = true;
                                                                                  if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++;
                                                                                  if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;
                      wrap.RMA = rmas;
                      rmaWrapperList.add(wrap);
                } } else errorMsg = 'Sorry, no records available to view.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for searching RMA's upon rma / sales order
    */    
    public PageReference searchSRs() {  
        try {
            Set<Id> rmaIds = new Set<Id>();        
            rmaWrapperList = new List<Wrappers>();
            rmaliList = new List<RMA_Line_Item__c>();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>(); 
            rmaList = new List<Return_Merchandise_Authorisation__c>();
            if(searchText != null && searchText != '') { String searchString = '%'+String.escapeSingleQuotes(searchText)+'%';if(Schema.sObjectType.Return_Merchandise_Authorisation__c.isAccessible()) RMAList = Database.query('select ' + String.escapeSingleQuotes(RMAFields) + ' , SO__r.Ship_To_Address__r.Address_Line1__c, SO__r.Ship_To_Address__r.Address_Line2__c, SO__r.Ship_To_Address__r.Address_Line3__c, SO__r.Ship_To_Address__r.City__c, SO__r.Ship_To_Address__r.County__c, SO__r.Ship_To_Address__r.State__c, '+
                                                                                                    +' SO__r.Ship_To_Address__r.Postal_Code__c, SO__r.Ship_To_Address__r.Country__c, SO__r.Account__r.Name, SO__r.Name, SO__r.Customer__c, SO__r.Barcode__c from Return_Merchandise_Authorisation__c where (Active__c = true And (Name like: searchString OR SO__r.Name like: searchString)) Order By Name limit 100'); 
            } else {
                if(Schema.sObjectType.Return_Merchandise_Authorisation__c.isAccessible()) RMAList = Database.query('select ' + String.escapeSingleQuotes(RMAFields) + ' , SO__r.Ship_To_Address__r.Address_Line1__c, SO__r.Ship_To_Address__r.Address_Line2__c, SO__r.Ship_To_Address__r.Address_Line3__c, SO__r.Ship_To_Address__r.City__c, SO__r.Ship_To_Address__r.County__c, SO__r.Ship_To_Address__r.State__c, '+
                                                                                                    +' SO__r.Ship_To_Address__r.Postal_Code__c, SO__r.Ship_To_Address__r.Country__c, SO__r.Account__r.Name, SO__r.Name, SO__r.Account__c, SO__r.Barcode__c from Return_Merchandise_Authorisation__c where (Active__c = true) Order By Name limit 100');                         
            } for(Return_Merchandise_Authorisation__c rmas : RMAList) { rmaIds.add(rmas.Id); }
            if(rmaIds.size() > 0) { errorMsg = '';
                                    if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) rmaliList = Database.query('select ' + String.escapeSingleQuotes(RMALIFields) + ' from RMA_Line_Item__c where (Return_Merchandise_Authorisation__c In : rmaIds)');
                                    if(Schema.sObjectType.Package__c.isAccessible()) pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Return_Merchandise_Authorisation__c In: rmaIds)');
                                    if(Schema.sObjectType.Shipment__c.isAccessible()) shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Return_Merchandise_Authorisation__c In: rmaIds)');
                for(Return_Merchandise_Authorisation__c rmas: RMAList) { Wrappers wrap = new Wrappers(); 
                    for(RMA_Line_Item__c ramli: rmaliList) { if(ramli.Return_Merchandise_Authorisation__c == rmas.Id && ramli.Picked_Quantity__c != ramli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }
                    for(Package__c pkg : pkgList) { if(pkg.Return_Merchandise_Authorisation__c == rmas.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0; 
                    for(Shipment__c ship : shipList) { 
                        if(ship.Return_Merchandise_Authorisation__c == rmas.Id) { wrap.isAvailableShipments = true;
                                                                                  if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++;
                                                                                  if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;
                      wrap.RMA = rmas;
                      rmaWrapperList.add(wrap);
                }  } else errorMsg = 'Sorry, no records available to view.';  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating barcodes for selected WOLIs
    */
    public PageReference createBarcode() {
        try {                        
            Boolean error = false;
            rmaliIds = new List<Id>();
            PB = new PrintBarcodes();
            Set<Id> pIds = new Set<Id>();
            rmaliSelectedWrapperList = new List<Wrappers>();
            PB.BarcodeWrapperList = new List<PrintBarcodes.BarcodeWrapper>();           
            if(rmaliWrapperList.size() > 0) {
                for(Wrappers wrap : rmaliWrapperList) { if(wrap.rmaliSelected == true) { rmaliIds.add(wrap.rmali.Id); pIds.add(wrap.rmali.SOLI__r.Product__c); rmaliSelectedWrapperList.add(wrap); } }
                if(rmaliSelectedWrapperList.size() > 0) { errorMsg = ''; List<Product2> prods = Database.query('select ' + String.escapeSingleQuotes(prodFields) +' from Product2 where Id In: pIds');    Map<Id, Product2> pMap = new Map<Id, Product2>(); for(Product2 prod: prods) { pMap.put(prod.Id, prod); }for(Wrappers wrap : rmaliSelectedWrapperList) { PrintBarcodes.BarcodeWrapper BW; if(PB.LabelField != Null && PB.LabelField != '') BW = new PrintBarcodes.BarcodeWrapper(wrap.RMALI.SOLI__r.Product__r.Barcode__c, wrap.RMALI.SOLI__r.Product__r.Name, wrap.RMALI.SOLI__r.Product__r.Name);else  BW = new PrintBarcodes.BarcodeWrapper(wrap.RMALI.SOLI__r.Product__r.Barcode__c, '' , wrap.RMALI.SOLI__r.Product__r.Name); BW.products = pMap.get(wrap.RMALI.SOLI__r.Product__c);  PB.BarcodeWrapperList.add(BW);
                    } 
                } else { errorMsg = 'Please select a line item to print barcode.'; }   } else { errorMsg = 'Items have been picked, please proceed to packing.'; } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return Page.stockdispatching_SR_PrintPickProductsPDF;
    }
    
    /*
      method for redirecting for next tab (Pick) 
    */
    public PageReference redirect2NextTab() {
        try {
            Boolean error = false;
            String customerId = '';            
            Set<Id> rmaIds = new Set<Id>();
            Set<Id> orgIds = new Set<Id>();
            barcodeLoc = barcodeLocMsg = '';
            SSLList = new List<Location__c>();  
            rmaliWrapperList = new List<Wrappers>();
            binList = new List<StorageContainer__c>();
            showSN = false;
            showBatch = false;
            Set<Id> proIds = new Set<Id>();
            Set<Id> assIds = new Set<Id>();
            PPLIList2Delete = new List<Stock_Outward_Line_Item__c>();
            
            
            if(rmaWrapperList.size() > 0){
                rmaSelectedWrapperList = new List<Wrappers>(); 
                for(Wrappers sow : rmaWrapperList) {
                    if(sow.rmaSelected == true) { 
                        if(salesreturnId == sow.RMA.Id) salesreturnId = Null;
                        if(customerId == '') customerId = sow.RMA.SO__r.Account__c; 
                        if(customerId == sow.RMA.SO__r.Account__c){
                            rmaIds.add(sow.RMA.Id);
                            rmaSelectedWrapperList.add(sow);
                            orgIds.add(sow.RMA.Organisation__c);  } else { errorMsg = 'You cannot select orders with different customer.'; error = true; break; }                                                                            
                    }
                    if(salesreturnId == sow.RMA.Id) { rmaIds.add(salesreturnId); rmaSelectedWrapperList.add(sow); }} } else { for(Wrappers sow : rmaSelectedWrapperList) { if(customerId == '') customerId = sow.RMA.SO__r.Account__c; rmaIds.add(sow.RMA.Id); orgIds.add(sow.RMA.Organisation__c);
                }
            }
            
            
            if(rmaIds.size() > 0) {
                if(!error) { 
                    errorMsg = '';
                    Map<Id, Product2> productMap = new Map<Id, Product2>();
                    Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>();
                    
                    if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) { 
                        rmaliList = Database.query('select ' + String.escapeSingleQuotes(RMALIFields) + ' ,Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.SO__r.Name, Return_Merchandise_Authorisation__r.SO__r.Account__r.Name, Return_Merchandise_Authorisation__r.Organisation__c, '+
                                                             +'  SOLI__r.Product__r.Item_Description__c, SOLI__r.Product__r.Name, SOLI__r.Product__r.Preview_Image__c, SOLI__r.Product__r.Picture__c, SOLI__r.Product__r.Weight__c, '+
                                                             +' SOLI__r.Product__r.Barcode__c, SOLI__r.Product__r.ERP7__Is_Kit__c, SOLI__r.ERP7__Product__r.ERP7__Lot_Tracked__c, SOLI__r.ERP7__Asset__r.ERP7__Lot_Tracked__c, SOLI__r.ERP7__Asset__r.Name, SOLI__r.Product__r.Serialise__c, SOLI__r.ERP7__Asset__r.Serialise__c from RMA_Line_Item__c where (Return_Merchandise_Authorisation__c In : rmaIds) order by Return_Merchandise_Authorisation__c ASC'); 
                    } 
                    
                    for(RMA_Line_Item__c rmali: rmaliList) { 
                        rmaliIds.add(rmali.Id); orgIds.add(rmali.Return_Merchandise_Authorisation__r.Organisation__c); 
                        if(rmali.SOLI__r.Product__c != Null) proIds.add(rmali.SOLI__r.Product__c);
                        if(rmali.SOLI__r.Asset__c != Null) assIds.add(rmali.SOLI__r.Asset__c);
                    }
                    
                    productMap = new Map<Id, Product2>([Select Id, Name, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]);
                    assetMap = new Map<Id, Asset__c>([Select Id, Name, Picture__c, Preview_Image__c, Status__c, Item_Description__c, Special_Instructions__c, Weight__c, Barcode__c From Asset__c Where Id In: assIds]);
                    
                    
                    
                    if(orgIds.size() > 0) { 
                        DistributionChannels = Database.query('select ' + String.escapeSingleQuotes(channelFields) + ' ,Site__r.Name, Site__r.Barcode__c from Distribution_Channel__c where (Active__c = true) Order By Name Asc'); } else { DistributionChannels = Database.query('select ' + String.escapeSingleQuotes(channelFields) + ' ,Site__r.Name, Site__r.Barcode__c from Distribution_Channel__c where (Active__c = true) Order By Name Asc'); }
                    
                    
                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()) sdliItemList = Database.query('select ' + String.escapeSingleQuotes(SDLIFields) + ' from Stock_Outward_Line_Item__c where RMA_Line_Item__c In : rmaliIds'); 
                    
                    List<Id> WIISIds = new List<Id>();
                    for(Stock_Outward_Line_Item__c w : sdliItemList) { 
                        WIISIds.add(w.Site_Product_Service_Inventory_Stock__c); 
                    }  
                    List<Inventory_Stock__c> WIISLists;
                    if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) { 
                        WIISLists = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ', Warehouse__r.Name, Warehouse__r.Barcode__c, StorageContainer__r.Name, StorageContainer__r.Barcode__c, Location__r.Name, Location__r.Barcode__c from Inventory_Stock__c where '+
                                                              '(Warehouse__c =: selectedSite And ((Product__c In: proIds And Number_of_Item_In_Stock__c > 0) Or Fixed_Asset__c In: assIds) And Active__c = true) Order By ERP7__Expiry_Date__c ASC');
                    }
                     
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
                    
                    for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);if(!stockBatches.containsKey(InwardLine.ERP7__Product__c)) {  Set<SelectOption> myBatches = new Set<SelectOption>(); if(!InwardLine.ERP7__Product__r.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));  myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); stockBatches.put(InwardLine.ERP7__Product__c, myBatches);}else{Set<SelectOption> myBatches = stockBatches.get(InwardLine.ERP7__Product__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); stockBatches.put(InwardLine.ERP7__Product__c, myBatches);
                            }
                            
                        }
                    }
                    
                    for(RMA_Line_Item__c rmalis : rmaliList) { 
                        if(rmalis.SOLI__r.Product__c != Null){
                            Wrappers swrap = new Wrappers();  
                            swrap.product = productMap.get(rmalis.SOLI__r.Product__c); 
                            swrap.RMALI = rmalis;
                            if(swrap.RMALI.Picked_Quantity__c != null) { 
                                if(swrap.RMALI.Picked_Quantity__c == swrap.RMALI.Quantity_Return__c) {
                                    swrap.raisedQty = Integer.valueof(swrap.RMALI.Picked_Quantity__c);     
                                    swrap.remainingQty = Integer.valueof(swrap.RMALI.Quantity_Return__c - swrap.raisedQty);
                                } else if(swrap.RMALI.Picked_Quantity__c < swrap.RMALI.Quantity_Return__c) {
                                    swrap.raisedQty = Integer.valueof(swrap.RMALI.Picked_Quantity__c); 
                                    swrap.remainingQty = Integer.valueof(swrap.RMALI.Quantity_Return__c - swrap.raisedQty);                                      
                                    swrap.requiredQty = Integer.valueof(swrap.RMALI.Quantity_Return__c - swrap.raisedQty);
                                }
                            } else { swrap.requiredQty = Integer.valueof(swrap.RMALI.Quantity_Return__c); 
                                     swrap.remainingQty = Integer.valueof(swrap.RMALI.Quantity_Return__c);     
                            }
                            
                            Set<SelectOption> options1 = new Set <SelectOption>(); 
                            Set<SelectOption> options2 = new Set <SelectOption>();
                            Set<SelectOption> options3 = new Set <SelectOption>(); 
                            Set<SelectOption> address = new Set <SelectOption>(); 
                            for(ERP7__Inventory_Stock__c wiis: WIISLists) {if(wiis.Product__c == rmalis.SOLI__r.Product__c) { if(wiis.StorageContainer__c != null) { swrap.binName = swrap.AddressName = wiis.StorageContainer__c; if(wiis.StorageContainer__r.Name != null) options3.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Name));if(wiis.StorageContainer__r.Barcode__c != null) { address.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c; } } else if(wiis.Location__c != null) { swrap.LN = wiis.Location__r.Name; swrap.LocationName = swrap.AddressName  = wiis.Location__c;if(wiis.Location__r.Name != null) options2.add(new SelectOption(wiis.Location__c, wiis.Location__r.Name));if(wiis.Location__r.Barcode__c != null){ address.add(new SelectOption(wiis.Location__c, wiis.Location__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;} } else if(wiis.Warehouse__c != null) { swrap.WN = wiis.Warehouse__r.Name; swrap.WarehouseName = swrap.AddressName = wiis.Warehouse__c;if(wiis.Warehouse__r.Name != null) options1.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Name)); if(wiis.Warehouse__r.Barcode__c != null){ address.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c; } }stockMap.put(wiis.Product__c, wiis.Id);
                                }
                            }
                            swrap.address.addAll(address);
                            swrap.CurrentWarehouses.addAll(options1); 
                            swrap.CurrentLocations.addAll(options2);    
                            swrap.CurrentBins.addAll(options3); 
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);
                            if(myStock != 0) swrap.inventoryStock = myStock + swrap.remainingQty;
                        
                            swrap.BatchLotCodes = new List <SelectOption>();   
                            if(stockBatches.ContainsKey(rmalis.SOLI__r.Product__c)) { swrap.BatchLotCodes.addAll(stockBatches.get(rmalis.SOLI__r.Product__c)); }
                            
                            if(swrap.BatchLotCodes.size() > 0 && rmalis.SOLI__r.Product__r.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                            }
                            else swrap.BatchLotCode = '';
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);
                            
                           
                            if(swrap.raisedQty != rmalis.Quantity_Return__c) {
                                if(rmalis.SOLI__r.Product__r.Serialise__c){if(swrap.requiredQty > 0) swrap.requiredQty = 1;  swrap.serialized = true;  showSN = true;
                                } 
                                
                                if(swrap.BatchLotCodes.size() > 0) showBatch = true;
                                rmaliWrapperList.add(swrap);}}else if(rmalis.SOLI__r.Asset__c != Null && !(rmalis.Picked_Quantity__c > 0)){ Wrappers swrap = new Wrappers();   swrap.asset = assetMap.get(rmalis.SOLI__r.Asset__c); swrap.RMALI = rmalis;if(swrap.RMALI.Picked_Quantity__c != null) { if(swrap.RMALI.Picked_Quantity__c == swrap.RMALI.Quantity_Return__c) { swrap.raisedQty = Integer.valueof(swrap.RMALI.Picked_Quantity__c); swrap.remainingQty = Integer.valueof(swrap.RMALI.Quantity_Return__c - swrap.raisedQty);} else if(swrap.RMALI.Picked_Quantity__c < swrap.RMALI.Quantity_Return__c) {swrap.raisedQty = Integer.valueof(swrap.RMALI.Picked_Quantity__c);  swrap.remainingQty = Integer.valueof(swrap.RMALI.Quantity_Return__c - swrap.raisedQty); swrap.requiredQty = Integer.valueof(swrap.RMALI.Quantity_Return__c - swrap.raisedQty);}} else { swrap.requiredQty = Integer.valueof(swrap.RMALI.Quantity_Return__c);  swrap.remainingQty = Integer.valueof(swrap.RMALI.Quantity_Return__c);     }Set<SelectOption> options1 = new Set <SelectOption>(); Set<SelectOption> options2 = new Set <SelectOption>(); Set<SelectOption> options3 = new Set <SelectOption>(); Set<SelectOption> address = new Set <SelectOption>(); for(ERP7__Inventory_Stock__c wiis: WIISLists) {if(wiis.Fixed_Asset__c == rmalis.SOLI__r.Asset__c) {if(wiis.StorageContainer__c != null) {swrap.binName = swrap.AddressName = wiis.StorageContainer__c;  if(wiis.StorageContainer__r.Name != null) options3.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Name)); if(wiis.StorageContainer__r.Barcode__c != null) { address.add(new SelectOption(wiis.StorageContainer__c, wiis.StorageContainer__r.Barcode__c));myStock += WIIS.Number_of_Item_In_Stock__c;}} else if(wiis.Location__c != null) { swrap.LN = wiis.Location__r.Name;swrap.LocationName = swrap.AddressName  = wiis.Location__c;if(wiis.Location__r.Name != null) options2.add(new SelectOption(wiis.Location__c, wiis.Location__r.Name));if(wiis.Location__r.Barcode__c != null){ address.add(new SelectOption(wiis.Location__c, wiis.Location__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c; }} else if(wiis.Warehouse__c != null) {swrap.WN = wiis.Warehouse__r.Name; swrap.WarehouseName = swrap.AddressName = wiis.Warehouse__c;if(wiis.Warehouse__r.Name != null) options1.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Name));  if(wiis.Warehouse__r.Barcode__c != null){ address.add(new SelectOption(wiis.Warehouse__c, wiis.Warehouse__r.Barcode__c)); myStock += WIIS.Number_of_Item_In_Stock__c;}}stockMap.put(wiis.Fixed_Asset__c, wiis.Id); }}swrap.address.addAll(address); swrap.CurrentWarehouses.addAll(options1); swrap.CurrentLocations.addAll(options2);    swrap.CurrentBins.addAll(options3);   if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock); if(myStock != 0) swrap.inventoryStock = myStock + swrap.remainingQty;swrap.BatchLotCodes = new List <SelectOption>(); if(stockBatches.ContainsKey(rmalis.SOLI__r.Asset__c)) { swrap.BatchLotCodes.addAll(stockBatches.get(rmalis.SOLI__r.Asset__c)); }if(swrap.BatchLotCodes.size() > 0 && rmalis.SOLI__r.Asset__r.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());}else swrap.BatchLotCode = ''; if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);if(swrap.raisedQty != rmalis.Quantity_Return__c) { if(rmalis.SOLI__r.Asset__r.Serialise__c){  if(swrap.requiredQty > 0) swrap.requiredQty = 1; swrap.serialized = true;  showSN = true; }  if(swrap.BatchLotCodes.size() > 0) showBatch = true;  rmaliWrapperList.add(swrap);
                            }
                        }
                    }
                    return page.Stockdispatching_SR_Pick;    } } else errorMsg = 'Please select an order to proceed.';  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }return null;
    }
    
    /*
      method for fetching available inventory stocks upon selected address
    */
    public PageReference fetchBinStocks() {
        try {
            List<Wrappers> rmaliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            if(rowCounter != null) rmaliWrap = new List<Wrappers>(); rmaliWrap.add(rmaliWrapperList.get(rowCounter));
            if(rmaliWrap != null) {
                if(Schema.sObjectType.Site__c.isAccessible()) siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(rmaliWrap[0].addressName) + '\' And Active__c = true)');
                          
                if(Schema.sObjectType.Location__c.isAccessible()) SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(rmaliWrap[0].addressName) + '\' And Active__c = true)');

                if(Schema.sObjectType.StorageContainer__c.isAccessible()) binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(rmaliWrap[0].addressName) + '\' And Active__c = true)');
                
                if(binList.size() > 0) {if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By CreatedDate ASC');                    } for(Inventory_Stock__c WIIS : WIISList) { stockMap.put(WIIS.Product__c, WIIS.Id); }Decimal myStock = 0; for(Wrappers swrap : rmaliWrap) {for(Inventory_Stock__c WIIS : WIISList) { if(swrap.RMALI.SOLI__r.Product__c == WIIS.Product__c && (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)) myStock += WIIS.Number_of_Item_In_Stock__c; }if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock); else swrap.requiredQty = Integer.valueof(swrap.RMALI.Quantity_Return__c);swrap.inventoryStock = myStock; swrap.binName = null; swrap.locationName = SSLList[0].Id;swrap.warehouseName = SSLList[0].Site__c; swrap.WN = SSLList[0].Site__r.Name; swrap.LN = SSLList[0].Name;
                    }
                
                } else if(SSLList.size() > 0) { if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By CreatedDate ASC');                    } for(Inventory_Stock__c WIIS : WIISList) { stockMap.put(WIIS.Product__c, WIIS.Id); }Decimal myStock = 0;for(Wrappers swrap : rmaliWrap) {for(Inventory_Stock__c WIIS : WIISList) { if(swrap.RMALI.SOLI__r.Product__c == WIIS.Product__c && (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)) myStock += WIIS.Number_of_Item_In_Stock__c;  }if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = Integer.valueof(swrap.RMALI.Quantity_Return__c);swrap.inventoryStock = myStock; swrap.binName = null; swrap.locationName = SSLList[0].Id; swrap.warehouseName = SSLList[0].Site__c; swrap.WN = SSLList[0].Site__r.Name; swrap.LN = SSLList[0].Name;
                    }

                
                } else if(siteList.size() > 0) {if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By CreatedDate ASC');                                        } for(Inventory_Stock__c WIIS : WIISList) { stockMap.put(WIIS.Product__c, WIIS.Id); }Decimal myStock = 0;for(Wrappers swrap : rmaliWrap) {for(Inventory_Stock__c WIIS : WIISList) { if(swrap.RMALI.SOLI__r.Product__c == WIIS.Product__c && (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)) myStock += WIIS.Number_of_Item_In_Stock__c; }if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = Integer.valueof(swrap.RMALI.Quantity_Return__c);swrap.inventoryStock = myStock; swrap.binName = null; swrap.locationName = null; swrap.warehouseName = siteList[0].Id; swrap.WN = siteList[0].Name;  swrap.LN = '';}  }} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
      public PageReference fetchBatchStocks() {
        try {
            List<Wrappers> rmaliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(rowCounter != null) rmaliWrap = new List<Wrappers>(); rmaliWrap.add(rmaliWrapperList.get(rowCounter));
            if(rmaliWrap != null) {
                if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
                else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(rmaliWrap[0].addressName) + '\' And Active__c = true)'); }
                    
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
                else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(rmaliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
                else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(rmaliWrap[0].addressName) + '\' And Active__c = true)'); }
                          
                if(binList.size() > 0) {   if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }Decimal myStock = 0;   if(rmaliWrap.size() > 0) {Wrappers swrap = rmaliWrap[0]; List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c  From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; }  Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>(); Set<SelectOption> myBatches = new Set<SelectOption>(); if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--')); for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){if(InwardLine.ERP7__Material_Batch_Lot__c != Null){  batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); }} if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) {  swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); } else swrap.inventoryStock = myStock; if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);  else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                            
                    }
                    
                } else if(SSLList.size() > 0) {    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }Decimal myStock = 0;if(rmaliWrap.size() > 0) { Wrappers swrap = rmaliWrap[0];List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];for(Inventory_Stock__c WIIS : WIISList) {if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  }  Set<SelectOption> myBatches = new Set<SelectOption>(); Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();  if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--')); for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name));} }if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); } else swrap.inventoryStock = myStock; if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock); else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                        
                    }
                    
                } else if(siteList.size() > 0) {if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }Decimal myStock = 0;   if(rmaliWrap.size() > 0) {Wrappers swrap = rmaliWrap[0];List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; } Set<SelectOption> myBatches = new Set<SelectOption>(); Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){if(InwardLine.ERP7__Material_Batch_Lot__c != Null){myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c);} }  if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.rmali.Quantity_Return__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) {swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);} else swrap.inventoryStock = myStock;if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);  else swrap.requiredQty = Integer.valueof(swrap.remainingQty); if(swrap.inventoryStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = swrap.inventoryStock+swrap.rmali.Quantity_Return__c-swrap.raisedQty;  else if(myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  } } }    } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    
    
    /*
      method for creating product purchase line item for selected RMALIs
    */
    public PageReference saveRMALIs() {
        try {
            Boolean error = false;
            Set<Id> rmaIds = new Set<Id>();
            List<Id> assetIds = new List<Id>();
            rmaliSelectedWrapperList = new List<Wrappers>();
            SDLIList = new List<Stock_Outward_Line_Item__c>();
            
            if(rmaliWrapperList.size() > 0) {
                for(Wrappers wrap : rmaliWrapperList) { if(wrap.rmaliSelected == true) { if(wrap.rmali.Soli__r.Asset__c != Null){ assetIds.add(wrap.rmali.Soli__r.Asset__c); } rmaIds.add(wrap.rmali.Return_Merchandise_Authorisation__c); rmaliSelectedWrapperList.add(wrap); } }
                if(rmaliSelectedWrapperList.size() > 0) { 
                    errorMsg = '';
                    for(Wrappers wrap: rmaliSelectedWrapperList) {
                        if(wrap.inventoryStock == 0) { errorMsg = 'Sorry, no available inventory for the selected item to proceed.'; error = true; break; } 
                        else if(wrap.requiredQty > wrap.inventoryStock) { errorMsg = 'Quantity cannot be greater than available stock.'; error = true; break; } 
                        else if(wrap.requiredQty > wrap.remainingQty) { errorMsg = 'Quantity cannot be greater than remaining Quantity.'; error = true; break; }
                        else if(wrap.serialized && (wrap.SerialNumbers.Serial__c == '' || wrap.SerialNumbers.Serial__c == Null)) { errorMsg = 'Required field missing - Serial Number'; error = true; break; }
                    }
                    if(!error) { 
                        MAP<Id, RMA_Line_Item__c> rmaliMap = new MAP<Id, RMA_Line_Item__c>();
                        MAP<Id, Asset__c> assetMap = new MAP<Id, Asset__c>([Select Id, Name, Active__c, Barcode__c, Status__c From Asset__c Where Id In :assetIds]);
                         
                        for(Wrappers wrap: rmaliSelectedWrapperList) {
                            Stock_Outward_Line_Item__c sdlis = new Stock_Outward_Line_Item__c();
                            
                            // creating new stock outward line items
                            if(wrap.rmali.Name != null) sdlis.Name = 'STOLI-'+wrap.rmali.Name;
                            if(wrap.RMALI.SOLI__r.Product__c != Null){ if(stockMap.get(wrap.RMALI.SOLI__r.Product__c) != Null) sdlis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.RMALI.SOLI__r.Product__c); if(wrap.RMALI.SOLI__r.Product__c != Null) sdlis.Product__c = wrap.RMALI.SOLI__r.Product__c;
                            } else if(wrap.RMALI.SOLI__r.Asset__c != Null){if(stockMap.get(wrap.RMALI.SOLI__r.Asset__c) != Null) sdlis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.RMALI.SOLI__r.Asset__c); if(wrap.RMALI.SOLI__r.Asset__c != Null) sdlis.Fixed_Asset__c = wrap.RMALI.SOLI__r.Asset__c;
                            }           
                            if(wrap.requiredQty != null) sdlis.Quantity__c = wrap.requiredQty;
                            if(wrap.requiredQty != null) sdlis.Picked_Quantity__c = wrap.requiredQty;
                            if(wrap.rmali.Return_Merchandise_Authorisation__c != null) sdlis.Return_Merchandise_Authorisation__c = wrap.rmali.Return_Merchandise_Authorisation__c;
                            sdlis.RMA_Line_Item__c = wrap.rmali.Id;
                            sdlis.Picked_Date__c = System.Now();
                            sdlis.Status__c = 'Committed';
                            sdlis.Active__c = true;   
                            if(wrap.SerialNumbers.Serial__c != null) sdlis.Serial__c = wrap.SerialNumbers.Serial__c;
                            if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') sdlis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;           
                            orderNumber = wrap.rmali.Return_Merchandise_Authorisation__r.Name;
                            
                            if(wrap.rmali.Picked_Quantity__c == null) wrap.rmali.Picked_Quantity__c = wrap.requiredQty; else wrap.rmali.Picked_Quantity__c += wrap.requiredQty;
                            
                            rmaliMap.put(wrap.rmali.Id, wrap.rmali);
                            SDLIList.add(sdlis);                        
                        }   
                        if(SDLIList.size() > 0) { 
                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()) { DMLManager.UpsertAsUser(SDLIList);} else{ /*no access*/ } if(Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) { upsert rmaliMap.Values();} else{ /*no access*/ } return redirect2NextTab();
                        }
                    }                    
                } else errorMsg = 'Please select a line item to save.';} else errorMsg = 'Items have been picked, please proceed to packing.';
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for generating picking slip(collection of selected RMALI's) as pdf
    */    
    public PageReference createPickingSlips() {
        String rmaID;
        try {
            rmaliSelectedWrapperList = new List<Wrappers>();
            for(Wrappers wrap : rmaliWrapperList) { rmaID = wrap.rmali.Return_Merchandise_Authorisation__c;  if(wrap.rmaliSelected == true) rmaliSelectedWrapperList.add(wrap); }
            RMA = [Select Id, Name, ERP7__Refund_Amount__c, 
                    ERP7__Picked_Quantity__c, ERP7__Packed_Quantity__c, 
                    ERP7__SO__c, ERP7__SO__r.ERP7__Contact__c, ERP7__SO__r.ERP7__Contact__r.Phone, ERP7__SO__r.ERP7__Account__c, ERP7__SO__r.ERP7__Account__r.ERP7__Company__c, ERP7__SO__r.ERP7__Contact__r.Name, ERP7__Total_Quantity__c, ERP7__SO__r.ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__SO__r.ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, ERP7__SO__r.ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, 
                    ERP7__SO__r.ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__SO__r.ERP7__Bill_To_Address__r.ERP7__Country__c, ERP7__SO__r.ERP7__Bill_To_Address__r.ERP7__Postal_Code__c, ERP7__SO__r.ERP7__Ship_To_Address__c,
                    ERP7__SO__r.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__SO__r.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, ERP7__SO__r.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__SO__r.ERP7__Ship_To_Address__r.ERP7__City__c, 
                    ERP7__SO__r.ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__SO__r.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c From ERP7__Return_Merchandise_Authorisation__c where Id=:rmaId];
            return page.stockdispatching_SR_PickingSlips;} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating a new package / displaying the existing created packages
    */
    public PageReference createPacks() {
        try {
            Set<Id> rmaIds = new Set<Id>();
            
            
            if(rmaWrapperList.size() > 0){ 
                rmaSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : rmaWrapperList) { 
                    if(sow.rmaSelected == true) { 
                        rmaIds.add(sow.RMA.Id); 
                        rmaSelectedWrapperList.add(sow); 
                        if(salesreturnId == sow.RMA.Id) salesreturnId = Null;
                    }
                    if(salesreturnId == sow.RMA.Id){ rmaSelectedWrapperList.add(sow); rmaIds.add(sow.RMA.Id); } } }else { for(Wrappers sow : rmaSelectedWrapperList) { rmaIds.add(sow.RMA.Id); 
                }
            }
            
            if(rmaIds.size() > 0) { rmaliWrapperList = new List<Wrappers>(); rmaliList = new List<RMA_Line_Item__c>();
                if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) { rmaliList = Database.query('select ' + String.escapeSingleQuotes(RMALIFields) + ' ,Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.SO__r.Name, SOLI__r.Base_Price__c, SOLI__r.Price_Product__c, Return_Merchandise_Authorisation__r.SO__r.Account__r.Name, '+
                                                                                     +' Return_Merchandise_Authorisation__r.Organisation__c, SOLI__r.Product__r.Item_Description__c, SOLI__r.Product__r.Name, SOLI__r.Product__r.Preview_Image__c, SOLI__r.Product__r.Picture__c, SOLI__r.Product__r.Weight__c, SOLI__r.Product__r.Barcode__c, SOLI__r.Asset__r.Name '+
                                                                                     +' from RMA_Line_Item__c where (Return_Merchandise_Authorisation__c In: rmaIds) order by Return_Merchandise_Authorisation__c ASC');
                }
                for(RMA_Line_Item__c rmalis : rmaliList) {
                    if(rmalis.Packed_Quantity__c != rmalis.Picked_Quantity__c && rmalis.Picked_Quantity__c <= rmalis.Quantity_Return__c) {
                        Wrappers swrap = new Wrappers(); 
                        swrap.RMALI = rmalis;
                        swrap.isRMALIawaiting = true;
                        orderNumber = rmalis.Return_Merchandise_Authorisation__r.Name;
                        rmaliWrapperList.add(swrap);
                    }                                            
                }   
                if(Schema.sObjectType.Package__c.isAccessible()) { Packages = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Return_Merchandise_Authorisation__r.SO__r.Account__c, Shipment__r.Name, Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.SO__r.Account__r.Name, '+
                                                                              +' Shipment__r.Shipment_Date__c, Shipment__r.Status__c from Package__c where (Active__c = true And Return_Merchandise_Authorisation__c In: rmaIds) Order by Shipment__r.Name, CreatedDate Asc');                       
                } packMap = new Map <Id, Package__c>(Packages); 
                
                if(Packages.size() > 0 && rmaliWrapperList.size() > 0) { createPack = true; isAwaiting = true; }
                else if(Packages.size() > 0) { createPack = false; isAwaiting = true; } else if(rmaliWrapperList.size() > 0) { createPack = true; isAwaiting = false; }    
                
                Set<Id> pkgIds = new Set<Id>();
                if(Packages.size() > 0) { for(Package__c pack: Packages) { pkgIds.add(pack.Id); } }       
                String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');
                if(Schema.sObjectType.Shipment__c.isAccessible()) Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where (Package__c In: pkgIds And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');
                
                if(Schema.sObjectType.Package_List__c.isAccessible()) packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c In: pkgIds And Active__c = true) Order by CreatedDate Asc');
                
                //*****************************************************************            
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { lineItemWrapper LW = new lineItemWrapper(); LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm';
                        else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }    
                
                //****************************************************************        
                    Package2Create = new Package__c();     
                    if(rmaIds.size() > 0) Package2Create.Return_Merchandise_Authorisation__c = (new list<Id>(rmaIds))[0];                                
                    Package2Create.Weight__c = 0;
                    Package2Create.Declared_Value__c = 0;                            
                    packageWrapperList = new List<packageWrapper>();
                    Package2Create.Status__c = 'Deposited To Front Desk';
                    if(Packages != null) Package2Create.Name = Package2Create.Barcode__c = Package2Create.Description__c = Package2Create.Name__c = 'SR-Package-'+ Integer.valueof(Packages.size()+1);
                    for(Wrappers wrap : rmaliWrapperList) { 
                        if(wrap.isRMALIawaiting == true) { packageWrapper PW = new packageWrapper();                            
                            PW.pkgSelected = true;
                            PW.rmali = wrap.rmali;
                            PW.qtyToPick = wrap.rmali.Picked_Quantity__c;
                            if(wrap.rmali.Picked_Quantity__c != null && wrap.rmali.Packed_Quantity__c != null) PW.qtyToPack = wrap.rmali.Picked_Quantity__c - wrap.rmali.Packed_Quantity__c;
                            else PW.qtyToPack = wrap.rmali.Picked_Quantity__c;
                                
                            if(PW.rmali.SOLI__r.Product__r.Weight__c != null) Package2Create.Weight__c += (PW.rmali.SOLI__r.Product__r.Weight__c * PW.qtyToPack);
                            
                            if(PW.rmali.SOLI__r.Price_Product__c != null) Package2Create.Declared_Value__c += (PW.rmali.SOLI__r.Price_Product__c * PW.qtyToPack);
                                                                                    
                            if(PW.qtyToPack != 0) packageWrapperList.add(PW);
                        }
                    } return Page.Stockdispatching_SR_Package;} else errorMsg = 'Please select an order to proceed.';} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for re-evaluating the package weight and declared value.
    */
    public PageReference evaluatePackDetails() {
        try {
            errorMsg2 = ''; Package2Create.Weight__c = Package2Create.Declared_Value__c = 0;
            for(packageWrapper PW : packageWrapperList) {
                if(PW.rmali.SOLI__r.Product__r.Weight__c != null) Package2Create.Weight__c += (PW.rmali.SOLI__r.Product__r.Weight__c * PW.qtyToPack);                            
                if(PW.rmali.SOLI__r.Price_Product__c != null) Package2Create.Declared_Value__c += (PW.rmali.SOLI__r.Price_Product__c * PW.qtyToPack);} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'  Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for pre-populating package details from custom settings.
    */
    public PageReference populatePackDetails() {
        try { 
           List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
           if(pkgTypeValue != null && pkgTypeValue != '--None--') {
               if(Schema.sObjectType.Package_Details__c.isAccessible()) pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from ERP7__Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\') Limit 1'); 
               if(pkgDetailList.size() > 0) {
                   if(Schema.sObjectType.Package_Details__c.fields.Length__c.isAccessible()) Package2Create.Length__c = pkgDetailList[pkgDetailList.size() - 1].Length__c;
                   if(Schema.sObjectType.Package_Details__c.fields.Width__c.isAccessible()) Package2Create.Width__c = pkgDetailList[pkgDetailList.size() - 1].Width__c;            
                   if(Schema.sObjectType.Package_Details__c.fields.Height__c.isAccessible()) Package2Create.Height__c = pkgDetailList[pkgDetailList.size() - 1].Height__c;
                   if(Schema.sObjectType.Package_Details__c.fields.Weight_Unit__c.isAccessible()) Package2Create.Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].Weight_Unit__c;
                   //if(Schema.sObjectType.Package__c.fields.Shipment_Type__c.isAccessible()) Package2Create.Shipment_Type__c = 'UPS';            
               } } else errorMsg2 = 'Sorry, selected package type not available.';  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    } 
    
    /*
      method for updating package details.
    */
    public PageReference updatePacks() {
        try {
            Boolean error = false; 
            if(packageWrapperList != null) {
                List<Package_List__c> PLS = new List<Package_List__c>();
                MAP<Id, RMA_Line_Item__c> rmaliMap = new MAP<Id, RMA_Line_Item__c>(); 
                for(packageWrapper pw: packageWrapperList) {
                    if(pw.qtyToPack > pw.qtyToPick && pw.pkgSelected == true) { errorMsg2 = 'Packed quantity cannot be greater than picked Quantity.'; error = true; break; }
                }
                if(!error) { Package2Create.Active__c = true;
                            if(Package2Create != null) { if(Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()) { DMLManager.upsertAsUser(Package2Create); }  else{ /*no access */ } }
                    for(Integer i=1; i<=packageWrapperList.size(); i++) {
                        if(packageWrapperList[i-1].pkgSelected == true) { Package_List__c packageList = new Package_List__c();                            
                            packageList.Name = 'Package List - '+i;
                            packageList.Active__c = true;
                            packageList.Package__c = Package2Create.Id;
                            packageList.Quantity__c = packageWrapperList[i-1].qtyToPack;
                            packageList.Return_Merchandise_Authorisation__c = packageWrapperList[i-1].rmali.Return_Merchandise_Authorisation__c;
                            packageList.RMA_Line_Item__c = packageWrapperList[i-1].rmali.Id;
                            if(packageWrapperList[i-1].rmali.Packed_Quantity__c == null) packageWrapperList[i-1].rmali.Packed_Quantity__c = packageWrapperList[i-1].qtyToPack; else packageWrapperList[i-1].rmali.Packed_Quantity__c += packageWrapperList[i-1].qtyToPack;
                            
                            rmaliMap.put(packageWrapperList[i-1].rmali.Id, packageWrapperList[i-1].rmali);
                            PLS.add(packageList);
                        }
                    }    
                            if(PLS.size() > 0) { if(Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()) { DMLManager.UpsertAsUser(PLS); } else{ /*no access */ }
                                                if(Schema.sObjectType.MRP__c.isCreateable() && Schema.sObjectType.MRP__c.isUpdateable()) { DMLManager.UpsertAsUser(rmaliMap.Values()); } else{  /*no access */ }
                    } createPacks(); }} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for updating the details of created packages and package list
    */
    public PageReference editPackage() {
        try {
            Set<Id> rmaIds = new Set<Id>();
            Packages = new List<Package__c>();
            currentItems = new List<RMA_Line_Item__c>();    
            if(pack2updateId != null) {
                if(Schema.sObjectType.Package__c.isAccessible()) { Package2Create = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Return_Merchandise_Authorisation__r.SO__r.Account__c, Shipment__r.Name from Package__c where (Id =\'' + String.escapeSingleQuotes(pack2updateId) + '\')'); } 
                packMap = new Map <Id, Package__c>(Packages);
                
                if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) { currentItems = Database.query('select ' + String.escapeSingleQuotes(RMALIFields) + ' ,Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.SO__r.Name, SOLI__r.Base_Price__c, SOLI__r.Price_Product__c, Return_Merchandise_Authorisation__r.SO__r.Account__r.Name, Return_Merchandise_Authorisation__r.Organisation__c, '+
                                                                                        +' SOLI__r.Product__r.Item_Description__c, SOLI__r.Product__r.Name, SOLI__r.Asset__r.Name, SOLI__r.Product__r.Preview_Image__c, SOLI__r.Product__r.Picture__c, SOLI__r.Product__r.Weight__c, SOLI__r.Product__r.Barcode__c from RMA_Line_Item__c where (Return_Merchandise_Authorisation__c =\'' + String.escapeSingleQuotes(Package2Create.Return_Merchandise_Authorisation__c) + '\') order by Return_Merchandise_Authorisation__c ASC');                            
                }  String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');
                   if(Schema.sObjectType.Shipment__c.isAccessible()) Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where (Package__c =\'' + String.escapeSingleQuotes(Package2Create.Return_Merchandise_Authorisation__c) + '\' And Status__c !=\'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');
                
                if(Schema.sObjectType.Package_List__c.isAccessible()) packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(Package2Create.Id) + '\' And Active__c = true) Order by CreatedDate Asc');
                
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
                for(RMA_Line_Item__c rmali : currentItems) { packageWrapper PW = new packageWrapper();
                    List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                    for(Package_List__c pl : packageLists){
                       if(pl.RMA_Line_Item__c == rmali.Id) { PW.rmali = rmali;
                            PW.qtyToPick = pl.Quantity__c;
                            PW.qtyToPack = pl.Quantity__c;                                
                            innerPackageWrapper ipw = new innerPackageWrapper();
                            ipw.pack = String.valueof(pl.Package__c);
                            ipw.packege = packMap.get(pl.Package__c);
                            ipw.packageList = pl;
                            
                            ipw.packList.add(new SelectOption('','--None--'));
                            if(ipw.packege.Status__c == 'Shipped' || ipw.packege.Status__c == 'Picked Up' || ipw.packege.Status__c == 'Delivered') ipw.packList.add(new SelectOption(String.valueof(ipw.packege.Id),ipw.packege.Name__c)); 
                            
                            for(Package__c P : Packages){
                                if((P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') && (ipw.packege.Status__c != 'Shipped' && ipw.packege.Status__c != 'Picked Up' && ipw.packege.Status__c != 'Delivered'))
                                ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c));  
                            } ipwList.add(ipw);
                        }
                    } if(ipwList.size() > 0) { PW.innerPackList = ipwList;  packageWrapperList.add(PW); }
                } CreatePack = true; isAwaiting = false;           } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting created packages
    */
    public PageReference deletePackage() {
        try {
            Set<Id> rmaliIds = new Set<Id>();
            MAP<Id, RMA_Line_Item__c> rmaliMap = new MAP<Id, RMA_Line_Item__c>();
            if(pack2updateId != null) {                               
                List<Package_List__c> packList = new List<Package_List__c>(); 
                List<RMA_Line_Item__c> rmaliList = new List<RMA_Line_Item__c>();
                if(Schema.sObjectType.Package_List__c.isAccessible()) packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,RMA_Line_Item__r.Packed_Quantity__c from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack2updateId) + '\' And Active__c = true) Order by CreatedDate Asc');
                for(Package_List__c pls: packList) { rmaliIds.add(pls.RMA_Line_Item__c); }
                if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) rmaliList = Database.query('select ' + String.escapeSingleQuotes(RMALIFields) + ' from RMA_Line_Item__c where Id In: rmaliIds');                
                for(Package_List__c pl: packList) {
                    for(RMA_Line_Item__c rmalis: rmaliList) {
                        if(pl.RMA_Line_Item__c == rmalis.Id) {
                            if(rmalis.Packed_Quantity__c != null) {
                                rmalis.Packed_Quantity__c = rmalis.Packed_Quantity__c - pl.Quantity__c;
                                rmaliMap.put(rmalis.Id, rmalis);
                            } break;
                        }
                    }
                }
            }
            if(rmaliMap.size() > 0) { if(Schema.sObjectType.RMA_Line_Item__c.isCreateable() && Schema.sObjectType.RMA_Line_Item__c.isUpdateable()) { DMLManager.UpsertAsUser(rmaliMap.Values()); } else{ /* no access*/ } } 
            if(pack2updateId != null && Package__c.sObjectType.getDescribe().isDeletable()) { delete new Package__c(Id = pack2updateId);  } else{ /* No access to delete*/ }          
            createPacks();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
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
                for(Package__c p : [select Name, Barcode__c, Name__c, Owner.Name, CreatedDate, Weight__c, Return_Merchandise_Authorisation__r.SO__r.Account__r.Name, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Customer__r.Name, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Address_Line1__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Address_Line2__c, 
                                   Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Address_Line3__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.City__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.County__c, Return_Merchandise_Authorisation__r.SO__r.Contact__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Country__c, 
                                   Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Phone, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Fax, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Name, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.State__c, 
                                   Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Postal_Code__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, RMA_Line_Item__c, Package__r.Return_Merchandise_Authorisation__c, RMA_Line_Item__r.SOLI__r.Product__r.SKU__c, RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.SOLI__r.Quantity__c, RMA_Line_Item__r.SOLI__r.Sales_Order__r.Name, 
                                   RMA_Line_Item__r.SOLI__r.Total_Price__c,  RMA_Line_Item__r.SOLI__r.ReturnedQuantity__c, RMA_Line_Item__r.SOLI__r.Name, SKU__c, Package_Weight__c, RMA_Line_Item__r.SOLI__r.Description__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {packListRecords = new List<Package_List__c>(); for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); } packageRecords.put(p,packListRecords); contactId = p.Return_Merchandise_Authorisation__r.SO__r.Contact__c; newPackageId = p.Id;
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); Database.rollback(sp); return page.stockdispatching_SR_PackingSlips;
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
                for(Package__c p : [select Name, Barcode__c, Name__c, Owner.Name, CreatedDate, Weight__c, Return_Merchandise_Authorisation__r.SO__r.Account__r.Name, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Customer__r.Name, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Address_Line1__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Address_Line2__c, 
                                   Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Address_Line3__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.City__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.County__c, Return_Merchandise_Authorisation__r.SO__r.Contact__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Country__c, 
                                   Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Phone, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Fax, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Name, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.State__c, 
                                   Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__r.Postal_Code__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, RMA_Line_Item__c, Package__r.Return_Merchandise_Authorisation__c, RMA_Line_Item__r.SOLI__r.Product__r.SKU__c, RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.SOLI__r.Quantity__c, RMA_Line_Item__r.SOLI__r.Sales_Order__r.Name, 
                                   RMA_Line_Item__r.SOLI__r.Total_Price__c,  RMA_Line_Item__r.SOLI__r.ReturnedQuantity__c, RMA_Line_Item__r.SOLI__r.Name, SKU__c, Package_Weight__c, RMA_Line_Item__r.SOLI__r.Description__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {packListRecords = new List<Package_List__c>(); for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); } packageRecords.put(p,packListRecords);  contactId = p.Return_Merchandise_Authorisation__r.SO__r.Contact__c; newPackageId = p.Id;
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});Database.rollback(sp); return page.stockdispatching_SR_PackingLists;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return null;
    }
    
    /*
      method for displaying available shipment list from the system.
    */
    public PageReference createShipments() {
        try {
            Set<Id> rmaIds = new Set<Id>();
            shipmentList = new List<Shipment__c>();
            shipmentWrapperList = new List<Wrappers>();
            
            if(rmaWrapperList.size() > 0){ 
                rmaSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : rmaWrapperList) { 
                    if(sow.rmaSelected == true) { 
                        rmaIds.add(sow.RMA.Id); 
                        rmaSelectedWrapperList.add(sow); 
                        if(salesreturnId == sow.RMA.Id) salesreturnId = Null;
                    }
                    if(salesreturnId == sow.RMA.Id){ rmaSelectedWrapperList.add(sow); rmaIds.add(sow.RMA.Id); }  }  }else { for(Wrappers sow : rmaSelectedWrapperList) { rmaIds.add(sow.RMA.Id);  }
            }           
            
            if(rmaIds.size() > 0) {
                if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) shipmentList = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' ,RecordType.Name, Sales_Order__r.Name, Work_Order__r.Name, Purchase_Orders__r.Name, Transfer_Order__r.Name, Return_Merchandise_Authorisation__r.Name, Customer__r.Name, Shipping_Address__r.Customer__r.Name, Shipping_Address__r.Address_Line1__c, '+
                                                                                      +' Shipping_Address__r.Address_Line2__c, Shipping_Address__r.Address_Line3__c, Shipping_Address__r.City__c, Shipping_Address__r.County__c, Shipping_Address__r.Country__c, Shipping_Address__r.Contact__r.Phone, Shipping_Address__r.Contact__r.Fax, Shipping_Address__r.Contact__r.Name, '+
                                                                                      +' Shipping_Address__r.Contact__r.Email, Shipping_Address__r.State__c, Shipping_Address__r.Postal_Code__c from Shipment__c where (Return_Merchandise_Authorisation__c In: rmaIds And Active__c = true) Order by CreatedDate Asc');
                for(Shipment__c shp: shipmentList) { Wrappers wrap = new Wrappers();                    
                                                     wrap.shipM = shp;
                                                     if(wrap.shipM.RecordType.Name == 'UPS Shipping') wrap.shipmentType = 'UPS'; else if(wrap.shipM.RecordType.Name == 'Fedex Shipping') wrap.shipmentType = 'FedEx'; else if(wrap.shipM.RecordType.Name == 'Internal Shipping') wrap.shipmentType = 'Shipment';
                                                     if(shp.ERP7__TrackingNumber__c != null) wrap.trackingNo += shp.ERP7__TrackingNumber__c.replace(',','<br/>');
                                                     shipmentWrapperList.add(wrap);
                } return page.Stockdispatching_SR_Shipment; } else errorMsg = 'Please select an order to proceed.';} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }return null;
    }
    
    /*
      method for deleting shipment
    */
    public PageReference deleteShipment() {
        try {
            if(packageId != null) shipmentWrapperList.remove(Integer.valueof(packageId));
            if(shipmentId != null && Shipment__c.sObjectType.getDescribe().isDeletable()) { delete new Shipment__c(Id = shipmentId);} else{ /* no access */ } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
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
                List<Package_List__c> packageItemList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,RMA_Line_Item__r.SOLI__r.Product__r.SKU__c, RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.Return_Merchandise_Authorisation__r.Name, '+
                                                        +' RMA_Line_Item__r.Name, RMA_Line_Item__r.Quantity_Return__c, RMA_Line_Item__r.Total_Deduction__c,  Package__r.Shipment__c, Package__r.Name from Package_List__c where Package__c In: pkgIds'); 
                for(Shipment__c sh: shipList) { List<Package_List__c> pkgItemList = new List<Package_List__c>();
                    Boolean adding = false;
                    for(Package_List__c pkl: packageItemList) { if(pkl.Package__r.Shipment__c == sh.Id) { pkgItemList.add(pkl); adding = true; } }
                    if(adding) shipmentRecords.put(sh, pkgItemList); 
                    newShipmentId = sh.Id;
                    contactId = sh.Customer_Contact__c;                    
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); Database.rollback(sp); return page.stockdispatching_SR_ShippingSlips;
            } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for generating barcodes from different sObject fields as pdf.
    */
    public PageReference createBarcodesPage() {
        return page.stockdispatching_SR_printbarcodes;
    }    
    public pageReference createOrder() {                   
        pageReference pag = new pageReference('/apex/ERP7__stockdispatching_SalesReturn');
        pag.setRedirect(true);
        return pag;
    }
    public PageReference back() {
        pageReference pag = new pageReference('/apex/ERP7__stockdispatching_SalesReturn');
        pag.setRedirect(true);
        return pag;
    }
    public PageReference createUPSShipment() {
        try { 
            String sType = '';
            Boolean error = false;
            selectedPackIds = new List<Id>();            
            if(lineItemWrapperList != null) {
                for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) { if(sType == '') sType = lw.pack.Shipment_Type__c; if(sType == lw.pack.Shipment_Type__c) { selectedPackIds.add(lw.pack.Id); if(shipmentType == null) shipmentType = lw.pack.Shipment_Type__c;} else { errorMsg1 = 'You cannot select packages with different shipment type.'; error = true; break; }
                                                               } else { if(packageId != null && packageId != '') selectedPackIds.add(packageId); }}}  if(!error) { errorMsg1 = '';if(selectedPackIds.size() > 0 && shipmentType == 'UPS') { showUPSComponent = true; shipId = ''; retValue = 'SR'; }   else if((shipmentId != null && shipmentId != '') && shipmentType == 'UPS') { showUPSComponent = true; shipId = shipmentId; retValue = 'SR'; } else if(selectedPackIds.size() > 0 && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = ''; retValue = 'SR'; }  else if((shipmentId != null && shipmentId != '') && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = shipmentId; retValue = 'SR'; }else if(selectedPackIds.size() > 0 && shipmentType == 'FedEx') { showfedexComponent = true; shipId = ''; retValue = 'SR'; }                                                                      else if((shipmentId != null && shipmentId != '') && shipmentType == 'FedEx') { showFedExComponent = true; shipId = shipmentId; retValue = 'SR'; }
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return null;
    }
    
    /*
      scanner methods definitions
    */
    public PageReference scannerMethod() {
        try {
            RMAList = Database.query('select ' + String.escapeSingleQuotes(RMAFields) + ' , SO__r.Ship_To_Address__r.Address_Line1__c, SO__r.Ship_To_Address__r.Address_Line2__c, SO__r.Ship_To_Address__r.Address_Line3__c, SO__r.Ship_To_Address__r.City__c, SO__r.Ship_To_Address__r.County__c, SO__r.Ship_To_Address__r.State__c, '+
                      +' SO__r.Ship_To_Address__r.Postal_Code__c, SO__r.Ship_To_Address__r.Country__c, SO__r.Account__r.Name, SO__r.Name, SO__r.Barcode__c from Return_Merchandise_Authorisation__c  where (Active__c = true And Barcode__c =\'' + String.escapeSingleQuotes(barcode.trim()) + '\') limit 1'); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    public PageReference scannerMethodCustom() {
        try {            
            errorMsg = barcodeLocMsg = '';
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); }
            else if(mybarcode == 'PICK') { return redirect2NextTab(); }
            else if(mybarcode == 'PACK') { return saveRMALIs(); }
            else if(mybarcode == 'SHIP') { createShipments(); }
            
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<RMA_Line_Item__c> rmaliListcheck = new List<RMA_Line_Item__c>();
            
            if(Schema.sObjectType.Site__c.isAccessible()) siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];        
            if(Schema.sObjectType.Location__c.isAccessible()) SSLList = [Select Id, Name, Barcode__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];            
            if(Schema.sObjectType.StorageContainer__c.isAccessible()) binList = [Select Id, Name, Barcode__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) rmaliListcheck = [select Id, Name, Barcode__c, SOLI__r.Product__r.Barcode__c from RMA_Line_Item__c where Barcode__c =:barcode.trim() Or SOLI__r.Product__r.Barcode__c =:barcode.trim() limit 1];
            
            if(rmaliListcheck.size() > 0 && barcodeLoc != '' && barcodeLoc != Null) {  for(Wrappers W : rmaliWrapperList){  if(!W.rmaliSelected && W.AddressName==barcodeLoc && (barcode.trim() == W.rmali.Barcode__c || barcode.trim() == W.rmali.SOLI__r.Product__r.Barcode__c)){ barcodeLoc = barcodeLocMsg = ''; W.rmaliSelected = true;  return null; }             
                }
            }
            for(Wrappers W : rmaliWrapperList){
                if(!W.rmaliSelected && ((siteList.size()>0 && W.AddressName == siteList[0].Id) || (SSLList.size()>0 && W.AddressName == SSLList[0].Id) || (binList.size()>0 && W.AddressName == binList[0].Id))) { barcodeLocMsg = barcodeLoc = '';integer wCount = 0;String addrs = W.AddressName;for(Wrappers WA : rmaliWrapperList){ if(addrs == WA.AddressName) wCount+=1; }if(wCount == 1) W.rmaliSelected = true;  else if(wCount > 1) { barcodeLocMsg = 'There are multiple products in the stock ';if(siteList.size() > 0) barcodeLocMsg = barcodeLocMsg+'"'+siteList[0].Barcode__c+'"'+' please scan the product to pick.';else if(SSLList.size() > 0) barcodeLocMsg = barcodeLocMsg+'"'+SSLList[0].Barcode__c+'"'+' please scan the product to pick.';else if(binList.size() > 0) barcodeLocMsg = barcodeLocMsg+'"'+binList[0].Barcode__c+'"'+' please scan the product to pick.'; barcodeLoc = W.AddressName;} break;
                }             
            }
            if(RMAList.size() > 0) { rmaWrapperList = new List<Wrappers>();for(Return_Merchandise_Authorisation__c rmas: RMAList) { Wrappers wrap = new Wrappers();wrap.rmaSelected = true;wrap.RMA = rmas; rmaWrapperList.add(wrap);
                }    
            } if(barcodeLocMsg == '') saveRMALIs();   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    public pageReference scannerMethodCustomPick() {
        try {
            errorMsg = '';
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); }
            else if(mybarcode == 'PICK') { return redirect2NextTab(); }
            else if(mybarcode == 'PACK') { return createPacks(); }
            else if(mybarcode == 'SHIP') { createShipments(); }
            
            if(RMAList.size() > 0) {if(initialScan != true) { initialScan = true; rmaWrapperList = new List<Wrappers>(); }for(Return_Merchandise_Authorisation__c rmas: RMAList) { boolean exist = false;for(Wrappers w: rmaWrapperList) { if(rmas.Id == w.RMA.Id) exist = true; }if(!exist) { Wrappers wrap = new Wrappers(); wrap.rmaSelected = true; wrap.RMA = rmas;rmaWrapperList.add(wrap);   }}  }  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;}public static String sortBy                                { get; set; }    public static String prevSortBy                            { get; set; }public static String orderFormat                           { get; set; }
            
    public List<Wrappers> rmaWrapperList                       { get; set; }    
    public List<Wrappers> rmaliWrapperList                     { get; set; }
    public List<Wrappers> shipmentWrapperList                  { get; set; }    
    public List<Wrappers> rmaSelectedWrapperList               { get; set; }
    public List<Wrappers> rmaliSelectedWrapperList             { get; set; }      public List<Wrappers> shipmentSelectedWrapperList          { get; set; }  
    public class Wrappers implements Comparable {                
        public String SD                                       { get; set; }        
        public String WN                                       { get; set; } 
        public String LN                                       { get; set; } 
        public String binName                                  { get; set; }                 
        public String stockId                                  { get; set; } 
        public Package__c sPkg                                 { get; set; }        
        public String AddressName                              { get; set; }        
        public Integer raisedQty                               { get; set; }
        public Boolean rmaSelected                             { get; set; }        
        public Boolean shipSelected                            { get; set; }    
        public Integer requiredQty                             { get; set; }
        public String locationName                             { get; set; }
        public String trackingNo                               { get; set; }
        public Shipment__c shipM                               { get; set; }
        public String shipmentType                             { get; set; }
        public Integer remainingQty                            { get; set; }
        public Boolean rmaliSelected                           { get; set; }  
        public Boolean include                                 { get; set; }
        public String batchLotCode                             { get; set; }   
        public String warehouseName                            { get; set; } 
        public Boolean isRMALIawaiting                         { get; set; }       
        public Decimal inventoryStock                          { get; set; } 
        public RMA_Line_Item__c RMALI                          { get; set; }                   
        public Boolean isAvailablePackages                     { get; set; }
        public List<SelectOption> Address                      { get; set; }
        public Boolean isAvailableShipments                    { get; set; }
        public List<SelectOption> CurrentBins                  { get; set; }                
        public Boolean isAllShipmentsDelivered                 { get; set; }        
        public List<SelectOption> CurrentLocations             { get; set; }
        public List<SelectOption> CurrentWarehouses            { get; set; }
        public Return_Merchandise_Authorisation__c RMA         { get; set; } 
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
            AddressName = '';
            include = false;            
            binName = null;
            stockId = null;                  
            raisedQty = 0;
            requiredQty = 0;
            remainingQty = 0;
            trackingNo = ''; 
            inventoryStock = 0;                  
            rmaSelected = false;  
            rmaliSelected = false;
            shipSelected = false;
            locationName = null;                                   
            isRMALIawaiting = false;                          
            warehouseName = null;
            shipM = new Shipment__c();
            sPkg = new Package__c();            
            isAvailablePackages = false;
            isAvailableShipments = false;
            isAllShipmentsDelivered = false;                
            Address = new List<SelectOption>();                                
            RMALI = new RMA_Line_Item__c();
            CurrentBins = new List<SelectOption>();
            CurrentLocations = new List<SelectOption>();
            CurrentWarehouses = new List<SelectOption>();                        
            RMA = new Return_Merchandise_Authorisation__c();
            
            BatchLotCodes = new List<SelectOption>(); 
            MRP = new ERP7__MRP__c(); 
            MRPsWrapperList = new List<Wrappers>(); 
            product = new product2();   
            Asset = new Asset__c();
            serialized = false;
            SerialNumbers = new Stock_Outward_Line_Item__c(); }  public Integer compareTo(Object objToCompare) {if(sortBy == 'WN') { Integer result = WN.compareTo(((Wrappers)objToCompare).WN);return (orderFormat == 'ASC')? result : result * -1; } else if(sortBy == 'LN') { Integer result = LN.compareTo(((Wrappers)objToCompare).LN);return (orderFormat == 'ASC')? result : result * -1; } else if(sortBy == 'SD') { Integer result = SD.compareTo(((Wrappers)objToCompare).SD);return (orderFormat == 'ASC')? result : result * -1; }  return 0; }               
    }
    public class packageWrapper {
        public Decimal qtyToPick                                 { get; set; }   
        public Decimal qtyToPack                                 { get; set; }
        public Boolean pkgSelected                               { get; set; } 
        public RMA_Line_Item__c rmali                            { get; set; }
        public List<innerPackageWrapper> innerPackList           { get; set; }        
        
        public packageWrapper(){ 
            qtyToPick = 0;
            qtyToPack = 0;
            pkgSelected = false;
            rmali = new RMA_Line_Item__c();
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
    public class innerPackageWrapper {
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
}