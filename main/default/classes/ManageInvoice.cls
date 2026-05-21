public with sharing class ManageInvoice {
    @AuraEnabled 
    public static ERP7__Invoice__c fetchRecord(String InvId){ 
        //System.debug([SELECT Id, Name FROM ERP7__Invoice__c WHERE Id=:InvId]);
        ERP7__Invoice__c e=[Select Id, Name , ERP7__Paid_Amount_Applied__c, ERP7__Tax_Amount__c,ERP7__Invoice_Amount__c, ERP7__Total_Due__c, ERP7__Amount_Paid__c,ERP7__Record_Type_Name__c, ERP7__Order_S__c, ERP7__Order_S__r.Name, ERP7__Order__c,ERP7__Down_Payment__c,ERP7__Total_Down_Payment_Amount__c, ERP7__Account__c, ERP7__Contact__c, ERP7__Sales_Order_Amount__c,ERP7__Sales_Invoice_Percentage__c,ERP7__Sales_Invoice_Tax_Percentage__c,ERP7__Sub_Total_Amount__c,ERP7__Organisation__c, ERP7__Total_Discount__c,ERP7__Discount__c,ERP7__Discount_Amount__c, ERP7__Invoice_Date__c, ERP7__Invoice_Due_Date__c, ERP7__Payment_Terms__c from ERP7__Invoice__c where Id =:InvId];   
        return e;												    
    }
    @AuraEnabled
    public static List<String> getPayTerms(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Invoice__c.ERP7__Payment_Terms__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled 
    public static List<String> getFieldsSetApiName(String sObjectName,String fieldSetApiName){
        return ERP7.UtilClass.getFieldsSetApiName(sObjectName, fieldSetApiName);
    } 
    
    @AuraEnabled 
    public static List<ERP7__Invoice_Line_Item__c> getInvoiceLineItems(String InvoiceId){
        //System.debug([SELECT Id, Name FROM ERP7__Invoice_Line_Item__c WHERE ERP7__Invoice__c=:SOId]);
        return [SELECT Id, Name, ERP7__Sales_Order_Line_Item__c, ERP7__Product__r.Name, ERP7__Quantity__c,ERP7__Order_Product__c,
                ERP7__Unit_Price__c, ERP7__Sub_Total__c, ERP7__Tax_Rate__c, ERP7__Discount_Amount__c,ERP7__VAT_Amount__c,
                ERP7__Total_Price__c, ERP7__Description__c, ERP7__Total_Tax__c,ERP7__Order_Product__r.OrderItemNumber,ERP7__Sales_Order_Line_Item__r.Name FROM ERP7__Invoice_Line_Item__c WHERE ERP7__Invoice__c=:InvoiceId];       
    }
    
    @AuraEnabled
    public static void updateRecords(List<ERP7__Invoice_Line_Item__c> recs, ERP7__Invoice__c rec,List<Id> DeleteItems) {
        update recs;
        update rec;
        List<ERP7__Invoice_Line_Item__c> lItemsToDelete = new List<ERP7__Invoice_Line_Item__c>();
        for(Id ids : DeleteItems){
            ERP7__Invoice_Line_Item__c e =[Select Id FROM ERP7__Invoice_Line_Item__c where Id=:ids];
            lItemsToDelete.add(e);
        }
        delete lItemsToDelete;   
    }
    
    @AuraEnabled
    public static void delItem(List<ERP7__Invoice_Line_Item__c> lItem) {
        delete lItem;
    }   
    
    @AuraEnabled
    public static List<ERP7__Invoice__c> getInvoicesofOrder(String OrdId, String InvId) {
        
        List<ERP7__Invoice__c> ordInvoice= [Select Id,ERP7__Paid_Amount_Applied__c,ERP7__Order_S__c from ERP7__Invoice__c Where ERP7__Order_S__c =: OrdId And Id!=: InvId];
        //System.debug('--->'+ ordInvoice);
        for(ERP7__Invoice__c e : ordInvoice){
            
            // System.debug('--->'+ e.Id +' and '+ e.ERP7__Order_S__c);
        }
        return ordInvoice;
    }
    
    @AuraEnabled
    public static List<ERP7__Invoice__c> getInvoicesofSales(String OrdId, String InvId) {
        
        List<ERP7__Invoice__c> ordInvoice= [Select Id,ERP7__Paid_Amount_Applied__c,ERP7__Order__c from ERP7__Invoice__c Where ERP7__Order__c =: OrdId And Id!=: InvId];
        //System.debug('--->'+ ordInvoice);
        for(ERP7__Invoice__c e : ordInvoice){
            
            //System.debug('--->'+ e.Id +' and '+ e.ERP7__Order_S__c);
        }
        return ordInvoice;
    }
    
}