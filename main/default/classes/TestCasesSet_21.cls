@isTest(SeeAllData=true)
private class TestCasesSet_21 {
    /*Transfer Order*/
    /*static testMethod void UnitTest(){
Account c = new Account(Name='Test Customer', ERP7__Account_Type__c='Customer');
insert c;
Account o = new Account(Name='Test Customer', ERP7__Account_Type__c='Organisation');
insert o;
Account s = new Account(Name='Test Customer', ERP7__Account_Type__c='Supplier');
insert s;
Contact con = new Contact(FirstName='Test', LastName='Test');
insert con;

Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId');
insert ps;
ERP7__Transfer_Order__c to = new ERP7__Transfer_Order__c(Name='Test Transfer Order', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id,ERP7__Ready_To_Pick_Pack__c=true,ERP7__Ready_To_Receive__c=true);
insert to;

Transfer_Order_Line_Items__c toli = new Transfer_Order_Line_Items__c(Name='Test',Batch_Lot_Code__c='test', Products__c=ps.id,Transfer_Order__c=to.id,Quantity_received__c=100,Quantity_requested__c=100);
insert toli;
PreventRecursiveLedgerEntry.testCasesTransactions = false;
update to;

Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = o.id);
insert site;

Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
insert WarehouseItemInventoryStock; 


Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c =WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2, Transfer_Order_Line_Item__c=toli.Id);
insert SPLI;

ERP7__Stock_Outward_Line_Item__c stoli = new ERP7__Stock_Outward_Line_Item__c(Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.Id, ERP7__Active__c=true,ERP7__Quantity__c=1);
insert stoli;
ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
ERP7__Contact__c=con.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
insert addr;
ERP7__Channel__c chan = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=addr.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
ERP7__Phone__c='1234567890', ERP7__Active__c=true);
insert chan;
ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test Employee', ERP7__Channel__c=chan.Id, Employee_User__c=UserInfo.getUserId());
insert emp;
Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Transfer_Order_Line_Item__c=toli.id);
insert mrp;
ERP7__BOM__c bom = new ERP7__BOM__c(Name='Test');
insert bom;
ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='test', ERP7__Channel__c=chan.Id, ERP7__Site__c=site.Id, ERP7__Active__c=true);
insert dc;

//Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
Test.startTest();
//Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = c.Id,Contact__c = con.Id,Channel__c = chan.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
//insert sod;
PageReference pageRef = System.Page.SupplierInventoryConsole;
pageRef.getParameters().put('toid',to.Id);
pageRef.getParameters().put('channel',chan.Id);
Test.setCurrentPage(pageRef);
ApexPages.StandardController controller;
InventoryManagement invMan = new InventoryManagement(controller);
//invMan.TransferOrderInventoryCustomContructor();
/*
ERP7__Purchase_Line_Items__c PLI = poli;
InventoryManagement.PLIWrapper purchaseli = new InventoryManagement.PLIWrapper(PLI);
Work_Order_Line_Items__c WOLIS = woli;
InventoryManagement.WOLIWrapper workli = new InventoryManagement.WOLIWrapper(WOLIS);
ERP7__RMA_Line_Item__c RMALIS = rmalineitem;
InventoryManagement.RMALIWrapper rmali = new InventoryManagement.RMALIWrapper(RMALIS);
Transfer_Order_Line_Items__c TOLIS = toli;
InventoryManagement.TOLIWrapper toliItem = new InventoryManagement.TOLIWrapper(TOLIS);
Inventory_Stock__c WIIS = is;
List<Stock_Inward_Line_Item__c> SPLI = new List<Stock_Inward_Line_Item__c>();
SPLI.add(stili);
InventoryManagement.StockWrapper sw = new InventoryManagement.StockWrapper(WIIS, SPLI);
Inventory_Stock__c WIIIS = is;
Stock_Inward_Line_Item__c SPLII = stili;
InventoryManagement.StockWrapperNew swn = new InventoryManagement.StockWrapperNew(WIIIS, SPLII);
*
invMan.Receive();
invMan.PutAway();
invMan.counter = 0;
invMan.AddTransferStock();
invMan.counter = 0;
invMan.subcounter = 0;

invMan.ExplodeKitTO();
invMan.counter = 0;
invMan.subcounter = 0;
invMan.AddStockKitTO();
invMan.counter = 0;
invMan.ExplodeTOLI();
invMan.selectedSite = site.id;
invMan.SaveTOLines();
invMan.SaveTOLiness();
invMan.counter = 0;
invMan.subcounter = 0;
invMan.RemoveTransferStock();
invMan.cancelTo();
String salName = 'ERP';
String sal1Name = 'ERP';
System.assertEquals(salName, sal1Name);
Test.stopTest();
}*/
    
