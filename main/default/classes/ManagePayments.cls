/*
 * Changes Made by - Syed Moin Pasha
 * Date - 11th August 2021
 * Reason - Transaction was creating only 1 ledger entry on payment Post
 * Fix - verify that the transaction was not carrying the amount as we were updating it with total Amount field in Payment
 *       Updated the condition to update the Transaction Amount with Either Amount or Total amount which is carrying the Values
 *       Line 68
 * 
*/

public with sharing class ManagePayments {
    /*
    Create Transactions on Posting payments   
    */
//public static void beforeUpsert_Operation(List<ERP7__Payment__c> paymentList1){
public static void beforeUpsert_Operation(String paymentList1){
    List<ERP7__Payment__c> paymentList = (List<ERP7__Payment__c>)JSON.deserialize(paymentList1, List<ERP7__Payment__c>.class);
    Map<Id,Id> oldCOA = new Map<Id,Id>();
    Map<Id,Id> newCOA = new Map<Id,Id>();
    Map<Id,Id> invIdMap2OrderId = new Map<Id,Id>();
    set<Id> invoiceIds = new set<Id>();
    for(Integer i=0;i<paymentList.size();i++){
        if(paymentList[i].ERP7__Invoice__c != null &&  (paymentList[i].ERP7__Sales_Order__c == null || paymentList[i].ERP7__Order__c ==null))
            invoiceIds.add(paymentList[i].ERP7__Invoice__c);
        if(paymentList[i].ERP7__Payment_Account__c != null)  newCOA.put(paymentList[i].id,paymentList[i].ERP7__Payment_Account__c);
        if(paymentList[i].ERP7__Total_Amount__c == null && paymentList[i].ERP7__Amount__c != null)
            paymentList[i].ERP7__Total_Amount__c = paymentList[i].ERP7__Amount__c;
        else
            paymentList[i].ERP7__Amount__c = paymentList[i].ERP7__Total_Amount__c;
    }
    Boolean isSalesOrder=false;
    for(ERP7__Invoice__c inv: [SELECT Id,ERP7__Order__c,ERP7__Order_S__c FROM ERP7__Invoice__c WHERE id in: invoiceIds]){
        if(inv.ERP7__Order__c != null){ invIdMap2OrderId.put(inv.Id,inv.ERP7__Order__c); isSalesOrder=true;}
        else if(inv.ERP7__Order_S__c != null) invIdMap2OrderId.put(inv.Id,inv.ERP7__Order_S__c);
    }
    if(invIdMap2OrderId.size()>0){
        for(Integer i=0;i<paymentList.size();i++){
            if(invIdMap2OrderId.get(paymentList[i].ERP7__Invoice__c) != null)
                if(isSalesOrder) paymentList[i].ERP7__Sales_Order__c = invIdMap2OrderId.get(paymentList[i].ERP7__Invoice__c); 
                else paymentList[i].ERP7__Order__c = invIdMap2OrderId.get(paymentList[i].ERP7__Invoice__c); 
        }
            
    }
    if(Trigger.isUpdate){
        for(Transaction__c transOld :[Select Id,ERP7__Payment__r.ERP7__Payment_Account__c FROM Transaction__c WHERE ERP7__Payment__c IN: Trigger.oldMap.keyset()]){            oldCOA.put(transOld.id,transOld.ERP7__Payment__r.ERP7__Payment_Account__c);
        }
        List<Finance_General_Ledger_Entry__c> ExistingFGLEs = new List<Finance_General_Ledger_Entry__c>();
        ExistingFGLEs = [SELECT Id,ERP7__Chart_of_Account__c,Transactions__r.ERP7__Payment__c FROM Finance_General_Ledger_Entry__c WHERE Transactions__r.ERP7__Payment__c IN: Trigger.oldMap.keyset() AND ERP7__Chart_of_Account__c IN:oldCOA.values() Order By Name];
        for(Integer i=0;i<ExistingFGLEs.size();i++)            if(newCoA.get(ExistingFGLEs[i].Transactions__r.ERP7__Payment__c) != null)            ExistingFGLEs[i].ERP7__Chart_of_Account__c = newCoA.get(ExistingFGLEs[i].Transactions__r.ERP7__Payment__c);
        if(ExistingFGLEs.size()>0)update ExistingFGLEs;
    }
}
public static void upsertTransactionOnPaymentPost(){
    Map < Id, Id > existingTransactionForPayment_MAP = new Map < Id, Id > ();
    for (Transaction__c trans: [SELECT id, Payment__c FROM Transaction__c WHERE Payment__c in : Trigger.newMap.keyset()]) existingTransactionForPayment_MAP.put(trans.Payment__c, trans.id);
   
    Id CIT = RecordTypeUtil.getObjectRecordTypeId(Transaction__c.SObjectType, 'Customer Invoice Transaction');
    Id SIT = RecordTypeUtil.getObjectRecordTypeId(Transaction__c.SObjectType, 'Supplier Invoice Transaction');
    List < Transaction__c > Transactions2update = new List < Transaction__c > ();
    for (Integer i = 0; i < System.Trigger.New.size(); i++) {
        Payment__c payment = (ERP7__Payment__c)System.Trigger.New[i];
        Transaction__c trans = new Transaction__c(id = (existingTransactionForPayment_MAP.get(payment.id) != null) ? existingTransactionForPayment_MAP.get(payment.id) : null);
        if (payment.Posted__c && !payment.ERP7__Refund__c) {            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){trans.Active__c = true;}else{/*No access*/}            if(payment.ERP7__Amount__c!=null){ if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = payment.ERP7__Amount__c;}else{/*No access*/} }            else{ if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = payment.ERP7__Total_Amount__c;}else{/*No access*/} }            if(payment.ERP7__Bank_Charges__c >0 ){ if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c += payment.ERP7__Bank_Charges__c;}else{/*No access*/}   }                          if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = (payment.Posted_Date__c != null) ? payment.Posted_Date__c : System.Today();}else{/*No access*/}            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed';}else{/*No access*/}            if(Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isUpdateable()){trans.Transaction_Method__c = payment.Payment_Gateway__c;}else{/*No access*/}            if(payment.ERP7__Debit_Note__c != null){ if(Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isUpdateable()){trans.ERP7__Debit_Note__c = payment.ERP7__Debit_Note__c;}else{/*No access*/}}            if(payment.ERP7__Pre_Payment__c){ if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'PrePayment';}else{/*No access*/} }            else{ if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = payment.ERP7__Transaction_Type__c;}else{/*No access*/} }            if(Schema.sObjectType.Transaction__c.fields.Payment__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Payment__c.isUpdateable()){trans.Payment__c = payment.Id;}else{/*No access*/}            if (payment.ERP7__Voucher__c != null || payment.ERP7__Bill__c != null){                trans.ERP7__Finance_Category_Type__c = 'Credit';            }else{                trans.ERP7__Finance_Category_Type__c = 'Debit';            }            if(payment.ERP7__Accounts__c !=null && payment.ERP7__Transaction_Type__c=='BillPayment'){                trans.ERP7__Supplier__c = payment.ERP7__Accounts__c;            }            if(payment.ERP7__Debit_Note__c != null && payment.ERP7__Accounts__c !=null){                trans.ERP7__Supplier__c = payment.ERP7__Accounts__c;            }            if(payment.ERP7__Accounts__c !=null && payment.ERP7__Transaction_Type__c=='InvoicePayment'){                trans.ERP7__Customer__c = payment.ERP7__Accounts__c;            }            if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){trans.Organisation__c = payment.ERP7__Account__c;}else{/*No access*/}            if (payment.ERP7__Voucher__c != null || payment.ERP7__Bill__c != null){   if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){trans.RecordTypeId =  SIT;}else{/*No access*/} }            else{    if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){trans.RecordTypeId = CIT;}else{/*No access*/} }            Transactions2update.add(trans);        }   
    }
        
    //&& Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable() && Schema.sObjectType.Transaction__c.fields.Payment__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Payment__c.isUpdateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isUpdateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isUpdateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()
    system.debug('Transactions2update.size() from managePayments~>'+Transactions2update.size());
    PreventRecursiveLedgerEntry.TransactionProcess = true;
    if (Transactions2update.size() > 0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){ upsert Transactions2update;}else{ /*('Not allowed to upsert transaction');*/ }
    
}

 public static void upsertPaymentsAppliedonInvoice(Set<Id> paymentsIds){
    Map < Id, Id > existingPaymentsAppliedonInvoice_MAP = new Map < Id, Id > ();
    for (ERP7__Payment_Applied_on_Invoice__c PAyApplied: [SELECT id, Payment__c FROM ERP7__Payment_Applied_on_Invoice__c WHERE Payment__c in : paymentsIds and Payment__r.ERP7__Status__c = 'Paid' and Payment__r.ERP7__Invoice__c != null]) existingPaymentsAppliedonInvoice_MAP.put(PAyApplied.id, PAyApplied.Payment__c);
   
     
     List < ERP7__Payment_Applied_on_Invoice__c > PaymentApplied2update = new List < ERP7__Payment_Applied_on_Invoice__c > ();
        for (Integer i = 0; i < System.Trigger.New.size(); i++) {
            Payment__c payment = (ERP7__Payment__c)System.Trigger.New[i];
            ERP7__Payment_Applied_on_Invoice__c PAyApp = new ERP7__Payment_Applied_on_Invoice__c(id = (existingPaymentsAppliedonInvoice_MAP.get(payment.id) != null) ? existingPaymentsAppliedonInvoice_MAP.get(payment.id) : null);
            
            if (trigger.isUpdate && payment.Status__c == Trigger.old[i].get('ERP7__Status__c') && payment.Status__c == 'Paid' && PAyApp.id == null){ break;}
            
            if (payment.Status__c == 'Paid' && payment.ERP7__Invoice__c != null) {
                
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Amount__c.isUpdateable()){PAyApp.Amount__c = payment.Amount__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable()){PAyApp.ERP7__Invoice__c = payment.ERP7__Invoice__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable()){PAyApp.ERP7__Payment__c = payment.Id;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Type__c.isUpdateable()){PAyApp.ERP7__Type__c = payment.ERP7__Type__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Applied_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Applied_Date__c.isUpdateable()){PAyApp.ERP7__Applied_Date__c = System.Today();}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isUpdateable()){PAyApp.Name = payment.Name;}else{/*No access*/}
                if(!payment.ERP7__Refund__c)
                PaymentApplied2update.add(PAyApp);
            }
        }
     //&& Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Applied_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Applied_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Amount__c.isUpdateable()
     
     if (PaymentApplied2update.size() > 0 && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isUpdateable()){ upsert PaymentApplied2update; }else{ /*('not allowed to upsert PAyApp');*/ /*'User is not allowed to update ERP7__Payment_Applied_on_Invoice__c fields'*/ }
     
    
}
 
 /*public static void upsertPaymentsAppliedonBill(Set<Id> paymentsIds){
    Map < Id, Id > existingPaymentsAppliedonInvoice_MAP = new Map < Id, Id > ();
    for (ERP7__Payment_Applied_on_Bill__c PAyApplied: [SELECT id, Payment__c FROM ERP7__Payment_Applied_on_Bill__c WHERE Payment__c in : paymentsIds and Payment__r.ERP7__Status__c = 'Paid' and Payment__r.ERP7__Bill__c != null]) existingPaymentsAppliedonInvoice_MAP.put(PAyApplied.id, PAyApplied.Payment__c);
   
     List < ERP7__Payment_Applied_on_Bill__c > PaymentApplied2update = new List < ERP7__Payment_Applied_on_Bill__c > ();
        for (Integer i = 0; i < System.Trigger.New.size(); i++) {
            Payment__c payment = (ERP7__Payment__c)System.Trigger.New[i];
            ERP7__Payment_Applied_on_Bill__c PAyApp = new ERP7__Payment_Applied_on_Bill__c(id = (existingPaymentsAppliedonInvoice_MAP.get(payment.id) != null) ? existingPaymentsAppliedonInvoice_MAP.get(payment.id) : null);
            if (trigger.isUpdate && payment.Status__c == Trigger.old[i].get('ERP7__Status__c') && payment.Status__c == 'Paid' && PAyApp.id == null) break;
            if (payment.Status__c == 'Paid' && payment.ERP7__Bill__c != null) {
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Amount__c.isUpdateable()){PAyApp.Amount__c = payment.Amount__c;}else{}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Bill__c.isCreateable()){PAyApp.ERP7__Bill__c = payment.ERP7__Bill__c;}else{}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Payment__c.isCreateable()){PAyApp.ERP7__Payment__c = payment.Id;}else{}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Type__c.isUpdateable()){PAyApp.ERP7__Type__c = payment.ERP7__Type__c;}else{}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Applied_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Applied_Date__c.isUpdateable()){PAyApp.ERP7__Applied_Date__c = System.Today();}else{}
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Name.isUpdateable()){PAyApp.Name = payment.Name;}else{}
               
                PaymentApplied2update.add(PAyApp);
            }
        }
     //&& Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Applied_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Applied_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Payment__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Bill__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.ERP7__Bill__c.isUpdateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Bill__c.fields.Amount__c.isUpdateable(
        if (PaymentApplied2update.size() > 0 && Schema.SObjectType.ERP7__Payment_Applied_on_Bill__c.isCreateable() && Schema.SObjectType.ERP7__Payment_Applied_on_Bill__c.isUpdateable()){ upsert PaymentApplied2update; }  else{ }
}*/

