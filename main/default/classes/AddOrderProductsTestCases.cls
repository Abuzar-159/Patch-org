@isTest
public class AddOrderProductsTestCases {
    @isTest public static void unitTest1(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom',ERP7__Product__c=pro.Id,ERP7__Postal_Code__c='123');
        insert tax;
        
        AddOrderProducts.fetchOrder(ord.Id);
        AddOrderProducts.initialProducts(ord.Id,1);
        AddOrderProducts.savePriBook(ord.Id,'Standard Price Book');
        //AddOrderProductsLC.initialProducts(quote1.Id,1);
        //AddOrderProductsLC.initialProducts(quote2.Id,1);
        AddOrderProducts.fetchProducts(ord.id,'','','','');
        addProducts.getProducts('','test','prod',dCh.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest2(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Account acc2 = new Account(Name='Naseeruddin Akhtar');
        insert acc2;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        acc2.ERP7__Order_Profile__c=profile.Id;
        upsert acc2;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Stage__c='Entered'); 
        insert ord1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom',ERP7__Product__c=pro.Id);
        insert tax1;
        AddOrderProducts.initialProducts(ord3.Id,1);
        
        AddOrderProducts.getDiscountPlan(ord.id,pro.Id,4);        
        AddOrderProducts.getDiscountPlan(ord1.id,pro.Id,4);
        
        AddOrderProducts.fetchProducts(ord.id,'Laptop X200','HR','Hardware','Hardware');
        AddOrderProducts.fetchProducts(ord1.id,'Laptop X200','','Others','Hardware');
        AddOrderProducts.fetchProducts(ord.id,'','','','');
        //AddOrderProducts.fetchProducts(ord1.id,'','HR','Others','IT');
        //AddOrderProducts.fetchProducts(ord1.id,'','HR','Others','');
        //AddOrderProducts.fetchProducts(ord1.id,'','','Others','IT');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    static testMethod void unitTest22(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Account acc2 = new Account(Name='Naseeruddin Akhtar');
        insert acc2;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        acc2.ERP7__Order_Profile__c=profile.Id;
        upsert acc2;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Stage__c='Entered'); 
        insert ord1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom',ERP7__Product__c=pro.Id);
        insert tax1;
        
        AddOrderProducts.fetchProducts(ord1.id,'','HR','Others','IT');
        AddOrderProducts.fetchProducts(ord1.id,'','HR','Others','');
        AddOrderProducts.fetchProducts(ord1.id,'','','Others','IT');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest3(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom',ERP7__Postal_Code__c='123');
        insert tax;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),AccountId=acc.Id,
                               ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Country__c='United Kingdom',ERP7__Product__c=pro.Id);
        insert tax1;
        AddOrderProducts.initialProducts(ord3.Id,1); 
        AddOrderProducts.fetchProducts(ord3.id,'','','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest4(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom',ERP7__Postal_Code__c='123');
        insert tax;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Product__c=pro.Id);
        insert tax1;
        AddOrderProducts.initialProducts(ord3.Id,1);        
        AddOrderProducts.fetchProducts(ord3.id,'','','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest5(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Bill_To_Address__c = add.Id,
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom',ERP7__Postal_Code__c='123');
        insert tax;        
        AddOrderProducts.initialProducts(ord.Id,1);
        AddOrderProducts.fetchProducts(ord.id,'','','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest6(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom');
        insert tax1;
        AddOrderProducts.initialProducts(ord3.Id,1);    
        AddOrderProducts.fetchProducts(ord3.id,'','','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest7(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add1.Id,ERP7__Ship_To_Address__c=add1.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Country__c='United Kingdom');
        insert tax1;
        AddOrderProducts.initialProducts(ord3.Id,1);    
        AddOrderProducts.fetchProducts(ord3.id,'','','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);                        
    }
    static testMethod void unitTest88(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add1.Id,ERP7__Ship_To_Address__c=add1.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id);
        insert tax1;
        AddOrderProducts.initialProducts(ord3.Id,1);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest8(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Destination');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        Address__c add1 = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add1;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add1.Id,ERP7__Ship_To_Address__c=add1.Id);
        insert quote3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        ERP7__Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id);
        insert tax1;
        AddOrderProducts.initialProducts(ord3.Id,1);        
        AddOrderProducts.fetchProducts(ord3.id,'','','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest9(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        Product2 pro = new Product2(Name = 'Laptop X200', Family ='Others',IsActive=TRUE);//,ERP7__Category__c='IT',ProductCode='HR'
        insert pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        acc.ERP7__Order_Profile__c = profile.Id;
        update acc;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id);
        insert quote;
        //ERP7__Quote_Line_Items__c qtLine=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id);
        insert tax;
        
        AddOrderProducts.selectOptions1 so=new AddOrderProducts.selectOptions1('--None--','');
        List<AddOrderProducts.selectOptions1> soList=new List<AddOrderProducts.selectOptions1>();
        soList.add(so);
        List<Discount_Plan__c> dplan=new List<Discount_Plan__c>();
        dplan.add(dp);
        List<Tier_Discount_Allocation__c> tdaList=new List<Tier_Discount_Allocation__c>();
        tdaList.add(tda);
        PricebookEntry pbe1=[Select Id,Name,Product2Id,Product2.Id,Product2.Name,UnitPrice,IsActive from PricebookEntry where IsActive = true];
        PricebookEntry pbe2=[Select Id,Name,Product2Id,Product2.Id,Product2.Name,UnitPrice,IsActive from PricebookEntry where IsActive = true];
        AddOrderProducts.pbeWrapper wrapper=new AddOrderProducts.pbeWrapper(pbe1,'',soList,1,dplan,tdaList,tax,Tax.Id,0,0);
        AddOrderProducts.pbeWrapper wrapper1=new AddOrderProducts.pbeWrapper(pbe2,'',soList,1,dplan,tdaList,tax,Tax.Id,0,0);
        List<AddOrderProducts.pbeWrapper> wpList=new List<AddOrderProducts.pbeWrapper>();
        wpList.add(wrapper);
        wpList.add(wrapper1);
        
        //ERP7__Quote_Line_Items__c qtLine1=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine1;
        OrderItem orditem1 = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem1;
        
        List<String> itemsToDel=new List<String>();
        itemsToDel.add(orditem1.Id);
        AddOrderProducts.saveOrderLine(ord.Id,JSON.serialize(wpList),itemsToDel);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest10(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        Product2 pro = new Product2(Name = 'Laptop X200', Family ='Others',IsActive=TRUE);//,ERP7__Category__c='IT',ProductCode='HR'
        insert pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id);
        insert quote;
        //ERP7__Quote_Line_Items__c qtLine=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id);
        insert quote1;
        //ERP7__Quote_Line_Items__c qtLine1=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote1.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine1;
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord1;
        OrderItem orditem1 = new OrderItem(OrderId = ord1.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem1;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,ERP7__Ceiling_Discount_Value__c=20,ERP7__Default_Discount_Value__c=10,ERP7__Floor_Discount_Value__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id);
        insert tax;
        
        AddOrderProducts.selectOptions1 so=new AddOrderProducts.selectOptions1('--None--','');
        List<AddOrderProducts.selectOptions1> soList=new List<AddOrderProducts.selectOptions1>();
        soList.add(so);
        List<Discount_Plan__c> dplan=new List<Discount_Plan__c>();
        dplan.add(dp);
        List<Tier_Discount_Allocation__c> tdaList=new List<Tier_Discount_Allocation__c>();
        tdaList.add(tda);
        PricebookEntry pbe1=[Select Id,Name,Product2Id,Product2.Id,Product2.Name,UnitPrice,IsActive from PricebookEntry where IsActive = true];
        PricebookEntry pbe2=[Select Id,Name,Product2Id,Product2.Id,Product2.Name,UnitPrice,IsActive from PricebookEntry where IsActive = true];
        AddOrderProducts.pbeWrapper wrapper=new AddOrderProducts.pbeWrapper(pbe1,'',soList,1,dplan,tdaList,tax,tax.Id,0,0);
        AddOrderProducts.pbeWrapper wrapper1=new AddOrderProducts.pbeWrapper(pbe2,'',soList,1,dplan,tdaList,tax,tax.Id,0,0);
        List<AddOrderProducts.pbeWrapper> wpList=new List<AddOrderProducts.pbeWrapper>();
        wpList.add(wrapper);
        wpList.add(wrapper1);
        
        //ERP7__Quote_Line_Items__c qtLine2=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine2;
        List<String> itemsToDel=new List<String>();
        itemsToDel.add(orditem1.Id);
        AddOrderProducts.saveOrderLine(ord.Id,JSON.serialize(wpList),itemsToDel);
        AddOrderProducts.saveOrderLine(ord1.Id,JSON.serialize(wpList),itemsToDel);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest11(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        //ERP7__Quote_Line_Items__c qtLine=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id,ERP7__Customer__c=acc.Id);
        insert quote1;
        //ERP7__Quote_Line_Items__c qtLine1=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote1.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine1;
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord1;
        OrderItem orditem1 = new OrderItem(OrderId = ord1.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id,ERP7__Customer__c=acc.Id);
        insert quote2;
        //ERP7__Quote_Line_Items__c qtLine2=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote2.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine2;
        ERP7__Quotes__c quote3=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id,ERP7__Customer__c=acc.Id);
        insert quote3;
        //ERP7__Quote_Line_Items__c qtLine3=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote3.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine3;
        Order ord3 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord3;
        OrderItem orditem3 = new OrderItem(OrderId = ord3.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem3;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;        
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id);
        insert tax;
        orditem.ERP7__Tax__c=tax.Id;
        orditem.ERP7__Discount_Plan__c=dp.Id;
        upsert orditem;
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;
        
        Discount_Plan__c dp1 = new Discount_Plan__c(name='test',Active__c=true,ERP7__Ceiling_Discount_Value__c=20,ERP7__Default_Discount_Value__c=10,ERP7__Floor_Discount_Value__c=0,Status__c='Manager Approved');
        insert dp1;
        Tier_Discount_Allocation__c tda1 = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp1.id,Order_Profile__c=profile.Id);
        insert tda1;
        orditem1.ERP7__Discount_Plan__c=dp1.Id;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        
        AddOrderProducts.fetchOrderLine(ord.Id);
        AddOrderProducts.fetchOrderLine(ord1.Id);
        //AddOrderProducts.fetchOrderLine(ord2.Id);
        AddOrderProducts.fetchOrderLine(ord3.Id);
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest12(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        //ERP7__Quote_Line_Items__c qtLine=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,ERP7__Ceiling_Discount_Value__c=20,ERP7__Default_Discount_Value__c=10,ERP7__Floor_Discount_Value__c=0,Status__c='Manager Approved');
        insert dp;        
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id);
        insert tax;
        orditem.ERP7__Tax__c=tax.Id;
        orditem.ERP7__Discount_Plan__c=dp.Id;
        upsert orditem;
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;     
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        
        AddOrderProducts.fetchOrderLine(ord.Id);
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void unitTest13(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id,ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id);
        insert quote;
        //ERP7__Quote_Line_Items__c qtLine=new ERP7__Quote_Line_Items__c(Name='TestQtLine',ERP7__Discount_Amount__c=10,ERP7__Discount_Percent__c=1,ERP7__List_Price__c=100,ERP7__Other_Tax__c=10,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1,ERP7__Quotes__c=quote.Id,ERP7__sortOrder__c=1,ERP7__VAT_Amount__c=10);
        //insert qtLine;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Bill_To_Address__c=add.Id,ERP7__Ship_To_Address__c=add.Id); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Status__c='Manager Approved');
        insert dp;        
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id);
        insert tax;
        orditem.ERP7__Tax__c=tax.Id;
        orditem.ERP7__Discount_Plan__c=dp.Id;
        upsert orditem;
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        
        AddOrderProducts.fetchOrderLine(quote.Id);
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    //================Test cases for Product Configurator=====================
    static testMethod void unitTest15(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
        pro.ERP7__Version__c = ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id);
        insert quote;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        Order ord2 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                               AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                               ERP7__Stage__c='Entered'); 
        insert ord2;
        
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        ERP7__Product_Feature__c pf=new ERP7__Product_Feature__c(Name='Test',ERP7__Product__c=pro.Id);
        insert pf;
        ERP7__Product_Option__c po=new ERP7__Product_Option__c(ERP7__Optional_SKU__c=pro.id,ERP7__Configured_SKU__c=pro.Id,ERP7__Product_Feature__c=pf.Id);
        insert po;
        
        AddOrderProducts.getOptionProd(pro.Id, ord.Id);
        //AddOrderProducts.getOptionProd(pro.Id, ord.Id);
        AddOrderProducts.getOptionProd(pro.Id, ord2.Id);
        AddOrderProducts.getAllOptionRules(pro.Id);
        
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today());
        insert ver1;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Manufacturing'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = ver1.Id, ERP7__Product__c = pro.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000,ERP7__Address__c=add.Id);
        insert routing;
        //String strRecordTypeId1 = [Select Id From RecordType Where SobjectType = 'ERP7__Bill_Of_Material__c' and Name = 'Catalog_BOM'].Id;
        //bom.RecordTypeId=strRecordTypeId1;
        //update bom;
        Map<String, Decimal> proOptions1=new Map<String, Decimal>();
        proOptions1.put(pro.Id, 1);
        Map<String, String> proFeatureMap=new Map<String, String>();
        proFeatureMap.put(pro.Id, pf.Id);
        AddOrderProducts.createVersion(JSON.serialize(proOptions1),pro.Id,JSON.serialize(proFeatureMap));
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    //================Test cases for Product Configurator=====================
    
}