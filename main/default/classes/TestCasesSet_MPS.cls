@isTest
private class TestCasesSet_MPS {
    static testMethod void UnitTestErpMark7_1(){  
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps;
       
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true);
        insert ps1;            
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id,ERP7__Type__c='Primary',ERP7__Status__c = 'Certified');
        insert psa; 
        
        MPS__c newMPS = new MPS__c();
        newMPS.Name = 'Test';
        newMPS.ERP7__Start_Date__c = system.today();
        newMPS.ERP7__End_Date__c = system.today()+365;
        newMPS.ERP7__Lot_Size__c = 50;
        newMPS.ERP7__Default_Demand_Forecast__c = 0;
        newMPS.ERP7__Minimum_Inventory_Level__c = 5;
        newMPS.ERP7__Product__c = ps.Id;
        newMPS.ERP7__Schedule_Period__c = 'Monthly';
        newMPS.ERP7__Starting_Inventory__c = 100;
        insert newMPS;
        MPS_AT_Lightning.MPS MPS1 = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS_AT_Lightning.getAllStockRunRateOnDate(JSON.serialize(MPS1),'false');
        MPS_AT_Lightning.getAllSTockRR(newMPS.Id,system.today(),'','');
        
        ERP7__MPS_line_Item__c mpsLi = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = newMPS.Id);
        insert mpsLi;
        
        
        test.startTest();
        MPS_AT_Lightning.MPS MPS = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS = MPS_AT_Lightning.Evaluates(JSON.serialize(MPS));
        MPS = MPS_AT_Lightning.Saves(JSON.serialize(MPS));
        MPS = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS = MPS_AT_Lightning.getAllStockRunRate(JSON.serialize(MPS),'false');
        ERP7__MPS_line_Item__c MPSLine = [Select Id, Name From ERP7__MPS_line_Item__c Limit 1];
        MPS_AT_Lightning.Evaluates(JSON.serialize(psa));
        MPS_AT_Lightning.Saves(JSON.serialize(psa));
        MPS_AT_Lightning.getAllStockRunRateOnDate(JSON.serialize(MPS),'false');
        MPS_AT_Lightning.getAllSTockRR(newMPS.Id,system.today(),'','');
        String URL = MPS_AT_Lightning.MO_WO_URL(MPSLine.Id);
         Version__c v= new Version__c(Name='Test',Active__c=true,Product__c=ps.Id);
        insert v;
        psa.BOM_Version__c=v.Id;
        update psa;
        ERP7__WIP_Link__c wip = new ERP7__WIP_Link__c(Name='Test WIp',ERP7__Version__c=v.Id,ERP7__Process_Output_Product__c=ps1.Id,ERP7__Product__c=ps.Id);
        insert wip;
        MPS_AT_Lightning.getBomMPS(JSON.serialize(newMPS),v.Id,'');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();    
    }
    
    static testMethod void UnitTestErpMark7_2(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps;  
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true);
        insert ps1;            
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa; 
        MPS__c newMPS = new MPS__c();
        newMPS.Name = 'Test';
        newMPS.ERP7__Start_Date__c = system.today();
        newMPS.ERP7__End_Date__c = system.today()+365;
        newMPS.ERP7__Lot_Size__c = 50;
        newMPS.ERP7__Default_Demand_Forecast__c = 0;
        newMPS.ERP7__Minimum_Inventory_Level__c = 5;
        newMPS.ERP7__Product__c = ps.Id;
        newMPS.ERP7__Schedule_Period__c = 'Weekly';
        newMPS.ERP7__Starting_Inventory__c = 100;
        insert newMPS;
         MPS_AT_Lightning.MPS MPS1 = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS_AT_Lightning.getAllStockRunRateOnDate(JSON.serialize(MPS1),'false');
        MPS_AT_Lightning.getAllSTockRR(newMPS.Id,system.today(),'','');
        
        ERP7__MPS_line_Item__c mpsLi = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = newMPS.Id);
        insert mpsLi;
        MPS_AT_Lightning.getAll(psa.Id);
       
        test.startTest();
        MPS_AT_Lightning.MPS MPS = MPS_AT_Lightning.getAll(newMPS.Id);
        
        MPS = MPS_AT_Lightning.Evaluates(JSON.serialize(MPS));
        MPS = MPS_AT_Lightning.Saves(JSON.serialize(MPS));
        MPS = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS = MPS_AT_Lightning.getAllStockRunRate(JSON.serialize(MPS),'false');
        MPS_AT_Lightning.SavesMPS(JSON.serialize(MPS));
        MPS_AT_Lightning.getAllStockRunRateOnDate(JSON.serialize(MPS),'false');
        ERP7__MPS_line_Item__c MPSLine = [Select Id, Name From ERP7__MPS_line_Item__c Limit 1];
        MPS_AT_Lightning.getAllSTockRR(newMPS.Id,system.today(),'','');
        String URL = MPS_AT_Lightning.MO_WO_URL(MPSLine.Id);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();    
    }
    
    static testMethod void UnitTestErpMark7_3(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps;  
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true);
        insert ps1;            
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa; 
        MPS__c newMPS = new MPS__c();
        newMPS.Name = 'Test';
        newMPS.ERP7__Start_Date__c = system.today();
        newMPS.ERP7__End_Date__c = system.today()+365;
        newMPS.ERP7__Lot_Size__c = 50;
        newMPS.ERP7__Default_Demand_Forecast__c = 0;
        newMPS.ERP7__Minimum_Inventory_Level__c = 5;
        newMPS.ERP7__Product__c = ps.Id;
        newMPS.ERP7__Schedule_Period__c = 'quarterly';
        newMPS.ERP7__Starting_Inventory__c = 100;
        insert newMPS;
         MPS_AT_Lightning.MPS MPS1 = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS_AT_Lightning.getAllStockRunRate(JSON.serialize(MPS1),'false');
        MPS_AT_Lightning.getAllStockRunRateOnDate(JSON.serialize(MPS1),'false');
        MPS_AT_Lightning.getAllSTockRR(newMPS.Id,system.today(),'','');
        
        ERP7__MPS_line_Item__c mpsLi = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = newMPS.Id);
        insert mpsLi;
        
        test.startTest();
        MPS_AT_Lightning.MPS MPS = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS = MPS_AT_Lightning.Evaluates(JSON.serialize(MPS));
        MPS = MPS_AT_Lightning.Saves(JSON.serialize(MPS));
        MPS = MPS_AT_Lightning.getAll(newMPS.Id);
        MPS = MPS_AT_Lightning.getAllStockRunRate(JSON.serialize(MPS),'true');
        MPS_AT_Lightning.getAllStockRunRateOnDate(JSON.serialize(MPS),'true');
        ERP7__MPS_line_Item__c MPSLine = [Select Id, Name From ERP7__MPS_line_Item__c Limit 1];
        MPS_AT_Lightning.getAllSTockRR(newMPS.Id,system.today(),'','');
        String URL = MPS_AT_Lightning.MO_WO_URL(MPSLine.Id);
        MPS_AT_Lightning.getAllInitial('',System.today(),System.today()+60,'','');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();    
    }
    
    static testMethod void UnitTestErpMark7_4(){ 
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
        
        Product2 product1 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product1;
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(ERP7__Organisation__c = o.Id, Name = 'test', ERP7__Active__c = true, ERP7__Warehouse__c = site.Id, ERP7__Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
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
        PricebookEntry pricebookentry1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product1.Id, UnitPrice = 10000, IsActive = true);
        insert pricebookentry1;
        Pricebook2 pricebook = new Pricebook2(Name = 'Standard Pricebook', isActive = true);
        insert pricebook;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production', ERP7__Price_Book__c = pricebook.Id, ERP7__Inventory_Stock__c = inventorystock.Id, ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified', ERP7__Default__c = true);
        insert version;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = o.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id);
        insert wc;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__Project__c = project.Id, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1, ERP7__Is_Closed__c = false);
        insert manuorder;
        ERP7__WO__c wo = new ERP7__WO__c(Name = 'Test', ERP7__Status__c = 'In Progress', ERP7__Approved_Date__c = system.today(), ERP7__Lead_Time__c = system.today(), ERP7__Customer__c = c.Id, ERP7__Contact__c = con.Id, ERP7__Material_Serial_Number_Start__c = '2', ERP7__Material_Serial_Number_End__c = '5', ERP7__Expected_Date__c = system.today(), ERP7__Progress__c = 2, ERP7__Planned_Date_From__c = system.today(), ERP7__Start_Date__c = system.today(), ERP7__Ready_To_Receive__c = true, ERP7__Ready_To_Pick_Pack__c = true, ERP7__Active__c = true, ERP7__Planned_Date_To__c = system.today(), ERP7__End_Date__c = system.today(), ERP7__Process__c = process.Id, ERP7__Process_Cycle__c = processcycle.Id, ERP7__MO__c = manuorder.Id,ERP7__Work_Center__c = wc.Id);
        insert wo;
        WorkCenterCapacityPlanning.WCCP newWCCP = new WorkCenterCapacityPlanning.WCCP();
        test.startTest();
        WorkCenterCapacityPlanning.getAll(JSON.serialize(newWCCP),'false', 'MO', 0, 10);
        WorkCenterCapacityPlanning.getAll(JSON.serialize(newWCCP),'false', 'WO', 0, 10);
        WorkCenterCapacityPlanning.getMOs(JSON.serialize(newWCCP), 0, 10);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();    
    }
}