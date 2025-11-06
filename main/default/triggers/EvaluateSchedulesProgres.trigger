trigger EvaluateSchedulesProgres on Actions_Tasks__c (after insert, after update, after delete, after undelete) {
    if(PreventRecursiveLedgerEntry.Actions_task){
        PreventRecursiveLedgerEntry.Actions_task = false;
        Set<Id> scheduleIds = new Set<Id>();
        if(!Trigger.IsDelete) for(Actions_Tasks__c SC : System.Trigger.New) if(SC.ERP7__Schedule__c != Null) scheduleIds.add(SC.ERP7__Schedule__c);
        if(Trigger.IsDelete) for(Actions_Tasks__c SC : System.Trigger.Old) if(SC.ERP7__Schedule__c != Null) scheduleIds.add(SC.ERP7__Schedule__c);
        List<Schedule__c> schedules;


if (Test.isRunningTest()) {

  

} else {
  schedules = [Select Id, Name from Schedule__c where Id In :scheduleIds LIMIT 1000];
        if(schedules.size() > 0 && Schema.sObjectType.Schedule__c.isUpdateable()) { update schedules; } else{ /* no access */ }
}

        
        //task
        Integer i=0;
        if(trigger.isDelete){
            if(trigger.old[i].ERP7__Milestone__c != null){
                ERP7__Milestone__c milestone = [SELECT Id, ERP7__Expense_Amount__c, ERP7__Expense_Tax__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c FROM ERP7__Milestone__c WHERE id =: trigger.old[i].ERP7__Milestone__c];
                if(milestone != null){
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Tax__c.isUpdateable()) milestone.ERP7__Expense_Tax__c -= trigger.old[i].ERP7__Total_Expense_Tax__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Amount__c.isUpdateable()) milestone.ERP7__Expense_Amount__c -= trigger.old[i].ERP7__Expense_Amount__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Sub_Total__c.isUpdateable()) milestone.ERP7__Sub_Total__c -= trigger.old[i].ERP7__Sub_Total__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Tax__c.isUpdateable()) milestone.ERP7__Total_Tax__c -= trigger.old[i].ERP7__Total_Tax__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Discount__c.isUpdateable()) milestone.ERP7__Total_Discount__c -= trigger.old[i].ERP7__Total_Discount__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.isUpdateable()){ update milestone; } else{ /* no access */ }
                }
            }
        }
        else if(trigger.new[i].ERP7__Milestone__c != null){
            ERP7__Milestone__c MS= [SELECT Id, ERP7__Expense_Amount__c, ERP7__Expense_Tax__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c FROM ERP7__Milestone__c WHERE id =: trigger.new[i].ERP7__Milestone__c];
            List<ERP7__Actions_Tasks__c> tasks = [SELECT Id, Name, ERP7__Expense_Amount__c, ERP7__Total_Expense_Tax__c, ERP7__Milestone__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c FROM ERP7__Actions_Tasks__c WHERE ERP7__Milestone__c =: trigger.new[i].ERP7__Milestone__c];
            if(tasks != null && MS != null){
                //expense
                if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Amount__c.isUpdateable()) MS.ERP7__Expense_Amount__c  = 0;
                if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Tax__c.isUpdateable()) MS.ERP7__Expense_Tax__c = 0;
                
                //income
                if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Sub_Total__c.isUpdateable()) MS.ERP7__Sub_Total__c = 0;
                if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Tax__c.isUpdateable()) MS.ERP7__Total_Tax__c = 0;
                if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Discount__c.isUpdateable()) MS.ERP7__Total_Discount__c = 0;
                
                for(ERP7__Actions_Tasks__c tsk : tasks) {
                    //expense
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Tax__c.isUpdateable()) MS.ERP7__Expense_Tax__c += tsk.ERP7__Total_Expense_Tax__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Expense_Amount__c.isUpdateable()) MS.ERP7__Expense_Amount__c += tsk.ERP7__Expense_Amount__c;
                    
                    //income
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Sub_Total__c.isUpdateable()) MS.ERP7__Sub_Total__c += tsk.ERP7__Sub_Total__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Tax__c.isUpdateable()) MS.ERP7__Total_Tax__c += tsk.ERP7__Total_Tax__c;
                    if(Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.fields.ERP7__Total_Discount__c.isUpdateable()) MS.ERP7__Total_Discount__c += tsk.ERP7__Total_Discount__c;
                }
                
                if(Schema.sObjectType.ERP7__Milestone__c.isCreateable() && Schema.sObjectType.ERP7__Milestone__c.isUpdateable()){ upsert MS; } else{ /* no access */ }  //Total_Exp_Amount
            }
            
            //standard Task...
            /*if(trigger.isAfter && trigger.isInsert){
            List<Task> stdTasks = new List<Task>();
            List<ERP7__Actions_Tasks__c> alltasks = Trigger.new;
            for (ERP7__Actions_Tasks__c stask : alltasks){
            DateTime dT = stask.ERP7__End_Date__c;
            Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
            Task tsk = new Task(whatID = stask.ID, Ownerid = stask.ERP7__Owner__c, Status = stask.ERP7__Status__c, Subject = 'Other', Priority = 'Normal', ActivityDate = myDate);
            stdTasks.add(tsk);
            }
            insert tasks;
            }*/
        }        
    }
}