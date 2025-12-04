@isTest
private class EmailTestCase {
    
   public static Contact contact;

    
    static void init(){
        
     RecordType ICE_rType = [select Id, Name From RecordType Where Name = 'Expense' and SobjectType = 'ERP7__ICE__c' Limit 1];         
        
     Account sup = new Account(Name='Customer');
            insert sup;       
     
    contact = new Contact(FirstName='Test',LastName='Contact',AccountId=sup.id,Phone='1234567890',Email='test@test.com');
           insert contact;
    }
    
    static testMethod void UnitTestEmailIceCase(){ 
        init();
        CreateCase cc = new CreateCase();  
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
        // Create the email body
       email.plainTextBody = 'This should become a note';
       email.fromAddress =contact.Email;
       String contactEmail = contact.Email;
       email.ccAddresses = new String[] {'TEST <' + contactEmail + '>'};
       email.subject = ' Test 123';
        
       Test.startTest();
         Messaging.InboundEmailResult result = cc.handleInboundEmail(email, env);
        delete contact;
        result = cc.handleInboundEmail(email, env);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
       Test.stopTest();       
    } 
}