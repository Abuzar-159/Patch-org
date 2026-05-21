trigger UpdateSampleStock on Sample__c (after insert, after update, after delete, after undelete) {
    Set<Id> stockIds = new Set<Id>();
    if(!Trigger.Isdelete){
        for(Sample__c s : System.Trigger.New){
            if(s.Check_In_Inventory_Stock__c != Null) stockIds.add(s.Check_In_Inventory_Stock__c);
            if(s.Check_Out_Inventory_Stock__c != Null) stockIds.add(s.Check_Out_Inventory_Stock__c);
        }
    } 
    else{
        for(Sample__c s : System.Trigger.Old){
            if(s.Check_In_Inventory_Stock__c != Null) stockIds.add(s.Check_In_Inventory_Stock__c);
            if(s.Check_Out_Inventory_Stock__c != Null) stockIds.add(s.Check_Out_Inventory_Stock__c);
        }
    }
    List<Inventory_Stock__c> stocks = [Select Id, Name From Inventory_Stock__c Where Id In : stockIds];
    if(stocks.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) { update stocks; } else{ /* no access */ }
}