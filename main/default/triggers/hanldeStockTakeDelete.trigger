trigger hanldeStockTakeDelete on ERP7__Stock_Take__c (before delete) {
    if(Trigger.isDelete){
        List<ERP7__Stock_Take_Line_Item__c> stkli = [Select Id,Name,ERP7__Inventory_Stock__c from ERP7__Stock_Take_Line_Item__c where ERP7__Stock_Take__c in :Trigger.oldMap.keySet() and ERP7__Inventory_Stock__c != null];
        if(stkli.size() > 0){
            set<Id> invIDs = new set<Id>();
             set<Id> stkids = new set<Id>();
            for(ERP7__Stock_Take_Line_Item__c stkl : stkli){
                stkids.add(stkl.Id);
                invIDs.add(stkl.ERP7__Inventory_Stock__c);
            }
           List<ERP7__Stock_Inward_Line_Item__c> sili = [Select Id,Name from ERP7__Stock_Inward_Line_Item__c where ERP7__Active__c = true and ERP7__Site_ProductService_InventoryStock__c In :invIDs and ERP7__Stock_Take_Line_Item__c In :stkids] ;
            List<ERP7__Stock_Outward_Line_Item__c> soli = [Select Id,Name from ERP7__Stock_Outward_Line_Item__c where ERP7__Active__c = true and ERP7__Site_Product_Service_Inventory_Stock__c In :invIDs and ERP7__Stock_Take_Line_Item__c In :stkids] ;
            if(sili.size() > 0) delete sili;
            if(soli.size() > 0) delete soli;
        }
    }
}