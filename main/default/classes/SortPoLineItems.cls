public with sharing class SortPoLineItems {
    @AuraEnabled
    public static PoWrapper fetchOrderLines(String purchaseId){
        PoWrapper PoAndLine = new PoWrapper();
        try{
            if(purchaseId != ''){
                PoAndLine.PurchaseOrder = [Select Id, Name from ERP7__PO__c where Id =:purchaseId Limit 1];
                PoAndLine.Polis = [Select Id, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Unit_Price__c, ERP7__Total_Price__c, ERP7__Description__c,ERP7__Sort_Order__c from ERP7__Purchase_Line_Items__c where ERP7__Purchase_Orders__c =:purchaseId order by ERP7__Sort_Order__c];
            }
        }catch(Exception e){  PoAndLine.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }        
        return PoAndLine;
    }
    
    @AuraEnabled
    public static String updateSortOrder(String listOfPOLI, String purchaseId){
        try{
            if(purchaseId != ''){
                List<ERP7__Purchase_Line_Items__c> listOfPoli1 = (List<ERP7__Purchase_Line_Items__c>) JSON.deserialize(listOfPOLI, List<ERP7__Purchase_Line_Items__c>.class);
                if(listOfPoli1.size() > 0){                        
                    List<ERP7__Purchase_Line_Items__c> listPOLI=new List<ERP7__Purchase_Line_Items__c>();
                    for(Integer i=0;i<listOfPoli1.size();i++){
                        listOfPoli1[i].Sort_Order__c=i+1;
                        listPOLI.add(listOfPoli1[i]);
                    }
                    if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Sort_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Purchase_Line_Items__c.isUpdateable()) { update listPOLI; } else{ /*no access*/ }
                    
                }
            }
        }catch(exception ex){ String exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();  }
        return '';
    }
    
    public class PoWrapper{
        @AuraEnabled public String errorMsg                             { get; set; }
        @AuraEnabled public ERP7__PO__c PurchaseOrder                   { get; set; }
        @AuraEnabled public List<ERP7__Purchase_Line_Items__c> Polis    { get; set; }
        
        public PoWrapper(){
            errorMsg = '';
            PurchaseOrder = new ERP7__PO__c();
            Polis = new List<ERP7__Purchase_Line_Items__c>();
        }
    }
}