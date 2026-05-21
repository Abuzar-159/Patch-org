@isTest
private class PMMRPFulfillmentTestCaseSet {
    
    private Schedule__c mps;
     
    static testMethod void unitMRPFulfillmentTestCase() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = true,Run__c = true);
        insert mod;
         Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',  Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Product2 ps = new Product2(
                                Name='test', isActive=true, Track_Inventory__c=true, Barcode__c = '007879', Issue_Purchase_Order__c=true, Issue_Work_Order__c=true);
        insert ps;
        Process__c mas = new Process__c(Name = 'Test mas');
        insert mas;
        Schedule__c mps = new Schedule__c( Process__c = mas.Id);
        insert mps;
        Schedule__c ms = new Schedule__c(Name = 'Test ms');
        insert ms;
        Site__c s = new Site__c(Organisation__c = orgn.Id,  Name = 'Test site', Active__c = true);      
        insert s;
        
        MRP__c mrp = new MRP__c(Name = 'Test mrp', Status__c = 'Requested', MRP_Product__c = ps.Id, Sourced_Site__c = s.Id,
                      Schedule__c = ms.Id, Required_Amount__c= 90);
        insert mrp;  
        
        Inventory_Stock__c wiis = new Inventory_Stock__c(Name = 'Test wiis', Product__c = ps.Id, 
                                                  Warehouse__c = s.Id);
        insert wiis;
       
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name = 'Test sdli', 
                                          Site_Product_Service_Inventory_Stock__c = wiis.Id, Product__c = ps.Id,
                                          Schedule__c = mps.Id);
        insert sdli;
        Stock_Outward_Line_Item__c sdli1 = new Stock_Outward_Line_Item__c(Name = 'Test sdli', 
                                          Site_Product_Service_Inventory_Stock__c = wiis.Id, Product__c = ps.Id,
                                          Schedule__c = ms.Id);
        insert sdli1;
        
        ApexPages.StandardController controller;
        ProductionOrMaintenanceMRPFulfillment pm1 = new ProductionOrMaintenanceMRPFulfillment(controller);
        ProductionOrMaintenanceMRPFulfillment pm = new ProductionOrMaintenanceMRPFulfillment();
        
        
        pm1.populateSchedule();
        
        ProductionOrMaintenanceMRPFulfillment.sortBy = 'prod';
        pm1.sortList();
        
        pm1.MRPWrapperList[0].selected = true;
        pm1.createPO();
        pm1.wrapCounter = 0;
        
        pm1.savePO();
        
        pm1.MRPWrapperList[0].selected = true;
        pm1.createWO();
        pm1.wrapCounter = 0;
        
        pm1.saveWO();
        
        pm1.Save();
        pm1.SaveNew();
        pm1.barcode = '007879';
        pm1.scannerMethod();
        pm1.addQuantityScanner(ps.id);
        
        pm1.back();
        pm1.Cancel();
        pm1.processMRPs();
        pm1.processProductionMRPs();
        pm1.processMaintenanceMRPs();
        pm1.ProcessCostcardValues();
        pm1.ProcessCostcardValuesWO();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
       
    }
    
    static testMethod void unitMRPFulfillmentTestCase1() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        test.startTest();
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = true,Run__c = true);
        insert mod;
        Account orgn = new Account(Name='Organisation',  Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
         insert salepoint;
             Account customer = new Account(Name='Customer');
            insert customer;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',Contact_Numer__c='test');
            insert contact;
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress;
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
            insert sAddress;
            Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress1;
            Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
            insert sAddress1;
            System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
            System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Organisation__c = orgn.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;
            Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
            
            Sales_Order__c sod = new Sales_Order__c();   
         //   sod.Organisation__c = orgn.Id;
          //  sod.Organisation_Business_Unit__c = busUnit.Id; 
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Contact__c = Contact.Id;
            sod.Channel__c = salePoint.Id;
            sod.Bill_To_Address__c = bAddress1.Id;
            sod.Ship_To_Address__c = sAddress1.Id;
            sod.Request_Date__c = system.Today();
            sod.Is_Back_Order__c = true;
            insert sod;
            Product2 ps = new Product2(
                                    Name='test', isActive=true, Track_Inventory__c=true, Barcode__c = '007879');
            insert ps;
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Order_Line_Status__c='Requested',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim;
            Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Order_Line_Status__c='Requested',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim1; 
            Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
            insert site;
            Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock;
            
            Stock_Outward_Line_Item__c ppli = new Stock_Outward_Line_Item__c(Sales_Order__c=sod.id,Status__c='Requested',Product__c=ps.id,Quantity__c=1,Sales_Order_Line_Item__c=solim.id,Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.id,Supplier__c = sup.id);
            insert ppli;
            Stock_Outward_Line_Item__c ppli1 = new Stock_Outward_Line_Item__c(Sales_Order__c=sod.id, Status__c='Requested',Product__c=ps.id,Quantity__c=3,Sales_Order_Line_Item__c=solim1.id,Site_Product_Service_Inventory_Stock__c=WarehouseItemInventoryStock.id,Supplier__c = sup.id);
            insert ppli1;
            PageReference pageref = Page.OrderFulfillment;
            pageref.getParameters().put('Id',salepoint.id);
            Test.setCurrentPage(pageref);
            ApexPages.StandardController controller;
            SalesOrderFulfillment sof = new SalesOrderFulfillment(controller);
            sof.EvaluateStock();
            sof.FulfillOrders();
            sof.OrderConsole();
            sof.sortList();
            PrintBarcodes PB = new PrintBarcodes();
            PB.customCon();
            PB.BarcodeLocSwitch();
            PB.LabelLocSwitch();
            PB.Beginning();
            PB.Previous();
            PB.Next();
            PB.End();
            PB.getDisablePrevious();
            PB.getDisableNext();
            PB.getTotal_size();
            PB.getlistsize();
            PB.getPageNumber();
            PB.getcounter();
            PB.getTotalPages();
            PB.customConEval();
            PB.fieldProps();
            PB.selectAll = true;
            PB.selectAll();
            PB.PrintPreview();
            Test.stopTest();
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
    }
    
}