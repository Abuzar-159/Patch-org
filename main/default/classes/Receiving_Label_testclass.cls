@isTest
public  class Receiving_Label_testclass {
    @isTest(SeeAllData=false)
    public static void testmethod1(){
         Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        
        Address__c bAddress = new Address__c(Customer__c=customer.id, ERP7__Primary__c = true,
                                             Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                                             City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true, Is_Shipping_Address__c=true);
        insert bAddress;
        
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = bAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        insert sod;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true, ERP7__Is_Kit__c = true);
        insert ps;
        
        Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps2;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(),
                                                  ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Account__c=customer.Id, ERP7__Availability_date__c=system.today(), ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Vendor_Batch_Number__c='test', ERP7__Next_Inspection_Date__c=system.today(), ERP7__Inward_Quantity__c=2,
                                                  ERP7__Outward_Quantity__c=2, ERP7__Active__c=true, ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id);
        insert batch;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WIIS;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id, Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS2.Id,Product__c=ps.Id,Quantity__c=200);
        insert SPLI;
        
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        List<Sales_Order_Line_Item__c > SOLIs2insert  = new List<Sales_Order_Line_Item__c > ();
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
          solim.Quantity__c=1;
        SOLIs2insert.add(solim );
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=4,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10, ERP7__Explode__c=true);
        solim1.Quantity__c=4;
        SOLIs2insert.add(solim1);
        
        insert SOLIs2insert;
       
        
       
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Sales_Order__c=sod.Id, ERP7__Active__c=true,Channel__c=salePoint.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        
        insert Logistic;
        List<ERP7__Logistic_Line_Item__c> log2insert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c=Solim.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        log2insert.add(LogisticLine1);
        
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, ERP7__Sales_Order_Line_Item__c=Solim1.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        log2insert.add(LogisticLine);
       
       PreventRecursiveLedgerEntry.LogisticLineRollup = false;
       insert log2insert;
        test.startTest();
        
        PageReference pg = System.Page.ReceivingLabel;
        pg.getParameters().put('loIds', Logistic.Id);
        pg.getParameters().put('LotId', batch.Id);
        Test.setCurrentPage(pg);
        Receiving_Label rlabel = new Receiving_Label();
        rlabel.createLabel();
        test.stopTest();
        delete LogisticLine;
        delete Logistic;
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        /*User u = new User(Alias = 'standt2', Email='stasndarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing 2', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@tes2torg.com');
        System.runAs(u) {
            PreventRecursiveLedgerEntry.LogisticLineRollup = true; */
           // delete LogisticLine1;
            
        //}
        
        //test.stopTest();
    }
}