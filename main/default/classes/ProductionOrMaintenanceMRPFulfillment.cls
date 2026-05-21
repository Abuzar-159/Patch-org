public with sharing class ProductionOrMaintenanceMRPFulfillment {
    
    public MRP__c MRP                                               { get; set; }  public String scheduleType                                      { get; set; } 
    public List<MRP__c> MRPs                                        { get; set; }
    public String barcode                                           { get; set; }
    public Stock_Outward_Line_Item__c SDLI                          { get; set; }
    public List<Stock_Outward_Line_Item__c> SDLIList                { get; set; }
    public List<Stock_Outward_Line_Item__c> SDLIList2Upsert         { get; set; }
    public List<MRPWrapper> MRPWrapperList                          { get; set; }
    public String mrpName                                           { get; set; }
    public String  errMsg                                           { get; set; }
    public MRP__c MRPNew                                            { get; set; }
    public List<Id> warehouseIds                                    { get; set; }
    public List<Id> productIds                                      { get; set; }
    public List<Inventory_Stock__c> warehouseStocks  { get; set; } public Integer counter                                          { get; set; }
    public Map<String, Decimal> stockCount                          { get; set; }
    
    public Integer wrapCounter                                      { get; set; }
    
    public List<MRP__c> mrps2Update                                 { get; set; }
    public PO__c PO                                                 { get; set; }
    public List<Purchase_Line_Items__c> Polis                       { get; set; }
    
    public WO__c WO                                                 { get; set; }
    public List<Work_Order_Line_Items__c> Wolis                     { get; set; }
    
    public static Map<String, Schema.SObjectType> schemaMap;
    
    public ProductionOrMaintenanceMRPFulfillment(ApexPages.StandardController controller) {
    try{
        schemaMap = Schema.getGlobalDescribe();
        MRP = new MRP__c();
        MRPNew = new MRP__c();
        MRPs = new List<MRP__c>();
        SDLI = new Stock_Outward_Line_Item__c();
        SDLIList = new List<Stock_Outward_Line_Item__c>();
        SDLIList2Upsert = new List<Stock_Outward_Line_Item__c>();
        mrpName = '';
        errMsg = '';
        orderFormat = 'DESC';
        prevSortBy = '';
        if(!Schema.sObjectType.MRP__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.MRP__c.Label));
   		} else {
            MRPs = [Select Id, Name, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c, Check_Out_Process__c, 
                    Visit__c,  Fulfilled_Amount__c, Process__c, 
                    Schedule__c, Maximum_Hold_days__c, Notes__c, MRP_Product__c, Production_Cycle__c, Requested_Requirement_Date__c, 
                    Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c, Required_Amount__c, MRP_Product__r.Name, Purchase_Order__c, Work_Order__c, MRP_Product__r.Picture__c, MRP_Product__r.Preview_Image__c,
                    Schedule__r.Name, Purchase_Order__r.Name, Work_Order__r.Name, MRP_Product__r.Issue_Purchase_Order__c, MRP_Product__r.Issue_Work_Order__c 
                    From MRP__c Where MRP_Product__c != Null And Required_Amount__c > 0 And (Schedule__c != Null ) And 
                    Required_Amount__c > 0 And Status__c = 'Requested' order by MRP_Product__c Limit 10000];
        }
        warehouseIds = new List<Id>();
        productIds = new List<Id>();
        MRPWrapperList = new List<MRPWrapper>();
        
        for(MRP__c mr : MRPs){
            if(Schema.SObjectType.MRP__c.Fields.Sourced_Site__c.isAccessible() && mr.Sourced_Site__c != Null) warehouseIds.add(mr.Sourced_Site__c);
            if(Schema.SObjectType.MRP__c.Fields.MRP_Product__c.isAccessible() && mr.MRP_Product__c != Null) productIds.add(mr.MRP_Product__c);
        }
        
        String allFields2 = fetchAllFields('ERP7__Inventory_Stock__c');
        utilClass.FLSCheck(allFields2.split(','),'ERP7__Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name';
        String query2 = 'select ' + allFields2 + ' from Inventory_Stock__c where Warehouse__c In :warehouseIds And Product__c In :productIds order by CreatedDate ASC';
        if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
   		} else {
             warehouseStocks = Database.query(query2);
          }
        stockCount = new Map<String, Decimal>();
        
        for(MRP__c mr : MRPs){
            Decimal stockQuantity = 0;
            for(Inventory_Stock__c wiis : warehouseStocks){
                if(Schema.sObjectType.Inventory_Stock__c.Fields.Warehouse__c.isAccessible() && Schema.sObjectType.Inventory_Stock__c.Fields.Product__c.isAccessible() &&  mr.MRP_Product__c == wiis.Product__c && mr.Sourced_Site__c == wiis.Warehouse__c){
                    if(Schema.sObjectType.Inventory_Stock__c.Fields.Number_of_Item_In_Stock__c.isAccessible())stockQuantity += wiis.Number_of_Item_In_Stock__c;
                }
            }
            MRPWrapperList.add(new MRPWrapper(mr,stockQuantity));
            if(mr.MRP_Product__c != Null && mr.Sourced_Site__c != Null){
                string prodWare = mr.MRP_Product__c;
                prodWare += mr.Sourced_Site__c;
                stockCount.put(prodWare,stockQuantity);
            }
        }
        
        if(!(MRPWrapperList.size() > 0)){ errMsg = 'No MRPs to fulfill !'; }
    }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
                       }
    }

    public ProductionOrMaintenanceMRPFulfillment() {}
    
    public PageReference populateSchedule(){
    try{
        schemaMap = Schema.getGlobalDescribe();
        SDLI = new Stock_Outward_Line_Item__c();
        MRPs = new List<MRP__c>();
        mrpName = '%'+mrpName+'%';
        if(!Schema.sObjectType.MRP__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.MRP__c.Label));
   		} else {
         if(MRP.Purchase_Order__c != Null && MRP.Work_Order__c != Null){
            MRPs = [Select Id, Name, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c, Check_Out_Process__c, 
                    Visit__c,  Fulfilled_Amount__c, Process__c, 
                    Schedule__c, Maximum_Hold_days__c, Notes__c, MRP_Product__c, Production_Cycle__c, Requested_Requirement_Date__c, 
                    Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c, Required_Amount__c, MRP_Product__r.Name, Purchase_Order__c, Work_Order__c, MRP_Product__r.Picture__c, MRP_Product__r.Preview_Image__c,
                    Schedule__r.Name,  Purchase_Order__r.Name, Work_Order__r.Name, MRP_Product__r.Issue_Purchase_Order__c, MRP_Product__r.Issue_Work_Order__c 
                    From MRP__c Where MRP_Product__c != Null And Name Like :mrpName And Required_Amount__c > 0 And (Schedule__c != Null) And Required_Amount__c > 0 And 
                    Status__c = 'Requested' And Purchase_Order__c =: MRP.Purchase_Order__c And Work_Order__c =: MRP.Work_Order__c order by MRP_Product__c Limit 10000];
         }else if(MRP.Purchase_Order__c != Null && MRP.Work_Order__c == Null){
                MRPs = [Select Id, Name, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c, Check_Out_Process__c, 
                        Visit__c,  Fulfilled_Amount__c,  Process__c, 
                        Schedule__c, Maximum_Hold_days__c, Notes__c, MRP_Product__c, Production_Cycle__c, Requested_Requirement_Date__c, 
                        Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c, Required_Amount__c, MRP_Product__r.Name, Purchase_Order__c, Work_Order__c, MRP_Product__r.Picture__c, MRP_Product__r.Preview_Image__c,
                        Schedule__r.Name,  Purchase_Order__r.Name, Work_Order__r.Name, MRP_Product__r.Issue_Purchase_Order__c, MRP_Product__r.Issue_Work_Order__c 
                        From MRP__c Where MRP_Product__c != Null And Name Like :mrpName And Required_Amount__c > 0 And (Schedule__c != Null) And 
                        Required_Amount__c > 0 And Status__c = 'Requested' And Purchase_Order__c =: MRP.Purchase_Order__c order by MRP_Product__c Limit 10000]; 
        }else if(MRP.Purchase_Order__c == Null && MRP.Work_Order__c != Null){
            MRPs = [Select Id, Name, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c, Check_Out_Process__c, 
                    Visit__c,  Fulfilled_Amount__c, Process__c, 
                    Schedule__c, Maximum_Hold_days__c, Notes__c, MRP_Product__c, Production_Cycle__c, Requested_Requirement_Date__c, 
                    Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c, Required_Amount__c, MRP_Product__r.Name, Purchase_Order__c, Work_Order__c, MRP_Product__r.Picture__c, MRP_Product__r.Preview_Image__c,
                    Schedule__r.Name, Purchase_Order__r.Name, Work_Order__r.Name, MRP_Product__r.Issue_Purchase_Order__c, MRP_Product__r.Issue_Work_Order__c 
                    From MRP__c Where MRP_Product__c != Null And Name Like :mrpName And Required_Amount__c > 0 And (Schedule__c != Null) And 
                    Required_Amount__c > 0 And Status__c = 'Requested' And Work_Order__c =: MRP.Work_Order__c order by MRP_Product__c Limit 10000];
        }else {
            MRPs = [Select Id, Name, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c, Check_Out_Process__c, 
                    Visit__c, Fulfilled_Amount__c,  Process__c, 
                    Schedule__c, Maximum_Hold_days__c, Notes__c, Production_Cycle__c, Requested_Requirement_Date__c, 
                    Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c, Required_Amount__c, MRP_Product__r.Name, Purchase_Order__c, Work_Order__c, MRP_Product__r.Picture__c, MRP_Product__r.Preview_Image__c,
                    Schedule__r.Name,  Purchase_Order__r.Name, Work_Order__r.Name, MRP_Product__r.Issue_Purchase_Order__c, MRP_Product__r.Issue_Work_Order__c 
                    From MRP__c Where MRP_Product__c != Null And Name Like :mrpName And Required_Amount__c > 0 And (Schedule__c != Null) And 
                    Required_Amount__c > 0 And Status__c = 'Requested' order by MRP_Product__c Limit 10000];
        }
        }
        warehouseIds = new List<Id>();
        productIds = new List<Id>();
        MRPWrapperList = new List<MRPWrapper>(); 
        
        for(MRP__c mr : MRPs){
            if(Schema.SObjectType.MRP__c.Fields.Sourced_Site__c.isAccessible() && mr.Sourced_Site__c != Null) warehouseIds.add(mr.Sourced_Site__c);
            if(Schema.SObjectType.MRP__c.Fields.MRP_Product__c.isAccessible() && mr.MRP_Product__c != Null) productIds.add(mr.MRP_Product__c);
        }
        
        String allFields2 = fetchAllFields('ERP7__Inventory_Stock__c');
        utilClass.FLSCheck(allFields2.split(','),'ERP7__Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name';
        String query2 = 'select ' + allFields2 + ' from Inventory_Stock__c where Warehouse__c In :warehouseIds And Product__c In :productIds order by CreatedDate ASC';
        if(!Schema.sObjectType.Inventory_Stock__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Inventory_Stock__c.Label));
   } else {
         warehouseStocks = Database.query(query2);
       } 
        stockCount = new Map<String, Decimal>();
        
        for(MRP__c mr : MRPs){
            Decimal stockQuantity = 0;
            for(Inventory_Stock__c wiis : warehouseStocks){
                if(Schema.sObjectType.Inventory_Stock__c.Fields.Warehouse__c.isAccessible() && Schema.sObjectType.Inventory_Stock__c.Fields.Product__c.isAccessible() && mr.MRP_Product__c == wiis.Product__c && mr.Sourced_Site__c == wiis.Warehouse__c){
                    if(Schema.sObjectType.Inventory_Stock__c.Fields.Number_of_Item_In_Stock__c.isAccessible())stockQuantity += wiis.Number_of_Item_In_Stock__c;
                }
            }
            MRPWrapperList.add(new MRPWrapper(mr,stockQuantity));
            if(Schema.SObjectType.MRP__c.Fields.MRP_Product__c.isAccessible() && Schema.SObjectType.MRP__c.Fields.Sourced_Site__c.isAccessible() && mr.MRP_Product__c != Null && mr.Sourced_Site__c != Null){
                string prodWare = mr.MRP_Product__c;
                prodWare += mr.Sourced_Site__c;
                stockCount.put(prodWare,stockQuantity);
            }
        }
        
        if(!(MRPWrapperList.size() > 0)){ errMsg = 'No MRPs to fulfill !';
        }
        
        return null;
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return Null;
        }
    }
    
    public PageReference processMRPs(){
        return null;
    } 
    
    public PageReference processProductionMRPs(){
        return null;
    } 
    
    public PageReference processMaintenanceMRPs(){
       return null;
    } 
    
    
    public PageReference createPO(){
    try{
        PO = new PO__c(Status__c='New'); 
        Polis = new List<Purchase_Line_Items__c>();  
        Map<Id, List<MRP__c>> productMRPs = new Map<Id, List<MRP__c>>(); 
        mrps2Update = new List<MRP__c>();
        
        Set<Id> prodIds = new Set<Id>();
        prodIds.addAll(productIds);
        
        for(Id pId : prodIds){
            List<MRP__c> myMRPs = new List<MRP__c>();
            for(MRPWrapper m : MRPWrapperList) {
                if(m.selected && m.MRP.MRP_Product__c == PId && m.MRP.MRP_Product__r.Issue_Purchase_Order__c && m.MRP.Purchase_Order__c == Null){
                    myMRPs.add(m.MRP);
                }
            }
            if(myMRPs.size() > 0) productMRPs.put(pId,myMRPs);
        }
        
        Set<Id> selectedpIds = productMRPs.keySet();
        
        for(Id pId : selectedpIds){
            
            if(productMRPs.ContainsKey(pId)){
                Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Active__c=true,Product__c=pId,Quantity__c=0);
                List<MRP__c> myMRPs = productMRPs.get(pId);
                               
                for(MRP__c mrpss : myMRPs) {
                    poli.Quantity__c += mrpss.Required_Amount__c;
                    poli.MRP_Material_Requirements_Planning__c= mrpss.id;
                    poli.Name = mrpss.MRP_Product__r.Name;
                    mrps2Update.add(mrpss);
                }
                
                Polis.add(poli);
            }
        }
        if(Polis.size() > 0) return Page.CreatePurchaseOrder;
        return Null;
        }catch(Exception  e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return Null;
        }
    } 
    
    public PageReference createWO(){
    try{
        WO = new WO__c(); 
        Wolis = new List<Work_Order_Line_Items__c>();  
        Map<Id, List<MRP__c>> productMRPs = new Map<Id, List<MRP__c>>(); 
        mrps2Update = new List<MRP__c>();
        
        Set<Id> prodIds = new Set<Id>();
        prodIds.addAll(productIds);
        
        for(Id pId : prodIds){
            List<MRP__c> myMRPs = new List<MRP__c>();
            for(MRPWrapper m : MRPWrapperList) {
                if(m.selected && m.MRP.MRP_Product__c == PId && m.MRP.MRP_Product__r.Issue_Work_Order__c && m.MRP.Work_Order__c == Null){
                    myMRPs.add(m.MRP);
                }
            }
            if(myMRPs.size() > 0) productMRPs.put(pId,myMRPs);
        }
        
        Set<Id> selectedpIds = productMRPs.keySet();
        
        for(Id pId : selectedpIds){
            
            if(productMRPs.ContainsKey(pId)){
                List<MRP__c> myMRPs = productMRPs.get(pId);
                Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c(Active__c=true,Product__c=pId,Quantity__c=0);
                
                
                for(MRP__c mrpss : myMRPs) {
                    woli.Quantity__c += mrpss.Required_Amount__c;
                    woli.MRP_Material_Requirements_Planning__c= mrpss.id;
                    mrps2Update.add(mrpss);
                }
                
                Wolis.add(woli);
            }
        }
        if(Wolis.size() > 0) return Page.CreateWorkOrder;
        return Null;
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return Null;
        }
    } 
    
    public PageReference savePO(){
    try{
        DMLManager.upsertAsUser(PO);
        
        for(Purchase_Line_Items__c poli : Polis){
            poli.Purchase_Orders__c = PO.Id;
        }
        for(MRP__c mrpss : mrps2Update){
            mrpss.Purchase_Order__c = PO.Id;
        }
        if(Polis.size() > 0) DMLManager.upsertAsUser(Polis);
        if(mrps2Update.size() > 0) DMLManager.upsertAsUser(mrps2Update);
        
        populateSchedule();
        return Page.ProductionOrMaintenanceMRPFulfillment;
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
    }
    
   
    public Void ProcessCostcardValues(){
    try{
        if(Polis[wrapCounter].Cost_Card__c != Null){
           if(Schema.sObjectType.Cost_Card__c.isAccessible()){
            Cost_Card__c cc = [Select id, Name, Cost__c From Cost_Card__c where id =: Polis[wrapCounter].Cost_Card__c];
            
            if(Schema.SObjectType.Cost_Card__c.Fields.Cost__c.isAccessible() && cc.Cost__c != Null && Polis[wrapCounter].Quantity__c != Null) {
                Polis[wrapCounter].Unit_Price__c = cc.Cost__c;
                Polis[wrapCounter].Total_Price__c = Polis[wrapCounter].Unit_Price__c * Polis[wrapCounter].Quantity__c;
            }
            }
        }
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return ;
        }
    }
    
    public Void ProcessCostcardValuesWO(){
    try{
        if(Wolis[wrapCounter].Cost_Card__c != Null){
        if(Schema.sObjectType.Cost_Card__c.isAccessible()){
            Cost_Card__c cc = [Select id, Name, Cost__c From Cost_Card__c where id =: Wolis[wrapCounter].Cost_Card__c];
            
            if(Schema.SObjectType.Cost_Card__c.Fields.Cost__c.isAccessible() && cc.Cost__c != Null && Wolis[wrapCounter].Quantity__c != Null) {
                Wolis[wrapCounter].Unit_Price__c = cc.Cost__c;
                Wolis[wrapCounter].Total_Cost__c = Wolis[wrapCounter].Unit_Price__c * Wolis[wrapCounter].Quantity__c;
            }else{
                Wolis[wrapCounter].Unit_Price__c = null;
                Wolis[wrapCounter].Total_Cost__c = null;
            }
            }
        }
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return;
        }
    }
    
    public PageReference back(){
        return Page.ProductionOrMaintenanceMRPFulfillment;
    } 
    
    public PageReference saveWO(){
    try{
      DMLManager.updateAsUser(WO);
        
        for(Work_Order_Line_Items__c woli : Wolis){ if(Schema.sobjectType.Work_Order_Line_Items__c.fields.Work_Orders__c.isAccessible())woli.Work_Orders__c = WO.Id;
        }
        for(MRP__c mrpss : mrps2Update){ if(Schema.sobjectType.MRP__c.fields.Work_Order__c.isAccessible())mrpss.Work_Order__c = WO.Id;
        }
        if(Wolis.size() > 0)DMLManager.updateAsUser(Wolis);
        if(mrps2Update.size() > 0)DMLManager.updateAsUser(mrps2Update);
        
        populateSchedule();
        return Page.ProductionOrMaintenanceMRPFulfillment;
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
    } 
    
    
    
    public PageReference Save(){
    try{
        Boolean flag = false;
        List<MRP__c> mrps2Upsert = new List<MRP__c>();
        List<Stock_Outward_Line_Item__c> sdlis2Upsert = new List<Stock_Outward_Line_Item__c>();
        Map<String,Decimal> stockCountTemp = stockCount.Clone();
        Map<Id, List<Inventory_Stock__c>> productSites = new Map<Id, List<Inventory_Stock__c>>();
        
        List<Inventory_Stock__c> WarehouseItemInventoryStocks;
        if(Schema.sobjectType.Inventory_Stock__c.isAccessible()){
        UtilClass.FLSCheck(new string[]{'Id','Name','ERP7__Active__c','ERP7__Organisation__c','ERP7__Warehouse__c','ERP7__Product__c','ERP7__Number_of_Item_In_Stock__c','ERP7__Number_of_Item_Purchased_In__c','ERP7__Number_of_Items_Dispatched__c','ERP7__No_of_Items_Sold__c','ERP7__Checked_In_Date__c'},'Inventory_Stock__c');
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c,  Warehouse__c, Product__c,  Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,
                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c, Checked_In_Date__c 
                                            From Inventory_Stock__c Where Product__c In: productIds And Warehouse__c In: warehouseIds And 
                                            Active__c = true And Number_of_Item_In_Stock__c > 0 Order By Checked_In_Date__c ASC];
                                                                                     
                                                                                     
        for(Id pId : productIds){
            List<Inventory_Stock__c> sites = new List<Inventory_Stock__c>();
            for(Inventory_Stock__c WIIS : WarehouseItemInventoryStocks){ if(Schema.sObjectType.Inventory_Stock__c.fields.Product__c.isAccessible() && pId == WIIS.Product__c) sites.add(WIIS);
            }
            productSites.put(pId,sites);
            
        }
        }                                                                                
        for(MRPWrapper m : MRPWrapperList) {
            if(m.remainingQuantityMRP.Fulfilled_Amount__c > m.inStock || m.remainingQuantityMRP.Fulfilled_Amount__c > m.MRP.Required_Amount__c) {
                m.remainingQuantityMRP.Fulfilled_Amount__c.addError('Quantity cannot be greater than required or stock');  flag = true;
            }
            else if(!flag && m.MRP.MRP_Product__c != Null && m.MRP.Sourced_Site__c != Null && m.inStock > 0 && m.remainingQuantityMRP.Fulfilled_Amount__c > 0){
                string prodWare = m.MRP.MRP_Product__c; prodWare += m.MRP.Sourced_Site__c; Decimal stockValue = stockCountTemp.get(prodWare);
                 
                if(stockValue < m.remainingQuantityMRP.Fulfilled_Amount__c){ flag = true; m.remainingQuantityMRP.Fulfilled_Amount__c.addError('Quantity in stock is less than quantity to fulfill');
                }else{
                    stockValue -= m.remainingQuantityMRP.Fulfilled_Amount__c; stockCountTemp.put(prodWare,stockValue);
                    m.MRP.Fulfilled_Amount__c =  m.MRP.Required_Amount__c - m.MRP.Required_Amount__c + m.remainingQuantityMRP.Fulfilled_Amount__c;
                    
                    if(m.MRP.Required_Amount__c == m.MRP.Fulfilled_Amount__c) { m.MRP.Status__c = 'FulFilled';
                    } 
                    
                    mrps2Upsert.add(m.MRP);
                    
                    // create dispatch and dispatch line item also update mrp.
                    
                    if(productSites.containsKey(m.MRP.MRP_Product__c) && productSites.get(m.MRP.MRP_Product__c).size() > 0){
                        List<Inventory_Stock__c> WIISs = productSites.get(m.MRP.MRP_Product__c);
                        Inventory_Stock__c WIIS = (m.MRP.Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
                        SDLI = new Stock_Outward_Line_Item__c();
                        if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Name.isAccessible())SDLI.Name = m.MRP.Name;
                        if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Active__c.isAccessible())SDLI.Active__c = true;
                        if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Process__c.isAccessible())SDLI.Process__c = m.MRP.Process__c;
                        if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isAccessible())SDLI.Schedule__c = m.MRP.Schedule__c;
                        SDLI.MRP_Material_Requirements_Planning__c = m.MRP.Id;
                        if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isAccessible())SDLI.BoM__c = m.MRP.BOM__c;
                        SDLI.Quantity__c = m.remainingQuantityMRP.Fulfilled_Amount__c;
                        if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Status__c.isAccessible())SDLI.Status__c = 'Dispatched';
                        SDLI.Product__c = m.MRP.MRP_Product__c;
                        SDLI.Site_Product_Service_Inventory_Stock__c = WIIS.Id;
                        if(m.MRP.BOM_Requirement_Cost__c != Null){ SDLI.Total_Amount__c = m.MRP.BOM_Requirement_Cost__c;
                            SDLI.Unit_Price__c = (m.MRP.Required_Amount__c != Null && m.MRP.Required_Amount__c > 0)? m.MRP.BOM_Requirement_Cost__c/m.MRP.Required_Amount__c : 0;
                        }
                        SDLIs2Upsert.add(SDLI);
                    }
                }
            }
        } 
        
        if(!flag) {
           
            if(SDLIs2Upsert.size() > 0) DMLManager.updateAsUser(SDLIs2Upsert);

            if(mrps2Upsert.size() > 0) DMLManager.updateAsUser(mrps2Upsert);
            
            populateSchedule();
        }
        return Null;
        }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
            return null;
        }
    } 
    
    public PageReference SaveNew(){
       return null;
    } 
    
    public PageReference Cancel(){
        PageReference Page = new PageReference('/home/home.jsp');
        Page.setRedirect(true);
        return Page;
    }
    
    public pageReference scannerMethod() {
         try{
                List<Product2> productList;
                if(Schema.sObjectType.Product2.isAccessible())
                productList = [select id, name, Barcode__c from Product2 where Barcode__c =: barcode.trim()];
                
                if(productList.size() > 0) addQuantityScanner(productList[0].Id); 
                
                return null;
            }catch(Exception e){ ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
                return null;
            }
    }   
    
    public pageReference addQuantityScanner(String productId) {
                
        for(MRP__c m: MRPs) {
            if(m.MRP_Product__c == productId && m.Fulfilled_Amount__c < m.Required_Amount__c)  { m.Fulfilled_Amount__c += 1; break; }
        }
        
        return null;
    }
    
    public String fetchAllFields(String sObj){
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObj).getDescribe().fields.getMap();
        String allFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(allFields == null || allFields == ''){
                allFields = fieldName;
            }else{
                allFields = allFields + ', ' + fieldName;
            }
        }
        return allFields;
    }
    
    public static String sortBy        { get; set; }
    public static String orderFormat   { get; set; }
    public static String prevSortBy    { get; set; }
    
    public void sortList(){
        MRPWrapperList.sort();
    }
    
    public class MRPWrapper implements Comparable{
        public MRP__c MRP                                               { get; set; }
        public MRP__c remainingQuantityMRP                              { get; set; }         
        public Boolean selected                                         { get; set; } public Decimal remainingQuantity                                { get; set; }
        public Decimal inStock                                          { get; set; }
        public String prod;                                            
        public String mrpn; 
        public String ps;                                            
        public String ms; 
        public String po;   
        public String wo;
        
        public MRPWrapper(MRP__c MRP, Decimal Stock) {
            this.MRP = MRP;
            remainingQuantityMRP = new MRP__c();
            selected = false;
            this.inStock = Stock;
            this.prod = (MRP.MRP_Product__c != Null)? MRP.MRP_Product__r.Name : '';
            this.ps = (MRP.Schedule__c != Null)? MRP.Schedule__r.Name : '';
            this.po = (MRP.Purchase_Order__c != Null)? MRP.Purchase_Order__r.Name : '';
            this.wo = (MRP.Work_Order__c != Null)? MRP.Work_Order__r.Name : '';
            this.mrpn = MRP.Name;
        }
        
        public Integer compareTo(Object objToCompare) {
            if(sortBy == 'prod') { Integer result = prod.compareTo(((MRPWrapper)objToCompare).prod);
                if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1; else return 0;  
            }
            else if(sortBy == 'mrp') { Integer result = mrpn.compareTo(((MRPWrapper)objToCompare).mrpn);
                if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1; else return 0; 
            }
            else if(sortBy == 'ps') { Integer result = ps.compareTo(((MRPWrapper)objToCompare).ps);
                if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1; else return 0; 
            }
            else if(sortBy == 'ms') { Integer result = ms.compareTo(((MRPWrapper)objToCompare).ms);
                if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1; else return 0; 
            }
            else if(sortBy == 'po') { Integer result = po.compareTo(((MRPWrapper)objToCompare).po);
                if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1; else return 0; 
            }
            else { Integer result = wo.compareTo(((MRPWrapper)objToCompare).wo);
                if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1; else return 0; 
            }
        }
    }

}