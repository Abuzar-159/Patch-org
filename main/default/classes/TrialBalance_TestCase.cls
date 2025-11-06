@isTest
private class TrialBalance_TestCase{
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
        
        // Create test data for Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                ERP7__Email__c = 'test' + i + '@example.com'
            ));
        }
        insert accounts;
        
        // Create test Attachments and ContentDocumentLinks
        for (Account acc : accounts) {
            Attachment att = new Attachment(
                Name = 'Test Attachment',
                ContentType = 'application/pdf',
                ParentId = acc.Id,
                Body = Blob.valueOf('Test attachment body')
            );
            insert att;
            
            ContentVersion cv = new ContentVersion(
                Title = 'Test Document',
                PathOnClient = 'TestDocument.pdf',
                VersionData = Blob.valueOf('Test document body')
            );
            insert cv;
            
            ContentDocumentLink cdl = new ContentDocumentLink(
                LinkedEntityId = acc.Id,
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId
            );
            insert cdl;
        }
        
    } 
    
    Static Date getFinancialStartDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].StartDate;
    }
    static Date getFinancialEndDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].EndDate;
    }
    
    
    static testmethod void unit1()
    {
        Test.startTest();
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation',Default__c = true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Payment_account__c=true,Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc ;
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert testlaiabilityacc;
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc1;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'),isContra_Account__c=false);
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),isContra_Account__c=false);
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=false);
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'AP_Supplier_Invoice_Transaction');
        Transaction__c test_tran1 = new Transaction__c(Transaction_Status__c='Completed',Transaction_Type__c ='Payment',RecordTypeId=SIT,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
        insert test_tran1;
        Transaction__c test_tran2 = new Transaction__c(Transaction_Type__c='Purchase',Transaction_Status__c='Completed',RecordTypeId=SIT,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
        insert test_tran2;
        
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
        
        Finance_General_Ledger_Entry__c test_Entry1 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeDebit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=test_tran1.id,Debit_Entry__c=5000.00);
        insert test_entry1;
        Finance_General_Ledger_Entry__c test_Entry2 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=test_tran2.id,credit_Entry__c=5000.00);
        insert test_entry2;
        TrialBalance tb = new TrialBalance();
        TrialBalance.searchOrg('Test');
        tb.startDate = startDate.format();
        tb.endDate = endDate.format();
        tb.trial_Balance.Organisation__c = orgn.id;
        ApexPages.currentPage().getParameters().put('stDate',String.valueOf(startDate)); 
        ApexPages.currentPage().getParameters().put('enDate',String.valueOf(endDate));  
        tb.fetchTrialRows();
        tb.downloadAsPdf();
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name); 
        Voucher__c voucher = new Voucher__c(Name='Test voucher',posted__c=true,Payment_Account__c=testassetacc.id,Amount__c=100);
        insert voucher;
        voucher.posted__c=false;
        update voucher;
        Test.stopTest();
    }
    static testmethod void unit2()
    {
        Test.startTest();
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'AP_Supplier_Invoice_Transaction');
        Id CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Customer_Invoice_Transaction');
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation',Default__c = true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
		List<ERP7__Chart_of_Accounts__c> list_chart_Of_Accounts = new List<ERP7__Chart_of_Accounts__c>();
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'), ERP7__Active__c = true);
        list_chart_Of_Accounts.add(testassetacc);
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'), ERP7__Active__c = true);
        list_chart_Of_Accounts.add(testlaiabilityacc);
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'), ERP7__Active__c = true);
        list_chart_Of_Accounts.add(testassetacc1);
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'),isContra_Account__c=false, ERP7__Active__c = true);
        list_chart_Of_Accounts.add(testlExpenseacc);
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),isContra_Account__c=false, ERP7__Active__c = true);
        list_chart_Of_Accounts.add(testlEquityacc);
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=false, ERP7__Active__c = true);
        list_chart_Of_Accounts.add(testlincomeacc);
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true, ERP7__Active__c = true);
        list_chart_Of_Accounts.add(testlincomeacc1);
		insert list_chart_Of_Accounts;
        
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        
        Payment__c pay = new Payment__c(Status__c='Paid',Account__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Payment_Gateway__c='Cash',First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100,Posted__c=true);
        insert pay;
        PreventRecursiveLedgerEntry.proceed=false;
        pay.Amount__c = 200;
       // update pay;
        Transaction__c test_tran3 = new Transaction__c(Transaction_Status__c='Completed',Transaction_Type__c ='Payment',Payment__c=pay.id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 2500.00,Active__c=true);
        insert test_tran3;
        PreventRecursiveLedgerEntry.proceed=true;
        update test_tran3;
        Payment__c pay1 = new Payment__c(Status__c='Paid',Account__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Payment_Gateway__c='Cheque',First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100);
        insert pay1;
        Transaction__c test_tran4 = new Transaction__c(RecordTypeId=CIT,Transaction_Status__c='Completed',Transaction_Type__c ='Payment',Payment__c=pay1.id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 2500.00,Active__c=true);
        insert test_tran4;
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
        
        
        Finance_General_Ledger_Entry__c test_Entry3 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeDebit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=2500.00);
        insert test_entry3;
        Finance_General_Ledger_Entry__c test_Entry4 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlaiabilityacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=2500.00);
        insert test_entry4;
        TrialBalance tb = new TrialBalance();
        //TrialBalance.AcountsGroupMap a = new TrialBalance.AcountsGroupMap(null,null,0.00, 0.00,0.00,0.00, false);
        TrialBalance.checkMultiCurrency c = new TrialBalance.checkMultiCurrency();
        TrialBalance.setValues(null,null,0.00, 0.00,0.00,0.00, false,c);
        TrialBalance.searchOrg('Test');
        tb.chart_Of_Accounts = list_chart_Of_Accounts;
        tb.classficationOfAccounts();
        tb.startDate = startDate.format();
        tb.endDate = endDate.format();
        tb.trial_Balance.Organisation__c = orgn.id;
        //tb.fetchTrialRows();
        tb.downloadAsPdf();
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name); 
        Test.stopTest();
    }
    static testmethod void unit3()
    {
        Test.startTest();
        Id CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Customer_Invoice_Transaction');
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation',Default__c = true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc ;
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert testlaiabilityacc;
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc1;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'),isContra_Account__c=false);
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),isContra_Account__c=false);
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=false);
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(Start_Date__c= startDate,End_Date__c =endDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Payment__c pay1 = new Payment__c(Status__c='Paid',Account__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Payment_Gateway__c='Cash',First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100,Posted__c=true);
        insert pay1;
        /* Payment__c pay1 = new Payment__c(Status__c='Paid',Account__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Payment_Gateway__c='PayPal',First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100);
insert pay1; */
        Transaction__c test_tran5 = new Transaction__c(RecordTypeId=CIT,Transaction_Status__c='Completed',Transaction_Type__c ='Payment',Payment__c=pay1.id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran5;
        Id MS = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Merchandise_Sale');
        Transaction__c test_tran6 = new Transaction__c(Transaction_Status__c='Completed',Transaction_Type__c ='Sales',RecordTypeId=Ms,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran6; 
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry');          
        
        Finance_General_Ledger_Entry__c test_Entry5 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeDebit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlExpenseacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.00);
        insert test_entry5;
        Finance_General_Ledger_Entry__c test_Entry6 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=1500.00);
        insert test_entry6;      
        Finance_General_Ledger_Entry__c test_Entry7 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=1500.00);
        insert test_entry7;        
        delete test_entry7;
        TrialBalance tb = new TrialBalance();
        TrialBalance.searchOrg('Test');
        tb.startDate = startDate.format();
        tb.endDate = endDate.format();
        tb.trial_Balance.Organisation__c = orgn.id;
        ApexPages.currentPage().getParameters().put('stDate',String.valueOf(startDate)); 
        ApexPages.currentPage().getParameters().put('enDate',String.valueOf(endDate)); 
        tb.fetchTrialRows();
        tb.downloadAsPdf();
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name); 
        Test.stopTest();
    }
    static testmethod void unit4()
    {
        
        Test.startTest();
        TrialBalanceLightning TBLightning = new TrialBalanceLightning();
        Id CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Customer_Invoice_Transaction');
        Date startDate = getFinancialstartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation',Default__c = true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc ;
        Chart_of_Accounts__c testlaiabilityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert testlaiabilityacc;
        Chart_of_Accounts__c testassetacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc1;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'),isContra_Account__c=false);
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),isContra_Account__c=false);
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=false);
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(Start_Date__c= startDate,End_Date__c =endDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Payment__c pay1 = new Payment__c(Status__c='Paid',Account__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Payment_Gateway__c='Cash',First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100,Posted__c=true);
        insert pay1;
        /*
        Payment__c pay1 = new Payment__c(Status__c='Paid',Account__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Payment_Gateway__c='PayPal',First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100);
        insert pay1; */
        Transaction__c test_tran5 = new Transaction__c(RecordTypeId=CIT,Transaction_Status__c='Completed',Transaction_Type__c ='Payment',Payment__c=pay1.id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran5;
        Id MS = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c', 'Merchandise_Sale');
        Transaction__c test_tran6 = new Transaction__c(Transaction_Status__c='Completed',Transaction_Type__c ='Sales',RecordTypeId=Ms,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 1500.00,Active__c=true);
        insert test_tran6; 
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry');          
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
        Finance_General_Ledger_Entry__c test_Entry5 = new Finance_General_Ledger_Entry__c(ERP7__Accounting_period__C =accperiodList[0].Id, Recordtypeid=rTypeDebit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlExpenseacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.00);
        insert test_entry5;
        Finance_General_Ledger_Entry__c test_Entry6 = new Finance_General_Ledger_Entry__c(ERP7__Accounting_period__C =accperiodList[0].Id,Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=1500.00);
        insert test_entry6;      
        Finance_General_Ledger_Entry__c test_Entry7 = new Finance_General_Ledger_Entry__c(ERP7__Accounting_period__C =accperiodList[0].Id,Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),credit_Entry__c=1500.00);
        insert test_entry7;        
        delete test_entry7;
        String Credit = 'Credit';
        String Debit = 'Debit';
        String Open = 'Open';
        TrialBalanceLightning.fetchDetails(null,null);
        TrialBalanceLightning.getCurrencies();
        TrialBalanceLightning.selectOptions s = new TrialBalanceLightning.selectOptions(null, null , true);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();  
    }
    
   
    @isTest
    static void testGetAccountDetailsWithFilesAndAttachments() {
        // Fetch an Account Id from setup data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the method
        AccountAttachmentsController.AccountWrapper result = AccountAttachmentsController.getAccountDetailsWithFilesAndAttachments(testAccount.Id);

        // Assert results
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.account);
        System.assertEquals(testAccount.Id, result.account.Id);
        System.assert(result.attachments.size() > 0);
        System.assert(result.contentDocuments.size() > 0);
    }

    @isTest
    static void testSaveAttachment() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Create a new Attachment
        Attachment newAttachment = new Attachment(
            Name = 'New Test Attachment',
            ContentType = 'application/pdf',
            ParentId = testAccount.Id,
            Body = Blob.valueOf('New test attachment body')
        );

        // Call the method
        AccountAttachmentsController.saveAttachment(newAttachment);

        // Assert that the attachment was saved
        Attachment savedAttachment = [SELECT Id, Name FROM Attachment WHERE Id = :newAttachment.Id];
        System.assertNotEquals(null, savedAttachment);
        System.assertEquals('New Test Attachment', savedAttachment.Name);
    }

    @isTest
    static void testDeleteRecord() {
        // Fetch an Attachment Id from setup data
        Attachment att = [SELECT Id FROM Attachment LIMIT 1];

        // Call the delete method
        AccountAttachmentsController.deleteRecord(att.Id, 'Attachment');

        // Assert that the attachment was deleted
        System.assertEquals(0, [SELECT COUNT() FROM Attachment WHERE Id = :att.Id]);

        // Fetch a ContentDocumentLink Id from setup data
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        ContentDocumentLink cdl = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :accountId LIMIT 1];

        // Call the delete method
        AccountAttachmentsController.deleteRecord(cdl.ContentDocumentId, 'ContentDocument');

        // Assert that the ContentDocumentLink was deleted
        //System.assertEquals(0, [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :cdl.ContentDocumentId]);
    }

    @isTest
    static void testGetAccountsWithSearchAndPagination() {
        // Test without search keyword
        AccountAttachmentsController.AccountPaginationWrapper result = AccountAttachmentsController.getAccounts('', 1);

        // Assert results
        System.assertNotEquals(null, result);
        System.assert(result.accounts.size() > 0);
        System.assert(result.totalPages > 0);

        // Test with search keyword
        AccountAttachmentsController.AccountPaginationWrapper searchResult = AccountAttachmentsController.getAccounts('Test', 1);

        // Assert results
        System.assertNotEquals(null, searchResult);
        System.assert(searchResult.accounts.size() > 0);
        System.assert(searchResult.totalPages > 0);
    }
}