public with Sharing class ManageProjects {
    
    @AuraEnabled
    public static comWrap getAll(String pjtID) {
        ERP7__Project__c PROJ = [SELECT Id, Name, ERP7__Project_Manager__c, ERP7__Project_Manager__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Team__c, ERP7__Team__r.Name, ERP7__Status__c, ERP7__Percentage__c, ERP7__Default_Routing__c, ERP7__Default_Routing__r.Name, ERP7__Description__c, ERP7__Organisations__c, ERP7__Organisations__r.Name, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__Account__c, ERP7__Account__r.Name, ERP7__Default_Routing__r.ERP7__Process__c FROM ERP7__Project__c WHERE Id =: pjtID];
        //ERP7__Routing__c curRouting = [SELECT Id, ERP7__Process__c FROM ERP7__Routing__c WHERE Id =: PROJ.ERP7__Default_Routing__c];
        List<milestoneWrap> MsList = getProcessMilestones('', pjtID);
        comWrap pjtCom = new comWrap(PROJ, MsList);
        return pjtCom;
    }
    
    @AuraEnabled
    public static List< PMWP > getProjects(Integer pjtOffset, Integer RecordLimit, String status) {
        List< PMWP > projectWP = new List< PMWP >();
        System.debug('Status: '+status);
        List< ERP7__Project__c > PROJs = new List< ERP7__Project__c >();
        if(status != '') PROJs = [SELECT Id, Name, ERP7__Total_Amount__c , ERP7__Committed_Amount__c , ERP7__Consumed_Amount__c , ERP7__Returned_Amount__c , ERP7__Remaining_Amount__c , ERP7__Project_Manager__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Team__c, ERP7__Status__c, ERP7__Percentage__c, ERP7__Default_Routing__c, ERP7__Description__c, ERP7__Organisations__c, ERP7__Contact__c, ERP7__Account__c, ERP7__Project_Manager__r.Name, ERP7__Default_Routing__r.ERP7__Process__c, ERP7__Total_Expense_Amount__c, ERP7__Total_Income__c FROM ERP7__Project__c WHERE ERP7__Active__c = true AND ERP7__Status__c =: status Order by CreatedDate Desc limit 1000];
        else PROJs = [SELECT Id, Name, ERP7__Total_Amount__c , ERP7__Committed_Amount__c , ERP7__Consumed_Amount__c , ERP7__Returned_Amount__c , ERP7__Remaining_Amount__c , ERP7__Project_Manager__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Team__c, ERP7__Status__c, ERP7__Percentage__c, ERP7__Default_Routing__c, ERP7__Description__c, ERP7__Organisations__c, ERP7__Contact__c, ERP7__Account__c, ERP7__Project_Manager__r.Name, ERP7__Default_Routing__r.ERP7__Process__c, ERP7__Total_Expense_Amount__c, ERP7__Total_Income__c FROM ERP7__Project__c WHERE ERP7__Active__c = true AND ERP7__Status__c != 'Rejected' Order by CreatedDate Desc limit 1000];
        List< ERP7__Project__c > newProjectList = new List<ERP7__Project__c>();
        Integer countPjt = 0;
        for(ERP7__Project__c pjt : PROJs) {
            if(countPjt < (pjtOffset+RecordLimit) && countPjt >= pjtOffset) {
                newProjectList.add(pjt);
            }
            countPjt++;
        }
        List<ERP7__Resource__c> ResourceList = [SELECT Id, Name, ERP7__User__c,ERP7__Team__c FROM ERP7__Resource__c WHERE ERP7__Team__c != null];
        List<User> UserList=[SELECT Id, Name, fullphotourl FROM User WHERE IsActive = true];
        
        for(ERP7__Project__c project : newProjectList) {
            List<User> ProjectUserList = new List<User>();
            for(ERP7__Resource__c projectRes : ResourceList) {
                if(projectRes.ERP7__Team__c == project.ERP7__Team__c && project.ERP7__Team__c != null && projectRes.ERP7__Team__c != null){
                    for(User user : UserList) {
                        if(user.Id == projectRes.ERP7__User__c) {
                            ProjectUserList.add(user);
                        }
                    }
                }
            }
            projectWP.add(new PMWP(project, ProjectUserList, PROJs.size()));
        }
        //projectWP.recSize = PROJs.size();
        return projectWP;
    }
     @AuraEnabled
    public static List< ERP7__Project__c > getAllProjects() {
    List< ERP7__Project__c > PROJs = [SELECT Id, Name, ERP7__Total_Amount__c , ERP7__Committed_Amount__c , ERP7__Consumed_Amount__c , ERP7__Returned_Amount__c , ERP7__Remaining_Amount__c , ERP7__Project_Manager__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Team__c, ERP7__Status__c, ERP7__Percentage__c, ERP7__Default_Routing__c, ERP7__Description__c, ERP7__Organisations__c, ERP7__Contact__c, ERP7__Account__c, ERP7__Project_Manager__r.Name, ERP7__Default_Routing__r.ERP7__Process__c, ERP7__Total_Expense_Amount__c, ERP7__Total_Income__c FROM ERP7__Project__c WHERE ERP7__Active__c = true AND ERP7__Status__c != 'Rejected' Order by CreatedDate Desc limit 1000];
    return PROJs;
    }
    
    @AuraEnabled
    public static List <PMWP> getsimilarProjects(String searchStr) {
        List< PMWP > projectWP = new List< PMWP >();
        searchStr = '%' + searchStr + '%';
        try {
            List< ERP7__Project__c > PROJs = [SELECT Id, Name, ERP7__Project_Manager__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Team__c, ERP7__Status__c, ERP7__Percentage__c, ERP7__Default_Routing__c, ERP7__Description__c, ERP7__Organisations__c, ERP7__Contact__c, ERP7__Account__c, ERP7__Project_Manager__r.Name, ERP7__Default_Routing__r.ERP7__Process__c, ERP7__Total_Expense_Amount__c, ERP7__Total_Income__c FROM ERP7__Project__c WHERE ERP7__Active__c = true AND ERP7__Status__c != 'Rejected' AND Name LIKE:searchStr Order by CreatedDate Desc LIMIT 1000];
            List<ERP7__Resource__c> ResourceList = [SELECT Id, Name, ERP7__User__c,ERP7__Team__c FROM ERP7__Resource__c WHERE ERP7__Team__c != null];
            List<User> UserList=[SELECT Id, Name, fullphotourl FROM User WHERE IsActive = true];
            
            for(ERP7__Project__c project : PROJs) {
                List<User> ProjectUserList = new List<User>();
                for(ERP7__Resource__c projectRes : ResourceList) {
                    if(projectRes.ERP7__Team__c == project.ERP7__Team__c && project.ERP7__Team__c != null && projectRes.ERP7__Team__c != null){
                        for(User user : UserList) {
                            if(user.Id == projectRes.ERP7__User__c) {
                                ProjectUserList.add(user);
                            }
                        }
                    }
                }
                projectWP.add(new PMWP(project, ProjectUserList, PROJs.size()));
            }
        }catch(Exception e){ projectWP[0].errMsg = 'exception occurred : '+e;
            
        }
        return projectWP;
    }
    
    @AuraEnabled
    public static List < String > getStatuspickval() {
        List < String > options = new List < String > ();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Project__c.Status__c.getDescribe();
        
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List < String > getMilestoneStatuspickval() {
        List < String > options = new List < String > ();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Milestone__c.Status__c.getDescribe();
        
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List < String > getTaskStatusPickval() {
        List < String > options = new List < String > ();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Actions_Tasks__c.Status__c.getDescribe();
        
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static List < String > getTaskTypePickval() {
        List < String > options = new List < String > ();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Actions_Tasks__c.Type__c.getDescribe();
        
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        
        return options;
    }
    
    @AuraEnabled
    public static Map<String,String> getTOTypePickval()
    {
        Map<String,String> recordTypeMap = new Map<String,String>();
        Schema.DescribeSObjectResult R = ERP7__Transfer_Order__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        for(RecordType rec : [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE SobjectType = 'ERP7__Transfer_Order__c']) {
            recordTypeMap.put(rec.Id, rec.Name);
            
        }
        return recordTypeMap;
    }
    
    @AuraEnabled
    public static List < String > getTOStatusPickval() {
        List < String > options = new List < String > ();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Transfer_Order__c.Status__c.getDescribe();
        
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static Project__c getCurProject(String curProjId) {
        ERP7__Project__c currentPROJ = new ERP7__Project__c();
        currentPROJ = [SELECT Id, Name, ERP7__Project_Manager__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Status__c, ERP7__Percentage__c, ERP7__Organisations__c, ERP7__Team__c, ERP7__Default_Routing__c, ERP7__Account__c, ERP7__Contact__c, ERP7__Default_Routing__r.ERP7__Process__c, ERP7__Description__c, ERP7__Total_Expense_Amount__c, ERP7__Total_Income__c FROM ERP7__Project__c WHERE Id =: curProjId LIMIT 1];
        return currentPROJ;
    }
    
    @AuraEnabled
    public static Actions_Tasks__c getCurTask(String curTaskId) {
        ERP7__Actions_Tasks__c currentTASK = new ERP7__Actions_Tasks__c();
        currentTASK = [SELECT Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Status__c, ERP7__Type__c, ERP7__Project__c, ERP7__Milestone__c, ERP7__Owner__c, ERP7__Owner__r.Name FROM ERP7__Actions_Tasks__c WHERE Id =: curTaskId LIMIT 1];
        return currentTASK;
    }
    
    @AuraEnabled
    public static List< milestoneWrap > getProcessMilestones(String curRouting, String curProject) {
        
        List< ERP7__Resource_Group__c > resG = new List<ERP7__Resource_Group__c >();
        List< milestoneWrap > milestonesWP = new List< milestoneWrap >();
        List< ERP7__Milestone__c > milestones = new List< ERP7__Milestone__c >();
        
        milestones = [SELECT Id, Name, ERP7__Resource__c, ERP7__Resource_Group__c, ERP7__Resource_Group__r.Name, ERP7__Start_Date__c, ERP7__Due_Date__c, ERP7__Status__c, ERP7__Project__c, ERP7__Percentage__c, ERP7__Organisations__c, ERP7__isSerialized__c, ERP7__Previous_Milestone__c, ERP7__Next_Milestone__c,ERP7__Requirement__c FROM ERP7__Milestone__c WHERE ERP7__Project__c =: curProject ORDER by CreatedDate Asc];
        
        List< String > rglst = new List< String >();
        for(ERP7__Milestone__c m : milestones){
            if(m.ERP7__Resource_Group__c != null){
                if(!rglst.contains(m.ERP7__Resource_Group__c)){
                    rglst.add(m.ERP7__Resource_Group__c);
                } 
            }
        }
        
        List< ERP7__Actions_Tasks__c > tasks = new List< ERP7__Actions_Tasks__c >();
        List<ERP7__Resource__c> ResourceList = new List<ERP7__Resource__c>();
        
        tasks = [SELECT Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Status__c, ERP7__Type__c, ERP7__Project__c, ERP7__Milestone__c, ERP7__Owner__c, ERP7__Owner__r.Name, ERP7__Total_Amount__c, ERP7__Total_Expense_Amount__c FROM ERP7__Actions_Tasks__c WHERE ERP7__Project__c =: curProject];
        
        ResourceList = [SELECT Id, Name, ERP7__User__c,ERP7__Resource_Group__c FROM ERP7__Resource__c WHERE ERP7__Resource_Group__c != null AND ERP7__Resource_Group__c In : rglst AND ERP7__User__c != null];
        
        List< String > usrlst = new List< String >();
        for(ERP7__Resource__c res : ResourceList){
            if(!usrlst.contains(res.ERP7__User__c)){
                usrlst.add(res.ERP7__User__c);
            } 
        }
        List<User> UserList = new List<User>();
        UserList = [SELECT Id, Name, fullphotourl FROM User WHERE IsActive = true AND Id In : usrlst];
        
        List<User> MilestoneUserList = new List<User>();
        List< ERP7__Actions_Tasks__c > tskList = new List< ERP7__Actions_Tasks__c >();
        
        for(ERP7__Milestone__c milestone : milestones) {
            MilestoneUserList = new List<User>();
            tskList = new List< ERP7__Actions_Tasks__c >();
            if(milestone.ERP7__Resource_Group__c != null){
                for(ERP7__Resource__c res : ResourceList) {
                    if(res.ERP7__Resource_Group__c == milestone.ERP7__Resource_Group__c){
                        for(User user : UserList) {
                            if(user.Id == res.ERP7__User__c) {
                                MilestoneUserList.add(user);
                            }
                        }
                    }
                }
            }
            for(ERP7__Actions_Tasks__c task : tasks) {
                if(task.ERP7__Milestone__c == milestone.Id) {
                    tskList.add(task);
                }
            }
            milestonesWP.add(new milestoneWrap(milestone, tskList, MilestoneUserList));
        }
        return milestonesWP;
    }
    
    @AuraEnabled
    public static List<ERP7__Actions_Tasks__c> getMilestoneTasks(String currMilestone) {
        List<ERP7__Actions_Tasks__c> tasks = new List<ERP7__Actions_Tasks__c>();
        tasks = [SELECT Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Status__c, ERP7__Type__c, ERP7__Project__c, ERP7__Milestone__c, ERP7__Owner__c, ERP7__Owner__r.Name FROM ERP7__Actions_Tasks__c WHERE ERP7__Milestone__c =: currMilestone];
        return tasks;
    }
    
    @AuraEnabled
    public static List<ERP7__Manufacturing_Order__c> getTaskMOs(String taskId) {
        List<ERP7__Manufacturing_Order__c> Morders = new List<ERP7__Manufacturing_Order__c>();
        Morders = [SELECT Id, Name, ERP7__Project__c, ERP7__Routing__c, ERP7__Version__c, ERP7__Product__c, ERP7__Sales_Order__c, ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name, ERP7__Status__c, ERP7__Quantity__c, ERP7__Progress__c, ERP7__Expected_Date__c FROM ERP7__Manufacturing_Order__c WHERE ERP7__Tasks__c =: taskId];
        return Morders;
    }
    
    @AuraEnabled
    public static List<ERP7__WO__c> getTaskWOs(String taskId) {
        List<ERP7__WO__c> Worders = new List<ERP7__WO__c>();
        Worders = [SELECT Id, Name, ERP7__Project__c, ERP7__Routing__c, ERP7__Version__c, ERP7__Product__c, ERP7__Sales_Order__c, ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name, ERP7__Status__c, ERP7__Total_Quantity__c, ERP7__Progress__c, ERP7__Expected_Date__c FROM ERP7__WO__c WHERE ERP7__Tasks__c =: taskId];
        return Worders;
    }
    
    @AuraEnabled
    public static List<ERP7__Transfer_Order__c> getTaskTOs(String taskId) {
        List<ERP7__Transfer_Order__c> Torders = new List<ERP7__Transfer_Order__c>();
        Torders = [SELECT Id, Name, RecordTypeId, ERP7__From_Site__c, ERP7__From_Site__r.Name, ERP7__To_Site__c, ERP7__To_Site__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__To_Channel__c, ERP7__To_Channel__r.Name, ERP7__Status__c FROM ERP7__Transfer_Order__c WHERE ERP7__Tasks__c =: taskId];
        return Torders;
    }
    
    @AuraEnabled
    public static List<ERP7__Sales_Order__c> getTaskSOs(String taskId) {
        List<ERP7__Sales_Order__c> Sorders = new List<ERP7__Sales_Order__c>();
        Sorders = [SELECT Id, Name, ERP7__Account__c, ERP7__Account__r.Name, ERP7__Employees__c, ERP7__Employees__r.Name, ERP7__Contact__c, ERP7__Contact__r.Name, ERP7__Status__c, ERP7__Total_Quantity__c FROM ERP7__Sales_Order__c WHERE ERP7__Tasks__c =: taskId];
        return Sorders;
    }
    
    @AuraEnabled
    public static List<ERP7__PO__c> getTaskPOs(String taskId) {
        List<ERP7__PO__c> Porders = new List<ERP7__PO__c>();
        Porders = [SELECT Id, Name, ERP7__Status__c, ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Name, ERP7__Total_Quantity__c, ERP7__Vendor__c, ERP7__Vendor__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name FROM ERP7__PO__c WHERE ERP7__Tasks__c =: taskId];
        return Porders;
    }
    
    @AuraEnabled
    public static List<ERP7__Requisition__c> getTaskPRs(String taskId) {
        List<ERP7__Requisition__c> Prequisition = new List<ERP7__Requisition__c>();
        Prequisition = [SELECT Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Requisitioned_By__c, ERP7__Requisitioned_By__r.Name, ERP7__Status__c FROM ERP7__Requisition__c WHERE ERP7__Tasks__c =: taskId];
        return Prequisition;
    }
    
    @AuraEnabled
    public static PMWP  save_Project(String currentProject) {
        try{
            ERP7__Project__c project = (ERP7__Project__c) JSON.deserialize(currentProject, ERP7__Project__c .class);
            List<User> res = new List<User>();
            PMWP projectWP;
            if(Schema.SObjectType.ERP7__Project__c.isCreateable() && Schema.SObjectType.ERP7__Project__c.isUpdateable()) upsert project;
            projectWP = new PMWP(project, res, 0);
            return projectWP;
        }
        catch(DmlException e){ String msg = '';
            
            for (Integer i = 0; i < e.getNumDml(); i++) {  msg =+ e.getDmlMessage(i) +  '\n' ;
            } throw new AuraHandledException(msg);
             
        }catch(Exception e){  throw new AuraHandledException(e.getMessage());
        }
        finally {
        }
    }
    
    @AuraEnabled
    public static milestoneWrap save_MilestoneAK(String newMilestone, String currentRouting, String msList) {
        milestoneWrap milestoneWP;
        try{
            List< ERP7__Actions_Tasks__c > tskList = new List< ERP7__Actions_Tasks__c >();
            List< User > resG = new List< User >();
            ERP7__Milestone__c milestone = (ERP7__Milestone__c) JSON.deserialize(newMilestone, ERP7__Milestone__c .class);
            if(Schema.SObjectType.ERP7__Milestone__c.isCreateable() && Schema.SObjectType.ERP7__Milestone__c.isUpdateable()) upsert milestone;
            milestoneWP = new milestoneWrap(milestone, tskList, resG);
            
            //serial
            if(milestone.ERP7__isSerialized__c){
                if(milestone.ERP7__Previous_Milestone__c != null){
                    ERP7__Milestone__c prevMS = [Select Id, Name, Start_Date__c, Due_Date__c, Percentage__c, ERP7__Project__c, ERP7__isSerialized__c, ERP7__Previous_Milestone__c, ERP7__Next_Milestone__c From ERP7__Milestone__c where Id =:milestone.ERP7__Previous_Milestone__c LIMIT 1];
                    if(prevMS != null){
                        Date prevSD = prevMS.ERP7__Start_Date__c;
                        Date prevED = prevMS.ERP7__Due_Date__c;
                        Date currentSD = milestone.ERP7__Start_Date__c;
                        Date currentED = milestone.ERP7__Due_Date__c;
                        Integer days = 0;
                        Integer currDuration = currentSD.daysBetween(currentED);
                        if(currentSD < prevED){
                            milestone.Start_Date__c = prevED.addDays(days);
                            currentSD = milestone.ERP7__Start_Date__c;
                            milestone.ERP7__Due_Date__c = currentSD.addDays(currDuration);
                        }
                    }
                }
                
                ERP7__Milestone__c nextMS = new ERP7__Milestone__c();
                ERP7__Milestone__c current = new ERP7__Milestone__c();
                List<ERP7__Milestone__c> nextMSlist = new List<ERP7__Milestone__c>();
                List<ERP7__Milestone__c> MSl = [Select Id, Name, Start_Date__c, Due_Date__c, Percentage__c, ERP7__Project__c, ERP7__isSerialized__c, ERP7__Previous_Milestone__c, ERP7__Next_Milestone__c From ERP7__Milestone__c where ERP7__Project__c =: milestone.ERP7__Project__c AND ERP7__isSerialized__c = true LIMIT 1000];
                // Id !=: milestone.Id AND 
                Id nextId;
                Id currId;
                if(milestone.ERP7__Next_Milestone__c != null){
                    nextId = milestone.ERP7__Next_Milestone__c;
                    currId = milestone.Id;
                    for(ERP7__Milestone__c seriesMs: MSl) {
                        if(seriesMs.Id == currId || seriesMs.Id == milestone.Id){
                            if(nextId == milestone.ERP7__Next_Milestone__c){
                                current = milestone;
                                
                            }
                            else{
                                current = seriesMs;                                
                            }
                            for(ERP7__Milestone__c nextseriesMs: MSl){
                                if(nextseriesMs.Id == nextId){
                                    nextMS = nextseriesMs;
                                    Date nextSD = nextMS.ERP7__Start_Date__c;
                                    Date nextED = nextMS.ERP7__Due_Date__c;
                                    Date currentED = current.ERP7__Due_Date__c;
                                    Integer days = 0;
                                    Integer nextDuration = nextSD.daysBetween(nextED);
                                    if(nextSD < currentED){
                                        nextMS.ERP7__Start_Date__c = currentED.addDays(days);
                                        nextSD = nextMS.Start_Date__c;
                                        nextMS.ERP7__Due_Date__c = nextSD.addDays(nextDuration);                                        
                                    }
                                    nextMSlist.add(nextMS);
                                }
                            }
                        }
                        currId = nextId;
                        if(nextMS.ERP7__Next_Milestone__c != null)
                            nextId = nextMS.ERP7__Next_Milestone__c;
                        else
                            nextId = null;
                    }
                    try{
                        DMLManager.upsertAsUser(nextMSlist);
                    } catch(Exception ex){
                    }
                }
            }
        }
        catch(DmlException e){ String msg = '';
            for (Integer i = 0; i < e.getNumDml(); i++) { msg =+ e.getDmlMessage(i) +  '\n' ;
            } throw new AuraHandledException(msg);
             
        }catch(Exception e){throw new AuraHandledException(e.getMessage());
        }
        finally {
        }
        return milestoneWP;
    }
    
    @AuraEnabled
    public static List<milestoneWrap> delete_Milestone(String msWrap, String recordId) {
        List<milestoneWrap> miles = new List<milestoneWrap>();
        if(msWrap != null && msWrap != ''){
            miles = (List<milestoneWrap>) JSON.deserialize(msWrap, List<milestoneWrap> .class);
            
            ERP7__Milestone__c delMs = new ERP7__Milestone__c();
            integer i = 0;
            for(milestoneWrap ms : miles){
                if(ms.milestone.Id == recordId){
                    delMs = ms.milestone;
                    miles.remove(i);
                    break;
                }  i++;
            }
            if(ERP7__Milestone__c.sObjectType.getDescribe().isDeletable()) delete delMs;
        }
        return miles;
    }
    
    @AuraEnabled
    public static Actions_Tasks__c save_Task(String currentTask) {
        ERP7__Actions_Tasks__c currTask = (ERP7__Actions_Tasks__c) JSON.deserialize(currentTask, ERP7__Actions_Tasks__c .class);
        try {
            if(Schema.SObjectType.ERP7__Actions_Tasks__c.isCreateable() && Schema.SObjectType.ERP7__Actions_Tasks__c.isUpdateable()) upsert currTask;
        } catch (DMLException ex) {
            
        }
        return currTask;
    }
    
    @AuraEnabled
    public static ERP7__Actions_Tasks__c delete_Task(String recordId) {
        ERP7__Actions_Tasks__c delTsk = [SELECT Id, Name FROM ERP7__Actions_Tasks__c WHERE Id =: recordId];
        if(ERP7__Actions_Tasks__c.sObjectType.getDescribe().isDeletable()) delete delTsk;
        return null;
    }
    
    @AuraEnabled
    public static Transfer_Order__c save_TO(String TO) {
        ERP7__Transfer_Order__c currTO = (ERP7__Transfer_Order__c) JSON.deserialize(TO, ERP7__Transfer_Order__c.class);
        try {
            if(Schema.SObjectType.ERP7__Transfer_Order__c.isCreateable() && Schema.SObjectType.ERP7__Transfer_Order__c.isUpdateable()) upsert currTO;
        } catch (DMLException ex) { }
        return currTO;
    }
    
    public class comWrap {
        @AuraEnabled public ERP7__Project__c project                                    { get; set; }
        @AuraEnabled public List<milestoneWrap> milestones                              { get; set; }
        @AuraEnabled public Attachment Attachment                                       { get ; set; }
        
        public comWrap(ERP7__Project__c pjt, List<milestoneWrap> mst) {
            project = pjt;
            milestones = mst;
            Attachment = new Attachment();
        }
    }
    
    public class PMWP {
        
        @AuraEnabled public ERP7__Project__c project                                    { get; set; }
        @AuraEnabled public String errMsg                                               { get; set; }
        @AuraEnabled public boolean isCurrentP                                          { get; set; }
        @AuraEnabled public List < User > resourceList                                  { get; set; }
        
        
        @AuraEnabled public List<Integer> PNS                                        { get; set; }
        @AuraEnabled public Integer recSize                                          { get; set; }
        @AuraEnabled public Integer PageNum                                          { get; set; }
        
        public PMWP(ERP7__Project__c proj, List< User > resList, Integer total) {
            project = proj;
            isCurrentP = false;
            errMsg = '';
            resourceList = resList;
            
            PNS = new List<Integer>();
            recSize = total;
            PageNum = 0;
        }
        
    }
    
    public class milestoneWrap {
        @AuraEnabled public ERP7__Milestone__c milestone                                { get; set; }
        @AuraEnabled public String errMsg                                               { get; set; }
        @AuraEnabled public boolean isCurrentM                                          { get; set; }
        @AuraEnabled public List<ERP7__Actions_Tasks__c> TaskList                       { get; set; }
        @AuraEnabled public List < User > resourceGList                                 { get; set; }
        
        public milestoneWrap(ERP7__Milestone__c mile, List<ERP7__Actions_Tasks__c> tasks, List<User> resGroup) {
            milestone = mile;
            isCurrentM = false;
            errMsg = '';
            TaskList = tasks;
            resourceGList = resGroup;
        }
    }
}