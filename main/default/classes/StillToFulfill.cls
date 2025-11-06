public with sharing class StillToFulfill {
    public String LogId                                                      { get; set; }
    public String SOLIItemFields                                             { get; set; } 
    public Integer pickItems                                                 { get; set; }
    public Integer packItems                                                 { get; set; }
    public Integer shipItems                                                 { get; set; }
    public ERP7__Logistic__c LO                                              { get; set; } 
    public List <ERP7__Logistic_Line_Item__c> solisItemList                  { get; set; }
    public ERP7__Sales_Order__c SO                                           { get; set; } 
    public List <ERP7__Sales_Order_Line_Item__c> soliItemList                { get; set; }
    public String selectedAccout                                             { get; set; }
    public OutboundLogistics PSC                                             { get; set; }
    public String Back2SO                                                    { get; set; }
    
    public StillToFulfill() {
        LogId = ApexPages.currentPage().getParameters().get('soId');
        SOLIItemFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c') + ', ERP7__Product__r.Name, ERP7__Product__r.Picture__c, ERP7__Product__r.Family, ERP7__Sales_Order__r.Name ';
        StillToFulfillCustomSO();
    }
    public StillToFulfill(OutboundLogistics controller) {
        LogId = ApexPages.currentPage().getParameters().get('loId');
        SOLIItemFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c') + ', ERP7__Product__r.Name, ERP7__Product__r.Picture__c, ERP7__Product__r.Family, ERP7__Logistic__r.Name ';
        PSC = controller;
        StillToFulfillCustom();
    }
    
    public void StillToFulfillCustom(){ 
        if (LogId != null) {
            Back2SO = '';
            List<ERP7__Logistic__c> SOS = [Select Id, Name from ERP7__Logistic__c where Id =:LogId or Name =:LogId Limit 1];
            if(SOS.size() > 0){
                shipItems = packItems = pickItems = 0;
                LO = SOS[0];
                solisItemList = Database.query('select ' + String.escapeSingleQuotes(SOLIItemFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c =:LogId or ERP7__Logistic__r.Name =:LogId');
                for(ERP7__Logistic_Line_Item__c so_li :solisItemList){
                    if(so_li.Picked_Quantity__c != so_li.Quantity__c) pickItems++; 
                    if(so_li.Picked_Quantity__c != Null && so_li.Picked_Quantity__c > 0 && ((so_li.Packed_Quantity__c != Null && so_li.Picked_Quantity__c > so_li.Packed_Quantity__c) || so_li.Packed_Quantity__c == Null)) packItems++; 
                    if(so_li.Packed_Quantity__c != Null && so_li.Packed_Quantity__c > 0 && ((so_li.Shipped_Quantity__c != Null && so_li.Packed_Quantity__c > so_li.Shipped_Quantity__c) || so_li.Shipped_Quantity__c == Null)) shipItems++;
                }
                LogId = LO.Id;
                PSC.LogisticId = LO.Id;
                selectedAccout = LO.Name;
                PSC.redirect2NextTab();
                PSC.soSelectedWrapperList = new List<OutboundLogistics.Wrappers>();
                OutboundLogistics.Wrappers wrap = new OutboundLogistics.Wrappers();
                wrap.Logistic = Database.query('select ' + String.escapeSingleQuotes(PSC.logFields) + ', ERP7__Sales_Order__r.Name , ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where Id = :LogId');
                PSC.soSelectedWrapperList.add(wrap);
            }
        }
    }
    
    public void StillToFulfillCustomSO(){ 
        if (LogId != null) {
            List<ERP7__Sales_Order__c> SOS = [Select Id, Name from ERP7__Sales_Order__c where Id =:LogId or Name =:LogId Limit 1];
            if(SOS.size() > 0){
                Back2SO = SOS[0].Id;
                shipItems = packItems = pickItems = 0;
                SO = SOS[0];
                soliItemList = Database.query('select ' + String.escapeSingleQuotes(SOLIItemFields) + ' from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c =:LogId or ERP7__Sales_Order__r.Name =:LogId');
                
                Set<Id> productIds = new Set<Id>();
                for(ERP7__Sales_Order_Line_Item__c so_li :soliItemList){
                    productIds.add(so_li.product__c);
                }
                Map < Id, List<ERP7__Inventory_Stock__c> > ProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
                for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c,
                        ERP7__Warehouse__c, ERP7__product__c,
                        ERP7__Number_of_Item_In_Stock__c, ERP7__Number_of_Item_Purchased_In__c,
                        ERP7__Number_of_Items_Dispatched__c, ERP7__No_of_Items_Sold__c
                        From ERP7__Inventory_Stock__c
                        Where ERP7__product__c IN: productIds And
                        ERP7__Active__c = true And
                        ERP7__Number_of_Item_In_Stock__c > 0
                    ]) {
                    if(ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)){
                        ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
                    }else{
                        List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>();
                        WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks);
                        ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
                    }
                    
                }
                
                for(ERP7__Sales_Order_Line_Item__c so_li :soliItemList){
                    if(so_li.Picked_Quantity__c != so_li.Quantity__c) pickItems++; 
                    if(so_li.Picked_Quantity__c != Null && so_li.Picked_Quantity__c > 0 && ((so_li.Packed_Quantity__c != Null && so_li.Picked_Quantity__c > so_li.Packed_Quantity__c) || so_li.Packed_Quantity__c == Null)) packItems++; 
                    if(so_li.Packed_Quantity__c != Null && so_li.Packed_Quantity__c > 0 && ((so_li.Shipped_Quantity__c != Null && so_li.Packed_Quantity__c > so_li.Shipped_Quantity__c) || so_li.Shipped_Quantity__c == Null)) shipItems++;
                    Decimal proStockCount = 0;
                    if (ProductMap2Stock != null && ProductMap2Stock.keyset().contains(so_li.ERP7__Product__c)) {
                        for(ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(so_li.ERP7__Product__c)){
                            proStockCount += IS.ERP7__Number_of_Item_In_Stock__c; 
                        }
                    } 
                    so_li.ERP7__Reserved_Quantity__c = proStockCount;
                }
                LogId = SO.Id; 
                selectedAccout = SO.Name;
            }
        }
    }
    
    public PageReference Pick() { 
        return PSC.redirect2NextTab();
    }
    
    public list <ERP7__Logistic__c> getAccountList() {
        return [Select Id, Name From ERP7__Logistic__c limit 10000];
    }
    
}