public with sharing class SalesOrderFulfillment {
    public Id salepointId                                                                                       { get; set; }
    public List<Stock_Outward_Line_Item__c> PPLIS                                                            { get; set; }
    public List<Sales_Order_Line_Item__c> SOLIS                                                                 { get; set; }
    public Map<Sales_Order_Line_Item__c, Stock_Outward_Line_Item__c> solisPPLI                               { get; set; }
    public Map<Id, Stock_Outward_Line_Item__c> PPLImap                                                       { get; set; }
    public List<Inventory_Stock__c> warehouseStocks                                              { get; set; }
    public Map<Id, Inventory_Stock__c> stockMap                                                  { get; set; }
    public List<StockWrapper> StockWrapperList                                                                  { get; set; }
    public String errMsg                                                                                        { get; set; }
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    public static Map<String, Schema.SObjectType> schemaMap;
    
    public SalesOrderFulfillment(ApexPages.StandardController controller) {
        if(ApexPages.currentPage().getParameters().get('id') != null)salepointId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('id'),'UTF-8');
        customContructor();
        orderFormat = 'DESC';
        prevSortBy = '';
    }
    
    public Void customContructor(){
        String Requested = 'Requested';
        schemaMap = Schema.getGlobalDescribe();
        solisPPLI = new Map<Sales_Order_Line_Item__c, Stock_Outward_Line_Item__c>();
        PPLImap = new Map<Id, Stock_Outward_Line_Item__c>();
        stockMap = new Map<Id, Inventory_Stock__c>();
        StockWrapperList = new List<StockWrapper>();
        errMsg = '';
        String allFieldss = UtilClass.selectStarFromSObject('Sales_Order_Line_Item__c');
        UtilClass.FlSCheck(allFieldss.split(',') ,'Sales_Order_Line_Item__c');
        allFieldss += ', Sales_Order__r.Name, Sales_Order__r.Is_Back_Order__c, Sales_Order__r.Order_Date__c, Sales_Order__r.Account__r.Name, Sales_Order__r.Contact__r.Name, Sales_Order__r.Channel__c, Product__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c';
        String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ' from Sales_Order_Line_Item__c where Order_Line_Status__c = :Requested And Sales_Order__r.Channel__c = :salepointId order by Sales_Order__r.Order_Date__c ASC';
        if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible())SOLIS = Database.query(querys);
        
        List<String> soliIds = new List<String>();
        for(Sales_Order_Line_Item__c soli : SOLIS){
            soliIds.add(soli.Id);
        }
        
        String allFieldsp = UtilClass.selectStarFromSObject('Stock_Outward_Line_Item__c');
        UtilClass.FlSCheck(allFieldsp.split(',') ,'Stock_Outward_Line_Item__c');
        allFieldsp += ', Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Sales_Order__r.Is_Back_Order__c';
        String queryp = 'select ' + String.escapeSingleQuotes(allFieldsp) + ' from Stock_Outward_Line_Item__c where Sales_Order_Line_Item__c In :soliIds And Status__c = :Requested order by CreatedDate ASC';
        if(Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible())PPLIS = Database.query(queryp);
       
        for(Stock_Outward_Line_Item__c ppli : PPLIS){
           if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Sales_Order_Line_Item__c.isAccessible()) PPLImap.put(ppli.Sales_Order_Line_Item__c,ppli);
        }
       
        for(Sales_Order_Line_Item__c soli : SOLIS){
            if(PPLImap.containsKey(soli.Id)) solisPPLI.put(soli,PPLImap.get(soli.Id));
        }
       
        Set<Id> stockIds = new Set<Id>();
        for(Stock_Outward_Line_Item__c ppli : PPLIS){
           if(Schema.sobjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isAccessible())  stockIds.add(ppli.Site_Product_Service_Inventory_Stock__c);
        }
       
        String allFields2 = UtilClass.selectStarFromSObject('Inventory_Stock__c');
        UtilClass.FlSCheck(allFields2.split(',') ,'Inventory_Stock__c');
        allFields2 += ', Warehouse__r.Name';
        String query2 = 'select ' + String.escapeSingleQuotes(allFields2) + ' from Inventory_Stock__c where Id In :stockIds order by CreatedDate ASC';
        if(Schema.sObjectType.Inventory_Stock__c.isAccessible())warehouseStocks = Database.query(query2);
        
        for(Inventory_Stock__c WIIS : warehouseStocks){
            stockMap.put(WIIS.Id,WIIS);
        }
     
        
        for(Sales_Order_Line_Item__c soli : SOLIS){
            if(solisPPLI.containsKey(soli)){
                StockWrapper stockWrap = new StockWrapper(soli, solisPPLI.get(soli), stockMap.get(solisPPLI.get(soli).Site_Product_Service_Inventory_Stock__c));
                StockWrapperList.add(stockWrap);
            }
        }
       
       
        if(!(StockWrapperList.size() > 0)){
            errMsg = 'No sales order to fulfill !';
        }
    }
    
    public Void EvaluateStock(){
        Map<Id, Decimal> stockCountMap = new Map<Id, Decimal>();
        for(Inventory_Stock__c WIIS : warehouseStocks){
            Decimal tempCount;
            if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) tempCount = WIIS.Number_of_Item_In_Stock__c;
            for(StockWrapper sw : StockWrapperList){
                if(WIIS.Id == sw.Stock.Id && sw.fulfilled){
                    tempCount -= sw.SOLI.Quantity__c;
                }
            }
            stockCountMap.put(WIIS.Id,tempCount);
        }
        for(StockWrapper sw : StockWrapperList){
            sw.internalCount = stockCountMap.get(sw.Stock.Id);
        }
    }
    
    public Void FulfillOrders(){
        List<Stock_Outward_Line_Item__c> pplis2Update = new List<Stock_Outward_Line_Item__c>();                                                      
        List<Sales_Order_Line_Item__c> solis2Update = new List<Sales_Order_Line_Item__c>();                                                                
        for(StockWrapper sw : StockWrapperList){
            if(sw.fulfilled){
                sw.PPLI.Status__c = 'Reserved'; 
                sw.SOLI.Order_Line_Status__c = 'Reserved'; 
                pplis2Update.add(sw.PPLI);
                solis2Update.add(sw.SOLI);
            }
        }
        if(pplis2Update.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){hasAccess=true; update pplis2Update;} else{ hasAccess=false; errormsg='You are not allowed to update records'; }
        if(solis2Update.size() > 0 && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Order_Line_Status__c.isUpdateable()){hasAccess=true; update solis2Update;} else{ hasAccess=false; errormsg='You are not allowed to update records'; }
        customContructor();
    }
    
    public PageReference OrderConsole(){
        PageReference Page = new PageReference('/apex/OrderConsole?id='+salepointId);
        Page.setRedirect(true);
        return Page;
    }
    
    public static String sortBy        { get; set; }
    public static String orderFormat   { get; set; }
    public static String prevSortBy    { get; set; }
    
    public void sortList(){
        StockWrapperList.sort();
    }
    
    public class StockWrapper implements Comparable{
        public Sales_Order_Line_Item__c SOLI                          { get; set; } 
        public Inventory_Stock__c Stock                { get; set; }            
        public Stock_Outward_Line_Item__c PPLI                     { get; set; } 
        public Decimal internalCount                                  { get; set; } 
        public String  errMsg                                         { get; set; }
        public Boolean  fulfilled                                     { get; set; }
        public String  prod;                                            
        public String ord; 
        public String  cusAcc;                                            
        public String cusCon; 
        public String  ordDt;   
        public String  stockName;                                          
        
        public StockWrapper(Sales_Order_Line_Item__c SOLI, Stock_Outward_Line_Item__c PPLI, Inventory_Stock__c WIIS) {
            this.Stock = WIIS;
            this.SOLI = SOLI;
            this.PPLI = PPLI;
            this.internalCount = This.Stock.Number_of_Item_In_Stock__c;
            fulfilled = false;
            this.errMsg = '';
            
            if(Schema.sobjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) this.prod = SOLI.Product__r.Name;
            if(Schema.sobjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible() && Schema.sobjectType.Sales_Order__c.fields.Name.isAccessible()) this.ord = SOLI.Sales_Order__r.Name;
            if(Schema.sobjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible() && Schema.sobjectType.Sales_Order__c.fields.Account__c.isAccessible())  this.cusAcc = SOLI.Sales_Order__r.Account__r.Name;
            if(Schema.sobjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible() && Schema.sobjectType.Sales_Order__c.fields.Account__c.isAccessible()) this.cusCon = SOLI.Sales_Order__r.Contact__r.Name;
            if(Schema.sobjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible() && Schema.sobjectType.Sales_Order__c.fields.Account__c.isAccessible()) this.ordDt = String.valueof(SOLI.Sales_Order__r.Order_Date__c);
            if(Schema.sobjectType.Inventory_Stock__c.fields.Name.isAccessible()) this.stockName = WIIS.Name;
        }
        
        public Integer compareTo(Object objToCompare) {
            if(sortBy == 'product') {
                Integer result = prod.compareTo(((StockWrapper)objToCompare).prod);
               if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1;
               else return 0; 
            }
            else if(sortBy == 'order') {
                Integer result = ord.compareTo(((StockWrapper)objToCompare).ord);
                 if(result <= 0 && result != null) return (orderFormat == 'ASC')? result : result * -1;
               else return 0;
            }
            else if(sortBy == 'customer') {
                Integer result = cusAcc.compareTo(((StockWrapper)objToCompare).cusAcc);
                 if(result <= 0 && result != null) return (orderFormat == 'ASC')? result : result * -1;
               else return 0;
            }
            else if(sortBy == 'contact') {
                Integer result = cusCon.compareTo(((StockWrapper)objToCompare).cusCon);
                 if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1;
               else return 0;
            }
            else if(sortBy == 'stock') {
                Integer result = stockName.compareTo(((StockWrapper)objToCompare).stockName);
                 if(result <= 0 && result != null ) return (orderFormat == 'ASC')? result : result * -1;
               else return 0;
            }
            else {
                Integer result = ordDt.compareTo(((StockWrapper)objToCompare).ordDt);
                 if(result <= 0 && result != null) return (orderFormat == 'ASC')? result : result * -1;
               else return 0;
            }
        }
    }
}