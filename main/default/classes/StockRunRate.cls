public with sharing class StockRunRate {
    public List<RunRate> runRates                           { get; set; }
    public List<SelectOption> status                        { get; set; }
    public List<SelectOption> leadTimeType                  { get; set; }
    public String statusStr                                 { get; set; }
    public String renderParam                               { get; set; }
    public String leadTimeTypeStr                           { get; set; }
    public String srcStr                                    { get; set; }
    public Date wsFrom                                      { get; set; }
    public Date wsTo                                        { get; set; }
    public Date ipFrom                                      { get; set; }
    public Date ipTo                                        { get; set; }
    public Date opFrom                                      { get; set; }
    public Date opTo                                        { get; set; }
    public Employees__c Employee                            { get; set; }
    public List<SelectOption> channelSites                  { get; set; }
    public Id selectedSite                                  { get; set; }
    
    public static Map<String, Schema.SObjectType> schemaMap;
    
    public StockRunRate(){
        schemaMap = Schema.getglobalDescribe();
        runRates = new List<RunRate>();
        
        String renderP = apexpages.currentpage().getparameters().get('renderas');
        renderParam = (renderP == 'pdf')? renderP : '';
        
        leadTimeType = new List<SelectOption>();
        leadTimeType.add(new SelectOption('Purchase', 'Purchase'));
        leadTimeType.add(new SelectOption('Manufacture', 'Manufacture'));
        
        statusStr = srcStr = '';
        leadTimeTypeStr = 'Purchase';
        
        wsFrom = system.today();
        wsTo = system.today().addDays(7);
        
        ipFrom = system.today().addMonths(-3);
        ipTo = system.today();
        
        opFrom = system.today().addMonths(-3);
        opTo = system.today();
        
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
            
        try{ customController(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    } 
    
    public PageReference customController(){
        schemaMap = Schema.getglobalDescribe();
        runRates = new List<RunRate>();
        String completeStatus = 'Complete';
        List<Product2> products;
        if(Schema.sObjectType.Product2.isAccessible()){
        products = [Select Id, Name, isActive, Barcode__c, Purchase_Lead_Time_days__c, Manufacture_Lead_Time_days__c, Picture__c From Product2 Where isActive = true order by Name ASC];}
        
        //Rules
        List<ERP7__Reordering_Rule__c> ReorderingRules = [Select Id, Name, ERP7__Base_Quantity__c, ERP7__Channel__c, ERP7__Lead_Time__c, 
                                                            ERP7__Maximum_Quantity__c, ERP7__Minimum_Quantity__c, ERP7__Product__c, ERP7__Warning_Quantity__c,
                                                            ERP7__Quantity_Multiple__c, ERP7__Stock_Quantity__c, ERP7__Warehouse__c
                                                            From ERP7__Reordering_Rule__c
                                                            Where ERP7__Product__c In :products];
                                                            
        Map<Id, List<ERP7__Reordering_Rule__c>> proRules = new Map<Id, List<ERP7__Reordering_Rule__c>>();
        for(Product2 P : products) proRules.put(P.Id, new List<ERP7__Reordering_Rule__c>());
        for(ERP7__Reordering_Rule__c RR : ReorderingRules){
            proRules.get(RR.ERP7__Product__c).add(RR);
        }
        
        // Current Stock
        String allFields2 = fetchAllFields('ERP7__Inventory_Stock__c');
        UtilClass.FlSCheck(allFields2.split(',') ,'ERP7__Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name, Product__r.Name';
        String query2 = 'select ' + allFields2 + ' from ERP7__Inventory_Stock__c where Product__c In :products '; 
        query2 += 'and ERP7__Warehouse__c = :selectedSite order by Product__r.Name ASC';
        List<Inventory_Stock__c> warehouseStocks;
        if(Schema.sObjectType.ERP7__Inventory_Stock__c.isAccessible()){
        warehouseStocks = Database.query(query2);}
        
        //Outward Projection
        String allFields3 = fetchAllFields('ERP7__Stock_Outward_Line_Item__c');
        UtilClass.FlSCheck(allFields3.split(',') ,'ERP7__Stock_Outward_Line_Item__c');
        allFields3 += ', Product__r.Name, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c';
        String query3 = 'select ' + allFields3 + ' from Stock_Outward_Line_Item__c where ERP7__Active__c = true And Product__c In :products And CreatedDate >=: wsFrom And CreatedDate <=: wsTo and ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c = :selectedSite order by Product__r.Name ASC';
        List<Stock_Outward_Line_Item__c> PPLIs = new List<Stock_Outward_Line_Item__c>(); 
        if(wsFrom != Null && wsTo != Null) if(Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()){PPLIs = Database.query(query3);}
        
        //Inward Projection New
        String allFields9 = fetchAllFields('ERP7__Stock_Inward_Line_Item__c');
        UtilClass.FlSCheck(allFields9.split(',') ,'ERP7__Stock_Inward_Line_Item__c');
        allFields9 += ', Product__r.Name, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c';
        String query9 = 'select ' + allFields9 + ' from Stock_Inward_Line_Item__c where ERP7__Active__c = true And Product__c In :products And CreatedDate >=: ipFrom And CreatedDate <=: ipTo and ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c = :selectedSite';
        if(leadTimeTypeStr == 'Purchase') query9 += ' and ERP7__Purchase_Line_Items__c != Null';
        else query9 += ' and ERP7__Work_Order_Line_Items__c != Null';
        query9 += ' order by Product__r.Name ASC';
        List<Stock_Inward_Line_Item__c> SILIs = new List<Stock_Inward_Line_Item__c>(); 
        if(ipFrom != Null && ipTo != Null)if(Schema.sObjectType.Stock_Inward_Line_Item__c.isAccessible()){SILIs = Database.query(query9);}
        
        for(Product2 P : products){
            RunRate RR = new RunRate();
                
                // Current Stock
                boolean reachedProduct = false;
                for(Inventory_Stock__c WIIS : warehouseStocks){
                    if(WIIS.Product__c == P.Id){
                        RR.currentStock += WIIS.Number_of_Item_In_Stock__c;
                        reachedProduct = true;
                    }
                    else if(reachedProduct) break;
                }
                
                //Outward Projection
                boolean reachedProductPPLI = false;
                for(Stock_Outward_Line_Item__c PPLI : PPLIs){
                    if(PPLI.Product__c == P.Id){
                        if(PPLI.Quantity__c != Null) RR.salesStock += PPLI.Quantity__c;
                        reachedProductPPLI = true;
                    }
                    else if(reachedProductPPLI) break;
                }
                
                //Stock Rules
                boolean ruled = false;
                for(ERP7__Reordering_Rule__c Rule : proRules.get(P.Id)){
                    if(Rule.ERP7__Warehouse__c == selectedSite && Rule.ERP7__Channel__c == Employee.Channel__c){
                        if(Rule.ERP7__Maximum_Quantity__c != Null && RR.currentStock >= Rule.ERP7__Maximum_Quantity__c) { RR.status = 'Over Stock'; RR.iconStr = 'warning'; }
                        else if(Rule.ERP7__Maximum_Quantity__c != Null && Rule.ERP7__Minimum_Quantity__c != Null && RR.currentStock > Rule.ERP7__Minimum_Quantity__c && RR.currentStock < Rule.ERP7__Maximum_Quantity__c ) { RR.status = 'In Stock'; RR.iconStr = 'success';}
                        else if(Rule.ERP7__Base_Quantity__c != Null && Rule.ERP7__Minimum_Quantity__c != Null && RR.currentStock > Rule.ERP7__Base_Quantity__c && RR.currentStock < Rule.ERP7__Minimum_Quantity__c ) { RR.status = 'Low Stock'; RR.iconStr = 'info'; }
                        else if(Rule.ERP7__Base_Quantity__c != Null && RR.currentStock <= Rule.ERP7__Base_Quantity__c) { RR.status = 'Out of Stock'; RR.iconStr = 'danger'; }
                        ruled = true;
                        break;
                    }
                }
                if(!ruled){
                    if(RR.currentStock > 0) { RR.status = 'In Stock'; RR.iconStr = 'success'; }
                    else { RR.status = 'Out of Stock'; RR.iconStr = 'danger'; }
                }
               
                //Sales (Week Avg)
                if(wsFrom != Null && wsTo != Null && wsTo > wsFrom && opFrom != Null && opTo != Null && opTo > opFrom){
                     Integer wsDays =  wsFrom.daysBetween(wsTo);
                     Integer opDays =  opFrom.daysBetween(opTo);
                     RR.outStock = ((RR.salesStock * opDays) / wsDays).setscale(2);
                }
                
                //Inward Projection New
                for(Stock_Inward_Line_Item__c SILI : SILIs){
                    if(SILI.Product__c == P.Id){
                        if(SILI.Quantity__c != Null) RR.inwardStock += SILI.Quantity__c;
                    }
                }
              
                RR.product = P;
            runRates.add(RR);
        }
        return Null;
    }
    
    public PageReference PrintPreview() {
        return Page.RunRatePDF;
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
    
    public class RunRate{
        public Product2 product                                 { get; set; }
        public String status                                    { get; set; }
        public String iconStr                                   { get; set; }
        public Decimal currentStock                             { get; set; }
        public Decimal salesStock                               { get; set; }
        public Decimal inwardStock                              { get; set; }
        public Decimal outStock                                 { get; set; }
        
        public RunRate(){
            status = iconStr = '';
            currentStock = salesStock = inwardStock = outStock = 0;
        }
    }
}