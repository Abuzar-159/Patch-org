trigger Tax_Rules_Processing on Employee_Tax_Rule__c (after update) {  
    List<Id> etrIds = new List<Id>();
    for(Employee_Tax_Rule__c ETR : System.Trigger.New){
       etrIds.add(ETR.Id);
    } 
    List<CTC_Tax__c> Taxes = [Select Id, Name, CTC_Component__c, Employee_Tax_Rule__c From CTC_Tax__c Where Employee_Tax_Rule__c in : etrIds];  
    try { 
        if(Taxes.size() > 0 && Schema.sObjectType.CTC_Tax__c.isUpdateable()){ update Taxes; } else{ /* no access */ } } catch(Exception e){ 
    }
}