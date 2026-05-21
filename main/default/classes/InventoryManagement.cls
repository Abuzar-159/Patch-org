public With Sharing Class InventoryManagement {
    public String poId                                                                                          { get; set; }
    public List<String> poIds                                                                                   { get; set; }
    public PO__c PO                                                                                             { get; set; }
    public List<Purchase_Line_Items__c> Polis                                                                   { get; set; }
    public List<PLIWrapper> PLIWrapperList                                                                      { get; set; }
    
    public String soId                                                                                          { get; set; }
    public List<String> soIds                                                                                   { get; set; }
    public Sales_Order__c  SO                                                                                   { get; set; }
    public List<RMA_Line_Item__c > ROLIs                                                                        { get; set; }
    public List<RMALIWrapper> RMALIWrapperList                                                                  { get; set; }
    
    public String woId                                                                                          { get; set; }
    public List<String> woIds                                                                                   { get; set; }
    public WO__c WO                                                                                             { get; set; }
    public List<Work_Order_Line_Items__c> Wolis                                                                 { get; set; }
    public List<WOLIWrapper> WOLIWrapperList                                                                    { get; set; }
    
    public String toId                                                                                          { get; set; }
    public List<String> toIds                                                                                   { get; set; }
    public Transfer_Order__c TO                                                                                 { get; set; }
    public List<Transfer_Order_Line_Items__c> Tolis                                                             { get; set; }
    public List<TOLIWrapper> TOLIWrapperList                                                                    { get; set; }
    
    public Map<Inventory_Stock__c, List<Stock_Inward_Line_Item__c>> stockLines                                  { get; set; }
    public List<Stock_Inward_Line_Item__c> SPLIS2Delete                                                         { get; set; }
    public List<Inventory_Stock__c> stocks2Delete                                                               { get; set; }
    public List<Stock_Inward_Line_Item__c> SPLIS                                                                { get; set; } 
    public List<Inventory_Stock__c> warehouseStocks                                                             { get; set; }
    public List<Site__c> Sites                                                                                  { get; set; }
    public Integer counter                                                                                      { get; set; }
    public Integer subcounter                                                                                   { get; set; }
    public Integer lastcounter                                                                                  { get; set; }
    public static Map<String, Schema.SObjectType> schemaMap;
    public Map<String, Decimal> lineItemprocessedQuantities                                                     { get; set; }
    public String ErrMsg                                                                                        { get; set; }
    public String barcode                                                                                       { get; set; }
    public Integer collapseCounter                                                                              { get; set; }
    public Boolean itemFoundOnScan                                                                              { get; set; }
    public List<Stock_Outward_Line_Item__c> PPLIs2Update                                                        { get; set; }
    public StockWrapper randonScannedStock                                                                      { get; set; }
    public StockWrapperNew randonScannedStockNew                                                                { get; set; }
    public Boolean selectAll                                                                                    { get; set; }
    public String DisMsg                                                                                        { get; set; }
    public String channelId                                                                                     { get; set; }
    public String channelName                                                                                   { get; set; }
    public Employees__c Employee                                                                                { get; set; }
    public List<SelectOption> channelSites                                                                      { get; set; }
    public Id selectedSite                                                                                      { get; set; }
    public Id putawayId                                                                                         { get; set; }
    public Attachment universalAttachment                                                                       { get; set; }
    public Id PreparePushAttachmentId                                                                           { get; set; } 
    public List< ERP7__MRP__c > MRPS                                                                            { get; set; } 
    public Map<Id,Serial_Number__c> SerialMap                                                                   { get; set; }
    public Map<Id,String> orderNames                                                                              { get; set; }
    
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    
    public InventoryManagement() { }
    public InventoryManagement(ApexPages.StandardController controller) {
        schemaMap = Schema.getglobalDescribe();
        orderNames = new Map<Id,String>();
        poId = ApexPages.currentPage().getParameters().get('poid');
        woId = ApexPages.currentPage().getParameters().get('woId');
        soId = ApexPages.currentPage().getParameters().get('soId');
        toId = ApexPages.currentPage().getParameters().get('toId');
        channelId = ApexPages.currentPage().getParameters().get('channel');
        universalAttachment = new Attachment();
        SerialMap  = new Map<Id,Serial_Number__c>();
        ErrMsg = '';
        DisMsg = '';
        PPLIs2Update = new List<Stock_Outward_Line_Item__c>();
        Employee = new Employees__c();
        List<Employees__c> empList = new List<Employees__c>();
        empList = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                         Organisation_Business_Unit__c
                         From Employees__c
                         Where Employee_User__c = : UserInfo.getUserId()
                         Order by CreatedDate Asc Limit 1];
        if(empList.size() > 0) Employee = empList[0]; 
        Employee.Channel__c = Null;                 
        if(channelId != Null && channelId != '' && channelId != 'null') Employee.Channel__c = channelId;
        
        List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c,  Channel__c, Site__c, Site__r.Name
                                                                        From Distribution_Channel__c
                                                                        Where Channel__c = : channelId And Active__c = true
                                                                        Order By ERP7__Primary__c Desc];
        channelSites = new List<SelectOption>();        
        if(DistributionChannels.size() > 0) {
            for(Distribution_Channel__c DC: DistributionChannels) {channelSites.add(new SelectOption(DC.Site__c,DC.Site__r.Name));
            }
        }
                 
        if(poId != Null && poId != ''){
            poids = poId.split(',');
            SupplierInventoryCustomContructor();
        }
        if(woId != Null && woId != ''){woids = woId.split(',');
            ManufacturingInventoryCustomContructor();
        }
        if(soId != Null && soId != ''){soids = soId.split(',');
            RMAInventoryCustomContructor();
        }
        if(toId != Null && toId != ''){toids = toId.split(',');
            TransferOrderInventoryCustomContructor();
        }
    }
    
    
    ////////////// Transfer Order Inventory ///////////////////////
    
    public Void TransferOrderInventoryCustomContructor(){
        schemaMap = Schema.getglobalDescribe();
        TOLIWrapperList = new List<TOLIWrapper>();
        SPLIS2Delete = new List<Stock_Inward_Line_Item__c>();
        stocks2Delete = new List<Inventory_Stock__c>();
        lineItemprocessedQuantities = new Map<String, Decimal>();
        
        String allFields = fetchAllFields('ERP7__Transfer_Order__c');
        UtilClass.FlSCheck(allFields.split(',') ,'ERP7__Transfer_Order__c');
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Transfer_Order__c where Id in: toIds';
        List<ERP7__Transfer_Order__c> TOs = Database.query(query);
        
        orderNames = new Map<Id,String>();
        if(TOs != null && TOs.size() > 0) TO = TOs[0];
        for(ERP7__Transfer_Order__c TO : TOs){ 
            orderNames.put(TO.Id, TO.Name);
        }
        
        String allFields1 = fetchAllFields('ERP7__Transfer_Order_Line_Items__c');
        UtilClass.FlSCheck(allFields1.split(',') ,'ERP7__Transfer_Order_Line_Items__c');
        allFields1 += ', Transfer_Order__r.Name, Products__r.Name'+', Products__r.Picture__c'+', Products__r.Preview_Image__c, Products__r.ERP7__Is_Kit__c, Products__r.ERP7__Kit_Protected__c, Products__r.Lot_Tracked__c, Products__r.Serialise__c ';
        String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Transfer_Order_Line_Items__c where Transfer_Order__c in : toIds And Products__c != Null order by CreatedDate ASC';
        Tolis = Database.query(query1);
        
        List<String> productIds = new List<String>();
        List<String> TLIIds = new List<String>();
        for(Transfer_Order_Line_Items__c toli : Tolis){
          if(Schema.sobjectType.ERP7__Transfer_Order_Line_Items__c.fields.Products__c.isAccessible())  if(toli.Products__c != Null) productIds.add(toli.Products__c);
            TLIIds.add(toli.Id);
        }
        MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Serialise__c, ERP7__MRP_Product__r.Lot_Tracked__c, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, ERP7__Purchase_Line_Items__c, ERP7__Transfer_Order_Line_Item__c,  RecordType.Name From ERP7__MRP__c Where ERP7__Transfer_Order_Line_Item__c In :TLIIds And RecordType.Name = 'MRP Kit'];
        
        String allFields3 = fetchAllFields('ERP7__Stock_Inward_Line_Item__c');
        UtilClass.FlSCheck(allFields1.split(',') ,'ERP7__Stock_Inward_Line_Item__c');
        String query3 = 'select ' + String.escapeSingleQuotes(allFields3) + ' from ERP7__Stock_Inward_Line_Item__c where Transfer_Order_Line_Item__c In :TLIIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isAccessible()) SPLIS = Database.query(query3);
        for(Transfer_Order_Line_Items__c toli : Tolis){
            Decimal quantityProcessed = 0;
            if(toli.Explode__c != true){
                for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                    if(SPLI.Transfer_Order_Line_Item__c == toli.Id && SPLI.Quantity__c != Null && toli.Products__c == SPLI.Product__c){
                     if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())   quantityProcessed += SPLI.Quantity__c;
                    }
                }
            } lineItemprocessedQuantities.put(toli.Id, quantityProcessed);
        }
        
        List<Id> stockIds = new List<Id>();
        List<Id> serialIds = new List<Id>();
        for(Stock_Inward_Line_Item__c SPLI : SPLIS){
            if(SPLI.Sales_Order_Line_Item__c == Null)  stockIds.add(SPLI.Site_ProductService_InventoryStock__c);
            if(SPLI.Serial__c != Null)  serialIds.add(SPLI.Serial__c);
        }
        SerialMap = new Map<Id,Serial_Number__c>([Select Id, Name, Serial_Number__c, Product__c from Serial_Number__c Where Id In :serialIds]);
        
        String allFields2 = fetchAllFields('ERP7__Inventory_Stock__c');
        UtilClass.FlSCheck(allFields2.split(',') ,'ERP7__Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name';
        String query2 = 'select ' + String.escapeSingleQuotes(allFields2) + ' from ERP7__Inventory_Stock__c where Id In :stockIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.isAccessible()) warehouseStocks = Database.query(query2);
        String allFields4 = fetchAllFields('ERP7__Site__c');
        UtilClass.FlSCheck(allFields2.split(',') ,'ERP7__Site__c');
        String query4 = 'select ' + String.escapeSingleQuotes(allFields4) + ' from ERP7__Site__c where Active__c = true order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Site__c.isAccessible()) Sites = Database.query(query4);
        stockLines = new Map<Inventory_Stock__c, List<Stock_Inward_Line_Item__c>>();
        for(Inventory_Stock__c WIIS : warehouseStocks){
            List<Stock_Inward_Line_Item__c> mySPLIS = new List<Stock_Inward_Line_Item__c>();
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                if(WIIS.Id == SPLI.Site_ProductService_InventoryStock__c && SPLI.Sales_Order_Line_Item__c == Null){
                    mySPLIS.add(SPLI);
                    break;
                }
            } stockLines.put(WIIS, mySPLIS);
        }
        List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Tolis Order By CreatedDate Asc];
        Map<Id,Attachment> TOLIAttachment = new Map<Id,Attachment>();
        for(Attachment A : Attachments) TOLIAttachment.put(A.ParentId,A);
        
        for(Transfer_Order_Line_Items__c toli : Tolis){
            ToliWrapper ToliWrap = new ToliWrapper(Toli);
            TOLIWrap.attach = (TOLIAttachment.ContainsKey(toli.Id))? TOLIAttachment.get(toli.Id) : new Attachment();
            ToliWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(Toli.Id);
            ToliWrap.Incount  = 0;
            for(Inventory_Stock__c WIIS : warehouseStocks){
                if(toli.Products__c == WIIS.Product__c){
                    
                    for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                        if(toli.Id == SPLI.ERP7__Transfer_Order_Line_Item__c){
                            StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS));
                            stockWrap.SP.Site__c = WIIS.Warehouse__c;
                            if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) ToliWrap.Incount += SPLI.Quantity__c;
                            if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                            ToliWrap.StockWrapperList.add(stockWrap);
                        }
                    }
                }
            }
            ToliWrapperList.add(ToliWrap);
        }
    }
   
    public PageReference AddTransferStock(){
       
        TOLIWrapper TOLIWrap = TOLIWrapperList.get(counter);
        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        if(TOLIWrap.TOLI.Products__r.Serialise__c != true)  spliTemp.Quantity__c = (TOLIWrap.TOLI.Quantity_requested__c != Null && TOLIWrap.lineItemprocessedQuantity != Null)? TOLIWrap.TOLI.Quantity_requested__c-TOLIWrap.lineItemprocessedQuantity : 0;
        if(TOLIWrap.TOLI.Products__r.Serialise__c == true) spliTemp.Quantity__c = 1;
        tspli.add(spliTemp);
        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = TOLIWrap.TOLI.Products__c, Name=TOLIWrap.TOLI.Name,Checked_In_Date__c=system.today()), tspli);
        if(TOLIWrap.TOLI.Products__r.Serialise__c == true){
            SW.SerialNumber.Serial_Number__c = (TOLIWrap.TOLI.Starting_Number__c != Null)? TOLIWrap.TOLI.Serial_Number_Prefix__c+String.valueof(TOLIWrap.TOLI.Starting_Number__c+TOLIWrap.StockWrapperList.size()) : TOLIWrap.TOLI.Serial_Number_Prefix__c;
            SW.SerialNumber.Product__c = TOLIWrap.TOLI.Products__c;
        }
        TOLIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference RemoveTransferStock(){
        StockWrapper SW = (lastcounter != Null)? TOLIWrapperList.get(lastcounter).BOMS.get(counter).StockWrapperList.remove(subcounter) : TOLIWrapperList.get(counter).StockWrapperList.remove(subcounter);
        if(SW.stock.Id != Null) stocks2Delete.add(SW.stock);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
   
    
    public PageReference cancelTo(){
        String sr = ApexPages.currentPage().getParameters().get('sr');
        PageReference Page;
        if(sr != '' && sr != null) Page = new PageReference('/apex/ERP7__StockReceiving');
        else Page = new PageReference('/'+TO.Id);
        Page.setRedirect(true);
        return Page;
    }
    
    public PageReference SaveTOLines(){
        try{
            List<Transfer_Order_Line_Items__c> TOLIS2Upsert = new List<Transfer_Order_Line_Items__c>();                   
            List<Inventory_Stock__c> Stocks2Upsert = new List<Inventory_Stock__c>();                    
            List<Stock_Inward_Line_Item__c> SPLIS2Upsert = new List<Stock_Inward_Line_Item__c>();
            List<Serial_Number__c> Serials2Upsert = new List<Serial_Number__c>();   
            Boolean Error = false;
            
            // Required Validations
            for(TOLIWrapper TOLIW : TOLIWrapperList){
                if(TOLIW.TOLI.Explode__c != true){ //Product__r.ERP7__Is_Kit__c
                    for(StockWrapper WIIS : TOLIW.StockWrapperList){WIIS.SP.Site__c = selectedSite;
                        WIIS.SP.Site__c = selectedSite;
                        if(WIIS.stock.Name == '' || WIIS.stock.Name == Null || WIIS.SP.Site__c == Null || (TOLIW.TOLI.Products__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                            Error = true; TOLIW.errMsg = 'Please fill the fields marked as *';
                            }
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(SPL.Quantity__c == Null || (TOLIW.TOLI.Products__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                                Error = true; TOLIW.errMsg = 'Please fill the fields marked as *';
                             }
                        }
                    }
                } else {
                    for(TOLIWrapper TOLI_IN : TOLIW.BOMS){
                        for(StockWrapper WIIS : TOLI_IN.StockWrapperList){
                            WIIS.SP.Site__c = selectedSite;
                            if(WIIS.stock.Name == '' || WIIS.stock.Name == Null || WIIS.SP.Site__c == Null || (TOLI_IN.MRP.ERP7__MRP_Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                                /* *** IN ERR_IN SL.NO'+WIIS.SerialNumber.Serial_Number__c+'  '+TOLI_IN.MRP.ERP7__MRP_Product__r.Serialise__c); */
                                Error = true; TOLIW.errMsg = 'Please fill the fields marked as *';
                            }
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(SPL.Quantity__c == Null || (TOLI_IN.MRP.ERP7__MRP_Product__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                                    
                                    Error = true; TOLIW.errMsg = 'Please fill the fields marked as *';
                                }
                            }
                        }
                    }
                }
            }
            if(Error) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            
            // Calculation Validations
            Boolean isOkmainWrapper = true;
            for(TOLIWrapper TOLIW : TOLIWrapperList){
                if(TOLIW.TOLI.Explode__c != true){
                    if(!(TOLIW.toli.Quantity_requested__c > 0)){
                        Error = true; TOLIW.errMsg = 'Quantity Unavailable'; isOkmainWrapper = false;
                    }
                } else{
                    for(TOLIWrapper TOLI_IN : TOLIW.BOMS){
                        if(!(TOLI_IN.toli.Quantity_requested__c > 0)){
                            Error = true; TOLI_IN.errMsg = 'Quantity Unavailable'; isOkmainWrapper = false;
                        }
                    }
                }
            }
            if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            for(TOLIWrapper TOLIW : TOLIWrapperList){
                if(TOLIW.TOLI.Explode__c != true){
                    Decimal subQuantity = 0; 
                    for(StockWrapper WIIS : TOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subQuantity += SPL.Quantity__c;
                        }
                    }
                    if((TOLIW.lineItemprocessedQuantity - TOLIW.Incount + subQuantity) > TOLIW.toli.Quantity_requested__c){
                        Error = true; TOLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(TOLIW.toli.Quantity_requested__c - (TOLIW.lineItemprocessedQuantity - TOLIW.Incount));
                    }
                } else{ 
                    for(TOLIWrapper TOLI_IN : TOLIW.BOMS){
                        Decimal subQuantity = 0; 
                        for(StockWrapper WIIS : TOLI_IN.StockWrapperList){
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                subQuantity += SPL.Quantity__c;
                            }
                        }
                        if((TOLI_IN.lineItemprocessedQuantity - TOLI_IN.Incount + subQuantity) > (TOLI_IN.toli.Quantity_requested__c * TOLI_IN.mrp.ERP7__Total_Amount_Required__c)){
                            Error = true; TOLI_IN.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to : '+String.valueof(TOLI_IN.toli.Quantity_requested__c)+' : '+String.valueof(TOLI_IN.lineItemprocessedQuantity)+' : '+String.valueof(TOLI_IN.Incount)+' : '+String.valueof(TOLI_IN.toli.Quantity_requested__c - (TOLI_IN.lineItemprocessedQuantity - TOLI_IN.Incount));
                        }
                    }
                } 
            }
            
            // Successful Processing
            if(!Error){
                for(TOLIWrapper TOLIW : TOLIWrapperList){
                    TOLIS2Upsert.add(TOLIW.TOLI);
                    if(TOLIW.TOLI.Explode__c != true){
                        TOLIW.errMsg = '';
                        for(StockWrapper WIIS : TOLIW.StockWrapperList){
                            if(Schema.sobjectType.Inventory_Stock__c.fields.Warehouse__c.isAccessible()) WIIS.Stock.Warehouse__c = WIIS.SP.Site__c; 
                            Stocks2Upsert.add(WIIS.Stock);
                            if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                Serials2Upsert.add(WIIS.SerialNumber);
                            }
                        }
                    } else{  
                        for(TOLIWrapper TOLI_IN : TOLIW.BOMS){TOLIW.errMsg = '';
                            for(StockWrapper WIIS : TOLI_IN.StockWrapperList){
                                if(Schema.sobjectType.Inventory_Stock__c.fields.Warehouse__c.isAccessible()) WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                                Stocks2Upsert.add(WIIS.Stock);
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                    WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                    Serials2Upsert.add(WIIS.SerialNumber);
                                }
                            } 
                        }
                    }
                }
                //DMLManager.upsertAsUser(WO);
                if(Serials2Upsert.size() > 0 && Schema.sObjectType.Serial_Number__c.isCreateable() && Schema.sObjectType.Serial_Number__c.isUpdateable()) DMLManager.upsertAsUser(Serials2Upsert); else{ }
                if(TOLIS2Upsert.size() > 0 && Schema.sObjectType.Transfer_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Transfer_Order_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(TOLIS2Upsert); else{ }
                if(Stocks2Upsert.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isCreateable() && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) DMLManager.upsertAsUser(Stocks2Upsert); else{ }
                if(SPLIS2Delete.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isDeletable()) DMLManager.deleteAsUser(SPLIS2Delete); else{ }
                if(stocks2Delete.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isDeletable()) DMLManager.deleteAsUser(stocks2Delete); else{ }
                
                /*
                List<String> batchLots = new List<String>();
                for(TOLIWrapper TOLIW : TOLIWrapperList){
                    Decimal subquant = 0;
                    for(StockWrapper WIIS : TOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Batch_Lot_Code__c.isAccessible()) if(SPL.Batch_Lot_Code__c != Null && SPL.Batch_Lot_Code__c != '') batchLots.add(SPL.Batch_Lot_Code__c);
                        }
                    }
                }
                batchLots.add('');
                */
                //startitfromhere
                for(TOLIWrapper TOLIW : TOLIWrapperList){
                    if(TOLIW.TOLI.Explode__c != true){
                        
                        Decimal subquant = 0;
                        for(StockWrapper WIIS : TOLIW.StockWrapperList){
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                                if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Products__c.isAccessible())SPL.Product__c = TOLIW.TOLI.Products__c;
                                if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible())SPL.Transfer_Order_Line_Item__c = TOLIW.TOLI.Id;
                                if(Schema.sobjectType.ERP7__Transfer_Order_Line_Items__c.fields.Transfer_Order__c.isAccessible()) SPL.Transfer_Order__c = TOLIW.TOLI.Transfer_Order__c;
                                //if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Quantity__c.isAccessible())SPL.Unit_Price__c = (TOLIW.TOLI.Total_Cost__c >= 0 && TOLIW.toli.Quantity_requested__c > 0)? TOLIW.TOLI.Total_Cost__c/TOLIW.toli.Quantity_requested__c : 0;
                                //if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Total_Cost__c.isAccessible())SPL.Amount__c = TOLIW.TOLI.Total_Cost__c;
                                //if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.BoM__c.isAccessible())SPL.BoM__c = TOLIW.TOLI.BoM__c;
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') SPL.Serial__c = WIIS.SerialNumber.Id;
                                SPLIS2Upsert.add(SPL); if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())  subquant += SPL.Quantity__c;
                            }
                        }
                        TOLIW.lineItemprocessedQuantity = TOLIW.lineItemprocessedQuantity - TOLIW.Incount + subquant;
                        TOLIW.Incount = subquant;
                    } else{ for(TOLIWrapper TOLI_IN : TOLIW.BOMS){
                            
                            Decimal subquant = 0;
                            for(StockWrapper WIIS : TOLI_IN.StockWrapperList){
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                                    if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Products__c.isAccessible())SPL.Product__c = TOLI_IN.MRP.ERP7__MRP_Product__c;
                                    if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                    if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible())SPL.Transfer_Order_Line_Item__c = TOLIW.TOLI.Id;
                                    if(Schema.sobjectType.ERP7__Transfer_Order_Line_Items__c.fields.Transfer_Order__c.isAccessible()) SPL.Transfer_Order__c = TOLIW.TOLI.Transfer_Order__c;
                                    //if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Quantity__c.isAccessible())SPL.Unit_Price__c = (TOLIW.TOLI.Total_Cost__c >= 0 && TOLIW.toli.Quantity_requested__c > 0)? TOLIW.TOLI.Total_Cost__c/TOLIW.toli.Quantity_requested__c : 0;
                                    //if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.Total_Cost__c.isAccessible())SPL.Amount__c = TOLIW.TOLI.Total_Cost__c;
                                    //if(Schema.sObjectType.Transfer_Order_Line_Items__c.fields.BoM__c.isAccessible())SPL.BoM__c = TOLIW.TOLI.BoM__c;
                                    if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') SPL.Serial__c = WIIS.SerialNumber.Id;
                                    SPLIS2Upsert.add(SPL); if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())  subquant += SPL.Quantity__c;
                                }
                            }TOLI_IN.lineItemprocessedQuantity = TOLI_IN.lineItemprocessedQuantity - TOLI_IN.Incount + subquant; TOLI_IN.Incount = subquant;
                        }
                    }
                }
                /* *** SPLIS : '+SPLIS2Upsert);*/
                if(SPLIS2Upsert.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.isUpdateable()) DMLManager.upsertAsUser(SPLIS2Upsert); else{ }
                ErrMsg = '';
                //ManufacturingInventoryCustomContructor();
            } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference SaveTOLiness(){
        try{
            List<Transfer_Order_Line_Items__c> TOLIS2Upsert = new List<Transfer_Order_Line_Items__c>();                   
            List<Inventory_Stock__c> Stocks2Upsert = new List<Inventory_Stock__c>();                    
            List<Stock_Inward_Line_Item__c> SPLIS2Upsert = new List<Stock_Inward_Line_Item__c>();    
            Boolean Error = false;
            
            // Required Validations
            for(ToliWrapper TOLIW : ToliWrapperList){
                for(StockWrapper WIIS : TOLIW.StockWrapperList){
                    if(TOLIW.TOLI.Quantity_Received__c == Null || WIIS.stock.Name == '' || WIIS.stock.Name == Null || WIIS.SP.Site__c == Null){
                        Error = true; TOLIW.errMsg = 'Please fill the fields marked as *'; break;
                    }
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        if(SPL.Quantity__c == Null){
                            Error = true; TOLIW.errMsg = 'Please fill the fields marked as *'; break;
                        }
                    }
                } }if(Error) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
             
            // Calculation Validations
            Boolean isOkmainWrapper = true;
            for(ToliWrapper TOLIW : ToliWrapperList){
                if(TOLIW.TOLI.Quantity_Received__c > TOLIW.TOLI.Quantity_Requested__c){
                    Error = true; TOLIW.errMsg = 'Quantity Received cannot be greater than actual Quantity'; isOkmainWrapper = false;
                }
            }if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            
            for(ToliWrapper TOLIW : ToliWrapperList){
                Decimal subQuantity = 0; 
                for(StockWrapper WIIS : TOLIW.StockWrapperList){
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subQuantity += SPL.Quantity__c;
                    }
                }
                if((TOLIW.lineItemprocessedQuantity - TOLIW.Incount + subQuantity) > TOLIW.TOLI.Quantity_Received__c){
                    Error = true; TOLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(TOLIW.TOLI.Quantity_Received__c - (TOLIW.lineItemprocessedQuantity - TOLIW.Incount));
                }
            }
            // Successful Processing
            if(!Error){
                for(ToliWrapper TOLIW : ToliWrapperList){
                    TOLIW.errMsg = ''; TOLIS2Upsert.add(TOLIW.TOLI);
                    for(StockWrapper WIIS : TOLIW.StockWrapperList){
                       if(Schema.sobjectType.Channel__c.fields.Site__c.isAccessible())  WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                        Stocks2Upsert.add(WIIS.Stock);
                    }
                }
                if(Schema.sObjectType.Inventory_Stock__c.isCreateable() && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) DMLManager.upsertAsUser(Stocks2Upsert); else{ }
                if(Schema.sObjectType.Inventory_Stock__c.isDeletable()) DMLManager.deleteAsUser(stocks2Delete); else{ }
                if(Schema.sObjectType.Stock_Inward_Line_Item__c.isDeletable()) DMLManager.deleteAsUser(SPLIS2Delete); else{ }
                if(Schema.sObjectType.Transfer_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Transfer_Order_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(TOLIS2Upsert); else{ }
                List<String> batchLots = new List<String>();
                for(ToliWrapper TOLIW : ToliWrapperList){
                    Decimal subquant = 0;
                    for(StockWrapper WIIS : TOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Batch_Lot_Code__c.isAccessible()) if(SPL.Batch_Lot_Code__c != Null && SPL.Batch_Lot_Code__c != '') batchLots.add(SPL.Batch_Lot_Code__c);
                        }
                    }
                } batchLots.add('');
               
                for(ToliWrapper TOLIW : ToliWrapperList){
                    Decimal subquant = 0;
                    for(StockWrapper WIIS : TOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                            if(Schema.sobjectType.ERP7__Transfer_Order_Line_Items__c.fields.Products__c.isAccessible()) SPL.Product__c = TOLIW.TOLI.Products__c;
                            if(Schema.sobjectType.ERP7__Transfer_Order_Line_Items__c.isAccessible()) SPL.Transfer_Order_Line_Item__c = TOLIW.TOLI.Id;
                            if(Schema.sobjectType.ERP7__Transfer_Order_Line_Items__c.fields.Transfer_Order__c.isAccessible()) SPL.Transfer_Order__c = TOLIW.TOLI.Transfer_Order__c;
                            if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                            SPLIS2Upsert.add(SPL); if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subquant += SPL.Quantity__c;
                        }
                    } TOLIW.lineItemprocessedQuantity = TOLIW.lineItemprocessedQuantity - TOLIW.Incount + subquant; TOLIW.Incount = subquant;
                }
                if(SPLIS2Upsert.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.isUpdateable()) DMLManager.upsertAsUser(SPLIS2Upsert); else{ }
                ErrMsg = ''; TransferOrderInventoryCustomContructor();
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    
    ////////////// RMA Inventory ///////////////////////
    
    public Void RMAInventoryCustomContructor(){
        schemaMap = Schema.getglobalDescribe();
        RMALIWrapperList = new List<RMALIWrapper>();
        SPLIS2Delete = new List<Stock_Inward_Line_Item__c>();
        stocks2Delete = new List<Inventory_Stock__c>();
        lineItemprocessedQuantities = new Map<String, Decimal>();
        
        String allFields = fetchAllFields('ERP7__Sales_Order__c');
        UtilClass.FlSCheck(allFields.split(',') ,'ERP7__Sales_Order__c');
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ', Channel__r.Organisation__c from ERP7__Sales_Order__c where Id In : soids';
        List<ERP7__Sales_Order__c> SOs = Database.query(query);
        
        orderNames = new Map<Id,String>();
        if(SOs.size() > 0) SO = Sos[0];
        for(ERP7__Sales_Order__c so : SOs){ 
            orderNames.put(so.Id, so.Name);
        }
        
        String qc = 'Quality Check';
        String allFields1 = fetchAllFields('ERP7__RMA_Line_Item__c');
        UtilClass.FlSCheck(allFields1.split(',') ,'ERP7__RMA_Line_Item__c');
        allFields1 += ', ERP7__SOLI__r.Sales_Order__r.Name, ERP7__SOLI__r.Sales_Order__c, ERP7__SOLI__r.ERP7__Product__r.Name'+', ERP7__SOLI__r.ERP7__Product__r.ERP7__Picture__c'+', ERP7__SOLI__r.ERP7__Product__r.ERP7__Preview_Image__c, ERP7__SOLI__r.ERP7__Product__r.ERP7__Is_Kit__c, ERP7__SOLI__r.ERP7__Product__r.ERP7__Kit_Protected__c, Product__r.Name'+', Product__r.Picture__c, Product__r.ERP7__Is_Kit__c, Product__r.ERP7__Kit_Protected__c, Product__r.ERP7__Serialise__c, Product__r.Lot_Tracked__c, Product__r.Preview_Image__c'; 
        String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__RMA_Line_Item__c Where ERP7__Active__c = true and ERP7__Product__c != Null and ERP7__Return_Status__c = :qc and Added_Back_to_Inventory__c != true and ERP7__SOLI__r.Sales_Order__c In : soids order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__RMA_Line_Item__c.isAccessible()) Rolis = Database.query(query1);
        
        List<String> productIds = new List<String>();
        List<String> rmaliIds = new List<String>();
        for(ERP7__RMA_Line_Item__c roli : Rolis){ 
            if(roli.Product__c != Null) productIds.add(roli.Product__c);
            rmaliIds.add(roli.Id);
        }
        
        MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, ERP7__Purchase_Line_Items__c, ERP7__Return_Merchandise_Authorisation__c, ERP7__RMA_Line_Item__c, RecordType.Name From ERP7__MRP__c Where ERP7__RMA_Line_Item__c In :rmaliIds And RecordType.Name = 'MRP Kit'];
       
        String allFields3 = fetchAllFields('ERP7__Stock_Inward_Line_Item__c');
        UtilClass.FlSCheck(allFields3.split(',') ,'ERP7__Stock_Inward_Line_Item__c');
        String query3 = 'select ' + String.escapeSingleQuotes(allFields3) + ' from ERP7__Stock_Inward_Line_Item__c where RMA_Line_Item__c In :rmaliIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isAccessible()) SPLIS = Database.query(query3);
        
        for(ERP7__RMA_Line_Item__c roli : Rolis){
            Decimal quantityProcessed = 0;
            if(roli.Explode__c != true){
                for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                    if(SPLI.RMA_Line_Item__c == roli.Id && SPLI.Quantity__c != Null && roli.Product__c == SPLI.Product__c){
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                    }
                } 
            }
            lineItemprocessedQuantities.put(roli.Id, quantityProcessed);
        }
        
        List<Id> stockIds = new List<Id>();
        List<Id> serialIds = new List<Id>();
        for(Stock_Inward_Line_Item__c SPLI : SPLIS){
           if(SPLI.RMA_Line_Item__c != Null) stockIds.add(SPLI.Site_ProductService_InventoryStock__c);
            if(SPLI.Serial__c != Null)  serialIds.add(SPLI.Serial__c);
        }
        SerialMap = new Map<Id,Serial_Number__c>([Select Id, Name, Serial_Number__c, Product__c from Serial_Number__c Where Id In :serialIds]);
        
        String allFields2 = fetchAllFields('ERP7__Inventory_Stock__c');
        UtilClass.FlSCheck(allFields2.split(',') ,'ERP7__Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name';
        String query2 = 'select ' + String.escapeSingleQuotes(allFields2) + ' from ERP7__Inventory_Stock__c where Id In :stockIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.isAccessible()) warehouseStocks = Database.query(query2);
        
        String allFields4 = fetchAllFields('ERP7__Site__c');
        UtilClass.FlSCheck(allFields4.split(',') ,'ERP7__Site__c');
        String org = SO.Channel__r.Organisation__c;
       
        String query4 = 'select ' + String.escapeSingleQuotes(allFields4) + ' from ERP7__Site__c where Organisation__c  =: org and Active__c = true order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Site__c.isAccessible()) Sites = Database.query(query4);
        
        map<Id,Inventory_Stock__c> stockMap = new map<Id,Inventory_Stock__c>();
        for(Inventory_Stock__c stck : warehouseStocks){ 
            stockMap.put(stck.Id,stck);
        }
        
        stockLines = new Map<Inventory_Stock__c, List<Stock_Inward_Line_Item__c>>();
        for(Inventory_Stock__c WIIS : warehouseStocks){
            List<Stock_Inward_Line_Item__c> mySPLIS = new List<Stock_Inward_Line_Item__c>();
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                if(WIIS.Id == SPLI.Site_ProductService_InventoryStock__c && SPLI.ERP7__RMA_Line_Item__c != Null){
                    mySPLIS.add(SPLI);
                    break;
                }
            }  
            stockLines.put(WIIS, mySPLIS);
        }
        
        List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Rolis Order By CreatedDate Asc];
        Map<Id,Attachment> ROLIAttachment = new Map<Id,Attachment>();
        for(Attachment A : Attachments) ROLIAttachment.put(A.ParentId,A);
          
          
        for(ERP7__RMA_Line_Item__c roli : Rolis){
            RMALIWrapper RMALIWrap = new RMALIWrapper(roli);
            RMALIWrap.attach = (ROLIAttachment.ContainsKey(roli.Id))? ROLIAttachment.get(roli.Id) : new Attachment();
            RMALIWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(roli.Id);
            RMALIWrap.Incount  = 0;
            
            for(Inventory_Stock__c WIIS : warehouseStocks){
                if(roli.Product__c == WIIS.Product__c){
                    for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                        if(SPLI.Product__c == roli.Product__c && roli.Id == SPLI.RMA_Line_Item__c){
                            StockWrapperNew stockWrap = new StockWrapperNew(WIIS,SPLI);
                            stockWrap.SP.Site__c = WIIS.Warehouse__c;
                            RMALIWrap.Incount += SPLI.Quantity__c;
                            if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                            RMALIWrap.StockWrapperList.add(stockWrap);
                        }
                    }
                }
            }
            RMALIWrapperList.add(RMALIWrap);
        }
    }
    
   
    public PageReference AddSOStock(){
        RMALIWrapper RMALIWrap = RMALIWrapperList.get(counter);
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        
        if(RMALIWrap.ROLI.Product__r.Serialise__c != true) spliTemp.Quantity__c = (RMALIWrap.ROLI.Quantity_Return__c != Null && RMALIWrap.lineItemprocessedQuantity != Null)? RMALIWrap.ROLI.Quantity_Return__c-RMALIWrap.lineItemprocessedQuantity : 0;
        if(RMALIWrap.ROLI.Product__r.Serialise__c == true) spliTemp.Quantity__c = 1;
        
        StockWrapperNew SW = new StockWrapperNew(new Inventory_Stock__c(Active__c = true, Product__c = RMALIWrap.ROLI.SOLI__r.Product__c,  Name=RMALIWrap.ROLI.Name,Checked_In_Date__c=system.today()), spliTemp);
        if(RMALIWrap.ROLI.Product__r.Serialise__c == true){
            SW.SerialNumber.Serial_Number__c = (RMALIWrap.ROLI.Starting_Number__c != Null)? RMALIWrap.ROLI.Serial_Number_Prefix__c+String.valueof(RMALIWrap.ROLI.Starting_Number__c+RMALIWrap.StockWrapperList.size()) : RMALIWrap.ROLI.Serial_Number_Prefix__c;
            SW.SerialNumber.Product__c = RMALIWrap.ROLI.Product__c;
        }
        RMALIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null; 
    }
    
    public PageReference RemoveSOStock(){
        StockWrapperNew SW = (lastcounter != Null)? RMALIWrapperList.get(lastcounter).BOMS.get(counter).StockWrapperList.remove(subcounter) : RMALIWrapperList.get(counter).StockWrapperList.remove(subcounter);
        if(SW.stock.Id != Null) stocks2Delete.add(SW.stock);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference cancelSo(){
        String sr = ApexPages.currentPage().getParameters().get('sr');
        PageReference Page;
        if(sr != '' && sr != null) Page = new PageReference('/apex/ERP7__StockReceiving');
        else Page = new PageReference('/'+SO.Id);
        Page.setRedirect(true);
        return Page;
    }
    
    public PageReference Back2Order(){
        PageReference Page = new PageReference('/'+SO.Id);
        Page.setRedirect(true);
        return Page;
    }
    
    public PageReference Back2StockReceiving(){
        PageReference Page = new PageReference('/apex/ERP7__StockReceiving');
        Page.setRedirect(true);
        return Page;
    }
   
    public PageReference SaveROLInesReceived(){
        try{
            List<RMA_Line_Item__c> ROLIS2Upsert = new List<RMA_Line_Item__c>(); 
            Boolean Error = false;
             
            // Calculation Validations
            Boolean isOkmainWrapper = true;
            for(RMALIWrapper WOLIW : RMALIWrapperList){
                if(!(WOLIW.ROLI.Quantity_Return__c > 0)){
                    Error = true;
                    WOLIW.errMsg = 'Quantity Unavailable';
                    isOkmainWrapper = false;
                }
            }
            if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            for(RMALIWrapper WOLIW : RMALIWrapperList){
                if(WOLIW.ROLI.Quantity_Return__c > WOLIW.ROLI.Quantity_Available__c){
                    Error = true;
                    WOLIW.errMsg = 'Quantity Received cannot be less than Quantity added';
                    isOkmainWrapper = false;
                }
            }
            if(Error) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            // Successful Processing
            if(!Error){
                for(RMALIWrapper WOLIW : RMALIWrapperList){
                    WOLIW.errMsg = '';
                    ROLIS2Upsert.add(WOLIW.ROLI);
                }
                if(Schema.sObjectType.RMA_Line_Item__c.isCreateable() && Schema.sObjectType.RMA_Line_Item__c.isUpdateable()) DMLManager.upsertAsUser(ROLIS2Upsert); else{ }
                ErrMsg = '';
                RMAInventoryCustomContructor();
            } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    public PageReference SaveROLines(){
        try{
            List<Inventory_Stock__c> Stocks2Upsert = new List<Inventory_Stock__c>();                    
            List<Stock_Inward_Line_Item__c> SPLIS2Upsert = new List<Stock_Inward_Line_Item__c>();  
            List<Serial_Number__c> Serials2Upsert = new List<Serial_Number__c>();  
            Boolean Error = false;
            
            // Required Validations
            for(RMALIWrapper WOLIW : RMALIWrapperList){
                
                if(WOLIW.ROLI.Explode__c != true){ //Product__r.ERP7__Is_Kit__c
                    /* WOLIW :'+WOLIW) */
                   /*  selectedSite :'+selectedSite); */
                    for(StockWrapperNew WIIS : WOLIW.StockWrapperList){
                        WIIS.SP.Site__c = selectedSite;
                        if(WIIS.stock.Name == '' || WIIS.stock.Name == Null || (WOLIW.ROLI.Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                            Error = true;
                            WOLIW.errMsg = 'Please fill the fields marked as *';
                            break;
                        }
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(SPL.Quantity__c == Null || (WOLIW.ROLI.Product__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                                Error = true;
                                WOLIW.errMsg = 'Please fill the fields marked as *';
                                break;
                            }
                        }
                    }
                } else {
                    for(RMALIWrapper WOLI_IN : WOLIW.BOMS){
                        
                        for(StockWrapperNew WIIS : WOLI_IN.StockWrapperList){
                            WIIS.SP.Site__c = selectedSite;
                            if(WIIS.stock.Name == '' || WIIS.stock.Name == Null || (WOLI_IN.MRP.ERP7__MRP_Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                                Error = true;
                                WOLI_IN.errMsg = 'Please fill the fields marked as *';
                                }
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(SPL.Quantity__c == Null || (WOLI_IN.MRP.ERP7__MRP_Product__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                                    Error = true;
                                    WOLI_IN.errMsg = 'Please fill the fields marked as *';
                                 }
                            }
                        }
                    }
                }
            }
            if(Error) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            
            // Calculation Validations
            Boolean isOkmainWrapper = true;
            for(RMALIWrapper WOLIW : RMALIWrapperList){
                
                if(WOLIW.ROLI.Explode__c != true){
                    if(!(WOLIW.ROLI.Quantity_Return__c > 0)){
                        Error = true;
                        WOLIW.errMsg = 'Quantity Unavailable';
                        isOkmainWrapper = false;
                    }
                } else{
                    for(RMALIWrapper WOLI_IN : WOLIW.BOMS){
                        if(!(WOLI_IN.ROLI.Quantity_Return__c > 0)){
                            Error = true;
                            WOLI_IN.errMsg = 'Quantity Unavailable';
                            isOkmainWrapper = false;
                        }
                    }
                }
            }
            if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            for(RMALIWrapper WOLIW : RMALIWrapperList){
                
               
                if(WOLIW.ROLI.Explode__c != true){
                    Decimal subQuantity = 0; 
                    for(StockWrapperNew WIIS : WOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subQuantity += SPL.Quantity__c;
                            if(WOLIW.ROLI.Product__r.Serialise__c && SPL.Quantity__c > 1){
                                Error = true;
                                WOLIW.errMsg = 'Serialised Product cannot have quantity greater than one';
                            }
                        }
                    }
                    if((WOLIW.lineItemprocessedQuantity - WOLIW.Incount + subQuantity) > WOLIW.ROLI.Quantity_Return__c){
                        Error = true;
                        WOLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(WOLIW.ROLI.Quantity_Return__c - (WOLIW.lineItemprocessedQuantity - WOLIW.Incount));
                    }
                } else{  
                    for(RMALIWrapper WOLI_IN : WOLIW.BOMS){
                        Decimal subQuantity = 0; 
                        for(StockWrapperNew WIIS : WOLI_IN.StockWrapperList){
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subQuantity += SPL.Quantity__c;
                                if(WOLI_IN.MRP.ERP7__MRP_Product__r.Serialise__c && SPL.Quantity__c > 1){
                                    Error = true;
                                    WOLI_IN.errMsg = 'Serialised Product component cannot have quantity greater than one';
                                }
                            }
                        }
                        if((WOLI_IN.lineItemprocessedQuantity - WOLI_IN.Incount + subQuantity) > (WOLI_IN.ROLI.Quantity_Return__c * WOLI_IN.mrp.ERP7__Total_Amount_Required__c)){
                            Error = true;
                            WOLI_IN.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(WOLI_IN.ROLI.Quantity_Return__c - (WOLI_IN.lineItemprocessedQuantity - WOLI_IN.Incount));
                        }
                    }
                } 
            }
            
            // Successful Processing
            if(!Error){
                for(RMALIWrapper WOLIW : RMALIWrapperList){
                    if(WOLIW.ROLI.Explode__c != true){
                        WOLIW.errMsg = '';
                        for(StockWrapperNew WIIS : WOLIW.StockWrapperList){
                            WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                            Stocks2Upsert.add(WIIS.Stock);
                            if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                Serials2Upsert.add(WIIS.SerialNumber);
                            }
                        }
                    } else{  
                        for(RMALIWrapper WOLI_IN : WOLIW.BOMS){
                            WOLIW.errMsg = '';
                            for(StockWrapperNew WIIS : WOLI_IN.StockWrapperList){
                                if(Schema.sobjectType.Inventory_Stock__c.fields.Warehouse__c.isAccessible()) WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                                Stocks2Upsert.add(WIIS.Stock);
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                    WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                    Serials2Upsert.add(WIIS.SerialNumber);
                                }
                            } 
                        }
                    }
                }
                if(Serials2Upsert.size() > 0 && Schema.sObjectType.Serial_Number__c.isCreateable() && Schema.sObjectType.Serial_Number__c.isUpdateable()) DMLManager.upsertAsUser(Serials2Upsert); else{ }
                if(Stocks2Upsert.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isCreateable() && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) DMLManager.upsertAsUser(Stocks2Upsert); else{ }
                if(SPLIS2Delete.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isDeletable()) DMLManager.deleteAsUser(SPLIS2Delete); else{ }
                if(stocks2Delete.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isDeletable()) DMLManager.deleteAsUser(stocks2Delete); else{ }
                
                
                for(RMALIWrapper WOLIW : RMALIWrapperList){
                    /*Decimal subquant = 0;
                    for(StockWrapperNew WIIS : WOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(Schema.sobjectType.Inventory_Stock__c.fields.Name.isAccessible()) SPL.Name = WIIS.Stock.Name;
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                            if(Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.isAccessible() && Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.fields.Product__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.ERP7__SOLI__c.isAccessible()) SPL.Product__c = WOLIW.ROLI.SOLI__r.Product__c;
                            if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sobjectType.Stock_Inward_Line_Item__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                            if(Schema.sobjectType.ERP7__RMA_Line_Item__c.isAccessible())SPL.RMA_Line_Item__c = WOLIW.ROLI.Id;
                            if(Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.Total_Deduction__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.Quantity_Return__c.isAccessible()) SPL.Unit_Price__c = (WOLIW.ROLI.Total_Deduction__c >= 0 && WOLIW.ROLI.Total_Deduction__c > 0)? WOLIW.ROLI.Total_Deduction__c/WOLIW.ROLI.Quantity_Return__c : 0;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isAccessible() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())SPL.Amount__c = SPL.Unit_Price__c * SPL.Quantity__c;
                            SPLIS2Upsert.add(SPL);
                            if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subquant += SPL.Quantity__c;
                        }
                    }
                    WOLIW.lineItemprocessedQuantity = WOLIW.lineItemprocessedQuantity - WOLIW.Incount + subquant;
                    WOLIW.Incount = subquant;
                    */
                    
                    if(WOLIW.ROLI.Explode__c != true){
                        
                        Decimal subquant = 0;
                        for(StockWrapperNew WIIS : WOLIW.StockWrapperList){
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(Schema.sobjectType.Inventory_Stock__c.fields.Name.isAccessible()) SPL.Name = WIIS.Stock.Name;
                                if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                                if(Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.isAccessible() && Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.fields.Product__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.ERP7__SOLI__c.isAccessible()) SPL.Product__c = WOLIW.ROLI.SOLI__r.Product__c;
                                if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sobjectType.Stock_Inward_Line_Item__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                if(Schema.sobjectType.ERP7__RMA_Line_Item__c.isAccessible())SPL.RMA_Line_Item__c = WOLIW.ROLI.Id;
                                SPL.ERP7__Sales_Order_Line_Item__c = WOLIW.ROLI.ERP7__SOLI__c;
                                if(Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.Total_Deduction__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.Quantity_Return__c.isAccessible()) SPL.Unit_Price__c = (WOLIW.ROLI.Total_Deduction__c >= 0 && WOLIW.ROLI.Total_Deduction__c > 0)? WOLIW.ROLI.Total_Deduction__c/WOLIW.ROLI.Quantity_Return__c : 0;
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isAccessible() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())SPL.Amount__c = SPL.Unit_Price__c * SPL.Quantity__c;
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') SPL.Serial__c = WIIS.SerialNumber.Id;
                                SPLIS2Upsert.add(SPL);
                                if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subquant += SPL.Quantity__c;
                            }
                        }
                        WOLIW.lineItemprocessedQuantity = WOLIW.lineItemprocessedQuantity - WOLIW.Incount + subquant;
                        WOLIW.Incount = subquant;
                    } else{ 
                        for(RMALIWrapper WOLI_IN : WOLIW.BOMS){
                            
                            Decimal subquant = 0;
                            for(StockWrapperNew WIIS : WOLI_IN.StockWrapperList){
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    if(Schema.sobjectType.Inventory_Stock__c.fields.Name.isAccessible()) SPL.Name = WIIS.Stock.Name;
                                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                                    if(Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.isAccessible() && Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.fields.Product__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.ERP7__SOLI__c.isAccessible()) SPL.Product__c = WOLI_IN.MRP.ERP7__MRP_Product__c;
                                    if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sobjectType.Stock_Inward_Line_Item__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                    if(Schema.sobjectType.ERP7__RMA_Line_Item__c.isAccessible())SPL.RMA_Line_Item__c = WOLIW.ROLI.Id;
                                    SPL.ERP7__Sales_Order_Line_Item__c = WOLIW.ROLI.ERP7__SOLI__c;
                                    if(Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.Total_Deduction__c.isAccessible() && Schema.sobjectType.ERP7__RMA_Line_Item__c.fields.Quantity_Return__c.isAccessible()) SPL.Unit_Price__c = (WOLIW.ROLI.Total_Deduction__c >= 0 && WOLIW.ROLI.Total_Deduction__c > 0)? WOLIW.ROLI.Total_Deduction__c/WOLIW.ROLI.Quantity_Return__c : 0;
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isAccessible() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())SPL.Amount__c = SPL.Unit_Price__c * SPL.Quantity__c;
                                    if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') SPL.Serial__c = WIIS.SerialNumber.Id;
                                    SPLIS2Upsert.add(SPL);
                                    if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subquant += SPL.Quantity__c;
                                }
                            }
                            WOLI_IN.lineItemprocessedQuantity = WOLI_IN.lineItemprocessedQuantity - WOLI_IN.Incount + subquant;
                            WOLI_IN.Incount = subquant;
                        }
                    }
                }
                if(SPLIS2Upsert.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.isUpdateable()) DMLManager.upsertAsUser(SPLIS2Upsert); else{ }
                ErrMsg = '';
                RMAInventoryCustomContructor();
            } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
   
    
    ////////////// Supplier Inventory ///////////////////////
    
    public Void SupplierInventoryCustomContructor(){
        schemaMap = Schema.getglobalDescribe();
        PLIWrapperList = new List<PLIWrapper>();
        SPLIS2Delete = new List<Stock_Inward_Line_Item__c>();
        stocks2Delete = new List<Inventory_Stock__c>();
        lineItemprocessedQuantities = new Map<String, Decimal>();
        
        String allFields = fetchAllFields('ERP7__PO__c');
        UtilClass.FlSCheck(allFields.split(',') ,'ERP7__PO__c');
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ', Channel__r.Organisation__c from ERP7__PO__c where Id in: poIds';
        List<ERP7__PO__c> POs = Database.query(query);
        
        
        orderNames = new Map<Id,String>();
        if(POs.size() > 0) PO = POs[0];
        for(ERP7__PO__c PO : POs){ 
            orderNames.put(PO.Id, PO.Name);
        }
        
        String allFields1 = fetchAllFields('ERP7__Purchase_Line_Items__c');
        UtilClass.FlSCheck(allFields1.split(',') ,'ERP7__Purchase_Line_Items__c');
        allFields1 += ', Purchase_Orders__r.Name, Product__r.Name'+', Product__r.Picture__c, Product__r.ERP7__Is_Kit__c, Product__r.ERP7__Kit_Protected__c, Product__r.ERP7__Serialise__c, Product__r.Lot_Tracked__c, Product__r.Preview_Image__c';
        String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Purchase_Line_Items__c where Purchase_Orders__c in : poIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.isAccessible()) Polis = Database.query(query1);
        
        List<String> productIds = new List<String>();
        List<String> PLIIds = new List<String>();
        for(Purchase_Line_Items__c poli : Polis){
            if(poli.Product__c != Null) productIds.add(poli.Product__c);
            PLIIds.add(poli.Id);
        }
        
        MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Serialise__c, ERP7__MRP_Product__r.Lot_Tracked__c, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, ERP7__Purchase_Line_Items__c, RecordType.Name From ERP7__MRP__c Where ERP7__Purchase_Line_Items__c In :PLIIds And RecordType.Name = 'MRP Kit'];
        
        String allFields3 = fetchAllFields('ERP7__Stock_Inward_Line_Item__c');
        UtilClass.FlSCheck(allFields3.split(',') ,'ERP7__Stock_Inward_Line_Item__c');
        String query3 = 'select ' + String.escapeSingleQuotes(allFields3) + ' from ERP7__Stock_Inward_Line_Item__c where Purchase_Line_Items__c In :PLIIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isAccessible()) SPLIS = Database.query(query3);
        
        for(Purchase_Line_Items__c poli : Polis){
            Decimal quantityProcessed = 0;
            if(poli.Explode__c != true){
                for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                    if(SPLI.Purchase_Line_Items__c == poli.Id && SPLI.Quantity__c != Null && poli.Product__c == SPLI.Product__c){
                        if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                    }
                }
            }
            lineItemprocessedQuantities.put(poli.Id, quantityProcessed);
        }
        
        List<Id> stockIds = new List<Id>();
        List<Id> serialIds = new List<Id>();
        for(Stock_Inward_Line_Item__c SPLI : SPLIS){
            if(SPLI.Sales_Order_Line_Item__c == Null)  stockIds.add(SPLI.Site_ProductService_InventoryStock__c);
            if(SPLI.Serial__c != Null)  serialIds.add(SPLI.Serial__c);
        }
        
        SerialMap = new Map<Id,Serial_Number__c>([Select Id, Name, Serial_Number__c, Product__c from Serial_Number__c Where Id In :serialIds]);
        
        if(PO.Sales_Order__c != Null){
            if(Schema.sobjectType.ERP7__PO__c.fields.Sales_Order__c.isAccessible()) Id soId = PO.Sales_Order__c;
            String allFieldsPPLI = fetchAllFields('ERP7__Stock_Outward_Line_Item__c');
            UtilClass.FlSCheck(allFieldsPPLI.split(',') ,'ERP7__Stock_Outward_Line_Item__c');
            allFieldsPPLI += ', Sales_Order_Line_Item__r.Sales_Order__c';
            String queryppli = 'select ' + String.escapeSingleQuotes(allFieldsPPLI) + ' from ERP7__Stock_Outward_Line_Item__c where Sales_Order_Line_Item__r.Sales_Order__c = :soId order by CreatedDate ASC';
            if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isAccessible()) PPLIs2Update = Database.query(queryppli);
        }
        for(Stock_Outward_Line_Item__c PPLI : PPLIs2Update){
            if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isAccessible()) stockIds.add(PPLI.Site_Product_Service_Inventory_Stock__c);
        }
        
        String allFields2 = fetchAllFields('ERP7__Inventory_Stock__c');
        UtilClass.FlSCheck(allFields2.split(',') ,'ERP7__Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name';
        String query2 = 'select ' + String.escapeSingleQuotes(allFields2) + ' from ERP7__Inventory_Stock__c where Id In :stockIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.isAccessible()) warehouseStocks = Database.query(query2);
        
        String allFields4 = fetchAllFields('ERP7__Site__c');
        UtilClass.FlSCheck(allFields4.split(',') ,'ERP7__Site__c');
        String org = PO.Channel__r.Organisation__c;
        
        String query4 = 'select ' + String.escapeSingleQuotes(allFields4) + ' from ERP7__Site__c where Organisation__c  =: org and Active__c = true order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Site__c.isAccessible()) Sites = Database.query(query4);
        
        
        stockLines = new Map<Inventory_Stock__c, List<Stock_Inward_Line_Item__c>>();
        for(Inventory_Stock__c WIIS : warehouseStocks){
            List<Stock_Inward_Line_Item__c> mySPLIS = new List<Stock_Inward_Line_Item__c>();
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                if(WIIS.Id == SPLI.Site_ProductService_InventoryStock__c && SPLI.Sales_Order_Line_Item__c == Null){
                    mySPLIS.add(SPLI);
                    break;
                }
            }  
            stockLines.put(WIIS, mySPLIS);
        }
        
        List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Polis Order By CreatedDate Asc];
        Map<Id,Attachment> POLIAttachment = new Map<Id,Attachment>();
        for(Attachment A : Attachments) POLIAttachment.put(A.ParentId,A);
          
        for(ERP7__Purchase_Line_Items__c poli : Polis){
            PLIWrapper PLIWrap = new PLIWrapper(poli);
            PLIWrap.attach = (POLIAttachment.ContainsKey(poli.Id))? POLIAttachment.get(poli.Id) : new Attachment();
            PLIWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(poli.Id);
            PLIWrap.Incount  = 0;
            for(Inventory_Stock__c WIIS : warehouseStocks){
                if(poli.Product__c == WIIS.Product__c){
                    for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                        if(SPLI.Product__c == poli.Product__c && poli.Id == SPLI.Purchase_Line_Items__c){
                            StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS));
                            stockWrap.SP.Site__c = WIIS.Warehouse__c;
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) PLIWrap.Incount += SPLI.Quantity__c;
                            if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                            PLIWrap.StockWrapperList.add(stockWrap);
                            //break;
                        }
                    }
                    
                }
            }
            PLIWrapperList.add(PLIWrap);
        }
    }
   
    public PageReference AddStock(){
        /*  counter :'+counter); '*** subcounter :'+subcounter);*/
        PLIWrapper PLIWrap = PLIWrapperList.get(counter);
        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        //if(PLIWrap.PLI.Product__r.Serialise__c != true) spliTemp.Quantity__c = (PLIWrap.PLI.Quantity_Received__c != Null && PLIWrap.lineItemprocessedQuantity != Null)? PLIWrap.PLI.Quantity_Received__c-PLIWrap.lineItemprocessedQuantity : 0;
         if(PLIWrap.PLI.Product__r.Serialise__c != true) spliTemp.Quantity__c = (PLIWrap.PLI.Quantity_Received__c != Null)? PLIWrap.PLI.Quantity_Received__c : 0;
        if(PLIWrap.PLI.Product__r.Serialise__c == true) spliTemp.Quantity__c = 1;
        tspli.add(spliTemp);
        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = PLIWrap.pli.Product__c, Organisation__c = PLIWrap.pli.Organisation__c, Name=PLIWrap.pli.Name,Checked_In_Date__c=system.today()), tspli);
        if(PLIWrap.PLI.Product__r.Serialise__c == true){
            SW.SerialNumber.Serial_Number__c = (PLIWrap.PLI.Starting_Number__c != Null)? PLIWrap.PLI.Serial_Number_Prefix__c+String.valueof(PLIWrap.PLI.Starting_Number__c+PLIWrap.StockWrapperList.size()) : PLIWrap.PLI.Serial_Number_Prefix__c;
            SW.SerialNumber.Product__c = PLIWrap.PLI.Product__c;
        }
        PLIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference AddStockKit(){
        
        PLIWrapper PLIWrap = PLIWrapperList.get(counter).BOMS.get(subcounter);
        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        //if(PLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c != true) spliTemp.Quantity__c = (PLIWrap.PLI.Quantity_Received__c != Null && PLIWrap.lineItemprocessedQuantity != Null)? (((PLIWrap.PLI.Quantity_Received__c*PLIWrap.MRP.ERP7__Total_Amount_Required__c)/PLIWrap.PLI.Quantity__c)-PLIWrap.lineItemprocessedQuantity) : 0;
        if(PLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c != true) spliTemp.Quantity__c = (PLIWrap.PLI.Quantity_Received__c != Null)? (((PLIWrap.PLI.Quantity_Received__c*PLIWrap.MRP.ERP7__Total_Amount_Required__c)/PLIWrap.PLI.Quantity__c)) : 0;
        if(PLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c == true) spliTemp.Quantity__c = 1;
        tspli.add(spliTemp);
        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = PLIWrap.MRP.ERP7__MRP_Product__c, Organisation__c = PLIWrap.pli.Organisation__c, Name=PLIWrap.pli.Name,Checked_In_Date__c=system.today()), tspli);
        if(PLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c == true){
            SW.SerialNumber.Serial_Number__c = (PLIWrap.PLI.Starting_Number__c != Null)? PLIWrap.PLI.Serial_Number_Prefix__c+String.valueof(PLIWrap.PLI.Starting_Number__c+PLIWrap.StockWrapperList.size()) : PLIWrap.PLI.Serial_Number_Prefix__c;
            SW.SerialNumber.Product__c = PLIWrap.MRP.ERP7__MRP_Product__c;
        }
        PLIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference AddStockKitWO(){
        
        WOLIWrapper WOLIWrap = WOLIWrapperList.get(counter).BOMS.get(subcounter);
        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        spliTemp.Quantity__c = (WOLIWrap.WOLI.Quantity__c != Null && WOLIWrap.lineItemprocessedQuantity != Null)? ((WOLIWrap.WOLI.Quantity__c*WOLIWrap.MRP.ERP7__Total_Amount_Required__c)-WOLIWrap.lineItemprocessedQuantity) : 0;
        tspli.add(spliTemp);
        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = WOLIWrap.MRP.ERP7__MRP_Product__c, Organisation__c = WOLIWrap.WOLI.Organisation__c, Name=WOLIWrap.WOLI.Name,Checked_In_Date__c=system.today()), tspli);
        if(WOLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c == true){
            SW.SerialNumber.Serial_Number__c = (WOLIWrap.WOLI.Starting_Number__c != Null)? WOLIWrap.WOLI.Serial_Number_Prefix__c+String.valueof(WOLIWrap.WOLI.Starting_Number__c+WOLIWrap.StockWrapperList.size()) : WOLIWrap.WOLI.Serial_Number_Prefix__c;
            SW.SerialNumber.Product__c = WOLIWrap.MRP.ERP7__MRP_Product__c;
        }
        
        WOLIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference AddStockKitTO(){
      
        TOLIWrapper TOLIWrap = TOLIWrapperList.get(counter).BOMS.get(subcounter);
        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        spliTemp.Quantity__c = (TOLIWrap.TOLI.Quantity_requested__c != Null && TOLIWrap.lineItemprocessedQuantity != Null)? ((TOLIWrap.TOLI.Quantity_requested__c*TOLIWrap.MRP.ERP7__Total_Amount_Required__c)-TOLIWrap.lineItemprocessedQuantity) : 0;
        tspli.add(spliTemp);
        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = TOLIWrap.MRP.ERP7__MRP_Product__c, Organisation__c = TOLIWrap.TOLI.Organisation__c, Name=TOLIWrap.TOLI.Name,Checked_In_Date__c=system.today()), tspli);
        
        TOLIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference AddStockKitSO(){
        
        RMALIWrapper RMALIWrap = RMALIWrapperList.get(counter).BOMS.get(subcounter);
        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        spliTemp.Quantity__c = (RMALIWrap.ROLI.Quantity_Return__c != Null && RMALIWrap.lineItemprocessedQuantity != Null)? ((RMALIWrap.ROLI.Quantity_Return__c*RMALIWrap.MRP.ERP7__Total_Amount_Required__c)-RMALIWrap.lineItemprocessedQuantity) : 0;
        tspli.add(spliTemp);
        StockWrapperNew SW = new StockWrapperNew(new Inventory_Stock__c(Active__c = true, Product__c = RMALIWrap.ROLI.SOLI__r.Product__c, Organisation__c = RMALIWrap.ROLI.Organisation__c, Name=RMALIWrap.ROLI.Name,Checked_In_Date__c=system.today()), spliTemp);
        
        RMALIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference RemoveStock(){
        StockWrapper SW = (lastcounter != Null)? PLIWrapperList.get(lastcounter).BOMS.get(counter).StockWrapperList.remove(subcounter) : PLIWrapperList.get(counter).StockWrapperList.remove(subcounter);
        if(SW.stock.Id != Null) stocks2Delete.add(SW.stock);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference ExplodeKit(){
        schemaMap = Schema.getglobalDescribe();
        PLIWrapper PLIWrap = PLIWrapperList.get(counter);
        
        List<PLIWrapper> BomsWrapper = new List<PLIWrapper>();
        Map<String, Decimal> lineItemprocessedQuantities = new Map<String, Decimal>();
        
        for(ERP7__MRP__c mrp : MRPS){
            Decimal quantityProcessed = 0;
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                if(SPLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SPLI.Product__c && mrp.ERP7__Purchase_Line_Items__c == PLIWrap.PLI.Id && mrp.ERP7__Purchase_Line_Items__c == SPLI.ERP7__Purchase_Line_Items__c){
                    if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                }
            }
            lineItemprocessedQuantities.put(mrp.ERP7__MRP_Product__c, quantityProcessed);
        }
        for(ERP7__MRP__c mrp : MRPS){
            if(mrp.ERP7__Purchase_Line_Items__c == PLIWrap.PLI.Id){
                PLIWrapper PLIWrapIN = new PLIWrapper(PLIWrap.PLI);
                PLIWrapIN.mrp = mrp;
                PLIWrapIN.lineItemprocessedQuantity = lineItemprocessedQuantities.get(mrp.ERP7__MRP_Product__c);
                PLIWrapIN.Incount  = 0;
                for(Inventory_Stock__c WIIS : warehouseStocks){
                    if(mrp.ERP7__MRP_Product__c == WIIS.Product__c){
                        
                        for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                            if(SPLI.Product__c == mrp.ERP7__MRP_Product__c && mrp.ERP7__Purchase_Line_Items__c == SPLI.ERP7__Purchase_Line_Items__c){
                                StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS));
                                if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) PLIWrapIN.Incount += SPLI.Quantity__c;
                                if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)){
                                    stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                                }
                                PLIWrapIN.StockWrapperList.add(stockWrap);
                                //break;
                            }
                        }
                        
                    }
                }
                if(PLIWrapIN.StockWrapperList.size() == 0){
                    if(mrp.ERP7__MRP_Product__r.Serialise__c != true){
                        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
                        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
                        spliTemp.Quantity__c = (PLIWrapIN.PLI.Quantity_Received__c != Null && PLIWrapIN.lineItemprocessedQuantity != Null)? ((PLIWrapIN.PLI.Quantity_Received__c * PLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/PLIWrapIN.PLI.Quantity__c) - PLIWrapIN.lineItemprocessedQuantity : 0;
                        tspli.add(spliTemp);
                        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = PLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = PLIWrapIN.pli.Organisation__c, Name=PLIWrapIN.pli.Name,Checked_In_Date__c=system.today()), tspli);
                        PLIWrapIN.StockWrapperList.add(SW);
                    }else{
                        if(PLIWrapIN.PLI.Quantity_Received__c != Null && PLIWrapIN.lineItemprocessedQuantity != Null){
                            Integer N = Integer.valueof(((PLIWrapIN.PLI.Quantity_Received__c * PLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/PLIWrapIN.PLI.Quantity__c) - PLIWrapIN.lineItemprocessedQuantity);
                            for(Integer i=0; i<N; i++){
                                List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
                                Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
                                spliTemp.Quantity__c = 1;
                                tspli.add(spliTemp);
                                StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = PLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = PLIWrapIN.pli.Organisation__c, Name=PLIWrapIN.pli.Name,Checked_In_Date__c=system.today()), tspli);
                                    SW.SerialNumber.Serial_Number__c = (PLIWrapIN.PLI.Starting_Number__c != Null)? PLIWrapIN.PLI.Serial_Number_Prefix__c+String.valueof(PLIWrapIN.PLI.Starting_Number__c+i) : PLIWrapIN.PLI.Serial_Number_Prefix__c;
                                    SW.SerialNumber.Product__c = PLIWrapIN.MRP.ERP7__MRP_Product__c;
                                PLIWrapIN.StockWrapperList.add(SW);
                            }
                        }
                    }
                }
                BomsWrapper.add(PLIWrapIN);
            }
        }
        
        PLIWrap.Boms = BomsWrapper;
        counter = subcounter = lastcounter = Null;
        return Null;
        
    }
    
    public PageReference ExplodeKitWO(){
        schemaMap = Schema.getglobalDescribe();
        WOLIWrapper WOLIWrap = WOLIWrapperList.get(counter);
        
        List<WOLIWrapper> BomsWrapper = new List<WOLIWrapper>();
        Map<String, Decimal> lineItemprocessedQuantities = new Map<String, Decimal>();
        
        for(ERP7__MRP__c mrp : MRPS){
            Decimal quantityProcessed = 0;
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                if(SPLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SPLI.Product__c && mrp.ERP7__Work_Order_Line_Items__c == WOLIWrap.WOLI.Id){
                    if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                }
            }
            lineItemprocessedQuantities.put(mrp.ERP7__MRP_Product__c, quantityProcessed);
        }
        for(ERP7__MRP__c mrp : MRPS){
            if(mrp.ERP7__Work_Order_Line_Items__c == WOLIWrap.WOLI.Id){
                WOLIWrapper WOLIWrapIN = new WOLIWrapper(WOLIWrap.woli);
                WOLIWrapIN.mrp = mrp;
                WOLIWrapIN.lineItemprocessedQuantity = lineItemprocessedQuantities.get(mrp.ERP7__MRP_Product__c);
                WOLIWrapIN.Incount  = 0;
                for(Inventory_Stock__c WIIS : warehouseStocks){
                    if(mrp.ERP7__MRP_Product__c == WIIS.Product__c){
                        
                        for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                            if(SPLI.Product__c == mrp.ERP7__MRP_Product__c && SPLI.ERP7__Work_Order_Line_Items__c == mrp.ERP7__Work_Order_Line_Items__c){
                                StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS));
                                if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) WOLIWrapIN.Incount += SPLI.Quantity__c;
                                if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)){
                                    stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                                }
                                WOLIWrapIN.StockWrapperList.add(stockWrap);
                            }
                        }
                    }
                }
                if(WOLIWrapIN.StockWrapperList.size() == 0){
                    if(mrp.ERP7__MRP_Product__r.Serialise__c != true){
                        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
                        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
                        spliTemp.Quantity__c = (WOLIWrapIN.woli.Quantity__c != Null && WOLIWrapIN.lineItemprocessedQuantity != Null)? (WOLIWrapIN.woli.Quantity__c * WOLIWrapIN.mrp.ERP7__Total_Amount_Required__c) - WOLIWrapIN.lineItemprocessedQuantity : 0;
                        tspli.add(spliTemp);
                        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = WOLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = WOLIWrapIN.woli.Organisation__c, Name=WOLIWrapIN.woli.Name,Checked_In_Date__c=system.today()), tspli);
                        WOLIWrapIN.StockWrapperList.add(SW);
                    }else{
                        if(WOLIWrapIN.Woli.Quantity__c != Null && WOLIWrapIN.lineItemprocessedQuantity != Null){
                            Integer N = Integer.valueof(((WOLIWrapIN.Woli.Quantity__c * WOLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/WOLIWrapIN.Woli.Quantity__c) - WOLIWrapIN.lineItemprocessedQuantity);
                            for(Integer i=0; i<N; i++){
                                List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
                                Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
                                spliTemp.Quantity__c = 1;
                                tspli.add(spliTemp);
                                StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = WOLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = WOLIWrapIN.Woli.Organisation__c, Name=WOLIWrapIN.Woli.Name,Checked_In_Date__c=system.today()), tspli);
                                    SW.SerialNumber.Serial_Number__c = (WOLIWrapIN.Woli.Starting_Number__c != Null)? WOLIWrapIN.Woli.Serial_Number_Prefix__c+String.valueof(WOLIWrapIN.Woli.Starting_Number__c+i) : WOLIWrapIN.Woli.Serial_Number_Prefix__c;
                                    SW.SerialNumber.Product__c = WOLIWrapIN.MRP.ERP7__MRP_Product__c;
                                WOLIWrapIN.StockWrapperList.add(SW);
                            }
                        }
                    }
                    
                }
                BomsWrapper.add(WOLIWrapIN);
            }
        }
        
        WOLIWrap.Boms = BomsWrapper;
        counter = subcounter = lastcounter = Null;
        return Null;
        
    }
    
   public PageReference ExplodeKitTO(){
        schemaMap = Schema.getglobalDescribe();
        TOLIWrapper TOLIWrap = TOLIWrapperList.get(counter);
        /* TOLIWrap :'+TOLIWrap   *** MRPS :'+MRPS)*/
        List<TOLIWrapper> BomsWrapper = new List<TOLIWrapper>();
        Map<String, Decimal> lineItemprocessedQuantities = new Map<String, Decimal>();
       
        for(ERP7__MRP__c mrp : MRPS){
            Decimal quantityProcessed = 0;
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                /* SPLI :'+SPLI);*/
                if(SPLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SPLI.Product__c && mrp.ERP7__Transfer_Order_Line_Item__c == TOLIWrap.TOLI.Id && mrp.ERP7__Transfer_Order_Line_Item__c == SPLI.ERP7__Transfer_Order_Line_Item__c){
                    if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                }
            }
            String LIQ = String.valueof(TOLIWrap.TOLI.Id)+String.valueof(mrp.ERP7__MRP_Product__c);
            lineItemprocessedQuantities.put(LIQ, quantityProcessed);
        }
        for(ERP7__MRP__c mrp : MRPS){
            if(mrp.ERP7__Transfer_Order_Line_Item__c == TOLIWrap.TOLI.Id){
                
                TOLIWrapper TOLIWrapIN = new TOLIWrapper(TOLIWrap.TOLI);
                TOLIWrapIN.mrp = mrp;
                String LIQ = String.valueof(TOLIWrap.TOLI.Id)+String.valueof(mrp.ERP7__MRP_Product__c);
                TOLIWrapIN.lineItemprocessedQuantity = lineItemprocessedQuantities.get(LIQ);
                TOLIWrapIN.Incount  = 0;
                for(Inventory_Stock__c WIIS : warehouseStocks){
                    
                    if(mrp.ERP7__MRP_Product__c == WIIS.Product__c){
                        
                        for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                            if(SPLI.Product__c == mrp.ERP7__MRP_Product__c && SPLI.ERP7__Transfer_Order_Line_Item__c == mrp.ERP7__Transfer_Order_Line_Item__c){
                                StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS));
                                if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) TOLIWrapIN.Incount += SPLI.Quantity__c;
                                if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)){
                                    stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                                   /*stockWrap.SerialNumber '+stockWrap.SerialNumber);*/
                                }
                                TOLIWrapIN.StockWrapperList.add(stockWrap);
                            }
                        }
                         
                    }
                }
                if(TOLIWrapIN.StockWrapperList.size() == 0){
                    if(mrp.ERP7__MRP_Product__r.Serialise__c != true){
                        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
                        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
                        spliTemp.Quantity__c = (TOLIWrapIN.TOLI.ERP7__Quantity_requested__c != Null && TOLIWrapIN.lineItemprocessedQuantity != Null)? (TOLIWrapIN.TOLI.ERP7__Quantity_requested__c * TOLIWrapIN.mrp.ERP7__Total_Amount_Required__c) - TOLIWrapIN.lineItemprocessedQuantity : 0;
                        tspli.add(spliTemp);
                        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = TOLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = TOLIWrapIN.TOLI.Organisation__c, Name=TOLIWrapIN.TOLI.Name,Checked_In_Date__c=system.today()), tspli);
                        TOLIWrapIN.StockWrapperList.add(SW);
                    } else{
                        if(TOLIWrapIN.TOLI.ERP7__Quantity_requested__c != Null && TOLIWrapIN.lineItemprocessedQuantity != Null){
                            Integer N = Integer.valueof(((TOLIWrapIN.TOLI.ERP7__Quantity_requested__c * TOLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/TOLIWrapIN.TOLI.ERP7__Quantity_requested__c) - TOLIWrapIN.lineItemprocessedQuantity);
                            for(Integer i=0; i<N; i++){
                                List<Stock_Inward_Line_Item__c> tsTOLI = new List<Stock_Inward_Line_Item__c>();
                                Stock_Inward_Line_Item__c sTOLITemp = new Stock_Inward_Line_Item__c();
                                sTOLITemp.Quantity__c = 1;
                                tsTOLI.add(sTOLITemp);
                                StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = TOLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = TOLIWrapIN.TOLI.Organisation__c, Name=TOLIWrapIN.TOLI.Name,Checked_In_Date__c=system.today()), tsTOLI);
                                    SW.SerialNumber.Serial_Number__c = (TOLIWrapIN.TOLI.Starting_Number__c != Null)? TOLIWrapIN.TOLI.Serial_Number_Prefix__c+String.valueof(TOLIWrapIN.TOLI.Starting_Number__c+i) : TOLIWrapIN.TOLI.Serial_Number_Prefix__c;
                                    SW.SerialNumber.Product__c = TOLIWrapIN.MRP.ERP7__MRP_Product__c;
                                TOLIWrapIN.StockWrapperList.add(SW);
                            }
                        }
                    }
                    
                } 
                BomsWrapper.add(TOLIWrapIN);
            }
        }
       
        TOLIWrap.Boms = BomsWrapper;
        counter = subcounter = lastcounter = Null;
        return Null;
        
    }
    
    public PageReference ExplodeKitSO(){
        schemaMap = Schema.getglobalDescribe();
        RMALIWrapper ROLIWrap = RMALIWrapperList.get(counter);
        
        List<RMALIWrapper> BomsWrapper = new List<RMALIWrapper>();
        Map<String, Decimal> lineItemprocessedQuantities = new Map<String, Decimal>();
        
        
        for(ERP7__MRP__c mrp : MRPS){
            Decimal quantityProcessed = 0;
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                
                if(SPLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SPLI.Product__c && mrp.ERP7__RMA_Line_Item__c == ROLIWrap.ROLI.Id && SPLI.RMA_Line_Item__c == mrp.ERP7__RMA_Line_Item__c ){
                    if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                }
            }
            String LIQ = String.valueof(ROLIWrap.ROLI.Id)+String.valueof(mrp.ERP7__MRP_Product__c);
            lineItemprocessedQuantities.put(LIQ, quantityProcessed);
        }
        for(ERP7__MRP__c mrp : MRPS){
            if(mrp.ERP7__RMA_Line_Item__c == ROLIWrap.ROLI.Id){
               
                RMALIWrapper ROLIWrapIN = new RMALIWrapper(ROLIWrap.ROLI);
                ROLIWrapIN.mrp = mrp;
                String LIQ = String.valueof(ROLIWrap.ROLI.Id)+String.valueof(mrp.ERP7__MRP_Product__c);
                ROLIWrapIN.lineItemprocessedQuantity = lineItemprocessedQuantities.get(LIQ);
                ROLIWrapIN.Incount  = 0;
                for(Inventory_Stock__c WIIS : warehouseStocks){
                    
                    if(mrp.ERP7__MRP_Product__c == WIIS.Product__c){
                        for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                            if(SPLI.Product__c == mrp.ERP7__MRP_Product__c && SPLI.ERP7__RMA_Line_Item__c == mrp.ERP7__RMA_Line_Item__c){
                                StockWrapperNew stockWrap = new StockWrapperNew(WIIS,SPLI);
                                ROLIWrapIN.Incount += SPLI.Quantity__c;
                                if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)){
                                    stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                                }
                                ROLIWrapIN.StockWrapperList.add(stockWrap);
                            }
                        }
                    }
                }
                if(ROLIWrapIN.StockWrapperList.size() == 0){
                    if(mrp.ERP7__MRP_Product__r.Serialise__c != true){
                        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
                        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
                        spliTemp.Quantity__c = (ROLIWrapIN.ROLI.Quantity_Return__c != Null && ROLIWrapIN.lineItemprocessedQuantity != Null)? (ROLIWrapIN.ROLI.Quantity_Return__c * ROLIWrapIN.mrp.ERP7__Total_Amount_Required__c) - ROLIWrapIN.lineItemprocessedQuantity : 0;
                        tspli.add(spliTemp);
                        StockWrapperNew SW = new StockWrapperNew(new Inventory_Stock__c(Active__c = true, Product__c = ROLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = ROLIWrapIN.ROLI.Organisation__c, Name=ROLIWrapIN.ROLI.Name,Checked_In_Date__c=system.today()), spliTemp);
                        ROLIWrapIN.StockWrapperList.add(SW);
                    }else{
                        if(ROLIWrapIN.ROLI.Quantity_Return__c != Null && ROLIWrapIN.lineItemprocessedQuantity != Null){
                            Integer N = Integer.valueof(((ROLIWrapIN.ROLI.Quantity_Return__c * ROLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/ROLIWrapIN.ROLI.Quantity_Return__c) - ROLIWrapIN.lineItemprocessedQuantity);
                            for(Integer i=0; i<N; i++){
                                List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
                                Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
                                spliTemp.Quantity__c = 1;
                                tspli.add(spliTemp);
                                StockWrapperNew SW = new StockWrapperNew(new Inventory_Stock__c(Active__c = true, Product__c = ROLIWrapIN.MRP.ERP7__MRP_Product__c, Organisation__c = ROLIWrapIN.ROLI.Organisation__c, Name=ROLIWrapIN.ROLI.Name,Checked_In_Date__c=system.today()), spliTemp);
                                    SW.SerialNumber.Serial_Number__c = (ROLIWrapIN.ROLI.Starting_Number__c != Null)? ROLIWrapIN.ROLI.Serial_Number_Prefix__c+String.valueof(ROLIWrapIN.ROLI.Starting_Number__c+i) : ROLIWrapIN.ROLI.Serial_Number_Prefix__c;
                                    SW.SerialNumber.Product__c = ROLIWrapIN.MRP.ERP7__MRP_Product__c;
                                ROLIWrapIN.StockWrapperList.add(SW);
                            }
                        }
                    }
                }
                BomsWrapper.add(ROLIWrapIN);
            }
        }
        
        ROLIWrap.Boms = BomsWrapper;
        counter = subcounter = lastcounter = Null;
        return Null;
        
    }
    
    public PageReference cancelPo(){
        String sr = ApexPages.currentPage().getParameters().get('sr');
        PageReference Page;
        if(sr != '' && sr != null) Page = new PageReference('/apex/ERP7__StockReceiving');
        else Page = new PageReference('/'+PO.Id);
        Page.setRedirect(true);
        return Page;
    }
    
    public PageReference ExplodePLI(){
        /*counter :'+counter*/
        PLIWrapper PLIWrap = PLIWrapperList.get(counter);
        counter = subcounter = lastcounter = Null;
        if(Schema.sObjectType.Purchase_Line_Items__c.isUpdateable()) update PLIWrap.PLI; else{ }
        return Null;
    }
    
    public PageReference ExplodeWOLI(){
        /*counter :'+counter*/
        WOLIWrapper WOLIWrap = WOLIWrapperList.get(counter);
        counter = subcounter = lastcounter = Null;
        if(Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) update WOLIWrap.WOLI; else{ }
        return Null;
    }
    
    public PageReference ExplodeSOLI(){
       /*counter :'+counter*/
        RMALIWrapper RMALIWrap = RMALIWrapperList.get(counter);
        counter = subcounter = lastcounter = Null;
        if(Schema.sObjectType.ERP7__RMA_Line_Item__c.isUpdateable()) update RMALIWrap.ROLI; else{ }
        return Null;
    }
    
    public PageReference ExplodeTOLI(){
       /*counter :'+counter*/
        TOLIWrapper TOLIWrap = TOLIWrapperList.get(counter);
        counter = subcounter = lastcounter = Null;
        if(Schema.sObjectType.Transfer_Order_Line_Items__c.isUpdateable()) update TOLIWrap.TOLI; else{ }
        return Null;
    }
    
    public PageReference SavePOLinesReceived(){
    //try{
        List<Purchase_Line_Items__c> PLIS2Upsert = new List<Purchase_Line_Items__c>();  
        Boolean Error = false;
        
        // Calculation Validations
        Boolean isOkmainWrapper = true;
        for(PLIWrapper PLIW : PLIWrapperList){
          PLIW.PLI.Quantity_Received__c +=PLIW.ReceiveQty;
            if(PLIW.ReceiveQty > PLIW.PLI.Remaining_Quantity__c){
                Error = true;
                PLIW.errMsg = 'Quantity Receive cannot be greater than Remaining Quantity';
                isOkmainWrapper = false;
            }
            if(PLIW.PLI.Quantity_Received__c < PLIW.lineItemprocessedQuantity){
                Error = true;
                PLIW.errMsg = 'Quantity Received cannot be less than Quantity added';
                isOkmainWrapper = false;
            }
        }
        if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
        
        // Successful Processing
        if(!Error){
            for(PLIWrapper PLIW : PLIWrapperList){
                PLIS2Upsert.add(PLIW.PLI);
            }
            if(PLIS2Upsert.size() > 0 && Schema.sObjectType.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(PLIS2Upsert); else{ }
            SupplierInventoryCustomContructor();
        }
        //} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }

        return Null;
    }
    
    public PageReference SavePOLines(){
    try{
        List<Purchase_Line_Items__c> PLIS2Upsert = new List<Purchase_Line_Items__c>();                   
        List<Inventory_Stock__c> Stocks2Upsert = new List<Inventory_Stock__c>();                    
        List<Stock_Inward_Line_Item__c> SPLIS2Upsert = new List<Stock_Inward_Line_Item__c>();   
        List<Serial_Number__c> Serials2Upsert = new List<Serial_Number__c>();
        Boolean Error = false;
        
        // Required Validations
        for(PLIWrapper PLIW : PLIWrapperList){
            if(PLIW.PLI.Explode__c != true){ //Product__r.ERP7__Is_Kit__c
                for(StockWrapper WIIS : PLIW.StockWrapperList){
                    WIIS.SP.Site__c = selectedSite;
                    if(PLIW.PLI.Quantity_Received__c == Null || WIIS.stock.Name == '' || WIIS.stock.Name == Null || (PLIW.PLI.Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                        Error = true;
                        PLIW.errMsg = 'Please fill the fields marked as *';
                        break;
                    }
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        if(SPL.Quantity__c == Null || (PLIW.PLI.Product__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                            Error = true;
                            PLIW.errMsg = 'Please fill the fields marked as *';
                            break;
                        }
                    }
                }
            } else{
                for(PLIWrapper PLIW_IN : PLIW.BOMS){
                    for(StockWrapper WIIS : PLIW_IN.StockWrapperList){
                        WIIS.SP.Site__c = selectedSite;
                        if(PLIW_IN.PLI.Quantity_Received__c == Null || WIIS.stock.Name == '' || WIIS.stock.Name == Null || (PLIW_IN.MRP.ERP7__MRP_Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                            Error = true;
                            PLIW_IN.errMsg = 'Please fill the fields marked as *';
                            break;
                        }
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(SPL.Quantity__c == Null || (PLIW_IN.MRP.ERP7__MRP_Product__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                                Error = true;
                                PLIW_IN.errMsg = 'Please fill the fields marked as *';
                                break;
                            }
                        }
                    }
                }
            }
        }
        if(Error) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
         
        // Calculation Validations
        Boolean isOkmainWrapper = true;
        for(PLIWrapper PLIW : PLIWrapperList){
            if(PLIW.PLI.Explode__c != true){
                if(PLIW.PLI.Quantity_Received__c > PLIW.PLI.Quantity__c){
                    Error = true;
                    PLIW.errMsg = 'Quantity Received cannot be greater than actual Quantity';
                    isOkmainWrapper = false;
                }
                if(PLIW.PLI.Quantity_Received__c < PLIW.lineItemprocessedQuantity){
                    Error = true;
                    PLIW.errMsg = 'Quantity Received cannot be less than Quantity added';
                    isOkmainWrapper = false;
                }
                
            } else{
                for(PLIWrapper PLIW_IN : PLIW.BOMS){
                    if(PLIW_IN.PLI.Quantity_Received__c > PLIW_IN.PLI.Quantity__c){
                        Error = true;
                        PLIW_IN.errMsg = 'Quantity Received cannot be greater than actual Quantity';
                        isOkmainWrapper = false;
                    }
                    if(((PLIW_IN.PLI.Quantity_Received__c * PLIW_IN.MRP.ERP7__Total_Amount_Required__c)/PLIW_IN.PLI.Quantity__c) < PLIW_IN.lineItemprocessedQuantity){
                        Error = true;
                        PLIW_IN.errMsg = 'Quantity Received cannot be less than Quantity added';
                        isOkmainWrapper = false;
                    }
                }
            }
        }
        if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
        
        for(PLIWrapper PLIW : PLIWrapperList){
            if(PLIW.PLI.Explode__c != true){
                Decimal subQuantity = 0;
                for(StockWrapper WIIS : PLIW.StockWrapperList){
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        subQuantity += SPL.Quantity__c;
                        if(PLIW.PLI.Product__r.Serialise__c && SPL.Quantity__c > 1){
                            Error = true;
                            PLIW.errMsg = 'Serialised Product cannot have quantity greater than one';
                        }
                    }
                }
                if((PLIW.lineItemprocessedQuantity - PLIW.Incount + subQuantity) > PLIW.PLI.Quantity_Received__c){
                    Error = true;
                    PLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(PLIW.PLI.Quantity_Received__c - (PLIW.lineItemprocessedQuantity - PLIW.Incount));
                }
            } else{
                for(PLIWrapper PLIW_IN : PLIW.BOMS){
                    Decimal subQuantity_IN = 0;
                    for(StockWrapper WIIS : PLIW_IN.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            subQuantity_IN += SPL.Quantity__c;
                            if(PLIW_IN.MRP.ERP7__MRP_Product__r.Serialise__c && SPL.Quantity__c > 1){
                                Error = true;
                                PLIW.errMsg = 'Serialised Product component cannot have quantity greater than one';
                            }
                        }
                    }
                    if((PLIW_IN.lineItemprocessedQuantity - PLIW_IN.Incount + subQuantity_IN) > (PLIW_IN.PLI.Quantity_Received__c)*(PLIW_IN.MRP.ERP7__Total_Amount_Required__c)){
                        Error = true;
                        PLIW_IN.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof((PLIW_IN.PLI.Quantity_Received__c - (PLIW_IN.lineItemprocessedQuantity - PLIW_IN.Incount)*(PLIW_IN.MRP.ERP7__Total_Amount_Required__c)));
                    }
                }
            }
        }
        
       
        // Successful Processing
        if(!Error){
            for(PLIWrapper PLIW : PLIWrapperList){
                PLIS2Upsert.add(PLIW.PLI);
                if(PLIW.PLI.Explode__c != true){
                    PLIW.errMsg = '';
                    for(StockWrapper WIIS : PLIW.StockWrapperList){
                        WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                        //if(WIIS.Stock.Name == Null || WIIS.Stock.Name == '') WIIS.Stock.Name = PLIW.PLI.Product__r.Name;
                        Stocks2Upsert.add(WIIS.Stock);
                        if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                            WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                            Serials2Upsert.add(WIIS.SerialNumber);
                        }
                    }
                } else{
                    for(PLIWrapper PLIW_IN : PLIW.BOMS){
                        PLIW_IN.errMsg = '';
                        for(StockWrapper WIIS : PLIW_IN.StockWrapperList){
                            if(Schema.sobjectType.Inventory_Stock__c.fields.ERP7__Warehouse__c.isAccessible()) WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                            Stocks2Upsert.add(WIIS.Stock);
                            if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                Serials2Upsert.add(WIIS.SerialNumber);
                            }
                        }
                    }
                }
            }
            if(Serials2Upsert.size() > 0 && Schema.sObjectType.Serial_Number__c.isCreateable() && Schema.sObjectType.Serial_Number__c.isUpdateable()) DMLManager.upsertAsUser(Serials2Upsert); else{ }
            if(Stocks2Upsert.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isCreateable() && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) DMLManager.upsertAsUser(Stocks2Upsert); else{ }
           if(SPLIS2Delete.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isDeletable()) DMLManager.deleteAsUser(SPLIS2Delete); else{ }
                if(stocks2Delete.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isDeletable()) DMLManager.deleteAsUser(stocks2Delete); else{ }
            if(PLIS2Upsert.size() > 0 && Schema.sObjectType.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(PLIS2Upsert); else{ }
            
            /*
            List<String> batchLots = new List<String>();
            for(PLIWrapper PLIW : PLIWrapperList){
                Decimal subquant = 0;
                for(StockWrapper WIIS : PLIW.StockWrapperList){
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Batch_Lot_Code__c.isAccessible()) if(SPL.Batch_Lot_Code__c != Null && SPL.Batch_Lot_Code__c != '') batchLots.add(SPL.Batch_Lot_Code__c);
                    }
                }
            }
            batchLots.add('');
            */
                  
            for(PLIWrapper PLIW : PLIWrapperList){
                if(PLIW.PLI.Explode__c != true){
                    Decimal subquant = 0;
                    for(StockWrapper WIIS : PLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(SPL.Name == Null || SPL.Name == '') if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isUpdateable()) SPL.Name = PLIW.PLI.Product__r.Name;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isUpdateable()) SPL.Active__c = true;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isUpdateable()) SPL.Product__c = PLIW.PLI.Product__c;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Line_Items__c.isUpdateable()) SPL.Purchase_Line_Items__c = PLIW.PLI.Id;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) SPL.Purchase_Orders__c = PLIW.PLI.Purchase_Orders__c;
                            if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isUpdateable()) SPL.Unit_Price__c = (PLIW.PLI.Unit_Price__c >= 0)? PLIW.PLI.Unit_Price__c : 0;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Tax__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Tax__c.isUpdateable()) SPL.Tax__c = (PLIW.PLI.Tax__c >= 0)? PLIW.PLI.Tax__c : 0;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isAccessible() && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isAccessible() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Amount__c.isUpdateable()) SPL.Amount__c = SPL.Unit_Price__c * SPL.Quantity__c;//SPL.Unit_Price__c * PLIW.PLI.Quantity__c;
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Tax__c.isAccessible() && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isAccessible() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Total_Tax__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Total_Tax__c.isUpdateable()) SPL.Total_Tax__c = SPL.Tax__c * SPL.Quantity__c;//SPL.Tax__c * PLIW.PLI.Quantity__c
                            if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '' && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isUpdateable()) SPL.Serial__c = WIIS.SerialNumber.Id;
                            SPLIS2Upsert.add(SPL);  
                           if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())  subquant += SPL.Quantity__c;
                        }
                    }
                    PLIW.lineItemprocessedQuantity = PLIW.lineItemprocessedQuantity - PLIW.Incount + subquant;
                    PLIW.Incount = subquant;
                } else{
                    for(PLIWrapper PLIW_IN : PLIW.BOMS){
                        Decimal subquant = 0;
                        for(StockWrapper WIIS : PLIW_IN.StockWrapperList){
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(SPL.Name == Null || SPL.Name == '') if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isUpdateable()) SPL.Name = PLIW_IN.MRP.ERP7__MRP_Product__r.Name;
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isUpdateable()) SPL.Active__c = true;
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isUpdateable()) SPL.Product__c = PLIW_IN.MRP.ERP7__MRP_Product__c;
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Line_Items__c.isUpdateable()) SPL.Purchase_Line_Items__c = PLIW.PLI.Id;
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) SPL.Purchase_Orders__c = PLIW.PLI.Purchase_Orders__c;
                                if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                //if(Schema.sObjectType.Purchase_Line_Items__c.fields.Unit_Price__c.isAccessible()) SPL.Unit_Price__c = (PLIW.PLI.Unit_Price__c >= 0)? PLIW.PLI.Unit_Price__c : 0;
                                //if(Schema.sObjectType.Purchase_Line_Items__c.fields.Tax__c.isAccessible()) SPL.Tax__c = (PLIW.PLI.Tax__c >= 0)? PLIW.PLI.Tax__c : 0;
                                //if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isAccessible() && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isAccessible()) SPL.Amount__c = SPL.Unit_Price__c * PLIW_IN.PLI.Quantity__c;
                                //if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Tax__c.isAccessible() && Schema.sObjectType.Purchase_Line_Items__c.fields.Quantity__c.isAccessible()) SPL.Total_Tax__c = SPL.Tax__c * PLIW_IN.PLI.Quantity__c;
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '' && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isUpdateable()) SPL.Serial__c = WIIS.SerialNumber.Id;
                                SPLIS2Upsert.add(SPL);  
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subquant += SPL.Quantity__c;
                            }
                        }
                        PLIW_IN.lineItemprocessedQuantity = PLIW_IN.lineItemprocessedQuantity - PLIW_IN.Incount + subquant;
                        PLIW_IN.Incount = subquant;
                    }
                }
            }
            if(SPLIS2Upsert.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.isUpdateable()){hasAccess=true; upsert SPLIS2Upsert;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
            ErrMsg = '';
            //SupplierInventoryCustomContructor();
            //putaway();
        }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }

        return Null;
    }
    
    
    ////////////// Manufacture Inventory ///////////////////////
    
    public Void ManufacturingInventoryCustomContructor(){
        schemaMap = Schema.getglobalDescribe();
        WOLIWrapperList = new List<WOLIWrapper>();
        SPLIS2Delete = new List<Stock_Inward_Line_Item__c>();
        stocks2Delete = new List<Inventory_Stock__c>();
        lineItemprocessedQuantities = new Map<String, Decimal>();
        
        String allFields = fetchAllFields('ERP7__WO__c');
        UtilClass.FlSCheck(allFields.split(',') ,'ERP7__WO__c');
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ' , Channel__r.Organisation__c from ERP7__WO__c where Id in : woIds';
        List<ERP7__WO__c> WOs = Database.query(query);
        
        
        orderNames = new Map<Id,String>();
        if(WOs.size() > 0) WO = WOs[0];
        for(ERP7__WO__c WO : WOs){ 
            orderNames.put(WO.Id, WO.Name);
        }
        
        String allFields1 = fetchAllFields('ERP7__Work_Order_Line_Items__c');
        UtilClass.FlSCheck(allFields1.split(',') ,'ERP7__Work_Order_Line_Items__c');
        allFields1 += ', Work_Orders__r.Name, Product__r.Name'+', Product__r.Picture__c, Product__r.ERP7__Is_Kit__c, Product__r.ERP7__Kit_Protected__c'+', Product__r.Preview_Image__c, Product__r.Lot_Tracked__c, Product__r.Serialise__c';
        String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Work_Order_Line_Items__c where Work_Orders__c in : woIds And Product__c != Null order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isAccessible()) Wolis = Database.query(query1);
        
        List<String> productIds = new List<String>();
        List<String> WOLIIds = new List<String>();
        for(Work_Order_Line_Items__c woli : Wolis){
            if(woli.Product__c != Null) if(Schema.sobjectType.Work_Order_Line_Items__c.fields.Product__c.isAccessible()) productIds.add(Woli.Product__c);
            WOLIIds.add(woli.Id);
        }
        
        MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, ERP7__MRP_Product__r.Lot_Tracked__c, ERP7__MRP_Product__r.Serialise__c, ERP7__Purchase_Line_Items__c, ERP7__Work_Order_Line_Items__c,  RecordType.Name From ERP7__MRP__c Where ERP7__Work_Order_Line_Items__c In :WOLIIds And RecordType.Name = 'MRP Kit'];
        
        String allFields3 = fetchAllFields('ERP7__Stock_Inward_Line_Item__c');
        UtilClass.FlSCheck(allFields3.split(',') ,'ERP7__Stock_Inward_Line_Item__c');
        String query3 = 'select ' + String.escapeSingleQuotes(allFields3) + ' from ERP7__Stock_Inward_Line_Item__c where Work_Order_Line_Items__c In :WOLIIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isAccessible()) SPLIS = Database.query(query3);
        
     
        for(Work_Order_Line_Items__c woli : Wolis){
            Decimal quantityProcessed = 0;
            if(woli.Explode__c != true){
                for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                    if(SPLI.Work_Order_Line_Items__c == woli.Id && SPLI.Quantity__c != Null){
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                    }
                }
            }
            lineItemprocessedQuantities.put(woli.Id, quantityProcessed);
        }
        
        List<Id> stockIds = new List<Id>();
        List<Id> serialIds = new List<Id>();
        
        for(Stock_Inward_Line_Item__c SPLI : SPLIS){
            if(SPLI.Sales_Order_Line_Item__c == Null) stockIds.add(SPLI.Site_ProductService_InventoryStock__c);
            if(SPLI.Serial__c != Null)  serialIds.add(SPLI.Serial__c);
        }
        SerialMap = new Map<Id,Serial_Number__c>([Select Id, Name, Serial_Number__c, Product__c from Serial_Number__c Where Id In :serialIds]);
        
        
        if(WO.Sales_Order__c != Null){
            Id soId = WO.Sales_Order__c;
            String allFieldsPPLI = fetchAllFields('ERP7__Stock_Outward_Line_Item__c');
            UtilClass.FlSCheck(allFieldsPPLI.split(',') ,'ERP7__Stock_Outward_Line_Item__c');
            allFieldsPPLI += ', Sales_Order_Line_Item__r.Sales_Order__c';
            String queryppli = 'select ' + String.escapeSingleQuotes(allFieldsPPLI) + ' from ERP7__Stock_Outward_Line_Item__c where Sales_Order_Line_Item__r.Sales_Order__c = :soId order by CreatedDate ASC';
            if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isAccessible()) PPLIs2Update = Database.query(queryppli);
        }
        for(Stock_Outward_Line_Item__c PPLI : PPLIs2Update){
            if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isAccessible()) stockIds.add(PPLI.Site_Product_Service_Inventory_Stock__c);
        }
        
        
        String allFields2 = fetchAllFields('ERP7__Inventory_Stock__c');
        UtilClass.FlSCheck(allFields2.split(',') ,'ERP7__Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name';
        String query2 = 'select ' + String.escapeSingleQuotes(allFields2) + ' from ERP7__Inventory_Stock__c where Id In :stockIds order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.isAccessible()) warehouseStocks = Database.query(query2);
        
        String allFields4 = fetchAllFields('ERP7__Site__c');
        UtilClass.FlSCheck(allFields4.split(',') ,'ERP7__Site__c');
        String org = WO.Channel__r.Organisation__c;
        String query4 = 'select ' + String.escapeSingleQuotes(allFields4) + ' from ERP7__Site__c where Organisation__c  =: org and Active__c = true order by CreatedDate ASC';
        if(Schema.sObjectType.ERP7__Site__c.isAccessible()) Sites = Database.query(query4);
        
        
        stockLines = new Map<Inventory_Stock__c, List<Stock_Inward_Line_Item__c>>();
        for(Inventory_Stock__c WIIS : warehouseStocks){
            List<Stock_Inward_Line_Item__c> mySPLIS = new List<Stock_Inward_Line_Item__c>();
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                if(WIIS.Id == SPLI.Site_ProductService_InventoryStock__c && SPLI.Sales_Order_Line_Item__c == Null){
                    mySPLIS.add(SPLI);
                    break;
                }
            }  
            stockLines.put(WIIS, mySPLIS);
        }
        
        List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Wolis Order By CreatedDate Asc];
        Map<Id,Attachment> WOLIAttachment = new Map<Id,Attachment>();
        for(Attachment A : Attachments) WOLIAttachment.put(A.ParentId,A);
        
        for(ERP7__Work_Order_Line_Items__c woli : Wolis){
            WOLIWrapper WOLIWrap = new WOLIWrapper(woli);
            WOLIWrap.attach = (WOLIAttachment.ContainsKey(woli.Id))? WOLIAttachment.get(woli.Id) : new Attachment();
            WOLIWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(woli.Id);
            WOLIWrap.Incount  = 0;
            for(Inventory_Stock__c WIIS : warehouseStocks){
                if(woli.Product__c == WIIS.Product__c){
                    for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS)){
                        if(SPLI.Product__c == woli.Product__c && woli.Id == SPLI.ERP7__Work_Order_Line_Items__c){
                            StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS));
                            stockWrap.SP.Site__c = WIIS.Warehouse__c;
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) WOLIWrap.Incount += SPLI.Quantity__c;
                            if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                            WOLIWrap.StockWrapperList.add(stockWrap); 
                            //break;
                        }
                    }
                    
                }
            }
            WOLIWrapperList.add(WOLIWrap);
        }
        
    }
    
    public PageReference AddManufacturedStock(){
        /*counter :'+counter*/
        WOLIWrapper WOLIWrap = WOLIWrapperList.get(counter);
        List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
        Stock_Inward_Line_Item__c spliTemp = new Stock_Inward_Line_Item__c();
        spliTemp.Batch_Lot_Code__c = (WOLIWrap.WOLI.Batch_Lot_Code__c != Null)? WOLIWrap.WOLI.Batch_Lot_Code__c : '';
        if(WOLIWrap.WOLI.Product__r.Serialise__c != true) spliTemp.Quantity__c = (WOLIWrap.WOLI.Quantity__c != Null && WOLIWrap.lineItemprocessedQuantity != Null)? WOLIWrap.WOLI.Quantity__c-WOLIWrap.lineItemprocessedQuantity : 0;
        if(WOLIWrap.WOLI.Product__r.Serialise__c == true) spliTemp.Quantity__c = 1;
        tspli.add(spliTemp);
        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = WOLIWrap.woli.Product__c, Organisation__c = WOLIWrap.woli.Organisation__c, Name=WOLIWrap.WOLI.Name,Checked_In_Date__c=system.today()), tspli);
        if(WOLIWrap.WOLI.Product__r.Serialise__c == true){
            SW.SerialNumber.Serial_Number__c = (WOLIWrap.WOLI.Starting_Number__c != Null)? WOLIWrap.WOLI.Serial_Number_Prefix__c+String.valueof(WOLIWrap.WOLI.Starting_Number__c+WOLIWrap.StockWrapperList.size()) : WOLIWrap.WOLI.Serial_Number_Prefix__c;
            SW.SerialNumber.Product__c = WOLIWrap.WOLI.Product__c;
        }
        
        WOLIWrap.StockWrapperList.add(SW);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference RemoveManufacturedStock(){
        StockWrapper SW = (lastcounter != Null)? WOLIWrapperList.get(lastcounter).BOMS.get(counter).StockWrapperList.remove(subcounter) : WOLIWrapperList.get(counter).StockWrapperList.remove(subcounter);
        if(SW.stock.Id != Null) stocks2Delete.add(SW.stock);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    
    public PageReference AddManufacturedItem(){
        Stock_Inward_Line_Item__c SPLITemp = new Stock_Inward_Line_Item__c();
         if(WO.Sales_Order__c != Null) if(Schema.sobjectType.WO__c.fields.Sales_Order__c.isAccessible()) SPLITemp.Sales_Order__c = WO.Sales_Order__c;
        WOLIWrapperList.get(counter).StockWrapperList.get(subcounter).SPLI.add(SPLITemp);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference RemoveManufacturedItem(){
        WOLIWrapper WLIW = WOLIWrapperList.get(counter);
        Stock_Inward_Line_Item__c spli = WOLIWrapperList.get(counter).StockWrapperList.get(subcounter).SPLI.remove(lastcounter);
        if(spli.Id != Null) SPLIS2Delete.add(spli);
        counter = subcounter = lastcounter = Null;
        return Null;
    }
    
    public PageReference cancelWo(){
         String sr = ApexPages.currentPage().getParameters().get('sr');
        PageReference Page;
        if(sr != '' && sr != null) Page = new PageReference('/apex/ERP7__StockReceiving');
        else Page = new PageReference('/'+WO.Id);
        Page.setRedirect(true);
        return Page;
    }
    
    public PageReference SaveTOLinesReceived(){
        try{
            List<Transfer_Order_Line_Items__c> TOLIS2Upsert = new List<Transfer_Order_Line_Items__c>();                   
           
            Boolean Error = false;
            
            
            // Calculation Validations
            Boolean isOkmainWrapper = true;
            for(TOLIWrapper TOLIW : TOLIWrapperList){
                if(!(TOLIW.TOLI.ERP7__Quantity_requested__c > 0)){
                    Error = true;
                    TOLIW.errMsg = 'Quantity Unavailable';
                    isOkmainWrapper = false;
                }
            }
            if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            for(TOLIWrapper TOLIW : TOLIWrapperList){
                if(TOLIW.lineItemprocessedQuantity > TOLIW.TOLI.ERP7__Quantity_requested__c){
                    Error = true;
                    TOLIW.errMsg = 'Quantity Received cannot be less than Quantity added';
                    isOkmainWrapper = false;
                }
            }
            
            // Successful Processing
            if(!Error){
                for(TOLIWrapper TOLIW : TOLIWrapperList){
                    TOLIW.errMsg = '';
                    TOLIS2Upsert.add(TOLIW.TOLI);
                }
                if(Schema.sObjectType.Transfer_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Transfer_Order_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(TOLIS2Upsert); else{ }
                ErrMsg = '';
                ManufacturingInventoryCustomContructor();
            } 
        }catch(exception e){}
        return Null;
    }
    
    
     public PageReference SaveWOLinesReceived(){
        try{
            List<Work_Order_Line_Items__c> WOLIS2Upsert = new List<Work_Order_Line_Items__c>();                   
           
            Boolean Error = false;
            
            
            // Calculation Validations
            Boolean isOkmainWrapper = true;
            for(WOLIWrapper WOLIW : WOLIWrapperList){
                if(!(WOLIW.WOLI.Quantity__c > 0)){
                    Error = true;
                    WOLIW.errMsg = 'Quantity Unavailable';
                    isOkmainWrapper = false;
                }
            }
            if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            for(WOLIWrapper WOLIW : WOLIWrapperList){
                if(WOLIW.lineItemprocessedQuantity > WOLIW.WOLI.Quantity__c){
                    Error = true;
                    WOLIW.errMsg = 'Quantity Received cannot be less than Quantity added';
                    isOkmainWrapper = false;
                }
            }
            
            // Successful Processing
            if(!Error){
                for(WOLIWrapper WOLIW : WOLIWrapperList){
                    WOLIW.errMsg = '';
                    WOLIS2Upsert.add(WOLIW.WOLI);
                }
                if(Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(WOLIS2Upsert); else{ }
                ErrMsg = '';
                ManufacturingInventoryCustomContructor();
            } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference SaveWOLines(){
        try{
            List<Work_Order_Line_Items__c> WOLIS2Upsert = new List<Work_Order_Line_Items__c>();                   
            List<Inventory_Stock__c> Stocks2Upsert = new List<Inventory_Stock__c>();                    
            List<Stock_Inward_Line_Item__c> SPLIS2Upsert = new List<Stock_Inward_Line_Item__c>();
            List<Serial_Number__c> Serials2Upsert = new List<Serial_Number__c>();    
            Boolean Error = false;
            // Required Validations
            for(WOLIWrapper WOLIW : WOLIWrapperList){
                if(WOLIW.WOLI.Explode__c != true){ //Product__r.ERP7__Is_Kit__c
                    for(StockWrapper WIIS : WOLIW.StockWrapperList){
                        WIIS.SP.Site__c = selectedSite;
                        if(WIIS.stock.Name == '' || WIIS.stock.Name == Null || WIIS.SP.Site__c == Null || (WOLIW.WOLI.Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                            Error = true;
                            WOLIW.errMsg = 'Please fill the fields marked as *';
                        }
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(SPL.Quantity__c == Null || (WOLIW.WOLI.Product__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                                Error = true;
                                WOLIW.errMsg = 'Please fill the fields marked as *';
                             }
                        }
                    }
                } else {
                    for(WOLIWrapper WOLI_IN : WOLIW.BOMS){
                        for(StockWrapper WIIS : WOLI_IN.StockWrapperList){
                            WIIS.SP.Site__c = selectedSite;
                            if(WIIS.stock.Name == '' || WIIS.stock.Name == Null || WIIS.SP.Site__c == Null|| (WOLI_IN.MRP.ERP7__MRP_Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){
                                Error = true;
                                WOLIW.errMsg = 'Please fill the fields marked as *';
                                }
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(SPL.Quantity__c == Null  || (WOLIW.MRP.ERP7__MRP_Product__r.Lot_Tracked__c && SPL.ERP7__Material_Batch_Lot__c == Null)){
                                    Error = true;
                                    WOLIW.errMsg = 'Please fill the fields marked as *';
                                 }
                            }
                        }
                    }
                }
            }
            if(Error) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            
            // Calculation Validations
            Boolean isOkmainWrapper = true;
            for(WOLIWrapper WOLIW : WOLIWrapperList){
                if(WOLIW.WOLI.Explode__c != true){
                    if(!(WOLIW.WOLI.Quantity__c > 0)){
                        Error = true;
                        WOLIW.errMsg = 'Quantity Unavailable';
                        isOkmainWrapper = false;
                    }
                } else{
                    for(WOLIWrapper WOLI_IN : WOLIW.BOMS){
                        if(!(WOLI_IN.WOLI.Quantity__c > 0)){
                            Error = true;
                            WOLI_IN.errMsg = 'Quantity Unavailable';
                            isOkmainWrapper = false;
                        }
                    }
                }
            }
            if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below'; return Null; }
            for(WOLIWrapper WOLIW : WOLIWrapperList){
                if(WOLIW.WOLI.Explode__c != true){
                    Decimal subQuantity = 0; 
                    for(StockWrapper WIIS : WOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subQuantity += SPL.Quantity__c;
                        }
                    }
                    if((WOLIW.lineItemprocessedQuantity - WOLIW.Incount + subQuantity) > WOLIW.WOLI.Quantity__c){
                        Error = true;
                        WOLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(WOLIW.WOLI.Quantity__c - (WOLIW.lineItemprocessedQuantity - WOLIW.Incount));
                    }
                } else{  
                        for(WOLIWrapper WOLI_IN : WOLIW.BOMS){
                            Decimal subQuantity = 0; 
                            for(StockWrapper WIIS : WOLI_IN.StockWrapperList){
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) subQuantity += SPL.Quantity__c;
                                }
                            }
                            if((WOLI_IN.lineItemprocessedQuantity - WOLI_IN.Incount + subQuantity) > (WOLI_IN.WOLI.Quantity__c * WOLI_IN.mrp.ERP7__Total_Amount_Required__c)){
                                Error = true;
                                WOLI_IN.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(WOLI_IN.WOLI.Quantity__c - (WOLI_IN.lineItemprocessedQuantity - WOLI_IN.Incount));
                            }
                        }
                } 
            }
            
            // Successful Processing
            if(!Error){
                for(WOLIWrapper WOLIW : WOLIWrapperList){
                    WOLIS2Upsert.add(WOLIW.WOLI);
                    if(WOLIW.WOLI.Explode__c != true){
                        WOLIW.errMsg = '';
                        for(StockWrapper WIIS : WOLIW.StockWrapperList){
                            if(Schema.sobjectType.Inventory_Stock__c.fields.Warehouse__c.isAccessible()) WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                            Stocks2Upsert.add(WIIS.Stock);
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                Serials2Upsert.add(WIIS.SerialNumber);
                            }
                        }
                    } else{  
                        for(WOLIWrapper WOLI_IN : WOLIW.BOMS){
                            WOLIW.errMsg = '';
                            for(StockWrapper WIIS : WOLI_IN.StockWrapperList){
                                if(Schema.sobjectType.Inventory_Stock__c.fields.Warehouse__c.isAccessible()) WIIS.Stock.Warehouse__c = WIIS.SP.Site__c;
                                Stocks2Upsert.add(WIIS.Stock);
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                    WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                    Serials2Upsert.add(WIIS.SerialNumber);
                                }
                            } 
                        }
                    }
                }
                //DMLManager.upsertAsUser(WO);
                if(Serials2Upsert.size() > 0 && Schema.sObjectType.Serial_Number__c.isCreateable() && Schema.sObjectType.Serial_Number__c.isUpdateable()) DMLManager.upsertAsUser(Serials2Upsert); else{ }
                if(Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(WOLIS2Upsert); else{ }
                if(Schema.sObjectType.Inventory_Stock__c.isCreateable() && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) DMLManager.upsertAsUser(Stocks2Upsert); else{ }
                if(SPLIS2Delete.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isDeletable()) DMLManager.deleteAsUser(SPLIS2Delete); else{ }
                if(stocks2Delete.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isDeletable()) DMLManager.deleteAsUser(stocks2Delete); else{ }
                
                /*
                List<String> batchLots = new List<String>();
                for(WOLIWrapper WOLIW : WOLIWrapperList){
                    Decimal subquant = 0;
                    for(StockWrapper WIIS : WOLIW.StockWrapperList){
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Batch_Lot_Code__c.isAccessible()) if(SPL.Batch_Lot_Code__c != Null && SPL.Batch_Lot_Code__c != '') batchLots.add(SPL.Batch_Lot_Code__c);
                        }
                    }
                }
                batchLots.add('');
                */
                //startitfromhere
                for(WOLIWrapper WOLIW : WOLIWrapperList){
                    if(WOLIW.WOLI.Explode__c != true){
                        /*WOLIW No Explode: */
                        Decimal subquant = 0;
                        for(StockWrapper WIIS : WOLIW.StockWrapperList){
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                                if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Product__c.isAccessible())SPL.Product__c = WOLIW.WOLI.Product__c;
                                if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                if(Schema.sObjectType.Work_Order_Line_Items__c.isAccessible())SPL.Work_Order_Line_Items__c = WOLIW.WOLI.Id;
                                if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Quantity__c.isAccessible())SPL.Unit_Price__c = (WOLIW.WOLI.Total_Cost__c >= 0 && WOLIW.WOLI.Quantity__c > 0)? WOLIW.WOLI.Total_Cost__c/WOLIW.WOLI.Quantity__c : 0;
                                if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Total_Cost__c.isAccessible())SPL.Amount__c = WOLIW.WOLI.Total_Cost__c;
                                if(Schema.sObjectType.Work_Order_Line_Items__c.fields.BoM__c.isAccessible())SPL.BoM__c = WOLIW.WOLI.BoM__c;
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') SPL.Serial__c = WIIS.SerialNumber.Id;
                                SPLIS2Upsert.add(SPL);
                                if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())  subquant += SPL.Quantity__c;
                            }
                        }
                        WOLIW.lineItemprocessedQuantity = WOLIW.lineItemprocessedQuantity - WOLIW.Incount + subquant;
                        WOLIW.Incount = subquant;
                    } else{ 
                        for(WOLIWrapper WOLI_IN : WOLIW.BOMS){
                           
                            Decimal subquant = 0;
                            for(StockWrapper WIIS : WOLI_IN.StockWrapperList){
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isAccessible()) SPL.Active__c = true;
                                     if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Product__c.isAccessible())SPL.Product__c = WOLI_IN.MRP.ERP7__MRP_Product__c;
                                    if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                    if(Schema.sObjectType.Work_Order_Line_Items__c.isAccessible())SPL.Work_Order_Line_Items__c = WOLIW.WOLI.Id;
                                    //if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Total_Cost__c.isAccessible() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Quantity__c.isAccessible())SPL.Unit_Price__c = (WOLIW.WOLI.Total_Cost__c >= 0 && WOLIW.WOLI.Quantity__c > 0)? WOLIW.WOLI.Total_Cost__c/WOLIW.WOLI.Quantity__c : 0;
                                    //if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Total_Cost__c.isAccessible())SPL.Amount__c = WOLIW.WOLI.Total_Cost__c;
                                    //if(Schema.sObjectType.Work_Order_Line_Items__c.fields.BoM__c.isAccessible())SPL.BoM__c = WOLIW.WOLI.BoM__c;
                                    if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') SPL.Serial__c = WIIS.SerialNumber.Id;
                                    SPLIS2Upsert.add(SPL);
                                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())  subquant += SPL.Quantity__c;
                                }
                            }
                            WOLI_IN.lineItemprocessedQuantity = WOLI_IN.lineItemprocessedQuantity - WOLI_IN.Incount + subquant;
                            WOLI_IN.Incount = subquant;
                        }
                    }
                }
                
                if(SPLIS2Upsert.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.isUpdateable()) DMLManager.upsertAsUser(SPLIS2Upsert);
                ErrMsg = '';
                //ManufacturingInventoryCustomContructor();
            } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public class PLIWrapper {
        public Purchase_Line_Items__c PLI                             { get; set; } 
        public List<StockWrapper> StockWrapperList                    { get; set; }
        public Attachment attach                                      { get; set; }
        public String  errMsg                                         { get; set; }
        public Decimal lineItemprocessedQuantity                      { get; set; } 
        public Decimal Incount                                        { get; set; }
        public Decimal ReceiveQty                                     { get; set; }
        public Boolean collaps                                        { get; set; } 
        public Boolean selected                                       { get; set; }
        public List<PLIWrapper> BOMS                                  { get; set; }
        public ERP7__BOM__c BOM                                       { get; set; }
        public ERP7__MRP__c MRP                                       { get; set; }
        
        
        public PLIWrapper(ERP7__Purchase_Line_Items__c PLI) {
            this.PLI = PLI;
            attach = new attachment();
            StockWrapperList = new List<StockWrapper>();
            this.errMsg = '';
            Incount = 0;
            ReceiveQty = PLI.Remaining_Quantity__c;
            lineItemprocessedQuantity = 0;
            collaps = false;
            selected = false;
            BOMS = new List<PLIWrapper>();
            BOM = new ERP7__BOM__c();
            MRP = new ERP7__MRP__c();
        }
    }
    
    public class WOLIWrapper {
        public Work_Order_Line_Items__c WOLI                          { get; set; } 
        public Attachment attach                                      { get; set; }
        public List<StockWrapper> StockWrapperList                    { get; set; }
        public String  errMsg                                         { get; set; }
        public Decimal lineItemprocessedQuantity                      { get; set; } 
        public Decimal Incount                                        { get; set; } 
        public Boolean collaps                                        { get; set; }
        public Boolean selected                                       { get; set; } 
        public List<WOLIWrapper> BOMS                                 { get; set; }
        public ERP7__BOM__c BOM                                       { get; set; }
        public ERP7__MRP__c MRP                                       { get; set; }
        
        public WOLIWrapper(Work_Order_Line_Items__c WOLI) {
            this.WOLI = WOLI;
            StockWrapperList = new List<StockWrapper>();
            attach = new attachment();
            this.errMsg = '';
            Incount = 0;
            lineItemprocessedQuantity = 0;
            collaps = false;
            selected = false;
            BOMS = new List<WOLIWrapper>();
            BOM = new ERP7__BOM__c();
            MRP = new ERP7__MRP__c();
        }
    }
    
    public class RMALIWrapper {
        public ERP7__RMA_Line_Item__c ROLI                            { get; set; } 
        public Attachment attach                                      { get; set; }
        public List<StockWrapperNew> StockWrapperList                 { get; set; }
        public String  errMsg                                         { get; set; }
        public Decimal lineItemprocessedQuantity                      { get; set; } 
        public Decimal Incount                                        { get; set; }
        public Boolean collaps                                        { get; set; } 
        public Boolean selected                                       { get; set; } 
        public List<RMALIWrapper> BOMS                                { get; set; }
        public ERP7__BOM__c BOM                                       { get; set; }
        public ERP7__MRP__c MRP                                       { get; set; }
        
        public RMALIWrapper(ERP7__RMA_Line_Item__c RMALI) {
            this.ROLI = RMALI;
            StockWrapperList = new List<StockWrapperNew>();
            attach = new attachment();
            this.errMsg = '';
            Incount = 0;
            lineItemprocessedQuantity = 0;
            collaps = false;
            selected = false;
            BOMS = new List<RMALIWrapper>();
            BOM = new ERP7__BOM__c();
            MRP = new ERP7__MRP__c();
        }
    }
    
    public class TOLIWrapper {
        public Transfer_Order_Line_Items__c TOLI                      { get; set; }
        public Attachment attach                                      { get; set; } 
        public List<StockWrapper> StockWrapperList                    { get; set; }
        public String  errMsg                                         { get; set; }
        public Decimal lineItemprocessedQuantity                      { get; set; } 
        public Decimal Incount                                        { get; set; } 
        public Boolean collaps                                        { get; set; }
        public Boolean selected                                       { get; set; } 
        public List<TOLIWrapper> BOMS                                 { get; set; }
        public ERP7__BOM__c BOM                                       { get; set; }
        public ERP7__MRP__c MRP                                       { get; set; }
        
        public TOLIWrapper(Transfer_Order_Line_Items__c TOLI) {
            this.TOLI = TOLI;
            StockWrapperList = new List<StockWrapper>();
            this.errMsg = '';
            attach = new attachment();
            Incount = 0;
            lineItemprocessedQuantity = 0;
            collaps = false;
            selected = false;
            BOMS = new List<TOLIWrapper>();
            BOM = new ERP7__BOM__c();
            MRP = new ERP7__MRP__c();
        }
    }
    
    public class StockWrapper {
        public Inventory_Stock__c Stock                { get; set; }            
        public List<Stock_Inward_Line_Item__c> SPLI    { get; set; }  
        public Channel__c  SP                          { get; set; } 
        public ERP7__Serial_Number__c SerialNumber     { get; set; }
        
        public StockWrapper(Inventory_Stock__c WIIS, List<Stock_Inward_Line_Item__c> SPLI) {
            this.Stock = WIIS;
            this.SPLI = SPLI;
            if(!(SPLI.size() > 0)) this.SPLI.add(new Stock_Inward_Line_Item__c());
            this.SP = new Channel__c();
            SerialNumber = new ERP7__Serial_Number__c();
        }
    }
    
    public class StockWrapperNew {
        public Inventory_Stock__c Stock                { get; set; }            
        public List<Stock_Inward_Line_Item__c> SPLI    { get; set; }  
        public Channel__c  SP                          { get; set; } 
        public ERP7__Serial_Number__c SerialNumber     { get; set; }
        
        
        public StockWrapperNew(Inventory_Stock__c WIIS, Stock_Inward_Line_Item__c SPLI) {
            this.Stock = WIIS;
            this.SPLI = new List<Stock_Inward_Line_Item__c>();
            this.SPLI.add(SPLI);
            this.SP = new Channel__c();
            SerialNumber = new ERP7__Serial_Number__c();
        }
    }
    
   
    public pageReference scannerMethodSupplier() {
         ErrMsg = '';
        DisMsg = '';
        if(barcode.trim() == 'StockReceiving'){ return Back2StockReceiving(); }
        if(barcode.trim() == 'Save'){ return SavePOLines(); }
        if(randonScannedStock != Null){
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
             
            if(Schema.sObjectType.Site__c.isAccessible()) siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.Location__c.isAccessible()) SSLList = [Select Id, Name, Barcode__c, Site__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.StorageContainer__c.isAccessible()) binList = [Select Id, Name, Barcode__c, Site__c, Location__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];   
            
            if(binList.size() > 0) { 
                if(Schema.sobjectType.StorageContainer__c.isAccessible()) randonScannedStock.Stock.StorageContainer__c = binList[0].Id;
                if(Schema.sobjectType.StorageContainer__c.fields.Location__c.isAccessible()) randonScannedStock.Stock.Location__c = binList[0].Location__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = binList[0].Site__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStock.SP.Site__c = binList[0].Site__c;
            }
            else if(SSLList.size() > 0){
                if(Schema.sobjectType.Location__c.isAccessible()) randonScannedStock.Stock.Location__c = SSLList[0].Id;
                if(Schema.sobjectType.Location__c.fields.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = SSLList[0].Site__c;
                if(Schema.sobjectType.Location__c.fields.Site__c.isAccessible()) randonScannedStock.SP.Site__c = SSLList[0].Site__c;
            }
            else if(siteList.size() > 0){
                 if(Schema.sobjectType.Site__c.isAccessible())  randonScannedStock.Stock.Warehouse__c = siteList[0].Id;
                 if(Schema.sobjectType.Site__c.isAccessible())  randonScannedStock.SP.Site__c = siteList[0].Id;
            }
            DisMsg = '';
            if(binList.size() > 0 || SSLList.size() > 0 || siteList.size() > 0) return null;
           }
        //if stock wrapper not null search for location and populate else assign null it and proceed
        
        itemFoundOnScan = false;
        List<Product2> productList;
        if(Schema.sObjectType.Product2.isAccessible()) productList = [select id, name, Barcode__c from Product2 where Barcode__c =: barcode.trim() Limit 1];
        if(productList.size() > 0) 
            addQuantityScannerSupplier(JSON.serialize(productList[0])); 
        else ErrMsg = 'Product not found';
        return null;
    }   
    
    public pageReference addQuantityScannerSupplier(String product1) {
        Product2 product = (Product2)JSON.deserialize(product1, Product2.class);
        String productId = product.Id;
         Boolean Error = false;
        ErrMsg = '';
        Boolean exist = false;
        for(PLIWrapper PLIW : PLIWrapperList){
            if(PLIW.PLI.Product__c == productId) barcode = '#'+productId;
            
            if(PLIW.PLI.Product__c == productId && PLIW.PLI.Quantity_Received__c > 0 && PLIW.PLI.Quantity__c > 0 && PLIW.PLI.Quantity_Received__c <= PLIW.PLI.Quantity__c && PLIW.lineItemprocessedQuantity < PLIW.PLI.Quantity_Received__c){
                Decimal subQuantity = 0; 
                for(StockWrapper WIIS : PLIW.StockWrapperList){
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c != Null) subQuantity += SPL.Quantity__c;
                    }
                }
                 if((PLIW.lineItemprocessedQuantity - PLIW.Incount + subQuantity) > PLIW.PLI.Quantity_Received__c){
                    Error = true;
                    PLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(PLIW.PLI.Quantity_Received__c - (PLIW.lineItemprocessedQuantity - PLIW.Incount));
                  }
                
                
                if(!Error){
                    if(!(PLIW.StockWrapperList.size() > 0)){
                        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = PLIW.pli.Product__c, Organisation__c = PLIW.pli.Organisation__c, Name=PLIW.pli.Name,Checked_In_Date__c=system.today()), new List<Stock_Inward_Line_Item__c>());
                        PLIW.StockWrapperList.add(SW);
                    }
                    if(!(PLIW.StockWrapperList[0].SPLI.size() > 0)) 
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.isAccessible()) PLIW.StockWrapperList[0].SPLI.add(new Stock_Inward_Line_Item__c());
                    
                    Stock_Inward_Line_Item__c SPL = PLIW.StockWrapperList[0].SPLI[0];
                    
                    SPL.Batch_Lot_Code__c = (PLIW.pli.Batch_Lot_Code__c != Null)? PLIW.pli.Batch_Lot_Code__c : '';
                    
                     SPL.Quantity__c = (PLIW.PLI.Quantity_Received__c != Null)? PLIW.PLI.Quantity_Received__c : 0;
                    
                    PLIW.lineItemprocessedQuantity = SPL.Quantity__c;
                    PLIW.Incount = PLIW.lineItemprocessedQuantity;
                }
                randonScannedStock = PLIW.StockWrapperList[0];
                DisMsg = 'Product "'+PLIW.PLI.Product__r.Name+'" found please scan the location';
                exist = true;
                barcode = '#'+PLIW.PLI.Id;
                itemFoundOnScan = true;
                break;
            }
        }
        if(Error) ErrMsg = 'Please verify the errors below';
        if(!exist) { ErrMsg = 'Product not found or its already added to the inventory'; DisMsg = ''; randonScannedStock = Null;} 
        return null;
    }
    
    public pageReference scannerMethodManufacturing() {
         ErrMsg = '';
        DisMsg = '';
        if(barcode.trim() == 'StockReceiving'){ return Back2StockReceiving(); }
        if(barcode.trim() == 'Save'){ return SaveWOLines(); }
        if(randonScannedStock != Null){
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
             
            if(Schema.sObjectType.Site__c.isAccessible()) siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.Location__c.isAccessible()) SSLList = [Select Id, Name, Barcode__c, Site__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.StorageContainer__c.isAccessible()) binList = [Select Id, Name, Barcode__c, Site__c, Location__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];   
            
            if(binList.size() > 0) { 
                if(Schema.sobjectType.StorageContainer__c.isAccessible()) randonScannedStock.Stock.StorageContainer__c = binList[0].Id;
                if(Schema.sobjectType.StorageContainer__c.fields.Location__c.isAccessible()) randonScannedStock.Stock.Location__c = binList[0].Location__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = binList[0].Site__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStock.SP.Site__c = binList[0].Site__c;
            }
            else if(SSLList.size() > 0){
                if(Schema.sobjectType.Location__c.isAccessible()) randonScannedStock.Stock.Location__c = SSLList[0].Id;
                if(Schema.sobjectType.Location__c.fields.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = SSLList[0].Site__c;
                if(Schema.sobjectType.Location__c.fields.Site__c.isAccessible()) randonScannedStock.SP.Site__c = SSLList[0].Site__c;
            }
            else if(siteList.size() > 0){
                if(Schema.sobjectType.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = siteList[0].Id;
                if(Schema.sobjectType.Site__c.isAccessible()) randonScannedStock.SP.Site__c = siteList[0].Id;
            }
            DisMsg = '';
            if(binList.size() > 0 || SSLList.size() > 0 || siteList.size() > 0) return null;
          }
        //if stock wrapper not null search for location and populate else assign null it and proceed
        
        itemFoundOnScan = false;
        List<Product2> productList;
        if(Schema.sObjectType.Product2.isAccessible()) productList = [select id, name, Barcode__c from Product2 where Barcode__c =: barcode.trim() Limit 1];
        if(productList.size() > 0) 
            addQuantityScannerManufacturing(JSON.serialize(productList[0])); 
        else ErrMsg = 'Product not found';
        return null;
    }   
    
    public pageReference addQuantityScannerManufacturing(String product1) {
        Product2 product = (Product2)JSON.deserialize(product1, Product2.class);
        String productId = product.Id;
        Boolean Error = false;
        ErrMsg = '';
        Boolean exist = false;
        
        for(WOLIWrapper WOLI : WOLIWrapperList){
            if(WOLI.woli.Product__c == productId) barcode = '#'+productId;
            if(WOLI.woli.Product__c == productId && WOLI.woli.Quantity__c > 0 && WOLI.lineItemprocessedQuantity < WOLI.woli.Quantity__c){
                Decimal subQuantity = 0; 
                for(StockWrapper WIIS : WOLI.StockWrapperList){
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c != Null) subQuantity += SPL.Quantity__c;
                    }
                }
                if((WOLI.lineItemprocessedQuantity - WOLI.Incount + subQuantity) > WOLI.woli.Quantity__c){
                    Error = true;
                    WOLI.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(WOLI.woli.Quantity__c - (WOLI.lineItemprocessedQuantity - WOLI.Incount));
                   }
                if(!Error){
                    if(!(WOLI.StockWrapperList.size() > 0)){ 
                        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = WOLI.woli.Product__c, Name=WOLI.woli.Name,Checked_In_Date__c=system.today()), new List<Stock_Inward_Line_Item__c>());
                        WOLI.StockWrapperList.add(SW);
                    }
                    if(!(WOLI.StockWrapperList[0].SPLI.size() > 0)) 
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.isAccessible()) WOLI.StockWrapperList[0].SPLI.add(new Stock_Inward_Line_Item__c());
                    
                    Stock_Inward_Line_Item__c SPL = WOLI.StockWrapperList[0].SPLI[0];
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c == Null) SPL.Quantity__c = 1;
                    else SPL.Quantity__c += 1;
                    
                    SPL.Batch_Lot_Code__c = (WOLI.woli.Batch_Lot_Code__c != Null)? WOLI.woli.Batch_Lot_Code__c : '';
                    
                    SPL.Quantity__c = (WOLI.woli.Quantity__c != Null)? WOLI.woli.Quantity__c : 0;
                    
                    WOLI.lineItemprocessedQuantity = SPL.Quantity__c;
                    WOLI.Incount = WOLI.lineItemprocessedQuantity;
                }
                randonScannedStock = WOLI.StockWrapperList[0];
                DisMsg = 'Product "'+WOLI.woli.Product__r.Name+'" found please scan the location';
                exist = true;
                barcode = '#'+WOLI.WOLI.Id;
                itemFoundOnScan = true;
                break;
            }
        }
        if(Error) ErrMsg = 'Please verify the errors below';
        if(!exist) ErrMsg = 'Product not found or its already added to the inventory';
        return null;
    }
    
    public pageReference scannerMethodReturns() {
        ErrMsg = '';
        DisMsg = '';
        if(barcode.trim() == 'StockReceiving'){ return Back2StockReceiving(); }
        if(barcode.trim() == 'Save'){ return SaveROLines(); }
        if(randonScannedStockNew != Null){
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
             
            if(Schema.sObjectType.Site__c.isAccessible()) siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.Location__c.isAccessible()) SSLList = [Select Id, Name, Barcode__c, Site__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.StorageContainer__c.isAccessible()) binList = [Select Id, Name, Barcode__c, Site__c, Location__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];   
            
            if(binList.size() > 0) { 
                if(Schema.sobjectType.StorageContainer__c.isAccessible()) randonScannedStockNew.Stock.StorageContainer__c = binList[0].Id;
                if(Schema.sobjectType.StorageContainer__c.fields.Location__c.isAccessible()) randonScannedStockNew.Stock.Location__c = binList[0].Location__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStockNew.Stock.Warehouse__c = binList[0].Site__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStockNew.SP.Site__c = binList[0].Site__c;
            }
            else if(SSLList.size() > 0){
                if(Schema.sobjectType.Location__c.isAccessible())  randonScannedStockNew.Stock.Location__c = SSLList[0].Id;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStockNew.Stock.Warehouse__c = SSLList[0].Site__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStockNew.SP.Site__c = SSLList[0].Site__c;
            }
            else if(siteList.size() > 0){
                if(Schema.sObjectType.Location__c.isAccessible()) randonScannedStockNew.Stock.Warehouse__c = siteList[0].Id;
                if(Schema.sObjectType.Location__c.isAccessible()) randonScannedStockNew.SP.Site__c = siteList[0].Id;
            }
            DisMsg = '';
            if(binList.size() > 0 || SSLList.size() > 0 || siteList.size() > 0) return null;
            }
        //if stock wrapper not null search for location and populate else assign null it and proceed
        
        itemFoundOnScan = false;
        List<Product2> productList;
        if(Schema.sObjectType.Product2.isAccessible()) productList = [select id, name, Barcode__c from Product2 where Barcode__c =: barcode.trim() Limit 1];
        if(productList.size() > 0) 
            addQuantityScannerReturn(JSON.serialize(productList[0])); 
        else ErrMsg = 'Product not found';
        return null;
    }   
    
    public pageReference addQuantityScannerReturn(String product1) {
        Product2 product = (Product2)JSON.deserialize(product1, Product2.class);
        String productId = product.Id;
        Boolean Error = false;
        ErrMsg = '';
        Boolean exist = false;
        
        for(RMALIWrapper ROLI : RMALIWrapperList){
            if(ROLI.roli.SOLI__r.Product__c == productId) barcode = '#'+productId;
            if(ROLI.roli.SOLI__r.Product__c == productId && ROLI.roli.Quantity_Return__c > 0 && ROLI.lineItemprocessedQuantity < ROLI.roli.Quantity_Return__c){
                Decimal subQuantity = 0; 
                for(StockWrapperNew WIIS : ROLI.StockWrapperList){
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c != Null) subQuantity += SPL.Quantity__c;
                    }
                }
                if((ROLI.lineItemprocessedQuantity - ROLI.Incount + subQuantity) > ROLI.roli.Quantity_Return__c){
                    Error = true;
                    ROLI.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(ROLI.roli.Quantity_Return__c - (ROLI.lineItemprocessedQuantity - ROLI.Incount));
                   }
                 if(!Error){
                    if(!(ROLI.StockWrapperList.size() > 0)){ 
                        StockWrapperNew SW = new StockWrapperNew(new Inventory_Stock__c(Active__c = true, Product__c = ROLI.roli.SOLI__r.Product__c,  Name=ROLI.roli.Name,Checked_In_Date__c=system.today()), new Stock_Inward_Line_Item__c());
                        ROLI.StockWrapperList.add(SW);
                    }
                    if(!(ROLI.StockWrapperList[0].SPLI.size() > 0)) 
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.isAccessible()) ROLI.StockWrapperList[0].SPLI.add(new Stock_Inward_Line_Item__c());
                    
                    Stock_Inward_Line_Item__c SPL = ROLI.StockWrapperList[0].SPLI[0];
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c == Null) SPL.Quantity__c = 1;
                    else SPL.Quantity__c += 1;
                    
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Batch_Lot_Code__c.isAccessible()) SPL.Batch_Lot_Code__c = (ROLI.roli.Batch_Lot_Code__c != Null)? ROLI.roli.Batch_Lot_Code__c : '';
                    
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) SPL.Quantity__c = (ROLI.roli.Quantity_Return__c != Null)? ROLI.roli.Quantity_Return__c : 0;
                    
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) ROLI.lineItemprocessedQuantity = SPL.Quantity__c;
                    ROLI.Incount = ROLI.lineItemprocessedQuantity;
                }
                randonScannedStockNew = ROLI.StockWrapperList[0];
                if(Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isAccessible() && Schema.sobjectType.Product2.fields.Name.isAccessible()) DisMsg = 'Product "'+ROLI.roli.SOLI__r.Product__r.Name+'" found please scan the location';
                exist = true;
                barcode = '#'+ROLI.ROLI.Id;
                itemFoundOnScan = true;
                break;
            }
        }
        if(Error) ErrMsg = 'Please verify the errors below';
        if(!exist) ErrMsg = 'Product not found or its already added to the inventory';
        return null;
    }
    
    
    public pageReference scannerMethodTransfer() {
         ErrMsg = '';
        DisMsg = '';
        if(barcode.trim() == 'StockReceiving'){ return Back2StockReceiving(); }
        if(barcode.trim() == 'Save'){ return SaveTOLines(); }
        if(randonScannedStock != Null){
            List<StorageContainer__c> binList = new List<StorageContainer__c>();
            List<Site__c> siteList = new List<Site__c>();            
            List<Location__c> SSLList = new List<Location__c>();
             
            if(Schema.sObjectType.Site__c.isAccessible()) siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.Location__c.isAccessible()) SSLList = [Select Id, Name, Barcode__c, Site__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
            if(Schema.sObjectType.StorageContainer__c.isAccessible()) binList = [Select Id, Name, Barcode__c, Site__c, Location__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];   
            
            if(binList.size() > 0) { 
                if(Schema.sobjectType.StorageContainer__c.isAccessible()) randonScannedStock.Stock.StorageContainer__c = binList[0].Id;
                if(Schema.sobjectType.StorageContainer__c.fields.Location__c.isAccessible()) randonScannedStock.Stock.Location__c = binList[0].Location__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = binList[0].Site__c;
                if(Schema.sobjectType.StorageContainer__c.fields.Site__c.isAccessible()) randonScannedStock.SP.Site__c = binList[0].Site__c;
            }
            else if(SSLList.size() > 0){
                if(Schema.sobjectType.Location__c.isAccessible())  randonScannedStock.Stock.Location__c = SSLList[0].Id;
                if(Schema.sobjectType.Location__c.fields.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = SSLList[0].Site__c;
                if(Schema.sobjectType.Location__c.fields.Site__c.isAccessible()) randonScannedStock.SP.Site__c = SSLList[0].Site__c;
            }
            else if(siteList.size() > 0){
                 if(Schema.sobjectType.Site__c.isAccessible()) randonScannedStock.Stock.Warehouse__c = siteList[0].Id;
                 if(Schema.sobjectType.Site__c.isAccessible()) randonScannedStock.SP.Site__c = siteList[0].Id;
            }
            DisMsg = '';
            if(binList.size() > 0 || SSLList.size() > 0 || siteList.size() > 0) return null;
            }
        //if stock wrapper not null search for location and populate else assign null it and proceed
        
        itemFoundOnScan = false;
        List<Product2> productList;
        if(Schema.sObjectType.Product2.isAccessible()) productList= [select id, name, Barcode__c from Product2 where Barcode__c =: barcode.trim() Limit 1];
        if(productList.size() > 0) 
            addQuantityScannerTransfering(JSON.serialize(productList[0])); 
        else ErrMsg = 'Product not found';
        return null;
    }   
    
    public pageReference addQuantityScannerTransfering(String product1) {
        Product2 product = (Product2)JSON.deserialize(product1, Product2.class);
        String productId = product.Id;
        Boolean Error = false;
        ErrMsg = '';
        Boolean exist = false;
        
        for(TOLIWrapper TOLI : TOLIWrapperList){
            if(TOLI.TOLI.Products__c == productId) barcode = '#'+productId;
            if(TOLI.TOLI.Products__c == productId && TOLI.TOLI.Quantity_received__c > 0 && TOLI.lineItemprocessedQuantity < TOLI.TOLI.Quantity_received__c){
                Decimal subQuantity = 0; 
                for(StockWrapper WIIS : TOLI.StockWrapperList){
                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                       if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible())  if(SPL.Quantity__c != Null) subQuantity += SPL.Quantity__c;
                    }
                }
                if((TOLI.lineItemprocessedQuantity - TOLI.Incount + subQuantity) > TOLI.TOLI.Quantity_received__c){
                    Error = true;
                    TOLI.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(TOLI.TOLI.Quantity_received__c - (TOLI.lineItemprocessedQuantity - TOLI.Incount));
                  }
                if(!Error){
                    if(!(TOLI.StockWrapperList.size() > 0)){ 
                        StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = TOLI.TOLI.Products__c,  Name=TOLI.TOLI.Name,Checked_In_Date__c=system.today()), new List<Stock_Inward_Line_Item__c>());
                        TOLI.StockWrapperList.add(SW);
                    }
                    if(!(TOLI.StockWrapperList[0].SPLI.size() > 0)) 
                        if(Schema.sobjectType.Stock_Inward_Line_Item__c.isAccessible()) TOLI.StockWrapperList[0].SPLI.add(new Stock_Inward_Line_Item__c());
                    
                    Stock_Inward_Line_Item__c SPL = TOLI.StockWrapperList[0].SPLI[0];
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c == Null) SPL.Quantity__c = 1;
                    else SPL.Quantity__c += 1;
                    
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Batch_Lot_Code__c.isAccessible()) SPL.Batch_Lot_Code__c = (TOLI.TOLI.Batch_Lot_Code__c != Null)? TOLI.TOLI.Batch_Lot_Code__c : '';
                    
                    SPL.Quantity__c = (TOLI.TOLI.Quantity_received__c != Null)? TOLI.TOLI.Quantity_received__c : 0;
                    
                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) TOLI.lineItemprocessedQuantity = SPL.Quantity__c;
                    TOLI.Incount = TOLI.lineItemprocessedQuantity;
                }
                randonScannedStock = TOLI.StockWrapperList[0];
                DisMsg = 'Product "'+TOLI.TOLI.Products__r.Name+'" found please scan the location';
                exist = true;
                barcode = '#'+TOLI.TOLI.Id;
                itemFoundOnScan = true;
                break;
            }
        }
        if(Error) ErrMsg = 'Please verify the errors below';
        if(!exist) { 
            ErrMsg = 'Product not found or its already added to the inventory';
               
        }
        return null;
    }
   
    public void customCollapse(){
        PLIWrapperList[collapseCounter].collaps = (PLIWrapperList[collapseCounter].collaps)? false : true;
    }
    
    public pageReference Receive() {
        try {
            ErrMsg = DisMsg = '';
            if(poIds != Null && poIds.size() > 0) { SupplierInventoryCustomContructor(); return Page.ERP7__POReceive; }
            else if(woIds != Null && woIds.size() > 0) { ManufacturingInventoryCustomContructor(); return Page.ERP7__WOReceive; }
            else if(soIds != Null && soIds.size() > 0) { RMAInventoryCustomContructor(); return Page.ERP7__SOReceive; }
            else if(toIds != Null && toIds.size() > 0) { TransferOrderInventoryCustomContructor(); return Page.ERP7__TOReceive; }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference PutAway() {
        try {
            Boolean proceed = false;
            if(poIds != Null && poIds.size() > 0){
                for(Integer i=0; i< PLIWrapperList.size(); i++){
                    PLIWrapper PLI = PLIWrapperList[i];
                    if(PLI.Selected) proceed = true;
                    if(PLI.StockWrapperList.size()==0 && PLI.PLI.Quantity__c > 0 && PLI.PLI.Quantity_Received__c > 0 && PLI.PLI.Quantity_Received__c > PLI.lineItemprocessedQuantity){
                       if((PLI.PLI.Product__r.ERP7__Is_Kit__c == true && PLI.PLI.ERP7__Explode__c == false) || PLI.PLI.Product__r.ERP7__Is_Kit__c != true){
                           counter = i;
                           if(PLI.PLI.Product__r.Serialise__c){
                               Integer N = Integer.valueof(PLI.PLI.Quantity_Received__c - PLI.lineItemprocessedQuantity);
                               for(Integer j=0; j<N; j++) { counter = i; AddStock(); }
                           } else AddStock();
                       } else if(PLI.PLI.Product__r.ERP7__Is_Kit__c == true && PLI.PLI.ERP7__Explode__c == true){
                          counter = i;
                          ExplodeKit();
                       }
                    }
                }
                if(proceed) return Page.ERP7__SupplierInventoryConsole;
            }
            else if(woIds != Null && woIds.size() > 0){
                for(Integer i=0; i< WOLIWrapperList.size(); i++){
                    WOLIWrapper WOLI = WOLIWrapperList[i];
                    if(WOLI.Selected) proceed = true;
                    if(WOLI.StockWrapperList.size()==0 && WOLI.WOLI.Quantity__c > 0 && WOLI.WOLI.Quantity__c > WOLI.lineItemprocessedQuantity){
                       counter = i;
                       if((WOLI.WOLI.Product__r.ERP7__Is_Kit__c == true && WOLI.WOLI.ERP7__Explode__c == false) || WOLI.WOLI.Product__r.ERP7__Is_Kit__c != true){
                           if(WOLI.WOLI.Product__r.Serialise__c){
                               Integer N = Integer.valueof(WOLI.WOLI.Quantity__c - WOLI.lineItemprocessedQuantity);
                               for(Integer j=0; j<N; j++) { counter = i; AddManufacturedStock(); }
                           } else AddManufacturedStock();
                       } else if(WOLI.WOLI.Product__r.ERP7__Is_Kit__c == true && WOLI.WOLI.ERP7__Explode__c == true){
                          counter = i;
                          ExplodeKitWO();
                       }
                    }
                }
                if(proceed) return Page.ERP7__ManufacturingInventoryConsole;
            }
            else if(toIds != Null && toIds.size() > 0){
                for(Integer i=0; i< toliWrapperList.size(); i++){
                    toliWrapper toli = toliWrapperList[i];
                    if(toli.Selected) proceed = true;
                    /*toli : '+toli*/
                    if(toli.StockWrapperList.size()==0 && toli.toli.ERP7__Quantity_requested__c > 0 && toli.toli.ERP7__Quantity_requested__c > toli.lineItemprocessedQuantity){
                       counter = i;
                       if((toli.toli.Products__r.ERP7__Is_Kit__c == true && toli.toli.ERP7__Explode__c == false) || toli.toli.Products__r.ERP7__Is_Kit__c != true){
                           if(toli.toli.Products__r.Serialise__c){
                               Integer N = Integer.valueof(toli.toli.ERP7__Quantity_requested__c - toli.lineItemprocessedQuantity);
                               for(Integer j=0; j<N; j++) { counter = i; AddTransferStock(); }
                           } else AddTransferStock();
                       } else if(toli.toli.Products__r.ERP7__Is_Kit__c == true && toli.toli.ERP7__Explode__c == true){
                          counter = i;
                          ExplodeKitTO();
                       }
                    }
                }
                if(proceed) return Page.ERP7__TransferInventoryConsole;
            }
            else if(soIds != Null && soIds.size() > 0){
                for(Integer i=0; i< RMALIWrapperList.size(); i++){
                    RMALIWrapper ROLI = RMALIWrapperList[i];
                    if(ROLI.Selected) proceed = true;
                    
                    if(ROLI.StockWrapperList.size()==0 && ROLI.roli.Quantity_Return__c > 0 && ROLI.ROLI.Quantity_Return__c > ROLI.lineItemprocessedQuantity){
                       counter = i;
                       if((ROLI.ROLI.Product__r.ERP7__Is_Kit__c == true && ROLI.ROLI.ERP7__Explode__c == false) || ROLI.ROLI.Product__r.ERP7__Is_Kit__c != true){
                           if(roli.roli.Product__r.Serialise__c){
                               Integer N = Integer.valueof(ROLI.ROLI.Quantity_Return__c - roli.lineItemprocessedQuantity);
                               for(Integer j=0; j<N; j++) { counter = i; AddSOstock(); }
                           } else AddSOstock();
                       } else if(ROLI.ROLI.Product__r.ERP7__Is_Kit__c == true && ROLI.ROLI.ERP7__Explode__c == true){
                          counter = i;
                          ExplodeKitSO();
                       }
                    }
                }
                if(proceed) return Page.ERP7__RMAInventoryConsole;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference PutOneAway() {
        try {
            if(poIds != Null && poIds.size() > 0){
                for(Integer i=0; i< PLIWrapperList.size(); i++){
                    PLIWrapper PLI = PLIWrapperList[i];
                    if(PLI.PLI.Id == putawayId) PLI.Selected = true; else PLI.Selected = false;
                    if(PLI.Selected && PLI.StockWrapperList.size()==0 && PLI.PLI.Quantity__c > 0 && PLI.PLI.Quantity_Received__c > 0 && PLI.PLI.Quantity_Received__c > PLI.lineItemprocessedQuantity){
                       counter = i;
                       if(PLI.PLI.Product__r.Serialise__c){
                           Integer N = Integer.valueof(PLI.PLI.Quantity_Received__c - PLI.lineItemprocessedQuantity);
                           for(Integer j=0; j<N; j++) { counter = i; AddStock(); }
                       } else AddStock();
                    } else if(PLI.PLI.Product__r.ERP7__Is_Kit__c == true && PLI.PLI.ERP7__Explode__c == true){
                      counter = i;
                      ExplodeKit();
                    }
                }
                return Page.ERP7__SupplierInventoryConsole;
            }
            else if(woIds != Null && woIds.size() > 0){
                for(Integer i=0; i< WOLIWrapperList.size(); i++){
                    WOLIWrapper WOLI = WOLIWrapperList[i];
                    if(WOLI.WOLI.Id == putawayId) WOLI.Selected = true; else WOLI.Selected = false;
                    if(WOLI.StockWrapperList.size()==0 && WOLI.WOLI.Quantity__c > 0 && WOLI.WOLI.Quantity__c > WOLI.lineItemprocessedQuantity){
                       counter = i;
                       if((WOLI.WOLI.Product__r.ERP7__Is_Kit__c == true && WOLI.WOLI.ERP7__Explode__c == false) || WOLI.WOLI.Product__r.ERP7__Is_Kit__c != true){
                           if(WOLI.WOLI.Product__r.Serialise__c){
                               Integer N = Integer.valueof(WOLI.WOLI.Quantity__c - WOLI.lineItemprocessedQuantity);
                               for(Integer j=0; j<N; j++) { counter = i; AddManufacturedStock(); }
                           } else AddManufacturedStock();
                       } else if(WOLI.WOLI.Product__r.ERP7__Is_Kit__c == true && WOLI.WOLI.ERP7__Explode__c == true){
                          counter = i;
                          ExplodeKitWO();
                       }
                    }
                }
                return Page.ERP7__ManufacturingInventoryConsole;
            }
            else if(toIds != Null && toIds.size() > 0){
                for(Integer i=0; i< toliWrapperList.size(); i++){
                    toliWrapper toli = toliWrapperList[i];
                    if(toli.toli.Id == putawayId) toli.Selected = true; else toli.Selected = false;
                  
                    if(toli.StockWrapperList.size()==0 && toli.toli.ERP7__Quantity_requested__c > 0 && toli.toli.ERP7__Quantity_requested__c > toli.lineItemprocessedQuantity){
                       counter = i;
                       if((toli.toli.Products__r.ERP7__Is_Kit__c == true && toli.toli.ERP7__Explode__c == false) || toli.toli.Products__r.ERP7__Is_Kit__c != true){
                           if(toli.toli.Products__r.Serialise__c){
                               Integer N = Integer.valueof(toli.toli.ERP7__Quantity_requested__c - toli.lineItemprocessedQuantity);
                               for(Integer j=0; j<N; j++) { counter = i; AddTransferStock(); }
                           } else AddTransferStock();
                       } else if(toli.toli.Products__r.ERP7__Is_Kit__c == true && toli.toli.ERP7__Explode__c == true){
                          counter = i;
                          ExplodeKitTO();
                       }
                    }
                }
                return Page.ERP7__TransferInventoryConsole;
            }
            else if(soIds != Null && soIds.size() > 0){
                for(Integer i=0; i< RMALIWrapperList.size(); i++){
                    RMALIWrapper ROLI = RMALIWrapperList[i];
                    if(roli.roli.Id == putawayId) roli.Selected = true; else roli.Selected = false;
                    
                    if(ROLI.StockWrapperList.size()==0 && ROLI.roli.Quantity_Return__c > 0 && ROLI.ROLI.Quantity_Return__c > ROLI.lineItemprocessedQuantity){
                       counter = i;
                       if((ROLI.ROLI.Product__r.ERP7__Is_Kit__c == true && ROLI.ROLI.ERP7__Explode__c == false) || ROLI.ROLI.Product__r.ERP7__Is_Kit__c != true){
                           if(roli.roli.Product__r.Serialise__c){
                               Integer N = Integer.valueof(ROLI.ROLI.Quantity_Return__c - roli.lineItemprocessedQuantity);
                               for(Integer j=0; j<N; j++) { counter = i; AddSOstock(); }
                           } else AddSOstock();
                       } else if(ROLI.ROLI.Product__r.ERP7__Is_Kit__c == true && ROLI.ROLI.ERP7__Explode__c == true){
                          counter = i;
                          ExplodeKitSO();
                       }
                    }
                }
                return Page.ERP7__RMAInventoryConsole;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference POALL() {
        try {
            if(selectAll) { for(PLIWrapper R : PLIWrapperList) R.Selected = true; } 
            else for(PLIWrapper R : PLIWrapperList) R.Selected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference WOALL() {
        try {
            if(selectAll) { for(WOLIWrapper R : WOLIWrapperList) R.Selected = true; } 
            else for(WOLIWrapper R : WOLIWrapperList) R.Selected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference SOALL() {
        try {
            if(selectAll) { for(RMALIWrapper R : RMALIWrapperList) R.Selected = true; } 
            else for(RMALIWrapper R : RMALIWrapperList) R.Selected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference TOALL() {
        try {
            if(selectAll) { for(TOLIWrapper R : TOLIWrapperList) R.Selected = true; } 
            else for(TOLIWrapper R : TOLIWrapperList) R.Selected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference PreparePushAttachment() {
        universalAttachment = new Attachment();
        return Null;
    }
    
    public PageReference PushAttachment() {
        if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable() || Schema.sObjectType.Attachment.fields.ParentId.isUpdateable()) universalAttachment.ParentId = PreparePushAttachmentId;
        if(Schema.sObjectType.Attachment.isCreateable() && Schema.sObjectType.Attachment.isUpdateable()){ hasAccess=true; upsert universalAttachment;}
        else{hasAccess=false; errormsg='You are not allowed to create or update records';}
        if(poIds != Null && poIds.size() > 0){ for(PLIWrapper s : PLIWrapperList){ if(s.PLI.Id == PreparePushAttachmentId) { s.Attach = universalAttachment; s.Attach.body = Null; break; }}}
        else if(woIds != Null && woIds.size() > 0){ for(WOLIWrapper s : WOLIWrapperList){ if(s.WOLI.Id == PreparePushAttachmentId) { s.Attach = universalAttachment; s.Attach.body = Null; break; }}}
        else if(toIds != Null && toIds.size() > 0){ for(TOLIWrapper s : TOLIWrapperList){ if(s.TOLI.Id == PreparePushAttachmentId) { s.Attach = universalAttachment; s.Attach.body = Null; break; }}}
        else if(soIds != Null && soIds.size() > 0){ for(RMALIWrapper s : RMALIWrapperList){ if(s.ROLI.Id == PreparePushAttachmentId) { s.Attach = universalAttachment; s.Attach.body = Null; break; }}}
        universalAttachment = new Attachment();
        return Null;
    } 
    
    public String fetchAllFields(String sObj){
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObj).getDescribe().fields.getMap();
        String allFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(allFields == null || allFields == ''){
                allFields = fieldName;
            } else{
                allFields = allFields + ', ' + fieldName;
            }
        }
        return allFields;
    } 
}