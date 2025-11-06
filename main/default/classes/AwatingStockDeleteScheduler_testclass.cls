@istest
public class AwatingStockDeleteScheduler_testclass{
    public static testMethod void testschedule() {
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product;
        ERP7__Version__c version = new ERP7__Version__c(Name = 'test', ERP7__Product__c = product.Id, ERP7__Category__c = 'Production',  ERP7__Start_Date__c = system.today(), ERP7__To_Date__c = system.today(), ERP7__Type__c = 'Assembly', ERP7__Status__c = 'Certified', ERP7__Default__c = true);
        insert version;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = version.Id, ERP7__Product__c = product.Id,   ERP7__Description__c = 'test',   ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000);
        insert routing;
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name = 'Test', ERP7__Initiate_MO__c = true, ERP7__Product__c = product.Id, ERP7__Version__c = version.Id, ERP7__Status__c = 'Complete', ERP7__Quantity__c = 10, ERP7__Routing__c = routing.Id, ERP7__Lead_Time__c = system.today(), ERP7__Progress__c = 100, ERP7__StartDate__c = system.Now(), ERP7__End_Date__c = system.today() + 1, ERP7__Expected_Date__c = system.today(), ERP7__Completion_Date__c = system.today(), ERP7__Labour_Cost__c = 10, ERP7__Material_Cost__c = 10, ERP7__Overhead_Cost__c = 10, ERP7__In_Production__c = false, ERP7__Manufactured_Quantity__c = 8, ERP7__Scrapped_Quantity__c = 1);
        insert manuorder;
        Account o = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert o;
        Site__c site = new Site__c(Name = 'site', Active__c = true, Organisation__c = o.id);
        insert site;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c inv = new Inventory_Stock__c(Organisation__c = o.Id, Name = 'test', Active__c = true, Warehouse__c = site.Id, Product__c = product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inv;        
        ERP7__Stock_Inward_Line_Item__c stin= new ERP7__Stock_Inward_Line_Item__c(ERP7__Site_ProductService_InventoryStock__c=inv.Id,ERP7__Manufacturing_Order__c=manuorder.Id,Name='Awaiting Stock' ,ERP7__Quantity__c = 0, ERP7__Status__c = 'Awaiting Stock');
        insert stin;
        Test.StartTest();
        AwatingStockDeleteScheduler testsche = new AwatingStockDeleteScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}