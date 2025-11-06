trigger InventoryManaging_RMALineItems on RMA_Line_Item__c (before insert,before delete, before update, after insert, after update, after delete, after undelete) {
    if(PreventRecursiveLedgerEntry.RMA_Inventory){
        PreventRecursiveLedgerEntry.RMA_Inventory = false;
        Set<Id> stockIds = new Set<Id>();
        if(!Trigger.Isdelete){
            for(RMA_Line_Item__c s : System.Trigger.New){
                if(s.Site_Item_Inventory_Stock__c != Null) stockIds.add(s.Site_Item_Inventory_Stock__c);
            }
            
            /*Return Quantity For Invoice Line Item*/
            list < RollUpSummaryUtility.fieldDefinition > RMALI_retQty = new list < RollUpSummaryUtility.fieldDefinition > {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity_Return__c', 'ERP7__Return_Quantity__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(RMALI_retQty, trigger.new, 'ERP7__RMA_Line_Item__c', 'ERP7__Invoice_Line_Item__c', 'ERP7__Invoice_Line_Item__c', ' ');
            
        }
        else{
            for(RMA_Line_Item__c s : System.Trigger.Old){
                if(s.Site_Item_Inventory_Stock__c != Null) stockIds.add(s.Site_Item_Inventory_Stock__c);
            }
        }
        List<Inventory_Stock__c> stocks = [Select Id, Name From Inventory_Stock__c Where Id In : stockIds];
        if(stocks.size() > 0 && Schema.sObjectType.Inventory_Stock__c.isUpdateable()) { update stocks; } else{ /* no access */ }
        
        
        
        if(Trigger.IsInsert && Trigger.IsBefore && !PreventRecursiveLedgerEntry.testCasesTransactions){ 
            //OrderInventoryUtil.createProductReturnedLineItems(System.Trigger.New);
        }
        
        if((Trigger.IsInsert || Trigger.IsUpdate) && Trigger.IsBefore && !PreventRecursiveLedgerEntry.testCasesTransactions){ 
            List<Id> soliIds = new List<Id>();
            Set<Id> OrdItemIds = new Set<Id>();
            for(RMA_Line_Item__c s : System.Trigger.New){
                if(s.ERP7__SOLI__c != Null) soliIds.add(s.ERP7__SOLI__c);
                if(s.ERP7__Ord_Item__c != Null) OrdItemIds.add(s.ERP7__Ord_Item__c);
            }
            Map<Id, Sales_Order_Line_Item__c> SOLIS = new Map<Id, Sales_Order_Line_Item__c>([Select Id, Name, Product__c from Sales_Order_Line_Item__c where Id In :soliIds]);
            Map<Id, OrderItem> OrdItemS = new Map<Id, OrderItem>([Select Id,Product2Id from OrderItem where Id In :OrdItemIds]);
            for(RMA_Line_Item__c s : System.Trigger.New){
                if(s.ERP7__SOLI__c != Null && SOLIS.get(s.ERP7__SOLI__c).Product__c != Null) s.Product__c = SOLIS.get(s.ERP7__SOLI__c).Product__c;
                if(s.ERP7__Ord_Item__c != Null && OrdItemS.get(s.ERP7__Ord_Item__c).Product2Id != Null) s.Product__c = OrdItemS.get(s.ERP7__Ord_Item__c).Product2Id;
            }
        }

        if(Trigger.IsAfter && !PreventRecursiveLedgerEntry.testCasesTransactions){ 
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            Set<Id> soliIds = new Set<Id>();
            Set<Id> OrdItemIds = new Set<Id>();
            if(!Trigger.IsDelete) {
                for(RMA_Line_Item__c s : System.Trigger.New){
                    if(s.SOLI__c != Null) soliIds.add(s.SOLI__c);
                    if(s.ERP7__Ord_Item__c != Null) OrdItemIds.add(s.ERP7__Ord_Item__c);
                }
            }
            if(Trigger.IsUpdate) {
                for(RMA_Line_Item__c s : System.Trigger.Old){
                    if(s.SOLI__c != Null) soliIds.add(s.SOLI__c);
                    if(s.ERP7__Ord_Item__c != Null) OrdItemIds.add(s.ERP7__Ord_Item__c);
                }
            }
            List<Sales_Order_Line_Item__c> solis = [Select Id, Name, ERP7__ReturnAmount__c, ERP7__ReturnedQuantity__c, ERP7__RMALines_to_Process__c from Sales_Order_Line_Item__c where Id In : soliIds];
            List<OrderItem> ordItems=[Select Id, ERP7__ReturnAmount__c, ERP7__ReturnedQuantity__c, ERP7__RMALines_to_Process__c from OrderItem where Id In : OrdItemIds];
            List<RMA_Line_Item__c> rmaLines=new List<RMA_Line_Item__c>();
            if(soliIds.size() > 0) rmaLines = [Select Id, Name, ERP7__Total_Deduction__c,ERP7__Tax__c, ERP7__Quantity_Return__c, ERP7__SOLI__c from ERP7__RMA_Line_Item__c where ERP7__SOLI__c In : soliIds];
            if(OrdItemIds.size()>0) rmaLines = [Select Id, Name, ERP7__Total_Deduction__c,ERP7__Tax__c, ERP7__Quantity_Return__c, ERP7__Ord_Item__c from ERP7__RMA_Line_Item__c where ERP7__Ord_Item__c In : OrdItemIds];
            
            for(Sales_Order_Line_Item__c soli : solis){
                Decimal RQuantity = 0;
                Decimal RAmount = 0;
                Decimal Count = 0;  
                for(RMA_Line_Item__c rmaLine : rmaLines){
                    if(rmaLine.SOLI__c == soli.Id){
                        Count++;
                        if(rmaLine.ERP7__Tax__c == Null)rmaLine.ERP7__Tax__c = 0.00;
                        if(rmaLine.ERP7__Total_Deduction__c != Null ) RAmount += rmaLine.ERP7__Total_Deduction__c + rmaLine.ERP7__Tax__c;
                        if(rmaLine.ERP7__Quantity_Return__c != Null) RQuantity += rmaLine.ERP7__Quantity_Return__c;
                    }
                }
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnedQuantity__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnedQuantity__c.isUpdateable()){ soli.ERP7__ReturnedQuantity__c = RQuantity;} else{ /* no access */ }
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnAmount__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnAmount__c.isUpdateable()){ soli.ERP7__ReturnAmount__c = RAmount; } else{ /* no access */ }
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__RMALines_to_Process__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__RMALines_to_Process__c.isUpdateable()) {soli.ERP7__RMALines_to_Process__c = Count;} else{ /* no access */ }
            }
            if(solis.size()>0 && Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()){ upsert solis; } else{ /* no access */ }
            
            for(Orderitem ord:ordItems){
                Decimal RQuantity = 0;
                Decimal RAmount = 0;
                Decimal Count = 0;  
                for(RMA_Line_Item__c rmaLine : rmaLines){
                    if(rmaLine.ERP7__Ord_Item__c == ord.Id){
                        Count++;
                        if(rmaLine.ERP7__Tax__c == Null) rmaLine.ERP7__Tax__c = 0.00;
                        if(rmaLine.ERP7__Total_Deduction__c != Null ) RAmount += rmaLine.ERP7__Total_Deduction__c + rmaLine.ERP7__Tax__c;
                        if(rmaLine.ERP7__Quantity_Return__c != Null) RQuantity += rmaLine.ERP7__Quantity_Return__c;
                    }
                }
                if(Schema.sObjectType.OrderItem.fields.ERP7__ReturnedQuantity__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__ReturnedQuantity__c.isUpdateable()){ord.ERP7__ReturnedQuantity__c = RQuantity;} else{ /* no access */ }
                if(Schema.sObjectType.OrderItem.fields.ERP7__ReturnAmount__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__ReturnAmount__c.isUpdateable()){ord.ERP7__ReturnAmount__c = RAmount;} else{ /* no access */ }
                if(Schema.sObjectType.OrderItem.fields.ERP7__RMALines_to_Process__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__RMALines_to_Process__c.isUpdateable()){ord.ERP7__RMALines_to_Process__c = Count;} else{ /* no access */ }
            }
            if(ordItems.size()>0 && Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()) { upsert ordItems; } else{ /* no access */ }
        }else{
            Set<Id> soliIds = new Set<Id>();
            Set<Id> OrdItemIds = new Set<Id>();
            if(Trigger.IsDelete) {
                for(RMA_Line_Item__c s : System.Trigger.Old){
                    if(s.SOLI__c != Null) soliIds.add(s.SOLI__c);
                    if(s.ERP7__Ord_Item__c != Null) OrdItemIds.add(s.ERP7__Ord_Item__c);
                }
            }
            List<Sales_Order_Line_Item__c> solis = [Select Id, Name, ERP7__ReturnAmount__c, ERP7__ReturnedQuantity__c, ERP7__RMALines_to_Process__c from Sales_Order_Line_Item__c where Id In : soliIds];
            for(Sales_Order_Line_Item__c soli : solis){
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnedQuantity__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnedQuantity__c.isUpdateable()){soli.ERP7__ReturnedQuantity__c =0.00; } else{ /* no access */}
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnAmount__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnAmount__c.isUpdateable()){ soli.ERP7__ReturnAmount__c = 0.0; } else{ /* no access */}
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__RMALines_to_Process__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__RMALines_to_Process__c.isUpdateable()){soli.ERP7__RMALines_to_Process__c = 0;} else{ /* no access */}
            }
            if(solis.size() > 0 &&  Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()) { upsert solis; } else{ /*no access */ }
            List<OrderItem> ordItems=[Select Id,ERP7__ReturnAmount__c, ERP7__ReturnedQuantity__c, ERP7__RMALines_to_Process__c from OrderItem where Id In : OrdItemIds];
            for(OrderItem Ord : ordItems){
                if(Schema.sObjectType.OrderItem.fields.ERP7__ReturnedQuantity__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__ReturnedQuantity__c.isUpdateable()){Ord.ERP7__ReturnedQuantity__c =0.00;} else{ /* no access */}
            	if(Schema.sObjectType.OrderItem.fields.ERP7__ReturnAmount__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__ReturnAmount__c.isUpdateable()){Ord.ERP7__ReturnAmount__c = 0.0;} else{ /* no access */}
                if(Schema.sObjectType.OrderItem.fields.ERP7__RMALines_to_Process__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__RMALines_to_Process__c.isUpdateable()){Ord.ERP7__RMALines_to_Process__c = 0;} else{ /* no access */}
            }
            if(ordItems.size() > 0 &&  Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()) { upsert ordItems; } else{ /*no access */ }
        }
        
        // Start ==> Create MRPS for ROLIs when exploded...
        
        if((Trigger.IsInsert || Trigger.IsUpdate) && Trigger.IsAfter){
            list<Id> ROLIIds2explode = new list<Id>();
            list<Id> proIds = new list<Id>();
            List< ERP7__MRP__c > mrps2delete = new List< ERP7__MRP__c >();
            Map<Id, List< ERP7__MRP__c >> ROLIMrps = new Map<Id, List< ERP7__MRP__c >>();
            Map<Id, List< ERP7__BOM__c >> ROLIBOMS = new Map<Id, List< ERP7__BOM__c >>();
            List< ERP7__MRP__c > MRPS2Insert = new List< ERP7__MRP__c >();
            
            for(RMA_Line_Item__c ROLI : System.Trigger.New) {
                if(ROLI.Explode__c) { ROLIIds2explode.add(ROLI.Id); proIds.add(ROLI.ERP7__Product__c); }
            }
            
            List< ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, ERP7__RMA_Line_Item__c, RecordType.Name 
                                         From ERP7__MRP__c 
                                         Where RecordType.Name = 'MRP Kit' And 
                                         ERP7__RMA_Line_Item__c In :ROLIIds2explode];
            
            List< ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, ERP7__BOM_Version__c, BOM_Version__r.Default__c, ERP7__BOM_Product__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name 
                                         From ERP7__BOM__c 
                                         Where ERP7__Active__c = true And 
                                         ERP7__BOM_Product__c In : proIds And
                                         BOM_Version__r.Active__c = true And
                                         BOM_Version__r.Start_Date__c <= Today And
                                         BOM_Version__r.To_Date__c >= Today And 
                                         RecordType.Name = 'Kit BOM'
                                         Order by BOM_Version__r.Default__c DESC];
            
            for(RMA_Line_Item__c ROLI : System.Trigger.New) {
                if(ROLI.Explode__c){
                    List< ERP7__MRP__c > myMRPS = new List< ERP7__MRP__c >();
                    for(ERP7__MRP__c mrp : MRPS){
                        if(ROLI.Id == mrp.ERP7__RMA_Line_Item__c) myMRPS.add(mrp);
                    }
                    ROLIMrps.put(ROLI.Id,myMRPS);
                    
                    List< ERP7__BOM__c > myBOMS = new List< ERP7__BOM__c >();
                    List< ERP7__BOM__c > myAllBOMS = new List< ERP7__BOM__c >();
                    
                    for(ERP7__BOM__c bom : BOMS){
                        if(roli.Product__c == bom.ERP7__BOM_Product__c && roli.Version__c != Null && roli.Version__c == bom.BOM_Version__c){
                            myBOMS.add(bom);
                        } 
                        else if(roli.Product__c == bom.ERP7__BOM_Product__c && roli.Version__c == Null && bom.BOM_Version__c != Null && bom.BOM_Version__r.Default__c == true){
                            myBOMS.add(bom);
                        }
                        if(roli.Product__c == bom.ERP7__BOM_Product__c && roli.Version__c == Null && bom.BOM_Version__c == Null){
                            myAllBOMS.add(bom);
                        }
                    }
                    
                    if(myBOMS.size() > 0) roliBOMS.put(roli.Id,myBOMS); 
                    else if(myAllBOMS.size() > 0) roliBOMS.put(roli.Id,myAllBOMS);
                }
            }
            
            Id rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
            Id rTpe_MRPMAN = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Manufacturing').getRecordTypeId();
            
            Map<Id, String> roliOldVersion = new Map<Id, String>();
            Map<Id, Decimal> roliOldQuantity = new Map<Id, Decimal>();
            
            if(Trigger.IsUpdate){
                for(RMA_Line_Item__c ROLI : System.Trigger.Old) {
                    roliOldQuantity.put(roli.Id,roli.Quantity_Return__c);
                    if(roli.Version__c != Null) roliOldVersion.put(roli.Id,roli.Version__c);
                    //else roliOldVersion.put(roli.Id,'');
                }
            }
            
            for(RMA_Line_Item__c ROLI : System.Trigger.New) {
                /*
Handles the deletion of MRPs if BOM version on soli is changed..
*/
                
                if(roli.Explode__c == true && ((roliOldVersion.containsKey(roli.Id) && String.valueof(roli.Version__c) != roliOldVersion.get(roli.Id)) || roliOldQuantity.get(roli.Id) != roli.Quantity_Return__c) && roliMrps.containsKey(roli.Id) && roliMrps.get(roli.Id).size() > 0) {
                    mrps2delete.addAll(roliMrps.get(roli.Id)); 
                    roliMrps.get(roli.Id).clear();
                }
                
                if(ROLI.Explode__c && ROLIMrps.get(ROLI.Id).size() == 0 && ROLIBOMS.containsKey(ROLI.Id)){
                    for(ERP7__BOM__c bom : ROLIBOMS.get(ROLI.Id)){
                        ERP7__MRP__c MRP = new ERP7__MRP__c();
                        if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()){ MRP.Name = BOM.Name;} else{ /* no access */ }
                    	if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){MRP.ERP7__Total_Amount_Required__c = BOM.Quantity__c*ROLI.Quantity_Return__c;} else{ /* no access */ }
                		if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()){MRP.ERP7__BOM__c = BOM.Id;} else{ /* no access */ }
            			if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()){MRP.ERP7__MRP_Product__c = BOM.ERP7__BOM_Component__c;} else{ /* no access */ }
        				if(Schema.sObjectType.ERP7__MRP__c.fields.RMA_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RMA_Line_Item__c.isUpdateable()){MRP.RMA_Line_Item__c = ROLI.Id;} else{ /* no access */ }
                        if(Schema.sObjectType.ERP7__MRP__c.fields.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Sales_Order_Line_Item__c.isUpdateable()){ MRP.Sales_Order_Line_Item__c = ROLI.SOLI__c; } else{ /* no access */ }
                        if( Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Order_Product__c.isUpdateable()){ MRP.ERP7__Order_Product__c = ROLI.ERP7__Ord_Item__c; } else{ /* no access */ }
                        if(rTpe_MRPKIT!= null && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()) { MRP.RecordTypeId = rTpe_MRPKIT; } else{ /* no access */ }
                        MRPS2Insert.add(MRP); 
                    }
                }
            }
            if(MRPS2Insert.size() > 0 &&  Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) { upsert MRPS2Insert; } else{ /* no access */ }
            
            if(mrps2delete.size() > 0) {
                List<Id> mrpIds = new List<Id>();
                for(MRP__c MRP : mrps2delete){ 
                    mrpIds.add(MRP.Id);  
                }
                List<Stock_Outward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, Batch_Lot_Code__c, BoM__c, Process__c, Schedule__c, MRP_Material_Requirements_Planning__c,
                                                           Product__c, Purchase_Orders__c, Quantity__c, 
                                                           Site_Product_Service_Inventory_Stock__c, Status__c, Tax__c, Total_Amount__c, Unit_Price__c
                                                           From Stock_Outward_Line_Item__c 
                                                           Where MRP_Material_Requirements_Planning__c In: mrpIds];
                
                if(SDLIs.size() > 0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) { delete SDLIs; } else{ /* no access */ }
                if(MRP__c.sObjectType.getDescribe().isDeletable()){ delete mrps2delete; } else{ /* no access */ }
                
            }
        }
    }
    // END ==> Create MRPS for POLIs when exploded...
}