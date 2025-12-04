trigger DepreciationScheduleTrigger on ERP7__Depreciation_Schedule__c (after insert) {
    DepreciationScheduleHelper.createTransactionsAndLedgerEntries(Trigger.newMap.keySet());
}