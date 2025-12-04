trigger CreateTOMRPs on Transfer_Order_Line_Items__c (before delete, after insert, after update, after undelete) {
    system.debug('CreateTOMRPs PreventRecursiveLedgerEntry.testCasesTransactions~>'+PreventRecursiveLedgerEntry.testCasesTransactions);
    if(!PreventRecursiveLedgerEntry.testCasesTransactions){  
        if(Trigger.IsBefore){
            if(Trigger.IsDelete){
                List<Stock_Outward_Line_Item__c>  SDLIs = [Select Id From Stock_Outward_Line_Item__c Where Transfer_Order_Line_Item__c In: System.Trigger.Old];  
                if(SDLIs.size() > 0 && Schema.sObjectType.Stock_Outward_Line_Item__c.isDeletable()) delete SDLIs;       
            }
        }
        
        if(Trigger.IsAfter){
            system.debug('TOLI stoli 0');
            set < Id > SOLI2Update = new set < Id > ();
            for (Transfer_Order_Line_Items__c TOLI_New: System.Trigger.New){
                if (TOLI_New.ERP7__Ready_To_Pick_Pack__c) SOLI2Update.add(TOLI_New.Id);
            }
            if (Trigger.IsInsert || Trigger.IsUndelete ) {
                
                if (SOLI2Update.size() > 0) TransferOrderInventoryUtils.createStockOutwardLineItems(SOLI2Update);
                system.debug('SOLI2Update size~>'+SOLI2Update.size());
            }
            
            //changes 
            if(Trigger.IsUpdate){
                system.debug('TOLI stoli 1');
                List <Stock_Outward_Line_Item__c> SOutwardList = [Select Id, Name From Stock_Outward_Line_Item__c  Where ERP7__Transfer_Order_Line_Item__c In: SOLI2Update  And Active__c = true];   //And ERP7__Picked_Date__c = Null
                if(SOutwardList.size() == 0){
                    system.debug('TOLI stoli 2');
                    TransferOrderInventoryUtils.createStockOutwardLineItems(SOLI2Update);
                } 
            }
			//
			        
            if(Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsUndelete){
                /* 
                    Start ==> Create MRPS for POLIs when exploded based on BOM and its versions ...
                */
                
                list<Id> toliIds2explode = new list<Id>(); list<Id> proIds = new list<Id>();  List< ERP7__MRP__c > mrps2delete = new List< ERP7__MRP__c >(); Map<Id, List< ERP7__MRP__c >> toliMrps = new Map<Id, List< ERP7__MRP__c >>();  Map<Id, List< ERP7__BOM__c >> toliBOMS = new Map<Id, List< ERP7__BOM__c >>();  List< ERP7__MRP__c > MRPS2Insert = new List< ERP7__MRP__c >();
                
                for(Transfer_Order_Line_Items__c toli : System.Trigger.New) {
                    if(toli.Explode__c) {  toliIds2explode.add(toli.Id);   proIds.add(toli.ERP7__Products__c); 
                    }
                }
                
                List< ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name,
                                                ERP7__Transfer_Order_Line_Item__c 
                                                From ERP7__MRP__c
                                                Where RecordType.Name = 'MRP Kit' And
                                                ERP7__Transfer_Order_Line_Item__c In :toliIds2explode];
                                                
                List< ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name, 
                                                BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c, BOM_Version__r.Status__c
                                                From ERP7__BOM__c 
                                                Where ERP7__Active__c = true And 
                                                ERP7__BOM_Product__c In : proIds And
                                                BOM_Version__r.Active__c = true And
                                                BOM_Version__r.Start_Date__c <= Today And
                                                BOM_Version__r.To_Date__c >= Today And 
                                                RecordType.Name = 'Kit BOM'
                                                Order by BOM_Version__r.Default__c DESC];
                                                
                
                for(ERP7__Transfer_Order_Line_Items__c toli : System.Trigger.New) {
                    if(toli.Explode__c){
                    
                        List< ERP7__MRP__c > myMRPS = new List< ERP7__MRP__c >();
                        
                        for(ERP7__MRP__c mrp : MRPS){
                            if(toli.Id == mrp.ERP7__Transfer_Order_Line_Item__c) myMRPS.add(mrp);
                        }
                        
                        toliMrps.put(toli.Id,myMRPS);
                        
                        List< ERP7__BOM__c > myBOMS = new List< ERP7__BOM__c >();
                        List< ERP7__BOM__c > myAllBOMS = new List< ERP7__BOM__c >();
                        
                        for(ERP7__BOM__c bom : BOMS){
                            if(toli.Products__c == bom.ERP7__BOM_Product__c && toli.Version__c != Null && toli.Version__c == bom.BOM_Version__c){ myBOMS.add(bom);
                            } 
                            else if(toli.Products__c == bom.ERP7__BOM_Product__c && toli.Version__c == Null && bom.BOM_Version__c != Null && bom.BOM_Version__r.Default__c == true){ myBOMS.add(bom);
                            }
                            if(toli.Products__c == bom.ERP7__BOM_Product__c && toli.Version__c == Null && bom.BOM_Version__c == Null){  myAllBOMS.add(bom);
                            }
                        }
                        
                        if(myBOMS.size() > 0) toliBOMS.put(toli.Id,myBOMS);  else if(myAllBOMS.size() > 0) toliBOMS.put(toli.Id,myAllBOMS);
                        
                    }
                }
                
                Id rTpe_MRPKIT; rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
                Id rTpe_MRPMAN; rTpe_MRPMAN = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Manufacturing').getRecordTypeId();
                
                Map<Id, String> toliOldVersion = new Map<Id, String>();
                Map<Id, Decimal> toliOldQuantity = new Map<Id, Decimal>();
                
                if(Trigger.IsUpdate){  for(ERP7__Transfer_Order_Line_Items__c toli : System.Trigger.Old) {  toliOldQuantity.put(toli.Id,toli.Quantity_requested__c);  if(toli.Version__c != Null) toliOldVersion.put(toli.Id,toli.Version__c);  else toliOldVersion.put(toli.Id,'');
                    }
                }
                
                for(ERP7__Transfer_Order_Line_Items__c toli : System.Trigger.New) {
                    /*
                        Handles the deletion of MRPs if BOM version on soli is changed..
                    */
                    
                    if(toli.Explode__c == true && ((toliOldVersion.containsKey(toli.Id) && String.valueof(toli.Version__c) != toliOldVersion.get(toli.Id)) || toliOldQuantity.get(toli.Id) != toli.Quantity_requested__c) && toliMrps.containsKey(toli.Id) && toliMrps.get(toli.Id).size() > 0) {
                        mrps2delete.addAll(toliMrps.get(toli.Id));   toliMrps.get(toli.Id).clear();
                    }
                    
                    if(toli.Explode__c && toliMrps.get(toli.Id).size() == 0 && toliBOMS.containsKey(toli.Id)){
                        for(ERP7__BOM__c bom : toliBOMS.get(toli.Id)){  
                            ERP7__MRP__c MRP = new ERP7__MRP__c();  
                            if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()){MRP.Name = BOM.Name; }else{/*No access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){MRP.ERP7__Total_Amount_Required__c = BOM.Quantity__c*toli.Quantity_requested__c;  }else{/*No access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()){MRP.ERP7__BOM__c = BOM.Id;  }else{/*No access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()){MRP.ERP7__MRP_Product__c = BOM.ERP7__BOM_Component__c;  }else{/*No access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable()){MRP.ERP7__Transfer_Order_Line_Item__c = toli.Id; }else{/*No access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Transfer_Order__c.isUpdateable()){MRP.Transfer_Order__c = toli.Transfer_Order__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()){
                                if(bom.RecordType.Name == 'Kit BOM' && rTpe_MRPKIT != null) MRP.RecordTypeId = rTpe_MRPKIT;
                                else if(bom.RecordType.Name == 'Manufacturing BOM' && rTpe_MRPMAN != null) MRP.RecordTypeId = rTpe_MRPMAN;
                            }else{/*No access*/}
                            MRPS2Insert.add(MRP); 
                        }
                    }
                }
                if(MRPS2Insert.size() > 0 && Schema.SObjectType.ERP7__MRP__c.isCreateable() && Schema.SObjectType.ERP7__MRP__c.isUpdateable()){upsert MRPS2Insert;}else{/*Not allowed to upsert*/}
                
                if(mrps2delete.size() > 0) {
                    List<Id> mrpIds = new List<Id>();  for(MRP__c MRP : mrps2delete){ mrpIds.add(MRP.Id);  
                    }
                    List<Stock_Outward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, Batch_Lot_Code__c, BoM__c, Process__c, Schedule__c, MRP_Material_Requirements_Planning__c,
                                                                Product__c, Purchase_Orders__c, Quantity__c, 
                                                                Site_Product_Service_Inventory_Stock__c, Status__c, Tax__c, Total_Amount__c, Unit_Price__c
                                                                From Stock_Outward_Line_Item__c 
                                                                Where MRP_Material_Requirements_Planning__c In: mrpIds];
                    
                    if(SDLIs.size() > 0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete SDLIs;  if(ERP7__MRP__c.sObjectType.getDescribe().isDeletable()) delete mrps2delete;
                    
                }
            }
        }
        
        /* 
            End ==> Create MRPS for POLIs when exploded based on BOM and its versions ...
        */
    }
    
}