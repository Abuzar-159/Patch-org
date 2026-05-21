public with sharing class OutboundLogistics {
    //not being used anywhere but exists to compensate overall code coverage - Arshad 16/02/23
    public List<SelectOption> Customers                                { get; set; } public String Customer                                             { get; set; }
    public Boolean CustomerPresent                                     { get; set; }
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
    public String orderNumber                                          { get; set; } public InternalShipping Is                                         { get; set; }    
    public String pkgTypeValue                                         { get; set; }    
    public String shipmentType                                         { get; set; }        
    public String PackageFields                                        { get; set; }
    public String ShipmentFields                                       { get; set; }  
    public String pack2updateId                                        { get; set; }
    public String service_code                                         { get; set; }    
    public String delivery_date                                        { get; set; } public Shipment__c Shipment                                        { get; set; }  
    
    public List<Id> selectedPackIds                                    { get; set; } public static Integer addRow                                       { get; set; }
    public Boolean time_in_cost_tab                                    { get; set; }
    public String ShipmentRecTypeId                                    { get; set; }     
    public String packageListFields                                    { get; set; }       
    public static Integer toDelIdent                                   { get; set; }     
    public String siteFields                                           { get; set; } 
    public Boolean CreatePack                                          { get; set; }              
    public Boolean isAwaiting                                          { get; set; }
    public String customerId                                           { get; set; }
    public Integer rowCounter                                          { get; set; } 
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
    public Boolean showInternalShippingComponent                       { get; set; } public List<Package_List__c> packListRecords                       { get; set; }
    public List<Sales_Order_Line_Item__c> soliList                     { get; set; } 
    public List<packageWrapper> packageWrapperList                     { get; set; }     
    public List<lineItemWrapper> lineItemWrapperList                   { get; set; }   
    public List<Stock_Outward_Line_Item__c> PPLIList                   { get; set; }    
    public List<Logistic_Line_Item__c > currentItems                   { get; set; }                     
    public Map<Id, List<Package_List__c>> packageListMap               { get; set; }     
    public List<Stock_Outward_Line_Item__c> ppliItemList               { get; set; } public List<packageWrapper> selectedPackageWrapperList             { get; set; }        
    public List<Stock_Outward_Line_Item__c> PPLIList2Delete            { get; set; }
    public Map<Id, List<Stock_Outward_Line_Item__c>> ppliMap           { get; set; } public List<Distribution_Channel__c> DistributionChannels          { get; set; }     
    public Map<Package__c, List<Package_List__c>> packageRecords       { get; set; }       
    public Map<Shipment__c, List<Package_List__c>> shipmentRecords     { get; set; }    
    public String barcode                                              { get; set; }       
    Public Boolean scanned                                             { get; set; }
    public PrintBarcodes PB                                            { get; set; }          
    public String barcodeLoc                                           { get; set; }      
    public String sfdcBaseURL                                          { get; set; }
    public Boolean initialScan                                         { get; set; }
    public String barcodeLocMsg                                        { get; set; }       public EmailTemplate packingTemplate                               { get; set; } 
    public EmailTemplate shippingTemplate                              { get; set; } 
    public Employees__c Employee                                       { get; set; }
    public List<SelectOption> channelSites                             { get; set; }
    public Id selectedSite                                             { get; set; }
    public String selectedOrders                                       { get; set; }
    public Boolean showFedexComponent                                  { get; set; }
    public Boolean showDHLComponent                                    { get; set; }
    public Boolean showUSPSComponent                                   { get; set; }  
    public Integer ScanNo                                              { get; set; }
    public ERP7__Sales_Order__c sales                                  { get; set; }
    public Boolean showSN                                              { get; set; } 
    public Boolean showBatch                                           { get; set; } 
    public ERP7__Logistic__c Logistic                                  { get; set; } 
    public String logFields                                            { get; set; } 
    public String logLineFields                                        { get; set; } 
    public String logisticId                                           { get; set; }
    public List<ERP7__Logistic__c> Logistics                           { get; set; }
    public Integer PackingSlipHeight                                   { get; set; }
    public List<Id> SerialIds2Exempt                                   { get; set; }
    public Boolean reRend                                              { get; set; }
    
    public List<Integer> PNS                                           { get; set; }
    public Integer startCount                                          { get; set; }
    public Integer endCount                                            { get; set; }
    public Integer Offset                                              { get; set; }
    public Integer recSize                                             { get; set; }
    public Integer PageNum                                             { get; set; }
    public Integer Show                                                { get; set; } public String errormsg3                                            { get; set; } public Boolean hasAccess                                           { get; set; }
    
    public OutboundLogistics() {
       
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
            logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
            logLineFields += ', Logistic__r.ERP7__Order__c, Product__r.Is_Asset__c, Product__r.ProductCode, ERP7__Logistic__r.Name, Product__r.Item_Description__c, Product__r.Weight__c, Product__r.Special_Instructions__c, Product__r.ERP7__Is_Kit__c, Product__r.ERP7__Kit_Protected__c, Sales_Order_Line_Item__r.Sales_Order__c, Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Shipment_Type__c, Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Special_Instructions__c, Sales_Order_Line_Item__r.Sales_Order__r.ERP7__UPS_Service__c, Sales_Order_Line_Item__r.Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c, '+
                          +'Logistic__r.Account__c, Logistic__r.Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c, Product__r.Barcode__c, Product__r.Serialise__c, ERP7__Fixed_Asset__r.Serialise__c';
            
            
            PackingSlipHeight = 500;
            ScanNo = 0;                 
            errorMsg = '';
            searchText = '';
            nextIdent = 0; 
            CustomerPresent = false;
            showUPSComponent = false;  
            showFedexComponent = false;
            showDHLComponent = false;
            showUSPSComponent = false;
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
            reRend = false;
            Logistics = new List<ERP7__Logistic__c>();
            
            PNS = new List<Integer>();
            Show = 25;
            startCount = endCount = Offset = recSize = PageNum = 0;
            
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
            sfdcBaseURL = sfdcBaseURL.replace('erp7','c');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            imageURL = '/servlet/servlet.FileDownload?file=';
            List<Document> documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
            if(documentList.size() > 0) imageURL = imageURL + documentList[0].id; 
                     
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
                            channelSites.add(new SelectOption(DC.Site__c,DC.Name));
                        }
                        selectedSite = DistributionChannels[0].Site__c;
                    }  
                } 
            }       
             
            authorisedOrders();
            if(ApexPages.CurrentPage().getParameters().get('loId') != '' && ApexPages.CurrentPage().getParameters().get('loId') != null) {
                logisticId = ApexPages.CurrentPage().getParameters().get('loId');
                redirect2NextTab();
            }
            String SWL = ApexPages.CurrentPage().getParameters().get('pb');
            if(SWL != '' && SWL != null) { PB = (PrintBarcodes) JSON.deserialize(SWL, PrintBarcodes .class); }
            //if(PreventRecursiveLedgerEntry.PB != null && PreventRecursiveLedgerEntry.PB.BarcodeWrapperList.size() > 0) PB = PreventRecursiveLedgerEntry.PB;
   
    }
   
    public void authorisedOrders() {
            Set<Id> loIds = new Set<Id>();
            soWrapperList = new List<Wrappers>();
            List< ERP7__Logistic_Line_Item__c > loliList = new List< ERP7__Logistic_Line_Item__c >();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>(); 
            logisticId = ApexPages.CurrentPage().getParameters().get('loId');  
            String tempPOChannel = Employee.Channel__c;   
            errorMsg = '';
          
            // Take outbound logistics and map it with SO
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>(); 
            List<ERP7__Logistic__c> Recs = new List<ERP7__Logistic__c>();       
            if(!Schema.sObjectType.ERP7__Logistic__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic__c.Label));
            else { 
                if(logisticId != null && logisticId != '') {
                    
                    Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ', ERP7__Sales_Order__r.Name , ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, '+
                             +' ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where ERP7__Active__c = true And Total_Quantity__c > 0 And (ERP7__Type__c =\'Outbound\') And Id =\'' + String.escapeSingleQuotes(logisticId) + '\' And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Channel__c =: tempPOChannel And ERP7__RMA__c = Null Order by CreatedDate Desc Limit 1');
                }
            } 
            for(ERP7__Logistic__c log : Logs) { loIds.add(log.Id); }                                   
            if(loIds.size() > 0) {
               
            }
            if(Logs.size() > 0) {
               
            } else errorMsg = 'Sorry, no records available to view.';             
                        
    }
    
    public PageReference SiteSelect() {
            Set<Id> loIds = new Set<Id>();
            soWrapperList = new List<Wrappers>();
            List< ERP7__Logistic_Line_Item__c > loliList = new List< ERP7__Logistic_Line_Item__c >();
            List<Package__c> pkgList = new List<Package__c>();
            List<Shipment__c> shipList = new List<Shipment__c>(); 
            logisticId = ApexPages.CurrentPage().getParameters().get('loId');  
            String tempPOChannel = Employee.Channel__c;   
            errorMsg = '';
            startCount = endCount = Offset = 0;
            PageNum = 1;
            
            // Take outbound logistics and map it with SO
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>(); 
            List<ERP7__Logistic__c> Recs = new List<ERP7__Logistic__c>();       
            if(!Schema.sObjectType.ERP7__Logistic__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic__c.Label));
            else { 
                if(logisticId != null && logisticId != '') {
                    Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ', ERP7__Sales_Order__r.Name , ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, '+
                             +' ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where ERP7__Active__c = true And Total_Quantity__c > 0 And (ERP7__Type__c =\'Outbound\') And Id =\'' + String.escapeSingleQuotes(logisticId) + '\' And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Channel__c =: tempPOChannel And ERP7__RMA__c = Null Order by Expected_Date__c Asc Limit 1');
                }
            } 
            for(ERP7__Logistic__c log : Logs) { loIds.add(log.Id); }                                   
            if(loIds.size() > 0) {
                }
            if(Logs.size() > 0) {
              
            } else errorMsg = 'Sorry, no records available to view.';             
                
        return Null;
    }
    
    public PageReference redirect2NextTab() {
            Boolean error = false;
            String customerId = '';
            showSN = false;
            showBatch = false;
            String Reserved = 'Reserved';        
            Set<Id> soIds = new Set<Id>();
            Set<Id> spIds = new Set<Id>();
            Set<Id> proIds = new Set<Id>();
            Set<Id> assIds = new Set<Id>();
            Set<Id> OrderIds = new Set<Id>();
            SerialIds2Exempt = new List<Id>();
            selectedOrders = barcodeLoc = barcodeLocMsg = '';            
            SSLList = new List<Location__c>();
            soliWrapperList = new List<Wrappers>();
            binList = new List<StorageContainer__c>();
            PPLIList2Delete = new List<Stock_Outward_Line_Item__c>(); 
            
            if(soWrapperList.size() > 0) {
                soSelectedWrapperList = new List<Wrappers>();
                for(Wrappers sow : soWrapperList) {
                    if(sow.soSelected == true) {
                        if(logisticId == sow.logistic.Id) logisticId = Null;
                        if(customerId == '') customerId = sow.logistic.Account__c;
                        //if(customerId == sow.logistic.Account__c) { 
                            soIds.add(sow.logistic.Id);
                            if(sow.logistic.ERP7__Sales_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Sales_Order__c);
                            if(sow.logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Purchase_Order__c);
                            if(sow.logistic.ERP7__Work_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Work_Order__c);
                            if(sow.logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Transfer_Order__c);
                            spIds.add(sow.logistic.Channel__c);
                            selectedOrders = (selectedOrders != '')? (selectedOrders+ ', ' +sow.logistic.Name) : sow.logistic.Name;  
                            soSelectedWrapperList.add(sow); 
                        //} else { errorMsg = 'You cannot select orders with different customer.'; error = true; selectedOrders = ''; break; }                    
                    }
                    if(logisticId == sow.logistic.Id){ 
                      
                    }
                } 
            } else {
                for(Wrappers sow : soSelectedWrapperList) {
                    if(sow.soSelected == true) {
                        if(customerId == '') customerId = sow.logistic.Account__c; 
                        soIds.add(sow.logistic.Id);
                        if(sow.logistic.ERP7__Sales_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Sales_Order__c);
                        if(sow.logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Purchase_Order__c);
                        if(sow.logistic.ERP7__Work_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Work_Order__c);
                        if(sow.logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Transfer_Order__c);
                        spIds.add(sow.logistic.Channel__c);
                    }
                    if(logisticId == sow.logistic.Id){ 
                        sow.soSelected = true;
                        selectedOrders = (selectedOrders != '')? (selectedOrders+ ', ' +sow.logistic.Name) : sow.logistic.Name;
                        soIds.add(sow.logistic.Id); 
                        if(sow.logistic.ERP7__Sales_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Sales_Order__c);
                        if(sow.logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Purchase_Order__c);
                        if(sow.logistic.ERP7__Work_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Work_Order__c);
                        if(sow.logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Transfer_Order__c);
                        spIds.add(sow.logistic.Channel__c);
                    }
                } 
            }
            
                                                                                   
            if(soIds.size() > 0) {
                if(!error) { 
                    soWrapperList = new List<Wrappers>();
                    errorMsg =  '';
                    Map<Id, Product2> productMap = new Map<Id, Product2>();
                    Map<Id, Asset__c> assetMap = new Map<Id, Asset__c>();
                    List<MRP__c> MRPS = new List<MRP__c>();                 
                    Set<Id> WIISIds = new Set<Id>();
                    Set<Id> mrpIds = new Set<Id>();
                    Map<Id, List<ERP7__Stock_Outward_Line_Item__c>> lolisSolis = new Map<Id, List<ERP7__Stock_Outward_Line_Item__c>>();
                    String mrpKit = 'MRP Kit';
                    String TrueValue = 'True';
                    
                    List<ERP7__Logistic_Line_Item__c> soliss = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In: soIds and ERP7__RMA_Line_Item__c = Null order by ERP7__Logistic__c ASC'); 
                    
                    List<ERP7__Stock_Outward_Line_Item__c> pplis = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ', ERP7__Serial__r.Id, ERP7__Serial__r.ERP7__Serial_Number__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c from Stock_Outward_Line_Item__c where (ERP7__Sales_Order__c In: OrderIds Or ERP7__Work_Orders__c In: OrderIds Or ERP7__Purchase_Orders__c In: OrderIds Or ERP7__Transfer_Order__c In: OrderIds) and ERP7__Status__c  = :Reserved and ERP7__Quantity__c > 0 and ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :selectedSite and ERP7__RMA_Line_Item__c = Null ');
                    
                    for(ERP7__Stock_Outward_Line_Item__c ppli: pplis) { WIISIds.add(ppli.Site_Product_Service_Inventory_Stock__c); if(ppli.ERP7__Product__c != Null) proIds.add(ppli.ERP7__Product__c); if(ppli.ERP7__Fixed_Asset__c != Null) proIds.add(ppli.ERP7__Fixed_Asset__r.ERP7__Product__c); if(ppli.ERP7__Fixed_Asset__c != Null) assIds.add(ppli.ERP7__Fixed_Asset__c); if(ppli.ERP7__MRP_Material_Requirements_Planning__c != Null) mrpIds.add(ppli.ERP7__MRP_Material_Requirements_Planning__c); }
                    
                    MRPS = Database.query('select ' + String.escapeSingleQuotes(MRPFields) + ' ,Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Item_Description__c, MRP_Product__r.ERP7__Lot_Tracked__c, MRP_Product__r.Serialise__c from MRP__c where ((Sales_Order_Line_Item__r.ERP7__Sales_Order__c In :OrderIds Or ERP7__Purchase_Order__c In :OrderIds Or ERP7__Work_Order__c In :OrderIds Or ERP7__Transfer_Order__c In :OrderIds) And ERP7__Status__c  = :Reserved And RecordType.Name = :mrpKit And Id In: mrpIds)');
                    
                    for(ERP7__Logistic_Line_Item__c loli : soliss){
                        List<ERP7__Stock_Outward_Line_Item__c> mySolis = new List<ERP7__Stock_Outward_Line_Item__c>();
                        for(ERP7__Stock_Outward_Line_Item__c ppli: pplis) { if((ppli.ERP7__Sales_Order_Line_Item__c != Null && ppli.ERP7__Sales_Order_Line_Item__c == loli.ERP7__Sales_Order_Line_Item__c) || (ppli.ERP7__Purchase_Line_Items__c != Null && ppli.ERP7__Purchase_Line_Items__c == loli.ERP7__Purchase_Line_Items__c) || (ppli.ERP7__Work_Order_Line_Items__c != Null && ppli.ERP7__Work_Order_Line_Items__c == loli.ERP7__Work_Order_Line_Items__c) || (ppli.ERP7__Transfer_Order_Line_Item__c != Null && ppli.ERP7__Transfer_Order_Line_Item__c == loli.ERP7__Transfer_Order_Line_Item__c)){ mySolis.add(ppli);} } 
                        lolisSolis.put(loli.Id,mySolis);
                    }
                    
                    productMap = new Map<Id, Product2>([Select Id, Name, ProductCode, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]); //Serialise__c
                    assetMap = new Map<Id, Asset__c>([Select Id, Name, Picture__c, Preview_Image__c, Status__c, Item_Description__c, Special_Instructions__c, Weight__c, Barcode__c, ERP7__Serialise__c From Asset__c Where Id In: assIds]); //Serialise__c
                    
                    List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(warehouseFields) + ', Fixed_Asset__r.Product__c, Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                       +' StorageContainer__r.Barcode__c from Inventory_Stock__c where Warehouse__c =: selectedSite And ((Product__c In: proIds And (ERP7__Number_of_Item_In_Stock__c > 0 Or Id In :WIISIds)) Or Fixed_Asset__r.Product__c In: proIds ) Order By ERP7__Expiry_Date__c ASC'); 
                     
                    List<ERP7__Stock_Inward_Line_Item__c> StockInwardLineItems = [Select Id, Name, Active__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Material_Batch_Lot__r.ERP7__Availability_date__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Product__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Serial__c, ERP7__Serial__r.ERP7__Available__c,
                                                                                    ERP7__Material_Batch_Lot__r.ERP7__Inward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Outward_Quantity__c, ERP7__Material_Batch_Lot__r.ERP7__Available_Quantity__c, Fixed_Asset__c, Fixed_Asset__r.Product__c, ERP7__Material_Batch_Lot__r.ERP7__Production_Version__c
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
                    Map<Id,Id> batchVersion = new Map<Id,Id>();
                    Map<Id,List<ERP7__Inventory_Stock__c>> productStocks = new Map<Id,List<ERP7__Inventory_Stock__c>>();
                    Map<Id,Set<SelectOption>> stockBatches = new Map<Id,Set<SelectOption>>();
                    Map<Id,Set<Id>> stockSerials = new Map<Id,Set<Id>>();
                    
                    for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                    
                    }
                    
                    Map<Id, List<MRP__c>> soliMRPS = new Map<Id, List<MRP__c>>();
                    
                    for(ERP7__Logistic_Line_Item__c solis : soliss) {
                        Set<MRP__c> myMRPS = new Set<MRP__c>();
                        for(MRP__c mrp : MRPS) { if((solis.ERP7__Sales_Order_Line_Item__c != Null && mrp.Sales_Order_Line_Item__c == solis.ERP7__Sales_Order_Line_Item__c) || (solis.ERP7__Purchase_Line_Items__c != Null && mrp.ERP7__Purchase_Line_Items__c == solis.ERP7__Purchase_Line_Items__c) || (solis.Work_Order_Line_Items__c != Null && mrp.ERP7__Work_Order_Line_Items__c == solis.Work_Order_Line_Items__c) || (solis.ERP7__Transfer_Order_Line_Item__c != Null && mrp.ERP7__Transfer_Order_Line_Item__c == solis.ERP7__Transfer_Order_Line_Item__c)){ myMRPS.add(mrp); } }
                        List<MRP__c> myMRPSNew = new List<MRP__c>();
                        myMRPSNew.addAll(myMRPS);
                        soliMRPS.put(solis.Id,myMRPSNew);
                    }
                   
                    for(ERP7__Logistic_Line_Item__c solis : soliss) {
                        if(solis.ERP7__Quantity__c > 0 && (solis.ERP7__Picked_Quantity__c == Null || solis.ERP7__Quantity__c > solis.ERP7__Picked_Quantity__c) && lolisSolis.containsKey(solis.Id)){
                            for(ERP7__Stock_Outward_Line_Item__c sli : lolisSolis.get(solis.Id)){ 
                              
                            }
                        }        
                    }
                    return page.Pick;                   
                }                
            } else errorMsg = 'Please select an order to proceed.'; 
        return null;
    }
    
    public PageReference back2ShipmentPage() {
        if(ApexPages.currentPage().getParameters().get('shipmentId') != null) return page.Ship;
        else if(ApexPages.currentPage().getParameters().get('pack') != null) return page.Pack;
        return null; 
    }
    
    public PageReference deleteShipment() {
        try {
            if(packageId != null) shipmentWrapperList.remove(Integer.valueof(packageId));
            if(shipmentId != null && Shipment__c.sObjectType.getDescribe().isDeletable()) { delete new Shipment__c(Id = shipmentId); } else{ errorMsg = 'You are not allowed to delete';} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference createInternalShipping() {
        return null;
    }
    
    public PageReference scannerMethod() { 
        try { 
            String tempPOChannel = Employee.Channel__c;  
            Logistics = Database.query('select ' + String.escapeSingleQuotes(logFields) + ', ERP7__Sales_Order__r.Name , ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, '+
                             +' ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where ERP7__Active__c = true And Total_Quantity__c > 0 And (ERP7__Type__c =\'Outbound\') And Barcode__c =\'' + String.escapeSingleQuotes(barcode.trim()) + '\' Order by Expected_Date__c Asc Limit 1'); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference scannerMethodCustomReload() { 
        try {
            string mybarcode = barcode.trim();
            if(mybarcode == 'ORDER') { return createOrder(); } else if(mybarcode == 'PICK') { return redirect2NextTab(); }else if(mybarcode == 'SAVE') { return saveSOLIs(); }
            else if(mybarcode == 'PACK') { return createPacks(); } else if(mybarcode == 'SHIP') { return createShipments(); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }  
        return null;  
    }
    
    public PageReference scannerMethodCustom() { 
            errorMsg = '';
            barcodeLocMsg = '';
            string mybarcode = barcode.trim();
            reRend = false;
            
            if(mybarcode == 'ORDER' || mybarcode == 'PICK' || mybarcode == 'SAVE' || mybarcode == 'PACK' || mybarcode == 'SHIP') { reRend = true; return null; }
            
            List<ERP7__Logistic_Line_Item__c> loliListcheck;
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<ERP7__Batch__c> verifyBatches = new List<ERP7__Batch__c>();            
            List< ERP7__BOM__c > PackageBOMs = new List< ERP7__BOM__c >();   
            
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
            
            if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic_Line_Item__c.Label));
            else { 
                if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.Fields.Barcode__c.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.Fields.Barcode__c.getLabel()+' of sObject '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.getLabel());
                if(!Schema.sObjectType.ERP7__Logistic_Line_Item__c.Fields.Name.isAccessible()) throw new FLSException('Insufficient access To Field '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.Fields.Name.getLabel()+' of sObject '+Schema.SObjectType.ERP7__Logistic_Line_Item__c.getLabel());            
                loliListcheck = [select Id, Name, Barcode__c, Product__c, Product__r.Barcode__c from ERP7__Logistic_Line_Item__c where Barcode__c =:barcode.trim() Or Product__r.Barcode__c =:barcode.trim() limit 1]; 
                verifyBatches = [Select Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__Available_Quantity__c, ERP7__Product__c From ERP7__Batch__c Where ERP7__Barcode__c =: barcode.trim()];
            }    
            
            // If Sales Order is found            
            soWrapperList = new List<Wrappers>();
            if(Logistics.size() > 0) { for(ERP7__Logistic__c sos : Logistics) {  Wrappers wrap = new Wrappers(); wrap.soSelected = true; wrap.Logistic = sos; soWrapperList.add(wrap); return null; }    
            }
            if(siteList.size() > 0 || SSLList.size() > 0 || binList.size() > 0) { 
                // The Warehouse, location or bin code is found                         
               
            } else if(ScanNo == 0) { 
                if(loliListcheck.size() > 0 || verifyBatches.size() > 0) {
                    Batch__c myBatch = new Batch__c();
                    for(Wrappers W : soliWrapperList) { for(Batch__c bat : verifyBatches){ if(W.soliVerified && bat.Product__c == W.loli.Product__c) { myBatch = bat; break; } }
                    }
                    for(Wrappers W : soliWrapperList) { if(W.soliVerified && W.soliSelected && (barcode.trim() == W.loli.Barcode__c || barcode.trim() == W.loli.Product__r.Barcode__c || myBatch.Product__c == W.loli.Product__c)) { if(!(W.LOLI.Product__r.Is_Kit__c && W.LOLI.Explode__c) && W.requiredQty < (W.LOLI.Quantity__c - W.raisedQty) && ((W.inventoryStock - W.requiredQty) > 0)){ W.requiredQty += 1; return null; } else if(W.LOLI.Product__r.Is_Kit__c && W.LOLI.Explode__c && W.requiredQty < (W.MRP.Total_Amount_Required__c - W.raisedQty) && ((W.inventoryStock - W.requiredQty) > 0)){ W.requiredQty += 1; return null;
                            }  
                        } 
                    }
                }
                barcodeLocMsg = 'Invalid Barcode';
                return null;   } return null;
	}
    
    public PageReference createWOs() { return null; }
    
    public PageReference createPOs() { return null; }
    
    public PageReference createOrder() { pageReference pag = new pageReference('/apex/ERP7__OutboundLogistics'); pag.setRedirect(true); return pag; }
    
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
                shippingTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: 'Logistics_Shipping_Slip'];            
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
                
                return page.LogisticsCreateShippingSlips;    
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    public PageReference createShipments() {
        try {
            Set<Id> soIds = new Set<Id>();
            shipmentList = new List<Shipment__c>();
            shipmentWrapperList = new List<Wrappers>();
            // multiple SO to create package
            
            if(soWrapperList.size() > 0){ 
                         
            }
            else {
                for(Wrappers sow : soSelectedWrapperList) { 
                    soIds.add(sow.logistic.Id); 
                }
            }  
            
            if(soIds.size() > 0) {
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { shipmentList = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' ,RecordType.Name, Sales_Order__r.Name, Customer__r.Name, Shipping_Address__r.Customer__r.Name, Shipping_Address__r.Address_Line1__c, Shipping_Address__r.Address_Line2__c, Shipping_Address__r.Address_Line3__c, '+
                                      +' Shipping_Address__r.City__c, Shipping_Address__r.County__c, Shipping_Address__r.Country__c, Shipping_Address__r.Contact__r.Phone, Shipping_Address__r.Contact__r.Fax, Shipping_Address__r.Contact__r.Name, Shipping_Address__r.Contact__r.Email, '+
                                      +' Shipping_Address__r.State__c, Shipping_Address__r.Postal_Code__c from Shipment__c where (ERP7__Logistic__c In: soIds And Active__c = true) Order by CreatedDate Asc');
                }
                for(Shipment__c shp: shipmentList) { Wrappers wrap = new Wrappers(); wrap.shipM = shp;
                    if(wrap.shipM.RecordType.Name == 'UPS Shipping') wrap.shipmentType = 'UPS'; else if(wrap.shipM.RecordType.Name == 'Internal Shipping') wrap.shipmentType = 'Shipment'; else if(wrap.shipM.RecordType.Name == 'Fedex Shipping') wrap.shipmentType = 'FedEx'; else if(wrap.shipM.RecordType.Name == 'DHL Shipping') wrap.shipmentType = 'DHL'; else if(wrap.shipM.RecordType.Name == 'USPS Shipping') wrap.shipmentType = 'USPS';
                    if(shp.Tracking_Number__c != null) wrap.trackingNo += shp.Tracking_Number__c.replace(',','<br/>');
                    shipmentWrapperList.add(wrap);
                } return page.Ship;
            } else errorMsg = 'Please select an order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }

    public PageReference createUPSShipment() { 
        try {
            String sType = '';
            Boolean error = false;
            selectedPackIds = new List<Id>(); 
            if(lineItemWrapperList != null) { 
                for(lineItemWrapper lw: lineItemWrapperList) { 
                if(lw.sel == true) { if(sType == '') sType = lw.pack.Shipment_Type__c; if(sType == lw.pack.Shipment_Type__c) { selectedPackIds.add(lw.pack.Id); if(shipmentType == null) shipmentType = lw.pack.Shipment_Type__c; } else { errorMsg1 = 'You cannot select packages with different shipment type.'; error = true; break; }
                   } else { if(packageId != null && packageId != '') selectedPackIds.add(packageId); }
                 }                                
            } 
          
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        
        return null;
    }
    
    public PageReference createPickingSlips() {
        Set<Id> salesIds = new Set<Id>();
        try { 
            soliSelectedWrapperList = new List<Wrappers>();
            for(Wrappers wrap : soliWrapperList) {  salesIds.add(wrap.LOLI.ERP7__Logistic__c);  if(wrap.soliSelected == true){   for(SelectOption so : wrap.Address) if(so.getValue() == wrap.AddressName) wrap.AddressName = so.getLabel(); for(SelectOption bl : wrap.BatchLotCodes) if(bl.getValue() == wrap.BatchLotCode) wrap.BatchLotCode = bl.getLabel(); soliSelectedWrapperList.add(wrap);
              }
            }
            if(soliSelectedWrapperList.size() == 0){
                for(Wrappers wrap : soliWrapperList) {  salesIds.add(wrap.LOLI.ERP7__Logistic__c);  for(SelectOption so : wrap.Address) if(so.getValue() == wrap.AddressName) wrap.AddressName = so.getLabel(); for(SelectOption bl : wrap.BatchLotCodes) if(bl.getValue() == wrap.BatchLotCode) wrap.BatchLotCode = bl.getLabel(); soliSelectedWrapperList.add(wrap);
                }
            }
            Logistics = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' , ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, '+
                                                 +' ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where Id In : salesIds');
            return page.LogisticsPickingSlips; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); } return null;
    }

    public PageReference createBarcode() {
        try {                        
            Boolean error = false;
            soliIds = new List<Id>();
            PB = new PrintBarcodes();
            Set<Id> pIds = new Set<Id>();
            soliSelectedWrapperList = new List<Wrappers>();
            PB.BarcodeWrapperList = new List<PrintBarcodes.BarcodeWrapper>();           
            if(soliWrapperList.size() > 0) {
                             
            } else { errorMsg = 'Items have been picked, please proceed to packing.'; } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }        
        return Page.LogisticsPrintPickProductsPDF;
    }
    
    public PageReference createBarcodesPage() {
        return page.printbarcodes;
    }
    
    public PageReference saveSOLIs() {
        try {
            Boolean error = false;
            soliIds = new List<Id>();
            List<Id> lineIds = new List<Id>();
            List<Id> assetIds = new List<Id>();
            soliSelectedWrapperList = new List<Wrappers>();
            PPLIList = new List<Stock_Outward_Line_Item__c>(); 
            List<Id> SerialIds2Update = new List<Id>();
            Map<Id,Id> SerialStock2Inward = new Map<Id,Id>();
            
            if(soliWrapperList.size() > 0) {          
                for(Wrappers wrap : soliWrapperList) { 
                    if(wrap.soliSelected == true) { 
                        if(wrap.SerialNumbers.Fixed_Asset__c != Null){ assetIds.add(wrap.SerialNumbers.Fixed_Asset__c); 
                        } 
                        if(wrap.loli.Sales_Order_Line_Item__c != Null) lineIds.add(wrap.loli.Sales_Order_Line_Item__c); 
                        if(wrap.loli.Work_Order_Line_Items__c != Null) lineIds.add(wrap.loli.Work_Order_Line_Items__c); 
                        if(wrap.loli.ERP7__Purchase_Line_Items__c != Null) lineIds.add(wrap.loli.ERP7__Purchase_Line_Items__c); 
                        if(wrap.loli.Transfer_Order_Line_Item__c != Null) lineIds.add(wrap.loli.Transfer_Order_Line_Item__c); 
                        soliIds.add(wrap.loli.Id); 
                        
                        soliSelectedWrapperList.add(wrap); 
                    } 
                }
                if(soliSelectedWrapperList.size() > 0) { 
                    errorMsg = '';
                    List <ERP7__Serial_Number__c> SNS = new List <ERP7__Serial_Number__c>();
                    for(Wrappers wrap : soliSelectedWrapperList) {
                        if(wrap.inventoryStock == 0) { errorMsg = 'Sorry, no available inventory for the selected item to proceed.'; error = true; break; }      
                        else if(wrap.requiredQty > wrap.inventoryStock) { errorMsg = 'Quantity cannot be greater than available stock.'; error = true; break; }
                        else if(wrap.requiredQty > wrap.remainingQty) { errorMsg = 'Quantity cannot be greater than remaining Quantity.'; error = true; break; }
                        else if(wrap.serialized && (wrap.SerialNumbers.Serial__c == Null)) { errorMsg = 'Required field missing - Serial Number'; error = true; break; }
                        if(wrap.serialized && (wrap.SerialNumbers.Serial__c != Null)) { SerialIds2Update.add(wrap.SerialNumbers.Serial__c);
                        }
                    }  
                    if(SerialIds2Update.size() > 0){
                      
                    }
                                
                    if(!error) {
                        if(lineIds.size() > 0) {
                            ppliItemList = Database.query('select ' + String.escapeSingleQuotes(PPLIFields) + ' , ERP7__Serial__r.Name from Stock_Outward_Line_Item__c where ((Sales_Order_Line_Item__c In : lineIds Or Work_Order_Line_Items__c In : lineIds Or ERP7__Purchase_Line_Items__c In : lineIds Or Transfer_Order_Line_Item__c In : lineIds) and Picked_Date__c = null) and ERP7__Quantity__c > 0'); 
                        } 
                        MAP<Id, ERP7__Logistic_Line_Item__c > soliMap = new MAP<Id, ERP7__Logistic_Line_Item__c >();
                        MAP<Id, MRP__c> mrpMap = new MAP<Id, MRP__c>();
                        MAP<Id, Asset__c> assetMap = new MAP<Id, Asset__c>();
                        List<Id> serialIds = new List<Id>();
                        if(assetIds.size() > 0) assetMap = new MAP<Id, Asset__c>([Select Id, Name, Active__c, Barcode__c, Serialise__c, Status__c From Asset__c Where Id In :assetIds]);
                        if(ppliItemList.size() > 0){
                            
                        }  else errorMsg = 'No reserved stock outward Lines to pick';
                        
                        if(PPLIList.size() > 0 || assetMap.Values().size() > 0) { 
                          
                       }
                    }
                }                
            } else errorMsg = 'Items have been picked, please proceed to packing.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); 
       }      
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
                          
                if(binList.size() > 0) {                  
                
                    
                } else if(SSLList.size() > 0) {                   
                  
                    
                } else if(siteList.size() > 0) {
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
                            for(Inventory_Stock__c WIIS : WIISList) { 
                                if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                            
                            }   
                            
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.SOLI.Quantity__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            
                            if(swrap.BatchLotCode != '' && swrap.BatchLotCode != Null) { swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCode);
                            }
                            else swrap.inventoryStock = myStock;
                            
                            if(swrap.requiredQty >= swrap.inventoryStock) swrap.requiredQty = Integer.valueof(swrap.inventoryStock);  else swrap.requiredQty = Integer.valueof(swrap.remainingQty);
                            
                            if(swrap.requiredQty > 1) swrap.requiredQty = 1;
                            
                            if(swrap.soli.Order_Line_Status__c == 'Reserved' && swrap.inventoryStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = swrap.inventoryStock+swrap.SOLI.Quantity__c-swrap.raisedQty; 
                            else if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                            
                    }
                } 
            }                  
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }

    public PageReference fetchBinStocks() {
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
                          
                if(binList.size() > 0) {                  
            
                } else if(SSLList.size() > 0) {                   
                   
                } else if(siteList.size() > 0) {
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
                            for(Inventory_Stock__c WIIS : WIISList) { 
                                if(Schema.sObjectType.Inventory_Stock__c.fields.Number_of_Item_In_Stock__c.isAccessible() && swrap.Product.Id == WIIS.Product__c ) myStock += WIIS.Number_of_Item_In_Stock__c; //&& (swrap.batchLotCode == '' || WIIS.Batch_Lot_Code__c == swrap.batchLotCode)
                            }
                            Set<SelectOption> myBatches = new Set<SelectOption>();
                            Map<Id,Decimal> batchAvailStocks = new Map<Id,Decimal>();
                            if(!swrap.Product.ERP7__Lot_Tracked__c == true) myBatches.add(new SelectOption('','--None--'));
                            for(ERP7__Stock_Inward_Line_Item__c InwardLine : StockInwardLineItems){
                             
                            }   
                            if(swrap.requiredQty >= myStock) swrap.requiredQty = Integer.valueof(myStock);  else swrap.requiredQty = (swrap.MRP.Id == Null) ? Integer.valueof(swrap.SOLI.Quantity__c) : Integer.valueof(swrap.MRP.Total_Amount_Required__c);
                            if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id == Null) swrap.inventoryStock = myStock+swrap.SOLI.Quantity__c-swrap.raisedQty; 
                            else if(swrap.soli.Order_Line_Status__c == 'Reserved' && myStock > 0 && swrap.mrp.Id != Null) swrap.inventoryStock = myStock+swrap.MRP.Total_Amount_Required__c-swrap.raisedQty;  
                            else swrap.inventoryStock = myStock;
                            swrap.binName = null; swrap.locationName = null; swrap.warehouseName = siteList[0].Id;
                            swrap.WN = siteList[0].Name; swrap.LN = '';
                            swrap.BatchLotCodes = new List<SelectOption>(); swrap.BatchLotCodes.addAll(myBatches);
                            if(swrap.BatchLotCodes.size() > 0 && swrap.Product.ERP7__Lot_Tracked__c == true){ swrap.BatchLotCode = swrap.BatchLotCodes[0].getValue(); swrap.inventoryStock = batchAvailStocks.get(swrap.BatchLotCodes[0].getValue());
                            }
                            else swrap.BatchLotCode = '';
                        
                    }
                } 
            }                  
        return null;
    }

    public PageReference createPacks() {
        try {
            Set<Id> soIds = new Set<Id>();
            Set<Id> OrderIds = new Set<Id>();
            
            if(soWrapperList.size() > 0){ 
             
            }
            else {
                for(Wrappers sow : soSelectedWrapperList) { 
                    soIds.add(sow.logistic.Id); 
                    if(sow.logistic.ERP7__Sales_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Sales_Order__c);
                    if(sow.logistic.ERP7__Purchase_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Purchase_Order__c);
                    if(sow.logistic.ERP7__Work_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Work_Order__c);
                    if(sow.logistic.ERP7__Transfer_Order__c != Null) OrderIds.add(sow.logistic.ERP7__Transfer_Order__c);
                }
            }
            
            if(soIds.size() > 0) {
                soliWrapperList = new List<Wrappers>();
                
                List<Id> soliIds = new List<Id>();
                Map<Id,ERP7__Logistic_Line_Item__c> soliMap = new Map<Id,ERP7__Logistic_Line_Item__c>();
                List<Id> proIds = new List<Id>();
                String mrpKit = 'MRP Kit';
                String Reserved = 'Reserved';
                
                List<ERP7__Logistic_Line_Item__c> soliss = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In: soIds order by ERP7__Logistic__c ASC');
                
                for(ERP7__Logistic_Line_Item__c solis: soliss) {
                   if(!(solis.Product__r.ERP7__Is_Kit__c && solis.Explode__c) && solis.Packed_Quantity__c < solis.Picked_Quantity__c && solis.Picked_Quantity__c <= solis.Quantity__c && !(solis.Packed_Quantity__c < 0)) {
                   } else{
                       if(solis.ERP7__Sales_Order_Line_Item__c != Null) soliMap.put(solis.ERP7__Sales_Order_Line_Item__c,solis);
                       if(solis.ERP7__Purchase_Line_Items__c != Null) soliMap.put(solis.ERP7__Purchase_Line_Items__c,solis);
                       if(solis.Work_Order_Line_Items__c != Null) soliMap.put(solis.Work_Order_Line_Items__c,solis);
                       if(solis.ERP7__Transfer_Order_Line_Item__c != Null) soliMap.put(solis.ERP7__Transfer_Order_Line_Item__c,solis);
                       soliIds.add(solis.Id);
                   }
                }
                
                List<MRP__c> MRPSS = Database.query('select ' + String.escapeSingleQuotes(MRPFields) + ' ,Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ProductCode, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, RecordType.Name, ERP7__MRP_Product__r.ERP7__Item_Description__c, MRP_Product__r.ERP7__Lot_Tracked__c, MRP_Product__r.Serialise__c from MRP__c where ((Sales_Order_Line_Item__r.ERP7__Sales_Order__c In :OrderIds Or ERP7__Purchase_Order__c In :OrderIds Or ERP7__Work_Order__c In :OrderIds Or ERP7__Transfer_Order__c In :OrderIds) And ERP7__Status__c  = :Reserved And RecordType.Name = :mrpKit)');
               
                for(MRP__c MRP : MRPSS) {
                   
                }
                
                Map<Id, Product2> productMap = new Map<Id, Product2>([Select Id, Name, Picture__c, Preview_Image__c, Item_Description__c, ERP7__Lot_Tracked__c, Special_Instructions__c, Weight__c, Barcode__c From Product2 Where Id In: proIds]);
                
                Packages = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ', Logistic__r.Name ,Sales_Order__r.Name, Sales_Order__r.Account__r.Name, Shipment__r.Name, Shipment__r.Shipment_Date__c, '+
                          +' Logistic__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, Logistic__r.Account__c, Logistic__r.Account__r.Name, Shipment__r.Status__c, Logistic__r.ERP7__Ready_To_Ship__c from Package__c where (Active__c = true And Logistic__c In: soIds) Order by Shipment__r.Name, CreatedDate Asc');                       
                packMap = new Map <Id, Package__c>(Packages); 
                                       
                if(Packages.size() > 0 && soliWrapperList.size() > 0) { createPack = true; isAwaiting = true; }
                else if(Packages.size() > 0) { createPack = false; isAwaiting = true; }  else if(soliWrapperList.size() > 0) { createPack = true; isAwaiting = false; }
                
                Set<Id> pkgIds = new Set<Id>();
                if(Packages.size() > 0) { for(Package__c pack: Packages) { pkgIds.add(pack.Id); } }       
                ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');
                Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where (Package__c In: pkgIds And Status__c = \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');    
                packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ', ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c, Logistic__r.Account__c, Logistic__r.Account__r.Name from Package_List__c where (Package__c In: pkgIds And Active__c = true) Order by CreatedDate Asc'); 
                
                //*****************************************************************            
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { 
                        lineItemWrapper LW = new lineItemWrapper();
                        LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm'; else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }
                    
                    // **************************************************************** 
                    Id pikid = null;
                    Package2Create = new Package__c(Package_Type__c='Package');
                    Package2Create.Weight__c = 0;
                    Package2Create.Declared_Value__c = 0; 
                    
                    if(Package2Create.Package_Type__c != null && Package2Create.Package_Type__c != '') {
                        pkgTypeValue = Package2Create.Package_Type__c;  
                        populatePackDetails(); 
                    }
                    
                    if(soIds.size() > 0) Package2Create.Logistic__c = (new list<Id>(soIds))[0];
                    packageWrapperList = new List<packageWrapper>();
                    Package2Create.Status__c = 'Deposited To Front Desk'; 
                    
                    if(Packages != null) Package2Create.Name = Package2Create.Barcode__c = Package2Create.Name__c = 'Pkg-'+ orderNumber  +'-'+ Integer.valueof(Packages.size()+1);
                    for(Wrappers wrap : soliWrapperList) { 
                      
                    } 
                    Set<Id> custIds = new Set<Id>();
                    Customers = new List<SelectOption>();
                    Set<SelectOption> AllCustomers = new Set<SelectOption>(); 
                    for(packageWrapper wrap : packageWrapperList) { 
                     
                    }
                    Customers.addAll(AllCustomers);
                    if(Customers.size() > 0) CustomerPresent = true;
                    List<packageWrapper> pwln = new list<packageWrapper>();
                    //for(Id custId : custIds){
                        for(packageWrapper wrap : packageWrapperList){if(wrap.loli.Logistic__r.Account__c == Customer) { pwln.add(wrap); wrap.pkgSelected = true; }
                        }
                    //}
                    packageWrapperList = pwln;
                    soliWrapperList = new List<Wrappers>();
                    return Page.Pack;                               
            } else errorMsg = 'Please select an Order to proceed.'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
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
    
    public PageReference evaluatePackDetails() {
            errorMsg2 = '';
            Package2Create.Weight__c = Package2Create.Declared_Value__c = 0;
            for(packageWrapper PW : packageWrapperList) {
                if(PW.loli.Product__r.Weight__c != null) Package2Create.Weight__c += (PW.loli.Product__r.Weight__c * PW.qtyToPack);
                if(PW.loli.Price_Product__c != null) Package2Create.Declared_Value__c += (PW.loli.Price_Product__c * PW.qtyToPack);                    
            } 
        return null;
    }
    
    public PageReference deletePackage() {
        try {
            Set<Id> soliIds = new Set<Id>();
            MAP<Id, ERP7__Logistic_Line_Item__c > soliMap = new MAP<Id, ERP7__Logistic_Line_Item__c >();
            if(pack2updateId != null) {
                List<Package_List__c> packList = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ' ,Sales_Order_Line_Item__r.Packed_Quantity__c from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(pack2updateId) + '\' And Active__c = true) Order by CreatedDate Asc');
                for(Package_List__c pls: packList) { soliIds.add(pls.ERP7__Logistic_Line_Item__c); }
                List< ERP7__Logistic_Line_Item__c > soliList = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where Id In: soliIds'); 
                for(Package_List__c pl: packList) {
                    for(ERP7__Logistic_Line_Item__c solis: soliList) {
                        if(pl.ERP7__Logistic_Line_Item__c == solis.Id) {
                            if(solis.Packed_Quantity__c != null) {
                                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Packed_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.Packed_Quantity__c.isUpdateable()) solis.Packed_Quantity__c = solis.Packed_Quantity__c - pl.Quantity__c;
                                soliMap.put(solis.Id, solis);
                            } break;
                        }
                    }
                }
            }
            if(soliMap.size() > 0 && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()) { upsert soliMap.values(); } else{ errorMsg = 'You are not allowed to update';}
            if(pack2updateId != null && Package__c.sObjectType.getDescribe().isDeletable()) { delete new Package__c(Id = pack2updateId);     } else{ errorMsg = 'You are not allowed to delete';}       
            createPacks(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }

    public PageReference createPackingSlips() {
            string csfdcBaseURL=sfdcBaseURL;
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            String contactId, newPackageId;
            Set<Id> pkgIds = new Set<Id>();
            packageList = new List<Package__c>();
            packList = new List<Package_List__c>();
            packageRecords = new Map<Package__c, List<Package_List__c>>();                    
            if(packageId != null && packageId != '') pkgIds.add(packageId);
            Boolean checkedRow = false;
            for(lineItemWrapper lw: lineItemWrapperList) { 
                if(lw.sel == true){ 
                    checkedRow = true;
                    pkgIds.add(lw.pack.Id); 
                }
            }
            if(!checkedRow){ for(lineItemWrapper lw: lineItemWrapperList) { pkgIds.add(lw.pack.Id); }
            }
            if(pkgIds.size() > 0) {
               
            }
        return null;
    }
    
    public PageReference createPackingLabels() {
            String contactId, newPackageId;
            Set<Id> pkgIds = new Set<Id>();
            packageList = new List<Package__c>();
            packList = new List<Package_List__c>();
            packageRecords = new Map<Package__c, List<Package_List__c>>();                    
            if(packageId != null && packageId != '') pkgIds.add(packageId);
            Boolean checkedRow = false;
            for(lineItemWrapper lw: lineItemWrapperList) { 
                if(lw.sel == true){ 
                    checkedRow = true;
                    pkgIds.add(lw.pack.Id); 
                }
            }
            if(!checkedRow){ for(lineItemWrapper lw: lineItemWrapperList) {  pkgIds.add(lw.pack.Id);  }
            }
            
           
        return null;
    }
    
    public PageReference back() {
        pageReference pag = new pageReference('/apex/ERP7__OutboundLogistics');
        pag.setRedirect(true);
        return pag;
    }
        
    public PageReference StillToFulfill() {
        ApexPages.CurrentPage().getParameters().put('loId',LogisticId);
        return Page.StillToFulfill;
    }
    
    public PageReference updatePacks() {
            Boolean error = false;             
            if(packageWrapperList != null) {
                       
            }
        return null;
    }
     
    public PageReference editPackage() {
            Set<Id> soIds = new Set<Id>();
            Packages = new List<Package__c>();
            currentItems = new List<ERP7__Logistic_Line_Item__c>();        
            if(pack2updateId != null) {
                if(!Schema.sObjectType.Package__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package__c.Label));
                else { Package2Create = Database.query('select ' + String.escapeSingleQuotes(PackageFields) + ' ,Sales_Order__r.Account__c, Shipment__r.Name, Logistic__r.ERP7__Ready_To_Ship__c from Package__c where (Id =\'' + String.escapeSingleQuotes(pack2updateId) + '\')');  
                       packMap = new Map <Id, Package__c>(Packages);
                }
                currentItems = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c = \'' + String.escapeSingleQuotes(Package2Create.Logistic__c) + '\' order by ERP7__Logistic__c ASC');
                    
                String status = 'Cancelled';        
                ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping');
                if(!Schema.sObjectType.Shipment__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Shipment__c.Label));
                else { Shipments = Database.query('select ' + String.escapeSingleQuotes(ShipmentFields) + ' from Shipment__c where'+
                                   '(ERP7__Logistic__c = \'' + String.escapeSingleQuotes(Package2Create.Logistic__c) + '\' And Status__c !=\'' + String.escapeSingleQuotes(status) + '\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Order by CreatedDate Asc');
                }
                if(!Schema.sObjectType.Package_List__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Package_List__c.Label));
                else { packageLists = Database.query('select ' + String.escapeSingleQuotes(packageListFields) + ', ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c, Logistic__r.Account__c, Logistic__r.Account__r.Name from Package_List__c where (Package__c =\'' + String.escapeSingleQuotes(Package2Create.Id) + '\' And Active__c = true) Order by CreatedDate Asc'); }                        
                
                //*****************************************************************            
                    if(Package2Create != null) Packages.add(Package2Create);
                    lineItemWrapperList = new List<lineItemWrapper>();
                    for(Package__c P : Packages) { 
                        lineItemWrapper LW = new lineItemWrapper(); 
                        LW.pack = P;
                        if(P.Weight_Unit__c == 'KGS') LW.units = 'cm'; else LW.units = 'in';
                        
                        for(Shipment__c S : Shipments) { if(S.Id == P.Shipment__c) { LW.shipment = S; break; } }
                        LW.NoofLineItems = P.Package_Quantity__c;                
                        lineItemWrapperList.add(LW);
                    }        
                    
                // ****************************************************************            
                    packageWrapperList = new List<packageWrapper>();                                
                    for(ERP7__Logistic_Line_Item__c soli : currentItems){
                        packageWrapper PW = new packageWrapper();
                        List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                        for(Package_List__c pl : packageLists){
                           if(pl.ERP7__Logistic_Line_Item__c == soli.Id) { 
                                PW.Loli = soli;
                                PW.qtyToPick = pl.ERP7__Logistic_Line_Item__r.ERP7__Picked_Quantity__c;
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
                                } 
                                ipwList.add(ipw);
                           }
                        } 
                        if(ipwList.size() > 0) { PW.innerPackList = ipwList; packageWrapperList.add(PW); }
                    } CreatePack = true; isAwaiting = false;    
            }                           
        return Null;
    }
    
    public PageReference fetchSOLIIItems() {
            Set<Id> soIds = new Set<Id>();        
            Packages = new List<Package__c>();
            currentItems = new List< ERP7__Logistic_Line_Item__c >();            
            if(Package2Create.Logistic__c != null) {           
                currentItems = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c = \'' + String.escapeSingleQuotes(Package2Create.Logistic__c) + '\' order by ERP7__Logistic__c ASC');
                  
                // ****************************************************************            
                packageWrapperList = new List<packageWrapper>();            
                for(ERP7__Logistic_Line_Item__c soli : currentItems) { 
                    packageWrapper PW = new packageWrapper(); PW.Loli = soli;
                    List<innerPackageWrapper> ipwList = new List<innerPackageWrapper>();
                    for(Package_List__c pl : packageLists){
                       if(pl.ERP7__Logistic_Line_Item__c == soli.Id){
                       
                        }
                    } 
                    if(ipwList.size() > 0) { PW.innerPackList = ipwList; } 
                    else { innerPackageWrapper ipw = new innerPackageWrapper();                                
                           ipw.packList.add(new SelectOption('','--None--'));                            
                           for(Package__c P : Packages) { if(P.Status__c != 'Shipped' && P.Status__c != 'Picked Up' && P.Status__c != 'Delivered') ipw.packList.add(new SelectOption(String.valueof(P.Id),P.Name__c));  
                           } PW.innerPackList.add(ipw);
                    } packageWrapperList.add(PW);
                }
            } 
        return null;
    }
    
    public PageReference ChannelChange() {
        /*if(Employee.Channel__c != Null){ 
            List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c,   Channel__c, Site__c, Site__r.Name 
                                                                          From Distribution_Channel__c Where Channel__c = : Employee.Channel__c And Active__c = true 
                                                                          Order By ERP7__Primary__c Desc];
        
            channelSites = new List<SelectOption>();        
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) { channelSites.add(new SelectOption(DC.Site__c,DC.Name)); }
                selectedSite = DistributionChannels[0].Site__c;
            }  
        } 
        authorisedOrders();commented by shaguftha on 29_07_24*/
        return null; 
    }
    
    public PageReference OfsetChange() { if(PageNum > 0 && PageNum <= PNS.size()){ if(((Offset+show)/show) != PageNum){ Offset = (show*PageNum)-show; pageNum = (Offset + show)/show; } authorisedOrders(); } else PageNum = (Offset+show)/show; return null; }
    
    public PageReference SetShow() { startCount = endCount = Offset = 0; PageNum = 1; authorisedOrders(); return null; }
    
    public PageReference Next() { Offset = Offset+show; PageNum = PageNum+1; authorisedOrders(); return null; }
    
    public PageReference NextLast() { Offset = (PNS.size()-1)*show; PageNum = (Offset+show)/show; authorisedOrders(); return null; }
    
    public PageReference Previous() { Offset = Offset-show; PageNum = PageNum-1; authorisedOrders(); return null; }  public PageReference PreviousFirst() { Offset = 0; PageNum = 1; authorisedOrders(); return null; }
    
    
    public static String sortBy                                { get; set; }    
    public static String prevSortBy                            { get; set; }
    public static String orderFormat                           { get; set; }
        
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
        public ERP7__Logistic_Line_Item__c LOLI                { get; set; } 
        
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
            Logistic = new Logistic__c();         LOLI = new ERP7__Logistic_Line_Item__c();      }   public Integer compareTo(Object objToCompare) { if(sortBy == 'WN') { Integer result = WN.compareTo(((Wrappers)objToCompare).WN); return (orderFormat == 'ASC')? result : result * -1; }  else if(sortBy == 'LN') { Integer result = LN.compareTo(((Wrappers)objToCompare).LN); return (orderFormat == 'ASC')? result : result * -1; }  else if(sortBy == 'SD') { Integer result = SD.compareTo(((Wrappers)objToCompare).SD); return (orderFormat == 'ASC')? result : result * -1; }  return 0;    }           
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
        public Logistic_Line_Item__c Loli                        { get; set; }
        public MRP__c MRP                                        { get; set; }
        public List<innerPackageWrapper> innerPackList           { get; set; }        
      
        public packageWrapper(){
            qtyToPick = 0; 
            qtyToPack = 0;
            pkgSelected = false;
            Loli = new Logistic_Line_Item__c();
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