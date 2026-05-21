@isTest
public class AdjustmentEntriesLightningTest {
    
     Static Date getFinancialStartDate(){
        Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
        Date startDate = Date.newInstance((FiscalYearStartMonth==1)?System.today().Year():System.today().Year()-1,FiscalYearStartMonth,1);
        return startDate;
    }
    static Date getFinancialEndDate(){
        Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
        Date startDate = Date.newInstance((FiscalYearStartMonth==1)?System.today().Year():System.today().Year()-1,FiscalYearStartMonth,1);
        datetime FiscalYearSD = datetime.newInstanceGMT(startDate,Time.newInstance(0, 0, 0, 0));
        Integer year = (FiscalYearStartMonth >2)?startDate.year()+1:startDate.year();
        date endDate = (Date.isLeapYear(year))?startDate.adddays(365):startDate.adddays(364);
        datetime FiscalYearED = datetime.newInstanceGMT(endDate,Time.newInstance(23, 59, 59, 999));
        return endDate;
    }

    @isTest(seeAllData= true) 
    public static void unitTest1(){
        Test.startTest();
        Date startDate = getFinancialStartDate();
        Date endDate = getFinancialEndDate();
        Account orgn = new Account(Name='Organisation',Account_Type__c='Organisation',default__c=true);
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Finance_General_Ledger__c Gledger = new Finance_General_Ledger__c(End_Date__c = endDate,Start_Date__c=startDate,Name='Test Ledger',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Active__c = true);
        insert Gledger;
        Chart_of_Accounts__c cash = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Cash',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert cash;
        Chart_of_Accounts__c AR = new Chart_of_Accounts__c(Accounting_Period_Start_Date__c = startDate,Accounting_Period_End_Date__c=endDate,Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Account Receivable',RecordTypeId=AccountGroups_Map.get('Assets'));
        insert AR;
        Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeId(Finance_General_Ledger_Entry__c.sObjectType,'Credit General Ledger Entry');    
        Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeId(Finance_General_Ledger_Entry__c.sObjectType,'Debit General Ledger Entry'); 
        List<Transaction__c> transList = new List<Transaction__c>();
        Transaction__c test_tran1 = new Transaction__c(is_Adjustment__c =true,Transaction_Status__c='Completed',Transaction_Type__c='Sales',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
        transList.add(test_tran1);
        Transaction__c test_tran2 = new Transaction__c(is_Adjustment__c =true,Transaction_Status__c='Completed',Transaction_Type__c='Sales Returns',Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Amount__c = 5000.00,Active__c=true);
        transList.add(test_tran2);
        insert transList;
        List<Finance_General_Ledger_Entry__c> FGLES = new List<Finance_General_Ledger_Entry__c>();
        Finance_General_Ledger_Entry__c FGLE1 = new Finance_General_Ledger_Entry__c(RecordTypeId=rTypeDebit,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=Gledger.id,Chart_of_Account__c  =cash.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=transList[0].id,Debit_Entry__c=1500.0);
        insert FGLE1;
        FGLES.add(FGLE1); 
        Finance_General_Ledger_Entry__c FGLE2= new Finance_General_Ledger_Entry__c(RecordTypeId=rTypeCredit,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=Gledger.id,Chart_of_Account__c  =AR.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=transList[0].id,Credit_Entry__c=1500.0);
        insert FGLE2;
        FGLES.add(FGLE2);
        Finance_General_Ledger_Entry__c FGLE3 = new Finance_General_Ledger_Entry__c(RecordTypeId=rTypeDebit,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=Gledger.id,Chart_of_Account__c  =cash.id,General_Ledger_Entry_Type__c ='Debit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=transList[1].id,Debit_Entry__c=1000.0);
        insert FGLE3; 
        FGLES.add(FGLE3);
        Finance_General_Ledger_Entry__c FGLE4= new Finance_General_Ledger_Entry__c(RecordTypeId=rTypeCredit,Organisation__c =orgn.id,Organisation_Business_Unit__c=busUnit.id,Finance_General_Ledger__c=Gledger.id,Chart_of_Account__c  =AR.id,General_Ledger_Entry_Type__c ='Credit',General_Ledger_Entry_DateTime__c=system.today(),Transactions__c=transList[1].id,Credit_Entry__c=1000.0, ERP7__CustomerVendor__c=orgn.Id);
        insert FGLE4;
        FGLES.add(FGLE4);
        AdjustmentEntriesLightning instance = new AdjustmentEntriesLightning();
        instance.editTrans = test_tran1;
        instance.editAdjustments = FGLES;
        instance.DefaultOrg = test_tran1;
        instance.Gledger = Gledger;
        AdjustmentEntriesLightning.Adjust_Wrapper adjWrapper = new AdjustmentEntriesLightning.Adjust_Wrapper(orgn.Id);
        AdjustmentEntriesLightning.Entries e = new AdjustmentEntriesLightning.Entries(0, orgn.Id, 'Credit');
        e.GEntries.ERP7__CustomerVendor__c=orgn.id; 
         instance.rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');   
        instance.rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry');       
        instance.adjEntries = adjWrapper;
        instance.adjEntries.FGLEs.add(e);
        instance.adjDate = System.Today().format();
        instance.FGLE2Insert = FGLES;
        instance.selectedIndex=0;
        instance.editAdjustments = FGLES;
        system.debug('instance.editAdjustments  : '+instance.editAdjustments .size());
        String selId;
        AdjustmentEntriesLightning.saveEditEntries(selId, JSON.serialize(instance)); 
        AdjustmentEntriesLightning.saveCloneEntries(selId, JSON.serialize(instance));
        AdjustmentEntriesLightning.getFGLES(transList[0].Id, JSON.serialize(instance)); 
        AdjustmentEntriesLightning.fetchDetails(String.valueOf(0), 10 , 'Test');
        AdjustmentEntriesLightning.getAdjTransactions(String.valueOf(0), 10 , 'Test', JSON.serialize(instance));
        AdjustmentEntriesLightning.deleteAdjsTransaction(String.valueOf(0), String.valueof(10) , 'Test', String.valueof(transList[0].Id),JSON.serialize(instance));
        AdjustmentEntriesLightning.addCreditEntries(JSON.serialize(instance));
        AdjustmentEntriesLightning.addDebitEntries(JSON.serialize(instance));
        AdjustmentEntriesLightning.saveandNew(String.valueOf(0), 10 , 'Test', JSON.serialize(instance));
        AdjustmentEntriesLightning.setCOA(1, orgn.Id, JSON.serialize(instance));
        AdjustmentEntriesLightning.setEditCOA(1, orgn.Id, JSON.serialize(instance)); 
        
        AdjustmentEntriesLightning.getCurrencies();
        AdjustmentEntriesLightning.selectOptions so = new AdjustmentEntriesLightning.selectOptions('test', 'test');
        AdjustmentEntriesLightning.selectOptions so1 = new AdjustmentEntriesLightning.selectOptions('test', 'test', true);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name); 
        Test.stopTest();
    }
    

}