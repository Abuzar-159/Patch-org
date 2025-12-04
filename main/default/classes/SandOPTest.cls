@isTest
private class SandOPTest {
    @testSetup
    static void testDataSetup() {
        // Create Organisation Account
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn; 

        // Create Customer Account before Address__c
        Account acc = new Account(Name='Naseeruddin', Account_Type__c = 'Customer', ERP7__Organisation__c=orgn.Id);
        insert acc;

        // Create Address__c with ERP7__Customer__c
        Address__c add = new Address__c(
            ERP7__Customer__c=acc.Id,
            Address_Line1__c='test', 
            Address_Line2__c='test', 
            Address_Line3__c='test', 
            City__c='test', 
            ERP7__Country__c='United Kingdom', 
            Is_Billing_Address__c=true, 
            Is_Shipping_Address__c=true, 
            Primary__c=true, 
            ERP7__Active__c=true, 
            ERP7__Postal_Code__c='123', 
            ERP7__State__c='Ajman'
        );
        insert add;

        // Create Site
        ERP7__Site__c site = new ERP7__Site__c(
            Name='TestSite', 
            ERP7__Organisation__c=orgn.Id, 
            ERP7__Address__c=add.Id, 
            ERP7__Active__c=true
        );
        insert site;

        // Create Location with required ERP7__Site__c field
        ERP7__Location__c location = new ERP7__Location__c(Name = 'TestLocation', ERP7__Site__c = site.Id);
        insert location;

        // Continue with the rest of the setup
        Contact contact = new Contact(FirstName='Test', LastName='Contact', AccountId=acc.id, Phone='1234567890', Email='test@test.com');
        insert contact;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware', IsActive=TRUE, ERP7__Length__c=2, ERP7__Width__c=2, ERP7__Height__c=2, ERP7__Weight__c=2);
        insert pro;
        ERP7__Version__c ver = new ERP7__Version__c(Name='Test', Product__c=pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020, IsActive = true);
        insert pbe;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Channel', ERP7__Active__c=true, ERP7__Ship_From_Address__c=add.Id);
        insert channel;
        RecordType custProfile_RTypes = [SELECT Id, Name FROM RecordType WHERE Name = 'Customer' AND SobjectType = 'ERP7__Profiling__c' LIMIT 1]; 
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test', RecordTypeId=custProfile_RTypes.Id, ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert custProfile;
        RecordType orderProfile_RTypes = [SELECT Id, Name FROM RecordType WHERE Name = 'Order Profile' AND SobjectType = 'ERP7__Profiling__c' LIMIT 1];
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='AK Test', ERP7__Active__c=true, ERP7__Organisation__c=acc.Id, ERP7__Channel__c=channel.Id, ERP7__Price_Book__c=standardPricebook.Id, ERP7__Tax_Sourcing_Rules__c ='Origin', RecordTypeId=orderProfile_RTypes.Id, ERP7__Account_Profile__c=custProfile.Id);
        insert profile;
        acc.ERP7__Order_Profile__c = profile.Id;
        update acc;
        RecordType rTypeProfile = [SELECT Id, Name FROM RecordType WHERE SobjectType='ERP7__Profiling__c' AND Name='Employee' LIMIT 1];
        ERP7__Profiling__c empProfile = new ERP7__Profiling__c(Name='test', Active__c=true, RecordTypeId=rTypeProfile.Id);
        insert empProfile; 
        Employees__c emp = new Employees__c(First_Name__c='Naseer', Last_Name__c='Akhtar', Email__c='test@test.com', Organisation__c=orgn.Id, Employee_User__c=UserInfo.getUserId(), Employment_Status__c = 'Active', Non_Employee__c = false, Employee_Profiling__c=empProfile.Id);
        insert emp;
        Distribution_Channel__c dCh = new Distribution_Channel__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Site__c=site.Id, ERP7__Active__c=true);
        insert dCh;
        Order ord = new Order(Name = 'Test Order', Status = 'Draft', EffectiveDate = System.today(), ERP7__Shipment_Type__c='UPS', ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id, Pricebook2Id=standardPricebook.Id, ERP7__Amount__c=345, ERP7__Expected_Date__c=Date.today(), ERP7__Ship_To_Address__c=add.Id, ERP7__Bill_To_Address__c=add.id,
                             ERP7__Order_Profile__c=profile.Id, ERP7__Stage__c='Entered', ERP7__Channel__c=channel.Id, ERP7__Contact__c=contact.Id); 
        insert ord;
        // Set CreatedDate for the Order
        Test.setCreatedDate(ord.Id, DateTime.newInstance(2025, 1, 1));
        OrderItem orditem = new OrderItem(OrderId = ord.Id, Quantity = 1, UnitPrice = 100, Product2Id = pro.Id, PricebookEntryId=pbe.Id, ERP7__Active__c=true);        
        insert orditem;
        
         Order ord2 = new Order(Name = 'TEST_ORDER_001', Status = 'Draft', EffectiveDate = System.today(), ERP7__Shipment_Type__c='UPS', ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id, Pricebook2Id=standardPricebook.Id, ERP7__Amount__c=345, ERP7__Expected_Date__c=Date.today(), ERP7__Ship_To_Address__c=add.Id, ERP7__Bill_To_Address__c=add.id,
                             ERP7__Order_Profile__c=profile.Id, ERP7__Stage__c='Entered', ERP7__Channel__c=channel.Id, ERP7__Contact__c=contact.Id , ERP7__Organisation__c = orgn.Id); 
        insert ord2;
        System.debug('ord2 ->'+ord2.Name);
        // Set CreatedDate for the Order
        //Test.setCreatedDate(ord2.Id, DateTime.newInstance(2025, 1, 1));
        OrderItem orditem2 = new OrderItem(OrderId = ord2.Id, Quantity = 1, UnitPrice = 100, Product2Id = pro.Id, PricebookEntryId=pbe.Id, ERP7__Active__c=true);        
        insert orditem2;
        ERP7__Inventory_Stock__c warehouseItemInventoryStock = new ERP7__Inventory_Stock__c(Organisation__c = orgn.Id, Name='test', Active__c=true, Warehouse__c=site.Id, Product__c=pro.Id, ERP7__Location__c=location.Id, ERP7__Checked_In_Date__c=Date.today().addDays(-30));
        insert warehouseItemInventoryStock;  
        ERP7__Inventory_Stock__c warehouseItemInventoryStock2 = new ERP7__Inventory_Stock__c(Organisation__c = orgn.Id, Name='test', ERP7__Status__c='Checked In',Active__c=true, Warehouse__c=site.Id, Product__c=pro.Id, ERP7__Checked_In_Date__c=Date.today().addDays(-40),ERP7__Expiry_Date__c=Date.today().addDays(-10));
        insert warehouseItemInventoryStock2;    
        Stock_Inward_Line_Item__c spli = new Stock_Inward_Line_Item__c(Name='test', Active__c=true, ERP7__Site_ProductService_InventoryStock__c=warehouseItemInventoryStock.Id, Product__c=pro.Id, Quantity__c=10);
        insert spli;
        Stock_Inward_Line_Item__c spli2 = new Stock_Inward_Line_Item__c(Name='test', Active__c=true, ERP7__Site_ProductService_InventoryStock__c=warehouseItemInventoryStock2.Id, Product__c=pro.Id, Quantity__c=10,ERP7__Status__c = 'In Stock',ERP7__Unit_Price__c=10,ERP7__Amount__c=100);
        insert spli2;
         Stock_Inward_Line_Item__c spli3 = new Stock_Inward_Line_Item__c(Name='test', Active__c=true, ERP7__Site_ProductService_InventoryStock__c=warehouseItemInventoryStock2.Id, Product__c=pro.Id, Quantity__c=10,ERP7__Status__c = 'In Stock');
        insert spli3;
        Tier__c tier1 = new Tier__c(Active__c=true, Floor_Unit__c=1, Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(Name='test', Active__c=true, Ceiling_Discount_Percentage__c=20, Default_Discount_Percentage__c=10, Floor_Discount_Percentage__c=0, Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true, Active__c=true, Product__c=pro.Id, Tier__c=tier1.Id, Discount_Plan__c=dp.id, Order_Profile__c=profile.Id, ERP7__Price_Book__c =profile.ERP7__Price_Book__c);
        insert tda;
        ERP7__Tax__c tax = new ERP7__Tax__c(Active__c=true, Effective_Date__c=System.today(), Expiry_Date__c=System.today()+10, Tax_Rate__c=10, ERP7__Type__c='Sales tax', ERP7__Account_Profile__c=profile.Id, ERP7__Province__c='Ajman', ERP7__Country__c='United Kingdom', ERP7__Product__c=pro.Id, ERP7__Postal_Code__c='123');
        insert tax;
        ERP7__Invoice__c invoice = new ERP7__Invoice__c(Active__c = true, Order_S__c=ord.id, Account__c=acc.id, ERP7__Invoice_Amount__c=100);
        insert invoice;
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='test', ERP7__Start_Date__c=System.today(), ERP7__End_Date__c=System.today(), ERP7__Value__c=10.02,
                                                     ERP7__Minimum_Order_Amount__c=10.00, ERP7__Pre_Tax_Discount__c=true);
        insert coupon;
        ERP7__Coupon_Issued__c ci = new ERP7__Coupon_Issued__c(Name='test', ERP7__Coupon__c=coupon.Id, ERP7__Issued_Date__c=System.today(), ERP7__Product__c=pro.Id);
        insert ci;
        ERP7__Coupon_Redemption__c cr = new ERP7__Coupon_Redemption__c(Name='Test', ERP7__Coupon_Issued__c=ci.Id, ERP7__Redemption_Date__c=System.today(),
                                                                       ERP7__Coupon__c=coupon.Id);
        insert cr;
        ERP7__Credit_Note__c credit = new ERP7__Credit_Note__c(Name='Test', ERP7__Coupon_Redemption__c=cr.Id, ERP7__Account__c=acc.Id, ERP7__Credit__c=100, ERP7__Debit__c=10);
        insert credit;
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Loyalty_Program__c loyaltyProg = new Loyalty_Program__c(ERP7__Active__c=true, ERP7__Loyalty_Setup__c=loyalty.Id);
        insert loyaltyProg;
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=acc.id, Contact__c=contact.id, Status__c='Active', Start_date__c=System.today(), Expiration_Date__c=System.today()+10, ERP7__Loyalty_Program__c=loyaltyProg.Id, ERP7__Organisation__c=orgn.Id);
        insert clubCard;
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        ERP7__UPS_Package_Type__c upsPackageType = new ERP7__UPS_Package_Type__c(Name='test', ERP7__Package_Code__c='12', ERP7__Package_Description__c='Package');
        insert upsPackageType;

        // Create Reordering Rule for stock alert tests
        ERP7__Reordering_Rule__c rule = new ERP7__Reordering_Rule__c(
            ERP7__Product__c = pro.Id,
            ERP7__Warehouse__c = site.Id,
            ERP7__Safety_Stock__c = 5,
            ERP7__Reorder_Level__c = 15,
            ERP7__Active__c = true
        );
        insert rule;
    }
   
    @isTest
    static void testGetTopProductsByDemand() {
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];

        Test.startTest();
        Map<String, Object> result = sandOP.getTopProductsByDemand(org.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('topProductLabels'), 'Result should contain topProductLabels');
        System.assert(result.containsKey('topProductData'), 'Result should contain topProductData');
        List<String> labels = (List<String>)result.get('topProductLabels');
    }
    @isTest
    static void testGetWarehouseInventory() {
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];

        // Update Stock_Inward_Line_Item__c to ensure stock quantity
        Stock_Inward_Line_Item__c spli = [SELECT Id FROM Stock_Inward_Line_Item__c WHERE Product__c = :prod.Id LIMIT 1];
        spli.Quantity__c = 10;
        update spli;

        Test.startTest();
        Map<String, Object> result = sandOP.getWarehouseInventory(org.Id, prod.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('warehouseLabels'), 'Result should contain warehouseLabels');
        System.assert(result.containsKey('warehouseInventory'), 'Result should contain warehouseInventory');
        List<Decimal> inventory = (List<Decimal>)result.get('warehouseInventory');
        System.assert(inventory.size() > 0, 'Expected non-empty warehouse inventory');
    }

    @isTest
    static void testGetWarehouseInventoryNoProduct() {
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];

        // Update Stock_Inward_Line_Item__c
        Stock_Inward_Line_Item__c spli = [SELECT Id FROM Stock_Inward_Line_Item__c LIMIT 1];
        spli.Quantity__c = 10;
        update spli;

        Test.startTest();
        Map<String, Object> result = sandOP.getWarehouseInventory(org.Id, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('warehouseLabels'), 'Result should contain warehouseLabels');
        System.assert(result.containsKey('warehouseInventory'), 'Result should contain warehouseInventory');
    }
    @isTest
    static void testGetLocationInventory() {
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
        ERP7__Site__c site = [SELECT Id FROM ERP7__Site__c WHERE Name = 'TestSite' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];

        // Update Stock_Inward_Line_Item__c
        Stock_Inward_Line_Item__c spli = [SELECT Id FROM Stock_Inward_Line_Item__c WHERE Product__c = :prod.Id LIMIT 1];
        spli.Quantity__c = 10;
        update spli;

        Test.startTest();
        Map<String, Object> result = sandOP.getLocationInventory(site.Id, org.Id, prod.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('locationLabels'), 'Result should contain locationLabels');
        System.assert(result.containsKey('locationInventory'), 'Result should contain locationInventory');
    }

    @isTest
    static void testGetLocationInventoryNoProduct() {
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
        ERP7__Site__c site = [SELECT Id FROM ERP7__Site__c WHERE Name = 'TestSite' LIMIT 1];

        // Update Stock_Inward_Line_Item__c
        Stock_Inward_Line_Item__c spli = [SELECT Id FROM Stock_Inward_Line_Item__c LIMIT 1];
        spli.Quantity__c = 10;
        update spli;

        Test.startTest();
        Map<String, Object> result = sandOP.getLocationInventory(site.Id, org.Id, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('locationLabels'), 'Result should contain locationLabels');
        System.assert(result.containsKey('locationInventory'), 'Result should contain locationInventory');
    }
    @isTest
    static void testGetStockAlertData() {
        ERP7__Site__c site = [SELECT Id FROM ERP7__Site__c WHERE Name = 'TestSite' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];
        ERP7__Location__c location = [SELECT Id FROM ERP7__Location__c WHERE Name = 'TestLocation' LIMIT 1];
		Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
        // Update Stock_Inward_Line_Item__c
        Stock_Inward_Line_Item__c spli = [SELECT Id FROM Stock_Inward_Line_Item__c WHERE Product__c = :prod.Id LIMIT 1];
        spli.Quantity__c = 10;
        update spli;

        Test.startTest();
        List<Map<String, Object>> result = sandOP.getStockAlertData(site.Id, location.Id, prod.Id,org.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Expected stock alert data');
        System.assertEquals('Laptop X200', result[0].get('productName'), 'Expected product name to be Laptop X200');
    }

    @isTest
    static void testGetDynamicStockAgingData() {
        ERP7__Site__c site = [SELECT Id FROM ERP7__Site__c WHERE Name = 'TestSite' LIMIT 1];
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];

        // Update Stock_Inward_Line_Item__c
        Stock_Inward_Line_Item__c spli = [SELECT Id FROM Stock_Inward_Line_Item__c WHERE Product__c = :prod.Id LIMIT 1];
        spli.Quantity__c = 10;
        update spli;

        Test.startTest();
        List<Map<String, Object>> result = sandOP.getDynamicStockAgingData(site.Id, org.Id, prod.Id);
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Expected stock aging data');
        System.assertEquals('Laptop X200', result[0].get('productName'), 'Expected product name to be Laptop X200');
    }
    @isTest
    static void testGetAgingTrendData() {
        ERP7__Site__c site = [SELECT Id FROM ERP7__Site__c WHERE Name = 'TestSite' LIMIT 1];
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];

        // Update Stock_Inward_Line_Item__c
        Stock_Inward_Line_Item__c spli = [SELECT Id FROM Stock_Inward_Line_Item__c WHERE Product__c = :prod.Id LIMIT 1];
        spli.Quantity__c = 10;
        update spli;

        Test.startTest();
        List<Map<String, Object>> result = sandOP.getAgingTrendData(site.Id, org.Id, prod.Id, '2024');
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Expected aging trend data');
        System.assert(result[0].containsKey('month'), 'Result should contain month key');
    }

    @isTest
    static void testGetCustomerOrderTrend() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Naseeruddin' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
		Id prd = null;
        Test.startTest();
        Map<String, Object> result = sandOP.getCustomerOrderTrend(acc.Id, prod.Id, org.Id, '2024');
        Map<String, Object> result2 = sandOP.getCustomerOrderTrend(acc.Id,prd,org.Id, '2024');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('months'), 'Result should contain months');
        System.assert(result.containsKey('quantities'), 'Result should contain quantities');
        List<Decimal> quantities = (List<Decimal>)result.get('quantities');
    }

    @isTest
    static void testGetCustomerSummary() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Naseeruddin' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];
		Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
       List<Order> ordList = [SELECT Id, Status FROM Order];
        System.debug('ordList ->'+ordList);
        //System.assertEquals(1, ordList.size(), 'Order should exist from testSetup');
        Order ord = ordList[1];
        ord.status='Activated';
        update ord;
        Id prd=null;
        Test.startTest();
        Map<String, Object> result = sandOP.getCustomerSummary(acc.Id, prod.Id, '2024',org.Id);
        Map<String, Object> result2 = sandOP.getCustomerSummary(acc.Id, prd, '2024',org.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result map should not be null');
        System.assert(result.containsKey('frequency'), 'Result should contain frequency');
        System.assert(result.containsKey('monetary'), 'Result should contain monetary');
        System.assert(result.containsKey('recencyDays'), 'Result should contain recencyDays');
   
    }
	 @isTest
    static void testgetTopCustomersForProduct() {
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];
        Account org = [SELECT Id FROM Account WHERE Name = 'Organisation' LIMIT 1];
        List<Order> ordList = [SELECT Id, Status FROM Order];
        System.debug('ordList ->'+ordList);
        //System.assertEquals(1, ordList.size(), 'Order should exist from testSetup');
        Order ord = ordList[1];
        ord.status='Activated';
        update ord;
        Test.startTest();
        List<Map<String, Object>> result = sandOP.getTopCustomersForProduct(prod.Id,5,org.Id);
        Test.stopTest();
   
    }
    @isTest
     static void testgetDemandForecastWithHistory() {
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Laptop X200' LIMIT 1];
        Test.startTest();
        Map<String, Object> result = sandOP.getDemandForecastWithHistory(prod.Id,'');
        Test.stopTest();
   
    }
  }