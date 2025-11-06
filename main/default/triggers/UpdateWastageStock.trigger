trigger UpdateWastageStock on Material_Wastage__c (after insert, after update, after delete, after undelete) {
    Set<Id> stockIds = new Set<Id>();
    if(!Trigger.Isdelete){
        for(Material_Wastage__c s : System.Trigger.New){
            if(s.Site_Item_Inventory_Stock__c != Null) stockIds.add(s.Site_Item_Inventory_Stock__c);
        }
    }
    else{
        for(Material_Wastage__c s : System.Trigger.Old){
            if(s.Site_Item_Inventory_Stock__c != Null) stockIds.add(s.Site_Item_Inventory_Stock__c);
        }
    }
    List<Inventory_Stock__c> stocks = [Select Id, Name From Inventory_Stock__c Where Id In : stockIds];
    if(stocks.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) { update stocks; } else { /* no access */ }
}