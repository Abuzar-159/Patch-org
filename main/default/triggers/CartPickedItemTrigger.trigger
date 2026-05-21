trigger CartPickedItemTrigger on Cart_Picked_Item__c (After Insert,After Update,before delete) {
    
    if(Trigger.isInsert || Trigger.isUpdate){    List<Stock_Outward_Line_Item__c> stockoutWardToUpsert = new List<Stock_Outward_Line_Item__c>();
    Map<Id,Id> pickedLineitem_Map2_SoliId = new Map<Id,Id>();  for(Stock_Outward_Line_Item__c soli:[Select Id,ERP7__Cart_Picked_Item__c  from Stock_Outward_Line_Item__c  Where ERP7__Cart_Picked_Item__c In: Trigger.newMap.keySet()]) pickedLineitem_Map2_SoliId.put(soli.ERP7__Cart_Picked_Item__c,soli.id);
        
    for(Cart_Picked_Item__c item : Trigger.new){
    if(item.ERP7__Inventory_Stock__c !=null){    
        Stock_Outward_Line_Item__c ItemsToRemove = new Stock_Outward_Line_Item__c(Id=(pickedLineitem_Map2_SoliId.get(item.id)!= null)? pickedLineitem_Map2_SoliId.get(item.id): null);    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Cart__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Cart__c.isUpdateable()){ItemsToRemove.ERP7__Cart__c = item.ERP7__Cart__c; }else{/*No access*/}     if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()){ItemsToRemove.Product__c = item.Product__c;  }else{/*No access*/}   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){ItemsToRemove.Quantity__c = item.Quantity__c;  }else{/*No access*/}    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Cart_Picked_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Cart_Picked_Item__c.isUpdateable()){ItemsToRemove.ERP7__Cart_Picked_Item__c = item.id;  }else{/*No access*/}    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){ItemsToRemove.ERP7__Serial__c = item.ERP7__Serial_Number__c; }else{/*No access*/}     if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){ItemsToRemove.ERP7__Material_Batch_Lot__c = item.ERP7__Batch_Lot__c; }else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){ItemsToRemove.Status__c = 'Committed';  }else{/*No access*/}   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){ItemsToRemove.ERP7__Site_Product_Service_Inventory_Stock__c = item.ERP7__Inventory_Stock__c; }else{/*No access*/}
    
    stockoutWardToUpsert.add(ItemsToRemove);
    }
    }
    if(stockoutWardToUpsert.size()>0 && Schema.SObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.SObjectType.Stock_Outward_Line_Item__c.isUpdateable()){upsert stockoutWardToUpsert;}else{/*not allowed to upsert*/}
    }
    else if(Trigger.isDelete){  
        List<Stock_Outward_Line_Item__c> soliToDelete = new List<Stock_Outward_Line_Item__c>(); 
        soliToDelete = [Select Id,ERP7__Cart_Picked_Item__c  from Stock_Outward_Line_Item__c  Where ERP7__Cart_Picked_Item__c In: Trigger.oldMap.keySet()];
        if(soliToDelete.size()>0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable())  delete soliToDelete;
    }
    // code added by shaguftha to mark the seraial numbers as available when the cart picked items is deleted
    if(Trigger.isDelete && Trigger.isBefore){
        List<ERP7__Serial_Number__c> serials2Update = new List<ERP7__Serial_Number__c>();
        for(ERP7__Cart_Picked_Item__c cartPick : System.trigger.Old){
            if(cartPick.ERP7__Serial_Number__c != null) serials2Update.add(new ERP7__Serial_Number__c(Id=cartPick.ERP7__Serial_Number__c,ERP7__Available__c = true));
        }
        if(serials2Update.size() > 0){
            update serials2Update;
        }
    }
    
}