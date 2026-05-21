trigger Create_RFPS_Plan_Sub_Requirements on Requirement__c (after insert) {
    
    List<Id> rfpPlanReqIds = new List<Id>();
    List<Requirement__c> rfpPlanSubRequirements = new List<Requirement__c>();
    Map<Id, List<Requirement__c>> mySubRequirementsMap = new Map<Id, List<Requirement__c>>();
    List<Requirement__c> rfpPlanSubRequirements2CreateParent = new List<Requirement__c>();
    
    Id RTID; RTID = Schema.SObjectType.ERP7__Requirement__c.getRecordTypeInfosByDeveloperName().get('RFPS_Requirement').getRecordTypeId();
                        
    for(Requirement__c req : System.Trigger.New){
        if(RTID != null){  if(RTID == req.RecordTypeId && req.RFPS_Plan_Requirement__c != Null){   rfpPlanReqIds.add(req.RFPS_Plan_Requirement__c); 
            }
        }
    }
    
    Id rtSubReq; rtSubReq = Schema.SObjectType.ERP7__Requirement__c.getRecordTypeInfosByDeveloperName().get('RFPS_Sub_Requirement').getRecordTypeId();
                                
    rfpPlanSubRequirements = [Select Id, Name, RecordTypeId, RecordType.Name, Answer_Required__c, Parent_Requirement__c, Question__c, Request__c, Request_Plan__c, RFPS_Plan_Requirement__c, Sub_Section__c, Upload_Required__c
                              From Requirement__c
                              Where Parent_Requirement__c In: rfpPlanReqIds];
    
    
    for(ID RFPRPID : rfpPlanReqIds){
        List<Requirement__c> mySubRequirements = new List<Requirement__c>(); for(Requirement__c r : rfpPlanSubRequirements){  if(RFPRPID == r.Parent_Requirement__c){ mySubRequirements.add(r); }   }  mySubRequirementsMap.put(RFPRPID, mySubRequirements);
    }                    
    
    for(Requirement__c req : System.Trigger.New){
        if(RTID != null && rtSubReq != null){  if(RTID == req.RecordTypeId && req.RFPS_Plan_Requirement__c != Null){ List<Requirement__c> mySubReqs = mySubRequirementsMap.get(req.RFPS_Plan_Requirement__c);
                for(Requirement__c R : mySubReqs){  
                    Requirement__c reqNew = new Requirement__c();  
                if(Schema.sObjectType.Requirement__c.fields.RecordTypeId.isCreateable() && rtSubReq != null){reqNew.RecordTypeId = rtSubReq;  
                }else{/*No access*/}   if(Schema.sObjectType.Requirement__c.fields.Request__c.isCreateable()){reqNew.Request__c = R.Request__c; }else{/*No access*/} if(Schema.sObjectType.Requirement__c.fields.Question__c.isCreateable()){reqNew.Question__c = R.Question__c; }else{/*No access*/}  if(Schema.sObjectType.Requirement__c.fields.RFPS_Plan_Requirement__c.isCreateable()){reqNew.RFPS_Plan_Requirement__c = R.Id;  }else{/*No access*/} if(Schema.sObjectType.Requirement__c.fields.Upload_Required__c.isCreateable()){reqNew.Upload_Required__c = R.Upload_Required__c;  }else{/*No access*/}  if(Schema.sObjectType.Requirement__c.fields.Answer_Required__c.isCreateable()){reqNew.Answer_Required__c = R.Answer_Required__c;  }else{/*No access*/}  if(Schema.sObjectType.Requirement__c.fields.Sub_Section__c.isCreateable()){reqNew.Sub_Section__c = R.Sub_Section__c; }else{/*No access*/}  if(Schema.sObjectType.Requirement__c.fields.Parent_Requirement__c.isCreateable()){reqNew.Parent_Requirement__c = Req.Id;   }else{/*No access*/}  if(Schema.sObjectType.Requirement__c.fields.Request__c.isCreateable()){reqNew.Request__c = Req.Request__c; }else{/*No access*/}   rfpPlanSubRequirements2CreateParent.add(reqNew);  }
            }
        }
    }
    
    if(rfpPlanSubRequirements2CreateParent.size() > 0 && Schema.SObjectType.Requirement__c.isCreateable()) {  try { insert rfpPlanSubRequirements2CreateParent; } catch(Exception e){}
    }
}