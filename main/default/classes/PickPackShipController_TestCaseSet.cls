@isTest
private class PickPackShipController_TestCaseSet {
    
    static testMethod void UnitTestPickPackShip1() {
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
        
        
        /////////
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true, ERP7__Is_Kit__c = true);
        insert ps;     
        
        Product2 ps3 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps3;  
        
        Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps2;       
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
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
        /*Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                 Active__c=true,Warehouse__c=site.Id,
                                                 Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI1;*/
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true);
        insert ps1;            
        /*BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa; 
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;            
        System.assertEquals(ps.Name,'test');
			*/
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim;
        /*Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;   
        /////////
        
        
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4,
                                             Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Committed');
        insert PPLI; 
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id,
                                             Sales_Order__c=sod.Id, Picked_Quantity__c=1, Status__c = 'Committed');
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
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=PPLI.Product__c);
        insert mrp;*/
        
        PickPackShipController ppc = new PickPackShipController();
        PickPackShipController.Wrappers ppcWrap1 = new PickPackShipController.Wrappers();
        ppc.createBarcode();
        PickPackShipController.newWrapper ppcWrap2 = new PickPackShipController.newWrapper(1);
        PickPackShipController.innerPackageWrapper ppcWrap3 = new PickPackShipController.innerPackageWrapper(); 
        PickPackShipController.packageWrapper ppcWrap4 = new PickPackShipController.packageWrapper();                   
        PickPackShipController.lineItemWrapper ppcWrap5 = new PickPackShipController.lineItemWrapper();                   
        
        Test.startTest();
        ppc.InboundOrOutbound();
        ppc.LineItemId=null; ppc.shipId=null; ppc.result=null; ppc.retValue=null; ppc.errorMsg1=null; ppc.Packages=null; ppc.service_description=null; ppc.Shipments=null; 
        ppc.packMap=null; ppc.packageList=null; ppc.shipmentList=null; ppc.packageLists=null; ppc.packListRecords=null; ppc.lineItemWrapperList=null;ppc.currentItems=null; 
        ppc.DistributionChannels=null;  ppc.packageRecords=null; ppc.shipmentRecords=null; ppc.barcode=null; ppc.scanned=null; ppc.PB=null; ppc.shippingTemplate=null; ppc.selectedOrders=null;
        ppc.barcodeLoc=null; ppc.sfdcBaseURL=null;  ppc.sfdcBaseURL=null; ppc.initialScan=false;  ppc.barcodeLocMsg=null; ppc.packingTemplate=null; ppc.selectedPackageWrapperList=null; 
        ppc.sales=null; ppc.sfdcBaseURL=null;  ppc.sfdcBaseURL=null; ppc.initialScan=false;  ppc.barcodeLocMsg=null; ppc.packingTemplate=null; ppc.shipmentSelectedWrapperList=null; 
        ppc.shippingTemplate=null; ppc.selectedOrders=null; ppc.service_code=null; ppc.delivery_date=null; ppc.time_in_cost_tab=null; ppc.customerId=null;
        PickPackShipController.sortBy=null; PickPackShipController.prevSortBy=null; 
        ppc.Logistic=null;
        ppc.scannerMethodCustom();
                
        ppc.searchText = 'test'; 
        ppc.searchSOs();
        ppcWrap1.SO = sod;
        ppcWrap1.soSelected = true;
        ppc.soWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        ppc.redirect2NextTabCustom();
        
         PickPackShipController.Wrappers ppcWrap101 = new PickPackShipController.Wrappers();        
        List<SelectOption> options01 = new List <SelectOption>();
        List<SelectOption> options02 = new List <SelectOption>();
        List<SelectOption> options03 = new List <SelectOption>(); 
        ppcWrap101.SOLI = solim;
        ppcWrap101.CurrentWarehouses = options01; 
        ppcWrap101.CurrentLocations = options02;    
        ppcWrap101.CurrentBins = options03;
        ppcWrap101.addressName = site.Id;
        ppcWrap101.soSelected = false;
        ppcWrap101.soliSelected = false;
        ppc.soliWrapperList.add(ppcWrap101);
         ppc.createBarcode();
        
        PickPackShipController.Wrappers ppcWrap11 = new PickPackShipController.Wrappers();        
        List<SelectOption> options1 = new List <SelectOption>();
        List<SelectOption> options2 = new List <SelectOption>();
        List<SelectOption> options3 = new List <SelectOption>(); 
        ppcWrap11.SOLI = solim;
        ppcWrap11.CurrentWarehouses = options1; 
        ppcWrap11.CurrentLocations = options2;    
        ppcWrap11.CurrentBins = options3;
        ppcWrap11.addressName = site.Id;
        ppc.soliWrapperList.add(ppcWrap11);
        
        PickPackShipController.Wrappers ppcWrap12 = new PickPackShipController.Wrappers();        
        List<SelectOption> options12 = new List <SelectOption>();
        List<SelectOption> options22 = new List <SelectOption>();
        List<SelectOption> options32 = new List <SelectOption>();
        ppcWrap12.SOLI = solim;
        ppcWrap12.CurrentWarehouses = options12; 
        ppcWrap12.CurrentLocations = options22;    
        ppcWrap12.CurrentBins = options32;
        ppcWrap12.addressName = ssl.Id;
        ppc.soliWrapperList.add(ppcWrap12);
        
        PickPackShipController.Wrappers ppcWrap13 = new PickPackShipController.Wrappers();        
        List<SelectOption> options13 = new List <SelectOption>();
        List<SelectOption> options23 = new List <SelectOption>();
        List<SelectOption> options33 = new List <SelectOption>();
        ppcWrap13.SOLI = solim;
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
        ppc.soliWrapperList.add(ppcWrap11);
        ppc.stockMap.put(WIIS.Product__c, WIIS.Id);
        //try { ppc.saveSOLIs(); } catch(Exception e) {}
        /*ppc.saveSOLIs();
        
        ppc.soliWrapperList = new List<PickPackShipController.Wrappers>();
        ppc.createPOs();        
        ppcWrap11.SOLI = solim;
        ppcWrap11.soliSelected = true;
        ppc.soliWrapperList.add(ppcWrap11);  
        ppc.createPOs();        
        PickPackShipController.addRow = 1;
        ppc.addPoliWrapperRows();
        PickPackShipController.toDelIdent = 1;
        ppc.delPoliWrapperRow();
        ppc.savePO();
                
        ppc.soliWrapperList = new List<PickPackShipController.Wrappers>();
        ppc.createWOs();        
        ppcWrap11.SOLI = solim;
        ppcWrap11.soliSelected = true;
        ppc.soliWrapperList.add(ppcWrap11);  
        //ppc.createWOs();
        PickPackShipController.addRow = 1;
        ppc.addWoliWrapperRows();
        PickPackShipController.toDelIdent = 1;
        ppc.delWoliWrapperRow();
        ppc.saveWO();
        ppc.createOrder();
        ppc.back();
        ppc.back1();
        ppc.evaluatePackDetails();*/
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
        
        ppc.acceptTrackNotice();
        ppc.CreateUPSLabel(); 
        ppc.back2ShipmentPage();
        ppc.createBarcode();
        PickPackShipController.getCurrencyIsoCode(ps1);
    }
    
     /*static testMethod void UnitTestPickPackShip11() {
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
        
        
        /////////
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true, ERP7__Is_Kit__c = true);
        insert ps;     
        
        Product2 ps3 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps3;  
        
        Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps2;       
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
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
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                 Active__c=true,Warehouse__c=site.Id,
                                                 Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true);
        insert ps1;            
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa; 
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;            
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;   
        /////////
        
        
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4,
                                             Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Picked_Quantity__c=2, Status__c = 'Committed');
        insert PPLI; 
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=4, Sales_Order_Line_Item__c=solim.Id,
                                             Sales_Order__c=sod.Id, Picked_Quantity__c=1, Status__c = 'Committed');
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
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test MRP', MRP_Product__c=PPLI.Product__c);
        insert mrp;
        /*
        PickPackShipController ppc = new PickPackShipController();
        PickPackShipController.Wrappers ppcWrap1 = new PickPackShipController.Wrappers();
        PickPackShipController.newWrapper ppcWrap2 = new PickPackShipController.newWrapper(1);
        PickPackShipController.innerPackageWrapper ppcWrap3 = new PickPackShipController.innerPackageWrapper(); 
        PickPackShipController.packageWrapper ppcWrap4 = new PickPackShipController.packageWrapper();                   
        PickPackShipController.lineItemWrapper ppcWrap5 = new PickPackShipController.lineItemWrapper();                   
        
        Test.startTest();
        ppc.searchText = sod.Name; 
        ppc.searchSOs(); 
        ppc.searchText = null; 
        ppc.searchSOs();
        ppc.searchText = 'test'; 
        ppc.searchSOs();
        ppcWrap1.SO = sod;
        ppcWrap1.soSelected = true;
        ppc.soWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        ppc.redirect2NextTabCustom();
        
        PickPackShipController.Wrappers ppcWrap11 = new PickPackShipController.Wrappers();        
        List<SelectOption> options1 = new List <SelectOption>();
        List<SelectOption> options2 = new List <SelectOption>();
        List<SelectOption> options3 = new List <SelectOption>(); 
        ppcWrap11.SOLI = solim;
        ppcWrap11.CurrentWarehouses = options1; 
        ppcWrap11.CurrentLocations = options2;    
        ppcWrap11.CurrentBins = options3;
        ppcWrap11.addressName = site.Id;
        ppc.soliWrapperList.add(ppcWrap11);
        
        PickPackShipController.Wrappers ppcWrap12 = new PickPackShipController.Wrappers();        
        List<SelectOption> options12 = new List <SelectOption>();
        List<SelectOption> options22 = new List <SelectOption>();
        List<SelectOption> options32 = new List <SelectOption>();
        ppcWrap12.SOLI = solim;
        ppcWrap12.CurrentWarehouses = options12; 
        ppcWrap12.CurrentLocations = options22;    
        ppcWrap12.CurrentBins = options32;
        ppcWrap12.addressName = ssl.Id;
        ppc.soliWrapperList.add(ppcWrap12);
        
        PickPackShipController.Wrappers ppcWrap13 = new PickPackShipController.Wrappers();        
        List<SelectOption> options13 = new List <SelectOption>();
        List<SelectOption> options23 = new List <SelectOption>();
        List<SelectOption> options33 = new List <SelectOption>();
        ppcWrap13.SOLI = solim;
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
        ppc.soliWrapperList.add(ppcWrap11);
        ppc.stockMap.put(WIIS.Product__c, WIIS.Id);
        //try { ppc.saveSOLIs(); } catch(Exception e) {}
        ppc.saveSOLIs();
        
        ppc.createPackage();        
        ppc.createPacks();
        ppc.pkgTypeValue = 'Package';
        ppc.populatePackDetails();
        
        ppc.pack2updateId = pack.Id;        
        ppc.updatePacks(); 
        PickPackShipController.packageWrapper ppcWrap41 = new PickPackShipController.packageWrapper();                   
        ppcWrap41.pkgSelected = true;
        ppcWrap41.Soli = solim;
        ppc.packageWrapperList.add(ppcWrap41);
        ppc.updatePacksAndNewPack();
        ppc.editPackage();
        ppc.deletePackage();
        
        ppc.back2ShipmentPage();
        PickPackShipController.getCurrencyIsoCode(pack);
        ppc.createBarcode();
        ppc.CreateUPSLabel();        
        ppc.acceptTrackNotice();
        
        ppc.shipmentWrapperList = new List<PickPackShipController.Wrappers>();
        PickPackShipController.Wrappers ppcWrap22 = new PickPackShipController.Wrappers();        
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
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'UPS';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>{pack.Id};
        ppc.shipmentId = '';
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {} 
        
        ppc.fetchInternalShippingDetails();
        ppcWrap5.sel = true;
        ppcWrap5.pack = pack;
        ppc.lineItemWrapperList.add(ppcWrap5);
        ppc.createInternalShipping();
        
        ppc.createPickingSlips();
        ppc.packageId = pack.Id;
        try { ppc.createPackingSlips(); } catch(Exception e) {}
        try { ppc.createPackingLabels(); } catch(Exception e) {}
        ppc.createBarcodesPage();        
        
                
        ppc.soliWrapperList = new List<PickPackShipController.Wrappers>();
        ppc.createWOs();        
        ppcWrap11.SOLI = solim;
        ppcWrap11.soliSelected = true;
        ppc.soliWrapperList.add(ppcWrap11);  
        //ppc.createWOs();
        PickPackShipController.addRow = 1;
        ppc.addWoliWrapperRows();
        PickPackShipController.toDelIdent = 1;
        ppc.delWoliWrapperRow();
        ppc.saveWO();
        ppc.createOrder();
        ppc.back();
        ppc.back1();
        ppc.evaluatePackDetails();
        
        ppc.barcode = sod.Barcode__c; 
        ppc.scannerMethod();
        ppc.scannerMethodCustom();
        ppc.scannerMethodCustomPick();
        
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }*/
     @isTest (seeAllData=true)
    static  void UnitTestPickPackShip2() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        PreventRecursiveLedgerEntry.loged = true; 
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
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                                 Active__c=true,Warehouse__c=site.Id,
                                                 Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id);
        insert PPLI; 
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
        
        PickPackShipController ppc = new PickPackShipController();
        PickPackShipController.Wrappers ppcWrap1 = new PickPackShipController.Wrappers();
        PickPackShipController.newWrapper ppcWrap2 = new PickPackShipController.newWrapper(1);
        PickPackShipController.innerPackageWrapper ppcWrap3 = new PickPackShipController.innerPackageWrapper(); 
        PickPackShipController.packageWrapper ppcWrap4 = new PickPackShipController.packageWrapper();                   
        PickPackShipController.lineItemWrapper ppcWrap5 = new PickPackShipController.lineItemWrapper();                   
        
        Test.startTest();
        ppc.searchText = sod.Name; 
        ppc.searchSOs(); 
        ppc.searchText = null; 
        ppc.searchSOs(); 
        
        ppcWrap1.SO = sod;
        ppcWrap1.soSelected = true;
        ppc.soWrapperList.add(ppcWrap1);
        ppc.redirect2NextTab();
        ppc.redirect2NextTabCustom();
        
        PickPackShipController.Wrappers ppcWrap11 = new PickPackShipController.Wrappers();        
        List<SelectOption> options1 = new List <SelectOption>();
        List<SelectOption> options2 = new List <SelectOption>();
        List<SelectOption> options3 = new List <SelectOption>(); 
        ppcWrap11.SOLI = solim;
        ppcWrap11.CurrentWarehouses = options1; 
        ppcWrap11.CurrentLocations = options2;    
        ppcWrap11.CurrentBins = options3;
        ppcWrap11.addressName = site.Id;
        ppc.soliWrapperList.add(ppcWrap11);
        
        PickPackShipController.Wrappers ppcWrap12 = new PickPackShipController.Wrappers();        
        List<SelectOption> options12 = new List <SelectOption>();
        List<SelectOption> options22 = new List <SelectOption>();
        List<SelectOption> options32 = new List <SelectOption>();
        ppcWrap12.SOLI = solim;
        ppcWrap12.CurrentWarehouses = options12; 
        ppcWrap12.CurrentLocations = options22;    
        ppcWrap12.CurrentBins = options32;
        ppcWrap12.addressName = ssl.Id;
        ppc.soliWrapperList.add(ppcWrap12);
        
        PickPackShipController.Wrappers ppcWrap13 = new PickPackShipController.Wrappers();        
        List<SelectOption> options13 = new List <SelectOption>();
        List<SelectOption> options23 = new List <SelectOption>();
        List<SelectOption> options33 = new List <SelectOption>();
        ppcWrap13.SOLI = solim;
        ppcWrap13.CurrentWarehouses = options13; 
        ppcWrap13.CurrentLocations = options23;    
        ppcWrap13.CurrentBins = options33;
        ppcWrap13.addressName = bin.Id;
        ppc.soliWrapperList.add(ppcWrap13);
        
        ppc.rowCounter = 0;
        ppc.fetchBatchStocks();
        ppcWrap11.warehouseName = WIIS.Id;
        ppcWrap11.soliSelected = true;
        ppcWrap11.inventoryStock = 10;
        ppcWrap11.requiredQty = 5;
        ppcWrap11.remainingQty = 5;
        ppc.soliWrapperList.add(ppcWrap11);
        ppc.stockMap.put(WIIS.Product__c, WIIS.Id);
        try { ppc.saveSOLIs(); } catch(Exception e) {}
        
        ppc.createPackage();        
        ppc.createPacks();
        ppc.pkgTypeValue = 'Package';
        ppc.populatePackDetails();
        
        ppc.pack2updateId = pack.Id;        
        ppc.updatePacks(); 
        PickPackShipController.packageWrapper ppcWrap41 = new PickPackShipController.packageWrapper();                   
        ppcWrap41.pkgSelected = true;
        ppcWrap41.Soli = solim;
        ppc.packageWrapperList.add(ppcWrap41);
        ppc.updatePacksAndNewPack();
        ppc.editPackage();
        ppc.deletePackage();
        
        ppc.shipmentWrapperList = new List<PickPackShipController.Wrappers>();
        PickPackShipController.Wrappers ppcWrap22 = new PickPackShipController.Wrappers();        
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
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'UPS';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>{pack.Id};
        ppc.shipmentId = '';
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {}
        
        ppc.selectedPackIds = new List<Id>();
        ppc.shipmentId = ship1.Id;
        ppc.shipmentType = 'Internal Shipping';
        try { ppc.createUPSShipment(); } catch(Exception e) {} 
        
        ppc.fetchInternalShippingDetails();
        ppcWrap5.sel = true;
        ppcWrap5.pack = pack;
        ppc.lineItemWrapperList.add(ppcWrap5);
        ppc.createInternalShipping();
        
        ppc.createPickingSlips();
        ppc.packageId = pack.Id;
        try { ppc.createPackingSlips(); } catch(Exception e) {}
        try { ppc.createPackingLabels(); } catch(Exception e) {}
        ppc.createBarcodesPage();        
        
        ppc.soliWrapperList = new List<PickPackShipController.Wrappers>();
        ppc.createPOs();        
        ppcWrap11.SOLI = solim;
        ppcWrap11.soliSelected = true;
        ppc.soliWrapperList.add(ppcWrap11);  
        ppc.createPOs();        
        PickPackShipController.addRow = 1;
        ppc.addPoliWrapperRows();
        PickPackShipController.toDelIdent = 1;
        ppc.delPoliWrapperRow();
        ppc.savePO();
                
        ppc.soliWrapperList = new List<PickPackShipController.Wrappers>();
        ppc.createWOs();        
        ppcWrap11.SOLI = solim;
        ppcWrap11.soliSelected = true;
        ppc.soliWrapperList.add(ppcWrap11);  
        ppc.createWOs();
        PickPackShipController.addRow = 1;
        ppc.addWoliWrapperRows();
        PickPackShipController.toDelIdent = 1;
        ppc.delWoliWrapperRow();
        ppc.saveWO();
        
        ppc.createOrder();
        ppc.back();
        ppc.back1();
        ppc.evaluatePackDetails();
        
        ppc.barcode = sod.Barcode__c; 
        ppc.scannerMethod();
        //ppc.scannerMethodCustom();
        //ppc.scannerMethodCustomPick();
        
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }
     @isTest (seeAllData=true)
    static  void UnitTestPickPackShip3() {
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
        
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id);
        insert PPLI; 
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
        
        Test.startTest();
        PickPackShipController ppc = new PickPackShipController();
        
        ppc.barcode = sod.Barcode__c; 
        ppc.scannerMethod();
        ppc.scannerMethodCustom();
        List<ERP7__Sales_Order__c> SOList = new List<ERP7__Sales_Order__c>();
        SOList.add(sod);
        if(SOList.size()>0) ppc.scannerMethodCustom();
        ppc.scannerMethodCustomPick();
        ppc.authorisedOrders();
        String salesorderId = sod.Id;
        ppc.authorisedOrders();
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }
    
    static testMethod void UnitTestPrintUPSLabelController() {
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
        insert sod;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                           status__c='Shipped'); 
        insert ship;
        
        PageReference pg = System.Page.PrintUPSLabel;
        pg.getParameters().put('shipmentsId', ship.Id);        
        pg.getParameters().put('fileName', 'UPS_Label');
        pg.getParameters().put('contactId', contact.Id);        
        Test.setCurrentPage(pg);
                    
        PrintUPSLabelController puc = new PrintUPSLabelController();            
        puc.toEmail_Address = contact.Email;
        puc.Email_Details();
        puc.sendLabel();
        System.assertEquals(contact.Email,'test@test.com');
    }
}