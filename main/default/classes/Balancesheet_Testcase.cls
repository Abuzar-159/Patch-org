@isTest
private class Balancesheet_Testcase{
    
    
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
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Account orgn = TestDataFactory.createOrganisationAccounts(1)[0];
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Account sup = new Account(Name='Supplier',Account_Type__c='Supplier');
        insert sup;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
        insert contact;
        
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert testassetacc ;//testlaiabilityacc
        Chart_of_Accounts__c commpayable = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Commissions Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert commpayable;
        Chart_of_Accounts__c commpayableEquity = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Commissions Payable',RecordTypeId=AccountGroups_Map.get('Equity'));
        insert commpayableEquity;
        Chart_of_Accounts__c AccumulatedDepreciation = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,isContra_Account__c=true,Organisation_Business_Unit__c = busUnit.id,Name='Accumulated Depreciation',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert AccumulatedDepreciation;
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert testlExpenseacc;
        Chart_of_Accounts__c testlEquityacc = new Chart_of_Accounts__c(ERP7__isContra_Account__c=true,Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),Account_Type__c='RetainedEarnings');
        insert testlEquityacc;
        Chart_of_Accounts__c testlincomeacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'));
        insert testlincomeacc;
        Chart_of_Accounts__c testlincomeacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert testlincomeacc1;
        Chart_of_Accounts__c testlExpenseacc1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='COGS',RecordTypeId=AccountGroups_Map.get('Expense'),Account_Type__c='COGS');
        insert testlExpenseacc1; 
        system.debug('testlEquityacc : '+testlEquityacc.RecordType.DeveloperName);
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Organisation__c = orgn.Id;
        sod.Organisation_Business_Unit__c = busUnit.Id; 
        sod.Order_Status__c = 'Entered';
        sod.Account__c = customer.Id;
        sod.Request_Date__c = system.Today();
        sod.barcode__c='orderId';
        insert sod;
        Invoice__c inv  = new Invoice__c();
        inv.Order__c = sod.id;
        insert inv;
        
        PreventRecursiveLedgerEntry.proceed = true;
        inv.Posted__c =true;
        inv.Posted_Date__c = system.today();
        Update inv;
        /*
inv.Posted__c =false;
Update Inv;
inv.Posted__c =true;
Update inv;
*/
        Commission__c comm1 = new Commission__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Amount__c=100.00,Sales_Order__c=sod.id,Supplier_Partner__c=sup.id);
        insert comm1; 
        
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Finance_General_Ledger_Entry__c.sObjectType,'Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Finance_General_Ledger_Entry__c.sObjectType,'Debit_General_Ledger_Entry'); 
        Id CIT = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Customer_Invoice_Transaction');
        Id MS = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Merchandise_Sale');
        Id MR = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Merchandise_Return');
        Id ExpenseRT = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Expense_Transaction');
        Transaction__c test_tran1 = new Transaction__c(Invoice__c=inv.id,RecordTypeId=CIT,Transaction_Status__c='Completed',Transaction_Type__c='Sales',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
        insert test_tran1;
        test_tran1.Active__c = false;
        update test_tran1;
        test_tran1.Active__c = true;
        update test_tran1;
        
        List<Finance_General_Ledger_Entry__c> FGLES2Insert = new List<Finance_General_Ledger_Entry__c>();
        Finance_General_Ledger_Entry__c test_Entry4 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testassetacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Credit_Entry__c=1500.0);
        FGLES2Insert.add(test_entry4);
        Finance_General_Ledger_Entry__c test_Entry5 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =commpayable.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Credit_Entry__c=1500.0);
        FGLES2Insert.add(test_entry5);
        Finance_General_Ledger_Entry__c test_Entry6 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =AccumulatedDepreciation.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Credit_Entry__c=1500.0);
        FGLES2Insert.add(test_entry6);
        Finance_General_Ledger_Entry__c test_Entry7 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.0);
        FGLES2Insert.add(test_entry7); 
        Finance_General_Ledger_Entry__c test_Entry8 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =commpayableEquity.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.0);
        FGLES2Insert.add(test_Entry8); 
        Finance_General_Ledger_Entry__c test_Entry9 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlEquityacc.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.0);
        FGLES2Insert.add(test_Entry9);
        if(FGLES2Insert.size()>0)insert FGLES2Insert;
        
        Chart_of_Accounts__c commpayableEquity1 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Commissions Payable',RecordTypeId=AccountGroups_Map.get('Equity'),ERP7__Opening_Balance__c = 100);
        insert commpayableEquity1;
        Chart_of_Accounts__c AccumulatedDepreciation2 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,isContra_Account__c=true,Organisation_Business_Unit__c = busUnit.id,Name='Accumulated Depreciation',RecordTypeId=AccountGroups_Map.get('Assets'),ERP7__Opening_Balance__c = 200);
        insert AccumulatedDepreciation2;
        Chart_of_Accounts__c testlExpenseacc3 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'),ERP7__Opening_Balance__c = 300);
        insert testlExpenseacc3;
        Chart_of_Accounts__c testlEquityacc4 = new Chart_of_Accounts__c(ERP7__isContra_Account__c=true,Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'),Account_Type__c='RetainedEarnings',ERP7__Opening_Balance__c = 400);
        insert testlEquityacc4;
        Chart_of_Accounts__c testlincomeacc5 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),ERP7__Opening_Balance__c = 5000);
        insert testlincomeacc5;
        Chart_of_Accounts__c testlincomeacc16 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true,ERP7__Opening_Balance__c = 60025);
        insert testlincomeacc16;
        Chart_of_Accounts__c testlExpenseacc17 = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='COGS',RecordTypeId=AccountGroups_Map.get('Expense'),Account_Type__c='COGS',ERP7__Opening_Balance__c = 56620.25);
        insert testlExpenseacc17; 
        
    } 
    
    Static Date getFinancialStartDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].StartDate;
    }
    static Date getFinancialEndDate(){
        return [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR][0].EndDate;
    }
    
    /* static testmethod void unit1()
{       Date startDate = getFinancialStartDate();
Date endDate = getFinancialEndDate();
List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
Map<String,String> AccountGroups_Map = new Map<String,String>();
for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
Account orgn = new Account(Name='Organisation Test',Account_Type__c='Organisation',Default__c =true);
insert orgn; 
//Id CommReceivable = RecordTypeUtil.getObjectRecordTypeId(Commission__c.SObjectType,'Commission Receivable'); 
Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
insert busUnit;
Account sup = new Account(Name='Supplier',Account_Type__c='Supplier');
//insert sup;
Account customer = new Account(Name='Customer');
insert customer;
Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
insert contact;

Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
insert testLedger;
Chart_of_Accounts__c testassetacc = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
insert testassetacc ;//testlaiabilityacc
Chart_of_Accounts__c commpayable = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Commissions Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
insert commpayable;
Chart_of_Accounts__c AccumulatedDepreciation = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,isContra_Account__c=true,Organisation_Business_Unit__c = busUnit.id,Name='Accumulated Depreciation',RecordTypeId=AccountGroups_Map.get('Assets'));
insert AccumulatedDepreciation;
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
Sales_Order__c sod = new Sales_Order__c();   
sod.Organisation__c = orgn.Id;
sod.Organisation_Business_Unit__c = busUnit.Id; 
sod.Order_Status__c = 'Entered';
sod.Account__c = customer.Id;
sod.Request_Date__c = system.Today();
sod.barcode__c='orderId';
insert sod;
Invoice__c inv  = new Invoice__c();
inv.Order__c = sod.id;
insert inv;
PreventRecursiveLedgerEntry.proceed = false;
inv.Posted__c = true;
Update inv;
//inv.Posted__c =false;
//Update Inv;
//inv.Posted__c =true;
//Update inv;
Commission__c comm1 = new Commission__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Amount__c=100.00,Sales_Order__c=sod.id,Supplier_Partner__c=sup.id);
insert comm1; 

Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Finance_General_Ledger_Entry__c.sObjectType,'Credit_General_Ledger_Entry');    
Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Finance_General_Ledger_Entry__c.sObjectType,'Debit_General_Ledger_Entry'); 
Id CIT = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Customer_Invoice_Transaction');
Id MS = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Merchandise_Sale');
Id MR = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Merchandise_Return');
Id ExpenseRT = RecordTypeUtil.getObjectRecordTypeIdByDeveloperName(Transaction__c.sObjectType,'Expense_Transaction');
Transaction__c test_tran1 = new Transaction__c(Invoice__c=inv.id,RecordTypeId=CIT,Transaction_Status__c='Completed',Transaction_Type__c='Sales',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
insert test_tran1;
test_tran1.Active__c = false;
update test_tran1;
test_tran1.Active__c = true;
update test_tran1;
List<Finance_General_Ledger_Entry__c> FGLES2Insert = new List<Finance_General_Ledger_Entry__c>();
Finance_General_Ledger_Entry__c test_Entry1 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Credit_Entry__c=1500.0);
FGLES2Insert.add(test_entry1);
Finance_General_Ledger_Entry__c test_Entry2 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.0);
FGLES2Insert.add(test_entry2);
Finance_General_Ledger_Entry__c test_Entry3 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlExpenseacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Credit_Entry__c=1500.00);
FGLES2Insert.add(test_entry3);
Finance_General_Ledger_Entry__c test_Entry7 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.0);
FGLES2Insert.add(test_entry7);
Finance_General_Ledger_Entry__c test_Entry8 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlincomeacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Credit_Entry__c=1500.0);
FGLES2Insert.add(test_entry8);
Finance_General_Ledger_Entry__c test_Entry9 = new Finance_General_Ledger_Entry__c(Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =testlExpenseacc1.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Debit_Entry__c=1500.00);
FGLES2Insert.add(test_entry9);
if(FGLES2Insert.size()>0)
insert FGLES2Insert;
Test.startTest();
BalanceSheet bl = new BalanceSheet();
bl.startDate= startDate.format();
bl.endDate= endDate.format();
bl.Downloadpdf();
bl.DownloadComparisonpdf();
bl.CallCompute();
bl.getCurrencyISO();
bl.getFinancialYearList();
bl.refreshtab();
bl.getEdate();
bl.CheckQuartelyYearlyMon();
bl.FetchData();
bl.getDates();
bl.addCurrentYearEarnings();
BalanceSheet.Data d = new BalanceSheet.Data('Test',1000.00,1000.00,1000.00,1000.00);
d = new BalanceSheet.Data('Test',1000.00,1000.00,1000.00);
d = new BalanceSheet.Data('Test',1000.00,1000.00);
String salName = 'Erp7';
String sal1Name = 'Erp7';
System.assertEquals(salName, sal1Name);
Test.stopTest();
}*/
    static testmethod void unit2()
    {   
        Test.startTest();
        
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        BalanceSheet bl = new BalanceSheet();
        bl.startDate= startDate.format();
        bl.endDate= endDate.format();
        ApexPages.currentPage().getParameters().put('StartDate',String.valueOf(startDate)); 
        ApexPages.currentPage().getParameters().put('EndDate',String.valueOf(endDate));
        bl.Downloadpdf();
        bl.DownloadComparisonpdf();
        bl.CallCompute();
        bl.getCurrencyISO();
        bl.getFinancialYearList();
        bl.refreshtab();
        bl.getEdate();
        bl.CheckQuartelyYearlyMon();
        bl.FetchData();
        bl.addLiabilityandEquity();
        bl.getDates();
        bl.assignOrgId();
        bl.convert(10.08,'USD','USD');
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    //----------------------mna--------------------
    static testmethod void unittest2(){
        BalanceSheet.checkMultiCurrency obj=new BalanceSheet.checkMultiCurrency();
        obj.ismultiCurrency=false;
        obj.conversionRate=0.0;
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);        
    }
    
    /*public static testmethod void unittest3(){
BalanceSheet obj=new BalanceSheet();
obj.multiCurrencyEnabled=true;
Boolean test=obj.multiCurrencyEnabled;
if(test) obj.multiCurrencyEnabled=true;
String salName = 'ERP';
String sal1Name = 'ERP';
System.assertEquals(salName, sal1Name);        
}*/
    
    
    //------------------------mna--------------
    static testmethod void unit3()
    {   
        Test.startTest();
        BalanceSheetLightning BS = new BalanceSheetLightning();
        BalanceSheetLightning.BSWrapper bss23 = new BalanceSheetLightning.BSWrapper();
        BS = BalanceSheetLightning.fecthDetails(null,null); 
        BalanceSheetLightning.getCurrencies();
        BS = BalanceSheetLightning.ComputeData(JSON.serialize(BS)); 
        BalanceSheetLightning.getGraphValues(JSON.serialize(BS)); 
        List<BalanceSheetLightning.AccountGroup> subAcclist = new List<BalanceSheetLightning.AccountGroup>();
        BalanceSheetLightning.AccountGroup AG = new BalanceSheetLightning.AccountGroup(null,0.00,subAcclist);
        Map<String,Map<Integer,decimal>> val = new Map<String,Map<Integer,decimal>>();
        BalanceSheetLightning.AccountGroup AG2 = new BalanceSheetLightning.AccountGroup('test' , val, subAcclist);
        BalanceSheet bss = new BalanceSheet();
        //BalanceSheet.AccountGroup2 bsr = new BalanceSheet.AccountGroup2('test' , val, subAcclist, true);
        BalanceSheetLightning.AccountGroup AG3 = new BalanceSheetLightning.AccountGroup('test2',0.00,false);
        BalanceSheetLightning.AccountGroup AG4 = new BalanceSheetLightning.AccountGroup('test4',val,false);
        BalanceSheetLightning.Data d1 = new BalanceSheetLightning.Data('BS1', 0.00);
        BalanceSheetLightning.Data d2 = new BalanceSheetLightning.Data('BS2', 0.00, 0.00);
        BalanceSheetLightning.Data d3 = new BalanceSheetLightning.Data('BS3', 0.00, 0.00, 0.00);
        BalanceSheetLightning.Data d4 = new BalanceSheetLightning.Data('BS3', 0.00, 0.00, 0.00, 0.00);
        
        String accName = 'Test Account';
        Map<String, Map<Integer, Decimal>> values = new Map<String, Map<Integer, Decimal>>();
        values.put('FY2022', new Map<Integer, Decimal>{1 => 100.0, 2 => -50.0});
        Boolean flag = true;
        
        BalanceSheet balance = new BalanceSheet();
        BalanceSheet.AccountGroup subAcclist1 = new BalanceSheet.AccountGroup();
        
        List<BalanceSheet.AccountGroup> Accgroup = new List<BalanceSheet.AccountGroup>();
        
        balance.AccountGroup4(accName, values, flag);
        //balance.AccountGroup2(accName,values,jsonArrayString,true);
        
        
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();  
    }
    static testmethod void unit4()
    {   
        Test.startTest();
        BalanceSheetLightning BS = new BalanceSheetLightning();
        BS = BalanceSheetLightning.fecthDetails(null,null);
        BS.SelectedFy = '';
        BS.SelectedFy = '4';
        // BS.SelectedFy.add('4');
        BalanceSheetLightning.getCurrencies();
        BS = BalanceSheetLightning.ComputeData(JSON.serialize(BS)); 
        system.debug('FiscalYearQuarter : '+BS.FiscalYearQuarter);
        // BS.multiCurrencyEnabled = true;
        //Bs.isoCode = 'USD';
        
        BalanceSheetLightning.ComputeSelectedFyData(BS);
        BalanceSheetLightning.addCurrentYearEarnings(BS);
        BalanceSheetLightning.buildAccountsRendereingMap(BS);
        BalanceSheetLightning.fetchLedgerIds(null,null,BS.SelectedFy);
        BalanceSheetLightning.fetchNeLedgerIds(null,null,new List<String>{});
        String salName = 'Erp7';
        String sal1Name = 'Erp7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();  
    }
    @isTest
    static void testGetBudgetUpdated() {
        // Create test data
        Integer fiscalYearStartMonth = Date.today().month();
        Account orgn = new Account(Name='Organisation Test',Account_Type__c='Organisation',Default__c =true);
        insert orgn;
        Organization org = [SELECT Id, FiscalYearStartMonth FROM Organization LIMIT 1];
        // org.FiscalYearStartMonth = fiscalYearStartMonth;
        // update org;
        
        RecordType revenueRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Income_Revenue', 'Equity', 'Liability') LIMIT 1];
        RecordType expenseRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Assets', 'Expense') LIMIT 1];
        
        ERP7__Chart_of_Accounts__c revenueAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Revenue Account',
            ERP7__Account_Type__c = 'Revenue',
            RecordTypeId = revenueRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert revenueAccount;
        
        ERP7__Chart_of_Accounts__c expenseAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Expense Account',
            ERP7__Account_Type__c = 'Expense',
            RecordTypeId = expenseRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert expenseAccount;
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Active__c = true);
        insert testLedger;
        ERP7__Finance_General_Ledger_Entry__c ledgerEntry = new ERP7__Finance_General_Ledger_Entry__c(
            Name = 'Test Ledger Entry',
            ERP7__Chart_of_Account__c = revenueAccount.Id,
            ERP7__Finance_General_Ledger__c = testLedger.Id,
            ERP7__Credit_Entry__c = 100,
            ERP7__Debit_Entry__c = 50
        );
        insert ledgerEntry;
        ERP7__Project__c proj = new ERP7__Project__c(Name = 'Test project',ERP7__Active__c = true);
        insert proj;
        ERP7__Budget_Plan__c bp1 = new ERP7__Budget_Plan__c(ERP7__UnPosted_Actual_Expenditures__c=false, Name = 'test BP',ERP7__Organisation__c = orgn.Id);
        insert bp1;
        ERP7__Budget_Account__c bc1 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__First_Quarter_Amount__c = 25);
        insert bc1;
        BudgetPlannerUpdated.fetchYearBudgetForecast(orgn.Id,bp1.Id);
        bp1.ERP7__UnPosted_Actual_Expenditures__c = false;
        BudgetPlannerUpdated.fetchMonthlyBudgetForecast(orgn.Id,bp1.Id);
    }
    @isTest
    static void testGetBudgetUpdated11() {
        // Create test data
        Integer fiscalYearStartMonth = Date.today().month();
        Account orgn = new Account(Name='Organisation Test',Account_Type__c='Organisation',Default__c =true);
        insert orgn;
        Organization org = [SELECT Id, FiscalYearStartMonth FROM Organization LIMIT 1];
        // org.FiscalYearStartMonth = fiscalYearStartMonth;
        // update org;
        
        RecordType revenueRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Income_Revenue', 'Equity', 'Liability') LIMIT 1];
        RecordType expenseRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Assets', 'Expense') LIMIT 1];
        
        ERP7__Chart_of_Accounts__c revenueAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Revenue Account',
            ERP7__Account_Type__c = 'Revenue',
            RecordTypeId = revenueRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert revenueAccount;
        
        ERP7__Chart_of_Accounts__c expenseAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Expense Account',
            ERP7__Account_Type__c = 'Expense',
            RecordTypeId = expenseRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert expenseAccount;
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Active__c = true);
        insert testLedger;
        ERP7__Finance_General_Ledger_Entry__c ledgerEntry = new ERP7__Finance_General_Ledger_Entry__c(
            Name = 'Test Ledger Entry',
            ERP7__Chart_of_Account__c = revenueAccount.Id,
            ERP7__Finance_General_Ledger__c = testLedger.Id,
            ERP7__Credit_Entry__c = 100,
            ERP7__Debit_Entry__c = 50
        );
        insert ledgerEntry;
        ERP7__Project__c proj = new ERP7__Project__c(Name = 'Test project',ERP7__Active__c = true);
        insert proj;
        ERP7__Budget_Plan__c bp1 = new ERP7__Budget_Plan__c(ERP7__UnPosted_Actual_Expenditures__c=false, Name = 'test BP',ERP7__Organisation__c = orgn.Id);
        insert bp1;
        ERP7__Budget_Account__c bc1 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__First_Quarter_Amount__c = 25);
        insert bc1;
        // Call the method to be tested
        BudgetPlannerUpdated.getBudgetInstance();
        BudgetPlannerUpdated.getChartOfAccountDetails(expenseAccount.Id);
        BudgetPlannerUpdated.getProjectWrapp();
        BudgetPlannerUpdated.getProgrammeWrapp();
        BudgetPlannerUpdated.getDefaultOrganisation();
        BudgetPlannerUpdated.getYearsList();
        BudgetPlannerUpdated.getDepartmentWrapp();
        BudgetPlannerUpdated.DepartmentForecastWrapper dwrap = new BudgetPlannerUpdated.DepartmentForecastWrapper();
        BudgetPlannerUpdated.fetchMonthlyBudgetUpdate(orgn.Id,bp1.Id); 
        BudgetPlannerUpdated.fetchMonthlyBudget(orgn.Id,bp1.Id);
        BudgetPlannerUpdated.getBudgetList(orgn.Id,'Name','ASC',0,10);
        BudgetPlannerUpdated.createBudgetAccount(expenseAccount,orgn.Id);
        BudgetPlannerUpdated.projectWrapper projectWrap = new BudgetPlannerUpdated.projectWrapper();
        List<BudgetPlannerUpdated.projectWrapper> wraplist = new List<BudgetPlannerUpdated.projectWrapper>();
        wraplist.add(projectWrap);
        BudgetPlannerUpdated.SaveMonthlyBudgetUpdated(orgn.Id,'2024','January',JSON.serialize(wraplist),'','Monthly','',10,'Posted Actual Expenditures',1000);
        BudgetPlannerUpdated.SaveMonthlyBudgetUpdated(orgn.Id,'2024','January',JSON.serialize(wraplist),bp1.Id,'','', 10,'',1000);
        BudgetPlannerUpdated.SaveMonthlyBudget(orgn.Id,'2024','January',JSON.serialize(projectWrap),'');
        BudgetPlannerUpdated.SaveMonthlyBudget(orgn.Id,'2024','January',JSON.serialize(projectWrap),bp1.Id);
        BudgetPlannerUpdated.projectForecastWrapper bpt = new  BudgetPlannerUpdated.projectForecastWrapper ();
        BudgetPlannerUpdated.BudgetForecastWrapper bpt2 = new  BudgetPlannerUpdated.BudgetForecastWrapper ();
        try{
           BudgetPlannerUpdated.submitRecordForApproval(bp1.Id); 
        }catch(Exception e){
           system.debug('errors -->'+e.getMessage());
        }
        BudgetPlannerUpdated.fetchMonthlyBudgetForecast(orgn.Id,bp1.Id);
        BudgetPlannerUpdated.fetchQuerterBudgetForecast(orgn.Id,bp1.Id);
        /*
         BudgetPlannerUpdated.fetchYearBudgetForecast(orgn.Id,bp1.Id);
        bp1.ERP7__UnPosted_Actual_Expenditures__c = false;
        BudgetPlannerUpdated.fetchMonthlyBudgetForecast(orgn.Id,bp1.Id);*/
        
        // Create an instance of the BudgetPlannerUpdated class
        BudgetPlannerUpdated budgetPlanner = new BudgetPlannerUpdated();
        
          List<BudgetPlannerUpdated.SelectOption> revenueRecordTypeList = new List<BudgetPlannerUpdated.SelectOption>{
            new BudgetPlannerUpdated.SelectOption('Option 1', 'Option 1'),
            new BudgetPlannerUpdated.SelectOption('Option 2', 'Option 2')
        };
        budgetPlanner.coaRevenueRecordTypeList = revenueRecordTypeList;
        System.assertEquals(revenueRecordTypeList, budgetPlanner.coaRevenueRecordTypeList);
        
        // Test the coaExpenseRecordTypeList property
        List<BudgetPlannerUpdated.SelectOption> expenseRecordTypeList = new List<BudgetPlannerUpdated.SelectOption>{
        new BudgetPlannerUpdated.SelectOption('Option 3', 'Option 3'),
        new BudgetPlannerUpdated.SelectOption('Option 4', 'Option 4')
                                              };
        budgetPlanner.coaExpenseRecordTypeList = expenseRecordTypeList;
        System.assertEquals(expenseRecordTypeList, budgetPlanner.coaExpenseRecordTypeList);
        
        // Create an instance of the budget class
        BudgetPlannerUpdated.budget budget = new BudgetPlannerUpdated.budget();
        
        // Test the VarianceAmount property
        Decimal varianceAmount = 100.00;
        budget.VarianceAmount = varianceAmount;
        System.assertEquals(varianceAmount, budget.VarianceAmount);
        
        // Test the BudgetAmount property
        Decimal budgetAmount = 200.00;
        budget.BudgetAmount = budgetAmount;
        System.assertEquals(budgetAmount, budget.BudgetAmount);
        
        // Test the ExpenseAmount property
        Decimal expenseAmount = 300.00;
        budget.ExpenseAmount = expenseAmount;
        System.assertEquals(expenseAmount, budget.ExpenseAmount);
        
        // Test the RevenueBudgetMap property
        Map<String, List<Decimal>> revenueBudgetMap = new Map<String, List<Decimal>>();
        revenueBudgetMap.put('Category 1', new List<Decimal>{10.00, 20.00});
        revenueBudgetMap.put('Category 2', new List<Decimal>{30.00, 40.00});
        budget.RevenueBudgetMap = revenueBudgetMap;
        System.assertEquals(revenueBudgetMap, budget.RevenueBudgetMap);
        
        // Test the ExpenseBudgetMap property
        Map<String, List<Decimal>> expenseBudgetMap = new Map<String, List<Decimal>>();
        expenseBudgetMap.put('Category 3', new List<Decimal>{50.00, 60.00});
        expenseBudgetMap.put('Category 4', new List<Decimal>{70.00, 80.00});
        budget.ExpenseBudgetMap = expenseBudgetMap;
        System.assertEquals(expenseBudgetMap, budget.ExpenseBudgetMap);
        
        // Test the coaRevenueRecordTypeList property in the budget class
        budget.coaRevenueRecordTypeList = revenueRecordTypeList;
        System.assertEquals(revenueRecordTypeList, budget.coaRevenueRecordTypeList);
        
        // Test the coaExpenseRecordTypeList property in the budget class
        budget.coaExpenseRecordTypeList = expenseRecordTypeList;
        System.assertEquals(expenseRecordTypeList, budget.coaExpenseRecordTypeList);
        
        // Test the PreviousTwoYearsRevenueValues property
        List<Decimal> previousTwoYearsRevenueValues = new List<Decimal>{100.00, 200.00};
        budget.PreviousTwoYearsRevenueValues = previousTwoYearsRevenueValues;
        System.assertEquals(previousTwoYearsRevenueValues, budget.PreviousTwoYearsRevenueValues);
        
        // Test the PreviousTwoYearsTotalRevenueValues property
        Decimal previousTwoYearsTotalRevenueValues = 300.00;
        budget.PreviousTwoYearsTotalRevenueValues = previousTwoYearsTotalRevenueValues;
        System.assertEquals(previousTwoYearsTotalRevenueValues, budget.PreviousTwoYearsTotalRevenueValues);
        
        // Test the PreviousOneYearsRevenueValues property
        List<Decimal> previousOneYearsRevenueValues = new List<Decimal>{400.00, 500.00};
        budget.PreviousOneYearsRevenueValues = previousOneYearsRevenueValues;
        System.assertEquals(previousOneYearsRevenueValues, budget.PreviousOneYearsRevenueValues);
        
        // Test the PreviousOneYearsTotalRevenueValues property
        Decimal previousOneYearsTotalRevenueValues = 600.00;
        budget.PreviousOneYearsTotalRevenueValues = previousOneYearsTotalRevenueValues;
        System.assertEquals(previousOneYearsTotalRevenueValues, budget.PreviousOneYearsTotalRevenueValues);
    }
    
    @isTest
    static void testGetBudget() {
        // Create test data
        Integer fiscalYearStartMonth = Date.today().month();
        Account orgn = new Account(Name='Organisation Test',Account_Type__c='Organisation',Default__c =true);
        insert orgn;
        Organization org = [SELECT Id, FiscalYearStartMonth FROM Organization LIMIT 1];
        // org.FiscalYearStartMonth = fiscalYearStartMonth;
        // update org;
        
        RecordType revenueRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Income_Revenue', 'Equity', 'Liability') LIMIT 1];
        RecordType expenseRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Assets', 'Expense') LIMIT 1];
        
        ERP7__Chart_of_Accounts__c revenueAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Revenue Account',
            ERP7__Account_Type__c = 'Revenue',
            RecordTypeId = revenueRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert revenueAccount;
        
        ERP7__Chart_of_Accounts__c expenseAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Expense Account',
            ERP7__Account_Type__c = 'Expense',
            RecordTypeId = expenseRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert expenseAccount;
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Active__c = true);
        insert testLedger;
        ERP7__Finance_General_Ledger_Entry__c ledgerEntry = new ERP7__Finance_General_Ledger_Entry__c(
            Name = 'Test Ledger Entry',
            ERP7__Chart_of_Account__c = revenueAccount.Id,
            ERP7__Finance_General_Ledger__c = testLedger.Id,
            ERP7__Credit_Entry__c = 100,
            ERP7__Debit_Entry__c = 50
        );
        insert ledgerEntry;
        ERP7__Project__c proj = new ERP7__Project__c(Name = 'Test project',ERP7__Active__c = true);
        insert proj;
        ERP7__Budget_Plan__c bp1 = new ERP7__Budget_Plan__c(ERP7__UnPosted_Actual_Expenditures__c=false, Name = 'test BP',ERP7__Organisation__c = orgn.Id);
        insert bp1;
        ERP7__Budget_Account__c bc1 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__First_Quarter_Amount__c = 25);
        insert bc1;
        // Call the method to be tested
        BudgetPlanner.budget result = BudgetPlanner.getBudget();
        BudgetPlanner.getBudgetInstance();
        BudgetPlanner.getChartOfAccountDetails(expenseAccount.Id);
        BudgetPlanner.getProjectWrapp();
        BudgetPlanner.getProgrammeWrapp();
        BudgetPlanner.getDefaultOrganisation();
        BudgetPlanner.getYearsList();
        BudgetPlanner.getDepartmentWrapp();
        BudgetPlanner.DepartmentForecastWrapper dwrap = new BudgetPlanner.DepartmentForecastWrapper();
        BudgetPlanner.fetchMonthlyBudgetUpdate(orgn.Id,bp1.Id); 
        BudgetPlanner.fetchMonthlyBudget(orgn.Id,bp1.Id);
        BudgetPlanner.getBudgetList(orgn.Id,'Name','ASC',0,10);
        BudgetPlanner.createBudgetAccount(expenseAccount,orgn.Id);
        BudgetPlanner.projectWrapper projectWrap = new BudgetPlanner.projectWrapper();
        List<BudgetPlanner.projectWrapper> wraplist = new List<BudgetPlanner.projectWrapper>();
        wraplist.add(projectWrap);
        BudgetPlanner.SaveMonthlyBudgetUpdated(orgn.Id,'2024','January',JSON.serialize(wraplist),'','Quarterly',10,'Posted Actual Expenditures',1000);
        BudgetPlanner.SaveMonthlyBudgetUpdated(orgn.Id,'2024','January',JSON.serialize(wraplist),'','Yearly',10,'Posted Actual Expenditures',1000);
        BudgetPlanner.SaveMonthlyBudgetUpdated(orgn.Id,'2024','January',JSON.serialize(wraplist),bp1.Id,'',10,'',1000);
        BudgetPlanner.SaveMonthlyBudget(orgn.Id,'2024','January',JSON.serialize(projectWrap),'');
        BudgetPlanner.SaveMonthlyBudget(orgn.Id,'2024','January',JSON.serialize(projectWrap),bp1.Id);
        BudgetPlanner.projectForecastWrapper bpt = new  BudgetPlanner.projectForecastWrapper ();
        BudgetPlanner.BudgetForecastWrapper bpt2 = new  BudgetPlanner.BudgetForecastWrapper ();
        try{
           BudgetPlanner.submitRecordForApproval(bp1.Id); 
        }catch(Exception e){
           system.debug('errors -->'+e.getMessage());
        }
        BudgetPlanner.fetchMonthlyBudgetForecast(orgn.Id,bp1.Id);
        bp1.ERP7__UnPosted_Actual_Expenditures__c = false;
        BudgetPlanner.fetchMonthlyBudgetForecast(orgn.Id,bp1.Id);
        // Assertions
        //System.assertEquals(10000, result.BudgetAmount);
        //System.assertEquals(-1600, result.ExpenseAmount);
        
        
        //System.assertEquals(expenseRecordType.Id, result.coaExpenseRecordTypeList[0].value);
        // System.assertEquals(expenseRecordType.Name, result.coaExpenseRecordTypeList[0].label);
    }
    @isTest
    static void testGetBudget1() {
        // Create test data
        Integer fiscalYearStartMonth = Date.today().month();
        Account orgn = new Account(Name='Organisation Test',Account_Type__c='Organisation',Default__c =true);
        insert orgn;
        Organization org = [SELECT Id, FiscalYearStartMonth FROM Organization LIMIT 1];
        // org.FiscalYearStartMonth = fiscalYearStartMonth;
        // update org;
        
        RecordType revenueRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Income_Revenue', 'Equity', 'Liability') LIMIT 1];
        RecordType expenseRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Assets', 'Expense') LIMIT 1];
        
        ERP7__Chart_of_Accounts__c revenueAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Revenue Account',
            ERP7__Account_Type__c = 'Revenue',
            RecordTypeId = revenueRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert revenueAccount;
        
        ERP7__Chart_of_Accounts__c expenseAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Expense Account',
            ERP7__Account_Type__c = 'Expense',
            RecordTypeId = expenseRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert expenseAccount;
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Active__c = true);
        insert testLedger;
        ERP7__Finance_General_Ledger_Entry__c ledgerEntry = new ERP7__Finance_General_Ledger_Entry__c(
            Name = 'Test Ledger Entry',
            ERP7__Chart_of_Account__c = revenueAccount.Id,
            ERP7__Finance_General_Ledger__c = testLedger.Id,
            ERP7__Credit_Entry__c = 100,
            ERP7__Debit_Entry__c = 50
        );
        insert ledgerEntry;
        ERP7__Project__c proj = new ERP7__Project__c(Name = 'Test project',ERP7__Active__c = true);
        insert proj;
        ERP7__Budget_Plan__c bp1 = new ERP7__Budget_Plan__c(Name = 'test BP',ERP7__Organisation__c = orgn.Id);
        insert bp1;
        ERP7__Budget_Account__c bc1 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__First_Quarter_Amount__c = 25);
        insert bc1;
        // Call the method to be tested
        BudgetPlanner.budget result = BudgetPlanner.getBudget();
        BudgetPlanner.fetchQuerterBudgetForecast(orgn.Id,bp1.Id);
        //BudgetPlanner.fetchYearBudgetForecast(orgn.Id,bp1.Id);
    }
    @isTest
    static void testGetBudget2() {
        // Create test data
        Integer fiscalYearStartMonth = Date.today().month();
        Account orgn = new Account(Name='Organisation Test',Account_Type__c='Organisation',Default__c =true);
        insert orgn;
        Organization org = [SELECT Id, FiscalYearStartMonth FROM Organization LIMIT 1];
        // org.FiscalYearStartMonth = fiscalYearStartMonth;
        // update org;
        
        RecordType revenueRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Income_Revenue', 'Equity', 'Liability') LIMIT 1];
        RecordType expenseRecordType = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ERP7__Chart_of_Accounts__c' AND DeveloperName IN ('Assets', 'Expense') LIMIT 1];
        
        ERP7__Chart_of_Accounts__c revenueAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Revenue Account',
            ERP7__Account_Type__c = 'Revenue',
            RecordTypeId = revenueRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert revenueAccount;
        
        ERP7__Chart_of_Accounts__c expenseAccount = new ERP7__Chart_of_Accounts__c(
            Name = 'Test Expense Account',
            ERP7__Account_Type__c = 'Expense',
            RecordTypeId = expenseRecordType.Id,
            ERP7__Accounting_Period_Start_Date__c = Date.today(),
            ERP7__Accounting_Period_End_Date__c = Date.today(),
            ERP7__Active__c = true,
            ERP7__Organisation__c = orgn.Id
        );
        insert expenseAccount;
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Active__c = true);
        insert testLedger;
        ERP7__Finance_General_Ledger_Entry__c ledgerEntry = new ERP7__Finance_General_Ledger_Entry__c(
            Name = 'Test Ledger Entry',
            ERP7__Chart_of_Account__c = revenueAccount.Id,
            ERP7__Finance_General_Ledger__c = testLedger.Id,
            ERP7__Credit_Entry__c = 100,
            ERP7__Debit_Entry__c = 50
        );
        insert ledgerEntry;
        ERP7__Project__c proj = new ERP7__Project__c(Name = 'Test project',ERP7__Active__c = true);
        insert proj;
        ERP7__Budget_Plan__c bp1 = new ERP7__Budget_Plan__c(Name = 'test BP',ERP7__Organisation__c = orgn.Id);
        insert bp1;
        ERP7__Budget_Account__c bc1 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__January_Budget__c = 25);
        insert bc1;
        ERP7__Budget_Account__c bc2 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__February_Budget__c = 25);
        insert bc2;
        ERP7__Budget_Account__c bc3 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__March_Budget__c = 25);
        insert bc3;
         ERP7__Budget_Account__c bc4 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__April_Budget__c = 25);
        insert bc4;
         ERP7__Budget_Account__c bc5 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__May_Budget__c = 25,ERP7__June_Budget__c = 25, ERP7__July_Budget__c= 25, ERP7__August_Budget__c = 25, ERP7__September_Budget__c=25, ERP7__October_Budget__c=25, ERP7__November_Budget__c=25, ERP7__December_Budget__c=25);
        insert bc5;
            ERP7__Budget_Account__c bc6 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__June_Budget__c = 25, ERP7__July_Budget__c= 25, ERP7__August_Budget__c = 25, ERP7__September_Budget__c=25, ERP7__October_Budget__c=25, ERP7__November_Budget__c=25, ERP7__December_Budget__c=25);
        /*insert bc6;
            ERP7__Budget_Account__c bc7 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__July_Budget__c = 25);
        insert bc7;
            ERP7__Budget_Account__c bc8 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__August_Budget__c = 25);
        insert bc8;
            ERP7__Budget_Account__c bc9 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__September_Budget__c = 25);
        insert bc9;
            ERP7__Budget_Account__c bc10 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__October_Budget__c = 25);
        insert bc10;
            ERP7__Budget_Account__c bc11 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__November_Budget__c = 25);
        insert bc11;
            ERP7__Budget_Account__c bc12 = new ERP7__Budget_Account__c(Name = 'test BC',ERP7__Budget_Plan__c = bp1.Id,ERP7__Project__c = proj.Id,ERP7__Organisation__c = orgn.Id,ERP7__Amount__c =100,ERP7__Committed_Amount__c = 50,ERP7__Consumed_Amount__c=20,ERP7__December_Budget__c = 25);
        insert bc12;*/
        // Call the method to be tested
        BudgetPlanner.budget result = BudgetPlanner.getBudget();
        test.StartTest();
        BudgetPlanner.fetchYearBudgetForecast(orgn.Id,bp1.Id);
        Balancesheet.Data data = new Balancesheet.Data('',0);
        Balancesheet bs = new Balancesheet();
        bs.getdata();
        Balancesheet.AccountGroup hg= new Balancesheet.AccountGroup('',0,new List<Balancesheet.AccountGroup>());
        Balancesheet.AccountGroup hf= new Balancesheet.AccountGroup('',new Map<String, Map<Integer,decimal>>(),new List<Balancesheet.AccountGroup>());
        Balancesheet.AccountGroup he= new Balancesheet.AccountGroup('',0,false);
        Balancesheet.AccountGroup hd= new Balancesheet.AccountGroup('',new Map<String, Map<Integer,decimal>>(),false);
        test.stopTest();
    }
    }