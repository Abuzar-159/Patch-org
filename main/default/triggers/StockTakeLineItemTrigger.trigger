trigger StockTakeLineItemTrigger on ERP7__Stock_Take_Line_Item__c (after insert, after update) {
    if (Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsUndelete) ) {//&& PreventRecursiveLedgerEntry.preventStlTriggerTransactions
        //PostingPreventingHandler.createTransactionsAndLedgerEntriesSTLine(System.Trigger.New, System.Trigger.NewMap.KeySet());
    }
}