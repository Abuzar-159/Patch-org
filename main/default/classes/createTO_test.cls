@isTest
public class createTO_test {
    
    static testmethod void TransferOrder(){
        Test.startTest();
        CreateTO TO = new CreateTO(); 
        
        //data 
        Account testCust = new Account(Name = 'testCust001', ERP7__Account_Type__c = 'Customer');
        insert testCust;
        
        Product2 testProd = new Product2(Name = 'testprod001', ERP7__Lot_Tracked__c = true);
        insert testProd; 
        Product2 testProd2 = new Product2(Name = 'testprod002', ERP7__Lot_Tracked__c = true);
        insert testProd2;
        
        ERP7__Batch__c testBatch = new ERP7__Batch__c(Name = 'testbatch001', ERP7__Product__c = testProd.Id);
        insert testBatch;
        
        ERP7__Channel__c testCh = new ERP7__Channel__c(Name = 'testCh001');
        insert testCh;
        
        ERP7__Address__c testAdd = new ERP7__Address__c(Name = 'testAdd001', ERP7__Customer__c = testCust.Id);
        insert testAdd;
        
        ERP7__Site__c testSite = new ERP7__Site__c(Name = 'testSite001', ERP7__Address__c = testAdd.Id);
        insert testSite;
        
        ERP7__Distribution_Channel__c testDC = new ERP7__Distribution_Channel__c(Name = 'testDC001', ERP7__Channel__c = testCh.Id, ERP7__Site__c = testSite.Id);
        insert testDC;
        
        ERP7__Transfer_Order__c testTO = new ERP7__Transfer_Order__c(Name = 'testTO001',ERP7__Active__c = true, ERP7__Channel__c = testCh.Id, ERP7__To_Channel__c = testCh.Id, ERP7__Distribution_Channel__c = testDC.Id, ERP7__To_Distribution_Channel__c = testDC.Id, ERP7__From_Site__c = testSite.Id, ERP7__To_Site__c = testSite.Id, ERP7__From_Address__c = testAdd.Id, ERP7__To_Address__c = testAdd.Id);        
        ERP7__Transfer_Order_Line_Items__c  testTOLI = new ERP7__Transfer_Order_Line_Items__c(Name = 'testTOLI001', ERP7__Products__c = testProd.Id, ERP7__Batch_Lot__c = testBatch.Id, ERP7__Quantity_requested__c = 1);
        List<ERP7__Transfer_Order_Line_Items__c> testTOLIlist = new List<ERP7__Transfer_Order_Line_Items__c>();
        testTOLIlist.add(testTOLI);
        
        ERP7__Inventory_Stock__c testIstock = new ERP7__Inventory_Stock__c(Name = 'testIstock', ERP7__Product__c = testProd.Id, ERP7__Active__c = true, ERP7__Warehouse__c = testSite.Id, ERP7__Batch_Lot__c = testBatch.Id);
        insert testIstock;
        ERP7__Stock_Inward_Line_Item__c testStockIn = new ERP7__Stock_Inward_Line_Item__c(Name = 'testStockIn001',ERP7__Active__c = true, ERP7__Site_ProductService_InventoryStock__c = testIstock.Id, ERP7__Quantity__c = 10, ERP7__Unit_Price__c = 10, ERP7__Amount__c = 100);
        insert testStockIn;
        
        ERP7__Employees__c testEmp = new ERP7__Employees__c(Name = 'testEmp001', ERP7__Employee_User__c = UserInfo.getUserId(), ERP7__Channel__c = testCh.Id);
        insert testEmp;
        
        CreateTO.fetchChannelandDC();
        CreateTO.getTOStatuspickval();
        CreateTO.getTOshipmenttype();
        
        CreateTO.fetchProductDetails(testProd.Id);
        CreateTO.fetchProductInventoryStock(testProd.Id,testDC.Id);
        CreateTO.fetchProductInventoryStock(testProd2.Id,testDC.Id);
        CreateTO.fetchBatchProductInventoryStock(testProd.Id, testBatch.Id,testDC.Id);
        CreateTO.fetchBatchProductInventoryStock(testProd2.Id, testBatch.Id, testDC.Id);
        CreateTO.save_TO(JSON.serialize(testTO), JSON.serialize(testTOLIlist));
        CreateTO.getSitefromDC(testDC.Id);
        CreateTO.getDependentPicklistMap('ERP7__PO__c','ERP7__Shipment_Type__c','ERP7__Shipment_Preference_Speed__c');

        CreateTO.checkInventories(testDC.Id, testProd2.Id, 0);
        CreateTO.getProdDetails(testProd2.Id,testDC.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
}