/*
    Rollup summary based on respective sObject value to ERP7__Total_Amount__c
    The Following rollup summary has limitation of 50000 records.
    if we are hitting Too many Soql rows returned:50001 (limit exception) add @future annoation to below method with Higher limits parameter.
    
*/
//public static void paymentRollUpSummary(List<ERP7__Payment__c> paymentNewList1,List<ERP7__Payment__c> paymentOldList1){
public static void paymentRollUpSummary(String paymentNewList1,String paymentOldList1){
    System.debug('paymentRollUpSummary');
    List<ERP7__Payment__c> paymentNewList = (List<ERP7__Payment__c>)JSON.deserialize(paymentNewList1, List<ERP7__Payment__c>.class);
    List<ERP7__Payment__c> paymentOldList = (List<ERP7__Payment__c>)JSON.deserialize(paymentOldList1, List<ERP7__Payment__c>.class);
    Set<Id> accountIds = new Set<Id>();
    Set<Id> soIds = new Set<Id>();
    MAP<Id, Account> AccountMap = new  MAP<Id, Account>();
    MAP<Id, ERP7__Invoice__c> InvoiceMap = new  MAP<Id, ERP7__Invoice__c>();
    MAP<Id, ERP7__Bill__c> BillMap = new  MAP<Id, ERP7__Bill__c>();
    MAP<Id, ERP7__PO__c> POMap = new  MAP<Id, ERP7__PO__c>();
    
    if(paymentNewList != null)
    for(ERP7__Payment__c pay:paymentNewList){
        if(pay.ERP7__Accounts__c != null) accountIds.add(pay.ERP7__Accounts__c);
        if(pay.ERP7__Sales_Order__c != null) soIds.add(pay.ERP7__Sales_Order__c);  else if(pay.ERP7__Order__c != null) soIds.add(pay.ERP7__Order__c);
    }
    
    if(paymentOldList != null)     for(ERP7__Payment__c pay:paymentOldList){        if(pay.ERP7__Accounts__c != null) accountIds.add(pay.ERP7__Accounts__c);        if(pay.ERP7__Sales_Order__c != null) soIds.add(pay.ERP7__Sales_Order__c);  else if(pay.ERP7__Order__c != null) soIds.add(pay.ERP7__Order__c);    }
    
    
    //if(AccountMap.values().size() > 0 && Schema.sObjectType.Account.fields.ERP7__Debit_Balance__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Credit_Balance__c.isUpdateable() && Schema.SObjectType.Account.isUpdateable()){ update AccountMap.values();}else{ /*('not aloowed to upsert Account');*/ /*'User is not allowed to update Account ERP7__Debit_Balance__c field'*/ }
    if(BillMap.values().size() > 0 && Schema.SObjectType.ERP7__Bill__c.isUpdateable()){ update BillMap.values(); }else{/*No access*/}
    
    if(soIds.size() > 0){
        List<ERP7__Payment__c> SOPayments2Rollup = [SELECT Id, ERP7__Status__c,ERP7__Bill__c, ERP7__Type__c, Pre_Payment__c, 
                                                       ERP7__Total_Amount__c, ERP7__Refund__c, ERP7__Refund_Amount__c, ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Posted__c, ERP7__Accounts__c 
                                                       FROM ERP7__Payment__c 
                                                       WHERE ERP7__Status__c = 'Paid' AND 
                                                       ERP7__Type__c = 'Debit' AND
                                                       ERP7__Total_Amount__c != Null AND
                                                       (ERP7__Sales_Order__c IN: soIds OR ERP7__Order__c IN: soIds)];
        
        List<ERP7__Sales_Order__c> SalesOrder2Update = [Select Id, Name, ERP7__Amount_Paid__c, ERP7__Refund_Amount__c From ERP7__Sales_Order__c Where Id In : soIds]; 
        List<Order> Order2Update = [Select Id, Name, ERP7__Amount_Paid__c From Order Where Id In : soIds]; 
        
        if(SalesOrder2Update.size() > 0){
            Map<Id, List<ERP7__Payment__c>> SoPayments = new Map<Id, List<ERP7__Payment__c>>(); 
            for(ERP7__Sales_Order__c SO : SalesOrder2Update) SoPayments.put(SO.Id,new List<ERP7__Payment__c>());
            for(ERP7__Payment__c Payment : SOPayments2Rollup){                if(SoPayments.containsKey(Payment.ERP7__Sales_Order__c)) SoPayments.get(Payment.ERP7__Sales_Order__c).add(Payment);                else SoPayments.put(Payment.ERP7__Sales_Order__c, new List<ERP7__Payment__c>{Payment});            }                    
            for(ERP7__Sales_Order__c SO : SalesOrder2Update){
                if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Amount_Paid__c.isUpdateable()){SO.ERP7__Amount_Paid__c = 0;}else{/*No access*/}
                for(ERP7__Payment__c Payment : SoPayments.get(SO.Id)){                    if(!Payment.ERP7__Refund__c) if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Amount_Paid__c.isUpdateable()){SO.ERP7__Amount_Paid__c += Payment.ERP7__Total_Amount__c;}else{/*No access*/}                    if(Payment.ERP7__Refund__c){                        if(SO.ERP7__Refund_Amount__c!=null) SO.ERP7__Refund_Amount__c = Payment.ERP7__Refund_Amount__c;                        else SO.ERP7__Refund_Amount__c = Payment.ERP7__Refund_Amount__c;                    }                } 
                
            } 
            if(SalesOrder2Update.size() > 0 && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()){ update SalesOrder2Update; }else{ /*('not allowed to update SalesOrder2Update');*/ /*'User is not allowed to Update Sales order ERP7__Amount_Paid__c field');*/}
        }
        if(Order2Update.size() > 0){            Map<Id, List<ERP7__Payment__c>> SoPayments = new Map<Id, List<ERP7__Payment__c>>();             for(Order SO : Order2Update) SoPayments.put(SO.Id,new List<ERP7__Payment__c>());            for(ERP7__Payment__c Payment : SOPayments2Rollup){                if(SoPayments.containsKey(Payment.ERP7__Order__c)) SoPayments.get(Payment.ERP7__Order__c).add(Payment);                else SoPayments.put(Payment.ERP7__Order__c, new List<ERP7__Payment__c>{Payment});            }                                for(Order SO : Order2Update){                if(Schema.sObjectType.Order.fields.ERP7__Amount_Paid__c.isUpdateable()){SO.ERP7__Amount_Paid__c = 0;}else{/*No access*/}                for(ERP7__Payment__c Payment : SoPayments.get(SO.Id)){                    if(Schema.sObjectType.Order.fields.ERP7__Amount_Paid__c.isUpdateable()){SO.ERP7__Amount_Paid__c += Payment.ERP7__Total_Amount__c;}else{/*No access*/}                }             }             if(Order2Update.size() > 0 && Schema.sObjectType.Order.isUpdateable()){ update Order2Update; }else{ /*('not allowed to update Order2Update');*/ /*'User is not allowed to Update Order ERP7__Amount_Paid__c field');*/}        }                                  
    }
}
}