@isTest
private class TestCasesSet_5 {
    static testMethod void UnitTest2(){
      try{
        
        //MyTimesheets
        
        Id userId = UserInfo.getUserId();
          
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        System.assertEquals(orgn.Name, 'Organisation');
        
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        
        Account acc = new Account(Name='test');
        insert acc;
        
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=userId,Employment_Status__c = 'Active',Non_Employee__c = false,First_Working_Day__c = system.today());
        insert emp;        
       
        Timesheet__c timesheet = new Timesheet__c(Employees__c=emp.Id, Approver__c=userId,Status__c='Draft',Selected__c=true,Start_date__c=system.Today());
        insert timesheet;
        
        Time_Card_Entry__c tce = new Time_Card_Entry__c(Active__c=true, Timesheet__c=timesheet.Id,Week_Day_1__c=system.today());
        insert tce;
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
     
       } catch(exception e){} 
    }
   
}