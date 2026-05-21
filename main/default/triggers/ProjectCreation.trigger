trigger ProjectCreation on ERP7__Project__c (after insert, after update) {
    
    Integer i=0;
    Date startD = system.today();
    Date endD = startD.addDays(1);
    if(trigger.isInsert){
        if(trigger.new[i].ERP7__Default_Routing__c != null){
            ERP7__Routing__c routing = [SELECT Id, ERP7__Process__c FROM ERP7__Routing__c WHERE Id =: trigger.new[i].ERP7__Default_Routing__c LIMIT 1];
            String newProcess = routing.ERP7__Process__c;
            List<ERP7__Process_Cycle__c> cycles = [SELECT Id, Name, ERP7__Process__c FROM ERP7__Process_Cycle__c WHERE ERP7__Process__c =: newProcess];
            if (newProcess != null && cycles.size() != null && cycles.size()>0){
                List<ERP7__Milestone__c> Milestones = new List<ERP7__Milestone__c>();
                Integer j =0;
                for(ERP7__Process_Cycle__c cycle : cycles){
                    ERP7__Milestone__c newMilestone = new ERP7__Milestone__c();   if(Schema.sObjectType.ERP7__Milestone__c.fields.Name.isCreateable()){newMilestone.Name = cycle.Name;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isCreateable()){newMilestone.ERP7__Start_Date__c = startD.addDays(j);}else{/*No access*/}    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isCreateable()){newMilestone.ERP7__Due_Date__c = endD.addDays(j);}else{/*No access*/}   if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Status__c.isCreateable()){newMilestone.ERP7__Status__c = 'Planned';}else{/*No access*/}   if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Project__c.isCreateable()){newMilestone.ERP7__Project__c = trigger.new[i].Id;}else{/*No access*/}
                    Milestones.add(newMilestone);
                    j = j+1;
                }
                if(Schema.sObjectType.ERP7__Milestone__c.isCreateable()){insert Milestones;}else{/* no access */}
            }
        }
    }
    
    if(trigger.isUpdate){
        if(trigger.old[i].ERP7__Default_Routing__c != null){
            if(trigger.new[i].ERP7__Default_Routing__c != trigger.old[i].ERP7__Default_Routing__c){
                //old
                ERP7__Routing__c routingOld = [SELECT Id, ERP7__Process__c FROM ERP7__Routing__c WHERE Id =: trigger.old[i].ERP7__Default_Routing__c ORDER BY CreatedDate Asc LIMIT 1];
                String oldProcess = routingOld.ERP7__Process__c;
                List<ERP7__Process_Cycle__c> Oldcycles = [SELECT Id, Name FROM ERP7__Process_Cycle__c WHERE ERP7__Process__c =: oldProcess ORDER BY CreatedDate Asc];
                
                List<ERP7__Milestone__c> OldMilestones = [SELECT Id, Name FROM ERP7__Milestone__c WHERE ERP7__Project__c =: trigger.new[i].Id];
                if(OldMilestones.size()>0 && ERP7__Milestone__c.sObjectType.getDescribe().isDeletable()) {  delete OldMilestones; } else{ /* no access */ }
                List<ERP7__Actions_Tasks__c> OldTasks = [SELECT Id,Name FROM ERP7__Actions_Tasks__c WHERE ERP7__Milestone__c IN: OldMilestones];
                if(OldTasks.size()>0 && ERP7__Actions_Tasks__c.sObjectType.getDescribe().isDeletable()){  delete OldTasks; } else { /* no access */ }
                
                if(trigger.new[i].ERP7__Default_Routing__c != null){
                    ERP7__Routing__c routing = [SELECT Id, ERP7__Process__c FROM ERP7__Routing__c WHERE Id =: trigger.new[i].ERP7__Default_Routing__c ORDER BY CreatedDate Asc LIMIT 1];
                    String newProcess = routing.ERP7__Process__c;
                    List<ERP7__Process_Cycle__c> cycles = [SELECT Id, Name, ERP7__Process__c FROM ERP7__Process_Cycle__c WHERE ERP7__Process__c =: newProcess ORDER BY CreatedDate Asc];
                    if (newProcess != null && cycles.size() != null && cycles.size()>0){
                        List<ERP7__Milestone__c> newMilestones = new List<ERP7__Milestone__c>();
                        Integer j =0;
                        for(ERP7__Process_Cycle__c cycle : cycles){
                            ERP7__Milestone__c newMilestonet = new ERP7__Milestone__c();  if(Schema.sObjectType.ERP7__Milestone__c.fields.Name.isCreateable()){newMilestonet.Name = cycle.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isCreateable()){newMilestonet.ERP7__Start_Date__c = startD.addDays(j);}else{/*No access*/}  if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isCreateable()){newMilestonet.ERP7__Due_Date__c = endD.addDays(j);}else{/*No access*/}   if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Status__c.isCreateable()){newMilestonet.ERP7__Status__c = 'Planned';}else{/*No access*/} if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Project__c.isCreateable()){newMilestonet.ERP7__Project__c = trigger.new[i].Id;}else{/*No access*/}
                            newMilestones.add(newMilestonet);
                            j = j+1;
                        }
                        if(Schema.sObjectType.ERP7__Milestone__c.isCreateable()) { insert newMilestones; } else{ /* no access */ }
                    }
                }
            }
        }
        else {
            if(trigger.new[i].ERP7__Default_Routing__c != null){
                ERP7__Routing__c routing = [SELECT Id, ERP7__Process__c FROM ERP7__Routing__c WHERE Id =: trigger.new[i].ERP7__Default_Routing__c LIMIT 1];
                String newProcess = routing.ERP7__Process__c;
                List<ERP7__Process_Cycle__c> cycles = [SELECT Id, Name, ERP7__Process__c FROM ERP7__Process_Cycle__c WHERE ERP7__Process__c =: newProcess];
                if (newProcess != null && cycles.size() != null && cycles.size()>0){
                    List<ERP7__Milestone__c> newMilestones = new List<ERP7__Milestone__c>();
                    Integer j =0;
                    for(ERP7__Process_Cycle__c cycle : cycles){
                        ERP7__Milestone__c newMilestonet = new ERP7__Milestone__c();  if(Schema.sObjectType.ERP7__Milestone__c.fields.Name.isCreateable()){newMilestonet.Name = cycle.Name;}else{/*No access*/} if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Start_Date__c.isCreateable()){newMilestonet.ERP7__Start_Date__c = startD.addDays(j);}else{/*No access*/}  if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Due_Date__c.isCreateable()){newMilestonet.ERP7__Due_Date__c = endD.addDays(j);}else{/*No access*/}   if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Status__c.isCreateable()){newMilestonet.ERP7__Status__c = 'Planned';}else{/*No access*/}  if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Project__c.isCreateable()){newMilestonet.ERP7__Project__c = trigger.new[i].Id;}else{/*No access*/}
                        newMilestones.add(newMilestonet);
                        j = j+1;
                    }
                    if(Schema.sObjectType.ERP7__Milestone__c.isCreateable()){ insert newMilestones; } else{ /* no access */ }
                }
            }
        }
    }
}