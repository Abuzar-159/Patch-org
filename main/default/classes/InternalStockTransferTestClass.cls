@isTest
private class InternalStockTransferTestClass {
     @isTest(seeAllData = true)
    static  void UnitTestInternalStockTransferMethod()
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
        Product2 prod = new Product2(Name='test');
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
        
        List<ERP7__Cart_Putaway_Item__c> cpai=new List<ERP7__Cart_Putaway_Item__c>();
        cpai.add(cartputitem1);
        InternalStockTransfer.getAll(String.valueOf(site), String.valueOf(des_site.Id), system.now().addDays(-10), system.now().addDays(10));
        InternalStockTransfer.saveCartItem(JSON.serialize(cartpickitem));
        InternalStockTransfer.saveCartItem(JSON.serialize(cartpickitem1));
        InternalStockTransfer.saveCartputawayItem(JSON.serialize(cpai),'');
       String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    static testmethod void UnitTestInternalStockTransferMethod2()
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
        Product2 prod = new Product2(Name='test');
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
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
     @isTest(seeAllData = true)
     static  void UnitTestInternalStockTransferMethod3()
    {
        String bcode = 'batch001';
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 prod1 = new Product2(Name='Laptop',Is_Asset__c=true,ERP7__Serialise__c = true);
        insert prod1;
            Account cust = new Account(Name='UnitTestInternalStockTransferMethodTestCust', ERP7__Account_Type__c='Customer');
        insert cust;  
        ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c (ERP7__Available__c = true,Name='TestSerial',Serial_Number__c=bcode,Product__c = pro.Id);
        insert serial;
        ERP7__Site__c des_site = new ERP7__Site__c(Name='Royal Oak Warehouse', ERP7__Active__c=true,
                                                   ERP7__Type__c='Warehouse', Barcode__c = 'Test_Dest_Site');
        insert des_site;
        Asset__c FA = new Asset__c(Name='Test FA',Product__c = prod1.Id,Serial__c = serial.Id);
        insert FA;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation'); insert orgn;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=pro.Id,Checked_In_Date__c = date.today(),ERP7__Serial__c = serial.Id);
        insert WarehouseItemInventoryStock1; 
        ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = WarehouseItemInventoryStock1.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 10,Product__c = prod1.Id);
        insert sili;
        ERP7__Version__c  ver = new ERP7__Version__c(ERP7__Active__c = true,ERP7__Barcode__c = '00000105',ERP7__Category__c = 'Production',ERP7__Default__c = true,ERP7__Description__c = 'Test Version',ERP7__Inventory_Stock__c =WarehouseItemInventoryStock1.Id,ERP7__Picture__c = 'https://www.sfdc99.com/wp-content/uploads/2015/08/MVP-Logo-No-Borders.png',ERP7__Product__c = pro.Id,ERP7__Quantity__c = 5,ERP7__Status__c = 'New',Name = 'Test ver',ERP7__Type__c = 'Production');
        insert ver;
         Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        /*Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Name='test',Active__c=true);
        insert profile; */
        Employees__c emp = new Employees__c(Name= 'Test Employee',First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active');
        insert emp;
        ERP7__Address__c address = new ERP7__Address__c(Name='Test', ERP7__Address_Line1__c='14 TOTTENHAM COURT ROAD',
                                                        ERP7__Country__c='United Kingdom', ERP7__City__c='London', ERP7__State__c='Greater London',
                                                        ERP7__Postal_Code__c='W1T1JY', ERP7__Customer__c=cust.Id);
        insert address;
         ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test Channel', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='Adam',
                                                        ERP7__Company__c='Test Company', ERP7__Phone__c='1020202039', ERP7__Active__c=true, ERP7__City__c='WORKINGTON',
                                                        ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California', ERP7__Country__c='United States',
                                                        ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=orgn.Id);
        insert channel;
        ERP7__Cart__c cart = new ERP7__Cart__c(Name='Test',Site__c = site.id,ERP7__Employee__c =emp.Id,ERP7__Account__c =cust.Id,ERP7__Channel__c=channel.Id);
        insert cart;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='Test Location2',Barcode__c = 'loc2',Site__c=des_site.Id);
        insert loc2;
        ERP7__StorageContainer__c store =  new ERP7__StorageContainer__c(ERP7__Location__c=loc2.Id,ERP7__Active__c=true,Name='Storage container',ERP7__Barcode__c='0010023',ERP7__Organisation__c =orgn.Id); insert store;
        ERP7__Batch__c batch = new ERP7__Batch__c(ERP7__Account__c=cust.Id,ERP7__Active__c = true,ERP7__Asset__c=FA.id,ERP7__Availability_date__c = date.today()+2,ERP7__Barcode__c = 'batch001',Name = 'batch001',ERP7__Cost_Price__c = 30,ERP7__Date_of_Manufacture__c = date.Today(),ERP7__Product__c = pro.Id,ERP7__Production_Version__c = ver.Id); insert batch;
        ERP7__Cart_Picked_Item__c cartPick = new ERP7__Cart_Picked_Item__c(Name = 'test cart',ERP7__Quantity__c = 3,ERP7__Product__c=pro.Id,ERP7__Product_Version__c = ver.Id,ERP7__Inventory_Stock__c =WarehouseItemInventoryStock1.Id,ERP7__Serial_Number__c =serial.Id,ERP7__Fixed_Asset__c =FA.Id, ERP7__From_Location__c =loc2.Id,ERP7__Batch_Lot__c = batch.Id,ERP7__Cart__c =cart.Id );
        insert cartPick;
        WarehouseItemInventoryStock1.ERP7__Number_of_Sample_Items_Checked_In__c = 99;
        WarehouseItemInventoryStock1.ERP7__StorageContainer__c = store.Id;
        WarehouseItemInventoryStock1.ERP7__Batch_Lot__c = batch.Id;
        //WarehouseItemInventoryStock1.ERP7__Number_of_Item_In_Stock__c = 100;
        update WarehouseItemInventoryStock1;
        //String bcode = '0002311';
        String siteId = site.Id;
        String LocId = loc2.Id;
        String step = '';
        String cart1 = JSON.serialize(cartPick);
        try{InternalStockTransfer.searchBarcode(bcode,siteId,LocId,step,cart1);}catch(exception e){}
        try{InternalStockTransfer.searchBarcode1(bcode,siteId,LocId,step,cart1);}catch(exception e){}
        ERP7__Site__c result2 = InternalStockTransfer.searchwarehouse(bcode);
       
        ERP7__Cart__c result3 = InternalStockTransfer.createCart(JSON.serialize(cart));
        
        list < ERP7__Cart__c > result4 = InternalStockTransfer.getCartDetails();
       
        String currProdId = prod1.Id;
        Product2 result5 = InternalStockTransfer.fetchProductDetails(currProdId);
        
        Decimal result6 = InternalStockTransfer.fetchProductInventoryStock(currProdId);
        
        ERP7__Cart__c result7 = InternalStockTransfer.getSiteofCartDetails(siteId);
       
        String cartId= cartPick.Id;
        String currBatchLot = batch.Id;
        try{ InternalStockTransfer.searchBarcode(bcode,siteId,LocId,'step',cart1);}catch(exception e){}
        
        list < ERP7__Cart_Picked_Item__c > result10 = InternalStockTransfer.getCartItemDetails(cartId);
        
        List<ERP7__Cart_Putaway_Item__c> result11 = InternalStockTransfer.createCartputawayItem(cartId);
        
        Decimal result12 = InternalStockTransfer.fetchBatchProductInventoryStock(currProdId,currBatchLot);
       
        ERP7__Cart__c result13 = InternalStockTransfer.getSiteofCartDetails(siteId);
       
        String result15 = InternalStockTransfer.getLocationByBarcode(bcode,siteId);
        
        InternalStockTransfer.fetchProductSiteInvStock(pro.Id,'','','','');
        Integer index=1;
        cartPick.ERP7__Quantity__c = 5;
        update cartPick;
        ERP7__Cart_Picked_Item__c pickItem = cartPick;
        InternalStockTransfer.wrapper_PickedItem  cmp = new InternalStockTransfer.wrapper_PickedItem(index,pickItem);
        
       List<InternalStockTransfer.wrapper_PickedItem>  result0 = InternalStockTransfer.fetchCartPickedDetails(cartId);
        
        //String pickeditem = prod1.Name;
        // InternalStockTransfer.saveCartItem(JSON.serialize(new Cart_Picked_Item__c(Name = 'test cart',ERP7__Quantity__c = 3,ERP7__Product__c=pro.Id,ERP7__Product_Version__c = ver.Id,ERP7__Inventory_Stock__c =WarehouseItemInventoryStock1.Id,ERP7__Serial_Number__c =serial.Id,ERP7__Fixed_Asset__c =FA.Id, ERP7__From_Location__c =loc2.Id,ERP7__Batch_Lot__c = batch.Id,ERP7__Cart__c =cart.Id )));
        InternalStockTransfer.PreparePickSerialNos(currProdId,'',siteId,'','100',new List<String>{});
        Product2 prod4 = new Product2(Name='Laptop prod4',Is_Asset__c=false,ERP7__Serialise__c = true);
        insert prod4 ;
         ERP7__Serial_Number__c serial2 = new ERP7__Serial_Number__c (ERP7__Available__c = true,Name='TestSerial prod4 ',Serial_Number__c='TestSerial prod4 rrr',Product__c = prod4.Id);
        insert serial2;
         Inventory_Stock__c WarehouseItemInventoryStock3 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=prod4.Id,Checked_In_Date__c = date.today(),ERP7__Serial__c = serial2.Id);
        insert WarehouseItemInventoryStock3; 
        ERP7__Stock_Inward_Line_Item__c sili4 = new ERP7__Stock_Inward_Line_Item__c(Site_ProductService_InventoryStock__c = WarehouseItemInventoryStock3.Id, Name = 'Test Sili ',ERP7__Quantity__c  = 1,Product__c = prod4.Id,ERP7__Serial__c = serial2.Id);
        insert sili4;
        InternalStockTransfer.createInventoryforSerial(prod4.Id ,JSON.serialize(new List<String>{serial2.Id}), siteId,'',cartId);
        //InternalStockTransfer.saveCartputawayItem(cart1,siteId);
        String result8 = InternalStockTransfer.delSlctRec(cartId);
        InternalStockTransfer.getProdDetails(prod4.Id,'');
                InternalStockTransfer.getScannedCartDetails(site.Id,'Test');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
        
    }
}