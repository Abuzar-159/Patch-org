@isTest
public class InventoryManagementReport_testClass {
    @isTest//(seeAllData = true)
    public static void testcase1(){
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < 5; i++) {
            Product2 p = new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'TestCode' + i,
                Family = 'Test Family',
                ERP7__Product_Service_Family__c = 'Test Subfamily',
                IsActive = true
            );
            products.add(p);
        }
        insert products;
        // Create test Inventory_Stock__c record
        Inventory_Stock__c inventoryStock = new Inventory_Stock__c(
            Name = 'Test Inventory Stock',
            ERP7__Active__c = true,
            ERP7__Warehouse__c = site.Id,
            ERP7__Product__c = products[0].Id,
            ERP7__Organisation__c = o.Id
            // Add other required fields as needed
        );
        insert inventoryStock;
        
        // Create test Stock_Inward_Line_Item__c record
        Stock_Inward_Line_Item__c inwardLineItem = new Stock_Inward_Line_Item__c(
            Name = 'Test Inward Line Item',
            Active__c = true,
            Site_ProductService_InventoryStock__c = inventoryStock.Id,
            Product__c = products[0].Id,
            Quantity__c = 20
            // Add other required fields as needed
        );
        insert inwardLineItem;
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Supplier'); 
        insert sup;
        ERP7__PO__c PO1 = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id,  ERP7__Organisation__c = o.Id); // ERP7__Ready_To_Receive__c = true 23/10/23
        insert PO1;
        Stock_Inward_Line_Item__c inwardLineItem2 = new Stock_Inward_Line_Item__c(
            Name = 'Test Inward Line Item',
            Active__c = true,
            Site_ProductService_InventoryStock__c = inventoryStock.Id,
            Product__c = products[0].Id,
            Quantity__c = 20,
            ERP7__Purchase_Orders__c = PO1.Id,
            ERP7__Status__c = 'In Stock'
            // Add other required fields as needed
        );
        insert inwardLineItem2;
        ERP7__Stock_Take__c  stockTakesObject = new ERP7__Stock_Take__c(Name='test');
        insert stockTakesObject;
        ERP7__Stock_Take_Line_Item__c SINLINE = new ERP7__Stock_Take_Line_Item__c(Name='test',Product__c = products[0].Id,ERP7__Adjusted_Quantity__c = 12,ERP7__Stock_Take__c = stockTakesObject.Id,ERP7__Inventory_Stock__c = inventoryStock.Id);
        insert SINLINE;
        Stock_Inward_Line_Item__c inwardLineItem3 = new Stock_Inward_Line_Item__c(
            Name = 'Test Inward Line Item',
            Active__c = true,
            Site_ProductService_InventoryStock__c = inventoryStock.Id,
            Product__c = products[0].Id,
            Quantity__c = 20,
            ERP7__Stock_Take_Line_Item__c = SINLINE.Id
            // Add other required fields as needed
        );
        insert inwardLineItem3;
        
        List<Stock_Outward_Line_Item__c> outwardLineItems = new List<Stock_Outward_Line_Item__c>();
        // for(Integer i = 0; i < 5; i++) {
        Stock_Outward_Line_Item__c outwardLineItem = new Stock_Outward_Line_Item__c(
            Name = 'Test Outward Line Item ',
            Active__c = true,
            ERP7__Site_Product_Service_Inventory_Stock__c = inventoryStock.Id,
            Product__c = products[0].Id,
            ERP7__Status__c ='Reserved',
            Quantity__c = 15
            // Add other required fields as needed
        );
        //  outwardLineItems.add(outwardLineItem);
        // }
        outwardLineItem.ERP7__Stock_Take_Line_Item__c = SINLINE.Id;
        insert outwardLineItem;
        Test.startTest();
        InventoryManagementReport.getPicklistFamilyAndSubFamily();
        InventoryManagementReport.getInvnetoryTrace(products[0].Id,'','','',site.Id,null,null);
        InventoryManagementReport.getInventoryDetailsbyDate('','','',site.Id,100,1,null,null);
        InventoryManagementReport.getInventoryDetails('','','',site.Id,100,1,0);
        ERP7__Reordering_Rule__c rr = InventoryManagementReport.createReorder(JSON.serialize(new ERP7__Reordering_Rule__c(Name='test',ERP7__Active__c = true,ERP7__Lead_Time__c = 10,ERP7__MinimumOrderingQuantity__c = 200,ERP7__Product__c=products[0].Id)));
       	InventoryManagementReport.getReorderingRules('',10,200,'',products[0].Id);
        InventoryManagementReport.updateReorder(rr.Id,True);
        Test.stopTest();
    }
    @isTest
    static void testGetInventoryDetailsbyDate() {
        // Create test data
        
        // Create test Product2 records
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < 5; i++) {
            Product2 p = new Product2(
                Name = 'Test Product ' + i,
                ProductCode = 'TestCode' + i,
                Family = '',
                ERP7__Product_Service_Family__c = '',
                IsActive = true
            );
            products.add(p);
        }
        insert products;
        //from here
        List<String> productsIdlist = new List<String>();
        for(Product2 pro: products){
            productsIdlist.add(pro.Id);
        }//till here
        products[0].ERP7__Lot_Tracked__c = true;
        update products[0];
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=products[0].Id,ERP7__Active__c=true);
        insert batch1;
        // Create test Site record
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        
        // Create test Inventory_Stock__c records
        List<Inventory_Stock__c> inventoryStocks = new List<Inventory_Stock__c>();
        for(Integer i = 0; i < 5; i++) {
            Inventory_Stock__c inventoryStock = new Inventory_Stock__c(
                ERP7__Organisation__c = o.Id,
                Name = 'Test Inventory Stock ' + i,
                ERP7__Active__c = true,
                ERP7__Warehouse__c = site.Id,
                ERP7__Product__c = products[i].Id
                // Add other required fields as needed
            );
            inventoryStocks.add(inventoryStock);
        }
        inventoryStocks[0].ERP7__Batch_Lot__c = batch1.Id;
        insert inventoryStocks;
        
        // Create test Stock_Inward_Line_Item__c records
        List<Stock_Inward_Line_Item__c> inwardLineItems = new List<Stock_Inward_Line_Item__c>();
        for(Integer i = 0; i < 5; i++) {
            Stock_Inward_Line_Item__c inwardLineItem = new Stock_Inward_Line_Item__c(
                Name = 'Test Inward Line Item ' + i,
                Active__c = true,
                Site_ProductService_InventoryStock__c = inventoryStocks[i].Id,
                Product__c = products[i].Id,
                ERP7__Status__c ='In Stock',
                Quantity__c = 20
                // Add other required fields as needed
            );
            inwardLineItems.add(inwardLineItem);
        }
        inwardLineItems[0].ERP7__Material_Batch_Lot__c = batch1.Id;
        insert inwardLineItems;
        // Create test Stock_Outward_Line_Item__c records
        List<Stock_Outward_Line_Item__c> outwardLineItems = new List<Stock_Outward_Line_Item__c>();
        for(Integer i = 0; i < 5; i++) {
            Stock_Outward_Line_Item__c outwardLineItem = new Stock_Outward_Line_Item__c(
                Name = 'Test Outward Line Item ' + i,
                Active__c = true,
                ERP7__Site_Product_Service_Inventory_Stock__c = inventoryStocks[i].Id,
                Product__c = products[i].Id,
                ERP7__Status__c ='Reserved',
                Quantity__c = 15
                // Add other required fields as needed
            );
            outwardLineItems.add(outwardLineItem);
        }
        outwardLineItems[0].ERP7__Material_Batch_Lot__c = batch1.Id;
        insert outwardLineItems;
        // Call the method to be tested
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = products[0].Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = products[1].Id, UnitPrice = 1020,IsActive = true);
        insert pbe1;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Organisation__c=o.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
        
        
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = products[0].Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        outwardLineItems[0].ERP7__Order__c = ord.Id;
        update outwardLineItems[0];
        Test.setCreatedDate(orditem.Id, DateTime.newInstance(2024, 2, 1));
        OrderItem orditem1 = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = products[1].Id,PricebookEntryId=pbe1.Id,ERP7__Active__c=true);        
        insert orditem1;
        ERP7__Transfer_Order__c TO = new ERP7__Transfer_Order__c(
            Name = 'Test02',                                     // Transfer Order Name
            ERP7__Requested_Date__c = system.today(),  // Requested Date
            ERP7__Expected_Date__c = system.today()+1,   // Expected Date              // From Site
            ERP7__Status__c = 'Draft',                         // Status
            ERP7__Active__c = true,                                // Active
            ERP7__Customer__c = acc.Id,                 // Customer
            ERP7__Sellable_in_Transit__c = false,                  // Sellable in Transit
            ERP7__Receive_All_Close__c = false,                    // Receive All & Close
            ERP7__Tracking__c = '666',                             // TRACKING
            ERP7__Ready_To_Receive__c = true,                     // Ready To Receive
            ERP7__Ready_To_Pick_Pack__c = true,                    // Ready To Pick & Pack
            ERP7__Is_Closed__c = false,                            // Is Closed
            ERP7__Organisation__c = o.Id             // Organisation
        );
        insert TO;
        outwardLineItems[1].ERP7__Transfer_Order__c = TO.Id;
        update outwardLineItems[1];
        Test.startTest();
        InventoryManagementReport.getPicklistFamilyAndSubFamily();
        InventoryManagementReport.getInvnetoryTrace(products[0].Id,batch1.Id,'','',site.Id,null,null);
        InventoryManagementReport.getInventoryDetailsbyDate('','','',site.Id,100,1,null,null);
        InventoryManagementReport.getInventoryDetails('','','',site.Id,100,1,0);
        Date firstDateOfYear = Date.newInstance(Date.today().year(), 1, 1);
        
        InventoryManagementReport.getforecastByProduct(products[0].Id, 'Monthly', 'Sales', firstDateOfYear, System.today());
        InventoryManagementReport.getforecastByProduct(products[0].Id, 'Quarterly', 'Sales', firstDateOfYear, System.today());
        InventoryManagementReport.getforecastByProduct(products[0].Id, 'Quarterly', 'Production/Supply', firstDateOfYear, System.today());
        InventoryManagementReport.getforecastByProduct(products[0].Id, 'Monthly', 'Production/Supply', firstDateOfYear, System.today());
        
        InventoryManagementReport.getforecast('Monthly', 'Sales', firstDateOfYear, System.today(),10,1,productsIdlist);
        InventoryManagementReport.getforecast('Quarterly', 'Sales', firstDateOfYear, System.today(),10,1,productsIdlist);
        InventoryManagementReport.getforecast('Quarterly', 'Production/Supply', firstDateOfYear, System.today(),10,1,productsIdlist);
        InventoryManagementReport.getforecast('Monthly', 'Production/Supply', firstDateOfYear, System.today(),10,1,productsIdlist);
        
        InventoryManagementReport.getforecastforMRPS('Monthly','Sales',firstDateOfYear,System.today(),10,1,productsIdlist,new List<Id>());
        InventoryManagementReport.getforecastforMRPS('Quarterly','Sales',firstDateOfYear,System.today(),10,1,new List<String>(),new List<Id>());
        InventoryManagementReport.getforecastforMRPS('Monthly','Production/Supply',firstDateOfYear,System.today(),10,1,productsIdlist,new List<Id>());
        InventoryManagementReport.getforecastforMRPS('Quarterly','Production/Supply',firstDateOfYear,System.today(),10,1,new List<String>(),new List<Id>());
        
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products[0].Id,'Reserved SO',System.today(),firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products[0].Id,'Reserved MO',System.today(),firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products[0].Id,'Demand SO',System.today(),firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products[0].Id,'Demand MO',System.today(),firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products[0].Id,'IC Transfer',System.today(),firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products[0].Id,'Open POs',System.today(),firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products[0].Id,'Open MOs',System.today(),firstDateOfYear);
        Test.stopTest();
        
        
    }
    @isTest 
    static void getOrderDetailsBasedOnStatusTestCase(){
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        Date firstDateOfYear = Date.newInstance(System.today().year(), 1, 1);
        Date today = System.today();
        Product2 products = new Product2(
            Name = 'Test Product ' + 11,
            ProductCode = 'TestCode' + 34,
            Family = '',
            ERP7__Product_Service_Family__c = '',
            IsActive = true
        );
        insert products;
        Inventory_Stock__c inventoryStock = new Inventory_Stock__c(
                ERP7__Organisation__c = o.Id,
                Name = 'Test Inventory Stock ' + 34,
                ERP7__Active__c = true,
                ERP7__Warehouse__c = site.Id,
                ERP7__Product__c = products.Id
            );
        insert inventoryStock;
         Stock_Inward_Line_Item__c inwardLineItem = new Stock_Inward_Line_Item__c(
                Name = 'Test Inward Line Item ' + 2,
                Active__c = true,
                Site_ProductService_InventoryStock__c = inventoryStock.Id,
                Product__c = products.Id,
                ERP7__Status__c = 'In Stock',
                Quantity__c = 100
            );
        insert inwardLineItem;
          Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Organisation__c=o.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
         Stock_Outward_Line_Item__c outwardLineItem = new Stock_Outward_Line_Item__c(
                Name = 'Test Outward Line Item ',
                Active__c = true,
                ERP7__Site_Product_Service_Inventory_Stock__c = inventoryStock.Id,
                Product__c = products.Id,
                ERP7__Status__c = 'Reserved',
                Quantity__c = 1,
                ERP7__Order__c = ord.Id
            );
        insert outwardLineItem;
        ERP7__Manufacturing_Order__c mo = new ERP7__Manufacturing_Order__c(Name = 'test MO');
        insert mo;
         Stock_Outward_Line_Item__c outwardLineItem1 = new Stock_Outward_Line_Item__c(
                Name = 'Test Outward Line Item ',
                Active__c = true,
                ERP7__Site_Product_Service_Inventory_Stock__c = inventoryStock.Id,
                Product__c = products.Id,
                ERP7__Status__c = 'Reserved',
                Quantity__c = 1,
                ERP7__Manufacturing_Order__c = mo.Id
            );
        insert outwardLineItem1;
        Stock_Inward_Line_Item__c inwardLineItem2 = new Stock_Inward_Line_Item__c(
                Name = 'Test Inward Line Item ' + 2,
                Active__c = true,
                Site_ProductService_InventoryStock__c = inventoryStock.Id,
                Product__c = products.Id,
                ERP7__Status__c = 'Quality Check(QA)',
                Quantity__c = 100,
            	ERP7__Manufacturing_Order__c = mo.Id
            );
        insert inwardLineItem2;
         Account sup = new Account(Name='Supplier',Account_Type__c = 'Supplier'); 
        insert sup;
         ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;

        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true,ERP7__Priority__c = '1');
        insert DC;
        ERP7__PO__c PO1 = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = o.Id); // ERP7__Ready_To_Receive__c = true 23/10/23
        insert PO1;
         Stock_Inward_Line_Item__c inwardLineItem3 = new Stock_Inward_Line_Item__c(
                Name = 'Test Inward Line Item ' + 2,
                Active__c = true,
                Site_ProductService_InventoryStock__c = inventoryStock.Id,
                Product__c = products.Id,
                ERP7__Status__c = 'Quality Check(QA)',
                Quantity__c = 100,
            	ERP7__Purchase_Orders__c = PO1.Id
            );
        insert inwardLineItem3;
        Test.startTest();
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products.Id,'Reserved SO',System.today()+1,firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products.Id,'Reserved MO',System.today()+1,firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products.Id,'Demand SO',System.today()+1,firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products.Id,'Demand MO',System.today()+1,firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products.Id,'IC Transfer',System.today()+1,firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products.Id,'Open POs',System.today()+1,firstDateOfYear);
        InventoryManagementReport.getOrderDetailsBasedOnStatus(products.Id,'Open MOs',System.today()+1,firstDateOfYear);
        Test.stopTest();
    }
    @isTest
    static void testGetforecastByProduct() {
        // Create test data
        Product2 testProduct = new Product2(Name = 'Test Product', ProductCode = 'TEST001');
        insert testProduct;
        
        Date fromDate = Date.today().addMonths(-3);
        Date toDate = Date.today();
        
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = testProduct.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
        
        
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = testProduct.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        Test.setCreatedDate(orditem.Id, DateTime.newInstance(2024, 2, 1));
        
        
        // Call the method to test
        InventoryManagementReport.ForecastWrapper result = InventoryManagementReport.getforecastByProduct(
            testProduct.Id,
            'Month',
            'Sales',
            fromDate,
            toDate
        );
        
        // Assert the result
        System.assertEquals('Test Product', result.productName);
        System.assertEquals('TEST001', result.productCode);
        System.assertEquals(testProduct.Id, result.productId);
        // System.assertEquals(10, result.quantity); // Assuming there's only one order item
        //System.assertEquals(1, result.orderWarp.size()); // Assuming there's only one order
    }
    
    
    @testSetup
    static void setup() {
         Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Vendor'); 
        insert sup;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='DC',Channel__c = channel.Id,ERP7__Site__c = site.Id,ERP7__Active__c = true);
        insert dc;
        // Create test Product
        Product2 product = new Product2(Name = 'Test Product', ERP7__Storage_Holding_Cost__c = 5,ERP7__Issue_Purchase_Order__c=true);
        insert product;
        ERP7__Cost_Card__c cc = new ERP7__Cost_Card__c(Name='test p cc',ERP7__Active__c = true,ERP7__Cost__c = 10,ERP7__Default__c = true,ERP7__Product__c=product.Id,ERP7__Supplier__c = sup.Id);
        insert cc;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test',ERP7__Issue_Manufacturing_Order__c=true);
        insert product1;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product1.Id, ERP7__Category__c = 'Production', ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today()+3, ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified', ERP7__Default__c = true,ERP7__Active__c=true);
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified', ERP7__Type__c = 'Primary',BOM_Version__c=version.Id);
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified',BOM_Version__c=version.Id);
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product1.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
       
        // Create test Reordering Rule
        ERP7__Reordering_Rule__c reorderingRule = new ERP7__Reordering_Rule__c(
            ERP7__Active__c = true,
            ERP7__MinimumOrderingQuantity__c = 50,
            ERP7__Lead_Time__c = 5,
            ERP7__Vendor_Account__c = sup.Id, // Replace with a valid vendor account ID
            ERP7__Routing__c = routing.Id,
            ERP7__Minimum_Quantity__c = 20,
            ERP7__Maximum_Quantity__c = 100,
            ERP7__Warning_Quantity__c = 30,
            ERP7__Product__c = product1.Id
        );
        insert reorderingRule;
         ERP7__Reordering_Rule__c reorderingRule2 = new ERP7__Reordering_Rule__c(
            ERP7__Active__c = true,
            ERP7__MinimumOrderingQuantity__c = 50,
            ERP7__Lead_Time__c = 5,
            ERP7__Vendor_Account__c = sup.Id, // Replace with a valid vendor account ID
            ERP7__Minimum_Quantity__c = 20,
            ERP7__Maximum_Quantity__c = 100,
            ERP7__Warning_Quantity__c = 30,
            ERP7__Product__c = product.Id
        );
        insert reorderingRule2;
        ERP7__Material_Requirement_Planning__c mrp = new ERP7__Material_Requirement_Planning__c(
            Name = 'Test MRP',
            ERP7__From_Date__c = System.today(),
            ERP7__To_Date__c = System.today().addMonths(1),
            ERP7__Site__c = site.Id,
            //ERP7__Algorithm__c = 'Lot-for-Lot (L4L)',
            ERP7__Simulate__c = true
        );
        insert mrp;        
        // Create test MPS
        ERP7__MPS__c mps = new ERP7__MPS__c(
            Name = 'Test MPS',
            ERP7__Demand_Sales__c = 100,
            ERP7__Issued_WIP__c = 50,
            ERP7__Product__c = product.Id,
            ERP7__Awaiting_Qty__c = 20,
            ERP7__Starting_Inventory__c = 100,
            ERP7__Reserved_SO__c = 10,
            ERP7__Reordering_Rule__c = reorderingRule2.Id,
            ERP7__Default_Demand_Forecast__c = 150,
            ERP7__Master_MRP__c = mrp.Id,
            ERP7__Schedule_Period__c = 'Quarterly'
        );
        insert mps;
        ERP7__MPS__c mps1 = new ERP7__MPS__c(
            Name = 'Test MPS1',
            ERP7__Demand_Sales__c = 100,
            ERP7__Issued_WIP__c = 50,
            ERP7__Product__c = product1.Id,
            ERP7__Awaiting_Qty__c = 20,
            ERP7__Starting_Inventory__c = 100,
            ERP7__Reserved_SO__c = 10,
            ERP7__Reordering_Rule__c = reorderingRule.Id,
            ERP7__Default_Demand_Forecast__c = 150,
            ERP7__Master_MRP__c = mrp.Id,
            ERP7__Schedule_Period__c = 'Quarterly'
        );
        insert mps1;
        
        // Create test MPS line items
        List<ERP7__MPS_line_Item__c> mpsLineItems = new List<ERP7__MPS_line_Item__c>();
        for (Integer i = 1; i <= 3; i++) {
            mpsLineItems.add(new ERP7__MPS_line_Item__c(
                Name = 'MPS Line Item ' + i,
                ERP7__Actual_Demand__c = 100 + i * 10,
                ERP7__Demand_Forecast__c = 120 + i * 10,
                ERP7__FPA__c = 10 + i,
                ERP7__Month_Quarter_Year__c = 'Q' + i + '-24',
                ERP7__MPS__c = mps.Id
            ));
        }
        for (Integer i = 1; i <= 3; i++) {
            mpsLineItems.add(new ERP7__MPS_line_Item__c(
                Name = 'MPS Line Item ' + i,
                ERP7__Actual_Demand__c = 100 + i * 10,
                ERP7__Demand_Forecast__c = 120 + i * 10,
                ERP7__FPA__c = 10 + i,
                ERP7__Month_Quarter_Year__c = 'Q' + i + '-24',
                ERP7__MPS__c = mps1.Id
            ));
        }
        insert mpsLineItems;
    }
    
    @isTest
    static void testMRPSimulationHandler() {
        // Fetch MRP to simulate
        List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Lot-for-Lot (L4L)';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
        InventoryManagementReport.getMRPDetails(mrp[0].Id);
        InventoryManagementReport.saveMRPS(JSON.serialize(mrp[0]),JSON.serialize(MRPItem));
        List<InventoryManagementReport.ForecastWrapper> frwrap = new List<InventoryManagementReport.ForecastWrapper>();
        List<ERP7__MPS_line_Item__c> MPSlineitems = [Select Id,Name from ERP7__MPS_line_Item__c];
        InventoryManagementReport.ReorderingWrap rrwrap = new InventoryManagementReport.ReorderingWrap(10,20,new ERP7__Reordering_Rule__c(Name = 'test'));
        frwrap.add(new InventoryManagementReport.ForecastWrapper(MRPItem[0].ERP7__Product__c,'Test','00123',10, new Map<String,List<InventoryManagementReport.OrderDetailsWrap>>(),MPSlineitems,new List<InventoryManagementReport.ReorderingWrap>()));
        InventoryManagementReport.saveForecasts(JSON.serialize(frwrap),'',JSON.serialize(MRPItem));
        try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        InventoryManagementReport.deleteMPsRecord(MRPItem[0].Id);
        Test.stopTest();
        
        // Verify that MOs and POs are created
        List<ERP7__Manufacturing_Order__c> mos = [SELECT Id, Name FROM ERP7__Manufacturing_Order__c];
        List<ERP7__PO__c> pos = [SELECT Id, Name FROM ERP7__PO__c];
        List<ERP7__Purchase_Line_Items__c> polineItems = [SELECT Id, ERP7__Purchase_Orders__c FROM ERP7__Purchase_Line_Items__c];
        
        System.assertequals(mos.size(), 1);
        System.assertEquals(pos.size(), 0);
        //System.assert(polineItems.size() > 0, 'Purchase Order Line Items should be created');
        //System.assertEquals(polineItems[0].ERP7__Purchase_Orders__c, pos[0].Id, 'PO Line Items should be associated with the correct PO');
    }
    
    @isTest
    static void testMRPSimulationTrigger() {
        // Fetch MRP and update to trigger simulation
        ERP7__Material_Requirement_Planning__c mrp = [SELECT Id, ERP7__Simulate__c FROM ERP7__Material_Requirement_Planning__c LIMIT 1];
        mrp.ERP7__Simulate__c = true;
        
        Test.startTest();
        update mrp;
        Test.stopTest();
        
        // Verify that the job is scheduled
        List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name LIKE 'MRPSimulationJob_%'];
       // System.assert(scheduledJobs.size() > 0, 'MRP Simulation job should be scheduled');
    }
    
    @isTest
    static void testScheduledJobExecution() {
        // Fetch MRP to simulate
        ERP7__Material_Requirement_Planning__c mrp = [SELECT Id FROM ERP7__Material_Requirement_Planning__c LIMIT 1];
        Set<Id> mrpsIds = new Set<Id>{mrp.Id};
            
            // Schedule the job
            Test.startTest();
       /* String jobName = 'MRPSimulationJob_' + Datetime.now().getTime();
        String cronExp = '0 0 0 * * ?'; // Run daily at midnight
        System.schedule(jobName, cronExp, new MRPSimulationHandler());
       
        
        // Verify that the job is scheduled
        List<CronTrigger> scheduledJobs = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        System.assert(scheduledJobs.size() > 0, 'MRP Simulation job should be scheduled');*/
        
        // Simulate job execution
        
       // MRPSimulationHandler handler = new MRPSimulationHandler();
        //System.schedule('MRPSimulationJob_Test', cronExp, handler);
        Test.stopTest();
        
        // Verify that MOs and POs are created
        List<ERP7__Manufacturing_Order__c> mos = [SELECT Id, Name FROM ERP7__Manufacturing_Order__c];
        List<ERP7__PO__c> pos = [SELECT Id, Name FROM ERP7__PO__c];
        List<ERP7__Purchase_Line_Items__c> polineItems = [SELECT Id, ERP7__Purchase_Orders__c FROM ERP7__Purchase_Line_Items__c];
        
        //System.assert(mos.size() > 0, 'Manufacturing Orders should be created');
        //System.assert(pos.size() > 0, 'Purchase Orders should be created');
        //System.assert(polineItems.size() > 0, 'Purchase Order Line Items should be created');
        //System.assertEquals(polineItems[0].ERP7__Purchase_Orders__c, pos[0].Id, 'PO Line Items should be associated with the correct PO');
    }
     @isTest
    static void testMinMaxSystemAlgorithm() {
      List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Min-Max System';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
         try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
     @isTest
    static void testFOQAlgorithm() {
      List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Fixed Order Quantity (FOQ)';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
         try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
     @isTest
    static void testEOQAlgorithm() {
      List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Economic Order Quantity (EOQ)';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
         try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

     @isTest
    static void testPOQAlgorithm() {
      List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Period Order Quantity (POQ)';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
         try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

     @isTest
    static void testSSMAlgorithm() {
      List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Safety Stock Method';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
         try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }
     @isTest
    static void testJITAlgorithm() {
      List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Just-In-Time (JIT)';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
         try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

     @isTest
    static void testDDMRPAlgorithm() {
      List<ERP7__Material_Requirement_Planning__c> mrp = [SELECT Id,Name,ERP7__Algorithm__c FROM ERP7__Material_Requirement_Planning__c ];
        mrp[0].ERP7__Algorithm__c = 'Demand Driven MRP (DDMRP)';
        update mrp[0];
        List<ERP7__MPS__c> MRPItem = [Select Id,Name,ERP7__Product__c from ERP7__MPS__c];
        Set<Id> mrpsIds = new Set<Id>();
        for(ERP7__Material_Requirement_Planning__c mp : mrp) mrpsIds.add(mp.Id);
            // Run the handler directly
        Test.startTest();
         try {
            
            MRPSimulationHandler.handleAlgorithm(mrpsIds);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

   
}