trigger OrderItemKitVersionTrigger on OrderItem (before insert, before update) {
  
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
     
        Set<Id> kitProductIds = new Set<Id>();
        
      
        for (OrderItem oi : Trigger.new) {
            if (oi.Product2Id != null) {
                kitProductIds.add(oi.Product2Id);
            }
        }
        
        if (kitProductIds.isEmpty()) return;
        
       
        Map<Id, Product2> productMap = new Map<Id, Product2>([
            SELECT Id, ERP7__Is_Kit__c 
            FROM Product2 
            WHERE Id IN :kitProductIds
        ]);
        
        
        Set<Id> actualKitProductIds = new Set<Id>();
        
                for (OrderItem oi : Trigger.new) {
            Product2 prod = productMap.get(oi.Product2Id);
            if (prod != null && prod.ERP7__Is_Kit__c == true) {
                actualKitProductIds.add(oi.Product2Id);
            }
        }
        
        if (actualKitProductIds.isEmpty()) return;
        
        
        Map<Id, ERP7__Version__c> defaultVersionsMap = new Map<Id, ERP7__Version__c>();
        for (ERP7__Version__c ver : [
            SELECT Id, ERP7__Product__c 
            FROM ERP7__Version__c 
            WHERE ERP7__Product__c IN :actualKitProductIds 
            AND ERP7__Default__c = true
        ]) {
            defaultVersionsMap.put(ver.ERP7__Product__c, ver);
        }
        
        
        for (OrderItem oi : Trigger.new) {
            Product2 prod = productMap.get(oi.Product2Id);
            if (prod != null && prod.ERP7__Is_Kit__c == true) {
                ERP7__Version__c defaultVer = defaultVersionsMap.get(oi.Product2Id);
                if (defaultVer != null) {
                    oi.ERP7__Version__c = defaultVer.Id;
                }
            }
        }
    }
}