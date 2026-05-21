global class UpdateProdStockAsync implements Queueable {
    global Set<Id> productIds;
    
    global UpdateProdStockAsync(Set<Id> products) {
        this.productIds = products;
    }
    
    global void execute(QueueableContext context) {
        System.debug('INSIDE UpdateProdStockAsync ');
        List<Product2> prodMap = new List<Product2>();
        
        try {
            for (AggregateResult result : [SELECT ERP7__Product__c,
                                           SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) AwaitingStock,
                                           SUM(ERP7__No_of_Items_Reserved__c) ReservedStock,
                                           SUM(ERP7__Number_of_Item_In_Stock__c) TotalStock 
                                           FROM ERP7__Inventory_Stock__c 
                                           WHERE ERP7__Active__c = true 
                                           AND ERP7__Product__c IN :productIds
                                           AND ERP7__Warehouse__c != null 
                                           GROUP BY ERP7__Product__c]) {
                                               
                                               Id prodId = (Id) result.get('ERP7__Product__c');
                                               if (prodId != null) {
                                                   Product2 product = new Product2(
                                                       Id = prodId,
                                                       ERP7__Available_Stock__c = (Decimal) result.get('TotalStock'),
                                                       ERP7__Awaiting_Stock__c = (Decimal) result.get('AwaitingStock'),
                                                       ERP7__Reserved_Stock__c = (Decimal) result.get('ReservedStock')
                                                   );
                                                   prodMap.add(product);
                                               }
                                           }
            
            if (!prodMap.isEmpty()) {
                update prodMap;
            }
            else{
                System.debug('Inside Inv empty: ');
                List<Product2> prodsnull=  [SELECT Id, Available_Stock__c,Awaiting_Stock__c ,Reserved_Stock__c FROM Product2 WHERE Id IN :productIds];
                for(Product2 p:prodsnull){
                    p.Available_Stock__c=0;
                    p.Awaiting_Stock__c=0;
                    p.Awaiting_Stock__c=0;
                }
                System.debug('product: ' + prodsnull);
                update prodsnull;
            }
            System.debug('prodMap: '+prodMap);
            
        } catch (Exception e) {
            System.debug('An error occurred in UpdateProdStockAsync: ' + e.getMessage());
        } 
    }
    
}