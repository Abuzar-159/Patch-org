public with sharing class RollUpSummaryFuture{
    @future
    public static void rollUpTrigger(list<Id> StockOutwardIds){
        try{
            List<Id> soliIds = new List<Id>();
            List<Id> oliIds = new List<Id>();
            Map<Id, List<Stock_Outward_Line_Item__c>> myOutwards = new Map<Id, List<Stock_Outward_Line_Item__c>>();
            List<Stock_Outward_Line_Item__c> outwards = [Select Id, Name, ERP7__Sales_Order_Line_Item__c,ERP7__Order_Product__c, ERP7__Cost_Price__c From Stock_Outward_Line_Item__c Where Id In: StockOutwardIds];
            for(Stock_Outward_Line_Item__c outward : outwards){
                if(outward.ERP7__Sales_Order_Line_Item__c != Null) {
                    soliIds.add(outward.ERP7__Sales_Order_Line_Item__c);
                    List<Stock_Outward_Line_Item__c> tempOutwards = (myOutwards.containsKey(outward.ERP7__Sales_Order_Line_Item__c))? myOutwards.get(outward.ERP7__Sales_Order_Line_Item__c) : new List<Stock_Outward_Line_Item__c>();
                    tempOutwards.add(outward);
                    myOutwards.put(outward.ERP7__Sales_Order_Line_Item__c, tempOutwards);
                }
                else if(outward.ERP7__Order_Product__c !=Null){
                     oliIds.add(outward.ERP7__Order_Product__c);
                    List<Stock_Outward_Line_Item__c> tempOutwards = (myOutwards.containsKey(outward.ERP7__Order_Product__c))? myOutwards.get(outward.ERP7__Order_Product__c) : new List<Stock_Outward_Line_Item__c>();
                    tempOutwards.add(outward);
                    myOutwards.put(outward.ERP7__Order_Product__c, tempOutwards);
                }
            }
            if(soliIds.Size() > 0) {
                List<ERP7__Sales_Order_Line_Item__c> Solis = [Select Id, Name, ERP7__Cost__c From ERP7__Sales_Order_Line_Item__c Where Id In: soliIds];
                for(ERP7__Sales_Order_Line_Item__c Soli : Solis){
                    Decimal TotalCostPrice = 0;
                    for(Stock_Outward_Line_Item__c outward : myOutwards.get(Soli.Id)){
                        if(outward.ERP7__Cost_Price__c != Null) TotalCostPrice += outward.ERP7__Cost_Price__c;
                    }
                    if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Cost__c.isUpdateable()) Soli.ERP7__Cost__c = TotalCostPrice;
                }
                if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()) { update Solis; } else{ /* not allowed */ }
            }
            else if(oliIds.size() > 0){
                List<OrderItem> Solis = [Select Id, OrderItemNumber, ERP7__Cost__c From OrderItem Where Id In: oliIds];
                for(OrderItem Soli : Solis){
                    Decimal TotalCostPrice = 0;
                    for(Stock_Outward_Line_Item__c outward : myOutwards.get(Soli.Id)){
                        if(outward.ERP7__Cost_Price__c != Null) TotalCostPrice += outward.ERP7__Cost_Price__c;
                    }
                    if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Cost__c.isUpdateable()) Soli.ERP7__Cost__c = TotalCostPrice;
                }
                if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()){ update Solis; } else{ /* not allowed */ }
                
            }
        }catch(exception e){}
    }
    
    @future
    public static void rollUp2SolisTrigger(list<Id> LoliIds){
        try{
            //PreventRecursiveLedgerEntry.LogisticLineRollup = false;
            PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; 
            String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            List<ERP7__Logistic_Line_Item__c> Lolis = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where Id In: LoliIds'); 
            
            
            list<RollUpSummaryUtility.fieldDefinition> FieldDefinitions2 = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Packed_Quantity__c', 'ERP7__Packed_Quantity__c')
            };
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions2, Lolis, 'Logistic_Line_Item__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', '');
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions2, Lolis, 'Logistic_Line_Item__c','ERP7__Order_Product__c', 'OrderItem', '');
            
            list<RollUpSummaryUtility.fieldDefinition> FieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Picked_Quantity__c', 'ERP7__Picked_Quantity__c')
            };
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions1, Lolis, 'Logistic_Line_Item__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', '');
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions1, Lolis, 'Logistic_Line_Item__c','ERP7__Order_Product__c', 'OrderItem', '');
            
            
            list<RollUpSummaryUtility.fieldDefinition> FieldDefinitions3 = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Shipped_Quantity__c', 'ERP7__Shipped_Quantity__c')
            };
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions3, Lolis, 'Logistic_Line_Item__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', '');
			RollUpSummaryUtility.rollUpTrigger(FieldDefinitions3, Lolis, 'Logistic_Line_Item__c','ERP7__Order_Product__c', 'OrderItem', '');
            
            list<RollUpSummaryUtility.fieldDefinition> FieldDefinitions4 = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity__c', 'ERP7__Logistic_Quantity__c')
            };
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions4, Lolis, 'Logistic_Line_Item__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', '');
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions4, Lolis, 'Logistic_Line_Item__c','ERP7__Order_Product__c', 'OrderItem', '');
            
        }catch(exception e){
            String errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();
            /*'*** errorMsg : '+errorMsg*/    
        }
    }
}