@isTest
private class Stockdispatching_TO_TestCaseSet {    
    static testMethod void UnitTestStockdispatching_TO1() {
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
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true, ERP7__County__c='test');
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true, ERP7__County__c='test');
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
                                                       
                                                       Channel__c=emp.ERP7__Channel__c, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        Product2 ps = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true, ERP7__Lot_Tracked__c =false);
        insert ps;  
        
        Product2 ps1 = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true, ERP7__Lot_Tracked__c =false);
        insert ps1;   
        
        Product2 ps2 = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true, ERP7__Lot_Tracked__c =false);
        insert ps2; 
        
        PriceBookEntry PB = new PriceBookEntry( ERP7__Admin_Shipping_Price__c = 20, ERP7__Barcode__c = 'Test', ERP7__Description__c = 'Test',
                                               ERP7__End_Date__c = System.Today().adddays(365), ERP7__Notes__c = 'Test', ERP7__Purchase_Price__c = 600, ERP7__Shipping_Price__c = 900, ERP7__Start_Date__c = System.Today());         
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                     Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test',  ERP7__Available__c=true,
                                                  ERP7__Supplier__c=sup.Id, ERP7__Status__c='Available', ERP7__Active__c=true, ERP7__Model__c='test', ERP7__Capacity__c='test',
                                                  ERP7__Item_Description__c='test');
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Availability_date__c=system.today(), ERP7__Active__c=true,
                                                  ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id, ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Inward_Quantity__c=2, ERP7__Outward_Quantity__c=2);
        insert batch;
        
        
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,
                                  Warehouse__c=site.Id,Product__c=ps.Id, StorageContainer__c=bin.Id, ERP7__Location__c=ssl.Id, ERP7__Number_of_Sample_Items_Checked_In__c=10,
                                  ERP7__Number_of_Items_to_Resell__c=4, ERP7__Number_of_Items_In_QualityCheck__c=10, ERP7__Number_of_Item_Discarded__c=4, ERP7__Number_of_Sample_Items_Checked_Out__c=2, Fixed_Asset__c=asset.Id);
        insert WIIS;
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c(Name='test', ERP7__Site_ProductService_InventoryStock__c=WIIS.Id, 
                                                                                     ERP7__Product__c=ps.Id, ERP7__Quantity__c=2);//ERP7__Material_Batch_Lot__c=batch.Id,ERP7__Batch_Lot_Code__c='test',
        insert sili;
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id,
                                   Product__c=ps.Id,Location__c=ssl.Id, StorageContainer__c=bin.Id, ERP7__Number_of_Sample_Items_Checked_In__c=10,
                                  ERP7__Number_of_Items_to_Resell__c=4, ERP7__Number_of_Items_In_QualityCheck__c=10, ERP7__Number_of_Item_Discarded__c=4, ERP7__Number_of_Sample_Items_Checked_Out__c=2, Fixed_Asset__c=asset.Id);
        insert WIIS1;
        
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,
                                   Warehouse__c=site.Id,Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id, ERP7__Number_of_Sample_Items_Checked_In__c=10,
                                  ERP7__Number_of_Items_to_Resell__c=4, ERP7__Number_of_Items_In_QualityCheck__c=10, ERP7__Number_of_Item_Discarded__c=4, ERP7__Number_of_Sample_Items_Checked_Out__c=2, Fixed_Asset__c=asset.Id);
        insert WIIS2;
        Transfer_Order__c to = new Transfer_Order__c(Name='Test Order', From_Address__c = bAddress.Id, TO_Address__c = bAddress.Id,
                               From_Site__c = site.Id, Status__c = 'Approved', Active__c = true, Barcode__c = 'Test-123', Expected_Date__c=system.today(), Is_Closed__c = false, ERP7__Ready_To_Pick_Pack__c = true);
        insert to;      
        Transfer_Order_Line_Items__c toli1 = new Transfer_Order_Line_Items__c(Name = 'Test Item', Transfer_Order__c = to.Id,Quantity_requested__c=5,
                                            From_Site__c=site.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Quantity_received__c=5, Products__c = ps.Id, Asset__c=asset.Id);
        insert toli1;
        Transfer_Order_Line_Items__c toli2 = new Transfer_Order_Line_Items__c(Name = 'Test Item', Transfer_Order__c = to.Id,Quantity_requested__c=5,
                                            From_Location__c=ssl.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Quantity_received__c=5, Products__c = ps.Id, Asset__c=asset.Id);
        insert toli2;
        Transfer_Order_Line_Items__c toli3 = new Transfer_Order_Line_Items__c(Name = 'Test Item', Transfer_Order__c = to.Id,Quantity_requested__c=5,
                                            From_Site__c=site.Id,From_Location__c=ssl.Id,From_Storage__c=bin.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,
                                            Quantity_received__c=5, Products__c = ps.Id, Asset__c=asset.Id);
        insert toli3;                                       
        Package__c pack = new Package__c( Name__c='Test Pack',
                          Transfer_Order__c=to.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Transfer_Order_Line_Item__c = toli1.Id,Active__c=true,
                                Transfer_Order__c=to.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Transfer_Order__c =to.Id ,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];        
        Package__c pack1 = new Package__c( Name__c='Test Pack',
                          Transfer_Order__c=to.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Transfer_Order_Line_Item__c = toli1.Id,Active__c=true,
                                Transfer_Order__c=to.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;
       
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name='test dispatch line item',
                                          Site_Product_Service_Inventory_Stock__c=WIIS.Id,
                                          product__c = ps.Id,Quantity__c=10, ERP7__Status__c='Reserved');
        insert sdli;
        
        ERP7__StorageContainer__c SC = new ERP7__StorageContainer__c(Name='test', ERP7__Site__c=site.Id, ERP7__Location__c=ssl.Id, ERP7__Type__c='Bin', Barcode__c='Test');
        insert SC;
        
        StockDispatchingController_TO ppc = new StockDispatchingController_TO();
        StockDispatchingController_TO.Wrappers ppcWrap1 = new StockDispatchingController_TO.Wrappers();
        StockDispatchingController_TO.innerPackageWrapper ppcWrap3 = new StockDispatchingController_TO.innerPackageWrapper(); 
        StockDispatchingController_TO.packageWrapper ppcWrap4 = new StockDispatchingController_TO.packageWrapper();                   
        StockDispatchingController_TO.lineItemWrapper ppcWrap5 = new StockDispatchingController_TO.lineItemWrapper();  
        
        PageReference pageRef1 = System.Page.Stockdispatching_WorkOrder;
        pageRef1.getParameters().put('toId',to.Id);
        Test.setCurrentPage(pageRef1);
        
        Test.startTest();
        String transferorderId = to.Id;
        ppc.alltransferorders();
        ppc.searchText = to.Name; 
        ppc.searchTOs(); 
        ppc.searchText = null; 
        ppc.searchTOs();  
        ppc.createBarcode();
        ppcWrap1.TO = to;
        ppcWrap1.toSelected = true;
        ppc.toWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        String toliIds = toli3.Id;
        ppc.redirect2NextTab();
        StockDispatchingController_TO.Wrappers ppcWrap13 = new StockDispatchingController_TO.Wrappers();       
        ppcWrap13.warehouseName = WIIS.Id;
        ppcWrap13.toSelected = true;
        ppcWrap13.inventoryStock = 10;
        ppcWrap13.requiredQty = 5;
        ppcWrap13.remainingQty = 5;
        ppc.toliSelectedWrapperList.add(ppcWrap13);
        ppc.redirect2NextTab();
        Boolean toSelected = true;
        ppc.redirect2NextTab();
        Set<Id> toIds = new Set<Id>();
        toIds.add(TO.Id);
        ppc.redirect2NextTab();
        StockDispatchingController_TO.Wrappers ppcWrap11 = new StockDispatchingController_TO.Wrappers();       
        ppcWrap11.warehouseName = WIIS.Id;
        ppcWrap11.toliSelected = true;
        ppcWrap11.inventoryStock = 10;
        ppcWrap11.requiredQty = 5;
        ppcWrap11.remainingQty = 5;
        ppc.toliWrapperList.add(ppcWrap11);
        
        StockDispatchingController_TO.Wrappers ppcWrap12 = new StockDispatchingController_TO.Wrappers();       
        ppcWrap11.warehouseName = WIIS.Id;
        ppcWrap11.toliSelected = true;
        ppcWrap11.inventoryStock = 10;
        ppcWrap11.requiredQty = 5;
        ppcWrap11.remainingQty = 5;
        ppc.toliSelectedWrapperList.add(ppcWrap12);
        ppc.createBarcode();
        
        ppc.stockMap.put(ps.Id, wiis.Id);
        try { ppc.saveTOLIs(); } catch(Exception e) {}
        
        ppc.createPackage();        
        ppc.createPacks();
        ppc.pkgTypeValue = 'Package';
        ppc.populatePackDetails();
        ppc.evaluatePackDetails();
           
        ppc.pack2updateId = pack.Id;
        StockDispatchingController_TO.packageWrapper ppcWrap41 = new StockDispatchingController_TO.packageWrapper();                   
        ppcWrap41.pkgSelected = true;
        ppcWrap41.toli = toli1;
        ppc.packageWrapperList = new list<StockDispatchingController_TO.packageWrapper>();
        ppc.packageWrapperList.add(ppcWrap41);        
        ppc.updatePacks();     
        ppc.editPackage();
        ppc.deletePackage();
        
        ppc.shipmentWrapperList = new List<StockDispatchingController_TO.Wrappers>();
        StockDispatchingController_TO.Wrappers ppcWrap22 = new StockDispatchingController_TO.Wrappers();        
        ppcWrap22.shipM = ship;        
        ppcWrap22.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap22);        
        ppc.createShipments(); 
        ppc.shipmentId = ship.Id;
        ppc.packageId = '0';
        ppc.deleteShipment();
          
        ppc.createTOs();              
        StockDispatchingController_TO.addRow = 1;
        ppc.addToliWrapperRows();
        ppc.tolisWrapperList.add(new StockDispatchingController_TO.newWrapper(1));
        StockDispatchingController_TO.toDelIdent = 1;
        ppc.delToliWrapperRow();
        ppc.saveTO();
        
        ppc.shipmentWrapperList = new List<StockDispatchingController_TO.Wrappers>();
        StockDispatchingController_TO.Wrappers ppcWrap32 = new StockDispatchingController_TO.Wrappers();        
        ppcWrap32.shipM = ship;        
        ppcWrap32.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap32);        
        try { ppc.createShippingSlips(); } catch(Exception e) {}
        
        ppc.packageId = pack.Id;
        try { ppc.createPackingSlips(); } catch(Exception e) {}
        try { ppc.createPackingLabels(); } catch(Exception e) {}
        
        ppc.createOrder();
        ppc.back();
        ppc.createPackage();
        ppc.createPickingSlips();
        ppc.createBarcodesPage();
        
        ppcWrap5.sel = true;
        ppcWrap5.pack = pack;
        ppc.lineItemWrapperList.add(ppcWrap5);
        ppc.shipmentType = 'UPS';
        ppc.createUPSShipment();
        
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'UPS';
        ppc.createUPSShipment();
        
        ppc.shipmentType = 'Internal Shipping';
        ppc.createUPSShipment();
        
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'Internal Shipping';
        ppc.createUPSShipment(); 
        
        ppc.barcode = to.Barcode__c; 
        ppc.scannerMethod();
        ppc.scannerMethodCustom();
        ppc.scannerMethodCustomPick();
        ppc.createBarcode();
        ppc.fetchBinStocks();
        ppc.fetchBatchStocks();
        System.assertEquals('test@test.com',contact.Email);     
        test.stopTest();        
    }
    
}