public with sharing class shippingSlipCompController {
        
    public String packageId         { get; set; }
    
    public List<Package_List__c> getPackageLists() {
        List<Package_List__c> packList = new List<Package_List__c>();  
        if(packageId != null && packageId != '') {
            packList = [Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, ERP7__Order_Product__c ,Package__r.Order__c, Sales_Order_Line_Item__c, Package__r.Sales_Order__c, Package__r.Work_Order__c, 
                        Package__r.Purchase_Order__c, Package__r.Transfer_Order__c,Sales_Order_Line_Item__r.Product__r.SKU__c, Work_Order_Line_Items__r.Product__r.SKU__c,ERP7__Order_Product__r.Product2.SKU__c ,ERP7__Order_Product__r.Product2.Name ,    ERP7__Order_Product__r.Product2.ProductCode,                   
                        Purchase_Line_Items__r.Product__r.SKU__c, Transfer_Order_Line_Item__r.Products__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, ERP7__Work_Order_Line_Items__c,
                        Work_Order_Line_Items__r.Product__r.Name, ERP7__Work_Order_Line_Items__r.ERP7__Asset__r.Name, Purchase_Line_Items__r.Product__r.Name, Transfer_Order_Line_Item__r.Products__r.Name, 
                       ERP7__Order_Product__r.Quantity, ERP7__Order_Product__r.Order.Name, Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Total_Price__c,ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ProductCode,
                         ERP7__Order_Product__r.ReturnedQuantity__c,ERP7__Order_Product__r.OrderItemNumber ,Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Name, SKU__c, Package_Weight__c, ERP7__Order_Product__r.ERP7__Total_Price__c,ERP7__Order_Product__r.Description, ERP7__Order_Product__r.ERP7__Asset__r.Name,
                        Sales_Order_Line_Item__r.Description__c, Sales_Order_Line_Item__r.ERP7__Asset__r.Name, ERP7__RMA_Line_Item__c, ERP7__RMA_Line_Item__r.ERP7__Product__c, ERP7__RMA_Line_Item__r.ERP7__Product__r.Name From Package_List__c where Package__r.Name =: String.escapeSingleQuotes(packageId)];
        }
        return packList;
    }    
}