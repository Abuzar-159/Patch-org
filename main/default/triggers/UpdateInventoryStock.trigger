trigger UpdateInventoryStock on Inventory_Stock__c (before update, after update, after delete) {
    ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
    boolean stopInventorysync;
    stopInventorysync = false;
    FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
    if(FC != null){
        stopInventorysync = FC.ERP7__Stop_update_inventory_Update__c;
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        if(!PreventRecursiveLedgerEntry.preventStockTrigger){
            PreventRecursiveLedgerEntry.preventStockTrigger = true;
            Set<Id> stockIds = new Set<Id>();
            
            for(Inventory_Stock__c s : System.Trigger.New){
                stockIds.add(s.Id);
            }
            
            list<Sample__c> sampleItems = [Select Id, Name, ERP7__Active__c, ERP7__Check_In_Inventory_Stock__c, ERP7__Check_Out_Inventory_Stock__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Site__c  
                                           From Sample__c 
                                           Where (ERP7__Check_In_Inventory_Stock__c In : stockIds Or ERP7__Check_Out_Inventory_Stock__c In : stockIds) And
                                           ERP7__Active__c = true And
                                           ERP7__Quantity__c != Null];
            List<RMA_Line_Item__c> rmaItems = [Select Id, Name, ERP7__Active__c, ERP7__Quantity_Available__c, ERP7__Quantity_Return__c, ERP7__Site_Item_Inventory_Stock__c, ERP7__Number_of_Items_In_Quality_Check__c, ERP7__Number_of_Items_to_Re_sell__c 
                                               From RMA_Line_Item__c 
                                               Where ERP7__Site_Item_Inventory_Stock__c In : stockIds And
                                               ERP7__Active__c = true And
                                               ERP7__Quantity_Return__c != Null];
            
            List<Material_Wastage__c> wastageItems = [Select Id, Name, ERP7__Wastage_Quantity__c, ERP7__Site_Item_Inventory_Stock__c 
                                                      From Material_Wastage__c 
                                                      Where ERP7__Site_Item_Inventory_Stock__c In : stockIds And
                                                      ERP7__Wastage_Quantity__c != Null];
            
            
            for(Inventory_Stock__c s : System.Trigger.New){
                Decimal sampleItemsCheckedIn = 0;
                for(Sample__c sample : sampleItems){
                    if(S.Id == sample.ERP7__Check_In_Inventory_Stock__c && sample.ERP7__Product__c == s.ERP7__Product__c && sample.ERP7__Site__c == s.ERP7__Warehouse__c)  sampleItemsCheckedIn += sample.ERP7__Quantity__c;
                }
                
                Decimal sampleItemsCheckedOut = 0;
                for(Sample__c sample : sampleItems){
                    if(S.Id == sample.ERP7__Check_Out_Inventory_Stock__c && sample.ERP7__Product__c == s.ERP7__Product__c && sample.ERP7__Site__c == s.ERP7__Warehouse__c)  sampleItemsCheckedOut += sample.ERP7__Quantity__c;
                }
                
                Decimal rmaItemsInQualityCheck = 0;
                Decimal rmaItems2Resell = 0;
                for(RMA_Line_Item__c rmaline : rmaItems){
                    if(S.Id == rmaline.ERP7__Site_Item_Inventory_Stock__c)
                        if(rmaline.ERP7__Number_of_Items_In_Quality_Check__c != Null) rmaItemsInQualityCheck += rmaline.ERP7__Number_of_Items_In_Quality_Check__c;
                    if(rmaline.ERP7__Number_of_Items_to_Re_sell__c != Null) rmaItems2Resell += rmaline.ERP7__Number_of_Items_to_Re_sell__c;
                }
                
                Decimal discardedItems = 0;
                for(Material_Wastage__c wasteItem : wastageItems){
                    if(S.Id == wasteItem.ERP7__Site_Item_Inventory_Stock__c)
                        discardedItems += wasteItem.ERP7__Wastage_Quantity__c;
                }
                
                s.ERP7__Number_of_Item_Discarded__c = discardedItems;
                s.ERP7__Number_of_Items_In_QualityCheck__c = rmaItemsInQualityCheck;
                s.ERP7__Number_of_Items_to_Resell__c = rmaItems2Resell;
                s.ERP7__Number_of_Sample_Items_Checked_In__c = sampleItemsCheckedIn;
                s.ERP7__Number_of_Sample_Items_Checked_Out__c = sampleItemsCheckedOut;
            }
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate && PreventRecursiveLedgerEntry.preventStockCalculation && !stopInventorysync){
        Set<Id> prodIds = new Set<Id>();
        List<ERP7__Inventory_Stock__c> invlst = [Select Id,Name,ERP7__Product__c from ERP7__Inventory_Stock__c where Id = :Trigger.NewMap.keySet()];
        for (ERP7__Inventory_Stock__c inv : invlst) {
            prodIds.add(inv.ERP7__Product__c);
        }
        if (!prodIds.isEmpty())System.enqueueJob(new UpdateProdStockAsync(prodIds));
    }
    try{
        if(Trigger.isAfter && Trigger.isDelete && PreventRecursiveLedgerEntry.preventStockCalculation && !stopInventorysync){
            System.debug('Trigger is after delete');
            Set<Id> prodIds = new Set<Id>();
            for (ERP7__Inventory_Stock__c inv : Trigger.Old) {
                prodIds.add(inv.ERP7__Product__c);
                System.debug('Processing deleted record: ' + inv);
            }
            
            if (!prodIds.isEmpty()){
                System.debug('Collected product IDs: ' + prodIds);
                System.enqueueJob(new UpdateProdStockAsync(prodIds));
            }
        }
    }catch (Exception e) {
        System.debug('Error: ' + e.getMessage());
        System.debug('Stack Trace: ' + e.getStackTraceString());
    }
}