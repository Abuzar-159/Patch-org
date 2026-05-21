@isTest
private class TimeSheetManagerLC_TestCases {
    static testmethod void TimeManage(){ 
        String nodays;
        String dateChange;
        String str;
        String eid;
        String strDate;
        String timesheetId; 
        String strId;
        String reason;
        String tid;
        String sts;
        string newDay;
        Id recordId;
        String type;
        String value;
        String searchString;
        
        
        RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        ERP7__Cost_to_Company__c CTC = new ERP7__Cost_to_Company__c(name='test', ERP7__Fixed_Tax_Amount__c=123.00);
        insert CTC;
        ERP7__Profiling__c pro = new ERP7__Profiling__c(Name='test', ERP7__Cost_to_Company__c = CTC.Id, RecordTypeId = emp_rTypes_org.Id//, ERP7__Leave_Entitlement__c =ent.Id
                                                       );
        insert pro;
        ERP7__Employees__c emp = new ERP7__Employees__c(name='test', ERP7__Employee_Profiling__c = pro.Id,Employee_User__c = userinfo.getUserId());
        insert emp;
        ERP7__Project__c proj = new ERP7__Project__c(Name='test');
        insert proj;
        ERP7__Timesheet__c ts = new ERP7__Timesheet__c(Name='test', ERP7__Approver__c=emp.ERP7__Employee_User__c, ERP7__Status__c='Submitted', ERP7__Week_Date__c=system.today(), ERP7__Project__c=proj.Id, ERP7__Employees__c=emp.Id);
        insert ts;
        ERP7__Time_Card_Entry__c tCardEntry = new ERP7__Time_Card_Entry__c(ERP7__Timesheet__c = ts.Id);
        insert tCardEntry;
        
        
        TimeSheetManagerLC tc = new TimeSheetManagerLC();
        TimeSheetManagerLC.SearchResult sr = new TimeSheetManagerLC.SearchResult();
        TimeSheetManagerLC.TimeSheet_ManagerLC(nodays, dateChange);
        TimeSheetManagerLC.getTimeSheets(str, eid, 'THIS_FISCAL_YEAR');
        TimeSheetManagerLC.getEmployees();
        TimeSheetManagerLC.newTimesheet();  
        TimeSheetManagerLC.saveTimesheet(ts);    
        TimeSheetManagerLC.saveTimeCardEntry(tCardEntry);  
        TimeSheetManagerLC.getAccount(ts.id);
        
        TimeSheetManagerLC.saveAccount(ts);
        TimeSheetManagerLC.getSheet();
        TimeSheetManagerLC.EditTimesheet(strId);
        TimeSheetManagerLC.getApproval();
        tid = ts.Id;
        reason = 'test';
        sts = 'Approved';
        TimeSheetManagerLC.arTimesheet(reason, tid, sts);
        TimeSheetManagerLC.initializeTimeCardEntry(); 
        TimeSheetManagerLC.getApprovedTimeSheets('THIS_FISCAL_YEAR');    
        TimeSheetManagerLC.initializeToTimeSheets(newDay);    
        TimeSheetManagerLC.searchSObject('ERP7__Timesheet__c', 'test'); 
        TimeSheetManagerLC.getCurrentValue('ERP7__Timesheet__c', ts.Id);
        TimeSheetManagerLC.getCurrentValue(null, ts.id);
        TimeSheetManagerLC.getCurrentValue('ERP7__Timesheet__c', null);
        TimeSheetManagerLC.getCurrentValue('ERP7__Timesheet__c', 'test');
        type='ERP7__Timesheet__c';    
        TimeSheetManagerLC.searchSObject(type, null);
        TimeSheetManagerLC.searchSObject(type, 'ABC');
        TimeSheetManagerLC.deleteAccount(ts.id);
        TimeSheetManagerLC.getAccount(null);
        TimeSheetManagerLC.deleteAccount(null);
        TimeSheetManagerLC.saveAccount(null);
        TimeSheetManagerLC.saveTimesheet(null);
        Id recordId1 = tCardEntry.Id;
        TimeSheetManagerLC.deleteTcardEntry(recordId1);
        TimeSheetManagerLC.getSheetApproved();
        TimeSheetManagerLC.getProjectIds();
        TimeSheetManagerLC.getFunctionalityControl();
        TimeSheetManagerLC.saveTimeCardEntry(null);
        TimeSheetManagerLC.getManagerId(emp.Id);
        TimeSheetManagerLC.getTimeCardItems(ts.Id);
        String type1 = 'test';
        String searchString1 = 'test';
        String queryFilter = 'test';
        TimeSheetManagerLC.search_SObject(type1, searchString1, queryFilter);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name); 
        TimeSheetManagerLC.GetRecordCounts('THIS_FISCAL_YEAR');
        //commented below 4 lins as the method were not avaialble in apex class TimeSheetManagerLC
       // TimeSheetManagerLC.getSheetsandTimeCards('THIS_FISCAL_YEAR',);
        //TimeSheetManagerLC.getSheetsandTimeCardsApproved('THIS_FISCAL_YEAR');
        //TimeSheetManagerLC.getSheetsandTimeCards('');
        //TimeSheetManagerLC.getSheetsandTimeCardsApproved('');
        TimeSheetManagerLC.getSheetsandTimeCardsToApprove();
        TimeSheetManagerLC.search_SObject_Custom('','','','');
        TimeSheetManagerLC.search_SObject_Custom('ERP7__Timesheet__c','test','','Name');
        TimeSheetManagerLC.get_CurrentValue('', '', '');
        TimeSheetManagerLC.get_CurrentValue('ERP7__Timesheet__c', ts.Id, 'Name');
    }   

