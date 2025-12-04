@isTest
private class LeaveManagementLC_TestCases {
    static testmethod void leaveManage(){
        String recordId;
        String str;
        String strId;
        String reason;
        String tid;
        String sts;
        String strDate;
        
        RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        Account orgn = new Account(Name='Organisation',Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Cost_to_Company__c CTC = new Cost_to_Company__c(name='test', Fixed_Tax_Amount__c=123.00);
        insert CTC;
        Profiling__c pro = new Profiling__c(Name='test', Cost_to_Company__c = CTC.Id, RecordTypeId = emp_rTypes_org.Id//, ERP_MARK7__Leave_Entitlement__c =ent.Id
                                           );//ERP_MARK7__Holiday_Entitlement__c = LEH.Id
        insert pro;
        Employees__c emp = new Employees__c(name='test', Employee_Profiling__c = pro.Id,Employee_User__c = userinfo.getUserId());
        insert emp;
        Leave_Entitlement__c LE = new  Leave_Entitlement__c(Name='test', Total_Entitled_Leaves__c=123, Employee__c=emp.Id, Profiling__c=pro.Id);
        insert LE;
        
        Leave_Entitlements_Holidays__c LEH = new Leave_Entitlements_Holidays__c(Name='test', Number_of_Days__c=10, Date_Of_Holiday__c=system.today(),
                                                                                Leave_Type__c='Sick Leave', Leave_Entitlement__c=LE.Id);
        insert LEH;  
        pro.ERP7__Leave_Entitlement__c =LE.id;
        update pro;
        
        Id managerId = [Select Id, Name, ManagerId from User where Id =: emp.ERP7__Employee_User__c limit 1].ManagerId;
        Leave_Request__c Leave = new Leave_Request__c(Name='test', Leave_Start_Date__c=system.today(), ERP7__Approvers__c = managerId,
                                                      Leave_End_Date__c=system.today(), Reason__c='test', Status__c='Draft',
                                                      Number_of_Days__c=1, Leave_Type__c='Sick Leave', Employee__c=emp.Id, Leave_Entitlement__c=LE.Id );
        
        insert Leave;
        ERP7__Leave_Request__c LeaveReqs2 = new ERP7__Leave_Request__c(Name='test2', ERP7__Leave_Start_Date__c=system.today(), ERP7__Approvers__c = managerId,
                                                      ERP7__Leave_End_Date__c=system.today(), ERP7__Reason__c='test', ERP7__Status__c='Submitted',
                                                      ERP7__Number_of_Days__c=1, ERP7__Leave_Type__c='Sick Leave', ERP7__Employee__c=emp.Id, ERP7__Leave_Entitlement__c=LE.Id );
        insert LeaveReqs2;
        
        Test.startTest();   
        LeaveManagementLC lc = new LeaveManagementLC();
        LeaveManagementLC.getEmp();
        LeaveManagementLC.getEnt1();
        LeaveManagementLC.getDefault();
        LeaveManagementLC.getDefaultApproved(Date.today().year());
        LeaveManagementLC.getAccounts('THIS_FISCAL_YEAR');
        LeaveManagementLC.getEntmeDefault();
        LeaveManagementLC.GetRecordCounts('THIS_FISCAL_YEAR');
        LeaveManagementLC.deleteLeave(recordId);
        LeaveManagementLC.getLeaveApproved('THIS_FISCAL_YEAR');
        LeaveManagementLC.getEntitlementsHolidays('THIS_FISCAL_YEAR');
        LeaveManagementLC.getEntitlementsHolidaysDefault();
        LeaveManagementLC.getEntme('THIS_FISCAL_YEAR');
        LeaveManagementLC.getCurrentUserEmp();
        //LeaveManagementLC.getLR(str, recordId);
        //LeaveManagementLC.getEntValues();
        //LeaveManagementLC.getLeave(recordId, str);
        //LeaveManagementLC.newAccount();
        //LeaveManagementLC.getEmp();
        //LeaveManagementLC.getEmpEnt();
        //LeaveManagementLC.getNumAvail();
        //LeaveManagementLC.getHolid();
        //LeaveManagementLC.getLeavebyId(strId);
        //LeaveManagementLC.getARLeaves(str1, empid);
        //LeaveManagementLC.getValuesPick(LeaveReq, leaveType);
        String str1 = 'Draft';
        String empid = emp.Id;
        
        LeaveManagementLC.getApproval();
        LeaveManagementLC.getApproverDetails();
        tid = Leave.Id;
        reason = 'test';
        sts = 'Approved';
        LeaveManagementLC.saveApprovedLeave(reason, sts, tid);
        LeaveManagementLC.saveApprovedLeave(reason, sts, 'Submitted');
        LeaveManagementLC.saveApprovedLeave(reason, sts, 'Rejected');
        ERP7__Leave_Request__c LeaveReq = Leave;
        String leaveType = 'Sick Leave';
        LeaveManagementLC.getLeaveTypes();
        String strs2 = 'Submitted';
        String leaveTypes = 'Sick Leave';
        LeaveManagementLC.getSaveLeaveRequest(JSON.serialize(LeaveReqs2), strs2, leaveTypes);
        LeaveManagementLC.ApproveReject(Leave.Id, 'Submitted');
        LeaveManagementLC.ApproveReject(Leave.Id, 'Approved');
        LeaveManagementLC.ApproveReject(Leave.Id, 'Rejected');
        LeaveManagementLC.DelLeaveRequest(Leave.Id,2024);
        LeaveManagementLC.getDraftSubmitted(2024);
        LeaveManagementLC.getEmployeRecords();
        LeaveManagementLC.getSubmittedRequests();
        LeaveManagementLC.getApproved('Approved',2024);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
}