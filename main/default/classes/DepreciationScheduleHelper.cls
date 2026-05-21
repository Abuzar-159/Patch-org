public class DepreciationScheduleHelper {
    public static void createTransactionsAndLedgerEntries(Set<Id> depIds){
        List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
        List<ERP7__Transaction__c > transactionsToCreate = new List<ERP7__Transaction__c>();
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];//WHERE ERP7__Start_Date__c = THIS_FISCAL_YEAR
        Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
        for(ERP7__Accounting_Period__c acc :accperiodList){
            accountingPeriodMapBYName.put(acc.Name,acc);
        }
        List<ERP7__Finance_General_Ledger_Entry__c > ledgerEntry= new List<ERP7__Finance_General_Ledger_Entry__c >();
        coaMap = [select Id, Name, ERP7__Chart_of_Account__c from ERP7__COA_Mapping__c where Name='Depreciation' limit 1];
        List<ERP7__Depreciation_Schedule__c> dsList = new List<ERP7__Depreciation_Schedule__c>();
        dsList = [select Id, Name, ERP7__Depreciation_Expense__c, ERP7__Depreciation__c, ERP7__Organisation__c, ERP7__Depreciation__r.ERP7__Product__c, ERP7__Depreciation__r.ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Depreciation__r.ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Depreciation__r.ERP7__Asset__r.ERP7__Product__r.ERP7__Asset_Account__c, ERP7__Depreciation__r.ERP7__Standard_Asset__r.ERP7__Asset_Account__c, ERP7__Depreciation__r.ERP7__Standard_Asset__r.Product2.ERP7__Asset_Account__c, ERP7__Depreciation__r.ERP7__Standard_Asset__c  from ERP7__Depreciation_Schedule__c where Id IN:depIds];
        for(ERP7__Depreciation_Schedule__c ds:dsList){
            // Create a new transaction record for each depreciation schedule
            ERP7__Transaction__c trans = new ERP7__Transaction__c();
            trans.ERP7__Amount__c=ds.ERP7__Depreciation_Expense__c;
            trans.ERP7__Transaction_Date__c=Date.today();
            string month = (String.valueof(trans.ERP7__Transaction_Date__c.month()).length() > 1)? String.valueof(trans.ERP7__Transaction_Date__c.month()) : '0'+trans.ERP7__Transaction_Date__c.month();
            String periodName = trans.ERP7__Transaction_Date__c.year()+'-'+month;
            trans.ERP7__Accounting_Period__c = accountingPeriodMapBYName.get(periodName).Id;
            trans.ERP7__Transaction_Type__c='Depreciation';
            trans.ERP7__Depreciation_Schedule__c=ds.Id;
            trans.ERP7__Depreciation__c=ds.ERP7__Depreciation__c;
            trans.ERP7__Organisation__c=ds.ERP7__Organisation__c;
            trans.ERP7__Transaction_Status__c='Completed';
            if(trans.ERP7__Depreciation__r.ERP7__Standard_Asset__c!=null) trans.ERP7__Credit_Chart_of_Account__c= ds.ERP7__Depreciation__r.ERP7__Standard_Asset__r.Product2.ERP7__Asset_Account__c;
            else if(trans.ERP7__Depreciation__r.ERP7__Product__c==null) trans.ERP7__Credit_Chart_of_Account__c= ds.ERP7__Depreciation__r.ERP7__Asset__r.ERP7__Product__r.ERP7__Asset_Account__c;
            else if(trans.ERP7__Depreciation__r.ERP7__Product__c!=null) trans.ERP7__Credit_Chart_of_Account__c= ds.ERP7__Depreciation__r.ERP7__Product__r.ERP7__Asset_Account__c;
            trans.ERP7__Debit_Chart_of_Account__c= coaMap[0].ERP7__Chart_of_Account__c;
            trans.ERP7__Finance_Category_Type__c='Credit';
            
            transactionsToCreate.add(trans); 
        }
            
            //Adjustment Entries Records
            if (!transactionsToCreate.isEmpty()) {
                insert transactionsToCreate;
                
                Id FGLEDebitRecordTypeId = Schema.SObjectType.ERP7__Finance_General_Ledger_Entry__c.getRecordTypeInfosByDeveloperName().get('Debit_General_Ledger_Entry').getRecordTypeId();
                Id FGLECreditRecordTypeId = Schema.SObjectType.ERP7__Finance_General_Ledger_Entry__c.getRecordTypeInfosByDeveloperName().get('Credit_General_Ledger_Entry').getRecordTypeId();
                
                String FGLrecordIdForAdjBillingBatch = System.Label.FGLrecordIdForAdjBillingBatch;
                
                Id FGLid;
                system.debug('FGLrecordIdForAdjBillingBatch~>'+FGLrecordIdForAdjBillingBatch);
                
                List<ERP7__Finance_General_Ledger__c> genLedgr = [SELECT Id, Name, ERP7__Active__c from ERP7__Finance_General_Ledger__c Where ERP7__Active__c = true ];//AND Name =:FGLrecordIdForAdjBillingBatch
                system.debug('genLedgr~>'+genLedgr.size());

                if(genLedgr.size() > 0) FGLid = genLedgr[0].Id;
                
                for (ERP7__Transaction__c tran : transactionsToCreate) {                        
                    ERP7__Finance_General_Ledger_Entry__c entryCredit = new ERP7__Finance_General_Ledger_Entry__c(); 
                    entryCredit.ERP7__General_Ledger_Entry_Type__c='Credit';
                    entryCredit.ERP7__Finance_General_Ledger__c=FGLid;
                    entryCredit.ERP7__General_Ledger_Entry_DateTime__c= system.now().adddays(-1);
                    entryCredit.ERP7__Transactions__c=tran.Id;
                    entryCredit.ERP7__Chart_of_Account__c=tran.ERP7__Credit_Chart_of_Account__c;
                    entryCredit.RecordTypeId = FGLECreditRecordTypeId;
                    entryCredit.ERP7__Credit_Entry__c=tran.ERP7__Amount__c;
                    entryCredit.ERP7__Organisation__c=tran.ERP7__Organisation__c;
                    entryCredit.ERP7__Accounting_Period__c = tran.ERP7__Accounting_Period__c;
                    ledgerEntry.add(entryCredit);
                   
                    ERP7__Finance_General_Ledger_Entry__c entryDebit = new ERP7__Finance_General_Ledger_Entry__c(); 
                    entryDebit.ERP7__General_Ledger_Entry_Type__c='Debit';
                    entryDebit.ERP7__Finance_General_Ledger__c=FGLid;
                    entryDebit.ERP7__General_Ledger_Entry_DateTime__c= system.now().adddays(-1);
                    entryDebit.ERP7__Transactions__c=tran.Id;
                    entryDebit.ERP7__Chart_of_Account__c=tran.ERP7__Debit_Chart_of_Account__c;
                    entryDebit.RecordTypeId = FGLEDebitRecordTypeId;
                    entryDebit.ERP7__Debit_Entry__c=tran.ERP7__Amount__c;
                    entryDebit.ERP7__Organisation__c=tran.ERP7__Organisation__c;
                    entryDebit.ERP7__Accounting_Period__c = tran.ERP7__Accounting_Period__c;
                    ledgerEntry.add(entryDebit);
                }
            }  
            
            if (!ledgerEntry.isEmpty()) {
                insert ledgerEntry;
            }
    }
}