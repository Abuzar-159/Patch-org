public with sharing class PaypalPaymentNotification {
    /*private String TransactionId;
    private String soId;
    private String InvId;
    private Decimal paidAmt;
    
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    
    public PaypalPaymentNotification(){
        
    }
    public PageReference CreatePayment() {
        String transactionId = Apexpages.Currentpage().getparameters().get('tx') ;
        if(transactionId != null && transactionId.length()==17){
             TransactionId = Apexpages.Currentpage().getparameters().get('tx');
        if(Apexpages.Currentpage().getparameters().get('item_number') != null)  
            soId = Apexpages.Currentpage().getparameters().get('item_number');
        if(Apexpages.Currentpage().getparameters().get('item_name') != null)
             InvId = Apexpages.Currentpage().getparameters().get('item_name');             
         if(Apexpages.Currentpage().getparameters().get('amt') != null)
                paidAmt = Decimal.valueof(Apexpages.Currentpage().getparameters().get('amt'));
        }else{
           //throw exception for not to access the page
        }

        Id RTID; RTID = Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Card_Payments').getRecordTypeId();
                
        List<ERP7__Payment__c> paymentList = [Select Id, Name, ERP7__Invoice__c, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__Transaction_ID__c,
                                              ERP7__Payment_Gateway__c From ERP7__Payment__c where RecordTypeId=:rec.Id and ERP7__Transaction_ID__c=:transactionId];
                      
        List<ERP7__Invoice__c> invoice = [Select Name, ERP7__Order__c from ERP7__Invoice__c where ERP7__Order__c=:soId];                                
        if(paymentList.size()==0){
        ERP7__Payment__c Payment = new ERP7__Payment__c();
        Payment.Name = 'Test';
        Payment.ERP7__Sales_Order__c = soId;
        //Payment.ERP7__Invoice__c = invoice[0].Name;
        Payment.ERP7__Amount__c = paidAmt;
        Payment.ERP7__Transaction_ID__c = transactionId;
        Payment.ERP7__Status__c = 'Paid';
        Payment.ERP7__Payment_Gateway__c = 'PayPal';
        Payment.ERP7__Type__c = 'Debit';
        Payment.ERP7__Is_External_Payment__c = true;
        if(RTID != null) Payment.RecordTypeId = RTID;
        if(Payment != null)
        if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Is_External_Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Is_External_Payment__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_ID__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Name.isUpdateable()){hasAccess=true; upsert Payment;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
       } 
        return null;
    }*/

}