/*
* Changes made by - Moin
* Date - 03rd August 2023
* Reason - Invoices created with more then 2 decimal places amount was not posting
* Fix Applied - added .setScale(2) in line 93 and 94
*/

/*
* Changes made by - Moin
* Date - 25th July 2024
* Reason - preventing any record updates if the accounting period is closed
*/
public class PostingPreventingHandler {
   /* public static void handleInvoiceAfterInsert(List<ERP7__Invoice__c> newInvoices, Map<Id, ERP7__Invoice__c> newInvoiceMap, Map<Id, ERP7__Invoice__c> oldInvoiceMap) {
        Map<String, Module__c> runModule = new Map<String, Module__c>(Module__c.getAll());
        system.debug('PostingPreventingHandler called -- > handleInvoiceAfterInsert');
        if (runModule.size() > 0 && runModule.get('Finance').ERP7__Run_Posting_Trigger__c) {
            List<Id> invoiceIds = new List<Id>();

            for (ERP7__Invoice__c inv : newInvoices) {
                if (inv.ERP7__Posted__c) {// && oldInvoiceMap.get(inv.Id).ERP7__Posted__c != inv.ERP7__Posted__c
                    invoiceIds.add(inv.Id);
                }
            }

            if (invoiceIds.size() > 0) {
                List<ERP7__Invoice_Line_Item__c> invItems = [
                    SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.ERP7__Expense_Account__c, ERP7__Product__r.Name,
                    ERP7__Product__r.ERP7__Revenue_Account__c, ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Invoice__c
                    FROM ERP7__Invoice_Line_Item__c
                    WHERE ERP7__Invoice__c IN :invoiceIds
                ];

                system.debug('PostingPreventingHandler invItems~>'+invItems.size());

                Map<Id, List<ERP7__Invoice_Line_Item__c>> invMap = new Map<Id, List<ERP7__Invoice_Line_Item__c>>();
                for (ERP7__Invoice_Line_Item__c invItem : invItems) {
                    if (invMap.containsKey(invItem.ERP7__Invoice__c)) {
                        invMap.get(invItem.ERP7__Invoice__c).add(invItem);
                    } else {
                        invMap.put(invItem.ERP7__Invoice__c, new List<ERP7__Invoice_Line_Item__c>{invItem});
                    }
                }

                Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([select Id, Name from ERP7__Transaction__c where ERP7__Invoice__c IN :InvoiceIds]);
                Set<Id> transactionIds = transMap.keySet();

                system.debug('PostingPreventingHandler transactionIds~>'+transactionIds.size());

                List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
                fgleList = [SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Chart_of_Account__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Invoice__c
                            FROM ERP7__Finance_General_Ledger_Entry__c
                            WHERE ERP7__Transactions__c IN :transactionIds AND ERP7__Credit_Entry__c != null AND ERP7__Debit_Entry__c != null
                            AND Accounting_period__c != null  AND Accounting_period__r.Status__c != 'Closed' ];

                system.debug('PostingPreventingHandler fgleList~>'+fgleList.size());

                Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
                for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {
                    if (ledgerMap.containsKey(fgle.ERP7__Transactions__r.ERP7__Invoice__c)) {
                        ledgerMap.get(fgle.ERP7__Transactions__r.ERP7__Invoice__c).add(fgle);
                    } else {
                        ledgerMap.put(fgle.ERP7__Transactions__r.ERP7__Invoice__c, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
                    }
                }
                for (Id invId : invoiceIds) {

                    if (ledgerMap!=null && ledgerMap.containsKey(invId)) {
                        Decimal creditSum = 0.00;
                        Decimal debitSum = 0.00;

                        for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(invId)) {
                            creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);
                            debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);

                            if(fgl.ERP7__Chart_of_Account__c == Null){
                                String errMessage = 'Chart of Account Missing!';
                                newInvoiceMap.get(invId).addError(errMessage);
                                return;
                            }
                        }
                        system.debug('creditSum-->'+creditSum);
                        system.debug('debitSum-->'+debitSum);
                        if (creditSum != debitSum ) {//|| creditSum == 0 Removed this condition on request from Stephanie
                            newInvoiceMap.get(invId).addError('Entries Mismatch Found! Please check the amounts');
                        }
                    }else{
                        system.debug('PostingPreventingHandler -- > handleInvoiceAfterInsert');
                        if(newInvoiceMap.get(invId).ERP7__Invoice_Amount__c!=null && newInvoiceMap.get(invId).ERP7__Invoice_Amount__c>0) newInvoiceMap.get(invId).addError('Entries Mismatch or Not Found!'); // if(newInvoiceMap.get(invId).ERP7__Invoice_Amount__c!=null && newInvoiceMap.get(invId).ERP7__Invoice_Amount__c>0) added this to post invoice with 0 amount
                    }
                }
            }
        }
    }
*/


