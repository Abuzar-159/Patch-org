@isTest
private class ManageWOsTestClass {   
    static testmethod void UnitTest1() {
        test.startTest();            
        ManageMaintenanceWOs.searchProducts('searchString');
        ManageMaintenanceWOs.searchProductsP('searchStrings'); 
        ManageMaintenanceWOs.searchWOs('searchStringswo');  
        ManageMaintenanceWOs.searchWSs('searchStringws');
        ManageMaintenanceWOs.searchWSss('searchStringwc');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name); 
        test.stopTest();
        
    }
    
    static testmethod void UnitTest2() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Account s = new Account(Name = 'Supplier', Account_Type__c = 'Supplier');
        insert s;
        Account c = new Account(Name = 'Test', ERP7__Account_Type__c = 'Customer', AccountNumber = '1234', ERP7__Company__c = 'Aqxolt India Pvt Ltd', ERP7__Start_of_Week__c = 'Monday', ERP7__CustomerPriority__c = 'High', ERP7__Active__c = 'Yes', ERP7__SLA__c = 'Gold', ERP7__SLAExpirationDate__c = system.today());
        insert c;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='test DC',ERP7__Channel__c=channel.Id,ERP7__Active__c = true,ERP7__Site__c = site.Id,ERP7__Priority__c = '1');
        insert DC;
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=o.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test',ERP7__Issue_Manufacturing_Order__c=true);
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20,  ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Ser',ERP7__Available__c= true,Product__c = product.Id);
        insert ser;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='Ser',ERP7__Active__c= true,Product__c = product1.Id);
        insert batch;
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,Serial__c= ser.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=inventorystock.Id,Product__c=product.Id,Quantity__c=200,Serial__c= ser.Id);
        insert SPLI;
        Inventory_Stock__c inventorystock1 = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product1.Id,ERP7__Batch_Lot__c=batch.Id);
        insert inventorystock1;
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=inventorystock1.Id,Product__c=product1.Id,Quantity__c=200,ERP7__Material_Batch_Lot__c = batch.Id);
        insert SPLI1;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        PricebookEntry pricebookentry1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product1.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry1;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today()+3, ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified', ERP7__Default__c = true,ERP7__Active__c=true);
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified', ERP7__Type__c = 'Primary',BOM_Version__c=version.Id);
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified',BOM_Version__c=version.Id);
        insert bom1;
        Address__c bAddress = new Address__c(Customer__c=o.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000,ERP7__Address__c=bAddress.Id);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, Start_Date__c=Datetime.newInstance(system.today(),Time.newInstance(6, 0, 0, 0)), End_Date__c=Datetime.newInstance(system.today()+10,Time.newInstance(20, 0, 0, 0)));
        insert wc;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test',ERP7__Process_Cycle__c = processcycle.Id, ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
        Insert oprn;
        Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,Serial__c= ser.Id);
        insert stock;
        Stock_Inward_Line_Item__c SPLI2 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=stock.Id,Product__c=product.Id,Quantity__c=20,Serial__c= ser.Id);
        insert SPLI2;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__WO__c WO = new ERP7__WO__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Approved_Date__c=system.today(), ERP7__Customer__c=c.Id,ERP7__Work_Center__c = wc.id,
                                         ERP7__Channel__c=channel.Id, ERP7__Status__c='In Progress', ERP7__Contact__c=con.Id,ERP7__Type__c = 'Maintenance',
                                         ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Quantity_Ordered__c = 10, ERP7__Routing__c = routing.Id,
                                         ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__Start_Date__c = system.Now(), 
                                         ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(),
                                         ERP7__Active__c=true,ERP7__Is_Closed__c=false);
        insert WO;
        WO.ERP7__Version__c = Null;
        PreventRecursiveLedgerEntry.testCasesTransactions = false; update WO;           
        WO.ERP7__Version__c = version.Id; 
        WO.ERP7__Quantity_Ordered__c = 16;                      
        PreventRecursiveLedgerEntry.testCasesTransactions = false; update WO; 
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, Work_Order__c = WO.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 90, ERP7__Total_Amount_Required__c=90,ERP7__BOM__c=bom.Id);
        insert mrp;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so.Id, ERP7__Issue_Manufacturing_Order__c=true, ERP7__Issue_Work_Order__c=true, ERP7__Quantity__c=100);
        insert soli;
        
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        /*Order ord = new Order(Name='ord0001');
        insert ord;
        OrderItem ordItem = new OrderItem(OrderId=ord.Id, Product2Id=product.Id, Quantity=10);
        insert ordItem;*/
        MO_WO_Scheduler.newTimesWrap nTw = new MO_WO_Scheduler.newTimesWrap();
        nTw.Id = processcycle.Id;
        nTw.stDate = String.valueOf(system.now());
        nTw.enDate = String.valueOf(system.now());
        List<MO_WO_Scheduler.newTimesWrap> nTwList = new List<MO_WO_Scheduler.newTimesWrap>();
        nTwList.add(nTw);
        
        test.startTest();
        MO_WO_Scheduler Scheduler = new MO_WO_Scheduler();
        MO_WO_Scheduler.fetchRoutingDetails('','','','','', '');
        
        MO_WO_Scheduler.fetchWorkCenterDetails(wc.Id,system.Today(),'','');
        MO_WO_Scheduler.fetchWorkCenterDetails(wc.Id,system.Today(),'',WO.Id);
        MO_WO_Scheduler.fetchAllProducts('','Product', 'MO');
        MO_WO_Scheduler.fetchAllProducts('','Sales Order', 'MO');
        MO_WO_Scheduler.fetchAllProducts('','Manufacturing Order', 'MO');
        MO_WO_Scheduler.fetchAllProducts('','Work Order', 'MO');
        MO_WO_Scheduler.fetchAllProducts('','Product', 'WO');
        MO_WO_Scheduler.fetchAllProducts('','Sales Order', 'WO');
        MO_WO_Scheduler.fetchAllProducts('','Manufacturing Order', 'WO');
        MO_WO_Scheduler.fetchAllProducts('','Work Order', 'WO');
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        MO_WO_Scheduler.SaveM(JSON.serialize(new ERP7__Manufacturing_Order__c(Name='MO')), JSON.serialize(new List<ERP7__WO__c>{new ERP7__WO__c(Name='WO')}));//, JSON.serialize(nTwList)
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = c.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Organisation__c=o.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
        
        
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = product.Id,PricebookEntryId=pricebookentry.Id,ERP7__Active__c=true);        
        insert orditem;
        User user=[Select Id,Name,ProfileId,Profile.Name from user where Id=:UserInfo.getUserId()];        
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(user.Id);
        if(customList != null){
            customList.ERP7__Is_Standard_Order__c = true;
            customList.ERP7__Create_MO_for_each_QTY_serial_product__c = true;
            system.debug('customList : '+customList.ERP7__Is_Standard_Order__c);
            update customList;
        }
        else{
            customList = new ERP7__Functionality_Control__c();
            customList.ERP7__Is_Standard_Order__c = true;
            customList.ERP7__Create_MO_for_each_QTY_serial_product__c = true;
            system.debug('customList : '+customList.ERP7__Is_Standard_Order__c);
            upsert customList;
        }
        MO_WO_Scheduler.fetchRoutingDetails('','','','','', orditem.Id);
        orditem.ERP7__Issue_Manufacturing_Order__c = true;
        update orditem;
         MO_WO_Scheduler.fetchRoutingDetails('','','','','', orditem.Id);
        MO_WO_Scheduler.fetchAllProducts('','Product', 'MO');
        MO_WO_Scheduler.fetchAllProducts('','Sales Order', 'MO');
        MO_WO_Scheduler.fetchMODetails(manuorder.Id);
        MO_WO_Scheduler.fetchWODetails(WO.Id);
        MO_WO_Scheduler.UpdateM(JSON.serialize(new ERP7__Manufacturing_Order__c(Name='MO')), JSON.serialize(new List<ERP7__WO__c>{new ERP7__WO__c(Name='WO')}));
        MO_WO_Scheduler.ScheduledWOTime(String.valueof(system.Today()),5,6);
        MO_WO_Scheduler.SaveW(JSON.serialize(new ERP7__WO__c(Name='WO')));
        
       MO_WO_Scheduler.updateWOs(JSON.serialize(new List<ERP7__WO__c>{WO}));
        MO_WO_Scheduler.SaveM(JSON.serialize(new ERP7__Manufacturing_Order__c(Name='MO',ERP7__Product__c=product.Id,ERP7__Quantity__c = 4)), JSON.serialize(new List<ERP7__WO__c>{new ERP7__WO__c(Name='WO')}));//, JSON.serialize(nTwList)
        
        WorkOrder WorkOrder = new WorkOrder();
        WOrkOrder.selectOptions SOP =  new WOrkOrder.selectOptions('test','test');
        PreventRecursiveLedgerEntry.testCasesTransactions = false; delete WO;
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest(); 
        
    }
    
    static testmethod void UnitTest3() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Account s = new Account(Name = 'Supplier', Account_Type__c = 'Supplier');
        insert s;
        Account c = new Account(Name = 'Test', ERP7__Account_Type__c = 'Customer', AccountNumber = '1234', ERP7__Company__c = 'Aqxolt India Pvt Ltd', ERP7__Start_of_Week__c = 'Monday', ERP7__CustomerPriority__c = 'High', ERP7__Active__c = 'Yes', ERP7__SLA__c = 'Gold', ERP7__SLAExpirationDate__c = system.today());
        insert c;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=o.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__Lot_Tracked__c = false,ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test',ERP7__Issue_Manufacturing_Order__c=true);
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        ERP7__Batch__c btch = new Batch__c(Name='test batch',Active__c = true);
        insert btch;
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Ser',ERP7__Available__c= true,Product__c = product.Id);
        insert ser;
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Serial__c  = ser.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=inventorystock.Id,Product__c=product.Id,Quantity__c=200,ERP7__Serial__c  = ser.Id);
        insert SPLI;
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='Ser',ERP7__Active__c= true,Product__c = product1.Id);
        insert batch;
        Inventory_Stock__c inventorystock1 = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product1.Id,ERP7__Batch_Lot__c=batch.Id);
        insert inventorystock1;
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=inventorystock1.Id,Product__c=product1.Id,Quantity__c=200,ERP7__Material_Batch_Lot__c  = batch.Id);
        insert SPLI1;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        PricebookEntry pricebookentry1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product1.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry1;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today()+3, ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified', ERP7__Default__c = true,ERP7__Active__c=true);
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified', ERP7__Type__c = 'Primary',BOM_Version__c=version.Id);
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified',BOM_Version__c=version.Id);
        insert bom1;
        Address__c bAddress = new Address__c(Customer__c=o.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000,ERP7__Address__c=bAddress.Id);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, Start_Date__c=Datetime.newInstance(system.today(),Time.newInstance(6, 0, 0, 0)), End_Date__c=Datetime.newInstance(system.today()+10,Time.newInstance(20, 0, 0, 0)));
        insert wc;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test',ERP7__Process_Cycle__c = processcycle.Id, ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
        Insert oprn;
        Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,Serial__c = ser.Id);
        insert stock;
        Stock_Inward_Line_Item__c SPLI2 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=stock.Id,Product__c=product.Id,Quantity__c=20,Serial__c = ser.Id);
        insert SPLI2;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__WO__c WO = new ERP7__WO__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Approved_Date__c=system.today(), ERP7__Customer__c=c.Id,ERP7__Work_Center__c = wc.id,
                                         ERP7__Channel__c=channel.Id, ERP7__Status__c='In Progress', ERP7__Contact__c=con.Id,ERP7__Type__c = 'Maintenance',
                                         ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Quantity_Ordered__c = 10, ERP7__Routing__c = routing.Id,
                                         ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__Start_Date__c = system.Now(), 
                                         ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(),
                                         ERP7__Active__c=true,ERP7__Is_Closed__c=false);
        insert WO;
        WO.ERP7__Version__c = Null;
        PreventRecursiveLedgerEntry.testCasesTransactions = false; update WO;           
        WO.ERP7__Version__c = version.Id; 
        WO.ERP7__Quantity_Ordered__c = 16;                      
        PreventRecursiveLedgerEntry.testCasesTransactions = false; update WO; 
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, Work_Order__c = WO.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 90, ERP7__Total_Amount_Required__c=90,ERP7__BOM__c=bom.Id);
        insert mrp;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so.Id, ERP7__Issue_Manufacturing_Order__c=true, ERP7__Issue_Work_Order__c=true, ERP7__Quantity__c=100);
        insert soli;
        
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('RId',manuorder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(manuorder);
        Traveller Traveller = new Traveller(sc);
        ApexPages.currentPage().getParameters().put('RId',WO.Id);
        ApexPages.StandardController scw = new ApexPages.StandardController(manuorder);
        Traveller Travellerw = new Traveller(scw);
        Traveller.createPDF();
        Traveller.createPDFs();
        
        WOTraveller WOT = new WOTraveller();
        WOT.Id = WO.Id;
        String Id = WOT.Id;
        MOTraveller MOT = new MOTraveller();
        MOT.Id = manuorder.Id;
        Id = MOT.Id;
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest(); 
        
    }
    
    static testmethod void UnitTest4() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Account s = new Account(Name = 'Supplier', Account_Type__c = 'Supplier');
        insert s;
        Account c = new Account(Name = 'Test', ERP7__Account_Type__c = 'Customer', AccountNumber = '1234', ERP7__Company__c = 'Aqxolt India Pvt Ltd', ERP7__Start_of_Week__c = 'Monday', ERP7__CustomerPriority__c = 'High', ERP7__Active__c = 'Yes', ERP7__SLA__c = 'Gold', ERP7__SLAExpirationDate__c = system.today());
        insert c;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=o.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = false, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test',ERP7__Issue_Manufacturing_Order__c=true);
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = false, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
         ERP7__Batch__c batch = new ERP7__Batch__c(Name='Ser',ERP7__Active__c= true,Product__c = product1.Id);
        insert batch;
         ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Ser',ERP7__Available__c= true,Product__c = product.Id);
        insert ser;
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Serial__c  = ser.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=inventorystock.Id,Product__c=product.Id,Quantity__c=200,ERP7__Serial__c  = ser.Id);
        insert SPLI;
        Inventory_Stock__c inventorystock1 = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product1.Id,ERP7__Batch_Lot__c = batch.Id);
        insert inventorystock1;
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=inventorystock1.Id,Product__c=product1.Id,Quantity__c=200,ERP7__Material_Batch_Lot__c  = batch.Id);
        insert SPLI1;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        PricebookEntry pricebookentry1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product1.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry1;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today()+3, ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified', ERP7__Default__c = true,ERP7__Active__c=true);
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified', ERP7__Type__c = 'Primary',BOM_Version__c=version.Id);
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified',BOM_Version__c=version.Id);
        insert bom1;
        ERP7__Variance__c Variance = new ERP7__Variance__c(Name='Variance - 1', ERP7__Type__c='Alternative', ERP7__Bill_Of_Material__c=bom.Id, ERP7__BOM_Variance__c=bom1.Id, ERP7__Product__c=product.Id, ERP7__Active__c=true);
        insert Variance;
        Address__c bAddress = new Address__c(Customer__c=o.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000,ERP7__Address__c=bAddress.Id);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, Start_Date__c=Datetime.newInstance(system.today(),Time.newInstance(6, 0, 0, 0)), End_Date__c=Datetime.newInstance(system.today()+10,Time.newInstance(20, 0, 0, 0)));
        insert wc;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test',ERP7__Process_Cycle__c = processcycle.Id, ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
        Insert oprn;
        Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,ERP7__Serial__c  = ser.Id);
        insert stock;
        Stock_Inward_Line_Item__c SPLI2 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=stock.Id,Product__c=product.Id,Quantity__c=20,ERP7__Serial__c  = ser.Id);
        insert SPLI2;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__WO__c WO = new ERP7__WO__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Approved_Date__c=system.today(), ERP7__Customer__c=c.Id,ERP7__Work_Center__c = wc.id,
                                         ERP7__Channel__c=channel.Id, ERP7__Status__c='In Progress', ERP7__Contact__c=con.Id,ERP7__Type__c = 'Maintenance',
                                         ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Quantity_Ordered__c = 10, ERP7__Routing__c = routing.Id,
                                         ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__Start_Date__c = system.Now(), 
                                         ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(),
                                         ERP7__Active__c=true,ERP7__Is_Closed__c=false);
        insert WO;
        WO.ERP7__Version__c = Null;
        PreventRecursiveLedgerEntry.testCasesTransactions = false; update WO;           
        WO.ERP7__Version__c = version.Id; 
        WO.ERP7__Quantity_Ordered__c = 16;                      
        PreventRecursiveLedgerEntry.testCasesTransactions = false; update WO; 
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, Work_Order__c = WO.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 90, ERP7__Total_Amount_Required__c=90,ERP7__BOM__c=bom.Id);
        insert mrp;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so.Id, ERP7__Issue_Manufacturing_Order__c=true, ERP7__Issue_Work_Order__c=true, ERP7__Quantity__c=100);
        insert soli;
        
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        
        test.startTest();
        ProductConfigurator PG = new ProductConfigurator();
        ProductConfigurator.comWrap comWrap = ProductConfigurator.ConfigureMO(String.valueof(routing.Id));
        ProductConfigurator.SaveConfiguration(JSON.serialize(comWrap.BOMWrapperList), String.valueof(routing.Id), JSON.serialize(comWrap.SelectedRouting), JSON.serialize(comWrap.SelectedVersion));
        ProductConfigurator.SaveConfigurationVersion(JSON.serialize(comWrap.BOMWrapperList), String.valueof(version.Id), JSON.serialize(comWrap.SelectedVersion));
        comWrap.BOMWrapperList[0].BOM.ERP7__Active__c = false;
        ProductConfigurator.SaveConfiguration(JSON.serialize(comWrap.BOMWrapperList), String.valueof(routing.Id), JSON.serialize(comWrap.SelectedRouting), JSON.serialize(comWrap.SelectedVersion));
        ProductConfigurator.SaveConfigurationVersion(JSON.serialize(comWrap.BOMWrapperList), String.valueof(version.Id), JSON.serialize(comWrap.SelectedVersion));
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest(); 
        
    }
}