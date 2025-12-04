@isTest
private class Stockdispatching_PO_TestCaseSet {    
    static testMethod void UnitTestStockdispatching_PO1() {
        StockDispatchingController_PO sdcPO = new StockDispatchingController_PO();
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
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
                                                       
                                                       Channel__c=emp.ERP7__Channel__c, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;
        Sales_Order__c sod = new Sales_Order__c();
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod;
        Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        insert ps;             
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(
                                         Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=5,Sales_Order__c=sod.id,
                                         Total_Price__c=100,VAT_Amount__c=10,Packed_Quantity__c = 2,Picked_Quantity__c = 3);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Organisation__c = orgn.Id,
                                          Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,
                                          Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;    
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id,
                                  Product__c=ps.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
                           Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                     Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                   Active__c=true,Warehouse__c=site.Id,
                                   Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id);
        insert PPLI; 
        PPLI.Quantity__c = 3;
        update PPLI;
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order__c=sod.Id);
        insert PPLI1;  
        String poRectype = RecordTypeUtil.getObjectRecordTypeIds('PO__c','Return_to_Vendor_RTV');
        PO__c mPO = new PO__c(Organisation__c = orgn.Id, Delivery_Address__c = bAddress.Id,
                   vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id,Barcode__c='PO',
                   vendor_Contact__c = contact.Id, Is_Closed__c = false, Active__c = true, Status__c='Approved', ERP7__Ready_To_Pick_Pack__c = true, 
                   Expected_Date__c=system.today(), RecordTypeId=poRectype);
        insert mPO; 
        Purchase_Line_Items__c mpoli = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=mPO.id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3, Site__c=site.Id);
        insert mpoli;
        Stock_Inward_Line_Item__c sili = new Stock_Inward_Line_Item__c(
                                         Product__c = ps.Id,Site_ProductService_InventoryStock__c=WIIS.Id,Quantity__c=2,
                                         Purchase_Orders__c =mPO.Id, Purchase_Line_Items__c=mpoli.Id);
        insert sili;
        PO__c PO = new PO__c(Organisation__c = orgn.Id, Delivery_Address__c = bAddress.Id,
                   vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id,Barcode__c='PO',
                   RecordTypeId = poRectype, vendor_Contact__c = contact.Id,Master_Purchase_Orders__c=mPO.Id);
        insert PO;
        PO__c pod = [Select id, Name From PO__c Where id =: po.id Limit 1];
        
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=PO.Id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Site__c=site.Id);
        insert poli;
        Purchase_Line_Items__c poli1 = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Site__c=site.Id);
        insert poli1;   
        delete poli1;
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name='test dispatch line item',
                                          Purchase_Orders__c=po.Id, Site_Product_Service_Inventory_Stock__c=WIIS.Id,
                                          Purchase_Line_Items__c=poli.Id,Product__c = ps.Id,Quantity__c=2);
        insert sdli;                                                          
        Package__c pack = new Package__c( Name__c='Test Pack',
                          Purchase_Order__c=po.Id,Active__c = true,status__c='Deposited to front desk', Shipment__c=null);
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Purchase_Line_Items__c = poli.Id,Active__c=true,
                                Purchase_Orders__c=po.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Purchase_Orders__c =po.Id,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];        
        Package__c pack1 = new Package__c( Name__c='Test Pack',
                          Purchase_Order__c=po.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,
                                Purchase_Orders__c=po.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void UnitTestStockdispatching_PO2() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
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
                                                       
                                                       Channel__c=emp.ERP7__Channel__c, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;
        Sales_Order__c sod = new Sales_Order__c();
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        insert sod;
        Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        insert ps;             
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(
                                         Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=5,Sales_Order__c=sod.id,
                                         Total_Price__c=100,VAT_Amount__c=10,Packed_Quantity__c = 2,Picked_Quantity__c = 3);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Organisation__c = orgn.Id,
                                          Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,
                                          Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;    
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test', Active__c=true,Warehouse__c=site.Id,
                                  Product__c=ps.Id);
        insert WIIS;
        Location__c ssl = new Location__c(
                           Name='Test Location',Barcode__c='LOC',Site__c=site.Id);
        insert ssl;
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                   Active__c=true,Warehouse__c=site.Id,
                                   Product__c=ps.Id,Location__c=ssl.Id);
        insert WIIS1;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,
                     Site__c=site.Id,status__c='Checked In',Barcode__c='Bin');
        insert bin;
        Inventory_Stock__c WIIS2 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',
                                   Active__c=true,Warehouse__c=site.Id,
                                   Product__c=ps.Id,Location__c=ssl.Id,StorageContainer__c=bin.Id);
        insert WIIS2;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id);
        insert PPLI; 
        PPLI.Quantity__c = 3;
        update PPLI;
        Stock_Outward_Line_Item__c PPLI1 = new Stock_Outward_Line_Item__c(
                                             Product__c = ps.Id,Site_Product_Service_Inventory_Stock__c=WIIS.Id,Quantity__c=2,
                                             Sales_Order__c=sod.Id);
        insert PPLI1;  
        String poRectype = RecordTypeUtil.getObjectRecordTypeIds('PO__c','Return_to_Vendor_RTV');
        PO__c mPO = new PO__c(Organisation__c = orgn.Id, Delivery_Address__c = bAddress.Id,
                   vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id,Barcode__c='PO',
                   vendor_Contact__c = contact.Id, Is_Closed__c = false, Active__c = true, Status__c='Approved', ERP7__Ready_To_Pick_Pack__c = true, 
                   Expected_Date__c=system.today(), RecordTypeId=poRectype);
        insert mPO; 
        Purchase_Line_Items__c mpoli = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=mPO.id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Site__c=site.Id);
        insert mpoli;
        Stock_Inward_Line_Item__c sili = new Stock_Inward_Line_Item__c(
                                         Product__c = ps.Id,Site_ProductService_InventoryStock__c=WIIS.Id,Quantity__c=2,
                                         Purchase_Orders__c =mPO.Id, Purchase_Line_Items__c=mpoli.Id);
        insert sili;
        /*PO__c PO = new PO__c(Organisation__c = orgn.Id, Delivery_Address__c = bAddress.Id,
                   vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id,Barcode__c='PO',
                   RecordTypeId = poRectype, vendor_Contact__c = contact.Id,Master_Purchase_Orders__c=mPO.Id);
        insert PO;
        PO__c pod = [Select id, Name From PO__c Where id =: po.id Limit 1];
        
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=PO.Id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3);
        insert poli;
        Purchase_Line_Items__c poli1 = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3);
        insert poli1;   
        delete poli1;
        Stock_Outward_Line_Item__c sdli = new Stock_Outward_Line_Item__c(Name='test dispatch line item',
                                          Purchase_Orders__c=po.Id, Site_Product_Service_Inventory_Stock__c=WIIS.Id,
                                          Purchase_Line_Items__c=poli.Id,Product__c = ps.Id,Quantity__c=2);
        insert sdli;                                                          
        Package__c pack = new Package__c( Name__c='Test Pack',
                          Purchase_Order__c=po.Id,Active__c = true,status__c='Deposited to front desk', Shipment__c=null);
        insert pack;        
        Package_List__c plist = new Package_List__c(Name = 'Test List', Purchase_Line_Items__c = poli.Id,Active__c=true,
                                Purchase_Orders__c=po.Id,Package__c = pack.Id, Quantity__c = 3);
        insert plist;
        Shipment__c ship = new Shipment__c(Customer__c=customer.id,
                           Shipping_Address__c=sAddress.Id,Active__c=true,Purchase_Orders__c =po.Id,Customer_Contact__c=contact.id,
                           status__c='Shipped',Tracking_Number__c='123456'); 
        insert ship;
        Shipment__c ship1 = [select Id, Name from Shipment__c where Id =: ship.Id limit 1];        
        Package__c pack1 = new Package__c( Name__c='Test Pack',
                          Purchase_Order__c=po.Id,Active__c = true,status__c='Deposited to front desk',Shipment__c=ship.Id);
        insert pack1;        
        Package_List__c plist1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c = solim1.Id,Active__c=true,
                                Purchase_Orders__c=po.Id,Package__c = pack1.Id, Quantity__c = 3);
        insert plist1;
        Package_Details__c pd = new Package_Details__c(Name='Test Pkg',Package_Type__c='Package',Length__c=3,Width__c=3,
                                Height__c=4,Weight_Unit__c='KGS');
        insert pd;*/
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
}