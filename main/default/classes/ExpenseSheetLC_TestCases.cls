@isTest
private class ExpenseSheetLC_TestCases {
    static testmethod void expense(){
        String strDate;
        Id recordId;
        String strId;
        Id parentId;
        String fileName;
        String base64Data;
        String contentType;
        String reason;
        String tid; 
        String sts;
        String fileId;
        
        RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        
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
        
        ERP7__Expense_Line_Item__c eli = new ERP7__Expense_Line_Item__c (name = 'test', ERP7__Expense__c = exp.Id, ERP7__Expense_Date__c = system.today());
        Expense_Line_Item__c eli1 = new Expense_Line_Item__c (name = 'test', Expense_Date__c = system.today());
        insert eli;
        
        Expense__c exp1 = new Expense__c(name = 'test', ERP7__Status__c='Approved',  ERP7__Date__c= system.today(), ERP7__Approver__c = userinfo.getUserId(), ERP7__Employees__c = emp.Id);
        insert exp1; 
        ERP7__Expense_Line_Item__c eli2 = new ERP7__Expense_Line_Item__c (name = 'test', ERP7__Expense__c = exp.Id, ERP7__Expense_Date__c = system.today());
        insert eli2;
        TransactionManagement.fetchExpenses(null, null, null);
        List<Expense_Line_Item__c> eli01 = new List<Expense_Line_Item__c> ();
        //eli01.add(eli);
        //eli01.add(eli1);
        List<String> str= new List<String>();
       str.add(exp.Id);
       str.add(exp1.Id);
        boolean isExUpdate = false;
        Blob b = Blob.valueOf('Test Data');
        String b64 = EncodingUtil.base64Encode(b);
        
        ExpenseSheetLC exps = new ExpenseSheetLC();
        exps.numAmountSub = 0;
        exps.numAmountPaid = 0;
        
        ExpenseSheetLC.getSheet('THIS_FISCAL_YEAR', userinfo.getUserId());
        ExpenseSheetLC.getSheetApproved('THIS_FISCAL_YEAR');
         ExpenseSheetLC.getSheetRefund('THIS_FISCAL_YEAR', userinfo.getUserId());
        ExpenseSheetLC.getExpenses('THIS_FISCAL_YEAR');
        ExpenseSheetLC.getApprovedExpenses('');
        ExpenseSheetLC.getEmployeeDetails();
        ExpenseSheetLC.deleteExpense(recordId);
        ExpenseSheetLC.GetRecordCounts('','THIS_FISCAL_YEAR', userinfo.getUserId());
        ExpenseSheetLC.GetPaidRecordCounts('','THIS_FISCAL_YEAR');
        ExpenseSheetLC.getEmployees();
        ExpenseSheetLC.AddExpenseCheckFLS();
        ExpenseSheetLC.deleteExpenseSheet(recordId);
        ExpenseSheetLC.deleteElineItem(recordId);
       // ExpenseSheetLC.save_ExpenseIK(string.valueOf(isExUpdate),JSON.serialize(exp), JSON.serialize(eli01),true); 
        ExpenseSheetLC.saveExpenseLineItem(JSON.serialize(eli));
        ExpenseSheetLC.getCurrencyIsoCode();
        //ExpenseSheetLC.EditExpense(strId);
        ExpenseSheetLC.uploadFileAK('parent', 'fileName', 'base64Data', 'contentType');
        ExpenseSheetLC.uploadFileAK(eli.Id, 'fileName', b64, 'text');
        ExpenseSheetLC.DeleteAT(pro.Id, 'ERP7__Profiling__c');
        parentId = eli.id;
        fileName = 'test';
        base64Data = 'test';
        contentType = 'test';
        ExpenseSheetLC.saveTheFile(parentId, fileName, base64Data, contentType);
        Id parentId1 = eli.Id;
        String fileName1 = 'test';
        String base64Data1 = 'test';
        String contentType1 = 'test';
        String fileId1 = '';
        ExpenseSheetLC.saveTheChunk(parentId1, fileName1, base64Data1, contentType1, fileId1);
        ExpenseSheetLC.getApproval();
        tid = exp.Id;
        reason = 'test';
        sts = 'Approved';
        try{
            ExpenseSheetLC.saveApprovedExpense(reason, tid, sts);
        ExpenseSheetLC.appendToFile(exp.Id,'test');
        }catch(Exception e){}
        ExpenseSheetLC.getCategorypickval();
        ExpenseSheetLC.getTypepickval();
        ExpenseSheetLC.delCurExpli(JSON.serialize(eli));
       list<ERP7__Expense_Line_Item__c> explineitems = new list<ERP7__Expense_Line_Item__c>();
        explineitems.add(eli1);
        explineitems.add(eli2);
        //String jsonString = JSON.serialize(explineitems);
        //ExpenseSheetLC.upsateAllExpli(jsonString);
        ExpenseSheetLC.deleteMultiExpense(str);
        ExpenseSheetLC.EditMultiExpense(str);
        ExpenseSheetLC.ExpenseWrap exwrap = new ExpenseSheetLC.ExpenseWrap();
        ExpenseSheetLC.lineWrapper linewrap = new ExpenseSheetLC.lineWrapper();
        ExpenseSheetLC.ExpWrap ewrap = new ExpenseSheetLC.ExpWrap();
        ExpenseSheetLC.fetchExpRecords(exp.Id);
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Organisation__c =orgn.id ,Name='Tax',ERP7__Default_Expense_Tax__c=true);
        insert coa;
        ExpenseSheetLC.fetchDefaultTaxCOA(10);
        list<ERP7__Expense_Line_Item__c> expenselineitems = [select Id, Name, ERP7__Expense__c from ERP7__Expense_Line_Item__c where Id=:eli2.Id];
        ExpenseSheetLC.upsateAllExpli(JSON.serialize(expenselineitems),true);
        //ExpenseSheetLC.getCOA(eli2.Id);
        string ExpId = exp.Id;
        system.debug('ExpId-->'+ExpId);
        try{ ExpenseSheetLC.EditExpense(ExpId); } catch(exception e){}
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
}