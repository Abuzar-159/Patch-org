trigger ManufacturingOrder on Manufacturing_Order__c(after insert, after update, after undelete, before delete, after delete) {
    Map < Id, List < ERP7__Operation__c >> Routing_Operations = new Map < Id, List < ERP7__Operation__c >> ();
    list < Id > proIds = new list < Id > ();
    Set < Id > OperationIds = new Set < Id > ();
    Set < Id > RoutingIds = new Set < Id > ();
    Map < Id, Set < Id >> RoutingWorkCenters = new Map < Id, Set < Id >> ();
    Map < Id, Set < Id >> RoutingProcesses = new Map < Id, Set < Id >> ();
    Map < Id, Boolean > IsProductKit = new Map < Id, Boolean > ();
    list < ERP7__WO__c > WOs2Create = new list < ERP7__WO__c > ();
    list < ERP7__Actions_Tasks__c > actions2Create = new list < ERP7__Actions_Tasks__c > ();
    list < ERP7__Timesheet__c > timesheets2Create = new list < ERP7__Timesheet__c > ();
    list < ERP7__Work_Order_Line_Items__c > WOLines2Create = new list < ERP7__Work_Order_Line_Items__c > ();
    List < ERP7__MRP__c > mrps2delete = new List < ERP7__MRP__c > ();
    Map < Id, List < ERP7__MRP__c >> moliMrps = new Map < Id, List < ERP7__MRP__c >> ();
    Map < Id, List < ERP7__BOM__c >> moliBOMS = new Map < Id, List < ERP7__BOM__c >> ();
    List < ERP7__MRP__c > MRPS2Insert = new List < ERP7__MRP__c > ();
    List < Inventory_Stock__c > stocks2upsert = new List < Inventory_Stock__c > ();
    List < Stock_Inward_Line_Item__c > stockInwards2upsert = new List < Stock_Inward_Line_Item__c > ();
    Map < Id, Inventory_Stock__c > moliStockMap = new Map < Id, Inventory_Stock__c > ();
    Map < String, ERP7__WO__c > cycleWO = new Map < String, ERP7__WO__c > ();
    Map < Id, Id > ProcessWC = new Map < Id, Id > (); 
    list < Manufacturing_Order__c > MOs2CreateWIPs = new list < Manufacturing_Order__c > ();
    set <Id> CompletedMO = new set <Id> ();
    
    try{
        /* added shaguftha 21/02/24 FC and ProceedTransactionCreation to run MO transaction */
        Boolean ProceedTransactionCreation = false;
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ 
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
        }
        if(FC != null){
            ProceedTransactionCreation = FC.ERP7__Create_MO_transactions__c;
        }
        system.debug('ProceedTransactionCreation : '+ProceedTransactionCreation);
        //Moin added this below 3 line on 17th January 2024 in order to track WIP Inventory
        if(ProceedTransactionCreation){
            if (Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsUndelete) && PreventRecursiveLedgerEntry.preventMoTriggerTransactions) {
                PostingPreventingHandler.createTransactionsAndLedgerEntries(System.Trigger.New, System.Trigger.NewMap.KeySet());
            }
        }
      
        system.debug('PreventRecursiveLedgerEntry.testCasesTransactions : '+PreventRecursiveLedgerEntry.testCasesTransactions);
        if (!PreventRecursiveLedgerEntry.testCasesTransactions && PreventRecursiveLedgerEntry.MOTrigger) { 
            PreventRecursiveLedgerEntry.MOTrigger = false;
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            if (Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsUndelete)) {
                if(Trigger.IsInsert || Trigger.IsUndelete){
                    for (Manufacturing_Order__c MO: System.Trigger.New) {
                        if (MO.ERP7__Initiate_MO__c){
                            if(MO.ERP7__Routing__c != Null) RoutingIds.add(MO.ERP7__Routing__c);
                            if(MO.ERP7__Product__c != Null) proIds.add(MO.ERP7__Product__c);
                            MOs2CreateWIPs.add(MO);
                        }
                    }
                }
                system.debug('MOs2CreateWIPs : '+MOs2CreateWIPs.size());
                if (Trigger.IsUpdate) {
                    for (Manufacturing_Order__c MO: System.Trigger.New) {
                        
                      if(MO.ERP7__Status__c == 'Complete'  || MO.ERP7__Status__c == 'Cancelled') CompletedMO.add(MO.Id);
                        for(Manufacturing_Order__c MO_Old: System.Trigger.Old){
                            if (MO.ERP7__Initiate_MO__c && MO.ERP7__Initiate_MO__c != MO_Old.ERP7__Initiate_MO__c){
                                if(MO.ERP7__Routing__c != Null) RoutingIds.add(MO.ERP7__Routing__c);
                                if(MO.ERP7__Product__c != Null) proIds.add(MO.ERP7__Product__c);
                                MOs2CreateWIPs.add(MO);
                            }
                        }
                    } 
                }
                //('CompletedMO size : '+CompletedMO.size());
                if(CompletedMO.size() > 0){
                   List<ERP7__Stock_Outward_Line_Item__c> stockstoCreate = new List<ERP7__Stock_Outward_Line_Item__c>();
                    List<ERP7__Stock_Outward_Line_Item__c> reservedStock = [Select Id,ERP7__Product__r.Name,ERP7__Manufacturing_Order__c,Name,ERP7__Product__c,ERP7__Site_Product_Service_Inventory_Stock__c,ERP7__MRP_Material_Requirements_Planning__c, ERP7__Material_Batch_Lot__c,ERP7__Quantity__c,ERP7__Status__c,ERP7__Serial__c,ERP7__MRP_Material_Requirements_Planning__r.ERP7__Consumed_Quantity__c,ERP7__MRP_Material_Requirements_Planning__r.ERP7__Fulfilled_Amount__c,ERP7__MRP_Material_Requirements_Planning__r.ERP7__Scrapped_Quantity__c from ERP7__Stock_Outward_Line_Item__c where ERP7__Manufacturing_Order__c IN :CompletedMO And ERP7__Status__c = 'Reserved' FOR UPDATE];//for update added by Idris. Old code was causing exception like 'unable to lock row'
                    for(ERP7__Stock_Outward_Line_Item__c stock : reservedStock){
                        if(stock.ERP7__Status__c != 'Committed' && stock.ERP7__Status__c == 'Reserved' && stock.ERP7__MRP_Material_Requirements_Planning__c!=null && (stock.ERP7__MRP_Material_Requirements_Planning__r.ERP7__Consumed_Quantity__c == 0 || ((stock.ERP7__MRP_Material_Requirements_Planning__r.ERP7__Consumed_Quantity__c + stock.ERP7__MRP_Material_Requirements_Planning__r.ERP7__Scrapped_Quantity__c) < stock.ERP7__MRP_Material_Requirements_Planning__r.ERP7__Fulfilled_Amount__c)) ) stockstoCreate.add(stock); // added +scrap by shaguftha on 19/09/23 to avoid the update od stock outward which are of scrap Qty
                    }
                    //('stockstoCreate : '+stockstoCreate.size());
                    if(stockstoCreate.size() > 0){
                       // List < Stock_Inward_Line_Item__c > stockIntoAddinv = new List < Stock_Inward_Line_Item__c > ();
                        for(ERP7__Stock_Outward_Line_Item__c outwards : stockstoCreate){
                           if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()) outwards.ERP7__Status__c = 'Rejected';
                           /* ERP7__Stock_Inward_Line_Item__c createnewstock  = new ERP7__Stock_Inward_Line_Item__c();
                            createnewstock.Name = outwards.ERP7__Product__r.Name;
                            createnewstock.ERP7__Active__c = true;
                            createnewstock.ERP7__Manufacturing_Order__c = outwards.ERP7__Manufacturing_Order__c;
                            createnewstock.ERP7__Quantity__c = outwards.ERP7__Quantity__c;
                            createnewstock.ERP7__Site_ProductService_InventoryStock__c = outwards.ERP7__Site_Product_Service_Inventory_Stock__c;
                            createnewstock.ERP7__Product__c = outwards.ERP7__Product__c;
                            createnewstock.ERP7__Material_Batch_Lot__c = outwards.ERP7__Material_Batch_Lot__c;
                            createnewstock.ERP7__Serial__c = outwards.ERP7__Serial__c;
                            
                            stockIntoAddinv.add(createnewstock);*/
                        }
                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()) update stockstoCreate; else{ }
                        //if(stockIntoAddinv.size() > 0 && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Site_ProductService_InventoryStock__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable()) { insert  stockIntoAddinv;  } else{ //('no access'); }
                        
                    }
                    
                }
                /* 
                    Start ==> Create and WIPs, Batches and Serials
                */
                List<ERP7__WIP__c> WIPs2Insert = new List<ERP7__WIP__c>();
                List<ERP7__WIP__c> SerialWIPs2Insert = new List<ERP7__WIP__c>();
                List<ERP7__WIP__c> SerialWIPs2Insert2 = new List<ERP7__WIP__c>();
                 List<ERP7__Serial_Number__c > serials2Upsert = new List<ERP7__Serial_Number__c >();
                List<ERP7__Serial_Number__c > serials2Upsert2 = new List<ERP7__Serial_Number__c >();
                Map<ERP7__WIP__c, ERP7__Batch__c > BatchWIPMap = new Map<ERP7__WIP__c, ERP7__Batch__c >();
                Map<ERP7__WIP__c, ERP7__Batch__c > BatchWIPMap2 = new Map<ERP7__WIP__c, ERP7__Batch__c >();
                List<ERP7__Inventory_Stock__c> StockList2Create = new List<ERP7__Inventory_Stock__c>();
                List<ERP7__Stock_Inward_Line_Item__c> StocksInwardList2Create = new List<ERP7__Stock_Inward_Line_Item__c>();
                 Map<Id, ERP7__Inventory_Stock__c> pliStock = new Map<Id, ERP7__Inventory_Stock__c>();
                Map<Id, ERP7__Stock_Inward_Line_Item__c> pliStockInward = new Map<Id, ERP7__Stock_Inward_Line_Item__c>();
                
                List<ERP7__Stock_Inward_Line_Item__c> existingInwards = [Select Id,Name,ERP7__Manufacturing_Order__c,ERP7__Quantity__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Manufacturing_Order__c IN: System.Trigger.NewMap.KeySet() and Name = 'Awaiting Stock' and ERP7__Status__c =  'Awaiting Stock'];
                System.debug('existingInwards : '+existingInwards.size());
                Map<Id,ERP7__Stock_Inward_Line_Item__c> MOInwards = new Map<Id,ERP7__Stock_Inward_Line_Item__c> ();
                
                for(ERP7__Stock_Inward_Line_Item__c sin :existingInwards) MOInwards.put(sin.ERP7__Manufacturing_Order__c,sin);
                 for (Manufacturing_Order__c MO: System.Trigger.New) {
                    System.debug('MO.Status : '+MO.ERP7__Status__c);
                    if(MO.ERP7__Serialise__c){
                    //     if(!MOInwards.containsKey(MO.Id)){
                    //         ERP7__Inventory_Stock__c Stock2Create = new ERP7__Inventory_Stock__c(ERP7__Active__c = true, Name = 'Awaiting Stock', ERP7__Checked_In_Date__c = system.today(), ERP7__Product__c = MO.ERP7__Product__c); //ERP7__Version__c = MO.ERP7__Version__c
                    //        if(MO.ERP7__Finished_Products_SiteId__c != Null) Stock2Create.ERP7__Warehouse__c = MO.ERP7__Finished_Products_SiteId__c;
                            
                    //         ERP7__Stock_Inward_Line_Item__c StockInward2Create = new ERP7__Stock_Inward_Line_Item__c(ERP7__Manufacturing_Order__c = MO.Id, Name = 'Awaiting Stock', ERP7__Active__c = true, ERP7__Product__c = MO.ERP7__Product__c, ERP7__Status__c = 'Awaiting Stock');
                    //         System.debug('new creating inv and SILI Stock2Create StockInward2Create : '+Stock2Create+' StockInward2Create : '+StockInward2Create);
                    //         if(MO.ERP7__Status__c == 'Completed') StockInward2Create.ERP7__Quantity__c = 0;
                    //         else  StockInward2Create.ERP7__Quantity__c = MO.ERP7__Quantity__c - (MO.ERP7__Scrap_Quantity__c + MO.ERP7__Quantity_Produced__c);
                    //         pliStock.put(MO.Id, Stock2Create);
                    //         pliStockInward.put(MO.Id, StockInward2Create);
                    //         StockList2Create.add(Stock2Create);
                    //         StocksInwardList2Create.add(StockInward2Create);
                    //     }

                    //     else{
                    //         ERP7__Stock_Inward_Line_Item__c StockInward2Update = MOInwards.get(MO.Id);
                    //         if(MO.ERP7__Status__c == 'Completed') StockInward2Update.ERP7__Quantity__c = 0;
                    //         else  StockInward2Update.ERP7__Quantity__c = MO.ERP7__Quantity__c - (MO.ERP7__Scrap_Quantity__c + MO.ERP7__Quantity_Produced__c);
                    //         system.debug('StockInward2Update.ERP7__Quantity__c  : '+StockInward2Update.ERP7__Quantity__c);
                    //         StocksInwardList2Create.add(StockInward2Update);
                    //     }
                    // }
                    // commented existing code 126-147 and added this by matheen 148-194 on 16-8-25 for new inevntory is being created with 0 qty (PROD ISSUE)
                    if (!MOInwards.containsKey(MO.Id)) {
                        Decimal pendingQty = MO.ERP7__Quantity__c - (MO.ERP7__Scrap_Quantity__c + MO.ERP7__Quantity_Produced__c);

                        if (pendingQty <= 0) {
                            System.debug('Skipping new Inventory/Inward creation for MO ' + MO.Id + ' because pendingQty = ' + pendingQty);
                        } else {
                            ERP7__Inventory_Stock__c Stock2Create = new ERP7__Inventory_Stock__c(
                                ERP7__Active__c = true,
                                Name = 'Awaiting Stock',
                                ERP7__Checked_In_Date__c = System.today(),
                                ERP7__Product__c = MO.ERP7__Product__c
                            );
                            if (MO.ERP7__Finished_Products_SiteId__c != null) {
                                Stock2Create.ERP7__Warehouse__c = MO.ERP7__Finished_Products_SiteId__c;
                            }

                            ERP7__Stock_Inward_Line_Item__c StockInward2Create = new ERP7__Stock_Inward_Line_Item__c(
                                ERP7__Manufacturing_Order__c = MO.Id,
                                Name = 'Awaiting Stock',
                                ERP7__Active__c = true,
                                ERP7__Product__c = MO.ERP7__Product__c,
                                ERP7__Status__c = 'Awaiting Stock',
                                ERP7__Quantity__c = pendingQty
                            );

                            System.debug('Creating Inventory and Inward for MO ' + MO.Id + ' with qty ' + pendingQty);

                            pliStock.put(MO.Id, Stock2Create);
                            pliStockInward.put(MO.Id, StockInward2Create);
                            StockList2Create.add(Stock2Create);
                            StocksInwardList2Create.add(StockInward2Create);
                        }
                    } else {
                        ERP7__Stock_Inward_Line_Item__c StockInward2Update = MOInwards.get(MO.Id);
                        if (MO.ERP7__Status__c == 'Completed') {
                            StockInward2Update.ERP7__Quantity__c = 0;
                        } else {
                            StockInward2Update.ERP7__Quantity__c =
                            MO.ERP7__Quantity__c - (MO.ERP7__Scrap_Quantity__c + MO.ERP7__Quantity_Produced__c);
                        }
                        System.debug('Updating existing Inward for MO ' + MO.Id + ' to qty ' + StockInward2Update.ERP7__Quantity__c);
                        StocksInwardList2Create.add(StockInward2Update);
                    }

                 }
                }
                for (Manufacturing_Order__c MO: MOs2CreateWIPs) {
                    //new code for serial batch wip
                    if(MO.ERP7__Serialise__c && MO.ERP7__Lot_Tracked__c){
                        integer j = 1;
                        ERP7__WIP__c WIP = new ERP7__WIP__c();
                        if(Schema.sObjectType.ERP7__WIP__c.fields.Name.isCreateable()) WIP.Name = MO.Name+'-'+String.valueof(j);
                        if(Schema.sObjectType.ERP7__WIP__c.fields.ERP7__MO__c.isCreateable()) WIP.ERP7__MO__c = MO.Id;
                        SerialWIPs2Insert2.add(WIP);
                        while(j <= Integer.valueof(MO.ERP7__Quantity__c)){
                            ERP7__Serial_Number__c Serial = new ERP7__Serial_Number__c();
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Available__c.isCreateable()) Serial.ERP7__Available__c = false; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isCreateable()) Serial.ERP7__Product__c = MO.ERP7__Product__c; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable()) Serial.ERP7__Warehouse__c = MO.ERP7__Finished_Products_SiteId__c; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isCreateable()) Serial.ERP7__Production_Version__c = MO.ERP7__Version__c; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isCreateable()) Serial.ERP7__Manufacturing_Order__c = MO.Id;
                            serials2Upsert2.add(Serial);
                            j++;
                        }
                        ERP7__Batch__c Batch = new ERP7__Batch__c();
                        if(Schema.sObjectType.ERP7__Batch__c.fields.Active__c.isCreateable()) Batch.ERP7__Active__c = true; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Product__c.isCreateable()) Batch.ERP7__Product__c = MO.ERP7__Product__c; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Production_Version__c.isCreateable()) Batch.ERP7__Production_Version__c = MO.ERP7__Version__c; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Manufacturing_Order__c.isCreateable()) Batch.ERP7__Manufacturing_Order__c = MO.Id; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Inward_Quantity__c.isCreateable()) Batch.ERP7__Inward_Quantity__c = MO.ERP7__Quantity__c;
                        if(MO.ERP7__Expected_Date__c != Null && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Date_of_Manufacture__c.isCreateable()) Batch.ERP7__Date_of_Manufacture__c = MO.ERP7__Expected_Date__c;
                        BatchWIPMap2.put(WIP,Batch);
                    } 
                    else if(MO.ERP7__Serialise__c){
                       //change by shaguftha 1 - 14/09/23
                        integer j = 1;
                        ERP7__WIP__c WIP = new ERP7__WIP__c();
                        if(Schema.sObjectType.ERP7__WIP__c.fields.Name.isCreateable()) WIP.Name = MO.Name+'-'+String.valueof(j);
                        if(Schema.sObjectType.ERP7__WIP__c.fields.ERP7__MO__c.isCreateable()) WIP.ERP7__MO__c = MO.Id;
                        SerialWIPs2Insert.add(WIP);
                        while(j <= Integer.valueof(MO.ERP7__Quantity__c)){
                            ERP7__Serial_Number__c Serial = new ERP7__Serial_Number__c();
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Available__c.isCreateable()) Serial.ERP7__Available__c = false; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isCreateable()) Serial.ERP7__Product__c = MO.ERP7__Product__c; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable()) Serial.ERP7__Warehouse__c = MO.ERP7__Finished_Products_SiteId__c; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isCreateable()) Serial.ERP7__Production_Version__c = MO.ERP7__Version__c; 
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isCreateable()) Serial.ERP7__Manufacturing_Order__c = MO.Id;
                            serials2Upsert.add(Serial);
                            j++;
                        }
                         //change by shaguftha 1 - 14/09/23
                    } 
                    else if(MO.ERP7__Lot_Tracked__c){
                        ERP7__WIP__c WIP = new ERP7__WIP__c(Name = MO.Name, ERP7__MO__c = MO.Id);
                        ERP7__Batch__c Batch = new ERP7__Batch__c();
                        if(Schema.sObjectType.ERP7__Batch__c.fields.Active__c.isCreateable()) Batch.ERP7__Active__c = true; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Product__c.isCreateable()) Batch.ERP7__Product__c = MO.ERP7__Product__c; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Production_Version__c.isCreateable()) Batch.ERP7__Production_Version__c = MO.ERP7__Version__c; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Manufacturing_Order__c.isCreateable()) Batch.ERP7__Manufacturing_Order__c = MO.Id; 
                        if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Inward_Quantity__c.isCreateable()) Batch.ERP7__Inward_Quantity__c = MO.ERP7__Quantity__c;
                        if(MO.ERP7__Expected_Date__c != Null && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Date_of_Manufacture__c.isCreateable()) Batch.ERP7__Date_of_Manufacture__c = MO.ERP7__Expected_Date__c;
                        BatchWIPMap.put(WIP,Batch);
                    } 
                    else{
                        ERP7__WIP__c WIP = new ERP7__WIP__c();
                        if(Schema.sObjectType.ERP7__WIP__c.fields.Name.isCreateable()) WIP.Name = MO.Name;
                        if(Schema.sObjectType.ERP7__WIP__c.fields.ERP7__MO__c.isCreateable()) WIP.ERP7__MO__c = MO.Id;
                        WIPs2Insert.add(WIP);
                    }
               } //ended the for loop here
                //change by shaguftha 2 - 14/09/23
                if(BatchWIPMap2.size() > 0 && SerialWIPs2Insert2.size() > 0){
                    if(Schema.sObjectType.ERP7__Batch__c.isCreateable()) insert BatchWIPMap2.Values(); else{ }
                    for(ERP7__WIP__c WIP : BatchWIPMap2.KeySet()){
                        if(Schema.sObjectType.ERP7__WIP__c.fields.ERP7__Material_Batch_Lot__c.isCreateable()) WIP.ERP7__Material_Batch_Lot__c = BatchWIPMap2.get(WIP).Id;
                    }
                    insert SerialWIPs2Insert2;
                    for(ERP7__Serial_Number__c ser : serials2Upsert2){
                        if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__WIP__c.isCreateable()) ser.ERP7__WIP__c = SerialWIPs2Insert2[0].Id;
                    }
                    system.debug('serials2Upsert : '+serials2Upsert2.size());
                    PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation = false;
                    insert serials2Upsert2;
                }
                
                     
                    if(SerialWIPs2Insert.size() > 0){
                        insert SerialWIPs2Insert;
                        for(ERP7__Serial_Number__c ser : serials2Upsert){
                            if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__WIP__c.isCreateable()) ser.ERP7__WIP__c = SerialWIPs2Insert[0].Id;
                        }
                        system.debug('serials2Upsert : '+serials2Upsert.size());
                       PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation = false;
                        insert serials2Upsert;
                    }
                //change by shaguftha 1 end here
                    if(BatchWIPMap.size() > 0 ){
                        if(Schema.sObjectType.ERP7__Batch__c.isCreateable()) insert BatchWIPMap.Values(); else{ }
                        for(ERP7__WIP__c WIP : BatchWIPMap.KeySet()){
                           if(Schema.sObjectType.ERP7__WIP__c.fields.ERP7__Material_Batch_Lot__c.isCreateable()) WIP.ERP7__Material_Batch_Lot__c = BatchWIPMap.get(WIP).Id;
                        }
                        WIPs2Insert.addAll(BatchWIPMap.KeySet());
                    }
                    
                //}  //commented the for loop for bulikifing
                if(WIPs2Insert.size() > 0 && Schema.sObjectType.ERP7__WIP__c.isCreateable()) { insert WIPs2Insert; } else{  }
                
                if(StockList2Create.size() > 0)  { System.debug('inserting stockList2Create'); insert StockList2Create;}
                
                for(Id pliId : pliStockInward.KeySet()){
                    pliStockInward.get(pliId).ERP7__Site_ProductService_InventoryStock__c = pliStock.get(pliId).Id;
                }
                system.debug('*** StocksInwardList2Create : '+StocksInwardList2Create.size());
                if(StocksInwardList2Create.size() > 0)  upsert StocksInwardList2Create;
               
                /* 
                    End ==>  Create and WIPs, Batches and Serials
                */
                
                /* 
                    Start ==> Create and manage WO, WO Lines and Action and Tasks
                */
                if(RoutingIds.size() > 0){
                    Map<Id, ERP7__Operation__c> OperationMap = new Map<Id, ERP7__Operation__c>();
                    List < ERP7__Operation__c > Operations = [Select Id, Name, ERP7__Routing_Link__c, ERP7__Description__c, ERP7__Fixed_Cost__c, ERP7__Move_Time__c, ERP7__Next_Operation_No__c, ERP7__Operation_No__c,
                        ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Process_Cycle__r.ERP7__Progress__c ,ERP7__Process_Cycle__r.ERP7__Process__c, ERP7__Quantity__c, ERP7__Required__c, ERP7__Routing__c, ERP7__Run_Time__c, ERP7__Setup_Time__c, ERP7__Variable_Cost__c,
                        ERP7__Work_Center__c, ERP7__Wait_Time__c, ERP7__Type__c, ERP7__Auto_Clock_In__c
                        From ERP7__Operation__c Where ERP7__Routing__c In: RoutingIds And ERP7__Process_Cycle__c != Null Order By ERP7__Sort__c, ERP7__Process_Cycle__r.CreatedDate, ERP7__Operation_No__c ASC
                    ];
                    for (ERP7__Operation__c Operation: Operations) {
                        OperationMap.put(Operation.ERP7__Process_Cycle__c, Operation);
                        if (Operation.ERP7__Routing__c != Null && Routing_Operations.containskey(Operation.ERP7__Routing__c)) {
                            Routing_Operations.get(Operation.ERP7__Routing__c).add(Operation);
                        } else if (Operation.ERP7__Routing__c != Null && !Routing_Operations.containskey(Operation.ERP7__Routing__c)) {
                            List < ERP7__Operation__c > myList = new List < ERP7__Operation__c > ();
                            myList.add(Operation);
                            Routing_Operations.put(Operation.ERP7__Routing__c, myList);
                        }
                        
                        if (Operation.ERP7__Routing__c != Null && RoutingWorkCenters.containskey(Operation.ERP7__Routing__c)) {
                            RoutingWorkCenters.get(Operation.ERP7__Routing__c).add(Operation.ERP7__Work_Center__c);
                        } else if (Operation.ERP7__Routing__c != Null && !RoutingWorkCenters.containskey(Operation.ERP7__Routing__c)) {
                            Set < Id > myList = new Set < Id > ();
                            myList.add(Operation.ERP7__Work_Center__c);
                            RoutingWorkCenters.put(Operation.ERP7__Routing__c, myList);
                        }
                        
                        if (Operation.ERP7__Routing__c != Null && RoutingProcesses.containskey(Operation.ERP7__Routing__c)) {
                            RoutingProcesses.get(Operation.ERP7__Routing__c).add(Operation.ERP7__Process_Cycle__c);
                        } else if (Operation.ERP7__Routing__c != Null && !RoutingProcesses.containskey(Operation.ERP7__Routing__c)) {
                            Set < Id > myList = new Set < Id > ();
                            myList.add(Operation.ERP7__Process_Cycle__c);
                            RoutingProcesses.put(Operation.ERP7__Routing__c, myList);
                        }
                        
                        if (Operation.ERP7__Process_Cycle__c != Null && Operation.ERP7__Work_Center__c != Null) {
                            ProcessWC.put(Operation.ERP7__Process_Cycle__c, Operation.ERP7__Work_Center__c);
                        }
                    }
                    
                    for (Manufacturing_Order__c MO: System.Trigger.New) {
                        integer rps= 0;
                        if(MO.ERP7__Escape_Process__c == false){
                            if (MO.ERP7__Product__c != Null) IsProductKit.put(MO.ERP7__Product__c, MO.ERP7__Is_Kit__c);
                            if (RoutingWorkCenters.containsKey(MO.ERP7__Routing__c)) {
                                for (Id wcId: RoutingProcesses.get(MO.ERP7__Routing__c)) {
                                    ERP7__WO__c WO2Create = new ERP7__WO__c();
                                    if(Schema.sObjectType.ERP7__WO__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.Name.isUpdateable()) WO2Create.Name = OperationMap.get(WCId).ERP7__Process_Cycle__r.Name;   //MO.Name;
                                    //WO2Create.ERP7__Site__c = MO.ERP7__Finished_Products_Site__c;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.Planned_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.Planned_Date__c.isUpdateable()) WO2Create.Planned_Date__c = System.Today();
                                    //('OperationMap.get(WCId).ERP7__Process_Cycle__r.ERP7__Progress__c : '+OperationMap.get(WCId).ERP7__Process_Cycle__r.ERP7__Progress__c);
                                    if(Schema.sObjectType.ERP7__WO__c.fields.Progress__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.Progress__c.isUpdateable()) WO2Create.Progress__c = OperationMap.get(WCId).ERP7__Process_Cycle__r.ERP7__Progress__c;
                                    //('WO2Create.Progress__c : '+WO2Create.Progress__c);
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Process_Cycle__c.isUpdateable()) WO2Create.ERP7__Process_Cycle__c = WCId;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Status__c.isUpdateable()) WO2Create.ERP7__Status__c = 'Issued';
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Version__c.isUpdateable()) WO2Create.ERP7__Version__c = MO.ERP7__Version__c;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Project__c.isUpdateable()) WO2Create.ERP7__Project__c = MO.ERP7__Project__c;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Routing__c.isUpdateable()) WO2Create.ERP7__Routing__c = MO.ERP7__Routing__c;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Site__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Site__c.isUpdateable()) WO2Create.ERP7__Site__c = MO.ERP7__Finished_Products_SiteId__c;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__MO__c.isUpdateable()) WO2Create.ERP7__MO__c = MO.Id;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Product__c.isUpdateable()) WO2Create.ERP7__Product__c = MO.ERP7__Product__c;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isUpdateable()) WO2Create.ERP7__Quantity_Ordered__c = MO.ERP7__Quantity__c;
                                    if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Sales_Order__c.isUpdateable()) WO2Create.ERP7__Sales_Order__c = MO.ERP7__Sales_Order__c;
                                    if(rps == 0){
                                        if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isUpdateable()) WO2Create.ERP7__Start_Date__c = system.Now();
                                        if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isUpdateable()) WO2Create.ERP7__End_Date__c = system.Now().addHours(1);
                                   
                                    }else{
                                        if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Start_Date__c.isUpdateable()) WO2Create.ERP7__Start_Date__c = system.Now().addHours(rps);
                                        if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__End_Date__c.isUpdateable()) WO2Create.ERP7__End_Date__c =  system.Now().addHours(1+rps);
                                   
                                    }
                                   // MO.ERP7__End_Date__c = WO2Create.ERP7__End_Date__c;
                                    WO2Create.ERP7__ExpectedDate__c = MO.ERP7__End_Date__c;
                                     if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Type__c.isUpdateable()) WO2Create.ERP7__Type__c = 'Manufacturing';
                                    if(ProcessWC.containsKey(WCId)) if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.fields.ERP7__Work_Center__c.isUpdateable()) WO2Create.ERP7__Work_Center__c = ProcessWC.get(WCId);
                                    WOs2Create.add(WO2Create);
                                    String myId = String.valueof(MO.Id) + String.valueof(WCID);
                                    cycleWO.put(myId, WO2Create);
                                }
                            }
                            
                            if (Routing_Operations.containsKey(MO.ERP7__Routing__c)){
                                for (ERP7__Operation__c Operation: Routing_Operations.get(MO.ERP7__Routing__c)) {
                                    ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.Name.isUpdateable()) action2Create.Name = Operation.Name;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process_Cycle__c.isUpdateable()) action2Create.ERP7__Process_Cycle__c = Operation.ERP7__Process_Cycle__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()) action2Create.ERP7__Manufacturing_Order__c = MO.Id;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Operation__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Operation__c.isUpdateable()) action2Create.ERP7__Operation__c = Operation.Id;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Type__c.isUpdateable()) action2Create.ERP7__Type__c = Operation.ERP7__Type__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Work_Center__c.isUpdateable()) action2Create.ERP7__Work_Center__c = Operation.ERP7__Work_Center__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Product__c.isUpdateable()) action2Create.ERP7__Product__c = MO.ERP7__Product__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Auto_Clock_In__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Auto_Clock_In__c.isUpdateable()) action2Create.ERP7__Auto_Clock_In__c = Operation.ERP7__Auto_Clock_In__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process__c.isUpdateable()) action2Create.ERP7__Process__c = Operation.ERP7__Process_Cycle__r.ERP7__Process__c;
                                    actions2Create.add(action2Create);
                                }
                            }
                        }
                    }
                    if(WOs2Create.size() > 0 && Schema.SObjectType.ERP7__WO__c.isCreateable() && Schema.SObjectType.ERP7__WO__c.isUpdateable()) upsert WOs2Create; else{ }
                    for (ERP7__Actions_Tasks__c AT: actions2Create) {
                        String myId = String.valueof(AT.ERP7__Manufacturing_Order__c) + String.valueof(AT.ERP7__Process_Cycle__c);
                        if (cycleWO.containsKey(myId)) AT.ERP7__Work_Order__c = cycleWO.get(myId).Id;
                    }
                    if (actions2Create.size() > 0 && Schema.SObjectType.ERP7__Actions_Tasks__c.isCreateable() && Schema.SObjectType.ERP7__Actions_Tasks__c.isUpdateable()) upsert actions2Create; else{ }
                    for (ERP7__WO__c WO: WOs2Create) {
                        ERP7__Work_Order_Line_Items__c WOLine2Create = new ERP7__Work_Order_Line_Items__c();
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Name.isUpdateable()) WOLine2Create.Name = WO.Name;
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Active__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Active__c.isUpdateable()) WOLine2Create.ERP7__Active__c = true;
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Version__c.isUpdateable()) WOLine2Create.ERP7__Version__c = WO.ERP7__Version__c;
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Work_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Work_Orders__c.isUpdateable()) WOLine2Create.ERP7__Work_Orders__c = WO.Id;
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Product__c.isUpdateable()) WOLine2Create.ERP7__Product__c = WO.ERP7__Product__c;
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Quantity__c.isUpdateable()) WOLine2Create.ERP7__Quantity__c = WO.ERP7__Quantity_Ordered__c;
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Sales_Order__c.isUpdateable()) WOLine2Create.ERP7__Sales_Order__c = WO.ERP7__Sales_Order__c;
                        if(Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.Manufacturing_Order__c.isUpdateable()) WOLine2Create.Manufacturing_Order__c = WO.ERP7__MO__c;
                        if (IsProductKit.containsKey(WO.ERP7__Product__c) && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Explode__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.fields.ERP7__Explode__c.isUpdateable()) WOLine2Create.ERP7__Explode__c = IsProductKit.get(WO.ERP7__Product__c);
                        WOLines2Create.add(WOLine2Create);
                    }
                    if (WOLines2Create.size() > 0 && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Work_Order_Line_Items__c.isUpdateable()) upsert WOLines2Create; else{ }
                }
                /* 
                    End ==> Create and manage WO, WO Lines and Action and Tasks
                */
                
                
                /* 
                    //Start ==> Create and manage MRPS based on BOM and its versions ...
                
                if(proIds.size() > 0){
                    List<Id> CancelledMOIds = new List<Id>();
                    List < ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__Routing_Link__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name,
                        ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c
                        From ERP7__MRP__c
                        Where RecordType.Name = 'MRP Manufacturing' And
                        ERP7__MO__c In: System.Trigger.New
                    ];
                    List < ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, BOM_Product__c, BOM_Version__c, ERP7__Routing_Link__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name, ERP7__For_Multiples__c,
                        BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c, BOM_Version__r.Status__c, ERP7__Type__c, ERP7__Process_Cycle__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c
                        From ERP7__BOM__c
                        Where ERP7__Active__c = true And
                        ERP7__BOM_Product__c In: proIds And
                        ERP7__Type__c = 'Primary' And
                        BOM_Version__r.Active__c = true And
                        BOM_Version__r.Start_Date__c <= Today And
                        (BOM_Version__r.To_Date__c = Null Or BOM_Version__r.To_Date__c >= Today) And
                        RecordType.Name = 'Manufacturing BOM'
                        Order by BOM_Version__r.Default__c DESC
                    ];
                    for (ERP7__Manufacturing_Order__c moli: System.Trigger.New) {
                        if(!(Trigger.IsInsert && moli.ERP7__Escape_BOMS__c)){
                            if(moli.ERP7__Status__c == 'Cancelled') CancelledMOIds.add(moli.Id);
                            List < ERP7__MRP__c > myMRPS = new List < ERP7__MRP__c > ();
                            for (ERP7__MRP__c mrp: MRPS) {
                                if (moli.Id == mrp.ERP7__MO__c) myMRPS.add(mrp);
                            }
                            moliMrps.put(moli.Id, myMRPS);
                            List < ERP7__BOM__c > myBOMS = new List < ERP7__BOM__c > ();
                            List < ERP7__BOM__c > myAllBOMS = new List < ERP7__BOM__c > ();
                            for (ERP7__BOM__c bom: BOMS) {
                                if (moli.Product__c == bom.ERP7__BOM_Product__c && moli.Version__c != Null && moli.Version__c == bom.BOM_Version__c) {
                                    myBOMS.add(bom);
                                } else if (moli.Product__c == bom.ERP7__BOM_Product__c && moli.Version__c == Null && bom.BOM_Version__c != Null && bom.BOM_Version__r.Default__c == true) {
                                    myBOMS.add(bom);
                                }
                                if (moli.Product__c == bom.ERP7__BOM_Product__c && moli.Version__c == Null && bom.BOM_Version__c == Null) {
                                    myAllBOMS.add(bom);
                                }
                            }
                            if (myBOMS.size() > 0) moliBOMS.put(moli.Id, myBOMS);
                            else if (myAllBOMS.size() > 0) moliBOMS.put(moli.Id, myAllBOMS);
                        }
                    }
                    Id rTpe_MRPKIT; rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
                   
                    Id rTpe_MRPMAN; rTpe_MRPMAN = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Manufacturing').getRecordTypeId();

                    Map < Id, String > moliOldVersion = new Map < Id, String > ();
                    Map < Id, Decimal > moliOldQuantity = new Map < Id, Decimal > ();
                    Map < Id, Decimal > moliOldQuantityManu = new Map < Id, Decimal > ();
                    if (Trigger.IsUpdate) {
                        for (ERP7__Manufacturing_Order__c moli: System.Trigger.Old) {
                            moliOldQuantity.put(moli.Id, moli.Quantity__c);
                            if (moli.ERP7__Manufactured_Quantity__c >= 0) moliOldQuantityManu.put(moli.Id, moli.ERP7__Manufactured_Quantity__c);
                            else moliOldQuantityManu.put(moli.Id, 0);
                            if (moli.Version__c != Null) moliOldVersion.put(moli.Id, moli.Version__c);
                            //else moliOldVersion.put(moli.Id,'');
                        }
                    }
                    for (ERP7__Manufacturing_Order__c moli: System.Trigger.New) {
                        
                        if (((moliOldVersion.containsKey(moli.Id) && String.valueof(moli.Version__c) != moliOldVersion.get(moli.Id)) || moliOldQuantity.get(moli.Id) != moli.Quantity__c) && moliMrps.containsKey(moli.Id) && moliMrps.get(moli.Id).size() > 0) {
                            mrps2delete.addAll(moliMrps.get(moli.Id));
                            moliMrps.get(moli.Id).clear();
                        }
                        if (moliMrps.containsKey(moli.Id) && moliMrps.get(moli.Id).size() == 0 && moliBOMS.containsKey(moli.Id)) {
                            for (ERP7__BOM__c bom : moliBOMS.get(moli.Id)) {
                                ERP7__MRP__c MRP = new ERP7__MRP__c(Name = BOM.Name, ERP7__BOM__c = BOM.Id, ERP7__MRP_Product__c = BOM.ERP7__BOM_Component__c, ERP7__Version__c = BOM.ERP7__BOM_Version__c,ERP7__Routing_Link__c = BOM.ERP7__Routing_Link__c,ERP7__MO__c = moli.Id, ERP7__Process_Cycle__c=BOM.ERP7__Process_Cycle__c);
                                if(BOM.ERP7__Minimum_Variance__c != Null) MRP.ERP7__Minimum_Variance__c = BOM.ERP7__Minimum_Variance__c * moli.Quantity__c;
                                if(BOM.ERP7__Maximum_Variance__c != Null) MRP.ERP7__Maximum_Variance__c = BOM.ERP7__Maximum_Variance__c * moli.Quantity__c;
                                if (bom.RecordType.Name == 'Manufacturing BOM' && rTpe_MRPMAN != null) MRP.RecordTypeId = rTpe_MRPMAN;
                                else if (bom.RecordType.Name == 'Manufacturing BOM' && rTpe_MRPMAN != null) MRP.RecordTypeId = rTpe_MRPMAN;
                                if(bom.ERP7__For_Multiples__c > 0) MRP.ERP7__Total_Amount_Required__c = BOM.Quantity__c * (Math.ceil(moli.Quantity__c/bom.ERP7__For_Multiples__c));
                                else MRP.ERP7__Total_Amount_Required__c = BOM.Quantity__c * moli.Quantity__c;
                                MRPS2Insert.add(MRP);
                            }
                        }
                        
                    }
                    if (MRPS2Insert.size() > 0) upsert MRPS2Insert;
                    if (mrps2delete.size() > 0) {
                        List < Id > mrpIds = new List < Id > ();
                        for (MRP__c MRP: mrps2delete) {
                            mrpIds.add(MRP.Id);
                        }
                        List < Stock_Outward_Line_Item__c > SDLIs = [Select Id, Name, Active__c, Batch_Lot_Code__c, BoM__c, Process__c, Schedule__c, MRP_Material_Requirements_Planning__c,
                            Product__c, Purchase_Orders__c, Quantity__c,
                            Site_Product_Service_Inventory_Stock__c, Status__c, Tax__c, Total_Amount__c, Unit_Price__c
                            From Stock_Outward_Line_Item__c
                            Where MRP_Material_Requirements_Planning__c In: mrpIds
                        ];
                        if (SDLIs.size() > 0) delete SDLIs;
                        delete mrps2delete;
                    }
                   
                    if(CancelledMOIds.size() > 0){
                        List < Stock_Outward_Line_Item__c > RejectSDLIs = [Select Id, Name, Status__c
                            From Stock_Outward_Line_Item__c
                            Where ERP7__Manufacturing_Order__c In: CancelledMOIds And Status__c != 'Rejected'
                        ];
                        for(Stock_Outward_Line_Item__c RejectSDLI :RejectSDLIs){
                            RejectSDLI.ERP7__Status__c = 'Rejected';
                        }
                        if (RejectSDLIs.size() > 0) update RejectSDLIs;
                    }
                }
                
                    // End ==> Create and manage MRPS based on BOM and its versions ...
                */
                
            }
            
            if (Trigger.IsBefore) {
                if (Trigger.IsDelete) {
                    List < Stock_Outward_Line_Item__c > SDLIs = [Select Id From Stock_Outward_Line_Item__c Where ERP7__Manufacturing_Order__c In: System.Trigger.Old];
                    if (SDLIs.size() > 0&& Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete SDLIs; else{ }
                }
            }
            
            // Custom Roll up Start
            list<RollUpSummaryUtility.fieldDefinition> WOfieldDefinitionsLC = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity__c', 'ERP7__MO_Quantity__c')
            };
            if (Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsUndelete)) {
                RollUpSummaryUtility.rollUpTrigger(WOfieldDefinitionsLC, System.Trigger.New, 'ERP7__Manufacturing_Order__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', ' And ERP7__Sales_Order_Line_Item__r.ERP7__Issue_Manufacturing_Order__c = true ');
            } else if (Trigger.IsAfter) {
                if (Trigger.IsDelete) {
                    RollUpSummaryUtility.rollUpTrigger(WOfieldDefinitionsLC, System.Trigger.Old, 'ERP7__Manufacturing_Order__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', ' And ERP7__Sales_Order_Line_Item__r.ERP7__Issue_Manufacturing_Order__c = true ');
                }
            }
            // Custom Roll up End
             
        }
    } catch(Exception e){}
}