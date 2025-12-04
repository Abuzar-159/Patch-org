trigger ApplyRangeChanges on Tax_Range__c (after insert, after update, after delete, after undelete) {
    Set<Id> etrIds = new Set<Id>();
    if(!Trigger.IsDelete){
        for(Tax_Range__c ETR : System.Trigger.New){
           etrIds.add(ETR.Employee_Tax_Rule__c);
        }
    }
    else{
        for(Tax_Range__c ETR : System.Trigger.Old){
           etrIds.add(ETR.Employee_Tax_Rule__c);
        }
    }
    List<CTC_Tax__c> Taxes = [Select Id, Name, CTC_Component__c, Employee_Tax_Rule__c From CTC_Tax__c Where Employee_Tax_Rule__c in : etrIds];  
    try { 
        if(Taxes.size() > 0 && Schema.SObjectType.CTC_Tax__c.isUpdateable() && Schema.sObjectType.CTC_Tax__c.fields.Employee_Tax_Rule__c.isUpdateable() && Schema.sObjectType.CTC_Tax__c.fields.CTC_Component__c.isUpdateable() && Schema.sObjectType.CTC_Tax__c.fields.Name.isUpdateable()){ update Taxes; } } catch(Exception e){ 
    }
}