Public  with sharing class BalanceSheet{
    public Map<String,Integer> FinancialYears                                         { get; set; }
    public Map<String,AccountGroup> FinancialYearWiseAssetMap                         { get; set; }
    public Map<String,AccountGroup> compareBalanceSheetMap                            { get; set; }
    public Map<String,Map<Integer,decimal>> CompareFyWiseExpenseMap                   { get; set; }
    public map<String,Decimal> FyWiseExpenseMap                                       { get; set; }
    public Map<String,Map<Integer,decimal>> CompareFyWiseIncomeMap                    { get; set; }
    public map<String,Decimal> FyWiseIncomeMap                                        { get; set; }
    public Map<String,map<String,decimal>> chartmap                                   { get; set; }    
    public string yfields                                                             { get; set; }
    public Map<String,Map<String,Decimal>> CurrentChartofAccounts                     { get; set; } public ERP7__Accounting_Period__c CurrentFy                                       { get; set; }
    public String SelectedFy                                                          { get; set; }
    public String newOrganisationId                                                   { get; set; }
    public String SelectedFy_BS                                                       { get; set; }
    public Account Select_Organisation                                                { get; set; }
    public String endDate                                                             { get; set; }
    public string startDate                                                           { get; set; } 
    public string startfy                                                             { get; set; }
    public string endfy                                                               { get; set; }
    public String minDate                                                             { get; set; }
    public String max_Date                                                            { get; set; }
    public Boolean  showChart                                                         { get; set; }
    public String FyYear                                                              { get; set; }
    public String Colorset                                                            { get; set; }
    public String YearorQuarter                                                       { get; set; }
    public List<string> Colors;
    public Boolean ShowFyWise                                                         { get; set; }
    public Boolean ShowQuartely                                                       { get; set; }
    public Boolean showMonthly                                                        { get; set; }
    public List<String> FYNames                                                       { get; set; }
    public String ChartTitle                                                          { get; set; }
    public Boolean showBalancesheet                                                   { get; set; }
    public ERP7__Chart_of_Accounts__c Total_Assets                                    { get; set; }
    public ERP7__Chart_of_Accounts__c Total_Liab_Equity                               { get; set; }
    public Map<string,boolean> balanceSheetAccounts                                   { get; set; }
    public Map<String,String> FiscalYearQuarter                                       { get; set; }
    public Map<String,String> FiscalYear                                              { get; set; }
    public Map<Integer,String> IntegerToMonthName                                     { get; set; }
    public Map<Integer,String> IntegerToQuarterName                                   { get; set; }
    public String RE_COA                                                              { get; set; }
    Public List<Period> FiscalPeriod                                                  { get; set; }
    public Boolean multiCurrencyEnabled                                                                               {get;  set; } public String isoCode                                                                                             { get; set; }
    public Integer mon;
    public Decimal  totalAsset                                            {get;set;}
    public Decimal  totalLiabEqui                                           {get;set;}
    public checkMultiCurrency checkCurrency                                   {get;set;}
    public List < AggregateResult > assetList {get;set;}
    public List < AggregateResult > liabilityList {get;set;}
    public List < AggregateResult > EquityList {get;set;}
    public BalanceSheet(){
        try{
            assetList = new List < AggregateResult >();
        	liabilityList = EquityList = new List < AggregateResult >();
        	totalAsset = totalLiabEqui = 0.00;
            multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            String selectedIso = apexpages.currentpage().getparameters().get('CurrencyIso');
            
            checkCurrency=new checkMultiCurrency();
            checkCurrency.conversionRate= 1; 
            checkCurrency.userISO = selectedIso;
            FinancialYearWiseAssetMap = new Map<String,AccountGroup>();
            compareBalanceSheetMap    = new Map<String,AccountGroup>();
            CompareFyWiseExpenseMap   = new Map<String,Map<Integer,decimal>>(); 
            CompareFyWiseIncomeMap    = new Map<String,Map<Integer,decimal>>();
            FyWiseIncomeMap           = new Map<String,Decimal>();
            FyWiseExpenseMap          = new Map<String,Decimal>();
            CurrentChartofAccounts    = new Map<String,Map<String,decimal>>();
            chartmap                  = new Map<String,map<String,decimal>>();
            FinancialYears            = new Map<String,Integer>();
            Select_Organisation       = new Account();
            Total_Assets                          = new ERP7__Chart_of_Accounts__c();
            Total_Liab_Equity         = new ERP7__Chart_of_Accounts__c();
            buildConditions();
            FiscalPeriod = [SELECT StartDate,EndDate FROM Period WHERE Type = 'Year' AND StartDate <= TODAY AND EndDate >= TODAY];
            mon = FiscalPeriod[0].StartDate.Month();
            BuildMOnthMap(mon);
            YearorQuarter='Fyear';   
            Date mydate = system.today().adddays(-90);//FiscalPeriod[0].StartDate;
            date end_Date = system.today();//FiscalPeriod[0].EndDate;
            minDate =mydate.format();
            startDate = mydate.format();
            endDate = end_Date.format();
            max_Date = end_Date.format();
            IntegerToQuarterName =new Map<Integer,String>(); 
            IntegerToQuarterName.put(1,'Q-1');
            IntegerToQuarterName.put(2,'Q-2');
            IntegerToQuarterName.put(3,'Q-3');
            IntegerToQuarterName.put(4,'Q-4');
            balanceSheetAccounts= new Map<string,boolean>();
            balanceSheetAccounts.put('Assets',false);
            balanceSheetAccounts.put('Equity',false);
            balanceSheetAccounts.put('Liability',false);
            SelectedFy ='1';
            SelectedFy_BS = '1';
            showChart = true;
            ShowFyWise = true;
            ShowQuartely = false;
            showMonthly = false;
            showBalancesheet = false;
            FYNames = new List<String>();
            Account Organisation = ERP7.UtilClass.getOrganisationByLogin_Employee();
            if(Organisation.Id != null ){
                Select_Organisation.ERP7__Organisation__c = Organisation.id;
                RE_COA = getRE_AccountName(Select_Organisation.ERP7__Organisation__c);
                colors= new List<String>{'#FF0000','#6A5ACD','#00FF00','#0000FF','#00BFFF','#D2691E','#8A2BE2','#778899','#CAFF70','#7FFFD4','#0000A0'};
                ComputeSelectedFyDataUpdated();
                    //ComputeSelectedFyData();
                //ComputeData();
                if(multiCurrencyEnabled){  Total_Assets.put('CurrencyIsoCode',isoCode); Total_Liab_Equity.put('CurrencyIsoCode',isoCode);
                }
            }}catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); 
        }
    }
    
    public class checkMultiCurrency{
        public Boolean ismultiCurrency  {get;set;} public String  userISO          {get;set;} public String  isoCode          {get;set;}
        public double  conversionRate   {get;set;}
        public checkMultiCurrency(){
            ismultiCurrency = false;
            conversionRate  = 0.00;
        }
    }
    
    public void CheckQuartelyYearlyMon(){
        try{
            ComputeData();        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));} 
    } 
    
    
    public PageReference ComputeSelectedFyDataUpdated() {
        try{
            system.debug('ComputeSelectedFyData called');
            system.debug('Select_Organisation.Organisation__c ' + Select_Organisation.ERP7__Organisation__c);
            String isoCode = '';
            if(Schema.getGlobalDescribe().containsKey('CurrencyType')){isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');}
            Map < Id, ERP7__Chart_of_Accounts__c > chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c > ([SELECT Name, RecordTypeId, ERP7__isContra_Account__c,ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where RecordType.DeveloperName not in ('Income_Revenue', 'Expense')]); 
            if ((chart_Of_Accounts.size() == 0 || chart_Of_Accounts == null)) {ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: No Chart of Accounts found.'); ApexPages.addMessage(myMsg);  return null; }
            String qryFilter = '';
            if (Select_Organisation.ERP7__Organisation__c != null) qryFilter += ' AND ERP7__Organisation__c = \'' + Select_Organisation.ERP7__Organisation__c + '\' ';
            String StartDate = apexpages.currentpage().getparameters().get('StartDate');
            String EndDate = apexpages.currentpage().getparameters().get('EndDate');
            system.debug('StartDate -->'+StartDate);
            system.debug('EndDate -->'+EndDate);
            if(StartDate!=''&&StartDate!=null) Date start_date = Date.valueOf(StartDate);
            Date end_Date = Date.valueOf(EndDate); system.debug('end_Date -->'+end_Date); string stat = 'Open';
            String Query = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c coa, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name coaName ' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Assets\',\' \') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
                ' GROUP BY   ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c';
            
            assetList = Database.query(Query);
            for(AggregateResult agg : assetList){
                system.debug('totalAsset-->'+totalAsset);
                totalAsset = totalAsset + double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));
            }
            String liabQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c coa, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name coaName ' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Liability\',\' \') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
                ' GROUP BY   ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c';
            
            liabilityList = Database.query(liabQuery);
            for(AggregateResult agg : liabilityList){
                totalLiabEqui = totalLiabEqui + double.valueOf(agg.get('Credit')) - double.valueOf(agg.get('Debit'));
            }
            
            String equityQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c coa, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name coaName ' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Equity\',\' \') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
                ' GROUP BY   ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c';
            
            EquityList = Database.query(equityQuery);
            for(AggregateResult agg : EquityList){
                totalLiabEqui = totalLiabEqui + double.valueOf(agg.get('Credit')) - double.valueOf(agg.get('Debit'));
            }
            return null;
        }catch(Exception e){
            system.debug('Exception--->'+e+'Line Number-->'+e.getLineNumber());
            return null;
        }
    }
    
    public void BuildMOnthMap(Integer m){
        IntegerToMonthName = new Map<Integer,String>();
        List<String> MonthNames = new List<String> { 'JAN', 'FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC','JAN', 'FEB','MAR'};
        for(Integer i=0;i<=11;i++)
        IntegerToMonthName.put(i+1,MonthNames[(i-1)+m]);
    } 

    public void buildConditions(){
        FiscalYearQuarter = new Map<String,String>();
        FiscalYearQuarter.put('1','= THIS_FISCAL_YEAR');
        FiscalYearQuarter.put('2','>= LAST_FISCAL_YEAR AND ERP7__General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        FiscalYearQuarter.put('3','>= LAST_N_FISCAL_YEARS:2 AND ERP7__General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        FiscalYearQuarter.put('4','= THIS_FISCAL_QUARTER');
        FiscalYearQuarter.put('5','= NEXT_FISCAL_QUARTER OR ERP7__General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        FiscalYearQuarter.put('6','= NEXT_FISCAL_QUARTER');
        FiscalYearQuarter.put('7','= LAST_FISCAL_QUARTER OR ERP7__General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        /*Fiscal Year*/
        FiscalYear = new Map<String,String>(); 
        FiscalYear.put('1','Startdate = THIS_FISCAL_YEAR');
        FiscalYear.put('2','Startdate >= LAST_FISCAL_YEAR AND Startdate <= THIS_FISCAL_YEAR');
        FiscalYear.put('3','Startdate >= LAST_N_FISCAL_YEARS:2 AND Startdate <= THIS_FISCAL_YEAR');
        FiscalYear.put('4','Startdate = THIS_FISCAL_QUARTER');
        FiscalYear.put('5','Startdate <= NEXT_FISCAL_QUARTER AND Startdate >= THIS_FISCAL_QUARTER');
        FiscalYear.put('6','Startdate = NEXT_FISCAL_QUARTER');
        FiscalYear.put('7','StartDate >= LAST_FISCAL_QUARTER AND StartDate <= THIS_FISCAL_QUARTER ');

    }
    public PageReference ComputeSelectedFyData(){
        try{
            Total_Assets = new ERP7__Chart_of_Accounts__c(ERP7__Opening_Balance__c=0.00);
            Total_Liab_Equity = new ERP7__Chart_of_Accounts__c(ERP7__Opening_Balance__c=0.00);
            if(multiCurrencyEnabled){  Total_Assets.put('CurrencyIsoCode',isoCode); Total_Liab_Equity.put('CurrencyIsoCode',isoCode);
            }
            FinancialYearWiseAssetMap = new Map<String,AccountGroup>();
            FyWiseIncomeMap = new Map<String,Decimal>();
            FyWiseExpenseMap = new Map<String,Decimal>();
            String StartDate = apexpages.currentpage().getparameters().get('StartDate');
            String endDate = apexpages.currentpage().getparameters().get('EndDate');
            system.debug('endDate -->'+endDate);
            Map<Id,ERP7__Chart_of_Accounts__c> chart_Of_Accounts = new Map<Id,ERP7__Chart_of_Accounts__c>([SELECT Name,RecordTypeId,ERP7__isContra_Account__c,
            ERP7__Account_Type__c,RecordType.DeveloperName,ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where  ERP7__Active__c = true ]);
            if((chart_Of_Accounts.size() == 0 || chart_Of_Accounts == null ) && showBalancesheet){ showBalancesheet = false;ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Chart of Accounts, found For selected Organisation.'); ApexPages.addMessage(myMsg); return null;
            }
            List<AggregateResult> BalanceSheetData = new List<AggregateResult>();
             // For converting to other currency
             Boolean ismultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
             String isoCodee; Decimal conversionRate=1;
            BalanceSheetData = [SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, 
            ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
            ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount,CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
            FROM ERP7__Finance_General_Ledger_Entry__c 
            WHERE ERP7__Active__c=true AND ERP7__Organisation__c =: Select_Organisation.ERP7__Organisation__c  AND 
            ERP7__General_Ledger_Entry_DateTime__c <= :Date.valueOf(endDate) AND
            ERP7__Organisation__c = :Select_Organisation.ERP7__Organisation__c
            GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c Order By ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST limit 5000];
            for(AggregateResult bsd:BalanceSheetData){
                Decimal openingBal = 0;//(chart_Of_Accounts.get((ID)bsd.get('AccountId'))!= null)? chart_Of_Accounts.get((ID)bsd.get('AccountId')).ERP7__Opening_Balance__c:0.00;
                Decimal creditSum = 0.0;
                Decimal debitsum = 0.0;
                Decimal ClosingBalance = 0.0;
                Decimal TotalIncome = 0.00;
                Decimal TotalExpense = 0.00;
                AccountGroup AccountNameValue = new AccountGroup();
                if(multiCurrencyEnabled){  AccountNameValue.Container.put('CurrencyIsoCode',isoCode); AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode); }
                AccountGroup ParentAccount = new AccountGroup();
                if(multiCurrencyEnabled){    ParentAccount.Container.put('CurrencyIsoCode',isoCode);  ParentAccount.NContainer.put('CurrencyIsoCode',isoCode);
                     }
                List<AccountGroup> AccountNameValueList = new List<AccountGroup>();
                List<AccountGroup> subAccsList = new List<AccountGroup>();
                
                // For mulitiplication of currencies
                if(bsd.get('Credit') != null){ 
                    creditSum = double.valueOf(bsd.get('Credit'));
                } 
                if(bsd.get('Debit') != null){
                    debitsum = double.valueOf(bsd.get('Debit'));
                } 
                // End of mulitiplication of currencies   
                
                if(bsd.get('AccountGroup') ==  'Assets'){
                    system.debug('openingBal-->'+openingBal);
                    if((Boolean)bsd.get('ContraAccount')){
                        ClosingBalance = (openingBal +(creditSum - debitsum));
                        AccountNameValue = AccountGroup3('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));//new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if(multiCurrencyEnabled){  AccountNameValue.Container.put('CurrencyIsoCode',isoCode);   AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                        ClosingBalance = -ClosingBalance;
                    }else{
                        system.debug('creditSum-->'+creditSum);
                        system.debug('debitsum-->'+debitsum);
                        ClosingBalance = (openingBal - (creditSum - debitsum));
                        system.debug('Account Name - > '+String.valueOf(bsd.get('AccountName')));
                        system.debug('ClosingBalance - > '+ClosingBalance);
                        AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if(multiCurrencyEnabled){   AccountNameValue.Container.put('CurrencyIsoCode',isoCode);    AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                    }
                }else if(bsd.get('AccountGroup') ==  'Liability'){
                    ClosingBalance = (openingBal + (creditSum - debitsum));
                    AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));//new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                     if(multiCurrencyEnabled){  AccountNameValue.Container.put('CurrencyIsoCode',isoCode);  AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                }else if(bsd.get('AccountGroup') ==  'Equity'){ 
                    if((Boolean)bsd.get('ContraAccount')){   ClosingBalance = (openingBal+(creditSum - debitsum));   AccountNameValue = AccountGroup3('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));// new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount')); 
                         if(multiCurrencyEnabled){ AccountNameValue.Container.put('CurrencyIsoCode',isoCode);  AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode); }
                        ClosingBalance = -ClosingBalance;
                    }else{
                        ClosingBalance = (openingBal + (creditSum - debitsum));  AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));//new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                         if(multiCurrencyEnabled){  AccountNameValue.Container.put('CurrencyIsoCode',isoCode);  AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode); }
                    } 
                }
                AccountNameValueList = new List<AccountGroup>();
                AccountNameValueList.add(AccountNameValue);
                AccountGroup subAccGrp = AccountGroup1(String.valueOf(bsd.get('SubAccountGroup')),ClosingBalance,JSON.serialize(AccountNameValueList));//new AccountGroup(String.valueOf(bsd.get('SubAccountGroup')),ClosingBalance,AccountNameValueList);
                 if(multiCurrencyEnabled){  subAccGrp.Container.put('CurrencyIsoCode',isoCode);  subAccGrp.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                subAccsList = new List<AccountGroup>();
                subAccsList.add(subAccGrp);
                
                ParentAccount = AccountGroup1(String.valueOf(bsd.get('AccountGroup')), ClosingBalance,JSON.serialize(subAccsList));// new AccountGroup(String.valueOf(bsd.get('AccountGroup')), ClosingBalance,subAccsList);
                if(multiCurrencyEnabled){   ParentAccount.Container.put('CurrencyIsoCode',isoCode);  ParentAccount.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                 
                if(String.valueOf(bsd.get('AccountGroup')) == 'Assets' || String.valueOf(bsd.get('AccountGroup')) == 'Liability' || String.valueOf(bsd.get('AccountGroup')) == 'Equity' ){
                if(FinancialYearWiseAssetMap.get(String.valueOf(bsd.get('AccountGroup'))) == null){               
                    FinancialYearWiseAssetMap.put(String.valueOf(bsd.get('AccountGroup')),ParentAccount);                        
                }else{
                    AccountGroup PAccount = FinancialYearWiseAssetMap.get(String.valueOf(bsd.get('AccountGroup')));
                      if(multiCurrencyEnabled){   PAccount.Container.put('CurrencyIsoCode',isoCode);  PAccount.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                   
                    if(PAccount.SubAccountList != null && PAccount.SubAccountList.size()>0){
                        Boolean flag = true;
                        for(Integer i=0;i<PAccount.SubAccountList.size();i++){
                            if(PAccount.SubAccountList[i].Name == String.valueOf(bsd.get('SubAccountGroup'))){
                                Boolean sflag= true;
                                if(PAccount.SubAccountList[i].SubAccountList != null && PAccount.SubAccountList[i].SubAccountList.size()>0){
                                    for(Integer j=0;j<PAccount.SubAccountList[i].SubAccountList.size();j++){
                                        if(PAccount.SubAccountList[i].SubAccountList[j].Name == String.valueOf(bsd.get('AccountName'))){         PAccount.SubAccountList[i].SubAccountList[j].value += ClosingBalance;sflag = false;
                                        }
                                        
                                    }
                                    
                                    for(Integer j=0;j<PAccount.SubAccountList[i].SubAccountList.size();j++){
                                        PAccount.SubAccountList[i].SubAccountList[j].Container.ERP7__Amount__c = PAccount.SubAccountList[i].SubAccountList[j].value;
                                        PAccount.SubAccountList[i].SubAccountList[j].NContainer.ERP7__Amount__c = 0-PAccount.SubAccountList[i].SubAccountList[j].value;    
                                    }
                                    for(AccountGroup AG: PAccount.SubAccountList[i].SubAccountList){
                                        for(String s:AG.FywiseValues.keyset()){ Map<integer,Decimal> AV = new Map<integer, Decimal>(AG.FywiseValues.get(s));  Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                                            for(Integer aVal : AV.keyset() ){  ERP7__Transaction__c trans=new ERP7__Transaction__c();  trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                                                if(multiCurrencyEnabled) trans.put('CurrencyIsoCode',isoCode);
                                                setAV.put(aVal,trans);   } AG.GContainerFyWValues.put(s,setAV);
                                        }
                                    }
                                    
                                }
                                if(sflag){
                                    PAccount.SubAccountList[i].SubAccountList.add(AccountNameValue);
                                }
                                PAccount.SubAccountList[i].value += ClosingBalance;
                                flag = false;
                            }
                            
                            
                        }  
                        
                        for(Integer i=0;i<PAccount.SubAccountList.size();i++){
                            PAccount.SubAccountList[i].Container.ERP7__Amount__c = PAccount.SubAccountList[i].value;
                            PAccount.SubAccountList[i].NContainer.ERP7__Amount__c = 0-PAccount.SubAccountList[i].value;    
                        }   
                        
                        for(AccountGroup AG: PAccount.SubAccountList){
                            for(String s:AG.FywiseValues.keyset()){  Map<integer,Decimal> AV = new Map<integer, Decimal>(AG.FywiseValues.get(s));  Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                                for(Integer aVal : AV.keyset() ){
                                    ERP7__Transaction__c trans=new ERP7__Transaction__c(); trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                                    if(multiCurrencyEnabled) trans.put('CurrencyIsoCode',isoCode);
                                    setAV.put(aVal,trans); } AG.GContainerFyWValues.put(s,setAV);
                            }
                        }
                        if(flag){   PAccount.SubAccountList.add(subAccGrp); }
                        
                        PAccount.value += ClosingBalance;
                        PAccount.Container.ERP7__Amount__c = PAccount.value;
                        PAccount.NContainer.ERP7__Amount__c = 0-PAccount.value;
                    }       
                }
            }
            }
            addCurrentYearEarnings();  
            buildAccountsRendereingMap();
            if(FinancialYearWiseAssetMap != null &&  FinancialYearWiseAssetMap.get('Assets')!= null) Total_Assets.ERP7__Opening_Balance__c =  FinancialYearWiseAssetMap.get('Assets').value;
            if(FinancialYearWiseAssetMap != null && FinancialYearWiseAssetMap.get('Equity') != null && FinancialYearWiseAssetMap.get('Liability') != null) 
                Total_Liab_Equity.ERP7__Opening_Balance__c = FinancialYearWiseAssetMap.get('Liability').value+ FinancialYearWiseAssetMap.get('Equity').value;
            }catch(Exception e){
                system.debug('Exception-->'+e+e.getLineNumber());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
            return null;  
    }

    public void buildAccountsRendereingMap(){
        try{
            for(String s:balanceSheetAccounts.keyset()){
                balanceSheetAccounts.put(s,FinancialYearWiseAssetMap.containskey(s));
            }
        }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));  return ;
        }   
    }
    public void  addLiabilityandEquity(){
        try{
            Boolean IsmultiCurrencyEnabled;    String isoCode;   IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){   isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
            
            if(FinancialYearWiseAssetMap.get('Liability')!=null && FinancialYearWiseAssetMap.get('Equity') != null){  
                AccountGroup LAccount =  FinancialYearWiseAssetMap.get('Liability');
                 if(IsmultiCurrencyEnabled){ LAccount.Container.put('CurrencyIsoCode',isoCode); LAccount.NContainer.put('CurrencyIsoCode',isoCode);
                     }
                AccountGroup EAccount =  FinancialYearWiseAssetMap.get('Equity'); 
                 if(IsmultiCurrencyEnabled){ EAccount.Container.put('CurrencyIsoCode',isoCode);  EAccount.NContainer.put('CurrencyIsoCode',isoCode);
                     }
                EAccount.value += LAccount.value; EAccount.Name = 'Liability and Equity';
            }
         }catch(Exception e){ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));  return ;
        }   
    }
    public void addCurrentYearEarnings(){ 
        try{ 
            Boolean IsmultiCurrencyEnabled;            
            String isoCode;
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){   isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
                }
            
            AccountGroup ParentAccount = new AccountGroup();
            if(IsmultiCurrencyEnabled){  ParentAccount.Container.put('CurrencyIsoCode',isoCode);   ParentAccount.NContainer.put('CurrencyIsoCode',isoCode);
                     }
            List<AccountGroup> AccountNameValueList = new List<AccountGroup>(); 
            List<AccountGroup> SubAccountList = new List<AccountGroup>(); 
            List<AccountGroup> subAccsList = new List<AccountGroup>(); 
            Decimal Income = (FyWiseIncomeMap.get('Income_Revenue')!= null)? 
                FyWiseIncomeMap.get('Income_Revenue'):0.00; Decimal Expense = (FyWiseExpenseMap.get('Expense')!= null)? FyWiseExpenseMap.get('Expense'):0.00; 
            Decimal TotalEarnings = Income-Expense;  //(Income-Expense) 
            AccountGroup AccountNameValue = AccountGroup3(RE_COA,TotalEarnings,false); // new AccountGroup(RE_COA,TotalEarnings,false); 
            if(IsmultiCurrencyEnabled){   AccountNameValue.Container.put('CurrencyIsoCode',isoCode);   AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                     }
            AccountNameValueList = new List<AccountGroup>();
            AccountNameValueList.add(AccountNameValue);
            AccountGroup subAccGrp = AccountGroup1(RE_COA,TotalEarnings,JSON.serialize(AccountNameValueList));//new AccountGroup(RE_COA,TotalEarnings,AccountNameValueList); 
            if(IsmultiCurrencyEnabled){   subAccGrp.Container.put('CurrencyIsoCode',isoCode);  subAccGrp.NContainer.put('CurrencyIsoCode',isoCode);
                     }
            if(FinancialYearWiseAssetMap.get('Liability') != null)
                if(FinancialYearWiseAssetMap.get('Equity')== null){  subAccsList = new List<AccountGroup>(); subAccsList.add(subAccGrp); ParentAccount = AccountGroup1('Equity', TotalEarnings,JSON.serialize(subAccsList));
                     if(IsmultiCurrencyEnabled){   ParentAccount.Container.put('CurrencyIsoCode',isoCode);  ParentAccount.NContainer.put('CurrencyIsoCode',isoCode);
                     }
                    FinancialYearWiseAssetMap.put('Equity',ParentAccount);
                }else {
                   
                    AccountGroup PAccount = FinancialYearWiseAssetMap.get('Equity');  if(IsmultiCurrencyEnabled){   PAccount.Container.put('CurrencyIsoCode',isoCode); PAccount.NContainer.put('CurrencyIsoCode',isoCode); }
                    if(PAccount.SubAccountList != null && PAccount.SubAccountList.size()>0){  PAccount.SubAccountList.add(subAccGrp);  }  else{PAccount.SubAccountList = subAccsList;  }
                    PAccount.value += TotalEarnings;
                }       
        }catch(Exception e){   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));  return ;
        }   
        
    }
 
    public PageReference ComputeData(){
        try{
            /*Boolean IsmultiCurrencyEnabled;            
            String isoCode;
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){      isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
            // For converting to other currency
              Decimal conversionRate=1;
                    if(IsmultiCurrencyEnabled){
                        String iso  = UserInfo.getDefaultCurrency();  String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso';   conversionRate= (Decimal) Database.Query(q)[0].get('conversionRate'); 
                    }   
             // End of converting to other currency  
            String StartDate = apexpages.currentpage().getparameters().get('StartDate');
            String EndDate = apexpages.currentpage().getparameters().get('EndDate');
            system.debug('StartDate -->'+StartDate);
            system.debug('EndDate -->'+EndDate);
            Date start_date = Date.valueOf(StartDate);
            Date end_Date = Date.valueOf(EndDate);
            
            Date Sfy = Date.parse(minDate);
            if(SelectedFy.equalsIgnoreCase('2') || SelectedFy.equalsIgnoreCase('3')) 
            sfy =sfy.addYears(1-Integer.valueof(SelectedFy));  startfy = sfy.format(); endfy = max_date;
            compareBalanceSheetMap = new Map<String,AccountGroup>(); Map<Id,ERP7__Chart_of_Accounts__c> chart_Of_Accounts = new Map<Id,ERP7__Chart_of_Accounts__c>([SELECT Name,RecordTypeId,ERP7__isContra_Account__c,
            ERP7__Account_Type__c,RecordType.DeveloperName,ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where ERP7__Active__c = true ]);
            if((chart_Of_Accounts.size() == 0 || chart_Of_Accounts == null ) && showBalancesheet){  showBalancesheet = false; ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: No Chart of Accounts, found For selected Organisation.'); ApexPages.addMessage(myMsg); return null; }
            
            String DbQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit,'+ 
            'ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,'+
            ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount,CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly'+
            ' FROM ERP7__Finance_General_Ledger_Entry__c where '+
            ' DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date '+ 
            ' '+'\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Assets\',\'Liability\',\'Equity\',\'Income_Revenue\',\'Expense\')'+
            ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC limit 5000';
           
            String CoaQuery = 'SELECT ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,'+
            ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly'+
            ' FROM ERP7__Finance_General_Ledger_Entry__c where '+ 
            ' DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date '+ ' '+'\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Assets\',\'Liability\',\'Equity\',\'Income_Revenue\',\'Expense\')'+
            ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC limit 5000';
            
            List<AggregateResult> BalanceSheetData = Database.query(DbQuery);
            List<AggregateResult> COAList = Database.query(CoaQuery);
            Map<String,Map<Integer,decimal>> TempYear = new Map<String,Map<Integer,decimal>>();
            Map<Integer,decimal> quarterMap = new Map<Integer,decimal>();
            Map<Integer,Decimal> TotalList = new Map<Integer,Decimal>();
            if(YearorQuarter.containsIgnoreCase('Month')){    showMonthly = true;  showFywise = false;  ShowQuartely = false;    }
            else if(YearorQuarter.containsIgnoreCase('Quarter')||FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter') ){  showMonthly = false; showFywise = false; ShowQuartely = true;}
            else{  showMonthly = false; showFywise = true; ShowQuartely = false;
                
            }
            Integer NoQ_M;
            if(!FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter') && (SelectedFy.containsAny('123'))){
                NoQ_M = (YearorQuarter.containsIgnoreCase('Month'))? 12 : (YearorQuarter.containsIgnoreCase('Quarter'))? 4 : 1 ;
                Integer Ylen = Integer.valueOf(SelectedFy);
                TempYear = new Map<String,Map<Integer,Decimal>>();
                
                for(Integer j=0;j<YLen;j++){
                    TotalList= new Map<Integer,Decimal>();
                    if(YearorQuarter.containsIgnoreCase('Year') && (SelectedFy.containsAny('123'))){
                        TotalList.put(((mon==1)?System.today().Year():System.today().Year()-1)-j,0.00); 
                    }else if((YearorQuarter.containsIgnoreCase('Month') || YearorQuarter.containsIgnoreCase('Quarter')) && (SelectedFy.containsAny('123'))){
                        for(integer i=1;i<NoQ_M+1;i++){    TotalList.put(i,0.00); }
                    }
                    TempYear.put(String.valueOf(((mon==1)?System.today().Year():System.today().Year()-1)-j),TotalList);
                    CompareFyWiseExpenseMap.put(String.valueOf(((mon==1)?System.today().Year():System.today().Year()-1)-j),new Map<Integer,Decimal>(TotalList));
                    CompareFyWiseIncomeMap.put(String.valueOf(((mon==1)?System.today().Year():System.today().Year()-1)-j),new Map<Integer,Decimal>(TotalList));
                }  
                
            }else{
                for(AggregateResult coa:COAList){ quarterMap = new Map<Integer,decimal>();
                    if(TempYear.get(String.valueOf(coa.get('Fyear'))) != null) quarterMap = TempYear.get(String.valueOf(coa.get('Fyear')));
                    quarterMap.put(Integer.valueOf(coa.get('FQuarter')),0.00);  TempYear.put(String.valueOf(coa.get('Fyear')),quarterMap);
                }
            } 
            for(AggregateResult bsd:BalanceSheetData){
               Map<String,Map<Integer,Decimal>> AcctValYear = new  Map<String,Map<Integer,Decimal>>();
                Map<String,Map<Integer,Decimal>> ParentGroupYear = new Map<String,Map<Integer,Decimal>>();
                Map<String,Map<Integer,Decimal>> SubGroupYear = new Map<String,Map<Integer,Decimal>>();
                for(String ss:TempYear.keyset()){
                    AcctValYear.put(ss,new Map<Integer,Decimal>(TempYear.get(ss)));
                    SubGroupYear.put(ss,new Map<Integer,Decimal>(TempYear.get(ss)));
                    ParentGroupYear.put(ss,new Map<Integer,Decimal>(TempYear.get(ss)));
                }
                Decimal openingBal = (chart_Of_Accounts.get((ID)bsd.get('AccountId'))!= null)? chart_Of_Accounts.get((ID)bsd.get('AccountId')).ERP7__Opening_Balance__c:0.00;
                Decimal creditSum = 0.0;
                Decimal debitsum = 0.0;
                Decimal ClosingBalance = 0.0;
                Decimal TotalIncome = 0.00;
                Decimal TotalExpense = 0.00;
                AccountGroup AccountNameValue = new AccountGroup();
                if(IsmultiCurrencyEnabled){   AccountNameValue.Container.put('CurrencyIsoCode',isoCode); AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                }
                AccountGroup ParentAccount = new AccountGroup();
                if(IsmultiCurrencyEnabled){  ParentAccount.Container.put('CurrencyIsoCode',isoCode);   ParentAccount.NContainer.put('CurrencyIsoCode',isoCode);
                }
                List<AccountGroup> AccountNameValueList = new List<AccountGroup>();
                List<AccountGroup> subAccsList = new List<AccountGroup>();
                YearorQuarter = (FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter'))? 'FQuarter' :  YearorQuarter;
               // if(bsd.get('Credit') != null) creditSum = double.valueOf(bsd.get('Credit'));
               // if(bsd.get('Debit') != null) debitsum = double.valueOf(bsd.get('Debit'));
               
                // For mulitiplication of currencies
                if(bsd.get('Credit') != null){ 
                    if(IsmultiCurrencyEnabled){
                        if( isoCode != UserInfo.getDefaultCurrency()){creditSum = double.valueOf(bsd.get('Credit')) * double.valueOf(conversionRate );}
                        else creditSum = double.valueOf(bsd.get('Credit'));
                       }
                    else{
                        creditSum = double.valueOf(bsd.get('Credit'));
                    }
                } 
                if(bsd.get('Debit') != null){
                    if(IsmultiCurrencyEnabled){ 
                        if( isoCode != UserInfo.getDefaultCurrency()){debitsum = double.valueOf(bsd.get('Debit')) * double.valueOf(conversionRate );}
                        else debitsum = double.valueOf(bsd.get('Debit'));
                    }else{
                         debitsum = double.valueOf(bsd.get('Debit'));
                    }
                } 
                // End of mulitiplication of currencies   
                
                if(bsd.get('AccountGroup') ==  'Assets'){
                    if((Boolean)bsd.get('ContraAccount')){
                        ClosingBalance = (openingBal +(creditSum - debitsum));
                        Map<Integer,Decimal> valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                        valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),ClosingBalance);
                        AcctValYear.put(String.valueOf(bsd.get('Fyear')),valueMap);
                        AccountNameValue = AccountGroup4('Less:'+String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));//new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                        if(IsmultiCurrencyEnabled){     AccountNameValue.Container.put('CurrencyIsoCode',isoCode);   AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                
                        ClosingBalance = -ClosingBalance;
                    }else{
                       
                        ClosingBalance = (openingBal - (creditSum - debitsum));
                        Map<Integer,Decimal> valueMap =  AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                        valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),ClosingBalance);
                        AcctValYear.put(String.valueOf(bsd.get('Fyear')),valueMap);
                        AccountNameValue = AccountGroup4(String.valueOf(bsd.get('AccountName')),new Map<String,Map<Integer,Decimal>>(AcctValYear),(Boolean)bsd.get('ContraAccount'));// new AccountGroup(String.valueOf(bsd.get('AccountName')),new Map<String,Map<Integer,Decimal>>(AcctValYear),(Boolean)bsd.get('ContraAccount'));
                        if(IsmultiCurrencyEnabled){  AccountNameValue.Container.put('CurrencyIsoCode',isoCode); AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                
                    }
                }else if(bsd.get('AccountGroup') ==  'Liability'){
                    ClosingBalance = (openingBal + (creditSum - debitsum));
                    Map<Integer,Decimal> valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                    valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),ClosingBalance);
                    AcctValYear.put(String.valueOf(bsd.get('Fyear')),valueMap);
                    AccountNameValue = AccountGroup4(String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));//new AccountGroup(String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                    if(IsmultiCurrencyEnabled){   AccountNameValue.Container.put('CurrencyIsoCode',isoCode);  AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                    }
                }else if(bsd.get('AccountGroup') ==  'Equity'){
                    if((Boolean)bsd.get('ContraAccount')){  ClosingBalance = (openingBal+(creditSum - debitsum)); Map<Integer,Decimal> valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));     valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),ClosingBalance); AcctValYear.put(String.valueOf(bsd.get('Fyear')),valueMap);       AccountNameValue = AccountGroup4('Less:'+String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));//new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                        if(IsmultiCurrencyEnabled){  AccountNameValue.Container.put('CurrencyIsoCode',isoCode);  AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                        ClosingBalance = -ClosingBalance;
                    }else{  ClosingBalance = (openingBal + (creditSum - debitsum)); Map<Integer,Decimal> valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear'))); valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),ClosingBalance);    AcctValYear.put(String.valueOf(bsd.get('Fyear')),valueMap);    AccountNameValue = AccountGroup4(String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));// new AccountGroup(String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                        if(IsmultiCurrencyEnabled){ AccountNameValue.Container.put('CurrencyIsoCode',isoCode);  AccountNameValue.NContainer.put('CurrencyIsoCode',isoCode);
                        }
                       } 
                }else if(bsd.get('AccountGroup') ==  'Income_Revenue'){
                    if((Boolean)bsd.get('ContraAccount')){
                        ClosingBalance = (openingBal+(creditSum - debitsum));
                        if(CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear')))!= null){
                            Map<Integer,Decimal> valueMap = CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear')));
                            TotalIncome  = valueMap.get(Integer.valueOf(bsd.get(YearorQuarter)));
                            TotalIncome  += ClosingBalance;
                            valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),TotalIncome);
                            CompareFyWiseIncomeMap.put(String.valueOf(bsd.get('AccountGroup')),valueMap);
                        }
                    }else{  ClosingBalance = (openingBal + (creditSum + debitsum));
                        if(CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear')))!= null){  Map<Integer,Decimal> valueMap = CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear')));  TotalIncome  = valueMap.get(Integer.valueOf(bsd.get(YearorQuarter)));  TotalIncome  += ClosingBalance;   valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),TotalIncome);  CompareFyWiseIncomeMap.put(String.valueOf(bsd.get('AccountGroup')),valueMap);  }       
                    } 
                }else if(bsd.get('AccountGroup') ==  'Expense'){ ClosingBalance = (openingBal - (creditSum - debitsum));
                    if(CompareFyWiseExpenseMap.get(String.valueOf(bsd.get('Fyear')))!= null){ Map<Integer,Decimal> valueMap = CompareFyWiseExpenseMap.get(String.valueOf(bsd.get('Fyear')));  TotalIncome  = valueMap.get(Integer.valueOf(bsd.get(YearorQuarter)));   TotalIncome  += ClosingBalance; valueMap.put(Integer.valueOf(bsd.get(YearorQuarter)),TotalIncome);  CompareFyWiseExpenseMap.put(String.valueOf(bsd.get('AccountGroup')),valueMap);    
                    }      
                }
                AccountNameValueList = new List<AccountGroup>();
                AccountNameValueList.add(AccountNameValue);
                Map<Integer,Decimal> SubGrpvalueMap = new Map<Integer,Decimal>(SubGroupYear.get(String.valueof(bsd.get('Fyear'))));
                SubGrpvalueMap.put(Integer.valueof(bsd.get(YearorQuarter)),ClosingBalance);
                SubGroupYear.put(String.valueof(bsd.get('Fyear')),new Map<Integer,Decimal>(SubGrpvalueMap));
                AccountGroup subAccGrp =AccountGroup2(String.valueOf(bsd.get('SubAccountGroup')),new Map<String,Map<Integer,Decimal>>(SubGroupYear),JSON.serialize(AccountNameValueList),IsmultiCurrencyEnabled);// new AccountGroup(String.valueOf(bsd.get('SubAccountGroup')),new Map<String,Map<Integer,Decimal>>(SubGroupYear),AccountNameValueList);
                if(IsmultiCurrencyEnabled){ subAccGrp.Container.put('CurrencyIsoCode',isoCode); subAccGrp.NContainer.put('CurrencyIsoCode',isoCode);
                }
                subAccsList = new List<AccountGroup>();
                subAccsList.add(subAccGrp);
                Map<Integer,Decimal> parentValueMap =  new Map<Integer,Decimal>(ParentGroupYear.get(String.valueof(bsd.get('Fyear'))));
                parentValueMap.put(Integer.valueof(bsd.get(YearorQuarter)),ClosingBalance);
                ParentGroupYear.put(String.valueof(bsd.get('Fyear')),parentValueMap);
                ParentAccount = AccountGroup2(String.valueOf(bsd.get('AccountGroup')), new Map<String,Map<Integer,Decimal>>(ParentGroupYear),JSON.serialize(subAccsList),IsmultiCurrencyEnabled);//new AccountGroup(String.valueOf(bsd.get('AccountGroup')), new Map<String,Map<Integer,Decimal>>(ParentGroupYear),subAccsList);
                if(IsmultiCurrencyEnabled){  ParentAccount.Container.put('CurrencyIsoCode',isoCode);  ParentAccount.NContainer.put('CurrencyIsoCode',isoCode);
                }
                
                if(String.valueOf(bsd.get('AccountGroup')) == 'Assets' || String.valueOf(bsd.get('AccountGroup')) == 'Liability' || String.valueOf(bsd.get('AccountGroup')) == 'Equity' )
                if(compareBalanceSheetMap.get(String.valueOf(bsd.get('AccountGroup'))) == null){               
                    compareBalanceSheetMap.put(String.valueOf(bsd.get('AccountGroup')),ParentAccount);                        
                }else{
                    AccountGroup PAccount = compareBalanceSheetMap.get(String.valueOf(bsd.get('AccountGroup')));
                    if(IsmultiCurrencyEnabled){ PAccount.Container.put('CurrencyIsoCode',isoCode);  PAccount.NContainer.put('CurrencyIsoCode',isoCode);
                    }
                
                    if(PAccount.SubAccountList != null && PAccount.SubAccountList.size()>0){
                        Boolean flag = true;
                        for(Integer i=0;i<PAccount.SubAccountList.size();i++){
                            if(PAccount.SubAccountList[i].Name == String.valueOf(bsd.get('SubAccountGroup'))){
                                Boolean sflag= true;
                                if(PAccount.SubAccountList[i].SubAccountList != null && PAccount.SubAccountList[i].SubAccountList.size()>0){
                                    for(Integer j=0;j<PAccount.SubAccountList[i].SubAccountList.size();j++){
                                        if(PAccount.SubAccountList[i].SubAccountList[j].Name == String.valueOf(bsd.get('AccountName'))){  Decimal currentVal = PAccount.SubAccountList[i].SubAccountList[j].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(YearOrQuarter))); currentVal+= ClosingBalance; PAccount.SubAccountList[i].SubAccountList[j].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).put(Integer.valueOf(bsd.get(YearOrQuarter)),currentVal);  sflag = false;
                                        }
                                        
                                    }
                                    
                                }
                                if(sflag){
                                    PAccount.SubAccountList[i].SubAccountList.add(AccountNameValue);
                                }
                                Decimal SubcurrentVal = PAccount.SubAccountList[i].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(YearOrQuarter))); SubcurrentVal+= ClosingBalance;
                                PAccount.SubAccountList[i].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).put(Integer.valueOf(bsd.get(YearOrQuarter)),SubcurrentVal);
                                PAccount.SubAccountList[i].value += ClosingBalance;
                                flag = false;
                            }
                      }     
                        for(Integer i=0;i<PAccount.SubAccountList.size();i++){
                            PAccount.SubAccountList[i].Container.ERP7__Amount__c = PAccount.SubAccountList[i].value;
                            if(IsmultiCurrencyEnabled)PAccount.SubAccountList[i].Container.put('CurrencyIsoCode',isoCode);
                            PAccount.SubAccountList[i].NContainer.ERP7__Amount__c = 0-PAccount.SubAccountList[i].value;
                            if(IsmultiCurrencyEnabled)PAccount.SubAccountList[i].NContainer.put('CurrencyIsoCode',isoCode);
                        } 
                        for(AccountGroup AG: PAccount.SubAccountList){
                            for(String s:AG.FywiseValues.keyset()){
                                Map<integer,Decimal> AV=new Map<integer, Decimal>(AG.FywiseValues.get(s));
                                Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                                for(Integer aVal : AV.keyset() ){
                                    ERP7__Transaction__c trans=new ERP7__Transaction__c();
                                    trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                                    if(multiCurrencyEnabled) trans.put('CurrencyIsoCode',isoCode);
                                    setAV.put(aVal,trans);
                                }
                                AG.GContainerFyWValues.put(s,setAV);
                            }
                        }
                        if(flag){PAccount.SubAccountList.add(subAccGrp);
                        }
                        
                        Decimal pcurrentVal = PAccount.FywiseValues.get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(YearOrQuarter)));pcurrentVal+= ClosingBalance;
                        PAccount.FywiseValues.get(String.valueOf(bsd.get('Fyear'))).put(Integer.valueOf(bsd.get(YearOrQuarter)),pcurrentVal);
                    }                
                }
            }/*End of For Loop BSd*
            
            Map<String,Map<Integer,Decimal>> RetainedEarnings = new  Map<String,Map<Integer,Decimal>>();
            Map<String,Map<Integer,Decimal>> parentEarnings = new  Map<String,Map<Integer,Decimal>>();
            for(String ss:TempYear.keyset()){
                RetainedEarnings.put(ss,new Map<Integer,Decimal>(TempYear.get(ss)));
                parentEarnings.put(ss,new Map<Integer,Decimal>(TempYear.get(ss)));
            }
            Map<Integer,Decimal> tmap ;
            Map<String,Map<Integer,Decimal>> LiabilityAndEquity = new  Map<String,Map<Integer,Decimal>>();
            Map<Integer,Decimal> t_map ;
            /* Adding Laibility And Equity *
            for(String str:TempYear.keyset()){
                t_map = new Map<Integer,Decimal>(); 
                for(Integer i : TempYear.get(str).keyset()){
                    Decimal Eval = (compareBalanceSheetMap.get('Liability') != null)?compareBalanceSheetMap.get('Liability').FywiseValues.get(str).get(i):0.00;
                    Decimal Lval = (compareBalanceSheetMap.get('Equity') != null)?compareBalanceSheetMap.get('Equity').FywiseValues.get(str).get(i):0.00;
                    t_map.put(i,(Lval+Eval));
                }
                LiabilityAndEquity.put(Str,t_map);
            }
            
            AccountGroup  Parent_Account = AccountGroup2('Liabilty And Equity', new Map<String,Map<Integer,Decimal>>(LiabilityAndEquity),JSON.serialize(new List<AccountGroup>()),multiCurrencyEnabled);//new AccountGroup('Liabilty And Equity', new Map<String,Map<Integer,Decimal>>(LiabilityAndEquity),new List<AccountGroup>());
            if(IsmultiCurrencyEnabled){  Parent_Account.Container.put('CurrencyIsoCode',isoCode); Parent_Account.NContainer.put('CurrencyIsoCode',isoCode);
            }
               
            compareBalanceSheetMap.put('Liabilty And Equity',Parent_Account);       
            
            getdata();*/
            return null;
        }catch(Exception e){    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));   return null;
        }   
    }
    public string getRE_AccountName( String OrgId){
        try{
        return [Select Name From ERP7__Chart_of_Accounts__c Where  ERP7__Account_Type__c = 'Retained_Earnings' limit 1].Name;//Organisation__c=:OrgId AND
        }catch(Exception e){
            return 'Net Profit';
        }
        
    }
    public pageReference getDates(){
    if(String.isNotEmpty(SelectedFy_BS)){
       string Type = (SelectedFy_BS.containsAny('123'))?'Year':'Quarter'; List< AggregateResult > selectedPeriod = new List< AggregateResult >();
       selectedPeriod = Database.query('SELECT MIN(StartDate) startDate, MAX(EndDate) endDate FROM Period WHERE Type =\''+String.escapeSingleQuotes(Type)+'\' AND '+String.escapeSingleQuotes(FiscalYear.get(SelectedFy_BS)));
       if(selectedPeriod.size()>0){
           startDate = date.valueOf(String.valueof(selectedPeriod[0].get('startDate'))).format();   EndDate = date.valueOf(String.valueof(selectedPeriod[0].get('endDate'))).format();
       }
    }
    return null;
    }
    public PageReference FetchData(){
        return ComputeSelectedFyData();
    }

    public PageReference Refreshtab(){
        showChart =   true;
        return null;
    }
    public List<SelectOption> getFinancialYearList(){
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','Fiscal year',true));
        options.add(new SelectOption('1','Current FY'));
        options.add(new SelectOption('2','Current and Previous FY'));
        options.add(new SelectOption('3','Current and Previous 2 FY'));
        options.add(new SelectOption('None','Fiscal Quarter',true));
        options.add(new SelectOption('4','Current FQ'));
        options.add(new SelectOption('5','Current and Next FQ'));
        options.add(new SelectOption('6','Next FQ'));
        options.add(new SelectOption('7','Current and Previous FQ'));
        return options;
        
    }

    public pagereference Downloadpdf(){
        PageReference balanceSheet_pdf = Page.ERP7__BalanceSheetAsPdf;
        balanceSheet_pdf.setRedirect(false);
        return balanceSheet_pdf;
    } 
    public pagereference DownloadComparisonpdf(){
        PageReference balanceSheet_Doc = Page.ERP7__ComparisonBalanceSheet;
        balanceSheet_Doc.setRedirect(false);
        return balanceSheet_Doc;
    }   
    
    //Methods
    public AccountGroup AccountGroup1(String AccName,Decimal val,String subAcclist1){
            List<AccountGroup> subAcclist = (List<AccountGroup>)JSON.deserialize(subAcclist1, List<AccountGroup>.class);
        AccountGroup AGroup = new AccountGroup();
            AGroup.Name = AccName;
            AGroup.value = val;
            AGroup.SubAccountList = subAcclist;
            AGroup.Container = new ERP7__Transaction__c();
            AGroup.Container.ERP7__Amount__c = val.setscale(2);
            AGroup.NContainer = new ERP7__Transaction__c();
            AGroup.NContainer.ERP7__Amount__c = 0-val.setscale(2);
            Map<String,Map<Integer,decimal>> Fy = new Map<String,Map<Integer,decimal>>();
            for(AccountGroup AG: AGroup.SubAccountList){
                for(String s:AG.FywiseValues.keyset()){  Map<integer,Decimal> AV = new Map<integer, Decimal>(AGroup.FywiseValues.get(s)); Map<integer,ERP7__Transaction__c> setAV = new Map<integer,ERP7__Transaction__c>();
                    for(Integer aVal : AV.keyset() ){ERP7__Transaction__c trans=new ERP7__Transaction__c();  trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                        if(AG.IsmultiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                        setAV.put(aVal,trans); } AG.GContainerFyWValues.put(s,setAV);
                }
            }
             for(AccountGroup AG : AGroup.SubAccountList){
                AG.Container.ERP7__Amount__c = AG.Value.setscale(2);
                AG.NContainer.ERP7__Amount__c = 0-AG.Value.setscale(2);
            }
        return AGroup;
    }
    
    public AccountGroup AccountGroup2(String AccName ,Map<String,Map<Integer,decimal>> val,String subAcclist1,Boolean IsmultiCurrencyEnabled){
            List<AccountGroup> subAcclist = (List<AccountGroup>)JSON.deserialize(subAcclist1, List<AccountGroup>.class);
        AccountGroup AGroup = new AccountGroup();
            AGroup.Name = AccName;
            AGroup.FywiseValues = val;
            AGroup.SubAccountList = subAcclist;
            AGroup.Container = new ERP7__Transaction__c();
            AGroup.NContainer = new ERP7__Transaction__c();
            for(AccountGroup AG: AGroup.SubAccountList){
                for(String s:AG.FywiseValues.keyset()){
                    Map<integer,Decimal> AV=new Map<integer, Decimal>(AGroup.FywiseValues.get(s));
                    Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                    for(Integer aVal : AV.keyset() ){
                        ERP7__Transaction__c trans=new ERP7__Transaction__c();
                        trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                        if(AG.IsmultiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                        setAV.put(aVal,trans);
                    }
                    AG.GContainerFyWValues.put(s,setAV);
                }
            }
            for(String FWV : val.keyset() ){
                Map<integer,Decimal> AV=new Map<integer, Decimal>(AGroup.FywiseValues.get(FWV));
                Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                for(Integer aVal : AV.keyset() ){
                    ERP7__Transaction__c trans=new ERP7__Transaction__c();
                    trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                    if(IsmultiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                    setAV.put(aVal,trans);
                }
                AGroup.GContainerFyWValues.put(FWV,setAV);
            }
            for(AccountGroup AG : AGroup.SubAccountList){
                AG.Container.ERP7__Amount__c = AG.Value.setscale(2);
                AG.NContainer.ERP7__Amount__c = 0-AG.Value.setscale(2);
            }
         return AGroup;
    }
    
    public AccountGroup AccountGroup3(String AccName,Decimal val,Boolean flag){
            AccountGroup AG = new AccountGroup();
            AG.Name = AccName;
            AG.value = val;
            AG.contraFlag = flag;
            AG.Container = new ERP7__Transaction__c();
            AG.Container.ERP7__Amount__c = val.setscale(2);
            AG.NContainer = new ERP7__Transaction__c();
            AG.NContainer.ERP7__Amount__c = 0-val.setscale(2);
            return AG;
    }
    
    public AccountGroup AccountGroup4(String AccName,Map<String,Map<Integer,decimal>> val,Boolean flag){
            AccountGroup AGroup = new AccountGroup();
            AGroup.Name = AccName;
            AGroup.FywiseValues = val;
            AGroup.contraFlag = flag;
            for(String FWV : val.keyset() ){
                Map<integer,Decimal> AV=new Map<integer, Decimal>(AGroup.FywiseValues.get(FWV));
                Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                for(Integer aVal : AV.keyset() ){
                    ERP7__Transaction__c trans=new ERP7__Transaction__c();
                    trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                    setAV.put(aVal,trans);
                }
                AGroup.GContainerFyWValues.put(FWV,setAV);
            }
            AGroup.Container = new ERP7__Transaction__c();
            AGroup.NContainer = new ERP7__Transaction__c();
            return AGroup;
    }
    
    
    
    
    /*Wrapper datatype*/
    public class AccountGroup  {
        public String Name                          { get; set; }
        public decimal Value                        { get; set; }
        public List<AccountGroup>  SubAccountList   { get; set; }
        public Boolean contraFlag                   { get; set; }
        public Map<String,Map<Integer,decimal>> FywiseValues { get; set; }
        public Map<String,Map<Integer,ERP7__Transaction__c>> GContainerFyWValues {get;set;}
        public ERP7__Transaction__c Container              {get;set;}
        public ERP7__Transaction__c NContainer             {get;set;}
        public Boolean IsmultiCurrencyEnabled             {get;set;}   public String isoCode                          { get; set; }
        
        /*Instance Intialization Block*/
        {
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){
            }
            Name = '';
            value = 0.00;
            SubAccountList = new List<AccountGroup>();
            contraFlag = false;
            FywiseValues = new Map<String,Map<Integer,decimal>>();
            GContainerFyWValues = new Map<String,Map<Integer,ERP7__Transaction__c>>(); 
            this.Container = new ERP7__Transaction__c();
            this.Container.ERP7__Amount__c = 0.00;
            this.NContainer = new ERP7__Transaction__c();
            this.NContainer.ERP7__Amount__c = 0.00;
        }
        public AccountGroup(){
        }
        
        public AccountGroup(String AccName,Decimal val,List<AccountGroup> subAcclist){  this.Name = AccName;  this.value = val; this.SubAccountList = subAcclist; this.Container = new ERP7__Transaction__c();this.Container.ERP7__Amount__c = val.setscale(2); this.NContainer = new ERP7__Transaction__c();  this.NContainer.ERP7__Amount__c = 0-val.setscale(2);
            if(IsmultiCurrencyEnabled){}  Map<String,Map<Integer,decimal>> Fy = new Map<String,Map<Integer,decimal>>();
            for(AccountGroup AG: this.SubAccountList){for(String s:AG.FywiseValues.keyset()){ Map<integer,Decimal> AV = new Map<integer, Decimal>(this.FywiseValues.get(s)); Map<integer,ERP7__Transaction__c> setAV = new Map<integer,ERP7__Transaction__c>();
                    for(Integer aVal : AV.keyset() ){ ERP7__Transaction__c trans=new ERP7__Transaction__c();  trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                        if(AG.IsmultiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                        setAV.put(aVal,trans); } AG.GContainerFyWValues.put(s,setAV);
                }
            }
             for(AccountGroup AG : this.SubAccountList){  AG.Container.ERP7__Amount__c = AG.Value.setscale(2);  AG.NContainer.ERP7__Amount__c = 0-AG.Value.setscale(2);   }
        }
        public AccountGroup(String AccName ,Map<String,Map<Integer,decimal>> val,List<AccountGroup> subAcclist){ this.Name = AccName;  this.FywiseValues = val; this.SubAccountList = subAcclist; this.Container = new ERP7__Transaction__c(); this.NContainer = new ERP7__Transaction__c();
            
            if(IsmultiCurrencyEnabled){  }
            
            for(AccountGroup AG: this.SubAccountList){
                for(String s:AG.FywiseValues.keyset()){
                    Map<integer,Decimal> AV=new Map<integer, Decimal>(this.FywiseValues.get(s));
                    Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                    for(Integer aVal : AV.keyset() ){ ERP7__Transaction__c trans=new ERP7__Transaction__c(); trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                        if(AG.IsmultiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                        setAV.put(aVal,trans);   } AG.GContainerFyWValues.put(s,setAV);
                }
            }
            for(String FWV : val.keyset() ){ Map<integer,Decimal> AV=new Map<integer, Decimal>(this.FywiseValues.get(FWV));   Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                for(Integer aVal : AV.keyset() ){    ERP7__Transaction__c trans=new ERP7__Transaction__c(); trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                    if(IsmultiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                    setAV.put(aVal,trans);
                } this.GContainerFyWValues.put(FWV,setAV);
            }
            for(AccountGroup AG : this.SubAccountList){   AG.Container.ERP7__Amount__c = AG.Value.setscale(2);   AG.NContainer.ERP7__Amount__c = 0-AG.Value.setscale(2);   }
        }
        
        public AccountGroup(String AccName,Decimal val,Boolean flag){ this.Name = AccName;  this.value = val;  this.contraFlag = flag; this.Container = new ERP7__Transaction__c(); this.Container.ERP7__Amount__c = val.setscale(2);  this.NContainer = new ERP7__Transaction__c(); this.NContainer.ERP7__Amount__c = 0-val.setscale(2);  }
        public AccountGroup(String AccName,Map<String,Map<Integer,decimal>> val,Boolean flag){
            this.Name = AccName;  this.FywiseValues = val; this.contraFlag = flag;
            for(String FWV : val.keyset() ){   Map<integer,Decimal> AV=new Map<integer, Decimal>(this.FywiseValues.get(FWV));   Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                for(Integer aVal : AV.keyset() ){ ERP7__Transaction__c trans=new ERP7__Transaction__c();trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));   setAV.put(aVal,trans);  }
                this.GContainerFyWValues.put(FWV,setAV);
            }
            this.Container = new ERP7__Transaction__c(); this.NContainer = new ERP7__Transaction__c();
            
            if(IsmultiCurrencyEnabled){ }
        }
    }
    public List<Data> datalist { get; set ;}
    public void getdata(){
        try{
            /*Colorset=String.join(colors,',');
            datalist = new List<data>();
            Map<String,decimal> tempMap;
            FyYear ='';
            yfields = '';
            ChartTitle = 'Balance Sheet Accounts';
            tempMap = new Map<String,decimal>();
            for(AccountGroup temp:compareBalanceSheetMap.values()){
                tempMap = new Map<String,decimal>();
                for(String s :temp.FywiseValues.keyset()){
                    Map<Integer,Decimal> valMap = new Map<Integer,Decimal>(temp.FywiseValues.get(s));
                    Decimal TotalValue = 0.00;
                    for(Decimal d:valMap.values())TotalValue +=d;
                    tempMap.put(s,TotalValue);
                }
                CurrentChartofAccounts.put('Total '+temp.Name,tempMap);
                if(temp.SubAccountList != null && temp.SubAccountList.size()>0)
                for(AccountGroup stemp:temp.SubAccountList){
                    Map<String,decimal> tempMap1 = new Map<String,decimal>();
                    for(String s :stemp.FywiseValues.keyset()){
                        Map<Integer,Decimal> valMap = new Map<Integer,Decimal>(stemp.FywiseValues.get(s));
                        Decimal TotalValue = 0.00;
                        for(Decimal d:valMap.values())TotalValue +=d;
                        tempMap1.put(s,TotalValue);
                    }
                    CurrentChartofAccounts.put(stemp.Name,tempMap1);
                }
            }
            
            Map<String,decimal> temp_Map;
            for(String s:CurrentChartofAccounts.keyset()){
                temp_Map = CurrentChartofAccounts.get(s);
                List<Decimal> valueList = temp_Map.values();
                INteger k = 0 ;
                if(valueList.size()==4) datalist.add(new Data(s,valueList[k],valueList[k+1],valueList[k+2],valueList[k+3]));
                else if(valueList.size()==3) datalist.add(new Data(s,valueList[k],valueList[k+1],valueList[k+2]));
                else if(valueList.size()==2)  datalist.add(new Data(s,valueList[k],valueList[k+1]));
                else
                datalist.add(new Data(s,valueList[k]));
                
            }  
            List<String> keyList = new List<String>();
            for(integer x =1;x<=temp_Map.keyset().size();x++){
                keyList.add('data'+x);
                
            }  
            FyYear=String.join(keyList,',');
            yfields = String.join(new List<String>(temp_Map.keyset()),',');
            
            
            for(AccountGroup AG: compareBalanceSheetMap.values()){
                for(String s:AG.FywiseValues.keyset()){
                    Map<integer,Decimal> AV=new Map<integer, Decimal>(AG.FywiseValues.get(s));
                    Map<integer,ERP7__Transaction__c> setAV=new Map<integer,ERP7__Transaction__c>();
                    for(Integer aVal : AV.keyset() ){
                        ERP7__Transaction__c trans=new ERP7__Transaction__c();
                        trans.ERP7__Amount__c=(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                        if(multiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                        setAV.put(aVal,trans);
                    }
                    AG.GContainerFyWValues.put(s,setAV);
                }
                for(AccountGroup AGS: AG.SubAccountList){
                    for(String s : AGS.FywiseValues.keyset()){
                        Map<integer,Decimal> AVS = new Map<integer, Decimal>(AGS.FywiseValues.get(s));
                        Map<integer,ERP7__Transaction__c> setAVS=new Map<integer,ERP7__Transaction__c>();
                        for(Integer aVal : AVS.keyset() ){
                            ERP7__Transaction__c trans=new ERP7__Transaction__c();
                            trans.ERP7__Amount__c=(AVS.get(aVal) >= 0 )? AVS.get(aVal) : (0-AVS.get(aVal));
                            if(multiCurrencyEnabled && isoCode!='' && isoCode!=null) trans.put('CurrencyIsoCode',isoCode);
                            setAVS.put(aVal,trans);
                        }
                        AGS.GContainerFyWValues.put(s,setAVS);
                    }
                    
                }
            }*/
            
            return ; }catch(Exception e){   ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));     return ;
        } 
    }
    public class Data {
        public String name { get; set; }
        public Decimal data1 { get; set; } public Decimal data2 { get; set; }  public Decimal data3 { get; set; } public Decimal data4 { get; set; }  public Data(String name, Decimal data1, Decimal data2, Decimal data3,Decimal data4) {  this.name = name; this.data1  = data1; this.data2 = data2; this.data3 = data3;  this.data4 = data4; }public Data(String name, Decimal data1, Decimal data2, Decimal data3) { this.name = name;  this.data1  = data1;  this.data2 = data2;  this.data3 = data3;  }public Data(String name, Decimal data1, Decimal data2) {  this.name = name; this.data1  = data1; this.data2 = data2; }
        public Data(String name, Decimal data1) {
            this.name = name;
            this.data1  = data1;
        }
    }
    public Date getEdate(){
        return Date.parse(endDate);
    }
    public String getCurrencyISO(){  
        if(multiCurrencyEnabled){  String isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');  return isoCode;  }
        return UserInfo.getDefaultCurrency();
    }
    public PageReference CallCompute(){ 
        try{
            YearorQuarter='Fyear';
            return computeData();  }catch(Exception e){  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber()));    return null; }       
    }
     public pageReference assignOrgId(){ 
          Select_Organisation.ERP7__Organisation__c = newOrganisationId;
      return null;
      }
    
    
  public Decimal convert(Decimal value, String fromIso, String toIso) {
        if (String.isEmpty(fromIso) || String.isEmpty(toIso)) {     return value; }
        Map<String, string> con=new Map<String, string>(); 
      return null;
    }
    
    
}