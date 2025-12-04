trigger ManageReturnPurchaseOrders on PO__c (after insert, after update, before delete, after delete, after undelete)  {   
    
    if(PreventRecursiveLedgerEntry.potrigger){ 
            SalesOrderTrigger.ManagePurchaseOrderLogistics(Trigger.IsInsert,Trigger.IsUpdate, JSON.serialize(Trigger.New), JSON.serialize(Trigger.Old));
        }
     
    /*if(trigger.isUpdate) {   
        if(!System.isFuture() && !System.isBatch() && PreventRecursiveLedgerEntry.AwaitingStockPO) {
            PreventRecursiveLedgerEntry.AwaitingStockPO = false;
            MaintainBatchStocks.MaintainAwaitingStocksPO(trigger.newMap.keySet());
        }
    }*/
    
    if(trigger.isBefore && trigger.isDelete){        try{
        //new code to prevent PO deletion if an associated bill is present on Aug 4 2025
        Set<Id> poIdsToDelete = new Set<Id>();
        for (ERP7__PO__c po : Trigger.old) {  poIdsToDelete.add(po.Id);  }
        Map<Id, List<ERP7__Bill__c>> poToBillsMap = new Map<Id, List<ERP7__Bill__c>>();
        for (ERP7__Bill__c bill : [SELECT Id, ERP7__Purchase_Order__c FROM ERP7__Bill__c WHERE ERP7__Purchase_Order__c IN :poIdsToDelete]) {
        if (!poToBillsMap.containsKey(bill.ERP7__Purchase_Order__c)) {poToBillsMap.put(bill.ERP7__Purchase_Order__c, new List<ERP7__Bill__c>());
        }poToBillsMap.get(bill.ERP7__Purchase_Order__c).add(bill);
    	}
        for (ERP7__PO__c po : Trigger.old) {if (poToBillsMap.containsKey(po.Id)) {
         //   po.addError('This Purchase Order cannot be deleted because it has associated Bills.');
        }}
        //new code end
        system.debug('going to delete all stow for return pos');            Id PORecdType = RecordTypeUtil.getObjectRecordTypeIds('PO__c','Return_to_Vendor_RTV');            Set<Id> pliIds = new Set<Id>();            for(ERP7__Purchase_Line_Items__c pli : [SELECT Id, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.RecordTypeId FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c IN : System.Trigger.Old AND ERP7__Purchase_Orders__r.RecordTypeId =: PORecdType]) {                 pliIds.add(pli.Id);             }              if(pliIds.size() > 0) {                List<ERP7__Stock_Outward_Line_Item__c> StockOutwardItems2Delete = new List<ERP7__Stock_Outward_Line_Item__c>([Select Id, Name From ERP7__Stock_Outward_Line_Item__c Where ERP7__Purchase_Line_Items__c In: pliIds]);                if(StockOutwardItems2Delete.size() > 0 && ERP7__Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()){ system.debug('deleting all stow for return pos here'); delete StockOutwardItems2Delete; }else{ }                            }else system.debug('pliIds size 0');        }catch(Exception e){            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());        }    }   
    
    if(PreventRecursiveLedgerEntry.LogisticLineRollup){
        PreventRecursiveLedgerEntry.LogisticLineRollup = false;
        // For Rollup Start
        if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {        
            list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount__c', 'ERP7__Spend_Amounts__c')
                    };         
                        RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.new, 'ERP7__PO__c', 'ERP7__Budget_Accounts__c', 'ERP7__Budget_Account__c', '');
            
        }
        
        if(trigger.isDelete) {            list<RollUpSummaryUtility.fieldDefinition> BOMfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount__c', 'ERP7__Spend_Amounts__c')                    };                                 RollUpSummaryUtility.rollUpTrigger(BOMfieldDefinitions1, trigger.old, 'ERP7__PO__c', 'ERP7__Budget_Accounts__c', 'ERP7__Budget_Account__c', '');        }
        
        // For Rollup End
        
        //task
        Integer i=0;
        if(trigger.isDelete){            if(trigger.old[i].ERP7__Tasks__c != null){                ERP7__Actions_Tasks__c task = [SELECT Id, ERP7__Expense_Amount__c, ERP7__Total_Expense_Tax__c, ERP7__Milestone__c FROM ERP7__Actions_Tasks__c WHERE Id =: trigger.old[i].ERP7__Tasks__c];                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Expense_Tax__c.isUpdateable()) task.ERP7__Total_Expense_Tax__c -= trigger.old[i].ERP7__Tax_Amount__c;                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Expense_Amount__c.isUpdateable()) task.ERP7__Expense_Amount__c    -= trigger.old[i].ERP7__Amount__c;                if(Schema.SObjectType.ERP7__Actions_Tasks__c.isUpdateable()){update task;}else{/*not allowed to update*/}            }        }  
    }
    
}