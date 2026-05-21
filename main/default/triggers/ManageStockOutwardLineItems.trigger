/*
 * Changes made by - Syed Moin Pasha
 * Date - 26th july 2023
 * Reason - Was getting exception Delete failed. First exception on row 0 with id a3406000000uGOMAA2; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ERP7.ManageStockOutwardLineItems: execution of AfterDelete
 * Fix Applied : Added !Trigger.isDelete on line 11 and 50
 * 
*/
trigger ManageStockOutwardLineItems on Purchase_Line_Items__c(before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    system.debug('ManageStockOutwardLineItems POLI trigger called');
    
    if(trigger.isAfter && PreventRecursiveLedgerEntry.preventPOLIValidation && Schema.sObjectType.Product2.fields.ERP7__Purchase_From_Approved_Vendor__c.isAccessible() &&!Trigger.Isdelete){
        PreventRecursiveLedgerEntry.preventPOLIValidation = false;
        Set<Id> pIds = new Set<Id>();
        Set<Id> purIds = new Set<Id>();
        for(Purchase_Line_Items__c poli : Trigger.new){
            if(poli.ERP7__Product__c != null) pIds.add(poli.ERP7__Product__c);
        }
        if(pIds.size()>0){
            Map<Id, ERP7__Approved_Vendor__c> venAppMap = new Map<Id, ERP7__Approved_Vendor__c>();
            Map<Id, Product2> prodMap = new Map<Id, Product2>([select Id, Name, ERP7__Purchase_From_Approved_Vendor__c from Product2 where Id IN:pIds and ERP7__Purchase_From_Approved_Vendor__c = true]);
            system.debug('prodMap : '+prodMap);
            List<ERP7__Approved_Vendor__c> appList = new List<ERP7__Approved_Vendor__c>();
            appList = [select Id, ERP7__Product__c, ERP7__Vendor__c from ERP7__Approved_Vendor__c where ERP7__Product__c IN :pIds and ERP7__Product__r.ERP7__Purchase_From_Approved_Vendor__c = true];
            if(appList.size()>0){                for(ERP7__Approved_Vendor__c app : appList){                   venAppMap.put(app.ERP7__Vendor__c, app);                }
            }
            system.debug('venAppMap--'+venAppMap.size());
            Map<Id, Purchase_Line_Items__c> poliMap = new Map<Id, Purchase_Line_Items__c>([select Id, Name, ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.ERP7__Vendor__c from Purchase_Line_Items__c where Id IN :Trigger.newMap.keyset()]);
            system.debug('prodMap-->'+prodMap);
            if(prodMap.size() > 0){                for(Purchase_Line_Items__c poli : Trigger.new){                    system.debug('poli-->'+poli);                    system.debug('prodMap.containsKey(poli.ERP7__Product__c) : '+prodMap.containsKey(poli.ERP7__Product__c));                    if(prodMap.containsKey(poli.ERP7__Product__c)  && prodMap.get(poli.ERP7__Product__c).ERP7__Purchase_From_Approved_Vendor__c){                        if(poliMap.get(poli.Id).ERP7__Purchase_Orders__r.ERP7__Vendor__c == null){                            poli.addError('please select the vendor for the purchase order');                        }else if(!venAppMap.containskey(poliMap.get(poli.Id).ERP7__Purchase_Orders__r.ERP7__Vendor__c)){                            poli.addError('please select the approved vendor for the purchase order : '+poli.ERP7__Product__c);                        }                    }                }                            }     
        }
        
    }
     if((Trigger.IsAfter && Trigger.IsUpdate) ){
        set<Id> POIds = new set<Id>();set<Id> PurchaseOrderIds = new set<Id>();
        for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) {
            ERP7__Purchase_Line_Items__c oldPLI = System.Trigger.OldMap.get(pli.Id);
            if(pli.ERP7__Quantity__c != oldPLI.ERP7__Quantity__c || pli.ERP7__Unit_Price__c != oldPLI.ERP7__Unit_Price__c||pli.ERP7__Tax_Rate__c != oldPLI.ERP7__Tax_Rate__c){  
                POIds.add(pli.Id);
                if(pli.ERP7__Purchase_Orders__c!=null){PurchaseOrderIds.add(pli.ERP7__Purchase_Orders__c);}} 
        }
        system.debug('SyncPOLIQtyandPriceFuture POIds : '+POIds.size());
         if(POIds.size() > 0) { 
             //new code to validate the quantity of po line item to not be less than logistic quantity/putaway quantity.
           /*  Map<Id, Decimal> purchaseLineItemToPutawayQtyMap = new Map<Id, Decimal>();Map<Id, String> purchaseLineItemToNameMap = new Map<Id, String>();
             List<ERP7__Logistic_Line_Item__c> logLines = [
                 SELECT Id, Name, ERP7__Quantity__c, ERP7__Putaway_Quantity__c,
                 ERP7__Purchase_Line_Items__c, ERP7__Purchase_Line_Items__r.Name, ERP7__Product__c, ERP7__Product__r.Name
                 FROM ERP7__Logistic_Line_Item__c
                 WHERE ERP7__Purchase_Line_Items__c IN :Trigger.newMap.keySet()
             ];
             for (ERP7__Logistic_Line_Item__c logLine : logLines) {
                 if (logLine.ERP7__Purchase_Line_Items__c != null && logLine.ERP7__Putaway_Quantity__c != null) {Decimal currentQty = purchaseLineItemToPutawayQtyMap.get(logLine.ERP7__Purchase_Line_Items__c);
                     if (currentQty == null){ currentQty = 0;}purchaseLineItemToPutawayQtyMap.put(logLine.ERP7__Purchase_Line_Items__c,currentQty + logLine.ERP7__Putaway_Quantity__c);
                 }
                 purchaseLineItemToNameMap.put(logLine.ERP7__Purchase_Line_Items__c,logLine.ERP7__Product__r.Name);
             }
             
             for (ERP7__Purchase_Line_Items__c pli : Trigger.new) {
                 Decimal totalPutawayQty = purchaseLineItemToPutawayQtyMap.get(pli.Id);
                 if (totalPutawayQty != null && totalPutawayQty > pli.ERP7__Quantity__c) {System.debug('error countttt');String name=purchaseLineItemToNameMap.get(pli.Id)!=null?purchaseLineItemToNameMap.get(pli.Id):'';pli.ERP7__Quantity__c.addError('Purchase quantity (' + pli.ERP7__Quantity__c + ') on line item "' + name + '" cannot be less than total received quantity (' + totalPutawayQty + ').');
                     return;
                 }
             }*/
             //new code end
             //new code to update bill line items quantity on update of purchse line items quantity on Aug 4 2025
             Set<Id> updatedPLIIds = new Set<Id>();
             
             for (ERP7__Purchase_Line_Items__c newPLI : Trigger.new) {
                 ERP7__Purchase_Line_Items__c oldPLI = Trigger.oldMap.get(newPLI.Id);
                 if (
                     (newPLI.ERP7__Quantity__c != oldPLI.ERP7__Quantity__c )||
                     (newPLI.ERP7__Unit_Price__c != oldPLI.ERP7__Unit_Price__c )||
                     (newPLI.ERP7__Tax_Rate__c != oldPLI.ERP7__Tax_Rate__c)
                 ) {
                     updatedPLIIds.add(newPLI.Id);
                 }
             }
             
             if (!updatedPLIIds.isEmpty()) {Boolean noError=true;
                 List<ERP7__Dimension__c> dimsToUpdate = new List<ERP7__Dimension__c>();                           
                 List<ERP7__Dimension__c> relatedDims = [
        				SELECT Id, ERP7__Purchase_Line_Items__c, ERP7__Allocation_Percentage__c, ERP7__Allocation_Amount__c
        				FROM ERP7__Dimension__c
        				WHERE ERP7__Purchase_Line_Items__c IN :updatedPLIIds
    					];                          
                                            
                 List<ERP7__Bill_Line_Item__c> billLineItemsToUpdate = [
                     SELECT Id, ERP7__Purchase_Order_Line_Items__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Bill__c, ERP7__Bill__r.ERP7__Matched__c,
                     ERP7__Amount__c, ERP7__Total_Amount__c, ERP7__Remaining_Match_Quantity__c, ERP7__Tax_Amount__c, ERP7__Tax_Rate__c, ERP7__Posted__c
                     FROM ERP7__Bill_Line_Item__c
                     WHERE ERP7__Purchase_Order_Line_Items__c IN :updatedPLIIds
                 ];
                 List<ERP7__Bill_Line_Item__c> billsToUpdate=new List<ERP7__Bill_Line_Item__c>();                           
                 Map<Id, ERP7__Purchase_Line_Items__c> updatedPLIMap = new Map<Id, ERP7__Purchase_Line_Items__c>();
                 for (ERP7__Purchase_Line_Items__c pli : Trigger.new) {if (updatedPLIIds.contains(pli.Id)) {updatedPLIMap.put(pli.Id, pli);}}  
                 //to update the dimensions. updated on 16 sep 2025
                 for (ERP7__Dimension__c dim : relatedDims) {
        			ERP7__Purchase_Line_Items__c relatedPLI = updatedPLIMap.get(dim.ERP7__Purchase_Line_Items__c);
        			if (relatedPLI != null) {
            			Decimal unitPrice = relatedPLI.ERP7__Unit_Price__c != null ? relatedPLI.ERP7__Unit_Price__c : 0;
            			Decimal quantity  = relatedPLI.ERP7__Quantity__c != null ? relatedPLI.ERP7__Quantity__c : 0;
            			Decimal baseAmount = unitPrice * quantity; // Excluding tax
            			Decimal allocationPercentage = dim.ERP7__Allocation_Percentage__c != null ? dim.ERP7__Allocation_Percentage__c : 0;
                        Decimal calculatedAmount = (baseAmount * allocationPercentage) / 100;
                        System.debug('allocationPercentage '+allocationPercentage);
                        System.debug('calculatedAmount '+calculatedAmount);
                        if (dim.ERP7__Allocation_Amount__c == null || dim.ERP7__Allocation_Amount__c != calculatedAmount) {System.debug('dim.ERP7__Allocation_Amount__c before '+dim.ERP7__Allocation_Amount__c);
                            dim.ERP7__Allocation_Amount__c = calculatedAmount;System.debug('dim.ERP7__Allocation_Amount__c After '+dim.ERP7__Allocation_Amount__c);
                            dimsToUpdate.add(dim);
                        }
        			}
    			}if (!dimsToUpdate.isEmpty()) {update dimsToUpdate;}
                 //dimension update end
               /*  for (ERP7__Bill_Line_Item__c bli : billLineItemsToUpdate) {
                     
                     ERP7__Purchase_Line_Items__c relatedPLI = updatedPLIMap.get(bli.ERP7__Purchase_Order_Line_Items__c);
                     if (relatedPLI != null) {
                         Decimal unitPrice = relatedPLI.ERP7__Unit_Price__c != null ? relatedPLI.ERP7__Unit_Price__c : 0;Decimal quantity  = relatedPLI.ERP7__Quantity__c != null ? relatedPLI.ERP7__Quantity__c : 0;Decimal taxRate   = relatedPLI.ERP7__Tax_Rate__c != null ? relatedPLI.ERP7__Tax_Rate__c : 0;
                         Decimal baseAmount = unitPrice * quantity;Decimal taxAmount = (taxRate > 0) ? (baseAmount * taxRate / 100) : 0;
                         bli.ERP7__Quantity__c = quantity;bli.ERP7__Tax_Rate__c = taxRate;bli.ERP7__Tax_Amount__c = taxAmount;bli.ERP7__Amount__c = unitPrice;bli.ERP7__Total_Amount__c = baseAmount + taxAmount;
                         billsToUpdate.add(bli);
                     }System.debug('process not stopped after the error??');
                 }
                 if (!billsToUpdate.isEmpty()) {PreventRecursiveLedgerEntry.billTriggersFromPO=false; update billsToUpdate;}*/
             }
             //new code end to update related bill line items
             PreventRecursiveLedgerEntry.AwaitingStockPO = false;             MaintainBatchStocks.SyncPOLIQtyandPriceFuture(POIds); if(PurchaseOrderIds.size()>0){PreventRecursiveLedgerEntry.polisUpdateFromAwaitingStocksPO=false; MaintainBatchStocks.MaintainAwaitingStocksPO(PurchaseOrderIds);}        }
         
    }
    //new codebelow to update the price when quantity, unit price or tax is updated
    if(Trigger.IsBefore && Trigger.IsUpdate){
        set<Id> POIds = new set<Id>();
        //for logistic scenarios
        Map<Id, Decimal> purchaseLineItemToPutawayQtyMap = new Map<Id, Decimal>();Map<Id, String> purchaseLineItemToNameMap = new Map<Id, String>();
        List<ERP7__Logistic_Line_Item__c> logLines = [
            SELECT Id, Name, ERP7__Quantity__c, ERP7__Putaway_Quantity__c,
            ERP7__Purchase_Line_Items__c, ERP7__Purchase_Line_Items__r.Name, ERP7__Product__c, ERP7__Product__r.Name
            FROM ERP7__Logistic_Line_Item__c
            WHERE ERP7__Purchase_Line_Items__c IN :Trigger.newMap.keySet()
        ];
        for (ERP7__Logistic_Line_Item__c logLine : logLines) {
            if (logLine.ERP7__Purchase_Line_Items__c != null && logLine.ERP7__Putaway_Quantity__c != null) {Decimal currentQty = purchaseLineItemToPutawayQtyMap.get(logLine.ERP7__Purchase_Line_Items__c);
                                                                                                            if (currentQty == null){ currentQty = 0;}purchaseLineItemToPutawayQtyMap.put(logLine.ERP7__Purchase_Line_Items__c,currentQty + logLine.ERP7__Putaway_Quantity__c);
                                                                                                           }
            purchaseLineItemToNameMap.put(logLine.ERP7__Purchase_Line_Items__c,logLine.ERP7__Product__r.Name);
        }
        
        for (ERP7__Purchase_Line_Items__c pli : Trigger.new) {
            Decimal totalPutawayQty = purchaseLineItemToPutawayQtyMap.get(pli.Id);
            if (totalPutawayQty != null && totalPutawayQty > pli.ERP7__Quantity__c) {System.debug('error countttt');String name=purchaseLineItemToNameMap.get(pli.Id)!=null?purchaseLineItemToNameMap.get(pli.Id):'';
                                                                                  //   pli.ERP7__Quantity__c.addError('Purchase quantity (' + pli.ERP7__Quantity__c + ') on line item "' + name + '" cannot be less than total received quantity (' + totalPutawayQty + ').');
                                                                                  }
        }
        //
        //for bill scenario
        Set<Id> updatedPLIIds = new Set<Id>();
        for (ERP7__Purchase_Line_Items__c newPLI : Trigger.new) {
            ERP7__Purchase_Line_Items__c oldPLI = Trigger.oldMap.get(newPLI.Id);
            if ((newPLI.ERP7__Quantity__c != oldPLI.ERP7__Quantity__c) ||
                (newPLI.ERP7__Unit_Price__c != oldPLI.ERP7__Unit_Price__c) ||
                (newPLI.ERP7__Tax_Rate__c != oldPLI.ERP7__Tax_Rate__c)) {
                    updatedPLIIds.add(newPLI.Id);
                }
        }
        
        if (!updatedPLIIds.isEmpty()) {
            // Query Bill_Line_Items that are related to the updated PLIs
            // check before updating the pli if there are multiple bill line items
            Map<Id, Integer> unpostedBillCount = new Map<Id, Integer>();
            for (AggregateResult ar : [
                SELECT COUNT(Id) countt, ERP7__Purchase_Order_Line_Items__c pliId
                FROM ERP7__Bill_Line_Item__c
                WHERE ERP7__Purchase_Order_Line_Items__c IN :updatedPLIIds //AND ERP7__Bill__r.ERP7__Posted__c = false
                GROUP BY ERP7__Purchase_Order_Line_Items__c
            ]) {
                unpostedBillCount.put((Id)ar.get('pliId'), (Integer)ar.get('countt'));
            }

            for (ERP7__Purchase_Line_Items__c pli : Trigger.new) {
                if (updatedPLIIds.contains(pli.Id) && unpostedBillCount.get(pli.Id) > 1) {
                  //  pli.addError('Cannot modify this Purchase Order Line Item while it is associated with more than one Bill.');
                }
            }//check before updating the pli if there are multiple bill line items end
            List<ERP7__Bill_Line_Item__c> billLineItems = [
                SELECT Id, ERP7__Purchase_Order_Line_Items__c, ERP7__Bill__r.ERP7__Matched__c, ERP7__Posted__c
                FROM ERP7__Bill_Line_Item__c
                WHERE ERP7__Purchase_Order_Line_Items__c IN :updatedPLIIds
            ];
            System.debug('validation in trigger isBefore');
            // Create a map to quickly look up related PLIs
            Map<Id, ERP7__Purchase_Line_Items__c> pliMap = new Map<Id, ERP7__Purchase_Line_Items__c>(Trigger.new);
            
            for (ERP7__Bill_Line_Item__c bli : billLineItems) {
                ERP7__Purchase_Line_Items__c relatedPLI = pliMap.get(bli.ERP7__Purchase_Order_Line_Items__c);
                
                if (relatedPLI != null) {
                   /* if (bli.ERP7__Bill__r.ERP7__Matched__c) {
                        relatedPLI.addError('You cannot update this Purchase Line Item because the associated Bill has already been Matched.');
                    } else */
                    if (bli.ERP7__Posted__c) {
                     //   relatedPLI.addError('You cannot update this Purchase Line Item because the associated Bill Line Item has already been posted.');
                    }
                }
            }
        }
        //bill scenario end
		Set<Id> pliIds = new Set<Id>();System.debug('below part of code??');
		for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) {
            ERP7__Purchase_Line_Items__c oldPLI = System.Trigger.OldMap.get(pli.Id);
            if(pli.ERP7__Quantity__c != oldPLI.ERP7__Quantity__c|| pli.ERP7__Unit_Price__c != oldPLI.ERP7__Unit_Price__c|| pli.ERP7__Tax_Rate__c != oldPLI.ERP7__Tax_Rate__c){
                pliIds.add(pli.Id);
				Decimal quantity = pli.ERP7__Quantity__c != null ? pli.ERP7__Quantity__c : 0;Decimal unitPrice = pli.ERP7__Unit_Price__c != null ? pli.ERP7__Unit_Price__c : 0;Decimal taxRate = pli.ERP7__Tax_Rate__c != null ? pli.ERP7__Tax_Rate__c : 0;
				Decimal baseAmount = quantity * unitPrice;Decimal taxAmount = baseAmount * (taxRate / 100);Decimal totalPrice = baseAmount;// + taxAmount
				pli.ERP7__Tax__c = taxAmount;pli.ERP7__Total_Price__c = totalPrice;
			}
        }//the below if condition to update ERP7__Billed_Quantity__c if we have it
        if (!pliIds.isEmpty()) {
            Set<Id> pliWithBills = new Set<Id>();
            for (ERP7__Bill_Line_Item__c bli : [
                SELECT ERP7__Purchase_Order_Line_Items__c
                FROM ERP7__Bill_Line_Item__c
                WHERE ERP7__Purchase_Order_Line_Items__c IN :pliIds
                
            ]) {
                pliWithBills.add(bli.ERP7__Purchase_Order_Line_Items__c);
            }
            
            // Update ERP7__Billed_Quantity__c only for those PLIs
            for (ERP7__Purchase_Line_Items__c pli : Trigger.new) {
                if (pliWithBills.contains(pli.Id)) {
                    pli.ERP7__Billed_Quantity__c = pli.ERP7__Quantity__c;
                }
            }
        }//update ERP7__Billed_Quantity__c scenario end
    }
    //
    
    //
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<Id> pliIdsToDelete = new Set<Id>();
        for (ERP7__Purchase_Line_Items__c pli : Trigger.old) {pliIdsToDelete.add(pli.Id);}
        List<ERP7__Logistic_Line_Item__c> relatedLogLines = [
            SELECT Id, ERP7__Putaway_Quantity__c, ERP7__Quantity_Received__c, ERP7__Purchase_Line_Items__c
            FROM ERP7__Logistic_Line_Item__c
            WHERE ERP7__Purchase_Line_Items__c IN :pliIdsToDelete
        ];
        List<ERP7__Bill_Line_Item__c> billItems=[Select Id, ERP7__Quantity__c from ERP7__Bill_Line_Item__c where ERP7__Purchase_Order_Line_Items__c IN :pliIdsToDelete];
        
        // Track any PLI that has non-zero received or putaway quantity
        Set<Id> pliBlockedFromDelete = new Set<Id>();Map<Id, Decimal> totalReceivedMap = new Map<Id, Decimal>();Map<Id, Decimal> totalPutawayMap = new Map<Id, Decimal>();Map<Id, List<ERP7__Bill_Line_Item__c>> billItemsMap = new Map<Id, List<ERP7__Bill_Line_Item__c>>();
        
        for (ERP7__Logistic_Line_Item__c logLine : relatedLogLines) {
            Id pliId = logLine.ERP7__Purchase_Line_Items__c;
            if (logLine.ERP7__Putaway_Quantity__c != null && logLine.ERP7__Putaway_Quantity__c > 0) {pliBlockedFromDelete.add(pliId);totalPutawayMap.put(pliId, (totalPutawayMap.get(pliId) != null ? totalPutawayMap.get(pliId) : 0) + logLine.ERP7__Putaway_Quantity__c);}
            if (logLine.ERP7__Quantity_Received__c != null && logLine.ERP7__Quantity_Received__c > 0) {pliBlockedFromDelete.add(pliId);totalReceivedMap.put(pliId, (totalReceivedMap.get(pliId) != null ? totalReceivedMap.get(pliId) : 0) + logLine.ERP7__Quantity_Received__c);}
        }
        
        // Add error to each PLI that can't be deleted for logistic related....
        for (ERP7__Purchase_Line_Items__c pli : Trigger.old) {
            if (pliBlockedFromDelete.contains(pli.Id)) {Decimal receivedQty = totalReceivedMap.containsKey(pli.Id) ? totalReceivedMap.get(pli.Id) : 0;Decimal putawayQty = totalPutawayMap.containsKey(pli.Id) ? totalPutawayMap.get(pli.Id) : 0;
                                                       // pli.addError('Cannot delete this Purchase Line Item because it has associated Logistic Line Items that have already been received (Putaway: ' + putawayQty + ', Received: ' + receivedQty + ').');
            }
        }
        
        for (ERP7__Bill_Line_Item__c bli : [
            SELECT Id, ERP7__Purchase_Order_Line_Items__c
            FROM ERP7__Bill_Line_Item__c
            WHERE ERP7__Purchase_Order_Line_Items__c IN :pliIdsToDelete
        ]) {
            if (!billItemsMap.containsKey(bli.ERP7__Purchase_Order_Line_Items__c)) {billItemsMap.put(bli.ERP7__Purchase_Order_Line_Items__c, new List<ERP7__Bill_Line_Item__c>());}
            billItemsMap.get(bli.ERP7__Purchase_Order_Line_Items__c).add(bli);
        }
        
        // Prevent deletion if related Bill Line Items exist
        for (ERP7__Purchase_Line_Items__c pli : Trigger.old) {
            if (billItemsMap.containsKey(pli.Id)) {
              //  pli.addError('This purchase order line item cannot be deleted because it is referenced by a Bill Line Item.');
            }
        }
        
    }
    //
    if(trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) &&!Trigger.Isdelete){
        Set<Id> POIds = new Set<Id>();
        for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) POIds.add(pli.ERP7__Purchase_Orders__c);
        if(!System.isFuture() && !System.isBatch() && POIds.size() > 0 && PreventRecursiveLedgerEntry.AwaitingStockPO) {
            PreventRecursiveLedgerEntry.AwaitingStockPO = false;
            MaintainBatchStocks.MaintainAwaitingStocksPO(POIds);  
            system.debug('call to MaintainAwaitingStocksPO');
        }
    }   
    
    if(Trigger.IsAfter){
        Set<Id> poIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        Set<Id> pliIds = new Set<Id>();
        Set<Id> masterPOIds = new Set<Id>();
        
        Map<Id, ERP7__Stock_Outward_Line_Item__c> ExistingStockOutwardItems = new Map<Id, ERP7__Stock_Outward_Line_Item__c>();
        
        //new code added by arshad 01/02/23
        Set<Id> serialProdIds = new Set<Id>();
        Set<Id> lotProdIds = new Set<Id>();
        Set<Id> normalProdIds = new Set<Id>();
        Map<Id, List<Id>> serialstockIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> lotstockIds = new Map<Id, List<Id>>();
        Map<Id, List<Id>> normalstockIds = new Map<Id, List<Id>>();
        
        if(!PreventRecursiveLedgerEntry.testCasesTransactions && Trigger.isExecuting) {
            Id PORecdType = RecordTypeUtil.getObjectRecordTypeIds('PO__c','Return_to_Vendor_RTV');
            if(!Trigger.Isdelete) for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) {  if(pli.ERP7__Product__c != null){ poIds.add(pli.ERP7__Purchase_Orders__c); prodIds.add(pli.ERP7__Product__c); } }
            if(!Trigger.IsDelete) {
                pliIds = Trigger.newMap.keyset();
                for(ERP7__PO__c po: [SELECT Id, Name, ERP7__Master_Purchase_Orders__c, RecordTypeId FROM ERP7__PO__c WHERE Id IN : poIds AND ERP7__Master_Purchase_Orders__c != null]) {                    if(po.RecordTypeId == PORecdType) masterPOIds.add(po.ERP7__Master_Purchase_Orders__c);
                }
                system.debug('masterPOIds : '+masterPOIds.size() + '  : '+masterPOIds);
             if(masterPOIds.size() > 0) {    List<Id> stockIds = new List<Id>();    for(ERP7__Stock_Inward_Line_Item__c SILI: [select Id, Name, ERP7__Product__c,ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Serial__c,ERP7__Material_Batch_Lot__c, ERP7__Site_ProductService_InventoryStock__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Purchase_Orders__c In: masterPOIds and ERP7__Status__c  != 'Awaiting Stock' AND ERP7__Site_ProductService_InventoryStock__c != null AND ERP7__Product__c != null AND ERP7__Product__c IN: prodIds Order By CreatedDate ASC]) {        if(SILI.ERP7__Product__r.ERP7__Serialise__c){            stockIds = new List<Id>();            serialProdIds.add(SILI.ERP7__Product__c);            if(serialstockIds.containsKey(SILI.ERP7__Product__c)) stockIds = serialstockIds.get(SILI.ERP7__Product__c);            if(!stockIds.contains(SILI.ERP7__Site_ProductService_InventoryStock__c)) stockIds.add(SILI.ERP7__Site_ProductService_InventoryStock__c);            if(stockIds.size() > 0) serialstockIds.put(SILI.ERP7__Product__c, stockIds);        }else if(SILI.ERP7__Product__r.ERP7__Lot_Tracked__c){            stockIds = new List<Id>();            lotProdIds.add(SILI.ERP7__Product__c);            if(lotstockIds.containsKey(SILI.ERP7__Product__c)) stockIds = lotstockIds.get(SILI.ERP7__Product__c);            if(!stockIds.contains(SILI.ERP7__Site_ProductService_InventoryStock__c)) stockIds.add(SILI.ERP7__Site_ProductService_InventoryStock__c);            if(stockIds.size() > 0) lotstockIds.put(SILI.ERP7__Product__c, stockIds);        }else{            stockIds = new List<Id>();            normalProdIds.add(SILI.ERP7__Product__c);            if(normalstockIds.containsKey(SILI.ERP7__Product__c)) stockIds = normalstockIds.get(SILI.ERP7__Product__c);            if(!stockIds.contains(SILI.ERP7__Site_ProductService_InventoryStock__c)) stockIds.add(SILI.ERP7__Site_ProductService_InventoryStock__c);            if(stockIds.size() > 0) normalstockIds.put(SILI.ERP7__Product__c, stockIds);        }    }}
                system.debug('normalstockIds : '+normalstockIds);
                system.debug('lotstockIds : '+lotstockIds);
                system.debug('serialstockIds : '+serialstockIds);
                if(pliIds.size() > 0) {
                    for(ERP7__Stock_Outward_Line_Item__c SOLI: [select Id, Name, ERP7__Purchase_Line_Items__c, ERP7__Purchase_Orders__c, ERP7__Product__c, ERP7__Active__c, ERP7__Site_Product_Service_Inventory_Stock__c,
                                                                ERP7__Quantity__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Product__r.ERP7__Track_Inventory__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Serial__c,ERP7__Material_Batch_Lot__c,
                                                                ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.RecordTypeId from ERP7__Stock_Outward_Line_Item__c where ERP7__Purchase_Line_Items__c In: pliIds]) {                                                                  if(SOLI.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.RecordTypeId == PORecdType) ExistingStockOutwardItems.put(SOLI.ERP7__Purchase_Line_Items__c, SOLI);
                                                                                                                                                                                                                          
                                                                }
                }     
                
                List<ERP7__Stock_Outward_Line_Item__c> StockOutwardItems2update = new List<ERP7__Stock_Outward_Line_Item__c>();
                
                Map<id, ERP7__PO__c> POMaps = new Map<id, ERP7__PO__c>();
                
                for(ERP7__PO__c po: [SELECT Id, Name, ERP7__Master_Purchase_Orders__c, RecordTypeId,ERP7__Ready_To_Pick_Pack__c FROM ERP7__PO__c WHERE Id IN : poIds]) {
                    POMaps.put(po.id, po);
                }
                
                //new code added by arshad 01/02/23
                for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) {
                    if(pli.ERP7__Product__c != null && pli.Quantity__c != null){
                        ERP7__PO__c po = new ERP7__PO__c();
                        po = POMaps.get(pli.ERP7__Purchase_Orders__c);
                        if(po.RecordTypeId == PORecdType) {                            if(!(ExistingStockOutwardItems.containsKey(pli.Id))) {                                if(serialProdIds.contains(pli.ERP7__Product__c) && serialstockIds.containskey(pli.ERP7__Product__c)){                                    for(Integer i = 0; i < pli.Quantity__c; i++){                                        ERP7__Stock_Outward_Line_Item__c SOLI = (ExistingStockOutwardItems.containsKey(pli.Id)) ? ExistingStockOutwardItems.get(pli.Id) : new ERP7__Stock_Outward_Line_Item__c();                                        if(!(ExistingStockOutwardItems.containsKey(pli.Id)) && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Name.isUpdateable()) SOLI.Name = 'SOLI-' + pli.Name;                                                                if(pli.Product__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) SOLI.Product__c = pli.Product__c;                                        if(pli.Asset__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable()) SOLI.Fixed_Asset__c = pli.ERP7__Asset__c;                                        if(pli.Quantity__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) SOLI.Quantity__c = 1;                                         if(pli.Unit_Price__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()) SOLI.Unit_Price__c = pli.Unit_Price__c;                                         if(pli.Tax__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Tax__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Tax__c.isUpdateable()) SOLI.Tax__c = pli.Tax__c;                                        if(pli.Total_Price__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()) SOLI.Total_Amount__c = pli.Total_Price__c;                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) SOLI.Purchase_Orders__c = pli.Purchase_Orders__c;                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Line_Items__c.isUpdateable())SOLI.Purchase_Line_Items__c = pli.Id;                                                                                if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){                                             if(!(ExistingStockOutwardItems.containsKey(pli.Id))){                                               if(po.ERP7__Ready_To_Pick_Pack__c) SOLI.Status__c = 'Reserved';                                                else SOLI.Status__c = 'Returned to Supplier';                                            }else{                                                if(String.isNotEmpty(SOLI.Status__c)){                                                }                                                else  if(po.ERP7__Ready_To_Pick_Pack__c) SOLI.Status__c = 'Reserved';                                                 else SOLI.Status__c = 'Returned to Supplier';                                            }                                        }                                        if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable())SOLI.Active__c = true;                                              if(!(ExistingStockOutwardItems.containsKey(pli.Id))){                                            if(serialstockIds.get(pli.ERP7__Product__c).size() > i && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()) SOLI.ERP7__Site_Product_Service_Inventory_Stock__c = serialstockIds.get(pli.ERP7__Product__c)[i];                                        }                                        StockOutwardItems2update.add(SOLI);                                    }                                }                                else if((lotProdIds.contains(pli.ERP7__Product__c) && lotstockIds.containskey(pli.ERP7__Product__c)) || normalProdIds.contains(pli.ERP7__Product__c) && normalstockIds.containskey(pli.ERP7__Product__c)){                                    ERP7__Stock_Outward_Line_Item__c SOLI = new ERP7__Stock_Outward_Line_Item__c();                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Name.isUpdateable()) SOLI.Name = 'SOLI-' + pli.Name;                                                            if(pli.Product__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()) SOLI.Product__c = pli.Product__c;                                    if(pli.Asset__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Fixed_Asset__c.isUpdateable()) SOLI.Fixed_Asset__c = pli.ERP7__Asset__c;                                    if(pli.Quantity__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()) SOLI.Quantity__c = pli.Quantity__c;                                    if(pli.Unit_Price__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()) SOLI.Unit_Price__c = pli.Unit_Price__c;                                     if(pli.Tax__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Tax__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Tax__c.isUpdateable()) SOLI.Tax__c = pli.Tax__c;                                    if(pli.Total_Price__c != null && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()) SOLI.Total_Amount__c = pli.Total_Price__c;                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) SOLI.Purchase_Orders__c = pli.Purchase_Orders__c;                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Purchase_Line_Items__c.isUpdateable())SOLI.Purchase_Line_Items__c = pli.Id;                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){                                       if(po.ERP7__Ready_To_Pick_Pack__c) SOLI.Status__c = 'Reserved';                                         else SOLI.Status__c = 'Returned to Supplier';                                    }                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable())SOLI.Active__c = true;                                         if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){                                        if(lotstockIds.containskey(pli.ERP7__Product__c)){                                            if(lotstockIds.get(pli.ERP7__Product__c).size() > 0) SOLI.ERP7__Site_Product_Service_Inventory_Stock__c = lotstockIds.get(pli.ERP7__Product__c)[0];                                        }else if(normalstockIds.containskey(pli.ERP7__Product__c)){                                            if(normalstockIds.get(pli.ERP7__Product__c).size() > 0) SOLI.ERP7__Site_Product_Service_Inventory_Stock__c = normalstockIds.get(pli.ERP7__Product__c)[0];                                        }                                    }                                                                        StockOutwardItems2update.add(SOLI);                                }                            }                         }                 
                    }
                } 
                system.debug('StockOutwardItems2update-->'+StockOutwardItems2update.size());
                if(StockOutwardItems2update.size() > 0 &&  StockOutwardItems2update[0].ERP7__Site_Product_Service_Inventory_Stock__c != null && Schema.SObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.SObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()) upsert StockOutwardItems2update; else{  }
            } 
            else {                system.debug('poli to delete all stow for return pos');                for(ERP7__Purchase_Line_Items__c pli : System.Trigger.Old) {                     for(ERP7__PO__c po: [SELECT Id, Name, ERP7__Master_Purchase_Orders__c, RecordTypeId FROM ERP7__PO__c WHERE Id IN : poIds]) {                        if(pli.ERP7__Purchase_Orders__c == po.Id && po.RecordTypeId == PORecdType) pliIds.add(pli.Id);                     }                }                  if(pliIds.size() > 0) {                    List<ERP7__Stock_Outward_Line_Item__c> StockOutwardItems2Delete = new List<ERP7__Stock_Outward_Line_Item__c>([Select Id, Name From ERP7__Stock_Outward_Line_Item__c Where ERP7__Purchase_Line_Items__c In: pliIds]);                    if(StockOutwardItems2Delete.size() > 0 && ERP7__Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()){ system.debug('deleting all stow for return pos here'); delete StockOutwardItems2Delete; }else{ }                                }            }             
            
            // Start ==> Create MRPS for POLIs when exploded...
            
            if(Trigger.IsUpdate){
                /*Return Quanity Order*/
                system.debug('Roll up summary to sum up return quantity called');
                list < RollUpSummaryUtility.fieldDefinition > MAPfieldDefinitions1 = new list < RollUpSummaryUtility.fieldDefinition > {
                    new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity__c', 'ERP7__Return_Quanitty__c')
                        };
                            RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.new, 'ERP7__Purchase_Line_Items__c', 'ERP7__Master_Purchase_Line_Items__c', 'ERP7__Purchase_Line_Items__c', ' AND ERP7__Master_Purchase_Line_Items__c  != null');
                
                
                list<Id> pliIds2explode = new list<Id>();
                list<Id> proIds = new list<Id>();
                Map<Id, List< ERP7__MRP__c >> pliMrps = new Map<Id, List< ERP7__MRP__c >>();
                Map<Id, List< ERP7__BOM__c >> pliBOMS = new Map<Id, List< ERP7__BOM__c >>();
                List< ERP7__MRP__c > MRPS2Insert = new List< ERP7__MRP__c >();
                List< ERP7__MRP__c > mrps2delete = new List< ERP7__MRP__c >();
                
                for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) {
                    if(pli.Explode__c) { pliIds2explode.add(pli.Id); proIds.add(pli.ERP7__Product__c);}
                }
                
                List< ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, ERP7__Purchase_Line_Items__c, RecordType.Name From ERP7__MRP__c Where RecordType.Name = 'MRP Kit' And ERP7__Purchase_Line_Items__c In :pliIds2explode];
                List< ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name, 
                                             BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c, BOM_Version__r.Status__c
                                             From ERP7__BOM__c 
                                             Where ERP7__Active__c = true And 
                                             RecordType.Name = 'Kit BOM' And 
                                             ERP7__BOM_Product__c In : proIds And
                                             BOM_Version__r.Active__c = true And
                                             BOM_Version__r.Start_Date__c <= Today And
                                             BOM_Version__r.To_Date__c >= Today And
                                             (BOM_Version__r.Type__c = 'Assembly' Or
                                              BOM_Version__r.Type__c = 'Sales')
                                             Order by BOM_Version__r.Default__c DESC];
                
                for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) {
                    if(pli.Explode__c){
                        List< ERP7__MRP__c > myMRPS = new List< ERP7__MRP__c >();
                        for(ERP7__MRP__c mrp : MRPS){
                            if(pli.Id == mrp.ERP7__Purchase_Line_Items__c) myMRPS.add(mrp);
                        }
                        pliMrps.put(pli.Id,myMRPS);
                        
                        List< ERP7__BOM__c > myBOMS = new List< ERP7__BOM__c >();
                        List< ERP7__BOM__c > myAllBOMS = new List< ERP7__BOM__c >();
                        
                        for(ERP7__BOM__c bom : BOMS){
                            if(pli.Product__c == bom.ERP7__BOM_Product__c && pli.Version__c != Null && pli.Version__c == bom.BOM_Version__c){
                                myBOMS.add(bom);
                            } 
                            else if(pli.Product__c == bom.ERP7__BOM_Product__c && pli.Version__c == Null && bom.BOM_Version__c != Null && bom.BOM_Version__r.Default__c == true){
                                myBOMS.add(bom);
                            }
                            if(pli.Product__c == bom.ERP7__BOM_Product__c && pli.Version__c == Null && bom.BOM_Version__c == Null){
                                myAllBOMS.add(bom);
                            }
                        }
                        
                        if(myBOMS.size() > 0) pliBOMS.put(pli.Id,myBOMS); 
                        else if(myAllBOMS.size() > 0) pliBOMS.put(pli.Id,myAllBOMS);
                    }
                }
                
                Id rTpe_MRPKIT; rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
                
                Map<Id, String> pliOldVersion = new Map<Id, String>();
                Map<Id, Decimal> pliOldQuantity = new Map<Id, Decimal>();
                
                if(Trigger.IsUpdate){
                    for(ERP7__Purchase_Line_Items__c pli : System.Trigger.Old) {
                        pliOldQuantity.put(pli.Id,pli.Quantity__c);
                        if(pli.Version__c != Null) pliOldVersion.put(pli.Id,pli.Version__c);
                        else pliOldVersion.put(pli.Id,'');
                    }
                }
                
                for(ERP7__Purchase_Line_Items__c pli : System.Trigger.New) {
                    
                    /*
Handles the deletion of MRPs if BOM version on poli is changed..
*/
                    
                    if(pli.Explode__c == true && ((pliOldVersion.containsKey(pli.Id) && String.valueof(pli.Version__c) != pliOldVersion.get(pli.Id)) || pliOldQuantity.get(pli.Id) != pli.Quantity__c) && pliMrps.containsKey(pli.Id) && pliMrps.get(pli.Id).size() > 0) {                        mrps2delete.addAll(pliMrps.get(pli.Id));                         pliMrps.get(pli.Id).clear();                    }
                    
                    if(pli.Explode__c && pliMrps.get(pli.Id).size() == 0 && pliBOMS.containsKey(pli.Id)){                        for(ERP7__BOM__c bom : pliBOMS.get(pli.Id)){                            ERP7__MRP__c MRP = new ERP7__MRP__c();                            if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()) MRP.Name = BOM.Name;                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()) MRP.ERP7__Total_Amount_Required__c = BOM.Quantity__c*pli.Quantity__c;                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()) MRP.ERP7__BOM__c = BOM.Id;                            if(Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Version__c.isUpdateable()) MRP.Version__c = pli.Version__c;                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()) MRP.ERP7__MRP_Product__c = BOM.ERP7__BOM_Component__c;                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable()) MRP.ERP7__Purchase_Line_Items__c = PLI.Id;                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Purchase_Order__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Purchase_Order__c.isUpdateable()) MRP.ERP7__Purchase_Order__c = PLI.ERP7__Purchase_Orders__c;                            if(rTpe_MRPKIT != null && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()) MRP.RecordTypeId = rTpe_MRPKIT;                            MRPS2Insert.add(MRP);                           }                    }          
                }
                
                if(MRPS2Insert.size() > 0 && Schema.SObjectType.ERP7__MRP__c.isCreateable() && Schema.SObjectType.ERP7__MRP__c.isUpdateable()) upsert MRPS2Insert; else{ }
                
                if(mrps2delete.size() > 0) {                    List<Id> mrpIds = new List<Id>();                    for(MRP__c MRP : mrps2delete){                         mrpIds.add(MRP.Id);                      }                    List<Stock_Outward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, Batch_Lot_Code__c, BoM__c, Process__c, Schedule__c, MRP_Material_Requirements_Planning__c,                                                               Product__c, Purchase_Orders__c, Quantity__c,                                                                Site_Product_Service_Inventory_Stock__c, Status__c, Tax__c, Total_Amount__c, Unit_Price__c                                                               From Stock_Outward_Line_Item__c                                                                Where MRP_Material_Requirements_Planning__c In: mrpIds];                                        if(SDLIs.size() > 0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete SDLIs; else{ }                    if(MRP__c.sObjectType.getDescribe().isDeletable()) delete mrps2delete; else{ }                                    }          
            }
            // END ==> Create MRPS for POLIs when exploded...
            
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
        }
    }
    
   
}