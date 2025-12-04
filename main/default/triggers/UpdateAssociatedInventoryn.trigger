trigger UpdateAssociatedInventoryn on StorageContainer__c (before insert, before update, after update) {
   
    Map<Id,Inventory_Stock__c> StorageIdMapToInventoryStock = new Map<Id,Inventory_Stock__c>();
    Map<Id,Stock_Inward_Line_Item__c> StorageIdMapToStockInward = new Map<Id,Stock_Inward_Line_Item__c>();
   try{
            if(Trigger.isUpdate && Trigger.isAfter){
                 List<Inventory_Stock__c> warehouseInventory = [SELECT name, Active__c, Organisation__c, Product__c, StorageContainer__c, Location__c 
                                                                               FROM Inventory_Stock__c WHERE StorageContainer__c IN: Trigger.newMap.keySet()];
                if(warehouseInventory.size()>0)
                    for(Inventory_Stock__c WIIS :warehouseInventory)  StorageIdMapToInventoryStock.put(WIIS.StorageContainer__c,WIIS);
                       
                        
                List<Stock_Inward_Line_Item__c> sitePurchaseLineItemList = [SELECT Purchase_Orders__c, Active__c, Amount__c, BoM__c,Process__c, Schedule__c,  Product__c , Site_ProductService_InventoryStock__c, Location__c, StorageContainer__c, Tax__c, Unit_Price__c 
                                                                            FROM Stock_Inward_Line_Item__c WHERE StorageContainer__c IN: Trigger.newMap.keySet()];
                if(sitePurchaseLineItemList.size()>0)
                    for(Stock_Inward_Line_Item__c SILI :sitePurchaseLineItemList) StorageIdMapToStockInward.put(SILI.StorageContainer__c,SILI);  
                                      
               for(StorageContainer__c sc :Trigger.new)
                    if(sc.Status__c == 'Checked in'){
                            Inventory_Stock__c inventory = StorageIdMapToInventoryStock.get(sc.id);
                            if(Schema.sObjectType.Inventory_Stock__c.fields.Location__c.isUpdateable()) inventory.Location__c = sc.Location__c;
                            StorageIdMapToInventoryStock.put(sc.id,inventory);
                            Stock_Inward_Line_Item__c purchaseLineitem =StorageIdMapToStockInward.get(sc.id);
                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Location__c.isUpdateable()) purchaseLineitem.Location__c = sc.Location__c;
                            StorageIdMapToStockInward.put(sc.Id,purchaseLineitem);
                        }
                    
                    
                   }
           
       if(StorageIdMapToInventoryStock.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isUpdateable()){ update StorageIdMapToInventoryStock.values(); } else { /* no access */ }
                
       if(StorageIdMapToStockInward.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.isUpdateable()){ update StorageIdMapToStockInward.values(); }   else { /* no access */ }
       }
       catch(DMLException ex){
         }
       catch(QUERYException ex){
         }
       catch(Exception ex){
        }
}