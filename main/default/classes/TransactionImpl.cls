public with sharing class TransactionImpl implements ITrigger{
    
    public void bulkBefore(){
        
    }
    public void bulkAfter(){
        
    } 
    public void beforeInsert(){
        List<Account> DefaultOrgList = new List<Account>();
        if(UtilClass.getOrganisationByLogin_Employee().Id != null)
            DefaultOrgList.add(UtilClass.getOrganisationByLogin_Employee());          
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];//WHERE ERP7__Start_Date__c = THIS_FISCAL_YEAR
        Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
        for(ERP7__Accounting_Period__c acc :accperiodList){
            accountingPeriodMapBYName.put(acc.Name,acc);
        }
        List<Business_Unit__c> DefaultOrgBu = new List<Business_Unit__c>();
        if(DefaultOrgList != null && DefaultOrgList.size()>0){
            DefaultOrgBu = [SELECT Id FROM Business_Unit__c where Organisation__c =:DefaultOrgList[0].Id limit 1];
            for(Transaction__c trans :(List<Transaction__c>) System.Trigger.New){
                if(trans.ERP7__Transaction_Date__c == null)trans.ERP7__Transaction_Date__c = system.Today();
                string month = (String.valueof(trans.ERP7__Transaction_Date__c.month()).length() > 1)? String.valueof(trans.ERP7__Transaction_Date__c.month()) : '0'+trans.ERP7__Transaction_Date__c.month();
                String periodName = trans.ERP7__Transaction_Date__c.year()+'-'+month;
                //Moin added this below if condition since it was assigning accounting period for closed accoutning transactions
                if(trans.ERP7__Accounting_Period__c==null){
                    if(accountingPeriodMapBYName.get(periodName) != null ){
                        if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Open')
                            trans.ERP7__Accounting_Period__c = accountingPeriodMapBYName.get(periodName).Id;
                        else 
                            trans.addError('Transactions Should be posted to Open Accounting Period');
                    }else{
                        if(accountingPeriodMapBYName.containsKey(periodName)) trans.ERP7__Accounting_Period__c = accountingPeriodMapBYName.get(periodName).Id;
                    }
                }
                //trans.addError('Transactions Should be posted to Open Accounting Period');
                
                if(DefaultOrgList.size()>0 && trans.Organisation__c == null)trans.Organisation__c=DefaultOrgList[0].id;
                if(DefaultOrgBu.size()>0 && trans.Organisation_Business_Unit__c == null)trans.Organisation_Business_Unit__c = DefaultOrgBu[0].id;
                
            }
        }
    } 
    public void afterInsert(){
        system.debug('calling TransactionsLedgerEntry.TriggerHandler_Insert_Update from afterInsert if PreventRecursiveLedgerEntry.TransactionProcess~>'+PreventRecursiveLedgerEntry.TransactionProcess);
        if(PreventRecursiveLedgerEntry.TransactionProcess){
            system.debug('calling TransactionsLedgerEntry.TriggerHandler_Insert_Update from afterInsert');
            TransactionsLedgerEntry.TriggerHandler_Insert_Update(Trigger.NewMap.Keyset(),Trigger.IsInsert);
            PreventRecursiveLedgerEntry.TransactionProcess = false;
        }
        
        Map<String, Module__c> runModule = Module__c.getAll();
        if (runModule.containsKey('Finance') && runModule.get('Finance').ERP7__Run_Posting_Trigger__c) {
            Set<Id> transactionIds = Trigger.newMap.keySet();
            
            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = [
                SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c
                FROM ERP7__Finance_General_Ledger_Entry__c
                WHERE ERP7__Transactions__c IN :transactionIds
                AND Accounting_period__c != null and ERP7__Credit_Entry__c!=null and ERP7__Debit_Entry__c!=null
                AND Accounting_period__r.Status__c != 'Closed'
            ];
            
            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
            for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {
                if (ledgerMap.containsKey(fgle.ERP7__Transactions__c)) {
                    ledgerMap.get(fgle.ERP7__Transactions__c).add(fgle);
                } else {
                    ledgerMap.put(fgle.ERP7__Transactions__c, new List<ERP7__Finance_General_Ledger_Entry__c>{ fgle });
                }
            }
            
            for (Id transId : transactionIds) {
                Decimal creditSum = 0.00;
                Decimal debitSum = 0.00;
                
                if (ledgerMap.containsKey(transId)) {
                    for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(transId)) {
                        creditSum += fgl.ERP7__Credit_Entry__c;
                        debitSum += fgl.ERP7__Debit_Entry__c;
                    }
                }
                
                if (creditSum != debitSum) {
                    //throw new DMLException('Entries Mismatch Found!'); 
                    //Trigger.newMap.get(transId).addError('Entries Mismatch Found!');
                }
            }
        }
    }
    public void beforeUpdate(){
        /*Map<String, Module__c> runModule = Module__c.getAll();
if (runModule.containsKey('Finance') && runModule.get('Finance').ERP7__Run_Posting_Trigger__c) {
Set<Id> transactionIds = Trigger.newMap.keySet();

List<ERP7__Finance_General_Ledger_Entry__c> fgleList = [
SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c
FROM ERP7__Finance_General_Ledger_Entry__c
WHERE ERP7__Transactions__c IN :transactionIds
AND Accounting_period__c != null and ERP7__Credit_Entry__c!=null and ERP7__Debit_Entry__c!=null
AND Accounting_period__r.Status__c != 'Closed'
];

Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {
if (ledgerMap.containsKey(fgle.ERP7__Transactions__c)) {
ledgerMap.get(fgle.ERP7__Transactions__c).add(fgle);
} else {
ledgerMap.put(fgle.ERP7__Transactions__c, new List<ERP7__Finance_General_Ledger_Entry__c>{ fgle });
}
}

for (Id transId : transactionIds) {
Decimal creditSum = 0.00;
Decimal debitSum = 0.00;

if (ledgerMap.containsKey(transId)) {
for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(transId)) {
creditSum += fgl.ERP7__Credit_Entry__c;
debitSum += fgl.ERP7__Debit_Entry__c;
}
}

if (creditSum != debitSum) {
//throw new DMLException('Entries Mismatch Found!'); 
Trigger.newMap.get(transId).addError('Entries Mismatch Found!');
}
}
}*/
    } 
    public void afterUpdate(){
        system.debug('calling TransactionsLedgerEntry.TriggerHandler_Insert_Update from afterUpdate if PreventRecursiveLedgerEntry.TransactionProcess~>'+PreventRecursiveLedgerEntry.TransactionProcess);
        if(PreventRecursiveLedgerEntry.TransactionProcess){
            system.debug('calling TransactionsLedgerEntry.TriggerHandler_Insert_Update from afterUpdate');
            TransactionsLedgerEntry.TriggerHandler_Insert_Update(Trigger.NewMap.Keyset(),true);
            PreventRecursiveLedgerEntry.TransactionProcess = false;
        }
    }
    public void afterUnDelete(){
        system.debug('calling TransactionsLedgerEntry.TriggerHandler_Insert_Update from afterUnDelete if PreventRecursiveLedgerEntry.TransactionProcess~>'+PreventRecursiveLedgerEntry.TransactionProcess);
        if(PreventRecursiveLedgerEntry.TransactionProcess){
            system.debug('calling TransactionsLedgerEntry.TriggerHandler_Insert_Update from afterUnDelete');
            TransactionsLedgerEntry.TriggerHandler_Insert_Update(Trigger.NewMap.Keyset(),Trigger.isUndelete);
            PreventRecursiveLedgerEntry.TransactionProcess = false;
        }
    }
    public void beforeDelete(){
        List<Finance_General_Ledger_Entry__c> FGLES2Delete = [SELECT ID FROM Finance_General_Ledger_Entry__c WHERE Transactions__c IN:Trigger.oldMap.keyset() AND Accounting_period__c != null AND Accounting_period__r.Status__c != 'Closed'];//
        if(FGLES2Delete.size() >0 ){ if(Finance_General_Ledger_Entry__c.sObjectType.getDescribe().isDeletable()) delete FGLES2Delete; else{ } }
    }
    public void AfterDelete(){
        
    }
    public void andFinally(){
    }
}