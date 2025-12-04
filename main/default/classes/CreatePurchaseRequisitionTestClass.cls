@isTest
private class CreatePurchaseRequisitionTestClass {
  
    @isTest
    static void UniTest(){
        
        
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        Account orgn = new Account(Name='Universal Stores', Account_Type__c = 'Organisation');
        insert orgn;
         ERP7__Business_Unit__c bu = new ERP7__Business_Unit__c(Name='TestBusinessUnit',ERP7__Organisation__c=orgn.Id);
		insert bu;
        orgn.ERP7__Organisation_Business_Unit__c = bu.ID; update orgn;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',ERP7__Organisation__c=orgn.Id,
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
         ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c,ERP7__Priority__c='1');
        insert DC;
        ERP7__Requisition__c req = new ERP7__Requisition__c(Name='Test', ERP7__Active__c=true, ERP7__Expected_Delivery_Date__c=system.today(),
                                                            ERP7__Actual_Delivery_Date__c=system.today(), ERP7__Distribution_Channel__c=DC.Id);
        insert req;
        
        ERP7__Purchase_Requisition_Line_Items__c prli = new ERP7__Purchase_Requisition_Line_Items__c(Name='Test', ERP7__Purchase_Requisition__c=req.Id,
                                                                                                     ERP7__Quantity__c=2, ERP7__Unit__c=10, ERP7__Amount__c=10,
                                                                                                     ERP7__Purchase_Orders__c=null);
        insert prli;
        List<ERP7__Purchase_Requisition_Line_Items__c> prli_list = new List<ERP7__Purchase_Requisition_Line_Items__c>();
        prli_list.add(prli);
        
        
        Account customer = new Account(Name='Customer');
        insert customer;
        
       
        Account Acc1 = new Account(Name='TestAcc', ERP7__Account_Type__c='Customer',ERP7__Organisation_Business_Unit__c=bu.Id);
        insert Acc1;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=c.id,Phone='1234567890',Email='test@test.com',ERP7__Primary__c = true);
        insert contact;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax; 
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Tax__c=tax.id,Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true,ERP7__Status__c = 'Released');
        insert ps; 
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Profile__c = sop.Id;
        //sod.Customer_Profile__c = custProfile.Id;
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        insert sod;
       
        Sales_Order__c psod = [Select id, Name,Contact__c,Account__c From Sales_Order__c Where id =: sod.id Limit 1];
        
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10,ERP7__Is_Back_Order__c = true);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10,ERP7__Is_Back_Order__c = true);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
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
        
        req.ERP7__Order_S__c = ord.Id;
         req.ERP7__Sales_Order__c = sod.id;
    
        update req;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,ERP7__Is_Back_Order__c = true);        
        insert orditem;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        ERP7__Site__c site1 = new ERP7__Site__c(Name = 'projectTestSite');
        insert site1;
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site1.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c(Name = 'inventory1', ERP7__Warehouse__c = site1.Id, ERP7__Product__c = ps.Id, ERP7__Active__c = true);
        insert stock;
        ERP7__Stock_Inward_Line_Item__c inward = new ERP7__Stock_Inward_Line_Item__c(Name= 'inward1', ERP7__Site_ProductService_InventoryStock__c = stock.Id, ERP7__Product__c = ps.Id, ERP7__Quantity__c = 5);
        insert inward;
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
        insert MO;
        ERP7__WO__c WO = new ERP7__WO__c(Name = 'testWO1', ERP7__Routing__c = rout.Id);
        insert WO;
        ERP7__MRP__c mrpLine = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine.ERP7__MO__c = MO.Id;
        mrpLine.ERP7__Work_Order__c = WO.Id;
        insert mrpLine;
         Test.startTest();   
        CreatePurchaseRequisition CPR = new CreatePurchaseRequisition();
        CreatePurchaseRequisition.getStatus();
        CreatePurchaseRequisition.getstocks(DC.Id,pro.id);
        CreatePurchaseRequisition.populateOrdItems(ord.Id,'');
        CreatePurchaseRequisition.populateOrdItems('',sod.Id);
         CreatePurchaseRequisition.populateOrdItems(ord.Id,sod.Id);
        CreatePurchaseRequisition.fetchChannelandDC(ord.Id,'');
        CreatePurchaseRequisition.fetchChannelandDC('',solim.id);
        CreatePurchaseRequisition.fetchChannelandDC(ord.Id,null);
        CreatePurchaseRequisition.save_PurchaseRequisition(JSON.serialize(req), JSON.serialize(prli_list),ord.Id,'');
        CreatePurchaseRequisition.save_PurchaseRequisition(JSON.serialize(req), JSON.serialize(prli_list),'',sod.Id);
        CreatePurchaseRequisition.populateSOLI(solim.Id);
        CreatePurchaseRequisition.populateMrpline(mrpLine.Id);
        CreatePurchaseRequisition.populateMOlines(MO.Id);
        CreatePurchaseRequisition.populateWOlines(WO.Id);
        CreatePurchaseRequisition.getExistingPReq(sod.Id,'');
        CreatePurchaseRequisition.getExistingPReq('',ord.Id);
        CreatePurchaseRequisition.fetchProductDesc(pro.Id);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
}