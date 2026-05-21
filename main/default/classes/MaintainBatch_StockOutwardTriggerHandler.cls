public class MaintainBatch_StockOutwardTriggerHandler {
    public static void handleAfterInsert(List<Stock_Outward_Line_Item__c> newList) {
        system.debug('handleAfterInsert called here');
        BatchStockCommon(newList);
        LogisticLinesCommon(newList);
        TransactionUpdateCommon(newList);
    }

    public static void handleAfterUpdate(List<Stock_Outward_Line_Item__c> newList, Map<Id, Stock_Outward_Line_Item__c> oldMap) {
        system.debug('handleAfterUpdate called here');
        BatchStockCommon(newList);
        LogisticLinesCommon(newList);
        TransactionUpdateCommon(newList);
        
        List<Id> mrpIds = new List<Id>();
        Map<Id, MRP__c> MRPs;
        Map<Id, MRP__c> MRPs2Upsert = new Map<Id, MRP__c>();

        for (Stock_Outward_Line_Item__c SDLI : newList) {
            if (SDLI.MRP_Material_Requirements_Planning__c != null) {                mrpIds.add(SDLI.MRP_Material_Requirements_Planning__c);
            }
        }

        MRPs = new Map<Id, MRP__c>([
            SELECT Id, Name, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c,
                Check_Out_Process__c, Fulfilled_Amount__c, Process__c,
                Schedule__c, Maximum_Hold_days__c, Notes__c, MRP_Product__c, Production_Cycle__c,
                Requested_Requirement_Date__c, Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c
            FROM MRP__c
            WHERE Id IN :mrpIds
        ]);

        for (Stock_Outward_Line_Item__c SDLI : newList) {
           if (SDLI.MRP_Material_Requirements_Planning__c != null) {                MRP__c mrp = MRPs.get(SDLI.MRP_Material_Requirements_Planning__c);                system.debug('mrp.Status__c  SOLI hanlder : '+mrp.Status__c);                if (Schema.sObjectType.MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.MRP__c.fields.Status__c.isUpdateable()) {                    if (SDLI.Status__c == 'Dispatched') {                        mrp.Status__c = 'Fulfilled';                    } else if (SDLI.Status__c == 'Rejected') {                        mrp.Status__c = mrp.Status__c;                    } else if (SDLI.Status__c != 'Returned to Supplier' && SDLI.Status__c != 'Reserved' && SDLI.Status__c != 'Committed') {                        mrp.Status__c = SDLI.Status__c;                    }                }                if (!MRPs2Upsert.containsKey(mrp.Id)) {                    MRPs2Upsert.put(mrp.Id, mrp);                    system.debug('mrp.Status__c  SOLI hanlder after: '+mrp.Status__c);                }            }   
        // if (SDLI.MRP_Material_Requirements_Planning__c != null) {                MRP__c mrp = MRPs.get(SDLI.MRP_Material_Requirements_Planning__c);                system.debug('mrp.Status__c  SOLI hanlder : '+mrp.Status__c);                if (Schema.sObjectType.MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.MRP__c.fields.Status__c.isUpdateable()) {                    if (SDLI.Status__c == 'Dispatched') {                        mrp.Status__c = 'Fulfilled';                    } else if (SDLI.Status__c == 'Rejected') {                        mrp.Status__c = mrp.Status__c;                    } else if (SDLI.Status__c != 'Returned to Supplier' && SDLI.Status__c != 'Reserved') {                        mrp.Status__c = SDLI.Status__c;                    }                }                if (!MRPs2Upsert.containsKey(mrp.Id)) {                    MRPs2Upsert.put(mrp.Id, mrp);                    system.debug('mrp.Status__c  SOLI hanlder after: '+mrp.Status__c);                }            }      
   
        }

        if (MRPs2Upsert.size() > 0 && Schema.SObjectType.MRP__c.isCreateable() && Schema.SObjectType.MRP__c.isUpdateable()) {            PreventRecursiveLedgerEntry.MRPFlowTrigger = false;            upsert MRPs2Upsert.values();
        } else {
            /* Not allowed to upsert */
        }
        
        //commented by Arshad 27/06/2023
        /*
        List<Id> outIds = new List<Id>();
        
        system.debug('newList size~>'+newList.size());
        
        for (Stock_Outward_Line_Item__c stock_oli : newList) { //oldMap.Values() //changed by Arshad - 21/06/2023
            system.debug('stock_oli.ERP7__Status__c~>'+stock_oli.ERP7__Status__c);
            system.debug('stock_oli.Id~>'+stock_oli.Id);
            if ((stock_oli.ERP7__Status__c == 'Reserved' || stock_oli.ERP7__Status__c == 'Requested') && stock_oli.ERP7__Quantity__c <= 0) {
                outIds.add(stock_oli.Id);
            }
        }
        
        system.debug('outIds to delete~>'+outIds.size());
        
        if (outIds.size() > 0) {
            Database.delete(outIds, false);
        }
        */
    }
    
    public static void handleAfterDelete(List<Stock_Outward_Line_Item__c> oldList) {
        BatchStockCommon(oldList);
        LogisticLinesCommon(oldList);
    }
    
    public static void handleAfterUndelete(List<Stock_Outward_Line_Item__c> undeletedList) {
        BatchStockCommon(undeletedList);
        LogisticLinesCommon(undeletedList);
    }
    
    //Added by arshad 27/06/2023
    @Future // made by Imran
    Public static void deleteZeroReserverSTOLI(Set<Id> recIds){ // List<Stock_Outward_Line_Item__c> myList
         List<Id> outIds = new List<Id>();
        List<Stock_Outward_Line_Item__c> myList = [Select Id, Name, ERP7__Status__c,  ERP7__Quantity__c From Stock_Outward_Line_Item__c Where Id In :recIds];
        system.debug('myList size~>'+myList.size());

        for (Stock_Outward_Line_Item__c stock_oli : myList) { //oldMap.Values() //changed by Arshad - 27/06/2023
            system.debug('stock_oli.ERP7__Status__c~>'+stock_oli.ERP7__Status__c);
            system.debug('stock_oli.Id~>'+stock_oli.Id);
            if ((stock_oli.ERP7__Status__c == 'Reserved' || stock_oli.ERP7__Status__c == 'Requested' || stock_oli.ERP7__Status__c == 'Committed') && stock_oli.ERP7__Quantity__c <= 0) {                outIds.add(stock_oli.Id);
            }
        }
        
        system.debug('outIds to delete~>'+outIds.size());
        
        if (outIds.size() > 0) {            Database.delete(outIds, false);
        }
    }
    
    /*
    public static void updateMRPstatus(List<Stock_Outward_Line_Item__c> newList) {
        
        List<Id> mrpIds = new List<Id>();
        Map<Id, MRP__c> MRPs;
        Map<Id, MRP__c> MRPs2Upsert = new Map<Id, MRP__c>();

        for (Stock_Outward_Line_Item__c SDLI : newList) {
            if (SDLI.MRP_Material_Requirements_Planning__c != null) {
                mrpIds.add(SDLI.MRP_Material_Requirements_Planning__c);
            }
        }

        MRPs = new Map<Id, MRP__c>([
            SELECT Id, Name, BOM__c, Bill_Of_Material_Product__c, BOM_Actual_Cost__c, BOM_Requirement_Cost__c,
                Check_Out_Process__c, Fulfilled_Amount__c, Process__c,
                Schedule__c, Maximum_Hold_days__c, Notes__c, MRP_Product__c, Production_Cycle__c,
                Requested_Requirement_Date__c, Site__c, Request_Fulfilled_Date__c, Sourced_Site__c, Status__c
            FROM MRP__c
            WHERE Id IN :mrpIds
        ]);

        for (Stock_Outward_Line_Item__c SDLI : newList) {
            if (SDLI.MRP_Material_Requirements_Planning__c != null) {
                MRP__c mrp = MRPs.get(SDLI.MRP_Material_Requirements_Planning__c);
                system.debug('mrp.Status__c  SOLI hanlder : '+mrp.Status__c);
                if (Schema.sObjectType.MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.MRP__c.fields.Status__c.isUpdateable()) {
                    if (SDLI.Status__c == 'Dispatched') {
                        mrp.Status__c = 'Fulfilled';
                    } else if (SDLI.Status__c == 'Rejected') {
                        mrp.Status__c = mrp.Status__c;
                    } else if (SDLI.Status__c != 'Returned to Supplier' && SDLI.Status__c != 'Reserved') {
                        mrp.Status__c = SDLI.Status__c;
                    }
                }
                if (!MRPs2Upsert.containsKey(mrp.Id)) {
                    MRPs2Upsert.put(mrp.Id, mrp);
                    system.debug('mrp.Status__c  SOLI hanlder after: '+mrp.Status__c);
                }
            }
        }

        if (MRPs2Upsert.size() > 0 && Schema.SObjectType.MRP__c.isCreateable() && Schema.SObjectType.MRP__c.isUpdateable()) {
            upsert MRPs2Upsert.values();
        } else {
            // Not allowed to upsert //
        }
    }
    
    
    
    public static void handlerMaintainBatchStocks(Boolean TriggerIsInsert,Boolean TriggerIsUpdate,Boolean TriggerisDelete,List<Stock_Outward_Line_Item__c> NewSystemTrigger,List<Stock_Outward_Line_Item__c> OldSystemTrigger) {
        system.debug('handlerMaintainBatchStocks called');
        Set<Id> batchIds = new Set<Id>();
        Set<Id> serialIds = new Set<Id>();
        Set<Id> outwardIds = new Set<Id>();
        
        if(!TriggerIsdelete){
            for(Stock_Outward_Line_Item__c SOLI : NewSystemTrigger){
                system.debug('SOLI quantity 1: '+SOLI.ERP7__Quantity__c);
                outwardIds.add(SOLI.Id);
                if(SOLI.ERP7__Material_Batch_Lot__c != Null) batchIds.add(SOLI.ERP7__Material_Batch_Lot__c);
                if(SOLI.ERP7__Serial__c != Null && SOLI.ERP7__Status__c == 'Committed') serialIds.add(SOLI.ERP7__Serial__c);
            }
        }
        
        if(TriggerIsUpdate || TriggerIsdelete){
            for(Stock_Outward_Line_Item__c SOLI : OldSystemTrigger){
                system.debug('SOLI quantity 2: '+SOLI.ERP7__Quantity__c);
                outwardIds.add(SOLI.Id);
                if(SOLI.ERP7__Material_Batch_Lot__c != Null) batchIds.add(SOLI.ERP7__Material_Batch_Lot__c);
                if(SOLI.ERP7__Serial__c != Null && SOLI.ERP7__Status__c == 'Committed') serialIds.add(SOLI.ERP7__Serial__c);
            }
        }
        
        if (batchIds.size() > 0 && !System.isBatch() && !System.isFuture()) {
            system.debug('MaintainBatchStocks.MaintainBatchStocks called with batchIds~>'+batchIds);
            MaintainBatchStocks.MaintainBatchStocks(batchIds);
        }
        if (serialIds.size() > 0 && !System.isBatch() && !System.isFuture()) {
            system.debug('MaintainBatchStocks.MaintainserialStocks called with serialIds~>'+serialIds);
            MaintainBatchStocks.MaintainserialStocks(serialIds);
        }
        if (!System.isFuture() && !System.isBatch() && NewSystemTrigger.size() > 0) {
            system.debug('MaintainBatchStocks.UpdateUnitPriceStockOutward called with NewSystemTrigger~>'+NewSystemTrigger.size());
            MaintainBatchStocks.UpdateUnitPriceStockOutward(getIds(NewSystemTrigger));
        }
        if (NewSystemTrigger.size() > 0) {
            system.debug('MaintainBatchStocks.UpdateRequestedStockOutward called with NewSystemTrigger~>'+NewSystemTrigger.size());
            MaintainBatchStocks.UpdateRequestedStockOutward(getIds(NewSystemTrigger));
        }
        
    }
    */
    
    public static void BatchStockCommon(List<Stock_Outward_Line_Item__c> myList) {
        system.debug('BatchStockCommon called');
        Set<Id> batchIds = new Set<Id>();
        Set<Id> serialIds = new Set<Id>();
        List<Id> outwardIds = new List<Id>();

        for (Stock_Outward_Line_Item__c SOLI : myList) {
            outwardIds.add(SOLI.Id);
            if (SOLI.ERP7__Material_Batch_Lot__c != null) {
                batchIds.add(SOLI.ERP7__Material_Batch_Lot__c);
            }
            if (SOLI.ERP7__Serial__c != null && SOLI.ERP7__Status__c == 'Committed') {               serialIds.add(SOLI.ERP7__Serial__c);
            }
        }
        
        if (batchIds.size() > 0 && !System.isBatch() && !System.isFuture()) {
            system.debug('MaintainBatchStocks.MaintainBatchStocks called with batchIds~>'+batchIds);
            MaintainBatchStocks.MaintainBatchStocks(batchIds);
        }
        if (serialIds.size() > 0 && !System.isBatch() && !System.isFuture()) {            system.debug('MaintainBatchStocks.MaintainserialStocks called with serialIds~>'+serialIds);            MaintainBatchStocks.MaintainserialStocks(serialIds);
        }
        if (!System.isFuture() && !System.isBatch() && myList.size() > 0) {
            system.debug('MaintainBatchStocks.UpdateUnitPriceStockOutward called with myList~>'+myList.size());
            MaintainBatchStocks.UpdateUnitPriceStockOutward(getIds(myList));
        }
        if (myList.size() > 0) {
            system.debug('MaintainBatchStocks.UpdateRequestedStockOutward called with myList~>'+myList.size());
            MaintainBatchStocks.UpdateRequestedStockOutward(getIds(myList));
        }
    }
    
    public static void LogisticLinesCommon(List<Stock_Outward_Line_Item__c> myList) {
        system.debug('LogisticLinesCommon called');
        Set<Id> soliIds = new Set<Id>();
        List <ERP7__Logistic_Line_Item__c> solis = new List <ERP7__Logistic_Line_Item__c>();
        
        for(Stock_Outward_Line_Item__c SDLI : myList){
            if(SDLI.ERP7__Logistic_Line_Item__c != Null) soliIds.add(SDLI.ERP7__Logistic_Line_Item__c);
        }
        if(soliIds.size() > 0) {            List<Stock_Outward_Line_Item__c> StockOutwards = [Select Id, Name, Picked_Quantity__c, ERP7__Logistic_Line_Item__c From Stock_Outward_Line_Item__c Where ERP7__Logistic_Line_Item__c In :soliIds];            for(Id soliId :soliIds){                ERP7__Logistic_Line_Item__c soli = new ERP7__Logistic_Line_Item__c(Id = soliId, Picked_Quantity__c = 0);                for(ERP7__Stock_Outward_Line_Item__c StockOutward :StockOutwards){                    if(soli.Id == StockOutward.ERP7__Logistic_Line_Item__c && StockOutward.ERP7__Picked_Quantity__c != Null && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Picked_Quantity__c.isUpdateable()) soli.ERP7__Picked_Quantity__c = soli.ERP7__Picked_Quantity__c + StockOutward.ERP7__Picked_Quantity__c;                 }                solis.add(soli);            }            PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false;            if(Schema.SObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()){update solis;}else{/*Not allowed to insert*/}        }   
    }
    
    public static void TransactionUpdateCommon(List<Stock_Outward_Line_Item__c> newList) {
        List<Transaction__c> TransactionsToUpdate = new List<Transaction__c>();
        Id PPLI_RID = RecordTypeUtil.getObjectRecordTypeId(Transaction__c.SobjectType, 'Merchandise Sale');
        Map<Id, Id> ExistingTransactions = getExistingTransactions(newList);
        Map<String, Module__c> RunModule = Module__c.getAll();

        if (RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run__c && PreventRecursiveLedgerEntry.proceed) {            PreventRecursiveLedgerEntry.proceed = false;            Map<Id, Decimal> Product_Map2Id = getProductMap2Id(newList);            Set<Id> pricebookIds = getPricebookIds(newList);            Set<Id> ProductIds = getProductIds(newList);            for (PricebookEntry pbEntry : [                SELECT Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, ERP7__Purchase_Price__c                FROM PricebookEntry                WHERE Pricebook2Id IN :pricebookIds AND Product2Id IN :ProductIds            ]) {                Decimal purchasePrice = (pbEntry.ERP7__Purchase_Price__c != null) ? pbEntry.ERP7__Purchase_Price__c : pbEntry.UnitPrice;                Product_Map2Id.put(pbEntry.Product2Id, purchasePrice);            }            for (Stock_Outward_Line_Item__c stock_oli : newList) {                if (stock_oli.Posted__c && stock_oli.Status__c == 'Committed') {                    Transaction__c trans = new Transaction__c(                        Id = (ExistingTransactions.get(stock_oli.Id) != null) ? ExistingTransactions.get(stock_oli.Id) : null                    );                    if (Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) {                        trans.Active__c = true;                    }                    Decimal unitPrice = (stock_oli.ERP7__Cost_Price__c > 0.00) ? stock_oli.ERP7__Cost_Price__c : (stock_oli.ERP7__Unit_Price__c != null) ? stock_oli.ERP7__Unit_Price__c : stock_oli.ERP7__Cost_Price__c;                    if (stock_oli.Product__c != null && Product_Map2Id.get(stock_oli.Product__c) != null) {                        unitPrice = (unitPrice != null && unitPrice > 0.00) ? unitPrice : Product_Map2Id.get(stock_oli.Product__c);                    }                    if (Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) {                        trans.Amount__c = (stock_oli.ERP7__Quantity__c != null) ? (stock_oli.ERP7__Quantity__c * unitPrice) : 0.00;                    }                    if (Schema.sObjectType.Transaction__c.fields.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Stock_Inward_Line_Item__c.isUpdateable()) {                        trans.Stock_Outward_Line_Item__c = stock_oli.Id;                    }                    if (Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) {                        trans.Transaction_Date__c = System.Today();                    }                    if (Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) {                        trans.Transaction_Status__c = 'Completed';                    }                    if (Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) {                        if (stock_oli.Cart_Picked_Item__c != null) {                            trans.Transaction_Type__c = 'Transfer';                        } else {                            trans.Transaction_Type__c = 'InventoryReduction';                        }                    }                    if (Schema.sObjectType.Transaction__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Product__c.isUpdateable()) {                        trans.Product__c = stock_oli.Product__c;                    }                    if (PPLI_RID != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) {                        trans.RecordTypeId = PPLI_RID;                    }                    TransactionsToUpdate.add(trans);                }            }            if (TransactionsToUpdate.size() > 0 && Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Return_PO__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Return_PO__c.isUpdateable() && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()) {            } else {                /* Not allowed to upsert */            }        }  
    }
    
    private static Set<Id> getIds(List<Stock_Outward_Line_Item__c> items) {
        Set<Id> ids = new Set<Id>();
        for (Stock_Outward_Line_Item__c item : items) {
            ids.add(item.Id);
        }
        return ids;
    }

    private static Map<Id, Id> getExistingTransactions(List<Stock_Outward_Line_Item__c> items) {
        Map<Id, Id> transactions = new Map<Id, Id>();
        for (Transaction__c trans : [
            SELECT Id, ERP7__Stock_Outward_Line_Item__c
            FROM Transaction__c
            WHERE ERP7__Stock_Outward_Line_Item__c IN :getIds(items)
        ]) {
            transactions.put(trans.ERP7__Stock_Outward_Line_Item__c, trans.Id);
        }
        return transactions;
    }

    private static Map<Id, Decimal> getProductMap2Id(List<Stock_Outward_Line_Item__c> items) {        Map<Id, Decimal> productMap = new Map<Id, Decimal>();        Set<Id> pricebookIds = new Set<Id>();        Set<Id> productIds = new Set<Id>();        for (Stock_Outward_Line_Item__c s : [            SELECT ERP7__Sales_Order_Line_Item__r.ERP7__PriceBookId__c, ERP7__Sales_Order_Line_Item__r.ERP7__Product__c            FROM Stock_Outward_Line_Item__c            WHERE Id IN :getIds(items) AND Status__c = 'Committed'        ]) {            if (s.ERP7__Sales_Order_Line_Item__c != null && s.ERP7__Sales_Order_Line_Item__r.ERP7__PriceBookId__c != null && s.ERP7__Sales_Order_Line_Item__r.ERP7__Product__c != null) {                pricebookIds.add(s.ERP7__Sales_Order_Line_Item__r.ERP7__PriceBookId__c);                productIds.add(s.ERP7__Sales_Order_Line_Item__r.ERP7__Product__c);            }        }        for (PricebookEntry pbEntry : [            SELECT UnitPrice, Product2Id, ERP7__Purchase_Price__c            FROM PricebookEntry            WHERE Pricebook2Id IN :pricebookIds AND Product2Id IN :productIds        ]) {            Decimal purchasePrice = (pbEntry.ERP7__Purchase_Price__c != null) ? pbEntry.ERP7__Purchase_Price__c : pbEntry.UnitPrice;            productMap.put(pbEntry.Product2Id, purchasePrice);        }        return productMap;    }
    
    private static Set<Id> getPricebookIds(List<Stock_Outward_Line_Item__c> items) {        Set<Id> pricebookIds = new Set<Id>();        for (Stock_Outward_Line_Item__c item : items) {            if (item.ERP7__Sales_Order_Line_Item__r.ERP7__PriceBookId__c != null) {                pricebookIds.add(item.ERP7__Sales_Order_Line_Item__r.ERP7__PriceBookId__c);            }        }        return pricebookIds;    }
    

    private static Set<Id> getProductIds(List<Stock_Outward_Line_Item__c> items) {        Set<Id> productIds = new Set<Id>();        for (Stock_Outward_Line_Item__c item : items) {            if (item.ERP7__Sales_Order_Line_Item__r.ERP7__Product__c != null) {                productIds.add(item.ERP7__Sales_Order_Line_Item__r.ERP7__Product__c);            }        }        return productIds;    }
}