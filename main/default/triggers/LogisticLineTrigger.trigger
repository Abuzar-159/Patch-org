/*
 * LastModifiedBy - Arshad Shariff
 * LastModifiedDate - 08/06/2023
 * Reason - Enhancement to capture picked/packed qty on PO & POLI from LOLI for RTVPO
 */

trigger LogisticLineTrigger on Logistic_Line_Item__c (after insert, after update,before delete, after delete, after undelete) {
    system.debug('LogisticLineTrigger trigger.isAfter : '+trigger.isAfter);
    system.debug('LogisticLineTrigger trigger.isExecuting : '+trigger.isExecuting);
    system.debug('LogisticLineTrigger PreventRecursiveLedgerEntry.LogisticLineRollup: '+PreventRecursiveLedgerEntry.LogisticLineRollup);
    Map<Id, ERP7__Purchase_Line_Items__c> POLImap = new Map<Id, ERP7__Purchase_Line_Items__c>();
    Map<Id, ERP7__Purchase_Line_Items__c> RTVPOLImap = new Map<Id, ERP7__Purchase_Line_Items__c>();
    
    //added below code to not allow deletion of line items if quantity is fully received or partially received
    if (Trigger.isBefore && Trigger.isDelete) {
        for (ERP7__Logistic_Line_Item__c item : Trigger.old) {
            Decimal quantity = item.ERP7__Quantity__c;
            Decimal putawayQuantity = item.ERP7__Putaway_Quantity__c;
            
            if (putawayQuantity != null && quantity != null && putawayQuantity > 0) {
                if (putawayQuantity >= quantity) {
                 //   item.addError('This logistic line item cannot be deleted as the quantity is fully received.');
                } else {
                  //  item.addError('This logistic line item cannot be deleted as the quantity is partially received.');
                }
            }
        }
    }//new code end

    if(trigger.isAfter && PreventRecursiveLedgerEntry.LogisticLineRollup && Trigger.isExecuting)
        if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {
            PreventRecursiveLedgerEntry.LogisticLineRollup = false;
            
            Map<Id, ERP7__Sales_Order_Line_Item__c> soliMap = new Map<Id, ERP7__Sales_Order_Line_Item__c>();
            Map<Id, OrderItem> orderProductMap = new Map<Id, OrderItem>();
            Map<Id, ERP7__Transfer_Order_Line_Items__c> TOLImap = new Map<Id, ERP7__Transfer_Order_Line_Items__c>();
            Map<Id, ERP7__RMA_Line_Item__c> RMALImap = new Map<Id, ERP7__RMA_Line_Item__c>();
            
            for(Logistic_Line_Item__c loli : trigger.new){
                if(loli.ERP7__Sales_Order_Line_Item__c != null) soliMap.put(loli.ERP7__Sales_Order_Line_Item__c, new ERP7__Sales_Order_Line_Item__c(Id=loli.ERP7__Sales_Order_Line_Item__c, ERP7__Logistic_Quantity__c=0, ERP7__Picked_Quantity__c=0, ERP7__Packed_Quantity__c=0, ERP7__Shipped_Quantity__c=0));
                if(loli.ERP7__Order_Product__c != null) orderProductMap.put(loli.ERP7__Order_Product__c, new OrderItem(Id=loli.ERP7__Order_Product__c, ERP7__Logistic_Quantity__c=0, ERP7__Picked_Quantity__c=0, ERP7__Packed_Quantity__c=0, ERP7__Shipped_Quantity__c=0));
                if(loli.ERP7__Transfer_Order_Line_Item__c != null) TOLImap.put(loli.ERP7__Transfer_Order_Line_Item__c, new ERP7__Transfer_Order_Line_Items__c(Id=loli.ERP7__Transfer_Order_Line_Item__c, ERP7__Putaway_Quantity__c=0, ERP7__Shipped_Quantity__c=0,ERP7__Quantity_received__c=0,ERP7__Quantity_remaining__c=0,ERP7__Picked_Quantity__c=0,ERP7__Packed_Quantity__c=0));
                if(loli.ERP7__Purchase_Line_Items__c != null && loli.ERP7__Is_Return_PO__c == false) POLImap.put(loli.ERP7__Purchase_Line_Items__c, new ERP7__Purchase_Line_Items__c(Id=loli.ERP7__Purchase_Line_Items__c, ERP7__Putaway_Quantity__c=0,ERP7__Quantity_received__c=0,ERP7__Logistic_Quantity__c = 0));
                if(loli.ERP7__Purchase_Line_Items__c != null && loli.ERP7__Is_Return_PO__c == true) RTVPOLImap.put(loli.ERP7__Purchase_Line_Items__c, new ERP7__Purchase_Line_Items__c(Id=loli.ERP7__Purchase_Line_Items__c, ERP7__Picked_Quantity__c=0, ERP7__Packed_Quantity__c=0,ERP7__Logistic_Quantity__c = 0));
                if(loli.ERP7__RMA_Line_Item__c != null) RMALImap.put(loli.ERP7__RMA_Line_Item__c, new ERP7__RMA_Line_Item__c(Id=loli.ERP7__RMA_Line_Item__c, ERP7__Received_Quantity__c=0));
            }
            system.debug('POLImap.size() : '+POLImap.size());
            system.debug('RTVPOLImap.size() : '+RTVPOLImap.size());
            
            if(soliMap.size() > 0 || orderProductMap.size() > 0 || TOLImap.size() > 0 || POLImap.size() > 0 || RMALImap.size() > 0 || RTVPOLImap.size() > 0){
                List<Logistic_Line_Item__c> Lolis = [Select Id, Name, ERP7__Sales_Order_Line_Item__c, ERP7__Order_Product__c,ERP7__Transfer_Order_Line_Item__c,ERP7__Purchase_Line_Items__c,ERP7__RMA_Line_Item__c, ERP7__Picked_Quantity__c, ERP7__Packed_Quantity__c, ERP7__Quantity__c,ERP7__Putaway_Quantity__c,ERP7__Shipped_Quantity__c,ERP7__Quantity_Received__c,ERP7__Remaining_Quantity__c 
                                                     From Logistic_Line_Item__c Where (ERP7__Sales_Order_Line_Item__c != Null And ERP7__Sales_Order_Line_Item__c In :soliMap.keySet()) Or (ERP7__Order_Product__c != Null And ERP7__Order_Product__c In :orderProductMap.keySet()) Or (ERP7__Transfer_Order_Line_Item__c != Null And ERP7__Transfer_Order_Line_Item__c In :TOLImap.keySet()) 
                                                     Or (ERP7__Purchase_Line_Items__c != Null And ERP7__Purchase_Line_Items__c In :POLImap.keySet())  Or (ERP7__Purchase_Line_Items__c != Null And ERP7__Purchase_Line_Items__c In :RTVPOLImap.keySet()) Or (ERP7__RMA_Line_Item__c != Null And ERP7__RMA_Line_Item__c In :RMALImap.keySet())];
                for(Logistic_Line_Item__c loli :Lolis){
                    system.debug('loli.ERP7__Purchase_Line_Items__c : '+loli.ERP7__Purchase_Line_Items__c);
                    if(loli.ERP7__Sales_Order_Line_Item__c != null){
                        if(soliMap.containsKey(loli.ERP7__Sales_Order_Line_Item__c)){
                            ERP7__Sales_Order_Line_Item__c soli = soliMap.get(loli.ERP7__Sales_Order_Line_Item__c);
                            if(loli.ERP7__Quantity__c != Null) soli.ERP7__Logistic_Quantity__c += loli.ERP7__Quantity__c;
                            system.debug('soli.ERP7__Logistic_Quantity__c : '+soli.ERP7__Logistic_Quantity__c);
                            if(loli.ERP7__Picked_Quantity__c != Null) soli.ERP7__Picked_Quantity__c += loli.ERP7__Picked_Quantity__c;
                            if(loli.ERP7__Packed_Quantity__c != Null) soli.ERP7__Packed_Quantity__c += loli.ERP7__Packed_Quantity__c;
                            if(loli.ERP7__Shipped_Quantity__c != Null) soli.ERP7__Shipped_Quantity__c += loli.ERP7__Shipped_Quantity__c;
                            soliMap.put(soli.Id, soli);
                        }
                    }
                    if(loli.ERP7__Order_Product__c != null){
                        if(orderProductMap.containsKey(loli.ERP7__Order_Product__c)){
                            OrderItem orderProduct = orderProductMap.get(loli.ERP7__Order_Product__c);
                            if(loli.ERP7__Quantity__c != Null) orderProduct.ERP7__Logistic_Quantity__c += loli.ERP7__Quantity__c;
                            system.debug('orderProduct.ERP7__Logistic_Quantity__c : '+orderProduct.ERP7__Logistic_Quantity__c);
                            if(loli.ERP7__Picked_Quantity__c != Null) orderProduct.ERP7__Picked_Quantity__c += loli.ERP7__Picked_Quantity__c;
                            if(loli.ERP7__Packed_Quantity__c != Null) orderProduct.ERP7__Packed_Quantity__c += loli.ERP7__Packed_Quantity__c;
                            if(loli.ERP7__Shipped_Quantity__c != Null) orderProduct.ERP7__Shipped_Quantity__c += loli.ERP7__Shipped_Quantity__c;
                            system.debug('orderProduct.ERP7__Shipped_Quantity__c : '+orderProduct.ERP7__Shipped_Quantity__c);
                            orderProductMap.put(orderProduct.Id, orderProduct);
                        }
                    }
                    if(loli.ERP7__Transfer_Order_Line_Item__c != null){
                        if(TOLImap.containsKey(loli.ERP7__Transfer_Order_Line_Item__c)){
                            ERP7__Transfer_Order_Line_Items__c toli = TOLImap.get(loli.ERP7__Transfer_Order_Line_Item__c);
                            if(loli.ERP7__Picked_Quantity__c != null) toli.ERP7__Picked_Quantity__c += loli.ERP7__Picked_Quantity__c;
                            if(loli.ERP7__Packed_Quantity__c != null) toli.ERP7__Packed_Quantity__c += loli.ERP7__Packed_Quantity__c;
                            if(loli.ERP7__Putaway_Quantity__c != null) toli.ERP7__Putaway_Quantity__c += loli.ERP7__Putaway_Quantity__c;
                            if(loli.ERP7__Shipped_Quantity__c != null) toli.ERP7__Shipped_Quantity__c += loli.ERP7__Shipped_Quantity__c;
                            if(loli.ERP7__Quantity_Received__c != null) toli.ERP7__Quantity_received__c += loli.ERP7__Quantity_Received__c;
                            //if(loli.ERP7__Remaining_Quantity__c != null) toli.ERP7__Quantity_remaining__c += loli.ERP7__Remaining_Quantity__c;
                            TOLImap.put(toli.Id, toli);
                        }
                    }
                    if(loli.ERP7__Purchase_Line_Items__c != null){
                         if(POLImap.containsKey(loli.ERP7__Purchase_Line_Items__c)){
                            ERP7__Purchase_Line_Items__c soli = POLImap.get(loli.ERP7__Purchase_Line_Items__c);
                            if(loli.ERP7__Quantity__c != Null) soli.ERP7__Logistic_Quantity__c += loli.ERP7__Quantity__c;
                            if(loli.ERP7__Quantity_Received__c != Null) soli.ERP7__Quantity_Received__c += loli.ERP7__Quantity_Received__c;
                            if(loli.ERP7__Putaway_Quantity__c != Null && loli.ERP7__Putaway_Quantity__c > 0) soli.ERP7__Putaway_Quantity__c += loli.ERP7__Putaway_Quantity__c;
                            POLImap.put(soli.Id, soli);
                            system.debug('POLImap after: '+POLImap);
                        }
                        if(RTVPOLImap.containsKey(loli.ERP7__Purchase_Line_Items__c)){
                            ERP7__Purchase_Line_Items__c soli = RTVPOLImap.get(loli.ERP7__Purchase_Line_Items__c);
                            if(loli.ERP7__Quantity__c != Null) soli.ERP7__Logistic_Quantity__c += loli.ERP7__Quantity__c;
                            if(loli.ERP7__Picked_Quantity__c != Null) soli.ERP7__Picked_Quantity__c += loli.ERP7__Picked_Quantity__c;
                            if(loli.ERP7__Packed_Quantity__c != Null) soli.ERP7__Packed_Quantity__c += loli.ERP7__Packed_Quantity__c;
                            RTVPOLImap.put(soli.Id, soli);
                            system.debug('RTVPOLImap after: '+RTVPOLImap);
                        }
                    }
                    
                    if(loli.ERP7__RMA_Line_Item__c != null){
                         if(RMALImap.containsKey(loli.ERP7__RMA_Line_Item__c)){
                            ERP7__RMA_Line_Item__c rmali = RMALImap.get(loli.ERP7__RMA_Line_Item__c);
                            if(loli.ERP7__Putaway_Quantity__c != Null) rmali.ERP7__Received_Quantity__c += loli.ERP7__Putaway_Quantity__c;
                            RMALImap.put(rmali.Id, rmali);
                        }
                    }
                    
                } 
                try{ if(soliMap.values().size() > 0) update soliMap.values(); } catch(exception e){ }
                system.debug('orderProductMap : '+orderProductMap.values().size());
                system.debug('orderProductMap : '+orderProductMap);
                try{ if(orderProductMap.values().size() > 0) { PreventRecursiveLedgerEntry.Loged = true; update orderProductMap.values(); } } catch(exception e){ }
                try{ if(TOLImap.values().size() > 0) update TOLImap.values(); } catch(exception e){ }
                system.debug('RMALImap : '+RMALImap.values().size());
                try{ if(RMALImap.values().size() > 0) update RMALImap.values(); } catch(exception e){ }
            }
        }
    
    if((trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) ) {//&& PreventRecursiveLedgerEntry.LogisticLineRollupInbound && Trigger.isExecuting
        PreventRecursiveLedgerEntry.LogisticLineRollupInbound = false;
        system.debug('POLImap 1: '+POLImap.values().size());
        system.debug('POLImap 2: '+POLImap.values());
        try{ if(POLImap.values().size() > 0) { update POLImap.values(); system.debug('POLI update call to ManageStockOutwardLineItems: '+POLImap.values());}} catch(exception e){ }
        
        system.debug('RTVPOLImap 1: '+RTVPOLImap.values().size());
        system.debug('RTVPOLImap 2: '+RTVPOLImap.values());
        try{ if(RTVPOLImap.values().size() > 0) { update RTVPOLImap.values(); system.debug('RTVPOLI update call to ManageStockOutwardLineItems: '+RTVPOLImap.values());}} catch(exception e){ }
        /* list<RollUpSummaryUtility.fieldDefinition> FieldDefinitions5 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Putaway_Quantity__c', 'ERP7__Putaway_Quantity__c')
                };
                    RollUpSummaryUtility.rollUpTrigger(FieldDefinitions5, trigger.new, 'Logistic_Line_Item__c','ERP7__Purchase_Line_Items__c', 'ERP7__Purchase_Line_Items__c', '');
        list<RollUpSummaryUtility.fieldDefinition> FieldDefinitions6 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity_Received__c', 'ERP7__Quantity_Received__c')
                };
                    RollUpSummaryUtility.rollUpTrigger(FieldDefinitions6, trigger.new, 'Logistic_Line_Item__c','ERP7__Purchase_Line_Items__c', 'ERP7__Purchase_Line_Items__c', '');
*/
    }
    
}