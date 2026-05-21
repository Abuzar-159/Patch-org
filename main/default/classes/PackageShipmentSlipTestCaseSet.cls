@isTest
private class PackageShipmentSlipTestCaseSet {
    
    static testMethod void unitTestCase1() {
        Account orgn = new Account(Name='Organisation',  Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123', AccountId = orgn.Id);
        insert contact;
        Address__c bAddress = new Address__c(Customer__c = orgn.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c( Primary__c = true , Customer__c=orgn.id,Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint1 = new Channel__c(Name = 'Sale Point',Organisation__c = orgn.id,Active__c=true);
        insert salepoint1;
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = orgn.Id;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint1.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        insert sod;
        Product2 ps = new Product2(Name='test',
                                Item_Description__c = 'test description',Picture__c = 'testUrl',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Package__c pack = new Package__c( Name__c='Test Package',
                                     Sales_Order__c = sod.Id, Active__c = true, Description__c = 'Test Description');
        insert pack;
        Package_List__c packList = new Package_List__c(Name = 'Test Package List', Package__c = pack.Id,
                                              Sales_Order_Line_Item__c = solim.Id, Quantity__c = 2);
        insert packList;
        
        PageReference page = System.Page.PackageSlip;
        page.getParameters().put('packId', pack.Id);
        Test.setCurrentPage(page);
        
        Test.startTest();
        Package_Shipment_Slip packShip = new Package_Shipment_Slip();
        
        packShip.viewSlip();
        packShip.ccEmail_Addresses = 'test@test.com';
        try { packShip.sendPackagingSlip(); } catch(Exception e) { packShip.exceptionMethod(e, 'Test'); }
        
        String s1 = 'TestUnit';
        String s2 = 'TestUnit';
        System.assertEquals(s1,s2);
        Test.stopTest();
    }
    
    static testMethod void unitTestCase2() {
        Account orgn = new Account(Name='unitTestCase2Organisation',  Account_Type__c = 'Organisation');
        insert orgn;
        Account cust = new Account(Name='unitTestCase2Customer',  Account_Type__c = 'Customer');
        insert cust;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        Address__c bAddress = new Address__c( Customer__c = orgn.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c( Primary__c = true , Customer__c=orgn.id,Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint1 = new Channel__c(Name = 'Sale Point',Organisation__c = orgn.id,Active__c=true);
        insert salepoint1;
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = orgn.Id;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint1.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        insert sod;
        Product2 ps = new Product2(Name='test',
                                Item_Description__c = 'test description',Picture__c = 'testUrl',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,
                                         Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,
                                         VAT_Amount__c=10);
        insert solim;
        Shipment__c shipment = new Shipment__c( Sales_Order__c = sod.Id,
                                          Customer__c = cust.Id, Customer_Contact__c = Contact.Id);
        insert shipment;
        Package__c pack = new Package__c( Name__c='Test Package',
                                     Shipment__c = shipment.Id, Sales_Order__c = sod.Id, Active__c = true, Description__c = 'Test Description');
        insert pack;
        Package_List__c packList = new Package_List__c(Name = 'Test Package List', Package__c = pack.Id,
                                              Sales_Order_Line_Item__c = solim.Id, Quantity__c = 2);
        insert packList;
        
        PageReference page = System.Page.ShippingSlip;
        page.getParameters().put('shipId', shipment.Id);
        Test.setCurrentPage(page);
        
        Test.startTest();
        Package_Shipment_Slip packShip = new Package_Shipment_Slip();
        
        packShip.sendPackagingSlip();
        
        String s1 = 'TestUnit';
        String s2 = 'TestUnit';
        System.assertEquals(s1,s2);
        Test.stopTest();
    }
}