trigger ProcessTaxAmount on CTC_Component__c (after update) {    
   List<Id> Ids = new list<Id>();        
   for(CTC_Component__c CTCC : System.Trigger.New){
       Ids.add(CTCC.Id);
   }
   List<CTC_Tax__c> ctcTaxes = [Select Id, Name, CTC_Component__c From CTC_Tax__c Where CTC_Component__c in : Ids];   
    if(Schema.sObjectType.CTC_Tax__c.isUpdateable()) { update ctcTaxes; }  else{ /* no access */ }
}