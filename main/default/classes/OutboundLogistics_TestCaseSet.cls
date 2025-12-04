@isTest
private class OutboundLogistics_TestCaseSet {
    @isTest
    static  void OutboundLogisticsUnitTest1() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;   
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        
        Address__c bAddress = new Address__c(Customer__c=customer.id, ERP7__Primary__c = true,
                                             Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true, Is_Shipping_Address__c=true);
        insert bAddress;
        
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
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
        sod.Ship_To_Address__c = bAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true, ERP7__Is_Kit__c = true);
        insert ps;
        
        Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps2;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WIIS;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim1;
        
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Sales_Order__c=sod.Id, ERP7__Active__c=true,Channel__c=salePoint.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c=Solim.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        upsert LogisticLine1;
        
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, ERP7__Sales_Order_Line_Item__c=Solim1.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        upsert LogisticLine;
        Test.startTest();
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c( Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Reserved');
        insert PPLI;
        
        //sod.Issue_Warranty__c = True;
        //update sod;
        
        Package__c pack = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id,Sales_Order__c=sod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;
        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true, Logistic__c=Logistic.Id, ERP7__Logistic_Line_Item__c = LogisticLine.Id, Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=bAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                                           Logistic__c=Logistic.Id, status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        
        Package__c pack1 = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id, Sales_Order__c=sod.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,Logistic__c=Logistic.Id,
                                                     Sales_Order__c=sod.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                                       Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps2.Id,Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c  = 'Reserved');
        insert mrp;
        
        PageReference pg = System.Page.OutboundLogistics;
        pg.getParameters().put('loId', Logistic.Id);        
        Test.setCurrentPage(pg);
        
        
        
        OutboundLogistics ppc = new OutboundLogistics();
        
        OutboundLogistics.Wrappers ppcWrap1 = new OutboundLogistics.Wrappers();
        OutboundLogistics.innerPackageWrapper ppcWrap3 = new OutboundLogistics.innerPackageWrapper(); 
        OutboundLogistics.packageWrapper ppcWrap4 = new OutboundLogistics.packageWrapper();                   
        OutboundLogistics.lineItemWrapper ppcWrap5 = new OutboundLogistics.lineItemWrapper();
        ppc.shipId = ppc.result = ppc.retValue = ppc.errorMsg1 = ppc.searchText = ppc.service_code = ppc.delivery_date = ppc.customerId = ppc.service_description = '';
        ppc.time_in_cost_tab = ppc.scanned = ppc.initialScan = false;
        ppc.sales = new ERP7__Sales_Order__c();
        OutboundLogistics.toDelIdent = 0;
        
        ppcWrap1.Logistic = Logistic;
        ppcWrap1.soSelected = true;
        ppc.soWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        ppc.soWrapperList = new List<OutboundLogistics.Wrappers>();
        ppc.logisticId = Logistic.Id;
        ppc.redirect2NextTab();
        
        OutboundLogistics.Wrappers ppcWrap11 = new OutboundLogistics.Wrappers();        
        List<SelectOption> options1 = new List <SelectOption>();
        List<SelectOption> options2 = new List <SelectOption>();
        List<SelectOption> options3 = new List <SelectOption>(); 
        ppcWrap11.LOLI = LogisticLine1;
        ppcWrap11.CurrentWarehouses = options1; 
        ppcWrap11.CurrentLocations = options2;    
        ppcWrap11.CurrentBins = options3;
        ppcWrap11.addressName = site.Id;
        ppc.soliWrapperList.add(ppcWrap11);
        
        OutboundLogistics.Wrappers ppcWrap12 = new OutboundLogistics.Wrappers();        
        List<SelectOption> options12 = new List <SelectOption>();
        List<SelectOption> options22 = new List <SelectOption>();
        List<SelectOption> options32 = new List <SelectOption>();
        ppcWrap12.LOLI = LogisticLine1;
        ppcWrap12.CurrentWarehouses = options12; 
        ppcWrap12.CurrentLocations = options22;    
        ppcWrap12.CurrentBins = options32;
        ppcWrap12.addressName = ssl.Id;
        ppc.soliWrapperList.add(ppcWrap12);
        
        OutboundLogistics.Wrappers ppcWrap13 = new OutboundLogistics.Wrappers();        
        List<SelectOption> options13 = new List <SelectOption>();
        List<SelectOption> options23 = new List <SelectOption>();
        List<SelectOption> options33 = new List <SelectOption>();
        ppcWrap13.LOLI = LogisticLine1;
        ppcWrap13.CurrentWarehouses = options13; 
        ppcWrap13.CurrentLocations = options23;    
        ppcWrap13.CurrentBins = options33;
        ppcWrap13.addressName = bin.Id;
        ppc.soliWrapperList.add(ppcWrap13);
        
        ppc.rowCounter = 0;
        ppc.fetchBinStocks();
        ppc.fetchBatchStocks();
        ppcWrap11.warehouseName = WIIS.Id;
        ppcWrap11.soliSelected = true;
        ppcWrap11.inventoryStock = 10;
        ppcWrap11.requiredQty = 5;
        ppcWrap11.remainingQty = 5;
        ppcWrap11.Loli = LogisticLine;
        ppc.soliWrapperList.add(ppcWrap11);
        ppc.stockMap.put(WIIS.Product__c, WIIS.Id);
        //try { ppc.saveSOLIs(); } catch(Exception e) {}
        ppc.saveSOLIs();
        //ppc.createPacks();
        ppc.pkgTypeValue = 'Package';
        ppc.populatePackDetails();
        
        ppc.pack2updateId = pack.Id;        
        ppc.updatePacks(); 
        OutboundLogistics.packageWrapper ppcWrap41 = new OutboundLogistics.packageWrapper();                   
        ppcWrap41.pkgSelected = true;
        ppcWrap41.Loli = LogisticLine;
        //ppc.packageWrapperList.add(ppcWrap41);
        ppc.editPackage();
        ppc.deletePackage();
        
        ppc.back2ShipmentPage();
        Test.stopTest();
        ppc.createBarcode();
        
        ppc.shipmentWrapperList = new List<OutboundLogistics.Wrappers>();
        OutboundLogistics.Wrappers ppcWrap22 = new OutboundLogistics.Wrappers();        
        ppcWrap22.shipM = ship;        
        ppcWrap22.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap22);        
        ppc.createShippingSlips();
        ppc.createShipments(); 
        
        ppc.shipmentId = ship.Id;
        ppc.packageId = '0';
        ppc.deleteShipment();
        
        ppc.Package2Create.Sales_Order__c = sod.Id;        
        ppc.fetchSOLIIItems();        
        
        ppc.shipmentType = 'UPS';
        ppc.selectedPackIds = new List<Id>{pack.Id};
            ppc.createUPSShipment();
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship.Id;
        ppc.shipmentType = 'UPS';
        //try { ppc.createUPSShipment(); } catch(Exception e) {}
        ppc.createUPSShipment();
        ppc.selectedPackIds = new List<Id>{pack.Id};
            ppc.shipmentId = '';
        ppc.shipmentType = 'Internal Shipping';
        //try { ppc.createUPSShipment(); } catch(Exception e) {}
        ppc.createUPSShipment();
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship.Id;
        ppc.shipmentType = 'Internal Shipping';
        //try { ppc.createUPSShipment(); } catch(Exception e) {} 
        ppc.createUPSShipment();
        
        ppcWrap5.sel = true;
        ppcWrap5.pack = pack;
        ppc.lineItemWrapperList.add(ppcWrap5);
        ppc.createInternalShipping();
        
        ppc.createPickingSlips();
        ppc.packageId = pack.Id;
        //try { ppc.createPackingSlips(); } catch(Exception e) {}
        //try { ppc.createPackingLabels(); } catch(Exception e) {}
        ppc.createPackingSlips();
        ppc.createPackingLabels();
        ppc.createBarcodesPage();        
        
        ppc.soliWrapperList = new List<OutboundLogistics.Wrappers>();
        ppc.createPOs();  
        ppc.createWOs();      
        ppcWrap11.LOLI = LogisticLine1;
        ppcWrap11.soliSelected = true;
        ppc.soliWrapperList.add(ppcWrap11);  
        ppc.soliWrapperList = new List<OutboundLogistics.Wrappers>();
        
        ppc.back();
        ppc.evaluatePackDetails();
        
        ppc.barcode = sod.Barcode__c; 
        ppc.scannerMethod();
        ppc.scannerMethodCustom();
        ppc.SiteSelect();
        System.assertEquals('test@test.com',contact.Email); 
        
        ppc.scannerMethodCustomReload();
        ppc.createOrder();
        ppc.ChannelChange();
        ppc.OfsetChange();
        ppc.SetShow();
        ppc.Next();
        ppc.NextLast();
        ppc.Previous();
        //ppc.PreviousFirst();
            
    }
    
    /*static testMethod void OutboundLogisticsUnitTest2() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id, ERP7__Primary__c = true,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true, Is_Shipping_Address__c=true);
        insert bAddress;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id, Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
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
        sod.Ship_To_Address__c = bAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true, ERP7__Is_Kit__c = true);
        insert ps;
        
        Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps2;

        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;

        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WIIS;

        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;

        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI1;

        BOM__c psa1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        System.assertEquals(ps.Name,'test');

        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim;

        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim1;
        
        solim1.Quantity__c=1;
        update solim1;

        solim1.Quantity__c=4;
        update solim1;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Sales_Order__c=sod.Id, ERP7__Active__c=true,Channel__c=salePoint.Id);
        upsert Logistic;
       
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c=Solim.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved',Explode__c=true);
        upsert LogisticLine;
        
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c( Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Reserved');
        insert PPLI;
         
        Package__c pack = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id,Sales_Order__c=sod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;

        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true, Logistic__c=Logistic.Id, ERP7__Logistic_Line_Item__c = LogisticLine.Id, Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;

        Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=bAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id, Logistic__c=Logistic.Id, status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Package__c pack1 = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id, Sales_Order__c=sod.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,Logistic__c=Logistic.Id, Sales_Order__c=sod.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3, Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        List< RecordType > rTpe_MRPKIT = [Select Id, Name from RecordType Where sObjectType='ERP7__MRP__c' And Name='MRP Kit'];

        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps.Id,Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c  = 'Reserved',RecordTypeId=rTpe_MRPKIT[0].Id);
        insert mrp;
        
        PageReference pg = System.Page.OutboundLogistics;
        pg.getParameters().put('loId', Logistic.Id);
        Test.setCurrentPage(pg);
        
        OutboundLogistics ppc = new OutboundLogistics();
        OutboundLogistics.Wrappers ppcWrap1 = new OutboundLogistics.Wrappers();
        OutboundLogistics.innerPackageWrapper ppcWrap3 = new OutboundLogistics.innerPackageWrapper(); 
        OutboundLogistics.packageWrapper ppcWrap4 = new OutboundLogistics.packageWrapper();                   
        OutboundLogistics.lineItemWrapper ppcWrap5 = new OutboundLogistics.lineItemWrapper();                   
        
        Test.startTest();
        ppcWrap1.Logistic = Logistic;
        ppcWrap1.soSelected = true;
        ppc.soWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        
        OutboundLogistics.Wrappers ppcWrap11 = new OutboundLogistics.Wrappers();        
        List<SelectOption> options1 = new List <SelectOption>();
        List<SelectOption> options2 = new List <SelectOption>();
        List<SelectOption> options3 = new List <SelectOption>(); 
        ppcWrap11.LOLI = LogisticLine;
        ppcWrap11.CurrentWarehouses = options1; 
        ppcWrap11.CurrentLocations = options2;    
        ppcWrap11.CurrentBins = options3;
        ppcWrap11.addressName = site.Id;
        ppc.soliWrapperList.add(ppcWrap11);
        
        
        OutboundLogistics.Wrappers ppcWrap12 = new OutboundLogistics.Wrappers();        
        List<SelectOption> options12 = new List <SelectOption>();
        List<SelectOption> options22 = new List <SelectOption>();
        List<SelectOption> options32 = new List <SelectOption>();
        ppcWrap12.LOLI = LogisticLine;
        ppcWrap12.CurrentWarehouses = options12; 
        ppcWrap12.CurrentLocations = options22;    
        ppcWrap12.CurrentBins = options32;
        ppcWrap12.addressName = ssl.Id;
        ppc.soliWrapperList.add(ppcWrap12);
        
        OutboundLogistics.Wrappers ppcWrap13 = new OutboundLogistics.Wrappers();        
        List<SelectOption> options13 = new List <SelectOption>();
        List<SelectOption> options23 = new List <SelectOption>();
        List<SelectOption> options33 = new List <SelectOption>();
        ppcWrap13.LOLI = LogisticLine;
        ppcWrap13.CurrentWarehouses = options13; 
        ppcWrap13.CurrentLocations = options23;    
        ppcWrap13.CurrentBins = options33;
        ppcWrap13.addressName = bin.Id;
        ppc.soliWrapperList.add(ppcWrap13);
        ppc.saveSOLIs();
        
        ppc.rowCounter = 0;
        //ppc.fetchBatchStocks();
        //ppc.saveSOLIs();
        //ppc.createPacks();
        //ppc.updatePacks(); 
        ppcWrap11.warehouseName = WIIS.Id;
        ppcWrap11.soliSelected = true;
        ppcWrap11.inventoryStock = 10;
        ppcWrap11.requiredQty = 5;
        ppcWrap11.remainingQty = 5;
        ppcWrap11.Loli = LogisticLine;
        ppc.soliWrapperList.add(ppcWrap11);
        ppc.stockMap.put(WIIS.Product__c, WIIS.Id);
        //try { ppc.saveSOLIs(); } catch(Exception e) {}
        //ppc.saveSOLIs();
        ppcWrap1.Logistic = Logistic;
        ppcWrap1.soSelected = true;
        ppc.soWrapperList.add(ppcWrap1);
        
        ppc.createPacks();
        ppc.pkgTypeValue = 'Package';
        //ppc.populatePackDetails();
        
        ppc.pack2updateId = pack.Id;        
        ppc.updatePacks(); 
        OutboundLogistics.packageWrapper ppcWrap41 = new OutboundLogistics.packageWrapper();                   
        ppcWrap41.pkgSelected = true;
        ppcWrap41.Loli = LogisticLine;
        ppc.packageWrapperList.add(ppcWrap41);
        
        
        ppc.shipmentWrapperList = new List<OutboundLogistics.Wrappers>();
        OutboundLogistics.Wrappers ppcWrap22 = new OutboundLogistics.Wrappers();        
        ppcWrap22.shipM = ship;        
        ppcWrap22.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap22);        
       
        ppc.shipmentId = ship.Id;
        ppc.packageId = '0';
        ppc.deleteShipment();
        
        ppc.Package2Create.Sales_Order__c = sod.Id;        
               
        
        ppc.shipmentType = 'UPS';
        ppc.selectedPackIds = new List<Id>{pack.Id};
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship.Id;
        ppc.shipmentType = 'UPS';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>{pack.Id};
        ppc.shipmentId = '';
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship.Id;
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {} 
        
        ppcWrap5.sel = true;
        ppcWrap5.pack = pack;
        ppc.lineItemWrapperList.add(ppcWrap5);
        ppc.createInternalShipping();
        
        
        ppc.createPickingSlips();
        ppc.packageId = pack.Id;
        try { ppc.createPackingSlips(); } catch(Exception e) {}
        try { ppc.createPackingLabels(); } catch(Exception e) {}
        ppc.createBarcodesPage();        
        
        ppc.soliWrapperList = new List<OutboundLogistics.Wrappers>();
        ppc.createPOs();        
        ppcWrap11.LOLI = LogisticLine;
        ppcWrap11.soliSelected = true;
        ppc.soliWrapperList.add(ppcWrap11);  
        ppc.createPOs();        
        OutboundLogistics.addRow = 1;
        ppc.createOrder();
        ppc.back();
        ppc.evaluatePackDetails();
        
        ppc.barcode = sod.Barcode__c; 
        ppc.scannerMethod();
        //ppc.scannerMethodCustom();
        //ppc.scannerMethodCustomPick();
        
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }*/
    @isTest(SeeAllData=true)
    static  void OutboundLogisticsUnitTest3() {
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id,
                       Barcode__c='Site');
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, 
                                                       
                                                       Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
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
        Product2 ps = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        insert ps;             
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(
                                         Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=5,Sales_Order__c=sod.id,
                                         Total_Price__c=100,VAT_Amount__c=10,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Inventory_Tracked__c=true);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(
                                          Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,
                                          Total_Price__c=100,VAT_Amount__c=10,Inventory_Tracked__c=true);
        insert solim1;    
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                 Active__c=true,Warehouse__c=site.Id,
                                                 Product__c=ps.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
                                       Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                 Active__c=true,Warehouse__c=site.Id,
                                                 Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                     Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Active__c=true,Warehouse__c=site.Id,
                                                 Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id);
        insert PPLI; 
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order__c=sod.Id);
        insert PPLI1;  
        PO__c PO = new PO__c(Delivery_Address__c = bAddress.Id,
                   vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id,Barcode__c='PO');
        insert PO;  
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,
                                      Product__c = ps.Id);
        insert poli;     
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true,
                   WO_Supplier__c = sup.Id,Barcode__c='WO');
        PreventRecursiveLedgerEntry.preventWOExecution = false;
        insert wo;
        Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c(
                                        Work_Orders__c = wo.Id, Quantity__c = 2);
        insert woli;  
        Package__c pack = new Package__c( Name__c='Test Pack',
                          Sales_Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true,
                                Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        PreventRecursiveLedgerEntry.preventShipmentcounterTrigger = false;
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];        
        Package__c pack1 = new Package__c( Name__c='Test Pack',
                          Sales_Order__c=psod.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,
                                Sales_Order__c=psod.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Sales_Order__c=psod.Id, ERP7__Active__c=true,Channel__c=salePoint.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c=Solim.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        upsert LogisticLine;
        
        PageReference pg = System.Page.OutboundLogistics;
        pg.getParameters().put('loId', Logistic.Id);        
        Test.setCurrentPage(pg);
        
        Test.startTest();
        OutboundLogistics ppc = new OutboundLogistics();
        ppc.barcode = sod.Barcode__c; 
        ppc.scannerMethod();
        ppc.scannerMethodCustom();
        List<ERP7__Sales_Order__c> SOList = new List<ERP7__Sales_Order__c>();
        SOList.add(sod);
        if(SOList.size()>0) ppc.scannerMethodCustom();
        ppc.authorisedOrders();
        String salesorderId = sod.Id;
        ppc.authorisedOrders();
        ppc.StillToFulfill();
        OutboundLogistics.sortBy = OutboundLogistics.prevSortBy = OutboundLogistics.orderFormat = '';
        ppc.shipmentSelectedWrapperList = new List<OutboundLogistics.Wrappers>();
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }
    @isTest//(SeeAllData=true)
    static  void OutboundLogisticsUnitTest4() {
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = false,Run__c = false);
        insert mod;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        
        Address__c bAddress = new Address__c(Customer__c=customer.id, ERP7__Primary__c = true,
                                             Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true, Is_Shipping_Address__c=true);
        insert bAddress;
        
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
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
        sod.Ship_To_Address__c = bAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true, ERP7__Is_Kit__c = true);
        insert ps;
        
        Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps2;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WIIS;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim1;
        
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Sales_Order__c=sod.Id, ERP7__Active__c=true,Channel__c=salePoint.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c=Solim.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        upsert LogisticLine1;
        
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, ERP7__Sales_Order_Line_Item__c=Solim1.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        upsert LogisticLine;
        
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c( Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Reserved');
        insert PPLI;
        
        //sod.Issue_Warranty__c = True;
        //update sod;
        
        Package__c pack = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id,Sales_Order__c=sod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;
        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true, Logistic__c=Logistic.Id, ERP7__Logistic_Line_Item__c = LogisticLine.Id, Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=bAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                                           Logistic__c=Logistic.Id, status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        
        Package__c pack1 = new Package__c( Name__c='Test Pack',Logistic__c=Logistic.Id, Sales_Order__c=sod.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,Logistic__c=Logistic.Id,
                                                     Sales_Order__c=sod.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                                       Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=ps2.Id,Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c  = 'Reserved');
        insert mrp;
        
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='loc1',ERP7__Site__c=site.id);
        insert loc1;
        
        ERP7__Employees__c TestEmp = new ERP7__Employees__c(Name='Test',ERP7__Employee_User__c=userInfo.getUserId());
        insert TestEmp;
         ERP7__Version__c version= new ERP7__Version__c(name='Test_vrsion',ERP7__Product__c=ps2.Id);
        insert version;
         ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='Test-001',ERP7__Account__c=customer.Id,ERP7__Product__c=ps2.Id,ERP7__Production_Version__c=version.Id);
        insert batch1;
        ERP7__Inventory_Stock__c is = new ERP7__Inventory_Stock__c(Name='Test Inventory Stock', ERP7__Warehouse__c = site.id,ERP7__Location__c = loc1.id,ERP7__product__c = ps2.id,ERP7__Batch_Lot__c = batch1.Id);
        insert is;
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true, ERP7__Site_ProductService_InventoryStock__c = is.id,ERP7__Product__c  = ps2.id, ERP7__Quantity__c = 50.00);
        insert sili; 
        ERP7__Stock_Take__c sT = new ERP7__Stock_Take__c(Name = 'Test', ERP7__Approver__c = TestEmp.Id, ERP7__Employee__c =TestEmp.Id, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today() , ERP7__Site__c = site.Id, ERP7__Status__c = 'Open');
        insert sT;
        ERP7__Stock_Take_Line_Item__c STLI = new ERP7__Stock_Take_Line_Item__c(ERP7__Stock_Take__c = sT.Id, ERP7__Inventory_Stock__c = is.Id, ERP7__Stock_Available__c = 50, ERP7__Stock_In_Hand__c = 0.00, ERP7__Variance__c = 0.00);
        insert STLI;
        
       

       
        
        ERP7__Stock_Inward_Line_Item__c  sili1 = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true, ERP7__Site_ProductService_InventoryStock__c = is.id, ERP7__Stock_Take_Line_Item__c = STLI.Id,ERP7__Product__c  = ps2.id, ERP7__Quantity__c = 50.00,ERP7__Material_Batch_Lot__c=batch1.Id);
        insert sili1;
        Test.startTest();
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        ERP7__Stock_Outward_Line_Item__c soli1 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c =true, ERP7__Site_Product_Service_Inventory_Stock__c  = is.id, ERP7__Stock_Take_Line_Item__c = STLI.Id, ERP7__Product__c  = ps2.id, ERP7__Quantity__c = 5.00);
        insert soli1;
        
        PageReference pg = System.Page.OutboundLogistics;
        pg.getParameters().put('loId', Logistic.Id);        
        Test.setCurrentPage(pg);
        

        
         OutboundLogistics ppc = new OutboundLogistics();
        OutboundLogistics.Wrappers ppcWrap1 = new OutboundLogistics.Wrappers();
        OutboundLogistics.innerPackageWrapper ppcWrap3 = new OutboundLogistics.innerPackageWrapper(); 
        OutboundLogistics.packageWrapper ppcWrap4 = new OutboundLogistics.packageWrapper();                   
        OutboundLogistics.lineItemWrapper ppcWrap5 = new OutboundLogistics.lineItemWrapper(); 
        ppc.updatePacks();
        ppc.editPackage();
        ppc.deletePackage();
        ppc.createShippingSlips();
        ppc.createShipments(); 
        ppc.fetchSOLIIItems(); 
        ppc.fetchBatchStocks();
        ppc.saveSOLIs();
        ppc.createPacks();
        ppc.updatePacks(); 
        system.assertEquals('test@test.com', contact.Email);
        test.stopTest();
    }
}