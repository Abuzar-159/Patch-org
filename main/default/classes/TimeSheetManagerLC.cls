global with Sharing class TimeSheetManagerLC{
    @AuraEnabled
    global Decimal numTimesheetSub{ get; set; }

    @AuraEnabled
    global Decimal numTimesheetApp{ get; set; }

    @AuraEnabled
    global Decimal numTimesheetRej{ get; set; }

    @AuraEnabled
    global Set<Id> currentRecordId{ get; set; }

    @AuraEnabled
    global static list<Account> acc{ get; set; }

    @AuraEnabled
    global list<ERP7__Time_Card_Entry__c> TimeCardList{ get; set; }

    @AuraEnabled
    global ERP7__Timesheet__c TimeSheet{ get; set; }

    @AuraEnabled
    global Date d{ get; set; }

    @AuraEnabled
    global Date d1{ get; set; }

    @AuraEnabled
    global Date d2{ get; set; }

    @AuraEnabled
    global Date d3{ get; set; }

    @AuraEnabled
    global Date d4{ get; set; }

    @AuraEnabled
    global Date d5{ get; set; }

    @AuraEnabled
    global Date d6{ get; set; }

    @AuraEnabled
    global Date weekDate{ get; set; }

    @AuraEnabled
    global Boolean disable_D1{ get; set; }

    @AuraEnabled
    global String status{ get; set; }

    @AuraEnabled
    global static list<ERP7__Project__c> projectList{ get; set; }

    @AuraEnabled
    global static list<ERP7__Employee_Leave__c> empLeave{ get; set; }

    @AuraEnabled
    global static Map<Integer, Boolean> slotsMap{ get; set; }

    @AuraEnabled
    global Boolean check = true;
    @AuraEnabled
    global static TimeSheetManagerLC TimeSheet_ManagerLC(String nodays, String dateChange){

        if (String.isEmpty(nodays))
            nodays = '0';
        slotsMap = new Map<Integer, Boolean>();
        TimeSheetManagerLC timeDate = new TimeSheetManagerLC();

        Date newDate = (String.isNotEmpty(dateChange)) ? Date.valueOf(dateChange).toStartofWeek() : System.Today().toStartofWeek();
        empLeave = new list<ERP7__Employee_Leave__c>();

        timeDate.d = newDate;
        timeDate.d1 = newDate + 1;
        timeDate.d2 = newDate + 2;
        timedate.d3 = newDate + 3;
        timedate.d4 = newDate + 4;
        timedate.d5 = newDate + 5;
        timedate.d6 = newDate + 6;
        return timeDate;
    }

    @AuraEnabled
    global static list<ERP7__Timesheet__c> getTimeSheets(String str, String eid, String strDate){
        return null;
    }

    @AuraEnabled
    global static list<Timesheet__c> getApprovedTimeSheets(String strDate){
        return null;
    }

    @AuraEnabled
    global static ERP7__Employees__c getEmployees(){
        Id userId = UserInfo.getUserId();
        if (!Schema.sObjectType.ERP7__Employees__c.isAccessible()){
            throw new System.NoAccessException(); //return null;
        } else{
            String[] employeesAccessFields = new String[]{ 'Id', 'Name', 'ERP7__Work_Status__c', 'ERP7__Social_Security_Number__c', 'ERP7__Marital_Status__c', 'ERP7__Last_Name__c', 'ERP7__Job_Title__c', 'ERP7__Organisation__c', 'ERP7__Organisation_Business_Unit__c', 'ERP7__Gender__c', 'ERP7__Employee_User__c', 'ERP7__ReportingManager__c', 'ERP7__Former_Employee__c' };
            Map<String, Schema.SObjectField> m = Schema.SObjectType.ERP7__Employees__c.fields.getMap();
            for (String fieldToCheck : employeesAccessFields){
                if (m.get(fieldToCheck) != null && !m.get(fieldToCheck).getDescribe().isAccessible()){
                    throw new System.NoAccessException(); //return null;
                }
            }
            return [Select Id, ERP7__Organisation__c, ERP7__Admin__c, ERP7__Organisation__r.ERP7__Start_of_Week__c, ERP7__Organisation__r.Name, ERP7__Organisation_Business_Unit__r.Name, ERP7__Organisation_Business_Unit__c, ERP7__Work_Status__c, ERP7__Social_Security_Number__c, ERP7__ReportingManager__c, Name, ERP7__Marital_Status__c, ERP7__Last_Name__c, ERP7__Job_Title__c, ERP7__Gender__c, ERP7__Former_Employee__c, ERP7__Former_Employee_Record__c, ERP7__First_Name__c, ERP7__Employment_End_Date__c, ERP7__Employee_User__c, ERP7__ReportingManager__r.ERP7__First_Name__c, ERP7__ReportingManager__r.ERP7__Last_Name__c, ERP7__ReportingManager__r.ERP7__Employee_User__c, ERP7__Employee_User__r.Manager.FirstName, ERP7__Employee_User__r.Manager.LastName, ERP7__Employee_User__r.ManagerId, ERP7__Employee_User__r.DelegatedApproverId
                    From ERP7__Employees__c
                    where ERP7__Employee_User__c = :userId
                    ORDER BY CREATEDDATE asc
                    limit 1];
        }
    }

    @AuraEnabled
    global static ERP7__Timesheet__c newTimesheet(){
        return null;
    }

    @AuraEnabled
    global static ERP7__Timesheet__c saveTimesheet(ERP7__Timesheet__c tSheet){
        try{
            if (Schema.SObjectType.ERP7__Timesheet__c.isCreateable() && Schema.SObjectType.ERP7__Timesheet__c.isUpdateable())
                upsert tSheet;
            else{
            }
            /*Id userId = UserInfo.getUserId();
             Id managerId;
             ERP7__Employees__c emp = new ERP7__Employees__c();
             emp = [Select Id, Name, ERP7__Employee_User__c From ERP7__Employees__c where ERP7__Employee_User__c =: userId limit 1];
             managerId = [Select Id, Name, ManagerId from User where Id =: emp.ERP7__Employee_User__c limit 1].ManagerId;

             //if(Schema.sObjectType.ERP7__Timesheet__c.isCreateable()&& Schema.sObjectType.ERP7__Timesheet__c.isUpdateable())

             if(managerId != null && tSheet.ERP7__Status__c == 'Submitted'){
             Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
             req.setComments('Submitted for approval. Please approve.');
             req.setNextApproverIds(new Id[] {managerId});
             req.setObjectId(tSheet.Id);
             req.setProcessDefinitionNameOrId('Timesheet_Submit_Approval');
             req.setSkipEntryCriteria(true);
             Approval.ProcessResult result = Approval.process(req);
             }*/
            if (tSheet != null)
                return tSheet;
        } catch (Exception e){
        }
        return null;
    }

    @AuraEnabled
    global static ERP7__Time_Card_Entry__c saveTimeCardEntry(ERP7__Time_Card_Entry__c tCardEntry){
        try{
            if (tCardEntry != null)
                if (Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable())
                    upsert tCardEntry;
                else{
                
            }
            return tCardEntry;
        } catch (Exception e){
            return null;
        }
    }

    @AuraEnabled
    public static List<selectOptions> getTCEStatus(){
        List<selectOptions> options = new List<selectOptions>();
        Schema.DescribeFieldResult fieldResult = ERP7__Time_Card_Entry__c.ERP7__Task__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple)
            options.add(new SelectOptions(f.getLabel(), f.getValue()));
        return options;
    }

    @AuraEnabled
    public static List<selectOptions> getActiStatus(){
        List<selectOptions> options = new List<selectOptions>();
        Schema.DescribeFieldResult fieldResult = ERP7__Time_Card_Entry__c.ERP7__Activity_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple)
            options.add(new SelectOptions(f.getLabel(), f.getValue()));
        return options;
    }

    @AuraEnabled
    public static List<selectOptions> getTimeStatus(){
        List<selectOptions> options = new List<selectOptions>();
        Schema.DescribeFieldResult fieldResult = ERP7__Timesheet__c.ERP7__Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f : ple)
            options.add(new SelectOptions(f.getLabel(), f.getValue()));
        return options;
    }

    @AuraEnabled
    public static List<Id> getProjectIds(){
        // Fetching the current user's Id using UserInfo.getUserId()
        Id currentUserId = UserInfo.getUserId();
        System.debug('currentUserId: ' + currentUserId);

        // Query for resources directly related to the current user and their team's projects
        List<ERP7__Resource__c> resources = [SELECT Id, ERP7__Team__r.ERP7__Project__c FROM ERP7__Resource__c WHERE ERP7__User__c = :currentUserId And ERP7__Start_Date__c <= TODAY And ERP7__End_Date__c >= TODAY];
        Set<Id> projectIds = new Set<Id>();
System.debug('Resources queried: ' + resources);

        // Extract project IDs directly from the queried resources
        for(ERP7__Resource__c resource : resources) {
            if(resource.ERP7__Team__r != null && resource.ERP7__Team__r.ERP7__Project__c != null) {
                projectIds.add(resource.ERP7__Team__r.ERP7__Project__c);
            }
        }
    System.debug('Project IDs retrieved: ' + projectIds);

    // Convert the set of projectIds to a list before returning
        return new List<Id>(projectIds);
    }

    @AuraEnabled 
    public static ERP7__Functionality_Control__c getFunctionalityControl(){
        ERP7__Functionality_Control__c FC=new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(FC == null){ 
            FC = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
        }
        if(FC != null){
            return FC;
        }
        return FC;
    } 

    @AuraEnabled
    global static ERP7__Time_Card_Entry__c saveTimeCardEntryUp(String tCardEntry){
        system.debug('tCardEntry-->' + tCardEntry);
        ERP7__Time_Card_Entry__c tCEntry = (ERP7__Time_Card_Entry__c)JSON.deserialize(tCardEntry, ERP7__Time_Card_Entry__c.class);
        system.debug('tCEntry-->' + tCEntry);
        try{
            if (tCEntry != null)
                if (Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable())
                    upsert tCEntry;
                else{
                
            }
            return tCEntry;
        } catch (Exception e){
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    global static Id deleteAccount(Id recordId){
        Id oldAccountId = null;
        try{
            if (ERP7__Timesheet__c.sObjectType.getDescribe().isDeletable())
                delete new ERP7__Timesheet__c(
                    Id = recordId
                );
            else{
            }
            oldAccountId = recordId;
        } catch (System.Exception caught){
        }

        return oldAccountId;
    }
    @AuraEnabled
    global static Id deletetimeCard(Id recordId, Id tsheetId){
        Id oldAccountId = null;
        try{
            /*if (ERP7__Time_Card_Entry__c.sObjectType.getDescribe().isDeletable())
                delete new ERP7__Time_Card_Entry__c(
                    Id = recordId
                );*/
            if (ERP7__Time_Card_Entry__c.sObjectType.getDescribe().isDeletable()){
                ERP7__Time_Card_Entry__c delEntry =[select id from ERP7__Time_Card_Entry__c where id=:recordId];
                delete delEntry;
                List<ERP7__Time_Card_Entry__c> otherentries =[select id , timesheet__c from ERP7__Time_Card_Entry__c where timesheet__c=: tsheetId];
                if(otherentries.isEmpty() && ERP7__Timesheet__c.sObjectType.getDescribe().isDeletable()) delete new ERP7__Timesheet__c(
                    Id = tsheetId
                );
                return recordId;
            }
            else{
            }
            oldAccountId = recordId;
        } catch (System.Exception caught){
        }

        return oldAccountId;
    }

    @AuraEnabled
    global static Id deleteTcardEntry(Id recordId){
        Id oldAccountId = null;
        try{
            if (ERP7__Time_Card_Entry__c.sObjectType.getDescribe().isDeletable())
                delete new ERP7__Time_Card_Entry__c(
                    Id = recordId
                );
            else{
            }
            oldAccountId = recordId;
        } catch (System.Exception caught){
        }
        return oldAccountId;
    }

    @AuraEnabled
    global static ERP7__Timesheet__c getAccount(Id recordId){
        return null;
    }

    @AuraEnabled
    global static Id saveAccount(ERP7__Timesheet__c newAccount){
        return null;
    }

    @AuraEnabled
    global static list<ERP7__Timesheet__c> getSheet(){
        return null;
    }

    @AuraEnabled
    global static list<ERP7__Timesheet__c> getSheetApproved(){
        return null;
    }

    @AuraEnabled
    global static TimeSheetManagerLC EditTimesheet(String strId){
        TimeSheetManagerLC temp = new TimeSheetManagerLC();
        String[] timefieldsAccessFields = new String[]{ 'Id', 'Name', 'ERP7__Project__c', 'ERP7__Week_Date__c', 'ERP7__Start_Date__c', 'ERP7__End_Date__c', 'ERP7__Employees__c', 'ERP7__Approver__c', 'ERP7__Status__c' };
        Map<String, Schema.SObjectField> m = Schema.SObjectType.ERP7__Timesheet__c.fields.getMap();
        for (String fieldToCheck : timefieldsAccessFields){
            if (!m.get(fieldToCheck).getDescribe().isAccessible()){
                throw new System.NoAccessException(); //return null;
            }
        }

        temp.Timesheet = (String.isNotEmpty(strId)) ? [SELECT id, Name, ERP7__Week_Date__c, ERP7__Project__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Employees__r.ERP7__First_Name__c, ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Status__c
                                                       FROM ERP7__Timesheet__c
                                                       where Id = :strId] : new ERP7__Timesheet__c();

        String[] timecardfieldsAccessFields = new String[]{ 'Id', 'Name', 'ERP7__Timesheet__c', 'ERP7__Project__c', 'ERP7__Schedule__c', 'ERP7__Task__c', 'ERP7__Activity_Status__c', 'ERP7__Activity_Risk__c', 'ERP7__Week_Day_1__c', 'ERP7__Week_Day_2__c', 'ERP7__Week_Day_3__c', 'ERP7__Week_Day_4__c', 'ERP7__Week_Day_5__c', 'ERP7__Week_Day_6__c', 'ERP7__Week_Day_7__c', 'ERP7__Week_Day_1_Comment__c', 'ERP7__Week_Day_2_Comment__c', 'ERP7__Week_Day_3_Comment__c', 'ERP7__Week_Day_4_Comment__c', 'ERP7__Week_Day_5_Comment__c', 'ERP7__Week_Day_6_Comment__c', 'ERP7__Week_Day_7_Comment__c', 'ERP7__Week_Day_1_Hours__c', 'ERP7__Week_Day_2_Hours__c', 'ERP7__Week_Day_3_Hours__c', 'ERP7__Week_Day_4_Hours__c', 'ERP7__Week_Day_5_Hours__c', 'ERP7__Week_Day_6_Hours__c', 'ERP7__Week_Day_7_Hours__c', 'ERP7__Week_Day_7_Hours__c', 'ERP7__Week_Day_7_Hours__c', 'ERP7__Week_Day_7_Hours__c' };
        Map<String, Schema.SObjectField> n = Schema.SObjectType.ERP7__Time_Card_Entry__c.fields.getMap();
        for (String fieldToCheck : timecardfieldsAccessFields){
            if (!n.get(fieldToCheck).getDescribe().isAccessible()){
                throw new System.NoAccessException(); //return null;
            }
        }

        temp.TimeCardList = (String.isNotEmpty(strId)) ? [SELECT Id, Name, ERP7__Timesheet__r.Name, ERP7__Project__c, ERP7__Schedule__c, ERP7__Task__c, ERP7__Activity_Status__c, ERP7__Activity_Risk__c, ERP7__Week_Day_1__c, ERP7__Week_Day_1_Comment__c, ERP7__Week_Day_1_Hours__c, ERP7__Week_Day_2__c, ERP7__Week_Day_2_Comment__c, ERP7__Week_Day_2_Hours__c, ERP7__Week_Day_3__c, ERP7__Week_Day_3_Comment__c, ERP7__Week_Day_3_Hours__c, ERP7__Week_Day_4__c, ERP7__Week_Day_4_Comment__c, ERP7__Week_Day_4_Hours__c, ERP7__Week_Day_5__c, ERP7__Week_Day_5_Comment__c, ERP7__Week_Day_5_Hours__c, ERP7__Week_Day_6__c, ERP7__Week_Day_6_Comment__c, ERP7__Week_Day_6_Hours__c, ERP7__Week_Day_7__c, ERP7__Week_Day_7_Comment__c, ERP7__Week_Day_7_Hours__c, ERP7__Selected_Date__c
                                                          FROM ERP7__Time_Card_Entry__c
                                                          where ERP7__Timesheet__c = :strId
                                                          ORDER BY ERP7__Week_Day_1__c asc] : new List<ERP7__Time_Card_Entry__c>();
        return temp;
    }

    @AuraEnabled
    global static list<ERP7__Timesheet__c> getApproval(){
        return null;
    }

    @AuraEnabled
    global static void arTimesheet(String reason, String tid, String sts){
        string[] alltid = tid.split(',');
        list<ERP7__Timesheet__c> listts = new list<ERP7__Timesheet__c>();
        for (String s : alltid){
            ERP7__Timesheet__c ts = new ERP7__Timesheet__c(
                id = (ID) s
            );
            if (Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Approve_Rejected_Reason__c.isUpdateable())
                ts.ERP7__Approve_Rejected_Reason__c = reason;
            if (Schema.sObjectType.ERP7__Timesheet__c.fields.ERP7__Status__c.isUpdateable())
                ts.ERP7__Status__c = sts;
            listts.add(ts);
        }
        if (Schema.SObjectType.ERP7__Timesheet__c.isUpdateable()){
            update listts;
        } else{
            /*Not allowed to update*/
        }
    }

    @AuraEnabled
    global static ERP7__Time_Card_Entry__c initializeTimeCardEntry(){
        return new ERP7__Time_Card_Entry__c();
    }

    @AuraEnabled
    global static ERP7__Timesheet__c initializeToTimeSheets(string newDay){
        Date d = system.today().toStartOfWeek();
        if (String.isNotEmpty(newDay))
            d = d.adddays(Integer.valueOf(newDay));
        return new ERP7__Timesheet__c(
            ERP7__Week_Date__c = d
        );
    }

    @AuraEnabled
    global static String getCurrentValue(String type, String value){
        try{
            if (String.isBlank(type) ){
                return null;
            }

            ID lookupId = null;
            try{
                if (value instanceof Id)
                    lookupId = (ID) value;
            } catch (Exception e){
                return null;
            }

            if (String.isBlank(lookupId)){
                return null;
            }

            SObjectType objType = Schema.getGlobalDescribe().get(type);
            if (objType == null){
                return null;
            }

            String nameField = getSobjectNameField(objType);
            String query = 'Select Id, ' + String.escapeSingleQuotes(nameField) + ' From ' + String.escapeSingleQuotes(type) +' Where Id = \'' + String.escapeSingleQuotes(lookupId) + '\'';
            List<SObject> oList = Database.query(query);
            if (oList.size() == 0){
                return null;
            }
            return String.valueOf(oList[0].get(nameField));//.escapeHTML4();
        } catch (Exception e){
            return null;
        }
    }

    @AuraEnabled
    global static String get_CurrentValue(String type, String value, String SearchField){
        try{
            if (String.isBlank(type) ){
                return null;
            }

            ID lookupId = null;
            try{
                lookupId = (ID) value;
            } catch (Exception e){
                return null;
            }

            if (String.isBlank(lookupId)){
                return null;
            }

            SObjectType objType = Schema.getGlobalDescribe().get(type);
            if (objType == null){
                return null;
            }

            String nameField = getSobjectNameField(objType);
            String where_filter = (String.isBlank(SearchField)) ? 'Id ' : SearchField;
            SearchField = (String.isBlank(SearchField)) ? nameField : SearchField;
            String query = 'Select Id, ' + String.escapeSingleQuotes(SearchField) + ' From ' + String.escapeSingleQuotes(type) +' Where Id = \'' + String.escapeSingleQuotes(lookupId) + '\'';
            List<SObject> oList = Database.query(query);
            if (oList.size() == 0){
                return null;
            }
            return String.valueOf(oList[0].get(SearchField));
        } catch (Exception e){
            return null;
        }
    }

    global class SearchResult{
        global String value{ get; Set; }

        global String id{ get; set; }

    }

    private static String getSobjectNameField(SobjectType sobjType){

        String nameField = 'Name';
        Schema.DescribeSObjectResult dfrLkp = sobjType.getDescribe();
        for (schema.SObjectField sotype : dfrLkp.fields.getMap().values()){
            Schema.DescribeFieldResult fieldDescObj = sotype.getDescribe();
            if (fieldDescObj.isNameField()){
                nameField = fieldDescObj.getName();
                break;
            }
        }
        return nameField;
    }

    @AuraEnabled
    public static String search_SObject_Custom(String type, String searchString, String queryFilter, String SearchField){

        if (String.isBlank(type)  || String.isBlank(searchString)){
            return null;
        }

        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if (objType == null){
            return null;
        }

        String nameField = getSobjectNameField(objType);
        SearchField = String.isBlank(SearchField) ? nameField : SearchField;
        searchString = '\'*' + searchString + '*\'';
        String query_filter = (queryFilter != null) ? queryFilter : '';
        String soslQuery = 'FIND :searchString IN ALL FIELDS RETURNING ' + 
                         String.escapeSingleQuotes(type) +'(Id, ' + String.escapeSingleQuotes(SearchField) + ' ' + String.escapeSingleQuotes(query_filter) + ' ORDER BY ' + String.escapeSingleQuotes(SearchField) + ') LIMIT 20';
        List<List<SObject>> results = Search.query(soslQuery);

        List<SearchResult> output = new List<SearchResult>();
        if (results.size() > 0){
            for (SObject sobj : results[0]){
                SearchResult sr = new SearchResult();
                sr.id = (String) sobj.get('Id');
                sr.value = (String) sobj.get(SearchField);
                output.add(sr);
            }
        }
        return JSON.serialize(output);
    }

    @AuraEnabled
    global static String searchSObject(String type, String searchString){
        if (String.isBlank(type)  || String.isBlank(searchString)){
            return null;
        }

        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if (objType == null){
            return null;
        }

        String nameField = getSobjectNameField(objType);
        searchString = '\'*' + searchString + '*\'';
        String soslQuery = 'FIND :searchString IN NAME FIELDS RETURNING ' + 
                         String.escapeSingleQuotes(type) +'(Id, ' + String.escapeSingleQuotes(nameField) + ' ORDER BY ' + String.escapeSingleQuotes(nameField) + ') LIMIT 20';
        List<List<SObject>> results = Search.query(soslQuery);

        List<SearchResult> output = new List<SearchResult>();
        if (results.size() > 0){
            for (SObject sobj : results[0]){
                SearchResult sr = new SearchResult();
                sr.id = (String) sobj.get('Id');
                sr.value = (String) sobj.get(nameField);
                output.add(sr);
            }
        }
        return JSON.serialize(output);
    }

    @AuraEnabled
    global static String search_SObject(String type, String searchString, String queryFilter){
        if (String.isBlank(type)  || String.isBlank(searchString)){
            return null;
        }

        SObjectType objType = Schema.getGlobalDescribe().get(type);
        if (objType == null){
            return null;
        }

        String nameField = getSobjectNameField(objType);
        searchString = '\'*' + searchString + '*\'';
        String query_filter = (queryFilter != null) ? queryFilter : '';
        String soslQuery = 'FIND :searchString IN NAME FIELDS RETURNING ' + 
                         String.escapeSingleQuotes(type) +'(Id, ' + String.escapeSingleQuotes(nameField) + ' ' + String.escapeSingleQuotes(query_filter) + ' ORDER BY ' + String.escapeSingleQuotes(nameField) + ') LIMIT 20';
        List<List<SObject>> results = Search.query(soslQuery);

        List<SearchResult> output = new List<SearchResult>();
        if (results.size() > 0){
            for (SObject sobj : results[0]){
                SearchResult sr = new SearchResult();
                sr.id = (String) sobj.get('Id');
                sr.value = (String) sobj.get(nameField);
                output.add(sr);
            }
        }
        return JSON.serialize(output);
    }

    @AuraEnabled
    global static TimeSheetManagerLC GetRecordCounts(String strDate){
        TimeSheetManagerLC result;
        String SQueryS;
        String SQueryA;
        String SQueryR;
        if (strDate == '' || strDate == null)
            strDate = '=NULL';
        else
            strDate = '=' + strDate;
        if (!Schema.sObjectType.ERP7__Time_Card_Entry__c.isAccessible()){
            throw new System.NoAccessException(); //return null;
        } else{
            String[] timecardfieldsAccessFields = new String[]{ 'Id', 'Name', 'ERP7__Total_Hours__c' };
            Map<String, Schema.SObjectField> m = Schema.SObjectType.ERP7__Time_Card_Entry__c.fields.getMap();
            for (String fieldToCheck : timecardfieldsAccessFields){
                if (m.get(fieldToCheck) != null && !m.get(fieldToCheck).getDescribe().isAccessible()){
                    throw new System.NoAccessException(); //return null;
                }
            }
            result = new TimeSheetManagerLC();
            SQueryS = 'select Sum(ERP7__Working_Minutes__c) num1' + 
                     ' from ERP7__Time_Card_Entry__c where ERP7__Timesheet__r.ERP7__Status__c = \'Submitted\' and ERP7__Timesheet__r.ERP7__Week_Date__c ' + String.escapeSingleQuotes(strDate) + 
                     ' and Timesheet__r.Employees__r.Employee_User__c =\'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\'';
            System.debug('SQueryS ' + SQueryS);
            aggregateResult temp1 = Database.query(SQueryS);
            if (temp1.get('num1') == null)
                result.numTimesheetSub = 0.00;
            else
                result.numTimesheetSub = double.valueOf(temp1.get('num1'));
            SQueryA = 'select Sum(ERP7__Approve_Minutes__c) num2' + 
                     ' from ERP7__Time_Card_Entry__c where ERP7__Timesheet__r.ERP7__Status__c = \'Approved\' and ERP7__Timesheet__r.ERP7__Week_Date__c ' + String.escapeSingleQuotes(strDate) + 
                     ' and Timesheet__r.Employees__r.Employee_User__c =\'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\'';
            aggregateResult temp2 = Database.query(SQueryA);
            if (temp2.get('num2') == null){
                result.numTimesheetApp = 0.00;
            } else{
                result.numTimesheetApp = double.valueOf(temp2.get('num2'));
            }
            SQueryR = 'select Sum(ERP7__Working_Minutes__c) num3' + 
                     ' from ERP7__Time_Card_Entry__c where ERP7__Timesheet__r.ERP7__Status__c = \'Rejected\' and ERP7__Timesheet__r.ERP7__Week_Date__c ' + String.escapeSingleQuotes(strDate) + 
                     ' and Timesheet__r.Employees__r.Employee_User__c =\'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\'';
            aggregateResult temp3 = Database.query(SQueryR);
            if (temp3.get('num3') == null){
                result.numTimesheetRej = 0.00;
            } else{
                result.numTimesheetRej = double.valueOf(temp3.get('num3'));
            }
            return result;
        }
    }

    @AuraEnabled
    public static list<TimeSheetManagerLC> getTimeLogs(String startDate, String endDate){
        List<TimeSheetManagerLC> TSwrpList = new List<TimeSheetManagerLC>();
        List<ERP7__Timesheet__c> tmSheets = new List<ERP7__Timesheet__c>();
        List<ERP7__Time_Card_Entry__c> timeCards = new List<ERP7__Time_Card_Entry__c>();
        String TCqry = 'SELECT Id, Name, ERP7__Week_Day_1__c, ERP7__Week_Day_1_Comment__c, ERP7__Working_Minutes__c, ERP7__Activity_Status__c, ERP7__Schedule__c, ERP7__Schedule__r.ERP7__Project__c, ERP7__Task__c, ERP7__Activity_Risk__c, ERP7__Timesheet__c, ERP7__Total_Hours__c, ERP7__Department__c, ERP7__Programme__c';
        TCqry += ' FROM ERP7__Time_Card_Entry__c where ERP7__Timesheet__c != null and ERP7__Week_Day_1__c >= ' + String.escapeSingleQuotes(startDate) + ' AND ERP7__Week_Day_1__c <= ' + String.escapeSingleQuotes(endDate) + ' and ERP7__Timesheet__r.ERP7__Status__c != \'Approved\' and ERP7__Timesheet__r.ERP7__Status__c != \'Submitted\' and ERP7__Timesheet__r.ERP7__Status__c != \'Rejected\' and ERP7__Timesheet__r.ERP7__Employees__r.ERP7__Employee_User__c = \'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\'';
        System.debug('TCqry' + TCqry);
        timeCards = database.query(TCqry);
        set<Id> tsIds = new set<Id>();
        for (ERP7__Time_Card_Entry__c TC : timeCards){
            tsIds.add(TC.ERP7__Timesheet__c);
        }

        Date parsedEndDate = Date.valueOf(endDate);
        Date parsedStartDate = Date.valueOf(startDate);
        tmSheets = [SELECT id, Name, ERP7__Week_Date__c, ERP7__Project__c, ERP7__Approved_Minutes__c, ERP7__Submitted_Minutes__c, ERP7__Project__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Employees__r.ERP7__First_Name__c, ERP7__Approver__r.Name, ERP7__Status__c, ERP7__Total_Hours__c
                    FROM ERP7__Timesheet__c
                    where ERP7__Status__c != 'Approved' And ERP7__Status__c != 'Submitted' And ERP7__Status__c != 'Rejected' And ERP7__Employees__r.ERP7__Employee_User__c = :UserInfo.getUserId() And (Id IN:tsIds OR ((CALENDAR_MONTH(ERP7__Week_Date__c) = :parsedStartDate.month() And CALENDAR_YEAR(ERP7__Week_Date__c) = :parsedStartDate.year()) OR (CALENDAR_MONTH(ERP7__Week_Date__c) = :parsedEndDate.month() And CALENDAR_YEAR(ERP7__Week_Date__c) = :parsedEndDate.year())))];
        System.debug('tmSheets ' + tmSheets);
        for (ERP7__Timesheet__c TS : tmSheets){
            TimeSheetManagerLC TSwrp = new TimeSheetManagerLC();
            List<ERP7__Time_Card_Entry__c> TS_tceList = new List<ERP7__Time_Card_Entry__c>();
            for (ERP7__Time_Card_Entry__c TCE : timeCards){
                if (TCE.ERP7__Timesheet__c == TS.Id){
                    TS_tceList.add(TCE);
                }
            }
            TSwrp.Timesheet = TS;
            TSwrp.TimeCardList = (TS_tceList.size() > 0) ? TS_tceList : new List<ERP7__Time_Card_Entry__c>();
            TSwrpList.add(TSwrp);
        }
        return TSwrpList;
    }

    @AuraEnabled
    public static list<ERP7__Timesheet__c> getDrafSubTimeCards(String FiscalYear){
        try{
            List<ERP7__Timesheet__c> tmSheets = new List<ERP7__Timesheet__c>();
            String selectedFY = (FiscalYear == '' || FiscalYear == null) ? '!=THIS_FISCAL_YEAR' : '=' + FiscalYear;
            String TSqry = 'SELECT id, Name, ERP7__Week_Date__c, ERP7__Approved_Minutes__c, ERP7__Submitted_Minutes__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c,';
            TSqry += ' ERP7__Employees__r.ERP7__First_Name__c, ERP7__Approver__r.Name, ERP7__Status__c, ERP7__Total_Hours__c';
            TSqry += ' FROM ERP7__Timesheet__c where ERP7__Week_Date__c' + String.escapeSingleQuotes(selectedFY);
            TSqry += ' and ERP7__Status__c != \'Approved\' and ERP7__Status__c != \'Rejected\' ';
            TSqry += ' and ERP7__Employees__r.ERP7__Employee_User__c = \'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\' ORDER by ERP7__Week_Date__c asc';
            tmSheets = database.query(TSqry);
            return tmSheets;
        } catch (Exception e){
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static ERP7__Time_Card_Entry__c saveTimeLogs(ERP7__Timesheet__c tSheet, ERP7__Time_Card_Entry__c tCardEntry){
        try{
            System.debug('tSheet' + tSheet);
            System.debug('tCardEntry' + tCardEntry);
            if (Schema.SObjectType.ERP7__Timesheet__c.isCreateable() && Schema.SObjectType.ERP7__Timesheet__c.isUpdateable())
                upsert tSheet;
            else{
            }
            if (tCardEntry != null)
                tCardEntry.ERP7__Timesheet__c = tSheet.Id;
            if (Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable())
                upsert tCardEntry;
            else{
            }

            System.debug('tCardEntry' + tCardEntry);
            if (tCardEntry != null)
                return tCardEntry;
        } catch (Exception e){
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static String saveSheetandTimeCards(ERP7__Timesheet__c tSheet, String tCardList, String ApprovalType){
        String error = null;
        system.debug('saveSheetandTimeCards');
        try{
            List<ERP7__Time_Card_Entry__c> tCardEntry = (List<ERP7__Time_Card_Entry__c>)JSON.deserialize(tCardList, List<ERP7__Time_Card_Entry__c>.class);
            if (ApprovalType == 'Submitted')
                tSheet.ERP7__Status__c = 'Submitted';
            if (Schema.SObjectType.ERP7__Timesheet__c.isCreateable() && Schema.SObjectType.ERP7__Timesheet__c.isUpdateable())
                upsert tSheet;
            else{
            }
            List<ERP7__Time_Card_Entry__c> TCEList = new List<ERP7__Time_Card_Entry__c>();
            for (ERP7__Time_Card_Entry__c TCE : tCardEntry){
                TCE.ERP7__Timesheet__c = tSheet.Id;
                TCEList.add(TCE);
            }
            System.debug('tSheet'+tSheet);
            system.debug('TCElist--->' + TCEList);
            if (Schema.sObjectType.ERP7__Time_Card_Entry__c.isCreateable() && Schema.sObjectType.ERP7__Time_Card_Entry__c.isUpdateable())
                upsert TCEList;
            else{
            }

            if (ApprovalType == 'Submitted'){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please review and approve.');
                req.setObjectId(tSheet.Id);
                req.setNextApproverIds(new Id[]{ tSheet.ERP7__Approver__c });
                Approval.ProcessResult result = Approval.process(req);
            } else{
                Id workItemId;
                List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :tSheet.Id And ProcessInstance.Status = 'Pending' LIMIT 1];

                if (!workItems.isEmpty()){ workItemId = workItems[0].Id; }
                    
                if (ApprovalType == 'Approved' && !workItems.isEmpty()){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkItemID(workItemId);
                    req.setComments('Request Approved by User: ' + userInfo.getName());
                    req.setAction('Approve');
                    Approval.ProcessResult result =  Approval.process(req);
                } else if (ApprovalType == 'Rejected' && !workItems.isEmpty()){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkItemID(workItemId);
                    req.setComments('Request Rejected by User: ' + userInfo.getName());
                    req.setAction('Reject');
                    Approval.ProcessResult result =  Approval.process(req);
                }
            }
            return error;
        } catch (Exception e){
            error = String.valueOf(e);
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
            return error;
        }
    }

    @AuraEnabled
    public static list<ERP7__Timesheet__c> getSheetsApproved(String FiscalYearApproved){
        try{
            String selectedFY = (FiscalYearApproved == '' || FiscalYearApproved == null) ? '!=THIS_FISCAL_YEAR' : '=' + FiscalYearApproved;
            List<ERP7__Timesheet__c> tmSheets = new List<ERP7__Timesheet__c>();
            set<Id> tsIds = new set<Id>();
            String TSqry = 'SELECT id, Name, ERP7__Week_Date__c, ERP7__Approved_Minutes__c, ERP7__Submitted_Minutes__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c,';
            TSqry += ' ERP7__Employees__r.ERP7__First_Name__c, ERP7__Approver__r.Name, ERP7__Status__c, ERP7__Total_Hours__c';
            TSqry += ' FROM ERP7__Timesheet__c where ERP7__Week_Date__c' + String.escapeSingleQuotes(selectedFY);
            TSqry += ' and ERP7__Approver__c != null and (ERP7__Status__c = \'Approved\' or ERP7__Status__c = \'Rejected\') ';
            TSqry += ' and ERP7__Employees__r.ERP7__Employee_User__c = \'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\' ORDER by ERP7__Week_Date__c asc';
            tmSheets = database.query(TSqry);
            return tmSheets;
        } catch (Exception e){
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static TimeSheetManagerLC getSheetandTimeCards(String TimeSheetId){
        TimeSheetManagerLC TSwrp = new TimeSheetManagerLC();
        try{
            TimeSheetManagerLC TSwrpList = new TimeSheetManagerLC();
            List<ERP7__Timesheet__c> tmSheets = [SELECT id, Name, ERP7__Week_Date__c, ERP7__Approved_Minutes__c, ERP7__Submitted_Minutes__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Employees__r.ERP7__First_Name__c, ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Status__c, ERP7__Total_Hours__c
                                                 FROM ERP7__Timesheet__c
                                                 where Id = :TimeSheetId];

            List<ERP7__Time_Card_Entry__c> timeCards = [SELECT Id, Name, ERP7__Week_Day_1__c, ERP7__Week_Day_1_Comment__c, ERP7__Working_Minutes__c, ERP7__Approve_Minutes__c, ERP7__Activity_Status__c, ERP7__Schedule__c, ERP7__Schedule__r.ERP7__Project__c, ERP7__Task__c, ERP7__Activity_Risk__c, ERP7__Timesheet__c, ERP7__Total_Hours__c, ERP7__Department__c, ERP7__Programme__c
                                                        FROM ERP7__Time_Card_Entry__c
                                                        where ERP7__Timesheet__c = :TimeSheetId
                                                        ORDER BY ERP7__Week_Day_1__c asc];
            TSwrp.Timesheet = tmSheets[0];
            TSwrp.TimeCardList = timeCards;
            return TSwrp;
        } catch (Exception e){
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static list<ERP7__Timesheet__c> getSheetsToApprove(){
        try{
            List<ERP7__Timesheet__c> tmSheets = [SELECT id, Name, ERP7__Week_Date__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Approved_Minutes__c, ERP7__Submitted_Minutes__c, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Employees__r.Name, ERP7__Employees__r.ERP7__First_Name__c, ERP7__Employees__r.ERP7__Last_Name__c, ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Status__c, ERP7__Employees__r.ERP7__ReportingManager__c, ERP7__Employees__r.ERP7__Employee_User__c, ERP7__Employees__r.ERP7__Employee_User__r.Name, ERP7__Total_Hours__c, ERP7__Employees__c
                                                 FROM ERP7__Timesheet__c
                                                 where ERP7__Approver__c = :userinfo.getUserId() And ERP7__Status__c = 'Submitted'
                                                 ORDER by ERP7__Week_Date__c asc];

            return tmSheets;
        } catch (Exception e){
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static list<ERP7__Timesheet__c> getAllTimeSheets(String FiscalYearApproved, String EmployeeId){
        try{
            String selectedFY = (FiscalYearApproved == '' || FiscalYearApproved == null) ? '!=THIS_FISCAL_YEAR' : '=' + FiscalYearApproved;
            List<ERP7__Timesheet__c> tmSheets = new List<ERP7__Timesheet__c>();
            set<Id> tsIds = new set<Id>();
            String TSqry = 'SELECT id, Name, ERP7__Week_Date__c, ERP7__Approved_Minutes__c, ERP7__Submitted_Minutes__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c,';
            TSqry += ' ERP7__Employees__r.ERP7__First_Name__c, ERP7__Approver__r.Name, ERP7__Status__c, ERP7__Total_Hours__c';
            TSqry += ' FROM ERP7__Timesheet__c where ERP7__Week_Date__c' + String.escapeSingleQuotes(selectedFY) + ' And ERP7__Employees__c=\''+String.escapeSingleQuotes(EmployeeId)+'\' ORDER by ERP7__Week_Date__c asc';
            System.debug(TSqry);
            tmSheets = database.query(TSqry);
            return tmSheets;
        } catch (Exception e){
            system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            //return null;
        }
    }

    @AuraEnabled
    public static list<TimeSheetManagerLC> getSheetsandTimeCardsToApprove(){
        List<TimeSheetManagerLC> TSwrpList = new List<TimeSheetManagerLC>();
        List<ERP7__Timesheet__c> tmSheets = new List<ERP7__Timesheet__c>();
        List<ERP7__Time_Card_Entry__c> timeCards = new List<ERP7__Time_Card_Entry__c>();
        set<Id> tsIds = new set<Id>();

        tmSheets = [SELECT id, Name, ERP7__Week_Date__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Start_Date__c, ERP7__End_Date__c, ERP7__Employees__r.ERP7__First_Name__c, ERP7__Employees__r.ERP7__Last_Name__c, ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Status__c, ERP7__Employees__r.ERP7__ReportingManager__c, ERP7__Employees__r.ERP7__Employee_User__c, ERP7__Employees__r.ERP7__Employee_User__r.Name, ERP7__Total_Hours__c, ERP7__Employees__c
                    FROM ERP7__Timesheet__c
                    where ERP7__Approver__c = :userinfo.getUserId() And ERP7__Status__c = 'Submitted'
                    ORDER by ERP7__Week_Date__c asc];
        for (ERP7__Timesheet__c TS : tmSheets){
            tsIds.add(TS.Id);
        }
        if (tsIds.size() > 0){
            timeCards = [SELECT Id, Name, ERP7__Week_Day_1__c, ERP7__Week_Day_1_Comment__c, ERP7__Working_Minutes__c, ERP7__Approve_Minutes__c, ERP7__Activity_Status__c, ERP7__Schedule__c, ERP7__Schedule__r.ERP7__Project__c, ERP7__Task__c, ERP7__Activity_Risk__c, ERP7__Timesheet__c, ERP7__Total_Hours__c, ERP7__Department__c, ERP7__Programme__c
                         FROM ERP7__Time_Card_Entry__c
                         where ERP7__Timesheet__c = :tsIds
                         ORDER BY ERP7__Week_Day_1__c asc];
            for (ERP7__Timesheet__c TS : tmSheets){
                TimeSheetManagerLC TSwrp = new TimeSheetManagerLC();
                List<ERP7__Time_Card_Entry__c> TS_tceList = new List<ERP7__Time_Card_Entry__c>();
                for (ERP7__Time_Card_Entry__c TCE : timeCards){
                    if (TCE.ERP7__Timesheet__c == TS.Id){
                        TS_tceList.add(TCE);
                    }
                }
                TSwrp.Timesheet = TS;
                TSwrp.TimeCardList = (TS_tceList.size() > 0) ? TS_tceList : new List<ERP7__Time_Card_Entry__c>();
                TSwrpList.add(TSwrp);
            }
        }
        return TSwrpList;
    }

    public class selectOptions{
        @AuraEnabled
        public String label{ get; set; }

        @AuraEnabled
        public String value{ get; set; }

        public selectOptions(String lab, string val){
            label = lab;
            value = val;
        }

    }
    @AuraEnabled
    public static ERP7__Employees__c getManagerId(String Employees){
        try{System.debug('Inside getManagerId');
            String mangId='';
            ERP7__Employees__c userRec = new ERP7__Employees__c();
            if (Employees != null){
                System.debug('Inside if');
                userRec= [Select Id, ERP7__Employee_User__c, ERP7__Employee_User__r.ManagerId,ERP7__Employee_User__r.DelegatedApproverId from ERP7__Employees__c where Id =: Employees limit 1];
                System.debug('ManagerId-->' + userRec.ERP7__Employee_User__r.ManagerId);
                if(userRec.ERP7__Employee_User__r.ManagerId != null )mangId= userRec.ERP7__Employee_User__r.ManagerId;
            }
            return userRec;
        } catch (Exception e){
            System.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            return null;
        }
    } 
    @AuraEnabled
    public static List<ERP7__Time_Card_Entry__c> getTimeCardItems(String tSheetId){
        List<ERP7__Time_Card_Entry__c> timeCards = new List<ERP7__Time_Card_Entry__c>();
        try{ timeCards = [SELECT Id, Name, ERP7__Timesheet__c, ERP7__Working_Minutes__c, ERP7__Approve_Minutes__c, ERP7__Activity_Status__c, ERP7__Schedule__c, ERP7__Schedule__r.ERP7__Project__c, ERP7__Task__c, ERP7__Activity_Risk__c, ERP7__Total_Hours__c, ERP7__Department__c, ERP7__Programme__c
                         FROM ERP7__Time_Card_Entry__c
                         where ERP7__Timesheet__c = :tSheetId];
            return timeCards;
            
        }catch (Exception e){
            System.debug('Exception-->' + e + e.getMessage() + e.getLineNumber());
            return null;
        }
    }

}