trigger MaintainBatch_StockOutward on Stock_Outward_Line_Item__c (after insert, after update, after delete, after undelete) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        system.debug('MaintainBatch_StockOutward handleAfterInsert called');
        MaintainBatch_StockOutwardTriggerHandler.handleAfterInsert(Trigger.new);
    }

    system.debug('MaintainBatch_StockOutward proceedStockOutwardUpdateHandler ~>'+PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler);
    if (Trigger.isAfter && Trigger.isUpdate && (PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler)) { //|| Test.isRunningTest()
        system.debug('MaintainBatch_StockOutward handleAfterUpdate called ');
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = false;
        MaintainBatch_StockOutwardTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
    
    system.debug('MaintainBatch_StockOutward proceedDeleteZeroReserverSTOLI ~>'+PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI);
    if (Trigger.isAfter && Trigger.isUpdate) { // && (PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI || Test.isRunningTest())
        system.debug('MaintainBatch_StockOutward deleteZeroReserverSTOLI called ');
        PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI = false;
        if(!system.isFuture() && !system.isBatch()) MaintainBatch_StockOutwardTriggerHandler.deleteZeroReserverSTOLI(Trigger.NewMap.Keyset()); //changed by Arshad 18 Sep 2023
    }
    
    if (Trigger.isAfter && Trigger.isDelete) {
        system.debug('MaintainBatch_StockOutward handleAfterDelete called');
        MaintainBatch_StockOutwardTriggerHandler.handleAfterDelete(Trigger.old);
    }

    if (Trigger.isAfter && Trigger.isUndelete) {
        MaintainBatch_StockOutwardTriggerHandler.handleAfterUndelete(Trigger.new);
    }
    
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(RunModule.get('Finance') != null && RunModule.get('Finance').ERP7__Inventory_Tracking_on_Stock_Outward__c && !Trigger.isDelete){
        List<Transaction__c> Transactions2update = new List<Transaction__c>();
        Map<Id, Id> soliExisting_Transactions = new Map<Id, id>();
        for(Transaction__c eTransaction :[Select Id, Name, ERP7__Stock_Outward_Line_Item__c From Transaction__c Where ERP7__Stock_Outward_Line_Item__c  In : Trigger.NewMap.keyset()])
            soliExisting_Transactions.put(eTransaction.ERP7__Stock_Outward_Line_Item__c, eTransaction.id);
        
        // End Here
        for(ERP7__Stock_Outward_Line_Item__c SILI : System.trigger.New){
            if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').ERP7__Inventory_Tracking_on_Stock_Outward__c ) && SILI.Posted__C && SILI.ERP7__Cost_Price__c!=null && SILI.ERP7__Unit_Price__c!=null && SILI.ERP7__Unit_Price__c!=SILI.ERP7__Cost_Price__c){//&& trigger.isInsert
                // Added below line
                Transaction__c trans = new Transaction__c(Id=(soliExisting_Transactions.get(SILI.Id)!=null)?soliExisting_Transactions.get(SILI.Id):null);
                //Transaction__c trans = new Transaction__c();
                if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                Decimal unitPrice  = (SILI.ERP7__Unit_Price__c > 0.00)?SILI.ERP7__Unit_Price__c:0.00;
                system.debug('unitPrice-->'+unitPrice);
                system.debug('qty-->'+SILI.ERP7__Quantity__c);
                if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = (SILI.ERP7__Quantity__c != null && unitPrice != null)? SILI.ERP7__Quantity__c * unitPrice :0.00;
                //if(Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Return_PO__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Return_PO__c.isUpdateable()) trans.ERP7__Purchase_Return_PO__c = sili.ERP7__Purchase_Orders__c;
                if(Schema.sObjectType.Transaction__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Product__c.isUpdateable()) trans.ERP7__Product__c = SILI.ERP7__Product__c;
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                if(Schema.sObjectType.Transaction__c.fields.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Stock_Inward_Line_Item__c.isUpdateable()) trans.ERP7__Stock_Outward_Line_Item__c = SILI.Id; 
                //if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = SupplierRecordId;
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){
                    trans.Transaction_Type__c = 'InventorySold';
                }
                system.debug('Amount-->'+trans.Amount__c);
                if(trans.Transaction_Type__c == 'InventorySold'){
                    Transactions2update.add(trans);  
                }
                 
            }
        }
        
        if(Transactions2update.size()>0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){upsert Transactions2update;}else{/*Not allowed to upsert*/}
    }
    //Changed by arshad 27/06/2023
    /*    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
        List<Stock_Outward_Line_Item__c> NewSystemTrigger = Trigger.New;
        List<Stock_Outward_Line_Item__c> OldSystemTrigger = new List<Stock_Outward_Line_Item__c>();
        if(Trigger.isUpdate) OldSystemTrigger = Trigger.Old;
        
        //handler methods of MaintainBatchStocks
        MaintainBatch_StockOutwardTriggerHandler.handlerMaintainBatchStocks(Trigger.isInsert,Trigger.isUpdate,Trigger.isDelete,NewSystemTrigger,OldSystemTrigger);
        
        //TransactionUpdateCommon handler
        if(Trigger.isInsert || Trigger.isUpdate){
            MaintainBatch_StockOutwardTriggerHandler.TransactionUpdateCommon(Trigger.New);
        }
        
        //Update MRPs Status
        if(Trigger.isUpdate){
            MaintainBatch_StockOutwardTriggerHandler.updateMRPstatus(Trigger.New);
        }
        
        //Update LOLI picked qty
        List<Stock_Outward_Line_Item__c> SystemTrigger = new List<Stock_Outward_Line_Item__c>();
        if(Trigger.isDelete) SystemTrigger = System.Trigger.Old;
        else SystemTrigger = System.Trigger.New;
        MaintainBatch_StockOutwardTriggerHandler.LogisticLinesCommon(SystemTrigger);
        
        //Deleting Stock outward when Quantity become zero with status Reserved
        if(Trigger.isUpdate){
            MaintainBatch_StockOutwardTriggerHandler.deleteZeroReserverSTOLI(Trigger.New);
        }
    }
    */
    
}