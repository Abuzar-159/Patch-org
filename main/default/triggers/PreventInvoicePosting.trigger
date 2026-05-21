/*
* Created By : Moin
* Date : 17th April 2023
* Reason : to Prevent the Invoices update if Accouting Period is Closed
* 
*/

trigger PreventInvoicePosting on ERP7__Invoice__c (after Insert, after update) {
    List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
    accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];
    Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
    for(ERP7__Accounting_Period__c acc :accperiodList){
         accountingPeriodMapBYName.put(acc.Name,acc);
    }
    for(ERP7__Invoice__c inv :(List<ERP7__Invoice__c>) System.Trigger.New){
        //if(inv.ERP7__Invoice_Date__c != null) inv.ERP7__Invoice_Date__c = system.Today();
        if(inv.ERP7__Invoice_Date__c != null){
            string month = (String.valueof(inv.ERP7__Invoice_Date__c.month()).length() > 1)? String.valueof(inv.ERP7__Invoice_Date__c.month()) : '0'+inv.ERP7__Invoice_Date__c.month();
            String periodName = inv.ERP7__Invoice_Date__c.year()+'-'+month;
            if(accountingPeriodMapBYName.get(periodName) != null ){
                if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed')
                    inv.addError('Accounting Period is Closed, cannot update the Invoice.');
            }
        }
    }
    /*Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
        List<Id> InvoiceIds = new List<Id>();
        for(ERP7__Invoice__c inv : Trigger.new){
            if(inv.ERP7__Posted__c && trigger.oldMap.get(inv.Id).ERP7__Posted__c != inv.ERP7__Posted__c){
                InvoiceIds.add(inv.Id);
            }
        }
        if(InvoiceIds.size()>0){
            List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'Sales'];
            if(coaMap.size()<2){
                Trigger.newMap.get(InvoiceIds[0]).addError('Please set up the Coa Mapping of Type Sales');
            }
            List<ERP7__Invoice_Line_Item__c> invItems = new List<ERP7__Invoice_Line_Item__c>();
            invItems = [select Id, Name, ERP7__Product__c, ERP7__Invoice__c, ERP7__Product__r.ERP7__Expense_Account__c, ERP7__Product__r.ERP7__Revenue_Account__c, ERP7__Product__r.ERP7__Inventory_Account__c   from ERP7__Invoice_Line_Item__c where ERP7__Invoice__c IN :InvoiceIds];
            Map<Id, List<ERP7__Invoice_Line_Item__c>> invMap = new Map<Id, List<ERP7__Invoice_Line_Item__c>>();
            for(ERP7__Invoice_Line_Item__c invItem : invItems){
                if(invMap.containskey(invItem.ERP7__Invoice__c)){
                    invMap.get(invItem.ERP7__Invoice__c).add(invItem);
                }else{
                    List<ERP7__Invoice_Line_Item__c> invItemz = new List<ERP7__Invoice_Line_Item__c>();
                    invItemz.add(invItem);
                    invMap.put(invItem.ERP7__Invoice__c, invItemz);
                }
            }
            for(Id invId : InvoiceIds){
                if(invMap.size()>0){
                    for(ERP7__Invoice_Line_Item__c  invline : invMap.get(invId)){
                        if(invline.ERP7__Product__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Product for line item - '+ invline.Name;
                            Trigger.newMap.get(invId).addError(errMessage);
                        }
                        else if(invline.ERP7__Product__r.ERP7__Expense_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Expense Account of the Product for line item - '+ invline.Name;
                            Trigger.newMap.get(invId).addError(errMessage);
                        }
                        else if(invline.ERP7__Product__r.ERP7__Revenue_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check  the Revenue Account of the the Product for line item - '+ invline.Name;
                            Trigger.newMap.get(invId).addError(errMessage);
                        }
                        else if(invline.ERP7__Product__r.ERP7__Inventory_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Inventory Account of the Product for line item - '+ invline.Name;
                            Trigger.newMap.get(invId).addError(errMessage);
                        }
                    }
                }
                Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([select Id, Name from ERP7__Transaction__c where ERP7__Invoice__c IN :InvoiceIds]);
                Set<Id> transactionIds = transMap.keySet();
                
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
                        Trigger.newMap.get(invId).addError('Entries Mismatch Found!');
                    }
                }
            }
        }
    }*/
}