public With Sharing class addProducts {
    @AuraEnabled
    public static WrapLst getProducts(String venId,String searchString,string searchFamily,String DCId){
        WrapLst wrap = new WrapLst();
        List<wrapper> wraplist = new List<wrapper>();
        List<Product2> prodList = new List<Product2>();
        string query = 'Select Id,Name,Description from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true';
        
        if(venId != null && venId != ''){
            query+= ' and ERP7__Default_Vendor__c = :venId';
        }
        if(searchFamily != null && searchFamily != ''){
            query+= ' and Family = :searchFamily';
        }
        if(searchString != null && searchString != ''){
            query+= ' and (Name LIKE :searchString or ProductCode LIKE :searchString or StockKeepingUnit LIKE :searchString )';
        }
        query+= ' Order By Name Limit 100';
        prodList = Database.query(query);
        if(prodList.size() == 0){
            set<Id> productIds = new set<Id>();
            string status = 'Approved';
            query = 'Select Id,Name,ERP7__Product__c from ERP7__Approved_Vendor__c where ERP7__Product__c !=null and ERP7__Product__r.ERP7__Issue_Purchase_Order__c = true and ERP7__Status__c = :status';
            
            if(venId != null && venId != ''){
                query+= ' and ERP7__Default_Vendor__c = :venId';
            }
            if(searchFamily != null && searchFamily != ''){
                query+= ' and ERP7__Product__r.Family = :searchFamily';
            }
            if(searchString != null && searchString != ''){
                query+= ' and (ERP7__Product__r.Name LIKE :searchString or ERP7__Product__r.ProductCode LIKE :searchString or ERP7__Product__r.StockKeepingUnit LIKE :searchString )';
            }
            query+= ' Order By Name Limit 100';
            
           List<ERP7__Approved_Vendor__c> approvedVendors = Database.query(query);
            for(ERP7__Approved_Vendor__c appVen:approvedVendors){
                productIds.add(appVen.ERP7__Product__c);
            }
            system.debug('productIds : '+productIds.size());
            prodList = [Select Id,Name,Description  from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true and Id IN: productIds limit 100];
        }
        if(prodList.size() == 0){
            
             query = 'Select Id,Name,Description from Product2 where IsActive = true and ERP7__Issue_Purchase_Order__c = true';
            
            if(venId != null && venId != '' && (searchFamily == null || searchFamily == '') && (searchString == null || searchString == '')){
                wrap.Msg='No products avaialble to view based on selected vendor';
            }
            else if(searchFamily != null && searchFamily != ''  && (searchString == null || searchString == '')){
                wrap.Msg='No products avaialble to view based on selected family';
            }
            if(searchString != null && searchString != ''){
                 wrap.Msg='No products avaialble to view based on searched item';
            }
            query+= ' Order By Name Limit 100';
            prodList = Database.query(query);
        }
        system.debug('prodList : '+prodList);
        set<Id> siteIds = new set<Id>();
        set<Id> productIds = new set<Id>();
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(DCId != null && DCId != '' && prodList.size() > 0){
            
            List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                  where Id=:DCId and ERP7__Active__c=true];                
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
            for(Product2 pr:prodList)
                productIds.add(pr.Id);
            
            
            if(productIds.size() > 0) {
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                                Where product__c In: productIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds And                                                 
                                                ERP7__Number_of_Item_In_Stock__c > 0
                                               ];
            }
            
            
        }
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        for(Id prId:productIds){
            Decimal stock=0;
            for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                if(prId == inven.product__c){
                    stock += inven.ERP7__Number_of_Item_In_Stock__c;
                }
            }
            stockView.put(prId,stock);                
        }
        for(Product2 pr:prodList){
            wrapper wrapNew = new wrapper();
            wrapNew.prod = pr;
            if(stockView.containsKey(pr.Id))  wrapNew.stock = stockView.get(pr.Id);
            else  wrapNew.stock = 0;
            wraplist.add(wrapNew);
        }
        system.debug('wraplist : '+wraplist.size());
        if(wraplist.size() > 0){
          wrap.wrapList = wraplist;
        } 
        else {
            wrap.Msg='No products avaialble to view';
        }
        return wrap;
    }
    public class wrapper{
        @AuraEnabled public Product2 prod{get;set;}
        @AuraEnabled public Decimal stock {get;set;}
    }
    public class WrapLst{
        @AuraEnabled public List<wrapper> wrapList {get;set;}
        @AuraEnabled public String Msg {get;set;}
    }
}