/* Changed made on 06/11/2023 by shaguftha
 * Reason : Restrict the creation of inventory records until the WIP is completed
 * changes : line 51 & 52 and added 38 to 46
 * 
*/
/* changes made on 10/06/24 by shaguftha
 * Added QA process in the WIP flows
 * 
*/
trigger WIPFlows on WIP_Flow__c (after insert, after update, after delete, after undelete,before delete) {
    system.debug('WIP flow trigger called');
    set<Id> prodIds = new set<Id>();
    set<Id> siteIds = new set<Id>();
    if(PreventRecursiveLedgerEntry.WIPFlowTrigger){
        PreventRecursiveLedgerEntry.WIPFlowTrigger = false;
    if (Trigger.isBefore && Trigger.isDelete) {
        // Collect WIP IDs from WIP Flow records
        Set<Id> wipIds = new Set<Id>();
        for (ERP7__WIP_Flow__c wipf : Trigger.old) {
            if (wipf.ERP7__WIP__c != null) {
                wipIds.add(wipf.ERP7__WIP__c);
            }
        }
        
        // Proceed only if there are WIP records to check
        if (!wipIds.isEmpty()) {
            // Query WIP records to get associated Manufacturing Orders
            Map<Id, ERP7__WIP__c> wipMap = new Map<Id, ERP7__WIP__c>([
                SELECT Id, ERP7__MO__c 
                FROM ERP7__WIP__c 
                WHERE Id IN :wipIds 
                AND ERP7__MO__c != null
            ]);
            
            // Collect MO IDs from WIP records
            Set<Id> moIds = new Set<Id>();
            for (ERP7__WIP__c wip : wipMap.values()) {
                moIds.add(wip.ERP7__MO__c);
            }
            
            // Query Manufacturing Orders with specified statuses
            if (!moIds.isEmpty()) {
                Map<Id, ERP7__Manufacturing_Order__c> moMap = new Map<Id, ERP7__Manufacturing_Order__c>([
                    SELECT Id, Status__c 
                    FROM ERP7__Manufacturing_Order__c 
                    WHERE Id IN :moIds 
                    AND Status__c IN ('Draft', 'In Progress', 'Complete')
                ]);
                
                // Check each WIP Flow record for deletion conditions
                for (ERP7__WIP_Flow__c wipf : Trigger.old) {
                    if (wipf.ERP7__WIP__c != null && wipMap.containsKey(wipf.ERP7__WIP__c)) {
                        ERP7__WIP__c relatedWip = wipMap.get(wipf.ERP7__WIP__c);
                    /*    if (relatedWip.ERP7__MO__c != null && moMap.containsKey(relatedWip.ERP7__MO__c)) {
                             String userLang = UserInfo.getLocale();
                            wipf.addError('Cannot delete WIP Flow record when MO is Already Scheduled.');
                        }*/
                        if (relatedWip.ERP7__MO__c != null && moMap.containsKey(relatedWip.ERP7__MO__c)) {
    String userLang = UserInfo.getLocale(); // or UserInfo.getLanguage()
    
    String errorMsg;
    if (userLang != null && userLang.startsWith('fr')) {
        errorMsg = 'Impossible de supprimer l’enregistrement WIP Flow lorsque l’OF est déjà planifié.';
    } else {
        errorMsg = 'Cannot delete WIP Flow record when MO is already scheduled.';
    }
    
    wipf.addError(errorMsg);
}

                    }
                }
            }
        }
    }

        if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            system.debug('Trigger.isUpdate : '+Trigger.isUpdate);
            Set<Id> WIPFlowIds = new Set<Id>();
            for (Integer i=0; i<System.Trigger.New.size(); i++) {
                 WIPFlowIds.add(System.Trigger.New[i].Id);
                //if (Trigger.isUpdate && System.Trigger.New[i].ERP7__Product__c != Null && ((System.Trigger.New[i].ERP7__Quantity__c > 0 && System.Trigger.New[i].ERP7__Quantity__c != System.Trigger.Old[i].ERP7__Quantity__c)  || (System.Trigger.New[i].ERP7__Quantity_Scrapped__c > 0 && System.Trigger.New[i].ERP7__Quantity_Scrapped__c != System.Trigger.Old[i].ERP7__Quantity_Scrapped__c))) WIPFlowIds.add(System.Trigger.New[i].Id);
                //if(flow.ERP7__Type__c == 'Produced' || flow.ERP7__Type__c == 'Processed') 
                prodIds.add(System.Trigger.New[i].ERP7__Product__c);
                siteIds.add(System.Trigger.New[i].ERP7__Finished_Products_Site__c);
            }
            system.debug('WIPFlowIds : '+WIPFlowIds.size());
            if(!System.isFuture() && !System.isBatch() && WIPFlowIds.size() > 0 && PreventRecursiveLedgerEntry.AwaitingStockMO) {
                PreventRecursiveLedgerEntry.AwaitingStockMO = false;
                MaintainBatchStocks.MaintainAwaitingStocksMO(WIPFlowIds); 
            } 
        } 
        
        if(Trigger.IsAfter && Trigger.IsUpdate){ 
            Set<Id> WFIDs = new Set<Id>();
            Map<Id, ERP7__WIP_Flow__c> WIPFlows = new Map<Id, ERP7__WIP_Flow__c>();
            List<ERP7__Inventory_Stock__c> Stocks = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Stock_Inward_Line_Item__c> SPLIs = new List<ERP7__Stock_Inward_Line_Item__c>();
            List<ERP7__Serial_Number__c> Serials = new List<ERP7__Serial_Number__c>();
            List<ERP7__Batch__c> Batches = new List<ERP7__Batch__c>();
            Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c> StockInwardMap = new Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c>();
            Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Serial_Number__c > SerialInwardMap = new Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Serial_Number__c >();
            Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Batch__c > BatchInwardMap = new Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Batch__c >();
            Map<ERP7__Inventory_Stock__c, ERP7__Batch__c > BatchInventoryMap = new Map<ERP7__Inventory_Stock__c, ERP7__Batch__c >();
            Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> WFInwardMap = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
            Boolean restrictInventoryCreation = false;
            Boolean QAisEnaled = false;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ 
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
            }
            if(FC != null){
                restrictInventoryCreation = FC.ERP7__AllowCreationOfInvnetoryOnlyWhenComplete__c;
                QAisEnaled = FC.ERP7__Enable_QA_in_Manufacturing_process__c;
            }
            for (Integer i=0; i<System.Trigger.New.size(); i++) {
                
                if (!restrictInventoryCreation && System.Trigger.New[i].ERP7__Product__c != Null && ((System.Trigger.New[i].ERP7__Quantity__c > 0 && System.Trigger.New[i].ERP7__Quantity__c != System.Trigger.Old[i].ERP7__Quantity__c)  || (System.Trigger.New[i].ERP7__Quantity_Scrapped__c > 0 && System.Trigger.New[i].ERP7__Quantity_Scrapped__c != System.Trigger.Old[i].ERP7__Quantity_Scrapped__c))){ //System.Trigger.New[i].ERP7__Status__c != System.Trigger.Old[i].ERP7__Status__c && System.Trigger.New[i].ERP7__Status__c == 'Completed'  removed for partial creation of inventory before creating the inventory 
                    // removed by shaguftha on 04/08/2023  && (System.Trigger.New[i].ERP7__Type__c == 'Produced' || System.Trigger.New[i].ERP7__Type__c == 'Scrapped' || System.Trigger.New[i].ERP7__Type__c == 'Processed')
                    WFIDs.add(System.Trigger.New[i].Id);
                }
                else if(restrictInventoryCreation && System.Trigger.New[i].ERP7__Status__c == 'Completed' && (System.Trigger.New[i].ERP7__Quantity__c > 0 || System.Trigger.New[i].ERP7__Quantity_Scrapped__c > 0))  WFIDs.add(System.Trigger.New[i].Id);
               
            }
            //('WFIDs size: '+WFIDs.size()+' WFIDS :'+WFIDs);
            if (WFIDs.size() > 0){
                String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP_Flow__c');
                String wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ', ERP7__Version__r.ERP7__Product__c,ERP7__Product__r.ERP7__Quality_Check_QA__c, ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c,ERP7__Product__r.Serialise__c, ERP7__Product__r.Lot_Tracked__c, ERP7__Work_Orders__r.ERP7__Product__c, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c, ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c, ERP7__WIP__r.ERP7__Material_Batch_Lot__c, ERP7__WIP__r.ERP7__Serial_Number__c  from ERP7__WIP_Flow__c where Id = :WFIDs And ERP7__Work_Orders__r.ERP7__MO__c != Null FOR UPDATE';
                List<ERP7__WIP_Flow__c> WIPFlowss = Database.query(wpquery);
                //update WIPFlowss;
                for (ERP7__WIP_Flow__c WF: WIPFlowss) {
                    WIPFlows.put(WF.Id, WF);
                    WFInwardMap.put(WF.Id, new List<ERP7__Stock_Inward_Line_Item__c>());
                }
                WIPFlowss = new List<ERP7__WIP_Flow__c>();
                List<ERP7__Stock_Inward_Line_Item__c> ExistingSILIS = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__WIP_Flow__c, ERP7__Quantity__c,ERP7__Scrap__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Active__c = true And ERP7__WIP_Flow__c != Null And ERP7__WIP_Flow__c In :WFIDs And ERP7__Quantity__c > 0 AND ERP7__Status__c != 'Awaiting Stock' FOR UPDATE];
                for(ERP7__Stock_Inward_Line_Item__c ExistingSILI : ExistingSILIS){
                    List<ERP7__Stock_Inward_Line_Item__c> mySILIS = WFInwardMap.get(ExistingSILI.ERP7__WIP_Flow__c);
                    mySILIS.add(ExistingSILI);
                    WFInwardMap.put(ExistingSILI.ERP7__WIP_Flow__c, mySILIS);
                }
                ExistingSILIS = new List<ERP7__Stock_Inward_Line_Item__c>();
                Map<Id,ERP7__Inventory_Stock__c> existingInvMap = new Map<Id,ERP7__Inventory_Stock__c>();
                //added on 10/2/2023 to avoid duplicate inventory creation for normal products and line 94 & 95
                List<ERP7__Inventory_Stock__c> Existingstock = [Select Id,Name,ERP7__Product__c,ERP7__Batch_Lot__c from ERP7__Inventory_Stock__c where ERP7__Product__c IN: prodIds and ERP7__Warehouse__c In: siteIds and ERP7__Serial__c = null AND Name != 'Awaiting Stock' limit 1000];
                if(Existingstock.size() > 0){
                    for(ERP7__Inventory_Stock__c inv:Existingstock){
                        if(!existingInvMap.containsKey(inv.ERP7__Product__c)) existingInvMap.put(inv.ERP7__Product__c,inv);
                        //if(inv.ERP7__Batch_Lot__c != null && !existingInvMap.containsKey(inv.ERP7__Batch_Lot__c)) existingInvMap.put(inv.ERP7__Batch_Lot__c,inv);
                    }
                    Existingstock = new  List<ERP7__Inventory_Stock__c>();
                }
                //('WFInwardMap : '+WFInwardMap.size());
                for (Integer i=0; i<System.Trigger.New.size(); i++) {
                    if(WIPFlows.containsKey(System.Trigger.New[i].Id)) {
                        //('true : '+System.Trigger.New[i].Id);
                        ERP7__WIP_Flow__c WF = WIPFlows.get(System.Trigger.New[i].Id);
                        Decimal curQuantity = 0;
                        Decimal scrapQuantity = 0;
                        for(ERP7__Stock_Inward_Line_Item__c SILI : WFInwardMap.get(WF.Id)){
                            if(SILI.ERP7__Scrap__c)  scrapQuantity += SILI.ERP7__Quantity__c;
                            else curQuantity += SILI.ERP7__Quantity__c;
                        }
                        system.debug('curQuantity : '+curQuantity);
                        system.debug('scrapQuantity : '+scrapQuantity);
                        system.debug('WF.ERP7__Quantity__c : '+WF.ERP7__Quantity__c);
                        if((WF.ERP7__Quantity__c + WF.ERP7__Quantity_Scrapped__c) - (curQuantity + scrapQuantity) > 0){
                            system.debug('curQuantity condition true ');
                            ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c();  
                            //if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable() && WF.ERP7__WIP__r.ERP7__Material_Batch_Lot__c != Null){Stock.ERP7__Batch_Lot__c = WF.ERP7__WIP__r.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c;}else{/*No access*/}   
                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = WF.ERP7__Work_Orders__c;}else{/*No access*/}  
                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__WIP_Flow__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__WIP_Flow__c.isUpdateable()){Stock.ERP7__WIP_Flow__c = WF.Id;}else{/*No access*/}  
                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}  
                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=WF.Name;}else{/*No access*/}  
                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}    
                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=WF.ERP7__Finished_Products_Site__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}
                            if(WF.ERP7__Product__c == WF.ERP7__Work_Orders__r.ERP7__Product__c){
                                //('WF and WO product condition true ');
                                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){Stock.ERP7__Product__c = WF.ERP7__Product__c;}else{/*No access*/}
                                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = WF.ERP7__Version__c;}else{/*No access*/}
                            }
                            else{
                                //('WF and WO product condition false ');
                                if(WF.ERP7__Product__c != WF.ERP7__Work_Orders__r.ERP7__Product__c && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){ Stock.ERP7__Product__c = WF.ERP7__Product__c;}else{/*No access*/}
                                if(WF.ERP7__Version__r.ERP7__Product__c == Stock.ERP7__Product__c && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){ Stock.ERP7__Version__c = WF.ERP7__Version__c;}else{/*No access*/}
                            }
                            // WF.ERP7__Type__c == 'Scrapped' 
                            if((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0 && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){ Stock.ERP7__Scrap__c = true;}else{/*No access*/}
                           
                            if (WF.ERP7__Expiry_Date__c != null && WF.ERP7__Expiry_Date__c > System.today() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Expiry_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Expiry_Date__c.isUpdateable()) {                   
                                Stock.ERP7__Expiry_Date__c = WF.ERP7__Expiry_Date__c;
                                system.debug('Setting ERP7__Expiry_Date__c for new Stock: ' + Stock.ERP7__Expiry_Date__c);
                            }
                            if(!WF.ERP7__Product__r.Serialise__c && !WF.ERP7__Product__r.Lot_Tracked__c){
                                system.debug('existingInvMap : '+existingInvMap.size());
                                if(existingInvMap.size() > 0 && existingInvMap.containsKey(WF.ERP7__Product__c)){
                                     Stock = existingInvMap.get(WF.ERP7__Product__c);
                                     if (WF.ERP7__Expiry_Date__c != null && WF.ERP7__Expiry_Date__c > System.today() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Expiry_Date__c.isUpdateable()) {
                                        Stock.ERP7__Expiry_Date__c = WF.ERP7__Expiry_Date__c;
                                        system.debug('Setting ERP7__Expiry_Date__c for existing Stock: ' + Stock.ERP7__Expiry_Date__c);
                                    }
                                }
                                //('Normal product condition true ');
                                ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();    
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c;}else{/*No access*/}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = WF.ERP7__Work_Orders__c;}else{/*No access*/}   
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isUpdateable()){SPLI.ERP7__WIP_Flow__c = WF.Id;}else{/*No access*/}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = WF.Name;}else{/*No access*/}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = WF.ERP7__Product__c;}else{/*No access*/}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){
                                    SPLI.ERP7__Quantity__c = ((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0) ? (WF.ERP7__Quantity_Scrapped__c - scrapQuantity) : (WF.ERP7__Quantity__c-curQuantity);
                                        }else{/*No access*/} 
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c = WF.ERP7__Version__c;}else{/*No access*/}
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()){ SPLI.ERP7__Sales_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c;}else{/*No access*/}
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable()){ SPLI.ERP7__Sales_Order_Line_Item__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c;}else{/*No access*/}
                                if((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){ SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                if(QAisEnaled &&  (WF.ERP7__Product__r.ERP7__Quality_Check_QA__c || WF.ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c)){
                                    SPLI.ERP7__Status__c = 'Quality Check(QA)';
                                }//added by shaguftha for QA change
                                StockInwardMap.put(SPLI,Stock);
                                system.debug('SPLI 5 Qty : '+SPLI.ERP7__Quantity__c);
                                SPLIs.add(SPLI);
                            }
                            else if(WF.ERP7__Product__r.Serialise__c && WF.ERP7__Product__c != WF.ERP7__Work_Orders__r.ERP7__Product__c){
                                //('Serial product condition true ');
                                integer j = 1;
                                while(j <= Integer.valueof(WF.ERP7__Quantity__c-curQuantity)){
                                    //('while condition');
                                    ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c;}else{/*No access*/}    
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = WF.ERP7__Work_Orders__c;}else{/*No access*/}   
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isUpdateable()){SPLI.ERP7__WIP_Flow__c = WF.Id;}else{/*No access*/}  
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = WF.Name+String.valueof(j);}else{/*No access*/}   
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = WF.ERP7__Product__c;}else{/*No access*/}   
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){
                                        SPLI.ERP7__Quantity__c = 1;
                                    }else{/*No access*/} 
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c = WF.ERP7__Version__c;}else{/*No access*/}
                                    
                                    if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()){ SPLI.ERP7__Sales_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c;}else{/*No access*/}
                                    if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable()){ SPLI.ERP7__Sales_Order_Line_Item__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c;}else{/*No access*/}
                                    if((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){ SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                    if(QAisEnaled &&  (WF.ERP7__Product__r.ERP7__Quality_Check_QA__c|| WF.ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c)){
                                        SPLI.ERP7__Status__c = 'Quality Check(QA)';
                                    }//added by shaguftha for QA change
                                    StockInwardMap.put(SPLI,Stock);
                                    system.debug('SPLI 4 : '+SPLI.ERP7__Quantity__c);
                                    SPLIs.add(SPLI);
                                    ERP7__Serial_Number__c Serial = new ERP7__Serial_Number__c();
                                   // if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Available__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Available__c.isUpdateable()){Serial.ERP7__Available__c = (WF.ERP7__Type__c == 'Scrapped') ? false : true; }else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isUpdateable()){Serial.ERP7__Product__c = WF.ERP7__Product__c; }else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable()){Serial.ERP7__Warehouse__c=WF.ERP7__Finished_Products_Site__c; }else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isUpdateable()){Serial.ERP7__Production_Version__c = WF.ERP7__Version__c; }else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Serial.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c; }else{/*No access*/}
                                    Serial.ERP7__Date_of_Manufacture__c = System.today();
                                  //  Serial.ERP7__Scrap__c = ((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0) ? true : false;
                                    /*if(SPLI.ERP7__Status__c == 'Quality Check(QA)'){
                                        Serial.ERP7__Status__c = ((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0) ? 'Scrap' : 'Available';
                                    }*/
                                    SerialInwardMap.put(SPLI,Serial);
                                    Serials.add(Serial);
                                    j++;
                                }
                            }
                          /* 14_09_23 SM else if(WF.ERP7__Product__r.Serialise__c && WF.ERP7__Product__c == WF.ERP7__Work_Orders__r.ERP7__Product__c){
                                //('Serial product 2nd condition else if true ');
                                ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();   
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c; }else{}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = WF.ERP7__Work_Orders__c; }else{}    
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isUpdateable()){SPLI.ERP7__WIP_Flow__c = WF.Id; }else{} 
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = WF.Name; }else{}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = WF.ERP7__Product__c; }else{}   
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true; }else{}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = 1; }else{}   
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0; }else{}   
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c = WF.ERP7__Version__c; }else{}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SPLI.ERP7__Serial__c = WF.ERP7__WIP__r.ERP7__Serial_Number__c; Serials.add(new ERP7__Serial_Number__c(Id=WF.ERP7__WIP__r.ERP7__Serial_Number__c,ERP7__Date_of_Manufacture__c=System.today(),ERP7__Available__c = ((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0)  ? false : true,ERP7__Scrap__c = ((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0) ? true : false)); }else{}
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()){ SPLI.ERP7__Sales_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c; }else{}
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable()){ SPLI.ERP7__Sales_Order_Line_Item__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c; }else{}
                                if((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()) {SPLI.ERP7__Scrap__c = true; }else{}
                                StockInwardMap.put(SPLI,Stock);
                                system.debug('SPLI 3 : '+SPLI.ERP7__Quantity__c);
                                SPLIs.add(SPLI);
                                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isUpdateable()){Stock.ERP7__Serial__c = WF.ERP7__WIP__r.ERP7__Serial_Number__c;}else{} // added by shaguftha
                            }*/
                            else if(WF.ERP7__Product__r.Lot_Tracked__c && WF.ERP7__Product__c != WF.ERP7__Work_Orders__r.ERP7__Product__c){
                                //('Batch product condition else if product not equals ');
                                ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = WF.ERP7__Work_Orders__c;}else{/*No access*/}              
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isUpdateable()){SPLI.ERP7__WIP_Flow__c = WF.Id;}else{/*No access*/}    
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = WF.Name;}else{/*No access*/}     
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = WF.ERP7__Product__c;}else{/*No access*/}           
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){
                                    SPLI.ERP7__Quantity__c = ((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0) ? (WF.ERP7__Quantity_Scrapped__c - scrapQuantity) : (WF.ERP7__Quantity__c-curQuantity);
                                        }else{/*No access*/}           
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}
                                
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()){ SPLI.ERP7__Sales_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c;}else{/*No access*/}
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable()){ SPLI.ERP7__Sales_Order_Line_Item__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c;}else{/*No access*/}
                                if((WF.ERP7__Quantity_Scrapped__c - scrapQuantity)  > 0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){ SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                if(QAisEnaled &&  (WF.ERP7__Product__r.ERP7__Quality_Check_QA__c || WF.ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c)){
                                    SPLI.ERP7__Status__c = 'Quality Check(QA)';
                                }//added by shaguftha for QA change
                                StockInwardMap.put(SPLI,Stock);
                                system.debug('SPLI 2 : '+SPLI.ERP7__Quantity__c);
                                SPLIs.add(SPLI);
                                ERP7__Batch__c Batch = new ERP7__Batch__c(); if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Active__c.isUpdateable()){Batch.ERP7__Active__c = true; }else{/*No access*/}  if(WF.ERP7__Product__c != null && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Product__c.isUpdateable()){ Batch.ERP7__Product__c = WF.ERP7__Product__c; }else{/*No access*/}   if(WF.ERP7__Version__r.ERP7__Product__c == Stock.ERP7__Product__c && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Production_Version__c.isUpdateable()){ Batch.ERP7__Production_Version__c = WF.ERP7__Version__c; }else{/*No access*/}  if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Batch.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c;}else{/*No access*/}  
                                if(!((WF.ERP7__Quantity_Scrapped__c - scrapQuantity) > 0) && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Inward_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Inward_Quantity__c.isUpdateable()){ Batch.ERP7__Inward_Quantity__c = WF.ERP7__Quantity__c-curQuantity;}else{/*No access*/}
                                // if(WF.ERP7__Expiry_Date__c != null && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Expiry_Date__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Expiry_Date__c.isUpdateable()){
                                //     Batch.ERP7__Expiry_Date__c = WF.ERP7__Expiry_Date__c;
                                //     system.debug('Setting ERP7__Expiry_Date__c for Batch: ' + Batch.ERP7__Expiry_Date__c);
                                // }
                                system.debug('Batch : '+Batch);
                                BatchInwardMap.put(SPLI,Batch);
                                BatchInventoryMap.put(Stock,Batch);
                                Batches.add(Batch);
                            }//the below condition added to avoid running the code if the end product is serial-batch. Condition: '!WF.ERP7__Product__r.Serialise__c'
                            else if(!WF.ERP7__Product__r.Serialise__c && WF.ERP7__Product__r.Lot_Tracked__c && WF.ERP7__Product__c == WF.ERP7__Work_Orders__r.ERP7__Product__c){
                                //('Batch product condition else if product equals ');
                                ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__c;}else{/*No access*/}    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = WF.ERP7__Work_Orders__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__WIP_Flow__c.isUpdateable()){SPLI.ERP7__WIP_Flow__c = WF.Id;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = WF.Name;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = WF.ERP7__Product__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){
                                    SPLI.ERP7__Quantity__c = ((WF.ERP7__Quantity_Scrapped__c - scrapQuantity) > 0) ? (WF.ERP7__Quantity_Scrapped__c - scrapQuantity) : (WF.ERP7__Quantity__c-curQuantity);
                                        }else{/*No access*/}   
                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SPLI.ERP7__Material_Batch_Lot__c = WF.ERP7__WIP__r.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                                
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order__c.isUpdateable()){ SPLI.ERP7__Sales_Order__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order__c;}else{/*No access*/}
                                if(WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c != null && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable()){ SPLI.ERP7__Sales_Order_Line_Item__c = WF.ERP7__Work_Orders__r.ERP7__MO__r.ERP7__Sales_Order_Line_Item__c;}else{/*No access*/}
                                if((WF.ERP7__Quantity_Scrapped__c - scrapQuantity) > 0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){ SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                if(QAisEnaled &&  (WF.ERP7__Product__r.ERP7__Quality_Check_QA__c || WF.ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c)){
                                    SPLI.ERP7__Status__c = 'Quality Check(QA)';
                                }//added by shaguftha for QA change
                                StockInwardMap.put(SPLI,Stock);
                                system.debug('SPLI 1 : '+SPLI.ERP7__Quantity__c);
                                SPLIs.add(SPLI);
                                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()){Stock.ERP7__Batch_Lot__c = WF.ERP7__WIP__r.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                            }
                            if(Stock.ERP7__Product__c != null && !(WF.ERP7__Product__r.Serialise__c && WF.ERP7__Product__c == WF.ERP7__Work_Orders__r.ERP7__Product__c)) Stocks.add(Stock);
                        }
                    }
                }
                
                system.debug('Serials : '+Serials.size());
                if (Batches.size() > 0 && Schema.sObjectType.ERP7__Batch__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.isUpdateable()) { upsert Batches; } else{ /*(' no access batch');*/  }
                
                if(Batches.size() > 0){
                    for(ERP7__Inventory_Stock__c batchStk : Stocks){
                        String BatchId = '';
                        if(BatchInventoryMap.containsKey(batchStk)) BatchId = BatchInventoryMap.get(batchStk).Id;
                        system.debug('BatchId : '+BatchId);
                        if(BatchId != null && BatchId != '') batchStk.ERP7__Batch_Lot__c = BatchId;
                    }
                }
                if (Stocks.size() > 0 && Schema.sObjectType.ERP7__Inventory_Stock__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.isUpdateable()){  upsert Stocks; } else{ /*(' no access stock');*/ }
                if (Serials.size() > 0 && Schema.sObjectType.ERP7__Serial_Number__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.isUpdateable()){  upsert Serials; } else{ /*('No access serialk');*/ }
                //('StockInwardMap : '+StockInwardMap.size());
                for(ERP7__Stock_Inward_Line_Item__c inward : StockInwardMap.KeySet()){
                    String StockId = '', SerialId = '', BatchId = ''; 
                    StockId = StockInwardMap.get(inward).Id;
                    system.debug('inward 6 bfr : '+inward.ERP7__Quantity__c);
                    //('StockId : '+StockId);
                    if(SerialInwardMap.containsKey(inward)) SerialId = SerialInwardMap.get(inward).Id;
                    if(BatchInwardMap.containsKey(inward)) BatchId = BatchInwardMap.get(inward).Id;
                    inward.ERP7__Site_ProductService_InventoryStock__c = StockId;
                    if(SerialId != '' && inward.ERP7__Serial__c == Null) inward.ERP7__Serial__c = SerialId;
                    if(BatchId != '' && inward.ERP7__Material_Batch_Lot__c == Null) inward.ERP7__Material_Batch_Lot__c = BatchId;
                    system.debug('inward 6 after : '+inward.ERP7__Serial__c);
                }
                PreventRecursiveLedgerEntry.OrderTriggerDuringMO=false;//new line of code by idris
                system.debug('SPLIs.size() : '+SPLIs.size());
                if (SPLIs.size() > 0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isUpdateable()){ upsert SPLIs; } else{ /*('No access stock inward');*/ }
                
         
                // added by SM
                if(Serials.size() > 0){
                    Id WF_MOId = Serials[0].ERP7__Manufacturing_Order__c;
                    List<ERP7__Inventory_Stock__c> fetchedserialStocks = [SELECT Id, ERP7__Product__c, ERP7__Serial__c 
                                                                          FROM ERP7__Inventory_Stock__c 
                                                                          WHERE ERP7__Manufacturing_Order__c =: WF_MOId AND
                                                                          ERP7__Product__r.ERP7__Serialise__c = true AND 
                                                                          ERP7__Manufacturing_Order__c != Null AND // added for fix - imran
                                                                          ERP7__Serial__c = Null // added for fix - imran
                                                                          FOR UPDATE];
                    Stocks = new List<ERP7__Inventory_Stock__c>();
                    /*
                    for(ERP7__Inventory_Stock__c serialStk : fetchedserialStocks){
                    for(ERP7__Serial_Number__c srl : Serials){
                    if(serialStk.ERP7__Serial__c == null && serialStk.ERP7__Product__c == srl.ERP7__Product__c){
                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isUpdateable()){serialStk.ERP7__Serial__c = srl.Id;}else{}
                    Stocks.add(serialStk);
                    }
                    }
                    }
                    */
                    // Imran - Above commented nested for loop is handled with below code with 2 for loops - this need to be tested
                    Map<Id, List<Id>> ProductSerials = new Map<Id, List<Id>>();
                    for(ERP7__Serial_Number__c srl : Serials){
                        List<Id> mySerials = new List<Id>();
                        if(ProductSerials.containsKey(srl.ERP7__Product__c)) mySerials = ProductSerials.get(srl.ERP7__Product__c);
                        mySerials.add(srl.Id);
                        ProductSerials.put(srl.ERP7__Product__c, mySerials);
                    }
                    for(ERP7__Inventory_Stock__c serialStk : fetchedserialStocks){
                        if(serialStk.ERP7__Product__c != Null && ProductSerials.containsKey(serialStk.ERP7__Product__c)){
                            List<Id> mySerials = ProductSerials.get(serialStk.ERP7__Product__c);
                            if(mySerials.size() > 0){
                                serialStk.ERP7__Serial__c = mySerials.remove(0);
                                ProductSerials.put(serialStk.ERP7__Product__c, mySerials);
                                Stocks.add(serialStk);
                            }
                        }
                    }
                    
                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.isUpdateable()){ update Stocks; } else{ /* no access */ }
                }
            }
        }
    }
}