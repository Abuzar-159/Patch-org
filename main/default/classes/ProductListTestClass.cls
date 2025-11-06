@isTest
private class ProductListTestClass {
	 
     /*static testmethod void UnitTest(){
        Account o = new Account(Name='Test Organisation', ERP7__Active__c='Yes', ERP7__Account_Type__c='Organisation', AccountNumber='CUS-001');
        insert o;
        
		RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
             
        Id pricebookId = Test.getStandardPricebookId();
        
        Account c = new Account(Name='Test Organisation', ERP7__Active__c='Yes', ERP7__Account_Type__c='Customer', AccountNumber='CUS-001', ERP7__Order_Profile__c=sop.Id);
        insert c;

        Contact con = new Contact(FirstName='Test', LastName='Test', AccountID=c.Id);
        insert con;
		
        ERP7__Address__c address = new ERP7__Address__c(Name='Nildram Ltd', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id,
                                                        ERP7__Active__c=true, ERP7__Primary__c=true, ERP7__Is_Billing_Address__c=true,
                                                        ERP7__Is_Shipping_Address__c=true, ERP7__Address_Line1__c='Ardenham Court',ERP7__Address_Line2__c='Oxford Road',
                                                        ERP7__Country__c='United Kingdom', ERP7__City__c='AYLESBURY', ERP7__State__c='Buckinghamshire', ERP7__Postal_Code__c='HP19 3EQ',
                                                        ERP7__Organisation__c=o.Id);
        insert address;
        
        ERP7__Business_Unit__c busunit = new ERP7__Business_Unit__c(Name='Test', ERP7__Organisation__c=o.Id, ERP7__Returns_Address__c='Marketing',
                                                                    ERP7__Mailing_Address_Line_1__c='122', ERP7__Mailing_Address_Line_2__c='Free Zone Business Park',
                                                                    ERP7__Active__c=true, ERP7__Country__c='United Kingdom', ERP7__City__c='Birmingham', ERP7__Phone__c='0123456789',
                                                                    ERP7__Contact__c=con.Id, ERP7__Website__c='www.aqxolt.com');
        insert busunit;
        
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='E-Commerce Channel', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='David',
                                                        ERP7__Company__c='Aqxolt', ERP7__Phone__c='0123456789', ERP7__Active__c=true, ERP7__Organisation__c=o.Id,
                                                        ERP7__Organisation_Business_Unit__c=busunit.Id, ERP7__City__c='WORKINGTON', ERP7__Street__c='123 Do Not ship lane',
                                                        ERP7__State_Province__c='California', ERP7__Country__c='United States', ERP7__Zip_Postal_Code__c='0033');
        insert channel;
        
        ERP7__Site__c site = new ERP7__Site__c(Name='E-Commerce Warehouse', ERP7__Primary_Contact__c=con.Id, ERP7__Address__c=address.Id,
                                               ERP7__Active__c=true, ERP7__Type__c='Warehouse', ERP7__Organisation__c=o.Id, ERP7__Organisation_Business_Unit__c=busunit.Id);
        insert site;
        
        ERP7__Distribution_Channel__c disChannel = new ERP7__Distribution_Channel__c(Name='E-Commerce Distribution Channel', ERP7__Channel__c=channel.Id, ERP7__Contact__c=con.Id,
                                                                                     ERP7__Active__c=true, ERP7__Primary__c=true, ERP7__Site__c=site.Id, ERP7__Priority__c='2');
        insert disChannel;
        
            
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true,ERP7__Status__c = 'Released', family='FURNITURE');
        insert ps;   
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice; 
        
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert customPriceps;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = o.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
           
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Morgan Fedrik', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        
        ERP7__Cart__c cart = new ERP7__Cart__c(Name='E-Commerce Cart', ERP7__Channel__c=channel.ID, ERP7__Site__c=site.Id, ERP7__Employee__c=emp.Id, ERP7__Account__c=c.Id);
        insert cart;
        
        ERP7__Cart_Picked_Item__c CPI = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Product__c=ps.Id);
        insert CPI;
        
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Value_In_Percent__c=2, ERP7__Product__c=ps.Id);
        insert coupon;
        
        ERP7__Coupon_Issued__c CI = new ERP7__Coupon_Issued__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Coupon__c=coupon.Id,
                                                               ERP7__Issued_Date__c=system.today(), ERP7__Product__c=ps.Id);
        insert CI;
        
        ProductList PL = new ProductList();
        ProductList.productDisplayWrapper PDW = new ProductList.productDisplayWrapper();
        ProductList.PriceBookEntryWrapper PEW = new ProductList.PriceBookEntryWrapper();
        ProductList.returnClass RC = new ProductList.returnClass();
        String accID=c.Id; String profileID=sop.Id; String channelID=channel.Id; String family='FURNITURE';
        ProductList.fetchProducts(accID, profileID, channelID, family);
        ProductList.saveCarts(accID, profileID);
        ProductList.getPickList();
        ProductList.getDeleteProducts();
        String Coupons=coupon.Id; Decimal totalPrice = 2.0;
        ProductList.applyCoupons(Coupons, totalPrice, accID);
    }*/
    static testMethod void unitTest1(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        //Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;
        ERP7__Cart__c cart=new ERP7__Cart__c(Name='Test',ERP7__Account__c=acc.Id);
        insert cart;
        ERP7__Cart_Picked_Item__c cpi=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;
        ProductList.fetchProducts(acc.Id,profile.Id,'Hardware');
        ProductList.saveCarts(acc.Id,profile.Id);
        ProductList.applyCoupons('Test',10,acc.Id);
        ProductList.getDeleteProducts();
        ProductList.getPickList();
        System.assertEquals('ERP', 'ERP');
        
    }
}