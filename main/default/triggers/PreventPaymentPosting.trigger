/*
 * Created By : Moin
 * Date : 17th April 2023
 * Reason : to Prevent the Posting of Payment is their is any mismatch in the creation of ledger Entries
 * 
*/
trigger PreventPaymentPosting on ERP7__Payment__c (after insert, after update) {
    if(PreventRecursiveLedgerEntry.preventPostingTrigger){
        PreventRecursiveLedgerEntry.preventPostingTrigger = false;
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];
        Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
        for(ERP7__Accounting_Period__c acc :accperiodList){
            accountingPeriodMapBYName.put(acc.Name,acc);
        }
        for(ERP7__Payment__c pay:(List<ERP7__Payment__c>) System.Trigger.New){
            //if(pay.ERP7__Payment_Date__c== null) pay.ERP7__Payment_Date__c= system.Today();
            if(pay.ERP7__Payment_Date__c!= null){
                string month = (String.valueof(pay.ERP7__Payment_Date__c.month()).length() > 1)? String.valueof(pay.ERP7__Payment_Date__c.month()) : '0'+pay.ERP7__Payment_Date__c.month();
                String periodName = pay.ERP7__Payment_Date__c.year()+'-'+month;
                if(accountingPeriodMapBYName.get(periodName) != null ){
                    if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed')
                        pay.addError('Accounting Period is Closed, cannot update the Payment.');
                }
            }
        }
    }
    /*Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
        List<Id> paymentIds = new List<Id>();
        for(ERP7__Payment__c pay : Trigger.new){
            if(pay.ERP7__Posted__c && trigger.oldMap.get(pay.Id).ERP7__Posted__c != pay.ERP7__Posted__c){
                if(pay.ERP7__Payment_Account__c == null){
                    String errMessage = 'Entries Mismatch Found!. Please check the Payment Account';
                    pay.addError(errMessage);
                }else{
                    paymentIds.add(pay.Id);
                }
            }
        }
        if(paymentIds.size()>0){
            List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'AdvancePayment'];
            if(coaMap.size()<1){
                Trigger.newMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type AdvancePayment');
            }
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'InvoicePayment'];
            if(coaMap.size()<2){
                Trigger.newMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type InvoicePayment');
            }
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'BillPayment'];
            if(coaMap.size()<2){
                Trigger.newMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type BillPayment');
            }
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'CreditPayment'];
            if(coaMap.size()<2){
                Trigger.newMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type CreditPayment');
            }
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'VoucherPayment'];
            if(coaMap.size()<2){
                Trigger.newMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type VoucherPayment');
            }
        }
    }*/
}