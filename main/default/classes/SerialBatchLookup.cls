public with sharing class SerialBatchLookup {
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String Loc_Id,String site_Id,String queryFilter) {
        String searchKey ='%' + searchKeyWord + '%';
        
        queryFilter = (String.isBlank(queryFilter))? '' : queryFilter;
        if(String.isNotEmpty(Loc_Id)) queryFilter +=' AND ERP7__Location__c =\''+ Loc_Id +'\'';
        if(String.isNotEmpty(site_Id)) queryFilter +=' AND ERP7__Warehouse__c =\''+ site_Id +'\'';
        List < sObject > returnList = new List < sObject > ();
        List<ERP7__Serial_Number__c > serialList = new List<ERP7__Serial_Number__c >();
        serialList = [SELECT Id,Name,ERP7__Product__c,ERP7__Available__c,ERP7__Serial_Number__c  FROM ERP7__Serial_Number__c   Where (ERP7__Serial_Number__c  LIKE: searchKey or Name LIKE: searchKey)  AND ERP7__Available__c = true AND ERP7__Product__r.ERP7__Serialise__c = true AND ERP7__Product__c != null order by createdDate DESC limit 5];  //AND ERP7__Warehouse__c  =:SiteId
        Map<Id,List<ERP7__Serial_Number__c >> serialMap = new Map<Id,List<ERP7__Serial_Number__c >>();
        for(ERP7__Serial_Number__c ser: serialList){
            List<ERP7__Serial_Number__c > templist =  (serialMap.get(ser.ERP7__Product__c) != null)?serialMap.get(ser.ERP7__Product__c): new List<ERP7__Serial_Number__c >();
            templist.add(ser);
            serialMap.put(ser.ERP7__Product__c,templist);
        }
        List<ERP7__Batch__c > batchList = new List<ERP7__Batch__c >();
        batchList = [SELECT Id,Name,ERP7__Product__c,ERP7__Vendor_Batch_Number__c  FROM ERP7__Batch__c   Where (Name LIKE: searchKey)  AND ERP7__Product__r.ERP7__Lot_Tracked__c = true AND ERP7__Product__c != null order by createdDate DESC limit 5];  //AND logistic__Warehouse__c  =:SiteId
        Map<Id,List<ERP7__Batch__c >> batchMap = new Map<Id,List<ERP7__Batch__c >>();
        for(ERP7__Batch__c bat: batchList){
            List<ERP7__Batch__c > templist1 =  (batchMap.get(bat.ERP7__Product__c) != null)?batchMap.get(bat.ERP7__Product__c): new List<ERP7__Batch__c >();
            templist1.add(bat);
            batchMap.put(bat.ERP7__Product__c,templist1);
        }
        set<Id> pids = new set<Id>();
        if(serialMap.size()>0) pids = serialMap.keySet();
        else if(batchMap.size()>0) { pids = batchMap.keySet();  }
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'SELECT Id, Name ,ERP7__Product__c,ERP7__Product__r.ERP7__Lot_Tracked__c ,ERP7__Product__r.Name,ERP7__Product__r.Id,ERP7__Product__r.StockKeepingUnit,ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Fixed_Asset__c,ERP7__Fixed_Asset__r.Id,ERP7__Fixed_Asset__r.Name,ERP7__Fixed_Asset__r.ERP7__Serial__c,ERP7__Fixed_Asset__r.ERP7__Serial__r.Id,ERP7__Fixed_Asset__r.ERP7__Serial__r.Name,ERP7__Fixed_Asset__r.ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Number_of_Item_In_Stock__c, ERP7__StorageContainer__c,ERP7__Warehouse__c, ERP7__Location__c,ERP7__Location__r.Name,ERP7__Location__r.ERP7__Barcode__c, ERP7__StorageContainer__r.Name, ERP7__Batch_Lot__c , ERP7__Batch_Lot__r.Id, ERP7__Batch_Lot__r.Name from ERP7__Inventory_Stock__c where ( ERP7__Fixed_Asset__r.ERP7__Serial__r.Name LIKE: searchKey or ERP7__Batch_Lot__r.Name LIKE: searchKey or ERP7__Product__c IN: pids) AND ERP7__Number_of_Item_In_Stock__c >0.00 '+queryFilter+' order by createdDate DESC limit 5';
        List < ERP7__Inventory_Stock__c > lstOfRecords = Database.query(sQuery);
        for (ERP7__Inventory_Stock__c obj: lstOfRecords) {
            ERP7__Cart_Picked_Item__c  PickedItem = new ERP7__Cart_Picked_Item__c();
            PickedItem.ERP7__Quantity__c = 1.00;
            PickedItem.ERP7__Inventory_Stock__c =obj.Id;
            PickedItem.ERP7__Inventory_Stock__r = new ERP7__Inventory_Stock__c(Id = obj.Id,ERP7__Number_of_Sample_Items_Checked_In__c  = obj.ERP7__Number_of_Item_In_Stock__c);
            //PickedItem.ERP7__Inventory_Stock__r.put('ERP7__Number_of_Item_In_Stock__c',obj.ERP7__Number_of_Item_In_Stock__c); 
            //PickedItem.put('ERP7__Available_Stock__c',obj.ERP7__Number_of_Item_In_Stock__c);
            PickedItem.ERP7__From_Location__c  = obj.ERP7__Location__c;
            PickedItem.ERP7__From_Location__r =  new ERP7__Location__c(Id = obj.ERP7__Location__c,Name = obj.ERP7__Location__r.Name,ERP7__Barcode__c = obj.ERP7__Location__r.ERP7__Barcode__c );            
            
            if(obj.ERP7__Fixed_Asset__c != null){
                PickedItem.ERP7__Serial_Number__c = obj.ERP7__Fixed_Asset__r.ERP7__Serial__c;
                PickedItem.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id= obj.ERP7__Fixed_Asset__r.ERP7__Serial__c,Name = obj.ERP7__Fixed_Asset__r.ERP7__Serial__r.Name,ERP7__Serial_Number__c = obj.ERP7__Fixed_Asset__r.ERP7__Serial__r.ERP7__Serial_Number__c);
                PickedItem.ERP7__Fixed_Asset__c = obj.ERP7__Fixed_Asset__c;
                PickedItem.ERP7__Fixed_Asset__r = new ERP7__Asset__c(Id =obj.ERP7__Fixed_Asset__c,Name = obj.ERP7__Fixed_Asset__r.Name);
                returnList.add(PickedItem);
            }else if(obj.ERP7__Product__c != null){
                if(obj.ERP7__Product__r.ERP7__Serialise__c){
                    for(ERP7__Serial_Number__c ser: serialMap.get(obj.ERP7__Product__c)){
                        ERP7__Cart_Picked_Item__c  PickedItemserial = new ERP7__Cart_Picked_Item__c();
                        PickedItemserial.ERP7__From_Location__c  = obj.ERP7__Location__c;
                        PickedItemserial.ERP7__From_Location__r =  new ERP7__Location__c(Id = obj.ERP7__Location__c,Name = obj.ERP7__Location__r.Name,ERP7__Barcode__c = obj.ERP7__Location__r.ERP7__Barcode__c );  
                        PickedItemserial.ERP7__Quantity__c = 1.00;
                        PickedItemserial.ERP7__Inventory_Stock__c =obj.Id;
                        PickedItemserial.ERP7__Inventory_Stock__r = new ERP7__Inventory_Stock__c(Id = obj.Id,ERP7__Number_of_Sample_Items_Checked_In__c  = obj.ERP7__Number_of_Item_In_Stock__c);
                        PickedItemserial.ERP7__Product__c = obj.ERP7__Product__c;
                        PickedItemserial.ERP7__Product__r = new Product2(Id =obj.ERP7__Product__c,Name = obj.ERP7__Product__r.Name);
                        PickedItemserial.ERP7__Serial_Number__c = ser.Id;
                        PickedItemserial.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id= ser.Id,Name = ser.Name,ERP7__Serial_Number__c = ser.ERP7__Serial_Number__c);
                        PickedItemserial.Name = PickedItemserial.ERP7__Serial_Number__r.Name;
                        returnList.add(PickedItemserial);
                    }        
                }else if(obj.ERP7__Product__r.ERP7__Lot_Tracked__c){
                    pickedItem.ERP7__Batch_Lot__c = obj.ERP7__Batch_Lot__c; 
                    pickedItem.Name = obj.ERP7__Batch_Lot__r.Name;
                    pickedItem.ERP7__Batch_Lot__r = new ERP7__Batch__c(Id = obj.ERP7__Batch_Lot__c,Name = obj.ERP7__Batch_Lot__r.Name);   
                    PickedItem.ERP7__Product__c = obj.ERP7__Product__c;
                    PickedItem.ERP7__Product__r = new Product2(Id =obj.ERP7__Product__c,Name = obj.ERP7__Product__r.Name);
                    returnList.add(PickedItem);   
                }
                
            }
        }
        return returnList;
    }
    
}