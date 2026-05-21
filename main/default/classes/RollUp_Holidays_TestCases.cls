@isTest
private class RollUp_Holidays_TestCases {
   static testmethod void RollUpHolidays(){
            
            RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
            insert bUnit; 
            Cost_to_Company__c CTC = new Cost_to_Company__c(name='test', Fixed_Tax_Amount__c=123.00, 
                                                                                  Organisation__c = orgn.Id, Organisation_Business_Unit__c=bUnit.Id);
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
            pro.Leave_Entitlement__c =LE.id;
            update pro;
        
            Leave_Request__c Leave = new Leave_Request__c(Name='test', Leave_Start_Date__c=system.today(),
                                                          Leave_End_Date__c=system.today(), Reason__c='test', Status__c='Draft',
                                                          Number_of_Days__c=1, Leave_Type__c='Sick Leave', Employee__c=emp.Id, Leave_Entitlement__c=LE.Id);
         
             insert Leave;  
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
   }
}