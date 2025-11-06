public with sharing class SortLineItems {
    @AuraEnabled
    public static SoWrapper fetchOrderLines(String salesId, String invoiceId){
        SoWrapper SoAndLine = new SoWrapper();
        try{
            if(salesId != ''){
            	SoAndLine.SalesOrder = [Select Id, Name from ERP7__Sales_Order__c where Id =:salesId Limit 1];
            	SoAndLine.Solis = [Select Id, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Base_Price__c, ERP7__Total_Tax__c, ERP7__Total_Price__c, ERP7__Detailed_Description__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c =:salesId order by ERP7__Sort_Order__c];
            }
            
            if(invoiceId != ''){
                SoAndLine.Invoice = [Select Id, Name from ERP7__Invoice__c where Id =:invoiceId Limit 1];
            	SoAndLine.Invlis = [Select Id, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Base_Price__c, ERP7__Total_Tax__c, ERP7__Total_Price__c, ERP7__Detailed_Description__c from ERP7__Invoice_Line_Item__c where ERP7__Invoice__c =:invoiceId order by ERP7__Sort_Order__c];
            }
        }catch(Exception e){  SoAndLine.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }        
        return SoAndLine;
    }
    
    @AuraEnabled
    public static String updateSortOrder(String listOfSOLI, String salesId, String invoiceId){
        try{
            if(salesId != ''){
                List<ERP7__Sales_Order_Line_Item__c> listOfSoli1 = (List<ERP7__Sales_Order_Line_Item__c>) JSON.deserialize(listOfSOLI, List<ERP7__Sales_Order_Line_Item__c>.class);
                if(listOfSoli1.size() > 0){
                    List<ERP7__Sales_Order_Line_Item__c> listSOLI=new List<ERP7__Sales_Order_Line_Item__c>();
                    for(Integer i=0;i<listOfSoli1.size();i++){
                        listOfSoli1[i].ERP7__Sort_Order__c=i+1;
                        listSOLI.add(listOfSoli1[i]);
                    }
                    if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Sort_Order__c.isUpdateable()) { update listSOLI; } else{ /* no access*/ }
                }
            }
            if(invoiceId != ''){
                List<ERP7__Invoice_Line_Item__c> listOfSoli1 = (List<ERP7__Invoice_Line_Item__c>) JSON.deserialize(listOfSOLI, List<ERP7__Invoice_Line_Item__c>.class);
                if(listOfSoli1.size() > 0){
                    List<ERP7__Invoice_Line_Item__c> listSOLI=new List<ERP7__Invoice_Line_Item__c>();
                    for(Integer i=0;i<listOfSoli1.size();i++){
                        listOfSoli1[i].ERP7__Sort_Order__c=i+1;
                        listSOLI.add(listOfSoli1[i]);
                    }
                    if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isUpdateable()) { update listSOLI; } else{ /* No access */ }
                }
            }
            
        }catch(exception ex){ String exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();}
        return '';
    }
    
    public class SoWrapper{
        @AuraEnabled public String errorMsg                                 { get; set; }
        @AuraEnabled public ERP7__Sales_Order__c SalesOrder                 { get; set; }
        @AuraEnabled public List<ERP7__Sales_Order_Line_Item__c> Solis      { get; set; }
        @AuraEnabled public ERP7__Invoice__c Invoice                        { get; set; }
        @AuraEnabled public List<ERP7__Invoice_Line_Item__c> Invlis         { get; set; }
        
        public SoWrapper(){
            errorMsg = '';
            SalesOrder = new ERP7__Sales_Order__c();
            Solis = new List<ERP7__Sales_Order_Line_Item__c>();
            Invoice = new ERP7__Invoice__c();
            Invlis = new List<ERP7__Invoice_Line_Item__c>();
        }
    }
}