@isTest
private class TestCasesSet_20 {

   static testMethod void eSignatureTestNeg(){
        ESignController esign = new ESignController();
        try {
         if(Test.isRunningTest()) {
                ICE__c i = new ICE__c (Close_Date__c = System.today(),Subject__c ='TEST',Priority__c = 'TEST',Description__c='TEST',Customer_Contact_Email__c='test@test.com');
                insert i;
                System.assertEquals('FAILURE',ESignController.captureSignature('TESTIMAGE',i.Name,'Sigature'));
            }
        } catch (DMLException ex) {
            
        }
    }
    
    static testMethod void eSignatureTest(){
        ICE__c  ice = new ICE__c (Close_Date__c = System.today(),Subject__c ='TEST',Priority__c = 'TEST',Description__c='TEST',Customer_Contact_Email__c='test@test.com');
        insert ice;
        ESignController.signatureId = ice.Id;    
        System.assertEquals('SUCCESS',ESignController.captureSignature('TESTIMAGE',ESignController.signatureId,'Sigature'));
        
        
        
    }
    
     static testMethod void expenseTest(){
    
    RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        
          Id recordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Liabilities').getRecordTypeId();
           Id ExpenserecordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Expense').getRecordTypeId();
        
        ERP7__Chart_of_Accounts__c coa1 = new ERP7__Chart_of_Accounts__c(Name='Credit Card', ERP7__Organisation__c = orgn.Id, RecordTypeId=recordType );
        insert coa1;
         ERP7__Chart_of_Accounts__c Expensecoa1 = new ERP7__Chart_of_Accounts__c(Name='Expense', ERP7__Organisation__c = orgn.Id, RecordTypeId=recordType );
        insert Expensecoa1;
        
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        
        ERP7__Cost_to_Company__c CTC = new ERP7__Cost_to_Company__c(name='test', ERP7__Fixed_Tax_Amount__c=123.00);
        insert CTC;
        
        ERP7__Profiling__c pro = new ERP7__Profiling__c(Name='test', ERP7__Cost_to_Company__c = CTC.Id, RecordTypeId = emp_rTypes_org.Id//, ERP_MARK7__Leave_Entitlement__c =ent.Id
                                                       );//ERP_MARK7__Holiday_Entitlement__c = LEH.Id
        insert pro;
        ERP7__Employees__c emp = new ERP7__Employees__c(name='test', ERP7__Employee_Profiling__c = pro.Id,Employee_User__c = userinfo.getUserId());
        insert emp;
        Expense__c exp = new Expense__c(name = 'test', ERP7__Status__c='Submitted',  ERP7__Date__c= system.today(), ERP7__Approver__c = userinfo.getUserId(), ERP7__Employees__c = emp.Id);
        insert exp; 
        ExpenseSheetLC.appendToFile(null,'test'); 
        
      
        ERP7__Expense_Line_Item__c eli = new ERP7__Expense_Line_Item__c (name = 'test', ERP7__Expensed_Submitted__c = 800, ERP7__VAT_Amount__c = 50, ERP7__Expense__c = exp.Id, ERP7__Expense_Date__c = system.today(), ERP7__Expense_Type__c = 'Travel Insurance', ERP7__Chart_of_Account__c = Expensecoa1.id);
        ERP7__Expense_Line_Item__c InterimPayment = new ERP7__Expense_Line_Item__c (name = 'test', ERP7__Expensed_Submitted__c = 1050, ERP7__Expense__c = exp.Id, ERP7__Expense_Date__c = system.today(), ERP7__Expense_Type__c = 'Interim payment', ERP7__Chart_of_Account__c = coa1.id);
        ERP7__Expense_Line_Item__c refund = new ERP7__Expense_Line_Item__c (name = 'test', ERP7__Expensed_Submitted__c = 200, ERP7__Expense__c = exp.Id, ERP7__Expense_Date__c = system.today(), ERP7__Expense_Type__c = 'Interim payment');
        Expense_Line_Item__c eli1 = new Expense_Line_Item__c (name = 'test', Expense_Date__c = system.today());
        insert eli;
        insert InterimPayment;
       // insert refund;

        exp.ERP7__Paid__c = True;
        exp.ERP7__Post__c = True;

        
        
        Expense__c exp1 = new Expense__c(name = 'test', ERP7__Status__c='Approved',  ERP7__Date__c= system.today(), ERP7__Approver__c = userinfo.getUserId(), ERP7__Employees__c = emp.Id);
        insert exp1; 
        ERP7__Expense_Line_Item__c eli2 = new ERP7__Expense_Line_Item__c (name = 'test', ERP7__Expense__c = exp.Id, ERP7__Expense_Date__c = system.today());
        insert eli2;
        
        }

}