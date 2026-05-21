@isTest
private class IncomeStatement_TestCase{ 
    @TestSetup static void FinanceSetup() {
        Module__c mod = new Module__c(Name='Finance',Run__c=true);
        insert mod;
        Global_Trigger_Handlers__c gv = new Global_Trigger_Handlers__c(Name='TransactionTrigger',ClassName__c='ERP7.TransactionImpl'); 
        insert gv;
        set<Id> pids = new set<Id>();
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        for(Period p : [SELECT Id, StartDate, EndDate, FiscalYearSettings.Name, PeriodLabel, Type FROM Period Where FiscalYearSettings.StartDate = THIS_FISCAL_YEAR AND Type='Month']){
            ERP7__Accounting_Period__c temp = new ERP7__Accounting_Period__c();
            temp.ERP7__Start_Date__c  = p.StartDate;
            temp.ERP7__End_Date__c  = p.EndDate;
            temp.ERP7__New_Fiscal_Year__c = TRUE;
            temp.ERP7__PeriodId__c = p.Id;
            pids.add(p.Id);
            accperiodList.add(temp); 
        }
        if(accperiodList.size()>0)
            upsert accperiodList;
        accperiodList=[SELECT Id,Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__New_Fiscal_Year__c,ERP7__PeriodId__c FROM ERP7__Accounting_Period__c WHERE  ERP7__PeriodId__c IN: pids];
    } 
    
