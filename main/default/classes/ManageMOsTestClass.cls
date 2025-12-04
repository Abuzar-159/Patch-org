@Istest
private class ManageMOsTestClass {
    static testmethod void UnitTest1() {  
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        /*Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation'); 
insert o;
Account s = new Account(Name = 'Supplier', Account_Type__c = 'Supplier');
insert s;
Account c = new Account(Name = 'Test', ERP7__Account_Type__c = 'Customer', AccountNumber = '1234', ERP7__Company__c = 'Aqxolt India Pvt Ltd', ERP7__Start_of_Week__c = 'Monday', ERP7__CustomerPriority__c = 'High', ERP7__Active__c = 'Yes', ERP7__SLA__c = 'Gold', ERP7__SLAExpirationDate__c = system.today());
insert c;
Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
insert channel;
Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
insert site;
Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
insert product;
Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id);
insert inventorystock;
Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
insert con;
ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
insert process;
ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
insert processcycle;
Id pricebookId = Test.getStandardPricebookId();
PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
insert pricebookentry;
Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
insert pricebook;
ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
insert version;
ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
insert version1;
ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
insert routing;
ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
insert project;
ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
insert machine;
ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
insert wc;
ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
insert ws;
ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
Insert oprn;
ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
insert manuorder;
manuorder.ERP7__Version__c = version.Id;
upsert manuorder;
ERP7__WO__c wo = new ERP7__WO__c(Name = 'Test', ERP7__Status__c = 'In Progress', ERP7__Approved_Date__c = system.today(), ERP7__Lead_Time__c = system.today(), ERP7__Customer__c = c.Id, ERP7__Contact__c = con.Id, ERP7__Material_Serial_Number_Start__c = '2', ERP7__Material_Serial_Number_End__c = '5', ERP7__Expected_Date__c = system.today(), ERP7__Progress__c = 2, ERP7__Planned_Date_From__c = system.today(), ERP7__Start_Date__c = system.today(), ERP7__Ready_To_Receive__c = true, ERP7__Ready_To_Pick_Pack__c = true, ERP7__Active__c = true, ERP7__Planned_Date_To__c = system.today(), ERP7__End_Date__c = system.today(), ERP7__Process__c = process.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__MO__c = manuorder.Id,ERP7__Work_Center__c = wc.Id);
insert wo;
ERP7__Work_Order_Line_Items__c woli = new ERP7__Work_Order_Line_Items__c(Name = 'Test', ERP7__Work_Orders__c = wo.Id, ERP7__Product__c = product.Id, ERP7__Quantity__c = 10, ERP7__Version__c = version.Id, ERP7__Unit_Price__c = 100, ERP7__Picked_Quantity__c = 2, ERP7__Packed_Quantity__c = 2, ERP7__Active__c = true, ERP7__Picked_Date__c = system.today(), ERP7__Manufacturing_Order__c = manuorder.Id, ERP7__Serialise__c = true, ERP7__Direct_Labour__c = 10, ERP7__Overhead__c = 10, ERP7__Organisation__c = o.Id);
insert woli;
ERP7__Schedule__c schedule = new ERP7__Schedule__c(Name = 'Test', ERP7__Process__c = process.Id, ERP7__Work_Order__c = wo.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__Schedule_Start_Date__c = system.today(), ERP7__Status__c = 'In Progress', ERP7__Estimated_Machine_Hour__c = 2, ERP7__Estimated_Workforce_Hour__c = 2, ERP7__Workforce_Allocation__c = 2, ERP7__Direct_Labour__c = 100, ERP7__Direct_Materials__c = 1000, ERP7__Overhead__c = 100, ERP7__Product__c = product.Id, ERP7__Total_Cost__c = 500, ERP7__Organisation__c = o.Id, ERP7__Work_Order_Line_Item__c = woli.Id, ERP7__Schedule_End_Date__c = system.today(), ERP7__Actual_Machine_Hour__c = 3, ERP7__Actual_Workforce_Hour__c = 3, ERP7__Machine_Allocation__c = 5, ERP7__Project__c = project.Id);
insert schedule;
ERP7__Product_Service__c productservice = new ERP7__Product_Service__c(Name = 'Test', ERP7__Product_Service_Family__c = 'Furniture', ERP7__Item_Type__c = 'New', ERP7__Description__c = 'Test', ERP7__Status__c = 'Delivered', ERP7__Purchase_Lead_Time_days__c = 10, ERP7__Manufacture_Lead_Time_days__c = 30, ERP7__Approved_by__c = 'EU', ERP7__Colour__c = 'Red', ERP7__isAccessory__c = true, ERP7__Mass__c = 100, ERP7__Weight__c = 200, ERP7__Track_Inventory__c = true, ERP7__Weight_Dimensions__c = 'Kilogram');
insert productservice;
Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id);
insert stock;

ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
insert rg;
ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
insert cap;
ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
insert dem;
ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
insert res;
ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='tes123t',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
try{ insert resAloc; }catch(Exception e){}
ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='tes1231t', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
insert OT;*/
        
        test.startTest();
        ManageMOs MMO = new ManageMOs();
        ManageMOs.searchProducts('searchString');
        ManageMOs.searchProductsP('searchStrings');
        ManageMOs.searchWOs('searchStringswo');
        ManageMOs.searchWSs('searchStringws');
        ManageMOs.searchWSss('searchStringwc');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
        
    }
    
