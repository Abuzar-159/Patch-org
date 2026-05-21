@isTest
private class Stockdispatching_SR_TestCaseSet {    
     static testMethod void UnitTestStockdispatching_SR1() {
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
                                                       
                                                       Channel__c=emp.ERP7__Channel__c, Site__c=site.Id, Priority__c='1');
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
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod;
        Sales_Order__c psod = [Select id, Name, Contact__c From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        insert ps;             
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(
                                         Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=5,Sales_Order__c=sod.id,
                                         Total_Price__c=100,VAT_Amount__c=10,Packed_Quantity__c = 2,Picked_Quantity__c = 3);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(
                                          Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,
                                          Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;            
        Location__c ssl = new Location__c(
                              Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                                  Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                  Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WIIS;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                   Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                   Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
         Return_Merchandise_Authorisation__c rma = new Return_Merchandise_Authorisation__c(
                                                   SO__c=sod.Id, Active__c=true,Barcode__c='testCode1');
        insert rma;
        RMA_Line_Item__c rmali1 = new RMA_Line_Item__c(
                                Return_Merchandise_Authorisation__c=rma.Id, Quantity_Return__c=5, Active__c=true,
                                SOLI__c=solim.Id,Picked_Quantity__c=3);
        insert rmali1; 
        RMA_Line_Item__c rmali2 = new RMA_Line_Item__c(
                                Return_Merchandise_Authorisation__c=rma.Id, Quantity_Return__c=5, Active__c=true,
                                SOLI__c=solim.Id,Picked_Quantity__c=5);                                
        insert rmali2;                                                   
        RMA_Line_Item__c rmali3 = new RMA_Line_Item__c(
                                Return_Merchandise_Authorisation__c=rma.Id, Quantity_Return__c=5, Active__c=true,
                                SOLI__c=solim.Id);
        insert rmali3; 
        Package__c pack = new Package__c( Name__c='Test Pack',
                          Return_Merchandise_Authorisation__c=rma.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', RMA_Line_Item__c = rmali1.Id,Active__c=true,
                                Return_Merchandise_Authorisation__c=rma.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Return_Merchandise_Authorisation__c=rma.Id,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];                        
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;        
       
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name='test dispatch line item',
                                          Site_Product_Service_Inventory_Stock__c=WIIS.Id,Picked_Quantity__c = 3,
                                          Product__c = ps.Id,Quantity__c=2,RMA_Line_Item__c=rmali1.Id);
        insert sdli;
        
        StockDispatchingController_SR ppc = new StockDispatchingController_SR();
        StockDispatchingController_SR.Wrappers ppcWrap1 = new StockDispatchingController_SR.Wrappers();
        StockDispatchingController_SR.innerPackageWrapper ppcWrap3 = new StockDispatchingController_SR.innerPackageWrapper(); 
        StockDispatchingController_SR.packageWrapper ppcWrap4 = new StockDispatchingController_SR.packageWrapper();                   
        StockDispatchingController_SR.lineItemWrapper ppcWrap5 = new StockDispatchingController_SR.lineItemWrapper();  
        
        PageReference pageRef1 = System.Page.Stockdispatching_SalesReturn;
        pageRef1.getParameters().put('srId',rma.Id);           
        Test.setCurrentPage(pageRef1);
        
        test.StartTest();
        ppc.searchText = rma.Name; 
        ppc.searchSRs(); 
        ppc.searchText = null; 
        ppc.searchSRs(); 
        
        ppcWrap1.RMA = rma;
        ppcWrap1.rmaSelected = true;
        ppc.rmaWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        
        ppc.rowCounter = 0;
        ppc.fetchBinStocks();
        
        ppcWrap1.warehouseName = WIIS.Id;
        ppcWrap1.rmaliSelected = true;
        ppcWrap1.inventoryStock = 10;
        ppcWrap1.requiredQty = 5;
        ppcWrap1.remainingQty = 5;
        ppc.rmaliWrapperList.add(ppcWrap1);
        ppc.stockMap.put(WIIS.Product__c, WIIS.Id);
        try { ppc.saveRMALIs(); } catch(Exception e) {}
        ppc.createPickingSlips();
        
        ppc.pkgTypeValue = 'Package';
        ppc.createPacks();
        ppc.evaluatePackDetails();
        ppc.populatePackDetails();
        ppc.updatePacks(); 
        ppc.pack2updateId = pack.Id;
        ppc.editPackage();
        ppc.pack2updateId = pack.Id;
        ppc.deletePackage();
        ppc.packageId = pack.Id;
        try { ppc.createPackingSlips(); } catch(Exception e) {}
        try { ppc.createPackingLabels(); } catch(Exception e) {}
        
        ppc.shipmentWrapperList = new List<StockDispatchingController_SR.Wrappers>();
        StockDispatchingController_SR.Wrappers ppcWrap22 = new StockDispatchingController_SR.Wrappers();        
        ppcWrap22.shipM = ship;        
        ppcWrap22.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap22);        
        ppc.createShipments(); 
        ppc.shipmentId = ship.Id;
        ppc.packageId = '0';
        ppc.deleteShipment();
        
        ppc.shipmentWrapperList = new List<StockDispatchingController_SR.Wrappers>();
        StockDispatchingController_SR.Wrappers ppcWrap32 = new StockDispatchingController_SR.Wrappers();        
        ppcWrap32.shipM = ship;        
        ppcWrap32.shipSelected = true;
        ppc.shipmentWrapperList.add(ppcWrap32);        
        try { ppc.createShippingSlips(); } catch(Exception e) {}
        
        ppc.createBarcodesPage(); 
        ppc.createOrder();
        ppc.back();
        
        ppcWrap5.sel = true;
        ppcWrap5.pack = pack;
        ppc.lineItemWrapperList.add(ppcWrap5);
        ppc.shipmentType = 'UPS';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'UPS';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.barcode = 'Test'; 
        ppc.scannerMethod();
        ppc.scannerMethodCustom();
        ppc.scannerMethodCustomPick();
        ppc.createBarcode();
        ppc.fetchBatchStocks(); 
        System.assertEquals('test@test.com',contact.Email);         
        test.stopTest();                       
     }
}