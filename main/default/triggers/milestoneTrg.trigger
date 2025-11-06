trigger milestoneTrg on ERP7__Milestone__c (after insert, after update, after undelete, after delete) {
    
    //task
    Integer i=0;
    if(trigger.isDelete){
        if(trigger.old[i].ERP7__Project__c != null){
            ERP7__Project__c project= [SELECT Id, Name, ERP7__Expense_Amount__c, ERP7__Expense_Tax__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c FROM ERP7__Project__c WHERE id =: trigger.old[i].ERP7__Project__c];
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Tax__c.isUpdateable()) project.ERP7__Expense_Tax__c    -= trigger.old[i].ERP7__Expense_Tax__c;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Amount__c.isUpdateable()) project.ERP7__Expense_Amount__c -= trigger.old[i].ERP7__Expense_Amount__c;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Sub_Total__c.isUpdateable()) project.ERP7__Sub_Total__c 	   	-= trigger.old[i].ERP7__Sub_Total__c;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Tax__c.isUpdateable()) project.ERP7__Total_Tax__c 	   	-= trigger.old[i].ERP7__Total_Tax__c;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Discount__c.isUpdateable()) project.ERP7__Total_Discount__c -= trigger.old[i].ERP7__Total_Discount__c;
            if(Schema.sObjectType.ERP7__Project__c.isUpdateable()) update project; else{ }
        }
    }
    else if(trigger.new[i].ERP7__Project__c != null) {
        ERP7__Project__c PJT= [SELECT Id, Name, ERP7__Expense_Amount__c, ERP7__Expense_Tax__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c FROM ERP7__Project__c WHERE id =: trigger.new[i].ERP7__Project__c];
        List<ERP7__Milestone__c> MSlist = [SELECT Id, Name, ERP7__Expense_Amount__c, ERP7__Expense_Tax__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c FROM ERP7__Milestone__c WHERE ERP7__Project__c =: trigger.new[i].ERP7__Project__c];
        if(PJT != null && MSlist != null && MSlist.size()>0){
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Amount__c.isUpdateable()) PJT.ERP7__Expense_Amount__c  = 0;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Tax__c.isUpdateable()) PJT.ERP7__Expense_Tax__c     = 0;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Sub_Total__c.isUpdateable()) PJT.ERP7__Sub_Total__c 	    = 0;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Tax__c.isUpdateable()) PJT.ERP7__Total_Tax__c 	    = 0;
            if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Discount__c.isUpdateable()) PJT.ERP7__Total_Discount__c = 0;
            for(ERP7__Milestone__c mst : MSlist) {
                //expense
                if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Tax__c.isUpdateable()) PJT.ERP7__Expense_Tax__c    += mst.ERP7__Expense_Tax__c;
                if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Expense_Amount__c.isUpdateable()) PJT.ERP7__Expense_Amount__c += mst.ERP7__Expense_Amount__c;
                
                //income
                if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Sub_Total__c.isUpdateable()) PJT.ERP7__Sub_Total__c 	   += mst.ERP7__Sub_Total__c;
                if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Tax__c.isUpdateable()) PJT.ERP7__Total_Tax__c 	   += mst.ERP7__Total_Tax__c;
                if(Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Project__c.fields.ERP7__Total_Discount__c.isUpdateable()) PJT.ERP7__Total_Discount__c += mst.ERP7__Total_Discount__c;
            }
            //expense
            
            //income
            
            if(Schema.SObjectType.ERP7__Project__c.isCreateable() && Schema.SObjectType.ERP7__Project__c.isUpdateable()) upsert PJT; else{ }//Total_Exp_Amount
        }
        
    }
}