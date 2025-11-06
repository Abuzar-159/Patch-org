trigger ValidateVendorPartNumber on ERP7__Cost_Card__c (before insert, before update) {
    
    List<ERP7__Cost_Card__c> existingCostCards = new List<ERP7__Cost_Card__c>();
    existingCostCards = [Select Id,Name,ERP7__Vendor_Part_Number__c from ERP7__Cost_Card__c where ERP7__Vendor_Part_Number__c !=null limit 500];
    
    if(Trigger.isInsert && Trigger.isBefore){
        
        for (ERP7__Cost_Card__c NewCost : Trigger.new) {
            for(ERP7__Cost_Card__c ExtCost :existingCostCards){
                if (NewCost.ERP7__Vendor_Part_Number__c != null && NewCost.ERP7__Vendor_Part_Number__c == ExtCost.ERP7__Vendor_Part_Number__c) {
                     NewCost.addError('A record with this Vendor Part Number already exists.');
                }
            }
        }  
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        
        Map<Id,ERP7__Cost_Card__c> OldcostcardMap = Trigger.oldMap;
        for (ERP7__Cost_Card__c NewCost : Trigger.new) {
            if(OldcostcardMap.get(NewCost.Id).ERP7__Vendor_Part_Number__c != NewCost.ERP7__Vendor_Part_Number__c){
                for(ERP7__Cost_Card__c ExtCost :existingCostCards){
                    if (NewCost.ERP7__Vendor_Part_Number__c != null && NewCost.ERP7__Vendor_Part_Number__c == ExtCost.ERP7__Vendor_Part_Number__c) 
                    { NewCost.addError('A record with this Vendor Part Number already exists.'); }
                }
            }
        } 
    } 
}