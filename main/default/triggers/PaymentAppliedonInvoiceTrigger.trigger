/*
    Created by - Syed Moin Pasha
    Date - 03rd November 2021
    Reason - Trigger is used to update the Amount Paid on the Sales Order for the payment against multiple invoices
*/
trigger PaymentAppliedonInvoiceTrigger on ERP7__Payment_Applied_on_Invoice__c (after insert, after update) {
    if(ERP7.PreventRecursiveLedgerEntry.preventPaymentAppliedOnInvoice){
        Set<Id> Pids = new Set<Id>();
        Set<Id> invids = new Set<Id>();
        Set<Id> soids = new Set<Id>();
        List<ERP7__Invoice__c> invoiceList = new List<ERP7__Invoice__c>();
        List<ERP7__Sales_Order__c> so2Upsert = new List<ERP7__Sales_Order__c>();
        Map<Id, ERP7__Payment__c> payMap = new Map<Id, ERP7__Payment__c>();
        Map<Id, ERP7__Sales_Order__c> invOrderMap = new Map<Id, ERP7__Sales_Order__c>();
        Map<Id, ERP7__Sales_Order__c> soMap = new Map<Id, ERP7__Sales_Order__c>();
        for(ERP7__Payment_Applied_on_Invoice__c poi : Trigger.new){
            if(poi.ERP7__Payment__c!=null){
                Pids.add(poi.ERP7__Payment__c);
            }
        }
        //fetch payments without Sales Order
        if(Pids.size()>0){
            payMap = new Map<Id, ERP7__Payment__c>([select Id, ERP7__Sales_Order__c, ERP7__Invoice__c from ERP7__Payment__c where Id IN :Pids and ERP7__Sales_Order__c=null]);
        }
        
        if(payMap.size()>0){
            for(ERP7__Payment_Applied_on_Invoice__c poi : Trigger.new){
                if(payMap.containsKey(poi.ERP7__Payment__c)){
                    if(poi.ERP7__Invoice__c!=null) invids.add(poi.ERP7__Invoice__c);
                }
            }
            if(invids.size()>0){
                invoiceList = [select Id, Name, ERP7__Order__c from ERP7__Invoice__c where Id IN :invids];
                for(ERP7__Invoice__c inv : invoiceList){
                    if(inv.ERP7__Order__c != null) soids.add(inv.ERP7__Order__c);
                }
                if(soids.size()>0){
                    soMap = new Map<Id, ERP7__Sales_Order__c>([select Id, Name, ERP7__Amount_Paid__c from ERP7__Sales_Order__c where Id IN :soids]);
                    for(ERP7__Invoice__c inv : invoiceList){
                        if(soMap.containsKey(inv.ERP7__Order__c)){
                            invOrderMap.put(inv.Id, soMap.get(inv.ERP7__Order__c));
                        }
                    }
                    for(ERP7__Payment_Applied_on_Invoice__c poi : Trigger.new){
                        if(invOrderMap.containsKey(poi.ERP7__Invoice__c)){
                            if(Trigger.isInsert){
                                ERP7__Sales_Order__c so = invOrderMap.get(poi.ERP7__Invoice__c);
                                if(so.ERP7__Amount_Paid__c == null) so.ERP7__Amount_Paid__c = poi.ERP7__Amount__c;
                                else so.ERP7__Amount_Paid__c = so.ERP7__Amount_Paid__c + poi.ERP7__Amount__c;
                                so2Upsert.add(so);
                            }
                            if(Trigger.isUpdate){
                                ERP7__Payment_Applied_on_Invoice__c paoI = Trigger.oldMap.get(poi.Id);
                                if(paoI.ERP7__Amount__c != poi.ERP7__Amount__c){
                                    ERP7__Sales_Order__c so = invOrderMap.get(poi.ERP7__Invoice__c);
                                    if(so.ERP7__Amount_Paid__c == null) so.ERP7__Amount_Paid__c = poi.ERP7__Amount__c;
                                    else so.ERP7__Amount_Paid__c = so.ERP7__Amount_Paid__c - paoI.ERP7__Amount__c + poi.ERP7__Amount__c;
                                    so2Upsert.add(so);
                                }
                            }
                        }
                    }
                }
            }
        }
        if(so2Upsert.size()>0){
            ERP7.PreventRecursiveLedgerEntry.preventPaymentAppliedOnInvoice = false;
            update so2Upsert;
        }
    }
}