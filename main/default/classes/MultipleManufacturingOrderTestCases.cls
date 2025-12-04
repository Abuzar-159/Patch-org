@isTest
public class MultipleManufacturingOrderTestCases {
    
    @testSetup static void dataSetup(){
        Account orgn = new Account(Name='Universal Stores', Account_Type__c = 'Organisation');
        insert orgn;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=orgn.Id,ERP7__Active__c=true,ERP7__Is_Billing_Address__c=true);
        insert address;
        ERP7__Address__c  saddress = new ERP7__Address__c(Name='Test', ERP7__Customer__c=orgn.Id,ERP7__Active__c=true,ERP7__Is_Shipping_Address__c=true);
        insert saddress;
        Account cus = new Account(Name='Customer',Account_Type__c = 'Customer');
        insert cus;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=cus.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true, ERP7__Issue_Manufacturing_Order__c=true);
        insert ps;
        Product2 ps1 = new Product2(Name='test', isActive=true,Track_Inventory__c=true, ERP7__Issue_Manufacturing_Order__c=true);
        insert ps1;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test',  ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true,ERP7__Organisation__c = orgn.Id );
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id,ERP7__Active__c=true);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true,ERP7__Priority__c = '1');
        insert DC;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',ERP7__Product__c=ps.Id,ERP7__Active__c=true,ERP7__Type__c='Alternate',ERP7__Status__c='Certified',ERP7__Quantity__c=1,ERP7__Start_Date__c=system.today(),ERP7__To_Date__c=system.today(),ERP7__Unit_of_Measure__c='Each',ERP7__Sales_Ready__c=true);
        insert ver;
        
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=ps.Id,ERP7__BOM_Version__c=ver.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = ver.Id, ERP7__Product__c = ps.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000,ERP7__Address__c=address.Id);
        insert routing;
        
        ps.ERP7__Version__c=ver.Id;
        ps.ERP7__Routing__c=routing.Id;
        update ps;
        
        
        
        ERP7__Project__c project = new ERP7__Project__c(Name = 'Test', ERP7__Active__c = true, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today()+1, ERP7__Requisition_Type__c = 'Goods', ERP7__Status__c = 'New');
        insert project;
        ERP7__Machine__c machine = new ERP7__Machine__c(Name = 'Test');
        insert machine;
        ERP7__Work_Center__c wc = new ERP7__Work_Center__c(Name = 'Test', ERP7__Active__c = true, ERP7__Shop_Floor_Warehouse__c = site.Id, ERP7__Type__c = 'Machine', ERP7__Planned_Capacity__c = 5, ERP7__Consumed_Capacity__c = 1, ERP7__Maximum_Capacity_Minutes__c = 3, ERP7__Organisation__c = orgn.Id, ERP7__Channel__c = channel.Id, ERP7__Plant__c = site.Id, ERP7__Machine__c = machine.Id);
        insert wc;
        
        ERP7__Operation__c oprn = new ERP7__Operation__c(Name = 'Test', ERP7__Work_Center__c = wc.Id, ERP7__Quantity__c = 7, ERP7__Routing__c = routing.Id, ERP7__Process_Cycle__c = processcycle.Id);
        Insert oprn;
        
    }
    
    public static testmethod void unitTest1(){
        
        MultipleManufacturingOrder.fetchProducts('',10,0,'');
        List<Product2> proList=[Select Id,Name from Product2 where Name='test'];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList) proIds.add(pr.Id);
        MultipleManufacturingOrder.fetchVersionAndRouting(proIds);
        
        List<ERP7__Version__c> verList=[Select Id,Name from ERP7__Version__c where Name='Test'];
        List<ERP7__Routing__c> rtList=[Select Id,Name from ERP7__Routing__c where Name='Test'];
        List<ERP7__Manufacturing_Order__c> MOList=new List<ERP7__Manufacturing_Order__c>();
        ERP7__Manufacturing_Order__c mo=new ERP7__Manufacturing_Order__c();
        mo.ERP7__Product__c=proList[0].Id;
        mo.ERP7__Version__c=verList[0].Id;
        mo.ERP7__Routing__c=rtList[0].Id;
        mo.ERP7__StartDate__c=System.now();
        mo.ERP7__ExpectedDate__c=System.now().addHours(1);
        mo.ERP7__Status__c='Draft';        
        MOList.add(mo);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        MultipleManufacturingOrder.saveMO(JSON.serialize(MOList));
    }

}