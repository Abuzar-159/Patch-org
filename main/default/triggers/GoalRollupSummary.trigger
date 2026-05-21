trigger GoalRollupSummary on Goal__c (after insert, after update, after delete, after undelete) {
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('COUNT', 'ERP7__Code__c', 'ERP7__Goals_Count__c')
        };         
        RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions, trigger.new, 'ERP7__Goal__c', 'ERP7__Review__c', 'ERP7__Review__c', '');        
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Of_Over_All_Objectives__c', 'ERP7__Total_Of_Over_All_Goals__c')
        };         
        RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.new, 'ERP7__Goal__c', 'ERP7__Review__c', 'ERP7__Review__c', '');
    }
     
    if(trigger.isDelete) {
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('COUNT', 'ERP7__Code__c', 'ERP7__Goals_Count__c')
        };         
        RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions, trigger.old, 'ERP7__Goal__c', 'ERP7__Review__c', 'ERP7__Review__c', '');
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Of_Over_All_Objectives__c', 'ERP7__Total_Of_Over_All_Goals__c')
        };         
        RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.old, 'ERP7__Goal__c', 'ERP7__Review__c', 'ERP7__Review__c', '');
    }
}