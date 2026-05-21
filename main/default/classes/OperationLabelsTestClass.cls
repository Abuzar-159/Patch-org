@isTest
private class OperationLabelsTestClass {
    
 @isTest(seeAllData = true)
    static  void UnitTest() { 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Id userId = UserInfo.getUserId();
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='test', ERP7__First_Name__c='test', ERP7__Last_Name__c='test',
                                                        ERP7__Gender__c='Male', ERP7__Channel__c=salepoint.Id, Employee_User__c =userId);
        insert emp;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id,
                       Barcode__c='Site');
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, 
                                                       
                                                       Channel__c=emp.ERP7__Channel__c, Site__c=site.Id, Priority__c='1', ERP7__Primary__c=true);
        insert DistributionChannels;  
        
        Product2 ps = new Product2(
                                   Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true,Weight__c=2, ERP7__Lot_Tracked__c=true, 
                                   ERP7__Picture__c='https://images-na.ssl-images-amazon.com/images/G/01/img15/furniture/verticalstore/24795_Vertical-Category_DiningTables_Priority1_SmallTile._CB312951036_.jpg');
        insert ps;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Organisation__c=orgn.Id,  ERP7__Available__c=true,
                                                  ERP7__Supplier__c=sup.Id, ERP7__Status__c='Available', ERP7__Active__c=true, ERP7__Model__c='test', ERP7__Capacity__c='test',
                                                  ERP7__Item_Description__c='test');
        insert asset;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps.Id,ERP7__Active__c=true);
        insert batch1;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                  Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
                                           Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                   Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                     Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                   Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS2;     
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, ERP7__Is_Closed__c=false,
                   WO_Supplier__c = sup.Id, Barcode__c='WO', Status__c='Complete', ERP7__Ready_To_Pick_Pack__c=true, Expected_Date__c=system.today());
        insert wo;
        Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c( Asset__c=asset.Id,
                                        Work_Orders__c = wo.Id, Quantity__c = 2, Picked_Quantity__c = 1, ERP7__Product__c=ps.Id, ERP7__Batch_Lot_Code__c='test', ERP7__Quantity__c=10);
        insert woli;  
        Package__c pack = new Package__c(Name__c='Test Pack',
                          Work_Order__c=wo.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Work_Order_Line_Items__c = woli.Id,Active__c=true,
                                Work_Orders__c=wo.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Work_Order__c=wo.Id ,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];        
        Package__c pack1 = new Package__c( Name__c='Test Pack',
                           Work_Order__c=wo.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Work_Order_Line_Items__c = woli.Id,Active__c=true,
                                Work_Orders__c=wo.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name='test dispatch line item',
                                          Site_Product_Service_Inventory_Stock__c=WIIS.Id,Picked_Quantity__c = 3,
                                          Product__c = ps.Id,Quantity__c=2,Work_Order_Line_Items__c=woli.Id);
        insert sdli;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='test', ERP7__Work_Order__c=WO.Id, ERP7__Ready_For_Dispatch__c=true);
        insert mrp;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Availability_date__c=system.today(), ERP7__Active__c=true,
                                                  ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id, ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Inward_Quantity__c=2, ERP7__Outward_Quantity__c=2);
        insert batch;
        
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c(Name='test', ERP7__Site_ProductService_InventoryStock__c=WIIS2.Id);//ERP7__Batch_Lot_Code__c='test',ERP7__Material_Batch_Lot__c=batch.Id
                                                                                    
        insert sili;
        
        String workorderId = wo.Id;
        
        
        PageReference pageRef11 = System.Page.MOLabel;
        pageRef11.getParameters().put('WId',wo.Id);           
        Test.setCurrentPage(pageRef11);
        ApexPages.StandardController controller;
        OperationLabel ML = new OperationLabel(controller);
        Test.startTest();
        ML.createPDF();
        
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }
     @isTest(seeAllData = true)
    static  void UnitTestMOrderLabel() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Id userId = UserInfo.getUserId();
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='test', ERP7__First_Name__c='test', ERP7__Last_Name__c='test',
                                                        ERP7__Gender__c='Male', ERP7__Channel__c=salepoint.Id, Employee_User__c =userId);
        insert emp;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id,
                       Barcode__c='Site');
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, 
                                                       
                                                       Channel__c=emp.ERP7__Channel__c, Site__c=site.Id, Priority__c='1', ERP7__Primary__c=true);
        insert DistributionChannels;  
        
        Product2 ps = new Product2(
                                   Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true,Weight__c=2, ERP7__Lot_Tracked__c=true, 
                                   ERP7__Picture__c='https://images-na.ssl-images-amazon.com/images/G/01/img15/furniture/verticalstore/24795_Vertical-Category_DiningTables_Priority1_SmallTile._CB312951036_.jpg');
        insert ps;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Organisation__c=orgn.Id,  ERP7__Available__c=true,
                                                  ERP7__Supplier__c=sup.Id, ERP7__Status__c='Available', ERP7__Active__c=true, ERP7__Model__c='test', ERP7__Capacity__c='test',
                                                  ERP7__Item_Description__c='test');
        insert asset;
        
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps.Id,ERP7__Active__c=true);
        insert batch1;
        
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                  Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
                                           Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                   Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                     Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', 
                                   Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id,ERP7__Batch_Lot__c=batch1.Id);
        insert WIIS2;     
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, ERP7__Is_Closed__c=false,
                   WO_Supplier__c = sup.Id, Barcode__c='WO', Status__c='Complete', ERP7__Ready_To_Pick_Pack__c=true, Expected_Date__c=system.today());
        insert wo;
        Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c( Asset__c=asset.Id,
                                        Work_Orders__c = wo.Id, Quantity__c = 2, Picked_Quantity__c = 1, ERP7__Product__c=ps.Id, ERP7__Batch_Lot_Code__c='test', ERP7__Quantity__c=10);
        insert woli;  
        Package__c pack = new Package__c(Name__c='Test Pack',
                          Work_Order__c=wo.Id,Active__c = true,status__c='Deposited to front desk');
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Work_Order_Line_Items__c = woli.Id,Active__c=true,
                                Work_Orders__c=wo.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Work_Order__c=wo.Id ,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];        
        Package__c pack1 = new Package__c( Name__c='Test Pack',
                           Work_Order__c=wo.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Work_Order_Line_Items__c = woli.Id,Active__c=true,
                                Work_Orders__c=wo.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name='test dispatch line item',
                                          Site_Product_Service_Inventory_Stock__c=WIIS.Id,Picked_Quantity__c = 3,
                                          Product__c = ps.Id,Quantity__c=2,Work_Order_Line_Items__c=woli.Id);
        insert sdli;
        
        ERP7__MRP__c mrp = new ERP7__MRP__c(Name='test', ERP7__Work_Order__c=WO.Id, ERP7__Ready_For_Dispatch__c=true);
        insert mrp;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(Name='test', ERP7__Availability_date__c=system.today(), ERP7__Active__c=true,
                                                  ERP7__Date_of_Manufacture__c=system.today(), ERP7__Asset__c=asset.Id, ERP7__Shelf_Life_Expiration_Date__c=system.today(),
                                                  ERP7__Inward_Quantity__c=2, ERP7__Outward_Quantity__c=2);
        insert batch;
        
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c(Name='test', ERP7__Site_ProductService_InventoryStock__c=WIIS2.Id
                                                                                   );//ERP7__Batch_Lot_Code__c='test', ERP7__Material_Batch_Lot__c=batch.Id
        insert sili;
        ERP7__Version__c version = new ERP7__Version__c(Name='Test', ERP7__Product__c=ps.Id);
        insert version;
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name='Test', ERP7__Product__c=version.ERP7__Product__c, ERP7__Version__c=version.Id, ERP7__Quantity__c=1, ERP7__StartDate__c=system.today(), ERP7__End_Date__c=system.today());
        insert MO;
        String mOrderId = MO.Id;
        
        
        PageReference pageRef11 = System.Page.MOrderLabel;
        pageRef11.getParameters().put('MId',MO.Id);           
        Test.setCurrentPage(pageRef11);
        ApexPages.StandardController controller;
        MOrderLabel MOL = new MOrderLabel(controller);
        Test.startTest();
        MOL.createPDF();
        
        System.assertEquals('test@test.com',contact.Email);        
        Test.stopTest();
    }
    
}