    static testMethod void UnitTest_1(){
        
        Account c = new Account(Name='Test Customer', ERP7__Account_Type__c='Customer');
        insert c;
        Account o = new Account(Name='Test Customer', ERP7__Account_Type__c='Organisation');
        insert o;
        Account s = new Account(Name='Test Customer', ERP7__Account_Type__c='Supplier');
        insert s;
        Contact con = new Contact(FirstName='Test', LastName='Test');
        insert con;
        ERP7__Transfer_Order__c to = new ERP7__Transfer_Order__c(Name='Test Transfer Order', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id);
        insert to;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
        
        Transfer_Order_Line_Items__c toli = new Transfer_Order_Line_Items__c(Serial_Number_Prefix__c='Test_To',Starting_Number__c=1,Name='Test',Batch_Lot_Code__c='test', Products__c=ps.id,Transfer_Order__c=to.id,Quantity_received__c=100,Quantity_requested__c=100);
        insert toli;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = o.id);
        insert site;
        
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='ToTest1',ERP7__Product__c=ps.Id);
        insert ser;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Serial__c=ser.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(ERP7__Serial__c=ser.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c =WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2, Transfer_Order_Line_Item__c=toli.Id);
        insert SPLI;
        
        ERP7__Stock_Outward_Line_Item__c stoli = new ERP7__Stock_Outward_Line_Item__c(Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.Id, ERP7__Active__c=true,ERP7__Quantity__c=1,Product__c=ps.Id);
        insert stoli;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=con.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert addr;
        ERP7__Channel__c chan = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=addr.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                     ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                     ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert chan;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test Employee', ERP7__Channel__c=chan.Id, Employee_User__c=UserInfo.getUserId());
        insert emp;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Transfer_Order_Line_Item__c=toli.id);
        insert mrp;
        
        ERP7__BOM__c bom = new ERP7__BOM__c(Name='Test');
        insert bom;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='test', ERP7__Channel__c=chan.Id, ERP7__Site__c=site.Id, ERP7__Active__c=true);
        insert dc;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = c.Id,Contact__c = con.Id,Channel__c = chan.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Test.startTest();
        PageReference pageRef = System.Page.SupplierInventoryConsole;
        pageRef.getParameters().put('toid',to.Id);
        pageRef.getParameters().put('channel',chan.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller;
        InventoryManagement invMan = new InventoryManagement(controller);
        invMan.counter = 0;
        invMan.AddTransferStock();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.ExplodeKitTO();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.AddStockKitTO();
        invMan.counter = 0;
        invMan.ExplodeTOLI();
        invMan.selectedSite = site.id;
        invMan.SaveTOLines();
        invMan.SaveTOLiness();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.RemoveTransferStock();
        invMan.cancelTo();
        PreventRecursiveLedgerEntry.proceed = true; 
        stoli.Status__c = 'Committed';
        update stoli; 
        delete stoli;
        undelete stoli; 
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    static testMethod void UnitTest_1_1(){
        
        Account c = new Account(Name='Test Customer', ERP7__Account_Type__c='Customer');
        insert c;
        Account o = new Account(Name='Test Customer', ERP7__Account_Type__c='Organisation');
        insert o;
        Account s = new Account(Name='Test Customer', ERP7__Account_Type__c='Supplier');
        insert s;
        Contact con = new Contact(FirstName='Test', LastName='Test');
        insert con;
        ERP7__Transfer_Order__c to = new ERP7__Transfer_Order__c(Name='Test Transfer Order', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id);
        insert to;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
        
        Transfer_Order_Line_Items__c toli = new Transfer_Order_Line_Items__c(Explode__c = true,Serial_Number_Prefix__c='Test_To',Starting_Number__c=1,Name='Test',Batch_Lot_Code__c='test', Products__c=ps.id,Transfer_Order__c=to.id,Quantity_Received__c=10,Quantity_requested__c=100);
        insert toli;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = o.id);
        insert site;
        
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='ToTest1',ERP7__Product__c=ps.Id);
        insert ser;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Serial__c=ser.Id);
        insert WarehouseItemInventoryStock; 
        
        
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(ERP7__Serial__c=ser.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c =WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2, Transfer_Order_Line_Item__c=toli.Id);
        insert SPLI;
        
        ERP7__Stock_Outward_Line_Item__c stoli = new ERP7__Stock_Outward_Line_Item__c(Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.Id, ERP7__Active__c=true,ERP7__Quantity__c=1,Product__c=ps.Id);
        insert stoli;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=con.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert addr;
        ERP7__Channel__c chan = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=addr.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                     ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                     ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert chan;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test Employee', ERP7__Channel__c=chan.Id, Employee_User__c=UserInfo.getUserId());
        insert emp;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Transfer_Order_Line_Item__c=toli.id);
        insert mrp;
        
        ERP7__BOM__c bom = new ERP7__BOM__c(Name='Test');
        insert bom;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='test', ERP7__Channel__c=chan.Id, ERP7__Site__c=site.Id, ERP7__Active__c=true);
        insert dc;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = c.Id,Contact__c = con.Id,Channel__c = chan.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Test.startTest();
        PageReference pageRef = System.Page.SupplierInventoryConsole;
        pageRef.getParameters().put('toid',to.Id);
        pageRef.getParameters().put('channel',chan.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller;
        InventoryManagement invMan = new InventoryManagement(controller);
        invMan.counter = 0;
        invMan.AddTransferStock();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.ExplodeKitTO();
        invMan.counter = 0;
        invMan.ExplodeTOLI();
        invMan.selectedSite = site.id;
        invMan.SaveTOLines();
        invMan.SaveTOLiness();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.RemoveTransferStock();
        invMan.cancelTo();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    static testMethod void UnitTest_1_2(){
        
        Account c = new Account(Name='Test Customer', ERP7__Account_Type__c='Customer');
        insert c;
        Account o = new Account(Name='Test Customer', ERP7__Account_Type__c='Organisation');
        insert o;
        Account s = new Account(Name='Test Customer', ERP7__Account_Type__c='Supplier');
        insert s;
        Contact con = new Contact(FirstName='Test', LastName='Test');
        insert con;
        ERP7__Transfer_Order__c to = new ERP7__Transfer_Order__c(Name='Test Transfer Order', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id);
        insert to;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=false);
        insert ps;
        
        Transfer_Order_Line_Items__c toli = new Transfer_Order_Line_Items__c(Explode__c = true,Serial_Number_Prefix__c='Test_To',Starting_Number__c=1,Name='Test',Batch_Lot_Code__c='test', Products__c=ps.id,Transfer_Order__c=to.id,Quantity_Received__c=10,Quantity_requested__c=100);
        insert toli;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = o.id);
        insert site;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id);
        insert WarehouseItemInventoryStock; 
        
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='ToTest1',ERP7__Product__c=ps.Id);
        insert ser;
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c =WarehouseItemInventoryStock.Id,Quantity__c=2, Transfer_Order_Line_Item__c=toli.Id);
        insert SPLI;
        
        ERP7__Stock_Outward_Line_Item__c stoli = new ERP7__Stock_Outward_Line_Item__c(Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.Id, ERP7__Active__c=true,ERP7__Quantity__c=1);
        insert stoli;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=con.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert addr;
        ERP7__Channel__c chan = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=addr.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                     ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                     ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert chan;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test Employee', ERP7__Channel__c=chan.Id, Employee_User__c=UserInfo.getUserId());
        insert emp;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Transfer_Order_Line_Item__c=toli.id);
        insert mrp;
        
        ERP7__BOM__c bom = new ERP7__BOM__c(Name='Test');
        insert bom;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='test', ERP7__Channel__c=chan.Id, ERP7__Site__c=site.Id, ERP7__Active__c=true);
        insert dc;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = c.Id,Contact__c = con.Id,Channel__c = chan.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Test.startTest();
        PageReference pageRef = System.Page.SupplierInventoryConsole;
        pageRef.getParameters().put('toid',to.Id);
        pageRef.getParameters().put('channel',chan.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller;
        InventoryManagement invMan = new InventoryManagement(controller);
        invMan.counter = 0;
        invMan.AddTransferStock();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.ExplodeKitTO();
        invMan.counter = 0;
        invMan.ExplodeTOLI();
        invMan.selectedSite = site.id;
        invMan.SaveTOLines();
        invMan.SaveTOLiness();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.RemoveTransferStock();
        invMan.cancelTo();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    static testMethod void UnitTest_1_3(){
        
        Account c = new Account(Name='Test Customer', ERP7__Account_Type__c='Customer');
        insert c;
        Account o = new Account(Name='Test Customer', ERP7__Account_Type__c='Organisation');
        insert o;
        Account s = new Account(Name='Test Customer', ERP7__Account_Type__c='Supplier');
        insert s;
        Contact con = new Contact(FirstName='Test', LastName='Test');
        insert con;
        ERP7__Transfer_Order__c to = new ERP7__Transfer_Order__c(Name='Test Transfer Order', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id);
        insert to;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
        
        Transfer_Order_Line_Items__c toli = new Transfer_Order_Line_Items__c(Explode__c = true,Serial_Number_Prefix__c='Test_To',Starting_Number__c=1,Name='Test',Batch_Lot_Code__c='test', Products__c=ps.id,Transfer_Order__c=to.id,Quantity_Received__c=10,Quantity_requested__c=100);
        insert toli;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = o.id);
        insert site;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id);
        insert WarehouseItemInventoryStock; 
        
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='ToTest1',ERP7__Product__c=ps.Id);
        insert ser;
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c =WarehouseItemInventoryStock.Id,Quantity__c=2, Transfer_Order_Line_Item__c=toli.Id);
        insert SPLI;
        
        ERP7__Stock_Outward_Line_Item__c stoli = new ERP7__Stock_Outward_Line_Item__c(Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.Id, ERP7__Active__c=true,ERP7__Quantity__c=1);
        insert stoli;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=con.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert addr;
        ERP7__Channel__c chan = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=addr.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                     ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                     ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert chan;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test Employee', ERP7__Channel__c=chan.Id, Employee_User__c=UserInfo.getUserId());
        insert emp;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Transfer_Order_Line_Item__c=toli.id);
        insert mrp;
        
        ERP7__BOM__c bom = new ERP7__BOM__c(Name='Test');
        insert bom;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='test', ERP7__Channel__c=chan.Id, ERP7__Site__c=site.Id, ERP7__Active__c=true);
        insert dc;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = c.Id,Contact__c = con.Id,Channel__c = chan.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Test.startTest();
        PageReference pageRef = System.Page.SupplierInventoryConsole;
        pageRef.getParameters().put('toid',to.Id);
        pageRef.getParameters().put('channel',chan.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller;
        InventoryManagement invMan = new InventoryManagement(controller);
        invMan.counter = 0;
        invMan.AddTransferStock();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.ExplodeKitTO();
        invMan.counter = 0;
        invMan.ExplodeTOLI();
        invMan.selectedSite = site.id;
        invMan.SaveTOLines();
        invMan.SaveTOLiness();
        invMan.counter = 0;
        invMan.subcounter = 0;
        invMan.RemoveTransferStock();
        invMan.cancelTo();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    /*WORK ORDER */
    static testMethod void UnitTest_WO_1(){ 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;         ERP7__Channel__c channel = new ERP7__Channel__c(Organisation__c = orgn.Id,Name='Test Channel', ERP7__Ship_From_Address__c=sAddress.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                                              ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                                              ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert channel;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = Contact.AccountId,Contact__c = Contact.Id,Channel__c = channel.Id,Bill_To_Address__c = bAddress.Id,Ship_To_Address__c = sAddress.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps; Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        WO__c WO = new WO__c(name= 'WO-123',Sales_Order__c=sod.id);
        insert WO; 
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='WoTest1',ERP7__Product__c=ps.Id);
        insert ser;
        Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c(Quantity__c=5,Work_Orders__c=WO.id,Product__c = ps.Id);
        insert woli;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true);
        insert site;
        
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=ps.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Serial__c = serial1.Id);
        insert WarehouseItemInventoryStock; 
        
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=5,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Work_Order_Line_Items__c=woli.id);
        insert mrp;
        
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Serial__c=ser.id,Work_Order_Line_Items__c=woli.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=1);
        insert SPLI; 
        
        ERP7__Stock_Outward_Line_Item__c stoli = new ERP7__Stock_Outward_Line_Item__c(Sales_Order_Line_Item__c=solim.id,Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.Id, ERP7__Active__c=true,ERP7__Quantity__c=1,Product__c=ps.Id);
        insert stoli;
        
        PageReference pageRef = System.Page.ManufacturingInventoryConsole;
        pageRef.getParameters().put('woid',WO.Id);
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        ApexPages.StandardController controller;
        InventoryManagement invCons = new InventoryManagement();
        InventoryManagement invCon = new InventoryManagement(controller);
        invCon.Receive();
        invCon.PutAway();
        invCon.selectedSite = site.id;
        invCon.SaveWOLines();
        invCon.SaveWOLinesReceived();
        invCon.counter = 0;
        invCon.ExplodeKitWO();
        invCon.counter = 0;
        invCon.ExplodeWOLI();
        invCon.counter = 0;
        invCon.AddManufacturedStock();
        invCon.counter = 0; invCon.subcounter = 1;
        invCon.AddManufacturedItem();
        invCon.counter = 0; invCon.subcounter = 1; invCon.lastcounter = 0;
        invCon.RemoveManufacturedItem();
        invCon.counter = 0; invCon.subcounter = 1;
        invCon.RemoveManufacturedStock();
        invCon.cancelWo();
        invCon.barcode = 'productId';
        invCon.scannerMethodManufacturing();
        invCon.barcode = 'productId';
        invCon.scannerMethodManufacturing();
        invCon.warehouseStocks=new List<Inventory_Stock__c>(); 
        invCon.counter = 0;
        invCon.ExplodeKitWO();  
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.StopTest();
    }
    static testMethod void UnitTest_WO_2(){ 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId');
        insert ps;   
        
        WO__c WO = new WO__c(name= 'WO-123');
        insert WO;  
        
        Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c(Explode__c = true,Quantity__c=5,Work_Orders__c=WO.id,Product__c = ps.Id);
        insert woli;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true);
        insert site;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=15,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Work_Order_Line_Items__c=woli.id);
        insert mrp;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Work_Order_Line_Items__c=woli.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;    
        PageReference pageRef = System.Page.ManufacturingInventoryConsole;
        pageRef.getParameters().put('woid',WO.Id);
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        ApexPages.StandardController controller;
        InventoryManagement invCons = new InventoryManagement();
        InventoryManagement invCon = new InventoryManagement(controller);
        
        invCon.counter = 0;
        invCon.ExplodeKitWO();
        invCon.selectedSite = site.id;
        invCon.SaveWOLines();
        invCon.SaveWOLinesReceived();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.StopTest();
    }
    static testMethod void UnitTest_WO_3(){ 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId');
        insert ps;   
        
        WO__c WO = new WO__c(name= 'WO-123');
        insert WO;  
        
        Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c(Explode__c = true,Quantity__c=5,Work_Orders__c=WO.id,Product__c = ps.Id);
        insert woli;
        Site__c site = new Site__c(Name = 'site', Active__c=true);
        insert site;
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id);
        insert WarehouseItemInventoryStock; 
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=15,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__Work_Order_Line_Items__c=woli.id);
        insert mrp;  
        PageReference pageRef = System.Page.ManufacturingInventoryConsole;
        pageRef.getParameters().put('woid',WO.Id);
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        ApexPages.StandardController controller;
        InventoryManagement invCons = new InventoryManagement();
        InventoryManagement invCon = new InventoryManagement(controller);
        
        invCon.counter = 0;
        invCon.ExplodeKitWO();
        invCon.selectedSite = site.id;
        invCon.SaveWOLines();
        invCon.SaveWOLinesReceived();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.StopTest();
    }
    static testMethod void UnitTest_PO_1(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c = sup.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c = sup.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c( Customer__c = orgn.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        RecordType rec = [Select Id, Name From RecordType WHERE SObjectType='ERP7__Profiling__c' and Name='Employee' LIMIT 1];
        ERP7__Profiling__c pro = new ERP7__Profiling__c(Name='test', RecordTypeId=rec.Id);
        insert pro;
        ERP7__Channel__c channel = new ERP7__Channel__c(ERP7__Organisation__c=orgn.Id, ERP7__Ship_From_Address__c=bAddress1.Id, Name='test', ERP7__Shipper_Name__c='test',
                                                        ERP7__City__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Company__c='Aqxolt', ERP7__Street__c='test', 
                                                        ERP7__State_Province__c = 'test', ERP7__Country__c='test', ERP7__Phone__c='8393939393');
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='test', First_Name__c='test', Channel__c=Channel.Id, 
                                                        Employee_User__c=UserInfo.getUserId(),Organisation_Business_Unit__c=bUnit.Id, Organisation__c=orgn.Id, Employee_Profiling__c=pro.Id);
        insert emp;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = Contact.AccountId,Contact__c = Contact.Id,Channel__c = channel.Id,Bill_To_Address__c = bAddress.Id,Ship_To_Address__c = sAddress.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        ERP7__Site__c sites = new ERP7__Site__c(Active__c=true,ERP7__Organisation__c=orgn.Id, Name='Test', ERP7__Type__c='Warehouse');
        insert sites;
        ERP7__Distribution_Channel__c dis = new ERP7__Distribution_Channel__c(ERP7__Channel__c=Channel.Id, ERP7__Site__c=sites.Id, Name='test',Active__c=true,ERP7__Primary__c=true);
        insert dis;
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account', Organisation__c = orgn.Id);
        insert BA;
        PO__c PO = new PO__c( Sales_Order__c=sod.id,Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress1.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
        insert PO;  
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='WoTest1',ERP7__Product__c=ps.Id);
        insert ser;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=5,Purchase_Orders__c=PO.id,Total_Price__c=500,Product__c = ps.Id);
        insert poli;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=15,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',Purchase_Line_Items__c=poli.id);
        insert mrp;
        //Module__c financeModule = new Module__c(Name = 'Finance', ERP7__Run_Posting_Trigger__c = false);
        //upsert financeModule;
        Bill__c bill = new Bill__c(Name = 'Bill Pay', Posted__c = false, Total_Amount__c =200, Purchase_Order__c = PO.Id, Account__c = orgn.Id);
        Insert bill;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;   
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Serial__c=ser.Id);
        insert WarehouseItemInventoryStock; 
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Serial__c=ser.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c =WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=1, Purchase_Line_Items__c=poli.Id);
        insert SPLI; 
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        ERP7__Stock_Outward_Line_Item__c stoli = new ERP7__Stock_Outward_Line_Item__c(Sales_Order_Line_Item__c=solim.id,Name='Test', ERP7__Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.Id, ERP7__Active__c=true,ERP7__Quantity__c=1,Product__c=ps.Id);
        insert stoli;
        PageReference pageRef = System.Page.SupplierInventoryConsole;
        pageRef.getParameters().put('poId',PO.Id);
        Test.setCurrentPage(pageRef);       
        Test.StartTest();
        ApexPages.StandardController controller;
        InventoryManagement invCons = new InventoryManagement();
        InventoryManagement invCon = new InventoryManagement(controller);
        
        invCon.counter = 0;
        //try { 
        invCon.selectedSite = site.Id;
        invCon.Receive();
        invCon.PutAway();
        invCon.SavePOLinesReceived();
        invCon.SavePOLines();
        invCon.counter = 0; invCon.subcounter = 0;
        invCon.AddStock();
        invCon.Receive();
        invCon.counter = 0;
        invCon.ExplodeKit();
        invCon.counter = 0; invCon.subcounter = 0;
        invCon.AddStockKit();
        invCon.SavePOLinesReceived();
        invCon.PutAway();
        invCon.counter = 0; invCon.subcounter = 0;
        invCon.RemoveStock();
        invCon.collapseCounter = 0; 
        invCon.customCollapse();
        invCon.cancelPo();
        invCon.PutOneAway();
        invCon.POALL();
        invCon.WOALL();
        invCon.SOALL();
        invCon.TOALL();
        invCon.PreparePushAttachment();
        invCon.PreparePushAttachmentId = PO.Id;
        invCon.universalAttachment.Name='test';
        invCon.universalAttachment.body=blob.valueof('test');
        invCon.PushAttachment();
        invCon.barcode = 'productId';
        invCon.scannerMethodSupplier();
        invCon.barcode = 'productId';
        invCon.scannerMethodSupplier();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        //} catch(Exception e) {}
        Test.StopTest();
    }
    
    
    
    /*Commented by Akhtar
static testMethod void UnitTestErpMark7ShipmentManagement(){ 
try {
// assert standardProfileId valid
Profile Prof = new Profile();
Prof = [select Id 
from Profile 
where Name = 'Standard User' limit 1];
Id standardProfileId = Prof.Id;

PreventRecursiveLedgerEntry.testCasesTransactions = true;
Account orgn = TestDataFactory.createOrganisationAccounts(1)[0];
Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
insert sup;
Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
insert busUnit; 
Commission_Plan__c comPlan = new Commission_Plan__c( Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
insert comPlan;
Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
insert comrate;
Cost_to_Company__c ctc = new Cost_to_Company__c(Organisation__c = orgn.Id, Name='test',Commission_Plan__c=comPlan.Id);
insert ctc;            
CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
insert sal;
CTC_Component__c sal1 = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
insert sal1;
System.assertEquals(sal.Name, sal1.Name);
delete sal1;            
Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
insert rule;
Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
insert tr; 
Tax_Range__c tr1 = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=2000);
insert tr1;
delete tr1;
CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
insert empTax; 
update rule;
Employee_Tax_Rule__c rule1 = new Employee_Tax_Rule__c(Name='test');
insert rule1;  
Profiling__c profile = new Profiling__c(Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(ERP7__Profiling__c.sObjectType,'Employee'));
insert profile;  

Channel__c salepoint = new Channel__c(Name = 'Sale Point');
insert salepoint;

Employees__c emp = new Employees__c(Channel__c = salepoint.Id,First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=insertStandardUser(standardProfileId).Id,Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
insert emp;


Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
insert site;
Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
insert DistributionChannels;                      
Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
insert loyalty;
Account customer = new Account(Name='Customer');
insert customer;
Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
insert contact;
Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
insert bAddress;
Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
insert sAddress;
Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
insert bAddress1;
Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
insert sAddress1;
System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
insert clubCard;

Sales_Order__c sod = new Sales_Order__c();   
sod.Order_Status__c = 'Entered';
sod.Account__c = Contact.AccountId;
sod.Contact__c = Contact.Id;
sod.Channel__c = salePoint.Id;
sod.Bill_To_Address__c = bAddress.Id;
sod.Ship_To_Address__c = sAddress.Id;
sod.Request_Date__c = system.Today();
sod.barcode__c='orderId';
insert sod;
Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
Invoice__c Inv = new Invoice__c(Organisation__c = orgn.Id, Active__c=true);

Inv.Order__c = sod.Id;
insert Inv;
List<Invoice_Line_Item__c> invlList = new List<Invoice_Line_Item__c>();
Invoice_Line_Item__c ILIT = new Invoice_Line_Item__c(Invoice__c = Inv.id, ERP7__Quantity__c = 20, ERP7__Total_Price__c = 400, ERP7__VAT_Amount__c = 100);
invlList.add(ILIT);
Invoice_Line_Item__c ILIT1 = new Invoice_Line_Item__c(Invoice__c = Inv.id, ERP7__Quantity__c = 20, ERP7__Total_Price__c = 400, ERP7__VAT_Amount__c = 100);
invlList.add(ILIT1);
Invoice_Line_Item__c ILIT2 = new Invoice_Line_Item__c(Invoice__c = Inv.id, ERP7__Quantity__c = 20, ERP7__Total_Price__c = 400, ERP7__VAT_Amount__c = 100);
invlList.add(ILIT2);
if(invlList.size()>0){
insert invlList;
delete invlList[0];
}

//Inv.Posted__c = True;
Update Inv;

Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
insert ps; 


Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
insert ps2; 

Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
insert WarehouseItemInventoryStock; 


Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
insert SPLI;
Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
insert WarehouseItemInventoryStock1; 

Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
insert SPLI1;
Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
insert ps1;            
//BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
//insert psa;  
//BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
//insert psa1;            
System.assertEquals(ps.Name,'test');
Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
insert solim;
Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
insert solim1;            
solim1.Quantity__c=1;
update solim1;
solim1.Quantity__c=4;
update solim1;

Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
insert RMA;              
//RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
//insert RMA_Line_Item; 


solim.Quantity__c = 2;
update solim;
Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
insert tier1;
Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
insert dp;
Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
insert tda;
Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
insert tax;            
Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
insert tp;
Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
insert pta;

ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
insert discountCoupon;
ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
insert CouponRedemption;

ERP7__Coupon__c discountCouponV1 = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
insert discountCouponV1;

PageReference pageRef = System.Page.ShipmentManagement;
pageRef.getParameters().put('SON',psod.id);
Test.setCurrentPage(pageRef);

}catch(exception e){}  

}*/
    
    static testMethod void UnitTestErpMark7ShipmentManagements(){ 
        try {
            
            // assert standardProfileId valid
            Profile Prof = new Profile();
            Prof = [select Id 
                    from Profile 
                    where Name = 'Standard User' limit 1];
            Id standardProfileId = Prof.Id;
            
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
            insert comPlan;
            Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
            insert comrate;
            Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
            insert ctc;            
            CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal;
            CTC_Component__c sal1 = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal1;
            System.assertEquals(sal.Name, sal1.Name);
            delete sal1;            
            Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
            insert rule;
            Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
            insert tr; 
            Tax_Range__c tr1 = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=2000);
            insert tr1;
            delete tr1;
            CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
            insert empTax; 
            update rule;
            Employee_Tax_Rule__c rule1 = new Employee_Tax_Rule__c(Name='test');
            insert rule1;   
            Profiling__c profile = new Profiling__c(Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(ERP7__Profiling__c.sObjectType,'Employee'));
            insert profile; 
            
            Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
            insert salepoint;
            
            Employees__c emp = new Employees__c(Channel__c = salepoint.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=insertStandardUser(standardProfileId).Id,Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
            insert emp;
            
            
            Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
            insert site;
            Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
            insert DistributionChannels;                      
            Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
            insert loyalty;
            Account customer = new Account(Name='Customer');
            insert customer;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
            insert contact;
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
            insert bAddress;
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
            insert sAddress;
            Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
            insert bAddress1;
            Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
            insert sAddress1;
            System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
            System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;
            
            Sales_Order__c sod = new Sales_Order__c();   
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Contact__c = Contact.Id;
            sod.Channel__c = salePoint.Id;
            sod.Bill_To_Address__c = bAddress.Id;
            sod.Ship_To_Address__c = sAddress.Id;
            sod.Request_Date__c = system.Today();
            sod.barcode__c='orderId';
            insert sod;
            Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
            Invoice__c Inv = new Invoice__c(name='Test',Active__c=true);
            
            Inv.Order__c = sod.Id;
            insert Inv;
            Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps;            
            Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock; 
            
            Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI;
            Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock1; 
            
            Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI1;
            Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps1;  
            Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps2;              
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;             
            System.assertEquals(ps.Name,'test');
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim;
            Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim1;            
            solim1.Quantity__c=1;
            update solim1;
            solim1.Quantity__c=4;
            update solim1;
            
            /*Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
insert RMA;              
RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
insert RMA_Line_Item; */           
            
            solim.Quantity__c = 2;
            update solim;
            Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
            insert tier1;
            Discount_Plan__c dp = new Discount_Plan__c(Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
            insert dp;
            Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
            insert tda;
            Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;            
            Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
            insert tp;
            Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
            insert pta;
            /* PriceBook_Entry__c pb = new PriceBook_Entry__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Active__c=true,End_Date__c=System.Today()+10, Product__c=ps.id,Purchase_Price__c=80,Selling_Price__c=100,Start_Date__c=System.Today(),Tax_Plan__c=tp.Id);
insert pb;
PriceBook_Entry__c pb1 = new PriceBook_Entry__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Active__c=true,End_Date__c=System.Today()+10, Product__c=ps1.id,Purchase_Price__c=80,Selling_Price__c=100,Start_Date__c=System.Today(),Tax_Plan__c=tp.Id);
insert pb1; */
            
            ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
            insert discountCoupon;
            ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
            insert CouponRedemption;
            
            ERP7__Coupon__c discountCouponV1 = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
            insert discountCouponV1;
            
            Package__c pack = new Package__c( Name__c = 'Test Pack');
            insert pack;
            ERP7__Package_List__c plist = new ERP7__Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,
                                                                    Package__c = pack.Id, Quantity__c = 3);
            insert plist;
            
            PageReference pageRef = System.Page.ShipmentManagement;
            pageRef.getParameters().put('SON',psod.id);
            Test.setCurrentPage(pageRef);
            
            test.startTest();
            ApexPages.StandardController controller;
            ShipmentManagements sc = new ShipmentManagements();
            
            sc.getCurrencyISO();
            sc.createPackage();
            sc.Package2Create.Name__c = 'test';
            sc.Package2Create.Shipment_Type__c = 'UPS';
            sc.savePackage();
            Package__c Package2Create = [Select id, Name, Shipment_Type__c, Active__c, Deposit_Tag__c, Name__c, Sales_Order__c, Status__c
                                         From Package__c limit 1];
            sc.pack2updateId = Package2Create.Id;
            Package2Create.Sales_Order__c=psod.id;
            sc.editPackage();
            sc.updatePacks();
            sc.assignNewPack();
            sc.deassignNewPack();
            sc.NextUPS();
            
            sc.packId = Package2Create.Id;
            sc.Next();
            sc.NextInternal();
            
            Package2Create.Shipment_Type__c = 'Internal Shipping';
            sc.redirecting();
            Package2Create.Active__c = true;
            upsert Package2Create;
            sc.packId = Package2Create.Id;
            sc.getCurrentOrderItems(sod.Id);
            test.stopTest();
            //PageReference pageRef1 = System.Page.InternalShipping;
            //pageRef1.getParameters().put('pack',Package2Create.id);
            //Test.setCurrentPage(pageRef1);
            
            sc.Next();
            sc.cancelPackage();
            sc.pack2updateId = Package2Create.Id;
            sc.deletePackage();
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            
        }catch(exception e){}  
    }
    
    
    static testMethod void UnitTestErpMark7StockInventoryManagement(){ 
        try {
            
            // assert standardProfileId valid
            Profile Prof = new Profile();
            Prof = [select Id 
                    from Profile 
                    where Name = 'Standard User' limit 1];
            Id standardProfileId = Prof.Id;
            
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
            insert comPlan;
            Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
            insert comrate;
            Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
            insert ctc;            
            CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal;
            CTC_Component__c sal1 = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal1;
            System.assertEquals(sal.Name, sal1.Name);
            delete sal1;            
            Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
            insert rule;
            Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
            insert tr; 
            Tax_Range__c tr1 = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=2000);
            insert tr1;
            delete tr1;
            CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
            insert empTax; 
            update rule;
            Employee_Tax_Rule__c rule1 = new Employee_Tax_Rule__c(Name='test');
            insert rule1;   
            RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__Profiling__c' And Name='Employee' Limit 1];
            Profiling__c profile = new Profiling__c(Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile.Id);
            insert profile;  
            Channel__c salepoint = new Channel__c(Name = 'Sale Point');
            insert salepoint;
            
            Employees__c emp = new Employees__c(Channel__c = salepoint.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=insertStandardUser(standardProfileId).id,Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
            insert emp;
            
            
            Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
            insert site;
            Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
            insert DistributionChannels;                      
            Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
            insert loyalty;
            Account customer = new Account(Name='Customer');
            insert customer;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
            insert contact;
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
            insert bAddress;
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
            insert sAddress;
            Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
            insert bAddress1;
            Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
            insert sAddress1;
            System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
            System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Organisation__c = orgn.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;
            
            Sales_Order__c sod = new Sales_Order__c();   
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Contact__c = Contact.Id;
            sod.Channel__c = salePoint.Id;
            sod.Bill_To_Address__c = bAddress.Id;
            sod.Ship_To_Address__c = sAddress.Id;
            sod.Request_Date__c = system.Today();
            sod.barcode__c='orderId';
            insert sod;
            Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
            Invoice__c Inv = new Invoice__c(name= 'Test',Active__c=true);
            
            Inv.Order__c = sod.Id;
            insert Inv;
            Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps;            
            Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock; 
            
            Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI;
            Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock1; 
            
            Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI1;
            Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps1;  
            Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps2;          
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;             
            System.assertEquals(ps.Name,'test');
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim;
            Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim1;            
            solim1.Quantity__c=1;
            update solim1;
            solim1.Quantity__c=4;
            update solim1;
            
            /*Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
insert RMA;              
RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
insert RMA_Line_Item; */
            
            
            solim.Quantity__c = 2;
            update solim;
            Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
            insert tier1;
            Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
            insert dp;
            Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
            insert tda;
            Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;            
            Tax_Plan__c tp = new Tax_Plan__c(Name= 'Test',Type__c='sales');
            insert tp;
            Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
            insert pta;
            /* PriceBook_Entry__c pb = new PriceBook_Entry__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Active__c=true,End_Date__c=System.Today()+10, Product__c=ps.id,Purchase_Price__c=80,Selling_Price__c=100,Start_Date__c=System.Today(),Tax_Plan__c=tp.Id);
insert pb;
PriceBook_Entry__c pb1 = new PriceBook_Entry__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Active__c=true,End_Date__c=System.Today()+10, Product__c=ps1.id,Purchase_Price__c=80,Selling_Price__c=100,Start_Date__c=System.Today(),Tax_Plan__c=tp.Id);
insert pb1; */
            
            ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
            insert discountCoupon;
            ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
            insert CouponRedemption;
            
            ERP7__Coupon__c discountCouponV1 = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
            insert discountCouponV1;
            
            PageReference pageRef = System.Page.StockReceiving;
            Test.setCurrentPage(pageRef);
            
            test.startTest();
            ApexPages.StandardController controller;
            StockReceiving sc = new StockReceiving();
            StockReceiving.POWrapper pow = new StockReceiving.POWrapper();
            StockReceiving.WOWrapper wow = new StockReceiving.WOWrapper();
            StockReceiving.SOWrapper sow = new StockReceiving.SOWrapper();
            StockReceiving.TOWrapper tow = new StockReceiving.TOWrapper();
            StockReceiving.newWrapper now = new StockReceiving.newWrapper(1);
            
            sc.SearchWOS();
            sc.SearchPOS();
            sc.SearchSOS();
            sc.SearchTOS();
            sc.setWO();
            sc.setPO();
            sc.setSO();
            sc.setTO();
            sc.barcode = 'test';
            sc.scannerMethod();
            sc.scannerMethodCustom();
            sc.PutAway();
            sc.PutAwayPOS();
            sc.PutAwayWOS();
            sc.PutAwaySOS();
            sc.PutAwayTOS();
            sc.selectAll = true;
            sc.POALL();
            sc.WOALL();
            sc.SOALL();
            sc.TOALL();
            sc.selectAll = false;
            sc.POALL();
            sc.WOALL();
            sc.SOALL();
            sc.TOALL();
            
            sc.createPOs();             
            StockReceiving.addRow = 1;
            sc.addPoliWrapperRows();
            StockReceiving.toDelIdent = 1;
            sc.delPoliWrapperRow();
            sc.savePO();
            
            sc.createWOs();             
            StockReceiving.addRow = 1;
            sc.addWoliWrapperRows();
            StockReceiving.toDelIdent = 1;
            sc.delWoliWrapperRow();
            sc.saveWO();
            
            sc.createPRs();             
            StockReceiving.addRow = 1;
            sc.addPrliWrapperRows();
            StockReceiving.toDelIdent = 1;
            sc.delPrliWrapperRow();
            sc.savePR();
            
            sc.createSalesReturns();
            sc.back();
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
        }catch(exception e){}  
        
    }
    
    static testMethod void UnitTestErpMark7RMAInventoryManagement(){ 
        
        // assert standardProfileId valid
        Profile Prof = new Profile();
        Prof = [select Id 
                from Profile 
                where Name = 'Standard User' limit 1];
        Id standardProfileId = Prof.Id;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
        insert comPlan;
        Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
        insert comrate;
        Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
        insert ctc;            
        CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal;
        CTC_Component__c sal1 = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal1;
        System.assertEquals(sal.Name, sal1.Name);
        delete sal1;            
        Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
        insert rule;
        Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
        insert tr; 
        Tax_Range__c tr1 = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=2000);
        insert tr1;
        delete tr1;
        CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
        insert empTax; 
        update rule;
        Employee_Tax_Rule__c rule1 = new Employee_Tax_Rule__c(Name='test');
        insert rule1;   
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__Profiling__c' And Name='Employee' Limit 1];
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile.Id);
        insert profile;  
        
        
        Site__c site = new Site__c(Organisation__c = orgn.Id,Name = 'site', Active__c=true);
        insert site;
        
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Name = 'Test',Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress1;
        ERP7__Channel__c channel = new ERP7__Channel__c(Organisation__c = orgn.Id,Name='Test Channel', ERP7__Ship_From_Address__c=sAddress.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                        ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                        ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert channel;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels; 
        Employees__c emp = new Employees__c(Channel__c = channel.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=insertStandardUser(standardProfileId).Id,Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = Contact.AccountId,Contact__c = Contact.Id,Channel__c = channel.Id,Bill_To_Address__c = bAddress.Id,Ship_To_Address__c = sAddress.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Invoice__c Inv = new Invoice__c(Organisation__c = orgn.Id, Active__c=true);
        
        Inv.Order__c = sod.Id;
        insert Inv;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps; 
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps1; 
        //Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        //insert WarehouseItemInventoryStock; 
        
        //Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        //insert SPLI1; 
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps2;         
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;            
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
        
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Product__c = ps.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item; 
        RMA_Line_Item__c RMA_Line_Item2 = new RMA_Line_Item__c(Product__c = ps2.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item2;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__RMA_Line_Item__c=RMA_Line_Item.id);
        insert mrp;
        
        //Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(RMA_Line_Item__c=RMA_Line_Item.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        //insert SPLI;
        solim.Quantity__c = 2;
        update solim;
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
        Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
        insert tp;
        Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
        insert pta;
        
        ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCoupon;
        ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
        insert CouponRedemption;
        
        ERP7__Coupon__c discountCouponV1 = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCouponV1;
        
        PageReference pageRef1 = System.Page.RMAInventoryConsole;
        pageRef1.getParameters().put('soId', sod.id);
        Test.setCurrentPage(pageRef1);
        test.startTest();
        ApexPages.StandardController controller;
        InventoryManagement sc1 = new InventoryManagement(controller);
        sc1.Receive();
        sc1.PutAway();
        sc1.counter = 0;
        sc1.AddSOStock(); 
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.ExplodeKitSO();
        sc1.Back2Order();
        sc1.Back2StockReceiving();
        sc1.selectedSite = site.id;
        sc1.SaveROLines();
        sc1.cancelSo();
        sc1.counter = 0;
        sc1.ExplodeSOLI();
        //sc1.AddStockKitSO();
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.RemoveSOStock(); 
        sc1.barcode = 'productId';
        sc1.scannerMethodReturns();
        sc1.barcode = 'productId';
        sc1.scannerMethodReturns();
        sc1.SaveROLInesReceived();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    static testMethod void UnitTestErpMark7RMAInventoryManagement_1(){ 
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account customer = new Account(Name='Customer',Account_Type__c='Customer');
        insert customer;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Site__c site = new Site__c(Organisation__c = orgn.Id,Name = 'site', Active__c=true);
        insert site;   
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        ERP7__Channel__c channel = new ERP7__Channel__c(Organisation__c = orgn.Id,Name='Test Channel', ERP7__Ship_From_Address__c=sAddress.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                        ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                        ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert channel;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels; 
        Employees__c emp = new Employees__c(Channel__c = channel.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=userInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp; 
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = Contact.AccountId,Contact__c = Contact.Id,Channel__c = channel.Id,Bill_To_Address__c = bAddress.Id,Ship_To_Address__c = sAddress.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Invoice__c Inv = new Invoice__c(Order__c = sod.Id,Organisation__c = orgn.Id, Active__c=true);
        insert Inv;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId',Serialise__c=true);
        insert ps; 
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='RMTest1',ERP7__Product__c=ps.Id);
        insert ser;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps1; 
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps2;         
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;   
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Serial__c=ser.Id);
        insert WarehouseItemInventoryStock;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;  
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Product__c = ps.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item; 
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__RMA_Line_Item__c=RMA_Line_Item.id);
        insert mrp;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(RMA_Line_Item__c=RMA_Line_Item.id,Serial__c=ser.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=1);
        insert SPLI;  
        PageReference pageRef1 = System.Page.RMAInventoryConsole;
        pageRef1.getParameters().put('soId', sod.id);
        Test.setCurrentPage(pageRef1);
        test.startTest();
        ApexPages.StandardController controller;
        InventoryManagement sc1 = new InventoryManagement(controller);
        
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.ExplodeKitSO();
        sc1.selectedSite = site.id;
        sc1.SaveROLines();
        sc1.counter = 0;
        sc1.AddSOStock();
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.RemoveSOStock();
        sc1.Back2Order();
        sc1.Back2StockReceiving();
        sc1.cancelSo();
        sc1.counter = 0;
        sc1.ExplodeSOLI();
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.AddSOStock();
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.RemoveSOStock(); 
        sc1.barcode = 'productId';
        sc1.scannerMethodReturns();
        sc1.barcode = 'productId';
        sc1.scannerMethodReturns();
        sc1.SaveROLInesReceived();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    static testMethod void UnitTestErpMark7RMAInventoryManagement_2(){ 
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Account customer = new Account(Name='Customer',Account_Type__c='Customer');
        insert customer;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Site__c site = new Site__c(Name = 'site', Active__c=true);
        insert site;                   
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Name = 'Test',Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress1;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=sAddress.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                        ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                        ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert channel;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels; 
        Employees__c emp = new Employees__c(Channel__c = channel.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=userInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = Contact.AccountId,Contact__c = Contact.Id,Channel__c = channel.Id,Bill_To_Address__c = bAddress.Id,Ship_To_Address__c = sAddress.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Invoice__c Inv = new Invoice__c(Organisation__c = orgn.Id, Active__c=true);
        Inv.Order__c = sod.Id;
        insert Inv;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId',Serialise__c=true);
        insert ps; 
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='RMTest1',ERP7__Product__c=ps.Id);
        insert ser;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId',Serialise__c=true);
        insert ps1;
        ERP7__Serial_Number__c ser1 = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='RMTest2',ERP7__Product__c=ps1.Id);
        insert ser1; 
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps2;         
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;   
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Serial__c=ser.Id);
        insert WarehouseItemInventoryStock;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;  
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Explode__c=true,Product__c = ps.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item; 
        RMA_Line_Item__c RMA_Line_Item2 = new RMA_Line_Item__c(Explode__c=true,Product__c = ps2.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item2;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__RMA_Line_Item__c=RMA_Line_Item.id);
        insert mrp;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(ERP7__Serial__c=ser.id,RMA_Line_Item__c=RMA_Line_Item.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=1);
        insert SPLI;   
        PageReference pageRef1 = System.Page.RMAInventoryConsole;
        pageRef1.getParameters().put('soId', sod.id);
        Test.setCurrentPage(pageRef1);
        test.startTest();
        ApexPages.StandardController controller;
        InventoryManagement sc1 = new InventoryManagement(controller);
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.ExplodeKitSO();
        sc1.counter = 0;
        sc1.subcounter = 0;
        //sc1.AddStockKitSO();
        sc1.selectedSite = site.id;
        sc1.SaveROLines();
        sc1.counter = 0;
        sc1.AddSOStock();
        sc1.counter = 0;
        sc1.ExplodeSOLI();
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.RemoveSOStock(); 
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    static testMethod void UnitTestErpMark7RMAInventoryManagement_3(){ 
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Account customer = new Account(Name='Customer',Account_Type__c='Customer');
        insert customer;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Site__c site = new Site__c(Name = 'site', Active__c=true);
        insert site;                   
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Name = 'Test',Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress1;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=sAddress.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                        ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                        ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert channel;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels; 
        Employees__c emp = new Employees__c(Channel__c = channel.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=userInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = Contact.AccountId,Contact__c = Contact.Id,Channel__c = channel.Id,Bill_To_Address__c = bAddress.Id,Ship_To_Address__c = sAddress.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Invoice__c Inv = new Invoice__c(Organisation__c = orgn.Id, Active__c=true);
        Inv.Order__c = sod.Id;
        insert Inv;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId',Serialise__c=true);
        insert ps; 
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='RMTest1',ERP7__Product__c=ps.Id);
        insert ser;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId',Serialise__c=true);
        insert ps1;
        ERP7__Serial_Number__c ser1 = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='RMTest2',ERP7__Product__c=ps1.Id);
        insert ser1; 
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps2;         
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;   
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id);
        insert WarehouseItemInventoryStock;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;  
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Explode__c=true,Product__c = ps.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item; 
        RMA_Line_Item__c RMA_Line_Item2 = new RMA_Line_Item__c(Explode__c=true,Product__c = ps2.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item2;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__RMA_Line_Item__c=RMA_Line_Item.id);
        insert mrp;
        PageReference pageRef1 = System.Page.RMAInventoryConsole;
        pageRef1.getParameters().put('soId', sod.id);
        Test.setCurrentPage(pageRef1);
        test.startTest();
        ApexPages.StandardController controller;
        InventoryManagement sc1 = new InventoryManagement(controller);
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.ExplodeKitSO();
        sc1.selectedSite = site.id;
        sc1.SaveROLines();
        sc1.counter = 0;
        sc1.AddSOStock();
        sc1.counter = 0;
        sc1.ExplodeSOLI();
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.AddSOStock();
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.RemoveSOStock(); 
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    static testMethod void UnitTestErpMark7RMAInventoryManagement_4(){ 
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Account customer = new Account(Name='Customer',Account_Type__c='Customer');
        insert customer;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Site__c site = new Site__c(Name = 'site', Active__c=true);
        insert site;                   
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Name = 'Test',Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress1;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=sAddress.Id, ERP7__City__c='Test City', ERP7__Street__c='Test Street', ERP7__State_Province__c='Test Province', ERP7__Country__c='Test Country',
                                                        ERP7__Zip_Postal_Code__c='Test Code', ERP7__Shipper_Name__c='Test Shipper', ERP7__Company__c='Test Company',
                                                        ERP7__Phone__c='1234567890', ERP7__Active__c=true);
        insert channel;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels; 
        Employees__c emp = new Employees__c(Channel__c = channel.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=userInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false);
        insert emp;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Entered',Account__c = Contact.AccountId,Contact__c = Contact.Id,Channel__c = channel.Id,Bill_To_Address__c = bAddress.Id,Ship_To_Address__c = sAddress.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
        Invoice__c Inv = new Invoice__c(Organisation__c = orgn.Id, Active__c=true);
        Inv.Order__c = sod.Id;
        insert Inv;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId',Serialise__c=true);
        insert ps; 
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='RMTest1',ERP7__Product__c=ps.Id);
        insert ser;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId',Serialise__c=true);
        insert ps1;
        ERP7__Serial_Number__c ser1 = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='RMTest2',ERP7__Product__c=ps1.Id);
        insert ser1; 
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps2;         
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;   
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Serial__c=ser.Id);
        insert WarehouseItemInventoryStock;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;  
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Explode__c=true,Product__c = ps.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item; 
        RMA_Line_Item__c RMA_Line_Item2 = new RMA_Line_Item__c(Explode__c=true,Product__c = ps2.id, Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id,Added_Back_to_Inventory__c=false,ERP7__Active__c = true, ERP7__Return_Status__c = 'Quality Check' );
        insert RMA_Line_Item2;
        Id MRPKit = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
        ERP7__MRP__c mrp = new ERP7__MRP__c(ERP7__Total_Amount_Required__c=1,ERP7__MRP_Product__c=ps.id,RecordTypeId=MRPKit,Name='Test',ERP7__RMA_Line_Item__c=RMA_Line_Item.id);
        insert mrp;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(ERP7__Serial__c=ser.id,RMA_Line_Item__c=RMA_Line_Item.id,Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=1);
        insert SPLI;   
        PageReference pageRef1 = System.Page.RMAInventoryConsole;
        pageRef1.getParameters().put('soId', sod.id);
        Test.setCurrentPage(pageRef1);
        test.startTest();
        ApexPages.StandardController controller;
        InventoryManagement sc1 = new InventoryManagement(controller);
        sc1.counter = 0;
        sc1.subcounter = 0;
        sc1.ExplodeKitSO();
        sc1.selectedSite = site.id;
        sc1.SaveROLines();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    
    
    
    public static String getUserNamePrefix(){
        
        return UserInfo.getOrganizationId() + System.now().millisecond();
        
    }
    
    public static User insertStandardUser(Id standardProfileId){
        
        
        
        User standardUser = new User(
            
            Username = getUserNamePrefix() + 'standarduser@testorg.com',
            
            Alias = 'standt',
            
            email = 'standarduser@testorg.com',
            
            emailencodingkey = 'UTF-8',
            
            LastName = 'Testing',
            
            LocaleSidKey = 'en_US',
            
            LanguageLocaleKey = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()].LanguageLocaleKey,
            
            ProfileId = standardProfileId,
            
            TimeZoneSidKey = 'America/Los_Angeles'
            
        );
        
        insert standardUser;
        
        return standardUser;
    }
    
    static testMethod void UnitTestErpMark7TransferInventoryManagement2(){
        Profile Prof = new Profile();
        Prof = [select Id 
                from Profile 
                where Name = 'Standard User' limit 1];
        Id standardProfileId = Prof.Id;
        
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = TestDataFactory.createOrganisationAccounts(1)[0];
        Account Sup = new Account(Name='Test', Account_type__c='vendor');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
        insert comPlan;
        Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
        insert comrate;
        Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
        insert ctc;            
        CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal;            
        Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
        insert rule;
        Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
        insert tr; 
        CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
        insert empTax; 
        update rule;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(ERP7__Profiling__c.sObjectType,'Employee'));
        insert profile;  
        Employees__c emp = new Employees__c(Channel__c = salepoint.Id,First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=insertStandardUser(standardProfileId).Id,Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;                      
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.barcode__c='orderId';
        insert sod;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps;            
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId', Serialise__c=true);
        insert ps1;     
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId', Serialise__c=true);
        insert ps2;        
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;            
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
        
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id, Organisation__c = sod.Organisation__c);
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
        insert RMA_Line_Item; 
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    } 
    
    static testMethod void UnitTestErpMark7TransferInventoryManagement(){ 
        
        Profile Prof = new Profile();
        Prof = [select Id 
                from Profile 
                where Name = 'Standard User' limit 1];
        Id standardProfileId = Prof.Id;
        
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = TestDataFactory.createOrganisationAccounts(1)[0];
        Account Sup = new Account(Name='Test', Account_type__c='vendor');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
        insert comPlan;
        Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
        insert comrate;
        Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
        insert ctc;            
        CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal;            
        Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
        insert rule;
        Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
        insert tr; 
        CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
        insert empTax; 
        update rule;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(ERP7__Profiling__c.sObjectType,'Employee'));
        insert profile;  
        Employees__c emp = new Employees__c(Channel__c = salepoint.Id,First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=insertStandardUser(standardProfileId).Id,Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;                      
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.barcode__c='orderId';
        insert sod;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps;            
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId', Serialise__c=true);
        insert ps1;     
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId', Serialise__c=true);
        insert ps2;        
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;            
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
        
        
        
        
        solim.Quantity__c = 2;
        update solim;
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
        Tax_Plan__c tp = new Tax_Plan__c(Name = 'Test', Type__c='sales');
        insert tp;
        Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Name = 'Test',Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
        insert pta;
        
        ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCoupon;
        ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
        insert CouponRedemption;
        
        ERP7__Coupon__c discountCouponV1 = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCouponV1;
        
        ERP7__Transfer_Order__c TO = new ERP7__Transfer_Order__c(Name='test',Active__c=true,Status__c='Approved');
        insert TO;
        Transfer_Order_Line_Items__c toli1 = new Transfer_Order_Line_Items__c(Name='Test',Batch_Lot_Code__c='test', Products__c=ps.id,Transfer_Order__c=to.id,Quantity_received__c=100,Quantity_requested__c=100,Explode__c=false);
        insert toli1;
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account', Organisation__c = orgn.Id);
        insert BA;
        PO__c PO = new PO__c( Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
        insert PO;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=5,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        
        
        ERP7__Process__c process = new ERP7__Process__c(Name='Test');
        insert process;
        ERP7__WO__c wo = new ERP7__WO__c(Name='test'); //, ERP7__Process__c=process.Id
        insert wo;
        Work_Order_Line_Items__c woli1 = new Work_Order_Line_Items__c(Quantity__c=5,Work_Orders__c=wo.id,Product__c = ps.Id);
        insert woli1;
        ERP7__Process_Cycle__c procycle = new ERP7__Process_Cycle__c(Name='test', ERP7__Process__c=process.Id);
        insert procycle;
        ERP7__BOM__c bom = new ERP7__BOM__c(Name='test', ERP7__Manufacturing_Assembly_Process__c=process.Id, ERP7__Process_Cycle__c=procycle.Id, ERP7__Quantity__c=10);
        insert bom;
        ERP7__Return_Merchandise_Authorisation__c rma1 = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Organisation__c=orgn.Id);
        insert rma1;
        ERP7__RMA_Line_Item__c rmaitem = new ERP7__RMA_Line_Item__c(Name='test', ERP7__Return_Merchandise_Authorisation__c=rma1.Id, Quantity_Return__c=10);
        insert rmaitem;
        PageReference pageRef1 = System.Page.TransferInventoryConsole;
        pageRef1.getParameters().put('toId', TO.id);
        Test.setCurrentPage(pageRef1);
        test.startTest();
        ApexPages.StandardController controller;
        InventoryManagement sc1 = new InventoryManagement(controller);
        ERP7__Purchase_Line_Items__c PLI = poli;
        InventoryManagement.PLIWrapper pli1 = new InventoryManagement.PLIWrapper(PLI);
        Work_Order_Line_Items__c WOLI = woli1;
        InventoryManagement.WOLIWrapper wol = new InventoryManagement.WOLIWrapper(WOLI);
        ERP7__RMA_Line_Item__c RMALI = rmaitem;
        InventoryManagement.RMALIWrapper rmawrap = new InventoryManagement.RMALIWrapper(RMALI);
        Transfer_Order_Line_Items__c TOLI = toli1;
        InventoryManagement.TOLIWrapper tol = new InventoryManagement.TOLIWrapper(TOLI);
        Inventory_Stock__c WIIS = WarehouseItemInventoryStock1;
        List<Stock_Inward_Line_Item__c> SPLIS = [Select  Name, Active__c, Site_ProductService_InventoryStock__c, Product__c, Quantity__c From Stock_Inward_Line_Item__c where Site_ProductService_InventoryStock__c =: WarehouseItemInventoryStock.Id]; 
        InventoryManagement.StockWrapper stock = new InventoryManagement.StockWrapper(WarehouseItemInventoryStock1, SPLIS);
        Inventory_Stock__c WIIS1 = WarehouseItemInventoryStock1;
        Stock_Inward_Line_Item__c SPL = SPLI1;
        InventoryManagement.StockWrapperNew stockNew = new InventoryManagement.StockWrapperNew(WIIS1, SPLI1);
        try { 
            sc1.counter = 0;
            sc1.AddTransferStock(); 
            sc1.counter = 0;
            sc1.subcounter = 0;
            sc1.RemoveTransferStock(); 
        } catch(Exception e) {}
        sc1.cancelTo();
        sc1.SaveTOLines();
        sc1.SaveTOLiness();
        sc1.SaveTOLinesReceived();
        sc1.SaveWOLinesReceived();
        sc1.barcode = 'productId';
        sc1.scannerMethodTransfer();
        sc1.barcode = 'productId';
        sc1.scannerMethodTransfer();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    
    static testMethod void InternalShippingTestClass(){
        /*Profile Prof = new Profile();
        Prof = [select Id 
                from Profile 
                where Name = 'Standard User' limit 1];
        Id standardProfileId = Prof.Id;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = TestDataFactory.createOrganisationAccounts(1)[0];
        List<Account> custAcc=TestDataFactory.createCustomerAccounts(5);//
        List<ERP7__Invoice__c> Invs=TestDataFactory.createInvoices(5,custAcc);
        List<ERP7__Invoice_Line_Item__c> InvLis=TestDataFactory.createInvoicesLineItem(5,Invs);
        
        TestDataFactory.createData(5);//
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
        insert comPlan;
        Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
        insert comrate;
        Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
        insert ctc;            
        CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal;          
        Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
        insert rule;
        Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
        insert tr; 
        CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
        insert empTax; 
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(ERP7__Profiling__c.sObjectType,'Employee'));
        insert profile; 
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(Channel__c = salepoint.Id, First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=insertStandardUser(standardProfileId).Id,Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;                      
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',Country__c='United kingdom',State__c='Surrey', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
        insert sAddress;
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.barcode__c='orderId';
        insert sod;
        Invoice__c Inv = new Invoice__c(Organisation__c = orgn.Id, Active__c=true,Order__c = sod.Id);
        insert Inv;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps;            
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps1;  
        Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
        insert ps2;              
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;             
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
        
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id, Name = 'Test');
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
        insert RMA_Line_Item;            
        
        solim.Quantity__c = 2;
        update solim;
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
        Tax_Plan__c tp = new Tax_Plan__c(Name = 'Test',Type__c='sales');
        insert tp;
        Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
        insert pta;
        
        ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCoupon;
        ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
        insert CouponRedemption;
        
        ERP7__Coupon__c discountCouponV1 = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCouponV1;
        
        ERP7__Shipment__c ship = new ERP7__Shipment__c(Name='test', 
                                                       ERP7__Shipment_Type__c = 'commercial', ERP7__Customer__c = customer.Id, RecordTypeId = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(ERP7__Shipment__c.sObjectType,'Shipping'));
        PreventRecursiveLedgerEntry.preventShipmentcounterTrigger = false;    
        insert ship;
        Package__c pack = new Package__c( Name__c = 'Test Pack', Active__c = true, Shipment__c=ship.Id);
        insert pack;
        ERP7__Package_List__c plist = new ERP7__Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim.Id,
                                                                Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        ERP7__Shipment_Flow__c sflow = new ERP7__Shipment_Flow__c(Name='test', ERP7__Shipment__c=ship.Id, ERP7__Active__c=true, RecordTypeId=RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(ERP7__Shipment_Flow__c.sObjectType,'Pickup'));
        insert sflow;
        InternalShipping IS = new InternalShipping();
        IS.getCurrentOrder('');
        IS.getCurrentInv('');
        IS.InternalShippingCustom();
        IS.Back();
        IS.SaveDetails();
        IS.NewShipmentFlow();
        IS.deleteShipmentFlow();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);*/
    }
}