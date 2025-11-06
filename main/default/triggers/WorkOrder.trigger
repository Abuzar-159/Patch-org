/*
* Changes done on line #365  on 10/04/2023 by Shaguftha M
*/
trigger WorkOrder on ERP7__WO__c (after insert, after update, after undelete, before delete, after delete) {//before update , 
    list < Id > proIds = new list < Id > ();
    Set < Id > WOIds = new Set < Id > ();
    Set < Id > RoutingIds = new Set < Id > ();
    Map < Id, List < ERP7__Operation__c >> Routing_Operations = new Map < Id, List < ERP7__Operation__c >> ();
    Map < Id, List < ERP7__Actions_Tasks__c >> woATs = new Map < Id, List < ERP7__Actions_Tasks__c >> ();
    Map < Id, Id> opATs = new Map < Id, Id> ();//Id > Operation; Id > Actions&Task.
    list < ERP7__Actions_Tasks__c > actions2Create = new list < ERP7__Actions_Tasks__c > ();
    List < ERP7__MRP__c > mrps2delete = new List < ERP7__MRP__c > ();
    Map < Id, List < ERP7__MRP__c >> woliMrps = new Map < Id, List < ERP7__MRP__c >> ();
    Map < Id, List < ERP7__BOM__c >> woliBOMS = new Map < Id, List < ERP7__BOM__c >> ();
    List < ERP7__MRP__c > MRPS2Insert = new List < ERP7__MRP__c > ();
    List < ERP7__Inventory_Stock__c > stocks2upsert = new List < ERP7__Inventory_Stock__c > ();
    List < ERP7__Stock_Inward_Line_Item__c > stockInwards2upsert = new List < ERP7__Stock_Inward_Line_Item__c > ();
    Map < Id, ERP7__Inventory_Stock__c > woliStockMap = new Map < Id, ERP7__Inventory_Stock__c > ();
    Map < Id, Id > RoutingLinkWC = new Map < Id, Id > ();
    
    
        
    if (Trigger.IsUpdate && PreventRecursiveLedgerEntry.preventWOExecutionBefore) {//Trigger.IsBefore && 
        PreventRecursiveLedgerEntry.preventWOExecutionBefore = false;
        set<Id> WOIds = new set<Id>();
        set<Id> moIds = new set<Id>(); //Changed from List<Id> to set<Id> on 25/04/2023
        Set<Id> WOSignatures = new Set<Id>();
        for(ERP7__WO__c WO2Update : System.Trigger.New) { 
            if(WO2Update.ERP7__Is_Signature_Required__c) WOIds.add(WO2Update.Id);
            if(WO2Update.ERP7__MO__c != Null) moIds.add(WO2Update.ERP7__MO__c); 
        }
        if(WOIds.size() > 0){List<Attachment> Attachments = [Select Id, Name, ParentId, Owner.Name, CreatedDate From Attachment Where ParentId In: WOIds And Name = 'Signature' Order By CreatedDate Asc];  for(Attachment A : Attachments) WOSignatures.add(A.ParentId);
        }
       /* for(ERP7__WO__c WO2Update : System.Trigger.New){
            if(WO2Update.ERP7__Quantity_Ordered__c > 0 && WO2Update.ERP7__Quantity_Ordered__c == (WO2Update.ERP7__Quantity_Built__c + WO2Update.ERP7__Quantity_Scrapped__c) && (!WO2Update.ERP7__Is_Signature_Required__c || (WO2Update.ERP7__Is_Signature_Required__c && WOSignatures.contains(WO2Update.Id)))){
                WO2Update.ERP7__Status__c = 'Complete';
            }
        }*/
        if(moIds.size() > 0){
            List<WO__c> MOWOs2Rollup = [SELECT Id, ERP7__Rejected_Cost__c, ERP7__Scrap_Cost__c, ERP7__MO__c, ERP7__Labour_Cost__c, ERP7__Material_Cost__c, ERP7__Overhead_Cost__c 
                                        FROM ERP7__WO__c 
                                        WHERE ERP7__MO__c IN: moIds];
            system.debug('MOWOs2Rollup : '+MOWOs2Rollup.size());
            List<ERP7__Manufacturing_Order__c> MOs2Update = new List<ERP7__Manufacturing_Order__c>();
            Map<Id, List<ERP7__WO__c>> MOWOS = new Map<Id, List<ERP7__WO__c>>(); 
            for(Id moId : moIds) MOWOS.put(moId,new List<ERP7__WO__c>());
            for(ERP7__WO__c WO : MOWOs2Rollup){
                if(MOWOS.containsKey(WO.ERP7__MO__c)) MOWOS.get(WO.ERP7__MO__c).add(WO);  else MOWOS.put(WO.ERP7__MO__c, new List<ERP7__WO__c>{WO});
            }
            List<ERP7__Manufacturing_Order__c> Mos = [Select Id,Name,ERP7__Labour_Cost__c,ERP7__Material_Cost__c,ERP7__Overhead_Cost__c from ERP7__Manufacturing_Order__c where Id In :moIds];                    
            for(ERP7__Manufacturing_Order__c MO : Mos){
                //Moin commented this 3 line and added below line since the amount calculation was coming wrong while accounting wip inventory 17th january 2024
                /*if(MO.ERP7__Labour_Cost__c == null || MO.ERP7__Labour_Cost__c <= 0) MO.ERP7__Labour_Cost__c = 0;
                if(MO.ERP7__Material_Cost__c == null || MO.ERP7__Material_Cost__c <= 0) MO.ERP7__Material_Cost__c = 0;
                if(MO.ERP7__Overhead_Cost__c == null || MO.ERP7__Overhead_Cost__c <= 0) MO.ERP7__Overhead_Cost__c = 0;*/
                //ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Id = moId, ERP7__Labour_Cost__c = 0, ERP7__Material_Cost__c = 0, ERP7__Overhead_Cost__c = 0);
                if(MO.ERP7__Labour_Cost__c == null || MO.ERP7__Labour_Cost__c <= 0) MO.ERP7__Labour_Cost__c = 0;
                MO.ERP7__Material_Cost__c = 0;
                if(MO.ERP7__Overhead_Cost__c == null || MO.ERP7__Overhead_Cost__c <= 0) MO.ERP7__Overhead_Cost__c = 0;
                MO.ERP7__Scrap_Cost__c = 0;
                MO.ERP7__Rejected_Cost__c = 0;
                for(ERP7__WO__c WO : MOWOS.get(MO.Id)){
                    //if(WO.ERP7__Labour_Cost__c != Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Labour_Cost__c.isUpdateable()) { MO.ERP7__Labour_Cost__c += WO.ERP7__Labour_Cost__c; } else{/* no access */ }
                    if(WO.ERP7__Material_Cost__c != Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Material_Cost__c.isUpdateable()) { MO.ERP7__Material_Cost__c += WO.ERP7__Material_Cost__c;} else{/* no access */ }
                    //if(WO.ERP7__Overhead_Cost__c != Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Overhead_Cost__c.isUpdateable()) { MO.ERP7__Overhead_Cost__c += WO.ERP7__Overhead_Cost__c;} else{/* no access */ }
                    if(WO.ERP7__Scrap_Cost__c != Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Scrap_Cost__c.isUpdateable()) { MO.ERP7__Scrap_Cost__c += WO.ERP7__Scrap_Cost__c;} else{/* no access */ }
                    if(WO.ERP7__Rejected_Cost__c != Null && Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Rejected_Cost__c.isUpdateable()) { MO.ERP7__Rejected_Cost__c += WO.ERP7__Rejected_Cost__c;} else{/* no access */ }
                } 
                MOs2Update.add(MO);
            } 
            if(MOs2Update.size() > 0 && Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){ update MOs2Update;   } else{ /* no access */ }            
        }
    }
    
    if (Trigger.IsDelete) {
        List < Stock_Outward_Line_Item__c > SDLIs = [Select Id From Stock_Outward_Line_Item__c Where ERP7__Work_Orders__c In: System.Trigger.Old];
        if (SDLIs.size() > 0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) { delete SDLIs; } else{ /* no access */ }
    }
    
    
    system.debug('PreventRecursiveLedgerEntry.preventWOExecution : '+PreventRecursiveLedgerEntry.preventWOExecution);    
    if (Trigger.IsAfter && PreventRecursiveLedgerEntry.preventWOExecution) {
        PreventRecursiveLedgerEntry.preventWOExecution = false;
        
        if(!PreventRecursiveLedgerEntry.PreventWOLogistic) SalesOrderTrigger.ManageWorkOrderLogistics(Trigger.IsInsert,Trigger.IsUpdate, JSON.serialize(Trigger.New), JSON.serialize(Trigger.Old));
        
        if ((Trigger.IsInsert || Trigger.IsUpdate) && Trigger.IsAfter) {
            for (ERP7__WO__c WO: System.Trigger.New) {
                WOIds.add(WO.Id);
                if (WO.ERP7__Routing__c != Null) RoutingIds.add(WO.ERP7__Routing__c);
                if (WO.ERP7__Product__c != Null) proIds.add(WO.ERP7__Product__c);
            }
            List<ERP7__Actions_Tasks__c> ATs = [Select Id, Name, ERP7__Work_Order__c From ERP7__Actions_Tasks__c Where ERP7__Work_Order__c In : WOIds]; 
            for (ERP7__Actions_Tasks__c AT: ATs) {
                if (AT.ERP7__Work_Order__c != Null && woATs.containskey(AT.ERP7__Work_Order__c)) {   woATs.get(AT.ERP7__Work_Order__c).add(AT);
                } else if (AT.ERP7__Work_Order__c != Null && !woATs.containskey(AT.ERP7__Work_Order__c)) {
                    List < ERP7__Actions_Tasks__c > myList = new List < ERP7__Actions_Tasks__c > ();
                    myList.add(AT);
                    woATs.put(AT.ERP7__Work_Order__c, myList);
                }
            }
            
            List < ERP7__Operation__c > Operations = [Select Id, Name, ERP7__Routing_Link__c, ERP7__Description__c, ERP7__Fixed_Cost__c, ERP7__Move_Time__c, ERP7__Next_Operation_No__c, ERP7__Operation_No__c, ERP7__Sort__c,
                                                      ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.ERP7__Process__c, ERP7__Quantity__c, ERP7__Required__c, ERP7__Routing__c, ERP7__Routing__r.ERP7__Process__r.RecordType.Name, ERP7__Run_Time__c, ERP7__Setup_Time__c, ERP7__Variable_Cost__c,
                                                      ERP7__Work_Center__c, ERP7__Wait_Time__c, ERP7__Type__c, ERP7__Auto_Clock_In__c
                                                      From ERP7__Operation__c Where ERP7__Routing__c In: RoutingIds Order By ERP7__Sort__c, ERP7__Process_Cycle__r.CreatedDate, ERP7__Operation_No__c ASC
                                                     ];
            for (ERP7__Operation__c Operation: Operations) {
                if (Operation.ERP7__Routing__c != Null && Routing_Operations.containskey(Operation.ERP7__Routing__c)) {   RoutingLinkWC.put(Operation.ERP7__Process_Cycle__c, Operation.ERP7__Routing_Link__c); Routing_Operations.get(Operation.ERP7__Routing__c).add(Operation);
                } else if (Operation.ERP7__Routing__c != Null && !Routing_Operations.containskey(Operation.ERP7__Routing__c)) {
                    List < ERP7__Operation__c > myList = new List < ERP7__Operation__c > ();
                    myList.add(Operation);
                    Routing_Operations.put(Operation.ERP7__Routing__c, myList);
                }
            }
            for (ERP7__WO__c WO: System.Trigger.New) {
                if (Routing_Operations.containsKey(WO.ERP7__Routing__c) && !woATs.containsKey(WO.Id) && (Routing_Operations.get(WO.ERP7__Routing__c)[0].ERP7__Routing__r.ERP7__Process__r.RecordType.Name == 'Maintenance Process' || WO.ERP7__Escape_Process__c) && !WO.ERP7__Is_Closed__c) {
                    for (ERP7__Operation__c Operation: Routing_Operations.get(WO.ERP7__Routing__c)) {
                        ERP7__Actions_Tasks__c action2Create = new ERP7__Actions_Tasks__c();
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.Name.isUpdateable()){ action2Create.Name = Operation.Name; } else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process_Cycle__c.isUpdateable()){action2Create.ERP7__Process_Cycle__c = Operation.ERP7__Process_Cycle__c;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Routing_Link__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Routing_Link__c.isUpdateable()){action2Create.ERP7__Routing_Link__c = Operation.ERP7__Routing_Link__c;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Work_Order__c.isUpdateable()){action2Create.ERP7__Work_Order__c = WO.Id;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){action2Create.ERP7__Manufacturing_Order__c = WO.ERP7__MO__c;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Operation__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Operation__c.isUpdateable()){action2Create.ERP7__Operation__c = Operation.Id;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Type__c.isUpdateable()){action2Create.ERP7__Type__c = Operation.ERP7__Type__c;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Work_Center__c.isUpdateable()){action2Create.ERP7__Work_Center__c = Operation.ERP7__Work_Center__c;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Product__c.isUpdateable()){action2Create.ERP7__Product__c = WO.ERP7__Product__c;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Process__c.isUpdateable()){action2Create.ERP7__Process__c = Operation.ERP7__Process_Cycle__r.ERP7__Process__c;} else{/* no access*/}
                        if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Auto_Clock_In__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Auto_Clock_In__c.isUpdateable()){action2Create.ERP7__Auto_Clock_In__c = Operation.ERP7__Auto_Clock_In__c;} else{/* no access*/}
                        if((WO.ERP7__Process_Cycle__c != Null && Operation.ERP7__Process_Cycle__c == WO.ERP7__Process_Cycle__c) || WO.ERP7__Process_Cycle__c == Null) actions2Create.add(action2Create);
                    }
                }
                if (woATs.containsKey(WO.Id) && WO.ERP7__Status__c == 'Complete') { for(ERP7__Actions_Tasks__c task : woATs.get(WO.Id)) {   if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Status__c.isUpdateable()){task.ERP7__Status__c = 'Completed';} else{/* no access*/}  actions2Create.add(task);
                    }
                }
            }
            if (actions2Create.size() > 0 && Schema.sObjectType.ERP7__Actions_Tasks__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){ upsert actions2Create; } else{ /* no access */}
            actions2Create = [Select Id,Name,ERP7__Operation__c from ERP7__Actions_Tasks__c where ERP7__Operation__c IN :Operations];
            //this nested for loop removed by imran
            //for (ERP7__Operation__c Operation: Operations) {
                for(ERP7__Actions_Tasks__c task: actions2Create){
                    //if(task.ERP7__Operation__c == Operation.Id)
                        if(task.ERP7__Operation__c != Null) opATs.put(task.ERP7__Operation__c, task.Id);
                }
            //}
            
        }
        
        
        if (Trigger.IsAfter) {
            system.debug('after exceution 1');
            if (Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsUndelete) {
                system.debug('after IsUpdate 1');
                /* 
                Start ==> Create MRPS based on BOM and its versions ...
                */
                Set<Id> moIds = new set<Id>();
                for(ERP7__WO__c wo : System.Trigger.New) if(wo.ERP7__MO__c != Null) moIds.add(wo.ERP7__MO__c);
                List < ERP7__MRP__c > MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__Routing_Link__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MO__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name,
                                              ERP7__Work_Order_Line_Items__c,  ERP7__Work_Order__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c
                                              From ERP7__MRP__c
                                              Where RecordType.Name = 'MRP Manufacturing'
                                              And
                                              ERP7__Work_Order__c In: System.Trigger.New
                                             ];
                List<ERP7__WO__c> WOMO = [ SELECT Id, Name, Product__c, ERP7__Process_Cycle__c, Version__c,ERP7__MO__c,ERP7__MO__r.ERP7__Order_Product__c,ERP7__MO__r.ERP7__Order_Product__r.ERP7__Version__c FROM ERP7__WO__c WHERE Id IN :Trigger.NewMap.keySet()];
				

                // system.assertequals(MRPS.size(), 100);
                List < ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, ERP7__For_Multiples__c,ERP7__Operation__c, ERP7__Routing_Link__c, ERP7__Routing_Link__r.ERP7__Process_Cycle__c, BOM_Product__c, BOM_Version__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name,
                                              BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c, BOM_Version__r.Status__c, ERP7__Type__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c, ERP7__Process_Cycle__r.ERP7__Process__c                    From ERP7__BOM__c
                                              Where ERP7__Active__c = true And
                                              ERP7__BOM_Product__c In: proIds And
                                              ERP7__Type__c = 'Primary' And
                                              BOM_Version__r.Active__c = true And
                                              BOM_Version__r.Start_Date__c <= Today And
                                              BOM_Version__r.To_Date__c >= Today And
                                              RecordType.Name = 'Manufacturing BOM' 
                                              and ERP7__BOM_Component__r.ERP7__Track_Inventory__c =true // added to create only track inventory products for MRPs by shaguftha 26_06_2023
                                              Order by BOM_Version__r.Default__c DESC 
                                             ];
                for (ERP7__WO__c woli: System.Trigger.New) {
                    List < ERP7__MRP__c > myMRPS = new List < ERP7__MRP__c > ();
                    for (ERP7__MRP__c mrp: MRPS) {   if (woli.Id == mrp.ERP7__Work_Order__c) myMRPS.add(mrp);
                    }
                    woliMrps.put(woli.Id, myMRPS);
                    List < ERP7__BOM__c > myBOMS = new List < ERP7__BOM__c > ();
                    List < ERP7__BOM__c > myAllBOMS = new List < ERP7__BOM__c > ();
                    for (ERP7__BOM__c bom: BOMS) {
                        if (woli.Product__c == bom.ERP7__BOM_Product__c && woli.ERP7__Process_Cycle__c == bom.ERP7__Routing_Link__r.ERP7__Process_Cycle__c  && woli.Version__c != Null && woli.Version__c == bom.BOM_Version__c) {
                            myBOMS.add(bom);
                            system.debug('if');    } else if (woli.Product__c == bom.ERP7__BOM_Product__c && woli.ERP7__Process_Cycle__c == bom.ERP7__Routing_Link__r.ERP7__Process_Cycle__c  && woli.Version__c == Null && bom.BOM_Version__c != Null && bom.BOM_Version__r.Default__c == true) {  myBOMS.add(bom);
                        }
                        
                        //Added by Parveez on 06-sept-24 to get All boms for MRP Creation from the Order product version instead product defualt version.
                       
                        ERP7__Functionality_Control__c customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
                        
                        if (customList == null) {
                            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
                        }
                        if (customList == null) {
                            customList = ERP7__Functionality_Control__c.getInstance();            
                        }
                        boolean allowGetBomsProdVersion = customList != null && customList.ERP7__Order_Product_Version_for_manufacturing__c;
                        
                        if (allowGetBomsProdVersion) {
                            for (ERP7__WO__c wom : WOMO) {   if (wom.Product__c == bom.ERP7__BOM_Product__c &&
                                    wom.ERP7__Process_Cycle__c == bom.ERP7__Routing_Link__r.ERP7__Process_Cycle__c &&  wom.Version__c != null &&  bom.BOM_Version__c == wom.ERP7__MO__r.ERP7__Order_Product__r.ERP7__Version__c) {
                                        
                                        myBOMS.add(bom);
                                    }
                            }
                        }
                        
                        if (woli.Product__c == bom.ERP7__BOM_Product__c && woli.ERP7__Process_Cycle__c == bom.ERP7__Routing_Link__r.ERP7__Process_Cycle__c  && woli.Version__c == Null && bom.BOM_Version__c == Null) {  myAllBOMS.add(bom);
                        }
                    }
                     system.debug('myBOMS : '+myBOMS.size());
                     system.debug('myAllBOMS : '+myAllBOMS.size());
                    if (myBOMS.size() > 0) woliBOMS.put(woli.Id, myBOMS);
                    else if (myAllBOMS.size() > 0) woliBOMS.put(woli.Id, myAllBOMS);
                }
                
                Id rTpe_MRPKIT; rTpe_MRPKIT = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Kit').getRecordTypeId();
                
                Id rTpe_MRPMAN; rTpe_MRPMAN = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Manufacturing').getRecordTypeId();
                
                Map < Id, String > moliOldVersion = new Map < Id, String > ();
                Map < Id, Decimal > moliOldQuantity = new Map < Id, Decimal > ();
                Map < Id, Decimal > woliOldQuantityManu = new Map < Id, Decimal > ();
                if (Trigger.IsUpdate) {
                    for (ERP7__WO__c woli: System.Trigger.Old) {
                        moliOldQuantity.put(woli.Id, woli.ERP7__Quantity_Ordered__c);
                        if (woli.ERP7__Quantity_Ordered__c >= 0) woliOldQuantityManu.put(woli.Id, woli.ERP7__Quantity_Ordered__c);     else woliOldQuantityManu.put(woli.Id, 0);
                        if (woli.ERP7__Version__c != Null) moliOldVersion.put(woli.Id, woli.ERP7__Version__c);
                        //else moliOldVersion.put(woli.Id,'');
                    }
                }
                for (ERP7__WO__c woli: System.Trigger.New) {
                    /*
                        Handles the deletion of MRPs if BOM version on soli is changed..
                        */
                    if (((moliOldVersion.containsKey(woli.Id) && String.valueof(woli.ERP7__Version__c) != moliOldVersion.get(woli.Id)) || moliOldQuantity.get(woli.Id) != woli.ERP7__Quantity_Ordered__c) && woliMrps.containsKey(woli.Id) && woliMrps.get(woli.Id).size() > 0) {  mrps2delete.addAll(woliMrps.get(woli.Id));  woliMrps.get(woli.Id).clear();   
                    }
                    if (woliMrps.get(woli.Id).size() == 0 && woliBOMS.containsKey(woli.Id)) {
                        for (ERP7__BOM__c bom: woliBOMS.get(woli.Id)) {
                            ERP7__MRP__c MRP = new ERP7__MRP__c();
                            if(Schema.sObjectType.ERP7__MRP__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Name.isUpdateable()){MRP.Name = BOM.Name; } else{/* no access*/}
                            //('BOM.ERP7__For_Multiples__c : '+BOM.ERP7__For_Multiples__c);
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){
                                if(BOM.ERP7__For_Multiples__c > 0 && BOM.ERP7__For_Multiples__c != null) MRP.ERP7__Total_Amount_Required__c = (BOM.Quantity__c * (Math.ceil(woli.ERP7__Quantity_Ordered__c/bom.ERP7__For_Multiples__c))).setscale(4);
                                else MRP.ERP7__Total_Amount_Required__c = (BOM.ERP7__Quantity__c != Null && woli.ERP7__Quantity_Ordered__c != Null)? (BOM.ERP7__Quantity__c * woli.ERP7__Quantity_Ordered__c).setscale(4) : 0;  
                            } else{/* no access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__BOM__c.isUpdateable()){MRP.ERP7__BOM__c = BOM.Id; } else{/* no access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__MRP_Product__c.isUpdateable()){MRP.ERP7__MRP_Product__c = BOM.ERP7__BOM_Component__c; } else{/* no access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Version__c.isUpdateable()){MRP.ERP7__Version__c = BOM.ERP7__BOM_Version__c; } else{/* no access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Order__c.isUpdateable()){MRP.ERP7__Work_Order__c = woli.Id;  } else{/* no access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Work_Center__c.isUpdateable()){MRP.ERP7__Work_Center__c = woli.ERP7__Work_Center__c;  } else{/* no access*/}
                            if(BOM.ERP7__Process_Cycle__r.ERP7__Process__c != Null) if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process__c.isUpdateable()){MRP.ERP7__Process__c = BOM.ERP7__Process_Cycle__r.ERP7__Process__c; } else{/* no access*/}
                            if(BOM.ERP7__Process_Cycle__c != Null) if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Process_Cycle__c.isUpdateable()){MRP.ERP7__Process_Cycle__c = BOM.ERP7__Process_Cycle__c;} else{/* no access*/}
                            if(BOM.ERP7__Minimum_Variance__c != Null) if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Minimum_Variance__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Minimum_Variance__c.isUpdateable()){system.debug('Inside WorkOrder 282 BOM.ERP7__Minimum_Variance__c :'+BOM.ERP7__Minimum_Variance__c+'woli.ERP7__Quantity_Ordered__c'+woli.ERP7__Quantity_Ordered__c);} else{/* no access*/}
                            if(BOM.ERP7__Minimum_Variance__c != Null) if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Minimum_Variance__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Minimum_Variance__c.isUpdateable()){MRP.ERP7__Minimum_Variance__c = (BOM.ERP7__Minimum_Variance__c * woli.ERP7__Quantity_Ordered__c).setscale(4);} else{/* no access*/}
                            if(BOM.ERP7__Maximum_Variance__c != Null) if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Maximum_Variance__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Maximum_Variance__c.isUpdateable()){MRP.ERP7__Maximum_Variance__c = (BOM.ERP7__Maximum_Variance__c * woli.ERP7__Quantity_Ordered__c).setscale(4);} else{/* no access*/}
                            if(BOM.ERP7__Routing_Link__c != null) if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Routing_Link__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Routing_Link__c.isUpdateable()){MRP.ERP7__Routing_Link__c = BOM.ERP7__Routing_Link__c;} else{/* no access*/}
                            if(BOM.ERP7__Operation__c != null && opATs.containsKey(BOM.ERP7__Operation__c)) if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Action_Task__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Action_Task__c.isUpdateable()){MRP.ERP7__Action_Task__c = opATs.get(BOM.ERP7__Operation__c);} else{/* no access*/}
                            
                            if(woli.MO__c != null)if(Schema.sObjectType.ERP7__MRP__c.fields.MO__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.MO__c.isUpdateable()){MRP.MO__c = woli.MO__c;} else{/* no access*/}
                            if(Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.RecordTypeId.isUpdateable()){
                                if (bom.RecordType.Name == 'Manufacturing BOM' && rTpe_MRPMAN != null){ MRP.RecordTypeId = rTpe_MRPMAN;}  else if (bom.RecordType.Name == 'Manufacturing BOM' && rTpe_MRPMAN != null){ MRP.RecordTypeId = rTpe_MRPMAN;}
                            } else{/* no access*/}
                            MRPS2Insert.add(MRP);
                        }
                    }
                    /*Handles the creation of stock inwards on quantity changed..*/
                    if (woli.ERP7__Quantity_Ordered__c > 0 && woliOldQuantityManu.get(woli.Id) != Null && woli.ERP7__Quantity_Ordered__c > woliOldQuantityManu.get(woli.Id)) {
                        ERP7__Inventory_Stock__c Stock = new Inventory_Stock__c();
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Active__c.isUpdateable()){Stock.Active__c = true;} else{/* no access*/} 
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = woli.Id;} else{/* no access*/} 
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isUpdateable()){Stock.Product__c = woli.ERP7__Product__c;} else{/* no access*/}  
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name = woli.Name; } else{/* no access*/} 
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Checked_In_Date__c.isUpdateable()){Stock.Checked_In_Date__c = system.today();} else{/* no access*/} 
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isUpdateable()){Stock.Warehouse__c = woli.ERP7__Site__c;} else{/* no access*/} 
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';} else{/* no access*/} 
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = woli.ERP7__Version__c;} else{/* no access*/} 
                        stocks2upsert.add(Stock);
                        //woliStockMap.put(woli.Id, Stock);
                        Stock_Inward_Line_Item__c SILI = new Stock_Inward_Line_Item__c();
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SILI.Name = woli.Name;}else{/* no access*/} 
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isUpdateable()){SILI.Active__c = true;}else{/*no access*/}
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isUpdateable()){SILI.Product__c = woli.ERP7__Product__c;}else{/*no access*/}
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isUpdateable()){SILI.Quantity__c = woli.ERP7__Quantity_Ordered__c - woliOldQuantityManu.get(woli.Id);}else{/*no access*/}
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SILI.ERP7__Work_Order__c = woli.Id;}else{/*no access*/}
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SILI.ERP7__Version__c = woli.ERP7__Version__c;}else{/*no access*/}
                        //stockInwards2upsert.add(SILI);
                    }
                }
                system.debug('MRPS2Insert Work order Trigger : '+MRPS2Insert.size());
                
                if (MRPS2Insert.size() > 0 && Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){ upsert MRPS2Insert; } else{ /* no access */ }
                
                if (mrps2delete.size() > 0) {
                    List < Id > mrpIds = new List < Id > ();
                    for (ERP7__MRP__c MRP: mrps2delete) mrpIds.add(MRP.Id);
                    List < ERP7__Stock_Outward_Line_Item__c > SDLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c,
                                                                       ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c,
                                                                       ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c
                                                                       From ERP7__Stock_Outward_Line_Item__c
                                                                       Where ERP7__MRP_Material_Requirements_Planning__c In: mrpIds
                                                                      ];
                    if (SDLIs.size() > 0 && Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()){ delete SDLIs; } else{ /* no access */}
                    if(ERP7__MRP__c.sObjectType.getDescribe().isDeletable()){ delete mrps2delete;  } else{ /* no access */ }
                }
                
                if (Trigger.IsUpdate && stocks2upsert.size() > 0 && stockInwards2upsert.size() > 0) {
                    system.debug('stocks2upsert : '+stocks2upsert.size());
                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isUpdateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Checked_In_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Product__c.isUpdateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Active__c.isUpdateable()){ upsert stocks2upsert; } else{ /* no access */}
                    for (ERP7__Stock_Inward_Line_Item__c SILI: stockInwards2upsert) if(woliStockMap.containsKey(SILI.ERP7__Work_Order__c) && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Site_ProductService_InventoryStock__c.isCreateable() || Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Site_ProductService_InventoryStock__c.isUpdateable()) {SILI.ERP7__Site_ProductService_InventoryStock__c = woliStockMap.get(SILI.ERP7__Work_Order__c).Id; } else{/*no access*/}
                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isUpdateable()){ upsert stockInwards2upsert; } else{ /* no access */ }
                }
                
                /* 
                Start ==> Create WIP Flows ...
                */
                
                if (Trigger.IsInsert || Trigger.IsUpdate) {
                    Boolean showVerbasedOnOrder = false;
                    Boolean createWIPFLowsInFuture = false;
                    ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
                    customList = ERP7__Functionality_Control__c.getValues(userInfo.getUserId());
                    if(customList == null){ 
                        customList = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                        if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
                    }
                    if(customList != null){
                        showVerbasedOnOrder=customList.ERP7__Show_Version_based_on_order_Product__c;
                        createWIPFLowsInFuture=customList.ERP7__Create_WIPFlows_In_Future__c;
                    }
                    
                    if(!System.isFuture() && !System.isBatch() && createWIPFLowsInFuture) {   MaintainBatchStocks.CreateWIPFlows(Trigger.newMap.KeySet());
                        /* calling future method based on custom settings - imran 11Sep23 */
                    }
                    else{
                        Set<Id> processCycleIds = new Set<Id>();
                        Set<Id> ManuIds = new Set<Id>();
                        Map<Id, List<ERP7__WIP_Link__c>> PCLinks = new Map<Id, List<ERP7__WIP_Link__c>>();
                        Map<Id, List<ERP7__WIP__c>> MOWIP = new Map<Id, List<ERP7__WIP__c>>();
                        List<ERP7__WIP_Flow__c> WIPFlows2insert = new List<ERP7__WIP_Flow__c>();
                        Set<Id> productIds = new Set<Id>();
                        
                        for (ERP7__WO__c WO: System.Trigger.New) {
                            if (WO.ERP7__Process_Cycle__c != Null && WO.ERP7__MO__c != Null) {
                                processCycleIds.add(WO.ERP7__Process_Cycle__c);
                                ManuIds.add(WO.ERP7__MO__c);
                            }
                            if (WO.ERP7__Product__c != Null) productIds.add(WO.ERP7__Product__c);
                        }
                        
                        List<ERP7__WIP__c> WIPs = [Select Id, Name, ERP7__Serial_Number__c, ERP7__MO__c, ERP7__Material_Batch_Lot__c, ERP7__Barcode__c, ERP7__Closed__c, ERP7__Quantity__c, ERP7__Scrapped_Quantity__c
                                                   From ERP7__WIP__c 
                                                   Where ERP7__MO__c In : ManuIds]; 
                        for(ERP7__WIP__c WIP : WIPs){
                            if (MOWIP.containskey(WIP.ERP7__MO__c)) {  MOWIP.get(WIP.ERP7__MO__c).add(WIP);
                            } else {
                                List < ERP7__WIP__c > myList = new List < ERP7__WIP__c > ();
                                myList.add(WIP);
                                MOWIP.put(WIP.ERP7__MO__c, myList);
                            }
                        }                                        
                        
                        List<ERP7__WIP_Link__c> WIPLinks = [Select Id, Name, ERP7__Process_Cycle__c, ERP7__Process_Output_Product__c, ERP7__Product__c, ERP7__Quantity_Unit__c, ERP7__Quantity_Unit_Of_Measure__c, 
                                                            ERP7__Type__c, ERP7__Finished_Products_Site__c, ERP7__Version__c, ERP7__Process_Output_Version__c, ERP7__Process_Output_Product__r.ERP7__Serialise__c, ERP7__Process_Output_Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c 
                                                            From ERP7__WIP_Link__c 
                                                            Where ERP7__Process_Cycle__c In : processCycleIds // And  ERP7__Type__c = 'Produced'
                                                            And  ERP7__Product__c  In : productIds]; 
                        
                        List<ERP7__WIP_Flow__c> ExistingWIPflows = [Select Id,Name from ERP7__WIP_Flow__c where ERP7__WIP__r.ERP7__MO__c In : ManuIds and ERP7__WIP__c IN :WIPs];
                        if(ExistingWIPflows.size() == 0){
                            for (ERP7__WIP_Link__c WL: WIPLinks) {
                                if (PCLinks.containskey(WL.ERP7__Process_Cycle__c)) {   PCLinks.get(WL.ERP7__Process_Cycle__c).add(WL);
                                } else {
                                    List < ERP7__WIP_Link__c > myList = new List < ERP7__WIP_Link__c > ();
                                    myList.add(WL);
                                    PCLinks.put(WL.ERP7__Process_Cycle__c, myList);
                                }
                            }
                            
                            
                            //WIP flows creation -
                            for (ERP7__WO__c WO: System.Trigger.New) {
                                if (WO.ERP7__Process_Cycle__c != Null && WO.ERP7__MO__c != Null && MOWIP.containsKey(WO.ERP7__MO__c) && PCLinks.containsKey(WO.ERP7__Process_Cycle__c)){
                                    for(ERP7__WIP__c WIP : MOWIP.get(WO.ERP7__MO__c)){
                                        for(ERP7__WIP_Link__c WIPLink : PCLinks.get(WO.ERP7__Process_Cycle__c)){
                                            if(WO.ERP7__Product__c == WIPLink.ERP7__Product__c && (showVerbasedOnOrder || WO.ERP7__Version__c == WIPLink.ERP7__Version__c) && WIPLink.ERP7__Quantity_Unit__c != Null && WO.ERP7__Quantity_Ordered__c != Null){
                                                system.debug('is  serial : '+WIPLink.ERP7__Process_Output_Product__r.ERP7__Serialise__c);
                                                system.debug('is  batch : '+WIPLink.ERP7__Process_Output_Product__r.ERP7__Lot_Tracked__c);
                                                if(WIPLink.ERP7__Process_Output_Product__r.ERP7__Serialise__c){
                                                    system.debug('Product is serial');
                                                    Decimal totalQty = WO.ERP7__Quantity_Ordered__c*WIPLink.ERP7__Quantity_Unit__c;
                                                    system.debug('totalQty : '+totalQty);
                                                    
                                                    ERP7__WIP_Flow__c WIPFlow = new ERP7__WIP_Flow__c();
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.Name.isCreateable()){ WIPFlow.Name = WIPLink.Name; }else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__WIP_Link__c.isCreateable()){WIPFlow.ERP7__WIP_Link__c = WIPLink.Id;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Product__c.isCreateable()){WIPFlow.ERP7__Product__c = WIPLink.ERP7__Process_Output_Product__c; }else{}
                                                    if(WO.ERP7__Start_Date__c != Null) if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Start_Date__c.isCreateable()){WIPFlow.ERP7__Start_Date__c = date.newinstance(WO.ERP7__Start_Date__c.year(), WO.ERP7__Start_Date__c.month(), WO.ERP7__Start_Date__c.day());}else{}
                                                    if(WO.ERP7__End_Date__c != Null) if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__End_Date__c.isCreateable()){WIPFlow.ERP7__End_Date__c = date.newinstance(WO.ERP7__End_Date__c.year(), WO.ERP7__End_Date__c.month(), WO.ERP7__End_Date__c.day()); }else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity__c.isCreateable()){WIPFlow.ERP7__Quantity__c = 0;}else{} // Changed the Qty to zero on 10/4/23 to handle the Build qty shown on the builderscreen
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Type__c.isCreateable()){
                                                        if(WIPLink.ERP7__Process_Output_Product__c != WO.ERP7__Product__c) WIPFlow.ERP7__Type__c = 'Processed';
                                                        else WIPFlow.ERP7__Type__c = WIPLink.ERP7__Type__c; 
                                                    }else{}
                                                    system.debug('WIPFlow.ERP7__Type__c : '+WIPFlow.ERP7__Type__c);
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Work_Orders__c.isCreateable()){WIPFlow.ERP7__Work_Orders__c = WO.Id;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity_Unit__c.isCreateable()){WIPFlow.ERP7__Quantity_Unit__c = WIPLink.ERP7__Quantity_Unit__c;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Finished_Products_Site__c.isCreateable()){WIPFlow.ERP7__Finished_Products_Site__c = WIPLink.ERP7__Finished_Products_Site__c;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity_Unit_Of_Measure__c.isCreateable()){WIPFlow.ERP7__Quantity_Unit_Of_Measure__c = WIPLink.ERP7__Quantity_Unit_Of_Measure__c;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Status__c.isCreateable()){WIPFlow.ERP7__Status__c = 'In Progress';}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__WIP__c.isCreateable()){WIPFlow.ERP7__WIP__c = WIP.Id;}else{}
                                                    if(WIPLink.ERP7__Process_Output_Version__c != Null) if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Version__c.isCreateable()){WIPFlow.ERP7__Version__c = WIPLink.ERP7__Process_Output_Version__c;}else{}
                                                    WIPFlows2insert.add(WIPFlow); 
                                                    
                                                    
                                                }
                                                else{ //(!WIPLink.ERP7__Process_Output_Product__r.ERP7__Serialise__c){
                                                    system.debug('in else');
                                                    ERP7__WIP_Flow__c WIPFlow = new ERP7__WIP_Flow__c();
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.Name.isCreateable()){WIPFlow.Name = WIPLink.Name; }else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__WIP_Link__c.isCreateable()){WIPFlow.ERP7__WIP_Link__c = WIPLink.Id;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Product__c.isCreateable()){WIPFlow.ERP7__Product__c = WIPLink.ERP7__Process_Output_Product__c; }else{}
                                                    if(WO.ERP7__Start_Date__c != Null) if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Start_Date__c.isCreateable()){WIPFlow.ERP7__Start_Date__c = date.newinstance(WO.ERP7__Start_Date__c.year(), WO.ERP7__Start_Date__c.month(), WO.ERP7__Start_Date__c.day());}else{}
                                                    if(WO.ERP7__End_Date__c != Null) if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__End_Date__c.isCreateable()){WIPFlow.ERP7__End_Date__c = date.newinstance(WO.ERP7__End_Date__c.year(), WO.ERP7__End_Date__c.month(), WO.ERP7__End_Date__c.day()); }else{}
                                                    //WIPFlow.ERP7__Quantity__c = (WIPLink.ERP7__Product__r.ERP7__Serialise__c)? (1*WIPLink.ERP7__Quantity_Unit__c) : (WO.ERP7__Quantity_Ordered__c * WIPLink.ERP7__Quantity_Unit__c);
                                                    //if(WIPLink.ERP7__Process_Output_Product__r.ERP7__Serialise__c)  WIPFlow.ERP7__Quantity__c = WO.ERP7__Quantity_Ordered__c * 1;
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity__c.isCreateable()){WIPFlow.ERP7__Quantity__c = 0;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Type__c.isCreateable()){WIPFlow.ERP7__Type__c = WIPLink.ERP7__Type__c; }else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Work_Orders__c.isCreateable()){WIPFlow.ERP7__Work_Orders__c = WO.Id;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity_Unit__c.isCreateable()){WIPFlow.ERP7__Quantity_Unit__c = WIPLink.ERP7__Quantity_Unit__c;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Finished_Products_Site__c.isCreateable()){WIPFlow.ERP7__Finished_Products_Site__c = WIPLink.ERP7__Finished_Products_Site__c;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity_Unit_Of_Measure__c.isCreateable()){WIPFlow.ERP7__Quantity_Unit_Of_Measure__c = WIPLink.ERP7__Quantity_Unit_Of_Measure__c;}else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Status__c.isCreateable()){WIPFlow.ERP7__Status__c = 'In Progress'; }else{}
                                                    if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__WIP__c.isCreateable()){WIPFlow.ERP7__WIP__c = WIP.Id; }else{}
                                                    if(WIPLink.ERP7__Process_Output_Version__c != Null) if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Version__c.isCreateable()){WIPFlow.ERP7__Version__c = WIPLink.ERP7__Process_Output_Version__c; }else{}
                                                    WIPFlows2insert.add(WIPFlow); 
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            system.debug('WIPFlows2insert.size() : '+WIPFlows2insert.size());
                            if (WIPFlows2insert.size() > 0 && Schema.sObjectType.ERP7__WIP_Flow__c.isCreateable()) { insert WIPFlows2insert; } else { } 
                        }
                    }
                } 
                
                system.debug('moIds.size() : '+moIds.size());
            }
        }
        //PreventRecursiveLedgerEntry.preventWOExecution = true;
        if (!PreventRecursiveLedgerEntry.testCasesTransactions) {    
            // Custom Roll up Start
            list<RollUpSummaryUtility.fieldDefinition> WOfieldDefinitionsLC = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity_Ordered__c', 'ERP7__WO_Quantity__c')
                    };
                        if (Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate || Trigger.IsUndelete)) {
                            RollUpSummaryUtility.rollUpTrigger(WOfieldDefinitionsLC, System.Trigger.New, 'ERP7__WO__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', ' And ERP7__Sales_Order_Line_Item__r.ERP7__Issue_Work_Order__c = true ');
                        } else if (Trigger.IsAfter) {  if (Trigger.IsDelete) { RollUpSummaryUtility.rollUpTrigger(WOfieldDefinitionsLC, System.Trigger.Old, 'ERP7__WO__c','ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', ' And ERP7__Sales_Order_Line_Item__r.ERP7__Issue_Work_Order__c = true ');
                            }
                        }
            // Custom Roll up End
        }
        
   
    //MO status update.
    if(Trigger.IsAfter && Trigger.IsUpdate){
        system.debug('triggered mo status update');
        system.debug('PreventRecursiveLedgerEntry.preventMOstatusChange : '+PreventRecursiveLedgerEntry.preventMOstatusChange);
        if(PreventRecursiveLedgerEntry.preventMOstatusChange){
            PreventRecursiveLedgerEntry.preventMOstatusChange = false;
            Integer i=0;
            String state = '';
            String stage = '';
            if(Trigger.old[i].ERP7__Status__c != Trigger.New[i].ERP7__Status__c && Trigger.new[i].ERP7__MO__c != null){
                ERP7__Manufacturing_Order__c mo = [SELECT Id, ERP7__Status__c,ERP7__Stage__c FROM ERP7__Manufacturing_Order__c WHERE Id =: Trigger.New[i].ERP7__MO__c LIMIT 1];
                List<ERP7__WO__c> wos = [SELECT Id, ERP7__Status__c,ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.Name,ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c,ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__r.Name FROM ERP7__WO__c WHERE ERP7__MO__c =: mo.Id LIMIT 9999];
                for(ERP7__WO__c wo : wos){
                    if(Trigger.New[i].Id == wo.Id){
                        if(wo.ERP7__Status__c == 'Complete'){
                            if(wo.ERP7__Process_Cycle__c != null && wo.ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c != null){
                                stage = wo.ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__r.Name;
                            }
                            else{
                                stage = wo.ERP7__Process_Cycle__r.Name;
                            }
                        }
                        else{
                          stage = wo.ERP7__Process_Cycle__r.Name;  
                        }
                    }
                    if(wo.ERP7__Status__c == 'Complete'){
                        if(state != 'Draft' && state != 'In Progress') state = 'Complete';
                        else state = 'In Progress';
                    }
                    else if(wo.ERP7__Status__c == 'Issued'){
                        if(state == 'Complete') state = 'In Progress';
                        else state = 'Draft';
                    }
                    else if(wo.ERP7__Status__c == 'In Progress'){
                        state = 'In Progress';
                        break;
                    }
                }
                System.debug('Stage : '+stage);
                if((state != '' && mo.ERP7__Status__c != state) || (stage != '' && stage != mo.ERP7__Stage__c)){
                    if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Status__c.isUpdateable()){mo.ERP7__Status__c = state;} else{ /* no access */ }
                    if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Stage__c.isUpdateable()){mo.ERP7__Stage__c = stage;} else{ /* no access */ }
                    if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){ update mo; } else{ /* no access */ }
                }
            }
            
        }
    }
    //MO status update.
    //
    }
}