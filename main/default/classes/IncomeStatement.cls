public with sharing class IncomeStatement {
    
    public Map<String,AccountGroup> FinancialYearWiseAccountMap                       { get; set; }public String userISO                                                   {get;set;}
    public ERP7__Transaction__c Select_Organisation                                         { get; set; }
    public String endDate                                                             { get; set; }
    public Date EDate                                                             { get; set; }
    public string startDate                                                           { get; set; }
    public String minDate                                                             { get; set; }
    public String max_Date                                                            { get; set; }
    public Map<Id,ERP7__Chart_of_Accounts__c> chart_Of_Accounts;
    public ERP7__Chart_of_Accounts__c Net_Profit                                            { get; set; }
    public ERP7__Chart_of_Accounts__c Total_Revenue                                         { get; set; } 
    public ERP7__Chart_of_Accounts__c Total_Expense                                         { get; set; }
    public Map<String,string> displayaccsMap                                          { get; set; }
    public Map<String,Map<String,Map<Integer,decimal>>> FinancialAccountIncomeStmt    { get; set; }
    public Map<String,Map<String,Map<Integer,ERP7__Transaction__c>>> FinancialAccountIncomeStmt2   { get; set; }
    public Map<String,Map<String,Map<Integer,decimal>>> FinancialAccountExpenseStmt   { get; set; }
    public Map<String,Map<String,Map<Integer,decimal>>> FinancialCOGSExpenseStmt      { get; set; }
    public Map<String,Map<Integer,decimal>> TotalIncomeStmt                           { get; set; }
    public Map<String,Map<Integer,decimal>> TotalExpenseStmt                          { get; set; }
    public Map<String,Map<Integer,decimal>> TotalCOGSStmt                             { get; set; }
    public Map<String,Map<Integer,decimal>> TotalNetProfitStmt                        { get; set; }
    public Map<String,Map<String,Map<Integer,ERP7__Transaction__c>>> FinancialAccountExpenseStmt2   { get; set; }
    public Map<String,Map<String,Map<Integer,ERP7__Transaction__c>>> FinancialCOGSExpenseStmt2      { get; set; }
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalIncomeStmt2                           { get; set; }
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalExpenseStmt2                          { get; set; }
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalCOGSStmt2                             { get; set; }
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalNetProfitStmt2                        { get; set; }
    public String newOrganisationId                                                   { get; set; }
    public string yfields                                                             { get; set; }
    public Map<String,Map<String,decimal>> CurrentChartofAccounts                     { get; set; }
    public String SelectedFy                                                          { get; set; } public  Map<String,Integer> FinancialYears                                        { get; set; }
    public string startfy                                                             { get; set; }
    public string endfy                                                               { get; set; }
    public Boolean  showChart                                                         { get; set; }
    public String FyYear                                                              { get; set; }
    public String Colorset                                                            { get; set; }public set<String> DataType                                                       { get; set; }
    public Boolean ShowFyWise                                                         { get; set; }
    public Boolean ShowMonthly                                                        { get; set; }
    public Boolean ShowQuartely                                                       { get; set; }
    public List<String> FYNames                                                       { get; set; }
    public String ChartTitle                                                          { get; set; } public List<string> Colors;public Map<string,boolean> IncomeStatementAccounts                                { get; set; }
    public Map<String,String> FiscalYearQuarter                                       { get; set; }
    public String YearorQuarter                                                       { get; set; }
    public Map<Integer,String> IntegerToMonthName                                     { get; set; }
    public Map<Integer,String> IntegerToQuarterName                                   { get; set; } public Map<String,String> YearToString                                            { get; set; }
    public Boolean multiCurrencyEnabled             {get;set;}public String isoCode                          { get; set; } public Integer mon; public Decimal  conversionRate                                            {get;set;}
    public Decimal  totalIncome                                            {get;set;}
    public Decimal  totalExpense                                           {get;set;}
    public checkMultiCurrency checkCurrency                                   {get;set;}
    public List < AggregateResult > incomeList {get;set;}
    public List < AggregateResult > ExpenseList {get;set;}
    public Integer year                            {get;set;}
    public IncomeStatement() {
        incomeList = new List < AggregateResult >();
        ExpenseList = new List < AggregateResult >();
        totalIncome = totalExpense = 0.00;
        year = 2024;
        multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); 
        if(multiCurrencyEnabled){ checkCurrency=new checkMultiCurrency();String selectedIso = apexpages.currentpage().getparameters().get('CurrencyIso');isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');String iso  = selectedIso;String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso';checkCurrency.conversionRate= (Decimal) Database.Query(q)[0].get('conversionRate'); checkCurrency.userISO = selectedIso;
        }
        else{
            String selectedIso = apexpages.currentpage().getparameters().get('CurrencyIso');
            checkCurrency=new checkMultiCurrency();
            checkCurrency.conversionRate= 1; 
            checkCurrency.userISO = selectedIso;
        }
        FYNames = new List<String>();
        FinancialYearWiseAccountMap = new Map < String, AccountGroup > ();
        FinancialYearWiseAccountMap.put('Income_Revenue', new AccountGroup());
        FinancialYearWiseAccountMap.put('Expense', new AccountGroup());
        
        CurrentChartofAccounts = new Map < String, Map < String, decimal >> ();
        Select_Organisation = new ERP7__Transaction__c();
        Total_Revenue = new ERP7__Chart_of_Accounts__c();
        Total_Expense = new ERP7__Chart_of_Accounts__c();
        buildConditions();
        SelectedFy = '1';
        Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id =: Userinfo.getOrganizationId()].FiscalYearStartMonth;
        List < Period > FiscalPeriod = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Year'
                                        AND StartDate <= TODAY AND EndDate >= TODAY
                                       ];
        mon = FiscalYearStartMonth;
        String StartDate = apexpages.currentpage().getparameters().get('StartDate');
        String EndDate = apexpages.currentpage().getparameters().get('EndDate');
        Startfy = StartDate;
        endfy = EndDate;
        system.debug('StartDate-->'+StartDate);
        system.debug('EndDate-->'+EndDate);
        Date mydate = system.today().adddays(-365);
        date end_Date = system.today();
        if(StartDate!=null) mydate = Date.valueOf(StartDate);
        if(EndDate!=null) end_Date = Date.valueOf(EndDate);
        EDate = end_Date;
        system.debug('mydate-->'+mydate);
        minDate = mydate.format();
        startDate = mydate.format();
        system.debug('startDate-->'+startDate);
        endDate = end_Date.format();
        max_Date = end_Date.format();
        YearorQuarter = 'Fyear';
        showChart = false;
        ShowFyWise = true;
        ShowMonthly = false;
        ShowQuartely = false;
        FyYear = 'data1,data2,data3';
        displayaccsMap = new Map < String, String > ();
        displayaccsMap.put('Income_Revenue', 'Operating Income');
        displayaccsMap.put('Expense', 'Operating Expenses');
        displayaccsMap.put('Sales', 'Net Sales');
        BuildMOnthMap(FiscalYearStartMonth);
        IntegerToQuarterName = new Map < Integer, String > ();
        IntegerToQuarterName.put(1, 'Q-1');
        IntegerToQuarterName.put(2, 'Q-2');
        IntegerToQuarterName.put(3, 'Q-3');
        IntegerToQuarterName.put(4, 'Q-4');
        /* List < Account > DefaultOrgList = [Select Id, Name FROM Account where Account_Type__c = 'Organisation'
and Default__c = true limit 1
];

if (DefaultOrgList != null && DefaultOrgList.size() > 0) {
Select_Organisation.Organisation__c = DefaultOrgList[DefaultOrgList.size() - 1].id;
*/
        Account Organisation = ERP7.UtilClass.getOrganisationByLogin_Employee();
        
        
        if(Organisation.Id != null ){
            Select_Organisation.ERP7__Organisation__c = Organisation.id;
            showChart = false;
            colors = new List < String > {
                '#FF0000',
                    '#6A5ACD',
                    '#00b200',
                    '#0000FF',
                    '#00BFFF',
                    '#D2691E',
                    '#8A2BE2',
                    '#778899',
                    '#CAFF70',
                    '#7FFFD4',
                    '#0000A0'
                    };
                        system.debug('calling ComputeSelectedFyData');
            //ComputeSelectedFyData();
            ComputeData();
            if(multiCurrencyEnabled){ Net_Profit = new ERP7__Chart_of_Accounts__c();Total_Revenue = new ERP7__Chart_of_Accounts__c();Total_Expense = new ERP7__Chart_of_Accounts__c();Net_Profit.put('CurrencyIsoCode',isoCode); Total_Revenue.put('CurrencyIsoCode',isoCode); Total_Expense.put('CurrencyIsoCode',isoCode);
            }
        }
    }
    
    public void BuildMOnthMap(Integer m) {
        IntegerToMonthName = new Map < Integer, String > ();
        List < String > MonthNames = new List < String > {
            'JAN',
                'FEB',
                'MAR',
                'APR',
                'MAY',
                'JUN',
                'JUL',
                'AUG',
                'SEP',
                'OCT',
                'NOV',
                'DEC',
                'JAN',
                'FEB',
                'MAR',
                'APR',
                'MAY',
                'JUN',
                'JUL',
                'AUG',
                'SEP',
                'OCT',
                'NOV',
                'DEC',
                'JAN',
                'FEB',
                'MAR'
                };
                    for (Integer i = 0; i <= 11; i++)
                    IntegerToMonthName.put(i + 1, MonthNames[(i - 1) + m]);
    }
    
    public void buildConditions() {
        FiscalYearQuarter = new Map < String, String > ();
        FiscalYearQuarter.put('1', '= THIS_FISCAL_YEAR');
        FiscalYearQuarter.put('2', '>= LAST_FISCAL_YEAR AND General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        FiscalYearQuarter.put('3', '>= LAST_N_FISCAL_YEARS:2 AND General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        FiscalYearQuarter.put('4', '= THIS_FISCAL_QUARTER');
        FiscalYearQuarter.put('5', '= NEXT_FISCAL_QUARTER OR General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        FiscalYearQuarter.put('6', '= NEXT_FISCAL_QUARTER');
        FiscalYearQuarter.put('7', '= LAST_FISCAL_QUARTER OR General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        
    }
    
    public pagereference Downloadpdf() {
        PageReference incomeStmtpdf = Page.ERP7__IncomeStatementAsPDF;
        incomeStmtpdf.setRedirect(false);
        return incomeStmtpdf;
    }
    
    public void CheckQuartelyYearlyMon() {
        //ComputeData();
    }
    
    public PageReference ComputeSelectedFyData() {
        try{
            system.debug('ComputeSelectedFyData called');
            system.debug('Select_Organisation.Organisation__c ' + Select_Organisation.ERP7__Organisation__c);
            Total_Revenue = new ERP7__Chart_of_Accounts__c();
            Total_Expense = new ERP7__Chart_of_Accounts__c();
            Net_Profit = new ERP7__Chart_of_Accounts__c();
            String isoCode = '';
            if(Schema.getGlobalDescribe().containsKey('CurrencyType')){ isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
            FinancialYearWiseAccountMap = new Map < String, AccountGroup > ();
            FinancialYearWiseAccountMap.put('Income_Revenue', new AccountGroup());
            FinancialYearWiseAccountMap.put('Expense', new AccountGroup());
            
            chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c > ([SELECT Name, RecordTypeId, ERP7__isContra_Account__c,
                                                                             ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where RecordType.DeveloperName in ('Income_Revenue', 'Expense')
                                                                            ]); 
            if ((chart_Of_Accounts.size() == 0 || chart_Of_Accounts == null)) {  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: No Chart of Accounts found.'); ApexPages.addMessage(myMsg);return null;
            }
            String qryFilter = '';
            if (Select_Organisation.ERP7__Organisation__c != null) qryFilter += ' AND ERP7__Organisation__c = \'' + Select_Organisation.ERP7__Organisation__c + '\' ';
            if (Select_Organisation.ERP7__Customer__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Customer__c = \'' + Select_Organisation.ERP7__Customer__c + '\' ';
            if (Select_Organisation.ERP7__Product__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Product__c = \'' + Select_Organisation.ERP7__Product__c + '\' ';
            if (Select_Organisation.ERP7__Sales_Order__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Sales_Order__c = \'' + Select_Organisation.ERP7__Sales_Order__c + '\' ';
            
            if (Select_Organisation.ERP7__Project__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Project__c = \'' +Select_Organisation.ERP7__Project__c + '\' ';
            if (Select_Organisation.ERP7__Supplier__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Supplier__c = \'' + Select_Organisation.ERP7__Supplier__c + '\' ';
            if (Select_Organisation.ERP7__Employee__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Employee__c = \'' + Select_Organisation.ERP7__Employee__c + '\' ';
            if (Select_Organisation.ERP7__Site__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Site__c = \'' + Select_Organisation.ERP7__Site__c + '\' ';
            if (Select_Organisation.ERP7__Channel__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Channel__c = \'' + Select_Organisation.ERP7__Channel__c + '\' ';
            if (Select_Organisation.ERP7__Industry__c != null && Select_Organisation.ERP7__Industry__c != '' && Select_Organisation.ERP7__Industry__c != '--None--') qryFilter += ' AND ERP7__Transactions__r.ERP7__Industry__c = \'' + Select_Organisation.ERP7__Industry__c + '\' ';
            
            /*'qryFilter ' + qryFilter);*/
            String StartDate = apexpages.currentpage().getparameters().get('StartDate');
            String EndDate = apexpages.currentpage().getparameters().get('EndDate');
            system.debug('StartDate -->'+StartDate);
            system.debug('EndDate -->'+EndDate);
            Date start_date = Date.valueOf(StartDate);
            Date end_Date = Date.valueOf(EndDate);
            
            string stat = 'Open';
            String Query = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c coa, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name coaName ' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Income_Revenue\',\' \') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
                ' GROUP BY   ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c';
            
            incomeList = Database.query(Query);
            for(AggregateResult agg : incomeList){ system.debug('totalIncome-->'+totalIncome); totalIncome = totalIncome + double.valueOf(agg.get('Credit')) - double.valueOf(agg.get('Debit'));
            }
            String EQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c coa, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name coaName' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\' \',\'Expense\') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
                ' GROUP BY ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c order by ERP7__Chart_of_Account__r.Name';
            
            ExpenseList = Database.query(EQuery);
            for(AggregateResult agg : ExpenseList){totalExpense = totalExpense + double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));
            }
            return null; }catch(Exception e){system.debug('Exception--->'+e+'Line Number-->'+e.getLineNumber());return null;
        }
    }
    
    public class checkMultiCurrency{
        public Boolean ismultiCurrency  {get;set;} 
        public String  userISO          {get;set;}  public String  isoCode          {get;set;}
        public double  conversionRate   {get;set;}
        public checkMultiCurrency(){
            ismultiCurrency = false;
            conversionRate  = 0.00;
        }
    }
    
    public PageReference ComputeData() {
        system.debug('ComputeData called');
        Date Sfy = Date.parse(minDate);
        if (SelectedFy.equalsIgnoreCase('2') || SelectedFy.equalsIgnoreCase('3'))
        sfy = sfy.addYears(1 - Integer.valueof(SelectedFy));
        startfy = sfy.format();
        endfy = max_date;
        TotalIncomeStmt = new Map < String, Map < Integer, decimal >> ();
        TotalExpenseStmt = new Map < String, Map < Integer, decimal >> ();
        TotalCOGSStmt = new Map < String, Map < Integer, decimal >> ();
        TotalNetProfitStmt = new Map < String, Map < Integer, decimal >> ();
        FinancialAccountIncomeStmt = new Map < String, Map < String, Map < Integer, decimal >>> (); 
        FinancialCOGSExpenseStmt = new Map < String, Map < String, Map < Integer, decimal >>> ();
        FinancialAccountExpenseStmt = new Map < String, Map < String, Map < Integer, decimal >>> ();
        
        FinancialAccountIncomeStmt2 = new Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>> ();
        TotalIncomeStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
        TotalExpenseStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
        TotalCOGSStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
        TotalNetProfitStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
        FinancialCOGSExpenseStmt2 = new Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>> ();
        FinancialAccountExpenseStmt2 = new Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>> ();
        
        
        String StartDate = apexpages.currentpage().getparameters().get('StartDate');
        String EndDate = apexpages.currentpage().getparameters().get('EndDate');
        String view = '';
        view = apexpages.currentpage().getparameters().get('view');
        SelectedFy = apexpages.currentpage().getparameters().get('sFY');
        system.debug('StartDate-->'+StartDate);
        system.debug('EndDate-->'+EndDate);
        /*Date start_date = Date.valueOf(StartDate);
date end_date = Date.valueOf(EndDate);*/
        Date start_date = system.today().adddays(-60);
        date end_Date = system.today();
        if(StartDate != null) start_date = Date.valueOf(StartDate);
        if(EndDate != null) end_Date = Date.valueOf(EndDate);
        
        
        String DbQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit,' +
            'ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,' +
            ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount,CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly' +
            ' FROM ERP7__Finance_General_Ledger_Entry__c where ERP7__Active__c = true AND ' +
            ' DAY_ONLY(ERP7__General_Ledger_Entry_DateTime__c) >=: start_date AND DAY_ONLY(ERP7__General_Ledger_Entry_DateTime__c) <=: end_date AND '+
            ' ERP7__Organisation__c =\'' + String.escapeSingleQuotes(Select_Organisation.ERP7__Organisation__c) + '\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Income_Revenue\',\'Expense\')' +
            ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC ';// limit 5000
        
        String CoaQuery = 'SELECT ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,' +
            ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly' +
            ' FROM ERP7__Finance_General_Ledger_Entry__c where ERP7__Active__c = true AND ' +
            ' DAY_ONLY(ERP7__General_Ledger_Entry_DateTime__c) >=: start_date AND DAY_ONLY(ERP7__General_Ledger_Entry_DateTime__c) <=: end_date AND '+
            ' ERP7__Organisation__c =\'' + String.escapeSingleQuotes(Select_Organisation.ERP7__Organisation__c) + '\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Income_Revenue\',\'Expense\')' +
            ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC ';// limit 5000
        
        List < AggregateResult > BalanceSheetData = Database.query(DbQuery);
        /*BalanceSheetData);*/
        List < AggregateResult > COAList = Database.query(CoaQuery);
        Map < integer, Decimal > TempList = new Map < integer, Decimal > ();
        Map < String, Map < Integer, decimal >> TempYear = new Map < String, Map < Integer, decimal >> ();
        
        if (YearorQuarter.containsIgnoreCase('Month') || (view!=null && view=='Monthly')) {
            showMonthly = true;
            showFywise = false;
            ShowQuartely = false;
            YearorQuarter = 'FMonthly';
        } else if ((YearorQuarter.containsIgnoreCase('Quarter') || FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter')) || (view!=null && view=='Quaterly') ){
            showMonthly = false;
            showFywise = false;
            ShowQuartely = true;
            YearorQuarter = 'FQuarter';
        } else {
            showMonthly = false;
            showFywise = true;
            ShowQuartely = false;
            YearorQuarter = 'Fyear';
            
        }
        Map < Integer, decimal > quarterMap = new Map < Integer, decimal > ();
        Integer NoQ_M;
        if (!FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter') && (SelectedFy.containsAny('123'))) {
            NoQ_M = (YearorQuarter.containsIgnoreCase('Month')) ? 12 : ((YearorQuarter.containsIgnoreCase('Quarter')) ? 4 : 1);
                // Integer YLen =(FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter'))? 1 : Integer.valueOf(SelectedFy);
                Integer Ylen = Integer.valueOf(SelectedFy);
            TempYear = new Map < String, Map < Integer, Decimal >> ();
            
            for (Integer j = 0; j < YLen; j++) {
                Map < Integer, Decimal > TList = new Map < Integer, Decimal > ();
                Map < Integer, Decimal > TotalList = new Map < Integer, Decimal > ();
                if (YearorQuarter.containsIgnoreCase('Year')) {
                    TotalList.put(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j, 0.00);
                    Tlist.put(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j, 0.00);
                    TempYear.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TList));
                    TotalIncomeStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), TotalList);
                    TotalExpenseStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                    TotalCOGSStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                    TotalNetProfitStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                } else if ((YearorQuarter.containsIgnoreCase('Month') || YearorQuarter.containsIgnoreCase('Quarter'))) {
                    for (integer i = 1; i < NoQ_M + 1; i++) {
                        TempList.put(i, 0.00);
                        TotalList.put(i, 0.00);
                    }
                    TempYear.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), TempList);
                    TotalIncomeStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), TotalList);
                    TotalExpenseStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                    TotalCOGSStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                    TotalNetProfitStmt.put(String.valueOf(((mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                }
                
            }
            
        } else {
            for (AggregateResult coa: COAList) {
                quarterMap = new Map < Integer, decimal > ();
                if (TempYear.get(String.valueOf(coa.get('Fyear'))) != null)
                    quarterMap = TempYear.get(String.valueOf(coa.get('Fyear')));
                quarterMap.put(Integer.valueOf(coa.get('FQuarter')), 0.00);
                TempYear.put(String.valueOf(coa.get('Fyear')), quarterMap);
                TotalIncomeStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));
                TotalExpenseStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));
                TotalCOGSStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));
                TotalNetProfitStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));
            }
            
            
        }
        
        for (AggregateResult coa: COAList) {
            Map < String, Map < Integer, Decimal >> TempY = new Map < String, Map < Integer, Decimal >> ();
            
            for (String s: TempYear.keyset()) {
                Map < Integer, Decimal > innerMap = new Map < Integer, Decimal > ();
                
                innerMap = TempYear.get(s);
                TempY.put(s, new Map < Integer, Decimal > (innerMap));
            }
            
            
            if (String.valueOf(Coa.get('AccountGroup')) == 'Income_Revenue'){
                FinancialAccountIncomeStmt.put(String.valueOf(Coa.get('AccountName')), new Map < String, Map < Integer, Decimal >> (TempY));
            }
            else {
                if (String.valueOf(Coa.get('SubAccountGroup')) != null)
                    FinancialCOGSExpenseStmt.put(String.valueOf(Coa.get('AccountName')), new Map < String, Map < Integer, Decimal >> (TempY));
                else
                    FinancialAccountExpenseStmt.put(String.valueOf(Coa.get('AccountName')), new Map < String, Map < Integer, Decimal >> (TempY));
                
            }
        }
        
        
        for (AggregateResult bsd: BalanceSheetData) {
            system.debug('bsd-->'+bsd);
            Decimal TotalIncome = 0.00;
            Decimal creditSum = 0.0;
            Decimal debitsum = 0.0;
            Decimal ClosingBalance = 0.0;
            if (bsd.get('Credit') != null) creditSum = double.valueOf(bsd.get('Credit'));
            if (bsd.get('Debit') != null) debitsum = double.valueOf(bsd.get('Debit'));
            if ((Boolean) bsd.get('ContraAccount')) {
                ClosingBalance = (debitsum - creditSum);
                //ClosingBalance = -ClosingBalance;
            } else {
                ClosingBalance = (creditSum - debitsum);
                
            }
            system.debug('called==>'+FinancialAccountIncomeStmt);
            YearorQuarter = (FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter')) ? 'FQuarter' : YearorQuarter;
            if (String.valueOf(bsd.get('AccountGroup')) == 'Income_Revenue') {
                /*'called==>'+FinancialAccountIncomeStmt);*/
                if (FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName'))) != null && FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName'))).get(String.valueOf(bsd.get('Fyear'))) != null && FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName'))).get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(YearorQuarter))) != null) {
                    
                    Map < String, Map < Integer, decimal >> AccountMap = FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName')));
                    Map < Integer, decimal > QuarterlyMap = AccountMap.get(String.valueOf(bsd.get('Fyear')));
                    Map < Integer, decimal > TotalMap = TotalIncomeStmt.get(String.valueOf(bsd.get('Fyear')));
                    Decimal total = QuarterlyMap.get(Integer.valueof(bsd.get(YearorQuarter)));
                    Decimal RowTotal = TotalMap.get(Integer.valueof(bsd.get(YearorQuarter)));
                    if ((Boolean) bsd.get('ContraAccount')) {
                        QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)), total - ClosingBalance);
                        TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)), RowTotal - ClosingBalance);
                    } else {
                        QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)), total + ClosingBalance);
                        TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)), RowTotal + ClosingBalance);
                    }
                    AccountMap.put(String.valueOf(bsd.get('Fyear')), QuarterlyMap);
                    TotalIncomeStmt.put(String.valueOf(bsd.get('Fyear')), TotalMap);
                }
            } else {
                if (FinancialAccountExpenseStmt != null && bsd.get('SubAccountGroup') != null && String.valueOf(bsd.get('SubAccountGroup')) == null && FinancialAccountExpenseStmt.get(String.valueOf(bsd.get('AccountName'))) != null && FinancialAccountExpenseStmt.get(String.valueOf(bsd.get('AccountName'))).get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(YearorQuarter))) != null) {
                    Map < String, Map < Integer, decimal >> AccountMap = FinancialAccountExpenseStmt.get(String.valueOf(bsd.get('AccountName')));    Map < Integer, decimal > QuarterlyMap = AccountMap.get(String.valueOf(bsd.get('Fyear')));  Map < Integer, decimal > TotalMap = TotalExpenseStmt.get(String.valueOf(bsd.get('Fyear')));   Decimal total = QuarterlyMap.get(Integer.valueof(bsd.get(YearorQuarter)));    Decimal RowTotal = TotalMap.get(Integer.valueof(bsd.get(YearorQuarter)));
                    //QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)),total+ClosingBalance);
                    //TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)),RowTotal+ClosingBalance);
                    if ((Boolean) bsd.get('ContraAccount')) {
                        QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)), total - ClosingBalance);  TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)), RowTotal - ClosingBalance);
                    } else {
                        QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)), total + ClosingBalance);  TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)), RowTotal + ClosingBalance);
                    }
                    AccountMap.put(String.valueOf(bsd.get('Fyear')), QuarterlyMap);  TotalExpenseStmt.put(String.valueOf(bsd.get('Fyear')), TotalMap);  FinancialAccountExpenseStmt.put(String.valueOf(bsd.get('AccountName')), AccountMap);
                } else {
                    Map < String, Map < Integer, decimal >> AccountMap = FinancialCOGSExpenseStmt.get(String.valueOf(bsd.get('AccountName')));
                    if (AccountMap != null) {
                        Map < Integer, decimal > QuarterlyMap = AccountMap.get(String.valueOf(bsd.get('Fyear')));   Map < Integer, decimal > TotalMap = TotalCOGSStmt.get(String.valueOf(bsd.get('Fyear')));
                        if (QuarterlyMap != null) {
                            Decimal total = QuarterlyMap.get(Integer.valueof(bsd.get(YearorQuarter)));
                            Decimal RowTotal = TotalMap.get(Integer.valueof(bsd.get(YearorQuarter)));
                            //QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)),total+ClosingBalance);
                            //TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)),RowTotal+ClosingBalance);
                            if ((Boolean) bsd.get('ContraAccount')) { 
                                QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)), total - ClosingBalance);
                                TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)), RowTotal - ClosingBalance);
                            } else {
                                QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)), total + ClosingBalance);
                                TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)), RowTotal + ClosingBalance);
                            }
                            AccountMap.put(String.valueOf(bsd.get('Fyear')), QuarterlyMap);
                            TotalCOGSStmt.put(String.valueOf(bsd.get('Fyear')), TotalMap);
                            FinancialCOGSExpenseStmt.put(String.valueOf(bsd.get('AccountName')), AccountMap);
                        }
                    }
                }
            }
        }
        
        for (String s: TotalIncomeStmt.keyset()) {
            Map < Integer, decimal > NettempMap = new Map < Integer, decimal > ();
            for (Integer i: TotalIncomeStmt.get(s).keyset()) {
                NettempMap.put(i, TotalIncomeStmt.get(s).get(i) - (TotalExpenseStmt.get(s).get(i) - TotalCOGSStmt.get(s).get(i)));
                TotalNetProfitStmt.put(s, NettempMap);
            }
        }
        
        // Transaaction for currency display
        for(String M1 : FinancialAccountIncomeStmt.keyset()){
            Map<String, Map<Integer, ERP7__Transaction__c>> M22 = new Map<String, Map<Integer, ERP7__Transaction__c>>();
            for(String M2 : FinancialAccountIncomeStmt.get(M1).keyset()){
                Map<Integer, ERP7__Transaction__c> M33 = new Map<Integer, ERP7__Transaction__c>();
                for(Integer M3 : FinancialAccountIncomeStmt.get(M1).get(M2).keyset()){
                    ERP7__Transaction__c tran = new ERP7__Transaction__c();
                    tran.ERP7__Amount__c = FinancialAccountIncomeStmt.get(M1).get(M2).get(M3);
                    if(multiCurrencyEnabled) tran.put('CurrencyIsoCode',isoCode);
                    if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;
                    M33.put(M3, tran);
                }
                M22.put(M2, M33);
            }
            FinancialAccountIncomeStmt2.put(M1, M22);
        }
        system.debug('*** FinancialAccountIncomeStmt2 ==> '+FinancialAccountIncomeStmt2);
        
        
        for(String M1 : FinancialAccountExpenseStmt.keyset()){
            Map<String, Map<Integer, ERP7__Transaction__c>> M22 = new Map<String, Map<Integer, ERP7__Transaction__c>>();
            for(String M2 : FinancialAccountExpenseStmt.get(M1).keyset()){
                Map<Integer, ERP7__Transaction__c> M33 = new Map<Integer, ERP7__Transaction__c>();
                for(Integer M3 : FinancialAccountExpenseStmt.get(M1).get(M2).keyset()){
                    ERP7__Transaction__c tran = new ERP7__Transaction__c();
                    tran.ERP7__Amount__c = FinancialAccountExpenseStmt.get(M1).get(M2).get(M3);
                    if(multiCurrencyEnabled) tran.put('CurrencyIsoCode',isoCode);
                    if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;
                    M33.put(M3, tran);
                }
                M22.put(M2, M33);
            }
            FinancialAccountExpenseStmt2.put(M1, M22);
        }
        system.debug('*** FinancialAccountExpenseStmt2 ==> '+FinancialAccountExpenseStmt2);
        
        for(String M1 : FinancialCOGSExpenseStmt.keyset()){
            Map<String, Map<Integer, ERP7__Transaction__c>> M22 = new Map<String, Map<Integer, ERP7__Transaction__c>>();
            for(String M2 : FinancialCOGSExpenseStmt.get(M1).keyset()){
                Map<Integer, ERP7__Transaction__c> M33 = new Map<Integer, ERP7__Transaction__c>();
                for(Integer M3 : FinancialCOGSExpenseStmt.get(M1).get(M2).keyset()){
                    ERP7__Transaction__c tran = new ERP7__Transaction__c();
                    tran.ERP7__Amount__c = FinancialCOGSExpenseStmt.get(M1).get(M2).get(M3);
                    if(multiCurrencyEnabled) tran.put('CurrencyIsoCode',isoCode);
                    if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;
                    M33.put(M3, tran);
                }
                M22.put(M2, M33);
            }
            FinancialCOGSExpenseStmt2.put(M1, M22);
        }
        system.debug('*** FinancialCOGSExpenseStmt2 ==> '+FinancialCOGSExpenseStmt2);
        
        for(String M1 : TotalIncomeStmt.keyset()){
            Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
            for(Integer M2 : TotalIncomeStmt.get(M1).keyset()){
                ERP7__Transaction__c tran = new ERP7__Transaction__c();
                tran.ERP7__Amount__c = TotalIncomeStmt.get(M1).get(M2);
                if(multiCurrencyEnabled) tran.put('CurrencyIsoCode',isoCode);
                if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;
                M22.put(M2, tran);
            }
            TotalIncomeStmt2.put(M1, M22);
        }
        system.debug('*** TotalIncomeStmt2 ==> '+TotalIncomeStmt2);
        
        for(String M1 : TotalExpenseStmt.keyset()){
            Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
            for(Integer M2 : TotalExpenseStmt.get(M1).keyset()){
                ERP7__Transaction__c tran = new ERP7__Transaction__c();
                tran.ERP7__Amount__c = TotalExpenseStmt.get(M1).get(M2);
                if(multiCurrencyEnabled) tran.put('CurrencyIsoCode',isoCode);
                if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;
                M22.put(M2, tran);
            }
            TotalExpenseStmt2.put(M1, M22);
        }
        system.debug('TotalExpenseStmt2 ==> '+TotalExpenseStmt2);
        
        for(String M1 : TotalCOGSStmt.keyset()){
            Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
            for(Integer M2 : TotalCOGSStmt.get(M1).keyset()){
                ERP7__Transaction__c tran = new ERP7__Transaction__c();
                tran.ERP7__Amount__c = TotalCOGSStmt.get(M1).get(M2);
                if(multiCurrencyEnabled) tran.put('CurrencyIsoCode',isoCode);
                if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;
                M22.put(M2, tran);
            }
            TotalCOGSStmt2.put(M1, M22);
        }
        system.debug('TotalCOGSStmt2 ==> '+TotalCOGSStmt2);
        
        for(String M1 : TotalNetProfitStmt.keyset()){
            Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
            for(Integer M2 : TotalNetProfitStmt.get(M1).keyset()){
                ERP7__Transaction__c tran = new ERP7__Transaction__c();
                tran.ERP7__Amount__c = TotalNetProfitStmt.get(M1).get(M2);
                if(multiCurrencyEnabled) tran.put('CurrencyIsoCode',isoCode);
                if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;
                M22.put(M2, tran);
            }
            TotalNetProfitStmt2.put(M1, M22);
        }
        system.debug('*** TotalNetProfitStmt2 ==> '+TotalNetProfitStmt2);
        
        /*
public Map<String,Map<String,Map<Integer,decimal>>> FinancialAccountExpenseStmt   { get; set; }
public Map<String,Map<String,Map<Integer,decimal>>> FinancialCOGSExpenseStmt      { get; set; }
public Map<String,Map<Integer,decimal>> TotalIncomeStmt                           { get; set; }
public Map<String,Map<Integer,decimal>> TotalExpenseStmt                          { get; set; }
public Map<String,Map<Integer,decimal>> TotalCOGSStmt                             { get; set; }
public Map<String,Map<Integer,decimal>> TotalNetProfitStmt                        { get; set; }
*/
        return null;
    }
    
    public List < Data > getdata() {
        showchart = true;
        CurrentChartofAccounts = new Map < String, Map < String, decimal >> ();
        List < Data > datalist = new List < data > ();
        Colorset = String.join(colors, ',');
        Map < String, decimal > tempMap;
        integer m = 1;
        FyYear = '';
        if (SelectedFy.containsAny('14567')) {
            ChartTitle = (YearorQuarter.containsIgnoreCase('Month')) ? 'FISCAL MONTH' : (YearorQuarter.containsIgnoreCase('Quarter')) ? 'FISCAL QUARTERS' : 'FISCAL YEAR';
            for (String s: TotalIncomeStmt.keyset()) {
                List < Integer > keyList = new List < Integer > (TotalIncomeStmt.get(s).keyset());
                for (Integer i = 0; i < keyList.size(); i++) {
                    String str;
                    if (YearorQuarter.containsIgnoreCase('Quarter'))
                        str = IntegerToQuarterName.get(keyList[i]);
                    else if (YearorQuarter.containsIgnoreCase('Month')) str = IntegerToMonthName.get(keyList[i]);
                    else
                        str = String.valueOf(keyList[i]);
                    datalist.add(new Data(str, TotalIncomeStmt.get(s).get(keyList[i]), TotalExpenseStmt.get(s).get(keyList[i]), TotalIncomeStmt.get(s).get(keyList[i]) - (TotalExpenseStmt.get(s).get(keyList[i]) + TotalCOGSStmt.get(s).get(keyList[i]))));
                }
            }
            yfields = 'Total Income,Total Expense,Net Profit';
            FyYear = 'data1,data2,data3';
        } else if (YearorQuarter.containsIgnoreCase('Quarter')) {
            FyYear = '';
            yfields = '';
            ChartTitle = 'Net Profit / Loss';
            tempMap = new Map < String, decimal > ();
            Map < String, decimal > ExpensetempMap = new Map < String, decimal > ();
            Map < String, decimal > NettempMap = new Map < String, decimal > ();
            List < String > Year_List = new List < String > (TotalIncomeStmt.keyset());
            Integer j = 0;
            for (Integer i: IntegerToQuarterName.keyset()) {
                String str = (YearorQuarter.containsIgnoreCase('Quarter')) ? IntegerToQuarterName.get(i) : String.valueOf(i);
                if (Year_List.size() == 2) {
                    datalist.add(new Data(str, TotalIncomeStmt.get(Year_List[j]).get(i) - (TotalExpenseStmt.get(Year_List[j]).get(i) + TotalCOGSStmt.get(Year_List[j]).get(i)), TotalIncomeStmt.get(Year_List[j + 1]).get(i) - (TotalExpenseStmt.get(Year_List[j + 1]).get(i) + TotalCOGSStmt.get(Year_List[j + 1]).get(i))));
                    FyYear = 'data1,data2';
                } else if (Year_List.size() == 3) {
                    datalist.add(new Data(str, TotalIncomeStmt.get(Year_List[j]).get(i) - (TotalExpenseStmt.get(Year_List[j]).get(i) + TotalCOGSStmt.get(Year_List[j]).get(i)), TotalIncomeStmt.get(Year_List[j + 1]).get(i) - (TotalExpenseStmt.get(Year_List[j + 1]).get(i) + TotalCOGSStmt.get(Year_List[j + 1]).get(i)), TotalIncomeStmt.get(Year_List[j + 2]).get(i) - (TotalExpenseStmt.get(Year_List[j + 2]).get(i) + TotalCOGSStmt.get(Year_List[j + 2]).get(i))));
                    FyYear = 'data1,data2,data3';
                }
            }
            
            yfields = String.join(new List < String > (TotalIncomeStmt.keyset()), ',');
            
        } else {
            FyYear = '';
            yfields = '';
            ChartTitle = 'Profit / Loss';
            tempMap = new Map < String, decimal > ();
            Map < String, decimal > ExpensetempMap = new Map < String, decimal > ();
            Map < String, decimal > NettempMap = new Map < String, decimal > ();
            for (String s: TotalIncomeStmt.keyset()) {
                for (Integer i: TotalIncomeStmt.get(s).keyset()) {
                    String str = (YearorQuarter.containsIgnoreCase('Quarter')) ? IntegerToQuarterName.get(i) : String.valueOf(i);
                    tempMap.put(str, TotalIncomeStmt.get(s).get(i));
                    CurrentChartofAccounts.put('Total Income', tempMap);
                    ExpensetempMap.put(str, TotalExpenseStmt.get(s).get(i));
                    CurrentChartofAccounts.put('Total Expense', ExpensetempMap);
                    NettempMap.put(str, TotalIncomeStmt.get(s).get(i) - (TotalExpenseStmt.get(s).get(i) + TotalCOGSStmt.get(s).get(i)));
                    CurrentChartofAccounts.put('Net Profit', NettempMap);
                }
            }
            Map < String, decimal > temp_Map;
            for (String s: CurrentChartofAccounts.keyset()) {
                temp_Map = CurrentChartofAccounts.get(s);
                List < Decimal > valueList = temp_Map.values();
                INteger k = 0;
                if (valueList.size() == 4) datalist.add(new Data(s, valueList[k], valueList[k + 1], valueList[k + 2], valueList[k + 3]));
                else if (valueList.size() == 3) datalist.add(new Data(s, valueList[k], valueList[k + 1], valueList[k + 2]));
                else if (valueList.size() == 2) datalist.add(new Data(s, valueList[k], valueList[k + 1]));
                else
                    datalist.add(new Data(s, valueList[k]));
                
            }
            List < String > keyList = new List < String > ();
            for (integer x = 1; x <= temp_Map.keyset().size(); x++) {
                keyList.add('data' + x);
                
            }
            FyYear = String.join(keyList, ',');
            yfields = String.join(new List < String > (temp_Map.keyset()), ',');
        }
        return datalist;
    }
    
    public List < SelectOption > getFinancialYearList() {
        
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('None', 'Fiscal year', true));
        options.add(new SelectOption('1', 'Current FY'));
        options.add(new SelectOption('2', 'Current and Previous FY'));
        options.add(new SelectOption('3', 'Current and Previous 2 FY'));
        options.add(new SelectOption('None', 'Fiscal Quarter', true));
        options.add(new SelectOption('4', 'Current FQ'));
        options.add(new SelectOption('5', 'Current and Next FQ'));
        options.add(new SelectOption('6', 'Next FQ'));
        options.add(new SelectOption('7', 'Current and Previous FQ'));
        return options;
        
    }
    
    /*Wrapper datatype*/
    public class AccountGroup {
        public String Name { get; set; }
        public Decimal Value { get; set; }
        public List < AccountGroup > SubAccountList { get; set; }
        public Boolean contraFlag { get; set; }
        public ERP7__Transaction__c Container              {get;set;}
        public ERP7__Transaction__c NContainer             {get;set;}
        public Boolean IsmultiCurrencyEnabled             {get;set;}
        public String isoCode                          { get; set; }
        
        /*Instance Intialization Block*/
        public AccountGroup() {
            Name = '';
            value = 0.00;
            SubAccountList = new List < AccountGroup > ();
            contraFlag = false;
            this.Container = new ERP7__Transaction__c();
            this.Container.ERP7__Amount__c = 0.00;
            this.NContainer = new ERP7__Transaction__c();
            this.NContainer.ERP7__Amount__c = 0.00;
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){
                //isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode'); this.Container.put('CurrencyIsoCode',isoCode);  this.NContainer.put('CurrencyIsoCode',isoCode);
            }
        }
        public AccountGroup(String AccName, Decimal val, List < AccountGroup > subAcclist, String isoCode) {
            this.Name = AccName;  this.value = val; this.SubAccountList = subAcclist;  this.Container = new ERP7__Transaction__c();  this.Container.ERP7__Amount__c = val.setscale(2);  this.NContainer = new ERP7__Transaction__c();  this.NContainer.ERP7__Amount__c = 0-val.setscale(2);
            
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){ this.Container.put('CurrencyIsoCode',isoCode); this.NContainer.put('CurrencyIsoCode',isoCode);
                                      }
            
            for(AccountGroup AG : this.SubAccountList){ AG.Container.ERP7__Amount__c = AG.Value.setscale(2); AG.NContainer.ERP7__Amount__c = 0-AG.Value.setscale(2);
                                                      }
        }
        public AccountGroup(String AccName, Decimal val, Boolean flag, String isoCode) {
            this.Name = AccName; this.value = val; this.contraFlag = flag; this.Container = new ERP7__Transaction__c(); this.Container.ERP7__Amount__c = val.setscale(2);  this.NContainer = new ERP7__Transaction__c();  this.NContainer.ERP7__Amount__c = 0-val.setscale(2);
            
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){ this.Container.put('CurrencyIsoCode',isoCode); this.NContainer.put('CurrencyIsoCode',isoCode);
                                      }
        }
    }
    
    public class Data {
        public String name { get; set; }
        public Decimal data1 { get; set; }
        public Decimal data2 { get; set; }
        public Decimal data3 { get; set; }
        public Decimal data4 { get; set; }
        public Data(String name, Decimal data1, Decimal data2, Decimal data3, Decimal data4) { this.name = name; this.data1 = data1; this.data2 = data2;  this.data3 = data3;  this.data4 = data4; }
        public Data(String name, Decimal data1, Decimal data2, Decimal data3) { this.name = name; this.data1 = data1; this.data2 = data2; this.data3 = data3; }
        public Data(String name, Decimal data1, Decimal data2) { this.name = name; this.data1 = data1; this.data2 = data2; }
        public Data(String name, Decimal data1) { this.name = name; this.data1 = data1; }
    }
    
    public PageReference CallCompute() { YearorQuarter = 'Fyear'; return computeData(); }
    
    public Date getEdate() { return null; }
    
    public String getCurrencyISO() { return UserInfo.getDefaultCurrency(); }
    
    public pageReference refreshTab() { YearorQuarter = 'Fyear'; return computeData(); }
    
    public pagereference DownloadComparisonpdf() {
        PageReference IncomeStmtCompare = Page.ERP7__ComparisonIncomeStatement;
        IncomeStmtCompare.setRedirect(false);
        return IncomeStmtCompare;
    }
    
    public pageReference assignOrgId() {
        /*'newOrganisationId ' + newOrganisationId);*/
        Select_Organisation.ERP7__Organisation__c = newOrganisationId;
        ComputeSelectedFyData();
        return null;
    } 
}