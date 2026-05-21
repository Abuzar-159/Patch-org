trigger Auto_Task_Actions_Creation on Schedule__c (After insert, before update) {
    
    Set<Id> processIds = new Set<Id>();
    Map<Id, List<Checklist__c>> processActions = new Map<Id, List<Checklist__c>>();
    Map<Id, List<BOM__c>> processBOMS = new Map<Id, List<BOM__c>>();
    List<Actions_Tasks__c > checklists = new List<Actions_Tasks__c>();
    List<MRP__c > MRPS = new List<MRP__c>();
    Set<Id> scheduleIds = new Set<Id>();
    List<Resource_Allocation__c> RAS = new List<Resource_Allocation__c>();
    if(Trigger.IsInsert){ 
        for(Schedule__c sch : System.Trigger.New) if(sch.Process__c != Null) processIds.add(sch.Process__c);
        
        List<Checklist__c> actionsTasks = [Select Id, Name, ERP7__Action_Detail__c, ERP7__Action_Type__c, ERP7__Duration__c, ERP7__Process__c, ERP7__Process_Cycle__c, ERP7__Product__c,
                                                 ERP7__Weight__c
                                                 From Checklist__c 
                                                 Where ERP7__Process__c In :processIds];
        
        
        List<BOM__c> BOMS = [Select Id, Name, Active__c, ERP7__Barcode__c, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__Code__c, ERP7__Cost_Card__c, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__BOM_Component__c, 
                                ERP7__Manufacturing_Assembly_Process__c, ERP7__Phase__c,ERP7__Process_Cycle__c, ERP7__Procurement_Type__c, ERP7__BOM_Product__c,ERP7__Quantity__c,  ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, ERP7__Requirement_Period_Start_Date__c, ERP7__Unit_of_Measure__c
                                From BOM__c
                                Where Active__c = true And
                                ERP7__Manufacturing_Assembly_Process__c In :processIds];
        
        for(Id pId : processIds){
            List<Checklist__c> ATL = new List<Checklist__c>();
            List<BOM__c> myBOM = new List<BOM__c>();
            
            for(Checklist__c AT : actionsTasks) if(pId == AT.ERP7__Process__c) ATL.add(AT);
            processActions.put(pId, ATL);
            
            for(Bom__c bom : BOMS) if(pId == bom.ERP7__Manufacturing_Assembly_Process__c) myBOM.add(bom);
            processBOMS.put(pId, myBOM);
        }
        
        for(Schedule__c sch : System.Trigger.New){
            if(sch.Process__c != Null){
                List<Checklist__c> myATL = processActions.get(sch.Process__c);
                for(Checklist__c myAT : myATL){    Actions_Tasks__c SC = new Actions_Tasks__c();  if(Schema.sObjectType.Actions_Tasks__c.fields.Name.isCreateable()){SC.Name = myAT.Name; }else{/*No access*/}  if(Schema.sObjectType.Actions_Tasks__c.fields.ERP7__Action_Detail__c.isCreateable()){SC.ERP7__Action_Detail__c = myAT.ERP7__Action_Detail__c; }else{/*No access*/}   if(Schema.sObjectType.Actions_Tasks__c.fields.ERP7__Action_Type__c.isCreateable()){SC.ERP7__Action_Type__c = myAT.ERP7__Action_Type__c; }else{/*No access*/}  if(Schema.sObjectType.Actions_Tasks__c.fields.ERP7__Schedule__c.isCreateable()){SC.ERP7__Schedule__c = sch.Id; }else{/*No access*/}  if(Schema.sObjectType.Actions_Tasks__c.fields.ERP7__Weight__c.isCreateable()){SC.ERP7__Weight__c = myAT.ERP7__Weight__c;}else{/*No access*/} checklists.add(SC);
                }
                
                List<BOM__c> myaBOMs = processBOMS.get(sch.Process__c);
                for(BOM__c bom : myaBOMs){ MRP__c mrp = new MRP__c();   if(Schema.sObjectType.MRP__c.fields.Name.isCreateable()){mrp.Name = bom.Name;  }else{/*No access*/}  if(Schema.sObjectType.MRP__c.fields.Process__c.isCreateable()){mrp.Process__c = bom.Manufacturing_Assembly_Process__c; }else{/*No access*/}  if(Schema.sObjectType.MRP__c.fields.MRP_Product__c.isCreateable()){mrp.MRP_Product__c = bom.BOM_Component__c; }else{/*No access*/}   if(Schema.sObjectType.MRP__c.fields.Notes__c.isCreateable()){mrp.Notes__c = bom.Description__c; }else{/*No access*/}  if(Schema.sObjectType.MRP__c.fields.Schedule__c.isCreateable()){mrp.Schedule__c = sch.Id; }else{/*No access*/}  if(Schema.sObjectType.MRP__c.fields.Process_Cycle__c.isCreateable()){mrp.Process_Cycle__c = bom.Process_Cycle__c; }else{/*No access*/}  if(Schema.sObjectType.MRP__c.fields.Total_Amount_Required__c.isCreateable()){mrp.Total_Amount_Required__c = bom.Quantity__c;  }else{/*No access*/}   MRPS.add(mrp);
                }
            }
        }
        
        if(checklists.size() > 0 && Schema.SObjectType.Actions_Tasks__c.isCreateable()){insert checklists;}else{/*Not allowed to insert*/}
        if(MRPS.size() > 0 && Schema.SObjectType.MRP__c.isCreateable()){ try { insert MRPS; } catch(exception ex){}}else{/*Not allowed to insert*/}
    }
    
    if(Trigger.IsUpdate){   for(Schedule__c sch : System.Trigger.New){ scheduleIds.add(sch.Id);
        }
        
        checklists = [Select Id, Name, ERP7__Action_Detail__c, ERP7__Action_Type__c, ERP7__Schedule__c, ERP7__Weight__c    From Actions_Tasks__c  Where ERP7__Schedule__c In :scheduleIds]; 
        
        RAS = [Select Id, Name, ERP7__Active__c, ERP7__Hours__c, ERP7__Employees__c, ERP7__Machine__c  From Resource_Allocation__c   Where ERP7__Schedule__c In :scheduleIds];
        
        for(Schedule__c sch : System.Trigger.New){  Decimal totalWeight = 0; Decimal emp = 0;  Decimal mach = 0;
            
            for(Actions_Tasks__c SC : checklists)  if(sch.Id == SC.ERP7__Schedule__c && SC.ERP7__Weight__c != Null) totalWeight += SC.ERP7__Weight__c;  if(totalWeight > 0)  sch.Progress__c = totalWeight;
                
            for(Resource_Allocation__c RA : RAS){ if(RA.ERP7__Hours__c != Null && RA.ERP7__Employees__c != Null) emp += RA.ERP7__Hours__c; if(RA.ERP7__Hours__c != Null && RA.ERP7__Machine__c != Null) mach += RA.ERP7__Hours__c;
            }
            if(sch.ERP7__Estimated_Workforce_Hour__c != Null)  sch.ERP7__Workforce_Allocation__c = (sch.ERP7__Estimated_Workforce_Hour__c != 0)? emp/sch.ERP7__Estimated_Workforce_Hour__c * 100 : 0;
            if(sch.ERP7__Estimated_Machine_Hour__c != Null)  sch.ERP7__Machine_Allocation__c = (sch.ERP7__Estimated_Machine_Hour__c != 0)? mach/sch.ERP7__Estimated_Machine_Hour__c * 100 : 0; sch.ERP7__Actual_Machine_Hour__c = mach;  sch.ERP7__Actual_Workforce_Hour__c = emp;
        }
    }
}