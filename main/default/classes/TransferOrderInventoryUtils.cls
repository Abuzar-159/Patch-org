Public with sharing Class TransferOrderInventoryUtils {
    
    /* Method to create Stock Outward Line Items for insert and undelete of TOLI. StockOutwardLineItems*/ 
    public static void createStockOutwardLineItems(set<Id> lineItemIds){
        system.debug('TransferOrderInventoryUtils createStockOutwardLineItems called');
        Set<Id> salepointIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<Id> assetIds = new Set<Id>();
        Set<Id> allSalepointSiteIds = new Set<Id>();
        Map<Id, Set<Id>> salepointSites = new Map<Id, Set<Id>>();
        Map<Id, Set<Inventory_Stock__c>> productSites = new Map<Id, Set<Inventory_Stock__c>>();
        Map<Id, List<Stock_Outward_Line_Item__c>> existingSoliAndSOWMap = new Map<Id, List<Stock_Outward_Line_Item__c>>();
        List<Stock_Outward_Line_Item__c> existingSOWList = new List<Stock_Outward_Line_Item__c>();
        List<Transfer_Order_Line_Items__c> currentLineItems = new List<Transfer_Order_Line_Items__c>();
        
        if(Schema.sObjectType.Transfer_Order_Line_Items__c.isAccessible()){
            currentLineItems = [Select Id, Name, ERP7__Transfer_Order__c, ERP7__From_Site__c, ERP7__To_Site__c, ERP7__Organisation__c, ERP7__Transfer_Order__r.ERP7__From_Site__c,ERP7__Transfer_Order__r.ERP7__Ready_To_Pick_Pack__c,
                                ERP7__Products__c, ERP7__Products__r.Name, ERP7__Products__r.SKU__c, ERP7__Products__r.Track_Inventory__c, ERP7__Quantity_requested__c,ERP7__Transfer_Order__r.ERP7__Ready_To_Receive__c,
                                ERP7__Transfer_Order__r.ERP7__Status__c, ERP7__Asset__c, Asset__r.Serial__c, ERP7__Products__r.ERP7__Serialise__c, ERP7__Products__r.ERP7__Lot_Tracked__c
                                ,ERP7__SerialNumber__c,ERP7__Batch_Lot__c
                                From Transfer_Order_Line_Items__c Where Id In: lineItemIds AND ERP7__Products__c != null AND ERP7__Quantity_requested__c > 0];
            
        }
        
        list<String> SolidIds=new list<String>();
        set<Id> serIds=new set<Id>(); // 18/12/23 Shaguftha
        set<Id> batchIds=new set<Id>(); // 18/12/23 Shaguftha
        for(Transfer_Order_Line_Items__c lineItem : currentLineItems) {
            SolidIds.add(lineItem.Id);
            if(lineItem.ERP7__SerialNumber__c != null) serIds.add(lineItem.ERP7__SerialNumber__c); // 18/12/23 Shaguftha
            if(lineItem.ERP7__Batch_Lot__c != null) batchIds.add(lineItem.ERP7__Batch_Lot__c);// 18/12/23 Shaguftha
        }
        
        existingSOWList = [SELECT Id, Name, ERP7__Transfer_Order__c, ERP7__Transfer_Order_Line_Item__c, ERP7__Quantity__c FROM Stock_Outward_Line_Item__c 
                           WHERE ERP7__Transfer_Order_Line_Item__c IN:SolidIds AND ERP7__Logistic_Line_Item__c != NULL AND ERP7__Quantity__c > 0];
        
        for(Transfer_Order_Line_Items__c lineItem : currentLineItems ){  
            if(lineItem.ERP7__Products__c != Null){
                if(Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.fields.ERP7__Products__c.isAccessible()) productIds.add(lineItem.ERP7__Products__c);
            } 
            if(lineItem.ERP7__Asset__c != Null){ if(Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.fields.ERP7__Asset__c.isAccessible()) assetIds.add(lineItem.ERP7__Asset__c); }
            if(lineItem.ERP7__Transfer_Order__r.ERP7__From_Site__c != Null){
                allSalepointSiteIds.add(lineItem.Transfer_Order__r.ERP7__From_Site__c);
            }
            if(lineItem.Id != Null){
                if(Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.isAccessible() && Schema.sObjectType.Stock_Outward_Line_Item__c.isAccessible()){
                    list<Stock_Outward_Line_Item__c> swList=new list<Stock_Outward_Line_Item__c>();   
                    for(Stock_Outward_Line_Item__c sw : existingSOWList ){ if(lineItem.Id==sw.ERP7__Transfer_Order_Line_Item__c) swList.add(sw); } 
                    existingSoliAndSOWMap.put(lineItem.Id, swList);   
                }   
            }
        } 
        
        Map < Id, List<ERP7__Inventory_Stock__c> > ProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
        Map < Id, ERP7__Inventory_Stock__c> SerialMap2Stock = new Map < Id, ERP7__Inventory_Stock__c>();
		Map < Id, ERP7__Inventory_Stock__c> BatchMap2Stock = new Map < Id, ERP7__Inventory_Stock__c>();
        
        Map < Id, Decimal> ProductMap2StockQty = new Map < Id, Decimal> ();
        Map < Id, Decimal> Invnetory2StockQty = new Map < Id, Decimal> ();
        system.debug('serIds size: '+serIds.size());
        system.debug('batchIds size: '+batchIds.size());
        String query = 'SELECT Id, Name, Active__c, Warehouse__c, Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Serial__c, ERP7__Version__c, Product__c, Number_of_Item_In_Stock__c, Checked_In_Date__c ';
        query += 'FROM Inventory_Stock__c WHERE (Product__c IN :productIds OR Fixed_Asset__c IN :assetIds) ';
        query += ' AND ERP7__Active__c = true AND ERP7__Warehouse__c IN :allSalepointSiteIds';
        if(serIds.size() > 0 || batchIds.size() > 0) query += ' AND (ERP7__Serial__c IN :serIds OR ERP7__Batch_Lot__c IN :batchIds OR (ERP7__Serial__c = null AND ERP7__Batch_Lot__c = null))';
        query += ' AND ERP7__Number_of_Item_In_Stock__c > 0 ORDER BY Checked_In_Date__c ASC';
        
        List<ERP7__Inventory_Stock__c> invlist = Database.query(query);
        system.debug('invlist : '+invlist.size());
        for (ERP7__Inventory_Stock__c WIIS:invlist) 
        {
            
            if(WIIS.ERP7__Serial__c != null){
                SerialMap2Stock.put(WIIS.ERP7__Serial__c, WIIS);
            }
           
            else{
                
                if(ProductMap2Stock.containsKey(WIIS.ERP7__product__c)){ ProductMap2Stock.get(WIIS.ERP7__product__c).add(WIIS); }
                else{ List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); WarehouseItemInventoryStockLists.add(WIIS); ProductMap2Stock.put(WIIS.ERP7__product__c, WarehouseItemInventoryStockLists); }
                if(WIIS.ERP7__Batch_Lot__c != null){
                    BatchMap2Stock.put(WIIS.ERP7__Batch_Lot__c,WIIS);
                }
            }
            
            Decimal total = 0; if(ProductMap2StockQty.containsKey(WIIS.ERP7__product__c)) total = ProductMap2StockQty.get(WIIS.ERP7__product__c); 
            total += WIIS.ERP7__Number_of_Item_In_Stock__c; ProductMap2StockQty.put(WIIS.ERP7__product__c, total);
            Invnetory2StockQty.put(WIIS.Id,WIIS.ERP7__Number_of_Item_In_Stock__c);
        }
        
        Boolean stockExceed = false;
        Boolean breakPoint = false;
        List<Stock_Outward_Line_Item__c> pplis2Insert = new List<Stock_Outward_Line_Item__c>(); 
        Decimal totalQuantity = 0;
        Decimal requestedQuantity = 0;
        Decimal finalQuantity = 0;
        List<Inventory_Stock__c> Inventory2Upsert = new List<Inventory_Stock__c>();
        Map<Id, ERP7__Inventory_Stock__c> pliStock = new Map<Id, ERP7__Inventory_Stock__c>();
        Map<Id, Stock_Outward_Line_Item__c> pliStockInward = new Map<Id, Stock_Outward_Line_Item__c>();
        //new code Arshad 09/06/2023
        for (Transfer_Order_Line_Items__c lineItem: currentLineItems) {
            // 19/12/23 Shaguftha
            if(lineItem.ERP7__Products__r.ERP7__Serialise__c){
                if(lineItem.ERP7__SerialNumber__c != null && SerialMap2Stock.containsKey(lineItem.ERP7__SerialNumber__c)){
                    ERP7__Inventory_Stock__c IS = SerialMap2Stock.get(lineItem.ERP7__SerialNumber__c);
                    requestedQuantity = finalQuantity = lineItem.ERP7__Quantity_requested__c;
                    Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();
                    PPLI.Active__c = true; PPLI.ERP7__Transfer_Order__c = lineItem.ERP7__Transfer_Order__c; PPLI.Product__c = lineItem.ERP7__Products__c; if(lineItem.ERP7__Asset__c != null){ PPLI.Fixed_Asset__c = lineItem.ERP7__Asset__c; }
                    if(IS.ERP7__Number_of_Item_In_Stock__c >= requestedQuantity) PPLI.Quantity__c = requestedQuantity; else PPLI.Quantity__c = IS.ERP7__Number_of_Item_In_Stock__c;
                    PPLI.Transfer_Order_Line_Item__c = lineItem.Id; PPLI.Site_Product_Service_Inventory_Stock__c = IS.Id;
                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && (lineItem.Transfer_Order__r.Status__c == 'Requested' || lineItem.Transfer_Order__r.Status__c == 'Approved' || lineItem.ERP7__Transfer_Order__r.ERP7__Ready_To_Pick_Pack__c))  PPLI.Status__c = 'Reserved';
                    if(IS.ERP7__Serial__c != null) PPLI.ERP7__Serial__c = IS.ERP7__Serial__c;
                    if(IS.ERP7__Batch_Lot__c != null) PPLI.ERP7__Material_Batch_Lot__c = IS.ERP7__Batch_Lot__c;
                    pplis2Insert.add(PPLI);
                }
                else{
                    ERP7__Inventory_Stock__c inv = new ERP7__Inventory_Stock__c(Active__c = true, Product__c = lineItem.ERP7__Products__c, Organisation__c = lineItem.Organisation__c, Name = 'Serial Stock Holder', Warehouse__c = lineItem.Transfer_Order__r.ERP7__From_Site__c);
                    Inventory2Upsert.add(inv);
                    Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();
                    PPLI.Name = 'Serial Stock Holder';
                    PPLI.Active__c = true; PPLI.ERP7__Transfer_Order__c = lineItem.ERP7__Transfer_Order__c; PPLI.Product__c = lineItem.ERP7__Products__c; if(lineItem.ERP7__Asset__c != null){ PPLI.Fixed_Asset__c = lineItem.ERP7__Asset__c; }
                    PPLI.Quantity__c = lineItem.ERP7__Quantity_requested__c;
                    PPLI.Transfer_Order_Line_Item__c = lineItem.Id; 
                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && (lineItem.Transfer_Order__r.Status__c == 'Requested' || lineItem.Transfer_Order__r.Status__c == 'Approved' || lineItem.ERP7__Transfer_Order__r.ERP7__Ready_To_Pick_Pack__c))  PPLI.Status__c = 'Reserved';
                    pplis2Insert.add(PPLI);
                    pliStock.put(lineItem.Id,inv);
                    pliStockInward.put(lineItem.Id,PPLI);
                }
            }
            else{
                system.debug('lineItem.ERP7__Batch_Lot__c : '+lineItem.ERP7__Batch_Lot__c);
                if(lineItem.ERP7__Batch_Lot__c != null){
                     requestedQuantity = finalQuantity = lineItem.ERP7__Quantity_requested__c;
                    if(BatchMap2Stock.containsKey(lineItem.ERP7__Batch_Lot__c)){
                        ERP7__Inventory_Stock__c IS = BatchMap2Stock.get(lineItem.ERP7__Batch_Lot__c);
                        system.debug('IS stock : '+IS.ERP7__Number_of_Item_In_Stock__c);
                        if(IS.ERP7__Number_of_Item_In_Stock__c > 0){
                            Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();
                            PPLI.Active__c = true; PPLI.ERP7__Transfer_Order__c = lineItem.ERP7__Transfer_Order__c; PPLI.Product__c = lineItem.ERP7__Products__c; if(lineItem.ERP7__Asset__c != null){ PPLI.Fixed_Asset__c = lineItem.ERP7__Asset__c; }
                            if(IS.ERP7__Number_of_Item_In_Stock__c >= requestedQuantity) PPLI.Quantity__c = requestedQuantity; else PPLI.Quantity__c = IS.ERP7__Number_of_Item_In_Stock__c;
                            PPLI.Transfer_Order_Line_Item__c = lineItem.Id; PPLI.Site_Product_Service_Inventory_Stock__c = IS.Id;
                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && (lineItem.Transfer_Order__r.Status__c == 'Requested' || lineItem.Transfer_Order__r.Status__c == 'Approved' || lineItem.ERP7__Transfer_Order__r.ERP7__Ready_To_Pick_Pack__c))  PPLI.Status__c = 'Reserved';
                            if(serIds.size() > 0 && serIds.contains(IS.ERP7__Serial__c)) PPLI.ERP7__Serial__c = IS.ERP7__Serial__c;
                            if(batchIds.size() > 0 && batchIds.contains(IS.ERP7__Batch_Lot__c)) PPLI.ERP7__Material_Batch_Lot__c = IS.ERP7__Batch_Lot__c;
                            pplis2Insert.add(PPLI);
                 
                        }
                    }
                }
                else{
                    if (ProductMap2Stock.containsKey(lineItem.ERP7__Products__c) && ProductMap2StockQty.containsKey(lineItem.ERP7__Products__c)) {
                    stockExceed = false; totalQuantity = ProductMap2StockQty.get(lineItem.ERP7__Products__c); requestedQuantity = finalQuantity = lineItem.ERP7__Quantity_requested__c;
                    if(totalQuantity < requestedQuantity) stockExceed = true;
                    
                    if(!stockExceed){
                        for(ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(lineItem.ERP7__Products__c)) {
                            system.debug('Invnetory2StockQty.containskey(IS.Id) : '+Invnetory2StockQty.containskey(IS.Id));
                            if(Invnetory2StockQty.containskey(IS.Id) && Invnetory2StockQty.get(IS.Id) > 0){
                                Stock_Outward_Line_Item__c PPLI = new Stock_Outward_Line_Item__c();
                                PPLI.Active__c = true; PPLI.ERP7__Transfer_Order__c = lineItem.ERP7__Transfer_Order__c; PPLI.Product__c = lineItem.ERP7__Products__c; if(lineItem.ERP7__Asset__c != null){ PPLI.Fixed_Asset__c = lineItem.ERP7__Asset__c; }
                                if(IS.ERP7__Number_of_Item_In_Stock__c >= requestedQuantity) PPLI.Quantity__c = requestedQuantity; else PPLI.Quantity__c = IS.ERP7__Number_of_Item_In_Stock__c;
                                PPLI.Transfer_Order_Line_Item__c = lineItem.Id; PPLI.Site_Product_Service_Inventory_Stock__c = IS.Id;
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && (lineItem.Transfer_Order__r.Status__c == 'Requested' || lineItem.Transfer_Order__r.Status__c == 'Approved' || lineItem.ERP7__Transfer_Order__r.ERP7__Ready_To_Pick_Pack__c))  PPLI.Status__c = 'Reserved';
                                if(serIds.size() > 0 && serIds.contains(IS.ERP7__Serial__c)) PPLI.ERP7__Serial__c = IS.ERP7__Serial__c;
                                if(batchIds.size() > 0 && batchIds.contains(IS.ERP7__Batch_Lot__c)) PPLI.ERP7__Material_Batch_Lot__c = IS.ERP7__Batch_Lot__c;
                                pplis2Insert.add(PPLI);
                                Decimal currentIsqty =  Invnetory2StockQty.get(IS.Id);
                                system.debug('currentIsqty : '+currentIsqty);
                                currentIsqty = (currentIsqty > 0) ? currentIsqty - PPLI.Quantity__c : 0;
                                Invnetory2StockQty.put(IS.Id,currentIsqty);
                                if(IS.ERP7__Number_of_Item_In_Stock__c >= requestedQuantity) break; else requestedQuantity -= IS.ERP7__Number_of_Item_In_Stock__c;
                 
                            }else continue;
                        }
                    }
                }
                }
            }  
        }
        
        if(Inventory2Upsert.size() > 0){
            insert Inventory2Upsert;
            for(Id pliId : pliStockInward.KeySet()){
                pliStockInward.get(pliId).Site_Product_Service_Inventory_Stock__c= pliStock.get(pliId).Id;
            }
        }
        if(pplis2Insert.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable()){ PreventRecursiveLedgerEntry.proceedDeleteZeroReserverSTOLI = true; PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true; system.debug('inserting soli here'); insert pplis2Insert; PreventRecursiveLedgerEntry.testCasesTransactions = false;  }  else{ }
    }
}