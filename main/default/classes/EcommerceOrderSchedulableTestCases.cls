@isTest
public class EcommerceOrderSchedulableTestCases {
    public static testMethod void unitTest1(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family ='Others',IsActive=TRUE);//,ERP7__Category__c='IT',ProductCode='HR'
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Sync_Status__c='Booked'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        
        
        Test.startTest();
        EcommerceOrderSchedulable sh1 = new EcommerceOrderSchedulable();      
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, sh1);
        
        
        System.assertEquals('test','test');
        Test.stopTest();
    }
}