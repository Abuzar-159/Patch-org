trigger PreventMultipleActiveLoyaltyCards on Loyalty_Card__c (before insert, before update, after undelete) {
    Set<Id> accIds = new Set<Id>();
    Map<Id,List<Loyalty_Card__c>> customer_Cards = new Map<Id,List<Loyalty_Card__c>>();
    Date myDate = system.Today();
    for(Loyalty_Card__c LC : System.Trigger.new){
        accIds.add(LC.Customer__c);
    }
    
    List<Loyalty_Card__c> loyaltyCards = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c, Expiration_Date__c,  Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                                             Organisation__c, Organisation_Business_Unit__c
                                             From Loyalty_Card__c Where 
                                             Customer__c In: accIds And                                            
                                             Status__c = 'Active' And
                                             Active__c = true And
                                             Start_date__c <= :myDate And
                                             Expiration_Date__c >= :myDate Limit 1];
    for(Id accId : accIds){
        List<Loyalty_Card__c> myCards = new List<Loyalty_Card__c>();
        for(Loyalty_Card__c LC : loyaltyCards){
            if(accId == LC.Customer__c){
                myCards.add(LC);
            }
        }
        customer_Cards.put(accId,myCards);
    }
    
    for(Loyalty_Card__c LC : System.Trigger.new){
        List<Loyalty_Card__c> activeCards = customer_Cards.get(LC.Customer__c);
        
        if(activeCards.size() > 0 && (Trigger.IsInsert || Trigger.IsUndelete) && (LC.Status__c == 'Active' && LC.Active__c == true && LC.Start_date__c <= myDate && LC.Expiration_Date__c >= myDate)){
            LC.addError('Active Loyalty Card already exist for this account');
        }
        else if(Trigger.IsUpdate && (LC.Status__c == 'Active' && LC.Active__c == true && LC.Start_date__c <= myDate && LC.Expiration_Date__c >= myDate)){
            for(Loyalty_Card__c LCO : System.Trigger.old){
                if(LC.Id == LCO.Id && (LCO.Status__c == 'Active' && LCO.Active__c == true && LCO.Start_date__c <= myDate && LCO.Expiration_Date__c >= myDate) && activeCards.size() > 1){
                    LC.addError('Active Loyalty Card already exist for this account');
                }
                else if(LC.Id == LCO.Id && !(LCO.Status__c == 'Active' && LCO.Active__c == true && LCO.Start_date__c <= myDate && LCO.Expiration_Date__c >= myDate) && activeCards.size() > 0){
                    LC.addError('Active Loyalty Card already exist for this account');
                }
            }
        }
    }
}