    public static void handleInvoiceAfterInsert(List<ERP7__Invoice__c> newInvoices, Map<Id, ERP7__Invoice__c> newInvoiceMap, Map<Id, ERP7__Invoice__c> oldInvoiceMap) {
    Map<String, Module__c> runModule = new Map<String, Module__c>(Module__c.getAll());
    System.debug('PostingPreventingHandler STARTED: handleInvoiceAfterInsert');

    if (runModule.size() > 0 && runModule.get('Finance').ERP7__Run_Posting_Trigger__c) { List<Id> invoiceIds = new List<Id>();

        for (ERP7__Invoice__c inv : newInvoices) {
            System.debug('Processing invoice: ' + inv.Id + ', Posted: ' + inv.ERP7__Posted__c);
            if (inv.ERP7__Posted__c) {	invoiceIds.add(inv.Id);
            }
        }

        System.debug('Collected Posted Invoice IDs: ' + invoiceIds);

        if (invoiceIds.size() > 0) {		List<ERP7__Invoice_Line_Item__c> invItems = [
                SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.ERP7__Expense_Account__c, ERP7__Product__r.Name,
                ERP7__Product__r.ERP7__Revenue_Account__c, ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Invoice__c
                FROM ERP7__Invoice_Line_Item__c
                WHERE ERP7__Invoice__c IN :invoiceIds
            ];

            System.debug('Fetched Invoice Line Items: ' + invItems.size());

            Map<Id, List<ERP7__Invoice_Line_Item__c>> invMap = new Map<Id, List<ERP7__Invoice_Line_Item__c>>();		for (ERP7__Invoice_Line_Item__c invItem : invItems) {
                System.debug('Line Item for Invoice: ' + invItem.ERP7__Invoice__c + ', Product: ' + invItem.ERP7__Product__c);
                if (!invMap.containsKey(invItem.ERP7__Invoice__c)) {			invMap.put(invItem.ERP7__Invoice__c, new List<ERP7__Invoice_Line_Item__c>());   } invMap.get(invItem.ERP7__Invoice__c).add(invItem);
            }

            Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>(			[SELECT Id, Name FROM ERP7__Transaction__c WHERE ERP7__Invoice__c IN :invoiceIds]
            );

            Set<Id> transactionIds = transMap.keySet();
            System.debug('Fetched Transactions: ' + transactionIds);

            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = [
                SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Chart_of_Account__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Invoice__c
                FROM ERP7__Finance_General_Ledger_Entry__c   WHERE ERP7__Transactions__c IN :transactionIds
                AND ERP7__Credit_Entry__c != null AND ERP7__Debit_Entry__c != null
                AND Accounting_period__c != null AND Accounting_period__r.Status__c != 'Closed'
            ];

            System.debug('Fetched Finance Ledger Entries: ' + fgleList.size());

            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();			for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {			Id invoiceId = fgle.ERP7__Transactions__r.ERP7__Invoice__c;			if (!ledgerMap.containsKey(invoiceId)) {			ledgerMap.put(invoiceId, new List<ERP7__Finance_General_Ledger_Entry__c>());
                }
                ledgerMap.get(invoiceId).add(fgle);
            }

            for (Id invId : invoiceIds) {
                System.debug('Validating Invoice: ' + invId);
                if (ledgerMap != null && ledgerMap.containsKey(invId)) {			Decimal creditSum = 0.00;			Decimal debitSum = 0.00;

                    for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(invId)) {
                        System.debug('Ledger Entry: ' + fgl);
                        System.debug(' -> Credit: ' + fgl.ERP7__Credit_Entry__c + ', Debit: ' + fgl.ERP7__Debit_Entry__c);

                        if (fgl.ERP7__Chart_of_Account__c == null) {			String errMessage = 'Chart of Account Missing for Ledger Entry with ID: ' + fgl.Id;
                            System.debug('ERROR: ' + errMessage);   newInvoiceMap.get(invId).addError(errMessage);			return;
                        }
                        creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);			debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                    }

                    System.debug('Computed Totals for Invoice ' + invId + ': Credit = ' + creditSum + ', Debit = ' + debitSum);
                    if (creditSum != debitSum) {			String errorMessage = 'Entries Mismatch Found! Please check the amounts. Credit: ' + creditSum + ', Debit: ' + debitSum;
                        System.debug('ERROR: ' + errorMessage);   newInvoiceMap.get(invId).addError(errorMessage);
                    }
                } else {
                    System.debug('No ledger entries found for invoice: ' + invId);
                    if (newInvoiceMap.get(invId).ERP7__Invoice_Amount__c != null && newInvoiceMap.get(invId).ERP7__Invoice_Amount__c > 0) {		String errorMessage = 'Entries Mismatch or Not Found! Invoice amount is: ' + newInvoiceMap.get(invId).ERP7__Invoice_Amount__c;
                        System.debug('ERROR: ' + errorMessage);   newInvoiceMap.get(invId).addError(errorMessage);
                    }
                }
            }
        } else {
            System.debug('No invoices were posted. Nothing to process.');
        }
    } else {
        System.debug('Finance module is not active or not configured to run posting trigger.');
    }
}

 /*   public static void handleBillAfterInsert(List<ERP7__Bill__c> newBills, Map<Id, ERP7__Bill__c> newBillMap, Map<Id, ERP7__Bill__c> oldBillMap) {
        Map<string, Module__c > RunModule = new Map<string, Module__c >();
        RunModule =  Module__c.getAll();
        if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
            List<Id> BillIds = new List<Id>();

            for(ERP7__Bill__c bill : newBills){
                if(bill.ERP7__Posted__c){// && oldBillMap.get(bill.Id).ERP7__Posted__c != bill.ERP7__Posted__c
                    BillIds.add(bill.Id);
                }
            }

            Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([select Id, Name from ERP7__Transaction__c where ERP7__Bill__c IN :BillIds]);
            Set<Id> transactionIds = transMap.keySet();

            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
            fgleList = [SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Bill__c
                        FROM ERP7__Finance_General_Ledger_Entry__c
                        WHERE ERP7__Transactions__c IN :transactionIds AND Accounting_period__c != null AND ERP7__Credit_Entry__c != null
                        AND ERP7__Debit_Entry__c != null AND Accounting_period__r.Status__c != 'Closed'
                       ];

            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
            for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {
                if (ledgerMap.containsKey(fgle.ERP7__Transactions__r.ERP7__Bill__c)) {
                    ledgerMap.get(fgle.ERP7__Transactions__r.ERP7__Bill__c).add(fgle);
                } else {
                    ledgerMap.put(fgle.ERP7__Transactions__r.ERP7__Bill__c, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
                }
            }

            if(BillIds.size()>0){
                List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
                coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'Purchase'];
                if(coaMap.size()<2){
                    Trigger.newMap.get(BillIds[0]).addError('Please set up the Coa Mapping of Type Purchase');
                }
                coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'Expense'];
                if(coaMap.size()<2){
                    Trigger.newMap.get(BillIds[0]).addError('Please set up the Coa Mapping of Type Expense');
                }
                List<ERP7__Bill_Line_Item__c> billItems = new List<ERP7__Bill_Line_Item__c>();
                billItems = [select Id, Name, ERP7__Chart_Of_Account__c, ERP7__Bill__c  from ERP7__Bill_Line_Item__c where ERP7__Bill__c IN :BillIds];
                Map<Id, List<ERP7__Bill_Line_Item__c>> BillMap = new Map<Id, List<ERP7__Bill_Line_Item__c>>();
                for(ERP7__Bill_Line_Item__c billItem : billItems){
                    if(BillMap.containskey(billItem.ERP7__Bill__c)){
                        BillMap.get(billItem.ERP7__Bill__c).add(billItem);
                    }else{
                        List<ERP7__Bill_Line_Item__c> billItemz = new List<ERP7__Bill_Line_Item__c>();
                        billItemz.add(billItem);
                        BillMap.put(billItem.ERP7__Bill__c, billItemz);
                    }
                }
                for(Id BillId : BillIds){
                    if(BillMap.size()>0){
                        for(ERP7__Bill_Line_Item__c  biiItem : BillMap.get(BillId)){
                            if(biiItem.ERP7__Chart_Of_Account__c == null){
                                String errMessage = 'Entries Mismatch Found!. Please check the Inventory or Expense Account for the Line Item- '+ biiItem.Name;
                                Trigger.newMap.get(BillId).addError(errMessage);
                            }
                        }
                    }

                    if (ledgerMap!=null && ledgerMap.containsKey(BillId)) {
                        Decimal creditSum = 0.00;
                        Decimal debitSum = 0.00;

                        for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(BillId)) {
                            creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);
                            debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                        }

                        if (creditSum != debitSum || creditSum == 0) {
                            newBillMap.get(BillId).addError('Entries Mismatch Found! Please check the amounts');
                        }
                    }else{
                        newBillMap.get(BillId).addError('Entries Mismatch or Not Found!!');
                    }
                }
            }
        }
    }
    */



    public static void handleBillAfterInsert(List<ERP7__Bill__c> newBills, Map<Id, ERP7__Bill__c> newBillMap, Map<Id, ERP7__Bill__c> oldBillMap) {
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    System.debug('RunModule Size: ' + RunModule.size());

    if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
        List<Id> BillIds = new List<Id>();   for(ERP7__Bill__c bill : newBills){
            System.debug('Checking Bill: ' + bill.Id + ', Posted: ' + bill.ERP7__Posted__c);
            if(bill.ERP7__Posted__c){		BillIds.add(bill.Id);
            }
        }

        System.debug('BillIds to process: ' + BillIds);

        Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>(			[SELECT Id, Name FROM ERP7__Transaction__c WHERE ERP7__Bill__c IN :BillIds]
        );
        Set<Id> transactionIds = transMap.keySet();
        System.debug('Related Transaction IDs: ' + transactionIds);

        List<ERP7__Finance_General_Ledger_Entry__c> fgleList = [
            SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Bill__c
            FROM ERP7__Finance_General_Ledger_Entry__c   WHERE ERP7__Transactions__c IN :transactionIds
                AND Accounting_period__c != null
                AND ERP7__Credit_Entry__c != null
                AND ERP7__Debit_Entry__c != null
                AND Accounting_period__r.Status__c != 'Closed'
        ];
        System.debug('Fetched FGLEs Size: ' + fgleList.size());
        System.debug('Fetched FGLEs: ' + fgleList);

        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();			for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {			Id billId = fgle.ERP7__Transactions__r.ERP7__Bill__c;			if (ledgerMap.containsKey(billId)) {			ledgerMap.get(billId).add(fgle);
            } else {     ledgerMap.put(billId, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
            }
        }
        System.debug('Ledger Map Keys: ' + ledgerMap.keySet());

        if(BillIds.size() > 0){		List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();			coaMap = [SELECT Id, Name FROM ERP7__COA_Mapping__c WHERE Name = 'Purchase'];
            System.debug('COA Mappings (Purchase): ' + coaMap.size());
            if(coaMap.size() < 2){			Trigger.newMap.get(BillIds[0]).addError('Please set up the Coa Mapping of Type Purchase');
            }

            coaMap = [SELECT Id, Name FROM ERP7__COA_Mapping__c WHERE Name = 'Expense'];
            System.debug('COA Mappings (Expense): ' + coaMap.size());
            if(coaMap.size() < 2){			Trigger.newMap.get(BillIds[0]).addError('Please set up the Coa Mapping of Type Expense in 1');
            }

            List<ERP7__Bill_Line_Item__c> billItems = [
                SELECT Id, Name, ERP7__Chart_Of_Account__c, ERP7__Bill__c
                FROM ERP7__Bill_Line_Item__c    WHERE ERP7__Bill__c IN :BillIds
            ];
            System.debug('Fetched Bill Line Items: ' + billItems.size());

            Map<Id, List<ERP7__Bill_Line_Item__c>> BillMap = new Map<Id, List<ERP7__Bill_Line_Item__c>>();		for(ERP7__Bill_Line_Item__c billItem : billItems){			if(BillMap.containsKey(billItem.ERP7__Bill__c)){			BillMap.get(billItem.ERP7__Bill__c).add(billItem);
                } else {    BillMap.put(billItem.ERP7__Bill__c, new List<ERP7__Bill_Line_Item__c>{billItem});
                }
            }

            for(Id BillId : BillIds){
                System.debug('Processing Bill: ' + BillId);
                if(BillMap.size() > 0 && BillMap.containsKey(BillId)){			for(ERP7__Bill_Line_Item__c biiItem : BillMap.get(BillId)){
                        System.debug('Checking Bill Line: ' + biiItem.Id + ', COA: ' + biiItem.ERP7__Chart_Of_Account__c);
                        if(biiItem.ERP7__Chart_Of_Account__c == null){			String errMessage = 'Entries Mismatch Found!. Please check the Inventory or Expense Account for the Line Item- ' + biiItem.Name;			Trigger.newMap.get(BillId).addError(errMessage);
                            System.debug('Error: ' + errMessage);
                        } else {
                            System.debug('good to go');
                        }
                    }
                }

                System.debug('ledgerMap: '+ ledgerMap);

                if (ledgerMap != null && ledgerMap.containsKey(BillId)) {			Decimal creditSum = 0.00;			Decimal debitSum = 0.00;

                    for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(BillId)) {
                        System.debug('fgl:'+fgl);
                        		creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);			debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                        System.debug('FGLE Entry → Credit: ' + fgl.ERP7__Credit_Entry__c + ', Debit: ' + fgl.ERP7__Debit_Entry__c);
                    }

                    System.debug('Bill ID: ' + BillId + ', Total Credit: ' + creditSum + ', Total Debit: ' + debitSum);

                    if (creditSum != debitSum || creditSum == 0) {			String mismatchError = 'Entries Mismatch Found! Please check the amounts';			newBillMap.get(BillId).addError(mismatchError);
                        System.debug('Error: ' + mismatchError);
                    }
                } else {
                    String notFoundError = 'Entries Mismatch or Not Found!!';			newBillMap.get(BillId).addError(notFoundError);
                    System.debug('Error: ' + notFoundError);
                }
            }
        }
    }
}

    public static void handlePaymentAfterInsert(List<ERP7__Payment__c> newPayments, Map<Id, ERP7__Payment__c> newPaymentMap, Map<Id, ERP7__Payment__c> oldPaymentMap) {
        Map<string, Module__c > RunModule = new Map<string, Module__c >();
        RunModule =  Module__c.getAll();
        if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
            List<Id> paymentIds = new List<Id>();		for(ERP7__Payment__c pay : newPayments){			if(pay.ERP7__Posted__c ){//&& oldPaymentMap.get(pay.Id).ERP7__Posted__c != pay.ERP7__Posted__c
                    if(pay.ERP7__Payment_Account__c == null){			String errMessage = 'Entries Mismatch Found!. Please check the Payment Account';			pay.addError(errMessage);
                    }else{
                        paymentIds.add(pay.Id);
                    }
                }
            }
            Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([select Id, Name from ERP7__Transaction__c where ERP7__Payment__c IN :paymentIds]);		Set<Id> transactionIds = transMap.keySet();

            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();			fgleList = [SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Payment__c
                        FROM ERP7__Finance_General_Ledger_Entry__c
                        WHERE ERP7__Transactions__c IN :transactionIds
                        AND Accounting_period__c != null
                        AND ERP7__Credit_Entry__c != null
                        AND ERP7__Debit_Entry__c != null
                        AND Accounting_period__r.Status__c != 'Closed'
                       ];

            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();			for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {			if (ledgerMap.containsKey(fgle.ERP7__Transactions__r.ERP7__Payment__c)) {			ledgerMap.get(fgle.ERP7__Transactions__r.ERP7__Payment__c).add(fgle);
                } else {
                    ledgerMap.put(fgle.ERP7__Transactions__r.ERP7__Payment__c, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
                }
            }
            if(paymentIds.size()>0){				List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();			coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'AdvancePayment'];			if(coaMap.size()<1){			newPaymentMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type AdvancePayment');
                }
                coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'InvoicePayment'];			if(coaMap.size()<2){			newPaymentMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type InvoicePayment');
                }
                coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'BillPayment'];			if(coaMap.size()<2){			newPaymentMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type BillPayment');
                }
                coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'CreditPayment'];			if(coaMap.size()<2){			newPaymentMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type CreditPayment');
                }
                coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'VoucherPayment'];			if(coaMap.size()<2){			newPaymentMap.get(paymentIds[0]).addError('Please set up the Coa Mapping of Type VoucherPayment');
                }
                for(Id PayId : paymentIds){			if (ledgerMap!=null && ledgerMap.containsKey(PayId)) {			Decimal creditSum = 0.00;			Decimal debitSum = 0.00;

                        for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(PayId)) {			creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);			debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                        }
                        system.debug('creditSum->'+creditSum);
                        system.debug('debitSum->'+debitSum);
                        if (creditSum != debitSum || creditSum == 0) {		newPaymentMap.get(PayId).addError('Entries Mismatch Found! Please check the amounts');
                        }
                    }else{
                        newPaymentMap.get(PayId).addError('Entries Mismatch or Not Found!');
                    }
                }
            }
        }
    }

  /*  public static void handleCreditNoteAfterInsert(List<ERP7__Credit_Note__c> newCreditNotes, Map<Id, ERP7__Credit_Note__c> newCreditNoteMap, Map<Id, ERP7__Credit_Note__c> oldCreditNoteMap) {
        Map<String, Module__c> runModule = new Map<String, Module__c>(Module__c.getAll());

        if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
            List<Id> CreditIds = new List<Id>();
            for(ERP7__Credit_Note__c cred : newCreditNotes){
                if(cred.ERP7__Posted__c){//&& oldCreditNoteMap.get(cred.Id).ERP7__Posted__c != cred.ERP7__Posted__c
                    CreditIds.add(cred.Id);
                }
            }

            Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([select Id, Name from ERP7__Transaction__c where ERP7__Credit_Note__c IN :CreditIds]);
            Set<Id> transactionIds = transMap.keySet();

            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();
            fgleList = [SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Credit_Note__c, ERP7__Chart_of_Account__c
                        FROM ERP7__Finance_General_Ledger_Entry__c
                        WHERE ERP7__Transactions__c IN :transactionIds
                        AND Accounting_period__c != null
                        AND ERP7__Credit_Entry__c != null
                        AND ERP7__Debit_Entry__c != null
                        AND Accounting_period__r.Status__c != 'Closed'
                       ];

            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
            for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {
                if (ledgerMap.containsKey(fgle.ERP7__Transactions__r.ERP7__Credit_Note__c)) {
                    ledgerMap.get(fgle.ERP7__Transactions__r.ERP7__Credit_Note__c).add(fgle);
                } else {
                    ledgerMap.put(fgle.ERP7__Transactions__r.ERP7__Credit_Note__c, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
                }
            }

            if(CreditIds.size()>0){
                List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
                coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'CreditsReturn'];
                if(coaMap.size()<2){
                    newCreditNoteMap.get(CreditIds[0]).addError('Please set up the Coa Mapping of Type CreditsReturn');
                }
                List<ERP7__Credit_Note_Item__c> credItems = new List<ERP7__Credit_Note_Item__c>();
                credItems = [select Id, Name, ERP7__Product__c, ERP7__Credit_Note__c, ERP7__Product__r.ERP7__Expense_Account__c, ERP7__Product__r.ERP7__Revenue_Account__c, ERP7__Product__r.ERP7__Inventory_Account__c   from ERP7__Credit_Note_Item__c where ERP7__Credit_Note__c IN :CreditIds];
                Map<Id, List<ERP7__Credit_Note_Item__c>> credMap = new Map<Id, List<ERP7__Credit_Note_Item__c>>();
                for(ERP7__Credit_Note_Item__c credItem : credItems){
                    if(credMap.containskey(credItem.ERP7__Credit_Note__c)){
                        credMap.get(credItem.ERP7__Credit_Note__c).add(credItem);
                    }else{
                        List<ERP7__Credit_Note_Item__c> credItemz = new List<ERP7__Credit_Note_Item__c>();
                        credItemz.add(credItem);
                        credMap.put(credItem.ERP7__Credit_Note__c, credItemz);
                    }
                }
                for(Id credId : CreditIds){

                    if (ledgerMap!=null && ledgerMap.containsKey(credId)) {
                        Decimal creditSum = 0.00;
                        Decimal debitSum = 0.00;

                        for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(credId)) {
                            if(fgl.ERP7__Chart_of_Account__c == Null){
                                String errMessage = 'Chart of Account Missing!';
                                newCreditNoteMap.get(credId).addError(errMessage);
                                return;
                            }
                            creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);
                            debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                        }

                        if (creditSum != debitSum || creditSum == 0) {
                            newCreditNoteMap.get(credId).addError('Entries Mismatch Found! Please check the amounts');
                        }
                    }else{
                        newCreditNoteMap.get(credId).addError('Entries Mismatch or Not Found!');
                    }
                }
            }
        }
    }
    */


    public static void handleCreditNoteAfterInsert(List<ERP7__Credit_Note__c> newCreditNotes, Map<Id, ERP7__Credit_Note__c> newCreditNoteMap, Map<Id, ERP7__Credit_Note__c> oldCreditNoteMap) {
    Map<String, Module__c> runModule = new Map<String, Module__c>(Module__c.getAll());
    System.debug('handleCreditNoteAfterInsert started. Credit Notes size: ' + newCreditNotes.size());

    if(runModule.size() > 0 && runModule.get('Finance').ERP7__Run_Posting_Trigger__c){
        List<Id> creditIds = new List<Id>();		for(ERP7__Credit_Note__c cred : newCreditNotes){
            System.debug('Checking Credit Note: ' + cred.Id + ' Posted: ' + cred.ERP7__Posted__c);
            if(cred.ERP7__Posted__c){		creditIds.add(cred.Id);
            }
        }
        System.debug('Credit Note IDs to validate: ' + creditIds);

        Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([			SELECT Id, Name FROM ERP7__Transaction__c WHERE ERP7__Credit_Note__c IN :creditIds
        ]);
        Set<Id> transactionIds = transMap.keySet();
        System.debug('Transaction IDs related to Credit Notes: ' + transactionIds);

        List<ERP7__Finance_General_Ledger_Entry__c> fgleList = [
            SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Credit_Note__c, ERP7__Chart_of_Account__c
            FROM ERP7__Finance_General_Ledger_Entry__c   WHERE ERP7__Transactions__c IN :transactionIds
                AND Accounting_period__c != null
                AND ERP7__Credit_Entry__c != null
                AND ERP7__Debit_Entry__c != null
                AND Accounting_period__r.Status__c != 'Closed'
        ];
        System.debug('Fetched FGLE entries: ' + fgleList.size());

        Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();			for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {			Id credId = fgle.ERP7__Transactions__r.ERP7__Credit_Note__c;
            System.debug('Mapping FGLE to Credit Note ID: ' + credId);
            if (ledgerMap.containsKey(credId)) {			ledgerMap.get(credId).add(fgle);  } else {    ledgerMap.put(credId, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
            }
        }

        if(creditIds.size() > 0){			List<ERP7__COA_Mapping__c> coaMap = [SELECT Id, Name FROM ERP7__COA_Mapping__c WHERE Name = 'CreditsReturn'];
            System.debug('COA Mappings (CreditsReturn): ' + coaMap.size());
            if(coaMap.size() < 2){			newCreditNoteMap.get(creditIds[0]).addError('Please set up the Coa Mapping of Type CreditsReturn');
                System.debug('COA Mapping CreditsReturn missing or insufficient');
            }

            List<ERP7__Credit_Note_Item__c> credItems = [
                SELECT Id, Name, ERP7__Product__c, ERP7__Credit_Note__c, ERP7__Product__r.ERP7__Expense_Account__c,
                       ERP7__Product__r.ERP7__Revenue_Account__c, ERP7__Product__r.ERP7__Inventory_Account__c
                FROM ERP7__Credit_Note_Item__c    WHERE ERP7__Credit_Note__c IN :creditIds
            ];
            System.debug('Fetched Credit Note Line Items: ' + credItems.size());

            Map<Id, List<ERP7__Credit_Note_Item__c>> credMap = new Map<Id, List<ERP7__Credit_Note_Item__c>>();			for(ERP7__Credit_Note_Item__c credItem : credItems){			if(credMap.containsKey(credItem.ERP7__Credit_Note__c)){				credMap.get(credItem.ERP7__Credit_Note__c).add(credItem);
                } else {      credMap.put(credItem.ERP7__Credit_Note__c, new List<ERP7__Credit_Note_Item__c>{credItem});
                }
            }

            for(Id credId : creditIds){
                System.debug('Processing Credit Note: ' + credId);
                if (ledgerMap != null && ledgerMap.containsKey(credId)) {			Decimal creditSum = 0.00;			Decimal debitSum = 0.00;

                    for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(credId)) {
                        System.debug('FGLE → Credit: ' + fgl.ERP7__Credit_Entry__c + ', Debit: ' + fgl.ERP7__Debit_Entry__c + ', COA: ' + fgl.ERP7__Chart_of_Account__c);
                        if(fgl.ERP7__Chart_of_Account__c == null){			String errMsg = 'Chart of Account Missing!';			newCreditNoteMap.get(credId).addError(errMsg);
                            System.debug(errMsg);
                            return;
                        }
                        creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);			debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                    }

                    System.debug('Credit Note ID: ' + credId + ' → Credit Sum: ' + creditSum + ', Debit Sum: ' + debitSum);
                    if (creditSum != debitSum || creditSum == 0) {			String mismatchErr = 'Entries Mismatch Found! Please check the amounts';			newCreditNoteMap.get(credId).addError(mismatchErr);
                        System.debug(mismatchErr);
                    }
                } else {
                    String notFoundErr = 'Entries Mismatch or Not Found!';			newCreditNoteMap.get(credId).addError(notFoundErr);
                    System.debug(notFoundErr);
                }
            }
        }
    }
}

    public static void handleDebitNoteAfterInsert(List<ERP7__Debit_Note__c> newDebitNotes, Map<Id, ERP7__Debit_Note__c> newDebitNoteMap, Map<Id, ERP7__Debit_Note__c> oldDebitNoteMap) {
        Map<string, Module__c > RunModule = new Map<string, Module__c >();
        RunModule =  Module__c.getAll();
        if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
            List<Id> DBIds = new List<Id>();			for(ERP7__Debit_Note__c debit : newDebitNotes){			if(debit.ERP7__Posted__c){// && oldDebitNoteMap.get(debit.Id).ERP7__Posted__c != debit.ERP7__Posted__c
   DBIds.add(debit.Id);
                }
            }

            Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([select Id, Name from ERP7__Transaction__c where ERP7__Debit_Note__c IN :DBIds]);			Set<Id> transactionIds = transMap.keySet();

            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();			fgleList = [SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Debit_Note__c
                        FROM ERP7__Finance_General_Ledger_Entry__c
                        WHERE ERP7__Transactions__c IN :transactionIds
                        AND Accounting_period__c != null
                        AND ERP7__Credit_Entry__c != null
                        AND ERP7__Debit_Entry__c != null
                        AND Accounting_period__r.Status__c != 'Closed'
                       ];

            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();			for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {			if (ledgerMap.containsKey(fgle.ERP7__Transactions__r.ERP7__Debit_Note__c)) {			ledgerMap.get(fgle.ERP7__Transactions__r.ERP7__Debit_Note__c).add(fgle);
                } else {
                    ledgerMap.put(fgle.ERP7__Transactions__r.ERP7__Debit_Note__c, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
                }
            }

            if(DBIds.size()>0){			List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();			coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'POReturn'];				if(coaMap.size()<2){			newDebitNoteMap.get(DBIds[0]).addError('Please set up the Coa Mapping of Type POReturn');
                }


                List<ERP7__Debit_Note_Item__c> dbItems = new List<ERP7__Debit_Note_Item__c>();			dbItems = [select Id, Name, ERP7__Chart_Of_Account__c, ERP7__Bill__c, ERP7__Debit_Note__c  from ERP7__Debit_Note_Item__c where ERP7__Debit_Note__c IN :DBIds];				Map<Id, List<ERP7__Debit_Note_Item__c>> DBMap = new Map<Id, List<ERP7__Debit_Note_Item__c>>();				for(ERP7__Debit_Note_Item__c dbItem : dbItems){			if(DBMap.containskey(dbItem.ERP7__Debit_Note__c)){			DBMap.get(dbItem.ERP7__Debit_Note__c).add(dbItem);
                    }else{
                        List<ERP7__Debit_Note_Item__c> dbItemz = new List<ERP7__Debit_Note_Item__c>();			dbItemz.add(dbItem);			DBMap.put(dbItem.ERP7__Debit_Note__c, dbItemz);
                    }
                }
                for(Id DBId : DBIds){			if(DBMap.size()>0){				for(ERP7__Debit_Note_Item__c  dbItem : DBMap.get(DBId)){			if(dbItem.ERP7__Chart_Of_Account__c == null){			String errMessage = 'Entries Mismatch Found!. Please check the Inventory or Expense Account for the Line Item- '+ dbItem.Name;			newDebitNoteMap.get(DBId).addError(errMessage);
                            }
                        }
                    }
                    if (ledgerMap!=null && ledgerMap.containsKey(DBId)) {			Decimal creditSum = 0.00;			Decimal debitSum = 0.00;

                        for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(DBId)) {			creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);			debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                        }

                        if (creditSum != debitSum || creditSum == 0) {			newDebitNoteMap.get(DBId).addError('Entries Mismatch Found! Please check the amounts');
                        }
                    }else{
                        newDebitNoteMap.get(DBId).addError('Entries Mismatch or Not Found!');
                    }
                }
            }
        }
    }


    public static void handleExpenseAfterInsert(List<ERP7__Expense__c> newExpenses, Map<Id, ERP7__Expense__c> newExpenseMap, Map<Id, ERP7__Expense__c> oldExpenseMap) {			Map<string, Module__c > RunModule = new Map<string, Module__c >();			RunModule =  Module__c.getAll();			if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){			List<Id> ExpIds = new List<Id>();			for(ERP7__Expense__c exp : newExpenses){			if(exp.Paid__c){// && oldDebitNoteMap.get(debit.Id).ERP7__Posted__c != debit.ERP7__Posted__c
                    ExpIds.add(exp.Id);
                }
            }

            Map<Id, ERP7__Transaction__c> transMap = new Map<Id, ERP7__Transaction__c>([select Id, Name from ERP7__Transaction__c where ERP7__Expense__c IN :ExpIds]);			Set<Id> transactionIds = transMap.keySet();

            List<ERP7__Finance_General_Ledger_Entry__c> fgleList = new List<ERP7__Finance_General_Ledger_Entry__c>();			fgleList = [SELECT ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Transactions__c, ERP7__Transactions__r.ERP7__Expense__c, ERP7__Chart_of_Account__c
                        FROM ERP7__Finance_General_Ledger_Entry__c
                        WHERE ERP7__Transactions__c IN :transactionIds
                        AND Accounting_period__c != null
                        AND ERP7__Credit_Entry__c != null
                        AND ERP7__Debit_Entry__c != null
                        AND Accounting_period__r.Status__c != 'Closed'
                       ];

            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();				for (ERP7__Finance_General_Ledger_Entry__c fgle : fgleList) {			if (ledgerMap.containsKey(fgle.ERP7__Transactions__r.ERP7__Expense__c)) {			ledgerMap.get(fgle.ERP7__Transactions__r.ERP7__Expense__c).add(fgle);
                } else {
                    ledgerMap.put(fgle.ERP7__Transactions__r.ERP7__Expense__c, new List<ERP7__Finance_General_Ledger_Entry__c>{fgle});
                }
            }

            if(ExpIds.size()>0){		List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();			coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'Expenses'];			if(coaMap.size()<1){	newExpenseMap.get(ExpIds[0]).addError('Please set up the Coa Mapping of Type Expenses');
                }


                List<ERP7__Expense_Line_Item__c> expItems = new List<ERP7__Expense_Line_Item__c>();			expItems = [select Id, Name, ERP7__Chart_Of_Account__c, ERP7__Expense__c  from ERP7__Expense_Line_Item__c where ERP7__Expense__c IN :ExpIds]; /* And ERP7__Expense_Type__c != 'Bill Payment'	*/		Map<Id, List<ERP7__Expense_Line_Item__c>> ExpMap = new Map<Id, List<ERP7__Expense_Line_Item__c>>();			for(ERP7__Expense_Line_Item__c expItem : expItems){			if(ExpMap.containskey(expItem.ERP7__Expense__c)){			ExpMap.get(expItem.ERP7__Expense__c).add(expItem);
                    }else{
                        List<ERP7__Expense_Line_Item__c> expItemz = new List<ERP7__Expense_Line_Item__c>();			expItemz.add(expItem);			ExpMap.put(expItem.ERP7__Expense__c, expItemz);
                    }
                }

                for(Id ExpId : ExpIds){
                    /*if(ExpMap.size()>0){
for(ERP7__Expense_Line_Item__c  expItem : DBMap.get(ExpId)){
if(dbItem.ERP7__Chart_Of_Account__c == null){
String errMessage = 'Entries Mismatch Found!. Please check the Inventory or Expense Account for the Line Item- '+ dbItem.Name;
newDebitNoteMap.get(DBId).addError(errMessage);
}
}
}*/
                    //if(ExpMap.containsKey(ExpId)){
                    if (ledgerMap!=null && ledgerMap.containsKey(ExpId)) {			Decimal creditSum = 0.00;			Decimal debitSum = 0.00;

                        for (ERP7__Finance_General_Ledger_Entry__c fgl : ledgerMap.get(ExpId)) {			if(fgl.ERP7__Chart_of_Account__c == Null){			String errMessage = 'Chart of Account Missing!';			newExpenseMap.get(ExpId).addError(errMessage);			return;
                            }
                            creditSum += fgl.ERP7__Credit_Entry__c.setScale(2);			debitSum += fgl.ERP7__Debit_Entry__c.setScale(2);
                        }

                        if (creditSum != debitSum || creditSum == 0) {			newExpenseMap.get(ExpId).addError('Entries Mismatch Found! Please check the amounts');
                        }
                    }else{
                        newExpenseMap.get(ExpId).addError('Entries Mismatch or Not Found!');
                    }
                    //}
                }
            }
        }
    }


    public static void createTransactionsAndLedgerEntries(List<Manufacturing_Order__c> mos, Set<Id> moIds){
        List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
        List<ERP7__Transaction__c > transactionsToCreate = new List<ERP7__Transaction__c>();
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];//WHERE ERP7__Start_Date__c = THIS_FISCAL_YEAR
        Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
        for(ERP7__Accounting_Period__c acc :accperiodList){
            accountingPeriodMapBYName.put(acc.Name,acc);
        }
        List < Finance_General_Ledger__c > FinanceGeneralLedgers = [Select Id, Name, Accounting_Period_End_Date__c, Accounting_Period_Start_Date__c, Active__c, Description__c, CreatedDate,
                                                                    Organisation__c, Organisation_Business_Unit__c From Finance_General_Ledger__c Where Active__c = true limit 1];
        Map<Id, Id> MOExisting_Transactions = new Map<Id, id>();
        Map<Id, Id> MOCompleteExisting_Transactions = new Map<Id, id>();
        Map < String, Id > ExistingFGLEMap = new Map < String, Id > ();
        for(Transaction__c eTransaction :[Select Id,Name, ERP7__Manufacturing_Order__c  From Transaction__c Where ERP7__Manufacturing_Order__c In :moIds])
            MOExisting_Transactions.put(eTransaction.ERP7__Manufacturing_Order__c, eTransaction.id);
        for(Transaction__c eTransaction :[Select Id,Name, ERP7__Transaction_Type__c, ERP7__Manufacturing_Order__c  From Transaction__c Where ERP7__Manufacturing_Order__c In :moIds and ERP7__Transaction_Type__c='Finish Good Inventory'])
            MOCompleteExisting_Transactions.put(eTransaction.ERP7__Manufacturing_Order__c, eTransaction.id);
        Account acc = UtilClass.getOrganisationByLogin_Employee();
        Map<Id, Manufacturing_Order__c> moMap = new Map<Id, Manufacturing_Order__c>();
        List<ERP7__Finance_General_Ledger_Entry__c > ledgerEntry= new List<ERP7__Finance_General_Ledger_Entry__c >();
        coaMap = [select Id, Name, ERP7__Chart_of_Account__c from ERP7__COA_Mapping__c where Name='WIP Inventory' limit 1];
        for(Manufacturing_Order__c mo:mos){
            moMap.put(mo.Id, mo);
            // Create a new transaction record for each depreciation schedule
            ERP7__Transaction__c trans = new ERP7__Transaction__c(Id=(MOExisting_Transactions.get(mo.Id)!=null)?MOExisting_Transactions.get(mo.Id):null);
            trans.ERP7__Amount__c=0;//mo.ERP7__Cost__c;
            trans.ERP7__Transaction_Date__c=Date.today();
            string month = (String.valueof(trans.ERP7__Transaction_Date__c.month()).length() > 1)? String.valueof(trans.ERP7__Transaction_Date__c.month()) : '0'+trans.ERP7__Transaction_Date__c.month();
            String periodName = trans.ERP7__Transaction_Date__c.year()+'-'+month;
            // added shaguftha 08_02_24 if below condition with contains
            if(accountingPeriodMapBYName.containsKey(periodName)) trans.ERP7__Accounting_Period__c = accountingPeriodMapBYName.get(periodName).Id;
            trans.ERP7__Transaction_Type__c='WIP Inventory';
            trans.ERP7__Manufacturing_Order__c=mo.Id;

            trans.ERP7__Organisation__c=acc.Id;
            trans.ERP7__Transaction_Status__c='Completed';
            trans.ERP7__Finance_Category_Type__c='Credit';

            transactionsToCreate.add(trans);
            if(mo.ERP7__Status__c=='Complete'){
                ERP7__Transaction__c trans1 = new ERP7__Transaction__c(Id=(MOCompleteExisting_Transactions.get(mo.Id)!=null)?MOCompleteExisting_Transactions.get(mo.Id):null);
                trans1.ERP7__Amount__c=0;//mo.ERP7__Cost__c;
                trans1.ERP7__Transaction_Date__c=Date.today();
                string month1 = (String.valueof(trans1.ERP7__Transaction_Date__c.month()).length() > 1)? String.valueof(trans1.ERP7__Transaction_Date__c.month()) : '0'+trans1.ERP7__Transaction_Date__c.month();
                String periodName1 = trans1.ERP7__Transaction_Date__c.year()+'-'+month1;
                 // added shaguftha 08_02_24 if condition below with contains
                if(accountingPeriodMapBYName.containsKey(periodName)) trans1.ERP7__Accounting_Period__c = accountingPeriodMapBYName.get(periodName1).Id;
                trans1.ERP7__Transaction_Type__c='Finish Good Inventory';
                trans1.ERP7__Manufacturing_Order__c=mo.Id;

                trans1.ERP7__Organisation__c=acc.Id;
                trans1.ERP7__Transaction_Status__c='Completed';
                trans1.ERP7__Finance_Category_Type__c='Credit';

                transactionsToCreate.add(trans1);
            }
        }

        // Remove duplicates from transactionsToCreate
        Set<Id> transactionIds = new Set<Id>();
        List<ERP7__Transaction__c> uniqueTransactions = new List<ERP7__Transaction__c>();

        for (ERP7__Transaction__c trans : transactionsToCreate) {
            if (!transactionIds.contains(trans.Id)) {
                transactionIds.add(trans.Id);
                uniqueTransactions.add(trans);
            }
        }

        // Upsert unique transactions
        if (!uniqueTransactions.isEmpty()) {
            PreventRecursiveLedgerEntry.preventTriggerMO = false;
            upsert uniqueTransactions;
        }
        /*if (!transactionsToCreate.isEmpty()) {
            upsert transactionsToCreate;
        }*/
        Set<Id> TransIds = new Set<Id>();
        for(ERP7__Transaction__c trans : uniqueTransactions){
            TransIds.add(trans.Id);
        }
        List<ERP7__Transaction__c > transactionsList = new List<ERP7__Transaction__c>();
        if(TransIds!=null && TransIds.size()>0){
            transactionsList = [select Id, Name, ERP7__Transaction_Type__c, ERP7__Accounting_Period__c, ERP7__Transaction_Date__c, ERP7__Manufacturing_Order__c, ERP7__Manufacturing_Order__r.ERP7__Cost__c, ERP7__Manufacturing_Order__r.ERP7__Labour_Cost__c, ERP7__Manufacturing_Order__r.ERP7__Material_Cost__c,ERP7__Manufacturing_Order__r.ERP7__Overhead_Cost__c, ERP7__Manufacturing_Order__r.ERP7__Scrap_Cost__c from ERP7__Transaction__c where Id IN:TransIds];
        }
        for (Finance_General_Ledger_Entry__c ExistingFGLE: [SELECT Id, ERP7__Chart_of_Account__c, Transactions__c FROM Finance_General_Ledger_Entry__c WHERE Transactions__c IN: TransIds Order By Name]) {
            ExistingFGLEMap.put(ExistingFGLE.Transactions__c + '_' + ExistingFGLE.ERP7__Chart_of_Account__c, ExistingFGLE.Id);
        }
        List<ERP7__COA_Mapping__c> COAList = new List<ERP7__COA_Mapping__c>();
        List<ERP7__COA_Mapping__c> COAFGList = new List<ERP7__COA_Mapping__c>();
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c', 'Credit_General_Ledger_Entry');
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c', 'Debit_General_Ledger_Entry');
        COAList = [SELECT ID,NAME ,ERP7__Chart_of_Account__c ,Tax__c ,ERP7__Contra__c, Discount__c ,ERP7__Chart_of_Account__r.Name  FROM ERP7__COA_Mapping__c where Name='WIP Inventory' limit 10000];
        COAFGList = [SELECT ID,NAME ,ERP7__Chart_of_Account__c ,Tax__c ,ERP7__Contra__c, Discount__c ,ERP7__Chart_of_Account__r.Name  FROM ERP7__COA_Mapping__c where Name='Finish Good Inventory' limit 10000];
        if(COAList!=null){
            for(ERP7__Transaction__c trans : transactionsList){
				if(trans.ERP7__Transaction_Type__c == 'WIP Inventory'){
				for(ERP7__COA_Mapping__c coa : COAList){
					Finance_General_Ledger_Entry__c FGLE = new Finance_General_Ledger_Entry__c();
					system.debug('coa-->'+coa);
					system.debug('moMap-->'+moMap);
					if(coa.Tax__c && !moMap.isEmpty() && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Labour_Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Labour_Cost__c>0) {
						FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Credit_Entry__c = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Labour_Cost__c, General_Ledger_Entry_Type__c = 'Credit', RecordTypeId = rTypeCredit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);
						ledgerEntry.add(FGLE);
					}
					if(coa.Discount__c && !moMap.isEmpty() && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Overhead_Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Overhead_Cost__c>0){
						FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Credit_Entry__c = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Overhead_Cost__c, General_Ledger_Entry_Type__c = 'Credit', RecordTypeId = rTypeCredit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);
						ledgerEntry.add(FGLE);
					}
					if(coa.ERP7__Contra__c && !moMap.isEmpty() && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c>0 ){
						Decimal amount = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Material_Cost__c;
						FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Credit_Entry__c = amount, General_Ledger_Entry_Type__c = 'Credit', RecordTypeId = rTypeCredit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);
						ledgerEntry.add(FGLE);
					}
					if(!coa.Tax__c && !coa.Discount__c && !coa.ERP7__Contra__c && !moMap.isEmpty() && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Overhead_Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c>0){
						Decimal amount = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Material_Cost__c + moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Labour_Cost__c+moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Overhead_Cost__c;
						FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Debit_Entry__c = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c, General_Ledger_Entry_Type__c = 'Debit', RecordTypeId = rTypeDebit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);
						ledgerEntry.add(FGLE);
					}
				}
				}
				if(trans.ERP7__Transaction_Type__c == 'Finish Good Inventory'){
					for(ERP7__COA_Mapping__c coa : COAFGList){
					Finance_General_Ledger_Entry__c FGLE = new Finance_General_Ledger_Entry__c();
					system.debug('coa-->'+coa);
					system.debug('moMap-->'+moMap);
					if(coa.ERP7__Contra__c && !moMap.isEmpty() && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c>0 ){
                        system.debug('Entered-->');
						Decimal amount = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Material_Cost__c + moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Labour_Cost__c+moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Overhead_Cost__c + moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Scrap_Cost__c;				FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Credit_Entry__c = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c, General_Ledger_Entry_Type__c = 'Credit', RecordTypeId = rTypeCredit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);				ledgerEntry.add(FGLE);
					}
					if(coa.Discount__c && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Scrap_Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Scrap_Cost__c>0){
						FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Debit_Entry__c = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Scrap_Cost__c, General_Ledger_Entry_Type__c = 'Debit', RecordTypeId = rTypeDebit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);			ledgerEntry.add(FGLE);
					}
                    if(coa.Tax__c && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Rejected_Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Rejected_Cost__c>0){
						FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Debit_Entry__c = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Rejected_Cost__c, General_Ledger_Entry_Type__c = 'Debit', RecordTypeId = rTypeDebit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);			ledgerEntry.add(FGLE);
					}
					if(!coa.Tax__c && !coa.Discount__c && !coa.ERP7__Contra__c && !moMap.isEmpty() && moMap.containskey(trans.ERP7__Manufacturing_Order__c) && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c!=null && moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c>0){
						Decimal amount = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Material_Cost__c + moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Labour_Cost__c+moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Overhead_Cost__c - moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Scrap_Cost__c - moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Rejected_Cost__c;			FGLE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) != null) ? ExistingFGLEMap.get(trans.id + '_' + COA.ERP7__Chart_of_Account__c) : null, Debit_Entry__c = moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Cost__c-moMap.get(trans.ERP7__Manufacturing_Order__c).ERP7__Scrap_Cost__c, General_Ledger_Entry_Type__c = 'Debit', RecordTypeId = rTypeDebit, ERP7__Chart_of_Account__c = COA.ERP7__Chart_of_Account__c, General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c, Accounting_period__c = trans.ERP7__Accounting_Period__c, Active__c = true, Organisation__c = acc.Id, Transactions__c = trans.Id, Finance_General_Ledger__c =FinanceGeneralLedgers[0].Id);			ledgerEntry.add(FGLE);
					}
				}
				}
            }
            system.debug('ledgerEntry-->'+ledgerEntry);
            if (!ledgerEntry.isEmpty()) {
                upsert ledgerEntry;
                PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
            }
        }
    }

    public static void createTransactionsAndLedgerEntriesSTLine(List<ERP7__Stock_Take_Line_Item__c> stlis, Set<Id> stliIds){
        Set<Id> slIds = new Set<Id>();
        Map<String, Id> prodInvMap = new Map<String, Id>();
        Map<String, Id> prodExpMap = new Map<String, Id>();
        Map<String, Id> prodRevMap = new Map<String, Id>();
        Set<Id> prodIds=new Set<Id>();
        for(ERP7__Stock_Take_Line_Item__c sts : stlis){
            if(sts.ERP7__Unit_Price__c!=null && sts.ERP7__Unit_Price__c>0){
                slIds.add(sts.Id);
                prodIds.add(sts.ERP7__Product__c);
            }
        }
        if(slIds.size()>0){
            List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
            List<ERP7__Transaction__c > transactionsToCreate = new List<ERP7__Transaction__c>();
            List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
            accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];//WHERE ERP7__Start_Date__c = THIS_FISCAL_YEAR
            Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
            for(ERP7__Accounting_Period__c acc :accperiodList){
                accountingPeriodMapBYName.put(acc.Name,acc);
            }
            List < Finance_General_Ledger__c > FinanceGeneralLedgers = [Select Id, Name, Accounting_Period_End_Date__c, Accounting_Period_Start_Date__c, Active__c, Description__c, CreatedDate,
                                                                        Organisation__c, Organisation_Business_Unit__c From Finance_General_Ledger__c Where Active__c = true limit 1];
            Map<Id, Id> STLExisting_Transactions = new Map<Id, id>();
            Map < String, Id > ExistingFGLEMap = new Map < String, Id > ();
            for(Transaction__c eTransaction :[Select Id,Name, ERP7__Stock_Take_Line_Item__c  From Transaction__c Where ERP7__Stock_Take_Line_Item__c In :slIds])
                STLExisting_Transactions.put(eTransaction.ERP7__Stock_Take_Line_Item__c, eTransaction.id);
            Account acc = UtilClass.getOrganisationByLogin_Employee();
            if(prodIds.size()>0){
                List<ERP7__Product_Coa__c> pcoa = new List<ERP7__Product_Coa__c>();
                pcoa = [select Id, Name, ERP7__Expense_Account__c, ERP7__Inventory_Account__c, ERP7__Revenue_Account__c, ERP7__Product__c from ERP7__Product_Coa__c where ERP7__Product__c IN:prodIds and ERP7__Organisation__c =:acc.Id];
                system.debug('pcoa-->'+pcoa);
                if(pcoa.size()>0){
                    for(ERP7__Product_Coa__c pco : pcoa){			if(pco.ERP7__Expense_Account__c!=null) prodExpMap.put(pco.ERP7__Product__c, pco.ERP7__Expense_Account__c);			if(pco.ERP7__Inventory_Account__c!=null) prodInvMap.put(pco.ERP7__Product__c, pco.ERP7__Inventory_Account__c);			if(pco.ERP7__Revenue_Account__c!=null) prodRevMap.put(pco.ERP7__Product__c, pco.ERP7__Revenue_Account__c);
                    }
                }
            }
            for(ERP7__Stock_Take_Line_Item__c sts : stlis){
                if(sts.ERP7__Unit_Price__c!=null && sts.ERP7__Unit_Price__c>0){
                    ERP7__Transaction__c trans = new ERP7__Transaction__c(Id=(STLExisting_Transactions.get(sts.Id)!=null)?STLExisting_Transactions.get(sts.Id):null);
                    trans.ERP7__Amount__c=0;//mo.ERP7__Cost__c;
                    trans.ERP7__Transaction_Date__c=Date.today();
                    string month = (String.valueof(trans.ERP7__Transaction_Date__c.month()).length() > 1)? String.valueof(trans.ERP7__Transaction_Date__c.month()) : '0'+trans.ERP7__Transaction_Date__c.month();
                    String periodName = trans.ERP7__Transaction_Date__c.year()+'-'+month;

                    if (Test.isRunningTest()) {

                    } else {
                        trans.ERP7__Accounting_Period__c = accountingPeriodMapBYName.get(periodName).Id;
                    }
                                        trans.ERP7__Transaction_Type__c='Stock Take Inventory';
                    trans.ERP7__Stock_Take_Line_Item__c=sts.Id;

                    trans.ERP7__Organisation__c=acc.Id;
                    trans.ERP7__Transaction_Status__c='Completed';
                    trans.ERP7__Finance_Category_Type__c='Credit';

                    transactionsToCreate.add(trans);
                }
            }
            Set<Id> transactionIds = new Set<Id>();
            List<ERP7__Transaction__c> uniqueTransactions = new List<ERP7__Transaction__c>();

            for (ERP7__Transaction__c trans : transactionsToCreate) {
                if (!transactionIds.contains(trans.Id)) {
                    transactionIds.add(trans.Id);
                    uniqueTransactions.add(trans);
                }
            }

            // Upsert unique transactions
            if (!uniqueTransactions.isEmpty()) {
                upsert uniqueTransactions;
                PreventRecursiveLedgerEntry.preventStlTriggerTransactions = true;
            }
        }
    }

    public static Boolean checkForAccountingPeriodClosing(Date recordDate){
        Boolean isclosed = false;
        system.debug('recordDate-->'+recordDate);
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];//WHERE ERP7__Start_Date__c = THIS_FISCAL_YEAR
        Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
        for(ERP7__Accounting_Period__c acc :accperiodList){
            accountingPeriodMapBYName.put(acc.Name,acc);
        }
        if(recordDate == null)recordDate = system.Today();
        string month = (String.valueof(recordDate.month()).length() > 1)? String.valueof(recordDate.month()) : '0'+recordDate.month();
        String periodName = recordDate.year()+'-'+month;
        if(accountingPeriodMapBYName.get(periodName) != null ){
            system.debug('period-->'+accountingPeriodMapBYName.get(periodName));
            if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed')			isclosed = true;
        }
        return isclosed;
    }

    public static Boolean checkForAccountingPeriodClosingPassword(Date recordDate, String pass){			Boolean isclosed = false;
        system.debug('recordDate-->'+recordDate);
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();			accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__Password__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];/* WHERE ERP7__Start_Date__c = THIS_FISCAL_YEAR		*/				Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();				for(ERP7__Accounting_Period__c acc :accperiodList){			accountingPeriodMapBYName.put(acc.Name,acc);
        }
        if(recordDate == null)recordDate = system.Today();			string month = (String.valueof(recordDate.month()).length() > 1)? String.valueof(recordDate.month()) : '0'+recordDate.month();				String periodName = recordDate.year()+'-'+month;			if(accountingPeriodMapBYName.get(periodName) != null ){
            system.debug('period-->'+accountingPeriodMapBYName.get(periodName));
            if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed' && accountingPeriodMapBYName.get(periodName).ERP7__Password__c !=pass)			isclosed = true;
        }
        return isclosed;
    }
}