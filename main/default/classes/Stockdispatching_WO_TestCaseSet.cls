@isTest
private Class Stockdispatching_WO_TestCaseSet {    
    static testMethod void UnitTestStockdispatching_WO1() {
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
        Id userId = UserInfo.getUserId();
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='test', ERP7__First_Name__c='test', ERP7__Last_Name__c='test',
                                                        ERP7__Gender__c='Male', ERP7__Channel__c=salepoint.Id, Employee_User__c =userId);
        insert emp;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id,
                       Barcode__c='Site');
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, 
                                                       
                                                       Channel__c=emp.ERP7__Channel__c, Site__c=site.Id, Priority__c='1', ERP7__Primary__c=true);
        insert DistributionChannels;  
        
        Product2 ps = new Product2(
                                   Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true,Weight__c=2, ERP7__Lot_Tracked__c=true, 
                                   ERP7__Picture__c='https://images-na.ssl-images-amazon.com/images/G/01/img15/furniture/verticalstore/24795_Vertical-Category_DiningTables_Priority1_SmallTile._CB312951036_.jpg');
        insert ps;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Organisation__c=orgn.Id,  ERP7__Available__c=true,
                                                  ERP7__Supplier__c=sup.Id, ERP7__Status__c='Available', ERP7__Active__c=true, ERP7__Model__c='test', ERP7__Capacity__c='test',
                                                  ERP7__Item_Description__c='test');
        insert asset;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps.Id,ERP7__Active__c=true);
        insert batch1;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                  Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
                                           Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                   Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                     Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                   Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS2;     
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, ERP7__Is_Closed__c=false,
                   WO_Supplier__c = sup.Id, Barcode__c='WO', Status__c='Complete', ERP7__Ready_To_Pick_Pack__c=true, Expected_Date__c=system.today());
        insert wo;
        Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c( Asset__c=asset.Id,
                                        Work_Orders__c = wo.Id, Quantity__c = 2, Picked_Quantity__c = 1, ERP7__Product__c=ps.Id, ERP7__Batch_Lot_Code__c='test', ERP7__Quantity__c=10);
        insert woli;  
        Package__c pack = new Package__c(Name__c='Test Pack',
                          Work_Order__c=wo.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Work_Order_Line_Items__c = woli.Id,Active__c=true,
                                Work_Orders__c=wo.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Work_Order__c=wo.Id ,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];        
        Package__c pack1 = new Package__c( Name__c='Test Pack',
                           Work_Order__c=wo.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Work_Order_Line_Items__c = woli.Id,Active__c=true,
                                Work_Orders__c=wo.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name='test dispatch line item',
                                          Site_Product_Service_Inventory_Stock__c=WIIS.Id,Picked_Quantity__c = 3,
                                          Product__c = ps.Id,Quantity__c=2,Work_Order_Line_Items__c=woli.Id);
        insert sdli;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='test', ERP7__Work_Order__c=WO.Id, ERP7__Ready_For_Dispatch__c=true);
        insert mrp;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Availability_date__c=system.today(), ERP7__Active__c=true,
                                                  ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id, ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Inward_Quantity__c=2, ERP7__Outward_Quantity__c=2);
        insert batch;
        
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c(Name='test', ERP7__Site_ProductService_InventoryStock__c=WIIS2.Id
                                                                                    );//, ERP7__Batch_Lot_Code__c='test',ERP7__Material_Batch_Lot__c=batch.Id
        insert sili;
        StockDispatchingController_WO ppc = new StockDispatchingController_WO();
        StockDispatchingController_WO.Wrappers ppcWrap1 = new StockDispatchingController_WO.Wrappers();
        StockDispatchingController_WO.newWrapper ppcWrap2 = new StockDispatchingController_WO.newWrapper(1);
        StockDispatchingController_WO.innerPackageWrapper ppcWrap3 = new StockDispatchingController_WO.innerPackageWrapper(); 
        StockDispatchingController_WO.packageWrapper ppcWrap4 = new StockDispatchingController_WO.packageWrapper();                   
        StockDispatchingController_WO.lineItemWrapper ppcWrap5 = new StockDispatchingController_WO.lineItemWrapper(); 
        
        PageReference pageRef1 = System.Page.Stockdispatching_WorkOrder;
        pageRef1.getParameters().put('woId',wo.Id);           
        Test.setCurrentPage(pageRef1);
        
        Test.startTest();
        ppc.searchText = wo.Name; 
        ppc.searchWOs(); 
        ppc.searchText = null; 
        ppc.searchWOs(); 
        
        ppcWrap1.WO = wo;
        ppcWrap1.woSelected = true;
        ppc.woWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        ppc.woSelectedWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        StockDispatchingController_WO.Wrappers ppcWrap11 = new StockDispatchingController_WO.Wrappers();        
        List<SelectOption> options1 = new List <SelectOption>();
        List<SelectOption> options2 = new List <SelectOption>();
        List<SelectOption> options3 = new List <SelectOption>(); 
        ppcWrap11.woli = woli;
        ppcWrap11.CurrentWarehouses = options1; 
        ppcWrap11.CurrentLocations = options2;    
        ppcWrap11.CurrentBins = options3;
        ppcWrap11.addressName = site.Id;
        ppc.woliWrapperList.add(ppcWrap11);
        ppc.rowCounter = 0;
        ppc.fetchBinStocks();
        
        ppcWrap11.warehouseName = WIIS.Id;
        ppcWrap11.woliSelected = true;
        ppcWrap11.inventoryStock = 10;
        ppcWrap11.requiredQty = 5;
        ppcWrap11.remainingQty = 5;
        ppc.woliWrapperList.add(ppcWrap11);
        ppc.stockMap.put(WIIS.Product__c, WIIS.Id);
        try { ppc.savewolis(); } catch(Exception e) {}
        
        ppc.pkgTypeValue = 'Package';
        ppc.populatePackDetails();
        ppc.createPackage();        
        ppc.createPacks();
        
        ppc.pack2updateId = pack.Id;
        StockDispatchingController_WO.packageWrapper ppcWrap41 = new StockDispatchingController_WO.packageWrapper();                   
        ppcWrap41.pkgSelected = true;
        ppcWrap41.woli = woli;
        ppc.packageWrapperList.add(ppcWrap41); 
        ppc.updatePacks();                    
        ppc.editPackage();                
        ppc.deletePackage();
        
        ppc.shipmentWrapperList = new List<StockDispatchingController_WO.Wrappers>();
        StockDispatchingController_WO.Wrappers ppcWrap22 = new StockDispatchingController_WO.Wrappers();        
        ppcWrap22.shipM = ship;        
        ppcWrap22.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap22);        
        ppc.createShipments(); 
        ppc.shipmentId = ship.Id;
        ppc.packageId = '0';
        ppc.deleteShipment();
        
        ppc.createWOs();                
        StockDispatchingController_WO.addRow = 1;
        ppc.addWoliWrapperRows();
        ppc.wolisWrapperList.add(ppcWrap2);
        StockDispatchingController_WO.toDelIdent = 1;
        ppc.delWoliWrapperRow();
        ppc.saveWO();
        
        StockDispatchingController_WO.getCurrencyIsoCode(wo);
        ppc.createPickingSlips();
        ppc.packageId = pack.Id;
        try { ppc.createPackingSlips(); } catch(Exception e) {}
        try { ppc.createPackingLabels(); } catch(Exception e) {}
        
        ppc.shipmentWrapperList = new List<StockDispatchingController_WO.Wrappers>();
        StockDispatchingController_WO.Wrappers ppcWrap32 = new StockDispatchingController_WO.Wrappers();        
        ppcWrap32.shipM = ship;        
        ppcWrap32.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap32);        
        try { ppc.createShippingSlips(); } catch(Exception e) {}
        ppc.createBarcodesPage(); 
        ppc.back2ShipmentPage();
        ppc.createOrder();
        ppc.back();
        ppc.evaluatePackDetails();
        ppc.createPackage();
        ppc.createUPSShipment();
        
        ppc.barcode = 'Test'; 
        ppc.scannerMethod();
        ppc.scannerMethodCustom();
        ppc.scannerMethodCustomPick();
        ppc.createBarcode();
        ppc.fetchBatchStocks();
        String workorderId = wo.Id;
        ppc.allWorkOrders();
        
        PageReference pageRef11 = System.Page.MOLabel;
        PageReference pageRef111 = System.Page.MOLabel1;
        pageRef11.getParameters().put('RId',batch.Id);  
        pageRef111.getParameters().put('RId',batch.Id);  
        Test.setCurrentPage(pageRef11);
        Test.setCurrentPage(pageRef111);
        ApexPages.StandardController controller;
        MOLabel ML = new MOLabel(controller);
        MOLabel1 ML1 = new MOLabel1(controller);
        ML.createPDF();
        ML1.createPDF();
        
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }
}