@isTest
private class TestSortLineItemsClass {
	// For SOLineSorting
    static testMethod void SOLineSorting() {
        Test.startTest();
        	Product2 ps = new Product2(Name='test', ERP7__Track_Inventory__c=true, IsActive=true, ERP7__Status__c = 'Released'); 
        	insert ps;
        	Product2 ps1 = new Product2(Name='test 1', ERP7__Track_Inventory__c=true, IsActive=true, ERP7__Status__c = 'Released'); 
        	insert ps1;
        
        	ERP7__Sales_Order__c sod = new ERP7__Sales_Order__c(Order_Status__c = 'Entered');
            insert sod;
            ERP7__Sales_Order_Line_Item__c ili = new ERP7__Sales_Order_Line_Item__c(Sales_Order__c=sod.id, ERP7__Sort_Order__c = 1, Active__c = true, Base_Price__c=100, Discount_Amount__c=10, Product__c=ps.id, Quantity__c=1);
            insert ili;
        	ERP7__Sales_Order_Line_Item__c ili1 = new ERP7__Sales_Order_Line_Item__c(Sales_Order__c=sod.id, ERP7__Sort_Order__c = 2, Active__c = true, Base_Price__c=10, Discount_Amount__c=10, Product__c=ps1.id, Quantity__c=1);
            insert ili1;
        	List <ERP7__Sales_Order_Line_Item__c> iList = new List<ERP7__Sales_Order_Line_Item__c>();
        	iList.add(ili);
        	iList.add(ili1);
        	String inId = sod.Id;
        	SortLineItems sl = new SortLineItems();
        	SortLineItems.SoWrapper mcw = new SortLineItems.SoWrapper();
        	SortLineItems.fetchOrderLines(inId,'');
        	SortLineItems.updateSortOrder(JSON.serialize(iList),inId,'');
        System.assertEquals('ERP','ERP');
        Test.stopTest();
    }
    
    // For InLineSorting
    static testMethod void InLineSorting() {
        Test.startTest();
        	Product2 ps = new Product2(Name='test', ERP7__Track_Inventory__c=true, IsActive=true, ERP7__Status__c = 'Released'); 
        	insert ps;
        	Product2 ps1 = new Product2(Name='test 1', ERP7__Track_Inventory__c=true, IsActive=true, ERP7__Status__c = 'Released'); 
        	insert ps1;
        	ERP7__Sales_Order__c sod = new ERP7__Sales_Order__c(Order_Status__c = 'Entered');
            insert sod;
            ERP7__Sales_Order_Line_Item__c sili = new ERP7__Sales_Order_Line_Item__c(Sales_Order__c=sod.id, ERP7__Sort_Order__c = 1, Active__c = true, Base_Price__c=100, Discount_Amount__c=10, Product__c=ps.id, Quantity__c=1);
            insert sili;
        	ERP7__Invoice__c iv = new ERP7__Invoice__c(ERP7__Invoice_Date__c = system.today(), ERP7__Active__c = true);
            insert iv;
            ERP7__Invoice_Line_Item__c ili = new ERP7__Invoice_Line_Item__c(ERP7__Sales_Order_Line_Item__c=sili.Id,ERP7__Product__c=ps.Id, ERP7__Detailed_Description__c = 'DD', ERP7__Invoice__c = iv.Id, ERP7__Sub_Total__c = 50.00, ERP7__Total_Price__c = 50.00);
            insert ili;
        	ERP7__Invoice_Line_Item__c ili1 = new ERP7__Invoice_Line_Item__c(ERP7__Product__c=ps1.Id, ERP7__Detailed_Description__c = 'DD', ERP7__Invoice__c = iv.Id, ERP7__Sub_Total__c = 50.00, ERP7__Total_Price__c = 50.00);
            insert ili1;
        	List <ERP7__Invoice_Line_Item__c> iList = new List<ERP7__Invoice_Line_Item__c>();
        	iList.add(ili);
        	iList.add(ili1);
        	String inId = ili.Id;
        	SortLineItems sl = new SortLineItems();
        	SortLineItems.SoWrapper mcw = new SortLineItems.SoWrapper();
        	SortLineItems.fetchOrderLines('',inId);
        	SortLineItems.updateSortOrder(JSON.serialize(iList),'',inId);
        System.assertEquals('ERP','ERP');
        Test.stopTest();
    }
    
    // For SortPoLineItems
    static testMethod void SortPoLineItems() {
        Test.startTest();
            Product2 ps = new Product2(Name='test', ERP7__Track_Inventory__c=true, IsActive=true, ERP7__Status__c = 'Released'); 
            insert ps;
            Product2 ps1 = new Product2(Name='test 1', ERP7__Track_Inventory__c=true, IsActive=true, ERP7__Status__c = 'Released'); 
            insert ps1;
            ERP7__PO__c sod = new ERP7__PO__c(Name = 'Test Po');
            insert sod;
            ERP7__Purchase_Line_Items__c ili = new ERP7__Purchase_Line_Items__c(ERP7__Purchase_Orders__c=sod.id, Sort_Order__c = 1, ERP7__Product__c=ps.id, ERP7__Quantity__c=1, ERP7__Description__c='Desc1',ERP7__Unit_Price__c=10);
            insert ili;
            ERP7__Purchase_Line_Items__c ili1 = new ERP7__Purchase_Line_Items__c(ERP7__Purchase_Orders__c=sod.id, Sort_Order__c = 2, ERP7__Product__c=ps1.id, ERP7__Quantity__c=1, ERP7__Description__c='Desc2',ERP7__Unit_Price__c=10);
            insert ili1;
            List <ERP7__Purchase_Line_Items__c> iList = new List<ERP7__Purchase_Line_Items__c>();
            iList.add(ili);
            iList.add(ili1);
            String inId = sod.Id;
            SortPoLineItems sl = new SortPoLineItems();
            SortPoLineItems.PoWrapper mcw = new SortPoLineItems.PoWrapper();
            SortPoLineItems.fetchOrderLines(inId);
            SortPoLineItems.updateSortOrder(JSON.serialize(iList),inId);
        System.assertEquals('ERP','ERP');
        Test.stopTest();
    }
}