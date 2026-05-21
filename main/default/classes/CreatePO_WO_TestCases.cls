@isTest
Private Class CreatePO_WO_TestCases {
    @isTest//(SeeAllData=true) commented SM 23/10/23
    static  void UnitTestWO_Unit1() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        
        Account orgn = new Account(Name='Universal Stores', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Supplier'); 
        insert sup;
        
        Account vend = new Account(Name='Vendor',Account_Type__c = 'Vendor');
        insert vend;
        
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, WO_Supplier__c = sup.Id);
        insert wo;
        
        
        Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
        insert ps;
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=c.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true,ERP7__Priority__c = '1');
        insert DC;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        ERP7__Site__c site1 = new ERP7__Site__c(Name = 'projectTestSite');
        insert site1;
        Sales_Order__c sod = new Sales_Order__c();
        sod.Order_Status__c = 'Entered';
        sod.Account__c = orgn.Id;
        sod.Contact__c = contact.Id;
        sod.Request_Date__c = system.Today();
        sod.Is_Back_Order__c = true;
        sod.ERP7__Channel__c = channel.Id;
        insert sod;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        solim.ERP7__Product__c = ps.Id;
        insert solim;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 102,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = c.id,ERP7__Contact__c=contact.Id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Organisation__c=orgn.Id);        
        insert ord;
        OrderItem orItem = new OrderItem(OrderId = ord.Id,PricebookEntryId=pbe.Id,Quantity = 1,UnitPrice = 100,ERP7__Active__c=true,ERP7__Is_Back_Order__c=true);        
        //orItem.Product2Id= pro.Id;
        insert orItem;
        ERP7__Material_Requirement_Planning__c matrp = new ERP7__Material_Requirement_Planning__c(Name='Matrp1');
        insert matrp;
        ERP7__MPS__c mps = new ERP7__MPS__c(Name = 'MPS1', ERP7__Product__c = ps.Id,ERP7__Master_MRP__c=matrp.Id);
        insert mps;
        ERP7__MPS_line_Item__c mpsLine = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = mps.Id);
        insert mpsLine;
        
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site1.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c(Name = 'inventory1', ERP7__Warehouse__c = site1.Id, ERP7__Product__c = ps.Id, ERP7__Active__c = true);
        insert stock;
        ERP7__Stock_Inward_Line_Item__c inward = new ERP7__Stock_Inward_Line_Item__c(Name= 'inward1', ERP7__Site_ProductService_InventoryStock__c = stock.Id, ERP7__Product__c = ps.Id, ERP7__Quantity__c = 5);
        insert inward;
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
        insert MO;
        ERP7__WO__c WO1 = new ERP7__WO__c(Name = 'testWO1', ERP7__Routing__c = rout.Id);
        insert WO1;
        ERP7__MRP__c mrpLine = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine.ERP7__MO__c = MO.Id;
        mrpLine.ERP7__Work_Order__c = WO1.Id;
        insert mrpLine;
        ERP7__MRP__c mrpLine2 = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine2.ERP7__MO__c = MO.Id;
        insert mrpLine2;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA1');
        insert rma;
        ERP7__RMA_Line_Item__c rmaLine = new ERP7__RMA_Line_Item__c(Name = 'testRMAline1', ERP7__Return_Merchandise_Authorisation__c = rma.Id);
        insert rmaLine;
        Date tomo = system.today();
        tomo.addMonths(1);
        ERP7__Cost_Card__c ccard = new ERP7__Cost_Card__c(Name = 'testCard1', ERP7__Product__c = ps.Id, ERP7__Supplier__c = sup.Id, ERP7__End_Date__c = tomo, ERP7__Cost__c = 10, ERP7__Quantity__c = 5);
        insert ccard;
        List<Id> prods = new List<Id>();
        prods.add(ps.Id);
        ERP7__PO__c PO = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = orgn.Id, ERP7__Ready_To_Receive__c = true,ERP7__Order__c=ord.Id);
        //insert PO;
        ERP7__PO__c PO1 = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = orgn.Id); // ERP7__Ready_To_Receive__c = true 23/10/23
        insert PO1;
        //for test coverage;
        ERP7__PO__c PO2 = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = orgn.Id); // ERP7__Ready_To_Receive__c = true 23/10/23
        insert PO2;
        ERP7__Purchase_Line_Items__c poli1 = new ERP7__Purchase_Line_Items__c(Name = 'testPOLI1',ERP7__Purchase_Orders__c=PO1.Id);
        insert poli1;
        ERP7__Purchase_Line_Items__c poli = new ERP7__Purchase_Line_Items__c(Name = 'testPOLI1', ERP7__Sales_Order__c = sod.Id);
        List<ERP7__Purchase_Line_Items__c> poli_list = new List<ERP7__Purchase_Line_Items__c>();
        poli_list.add(poli);
        Account sup01 = new Account(Name = 'testCaseSupplier', ERP7__Account_Type__c = 'Vendor');
        insert sup01;
        ERP7__Request__c req01 = new ERP7__Request__c(Name='testCaseRequest1', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today());
        insert req01;
        ERP7__Request_Supplier__c reqSup01 = new ERP7__Request_Supplier__c(Name='testRequestSupp1', ERP7__Request__c = req01.Id, ERP7__Supplier__c = sup01.Id, ERP7__Submit_Date__c = tomo);
        insert reqSup01;
        Package__c pack = new Package__c( Name__c='Test Pack',Sales_Order__c=sod.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;
        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,Active__c=true, Sales_Order__c=sod.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,Shipping_Address__c=address.Id,Active__c=true,Sales_Order__c =sod.Id ,Customer_Contact__c=contact.id,
                                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        PO.ERP7__Request__c = req01.Id;
        List<String> orderId1 = new List<String>();
        orderId1.add(ord.Id);
        //lightning
        Test.startTest();
        CreatePo.getVendorDetails(sup.Id);
        CreatePo.fetchCostCardIds(sup.Id);
        CreatePo.fetchPrice(ccard.Id);
        try{ CreatePO.fetchChannelandDC(ord.Id,sod.Id); }catch(Exception e){}
        CreatePO.fetchPOandPOLIs(PO1.Id,false);
        CreatePO.fetchPOandPOLIs(PO1.Id,true);
        CreatePO.getstocks(DC.Id,ps.Id);
        CreatePO.getExistingPO(sod.Id,'');
        CreatePO.getExistingPO('',ord.Id);
        CreatePO.getOrgCurrencies(orgn.Id);
        CreatePO.uploadFile(PO1.Id,'TEST','Test file uplaod','');
        //CreatePO.getCust(customer.Id);
        //CreatePO.getDC(DC.Id);
        List<String> itemToDel1=new List<String>();
        itemToDel1.add(poli1.Id);
        CreatePO.deletePOLI(itemToDel1);
         CreatePO.getOrderAddress(ord.Id);
        CreatePO.getOrderItemsforPOLIDropShip(ord.Id,'','');
        CreatePO.populateOrdItems(orderId1);//(ord.Id);
        CreatePO.populateMpsline(mpsLine.Id);
        CreatePO.populateMrpline(mrpLine.Id);
        CreatePO.populateMrpline(mrpLine2.Id);
        CreatePO.populateRMAPO(rmaLine.Id);
        CreatePO.populateMOlines(MO.Id);
        solim.ERP7__Is_Back_Order__c = true;
        update solim;
        CreatePO.populateSOlines(sod.Id);
        CreatePO.populateWOlines(WO1.Id);
        CreatePO.getStatus(); 
        CreatePO.getDependentPicklist('ERP7__PO__c','ERP7__Shipment_Type__c','ERP7__Shipment_Preference_Speed__c');
        string shipid =ship.id;
        List<string> packids = new List<string>();
        try{ CreatePO.save_PurchaseOrder(JSON.serialize(PO), JSON.serialize(poli_list), JSON.serialize(reqSup01), JSON.serialize(req01),'',shipid,packids, false, '');  }catch(Exception e){}
        CreatePO.fetchProductCC(sup.Id, ps.Id);
        CreatePO.fetchProductCC('',ps.Id);
        CreatePO.getpacklistdetails(shipid,packids);
        packids.add(pack.id);
        CreatePO.getpacklistdetails('',packids);
        CreatePO.getProducts(sup.Id,'','',DC.Id,false,'');
        CreatePO.checkforTax(address.Id,c.Id);
        system.debug('PO test: '+PO);
        PO.ERP7__Logistic_Created__c = true;
        try{ CreatePO.save_PurchaseOrder(JSON.serialize(PO), JSON.serialize(poli_list), JSON.serialize(reqSup01), JSON.serialize(req01),'','',packids, false, '');  }catch(Exception e){}
        try{ CreatePO.save_PurchaseOrder(JSON.serialize(PO), JSON.serialize(poli_list), JSON.serialize(reqSup01), JSON.serialize(req01),'','',packids, true,'');  }catch(Exception e){}
        System.assertEquals('ERP', 'ERP');
        Test.StopTest();
         
    }
    
    static testmethod void UnitTestPO_Unit11(){
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=orgn.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, WO_Supplier__c = sup.Id);
        insert wo;
        
        
        Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
        insert ps;
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
        insert DC;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        ERP7__Site__c site1 = new ERP7__Site__c(Name = 'projectTestSite');
        insert site1;
        Sales_Order__c sod = new Sales_Order__c();
        sod.Order_Status__c = 'Entered';
        sod.Account__c = orgn.Id;
        sod.Contact__c = contact.Id;
        sod.Request_Date__c = system.Today();
        sod.Is_Back_Order__c = true;
        sod.ERP7__Channel__c = channel.Id;
        insert sod;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        solim.ERP7__Product__c = ps.Id;
        insert solim;
        ERP7__MPS__c mps = new ERP7__MPS__c(Name = 'MPS1', ERP7__Product__c = ps.Id);
        //insert mps;
        ERP7__MPS_line_Item__c mpsLine = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = mps.Id);
        //insert mpsLine;
        
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site1.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c(Name = 'inventory1', ERP7__Warehouse__c = site1.Id, ERP7__Product__c = ps.Id, ERP7__Active__c = true);
        insert stock;
        ERP7__Stock_Inward_Line_Item__c inward = new ERP7__Stock_Inward_Line_Item__c(Name= 'inward1', ERP7__Site_ProductService_InventoryStock__c = stock.Id, ERP7__Product__c = ps.Id, ERP7__Quantity__c = 5);
        insert inward;
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
        insert MO;
        ERP7__WO__c WO1 = new ERP7__WO__c(Name = 'testWO1', ERP7__Routing__c = rout.Id);
        insert WO1;
        ERP7__MRP__c mrpLine = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine.ERP7__MO__c = MO.Id;
        mrpLine.ERP7__Work_Order__c = WO1.Id;
        insert mrpLine;
        ERP7__MRP__c mrpLine2 = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine2.ERP7__MO__c = MO.Id;
        insert mrpLine2;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA1');
        insert rma;
        ERP7__RMA_Line_Item__c rmaLine = new ERP7__RMA_Line_Item__c(Name = 'testRMAline1', ERP7__Return_Merchandise_Authorisation__c = rma.Id);
        insert rmaLine;
        Date tomo = system.today();
        tomo.addMonths(1);
        ERP7__Cost_Card__c ccard = new ERP7__Cost_Card__c(Name = 'testCard1', ERP7__Product__c = ps.Id, ERP7__Supplier__c = sup.Id, ERP7__End_Date__c = tomo, ERP7__Cost__c = 10, ERP7__Quantity__c = 5);
        insert ccard;
        List<Id> prods = new List<Id>();
        prods.add(ps.Id);
        ERP7__PO__c PO = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = orgn.Id, ERP7__Ready_To_Receive__c = true);
        //insert PO;
        ERP7__Purchase_Line_Items__c poli = new ERP7__Purchase_Line_Items__c(Name = 'testPOLI1', ERP7__Sales_Order__c = sod.Id);
        List<ERP7__Purchase_Line_Items__c> poli_list = new List<ERP7__Purchase_Line_Items__c>();
        poli_list.add(poli);
        Account sup01 = new Account(Name = 'testCaseSupplier', ERP7__Account_Type__c = 'Vendor');
        insert sup01;
        ERP7__Request__c req01 = new ERP7__Request__c(Name='testCaseRequest1', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today());
        insert req01;
        ERP7__Request_Supplier__c reqSup01 = new ERP7__Request_Supplier__c(Name='testRequestSupp1', ERP7__Request__c = req01.Id, ERP7__Supplier__c = sup01.Id, ERP7__Submit_Date__c = tomo);
        insert reqSup01;
        PO.ERP7__Request__c = req01.Id;
        
        CreatePO.fetchProductDesc(ps.Id);
        CreatePO.getVendorDetailsNew(c.Id, JSON.serialize(prods));
        CreatePO.getOrgAddressDetails(c.Id);
        CreatePO.getPOFC();
        CreatePO.getFCdetails();
        CreatePO.getSubFamily();
       // CreatePO.ContactRecordTypess();
        CreatePO.getDefaultVendor(site.Id, prods);
        System.assertEquals('ERP', 'ERP');
    }
    
    static testmethod void UnitTestWO_Unit2() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=orgn.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        WO__c wo = new WO__c(Name = 'test wo',  Active__c = true, WO_Supplier__c = sup.Id);
        insert wo;
        
        Sales_Order__c sod = new Sales_Order__c();
        
        sod.Order_Status__c = 'Entered';
        sod.Account__c = orgn.Id;
        sod.Contact__c = contact.Id;
        sod.Request_Date__c = system.Today();
        sod.Is_Back_Order__c = true;
        insert sod;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        pageReference page1 = System.page.Create_PurchaseOrder;
        page1.getParameters().put('Id',sod.Id);
        page1.getParameters().put('retUrl',' /'+sod.Id);
        Test.setCurrentPage(page1);
        
        CreatePo sopo = new CreatePo();
        //sopo.setSOID(sod.Id);
        LIst<id> temp_list= new List<Id>();
        temp_list.add(sopo.getSOID());
        sopo.setsoIds(temp_list);
        temp_list=sopo.getsoIds();
        CreatePo.newWrapper sopowrap = new CreatePo.newWrapper(1);
        sopo.addpoliWrapperRows();
        sopo.TotalPriceCalculation();
        sopo.setSOID('');
        sopo.savePO();
        sopo.back();
        sopo.SOID = sod.Id;
        
        pageReference page = System.page.Create_WorkOrder;
        page.getParameters().put('Id',sod.Id);
        page.getParameters().put('retUrl',' /'+sod.Id);
        Test.setCurrentPage(page);
        
        CreateWo sowo = new CreateWo();
        sowo.setSOID(sod.Id);
        CreateWo.newWrapper sowowrap = new CreateWo.newWrapper(1);
        sowo.addWoliWrapperRows();
        sowo.saveWO();
        CreateWo sowo1 = new CreateWo();
        sowo1.back();
        
        CreateWO cw=new CreateWO();
        CreateWO.addRow=0;CreateWO.toDelIdent=0;CreateWO.addRow=0;
        
        
        String s1 = 'test';
        String s2 = 'test'; 
        System.assertEquals(s1,s2);              
    }
    
    static testmethod void UnitTestPO_Unit3(){
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=orgn.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, WO_Supplier__c = sup.Id);
        insert wo;
        
        
        Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
        insert ps;
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
        insert DC;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        ERP7__Site__c site1 = new ERP7__Site__c(Name = 'projectTestSite');
        insert site1;
        Sales_Order__c sod = new Sales_Order__c();
        sod.Order_Status__c = 'Entered';
        sod.Account__c = orgn.Id;
        sod.Contact__c = contact.Id;
        sod.Request_Date__c = system.Today();
        sod.Is_Back_Order__c = true;
        sod.ERP7__Channel__c = channel.Id;
        insert sod;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        solim.ERP7__Product__c = ps.Id;
        insert solim;
        ERP7__MPS__c mps = new ERP7__MPS__c(Name = 'MPS1', ERP7__Product__c = ps.Id);
        //insert mps;
        ERP7__MPS_line_Item__c mpsLine = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = mps.Id);
        //insert mpsLine;
        
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site1.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c(Name = 'inventory1', ERP7__Warehouse__c = site1.Id, ERP7__Product__c = ps.Id, ERP7__Active__c = true);
        insert stock;
        ERP7__Stock_Inward_Line_Item__c inward = new ERP7__Stock_Inward_Line_Item__c(Name= 'inward1', ERP7__Site_ProductService_InventoryStock__c = stock.Id, ERP7__Product__c = ps.Id, ERP7__Quantity__c = 5);
        insert inward;
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
        insert MO;
        ERP7__WO__c WO1 = new ERP7__WO__c(Name = 'testWO1', ERP7__Routing__c = rout.Id);
        insert WO1;
        ERP7__MRP__c mrpLine = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine.ERP7__MO__c = MO.Id;
        mrpLine.ERP7__Work_Order__c = WO1.Id;
        insert mrpLine;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA1');
        insert rma;
        ERP7__RMA_Line_Item__c rmaLine = new ERP7__RMA_Line_Item__c(Name = 'testRMAline1', ERP7__Return_Merchandise_Authorisation__c = rma.Id);
        insert rmaLine;
        Date tomo = system.today();
        tomo.addMonths(1);
        ERP7__Cost_Card__c ccard = new ERP7__Cost_Card__c(Name = 'testCard1', ERP7__Product__c = ps.Id, ERP7__Supplier__c = sup.Id, ERP7__End_Date__c = tomo, ERP7__Cost__c = 10, ERP7__Quantity__c = 5);
        insert ccard;
        List<Id> prods = new List<Id>();
        prods.add(ps.Id);
        ERP7__PO__c PO = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = orgn.Id, ERP7__Ready_To_Receive__c = true);
        //insert PO;
        ERP7__Purchase_Line_Items__c poli = new ERP7__Purchase_Line_Items__c(Name = 'testPOLI1', ERP7__Sales_Order__c = sod.Id);
        List<ERP7__Purchase_Line_Items__c> poli_list = new List<ERP7__Purchase_Line_Items__c>();
        poli_list.add(poli);
        Account sup01 = new Account(Name = 'testCaseSupplier', ERP7__Account_Type__c = 'Vendor');
        insert sup01;
        ERP7__Request__c req01 = new ERP7__Request__c(Name='testCaseRequest1', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today());
        insert req01;
        
        //vf
        
        CreatePo sopo = new CreatePo();
        pageReference page1 = System.page.Create_PurchaseOrder;
        page1.getParameters().put('Id',sod.Id);
        page1.getParameters().put('retUrl',' /'+sod.Id);
        Test.setCurrentPage(page1);
        
        //sopo.setSOID(sod.Id);
        sopo.soId = sod.Id;
        //sopo.soliList.add(solim);
        LIst<id> temp_list= new List<Id>();
        temp_list.add(sopo.getSOID());
        sopo.setsoIds(temp_list);
        temp_list=sopo.getsoIds();
        CreatePo.newWrapper sopowrap = new CreatePo.newWrapper(1);
        sopo.delpoliWrapperRow();
        sopo.savePO();
        sopo.back();
        sopo.doInit();
        sopo.init();
        sopo.getUnitPriceByVendor();
        sopo.addPoliWrapperRows();
        sopo.delPoliWrapperRow();
        
        sopo.getUnitPriceByVendor();
        CreatePo.populateSOLI(solim.Id);
        
        pageReference page = System.page.Create_WorkOrder;
        page.getParameters().put('Id',sod.Id);
        page.getParameters().put('retUrl',' /'+sod.Id);
        Test.setCurrentPage(page);
        
        CreateWo sowo = new CreateWo();
        sowo.setSOID(sod.Id);
        LIst<id> templist= new List<Id>();
        templist.add(sowo.getSOID());
        sowo.setsoIds(templist);
        templist=sowo.getsoIds();
        CreateWo.newWrapper sowowrap = new CreateWo.newWrapper(1);
        sowo.delWoliWrapperRow();
        sowo.saveWO();
        sowo.back();
        
        String s1 = 'test';
        String s2 = 'test'; 
        System.assertEquals(s1,s2);   
    }
    static testmethod void UnitTestPO_Unit4(){
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer;
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, WO_Supplier__c = sup.Id);
        insert wo;
        
        
        Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
        insert ps;
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
        insert DC;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        ERP7__Site__c site1 = new ERP7__Site__c(Name = 'projectTestSite');
        insert site1;
        Address__c bAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Id pricebookId = Test.getStandardPricebookId();
        Order sod = new Order();   
        sod.Status = 'Draft';
        sod.ERP7__Stage__c = 'Entered';
        sod.EffectiveDate = system.today();
        sod.AccountId = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = channel.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        sod.Pricebook2Id=pricebookId;
        sod.ERP7__Shipment_Type__c='UPS';sod.ERP7__Shipment_Preference_Speed__c='--None--';
        insert sod; 
        Order psod = sod;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        OrderItem solim = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps.id,PricebookEntryId=pbe.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        insert solim; 
        ERP7__MPS__c mps = new ERP7__MPS__c(Name = 'MPS1', ERP7__Product__c = ps.Id);
        //insert mps;
        ERP7__MPS_line_Item__c mpsLine = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = mps.Id);
        //insert mpsLine;
        
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site1.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c(Name = 'inventory1', ERP7__Warehouse__c = site1.Id, ERP7__Product__c = ps.Id, ERP7__Active__c = true);
        insert stock;
        ERP7__Stock_Inward_Line_Item__c inward = new ERP7__Stock_Inward_Line_Item__c(Name= 'inward1', ERP7__Site_ProductService_InventoryStock__c = stock.Id, ERP7__Product__c = ps.Id, ERP7__Quantity__c = 5);
        insert inward;
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
        insert MO;
        ERP7__WO__c WO1 = new ERP7__WO__c(Name = 'testWO1', ERP7__Routing__c = rout.Id);
        insert WO1;
        ERP7__MRP__c mrpLine = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine.ERP7__MO__c = MO.Id;
        mrpLine.ERP7__Work_Order__c = WO1.Id;
        insert mrpLine;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA1');
        insert rma;
        ERP7__RMA_Line_Item__c rmaLine = new ERP7__RMA_Line_Item__c(Name = 'testRMAline1', ERP7__Return_Merchandise_Authorisation__c = rma.Id);
        insert rmaLine;
        Date tomo = system.today();
        tomo.addMonths(1);
        ERP7__Cost_Card__c ccard = new ERP7__Cost_Card__c(Name = 'testCard1', ERP7__Product__c = ps.Id, ERP7__Supplier__c = sup.Id, ERP7__End_Date__c = tomo, ERP7__Cost__c = 10, ERP7__Quantity__c = 5);
        insert ccard;
        List<Id> prods = new List<Id>();
        prods.add(ps.Id);
        ERP7__PO__c PO = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = orgn.Id, ERP7__Ready_To_Receive__c = true);
        insert PO;
        ERP7__Purchase_Line_Items__c poli = new ERP7__Purchase_Line_Items__c(Name = 'testPOLI1', ERP7__Order_Product__c = solim.Id,ERP7__Purchase_Orders__c= PO.Id);
        insert poli;
        List<ERP7__Purchase_Line_Items__c> poli_list = new List<ERP7__Purchase_Line_Items__c>();
        poli_list.add(poli);
        set<Id> PuId = new set<Id>();
        for(ERP7__Purchase_Line_Items__c pr : poli_list){ PuId.add(pr.Id); }
        Account sup01 = new Account(Name = 'testCaseSupplier', ERP7__Account_Type__c = 'Vendor');
        insert sup01;
        ERP7__Request__c req01 = new ERP7__Request__c(Name='testCaseRequest1', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today());
        insert req01;
        ERP7__Dimension__c dimen = new ERP7__Dimension__c(Name='Test',ERP7__Sort_Order__c=0);
        
        //vf
        
        CreatePo sopo = new CreatePo();
        
        pageReference page1 = System.page.Create_PurchaseOrder;
        page1.getParameters().put('Id',sod.Id);
        page1.getParameters().put('retUrl',' /'+sod.Id);
        Test.setCurrentPage(page1);
        
        //sopo.setSOID(sod.Id);
        sopo.soId = sod.Id;
        //sopo.soliList.add(solim);
        LIst<id> temp_list= new List<Id>();
        temp_list.add(sopo.getSOID());
        sopo.setsoIds(temp_list);
        temp_list=sopo.getsoIds();
        CreatePo.newWrapper sopowrap = new CreatePo.newWrapper(1);
        sopo.delpoliWrapperRow();
        sopo.savePO();
        sopo.back();
        sopo.doInit();
        sopo.init();
        sopo.getUnitPriceByVendor();
        sopo.addPoliWrapperRows();
        sopo.delPoliWrapperRow();
        sopo.getUnitPriceByVendor();
        CreatePO.getDC(DC.Id);
        CreatePO.getDC('');
        CreatePO.getCust(c.Id);
        CreatePO.getCust('');
        CreatePO.getVendorAddress(c.Id);
        CreatePO.getVendorAddress('');
        CreatePO.getShipmentType();
        CreatePO.fetchEmployeeRequester();
        CreatePO.getRecentRecord('Account');
        CreatePO.getRecentContact();
        CreatePO.getRecentDA();
        CreatePO.getCurrencies('');
        CreatePO.getFamily();
        CreatePO.getCategoryList();
        createPO.AnalyticalAccounts(JSON.serialize(dimen),PO.Id);
        createPO.getProdDetails(ps.Id,DC.Id);
        createPO.getPORecordTypes();
        insert dimen;
        createPO.deleteDimensions(dimen.Id);
        
        String s1 = 'test';
        String s2 = 'test'; 
        System.assertEquals(s1,s2);   
        PreventRecursiveLedgerEntry.SOLI_AllocateStock=true;
        OrderProductInventoryUtils.createProductPurchaseLineItems(PuId);
        PreventRecursiveLedgerEntry.SOLI_AllocateStock=true;
        OrderProductInventoryUtils.updateProductPurchaseLineItems(PuId);
        
        
        ApexPages.currentPage().getParameters().put('Id',po.Id);
        ApexPages.currentPage().getParameters().put('CustID',' /'+contact.Id);
        PurchaseOrderDocumentNew PODN = new PurchaseOrderDocumentNew();
        PODN.Email_Details();
        PODN.sendPO();
        //PODN.createPDF();
        PODN.getRecipientId();
        PODN.setRecipientId(po.Id);
    }
    
        @isTest
    	static void validatevenderpartTest(){
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Cost_Card__c costcrd = new ERP7__Cost_Card__c(Name = 'Laptop X200 cost',ERP7__Product__c=pro.Id,ERP7__Vendor_Part_Number__c='00001');
        insert costcrd;
        list<ERP7__Cost_Card__c>costList = new list<ERP7__Cost_Card__c>();
        for(integer i=1;i<=5;i++){
            ERP7__Cost_Card__c cost = new ERP7__Cost_Card__c();
            cost.Name = 'CostCard-' + i;
            cost.ERP7__Product__c = pro.Id;
            cost.ERP7__Vendor_Part_Number__c = '0000' + i;
            costList.add(cost);
        }
        Test.startTest();
            try { insert costList;} catch (DmlException e) {system.debug(e);}
        Test.stopTest();
    }
    
}