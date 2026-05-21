public with sharing class PickPackShipController {
   
    public PageReference InboundOrOutbound() {
      return null;
    }

    public PO__c PO                                                    { get; set; }
    public WO__c WO                                                    { get; set; }                       
    public Id LineItemId                                               { get; set; }         
    public String shipId                                               { get; set; }    
    public String result                                               { get; set; }  
    public String retValue                                             { get; set; }
    public String imageURL                                             { get; set; }    
    public String SOFields                                             { get; set; } 
    public String binFields                                            { get; set; }
    public List<Id> soliIds                                            { get; set; }    
    public String errorMsg                                             { get; set; }
    public String errorMsg1                                            { get; set; }                
    public String errorMsg2                                            { get; set; }
    public String prodFields                                           { get; set; }
    public String searchText                                           { get; set; }               
    public String SOLIFields                                           { get; set; } 
    public String MRPFields                                            { get; set; } 
    public String PPLIFields                                           { get; set; } 
    public String packageId                                            { get; set; }
    public String shipmentId                                           { get; set; }
    public Integer nextIdent                                           { get; set; }     
    public String orderNumber                                          { get; set; }
    public InternalShipping Is                                         { get; set; }    
    public String pkgTypeValue                                         { get; set; }    
    public String shipmentType                                         { get; set; }        
    public String PackageFields                                        { get; set; }
    public String ShipmentFields                                       { get; set; }  
    public String pack2updateId                                        { get; set; }
    public String service_code                                         { get; set; }    
    public String delivery_date                                        { get; set; }    
    public Shipment__c Shipment                                        { get; set; }  
    public static Integer addRow                                       { get; set; }
    public List<Id> selectedPackIds                                    { get; set; }
    public Boolean time_in_cost_tab                                    { get; set; }
    public String ShipmentRecTypeId                                    { get; set; }     
    public String packageListFields                                    { get; set; }       
    public static Integer toDelIdent                                   { get; set; }     
    public String siteFields                                           { get; set; } 
    public Boolean CreatePack                                          { get; set; }              
    public Boolean isAwaiting                                          { get; set; }
    public String customerId                                           { get; set; }
    public Integer rowCounter                                          { get; set; }
    public String salesorderId                                         { get; set; } 
    public String channelFields                                        { get; set; }     
    public Map<Id, Id> stockMap                                        { get; set; }    
    public String locationsFields                                      { get; set; }         
    public String warehouseFields                                      { get; set; }     
    public Boolean showUPSComponent                                    { get; set; }                  
    public Package__c Package2Create                                   { get; set; }
    public List<Location__c> SSLList                                   { get; set; }               
    public List<Package__c> Packages                                   { get; set; }         
    public String service_description                                  { get; set; }    
    public List<Shipment__c> Shipments                                 { get; set; }
    public Map<Id, Id> StockOutwardMap                                 { get; set; }
    public Map<Id, Package__c> packMap                                 { get; set; }
    transient public List<Sales_Order__c> SOList                       { get; set; }    
    public List<Package__c> packageList                                { get; set; }    
    public List<Package_List__c> packList                              { get; set; }
    public List<Shipment__c> shipmentList                              { get; set; }
    public List<Inventory_Stock__c> WIISList                           { get; set; } 
    public List<StorageContainer__c> binList                           { get; set; } 
    public String PackageCustomSettingFields                           { get; set; }                      
    public List<Package_List__c> packageLists                          { get; set; }        
    public List<Purchase_Line_Items__c> Polis                          { get; set; }    
    public List<Work_Order_Line_Items__c> Wolis                        { get; set; }  
    public Boolean showInternalShippingComponent                       { get; set; }    
    public List<Package_List__c> packListRecords                       { get; set; }
    public List<Sales_Order_Line_Item__c> soliList                     { get; set; } 
    public List<packageWrapper> packageWrapperList                     { get; set; }     
    public List<lineItemWrapper> lineItemWrapperList                   { get; set; }   
    public List<Stock_Outward_Line_Item__c> PPLIList                   { get; set; }    
    public List<Sales_Order_Line_Item__c> currentItems                 { get; set; }                     
    public Map<Id, List<Package_List__c>> packageListMap               { get; set; }     
    public List<Stock_Outward_Line_Item__c> ppliItemList               { get; set; }        
    public List<packageWrapper> selectedPackageWrapperList             { get; set; }        
    public List<Stock_Outward_Line_Item__c> PPLIList2Delete            { get; set; }
    public Map<Id, List<Stock_Outward_Line_Item__c>> ppliMap           { get; set; }            
    public List<Distribution_Channel__c> DistributionChannels          { get; set; }     
    public Map<Package__c, List<Package_List__c>> packageRecords       { get; set; }       
    public Map<Shipment__c, List<Package_List__c>> shipmentRecords     { get; set; }    
    public String barcode                                              { get; set; }       
    Public Boolean scanned                                             { get; set; }
    public PrintBarcodes PB                                            { get; set; }          
    public String barcodeLoc                                           { get; set; }      
    public String sfdcBaseURL                                          { get; set; }
    public Boolean initialScan                                         { get; set; }
    public String barcodeLocMsg                                        { get; set; }      
    public EmailTemplate packingTemplate                               { get; set; } 
    public EmailTemplate shippingTemplate                              { get; set; } 
    public Employees__c Employee                                       { get; set; }
    public List<SelectOption> channelSites                             { get; set; }
    public Id selectedSite                                             { get; set; }
    public String selectedOrders                                       { get; set; }
    public Boolean showFedexComponent                                  { get; set; }  
    public Integer ScanNo                                              { get; set; }
    public ERP7__Sales_Order__c sales                                  { get; set; }
    public Boolean showSN                                              { get; set; } 
    public Boolean showBatch                                           { get; set; } 
    public ERP7__Logistic__c Logistic                                  { get; set; } 
    public String logFields                                            { get; set; } 
    /*
      constructor
    */ 
       
    public PickPackShipController() {
        try {
            Logistic = new ERP7__Logistic__c(Type__c='Outbound');
            binFields = UtilClass.selectStarFromSObject('ERP7__StorageContainer__c');
            utilClass.FLSCheck(binFields.split(','),'ERP7__StorageContainer__c');
            siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c');         
            utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c');          
            SOFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order__c');
            utilClass.FLSCheck(SOFields.split(','),'ERP7__Sales_Order__c');
            PackageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');    
            utilClass.FLSCheck(PackageFields.split(','),'ERP7__Package__c');            
            ShipmentFields =  UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            utilClass.FLSCheck(ShipmentFields.split(','),'ERP7__Shipment__c');          
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
            utilClass.FLSCheck(packageListFields.split(','),'ERP7__Package_List__c');
            SOLIFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c');
            MRPFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(SOLIFields.split(','),'ERP7__Sales_Order_Line_Item__c');
            channelFields = UtilClass.selectStarFromSObject('ERP7__Distribution_Channel__c'); 
            utilClass.FLSCheck(channelFields.split(','),'ERP7__Distribution_Channel__c');
            locationsFields = UtilClass.selectStarFromSObject('ERP7__Location__c'); 
            utilClass.FLSCheck(locationsFields.split(','),'ERP7__Location__c');
            PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
            utilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');           
            PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');           
            warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');       
            utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c');          
            prodFields = UtilClass.selectStarFromSObject('Product2');
            utilClass.FLSCheck(prodFields.split(','),'Product2'); 
            logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');          
            
            ScanNo = 0;                 
            errorMsg = '';
            nextIdent = 0; 
            showUPSComponent = false;  
            showFedexComponent = false;                      
            soliIds = new List<Id>();        
            stockMap = new Map<Id, Id>();            
            SSLList = new List<Location__c>();                            
            Package2Create = new Package__c();
            SOList = new List<Sales_Order__c>();
            StockOutwardMap = new Map<Id, Id>(); 
            showInternalShippingComponent = false;                
            soliWrapperList = new List<Wrappers>();
            WIISList = new List<Inventory_Stock__c>();   
            binList = new List<StorageContainer__c>();            
            soSelectedWrapperList = new List<Wrappers>();                    
            soliList = new List<Sales_Order_Line_Item__c>();
            PPLIList = new List<Stock_Outward_Line_Item__c>();            
            packageListMap = new Map<Id, List<Package_List__c>>();
            ppliItemList = new List<Stock_Outward_Line_Item__c>();            
            PPLIList2Delete = new List<Stock_Outward_Line_Item__c>();
            ppliMap =  new Map<Id, List<Stock_Outward_Line_Item__c>>();
            showSN = false;
            showBatch = false;
            
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visual.force.com');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            imageURL = '/servlet/servlet.FileDownload?file=';
            if(!Schema.sObjectType.Document.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Document.Label));
            else {   List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
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
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c,   Channel__c, Site__c, Site__r.Name
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
            
            authorisedOrders();
            if(ApexPages.CurrentPage().getParameters().get('soId') != '' && ApexPages.CurrentPage().getParameters().get('soId') != null) { salesorderId = ApexPages.CurrentPage().getParameters().get('soId'); redirect2NextTab(); }
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for displaying all authorised sales orders which are not fulfilled
    */   
    public void authorisedOrders() {
        try {
            Set<Id> soIds = new Set<Id>();
            soWrapperList = new List<Wrappers>();
            List<Sales_Order_Line_Item__c> soliList = new List<Sales_Order_Line_Item__c>();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>(); 
            String salesorderId = ApexPages.CurrentPage().getParameters().get('soId');  
            String tempPOChannel = Employee.Channel__c;   
            
            // Take outbound logistics and map it with SO
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>();       
            if(!Schema.sObjectType.Sales_Order__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order__c.Label));
            else { 
                if(salesorderId != null && salesorderId != '') {
                    SOList = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' , Ship_To_Address__r.Address_Line1__c, Ship_To_Address__r.Address_Line2__c, Ship_To_Address__r.Address_Line3__c, Ship_To_Address__r.City__c, Ship_To_Address__r.County__c, Ship_To_Address__r.Country__c, '+
                             +' Ship_To_Address__r.State__c, Ship_To_Address__r.Postal_Code__c, Account__r.Name from Sales_Order__c where (Is_Closed__c = false And fulfilled__c = false And Total_Quantity__c > 0 And Id =\'' + String.escapeSingleQuotes(salesorderId) + '\') And Channel__c =: tempPOChannel And ERP7__Ready_To_Pick_Pack__c = true Order by Expected_Date__c Asc Limit 1');
                } else {
                    SOList = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' , Ship_To_Address__r.Address_Line1__c, Ship_To_Address__r.Address_Line2__c, Ship_To_Address__r.Address_Line3__c, Ship_To_Address__r.City__c, Ship_To_Address__r.County__c, '+
                             +' Ship_To_Address__r.Country__c, Ship_To_Address__r.State__c, Ship_To_Address__r.Postal_Code__c, Account__r.Name from Sales_Order__c where (Is_Closed__c = false And fulfilled__c = false And Total_Quantity__c > 0) And Channel__c =: tempPOChannel And ERP7__Ready_To_Pick_Pack__c = true Order by Expected_Date__c Asc Limit 1000');
                }
            } for(Sales_Order__c sos : SOList) { soIds.add(sos.Id); }                                   
            if(soIds.size() > 0) {
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
                else soliList = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' from Sales_Order_Line_Item__c where (Sales_Order__c In : soIds)');
                
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Sales_Order__c In: soIds)'); 
                
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Sales_Order__c In: soIds)'); 
            }
            if(SOList.size() > 0) {
                for(Sales_Order__c sos : SOList) { Wrappers wrap = new Wrappers();  
                    
                    for(Sales_Order_Line_Item__c soli : soliList) { if(soli.Sales_Order__c == sos.Id && soli.Picked_Quantity__c != soli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }
                    for(Package__c pkg : pkgList) { if(pkg.Sales_Order__c == sos.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) { 
                        if(ship.Sales_Order__c == sos.Id) { wrap.isAvailableShipments = true;
                                                            if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++;
                                                            if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;
                      wrap.SO = sos;
                      soWrapperList.add(wrap);
                }
            } else errorMsg = 'Sorry, no records available to view.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      method for searching SO's upon salesorder / customer
    */
    public PageReference searchSOs() {
        try {
            Set<Id> soIds = new Set<Id>();
            soList = new List<Sales_Order__c>();
            soWrapperList = new List<Wrappers>();
            List<Sales_Order_Line_Item__c> soliList = new List<Sales_Order_Line_Item__c>();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>(); 
            String tempPOChannel = Employee.Channel__c;  
            if(!Schema.sObjectType.Sales_Order__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order__c.Label));
            else {
                if(searchText != null && searchText != '') {
                    String searchString = '%'+String.escapeSingleQuotes(searchText)+'%';
                    SOList = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' , Ship_To_Address__r.Address_Line1__c, Ship_To_Address__r.Address_Line2__c, Ship_To_Address__r.Address_Line3__c, Ship_To_Address__r.City__c, Ship_To_Address__r.County__c, Ship_To_Address__r.Country__c, '+
                             +' Ship_To_Address__r.State__c, Ship_To_Address__r.Postal_Code__c, Account__r.Name from Sales_Order__c where (Is_Closed__c = false And fulfilled__c = false And (Name like: searchString OR Customer__r.Name like: searchString)) And Channel__c =: tempPOChannel And ERP7__Ready_To_Pick_Pack__c = true Order by CreatedDate Asc Limit 1000');
                } else {
                    SOList = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' , Ship_To_Address__r.Address_Line1__c, Ship_To_Address__r.Address_Line2__c, Ship_To_Address__r.Address_Line3__c, Ship_To_Address__r.City__c, Ship_To_Address__r.County__c, Ship_To_Address__r.Country__c, '+
                             +' Ship_To_Address__r.State__c, Ship_To_Address__r.Postal_Code__c, Account__r.Name from Sales_Order__c where (Is_Closed__c = false And fulfilled__c = false) And Channel__c =: tempPOChannel And ERP7__Ready_To_Pick_Pack__c = true Order by CreatedDate Asc Limit 1000');
                }
            } for(Sales_Order__c sos : SOList) { soIds.add(sos.Id); }
            if(soIds.size() > 0) {
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
                else soliList = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' from Sales_Order_Line_Item__c where (Sales_Order__c In : soIds)'); 
                
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else pkgList = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' from Package__c where (Sales_Order__c In: soIds)');
                
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else shipList = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Sales_Order__c In: soIds)'); 
            }              
            if(SOList.size() > 0) { errorMsg = '';
                for(Sales_Order__c sos : SOList) { Wrappers wrap = new Wrappers();  
                    
                    for(Sales_Order_Line_Item__c soli : soliList) { if(soli.Sales_Order__c == sos.Id && soli.Picked_Quantity__c != soli.Packed_Quantity__c) { wrap.isAvailablePackages = true; break; } }
                    for(Package__c pkg : pkgList) { if(pkg.Sales_Order__c == sos.Id) { wrap.isAvailablePackages = true; break; } }
                    Integer count = 0;
                    for(Shipment__c ship : shipList) { 
                        if(ship.Sales_Order__c == sos.Id) { wrap.isAvailableShipments = true;
                                                            if(ship.Status__c == 'Shipped' || ship.Status__c == 'Delivered') count++;
                                                            if(ship.ERP7__TrackingNumber__c != null) wrap.trackingNo += ship.ERP7__TrackingNumber__c.replace(',','<br/>');
                        } 
                    } if(count > 0 && count == shipList.size()) wrap.isAllShipmentsDelivered = true;
                      wrap.SO = sos;
                      soWrapperList.add(wrap);                    
                }
            } else errorMsg = 'Sorry, no records available to view.';                              
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null; 
    }
    
    /*
      method for barcode scan.
    */
    public pageReference scannerMethod() {
        try { 
            if(!Schema.sObjectType.Sales_Order__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order__c.Label));
            else { SOList = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' , Ship_To_Address__r.Address_Line1__c, Ship_To_Address__r.Address_Line2__c, Ship_To_Address__r.Address_Line3__c, Ship_To_Address__r.City__c, Ship_To_Address__r.County__c, '+
                            +' Ship_To_Address__r.Country__c, Ship_To_Address__r.State__c, Ship_To_Address__r.Postal_Code__c, Account__r.Name from Sales_Order__c where (Authorised__c = true And Is_Closed__c = false And fulfilled__c = false And ERP7__Ready_To_Pick_Pack__c = true And Barcode__c =\'' + String.escapeSingleQuotes(barcode.trim()) + '\') Limit 1'); 
            }                         
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }    
    public pageReference scannerMethodCustom() {
        try {
            errorMsg = '';
            barcodeLocMsg = '';
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); }
            else if(mybarcode == 'PICK') { return redirect2NextTab(); }
            else if(mybarcode == 'PACK') { return saveSOLIs(); }
            else if(mybarcode == 'SHIP') { createShipments(); }
            
            List<Sales_Order_Line_Item__c> soliListcheck;
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
                        
            if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
            else { 
                if(!Schema.sObjectType.Site__c.Fields.Barcode__c.isAccessible())throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Site__c.Fields.Barcode__c.getLabel()+' of sObject '+Schema.SObjectType.Site__c.getLabel());
                if(!Schema.sObjectType.Site__c.Fields.Name.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Site__c.Fields.Name.getLabel()+' of sObject '+Schema.SObjectType.Site__c.getLabel());
                siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =: barcode.trim() and Active__c = true limit 1]; 
            }
            if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
            else { 
                if(!Schema.sObjectType.Location__c.Fields.Barcode__c.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Location__c.Fields.Barcode__c.getLabel()+' of sObject '+Schema.SObjectType.Location__c.getLabel());
                if(!Schema.sObjectType.Location__c.Fields.Name.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Location__c.Fields.Name.getLabel()+' of sObject '+Schema.SObjectType.Location__c.getLabel());
                SSLList = [Select Id, Name, Barcode__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1]; 
            }
            if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
            else binList = [Select Id, Name, Barcode__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            
            if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
            else { 
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.Fields.Barcode__c.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Sales_Order_Line_Item__c.Fields.Barcode__c.getLabel()+' of sObject '+Schema.SObjectType.Sales_Order_Line_Item__c.getLabel());
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.Fields.Name.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.Sales_Order_Line_Item__c.Fields.Name.getLabel()+' of sObject '+Schema.SObjectType.Sales_Order_Line_Item__c.getLabel());            
                soliListcheck = [select Id, Name, Barcode__c, Product__c, Product__r.Barcode__c from Sales_Order_Line_Item__c where Barcode__c =:barcode.trim() Or Product__r.Barcode__c =:barcode.trim() limit 1]; 
            }    
            
            // If Sales Order is found            
            soWrapperList = new List<Wrappers>();
            if(SOList.size() > 0) { for(Sales_Order__c sos : SOList) { Wrappers wrap = new Wrappers(); wrap.soSelected = true; wrap.SO = sos; soWrapperList.add(wrap); return null; }    
            }
            
            if(siteList.size() > 0 || SSLList.size() > 0 || binList.size() > 0) { 
                 // The Warehouse, location or bin code is found                         
                for(Wrappers W : soliWrapperList) {
                    if(ScanNo == 0 && !W.soliVerified && ((siteList.size()> 0 && W.AddressName == siteList[0].Id) || (SSLList.size()>0 && W.AddressName == SSLList[0].Id) || (binList.size()>0 && W.AddressName == binList[0].Id))) {  barcodeLocMsg = barcodeLoc = ''; W.soliVerified = true; ScanNo = 1;  return null; } 
                } 
            } else if(ScanNo == 0) { barcodeLocMsg = 'Invalid stock address.'; return null; }
            
             // If product or line item is found                   
            if(soliListcheck.size() > 0 && ScanNo == 1) {
                for(Wrappers W : soliWrapperList) {
                    if(W.soliVerified && (barcode.trim() == W.soli.Barcode__c || barcode.trim() == W.soli.Product__r.Barcode__c)) { barcodeLoc = barcodeLocMsg = ''; W.soliSelected = true;  ScanNo = 0; return null; } 
                } 
            } else if(ScanNo == 1) { barcodeLocMsg = 'Invalid product.'; return null; }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
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
            
            if(SOList.size() > 0) {
                if(initialScan != true) { initialScan = true; soWrapperList = new List<Wrappers>(); }
                for(Sales_Order__c sos : SOList) { boolean exist = false;
                    for(Wrappers w : soWrapperList) { if(sos.Id == w.SO.Id) exist = true; }
                    if(!exist) { Wrappers wrap = new Wrappers(); wrap.soSelected = true; wrap.SO = sos; soWrapperList.add(wrap);
                    }
                }
            }    
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for redirecting for next tab.  
    */
    public PageReference redirect2NextTab() {
        return null;
    }
    
    public PageReference redirect2NextTabCustom() {
       return null;
    }
        
    /* 
      method for fetching available inventory stocks upon selected address
    */
    public PageReference fetchBinStocks() {
        try {
            List<Wrappers> soliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(rowCounter != null) soliWrap = new List<Wrappers>(); soliWrap.add(soliWrapperList.get(rowCounter));
            if(soliWrap != null) {
                if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
                else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                    
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
                else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
                else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                          
                if(binList.size() > 0) { if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); } Decimal myStock = 0; /*solis.MRP.MRP_Product__r.Item_Description__c != null && solis.MRP.Id != null*/ if(soliWrap.size() > 0) { Wrappers swrap = soliWrap[0]; List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC]; for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  /*&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)*/ } Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>(); Set<SelectOption> myBatches = new Set<SelectOption>(); if((!swrap.Product.ERP7__Lot_Tracked__c == true )) myBatches.add(new SelectOption('','--None--')); for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){ if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); } } if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock); else { swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.SOLI.Quantity__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c); } swrap.inventoryStock = myStock; swrap.binName = swrap.addressName; swrap.locationName = binList[0].Location__c; swrap.warehouseName = binList[0].Site__c; swrap.WN = binList[0].Site__r.Name;  swrap.LN = binList[0].Location__r.Name; swrap.BatchLotCodes = new List<SelectOption>(); swrap.BatchLotCodes.addAll(myBatches); if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue()); } else swrap.BatchLotCode = ''; } } 
                else if(SSLList.size() > 0) { if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); } Decimal myStock = 0; if(soliWrap.size() > 0) { Wrappers swrap = soliWrap[0]; List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC]; for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; /*&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)*/ } Set<SelectOption> myBatches = new Set<SelectOption>(); Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>(); if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--')); for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){ if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); } } if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock); else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.SOLI.Quantity__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c); swrap.inventoryStock = myStock; swrap.binName = null; swrap.locationName = SSLList[0].Id; swrap.warehouseName = SSLList[0].Site__c; swrap.WN = SSLList[0].Site__r.Name; swrap.LN = SSLList[0].Name; swrap.BatchLotCodes = new List<SelectOption>(); swrap.BatchLotCodes.addAll(myBatches); if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue()); } else swrap.BatchLotCode = ''; } } 
                else if(siteList.size() > 0) {
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }

                    Decimal myStock = 0;        
                    if(soliWrap.size() > 0) {
                        Wrappers swrap = soliWrap[0];
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c
                                                                                    From ERP7__Stock_Inward_Line_Item__c
                                                                                    Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                    ERP7__Product__c = :swrap.Product.Id And
                                                                                    Active__c = True
                                                                                    Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) {  if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){ if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); } }   
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock); else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.SOLI.Quantity__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = myStock+swrap.SOLI.Quantity__c-swrap.raisedQty; 
                            else if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                            else swrap.inventoryStock = myStock;
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
            }                  
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    public PageReference fetchBatchStocks() {
        try {
            List<Wrappers> soliWrap;
            WIISList = new List<Inventory_Stock__c>();
            List<Site__c> siteList = new List<Site__c>();                        
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            
            if(rowCounter != null) soliWrap = new List<Wrappers>(); soliWrap.add(soliWrapperList.get(rowCounter));
            
            if(soliWrap != null) {
                if(!Schema.sObjectType.Site__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Site__c.Label));
                else { siteList = Database.query('select ' + String.escapeSingleQuotes(siteFields) + ' from Site__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                    
                if(!Schema.sObjectType.Location__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Location__c.Label));
                else { SSLList = Database.query('select ' + String.escapeSingleQuotes(locationsFields) + ' ,Site__r.Name from Location__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                
                if(!Schema.sObjectType.StorageContainer__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.StorageContainer__c.Label));
                else { binList = Database.query('select ' + String.escapeSingleQuotes(binFields) + ' ,Site__r.Name, Location__r.Name from StorageContainer__c where (Id =\'' + String.escapeSingleQuotes(soliWrap[0].addressName) + '\' And Active__c = true)'); }
                          
                if(binList.size() > 0) { if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (StorageContainer__c =\'' + String.escapeSingleQuotes(binList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); } Decimal myStock = 0; if(soliWrap.size() > 0) { Wrappers swrap = soliWrap[0]; List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC]; for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c;  /*&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)*/ } Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>(); Set<SelectOption> myBatches = new Set<SelectOption>(); if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--')); for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){ if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); } } if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); } else swrap.inventoryStock = myStock; if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock); else swrap.requiredQty = Integer.valueof(swrap.remainingQty); } } 
                else if(SSLList.size() > 0) { if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label)); else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Location__c =\'' + String.escapeSingleQuotes(SSLList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); } for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); } Decimal myStock = 0; if(soliWrap.size() > 0) { Wrappers swrap = soliWrap[0]; List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And ERP7__Product__c = :swrap.Product.Id And Active__c = True Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC]; for(Inventory_Stock__c WIIS : WIISList) { if(swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; /*&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)*/ } Set<SelectOption> myBatches = new Set<SelectOption>(); Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>(); if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--')); for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){ if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); } } if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) {  swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); } else swrap.inventoryStock = myStock; if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);  else swrap.requiredQty = Integer.valueof(swrap.remainingQty); } } 
                else if(siteList.size() > 0) {
                    if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
                    else { WIISList = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ' from Inventory_Stock__c where (Warehouse__c =\'' + String.escapeSingleQuotes(siteList[0].Id) + '\' And Active__c = true And Number_of_Item_In_Stock__c > 0) Order By ERP7__Expiry_Date__c ASC'); }
                           for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible()) stockMap.put(WIIS.Product__c, WIIS.Id); }

                    Decimal myStock = 0;        
                    if(soliWrap.size() > 0) {
                        Wrappers swrap = soliWrap[0];
                       
                            List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
                                                                                            ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c
                                                                                            From ERP7__Stock_Inward_Line_Item__c
                                                                                            Where ERP7__Site_ProductService_InventoryStock__c In: WIISList And
                                                                                            ERP7__Product__c = :swrap.Product.Id And
                                                                                            Active__c = True
                                                                                            Order By ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c ASC];
                            for(Inventory_Stock__c WIIS : WIISList) { if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){ if(InwardLine.ERP7__Material_Batch_Lot__c != Null){ myBatches.add(new SelectOption(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.Name)); batchAvailStocks.put(InwardLine.ERP7__Material_Batch_Lot__c,InwardLine.ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c); } }   
                            
                            
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.SOLI.Quantity__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode); } else swrap.inventoryStock = myStock;
                            
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock); else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                            
                            if(swrap.soli.Order_Line_Status__c == 'Reserved' && swrap.inventoryStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = swrap.inventoryStock+swrap.SOLI.Quantity__c-swrap.raisedQty; 
                            else if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                    }
                } 
            }                  
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating product purchase line item for selected SOLIs
    */
    public PageReference saveSOLIs() {
        try {
            Boolean error = false;
            soliIds = new List<Id>();
            List<Id> assetIds = new List<Id>();
            soliSelectedWrapperList = new List<Wrappers>();
            PPLIList = new List<Stock_Outward_Line_Item__c>(); 
            
            if(soliWrapperList.size() > 0) {          
                for(Wrappers wrap : soliWrapperList) { if(wrap.soliSelected == true) { if(wrap.SOLI.Asset__c != Null){ assetIds.add(wrap.SOLI.Asset__c); } soliIds.add(wrap.soli.Id); soliSelectedWrapperList.add(wrap); } }
                if(soliSelectedWrapperList.size() > 0) { 
                    errorMsg = '';
                    for(Wrappers wrap : soliSelectedWrapperList) {
                        if(wrap.inventoryStock == 0) { errorMsg = 'Sorry, no available inventory for the selected item to proceed.'; error = true; break; }      
                        else if(wrap.requiredQty > wrap.inventoryStock) { errorMsg = 'Quantity cannot be greater than available stock.'; error = true; break; }
                        else if(wrap.requiredQty > wrap.remainingQty) { errorMsg = 'Quantity cannot be greater than remaining Quantity.'; error = true; break; }
                        else if(wrap.serialized && (wrap.SerialNumbers.Serial__c == Null)) { errorMsg = 'Required field missing - Serial Number'; error = true; break; }
                    }                
                    if(!error) {
                        if(soliIds.size() > 0) {
                            if(!Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Stock_Outward_Line_Item__c.Label));
                            else { ppliItemList = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ' from Stock_Outward_Line_Item__c where Sales_Order_Line_Item__c In : soliIds and Picked_Date__c = null'); }
                        } 
                        MAP<Id, Sales_Order_Line_Item__c> soliMap = new MAP<Id, Sales_Order_Line_Item__c>();
                        MAP<Id, MRP__c> mrpMap = new MAP<Id, MRP__c>();
                        MAP<Id, Asset__c> assetMap = new MAP<Id, Asset__c>([Select Id, Name, Active__c, Barcode__c, Status__c From Asset__c Where Id In :assetIds]);
                        
                        for(Wrappers wrap : soliSelectedWrapperList) {
                            
                            
                            for(Stock_Outward_Line_Item__c ppli: ppliItemList) { 
                                if(wrap.SOLI.Product__c != Null){ 
                                    if(!(wrap.SOLI.Product__r.ERP7__Is_Kit__c && wrap.SOLI.Explode__c) && wrap.SOLI.Product__c == ppli.Product__c && wrap.SOLI.Id == ppli.Sales_Order_Line_Item__c && ppli.Picked_Quantity__c == null) { 
                                        ppli.Quantity__c = ppli.Quantity__c - wrap.requiredQty;                                                                                                                               
                                        PPLIList.add(ppli);
                                        
                                        Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();  
                                            pplis.Name = 'STOLI-' + wrap.SOLI.Name;
                                            if(wrap.SOLI.Product__c != null) pplis.Product__c = ppli.Product__c;
                                            if(wrap.requiredQty != null) pplis.Quantity__c = wrap.requiredQty;
                                            if(wrap.requiredQty != null) pplis.Picked_Quantity__c = wrap.requiredQty;
                                            pplis.Picked_Date__c = System.Now();
                                            if(wrap.SOLI.Id != null) pplis.Sales_Order_Line_Item__c = wrap.SOLI.Id;
                                            if(wrap.SOLI.Sales_Order__c != null) pplis.Sales_Order__c = wrap.SOLI.Sales_Order__c;
                                            pplis.Status__c = 'Committed';
                                            pplis.Active__c = true; 
                                            if(wrap.SerialNumbers.Serial__c != null) pplis.Serial__c = wrap.SerialNumbers.Serial__c;
                                            if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;              
                                            orderNumber = wrap.SOLI.Sales_Order__r.Name;
                                            
                                            if(stockMap.get(wrap.SOLI.Product__c) != null) pplis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.SOLI.Product__c);
                                            if(wrap.SOLI.Picked_Quantity__c == null) wrap.SOLI.Picked_Quantity__c = wrap.requiredQty;
                                            else wrap.SOLI.Picked_Quantity__c += wrap.requiredQty;
                                            soliMap.put(wrap.SOLI.Id, wrap.SOLI);
                                        PPLIList.add(pplis);
                                    }
                                    else if((wrap.SOLI.Product__r.ERP7__Is_Kit__c && wrap.SOLI.Explode__c) && wrap.MRP.MRP_Product__c == ppli.Product__c && wrap.SOLI.Id == ppli.Sales_Order_Line_Item__c && ppli.Picked_Quantity__c == null) { ppli.Quantity__c = ppli.Quantity__c - wrap.requiredQty; PPLIList.add(ppli); Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c(); pplis.Name = 'STOLI-' + wrap.SOLI.Name; if(wrap.SOLI.Product__c != null) pplis.Product__c = ppli.Product__c; if(wrap.requiredQty != null) pplis.Quantity__c = wrap.requiredQty; if(wrap.requiredQty != null) pplis.Picked_Quantity__c = wrap.requiredQty; pplis.Picked_Date__c = System.Now(); if(wrap.SOLI.Id != null) pplis.Sales_Order_Line_Item__c = wrap.SOLI.Id; if(wrap.SOLI.Sales_Order__c != null) pplis.Sales_Order__c = wrap.SOLI.Sales_Order__c; pplis.Status__c = 'Committed'; pplis.Active__c = true; if(wrap.SerialNumbers.Serial__c != null) pplis.Serial__c = wrap.SerialNumbers.Serial__c; if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '') pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode; orderNumber = wrap.SOLI.Sales_Order__r.Name; if(stockMap.get(wrap.MRP.MRP_Product__c) != null) pplis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.MRP.MRP_Product__c); if(wrap.MRP.Picked_Quantity__c == null) wrap.MRP.Picked_Quantity__c = wrap.requiredQty; else wrap.MRP.Picked_Quantity__c += wrap.requiredQty; mrpMap.put(wrap.mrp.Id, wrap.mrp); pplis.MRP_Material_Requirements_Planning__c = wrap.MRP.Id; PPLIList.add(pplis); } } 
                                else if(wrap.SOLI.Asset__c != Null){ if(wrap.SOLI.Asset__c == ppli.Fixed_Asset__c && wrap.SOLI.Id == ppli.Sales_Order_Line_Item__c && ppli.Picked_Quantity__c == null) { ppli.Quantity__c = ppli.Quantity__c - wrap.requiredQty; PPLIList.add(ppli); Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c(); if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){  pplis.Name = 'STOLI-' + wrap.SOLI.Name; } else{ /* no access*/ } if(wrap.SOLI.Asset__c != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable()){ pplis.Fixed_Asset__c = wrap.SOLI.Asset__c; } else { /* no aceeess*/} if(wrap.requiredQty != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){ pplis.Quantity__c = wrap.requiredQty;} else { /* no aceeess*/} if(wrap.requiredQty != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Quantity__c.isUpdateable()){ pplis.Picked_Quantity__c = wrap.requiredQty;} else { /* no aceeess*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Picked_Date__c.isUpdateable()){ pplis.Picked_Date__c = System.Now();} else { /* no aceeess*/} if(wrap.SOLI.Id != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isUpdateable()){ pplis.Sales_Order_Line_Item__c = wrap.SOLI.Id;} else { /* no aceeess*/} if(wrap.SOLI.Sales_Order__c != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Sales_Order__c.isUpdateable()){ pplis.Sales_Order__c = wrap.SOLI.Sales_Order__c;} else { /* no aceeess*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){pplis.Status__c = 'Committed';} else { /* no aceeess*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()){pplis.Active__c = true; } else { /* no aceeess*/} if(wrap.SerialNumbers.Serial__c != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Serial__c.isUpdateable()){ pplis.Serial__c = wrap.SerialNumbers.Serial__c;} else { /* no aceeess*/} if(wrap.BatchLotCode != Null && wrap.BatchLotCode != '' && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){ pplis.ERP7__Material_Batch_Lot__c = wrap.BatchLotCode;  } else { /* no aceeess*/} orderNumber = wrap.SOLI.Sales_Order__r.Name; if(stockMap.get(wrap.SOLI.Asset__c) != null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() || Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){ pplis.Site_Product_Service_Inventory_Stock__c = stockMap.get(wrap.SOLI.Asset__c);} else { /* no aceeess*/} if(wrap.SOLI.Picked_Quantity__c == null && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){ wrap.SOLI.Picked_Quantity__c = wrap.requiredQty; } else {wrap.SOLI.Picked_Quantity__c += wrap.requiredQty;} soliMap.put(wrap.SOLI.Id, wrap.SOLI); PPLIList.add(pplis); } }
                            }
                        }            
                        if(PPLIList.size() > 0 || assetMap.Values().size() > 0) { 
                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()){ DMLManager.upsertAsUser(PPLIList); } else { /* no access*/ }
                        if(Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()){ DMLManager.upsertAsUser(soliMap.Values()); } else { /* no access*/ }
                            if(Schema.sObjectType.MRP__c.isCreateable() && Schema.sObjectType.MRP__c.isUpdateable()) { DMLManager.upsertAsUser(mrpMap.Values()); } else { /* no access*/ }
                            //if(Schema.sObjectType.Asset__c.isCreateable() && Schema.sObjectType.Asset__c.isUpdateable()) DMLManager.upsertAsUser(assetMap.Values());
                            return redirect2NextTab();
                        }
                    }
                } else errorMsg = 'Please select a line item to save.'; } else errorMsg = 'Items have been picked, please proceed to packing.';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));  }        
        return null;
    }
    
    /*
      method for creating barcodes for selected SOLIs
    */
    public PageReference createBarcode() {
        try {                        
            Boolean error = false; soliIds = new List<Id>(); PB = new PrintBarcodes(); Set<Id> pIds = new Set<Id>(); 
            soliSelectedWrapperList = new List<Wrappers>(); PB.BarcodeWrapperList = new List<PrintBarcodes.BarcodeWrapper>();           
            if(soliWrapperList.size() > 0) {
                for(Wrappers wrap : soliWrapperList) { if(wrap.soliSelected == true) { soliIds.add(wrap.soli.Id); pIds.add(wrap.soli.Product__c); soliSelectedWrapperList.add(wrap); } }
                if(soliSelectedWrapperList.size() > 0) { errorMsg = '';
                    List<Product2> prods = Database.query('select ' + String.escapeSingleQuotes(prodFields) +' from Product2 where Id In: pIds');    
                    Map<Id, Product2> pMap = new Map<Id, Product2>(); for(Product2 prod: prods) { pMap.put(prod.Id, prod); }

                    for(Wrappers wrap : soliSelectedWrapperList) { PrintBarcodes.BarcodeWrapper BW;
                        if(PB.LabelField != Null && PB.LabelField != '') BW = new PrintBarcodes.BarcodeWrapper(wrap.SOLI.Product__r.Barcode__c, wrap.SOLI.Product__r.Name, wrap.SOLI.Product__r.Name); else  BW = new PrintBarcodes.BarcodeWrapper(wrap.SOLI.Product__r.Barcode__c, '' , wrap.SOLI.Product__r.Name);
                        BW.products = pMap.get(wrap.SOLI.Product__c); PB.BarcodeWrapperList.add(BW);
                    } 
                } else { errorMsg = 'Please select a line item to print barcode.'; }                  
            } else { errorMsg = 'Items have been picked, please proceed to packing.'; }  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return Page.PrintPickProductsPDF;
    }
    
    /*
      method for creating a new package
    */
    public PageReference createPackage() {
        try {
            CreatePack = false;
            isAwaiting = true;
            Package2Create = new Package__c();
            Package2Create.Active__c = true;
            Set<Id> soIds = new Set<Id>();
            // SOLI to create package
            for(Wrappers wrap : soliWrapperList) { if(wrap.soliSelected == true) soIds.add(wrap.SOLI.Sales_Order__c); }
            // multiple SO to create package
            if(soWrapperList.size() > 0){ for(Wrappers sow : soWrapperList) { if(sow.soSelected == true) soIds.add(sow.SO.Id); } } else for(Wrappers sow : soSelectedWrapperList) soIds.add(sow.SO.Id);
            // Single SO to create package 
            if(salesorderId != null && salesorderId != '') soIds.add(salesorderId);
            if(soIds.size() > 0) Package2Create.Sales_Order__c = (new list<Id>(soIds))[0];
            createPacks(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for creating a new package / displaying the existing created packages
    */
    public PageReference createPacks() {
        try {
            Set<Id> soIds = new Set<Id>();
            // multiple SO to create package
           
            
            if(soWrapperList.size() > 0){ 
                soSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : soWrapperList) { 
                    if(sow.soSelected == true) { 
                        soIds.add(sow.SO.Id); 
                        soSelectedWrapperList.add(sow); 
                        if(salesorderId == sow.SO.Id) salesorderId = Null;
                    }
                    
                    if(salesorderId == sow.SO.Id){ soSelectedWrapperList.add(sow); soIds.add(sow.SO.Id); }
                } 
                
            }
            else { for(Wrappers sow : soSelectedWrapperList) { soIds.add(sow.SO.Id);  } }
            
            if(soIds.size() > 0) {
                soliWrapperList = new List<Wrappers>();
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
                else { 
                       List<Id> soliIds = new List<Id>();
                       Map<Id,ERP7__Sales_Order_Line_Item__c> soliMap = new Map<Id,ERP7__Sales_Order_Line_Item__c>();
                       List<Id> proIds = new List<Id>();
                       for(ERP7__Sales_Order_Line_Item__c solis: Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Order_Date__c, Sales_Order__r.Account__r.Name, Sales_Order__r.Channel__c, Product__r.Weight__c, Product__r.Preview_Image__c, Product__r.ERP7__Is_Kit__c, '+
                                                                 +' Product__r.Name, Asset__r.Name, ERP7__Product__r.Item_Type__c, ERP7__Product__r.SKU__c, Product__r.Picture__c, Sales_Order__r.Authorised__c, Product__r.Barcode__c from Sales_Order_Line_Item__c where (Sales_Order__c In: soIds) order by Sales_Order__c ASC')) {
                           if(!(solis.Product__r.ERP7__Is_Kit__c && solis.Explode__c) && solis.Packed_Quantity__c != solis.Picked_Quantity__c && solis.Picked_Quantity__c <= solis.Quantity__c) {
                               Wrappers swrap = new Wrappers(); 
                               swrap.SOLI = solis;
                               swrap.isSOLIawaiting = true;
                               orderNumber = solis.Sales_Order__r.Name;
                               proIds.add(solis.Product__c);
                               soliWrapperList.add(swrap);
                           } else{
                               soliMap.put(solis.Id,solis);
                               soliIds.add(solis.Id);
                           }
                       }
                       String mrpKit = 'MRP Kit';
                       for(MRP__C MRP : Database.query('select ' + String.escapeSingleQuotes(MRPFields) + ' ,ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Item_Description__c, MRP_Product__r.ERP7__Lot_Tracked__c, MRP_Product__r.Weight__c from MRP__c where (Sales_Order_Line_Item__c In :soliIds And RecordType.Name = :mrpKit)')) { if(MRP.Packed_Quantity__c != MRP.Picked_Quantity__c && MRP.Picked_Quantity__c <= MRP.Total_Amount_Required__c) { Wrappers swrap = new Wrappers(); swrap.SOLI = soliMap.get(MRP.Sales_Order_Line_Item__c); swrap.MRP = MRP; proIds.add(MRP.ERP7__MRP_Product__c); swrap.isSOLIawaiting = true; orderNumber = swrap.SOLI.Sales_Order__r.Name; soliWrapperList.add(swrap); } }
                       
                       Map<Id, Product2> productMap = new Map<Id, Product2>([Select Id, Name, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]);
                }
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else { 
                       Packages = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Account__r.Name, Shipment__r.Name, Shipment__r.Shipment_Date__c, '+
                                  +' Shipment__r.Status__c from Package__c where (Active__c = true And Sales_Order__c In: soIds) Order by Shipment__r.Name, CreatedDate Asc');                       
                       packMap = new Map <Id, Package__c>(Packages); 
                }                                 
                if(Packages.size() > 0 && soliWrapperList.size() > 0) { createPack = true; isAwaiting = true; }
                else if(Packages.size() > 0) { createPack = false; isAwaiting = true; } else if(soliWrapperList.size() > 0) { createPack = true; isAwaiting = false; }
                
                Set<Id> pkgIds = new Set<Id>();
                if(Packages.size() > 0) { for(Package__c pack: Packages) { pkgIds.add(pack.Id); } }       
                ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where (Package__c In: pkgIds And Status__c = \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc'); }    
                if(!Schema.sObjectType.Package_List__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package_List__c.Label));
                else { packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c In: pkgIds And Active__c = true) Order by CreatedDate Asc'); }
                
                //*****************************************************************            
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { lineItemWrapper LW = new lineItemWrapper();
                        LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm'; else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }
                    
                // **************************************************************** 
                    Package2Create = new Package__c();           
                    if(soIds.size() > 0) Package2Create.Sales_Order__c = (new list<Id>(soIds))[0];                                
                    Package2Create.Weight__c = 0;
                    Package2Create.Declared_Value__c = 0;                            
                    packageWrapperList = new List<packageWrapper>();
                    Package2Create.Status__c = 'Deposited To Front Desk';
                    if(Packages != null) Package2Create.Name = Package2Create.Barcode__c = Package2Create.Description__c = Package2Create.Name__c = 'Pkg-'+ orderNumber  +'-'+ Integer.valueof(Packages.size()+1);
                    for(Wrappers wrap : soliWrapperList) { 
                        if(wrap.isSOLIawaiting == true) { 
                            if(!(wrap.Soli.Product__r.ERP7__Is_Kit__c && wrap.Soli.Explode__c)){
                                packageWrapper PW = new packageWrapper();                            
                                PW.pkgSelected = true;
                                PW.Soli = wrap.soli;
                                PW.qtyToPick = wrap.Soli.Picked_Quantity__c;
                                if(wrap.Soli.Picked_Quantity__c != null && wrap.Soli.Packed_Quantity__c != null){ PW.qtyToPack = wrap.Soli.Picked_Quantity__c - wrap.Soli.Packed_Quantity__c; } else PW.qtyToPack = wrap.Soli.Picked_Quantity__c;
                               
                                if(PW.soli.Product__r.Weight__c != null) Package2Create.Weight__c += (PW.soli.Product__r.Weight__c * PW.qtyToPack);                                                                
                                                           
                                if(PW.soli.Price_Product__c != null) Package2Create.Declared_Value__c += (PW.soli.Price_Product__c * PW.qtyToPack);
                                                   
                                if(PW.qtyToPack != 0) packageWrapperList.add(PW);
                            }
                            else{ packageWrapper PW = new packageWrapper(); PW.pkgSelected = true; PW.Soli = wrap.soli; PW.mrp = wrap.mrp; PW.qtyToPick = wrap.MRP.Picked_Quantity__c; if(wrap.MRP.Picked_Quantity__c != null && wrap.MRP.Packed_Quantity__c != null) { PW.qtyToPack = wrap.MRP.Picked_Quantity__c - wrap.MRP.Packed_Quantity__c; }else PW.qtyToPack = wrap.MRP.Picked_Quantity__c; if(PW.MRP.MRP_Product__r.Weight__c != null) Package2Create.Weight__c += (PW.MRP.MRP_Product__r.Weight__c * PW.qtyToPack); /*if(PW.soli.Price_Product__c != null) Package2Create.Declared_Value__c += (PW.soli.Price_Product__c * PW.qtyToPack); */ if(PW.qtyToPack != 0) packageWrapperList.add(PW); }
                        }
                    } 
                    soliWrapperList = new List<Wrappers>();
                    return Page.PickPackShip_CreatePackage; } else errorMsg = 'Please select an Order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for re-evaluating the package weight and declared value.
    */
    public PageReference evaluatePackDetails() {
        try {
            errorMsg2 = '';
            Package2Create.Weight__c = Package2Create.Declared_Value__c = 0;
            for(packageWrapper PW : packageWrapperList) { if(PW.soli.Product__r.Weight__c != null) Package2Create.Weight__c += (PW.soli.Product__r.Weight__c * PW.qtyToPack); if(PW.soli.Price_Product__c != null) Package2Create.Declared_Value__c += (PW.soli.Price_Product__c * PW.qtyToPack); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for pre-populating package details from custom settings
    */
    public PageReference populatePackDetails() {
        try { 
            List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
            if(pkgTypeValue != null && pkgTypeValue != '--None--') {
                pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from ERP7__Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\') Limit 1');                             
                if(pkgDetailList.size() > 0) { Package2Create.Length__c = pkgDetailList[pkgDetailList.size() - 1].Length__c;
                                               Package2Create.Width__c = pkgDetailList[pkgDetailList.size() - 1].Width__c;            
                                               Package2Create.Height__c = pkgDetailList[pkgDetailList.size() - 1].Height__c;
                                               Package2Create.Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].Weight_Unit__c;
                                               //Package2Create.Shipment_Type__c = 'UPS';            
                }
            } else errorMsg2 = 'Sorry, selected package type not available.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for updating package details
    */
    public PageReference updatePacks() {
        try {
            Boolean error = false;            
            if(packageWrapperList != null) {
                List<Package_List__c> PLS = new List<Package_List__c>();
                MAP<Id, Sales_Order_Line_Item__c> soliMap = new MAP<Id, Sales_Order_Line_Item__c>();
                MAP<Id, MRP__c> mrpMap = new MAP<Id, MRP__c>();
                for(packageWrapper pw: packageWrapperList) {
                    if(pw.qtyToPack > pw.qtyToPick && pw.pkgSelected == true) { errorMsg2 = 'Packed quantity cannot be greater than picked Quantity.'; error = true; break; }
                }
                if(!error) { Package2Create.Active__c = true;
                            if(Package2Create != null) if(Schema.sObjectType.Package__c.isCreateable()&& Schema.sObjectType.Package__c.isUpdateable()) { DMLManager.upsertAsUser(Package2Create);} else { /* no aceeess*/}
                    for(Integer i=1; i<=packageWrapperList.size(); i++) {
                        if(packageWrapperList[i-1].pkgSelected == true) { 
                            Package_List__c packageList = new Package_List__c();                            
                            packageList.Name = 'Package List - '+i;
                            packageList.Active__c = true;
                            packageList.Package__c = Package2Create.Id;
                            packageList.Quantity__c = packageWrapperList[i-1].qtyToPack;
                            packageList.Sales_Order_Line_Item__c = packageWrapperList[i-1].soli.Id;
                            packageList.Sales_Order__c = packageWrapperList[i-1].soli.Sales_Order__c;
                            if(!(packageWrapperList[i-1].soli.Product__r.ERP7__Is_Kit__c && packageWrapperList[i-1].soli.Explode__c)){
                                if(packageWrapperList[i-1].soli.Packed_Quantity__c == null) packageWrapperList[i-1].soli.Packed_Quantity__c = packageWrapperList[i-1].qtyToPack;
                                else packageWrapperList[i-1].soli.Packed_Quantity__c += packageWrapperList[i-1].qtyToPack;
                                soliMap.put(packageWrapperList[i-1].soli.Id, packageWrapperList[i-1].soli);
                            } else{
                                if(packageWrapperList[i-1].mrp.Packed_Quantity__c == null){ packageWrapperList[i-1].mrp.Packed_Quantity__c = packageWrapperList[i-1].qtyToPack; }else packageWrapperList[i-1].mrp.Packed_Quantity__c += packageWrapperList[i-1].qtyToPack;
                                mrpMap.put(packageWrapperList[i-1].mrp.Id, packageWrapperList[i-1].mrp); packageList.MRP_Material_Requirement_Planning__c = packageWrapperList[i-1].mrp.Id;
                            }
                            
                            PLS.add(packageList);
                        }                        
                    } 
                    if(PLS.size() > 0) { 
                        if(Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()) {DMLManager.upsertAsUser(PLS);} else { /* no aceeess*/}
                        if(Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()) {DMLManager.upsertAsUser(soliMap.Values());} else { /* no aceeess*/}
                        if(Schema.sObjectType.MRP__c.isCreateable() && Schema.sObjectType.MRP__c.isUpdateable()) {DMLManager.upsertAsUser(mrpMap.Values());} else { /* no aceeess*/}
                    } createPacks();
                }            
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for updating package details and creating a new package
    */
    public PageReference updatePacksAndNewPack() {
        try {
            soliIds = new List<Id>();
            Boolean error = false;
            packageLists = new List<Package_List__c>();        
            selectedPackageWrapperList = new List<packageWrapper>();
            List<Package_List__c> PLS = new List<Package_List__c>();
            MAP<Id, Sales_Order_Line_Item__c> soliMap = new MAP<Id, Sales_Order_Line_Item__c>();
            if(packageWrapperList != null) { for(packageWrapper PW : packageWrapperList) { if(PW.pkgSelected == true) selectedPackageWrapperList.add(PW); } }
            if(selectedPackageWrapperList.size() > 0) { errorMsg2 = ''; Package2Create.Active__c = true;
                                                       if(Package2Create != null) if(Schema.sObjectType.Package__c.isCreateable()&& Schema.sObjectType.Package__c.isUpdateable()) {DMLManager.upsertAsUser(Package2Create);} else { /* no aceeess*/}
                for(packageWrapper PW : selectedPackageWrapperList) { Package_List__c packageList = new Package_List__c();                        
                                                                      packageList.Name = 'Package List - '+PW.soli.Product__r.Name;
                                                                      packageList.Active__c = true;
                                                                      packageList.Package__c = Package2Create.Id;
                                                                      packageList.Quantity__c = PW.qtyToPack;
                                                                      packageList.Sales_Order_Line_Item__c = PW.soli.Id;
                                                                      packageList.Sales_Order__c = PW.soli.Sales_Order__c;
                                                                      if(PW.soli.Packed_Quantity__c == null) PW.soli.Packed_Quantity__c = PW.qtyToPack;
                                                                      else PW.soli.Packed_Quantity__c += PW.qtyToPack;
                                                                        
                                                                      soliMap.put(PW.soli.Id, PW.soli);
                                                                      PLS.add(packageList);
                                                                      soliIds.add(PW.soli.Id);
                }
                if(PLS.size() > 0) { 
                    if(Schema.sObjectType.Package_List__c.isCreateable()&& Schema.sObjectType.Package_List__c.isUpdateable()) {DMLManager.upsertAsUser(PLS);} else { /* no aceeess*/}
                    if(Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable()&& Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()) {DMlManager.upsertAsUser(soliMap.Values()); } else { /* no aceeess*/}
                }
                if(soliIds.size() > 0) {
                    if(!Schema.sObjectType.Package_List__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package_List__c.Label));
                    else { packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Sales_Order_Line_Item__c In: soliIds And Active__c = true)'); }
                    List<Id> packListIds = new List<Id>();       
                    for(Package_List__c w : packageLists) { packListIds.add(w.Sales_Order_Line_Item__c); }
                    for(Id plId : packListIds) {
                        List<Package_List__c> mypliList = new List<Package_List__c>();
                        Boolean adding = false;
                        for(Package_List__c pli: packageLists) { if(plId == pli.Sales_Order_Line_Item__c) { mypliList.add(pli); adding = true; } }
                        if(adding) packageListMap.put(plId, mypliList);    
                    }
                    for(packageWrapper PW : selectedPackageWrapperList) {
                        if(packageListMap.KeySet().Contains(PW.soli.Id)) {           
                            for(Package_List__c pp : packageListMap.get(PW.soli.Id)) {
                                if(pp.Quantity__c == PW.qtyToPick) { PW.qtyToPick += pp.Quantity__c; } 
                                else if(pp.Quantity__c < PW.qtyToPick) { PW.qtyToPack += PW.qtyToPick - pp.Quantity__c; PW.qtyToPick += pp.Quantity__c;
                                } 
                            } if(PW.qtyToPick == PW.qtyToPack) error = false; else error = true;                        
                        }                    
                    }
                }
                if(error) { Package2Create = new Package__c(); Package2Create.Active__c = true; createPacks(); } 
                else if(!error) { createPacks(); } } else errorMsg2 = 'Please select a line item to pack.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    
    /*
      method for updating the details of created packages and package list
    */
    public PageReference editPackage() {
        try {
            Set<Id> soIds = new Set<Id>();
            Packages = new List<Package__c>();
            currentItems = new List<Sales_Order_Line_Item__c>();        
            if(pack2updateId != null) {
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else { Package2Create = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Sales_Order__r.Account__c, Shipment__r.Name from Package__c where (Id =\'' + String.escapeSingleQuotes(pack2updateId) + '\')');  
                       packMap = new Map <Id, Package__c>(Packages);
                }
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
                else { currentItems = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Order_Date__c, Sales_Order__r.Account__r.Name, Sales_Order__r.Channel__c, Product__r.Name, Asset__r.Name, Product__r.Preview_Image__c, Product__r.Weight__c, Product__r.ERP7__Is_Kit__c, '+
                                      +' Product__r.Picture__c, ERP7__Product__r.Item_Type__c, ERP7__Product__r.SKU__c, Sales_Order__r.Authorised__c from Sales_Order_Line_Item__c where (Sales_Order__c =\'' + String.escapeSingleQuotes(Package2Create.Sales_Order__c) + '\') order by Sales_Order__c ASC');                       
                }    
                String status = 'Cancelled';        
                ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where'+
                                   '(Package__c =\'' + String.escapeSingleQuotes(Package2Create.Sales_Order__c) + '\' And Status__c !=\'' + String.escapeSingleQuotes(status) + '\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');
                }
                if(!Schema.sObjectType.Package_List__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package_List__c.Label));
                else { packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(Package2Create.Id) + '\' And Active__c = true) Order by CreatedDate Asc'); }                        
                
                //*****************************************************************            
                    if(Package2Create != null) Packages.add(Package2Create);
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { lineItemWrapper LW = new lineItemWrapper(); LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm'; else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }        
                    
                // ****************************************************************            
                    packageWrapperList = new List<packageWrapper>();                                
                    for(Sales_Order_Line_Item__c soli : currentItems){
                        packageWrapper PW = new packageWrapper();
                        List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                        for(Package_List__c pl : packageLists){
                           if(pl.Sales_Order_Line_Item__c == soli.Id) { PW.Soli = soli;
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
                        } 
                        if(ipwList.size() > 0) { PW.innerPackList = ipwList; packageWrapperList.add(PW); }
                    } CreatePack = true; isAwaiting = false;     } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for deleting created packages
    */
    public PageReference deletePackage() {
        try {
            Set<Id> soliIds = new Set<Id>();
            MAP<Id, Sales_Order_Line_Item__c> soliMap = new MAP<Id, Sales_Order_Line_Item__c>();
            if(pack2updateId != null) {
                List<Package_List__c> packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Sales_Order_Line_Item__r.Packed_Quantity__c from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack2updateId) + '\' And Active__c = true) Order by CreatedDate Asc');
                for(Package_List__c pls: packList) { soliIds.add(pls.Sales_Order_Line_Item__c); }
                List<Sales_Order_Line_Item__c> soliList = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' from Sales_Order_Line_Item__c where Id In: soliIds'); 
                for(Package_List__c pl: packList) {
                    for(Sales_Order_Line_Item__c solis: soliList) {
                        if(pl.Sales_Order_Line_Item__c == solis.Id) {
                            if(solis.Packed_Quantity__c != null) {
                                solis.Packed_Quantity__c = solis.Packed_Quantity__c - pl.Quantity__c;
                                soliMap.put(solis.Id, solis);
                            } break;
                        }
                    }
                }
            }
            if(soliMap.size() > 0) if(Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable())upsert soliMap.values();
            if(pack2updateId != null) if(Package__c.sObjectType.getDescribe().isDeletable()) {delete new Package__c(Id = pack2updateId);} else { /* no aceeess*/}            
            createPacks(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
   
    /*
      method for redirecting back to ship / pack tab
    */
    public PageReference back2ShipmentPage() {
        if(ApexPages.currentPage().getParameters().get('shipmentId') != null) return page.PickPackShip_CreateShipment; else if(ApexPages.currentPage().getParameters().get('pack') != null) return page.pickpackship_CreatePackage;
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
                List<Package_List__c> packageItemList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Name, Sales_Order_Line_Item__r.Quantity__c, '+
                                                        +' Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.Description__c, Sales_Order_Line_Item__r.Shipping_Amount_Quantity__c, Sales_Order_Line_Item__r.Admin_Shipping_Amount__c, Package__r.Shipment__c, Package__r.Name from Package_List__c where Package__c In: pkgIds'); 
                for(Shipment__c sh: shipList) {   
                    List<Package_List__c> pkgItemList = new List<Package_List__c>();
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
                Database.rollback(sp);
                
                return page.PickPackShip_CreateShippingSlips;     } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for displaying available shipment list from the system.
    */
    public PageReference createShipments() {
        try {
            Set<Id> soIds = new Set<Id>();
            shipmentList = new List<Shipment__c>();
            shipmentWrapperList = new List<Wrappers>();
            // multiple SO to create package
            
            
            if(soWrapperList.size() > 0){ 
                soSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : soWrapperList) { 
                    if(sow.soSelected == true) { 
                        soIds.add(sow.SO.Id); 
                        soSelectedWrapperList.add(sow); 
                        if(salesorderId == sow.SO.Id) salesorderId = Null;
                    }
                    if(salesorderId == sow.SO.Id){ soSelectedWrapperList.add(sow); soIds.add(sow.SO.Id); }
                } 
            }
            else {
                for(Wrappers sow : soSelectedWrapperList) { soIds.add(sow.SO.Id); }
            }                      
            
            if(soIds.size() > 0) {
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { shipmentList = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' ,RecordType.Name, Sales_Order__r.Name, Customer__r.Name, Shipping_Address__r.Customer__r.Name, Shipping_Address__r.Address_Line1__c, Shipping_Address__r.Address_Line2__c, Shipping_Address__r.Address_Line3__c, '+
                                      +' Shipping_Address__r.City__c, Shipping_Address__r.County__c, Shipping_Address__r.Country__c, Shipping_Address__r.Contact__r.Phone, Shipping_Address__r.Contact__r.Fax, Shipping_Address__r.Contact__r.Name, Shipping_Address__r.Contact__r.Email, '+
                                      +' Shipping_Address__r.State__c, Shipping_Address__r.Postal_Code__c from Shipment__c where (Sales_Order__c In: soIds And Active__c = true) Order by CreatedDate Asc');
                }
                for(Shipment__c shp: shipmentList) { Wrappers wrap = new Wrappers(); wrap.shipM = shp;
                    if(wrap.shipM.RecordType.Name == 'UPS Shipping') wrap.shipmentType = 'UPS'; else if(wrap.shipM.RecordType.Name == 'Internal Shipping') wrap.shipmentType = 'Shipment'; else if(wrap.shipM.RecordType.Name == 'Fedex Shipping') wrap.shipmentType = 'FedEx';
                    if(shp.ERP7__TrackingNumber__c != null) wrap.trackingNo += shp.ERP7__TrackingNumber__c.replace(',','<br/>');
                    shipmentWrapperList.add(wrap);
                } return page.PickPackShip_CreateShipment; } else errorMsg = 'Please select an order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for deleting shipment
    */
    public PageReference deleteShipment() {
        try {
            if(packageId != null) shipmentWrapperList.remove(Integer.valueof(packageId));
            if(shipmentId != null) if(Shipment__c.sObjectType.getDescribe().isDeletable()) {delete new Shipment__c(Id = shipmentId);} else { /* no aceeess*/} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for fetching SOLI's list upon selected sales order for creating new package
    */
    public PageReference fetchSOLIIItems() {
        try {
            Set<Id> soIds = new Set<Id>();        
            Packages = new List<Package__c>();
            currentItems = new List<Sales_Order_Line_Item__c>();            
            if(Package2Create.Sales_Order__c != null) {           
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
                else { currentItems = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Order_Date__c, Sales_Order__r.Account__r.Name, Sales_Order__r.Channel__c, Product__r.Name, ERP7__Product__r.SKU__c, ERP7__Product__r.ERP7__Item_Type__c, ERP7__Product__r.ERP7__Preview_Image__c, '+
                                      +' Asset__r.Name, Product__r.Weight__c, Product__r.Picture__c, ERP7__Product__r.ERP7__Colour__c, ERP7__Quantity__c, ERP7__Picked_Quantity__c, Sales_Order__r.Authorised__c from Sales_Order_Line_Item__c where (Sales_Order__c =\'' + String.escapeSingleQuotes(Package2Create.Sales_Order__c) + '\') order by Sales_Order__c ASC');
                }                
            // ****************************************************************            
                packageWrapperList = new List<packageWrapper>(); for(Sales_Order_Line_Item__c soli : currentItems) { packageWrapper PW = new packageWrapper(); PW.Soli = soli; List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>(); for(Package_List__c pl : packageLists){ if(pl.Sales_Order_Line_Item__c == soli.Id){ innerPackageWrapper ipw = new innerPackageWrapper(); ipw.pack = String.valueof(pl.Package__c); ipw.packege = packMap.get(pl.Package__c); ipw.packageList = pl; ipw.packList.add(new SelectOption('','--None--')); if(ipw.packege.Status__c == 'Shipped' || ipw.packege.Status__c == 'Picked Up' || ipw.packege.Status__c == 'Delivered') ipw.packList.add(new SelectOption(String.valueof(ipw.packege.Id),ipw.packege.Name__c)); for(Package__c P : Packages){ if((P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') && (ipw.packege.Status__c != 'Shipped' && ipw.packege.Status__c != 'Picked Up' && ipw.packege.Status__c != 'Delivered')) ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c)); } ipwList.add(ipw); } } if(ipwList.size() > 0) { PW.innerPackList = ipwList; } else { innerPackageWrapper ipw = new innerPackageWrapper(); ipw.packList.add(new SelectOption('','--None--')); for(Package__c P : Packages) { if(P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c)); } PW.innerPackList.add(ipw); } packageWrapperList.add(PW); }
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for getting organization's currency code
    */
    public static String getCurrencyIsoCode(SObject someObject) { String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency(); return currencyIso; }
    
    /*
      method for redirecting respectively to UPS / InternalSipping page
    */
    public PageReference createUPSShipment() {
        try {
            String sType = '';
            Boolean error = false;
            selectedPackIds = new List<Id>(); 
             
            if(lineItemWrapperList != null) { 
                for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) { if(sType == '') sType = lw.pack.Shipment_Type__c; if(sType == lw.pack.Shipment_Type__c) { selectedPackIds.add(lw.pack.Id); if(shipmentType == null) shipmentType = lw.pack.Shipment_Type__c; } else { errorMsg1 = 'You cannot select packages with different shipment type.'; error = true; break; } } else { if(packageId != null && packageId != '') selectedPackIds.add(packageId); } }                                
            } 
            if(!error) { errorMsg1 = ''; if(selectedPackIds.size() > 0 && shipmentType == 'UPS') { showUPSComponent = true; shipId = ''; retValue = 'SO'; } else if((shipmentId != null && shipmentId != '') && shipmentType == 'UPS') { showUPSComponent = true; shipId = shipmentId; retValue = 'SO'; } else if(selectedPackIds.size() > 0 && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = ''; retValue = 'SO'; } else if((shipmentId != null && shipmentId != '') && shipmentType == 'Shipment') { showInternalShippingComponent = true; shipId = shipmentId; retValue = 'SO'; } else if(selectedPackIds.size() > 0 && shipmentType == 'FedEx') { showfedexComponent = true; shipId = ''; retValue = 'SO'; } else if((shipmentId != null && shipmentId != '') && shipmentType == 'FedEx') { showfedexComponent = true; shipId = shipmentId; retValue = 'SO'; } }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }

    /*
      method for fetching internal shipping details from existing InternalShipping.cls
    */
    public pageReference fetchInternalShippingDetails() {
        Shipment = new Shipment__c();                        
        Is = new InternalShipping();
        if(Is.Shipment != null) Shipment = Is.Shipment; 
        return null;
    }
    
    public PageReference createInternalShipping() {
        try {
            String packIds = '';
            Set<Id> pkgIds = new Set<Id>();        
            if(packageId != null && packageId != '') packIds = packageId;
            if(lineItemWrapperList != null) {
                for(lineItemWrapper lw: lineItemWrapperList) {  if(lw.sel == true) { pkgIds.add(lw.pack.Id);
                                                                 if(packIds != '') packIds += ',';
                                                                 packIds = packIds + lw.pack.Id; }
                }                                
            } return page.pickpackship_InternalShipping; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
       
    /*
      method for generating picking slip(collection of selected SOLI's) as pdf
    */    
    public PageReference createPickingSlips() {
        string salesId;
        try { soliSelectedWrapperList = new List<Wrappers>();
              for(Wrappers wrap : soliWrapperList) {  if(wrap.soliSelected == true)  soliSelectedWrapperList.add(wrap); }
              sales = [Select Id, Name, ERP7__Bill_To_Address__c, ERP7__Ship_To_Address__c, ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c,
                       ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Postal_Code__c,
                       ERP7__Bill_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, ERP7__Ship_To_Address__r.ERP7__Address_Line3__c,
                       ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Contact__c, ERP7__Contact__r.Name,
                       ERP7__Account__c, ERP7__Contact__r.Phone,ERP7__Account__r.ERP7__Company__c, ERP7__Purchase_Order_Number__c, (Select Id, Name, ERP7__Invoice_Date__c From Invoices__r) From ERP7__Sales_Order__c where Id =: salesId]; 
                       
              return page.PickPackShip_CreatePickingSlips;
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
            packageList = new List<Package__c>();
            packList = new List<Package_List__c>();
            packageRecords = new Map<Package__c, List<Package_List__c>>();                    
            if(packageId != null && packageId != '') pkgIds.add(packageId);
            for(lineItemWrapper lw: lineItemWrapperList) { if(lw.sel == true) pkgIds.add(lw.pack.Id); }
            if(pkgIds.size() > 0) {
                for(Package__c p : [select Name, Sales_Order__r.Ship_To_Address__r.Customer__r.Name, Sales_Order__r.Ship_To_Address__r.Address_Line1__c, Sales_Order__r.Ship_To_Address__r.Address_Line2__c, Sales_Order__r.Ship_To_Address__r.Address_Line3__c, Sales_Order__r.Ship_To_Address__r.City__c, Sales_Order__r.Ship_To_Address__r.County__c, 
                                   Sales_Order__r.Contact__c,Sales_Order__r.Ship_To_Address__r.Country__c, Sales_Order__r.Ship_To_Address__r.Contact__r.Phone, Sales_Order__r.Ship_To_Address__r.Contact__r.Fax, Sales_Order__r.Ship_To_Address__r.Contact__r.Name, Sales_Order__r.Ship_To_Address__r.Contact__r.Email, Sales_Order__r.Ship_To_Address__r.State__c, 
                                   Sales_Order__r.Ship_To_Address__r.Postal_Code__c, Barcode__c, Name__c, Sales_Order__r.Account__r.Name, Owner.Name, CreatedDate, Weight__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Sales_Order_Line_Item__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Product__r.SKU__c, 
                                   Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Total_Price__c,  Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Name, SKU__c, 
                                   Package_Weight__c, Sales_Order_Line_Item__r.Description__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {
                     
                     packListRecords = new List<Package_List__c>(); for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); }
                     packageRecords.put(p,packListRecords); contactId = p.Sales_Order__r.Contact__c; newPackageId = p.Id;
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});  Database.rollback(sp); return page.PickPackShip_CreatePackingLists;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
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
                for(Package__c p : [select Name, Sales_Order__r.Ship_To_Address__r.Customer__r.Name, Sales_Order__r.Ship_To_Address__r.Address_Line1__c, Sales_Order__r.Ship_To_Address__r.Address_Line2__c, Sales_Order__r.Ship_To_Address__r.Address_Line3__c, Sales_Order__r.Ship_To_Address__r.City__c, Sales_Order__r.Ship_To_Address__r.County__c, 
                                   Sales_Order__r.Contact__c, Sales_Order__r.Ship_To_Address__r.Country__c, Sales_Order__r.Ship_To_Address__r.Contact__r.Phone, Sales_Order__r.Ship_To_Address__r.Contact__r.Fax, Sales_Order__r.Ship_To_Address__r.Contact__r.Name, Sales_Order__r.Ship_To_Address__r.Contact__r.Email, Sales_Order__r.Ship_To_Address__r.State__c,
                                   Sales_Order__r.Ship_To_Address__r.Postal_Code__c, Barcode__c, Name__c, Sales_Order__r.Account__r.Name, Owner.Name, CreatedDate, Weight__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Sales_Order_Line_Item__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Product__r.SKU__c, 
                                   Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Name, SKU__c, Package_Weight__c, 
                                   Sales_Order_Line_Item__r.Description__c From Package_Lists__r) from Package__c Where Id In: pkgIds And Active__c = true Order by CreatedDate Asc]) {
                     
                     packListRecords = new List<Package_List__c>(); for(sObject c : p.Package_Lists__r) { packListRecords.add((Package_List__c)c); }
                     packageRecords.put(p,packListRecords); contactId = p.Sales_Order__r.Contact__c; newPackageId = p.Id;
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
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach});  Database.rollback(sp); return page.PickPackShip_CreatePackingSlips;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }    
        return null;
    }
    
    /*
      method for generating barcodes from different sObject fields as pdf
    */
    public PageReference createBarcodesPage() { return page.PickPackShip_PrintBarcodes; }
    
    /*
      method for create purchase order upon selected sales order line items
    */
    public PageReference createPOs() {
        try {
            PO = new PO__c(Status__c='New');        
            Set<Id> soIds = new Set<Id>();            
            poliWrapperList = new List<newWrapper>();
            soliSelectedWrapperList = new List<Wrappers>();
            List<Sales_Order_Line_Item__c> soliList = new List<Sales_Order_Line_Item__c>();
            if(soWrapperList.size() > 0){ for(Wrappers sow : soWrapperList) { if(sow.soSelected == true) soIds.add(sow.SO.Id); } } else for(Wrappers sow : soSelectedWrapperList) soIds.add(sow.SO.Id);                       
            if(soIds.size() > 0) { 
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
                else { soliList = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Order_Date__c, Sales_Order__r.Account__r.Name, Sales_Order__r.Channel__c, Product__r.Name, Product__r.Preview_Image__c, Asset__r.Name, '+
                                  +' Product__r.Picture__c, Sales_Order__r.Authorised__c from Sales_Order_Line_Item__c where (Sales_Order__c In : soIds) order by Sales_Order__c ASC');                       
                } if(soIds.size() == 1) PO.Sales_Order__c = (new list<Id>(soIds))[0];
            }
            for(Wrappers wrap : soliWrapperList) { if(wrap.soliSelected == true) soliSelectedWrapperList.add(wrap); }
            if(soliSelectedWrapperList.size() > 0) { 
                for(Wrappers wrap : soliSelectedWrapperList) { newWrapper nwrap = new newWrapper(nextIdent);                    
                                                               nwrap.poli.Active__c = true;
                                                               nwrap.poli.Product__c = wrap.SOLI.Product__c;
                                                               nwrap.poli.Quantity__c = wrap.SOLI.Quantity__c;
                                                               nwrap.poli.Name = wrap.SOLI.Product__r.Name;
                                                               nwrap.poli.Sales_Order_Line_Item__c = wrap.SOLI.Id;
                                                               nwrap.poli.Sales_Order__c = wrap.SOLI.Sales_Order__c;
                                                               poliWrapperList.add(nwrap);
                } if(poliWrapperList.size() > 0) return Page.PickPackShip_CreatePurchaseOrder;
                
            } else if(soliList.size() > 0) {
                for(Sales_Order_Line_Item__c solis: soliList) { newWrapper nwrap = new newWrapper(nextIdent);                    
                                                                nwrap.poli.Active__c = true;
                                                                nwrap.poli.Product__c = solis.Product__c;
                                                                nwrap.poli.Quantity__c = solis.Quantity__c;
                                                                nwrap.poli.Name = solis.Product__r.Name;
                                                                nwrap.poli.Sales_Order_Line_Item__c = solis.Id;
                                                                nwrap.poli.Sales_Order__c = solis.Sales_Order__c;
                                                                poliWrapperList.add(nwrap);
                } if(poliWrapperList.size() > 0) return Page.PickPackShip_CreatePurchaseOrder; } else errorMsg = 'Please select an order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for adding more POLI rows
    */
    public PageReference addPoliWrapperRows() {
        try {
            for(Integer i=0; i<addRow; i++) { poliWrapperList.add(new newWrapper(nextIdent++)); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting POLI rows
    */
    public PageReference delPoliWrapperRow() {
        try {
            if(toDelIdent != null) poliWrapperList.remove(toDelIdent); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for saving PO details
    */
    public PageReference savePO() {
        try {
            if(PO != null) if(Schema.sObjectType.PO__c.isCreateable()&& Schema.sObjectType.PO__c.isUpdateable()) {DMLManager.upsertAsUser(PO); } else { /* no aceeess*/}      
            Polis = new List<Purchase_Line_Items__c>(); 
            for(newWrapper nwrp: poliWrapperList) { Purchase_Line_Items__c poli = new Purchase_Line_Items__c();                
                                                    poli = nwrp.poli;
                                                    poli.Purchase_Orders__c = PO.Id;
                                                    Polis.add(poli);
                                                  } if(Polis.size() > 0) if(Schema.sObjectType.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.isUpdateable()) { DMLManager.upsertAsUser(Polis);} else { /* no aceeess*/}        
              return Page.PickPackShip_Order; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for create work order upon selected sales order line items
    */
    public PageReference createWOs() {
        try {
            WO = new WO__c(Status__c='New'); 
            Set<Id> soIds = new Set<Id>();
            woliWrapperList = new List<newWrapper>();
            soliSelectedWrapperList = new List<Wrappers>();
            List<Sales_Order_Line_Item__c> soliList = new List<Sales_Order_Line_Item__c>();                        
            if(soWrapperList.size() > 0){ for(Wrappers sow : soWrapperList) { if(sow.soSelected == true) soIds.add(sow.SO.Id); } } else for(Wrappers sow : soSelectedWrapperList) soIds.add(sow.SO.Id);                       
            if(soIds.size() > 0) { 
                if(!Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Sales_Order_Line_Item__c.Label));
                else { soliList = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Order_Date__c, Sales_Order__r.Account__r.Name, Sales_Order__r.Channel__c, Product__r.Name, Product__r.Preview_Image__c, Asset__r.Name, '+
                                  +'Product__r.Picture__c, Sales_Order__r.Authorised__c from Sales_Order_Line_Item__c where (Sales_Order__c In : soIds) order by Sales_Order__c ASC');                       
                } if(soIds.size() == 1) WO.Sales_Order__c = (new list<Id>(soIds))[0];
            }
            for(Wrappers wrap : soliWrapperList) { if(wrap.soliSelected == true) soliSelectedWrapperList.add(wrap); }
            if(soliSelectedWrapperList.size() > 0) {
                for(Wrappers wrap : soliSelectedWrapperList) { newWrapper nwrap = new newWrapper(nextIdent);                    
                                                               nwrap.woli.Active__c = true;
                                                               nwrap.woli.Product__c = wrap.SOLI.Product__c;
                                                               nwrap.woli.Quantity__c = wrap.SOLI.Quantity__c;
                                                               nwrap.woli.Sales_Order_Line_Item__c = wrap.SOLI.Id;
                                                               nwrap.woli.Sales_Order__c = wrap.SOLI.Sales_Order__c;
                                                               woliWrapperList.add(nwrap);
                } if(woliWrapperList.size() > 0) return Page.PickPackShip_CreateWorkOrder;            
                
            } else if(soliList.size() > 0) {
                for(Sales_Order_Line_Item__c solis: soliList) { newWrapper nwrap = new newWrapper(nextIdent);    
                                                                nwrap.woli.Active__c = true;
                                                                nwrap.woli.Product__c = solis.Product__c;
                                                                nwrap.woli.Quantity__c = solis.Quantity__c;
                                                                nwrap.woli.Sales_Order_Line_Item__c = solis.Id;
                                                                nwrap.woli.Sales_Order__c = solis.Sales_Order__c;
                                                                woliWrapperList.add(nwrap);
                } if(woliWrapperList.size() > 0) return Page.PickPackShip_CreateWorkOrder; } else errorMsg = 'Please select an order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    /*
      method for adding more WOLI rows
    */
    public PageReference addWoliWrapperRows() {
        try {
            for(Integer i=0; i<addRow; i++) { woliWrapperList.add(new newWrapper(nextIdent++)); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting WOLI rows
    */
    public PageReference delWoliWrapperRow() {
        try {
            if(toDelIdent != null) woliWrapperList.remove(toDelIdent);             } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for saving WO details
    */
    public PageReference saveWO() {
        try {
            if(WO != null) if(Schema.sObjectType.WO__c.isCreateable()&& Schema.sObjectType.WO__c.isUpdateable()) {DMLManager.upsertAsUser(WO);} else { /* no aceeess*/} 
            Wolis = new List<Work_Order_Line_Items__c>();       
            for(newWrapper nwrp: woliWrapperList) { Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c();                
                                                    woli = nwrp.woli;
                                                    woli.Work_Orders__c = WO.Id;
                                                    Wolis.add(woli);
            } if(Wolis.size() > 0 && Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(Wolis);        
              return Page.PickPackShip_Order; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    public pageReference createOrder() {                   
        pageReference pag = new pageReference('/apex/ERP7__Stockdispatching_SalesOrder');
        pag.setRedirect(true);
        return pag;        
    }
    public PageReference back() {
        pageReference pag = new pageReference('/apex/ERP7__Stockdispatching_SalesOrder');
        pag.setRedirect(true);
        return pag;
    }     
    public PageReference back1() {
        return page.pickpackship_CreatePackage;
    }
    /* public pageReference hideShipmentComponents() {
        if(showUPSComponent) showUPSComponent = false;
        else if(showInternalShippingComponent) showInternalShippingComponent = false;
        return null;
    } */
    
    /* Deprecated method */
    public PageReference acceptTrackNotice() { return null; }
    public PageReference CreateUPSLabel() { return null; }
    /* Deprecated method */
    
    /*
      wrapper class definitions
    */
    public static String sortBy                                { get; set; }    
    public static String prevSortBy                            { get; set; } public static String orderFormat                           { get; set; }
        
    public List<Wrappers> soWrapperList                        { get; set; }   
    public List<Wrappers> soliWrapperList                      { get; set; }
    public List<Wrappers> shipmentWrapperList                  { get; set; }    
    public List<Wrappers> soSelectedWrapperList                { get; set; }
    public List<Wrappers> soliSelectedWrapperList              { get; set; }      
    public List<Wrappers> shipmentSelectedWrapperList          { get; set; }  
    
    public class Wrappers implements Comparable{        //implements Comparable
        public String warehouseName                            { get; set; } 
        public String WN                                       { get; set; } 
        public String LN                                       { get; set; } 
        public String binName                                  { get; set; }         
        public String batchLotCode                             { get; set; }   
        public String stockId                                  { get; set; } 
        public Package__c sPkg                                 { get; set; }        
        public Sales_Order__c SO                               { get; set; }              
        public Integer raisedQty                               { get; set; }
        public Boolean soSelected                              { get; set; }        
        public Boolean shipSelected                            { get; set; }    
        public Integer requiredQty                             { get; set; }
        public String locationName                             { get; set; }
        public String trackingNo                               { get; set; }
        public Shipment__c shipM                               { get; set; }
        public String shipmentType                             { get; set; }
        public Integer remainingQty                            { get; set; }
        public Boolean soliSelected                            { get; set; }
        public Boolean soliVerified                            { get; set; }   
        public Boolean include                                 { get; set; }
        public Boolean isSOLIawaiting                          { get; set; }       
        public Decimal inventoryStock                          { get; set; } 
        public Sales_Order_Line_Item__c SOLI                   { get; set; }           
        public Boolean isAvailablePackages                     { get; set; }
        public Boolean isAvailableShipments                    { get; set; } 
        public Boolean isAllShipmentsDelivered                 { get; set; } 
        public List<SelectOption> CurrentBins                  { get; set; }        
        public List<SelectOption> CurrentLocations             { get; set; }
        public List<SelectOption> CurrentWarehouses            { get; set; }
        public List<SelectOption> Address                      { get; set; }
        public String AddressName                              { get; set; }
        public String SD                                       { get; set; }
        public List<SelectOption> BatchLotCodes                { get; set; }
        public ERP7__MRP__c MRP                                { get; set; }
        public Product2 product                                { get; set; }
        public Asset__c Asset                                  { get; set; }
        public List<Wrappers> MRPsWrapperList                  { get; set; }
        public Stock_Outward_Line_Item__c SerialNumbers        { get; set; }
        public Boolean serialized                              { get; set; }
        
        public ERP7__Logistic__c Logistic                      { get; set; }
        
        public Wrappers() {  
            SD = '';          
            WN = '';     
            LN = '';
            //batchLotCode = '';
            AddressName = '';
            include = false;            
            binName = null;
            stockId = null;                  
            raisedQty = 0;
            requiredQty = 0;
            remainingQty = 0;
            trackingNo = ''; 
            inventoryStock = 0;                  
            soSelected = false;  
            soliSelected = false;
            soliVerified = false;
            shipSelected = false;
            locationName = null;                                   
            isSOLIawaiting = false;                          
            warehouseName = null;
            shipM = new Shipment__c();
            sPkg = new Package__c();
            SO = new Sales_Order__c();
            isAvailablePackages = false;
            isAvailableShipments = false;  
            isAllShipmentsDelivered = false;              
            Address = new List<SelectOption>();                                
            SOLI = new Sales_Order_Line_Item__c();
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
            
            Logistic = new Logistic__c();              
        }   
         
        public Integer compareTo(Object objToCompare) { if(sortBy == 'WN') { Integer result = WN.compareTo(((Wrappers)objToCompare).WN); return (orderFormat == 'ASC')? result : result * -1; } else if(sortBy == 'LN') { Integer result = LN.compareTo(((Wrappers)objToCompare).LN); return (orderFormat == 'ASC')? result : result * -1; } else if(sortBy == 'SD') { Integer result = SD.compareTo(((Wrappers)objToCompare).SD); return (orderFormat == 'ASC')? result : result * -1; } return 0; } 
                     
    }
    
    public List<newWrapper> poliWrapperList               { get; set; }
    public List<newWrapper> woliWrapperList               { get; set; }     
    public class newWrapper {
        public Purchase_Line_Items__c poli                { get; set; }
        public Work_Order_Line_Items__c woli              { get; set; }  
        public Integer ident                              { get; set; } 

        public newWrapper(Integer inIdent) {
            ident = inIdent;
            poli = new Purchase_Line_Items__c();
            woli = new Work_Order_Line_Items__c();
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
        public Sales_Order_Line_Item__c Soli                     { get; set; }
        public MRP__c MRP                                        { get; set; }
        public List<innerPackageWrapper> innerPackList           { get; set; }        
      
        public packageWrapper(){ 
            qtyToPick = 0;
            qtyToPack = 0;
            pkgSelected = false;
            Soli = new Sales_Order_Line_Item__c();
            MRP = new MRP__c();
            innerPackList = new List<innerPackageWrapper>();
        } 
    }   
    
    public class lineItemWrapper {
        public Boolean sel                               { get; set; }
        public String units                              { get; set; }  
        public Package__c pack                           { get; set; }
        public Shipment__c shipment                      { get; set; }
        public Decimal NoofLineItems                     { get; set; }        
        
        public lineItemWrapper() {
            units = ''; 
            sel = false;            
            NoofLineItems = 0;
            pack = new Package__c();
            shipment = new Shipment__c();            
        }
    }    
}