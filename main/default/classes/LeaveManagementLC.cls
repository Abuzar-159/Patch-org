public with sharing class LeaveManagementLC {
    
    @AuraEnabled
    public Decimal numTimeOff     { get; set; }
    @AuraEnabled
    public Decimal numStatus      { get; set; }
    @AuraEnabled
    public Decimal NumHolidays    { get; set; }
    @AuraEnabled
    public Decimal numAvailable   { get; set; }
    
     @auraEnabled
    public static void saveEmployee(ERP7__Employees__c emp){
        try{
            /*if(Schema.SObjectType.Employees__c.isCreateable() && Schema.sObjectType.Employees__c.isUpdateable()){upsert emp;}*/
            upsert emp;
        }catch(Exception e){
            System.debug('error --> '+e);
        } 
    }
    
    @AuraEnabled
    public static ERP7__Employees__c getEmployeeDetails(String EmpId) {
        System.debug('EmpId is' + EmpId);
        ERP7__Employees__c empReturn1;
        
        empReturn1 = [
            SELECT 
            Id,
            ERP7__Last_Name__c,
            ERP7__First_Name__c,
            ERP7__First_Working_Day__c,
            ERP7__Gender__c,
            ERP7__Marital_Status__c,
            Name,
            ERP7__Organisation__c,
            ERP7__Organisation_Business_Unit__c,
            ERP7__Employee_Profiling__r.ERP7__Leave_Entitlement__c,
            ERP7__Employee_Profiling__r.ERP7__Leave_Entitlement__r.ERP7__Leave_Entitlements_Holidays__r.ERP7__Leaves_Taken__c,
            ERP7__Employee_User__c,
            ERP7__Admin__c,
            ERP7__Annual_Leave_Available__c,
            ERP7__Annual_Leave_Booked__c,
            ERP7__Casual_Leave_Available__c,
            ERP7__Casual_Leave_Boooked__c,
            ERP7__Sick_Leave_Available__c,
            ERP7__Sick_Leave_Booked__c,
            ERP7__Paternity_Leave_Avaiable__c,
            ERP7__Paternity_Leave_Booked__c,
            ERP7__Earned_Leave_Available__c,
            ERP7__Earned_Leave_Booked__c,
            ERP7__Active__c,
            ERP7__Employment_Status__c,
            ERP7__Phone__c,
            ERP7__Job_Title__c,
            ERP7__Email__c,
            ERP7__Employee_User__r.ManagerId,
            ERP7__Employee_User__r.Name,
            ERP7__ReportingManager__c,
            ERP7__ReportingManager__r.Id,
            ERP7__ReportingManager__r.Name,
            ERP7__Address__c
            FROM ERP7__Employees__c 
            WHERE Id = :EmpId 
            LIMIT 1
        ];
        
        System.debug('man obj ' + empReturn1.ERP7__ReportingManager__c);
        System.debug('man id ' + empReturn1.ERP7__ReportingManager__r.Id);
        System.debug('man name ' + empReturn1.ERP7__ReportingManager__r.Name);
        
        return empReturn1;
    }

    
    @auraEnabled
    public static Employees__c getEmp() {
        Employees__c empReturn1;
        String [] EmployeeAccessFields = new String [] {'Id',
            'Name',
            'ERP7__First_Name__c',
            'ERP7__Last_Name__c',
            'ERP7__ReportingManager__c',
            'ERP7__Organisation__c',
            'ERP7__Organisation_Business_Unit__c',
            'ERP7__Employee_Profiling__c',
            'ERP7__Job_Title__c',
            'ERP7__Employee_User__c',
            'ERP7__Admin__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Employees__c.fields.getMap();
        for (String fieldToCheck : EmployeeAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }
        empReturn1 = [select Id, Name, Organisation__c, Organisation_Business_Unit__c, Employee_Profiling__r.Leave_Entitlement__c,
                      Employee_Profiling__r.Leave_Entitlement__r.Leave_Entitlements_Holidays__r.Leaves_Taken__c, ERP7__Employee_User__c, ERP7__Employee_User__r.ManagerId,ERP7__Admin__c
                      from Employees__c where Employee_User__c =: userinfo.getUserId() Limit 500];
        return empReturn1;
    }
   
    @auraEnabled
    public static UserWrapper getCurrentUserEmp() {
        UserWrapper UserWrap = new UserWrapper();
        
        String [] EmployeeAccessFields = new String [] {'Id',
            'Name',
            'ERP7__First_Name__c',
            'ERP7__Last_Name__c',
            'ERP7__ReportingManager__c',
            'ERP7__Organisation__c',
            'ERP7__Organisation_Business_Unit__c',
            'ERP7__Employee_Profiling__c',
            'ERP7__Job_Title__c',
            'ERP7__Employee_User__c',
            'ERP7__Admin__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Employees__c.fields.getMap();
        for (String fieldToCheck : EmployeeAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }
        
        UserWrap.currEmp = [select Id, Name, Organisation__c,ERP7__Phone__c,ERP7__Email__c,ERP7__Place_of_Birth__c, Organisation_Business_Unit__c, Employee_Profiling__r.Leave_Entitlement__c,
                      Employee_Profiling__r.Leave_Entitlement__r.Leave_Entitlements_Holidays__r.Leaves_Taken__c, ERP7__Employee_User__c, ERP7__Employee_User__r.ManagerId,ERP7__Admin__c,
                      ERP7__Annual_Leave_Available__c ,ERP7__Annual_Leave_Booked__c ,ERP7__Casual_Leave_Available__c ,ERP7__Casual_Leave_Boooked__c ,ERP7__Sick_Leave_Available__c ,ERP7__Sick_Leave_Booked__c ,
                      ERP7__Paternity_Leave_Avaiable__c ,ERP7__Paternity_Leave_Booked__c ,ERP7__Earned_Leave_Available__c ,ERP7__Earned_Leave_Booked__c
                      from Employees__c where Employee_User__c =: userinfo.getUserId() Limit 500];
        
        UserWrap.currUser =  [Select id,Name,SmallPhotoUrl, FullPhotoUrl From User Where Id =: Userinfo.getUserId()];
        
        return UserWrap;
    }
    public class UserWrapper{
        @AuraEnabled public User currUser { get; set; }  
        @AuraEnabled public ERP7__Employees__c currEmp { get; set; }
        
        public UserWrapper(){
            currUser =new User();
            currEmp=new ERP7__Employees__c();
        }
    }
    
    @AuraEnabled
    //public static ERP7__Leave_Request__c getSaveLeaveRequest(ERP7__Leave_Request__c LeaveReq1, String str, String leaveType) {
    public static ERP7__Leave_Request__c getSaveLeaveRequest(String LeaveReq1, String str, String leaveType) {
        try{
        ERP7__Leave_Request__c LeaveReq = (ERP7__Leave_Request__c)JSON.deserialize(LeaveReq1, ERP7__Leave_Request__c.class);
        Id userId = UserInfo.getUserId(); 
        Id managerId;
        managerId = LeaveReq.ERP7__Approvers__c;
        ERP7__Employees__c emp = new ERP7__Employees__c();
        emp = [Select Id, Name, ERP7__Employee_User__c From ERP7__Employees__c where ERP7__Employee_User__c =: userId limit 1];
        if(managerId == null) managerId = [Select Id, Name, ManagerId from User where Id =: emp.ERP7__Employee_User__c limit 1].ManagerId;
        Integer daysTaken = 0;
        List<AggregateResult> groupedResults = new List<AggregateResult>();
        List<ERP7__Leave_Request__c> levRe = new List<ERP7__Leave_Request__c>();
        levRe = [select Id, Name From ERP7__Leave_Request__c where ERP7__Employee__r.ERP7__Employee_User__c =: UserInfo.getUserId() And ERP7__Leave_Type__c=:leaveType];
        if(levRe.size()>0){
            groupedResults =  [SELECT SUM(ERP7__Number_of_Days__c)nod, ERP7__Leave_Type__c From ERP7__Leave_Request__c
                                                where ERP7__Employee__r.ERP7__Employee_User__c =: UserInfo.getUserId()
                                                And ERP7__Leave_Type__c=:leaveType
                                                GROUP BY ERP7__Leave_Type__c ];
        }
        
        if(groupedResults.size()>0){
            for(AggregateResult lreq: groupedResults) {
                daysTaken = Integer.valueof(lreq.get('nod'))+Integer.valueof(LeaveReq.ERP7__Number_of_Days__c);
            } 
        }System.debug('days taken '+daysTaken);
        List<ERP7__Leave_Entitlements_Holidays__c> leh = new List<ERP7__Leave_Entitlements_Holidays__c>();
         leh= [Select Id, Name, ERP7__Leave_Entitlement__c, ERP7__Number_of_Days__c, 
                                                    ERP7__Leave_Type__c From ERP7__Leave_Entitlements_Holidays__c 
                                                    where ERP7__Leave_Entitlement__r.ERP7__Employee__r.ERP7__Employee_User__c=:UserInfo.getUserId()
                                                    And ERP7__Leave_Type__c=:leaveType];
        if(leh.size()>0){
            if(daysTaken <= Integer.valueof(leh[0].ERP7__Number_of_Days__c)) {
                if(Schema.sObjectType.ERP7__Leave_Request__c.fields.ERP7__Leave_Entitlement__c.isCreateable() && Schema.sObjectType.ERP7__Leave_Request__c.fields.ERP7__Leave_Entitlement__c.isUpdateable()){LeaveReq.ERP7__Leave_Entitlement__c = getEmp().Employee_Profiling__r.Leave_Entitlement__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Leave_Request__c.fields.ERP7__Leave_Entitlement__c.isCreateable() && Schema.sObjectType.ERP7__Leave_Request__c.fields.ERP7__Leave_Entitlement__c.isUpdateable()){LeaveReq.ERP7__Employee__c = getEmp().Id;}else{/*No access*/}
                if(Schema.sObjectType.Leave_Request__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Leave_Request__c.fields.ERP7__Status__c.isUpdateable()){ LeaveReq.ERP7__Status__c = str;}else{/*No accees*/}
                if(Schema.SObjectType.Leave_Request__c.isCreateable() && Schema.sObjectType.Leave_Request__c.isUpdateable()){ upsert LeaveReq; }else{/*No accees*/}
            }
        }
        //if(managerId != null && LeaveReq.ERP7__Status__c == 'Submitted' && LeaveReq.Id != null){ Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest(); req.setComments('Submitted for approval. Please approve.'); req.setNextApproverIds(new Id[] {managerId}); req.setObjectId(LeaveReq.Id);   req.setProcessDefinitionNameOrId('Leave_Approval_Request'); req.setSkipEntryCriteria(true); Approval.ProcessResult result = Approval.process(req);
        //}
            if(Schema.sObjectType.Leave_Request__c.fields.Leave_Entitlement__c.isCreateable() && Schema.sObjectType.Leave_Request__c.fields.Leave_Entitlement__c.isUpdateable()){LeaveReq.Leave_Entitlement__c = getEmp().Employee_Profiling__r.Leave_Entitlement__c;}else{/*No accees*/}        if(Schema.sObjectType.Leave_Request__c.fields.Employee__c.isCreateable() && Schema.sObjectType.Leave_Request__c.fields.Employee__c.isUpdateable()){LeaveReq.Employee__c = getEmp().Id;}else{/*No accees*/}
            if(Schema.sObjectType.Leave_Request__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Leave_Request__c.fields.ERP7__Status__c.isUpdateable()) LeaveReq.ERP7__Status__c = str;
            if(Schema.SObjectType.Leave_Request__c.isCreateable() && Schema.sObjectType.Leave_Request__c.isUpdateable()) upsert LeaveReq;
            
            if (str == 'Submitted'){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please review and approve.');
                req.setObjectId(LeaveReq.Id);
                system.debug('LeaveReq.ERP7__Approvers__c -->'+LeaveReq.ERP7__Approvers__c);
                req.setNextApproverIds(new Id[]{ LeaveReq.ERP7__Approvers__c });
                Approval.ProcessResult result = Approval.process(req);
            }
        return [SELECT Id, Name, ERP7__Leave_End_Date__c,ERP7__Approvers__c, ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Reason__c, ERP7__Status__c, ERP7__Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,ERP7__Applied_Date__c,ERP7__Employee__r.ERP7__Employee_User__r.SmallPhotoUrl,ERP7__Employee__r.Id,ERP7__Employee__r.Name,ERP7__Employee__c,ERP7__Duration__c FROM ERP7__Leave_Request__c where Id=:LeaveReq.Id];//LeaveReq
        }catch(Exception e){
            system.debug('Exception-->'+e+e.getMessage()+e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static list< Leave_Request__c> getDefault(){
        
        Id userId = UserInfo.getUserId();
        
        String [] leaveRequestAccessFields = new String [] {'Id',
            'Name',
            'ERP7__Applied_Date__c',
            'ERP7__Approval_Status__c',
            'ERP7__Approved_Date__c',
            'ERP7__Approver__c',
            'ERP7__Employee__c',
            'ERP7__Leave_Entitlement__c',
            'ERP7__Duration__c',
            'ERP7__Leave_End_Date__c',
            'ERP7__Leave_Start_Date__c',
            'ERP7__Leave_Type__c',
            'ERP7__Number_of_Days__c',
            'ERP7__Status__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
        for (String fieldToCheck : leaveRequestAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }
        
        
        return [SELECT id, Name, Employee__r.Employee_User__c, Leave_End_Date__c,Leave_Start_Date__c, Number_of_Days__c, ERP7__Reason__c, Status__c, Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,
                Duration__c, ERP7__Approvers__c FROM Leave_Request__c where Employee__r.Employee_User__c =: userId and Leave_Start_Date__c = THIS_FISCAL_YEAR and ERP7__Status__c != 'Approved' and ERP7__Status__c != 'Rejected'];
    }
    
    @AuraEnabled
    public static list<Leave_Request__c> getDefaultApproved(Integer currentFiscalYear){
        list<Leave_Request__c> fetchedLeaveRequests = new list<Leave_Request__c>();
        try{

            system.debug('inside getDefaultApproved:');
            Id userId = UserInfo.getUserId();
            
            String [] leaveRequestAccessFields = new String [] {'Id',
                'Name',
                'ERP7__Applied_Date__c',
                'ERP7__Approval_Status__c',
                'ERP7__Approved_Date__c',
                'ERP7__Approver__c',
                'ERP7__Employee__c',
                'ERP7__Leave_Entitlement__c',
                'ERP7__Duration__c',
                'ERP7__Leave_End_Date__c',
                'ERP7__Leave_Start_Date__c',
                'ERP7__Leave_Type__c',
                'ERP7__Number_of_Days__c',
                'ERP7__Status__c'
                };
                    Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
            for (String fieldToCheck : leaveRequestAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                    }
            }
           
            fetchedLeaveRequests =  [SELECT id, Name, ERP7__Leave_End_Date__c,ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Reason__c, ERP7__Status__c, ERP7__Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,ERP7__Applied_Date__c,
            ERP7__Duration__c FROM ERP7__Leave_Request__c where ERP7__Employee__r.ERP7__Employee_User__c =: userId and CALENDAR_YEAR(ERP7__Leave_Start_Date__c) =: currentFiscalYear and (ERP7__Status__c='Submitted' or ERP7__Status__c='Draft') ORDER BY ERP7__Status__c DESC];
           
            
        }
        catch(Exception e){
            System.debug('Exception in getDefaultApproved:'+e);
        }
        
        return fetchedLeaveRequests;
    }

    @AuraEnabled
    public static list<ERP7__Employees__c> getEmployeRecords(){
        list<ERP7__Employees__c> fetchedEmployeeRecs = new list<ERP7__Employees__c>();
        try{

            /*String [] EmployeeAccessFields = new String [] {'Id',
                'Name',
                'ERP7__Employee_User__c',
                'ERP7__Employee_User__r',
                'ERP7__Phone__c',
                'ERP7__Email__c',
                'ERP7__Active__c'
                };
                    Map<String,Schema.SObjectField> m = Schema.SObjectType.ERP7__Employees__c.fields.getMap();
            for (String fieldToCheck : EmployeeAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                    }
            }*/
           
            fetchedEmployeeRecs =  [SELECT id, Name, ERP7__Employee_User__c,ERP7__Job_Title__c,ERP7__Employee_User__r.SmallPhotoUrl,ERP7__Phone__c, ERP7__Email__c, ERP7__Active__c  FROM ERP7__Employees__c order by Name ASC limit 500];
           
            
        }
        catch(Exception e){
            System.debug('Exception in getEmployeRecords:'+e);
        }
        
        return fetchedEmployeeRecs;
    }

    @AuraEnabled
    public static list<Leave_Request__c> getSubmittedRequests(){
        list<Leave_Request__c> fetchedLeaveRequests = new list<Leave_Request__c>();
        try{

            system.debug('inside getDefaultApproved:');
            Id userId = UserInfo.getUserId();
            
            String [] leaveRequestAccessFields = new String [] {'Id',
                'Name',
                'ERP7__Applied_Date__c',
                'ERP7__Approval_Status__c',
                'ERP7__Approved_Date__c',
                'ERP7__Approver__c',
                'ERP7__Employee__c',
                'ERP7__Leave_Entitlement__c',
                'ERP7__Duration__c',
                'ERP7__Leave_End_Date__c',
                'ERP7__Leave_Start_Date__c',
                'ERP7__Leave_Type__c',
                'ERP7__Number_of_Days__c',
                'ERP7__Status__c'
                };
                    Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
            for (String fieldToCheck : leaveRequestAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                    }
            }
           
            fetchedLeaveRequests =  [SELECT id, Name, ERP7__Leave_End_Date__c,ERP7__Approvers__c,ERP7__Employee__c,ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Reason__c, ERP7__Status__c, ERP7__Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,ERP7__Applied_Date__c,ERP7__Employee__r.Name,ERP7__Employee__r.ERP7__Employee_User__r.SmallPhotoUrl,ERP7__Duration__c,ERP7__Employee__r.Id
                                     FROM ERP7__Leave_Request__c where ERP7__Status__c='Submitted' AND ERP7__Approvers__c =:userId Limit 500]; 
        }
        catch(Exception e){
            System.debug('Exception in getDefaultApproved:'+e);
        }
        
        return fetchedLeaveRequests;
    }
    
    @AuraEnabled
    public static list<Leave_Request__c> getApproved(String status,Integer currentFiscalYear){
        
        Id userId = UserInfo.getUserId();
        
        String [] leaveRequestAccessFields = new String [] {'Id',
            'Name',
            'ERP7__Applied_Date__c',
            'ERP7__Approval_Status__c',
            'ERP7__Approved_Date__c',
            'ERP7__Approver__c',
            'ERP7__Employee__c',
            'ERP7__Leave_Entitlement__c',
            'ERP7__Duration__c',
            'ERP7__Leave_End_Date__c',
            'ERP7__Leave_Start_Date__c',
            'ERP7__Leave_Type__c',
            'ERP7__Number_of_Days__c',
            'ERP7__Status__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
        for (String fieldToCheck : leaveRequestAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }
        return [SELECT id, Name, ERP7__Leave_End_Date__c,ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Reason__c, ERP7__Status__c, ERP7__Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,ERP7__Applied_Date__c,ERP7__Employee__r.ERP7__Employee_User__r.SmallPhotoUrl,ERP7__Employee__r.Id,ERP7__Employee__r.Name,ERP7__Employee__c,
        ERP7__Duration__c FROM ERP7__Leave_Request__c where ERP7__Employee__r.ERP7__Employee_User__c =: userId and CALENDAR_YEAR(ERP7__Leave_Start_Date__c) =: currentFiscalYear and ERP7__Status__c=:status ];
    }
    @AuraEnabled
    public static list<Leave_Request__c> getDraftSubmitted(Integer currentFiscalYear){
        
        Id userId = UserInfo.getUserId();
        
        /*String [] leaveRequestAccessFields = new String [] {'Id',
            'Name',
            'ERP7__Applied_Date__c',
            'ERP7__Approval_Status__c',
            'ERP7__Approved_Date__c',
            'ERP7__Approver__c',
            'ERP7__Employee__c',
            'ERP7__Leave_Entitlement__c',
            'ERP7__Duration__c',
            'ERP7__Leave_End_Date__c',
            'ERP7__Leave_Start_Date__c',
            'ERP7__Leave_Type__c',
            'ERP7__Number_of_Days__c',
            'ERP7__Status__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
        for (String fieldToCheck : leaveRequestAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }*/
        return [SELECT Id, Name, ERP7__Leave_End_Date__c,ERP7__Approvers__c, ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Reason__c, ERP7__Status__c, ERP7__Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,ERP7__Applied_Date__c,ERP7__Employee__r.ERP7__Employee_User__r.SmallPhotoUrl,ERP7__Employee__r.Id,ERP7__Employee__r.Name,ERP7__Employee__c,
        ERP7__Duration__c FROM ERP7__Leave_Request__c where ERP7__Employee__r.ERP7__Employee_User__c =: userId and CALENDAR_YEAR(ERP7__Leave_Start_Date__c) =: currentFiscalYear and (ERP7__Status__c='Draft' or ERP7__Status__c='Submitted') ORDER BY ERP7__Status__c DESC];
    }
    @AuraEnabled
    public static List<ERP7__Leave_Request__c> getAccounts(String strDate) {
        
        if(strDate == null)strDate='Today';
        strDate=(strDate.containsIgnoreCase('Today'))?'<='+strDate : '='+strDate;
        String SQueryL;
        List < ERP7__Leave_Request__c > elc;
        if(!Schema.sObjectType.ERP7__Leave_Request__c.isAccessible()) { return null;
        }
        else {
            String [] leaveRequestAccessFields = new String []{'Id', 'Name', 'ERP7__Applied_Date__c', 'ERP7__Approval_Status__c', 'ERP7__Approved_Date__c', 'ERP7__Approver__c', 'ERP7__Employee__c', 'ERP7__Leave_Entitlement__c', 'ERP7__Duration__c', 'ERP7__Leave_End_Date__c', 'ERP7__Leave_Start_Date__c', 'ERP7__Leave_Type__c', 'ERP7__Number_of_Days__c', 'ERP7__Status__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
            for (String fieldToCheck : leaveRequestAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                }
            }
            SQueryL = 'select id, name, ERP7__Applied_Date__c, ERP7__Approval_Status__c, ERP7__Approved_Date__c, ERP7__Leave_End_Date__c,'+
                ' ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Status__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c, ERP7__Reason__c, ERP7__Leave_Type__c, ERP7__Duration__c'+ //ERP7__Applied_Date__c removed by shaguftha on 09_04_24 as testclass failed duplicate field selected: ERP7__Applied_Date__c
                ' from ERP7__Leave_Request__c where Leave_Start_Date__c' +String.escapeSingleQuotes(strDate)+
                ' and ERP7__Status__c != \'Approved\' and ERP7__Status__c != \'Rejected\' and ERP7__Employee__r.ERP7__Employee_User__c = \''+String.escapeSingleQuotes(userinfo.getUserId())+'\'';
            elc = Database.query(SQueryL); 
            return elc;
        }
    }
    
    @AuraEnabled
    public static list < Leave_Entitlements_Holidays__c > getEntme(String strDate) {
        String SQueryEntitle;
        List < Leave_Entitlements_Holidays__c > entle;
        if(!Schema.sObjectType.Employees__c.isAccessible()) { return null;
        } 
        else {
            String [] leaveEntitleAccessFields = new String [] {'Id', 'Name', 'ERP7__Number_of_Days__c', 'ERP7__Leaves_Taken__c', 'ERP7__Date_Of_Holiday__c', 'ERP7__Leave_Entitlement__c'};
            Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Entitlements_Holidays__c.fields.getMap();
            for (String fieldToCheck : leaveEntitleAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
				}
            }
            SQueryEntitle = 'select id, Name, Number_of_Days__c, Leaves_Taken__c, Leave_Entitlement__c'+
                ' From Leave_Entitlements_Holidays__c'+
                ' where Leave_Entitlement__c != null and Leave_Entitlement__r.Entitlement_End_Date__c ='+String.escapeSingleQuotes(strDate);
            entle = Database.query(SQueryEntitle);
            return entle;
        }
    }
    
    @AuraEnabled
    public static list<ERP7__Leave_Request__c> getLeaveApproved(String strDate) {
        strDate=strDate.containsIgnoreCase('Today')?'<='+strDate : '='+strDate;
        String SQueryA;
        List < ERP7__Leave_Request__c > elcA;
        if(!Schema.sObjectType.ERP7__Leave_Request__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Leave_Request__c.Label));return null;
                                                                      } else {
                                                                          String [] leaveRequestAccessFields = new String [] {'Id',
                                                                              'Name',
                                                                              'ERP7__Applied_Date__c',
                                                                              'ERP7__Approval_Status__c',
                                                                              'ERP7__Approved_Date__c',
                                                                              'ERP7__Approver__c',
                                                                              'ERP7__Employee__c',
                                                                              'ERP7__Leave_Entitlement__c',
                                                                              'ERP7__Duration__c',
                                                                              'ERP7__Leave_End_Date__c',
                                                                              'ERP7__Leave_Start_Date__c',
                                                                              'ERP7__Leave_Type__c',
                                                                              'ERP7__Number_of_Days__c',
                                                                              'ERP7__Status__c'
                                                                              };
                                                                                  Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
                                                                          for (String fieldToCheck : leaveRequestAccessFields) {
                                                                              if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                                                                                     }
                                                                          }
                                                                          SQueryA = 'select id, name, ERP7__Approval_Status__c, ERP7__Approved_Date__c, ERP7__Approver__c, ERP7__Leave_Type__c,'+
                                                                              'ERP7__Leave_End_Date__c, ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c, ERP7__Status__c, ERP7__Reason__c'+ 
                                                                              ' FROM ERP7__Leave_Request__c where (ERP7__Status__c = \'Approved\' or ERP7__Status__c = \'Rejected\') and ERP7__Leave_Start_Date__c '+String.escapeSingleQuotes(strDate)+
                                                                              ' and ERP7__Employee__r.ERP7__Employee_User__c = \''+String.escapeSingleQuotes(userinfo.getUserId())+'\'';
                                                                          elcA = Database.query(SQueryA);
                                                                          return elcA;
                                                                      }
    }
    
    @AuraEnabled
    public static list<Leave_Entitlements_Holidays__c> getEntmeDefault(){
        
        String [] leaveEntitleAccessFields = new String [] {'Id',
            'Name',
            'ERP7__Number_of_Days__c',
            'ERP7__Leaves_Taken__c',
            'ERP7__Date_Of_Holiday__c',
            'ERP7__Leave_Entitlement__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Entitlements_Holidays__c.fields.getMap();
        for (String fieldToCheck : leaveEntitleAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }
        return [select id, Name, Number_of_Days__c, Leaves_Taken__c, Date_Of_Holiday__c From Leave_Entitlements_Holidays__c 
                where Leave_Entitlement__c != null And ERP7__Leave_Entitlement__r.ERP7__Employee__r.ERP7__Employee_User__c=:UserInfo.getUserId() Limit 500];
    }
    
    @AuraEnabled
    public static Id deleteLeave(Id recordId) {
        Id oldAccountId = null;
        
        try {
            if (Schema.sObjectType.Leave_Request__c.isDeletable()) delete new Leave_Request__c(Id = recordId);oldAccountId = recordId;
        }
        catch (System.Exception caught) {
            
        }
        
        return oldAccountId;
    }
    
     @AuraEnabled
    public static List<ERP7__Leave_Request__c> DelLeaveRequest(Id LeaveReqId, Integer currentFiscalYear) {
        Id userId = UserInfo.getUserId();
        try {
            if (Schema.sObjectType.Leave_Request__c.isDeletable()) delete new Leave_Request__c(Id = LeaveReqId);
        }
        catch (System.Exception caught) {
            
        }
        
        return [SELECT Id, Name, ERP7__Leave_End_Date__c,ERP7__Approvers__c, ERP7__Leave_Start_Date__c, ERP7__Number_of_Days__c, ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Reason__c, ERP7__Status__c, ERP7__Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,ERP7__Applied_Date__c,ERP7__Employee__r.ERP7__Employee_User__r.SmallPhotoUrl,ERP7__Employee__r.Id,ERP7__Employee__r.Name,ERP7__Employee__c,
        ERP7__Duration__c FROM ERP7__Leave_Request__c where ERP7__Employee__r.ERP7__Employee_User__c =: userId and CALENDAR_YEAR(ERP7__Leave_Start_Date__c) =: currentFiscalYear and (ERP7__Status__c='Draft' or ERP7__Status__c='Submitted') ORDER BY ERP7__Status__c DESC];
    }
    
    @AuraEnabled
    public static list<Employees__c> getEnt1(){
        
        String [] EmployeeAccessFields = new String [] {'Id',
            'Name',
            'ERP7__ReportingManager__c',
            'ERP7__Leave_Allowance_Take__c',
            'ERP7__First_Name__c',
            'ERP7__Leave_Allowance__c',
            'ERP7__Available_Allowance__c',
            'ERP7__Employee_User__c',
            'ERP7__Employee_Profiling__c',
            'ERP7__Time_Off__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Employees__c.fields.getMap();
        for (String fieldToCheck : EmployeeAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }
        return [ select id, name,First_Name__c, Available_Allowance__c, Leave_Allowance__c, Leave_Allowance_Take__c, ReportingManager__r.First_Name__c, ReportingManager__r.Last_Name__c,
                Employee_Profiling__r.Leave_Entitlement__r.Leave_Entitlements_Holidays__r.Name, ERP7__Time_Off__c, ERP7__Employee_User__c, ERP7__Employee_User__r.ManagerId FROM Employees__c
                where Employee_User__c =: userinfo.getUserId() Limit 500];
        
    }
    
    @AuraEnabled
    public static LeaveManagementLC GetRecordCounts(String strDate){
        LeaveManagementLC result;
        String SQuery;
        String SQueryToff;
        String SQueryAvail;
        result=new LeaveManagementLC();
        if(strDate == '' || strDate == null) strDate = '<= Today';
        else strDate = '=' +strDate;
        if(!Schema.sObjectType.Leave_Request__c.isAccessible()) {  throw new System.NoAccessException(); //return null;
        }
        else {
            String [] LeaveAccessFields = new String [] {'Id', 'Name', 'ERP7__Number_of_Days__c', 'ERP7__Status__c', 'ERP7__Employee__c', 'ERP7__Leave_Start_Date__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
            for (String fieldToCheck : LeaveAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                }
            }
            SQuery = 'select SUM(Number_of_Days__c) num'+ 
                ' FROM Leave_Request__c where Status__c = \'Submitted\' and Leave_Start_Date__c ' +String.escapeSingleQuotes(strDate)+
                ' and Employee__r.Employee_User__c =\''+String.escapeSingleQuotes(userinfo.getUserId())+'\''; 
            aggregateResult temp2 = Database.query(SQuery);
            if(temp2.get('num') == null) result.numStatus = 0.00; else result.numStatus = double.valueOf(temp2.get('num'));
        }
        if(!Schema.sObjectType.Leave_Request__c.isAccessible()) {  throw new System.NoAccessException(); //return null;
        }
        else{
            String [] LeaveAccessFields = new String [] {'Id', 'Name', 'ERP7__Number_of_Days__c', 'ERP7__Status__c', 'ERP7__Employee__c', 'ERP7__Leave_Start_Date__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
            for (String fieldToCheck : LeaveAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                }
            }
            SQueryToff = 'select SUM(Number_of_Days__c) tOff'+ 
                ' FROM Leave_Request__c where Status__c = \'Approved\' and Leave_Start_Date__c ' +String.escapeSingleQuotes(strDate)+
                ' and Employee__r.Employee_User__c =\''+String.escapeSingleQuotes(userinfo.getUserId())+'\''; 
            aggregateResult temp = Database.query(SQueryToff);
            if(temp.get('tOff') == null) result.numTimeOff = 0.00; else result.numTimeOff = double.valueOf(temp.get('tOff'));
        }
        
        if(!Schema.sObjectType.Employees__c.isAccessible()){ throw new System.NoAccessException(); //return null;
        }
        else {
            String [] EmployeeAccessFields = new String [] {'Id', 'Name', 'ERP7__Available_Allowance__c', 'ERP7__Employee_Profiling__c', 'ERP7__Employee_User__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Employees__c.fields.getMap();
            for (String fieldToCheck : EmployeeAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                }
            }
            SQueryAvail = 'select SUM(Available_Allowance__c) num4'+ 
                ' FROM Employees__c where Employee_Profiling__r.Leave_Entitlement__r.Entitlement_End_Date__c ' +String.escapeSingleQuotes(strDate)+
                ' and Employee_User__c =\''+String.escapeSingleQuotes(userinfo.getUserId())+'\''; 
            aggregateResult temp4 = Database.query(SQueryAvail);
            if(temp4.get('num4') == null) result.numAvailable = 0.00; else result.numAvailable = double.valueOf(temp4.get('num4'));
        }
        if(Schema.sObjectType.Leave_Entitlements_Holidays__c.isAccessible()){
            String [] leaveEntitleAccessFields = new String [] {'Id', 'Name', 'ERP7__Accumulative_Leave__c', 'ERP7__Date_Of_Holiday__c', 'ERP7__Leave_Entitlement__c', 'ERP7__Leave_Entitlements_Holidays__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Entitlements_Holidays__c.fields.getMap();
            for (String fieldToCheck : leaveEntitleAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                }
            }
            result.NumHolidays=[select count() from Leave_Entitlements_Holidays__c where Leave_Entitlement__c =: null
                                and Date_Of_Holiday__c != null and Date_Of_Holiday__c >: system.today() and Date_Of_Holiday__c = THIS_FISCAL_YEAR
                                Limit 500];
        }
        return result;
    }
    
    @auraEnabled
    public static list < Leave_Entitlements_Holidays__c > getEntitlementsHolidays(String strDate) {
        String SQueryHoliday;
        List <Leave_Entitlements_Holidays__c> holiday;
        if(!Schema.sObjectType.Leave_Entitlements_Holidays__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Leave_Entitlements_Holidays__c.Label));return null;
                                                                              } else {
                                                                                  String [] leaveEntitleAccessFields = new String [] {'Id',
                                                                                      'Name',
                                                                                      'ERP7__Accumulative_Leave__c',
                                                                                      'ERP7__Date_Of_Holiday__c',
                                                                                      'ERP7__Leave_Entitlement__c',
                                                                                      'ERP7__Leave_Entitlements_Holidays__c'
                                                                                      };
                                                                                          Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Entitlements_Holidays__c.fields.getMap();
                                                                                  for (String fieldToCheck : leaveEntitleAccessFields) {
                                                                                      if (!m.get(fieldToCheck).getDescribe().isAccessible()) { throw new System.NoAccessException(); //return null;
                                                                                                                                             }
                                                                                  }
                                                                                  SQueryHoliday = ' select id, Name, Date_Of_Holiday__c, Leave_Entitlement__c from Leave_Entitlements_Holidays__c where '+
                                                                                      ' Leave_Entitlement__c = null And Date_Of_Holiday__c != null And Date_Of_Holiday__c ='+String.escapeSingleQuotes(strDate); 
                                                                                  holiday = Database.query(SQueryHoliday); 
                                                                                  return holiday;
                                                                              }
    }
    
    @auraEnabled
    public static list<Leave_Entitlements_Holidays__c> getEntitlementsHolidaysDefault() {
        
        String [] leaveEntitleAccessFields = new String [] {'Id',
            'Name',
            'ERP7__Accumulative_Leave__c',
            'ERP7__Allowance_Paid__c',
            'ERP7__Leave_Entitlement__c',
            'ERP7__Leave_Sub_Type__c',
            'ERP7__Leave_Type__c',
            'ERP7__Leaves_Taken__c',
            'ERP7__Number_of_Days__c',
            'ERP7__Date_Of_Holiday__c',
            'ERP7__Leave_Entitlements_Holidays__c',
            'ERP7__Paid_Leave__c',
            'ERP7__Pay_Percentage__c',
            'ERP7__Active__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Entitlements_Holidays__c.fields.getMap();
        for (String fieldToCheck : leaveEntitleAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) { throw new System.NoAccessException(); //return null;
                                                                   }
        }
        
        return [select id, Name, Accumulative_Leave__c, Active__c, Allowance_Paid__c,
                Leave_Entitlement__c, Leave_Sub_Type__c, Leave_Type__c,Leaves_Taken__c,
                Number_of_Days__c, Date_Of_Holiday__c,
                Leave_Entitlements_Holidays__r.Name,Leave_Entitlements_Holidays__r.Date_Of_Holiday__c,
                Paid_Leave__c, Pay_Percentage__c from Leave_Entitlements_Holidays__c
                where Leave_Entitlement__c = null and Date_Of_Holiday__c = THIS_FISCAL_YEAR and Date_Of_Holiday__c >: system.today() order by Date_Of_Holiday__c asc Limit 500];
        
    }
    
    @AuraEnabled
    public Boolean check = true;
    
    /*@AuraEnabled
    public static void saveApprovedLeave(String reason, String tid, String sts){
        string[] alltid = tid.split(',');
        list<Leave_Request__c> listts = new list<Leave_Request__c>();
        for(String s:alltid){
            Leave_Request__c ts = new Leave_Request__c(id=(ID)s);
            if(Schema.sObjectType.Leave_Request__c.fields.ERP7__Approver_Comment__c.isUpdateable()){ts.ERP7__Approver_Comment__c = reason;}else{}
            if(Schema.sObjectType.Leave_Request__c.fields.Status__c.isUpdateable()){ts.Status__c=sts;}else{}
            listts.add(ts);
        }
        if(Schema.SObjectType.Leave_Request__c.isUpdateable()){
            String [] leaveRequestAccessFields = new String [] {'Id', 'Name', 'ERP7__Approver_Comment__c', 'ERP7__Status__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
            for (String fieldToCheck : leaveRequestAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return ;
                }
            }
            update listts;
        }
    }*/
    
    @AuraEnabled
    public static String saveApprovedLeave(String reason, String sts, String LeaveId){
        String error = null;
        try{
            Id workItemId;
            system.debug('Inside saveApprovedLeave:');
            List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :LeaveId And ProcessInstance.Status = 'Pending' LIMIT 1];
                
            list<ERP7__Leave_Request__c> LeaveRequest = [Select Id,Name,ERP7__Leave_Type__c,ERP7__Employee__c,ERP7__Number_of_Days__c from ERP7__Leave_Request__c where Id=:LeaveId LIMIT 1];
            
            list<ERP7__Employees__c> Employee = [Select Id,Name,ERP7__Annual_Leave_Booked__c,ERP7__Annual_Leave_Available__c,ERP7__Casual_Leave_Available__c,
                                                 ERP7__Casual_Leave_Boooked__c,ERP7__Sick_Leave_Available__c, ERP7__Sick_Leave_Booked__c, ERP7__Paternity_Leave_Avaiable__c,
                                                 ERP7__Paternity_Leave_Booked__c,ERP7__Earned_Leave_Available__c,ERP7__Earned_Leave_Booked__c
                                                 from ERP7__Employees__c where Id=:LeaveRequest[0].ERP7__Employee__c LIMIT 1];
            if (!workItems.isEmpty()){ workItemId = workItems[0].Id; }
            
            if (sts == 'Approved' && !workItems.isEmpty()){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkItemID(workItemId);
                req.setComments('Request Approved by User: ' + userInfo.getName() + reason);
                req.setAction('Approve');
                Approval.ProcessResult result =  Approval.process(req);
            } else if (sts == 'Rejected' && !workItems.isEmpty()){
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkItemID(workItemId);
                req.setComments('Request Rejected by User: ' + userInfo.getName() + reason);
                req.setAction('Reject');
                Approval.ProcessResult result =  Approval.process(req);    
            }
            
            if(Schema.sObjectType.Leave_Request__c.fields.ERP7__Approver_Comment__c.isUpdateable()){LeaveRequest[0].ERP7__Approver_Comment__c = reason;}else{/*No access*/}
            if(Schema.sObjectType.Leave_Request__c.fields.ERP7__Status__c.isUpdateable()){LeaveRequest[0].ERP7__Status__c=sts;}else{/*No access*/}
            if(Schema.sObjectType.Leave_Request__c.fields.ERP7__Approval_Status__c.isUpdateable()){LeaveRequest[0].ERP7__Approval_Status__c=sts;}else{/*No access*/}
            
            if(Schema.SObjectType.Leave_Request__c.isUpdateable()){ update LeaveRequest; }else{/*No access*/}
            
            if (sts == 'Approved' && !workItems.isEmpty()){
                if(LeaveRequest[0].ERP7__Leave_Type__c == 'Sick Leave'){ 
                    system.debug('Inside Sick Leave:'+LeaveRequest[0].ERP7__Leave_Type__c);
                    Employee[0].ERP7__Sick_Leave_Available__c = Employee[0].ERP7__Sick_Leave_Available__c - LeaveRequest[0].ERP7__Number_of_Days__c;
                    Employee[0].ERP7__Sick_Leave_Booked__c = Employee[0].ERP7__Sick_Leave_Booked__c + LeaveRequest[0].ERP7__Number_of_Days__c;
                }
                if(LeaveRequest[0].ERP7__Leave_Type__c == 'Casual Leave'){
                    Employee[0].ERP7__Casual_Leave_Available__c = Employee[0].ERP7__Sick_Leave_Available__c - LeaveRequest[0].ERP7__Number_of_Days__c;
                    Employee[0].ERP7__Casual_Leave_Boooked__c = Employee[0].ERP7__Casual_Leave_Boooked__c + LeaveRequest[0].ERP7__Number_of_Days__c;
                }
                if(LeaveRequest[0].ERP7__Leave_Type__c == 'Maternity/ Paternity Leave'){
                    Employee[0].ERP7__Paternity_Leave_Avaiable__c = Employee[0].ERP7__Paternity_Leave_Avaiable__c - LeaveRequest[0].ERP7__Number_of_Days__c;
                    Employee[0].ERP7__Paternity_Leave_Booked__c   = Employee[0].ERP7__Paternity_Leave_Booked__c + LeaveRequest[0].ERP7__Number_of_Days__c;
                }
                if(LeaveRequest[0].ERP7__Leave_Type__c == 'Annual Leave'){
                    Employee[0].ERP7__Annual_Leave_Available__c = Employee[0].ERP7__Annual_Leave_Available__c - LeaveRequest[0].ERP7__Number_of_Days__c;
                    Employee[0].ERP7__Annual_Leave_Booked__c   = Employee[0].ERP7__Annual_Leave_Booked__c + LeaveRequest[0].ERP7__Number_of_Days__c;
                }
                if(LeaveRequest[0].ERP7__Leave_Type__c == 'Earned Leave'){
                    Employee[0].ERP7__Earned_Leave_Available__c = Employee[0].ERP7__Paternity_Leave_Avaiable__c - LeaveRequest[0].ERP7__Number_of_Days__c;
                    Employee[0].ERP7__Earned_Leave_Booked__c   = Employee[0].ERP7__Earned_Leave_Booked__c + LeaveRequest[0].ERP7__Number_of_Days__c;
                } 
            }
            
            if(Schema.SObjectType.ERP7__Employees__c.isUpdateable()) update Employee;
        }
        catch (Exception e){  error = String.valueOf(e); system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber()); }
        return error;
    }
    
    @AuraEnabled
    public static List<Leave_Request__c> getApproval() {
        if(!Schema.sObjectType.Leave_Request__c.isAccessible()){  throw new System.NoAccessException(); //return null;
        } 
        else {
            String [] leaveRequestAccessFields = new String [] {'Id', 'Name', 'ERP7__Applied_Date__c', 'ERP7__Approval_Status__c', 'ERP7__Approved_Date__c', 'ERP7__Approver__c', 'ERP7__Employee__c', 'ERP7__Leave_Entitlement__c', 'ERP7__Duration__c', 'ERP7__Leave_End_Date__c', 'ERP7__Leave_Start_Date__c', 'ERP7__Leave_Type__c', 'ERP7__Number_of_Days__c', 'ERP7__Status__c' };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Leave_Request__c.fields.getMap();
            for (String fieldToCheck : leaveRequestAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                }
            }
            return [select id, name,ERP7__Approver__c, ERP7__Approvers__c, Applied_Date__c, Approval_Status__c, Approved_Date__c, Approver__r.Name, Employee__r.Employee_User__c, Employee__r.First_Name__c, Employee__r.Last_Name__c, 
                    Employee__r.Job_Title__c, Leave_End_Date__c, Leave_Start_Date__c, Number_of_Days__c, ERP7__Reason__c, Status__c, Leave_Type__c, ERP7__Approver_Comment__c, ERP7__Leave_Reason__c,
                    Leave_Entitlement__r.Available_Allowance__c, Leave_Entitlement__r.Leave_Allowance__c, Leave_Entitlement__r.Leave_Allowance_Used__c
                    FROM Leave_Request__c where ERP7__Approvers__c =: userinfo.getUserId() and ERP7__Status__c='Submitted' Limit 500];//Employee__r.ReportingManager__r.Employee_User__c =: userinfo.getUserId()
        }
    }
    
    @AuraEnabled
    public static List<String> getLeaveTypes() {
        List<String> options = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = ERP7__Leave_Request__c.ERP7__Leave_Type__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }       
        return options;
    }
    
    @AuraEnabled
    public static User getApproverDetails(){
        User usr = [Select ManagerId,Manager.Name FROM User Where Id =:userInfo.getUserId()];
        return usr; 
    }
    
    @AuraEnabled
    public static String ApproveReject(String LeaveId,String ApprovalType){
        String error = null;
        try{
            
                Id workItemId;
                List<ProcessInstanceWorkitem> workItems = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :LeaveId And ProcessInstance.Status = 'Pending' LIMIT 1];
                list<ERP7__Leave_Request__c> LeaveRequest = [Select Id,Name from ERP7__Leave_Request__c where Id=:LeaveId LIMIT 1];
                if (!workItems.isEmpty()){ workItemId = workItems[0].Id; }
            
                if (ApprovalType == 'Approved' && !workItems.isEmpty()){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkItemID(workItemId);
                    req.setComments('Request Approved by User: ' + userInfo.getName());
                    req.setAction('Approve');
                    Approval.ProcessResult result =  Approval.process(req);
                    LeaveRequest[0].ERP7__Status__c = 'Approved';
                    upsert LeaveRequest;
                } else if (ApprovalType == 'Rejected' && !workItems.isEmpty()){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setWorkItemID(workItemId);
                    req.setComments('Request Rejected by User: ' + userInfo.getName());
                    req.setAction('Reject');
                    Approval.ProcessResult result =  Approval.process(req);                    
                    LeaveRequest[0].ERP7__Status__c = 'Rejected';
                    upsert LeaveRequest;
                }
            }
        catch (Exception e){  error = String.valueOf(e); system.debug('Exception-->' + e + e.getMessage() + e.getLineNumber()); }
        return error;
    }
}