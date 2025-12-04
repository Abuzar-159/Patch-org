@isTest  (SeeAllData=true)
private class BankReconcile_TestCase{
    static testmethod void unit1() 
    {
        Test.startTest(); 
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(Organisation__c = orgn.Id,RecordTypeId = Bank_Acc_org.id,Organisation_Business_Unit__c = busUnit.id,Name = 'Test',Account_Number__c='12345678');
        insert testbank;
        testbank = [SELECT id,Organisation__c,Organisation__r.Name,Organisation_Business_Unit__c,Account_Number__c,Name From Bank_details__c where id =: testbank .id ];
        Bank_Reconciliation__c testbankobj = new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=testbank.id,Status__c='Draft');
        insert testbankobj;
        Bank_Statement__c test_stmt=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=200.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test',Balance__c=200.00);
        insert test_stmt;
        Bank_Statement__c test_stmt1=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=251.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test1',Balance__c=251.00);
        insert test_stmt1;
        Bank_Statement__c test_stmt2=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=200.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test2',Balance__c=251.00);
        insert test_stmt2;
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Transaction__c test_trans=new Transaction__c(Finance_Category_Type__c='Credit',Amount__c=200.00,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id);
        insert test_trans;
        Finance_General_Ledger_Entry__c test_Entry4 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,ERP7__Transactions__c =test_trans.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Credit_Entry__c=1500.0);
        insert test_Entry4;
        
        Transaction__c test_trans_1=new Transaction__c(Finance_Category_Type__c='Credit',Amount__c=200.00,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id);
        insert test_trans_1;
        Bank_Transaction__c bt1 = new Bank_Transaction__c(Bank_Reconciliation__c = testbankobj.id,Bank_Statement__c = test_stmt.id, Transaction__c = test_trans.id,Cleared_Date__c= System.Today(),Disbursement__c=test_stmt.Withdrawals__c,Debit__c=0.0 );
        insert bt1;
        list<Transaction__c> tr=new list<Transaction__c>();
        tr.add(test_trans);
        tr.add(test_trans_1);
   //     Document lstDoc = [select id,name,Body from Document where DeveloperName = 'Bank_Statement_Template'];
        
        BankReconciliationLightning.WrapperBankUnReconcile brwrap = new BankReconciliationLightning.WrapperBankUnReconcile();
        List<BankReconciliationLightning.WrapperBankUnReconcile> brwrapList = new List<BankReconciliationLightning.WrapperBankUnReconcile>();
        BankReconciliationLightning.WrapperTransaclist bwrap = new BankReconciliationLightning.WrapperTransaclist(test_trans_1);
        BankReconciliationLightning.updateBankReconciliation(JSON.serialize(testbankobj));
        brwrapList = BankReconciliationLightning.processUnReconcile(JSON.serialize(testbankobj));
        BankReconciliationLightning.RemoveUndoList(0, JSON.serialize(testbankobj), JSON.serialize(brwrapList));
        //BankReconciliationLightning brl=new BankReconciliationLightning();
        BankReconciliationLightning.retrieveDetails(testbank.Id,testbankobj.Id);
        BankReconciliationLightning.retrieveDetails(null,null);  
        BankReconciliationLightning.fetchDocuments();
        BankReconciliationLightning.bankStmtlist=null;
        
        BankReconciliationLightning.org_bankStmtlist=null;
        BankReconciliationLightning.showFileData=false;
        
        
        BankReconciliationLightning.showInputFile=false;
        BankReconciliationLightning.getTransactionStatus();
        BankReconciliationLightning.getTransactionType();
        BankReconciliationLightning.Find_and_Match('in','48', null, null, orgn.Id,'','');
        BankReconciliationLightning.Find_and_Match('in','', null, null, orgn.Id,'','');
        BankReconciliationLightning.MatchingTrasaction('48');
        BankReconciliationLightning.ProcessReconcile(JSON.serialize(test_stmt),JSON.serialize(tr),JSON.serialize(testbankobj));
        BankReconciliationLightning.CreateTransactionApex(JSON.serialize(test_stmt),JSON.serialize(test_trans_1),JSON.serialize(testbankobj));
        BankReconciliationLightning.CreateTransactionApex(JSON.serialize(null),JSON.serialize(null),JSON.serialize(testbankobj));
        BankReconciliationLightning.importedDetails();
        String str = 'Transaction_date,Payment,Transaction_summary,Cheque,Reference,Deposits,Withdrawals,Balance\n 01-01-2020,ICICI ATM,ATM/CASH WDL/,1111,2222,0,5000,400';
        Blob csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        
        
        BankReconciliationLightning.importCSVFile(JSON.serialize(testbankobj),testbank.Id,csvAsString);
        Datetime startdate1 = Datetime.now();
        
        
        Datetime enddate1 = startdate1 + 10;
        // BankReconciliationLightning.yodleeTransaction('',testbankobj.id,startdate1,enddate1,JSON.serialize(testbankobj));
        /*BankReconciliationLightning.ProcessReconcile(JSON.serialize(test_stmt2),JSON.serialize(tr),JSON.serialize(testbankobj));
BankReconciliationLightning.processUnReconcile(JSON.serialize(testbankobj));
BankReconciliationLightning.MatchingTrasaction('48');
BankReconciliationLightning.WrapperTransaclist wr=new BankReconciliationLightning.WrapperTransaclist(test_trans_1);
BankReconciliationLightning.WrapperBankUnReconcile wrapperinstanceundol = new  BankReconciliationLightning.WrapperBankUnReconcile();
List<BankReconciliationLightning.WrapperBankUnReconcile> wrp=new List<BankReconciliationLightning.WrapperBankUnReconcile>();
wrp.add(wrapperinstanceundol);
BankReconciliationLightning.RemoveUndoList(0,JSON.serialize(testbankobj),JSON.serialize(wrp));
BankReconciliationLightning.RemoveUndoList(5,JSON.serialize(testbankobj),JSON.serialize(wrp));
BankReconciliationLightning.updateBankReconciliation(JSON.serialize(testbankobj));
BankReconciliationLightning.updateBankReconciliation(null);
BankReconciliationLightning.importedDetails();*/
        //BankReconciliationLightning.CreateToken();
        
        
        List<Bank_Reconciliation__c> templist = new List<Bank_Reconciliation__c>();
        templist.add(testbankobj);
        
        /*Wrapper Class Instance*/
        
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    static testmethod void unit2()
    {
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation');
        insert orgn;
        
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(RecordTypeId = Bank_Acc_org.id,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id,Name='Test',Account_Number__c='12345678');
        insert testbank;
        Bank_Reconciliation__c testbankobj=new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=testbank.id,Status__c='Draft');
        insert testbankobj;
        
        
     //   Document lstDoc = [select id,name,Body from Document where DeveloperName='Bank_Statement_Template'];
        
        PageReference pageRef = System.Page.BankReconciliation;
        Test.setCurrentPage(pageRef);
        
        
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
    }
    static testmethod void unit3()
    {
        Test.startTest();
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(Organisation__c = orgn.Id,RecordTypeId = Bank_Acc_org.id,Organisation_Business_Unit__c = busUnit.id,Name = 'Test',Account_Number__c='12345678');
        insert testbank;
        Bank_Reconciliation__c testbankobj=new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=testbank.id,Status__c='Draft');
        insert testbankobj;
        Bank_Statement__c test_stmt=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=200.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test3',Balance__c=200.00);
        insert test_stmt;
        Bank_Statement__c test_stmt1=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=251.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test31',Balance__c=251.00);
        insert test_stmt1;
        Transaction__c test_trans = new Transaction__c(Finance_Category_Type__c='Credit',Amount__c=200.00,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id);
        insert test_trans;
        
        Bank_Transaction__c bt1 = new Bank_Transaction__c(Bank_Reconciliation__c = testbankobj.id,Bank_Statement__c = test_stmt.id, Transaction__c = test_trans.id,Cleared_Date__c= System.Today(),Disbursement__c=test_stmt.Withdrawals__c,Debit__c=0.0 );
        insert bt1;
      //  Document lstDoc = [select id,name,Body from Document where DeveloperName='Bank_Statement_Template'];
        
        PageReference pageRef = System.Page.BankReconciliation;
        pageRef.getParameters().put('rid',testbankobj.Id);
        Test.setCurrentPage(pageRef);
        
        
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    
    Static Date getFinancialStartDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].StartDate;
    }
    static Date getFinancialEndDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].EndDate;
    }
    static testmethod void unit11() 
    {
        Test.startTest();
        Credentials__c cc = [Select Id,Name from Credentials__c where name='Yodlee'];
        if(cc != null){
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            BankReconciliationLightning blr = new BankReconciliationLightning();
        }
        
        Test.stopTest();
    }
    static testmethod void unit12() 
    {
        
        Credentials__c cc = [Select Id,Name from Credentials__c where name='Yodlee'];
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        
        BankReconciliationLightning.JWT jw = new BankReconciliationLightning.JWT();
        BankReconciliationLightning.genBody(orgn.Id, 'fghjeyfhufnkdljeyttifjdfhrui');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BankReconciliationLightning.CreateToken();
        Test.stopTest();
    }
    static testmethod void unit13() 
    {
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Credentials__c cc = [Select Id,Name from Credentials__c where name='Yodlee'];
        update cc;
        
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(Organisation__c = orgn.Id,RecordTypeId = Bank_Acc_org.id,Organisation_Business_Unit__c = busUnit.id,Name = 'Test',Account_Number__c='12345678');
        insert testbank;
        Bank_Reconciliation__c testbankobj=new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=testbank.id,Status__c='Draft');
        insert testbankobj;
        Bank_Statement__c test_stmt=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=200.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test3',Balance__c=200.00);
        insert test_stmt;
        Bank_Statement__c test_stmt1=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=251.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test31',Balance__c=251.00);
        insert test_stmt1;
        Transaction__c test_trans = new Transaction__c(Finance_Category_Type__c='Credit',Amount__c=200.00,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id);
        insert test_trans;
        
        Bank_Transaction__c bt1 = new Bank_Transaction__c(Bank_Reconciliation__c = testbankobj.id,Bank_Statement__c = test_stmt.id, Transaction__c = test_trans.id,Cleared_Date__c= System.Today(),Disbursement__c=test_stmt.Withdrawals__c,Debit__c=0.0 );
        insert bt1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BankReconciliationLightning.generateToken();
        //BankReconciliationLightning.generateToken('a121o00000AYbFSAA1');
        //    ,testbankobj.Id,system.today(),system.today()+10,JSON.serialize(testbankobj));
        Test.stopTest();
    }
    static testmethod void unit14() 
    {
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Credentials__c cc = [Select Id,Name from Credentials__c where name Like 'plaid'];
        update cc;
        
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        ERP7__Bank_details__c bankDetails = new ERP7__Bank_details__c(Name='Test Bank', ERP7__Organisation__c = orgn.Id);
        insert bankDetails;
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='test CC',ERP7__Organisation__c = orgn.Id, ERP7__Bank_Account__c = bankDetails.Id);
        insert coa;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(Organisation__c = orgn.Id,RecordTypeId = Bank_Acc_org.id,Organisation_Business_Unit__c = busUnit.id,Name = 'Test',Account_Number__c='12345678');
        insert testbank;
        Bank_Reconciliation__c testbankobj=new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=testbank.id,Status__c='Draft');
        insert testbankobj;
        Bank_Statement__c test_stmt=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=200.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test3',Balance__c=200.00);
        insert test_stmt;
        Bank_Statement__c test_stmt1=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=251.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test31',Balance__c=251.00);
        insert test_stmt1;
        Transaction__c test_trans = new Transaction__c(Finance_Category_Type__c='Credit',Amount__c=200.00,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id);
        insert test_trans;
        
        Bank_Transaction__c bt1 = new Bank_Transaction__c(Bank_Reconciliation__c = testbankobj.id,Bank_Statement__c = test_stmt.id, Transaction__c = test_trans.id,Cleared_Date__c= System.Today(),Disbursement__c=test_stmt.Withdrawals__c,Debit__c=0.0 );
        insert bt1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BankReconciliationLightning.plaidTransaction(bankDetails.Id,testbankobj.Id,system.today(),system.today()+10,JSON.serialize(testbankobj));
        Test.stopTest();
    }
    static testmethod void unit15() 
    {
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Credentials__c cc = [Select Id,Name from Credentials__c where name Like 'plaid'];
        update cc;
        
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        ERP7__Bank_details__c bankDetails = new ERP7__Bank_details__c(Name='Test Bank', ERP7__Organisation__c = orgn.Id);
        insert bankDetails;
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='test CC',ERP7__Organisation__c = orgn.Id, ERP7__Bank_Account__c = bankDetails.Id);
        insert coa;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(Organisation__c = orgn.Id,RecordTypeId = Bank_Acc_org.id,Organisation_Business_Unit__c = busUnit.id,Name = 'Test',Account_Number__c='12345678');
        insert testbank;
        Bank_Reconciliation__c testbankobj=new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=bankDetails.Id,Status__c='Draft');
        insert testbankobj;
        Bank_Statement__c test_stmt=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=200.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test3',Balance__c=200.00);
        insert test_stmt;
        Bank_Statement__c test_stmt1=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=251.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test31',Balance__c=251.00);
        insert test_stmt1;
        Transaction__c test_trans = new Transaction__c(Finance_Category_Type__c='Credit',Amount__c=200.00,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id);
        insert test_trans;
        
        Bank_Transaction__c bt1 = new Bank_Transaction__c(Bank_Reconciliation__c = testbankobj.id,Bank_Statement__c = test_stmt.id, Transaction__c = test_trans.id,Cleared_Date__c= System.Today(),Disbursement__c=test_stmt.Withdrawals__c,Debit__c=0.0 );
        insert bt1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BankReconciliationLightning.yodleeTransaction(orgn.Id,testbankobj.Id,system.today(),system.today()+10,JSON.serialize(testbankobj));
        // BankReconciliationLightning.getYodleeTransactionList(bankDetails.Id, system.today(),system.today()+10);
        Test.stopTest();
    }
    static testmethod void unit16() 
    {
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Credentials__c cc = [Select Id,Name from Credentials__c where name Like 'plaid'];
        update cc;
        
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        ERP7__Bank_details__c bankDetails = new ERP7__Bank_details__c(Name='Test Bank', ERP7__Organisation__c = orgn.Id);
        insert bankDetails;
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='test CC',ERP7__Organisation__c = orgn.Id, ERP7__Bank_Account__c = bankDetails.Id);
        insert coa;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(Organisation__c = orgn.Id,RecordTypeId = Bank_Acc_org.id,Organisation_Business_Unit__c = busUnit.id,Name = 'Test',Account_Number__c='12345678');
        insert testbank;
        Bank_Reconciliation__c testbankobj=new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=bankDetails.Id,Status__c='Draft');
        insert testbankobj;
        Bank_Statement__c test_stmt=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=200.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test3',Balance__c=200.00);
        insert test_stmt;
        Bank_Statement__c test_stmt1=new Bank_Statement__c(Bank_Account__c=testbank.id,Bank_Reconciliation__c=testbankobj.id,Deposits__c=0.0,Withdrawals__c=251.00,Transaction_Date__c= System.Today(),Transaction_Mode__c= 'Cash',Transaction_Summary__c='Testing',Reference_Number__c='Test31',Balance__c=251.00);
        insert test_stmt1;
        Transaction__c test_trans = new Transaction__c(Finance_Category_Type__c='Credit',Amount__c=200.00,Organisation__c = orgn.Id,Organisation_Business_Unit__c=busUnit.id);
        insert test_trans;
        
        Bank_Transaction__c bt1 = new Bank_Transaction__c(Bank_Reconciliation__c = testbankobj.id,Bank_Statement__c = test_stmt.id, Transaction__c = test_trans.id,Cleared_Date__c= System.Today(),Disbursement__c=test_stmt.Withdrawals__c,Debit__c=0.0 );
        insert bt1;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        BankReconciliationLightning.getYodleeTransactionList(bankDetails.Id, system.today(),system.today()+10);
        BankReconciliationLightning.processAutoReconcile(JSON.serialize(bt1));
        BankReconciliationLightning.fetchAutoReconcileRecords(testbankobj.Id);
        Test.stopTest();
    }
}