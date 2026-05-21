trigger PackageTrigger on Package__c (after insert, after update, after delete, after undelete) {
    if(PreventRecursiveLedgerEntry.packageTrgCheck){
        PreventRecursiveLedgerEntry.packageTrgCheck = false;
        Set < Id > orderIds = new Set < Id > ();
        if(!Trigger.Isdelete){
            for(Package__c s: Trigger.New) {
                if(s.ERP7__Logistic__c != Null) 
                    orderIds.add(s.ERP7__Logistic__c);
            }
        } else {
            for(Package__c s: Trigger.Old) {
                if(s.ERP7__Logistic__c != Null) 
                    orderIds.add(s.ERP7__Logistic__c);
            }
        }
        if(orderIds.size() > 0){
            List< Package_List__c > PLs = [Select Id, Name, ERP7__Logistic__c From Package_List__c Where ERP7__Logistic__c In :orderIds];
            if(PLs.size() > 0 && Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()) { upsert PLs; } else{ /* no acccess */ }
        }
    }
}