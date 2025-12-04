trigger CommRollupSummary on Commission__c (after insert, after update, after delete, after undelete) {
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {        
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount__c', 'ERP7__Commission_Amount__c')
        };         
        RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.new, 'ERP7__Commission__c', 'ERP7__Employee_Pay__c', 'ERP7__Employee_Pay__c', '');
    }
     
    if(trigger.isDelete) {
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount__c', 'ERP7__Commission_Amount__c')
        };         
        RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.old, 'ERP7__Commission__c', 'ERP7__Employee_Pay__c', 'ERP7__Employee_Pay__c', '');
    }
}