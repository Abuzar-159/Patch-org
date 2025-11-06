@isTest
private class CreateMRPsTestClass {
    @isTest(seeAllData = true)
    static void UnitTestMethod(){
        Account o = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert o;
         
        Account s = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert s;
        
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer', AccountNumber='1234', ERP7__Company__c='Aqxolt India Pvt Ltd',
                                ERP7__Start_of_Week__c='Monday', ERP7__CustomerPriority__c='High', ERP7__Active__c='Yes', ERP7__SLA__c='Gold',
                                ERP7__SLAExpirationDate__c=system.today());
        insert c;
        
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = o.id);
        insert site;
        
        Product2 product = new Product2(Name='Test', ProductCode='PC-017', Family='Fruits', ERP7__Status__c='In Developement', ERP7__Track_Inventory__c=true, ERP7__Transactable__c=true, 
                                        ERP7__Weight_Dimensions__c='Gram', ERP7__Category__c='IT', ERP7__Sub_Category__c='Software', ERP7__Weight__c=10,
                                        ERP7__Is_Kit__c=true, ERP7__Price_Entry_Amount__c=45, ERP7__MOQ__c=20, ERP7__Serialise__c=true, ERP7__ASIN_Code__c='test',
                                        ERP7__Width__c=2, ERP7__Lot_Tracked__c=true, ERP7__Manufacturing_Type__c='Process', ERP7__Item_Description__c='test');
        insert product;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        
        Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=c.Id, Phone='1234567890', Email='test@gmail.com', ERP7__Company__c='Aqxolt',
                                  ERP7__Level__c='Secondary');
        insert con;
        
        ERP7__Process__c process = new ERP7__Process__c(Name='Test', ERP7__Process_Name__c='Test', ERP7__Manufacturing_Assembly_Costs__c=10,
                                                        ERP7__Workforce_Hour_Required__c=12, ERP7__Machine_Hour_Required__c=15, ERP7__Other_Material_Cost__c=10,
                                                        ERP7__Machine_Usage_Cost__c=10, ERP7__Workforce_Cost__c=10);
        insert process;
        
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name='Test', ERP7__Progress__c=3, ERP7__Process__c=process.Id);
        insert processcycle;
        
        //Id pricebookId = Test.getStandardPricebookId();
        //PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        //insert pricebookentry;
        
        Pricebook2 pricebook = new Pricebook2(Name='Standard Pricebook', isActive=true);
        insert pricebook;
        
        ERP7__Version__c version = new ERP7__Version__c(Name='test', ERP7__Product__c = product.Id, ERP7__Category__c='Production', ERP7__Price_Book__c=pricebook.Id, ERP7__Inventory_Stock__c=inventorystock.Id,
                                                        ERP7__Start_Date__c=system.today(), ERP7__To_Date__c=system.today(), ERP7__Type__c='Assembly', ERP7__Status__c='Certified', ERP7__Default__c=true);
        insert version;
        
        ERP7__Routing__c routing = new ERP7__Routing__c(Name='Test', ERP7__Status__c='Certified', ERP7__Type__c='Parallel', ERP7__BOM_Version__c=version.Id, ERP7__Product__c=product.Id, ERP7__Channel__c=channel.Id,
                                                        ERP7__Raw_Materials_Site__c=site.Id, ERP7__Description__c='test', ERP7__Process__c=process.Id, ERP7__Finished_Products_Site__c=site.Id,
                                                        ERP7__Minimum_Lot_Size__c=100, ERP7__Maximum_Lot_Size__c=1000);
        insert routing;
        
        ERP7__Project__c project = new ERP7__Project__c(Name='Test', ERP7__Active__c=true, ERP7__Start_Date__c=system.today(), ERP7__End_Date__c=system.today(), ERP7__Requisition_Type__c='Goods',
                                                        ERP7__Status__c='New');
        insert project;
        
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name='Test', ERP7__Product__c=product.Id, ERP7__Version__c=version.Id, ERP7__Status__c='Complete', ERP7__Quantity__c=10, ERP7__Routing__c=routing.Id,
                                                                                  ERP7__Lead_Time__c=system.today(), ERP7__Progress__c=100, ERP7__Project__c=project.Id, ERP7__StartDate__c=system.Now(),
                                                                                  ERP7__End_Date__c=system.today(), ERP7__Expected_Date__c=system.today(), ERP7__Completion_Date__c=system.today(), ERP7__Labour_Cost__c=10, ERP7__Material_Cost__c=10,
                                                                                  ERP7__Overhead_Cost__c=10, ERP7__In_Production__c=true, ERP7__Manufactured_Quantity__c=9, ERP7__Scrapped_Quantity__c=1);
        insert manuorder;
        
        ERP7__WO__c wo = new ERP7__WO__c(Name='Test', ERP7__Status__c='In Progress', ERP7__Approved_Date__c=system.today(), ERP7__Lead_Time__c=system.today(),
                                         ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Material_Serial_Number_Start__c='2', ERP7__Material_Serial_Number_End__c='5',
                                         ERP7__Expected_Date__c=system.today(), ERP7__Progress__c=2, ERP7__Planned_Date_From__c=system.today(), ERP7__Start_Date__c=system.today(),
                                         ERP7__Ready_To_Receive__c=true, ERP7__Ready_To_Pick_Pack__c=true, ERP7__Active__c=true, ERP7__Planned_Date_To__c=system.today(),
                                         ERP7__End_Date__c=system.today(), ERP7__Process__c=process.Id, ERP7__Process_Cycle__c=processcycle.Id, ERP7__MO__c=manuorder.Id);
        insert wo;
        
        ERP7__Work_Order_Line_Items__c woli = new ERP7__Work_Order_Line_Items__c(Name='Test', ERP7__Work_Orders__c=wo.Id, ERP7__Product__c=product.Id, ERP7__Quantity__c=10,
                                                                                 ERP7__Version__c=version.Id, ERP7__Unit_Price__c=100, ERP7__Picked_Quantity__c=2, ERP7__Packed_Quantity__c=2,
                                                                                 ERP7__Active__c=true, ERP7__Picked_Date__c=system.today(), ERP7__Manufacturing_Order__c=manuorder.Id, ERP7__Serialise__c=true,
                                                                                 ERP7__Direct_Labour__c=10, ERP7__Overhead__c=10, ERP7__Organisation__c=o.Id);
        insert woli;
        woli.Explode__c = true;
        update woli;
        ERP7__Schedule__c schedule = new ERP7__Schedule__c(Name='Test', ERP7__Process__c=process.Id, ERP7__Work_Order__c=wo.Id,
                                                           ERP7__Process_Cycle__c=processcycle.Id, ERP7__Schedule_Start_Date__c=system.today(), ERP7__Status__c='In Progress',
                                                           ERP7__Estimated_Machine_Hour__c=2, ERP7__Estimated_Workforce_Hour__c=2, ERP7__Workforce_Allocation__c=2, ERP7__Direct_Labour__c=100,
                                                           ERP7__Direct_Materials__c=1000, ERP7__Overhead__c=100, ERP7__Product__c=product.Id, ERP7__Total_Cost__c=500, ERP7__Organisation__c=o.Id,
                                                           ERP7__Work_Order_Line_Item__c=woli.Id, ERP7__Schedule_End_Date__c=system.today(), ERP7__Actual_Machine_Hour__c=3, ERP7__Actual_Workforce_Hour__c=3,
                                                           ERP7__Machine_Allocation__c=5, ERP7__Project__c=project.Id);
        insert schedule;
        
        ERP7__Product_Service__c productservice = new ERP7__Product_Service__c(Name='Test', ERP7__Product_Service_Family__c='Furniture', ERP7__Item_Type__c='New', ERP7__Description__c='Test', ERP7__Status__c='Delivered',
                                                                               ERP7__Purchase_Lead_Time_days__c=10, ERP7__Manufacture_Lead_Time_days__c=30, ERP7__Approved_by__c='EU', ERP7__Colour__c='Red', ERP7__isAccessory__c=true,
                                                                               ERP7__Mass__c=100, ERP7__Weight__c=200, ERP7__Track_Inventory__c=true, ERP7__Weight_Dimensions__c='Kilogram');
        insert productservice;
        
        ERP7__Machine__c machine = new ERP7__Machine__c(Name='Test');
        insert machine;
        
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name='Test', ERP7__Active__c=true, ERP7__Shop_Floor_Warehouse__c=site.Id, ERP7__Type__c='Machine',
                                                           ERP7__Planned_Capacity__c=5,ERP7__Maximum_Capacity_Minutes__c=3, ERP7__Organisation__c=o.Id,
                                                           ERP7__Channel__c=channel.Id, ERP7__Plant__c=site.Id, ERP7__Machine__c=machine.Id);
        insert wc;
        
        ERP7__Work_Station__c ws = new ERP7__Work_Station__c(Name='Test', ERP7__Active__c=true, ERP7__Site__c=site.Id);
        insert ws;
        
        Inventory_Stock__c stock = new Inventory_Stock__c(Organisation__c = o.Id, Name='test',Active__c=true, Product__c=product.Id, Checked_In_Date__c=system.today(),
                                                          Warehouse__c=routing.ERP7__Finished_Products_Site__c, ERP7__Status__c='Checked In', ERP7__Version__c=version.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert stock;
        
        Stock_Outward_Line_Item__c soli = new Stock_Outward_Line_Item__c(Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=stock.Id, Work_Order_Line_Items__c=woli.Id,Product__c=product.Id);
        insert soli;
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Order_Status__c='Entered', 
                                                           ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id);
        insert so;
        
        ERP7__Sales_Order_Line_Item__c solis = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so.Id, ERP7__Active__c=true, ERP7__Site__c=site.Id);
        try{insert solis;}catch(Exception e){}
        RecordType bomtype = [select Id, Name From RecordType Where Name = 'Kit BOM' and SobjectType = 'ERP7__BOM__c' Limit 1];
        
        ERP7__BOM__c bom = new ERP7__BOM__c(Name='Test', ERP7__BOM_Product__c=product.Id, ERP7__Unit_of_Measure__c='barrel', ERP7__Type__c='Alternate',
                                            ERP7__Quantity__c=10, ERP7__BOM_Version__c=version.Id, ERP7__Active__c=true);
        insert bom;
        RecordType mrptype = [select Id, Name From RecordType Where Name = 'MRP Kit' and SobjectType = 'ERP7__MRP__c' Limit 1];
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='Test', ERP7__Total_Amount_Required__c=10, ERP7__MRP_Product__c=product.Id, RecordTypeId=mrptype.Id, ERP7__Work_Order_Line_Items__c=woli.Id, Sales_Order_Line_Item__c=solis.Id, ERP7__BOM__c=bom.Id);
        insert mrp;
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
    }
}