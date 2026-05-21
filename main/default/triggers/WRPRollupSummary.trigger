trigger WRPRollupSummary on Resource_Allocation__c (after insert, after update, after delete, after undelete) {
    
    if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {
        list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Cost__c', 'ERP7__Direct_Labour__c')
        };
        list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions2 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Cost__c', 'ERP7__Overhead__c')
        };
        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.new, 'ERP7__Resource_Allocation__c','ERP7__Schedule__c', 'ERP7__Schedule__c', ' And ERP7__Employees__c != Null');
        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions2, trigger.new, 'ERP7__Resource_Allocation__c','ERP7__Schedule__c', 'ERP7__Schedule__c', 'And ERP7__Machine__c != Null');
        
       
    }
    
    if(trigger.isDelete){
        list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Cost__c', 'ERP7__Direct_Labour__c')
        };
        list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions2 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Cost__c', 'ERP7__Overhead__c')
        };
        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.Old, 'ERP7__Resource_Allocation__c','ERP7__Schedule__c', 'ERP7__Schedule__c', ' And ERP7__Employees__c != Null');
        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions2, trigger.Old, 'ERP7__Resource_Allocation__c','ERP7__Schedule__c', 'ERP7__Schedule__c', ' And ERP7__Machine__c != Null');
    }
    
     if(!Trigger.isDelete){
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isUndelete)){
            try{
            Map<Id, ERP7__Capacity__c> regCapacity = new Map<Id, ERP7__Capacity__c>();
            Map<Id, ERP7__Demand__c> regDemand = new Map<Id, ERP7__Demand__c>();
            List< ERP7__Demand__c > Demands2upsert = new List< ERP7__Demand__c >();
            List< ERP7__Capacity__c > Capacities2upsert = new List< ERP7__Capacity__c >();
            Set<Date> dates = new Set<Date>();
            Set<Id> resIds = new Set<Id>();
            
            for(Resource_Allocation__c Reg : Trigger.New){
                if(Reg.ERP7__Resource__c != Null){// && Reg.ERP7__Appointment_DateDt__c != Null
                    resIds.add(Reg.ERP7__Resource__c);
                    if(Reg.ERP7__Start_Date__c!=null){
                        Date dd=date.newinstance(Reg.ERP7__Start_Date__c.year(), Reg.ERP7__Start_Date__c.month(), Reg.ERP7__Start_Date__c.day());
                        dates.add(dd);
                    }
                    //dates.add(Reg.ERP7__Appointment_DateDt__c);
                }
            }
            if(resIds.size() > 0){
                List< ERP7__Capacity__c > Capacities = [Select Id, Name, ERP7__User__c, ERP7__Resource__c, ERP7__Date__c, ERP7__Capacity_Hrs__c,ERP7__Demand_Hrs__c
                                                             From ERP7__Capacity__c
                                                             Where ERP7__Resource__c In : resIds And
                                                             ERP7__Resource__c != Null And
                                                             ERP7__Date__c In : dates
                                                             Order by CreatedDate ASC];
                          if(Capacities.size() > 0){                        List< ERP7__Demand__c > Demands = [Select Id, Name, ERP7__User__c, ERP7__Product__c,  ERP7__Resource_Allocation__c, ERP7__Capacity__c, ERP7__Demand_Capacity_Hrs__c, ERP7__Start_Date_Time__c, ERP7__End_Date_Time__c, ERP7__Resource__c From ERP7__Demand__c Where ERP7__Resource_Allocation__c In : Trigger.newMap.keySet() And ERP7__Capacity__c != Null Order by CreatedDate ASC];                     for(ERP7__Demand__c Demand : Demands) if(!regDemand.containsKey(Demand.ERP7__Resource_Allocation__c)) regDemand.put(Demand.ERP7__Resource_Allocation__c, Demand);                                        for(ERP7__Resource_Allocation__c Reg : Trigger.New){                         if(Reg.ERP7__Product__c != Null){                            for(ERP7__Capacity__c Capacity : Capacities){                                if(Reg.ERP7__Resource__c == Capacity.ERP7__Resource__c){                                    if(!regCapacity.containsKey(Reg.Id)) regCapacity.put(Reg.Id, Capacity);                                }                            }                        }                    }                   for (ERP7__Resource_Allocation__c Reg: Trigger.New) {                        if (regCapacity.containsKey(Reg.Id)) {                           ERP7__Demand__c demand = new ERP7__Demand__c();                            if (regDemand.containsKey(Reg.Id)) demand = regDemand.get(Reg.Id);                           if(Schema.sObjectType.ERP7__Demand__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.Name.isUpdateable()){ demand.Name = Reg.Name; } else{/* no access*/}                           if (Reg.ERP7__User__c != Null && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__User__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__User__c.isUpdateable()) {demand.ERP7__User__c = Reg.ERP7__User__c;} else{/* no access*/}                           if (Reg.ERP7__Product__c != Null && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Product__c.isUpdateable()) {demand.ERP7__Product__c = Reg.ERP7__Product__c;  } else{/* no access*/}                           if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource_Allocation__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource_Allocation__c.isUpdateable()){demand.ERP7__Resource_Allocation__c = Reg.Id; } else{/* no access*/}                           if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource__c.isUpdateable()){demand.ERP7__Resource__c = Reg.ERP7__Resource__c; } else{/* no access*/}                           if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Capacity__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Capacity__c.isUpdateable()){demand.ERP7__Capacity__c = regCapacity.get(Reg.Id).Id; } else{/* no access*/}                           if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isUpdateable()){demand.ERP7__Demand_Capacity_Hrs__c = (Reg.ERP7__End_Date__c.getTime() - Reg.ERP7__Start_Date__c.getTime()) / (1000 * 60);} else{/* no access*/}                           if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isUpdateable()){demand.ERP7__Demand_Capacity_Hrs__c = demand.ERP7__Demand_Capacity_Hrs__c / 60; } else{/* no access*/}                           if (Reg.ERP7__Start_Date__c != Null && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Start_Date_Time__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Start_Date_Time__c.isUpdateable()) {demand.ERP7__Start_Date_Time__c = Reg.ERP7__Start_Date__c; } else{/* no access*/}                           if (Reg.ERP7__End_Date__c != Null  && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__End_Date_Time__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__End_Date_Time__c.isUpdateable()) {demand.ERP7__End_Date_Time__c = Reg.ERP7__End_Date__c;} else{/* no access*/}                           ERP7__Capacity__c cp=((regCapacity.get(Reg.Id) != null) ? regCapacity.get(Reg.Id) : null);                           if(cp!=null && Schema.sObjectType.ERP7__Capacity__c.fields.ERP7__Demand_Hrs__c.isCreateable() && Schema.sObjectType.ERP7__Capacity__c.fields.ERP7__Demand_Hrs__c.isUpdateable()){ cp.ERP7__Demand_Hrs__c=demand.ERP7__Demand_Capacity_Hrs__c;} else{/* no access*/}                           Capacities2upsert.add(cp);                           Demands2upsert.add(demand);                     }                 }                    if(Demands2upsert.size() > 0 && Schema.sObjectType.ERP7__Demand__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.isUpdateable()) { upsert Demands2upsert; } else { /* no access */ }                    if(Capacities2upsert.size() > 0 && Schema.sObjectType.ERP7__Capacity__c.isCreateable() && Schema.sObjectType.ERP7__Capacity__c.isUpdateable()) { upsert Capacities2upsert;} else { /* no access */ }                }          
            }
            
                if(Trigger.isUpdate){ List< ERP7__Demand__c > Demands2delete = [Select Id, Name From ERP7__Demand__c Where ERP7__Resource_Allocation__c In : Trigger.newMap.keySet() And Id Not In : Demands2upsert]; if(Demands2delete.size() > 0 && ERP7__Demand__c.sObjectType.getDescribe().isDeletable()) { delete Demands2delete; } else{ /* no access */}
            }
            }catch(Exception e){
               /*'Exception WRPRollupSummary-->'+e+'Line Number'+e.getLineNumber()*/
            }
        }
    }
  
    if(trigger.isDelete){ List< ERP7__Demand__c > Demands2delete = [Select Id, Name From ERP7__Demand__c Where ERP7__Resource_Allocation__c In : Trigger.oldMap.keySet()];if(Demands2delete.size() > 0 &&ERP7__Demand__c.sObjectType.getDescribe().isDeletable()){ delete Demands2delete; } else{ /* no access */ }
  }
  
}