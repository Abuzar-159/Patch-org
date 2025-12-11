/* changes on completetheWOandWIP method to move scrap inward and inventory creation to future methods */
public with sharing class BuildWorkOrder {
    @AuraEnabled
    public static comWrap getAll(String woId) {
        comWrap comW = new comWrap();

        try{
            String MOFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            String AllMOFields = MOFields + ',ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.ERP7__UoM__c, ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Routing__r.ERP7__Finished_Products_Site__r.Name, ERP7__Routing__r.ERP7__Process__c, ERP7__Product__r.QuantityUnitOfMeasure, ERP7__Manufacturing_Order__r.Name, ERP7__Routing__r.Name ';
            String WOFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            String AllWOFields = WOFields + ', ERP7__Product__r.Name, ERP7__Product__r.ERP7__UoM__c, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Routing__r.ERP7__Auto_Stock_Allocation__c, ERP7__Process_Cycle__r.ERP7__Previous_Process_Cycle__c, ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c, ERP7__Sales_Order__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Routing__r.Name, ERP7__Version__r.Name, ERP7__Product__r.QuantityUnitOfMeasure ';
            String TaskFields = 'Id,Name,ERP7__Status__c,ERP7__Barcode__c,ERP7__Type__c,ERP7__Auto_Clock_In__c,ERP7__Operation__c,ERP7__Work_Center__c,ERP7__Process_Cycle__c,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Finished_Quantity__c,ERP7__Reviewed_By__c,ERP7__Notes__c,ERP7__Action_Detail__c ';//UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');//toLabel(ERP7__Status__c)
            String AllTaskFields = TaskFields + ', ERP7__Work_Center__r.Name, ERP7__Work_Center__r.ERP7__Supervisor__c, ERP7__Work_Center__r.ERP7__Supervisor__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c, ERP7__Operation__r.ERP7__Sort__c, ERP7__Reviewed_By__r.Name ';
            String TSFields = UtilClass.selectStarFromSObject('ERP7__Timesheet__c');
            String AllTSFields = TSFields + '';
            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
            String AllWarehouseFields = WarehouseFields + '';

            Schema.DescribeFieldResult fieldResult1 = ERP7__WO__c.ERP7__Type__c.getDescribe();
            List < Schema.PicklistEntry > ple1 = fieldResult1.getPicklistValues();
            for(Schema.PicklistEntry f: ple1) {
                comW.Types.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            fieldResult1 = ERP7__WO__c.ERP7__Status__c.getDescribe();
            ple1 = fieldResult1.getPicklistValues();
            for(Schema.PicklistEntry f: ple1) {
                comW.Statuses.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            system.debug('1 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
            system.debug('Getting stuck here?woId: '+woId);
            if(woId != '' && woId != Null){
                 system.debug('Getting stuck here 1?');
                comW.WorkOrder = Database.query('SELECT '+String.escapeSingleQuotes(AllWOFields)+' , ERP7__Process_Cycle__r.ERP7__Enable_All_Tasks_Done__c,ERP7__MO__r.ERP7__Quantity__c,ERP7__Routing__r.ERP7__Max_Allowed_Cuts__c,ERP7__Work_Center__r.Name,ERP7__Routing__r.ERP7__Type__c,ERP7__Product__r.Description FROM WO__c WHERE Id = :woId Limit 1');
                system.debug('Getting stuck here 11?');
                String moId = comW.WorkOrder.ERP7__MO__c;
                String processId = comW.WorkOrder.ERP7__Process_Cycle__c;
                system.debug('Getting stuck here 12?');
                if(comW.WorkOrder.ERP7__Routing__r.ERP7__Type__c == 'Parallel' || comW.WorkOrder.ERP7__Routing__r.ERP7__Type__c == '') comW.executeParallel= true;  else{ comW.executeParallel= false;}
                system.debug('Getting stuck here 13?');
                comW.MaxCuts = (comW.WorkOrder.ERP7__Routing__r.ERP7__Max_Allowed_Cuts__c != null && comW.WorkOrder.ERP7__Routing__r.ERP7__Max_Allowed_Cuts__c > 0) ? (comW.WorkOrder.ERP7__Routing__r.ERP7__Max_Allowed_Cuts__c * comW.WorkOrder.ERP7__MO__r.ERP7__Quantity__c) : comW.WorkOrder.ERP7__MO__r.ERP7__Quantity__c;
                system.debug('Getting stuck here 14?');
                comW.manuOrders = (moId != Null && moId != '')? Database.query('SELECT '+String.escapeSingleQuotes(AllMOFields)+' FROM ERP7__Manufacturing_Order__c WHERE Id = :moId Limit 1') : new ERP7__Manufacturing_Order__c();
             system.debug('Getting stuck here 2?');
                List<ERP7__Actions_Tasks__c> acts= Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+', ERP7__Operation__r.ERP7__Routing_Link__c,ERP7__Operation__r.ERP7__Required__c FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :woId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
                //comW.TimeSheet = Database.query('SELECT '+AllTSFields+' FROM ERP7__Timesheet__c WHERE ERP7__Work_Order__c = :woId Limit 1');
                comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :woId Order BY CreatedDate Desc');
                comW.Tasks = acts;
                  system.debug('Getting stuck here 3?');
                  System.debug('actions size-->'+ acts.size());
                List<Note> allNotes  = new List<Note>();
                allNotes = [SELECT Id, Title, Body, CreatedDate, ParentId FROM Note where ParentId =:acts];
                Set<Id> operationIds = new Set<Id>();
                 Set<Id> taskIds = new Set<Id>();
                Map<Id, TaskWrapper> taskNotesMap = new Map<Id, TaskWrapper>();
                for (ERP7__Actions_Tasks__c task : acts) {
                    taskIds.add(task.Id);
                    taskNotesMap.put(task.Id, new TaskWrapper(task));
                    if(task.ERP7__Operation__c != Null) operationIds.add(task.ERP7__Operation__c);
                }

                for (Note note : allNotes) {                    if (taskNotesMap.containsKey(note.ParentId)) {                        taskNotesMap.get(note.ParentId).notesList.add(note);                    }               }

                comW.taskwrapList = new List<TaskWrapper>(taskNotesMap.values());
                 system.debug('Getting stuck here 4?');
                System.debug('comW.Allnotes-->'+ comW.Allnotes);

                List<ERP7__MRP__c> MRPs = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.ERP7__Unit_of_Measure__c, ERP7__BOM__r.Name,ERP7__BOM__r.ERP7__For_Multiples__c, ERP7__BOM__r.ERP7__BOM_Version__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ProductCode,ERP7__MRP_Product__r.ERP7__Vendor_product_Name__c,ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order__c, ERP7__Work_Order__r.Name, ERP7__Notes__c, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Scrap_Variant__c,
                                           ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__MO__r.ERP7__Version__c, ERP7__Fulfilled_Amount__c, ERP7__BOM__r.ERP7__Is_Protected__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__MRP_Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__Status__c, ERP7__Work_Order__r.ERP7__Raw_Materials_Site__c, ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                                           ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c,ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c, ERP7__MRP_Product__r.QuantityUnitOfMeasure, ERP7__BOM__r.ERP7__Product_Feature__r.Name, ERP7__BOM__r.ERP7__Product_Feature__c
                                           From ERP7__MRP__c
                                           Where ERP7__Work_Order__c = :woId Order By ERP7__BOM__r.ERP7__Sort__c ASC];
                List<ERP7__Stock_Outward_Line_Item__c> SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
                if(!comW.manuOrders.ERP7__Product__r.ERP7__Serialise__c){                    SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Date_of_Manufacture__c,  ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,                             ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name                             From Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c In: MRPs AND ERP7__MRP_Material_Requirements_Planning__c != null];                                   }

                List<ERP7__MRP__c> feature_MRPs = new List<ERP7__MRP__c>();
                for(ERP7__MRP__c MRP : MRPs) if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null) feature_MRPs.add(MRP);
                //for(ERP7__MRP__c MRP : MRPs) if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c == Null) feature_MRPs.add(MRP);
                if(feature_MRPs.size() > 0) MRPs = feature_MRPs;


                system.debug('3 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                Set<Id> proIds = new Set<Id>();
                Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
                for(MRP__c mrp : MRPS){
                    if(mrp.ERP7__MRP_Product__c != Null) proIds.add(mrp.ERP7__MRP_Product__c);
                }
                String selectedSite = comW.WorkOrder.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                String finishedProduct = comW.manuOrders.ERP7__Product__c;
                if(selectedSite != Null && selectedSite != ''){
                    for(AggregateResult result: [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock  FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c = :selectedSite
                                                 And (ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 And Name = 'Serial Stock Holder'))
                                                 and ERP7__Product__c IN:proIds GROUP BY ERP7__Product__c]){
                        Decimal myStock = 0;
                        Id ProdId = (Id)result.get('ERP7__Product__c');
                        if(stockMap.containsKey(ProdId)) myStock = stockMap.get(ProdId);
                        myStock +=(Decimal)result.get('totalStock');
                        stockMap.put(ProdId,myStock);
                    }
                }

                system.debug('4 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                List<mrpWrapBW> mrpWrapList = new List<mrpWrapBW>();
                for(Integer i=0; i<MRPs.size(); i++){
                    ERP7__MRP__c MRP = MRPs[i];
                    mrpWrapBW mrpWraper = new mrpWrapBW();

                    if((i == 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null) || (i > 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != MRPs[i-1].ERP7__BOM__r.ERP7__Product_Feature__c)){
                        if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null){
                            mrpWraper.Feature.Id = MRP.ERP7__BOM__r.ERP7__Product_Feature__c;
                            mrpWraper.Feature.Name = MRP.ERP7__BOM__r.ERP7__Product_Feature__r.Name;
                        }
                    }

                    mrpWraper.MRP = MRP;
                    if(stockMap.containsKey(MRP.ERP7__MRP_Product__c)) mrpWraper.Stock = stockMap.get(MRP.ERP7__MRP_Product__c);
                    if(mrpWraper.Stock == 0) mrpWraper.bgColor = 'red';
                    else if(mrpWraper.Stock > 0 && mrpWraper.Stock < mrpWraper.MRP.ERP7__Total_Amount_Required__c) mrpWraper.bgColor = 'orange';
                    else if(mrpWraper.Stock > 0 && mrpWraper.Stock >= mrpWraper.MRP.ERP7__Total_Amount_Required__c) {
                        mrpWraper.bgColor = 'green';
                        if(mrpWraper.MRP.ERP7__Fulfilled_Amount__c < mrpWraper.MRP.ERP7__Total_Amount_Required__c && mrpWraper.MRP.ERP7__Status__c == 'Requested') { comW.ReserveStock = true;}
                        //if(MRP.Status__c != 'Reserved') comW.ReserveStock = true;
                    }

                    if(MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c != Null) {
                        mrpWraper.SelectedUOM = MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                        mrpWraper.UOMS.add(new SelectOptions(mrpWraper.SelectedUOM, mrpWraper.SelectedUOM, true));
                        if(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure != mrpWraper.SelectedUOM) mrpWraper.UOMS.add(new SelectOptions(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure, MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure));
                    }

                    if(MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c != null){
                        String UOMS = MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c;
                        List<String> arr = UOMS.split(';');
                        for(String str : arr){
                            if(str != mrpWraper.SelectedUOM && str != MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure) mrpWraper.UOMS.add(new SelectOptions(str, str));
                        }
                    }
                     System.debug('SOLIs : '+SOLIs.size());
                    set<Id> batchIds = new set<Id>();
                    if(SOLIs.size() > 0){                        for(ERP7__Stock_Outward_Line_Item__c soli : SOLIs){                            if(MRP.Id == soli.ERP7__MRP_Material_Requirements_Planning__c){                                if(soli.ERP7__Material_Batch_Lot__c != Null  && !batchIds.contains(soli.ERP7__Material_Batch_Lot__c)) {  mrpWraper.Batches.add(new ERP7__Batch__c(Id=soli.ERP7__Material_Batch_Lot__c,Name=soli.ERP7__Material_Batch_Lot__r.Name)); batchIds.add(soli.ERP7__Material_Batch_Lot__c);}                            }                        }                    }
                    mrpWrapList.add(mrpWraper);
                }
                comW.MRPSSBW = mrpWrapList;
                mrpWrapList= new List<mrpWrapBW>();
                system.debug('5 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                if(comW.WorkOrder.ERP7__Routing__r.ERP7__Auto_Stock_Allocation__c == false) comW.ReserveStock = false;


                 Map<Id,List<ERP7__Guideline_Checklists__c>> Operationchecklists = new  Map<Id,List<ERP7__Guideline_Checklists__c>>();
                   system.debug('operationIds : '+operationIds.size());
                 if(processId != Null && processId != ''){
                    List<ERP7__Checklist__c> checktoassign = [Select Id,Name,ERP7__Action_Detail__c,ERP7__Process_Cycle__c,ERP7__Has_Checklist__c,ERP7__Comply__c,ERP7__Result__c,ERP7__Is_Mandatory__c,ERP7__Operation__c From ERP7__Checklist__c where ERP7__Process_Cycle__c = : processId and ERP7__Operation__c != null and ERP7__Operation__c IN : operationIds Order by CreatedDate asc];
                    List<ERP7__Guideline_Checklists__c> guidelinechecklists = [Select Id,Name ,ERP7__Checklist__c,ERP7__Checklist__r.ERP7__Comply__c,ERP7__Checklist__r.ERP7__Operation__c, ERP7__Instructions__c,ERP7__Is_Mandatory__c,ERP7__Action_Task__c from ERP7__Guideline_Checklists__c where (ERP7__Work_Orders__c =:woId AND ERP7__Checklist__c In :checktoassign) or ERP7__Action_Task__c IN :taskIds Order by CreatedDate asc];
                    system.debug('checktoassign : '+checktoassign.size());
                     Map<Id,ERP7__Guideline_Checklists__c> existingchecklist = new Map<Id,ERP7__Guideline_Checklists__c>();
                     for(ERP7__Guideline_Checklists__c guide :guidelinechecklists){                         existingchecklist.put(guide.ERP7__Checklist__c,guide);                     }

                     if(checktoassign.size() > 0){                        for(ERP7__Checklist__c csk : checktoassign){                        system.debug('csk.ERP7__Comply__c : '+csk.ERP7__Comply__c);                            ERP7__Guideline_Checklists__c guideCheck =existingchecklist.containskey(csk.Id) ? existingchecklist.get(csk.Id) : new ERP7__Guideline_Checklists__c(Name=(csk.ERP7__Comply__c != '' && csk.ERP7__Comply__c != '--None--') ? csk.ERP7__Comply__c : csk.Name,ERP7__Work_Orders__c = woId,ERP7__Checklist__c = csk.Id,ERP7__Checklist__r = new ERP7__Checklist__c(ERP7__Is_Mandatory__c = csk.ERP7__Is_Mandatory__c,ERP7__Comply__c = csk.ERP7__Comply__c,ERP7__Result__c = csk.ERP7__Result__c,ERP7__Operation__c = csk.ERP7__Operation__c),ERP7__Instructions__c = csk.ERP7__Has_Checklist__c ? csk.ERP7__Result__c : csk.ERP7__Action_Detail__c,ERP7__Is_Mandatory__c = csk.ERP7__Is_Mandatory__c);                                                       if(Operationchecklists.containskey(csk.ERP7__Operation__c)){                                Operationchecklists.get(csk.ERP7__Operation__c).add(guideCheck);                            }else{ Operationchecklists.put(csk.ERP7__Operation__c, new List<ERP7__Guideline_Checklists__c>{guideCheck});}                        }                    }
                    //if(checktoassign.size() > 0){ comW.checklist = checktoassign; }
                }
                system.debug('Operationchecklists : '+Operationchecklists.size());
                List<taskswrap> taskw = new List<taskswrap>();
                for(ERP7__Actions_Tasks__c AT : comW.Tasks){
                    taskIds.add(AT.Id);
                    if(AT.ERP7__Operation__c != Null) operationIds.add(AT.ERP7__Operation__c);
                    taskswrap twrap = new taskswrap();
                    twrap.Task = AT;
                    if(AT.ERP7__Operation__c != null) twrap.checklists = (Operationchecklists.containsKey(AT.ERP7__Operation__c) ? Operationchecklists.get(AT.ERP7__Operation__c) : null);                    else twrap.checklists = null;
                    taskw.add(twrap);
                }
                comW.tasklist = taskw;
                taskw = new List<taskswrap>();
                List<ERP7__Media__c> Media = [Select Id, Name, ERP7__Operation__c From ERP7__Media__c Where ERP7__Active__c = true And ERP7__Operation__c In :operationIds];
                List<Attachment> Attachs = [Select Id, Name, ParentId, Owner.Name, CreatedDate From Attachment Where ParentId In :Media Order By CreatedDate Asc];
                Map<Id, List<Attachment>> operationAttachs = new Map<Id, List<Attachment>>();
                Map<Id, ERP7__Operation__c> Operations = new Map<Id, ERP7__Operation__c>([Select Id, Name From ERP7__Operation__c Where Id In :operationIds]);
                for(Attachment Attach : Attachs){
                    for(ERP7__Media__c Med :Media){
                        if(Attach.ParentId == Med.Id){
                            if(operationAttachs.containskey(Med.ERP7__Operation__c)){
                                operationAttachs.get(Med.ERP7__Operation__c).add(Attach);
                            } else{
                                List<Attachment> myAttachs = new List<Attachment>();
                                myAttachs.add(Attach);
                                operationAttachs.put(Med.ERP7__Operation__c, myAttachs);
                            }
                            break;
                        }
                    }
                }
                system.debug('6 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                for(Id OperationId : operationIds){
                    OperationAttachments OAs = new OperationAttachments();
                    OAs.Operation = Operations.get(OperationId);
                    if(operationAttachs.containsKey(OperationId)) OAs.Attachments = operationAttachs.get(OperationId);
                    comW.OperationAttachmentsList.add(OAs);
                }
                Employees__c Employee = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                                         Organisation_Business_Unit__c
                                         From Employees__c
                                         Where Employee_User__c = : UserInfo.getUserId()
                                         Order by CreatedDate Asc Limit 1];
                comW.Employee = Employee;
                if(comW.Tasks.size() > 0) {
                    comW.SelectedTask = comW.Tasks[0];
                    List<ERP7__Time_Card_Entry__c> TCES =  [Select Id, Name, ERP7__Action_Task__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__Active__c From ERP7__Time_Card_Entry__c Where ERP7__Active__c = true And ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c = : UserInfo.getUserId() And ERP7__Start_Time__c <= Today And ERP7__End_Time__c = Null];
                    comW.Busy = (TCES.size() > 0)? true : false;
                    for(ERP7__Time_Card_Entry__c TCE : TCES){   if(TCE.ERP7__Action_Task__c == comW.SelectedTask.Id) {   comW.SelectedTask_TimeCardEntry = TCE; break; } }
                    if(comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Null && comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Employee.Id) comW.Permit = false;
                }
                set<id> checlistId = new set<id>();
                //String operationId = comW.SelectedTask.ERP7__Operation__c;


               /* for(ERP7__Checklist__c ch: comW.checklist) checlistId.add(ch.id);
                if(checlistId.size() > 0){  comW.guidelines = [Select Id,Name ,ERP7__Checklist__c, ERP7__Instructions__c,ERP7__Is_Mandatory__c,ERP7__Action_Task__c from ERP7__Guideline_Checklists__c where (ERP7__Work_Orders__c =:woId AND ERP7__Checklist__c In :checlistId) or ERP7__Action_Task__c = :comW.SelectedTask.Id Order by CreatedDate asc];
                                         }
                if(comW.guidelines.size() > 0){ comW.recordCreated = true;}*/
                for(OperationAttachments Atts: comW.OperationAttachmentsList){
                    for(Attachment Att: Atts.Attachments){
                        if(Att.Id != Null) {
                            comW.SelectedAttachment = Att;
                            break; break;
                        }
                    }
                }
                system.debug('7 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                comW.NewTask = new ERP7__Actions_Tasks__c();
                comW.SelectedAttachments = [Select Id, Name, ParentId, Owner.Name, CreatedDate From Attachment Where ParentId In :taskIds Order By CreatedDate Asc];
                comW.SelectedNotes = [Select Id, Title, Body,ParentId, Owner.Name, CreatedDate From Note Where ParentId In :taskIds Order By CreatedDate Asc];
                comW.NewTask.ERP7__Process__c = comW.manuOrders.ERP7__Routing__r.ERP7__Process__c;
                comW.NewTask.ERP7__Product__c = comW.WorkOrder.ERP7__Product__c;
                if(comW.manuOrders.Id != Null) comW.NewTask.ERP7__Manufacturing_Order__c = comW.manuOrders.Id;
                comW.NewTask.ERP7__Work_Order__c = comW.WorkOrder.Id;
                system.debug('8 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                if(moId != Null && moId != ''){
                    String querySN = 'select Id,Name,ERP7__Available__c,ERP7__Serial_Number__c,ERP7__Date_of_Manufacture__c,Barcode__c from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c = :moId limit 100';
                    comW.moSerialNos = Database.query(querySN);
                    comW.serialsLength= (Integer)[SELECT COUNT(Id) total FROM ERP7__Serial_Number__c WHERE ERP7__Manufacturing_Order__c  = :moId][0].get('total');

                    String queryBT = 'select Id,Name,ERP7__Date_of_Manufacture__c,ERP7__Barcode__c from ERP7__Batch__c where ERP7__Manufacturing_Order__c = :moId';
                    comW.moBatchNos = Database.query(queryBT);

                    comW.AllWOs = Database.query('SELECT '+String.escapeSingleQuotes(AllWOFields)+' FROM WO__c WHERE ERP7__MO__c = :moId ');

                    if(comW.executeParallel == false){
                        for(WO__c mwo : comW.AllWOs){
                            if(mwo.ERP7__Process_Cycle__c != Null && mwo.ERP7__Process_Cycle__c == comW.WorkOrder.ERP7__Process_Cycle__r.ERP7__Previous_Process_Cycle__c)  comW.prevWO = mwo.Id;
                            if(mwo.ERP7__Process_Cycle__c != Null && mwo.ERP7__Process_Cycle__c == comW.WorkOrder.ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c)  comW.nextWO = mwo.Id;
                        }
                        if(comW.prevWO != '' && comW.WorkOrder.Id != comW.prevWO){    ERP7__WO__c prevWOstatus = [Select Id,Name,ERP7__Status__c from ERP7__WO__c where Id=:comW.prevWO limit 1];        if(prevWOstatus.ERP7__Status__c != 'Complete') comW.errorMsg = 'Cannot start this process cycle bfr completing the previous';
                                                                                 }
                    }

                    String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP__c');
                    wpallFields += ' , ERP7__Material_Batch_Lot__r.Name, ERP7__Serial_Number__r.Name ';
                    String wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP__c where ERP7__MO__c = :moId';
                    comW.WIPs = Database.query(wpquery);

                    wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP_Flow__c');
                    wpallFields += ' , ERP7__Product__r.Name, ERP7__Product__r.ERP7__Width__c,ERP7__WIP__r.ERP7__Serial_Number__c,ERP7__WIP__r.ERP7__Serial_Number__r.Name,ERP7__WIP__r.ERP7__Serial_Number__r.ERP7__Serial_Number__c,ERP7__WIP__r.ERP7__Material_Batch_Lot__r.Name,ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c ,ERP7__Work_Orders__r.ERP7__Quantity_Scrapped__c,ERP7__Product__r.ERP7__UoM__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Product__r.ERP7__Grade__c,ERP7__Product__r.ERP7__Thickness__c,ERP7__Product__r.ERP7__Length__c';
                    wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP_Flow__c where ERP7__Work_Orders__c = :woId Order By ERP7__WIP__r.ERP7__Serial_Number__r.Name';
                    List<ERP7__WIP_Flow__c > wipflowlist = Database.query(wpquery);
                    for(ERP7__WIP_Flow__c wip : wipflowlist)  {
                        WIPFlowWrap wips = new WIPFlowWrap();
                        wips.wipFlow = wip;
                        wips.selected = false;
                        comW.WIPFlows.add(wips);
                    }
                    wipflowlist = new List<ERP7__WIP_Flow__c >();
                }
                system.debug('9 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());

                //RAs
                String wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Allocation__c');
                wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Employees__r.Name, ERP7__Machine__r.Name ';
                utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Allocation__c');
                String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Allocation__c Where ERP7__Work_Order__c = :woId Order by CreatedDate Asc limit 1000';
                List< ERP7__Resource_Allocation__c > RAS = Database.query(query);
                comW.RAS = RAS;
                RAS = new List< ERP7__Resource_Allocation__c >();
                // if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Active__c.isAccessible()){comW.rendertabs.add(true);}else{comW.rendertabs.add(false);}
                //if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Active__c.isAccessible()){comW.rendertabs.add(true);}else{comW.rendertabs.add(false);}
                //if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__End_Date__c.isAccessible()){comW.rendertabs.add(true);}else{comW.rendertabs.add(false);}
                comW.UOMCs = [Select MasterLabel, QualifiedApiName, DeveloperName, ERP7__From_UOM__c, ERP7__From_Value__c, ERP7__To_UOM__c, ERP7__To_Value__c FROM ERP7__UOM_Conversion__mdt limit 9999];

                if(comW.WorkOrder.ERP7__Work_Center__c != null){
                    wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Planner__c');
                    //wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Employees__r.Name, ERP7__Machine__r.Name ';
                    utilClass.FLSCheck(wcFields.split(','),'ERP7__Work_Planner__c');
                    String WC = comW.WorkOrder.ERP7__Work_Center__c;
                    query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Work_Planner__c Where ERP7__WorkCenter__c =: WC Order by CreatedDate Asc limit 1000';
                    List< ERP7__Work_Planner__c > WPS = Database.query(query);

                    wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Requirement__c');
                    wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Preferred_Resource__r.Name, ERP7__Preferred_Resource__r.ERP7__Employee__c, ERP7__Preferred_Resource__r.ERP7__Employee__r.Name, ERP7__Preferred_Resource__r.ERP7__Machine__c, ERP7__Preferred_Resource__r.ERP7__Machine__r.Name ';
                    utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Requirement__c');
                    query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Requirement__c Where ERP7__Work_Planner__c In :WPS Order by CreatedDate Asc limit 1000';
                    List< ERP7__Resource_Requirement__c > RRS = Database.query(query);

                    wcFields = UtilClass.selectStarFromSObject('ERP7__Capacity_Planner__c');
                    //wcFields += ', ERP7__Preferred_Resource__r.Name, ERP7__Preferred_Resource__r.ERP7__Employee__c, ERP7__Preferred_Resource__r.ERP7__Employee__r.Name, ERP7__Preferred_Resource__r.ERP7__Machine__c, ERP7__Preferred_Resource__r.ERP7__Machine__r.Name ';
                    query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Capacity_Planner__c Where ERP7__Work_Center__c  =: WC And ERP7__Start_Date__c <= Today And ERP7__End_Date__c >= Today Order by CreatedDate Desc limit 1';
                    List<ERP7__Capacity_Planner__c> CPS = Database.query(query);
                    if(CPS.size() > 0) comW.CapacityPlanner = CPS[0];

                    List<WorkPlanner> WorkPlanners = new List<WorkPlanner>();
                    for(ERP7__Work_Planner__c WP : WPS){
                        WorkPlanner WorkPlanner = new WorkPlanner();
                        WorkPlanner.WorkPlanner = WP;
                        comW.wpList.add(new SelectOptions(WP.Name, WP.Id));
                        for(ERP7__Resource_Requirement__c RR : RRS){
                            if(WP.Id == RR.ERP7__Work_Planner__c) WorkPlanner.RRS.add(RR);
                        }
                        if(comW.WorkPlanners.size() == 0) WorkPlanner.isSelect = true;
                        comW.WorkPlanners.add(WorkPlanner);
                    }
                }
                comW.Signatures = [Select Id, Name, ParentId, Owner.Name, CreatedDate From Attachment Where ParentId =: woId And Name = 'Signature' Order By CreatedDate Asc];
                List<Attachment> Attachments = [Select Id, Name, ParentId, Owner.Name, CreatedDate From Attachment Where ParentId =: woId And Name = 'Signature' Order By CreatedDate Asc];
                if(Attachments.size() > 0) comW.Attachment = Attachments[0];
                system.debug('10 Heap size is ' + limits.getHeapSize() + ' enforced is ' + limits.getLimitHeapSize());
                /* Visibility Control */
                ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
                if(FC == null){
                    FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
                    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();
                }
                if(FC != null){
                    if(FC.ERP7__Manufacturing_Builder_Show_Resources__c) { comW.rendertabs.add(true); } else{ comW.rendertabs.add(false); }
                    if(FC.ERP7__Manufacturing_Builder_Show_Time_Tracking__c) { comW.rendertabs.add(true);}else{ comW.rendertabs.add(false); }
                    if(FC.ERP7__Manufacturing_Builder_Show_Notes_Attach__c) { comW.rendertabs.add(true);}else{ comW.rendertabs.add(false); }
                    comW.ShowWorkCenter = FC.ERP7__Manufacturing_Builder_Show_Work_Center__c;
                    comW.linksNewOptions = FC.ERP7__Manufacturing_Builder_Links_New_Options__c;
                    comW.showAutoStockAllocation = FC.ERP7__WO_AutoStockAllocation__c;
                    comW.showManualStockAllocation = FC.ERP7__WO_ManualStockAllocation__c;
                    comW.showProdDesc = FC.ERP7__Manufacturing_Builder_Show_Description__c;
                    comW.EnterconsumeQtyAutomatical = FC.ERP7__Enter_Total_Consume_Quantity_automatical__c;
                    comW.ShowCustomSerailNumberGeneration = FC.ERP7__Show_Custom_generation_of_serial_numbers__c;
                    comW.byPassWOComplete = FC.ERP7__Bypass_WO_completion__c;
                    comW.showSearch = FC.ERP7__Show_search_in_WIP__c;
                    comW.showProducedSection = FC.ERP7__Show_produced_section_in_Build_MO__c;
                    comW.maxCutValidation = FC.ERP7__Add_Max_cuts_validation_in_MO__c;
                    comW.hideToProduceForOnlyMRP = FC.ERP7__HideToProduceorScrapinBuild__c;
                    comW.ShowProdStatus = FC.ERP7__Show_Production_Status_Traveller__c;
                    comW.showNotes = FC.ERP7__Add_Notes_Wo_Traveller__c;
                    comW.showVendorCode = FC.ERP7__Show_Vendor_Product_Code__c;
                    comW.showScrapDetails = FC.ERP7__Hide_Scrap_and_Waste_in_MO_and_WO__c;
                }
                FC = new ERP7__Functionality_Control__c();
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 1@ : '+ e.getLineNumber(); }    return comW;
    }
    public class searchWIP{
        @AuraEnabled public List<String> grades {get;set;}
        @AuraEnabled public List<String> thichkness {get;set;}
        @AuraEnabled public List<String> widths {get;set;}
        @AuraEnabled public List<String> lengths {get;set;}
        @AuraEnabled public  List<selectOptions> products {get;set;}
        public searchWIP(){
            grades = new List<String>();
            thichkness = new List<String>();
            products = new List<selectOptions>();
            widths = new List<String>();
            lengths = new List<String>();
        }
    }
    @AuraEnabled
    public static searchWIP getgradeandProducts(String woId){
        if(woId != '' && woId != Null){
            searchWIP serDetails = new searchWIP();
            List<ERP7__WIP_Flow__c > wipflowlist = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Width__c,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Grade__c,ERP7__Product__r.ERP7__Thickness__c,ERP7__Product__r.ERP7__Length__c,ERP7__Quantity__c,ERP7__Quantity_Scrapped__c,ERP7__Quantity_Ordered__c,ERP7__WIP__c from ERP7__WIP_Flow__c where ERP7__Work_Orders__c =:woId];
            set<String> gradeOptions = new set<String>();
            gradeOptions.add('--None--');
            set<String> widthOptions = new set<String>();
            widthOptions.add('--None--');
            List<selectOptions> productOptions = new List<selectOptions>();
            productOptions.add(new selectOptions('--None--','--None--'));
            set<String> thichknessOptions = new set<String>();
            thichknessOptions.add('--None--');
            set<String> lengthOptions = new set<String>();
            lengthOptions.add('--None--');
            for(ERP7__WIP_Flow__c wips : wipflowlist){
                if(wips.ERP7__Product__c != null){
                    if(wips.ERP7__Product__r.ERP7__Grade__c != null && wips.ERP7__Product__r.ERP7__Grade__c != ''){                        gradeOptions.add(wips.ERP7__Product__r.ERP7__Grade__c);                    }
                   if(wips.ERP7__Product__r.ERP7__Thickness__c != null && wips.ERP7__Product__r.ERP7__Thickness__c != 0){                        thichknessOptions.add(String.valueOf(wips.ERP7__Product__r.ERP7__Thickness__c));                    }
                    if(wips.ERP7__Product__r.ERP7__Width__c != null && wips.ERP7__Product__r.ERP7__Width__c != 0){
                        widthOptions.add(String.valueOf(wips.ERP7__Product__r.ERP7__Width__c));
                    }
                    if(wips.ERP7__Product__r.ERP7__Length__c != null && wips.ERP7__Product__r.ERP7__Length__c != 0){                       lengthOptions.add(String.valueOf(wips.ERP7__Product__r.ERP7__Length__c));
                   }
                    productOptions.add(new selectOptions(wips.ERP7__Product__r.Name,wips.ERP7__Product__c));
                }
            }
            if(gradeOptions != null && gradeOptions.size() > 0) serDetails.grades.addAll(gradeOptions);
            if(thichknessOptions != null && thichknessOptions.size() > 0) serDetails.thichkness.addAll(thichknessOptions);
            if(widthOptions != null && widthOptions.size() > 0) serDetails.widths.addAll(widthOptions);
            if(lengthOptions != null && lengthOptions.size() > 0) serDetails.lengths.addAll(lengthOptions);
            serDetails.products = productOptions;
            return serDetails;
        }
        return null;
    }
    @AuraEnabled
    public static comWrap SelectTasks(String task) {
        ERP7__Actions_Tasks__c tasks = (ERP7__Actions_Tasks__c) JSON.deserialize(task, ERP7__Actions_Tasks__c.class);
        comWrap comW = new comWrap();
        try{
            Employees__c Employee = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                                     Organisation_Business_Unit__c
                                     From Employees__c
                                     Where Employee_User__c = : UserInfo.getUserId()
                                     Order by CreatedDate Asc Limit 1];
            String TaskFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
            String AllTaskFields = TaskFields + ', ERP7__Work_Center__r.Name, ERP7__Work_Order__r.Project__c, ERP7__Work_Order__r.Name, ERP7__Work_Center__r.ERP7__Supervisor__c, ERP7__Work_Center__r.ERP7__Supervisor__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c ';
            String tId = Tasks.Id;
            comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId');
            List<ERP7__Time_Card_Entry__c> TCES =  [Select Id, Name, ERP7__Action_Task__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__Active__c From ERP7__Time_Card_Entry__c Where ERP7__Active__c = true And ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c = : UserInfo.getUserId() And ERP7__Start_Time__c <= Today And ERP7__End_Time__c = Null];
            comW.Busy = (TCES.size() > 0)? true : false;
            for(ERP7__Time_Card_Entry__c TCE : TCES){ if(TCE.ERP7__Action_Task__c == comW.SelectedTask.Id) {  comW.SelectedTask_TimeCardEntry = TCE;  break; }
                                                    }
            if(comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Null && comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Employee.Id)  comW.Permit = false;
            comW.MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__Fulfilled_Amount__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Picture__c,
                         ERP7__MRP_Product__r.ERP7__Preview_Image__c, ERP7__Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__Work_Order__c, Process_Cycle__c, ERP7__Notes__c,  ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                         ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name
                         From ERP7__MRP__c
                         Where Process_Cycle__c = : tasks.ERP7__Work_Order__r.ERP7__Process_Cycle__c And
                         ERP7__Action_Task__c =: tasks.Id And
                         ERP7__Work_Order__c = : tasks.ERP7__Work_Order__c  Order By ERP7__BOM__r.ERP7__Sort__c ASC];
            String operationId = comW.SelectedTask.ERP7__Operation__c;

            List<ERP7__Checklist__c> checktoassign = [Select Id,Name,ERP7__Action_Detail__c,ERP7__Process_Cycle__c,ERP7__Has_Checklist__c,ERP7__Comply__c,ERP7__Result__c,ERP7__Is_Mandatory__c,ERP7__Operation__c From ERP7__Checklist__c where ERP7__Operation__c =:operationId Order by CreatedDate asc]; //ERP7__Process_Cycle__c = : processId and
            if(checktoassign.size() > 0){ comW.checklist = checktoassign; }
            set<Id> checlistId =new set<Id>();
            for(ERP7__Checklist__c ch: comW.checklist) checlistId.add(ch.id);

            //if(checlistId.size() > 0){
            comW.guidelines = [Select Id, Name, ERP7__Checklist__c, ERP7__Instructions__c, ERP7__Is_Mandatory__c, ERP7__Action_Task__c from ERP7__Guideline_Checklists__c where ERP7__Action_Task__c = :comW.SelectedTask.Id Order by CreatedDate asc];
            // }

            if(comW.guidelines.size() > 0){ comW.recordCreated = true;} } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 2@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap StartTimeCardEntrys(String task) {
        String TSFields = UtilClass.selectStarFromSObject('ERP7__Timesheet__c');
        String AllTSFields = TSFields + '';
        ERP7__Actions_Tasks__c tasks = (ERP7__Actions_Tasks__c) JSON.deserialize(task, ERP7__Actions_Tasks__c.class);
        comWrap comW = new comWrap();
        try{
            Employees__c Employee = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                                     Organisation_Business_Unit__c
                                     From Employees__c
                                     Where Employee_User__c = : UserInfo.getUserId()
                                     Order by CreatedDate Asc Limit 1];
            comW.SelectedTask = tasks;
            String woId = comW.SelectedTask.ERP7__Work_Order__c;
            String empId = Employee.Id;
            ERP7__Timesheet__c TS;
            List<ERP7__Timesheet__c> TSs = Database.query('SELECT '+String.escapeSingleQuotes(AllTSFields)+' FROM ERP7__Timesheet__c WHERE ERP7__Work_Order__c = :woId And ERP7__Employees__c =: empId Limit 1');
            if(TSs.size() == 0 ){
                TS = new ERP7__Timesheet__c();
                if(Schema.sObjectType.ERP7__Timesheet__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.Name.isUpdateable()){TS.Name = comW.SelectedTask.ERP7__Work_Order__r.Name;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Employees__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Employees__c.isUpdateable()){TS.ERP7__Employees__c = Employee.Id;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Project__c.isUpdateable()){TS.ERP7__Project__c = comW.SelectedTask.ERP7__Work_Order__r.Project__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Status__c.isUpdateable()){TS.ERP7__Status__c = 'Draft';}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Work_Order__c.isUpdateable()){TS.ERP7__Work_Order__c = comW.SelectedTask.ERP7__Work_Order__c;}else{/*No access*/}
                if(Schema.SObjectType.ERP7__Timesheet__c.isCreateable() && Schema.SObjectType.ERP7__Timesheet__c.isUpdateable()){ upsert TS; }  else {/*No Access*/ } } else TS = TSs[0];
            ERP7__Time_Card_Entry__c TCE = new ERP7__Time_Card_Entry__c();
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.Name.isUpdateable()){TCE.Name = tasks.Name;}  else {/*No Access*/ }
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Action_Task__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Action_Task__c.isUpdateable()){TCE.ERP7__Action_Task__c = tasks.Id;}  else {/*No Access*/ }
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Active__c.isUpdateable()){TCE.ERP7__Active__c = true;}  else {/*No Access*/ }
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Project__c.isUpdateable()){TCE.ERP7__Project__c = TS.ERP7__Project__c;}  else {/*No Access*/ }
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Start_Time__c.isUpdateable()){TCE.ERP7__Start_Time__c = System.Now();}  else {/*No Access*/ }
            //TCE.ERP7__End_Time__c = Task.ERP7__Actual_End_Time__c;
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Status__c.isUpdateable()){TCE.ERP7__Status__c = 'Draft';}  else {/*No Access*/ }
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Timesheet__c.isCreateable()){TCE.ERP7__Timesheet__c = TS.Id;}  else {/*No Access*/ }
            if(Schema.SObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.SObjectType.ERP7__Time_Card_Entry__c.isUpdateable()){ upsert TCE;}  else {/*No Access*/ }

            comW.SelectedTask_TimeCardEntry = TCE;
            if(comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Null && comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Employee.Id)  comW.Permit = false;
            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            String TSId = TS.Id;
            comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :woId Order BY CreatedDate DESC'); } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 3@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap StopTimeCardEntrys(String task, String stce) {
        ERP7__Actions_Tasks__c tasks = (ERP7__Actions_Tasks__c) JSON.deserialize(task, ERP7__Actions_Tasks__c.class);
        ERP7__Time_Card_Entry__c TCE = (ERP7__Time_Card_Entry__c) JSON.deserialize(stce, ERP7__Time_Card_Entry__c.class);
        comWrap comW = new comWrap();
        try{
            Employees__c Employee = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                                     Organisation_Business_Unit__c
                                     From Employees__c
                                     Where Employee_User__c = : UserInfo.getUserId()
                                     Order by CreatedDate Asc Limit 1];
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isUpdateable()){TCE.ERP7__End_Time__c = system.Now();}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable()){ upsert TCE;}else{/*No access*/}

            comW.SelectedTask_TimeCardEntry = TCE;
            String woId = tasks.ERP7__Work_Order__c;
            List<ERP7__Time_Card_Entry__c> TCES =  [Select Id, Name, ERP7__Action_Task__c, ERP7__Start_Time__c, ERP7__End_Time__c, ERP7__Active__c From ERP7__Time_Card_Entry__c Where ERP7__Active__c = true And ERP7__Timesheet__r.ERP7__Employees__r.Employee_User__c = : UserInfo.getUserId() And ERP7__Start_Time__c <= Today And ERP7__End_Time__c = Null];
            comW.Busy = (TCES.size() > 0)? true : false;
            boolean found = false;
            for(ERP7__Time_Card_Entry__c TCEE : TCES){ if(TCEE.ERP7__Action_Task__c == comW.SelectedTask.Id) {   comW.SelectedTask_TimeCardEntry = TCEE;  found = true; break;
                                                                                                             }
                                                     }
            if(!found) comW.SelectedTask_TimeCardEntry = new ERP7__Time_Card_Entry__c();
            if(comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Null && comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Employee.Id)  comW.Permit = false;
            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :woId Order BY CreatedDate ASC'); } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 4@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap DeleteAction(Id tId) {
        comWrap comW = new comWrap();
        try{
            ERP7__Actions_Tasks__c AT = [Select Id, Name From ERP7__Actions_Tasks__c Where Id =:tId];
            if(ERP7__Actions_Tasks__c.sObjectType.getDescribe().isDeletable()){ delete AT; } else { } } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 5@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap SaveAction(String task) {

        ERP7__Actions_Tasks__c tasks = (ERP7__Actions_Tasks__c) JSON.deserializeStrict(task, ERP7__Actions_Tasks__c.class);
        comWrap comW = new comWrap();
        try{ if(Schema.SObjectType.ERP7__Actions_Tasks__c.isCreateable() && Schema.SObjectType.ERP7__Actions_Tasks__c.isUpdateable()){  upsert tasks; } else {/*No access*/ } } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 6@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap PreTaskFinish(String Task1) {
        ERP7__Actions_Tasks__c Task = (ERP7__Actions_Tasks__c) JSON.deserialize(Task1, ERP7__Actions_Tasks__c.class);
        comWrap comW = new comWrap();
        try{
            String SILIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');
            String AllSILIFields = SILIFields + '';
            if(Task.ERP7__Work_Order__r.ERP7__Process_Cycle__c != null) {

                if(Task.Process_Cycle__c != null){// && Task.ERP7__Routing_Link__c != null
                    for(ERP7__WIP_Link__c woWIPlinks: [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.Name FROM ERP7__WIP_Link__c WHERE ERP7__Process_Cycle__c =: Task.ERP7__Work_Order__r.ERP7__Process_Cycle__c]){     if(woWIPlinks.ERP7__Product__c != Task.ERP7__Product__c){ Product2 prod = new Product2();  prod.Id = woWIPlinks.ERP7__Product__c; prod.Name = woWIPlinks.ERP7__Product__r.Name; comW.WOproducts.add(prod);
                                                                                                                                                                                                                                                                                      }
                                                                                                                                                                                                                        }
                }
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 7@ : '+ e.getLineNumber(); }    return comW;
    }

    @AuraEnabled
    public static comWrap TaskUpdate(String Task1, String WO1, String MRPS1) {
        ERP7__Actions_Tasks__c Task = new ERP7__Actions_Tasks__c();
        ERP7__WO__c WO = new ERP7__WO__c();
        List<mrpWrap> MRPS = new List<mrpWrap>();
        List<ERP7__MRP__c> MRPSList = new List<ERP7__MRP__c>();
        if(Task1 != null) Task = (ERP7__Actions_Tasks__c) JSON.deserialize(Task1, ERP7__Actions_Tasks__c.class);
        if(WO1 != null) WO = (ERP7__WO__c) JSON.deserialize(WO1, ERP7__WO__c.class);
        if(MRPS1 != null) MRPS = (List<mrpWrap>) JSON.deserialize(MRPS1, List<mrpWrap>.class);
        for(mrpWrap mrp : MRPS){  MRPSList.add(mrp.MRP); }
        ERP7__Timesheet__c TS = new ERP7__Timesheet__c();
        comWrap comW = new comWrap();
        try{
            if(Task.ERP7__Status__c == 'In-Progress' && Task.ERP7__Start_Date__c == Null){ if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Start_Date__c.isUpdateable()){Task.ERP7__Start_Date__c = system.Now();}else{/*No access*/} }
            if(Task.ERP7__Status__c == 'In-Progress'){ if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Actual_Start_Time__c.isUpdateable()){Task.ERP7__Actual_Start_Time__c = system.Now();}else{/*No access*/} }
            if(Task.ERP7__Status__c == 'Completed' || Task.ERP7__Status__c == 'Cancelled') { if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__End_Date__c.isUpdateable()){Task.ERP7__End_Date__c = system.Now();}else{/*No access*/}   if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Actual_End_Time__c.isUpdateable()){Task.ERP7__Actual_End_Time__c = system.Now();}else{/*No access*/} }
            if(Task.ERP7__Status__c == 'On-Hold'){ if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Actual_End_Time__c.isUpdateable()){Task.ERP7__Actual_End_Time__c = system.Now();}else{/*No access*/} }
            if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){ update Task; } else{/*No access*/}
            if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){ update Task; } else{/*No access*/}

            String TaskFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
            String AllTaskFields = TaskFields + ', ERP7__Work_Center__r.Name, ERP7__Work_Order__r.Project__c, ERP7__Work_Order__r.Name, ERP7__Work_Center__r.ERP7__Supervisor__c, ERP7__Work_Center__r.ERP7__Supervisor__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c ';
            String tId = Task.Id;
            comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId');
            String TSFields = UtilClass.selectStarFromSObject('ERP7__Timesheet__c');
            String AllTSFields = TSFields + '';
            String woId = comW.SelectedTask.ERP7__Work_Order__c;

            List<Employees__c> empList = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                                          Organisation_Business_Unit__c
                                          From Employees__c
                                          Where Employee_User__c = : UserInfo.getUserId()
                                          Order by CreatedDate Asc Limit 1];

            String empId = empList[0].Id;
            List<ERP7__Timesheet__c> TSs = Database.query('SELECT '+String.escapeSingleQuotes(AllTSFields)+' FROM ERP7__Timesheet__c WHERE ERP7__Work_Order__c = :woId And ERP7__Employees__c =: empId Limit 1');
            if(TSs.size() == 0 ){
                TS = new ERP7__Timesheet__c();  if(Schema.sObjectType.ERP7__Timesheet__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.Name.isUpdateable()){TS.Name = comW.SelectedTask.ERP7__Work_Order__r.Name; }else{/*No access*/}                if(empList.size() > 0){ if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Employees__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Employees__c.isUpdateable()){TS.ERP7__Employees__c = empList[0].Id; }else{/*No access*/} }                if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Project__c.isUpdateable()){TS.ERP7__Project__c = comW.SelectedTask.ERP7__Work_Order__r.Project__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Status__c.isUpdateable()){TS.ERP7__Status__c = 'Draft';}else{/*No access*/}                if(Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Work_Order__c.isUpdateable()){TS.ERP7__Work_Order__c = comW.SelectedTask.ERP7__Work_Order__c; }else{/*No access*/}
                if(Schema.sObjectType.ERP7__Timesheet__c.isCreateable() && Schema.sObjectType.ERP7__Timesheet__c.isUpdateable()){ upsert TS; }else{/*No access*/}
            } else TS = TSs[0];

            if(Task.ERP7__Status__c == 'In-Progress' && Task.ERP7__Auto_Clock_In__c == true){   ERP7__Time_Card_Entry__c TCE = new ERP7__Time_Card_Entry__c(); if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.Name.isUpdateable()){TCE.Name = Task.Name; }else{/*No access*/}                if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Action_Task__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Action_Task__c.isUpdateable()){TCE.ERP7__Action_Task__c = Task.Id;}else{/*No access*/}                 if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Active__c.isUpdateable()){TCE.ERP7__Active__c = true; }else{/*No access*/}                if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Project__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Project__c.isUpdateable()){TCE.ERP7__Project__c = TS.ERP7__Project__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Start_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Start_Time__c.isUpdateable()){TCE.ERP7__Start_Time__c = Task.ERP7__Actual_Start_Time__c;}else{/*No access*/}          if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Status__c.isUpdateable()){TCE.ERP7__Status__c = 'Draft';}else{/*No access*/}                 if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__Timesheet__c.isCreateable()){TCE.ERP7__Timesheet__c = TS.Id;}else{/*No access*/}                                                                                             if(Schema.SObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.SObjectType.ERP7__Time_Card_Entry__c.isUpdateable()){upsert TCE;}else{/*No access*/}                                                                                                                                                                                          comW.SelectedTask_TimeCardEntry = TCE;    if(comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != Null && comW.SelectedTask.ERP7__Work_Center__r.ERP7__Supervisor__c != empList[0].Id)comW.Permit = false;                                                                                             }

            if(Task.ERP7__Status__c == 'Completed'){
                if(Task.ERP7__Work_Order__r.ERP7__Process_Cycle__c != null) {
                    comW.MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Picture__c, ERP7__MRP_Product__r.ERP7__Preview_Image__c,
                                 ERP7__Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, Process_Cycle__c, ERP7__Notes__c,  ERP7__Expected_Quantity__c,
                                 ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c,
                                 ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name
                                 From ERP7__MRP__c
                                 Where Process_Cycle__c = : Task.ERP7__Work_Order__r.ERP7__Process_Cycle__c And
                                 ERP7__MO__c = : Task.ERP7__Manufacturing_Order__c Order By ERP7__BOM__r.ERP7__Sort__c ASC];

                    /* List< ERP7__Stock_Outward_Line_Item__c > SILIs = [Select Id, Name, ERP7__Status__c,ERP7__Quantity__c From ERP7__Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c != Null And ERP7__MRP_Material_Requirements_Planning__c In :comW.MRPS];
for(ERP7__MRP__c mrp : comW.MRPS ){
for(ERP7__Stock_Outward_Line_Item__c SILI : SILIs) {
if(mrp.ERP7__Total_Amount_Required__c == SILI.ERP7__Quantity__c) SILI.ERP7__Status__c = 'Committed';
}
}
if(SILIs.size() > 0){
if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){ upsert SILIs; } else { }
} */
                }
                //comW.WorkOrder = WO;
                //update WO;
                if(Schema.SObjectType.ERP7__Actions_Tasks__c.isUpdateable()){ update comW.SelectedTask; } else {/*No access*/}
                //if(MRPSList != Null && MRPSList.size() > 0) update MRPSList;
            }

            if(Task.ERP7__Status__c == 'Completed' || Task.ERP7__Status__c == 'Cancelled' || Task.ERP7__Status__c == 'On-Hold') {
                List<ERP7__Time_Card_Entry__c> TCES = [Select Id, Name, ERP7__End_Time__c From ERP7__Time_Card_Entry__c Where ERP7__Action_Task__c =: Task.Id And ERP7__Active__c = true And ERP7__End_Time__c = Null];
                for(ERP7__Time_Card_Entry__c TCE : TCES){ if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isUpdateable()){TCE.ERP7__End_Time__c = Task.ERP7__Actual_End_Time__c;}else{/*No access*/} }
                if(TCES.size() > 0){
                    if(Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable()){upsert TCES;}else{/*No access*/}
                }
            }

            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            String TSId = TS.Id;
            comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :woId Order BY CreatedDate DESC');
            comW.Tasks = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :woId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
            set<Id> operationIds = new set<Id>();
            set<Id> taskIds = new set<Id>();
          string processId = Task.ERP7__Work_Order__r.ERP7__Process_Cycle__c;
            for(ERP7__Actions_Tasks__c act : comW.Tasks){
                operationIds.add(act.ERP7__Operation__c);
                taskIds.add(act.Id);
            }
            Map<Id,List<ERP7__Guideline_Checklists__c>> Operationchecklists = new  Map<Id,List<ERP7__Guideline_Checklists__c>>();
                   system.debug('operationIds : '+operationIds.size());
                 if(processId != Null && processId != ''){
                    List<ERP7__Checklist__c> checktoassign = [Select Id,Name,ERP7__Action_Detail__c,ERP7__Process_Cycle__c,ERP7__Has_Checklist__c,ERP7__Comply__c,ERP7__Result__c,ERP7__Is_Mandatory__c,ERP7__Operation__c From ERP7__Checklist__c where ERP7__Process_Cycle__c = : processId and ERP7__Operation__c != null and ERP7__Operation__c IN : operationIds Order by CreatedDate asc];
                    List<ERP7__Guideline_Checklists__c> guidelinechecklists = [Select Id,Name ,ERP7__Checklist__c,ERP7__Checklist__r.ERP7__Comply__c,ERP7__Checklist__r.ERP7__Operation__c, ERP7__Instructions__c,ERP7__Is_Mandatory__c,ERP7__Action_Task__c from ERP7__Guideline_Checklists__c where (ERP7__Work_Orders__c =:woId AND ERP7__Checklist__c In :checktoassign) or ERP7__Action_Task__c IN :taskIds Order by CreatedDate asc];
                    system.debug('checktoassign : '+checktoassign.size());
                     Map<Id,ERP7__Guideline_Checklists__c> existingchecklist = new Map<Id,ERP7__Guideline_Checklists__c>();
                     for(ERP7__Guideline_Checklists__c guide :guidelinechecklists){                         existingchecklist.put(guide.ERP7__Checklist__c,guide);                     }

                     if(checktoassign.size() > 0){                       for(ERP7__Checklist__c csk : checktoassign){                        system.debug('csk.ERP7__Comply__c : '+csk.ERP7__Comply__c);                            ERP7__Guideline_Checklists__c guideCheck =existingchecklist.containskey(csk.Id) ? existingchecklist.get(csk.Id) : new ERP7__Guideline_Checklists__c(Name=(csk.ERP7__Comply__c != '' && csk.ERP7__Comply__c != '--None--') ? csk.ERP7__Comply__c : csk.Name,ERP7__Work_Orders__c = woId,ERP7__Checklist__c = csk.Id,ERP7__Checklist__r = new ERP7__Checklist__c(ERP7__Is_Mandatory__c = csk.ERP7__Is_Mandatory__c,ERP7__Comply__c = csk.ERP7__Comply__c,ERP7__Result__c = csk.ERP7__Result__c,ERP7__Operation__c = csk.ERP7__Operation__c),ERP7__Instructions__c = csk.ERP7__Has_Checklist__c ? csk.ERP7__Result__c : csk.ERP7__Action_Detail__c,ERP7__Is_Mandatory__c = csk.ERP7__Is_Mandatory__c);                                                       if(Operationchecklists.containskey(csk.ERP7__Operation__c)){                                Operationchecklists.get(csk.ERP7__Operation__c).add(guideCheck);                            }else Operationchecklists.put(csk.ERP7__Operation__c, new List<ERP7__Guideline_Checklists__c>{guideCheck});                        }                    }
                    //if(checktoassign.size() > 0){ comW.checklist = checktoassign; }
                }
            List<taskswrap> tskwr = new List<taskswrap>();
            for(ERP7__Actions_Tasks__c act : comW.Tasks){
                taskswrap tskss = new taskswrap();
                tskss.Task = act;
                if(Operationchecklists.containskey(act.ERP7__Operation__c)) tskss.checklists = Operationchecklists.get(act.ERP7__Operation__c);
                else tskss.checklists = null;
                tskwr.add(tskss);
            }
            comW.tasklist = tskwr; } catch(Exception e) {   comW.errorMsg = e.getMessage() +' Line Number 8@ : '+ e.getLineNumber();
                                                         /*'Exception ~~>> '+e.getMessage() +' Line Number @ : '+ e.getLineNumber()*/
                                                        }
        return comW;
    }

    @AuraEnabled
    public static comWrap TaskUpdatePartial(String Task1,String  WO1, String MRPS1) {
        List < ERP7__MRP__c > MRPS = (List < ERP7__MRP__c > ) JSON.deserialize(MRPS1, List < ERP7__MRP__c > .class);
        ERP7__Actions_Tasks__c Task = (ERP7__Actions_Tasks__c) JSON.deserialize(Task1, ERP7__Actions_Tasks__c.class);
        ERP7__WO__c WO = (ERP7__WO__c) JSON.deserialize(WO1, ERP7__WO__c.class);
        ERP7__Timesheet__c TS = new ERP7__Timesheet__c();
        comWrap comW = new comWrap();
        try{
            String TaskFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
            String AllTaskFields = TaskFields + ', ERP7__Work_Center__r.Name, ERP7__Work_Order__r.Project__c, ERP7__Work_Order__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c ';
            String tId = Task.Id;
            comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId');
            if(Schema.SObjectType.ERP7__WO__c.isUpdateable()){ update WO; } else { }
            if(Schema.SObjectType.ERP7__MRP__c.isUpdateable()){ update MRPS; } else { }
            String woId = comW.SelectedTask.ERP7__Work_Order__c;
            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            String TSId = TS.Id;
            comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :woId Order BY CreatedDate DESC');
            comW.Tasks = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :woId Order By ERP7__Operation__r.ERP7__Sort__c ASC');    } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 9@ : '+ e.getLineNumber(); }
        return comW;
    }

    /* @AuraEnabled
public static comWrap completeSelectedWIPflow(String Task1,String WO1,String MRPSSS,String all_UOMs,String currentflow){
comWrap comW = new comWrap();
try{

List<mrpWrap> MRPSS = new List<mrpWrap>();

if(MRPSSS != null && MRPSSS != '') MRPSS = (List<mrpWrap>) JSON.deserialize(MRPSSS, List<mrpWrap>.class);

ERP7__WO__c WO = (ERP7__WO__c) JSON.deserialize(WO1, ERP7__WO__c.class);

ERP7__WIP_Flow__c wipflow = (ERP7__WIP_Flow__c) JSON.deserialize(currentflow, ERP7__WIP_Flow__c.class);

ERP7__Actions_Tasks__c Task = (ERP7__Actions_Tasks__c) JSON.deserialize(Task1, ERP7__Actions_Tasks__c.class);

if(Task.ERP7__Status__c == 'Completed') {
Task.ERP7__End_Date__c = system.Now();
Task.ERP7__Actual_End_Time__c = system.Now();
}
update Task;
String TaskFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
TaskFields += ', ERP7__Work_Center__r.Name, ERP7__Work_Order__r.Project__c, ERP7__Work_Order__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c ';
String tId = Task.Id;

comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(TaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
if(wipflow.ERP7__Product__c != WO.ERP7__Product__c){
wipflow.ERP7__Type__c= 'Processed';
}
update wipflow;

//if(wipflow.ERP7__Type__c == 'Produced' || wipflow.ERP7__Type__c == 'Processed') WO.ERP7__Quantity_Built__c = wipflow.ERP7__Quantity__c;
//else if(wipflow.ERP7__Type__c == 'Scrapped') WO.ERP7__Quantity_Scrapped__c = wipflow.ERP7__Quantity__c;

List<Id> mrpIds = new List<Id>();
List<ERP7__MRP__c> mrps2Update = new List<ERP7__MRP__c>();
for(mrpWrap MRPS: MRPSS){  mrps2Update.add(MRPS.MRP);  mrpIds.add(MRPS.MRP.Id); }
List<ERP7__Stock_Outward_Line_Item__c> Outwards = Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Process__c, ERP7__Product__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Status__c, ERP7__Work_Orders__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,  ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__MRP_Material_Requirements_Planning__c In :mrpIds');
Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c> StockInwardMap = new Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c>();
List<ERP7__Stock_Inward_Line_Item__c> SPLIs = new List<ERP7__Stock_Inward_Line_Item__c>();
List<ERP7__Inventory_Stock__c> Stocks = new List<ERP7__Inventory_Stock__c>();
List<ERP7__Stock_Outward_Line_Item__c> SOLIS2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();

for(mrpWrap MRPS: MRPSS){
comW.errorMsg = '';
Decimal stock2insert = MRPS.quantityToConsume + MRPS.quantityToScrap;

Decimal stock2Consume = MRPS.MRP.ERP7__Consumed_Quantity__c;

Decimal stock2Scrap = MRPS.quantityToScrap;

//start UOM Calc
List<ERP7__UOM_Conversion__mdt> allUOMCs = (List<ERP7__UOM_Conversion__mdt>) JSON.deserialize(all_UOMs, List<ERP7__UOM_Conversion__mdt>.class);

String prodUOM = MRPS.MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
String bomUOM  = MRPS.MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
if(prodUOM != null && prodUOM != '' && bomUOM != null && bomUOM != '' && bomUOM != prodUOM){
for(Integer k=0; k<allUOMCs.size(); k++){
if((allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM) || (allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM)){
//conversionFound = true;
comW.errorMsg = '';
if(allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM){
stock2Consume = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Consume;
stock2Scrap = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Scrap;
}
else if(allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM){
//stock2insert = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2insert;
stock2Consume = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Consume;
stock2Scrap = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Scrap;
}
else comW.errorMsg = 'UOM Conversion not found.';
break;
}

}
}
//end UOM Calc

for(ERP7__Stock_Outward_Line_Item__c SOLI : Outwards){
if(MRPS.MRP.Id == SOLI.ERP7__MRP_Material_Requirements_Planning__c && stock2insert > 0 && MRPS.MRP.ERP7__MRP_Product__c == SOLI.ERP7__Product__c){
ERP7__MRP__c MRP = MRPS.MRP;
if(stock2Scrap > 0){
Stock_Outward_Line_Item__c SDLI;
SDLI = new Stock_Outward_Line_Item__c(Name = MRP.Name, ERP7__Scrap__c = true, ERP7__Active__c = true,ERP7__Process__c = MRP.Process__c,Schedule__c = MRP.Schedule__c,ERP7__MRP_Material_Requirements_Planning__c = MRP.Id,ERP7__BoM__c = MRP.ERP7__BOM__c, ERP7__Status__c = 'Committed',ERP7__Product__c = MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = SOLI.ERP7__Site_Product_Service_Inventory_Stock__c,ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c);
if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c == 'Committed'){
Continue;
}
if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c != 'Committed'){// && MRPS.Lot_Serial == SOLI.ERP7__Serial__r.ERP7__Serial_Number__c
SDLI.Quantity__c = 1;//(SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= 1)?
SDLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;
SDLI.Id = SOLI.Id;
stock2Scrap = stock2Scrap - SOLI.Quantity__c;

//scrap inward.
ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c, ERP7__Work_Order__c = MRP.ERP7__Work_Order__c, ERP7__Active__c = true, Name=MRP.ERP7__Work_Order__r.Name, ERP7__Checked_In_Date__c=system.today(), ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Version__c = MRP.ERP7__Version__c, ERP7__Status__c = 'Checked In',ERP7__Scrap__c = true);
if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null) stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;
else stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;
Stock.ERP7__Serial__c = SOLI.ERP7__Serial__c;
ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c(ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c, ERP7__Work_Order__c = MRP.ERP7__Work_Order__c, Name = MRP.ERP7__Work_Order__r.Name, ERP7__Active__c = true, ERP7__Quantity__c = 1, ERP7__Unit_Price__c=0, ERP7__Version__c =  MRP.ERP7__Version__c,ERP7__Scrap__c = true);
if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null) SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;
else SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;
SPLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;
StockInwardMap.put(SPLI,Stock);
SPLIs.add(SPLI);
Stocks.add(Stock);
//scrap inward end.

}
else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true)){// && MRPS.Lot_Serial == SOLI.ERP7__Material_Batch_Lot__r.Name
SDLI.Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;
stock2Scrap = stock2Scrap - SDLI.Quantity__c;
SDLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;

//scrap inward.
ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c, ERP7__Work_Order__c = MRP.ERP7__Work_Order__c, ERP7__Active__c = true, Name=MRP.ERP7__Work_Order__r.Name, ERP7__Checked_In_Date__c=system.today(), ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Version__c = MRP.ERP7__Version__c, ERP7__Status__c = 'Checked In',ERP7__Scrap__c = true);
if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null) stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;
else stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;
Stock.ERP7__Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;
ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c(ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c, ERP7__Work_Order__c = MRP.ERP7__Work_Order__c, Name = MRP.ERP7__Work_Order__r.Name, ERP7__Active__c = true, ERP7__Quantity__c = SDLI.Quantity__c, ERP7__Unit_Price__c=0, ERP7__Version__c =  MRP.ERP7__Version__c,ERP7__Scrap__c = true);
if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null) SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;
else SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;
SPLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;
StockInwardMap.put(SPLI,Stock);
SPLIs.add(SPLI);
Stocks.add(Stock);
//scrap inward end.

}
else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {
SDLI.Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;
stock2Scrap = stock2Scrap - SDLI.Quantity__c;

//scrap inward.
ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c, ERP7__Work_Order__c = MRP.ERP7__Work_Order__c, ERP7__Active__c = true, Name=MRP.ERP7__Work_Order__r.Name, ERP7__Checked_In_Date__c=system.today(), ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c, ERP7__Version__c = MRP.ERP7__Version__c, ERP7__Status__c = 'Checked In',ERP7__Scrap__c = true);
if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null) stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;
else stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;
ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c(ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c, ERP7__Work_Order__c = MRP.ERP7__Work_Order__c, Name = MRP.ERP7__Work_Order__r.Name, ERP7__Active__c = true, ERP7__Quantity__c = SDLI.Quantity__c, ERP7__Unit_Price__c=0, ERP7__Version__c =  MRP.ERP7__Version__c,ERP7__Scrap__c = true);
if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null) SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;
else SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;
StockInwardMap.put(SPLI,Stock);
SPLIs.add(SPLI);
Stocks.add(Stock);
//scrap inward end.
}
if(MRP.BOM_Requirement_Cost__c != Null){
SDLI.Unit_Price__c = (MRP.Total_Amount_Required__c != Null && MRP.Total_Amount_Required__c > 0)? MRP.BOM_Requirement_Cost__c/MRP.Total_Amount_Required__c : 0;
SDLI.Total_Amount__c = SDLI.Unit_Price__c*SDLI.ERP7__Quantity__c;
SOLIS2Upsert.add(SDLI);
}
else SOLIS2Upsert.add(SDLI);
}
}

}
}
if((WO.ERP7__Quantity_Built__c + WO.ERP7__Quantity_Scrapped__c) == WO.ERP7__Quantity_Ordered__c) WO.ERP7__Status__c = 'Complete';

update WO;
comW.WorkOrder = WO;
if(mrps2Update.size() > 0){ update mrps2Update; }
update comW.SelectedTask;
if(SOLIS2Upsert.size() > 0){
upsert SOLIS2Upsert;
}
if(Stocks.size() > 0){
upsert Stocks;
}
for(ERP7__Stock_Inward_Line_Item__c inward : StockInwardMap.KeySet()){
String StockId = '', SerialId = '', BatchId = '';
StockId = StockInwardMap.get(inward).Id;
inward.ERP7__Site_ProductService_InventoryStock__c = StockId;
}
if(SPLIs.size() > 0) {
upsert SPLIs;
}
if(Task.ERP7__Status__c == 'Completed'){
List<ERP7__Time_Card_Entry__c> TCES = [Select Id, Name, ERP7__End_Time__c From ERP7__Time_Card_Entry__c Where ERP7__Action_Task__c =: Task.Id And ERP7__Active__c = true And ERP7__End_Time__c = Null];
for(ERP7__Time_Card_Entry__c TCE : TCES) TCE.ERP7__End_Time__c = Task.ERP7__Actual_End_Time__c;
if(TCES.size() > 0) { if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isUpdateable()){ upsert TCES; } else { } }
}
String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
String WoId = WO.Id;
comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :WoId Order BY CreatedDate DESC');
comW.Tasks = Database.query('SELECT '+String.escapeSingleQuotes(TaskFields)+' FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :WoId Order By ERP7__Operation__r.ERP7__Sort__c ASC');


}
catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
return comW;
}*/
    @AuraEnabled
    public static comWrap completeWIPflowandCreateInventory(String Task1,String WO1,String MRPSSS,String all_UOMs,String currentflow){
        comWrap comW = new comWrap();
        Savepoint sp = Database.setSavepoint();

        try{

            List<mrpWrap> MRPSS = new List<mrpWrap>();

            if(MRPSSS != null && MRPSSS != '') MRPSS = (List<mrpWrap>) JSON.deserialize(MRPSSS, List<mrpWrap>.class);

            ERP7__WO__c WO = (ERP7__WO__c) JSON.deserialize(WO1, ERP7__WO__c.class);
            System.debug('currentflow : '+currentflow);
           // System.debug('currentflow.expiry : '+currentflow.ERP7__Expiry_Date__c);
            ERP7__WIP_Flow__c wipflow = (ERP7__WIP_Flow__c) JSON.deserialize(currentflow, ERP7__WIP_Flow__c.class);
            System.debug('wipflow : '+wipflow);
            ERP7__Actions_Tasks__c Task = (ERP7__Actions_Tasks__c) JSON.deserialize(Task1, ERP7__Actions_Tasks__c.class);

            String WOId = WO.Id;
            List<ERP7__WIP_Flow__c> allwipFlows = [Select Id,Name,ERP7__Product__c,ERP7__Quantity__c,ERP7__Work_Orders__r.ERP7__Product__c,ERP7__Type__c,ERP7__Quantity_Ordered__c from ERP7__WIP_Flow__c where ERP7__Work_Orders__c =:WOId For Update];

            for(ERP7__WIP_Flow__c wip : allwipFlows){   if(wip.Id == wipflow.Id && wip.ERP7__Product__c == wipflow.ERP7__Product__c && wip.ERP7__Product__c != wip.ERP7__Work_Orders__r.ERP7__Product__c){ if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Type__c.isUpdateable()){wipflow.ERP7__Type__c = 'Processed';}else{/*No access*/} }
                                                        if(wip.Id == wipflow.Id && wipflow.ERP7__Quantity__c == wip.ERP7__Quantity_Ordered__c){ if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Status__c.isUpdateable()){wipflow.ERP7__Status__c = 'Completed';}else{/*No access*/} }
                                                       if(wipflow.ERP7__Expiry_Date__c != null) {
                                                            if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Expiry_Date__c.isUpdateable()) {
                                                                wipflow.ERP7__Expiry_Date__c = wipflow.ERP7__Expiry_Date__c;
                                                            } else {
                                                                System.debug('No access to update ERP7__Expiry_Date__c');
                                                            }
                                                        }
                                                    }

            if(Schema.sObjectType.ERP7__WIP_Flow__c.isCreateable() && Schema.sObjectType.ERP7__WIP_Flow__c.isUpdateable()){update wipflow;}else{comW.errorMsg = 'No access ! cannot update WIP flow!!';}
            Boolean iscompleted = false;
            Integer count=0;
            List<ERP7__WIP_Flow__c> allwipFlowsupdated = [Select Id,Name,ERP7__Product__c,ERP7__Status__c,ERP7__Quantity__c,ERP7__Work_Orders__r.ERP7__Product__c,ERP7__Type__c,ERP7__Quantity_Ordered__c from ERP7__WIP_Flow__c where ERP7__Work_Orders__c =:WOId];
            for(ERP7__WIP_Flow__c wip : allwipFlowsupdated){if(wip.ERP7__Quantity__c == wip.ERP7__Quantity_Ordered__c)  count= count+1;  }
            if(count == allwipFlowsupdated.size()) iscompleted = true;  else iscompleted = false;
            system.debug('iscompleted : '+iscompleted);
            //if(iscompleted){  if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isUpdateable()){WO.ERP7__Quantity_Built__c =  WO.ERP7__Quantity_Ordered__c;}else{/*No access*/} }
          //  system.debug('WO.ERP7__Quantity_Built__c : '+WO.ERP7__Quantity_Built__c);
            List<ERP7__Stock_Inward_Line_Item__c> wipstock = [Select Id,Name,ERP7__Product__c,ERP7__Serial__c,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Quantity__c,ERP7__WIP_Flow__c from ERP7__Stock_Inward_Line_Item__c where ERP7__WIP_Flow__c != null And ERP7__WIP_Flow__c =:wipflow.Id And ERP7__Active__c = : True and ERP7__Quantity__c > 0];

            List<ERP7__Stock_Inward_Line_Item__c> stock2update = new  List<ERP7__Stock_Inward_Line_Item__c>();
            /* for(ERP7__Stock_Inward_Line_Item__c stc : wipstock){
                system.debug('stc.Serial__c : '+stc.Serial__c);
                if(stc.ERP7__Product__c == wipflow.ERP7__Product__c && stc.ERP7__WIP_Flow__c == wipflow.Id && stc.ERP7__Quantity__c < wipflow.ERP7__Quantity__c){
                if(stc.ERP7__Product__r.ERP7__Lot_Tracked__c) {                             if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){stc.ERP7__Quantity__c = wipflow.ERP7__Quantity__c;}else{}        stock2update.add(stc);
                }
                else if(!stc.ERP7__Product__r.ERP7__Lot_Tracked__c && !stc.ERP7__Product__r.ERP7__Serialise__c){                          if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){stc.ERP7__Quantity__c = wipflow.ERP7__Quantity__c;}else{}    stock2update.add(stc);
                }
                }
                }
                */
            if(stock2update.size() > 0 && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isUpdateable()) {update stock2update;}else{/*No access*/}
          //  if((WO.ERP7__Quantity_Built__c + WO.ERP7__Quantity_Scrapped__c) == WO.ERP7__Quantity_Ordered__c){ if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Status__c.isUpdateable()){WO.ERP7__Status__c = 'Complete';}else{/*No access*/} }
            system.debug('WO.ERP7__Quantity_Built__c : '+WO.ERP7__Quantity_Built__c);
            system.debug('WO.ERP7__Quantity_Scrapped__c : '+WO.ERP7__Quantity_Scrapped__c);
            system.debug('WO.ERP7__Quantity_Ordered__c : '+WO.ERP7__Quantity_Ordered__c);
            if(Task.ERP7__Status__c == 'Completed') {
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__End_Date__c.isUpdateable()){Task.ERP7__End_Date__c = system.Now(); }else{/*No access*/}
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Actual_End_Time__c.isUpdateable()){Task.ERP7__Actual_End_Time__c = system.Now();}else{/*No access*/}
            }
            if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){update Task;}else{/*No access*/}
            List<Id> mrpIds = new List<Id>();
            List<ERP7__MRP__c> mrps2Update = new List<ERP7__MRP__c>();
            for(mrpWrap MRPS: MRPSS){  mrps2Update.add(MRPS.MRP);  mrpIds.add(MRPS.MRP.Id);
                                    }
            List<ERP7__Stock_Inward_Line_Item__c> Inwards = Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirement_Planning__c, ERP7__Product__c, ERP7__Process__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c  FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__MRP_Material_Requirement_Planning__c In :mrpIds');
            List<ERP7__Stock_Outward_Line_Item__c> Outwards = Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Process__c, ERP7__Product__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Status__c, ERP7__Work_Orders__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,  ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c,ERP7__Schedule__c,ERP7__MO_WO_Serial__c,ERP7__MO_WO_Material_Batch_Lot__c,Unit_Price__c,ERP7__Work_Order_Line_Items__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__MRP_Material_Requirements_Planning__c In :mrpIds and ERP7__Status__c = \'Reserved\'');

            //  Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Process__c, ERP7__Product__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Status__c, ERP7__Work_Orders__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,  ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__MRP_Material_Requirements_Planning__c In :mrpIds and ERP7__Status__c = \'Reserved\'');
            List<ERP7__Stock_Outward_Line_Item__c> SOLIS2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            Map<String,ERP7__Stock_Outward_Line_Item__c> SOLI2UpsertMap = new Map<String,ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Inventory_Stock__c> Stocks = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Stock_Inward_Line_Item__c> SPLIs = new List<ERP7__Stock_Inward_Line_Item__c>();
            Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c> StockInwardMap = new Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c>();
            Map<SoliWrapper, ERP7__Inventory_Stock__c> StockInwardMap2 = new Map<SoliWrapper, ERP7__Inventory_Stock__c>();
            Boolean InwardError = false;
            Boolean OutwardError = false;
            String TaskFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
            String AllTaskFields = TaskFields + ', ERP7__Work_Center__r.Name, ERP7__Work_Order__r.Project__c, ERP7__Work_Order__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c ';
            String tId = Task.Id;
             set<Id> SolisIds= new set<Id>();
             Decimal batchCounter=0,normalCounter=0;
            for(mrpWrap MRPS: MRPSS){
                if((MRPS.quantityToConsume + MRPS.quantityToScrap) > 0){
                    comW.errorMsg = '';       Decimal stock2insert = MRPS.quantityToConsume + MRPS.quantityToScrap;      Decimal stock2Consume = MRPS.quantityToConsume; /*MRPS.MRP.ERP7__Consumed_Quantity__c; */   Decimal stock2Scrap = MRPS.quantityToScrap;
                    system.debug('stock2insert : '+stock2insert);
                    //start UOM Calc
                    List<ERP7__UOM_Conversion__mdt> allUOMCs = (List<ERP7__UOM_Conversion__mdt>) JSON.deserialize(all_UOMs, List<ERP7__UOM_Conversion__mdt>.class);
                    String prodUOM = MRPS.MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;  String bomUOM  = MRPS.MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                    if(prodUOM != null && prodUOM != '' && bomUOM != null && bomUOM != '' && bomUOM != prodUOM){
                        for(Integer k=0; k<allUOMCs.size(); k++){
                            if((allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM) || (allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM)){
                                //conversionFound = true;
                                comW.errorMsg = '';
                                if(allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM){          stock2Consume = (allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c)*stock2Consume;        stock2Scrap = (allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c)*stock2Scrap;
                                                                                                             }
                                else if(allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM){                                    stock2Consume = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Consume;      stock2Scrap = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Scrap;
                               }                                else comW.errorMsg = 'UOM Conversion not found.';
                                break;
                            }

                        }
                    }
                    system.debug('stock2Consume : '+stock2Consume);

                    //end UOM Calc
                    //if(MRPS.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) stock2Scrap = 1;
                    for(ERP7__Stock_Inward_Line_Item__c SILI : Inwards){                       if(MRPS.MRP.Id == SILI.ERP7__MRP_Material_Requirement_Planning__c && stock2insert > 0 && MRPS.MRP.ERP7__MRP_Product__c == SILI.ERP7__Product__c){                            ERP7__MRP__c MRP = MRPS.MRP;                            Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c();    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){SDLI.Name = MRP.Name;}else{/*No access*/}     if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()){SDLI.Active__c = true;}else{/*No access*/}        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isUpdateable()){SDLI.Process__c = MRP.Process__c;}else{/*No access*/}     if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isUpdateable()){SDLI.Schedule__c = MRP.Schedule__c;}else{/*No access*/}             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isUpdateable()){SDLI.MRP_Material_Requirements_Planning__c = MRP.Id;}else{/*No access*/}         if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isUpdateable()){SDLI.BoM__c = MRP.BOM__c;}else{/*No access*/}          if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){SDLI.Status__c = 'Committed';}else{/*No access*/}                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()){SDLI.Product__c = MRP.MRP_Product__c;}else{/*No access*/}        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable()){SDLI.Site_Product_Service_Inventory_Stock__c = SILI.ERP7__Site_ProductService_InventoryStock__c;}else{/*No access*/}                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SDLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}                            if(MRP.BOM_Requirement_Cost__c != Null){if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = MRP.BOM_Requirement_Cost__c;}else{/*No access*/}     if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()){SDLI.Unit_Price__c = (MRP.Total_Amount_Required__c != Null && MRP.Total_Amount_Required__c > 0)? MRP.BOM_Requirement_Cost__c/MRP.Total_Amount_Required__c : 0;}else{/*No access*/}                            }                            if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && MRPS.Lot_Serial == SILI.ERP7__Serial__r.ERP7__Serial_Number__c){                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}                                stock2insert = stock2insert - SDLI.Quantity__c;  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SDLI.ERP7__Serial__c = SILI.ERP7__Serial__c;}else{/*No access*/} SOLIS2Upsert.add(SDLI);                                                            }                            else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true && MRPS.Lot_Serial == SILI.ERP7__Material_Batch_Lot__r.Name)){                                  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}                                stock2insert = stock2insert - SDLI.Quantity__c; if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SDLI.ERP7__Material_Batch_Lot__c = SILI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}                                SOLIS2Upsert.add(SDLI);                            }                            else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}                                stock2insert = stock2insert - SDLI.Quantity__c;  SOLIS2Upsert.add(SDLI);                            }                        }                   }
                    for(ERP7__Stock_Outward_Line_Item__c SOLI : Outwards){
                        if(MRPS.MRP.Id == SOLI.ERP7__MRP_Material_Requirements_Planning__c && stock2insert > 0 && MRPS.MRP.ERP7__MRP_Product__c == SOLI.ERP7__Product__c){
                            ERP7__MRP__c MRP = MRPS.MRP;
                            system.debug('MRP.ERP7__Consumed_Quantity__c : '+MRP.ERP7__Consumed_Quantity__c);
                            system.debug('MRP.ERP7__Scrapped_Quantity__c : '+MRP.ERP7__Scrapped_Quantity__c);
                            system.debug('MRP.ERP7__Fulfilled_Amount__c : '+MRP.ERP7__Fulfilled_Amount__c);
                            if(stock2Scrap > 0){
                                if(SOLI.ERP7__Quantity__c <= stock2Scrap){
                                    stock2Scrap = stock2Scrap -  SOLI.ERP7__Quantity__c;
                                    system.debug('stock2Scrap if: '+stock2Scrap);
                                    SOLI.ERP7__Status__c = 'Committed';
                                    SOLI.ERP7__Scrap__c = true;
                                    if(MRP.BOM_Requirement_Cost__c != Null){
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SOLI.Total_Amount__c = SOLI.Unit_Price__c*SOLI.ERP7__Quantity__c;}else{/*No access*/}
                                    }
                                    //scrap inventory
                                    ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c();
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}
                                    if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                    else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isUpdateable()){Stock.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()){Stock.ERP7__Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}

                                    ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c ;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}
                                    //if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                    if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                    else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SPLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                    system.debug('SPLI.ERP7__Serial__c build1: '+SPLI.ERP7__Serial__c);
                                    if(MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true ){
                                      //  ERP7__Stock_Inward_Line_Item__c.ERP7__Notes__c= 'b'+batchCounter; batchCounter++;
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'b'+batchCounter;}batchCounter++;
                                    }else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true){
                                      //  ERP7__Stock_Inward_Line_Item__c.ERP7__Notes__c = 'n'+normalCounter;  normalCounter++;
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'n'+normalCounter;}normalCounter++;
                                    }
                                    StockInwardMap.put(SPLI,Stock);          SPLIs.add(SPLI);       Stocks.add(Stock); // StockInwardMap2.put(new SoliWrapper(SPLI),Stock);
                                    SOLIS2Upsert.add(SOLI);
                                }
                                else{
                                    if(SOLI.ERP7__Quantity__c >= stock2Scrap){
                                        SOLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c - stock2Scrap;
                                    }
                                    system.debug('SOLI.ERP7__Quantity__c after: '+SOLI.ERP7__Quantity__c);
                                    if(MRP.BOM_Requirement_Cost__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SOLI.Total_Amount__c = SOLI.Unit_Price__c*SOLI.ERP7__Quantity__c;}else{/*No access*/} }
                                    if(SOLI.ERP7__Status__c != 'Committed'){ SOLIS2Upsert.add(SOLI); }
                                    system.debug('SOLIS2Upsert 8: '+SOLIS2Upsert.size());
                                    Stock_Outward_Line_Item__c SDLI;  SDLI = new Stock_Outward_Line_Item__c();      if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){SDLI.Name = MRP.Name;}else{/*No access*/}               if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SDLI.ERP7__Scrap__c = true;}else{/*No access*/}             if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SDLI.ERP7__Active__c = true;}else{/*No access*/}   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Process__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Process__c.isUpdateable()){SDLI.ERP7__Process__c = MRP.Process__c;}else{/*No access*/}                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isUpdateable()){SDLI.Schedule__c = MRP.Schedule__c;}else{/*No access*/}              if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isUpdateable()){SDLI.ERP7__MRP_Material_Requirements_Planning__c = MRP.Id;}else{/*No access*/}            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isUpdateable()){SDLI.ERP7__BoM__c = MRP.ERP7__BOM__c;}else{/*No access*/}          if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){       SDLI.ERP7__Status__c = 'Committed';         }else{/*No access*/}            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SDLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/}                      if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){SDLI.ERP7__Site_Product_Service_Inventory_Stock__c = SOLI.ERP7__Site_Product_Service_Inventory_Stock__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SDLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}
                                    if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c == 'Committed'){    Continue;
                                                                                                                                  }
                                    if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c != 'Committed'){// && MRPS.Lot_Serial == SOLI.ERP7__Serial__r.ERP7__Serial_Number__c
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = 1;}else{/*No access*/}//(SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= 1)?
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SDLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                        // SDLI.Id = SOLI.Id;
                                        stock2Scrap = stock2Scrap - SOLI.Quantity__c;

                                        //scrap inward.
                                        ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c();  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}
                                        //if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                        if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                        else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isUpdateable()){Stock.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}

                                        ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Quantity__c = 1;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}
                                        //if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                        if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                        else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SPLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SPLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                                        system.debug('SPLI.ERP7__Serial__c build1 if: '+SPLI.ERP7__Serial__c);
                                        StockInwardMap.put(SPLI,Stock);          SPLIs.add(SPLI);       Stocks.add(Stock);//StockInwardMap2.put(new SoliWrapper(SPLI),Stock);
                                        //scrap inward end.

                                    }
                                    else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true)){// && MRPS.Lot_Serial == SOLI.ERP7__Material_Batch_Lot__r.Name
                                        System.debug('stock2Scrap : '+stock2Scrap);
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                        stock2Scrap = stock2Scrap - SDLI.Quantity__c;
                                        System.debug('SDLI.Quantity__c : '+SDLI.Quantity__c);
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SDLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}

                                        //scrap inward.
                                        ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(); if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}
                                        //if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                        if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null) { if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                        else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()){Stock.ERP7__Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}

                                        ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = SDLI.Quantity__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}
                                        // if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}

                                        if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                        else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SPLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'b'+batchCounter;}batchCounter++;
                                        StockInwardMap.put(SPLI,Stock);          SPLIs.add(SPLI);     Stocks.add(Stock);// StockInwardMap2.put(new SoliWrapper(SPLI),Stock);
                                        //scrap inward end.

                                    }
                                    else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                        stock2Scrap = stock2Scrap - SDLI.Quantity__c;

                                        //scrap inward.
                                        ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c();  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}
                                        // if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/}
                                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                        if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                        else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }

                                        ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c(); if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = SDLI.Quantity__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                        // if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}
                                        if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                        else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                        if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'n'+normalCounter;}normalCounter++;
                                        StockInwardMap.put(SPLI,Stock);                          SPLIs.add(SPLI);    Stocks.add(Stock);// StockInwardMap2.put(new SoliWrapper(SPLI),Stock);
                                        //scrap inward end.
                                    }


                                    if(MRP.BOM_Requirement_Cost__c != Null){
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()){SDLI.Unit_Price__c = (MRP.Total_Amount_Required__c != Null && MRP.Total_Amount_Required__c > 0)? MRP.BOM_Requirement_Cost__c/MRP.Total_Amount_Required__c : 0;}else{/*No access*/}
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = SDLI.Unit_Price__c*SDLI.ERP7__Quantity__c;}else{/*No access*/}
                                        SOLIS2Upsert.add(SDLI);
                                    }
                                    else SOLIS2Upsert.add(SDLI);
                                    system.debug('SOLIS2Upsert 9: '+SOLIS2Upsert.size());
                                }

                            }
                            system.debug('stock2Consume :'+stock2Consume );
                            if (stock2Consume > 0){
                                system.debug('SOLI.ERP7__Quantity__c : '+SOLI.ERP7__Quantity__c);
                                if(SOLI.ERP7__Quantity__c <= stock2Consume){
                                    stock2Consume = stock2Consume -  SOLI.ERP7__Quantity__c;
                                    system.debug('stock2Consume if: '+stock2Consume);
                                    SOLI.ERP7__Status__c = 'Committed';
                                     if(MRP.BOM_Requirement_Cost__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SOLI.Total_Amount__c = SOLI.Unit_Price__c*SOLI.ERP7__Quantity__c;}else{/*No access*/} }
                                    SOLIS2Upsert.add(SOLI);
                                }
                                else{
                                    system.debug('SOLI.ERP7__Quantity__c bfr else: '+SOLI.ERP7__Quantity__c);
                                system.debug('stock2Consume');
                                if(SOLI.ERP7__Quantity__c > stock2Consume){         SOLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c - stock2Consume;         }
                                system.debug('SOLI.ERP7__Quantity__c after: '+SOLI.ERP7__Quantity__c);
                                if(MRP.BOM_Requirement_Cost__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SOLI.Total_Amount__c = SOLI.Unit_Price__c*SOLI.ERP7__Quantity__c;}else{/*No access*/} }
                                SOLIS2Upsert.add(SOLI);
                                Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();         pplis.Name = SOLI.Name;    pplis.ERP7__Active__c = true;         pplis.ERP7__Process__c = SOLI.ERP7__Process__c;                             pplis.ERP7__Schedule__c = SOLI.ERP7__Schedule__c;        pplis.ERP7__MRP_Material_Requirements_Planning__c = SOLI.ERP7__MRP_Material_Requirements_Planning__c;         pplis.ERP7__BoM__c = SOLI.ERP7__BoM__c;        pplis.ERP7__Status__c = 'Committed';     pplis.ERP7__Product__c = SOLI.ERP7__Product__c;                 pplis.ERP7__Site_Product_Service_Inventory_Stock__c = SOLI.ERP7__Site_Product_Service_Inventory_Stock__c;             pplis.ERP7__Version__c = SOLI.ERP7__Version__c;              pplis.ERP7__Quantity__c = stock2Consume;
                                system.debug('pplis.ERP7__Quantity__c after: '+pplis.ERP7__Quantity__c);              pplis.ERP7__MO_WO_Serial__c = SOLI.ERP7__MO_WO_Serial__c;                      pplis.ERP7__MO_WO_Material_Batch_Lot__c = SOLI.ERP7__MO_WO_Material_Batch_Lot__c;                   pplis.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;                        pplis.ERP7__Serial__c = SOLI.ERP7__Serial__c;         if(SOLI.Unit_Price__c != null) {pplis.Total_Amount__c = (SOLI.Unit_Price__c > 0) ? (pplis.ERP7__Quantity__c * SOLI.Unit_Price__c) : 0;}                      pplis.ERP7__Work_Orders__c = SOLI.ERP7__Work_Orders__c;                 pplis.ERP7__Work_Order_Line_Items__c = SOLI.ERP7__Work_Order_Line_Items__c;          pplis.ERP7__Manufacturing_Order__c = SOLI.ERP7__Manufacturing_Order__c;
                                SOLIS2Upsert.add(pplis);
                                }


                            }
                        }
                    }

                    //  }
                }
            }
            system.debug('SOLIS2Upsert : '+SOLIS2Upsert.size());
            if(!InwardError && !OutwardError){
                comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
                // if(updateqty) WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Ordered__c;

                if(Schema.sObjectType.ERP7__WO__c.isUpdateable()){update WO;} else {/*No access*/}
                comW.WorkOrder = WO;
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){update comW.SelectedTask;} else {/*No access*/}
                if(mrps2Update.size() > 0){
                    // For loop added on 10/4/2023 to change the status to committed
                    for(ERP7__MRP__c mrp : mrps2Update){       if((mrp.ERP7__Consumed_Quantity__c + mrp.ERP7__Scrapped_Quantity__c) == mrp.ERP7__Total_Amount_Required__c) mrp.ERP7__Status__c = 'Committed';
                    }
                    if(Schema.SObjectType.ERP7__MRP__c.isUpdateable()){ update mrps2Update; } else {/*No access*/}
                }

                if(SOLIS2Upsert.size() > 0){                    Integer i = 1;                    for(Stock_Outward_Line_Item__c soli : SOLIS2Upsert){                        if(soli.Id != null && !SOLI2UpsertMap.containsKey(soli.Id)){                            SOLI2UpsertMap.put(soli.Id,soli);                        }                        else if(soli.Id == null) {                            SOLI2UpsertMap.put(String.valueOf(i),soli); i++;                        }                    }                    if(Schema.SObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.SObjectType.Stock_Outward_Line_Item__c.isUpdateable()){ upsert SOLI2UpsertMap.Values(); } else {/*No access*/}                 }

                if(Stocks.size() > 0){         if(Schema.sObjectType.ERP7__Inventory_Stock__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.isUpdateable()){ upsert Stocks; }else {/*No access*/}
                }

                for(ERP7__Stock_Inward_Line_Item__c inward : StockInwardMap.KeySet()){                   String StockId = '', SerialId = '', BatchId = '';       StockId = StockInwardMap.get(inward).Id;                                       if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Site_ProductService_InventoryStock__c.isCreateable()){inward.ERP7__Site_ProductService_InventoryStock__c = StockId;}else{/*No access*/}                }
                List<ERP7__Stock_Inward_Line_Item__c> newSplis=new List<ERP7__Stock_Inward_Line_Item__c>();
                for(ERP7__Stock_Inward_Line_Item__c soli:SPLIs){
					system.debug('inventory in soli '+soli.ERP7__Site_ProductService_InventoryStock__c);
				}
                system.debug('StockInwardMap size  '+StockInwardMap.size());
                system.debug('StockInwardMap2 size  '+StockInwardMap2.size());
                if(SPLIs.size() > 0) {         if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isUpdateable()){ upsert SPLIs; } else {/*No access*/ }
                }

            } else{         comW.errorMsg = 'Invalid Lot/Serial please verify';
            }

            if(Task.ERP7__Status__c == 'Completed'){
                List<ERP7__Time_Card_Entry__c> TCES = [Select Id, Name, ERP7__End_Time__c From ERP7__Time_Card_Entry__c Where ERP7__Action_Task__c =: Task.Id And ERP7__Active__c = true And ERP7__End_Time__c = Null];
                for(ERP7__Time_Card_Entry__c TCE : TCES){ if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isUpdateable()){TCE.ERP7__End_Time__c = Task.ERP7__Actual_End_Time__c;}else{/*No access*/} }
                if(TCES.size() > 0) { if(Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable()){ upsert TCES;}else{/*No access*/}}
            }

            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            // String WOId = WO.Id;

            comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :WOId Order BY CreatedDate DESC');

            comW.Tasks = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :WOId Order By ERP7__Operation__r.ERP7__Sort__c ASC');

            List<ERP7__MRP__c> MRPs = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.ERP7__Unit_of_Measure__c, ERP7__BOM__r.Name, ERP7__BOM__r.ERP7__BOM_Version__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order__c, ERP7__Work_Order__r.Name, ERP7__Notes__c, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Scrap_Variant__c,
                                       ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__MO__r.ERP7__Version__c, ERP7__Fulfilled_Amount__c, ERP7__BOM__r.ERP7__Is_Protected__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__MRP_Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__Status__c, ERP7__Work_Order__r.ERP7__Raw_Materials_Site__c, ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                                       ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c,ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c, ERP7__MRP_Product__r.QuantityUnitOfMeasure, ERP7__BOM__r.ERP7__Product_Feature__r.Name, ERP7__BOM__r.ERP7__Product_Feature__c
                                       From ERP7__MRP__c
                                       Where ERP7__Work_Order__c = :woId Order By ERP7__BOM__r.ERP7__Sort__c ASC];
            List<mrpWrapBW> mrpWrapList = new List<mrpWrapBW>();
            for(Integer i=0; i<MRPs.size(); i++){
                ERP7__MRP__c MRP = MRPs[i];
                mrpWrapBW mrpWraper = new mrpWrapBW();

                if((i == 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null) || (i > 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != MRPs[i-1].ERP7__BOM__r.ERP7__Product_Feature__c)){
                    if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null){                 mrpWraper.Feature.Id = MRP.ERP7__BOM__r.ERP7__Product_Feature__c;           mrpWraper.Feature.Name = MRP.ERP7__BOM__r.ERP7__Product_Feature__r.Name;
                    }
                }

                mrpWraper.MRP = MRP;
                if(MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c != Null) {        mrpWraper.SelectedUOM = MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;        mrpWraper.UOMS.add(new SelectOptions(mrpWraper.SelectedUOM, mrpWraper.SelectedUOM, true));     if(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure != mrpWraper.SelectedUOM) mrpWraper.UOMS.add(new SelectOptions(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure, MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure));
                }

                if(MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c != null){
                    String UOMS = MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c;
                    List<String> arr = UOMS.split(';');       for(String str : arr){         if(str != mrpWraper.SelectedUOM && str != MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure) mrpWraper.UOMS.add(new SelectOptions(str, str));
                    }
                }
                mrpWrapList.add(mrpWraper);
            }
            comW.MRPSSBW = mrpWrapList;
        }
        catch(Exception e) {  Database.rollback(sp); comW.errorMsg = e.getMessage() +' Line Number 10@ : '+ e.getLineNumber(); system.debug('comW.errorMsg : '+comW.errorMsg);
                            //('Error : '+e.getMessage() +' Line Number @ : '+ e.getLineNumber());
                           }
        return comW;
    }

    class SoliWrapper{
		@AuraEnabled
    	public ERP7__Stock_Inward_Line_Item__c soli;

    	public SoliWrapper(ERP7__Stock_Inward_Line_Item__c soli){
        	this.soli=soli;
    	}

        public Boolean equals(Object soli){
            if(soli==null) return false;
            return this==soli;
        }

        public Integer hashCode(){
            return System.hashcode(this);
        }

	}

    @AuraEnabled
    public static comWrap TaskUpdateNew(String Task1, String WO1, String MRPSSS, String all_UOMs){
        Savepoint sp = Database.setSavepoint();
        List<mrpWrap> MRPSS = (List<mrpWrap>) JSON.deserialize(MRPSSS, List<mrpWrap>.class);
        ERP7__Actions_Tasks__c Task = (ERP7__Actions_Tasks__c) JSON.deserialize(Task1, ERP7__Actions_Tasks__c.class);
        ERP7__WO__c WO = (ERP7__WO__c) JSON.deserialize(WO1, ERP7__WO__c.class);
        ERP7__Timesheet__c TS = new ERP7__Timesheet__c();
        Boolean updateqty = false;
        comWrap comW = new comWrap();
        try{
            if(Task.ERP7__Status__c == 'Completed') {
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__End_Date__c.isUpdateable()){Task.ERP7__End_Date__c = system.Now(); }else{/*No access*/}
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Actual_End_Time__c.isUpdateable()){Task.ERP7__Actual_End_Time__c = system.Now();}else{/*No access*/}
            }
            if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()) { update Task; }else{/*No access*/}
           // if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()) { update Task; }else{/*No access*/}

            String TaskFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
            String AllTaskFields = TaskFields + ', ERP7__Work_Center__r.Name, ERP7__Work_Order__r.Project__c, ERP7__Work_Order__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c ';
            String tId = Task.Id;
            comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
            String woId = comW.SelectedTask.ERP7__Work_Order__c;
            if(woId != null && woId != ''){
                List<ERP7__WIP_Flow__c> wiplist = [Select Id,Name,ERP7__Status__c,ERP7__Product__c,ERP7__Work_Orders__r.ERP7__Product__c ,ERP7__Type__c from ERP7__WIP_Flow__c where ERP7__Work_Orders__c = :woId ];
                for(ERP7__WIP_Flow__c wip : wiplist){ if(wip.ERP7__Product__c != wip.ERP7__Work_Orders__r.ERP7__Product__c && wip.ERP7__Status__c== 'Completed' && wip.ERP7__Type__c== 'Processed'){ updateqty = true;   } else{ updateqty = false;    } }
            }

            List<Id> mrpIds = new List<Id>();
            List<ERP7__MRP__c> mrps2Update = new List<ERP7__MRP__c>();
            for(mrpWrap MRPS: MRPSS){  mrps2Update.add(MRPS.MRP);  mrpIds.add(MRPS.MRP.Id); }
            List<ERP7__Stock_Inward_Line_Item__c> Inwards = Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirement_Planning__c, ERP7__Product__c, ERP7__Process__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c  FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__MRP_Material_Requirement_Planning__c In :mrpIds');
            List<ERP7__Stock_Outward_Line_Item__c> Outwards = Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Process__c, ERP7__Product__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Status__c, ERP7__Work_Orders__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,  ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c,ERP7__Schedule__c,ERP7__MO_WO_Serial__c,ERP7__MO_WO_Material_Batch_Lot__c,Unit_Price__c,ERP7__Work_Order_Line_Items__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__MRP_Material_Requirements_Planning__c In :mrpIds and ERP7__Status__c = \'Reserved\'');

            List<ERP7__Stock_Outward_Line_Item__c> SOLIS2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Inventory_Stock__c> Stocks = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Stock_Inward_Line_Item__c> SPLIs = new List<ERP7__Stock_Inward_Line_Item__c>();
            Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c> StockInwardMap = new Map<ERP7__Stock_Inward_Line_Item__c, ERP7__Inventory_Stock__c>();
             Map<Id, ERP7__Inventory_Stock__c> batchStockInwardMap = new Map<Id, ERP7__Inventory_Stock__c>();
            Boolean InwardError = false;
            Boolean OutwardError = false;
            Decimal batchCounter=0,normalCounter=0;
            for(mrpWrap MRPS: MRPSS){
                if((MRPS.quantityToConsume + MRPS.quantityToScrap) > 0){
                    if(MRPS.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c || MRPS.MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c){
                        Boolean mrpInwardFound = false;
                        for(ERP7__Stock_Inward_Line_Item__c SILI : Inwards){
                            if(MRPS.MRP.Id == SILI.ERP7__MRP_Material_Requirement_Planning__c && SILI.ERP7__Product__c == MRPS.MRP.ERP7__MRP_Product__c){
                                if(MRPS.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && MRPS.Lot_Serial == SILI.ERP7__Serial__r.ERP7__Serial_Number__c) mrpInwardFound = true;
                                else if(!MRPS.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && MRPS.MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c && MRPS.Lot_Serial == SILI.ERP7__Material_Batch_Lot__r.Name) mrpInwardFound = true;
                            }
                        }
                        if(!mrpInwardFound) {
                            //InwardError = true;
                            //break;
                        }
                        if(!InwardError){
                            for(ERP7__Stock_Outward_Line_Item__c SOLI : Outwards){
                                if(MRPS.MRP.Id == SOLI.ERP7__MRP_Material_Requirements_Planning__c && SOLI.ERP7__Product__c == MRPS.MRP.ERP7__MRP_Product__c){
                                    if((MRPS.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && MRPS.Lot_Serial == SOLI.ERP7__Serial__r.ERP7__Serial_Number__c)){
                                        //OutwardError = true;
                                        //break;
                                    }
                                }
                            }
                        }
                    }
                    if(InwardError || OutwardError) break;
                    else{
                        comW.errorMsg = ''; Decimal stock2insert = MRPS.quantityToConsume + MRPS.quantityToScrap;          Decimal stock2Consume = MRPS.quantityToConsume; Decimal stock2Scrap = MRPS.quantityToScrap;

                        //start UOM Calc
                        List<ERP7__UOM_Conversion__mdt> allUOMCs = (List<ERP7__UOM_Conversion__mdt>) JSON.deserialize(all_UOMs, List<ERP7__UOM_Conversion__mdt>.class);
                        String prodUOM = MRPS.MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;
                        String bomUOM  = MRPS.MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                        if(prodUOM != null && prodUOM != '' && bomUOM != null && bomUOM != '' && bomUOM != prodUOM){
                            for(Integer k=0; k<allUOMCs.size(); k++){
                                if((allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM) || (allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM)){
                                    //conversionFound = true;
                                    comW.errorMsg = '';
                                    if(allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM){
                                        stock2Consume = (allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Consume).setScale(4);            stock2Scrap = (allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Scrap).setScale(4);
                                    }
                                    else if(allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM){
                                        //stock2insert = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2insert;
                                        stock2Consume = (allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Consume).setScale(4);      stock2Scrap = (allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Scrap).setScale(4);
                                    }
                                    else comW.errorMsg = 'UOM Conversion not found.';
                                    break;
                                }

                            }
                        }
                        //end UOM Calc
                        //if(MRPS.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c) stock2Scrap = 1;
                        for(ERP7__Stock_Inward_Line_Item__c SILI : Inwards){
                            if(MRPS.MRP.Id == SILI.ERP7__MRP_Material_Requirement_Planning__c && stock2insert > 0 && MRPS.MRP.ERP7__MRP_Product__c == SILI.ERP7__Product__c){
                                ERP7__MRP__c MRP = MRPS.MRP;
                                Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c(); if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){SDLI.Name = MRP.Name;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()){SDLI.Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isUpdateable()){SDLI.Process__c = MRP.Process__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isUpdateable()){SDLI.Schedule__c = MRP.Schedule__c;}else{/*No access*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isUpdateable()){SDLI.MRP_Material_Requirements_Planning__c = MRP.Id;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isUpdateable()){SDLI.BoM__c = MRP.BOM__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){SDLI.Status__c = 'Committed';}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()){SDLI.Product__c = MRP.MRP_Product__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable()){SDLI.Site_Product_Service_Inventory_Stock__c = SILI.ERP7__Site_ProductService_InventoryStock__c;}else{/*No access*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SDLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}

                                if(MRP.BOM_Requirement_Cost__c != Null){
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = MRP.BOM_Requirement_Cost__c;}else{/*No access*/}
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()){SDLI.Unit_Price__c = (MRP.Total_Amount_Required__c != Null && MRP.Total_Amount_Required__c > 0)? MRP.BOM_Requirement_Cost__c/MRP.Total_Amount_Required__c : 0;}else{/*No access*/}
                                }
                                if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && MRPS.Lot_Serial == SILI.ERP7__Serial__r.ERP7__Serial_Number__c){
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                    stock2insert = stock2insert - SDLI.Quantity__c;
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SDLI.ERP7__Serial__c = SILI.ERP7__Serial__c;}else{/*No access*/}
                                    //SDLI.ERP7__Material_Batch_Lot__c = SILI.ERP7__Material_Batch_Lot__c;
                                    SOLIS2Upsert.add(SDLI);
                                }
                                else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true && MRPS.Lot_Serial == SILI.ERP7__Material_Batch_Lot__r.Name)){
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                    stock2insert = stock2insert - SDLI.Quantity__c;
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SDLI.ERP7__Material_Batch_Lot__c = SILI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                                    SOLIS2Upsert.add(SDLI);
                                }
                                else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                    stock2insert = stock2insert - SDLI.Quantity__c;      SOLIS2Upsert.add(SDLI);
                                }
                            }
                        }
                        for(ERP7__Stock_Outward_Line_Item__c SOLI : Outwards){
                            if(MRPS.MRP.Id == SOLI.ERP7__MRP_Material_Requirements_Planning__c && stock2insert > 0 && MRPS.MRP.ERP7__MRP_Product__c == SOLI.ERP7__Product__c){
                                ERP7__MRP__c MRP = MRPS.MRP;
                                Decimal stockUsed = 0;
                                if(stock2Scrap > 0){
                                    system.debug('SOLI.ERP7__Quantity__c : '+SOLI.ERP7__Quantity__c);
                                    system.debug('stock2Scrap : '+stock2Scrap);

                                    if(SOLI.ERP7__Quantity__c <= stock2Scrap){
                                        System.debug('in if');
                                        stock2Scrap = stock2Scrap - SOLI.ERP7__Quantity__c;
                                      //  SOLI.ERP7__Status__c = 'Committed';
                                        SOLI.ERP7__Scrap__c = true;
                                        stockUsed += SOLI.ERP7__Quantity__c;
                                        if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c == 'Committed'){
                                            Continue;
                                        }
                                        if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c != 'Committed'){
                                            //scrap inward.
                                            ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(); if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isUpdateable()){Stock.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}

                                            ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SPLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                            StockInwardMap.put(SPLI,Stock);                       SPLIs.add(SPLI);  Stocks.add(Stock);
                                            //scrap inward end.

                                        }
                                        else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true)){// && MRPS.Lot_Serial == SOLI.ERP7__Material_Batch_Lot__r.Name
                                            //scrap inward.
                                            ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c();   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/}    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()){Stock.ERP7__Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                                            system.debug('Stock .ERP7__Batch_Lot__c : '+Stock .ERP7__Batch_Lot__c);
                                            ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c =SOLI.Quantity__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                            if(MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true ){
                                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'b'+batchCounter;}batchCounter++;
                                            }
                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SPLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/} system.debug('SPLI.ERP7__Material_Batch_Lot__c : '+SPLI.ERP7__Material_Batch_Lot__c );
                                            batchStockInwardMap.put(SPLI.ERP7__Material_Batch_Lot__c,Stock);                    SPLIs.add(SPLI);             // Stocks.add(Stock);
                                            //scrap inward end.

                                        }
                                        else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {
                                            //scrap inward.
                                            ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(); if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }

                                            ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = SOLI.Quantity__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                            if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true){
                                                if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'n'+normalCounter;}normalCounter++;
                                            }
                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            StockInwardMap.put(SPLI,Stock);                        SPLIs.add(SPLI);              Stocks.add(Stock);
                                            //scrap inward end.
                                        }
                                        SOLI.ERP7__Status__c = 'Committed';
                                    }
                                    else{
                                        if(SOLI.ERP7__Quantity__c >= stock2Scrap){
                                            SOLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c - stock2Scrap;
                                        }
                                        if(MRP.BOM_Requirement_Cost__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SOLI.Total_Amount__c = SOLI.Unit_Price__c*SOLI.ERP7__Quantity__c;}else{/*No access*/} }
                                        //SOLIS2Upsert.add(SOLI);
                                        Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c();
                                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){SDLI.Name = MRP.Name;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SDLI.ERP7__Scrap__c = true;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SDLI.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Process__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Process__c.isUpdateable()){SDLI.ERP7__Process__c = MRP.Process__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isUpdateable()){SDLI.Schedule__c = MRP.Schedule__c;}else{/*No access*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isUpdateable()){SDLI.ERP7__MRP_Material_Requirements_Planning__c = MRP.Id;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isUpdateable()){SDLI.ERP7__BoM__c = MRP.ERP7__BOM__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){SDLI.ERP7__Status__c = 'Committed';}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SDLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){SDLI.ERP7__Site_Product_Service_Inventory_Stock__c = SOLI.ERP7__Site_Product_Service_Inventory_Stock__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SDLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}

                                        if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c == 'Committed'){
                                            Continue;
                                        }
                                        if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c != 'Committed'){// && MRPS.Lot_Serial == SOLI.ERP7__Serial__r.ERP7__Serial_Number__c
                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = 1;}else{/*No access*/}//(SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= 1)?
                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SDLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                            SDLI.Id = SOLI.Id;    stock2Scrap = stock2Scrap - SOLI.Quantity__c;

                                            //scrap inward.
                                            ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(); if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Serial__c.isUpdateable()){Stock.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}

                                            ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = 1;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/} if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SPLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                            StockInwardMap.put(SPLI,Stock);                       SPLIs.add(SPLI);  Stocks.add(Stock);
                                            //scrap inward end.

                                        }
                                        else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true)){// && MRPS.Lot_Serial == SOLI.ERP7__Material_Batch_Lot__r.Name
                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.Number_of_Item_In_Stock__c > 0 && SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                            stock2Scrap = stock2Scrap - SDLI.Quantity__c;
                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SDLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}

                                            //scrap inward.
                                            ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c();   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/}    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()){Stock.ERP7__Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}

                                            ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = SDLI.Quantity__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                            if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'b'+batchCounter;}batchCounter++;
                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SPLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                                            batchStockInwardMap.put(SPLI.ERP7__Material_Batch_Lot__c,Stock);                    SPLIs.add(SPLI);            //  Stocks.add(Stock);
                                            //scrap inward end.

                                        }
                                        else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {
                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                            stock2Scrap = stock2Scrap - SDLI.Quantity__c;

                                            //scrap inward.
                                            ERP7__Inventory_Stock__c Stock = new ERP7__Inventory_Stock__c(); if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){Stock.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Work_Order__c.isUpdateable()){Stock.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Active__c.isUpdateable()){Stock.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()){Stock.Name=MRP.ERP7__Work_Order__r.Name;}else{/*No access*/} if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Checked_In_Date__c.isUpdateable()){Stock.ERP7__Checked_In_Date__c=system.today();}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Warehouse__c.isCreateable()){Stock.ERP7__Warehouse__c=SOLI.ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Version__c.isUpdateable()){Stock.ERP7__Version__c = MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Status__c.isUpdateable()){Stock.ERP7__Status__c = 'Checked In';}else{/*No access*/}   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Scrap__c.isUpdateable()){Stock.ERP7__Scrap__c = true;}else{/*No access*/}

                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Product__c.isUpdateable()){stock.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }

                                            ERP7__Stock_Inward_Line_Item__c SPLI = new ERP7__Stock_Inward_Line_Item__c();  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SPLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Work_Order__c.isUpdateable()){SPLI.ERP7__Work_Order__c = MRP.ERP7__Work_Order__c;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.Name.isUpdateable()){SPLI.Name = MRP.ERP7__Work_Order__r.Name;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SPLI.ERP7__Active__c = true;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SPLI.ERP7__Quantity__c = SDLI.Quantity__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable()){SPLI.ERP7__Unit_Price__c=0;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SPLI.ERP7__Version__c =  MRP.ERP7__Version__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SPLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                            if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Notes__c.isUpdateable()){SPLI.ERP7__Notes__c = 'n'+normalCounter;}normalCounter++;
                                            if(MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c != null){ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__r.ERP7__Scrap_Variant__c;}else{/*No access*/} }
                                            else{ if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SPLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/} }
                                            StockInwardMap.put(SPLI,Stock);                        SPLIs.add(SPLI);              Stocks.add(Stock);
                                            //scrap inward end.
                                        }
                                        if(MRP.BOM_Requirement_Cost__c != Null){
                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()){SDLI.Unit_Price__c = (MRP.Total_Amount_Required__c != Null && MRP.Total_Amount_Required__c > 0)? MRP.BOM_Requirement_Cost__c/MRP.Total_Amount_Required__c : 0;}else{/*No access*/}
                                            if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = SDLI.Unit_Price__c*SDLI.ERP7__Quantity__c;}else{/*No access*/}
                                            //SOLIS2Upsert.add(SDLI);
                                        }
                                        SOLIS2Upsert.add(SDLI);
                                    }

                                }
                                if (stock2Consume > 0){
                                    system.debug('SOLI.ERP7__Quantity__c bfr : '+SOLI.ERP7__Quantity__c);
                                    system.debug('stock2Consume bfr : '+stock2Consume);
                                    system.debug('stockUsed : '+stockUsed);
                                    Decimal remainingSOLIQty = SOLI.ERP7__Quantity__c - stockUsed;
                                    system.debug('remainingSOLIQty : '+remainingSOLIQty);
                                    if(remainingSOLIQty > 0){
                                        if(SOLI.ERP7__Quantity__c <= stock2Consume){
                                            System.debug('in if');
                                            stock2Consume = stock2Consume - SOLI.ERP7__Quantity__c;

                                            SOLI.ERP7__Status__c = 'Committed';
                                        }
                                        else{
                                            if(SOLI.ERP7__Quantity__c >= stock2Consume){
                                                SOLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c - stock2Consume;
                                            }
                                            system.debug('SOLI.ERP7__Quantity__c after: '+SOLI.ERP7__Quantity__c);
                                            if(MRP.BOM_Requirement_Cost__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SOLI.Total_Amount__c = SOLI.Unit_Price__c*SOLI.ERP7__Quantity__c;}else{/*No access*/} }
                                            system.debug('stock2Consume : '+stock2Consume);
                                            Stock_Outward_Line_Item__c pplis = new Stock_Outward_Line_Item__c();                   pplis.Name = SOLI.Name;pplis.ERP7__Active__c = true;                      pplis.ERP7__Process__c = SOLI.ERP7__Process__c;           pplis.ERP7__Schedule__c = SOLI.ERP7__Schedule__c;    pplis.ERP7__MRP_Material_Requirements_Planning__c = SOLI.ERP7__MRP_Material_Requirements_Planning__c;            pplis.ERP7__BoM__c = SOLI.ERP7__BoM__c;             pplis.ERP7__Status__c = 'Committed';      pplis.ERP7__Product__c = SOLI.ERP7__Product__c;          pplis.ERP7__Site_Product_Service_Inventory_Stock__c = SOLI.ERP7__Site_Product_Service_Inventory_Stock__c;                  pplis.ERP7__Version__c = SOLI.ERP7__Version__c;              pplis.ERP7__Quantity__c = stock2Consume;              system.debug('pplis.ERP7__Quantity__c after: '+pplis.ERP7__Quantity__c);                pplis.ERP7__MO_WO_Serial__c = SOLI.ERP7__MO_WO_Serial__c;                  pplis.ERP7__MO_WO_Material_Batch_Lot__c = SOLI.ERP7__MO_WO_Material_Batch_Lot__c;                    pplis.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;                pplis.ERP7__Serial__c = SOLI.ERP7__Serial__c;      if(SOLI.Unit_Price__c != null) {pplis.Total_Amount__c = (SOLI.Unit_Price__c > 0) ? (pplis.ERP7__Quantity__c * SOLI.Unit_Price__c) : 0;}              pplis.ERP7__Work_Orders__c = SOLI.ERP7__Work_Orders__c;             pplis.ERP7__Work_Order_Line_Items__c = SOLI.ERP7__Work_Order_Line_Items__c;   pplis.ERP7__Manufacturing_Order__c = SOLI.ERP7__Manufacturing_Order__c;
                                            stock2Consume = stock2Consume - pplis.ERP7__Quantity__c;
                                            SOLIS2Upsert.add(pplis);
                                        }
                                    }
                                    // SOLIS2Upsert.add(SOLI);

                                    /* Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c(Id = SOLI.Id);
if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){SDLI.ERP7__Status__c = 'Committed';}else{}
if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SDLI.ERP7__Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Consume)? stock2Consume : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;}else{}
if(SOLI.ERP7__Product__r.ERP7__Serialise__c && SOLI.ERP7__Status__c == 'Reserved'){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){SDLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c;}else{} }
stock2Consume = stock2Consume - SDLI.ERP7__Quantity__c;

if(MRP.BOM_Requirement_Cost__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = SOLI.Unit_Price__c*SDLI.ERP7__Quantity__c;}else{} }
SOLIS2Upsert.add(SDLI);*/

                                }
                                SOLIS2Upsert.add(SOLI);
                            }
                        }
                    }
                }
            }
            if(!InwardError && !OutwardError){
                comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
                // if(updateqty) WO.ERP7__Quantity_Built__c = WO.ERP7__Quantity_Ordered__c;

                if(Schema.sObjectType.ERP7__WO__c.isUpdateable()){update WO;} else {/*No access*/}
                comW.WorkOrder = WO;
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){ update comW.SelectedTask; } else {/*No access*/}
                if(mrps2Update.size() > 0){
                    if(Schema.SObjectType.ERP7__MRP__c.isUpdateable()){ update mrps2Update; } else {/*No access*/}
                }
                system.debug('SOLIS2Upsert : '+SOLIS2Upsert.size());
                if(SOLIS2Upsert.size() > 0){
                    Map<String,Stock_Outward_Line_Item__c> SOLIS2UpsertMAP = new Map<String,Stock_Outward_Line_Item__c>();
                    Integer i = 1;
                    for(Stock_Outward_Line_Item__c stoli : SOLIS2Upsert){
                        if(stoli.Id != null && !SOLIS2UpsertMAP.containsKey(stoli.Id)) SOLIS2UpsertMAP.put(stoli.Id,stoli);
                        else { SOLIS2UpsertMAP.put(String.valueOf(i),stoli); i++; }
                    }
                    system.debug('SOLIS2UpsertMAP : '+SOLIS2UpsertMAP.size());
                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()){ upsert SOLIS2UpsertMAP.values(); } else {/*No access*/}
                }
                if(SPLIs.size() > 0){
                    system.debug('Stocks bfr: '+Stocks.size());
                    Stocks.addall(batchStockInwardMap.Values());
                     system.debug('Stocks after: '+Stocks.size());
                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.isUpdateable()){ upsert Stocks; } else {/*No access*/}
                }

                for(ERP7__Stock_Inward_Line_Item__c inward : SPLIs){ //StockInwardMap.KeySet()
                    String StockId = '', SerialId = '', BatchId = '';
                    system.debug('batchStockInwardMap.containsKey(inward.ERP7__Material_Batch_Lot__c ) : '+batchStockInwardMap.containsKey(inward.ERP7__Material_Batch_Lot__c));
                    if(batchStockInwardMap.containsKey(inward.ERP7__Material_Batch_Lot__c)) StockId = batchStockInwardMap.get(inward.ERP7__Material_Batch_Lot__c).Id;
                    else  StockId = StockInwardMap.get(inward).Id;
                    system.debug('StockId : '+StockId);
                    //if(SerialInwardMap.containsKey(inward)) SerialId = SerialInwardMap.get(inward).Id;
                    //if(BatchInwardMap.containsKey(inward)) BatchId = BatchInwardMap.get(inward).Id;
                    inward.ERP7__Site_ProductService_InventoryStock__c = StockId;
                    //if(SerialId != '' && inward.ERP7__Serial__c == Null) inward.ERP7__Serial__c = SerialId;
                    //if(BatchId != '' && inward.ERP7__Material_Batch_Lot__c == Null) inward.ERP7__Material_Batch_Lot__c = BatchId;
                }
                if(SPLIs.size() > 0) {
                    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isUpdateable()){ upsert SPLIs; }else{/*No access*/}
                }

            } else{ comW.errorMsg = 'Invalid Lot/Serial please verify'; }

            if(Task.ERP7__Status__c == 'Completed'){
                List<ERP7__Time_Card_Entry__c> TCES = [Select Id, Name, ERP7__End_Time__c From ERP7__Time_Card_Entry__c Where ERP7__Action_Task__c =: Task.Id And ERP7__Active__c = true And ERP7__End_Time__c = Null];
                for(ERP7__Time_Card_Entry__c TCE : TCES){ if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isUpdateable()){TCE.ERP7__End_Time__c = Task.ERP7__Actual_End_Time__c;} else {/*No access*/} }
                if(TCES.size() > 0) { if(Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable()){ upsert TCES; } else {/*No access*/} }
            }

            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';
            String TSId = TS.Id;
            comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :woId Order BY CreatedDate DESC');
            comW.Tasks = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :woId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
        } catch(Exception e) { Database.rollback(sp); comW.errorMsg = e.getMessage() +' Line Number 11@ : '+ e.getLineNumber(); }
        return comW;
    }

    /*
@AuraEnabled
public static comWrap ReserveMRPSStocks(String MRPs){
List<mrpWrapBW> mrpWrappers = (List<mrpWrapBW>) JSON.deserialize(MRPs, List<mrpWrapBW> .class);
comWrap comW = new comWrap();
try{
comW.errorMsg = '';
String selectedSite = comW.manuOrders.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
String finishedProduct = comW.manuOrders.ERP7__Product__c;
List<Id> proIds = new List<Id>();
Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
Map<Id,List<Inventory_Stock__c>> productSites = new Map<Id,List<Inventory_Stock__c>>();

for(mrpWrapBW mrpWrapper : mrpWrappers){
if(mrpWrapper.mrp.ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != Null) selectedSite = mrpWrapper.mrp.ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
if(mrpWrapper.mrp.ERP7__MRP_Product__c != Null) proIds.add(mrpWrapper.mrp.ERP7__MRP_Product__c);
}

if(selectedSite != Null && selectedSite != ''){
String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
String AllWarehouseFields = WarehouseFields + '';
List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
+' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC');

for(Id proId : proIds){
Decimal myStock = 0;
if(!productSites.containsKey(proId)) productSites.put(proId, new List<Inventory_Stock__c>());
for(Inventory_Stock__c stock : WIISLists){
if(proId == stock.Product__c){
myStock += stock.Number_of_Item_In_Stock__c;
List<Inventory_Stock__c> myStocks = productSites.get(proId);
myStocks.add(stock);
productSites.put(proId,myStocks);
}
}
stockMap.put(proId,myStock);
}
}
List<Stock_Outward_Line_Item__c> SDLIs2Upsert = new List<Stock_Outward_Line_Item__c>();
List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();
for(mrpWrapBW mrpWrapper : mrpWrappers){
if(mrpWrapper.Stock > 0 && mrpWrapper.MRP.ERP7__Status__c == 'Requested' && mrpWrapper.Stock >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c){
List<Inventory_Stock__c> WIISs = productSites.get(mrpWrapper.MRP.MRP_Product__c);
if(WIISs != Null && WIISs.size() > 0){
Inventory_Stock__c WIIS = (mrpWrapper.MRP.Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c();   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){SDLI.Name = mrpWrapper.MRP.Name;}else{}   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()){SDLI.Active__c = true;}else{}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isUpdateable()){SDLI.Process__c = mrpWrapper.MRP.Process__c;}else{}    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isUpdateable()){SDLI.Schedule__c = mrpWrapper.MRP.Schedule__c;}else{}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isUpdateable()){SDLI.MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id;}else{}   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isUpdateable()){SDLI.BoM__c = mrpWrapper.MRP.BOM__c;}else{}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = mrpWrapper.MRP.Total_Amount_Required__c;}else{}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){SDLI.Status__c = 'Reserved';}else{}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()){SDLI.Product__c = mrpWrapper.MRP.MRP_Product__c;}else{} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable()){SDLI.Site_Product_Service_Inventory_Stock__c = WIIS.Id;}else{}   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;}else{} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){SDLI.ERP7__Version__c = WIIS.ERP7__Version__c;}else{}

if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;}else{}
if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()){SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;}else{}
}
if(mrpWrapper.MRP.Work_Order__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Orders__c.isUpdateable()){SDLI.Work_Orders__c = mrpWrapper.MRP.Work_Order__c;}else{} }
if(mrpWrapper.MRP.Work_Order_Line_Items__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Work_Order_Line_Items__c.isUpdateable()){SDLI.Work_Order_Line_Items__c = mrpWrapper.MRP.Work_Order_Line_Items__c;}else{} }
if(mrpWrapper.MRP.ERP7__MO__c != Null){ if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;}else{} }
SDLIs2Upsert.add(SDLI);
if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.Total_Amount_Required__c;}else{}
if(Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()){mrpWrapper.MRP.Status__c = 'Reserved';}else{}
MRPs2Upsert.add(mrpWrapper.MRP);
comW.errorMsg = '';
}
}
}
if(SDLIs2Upsert.size() > 0){
if(Schema.sObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()){ upsert SDLIs2Upsert; } else {}
}

if(MRPs2Upsert.size() > 0) {
if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){ upsert MRPs2Upsert; } else{}
}
comW.MRPSSBW =  mrpWrappers; } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
return comW;
}
*/

  /*  @AuraEnabled
    public static comWrap ReserveMRPSStocks(String MRPs){
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        comWrap comW = new comWrap();

        try{
            comW.errorMsg = '';
            List<mrpWrap> mrpWrapret = new List<mrpWrap>();
            String selectedSite = comW.manuOrders.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            String finishedProduct = comW.manuOrders.ERP7__Product__c;
            List<Id> proIds = new List<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            set<Id> MRPIds = new set<Id>();
            Map<Id,List<Inventory_Stock__c>> productSites = new Map<Id,List<Inventory_Stock__c>>();
            Map<Id,Decimal> Mapexistingstock = new Map<Id,Decimal>();
            Map<Id,Set<Id>> MapexistingstockSerials = new Map<Id,Set<Id>>();
            String MOId = '';
            for(mrpWrap mrpWrapper : mrpWrappers){
                if(MOId == '') MOId = mrpWrapper.mrp.ERP7__MO__c;
                if(mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != Null) selectedSite = mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                if(mrpWrapper.mrp.ERP7__MRP_Product__c != Null) proIds.add(mrpWrapper.mrp.ERP7__MRP_Product__c);
                MRPIds.add(mrpWrapper.mrp.Id);
            }
            List<ERP7__Stock_Outward_Line_Item__c> fulfilledStock = [Select Id,Name,ERP7__MO_WO_Serial__c ,ERP7__Quantity__c,ERP7__MRP_Material_Requirements_Planning__c from ERP7__Stock_Outward_Line_Item__c where ERP7__MRP_Material_Requirements_Planning__c In:MRPIds and ERP7__Active__c =true];


            List<ERP7__Serial_Number__c> SNS = new List<ERP7__Serial_Number__c> ();
            ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c();
            if(MOId != '') {
                MO = [Select Id, Name, ERP7__Product__r.ERP7__Serialise__c From ERP7__Manufacturing_Order__c Where Id =: MOId];
                if(MO.ERP7__Product__r.ERP7__Serialise__c == true) SNS = [Select Id, Name, ERP7__Material_Batch_Lot__c, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Serial_Number__c Where ERP7__Manufacturing_Order__c =: MO.Id];
            }
            system.debug('*** SNS : '+SNS);

            for(mrpWrap mrpWrapper : mrpWrappers){
                Decimal allocatedqty = 0;
                Set<Id> SerialNos = new Set<Id>();
                for(ERP7__Stock_Outward_Line_Item__c stk : fulfilledStock){
                    if(stk.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) {
                        allocatedqty += stk.ERP7__Quantity__c;
                        if(stk.ERP7__MO_WO_Serial__c != Null) SerialNos.add(stk.ERP7__MO_WO_Serial__c);
                        // system.debug('allocatedqty : '+allocatedqty);
                    }
                }
                MapexistingstockSerials.put(mrpWrapper.MRP.Id, SerialNos);
                if(allocatedqty > 0) Mapexistingstock.put(mrpWrapper.MRP.Id,allocatedqty);
            }
            system.debug('Mapexistingstock : '+Mapexistingstock);
            if(selectedSite != Null && selectedSite != ''){
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + '';
                List<ERP7__Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, '+
                                                                          +' ERP7__StorageContainer__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where (ERP7__Warehouse__c =: selectedSite And (ERP7__Product__c In: proIds And ERP7__Number_of_Item_In_Stock__c > 0) And ERP7__Active__c = true) Order By ERP7__Expiry_Date__c ASC');


                for(Id proId : proIds){
                    Decimal myStock = 0;
                    if(!productSites.containsKey(proId)) productSites.put(proId, new List<ERP7__Inventory_Stock__c>());
                    for(ERP7__Inventory_Stock__c stock : WIISLists){
                        if(proId == stock.Product__c){

                            myStock += stock.ERP7__Number_of_Item_In_Stock__c;
                            List<ERP7__Inventory_Stock__c> myStocks = productSites.get(proId);
                            myStocks.add(stock);
                            productSites.put(proId,myStocks);
                        }
                    }
                    stockMap.put(proId,myStock);

                }

            }
            system.debug('stockMap ; '+stockMap);
            List<Stock_Outward_Line_Item__c> SDLIs2Upsert = new List<Stock_Outward_Line_Item__c>();
            List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();

            for(mrpWrap mrpWrapper : mrpWrappers){
                Decimal WM = mrpWrapper.WeightMultiplier;
                system.debug('Product : '+mrpWrapper.MRP.MRP_Product__c+'   mrpWrapper.Stock : '+mrpWrapper.Stock+ ' 2.mrpWrapper.MRP.ERP7__Status__c : '+mrpWrapper.MRP.ERP7__Status__c+ ' 3.mrpWrapper.MRP.ERP7__Total_Amount_Required__c : '+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);

                if(mrpWrapper.Stock > 0 && mrpWrapper.MRP.ERP7__Status__c == 'Requested'){  //&& ((mrpWrapper.Stock >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c) || ((mrpWrapper.Stock + mrpWrapper.mrp.ERP7__Fulfilled_Amount__c) >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c))
                    system.debug('if');
                    List<Inventory_Stock__c> WIISs = productSites.get(mrpWrapper.MRP.MRP_Product__c);

                    if(WIISs != Null && WIISs.size() > 0){
                        system.debug('WIISs : Not null ');
                        ERP7__Inventory_Stock__c WIIS = (mrpWrapper.MRP.ERP7__Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
                        system.debug('WIIS : '+WIIS.ERP7__Number_of_Item_In_Stock__c);


                        // Single WIIS straight forward reduction and reserving
                        if((WIIS.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.mrp.ERP7__Fulfilled_Amount__c/WM) >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM){
                            system.debug('In if 1');
                            if(SNS.size() > 0){
                                for(ERP7__Serial_Number__c SN : SNS){
                                    if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id)){
                                        system.debug('*** SNS In One: '+SN.Name);
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                        //if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - Mapexistingstock.get(mrpWrapper.MRP.Id) ;
                                        //else SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
                                        SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                        SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                        if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                        if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                        if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                            SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                            SDLI.Total_Amount__c = SDLI.ERP7__Quantity__c*SDLI.Unit_Price__c;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                        if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        SDLIs2Upsert.add(SDLI);
                                        MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                    }
                                }
                            }
                            else{
                                system.debug('*** SNS out One: ');
                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM - Mapexistingstock.get(mrpWrapper.MRP.Id) ;
                                else SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM).setScale(4);
                                if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                    SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                    SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                }
                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                SDLIs2Upsert.add(SDLI);
                            }

                            mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
                            mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                            MRPs2Upsert.add(mrpWrapper.MRP);
                            comW.errorMsg = '';
                            mrpWrapret.add(mrpWrapper);

                        }


                        //Multiple WIIS calculative Reserving and other calculations
                        else if(WIIS.ERP7__Number_of_Item_In_Stock__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM){
                            system.debug('else if 1');

                            //Need Change Imran
                            Decimal remainingqty = 0;
                            for(Inventory_Stock__c stk : WIISs){
                                if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c != mrpWrapper.MRP.ERP7__Total_Amount_Required__c && mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                    if(SNS.size() > 0){
                                        Decimal WIISStock = stk.ERP7__Number_of_Item_In_Stock__c;
                                        for(ERP7__Serial_Number__c SN : SNS){
                                            if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) && WIISStock > 0 && WIISStock >= mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM){
                                                system.debug('*** SNS In two : '+SN.Name);
                                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                                //totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                                //if(((mrpWrapper.MRP.ERP7__Total_Amount_Required__c == stk.ERP7__Number_of_Item_In_Stock__c) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c > (stk.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c))) || remainingqty >= stk.ERP7__Number_of_Item_In_Stock__c || remainingqty == 0) { SDLI.ERP7__Quantity__c = stk.ERP7__Number_of_Item_In_Stock__c; system.debug('stk.ERP7__Number_of_Item_In_Stock__c 1 ***: '+stk.ERP7__Number_of_Item_In_Stock__c); }
                                                //else if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) { SDLI.ERP7__Quantity__c = remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id); system.debug('SDLI.ERP7__Quantity__c  1 ***: '+SDLI.ERP7__Quantity__c ); }
                                                //else { SDLI.ERP7__Quantity__c = remainingqty;  system.debug('remainingqty  1 ***: '+remainingqty );}//stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                                SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                                SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;

                                                if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                                    SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;
                                                    SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                                }
                                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                SDLIs2Upsert.add(SDLI);
                                                mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + SDLI.ERP7__Quantity__c*WM;//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                                WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                            }
                                        }
                                    }else{
                                        system.debug('*** SNS out two: ');
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                        //totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                        if(((mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM == stk.ERP7__Number_of_Item_In_Stock__c) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM > (stk.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c/WM))) || remainingqty >= stk.ERP7__Number_of_Item_In_Stock__c || remainingqty == 0) { SDLI.ERP7__Quantity__c = stk.ERP7__Number_of_Item_In_Stock__c; system.debug('stk.ERP7__Number_of_Item_In_Stock__c 1 ***: '+stk.ERP7__Number_of_Item_In_Stock__c); }
                                        else if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) { SDLI.ERP7__Quantity__c = (remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id)).setScale(4); system.debug('SDLI.ERP7__Quantity__c  1 ***: '+SDLI.ERP7__Quantity__c ); }
                                        else { SDLI.ERP7__Quantity__c = (remainingqty).setScale(4);  system.debug('remainingqty  1 ***: '+remainingqty );}//stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                        if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                        if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.BOM_Requirement_Cost__c != Null){
                                            SDLI.Total_Amount__c = mrpWrapper.MRP.BOM_Requirement_Cost__c;       SDLI.Unit_Price__c = (mrpWrapper.MRP.Total_Amount_Required__c != Null && mrpWrapper.MRP.Total_Amount_Required__c > 0)? mrpWrapper.MRP.BOM_Requirement_Cost__c/mrpWrapper.MRP.Total_Amount_Required__c : 0;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;                               if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        SDLIs2Upsert.add(SDLI);
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + SDLI.ERP7__Quantity__c*WM;//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                        system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                    }

                                    remainingqty = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM;
                                    if(remainingqty < 0) remainingqty = 0;

                                    if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c){         Decimal totalFulfilled =  (Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) ?  (Mapexistingstock.get(mrpWrapper.MRP.Id)) : 0;
                                        for(ERP7__Stock_Outward_Line_Item__c ss : SDLIs2Upsert){        if(ss.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) totalFulfilled += ss.ERP7__Quantity__c;
                                        }
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = totalFulfilled*WM;             system.debug('totalFulfilled else if 2 after: '+totalFulfilled+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );             mrpWrapper.MRP.ERP7__Status__c = 'Reserved';                    MRPs2Upsert.add(mrpWrapper.MRP);                     comW.errorMsg = '';                        mrpWrapret.add(mrpWrapper);        break;
                                    }
                                }
                            } // for WIIS
                        } // Multiple WIIS


                    } // WIIS size > 0
                } // MRP Stock > 0
            }

            if(SDLIs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){upsert SDLIs2Upsert;}else{comW.errorMsg ='Not allowed to upsert SDLI';} }
            if(MRPs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){upsert MRPs2Upsert;}else{comW.errorMsg ='Not allowed to upsert MRPs';} }
            List<mrpWrap> retunrMRP = new List<mrpWrap>();
            for(mrpWrap mrpWrapper : mrpWrapret){
                for(ERP7__MRP__c mrp : MRPs2Upsert){
                    if(mrpWrapper.MRP.ERP7__MRP_Product__c == mrp.ERP7__MRP_Product__c){  mrpWrapper.MRP = mrp;
                                                                                       }
                }
                retunrMRP.add(mrpWrapper);
            }
            comW.MRPSS = retunrMRP;
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }
        return comW;
    } */
     @AuraEnabled
    public static comWrap ReserveMRPSStocks(String MRPs,Integer AutostkLimit){
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        comWrap comW = new comWrap();
        system.debug('AutostkLimit : '+AutostkLimit);
        try{
            comW.errorMsg = '';
            List<mrpWrap> mrpWrapret = new List<mrpWrap>();
            String selectedSite = comW.manuOrders.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            String finishedProduct = comW.manuOrders.ERP7__Product__c;
            List<Id> proIds = new List<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            set<Id> MRPIds = new set<Id>();
            Map<Id,List<ERP7__Inventory_Stock__c>> productSites = new Map<Id,List<ERP7__Inventory_Stock__c>>();
            Map<Id,Decimal> Mapexistingstock = new Map<Id,Decimal>();
            Map<Id,Set<Id>> MapexistingstockSerials = new Map<Id,Set<Id>>();
            String MOId = '';
            for(mrpWrap mrpWrapper : mrpWrappers){
                if(MOId == '') MOId = mrpWrapper.mrp.ERP7__MO__c;
                if(mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c != Null) selectedSite = mrpWrapper.mrp.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
                if(mrpWrapper.mrp.ERP7__MRP_Product__c != Null) proIds.add(mrpWrapper.mrp.ERP7__MRP_Product__c);
                MRPIds.add(mrpWrapper.mrp.Id);
            }
            List<ERP7__Stock_Outward_Line_Item__c> fulfilledStock = [Select Id,Name,ERP7__Quantity__c,ERP7__MRP_Material_Requirements_Planning__c,ERP7__MO_WO_Serial__c from ERP7__Stock_Outward_Line_Item__c where ERP7__MRP_Material_Requirements_Planning__c In:MRPIds and ERP7__Active__c =true];


            List<ERP7__Serial_Number__c> SNS = new List<ERP7__Serial_Number__c> ();
            Map<Id,ERP7__Serial_Number__c> SNSMap = new Map<Id,ERP7__Serial_Number__c> ();
            ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c();

            Set<Id> SerialNos = new Set<Id>();
            for(mrpWrap mrpWrapper : mrpWrappers){
                Decimal allocatedqty = 0;

                for(ERP7__Stock_Outward_Line_Item__c stk : fulfilledStock){
                    if(stk.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) {
                        allocatedqty += stk.ERP7__Quantity__c;
                        if(stk.ERP7__MO_WO_Serial__c != Null) SerialNos.add(stk.ERP7__MO_WO_Serial__c);
                        // system.debug('allocatedqty : '+allocatedqty);
                    }
                }
                MapexistingstockSerials.put(mrpWrapper.MRP.Id, SerialNos);
                if(allocatedqty > 0) Mapexistingstock.put(mrpWrapper.MRP.Id,allocatedqty);
            }
            fulfilledStock = new List<ERP7__Stock_Outward_Line_Item__c>();
            system.debug('Mapexistingstock : '+Mapexistingstock);
            system.debug('SerialNos : '+SerialNos);
            if(MOId != '') {
                MO = [Select Id, Name, ERP7__Product__r.ERP7__Serialise__c From ERP7__Manufacturing_Order__c Where Id =: MOId];
                if(MO.ERP7__Product__r.ERP7__Serialise__c == true) {
                    SNSMap = new Map<Id,ERP7__Serial_Number__c> ([Select Id, Name, ERP7__Material_Batch_Lot__c, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Serial_Number__c Where ERP7__Manufacturing_Order__c =: MO.Id and Id Not IN :SerialNos limit :AutostkLimit]);
                    SNS = SNSMap.Values();
                }
            }
            system.debug('*** SNS : '+SNS);
            if(selectedSite != Null && selectedSite != ''){
                String WarehouseFields = ERP7.UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + '';
                List<ERP7__Inventory_Stock__c> WIISLists = Database.query('select Id,Name,ERP7__Number_of_Item_In_Stock__c,ERP7__Version__c ,ERP7__Batch_Lot__c,ERP7__Serial__c,ERP7__Product__c, ERP7__Warehouse__c, ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, '+
                                                                          +' ERP7__StorageContainer__r.ERP7__Barcode__c from ERP7__Inventory_Stock__c where (ERP7__Warehouse__c =: selectedSite And (ERP7__Product__c In: proIds And ERP7__Number_of_Item_In_Stock__c > 0) And ERP7__Active__c = true) Order By ERP7__Expiry_Date__c ASC Limit 1000');


                for(Id proId : proIds){
                    Decimal myStock = 0;
                    if(!productSites.containsKey(proId)) productSites.put(proId, new List<ERP7__Inventory_Stock__c>());
                    for(ERP7__Inventory_Stock__c stock : WIISLists){
                        if(proId == stock.ERP7__Product__c){

                            myStock += stock.ERP7__Number_of_Item_In_Stock__c;
                            List<ERP7__Inventory_Stock__c> myStocks = productSites.get(proId);
                            myStocks.add(stock);
                            productSites.put(proId,myStocks);
                        }
                    }
                    stockMap.put(proId,myStock);

                }
                WIISLists = new List<ERP7__Inventory_Stock__c>();

            }

            system.debug('stockMap ; '+stockMap);
            List<ERP7__Stock_Outward_Line_Item__c> SDLIs2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();

            System.debug('Limits.getCpuTime 1- '+ Limits.getCpuTime());
            System.debug('Limits.getLimitCpuTime 1- '+ Limits.getLimitCpuTime());
            System.debug('Limits.getHeapSize 1- '+ Limits.getHeapSize());
            System.debug('Limits.getLimitHeapSize 1- '+ Limits.getLimitHeapSize());

            for(mrpWrap mrpWrapper : mrpWrappers){
                Decimal WM = mrpWrapper.WeightMultiplier;
                system.debug('Product : '+mrpWrapper.MRP.ERP7__MRP_Product__c+'   mrpWrapper.Stock : '+mrpWrapper.Stock+ ' 2.mrpWrapper.MRP.ERP7__Status__c : '+mrpWrapper.MRP.ERP7__Status__c+ ' 3.mrpWrapper.MRP.ERP7__Total_Amount_Required__c : '+mrpWrapper.MRP.ERP7__Total_Amount_Required__c);
                decimal stockAllocated = 0;
                if(mrpWrapper.Stock > 0 && mrpWrapper.MRP.ERP7__Status__c == 'Requested'){  //&& ((mrpWrapper.Stock >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c) || ((mrpWrapper.Stock + mrpWrapper.mrp.ERP7__Fulfilled_Amount__c) >= mrpWrapper.mrp.ERP7__Total_Amount_Required__c))
                    system.debug('if');
                    List<ERP7__Inventory_Stock__c> WIISs = productSites.get(mrpWrapper.MRP.ERP7__MRP_Product__c);

                    if(WIISs != Null && WIISs.size() > 0){
                        system.debug('WIISs : Not null ');
                        ERP7__Inventory_Stock__c WIIS = (mrpWrapper.MRP.ERP7__Check_Out_Process__c == 'LIFO')? WIISs[WIISs.size()-1] : WIISs[0];
                        system.debug('WIIS : '+WIIS.ERP7__Number_of_Item_In_Stock__c);


                        // Single WIIS straight forward reduction and reserving
                        if((WIIS.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.mrp.ERP7__Fulfilled_Amount__c/WM) >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM){
                            system.debug('In if 1');
                            if(SNS.size() > 0){
                                for(ERP7__Serial_Number__c SN : SNS){
                                    if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id)){
                                        system.debug('*** SNS In One: '+SN.Name);
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                        //if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - Mapexistingstock.get(mrpWrapper.MRP.Id) ;
                                        //else SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
                                        SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                        stockAllocated += SDLI.ERP7__Quantity__c;
                                        SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                        if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;
                                        if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                        if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c != Null){
                                            SDLI.ERP7__Unit_Price__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c != Null && mrpWrapper.MRP.ERP7__Total_Amount_Required__c > 0)? mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c/mrpWrapper.MRP.ERP7__Total_Amount_Required__c : 0;
                                            SDLI.ERP7__Total_Amount__c = SDLI.ERP7__Quantity__c*SDLI.ERP7__Unit_Price__c;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                        if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        SDLIs2Upsert.add(SDLI);
                                        MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                    }

                                }
                            }
                            else{
                                system.debug('*** SNS out One: ');
                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = WIIS.Id, ERP7__Version__c = WIIS.ERP7__Version__c);
                                if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) SDLI.ERP7__Quantity__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM - Mapexistingstock.get(mrpWrapper.MRP.Id) ;
                                else SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM).setScale(4);
                                stockAllocated += SDLI.ERP7__Quantity__c;
                                if(WIIS.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = WIIS.ERP7__Batch_Lot__c;
                                if(WIIS.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = WIIS.ERP7__Serial__c;
                                if(mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c != Null){
                                    SDLI.ERP7__Total_Amount__c = mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c;
                                    SDLI.ERP7__Unit_Price__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c != Null && mrpWrapper.MRP.ERP7__Total_Amount_Required__c > 0)? mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c/mrpWrapper.MRP.ERP7__Total_Amount_Required__c : 0;
                                }
                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                SDLIs2Upsert.add(SDLI);
                            }

                            mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (stockAllocated * WM);//mrpWrapper.MRP.ERP7__Total_Amount_Required__c; change added by shaguftha 11/09/23
                            mrpWrapper.Stock = mrpWrapper.Stock - stockAllocated;
                            system.debug('1 : mrpWrapper.MRP.ERP7__Fulfilled_Amount__c : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c);
                            mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                            if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c == mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                            MRPs2Upsert.add(mrpWrapper.MRP);
                            comW.errorMsg = '';
                            mrpWrapret.add(mrpWrapper);

                        }


                        //Multiple WIIS calculative Reserving and other calculations
                        else if(WIIS.ERP7__Number_of_Item_In_Stock__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM){
                            system.debug('else if 1');

                            //Need Change Imran
                            Decimal remainingqty = 0;
                            for(ERP7__Inventory_Stock__c stk : WIISs){
                                if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c != mrpWrapper.MRP.ERP7__Total_Amount_Required__c && mrpWrapper.MRP.ERP7__Fulfilled_Amount__c < mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                    if(SNS.size() > 0){
                                        Decimal WIISStock = stk.ERP7__Number_of_Item_In_Stock__c;
                                        while(SNSMap.values().size() > 0){
                                            ERP7__Serial_Number__c SN = SNSMap.values()[0];
                                            //for(ERP7__Serial_Number__c SN : SNS){
                                            if(!MapexistingstockSerials.get(mrpWrapper.MRP.Id).contains(SN.Id) && WIISStock > 0 && WIISStock >= (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM)){
                                                system.debug('*** SNS In two : '+SN.Name);
                                                ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                                //totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                                //if(((mrpWrapper.MRP.ERP7__Total_Amount_Required__c == stk.ERP7__Number_of_Item_In_Stock__c) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c > (stk.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c))) || remainingqty >= stk.ERP7__Number_of_Item_In_Stock__c || remainingqty == 0) { SDLI.ERP7__Quantity__c = stk.ERP7__Number_of_Item_In_Stock__c; system.debug('stk.ERP7__Number_of_Item_In_Stock__c 1 ***: '+stk.ERP7__Number_of_Item_In_Stock__c); }
                                                //else if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) { SDLI.ERP7__Quantity__c = remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id); system.debug('SDLI.ERP7__Quantity__c  1 ***: '+SDLI.ERP7__Quantity__c ); }
                                                //else { SDLI.ERP7__Quantity__c = remainingqty;  system.debug('remainingqty  1 ***: '+remainingqty );}//stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                                SDLI.ERP7__Quantity__c = (mrpWrapper.MRP.ERP7__BOM__r.ERP7__Quantity__c/WM).setScale(4);
                                                stockAllocated += SDLI.ERP7__Quantity__c;
                                                SDLI.ERP7__MO_WO_Serial__c = SN.Id;
                                                if(SN.ERP7__Material_Batch_Lot__c != Null) SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SN.ERP7__Material_Batch_Lot__c;

                                                if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                                if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                                if(mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c != Null){
                                                    SDLI.ERP7__Total_Amount__c = mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c;
                                                    SDLI.ERP7__Unit_Price__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c != Null && mrpWrapper.MRP.ERP7__Total_Amount_Required__c > 0)? mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c/mrpWrapper.MRP.ERP7__Total_Amount_Required__c : 0;
                                                }
                                                if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                                if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                                if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                                SDLIs2Upsert.add(SDLI);
                                                mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c*WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                                WIISStock = WIISStock - SDLI.ERP7__Quantity__c;
                                                system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                                MapexistingstockSerials.get(mrpWrapper.MRP.Id).add(SN.Id);
                                                if(WIISStock <= 0) break;
                                            }
                                            SNSMap.remove(SN.Id);
                                        }
                                    }
                                    else{
                                        system.debug('*** SNS out two: ');
                                        ERP7__Stock_Outward_Line_Item__c SDLI = new ERP7__Stock_Outward_Line_Item__c(Name = mrpWrapper.MRP.Name, ERP7__Active__c = true, ERP7__Process__c = mrpWrapper.MRP.ERP7__Process__c, ERP7__Schedule__c = mrpWrapper.MRP.ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c = mrpWrapper.MRP.Id, ERP7__BoM__c = mrpWrapper.MRP.ERP7__BOM__c, ERP7__Status__c = 'Reserved', ERP7__Product__c = mrpWrapper.MRP.ERP7__MRP_Product__c, ERP7__Site_Product_Service_Inventory_Stock__c = stk.Id, ERP7__Version__c = stk.ERP7__Version__c);
                                        //totalAllocatedQty += stk.ERP7__Number_of_Item_In_Stock__c;
                                        if(((mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM == stk.ERP7__Number_of_Item_In_Stock__c) || (mrpWrapper.MRP.ERP7__Total_Amount_Required__c/WM > (stk.ERP7__Number_of_Item_In_Stock__c + mrpWrapper.MRP.ERP7__Fulfilled_Amount__c/WM))) || remainingqty >= stk.ERP7__Number_of_Item_In_Stock__c || remainingqty == 0) { SDLI.ERP7__Quantity__c = stk.ERP7__Number_of_Item_In_Stock__c; system.debug('stk.ERP7__Number_of_Item_In_Stock__c 1 ***: '+stk.ERP7__Number_of_Item_In_Stock__c); }
                                        else if(Mapexistingstock.containsKey(mrpWrapper.MRP.Id) && remainingqty > Mapexistingstock.get(mrpWrapper.MRP.Id)) { SDLI.ERP7__Quantity__c = (remainingqty - Mapexistingstock.get(mrpWrapper.MRP.Id)).setScale(4); system.debug('SDLI.ERP7__Quantity__c  1 ***: '+SDLI.ERP7__Quantity__c ); }
                                        else { SDLI.ERP7__Quantity__c = (remainingqty).setScale(4);  system.debug('remainingqty  1 ***: '+remainingqty);}//stk.ERP7__Number_of_Item_In_Stock__c -  mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                        stockAllocated += SDLI.ERP7__Quantity__c;
                                        if(stk.ERP7__Batch_Lot__c != null) SDLI.ERP7__Material_Batch_Lot__c = stk.ERP7__Batch_Lot__c;
                                        if(stk.ERP7__Serial__c != null) SDLI.ERP7__Serial__c = stk.ERP7__Serial__c;
                                        if(mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c != Null){
                                            SDLI.ERP7__Total_Amount__c = mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c;
                                            SDLI.ERP7__Unit_Price__c = (mrpWrapper.MRP.ERP7__Total_Amount_Required__c != Null && mrpWrapper.MRP.ERP7__Total_Amount_Required__c > 0)? mrpWrapper.MRP.ERP7__BOM_Requirement_Cost__c/mrpWrapper.MRP.ERP7__Total_Amount_Required__c : 0;
                                        }
                                        if(mrpWrapper.MRP.ERP7__Work_Order__c != Null) SDLI.ERP7__Work_Orders__c = mrpWrapper.MRP.ERP7__Work_Order__c;
                                        if(mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c != Null) SDLI.ERP7__Work_Order_Line_Items__c = mrpWrapper.MRP.ERP7__Work_Order_Line_Items__c;
                                        if(mrpWrapper.MRP.ERP7__MO__c != Null) SDLI.ERP7__Manufacturing_Order__c = mrpWrapper.MRP.ERP7__MO__c;
                                        SDLIs2Upsert.add(SDLI);
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + (SDLI.ERP7__Quantity__c*WM);//(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c + stk.ERP7__Number_of_Item_In_Stock__c).setscale(4);
                                        system.debug('SDLI else if 2: '+SDLI.ERP7__Quantity__c+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                    }

                                    //mrpWrapper.Stock = mrpWrapper.Stock - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                                    remainingqty = ((mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c)/WM).setScale(4);
                                    if(remainingqty < 0) remainingqty = 0;

                                    if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c >= mrpWrapper.MRP.ERP7__Total_Amount_Required__c){
                                        Decimal totalFulfilled =  (Mapexistingstock.containsKey(mrpWrapper.MRP.Id)) ?  (Mapexistingstock.get(mrpWrapper.MRP.Id)) : 0;
                                        for(ERP7__Stock_Outward_Line_Item__c ss : SDLIs2Upsert){
                                            if(ss.ERP7__MRP_Material_Requirements_Planning__c == mrpWrapper.MRP.Id) totalFulfilled += ss.ERP7__Quantity__c;
                                        }
                                        mrpWrapper.MRP.ERP7__Fulfilled_Amount__c = (totalFulfilled*WM).setScale(4);
                                        system.debug('totalFulfilled else if 2 after: '+totalFulfilled+' MRP QTy : '+mrpWrapper.MRP.ERP7__Fulfilled_Amount__c );
                                        if(mrpWrapper.MRP.ERP7__Fulfilled_Amount__c == mrpWrapper.MRP.ERP7__Total_Amount_Required__c) mrpWrapper.MRP.ERP7__Status__c = 'Reserved';
                                        system.debug('mrpWrapper.Stock  : '+mrpWrapper.Stock);
                                        comW.errorMsg = '';
                                        //mrpWrapret.add(mrpWrapper);
                                        break;
                                    }

                                }
                            }
                            system.debug('stockAllocated : '+stockAllocated);
                            system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                            mrpWrapper.MRPQuantity = mrpWrapper.MRP.ERP7__Total_Amount_Required__c - mrpWrapper.MRP.ERP7__Fulfilled_Amount__c;
                            mrpWrapper.Stock = mrpWrapper.Stock - stockAllocated;
                            MRPs2Upsert.add(mrpWrapper.MRP);
                            mrpWrapret.add(mrpWrapper);
                            system.debug('MRPs2Upsert : '+MRPs2Upsert);
                        } // Multiple WIIS


                    } // WIIS size > 0
                } // MRP Stock > 0
            }
            mrpWrappers = new List<mrpWrap>();
            System.debug('Limits.getCpuTime 2- '+ Limits.getCpuTime());
            System.debug('Limits.getLimitCpuTime 2- '+ Limits.getLimitCpuTime());
            System.debug('Limits.getHeapSize 2- '+ Limits.getHeapSize());
            System.debug('Limits.getLimitHeapSize 2- '+ Limits.getLimitHeapSize());
            system.debug('MRPs2Upsert.size() : '+MRPs2Upsert.size());
            system.debug('SDLIs2Upsert.size() : '+SDLIs2Upsert.size());
            if(SDLIs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler=false; upsert SDLIs2Upsert;}else{comW.errorMsg ='Not allowed to upsert SDLI';} }
            SDLIs2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            if(MRPs2Upsert.size() > 0){ if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()){PreventRecursiveLedgerEntry.MRPFlowTrigger = false; upsert MRPs2Upsert;}else{comW.errorMsg ='Not allowed to upsert MRPs';} }
            List<mrpWrap> retunrMRP = new List<mrpWrap>();
            for(mrpWrap mrpWrapper : mrpWrapret){
                for(ERP7__MRP__c mrp : MRPs2Upsert){
                    if(mrpWrapper.MRP.ERP7__MRP_Product__c == mrp.ERP7__MRP_Product__c){
                        mrpWrapper.MRP = mrp;
                      //  mrpWrapper.Stock = mrpWrapper.Stock - (mrp.ERP7__Fulfilled_Amount__c / mrpWrapper.WeightMultiplier);
                        system.debug('mrpWrapper.Stock : '+mrpWrapper.Stock);
                    }
                }
                retunrMRP.add(mrpWrapper);
            }

            comW.MRPSS=retunrMRP;
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 12@ : '+ e.getLineNumber();  }
        return comW;
    }

    @AuraEnabled
    public static comWrap MRPEdit(String MRP, String MRPs){
        comWrap comWrapper = new comWrap();
        try{
            List<Id> bomIds = new List<Id>();
            mrpWrap mrpWrapper = (mrpWrap) JSON.deserialize(MRP, mrpWrap .class);
            List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
            for(mrpWrap mrrp : mrpWrappers){
                if(mrrp.MRP.ERP7__BOM__c != Null) bomIds.add(mrrp.MRP.ERP7__BOM__c);
            }

            comWrapper.AlternativeBOMs = [Select Id, Name, ERP7__Bill_Of_Material__c, ERP7__BOM_Variance__c, ERP7__Product__c, ERP7__Product_Feature__c, ERP7__Type__c, ERP7__BOM_Variance__r.ERP7__BOM_Component__r.Name,
                                          ERP7__BOM_Variance__r.ERP7__BOM_Component__c, ERP7__BOM_Variance__r.RecordType.Name, ERP7__BOM_Variance__r.RecordTypeId, ERP7__BOM_Variance__r.ERP7__BOM_Version__c,
                                          ERP7__BOM_Variance__r.ERP7__Unit_of_Measure__c
                                          From ERP7__Variance__c
                                          Where ERP7__Type__c = 'Alternative' And
                                          ERP7__BOM_Variance__r.ERP7__BOM_Version__c =: mrpWrapper.MRP.ERP7__BOM__r.ERP7__BOM_Version__c And
                                          //ERP7__Bill_Of_Material__c Not In: bomIds //And
                                          ERP7__Bill_Of_Material__c = :mrpWrapper.MRP.ERP7__BOM__c
                                         ];

            String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
            String AllWarehouseFields = WarehouseFields + '';
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            for(ERP7__Variance__c bom : comWrapper.AlternativeBOMs){
                if(bom.ERP7__BOM_Variance__r.ERP7__BOM_Component__c != Null) proIds.add(bom.ERP7__BOM_Variance__r.ERP7__BOM_Component__c);
            }
            String selectedSite = mrpWrapper.MRP.ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            if(selectedSite != Null && selectedSite != ''){
                List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                    +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC');
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){ if(proId == stock.Product__c){  myStock += stock.Number_of_Item_In_Stock__c; }
                                                             }
                    stockMap.put(proId,myStock);
                }
            }
            comWrapper.MRPSS = new List<mrpWrap>();
            Id rTpe_MRPMAN = Schema.SObjectType.ERP7__MRP__c.getRecordTypeInfosByDeveloperName().get('MRP_Manufacturing').getRecordTypeId();
            for(ERP7__Variance__c bom : comWrapper.AlternativeBOMs){
                mrpWrap mrpW = new mrpWrap();
                ERP7__MRP__c MRPn = new ERP7__MRP__c(Name = BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__r.Name,ERP7__Total_Amount_Required__c = mrpWrapper.MRP.ERP7__Total_Amount_Required__c,ERP7__BOM__c = BOM.ERP7__BOM_Variance__c,ERP7__MRP_Product__c = BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__c,ERP7__Version__c = BOM.ERP7__BOM_Variance__r.ERP7__BOM_Version__c, ERP7__MO__c = mrpWrapper.MRP.ERP7__MO__c);
                mrpW.Qnty = mrpWrapper.MRP.ERP7__Total_Amount_Required__c;
                if(bom.ERP7__BOM_Variance__r.RecordType.Name == 'Manufacturing BOM' && rTpe_MRPMAN != null) MRPn.RecordTypeId = rTpe_MRPMAN;
                mrpW.MRP = MRPn;
                if(stockMap.containsKey(BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__c)) mrpW.Stock = stockMap.get(BOM.ERP7__BOM_Variance__r.ERP7__BOM_Component__c);
                comWrapper.MRPSS.add(mrpW);
            }
        } catch(Exception e) { comWrapper.errorMsg = e.getMessage() +' Line Number 13@ : '+ e.getLineNumber(); }
        return comWrapper;
    }

    @AuraEnabled
    public static comWrap MRPUpdate(String  MRP1){
        ERP7__MRP__c MRP = (ERP7__MRP__c) JSON.deserialize(MRP1, ERP7__MRP__c.class);
        comWrap comWrapper = new comWrap();
        try{
            if(Schema.SObjectType.ERP7__MRP__c.isCreateable() && Schema.SObjectType.ERP7__MRP__c.isUpdateable()) { upsert MRP; } else {/*No access*/}
        } catch(Exception e) { comWrapper.errorMsg = e.getMessage() +' Line Number 14@ : '+ e.getLineNumber(); }
        return comWrapper;
    }

    @AuraEnabled
    public static comWrap MRPUpdateNew(String  mrpMain1, String alternateMrps){
        ERP7__MRP__c mrpMain = (ERP7__MRP__c) JSON.deserialize(mrpMain1, ERP7__MRP__c.class);
        List<mrpWrap> mrpWrapper = (List<mrpWrap>) JSON.deserialize(alternateMrps, List<mrpWrap> .class);
        comWrap comWrapper = new comWrap();
        try{
            //upsert mrpMain;
            List<ERP7__MRP__c> alternateMrps2upsert = new List<ERP7__MRP__c>();
            List<ERP7__MRP__c> alternateMrps2delete = new List<ERP7__MRP__c>();

            for(mrpWrap mrp : mrpWrapper){
                if(mrp.isSelect && mrp.Qnty > 0) { if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Total_Amount_Required__c.isUpdateable()){mrp.MRP.ERP7__Total_Amount_Required__c = mrp.Qnty;}else{/*No access*/} alternateMrps2upsert.add(mrp.MRP); }
            }
            if((mrpMain.ERP7__BOM__r.ERP7__Is_Protected__c == true && alternateMrps2upsert.size() > 0) || !(mrpMain.ERP7__Total_Amount_Required__c > 0)) alternateMrps2delete.add(mrpMain);
            else alternateMrps2upsert.add(mrpMain);

            if(alternateMrps2upsert.size() > 0){
                if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) { upsert alternateMrps2upsert; } else {/*No access*/}
            }
            if(alternateMrps2delete.size() > 0){  if(ERP7__MRP__c.sObjectType.getDescribe().isDeletable()) { delete alternateMrps2delete; } else {/*No access*/}
                                               }
        } catch(Exception e) { comWrapper.errorMsg = e.getMessage() +' Line Number 15@ : '+ e.getLineNumber(); }
        return comWrapper;
    }

    @AuraEnabled
    public static comWrap SaveNewSOLI(String NewSOLI, String MRPs, String SerialNos){
        Savepoint sp = Database.setSavepoint();
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        ERP7__Stock_Outward_Line_Item__c mySOLI = (ERP7__Stock_Outward_Line_Item__c) JSON.deserialize(NewSOLI, ERP7__Stock_Outward_Line_Item__c .class);
        List<Id> moSerialNos = (List<Id>) JSON.deserialize(SerialNos, List<Id> .class);
        mrpWrap mrp = new mrpWrap();
        for(mrpWrap mrpW : mrpWrappers){
            if(mrpW.isSelect){
                mrp = mrpW;
                break;
            }
        }
        comWrap comW = new comWrap();
        comW.errorMsg = '';
        try{
            Decimal WM = mrp.WeightMultiplier;
            if(mrp.Stock > 0 && mrp.MRP.ERP7__Status__c == 'Requested' && mrp.Stock >= mrp.mrp.ERP7__Total_Amount_Required__c && mrp.MRP.ERP7__Fulfilled_Amount__c == mrp.MRP.ERP7__Total_Amount_Required__c){ if(Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.Status__c.isUpdateable()){mrp.MRP.Status__c = 'Reserved';}else{/*No access*/} }
            String selectedSite = mrp.MRP.ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            String Prod = mrp.MRP.ERP7__MRP_Product__c;
            if(selectedSite != Null && selectedSite != ''){
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + '';
                List<Inventory_Stock__c> WIISLists = new List<Inventory_Stock__c> ();
                if(!mrp.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c && !mrp.MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c)WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c =: Prod And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC');
                else if(mrp.MRP.ERP7__MRP_Product__r.ERP7__Serialise__c){
                    List<ERP7__Stock_Inward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                                                                    Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c,
                                                                    ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c
                                                                    From ERP7__Stock_Inward_Line_Item__c
                                                                    Where Product__c = :Prod And
                                                                    ERP7__Serial__c != Null And
                                                                    ERP7__Serial__r.ERP7__Available__c = true And
                                                                    ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And
                                                                    ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c = : selectedSite And
                                                                    ERP7__Serial__c = :mySOLI.ERP7__Serial__c Limit 1];
                    if(SDLIs.size() > 0){
                        String stkId = SDLIs[0].ERP7__Site_ProductService_InventoryStock__c;      WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, StorageContainer__r.Barcode__c from Inventory_Stock__c where Id =: stkId');
                    }
                }else if(mrp.MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c){                String batch = mySOLI.ERP7__Material_Batch_Lot__c;       WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', ERP7__Warehouse__r.Name, ERP7__Location__r.Name, ERP7__StorageContainer__r.Name, ERP7__Warehouse__r.ERP7__Barcode__c, ERP7__Location__r.ERP7__Barcode__c, ERP7__StorageContainer__r.ERP7__Barcode__c from Inventory_Stock__c where (ERP7__Warehouse__c =: selectedSite And (ERP7__Product__c =: Prod And ERP7__Number_of_Item_In_Stock__c > 0) And ERP7__Active__c = true And ERP7__Batch_Lot__c =: batch) Order By ERP7__Expiry_Date__c ASC');
                }
                Decimal myStock = 0;
                for(Inventory_Stock__c stock : WIISLists){  myStock += stock.Number_of_Item_In_Stock__c; }
                mySOLI.ERP7__Quantity__c = mySOLI.ERP7__Quantity__c.setScale(4);

                Decimal totalQuantity = (moSerialNos.size() > 0)? mySOLI.ERP7__Quantity__c * moSerialNos.size() : mySOLI.ERP7__Quantity__c;

                if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){
                    mrp.MRP.ERP7__Fulfilled_Amount__c = (mrp.MRP.ERP7__Fulfilled_Amount__c != null) ? mrp.MRP.ERP7__Fulfilled_Amount__c.setScale(4) : 0; //.setScale(4)
                }else{/*No access*/}
                if(myStock >= totalQuantity){
                    Decimal AllocatedStock = 0;
                    List<ERP7__Stock_Outward_Line_Item__c> SOLIs2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
                    if(moSerialNos.size() == 0){
                        for(Inventory_Stock__c stock : WIISLists){
                            if(AllocatedStock < totalQuantity){
                                ERP7__Stock_Outward_Line_Item__c myNewSOLI = new ERP7__Stock_Outward_Line_Item__c();
                                if(mySOLI.ERP7__Quantity__c <= stock.Number_of_Item_In_Stock__c){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = mySOLI.ERP7__Quantity__c;}else{/*No access*/}  }
                                else{ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = stock.Number_of_Item_In_Stock__c;}else{/*No access*/} }
                                AllocatedStock += myNewSOLI.ERP7__Quantity__c;               mrp.ActualWeight += myNewSOLI.ERP7__Quantity__c;                 if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){myNewSOLI.ERP7__Product__c = mrp.MRP.ERP7__MRP_Product__c;}else{/*No access*/}                         if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){myNewSOLI.ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id;}else{/*No access*/}                   if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){myNewSOLI.ERP7__Status__c = 'Reserved';}else{/*No access*/}                if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){myNewSOLI.ERP7__Version__c = mrp.MRP.ERP7__Version__c;}else{/*No access*/}                if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){myNewSOLI.ERP7__Active__c = true;}else{/*No access*/}       if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isUpdateable()){myNewSOLI.ERP7__MRP_Material_Requirements_Planning__c = mrp.MRP.Id;}else{/*No access*/}if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isUpdateable()){myNewSOLI.ERP7__BoM__c = mrp.MRP.ERP7__BOM__c;}else{/*No access*/}          if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isUpdateable()){myNewSOLI.ERP7__Work_Orders__c = mrp.MRP.ERP7__Work_Order__c;}else{/*No access*/}         if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){myNewSOLI.ERP7__Manufacturing_Order__c = mrp.MRP.ERP7__MO__c;}else{/*No access*/}                       if(mySOLI.ERP7__Material_Batch_Lot__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){myNewSOLI.ERP7__Material_Batch_Lot__c = mySOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/} }              if(mySOLI.ERP7__Serial__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){myNewSOLI.ERP7__Serial__c = mySOLI.ERP7__Serial__c;}else{/*No access*/} }             if(mySOLI.ERP7__MO_WO_Material_Batch_Lot__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isUpdateable()){myNewSOLI.ERP7__MO_WO_Material_Batch_Lot__c = mySOLI.ERP7__MO_WO_Material_Batch_Lot__c;}else{/*No access*/} }            if(mySOLI.ERP7__MO_WO_Serial__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isUpdateable()){myNewSOLI.ERP7__MO_WO_Serial__c = mySOLI.ERP7__MO_WO_Serial__c;}else{/*No access*/} }

                                if(mrp.MRP.BOM_Requirement_Cost__c != Null){                             mySOLI.Total_Amount__c = mrp.MRP.BOM_Requirement_Cost__c/WM;        mySOLI.Unit_Price__c = (mrp.MRP.Total_Amount_Required__c != Null && mrp.MRP.Total_Amount_Required__c > 0)? (mrp.MRP.BOM_Requirement_Cost__c/mrp.MRP.Total_Amount_Required__c)/WM : 0;
                                }
                                SOLIs2Upsert.add(myNewSOLI);
                            }
                        }
                    } else{
                        for(Inventory_Stock__c stock : WIISLists){
                            for(Id moSNId:  moSerialNos){
                                if(AllocatedStock < totalQuantity){
                                    ERP7__Stock_Outward_Line_Item__c myNewSOLI = new ERP7__Stock_Outward_Line_Item__c();
                                    if(mySOLI.ERP7__Quantity__c <= stock.Number_of_Item_In_Stock__c){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = mySOLI.ERP7__Quantity__c;}else{/*No access*/}  }
                                    else{ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable()){myNewSOLI.ERP7__Quantity__c = stock.Number_of_Item_In_Stock__c;}else{/*No access*/} }
                                    AllocatedStock += myNewSOLI.ERP7__Quantity__c;   mrp.ActualWeight += myNewSOLI.ERP7__Quantity__c;
                                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){myNewSOLI.ERP7__Product__c = mrp.MRP.ERP7__MRP_Product__c;}else{/*No access*/}                     if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){myNewSOLI.ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id;}else{/*No access*/}                 if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){myNewSOLI.ERP7__Status__c = 'Reserved';}else{/*No access*/}              if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Version__c.isUpdateable()){myNewSOLI.ERP7__Version__c = mrp.MRP.ERP7__Version__c;}else{/*No access*/}               if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){myNewSOLI.ERP7__Active__c = true;}else{/*No access*/}                  if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isUpdateable()){myNewSOLI.ERP7__MRP_Material_Requirements_Planning__c = mrp.MRP.Id;}else{/*No access*/}                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isUpdateable()){myNewSOLI.ERP7__BoM__c = mrp.MRP.ERP7__BOM__c;}else{/*No access*/}                  if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Work_Orders__c.isUpdateable()){myNewSOLI.ERP7__Work_Orders__c = mrp.MRP.ERP7__Work_Order__c;}else{/*No access*/}              if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){myNewSOLI.ERP7__Manufacturing_Order__c = mrp.MRP.ERP7__MO__c;}else{/*No access*/}                            if(mySOLI.ERP7__Material_Batch_Lot__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){myNewSOLI.ERP7__Material_Batch_Lot__c = mySOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/} }                     if(mySOLI.ERP7__Serial__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){myNewSOLI.ERP7__Serial__c = mySOLI.ERP7__Serial__c;}else{/*No access*/} }               if(mySOLI.ERP7__MO_WO_Material_Batch_Lot__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Material_Batch_Lot__c.isUpdateable()){myNewSOLI.ERP7__MO_WO_Material_Batch_Lot__c = mySOLI.ERP7__MO_WO_Material_Batch_Lot__c;}else{/*No access*/} }    if(mySOLI.ERP7__MO_WO_Serial__c != Null){ if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.fields.ERP7__MO_WO_Serial__c.isUpdateable()){myNewSOLI.ERP7__MO_WO_Serial__c = moSNId;}else{/*No access*/} }if(mrp.MRP.BOM_Requirement_Cost__c != Null){mySOLI.Total_Amount__c = mrp.MRP.BOM_Requirement_Cost__c/WM;         mySOLI.Unit_Price__c = (mrp.MRP.Total_Amount_Required__c != Null && mrp.MRP.Total_Amount_Required__c > 0)? (mrp.MRP.BOM_Requirement_Cost__c/mrp.MRP.Total_Amount_Required__c)/WM : 0;
                                    }
                                    SOLIs2Upsert.add(myNewSOLI);
                                }
                            }
                        }
                    }
                    PreventRecursiveLedgerEntry.testCasesTransactions = true;
                    if(Schema.sObjectType.ERP7__MRP__c.isCreateable() && Schema.sObjectType.ERP7__MRP__c.isUpdateable()) { upsert mrp.MRP; } else {/*No access*/}
                    if(SOLIs2Upsert.size()>0) {
                        if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.isUpdateable()){ upsert SOLIs2Upsert; } else {/*No access*/}
                    }
                    mrp.SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
                                 ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
                                 From ERP7__Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c =: mrp.MRP.Id];
                    comW.MRPSS = mrpWrappers;
                }
                else{
                    Database.rollback( sp );
                    comW.errorMsg = 'Invalid Stock';
                }
            }else{
                Database.rollback( sp );  comW.errorMsg = 'Invalid Stock';
            }
        } catch(Exception e) { Database.rollback( sp ); comW.errorMsg = e.getMessage() +' Line Number 16@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static Product2 GetDefaults(String  proId){
        return [Select Id, Name, ERP7__Version__c, ERP7__Routing__c From Product2 Where Id =: proId Limit 1];
    }

    @AuraEnabled
    public static comWrap SaveAllMRPs(String MRPs){
        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        comWrap comW = new comWrap();
        try{
            comW.errorMsg = '';
            List<ERP7__MRP__c> MRPs2Upsert = new List<ERP7__MRP__c>();
            for(mrpWrap mrpWrapper : mrpWrappers){
                MRPs2Upsert.add(mrpWrapper.MRP);
            }
            if(MRPs2Upsert.size() > 0) {
                if(Schema.SObjectType.ERP7__MRP__c.isCreateable() && Schema.SObjectType.ERP7__MRP__c.isUpdateable()){ upsert MRPs2Upsert; } else {/*No access*/}
            }
        } catch(Exception e) {  comW.errorMsg = e.getMessage() +' Line Number 17@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap DeleteSOLI(String SOLI, String MRPs){

        List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
        ERP7__Stock_Outward_Line_Item__c mySOLI = [Select Id, Name, ERP7__Quantity__c from ERP7__Stock_Outward_Line_Item__c where Id =:SOLI];

        mrpWrap mrp = new mrpWrap();
        for(mrpWrap mrpW : mrpWrappers){
            if(mrpW.isSelect) mrp = mrpW;
        }
        comWrap comW = new comWrap();
        comW.errorMsg = '';
        try{
            if(mrp.isSelect){
                if(ERP7__Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) { delete mySOLI; } else { }
                mrp.ActualWeight -= (mySOLI.ERP7__Quantity__c);
                if(mrp.MRP.ERP7__Fulfilled_Amount__c >= mySOLI.ERP7__Quantity__c){ if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){mrp.MRP.ERP7__Fulfilled_Amount__c -= (mySOLI.ERP7__Quantity__c*mrp.WeightMultiplier);}else{/*No access*/} }
                else { if(Schema.sObjectType.ERP7__MRP__c.fields.ERP7__Fulfilled_Amount__c.isUpdateable()){mrp.MRP.ERP7__Fulfilled_Amount__c = 0;}else{/*No access*/} }
                if(Schema.sObjectType.ERP7__MRP__c.isUpdateable()) { update mrp.MRP; } else {/*No access*/}

                mrp.SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
                             ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
                             From ERP7__Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c =: mrp.MRP.Id];
                comW.MRPSS = mrpWrappers; } } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 18@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap StartWORec(String RecId){
        comWrap comW = new comWrap();
        try{
            WO__c WO = [Select Id, Name, ERP7__Start_Date__c, Status__c from ERP7__WO__c Where Id =: RecId];
            if(Schema.sObjectType.WO__c.fields.Status__c.isCreateable() && Schema.sObjectType.WO__c.fields.Status__c.isUpdateable()){WO.Status__c = 'In Progress';}else{/*No access*/}
            if(Schema.sObjectType.WO__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.WO__c.fields.ERP7__Start_Date__c.isUpdateable()){WO.ERP7__Start_Date__c = system.Now();}else{/*No access*/}
            if(Schema.sObjectType.WO__c.isCreateable() && Schema.sObjectType.WO__c.isUpdateable()){ upsert WO; } else {/*No access*/} } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 19@ : '+ e.getLineNumber(); }
        return comW;
    }

  @AuraEnabled
  public static Manufacturing_Order__c getMOData(Id moId){
    return [SELECT Id, OwnerId, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, ERP7__Product__c, ERP7__Version__c, ERP7__Status__c, ERP7__Is_Closed__c, ERP7__Quantity__c, ERP7__Labour_Cost__c, ERP7__Material_Cost__c, ERP7__Overhead_Cost__c, ERP7__Cost__c, ERP7__Routing__c, ERP7__Serialise__c, ERP7__Lot_Tracked__c, ERP7__Is_Kit__c, ERP7__In_Production__c, ERP7__Progress__c, ERP7__Booked__c, ERP7__Quantity_Produced__c, ERP7__Manufactured_Quantity__c, ERP7__Finished_Products_SiteId__c, ERP7__StartDate__c, ERP7__End_Date__c, ERP7__Duration__c, ERP7__Scrapped_Quantity__c, ERP7__Quantity_Scrapped__c, ERP7__Initiate_MO__c, ERP7__Escape_Process__c, ERP7__ExpectedDate__c, ERP7__Is_Signature_Required__c, ERP7__Escape_BOMS__c, ERP7__Owner__c, ERP7__Scrap_Cost__c, ERP7__Scrap_Quantity__c, ERP7__Rejected_Cost__c, ERP7__Remaining_Quantity__c, ERP7__Stage__c,
    ERP7__Product__r.Name, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c,
    ERP7__Product__r.ERP7__UoM__c, ERP7__Product__r.QuantityUnitOfMeasure, ERP7__Product__r.Id,
    ERP7__Routing__r.Name, ERP7__Routing__r.ERP7__Raw_Materials_Site__c,
    ERP7__Routing__r.ERP7__Finished_Products_Site__c, ERP7__Routing__r.ERP7__Process__c,
    ERP7__Routing__r.ERP7__Finished_Products_Site__r.Name, ERP7__Routing__r.ERP7__Finished_Products_Site__r.Id,
    ERP7__Version__r.Name, ERP7__Version__r.Id
      FROM Manufacturing_Order__c
      WHERE Id = :moId
];
  }

    @AuraEnabled
    public static comWrap GetWORec(String RecId,String MO){
        comWrap comWrap = new comWrap();
        try{
            String allFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(allFields.split(','),'ERP7__WO__c');
            String querywo = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__WO__c ';
            querywo += 'where Id = :RecId';
            System.debug('Generated Query for WO: ' + querywo); // Line before execution
            ERP7__WO__c WO2Finish = Database.query(querywo);
            System.debug('WO2Finish record: ' + JSON.serialize(WO2Finish));
            comWrap.WorkOrder = WO2Finish;
            system.debug('comWrap.MRPSS.size() : '+comWrap.MRPSS.size());
            if(comWrap.MRPSS.size()<=0){
                comWrap.MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__Fulfilled_Amount__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Picture__c, ERP7__MRP_Product__r.QuantityUnitOfMeasure, ERP7__BOM__r.ERP7__Unit_of_Measure__c,
                                ERP7__MRP_Product__r.ERP7__Scrap_Variant__c, ERP7__MRP_Product__r.ERP7__Preview_Image__c, ERP7__Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__Work_Order__c, Process_Cycle__c, ERP7__Notes__c,  ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                                ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name
                                From ERP7__MRP__c
                                Where Process_Cycle__c = : WO2Finish.ERP7__Process_Cycle__c And
                                //ERP7__Action_Task__c =: Task.Id And
                                ERP7__Work_Order__c = : WO2Finish.ID  Order By ERP7__BOM__r.ERP7__Sort__c ASC];
                String SILIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');
                String AllSILIFields = SILIFields + '';
                List<Id> mrpIds = new List<Id>();
                Map<Id,set<Id>> MRPSerialIds = new  Map<Id,set<Id>>();
                for(ERP7__MRP__c MRP : comWrap.MRPS) mrpIds.add(MRP.Id);
                comWrap.MRPSS = new List<mrpWrap>();
                if(MO != null && MO != '')
                {
                    ERP7__Manufacturing_Order__c MOs = (ERP7__Manufacturing_Order__c) JSON.deserialize(MO, ERP7__Manufacturing_Order__c.class);
                    if(MOs.ERP7__Product__r.ERP7__Serialise__c){
                        set<Id> serialIDs = new set<Id>();
                        set<Id> serialIDallocatedStock = new set<Id>();
                        List<ERP7__Stock_Inward_Line_Item__c> inwardsProduced = [Select Id,Name,ERP7__Serial__c,ERP7__Quantity__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Manufacturing_Order__c = : MOs.Id and ERP7__Quantity__c > 0 and ERP7__Serial__c != null and Name != 'Awaiting Stock'];
                        for(ERP7__Stock_Inward_Line_Item__c sin : inwardsProduced) serialIDs.add(sin.ERP7__Serial__c);
                        inwardsProduced = new List<ERP7__Stock_Inward_Line_Item__c>();
                        List<ERP7__Stock_Outward_Line_Item__c> SOLIs = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.Name, ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
                                                                        ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c
                                                                        From Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c In: mrpIds and ERP7__MO_WO_Serial__c NOT IN:serialIDs and ERP7__MO_WO_Serial__c != null];

                        for(ERP7__Stock_Outward_Line_Item__c stk : SOLIs){
                            if(stk.ERP7__MO_WO_Serial__c != null && stk.ERP7__MRP_Material_Requirements_Planning__c != null) {
                                if(!MRPSerialIds.containsKey(stk.ERP7__MRP_Material_Requirements_Planning__c)) MRPSerialIds.put(stk.ERP7__MRP_Material_Requirements_Planning__c, new set<Id>{stk.ERP7__MO_WO_Serial__c});
                                else MRPSerialIds.get(stk.ERP7__MRP_Material_Requirements_Planning__c).add(stk.ERP7__MO_WO_Serial__c);
                                serialIDallocatedStock.add(stk.ERP7__MO_WO_Serial__c);
                            }
                        }
                        SOLIs = new List<Stock_Outward_Line_Item__c>();
                        List<ERP7__Serial_Number__c> serList = new  List<ERP7__Serial_Number__c>();
                        if(serList.size() > 0) serList =  [Select Id,Name,ERP7__Available__c,ERP7__Scrap__c,ERP7__Manufacturing_Order__c from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c = : MOs.Id and Id NOT IN: serialIDs and Id IN: serialIDallocatedStock and (ERP7__Available__c = false and ERP7__Scrap__c = false) Order By Name];
                        else serList =  [Select Id,Name,ERP7__Available__c,ERP7__Scrap__c,ERP7__Manufacturing_Order__c from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c = : MOs.Id and Id NOT IN: serialIDs  and (ERP7__Available__c = false and ERP7__Scrap__c = false) Order By Name];
                        comWrap.moSerialNos = serList;
                    }

                }

                for(ERP7__MRP__c mrp : comWrap.MRPS) {
                    mrpWrap mrpWrapp = new mrpWrap();
                    mrpWrapp.MRP = mrp;
                    mrpWrapp.SOLI = new ERP7__Stock_Outward_Line_Item__c(ERP7__Product__c=mrp.ERP7__MRP_Product__c, ERP7__Status__c='Reserved', ERP7__Active__c=true, ERP7__MRP_Material_Requirements_Planning__c=mrp.Id, ERP7__BoM__c=mrp.ERP7__BOM__c); //ERP7__Serial__c, ERP7__Material_Batch_Lot__c,
                    if(mrp.ERP7__MO__c != Null) mrpWrapp.SOLI.ERP7__Manufacturing_Order__c=mrp.ERP7__MO__c;
                    //for(ERP7__Stock_Inward_Line_Item__c SILI : SILIS) { if(SILI.ERP7__MRP_Material_Requirement_Planning__c == mrp.Id){ mrpWrapp.SILIS.add(SILI);   mrpWrapp.SOLI.ERP7__Site_Product_Service_Inventory_Stock__c = SILI.ERP7__Site_ProductService_InventoryStock__c; } }
                    if(mrp.ERP7__MRP_Product__r.ERP7__Serialise__c == true) comWrap.Serial = true;
                    if(mrp.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true) comWrap.Batch = true;
                    if(MRPSerialIds.containsKey(mrp.Id)) {
                        mrpWrapp.StockallocatedSerials = new List<Id>(MRPSerialIds.get(mrp.Id));
                    }
                    comWrap.MRPSS.add(mrpWrapp);
                }

            }
        } catch(Exception e) { comWrap.errorMsg = e.getMessage() +' Line Number getWORec@ : '+ e.getLineNumber(); }
        return comWrap;
    }

    @AuraEnabled
    public static comWrap UpdateWORec(String WO2Update1, String WIPFlows){
        ERP7__WO__c WO2Update = (ERP7__WO__c) JSON.deserialize(WO2Update1, ERP7__WO__c.class);

        comWrap comWrap = new comWrap();
        try{
            Boolean updateqty = false;
            List<WIPFlowWrap> WIP_Flows = (List<WIPFlowWrap>) JSON.deserialize(WIPflows, List<WIPFlowWrap>.class);
            // List<ERP7__WIP_Flow__c> WIP_Flows = (List<ERP7__WIP_Flow__c>) JSON.deserialize(WIPFlows, List<ERP7__WIP_Flow__c> .class);
            if(WIP_Flows.size() > 0) {
                //if(schema.SObjectType.ERP7__WIP_Flow__c.isUpdateable()){ update WIP_Flows; } else{ }
                for(WIPFlowWrap wip : WIP_Flows){
                    system.debug('wip : '+wip);
                    if(wip.wipFlow != null) {         if(wip.wipFlow.ERP7__Product__c != wip.wipFlow.ERP7__Work_Orders__r.ERP7__Product__c && wip.wipFlow.ERP7__Status__c== 'Completed' && wip.wipFlow.ERP7__Type__c== 'Processed'){ updateqty = true;   } else{ updateqty = false;   }
                    }
                }
            }
            system.debug('updateqty : '+updateqty);
            if(updateqty && WO2Update.ERP7__Quantity_Scrapped__c == 0){ if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Built__c.isUpdateable()){WO2Update.ERP7__Quantity_Built__c = WO2Update.ERP7__Quantity_Ordered__c;}else{/*No access*/} }
            if(Schema.sObjectType.ERP7__WO__c.isUpdateable()){ update WO2Update; }else{/*No access*/}
            /* commented from 2132 to 2155 by shaguftha on 08/08/2023 to avoid the update of next WO ordered qty */
            /*List<ERP7__WO__c> allmo_WorkOrders = [SELECT Id, Name, ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c,
ERP7__Quantity_Ordered__c, ERP7__Quantity_Built__c, ERP7__Quantity_Scrapped__c
FROM ERP7__WO__c WHERE ERP7__MO__c =: WO2Update.ERP7__MO__c ORDER BY CreatedDate Asc];//AND ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c != null
Id currentWOId = WO2Update.Id;
if(allmo_WorkOrders.size() > 0){
ERP7__WO__c currentWO = WO2Update;

List<ERP7__WO__c> newMO_WorkOrders = new List<ERP7__WO__c>();
Map<Id,ERP7__WO__c> cycleWOmap = new Map<Id,ERP7__WO__c>();
for(ERP7__WO__c wo : allmo_WorkOrders){
cycleWOmap.put(wo.ERP7__Process_Cycle__c, wo);
}
for(ERP7__WO__c wo : allmo_WorkOrders){
if(wo.Id == currentWOId && wo.ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c != null){
if(cycleWOmap.containsKey(wo.ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c)){
ERP7__WO__c nextWO = cycleWOmap.get(wo.ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c);
if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Quantity_Ordered__c.isUpdateable()){nextWO.ERP7__Quantity_Ordered__c = currentWO.ERP7__Quantity_Ordered__c - currentWO.ERP7__Quantity_Scrapped__c;}else{}
system.debug('nextWO.ERP7__Quantity_Ordered__c  : '+nextWO.ERP7__Quantity_Ordered__c );
newMO_WorkOrders.add(nextWO); currentWOId = nextWO.Id;
}
}
}
if(Schema.sObjectType.ERP7__WO__c.isUpdateable()){ update newMO_WorkOrders; } else{}
}*/
            /*
List<ERP7__Actions_Tasks__c> tasks = new List<ERP7__Actions_Tasks__c>();
if(WO2Update.ERP7__Quantity_Ordered__c > 0 && WO2Update.ERP7__Quantity_Ordered__c == WO2Update.ERP7__Quantity_Built__c){
WO2Update.ERP7__Status__c = 'Complete';
tasks = [Select Id, Name, ERP7__Status__c, ERP7__Work_Order__c From ERP7__Actions_Tasks__c Where ERP7__Work_Order__c = :WO2Update.Id Order By ERP7__Operation__r.ERP7__Sort__c ASC];
for(ERP7__Actions_Tasks__c task : tasks) task.ERP7__Status__c = 'Completed';
}
upsert WO2Update;
if(tasks.size() > 0) update tasks;

String woId = WO2Update.Id;
if(WO2Update.ERP7__MO__c != Null){
String moId = WO2Update.ERP7__MO__c;
String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP_Flow__c');
wpallFields += ' , ERP7__Product__r.Name ';
String wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP_Flow__c where ERP7__Work_Orders__c = :woId';
comWrap.WIPFlows = Database.query(wpquery);
for(ERP7__WIP_Flow__c WF: comWrap.WIPFlows){
WF.ERP7__Quantity__c = WF.ERP7__Quantity_Unit__c * WO2Update.ERP7__Quantity_Built__c;
}
if(comWrap.WIPFlows.size() > 0) update comWrap.WIPFlows;
wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP__c');
wpallFields += ' , ERP7__Material_Batch_Lot__r.Name, ERP7__Serial_Number__r.Name ';
wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP__c where ERP7__MO__c = :moId';
comWrap.WIPs = Database.query(wpquery);
}
*/
            comWrap.manuOrders = new ERP7__Manufacturing_Order__c();
            comWrap.manuOrders = [SELECT Id, ERP7__Status__c,ERP7__Progress__c FROM ERP7__Manufacturing_Order__c WHERE Id =: WO2Update.ERP7__MO__c limit 1];

            Id updatedWO = WO2Update.Id;
            if(WO2Update.ERP7__Quantity_Built__c == WO2Update.ERP7__Quantity_Ordered__c){
                if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Status__c.isUpdateable()){WO2Update.ERP7__Status__c = 'Complete';}else{/*No access*/}
                if(Schema.sObjectType.ERP7__WO__c.isUpdateable()){update WO2Update;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Progress__c.isUpdateable()){comWrap.manuOrders.ERP7__Progress__c =  comWrap.manuOrders.ERP7__Progress__c + WO2Update.ERP7__Progress__c;}else{/*No access*/}
                system.debug('comWrap.manuOrders.ERP7__Progress__c : '+comWrap.manuOrders.ERP7__Progress__c);
                if(Schema.SObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){update comWrap.manuOrders;  }else{/*No access*/}
            }

            String WOFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            String AllWOFields = WOFields + ', ERP7__Product__r.Name, ERP7__Product__r.ERP7__UoM__c, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Routing__r.ERP7__Auto_Stock_Allocation__c, ERP7__Process_Cycle__r.ERP7__Previous_Process_Cycle__c, ERP7__Process_Cycle__r.ERP7__Next_Process_Cycle__c, ERP7__Sales_Order__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Routing__r.Name, ERP7__Version__r.Name, ERP7__Product__r.QuantityUnitOfMeasure ';
            comWrap.WorkOrder = Database.query('SELECT '+String.escapeSingleQuotes(AllWOFields)+' , ERP7__Work_Center__r.Name,ERP7__Routing__r.ERP7__Type__c FROM WO__c WHERE Id = :updatedWO Limit 1');

        } catch(Exception e) {
            comWrap.errorMsg = e.getMessage() +' Line Number 20@ : '+ e.getLineNumber();
            system.debug('comWrap.errorMsg : '+comWrap.errorMsg);
            /*'Exception > '+e.getMessage() +' Line Number @ : '+ e.getLineNumber()*/
        }
        return comWrap;
    }

    /*@AuraEnabled
public static comWrap CompleteWIPFlow(String WIPFlow){
comWrap comWrap = new comWrap();
try{
Id finishId;
ERP7__WIP_Flow__c WIP_Flows = (ERP7__WIP_Flow__c) JSON.deserialize(WIPFlow, ERP7__WIP_Flow__c .class);
if(WIP_Flows.ERP7__Status__c == 'Completed'){
update WIP_Flows;
finishId = WIP_Flows.Id;

//for multiple output products
List<ERP7__WIP_Flow__c> woFlows = new List<ERP7__WIP_Flow__c>();
for(ERP7__WIP_Flow__c woWIP : [SELECT Id, Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE ERP7__Work_Orders__c =: WIP_Flows.ERP7__Work_Orders__c AND ERP7__WIP__c =: WIP_Flows.ERP7__WIP__c LIMIT 9999] ){
if(woWIP.ERP7__Status__c != 'Completed') woFlows.add(woWIP);
}
if(woFlows.size() > 0) delete woFlows;
}
else{
ERP7__WIP_Flow__c finishWIP_Flow = new ERP7__WIP_Flow__c(Name = WIP_Flows.Name, ERP7__WIP__c = WIP_Flows.ERP7__WIP__c, ERP7__Start_Date__c = WIP_Flows.ERP7__Start_Date__c, ERP7__End_Date__c = WIP_Flows.ERP7__End_Date__c, ERP7__Finished_Products_Site__c = WIP_Flows.ERP7__Finished_Products_Site__c, ERP7__Product__c = WIP_Flows.ERP7__Product__c, ERP7__Quantity__c = WIP_Flows.ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c = WIP_Flows.ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c = WIP_Flows.ERP7__Quantity_Unit__c,  ERP7__Type__c = WIP_Flows.ERP7__Type__c, ERP7__Work_Orders__c = WIP_Flows.ERP7__Work_Orders__c, ERP7__Status__c = 'In Progress', ERP7__WIP_Link__c = WIP_Flows.ERP7__WIP_Link__c);
insert finishWIP_Flow;
finishWIP_Flow.ERP7__Status__c = 'Completed';
update finishWIP_Flow;

finishId = finishWIP_Flow.ERP7__Work_Orders__c;
ERP7__WIP_Flow__c finishedWIPFlow = [SELECT Name, ERP7__WIP__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Finished_Products_Site__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c,  ERP7__Type__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE ERP7__Work_Orders__c =: finishId LIMIT 1];
List<ERP7__WIP_Flow__c> WIP_Flows_List = new List<ERP7__WIP_Flow__c>();
WIP_Flows_List.add(finishedWIPFlow);
comWrap.WIPFlows = WIP_Flows_List;
}
ERP7__WIP_Flow__c newWIPFlow = [SELECT Name, ERP7__WIP__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Finished_Products_Site__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c,  ERP7__Type__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE Id =: finishId LIMIT 1];
ERP7__WIP_Flow__c oldWIPF = [SELECT Id, ERP7__Work_Orders__r.ERP7__Process_Cycle__c FROM ERP7__WIP_Flow__c WHERE Id =: WIP_Flows.Id LIMIT 1];
Id moId = newWIPFlow.ERP7__Work_Orders__r.ERP7__MO__c;
String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP__c');
wpallFields += ' , ERP7__Material_Batch_Lot__r.Name, ERP7__Serial_Number__r.Name ';
String wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP__c where ERP7__MO__c = :moId';
comWrap.WIPs = Database.query(wpquery);

//ak
comWrap.MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__Fulfilled_Amount__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Picture__c,
ERP7__MRP_Product__r.ERP7__Scrap_Variant__c, ERP7__MRP_Product__r.ERP7__Preview_Image__c, ERP7__Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__Work_Order__c, Process_Cycle__c, ERP7__Notes__c,  ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name
From ERP7__MRP__c
Where Process_Cycle__c = : oldWIPF.ERP7__Work_Orders__r.ERP7__Process_Cycle__c And
//ERP7__Action_Task__c =: Task.Id And
ERP7__Work_Order__c = : WIP_Flows.ERP7__Work_Orders__c  Order By ERP7__BOM__r.ERP7__Sort__c ASC];
String SILIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');
String AllSILIFields = SILIFields + '';
List<Id> mrpIds = new List<Id>();
for(ERP7__MRP__c MRP : comWrap.MRPS) mrpIds.add(MRP.Id);
comWrap.MRPSS = new List<mrpWrap>();
List<ERP7__Stock_Inward_Line_Item__c> SILIS = Database.query('SELECT '+String.escapeSingleQuotes(AllSILIFields)+' FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__MRP_Material_Requirement_Planning__c In :mrpIds');
//List<ERP7__Stock_Inward_Line_Item__c> SILIS = new List<ERP7__Stock_Inward_Line_Item__c>();
for(ERP7__MRP__c mrp : comWrap.MRPS) {
mrpWrap mrpWrapp = new mrpWrap();
mrpWrapp.MRP = mrp;
mrpWrapp.SOLI = new ERP7__Stock_Outward_Line_Item__c(ERP7__Product__c=mrp.ERP7__MRP_Product__c, ERP7__Status__c='Reserved', ERP7__Active__c=true, ERP7__MRP_Material_Requirements_Planning__c=mrp.Id, ERP7__BoM__c=mrp.ERP7__BOM__c); //ERP7__Serial__c, ERP7__Material_Batch_Lot__c,
if(mrp.ERP7__MO__c != Null) mrpWrapp.SOLI.ERP7__Manufacturing_Order__c=mrp.ERP7__MO__c;
for(ERP7__Stock_Inward_Line_Item__c SILI : SILIS) {
if(SILI.ERP7__MRP_Material_Requirement_Planning__c == mrp.Id){
mrpWrapp.SILIS.add(SILI);
mrpWrapp.SOLI.ERP7__Site_Product_Service_Inventory_Stock__c = SILI.ERP7__Site_ProductService_InventoryStock__c;
}
}
if(mrp.ERP7__MRP_Product__r.ERP7__Serialise__c == true) comWrap.Serial = true;
if(mrp.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true) comWrap.Batch = true;
comWrap.MRPSS.add(mrpWrapp);
}
} catch(Exception e) { comWrap.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
return comWrap;
} */
    @AuraEnabled
    public static comWrap CompleteWIPFlow(String WIPFlow){
        comWrap comWrap = new comWrap();
        try{
            String finishId = ''; String WIPId = '';

            ERP7__WIP_Flow__c WIP_Flows = (ERP7__WIP_Flow__c) JSON.deserialize(WIPFlow, ERP7__WIP_Flow__c .class);
            WIPId = WIP_Flows.id;
            finishId = WIP_Flows.ERP7__Work_Orders__c;
            // AggregateResult[] aggrresult = [Select Sum(ERP7__Quantity__c)qty FROM ERP7__WIP_Flow__c where ERP7__Work_Orders__c=:finishId group by ERP7__Work_Orders__c];
            ERP7__WIP_Flow__c oldWIPF = new ERP7__WIP_Flow__c();
            if(WIPId != null && WIPId != ''){
                oldWIPF = [SELECT Id,ERP7__Work_Orders__r.ERP7__Product__c, ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c,ERP7__Work_Orders__r.ERP7__Process_Cycle__c,ERP7__Work_Orders__r.ERP7__MO__c FROM ERP7__WIP_Flow__c WHERE Id =: WIPId LIMIT 1];
            }
            Id moId = oldWIPF.ERP7__Work_Orders__r.ERP7__MO__c;
            if(WIP_Flows.ERP7__Status__c == 'Completed'){
                if(WIP_Flows.ERP7__Product__c != oldWIPF.ERP7__Work_Orders__r.ERP7__Product__c){  if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Type__c.isUpdateable()){WIP_Flows.ERP7__Type__c = 'Processed';}else{/*No access*/} }
                if(Schema.SObjectType.ERP7__WIP_Flow__c.isUpdateable()){ update WIP_Flows; }else{/*No access*/}


                //for multiple output products
                List<ERP7__WIP_Flow__c> woFlows = new List<ERP7__WIP_Flow__c>();
                for(ERP7__WIP_Flow__c woWIP : [SELECT Id, Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE ERP7__Work_Orders__c =: WIP_Flows.ERP7__Work_Orders__c AND ERP7__WIP__c =: WIP_Flows.ERP7__WIP__c LIMIT 9999] ){
                    // if(woWIP.ERP7__Status__c == 'Completed')
                    woFlows.add(woWIP);
                }
                if(woFlows.size() > 0){
                    for(ERP7__WIP_Flow__c wip : woFlows)  comWrap.WIPFlows.add(new WIPFlowWrap(wip,false,false)); //comWrap.WIPFlows=woFlows;
                }
                //delete woFlows;
            }
            else{
                // ERP7__WIP_Flow__c finishWIP_Flow = new ERP7__WIP_Flow__c(Name = WIP_Flows.Name, ERP7__WIP__c = WIP_Flows.ERP7__WIP__c, ERP7__Start_Date__c = WIP_Flows.ERP7__Start_Date__c, ERP7__End_Date__c = WIP_Flows.ERP7__End_Date__c, ERP7__Finished_Products_Site__c = WIP_Flows.ERP7__Finished_Products_Site__c, ERP7__Product__c = WIP_Flows.ERP7__Product__c, ERP7__Quantity__c = WIP_Flows.ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c = WIP_Flows.ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c = WIP_Flows.ERP7__Quantity_Unit__c,  ERP7__Type__c = WIP_Flows.ERP7__Type__c, ERP7__Work_Orders__c = WIP_Flows.ERP7__Work_Orders__c, ERP7__Status__c = 'In Progress', ERP7__WIP_Link__c = WIP_Flows.ERP7__WIP_Link__c);
                //insert finishWIP_Flow;
                if(WIP_Flows.ERP7__Product__c != oldWIPF.ERP7__Work_Orders__r.ERP7__Product__c){ if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Type__c.isUpdateable()){ WIP_Flows.ERP7__Type__c = 'Processed';}else{/*No access*/}   }
                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Status__c.isUpdateable()){WIP_Flows.ERP7__Status__c = 'Completed';}else{/*No access*/}
                if(Schema.sObjectType.ERP7__WIP_Flow__c.isUpdateable()){ update WIP_Flows;}else{/*No access*/}
                finishId = WIP_Flows.ERP7__Work_Orders__c;
                WIPId = WIP_Flows.id;
                List<ERP7__WIP_Flow__c> finishedWIPFlow = [SELECT Name, ERP7__WIP__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Finished_Products_Site__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c,  ERP7__Type__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE ERP7__Work_Orders__c =: finishId];
                List<ERP7__WIP_Flow__c> WIP_Flows_List = new List<ERP7__WIP_Flow__c>();
                for(ERP7__WIP_Flow__c wip : finishedWIPFlow)
                {
                    comWrap.WIPFlows.add(new WIPFlowWrap(wip,false,false));
                }
                //comWrap.WIPFlows = WIP_Flows_List;
            }
            ERP7__WIP_Flow__c newWIPFlow = new ERP7__WIP_Flow__c();

            if(finishId != null && finishId != ''){
                newWIPFlow = [SELECT Name, ERP7__WIP__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Finished_Products_Site__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c,  ERP7__Type__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE ERP7__Work_Orders__c =: finishId LIMIT 1];
            }
            /*'WIPId : '+WIPId);

'MO id ~> '+newWIPFlow.ERP7__Work_Orders__r.ERP7__MO__c);
'newWIPFlow : '+newWIPFlow);
'finishId : '+finishId);
'oldWIPF : '+oldWIPF); */
            if(newWIPFlow != null && oldWIPF != null && finishId != null && finishId != ''){

                String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP__c');
                wpallFields += ' , ERP7__Material_Batch_Lot__r.Name, ERP7__Serial_Number__r.Name ';
                String wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP__c where ERP7__MO__c = :moId';
                comWrap.WIPs = Database.query(wpquery);

                //ak
                comWrap.MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__Fulfilled_Amount__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Picture__c,
                                ERP7__MRP_Product__r.ERP7__Scrap_Variant__c, ERP7__MRP_Product__r.ERP7__Preview_Image__c, ERP7__Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__Work_Order__c, Process_Cycle__c, ERP7__Notes__c,  ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                                ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name
                                From ERP7__MRP__c
                                Where Process_Cycle__c = : oldWIPF.ERP7__Work_Orders__r.ERP7__Process_Cycle__c And
                                //ERP7__Action_Task__c =: Task.Id And
                                ERP7__Work_Order__c = : finishId  Order By ERP7__BOM__r.ERP7__Sort__c ASC];
            }
            String SILIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');
            String AllSILIFields = SILIFields + '';
            List<Id> mrpIds = new List<Id>();
            for(ERP7__MRP__c MRP : comWrap.MRPS) mrpIds.add(MRP.Id);
            comWrap.MRPSS = new List<mrpWrap>();
            List<ERP7__Stock_Inward_Line_Item__c> SILIS = Database.query('SELECT '+String.escapeSingleQuotes(AllSILIFields)+' FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__MRP_Material_Requirement_Planning__c In :mrpIds');
            //List<ERP7__Stock_Inward_Line_Item__c> SILIS = new List<ERP7__Stock_Inward_Line_Item__c>();
            for(ERP7__MRP__c mrp : comWrap.MRPS) {
                mrpWrap mrpWrapp = new mrpWrap();
                mrpWrapp.MRP = mrp;
                mrpWrapp.SOLI = new ERP7__Stock_Outward_Line_Item__c(ERP7__Product__c=mrp.ERP7__MRP_Product__c, ERP7__Status__c='Reserved', ERP7__Active__c=true, ERP7__MRP_Material_Requirements_Planning__c=mrp.Id, ERP7__BoM__c=mrp.ERP7__BOM__c); //ERP7__Serial__c, ERP7__Material_Batch_Lot__c,
                if(mrp.ERP7__MO__c != Null) mrpWrapp.SOLI.ERP7__Manufacturing_Order__c=mrp.ERP7__MO__c;
                for(ERP7__Stock_Inward_Line_Item__c SILI : SILIS) { if(SILI.ERP7__MRP_Material_Requirement_Planning__c == mrp.Id){ mrpWrapp.SILIS.add(SILI);   mrpWrapp.SOLI.ERP7__Site_Product_Service_Inventory_Stock__c = SILI.ERP7__Site_ProductService_InventoryStock__c; } }
                if(mrp.ERP7__MRP_Product__r.ERP7__Serialise__c == true) comWrap.Serial = true;
                if(mrp.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true) comWrap.Batch = true;
                comWrap.MRPSS.add(mrpWrapp);
                ERP7__Manufacturing_Order__c MO = [Select Id,Name ,ERP7__Manufactured_Quantity__c ,ERP7__Quantity_Produced__c , ERP7__Quantity_Scrapped__c , ERP7__Scrapped_Quantity__c from ERP7__Manufacturing_Order__c where Id=: moId];
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Manufactured_Quantity__c.isUpdateable()){MO.ERP7__Manufactured_Quantity__c = MO.ERP7__Quantity_Produced__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Scrapped_Quantity__c.isUpdateable()){MO.ERP7__Scrapped_Quantity__c = MO.ERP7__Quantity_Scrapped__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()) { update MO;}else{/*No access*/}
            }
        } catch(Exception e) { comWrap.errorMsg = e.getMessage() +' Line Number 21@ : '+ e.getLineNumber(); }
        return comWrap;
    }

    @AuraEnabled
    public static comWrap ScrapWIPFlow(String WIPFlow){
        comWrap comWrap = new comWrap();
        try{
            Id scrapId;
            ERP7__WIP_Flow__c WIP_Flows = (ERP7__WIP_Flow__c) JSON.deserialize(WIPFlow, ERP7__WIP_Flow__c .class);
            if(WIP_Flows.ERP7__Status__c == 'Completed'){
                if(Schema.SObjectType.ERP7__WIP_Flow__c.isUpdateable()){ update WIP_Flows; } else{ }
                scrapId = WIP_Flows.Id;

                //for multiple output products
                List<ERP7__WIP_Flow__c> woFlows = new List<ERP7__WIP_Flow__c>();
                for(ERP7__WIP_Flow__c woWIP : [SELECT Id, Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE ERP7__Work_Orders__c =: WIP_Flows.ERP7__Work_Orders__c AND ERP7__WIP__c =: WIP_Flows.ERP7__WIP__c LIMIT 9999] ){
                    if(woWIP.ERP7__Status__c != 'Completed') woFlows.add(woWIP);
                }
                if(woFlows.size() > 0){  if(ERP7__WIP_Flow__c.sObjectType.getDescribe().isDeletable()) { delete woFlows; } else { }
                                      }
            }
            else{
                ERP7__WIP_Flow__c scrapWIP_Flow = new ERP7__WIP_Flow__c();                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.Name.isCreateable()){scrapWIP_Flow.Name = WIP_Flows.Name; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__WIP__c.isCreateable()){scrapWIP_Flow.ERP7__WIP__c = WIP_Flows.ERP7__WIP__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Start_Date__c.isCreateable()){scrapWIP_Flow.ERP7__Start_Date__c = WIP_Flows.ERP7__Start_Date__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__End_Date__c.isCreateable()){scrapWIP_Flow.ERP7__End_Date__c = WIP_Flows.ERP7__End_Date__c;}else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Finished_Products_Site__c.isCreateable()){scrapWIP_Flow.ERP7__Finished_Products_Site__c = WIP_Flows.ERP7__Finished_Products_Site__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Product__c.isCreateable()){scrapWIP_Flow.ERP7__Product__c = WIP_Flows.ERP7__Product__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity__c.isCreateable()){scrapWIP_Flow.ERP7__Quantity__c = WIP_Flows.ERP7__Quantity__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity_Unit_Of_Measure__c.isCreateable()){scrapWIP_Flow.ERP7__Quantity_Unit_Of_Measure__c = WIP_Flows.ERP7__Quantity_Unit_Of_Measure__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Quantity_Unit__c.isCreateable()){scrapWIP_Flow.ERP7__Quantity_Unit__c = WIP_Flows.ERP7__Quantity_Unit__c;}else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Type__c.isCreateable()){scrapWIP_Flow.ERP7__Type__c = WIP_Flows.ERP7__Type__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Work_Orders__c.isCreateable()){scrapWIP_Flow.ERP7__Work_Orders__c = WIP_Flows.ERP7__Work_Orders__c; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Status__c.isCreateable()){scrapWIP_Flow.ERP7__Status__c = 'In Progress'; }else{/*No access*/}                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__WIP_Link__c.isCreateable()){scrapWIP_Flow.ERP7__WIP_Link__c = WIP_Flows.ERP7__WIP_Link__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__WIP_Flow__c.isCreateable()){ insert scrapWIP_Flow; } else {/*No access*/ }
                if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Status__c.isUpdateable()) {scrapWIP_Flow.ERP7__Status__c = 'Completed';} else {/*No access*/ }
                if(Schema.sObjectType.ERP7__WIP_Flow__c.isUpdateable()) { update scrapWIP_Flow; } else {/*No access*/ }

                scrapId = scrapWIP_Flow.ERP7__Work_Orders__c;
                ERP7__WIP_Flow__c scrappedWIPFlow = [SELECT Name, ERP7__WIP__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Finished_Products_Site__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c,  ERP7__Type__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE Id =: scrapId LIMIT 1];
                List<ERP7__WIP_Flow__c> scraped_Flows_List = new List<ERP7__WIP_Flow__c>(); scraped_Flows_List.add(scrappedWIPFlow);
                for(ERP7__WIP_Flow__c wip : scraped_Flows_List)  comWrap.WIPFlows.add(new WIPFlowWrap(wip,false,false)); //comWrap.WIPFlows = scraped_Flows_List;
            }


            ERP7__WIP_Flow__c scrappedWIPFlow = [SELECT Name, ERP7__WIP__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Finished_Products_Site__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Work_Orders__r.ERP7__MO__c, ERP7__Quantity__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Quantity_Unit__c,  ERP7__Type__c, ERP7__Work_Orders__c, ERP7__Status__c, ERP7__WIP_Link__c FROM ERP7__WIP_Flow__c WHERE Id =: scrapId LIMIT 1];
            ERP7__WIP_Flow__c oldWIPF = [SELECT Id, ERP7__Work_Orders__r.ERP7__Process_Cycle__c FROM ERP7__WIP_Flow__c WHERE Id =: WIP_Flows.Id LIMIT 1];
            Id moId = scrappedWIPFlow.ERP7__Work_Orders__r.ERP7__MO__c;
            ERP7__Manufacturing_Order__c MO = [Select Id,Name ,ERP7__Manufactured_Quantity__c ,ERP7__Quantity_Produced__c , ERP7__Quantity_Scrapped__c , ERP7__Scrapped_Quantity__c from ERP7__Manufacturing_Order__c where Id=: moId];
            if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Manufactured_Quantity__c.isUpdateable()){MO.ERP7__Manufactured_Quantity__c = MO.ERP7__Quantity_Produced__c;} else {/*No access*/}
            if(Schema.sObjectType.ERP7__Manufacturing_Order__c.fields.ERP7__Scrapped_Quantity__c.isUpdateable()){MO.ERP7__Scrapped_Quantity__c = MO.ERP7__Quantity_Scrapped__c;} else {/*No access*/}
            if(Schema.sObjectType.ERP7__Manufacturing_Order__c.isUpdateable()){update MO;} else {/*No access*/}
            String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP__c');
            wpallFields += ' , ERP7__Material_Batch_Lot__r.Name, ERP7__Serial_Number__r.Name ';
            String wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP__c where ERP7__MO__c = :moId';
            comWrap.WIPs = Database.query(wpquery);

            //ak
            comWrap.MRPS = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__Fulfilled_Amount__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Picture__c,
                            ERP7__MRP_Product__r.ERP7__Scrap_Variant__c, ERP7__MRP_Product__r.ERP7__Preview_Image__c, ERP7__Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__Work_Order__c, Process_Cycle__c, ERP7__Notes__c,  ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                            ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c, ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__BOM__r.ERP7__Product_Feature__r.Name
                            From ERP7__MRP__c
                            Where Process_Cycle__c = : oldWIPF.ERP7__Work_Orders__r.ERP7__Process_Cycle__c And
                            //ERP7__Action_Task__c =: Task.Id And
                            ERP7__Work_Order__c = : WIP_Flows.ERP7__Work_Orders__c  Order By ERP7__BOM__r.ERP7__Sort__c ASC];
            String SILIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');
            String AllSILIFields = SILIFields + '';
            List<Id> mrpIds = new List<Id>();
            for(ERP7__MRP__c MRP : comWrap.MRPS) mrpIds.add(MRP.Id);
            comWrap.MRPSS = new List<mrpWrap>();
            List<ERP7__Stock_Inward_Line_Item__c> SILIS = Database.query('SELECT '+String.escapeSingleQuotes(AllSILIFields)+' FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__MRP_Material_Requirement_Planning__c In :mrpIds');
            //List<ERP7__Stock_Inward_Line_Item__c> SILIS = new List<ERP7__Stock_Inward_Line_Item__c>();
            for(ERP7__MRP__c mrp : comWrap.MRPS) {
                mrpWrap mrpWrapp = new mrpWrap();
                mrpWrapp.MRP = mrp;
                mrpWrapp.SOLI = new ERP7__Stock_Outward_Line_Item__c(ERP7__Product__c=mrp.ERP7__MRP_Product__c, ERP7__Status__c='Reserved', ERP7__Active__c=true, ERP7__MRP_Material_Requirements_Planning__c=mrp.Id, ERP7__BoM__c=mrp.ERP7__BOM__c); //ERP7__Serial__c, ERP7__Material_Batch_Lot__c,
                if(mrp.ERP7__MO__c != Null) mrpWrapp.SOLI.ERP7__Manufacturing_Order__c=mrp.ERP7__MO__c;
                for(ERP7__Stock_Inward_Line_Item__c SILI : SILIS) { if(SILI.ERP7__MRP_Material_Requirement_Planning__c == mrp.Id){ mrpWrapp.SILIS.add(SILI);   mrpWrapp.SOLI.ERP7__Site_Product_Service_Inventory_Stock__c = SILI.ERP7__Site_ProductService_InventoryStock__c; } }
                if(mrp.ERP7__MRP_Product__r.ERP7__Serialise__c == true) comWrap.Serial = true;
                if(mrp.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true) comWrap.Batch = true;
                comWrap.MRPSS.add(mrpWrapp);
            }

            return comWrap;
        } catch(Exception e) { comWrap.errorMsg = e.getMessage() +' Line Number 22@ : '+ e.getLineNumber(); return null;}

    }
    @AuraEnabled
    public static comWrap DeleteRA(String RAId){
        comWrap comW = new comWrap();
        try{
            List<ERP7__Demand__c> Demands = [Select Id, Name from ERP7__Demand__c where ERP7__Resource_Allocation__c =:RAId];
            if(Demands.size() > 0){ if(ERP7__Demand__c.sObjectType.getDescribe().isDeletable()) { delete Demands; } else { }
                                  }
            ERP7__Resource_Allocation__c RA = [Select Id, Name from ERP7__Resource_Allocation__c where Id =:RAId];
            if(ERP7__Resource_Allocation__c.sObjectType.getDescribe().isDeletable()) { delete RA; } else { } } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 23@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap DeleteAT(String RAId, String ObjName){
        comWrap comW = new comWrap();
        try{
            String query = 'select Id from ' +String.escapeSingleQuotes(ObjName)+ ' Where Id =:RAId';
            SObject AT = Database.query(query);
            SObjectType sObjType = ((SObject) Type.forName(ObjName).newInstance()).getSObjectType();
            if(sObjType.getDescribe().isDeletable()){ delete AT;}else{/*No access*/} } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 24@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static comWrap GetAllResources(String  WPS, String Name, DateTime StartTime, DateTime EndTime, String WPId, String RRId){
        comWrap comW = new comWrap();
        try{
            comW.errorMsg = '';
            if(StartTime != Null && EndTime != Null && WPId != Null && RRId != Null && WPId != '' && RRId != ''){
                List<WorkPlanner> WPWrappers = (List<WorkPlanner>) JSON.deserialize(WPS, List<WorkPlanner> .class);
                List<Id> GroupIds = new List<Id>();
                List<Id> RRIds = new List<Id>();
                for(WorkPlanner WP : WPWrappers){
                    for(ERP7__Resource_Requirement__c RR : WP.RRS){
                        if(RR.Id == RRId && RR.ERP7__Resource_Group__c != Null) GroupIds.add(RR.ERP7__Resource_Group__c);
                        if(RR.ERP7__Work_Planner__c == WPId && RR.ERP7__Preferred_Resource__c != Null) RRIds.add(RR.ERP7__Preferred_Resource__c);
                    }
                }

                String wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Allocation__c');
                wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Employees__r.Name, ERP7__Machine__r.Name ';
                utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Allocation__c');
                String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Allocation__c Where ERP7__Start_Date__c < :EndTime And ERP7__End_Date__c > :StartTime And ERP7__Resource_Group__c In :GroupIds';
                List< ERP7__Resource_Allocation__c > RAS = Database.query(query);
                comW.RAS = RAS;
                Set<Id> empIds = new Set<Id>();
                Set<Id> macIds = new Set<Id>();
                for(ERP7__Resource_Allocation__c RA : RAS){
                    if(RA.ERP7__Employees__c != Null) empIds.add(RA.ERP7__Employees__c);
                    if(RA.ERP7__Machine__c != Null) macIds.add(RA.ERP7__Machine__c);
                }
                wcFields = UtilClass.selectStarFromSObject('ERP7__Resource__c');
                wcFields += ', RecordType.Name, ERP7__Employee__r.Name, ERP7__Machine__r.Name, ERP7__Resource_Group__r.Name ';
                utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Requirement__c');
                String resName = '%'+Name+'%';
                query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource__c Where Name like :resName And ERP7__Employee__c Not In : empIds And ERP7__Machine__c Not In : macIds And ERP7__Resource_Group__c In :GroupIds Order by CreatedDate Asc limit 1000';
                List< ERP7__Resource__c > RRS = Database.query(query);
                 System.debug('query: '+query);
                System.debug('RRS: '+RRS);
                System.debug('RRS size: '+RRS.size());
                for(ERP7__Resource__c R : RRS){
                    Resource RR = new Resource();
                    RR.Resource = R;
                    if(RRIds.contains(R.Id)) {
                        RR.isSelect = true;
                        comW.AvailableResources.add(RR);
                    }
                }
                for(ERP7__Resource__c R : RRS){
                    Resource RR = new Resource();
                    RR.Resource = R;
                    if(!RRIds.contains(R.Id)) comW.AvailableResources.add(RR);
                }
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 25@ : '+ e.getLineNumber(); }
        return comW;
    }


    @AuraEnabled
    public static comWrap SaveResources(String Resources,String  WO1, DateTime StartTime, DateTime EndTime){
        ERP7__WO__c WO = (ERP7__WO__c) JSON.deserialize(WO1, ERP7__WO__c.class);
        comWrap comW = new comWrap();
        try{
            comW.errorMsg = '';
            String WC = WO.ERP7__Work_Center__c;
            List<Resource> ResourceWrapper = (List<Resource>) JSON.deserialize(Resources, List<Resource> .class);
            String wcFields = UtilClass.selectStarFromSObject('ERP7__Capacity_Planner__c');
            //wcFields += ', ERP7__Preferred_Resource__r.Name, ERP7__Preferred_Resource__r.ERP7__Employee__c, ERP7__Preferred_Resource__r.ERP7__Employee__r.Name, ERP7__Preferred_Resource__r.ERP7__Machine__c, ERP7__Preferred_Resource__r.ERP7__Machine__r.Name ';
            String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Capacity_Planner__c Where ERP7__Start_Date__c <= Today And ERP7__End_Date__c >= Today Order by CreatedDate Desc limit 1';
            List<ERP7__Capacity_Planner__c> CPS = Database.query(query);
            if(CPS.size() > 0) {
                List< ERP7__Resource_Allocation__c > RA2Upsert = new List< ERP7__Resource_Allocation__c >();
                List< ERP7__Demand__c > Demands2Upsert = new List< ERP7__Demand__c >();
                for(Resource R : ResourceWrapper){
                    if(R.isSelect){
                        ERP7__Resource_Allocation__c RA = new ERP7__Resource_Allocation__c();
                        if(R.Resource.ERP7__Employee__c != Null){  if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.Name.isUpdateable()){RA.Name = R.Resource.ERP7__Employee__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Employees__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Employees__c.isUpdateable()){RA.ERP7__Employees__c = R.Resource.ERP7__Employee__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Type__c.isUpdateable()){RA.ERP7__Type__c = 'Human Resource';}else{/*No access*/}
                                                                }
                        else if(R.Resource.ERP7__Machine__c != Null){  if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.Name.isUpdateable()){RA.Name = R.Resource.ERP7__Machine__r.Name;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Machine__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Machine__c.isUpdateable()){RA.ERP7__Machine__c = R.Resource.ERP7__Machine__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Type__c.isUpdateable()){RA.ERP7__Type__c = 'Machine';}else{/*No access*/}
                                                                    }
                        if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.Resource__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.Resource__c.isUpdateable()){RA.Resource__c = R.Resource.Id;}else{/*No access*/}               if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Planner__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Planner__c.isUpdateable()){RA.ERP7__Planner__c = CPS[0].Id;}else{/*No access*/}              if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Active__c.isUpdateable()){RA.ERP7__Active__c = true;}else{/*No access*/}             if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Work_Order__c.isUpdateable()){RA.ERP7__Work_Order__c = WO.Id;}else{/*No access*/}             if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__End_Date__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__End_Date__c.isUpdateable()){RA.ERP7__End_Date__c = EndTime;}else{/*No access*/}              if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Start_Date__c.isUpdateable()){RA.ERP7__Start_Date__c = StartTime;}else{/*No access*/}                     if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Work_Center__c.isUpdateable()){RA.ERP7__Work_Center__c = WO.ERP7__Work_Center__c;}else{/*No access*/}               if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Product__c.isUpdateable()){RA.ERP7__Product__c = WO.ERP7__Product__c;}else{/*No access*/}      if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Process__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Process__c.isUpdateable()){RA.ERP7__Process__c = WO.ERP7__Process__c;}else{/*No access*/}
                        //RA.ERP7__Production_Cycle__c = WO.ERP7__Process_Cycle__c;
                        if(Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Resource_Group__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.fields.ERP7__Resource_Group__c.isUpdateable()){RA.ERP7__Resource_Group__c = R.Resource.ERP7__Resource_Group__c;}else{/*No access*/}
                        RA2Upsert.add(RA);
                    }
                }
                if(RA2Upsert.size() > 0){
                    if(Schema.sObjectType.ERP7__Resource_Allocation__c.isCreateable() && Schema.sObjectType.ERP7__Resource_Allocation__c.isUpdateable()) { upsert RA2Upsert; } else {/*No access*/}
                }
                for(ERP7__Resource_Allocation__c RA : RA2Upsert){
                    ERP7__Demand__c Demand = new ERP7__Demand__c();        if(Schema.sObjectType.ERP7__Demand__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.Name.isUpdateable()){Demand.Name = RA.Name;} else {/*No access*/}        if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Start_Date_Time__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Start_Date_Time__c.isUpdateable()){Demand.ERP7__Start_Date_Time__c = StartTime;} else {/*No access*/}         if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__End_Date_Time__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__End_Date_Time__c.isUpdateable()){Demand.ERP7__End_Date_Time__c = EndTime;} else {/*No access*/}             if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource_Group__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource_Group__c.isUpdateable()){Demand.ERP7__Resource_Group__c = RA.ERP7__Resource_Group__c;} else {/*No access*/}              if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Work_Center__c.isUpdateable()){Demand.ERP7__Work_Center__c = RA.ERP7__Work_Center__c;} else {/*No access*/}            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Work_Order__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Work_Order__c.isUpdateable()){Demand.ERP7__Work_Order__c = RA.ERP7__Work_Order__c;} else {/*No access*/}       if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Capacity_Planner__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Capacity_Planner__c.isUpdateable()){Demand.ERP7__Capacity_Planner__c = RA.ERP7__Planner__c;} else {/*No access*/}  if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource_Allocation__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource_Allocation__c.isUpdateable()){Demand.ERP7__Resource_Allocation__c = RA.Id;} else {/*No access*/}
                    Demands2Upsert.add(Demand);
                }
                if(Demands2Upsert.size() > 0) {     if(Schema.sObjectType.ERP7__Demand__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.isUpdateable()){ upsert Demands2Upsert; } else {/*No access*/}
                }
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 26@ : '+ e.getLineNumber(); }
        return comW;
    }

    /* @AuraEnabled
public static List<Attachment> uploadFile(String parent, String fileName, String base64Data, String contentType) {
base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
Attachment a = new Attachment();
a.parentId = parent;
a.Body = EncodingUtil.base64Decode(base64Data);
a.Name = fileName;
a.ContentType = contentType;
if(Schema.SObjectType.Attachment.isCreateable()) { insert a; } else { }
ERP7__Actions_Tasks__c AT = [Select Id, Name, ERP7__Work_Order__c From ERP7__Actions_Tasks__c Where Id =: parent];
List<ERP7__Actions_Tasks__c> ATS = [Select Id From ERP7__Actions_Tasks__c Where ERP7__Work_Order__c =: AT.ERP7__Work_Order__c];
List<Id> taskIds = new List<Id>();
for(ERP7__Actions_Tasks__c ATT : ATS) taskIds.add(ATT.Id);
List<Attachment> MYATS = [Select Id, Name, ParentId, ContentType, Owner.Name, CreatedDate From Attachment Where ParentId In :taskIds Order By CreatedDate Asc];
return MYATS;
}
*/
    @AuraEnabled
    public static List<Attachment>  uploadFile(String parent, String fileName, String base64Data, String contentType) {
        List<Attachment> MYATS = new List<Attachment>();
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment a = new Attachment();
            if(Schema.sObjectType.Attachment.fields.parentId.isCreateable()){a.parentId = parent;}else{/*No access*/}
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){a.Body = EncodingUtil.base64Decode(base64Data);}else{/*No access*/}
            if(Schema.sObjectType.Attachment.fields.Name.isCreateable()){a.Name = fileName;}else{/*No access*/}
            if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){a.ContentType = contentType; }else{/*No access*/}
            if(Schema.SObjectType.Attachment.isCreateable()) { insert a; }else{/*No access*/}
            //ERP7__Actions_Tasks__c AT = [Select Id, Name, ERP7__Work_Order__c From ERP7__Actions_Tasks__c Where Id =: parent];
            // List<ERP7__Actions_Tasks__c> ATS = [Select Id From ERP7__Actions_Tasks__c Where Id =: parent];
            //List<Id> taskIds = new List<Id>();
            // for(ERP7__Actions_Tasks__c ATT : ATS) taskIds.add(ATT.Id);
            MYATS = [Select Id, Name, ParentId, ContentType, Owner.Name, CreatedDate From Attachment Where ParentId = :parent Order By CreatedDate Asc];  } catch(Exception e) { /*'Upload Error : '+e.getMessage() +' Line Number @ : '+ e.getLineNumber()*/ }
        return MYATS;
    }
    @AuraEnabled
    public static List<Note> SaveNotes(String NN) {
        Note myNote = (Note) JSON.deserialize(NN, Note.class);
        comWrap comW = new comWrap();
        try{  if(Schema.SObjectType.Attachment.isCreateable() && Schema.SObjectType.Attachment.isUpdateable()){ upsert myNote; } else {/*No access*/} } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 27@ : '+ e.getLineNumber(); }

        ERP7__Actions_Tasks__c AT = [Select Id, Name, ERP7__Work_Order__c From ERP7__Actions_Tasks__c Where Id =: myNote.ParentId];
        List<ERP7__Actions_Tasks__c> ATS = [Select Id From ERP7__Actions_Tasks__c Where ERP7__Work_Order__c =: AT.ERP7__Work_Order__c];
        List<Id> taskIds = new List<Id>();
        for(ERP7__Actions_Tasks__c ATT : ATS) taskIds.add(ATT.Id);
        List<Note> MYATS = [Select Id, Title, Body,ParentId From Note Where ParentId In :taskIds Order By CreatedDate Asc];
        return MYATS;
    }

    @AuraEnabled
    public static List<Attachment> GetAttachments(String TaskId) {
        comWrap comW = new comWrap();
        ERP7__Actions_Tasks__c AT = [Select Id, Name, ERP7__Work_Order__c From ERP7__Actions_Tasks__c Where Id =: TaskId];
        List<ERP7__Actions_Tasks__c> ATS = [Select Id From ERP7__Actions_Tasks__c Where ERP7__Work_Order__c =: AT.ERP7__Work_Order__c];
        List<Id> taskIds = new List<Id>();
        for(ERP7__Actions_Tasks__c ATT : ATS) taskIds.add(ATT.Id);
        List<Attachment> MYATS = [Select Id, Name, ParentId, ContentType, Owner.Name, CreatedDate From Attachment Where ParentId In :taskIds Order By CreatedDate Asc];
        return MYATS;
    }

    @AuraEnabled
    public static List<Attachment> GetWOAttachments(String WOId) {
        comWrap comW = new comWrap();
        List<Attachment> MYATS = [Select Id, Name, ParentId, ContentType, Owner.Name, CreatedDate From Attachment Where ParentId = :WOId And Name = 'Signature' Order By CreatedDate Asc];
        return MYATS;
    }

    @AuraEnabled
    public static comWrap SaveW(String WO){
        ERP7__WO__c WOs = (ERP7__WO__c) JSON.deserialize(WO, ERP7__WO__c .class);
        comWrap comW = new comWrap();
        try{
            if(WOs.ERP7__Work_Center__c == Null && WOs.ERP7__Routing__c != Null) {
                List<ERP7__Routing__c> Routings = [Select Id, Name, ERP7__Work_Center__c From ERP7__Routing__c Where Id = :WOs.ERP7__Routing__c];
                if(Routings.size() > 0 && Routings[0].ERP7__Work_Center__c != Null){ if(Schema.sObjectType.WO__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.WO__c.fields.ERP7__Work_Center__c.isUpdateable()){WOs.ERP7__Work_Center__c = Routings[0].ERP7__Work_Center__c;} else {/*No access*/}  }
            }
            if(Schema.sObjectType.WO__c.isCreateable() && Schema.sObjectType.WO__c.isUpdateable()){ upsert WOs; } else {/*No access*/}
            comW.WorkOrder = WOs; } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 28@ : '+ e.getLineNumber(); }
        return comW;
    }

    @AuraEnabled
    public static ERP7__WO__c getAllRMALI(String rmarecordId){
        comWrap comW = new comWrap();
        ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c();
        ERP7__WO__c wo;
        Purchase_Line_Items__c poli;
        if(rmarecordId != null && rmarecordId != ''){
            RMALI = [Select Id, Name, ERP7__Quantity_Available__c, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.ERP7__SO__c,
                     ERP7__SOLI__c, ERP7__Quantity_Return__c, ERP7__Base_Price__c, ERP7__Sale_Price__c, ERP7__Product__c,ERP7__Product__r.Name
                     from ERP7__RMA_Line_Item__c where Id=:rmarecordId];
            wo = new ERP7__WO__c(Name = RMALI.Name, ERP7__Product__c = RMALI.ERP7__Product__c, ERP7__Product__r=new Product2(Id=RMALI.ERP7__Product__c,Name=RMALI.ERP7__Product__r.Name), ERP7__Quantity_Ordered__c = RMALI.ERP7__Quantity_Return__c, ERP7__Sales_Order__c = RMALI.ERP7__Return_Merchandise_Authorisation__r.ERP7__SO__c );
        }
        return wo;
    }


    @AuraEnabled
    public static ScanWrap SearchScanCode(String  scanCode, String MRPs){
        ScanWrap scanWrapper = new ScanWrap();
        try{
            List<mrpWrap> mrpWrappers = (List<mrpWrap>) JSON.deserialize(MRPs, List<mrpWrap> .class);
            List<ERP7__Serial_Number__c> SNS = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c  From ERP7__Serial_Number__c Where ERP7__Barcode__c =: scanCode Limit 1];
            if(SNS.size() > 0) {
                scanWrapper.Serial = SNS[0];
                scanWrapper.substep = 'Serial';
                for(mrpWrap mrrp : mrpWrappers){
                    if(mrrp.isSelect){
                        if(scanWrapper.Serial.ERP7__Manufacturing_Order__c != Null && scanWrapper.Serial.ERP7__Manufacturing_Order__c == mrrp.MRP.ERP7__MO__c) { scanWrapper.step = 'MO';
                                                                                                                                                               }
                        else if(scanWrapper.Serial.ERP7__Product__c == mrrp.MRP.ERP7__MRP_Product__c){
                            scanWrapper.step = 'MRP';
                        }
                    }
                    if(scanWrapper.step != '') break;
                }
            }else{
                List<ERP7__Batch__c> BTS = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Product__c, ERP7__Barcode__c  From ERP7__Batch__c Where ERP7__Barcode__c =: scanCode Limit 1];
                if(BTS.size() > 0) {
                    scanWrapper.Batch = BTS[0];   scanWrapper.substep = 'Batch';
                    for(mrpWrap mrrp : mrpWrappers){
                        if(mrrp.isSelect && scanWrapper.Batch.ERP7__Manufacturing_Order__c != Null && scanWrapper.Batch.ERP7__Manufacturing_Order__c == mrrp.MRP.ERP7__MO__c) {  scanWrapper.step = 'MO';   }
                        else if(mrrp.isSelect && scanWrapper.Batch.ERP7__Product__c == mrrp.MRP.ERP7__MRP_Product__c){ scanWrapper.step = 'MRP';   }
                        if(scanWrapper.step != '') break;
                    }
                }
            }
        } catch(Exception e) { scanWrapper.errorMsg = e.getMessage() +' Line Number 29@ : '+ e.getLineNumber(); }
        return scanWrapper;
    }

    @AuraEnabled
    public static ERP7__Sales_Order_Line_Item__c getSoliFromId(Id soliID) {
        /*if(soliId == null)
return null;

ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c();
try {
soli = [SELECT Id, ERP7__Product__c, ERP7__Product__r.ERP7__Version__c, ERP7__Product__r.ERP7__Routing__c, ERP7__Quantity_Needed__c, ERP7__Sales_Order__c FROM ERP7__Sales_Order_Line_Item__c WHERE Id =: soliID LIMIT 1];
} catch(Exception ex) {
}
return soli;*/
        return null;
    }

    @AuraEnabled
    public static Double getSerialStock(String serialId){

        Double serialStock = 0.0;
        try{
            Set<Id> stockIds = new Set<Id>();
            List<AggregateResult> serialInv = new List<AggregateResult>();
            List<AggregateResult> serialInvOut = new List<AggregateResult>();
            //List<ERP7__Stock_Inward_Line_Item__c> inwards = List<ERP7__Stock_Inward_Line_Item__c>();
            serialInv = [SELECT SUM(ERP7__Quantity__c)avaialbleStock FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__Serial__c =: serialId AND ERP7__Serial__c != null GROUP BY ERP7__Serial__c];
            serialInvOut = [SELECT SUM(ERP7__Quantity__c)avaialbleStock FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Serial__c =: serialId AND ERP7__Serial__c != null GROUP BY ERP7__Serial__c];
            //stockIds = inwards.KeySet();
            //batchInv = [SELECT SUM(ERP7__Number_of_Item_In_Stock__c) avaialbleStock FROM ERP7__Inventory_Stock__c WHERE Id IN: stockIds GROUP BY Id];
            if(serialInv.size() > 0 && serialInvOut.size() > 0) serialStock = (Double)serialInv[0].get('avaialbleStock') - (Double)serialInvOut[0].get('avaialbleStock');
            else serialStock = (Double)serialInv[0].get('avaialbleStock');

        }catch(Exception e){
            /*'exception occured : '+ e.getMessage() + '; At line : ' + e.getLineNumber()*/
            //throw new AuraHandledException(e.getMessage());
        }
        return serialStock;
    }

    @AuraEnabled
    public static Double getBatchStock(String batchId){
        try{
            Double batchStock = 0.0;
            List<AggregateResult> batchInv = new List<AggregateResult>();
            batchInv = [SELECT SUM(ERP7__Number_of_Item_In_Stock__c) avaialbleStock FROM ERP7__Inventory_Stock__c WHERE ERP7__Batch_Lot__c =: batchId AND ERP7__Batch_Lot__c != null AND ERP7__Number_of_Item_In_Stock__c > 0 GROUP BY ERP7__Batch_Lot__c];
            if(batchInv.size() > 0) batchStock = (Double)batchInv[0].get('avaialbleStock');
            return batchStock;
        }catch(Exception e){ throw new AuraHandledException(e.getMessage()); }
    }

    @AuraEnabled
    public static String setSerials(Integer startNum,String MOId,String woId,String serPrefix){
        try{
            List<ERP7__Serial_Number__c> failedRecords = new List<ERP7__Serial_Number__c>();
            if(startNum != null && MOId != null && MOId != ''){

                List<WIPFlowWrap> flowWrap = new  List<WIPFlowWrap>();
                List<ERP7__Serial_Number__c> serials = [Select Id,Name,ERP7__Serial_Number__c,ERP7__Barcode__c from ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c =: MOId];
                if(serials.size() > 0){
                    String format = (serPrefix != null && serPrefix != '') ? serPrefix : System.Label.Serial_Number_Format;
                    system.debug('format : '+format);
                    for(ERP7__Serial_Number__c ser : serials){
                        ser.Name = ser.ERP7__Serial_Number__c = ser.ERP7__Barcode__c = format + String.valueOf(startNum);
                        system.debug('ser.Name  : '+ser.Name );
                        startNum++;
                    }
                    List<Database.SaveResult> updateResults = Database.update(serials, false);

                    Integer counter = 0;
                    for (Database.SaveResult result : updateResults) {
                        if (!result.isSuccess()) {      failedRecords.add(serials[counter]);
                        }
                        counter++;
                    }

                    if (failedRecords.isEmpty()) {
                        List<ERP7__WIP_Flow__c> wipflows = new List<ERP7__WIP_Flow__c>();
                        if(woId != null && woId != ''){
                            String wpallFields = UtilClass.selectStarFromSObject('ERP7__WIP_Flow__c');
                            wpallFields += ' , ERP7__WIP__r.ERP7__Serial_Number__c,ERP7__WIP__r.ERP7__Serial_Number__r.Name,ERP7__Product__r.Name, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Work_Orders__r.Name, ERP7__Work_Orders__r.ERP7__Quantity_Ordered__c ,ERP7__Work_Orders__r.ERP7__Quantity_Scrapped__c,ERP7__Product__r.ERP7__UoM__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Version__r.Name';
                            string wpquery = 'select ' + String.escapeSingleQuotes(wpallFields) + ' from ERP7__WIP_Flow__c where ERP7__Work_Orders__c = :woId';
                            wipflows =  Database.query(wpquery);


                        }
                        if(wipflows.size() > 0) {
                            for(ERP7__WIP_Flow__c wip : wipflows )  flowWrap.add(new WIPFlowWrap(wip,false,false));
                            return JSON.serialize(flowWrap);
                        }
                        else return null;

                    }
                    else{
                        String failedRecordsMessage = 'Failed to generate the following serial numbers: ';

                        for (ERP7__Serial_Number__c failedRecord : failedRecords) {     failedRecordsMessage += failedRecord.Name + ', ';        }
                        failedRecordsMessage += 'as the serial number already exists ';
                        return failedRecordsMessage;
                    }
                }
            }

            return null;
        }
        catch(Exception e){
            if (e.getMessage().contains('Duplicate') || e.getMessage().contains('duplicate'))
            {
                return 'Duplicate serial numbers found. Please change the serial start number.';
            } else
            {
                return 'Error: ' + e.getMessage();
            }
        }
    }
    @AuraEnabled
    public static List<ERP7__Serial_Number__c> getSerialNumbers(Integer offsetVal,string Mo,Integer limitSer,List<String> SerialIds){
        if(limitSer == null || limitSer == 0) limitSer = 100;
        if(SerialIds == null) SerialIds = new List<String>();
        List<ERP7__Serial_Number__c> serialNums= [Select Id,Name,ERP7__Availability_date__c,ERP7__Available__c,ERP7__Barcode__c,ERP7__Date_of_Manufacture__c,ERP7__Serial_Number__c,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Id,ERP7__Manufacturing_Order__r.Name from  ERP7__Serial_Number__c where ERP7__Manufacturing_Order__c   = :Mo and Id Not In : SerialIds  LIMIT :limitSer OFFSET :offsetVal];
        return serialNums;
    }
    @AuraEnabled
    public static List<ERP7__WIP_Flow__c> getWIPFlows(Integer offsetVal,string Mo){
        List<ERP7__WIP_Flow__c> wipflows = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Version__c,ERP7__Version__r.Name,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Work_Orders__c,ERP7__Work_Orders__r.Id,ERP7__Work_Orders__r.Name,ERP7__Quantity_Ordered__c,ERP7__Quantity__c,ERP7__Quantity_Scrapped__c,ERP7__WIP__c,ERP7__WIP__r.ERP7__Serial_Number__c,ERP7__WIP__r.ERP7__Serial_Number__r.Name,ERP7__WIP__r.ERP7__Material_Batch_Lot__c,ERP7__WIP__r.ERP7__Material_Batch_Lot__r.Name from  ERP7__WIP_Flow__c where ERP7__WIP__r.ERP7__MO__c   = :Mo LIMIT 100 OFFSET :offsetVal];
        return wipflows;
    }
    public class WIPFlowWrap{
        @AuraEnabled public ERP7__WIP_Flow__c wipFlow                               { get ; set; }
        @AuraEnabled public Boolean selected                                        { get ; set; }
        @AuraEnabled public Boolean  StockNotAllocated                              { get ; set; }
        @AuraEnabled public Boolean  StockAllocated                                 { get ; set; }
        public WIPFlowWrap(ERP7__WIP_Flow__c  wip,Boolean selectval,Boolean NotAllocated){
            wipFlow   =     wip;
            selected    =   selectval;
            StockNotAllocated = NotAllocated;
        }
        public WIPFlowWrap(){
            wipFlow   =     new ERP7__WIP_Flow__c ();
            selected    =   false;
            StockNotAllocated = false;
            StockAllocated = true;
        }


    }
    public class comWrap {
        @AuraEnabled public ERP7__WO__c WorkOrder                                   { get ; set; }
        @AuraEnabled public ERP7__Manufacturing_Order__c manuOrders                 { get ; set; }
        @AuraEnabled public ERP7__Employees__c Employee                             { get ; set; }
        @AuraEnabled public ERP7__Timesheet__c TimeSheet                            { get ; set; }
        @AuraEnabled public List< ERP7__Time_Card_Entry__c > TimeCardEntries        { get ; set; }
        @AuraEnabled public ERP7__Time_Card_Entry__c SelectedTask_TimeCardEntry     { get ; set; }
        @AuraEnabled public List<ERP7__Actions_Tasks__c> Tasks                      { get ; set; }
        @AuraEnabled public List<OperationAttachments> OperationAttachmentsList     { get ; set; }
        @AuraEnabled public ERP7__Actions_Tasks__c SelectedTask                     { get ; set; }
        @AuraEnabled public List< ERP7__MRP__c > MRPS                               { get ; set; }
        @AuraEnabled public List< mrpWrap > MRPSS                                   { get ; set; }
        @AuraEnabled public List< mrpWrapBW > MRPSSBW                               { get ; set; }
        @AuraEnabled public ERP7__Actions_Tasks__c NewTask                          { get ; set; }
        @AuraEnabled public Note NewNote                                            { get ; set; }
        @AuraEnabled public ERP7__MRP__c NewMRP                                     { get ; set; }
        @AuraEnabled public ERP7__Stock_Outward_Line_Item__c NewSOLI                { get ; set; }
        @AuraEnabled public Attachment SelectedAttachment                           { get ; set; }
        @AuraEnabled public List<Attachment> SelectedAttachments                    { get ; set; }
        @AuraEnabled public List<Attachment> Signatures                             { get ; set; }
        @AuraEnabled public List<Note> SelectedNotes                                { get ; set; }
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public Boolean Batch                                           { get ; set; }
        @AuraEnabled public Boolean Serial                                          { get ; set; }
        @AuraEnabled public Boolean Busy                                            { get ; set; }
        @AuraEnabled public Boolean Permit                                          { get ; set; }
        @AuraEnabled public Boolean ReserveStock                                    { get ; set; }
        @AuraEnabled public List< ERP7__Variance__c > AlternativeBOMs               { get ; set; }
        @AuraEnabled public List<ERP7__Stock_Outward_Line_Item__c> SOLIs            { get ; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> moSerialNos                { get ; set; }
        @AuraEnabled public List<ERP7__Batch__c> moBatchNos                         { get ; set; }
        @AuraEnabled public String nextWO                                           { get ; set; }
        @AuraEnabled public String prevWO                                           { get ; set; }
        @AuraEnabled public List< ERP7__Resource_Allocation__c > RAS                { get ; set; }
        @AuraEnabled public List< WorkPlanner > WorkPlanners                        { get ; set; }
        @AuraEnabled public List< Resource > AvailableResources                     { get ; set; }
        @AuraEnabled public ERP7__Capacity_Planner__c CapacityPlanner               { get ; set; }
        @AuraEnabled public List<selectOptions> wpList                              { get ; Set; }
        @AuraEnabled public List<selectOptions> Types                               { get ; Set; }
        @AuraEnabled public List<selectOptions> Statuses                            { get ; Set; }
        @AuraEnabled public List< ERP7__WIP__c > WIPs                               { get ; set; }
        @AuraEnabled public List< WIPFlowWrap > WIPFlows                      { get ; set; }
        @AuraEnabled public List<ERP7__UOM_Conversion__mdt> UOMCs                   { get ; set; }
        @AuraEnabled public List<WO__c> AllWOs                                      { get ; set; }
        @AuraEnabled public Attachment Attachment                                   { get ; set; }
        @AuraEnabled public List<Product2> WOproducts                               { get ; set; }
        @AuraEnabled public List<ERP7__Checklist__c> checklist                      { get ; set; }
        @AuraEnabled public List<ERP7__Guideline_Checklists__c> guidelines          { get ; set; }
        @AuraEnabled public Boolean recordCreated                                   { get ; set; }
        @AuraEnabled public List<taskswrap> tasklist                                { get ; set; }
        @AuraEnabled public List<Boolean> rendertabs                                { get ; set; }
        @AuraEnabled public Boolean executeParallel                                 { get ; set; }
        @AuraEnabled public Boolean linksNewOptions                                 { get ; set; }
        @AuraEnabled public Boolean showAutoStockAllocation                         { get ; set; }
        @AuraEnabled public Boolean showManualStockAllocation                       { get ; set; }
        @AuraEnabled public Boolean ShowWorkCenter                                  { get ; set; }
        @AuraEnabled public Boolean showProdDesc                                    { get ; set; }
        @AuraEnabled public Boolean EnterconsumeQtyAutomatical                      { get ; set; }
        @AuraEnabled public Boolean ShowCustomSerailNumberGeneration                { get ; set; }
        @AuraEnabled public Boolean byPassWOComplete                                { get ; set; }
        @AuraEnabled public Boolean showSearch                                      { get ; set; }
        @AuraEnabled public Boolean showProducedSection                             { get ; set; }
        @AuraEnabled public Boolean maxCutValidation                                { get ; set; }
        @AuraEnabled public Boolean hideToProduceForOnlyMRP                         { get ; set; }
        @AuraEnabled public Integer serialsLength                                   { get; set; }
        @AuraEnabled public Decimal MaxCuts                                         { get; set; }
        @AuraEnabled public Decimal MRPQuantity                                     { get ; set; }
        @AuraEnabled public List<Note> Allnotes                                     { get ; set; }
        @AuraEnabled public Boolean showNotes                         { get ; set; }
        @AuraEnabled public Boolean ShowProdStatus                         { get ; set; }
         @AuraEnabled public Boolean showVendorCode                                   { get; set; }
         @AuraEnabled public Boolean showScrapDetails                                     { get; set; }
        @AuraEnabled public list<Taskwrapper> taskwrapList { get; set; }
        public comWrap() {
            taskwrapList = new List<Taskwrapper>();
            MaxCuts = 0;
            MRPQuantity= 0;
            serialsLength = 0;
            byPassWOComplete = showVendorCode = showScrapDetails = false;
            maxCutValidation = false;
            showSearch = false;
            showProducedSection = false;
            ShowCustomSerailNumberGeneration = false;
            WorkOrder = new ERP7__WO__c();
            manuOrders = new ERP7__Manufacturing_Order__c();
            TimeSheet = new ERP7__Timesheet__c();
            TimeCardEntries= new List< ERP7__Time_Card_Entry__c >();
            SelectedTask_TimeCardEntry = new ERP7__Time_Card_Entry__c();
            Tasks = new List<ERP7__Actions_Tasks__c>();
            MRPS = new List< ERP7__MRP__c >();
            MRPSS = new List< mrpWrap >();
            MRPSSBW = new List< mrpWrapBW >();
            OperationAttachmentsList = new List<OperationAttachments>();
            SelectedTask = new ERP7__Actions_Tasks__c();
            NewTask = new ERP7__Actions_Tasks__c();
            NewNote = new Note();
            NewMRP = new ERP7__MRP__c();
            NewSOLI = new ERP7__Stock_Outward_Line_Item__c();
            SelectedAttachment = new Attachment();
            SelectedAttachments = new List<Attachment>();
            Signatures = new List<Attachment>();
            SelectedNotes = new List<Note>();
            Employee = new ERP7__Employees__c();
            AlternativeBOMs = new List<ERP7__Variance__c>();
            errorMsg = prevWO = nextWO = '';
            Batch = false;
            Serial = false;
            Busy = false;
            executeParallel = false;
            Permit = true;
            ReserveStock = false;
            SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
            RAS = new List< ERP7__Resource_Allocation__c >();
            WorkPlanners = new List< WorkPlanner >();
            AvailableResources = new List< Resource >();
            CapacityPlanner = new ERP7__Capacity_Planner__c();
            WIPs = new List< ERP7__WIP__c >();
            WIPFlows = new List< WIPFlowWrap>();
            wpList = new List<selectOptions>();
            Types = new List<selectOptions>();
            Statuses = new List<selectOptions>();
            UOMCs = new List<ERP7__UOM_Conversion__mdt>();
            AllWOs = new List<WO__c>();
            Attachment = new Attachment();
            WOproducts = new List<Product2>();
            checklist = new List<ERP7__Checklist__c>();
            guidelines = new List<ERP7__Guideline_Checklists__c>();
            recordCreated = false;
            tasklist = new List<taskswrap>();
            rendertabs = new List<Boolean>();
            linksNewOptions = true;
            showAutoStockAllocation = true;
            showManualStockAllocation = true;
            ShowWorkCenter = true;
            showProdDesc = false;
            EnterconsumeQtyAutomatical = false;
            Allnotes = new List<Note>();
            showNotes = false;
            ShowProdStatus = false;
        }
    }

    public class taskswrap {
        @AuraEnabled public ERP7__Actions_Tasks__c Task                          { get ; set; }
        @AuraEnabled public Boolean isSelected                                    { get ; set; }
        @AuraEnabled public List<ERP7__Guideline_Checklists__c> checklists        { get ; set; }

        public taskswrap() {
            Task = new ERP7__Actions_Tasks__c();
            isSelected = false;
            checklists = new List<ERP7__Guideline_Checklists__c>();
        }
    }

    public  class Taskwrapper {
        @AuraEnabled public List<Note> Noteslist { get; set; }
        @AuraEnabled public ERP7__Actions_Tasks__c Task { get; set; }


        public TaskWrapper(ERP7__Actions_Tasks__c task) {
            this.task = task;
            notesList = new List<Note>();
        }

        // Empty constructor for serialization
        public TaskWrapper() {
            task = new ERP7__Actions_Tasks__c();
            notesList = new List<Note>();
        }
    }

    public class OperationAttachments {
        @AuraEnabled public ERP7__Operation__c Operation                            { get ; set; }
        @AuraEnabled public List<Attachment> Attachments                            { get ; set; }

        public OperationAttachments() {
            Operation = new ERP7__Operation__c();
            Attachments = new List<Attachment>();
        }
    }

    public class WorkPlanner {
        @AuraEnabled public ERP7__Work_Planner__c WorkPlanner                       { get ; set; }
        @AuraEnabled public List< ERP7__Resource_Requirement__c > RRS               { get ; set; }
        @AuraEnabled public Boolean isSelect                                        { get ; set; }

        public WorkPlanner() {
            WorkPlanner = new ERP7__Work_Planner__c();
            RRS = new List< ERP7__Resource_Requirement__c >();
            isSelect = false;
        }
    }

    public class Resource {
        @AuraEnabled public ERP7__Resource__c Resource                          { get ; set; }
        @AuraEnabled public Boolean isSelect                                    { get ; set; }

        public Resource() {
            Resource = new ERP7__Resource__c();
            isSelect = false;
        }
    }

    public class mrpWrap {
        @AuraEnabled public ERP7__MRP__c MRP                                        { get ; set; }
        @AuraEnabled public Decimal quantityToConsume                               { get ; set; }
        @AuraEnabled public Decimal quantityToScrap                                 { get ; set; }
        @AuraEnabled public ERP7__Stock_Outward_Line_Item__c SOLI                   { get ; set; }
        @AuraEnabled public List<ERP7__Stock_Inward_Line_Item__c> SILIS             { get ; set; }
        @AuraEnabled public String Lot_Serial                                       { get ; set; }
        @AuraEnabled public Decimal Qnty                                            { get ; set; }
        @AuraEnabled public Decimal Stock                                           { get ; set; }
        @AuraEnabled public Boolean isSelect                                        { get ; set; }
        @AuraEnabled public Decimal ActualWeight                                    { get ; set; }
        @AuraEnabled public List<ERP7__Stock_Outward_Line_Item__c> SOLIs            { get ; set; }
        @AuraEnabled public List<selectOptions> UOMS                                { get ; set; }
        @AuraEnabled public String SelectedUOM                                      { get ; set; }
        @AuraEnabled public Decimal WeightMultiplier                                { get ; set; }
        @AuraEnabled public Decimal BOMWeightMultiplier                             { get ; set; }
        @AuraEnabled public ERP7__Product_Feature__c Feature                        { get ; set; }
        @AuraEnabled public Decimal MRPQuantity                                     { get ; set; }
        @AuraEnabled public List<Id> StockallocatedSerials                          { get ; set; }
        public mrpWrap() {
            StockallocatedSerials = new List<Id>();
            MRPQuantity = 0;
            MRP = new ERP7__MRP__c();
            quantityToConsume = 0;
            quantityToScrap = 0;
            WeightMultiplier = 1;
            BOMWeightMultiplier = 1;
            Lot_Serial = '';
            SOLI = new ERP7__Stock_Outward_Line_Item__c();
            SILIS = new List<ERP7__Stock_Inward_Line_Item__c>();
            Qnty = 0;
            Stock = 0;
            ActualWeight = 0;
            isSelect = false;
            SOLIs = new List<ERP7__Stock_Outward_Line_Item__c>();
            UOMS = new List < selectOptions > ();
            SelectedUOM = '';
            Feature = new ERP7__Product_Feature__c();
        }
    }

    public class mrpWrapBW {
        @AuraEnabled public ERP7__MRP__c MRP                                        { get ; set; }
        @AuraEnabled public List<ERP7__MRP__c> MRPs                                 { get ; set; }
        @AuraEnabled public List<ERP7__Stock_Outward_Line_Item__c> SOLIs            { get ; set; }
        @AuraEnabled public Decimal Stock                                           { get ; set; }
        @AuraEnabled public Decimal Qnty                                            { get ; set; }
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public Boolean isSelect                                        { get ; set; }
        @AuraEnabled public String bgColor                                          { get ; set; }
        @AuraEnabled public ERP7__Manufacturing_Order__c MO                         { get ; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> SerialNos                  { get ; set; }
        @AuraEnabled public List<ERP7__Batch__c> Batches
                                    { get ; set; }
        @AuraEnabled public Decimal ActualWeight                                    { get ; set; }
        @AuraEnabled public List<selectOptions> UOMS                                { get ; set; }
        @AuraEnabled public String SelectedUOM                                      { get ; set; }
        @AuraEnabled public Decimal WeightMultiplier                                { get ; set; }
        @AuraEnabled public Decimal BOMWeightMultiplier                             { get ; set; }
        @AuraEnabled public ERP7__Product_Feature__c Feature                        { get ; set; }

        public mrpWrapBW() {
            MRP = new ERP7__MRP__c();
            MRPs = new List < ERP7__MRP__c > ();
            Stock = 0;
            Qnty = 0;
            WeightMultiplier = 1;
            BOMWeightMultiplier = 1;
            errorMsg = '';
            isSelect = false;
            bgColor = '#fff';
            MO = new ERP7__Manufacturing_Order__c();
            SOLIs = new List < ERP7__Stock_Outward_Line_Item__c > ();
            SerialNos = new List < ERP7__Serial_Number__c > ();
            Batches = new List < ERP7__Batch__c > ();
            ActualWeight = 0;
            UOMS = new List < selectOptions > ();
            SelectedUOM = '';
            Feature = new ERP7__Product_Feature__c();
        }
    }

    public class ScanWrap {
        @AuraEnabled public String step                                             { get ; set; }
        @AuraEnabled public String substep                                          { get ; set; }
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public ERP7__Serial_Number__c Serial                           { get ; set; }
        @AuraEnabled public ERP7__Batch__c Batch                                    { get ; set; }

        public ScanWrap() {
            step = '';
            substep = '';
            errorMsg = '';
            Serial = new ERP7__Serial_Number__c();
            Batch = new ERP7__Batch__c();
        }
    }

    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }

        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab;
            value = val;
            selected = sel;
        }
    }
    public static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    @AuraEnabled
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<String>> objResults = new Map<String,List<String>>();

        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){  return objResults;
                          }

        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();

        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){ return objResults;
                                                                                                   }

        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();

        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        for (PicklistEntryWrapper plew : depEntries) {

            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class PicklistEntryWrapper{

        public String label {get;set;} public String active {get;set;} public String value {get;set;}
        public String validFor {get;set;} public String defaultValue {get;set;}
        public PicklistEntryWrapper(){
        }

    }
    @AuraEnabled
    public static comWrap Savechecklists(String check, String WorkId,String guideline,String tsks){
        comWrap comW = new comWrap();
        try{
            List<taskswrap> tasklst = (List<taskswrap>)  JSON.deserialize(tsks, List<taskswrap>.class);
            //List<ERP7__Checklist__c> checklists  =new List<ERP7__Checklist__c>();
            //system.debug('check : '+check);
            //if(check != null && check != '')  checklists  = (List<ERP7__Checklist__c>)  JSON.deserialize(check, List<ERP7__Checklist__c>.class);
            // added (checklists != null) SM 9 oct below if
            //if(checklists != null && checklists.size() > 0 && Schema.sObjectType.ERP7__Checklist__c.isUpdateable()){ update checklists;}else{/*No access*/}
            List<ERP7__Guideline_Checklists__c> checklist2create = new List<ERP7__Guideline_Checklists__c> ();
            //List<ERP7__Guideline_Checklists__c> checkexits = new  List<ERP7__Guideline_Checklists__c>();
            //if(guideline != null && guideline != '') checkexits   = (List<ERP7__Guideline_Checklists__c>) JSON.deserialize(guideline, List<ERP7__Guideline_Checklists__c>.class);
            List<ERP7__Actions_Tasks__c> actionlist = new List<ERP7__Actions_Tasks__c>();
            List<ERP7__Actions_Tasks__c> alltasks = new List<ERP7__Actions_Tasks__c>();

            if(tasklst.size() > 0){
                for(taskswrap tsk : tasklst){
                    alltasks.add(tsk.Task);
                    if(tsk.isSelected){
                        ERP7__Actions_Tasks__c tss = tsk.Task;
                        //if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Status__c.isUpdateable()){tss.ERP7__Status__c = 'Completed';}else{/*No access*/}
                        system.debug('tss : '+tss.ERP7__Status__c);
                        actionlist.add(tss);
                        if(tsk.checklists != null && tsk.checklists.size() > 0) {
                            checklist2create.addAll(tsk.checklists);
                        }
                    }
                }
            }
            if(checklist2create.size() > 0) {
                for(ERP7__Guideline_Checklists__c gcsk : checklist2create){
                    gcsk.ERP7__Checklist__r = null;
                }
                upsert checklist2create;
            }
            system.debug('actionlist : '+actionlist.size());
            if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()) { update actionlist; }else{/*No access*/}
            comW.Tasks = alltasks;
            List<taskswrap> tskwr = new List<taskswrap>();

            comW.tasklist = tasklst;
            Set<Id> chekids = new Set<Id>();
            /*if(checkexits.size() > 0){ comW.guidelines =checkexits;  comW.recordCreated = true;  comW.checklist = checklists;
                                     }
            else if(checklists != null){ // added (checklists != null) SM 9 oct

                for(ERP7__Checklist__c ch : checklists){
                    ERP7__Guideline_Checklists__c checkist = new ERP7__Guideline_Checklists__c();
                    if(Schema.sObjectType.ERP7__Guideline_Checklists__c.fields.Name.isCreateable()){checkist.Name = ch.Name;}else{}
                    if(Schema.sObjectType.ERP7__Guideline_Checklists__c.fields.ERP7__Checklist__c.isCreateable()){checkist.ERP7__Checklist__c = ch.Id;}else{}
                    if(ch.ERP7__Result__c !=  null && ch.ERP7__Result__c != ''){ if(Schema.sObjectType.ERP7__Guideline_Checklists__c.fields.ERP7__Instructions__c.isCreateable()){checkist.ERP7__Instructions__c = ch.ERP7__Result__c;}else{} }
                    else if(ch.ERP7__Action_Detail__c !=  null && ch.ERP7__Action_Detail__c != ''){  if(Schema.sObjectType.ERP7__Guideline_Checklists__c.fields.ERP7__Instructions__c.isCreateable()){checkist.ERP7__Instructions__c = ch.ERP7__Action_Detail__c;}else{} }
                    if(WorkId != '' && WorkId != null){ if(Schema.sObjectType.ERP7__Guideline_Checklists__c.fields.ERP7__Work_Orders__c.isCreateable()){checkist.ERP7__Work_Orders__c = WorkId;}else{} }
                    for(ERP7__Actions_Tasks__c act : alltasks){

                        if(ch.ERP7__Operation__c == act.ERP7__Operation__c) {  if(Schema.sObjectType.ERP7__Guideline_Checklists__c.fields.ERP7__Action_Task__c.isCreateable()){checkist.ERP7__Action_Task__c = act.Id;}else{}
                                                                            }
                    }

                    checklist2create.add(checkist);
                }


                if(checklist2create.size() > 0){
                    if(Schema.sObjectType.ERP7__Guideline_Checklists__c.isCreateable()) { insert checklist2create; } else{}
                    comW.guidelines =checklist2create;
                    comW.recordCreated = true;
                    for(ERP7__Checklist__c ch : checklists){ ch.ERP7__Result__c = ''; ch.ERP7__Action_Detail__c = '';}
                    update checklists;
                    comW.checklist = checklists;
                }
            }    */
        }
        catch(Exception e) {  comW.errorMsg = e.getMessage() +' Line Number 30@ : '+ e.getLineNumber();
                            system.debug(' Error : '+e.getMessage() +' Line Number 30@ : '+ e.getLineNumber());
                           }
        return comW;
    }
    @AuraEnabled
    public static String CompleteWipandWO(String WorkOrder,String WIPs){
        ERP7__WO__c WO = (ERP7__WO__c) JSON.deserialize(WorkOrder, ERP7__WO__c.class);

        if(Schema.sObjectType.ERP7__WO__c.isUpdateable()){update WO;}else{/*No access*/}
        List<WIPFlowWrap> wipflows = (List<WIPFlowWrap>) JSON.deserialize(WIPs, List<WIPFlowWrap>.class);
        system.debug('wipflows : '+wipflows.size());
        set<Id> wipIds = new set<Id>();
        for(WIPFlowWrap all : wipflows){
            if(all.wipFlow != Null && all.wipFlow.Id != Null) wipIds.add(all.wipFlow.Id);
        }
        List<ERP7__WIP_Flow__c> Wip = [Select Id,Name,ERP7__Status__c from ERP7__WIP_Flow__c where Id IN:wipIds];
        for(ERP7__WIP_Flow__c wip1 : Wip){
            if(wip1.ERP7__Status__c != 'Completed'){ if(Schema.sObjectType.ERP7__WIP_Flow__c.fields.ERP7__Status__c.isUpdateable()){wip1.ERP7__Status__c = 'Completed';}else{/*No access*/} }
        }
        if(Schema.SObjectType.ERP7__WIP_Flow__c.isUpdateable() && Wip.size() > 0){update Wip;}else{/*No access*/}
        return 'SUCCESS';
    }

    @AuraEnabled
    public static comWrap completetheWOandWIP(String Task1,String WO1,String MRPSSS,String all_UOMs,String WIPflows,String type,String SelectSerials) {
        comWrap comW = new comWrap();
        Savepoint sp = Database.setSavepoint();
        try{
            List<mrpWrap> MRPSS = new List<mrpWrap>();
            if(MRPSSS != null && MRPSSS != '') MRPSS = (List<mrpWrap>) JSON.deserialize(MRPSSS, List<mrpWrap>.class);
            ERP7__WO__c WO = (ERP7__WO__c) JSON.deserialize(WO1, ERP7__WO__c.class);
            Id WOId = WO.Id;
            ERP7__Actions_Tasks__c Task = (ERP7__Actions_Tasks__c) JSON.deserialize(Task1, ERP7__Actions_Tasks__c.class);
            List<ERP7__WIP_Flow__c>  wipflows2update = (List<ERP7__WIP_Flow__c>) JSON.deserialize(WIPflows, List<ERP7__WIP_Flow__c>.class);
            List<ERP7__Serial_Number__c> serials2Update = (List<ERP7__Serial_Number__c>) JSON.deserialize(SelectSerials, List<ERP7__Serial_Number__c>.class);
            //new code below to get the batch lot for Serial-Batch Prod
            String batchLot='';
            System.debug('wipflows2update -- ');
            System.debug(wipflows2update);
            if(wipflows2update!=null && wipflows2update.size()>0){
                if(wipflows2update[0]!=null && wipflows2update[0].Id!=null){
                    ERP7__WIP_Flow__c wp=[select Id, ERP7__WIP__c, ERP7__WIP__r.ERP7__Material_Batch_Lot__c  from ERP7__WIP_Flow__c where Id=:wipflows2update[0].Id] ;
                    if(wp!=null && wp.ERP7__WIP__c!=null && wp.ERP7__WIP__r.ERP7__Material_Batch_Lot__c!=null){
                        batchLot=wp.ERP7__WIP__r.ERP7__Material_Batch_Lot__c;
                    }
                }
            }
            System.debug('batchlot --- '+batchLot);
            if(serials2Update.size() > 0){
                //new code to assign batchlot
                if(batchLot!=''){
                    for(ERP7__Serial_Number__c sr:serials2Update){
                        sr.ERP7__Material_Batch_Lot__c=batchLot;
                    }
                }
               PreventRecursiveLedgerEntry.ProceedSerialsTrigger = true; update serials2Update;

            }
            if(wipflows2update.size() > 0) {
                upsert wipflows2update;
            }
            Boolean iscompleted = false;
            Integer count=0;
            List<ERP7__WIP_Flow__c> allwipFlowsupdated = [Select Id,Name,ERP7__Product__c,ERP7__Status__c,ERP7__Quantity__c,ERP7__Work_Orders__r.ERP7__Product__c,ERP7__Type__c,ERP7__Quantity_Ordered__c from ERP7__WIP_Flow__c where ERP7__Work_Orders__c =:WOId];

            for(ERP7__WIP_Flow__c wip : allwipFlowsupdated){  if(wip.ERP7__Quantity__c == wip.ERP7__Quantity_Ordered__c)  count= count+1; else{ comW.WipFlows.add(new WIPFlowWrap(wip,false,false)); if(comW.WipFlows.size() == 200) break;}  }
            if(count == allwipFlowsupdated.size()) iscompleted = true;  else iscompleted = false;
            allwipFlowsupdated = new List<ERP7__WIP_Flow__c>();
            system.debug('iscompleted : '+iscompleted);
            system.debug('WO.ERP7__Quantity_Built__c : '+WO.ERP7__Quantity_Built__c);
            system.debug('WO.ERP7__Quantity_Scrapped__c : '+WO.ERP7__Quantity_Scrapped__c);
            if((WO.ERP7__Quantity_Built__c + WO.ERP7__Quantity_Scrapped__c) == WO.ERP7__Quantity_Ordered__c){ if(Schema.sObjectType.ERP7__WO__c.fields.ERP7__Status__c.isUpdateable()){WO.ERP7__Status__c = 'Complete';}else{/*No access*/} }
            if(Task.ERP7__Status__c == 'Completed' && WO.ERP7__Status__c == 'Complete') {
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__End_Date__c.isUpdateable()){Task.ERP7__End_Date__c = system.Now(); }else{/*No access*/}
                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Actual_End_Time__c.isUpdateable()){Task.ERP7__Actual_End_Time__c = system.Now();}else{/*No access*/}
            }
            if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){update Task;}else{/*No access*/}
            List<Id> mrpIds = new List<Id>();
            List<ERP7__MRP__c> mrps2Update = new List<ERP7__MRP__c>();
            for(mrpWrap MRPS: MRPSS){
                mrps2Update.add(MRPS.MRP);  mrpIds.add(MRPS.MRP.Id);
            }
            List<ERP7__Stock_Inward_Line_Item__c> Inwards = Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirement_Planning__c, ERP7__Product__c, ERP7__Process__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c  FROM ERP7__Stock_Inward_Line_Item__c WHERE ERP7__MRP_Material_Requirement_Planning__c In :mrpIds');
            List<ERP7__Stock_Outward_Line_Item__c> Outwards = Database.query('SELECT Id, Name, ERP7__Active__c, ERP7__BoM__c, ERP7__Manufacturing_Order__c, ERP7__Material_Batch_Lot__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Process__c, ERP7__Product__c, ERP7__Manufacturing_Order__r.ERP7__Product__c, ERP7__Manufacturing_Order__r.ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Version__c, ERP7__Quantity__c, ERP7__Serial__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Status__c, ERP7__Work_Orders__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c,  ERP7__Site_Product_Service_Inventory_Stock__r.ERP7__Warehouse__c,ERP7__MO_WO_Serial__c,ERP7__MO_WO_Material_Batch_Lot__c FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__MRP_Material_Requirements_Planning__c In :mrpIds AND ERP7__Manufacturing_Order__r.ERP7__Product__c != null and ERP7__MO_WO_Serial__c IN : serials2Update ');

            List<ERP7__Stock_Outward_Line_Item__c> SOLIS2Upsert = new List<ERP7__Stock_Outward_Line_Item__c>();
            Map<Id,ERP7__Stock_Outward_Line_Item__c> SOLI2UpsertMap = new Map<Id,ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Inventory_Stock__c> Stocks = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Stock_Inward_Line_Item__c> SPLIs = new List<ERP7__Stock_Inward_Line_Item__c>();
            Map<Id, ERP7__Stock_Inward_Line_Item__c> StockInwardMap = new Map<Id, ERP7__Stock_Inward_Line_Item__c>();
             Map<Id, ERP7__Inventory_Stock__c> StockInMap = new Map<Id, ERP7__Inventory_Stock__c>();
            Boolean InwardError = false;
            Boolean OutwardError = false;
            String TaskFields = UtilClass.selectStarFromSObject('ERP7__Actions_Tasks__c');
            String AllTaskFields = TaskFields + ', ERP7__Work_Center__r.Name, ERP7__Work_Order__r.Project__c, ERP7__Work_Order__r.Name, ERP7__Work_Order__r.ERP7__Process_Cycle__c, ERP7__Operation__r.ERP7__Timer__c, ERP7__Operation__r.ERP7__Label_Generator__c, ERP7__Operation__r.ERP7__Is_Signature_Required__c ';
            String tId = Task.Id;

            for(mrpWrap MRPS: MRPSS){
                if((MRPS.quantityToConsume + MRPS.quantityToScrap) > 0){
                    comW.errorMsg = '';
                    Decimal stock2insert = MRPS.quantityToConsume + MRPS.quantityToScrap;
                    Decimal stock2Consume = MRPS.quantityToConsume; //MRPS.MRP.ERP7__Consumed_Quantity__c;
                    Decimal stock2Scrap = MRPS.quantityToScrap;
                    //start UOM Calc
                    List<ERP7__UOM_Conversion__mdt> allUOMCs = (List<ERP7__UOM_Conversion__mdt>) JSON.deserialize(all_UOMs, List<ERP7__UOM_Conversion__mdt>.class);
                    String prodUOM = MRPS.MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure;  String bomUOM  = MRPS.MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                    if(prodUOM != null && prodUOM != '' && bomUOM != null && bomUOM != '' && bomUOM != prodUOM){
                        for(Integer k=0; k<allUOMCs.size(); k++){
                            if((allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM) || (allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM)){
                                comW.errorMsg = '';
                                if(allUOMCs[k].ERP7__From_UOM__c == prodUOM && allUOMCs[k].ERP7__To_UOM__c == bomUOM){
                                    stock2Consume = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Consume;
                                    stock2Scrap = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Scrap;
                                }
                                else if(allUOMCs[k].ERP7__From_UOM__c == bomUOM && allUOMCs[k].ERP7__To_UOM__c == prodUOM){
                                    stock2Consume = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Consume;
                                    stock2Scrap = allUOMCs[k].ERP7__From_Value__c/allUOMCs[k].ERP7__To_Value__c*stock2Scrap;
                                }
                                else comW.errorMsg = 'UOM Conversion not found.';
                                break;
                            }

                        }
                    }
                    allUOMCs = new List<ERP7__UOM_Conversion__mdt>();
                    //end UOM Calc
                    for(ERP7__Stock_Inward_Line_Item__c SILI : Inwards){
                        if(MRPS.MRP.Id == SILI.ERP7__MRP_Material_Requirement_Planning__c && stock2insert > 0 && MRPS.MRP.ERP7__MRP_Product__c == SILI.ERP7__Product__c){
                            ERP7__MRP__c MRP = MRPS.MRP;
                            Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c(); if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){SDLI.Name = MRP.Name;}else{/*No access*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Active__c.isUpdateable()){SDLI.Active__c = true;}else{/*No access*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Process__c.isUpdateable()){SDLI.Process__c = MRP.Process__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isUpdateable()){SDLI.Schedule__c = MRP.Schedule__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.MRP_Material_Requirements_Planning__c.isUpdateable()){SDLI.MRP_Material_Requirements_Planning__c = MRP.Id;}else{/*No access*/}   if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.BoM__c.isUpdateable()){SDLI.BoM__c = MRP.BOM__c;}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Status__c.isUpdateable()){SDLI.Status__c = 'Committed';}else{/*No access*/}  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Product__c.isUpdateable()){SDLI.Product__c = MRP.MRP_Product__c;}else{/*No access*/} if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Site_Product_Service_Inventory_Stock__c.isCreateable()){SDLI.Site_Product_Service_Inventory_Stock__c = SILI.ERP7__Site_ProductService_InventoryStock__c;}else{/*No access*/}                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SDLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}
                            if(MRP.BOM_Requirement_Cost__c != Null){
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = MRP.BOM_Requirement_Cost__c;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()){SDLI.Unit_Price__c = (MRP.Total_Amount_Required__c != Null && MRP.Total_Amount_Required__c > 0)? MRP.BOM_Requirement_Cost__c/MRP.Total_Amount_Required__c : 0;}else{/*No access*/}
                            }
                            if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && MRPS.Lot_Serial == SILI.ERP7__Serial__r.ERP7__Serial_Number__c){
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                stock2insert = stock2insert - SDLI.Quantity__c;  if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SDLI.ERP7__Serial__c = SILI.ERP7__Serial__c;}else{/*No access*/}
                                SOLIS2Upsert.add(SDLI);
                            }
                            else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true && MRPS.Lot_Serial == SILI.ERP7__Material_Batch_Lot__r.Name)){
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                stock2insert = stock2insert - SDLI.Quantity__c; if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SDLI.ERP7__Material_Batch_Lot__c = SILI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}
                                SOLIS2Upsert.add(SDLI);
                            }
                            else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = (SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c >= stock2insert)? stock2insert : SILI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                stock2insert = stock2insert - SDLI.Quantity__c;
                                SOLIS2Upsert.add(SDLI);
                            }
                        }
                    }

                    for(ERP7__Stock_Outward_Line_Item__c SOLI : Outwards){
                        if(MRPS.MRP.Id == SOLI.ERP7__MRP_Material_Requirements_Planning__c && stock2insert > 0 && MRPS.MRP.ERP7__MRP_Product__c == SOLI.ERP7__Product__c && SOLI.ERP7__Status__c != 'Committed'){
                            ERP7__MRP__c MRP = MRPS.MRP;
                            if(stock2Scrap > 0){

                                Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c();
                                SDLI.ERP7__MO_WO_Serial__c = SOLI.ERP7__MO_WO_Serial__c;
                                SDLI.ERP7__MO_WO_Material_Batch_Lot__c = SOLI.ERP7__MO_WO_Material_Batch_Lot__c;
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Name.isUpdateable()){SDLI.Name = MRP.Name;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Scrap__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Scrap__c.isUpdateable()){SDLI.ERP7__Scrap__c = true;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Active__c.isUpdateable()){SDLI.ERP7__Active__c = true;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Process__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Process__c.isUpdateable()){SDLI.ERP7__Process__c = MRP.Process__c;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Schedule__c.isUpdateable()){SDLI.Schedule__c = MRP.Schedule__c;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__MRP_Material_Requirements_Planning__c.isUpdateable()){SDLI.ERP7__MRP_Material_Requirements_Planning__c = MRP.Id;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__BoM__c.isUpdateable()){SDLI.ERP7__BoM__c = MRP.ERP7__BOM__c;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Status__c.isUpdateable()){
                                    SDLI.ERP7__Status__c = 'Committed';
                                }else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){SDLI.ERP7__Product__c = MRP.ERP7__MRP_Product__c;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Site_Product_Service_Inventory_Stock__c.isCreateable()){SDLI.ERP7__Site_Product_Service_Inventory_Stock__c = SOLI.ERP7__Site_Product_Service_Inventory_Stock__c;}else{/*No access*/}
                                if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){SDLI.ERP7__Manufacturing_Order__c = MRP.ERP7__MO__c;}else{/*No access*/}
                                if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c == 'Committed'){ Continue; }
                                if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c == true && SOLI.ERP7__Status__c != 'Committed'){// && MRPS.Lot_Serial == SOLI.ERP7__Serial__r.ERP7__Serial_Number__c
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){
                                        SDLI.Quantity__c = SOLI.Quantity__c;
                                    }else{/*No access*/}//(SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= 1)?

                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Serial__c.isUpdateable()){SDLI.ERP7__Serial__c = SOLI.ERP7__Serial__c;}else{/*No access*/}
                                    SDLI.Id = SOLI.Id;   stock2Scrap = stock2Scrap - SOLI.Quantity__c;

                                    //scrap inward.
                                        //1
                                    //scrap inward end.

                                }
                                else if((MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c == true)){// && MRPS.Lot_Serial == SOLI.ERP7__Material_Batch_Lot__r.Name
                                    System.debug('stock2Scrap : '+stock2Scrap);
                                    SDLI.Id = SOLI.Id;
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c =SOLI.Quantity__c;}// (SOLI.ERP7__MO_WO_Serial__c != null) ? 1 : stock2Scrap;} //(SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                    stock2Scrap = stock2Scrap - SDLI.Quantity__c;
                                    System.debug('SDLI.Quantity__c Lot : '+SDLI.Quantity__c);
                                    System.debug('SDLI.ERP7__Status__c Lot : '+SDLI.ERP7__Status__c);
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()){SDLI.ERP7__Material_Batch_Lot__c = SOLI.ERP7__Material_Batch_Lot__c;}else{/*No access*/}

                                    //scrap inward.
                                    //2
                                    //scrap inward end.

                                }
                                else if(MRP.ERP7__MRP_Product__r.ERP7__Serialise__c != true && MRP.ERP7__MRP_Product__r.ERP7__Lot_Tracked__c != true) {
                                    SDLI.Id = SOLI.Id;
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Quantity__c.isUpdateable()){SDLI.Quantity__c = SOLI.Quantity__c;}//(SOLI.ERP7__MO_WO_Serial__c != null) ? 1 : stock2Scrap; }//(SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Scrap)? stock2Scrap : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;}else{/*No access*/}
                                    stock2Scrap = stock2Scrap - SDLI.Quantity__c;
                                    System.debug('SDLI.Quantity__c Normal : '+SDLI.Quantity__c);
                                    System.debug('SDLI.ERP7__Status__c Normal : '+SDLI.ERP7__Status__c);
                                    //scrap inward.
                                    //3
                                    //scrap inward end.
                                }
                                system.debug('MRP.BOM_Requirement_Cost__c : '+MRP.BOM_Requirement_Cost__c);
                                if(MRP.BOM_Requirement_Cost__c != Null){
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Unit_Price__c.isUpdateable()){SDLI.Unit_Price__c = (MRP.Total_Amount_Required__c != Null && MRP.Total_Amount_Required__c > 0)? MRP.BOM_Requirement_Cost__c/MRP.Total_Amount_Required__c : 0;}else{/*No access*/}
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){SDLI.Total_Amount__c = SDLI.Unit_Price__c*SDLI.ERP7__Quantity__c;}else{/*No access*/}
                                }
                                SOLIS2Upsert.add(SDLI);

                            }

                            if (stock2Consume > 0){
                                system.debug('stock2Consume : '+stock2Consume);
                                Stock_Outward_Line_Item__c SDLI = new Stock_Outward_Line_Item__c(Id = SOLI.Id);
                                SDLI.ERP7__Status__c = 'Committed';

                                //SDLI.ERP7__Quantity__c = (SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c >= stock2Consume)? stock2Consume : SOLI.Site_Product_Service_Inventory_Stock__r.ERP7__Number_of_Item_In_Stock__c;

                                system.debug(' SDLI.ERP7__Quantity__c Non serials: '+SDLI.ERP7__Quantity__c);
                                if(SOLI.ERP7__Status__c == 'Reserved'){ //ERP7__Manufacturing_Order__r //SOLI.ERP7__Product__r.ERP7__Serialise__c &&
                                    SDLI.ERP7__Quantity__c = SOLI.ERP7__Quantity__c;
                                }

                                system.debug(' SDLI.ERP7__Quantity__c serials: '+SDLI.ERP7__Quantity__c);
                                stock2Consume = stock2Consume - SDLI.ERP7__Quantity__c;

                                if(MRP.BOM_Requirement_Cost__c != Null){
                                    if(Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isCreateable() && Schema.sObjectType.Stock_Outward_Line_Item__c.fields.Total_Amount__c.isUpdateable()){
                                        SDLI.Total_Amount__c = SOLI.Unit_Price__c*SDLI.ERP7__Quantity__c;
                                    }else{/*No access*/}
                                }
                                SOLIS2Upsert.add(SDLI);
                            }
                        }
                    }

                }
            }
            system.debug('SOLIS2Upsert : '+SOLIS2Upsert.size());
            comW.SelectedTask = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE Id = :tId Order By ERP7__Operation__r.ERP7__Sort__c ASC');
            if(Schema.sObjectType.ERP7__WO__c.isUpdateable()){PreventRecursiveLedgerEntry.PreventWOLogistic = true; update WO;} else {/*No access*/}
            comW.WorkOrder = WO;
            if(Schema.sObjectType.ERP7__Actions_Tasks__c.isUpdateable()){update comW.SelectedTask;} else {/*No access*/}
            if(mrps2Update.size() > 0){
                // For loop added on 10/4/2023 to change the status to committed
                for(ERP7__MRP__c mrp : mrps2Update){
                    if((mrp.ERP7__Consumed_Quantity__c + mrp.ERP7__Scrapped_Quantity__c) == mrp.ERP7__Total_Amount_Required__c) mrp.ERP7__Status__c = 'Committed';
                }
                if(Schema.SObjectType.ERP7__MRP__c.isUpdateable()){ PreventRecursiveLedgerEntry.MRPFlowTrigger = false; /* PreventRecursiveLedgerEntry.MRPFlowTrigger Added by shaguftha on 21_02_24 */ update mrps2Update; } else {/*No access*/}
                mrps2Update = new List<ERP7__MRP__c>();
            }
            set<Id> scrapOutwards = new set<Id>();
            if(SOLIS2Upsert.size() > 0){

                for(Stock_Outward_Line_Item__c soli : SOLIS2Upsert){
                    if(!SOLI2UpsertMap.containsKey(soli.Id)){
                        SOLI2UpsertMap.put(soli.Id,soli);
                    }
                    if(soli.Id != null && soli.ERP7__Scrap__c == true){
                        scrapOutwards.add(soli.Id);
                    }
                }
                SOLIS2Upsert = new List<Stock_Outward_Line_Item__c>();
                system.debug('SOLI2UpsertMap : '+SOLI2UpsertMap.size());
                if(Schema.SObjectType.Stock_Outward_Line_Item__c.isCreateable() && Schema.SObjectType.Stock_Outward_Line_Item__c.isUpdateable()){ upsert SOLI2UpsertMap.values(); } else {/*No access*/}


                SOLI2UpsertMap = new Map<Id,ERP7__Stock_Outward_Line_Item__c>();
            }

          // if(Stocks.size() > 0){
             //   if(Schema.sObjectType.ERP7__Inventory_Stock__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.isUpdateable()){ upsert Stocks; }else {}
          //  }

            //system.debug('StockInwardMap.KeySet() : '+StockInwardMap.KeySet());
            //List<ERP7__Stock_Inward_Line_Item__c> sinward2update = new List<ERP7__Stock_Inward_Line_Item__c>();
          //  for(Id pliId : StockInwardMap.KeySet()){
            //    StockInwardMap.get(pliId).ERP7__Site_ProductService_InventoryStock__c= StockInMap.get(pliId).Id;
           // }

           /* for(ERP7__Stock_Inward_Line_Item__c inward :SPLIs){
                String StockId = '', SerialId = '', BatchId = '';
                if(StockInwardMap.ContainsKey(inward)) {
                    StockId = StockInwardMap.get(inward).Id;
                    system.debug('StockId : '+StockId);
                    inward.ERP7__Site_ProductService_InventoryStock__c = StockId;
                }
                if(inward.ERP7__Site_ProductService_InventoryStock__c != null) sinward2update.add(inward);
            }
            */
           // if(SPLIs.size() > 0) {
            //    if(Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Inward_Line_Item__c.isUpdateable()){ upsert SPLIs; } else {/*No access*/ }
            //}
           // Stocks = new List<ERP7__Inventory_Stock__c>();
           // sinward2update = new List<ERP7__Stock_Inward_Line_Item__c>();
            if(Task.ERP7__Status__c == 'Completed'){
                List<ERP7__Time_Card_Entry__c> TCES = [Select Id, Name, ERP7__End_Time__c From ERP7__Time_Card_Entry__c Where ERP7__Action_Task__c =: Task.Id And ERP7__Active__c = true And ERP7__End_Time__c = Null];
                for(ERP7__Time_Card_Entry__c TCE : TCES){ if(Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.fields.ERP7__End_Time__c.isUpdateable()){TCE.ERP7__End_Time__c = Task.ERP7__Actual_End_Time__c;}else{/*No access*/} }
                if(TCES.size() > 0) { if(Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable()){ upsert TCES;}else{/*No access*/}}
            }

            String TSEFields = UtilClass.selectStarFromSObject('ERP7__Time_Card_Entry__c');
            String AllTSEFields = TSEFields + ', ERP7__Timesheet__r.ERP7__Work_Order__c, ERP7__Timesheet__r.ERP7__Employees__r.Name, ERP7__Action_Task__r.ERP7__Auto_Clock_In__c ';

            comW.TimeCardEntries = Database.query('SELECT '+String.escapeSingleQuotes(AllTSEFields)+' FROM ERP7__Time_Card_Entry__c WHERE ERP7__Timesheet__r.ERP7__Work_Order__c = :WOId Order BY CreatedDate DESC');

            comW.Tasks = Database.query('SELECT '+String.escapeSingleQuotes(AllTaskFields)+' FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c = :WOId Order By ERP7__Operation__r.ERP7__Sort__c ASC');

            List<ERP7__MRP__c> MRPs = [Select Id, Name, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__BOM__r.ERP7__Unit_of_Measure__c, ERP7__BOM__r.Name, ERP7__BOM__r.ERP7__BOM_Version__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, Sales_Order_Line_Item__c, RecordType.Name, ERP7__Work_Order__c, ERP7__Work_Order__r.Name, ERP7__Notes__c, ERP7__MRP_Product__r.ERP7__Serialise__c, ERP7__MRP_Product__r.ERP7__Lot_Tracked__c, ERP7__MRP_Product__r.ERP7__Scrap_Variant__c,
                                       ERP7__Work_Order_Line_Items__c, ERP7__MO__c, ERP7__MO__r.ERP7__Version__c, ERP7__Fulfilled_Amount__c, ERP7__BOM__r.ERP7__Is_Protected__c, ERP7__MO__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Consumed_Quantity__c, ERP7__Scrapped_Quantity__c, ERP7__MRP_Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__Status__c, ERP7__Work_Order__r.ERP7__Raw_Materials_Site__c, ERP7__Expected_Quantity__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                                       ERP7__BOM__r.ERP7__Exact_Quantity__c, ERP7__BOM__r.ERP7__Quantity__c, ERP7__BOM__r.ERP7__Minimum_Variance__c, ERP7__BOM__r.ERP7__Maximum_Variance__c,ERP7__Work_Order__r.ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__BOM__r.ERP7__Sort__c, ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c, ERP7__MRP_Product__r.QuantityUnitOfMeasure, ERP7__BOM__r.ERP7__Product_Feature__r.Name, ERP7__BOM__r.ERP7__Product_Feature__c
                                       From ERP7__MRP__c
                                       Where ERP7__Work_Order__c = :woId Order By ERP7__BOM__r.ERP7__Sort__c ASC];
            List<mrpWrapBW> mrpWrapList = new List<mrpWrapBW>();
            for(Integer i=0; i<MRPs.size(); i++){
                ERP7__MRP__c MRP = MRPs[i];
                mrpWrapBW mrpWraper = new mrpWrapBW();

                if((i == 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null) || (i > 0 && MRP.ERP7__BOM__r.ERP7__Product_Feature__c != MRPs[i-1].ERP7__BOM__r.ERP7__Product_Feature__c)){
                    if(MRP.ERP7__BOM__r.ERP7__Product_Feature__c != Null){
                        mrpWraper.Feature.Id = MRP.ERP7__BOM__r.ERP7__Product_Feature__c;
                        mrpWraper.Feature.Name = MRP.ERP7__BOM__r.ERP7__Product_Feature__r.Name;
                    }
                }

                mrpWraper.MRP = MRP;
                if(MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c != Null) {
                    mrpWraper.SelectedUOM = MRP.ERP7__BOM__r.ERP7__Unit_of_Measure__c;
                    mrpWraper.UOMS.add(new SelectOptions(mrpWraper.SelectedUOM, mrpWraper.SelectedUOM, true));
                    if(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure != mrpWraper.SelectedUOM) mrpWraper.UOMS.add(new SelectOptions(MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure, MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure));
                }

                if(MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c != null){
                    String UOMS = MRP.ERP7__MRP_Product__r.ERP7__Alternate_Quantity_Unit_Of_Measure__c;
                    List<String> arr = UOMS.split(';');
                    for(String str : arr){
                        if(str != mrpWraper.SelectedUOM && str != MRP.ERP7__MRP_Product__r.QuantityUnitOfMeasure) mrpWraper.UOMS.add(new SelectOptions(str, str));
                    }
                }
                mrpWrapList.add(mrpWraper);
            }
            comW.MRPSSBW = mrpWrapList;
            mrpWrapList = new List<mrpWrapBW>();
            system.debug('scrapOutwards : '+scrapOutwards.size());
            if(scrapOutwards.size() > 0) MaintainBatchStocks.createScrapStocks(scrapOutwards);
        }

        catch(Exception e) {
            Database.rollback(sp);
            if(e.getMessage().contains('UNABLE_TO_LOCK_ROW')) comW.errorMsg = 'Please refresh and try! the record you are trying to access is also updated by other user.';
            else comW.errorMsg = e.getMessage() +' Line Number 31@ : '+ e.getLineNumber();
            system.debug('comW.errorMsg : '+comW.errorMsg);
        }
        return comW;
    }

    @AuraEnabled
    public static String getstockAllocatedDetails(String RecId){
        if(RecId != null && RecId != ''){
            List<ERP7__MRP__c> MRPs  = [Select Id,Name from ERP7__MRP__c where ERP7__Work_Order__c =: RecId];
            List<ERP7__Stock_Outward_Line_Item__c> outwards = [Select Id,Name,ERP7__Quantity__c,ERP7__MO_WO_Serial__c from ERP7__Stock_Outward_Line_Item__c where ERP7__MRP_Material_Requirements_Planning__c In :MRPs and ERP7__Work_Orders__c=:RecId ];
            set<Id> MOStockAllocatedSerial = new set<Id>();
            for(ERP7__Stock_Outward_Line_Item__c stk : outwards){
                if(stk.ERP7__MO_WO_Serial__c != null) MOStockAllocatedSerial.add(stk.ERP7__MO_WO_Serial__c);
            }
            if(MOStockAllocatedSerial.size() > 0) return JSON.serialize(MOStockAllocatedSerial);
            else return null;
        }else return null;

    }
    @AuraEnabled
    public static List<ERP7__Stock_Outward_Line_Item__c> getMRPDetails(String MRP,String Mo){
        List<ERP7__Stock_Outward_Line_Item__c> stk = new List<ERP7__Stock_Outward_Line_Item__c>();
        stk = [Select Id, Name, ERP7__Active__c, ERP7__Batch_Lot_Code__c, ERP7__BoM__c, ERP7__Process__c, ERP7__Schedule__c, ERP7__MRP_Material_Requirements_Planning__c, ERP7__Version__c, ERP7__Serial__c, ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Date_of_Manufacture__c,  ERP7__MO_WO_Serial__c, ERP7__MO_WO_Serial__r.Name, ERP7__MO_WO_Material_Batch_Lot__c, ERP7__MO_WO_Material_Batch_Lot__r.Name,
               ERP7__Product__c, ERP7__Purchase_Orders__c, ERP7__Quantity__c, ERP7__Site_Product_Service_Inventory_Stock__c, ERP7__Status__c, ERP7__Tax__c, ERP7__Total_Amount__c, ERP7__Unit_Price__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name
               From ERP7__Stock_Outward_Line_Item__c Where ERP7__MRP_Material_Requirements_Planning__c =: MRP AND ERP7__MRP_Material_Requirements_Planning__c != null];
        return stk;

    }
     @AuraEnabled
    public static wipWOWrap saveWIPs (String WIP,String WoId){
       wipWOWrap wipWo = new wipWOWrap();
        if(WIP != null && WIP != ''){
            ERP7__WIP_Flow__c wip2Update = (ERP7__WIP_Flow__c) JSON.deserialize(WIP, ERP7__WIP_Flow__c.class);
            update wip2Update;
            wipWo.wip = wip2Update;
            if(WoId != null && WoId != ''){
                List<AggregateResult> wipResults = [SELECT ERP7__Work_Orders__c,  SUM(ERP7__Quantity_Scrapped__c) sumQuantityScrapped,     SUM(ERP7__Quantity__c) sumQuantity FROM ERP7__WIP_Flow__c  WHERE ERP7__Work_Orders__c = :WoId  GROUP BY ERP7__Work_Orders__c];
                ERP7__WO__c wo2Update = new ERP7__WO__c();
                for (AggregateResult ar : wipResults) {
                    String workOrder = (String) ar.get('ERP7__Work_Orders__c');
                    wo2Update.Id = workOrder;
                    Decimal sumQuantityScrapped = (Decimal) ar.get('sumQuantityScrapped');
                    wo2Update.ERP7__Quantity_Scrapped__c =  sumQuantityScrapped;
                    Decimal sumQuantity = (Decimal) ar.get('sumQuantity');
                    wo2Update.ERP7__Quantity_Built__c = sumQuantity;
                    // Process the aggregated results as needed
                }
                system.debug('wo2Update : '+wo2Update);
                if(wo2Update.Id != null)
                {
                    update wo2Update;
                    wipWo.wo = wo2Update;
                }


            }
            return wipWo;
        }
        else return null;

    }
    public class wipWOWrap{
        @AuraEnabled public ERP7__WIP_Flow__c wip {get;set;}
         @AuraEnabled public ERP7__WO__c wo {get;set;}
    }
     @AuraEnabled
    public static void deleteSerial(String RecId){
        ERP7__Serial_Number__c ser = [Select Id,Name from ERP7__Serial_Number__c where Id=:RecId limit 1];
        if(Schema.sObjectType.ERP7__Serial_Number__c.isDeletable())delete ser;
    }
       @AuraEnabled
    public static comWrap SaveSerial(String SerialNumber, String MO){
        ERP7__Manufacturing_Order__c MOs = (ERP7__Manufacturing_Order__c) JSON.deserialize(MO, ERP7__Manufacturing_Order__c .class);
        ERP7__Serial_Number__c SlNumber = (ERP7__Serial_Number__c) JSON.deserialize(SerialNumber, ERP7__Serial_Number__c .class);
        comWrap comW = new comWrap();
        try{
            // if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isUpdateable()){
            SlNumber.ERP7__Warehouse__c = MOs.ERP7__Routing__r.ERP7__Finished_Products_Site__c;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Product__c.isUpdateable()){
            SlNumber.ERP7__Product__c = MOs.ERP7__Product__c;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Production_Version__c.isUpdateable()){
            SlNumber.ERP7__Production_Version__c = MOs.ERP7__Version__c;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Manufacturing_Order__c.isUpdateable()){
            SlNumber.ERP7__Manufacturing_Order__c = MOs.Id;//}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Serial_Number__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.isUpdateable()){
            upsert SlNumber;//}else{ comW.errorMsg='not allowed to upsert';}
            comW.manuOrders = MOs;
            comW.errorMsg = '';
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number 32@ : '+ e.getLineNumber(); }
        return comW;
    }
       @AuraEnabled
    public static String setSerials2(String MOId,String serialsList){
        try{system.debug('Inside');
            List<ERP7__Serial_Number__c> serials = (List<ERP7__Serial_Number__c>) JSON.deserialize(serialsList,List<ERP7__Serial_Number__c>.class);
            if (serials.size() > 0) {
                List<ERP7__Serial_Number__c> failedRecords = new List<ERP7__Serial_Number__c>();
                List<Database.SaveResult> updateResults = Database.update(serials, false);
                Integer counter = 0;
                for (Integer i = 0; i < updateResults.size(); i++) {
                    if (!updateResults.get(i).isSuccess()) {
                        // DML operation failed
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        failedRecords.add(serials.get(i)); // failed record from the list
                        System.debug('Failed ID' + updateResults.get(i).Id+ 'error : '+error);
                    }
                }
                if (failedRecords.isEmpty()) {
                    return 'Success';
                }
                else{
                    String failedRecordsMessage = 'Failed to generate the following serial numbers: ';

                    for (ERP7__Serial_Number__c failedRecord : failedRecords) {
                       // system.debug('failedRecord : '+failedRecord);
                        failedRecordsMessage +=  failedRecord.Name + ', ';
                    }
                    failedRecordsMessage += 'as the serial number already exists/Product code doesn\'t Match ';
                    return failedRecordsMessage;
                }
            }
            return null;
        } catch (Exception e) {
            if (e.getMessage().contains('Duplicate') || e.getMessage().contains('duplicate')) {
                return 'Duplicate serial numbers found. Please change the serial start number.';
            } else {
                return 'Error: ' + e.getMessage();
            }
        }
    }

}