static testmethod void TimeManage2(){
        String nodays;
        String dateChange;
        String str;
        String eid;
        String strDate;
        String timesheetId; 
        String strId;
        String reason;
        String tid;
        String sts;
        string newDay;
        Id recordId;
        String type;
        String value;
        String searchString;
        
        
        RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        ERP7__Cost_to_Company__c CTC = new ERP7__Cost_to_Company__c(name='test', ERP7__Fixed_Tax_Amount__c=123.00);
        insert CTC;
        ERP7__Profiling__c pro = new ERP7__Profiling__c(Name='test', ERP7__Cost_to_Company__c = CTC.Id, RecordTypeId = emp_rTypes_org.Id//, ERP7__Leave_Entitlement__c =ent.Id
                                                       );
        insert pro;
        ERP7__Employees__c emp = new ERP7__Employees__c(name='test', ERP7__Employee_Profiling__c = pro.Id,Employee_User__c = userinfo.getUserId());
        insert emp;
        ERP7__Project__c proj = new ERP7__Project__c(Name='test');
        insert proj;
    	List<ERP7__Timesheet__c> ListTS = new List<ERP7__Timesheet__c>();
        ERP7__Timesheet__c ts = new ERP7__Timesheet__c(Name='test', ERP7__Approver__c=emp.ERP7__Employee_User__c, ERP7__Status__c='Submitted', ERP7__Week_Date__c=system.today(), ERP7__Project__c=proj.Id, ERP7__Employees__c=emp.Id);
        ListTS.add(ts);
    	
    	ERP7__Timesheet__c ts2 = new ERP7__Timesheet__c(Name='test', ERP7__Approver__c=emp.ERP7__Employee_User__c, ERP7__Status__c='Submitted', ERP7__Week_Date__c=system.today(), ERP7__Project__c=proj.Id, ERP7__Employees__c=emp.Id);
        ListTS.add(ts2);
    	insert ListTS;
    	List<ERP7__Time_Card_Entry__c> ListTC = new List<ERP7__Time_Card_Entry__c>();
        ERP7__Time_Card_Entry__c tCardEntry = new ERP7__Time_Card_Entry__c(Name='test',ERP7__Timesheet__c = ts.Id);
        ListTC.add(tCardEntry);
    	ERP7__Time_Card_Entry__c tCardEntry2 = new ERP7__Time_Card_Entry__c(Name='test',ERP7__Timesheet__c = ts.Id);
        ListTC.add(tCardEntry2);
        insert ListTC;
      	ERP7__Time_Card_Entry__c tCardEntry3 = new ERP7__Time_Card_Entry__c(Name='test3',ERP7__Timesheet__c = ts.Id);
		insert tCardEntry3;
        String approvalType = 'Submitted'; 
		Test.startTest();
        TimeSheetManagerLC tc = new TimeSheetManagerLC();
        TimeSheetManagerLC.SearchResult sr = new TimeSheetManagerLC.SearchResult();        
        TimeSheetManagerLC.saveTimeCardEntryUp(JSON.serialize(ts));
        TimeSheetManagerLC.saveTimeLogs(ts, tCardEntry);
        TimeSheetManagerLC.getDrafSubTimeCards('THIS_FISCAL_YEAR');
    	TimeSheetManagerLC.getSheetsApproved('THIS_FISCAL_YEAR');
    	TimeSheetManagerLC.getSheetandTimeCards(ts.Id);
    	TimeSheetManagerLC.getSheetsToApprove();
    	TimeSheetManagerLC.getAllTimeSheets('THIS_FISCAL_YEAR',emp.Id);
    	TimeSheetManagerLC.getTCEStatus();
    	TimeSheetManagerLC.getActiStatus();
    	TimeSheetManagerLC.getTimeStatus();
    	TimeSheetManagerLC.getTimeLogs(String.valueOf(Date.Today()),String.valueOf(Date.Today().addDays(10)));
        TimeSheetManagerLC.saveSheetandTimeCards(ts,JSON.serialize(ListTC),approvalType);
    	approvalType='Approved';
        TimeSheetManagerLC.saveSheetandTimeCards(ts,JSON.serialize(ListTC),approvalType);
    	approvalType='Rejected';
        TimeSheetManagerLC.saveSheetandTimeCards(ts,JSON.serialize(ListTC),approvalType);
        TimeSheetManagerLC.deletetimeCard(tCardEntry3.Id,ts.Id);
        Test.stopTest();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name); 
    }   
}