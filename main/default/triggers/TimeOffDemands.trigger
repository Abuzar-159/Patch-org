/*
    Trigger to to create demands against the respective capacities.
*/

trigger TimeOffDemands on ERP7__Time_Off__c (after insert, after update, after undelete) {//, before delete, 
    // Manage demands 
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate || trigger.isUndelete)){
        Map<Id, List<ERP7__Capacity__c>> timeOffCapacities = new Map<Id, List<ERP7__Capacity__c>>();
        Map<Id, List<ERP7__Demand__c>> timeOffDemands = new Map<Id, List<ERP7__Demand__c>>();
        List< ERP7__Capacity__c > capacities2Upsert = new List< ERP7__Capacity__c>();
        //Set< ERP7__Demand__c > Demands2upsert = new Set< ERP7__Demand__c >();
        Map<Id, ERP7__Demand__c> capDemand = new Map<Id, ERP7__Demand__c>();
        Map<ERP7__Demand__c,ERP7__Demand__c> Demands2upsertMap = new Map<ERP7__Demand__c,ERP7__Demand__c>();
        Set<Id> userIds = new Set<Id>();
        Date startDate, endDate;
        
        for(ERP7__Time_Off__c timeOff : Trigger.New){
            if(timeOff.ERP7__Start_Date__c != Null && timeOff.ERP7__End_Date__c != Null && timeOff.ERP7__User__c != Null){
                userIds.add(timeOff.ERP7__User__c);
                if(startDate == Null || timeOff.ERP7__Start_Date__c < startDate) startDate = timeOff.ERP7__Start_Date__c;
                if(endDate == Null || timeOff.ERP7__End_Date__c < endDate) endDate = timeOff.ERP7__End_Date__c;
                timeOffDemands.put(timeOff.Id, new List<ERP7__Demand__c>());
                timeOffCapacities.put(timeOff.Id, new List<ERP7__Capacity__c>());
            }
        }
        if(userIds.size() > 0){
            List< ERP7__Capacity__c > Capacities = [Select Id, Name, ERP7__User__c, ERP7__Product__c, ERP7__Date__c, ERP7__Capacity_Hrs__c, ERP7__Resource__c
                                                         From ERP7__Capacity__c
                                                         Where ERP7__User__c In : userIds And
                                                         ERP7__Date__c >= : startDate And 
                                                         ERP7__Date__c <= : endDate
                                                         Order by CreatedDate ASC];                                       
            if(Capacities.size() > 0){   
                List< ERP7__Demand__c > Demands = [Select Id, Name, ERP7__User__c, ERP7__Product__c, ERP7__Resource_Allocation__c, ERP7__Time_Off__c, ERP7__Capacity__c, ERP7__Demand_Capacity_Hrs__c
                                                        From ERP7__Demand__c
                                                        Where ERP7__Time_Off__c In : Trigger.newMap.keySet() And 
                                                        ERP7__Capacity__c != Null 
                                                        Order by CreatedDate ASC];
                for(ERP7__Demand__c Demand : Demands) {
                    if(!capDemand.containsKey(Demand.ERP7__Capacity__c)) capDemand.put(Demand.ERP7__Capacity__c, Demand);
                    timeOffDemands.get(Demand.ERP7__Time_Off__c).add(Demand);
                }
                
                for(ERP7__Time_Off__c timeOff : Trigger.New){
                    if(timeOff.ERP7__Start_Date__c != Null && timeOff.ERP7__End_Date__c != Null && timeOff.ERP7__User__c != Null){
                        for(ERP7__Capacity__c Capacity : Capacities){
                            if(timeOff.ERP7__User__c == Capacity.ERP7__User__c && Capacity.ERP7__Date__c >= timeOff.ERP7__Start_Date__c && Capacity.ERP7__Date__c <= timeOff.ERP7__End_Date__c){
                                timeOffCapacities.get(timeOff.Id).add(Capacity);
                            }
                        }
                    }
                }
                
                for(ERP7__Time_Off__c timeOff : Trigger.New){
                    Time ST, ET;
                    if(timeOff.ERP7__Start_Time__c == Null) ST = Time.newInstance(0, 0, 0, 0);
                    else ST = timeOff.ERP7__Start_Time__c;
                    if(timeOff.ERP7__End_Time__c == Null) ET = Time.newInstance(23, 59, 0, 0);
                    else ET = timeOff.ERP7__End_Time__c;
                    
                    if(timeOffCapacities.containsKey(timeOff.Id) && timeOff.Id!=null){
                        for(ERP7__Capacity__c Capacity : timeOffCapacities.get(timeOff.Id)){
                            ERP7__Demand__c demand = new ERP7__Demand__c();
                            try{
                            if(capDemand.containsKey(Capacity.Id) && Capacity.Id!=null) demand = capDemand.get(Capacity.Id);
                            if(Schema.sObjectType.ERP7__Demand__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.Name.isUpdateable()) demand.Name = timeOff.Name;
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__User__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__User__c.isUpdateable()) if(timeOff.ERP7__User__c!=null) demand.ERP7__User__c = timeOff.ERP7__User__c;
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Time_Off__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Time_Off__c.isUpdateable()) if(timeOff.Id!=null) demand.ERP7__Time_Off__c = timeOff.Id;
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Capacity__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Capacity__c.isUpdateable()) if(Capacity.Id!=null) demand.ERP7__Capacity__c = Capacity.Id;
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Resource__c.isUpdateable()) if(Capacity.ERP7__Resource__c!=null) demand.ERP7__Resource__c = Capacity.ERP7__Resource__c;                             
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isUpdateable()) demand.ERP7__Demand_Capacity_Hrs__c = (DateTime.newInstance(Capacity.ERP7__Date__c, ET).getTime() - DateTime.newInstance(Capacity.ERP7__Date__c, ST).getTime())/(1000*60);
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isUpdateable()) demand.ERP7__Demand_Capacity_Hrs__c = demand.ERP7__Demand_Capacity_Hrs__c/60;
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Start_Date_Time__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Start_Date_Time__c.isUpdateable()) if(timeOff.ERP7__Start_Date__c != Null) demand.ERP7__Start_Date_Time__c = Datetime.newInstance(timeOff.ERP7__Start_Date__c, ST);
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__End_Date_Time__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__End_Date_Time__c.isUpdateable()) if(timeOff.ERP7__End_Date__c != Null) demand.ERP7__End_Date_Time__c = Datetime.newInstance(timeOff.ERP7__End_Date__c, ET);
                            if(Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.ERP7__Demand_Capacity_Hrs__c.isUpdateable()) if(demand.ERP7__Demand_Capacity_Hrs__c > capacity.ERP7__Capacity_Hrs__c) demand.ERP7__Demand_Capacity_Hrs__c = capacity.ERP7__Capacity_Hrs__c;
                            //Demands2upsert.add(demand);
                            Demands2upsertMap.put(demand,demand);
                            demand = new ERP7__Demand__c();
                            }catch(Exception exp){/*'TimeOffDemands exp if any=>'+exp.getMessage()*/}
                        }
                    }
                }
                try{
                if(Demands2upsertMap.size()>0){
                  Set< ERP7__Demand__c > Demands2upsert = new Set< ERP7__Demand__c >();   
                  Demands2upsert.addAll(Demands2upsertMap.KeySet());
                    if(Demands2upsert.size()>0 && Schema.sObjectType.ERP7__Demand__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Demand__c.fields.Name.isUpdateable())  { upsert new List<ERP7__Demand__c >(Demands2upsert); } else{ /* no access */ }
                }}catch(Exception exp){}
                
               
            }
        }
        
        if(Trigger.isUpdate){
            List< ERP7__Demand__c > Demands2delete = [Select Id, Name From ERP7__Demand__c Where ERP7__Time_Off__c In : Trigger.newMap.keySet() And Id Not In : Demands2upsertMap.KeySet()]; //Demands2upsert
            if(Demands2delete.size() > 0 && ERP7__Demand__c.sObjectType.getDescribe().isDeletable()) { delete Demands2delete; } else{ /* no access */}
        }
    }
    
    if(trigger.isBefore && trigger.isDelete){
        List< ERP7__Demand__c > Demands2delete = [Select Id, Name From ERP7__Demand__c Where ERP7__Time_Off__c In : Trigger.oldMap.keySet()];
        if(Demands2delete.size() > 0 && ERP7__Demand__c.sObjectType.getDescribe().isDeletable()) { delete Demands2delete; } else{ /* no access */}
    }
}