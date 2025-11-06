trigger BOMRollupSummary on ERP7__BOM__c (after insert, after update, after delete, after undelete, before delete) {
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {        
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Cost_Price__c', 'ERP7__Manufacturing_Assembly_Costs__c')
        };  
        if(PreventRecursiveLedgerEntry.rollUpProcess){ //added to avoid recursion
            RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.new, 'ERP7__BOM__c', 'ERP7__Manufacturing_Assembly_Process__c', 'ERP7__Process__c', '');
            // PreventRecursiveLedgerEntry.rollUpProcess = false;
        }
    }
     
    if(trigger.isDelete && trigger.isAfter) {
        list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Cost_Price__c', 'ERP7__Manufacturing_Assembly_Costs__c')
        };   
        if(PreventRecursiveLedgerEntry.rollUpProcess){ //added to avoid recursion
            RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.old, 'ERP7__BOM__c', 'ERP7__Manufacturing_Assembly_Process__c', 'ERP7__Process__c', '');
            // PreventRecursiveLedgerEntry.rollUpProcess = false;
        }
    }
    
    if(trigger.isDelete && trigger.isBefore) {
        // Check for Manufacturing Orders with Draft or In Progress status
        Set<Id> versionIds = new Set<Id>();
        for(ERP7__BOM__c bom : trigger.old) {
            if(bom.ERP7__BOM_Version__c != null) {
                versionIds.add(bom.ERP7__BOM_Version__c);
            }
        }
        
        if(!versionIds.isEmpty()) {
            List<ERP7__Manufacturing_Order__c> relatedOrders = [
                SELECT Id, ERP7__Version__c 
                FROM ERP7__Manufacturing_Order__c 
                WHERE ERP7__Version__c IN :versionIds 
                AND ERP7__Status__c IN ('Draft', 'In Progress')
            ];
            
            Map<Id, List<ERP7__Manufacturing_Order__c>> versionToOrdersMap = new Map<Id, List<ERP7__Manufacturing_Order__c>>();
            for(ERP7__Manufacturing_Order__c order : relatedOrders) {
                if(!versionToOrdersMap.containsKey(order.ERP7__Version__c)) {
                    versionToOrdersMap.put(order.ERP7__Version__c, new List<ERP7__Manufacturing_Order__c>());
                }
                versionToOrdersMap.get(order.ERP7__Version__c).add(order);
            }
            
           /* for(ERP7__BOM__c bom : trigger.old) {
                if(bom.ERP7__BOM_Version__c != null && versionToOrdersMap.containsKey(bom.ERP7__BOM_Version__c)) {
                    bom.addError('Cannot delete BOM because its Version is associated with Manufacturing Orders in Draft or In Progress status.');
                }
            }*/
            for (ERP7__BOM__c bom : Trigger.old) {
    if (bom.ERP7__BOM_Version__c != null && versionToOrdersMap.containsKey(bom.ERP7__BOM_Version__c)) {
        
        // Check org/user language
        String userLang = UserInfo.getLocale(); // or UserInfo.getLanguage()
        
        String errorMsg;
        if (userLang != null && userLang.startsWith('fr')) {
            errorMsg = 'Impossible de supprimer la nomenclature car sa version est associée à des ordres de fabrication en statut Brouillon ou En cours.';
        } else {
            errorMsg = 'Cannot delete BOM because its Version is associated with Manufacturing Orders in Draft or In Progress status.';
        }

        bom.addError(errorMsg);
    }
}

        }
    }
    
    if(PreventRecursiveLedgerEntry.BOMsProcess) { 
        if(Trigger.isAfter && Trigger.isInsert) 
            BOMTriggerHelper.createSupportingBOMs(Trigger.isInsert,Trigger.isUpdate,Trigger.New); 
    }
    if(PreventRecursiveLedgerEntry.BOMsProcess) { 
        if(Trigger.isAfter && Trigger.isUpdate) 
            BOMTriggerHelper.updateSupportingBOMs(Trigger.isInsert,Trigger.isUpdate,Trigger.New); 
    }    
    if(PreventRecursiveLedgerEntry.BOMsProcess) { 
        if(Trigger.isBefore && Trigger.isDelete) 
            BOMTriggerHelper.deleteSupportingBoms(Trigger.Old); 
    }    
    if(PreventRecursiveLedgerEntry.BOMsProcess) { 
        if(Trigger.isAfter && Trigger.isUnDelete) 
            BOMTriggerHelper.undeleteSupportingBoms(Trigger.new); 
    }
    //if(PreventRecursiveLedgerEntry.BOMsProcessupdate)if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert)) BOMTriggerHelper.assignProsAndRouting(Trigger.new);
}