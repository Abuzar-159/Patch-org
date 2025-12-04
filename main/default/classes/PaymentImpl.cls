public with sharing class PaymentImpl implements ITrigger {
    public void bulkBefore(){} 
    public void bulkAfter(){} 
    public void beforeInsert(){
        ManagePayments.beforeUpsert_Operation(JSON.serialize(Trigger.New));
    } 
    public void afterInsert(){
        if(PreventRecursiveLedgerEntry.Payment){
            PreventRecursiveLedgerEntry.Payment = false;
            Map < string, Module__c > RunModule = new Map < string, Module__c > ();
            RunModule = Module__c.getAll();
            if (Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c)) 
                ManagePayments.upsertTransactionOnPaymentPost();
            ManagePayments.paymentRollUpSummary(JSON.serialize(Trigger.new),JSON.serialize(null));
            Boolean invoicePay = false;
            List<Id> invoiceIds = new List<Id>();
            List<ERP7__Payment__c> paymentNewList = (List<ERP7__Payment__c>)JSON.deserialize(JSON.serialize(Trigger.new), List<ERP7__Payment__c>.class);
            for(ERP7__Payment__c pay : paymentNewList){
                if(pay.ERP7__Invoice__c!=null){
                    invoiceIds.add(pay.ERP7__Invoice__c);
                }
            }
            if (!invoiceIds.isEmpty()) {
                Map<Id, ERP7__Invoice__c> invoiceMap = new Map<Id, ERP7__Invoice__c>([SELECT Id, ERP7__Order__c, ERP7__Order_S__c FROM ERP7__Invoice__c WHERE Id IN :invoiceIds]);
                for(ERP7__Payment__c pay : paymentNewList){
                    if(pay.ERP7__Invoice__c!=null && (invoiceMap.containsKey(pay.ERP7__Invoice__c) && (invoiceMap.get(pay.ERP7__Invoice__c).ERP7__Order__c != null || invoiceMap.get(pay.ERP7__Invoice__c).ERP7__Order_S__c != null))){
                        invoicePay = true;
                    }
                }
            }
            if(invoicePay){
                System.debug('Payment Applied called for invoice');
            	ManagePayments.upsertPaymentsAppliedonInvoice(Trigger.newMap.keyset());
            }
            //ManagePayments.upsertPaymentsAppliedonInvoice(Trigger.newMap.keyset());
           // ManagePayments.upsertPaymentsAppliedonBill(Trigger.newMap.keyset());
        }
    }
    public void beforeUpdate(){
         ManagePayments.beforeUpsert_Operation(JSON.serialize(Trigger.New));
    } 
    public void afterUpdate(){
        if(PreventRecursiveLedgerEntry.Payment){
            PreventRecursiveLedgerEntry.Payment = false;
            Map < string, Module__c > RunModule = new Map < string, Module__c > ();
            RunModule = Module__c.getAll();
            if (Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c)) 
                ManagePayments.upsertTransactionOnPaymentPost();
            ManagePayments.paymentRollUpSummary(JSON.serialize(Trigger.new),JSON.serialize(Trigger.Old));
            Boolean invoicePay = false;
            List<ERP7__Payment__c> paymentNewList = (List<ERP7__Payment__c>)JSON.deserialize(JSON.serialize(Trigger.new), List<ERP7__Payment__c>.class);
            for(ERP7__Payment__c pay : paymentNewList){
                if(pay.ERP7__Invoice__c!=null){
                    invoicePay = true;
                }
            }
            if(invoicePay){
            	ManagePayments.upsertPaymentsAppliedonInvoice(Trigger.newMap.keyset());
            }
            //ManagePayments.upsertPaymentsAppliedonInvoice(Trigger.newMap.keyset());
            //ManagePayments.upsertPaymentsAppliedonBill(Trigger.newMap.keyset());
        }
    }
    public void afterUnDelete(){
        if(PreventRecursiveLedgerEntry.Payment){
            PreventRecursiveLedgerEntry.Payment = false;
            Map < string, Module__c > RunModule = new Map < string, Module__c > ();
            RunModule = Module__c.getAll();
            if (Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c)) 
                ManagePayments.upsertTransactionOnPaymentPost();
            ManagePayments.paymentRollUpSummary(JSON.serialize(Trigger.new),JSON.serialize(null));
            ManagePayments.upsertPaymentsAppliedonInvoice(Trigger.newMap.keyset());
            //ManagePayments.upsertPaymentsAppliedonBill(Trigger.newMap.keyset());
        }
    }
    public void beforeDelete(){}
    public void AfterDelete(){
        if(PreventRecursiveLedgerEntry.Payment){
            PreventRecursiveLedgerEntry.Payment = false;
            ManagePayments.paymentRollUpSummary(JSON.serialize(null),JSON.serialize(Trigger.old));
        }
    }
    public void andFinally(){}
    
}