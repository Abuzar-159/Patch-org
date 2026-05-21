public with sharing class CreateCase implements Messaging.InboundEmailHandler {
 
  public Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
         
      
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();     
        String myPlainText= '';       
        String emailId = '';
        
        myPlainText = email.plainTextBody; 
        emailId = email.fromAddress;  
        ICE__c []newICE  = new ICE__c[0];
                
        try {    
            ICE__c newICERecord;
            Contact Con;
            if(Schema.sObjectType.Contact.isAccessible())
            Con = [SELECT Id, Name, Email,AccountId FROM Contact WHERE  Email =: emailId  LIMIT 1];
        if(con != null){
            newICERecord = new ICE__c (Description__C =  myPlainText, Priority__C = 'Medium',
            Status_Duration__c = 'Inbound Email', Subject__c = email.subject, Contact__c =  Con.Id,Account__c = Con.AccountId);    
         }else{ newICERecord = new ICE__c (Description__C =  myPlainText, Priority__C = 'Medium', Status_Duration__c = 'Inbound Email', Subject__c = email.subject);    
         }
            if(Schema.sObjectType.ICE__c.isCreateable()){ DMLManager.insertAsUser(newICERecord); }else{ }         
       } catch (QueryException e) {
           
        }
        
        result.success = true;
        
        return null;
        
    }
        
}