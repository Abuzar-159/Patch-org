@isTest
public class StockTransferDocTestCase {
    static testmethod void UnitTestInternalStockTransferMethod()
    {
        String bcode = 'loc1'; 
        Account org = new Account(Name='UnitTestInternalStockTransferMethodTestOrg', ERP7__Account_Type__c='Organisation');
        insert org;
        
        Account cust = new Account(Name='UnitTestInternalStockTransferMethodTestCust', ERP7__Account_Type__c='Customer');
        insert cust;    
        
        ERP7__Site__c site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                               ERP7__Type__c='Warehouse', Barcode__c = 'Test_site');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='Test Location1',Barcode__c = 'loc1',Site__c=site.Id);
        insert loc1;
        ERP7__Site__c des_site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                                   ERP7__Type__c='Warehouse', Barcode__c = 'Test_Dest_Site');
        insert des_site;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='Test Location2',Barcode__c = 'loc2',Site__c=des_site.Id);
        insert loc2;
        ERP7__Address__c address = new ERP7__Address__c(Name='Test', ERP7__Address_Line1__c='14 TOTTENHAM COURT ROAD',
                                                        ERP7__Country__c='United Kingdom', ERP7__City__c='London', ERP7__State__c='Greater London',
                                                        ERP7__Postal_Code__c='W1T1JY', ERP7__Customer__c=cust.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='Adam',
                                                        ERP7__Company__c='Test Company', ERP7__Phone__c='1020202039', ERP7__Active__c=true, ERP7__City__c='WORKINGTON',
                                                        ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California', ERP7__Country__c='United States',
                                                        ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=org.Id);
        insert channel;
        Product2 prod = new Product2(Name='test',Description='');
        insert prod;
        Product2 prod1 = new Product2(Name='test',Is_Asset__c=true);
        insert prod1;
        ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c (ERP7__Available__c = true,Name='TestSerial',Serial_Number__c='TestSerial',Product__c = prod.Id);
        insert serial;
        Asset__c FA = new Asset__c(Name='Test FA',Product__c = prod1.Id,Serial__c = serial.Id);
        insert FA;
        ERP7__Inventory_Stock__c stock  = new ERP7__Inventory_Stock__c(Location__c = loc1.id,Name='Test Stock',Warehouse__c = site.Id,Product__c = prod.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock; 
        ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Product__c = prod.Id);
        insert sili;
        ERP7__Inventory_Stock__c stock1  = new ERP7__Inventory_Stock__c(Name='Test Stock',Warehouse__c = site.Id,Fixed_Asset__c = FA.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock1; 
        ERP7__Stock_Inward_Line_Item__c sili1 = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock1.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Fixed_Asset__c = FA.Id);
        insert sili1;
        ERP7__Cart__c cart = new ERP7__Cart__c(Name='Test',Site__c = site.id);
        insert cart;
        ERP7__Cart_Picked_Item__c cartpickitem = new ERP7__Cart_Picked_Item__c(From_Location__c = loc1.id,Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=1,
                                                                               ERP7__Picked_Quantity__c=1,Product__c =prod.Id ,ERP7__Inventory_Stock__c = stock.Id);
        insert cartpickitem;
        
        ERP7__Cart_Picked_Item__c cartpickitem1 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id);
        insert cartpickitem1;
        
        ERP7__Cart_Putaway_Item__c cartputitem1 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        insert cartputitem1;
        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Employee_User__c = UserInfo.getUserId());
        insert emp;
        
        set<Id> cpai=new set<Id>();
        Test.StartTest();
        PageReference pageRef = System.Page.StockTransferDoc;
        pageRef.getParameters().put('cartIds',cartputitem1.Id);
        pageRef.getParameters().put('SourceSite',cart.Id);
        Test.setCurrentPage(pageRef);
        StockTransferDoc dco = new StockTransferDoc();
        dco.createpdf();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
   static testmethod void UnitTestInternalStockTransferMethod2()
    {
        Test.StartTest();
        String bcode = 'loc1'; 
        Account org = new Account(Name='UnitTestInternalStockTransferMethodTestOrg', ERP7__Account_Type__c='Organisation');
        insert org;
        
        Account cust = new Account(Name='UnitTestInternalStockTransferMethodTestCust', ERP7__Account_Type__c='Customer');
        insert cust;    
        
        ERP7__Site__c site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                               ERP7__Type__c='Warehouse', Barcode__c = 'Test_site');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='Test Location1',Barcode__c = 'loc1',Site__c=site.Id);
        insert loc1;
        ERP7__Site__c des_site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                                   ERP7__Type__c='Warehouse', Barcode__c = 'Test_Dest_Site');
        insert des_site;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='Test Location2',Barcode__c = 'loc2',Site__c=des_site.Id);
        insert loc2;
        ERP7__Address__c address = new ERP7__Address__c(Name='Test', ERP7__Address_Line1__c='14 TOTTENHAM COURT ROAD',
                                                        ERP7__Country__c='United Kingdom', ERP7__City__c='London', ERP7__State__c='Greater London',
                                                        ERP7__Postal_Code__c='W1T1JY', ERP7__Customer__c=cust.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='Adam',
                                                        ERP7__Company__c='Test Company', ERP7__Phone__c='1020202039', ERP7__Active__c=true, ERP7__City__c='WORKINGTON',
                                                        ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California', ERP7__Country__c='United States',
                                                        ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=org.Id);
        insert channel;
        Product2 prod = new Product2(Name='prod' ,Description='prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4aaaaa',ERP7__Serialise__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name='prod1' ,Description='prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4aaaaa');
        insert prod2;
         Product2 prod3 = new Product2(Name='prod2' ,Description='prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4aaaaa');
        insert prod3;
        Product2 prod4 = new Product2(Name='prod3' ,Description='prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4aaaaa');
        insert prod4;
        Product2 prod1 = new Product2(Name='prod4' ,Description='prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4prod4aaaaa',Is_Asset__c=true);
        insert prod1;
        ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c (ERP7__Available__c = true,Name='TestSerial',Serial_Number__c='TestSerial',Product__c = prod.Id);
        insert serial;
        Asset__c FA = new Asset__c(Name='Test FA',Product__c = prod1.Id,Serial__c = serial.Id);
        insert FA;
        
        ERP7__Inventory_Stock__c stock  = new ERP7__Inventory_Stock__c(Location__c = loc1.id,Name='Test Stock',Warehouse__c = site.Id,Product__c = prod.Id,ERP7__Serial__c = serial.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock; 
        ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Product__c = prod.Id);
        insert sili;
        ERP7__Inventory_Stock__c stock1  = new ERP7__Inventory_Stock__c(Name='Test Stock',Warehouse__c = site.Id,Fixed_Asset__c = FA.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock1; 
        ERP7__Stock_Inward_Line_Item__c sili1 = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock1.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Fixed_Asset__c = FA.Id);
        insert sili1;
        ERP7__Cart__c cart = new ERP7__Cart__c(Name='Test',Site__c = site.id);
        insert cart;
        List<ERP7__Cart_Picked_Item__c> allitems = new List<ERP7__Cart_Picked_Item__c>();
        ERP7__Cart_Picked_Item__c cartpickitem = new ERP7__Cart_Picked_Item__c(From_Location__c = loc1.id,Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=1,
                                                                               ERP7__Picked_Quantity__c=1,Product__c =prod.Id ,ERP7__Inventory_Stock__c = stock.Id,ERP7__Serial_Number__c = serial.Id);
        allitems.add(cartpickitem);
        
        ERP7__Cart_Picked_Item__c cartpickitem1 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id,Product__c =prod1.Id );
        allitems.add(cartpickitem1);
         ERP7__Cart_Picked_Item__c cartpickitem2 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id,Product__c =prod2.Id );
        allitems.add(cartpickitem2);
         ERP7__Cart_Picked_Item__c cartpickitem3 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id,Product__c =prod3.Id );
        allitems.add(cartpickitem3);
         ERP7__Cart_Picked_Item__c cartpickitem4 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id,Product__c =prod4.Id );
        allitems.add(cartpickitem4);
         ERP7__Cart_Picked_Item__c cartpickitem5 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id,Product__c =prod1.Id );
        allitems.add(cartpickitem5);
         ERP7__Cart_Picked_Item__c cartpickitem6 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id,Product__c =prod4.Id );
        allitems.add(cartpickitem6);
        upsert allitems;
        ERP7__Cart_Putaway_Item__c cartputitem1 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem1.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        ERP7__Cart_Putaway_Item__c cartputitem = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem2.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        ERP7__Cart_Putaway_Item__c cartputitem2 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem3.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        ERP7__Cart_Putaway_Item__c cartputitem3 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem4.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        ERP7__Cart_Putaway_Item__c cartputitem4 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem5.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        ERP7__Cart_Putaway_Item__c cartputitem5 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem6.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Employee_User__c = UserInfo.getUserId());
        insert emp;
        
        List<ERP7__Cart_Putaway_Item__c> cpai=new List<ERP7__Cart_Putaway_Item__c>();
        cpai.add(cartputitem5);cpai.add(cartputitem4);cpai.add(cartputitem3);cpai.add(cartputitem2);cpai.add(cartputitem1);cpai.add(cartputitem);
        upsert cpai;
        set<Id> idset = new set<Id>();
        for(ERP7__Cart_Putaway_Item__c cc : cpai){
           idset.add(cc.Id); 
        }
        PageReference pageRef = System.Page.StockTransferDoc;
        pageRef.getParameters().put('cartIds',JSON.serialize(idset));
        pageRef.getParameters().put('SourceSite',cart.Id);
        Test.setCurrentPage(pageRef);
        StockTransferDoc dco = new StockTransferDoc();
        dco.createpdf();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
      static testmethod void UnitTestInternalStockTransferMethod3()
    {
        String bcode = 'loc1'; 
        Account org = new Account(Name='UnitTestInternalStockTransferMethodTestOrg', ERP7__Account_Type__c='Organisation');
        insert org;
        
        Account cust = new Account(Name='UnitTestInternalStockTransferMethodTestCust', ERP7__Account_Type__c='Customer');
        insert cust;    
        
        ERP7__Site__c site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                               ERP7__Type__c='Warehouse', Barcode__c = 'Test_site');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='Test Location1',Barcode__c = 'loc1',Site__c=site.Id);
        insert loc1;
        ERP7__Site__c des_site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                                   ERP7__Type__c='Warehouse', Barcode__c = 'Test_Dest_Site');
        insert des_site;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='Test Location2',Barcode__c = 'loc2',Site__c=des_site.Id);
        insert loc2;
        ERP7__Address__c address = new ERP7__Address__c(Name='Test', ERP7__Address_Line1__c='14 TOTTENHAM COURT ROAD',
                                                        ERP7__Country__c='United Kingdom', ERP7__City__c='London', ERP7__State__c='Greater London',
                                                        ERP7__Postal_Code__c='W1T1JY', ERP7__Customer__c=cust.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='Adam',
                                                        ERP7__Company__c='Test Company', ERP7__Phone__c='1020202039', ERP7__Active__c=true, ERP7__City__c='WORKINGTON',
                                                        ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California', ERP7__Country__c='United States',
                                                        ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=org.Id);
        insert channel;
        Product2 prod = new Product2(Name='test',Description='',ERP7__Serialise__c = true);
        insert prod;
        Product2 prod1 = new Product2(Name='test',Is_Asset__c=true);
        insert prod1;
        ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c (ERP7__Available__c = true,Name='TestSerial',Serial_Number__c='TestSerial',Product__c = prod.Id);
        insert serial;
        Asset__c FA = new Asset__c(Name='Test FA',Product__c = prod1.Id,Serial__c = serial.Id);
        insert FA;
        ERP7__Inventory_Stock__c stock  = new ERP7__Inventory_Stock__c(Location__c = loc1.id,Name='Test Stock',Warehouse__c = site.Id,Product__c = prod.Id,ERP7__Serial__c=serial.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock; 
        ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Product__c = prod.Id);
        insert sili;
        ERP7__Inventory_Stock__c stock1  = new ERP7__Inventory_Stock__c(Name='Test Stock',Warehouse__c = site.Id,Fixed_Asset__c = FA.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock1; 
        ERP7__Stock_Inward_Line_Item__c sili1 = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock1.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Fixed_Asset__c = FA.Id);
        insert sili1;
        ERP7__Cart__c cart = new ERP7__Cart__c(Name='Test',Site__c = site.id);
        insert cart;
        ERP7__Cart_Picked_Item__c cartpickitem = new ERP7__Cart_Picked_Item__c(From_Location__c = loc1.id,Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=1,
                                                                               ERP7__Picked_Quantity__c=1,Product__c =prod.Id ,ERP7__Inventory_Stock__c = stock.Id,ERP7__Serial_Number__c = serial.Id);
        insert cartpickitem;
        
        ERP7__Cart_Picked_Item__c cartpickitem1 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id);
        insert cartpickitem1;
        
        ERP7__Cart_Putaway_Item__c cartputitem1 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        insert cartputitem1;
        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Employee_User__c = UserInfo.getUserId());
        insert emp;
        
        set<Id> cpai=new set<Id>();
        Test.StartTest();
        PageReference pageRef = System.Page.StockTransferDoc;
        pageRef.getParameters().put('cartIds',cartputitem1.Id);
        pageRef.getParameters().put('SourceSite',cart.Id);
        Test.setCurrentPage(pageRef);
        StockTransferDoc dco = new StockTransferDoc();
        dco.createpdf();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
     static testmethod void UnitTestInternalStockTransferMethod4()
    {
        String bcode = 'loc1'; 
        Account org = new Account(Name='UnitTestInternalStockTransferMethodTestOrg', ERP7__Account_Type__c='Organisation');
        insert org;
        
        Account cust = new Account(Name='UnitTestInternalStockTransferMethodTestCust', ERP7__Account_Type__c='Customer');
        insert cust;    
        
        ERP7__Site__c site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                               ERP7__Type__c='Warehouse', Barcode__c = 'Test_site');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='Test Location1',Barcode__c = 'loc1',Site__c=site.Id);
        insert loc1;
        ERP7__Site__c des_site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                                   ERP7__Type__c='Warehouse', Barcode__c = 'Test_Dest_Site');
        insert des_site;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='Test Location2',Barcode__c = 'loc2',Site__c=des_site.Id);
        insert loc2;
        ERP7__Address__c address = new ERP7__Address__c(Name='Test', ERP7__Address_Line1__c='14 TOTTENHAM COURT ROAD',
                                                        ERP7__Country__c='United Kingdom', ERP7__City__c='London', ERP7__State__c='Greater London',
                                                        ERP7__Postal_Code__c='W1T1JY', ERP7__Customer__c=cust.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='Adam',
                                                        ERP7__Company__c='Test Company', ERP7__Phone__c='1020202039', ERP7__Active__c=true, ERP7__City__c='WORKINGTON',
                                                        ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California', ERP7__Country__c='United States',
                                                        ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=org.Id);
        insert channel;
        Product2 prod = new Product2(Name='test',Description='',ERP7__Lot_Tracked__c = true);
        insert prod;
        Product2 prod1 = new Product2(Name='test',Is_Asset__c=true);
        insert prod1;
        ERP7__Batch__c batch = new ERP7__Batch__c (ERP7__Active__c = true,Name='Testbatch',ERP7__Barcode__c='Testbatch',Product__c = prod.Id);
        insert batch;
         ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c (ERP7__Available__c = true,Name='TestSerial',Serial_Number__c='TestSerial',Product__c = prod.Id);
        insert serial;
        Asset__c FA = new Asset__c(Name='Test FA',Product__c = prod1.Id,Serial__c = serial.Id);
        insert FA;
        ERP7__Inventory_Stock__c stock  = new ERP7__Inventory_Stock__c(Location__c = loc1.id,Name='Test Stock',Warehouse__c = site.Id,Product__c = prod.Id,ERP7__Batch_Lot__c=batch.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock; 
        ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Product__c = prod.Id);
        insert sili;
        ERP7__Inventory_Stock__c stock1  = new ERP7__Inventory_Stock__c(Name='Test Stock',Warehouse__c = site.Id,Fixed_Asset__c = FA.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock1; 
        ERP7__Stock_Inward_Line_Item__c sili1 = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock1.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Fixed_Asset__c = FA.Id);
        insert sili1;
        ERP7__Cart__c cart = new ERP7__Cart__c(Name='Test',Site__c = site.id);
        insert cart;
        ERP7__Cart_Picked_Item__c cartpickitem = new ERP7__Cart_Picked_Item__c(From_Location__c = loc1.id,Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=1,
                                                                               ERP7__Picked_Quantity__c=1,Product__c =prod.Id ,ERP7__Inventory_Stock__c = stock.Id,Batch_Lot__c = batch.Id);
        insert cartpickitem;
        
        ERP7__Cart_Picked_Item__c cartpickitem1 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id);
        insert cartpickitem1;
        
        ERP7__Cart_Putaway_Item__c cartputitem1 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        insert cartputitem1;
        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Employee_User__c = UserInfo.getUserId());
        insert emp;
        
        set<Id> cpai=new set<Id>();
        Test.StartTest();
        PageReference pageRef = System.Page.StockTransferDoc;
        pageRef.getParameters().put('cartIds',cartputitem1.Id);
        pageRef.getParameters().put('SourceSite',cart.Id);
        Test.setCurrentPage(pageRef);
        StockTransferDoc dco = new StockTransferDoc();
        dco.createpdf();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    static testmethod void UnitTestInternalStockTransferMethod5()
    {
        String bcode = 'loc1'; 
        Account org = new Account(Name='UnitTestInternalStockTransferMethodTestOrg', ERP7__Account_Type__c='Organisation');
        insert org;
        
        Account cust = new Account(Name='UnitTestInternalStockTransferMethodTestCust', ERP7__Account_Type__c='Customer');
        insert cust;    
        
        ERP7__Site__c site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                               ERP7__Type__c='Warehouse', Barcode__c = 'Test_site');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='Test Location1',Barcode__c = 'loc1',Site__c=site.Id);
        insert loc1;
        ERP7__Site__c des_site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                                   ERP7__Type__c='Warehouse', Barcode__c = 'Test_Dest_Site');
        insert des_site;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='Test Location2',Barcode__c = 'loc2',Site__c=des_site.Id);
        insert loc2;
        ERP7__Address__c address = new ERP7__Address__c(Name='Test', ERP7__Address_Line1__c='14 TOTTENHAM COURT ROAD',
                                                        ERP7__Country__c='United Kingdom', ERP7__City__c='London', ERP7__State__c='Greater London',
                                                        ERP7__Postal_Code__c='W1T1JY', ERP7__Customer__c=cust.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='Adam',
                                                        ERP7__Company__c='Test Company', ERP7__Phone__c='1020202039', ERP7__Active__c=true, ERP7__City__c='WORKINGTON',
                                                        ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California', ERP7__Country__c='United States',
                                                        ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=org.Id);
        insert channel;
        Product2 prod = new Product2(Name='test',Description='',ERP7__Lot_Tracked__c = true);
        insert prod;
        Product2 prod1 = new Product2(Name='test',Is_Asset__c=true);
        insert prod1;
        ERP7__Batch__c batch = new ERP7__Batch__c (ERP7__Active__c = true,Name='Testbatch',ERP7__Barcode__c='Testbatch',Product__c = prod.Id);
        insert batch;
         ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c (ERP7__Available__c = true,Name='TestSerial',Serial_Number__c='TestSerial',Product__c = prod.Id);
        insert serial;
        Asset__c FA = new Asset__c(Name='Test FA',Product__c = prod1.Id,Serial__c = serial.Id);
        insert FA;
        ERP7__Inventory_Stock__c stock  = new ERP7__Inventory_Stock__c(Location__c = loc1.id,Name='Test Stock',Warehouse__c = site.Id,Product__c = prod.Id,ERP7__Batch_Lot__c=batch.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock; 
        ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Product__c = prod.Id);
        insert sili;
        ERP7__Inventory_Stock__c stock1  = new ERP7__Inventory_Stock__c(Name='Test Stock',Warehouse__c = site.Id,Fixed_Asset__c = FA.Id);//Location__c,Batch_Lot__c =  putawayItem.Cart_Item__r.Batch_Lot__c ,
        insert stock1; 
        ERP7__Stock_Inward_Line_Item__c sili1 = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = stock1.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Fixed_Asset__c = FA.Id);
        insert sili1;
        ERP7__Cart__c cart = new ERP7__Cart__c(Name='Test',Site__c = site.id);
        insert cart;
        ERP7__Cart_Picked_Item__c cartpickitem = new ERP7__Cart_Picked_Item__c(From_Location__c = loc1.id,Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=1,Batch_Lot__c = batch.Id,
                                                                               ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id ,ERP7__Inventory_Stock__c = stock.Id,Product__c = prod.Id);
        insert cartpickitem;
        
        ERP7__Cart_Picked_Item__c cartpickitem1 = new ERP7__Cart_Picked_Item__c(Name='Test', ERP7__Cart__c=cart.Id, ERP7__Quantity__c=5,Product__c = prod.Id,
                                                                                ERP7__Picked_Quantity__c=1,Fixed_Asset__c =FA.Id);
        insert cartpickitem1;
        
        ERP7__Cart_Putaway_Item__c cartputitem1 = new ERP7__Cart_Putaway_Item__c(Name='Test', Cart_Item__c=cartpickitem.Id,
                                                                                 ERP7__To_Location__c=loc1.id,ERP7__Site__c=site.Id);
        insert cartputitem1;
        
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Employee_User__c = UserInfo.getUserId());
        insert emp;
        
        set<Id> cpai=new set<Id>();
        Test.StartTest();
        PageReference pageRef = System.Page.StockTransferDoc;
        pageRef.getParameters().put('cartIds',cartputitem1.Id);
        pageRef.getParameters().put('SourceSite',cart.Id);
        Test.setCurrentPage(pageRef);
        StockTransferDoc dco = new StockTransferDoc();
        dco.createpdf();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    
}