trigger MRPSimulationTrigger on Material_Requirement_Planning__c (after update) {
    Set<Id> mrpsIds = new Set<Id>();
    
    for (Material_Requirement_Planning__c mrp : Trigger.new) {
        Material_Requirement_Planning__c oldMRP = Trigger.oldMap.get(mrp.Id);
        
        if (!mrp.ERP7__Processed__c && oldMRP.ERP7__Simulate__c != mrp.ERP7__Simulate__c && mrp.ERP7__Simulate__c == true) {            if (mrp.ERP7__Algorithm__c != null && mrp.ERP7__Algorithm__c != '' && mrp.ERP7__Algorithm__c != '--None--') {                mrpsIds.add(mrp.Id);            }        }
        
    }
    
    if (!mrpsIds.isEmpty()) { MRPSimulationHandler.handleAlgorithm(mrpsIds);    }
}