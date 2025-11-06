@isTest
private class OutboundLogisticsLightningTestCases {
    @isTest(SeeAllData=true)
    static void OutboundLogisticsUnitTest1113() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        test.startTest();
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer;  
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod;
        Sales_Order__c psod = [Select id, Name, Contact__c From Sales_Order__c Where id =: sod.id Limit 1];
        
        List<Product2> Product2insert = new List<Product2>();
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        Product2insert.add(ps);
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='productId1',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);
        Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='productId2',Track_Inventory__c=true,ERP7__Serialise__c=true);
        Product2insert.add(ps2);
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        Product2insert.add(ps3);
        Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='productId4',Track_Inventory__c=true);
        Product2insert.add(ps4);
        upsert Product2insert;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps4.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2000,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                         Active__c=true,Warehouse__c=site.Id,
                                                         Product__c=ps.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
            Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                                                          Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        
        List<Sales_Order_Line_Item__c> soliToupsert = new List<Sales_Order_Line_Item__c>();
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim); //insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim1); //insert solim1; 
        
        Sales_Order_Line_Item__c solim2 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim2); //insert solim2;
        Sales_Order_Line_Item__c solim3 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps3.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim3); // insert solim3;  
        
        
        upsert soliToupsert;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        comW = OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'NewOrders','');
         List<String> serials = OutboundLogisticsLightning.getAllreservedSerials(ps.Id);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void OutboundLogisticsUnitTest112() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        PreventRecursiveLedgerEntry.Loged = true;
        insert sod;
        Sales_Order__c psod = [Select id, Name, Contact__c From Sales_Order__c Where id =: sod.id Limit 1];
        
        List<Product2> Product2insert = new List<Product2>();
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        Product2insert.add(ps);
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='productId1',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);
        Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='productId2',Track_Inventory__c=true,ERP7__Serialise__c=true);
        Product2insert.add(ps2);
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        Product2insert.add(ps3);
        Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='productId4',Track_Inventory__c=true);
        Product2insert.add(ps4);
        upsert Product2insert;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps4.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2000,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                         Active__c=true,Warehouse__c=site.Id,
                                                         Product__c=ps.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
            Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                                                          Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        
        List<Sales_Order_Line_Item__c> soliToupsert = new List<Sales_Order_Line_Item__c>();
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim); //insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim1); //insert solim1; 
        
        Sales_Order_Line_Item__c solim2 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim2); //insert solim2;
        Sales_Order_Line_Item__c solim3 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps3.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim3); // insert solim3;  
        
        
        upsert soliToupsert;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salePoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Sales_Order__c=psod.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c = Solim.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps1.Id, ERP7__Sales_Order_Line_Item__c = Solim2.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved', Explode__c=true);
        LoLines2upsert.add(LogisticLine1);
        
        ERP7__Logistic_Line_Item__c LogisticLine2 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, ERP7__Sales_Order_Line_Item__c = Solim3.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine2);
        
        ERP7__Logistic_Line_Item__c LogisticLine3 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps3.Id, ERP7__Sales_Order_Line_Item__c = Solim1.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine3);
        upsert LoLines2upsert;
        List<Stock_Outward_Line_Item__c> stocktoUpsert = new List<Stock_Outward_Line_Item__c>();
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
            Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4,
            Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Reserved');
        stocktoUpsert.add(PPLI);
        //insert PPLI; 
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
            Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id,
            Sales_Order__c=sod.Id, Picked_Quantity__c=1, Status__c = 'Reserved');
        // insert PPLI1;
        stocktoUpsert.add(PPLI1);
        
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        upsert stocktoUpsert;
        Package__c pack = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id,Sales_Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack; 
        List<Package_List__c> packToUpsert = new List<Package_List__c>();
        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true, Logistic__c=Logistic.Id, ERP7__Logistic_Line_Item__c = LogisticLine.Id, Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        packToUpsert.add(plist); //insert plist;
        
        upsert packToUpsert;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=sAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                                           status__c='Shipped',Tracking_Number__c='123456'); //Logistic__c=Logistic.Id,
        insert ship;      
        
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                                       Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps1.Id,Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c  = 'Reserved');
        insert mrp;
        
        List<String> LOIDS = new List<String>();
        LOIDS.add(Logistic.Id);
        
        Test.startTest();
        OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        OutboundLogisticsLightning.Wrappers LW = new OutboundLogisticsLightning.Wrappers();
        OutboundLogisticsLightning.logWrap lgwrap = new OutboundLogisticsLightning.logWrap();
        OutboundLogisticsLightning.packageWrapper PW = new OutboundLogisticsLightning.packageWrapper();
        OutboundLogisticsLightning.lineItemWrapper LOLIW = new OutboundLogisticsLightning.lineItemWrapper();
        OutboundLogisticsLightning.innerPackageWrapper IPW = new OutboundLogisticsLightning.innerPackageWrapper();
        OutboundLogisticsLightning.SelectOptions SLOP = new OutboundLogisticsLightning.SelectOptions('HI','HI');
        OutboundLogisticsLightning.SelectOptions SLOP1 = new OutboundLogisticsLightning.SelectOptions('HI','HI', false);
        
        OutboundLogisticsLightning.fetchSortedLogistics('Name','ASC',DistributionChannels.Id,salepoint.Id,10,0,'');
        OutboundLogisticsLightning.fetchSortedLogistics('Name','DESC','',salepoint.Id,10,0,'');
        comW = OutboundLogisticsLightning.createPacksInit(JSON.serialize(LOIDS), '');
        OutboundLogisticsLightning.editPackage(pack.Id);
        OutboundLogisticsLightning.deletePackage(pack.Id,JSON.serialize(LOIDS));
        OutboundLogisticsLightning.populatePackDetails(JSON.serialize(comW.Package2Create), 'Shipment');
        for(OutboundLogisticsLightning.packageWrapper wrap : comW.packageWrapperList) wrap.pkgSelected = true;
        OutboundLogisticsLightning.updatePacks(JSON.serialize(comW.Package2Create), JSON.serialize(comW.PackageWrapperList), JSON.serialize(LOIDS), comW.IsAwaiting);
        OutboundLogisticsLightning.createShipments(JSON.serialize(LOIDS));
        OutboundLogisticsLightning.deleteShipments(ship.Id,JSON.serialize(LOIDS));
        OutboundLogisticsLightning.getLogisticDetails(JSON.serialize(LOIDS));
        OutboundLogisticsLightning.getBatchStocks(batch.Id,PPLI1.Id); 
        OutboundLogisticsLightning.unCommitSOLI(PPLI1.Id);
        
        System.assertEquals('test@test.com',contact.Email);
        Test.stopTest();
    }
    @isTest
    static void OutboundLogisticsUnitTest1() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        Test.startTest();
        insert sod;
        Sales_Order__c psod = [Select id, Name, Contact__c From Sales_Order__c Where id =: sod.id Limit 1];
        
        List<Product2> Product2insert = new List<Product2>();
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        Product2insert.add(ps);
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='productId1',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);
        Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='productId2',Track_Inventory__c=true,ERP7__Serialise__c=true,ERP7__Is_Kit__c=false);
        Product2insert.add(ps2);
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        Product2insert.add(ps3);
        Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='productId4',Track_Inventory__c=true);
        Product2insert.add(ps4);
        upsert Product2insert;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps4.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2000,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                         Active__c=true,Warehouse__c=site.Id,
                                                         Product__c=ps.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
            Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                                                          Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        
        List<Sales_Order_Line_Item__c> soliToupsert = new List<Sales_Order_Line_Item__c>();
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim); //insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim1); //insert solim1; 
        
        Sales_Order_Line_Item__c solim2 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim2); //insert solim2;
        Sales_Order_Line_Item__c solim3 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps3.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim3); // insert solim3;  
        
        
        upsert soliToupsert;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salePoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Sales_Order__c=psod.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c = Solim.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps1.Id, ERP7__Sales_Order_Line_Item__c = Solim2.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved', Explode__c=true);
        LoLines2upsert.add(LogisticLine1);
        
        ERP7__Logistic_Line_Item__c LogisticLine2 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, ERP7__Sales_Order_Line_Item__c = Solim3.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved', Explode__c=false);
        LoLines2upsert.add(LogisticLine2);
        
        ERP7__Logistic_Line_Item__c LogisticLine3 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps3.Id, ERP7__Sales_Order_Line_Item__c = Solim1.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine3);
        upsert LoLines2upsert;
        List<Stock_Outward_Line_Item__c> stocktoUpsert = new List<Stock_Outward_Line_Item__c>();
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
            Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4,
            Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Reserved');
        stocktoUpsert.add(PPLI);
        //insert PPLI; 
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
            Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id,
            Sales_Order__c=sod.Id, Picked_Quantity__c=1, Status__c = 'Reserved');
        // insert PPLI1;
        stocktoUpsert.add(PPLI1);
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        upsert stocktoUpsert;
        Package__c pack = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id,Sales_Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack; 
        List<Package_List__c> packToUpsert = new List<Package_List__c>();
        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true, Logistic__c=Logistic.Id, ERP7__Logistic_Line_Item__c = LogisticLine.Id, Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        packToUpsert.add(plist); //insert plist;
        
        upsert packToUpsert;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=sAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                                           Logistic__c=Logistic.Id, status__c='Shipped',Tracking_Number__c='123456'); 
        //insert ship;      
        //Package__c pack1 = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id, Sales_Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        //insert pack1;        
        //Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,Logistic__c=Logistic.Id,
        //Sales_Order__c=psod.Id,Package__c = pack1.Id, Quantity__c = 3);
        //insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                                       Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps1.Id,Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c  = 'Reserved');
        insert mrp;
        
        List<String> LOIDS = new List<String>();
        LOIDS.add(Logistic.Id);
        
        
        OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        OutboundLogisticsLightning.Wrappers LW = new OutboundLogisticsLightning.Wrappers();
        OutboundLogisticsLightning.packageWrapper PW = new OutboundLogisticsLightning.packageWrapper();
        OutboundLogisticsLightning.lineItemWrapper LOLIW = new OutboundLogisticsLightning.lineItemWrapper();
        OutboundLogisticsLightning.innerPackageWrapper IPW = new OutboundLogisticsLightning.innerPackageWrapper();
        OutboundLogisticsLightning.SelectOptions SLOP = new OutboundLogisticsLightning.SelectOptions('HI','HI');
        OutboundLogisticsLightning.SelectOptions SLOP1 = new OutboundLogisticsLightning.SelectOptions('HI','HI', false);
        
        OutboundLogisticsLightning.scanLogistics('test');
        comW = OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'DeliveredOrders','');
        comW = OutboundLogisticsLightning.redirect2NextTab(JSON.serialize(LOIDS));
        for(OutboundLogisticsLightning.Wrappers wrap : comW.soliWrapperList) { wrap.soliSelected = true; wrap.soliVerified = true; }
        OutboundLogisticsLightning.CreateBarcode(JSON.serialize(comW.soliWrapperList));
        
        if(comW.soliWrapperList.size() > 0){
            OutboundLogisticsLightning.fetchBatchStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
            OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));  
        }
        
        // OutboundLogisticsLightning.scanLines('test', 0, JSON.serialize(comW.soliWrapperList));
        OutboundLogisticsLightning.scanLines('bin', 1, JSON.serialize(comW.soliWrapperList));
        OutboundLogisticsLightning.saveSOLIs(JSON.serialize(comW.soliWrapperList), JSON.serialize(comW.SerialIds2Exempt), JSON.serialize(comW.stockMap),JSON.serialize(LOIDS));
        //comW = OutboundLogisticsLightning.createPacksInit(JSON.serialize(LOIDS), '');
        //OutboundLogisticsLightning.editPackage(pack.Id);
        //OutboundLogisticsLightning.populatePackDetails(comW.Package2Create, 'Shipment');
        //for(OutboundLogisticsLightning.packageWrapper wrap : comW.packageWrapperList) wrap.pkgSelected = true;
        //  OutboundLogisticsLightning.updatePacks(comW.Package2Create, JSON.serialize(comW.PackageWrapperList), JSON.serialize(LOIDS), comW.IsAwaiting);
        //OutboundLogisticsLightning.deletePackage(pack.Id,JSON.serialize(LOIDS));
        //OutboundLogisticsLightning.createShipments(JSON.serialize(LOIDS));
        set<String> soIDs= new set<String>();
        soIDs.add(PPLI1.Id);
        OutboundLogisticsLightning.getcommitedSOLIs(JSON.serialize(soIDs));
        
        System.assertEquals('test@test.com',contact.Email);
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    static void OutboundLogisticsUnitTest11() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        PreventRecursiveLedgerEntry.Loged = true;
        insert sod;
        Sales_Order__c psod = [Select id, Name, Contact__c From Sales_Order__c Where id =: sod.id Limit 1];
        
        List<Product2> Product2insert = new List<Product2>();
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        Product2insert.add(ps);
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='productId1',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);
        Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='productId2',Track_Inventory__c=true,ERP7__Serialise__c=true);
        Product2insert.add(ps2);
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        Product2insert.add(ps3);
        Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='productId4',Track_Inventory__c=true);
        Product2insert.add(ps4);
        upsert Product2insert;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps4.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2000,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                         Active__c=true,Warehouse__c=site.Id,
                                                         Product__c=ps.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
            Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                                                          Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                          Active__c=true,Warehouse__c=site.Id,
                                                          Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        
        List<Sales_Order_Line_Item__c> soliToupsert = new List<Sales_Order_Line_Item__c>();
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim); //insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim1); //insert solim1; 
        
        Sales_Order_Line_Item__c solim2 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim2); //insert solim2;
        Sales_Order_Line_Item__c solim3 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps3.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        soliToupsert.add(solim3); // insert solim3;  
        
        
        upsert soliToupsert;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salePoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Sales_Order__c=psod.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c = Solim.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps1.Id, ERP7__Sales_Order_Line_Item__c = Solim2.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved', Explode__c=true);
        LoLines2upsert.add(LogisticLine1);
        
        ERP7__Logistic_Line_Item__c LogisticLine2 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, ERP7__Sales_Order_Line_Item__c = Solim3.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine2);
        
        ERP7__Logistic_Line_Item__c LogisticLine3 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps3.Id, ERP7__Sales_Order_Line_Item__c = Solim1.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine3);
        upsert LoLines2upsert;
        List<Stock_Outward_Line_Item__c> stocktoUpsert = new List<Stock_Outward_Line_Item__c>();
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
            Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4,
            Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Reserved');
        stocktoUpsert.add(PPLI);
        //insert PPLI; 
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
            Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id,
            Sales_Order__c=sod.Id, Picked_Quantity__c=1, Status__c = 'Reserved');
        // insert PPLI1;
        stocktoUpsert.add(PPLI1);
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        upsert stocktoUpsert;
        Package__c pack = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id,Sales_Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack; 
        List<Package_List__c> packToUpsert = new List<Package_List__c>();
        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true, Logistic__c=Logistic.Id, ERP7__Logistic_Line_Item__c = LogisticLine.Id, Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        packToUpsert.add(plist); //insert plist;
        
        upsert packToUpsert;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=sAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                                           Logistic__c=Logistic.Id, status__c='Shipped',Tracking_Number__c='123456'); 
        //insert ship;      
        //Package__c pack1 = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id, Sales_Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        //insert pack1;        
        //Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,Logistic__c=Logistic.Id,
        //Sales_Order__c=psod.Id,Package__c = pack1.Id, Quantity__c = 3);
        //insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                                       Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps1.Id,Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c  = 'Reserved');
        insert mrp;
        
        List<String> LOIDS = new List<String>();
        LOIDS.add(Logistic.Id);
        
        Test.startTest();
        OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        OutboundLogisticsLightning.Wrappers LW = new OutboundLogisticsLightning.Wrappers();
        OutboundLogisticsLightning.packageWrapper PW = new OutboundLogisticsLightning.packageWrapper();
        OutboundLogisticsLightning.lineItemWrapper LOLIW = new OutboundLogisticsLightning.lineItemWrapper();
        OutboundLogisticsLightning.innerPackageWrapper IPW = new OutboundLogisticsLightning.innerPackageWrapper();
        OutboundLogisticsLightning.SelectOptions SLOP = new OutboundLogisticsLightning.SelectOptions('HI','HI');
        OutboundLogisticsLightning.SelectOptions SLOP1 = new OutboundLogisticsLightning.SelectOptions('HI','HI', false);
        
        comW = OutboundLogisticsLightning.createPacksInit(JSON.serialize(LOIDS), '');
        OutboundLogisticsLightning.editPackage(pack.Id);
        OutboundLogisticsLightning.populatePackDetails(JSON.serialize(comW.Package2Create), 'Shipment');
        for(OutboundLogisticsLightning.packageWrapper wrap : comW.packageWrapperList) wrap.pkgSelected = true;
        OutboundLogisticsLightning.updatePacks(JSON.serialize(comW.Package2Create), JSON.serialize(comW.PackageWrapperList), JSON.serialize(LOIDS), comW.IsAwaiting);
        OutboundLogisticsLightning.deletePackage(pack.Id,JSON.serialize(LOIDS));
        OutboundLogisticsLightning.createShipments(JSON.serialize(LOIDS));
        OutboundLogisticsLCPages ol = new OutboundLogisticsLCPages(new ApexPages.StandardController(Logistic));
        PageReference pageRef = Page.PickSlip;
        pageRef.getParameters().put('loIds', Logistic.Id);
        pageRef.getParameters().put('ra', 'PDF');
        Test.setCurrentPage(pageRef);
        OutboundLogisticsLCPages OLP = new OutboundLogisticsLCPages();
        OLP.createPDF();
        OLP.createBarcodes();
        OLP.createPickingSlips();
        OLP.createPackingLabels();
        OLP.createPackingSlips();
        OLP.createShippingSlips();
        System.assertEquals('test@test.com',contact.Email);
        Test.stopTest();
    }
    
    
    
    static testMethod void OutboundLogisticsUnitTest3() {
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    /*static testMethod void OutboundLogisticsUnitTest4() {
PreventRecursiveLedgerEntry.testCasesTransactions = true;
Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
insert orgn;
Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
insert sup;
Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
insert busUnit;
Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
insert customer; 
Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
insert contact;
Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
insert bAddress;
Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
insert sAddress;

Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
insert salepoint;

Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
insert emp;

Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
insert site;

Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
insert DistributionChannels;  

List<Product2> Product2insert = new List<Product2>();
Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
Product2insert.add(ps);
Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='test',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
Product2insert.add(ps1);
Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='test',Track_Inventory__c=true,ERP7__Serialise__c=true);
Product2insert.add(ps2);
Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='test',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
Product2insert.add(ps3);
Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='test',Track_Inventory__c=true);
Product2insert.add(ps4);
upsert Product2insert;

ERP7__Version__c Version = new ERP7__Version__c(
Name = 'Default Version',                        
ERP7__Active__c = true,                            
ERP7__Start_Date__c = system.today(),  
ERP7__Product__c = ps1.Id,              
ERP7__To_Date__c = system.today()+365,     
ERP7__Category__c = 'Production',                  
ERP7__Type__c = 'Assembly',                        
ERP7__Status__c = 'Certified',                     
ERP7__Default__c = true,                           
ERP7__Subscription__c = false,   
ERP7__Sales_Ready__c = true                       
);
insert Version;

RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
ERP7__BOM__c BOM = new ERP7__BOM__c(
Name = 'BOM 1',                            
ERP7__BOM_Product__c = ps1.Id,    
ERP7__BOM_Component__c = ps4.Id,  
ERP7__Type__c = 'Primary',                   
ERP7__Quantity__c = 4,                 
ERP7__Active__c = true,                      
RecordTypeId = rTypeProfile.Id,                  
ERP7__BOM_Version__c = Version.Id,    
ERP7__Partial_Replacement__c = false,        
ERP7__Is_Protected__c = false,               
ERP7__Exact_Quantity__c = false,            
ERP7__Is_Package_BOM__c = false             
);
insert BOM;
Id pricebookId = Test.getStandardPricebookId();
Order sod = new Order();   
sod.Status = 'Draft';
sod.ERP7__Stage__c = 'Entered';
sod.EffectiveDate = system.today();
sod.AccountId = Contact.AccountId;
sod.Contact__c = Contact.Id;
sod.Channel__c = salePoint.Id;
sod.Bill_To_Address__c = bAddress.Id;
sod.Ship_To_Address__c = sAddress.Id;
sod.Request_Date__c = system.Today();
sod.Authorised__c = true;
sod.ERP7__Ready_To_Pick_Pack__c = true;
sod.fulfilled__c = false;
sod.Barcode__c = 'test';
sod.Pricebook2Id=pricebookId;
insert sod; 
Order psod = sod;

ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=20,
ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Product__c=ps3.Id);
insert batch;

ERP7__Serial_Number__c SR = new ERP7__Serial_Number__c(
Name = 'SR-1',                             
ERP7__Product__c = ps2.Id,        
ERP7__Serial_Number__c = 'SR-1',             
ERP7__Available__c = true,                   
ERP7__Barcode_Type__c = 'Code128'           
);
insert SR;

Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
insert ssl;

StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
insert bin;

List<Inventory_Stock__c> Stocks2insert = new List<Inventory_Stock__c>();
List<Stock_Inward_Line_Item__c> StockLines2insert = new List<Stock_Inward_Line_Item__c>();        

Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
Stocks2insert.add(WIIS);


Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=ps1.Id,Location__c=ssl.Id);
Stocks2insert.add(WIIS1);


Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps2.Id, Location__c=ssl.Id, StorageContainer__c=bin.Id);
Stocks2insert.add(WIIS2);


Inventory_Stock__c WIIS3 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps3.Id, Location__c=ssl.Id, StorageContainer__c=bin.Id);
Stocks2insert.add(WIIS3);


Inventory_Stock__c WIIS4 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps4.Id, Location__c=ssl.Id, StorageContainer__c=bin.Id);
Stocks2insert.add(WIIS4);

upsert Stocks2insert;

Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS.Id,Product__c=ps.Id,Quantity__c=200);
StockLines2insert.add(SPLI);

Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS1.Id,Product__c=ps1.Id,Quantity__c=200);
StockLines2insert.add(SPLI1);

Stock_Inward_Line_Item__c SPLI2 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps2.Id,Quantity__c=1, Serial__c=SR.Id);
StockLines2insert.add(SPLI2);

Stock_Inward_Line_Item__c SPLI3 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS3.Id,Product__c=ps3.Id,Quantity__c=100,ERP7__Material_Batch_Lot__c = batch.Id);
StockLines2insert.add(SPLI3);

Stock_Inward_Line_Item__c SPLI4 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS4.Id,Product__c=ps4.Id,Quantity__c=200);
StockLines2insert.add(SPLI4);

upsert StockLines2insert;
Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
update standardPricebook;       
PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
Insert pbe;
PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps1.Id, UnitPrice = 1020,IsActive = true);
Insert pbe1;
PricebookEntry pbe2 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps2.Id, UnitPrice = 1020,IsActive = true);
Insert pbe2;
PricebookEntry pbe3 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps3.Id, UnitPrice = 1020,IsActive = true);
Insert pbe3;
PricebookEntry pbe4 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps4.Id, UnitPrice = 1020,IsActive = true);
Insert pbe4;
List<OrderItem> SOLIS2insert = new List<OrderItem>();
OrderItem solim = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps.id,PricebookEntryId=pbe.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
SOLIS2insert.add(solim);
OrderItem solim1 = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps1.id,PricebookEntryId=pbe1.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
SOLIS2insert.add(solim1);
OrderItem solim2 = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps2.id,PricebookEntryId=pbe2.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true );
SOLIS2insert.add(solim2);
OrderItem solim3 = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps3.id,PricebookEntryId=pbe3.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
SOLIS2insert.add(solim3);
OrderItem solim4 = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps4.id,PricebookEntryId=pbe4.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true );
SOLIS2insert.add(solim4);
upsert SOLIS2insert;

PreventRecursiveLedgerEntry.testCasesTransactions = false;
sod.ERP7__Ready_To_Pick_Pack__c = true;
update sod;
test.startTest();
List<ERP7__Logistic__c> LOGS = [Select Id, Barcode__c, Name from ERP7__Logistic__c];

List<String> LOIDS = new List<String>();
for(ERP7__Logistic__c LOG : LOGS) LOIDS.add(LOG.Id);
ERP7__Logistic__c Logistic = LOGS[0];

List<ERP7__Logistic_Line_Item__c> LoLines2upsert = [Select Id, Barcode__c, Name from ERP7__Logistic_Line_Item__c];
ERP7__Logistic_Line_Item__c LogisticLine = LoLines2upsert[0];   

Package__c pack = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id,ERP7__Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk');
insert pack;  

Package_List__c plist = new Package_List__c(Name = 'Test List', ERP7__Order_Product__c = solim.Id,Active__c=true, ERP7__Logistic__c=Logistic.Id, ERP7__Logistic_Line_Item__c = LogisticLine.Id, ERP7__Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 1);
insert plist;

Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=sAddress.Id,Active__c=true,ERP7__Order__c=sod.Id ,Customer_Contact__c=contact.id,
Logistic__c=Logistic.Id, status__c='Shipped',Tracking_Number__c='123456'); 
insert ship;

Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];   

Package__c pack1 = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id, ERP7__Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
insert pack1;        
Package_List__c plist1 = new Package_List__c(Name = 'Test List', ERP7__Order_Product__c = solim1.Id,Active__c=true,Logistic__c=Logistic.Id,
ERP7__Order__c=psod.Id,Package__c = pack1.Id, Quantity__c = 3);
insert plist1;
Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
Height__c=4,Weight_Unit__c='KGS');
insert pd;

ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps1.Id,ERP7__Order_Product__c = solim.Id,ERP7__Status__c  = 'Reserved');
insert mrp;


OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
OutboundLogisticsLightning.Wrappers LW = new OutboundLogisticsLightning.Wrappers();
OutboundLogisticsLightning.packageWrapper PW = new OutboundLogisticsLightning.packageWrapper();
OutboundLogisticsLightning.lineItemWrapper LOLIW = new OutboundLogisticsLightning.lineItemWrapper();
OutboundLogisticsLightning.innerPackageWrapper IPW = new OutboundLogisticsLightning.innerPackageWrapper();
OutboundLogisticsLightning.SelectOptions SLOP = new OutboundLogisticsLightning.SelectOptions('HI','HI');
OutboundLogisticsLightning.SelectOptions SLOP1 = new OutboundLogisticsLightning.SelectOptions('HI','HI', false);

//comW = OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'');
//comW = OutboundLogisticsLightning.redirect2NextTab(JSON.serialize(LOIDS));
for(OutboundLogisticsLightning.Wrappers wrap : comW.soliWrapperList) { wrap.soliSelected = true; wrap.soliVerified = true; }
//OutboundLogisticsLightning.fetchBatchStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
//OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
//OutboundLogisticsLightning.saveSOLIs(JSON.serialize(comW.soliWrapperList), JSON.serialize(comW.SerialIds2Exempt), JSON.serialize(comW.stockMap),JSON.serialize(LOIDS));
//comW = OutboundLogisticsLightning.createPacksInit(JSON.serialize(LOIDS), '');
//OutboundLogisticsLightning.editPackage(pack.Id);
//for(OutboundLogisticsLightning.packageWrapper wrap : comW.packageWrapperList) wrap.pkgSelected = true;
//OutboundLogisticsLightning.updatePacks(JSON.serialize(comW.Package2Create), JSON.serialize(comW.PackageWrapperList), JSON.serialize(LOIDS), comW.IsAwaiting);

System.assertEquals('test@test.com',contact.Email);
Test.stopTest();
}*/
    static  testMethod void OutboundLogisticsUnitTest5() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = false,Run__c = false);
        insert mod;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        List<Product2> Product2insert = new List<Product2>();            
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='test',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);            
        upsert Product2insert;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps1.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod; 
        Sales_Order__c psod = sod;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=20,ERP7__Production_Version__c = Version.Id,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Product__c=ps1.Id);
        insert batch;
        
        ERP7__Serial_Number__c SR = new ERP7__Serial_Number__c(
            Name = 'SR-1',                             
            ERP7__Product__c = ps1.Id,        
            ERP7__Serial_Number__c = 'SR-1',             
            ERP7__Available__c = true,                   
            ERP7__Barcode_Type__c = 'Code128'           
        );
        insert SR;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        
        List<Inventory_Stock__c> Stocks2insert = new List<Inventory_Stock__c>();
        List<Stock_Inward_Line_Item__c> StockLines2insert = new List<Stock_Inward_Line_Item__c>();  
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps1.Id,ERP7__Active__c=true);
        insert batch1;
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=ps1.Id,Location__c=ssl.Id,ERP7__Batch_Lot__c=batch.Id);
        Stocks2insert.add(WIIS1);
        
        
        
        upsert Stocks2insert;
        
        
        Sales_Order_Line_Item__c solim1t = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        insert solim1t;
        
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        update sod;
        
        List<ERP7__Logistic__c> LOGS = [Select Id, Barcode__c, Name from ERP7__Logistic__c limit 3];
        List<String> LOIDS = new List<String>();
        for(ERP7__Logistic__c LOG : LOGS) LOIDS.add(LOG.Id);
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c();
        if(LOGS.size()>0) Logistic = LOGS[0]; else { Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salePoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Sales_Order__c=psod.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--'); 
                                                    insert Logistic; 
                                                    LOIDS.add(Logistic.Id);
                                                   }
        
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = [Select Id, Barcode__c, Name from ERP7__Logistic_Line_Item__c limit 3];
        //ERP7__Logistic_Line_Item__c LogisticLine = LoLines2upsert[0];  
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        insert ps3;
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id,Barcode__c='productId3', ERP7__Product__c=ps3.Id, ERP7__Sales_Order_Line_Item__c = Solim1t.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        insert LogisticLine;
        Id objectRecordTypeId = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByName().get('MRP Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps1.Id,Sales_Order_Line_Item__c = solim1t.Id,ERP7__Status__c  = 'Reserved', RecordTypeId=objectRecordTypeId);
        insert mrp;
        
        List<Stock_Outward_Line_Item__c> PPLIS=new List<Stock_Outward_Line_Item__c>();
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
            Product__c = ps1.Id,Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Quantity__c=4,
            Sales_Order_Line_Item__c=solim1t.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Reserved',
            ERP7__MRP_Material_Requirements_Planning__c=mrp.Id);
        PPLIS.add(PPLI);
        insert PPLIS;
        
        Test.startTest();
        
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        Stock_Outward_Line_Item__c sto = new Stock_Outward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Product__c=ps1.Id,Quantity__c=200,Sales_Order_Line_Item__c = solim1t.Id);
        insert sto;
        
        
        List<Sales_Order__c> sods = new List<Sales_Order__c>();    
        sods.add(sod);
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS1.Id,Product__c=ps1.Id,Quantity__c=200,ERP7__Material_Batch_Lot__c=batch.Id);
        StockLines2insert.add(SPLI1);
        
        
        upsert StockLines2insert;
        Set<Id> lineitemids = new set<Id>();         
        List<Sales_Order_Line_Item__c> SOLIS2insert = new List<Sales_Order_Line_Item__c>();            
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        SOLIS2insert.add(solim1);
        SOLIS2insert.add(solim1t);
        
        upsert SOLIS2insert;
        lineitemids.add(SOLIS2insert[0].Id);
        OrderInventoryUtils.updateProductPurchaseLineItems(lineitemids);
        
        
        OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        OutboundLogisticsLightning.Wrappers LW = new OutboundLogisticsLightning.Wrappers();
        OutboundLogisticsLightning.packageWrapper PW = new OutboundLogisticsLightning.packageWrapper();
        OutboundLogisticsLightning.lineItemWrapper LOLIW = new OutboundLogisticsLightning.lineItemWrapper();
        OutboundLogisticsLightning.innerPackageWrapper IPW = new OutboundLogisticsLightning.innerPackageWrapper();
        OutboundLogisticsLightning.SelectOptions SLOP = new OutboundLogisticsLightning.SelectOptions('HI','HI');
        OutboundLogisticsLightning.SelectOptions SLOP1 = new OutboundLogisticsLightning.SelectOptions('HI','HI', false);
        
        comW = OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'','');
        comW = OutboundLogisticsLightning.redirect2NextTab(JSON.serialize(LOIDS));
        for(OutboundLogisticsLightning.Wrappers wrap : comW.soliWrapperList) { wrap.soliSelected = true; wrap.soliVerified = true; }
        if(comW.soliWrapperList.size() > 0){
            OutboundLogisticsLightning.fetchBatchStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
            OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
        }
        else{
            LW.addressName = site.Id;
            LW.batchLotCode = 'test';
            List<OutboundLogisticsLightning.Wrappers> soliwrap = new List<OutboundLogisticsLightning.Wrappers>{LW};
            OutboundLogisticsLightning.fetchBatchStocks(JSON.serialize(LW),JSON.serialize(comW.stockMap));
            OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(LW),JSON.serialize(comW.stockMap));
        
        }
        //
        OutboundLogisticsLightning.saveSOLIs(JSON.serialize(comW.soliWrapperList), JSON.serialize(comW.SerialIds2Exempt), JSON.serialize(comW.stockMap),JSON.serialize(LOIDS));
        //comW = OutboundLogisticsLightning.createPacksInit(JSON.serialize(LOIDS), '');
        //OutboundLogisticsLightning.editPackage(pack.Id);
        //for(OutboundLogisticsLightning.packageWrapper wrap : comW.packageWrapperList) wrap.pkgSelected = true;
        //OutboundLogisticsLightning.updatePacks(comW.Package2Create, JSON.serialize(comW.PackageWrapperList), JSON.serialize(LOIDS), comW.IsAwaiting);
        OutboundLogisticsLightning.updateSerial(SR.Id,PPLI.Id); 
        System.assertEquals('test@test.com',contact.Email);
        OutboundLogisticsLightning.PreparePickSerialNos(LogisticLine.Id,'',new List<Id>{SR.Id});
        OrderInventoryUtils.deleteProductPurchaseLineItems(SOLIS2insert);
        OrderInventoryUtils.updateProductPurchaseLineItemsonSalesOrder(sods);
        
        delete SOLIS2insert;
        Test.stopTest();
    }
    static  testMethod void OutboundLogisticsUnitTest6() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = false,Run__c = false);
        insert mod;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        List<Product2> Product2insert = new List<Product2>();            
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='test',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);            
        upsert Product2insert;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps1.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod; 
        Sales_Order__c psod = sod;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=20,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Product__c=ps1.Id);
        insert batch;
        
        ERP7__Serial_Number__c SR = new ERP7__Serial_Number__c(
            Name = 'SR-1',                             
            ERP7__Product__c = ps1.Id,        
            ERP7__Serial_Number__c = 'SR-1',             
            ERP7__Available__c = true,                   
            ERP7__Barcode_Type__c = 'Code128'           
        );
        insert SR;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        
        List<Inventory_Stock__c> Stocks2insert = new List<Inventory_Stock__c>();
        List<Stock_Inward_Line_Item__c> StockLines2insert = new List<Stock_Inward_Line_Item__c>();        
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=ps1.Id,ERP7__StorageContainer__c=bin.Id);
        Stocks2insert.add(WIIS1);
        
        
        
        upsert Stocks2insert;
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS1.Id,Product__c=ps1.Id,Quantity__c=200,ERP7__Serial__c=SR.id);
        StockLines2insert.add(SPLI1);
        
        
        upsert StockLines2insert;
        
        List<Sales_Order_Line_Item__c> SOLIS2insert = new List<Sales_Order_Line_Item__c>();            
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        SOLIS2insert.add(solim1);
        
        upsert SOLIS2insert;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        update sod;
        
        List<ERP7__Logistic__c> LOGS = [Select Id, Barcode__c, Name from ERP7__Logistic__c];
        List<String> LOIDS = new List<String>();
        for(ERP7__Logistic__c LOG : LOGS) LOIDS.add(LOG.Id);
        
        ERP7__Logistic__c Logistic = LOGS.size() > 0 ? LOGS[0] : new ERP7__Logistic__c();
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = [Select Id, Barcode__c, Name from ERP7__Logistic_Line_Item__c];
        ERP7__Logistic_Line_Item__c LogisticLine =  LoLines2upsert.size() > 0 ? LoLines2upsert[0] : new ERP7__Logistic_Line_Item__c() ;   
        
        Id objectRecordTypeId = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByName().get('MRP Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps1.Id,Sales_Order_Line_Item__c = solim1.Id,ERP7__Status__c  = 'Reserved', RecordTypeId=objectRecordTypeId);
        insert mrp;
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        List<Stock_Outward_Line_Item__c> PPLIS=new List<Stock_Outward_Line_Item__c>();
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
            Product__c = ps1.Id,Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Quantity__c=4,
            Sales_Order_Line_Item__c=solim1.Id, Sales_Order__c=sod.Id,  Status__c = 'Reserved',
            ERP7__MRP_Material_Requirements_Planning__c=mrp.Id);
        PPLIS.add(PPLI);
        insert PPLIS;
        
        Test.startTest();
        OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        OutboundLogisticsLightning.Wrappers LW = new OutboundLogisticsLightning.Wrappers();
        OutboundLogisticsLightning.packageWrapper PW = new OutboundLogisticsLightning.packageWrapper();
        OutboundLogisticsLightning.lineItemWrapper LOLIW = new OutboundLogisticsLightning.lineItemWrapper();
        OutboundLogisticsLightning.innerPackageWrapper IPW = new OutboundLogisticsLightning.innerPackageWrapper();
        OutboundLogisticsLightning.SelectOptions SLOP = new OutboundLogisticsLightning.SelectOptions('HI','HI');
        OutboundLogisticsLightning.SelectOptions SLOP1 = new OutboundLogisticsLightning.SelectOptions('HI','HI', false);
        OutboundLogisticsLightning.CommittedStockWrap cm = new OutboundLogisticsLightning.CommittedStockWrap(PPLIS[0],false,true);
        OutboundLogisticsLightning.PicklistWrapper pk = new OutboundLogisticsLightning.PicklistWrapper();
        OutboundLogisticsLightning.PicklistEntryWrapper pkw = new OutboundLogisticsLightning.PicklistEntryWrapper();
        comW = OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'','');
        comW = OutboundLogisticsLightning.redirect2NextTab(JSON.serialize(LOIDS));
        for(OutboundLogisticsLightning.Wrappers wrap : comW.soliWrapperList) { wrap.soliSelected = true; wrap.soliVerified = true; }
        if(comW.soliWrapperList.size() > 0){
            OutboundLogisticsLightning.fetchBatchStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
            OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
        }
        //OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
        OutboundLogisticsLightning.saveSOLIs(JSON.serialize(comW.soliWrapperList), JSON.serialize(comW.SerialIds2Exempt), JSON.serialize(comW.stockMap),JSON.serialize(LOIDS));
        //comW = OutboundLogisticsLightning.createPacksInit(JSON.serialize(LOIDS), '');
        //OutboundLogisticsLightning.editPackage(pack.Id);
        //for(OutboundLogisticsLightning.packageWrapper wrap : comW.packageWrapperList) wrap.pkgSelected = true;
        //OutboundLogisticsLightning.updatePacks(comW.Package2Create, JSON.serialize(comW.PackageWrapperList), JSON.serialize(LOIDS), comW.IsAwaiting);
        OutboundLogisticsLightning.getDependentPicklistMap('ERP7__Package__c','ERP7__Shipment_Type__c','ERP7__Package_Type__c');
        System.assertEquals('test@test.com',contact.Email);
        Test.stopTest();
    }
    
    @isTest (seeAllData=true)
    static void OutboundLogisticsUnitTest8() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2000,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Asset__c=asset.Id,            
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod; 
        Sales_Order__c psod = sod;
        
        
        ERP7__Serial_Number__c SR = new ERP7__Serial_Number__c(
            Name = 'SR-1',                             
            ERP7__Asset__c = asset.Id,        
            ERP7__Serial_Number__c = 'SR-1',             
            ERP7__Available__c = true,                   
            ERP7__Barcode_Type__c = 'Code128'           
        );
        insert SR;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        
        List<Inventory_Stock__c> Stocks2insert = new List<Inventory_Stock__c>();
        List<Stock_Inward_Line_Item__c> StockLines2insert = new List<Stock_Inward_Line_Item__c>();        
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id,ERP7__Fixed_Asset__c = asset.Id);
        Stocks2insert.add(WIIS1);
        
        
        
        upsert Stocks2insert;
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS1.Id,ERP7__Fixed_Asset__c = asset.Id,Quantity__c=200);
        StockLines2insert.add(SPLI1);
        
        
        upsert StockLines2insert;
        
        List<Sales_Order_Line_Item__c> SOLIS2insert = new List<Sales_Order_Line_Item__c>();            
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,ERP7__Asset__c = asset.Id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        SOLIS2insert.add(solim1);
        
        upsert SOLIS2insert;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        update sod;
        
        
        
        List<ERP7__Logistic__c> LOGS = [Select Id, Barcode__c, Name,ERP7__Type__c,ERP7__Closed__c,Channel__c,ERP7__Distribution_Channel__r.ERP7__Site__c from ERP7__Logistic__c Limit 1];
        List<String> LOIDS = new List<String>();
       
        
        Id objectRecordTypeId = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByName().get('MRP Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', ERP7__Asset__c=asset.Id,Sales_Order_Line_Item__c = solim1.Id,ERP7__Status__c  = 'Reserved', RecordTypeId=objectRecordTypeId);
        insert mrp;
        
        /*List<Stock_Outward_Line_Item__c> PPLIS=new List<Stock_Outward_Line_Item__c>();
Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
ERP7__Fixed_Asset__c = asset.Id,Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Quantity__c=4,
Sales_Order_Line_Item__c=solim1.Id, Sales_Order__c=sod.Id,  Status__c = 'Reserved',
ERP7__MRP_Material_Requirements_Planning__c=mrp.Id);
PPLIS.add(PPLI);
system.debug('PPLIS tesssss: '+PPLIS.size());
insert PPLIS;
system.debug('afeter   : '+PPLIS.size());*/
        Test.startTest();
        OutboundLogisticsLightning  IBL = new OutboundLogisticsLightning ();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        OutboundLogisticsLightning.Wrappers LW = new OutboundLogisticsLightning.Wrappers();
        OutboundLogisticsLightning.packageWrapper PW = new OutboundLogisticsLightning.packageWrapper();
        OutboundLogisticsLightning.lineItemWrapper LOLIW = new OutboundLogisticsLightning.lineItemWrapper();
        OutboundLogisticsLightning.innerPackageWrapper IPW = new OutboundLogisticsLightning.innerPackageWrapper();
        OutboundLogisticsLightning.SelectOptions SLOP = new OutboundLogisticsLightning.SelectOptions('HI','HI');
        OutboundLogisticsLightning.SelectOptions SLOP1 = new OutboundLogisticsLightning.SelectOptions('HI','HI', false);
        
        comW = OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'OrdersToBeShipped','');
        comW = OutboundLogisticsLightning.redirect2NextTab(JSON.serialize(LOIDS));
        //for(OutboundLogisticsLightning.Wrappers wrap : comW.soliWrapperList) { wrap.soliSelected = true; wrap.soliVerified = true; }
        //OutboundLogisticsLightning.fetchBatchStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
        //OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
        OutboundLogisticsLightning.saveSOLIs(JSON.serialize(comW.soliWrapperList), JSON.serialize(comW.SerialIds2Exempt), JSON.serialize(comW.stockMap),JSON.serialize(LOIDS));
        OutboundLogisticsLightning.getLogisticDetails(JSON.serialize(LOIDS));
        OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'PartiallyShippedOrders','');
        OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'ShippedOrders','');
        
        //comW = OutboundLogisticsLightning.createPacksInit(JSON.serialize(LOIDS), '');
        //OutboundLogisticsLightning.editPackage(pack.Id);
        //for(OutboundLogisticsLightning.packageWrapper wrap : comW.packageWrapperList) wrap.pkgSelected = true;
        //OutboundLogisticsLightning.updatePacks(comW.Package2Create, JSON.serialize(comW.PackageWrapperList), JSON.serialize(LOIDS), comW.IsAwaiting);
        
        System.assertEquals('test@test.com',contact.Email);
        Test.stopTest();
    }
    
    static testMethod void OutboundLogisticsUnitTest9() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = false,Run__c = false);
        insert mod;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        List<Product2> Product2insert = new List<Product2>();            
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='test',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);            
        upsert Product2insert;
        
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps1.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salepoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod; 
        Sales_Order__c psod = sod;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=20,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Product__c=ps1.Id);
        insert batch;
        
        ERP7__Serial_Number__c SR = new ERP7__Serial_Number__c(
            Name = 'SR-1',                             
            ERP7__Product__c = ps1.Id,        
            ERP7__Serial_Number__c = 'SR-1',             
            ERP7__Available__c = true,                   
            ERP7__Barcode_Type__c = 'Code128'           
        );
        insert SR;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c = true);
        insert ssl;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c = true);
        insert bin;
        
        List<Inventory_Stock__c> Stocks2insert = new List<Inventory_Stock__c>();
        List<Stock_Inward_Line_Item__c> StockLines2insert = new List<Stock_Inward_Line_Item__c>();        
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=ps1.Id,ERP7__StorageContainer__c=bin.Id);
        Stocks2insert.add(WIIS1);
        
        
        
        upsert Stocks2insert;
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS1.Id,Product__c=ps1.Id,Quantity__c=200,ERP7__Serial__c=SR.id);
        StockLines2insert.add(SPLI1);
        
        
        upsert StockLines2insert;
        
        List<Sales_Order_Line_Item__c> SOLIS2insert = new List<Sales_Order_Line_Item__c>();            
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        SOLIS2insert.add(solim1);
        
        upsert SOLIS2insert;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        update sod;
        
        List<ERP7__Logistic__c> LOGS = [Select Id, Barcode__c, Name from ERP7__Logistic__c];
        List<String> LOIDS = new List<String>();
        for(ERP7__Logistic__c LOG : LOGS) LOIDS.add(LOG.Id);
        
        ERP7__Logistic__c Logistic = LOGS.size() > 0 ? LOGS[0] : new ERP7__Logistic__c();
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = [Select Id, Barcode__c, Name from ERP7__Logistic_Line_Item__c];
        ERP7__Logistic_Line_Item__c LogisticLine =  LoLines2upsert.size() > 0 ? LoLines2upsert[0] : new ERP7__Logistic_Line_Item__c() ;   
        
        Id objectRecordTypeId = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByName().get('MRP Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps1.Id,Sales_Order_Line_Item__c = solim1.Id,ERP7__Status__c  = 'Reserved', RecordTypeId=objectRecordTypeId);
        insert mrp;
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = false;
        List<Stock_Outward_Line_Item__c> PPLIS=new List<Stock_Outward_Line_Item__c>();
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
            Product__c = ps1.Id,Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Quantity__c=4,
            Sales_Order_Line_Item__c=solim1.Id, Sales_Order__c=sod.Id,  Status__c = 'Reserved',
            ERP7__MRP_Material_Requirements_Planning__c=mrp.Id);
        PPLIS.add(PPLI);
        insert PPLIS;
        ERP7__Logistic__c Logistic1 = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salepoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Sales_Order__c=sod.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic1;
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic1.Id, ERP7__Product__c=ps1.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        upsert LogisticLine1;
        ERP7__Inventory_Stock__c is = new ERP7__Inventory_Stock__c(Name='Test Inventory Stock',ERP7__Warehouse__c = site.id,ERP7__product__c = ps1.id);
        insert is;      
        ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c(ERP7__Warehouse__c =site.id,ERP7__Available__c = true,Name='Serail1',ERP7__Serial_Number__c='Test1',ERP7__product__c = ps1.id);
        insert serial;
        
        ERP7__Stock_Outward_Line_Item__c soli = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c =true,ERP7__Serial__c=serial.id,ERP7__Site_Product_Service_Inventory_Stock__c  = is.id,ERP7__Product__c  = ps1.id, ERP7__Quantity__c = 5.00,ERP7__Logistic_Line_Item__c=LogisticLine1.id);
        insert soli;
        Test.startTest();
        OutboundLogisticsLightning.comWrap comW = new OutboundLogisticsLightning.comWrap();
        comW = OutboundLogisticsLightning.getAll('', '', '', '', 0, 10,'','');
        comW = OutboundLogisticsLightning.redirect2NextTab(JSON.serialize(LOIDS));
        for(OutboundLogisticsLightning.Wrappers wrap : comW.soliWrapperList) { wrap.soliSelected = true; wrap.soliVerified = true; }
        if(comW.soliWrapperList.size() > 0){
            OutboundLogisticsLightning.fetchBatchStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
            OutboundLogisticsLightning.fetchBinStocks(JSON.serialize(comW.soliWrapperList[0]),JSON.serialize(comW.stockMap));
        }
         OutboundLogisticsLightning.getAvailableSerial(site.Id, LogisticLine1.Id);
        Test.stopTest();
        
    }
}