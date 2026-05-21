trigger MRPTrigger on MRP__c (after insert, after update,before delete, after delete, after undelete) {
    if(PreventRecursiveLedgerEntry.MRPFlowTrigger){
        PreventRecursiveLedgerEntry.MRPFlowTrigger = false;
        /* if (Trigger.isBefore && Trigger.isDelete) {
            Set<Id> moIds = new Set<Id>();
            for (MRP__c mrp : Trigger.old) {
                if (mrp.ERP7__MO__c != null) {
                    moIds.add(mrp.ERP7__MO__c);
                }
            }
            if (!moIds.isEmpty()) {
                Map<Id, ERP7__Manufacturing_Order__c> moMap = new Map<Id, ERP7__Manufacturing_Order__c>([
                    SELECT Id, Status__c 
                    FROM ERP7__Manufacturing_Order__c 
                    WHERE Id IN :moIds 
                    AND Status__c IN ('Draft', 'In Progress')
                ]);
                for (MRP__c mrp : Trigger.old) {
                    if (mrp.ERP7__MO__c != null && moMap.containsKey(mrp.ERP7__MO__c)) {
                        mrp.addError('Cannot delete MRP record because the associated Manufacturing Order is in Draft or In Progress status.');
                    }
                }
            }
        }*/
    //MRPTrigger.ManageSiteDispatchLineItems(Trigger.isExecuting,Trigger.isBefore,Trigger.isAfter,Trigger.isInsert,Trigger.isUpdate,Trigger.isUnDelete,Trigger.isDelete,Trigger.new,Trigger.old);
    MRPTrigger.ManageSiteDispatchLineItems(Trigger.isExecuting,Trigger.isBefore,Trigger.isAfter,Trigger.isInsert,Trigger.isUpdate,Trigger.isUnDelete,Trigger.isDelete,JSON.serialize(Trigger.new),JSON.serialize(Trigger.old));
    //MRPTrigger.MRPsRollupSummary(Trigger.isExecuting,Trigger.isBefore,Trigger.isAfter,Trigger.isInsert,Trigger.isUpdate,Trigger.isUnDelete,Trigger.isDelete,Trigger.new,Trigger.old);
    MRPTrigger.MRPsRollupSummary(Trigger.isExecuting,Trigger.isBefore,Trigger.isAfter,Trigger.isInsert,Trigger.isUpdate,Trigger.isUnDelete,Trigger.isDelete,JSON.serialize(Trigger.new),JSON.serialize(Trigger.old));
    }
}