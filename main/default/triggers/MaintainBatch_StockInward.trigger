trigger MaintainBatch_StockInward on Stock_Inward_Line_Item__c (after insert, after update, after delete, after undelete) {
    Set<Id> batchIds = new Set<Id>();
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    String SupplierRecordId = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Supplier_Invoice_Transaction');
    List<Transaction__c> Transactions2update = new List<Transaction__c>();
    
    if(PreventRecursiveLedgerEntry.StockInwardTrigger){
        PreventRecursiveLedgerEntry.StockInwardTrigger = false;
        
        
        if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            Set<Id> SILIIds=new Set<Id>();
            set<Id> serialIDs = new set<Id>();
            for(Stock_Inward_Line_Item__c SOLI : System.trigger.New) {
                if(SOLI.ERP7__Status__c != 'Awaiting Stock') SILIIds.add(SOLI.Id); /* added on 22_02_24 if status not equal to awaiting condition */
                if(SOLI.ERP7__Serial__c != null) serialIDs.add(SOLI.ERP7__Serial__c);
            }
            system.debug('SILIIds : '+SILIIds.size());
            if(!System.isFuture() && !System.isBatch() && SILIIds.size() > 0) MaintainBatchStocks.updateUnitPriceStockInward(SILIIds); 
            if(serialIDs.size() > 0 && !System.isFuture() && !System.isBatch()) MaintainBatchStocks.MaintainserialStocks(serialIDs); 
            
        }
        
        /* for transactions block of code */
        if(trigger.IsAfter && !trigger.IsDelete){
            Map<Id,Decimal> Product_Map2Id = new Map<Id,Decimal>();
            Map<Id,String> RMAlineMap = new Map<Id,String>();
            Set<Id> pricebookIds = new Set<Id>();
            Set<Id> ProductIds = new Set<Id>();
           for(Stock_Inward_Line_Item__c s :[SELECT Id,Name, ERP7__Purchase_Line_Items__c , ERP7__Product__c, ERP7__RMA_Line_Item__c, ERP7__RMA_Line_Item__r.ERP7__PriceBookId__c, ERP7__RMA_Line_Item__r.ERP7__Product__c, ERP7__RMA_Line_Item__r.ERP7__Return_Status__c, ERP7__Purchase_Line_Items__r.ERP7__Quantity__c,ERP7__Purchase_Line_Items__r.ERP7__Total_Price__c  FROM Stock_Inward_Line_Item__c Where Id IN: Trigger.newMap.keyset() AND Posted__C = true LIMIT 999]){    if(s.ERP7__RMA_Line_Item__c != null){        RMAlineMap.put(s.ERP7__RMA_Line_Item__c, s.ERP7__RMA_Line_Item__r.ERP7__Return_Status__c);    }    if(s.ERP7__RMA_Line_Item__c != null && s.ERP7__RMA_Line_Item__r.ERP7__PriceBookId__c != null && s.ERP7__RMA_Line_Item__r.ERP7__Product__c != null){                    pricebookIds.add(s.ERP7__RMA_Line_Item__r.ERP7__PriceBookId__c);                    ProductIds.add(s.ERP7__RMA_Line_Item__r.ERP7__Product__c);                    system.debug('Status-->'+s.ERP7__RMA_Line_Item__r.ERP7__Return_Status__c);                } else if(s.ERP7__Purchase_Line_Items__c != null && s.ERP7__Purchase_Line_Items__r.ERP7__Quantity__c != null && s.ERP7__Purchase_Line_Items__r.ERP7__Total_Price__c != null){                    Product_Map2Id.put(s.ERP7__Product__c,(s.ERP7__Purchase_Line_Items__r.ERP7__Total_Price__c/s.ERP7__Purchase_Line_Items__r.ERP7__Quantity__c).setScale(2));                   }    }
            
            
            for(PricebookEntry pbEntry :[Select Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, ERP7__Purchase_Price__c from PricebookEntry where Pricebook2Id in: pricebookIds AND Product2Id IN: ProductIds LIMIT 999]){                decimal purchasePrice = (pbEntry.ERP7__Purchase_Price__c != null)?pbEntry.ERP7__Purchase_Price__c:pbEntry.UnitPrice;                Product_Map2Id.put(pbEntry.Product2Id,purchasePrice);                            }
            
            // Moin's Code
            Map<Id, Id> soliExisting_Transactions = new Map<Id, id>();
            for(Transaction__c eTransaction :[Select Id, Name, ERP7__Stock_Inward_Line_Item__c From Transaction__c Where ERP7__Stock_Inward_Line_Item__c  In : Trigger.NewMap.keyset()])                soliExisting_Transactions.put(eTransaction.ERP7__Stock_Inward_Line_Item__c, eTransaction.id);
            
            // End Here
            for(Stock_Inward_Line_Item__c SILI : System.trigger.New){
                if(SILI.ERP7__Material_Batch_Lot__c != Null){                   system.debug('SILI status 2 : '+SILI.ERP7__Status__c);                    batchIds.add(SILI.ERP7__Material_Batch_Lot__c);
                } 
                if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c ) && SILI.Posted__C){//&& trigger.isInsert
                    // Added below line
                    Transaction__c trans = new Transaction__c(Id=(soliExisting_Transactions.get(SILI.Id)!=null)?soliExisting_Transactions.get(SILI.Id):null);
                    //Transaction__c trans = new Transaction__c();
                    if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                    Decimal unitPrice  = (SILI.ERP7__Cost_Price__c > 0.00)?SILI.ERP7__Cost_Price__c:SILI.ERP7__unit_Price__c;
                    if(SILI.Product__c != null && Product_Map2Id.get(SILI.Product__c) != null) unitPrice = (unitPrice != null && unitPrice >0.00)?unitPrice:Product_Map2Id.get(SILI.Product__c);
                    if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = (SILI.ERP7__Quantity__c != null && unitPrice != null)? SILI.ERP7__Quantity__c * unitPrice :0.00;
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Return_PO__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Return_PO__c.isUpdateable()) trans.ERP7__Purchase_Return_PO__c = sili.ERP7__Purchase_Orders__c;
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Product__c.isUpdateable()) trans.ERP7__Product__c = SILI.ERP7__Product__c;
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Stock_Inward_Line_Item__c.isUpdateable()) trans.ERP7__Stock_Inward_Line_Item__c = SILI.Id; 
                    if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = SupplierRecordId;
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){
                        system.debug('Discard-->'+RMAlineMap.get(SILI.ERP7__RMA_Line_Item__c));
                        if(SILI.ERP7__RMA_Line_Item__c != null && RMAlineMap.get(SILI.ERP7__RMA_Line_Item__c) != 'Discard') trans.Transaction_Type__c = 'InventoryReturn';
                        else if(SILI.ERP7__RMA_Line_Item__c != null && RMAlineMap.get(SILI.ERP7__RMA_Line_Item__c) == 'Discard') trans.Transaction_Type__c = 'ScrappedReturn';
                        else if(SILI.ERP7__Purchase_Line_Items__c != null) trans.Transaction_Type__c = 'InventoryPurchased';
                        else trans.Transaction_Type__c = 'Transfer';
                    }
                    
                    Transactions2update.add(trans);   
                }
            }
            if(Transactions2update.size()>0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){upsert Transactions2update;}else{/*Not allowed to upsert*/}
        }
        
        if(trigger.IsAfter && (trigger.IsUpdate || trigger.IsDelete)){            for(Stock_Inward_Line_Item__c SILI : System.trigger.Old){                system.debug('SILI status 1 : '+SILI.ERP7__Status__c);                if(SILI.ERP7__Material_Batch_Lot__c != Null) {                    batchIds.add(SILI.ERP7__Material_Batch_Lot__c);                }            }            if(trigger.IsDelete){                Transactions2update = [SELECT Id FROM Transaction__c WHERE ERP7__Stock_Inward_Line_Item__c in : trigger.OldMap.keyset() LIMIT 999];                 if(Transactions2update.size()>0 && Transaction__c.sObjectType.getDescribe().isDeletable()){                    delete Transactions2update;                }else{ }            }        }       
        
        if(trigger.IsAfter && !System.isFuture() && !System.isBatch() && batchIds.size() > 0) MaintainBatchStocks.MaintainBatchStocks(batchIds);
        
        /*
Auto update Sales Orders and Logistic Lines when all the items of that order came in....for custom sales orders
*/  
        ERP7__Functionality_Control__c FC=new ERP7__Functionality_Control__c();
        FC=ERP7__Functionality_Control__c.getValues(userInfo.getUserId());
        if(FC==null){ FC=ERP7__Functionality_Control__c.getValues(userInfo.getProfileId()); if(FC == null) FC=ERP7__Functionality_Control__c.getInstance();    }
        if(test.isRunningTest()) {
            FC.ERP7__Execute_SO_Auto_Stock_Allocation__c = true;
            FC.ERP7__Auto_Update_SO_Back_Order__c = true;
        }
        if(trigger.IsAfter && (trigger.IsInsert || trigger.IsUpdate) && FC.ERP7__Execute_SO_Auto_Stock_Allocation__c){
            // For sales order specific stock inwards
            Set<Id> soIds = new Set<Id>();
            //Set<Id> moIds = new Set<Id>();
            Set<Id> productIds = new Set<Id>();
            Set<Id> soliIds = new Set<Id>();
            Set<Id> soIds2 = new Set<Id>();
            Map < Id, Decimal > ProductMap2StockComing = new Map < Id, Decimal > ();
            Map < Id, List<ERP7__Inventory_Stock__c> > ProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
            Map < Id, Decimal > ProductMap2StockReserved = new Map < Id, Decimal > ();
            Map < Id, List<ERP7__Sales_Order_Line_Item__c> > SOLines = new Map < Id, List<ERP7__Sales_Order_Line_Item__c> > ();
            List<ERP7__Sales_order__c> SOS2Update = new List<ERP7__Sales_order__c>();
            List<ERP7__Sales_Order_Line_Item__c> SOLIS2Update = new List<ERP7__Sales_Order_Line_Item__c>();
            
            Set<Id> SOS2UpdateSet = new Set<Id>();
            Set<Id> SOLIS2UpdateSet = new Set<Id>();
            
            for (Integer i=0; i<System.Trigger.New.size(); i++) {
                ERP7__Stock_Inward_Line_Item__c sili = System.Trigger.New[i];
                if(sili.ERP7__Status__c != 'Awaiting Stock'){
                    Decimal siliOldQuantity = 0;
                    Decimal siliQuantity = 0;
                    if(sili.ERP7__Quantity__c != Null) siliQuantity = sili.ERP7__Quantity__c;
                    if(Trigger.isUpdate && System.Trigger.Old[i].ERP7__Quantity__c != Null) siliOldQuantity = System.Trigger.Old[i].ERP7__Quantity__c;
                    
                    siliQuantity = siliQuantity - siliOldQuantity;
                    
                    if(((sili.SoId__c != Null && sili.SoId__c != '') || (sili.ERP7__SOId_on_POLI__c != null && sili.ERP7__SOId_on_POLI__c != '')) && sili.ERP7__Product__c != Null) {                        productIds.add(sili.ERP7__Product__c);                        if(sili.ERP7__SOId_on_POLI__c != null && sili.ERP7__SOId_on_POLI__c != '') soIds.add(sili.ERP7__SOId_on_POLI__c);                         else if(sili.SoId__c != Null && sili.SoId__c != '') soIds.add(sili.ERP7__SoId__c);                        Decimal ik = 0;                        if(ProductMap2StockComing.containsKey(sili.ERP7__Product__c)){                            if(siliQuantity != Null) ik = ProductMap2StockComing.get(sili.ERP7__product__c) + siliQuantity;                        } else{                            ik = siliQuantity;                            ProductMap2StockComing.put(sili.ERP7__product__c, ik);                        }                    }             
                }            
            }
            
            if(soIds.size() > 0 && productIds.size() > 0){                for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Warehouse__c, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c IN: productIds And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0]) {                                        if(ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)) ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);                    else{ List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks); ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists); }                                        for(Id pId : ProductMap2Stock.keySet()) ProductMap2StockReserved.put(pId,0);                }                                List<ERP7__Sales_order__c> SOS = [Select Id, ERP7__Status__c, ERP7__Order_Profile__c, ERP7__Authorised__c, ERP7__Ready_To_Pick_Pack__c FROM ERP7__Sales_Order__c where Id in : soIds Order By CreatedDate ASC LIMIT 999];                 List < ERP7__Sales_Order_Line_Item__c > Solis = [Select Id, Name, ERP7__Inventory_Tracked__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__PriceBookId__c From ERP7__Sales_Order_Line_Item__c Where ERP7__Sales_Order__c In: SOS LIMIT 999];                                system.debug('SOS here1~>'+SOS.size());                system.debug('Solis here1~>'+Solis.size());                                 for(ERP7__Sales_Order_Line_Item__c soli : Solis){                    if(SOLines.containsKey(soli.ERP7__Sales_Order__c)) SOLines.get(soli.ERP7__Sales_Order__c).add(soli);                    else{ List<ERP7__Sales_Order_Line_Item__c> mySOLines = new List<ERP7__Sales_Order_Line_Item__c>(); mySOLines.add(soli); SOLines.put(soli.ERP7__Sales_Order__c, mySOLines); }                    }                                 Integer akSO = 0; Integer akSOLI = 0;                for(ERP7__Sales_order__c SO : SOS){                    Boolean stockExceed = false;                    if(SOLines.get(SO.Id) != null){                        for(ERP7__Sales_Order_Line_Item__c soli : SOLines.get(SO.Id)){                            Boolean soliStockExceed = false;                            If(!soliStockExceed) {                                if (soli.ERP7__Inventory_Tracked__c == true && ProductMap2Stock != null && ProductMap2Stock.containsKey(soli.ERP7__Product__c)) {                                    Decimal totalQuantity = 0;                                    for(ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(soli.ERP7__Product__c)) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c;                                     if(ProductMap2StockComing.containskey(soli.ERP7__Product__c)) totalQuantity += ProductMap2StockComing.get(soli.ERP7__Product__c);                                    if ((totalQuantity-ProductMap2StockReserved.get(soli.ERP7__Product__c))< Soli.ERP7__Quantity__c) {                                         soliStockExceed = true;                                     } else ProductMap2StockReserved.put(soli.ERP7__product__c, (ProductMap2StockReserved.get(soli.ERP7__product__c) + Soli.ERP7__Quantity__c));                                } else { stockExceed = soliStockExceed; }                                                                if (!soliStockExceed) {                                    if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isUpdateable()) soli.ERP7__Order_Line_Status__c = 'Reserved';                                     if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Is_Back_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Is_Back_Order__c.isUpdateable()) soli.ERP7__Is_Back_Order__c = false;                                     if(akSOLI < 10000){                                        if(!SOLIS2UpdateSet.contains(soli.Id)){ SOLIS2UpdateSet.add(soli.Id); SOLIS2Update.add(soli); akSOLI++; }                                    }                                    else if(akSOLI >= 10000 && akSOLI < 19998){                                        if(!soliIds.contains(soli.Id)){ soliIds.add(soli.Id); akSOLI++; }                                    }                                 } else StockExceed = soliStockExceed;                            }                        }                    }                    if (!stockExceed) {                        if(Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Is_Back_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Is_Back_Order__c.isUpdateable()) so.ERP7__Is_Back_Order__c = false;                         if(Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Status__c.isUpdateable()) so.ERP7__Status__c = 'Booked';                        if(akSO < 10000){                            if(!SOS2UpdateSet.contains(so.Id)){ SOS2UpdateSet.add(so.Id); SOS2Update.add(so); akSO++; }                        }                        else if(akSO >= 10000 && akSO < 19998){                            if(!soIds2.contains(so.Id)){ soIds2.add(so.Id); akSO++; }                        }                    }                }                                System.debug('SOS2Update.size() here1:'+SOS2Update.size());                System.debug('SOLIS2Update.size() here1:'+SOLIS2Update.size());                System.debug('soIds2.size() here1:'+soIds2.size());                System.debug('soliIds.size() here1:'+soliIds.size());                                if(SOS2Update.size() > 0 && Schema.SObjectType.ERP7__Sales_order__c.isCreateable() && Schema.SObjectType.ERP7__Sales_order__c.isUpdateable()){update SOS2Update;}else{/*Not allowed to update*/}                                if(SOLIS2Update.size() > 0 && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()){update SOLIS2Update;}else{/*Not allowed to update*/}                                if(soIds2.size() > 0) MaintainBatchStocks.EvaluateSalesOrders(soIds2);                if(soliIds.size() > 0) MaintainBatchStocks.EvaluateSalesOrdersLines(soliIds);                            }          
            
            
            // For non sales order specific stock inwards         
            if(FC != null){                    
                if(FC.ERP7__Auto_Update_SO_Back_Order__c){ 
                    System.debug('inside ERP7__Auto_Update_SO_Back_Order__c here1');
                    soIds = new Set<Id>();
                    soIds2 = new Set<Id>();
                    productIds = new Set<Id>();
                    soliIds = new Set<Id>();
                    ProductMap2StockComing = new Map < Id, Decimal > ();
                    ProductMap2Stock = new Map < Id, List<ERP7__Inventory_Stock__c> > ();
                    ProductMap2StockReserved = new Map < Id, Decimal > ();
                    SOS2Update = new List<ERP7__Sales_order__c>();
                    SOLIS2Update = new List<ERP7__Sales_Order_Line_Item__c>();
                    SOS2UpdateSet = new Set<Id>();
                    SOLIS2UpdateSet = new Set<Id>();
                    
                    for (Integer i=0; i<System.Trigger.New.size(); i++) {
                        ERP7__Stock_Inward_Line_Item__c sili = System.Trigger.New[i];
                        if(sili.ERP7__Status__c != 'Awaiting Stock'){
                            Decimal siliOldQuantity = 0;
                            Decimal siliQuantity = 0;
                            if(sili.ERP7__Quantity__c != Null) siliQuantity = sili.ERP7__Quantity__c;
                            if(Trigger.isUpdate && System.Trigger.Old[i].ERP7__Quantity__c != Null) siliOldQuantity = System.Trigger.Old[i].ERP7__Quantity__c;
                            
                            siliQuantity = siliQuantity - siliOldQuantity;
                            
                            if((sili.SoId__c == Null || sili.SoId__c == '') && sili.ERP7__Product__c != Null) {
                                productIds.add(sili.ERP7__Product__c);
                                Decimal ik = 0;
                                if(ProductMap2StockComing.containsKey(sili.ERP7__Product__c)){                                    if(siliQuantity != Null){ ik = ProductMap2StockComing.get(sili.ERP7__product__c) + siliQuantity; ProductMap2StockComing.remove(sili.ERP7__Product__c); ProductMap2StockComing.put(sili.ERP7__Product__c, ik); }
                                }
                                else{ ik = siliQuantity; ProductMap2StockComing.put(sili.ERP7__product__c, ik); }
                            }
                        }                    
                    }
                    
                    if(productIds.size() > 0){
                        for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Warehouse__c, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c IN: productIds And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 LIMIT 999]) {                            if(ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)) ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);                            else{ List<ERP7__Inventory_Stock__c> WarehouseItemInventoryStockLists = new List<ERP7__Inventory_Stock__c>(); WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks); ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists); }                                                        for(Id pId : ProductMap2Stock.keySet()) ProductMap2StockReserved.put(pId,0);                        }
                        
                        List < ERP7__Sales_Order_Line_Item__c > Solis = [Select Id, Name, ERP7__Inventory_Tracked__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__PriceBookId__c From ERP7__Sales_Order_Line_Item__c Where ERP7__Product__c In: productIds And ERP7__Is_Back_Order__c = true Order By CreatedDate ASC LIMIT 999];
                        
                        system.debug('Solis size here2~>'+Solis.size());
                        
                        Integer nsSO = 0; Integer nsSOLI = 0;
                        for(ERP7__Sales_Order_Line_Item__c soli : Solis){                            Boolean soliStockExceed = false;                            If(!soliStockExceed) {                                if (soli.ERP7__Inventory_Tracked__c == true && ProductMap2Stock != null && ProductMap2Stock.containsKey(soli.ERP7__Product__c)) {                                    Decimal totalQuantity = 0;                                    for(ERP7__Inventory_Stock__c IS : ProductMap2Stock.get(soli.ERP7__Product__c)) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c;                                    if(ProductMap2StockComing.containskey(soli.ERP7__Product__c)) totalQuantity += ProductMap2StockComing.get(soli.ERP7__Product__c);                                                            if((totalQuantity-ProductMap2StockReserved.get(soli.ERP7__Product__c)) < Soli.ERP7__Quantity__c){ soliStockExceed = true; }                                     else ProductMap2StockReserved.put(soli.ERP7__product__c, (ProductMap2StockReserved.get(soli.ERP7__product__c) + Soli.ERP7__Quantity__c));                                }                                                                 if (!soliStockExceed) {                                    if(nsSO < 10000) {                                        if(!SOS2UpdateSet.contains(soli.ERP7__Sales_Order__c)){ SOS2Update.add(new ERP7__Sales_order__c(id=soli.ERP7__Sales_Order__c)); SOS2UpdateSet.add(soli.ERP7__Sales_Order__c); nsSO++; }                                     }                                    else if(nsSO >= 10000 && nsSO < 19998){                                        if(!soIds2.contains(soli.ERP7__Sales_Order__c)){ soIds2.add(soli.ERP7__Sales_Order__c); nsSO++; }                                    }                                                                        if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isUpdateable()) soli.ERP7__Order_Line_Status__c = 'Reserved';                                    if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Is_Back_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Is_Back_Order__c.isUpdateable()) soli.ERP7__Is_Back_Order__c = false;                                    if(nsSOLI < 10000) {                                        if(!SOLIS2UpdateSet.contains(soli.Id)){ SOLIS2Update.add(soli); SOLIS2UpdateSet.add(soli.Id); nsSOLI++; }                                     }                                    else if(nsSOLI >= 10000 && nsSOLI < 19998){                                        if(!soliIds.contains(soli.Id)){ soliIds.add(soli.Id); nsSOLI++; }                                    }                                }                             }                        }                       
                        
                        System.debug('SOS2Update.size() here2:'+SOS2Update.size());
                        System.debug('SOLIS2Update.size() here2:'+SOLIS2Update.size());
                        System.debug('soIds2.size() here2:'+soIds2.size());
                        System.debug('soliIds.size() here2:'+soliIds.size());
                        
                        if(SOS2Update.size() > 0 && Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Is_Back_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_order__c.fields.ERP7__Is_Back_Order__c.isUpdateable() && Schema.SObjectType.ERP7__Sales_order__c.isCreateable() && Schema.SObjectType.ERP7__Sales_order__c.isUpdateable()){update SOS2Update;}else{/*Not allowed to update*/}
                        
                        if(SOLIS2Update.size() > 0 && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()){update SOLIS2Update;}else{/*Not allowed to update*/}
                        
                        if(soIds2.size() > 0) MaintainBatchStocks.EvaluateSalesOrders(soIds2);
                        if(soliIds.size() > 0) MaintainBatchStocks.EvaluateSalesOrdersLines(soliIds);
                    }
                }
            }
            
            //for (ERP7__Stock_Inward_Line_Item__c sili : System.Trigger.New) {
            //  if(sili.MoId__c != Null && sili.MoId__c != '') moIds.add(sili.MoId__c);
            //}
            
            //if(moIds.size() > 0){ 
            //List< ERP7__Manufacturing_Order__c > MOS = [Select Id, Name From ERP7__Manufacturing_Order__c Where Id In : MoIds];
            //doubts
            //upsert MOS;
            //}
        }
        
        
        /*
Auto update Standard Orders and Logistic Lines when all the items of that order came in.... for standard orders
*/ 
    if (trigger.IsAfter && (trigger.IsInsert || trigger.IsUpdate) && !FC.ERP7__Execute_SO_Auto_Stock_Allocation__c) {
      System.debug('inside Order flow');
      Set < Id > soIds = new Set < Id > ();
      Set < Id > productIds = new Set < Id > ();
      Set < Id > soliIds = new Set < Id > ();
      Set < Id > soIds2 = new Set < Id > ();
      Map < Id, Decimal > ProductMap2StockComing = new Map < Id, Decimal > ();
      Map < Id, List < ERP7__Inventory_Stock__c > > ProductMap2Stock = new Map < Id, List < ERP7__Inventory_Stock__c > > ();
      Map < Id, Decimal > ProductMap2StockReserved = new Map < Id, Decimal > ();
      Map < Id, List < OrderItem > > SOLines = new Map < Id, List < OrderItem > > ();
      List < Order > SOS2Update = new List < Order > ();
      List < OrderItem > SOLIS2Update = new List < OrderItem > ();
      Set < Id > SOS2UpdateSet = new Set < Id > ();
      Set < Id > SOLIS2UpdateSet = new Set < Id > ();
      System.debug('Trigger size :'+System.Trigger.New.size());
      for (Integer i = 0; i < System.Trigger.New.size(); i++) {
        ERP7__Stock_Inward_Line_Item__c sili = System.Trigger.New[i];
        System.debug('sili ->'+sili);
        if (sili.ERP7__Status__c != 'Awaiting Stock') {
          Decimal siliOldQuantity = 0;
          Decimal siliQuantity = 0;
          if (sili.ERP7__Quantity__c != Null) siliQuantity = sili.ERP7__Quantity__c;
          if (Trigger.isUpdate && System.Trigger.Old[i].ERP7__Quantity__c != Null) siliOldQuantity = System.Trigger.Old[i].ERP7__Quantity__c;
          siliQuantity = siliQuantity - siliOldQuantity;
          if (((sili.SoId__c != Null && sili.SoId__c != '') || (sili.ERP7__SOId_on_POLI__c != null && sili.ERP7__SOId_on_POLI__c != '')) && sili.ERP7__Product__c != Null) {
            System.debug('Inside After SOID');
            productIds.add(sili.ERP7__Product__c);
            if (sili.ERP7__SOId_on_POLI__c != null && sili.ERP7__SOId_on_POLI__c != '') SOIds.add(sili.ERP7__SOId_on_POLI__c);
            else if (sili.SoId__c != Null && sili.SoId__c != '') SOIds.add(sili.ERP7__SoId__c);
            Decimal ik = 0;
            if (ProductMap2StockComing.containsKey(sili.ERP7__Product__c)) {
              if (siliQuantity != Null) ik = ProductMap2StockComing.get(sili.ERP7__product__c) + siliQuantity;
            } else {
              ik = siliQuantity;
              ProductMap2StockComing.put(sili.ERP7__product__c, ik);
            }
          }
        }
      }
      System.debug('ProductMap2StockComing '+ProductMap2StockComing);
      System.debug('SOIds:' + SOIds);
      if (SOIds.size() > 0 && productIds.size() > 0) {
        for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Warehouse__c, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c IN: productIds And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0]) {
          if (ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)) ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
          else {
            List < ERP7__Inventory_Stock__c > WarehouseItemInventoryStockLists = new List < ERP7__Inventory_Stock__c > ();
            WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks);
            ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
          }System.debug('ProductMap2Stock:'+ProductMap2Stock);

          for (Id pId: ProductMap2Stock.keySet()) ProductMap2StockReserved.put(pId, 0);
        }
        System.debug('ProductMap2StockReserved:' + ProductMap2StockReserved);
        List < Order > SOS = [Select Id, Status, ERP7__Order_Profile__c, ERP7__Authorised__c, ERP7__Ready_To_Pick_Pack__c FROM Order where Id in: soIds Order By CreatedDate ASC LIMIT 999];System.debug('SOS size:' + SOS.size());
        List < OrderItem > Solis = [Select Id, ERP7__Inventory_Tracked__c, Product2Id, Quantity, OrderId, ERP7__Status__c, ERP7__PriceBookId__c From OrderItem Where OrderId In: SOS LIMIT 999];System.debug('Solis size:' + Solis.size());
        System.debug('Solis:' + Solis);
        for (OrderItem soli: Solis) {
          if (SOLines.containsKey(soli.OrderId)) SOLines.get(soli.OrderId).add(soli);
          else {
            List < OrderItem > mySOLines = new List < OrderItem > ();
            mySOLines.add(soli);
            SOLines.put(soli.OrderId, mySOLines);
          }
        }
        Integer akSO = 0;
        Integer akSOLI = 0;
        for (Order SO: SOS) {
          Boolean stockExceed = false;
          if (SOLines.get(SO.Id) != null) {
            for (OrderItem soli: SOLines.get(SO.Id)) {
              Boolean soliStockExceed = false;
              If(!soliStockExceed) {
                if (soli.ERP7__Inventory_Tracked__c == true && ProductMap2Stock != null && ProductMap2Stock.containsKey(soli.Product2Id)) {
                  Decimal totalQuantity = 0;
                  for (ERP7__Inventory_Stock__c IS: ProductMap2Stock.get(soli.Product2Id)) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c;
                  if (ProductMap2StockComing.containskey(soli.Product2Id)) totalQuantity += ProductMap2StockComing.get(soli.Product2Id);
                  if ((totalQuantity - ProductMap2StockReserved.get(soli.Product2Id)) < Soli.Quantity) {
                    soliStockExceed = true;
                  } else ProductMap2StockReserved.put(soli.Product2Id, (ProductMap2StockReserved.get(soli.Product2Id) + Soli.Quantity));
                } else {
                  stockExceed = soliStockExceed;
                }
                if (!soliStockExceed) {
                  if (Schema.sObjectType.OrderItem.fields.ERP7__Order_Line_Status__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Order_Line_Status__c.isUpdateable()) soli.ERP7__Order_Line_Status__c = 'Reserved';
                  if (Schema.sObjectType.OrderItem.fields.ERP7__Is_Back_Order__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Is_Back_Order__c.isUpdateable()) soli.ERP7__Is_Back_Order__c = false;
                  if (akSOLI < 10000) {
                    if (!SOLIS2UpdateSet.contains(soli.Id)) {
                      SOLIS2Update.add(soli);
                      SOLIS2UpdateSet.add(soli.Id);
                      akSOLI++;
                    }
                  } else if (akSOLI >= 10000 && akSOLI < 19998) {
                    if (!soliIds.contains(soli.Id)) {
                      soliIds.add(soli.Id);
                      akSOLI++;
                    }
                  }
                } else StockExceed = soliStockExceed;
              }
            }
          }
          if (!stockExceed) {
            if (Schema.sObjectType.Order.fields.ERP7__Is_Back_Order__c.isCreateable() && Schema.sObjectType.Order.fields.ERP7__Is_Back_Order__c.isUpdateable()) so.ERP7__Is_Back_Order__c = false;
              //change by khaleeq 10 july 2025 for status change in order
              if(so.Status != 'Pending Shipment' && so.Status != 'Picked up' && so.Status != 'Shipped' && so.Status != 'Delivered' && so.Status != 'Canceled'){ // this line
                  if (Schema.sObjectType.Order.fields.Status.isCreateable() && Schema.sObjectType.Order.fields.Status.isUpdateable()) system.debug('1'); so.Status = 'Activated';
              }// this line
            
            
              if (akSO < 10000) {
              if (!SOS2UpdateSet.contains(so.Id)) {
                SOS2UpdateSet.add(so.Id);
                SOS2Update.add(so);
                akSO++;
              }
            } else if (akSO >= 10000 && akSO < 19998) {
              if (!soIds2.contains(so.Id)) {
                soIds2.add(so.Id);
                akSO++;
              }
            }
          }
        }
        if (SOS2Update.size() > 0 && Schema.SObjectType.Order.isCreateable() && Schema.SObjectType.Order.isUpdateable()) {
          System.debug('inside SOS2Update');
          update SOS2Update;
        } else {
          /*Not allowed to update*/ }
        if (SOLIS2Update.size() > 0 && Schema.SObjectType.OrderItem.isCreateable() && Schema.SObjectType.OrderItem.isUpdateable()) {
          System.debug('inside SOLIS2Update');
          update SOLIS2Update;
        } else {
          /*Not allowed to update*/ }
        System.debug('soIds2:' + soIds2.size());
        System.debug('soliIds:' + soliIds.size());
        if (soIds2.size() > 0) MaintainBatchStocks.EvaluateOrders(soIds2);
        if (soliIds.size() > 0) MaintainBatchStocks.EvaluateOrdersLines(soliIds);
      }
      if (FC != null) {
        if (FC.ERP7__Auto_Update_SO_Back_Order__c) { 
          System.debug('inside ERP7__Auto_Update_SO_Back_Order__c here2');
          soIds = new Set < Id > ();
          soIds2 = new Set < Id > ();
          productIds = new Set < Id > ();
          soliIds = new Set < Id > ();
          ProductMap2StockComing = new Map < Id, Decimal > ();
          ProductMap2Stock = new Map < Id, List < ERP7__Inventory_Stock__c > > ();
          ProductMap2StockReserved = new Map < Id, Decimal > ();
          SOS2Update = new List < Order > ();
          SOLIS2Update = new List < OrderItem > ();
          SOS2UpdateSet = new Set < Id > ();
          SOLIS2UpdateSet = new Set < Id > ();
          for (Integer i = 0; i < System.Trigger.New.size(); i++) {
            ERP7__Stock_Inward_Line_Item__c sili = System.Trigger.New[i];
            if (sili.ERP7__Status__c != 'Awaiting Stock') { System.debug('in sil not Aw');
              Decimal siliOldQuantity = 0;
              Decimal siliQuantity = 0;
              if (sili.ERP7__Quantity__c != Null) siliQuantity = sili.ERP7__Quantity__c;
              if (Trigger.isUpdate && System.Trigger.Old[i].ERP7__Quantity__c != Null) siliOldQuantity = System.Trigger.Old[i].ERP7__Quantity__c;
              siliQuantity = siliQuantity - siliOldQuantity;
              if ((sili.SoId__c == Null || sili.SoId__c == '') && sili.ERP7__Product__c != Null) {
                productIds.add(sili.ERP7__Product__c);
                Decimal ik = 0;
                if (ProductMap2StockComing.containsKey(sili.ERP7__Product__c)) {
                  if (siliQuantity != Null) {
                    ik = ProductMap2StockComing.get(sili.ERP7__product__c) + siliQuantity;
                    ProductMap2StockComing.remove(sili.ERP7__Product__c);
                    ProductMap2StockComing.put(sili.ERP7__Product__c, ik);
                  }
                } else {
                  ik = siliQuantity;
                  ProductMap2StockComing.put(sili.ERP7__product__c, ik);
                }
              }
            }
          } System.debug('ProductMap2StockComing '+ProductMap2StockComing); System.debug('productIds 2'+productIds);
          if (productIds.size() > 0) {
            for (ERP7__Inventory_Stock__c WarehouseItemInventoryStocks: [Select Id, Name, ERP7__Active__c, ERP7__Warehouse__c, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c IN: productIds And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 LIMIT 999]) { System.debug('ware');
              if (ProductMap2Stock.containsKey(WarehouseItemInventoryStocks.ERP7__product__c)) ProductMap2Stock.get(WarehouseItemInventoryStocks.ERP7__product__c).add(WarehouseItemInventoryStocks);
              else {
                List < ERP7__Inventory_Stock__c > WarehouseItemInventoryStockLists = new List < ERP7__Inventory_Stock__c > ();
                WarehouseItemInventoryStockLists.add(WarehouseItemInventoryStocks);
                ProductMap2Stock.put(WarehouseItemInventoryStocks.ERP7__product__c, WarehouseItemInventoryStockLists);
                System.debug('else added pro');
              }
              for (Id pId: ProductMap2Stock.keySet()) ProductMap2StockReserved.put(pId, 0);
            }
            System.debug('productmap2Stock '+ProductMap2Stock);
            List < OrderItem > Solis = [Select Id, ERP7__Inventory_Tracked__c, Product2Id, Quantity, OrderId, ERP7__Status__c, ERP7__PriceBookId__c From OrderItem Where Product2Id In: productIds And ERP7__Is_Back_Order__c = true Order By CreatedDate ASC LIMIT 999];
            System.debug('sos2updatinng');
            System.debug('solis'+Solis);
            Integer nsSO = 0;
            Integer nsSOLI = 0;
            for (OrderItem soli: Solis) {
              Boolean soliStockExceed = false;
              If(!soliStockExceed) {
                if (soli.ERP7__Inventory_Tracked__c == true && ProductMap2Stock != null && ProductMap2Stock.containsKey(soli.Product2Id)) {
                  System.debug('inside 12');
                  Decimal totalQuantity = 0;
                  for (ERP7__Inventory_Stock__c IS: ProductMap2Stock.get(soli.Product2Id)) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c;
                  if (ProductMap2StockComing.containskey(soli.Product2Id)) totalQuantity += ProductMap2StockComing.get(soli.Product2Id);
                  if ((totalQuantity - ProductMap2StockReserved.get(soli.Product2Id)) < Soli.Quantity) {
                    soliStockExceed = true;
                  } else ProductMap2StockReserved.put(soli.Product2Id, (ProductMap2StockReserved.get(soli.Product2Id) + Soli.Quantity));
                } System.debug('ProductMap2StockReserved '+ProductMap2StockReserved);
                if (!soliStockExceed) {
                  if (nsSO < 10000) {
                    if (!SOS2UpdateSet.contains(soli.OrderId)) {
                        system.debug('2');
                      SOS2Update.add(new Order(id = soli.OrderId, ERP7__Is_Back_Order__c = true, Status = 'Activated'));
                      SOS2UpdateSet.add(soli.OrderId);
                      soIds2.add(soli.OrderId);
                      nsSO++;
                    }
                  } else if (nsSO >= 10000 && nsSO < 19998) {
                    if (!soIds2.contains(soli.OrderId)) {
                      soIds2.add(soli.OrderId);
                      nsSO++;
                    }
                  }
                  System.debug('soIds2'+soIds2);
                  if (Schema.sObjectType.OrderItem.fields.ERP7__Order_Line_Status__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Order_Line_Status__c.isUpdateable()) soli.ERP7__Order_Line_Status__c = 'Reserved'; System.debug('set reserved');
                  if (Schema.sObjectType.OrderItem.fields.ERP7__Is_Back_Order__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Is_Back_Order__c.isUpdateable()) soli.ERP7__Is_Back_Order__c = false; System.debug('set false backorder');
                  if (nsSOLI < 10000) {
                  if (!SOLIS2UpdateSet.contains(soli.Id)) {
                      SOLIS2Update.add(soli);
                      SOLIS2UpdateSet.add(soli.Id);
                      nsSOLI++;
                    }
                  } else if (nsSOLI >= 10000 && nsSOLI < 19998) {
                    if (!soliIds.contains(soli.Id)) {
                      soliIds.add(soli.Id);
                      nsSOLI++;
                    }
                  }
                }
              }
            }
            if (SOS2Update.size() > 0 && Schema.SObjectType.Order.isCreateable() && Schema.SObjectType.Order.isUpdateable()) { System.debug('sos2updatinng 2');
              update SOS2Update;
            } else {
              /*Not allowed to update*/ }
            // if (SOLIS2Update.size() > 0 && Schema.SObjectType.OrderItem.isCreateable() && Schema.SObjectType.OrderItem.isUpdateable()) { System.debug('sos2updatinn89');
            //   update SOLIS2Update;
            // } else {
            //   /*Not allowed to update*/ }
            //new 
            if (SOLIS2Update.size() > 0 && Schema.SObjectType.OrderItem.isCreateable() && Schema.SObjectType.OrderItem.isUpdateable()) {
                  System.debug('inside SOLIS2Update');
                  // Verify OrderItem records exist
                  Set<Id> soliIdsToUpdate = new Set<Id>();
                  for (OrderItem soli : SOLIS2Update) {
                      soliIdsToUpdate.add(soli.Id);
                      System.debug('OrderItem to update: ' + soli.Id + ', Status: ' + soli.ERP7__Order_Line_Status__c + ', BackOrder: ' + soli.ERP7__Is_Back_Order__c);
                  }
                  // Map<Id, OrderItem> existingSolis = new Map<Id, OrderItem>(
                  //     [SELECT Id FROM OrderItem WHERE Id IN :soliIdsToUpdate AND IsDeleted = FALSE ALL ROWS FOR UPDATE]
                  // );
                  Map<Id, OrderItem> existingSolis = new Map<Id, OrderItem>();
                      for (OrderItem oi : [SELECT Id, IsDeleted FROM OrderItem WHERE Id IN :soliIdsToUpdate ALL ROWS]) {
                          if (!oi.IsDeleted) {
                              existingSolis.put(oi.Id, oi);
                          }
                      }
                      System.debug('existingSolis '+existingSolis);
                  List<OrderItem> validSolisToUpdate = new List<OrderItem>();
                  for (OrderItem soli : SOLIS2Update) {
                      if (existingSolis.containsKey(soli.Id)) {
                          validSolisToUpdate.add(soli);
                      } else {
                          System.debug('OrderItem with ID ' + soli.Id + ' is deleted or inaccessible. Skipping update.');
                      }
                  } System.debug('validSolisToUpdate '+validSolisToUpdate);
                  if (validSolisToUpdate.size() > 0) {
                     try {
                          System.debug('🔁 Updating validSolisToUpdate bfr reverse -> ' + validSolisToUpdate);
                          for (OrderItem oi : validSolisToUpdate) {
                                System.debug(' bfr reverse ---' + oi.Id);
                            }
                           List<OrderItem> reversedList = new List<OrderItem>();
                            for (Integer i = validSolisToUpdate.size() - 1; i >= 0; i--) {
                                reversedList.add(validSolisToUpdate[i]);
                            }
                            validSolisToUpdate = reversedList;
                          System.debug('validSolisToUpdate reversed -> ' + validSolisToUpdate);
                          for (OrderItem oi : validSolisToUpdate) {
                                  System.debug(' Afr reverse --- ' + oi.Id);
                              }
                          update validSolisToUpdate; 
                          System.debug('✅ Successfully updated ' + validSolisToUpdate.size() + ' OrderItems.');
                      } catch (DmlException e) {
                          System.debug('❌ DML Exception during OrderItem update.');
                          System.debug('Error Message       : ' + e.getMessage());
                          System.debug('Stack Trace         : ' + e.getStackTraceString());
                          System.debug('Total DML Errors    : ' + e.getNumDml());

                          for (Integer i = 0; i < e.getNumDml(); i++) {
                              System.debug('--- Error ' + (i + 1) + ' ---');
                              if (i < validSolisToUpdate.size()) {
                                  System.debug('Record Causing Error: ' + validSolisToUpdate[i]);
                              } else {
                                  System.debug('Record Causing Error: Index out of bounds for validSolisToUpdate');
                              }
                              System.debug('Status Code         : ' + e.getDmlType(i));
                              System.debug('Error Message       : ' + e.getDmlMessage(i));
                              System.debug('Fields in Error     : ' + e.getDmlFields(i));
                          }
                      }

                  } else {
                      System.debug('No valid OrderItems to update.');
                  }
              } else {
                  /*Not allowed to update*/
              }
            if (soIds2.size() > 0 && !system.isFuture() && !system.isBatch()) MaintainBatchStocks.EvaluateOrders(soIds2);
            if (soliIds.size() > 0 && !system.isFuture() && !system.isBatch()) MaintainBatchStocks.EvaluateOrdersLines(soliIds);
          }
        }
      }
    }            
        /*  
Putaway Quantity Rollup to Logistic Line Item
*/
        /*commented on  22_02_24 by Shaguftha as the putaway qty update is not required */
       /* if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isDelete || trigger.isUnDelete)) {
            PreventRecursiveLedgerEntry.LogisticLineRollup = true;
            list<RollUpSummaryUtility.fieldDefinition> FieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity__c', 'ERP7__Putaway_Quantity__c')
                    };
                        List<Stock_Inward_Line_Item__c> Recs = (!trigger.isDelete)? trigger.new : trigger.old;
            RollUpSummaryUtility.rollUpTrigger(FieldDefinitions1, Recs, 'ERP7__Stock_Inward_Line_Item__c','ERP7__Logistic_Line_Item__c', 'ERP7__Logistic_Line_Item__c', ' And ERP7__Logistic_Line_Item__r.ERP7__Explode__c = false and ERP7__Status__c != \'Awaiting Stock\' ');
            
        }*/
    }
}