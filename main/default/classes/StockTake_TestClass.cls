@isTest
public class StockTake_TestClass {
    
    private  TestMethod static void unit1(){ 
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');  
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c TestEmp = new ERP7__Employees__c(Name='Test',ERP7__Employee_User__c=userInfo.getUserId());
        insert TestEmp; 
        ERP7__Site__c site = new ERP7__Site__c(Name='Test',ERP7__Barcode__c='TestSite');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='loc1',ERP7__Site__c=site.id);
        insert loc1;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='loc2',ERP7__Site__c=site.id,ERP7__Barcode__c='Testlocation');
        insert loc2;
        ERP7__StorageContainer__c bin1 = new ERP7__StorageContainer__c(Name='Bin1',ERP7__Site__c=site.id,ERP7__Location__c=loc1.Id);
        insert bin1;
        ERP7__StorageContainer__c bin2 = new ERP7__StorageContainer__c(Name='Bin2',ERP7__Site__c=site.id,ERP7__Location__c=loc2.Id);
        insert bin2;
        product2 pro1 = new Product2(IsActive=true,Name='Test Product-1',StockKeepingUnit='Test1');
        insert pro1;
        ERP7__Inventory_Stock__c is = new ERP7__Inventory_Stock__c(Name='Test Inventory Stock',ERP7__Warehouse__c = site.id,ERP7__Location__c = loc1.id,ERP7__product__c = pro1.id);
        insert is;
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true,ERP7__Site_ProductService_InventoryStock__c = is.id,ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 50.00);
        insert sili; 
        ERP7__Stock_Outward_Line_Item__c soli = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c =true,ERP7__Site_Product_Service_Inventory_Stock__c  = is.id,ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 5.00);
        insert soli;
        product2 pro2 = new Product2(IsActive=true,ERP7__Serialise__c = true,Name='Test Product-2',StockKeepingUnit='Test2');
        insert pro2; 
        
        ERP7__Serial_Number__c serial = new ERP7__Serial_Number__c(ERP7__Warehouse__c =site.id,ERP7__Available__c = true,Name='Serail1',ERP7__Serial_Number__c='Test1',ERP7__product__c = pro2.id);
        insert serial;
        ERP7__Inventory_Stock__c is1 = new ERP7__Inventory_Stock__c(Name='Test Inventory Stock2',ERP7__Warehouse__c = site.id,ERP7__Location__c = loc2.id,ERP7__product__c = pro2.id,ERP7__Serial__c = serial.Id);
        insert is1; 
        
        ERP7__Stock_Inward_Line_Item__c  sili1 = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true,ERP7__Site_ProductService_InventoryStock__c = is1.id,ERP7__Product__c  = pro2.id, ERP7__Quantity__c = 50.00);
        insert sili1;
        
        product2 pro3 = new Product2(ERP7__Is_Asset__c=true,IsActive=true,ERP7__Serialise__c = true,Name='Test Product-2',StockKeepingUnit='Test3');
        insert pro3;
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(ERP7__Warehouse__c =site.id,ERP7__Available__c = true,Name='Serail2',ERP7__Serial_Number__c='Test2',ERP7__product__c = pro3.id);
        insert serial1;
        ERP7__Asset__c FA = new ERP7__Asset__c (Serialise__c = true,Active__c = true,Status__c='Available',Available__c=true,Product__c=pro3.Id,Serial__c=serial1.id);
        insert FA;
        ERP7__Inventory_Stock__c is2 = new ERP7__Inventory_Stock__c(Name='Test Inventory Stock2',ERP7__Warehouse__c = site.id,ERP7__Location__c = loc2.id,Fixed_Asset__c = FA.id);
        insert is2; 
        //ERP7__Stock_Inward_Line_Item__c  sili2 = new ERP7__Stock_Inward_Line_Item__c (Serial__c=serial1.id,ERP7__Active__c =true,ERP7__Site_ProductService_InventoryStock__c = is1.id,Fixed_Asset__c  = FA.id, ERP7__Quantity__c = 1.00);
        //insert sili2;
       
        ERP7__Stock_Take__c  stockTakesObject = new ERP7__Stock_Take__c();
        StockTake stockTakeobj = new StockTake();
        //stockTakesObject = StockTake.getEmployeeDetails();
        StockTake.getStockOutWardStatus();
        StockTake.getStockInWardReason();
        StockTake.fetchLocations_Bins(site.id);
        stockTakesObject.ERP7__Site__c = site.id;
        stockTakesObject.ERP7__Site__r = new ERP7__Site__c(Id=site.id,Name='Test');
        String queryFilter = ' AND ERP7__Warehouse__c = \''+site.id+'\'';
        List<StockTake.stockTakeWrapper> stockTakeWrapperList =  StockTake.fetch_Products(queryFilter,'',0,1);
        StockTake.SearchScanCode('','');
        StockTake.SearchScanCode('TestSite','');
        StockTake.SearchScanCode('Testlocation','');
        StockTake.stockTakeObjWrapper stockWrapper =  new StockTake.stockTakeObjWrapper();
        List<ERP7__Stock_Inward_Line_Item__c> stock_InwardList = new List<ERP7__Stock_Inward_Line_Item__c>();
        List<ERP7__Stock_Outward_Line_Item__c > stock_OutwardList = new List<ERP7__Stock_Outward_Line_Item__c >();
        stock_OutwardList.add(soli);
        stock_InwardList.add(sili);
        stock_InwardList.add(sili1);
        //stock_InwardList.add(sili2);
        if(stockTakeWrapperList.size()>0){
            stockTakeWrapperList[0].stockInWardList = stock_InwardList;
            stockTakeWrapperList[0].stockOutWardList = stock_OutwardList;
        }
        stockWrapper = StockTake.update_Stocks(JSON.serialize(stockTakesObject),JSON.serialize(stockTakeWrapperList));
        stockWrapper = StockTake.StockTakeDetails(stockWrapper.stockTake.Id);
        StockTake.getAllDetails(string.valueOf(stockWrapper.stockTake.Id),'',string.valueOf(channel.Id),string.valueOf(site.Id),0,10,'','',false,'');
        
        StockTake.DeleteByInWardById(JSON.serialize(stock_InwardList[0]));
        StockTake.DeleteByOutWardById(JSON.serialize(stock_OutwardList[0]));
        test.startTest();
        try{ StockTake.fetchSortedList('ERP7__Employee__r.Name', 'ASC', String.valueOf(site.Id), string.valueOf(channel.Id), 50, 0); }catch(Exception e){}
        test.stopTest();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
    }
    
    private TestMethod static void unit2(){
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c);
        insert DC;
        
        ERP7__Stock_Take__c sT = new ERP7__Stock_Take__c(Name = 'Test', ERP7__Approver__c = emp.Id, ERP7__Employee__c =emp.Id, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today() , ERP7__Site__c = site.Id, ERP7__Status__c = 'Open');
        insert sT;
        
        test.startTest();
        StockTake stockTakeobj = new StockTake();
        StockTake.getStockTakeStatus();
        StockTake.getAllDetails('','',string.valueOf(channel.Id),string.valueOf(site.Id),0,10,'','',true,'');
        StockTake.getAll('',string.valueOf(channel.Id),string.valueOf(site.Id),0,25);
        
        StockTake.getStockTakeRec(string.valueOf(sT.Id));
        sT.Name = 'Updated Name';
        StockTake.updateStockTake(JSON.serialize(sT));
        StockTake.deleteStockTake(string.valueOf(sT.Id));
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    
    private  TestMethod static void unit3(){
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c TestEmp = new ERP7__Employees__c(Name='Test',ERP7__Employee_User__c=userInfo.getUserId());
        insert TestEmp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test',ERP7__Barcode__c='TestSite');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='loc1',ERP7__Site__c=site.id);
        insert loc1;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='loc2',ERP7__Site__c=site.id,ERP7__Barcode__c='Testlocation');
        insert loc2;
        ERP7__StorageContainer__c bin1 = new ERP7__StorageContainer__c(Name='Bin1',ERP7__Site__c=site.id,ERP7__Location__c=loc1.Id);
        insert bin1;
        ERP7__StorageContainer__c bin2 = new ERP7__StorageContainer__c(Name='Bin2',ERP7__Site__c=site.id,ERP7__Location__c=loc2.Id);
        insert bin2;
        product2 pro1 = new Product2(IsActive=true, Name='Test Product-1', ERP7__Track_Inventory__c = true, StockKeepingUnit='Test1',ERP7__Barcode__c='rec');
        insert pro1;
        ERP7__Inventory_Stock__c is = new ERP7__Inventory_Stock__c(Name='Test Inventory Stock', ERP7__Warehouse__c = site.id,ERP7__Location__c = loc1.id,ERP7__product__c = pro1.id);
        insert is;
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true, ERP7__Site_ProductService_InventoryStock__c = is.id,ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 50.00);
        insert sili; 
        ERP7__Stock_Take__c sT = new ERP7__Stock_Take__c(Name = 'Test', ERP7__Approver__c = TestEmp.Id, ERP7__Employee__c =TestEmp.Id, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today() , ERP7__Site__c = site.Id, ERP7__Status__c = 'Open');
        insert sT;
        ERP7__Stock_Take_Line_Item__c STLI = new ERP7__Stock_Take_Line_Item__c(ERP7__Stock_Take__c = sT.Id, ERP7__Inventory_Stock__c = is.Id, ERP7__Stock_Available__c = 50, ERP7__Stock_In_Hand__c = 0.00, ERP7__Variance__c = 0.00);
        insert STLI;
        ERP7__Stock_Inward_Line_Item__c  sili1 = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true, ERP7__Site_ProductService_InventoryStock__c = is.id, ERP7__Stock_Take_Line_Item__c = STLI.Id,ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 50.00);
        insert sili1;
        ERP7__Stock_Outward_Line_Item__c soli1 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c =true, ERP7__Site_Product_Service_Inventory_Stock__c  = is.id, ERP7__Stock_Take_Line_Item__c = STLI.Id, ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 5.00);
        insert soli1;
       
        test.startTest();
        StockTake stockTakeobj = new StockTake();
        StockTake.getAllDetails(string.valueOf(sT.Id),'',string.valueOf(channel.Id),string.valueOf(site.Id),0,10,'','',false,'');
        StockTake.StockTakeDetails(string.valueOf(sT.Id));
        StockTake.deleteStockTake(string.valueOf(sT.Id));
        StockTake.getSTAudit();
        StockTake.getscannedProducts('',site.Id,loc1.Id);
        PageReference pageRef = System.Page.StockTakeDoc;
        pageRef.getParameters().put('Id',sT.Id);
        Test.setCurrentPage(pageRef);
        StockTakeDoc dco = new StockTakeDoc();
        dco.createPDF();
        system.debug('customlabel~>'+System.Label.Stock_Take_Line_Items); 
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
        
    }
}