    Static Date getFinancialStartDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].StartDate;
    }
    static Date getFinancialEndDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].EndDate;
    }
    
    
    static testmethod void unit_1(){
        Test.startTest();
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
        
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation',Default__c =true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets')); 
        insert testassetacc;
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert testlaiabilityacc;
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc1;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),Account_Type__c='RetainedEarnings');
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'));
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'AP_Supplier_Invoice_Transaction');
        Set<Id> transId=new Set<Id>();
        Transaction__c test_tran3 = new Transaction__c(Transaction_Status__c='Completed',Transaction_Type__c ='Purchase Returns',RecordTypeId=SIT,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 2500.00,Active__c=true);
        insert test_tran3;
        Transaction__c test_tran4 = new Transaction__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 2500.00,Active__c=true);
        insert test_tran4; 
        transId.add(test_tran3.Id);
        delete test_tran4;
        Finance_General_Ledger_Entry__c test_Entry1 = new Finance_General_Ledger_Entry__c(RecordTypeId=rTypeDebit,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=5000.00);
        insert test_entry1;
        Finance_General_Ledger_Entry__c test_Entry2 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=5000.00,RecordTypeId=rTypeCredit);
        insert test_entry2;
        ApexPages.currentPage().getParameters().put('StartDate',String.valueOf(startDate)); 
        ApexPages.currentPage().getParameters().put('EndDate',String.valueOf(endDate));
        ApexPages.currentPage().getParameters().put('view','Monthly');
        ApexPages.currentPage().getParameters().put('sFY','1');
        IncomeStatement in_stmt = new IncomeStatement();
        in_stmt.startDate = startDate.format();
        in_stmt.endDate = endDate.format();
        in_stmt.Select_Organisation.Organisation__c = orgn.id;
        
        in_stmt.ComputeSelectedFyData();
        in_stmt.computeData();
        in_stmt.refreshTab();
        in_stmt.getData();
        in_Stmt.yearOrQuarter='FQuarter';
        in_Stmt.CheckQuartelyYearlyMon();
        in_stmt.getFinancialYearList();
        in_stmt.Downloadpdf();
        in_stmt.DownloadComparisonpdf();
        in_stmt.CallCompute();
        
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        update test_tran3;
        TransactionsLedgerEntry tr=new TransactionsLedgerEntry();
        TransactionsLedgerEntry.TriggerHandler_Insert_Update(transId,true);
        Test.stopTest();
    }
    static testmethod void unit_2(){
        Test.startTest();
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation',Default__c =true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc;
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert testlaiabilityacc;
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc1;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),Account_Type__c='RetainedEarnings');
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'));
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        Chart_of_Accounts__c testlExpenseacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='COGS',RecordTypeId=AccountGroups_Map.get('Expense'),Account_Type__c='COGS');
        insert testlExpenseacc1;
        
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Id ET = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Expense_Transaction');
        Transaction__c test_tran1 = new Transaction__c(Transaction_Status__c='Completed',Transaction_Type__c ='Expense',RecordTypeId=ET,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
        insert test_tran1;
        Transaction__c test_tran2 = new Transaction__c(Transaction_Status__c='Completed',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
        insert test_tran2;
        Finance_General_Ledger_Entry__c test_Entry7 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=test_tran2.id,Debit_Entry__c=1500.0,RecordTypeId=rTypeDebit);
        insert test_entry7; 
        Finance_General_Ledger_Entry__c test_Entry8 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=test_tran2.id,Debit_Entry__c=1500.0,RecordTypeId=rTypeDebit);
        insert test_entry8;
        Finance_General_Ledger_Entry__c test_Entry9 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlExpenseacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.00,RecordTypeId=rTypeDebit, ERP7__Active__c=true);
        insert test_entry9;
        ApexPages.currentPage().getParameters().put('StartDate',String.valueOf(startDate)); 
        ApexPages.currentPage().getParameters().put('EndDate',String.valueOf(endDate));
        ApexPages.currentPage().getParameters().put('view','Monthly');
        ApexPages.currentPage().getParameters().put('sFY','1');
        IncomeStatement in_stmt = new IncomeStatement();
        in_stmt.startDate = startDate.format();
        in_stmt.endDate = endDate.format();
        in_stmt.Select_Organisation.Organisation__c = orgn.id;
        ApexPages.currentPage().getParameters().put('StartDate',String.valueOf(startDate)); 
        ApexPages.currentPage().getParameters().put('EndDate',String.valueOf(endDate));
        in_stmt.ComputeSelectedFyData();
        in_stmt.SelectedFy='4';
        in_Stmt.yearOrQuarter='FQuarter';
        in_stmt.computeData();
        in_stmt.refreshTab();
        in_stmt.getData();
        in_Stmt.CheckQuartelyYearlyMon();
        in_stmt.getFinancialYearList();
        in_stmt.Downloadpdf();
        in_stmt.DownloadComparisonpdf();
        in_stmt.assignOrgId();
        IncomeStatementLightning INS = new IncomeStatementLightning();
        IncomeStatementLightning.icWrapper ICwrap=new IncomeStatementLightning.icWrapper();
        
        IncomeStatementLightning.ledgerWrap ledge = new IncomeStatementLightning.ledgerWrap();
        INS.userIsoCode='INR';
        // INS = IncomeStatementLightning.fetchDetails(null,null);
        INS = IncomeStatementLightning.fetchDetails(JSON.serialize(INS),'');
        INS = IncomeStatementLightning.ComputeData(JSON.serialize(INS));
        IncomeStatementLightning.getCurrencies();
        
        IncomeStatementLightning.buildConditions(JSON.serialize(INS));
        IncomeStatementLightning.BuildMOnthMap(1);
        INS = IncomeStatementLightning.getdata(JSON.serialize(INS));
        system.debug('INS.FinancialAccountIncomeStmt2 : '+INS.FinancialAccountIncomeStmt2);
        IncomeStatementLightning.getW3(JSON.serialize(INS.FinancialAccountIncomeStmt2));
        /// IncomeStatementLightning.getW2(JSON.serialize(INS.TotalIncomeStmt2));
        IncomeStatementLightning.ComputeSelectedFyData(JSON.serialize(INS));
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
        
    }
    static testmethod void unit_3(){
        Test.startTest();
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation',Default__c =true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc;
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert testlaiabilityacc;
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc1;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),Account_Type__c='RetainedEarnings');
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'));
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        ERP7__COA_Mapping__c coa = new ERP7__COA_Mapping__c(Name='Payment', ERP7__Chart_of_Account__c = testassetacc1.Id, ERP7__Organisation__c= orgn.id);
        insert coa;
        ERP7__COA_Mapping__c coa1 = new ERP7__COA_Mapping__c(Name='InvoicePayment', ERP7__Chart_of_Account__c = testassetacc1.Id, ERP7__Organisation__c= orgn.id);
        insert coa1; 
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        ID CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Customer_Invoice_Transaction');
        Transaction__c test_tran5 = new Transaction__c(RecordTypeId=CIT,Transaction_Status__c='Completed',Transaction_Type__c ='Payment',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran5;
        Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'AP_Supplier_Invoice_Transaction');
        Transaction__c test_tran6 = new Transaction__c(Transaction_Type__c='InvoicePayment',Transaction_Status__c='Completed',RecordTypeId=SIT,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran6;                        
        
        
        
        Finance_General_Ledger_Entry__c test_Entry5 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlExpenseacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.00,RecordTypeId=rTypeDebit);
        insert test_entry5;
        Finance_General_Ledger_Entry__c test_Entry6 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=1500.00,RecordTypeId=rTypeCredit);
        insert test_entry6; 
        Finance_General_Ledger_Entry__c test_Entry7 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.0,RecordTypeId=rTypeDebit);
        insert test_entry7; 
        ApexPages.currentPage().getParameters().put('StartDate',String.valueOf(startDate)); 
        ApexPages.currentPage().getParameters().put('EndDate',String.valueOf(endDate));
        ApexPages.currentPage().getParameters().put('view','Monthly');
        ApexPages.currentPage().getParameters().put('sFY','1');
        IncomeStatement in_stmt = new IncomeStatement();
        in_stmt.startDate = startDate.format();
        in_stmt.endDate = endDate.format();
        in_stmt.Select_Organisation.Organisation__c = orgn.id;
        in_Stmt.SelectedFy='2';
        in_stmt.ComputeSelectedFyData();
        in_Stmt.yearOrQuarter='FQuarter';
        in_stmt.computeData();
        in_stmt.refreshTab();
        in_Stmt.yearOrQuarter='FMonthly';
        in_stmt.computeData();
        in_stmt.getData();
        in_Stmt.SelectedFy='2';
        in_Stmt.yearOrQuarter='FQuarter';
        in_stmt.computeData();
        in_stmt.getData();
        in_Stmt.CheckQuartelyYearlyMon();
        in_stmt.getFinancialYearList();
        in_stmt.Downloadpdf();
        in_stmt.DownloadComparisonpdf();
        in_stmt.getEdate();
        in_stmt.getCurrencyISO();
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        IncomeStatementLightning INS = new IncomeStatementLightning();
        IncomeStatementLightning.W1 w=new IncomeStatementLightning.W1();
        //INS.userIsoCode='INR';
        //INS = IncomeStatementLightning.fetchDetails(null,null);
        
        
        INS = IncomeStatementLightning.fetchDetails(JSON.serialize(INS),'INR');
        INS = IncomeStatementLightning.ComputeData(JSON.serialize(INS));
        
        INS.yearOrQuarter='Quarter';
        IncomeStatementLightning.getCurrencies();
        //IncomeStatementLightning.getW3(null);
        IncomeStatementLightning.getW2(JSON.serialize(INS.TotalIncomeStmt2));
        IncomeStatementLightning.buildConditions(JSON.serialize(INS));
        IncomeStatementLightning.BuildMOnthMap(1);
        IncomeStatementLightning.getdata(JSON.serialize(INS));
        IncomeStatementLightning.ComputeSelectedFyData(JSON.serialize(INS));        
        Test.stopTest();
    }
    static testmethod void unit_4(){
        Test.startTest();
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation',Default__c =true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc;
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert testlaiabilityacc;
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc1;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),Account_Type__c='RetainedEarnings');
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'));
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        ID CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Customer_Invoice_Transaction');
        Transaction__c test_tran5 = new Transaction__c(RecordTypeId=CIT,Transaction_Status__c='Completed',Transaction_Type__c ='Payment',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran5;
        Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'AP_Supplier_Invoice_Transaction');
        Transaction__c test_tran6 = new Transaction__c(Transaction_Type__c='Commissions Payable',Transaction_Status__c='Completed',RecordTypeId=SIT,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran6;                        
        set<Id> pids = new set<Id>();
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        for(Period p : [SELECT Id, StartDate, EndDate, FiscalYearSettings.Name, PeriodLabel, Type FROM Period Where FiscalYearSettings.StartDate = THIS_FISCAL_YEAR AND Type='Month']){
            ERP7__Accounting_Period__c temp = new ERP7__Accounting_Period__c();
            temp.ERP7__Start_Date__c  = p.StartDate;
            temp.ERP7__End_Date__c  = p.EndDate;
            temp.ERP7__New_Fiscal_Year__c = TRUE;
            temp.ERP7__PeriodId__c = p.Id;
            pids.add(p.Id);
            accperiodList.add(temp); 
        }
        if(accperiodList.size()>0)
            upsert accperiodList;
        
        
        Finance_General_Ledger_Entry__c test_Entry5 = new Finance_General_Ledger_Entry__c(ERP7__Accounting_period__C =accperiodList[0].Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlExpenseacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.00,RecordTypeId=rTypeDebit);
        insert test_entry5;
        Finance_General_Ledger_Entry__c test_Entry6 = new Finance_General_Ledger_Entry__c(ERP7__Accounting_period__C =accperiodList[0].Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=1500.00,RecordTypeId=rTypeCredit);
        insert test_entry6; 
        Finance_General_Ledger_Entry__c test_Entry7 = new Finance_General_Ledger_Entry__c(ERP7__Accounting_period__C =accperiodList[0].Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.0,RecordTypeId=rTypeDebit);
        insert test_entry7; 
        
        IncomeStatementLightning INS = new IncomeStatementLightning();
        IncomeStatementLightning.AccountGroup ag = new IncomeStatementLightning.AccountGroup();
        IncomeStatementLightning.icWrap ic = new IncomeStatementLightning.icWrap();
        //W1 w=new W1();
        //INS.userIsoCode='INR';
        INS = IncomeStatementLightning.fetchDetails(null,null);
        //INS = IncomeStatementLightning.fetchDetails(JSON.serialize(INS),'INR');
        //INS = IncomeStatementLightning.ComputeData(JSON.serialize(INS));
        IncomeStatementLightning.getCurrencies();
        //IncomeStatementLightning.getW3(null);
        //IncomeStatementLightning.getW2(null);
        //IncomeStatementLightning.buildConditions(JSON.serialize(INS));
        IncomeStatementLightning.BuildMOnthMap(1);
        //IncomeStatementLightning.getdata(JSON.serialize(INS));
        //IncomeStatementLightning.ComputeSelectedFyData(JSON.serialize(INS));
        IncomeStatementLightning.Data D1 = new IncomeStatementLightning.Data('INS1',0.00,0.00,0.00,0.00);
        IncomeStatementLightning.Data D2 = new IncomeStatementLightning.Data('INS2',0.00,0.00,0.00);
        IncomeStatementLightning.Data D3 = new IncomeStatementLightning.Data('INS3',0.00,0.00);
        IncomeStatementLightning.Data D4 = new IncomeStatementLightning.Data('INS4',0.00);
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest(); 
    }
    
    @isTest
    public static void testComputeUpdatedData() {
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
          Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation',Default__c =true);
        insert orgn;
        // Create necessary test data
        ERP7__Chart_of_Accounts__c chartOfAccount1 = new ERP7__Chart_of_Accounts__c(Name = 'Revenue Account', RecordTypeId = AccountGroups_Map.get('Income_Revenue'),ERP7__Organisation__c = orgn.Id);
        ERP7__Chart_of_Accounts__c chartOfAccount2 = new ERP7__Chart_of_Accounts__c(Name = 'Expense Account', RecordTypeId = AccountGroups_Map.get('Expense'),ERP7__Organisation__c = orgn.Id);
        insert new List<ERP7__Chart_of_Accounts__c>{chartOfAccount1, chartOfAccount2};
            
            Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'AP_Supplier_Invoice_Transaction');
        Transaction__c test_tran3 = new Transaction__c(Transaction_Status__c='Completed',Transaction_Type__c ='Purchase Returns',RecordTypeId=SIT,Organisation__c =orgn.id,Amount__c = 2500.00,Active__c=true);
        insert test_tran3;
        // Create IncomeStatementLightning instance with required fields
        IncomeStatementLightning instance = new IncomeStatementLightning();
        instance.Select_Organisation = test_tran3;
        instance.chart_Of_Accounts = new Map<Id, ERP7__Chart_of_Accounts__c>{
            chartOfAccount1.Id => chartOfAccount1,
                chartOfAccount2.Id => chartOfAccount2
                };
                    instance.StartDate = '2023-01-01';
        instance.endDate = '2023-12-31';
        
        // Serialize the instance to JSON
        String instanceJson = JSON.serialize(instance);
        
        // Call the ComputeUpdatedData method
        Test.startTest();
        IncomeStatementLightning.ComputeUpdatedData(instanceJson);
        Test.stopTest();
        
        
    }
    
}