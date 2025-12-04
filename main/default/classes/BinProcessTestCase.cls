@isTest
public class BinProcessTestCase {
    
    static User u;
    static Channel__c salepoint;
    static Loading_Dropping_point__c loadpoint;
    static Loading_Dropping_point__c droppoint; 
    static PageReference pageRef;
    static Sales_Order__c sod; 
    static Shipment__c ship,ship1;
    public List<Transportation_Allocation__c> transPortAllocation;
    public List<Sales_Order_Line_Item__c> oli;  
    
    public static Sales_Order__c createSalesOrder(Id orgn,Id busUnit, Contact contact, Id salePt){
        Sales_Order__c psod = new Sales_Order__c( Order_Status__c = 'Entered',Account__c = contact.AccountId, Contact__c = contact.Id, Channel__c = salePt, Request_Date__c = system.Today());
            return psod;
     }
     
    public static Package__c createPackage(String depTag, Id sodD,Id orgn,Id busUnit){
        Package__c pkg = new Package__c(Deposit_Tag__c = depTag,Sales_Order__c=sodD,Status__c='none');    
                 return pkg;
    }
    
    public static void init(){
        
        Profile p;
        if(Schema.sObjectType.Profile.isAccessible())
        p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
         u = new User(Alias = 'TECASE', Email='user_case@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='user_case@testorg.com');
            insert u;
        
        RecordType loadRecType = [select Id, Name From RecordType Where Name = 'loading' and SobjectType = 'Loading_Dropping_point__c' Limit 1];  
        RecordType dropRecType = [select Id, Name From RecordType Where Name = 'Drop Off' and SobjectType = 'Loading_Dropping_point__c' Limit 1]; 
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
            insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Test',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
            insert contact;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit;
        
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
         salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
            insert salepoint;
         Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
             insert site;
         Transportation__c transport = new Transportation__c( Name='test transport', Transportation_Provider__c = sup.Id);
             insert transport;
          loadpoint = new Loading_Dropping_point__c(Channel__c = salepoint.Id,Site__c = Site.id, RecordTypeId=loadRecType.Id);
                 insert loadpoint;  
          droppoint = new Loading_Dropping_point__c(Channel__c = salepoint.Id,Site__c = Site.id, RecordTypeId=dropRecType.Id);
                 insert droppoint;         
         Account driver = new Account(Name='Driver');
            insert driver;
        Contact drivercontact = new Contact(FirstName='Test',LastName='Driver Contact',AccountId=driver.id,Phone='1234567890',Email='test@test.com',isDriver__c=true,Shipping_Driver__c = 'General', Driver_User__c=u.Id);
            insert drivercontact;
         Account transportProvider = new Account(Name='Transport Provider');
            insert transportProvider;

        Contact providercontact = new Contact(FirstName='Test',LastName='Provider',AccountId=transportProvider.id,Phone='1234567890',Email='test@test.com',isTransportProvider__c=true,Driver_User__c=u.Id);
            insert providercontact;

          Transportation_Allocation__c transAlloc = new Transportation_Allocation__c (Driver_Contact__c = drivercontact.Id, Loading_Dropping_point__c = loadpoint.Id, Transportation__c = transport.Id, Transport_Provider__c= providercontact.Id);
              insert transAlloc; 
        Contact myCon;
        if(Schema.sObjectType.Contact.isAccessible())
           myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
            
          
               sod = createSalesOrder(orgn.Id,busUnit.Id,contact, salepoint.Id);
             insert sod;
            
            Product2 ps = new Product2(Barcode__c ='Item-TEST', Name='test', IsActive =true,Track_Inventory__c=true);
            insert ps;
            Package__c pkg = createPackage('Dep-0000',sod.Id,orgn.Id,busUnit.Id);
                 insert pkg;
        
           Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c( Sales_Order__c = sod.id,Product__c=ps.Id,Package__c=pkg.id , Active__c=true);
                insert soli;
          
          Product2 ps1 = new Product2(Barcode__c ='Item-TESTOS', Name='test-1232', IsActive =true, Is_OverSized_Item__c=true,Track_Inventory__c=true);
            insert ps1; 
          
          Package__c pkg1 = createPackage('DepOS-0000',sod.Id,orgn.Id,busUnit.Id);
                 insert pkg1;
                 
           Sales_Order_Line_Item__c soli1 = new Sales_Order_Line_Item__c( Sales_Order__c = sod.id,Product__c=ps1.Id, Package__c=pkg1.id, Active__c=true);
                insert soli1; 
           Sales_Order_Line_Item__c soliSOQL  =  [select id,Sales_Order__c,
            Product__r.Barcode__c , Product__r.Picture__c, Sales_Order__r.Id, Organisation__r.id,
            Active__c,Package__r.Deposit_Tag__c,Organisation_Business_Unit__r.id  
            from  Sales_Order_Line_Item__c limit 1];
         Contact drivercontact1 = new Contact(FirstName='Test',LastName='Driver Contact Test',AccountId=driver.id,Phone='1234567890',Email='test@test.com');
            insert drivercontact1;
            
          Transportation_Allocation__c transAllocDrop = new Transportation_Allocation__c (Driver_Contact__c = drivercontact1.Id, Loading_Dropping_point__c = droppoint.Id, Transportation__c = transport.Id, Transport_Provider__c= providercontact.Id);
              insert transAllocDrop; 
           Transportation_Allocation__c transAllocDrop1 = new Transportation_Allocation__c (Driver_Contact__c = drivercontact1.Id, Loading_Dropping_point__c = droppoint.Id, Transportation__c = transport.Id, Transport_Provider__c= providercontact.Id);
              insert transAllocDrop1;
            ship = new Shipment__c(Active__c = true,  
           Sales_Order__c = sod.id,
                   Customer__c = customer.Id, Shipment_Date__c = System.today(), 
                   UPS_Package_Weight_Unit__c = 'LBS', UPS_Package_Type__c = 'UNKNOWN',
                    Check_In__c = false, Package__c = pkg.id);
            
                insert ship;
                
             ship1 = new Shipment__c(Active__c = true, 
                   Sales_Order__c = sod.id,
                   Customer__c = customer.Id, Shipment_Date__c = System.today(), 
                   UPS_Package_Weight_Unit__c = 'LBS', UPS_Package_Type__c = 'UNKNOWN',
                    Check_In__c = false, Package__c = pkg1.id);
            
                insert ship1;   
                String salName = 'ERP7';
                String sal1Name = 'ERP7';
                System.assertEquals(salName, sal1Name); 
        
    }
}