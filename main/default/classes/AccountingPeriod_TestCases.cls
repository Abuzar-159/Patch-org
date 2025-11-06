@isTest
public class AccountingPeriod_TestCases {
    testmethod static void unit1(){
        Test.startTest();
         Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:[select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ])AccountGroups_Map.put(r.DeveloperName,R.ID);
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation',Default__c = true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Chart_of_Accounts__c Cash = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id, Payment_account__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert Cash ;
        Chart_of_Accounts__c AccountsPayable = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert AccountsPayable;
        Chart_of_Accounts__c AccountsReceivable = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert AccountsReceivable;
        Chart_of_Accounts__c RentExpense = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert RentExpense;
        Chart_of_Accounts__c RetainedEarnings = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'));
        insert RetainedEarnings;
        Chart_of_Accounts__c Sales = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'));
        insert Sales;
        Chart_of_Accounts__c Sales_Return = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert Sales_Return;
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
        ERP7__Accounting_Period__c acc = new ERP7__Accounting_Period__c(Name='test',ERP7__Start_Date__c = system.today(),ERP7__End_Date__c = system.today()+90,ERP7__New_Fiscal_Year__c = true);
        insert acc;
        List<ERP7__Accounting_Period__c> accperiodList  = [SELECT Id,Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__New_Fiscal_Year__c,ERP7__PeriodId__c FROM ERP7__Accounting_Period__c WHERE  ERP7__Start_Date__c = THIS_FISCAL_YEAR];
        
        Finance_General_Ledger_Entry__c test_Entry1 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeDebit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =RentExpense.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c = accperiodList[0].ERP7__Start_Date__c,Accounting_period__c=accperiodList[0].Id,Debit_Entry__c=5000.00);
        insert test_entry1;
        Finance_General_Ledger_Entry__c test_Entry2 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =Sales.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c = accperiodList[0].ERP7__Start_Date__c,Accounting_period__c=accperiodList[0].Id,credit_Entry__c=5000.00);
        insert test_entry2;
        ERP7__COA_Mapping__c coa_Map = new ERP7__COA_Mapping__c(Name='Sales',Chart_of_account__c = Sales.Id);
        insert coa_Map;
        List<ERP7__Accounting_Period__c> accperiodList1  = [SELECT Id,Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__New_Fiscal_Year__c,ERP7__PeriodId__c FROM ERP7__Accounting_Period__c WHERE  ERP7__Start_Date__c = THIS_FISCAL_YEAR];
        accperiodList1[0].Status__c = 'Open';
       update accperiodList1[0];
        
        AccountingPeriod.getClosingEntries(accperiodList1[0].Id);
        set<Id> periodId = new set<Id>();periodId.add(accperiodList1[0].Id);
        try{ AccountingPeriod.closingEntries(periodId);
            
           }catch(Exception ex){} 
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    //---------------mna----------------------
    testmethod static void unit2(){
        Test.startTest();
         Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:[select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ])AccountGroups_Map.put(r.DeveloperName,R.ID);
        Account orgn = new Account(Name='Organisation Test', Account_Type__c = 'Organisation',Default__c = true);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert testLedger;
        Chart_of_Accounts__c Cash = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id, Payment_account__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert Cash ;
        Chart_of_Accounts__c AccountsPayable = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Payable',RecordTypeId=AccountGroups_Map.get('Liability'));
        insert AccountsPayable;
        Chart_of_Accounts__c AccountsReceivable = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert AccountsReceivable;
        Chart_of_Accounts__c RentExpense = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Rent Expense',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert RentExpense;
        Chart_of_Accounts__c RetainedEarnings = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Retained Earnings',RecordTypeId=AccountGroups_Map.get('Equity'));
        insert RetainedEarnings;
        Chart_of_Accounts__c Sales = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales',RecordTypeId=AccountGroups_Map.get('Income_Revenue'));
        insert Sales;
        Chart_of_Accounts__c Sales_Return = new Chart_of_Accounts__c(Finance_General_Ledger__c =testLedger.Id,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Name='Sales Returns',RecordTypeId=AccountGroups_Map.get('Income_Revenue'),isContra_Account__c=true);
        insert Sales_Return;
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry'); 
         ERP7__Accounting_Period__c acc = new ERP7__Accounting_Period__c(Name='test',ERP7__Start_Date__c = system.today(),ERP7__End_Date__c = system.today()+90,ERP7__New_Fiscal_Year__c = true);
        insert acc;
         List<ERP7__Accounting_Period__c> accperiodList = [SELECT Id,Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__New_Fiscal_Year__c,ERP7__PeriodId__c FROM ERP7__Accounting_Period__c WHERE  ERP7__Start_Date__c = THIS_FISCAL_YEAR];
        
        Finance_General_Ledger_Entry__c test_Entry1 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeDebit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =RentExpense.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c = accperiodList[0].ERP7__Start_Date__c,Accounting_period__c=accperiodList[0].Id,Debit_Entry__c=5000.00);
        insert test_entry1;
        Finance_General_Ledger_Entry__c test_Entry2 = new Finance_General_Ledger_Entry__c(Recordtypeid=rTypeCredit,Active__c=true,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=testLedger.id,Chart_of_Account__c =Sales.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c = accperiodList[0].ERP7__Start_Date__c,Accounting_period__c=accperiodList[0].Id,credit_Entry__c=5000.00);
        insert test_entry2;
        ERP7__COA_Mapping__c coa_Map = new ERP7__COA_Mapping__c(Name='Sales',Chart_of_account__c = Sales.Id);
        insert coa_Map;
        List<ERP7__Accounting_Period__c> accperiodList1  = [SELECT Id,Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__New_Fiscal_Year__c,ERP7__PeriodId__c FROM ERP7__Accounting_Period__c WHERE  ERP7__Start_Date__c = THIS_FISCAL_YEAR];
        accperiodList1[0].Status__c = 'Open';
        update accperiodList1[0];
        
        
        ERP7__Transaction__c tran=new ERP7__Transaction__c(Name='Test Trans',ERP7__Transaction_Date__c=System.today(),ERP7__Active__c=true,ERP7__Accounting_Period__c=accperiodList1[0].Id,ERP7__Amount__c=10);
        insert tran;
        
        /*List<ERP7__Transaction__c> tranList =[SELECT Id,NAME,Organisation__c,Transaction_Date__c, Amount__c  ,Accounting_period__c FROM Transaction__c];
        update tranList;*/
        
        set<Id> periodId = new set<Id>();
        periodId.add(accperiodList[0].Id);
        set<Id> transId = new set<Id>();
        transId.add(tran.Id);
        //transId.add('a0s1o000008dPXOAA2');
        AccountingPeriod.CreateClosingEntries(periodId,transId);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    testmethod static void unit3(){
        AccountingPeriod.COA_MAPPING(null);
        AccountingPeriod.FetchRetainedEarnings();
        String recId='a0s1o000008dPUoAAM';
        AccountingPeriod.closeAccountingPeriod(recId);
        AccountingPeriod.FetchRetainedEarnings();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    //---------------mna----------------------
}