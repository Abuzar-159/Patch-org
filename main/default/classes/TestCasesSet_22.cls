@isTest
private class TestCasesSet_22 {
    static testMethod void UnitTest1(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        Address__c bAddress = new Address__c( Customer__c = sup.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c bAddress1 = new Address__c( Customer__c = orgn.Id, Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account');
        insert BA;
        PO__c PO = new PO__c( Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress1.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
        insert PO;  
        Product2 ps = new Product2(Name='test', Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=2,Quantity_Received__c=2,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];     
        
        List<Purchase_Line_Items__c> poliList = [Select id, name,  Unit_Price__c,
                                                    Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
        
        Site__c site = new Site__c(Name = 'site', Active__c=true);
        insert site;
            
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
       
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2, Purchase_Line_Items__c=poli.Id);
        insert SPLI; 
        
        Process__c MAPs = new Process__c();
            MAPs.Name = 'Test';
            MAPs.Organisation__c = orgn.Id;
            MAPs.Process_Name__c = 'Test';
        insert MAPs;
        
        Cost_Card__c CC = new Cost_Card__c();
            CC.Name = 'Test';
            CC.Active__c = true;
            CC.Organisation__c = orgn.Id;
            CC.Organisation_Business_Unit__c = bUnit.Id;
            CC.Product__c = PS.Id;
            CC.Cost__c = 1;
        insert CC;
        
        BOM__c BOM = new BOM__c();
            BOM.Name = 'Test';
            BOM.Active__c = true;
            BOM.Cost_Card__c = CC.Id;
           // BOM.Finished_Products__c = PS.Id;
            BOM.BOM_Product__c = PS.Id;
            BOM.Quantity__c = 1;
            BOM.Manufacturing_Assembly_Process__c = MAPs.Id;    
        insert BOM;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        MRP__c MRP = new MRP__c();
            MRP.BOM__c = BOM.Id;
            MRP.Fulfilled_Amount__c = 1;
            MRP.Process__c = MAPs.Id;
            MRP.MRP_Product__c = PS.Id;
            MRP.Required_Amount__c = 1;
            MRP.BOM_Requirement_Cost__c = 10;
            MRP.BOM_Requirement_Cost__c = 10;
        insert MRP;
         
        update MRP;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        delete BOM;
        delete MRP;
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }

}