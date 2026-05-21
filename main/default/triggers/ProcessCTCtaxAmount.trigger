trigger ProcessCTCtaxAmount  on CTC_Tax__c (before insert, before update) {
    List<Id> empTaxRuleIds = new list<Id>();
    Map<Id,List<Tax_Range__c>> ruleRanges = new Map<Id,List<Tax_Range__c>>();
    
    for(CTC_Tax__c CTCC : System.Trigger.New){
        empTaxRuleIds.add(CTCC.Employee_Tax_Rule__c);
    }
    List<Tax_Range__c> taxRanges = [Select Id, Name, Active__c, Employee_Tax_Rule__c, Lower_Limit__c, Percent__c, Upper_Limit__c,
                                       Employee_Tax_Rule__r.Active__c, Employee_Tax_Rule__r.Start_Date__c, Employee_Tax_Rule__r.End_Date__c
                                       From Tax_Range__c 
                                       Where Active__c = true And
                                       Employee_Tax_Rule__c in : empTaxRuleIds And
                                       Employee_Tax_Rule__r.Active__c = true And
                                       Employee_Tax_Rule__r.Start_Date__c <= :system.today() And
                                       Employee_Tax_Rule__r.End_Date__c >= :system.today()];
                                       
   for(CTC_Tax__c CTCC : System.Trigger.New){
        List<Tax_Range__c> myTaxRanges = new List<Tax_Range__c>();
        for(Tax_Range__c TR : taxRanges){
           if(CTCC.Employee_Tax_Rule__c == TR.Employee_Tax_Rule__c){
               myTaxRanges.add(TR);
           }            
        }
        ruleRanges.put(CTCC.Employee_Tax_Rule__c, myTaxRanges);
    }
    for(CTC_Tax__c CTCC : System.Trigger.New){     
        List<Tax_Range__c> currentTaxRanges = ruleRanges.get(CTCC.Employee_Tax_Rule__c);
        Decimal currentPercent = 0;
        Boolean available = false;
        if(currentTaxRanges.size() > 0){            
            for(Tax_Range__c CTR : currentTaxRanges){
                if(!available){
                    if(CTCC.Amount__c >= CTR.Lower_Limit__c && CTCC.Amount__c <= CTR.Upper_Limit__c){
                        currentPercent = CTR.Percent__c;  
                        available = true;
                    }
                }
            }                
        }        
        if(available){ 
            CTCC.Tax_Amount__c = (currentPercent * CTCC.Amount__c)/100; 
        }   
        else {
            CTCC.Tax_Amount__c = 0;
        }  
    }
}