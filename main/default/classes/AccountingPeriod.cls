public with sharing class AccountingPeriod {
     
    public static void closingEntries(set<Id> closingAccountingPeriodIds){
        system.debug('closingAccountingPeriodIds-->'+closingAccountingPeriodIds);
        List<ERP7__Accounting_Period__c> AccountingPeriod = new List<ERP7__Accounting_Period__c>();
        AccountingPeriod = [SELECT Id,Name,ERP7__Status__c,Start_date__c,End_date__c FROM ERP7__Accounting_Period__c WHERE Id IN: closingAccountingPeriodIds ];
        if(closingAccountingPeriodIds != null && closingAccountingPeriodIds.size()>0 && AccountingPeriod.size()>0){
            Date StartDate = AccountingPeriod[0].Start_date__c;
            Date EndDate = AccountingPeriod[0].End_date__c;
            date start_date = StartDate;     
            date end_date = EndDate;
            Map < String, Id > ExistingTransMap = new Map < String, Id > ();
            Id APC = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Accounting_Period_Closing'); 
            for (Transaction__c trans: [SELECT Id, Name, ERP7__Accounting_Period__c FROM Transaction__c WHERE ERP7__Accounting_Period__c IN: closingAccountingPeriodIds AND recordtypeid =:APC Order By CreatedDate desc]) {ExistingTransMap.put(trans.ERP7__Accounting_Period__c, trans.Id);
            }
            List<AggregateResult> financialData = [SELECT SUM(Credit_Entry__c ) Credit, SUM(Debit_Entry__c) Debit, 
                                                   Chart_of_Account__c AccountId,Chart_of_Account__r.Name AccountName,Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                                                   Chart_of_Account__r.Account_Type__c SubAccountGroup,Chart_of_Account__r.isContra_Account__c ContraAccount
                                                   FROM Finance_General_Ledger_Entry__c 
                                                   WHERE Active__c=true AND ERP7__Transactions__r.RecordTypeId!=:APC AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND Chart_of_Account__r.RecordType.DeveloperName IN ('Income_Revenue','Expense')
                                                   GROUP BY Chart_of_Account__r.Name,Chart_of_Account__c,Chart_of_Account__r.RecordType.DeveloperName,Chart_of_Account__r.Account_Type__c ,Chart_of_Account__r.isContra_Account__c Order By Chart_of_Account__r.Account_Type__c DESC NULLS LAST];
            
            system.debug('financialData-->'+financialData.size());
            Decimal creditSum = 0.0;
            Decimal debitsum = 0.0;
            Decimal TotalIncome = 0.00;
            Decimal TotalExpense = 0.00;
            
            List<Transaction__c> Transactions2update = new List<Transaction__c>();
            
            for(AggregateResult fd:financialData){
                if(fd.get('Credit') != null) creditSum = double.valueOf(fd.get('Credit'));if(fd.get('Debit') != null) debitsum = double.valueOf(fd.get('Debit'));if(fd.get('AccountGroup') == 'Income_Revenue')TotalIncome += (creditSum - debitsum); 
                else if(fd.get('AccountGroup') == 'Expense')  TotalExpense += (debitsum - creditSum);
                
            }
            for(Id accperiodID : closingAccountingPeriodIds){
                Transaction__c trans = new Transaction__c(Id = (ExistingTransMap.size() > 0 && ExistingTransMap.get(accperiodID) != null) ? ExistingTransMap.get(accperiodID) : null);
                if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){
                    trans.Amount__c = (TotalIncome - TotalExpense);
                }
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'ClosingEntry';
                if(APC != null){ if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = APC;}
                if(Schema.sObjectType.Transaction__c.fields.Accounting_Period__C.isCreateable() && Schema.sObjectType.Transaction__c.fields.Accounting_Period__C.isUpdateable()) trans.Accounting_Period__C=accperiodID;
                Transactions2update.add(trans);   
            }
            if(Transactions2update.size()>0 && Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()){ 
                upsert Transactions2update;
                Set<Id> transIds = new Set<Id>();
                for (ERP7__Transaction__c tran : Transactions2update) { 
                    transIds.add(tran.Id);
                }
                CreateClosingEntries(closingAccountingPeriodIds, transIds);
            }else { }
        }
    } 
    public static void CreateClosingEntries(set<Id> closingAccountingPeriodIds,Set<Id> TransactionIds){
        system.debug('CreateClosingEntries called-->'+TransactionIds);
        String errormsg;
        Boolean hasAccess;
        Map < String, Id > ExistingFGLEMap = new Map < String, Id > ();
        for (Finance_General_Ledger_Entry__c ExistingFGLE: [SELECT Id, ERP7__Chart_of_Account__c, Transactions__c FROM Finance_General_Ledger_Entry__c WHERE Transactions__c IN: TransactionIds Order By Name]) {ExistingFGLEMap.put(ExistingFGLE.Transactions__c + '_' + ExistingFGLE.ERP7__Chart_of_Account__c, ExistingFGLE.Id);
        }
        system.debug('ExistingFGLEMap-->'+ExistingFGLEMap);
        List<ERP7__Accounting_Period__c> AccountingPeriod = new List<ERP7__Accounting_Period__c>();
        List<Finance_General_Ledger_Entry__c> FGLEs = new List<Finance_General_Ledger_Entry__c>();
        AccountingPeriod = [SELECT Id,Name,ERP7__Status__c,Start_date__c,End_date__c FROM ERP7__Accounting_Period__c WHERE Id IN: closingAccountingPeriodIds ];
        List<Chart_of_Accounts__c> RE_COA = [SELECT Id,Name  FROM ERP7__Chart_of_Accounts__c WHERE  Name='Retained Earnings/ Profit and Loss']; //ERP7__Accounting_Period_Start_Date__c  = THIS_FISCAL_YEAR AND
        if(closingAccountingPeriodIds.size()>0){ 
            Date StartDate = AccountingPeriod[0].Start_date__c;
            Date EndDate = AccountingPeriod[0].End_date__c;
            date start_date = StartDate;     
            date end_date = EndDate; 
            Decimal creditSum = 0.0;
            Decimal debitsum = 0.0; 
            Id rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');    
            Id rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry');  
            Id APC = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Accounting_Period_Closing');    
            List<Finance_General_Ledger__c> FinanceGeneralLedgers = [Select Id, Name, Accounting_Period_End_Date__c, Accounting_Period_Start_Date__c, Active__c, Description__c,CreatedDate,
                                                                     Organisation__c, Organisation_Business_Unit__c
                                                                     From Finance_General_Ledger__c
                                                                     Where Active__c = true Limit 1]; 
            List<AggregateResult> financialData = [SELECT SUM(Credit_Entry__c ) Credit, SUM(Debit_Entry__c) Debit, 
                                                   Chart_of_Account__c AccountId,Chart_of_Account__r.Name AccountName,Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                                                   Chart_of_Account__r.Account_Type__c SubAccountGroup,Chart_of_Account__r.isContra_Account__c ContraAccount
                                                   FROM Finance_General_Ledger_Entry__c 
                                                   WHERE Active__c=true AND ERP7__Transactions__r.RecordTypeId!=:APC  AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND Chart_of_Account__r.RecordType.DeveloperName IN ('Income_Revenue','Expense')
                                                   GROUP BY Chart_of_Account__r.Name,Chart_of_Account__c,Chart_of_Account__r.RecordType.DeveloperName,Chart_of_Account__r.Account_Type__c ,Chart_of_Account__r.isContra_Account__c Order By Chart_of_Account__r.Account_Type__c DESC NULLS LAST];
            for(Finance_General_Ledger__c FGL :FinanceGeneralLedgers)
                for(Transaction__c trans : [SELECT Id,NAME,Organisation__c,Transaction_Date__c, Amount__c  ,Accounting_period__c FROM Transaction__c WHERE Id IN : TransactionIds]){
                    Finance_General_Ledger_Entry__c FGLE_RE;
                    if(trans.Amount__c>0)FGLE_RE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + RE_COA[0].Id) != null) ? ExistingFGLEMap.get(trans.id + '_' + RE_COA[0].Id) : null,Active__c=true,Organisation__c = trans.Organisation__c,Transactions__c = trans.Id,Finance_General_Ledger__c = FGL.Id,RecordTypeId = rTypeCredit,General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c,Accounting_period__c = trans.Accounting_period__c,Credit_Entry__c  = trans.Amount__c);
                    else FGLE_RE = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + RE_COA[0].Id) != null) ? ExistingFGLEMap.get(trans.id + '_' + RE_COA[0].Id) : null,Active__c=true,Organisation__c = trans.Organisation__c,Transactions__c = trans.Id,Finance_General_Ledger__c = FGL.Id,RecordTypeId = rTypeCredit,General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c,Accounting_period__c = trans.Accounting_period__c,Debit_Entry__c  = (-1)*trans.Amount__c);
                    if(RE_COA.size()>0) FGLE_RE.Chart_of_Account__c = RE_COA[0].Id;
                    for(AggregateResult FD : financialData){
                        Finance_General_Ledger_Entry__c FGLE_Credit = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + (ID)fd.get('AccountId')) != null) ? ExistingFGLEMap.get(trans.id + '_' + (ID)fd.get('AccountId')) : null,Organisation__c = trans.Organisation__c,Transactions__c = trans.Id,Finance_General_Ledger__c = FGL.Id,RecordTypeId = rTypeCredit,General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c,Accounting_period__c = trans.Accounting_period__c);
                        Finance_General_Ledger_Entry__c FGLE_Debit = new Finance_General_Ledger_Entry__c(Id = (ExistingFGLEMap.size() > 0 && ExistingFGLEMap.get(trans.id + '_' + (ID)fd.get('AccountId')) != null) ? ExistingFGLEMap.get(trans.id + '_' + (ID)fd.get('AccountId')) : null,Organisation__c = trans.Organisation__c,Transactions__c = trans.Id,Finance_General_Ledger__c = FGL.Id,RecordTypeId = rTypeDebit,General_Ledger_Entry_DateTime__c = trans.ERP7__Transaction_Date__c,Accounting_period__c = trans.Accounting_period__c);
                        
                        if(fd.get('Credit') != null) creditSum = double.valueOf(fd.get('Credit'));  if(fd.get('Debit') != null) debitsum = double.valueOf(fd.get('Debit'));
                        system.debug('creditSum -->'+creditSum);
                        system.debug('debitsum -->'+debitsum);
                        system.debug('Account Id-->'+fd.get('AccountId'));
                        if(fd.get('AccountGroup') == 'Expense'){
                            if((debitsum - creditSum)>0){
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isUpdateable()) FGLE_Credit.Chart_of_Account__c  =(ID)fd.get('AccountId');
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isUpdateable()) FGLE_Credit.Active__c = true;
                                // FGLE_Credit.General_Ledger_Type__c ='Accounts Receivable';
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c .isUpdateable()) FGLE_Credit.General_Ledger_Entry_Type__c  ='Credit';
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Credit_Entry__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Credit_Entry__c.isUpdateable()) FGLE_Credit.Credit_Entry__c  = (debitsum - creditSum);
                                
                            }else{
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isUpdateable()) FGLE_Credit.Chart_of_Account__c  =(ID)fd.get('AccountId');
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isUpdateable()) FGLE_Credit.Active__c = true;
                                // FGLE_Credit.General_Ledger_Type__c ='Accounts Receivable';
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c .isUpdateable()) FGLE_Credit.General_Ledger_Entry_Type__c  ='Debit';
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Debit_Entry__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Debit_Entry__c.isUpdateable()) FGLE_Credit.Debit_Entry__c  = (creditSum-debitsum);
                                FGLE_Credit.RecordTypeId = rTypeDebit;
                            }
                        }else{
                            if((creditSum - debitsum)>0){
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isUpdateable()) FGLE_Debit.Chart_of_Account__c  =(ID)fd.get('AccountId');
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isUpdateable()) FGLE_Debit.Active__c = true;
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c .isUpdateable()) FGLE_Debit.General_Ledger_Entry_Type__c  ='Debit'; 
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Debit_Entry__c .isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Debit_Entry__c.isUpdateable()) FGLE_Debit.Debit_Entry__c  = (creditSum - debitsum);
                            }else{
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Chart_of_Account__c.isUpdateable()) FGLE_Debit.Chart_of_Account__c  =(ID)fd.get('AccountId');
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Active__c.isUpdateable()) FGLE_Debit.Active__c = true;
                                // FGLE_Credit.General_Ledger_Type__c ='Accounts Receivable';
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.General_Ledger_Entry_Type__c .isUpdateable()) FGLE_Debit.General_Ledger_Entry_Type__c  ='Credit';
                                if(Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Credit_Entry__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.fields.Credit_Entry__c.isUpdateable()) FGLE_Debit.Credit_Entry__c  = (debitsum-creditSum);
                                FGLE_Debit.RecordTypeId = rTypeCredit;
                            }
                        }
                        system.debug('FGLE_Credit.Credit_Entry__c-->'+FGLE_Credit.Credit_Entry__c);
                        system.debug('FGLE_Debit.Debit_Entry__c-->'+FGLE_Debit.Debit_Entry__c);
                        if(FGLE_Credit.Active__c && FGLE_Credit.Credit_Entry__c !=0)FGLEs.add(FGLE_Credit);                    if(FGLE_Debit.Active__c && FGLE_Debit.Debit_Entry__c !=0)FGLEs.add(FGLE_Debit);  
                    }
                    if(FGLE_RE.Active__c)FGLEs.add(FGLE_RE);
                }
            system.debug('FGLEs  data -->'+FGLEs);
            if(FGLEs.size()>0 && Schema.sObjectType.Finance_General_Ledger_Entry__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.isUpdateable()){ hasAccess=true; upsert FGLEs;}      else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
        }
    }
    
    public static Map<String,Set<ERP7__COA_Mapping__c>> COA_MAPPING(String OrgId){ //String Id
        Map<String,Set<ERP7__COA_Mapping__c>> COA_MappingList = new Map<String,Set<ERP7__COA_Mapping__c>>();
        if(String.isNotEmpty(OrgId)){
            for(ERP7__COA_Mapping__c COA : [SELECT ID,NAME ,ERP7__Chart_of_Account__c ,ERP7__Shipment__c, Tax__c ,ERP7__Contra__c, Discount__c ,ERP7__Chart_of_Account__r.Name  FROM ERP7__COA_Mapping__c where ERP7__Organisation__c=:OrgId limit 10000]){ //where ERP7__Organisation__c=:Id
                Set<ERP7__COA_Mapping__c> tempList = (COA_MappingList.get(COA.Name) != null)? COA_MappingList.get(COA.Name):new Set<ERP7__COA_Mapping__c>();   
                tempList.add(COA);   
                COA_MappingList.put(COA.Name,tempList);
            }
        }
        return COA_MappingList;
    }
    
    public static Map<String,Set<ERP7__COA_Mapping__c>> COA_MAPPING_BASED_ON_ISO(String OrgId, String CurrencyCode){ //String Id
        Map<String,Set<ERP7__COA_Mapping__c>> COA_MappingList = new Map<String,Set<ERP7__COA_Mapping__c>>();
        String query = 'SELECT ID,NAME ,ERP7__Chart_of_Account__c ,Tax__c ,ERP7__Shipment__c, ERP7__Contra__c, Discount__c ,ERP7__Chart_of_Account__r.Name  FROM ERP7__COA_Mapping__c where ERP7__Organisation__c=:OrgId AND CurrencyIsoCode=:CurrencyCode limit 10000';
        if(String.isNotEmpty(OrgId)){
            for(ERP7__COA_Mapping__c COA : database.query(query)){ //where ERP7__Organisation__c=:Id
                Set<ERP7__COA_Mapping__c> tempList = (COA_MappingList.get(COA.Name) != null)? COA_MappingList.get(COA.Name):new Set<ERP7__COA_Mapping__c>();   
                tempList.add(COA);    COA_MappingList.put(COA.Name,tempList);
            }
        }
        return COA_MappingList;
    }
     
    @AuraEnabled
    public static List<AggregateResult> getClosingEntries(String recordId){
        set<Id> closingAccountingPeriodIds = new set<Id>();
        if(String.isNotEmpty(recordId))closingAccountingPeriodIds.add(recordId);
        list<AggregateResult> FGLEList=new list<AggregateResult>();
        if(closingAccountingPeriodIds.size()>0)
          FGLEList=[SELECT SUM(Credit_Entry__c ) Credit, SUM(Debit_Entry__c) Debit, 
                   Chart_of_Account__c AccountId,Chart_of_Account__r.Name AccountName,Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                   Chart_of_Account__r.Account_Type__c SubAccountGroup,Chart_of_Account__r.isContra_Account__c ContraAccount
                   FROM Finance_General_Ledger_Entry__c 
                   WHERE Active__c=true AND Accounting_period__c IN: closingAccountingPeriodIds AND Chart_of_Account__r.RecordType.DeveloperName IN ('Income_Revenue','Expense')
                  // WHERE Accounting_period__c IN: closingAccountingPeriodIds AND Chart_of_Account__r.RecordType.DeveloperName IN ('Income_Revenue','Expense') 
                   GROUP BY  Chart_of_Account__r.Name,Chart_of_Account__c,Chart_of_Account__r.RecordType.DeveloperName,Chart_of_Account__r.Account_Type__c ,Chart_of_Account__r.isContra_Account__c
                   Order By Chart_of_Account__r.Account_Type__c DESC NULLS LAST
                   ]; 
        
         
               
        return FGLEList;
    } 
        @AuraEnabled
        public static ERP7__Chart_Of_accounts__c FetchRetainedEarnings(){
            List<ERP7__Chart_Of_accounts__c> REList = new List<ERP7__Chart_Of_accounts__c>();
            REList = [Select Id,Name FROM ERP7__Chart_Of_accounts__c WHERE Active__c = true AND Account_Type__c = 'Retained Earnings' AND RecordType.DeveloperName = 'Equity' limit 1];
            if(REList.size()>0)return REList[0];
            return null;
        } 
        @AuraEnabled
    public static String closeAccountingPeriod(String recId){
        String error=null;
        if(String.isNotEmpty(recId)){
            try{
            ERP7__Accounting_Period__c acc = new ERP7__Accounting_Period__c(Id=recId,status__c='Closed');   
                if(Schema.sObjectType.ERP7__Accounting_Period__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.isUpdateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.status__c.isCreateable() && Schema.sObjectType.ERP7__Accounting_Period__c.fields.status__c.isUpdateable()) upsert acc; else{/*Nor allowed to upsert*/}
            return error;    
            }catch(Exception e){
             error=String.valueOf(e);   
             if(error.contains('Previous Accounting Period Must be closed,before Closing Current Accounting Period'))error='Previous Accounting Period Must be closed,before Closing Current Accounting Period'; 
             return error; 
            }
            
        }
        return error;
    }
}