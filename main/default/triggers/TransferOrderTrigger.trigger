trigger TransferOrderTrigger on Transfer_Order__c (after insert, after update) {
    system.debug('TransferOrderTrigger PreventRecursiveLedgerEntry.testCasesTransactions~>'+PreventRecursiveLedgerEntry.testCasesTransactions);
    set<Id> toIds = new set<Id>();
    set<Id> toliIds = new set<Id>();
    
    for (Transfer_Order__c ToNew: Trigger.New){
        if(Trigger.isUpdate){
            Transfer_Order__c toOld = new Transfer_Order__c();
            toOld = Trigger.OldMap.get(ToNew.Id);
            if(TONew.ERP7__Ready_To_Pick_Pack__c && toOld.ERP7__Ready_To_Pick_Pack__c == false) toIds.add(ToNew.Id);
        }
        if(Trigger.isInsert){
            if(TONew.ERP7__Ready_To_Pick_Pack__c) toIds.add(ToNew.Id);
        }
    }
    
    if(toIds.size() > 0){
        List<Transfer_Order_Line_Items__c> toliLst = new List<Transfer_Order_Line_Items__c>();
        toliLst = [Select Id, Name, Transfer_Order__c, Transfer_Order__r.ERP7__Ready_To_Pick_Pack__c from Transfer_Order_Line_Items__c Where Transfer_Order__c In :toIds];
       //changes
        if(toliLst.size()>0){
            system.debug('upserting tolilst');
            //upsert toliLst;
        } 
        //
        for(Transfer_Order_Line_Items__c tl: toliLst){ toliIds.add(tl.Id); }
        system.debug('toliIds 1~>'+toliIds);
        if(toliIds.size() > 0) TransferOrderInventoryUtils.createStockOutwardLineItems(toliIds);
    }
       
    if(!PreventRecursiveLedgerEntry.testCasesTransactions){ 
        system.debug('calling manageTOLogistic');
        SalesOrderTrigger.ManageTransferOrderLogistics(Trigger.IsInsert,Trigger.IsUpdate, JSON.serialize(Trigger.New), JSON.serialize(Trigger.Old));
    }else{
        system.debug('not calling manageTOLogistic~>'+PreventRecursiveLedgerEntry.testCasesTransactions);
    }
   
}