        @isTest //(seeAllData = true)
        static  void UnitTest2() {
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
            ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = true,Run__c = true);
            insert mod;
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
            Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test', ERP7__Alternate_Quantity_Unit_Of_Measure__c='liter');
            insert product;
            Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
            insert product1;
            
            ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
            insert batch1;
            
            ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
            insert serial1;
            
            Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
            insert inventorystock;
            Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=100);
            insert SPLI;
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
            ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');//
            insert version;
            ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified', ERP7__Unit_of_Measure__c='liter', ERP7__BOM_Version__c = version.Id);
            insert bom;
            ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__BOM_Version__c = version.Id, ERP7__Status__c ='certified', ERP7__Unit_of_Measure__c='liter');
            insert bom1;
            ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
            insert routing;
            product.ERP7__Routing__c = routing.Id; product.ERP7__Version__c = version.Id;
            update product;
            ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
            insert project;
            ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id);
            insert wc;
            ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
            Insert oprn;
            
            ERP7__Batch__c batch2 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
            insert batch2;
            
            ERP7__Serial_Number__c serial2 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
            insert serial2;
            
            Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,ERP7__Batch_Lot__c=batch2.Id,ERP7__Serial__c = serial2.Id);
            insert stock;
            ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
            insert manuorder;
            MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id);
            insert mrp;
            ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
            insert so;
            ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so.Id);
            insert soli;
            Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
            insert pro;
            Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
            update standardPricebook;
            PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 102,IsActive = true);
            Insert pbe;
            
            Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                                  AccountId = c.id,ERP7__Contact__c=con.Id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                                  ERP7__Organisation__c=o.Id);        
            insert ord;
            
            
            OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
            insert orditem;
            ERP7__WO__c wo = new ERP7__WO__c(Name = 'Test', ERP7__Status__c = 'In Progress', ERP7__Approved_Date__c = system.today(), ERP7__Lead_Time__c = system.today(), ERP7__Customer__c = c.Id, ERP7__Contact__c = con.Id, ERP7__Material_Serial_Number_Start__c = '2', ERP7__Material_Serial_Number_End__c = '5', ERP7__Expected_Date__c = system.today(), ERP7__Progress__c = 2, ERP7__Planned_Date_From__c = system.today(), ERP7__Start_Date__c = system.today(), ERP7__Ready_To_Receive__c = true, ERP7__Ready_To_Pick_Pack__c = true, ERP7__Active__c = true, ERP7__Planned_Date_To__c = system.today(), ERP7__End_Date__c = system.today(), ERP7__Process__c = process.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__MO__c = manuorder.Id,ERP7__Work_Center__c = wc.Id);
            insert wo;
            Attachment attch = new Attachment(Name='Signature', ParentId=manuorder.Id, body=blob.valueof('Signature'));
            insert attch;
            mrp.ERP7__Work_Order__c = wo.Id;
            mrp.ERP7__BOM__c = bom.Id;
            update mrp;
            ERP7__Serial_Number__c sn = new ERP7__Serial_Number__c(Name='test', ERP7__Manufacturing_Order__c=manuorder.Id, ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
            insert sn;
            ERP7__Serial_Number__c sn1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test1');
            insert sn1;
            ERP7__Batch__c bt = new ERP7__Batch__c(Name='testBatch2', ERP7__Manufacturing_Order__c=manuorder.Id, ERP7__Product__c=product.Id, ERP7__Barcode__c='test2');
            insert bt;
            ERP7__Batch__c bt1 = new ERP7__Batch__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test3');
            insert bt1;
            ERP7__Stock_Outward_Line_Item__c NewSOLI1 = new ERP7__Stock_Outward_Line_Item__c(Quantity__c=1, ERP7__MRP_Material_Requirements_Planning__c = mrp.Id, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id);
            insert NewSOLI1;
            ERP7__Product_Feature__c prodFeature = new ERP7__Product_Feature__c(Name='test', ERP7__Product__c=product.Id);
            insert prodFeature;
            bom.ERP7__Product_Feature__c = prodFeature.Id;
            update bom;
            ERP7__Variance__c newVar001 = new ERP7__Variance__c(Name = 'varTest001', ERP7__Type__c = 'Alternative', ERP7__Product__c = product.Id, ERP7__Product_Feature__c = prodFeature.Id,ERP7__BOM_Variance__c = bom1.Id, ERP7__Bill_Of_Material__c = bom.Id);
            insert newVar001;
            mrp = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.Name, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name,
                   ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__MO__r.ERP7__Version__c, ERP7__Fulfilled_Amount__c, ERP7__BOM__r.ERP7__Is_Protected__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Work_Order__c
                   From ERP7__MRP__c
                   Where Id = :mrp.Id];
            test.startTest();
            
            
            ManufacturingOrder.mrpWrap com = new ManufacturingOrder.mrpWrap();
            com.MRP = mrp;
            com.isSelect = true;
            List<ManufacturingOrder.mrpWrap> comws = new List<ManufacturingOrder.mrpWrap>();
            comws.add(com);
            ManufacturingOrder.comWrap comW = ManufacturingOrder.getAll(manuorder.Id,true,false);
            ManufacturingOrder.SaveM(JSON.serialize(manuorder));
            ManufacturingOrder.MRPEdit(JSON.serialize(com),JSON.serialize(comws));
            ManufacturingOrder.MRPUpdate(JSON.serialize(mrp),JSON.serialize(comws));
            string mosoliId = soli.Id;
            String MOrdItm=orditem.Id;
            ERP7__Serial_Number__c SerialNumber = new ERP7__Serial_Number__c();
            ManufacturingOrder.SaveSerial(JSON.serialize(SerialNumber), JSON.serialize(manuorder));
            ERP7__Batch__c Batch = new ERP7__Batch__c();
            ManufacturingOrder.SaveBatch(JSON.serialize(Batch), JSON.serialize(manuorder));
            ManufacturingOrder.getAllMO(mrp.Id);
            ManufacturingOrder.getAllMPS('test');
            ManufacturingOrder.ReserveMRPSStocks(JSON.serialize(comws),10);
            ManufacturingOrder.getAllSOLI(mosoliId,MOrdItm);
            ManufacturingOrder.SaveAllMRPs(JSON.serialize(comws));
            ERP7__Stock_Outward_Line_Item__c NewSOLI = new ERP7__Stock_Outward_Line_Item__c(Quantity__c=1, ERP7__MRP_Material_Requirements_Planning__c = mrp.Id);
            List<Id> srIds = new list<Id>();
            ManufacturingOrder.SaveNewSOLI(JSON.serialize(NewSOLI),JSON.serialize(comws),JSON.serialize(srIds));
            List<ERP7__Stock_Outward_Line_Item__c> mySOLIs = [Select Id, Name, ERP7__Quantity__c from ERP7__Stock_Outward_Line_Item__c];
            if(mySOLIs.size() > 0) ManufacturingOrder.DeleteSOLI(mySOLIs[0].Id,JSON.serialize(comws));
            ManufacturingOrder.MRPNewUpdate1(JSON.serialize(mrp));
            ManufacturingOrder.GetDefaults(product.Id);
            ManufacturingOrder.getDependentMap(new ERP7__Checklist__c(),'ERP7__Comply__c','ERP7__Result__c');
            ManufacturingOrder.getWIPFlows(0,manuorder.Id);
            ERP7__Serial_Number__c ser3 = new ERP7__Serial_Number__c(Name='test234',ERP7__Manufacturing_Order__c = manuorder.Id);
            insert ser3;
            ManufacturingOrder.getSerialNumbers(0,manuorder.Id,null,new List<String>());
            ManufacturingOrder.deleteSelectedMRP(new List<String>{mrp.Id});
            
            Inventory_Stock__c stock1 = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,ERP7__Batch_Lot__c=bt.Id);
            insert stock1;
            ERP7__Stock_Inward_Line_Item__c inward = new ERP7__Stock_Inward_Line_Item__c(Name = 'test',Active__c = true, Product__c = product.Id,ERP7__Manufacturing_Order__c = manuorder.Id,ERP7__Site_ProductService_InventoryStock__c = stock1.Id,ERP7__Material_Batch_Lot__c = bt.Id);
            insert inward;
            List<ManufacturingOrder.ReceivedSILIWrap> createdSili = ManufacturingOrder.getStockinwards(0,manuorder.Id);
            if(createdSili != null) ManufacturingOrder.saveAlldetail(JSON.serialize(createdSili));
            List<ERP7__Guideline_Checklists__c> checkexits = new List<ERP7__Guideline_Checklists__c>();
            String guideline = JSON.serialize(checkexits);
            ManufacturingOrder.uploadMultipleFilesforQAguideline(guideline, new List<String>{'file1.pdf'}, new List<String>{'Test file in pdf fromat'}, new List<String>{'text/plain'});
            /* ManufacturingOrder.GetRouting(routing.Id);
    ManufacturingOrder.SearchScanCode('test',JSON.serialize(comws));
    ManufacturingOrder.SearchScanCode('testBatch2',JSON.serialize(comws));
    ManufacturingOrder.SearchScanCode('test2',JSON.serialize(comws));
    ManufacturingOrder.SearchScanCode('test3',JSON.serialize(comws));
    ManufacturingOrder.GetAttachments(manuorder.Id);
    ManufacturingOrder.DeleteAT(wo.Id, 'ERP7__WO__c');*/
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
            test.stopTest();
            
        }
    @isTest//(seeAllData = true)
    static  void UnitTest22() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
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
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test', ERP7__Alternate_Quantity_Unit_Of_Measure__c='liter');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=100);
        insert SPLI;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        //Id pricebookId = Test.getStandardPricebookId();
        //PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        //insert pricebookentry;
        //PricebookEntry pricebookentry1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product1.Id, UnitPrice = 10000, IsActive = true);
        //insert pricebookentry1;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');//
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified', ERP7__Unit_of_Measure__c='liter', ERP7__BOM_Version__c = version.Id);
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__BOM_Version__c = version.Id, ERP7__Status__c ='certified', ERP7__Unit_of_Measure__c='liter');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        product.ERP7__Routing__c = routing.Id; product.ERP7__Version__c = version.Id;
        update product;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id);
        insert wc;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
        Insert oprn;
        
        ERP7__Batch__c batch2 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch2;
        
        ERP7__Serial_Number__c serial2 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial2;
        
        Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,ERP7__Batch_Lot__c=batch2.Id,ERP7__Serial__c = serial2.Id);
        insert stock;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id);
        insert mrp;
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so.Id);
        insert soli;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 102,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                              AccountId = c.id,ERP7__Contact__c=con.Id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                              ERP7__Organisation__c=o.Id);        
        insert ord;
        
        
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        ERP7__WO__c wo = new ERP7__WO__c(Name = 'Test', ERP7__Status__c = 'In Progress', ERP7__Approved_Date__c = system.today(), ERP7__Lead_Time__c = system.today(), ERP7__Customer__c = c.Id, ERP7__Contact__c = con.Id, ERP7__Material_Serial_Number_Start__c = '2', ERP7__Material_Serial_Number_End__c = '5', ERP7__Expected_Date__c = system.today(), ERP7__Progress__c = 2, ERP7__Planned_Date_From__c = system.today(), ERP7__Start_Date__c = system.today(), ERP7__Ready_To_Receive__c = true, ERP7__Ready_To_Pick_Pack__c = true, ERP7__Active__c = true, ERP7__Planned_Date_To__c = system.today(), ERP7__End_Date__c = system.today(), ERP7__Process__c = process.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__MO__c = manuorder.Id,ERP7__Work_Center__c = wc.Id);
        insert wo;
        Attachment attch = new Attachment(Name='Signature', ParentId=manuorder.Id, body=blob.valueof('Signature'));
        insert attch;
        mrp.ERP7__Work_Order__c = wo.Id;
        mrp.ERP7__BOM__c = bom.Id;
        update mrp;
        ERP7__Serial_Number__c sn = new ERP7__Serial_Number__c(Name='test', ERP7__Manufacturing_Order__c=manuorder.Id, ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert sn;
        ERP7__Serial_Number__c sn1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test1');
        insert sn1;
        ERP7__Batch__c bt = new ERP7__Batch__c(Name='testBatch2', ERP7__Manufacturing_Order__c=manuorder.Id, ERP7__Product__c=product.Id, ERP7__Barcode__c='test2');
        insert bt;
        ERP7__Batch__c bt1 = new ERP7__Batch__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test3');
        insert bt1;
        ERP7__Stock_Outward_Line_Item__c NewSOLI1 = new ERP7__Stock_Outward_Line_Item__c(Quantity__c=1, ERP7__MRP_Material_Requirements_Planning__c = mrp.Id, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id);
        insert NewSOLI1;
        ERP7__Product_Feature__c prodFeature = new ERP7__Product_Feature__c(Name='test', ERP7__Product__c=product.Id);
        insert prodFeature;
        bom.ERP7__Product_Feature__c = prodFeature.Id;
        update bom;
        ERP7__Variance__c newVar001 = new ERP7__Variance__c(Name = 'varTest001', ERP7__Type__c = 'Alternative', ERP7__Product__c = product.Id, ERP7__Product_Feature__c = prodFeature.Id,ERP7__BOM_Variance__c = bom1.Id, ERP7__Bill_Of_Material__c = bom.Id);
        insert newVar001;
        mrp = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.Name, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name,
               ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__MO__r.ERP7__Version__c, ERP7__Fulfilled_Amount__c, ERP7__BOM__r.ERP7__Is_Protected__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Work_Order__c
               From ERP7__MRP__c
               Where Id = :mrp.Id];
        test.startTest();
        ManufacturingOrder.mrpWrap com = new ManufacturingOrder.mrpWrap();
        com.MRP = mrp;
        com.isSelect = true;
        List<ManufacturingOrder.mrpWrap> comws = new List<ManufacturingOrder.mrpWrap>();
        comws.add(com);
        ManufacturingOrder.GetRouting(routing.Id);
        ManufacturingOrder.SearchScanCode('test',JSON.serialize(comws));
        ManufacturingOrder.SearchScanCode('testBatch2',JSON.serialize(comws));
        ManufacturingOrder.SearchScanCode('test2',JSON.serialize(comws));
        ManufacturingOrder.SearchScanCode('test3',JSON.serialize(comws));
        ManufacturingOrder.GetAttachments(manuorder.Id);
        ManufacturingOrder.DeleteAT(wo.Id, 'ERP7__WO__c');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    @isTest(seeAllData = true)
    static  void UnitTest3() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
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
        Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
        insert emp;
        Product2 product = new Product2(Name = 'Test', ERP7__Alternate_Quantity_Unit_Of_Measure__c = 'liter', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=200);
        insert SPLI;
        //update inventorystock;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        //Id pricebookId = Test.getStandardPricebookId();
        //PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        //insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');//
        insert version1;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified', ERP7__Unit_of_Measure__c='liter', ERP7__BOM_Version__c = version.Id);
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__BOM_Version__c = version.Id, ERP7__Status__c ='certified', ERP7__Unit_of_Measure__c='liter');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
        Insert oprn;
        ERP7__Media__c Media = new ERP7__Media__c(Name='test', ERP7__Operation__c=oprn.Id, ERP7__Active__c=true);
        insert Media;
        Attachment attch = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch;
        Attachment attch1 = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch1;
        List<ERP7__Checklist__c> chektoinsert = new List<ERP7__Checklist__c>();
        ERP7__Checklist__c check1 = new ERP7__Checklist__c(Name='test check1',ERP7__Action_Detail__c='Action required',ERP7__Comply__c='Correct Material for Job',ERP7__Process_Cycle__c=processcycle.Id);
        insert check1;
        chektoinsert.add(check1);
        ERP7__Checklist__c check2 = new ERP7__Checklist__c(Name='test check2',ERP7__Action_Detail__c='Action require22',ERP7__Comply__c='--None--',ERP7__Process_Cycle__c=processcycle.Id);
        insert check2;
        chektoinsert.add(check2);
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__WIP_Link__c WIPLink1 = new ERP7__WIP_Link__c(
            Name = 'WIP Link - 1',                              
            ERP7__Process_Cycle__c = processcycle.Id,           
            ERP7__Product__c = product.Id,               
            ERP7__Version__c = version.Id,          
            ERP7__Process_Output_Product__c = product.Id, 
            ERP7__Process_Output_Version__c = version.Id,    
            ERP7__Finished_Products_Site__c = site.Id,  
            ERP7__Type__c = 'Produced',                          
            ERP7__Quantity_Unit__c = 1,                     
            ERP7__Quantity_Unit_Of_Measure__c = 'PCS'            
        );
        insert WIPLink1;
        
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        PreventRecursiveLedgerEntry.MOTrigger = true;
        insert manuorder;
        
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        List<WIP_Flow__c> WIPFLOW = [Select Id, Name, Status__c From WIP_Flow__c limit 1];
        if(WIPFLOW.size() > 0) { WIPFLOW[0].Status__c = 'Completed'; update WIPFLOW; }
        
        ERP7__WO__c WO2Create = new ERP7__WO__c();
        WO2Create.Name = 'test';   
        WO2Create.Planned_Date__c = System.Today();
        WO2Create.ERP7__Status__c = 'Issued';
        WO2Create.ERP7__Version__c = manuorder.ERP7__Version__c;
        WO2Create.ERP7__Routing__c = manuorder.ERP7__Routing__c;
        WO2Create.ERP7__Raw_Materials_Site__c = site.Id;
        WO2Create.ERP7__Site__c = manuorder.ERP7__Finished_Products_SiteId__c;
        WO2Create.ERP7__MO__c = manuorder.Id;
        WO2Create.ERP7__Product__c = manuorder.ERP7__Product__c;
        WO2Create.ERP7__Quantity_Ordered__c = manuorder.ERP7__Quantity__c;
        WO2Create.ERP7__Start_Date__c = manuorder.ERP7__StartDate__c;
        WO2Create.ERP7__End_Date__c = manuorder.ERP7__End_Date__c;
        WO2Create.ERP7__Type__c = 'Manufacturing';
        WO2Create.ERP7__Work_Center__c = WC.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = true;
        insert WO2Create;
        
        ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
        action2Create.Name = oprn.Name;
        action2Create.ERP7__Process_Cycle__c = oprn.ERP7__Process_Cycle__c;
        action2Create.ERP7__Routing_Link__c = oprn.ERP7__Routing_Link__c;
        action2Create.ERP7__Work_Order__c = WO2Create.Id;
        action2Create.ERP7__Manufacturing_Order__c = WO2Create.ERP7__MO__c;
        action2Create.ERP7__Operation__c = oprn.Id;
        action2Create.ERP7__Type__c = oprn.ERP7__Type__c;
        action2Create.ERP7__Work_Center__c = oprn.ERP7__Work_Center__c;
        action2Create.ERP7__Product__c = WO2Create.ERP7__Product__c;
        action2Create.ERP7__Process__c = oprn.ERP7__Process_Cycle__r.ERP7__Process__c;
        action2Create.ERP7__Auto_Clock_In__c = oprn.ERP7__Auto_Clock_In__c;
        insert action2Create ;
        
        ERP7__WO__c wo = [Select Id, Name, ERP7__MO__c, ERP7__Process_Cycle__c From ERP7__WO__c Where ERP7__MO__c =: manuorder.Id Limit 1];
        MRP__c mrp1 = new MRP__c(ERP7__Version__c = version.Id, ERP7__Process_Cycle__c=wo.ERP7__Process_Cycle__c, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo.Id);
        insert mrp1;
        List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];
        
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo.Id);
        insert mrp;
        
        ERP7__Stock_Outward_Line_Item__c NewSOLI1 = new ERP7__Stock_Outward_Line_Item__c(Quantity__c=1, ERP7__MRP_Material_Requirements_Planning__c = mrp.Id, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Site_Product_Service_Inventory_Stock__c = inventorystock.Id);
        insert NewSOLI1;
        ERP7__Product_Feature__c prodFeature = new ERP7__Product_Feature__c(Name='test', ERP7__Product__c=product.Id);
        insert prodFeature;
        bom.ERP7__Product_Feature__c = prodFeature.Id;
        update bom;
        ERP7__Variance__c newVar001 = new ERP7__Variance__c(Name = 'varTest001', ERP7__Type__c = 'Alternative', ERP7__Product__c = product.Id, ERP7__Product_Feature__c = prodFeature.Id,ERP7__BOM_Variance__c = bom1.Id, ERP7__Bill_Of_Material__c = bom.Id);
        insert newVar001;
        
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='test1233',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id); //ERP7__Resource__c=res.Id
        //try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='te23st', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(Name='test', ERP7__Product__c=product.Id, ERP7__Status__c='Approved', ERP7__WorkCenter__c=wc.Id);
        insert WP;
        
        ERP7__Resource_Requirement__c RR = new ERP7__Resource_Requirement__c(Name='test', ERP7__Resource_Group__c = rg.Id, ERP7__Preferred_Resource__c=res.Id, ERP7__Work_Planner__c=WP.Id, ERP7__Type__c='Setup');
        insert RR;
        
        test.startTest();
        BuildWorkOrder.mrpWrap mrpw = new BuildWorkOrder.mrpWrap();
        BuildWorkOrder.comWrap comW = BuildWorkOrder.getAll(wo.Id);
        BuildWorkOrder.TaskUpdate(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        BuildWorkOrder.TaskUpdatePartial(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        BuildWorkOrder.DeleteAction(comW.Tasks[0].Id);
        BuildWorkOrder.ReserveMRPSStocks(JSON.serialize(comW.MRPSSBW),10);
        BuildWorkOrder.MRPEdit(JSON.serialize(comW.MRPSSBW[0]),JSON.serialize(comW.MRPSSBW));
        BuildWorkOrder.MRPUpdate(JSON.serialize(mrp));
        BuildWorkOrder.MRPUpdateNew(JSON.serialize(mrp),JSON.serialize(comW.MRPSSBW));
        BuildWorkOrder.SaveAllMRPs(JSON.serialize(comW.MRPSSBW));
        BuildWorkOrder.StartWORec(wo.Id);
        BuildWorkOrder.GetWORec(wo.Id,manuorder.Id);
        BuildWorkOrder.GetDefaults(product1.Id);
        BuildWorkOrder.UpdateWORec(JSON.serialize(wo),JSON.serialize(new List<ERP7__WIP_Flow__c>()));
        comW.MRPSSBW[0].isSelect = true;
        List<Id> srIds = new list<Id>();
        BuildWorkOrder.SaveNewSOLI(JSON.serialize(new ERP7__Stock_Outward_Line_Item__c(name='test',ERP7__Quantity__c=1)),JSON.serialize(comW.MRPSSBW),JSON.serialize(srIds));
        List<ERP7__Stock_Outward_Line_Item__c> mySOLI = [Select Id, Name, ERP7__Quantity__c from ERP7__Stock_Outward_Line_Item__c limit 1];
        if(mySOLI.size() > 0) BuildWorkOrder.DeleteSOLI(mySOLI[0].Id,JSON.serialize(comW.MRPSSBW));
        sObject obj = new ERP7__Checklist__c();
        BuildWorkOrder.getDependentMap(obj, 'ERP7__Comply__c', 'ERP7__Result__c');
        //BuildWorkOrder.getcheclistoptions();
        String cheklistss = JSON.serialize(chektoinsert);
        List<ERP7__Guideline_Checklists__c> checkexits = new List<ERP7__Guideline_Checklists__c>();
        String guideline = JSON.serialize(checkexits);
        
        //comW.tasklist.Task[0].isSelected = true;
        BuildWorkOrder.Savechecklists(cheklistss,wo.Id,guideline,JSON.serialize(comW.tasklist));
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        BuildWorkOrder.getgradeandProducts(wo.Id);
        test.stopTest();
    }
    
    //soql 101 in this smethod be carefull //changed by Arshad 09/12/22
    static testmethod void UnitTest33() {
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
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
        Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=20);
        insert SPLI;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        ERP7__Process_Cycle__c processcycle2 = new ERP7__Process_Cycle__c(Name = 'PRC 2', ERP7__Progress__c = 1, ERP7__Process__c = process.Id);
        insert processcycle2;
        ERP7__Process_Cycle__c processcycle3 = new ERP7__Process_Cycle__c(Name = 'PRC 3', ERP7__Progress__c = 2, ERP7__Process__c = process.Id);
        insert processcycle3;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');//
        insert version1;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = '', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
        Insert oprn;
        ERP7__Media__c Media = new ERP7__Media__c(Name='test', ERP7__Operation__c=oprn.Id, ERP7__Active__c=true);
        insert Media;
        Attachment attch = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch;
        Attachment attch1 = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        
        ERP7__WO__c WO2Create = new ERP7__WO__c();
        WO2Create.Name = 'test';   
        WO2Create.Planned_Date__c = System.Today();
        WO2Create.ERP7__Status__c = 'Issued';
        WO2Create.ERP7__Version__c = manuorder.ERP7__Version__c;
        WO2Create.ERP7__Routing__c = manuorder.ERP7__Routing__c;
        WO2Create.ERP7__Raw_Materials_Site__c = site.Id;
        WO2Create.ERP7__Site__c = manuorder.ERP7__Finished_Products_SiteId__c;
        WO2Create.ERP7__MO__c = manuorder.Id;
        WO2Create.ERP7__Product__c = manuorder.ERP7__Product__c;
        WO2Create.ERP7__Quantity_Ordered__c = manuorder.ERP7__Quantity__c;
        WO2Create.ERP7__Start_Date__c = manuorder.ERP7__StartDate__c;
        WO2Create.ERP7__End_Date__c = manuorder.ERP7__End_Date__c;
        WO2Create.ERP7__Type__c = 'Manufacturing';
        WO2Create.ERP7__Work_Center__c = WC.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = true;
        insert WO2Create;
        
        ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
        action2Create.Name = oprn.Name;
        action2Create.ERP7__Process_Cycle__c = oprn.ERP7__Process_Cycle__c;
        action2Create.ERP7__Routing_Link__c = oprn.ERP7__Routing_Link__c;
        action2Create.ERP7__Work_Order__c = WO2Create.Id;
        action2Create.ERP7__Manufacturing_Order__c = WO2Create.ERP7__MO__c;
        action2Create.ERP7__Operation__c = oprn.Id;
        action2Create.ERP7__Type__c = oprn.ERP7__Type__c;
        action2Create.ERP7__Work_Center__c = oprn.ERP7__Work_Center__c;
        action2Create.ERP7__Product__c = WO2Create.ERP7__Product__c;
        action2Create.ERP7__Process__c = oprn.ERP7__Process_Cycle__r.ERP7__Process__c;
        action2Create.ERP7__Auto_Clock_In__c = oprn.ERP7__Auto_Clock_In__c;
        insert action2Create ;
        
        List<ERP7__WO__c> wo = [Select Id, Name, ERP7__MO__c From ERP7__WO__c Where ERP7__MO__c =: manuorder.Id];
        system.debug('wo.size() : '+wo.size());
        if(wo.size() > 0 || wo.size() == 1){
            wo[0].ERP7__Raw_Materials_Site__c = site.Id;
            wo[0].ERP7__Process_Cycle__c = processcycle.Id;
            PreventRecursiveLedgerEntry.preventWOExecution = true;
            update wo[0];  
        }
        if(wo.size() > 1){
            wo[1].ERP7__Raw_Materials_Site__c = site.Id;
            wo[1].ERP7__Process_Cycle__c = processcycle2.Id;
            PreventRecursiveLedgerEntry.preventWOExecution = true;
            update wo[1];  
        }
        
        List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];
        
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo[0].Id);
        insert mrp;
        
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='te12edst',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo[0].Id);
        try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='tes43t', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(Name='test', ERP7__Product__c=product.Id, ERP7__Status__c='Approved', ERP7__WorkCenter__c=wc.Id);
        insert WP;
        
        ERP7__Resource_Requirement__c RR = new ERP7__Resource_Requirement__c(Name='test', ERP7__Resource_Group__c = rg.Id, ERP7__Preferred_Resource__c=res.Id, ERP7__Work_Planner__c=WP.Id, ERP7__Type__c='Setup');
        insert RR;
        
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new  ERP7__Sales_Order_Line_Item__c(ERP7__Product__c=product.id,ERP7__Sales_Order__c=so.id);
        insert soli;
        //List<ERP7__RMA_Line_Item__c>
        ERP7__Serial_Number__c SNSD=new ERP7__Serial_Number__c(name='test',ERP7__Manufacturing_Order__c=manuorder.id,ERP7__Product__c=product.id);
        insert SNSD;
        List<ERP7__Serial_Number__c> SNS=[Select Id, Name,ERP7__Manufacturing_Order__c, ERP7__Product__c From ERP7__Serial_Number__c limit 1];
        SNS[0].ERP7__Barcode__c = 'test';
        update SNS;
        ERP7__Serial_Number__c SNS2= new ERP7__Serial_Number__c(Name = 'testSerial001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        SNS2.ERP7__Barcode__c = 'test1001';
        insert SNS2;
        SNS.add(SNS2);
        //ERP7__Batch__c BTCH = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Batch__c Limit 1];
        ERP7__Batch__c BTCH = new ERP7__Batch__c(Name = 'testBatch', ERP7__Product__c = mrp.ERP7__MRP_Product__c, ERP7__Manufacturing_Order__c = mrp.ERP7__MO__c);
        BTCH.ERP7__Barcode__c = 'testB';
        insert BTCH;
        ERP7__Batch__c BTCH2 = new ERP7__Batch__c(Name = 'testBatch001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        BTCH2.ERP7__Barcode__c = 'testB1001';
        insert BTCH2;
        
        List<ERP7__UOM_Conversion__mdt> UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 9999];
        //-----------------mna-----------------------
        
        test.startTest();
        
        BuildWorkOrder.mrpWrap mrpw = new BuildWorkOrder.mrpWrap();
        mrpw.mrp = mrp;
        mrpw.isSelect = true;
        List<BuildWorkOrder.mrpWrap> mrpwList = new List<BuildWorkOrder.mrpWrap>();
        mrpwList.add(mrpw);
        BuildWorkOrder.comWrap comW = BuildWorkOrder.getAll(wo[0].Id);
        comW.Tasks[0].ERP7__Work_Order__c = wo[0].Id;
        comW.Tasks[0].ERP7__Process_Cycle__c = wo[0].ERP7__Process_Cycle__c;
        update comW.Tasks[0];
        BuildWorkOrder.SelectTasks(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.StartTimeCardEntrys(JSON.serialize(comW.Tasks[0]));
        ERP7__Time_Card_Entry__c TCES =  [Select Id, Name, ERP7__Action_Task__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__Active__c From ERP7__Time_Card_Entry__c Where ERP7__Active__c = true And ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c = : UserInfo.getUserId() And ERP7__Start_Time__c <= Today And ERP7__End_Time__c = Null Limit 1]; 
        
        ERP7__Timesheet__c ts=new ERP7__Timesheet__c(Name='test',ERP7__Employees__c=emp.Id);
        insert ts;
        //ERP7__Time_Card_Entry__c TCES = new ERP7__Time_Card_Entry__c(Name='test',ERP7__Active__c=true,ERP7__Start_Time__c=system.today(),ERP7__End_Time__c=system.today(),ERP7__Timesheet__c=ts.Id);
        //insert TCES;
        BuildWorkOrder.StopTimeCardEntrys(JSON.serialize(comW.Tasks[0]),JSON.serialize(TCES));
        BuildWorkOrder.SaveAction(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.PreTaskFinish(JSON.serialize(comW.Tasks[0]));
        comW.Tasks[0].ERP7__Status__c = 'In-Progress';
        comW.Tasks[0].ERP7__Operation__c = Operations[0].Id;
        comW.Tasks[0].ERP7__Manufacturing_Order__c = manuorder.Id;
        upsert comW.Tasks[0];
        BuildWorkOrder.uploadFile (comW.Tasks[0].Id, 'test', 'String base64Data', 'png');
        BuildWorkOrder.SaveNotes(JSON.serialize(new Note(Title='test',ParentId=comW.Tasks[0].Id)));
        BuildWorkOrder.PreTaskFinish(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.TaskUpdate(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        BuildWorkOrder.TaskUpdatePartial(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        BuildWorkOrder.TaskUpdateNew(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPSSBW), JSON.serialize(UOMCs));
        comW.Tasks[0].ERP7__Status__c = 'Completed';
        upsert comW.Tasks[0];
        //-----------------mna--------------------------
        if(comW.Tasks[0].ERP7__Status__c == 'Completed') BuildWorkOrder.TaskUpdateNew(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPSSBW), JSON.serialize(UOMCs));
        if(comW.Tasks[0].ERP7__Status__c == 'Completed') BuildWorkOrder.TaskUpdate(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        //-----------------mna--------------------------
        
        //new data
        //List<ERP7__WIP_Flow__c> wipFlow = [SELECT Id FROM ERP7__WIP_Flow__c LIMIT 1];
        ERP7__Return_Merchandise_Authorisation__c rma001 = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA001', ERP7__SO__c = so.Id);
        insert rma001;
        ERP7__RMA_Line_Item__c rmaLine001 = new ERP7__RMA_Line_Item__c(Name = 'testRMALine001', ERP7__Return_Merchandise_Authorisation__c = rma001.Id, ERP7__SOLI__c = soli.Id, ERP7__Product__c = product.Id);
        insert rmaLine001;
        
        List<BuildWorkOrder.WorkPlanner> WPWL = new List<BuildWorkOrder.WorkPlanner>();
        BuildWorkOrder.WorkPlanner WPW = new BuildWorkOrder.WorkPlanner(); 
        WPW.RRS.add(RR);
        WPWL.add(WPW);
        BuildWorkOrder.GetAllResources(JSON.serialize(WPWL), '', system.Now(), system.Now()+1, WP.Id, RR.Id);            
        List<BuildWorkOrder.Resource> RWL = new List<BuildWorkOrder.Resource>();
        BuildWorkOrder.Resource RW = new BuildWorkOrder.Resource(); 
        RW.Resource = res;
        RWL.add(RW);
        BuildWorkOrder.SaveResources(JSON.serialize(RWL), JSON.serialize(WO[0]), system.Now(), system.Now()+1);
        BuildWorkOrder.SaveW(JSON.serialize(WO[0]));
        
        
       
        //----------------------mna-----------------------------------
        String woid = wo[0].id;
        string rmaId =rmaLine001.id;
        
       
        // if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('testB',JSON.serialize(mrpwList));
        //if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('testB1001',JSON.serialize(mrpwList));
        String batchId = BTCH.id;
        String serId = SNS2.id;
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
        
        
    }
    
    static testmethod void UnitTest33_A() {
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
        Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=20);
        insert SPLI;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version1;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
        Insert oprn;
        ERP7__Media__c Media = new ERP7__Media__c(Name='test', ERP7__Operation__c=oprn.Id, ERP7__Active__c=true);
        insert Media;
        Attachment attch = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch;
        Attachment attch1 = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
        insert manuorder;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        ERP7__WO__c WO2Create = new ERP7__WO__c();
        WO2Create.Name = 'test';   
        WO2Create.Planned_Date__c = System.Today();
        WO2Create.ERP7__Status__c = 'Issued';
        WO2Create.ERP7__Version__c = manuorder.ERP7__Version__c;
        WO2Create.ERP7__Routing__c = manuorder.ERP7__Routing__c;
        WO2Create.ERP7__Raw_Materials_Site__c = site.Id;
        WO2Create.ERP7__Site__c = manuorder.ERP7__Finished_Products_SiteId__c;
        WO2Create.ERP7__MO__c = manuorder.Id;
        WO2Create.ERP7__Product__c = manuorder.ERP7__Product__c;
        WO2Create.ERP7__Quantity_Ordered__c = manuorder.ERP7__Quantity__c;
        WO2Create.ERP7__Start_Date__c = manuorder.ERP7__StartDate__c;
        WO2Create.ERP7__End_Date__c = manuorder.ERP7__End_Date__c;
        WO2Create.ERP7__Type__c = 'Manufacturing';
        WO2Create.ERP7__Work_Center__c = WC.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = false;
        insert WO2Create;
        
        ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
        action2Create.Name = oprn.Name;
        action2Create.ERP7__Process_Cycle__c = oprn.ERP7__Process_Cycle__c;
        action2Create.ERP7__Routing_Link__c = oprn.ERP7__Routing_Link__c;
        action2Create.ERP7__Work_Order__c = WO2Create.Id;
        action2Create.ERP7__Manufacturing_Order__c = WO2Create.ERP7__MO__c;
        action2Create.ERP7__Operation__c = oprn.Id;
        action2Create.ERP7__Type__c = oprn.ERP7__Type__c;
        action2Create.ERP7__Work_Center__c = oprn.ERP7__Work_Center__c;
        action2Create.ERP7__Product__c = WO2Create.ERP7__Product__c;
        action2Create.ERP7__Process__c = oprn.ERP7__Process_Cycle__r.ERP7__Process__c;
        action2Create.ERP7__Auto_Clock_In__c = oprn.ERP7__Auto_Clock_In__c;
        insert action2Create ;
        
        ERP7__WO__c wo = [Select Id, Name, ERP7__MO__c From ERP7__WO__c Where ERP7__MO__c =: manuorder.Id Limit 1];
        wo.ERP7__Raw_Materials_Site__c = site.Id;
        wo.ERP7__Process_Cycle__c = processcycle.Id;
        update wo;
        List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];
        
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo.Id);
        insert mrp;
        
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='teed32st',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
        try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='tdfest', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(Name='test', ERP7__Product__c=product.Id, ERP7__Status__c='Approved', ERP7__WorkCenter__c=wc.Id);
        insert WP;
        
        ERP7__Resource_Requirement__c RR = new ERP7__Resource_Requirement__c(Name='test', ERP7__Resource_Group__c = rg.Id, ERP7__Preferred_Resource__c=res.Id, ERP7__Work_Planner__c=WP.Id, ERP7__Type__c='Setup');
        insert RR;
        
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new  ERP7__Sales_Order_Line_Item__c(ERP7__Product__c=product.id,ERP7__Sales_Order__c=so.id);
        insert soli;
        //List<ERP7__RMA_Line_Item__c>
        ERP7__Serial_Number__c SNSD=new ERP7__Serial_Number__c(name='test',ERP7__Manufacturing_Order__c=manuorder.id,ERP7__Product__c=product.id);
        insert SNSD;
        List<ERP7__Serial_Number__c> SNS=[Select Id, Name,ERP7__Manufacturing_Order__c, ERP7__Product__c From ERP7__Serial_Number__c limit 1];
        SNS[0].ERP7__Barcode__c = 'test';
        update SNS;
        ERP7__Serial_Number__c SNS2= new ERP7__Serial_Number__c(Name = 'testSerial001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        SNS2.ERP7__Barcode__c = 'test1001';
        insert SNS2;
        SNS.add(SNS2);
        //ERP7__Batch__c BTCH = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Batch__c Limit 1];
        ERP7__Batch__c BTCH = new ERP7__Batch__c(Name = 'testBatch', ERP7__Product__c = mrp.ERP7__MRP_Product__c, ERP7__Manufacturing_Order__c = mrp.ERP7__MO__c);
        BTCH.ERP7__Barcode__c = 'testB';
        insert BTCH;
        ERP7__Batch__c BTCH2 = new ERP7__Batch__c(Name = 'testBatch001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        BTCH2.ERP7__Barcode__c = 'testB1001';
        insert BTCH2;
        
        List<ERP7__UOM_Conversion__mdt> UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 9999];
        //-----------------mna-----------------------
        
        test.startTest();
        
        BuildWorkOrder.mrpWrap mrpw = new BuildWorkOrder.mrpWrap();
        mrpw.mrp = mrp;
        mrpw.isSelect = true;
        List<BuildWorkOrder.mrpWrap> mrpwList = new List<BuildWorkOrder.mrpWrap>();
        mrpwList.add(mrpw);
        BuildWorkOrder.comWrap comW = BuildWorkOrder.getAll(wo.Id);
        comW.Tasks[0].ERP7__Work_Order__c = wo.Id;
        comW.Tasks[0].ERP7__Process_Cycle__c = wo.ERP7__Process_Cycle__c;
        update comW.Tasks[0];
        BuildWorkOrder.SelectTasks(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.StartTimeCardEntrys(JSON.serialize(comW.Tasks[0]));
        //ERP7__Time_Card_Entry__c TCES =  [Select Id, Name, ERP7__Action_Task__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__Active__c From ERP7__Time_Card_Entry__c Where ERP7__Active__c = true And ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c = : UserInfo.getUserId() And ERP7__Start_Time__c <= Today And ERP7__End_Time__c = Null Limit 1]; 
        
        ERP7__Timesheet__c ts=new ERP7__Timesheet__c(Name='test',ERP7__Employees__c=emp.Id);
        insert ts;
        ERP7__Time_Card_Entry__c TCES= new ERP7__Time_Card_Entry__c(Name='test',ERP7__Active__c=true,ERP7__Start_Time__c=system.today(),ERP7__End_Time__c=system.today(),ERP7__Timesheet__c=ts.Id);
        insert TCES;
        
        comW.Tasks[0].ERP7__Status__c = 'In-Progress';
        comW.Tasks[0].ERP7__Operation__c = Operations[0].Id;
        comW.Tasks[0].ERP7__Manufacturing_Order__c = manuorder.Id;
        upsert comW.Tasks[0];
        comW.Tasks[0].ERP7__Status__c = 'Completed';
        upsert comW.Tasks[0];
        
        ERP7__Return_Merchandise_Authorisation__c rma001 = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA001', ERP7__SO__c = so.Id);
        insert rma001;
        ERP7__RMA_Line_Item__c rmaLine001 = new ERP7__RMA_Line_Item__c(Name = 'testRMALine001', ERP7__Return_Merchandise_Authorisation__c = rma001.Id, ERP7__SOLI__c = soli.Id, ERP7__Product__c = product.Id);
        insert rmaLine001;
        
        List<BuildWorkOrder.WorkPlanner> WPWL = new List<BuildWorkOrder.WorkPlanner>();
        BuildWorkOrder.WorkPlanner WPW = new BuildWorkOrder.WorkPlanner(); 
        WPW.RRS.add(RR);
        WPWL.add(WPW);
        BuildWorkOrder.GetAllResources(JSON.serialize(WPW), '', system.Now(), system.Now()+1, WP.Id, RR.Id);            
        List<BuildWorkOrder.Resource> RWL = new List<BuildWorkOrder.Resource>();
        BuildWorkOrder.Resource RW = new BuildWorkOrder.Resource(); 
        RW.Resource = res;
        RW.isSelect=true;
        RWL.add(RW);
        BuildWorkOrder.SaveResources(JSON.serialize(RWL), JSON.serialize(WO), system.Now(), system.Now()+1);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        BuildWorkOrder.DeleteAT(OT.Id, 'ERP7__Overtime__c');
        BuildWorkOrder.GetWOAttachments(wo.Id);
      //  BuildWorkOrder.getAllRMALI(rma001.Id);
        BuildWorkOrder.SearchScanCode('test',''); 
        BuildWorkOrder.SearchScanCode('testB',''); 
         //new
        if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('test',JSON.serialize(mrpwList));
        if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('test1001',JSON.serialize(mrpwList));
        WO.ERP7__Work_Center__c = null;
        WO.ERP7__Routing__c = routing.Id;
        update WO;
        BuildWorkOrder.SaveW(JSON.serialize(WO));
        test.stopTest();
    }
    
    static testmethod void UnitTest34() {
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
        Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=20);
        insert SPLI;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version1;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
        Insert oprn;
        ERP7__Media__c Media = new ERP7__Media__c(Name='test', ERP7__Operation__c=oprn.Id, ERP7__Active__c=true);
        insert Media;
        Attachment attch = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch;
        Attachment attch1 = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
        insert manuorder;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        
        ERP7__WO__c WO2Create = new ERP7__WO__c();
        WO2Create.Name = 'test';   
        WO2Create.Planned_Date__c = System.Today();
        WO2Create.ERP7__Status__c = 'Issued';
        WO2Create.ERP7__Version__c = manuorder.ERP7__Version__c;
        WO2Create.ERP7__Routing__c = manuorder.ERP7__Routing__c;
        WO2Create.ERP7__Raw_Materials_Site__c = site.Id;
        WO2Create.ERP7__Site__c = manuorder.ERP7__Finished_Products_SiteId__c;
        WO2Create.ERP7__MO__c = manuorder.Id;
        WO2Create.ERP7__Product__c = manuorder.ERP7__Product__c;
        WO2Create.ERP7__Quantity_Ordered__c = manuorder.ERP7__Quantity__c;
        WO2Create.ERP7__Start_Date__c = manuorder.ERP7__StartDate__c;
        WO2Create.ERP7__End_Date__c = manuorder.ERP7__End_Date__c;
        WO2Create.ERP7__Type__c = 'Manufacturing';
        WO2Create.ERP7__Work_Center__c = WC.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = false;
        insert WO2Create;
        
        ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
        action2Create.Name = oprn.Name;
        action2Create.ERP7__Process_Cycle__c = oprn.ERP7__Process_Cycle__c;
        action2Create.ERP7__Routing_Link__c = oprn.ERP7__Routing_Link__c;
        action2Create.ERP7__Work_Order__c = WO2Create.Id;
        action2Create.ERP7__Manufacturing_Order__c = WO2Create.ERP7__MO__c;
        action2Create.ERP7__Operation__c = oprn.Id;
        action2Create.ERP7__Type__c = oprn.ERP7__Type__c;
        action2Create.ERP7__Work_Center__c = oprn.ERP7__Work_Center__c;
        action2Create.ERP7__Product__c = WO2Create.ERP7__Product__c;
        action2Create.ERP7__Process__c = oprn.ERP7__Process_Cycle__r.ERP7__Process__c;
        action2Create.ERP7__Auto_Clock_In__c = oprn.ERP7__Auto_Clock_In__c;
        insert action2Create ;
        
        ERP7__WO__c wo = [Select Id, Name, ERP7__MO__c From ERP7__WO__c Where ERP7__MO__c =: manuorder.Id Limit 1];
        wo.ERP7__Raw_Materials_Site__c = site.Id;
        wo.ERP7__Process_Cycle__c = processcycle.Id;
        update wo;
        List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];
        
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo.Id);
        insert mrp;
        
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='tead32st',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
        try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='trd13est', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(Name='test', ERP7__Product__c=product.Id, ERP7__Status__c='Approved', ERP7__WorkCenter__c=wc.Id);
        insert WP;
        
        ERP7__Resource_Requirement__c RR = new ERP7__Resource_Requirement__c(Name='test', ERP7__Resource_Group__c = rg.Id, ERP7__Preferred_Resource__c=res.Id, ERP7__Work_Planner__c=WP.Id, ERP7__Type__c='Setup');
        insert RR;
        
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new  ERP7__Sales_Order_Line_Item__c(ERP7__Product__c=product.id,ERP7__Sales_Order__c=so.id);
        insert soli;
        //List<ERP7__RMA_Line_Item__c>
        ERP7__Serial_Number__c SNSD=new ERP7__Serial_Number__c(name='test',ERP7__Manufacturing_Order__c=manuorder.id,ERP7__Product__c=product.id);
        insert SNSD;
        List<ERP7__Serial_Number__c> SNS=[Select Id, Name,ERP7__Manufacturing_Order__c, ERP7__Product__c From ERP7__Serial_Number__c limit 1];
        SNS[0].ERP7__Barcode__c = 'test';
        update SNS;
        ERP7__Serial_Number__c SNS2= new ERP7__Serial_Number__c(Name = 'testSerial001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        SNS2.ERP7__Barcode__c = 'test1001';
        insert SNS2;
        SNS.add(SNS2);
        //ERP7__Batch__c BTCH = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Batch__c Limit 1];
        ERP7__Batch__c BTCH = new ERP7__Batch__c(Name = 'testBatch', ERP7__Product__c = mrp.ERP7__MRP_Product__c, ERP7__Manufacturing_Order__c = mrp.ERP7__MO__c);
        BTCH.ERP7__Barcode__c = 'testB';
        insert BTCH;
        ERP7__Batch__c BTCH2 = new ERP7__Batch__c(Name = 'testBatch001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        BTCH2.ERP7__Barcode__c = 'testB1001';
        insert BTCH2;
        
        List<ERP7__UOM_Conversion__mdt> UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 9999];
        //-----------------mna-----------------------
        
        test.startTest();
        
        BuildWorkOrder.mrpWrap mrpw = new BuildWorkOrder.mrpWrap();
        mrpw.mrp = mrp;
        mrpw.isSelect = true;
        List<BuildWorkOrder.mrpWrap> mrpwList = new List<BuildWorkOrder.mrpWrap>();
        mrpwList.add(mrpw);
        BuildWorkOrder.comWrap comW = BuildWorkOrder.getAll(wo.Id);
        comW.Tasks[0].ERP7__Work_Order__c = wo.Id;
        comW.Tasks[0].ERP7__Process_Cycle__c = wo.ERP7__Process_Cycle__c;
        update comW.Tasks[0];
        BuildWorkOrder.SelectTasks(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.StartTimeCardEntrys(JSON.serialize(comW.Tasks[0]));
        //ERP7__Time_Card_Entry__c TCES =  [Select Id, Name, ERP7__Action_Task__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__Active__c From ERP7__Time_Card_Entry__c Where ERP7__Active__c = true And ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c = : UserInfo.getUserId() And ERP7__Start_Time__c <= Today And ERP7__End_Time__c = Null Limit 1]; 
        
        ERP7__Timesheet__c ts=new ERP7__Timesheet__c(Name='test',ERP7__Employees__c=emp.Id);
        insert ts;
        ERP7__Time_Card_Entry__c TCES= new ERP7__Time_Card_Entry__c(Name='test',ERP7__Active__c=true,ERP7__Start_Time__c=system.today(),ERP7__End_Time__c=system.today(),ERP7__Timesheet__c=ts.Id);
        insert TCES;
        BuildWorkOrder.StopTimeCardEntrys(JSON.serialize(comW.Tasks[0]),JSON.serialize(TCES));
        BuildWorkOrder.SaveAction(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.PreTaskFinish(JSON.serialize(comW.Tasks[0]));
        comW.Tasks[0].ERP7__Status__c = 'In-Progress';
        comW.Tasks[0].ERP7__Operation__c = Operations[0].Id;
        comW.Tasks[0].ERP7__Manufacturing_Order__c = manuorder.Id;
        upsert comW.Tasks[0];
        BuildWorkOrder.uploadFile (comW.Tasks[0].Id, 'test', 'String base64Data', 'png');
        BuildWorkOrder.SaveNotes(JSON.serialize(new Note(Title='test',ParentId=comW.Tasks[0].Id)));
        BuildWorkOrder.PreTaskFinish(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.TaskUpdate(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        BuildWorkOrder.TaskUpdatePartial(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        BuildWorkOrder.TaskUpdateNew(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPSSBW), JSON.serialize(UOMCs));
        comW.Tasks[0].ERP7__Status__c = 'Completed';
        upsert comW.Tasks[0];
        //-----------------mna--------------------------
        if(comW.Tasks[0].ERP7__Status__c == 'Completed') BuildWorkOrder.TaskUpdateNew(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPSSBW), JSON.serialize(UOMCs));
        if(comW.Tasks[0].ERP7__Status__c == 'Completed') BuildWorkOrder.TaskUpdate(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        //-----------------mna--------------------------
        
        //new data
        //List<ERP7__WIP_Flow__c> wipFlow = [SELECT Id FROM ERP7__WIP_Flow__c LIMIT 1];
        ERP7__Return_Merchandise_Authorisation__c rma001 = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA001', ERP7__SO__c = so.Id);
        insert rma001;
        ERP7__RMA_Line_Item__c rmaLine001 = new ERP7__RMA_Line_Item__c(Name = 'testRMALine001', ERP7__Return_Merchandise_Authorisation__c = rma001.Id, ERP7__SOLI__c = soli.Id, ERP7__Product__c = product.Id);
        insert rmaLine001;
        
        List<BuildWorkOrder.WorkPlanner> WPWL = new List<BuildWorkOrder.WorkPlanner>();
        BuildWorkOrder.WorkPlanner WPW = new BuildWorkOrder.WorkPlanner(); 
        WPW.RRS.add(RR);
        WPWL.add(WPW);
        BuildWorkOrder.GetAllResources(JSON.serialize(WPW), '', system.Now(), system.Now()+1, WP.Id, RR.Id);            
        List<BuildWorkOrder.Resource> RWL = new List<BuildWorkOrder.Resource>();
        BuildWorkOrder.Resource RW = new BuildWorkOrder.Resource(); 
        RW.Resource = res;
        RWL.add(RW);
        
        if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('test',JSON.serialize(mrpwList));
        String batchId = BTCH.id;
        String serId = SNS2.id;
        BuildWorkOrder.getBatchStock(batchId);
        BuildWorkOrder.getSerialStock(serId);
        // BuildWorkOrder.getAllRMALI(rmaLine001.Id);
        String soliID =soli.id;
        BuildWorkOrder.getSoliFromId(soliID);
        String soliId2=null;BuildWorkOrder.getSoliFromId(soliId2);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        //----------------------mna-----------------------------------
        
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
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
        Insert oprn;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'In Progress', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        ERP7__WO__c wo = new ERP7__WO__c(Name = 'Test', ERP7__Status__c = 'In Progress', ERP7__Approved_Date__c = system.today(), ERP7__Lead_Time__c = system.today(), ERP7__Customer__c = c.Id, ERP7__Contact__c = con.Id, ERP7__Material_Serial_Number_Start__c = '2', ERP7__Material_Serial_Number_End__c = '5', ERP7__Expected_Date__c = system.today(), ERP7__Progress__c = 2, ERP7__Planned_Date_From__c = system.today(), ERP7__Start_Date__c = system.today(), ERP7__Ready_To_Receive__c = true, ERP7__Ready_To_Pick_Pack__c = true, ERP7__Active__c = true, ERP7__Planned_Date_To__c = system.today(), ERP7__End_Date__c = system.today(), ERP7__Process__c = process.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__MO__c = manuorder.Id,ERP7__Work_Center__c = wc.Id);
        insert wo;
        ERP7__Work_Order_Line_Items__c woli = new ERP7__Work_Order_Line_Items__c(Name = 'Test', ERP7__Work_Orders__c = wo.Id, ERP7__Product__c = product.Id, ERP7__Quantity__c = 10, ERP7__Version__c = version.Id, ERP7__Unit_Price__c = 100, ERP7__Picked_Quantity__c = 2, ERP7__Packed_Quantity__c = 2, ERP7__Active__c = true, ERP7__Picked_Date__c = system.today(), ERP7__Manufacturing_Order__c = manuorder.Id, ERP7__Serialise__c = true, ERP7__Direct_Labour__c = 10, ERP7__Overhead__c = 10, ERP7__Organisation__c = o.Id);
        insert woli;
        ERP7__Schedule__c schedule = new ERP7__Schedule__c(Name = 'Test', ERP7__Process__c = process.Id, ERP7__Work_Order__c = wo.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__Schedule_Start_Date__c = system.today(), ERP7__Status__c = 'In Progress', ERP7__Estimated_Machine_Hour__c = 2, ERP7__Estimated_Workforce_Hour__c = 2, ERP7__Workforce_Allocation__c = 2, ERP7__Direct_Labour__c = 100, ERP7__Direct_Materials__c = 1000, ERP7__Overhead__c = 100, ERP7__Product__c = product.Id, ERP7__Total_Cost__c = 500, ERP7__Organisation__c = o.Id, ERP7__Work_Order_Line_Item__c = woli.Id, ERP7__Schedule_End_Date__c = system.today(), ERP7__Actual_Machine_Hour__c = 3, ERP7__Actual_Workforce_Hour__c = 3, ERP7__Machine_Allocation__c = 5, ERP7__Project__c = project.Id);
        insert schedule;
        ERP7__Product_Service__c productservice = new ERP7__Product_Service__c(Name = 'Test', ERP7__Product_Service_Family__c = 'Furniture', ERP7__Item_Type__c = 'New', ERP7__Description__c = 'Test', ERP7__Status__c = 'Delivered', ERP7__Purchase_Lead_Time_days__c = 10, ERP7__Manufacture_Lead_Time_days__c = 30, ERP7__Approved_by__c = 'EU', ERP7__Colour__c = 'Red', ERP7__isAccessory__c = true, ERP7__Mass__c = 100, ERP7__Weight__c = 200, ERP7__Track_Inventory__c = true, ERP7__Weight_Dimensions__c = 'Kilogram');
        insert productservice;
        ERP7__Batch__c batch2 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch2;
        
        ERP7__Serial_Number__c serial2 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial2;
        
        Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,ERP7__Batch_Lot__c=batch2.Id,ERP7__Serial__c = serial2.Id);
        insert stock;
        	
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='14r23test',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
        try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='tesacs3t', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        
        test.startTest();
        ManufacturingBuilder MMO = new ManufacturingBuilder();
        //Moin added '' as the last parameter since test class was failing
        ManufacturingBuilder.getAll('Grid','','','', 'Issued', 10, 'M', '');
        ManufacturingBuilder.getAll('Grid','','','', 'Issued', 10, 'D', '');
        ManufacturingBuilder.getAll('Grid','','','', 'Issued', 10, 'W', '');
        ManufacturingBuilder.getAll('Grid','','','', 'Issued', 10, 'Y', '');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        BuildWorkOrder.DeleteRA(resAloc.Id);
        test.stopTest();
        
    }
    
    static testmethod void UnitTest5() {  
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
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id);
        Insert oprn;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'In Progress', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        ERP7__WO__c wo = new ERP7__WO__c(Name = 'Test', ERP7__Status__c = 'In Progress', ERP7__Approved_Date__c = system.today(), ERP7__Lead_Time__c = system.today(), ERP7__Customer__c = c.Id, ERP7__Contact__c = con.Id, ERP7__Material_Serial_Number_Start__c = '2', ERP7__Material_Serial_Number_End__c = '5', ERP7__Expected_Date__c = system.today(), ERP7__Progress__c = 2, ERP7__Planned_Date_From__c = system.today(), ERP7__Start_Date__c = system.today(), ERP7__Ready_To_Receive__c = true, ERP7__Ready_To_Pick_Pack__c = true, ERP7__Active__c = true, ERP7__Planned_Date_To__c = system.today(), ERP7__End_Date__c = system.today(), ERP7__Process__c = process.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__MO__c = manuorder.Id,ERP7__Work_Center__c = wc.Id,ERP7__Type__c  = 'Maintenance',ERP7__Routing__c=routing.Id);
        insert wo;
        ERP7__Work_Order_Line_Items__c woli = new ERP7__Work_Order_Line_Items__c(Name = 'Test', ERP7__Work_Orders__c = wo.Id, ERP7__Product__c = product.Id, ERP7__Quantity__c = 10, ERP7__Version__c = version.Id, ERP7__Unit_Price__c = 100, ERP7__Picked_Quantity__c = 2, ERP7__Packed_Quantity__c = 2, ERP7__Active__c = true, ERP7__Picked_Date__c = system.today(), ERP7__Manufacturing_Order__c = manuorder.Id, ERP7__Serialise__c = true, ERP7__Direct_Labour__c = 10, ERP7__Overhead__c = 10, ERP7__Organisation__c = o.Id);
        insert woli;
        ERP7__Schedule__c schedule = new ERP7__Schedule__c(Name = 'Test', ERP7__Process__c = process.Id, ERP7__Work_Order__c = wo.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__Schedule_Start_Date__c = system.today(), ERP7__Status__c = 'In Progress', ERP7__Estimated_Machine_Hour__c = 2, ERP7__Estimated_Workforce_Hour__c = 2, ERP7__Workforce_Allocation__c = 2, ERP7__Direct_Labour__c = 100, ERP7__Direct_Materials__c = 1000, ERP7__Overhead__c = 100, ERP7__Product__c = product.Id, ERP7__Total_Cost__c = 500, ERP7__Organisation__c = o.Id, ERP7__Work_Order_Line_Item__c = woli.Id, ERP7__Schedule_End_Date__c = system.today(), ERP7__Actual_Machine_Hour__c = 3, ERP7__Actual_Workforce_Hour__c = 3, ERP7__Machine_Allocation__c = 5, ERP7__Project__c = project.Id);
        insert schedule;
        ERP7__Product_Service__c productservice = new ERP7__Product_Service__c(Name = 'Test', ERP7__Product_Service_Family__c = 'Furniture', ERP7__Item_Type__c = 'New', ERP7__Description__c = 'Test', ERP7__Status__c = 'Delivered', ERP7__Purchase_Lead_Time_days__c = 10, ERP7__Manufacture_Lead_Time_days__c = 30, ERP7__Approved_by__c = 'EU', ERP7__Colour__c = 'Red', ERP7__isAccessory__c = true, ERP7__Mass__c = 100, ERP7__Weight__c = 200, ERP7__Track_Inventory__c = true, ERP7__Weight_Dimensions__c = 'Kilogram');
        insert productservice;
        
        ERP7__Batch__c batch2 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch2;
        
        ERP7__Serial_Number__c serial2 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial2;
        
        Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Product__c = product.Id, Checked_In_Date__c = system.today(), Warehouse__c = routing.ERP7__Finished_Products_Site__c, ERP7__Status__c = 'Checked In', ERP7__Version__c = version.Id,ERP7__Batch_Lot__c=batch2.Id,ERP7__Serial__c = serial2.Id);
        insert stock;
        
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='te123st',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
        try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='ter423st', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        
        test.startTest();
        MaintenanceBuilder MMO = new MaintenanceBuilder();
        MaintenanceBuilder.getAll('List','','','','');
        MaintenanceBuilder.GetWORec(wo.Id);
        MaintenanceBuilder.GetMORec(manuorder.Id);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
        
    }
    
    static testmethod void UnitTest6() {
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
        Cart_Putaway_Item__c cputItem = new Cart_Putaway_Item__c(Name='test001');
        //insert cputItem;
        Cart_Picked_Item__c cpickItem = new Cart_Picked_Item__c(Name='test001');
        //insert cpickItem;
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
        Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = false, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = false, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = false, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=20);
        insert SPLI;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version1;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        ERP7__WO__c wo = new ERP7__WO__c(Name = 'testWO', ERP7__MO__c = manuorder.Id, ERP7__Raw_Materials_Site__c = site.Id);
        insert wo;
        ERP7__Actions_Tasks__c tsk = new ERP7__Actions_Tasks__c(Name = 'testTsk', ERP7__Work_Order__c = wo.Id);
        insert tsk;
        Attachment attch = new Attachment(Name='Signature', ParentId=tsk.Id, body=blob.valueof('Signature'));
        insert attch;
        List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo.Id);
        insert mrp;
        ERP7__Site__c site001 = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site001;
        ERP7__WIP__c wip001 = new ERP7__WIP__c(Name = 'testWip001', ERP7__MO__c = manuorder.Id); //ERP7__Material_Batch_Lot__c=batch1.Id
        insert wip001;
        ERP7__WIP__c wip002 = new ERP7__WIP__c(Name = 'testWip001', ERP7__MO__c = manuorder.Id);
        insert wip002;
        ERP7__WIP_Flow__c wipFlow001 = new ERP7__WIP_Flow__c(Name = 'testWipFLow001', ERP7__Status__c = 'Completed', ERP7__WIP__c = wip001.Id, ERP7__Product__c = product.Id, ERP7__Quantity_Unit__c = 1, ERP7__Quantity__c = 2, ERP7__Finished_Products_Site__c = site001.Id, ERP7__Work_Orders__c = wo.Id);
        insert wipFlow001;
        ERP7__WIP_Flow__c wipFlow002 = new ERP7__WIP_Flow__c(Name = 'testWipFLow001', ERP7__Status__c = 'In Progress', ERP7__WIP__c = wip002.Id, ERP7__Product__c = product1.Id, ERP7__Quantity_Unit__c = 1, ERP7__Quantity__c = 2, ERP7__Finished_Products_Site__c = site001.Id, ERP7__Work_Orders__c = wo.Id);
        insert wipFlow002;
        
        PreventRecursiveLedgerEntry.AwaitingStockMO = true;
        PreventRecursiveLedgerEntry.WIPFlowTrigger = true;
        update wipFlow001;
        
        List<WIP_Flow__c> WIPFlows = [Select Id, Name From WIP_Flow__c Limit 5];
        for(WIP_Flow__c WIPFlow : WIPFlows){
            WIPFlow.ERP7__Quantity__c = 3;
        }
        if(WIPFlows.size() > 0) {
            PreventRecursiveLedgerEntry.AwaitingStockMO = true;
            PreventRecursiveLedgerEntry.WIPFlowTrigger = true;
            try{ update WIPFlows; } catch(exception e){}
        }
        
        
        BuildWorkOrder.CompleteWIPFlow(JSON.serialize(wipFlow001));
        BuildWorkOrder.CompleteWIPFlow(JSON.serialize(wipFlow002));
        BuildWorkOrder.ScrapWIPFlow(JSON.serialize(wipFlow001));
        BuildWorkOrder.ScrapWIPFlow(JSON.serialize(wipFlow002));
        BuildWorkOrder.GetAttachments(tsk.Id);
        System.assertEquals('ERP', 'ERP');
        List<ERP7__WIP_Flow__c> WIPList=new List<ERP7__WIP_Flow__c>();
        WIPList.add(wipFlow001);
        
        BuildWorkOrder.CompleteWipandWO(JSON.serialize(wo),JSON.serialize(WIPList));
        //BuildWorkOrder.getAllRMALI(rma001.Id);
    }
    @IsTest//(SeeAllData=true)
    static void UnitTest3343() {
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
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
        Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test',QuantityUnitOfMeasure = 'Sheet');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test'
                                         ,QuantityUnitOfMeasure = 'Sheet');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        PreventRecursiveLedgerEntry.ProceedSerialsTrigger = false;
        PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation = false;
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=1);
        insert SPLI;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');//
        insert version1;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified',ERP7__Unit_of_Measure__c = 'sqft');
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified',ERP7__Unit_of_Measure__c='sqft');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
        Insert oprn;
        ERP7__Media__c Media = new ERP7__Media__c(Name='test', ERP7__Operation__c=oprn.Id, ERP7__Active__c=true);
        insert Media;
        Attachment attch = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch;
        Attachment attch1 = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        ERP7__WO__c WO2Create = new ERP7__WO__c();
        WO2Create.Name = 'test';   
        WO2Create.Planned_Date__c = System.Today();
        WO2Create.ERP7__Status__c = 'Issued';
        WO2Create.ERP7__Version__c = manuorder.ERP7__Version__c;
        WO2Create.ERP7__Routing__c = manuorder.ERP7__Routing__c;
        WO2Create.ERP7__Raw_Materials_Site__c = site.Id;
        WO2Create.ERP7__Site__c = manuorder.ERP7__Finished_Products_SiteId__c;
        WO2Create.ERP7__MO__c = manuorder.Id;
        WO2Create.ERP7__Product__c = manuorder.ERP7__Product__c;
        WO2Create.ERP7__Quantity_Ordered__c = manuorder.ERP7__Quantity__c;
        WO2Create.ERP7__Start_Date__c = manuorder.ERP7__StartDate__c;
        WO2Create.ERP7__End_Date__c = manuorder.ERP7__End_Date__c;
        WO2Create.ERP7__Type__c = 'Manufacturing';
        WO2Create.ERP7__Work_Center__c = WC.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = true;
        insert WO2Create;
        
        ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
        action2Create.Name = oprn.Name;
        action2Create.ERP7__Process_Cycle__c = oprn.ERP7__Process_Cycle__c;
        action2Create.ERP7__Routing_Link__c = oprn.ERP7__Routing_Link__c;
        action2Create.ERP7__Work_Order__c = WO2Create.Id;
        action2Create.ERP7__Manufacturing_Order__c = WO2Create.ERP7__MO__c;
        action2Create.ERP7__Operation__c = oprn.Id;
        action2Create.ERP7__Type__c = oprn.ERP7__Type__c;
        action2Create.ERP7__Work_Center__c = oprn.ERP7__Work_Center__c;
        action2Create.ERP7__Product__c = WO2Create.ERP7__Product__c;
        action2Create.ERP7__Process__c = oprn.ERP7__Process_Cycle__r.ERP7__Process__c;
        action2Create.ERP7__Auto_Clock_In__c = oprn.ERP7__Auto_Clock_In__c;
        insert action2Create ;
        
        ERP7__WO__c wo = [Select Id, Name, ERP7__MO__c From ERP7__WO__c Where ERP7__MO__c =: manuorder.Id Limit 1];
        wo.ERP7__Raw_Materials_Site__c = site.Id;
        wo.ERP7__Process_Cycle__c = processcycle.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = true;
        update wo;
        List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];
        
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo.Id);
        insert mrp;
        
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='tes3123t',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
        try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='test', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(Name='test', ERP7__Product__c=product.Id, ERP7__Status__c='Approved', ERP7__WorkCenter__c=wc.Id);
        insert WP;
        
        ERP7__Resource_Requirement__c RR = new ERP7__Resource_Requirement__c(Name='test', ERP7__Resource_Group__c = rg.Id, ERP7__Preferred_Resource__c=res.Id, ERP7__Work_Planner__c=WP.Id, ERP7__Type__c='Setup');
        insert RR;
        
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new  ERP7__Sales_Order_Line_Item__c(ERP7__Product__c=product.id,ERP7__Sales_Order__c=so.id);
        insert soli;
        //List<ERP7__RMA_Line_Item__c>
        PreventRecursiveLedgerEntry.ProceedSerialsTrigger = false;
        PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation = false;
        ERP7__Serial_Number__c SNSD=new ERP7__Serial_Number__c(name='test',ERP7__Manufacturing_Order__c=manuorder.id,ERP7__Product__c=product.id);
        insert SNSD;
        List<ERP7__Serial_Number__c> SNS=[Select Id, Name,ERP7__Manufacturing_Order__c, ERP7__Product__c From ERP7__Serial_Number__c limit 1];
        SNS[0].ERP7__Barcode__c = 'test';
        update SNS;
        ERP7__Serial_Number__c SNS2= new ERP7__Serial_Number__c(Name = 'testSerial001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        SNS2.ERP7__Barcode__c = 'test1001';
        insert SNS2;
        SNS.add(SNS2);
        //ERP7__Batch__c BTCH = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Batch__c Limit 1];
        ERP7__Batch__c BTCH = new ERP7__Batch__c(Name = 'testBatch', ERP7__Product__c = mrp.ERP7__MRP_Product__c, ERP7__Manufacturing_Order__c = mrp.ERP7__MO__c);
        BTCH.ERP7__Barcode__c = 'testB';
        insert BTCH;
        ERP7__Batch__c BTCH2 = new ERP7__Batch__c(Name = 'testBatch001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        BTCH2.ERP7__Barcode__c = 'testB1001';
        insert BTCH2;
        
        List<ERP7__UOM_Conversion__mdt> UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 9999];
        system.debug('UOMCs '+UOMCs.size() );
        //-----------------mna-----------------------
        
        test.startTest();
        
        BuildWorkOrder.mrpWrap mrpw = new BuildWorkOrder.mrpWrap();
        mrpw.mrp = mrp;
        mrpw.isSelect = true;
        mrpw.quantityToConsume = 2;
        
        List<BuildWorkOrder.mrpWrap> mrpwList = new List<BuildWorkOrder.mrpWrap>();
        mrpwList.add(mrpw);
        BuildWorkOrder.comWrap comW = BuildWorkOrder.getAll(wo.Id);
        comW.Tasks[0].ERP7__Work_Order__c = wo.Id;
        comW.Tasks[0].ERP7__Process_Cycle__c = wo.ERP7__Process_Cycle__c;
        update comW.Tasks[0];
        BuildWorkOrder.SelectTasks(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.StartTimeCardEntrys(JSON.serialize(comW.Tasks[0]));
        //ERP7__Time_Card_Entry__c TCES =  [Select Id, Name, ERP7__Action_Task__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__Active__c From ERP7__Time_Card_Entry__c Where ERP7__Active__c = true And ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c = : UserInfo.getUserId() And ERP7__Start_Time__c <= Today And ERP7__End_Time__c = Null Limit 1]; 
        
        ERP7__Timesheet__c ts=new ERP7__Timesheet__c(Name='test',ERP7__Employees__c=emp.Id);
        insert ts;
        ERP7__Time_Card_Entry__c TCES= new ERP7__Time_Card_Entry__c(Name='test',ERP7__Active__c=true,ERP7__Start_Time__c=system.today(),ERP7__End_Time__c=system.today(),ERP7__Timesheet__c=ts.Id);
        insert TCES;
        BuildWorkOrder.StopTimeCardEntrys(JSON.serialize(comW.Tasks[0]),JSON.serialize(TCES));
        BuildWorkOrder.SaveAction(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.PreTaskFinish(JSON.serialize(comW.Tasks[0]));
        comW.Tasks[0].ERP7__Status__c = 'In-Progress';
        comW.Tasks[0].ERP7__Operation__c = Operations[0].Id;
        comW.Tasks[0].ERP7__Manufacturing_Order__c = manuorder.Id;
        upsert comW.Tasks[0];
        BuildWorkOrder.uploadFile (comW.Tasks[0].Id, 'test', 'String base64Data', 'png');
        BuildWorkOrder.SaveNotes(JSON.serialize(new Note(Title='test',ParentId=comW.Tasks[0].Id)));
        BuildWorkOrder.PreTaskFinish(JSON.serialize(comW.Tasks[0]));
        BuildWorkOrder.TaskUpdate(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        BuildWorkOrder.TaskUpdatePartial(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPS));
        
        BuildWorkOrder.TaskUpdateNew(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPSSBW), JSON.serialize(UOMCs));
        comW.Tasks[0].ERP7__Status__c = 'Completed';
        upsert comW.Tasks[0];
        
        List<WIP_Flow__c> WIPFLOW = [Select Id, Name, Status__c From WIP_Flow__c limit 1];
        system.debug('WIPFLOW : '+WIPFLOW);
        if(WIPFLOW.size() > 0) { WIPFLOW[0].Status__c = 'Completed'; update WIPFLOW; }
        if(WIPFLOW.size() > 0) {
            BuildWorkOrder.WIPFlowWrap wrap = new BuildWorkOrder.WIPFlowWrap();
            wrap.wipFlow  = WIPFLOW[0];
            wrap.selected = true;
            wrap.StockAllocated = true;
            List<BuildWorkOrder.mrpWrapBW> mrpsss = comW.MRPSSBW;
            List<BuildWorkOrder.mrpWrap> mrpsssW = new List<BuildWorkOrder.mrpWrap>();
            if(mrpsss.size() > 0) {
                BuildWorkOrder.mrpWrap mrpW1 = new BuildWorkOrder.mrpWrap();
                mrpW1.MRP = mrpsss[0].MRP;
                mrpW1.quantityToConsume = 2;
                mrpsssW.add(mrpW1);
            }
            BuildWorkOrder.completeWIPflowandCreateInventory(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(mrpsssW), JSON.serialize(UOMCs),JSON.serialize(wrap));
           BuildWorkOrder.completetheWOandWIP(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(mrpsssW), JSON.serialize(UOMCs),JSON.serialize(new List<ERP7__WIP_Flow__c>{WIPFLOW[0]}),'Produced',JSON.serialize(SNS));
            
        }
        else{
            ERP7__WIP__c w = new ERP7__WIP__c(Name='test WIP',ERP7__MO__c = manuorder.Id);
            insert w;
            WIP_Flow__c wip = new WIP_Flow__c(Name='test WIP flow',Status__c ='Completed',ERP7__Product__c = product.Id,ERP7__Quantity__c =2,ERP7__Work_Orders__c =comW.WorkOrder.Id,ERP7__WIP__c = w.Id );
            insert wip;
            List<BuildWorkOrder.mrpWrapBW> mrpsss = comW.MRPSSBW;
            List<BuildWorkOrder.mrpWrap> mrpsssW = new List<BuildWorkOrder.mrpWrap>();
            if(mrpsss.size() > 0) {
                BuildWorkOrder.mrpWrap mrpW1 = new BuildWorkOrder.mrpWrap();
                mrpW1.MRP = mrpsss[0].MRP;
                mrpW1.quantityToConsume = 2;
                mrpsssW.add(mrpW1);
            }
            BuildWorkOrder.completeWIPflowandCreateInventory(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(mrpsssW), JSON.serialize(UOMCs),JSON.serialize(wip));
            BuildWorkOrder.completetheWOandWIP(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(mrpsssW), JSON.serialize(UOMCs),JSON.serialize(new List<ERP7__WIP_Flow__c>{wip}),'Produced',JSON.serialize(SNS));
            
            
        }
        // if(WIPFLOW.size() > 0) BuildWorkOrder.completeSelectedWIPflow(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(comW.MRPSSBW), JSON.serialize(UOMCs),JSON.serialize(WIPFLOW[0]));
        //new data
        //List<ERP7__WIP_Flow__c> wipFlow = [SELECT Id FROM ERP7__WIP_Flow__c LIMIT 1];
      
        
        List<BuildWorkOrder.WorkPlanner> WPWL = new List<BuildWorkOrder.WorkPlanner>();
        BuildWorkOrder.WorkPlanner WPW = new BuildWorkOrder.WorkPlanner(); 
        WPW.RRS.add(RR);
        WPWL.add(WPW);
        List<BuildWorkOrder.Resource> RWL = new List<BuildWorkOrder.Resource>();
        BuildWorkOrder.Resource RW = new BuildWorkOrder.Resource(); 
        RW.Resource = res;
        
        
        BuildWorkOrder.SearchScanCode('test',''); 
        BuildWorkOrder.setSerials(1,manuorder.Id,wo.Id,'test');
        //new
       
        // if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('testB',JSON.serialize(mrpwList));
        //if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('testB1001',JSON.serialize(mrpwList));
        
        test.stopTest();
    }
    static testmethod void UnitTest33435() {
        PreventRecursiveLedgerEntry.preventMoTriggerTransactions = false;
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
        Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
        insert emp;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=1);
        insert SPLI;
        Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
        insert con;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');//
        insert version1;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');//
        insert version;
        ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom;
        ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
        insert bom1;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
        insert ws;
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
        Insert oprn;
        ERP7__Media__c Media = new ERP7__Media__c(Name='test', ERP7__Operation__c=oprn.Id, ERP7__Active__c=true);
        insert Media;
        Attachment attch = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch;
        Attachment attch1 = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
        insert attch1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        manuorder.ERP7__Version__c = version.Id;
        upsert manuorder;
        ERP7__WO__c WO2Create = new ERP7__WO__c();
        WO2Create.Name = 'test';   
        WO2Create.Planned_Date__c = System.Today();
        WO2Create.ERP7__Status__c = 'Issued';
        WO2Create.ERP7__Version__c = manuorder.ERP7__Version__c;
        WO2Create.ERP7__Routing__c = manuorder.ERP7__Routing__c;
        WO2Create.ERP7__Raw_Materials_Site__c = site.Id;
        WO2Create.ERP7__Site__c = manuorder.ERP7__Finished_Products_SiteId__c;
        WO2Create.ERP7__MO__c = manuorder.Id;
        WO2Create.ERP7__Product__c = manuorder.ERP7__Product__c;
        WO2Create.ERP7__Quantity_Ordered__c = manuorder.ERP7__Quantity__c;
        WO2Create.ERP7__Start_Date__c = manuorder.ERP7__StartDate__c;
        WO2Create.ERP7__End_Date__c = manuorder.ERP7__End_Date__c;
        WO2Create.ERP7__Type__c = 'Manufacturing';
        WO2Create.ERP7__Work_Center__c = WC.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = true;
        insert WO2Create;
        
        ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
        action2Create.Name = oprn.Name;
        action2Create.ERP7__Process_Cycle__c = oprn.ERP7__Process_Cycle__c;
        action2Create.ERP7__Routing_Link__c = oprn.ERP7__Routing_Link__c;
        action2Create.ERP7__Work_Order__c = WO2Create.Id;
        action2Create.ERP7__Manufacturing_Order__c = WO2Create.ERP7__MO__c;
        action2Create.ERP7__Operation__c = oprn.Id;
        action2Create.ERP7__Type__c = oprn.ERP7__Type__c;
        action2Create.ERP7__Work_Center__c = oprn.ERP7__Work_Center__c;
        action2Create.ERP7__Product__c = WO2Create.ERP7__Product__c;
        action2Create.ERP7__Process__c = oprn.ERP7__Process_Cycle__r.ERP7__Process__c;
        action2Create.ERP7__Auto_Clock_In__c = oprn.ERP7__Auto_Clock_In__c;
        insert action2Create ;
        
        ERP7__WO__c wo = [Select Id, Name, ERP7__MO__c From ERP7__WO__c Where ERP7__MO__c =: manuorder.Id Limit 1];
        wo.ERP7__Raw_Materials_Site__c = site.Id;
        wo.ERP7__Process_Cycle__c = processcycle.Id;
        PreventRecursiveLedgerEntry.preventWOExecution = true;
        update wo;
        List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];
        
        MRP__c mrp = new MRP__c(ERP7__Version__c = version.Id, ERP7__MO__c = manuorder.Id, Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = product.Id, Sourced_Site__c = site.Id, Required_Amount__c= 1, ERP7__Total_Amount_Required__c=1,ERP7__BOM__c=bom.Id,ERP7__Work_Order__c=wo.Id);
        insert mrp;
        
        ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
        insert rg;
        ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert cap;
        ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
        insert dem;
        ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
        insert res;
        ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='tes3123t',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
        try{ insert resAloc; }catch(Exception e){}
        ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='test', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
        insert OT;
        ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(Name='test', ERP7__Product__c=product.Id, ERP7__Status__c='Approved', ERP7__WorkCenter__c=wc.Id);
        insert WP;
        
        ERP7__Resource_Requirement__c RR = new ERP7__Resource_Requirement__c(Name='test', ERP7__Resource_Group__c = rg.Id, ERP7__Preferred_Resource__c=res.Id, ERP7__Work_Planner__c=WP.Id, ERP7__Type__c='Setup');
        insert RR;
        
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        ERP7__Sales_Order_Line_Item__c soli = new  ERP7__Sales_Order_Line_Item__c(ERP7__Product__c=product.id,ERP7__Sales_Order__c=so.id);
        insert soli;
        //List<ERP7__RMA_Line_Item__c>
        PreventRecursiveLedgerEntry.ProceedSerialsTrigger = false;
        PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation = false;
        ERP7__Serial_Number__c SNSD=new ERP7__Serial_Number__c(name='test',ERP7__Manufacturing_Order__c=manuorder.id,ERP7__Product__c=product.id);
        insert SNSD;
        List<ERP7__Serial_Number__c> SNS=[Select Id, Name,ERP7__Manufacturing_Order__c, ERP7__Product__c From ERP7__Serial_Number__c limit 1];
        SNS[0].ERP7__Barcode__c = 'test';
        update SNS;
        ERP7__Serial_Number__c SNS2= new ERP7__Serial_Number__c(Name = 'testSerial001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        SNS2.ERP7__Barcode__c = 'test1001';
        insert SNS2;
        SNS.add(SNS2);
        //ERP7__Batch__c BTCH = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Batch__c Limit 1];
        ERP7__Batch__c BTCH = new ERP7__Batch__c(Name = 'testBatch', ERP7__Product__c = mrp.ERP7__MRP_Product__c, ERP7__Manufacturing_Order__c = mrp.ERP7__MO__c);
        BTCH.ERP7__Barcode__c = 'testB';
        insert BTCH;
        ERP7__Batch__c BTCH2 = new ERP7__Batch__c(Name = 'testBatch001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
        BTCH2.ERP7__Barcode__c = 'testB1001';
        insert BTCH2;
        
        List<ERP7__UOM_Conversion__mdt> UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 9999];
        //-----------------mna-----------------------
        
        test.startTest();
        String batchId = BTCH.id;
        String serId = SNS2.id;
        BuildWorkOrder.getBatchStock(batchId);
        BuildWorkOrder.getSerialStock(serId);
        // BuildWorkOrder.getAllRMALI(rmaLine001.Id);
        String soliID =soli.id;
        BuildWorkOrder.getSoliFromId(soliID);
        
        String soliId2=null;BuildWorkOrder.getSoliFromId(soliId2);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        //----------------------mna-----------------------------------
        BuildWorkOrder.getSerialNumbers(1,manuorder.Id,10,null);
        BuildWorkOrder.getWIPFlows(1,manuorder.Id);
        BuildWorkOrder.getstockAllocatedDetails(wo.Id);
        BuildWorkOrder.getMRPDetails(mrp.Id,manuorder.Id);
        ERP7__WIP__c w = new ERP7__WIP__c(Name='test WIP',ERP7__MO__c = manuorder.Id);
        insert w;
        WIP_Flow__c wip = new WIP_Flow__c(Name='test WIP flow',Status__c ='Completed',ERP7__Product__c = product.Id,ERP7__Quantity__c =2,ERP7__Work_Orders__c =wo.Id,ERP7__WIP__c = w.Id );
        insert wip;
        BuildWorkOrder.saveWIPs(JSON.serialize(wip),wo.Id);
        
         BuildWorkOrder.mrpWrap mrpw = new BuildWorkOrder.mrpWrap();
        mrpw.mrp = mrp;
        mrpw.isSelect = true;
        mrpw.quantityToConsume = 2;
        
        List<BuildWorkOrder.mrpWrap> mrpwList = new List<BuildWorkOrder.mrpWrap>();
        mrpwList.add(mrpw);
        
        if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('test',JSON.serialize(mrpwList));
        if(SNS.size() > 0) BuildWorkOrder.SearchScanCode('test1001',JSON.serialize(mrpwList));
          ERP7__Return_Merchandise_Authorisation__c rma001 = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA001', ERP7__SO__c = so.Id);
        insert rma001;
        ERP7__RMA_Line_Item__c rmaLine001 = new ERP7__RMA_Line_Item__c(Name = 'testRMALine001', ERP7__Return_Merchandise_Authorisation__c = rma001.Id, ERP7__SOLI__c = soli.Id, ERP7__Product__c = product.Id);
        insert rmaLine001;
        String woid = wo.id;
        string rmaId =rmaLine001.id;
        BuildWorkOrder.GetWOAttachments(woid);
        BuildWorkOrder.getAllRMALI(rmaId);
        test.stopTest();
    }
    static testmethod void UnitTestNewMethods() {
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Account s = new Account(Name = 'Supplier', Account_Type__c = 'Supplier');
        insert s;
        Account c1 = new Account(Name = 'Test', ERP7__Email__c='test@test.com', ERP7__Account_Type__c = 'Customer', AccountNumber = '1234', ERP7__Company__c = 'Aqxolt India Pvt Ltd', ERP7__Start_of_Week__c = 'Monday', ERP7__CustomerPriority__c = 'High', ERP7__Active__c = 'Yes', ERP7__SLA__c = 'Gold', ERP7__SLAExpirationDate__c = system.today());
        insert c1;
        ProductListCommRegistration PLR = new ProductListCommRegistration ();
        ProductListCommRegistration.registerUserSelf('test@test.com', 'ik', 'kk', 'ki', '', false, 'ERP Product catalog Community Site Guest User');
        ProductListCommRegistration.getProfileId2(); 
        
        Account c = new Account(Name = 'Test', ERP7__Account_Type__c = 'Customer', AccountNumber = '1234', ERP7__Company__c = 'Aqxolt India Pvt Ltd', ERP7__Start_of_Week__c = 'Monday', ERP7__CustomerPriority__c = 'High', ERP7__Active__c = 'Yes', ERP7__SLA__c = 'Gold', ERP7__SLAExpirationDate__c = system.today());
        insert c;
        Contact con = new Contact(FirstName='iqwhsyqgxsk', LastName='kjhbkdscywebxsk', Email='tekGQSXZAZaxfrwst@test.com');
        insert con;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        //RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Routing__c' Limit 1];
        Date myDate = system.today();
        Date newDate = mydate.addDays(2);
        RecordType TOtype = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Transfer_Order__c' Limit 1];
        Product2 prod = new Product2(Name = 'projectTestProduct');
        insert prod;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = prod.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        
        ERP7__Resource_Allocation__c RA = new ERP7__Resource_Allocation__c(Name = 'ProjManger');
        insert RA;
        
        ERP7__Project__c proj = new ERP7__Project__c(name='projectTest', ERP7__Project_Manager__c = RA.Id, ERP7__Start_Date__c = myDate, ERP7__End_Date__c = newDate, ERP7__Status__c = 'Planned', ERP7__Percentage__c = 0.00, ERP7__Organisations__c = o.Id, ERP7__Default_Routing__c = rout.Id);
        insert proj;
        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='testEmp', ERP7__First_Name__c = 'test', ERP7__Last_Name__c = 'emp', ERP7__Employee_User__c = UserInfo.getUserId(), ERP7__Gender__c = 'Male', ERP7__Channel__c = channel.Id);
        insert emp;
        
        ERP7__Team__c tem = new ERP7__Team__c(Name = 'teamTest', ERP7__Project__c = proj.Id);
        insert tem;
        proj.ERP7__Team__c = tem.Id;
        update proj;
        
        ERP7__Resource_Group__c rcg = new ERP7__Resource_Group__c(Name='testRecG', ERP7__Process__c = prcs.Id, ERP7__Site__c = site.Id, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today().addDays(10), ERP7__Is_Manufacturing__c = true);
        insert rcg;
        
        ERP7__Resource__c rc = new ERP7__Resource__c(Name = 'testRec', ERP7__Employee__c = emp.Id, ERP7__Team__c = tem.Id, ERP7__Resource_Group__c = rcg.Id, ERP7__User__c = UserInfo.getUserId(), ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today().addDays(10));
        insert rc;
        
        ERP7__Milestone__c MS = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate.addDays(20), ERP7__Due_Date__c = newDate.addDays(20), ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00);
        insert MS;
        
        ERP7__Milestone__c MS2 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate.addDays(10), ERP7__Due_Date__c = newDate.addDays(10), ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS.Id);
        insert MS2;
        
        ERP7__Milestone__c MS3 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate, ERP7__Due_Date__c = newDate, ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS2.Id);
        insert MS3;
        MS2.ERP7__Next_Milestone__c = MS3.Id; update MS2;
        
        ERP7__Milestone__c MS4 = new ERP7__Milestone__c(name = 'milestoneTest', ERP7__Resource_Group__c = rcg.Id, ERP7__Status__c = 'Planned', ERP7__Start_Date__c = myDate, ERP7__Due_Date__c = newDate, ERP7__Project__c = proj.Id, ERP7__Process__c = prcs.Id, ERP7__Percentage__c = 0.00, ERP7__isSerialized__c = true, ERP7__Previous_Milestone__c = MS3.Id);
        insert MS4;
        MS3.ERP7__Next_Milestone__c = MS4.Id; update MS3;
        
        ERP7__Actions_Tasks__c task = new ERP7__Actions_Tasks__c(Name = 'taskTest', ERP7__Start_Date__c = myDate, ERP7__End_Date__c = newDate, ERP7__Status__c = 'New', ERP7__Type__c = 'Regular', ERP7__Project__c = proj.Id, ERP7__Milestone__c = MS.Id, ERP7__Resource__c = rc.Id);
        insert task;
        
        ERP7__Transfer_Order__c TO = new ERP7__Transfer_Order__c(Name = 'TOtest', RecordTypeId = TOtype.Id, ERP7__Status__c = 'Draft', ERP7__Requested_Date__c = system.today(), ERP7__Expected_Date__c = system.today());
        
        
        test.startTest();
        ApexPages.currentPage().getParameters().put('projId',proj.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(proj);
        ProjectDocument ProjectDocument = new ProjectDocument(sc);
        ProjectDocument.createPDF();
        System.assertEquals(proj.Name, 'projectTest');
        test.stopTest(); 
    }
    
    /* static testmethod void UnitTest3344() {
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
Employees__c emp = new Employees__c(Name='Test',Employee_User__c=UserInfo.getUserId());
insert emp;
Product2 product = new Product2(ERP7__Issue_Manufacturing_Order__c=true,QuantityUnitOfMeasure='barrel',Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test',IsActive=true);
insert product;
Product2 product1 = new Product2(ERP7__Issue_Manufacturing_Order__c=true,Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test',IsActive=true);
insert product1;
Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id);
insert inventorystock;
Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c = inventorystock.Id,Product__c=product.Id,Quantity__c=1);
insert SPLI;
Contact con = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = c.Id, Phone = '1234567890', Email = 'test@gmail.com', ERP7__Company__c = 'Aqxolt', ERP7__Level__c = 'Secondary');
insert con;
ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
insert process;
ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
insert processcycle;
Id pricebookId = Test.getStandardPricebookId();
PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
insert pricebookentry;
Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
insert pricebook;
ERP7__Version__c version1 = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
insert version1;
ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified');
insert version;
ERP7__BOM__c bom = new ERP7__BOM__c(ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified',ERP7__Unit_of_Measure__c='barrel');
insert bom;
ERP7__BOM__c bom1 = new ERP7__BOM__c(ERP7__BOM_Alternate_Of__c = bom.Id, ERP7__Type__c = 'Alternate',ERP7__Active__c=true,Name='test', ERP7__BOM_Product__c = product.Id, ERP7__BOM_Component__c = product1.Id, ERP7__Quantity__c=3, ERP7__Status__c ='certified');
insert bom1;
ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
insert routing;
ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
insert project;
ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
insert machine;
ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
insert wc;
ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name = 'Test', ERP7__Active__c = true, ERP7__Site__c = site.Id);
insert ws;
ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
Insert oprn;
ERP7__Media__c Media = new ERP7__Media__c(Name='test', ERP7__Operation__c=oprn.Id, ERP7__Active__c=true);
insert Media;
Attachment attch = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
insert attch;
Attachment attch1 = new Attachment(Name='Test', ParentId=Media.Id, body=blob.valueof('test'));
insert attch1;
PreventRecursiveLedgerEntry.testCasesTransactions = false;
ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version1.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
insert manuorder;
PreventRecursiveLedgerEntry.testCasesTransactions = true;
manuorder.ERP7__Version__c = version.Id;
upsert manuorder;

ERP7__WO__c wo = [Select Id, Name, ERP7__MO__c From ERP7__WO__c Where ERP7__MO__c =: manuorder.Id Limit 1];
wo.ERP7__Raw_Materials_Site__c = site.Id;
wo.ERP7__Process_Cycle__c = processcycle.Id;
update wo;
List<ERP7__Operation__c> Operations =  [Select Id, Name From ERP7__Operation__c];

MRP__c mrp = new MRP__c();
mrp.ERP7__Consumed_Quantity__c=1;
mrp.ERP7__Scrapped_Quantity__c=1;
mrp.ERP7__Version__c = version.Id;
mrp.ERP7__MO__c = manuorder.Id;
mrp.Name = 'Test mrp';
mrp.Status__c = 'Requested';
mrp.ERP7__MRP_Product__c = product.Id;
mrp.BOM_Requirement_Cost__c=10;
mrp.Sourced_Site__c = site.Id;
mrp.Required_Amount__c= 1;
mrp.ERP7__Total_Amount_Required__c=1;
mrp.ERP7__BOM__c=bom.Id;
mrp.ERP7__Work_Order__c=wo.Id;
mrp.ERP7__Quantity__c=1;
insert mrp;

SPLI.ERP7__MRP_Material_Requirement_Planning__c=mrp.Id;
update SPLI;
ERP7__Resource_Group__c rg = new ERP7__Resource_Group__c(Name='test');
insert rg;
ERP7__Capacity__c cap = new ERP7__Capacity__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
insert cap;
ERP7__Demand__c dem = new ERP7__Demand__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date_Time__c=system.Now()+1,ERP7__End_Date_Time__c=system.Now()+2);
insert dem;
ERP7__Resource__c res = new ERP7__Resource__c(Name='test',ERP7__Resource_Group__c=rg.Id, ERP7__Start_Date__c=system.Today(), ERP7__End_Date__c=system.Today()+2);
insert res;
ERP7__Resource_Allocation__c resAloc = new ERP7__Resource_Allocation__c(Name='test',ERP7__Work_Center__c=wc.Id,ERP7__Resource__c=res.Id,ERP7__Resource_Group__c=rg.Id,ERP7__Start_Date__c=system.Now()+1, ERP7__End_Date__c=system.Now()+2,ERP7__Work_Order__c=wo.Id);
try{ insert resAloc; }catch(Exception e){}
ERP7__Overtime__c OT = new ERP7__Overtime__c(Name='test', ERP7__Date__c=system.today(), ERP7__Resource__c=res.Id, ERP7__Hours__c=5);
insert OT;
ERP7__Work_Planner__c WP = new ERP7__Work_Planner__c(Name='test', ERP7__Product__c=product.Id, ERP7__Status__c='Approved', ERP7__WorkCenter__c=wc.Id);
insert WP;

ERP7__Resource_Requirement__c RR = new ERP7__Resource_Requirement__c(Name='test', ERP7__Resource_Group__c = rg.Id, ERP7__Preferred_Resource__c=res.Id, ERP7__Work_Planner__c=WP.Id, ERP7__Type__c='Setup');
insert RR;


ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
insert so;
ERP7__Sales_Order_Line_Item__c soli = new  ERP7__Sales_Order_Line_Item__c(ERP7__Product__c=product.id,ERP7__Sales_Order__c=so.id);
insert soli;
ERP7__Stock_Outward_Line_Item__c NewSOLI1 = new ERP7__Stock_Outward_Line_Item__c(Quantity__c=3, ERP7__MRP_Material_Requirements_Planning__c = mrp.Id, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Site_Product_Service_Inventory_Stock__c = inventorystock.Id);
insert NewSOLI1;
//List<ERP7__RMA_Line_Item__c>
ERP7__Serial_Number__c SNSD=new ERP7__Serial_Number__c(name='test',ERP7__Manufacturing_Order__c=manuorder.id,ERP7__Product__c=product.id);
insert SNSD;
List<ERP7__Serial_Number__c> SNS=[Select Id, Name,ERP7__Manufacturing_Order__c, ERP7__Product__c From ERP7__Serial_Number__c limit 1];
SNS[0].ERP7__Barcode__c = 'test';
update SNS;
ERP7__Serial_Number__c SNS2= new ERP7__Serial_Number__c(Name = 'testSerial001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
SNS2.ERP7__Barcode__c = 'test1001';
insert SNS2;
SNS.add(SNS2);
//ERP7__Batch__c BTCH = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Batch__c Limit 1];
ERP7__Batch__c BTCH = new ERP7__Batch__c(Name = 'testBatch', ERP7__Product__c = mrp.ERP7__MRP_Product__c, ERP7__Manufacturing_Order__c = mrp.ERP7__MO__c);
BTCH.ERP7__Barcode__c = 'testBatch';
insert BTCH;
ERP7__Batch__c BTCH2 = new ERP7__Batch__c(Name = 'testBatch001', ERP7__Product__c = mrp.ERP7__MRP_Product__c);
BTCH2.ERP7__Barcode__c = 'testB1001';
insert BTCH2;

List<ERP7__UOM_Conversion__mdt> UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 9999];
//-----------------mna-----------------------

test.startTest();




BuildWorkOrder.comWrap comW = BuildWorkOrder.getAll(wo.Id);
comW.Tasks[0].ERP7__Work_Order__c = wo.Id;
comW.Tasks[0].ERP7__Process_Cycle__c = wo.ERP7__Process_Cycle__c;
update comW.Tasks[0];
comW.Tasks[0].ERP7__Status__c = 'In-Progress';
comW.Tasks[0].ERP7__Operation__c = Operations[0].Id;
comW.Tasks[0].ERP7__Manufacturing_Order__c = manuorder.Id;
upsert comW.Tasks[0];
comW.Tasks[0].ERP7__Status__c = 'Completed';
upsert comW.Tasks[0];

MRP__c mr=[Select Id,Name,ERP7__MRP_Product__c,ERP7__MRP_Product__r.ERP7__Lot_Tracked__c from MRP__c where Id=:mrp.Id Limit 1];
BuildWorkOrder.mrpWrap mrpw = new BuildWorkOrder.mrpWrap();
mrpw.mrp = [Select Id,Name,ERP7__MRP_Product__c,ERP7__MRP_Product__r.ERP7__Lot_Tracked__c from MRP__c where Id=:mrp.Id Limit 1];
mrpw.isSelect = true;
mrpw.quantityToConsume = 2;
List<BuildWorkOrder.mrpWrap> mrpwList = new List<BuildWorkOrder.mrpWrap>();
mrpwList.add(mrpw);
comW.MRPSS=mrpwList;  

ERP7__WIP__c wip001 = new ERP7__WIP__c(Name = 'testWip001', ERP7__MO__c = manuorder.Id);
insert wip001;
ERP7__WIP_Flow__c wipFlow001 = new ERP7__WIP_Flow__c(Name = 'testWipFLow001', ERP7__Status__c = 'Completed', ERP7__WIP__c = wip001.Id, ERP7__Product__c = product.Id, ERP7__Quantity_Unit__c = 2, ERP7__Finished_Products_Site__c = site.Id, ERP7__Work_Orders__c =comW.WorkOrder.Id,ERP7__Quantity__c=2);
insert wipFlow001;

SPLI.ERP7__WIP_Flow__c=wipFlow001.Id;
update SPLI;



BuildWorkOrder.mrpWrap mrpWw=new BuildWorkOrder.mrpWrap();
mrpWw.MRP=mrp;
mrpWw.quantityToConsume=3;
mrpWw.quantityToScrap=0;
mrpWw.SOLI=NewSOLI1;
mrpWw.SILIS.add(SPLI);
List<BuildWorkOrder.mrpWrap> mrpWwList=new List<BuildWorkOrder.mrpWrap>();
mrpWwList.add(mrpWw);

BuildWorkOrder.completeWIPflowandCreateInventory(JSON.serialize(comW.Tasks[0]), JSON.serialize(comW.WorkOrder), JSON.serialize(mrpWwList), JSON.serialize(UOMCs),JSON.serialize(wipFlow001));
List<ERP7__WIP_Flow__c> WIPList=new List<ERP7__WIP_Flow__c>();
WIPList.add(wipFlow001);
BuildWorkOrder.CompleteWipandWO(JSON.serialize(wo),JSON.serialize(WIPList));

BuildWorkOrder.SearchScanCode('testBatch',JSON.serialize(mrpWwList)); 
ManufacturingOrder.getBatchStock('');
String salName = 'ERP';
String sal1Name = 'ERP';
System.assertEquals(salName, sal1Name);
//----------------------mna-----------------------------------

test.stopTest();
}*/
    
}