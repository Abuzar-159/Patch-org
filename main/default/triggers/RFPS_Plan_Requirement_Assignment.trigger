trigger RFPS_Plan_Requirement_Assignment on Request__c (after insert, after update) {
    /*
Trigger to create and assign requirements to RFP from RFP Plan
*/
    
    // Declerations and Definitions
    if(PreventRecursiveLedgerEntry.RFPS_Plan){
        PreventRecursiveLedgerEntry.RFPS_Plan = false;
        Map<Id, Id> rfp2PlanMap = new Map<Id, Id>();
        List<Id> rfpPlanIds = new List<Id>();
        List<Id> rfpIds = new List<Id>();
        List<Request_Plan__c> rfpPlans = new List<Request_Plan__c>();
        List<Requirement__c> rfpPlanRequirements = new List<Requirement__c>(); 
        List<Requirement__c> rfpPlanRequirements2CreateParent = new List<Requirement__c>();
        List<Requirement__c> rfpPlanRequirements2Update = new List<Requirement__c>();
        List<Requirement__c> rfps2Delete = new List<Requirement__c>();
        Map<Id, List<Requirement__c>> rfpPlanRequirementsMap = new Map<Id, List<Requirement__c>>();
        Map<Id, List<Requirement__c>> rfpRequirements2DeleteMap = new Map<Id, List<Requirement__c>>();
        
        for(Request__c rfp : System.Trigger.New){
            rfpIds.add(rfp.Id);
            if(rfp.Request_Plan__c != Null){
                rfp2PlanMap.put(rfp.Id, rfp.Request_Plan__c);
                rfpPlanIds.add(rfp.Request_Plan__c);
            }
        }
        
        //Fetch all the required data
        rfpPlans = [Select Id, Name, Active__c, Name__c, Organisation__c, Organisation_Business_Unit__c 
                    From Request_Plan__c
                    Where Id In: rfpPlanIds];
        
        rfpPlanRequirements = [Select Id, Name, RecordTypeId, RecordType.Name, Answer_Required__c, Section__c, Parent_Requirement__c, Question__c, Request__c, Request_Plan__c, RFPS_Plan_Requirement__c, Upload_Required__c
                               From Requirement__c
                               Where Request_Plan__c In: rfpPlanIds];
        
        List<Requirement__c> rfpRequirements = [Select Id, Name, Responses__c, RecordTypeId, RecordType.Name, Answer_Required__c, Parent_Requirement__c, Question__c, Request__c, Request_Plan__c, RFPS_Plan_Requirement__c, Upload_Required__c
                                                From Requirement__c
                                                Where Request__c In: rfpIds And
                                                RFPS_Plan_Requirement__c != Null LIMIT 9999];
        
        Id rt; rt = Schema.SObjectType.ERP7__Requirement__c.getRecordTypeInfosByDeveloperName().get('RFPS_Requirement').getRecordTypeId();

        for(Id rfpId :rfpIds){
            List<Requirement__c> myreq2Delete = new List<Requirement__c>();
            for(Requirement__c r : rfpRequirements){
                if(rfpId == r.Request__c){
                    myreq2Delete.add(r);
                }
            }
            rfpRequirements2DeleteMap.put(rfpId, myreq2Delete);
        }   
        
        //Process the fetched data as and when required
        for(Request_Plan__c rfpPlan : rfpPlans){
            List<Requirement__c> myRequirements = new List<Requirement__c>();
            
            for(Requirement__c reqrmnt : rfpPlanRequirements){
                if(rfpPlan.Id == reqrmnt.Request_Plan__c){
                    myRequirements.add(reqrmnt);
                }
            }
            rfpPlanRequirementsMap.put(rfpPlan.Id, myRequirements);
        }
        
        //Prepare data for insert/update based on requirements
        for(Request__c rfp : System.Trigger.New){
            if(rfp.Request_Plan__c != Null && rfp.Status__c == 'Review' && (Trigger.IsInsert || Trigger.IsUndelete)) {
                List<Requirement__c> currentRfpPlanRequirements = rfpPlanRequirementsMap.get(rfp.Request_Plan__c);
                
                for(Requirement__c currRequirement : currentRfpPlanRequirements){
                    if(rt != null && currRequirement.RecordType.Name == 'RFPS_Plan_RequirementS'){
                        Requirement__c req = new Requirement__c();
                        req.RecordTypeId = rt;
                        req.Request__c = rfp.Id;
                        req.Question__c = currRequirement.Question__c;
                        req.RFPS_Plan_Requirement__c = currRequirement.Id;
                        req.Upload_Required__c = currRequirement.Upload_Required__c;
                        req.Section__c = currRequirement.Section__c;
                        req.Answer_Required__c = currRequirement.Answer_Required__c;
                        rfpPlanRequirements2CreateParent.add(req);
                    }
                }
            }
            else if(Trigger.IsUpdate) {
                for(Request__c rfpOld : System.Trigger.Old){
                    if(rfp.Id == rfpOld.Id && rfpOld.Request_Plan__c != rfp.Request_Plan__c && rfp.Status__c != 'Review'){
                        rfp.addError('Sorry you cannot edit RFPS Plan');
                    }
                    else if(rfp.Id == rfpOld.Id && rfpOld.Request_Plan__c != rfp.Request_Plan__c && rfp.Status__c == 'Review'){
                        if(rfpOld.Request_Plan__c != Null && rfp.Request_Plan__c != Null){
                            List<Requirement__c> currentRfpPlanRequirements = rfpPlanRequirementsMap.get(rfp.Request_Plan__c);
                            
                            for(Requirement__c currRequirement : currentRfpPlanRequirements){
                                if(rt != null && currRequirement.RecordType.Name == 'RFPS_Plan_RequirementS'){
                                    Requirement__c req = new Requirement__c();
                                    req.RecordTypeId = rt;
                                    req.Request__c = rfp.Id;
                                    req.Question__c = currRequirement.Question__c;
                                    req.RFPS_Plan_Requirement__c = currRequirement.Id;
                                    req.Upload_Required__c = currRequirement.Upload_Required__c;
                                    req.Section__c = currRequirement.Section__c;
                                    req.Answer_Required__c = currRequirement.Answer_Required__c;
                                    rfpPlanRequirements2CreateParent.add(req);
                                }
                            }
                            List<Requirement__c> myRequirements2Delete = rfpRequirements2DeleteMap.get(rfp.Id);
                            for(Requirement__c r2d : myRequirements2Delete){
                                //check if the requirements have responses if yes depricate else delete it
                                if(r2d.Responses__c > 0){
                                    r2d.Depricated__c = true;
                                    rfpPlanRequirements2Update.add(r2d);
                                }
                                else{
                                    rfps2Delete.add(r2d);
                                }
                            }
                        }
                        else if(rfpOld.Request_Plan__c == Null && rfp.Request_Plan__c != Null){
                            List<Requirement__c> currentRfpPlanRequirements = rfpPlanRequirementsMap.get(rfp.Request_Plan__c);
                            
                            for(Requirement__c currRequirement : currentRfpPlanRequirements){
                                if(rt != null && currRequirement.RecordType.Name == 'RFPS_Plan_RequirementS'){
                                    Requirement__c req = new Requirement__c();
                                    if(Schema.sObjectType.Requirement__c.fields.RecordTypeId.isCreateable()) {req.RecordTypeId = rt;} else{ /* no access*/ }
                                    if(Schema.sObjectType.Requirement__c.fields.Request__c.isCreateable()) { req.Request__c = rfp.Id; } else{ /* no access*/ }
                                    if(Schema.sObjectType.Requirement__c.fields.Question__c.isCreateable()) { req.Question__c = currRequirement.Question__c; } else{ /* no access*/ }
                                    if(Schema.sObjectType.Requirement__c.fields.RFPS_Plan_Requirement__c.isCreateable()) { req.RFPS_Plan_Requirement__c = currRequirement.Id; } else{ /* no access*/ }
                                    if(Schema.sObjectType.Requirement__c.fields.Upload_Required__c.isCreateable()) { req.Upload_Required__c = currRequirement.Upload_Required__c; } else{ /* no access*/ }
                                    if(Schema.sObjectType.Requirement__c.fields.Answer_Required__c.isCreateable()) { req.Answer_Required__c = currRequirement.Answer_Required__c; } else{ /* no access*/ }
                                    if(Schema.sObjectType.Requirement__c.fields.Section__c.isCreateable()) { req.Section__c = currRequirement.Section__c; } else{ /* no access*/ }
                                    rfpPlanRequirements2CreateParent.add(req);
                                }
                            }
                        }
                        else if(rfpOld.Request_Plan__c != Null && rfp.Request_Plan__c == Null){
                            List<Requirement__c> myRequirements2Delete = rfpRequirements2DeleteMap.get(rfp.Id);
                            for(Requirement__c r2d : myRequirements2Delete){
                                //check if the requirements have responses if yes depricate else delete it
                                if(r2d.Responses__c > 0){
                                    if(Schema.sObjectType.Requirement__c.fields.Depricated__c.isUpdateable()) { r2d.Depricated__c = true; } else{ /* no access*/ }
                                    rfpPlanRequirements2Update.add(r2d);
                                }
                                else{
                                    rfps2Delete.add(r2d);
                                }
                            }   
                        }
                    }
                }
            }
        }
        
        // DML operations
        if(rfpPlanRequirements2CreateParent.size() > 0) {
            try { if(Schema.sObjectType.Requirement__c.isCreateable()){ insert rfpPlanRequirements2CreateParent;}  else{ /* no access */ }} catch(Exception e){}
        }
        if(rfpPlanRequirements2Update.size() > 0) {
            try { if(Schema.sObjectType.Requirement__c.isUpdateable()){ update rfpPlanRequirements2Update; } else{ /* no access */ } } catch(Exception e){}
        }
        
        if(rfps2Delete.size() > 0) {
            try { if(Requirement__c.sObjectType.getDescribe().isDeletable()){ delete rfps2Delete; } else{ /*  no access */ } }  catch(Exception e){}
        }
    }
}