public with sharing class InternalStockTransfer {
    
    @AuraEnabled
    public static List<ERP7__Cart_Putaway_Item__c> getAll(String Site,String destination,Datetime fromdate,Datetime To){
        List<ERP7__Cart_Putaway_Item__c> cartlist = [Select Id,Name,ERP7__Cart_Item__r.ERP7__Cart__r.Name,ERP7__Cart_Item__r.ERP7__Product__r.Name,ERP7__Picked_Quantity__c,ERP7__Putaway_Quantity__c,ERP7__Cart_Item__r.ERP7__From_Location__r.Name,ERP7__Site__r.Name,ERP7__To_Location__r.Name,
                                                     ERP7__Cart_Item__r.ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Cart_Item__r.ERP7__Batch_Lot__c,ERP7__Cart_Item__r.ERP7__Product__r.ERP7__Serialise__c,ERP7__Cart_Item__r.ERP7__Serial_Number__c,CreatedDate,
                                                     ERP7__Cart_Item__r.ERP7__Batch_Lot__r.Name,ERP7__Cart_Item__r.ERP7__Serial_Number__r.Name from ERP7__Cart_Putaway_Item__c 
                                                     where ERP7__Site__c =:destination and ERP7__Cart_Item__r.ERP7__Cart__r.ERP7__Site__c =:Site and CreatedDate >= :fromdate and CreatedDate < :To Order By CreatedDate ASC];
        if(cartlist.size() > 0)  return  cartlist; else return null;
    } 
    
    @AuraEnabled 
    public static String searchBarcode1(String bcode,String SiteId,String LocId ,String step,String cartPickedItem){
        
        /*-----searchBarcode-----*/
        ERP7__Cart_Picked_Item__c  PickedItem = new ERP7__Cart_Picked_Item__c();
        
        if(String.isNotBlank(cartPickedItem))  PickedItem =(ERP7__Cart_Picked_Item__c)JSON.deserialize(cartPickedItem, ERP7__Cart_Picked_Item__c.class); 
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if(String.isNotEmpty(bcode) && String.isNotEmpty(SiteId)) bcode = bcode.trim();
      
       
            List<ERP7__Location__c> locList = new List<ERP7__Location__c>();
            List<ERP7__Inventory_Stock__c> InventoryStocks = new List<ERP7__Inventory_Stock__c>();
            locList = [SELECT Id,Name,ERP7__Barcode__c FROM ERP7__Location__c  Where ERP7__Barcode__c =:bcode AND ERP7__Site__c =:SiteId ]; 
        	Id LocationId = locList[0].Id;
        	
            if(locList.size()>0){ 
                InventoryStocks = [SELECT Id,Name,ERP7__Product__c,ERP7__Warehouse__c,ERP7__Location__c FROM ERP7__Inventory_Stock__c  Where  ERP7__Location__c =:LocationId AND ERP7__Warehouse__c =:SiteId];
                
                PickedItem.ERP7__From_Location__c  = locList[0].Id;
                PickedItem.ERP7__From_Location__r =  new ERP7__Location__c(Id = locList[0].Id,Name = locList[0].Name,ERP7__Barcode__c = locList[0].ERP7__Barcode__c ); 
                PickedItem.ERP7__Product__c = InventoryStocks[0].ERP7__Product__c;
                return JSON.serialize(PickedItem);
                
            }
        
        	String qryFilter = '';
            Boolean isAsset = false;
            Boolean isSerialised = false;
            String prodId = '';
            String assetid = '';
            List<ERP7__Serial_Number__c > serialList = new List<ERP7__Serial_Number__c >();
            List<ERP7__Batch__c  > batchList = new List<ERP7__Batch__c  >();
            serialList = [SELECT Id,Name,ERP7__Product__c,ERP7__Asset__c,ERP7__Available__c,ERP7__Serial_Number__c  FROM ERP7__Serial_Number__c   Where (ERP7__Serial_Number__c  =:bcode or Name =:bcode)  AND ERP7__Available__c = true];  //AND ERP7__Warehouse__c  =:SiteId
            if(serialList.size()>0){
                isSerialised = true;
                if(serialList[0].ERP7__Asset__c != null){ assetid=serialList[0].ERP7__Asset__c ;  qryFilter = 'AND ERP7__Fixed_Asset__c =:serialList[0].ERP7__Asset__c'; 
                                                         isAsset = true; }
                else { prodId = serialList[0].ERP7__Product__c; qryFilter = 'AND ERP7__Product__c =:serialList[0].ERP7__Product__c'; 
                     } 
                return JSON.serialize(PickedItem);
            }
            
        	/*else{
            String qryFilter = '';
            Boolean isAsset = false;
            Boolean isSerialised = false;
            String prodId = '';
            String assetid = '';
            List<ERP7__Serial_Number__c > serialList = new List<ERP7__Serial_Number__c >();
            List<ERP7__Batch__c  > batchList = new List<ERP7__Batch__c  >();
            serialList = [SELECT Id,Name,ERP7__Product__c,ERP7__Asset__c,ERP7__Available__c,ERP7__Serial_Number__c  FROM ERP7__Serial_Number__c   Where (ERP7__Serial_Number__c  =:bcode or Name =:bcode)  AND ERP7__Available__c = true];  //AND ERP7__Warehouse__c  =:SiteId
            if(serialList.size()>0){
                isSerialised = true;
                if(serialList[0].ERP7__Asset__c != null){ assetid=serialList[0].ERP7__Asset__c ;  qryFilter = 'AND ERP7__Fixed_Asset__c =:serialList[0].ERP7__Asset__c'; 
                                                         isAsset = true; }
                else { prodId = serialList[0].ERP7__Product__c; qryFilter = 'AND ERP7__Product__c =:serialList[0].ERP7__Product__c'; 
                     } 
            }else{
                
                batchList = [SELECT Id,Name,ERP7__Product__c,ERP7__Asset__c   FROM ERP7__Batch__c  Where Name   =:bcode];  
                
                if(batchList.size()>0){ if(batchList[0].ERP7__Asset__c != null){   assetid= batchList[0].ERP7__Asset__c; qryFilter = 'AND ERP7__Fixed_Asset__c =:assetid'; isAsset = true; } else { prodId= batchList[0].ERP7__Product__c;qryFilter = 'AND ERP7__Product__c =:prodId';} }
                else{ gen.writeStringField ('Error','No Serial/Batch Found!'); gen.writeStringField ('step','serialcode'); gen.writeEndObject(); return gen.getAsString(); }
                
            } 
            List<ERP7__Inventory_Stock__c> stockList = new List<ERP7__Inventory_Stock__c>();
            if(String.isNotEmpty(LocId))qryFilter += ' AND ERP7__Location__c =:LocId';
            stockList = Database.query('SELECT Id,Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Product__r.Id,ERP7__Product__r.StockKeepingUnit,ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Fixed_Asset__c,ERP7__Fixed_Asset__r.Id,ERP7__Fixed_Asset__r.Name,ERP7__Fixed_Asset__r.ERP7__Serial__c,ERP7__Fixed_Asset__r.ERP7__Serial__r.Id,ERP7__Fixed_Asset__r.ERP7__Serial__r.Name,ERP7__Fixed_Asset__r.ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Location__r.Name , ERP7__Number_of_Item_In_Stock__c, ERP7__StorageContainer__c,ERP7__Warehouse__c, ERP7__Location__c,ERP7__StorageContainer__r.Name, ERP7__Batch_Lot__c , ERP7__Batch_Lot__r.Id, ERP7__Batch_Lot__r.Name FROM ERP7__Inventory_Stock__c  WHERE  ERP7__Number_of_Item_In_Stock__c > 0.00 AND ERP7__Warehouse__c =:siteId '+qryFilter); //AND (ERP7__Product__c =: prodId Or ERP7__Fixed_Asset__c=:assetid Or ERP7__Location__c =:LocId ) ');
            system.debug('stockList Qry'+ qryFilter);
            if(stockList.size()>0){
                PickedItem.ERP7__Quantity__c = 1.00; ERP7__Inventory_Stock__c stock =  stockList[0]; PickedItem.ERP7__Inventory_Stock__c =stockList[0].Id; PickedItem.ERP7__Inventory_Stock__r = new ERP7__Inventory_Stock__c(Id = stockList[0].Id,ERP7__Number_of_Sample_Items_Checked_In__c  = stockList[0].ERP7__Number_of_Item_In_Stock__c);
                
                If(isSerialised){
                    
                    PickedItem.ERP7__Serial_Number__c = serialList[0].Id;  PickedItem.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id= serialList[0].Id,Name = serialList[0].Name,ERP7__Serial_Number__c = serialList[0].ERP7__Serial_Number__c);
                    PickedItem.Name = PickedItem.ERP7__Serial_Number__r.Name;
                    if(isAsset){
                        PickedItem.ERP7__Fixed_Asset__c = stockList[0].ERP7__Fixed_Asset__c; PickedItem.ERP7__Fixed_Asset__r = new ERP7__Asset__c(Id =stockList[0].ERP7__Fixed_Asset__c,Name = stockList[0].ERP7__Fixed_Asset__r.Name);
                    }
                    else{ 
                        PickedItem.ERP7__Product__c = stockList[0].ERP7__Product__c; PickedItem.ERP7__Product__r = new Product2(Id =stockList[0].ERP7__Product__c,Name = stockList[0].ERP7__Product__r.Name,ERP7__Is_Asset__c = stockList[0].ERP7__Product__r.ERP7__Is_Asset__c);
                    }   
                }else{ 
                    pickedItem.ERP7__Batch_Lot__c = batchList[0].Id;  pickedItem.ERP7__Batch_Lot__r = new ERP7__Batch__c(Id = batchList[0].Id,Name = batchList[0].Name);   
                    //PickedItem.ERP7__Quantity__c = 1.00;
                    PickedItem.ERP7__Product__c = stockList[0].ERP7__Product__c; PickedItem.ERP7__Product__r = new Product2(Id =stockList[0].ERP7__Product__c,Name = stockList[0].ERP7__Product__r.Name); PickedItem.Name = PickedItem.ERP7__Batch_Lot__r.Name;
                }     
                return JSON.serialize(PickedItem);
            }else{ gen.writeStringField ('Error','No stock Found!'); gen.writeStringField ('step','serialcode'); gen.writeEndObject(); return gen.getAsString(); }
            
        }   */     
		return JSON.serialize(PickedItem);        
    }
    
    @AuraEnabled
    public static String searchLocation(String bcode, String SiteId){
        if (String.isNotEmpty(bcode) && String.isNotEmpty(SiteId)) {
            bcode = bcode.trim();
            ERP7__Location__c locList = [SELECT Id, Name, ERP7__Barcode__c FROM ERP7__Location__c WHERE ERP7__Barcode__c = :bcode AND ERP7__Site__c = :SiteId LIMIT 1];
            return locList.Id;
        }
        return null;
    }
    
    @AuraEnabled
    public static wrapper_Location_products searchBarcode(String bcode, String SiteId, String LocId, String step, String cartPickedItem) {
        
        wrapper_Location_products wrapperItems = new wrapper_Location_products();
        
        if (String.isNotEmpty(bcode) && String.isNotEmpty(SiteId)) {
            bcode = bcode.trim();
            List<ERP7__Location__c> locList = [SELECT Id, Name, ERP7__Barcode__c FROM ERP7__Location__c WHERE ERP7__Barcode__c = :bcode AND ERP7__Site__c = :SiteId LIMIT 1];
            List<ERP7__Cart_Picked_Item__c> pickedItemList = new List<ERP7__Cart_Picked_Item__c>();

            if (locList.Size()>0) {
                Id LocationId = locList[0].Id;
                ERP7__Cart_Picked_Item__c pickedItem1 = new ERP7__Cart_Picked_Item__c();
                if(cartPickedItem != null && cartPickedItem != ''){
                 pickedItem1 = (ERP7__Cart_Picked_Item__c) JSON.deserialize(cartPickedItem,ERP7__Cart_Picked_Item__c.class);
                
                }
                Id prodId = pickedItem1.ERP7__Product__c;
                Id BatchId = pickedItem1.ERP7__Batch_Lot__c;
                Id SerialId = pickedItem1.ERP7__Serial_Number__c; 
                if(prodId != null){
                    pickedItem1.ERP7__From_Location__c = LocationId;
                    system.debug('pickedItem1 : '+pickedItem1);
                    InvWrap invwrp = fetchProductSiteInvStock(prodId,SiteId,LocationId,BatchId,SerialId);
                    pickedItemList.add(pickedItem1);
                    integer j=0;
                    wrapper_PickedItem1 wrappicked = new wrapper_PickedItem1();
                    wrappicked.cpi = pickedItem1;
                    wrappicked.index = j++;
                    wrappicked.invdetails = invwrp;
                    wrapperItems.PickedItemWrapList.add(wrappicked);
                   return wrapperItems;
                }
              /*  List<ERP7__Inventory_Stock__c> InventoryStocks = [SELECT Id, Name, ERP7__Product__c, ERP7__Warehouse__c, ERP7__Location__c FROM ERP7__Inventory_Stock__c WHERE ERP7__Location__c = :LocationId AND ERP7__Warehouse__c = :SiteId];
                List<ERP7__Cart_Picked_Item__c> pickedItemList = new List<ERP7__Cart_Picked_Item__c>();
                
                for (Integer i = 0; i < InventoryStocks.size(); i++) {
                    ERP7__Cart_Picked_Item__c pickedItem1 = new ERP7__Cart_Picked_Item__c();
                    pickedItem1.ERP7__From_Location__c = LocationId;
                    pickedItem1.ERP7__Product__c = InventoryStocks[i].ERP7__Product__c;
                    pickedItemList.add(pickedItem1);
                }
                if (!InventoryStocks.isEmpty()) {
                    Integer j = 0;
                    for(ERP7__Cart_Picked_Item__c cpi:pickedItemList){
                        wrapper_PickedItem1 wrappicked = new wrapper_PickedItem1();
                        wrappicked.cpi = cpi;
                        wrappicked.index = j++;
                        wrapperItems.PickedItemWrapList.add(wrappicked);
                    } 
                    
                    system.debug('inside wrapperItems:'+wrapperItems);
                    return wrapperItems;
                    //return JSON.serialize(wrapperItems);
                }*/
            }
            
            List<Product2> ProductList = [SELECT Id, Name, ERP7__Barcode__c FROM Product2 WHERE Name = :bcode OR ProductCode = :bcode OR ERP7__Barcode__c= :bcode Limit 1];
            if(ProductList.size() > 0){
                Id prodId = ProductList[0].Id;
                if(prodId != null){
                    ERP7__Cart_Picked_Item__c pickedItem1 = new ERP7__Cart_Picked_Item__c();
                    pickedItem1.ERP7__Product__c = prodId;
                    InvWrap invwrp = fetchProductSiteInvStock(prodId,SiteId,LocId,'','');
                    pickedItemList.add(pickedItem1);
                    integer j=0;
                    wrapper_PickedItem1 wrappicked = new wrapper_PickedItem1();
                    wrappicked.cpi = pickedItem1;
                    wrappicked.index = j++;
                    wrappicked.invdetails = invwrp;
                    wrapperItems.PickedItemWrapList.add(wrappicked);
                   return wrapperItems;
                }
                
            }
            
            
			List<ERP7__Batch__c> BacthList = [SELECT Id, Name, ERP7__Barcode__c, ERP7__Product__c FROM ERP7__Batch__c WHERE (Name = :bcode OR ERP7__Barcode__c= :bcode) And ERP7__Available_Quantity__c > 0 And ERP7__Expired__c=false Limit 1];
            if(BacthList.size() > 0){
                Id prodId = BacthList[0].ERP7__Product__c;
                Id BatchId = BacthList[0].Id;
                if(prodId != null){
                    ERP7__Cart_Picked_Item__c pickedItem1 = new ERP7__Cart_Picked_Item__c();
                    pickedItem1.ERP7__Product__c = prodId;
                    pickedItem1.ERP7__Batch_Lot__c = BatchId;
                    InvWrap invwrp = fetchProductSiteInvStock(prodId,SiteId,LocId,BatchId,'');
                    pickedItemList.add(pickedItem1);
                    integer j=0;
                    wrapper_PickedItem1 wrappicked = new wrapper_PickedItem1();
                    wrappicked.cpi = pickedItem1;
                    wrappicked.index = j++;
                    wrappicked.invdetails = invwrp;
                    wrapperItems.PickedItemWrapList.add(wrappicked);
                   return wrapperItems;
                }
                /*ERP7__Cart_Picked_Item__c pickedItem1 = new ERP7__Cart_Picked_Item__c();
                pickedItem1.ERP7__Product__c = prodId;
                pickedItem1.ERP7__Batch_Lot__c = BatchId;
                //pickedItemList.add(pickedItem1);
                integer j=0;
                wrapper_PickedItem1 wrappicked = new wrapper_PickedItem1();
                wrappicked.cpi = pickedItem1;
                wrappicked.index = j++;
                wrapperItems.PickedItemWrapList.add(wrappicked);
                return wrapperItems;*/
            }            
            
            List<ERP7__Serial_Number__c> SerailList = [SELECT Id, Name, ERP7__Barcode__c,ERP7__Material_Batch_Lot__c, ERP7__Product__c FROM ERP7__Serial_Number__c WHERE (Name = :bcode OR ERP7__Barcode__c= :bcode) And ERP7__Available__c=true Limit 1];
            if(SerailList.size() > 0){
                Id prodId = SerailList[0].ERP7__Product__c;
                Id BatchId = SerailList[0].ERP7__Material_Batch_Lot__c;
                Id SerialId = SerailList[0].Id;
                if(prodId != null){
                    ERP7__Cart_Picked_Item__c pickedItem1 = new ERP7__Cart_Picked_Item__c();
                    pickedItem1.ERP7__Product__c = prodId;
                    pickedItem1.ERP7__Batch_Lot__c = BatchId;
                    pickedItem1.ERP7__Serial_Number__c = SerialId;
                    InvWrap invwrp = fetchProductSiteInvStock(prodId,SiteId,LocId,BatchId,SerialId);
                    pickedItemList.add(pickedItem1);
                    integer j=0;
                    wrapper_PickedItem1 wrappicked = new wrapper_PickedItem1();
                    wrappicked.cpi = pickedItem1;
                    wrappicked.index = j++;
                    wrappicked.invdetails = invwrp;
                    wrapperItems.PickedItemWrapList.add(wrappicked);
                   return wrapperItems;
                }

               /* ERP7__Cart_Picked_Item__c pickedItem1 = new ERP7__Cart_Picked_Item__c();
                pickedItem1.ERP7__Product__c = prodId;
                pickedItem1.ERP7__Batch_Lot__c = BatchId;
                pickedItem1.ERP7__Serial_Number__c = SerialId;
                //pickedItemList.add(pickedItem1);
                integer j=0;
                wrapper_PickedItem1 wrappicked = new wrapper_PickedItem1();
                wrappicked.cpi = pickedItem1;
                wrappicked.index = j++;
                wrapperItems.PickedItemWrapList.add(wrappicked);
                return wrapperItems;*/
            }
            
        }
        wrapperItems.errMsg = 'No Products/batch/Serial avaialble with barcode : '+bcode;
        return wrapperItems;
    }

    public class wrapper_PickedItem1{
        @AuraEnabled 
        public Integer index { get; set; }
        @AuraEnabled 
        public ERP7__Cart_Picked_Item__c cpi { get; set; }
        @AuraEnabled 
        public InvWrap invdetails { get; set; }
        public wrapper_PickedItem1(){
            cpi = new ERP7__Cart_Picked_Item__c();
            index = 0;
            invdetails = new InvWrap();
        }
    }
    
    
    
    

    
    public class wrapper_Location_products{
        
        @AuraEnabled 
        public List<wrapper_PickedItem1> PickedItemWrapList { get; set; }
        @AuraEnabled 
        public string errMsg { get; set; }
        public wrapper_Location_products(){
            PickedItemWrapList = new List<wrapper_PickedItem1>();
            errMsg = '';
        }
    }
    @AuraEnabled
    public static ERP7__Site__c searchwarehouse(String bcode){
        List<ERP7__Site__c> searchList = new List<ERP7__Site__c>();
        searchList  = [Select Id,Name FROM ERP7__Site__c where Barcode__c =:bcode.trim()];
        
        if(searchList.size()>0) return searchList[0]; else return null;
        
    }
    
    @AuraEnabled
    public static ERP7__Cart__c createCart(String cart1) {
        ERP7__Cart__c cart = (ERP7__Cart__c) JSON.deserialize(cart1, ERP7__Cart__c.class); cart.ERP7__Active__c=true;
        if (cart != null) {
            if (Schema.SObjectType.ERP7__Cart__c.isCreateable() && Schema.SObjectType.ERP7__Cart__c.isUpdateable()) { upsert cart; } else{ }
        }
        return cart;
    }
    
    @AuraEnabled
    public static list < ERP7__Cart__c > getCartDetails() {
        List < ERP7__Cart__c > cart;
        cart = [select id, name, ERP7__Employee__c, ERP7__Employee__r.Name, ERP7__Site__c, ERP7__Account__c, ERP7__Account__r.Name, ERP7__Cart__c, ERP7__Channel__c, CreatedDate
                from ERP7__Cart__c where ERP7__Active__c=true
               ];
        return cart;
    }
    
    
    @AuraEnabled
    public static list < ERP7__Cart_Picked_Item__c > getCartItemDetails(String cartId) {
        List < ERP7__Cart_Picked_Item__c > cartInfo;
        cartInfo = [select id, name, ERP7__Cart__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Quantity__c,
                    ERP7__From_Location__c, ERP7__From_Location__r.Name, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c
                    from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =: cartId
                   ];
        return cartInfo;
    }
    
    @AuraEnabled
    public static List<ERP7__Cart_Putaway_Item__c> createCartputawayItem(String cartId) {
        /*inside createCartputawayItem :'+cartId)*/
        List<ERP7__Cart_Putaway_Item__c> listofputawayItems = new List<ERP7__Cart_Putaway_Item__c>();
        if(String.isNotEmpty(cartId)){
            for(ERP7__Cart_Picked_Item__c CartPickedItem : [SELECT Id, Name,ERP7__From_Location__c,ERP7__Picked_Quantity__c ,ERP7__From_Location__r.Name ,ERP7__Quantity__c , ERP7__Cart__c, ERP7__Batch_Lot__c, ERP7__Product__c,ERP7__Serial_Number__r.Id,ERP7__Serial_Number__r.Name, 
                                                            ERP7__Serial_Number__c, ERP7__Product__r.Id,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Serialise__c ,ERP7__Total_Putaway_Quantity__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Batch_Lot__r.Id,ERP7__Batch_Lot__r.Name,  
                                                            ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.Name, ERP7__Inventory_Stock__c , ERP7__Inventory_Stock__r.Name, ERP7__Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c,ERP7__Available_Stock__c,ERP7__Remaining_Quantity__c from ERP7__Cart_Picked_Item__c  
                                                            where ERP7__Cart__c  =: cartId And ERP7__Remaining_Quantity__c  > 0]){ 
                                                                ERP7__Cart_Putaway_Item__c putawayItems = new ERP7__Cart_Putaway_Item__c(Name = CartPickedItem.Name,ERP7__Cart_Item__c = CartPickedItem.id,ERP7__To_Location__c=null,ERP7__Putaway_Quantity__c= CartPickedItem.ERP7__Remaining_Quantity__c);
                                                                
                                                                putawayItems.ERP7__Cart_Item__r = new ERP7__Cart_Picked_Item__c(Id=CartPickedItem.id,Name = CartPickedItem.Name,ERP7__Quantity__c = CartPickedItem.ERP7__Remaining_Quantity__c,ERP7__Product__c = CartPickedItem.ERP7__Product__c,ERP7__Product__r = new Product2(Id =CartPickedItem.ERP7__Product__c,Name = CartPickedItem.ERP7__Product__r.Name), ERP7__Fixed_Asset__c = CartPickedItem.ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r = new ERP7__Asset__c(Id = CartPickedItem.ERP7__Fixed_Asset__c,Name = CartPickedItem.ERP7__Fixed_Asset__r.Name), ERP7__Serial_Number__c = CartPickedItem.ERP7__Serial_Number__c, ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id = CartPickedItem.ERP7__Serial_Number__c, Name = CartPickedItem.ERP7__Serial_Number__r.Name), ERP7__Batch_Lot__c = CartPickedItem.ERP7__Batch_Lot__c, ERP7__Batch_Lot__r = new ERP7__Batch__c(Id = CartPickedItem.ERP7__Batch_Lot__c, Name = CartPickedItem.ERP7__Batch_Lot__r.Name));
                                                                
                                                                listofputawayItems.add(putawayItems);
                                                            }                  
        }   
        return listofputawayItems;
    }
    
    @AuraEnabled
    public static void saveCartputawayItem(String items,String siteId){
        List<ERP7__Cart_Putaway_Item__c> listofputawayItems = new List<ERP7__Cart_Putaway_Item__c>();
        
        listofputawayItems = (List<ERP7__Cart_Putaway_Item__c>) JSON.deserialize(items, List<ERP7__Cart_Putaway_Item__c>.class);
        if(listofputawayItems.size()>0 && Schema.sObjectType.ERP7__Cart_Putaway_Item__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Putaway_Item__c.isUpdateable()) { upsert listofputawayItems; } else{ }
    }
    
    //prodChange cartPickItem
    @AuraEnabled
    public static Product2 fetchProductDetails(String currProdId){
        Product2 currProduct = [SELECT Id, Name, ERP7__Lot_Tracked__c, ERP7__Serialise__c FROM Product2 WHERE Id =: currProdId LIMIT 1];
        return currProduct;
    }
    
    @AuraEnabled
    public static InvWrap fetchProductSiteInvStock(String currProdId,String site,String fromLocation,String batch,String serial){
        try{
            //New Code added by Arshad 29/05/2023
            Product2 prod = new Product2();
            InvWrap wr=new InvWrap();
            String iSFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
            utilClass.FLSCheck(iSFields.split(','),'ERP7__Inventory_Stock__c');
            List<ERP7__Inventory_Stock__c> productInventories = new List<ERP7__Inventory_Stock__c>();
            
            List<ERP7__Inventory_Stock__c> AllProductInventories = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Inventory_Stock__c> SingleProductInventories = new List<ERP7__Inventory_Stock__c>();
            Set<String> availLocIds = new Set<String>();
            Set<String> availBatchIds = new Set<String>();
            Set<String> availSerialIds = new Set<String>();
            
            if(String.isNotEmpty(currProdId)){
                List<Product2> prolist = [Select Id, Name, ERP7__Lot_Tracked__c, ERP7__Serialise__c from product2 where Id =:currProdId Limit 1];
                if(prolist.size() > 0){
                    prod = prolist[0];
                    String prodId = prod.Id;
                    if(prod.ERP7__Serialise__c) wr.isSerial = true;
                    if(prod.ERP7__Lot_Tracked__c) wr.isBatch = true;
                    
                    system.debug('prodId~>'+prodId);
                    system.debug('site~>'+site);
                    system.debug('fromLocation~>'+fromLocation);
                    system.debug('batch~>'+batch);
                    system.debug('serial~>'+serial);
                    
                    system.debug('wr.isBatch~>'+wr.isBatch);
                    system.debug('wr.isSerial~>'+wr.isSerial);
                    
                    String invqry = 'select ' + String.escapeSingleQuotes(iSFields) + '  from ERP7__Inventory_Stock__c where (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 or Name=\'Serial Stock Holder\')) AND ERP7__Active__c = true AND ERP7__Warehouse__c != null AND ERP7__Product__c != null AND ERP7__Product__r.IsActive = true And ERP7__Product__r.ERP7__Track_Inventory__c = true AND ERP7__Product__c =: prodId ';
                    
                    if(String.isNotEmpty(site)) invqry += ' AND ERP7__Warehouse__c =: site ';
                    if(String.isNotEmpty(fromLocation)){
                        if(String.isNotEmpty(site)) invqry += ' AND ERP7__Location__c =: fromLocation AND ERP7__Location__r.ERP7__Site__c =: site ';
                        else invqry += ' AND ERP7__Location__c =: fromLocation ';
                    }
                    
                    if(String.isNotEmpty(batch)) invqry += ' AND ERP7__Batch_Lot__c =: batch ';
                    if(String.isNotEmpty(serial)) invqry += ' AND ERP7__Serial__c =: serial ';
                    if(wr.isBatch) invqry += ' AND ERP7__Batch_Lot__c != null AND ERP7__Batch_Lot__r.ERP7__Expired__c = false AND ERP7__Batch_Lot__r.ERP7__Available_Quantity__c > 0 AND ERP7__Batch_Lot__r.ERP7__Product__c =: prodId ';
                    if(wr.isSerial) invqry += ' AND ERP7__Serial__c != null And ERP7__Serial__r.ERP7__Expired__c = false AND ERP7__Serial__r.ERP7__Product__c =: prodId AND ERP7__Serial__r.ERP7__Available__c = true ';
                    
                    invqry += 'Order By ERP7__Number_of_Item_In_Stock__c,CreatedDate DESC ';
                    //if(wr.isSerial) invqry += ' LIMIT 1 '; 
                    invqry += ' LIMIT 9000 ';
                    AllProductInventories = Database.query(invqry);
                    
                    
                    invqry = 'select ' + String.escapeSingleQuotes(iSFields) + '  from ERP7__Inventory_Stock__c where (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 or Name=\'Serial Stock Holder\')) AND ERP7__Active__c = true AND ERP7__Warehouse__c != null AND ERP7__Product__c != null AND ERP7__Product__r.IsActive = true And ERP7__Product__r.ERP7__Track_Inventory__c = true AND ERP7__Product__c =: prodId ';
                    
                    if(String.isNotEmpty(site)) invqry += ' AND ERP7__Warehouse__c =: site ';
                    if(String.isNotEmpty(fromLocation)){ if(String.isNotEmpty(site)) invqry += ' AND ERP7__Location__c =: fromLocation AND ERP7__Location__r.ERP7__Site__c =: site '; else invqry += ' AND ERP7__Location__c =: fromLocation '; }
                    else invqry += ' AND ERP7__Location__c = null ';
                    
                    if(String.isNotEmpty(batch)) invqry += ' AND ERP7__Batch_Lot__c =: batch '; else invqry += ' AND ERP7__Batch_Lot__c = null ';
                    if(String.isNotEmpty(serial)) invqry += ' AND ERP7__Serial__c =: serial '; else invqry += ' AND ERP7__Serial__c = null ';
                    
                    invqry += 'Order By ERP7__Number_of_Item_In_Stock__c,CreatedDate DESC ';
                    invqry += ' LIMIT 1 ';
                    
                    SingleProductInventories = Database.query(invqry);
                }
            }
            
            system.debug('SingleProductInventories.size()~>'+SingleProductInventories.size());
            system.debug('AllProductInventories.size()~>'+AllProductInventories.size());
            
            if(AllProductInventories.size() > 0){
                for(ERP7__Inventory_Stock__c IS : AllProductInventories) { 
                    if(IS.ERP7__Location__c != null){ system.debug('availLocIds- length-->'+availLocIds.size());availLocIds.add(IS.ERP7__Location__c); } 
                    if(IS.ERP7__Batch_Lot__c != null){ availBatchIds.add(IS.ERP7__Batch_Lot__c); } 
                    if(IS.ERP7__Serial__c != null){ availSerialIds.add(IS.ERP7__Serial__c); } 
                }
            }
            
            if (SingleProductInventories.size() > 0) {
                wr.inventory = SingleProductInventories[0].Id; 
                if(wr.isSerial && wr.isBatch) wr.batchId = SingleProductInventories[0].ERP7__Batch_Lot__c;
                system.debug('wr.inventory~>'+wr.inventory);
                
                //for lookups options
                
                Decimal totalQuantity = 0; 
                if(wr.isSerial){ totalQuantity = SingleProductInventories[0].ERP7__Number_of_Item_In_Stock__c; }
                else{ for(ERP7__Inventory_Stock__c IS : SingleProductInventories) { if(IS.ERP7__Number_of_Item_In_Stock__c > 0) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c; } }
                
                wr.totalQuantity = totalQuantity;
            }else{ wr.totalQuantity=0; }
            
            wr.availLocIds = availLocIds;
            wr.availBatchIds = availBatchIds;
            wr.availSerialIds = availSerialIds;
            system.debug('wr.totalQuantity~>'+wr.totalQuantity);
            system.debug('wr.availLocIds~>'+wr.availLocIds);
            system.debug('wr.availBatchIds~>'+wr.availBatchIds);
            system.debug('wr.availSerialIds~>'+wr.availSerialIds);
            //New Code added by Arshad 29/05/2023
            
            /*
InvWrap wr=new InvWrap();
boolean isbatchAndserial = false;

if(currProdId != null || currProdId != ''){
List<Product2> prolist = [Select Id, Name, ERP7__Lot_Tracked__c, ERP7__Serialise__c from product2 where Id =:currProdId Limit 1];
if(prolist.size() > 0){
Product2 pro = prolist[0]; //new Product2();
if(pro.ERP7__Lot_Tracked__c && pro.ERP7__Serialise__c){ wr.isSerial=true; isbatchAndserial = true; }
else if(pro.ERP7__Serialise__c) wr.isSerial=true;
else if(pro.ERP7__Lot_Tracked__c) wr.isBatch=true;
else{ wr.isBatch=false;wr.isSerial=false; }
}
}

List<ERP7__Inventory_Stock__c> productInventories=new List<ERP7__Inventory_Stock__c>();
if(site != null || site != ''){
if(wr.isSerial && isbatchAndserial && fromLocation == ''){ wr.qno=13; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =:null AND ERP7__Batch_Lot__c !=null and ERP7__Serial__c != null Order By CreatedDate DESC Limit 1]; }
else if(fromLocation != '' && batch !=''){ wr.qno=1; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =:fromLocation AND ERP7__Batch_Lot__c =:batch Order By CreatedDate DESC Limit 1]; }
else if(fromLocation != '' && serial !=''){ wr.qno=2; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =:fromLocation AND ERP7__Serial__c=:serial Order By CreatedDate DESC Limit 1]; }
else if(fromLocation == '' && batch !=''){ wr.qno=3; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =null AND ERP7__Batch_Lot__c =:batch Order By CreatedDate DESC Limit 1]; }
else if(fromLocation == '' && serial !=''){ wr.qno=4; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =null AND ERP7__Serial__c=:serial Order By CreatedDate DESC Limit 1]; }
else if(fromLocation != '' && batch =='' && serial ==''){ wr.qno=5; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =:fromLocation AND ERP7__Batch_Lot__c = null AND ERP7__Serial__c = null Limit 1]; }
else if(fromLocation == '' && batch =='' && serial ==''){ wr.qno=6; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =null AND ERP7__Batch_Lot__c = null AND ERP7__Serial__c = null Limit 1]; }
}
//else if(fromLocation == '' && (batch !='' || serial !='')) {wr.qno=5; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Warehouse__c =:site  AND ERP7__Location__c =null AND (ERP7__Batch_Lot__c =:batch OR ERP7__Serial__c=:serial)];}
if(site == null || site == ''){
if(fromLocation != '' && batch !=''){wr.qno=7; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0   AND ERP7__Location__c =:fromLocation AND ERP7__Batch_Lot__c =:batch Order by ERP7__Number_of_Item_In_Stock__c ASC Limit 1 ];}
else if(fromLocation != '' && serial !=''){wr.qno=8; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0   AND ERP7__Location__c =:fromLocation AND ERP7__Serial__c=:serial Order by ERP7__Number_of_Item_In_Stock__c ASC Limit 1];}
else if(fromLocation == '' && batch !=''){wr.qno=9; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0    AND ERP7__Location__c =null AND ERP7__Batch_Lot__c =:batch Order by ERP7__Number_of_Item_In_Stock__c ASC Limit 1];}
else if(fromLocation == '' && serial !=''){wr.qno=10; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0    AND ERP7__Location__c =null AND ERP7__Serial__c=:serial Order by ERP7__Number_of_Item_In_Stock__c ASC Limit 1];}

else if(fromLocation != '' && batch =='' && serial ==''){wr.qno=11; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0   AND ERP7__Location__c =:fromLocation AND ERP7__Batch_Lot__c =null AND ERP7__Serial__c=null Order by ERP7__Number_of_Item_In_Stock__c ASC Limit 1];}
else if(fromLocation == '' && batch =='' && serial ==''){wr.qno=12; productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0   AND ERP7__Location__c =null AND ERP7__Batch_Lot__c =null AND ERP7__Serial__c=null Order by ERP7__Number_of_Item_In_Stock__c ASC Limit 1];}

}
if (productInventories.size()>0) {
Decimal totalQuantity = 0; 
for(ERP7__Inventory_Stock__c IS : productInventories) { wr.inventory=IS.Id;  totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c; }
wr.totalQuantity=totalQuantity;
}else{ wr.totalQuantity=0; }
*/
          system.debug('No issue till here?');   
            return wr; } catch (Exception ex){ system.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString());   throw new AuraHandledException(ex.getMessage()+'; at line ~> '+ex.getStackTraceString());  }
    }
    
    public class InvWrap{
        @AuraEnabled public Decimal totalQuantity { get; set; }
        @AuraEnabled public Decimal qno { get; set; }
        @AuraEnabled public boolean isBatch { get; set; }
        @AuraEnabled public boolean isSerial { get; set; }
        @AuraEnabled public String inventory { get; set; }
        @AuraEnabled public String batchId { get; set; }
        //New Code added by Arshad 29/05/2023
        @AuraEnabled public Set<String> availLocIds { get; set; }
        @AuraEnabled public Set<String> availBatchIds { get; set; }
        @AuraEnabled public Set<String> availSerialIds { get; set; }
        
        public InvWrap(){
            totalQuantity=qno=0;
            isBatch=isSerial=false;
            inventory='';
            batchId = '';
            availLocIds = availBatchIds = availSerialIds = new Set<String>();
            
        }
    }
    
    @AuraEnabled
    public static Decimal fetchProductInventoryStock(String currProdId){
        List<ERP7__Inventory_Stock__c> productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0];
        if (productInventories != null && productInventories.size()>0) { Decimal totalQuantity = 0; for(ERP7__Inventory_Stock__c IS : productInventories) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c;  return totalQuantity; }
        return 0;
    }
    
    @AuraEnabled
    public static Decimal fetchBatchProductInventoryStock(String currProdId, String currBatchLot){
        List<ERP7__Inventory_Stock__c> productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Batch_Lot__c =: currBatchLot AND ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0];
        if (productInventories != null && productInventories.size()>0) {
            Decimal totalQuantity = 0; for(ERP7__Inventory_Stock__c IS : productInventories) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c; 
            return totalQuantity;
        }
        return 0;
    }
    //prodChange cartPickItem end
    
    @AuraEnabled
    public static ERP7__Cart__c getSiteofCartDetails(String siteId) {
        /*inside getSiteofCartDetails :'+siteId)*/
        List<ERP7__Cart__c> cartList = new List<ERP7__Cart__c>();
        cartList = [select id, name, ERP7__Employee__c, ERP7__Employee__r.Name, ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Site__c,ERP7__Site__r.Id,ERP7__Site__r.Name, ERP7__Account__c, ERP7__Account__r.Name, ERP7__Cart__c, ERP7__Channel__c, CreatedDate
                    from ERP7__Cart__c where ERP7__Active__c=true AND ERP7__Site__c =: siteId  order by ERP7__Site__c Limit 1 ]; //or ERP7__Employee__r.ERP7__Employee_User__c =: UserInfo.getUserId()
        if(cartList.size()>0) return cartList[0];
        return new ERP7__Cart__c(ERP7__Site__c = siteId);
    }
    
    @AuraEnabled
    public static ERP7__Cart__c getScannedCartDetails(String siteId,String SacnnedValue) {
        /*inside getSiteofCartDetails :'+siteId)*/
        List<ERP7__Cart__c> cartList = new List<ERP7__Cart__c>();
        String searchCartByName='%'+SacnnedValue+'%';
        cartList = [select id, name, ERP7__Employee__c, ERP7__Employee__r.Name, ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Site__c,ERP7__Site__r.Id,ERP7__Site__r.Name, ERP7__Account__c, ERP7__Account__r.Name, ERP7__Cart__c, ERP7__Channel__c, CreatedDate
                    from ERP7__Cart__c where ERP7__Active__c=true AND ERP7__Site__c =: siteId And (Name like: searchCartByName) order by ERP7__Site__c Limit 1 ]; //or ERP7__Employee__r.ERP7__Employee_User__c =: UserInfo.getUserId()
        if(cartList.size()>0) return cartList[0];
        return new ERP7__Cart__c(ERP7__Site__c = siteId);
    }
    
    @AuraEnabled
    public static String delSlctRec(String slctRec){ 
        /*inside slctRec is :'+slctRec*/
        List<ERP7__Cart_Picked_Item__c> delcartPickList = new List<ERP7__Cart_Picked_Item__c>();
        if(String.isNotEmpty(slctRec)){
            for(String s :slctRec.split(','))     
                if(s instanceof Id){
                    ERP7__Cart_Picked_Item__c item = new ERP7__Cart_Picked_Item__c(Id=s);
                    delcartPickList.add(item);
                }
        }
        
        if(ERP7__Cart_Picked_Item__c.sObjectType.getDescribe().isDeletable()) { delete delcartPickList; } else{ }
        
        return 'SUCCESS';
        
    } 
    
    public class wrapper_PickedItem{
        @AuraEnabled 
        public Integer index { get; set; }
        @AuraEnabled 
        public ERP7__Cart_Picked_Item__c cpi { get; set; }
        public wrapper_PickedItem(Integer index,ERP7__Cart_Picked_Item__c cpi){
            this.index = index;
            this.cpi = cpi;
        }
    }
    
    @AuraEnabled  
    public static List<wrapper_PickedItem> fetchCartPickedDetails(String cartId){
        List<wrapper_PickedItem> wrapperItems = new List<wrapper_PickedItem>();
        /*inside fetchCartPickedDetails is :'+cartId*/
        Integer i=0;
        for(ERP7__Cart_Picked_Item__c cpi:[Select Id, Name,ERP7__From_Location__c,ERP7__From_Location__r.Name ,ERP7__Quantity__c , ERP7__Cart__c, ERP7__Batch_Lot__c, ERP7__Product__c,ERP7__Serial_Number__r.Id,ERP7__Serial_Number__r.Name, 
                                           ERP7__Serial_Number__c, ERP7__Product__r.Id,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Serialise__c ,ERP7__Total_Putaway_Quantity__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Batch_Lot__r.Id,ERP7__Batch_Lot__r.Name,  
                                           ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Remaining_Quantity__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.Name, ERP7__Inventory_Stock__c , ERP7__Inventory_Stock__r.Name, ERP7__Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c,ERP7__Available_Stock__c  From ERP7__Cart_Picked_Item__c 
                                           where ERP7__Cart__c=:cartId AND ERP7__Remaining_Quantity__c  > 0])
            If(cpi.ERP7__Total_Putaway_Quantity__c <= cpi.ERP7__Quantity__c ){
                cpi.ERP7__Quantity__c = cpi.ERP7__Remaining_Quantity__c; wrapperItems.add(new wrapper_PickedItem(i++, cpi));
            }
        
        return wrapperItems;
        
    }
    
    @AuraEnabled
    public static String getLocationByBarcode(String bcode,String SiteId){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        system.debug('SiteId : '+SiteId);
        system.debug('bcode : '+bcode);
        if(!String.isEmpty(bcode)){ 
            List<ERP7__Location__c> locList = new List<ERP7__Location__c>();
            bcode = bcode.trim();
            locList = [SELECT Id,Name,ERP7__Barcode__c FROM ERP7__Location__c  Where ERP7__Barcode__c =:bcode AND ERP7__Site__c =:SiteId ];  
            if(locList.size()>0){  gen.writeStringField ('Error',''); gen.writeStringField ('Id',locList[0].Id); gen.writeStringField ('Name',locList[0].Name);
                                }  
            else{
                gen.writeStringField ('Id','');
                gen.writeStringField ('Name','');
                gen.writeStringField ('Error','No Location Found!');
            }
        }
        
        gen.writeEndObject();
        return gen.getAsString();
        
    }
    
    @AuraEnabled
    public static ERP7__Cart_Picked_Item__c saveCartItem(String pickeditem){
        
        ERP7__Cart_Picked_Item__c returnItem = (ERP7__Cart_Picked_Item__c)JSON.deserialize(pickeditem, ERP7__Cart_Picked_Item__c.class);
        
        /*returnItem Invetory:'+returnItem.ERP7__Inventory_Stock__c)*/
        /*if(returnItem.ERP7__Inventory_Stock__c == null && returnItem.ERP7__Batch_Lot__c == null && returnItem.ERP7__Serial_Number__c==null){ 
ERP7__Cart__c cart=[Select Id,ERP7__Site__c from ERP7__Cart__c where Id=:returnItem.ERP7__Cart__c  AND ERP7__Active__c=trueLimit 1];
ERP7__Inventory_Stock__c inv=[Select Id,Name from ERP7__Inventory_Stock__c where ERP7__Active__c=true AND ERP7__Number_of_Item_In_Stock__c>0 AND ERP7__Product__c=:returnItem.ERP7__Product__c AND ERP7__Warehouse__c=:cart.ERP7__Site__c Limit 1]; 
returnItem.ERP7__Inventory_Stock__c=inv.Id;
}
'returnItem Invetory:'+returnItem.ERP7__Inventory_Stock__c);*/
        //if(returnItem.Id == null)
        
        if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Picked_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Picked_Quantity__c.isUpdateable()) returnItem.ERP7__Picked_Quantity__c = (returnItem.ERP7__Total_Putaway_Quantity__c != null)?(returnItem.ERP7__Quantity__c + returnItem.ERP7__Total_Putaway_Quantity__c):returnItem.ERP7__Quantity__c;
        if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.isUpdateable()) { upsert returnItem; } else { }
        
        return [Select Id, Name,ERP7__Remaining_Quantity__c ,ERP7__From_Location__c,ERP7__From_Location__r.Name ,ERP7__Quantity__c , ERP7__Cart__c, ERP7__Batch_Lot__c, ERP7__Product__c,ERP7__Serial_Number__r.Id,ERP7__Serial_Number__r.Name, 
                ERP7__Serial_Number__c, ERP7__Picked_Quantity__c,ERP7__Product__r.Id,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Serialise__c ,ERP7__Total_Putaway_Quantity__c,ERP7__Product__r.ERP7__Is_Asset__c,ERP7__Batch_Lot__r.Id,ERP7__Batch_Lot__r.Name,  
                ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.Name, ERP7__Inventory_Stock__c , ERP7__Inventory_Stock__r.Name, ERP7__Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c,ERP7__Available_Stock__c  From ERP7__Cart_Picked_Item__c 
                where Id=:returnItem.Id];
    }
    
    
    @AuraEnabled
    public static wrapSerial PreparePickSerialNos(String productId,String searchString,String siteID,String locId,string lmt,List<string> serialIds){
        wrapSerial wrapS = new wrapSerial();
        try{
            String srchString = (searchString != null && searchString != '') ? searchString : '';
            
            List<SerialWrapper> serlist = new  List<SerialWrapper>();
            List<ERP7__Inventory_Stock__c> invlist = new List<ERP7__Inventory_Stock__c>();
            String query = 'Select Id,Name,ERP7__Serial__c,ERP7__Product__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where ERP7__Product__c=:productId and (ERP7__Number_of_Item_In_Stock__c > 0 OR (ERP7__Number_of_Item_In_Stock__c < 0 or Name=\'Serial Stock Holder\')) AND ERP7__Active__c = true AND ERP7__Warehouse__c != null AND ERP7__Product__c != null and ERP7__Serial__c != null and ERP7__Serial__r.ERP7__Available__c = true';
            if(siteID != null && siteID != '') query += '  and ERP7__Warehouse__c = :siteID';
            if(locId != null && locId != '') query += '  and ERP7__Location__c= :locId';
            else query += '  and ERP7__Location__c=null';
            if(srchString != null && srchString != '') query += ' and (ERP7__Serial__r.Name like :srchString or ERP7__Serial__r.ERP7__Barcode__c like :srchString)';
            if(serialIds != null && serialIds.size() > 0) query += '  and ERP7__Serial__c NOT IN :serialIds';
            query += ' Order By ERP7__Serial__r.Name ASC ';
            query +=  'Limit '+lmt;
            invlist  = database.query(query);
            system.debug('invlist.size() : '+invlist.size());
            if(invlist.size() == 0){
                SerialWrapper SW = new SerialWrapper();
                wrapS.error = 'No Serial Number Available';
                serlist.add(SW);
            }
            else if(invlist.size() == 1){
                SerialWrapper SW = new SerialWrapper();
                SW.isSelected = true;
                SW.SerialNo = new ERP7__Serial_Number__c(Id = invlist[0].ERP7__Serial__c,Name = invlist[0].ERP7__Serial__r.Name,ERP7__Barcode__c = invlist[0].ERP7__Serial__r.ERP7__Barcode__c);
                serlist.add(SW);
            }
            else if(invlist.size() > 0){
                for(ERP7__Inventory_Stock__c inv : invlist){
                    if(inv.ERP7__Serial__c != null && inv.ERP7__Product__c == productId){
                        SerialWrapper SW = new SerialWrapper();
                        SW.SerialNo = new ERP7__Serial_Number__c(Id = inv.ERP7__Serial__c,Name = inv.ERP7__Serial__r.Name,ERP7__Barcode__c = inv.ERP7__Serial__r.ERP7__Barcode__c);
                        serlist.add(SW);
                    }
                }  
            }
            system.debug('serlist : '+serlist.size());
            wrapS.PickSerialNos = serlist;  
        }
        catch(Exception e){
            string error = 'Error : '+e.getMessage()+ 'at line : '+e.getLineNumber();
            wrapS.error = error;
            
        }
        system.debug('wrapS.error  : '+wrapS.error);
        return wrapS;
    }
    
    
    public class SerialWrapper{
        @AuraEnabled public ERP7__Serial_Number__c SerialNo           { get; set; }
        @AuraEnabled public Boolean isSelected                        { get; set; }
        
        
        public SerialWrapper(){ 
            SerialNo = new ERP7__Serial_Number__c();
            isSelected = false;
            
        }
    }
    public class wrapSerial{
        @AuraEnabled public List<SerialWrapper> PickSerialNos  { get; set; }
        @AuraEnabled public String error                       { get; set; }
        public wrapSerial(){
            PickSerialNos = new List<SerialWrapper>();
            error = '';
        }
    }
    @AuraEnabled 
    public static List<wrapper_PickedItem> createInventoryforSerial(string productId,string serials,string siteID,string locId,string cartId){
        try{
            List<String> serialList = (List<String>) JSON.deserialize(serials, List<String>.class);
            List<ERP7__Inventory_Stock__c> invlist = [Select Id,Name,ERP7__Serial__c,ERP7__Product__c,ERP7__Number_of_Item_In_Stock__c,ERP7__Location__c,ERP7__Batch_Lot__c from ERP7__Inventory_Stock__c where ERP7__Product__c = :productId and ERP7__Warehouse__c = :siteID and ERP7__Location__c=:locId and  ERP7__Serial__c IN:serialList and ERP7__Serial__c != null and ERP7__Number_of_Item_In_Stock__c > 0];
            if(invlist.size() > 0){
                List<ERP7__Cart_Picked_Item__c> cartPickItems = new List<ERP7__Cart_Picked_Item__c>();
                for(String ser : serialList){
                    for(ERP7__Inventory_Stock__c inv : invlist){
                        if(inv.ERP7__Serial__c != null && inv.ERP7__Serial__c == ser){
                            system.debug('IN ');
                            ERP7__Cart_Picked_Item__c cartitem = new ERP7__Cart_Picked_Item__c();
                            // cartitem.ERP7__Available_Stock__c = inv.ERP7__Number_of_Item_In_Stock__c;
                            cartitem.ERP7__Quantity__c = 1;
                            cartitem.ERP7__Product__c = inv.ERP7__Product__c;
                            cartitem.ERP7__From_Location__c = inv.ERP7__Location__c;
                            cartitem.ERP7__Serial_Number__c = inv.ERP7__Serial__c;
                            cartitem.ERP7__Batch_Lot__c= inv.ERP7__Batch_Lot__c;
                            cartitem.ERP7__Cart__c = cartId;
                            cartitem.ERP7__Inventory_Stock__c = inv.Id;
                            cartitem.ERP7__Picked_Quantity__c = cartitem.ERP7__Quantity__c;
                            cartPickItems.add(cartitem);
                        }
                    }
                }
                if(cartPickItems.size() > 0) upsert cartPickItems;
                List<wrapper_PickedItem> cartWrap =fetchCartPickedDetails(cartId);
                return cartWrap;
            }
        }
        catch(exception e){
            system.debug('error : '+e.getLineNumber()+' Msg : '+e.getMessage());
        }
        return null;
    }
     @AuraEnabled
    public static wrapProd getProdDetails(String prodId,String siteId){
        if(prodId != null && prodId != ''){
            wrapProd result = new wrapProd();
            Product2 prod = [Select Id,Name,ERP7__Vendor_product_Name__c,Description,ProductCode,ERP7__Purchase_Lead_Time_days__c,ERP7__Serialise__c,ERP7__Lot_Tracked__c from Product2 where Id =:prodId limit 1];
            String selectedSite = '';
            if(String.isNotEmpty(siteId)){
					 selectedSite= siteId;
            }
            else{
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                    where ERP7__Employee_User__c=:UserInfo.getUserId()];
                if(empList.size()>0 && empList != null){
                    String channel = empList[0].ERP7__Channel__c;
                    List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                        From Distribution_Channel__c
                                                                        Where 
                                                                        Channel__c=:channel And Active__c = true order by ERP7__Priority__c ASC Limit 1];
                    
                    if(DistributionChannels.size() > 0) selectedSite= DistributionChannels[0].Site__c;
                }
            }
            
            result.product = prod;
            result.prodName = prod.Name;
            result.description = prod.Description;
            if(!prod.ERP7__Serialise__c && !prod.ERP7__Lot_Tracked__c){
                /*List<AggregateResult> WIISLists = [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock, SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) awaitingStock,SUM(ERP7__No_of_Items_Requested__c)requestedStocks FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c =: selectedSite And (ERP7__Number_of_Item_In_Stock__c > 0 ) AND ERP7__Product__c =: prodId GROUP BY ERP7__Product__c];   
                if(WIISLists.size() > 0) {
                    result.stock = (Decimal) WIISLists[0].get('totalStock');
                }
				system.debug('WIISLists : '+WIISLists);
				*/
                List<ERP7__Inventory_Stock__c> inventoryList = [Select Id,Name,ERP7__Number_of_Item_In_Stock__c from ERP7__Inventory_Stock__c  WHERE ERP7__Active__c = true   And ERP7__Warehouse__c =: selectedSite And (ERP7__Number_of_Item_In_Stock__c > 0) AND ERP7__Product__c =: prodId limit 1];
                result.inventory = (inventoryList.size() > 0) ? inventoryList[0].Id : null;
                result.stock = (inventoryList.size() > 0) ? inventoryList[0].ERP7__Number_of_Item_In_Stock__c : null;
            }
            return  result;           
        }
        else return null;
    }
    public class wrapProd{
        @AuraEnabled public Product2 product            {get;set;}
        @AuraEnabled public String inventory            {get;set;}
        @AuraEnabled public String prodName            {get;set;}
        @AuraEnabled public String  VendorPartNumber {get;set;}
        @AuraEnabled public String ProductCode       {get;set;}
        @AuraEnabled public String description              {get;set;}
        @AuraEnabled public String venId             {get;set;}
        @AuraEnabled public String errMsg            {get;set;}
        @AuraEnabled public Decimal stock            {get;set;}
        @AuraEnabled public Decimal demand           {get;set;}
        @AuraEnabled public Decimal AwaitStock       {get;set;}
        @AuraEnabled public String selCostCardId     {get;set;}
        @AuraEnabled public Decimal LeadTime         {get;set;} 
        @AuraEnabled public Decimal cost             {get;set;}
        public wrapProd(){
            product     = new Product2();
            inventory = '';
            prodName            = '';
            VendorPartNumber = '';
            ProductCode      = '';
            description            = '';
            venId            = '';
            errMsg            = '';
            stock           =0; 
            demand            =0; 
            AwaitStock       =0; 
            selCostCardId   = '';
            LeadTime         =0; 
            cost             =0;
        }
    }
    
    @AuraEnabled
    public static boolean getFunctionality() {
        boolean allowGlobalLocation = false;
        ERP7__Functionality_Control__c fc = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        
        if (fc == null) {
            fc = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if (fc == null) {  fc = ERP7__Functionality_Control__c.getInstance();}
        }
        
        if (fc != null) {  allowGlobalLocation = fc.ERP7__show_Global_Location_Stock_Transfer__c	; }
        return allowGlobalLocation;
    }
   
}