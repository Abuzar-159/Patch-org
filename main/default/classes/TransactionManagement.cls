global with sharing class TransactionManagement {
    @AuraEnabled    
    global static Account DefaultOrganisation(){
         return UtilClass.getOrganisationByLogin_Employee();
    }
    
    @AuraEnabled
    global static TransactionWrapper fetchInvoices(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        if(StartDate == null) StartDate = system.today().adddays(-365);
        if(EndDate == null) EndDate = system.today();
        DateTime dt = Datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day(), 0, 0, 0);
        DateTime de = Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day(), 0, 0, 0);
        List<ERP7__Invoice__c> invoices = new List<ERP7__Invoice__c>();
        Set<Id> invoiceIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate from ERP7__Invoice__c where ERP7__Posted__c = true and CreatedDate>=:dt and CreatedDate <=:de and ERP7__Organisation__c=:OrgId and RecordType.Name != 'Advance'  and ERP7__Order_S__c = null and ERP7__Invoice_Amount__c > 0 order by CreatedDate DESC];
        if(invoices.size()>0){
            invoiceIds = (new Map<Id, ERP7__Invoice__c>(invoices)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Invoice__c, ERP7__Amount__c from ERP7__Transaction__c where ERP7__Invoice__c IN :invoiceIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Invoice__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Invoice__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Invoice__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Invoice__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Invoice__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Invoice__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Invoice__c inv : invoices){
                if(!TransMap.containsKey(inv.Id)){
                    tw.noTransInvoices.add(inv);
                }
                if(TransMap.containsKey(inv.Id) && !LedgerMap.containskey(inv.Id) && TransMap.get(inv.Id).ERP7__Amount__c>0){
                    tw.noEntriesInvoices.add(inv);
                }
                if(LedgerMap.containskey(inv.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(inv.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.entryMismatchInvoices.add(inv);
                    }
                }
            }
        }
        tw.StartDate = StartDate;
        tw.EndDate = EndDate;
        return tw;
    }
    
    
    @AuraEnabled
    global static TransactionWrapper fetchBills(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        if(StartDate == null) StartDate = system.today().adddays(-30);
        if(EndDate == null) EndDate = system.today();
        DateTime dt = Datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day(), 0, 0, 0);
        DateTime de = Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day(), 0, 0, 0);
        List<ERP7__Bill__c> bills = new List<ERP7__Bill__c>();
        Set<Id> billIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate from ERP7__Bill__c where ERP7__Posted__c = true and CreatedDate>=:dt and CreatedDate <=:de and ERP7__Organisation__c=:OrgId and ERP7__Total_Amount__c > 0 order by CreatedDate DESC];
        if(bills.size()>0){
            billIds = (new Map<Id, ERP7__Bill__c>(bills)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Bill__c, ERP7__Amount__c from ERP7__Transaction__c where ERP7__Bill__c	 IN :billIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Bill__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Bill__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Bill__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Bill__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Bill__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Bill__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Bill__c bill : bills){
                if(!TransMap.containsKey(bill.Id)){
                    tw.noTransBills.add(bill);
                }
                if(TransMap.containsKey(bill.Id) && !LedgerMap.containskey(bill.Id) && TransMap.get(bill.Id).ERP7__Amount__c>0){
                    tw.noEntriesBills.add(bill);
                }
                if(LedgerMap.containskey(bill.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(bill.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.entryMismatchBills.add(bill);
                    }
                }
            }
        }
        tw.StartDate = StartDate;
        tw.EndDate = EndDate;
        return tw;
    }
	
    @AuraEnabled
    global static TransactionWrapper fetchPayments(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        if(StartDate == null) StartDate = system.today().adddays(-30);
        if(EndDate == null) EndDate = system.today();
        DateTime dt = Datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day(), 0, 0, 0);
        DateTime de = Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day(), 0, 0, 0);
        List<ERP7__Payment__c> payments = new List<ERP7__Payment__c>();
        Set<Id> paymentIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate from ERP7__Payment__c where ERP7__Posted__c = true and CreatedDate>=:dt and CreatedDate <=:de and ERP7__Account__c=:OrgId and ERP7__Payment_Account__c!= null order by CreatedDate DESC];
        if(payments.size()>0){
            paymentIds = (new Map<Id, ERP7__Payment__c>(payments)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Payment__c, ERP7__Amount__c from ERP7__Transaction__c where ERP7__Payment__c	 IN :paymentIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Payment__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Payment__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Payment__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Payment__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Payment__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Payment__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Payment__c pay : payments){
                if(!TransMap.containsKey(pay.Id)){
                    tw.noTransPayments.add(pay);
                }
                if(TransMap.containsKey(pay.Id) && !LedgerMap.containskey(pay.Id) && TransMap.get(pay.Id).ERP7__Amount__c>0){
                    tw.noEntriesPayments.add(pay);
                }
                if(LedgerMap.containskey(pay.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(pay.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.entryMismatchPayments.add(pay);
                    }
                }
            }
        }
        tw.StartDate = StartDate;
        tw.EndDate = EndDate;
        return tw;
    }
    
    @AuraEnabled
    global static TransactionWrapper fetchCreditNotes(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        if(StartDate == null) StartDate = system.today().adddays(-30);
        if(EndDate == null) EndDate = system.today();
        DateTime dt = Datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day(), 0, 0, 0);
        DateTime de = Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day(), 0, 0, 0);
        List<ERP7__Credit_Note__c> creditnotes = new List<ERP7__Credit_Note__c>();
        Set<Id> creditnoteIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        creditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate from ERP7__Credit_Note__c where ERP7__Posted__c = true and CreatedDate>=:dt and CreatedDate <=:de and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];
        if(creditnotes.size()>0){
            creditnoteIds = (new Map<Id, ERP7__Credit_Note__c>(creditnotes)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Credit_Note__c from ERP7__Transaction__c where ERP7__Credit_Note__c	 IN :creditnoteIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Credit_Note__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Credit_Note__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Credit_Note__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Credit_Note__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Credit_Note__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Credit_Note__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Credit_Note__c creditnote : creditnotes){
                if(!TransMap.containsKey(creditnote.Id)){
                    tw.noTransCreditnotes.add(creditnote);
                }
                if(TransMap.containsKey(creditnote.Id) && !LedgerMap.containskey(creditnote.Id)){
                    tw.noEntriesCreditnotes.add(creditnote);
                }
                if(LedgerMap.containskey(creditnote.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(creditnote.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.entryMismatchCreditnotes.add(creditnote);
                    }
                }
            }
        }
        tw.StartDate = StartDate;
        tw.EndDate = EndDate;
        return tw;
    }
    
    @AuraEnabled
    global static TransactionWrapper fetchDebitNotes(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        if(StartDate == null) StartDate = system.today().adddays(-30);
        if(EndDate == null) EndDate = system.today();
        DateTime dt = Datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day(), 0, 0, 0);
        DateTime de = Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day(), 0, 0, 0);
        List<ERP7__Debit_Note__c> debitnotes = new List<ERP7__Debit_Note__c>();
        Set<Id> debitnoteIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        debitnotes = [select Id, Name, ERP7__Posted__c, CreatedDate from ERP7__Debit_Note__c where ERP7__Posted__c = true and CreatedDate>=:dt and CreatedDate <=:de and ERP7__Organisation__c=:OrgId order by CreatedDate DESC];
        if(debitnotes.size()>0){
            debitnoteIds = (new Map<Id, ERP7__Debit_Note__c>(debitnotes)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Debit_Note__c from ERP7__Transaction__c where ERP7__Debit_Note__c IN :debitnoteIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Debit_Note__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Debit_Note__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Debit_Note__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Debit_Note__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Debit_Note__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Debit_Note__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Debit_Note__c debitnote : debitnotes){
                if(!TransMap.containsKey(debitnote.Id)){
                    tw.noTransDebitnotes.add(debitnote);
                }
                if(TransMap.containsKey(debitnote.Id) && !LedgerMap.containskey(debitnote.Id)){
                    tw.noEntriesDebitnotes.add(debitnote);
                }
                if(LedgerMap.containskey(debitnote.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(debitnote.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.entryMismatchDebitnotes.add(debitnote);
                    }
                }
            }
        }
        tw.StartDate = StartDate;
        tw.EndDate = EndDate;
        return tw;
    }
    
    @AuraEnabled
    global static TransactionWrapper fetchExpenses(String OrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        if(StartDate == null) StartDate = system.today().adddays(-30);
        if(EndDate == null) EndDate = system.today();
        DateTime dt = Datetime.newInstance(StartDate.year(), StartDate.month(), StartDate.day(), 0, 0, 0);
        DateTime de = Datetime.newInstance(EndDate.year(), EndDate.month(), EndDate.day(), 0, 0, 0);
        List<ERP7__Expense__c> expenses = new List<ERP7__Expense__c>();
        Set<Id> expenseIds = new Set<Id>();
        Map<Id, ERP7__Transaction__c> TransMap = new Map<Id, ERP7__Transaction__c>();
        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> LedgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
        expenses = [select Id, Name, ERP7__Paid__c, CreatedDate from ERP7__Expense__c where ERP7__Paid__c = true and CreatedDate>=:dt and CreatedDate <=:de order by CreatedDate DESC];
        if(expenses.size()>0){
            expenseIds = (new Map<Id, ERP7__Expense__c>(expenses)).keySet();
            List<ERP7__Transaction__c> transactions = new List<ERP7__Transaction__c>();
            transactions = [select Id, ERP7__Expense__c	 from ERP7__Transaction__c where ERP7__Expense__c IN :expenseIds];
            if(transactions.size()>0){
                for(ERP7__Transaction__c trans : transactions){
                    TransMap.put(trans.ERP7__Expense__c, trans);
                }
                List<ERP7__Finance_General_Ledger_Entry__c> generalLedger = new List<ERP7__Finance_General_Ledger_Entry__c>();
                generalLedger = [select Id, ERP7__Transactions__c, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__r.ERP7__Expense__c from ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__r.ERP7__Expense__c IN :TransMap.keyset()];
                if(generalLedger.size()>0){
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : generalLedger){
                        if(LedgerMap.containsKey(fgl.ERP7__Transactions__r.ERP7__Expense__c)){
                            LedgerMap.get(fgl.ERP7__Transactions__r.ERP7__Expense__c).add(fgl);
                        }else{
                            List<ERP7__Finance_General_Ledger_Entry__c> generalEntries = new List<ERP7__Finance_General_Ledger_Entry__c>();
                            generalEntries.add(fgl);
                            LedgerMap.put(fgl.ERP7__Transactions__r.ERP7__Expense__c,generalEntries);
                        }
                    }
                }
            }
            for(ERP7__Expense__c exp : expenses){
                if(!TransMap.containsKey(exp.Id)){
                    tw.noTransExpenses.add(exp);
                }
                if(TransMap.containsKey(exp.Id) && !LedgerMap.containskey(exp.Id)){
                    tw.noEntriesExpenses.add(exp);
                }
                if(LedgerMap.containskey(exp.Id)){
                    Decimal creditsum = 0;
                    Decimal debitsum = 0;
                    for(ERP7__Finance_General_Ledger_Entry__c fgl : LedgerMap.get(exp.Id)){
                        if(fgl.ERP7__Credit_Entry__c != null) creditsum = creditsum + fgl.ERP7__Credit_Entry__c;
                        if(fgl.ERP7__Debit_Entry__c != null)  debitsum = debitsum + fgl.ERP7__Debit_Entry__c;
                    }
                    if(creditsum != debitsum){
                        tw.entryMismatchExpenses.add(exp);
                    }
                }
            }
        }
        tw.StartDate = StartDate;
        tw.EndDate = EndDate;
        return tw;
    }
    
    
    // Wrapper Class
    global class TransactionWrapper{
        @AuraEnabled global Date StartDate {get;set;}
        @AuraEnabled global Date EndDate {get;set;}
        @AuraEnabled global List<ERP7__Invoice__c> noTransInvoices {get;set;}
        @AuraEnabled global List<ERP7__Invoice__c> noEntriesInvoices {get;set;}
        @AuraEnabled global List<ERP7__Invoice__c> entryMismatchInvoices {get;set;}
        
        @AuraEnabled global List<ERP7__Bill__c> noTransBills {get;set;}
        @AuraEnabled global List<ERP7__Bill__c> noEntriesBills {get;set;}
        @AuraEnabled global List<ERP7__Bill__c> entryMismatchBills {get;set;}
        
        @AuraEnabled global List<ERP7__Payment__c> noTransPayments {get;set;}
        @AuraEnabled global List<ERP7__Payment__c> noEntriesPayments {get;set;}
        @AuraEnabled global List<ERP7__Payment__c> entryMismatchPayments {get;set;}
        
        @AuraEnabled global List<ERP7__Expense__c> noTransExpenses {get;set;}
        @AuraEnabled global List<ERP7__Expense__c> noEntriesExpenses {get;set;}
        @AuraEnabled global List<ERP7__Expense__c> entryMismatchExpenses {get;set;}
        
        @AuraEnabled global List<ERP7__Credit_Note__c> noTransCreditnotes {get;set;}
        @AuraEnabled global List<ERP7__Credit_Note__c> noEntriesCreditnotes {get;set;}
        @AuraEnabled global List<ERP7__Credit_Note__c> entryMismatchCreditnotes {get;set;}
        
        @AuraEnabled global List<ERP7__Debit_Note__c> noTransDebitnotes {get;set;}
        @AuraEnabled global List<ERP7__Debit_Note__c> noEntriesDebitnotes {get;set;}
        @AuraEnabled global List<ERP7__Debit_Note__c> entryMismatchDebitnotes {get;set;}
        
        global TransactionWrapper(){
            noTransInvoices = new List<ERP7__Invoice__c>();
            entryMismatchInvoices = new List<ERP7__Invoice__c>();
            noEntriesInvoices = new List<ERP7__Invoice__c>();
            
            noTransBills = new List<ERP7__Bill__c>();
            noEntriesBills = new List<ERP7__Bill__c>();
            entryMismatchBills = new List<ERP7__Bill__c>();
            
            noTransPayments = new List<ERP7__Payment__c>();
            noEntriesPayments = new List<ERP7__Payment__c>();
            entryMismatchPayments = new List<ERP7__Payment__c>();
            
            noTransExpenses = new List<ERP7__Expense__c>();
            noEntriesExpenses = new List<ERP7__Expense__c>();
            entryMismatchExpenses = new List<ERP7__Expense__c>();
            
            noTransCreditnotes = new List<ERP7__Credit_Note__c>();
            noEntriesCreditnotes = new List<ERP7__Credit_Note__c>();
            entryMismatchCreditnotes = new List<ERP7__Credit_Note__c>();
            
            noTransDebitnotes = new List<ERP7__Debit_Note__c>();
            noEntriesDebitnotes = new List<ERP7__Debit_Note__c>();
            entryMismatchDebitnotes = new List<ERP7__Debit_Note__c>();
        }
        
    }
}