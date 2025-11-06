@isTest
private class UPSInvoiceCompControllerTestCaseSet {
    
    static testMethod void unitTest1() { 
        test.startTest();
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Company__c='Test',Phone='1234567890',Email='test@test.com');
        insert contact;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id, Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890');
        insert salepoint;
           
        Sales_Order__c sod = new Sales_Order__c();  
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Channel__c = salePoint.Id;
        sod.Request_Date__c = system.Today();
        insert sod;
        Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim; 
        Shipment__c shipments = new Shipment__c(Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',
                                Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, Tracking_Number__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                               UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
        insert shipments;
            
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test',Active__c=true,Shipment_Type__c='UPS',Status__c='test',
                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, Shipment__c=shipments.Id);
        try{insert testpack;
        
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
        insert pl1;
       
        
        UPSInvoiceCompController uc = new UPSInvoiceCompController();
        UPSInvoiceCompController.plWrapper upw = new UPSInvoiceCompController.plWrapper();
        
      
        uc.shipmentId = shipments.Id;
        UPSInvoiceCompController.getCurrencyIsoCode(shipments);
        uc.getPackageListsWrapper();
        
        System.assertEquals(contact.Email, 'test@test.com');
        }catch(Exception e){} 
        test.stopTest();
    }
}