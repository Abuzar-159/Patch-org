public With Sharing class BalanceSheetLightning {
    @AuraEnabled  
    public List<String> monthNames                                                   { get; set; }
    @AuraEnabled 
    public List<String> quarterNames                                                 { get; set; }
    @AuraEnabled 
    public List<W3> Wrapper                                                          { get; set; }
    @AuraEnabled
    Public String       CurrencyISO                                                   { get; set; }
    @AuraEnabled
    public List<Selectoptions> getPickList                                            { get; set; }
    @AuraEnabled
    public Map<String,Integer> FinancialYears                                         { get; set; }
    @AuraEnabled
    public Map<String,AccountGroup> FinancialYearWiseAssetMap                         { get; set; }
    @AuraEnabled
    public List<AccountGroup> FYAsset                                                 { get; set; }
    @AuraEnabled
    public List<AccountGroup> FYLiability                                             { get; set; }
    @AuraEnabled
    public List<AccountGroup> FYEquity                                                  { get; set; }
    @AuraEnabled
    public Map<String,AccountGroup> compareBalanceSheetMap                            { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,decimal>> CompareFyWiseExpenseMap                   { get; set; }
    @AuraEnabled
    public map<String,Decimal> FyWiseExpenseMap                                       { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,decimal>> CompareFyWiseIncomeMap                    { get; set; }
    @AuraEnabled
    public map<String,Decimal> FyWiseIncomeMap                                        { get; set; }
    @AuraEnabled
    public Map<String,map<String,decimal>> chartmap                                   { get; set; } 
    @AuraEnabled
    public string yfields                                                             { get; set; }
    @AuraEnabled
    public Map<String,Map<String,Decimal>> CurrentChartofAccounts                     { get; set; } 
    @AuraEnabled  
    public ERP7__Accounting_Period__c CurrentFy                                       { get; set; }
    @AuraEnabled
    public String SelectedFy                                                          { get; set; } 
    @AuraEnabled 
    public String newOrganisationId                                                   { get; set; }
    @AuraEnabled
    public String SelectedFy_BS                                                       { get; set; }
    @AuraEnabled
    public Account Select_Organisation                                                { get; set; }
    @AuraEnabled
    public String endDate                                                             { get; set; }
    @AuraEnabled
    public string startDate                                                           { get; set; }
    @AuraEnabled
    public Date sDate                                                             { get; set; }
    @AuraEnabled
    public Date eDate                                                           { get; set; }
    @AuraEnabled
    public string startfy                                                             { get; set; }
    @AuraEnabled
    public string endfy                                                               { get; set; }
    @AuraEnabled
    public String minDate                                                             { get; set; }
    @AuraEnabled
    public String max_Date                                                            { get; set; }
    @AuraEnabled
    public Boolean  showChart                                                         { get; set; }
    @AuraEnabled
    public String FyYear                                                              { get; set; }
    @AuraEnabled
    public String Colorset                                                            { get; set; }
    @AuraEnabled
    public String YearorQuarter                                                       { get; set; }
    @AuraEnabled
    public List<string> Colors                                                        { get; set; }
    @AuraEnabled
    public Boolean ShowFyWise                                                         { get; set; }
    @AuraEnabled
    public Boolean ShowQuartely                                                       { get; set; }
    @AuraEnabled
    public Boolean showMonthly                                                        { get; set; }
    @AuraEnabled
    public List<String> FYNames                                                       { get; set; }
    @AuraEnabled
    public String ChartTitle                                                          { get; set; }
    @AuraEnabled
    public Boolean showBalancesheet                                                   { get; set; }
    @AuraEnabled
    public ERP7__Chart_of_Accounts__c Total_Assets                                    { get; set; }
    @AuraEnabled
    public ERP7__Chart_of_Accounts__c Total_Liab_Equity                               { get; set; }
    @AuraEnabled
    public Map<string,boolean> balanceSheetAccounts                                   { get; set; }
    @AuraEnabled
    public Map<String,String> FiscalYearQuarter                                       { get; set; }
    @AuraEnabled
    public Map<String,String> FiscalYear                                              { get; set; }
    @AuraEnabled
    public Map<Integer,String> IntegerToMonthName                                     { get; set; }
    @AuraEnabled
    public Map<Integer,String> IntegerToQuarterName                                   { get; set; }
    @AuraEnabled
    public String RE_COA                                                              { get; set; }
    @AuraEnabled
    Public List<Period> FiscalPeriod                                                  { get; set; }
    @AuraEnabled
    public Boolean multiCurrencyEnabled                                               {get;  set; }
    @AuraEnabled
    public String isoCode                                                             { get; set; }
    @AuraEnabled
    public String userIsoCode                                                         { get; set; }
    @AuraEnabled
    public Integer mon                                                                { get; set; } 
    @AuraEnabled   
    public String errMsg                                                              { get; set; } 
    @AuraEnabled
    public Decimal currencyRate                                                       { get; set; }  
    @AuraEnabled  
    public Decimal Conversion                                                         {get; set; }
     
    @AuraEnabled
    public static BalanceSheetLightning fecthDetails(String Ins, String selectedIso) {
        BalanceSheetLightning BSD = new BalanceSheetLightning();
        if (Ins != null && Ins != 'null') {
            BSD = (BalanceSheetLightning) JSON.deserialize(Ins, BalanceSheetLightning.class);
        }
        BSD.multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if (BSD.multiCurrencyEnabled) {
            String COA_Currency = (String) Database.Query('select CurrencyIsoCode from ERP7__Chart_of_Accounts__c ')[0].get('CurrencyIsoCode');
            String q1 = 'SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: COA_Currency';
            BSD.Conversion = (Decimal) Database.Query(q1)[0].get('conversionRate');
            //BSD.
            /*'COA_Currency'+COA_Currency*/
    
            /*'BSD.Conversion'+BSD.Conversion*/
        }
    
        // =[];
        // BalanceSheetLightning BSD;
        //if(ins !=null && ins != 'null' )BSD = (BalanceSheetLightning) JSON.deserialize(ins, BalanceSheetLightning.class);
        //else BSD = new BalanceSheetLightning(); 
        try {
            BSD.multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            /*'multiCurrencyEnabled : '+multiCurrencyEnabled*/
            if (multiCurrencyEnabled) {
                BSD.isoCode = (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
    
            if (selectedIso != null) BSD.CurrencyISO = selectedIso;
            else BSD.CurrencyISO = UserInfo.getDefaultCurrency();
            if (BSD.multiCurrencyEnabled) {
                BSD.userIsoCode = BSD.CurrencyISO;
                String iso = BSD.userIsoCode;
                String q = 'SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso';
                BSD.currencyRate = (Decimal) Database.Query(q)[0].get('conversionRate');
            } else {
                BSD.userIsoCode = BSD.CurrencyISO;
                BSD.currencyRate = 1;
            }
    
            BSD.FinancialYearWiseAssetMap = new Map < String, AccountGroup > ();
            BSD.compareBalanceSheetMap = new Map < String, AccountGroup > ();
            BSD.CompareFyWiseExpenseMap = new Map < String, Map < Integer, decimal >> ();
            BSD.CompareFyWiseIncomeMap = new Map < String, Map < Integer, decimal >> ();
            BSD.FyWiseIncomeMap = new Map < String, Decimal > ();
            BSD.FyWiseExpenseMap = new Map < String, Decimal > ();
            BSD.CurrentChartofAccounts = new Map < String, Map < String, decimal >> ();
            BSD.chartmap = new Map < String, map < String, decimal >> ();
            BSD.FinancialYears = new Map < String, Integer > ();
            if (Ins == null || Ins == 'null' || Ins == '') BSD.Select_Organisation = new Account();
            BSD.Total_Assets = new ERP7__Chart_of_Accounts__c();
            BSD.Total_Liab_Equity = new ERP7__Chart_of_Accounts__c();
            BSD = buildConditions(BSD);
            /*'BSD returned from buildConditions : '+BSD*/
            BSD.FiscalPeriod = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Year'
                AND StartDate <= TODAY AND EndDate >= TODAY Order by StartDate desc
            ];
            /*' BSD.FiscalPeriod  : '+BSD.FiscalPeriod */
            BSD.mon = BSD.FiscalPeriod[0].StartDate.Month();
            BSD = BuildMOnthMap(BSD);
            BSD.YearorQuarter = 'Fyear';
            Date mydate = BSD.sDate == null ? BSD.FiscalPeriod[0].StartDate : BSD.sDate;
            date end_Date = BSD.eDate == null ? BSD.FiscalPeriod[0].EndDate : BSD.eDate;
            if (BSD.eDate == null) BSD.eDate = system.today();
            if (BSD.sDate == null) BSD.sDate = system.today().adddays(-30); //BSD.FiscalPeriod[0].StartDate.adddays(180);
            BSD.minDate = mydate.format();
            BSD.StartDate = mydate.format();
            BSD.endDate = end_Date.format();
            BSD.max_Date = end_Date.format();
            BSD.IntegerToQuarterName = new Map < Integer, String > ();
            BSD.IntegerToQuarterName.put(1, 'Q-1');
            BSD.IntegerToQuarterName.put(2, 'Q-2');
            BSD.IntegerToQuarterName.put(3, 'Q-3');
            BSD.IntegerToQuarterName.put(4, 'Q-4');
            BSD.quarterNames = new List < String > ();
            BSD.quarterNames.add('Q-1');
            BSD.quarterNames.add('Q-2');
            BSD.quarterNames.add('Q-3');
            BSD.quarterNames.add('Q-4');
            BSD.balanceSheetAccounts = new Map < string, boolean > ();
            BSD.balanceSheetAccounts.put('Assets', false); // Asset
            BSD.balanceSheetAccounts.put('Equity', false); // Equity
            BSD.balanceSheetAccounts.put('Liability', false); // Liability
            BSD.SelectedFy = BSD.SelectedFy == Null ? '1' : BSD.SelectedFy;
            BSD.SelectedFy_BS = BSD.SelectedFy_BS == null ? '1' : BSD.SelectedFy_BS;
            BSD.showChart = true;
            BSD.ShowFyWise = true;
            BSD.ShowQuartely = false;
            BSD.showMonthly = false;
            BSD.showBalancesheet = false;
            BSD.FYNames = new List < String > ();
            Account Organisation = ERP7.UtilClass.getOrganisationByLogin_Employee();
            if (Organisation.Id != null) {
                if (Ins == null || Ins == 'null' || Ins == '') BSD.Select_Organisation.ERP7__Organisation__c = Organisation.id;
                BSD.RE_COA = getRE_AccountName(BSD.Select_Organisation.ERP7__Organisation__c);
                BSD.colors = new List < String > {
                    '#FF0000',
                    '#6A5ACD',
                    '#00FF00',
                    '#0000FF',
                    '#00BFFF',
                    '#D2691E',
                    '#8A2BE2',
                    '#778899',
                    '#CAFF70',
                    '#7FFFD4',
                    '#0000A0'
                };
                    system.debug('calling ComputeSelectedFyData from fetchDetails');
                BSD = ComputeSelectedFyData(BSD);
                // BSD = ComputeData(BSD);
                if (BSD.multiCurrencyEnabled) {
                    BSD.Total_Assets.put('CurrencyIsoCode', BSD.isoCode);
                    BSD.Total_Liab_Equity.put('CurrencyIsoCode', BSD.isoCode);
                }
            }
            BSD.FYAsset = new List < AccountGroup > ();
            BSD.FYLiability = new List < AccountGroup > ();
            BSD.FYEquity = new List < AccountGroup > ();
            BSD.FYAsset.add(BSD.FinancialYearWiseAssetMap.get('Assets'));
            BSD.FYLiability.add(BSD.FinancialYearWiseAssetMap.get('Liability'));
            BSD.FYEquity.add(BSD.FinancialYearWiseAssetMap.get('Equity'));
            BSD.getPickList = new List < selectOptions > ();
            // BSD.getPickList.add(new selectOptions('None','Fiscal year',true));
            BSD.getPickList.add(new selectOptions('Current FY', '1'));
            BSD.getPickList.add(new selectOptions('Current and Previous FY', '2'));
            BSD.getPickList.add(new selectOptions('Current and Previous 2 FY', '3'));
            BSD.getPickList.add(new selectOptions('Fiscal Quarter', 'Fiscal Quarter', true));
            BSD.getPickList.add(new selectOptions('Current FQ', '4'));
            BSD.getPickList.add(new selectOptions('Current and Next FQ', '5'));
            BSD.getPickList.add(new selectOptions('Next FQ', '6'));
            BSD.getPickList.add(new selectOptions('Current and Previous FQ', '7'));
            // return BSD;
        } catch (Exception e) {
            BSD.errMsg = String.valueOf(e.getMessage()) + String.valueOf(e.getLineNumber());
        }
        return BSD;
    }
    
    @AuraEnabled
    public static List < selectOptions > getCurrencies() {
        List < selectOptions > options = new List < selectOptions > ();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if (IsmultiCurrencyEnabled) {
            List < sObject > currencies = Database.Query('SELECT IsoCode FROM CurrencyType');
            for (sObject a: currencies) {
                options.add(new SelectOptions(String.valueof(a.get('IsoCode')), String.valueof(a.get('IsoCode'))));
            }
        }
        return options;
    }
    
    @AuraEnabled
    public static BalanceSheetLightning ComputeData(String B) {
        BalanceSheetLightning BSDInstance = (BalanceSheetLightning) JSON.deserialize(B, BalanceSheetLightning.class);
        try {
            //system.debug('instance-->' + BSDInstance.sDate);
            system.debug('instance-->' + BSDInstance.eDate);
            BSDInstance.Wrapper = new List < W3 > ();
            Boolean IsmultiCurrencyEnabled;
            String isoCode;
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if (IsmultiCurrencyEnabled) {
                isoCode = (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
            // For converting to other currency
            Decimal conversionRate = 1;
            if (IsmultiCurrencyEnabled) {
                String iso = UserInfo.getDefaultCurrency();
                String q = 'SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso';
                conversionRate = (Decimal) Database.Query(q)[0].get('conversionRate');
            }
            // End of converting to other currency  
    
    
            Date Sfy = Date.parse(BSDInstance.minDate);
            if (BSDInstance.SelectedFy.equalsIgnoreCase('2') || BSDInstance.SelectedFy.equalsIgnoreCase('3'))
                sfy = sfy.addYears(1 - Integer.valueof(BSDInstance.SelectedFy));
            BSDInstance.startfy = sfy.format();
            BSDInstance.endfy = BSDInstance.max_date;
            BSDInstance.compareBalanceSheetMap = new Map < String, AccountGroup > ();
            Map < Id, ERP7__Chart_of_Accounts__c > chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c > ([SELECT Name, RecordTypeId, ERP7__isContra_Account__c,
                ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where ERP7__Active__c = true
            ]);
            if ((chart_Of_Accounts.size() == 0 || chart_Of_Accounts == null) && BSDInstance.showBalancesheet) {
                BSDInstance.showBalancesheet = false;
                BSDInstance.errMsg = 'Error: No Chart of Accounts, found For selected Organisation.';
                return null;
            }
            Date start_date = Date.valueOf(BSDInstance.sDate);
            date end_date = Date.valueOf(BSDInstance.eDate);
            system.debug('end_date-->' + end_date);
            String DbQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit,' +
                'ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,' +
                ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount,CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c where ' +
                ' DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                //' (ERP7__General_Ledger_Entry_DateTime__c '+BSDInstance.FiscalYearQuarter.get(BSDInstance.SelectedFy)+') AND '+ 
                ' ERP7__Organisation__c =\'' + BSDInstance.Select_Organisation.ERP7__Organisation__c + '\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Assets\',\'Liability\',\'Equity\',\'Income_Revenue\',\'Expense\')' +
                ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC limit 2000';
    
            String CoaQuery = 'SELECT ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,' +
                ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c where ' +
                ' ERP7__Organisation__c =\'' + BSDInstance.Select_Organisation.ERP7__Organisation__c + '\' AND (ERP7__General_Ledger_Entry_DateTime__c ' + BSDInstance.FiscalYearQuarter.get(BSDInstance.SelectedFy) + ') AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Assets\',\'Liability\',\'Equity\',\'Income_Revenue\',\'Expense\')' +
                ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c,ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC  limit 2000';
    
            List < AggregateResult > BalanceSheetData = Database.query(DbQuery);
            List < AggregateResult > COAList = Database.query(CoaQuery);
            Map < String, Map < Integer, decimal >> TempYear = new Map < String, Map < Integer, decimal >> ();
            Map < Integer, decimal > quarterMap = new Map < Integer, decimal > ();
            Map < Integer, Decimal > TotalList = new Map < Integer, Decimal > ();
            if (BSDInstance.YearorQuarter.containsIgnoreCase('Month')) {
                BSDInstance.showMonthly = true;
                BSDInstance.showFywise = false;
                BSDInstance.ShowQuartely = false;
            } else if (BSDInstance.YearorQuarter.containsIgnoreCase('Quarter') || BSDInstance.FiscalYearQuarter.get(BSDInstance.SelectedFy).containsIgnoreCase('Quarter')) {
                BSDInstance.showMonthly = false;
                BSDInstance.showFywise = false;
                BSDInstance.ShowQuartely = true;
            } else {
                BSDInstance.showMonthly = false;
                BSDInstance.showFywise = true;
                BSDInstance.ShowQuartely = false;
            }
            Integer NoQ_M;
            if (!BSDInstance.FiscalYearQuarter.get(BSDInstance.SelectedFy).containsIgnoreCase('Quarter') && (BSDInstance.SelectedFy.containsAny('123'))) {
                NoQ_M = (BSDInstance.YearorQuarter.containsIgnoreCase('Month')) ? 12 : (BSDInstance.YearorQuarter.containsIgnoreCase('Quarter')) ? 4 : 1;
                Integer Ylen = Integer.valueOf(BSDInstance.SelectedFy);
                TempYear = new Map < String, Map < Integer, Decimal >> ();
    
                for (Integer j = 0; j < YLen; j++) {
                    TotalList = new Map < Integer, Decimal > ();
                    if (BSDInstance.YearorQuarter.containsIgnoreCase('Year') && (BSDInstance.SelectedFy.containsAny('123'))) {
                        TotalList.put(((BSDInstance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j, 0.00);
                    } else if ((BSDInstance.YearorQuarter.containsIgnoreCase('Month') || BSDInstance.YearorQuarter.containsIgnoreCase('Quarter')) && (BSDInstance.SelectedFy.containsAny('123'))) {
                        for (integer i = 1; i < NoQ_M + 1; i++) {
                            TotalList.put(i, 0.00);
                        }
                    }
                    TempYear.put(String.valueOf(((BSDInstance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), TotalList);
                    BSDInstance.CompareFyWiseExpenseMap.put(String.valueOf(((BSDInstance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                    BSDInstance.CompareFyWiseIncomeMap.put(String.valueOf(((BSDInstance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                }
    
            } else {
                for (AggregateResult coa: COAList) {
                    quarterMap = new Map < Integer, decimal > ();
                    if (TempYear.get(String.valueOf(coa.get('Fyear'))) != null) quarterMap = TempYear.get(String.valueOf(coa.get('Fyear')));
                    quarterMap.put(Integer.valueOf(coa.get('FQuarter')), 0.00);
                    TempYear.put(String.valueOf(coa.get('Fyear')), quarterMap);
                }
            }
            Map < String, Map < Integer, Decimal >> AcctValYear = new Map < String, Map < Integer, Decimal >> ();
            Map < String, Map < Integer, Decimal >> ParentGroupYear = new Map < String, Map < Integer, Decimal >> ();
            Map < String, Map < Integer, Decimal >> SubGroupYear = new Map < String, Map < Integer, Decimal >> ();
    
            Decimal openingBal = 0.0;
            Decimal creditSum = 0.0;
            Decimal debitsum = 0.0;
            Decimal ClosingBalance = 0.0;
            Decimal TotalIncome = 0.00;
            Decimal TotalExpense = 0.00;
    
            AccountGroup AccountNameValue = new AccountGroup();
            AccountGroup ParentAccount = new AccountGroup();
            List < AccountGroup > AccountNameValueList = new List < AccountGroup > ();
            List < AccountGroup > subAccsList = new List < AccountGroup > ();
    
            Map < integer, Decimal > AV = new Map < integer, Decimal > ();
            Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
            ERP7__Transaction__c trans = new ERP7__Transaction__c();
    
            Map < String, Map < Integer, Decimal >> RetainedEarnings = new Map < String, Map < Integer, Decimal >> ();
            Map < String, Map < Integer, Decimal >> parentEarnings = new Map < String, Map < Integer, Decimal >> ();
    
    
            for (AggregateResult bsd: BalanceSheetData) {
                AcctValYear = new Map < String, Map < Integer, Decimal >> ();
                ParentGroupYear = new Map < String, Map < Integer, Decimal >> ();
                SubGroupYear = new Map < String, Map < Integer, Decimal >> ();
    
                for (String ss: TempYear.keyset()) {
                    AcctValYear.put(ss, new Map < Integer, Decimal > (TempYear.get(ss)));
                    SubGroupYear.put(ss, new Map < Integer, Decimal > (TempYear.get(ss)));
                    ParentGroupYear.put(ss, new Map < Integer, Decimal > (TempYear.get(ss)));
                }
                openingBal = (chart_Of_Accounts.get((ID) bsd.get('AccountId')) != null) ? chart_Of_Accounts.get((ID) bsd.get('AccountId')).ERP7__Opening_Balance__c : 0.00;
                //openingBal = 0.0;
                creditSum = 0.0;
                debitsum = 0.0;
                ClosingBalance = 0.0;
                TotalIncome = 0.00;
                TotalExpense = 0.00;
                AccountNameValue = new AccountGroup();
                if (IsmultiCurrencyEnabled) {
                    AccountNameValue.Container.put('CurrencyIsoCode', isoCode);
                    AccountNameValue.NContainer.put('CurrencyIsoCode', isoCode);
                }
                ParentAccount = new AccountGroup();
                if (IsmultiCurrencyEnabled) {
                    ParentAccount.Container.put('CurrencyIsoCode', isoCode);
                    ParentAccount.NContainer.put('CurrencyIsoCode', isoCode);
                }
                AccountNameValueList = new List < AccountGroup > ();
                subAccsList = new List < AccountGroup > ();
                BSDInstance.YearorQuarter = (BSDInstance.FiscalYearQuarter.get(BSDInstance.SelectedFy).containsIgnoreCase('Quarter')) ? 'FQuarter' : BSDInstance.YearorQuarter;
                // if(bsd.get('Credit') != null) creditSum = double.valueOf(bsd.get('Credit'));
                // if(bsd.get('Debit') != null) debitsum = double.valueOf(bsd.get('Debit'));
    
                // For mulitiplication of currencies
                if (bsd.get('Credit') != null) {
                    if (IsmultiCurrencyEnabled) {
                        if (isoCode != UserInfo.getDefaultCurrency()) {
                            creditSum = double.valueOf(bsd.get('Credit')) * double.valueOf(conversionRate);
                        } else creditSum = double.valueOf(bsd.get('Credit'));
                    } else {
                        creditSum = double.valueOf(bsd.get('Credit'));
                    }
                }
                if (bsd.get('Debit') != null) {
                    if (IsmultiCurrencyEnabled) {
                        if (isoCode != UserInfo.getDefaultCurrency()) {
                            debitsum = double.valueOf(bsd.get('Debit')) * double.valueOf(conversionRate);
                        } else debitsum = double.valueOf(bsd.get('Debit'));
                    } else {
                        debitsum = double.valueOf(bsd.get('Debit'));
                    }
                }
                // End of mulitiplication of currencies   
    
                if (bsd.get('AccountGroup') == 'Assets') {
                    if ((Boolean) bsd.get('ContraAccount')) {
                        system.debug('Assets C' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = (openingBal + (creditSum - debitsum));
                        Map < Integer, Decimal > valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                        valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), ClosingBalance);
                        AcctValYear.put(String.valueOf(bsd.get('Fyear')), valueMap);
                        AccountNameValue = AccountGroup4('Less:' + String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), AcctValYear, (Boolean) bsd.get('ContraAccount')); //new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                        if (IsmultiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', isoCode);
                        }
    
                        ClosingBalance = -ClosingBalance;
                    } else {
                        system.debug('Assets' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = (openingBal - (creditSum - debitsum));
                        Map < Integer, Decimal > valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                        valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), ClosingBalance);
                        AcctValYear.put(String.valueOf(bsd.get('Fyear')), valueMap);
                        AccountNameValue = AccountGroup4(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), new Map < String, Map < Integer, Decimal >> (AcctValYear), (Boolean) bsd.get('ContraAccount')); // new AccountGroup(String.valueOf(bsd.get('AccountName')),new Map<String,Map<Integer,Decimal>>(AcctValYear),(Boolean)bsd.get('ContraAccount'));
                        if (IsmultiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', isoCode);
                        }
    
                    }
                } else if (bsd.get('AccountGroup') == 'Liability') {
                    system.debug('Liability ' + String.valueOf(bsd.get('subCategory')));
                    ClosingBalance = (openingBal + (creditSum - debitsum));
                    Map < Integer, Decimal > valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                    valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), ClosingBalance);
                    AcctValYear.put(String.valueOf(bsd.get('Fyear')), valueMap);
                    AccountNameValue = AccountGroup4(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), AcctValYear, (Boolean) bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                    if (IsmultiCurrencyEnabled) {
                        AccountNameValue.Container.put('CurrencyIsoCode', isoCode);
                        AccountNameValue.NContainer.put('CurrencyIsoCode', isoCode);
                    }
                } else if (bsd.get('AccountGroup') == 'Equity') {
                    system.debug('equity ' + String.valueOf(bsd.get('subCategory')));
                    if ((Boolean) bsd.get('ContraAccount')) {
                        ClosingBalance = (openingBal + (creditSum - debitsum));
                        Map < Integer, Decimal > valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                        valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), ClosingBalance);
                        AcctValYear.put(String.valueOf(bsd.get('Fyear')), valueMap);
                        AccountNameValue = AccountGroup4('Less:' + String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), AcctValYear, (Boolean) bsd.get('ContraAccount')); //new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                        if (IsmultiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', isoCode);
                        }
                        ClosingBalance = -ClosingBalance;
                    } else {
                        system.debug('equity e' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = (openingBal + (creditSum - debitsum));
                        Map < Integer, Decimal > valueMap = AcctValYear.get(String.valueOf(bsd.get('Fyear')));
                        valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), ClosingBalance);
                        AcctValYear.put(String.valueOf(bsd.get('Fyear')), valueMap);
                        AccountNameValue = AccountGroup4(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), AcctValYear, (Boolean) bsd.get('ContraAccount')); // new AccountGroup(String.valueOf(bsd.get('AccountName')),AcctValYear,(Boolean)bsd.get('ContraAccount'));
                        if (IsmultiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', isoCode);
                        }
                    }
                } else if (bsd.get('AccountGroup') == 'Income_Revenue') {
                    if ((Boolean) bsd.get('ContraAccount')) {
                        system.debug('Income' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = (openingBal + (creditSum - debitsum));
                        if (BSDInstance.CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear'))) != null) {
                            Map < Integer, Decimal > valueMap = BSDInstance.CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear')));
                            TotalIncome = valueMap.get(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)));
                            TotalIncome += ClosingBalance;
                            valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), TotalIncome);
                            BSDInstance.CompareFyWiseIncomeMap.put(String.valueOf(bsd.get('AccountGroup')), valueMap);
                        }
                    } else {
                        system.debug('Income e' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = (openingBal + (creditSum + debitsum));
                        if (BSDInstance.CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear'))) != null) {
                            Map < Integer, Decimal > valueMap = BSDInstance.CompareFyWiseIncomeMap.get(String.valueOf(bsd.get('Fyear')));
                            TotalIncome = valueMap.get(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)));
                            TotalIncome += ClosingBalance;
                            valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), TotalIncome);
                            BSDInstance.CompareFyWiseIncomeMap.put(String.valueOf(bsd.get('AccountGroup')), valueMap);
                        }
                    }
                } else if (bsd.get('AccountGroup') == 'Expense') {
                    system.debug('Expense' + String.valueOf(bsd.get('subCategory')));
                    ClosingBalance = (openingBal - (creditSum - debitsum));
                    if (BSDInstance.CompareFyWiseExpenseMap.get(String.valueOf(bsd.get('Fyear'))) != null) {
                        Map < Integer, Decimal > valueMap = BSDInstance.CompareFyWiseExpenseMap.get(String.valueOf(bsd.get('Fyear')));
                        TotalIncome = valueMap.get(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)));
                        TotalIncome += ClosingBalance;
                        valueMap.put(Integer.valueOf(bsd.get(BSDInstance.YearorQuarter)), TotalIncome);
                        BSDInstance.CompareFyWiseExpenseMap.put(String.valueOf(bsd.get('AccountGroup')), valueMap);
                    }
                }
                AccountNameValueList = new List < AccountGroup > ();
                AccountNameValueList.add(AccountNameValue);
                Map < Integer, Decimal > SubGrpvalueMap = new Map < Integer, Decimal > (SubGroupYear.get(String.valueof(bsd.get('Fyear'))));
                SubGrpvalueMap.put(Integer.valueof(bsd.get(BSDInstance.YearorQuarter)), ClosingBalance);
                SubGroupYear.put(String.valueof(bsd.get('Fyear')), new Map < Integer, Decimal > (SubGrpvalueMap));
                AccountGroup subAccGrp = AccountGroup2(String.valueOf(bsd.get('SubAccountGroup')), String.valueOf(bsd.get('subCategory')), new Map < String, Map < Integer, Decimal >> (SubGroupYear), AccountNameValueList, IsmultiCurrencyEnabled); // new AccountGroup(String.valueOf(bsd.get('SubAccountGroup')),new Map<String,Map<Integer,Decimal>>(SubGroupYear),AccountNameValueList);
                if (IsmultiCurrencyEnabled) {
                    subAccGrp.Container.put('CurrencyIsoCode', isoCode);
                    subAccGrp.NContainer.put('CurrencyIsoCode', isoCode);
                }
                subAccsList = new List < AccountGroup > ();
                subAccsList.add(subAccGrp);
                Map < Integer, Decimal > parentValueMap = new Map < Integer, Decimal > (ParentGroupYear.get(String.valueof(bsd.get('Fyear'))));
                parentValueMap.put(Integer.valueof(bsd.get(BSDInstance.YearorQuarter)), ClosingBalance);
                ParentGroupYear.put(String.valueof(bsd.get('Fyear')), parentValueMap);
                ParentAccount = AccountGroup2(String.valueOf(bsd.get('AccountGroup')), String.valueOf(bsd.get('subCategory')), new Map < String, Map < Integer, Decimal >> (ParentGroupYear), subAccsList, IsmultiCurrencyEnabled); //new AccountGroup(String.valueOf(bsd.get('AccountGroup')), new Map<String,Map<Integer,Decimal>>(ParentGroupYear),subAccsList);
                if (IsmultiCurrencyEnabled) {
                    ParentAccount.Container.put('CurrencyIsoCode', isoCode);
                    ParentAccount.NContainer.put('CurrencyIsoCode', isoCode);
                }
    
                if (String.valueOf(bsd.get('AccountGroup')) == 'Assets' || String.valueOf(bsd.get('AccountGroup')) == 'Liability' || String.valueOf(bsd.get('AccountGroup')) == 'Equity')
                    if (BSDInstance.compareBalanceSheetMap.get(String.valueOf(bsd.get('AccountGroup'))) == null) {
                        BSDInstance.compareBalanceSheetMap.put(String.valueOf(bsd.get('AccountGroup')), ParentAccount);
                    } else {
                        AccountGroup PAccount = BSDInstance.compareBalanceSheetMap.get(String.valueOf(bsd.get('AccountGroup')));
                        if (IsmultiCurrencyEnabled) {
                            PAccount.Container.put('CurrencyIsoCode', isoCode);
                            PAccount.NContainer.put('CurrencyIsoCode', isoCode);
                        }
    
                        if (PAccount.SubAccountList != null && PAccount.SubAccountList.size() > 0) {
                            Boolean flag = true;
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
                                if (PAccount.SubAccountList[i].Name == String.valueOf(bsd.get('SubAccountGroup'))) {
                                    Boolean sflag = true;
                                    if (PAccount.SubAccountList[i].SubAccountList != null && PAccount.SubAccountList[i].SubAccountList.size() > 0) {
                                        for (Integer j = 0; j < PAccount.SubAccountList[i].SubAccountList.size(); j++) {
                                            if (PAccount.SubAccountList[i].SubAccountList[j].Name == String.valueOf(bsd.get('AccountName'))) {
                                                Decimal currentVal = PAccount.SubAccountList[i].SubAccountList[j].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(BSDInstance.YearOrQuarter)));
                                                currentVal += ClosingBalance;
                                                PAccount.SubAccountList[i].SubAccountList[j].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).put(Integer.valueOf(bsd.get(BSDInstance.YearOrQuarter)), currentVal);
                                                sflag = false;
                                            }
    
                                        }
    
                                    }
                                    if (sflag) {
                                        PAccount.SubAccountList[i].SubAccountList.add(AccountNameValue);
                                    }
                                    Decimal SubcurrentVal = PAccount.SubAccountList[i].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(BSDInstance.YearOrQuarter)));
                                    SubcurrentVal += ClosingBalance;
                                    PAccount.SubAccountList[i].FywiseValues.get(String.valueOf(bsd.get('Fyear'))).put(Integer.valueOf(bsd.get(BSDInstance.YearOrQuarter)), SubcurrentVal);
                                    PAccount.SubAccountList[i].value += ClosingBalance;
                                    flag = false;
                                }
                            }
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
    
                                PAccount.SubAccountList[i].Container.ERP7__Amount__c = PAccount.SubAccountList[i].value;
                                if (IsmultiCurrencyEnabled) PAccount.SubAccountList[i].Container.put('CurrencyIsoCode', isoCode);
                                PAccount.SubAccountList[i].NContainer.ERP7__Amount__c = 0 - PAccount.SubAccountList[i].value;
                                if (IsmultiCurrencyEnabled) PAccount.SubAccountList[i].NContainer.put('CurrencyIsoCode', isoCode);
                            }
                            for (AccountGroup AG: PAccount.SubAccountList) {
                                for (String s: AG.FywiseValues.keyset()) {
                                    AV = new Map < integer, Decimal > (AG.FywiseValues.get(s));
                                    setAV = new Map < integer, ERP7__Transaction__c > ();
                                    for (Integer aVal: AV.keyset()) {
                                        trans = new ERP7__Transaction__c();
                                        trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                                        if (BSDInstance.multiCurrencyEnabled) trans.put('CurrencyIsoCode', isoCode);
                                        setAV.put(aVal, trans);
                                    }
                                    AG.GContainerFyWValues.put(s, setAV);
                                }
                            }
                            if (flag) {
                                PAccount.SubAccountList.add(subAccGrp);
                            }
    
                            Decimal pcurrentVal = PAccount.FywiseValues.get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(BSDInstance.YearOrQuarter)));
                            pcurrentVal += ClosingBalance;
                            PAccount.FywiseValues.get(String.valueOf(bsd.get('Fyear'))).put(Integer.valueOf(bsd.get(BSDInstance.YearOrQuarter)), pcurrentVal);
                        }
                    }
            } /*End of For Loop BSd*/
    
            RetainedEarnings = new Map < String, Map < Integer, Decimal >> ();
            parentEarnings = new Map < String, Map < Integer, Decimal >> ();
            for (String ss: TempYear.keyset()) {
                RetainedEarnings.put(ss, new Map < Integer, Decimal > (TempYear.get(ss)));
                parentEarnings.put(ss, new Map < Integer, Decimal > (TempYear.get(ss)));
            }
            Map < Integer, Decimal > tmap;
            Map < String, Map < Integer, Decimal >> LiabilityAndEquity = new Map < String, Map < Integer, Decimal >> ();
            Map < Integer, Decimal > t_map;
            /* Adding Laibility And Equity */
            for (String str: TempYear.keyset()) {
                t_map = new Map < Integer, Decimal > ();
                for (Integer i: TempYear.get(str).keyset()) {
                    Decimal Eval = (BSDInstance.compareBalanceSheetMap.get('Liability') != null) ? BSDInstance.compareBalanceSheetMap.get('Liability').FywiseValues.get(str).get(i) : 0.00;
                    Decimal Lval = (BSDInstance.compareBalanceSheetMap.get('Equity') != null) ? BSDInstance.compareBalanceSheetMap.get('Equity').FywiseValues.get(str).get(i) : 0.00;
                    t_map.put(i, (Lval + Eval));
                }
                LiabilityAndEquity.put(Str, t_map);
            }
    
            AccountGroup Parent_Account = AccountGroup2('Liabilty And Equity', 'Liabilty And Equity', new Map < String, Map < Integer, Decimal >> (LiabilityAndEquity), new List < AccountGroup > (), BSDInstance.multiCurrencyEnabled); //new AccountGroup('Liabilty And Equity', new Map<String,Map<Integer,Decimal>>(LiabilityAndEquity),new List<AccountGroup>());
            if (IsmultiCurrencyEnabled) {
                Parent_Account.Container.put('CurrencyIsoCode', isoCode);
                Parent_Account.NContainer.put('CurrencyIsoCode', isoCode);
            }
    
            BSDInstance.compareBalanceSheetMap.put('Liabilty And Equity', Parent_Account);
    
            //  BSDInstance = getdata(BSDInstance);
    
    
            List < W3 > FW = new List < W3 > ();
            // converting the map to wrapper to iterate in lightning
            for (String s: BSDInstance.compareBalanceSheetMap.keySet()) {
                AccountGroup a = BSDInstance.compareBalanceSheetMap.get(s);
                W3 w3Instance = new W3();
                w3Instance.W3trans = new List < ERP7__Transaction__c > ();
                //Transactions
                Map < String, Map < Integer, ERP7__Transaction__c >> t = a.GContainerFyWValues;
                for (String ab: a.GContainerFyWValues.keyset()) {
                    Map < Integer, ERP7__Transaction__c > m1 = a.GContainerFyWValues.get(ab);
                    for (Integer i: m1.keyset()) {
                        w3Instance.W3trans.add(m1.get(i));
                    }
                }
                //Name
                w3Instance.W3COA = a.Name;
    
    
                //wrapper
                List < W2 > inner2 = new List < W2 > ();
                List < AccountGroup > sub = a.SubAccountList;
                for (AccountGroup subInstance: sub) {
                    W2 w2Instance = new W2();
                    AccountGroup sins = subInstance;
                    //Trans 
                    for (String abc: sins.GContainerFyWValues.keyset()) {
                        Map < Integer, ERP7__Transaction__c > m1 = sins.GContainerFyWValues.get(abc);
                        for (Integer i: m1.keyset()) {
                            w2Instance.W2trans.add(m1.get(i));
                        }
                    }
                    //Name 
                    w2Instance.W2COA = sins.Name;
                    //wrapper
                    List < AccountGroup > sub1 = sins.SubAccountList;
                    for (AccountGroup sub1ins: sub1) {
                        W1 w1instance = new W1();
                        //name
                        w1instance.W1COA = sub1ins.Name;
                        //transactions
                        for (String abc2: sub1ins.GContainerFyWValues.keyset()) {
                            Map < Integer, ERP7__Transaction__c > w1ins = sub1ins.GContainerFyWValues.get(abc2);
                            for (Integer i: w1ins.keyset()) {
                                w1instance.W1trans.add(w1ins.get(i));
                            }
                        }
                        //wrapper
                        w2Instance.innerWrapperW1.add(w1instance);
                    }
                    inner2.add(w2Instance);
                }
                w3Instance.innnerWrpperW2 = inner2;
                BSDInstance.Wrapper.add(w3Instance);
            }
            // End of converting the map to wrapper to iterate in lightning
            // BSDInstance.compareBalanceSheetMap.clear();        
            return BSDInstance;
        } catch (Exception e) {
            system.debug('Exception e=>' + e + e.getLineNumber() + e.getMessage());
            BSDInstance.errMsg = String.valueOf(e.getMessage()) + String.valueOf(e.getLineNumber());
            return BSDInstance;
        }
    }
    
    @AuraEnabled
    public static BalanceSheetLightning getGraphValues(String B) {
        BalanceSheetLightning BSDInstance = (BalanceSheetLightning) JSON.deserialize(B, BalanceSheetLightning.class);
        try {
            return getdata(BSDInstance);
        } catch (Exception e) {
            BSDInstance.errMsg = String.valueOf(e.getMessage()) + String.valueOf(e.getLineNumber());
            return BSDInstance;
        }
    }
    
    public class Data {
        @AuraEnabled
        public String name {
            get;
            set;
        }
        @AuraEnabled
        public Decimal data1 {
            get;
            set;
        }
        @AuraEnabled
        public Decimal data2 {
            get;
            set;
        }
        @AuraEnabled
        public Decimal data3 {
            get;
            set;
        }
        @AuraEnabled
        public Decimal data4 {
            get;
            set;
        }
        public Data(String name, Decimal data1, Decimal data2, Decimal data3, Decimal data4) {
            this.name = name;
            this.data1 = data1;
            this.data2 = data2;
            this.data3 = data3;
            this.data4 = data4;
        }
        public Data(String name, Decimal data1, Decimal data2, Decimal data3) {
            this.name = name;
            this.data1 = data1;
            this.data2 = data2;
            this.data3 = data3;
        }
        public Data(String name, Decimal data1, Decimal data2) {
            this.name = name;
            this.data1 = data1;
            this.data2 = data2;
        }
        public Data(String name, Decimal data1) {
            this.name = name;
            this.data1 = data1;
        }
    }
    
    @AuraEnabled
    public List < Data > datalist {
        get;
        set;
    }
    
    @AuraEnabled
    public static BalanceSheetLightning getdata(BalanceSheetLightning BS) {
        BalanceSheetLightning BSD = BS;
        try {
            BSD.Colorset = String.join(BSD.colors, ',');
            BSD.datalist = new List < data > ();
            Map < String, decimal > tempMap;
            BSD.FyYear = '';
            BSD.yfields = '';
            BSD.ChartTitle = 'Balance Sheet Accounts';
            tempMap = new Map < String, decimal > ();
            for (AccountGroup temp: BSD.compareBalanceSheetMap.values()) {
                tempMap = new Map < String, decimal > ();
                for (String s: temp.FywiseValues.keyset()) {
                    Map < Integer, Decimal > valMap = new Map < Integer, Decimal > (temp.FywiseValues.get(s));
                    Decimal TotalValue = 0.00;
                    for (Decimal d: valMap.values()) TotalValue += d;
                    tempMap.put(s, TotalValue);
                }
                BSD.CurrentChartofAccounts.put('Total ' + temp.Name, tempMap);
                if (temp.SubAccountList != null && temp.SubAccountList.size() > 0)
                    for (AccountGroup stemp: temp.SubAccountList) {
                        Map < String, decimal > tempMap1 = new Map < String, decimal > ();
                        for (String s: stemp.FywiseValues.keyset()) {
                            Map < Integer, Decimal > valMap = new Map < Integer, Decimal > (stemp.FywiseValues.get(s));
                            Decimal TotalValue = 0.00;
                            for (Decimal d: valMap.values()) TotalValue += d;
                            tempMap1.put(s, TotalValue);
                        }
                        BSD.CurrentChartofAccounts.put(stemp.Name, tempMap1);
                    }
            }
    
            Map < String, decimal > temp_Map;
            for (String s: BSD.CurrentChartofAccounts.keyset()) {
                temp_Map = BSD.CurrentChartofAccounts.get(s);
                List < Decimal > valueList = temp_Map.values();
                INteger k = 0;
                if (valueList.size() == 4) BSD.datalist.add(new Data(s, valueList[k], valueList[k + 1], valueList[k + 2], valueList[k + 3]));
                else if (valueList.size() == 3) BSD.datalist.add(new Data(s, valueList[k], valueList[k + 1], valueList[k + 2]));
                else if (valueList.size() == 2) BSD.datalist.add(new Data(s, valueList[k], valueList[k + 1]));
                else
                    BSD.datalist.add(new Data(s, valueList[k]));
    
            }
            List < String > keyList = new List < String > ();
            for (integer x = 1; x <= temp_Map.keyset().size(); x++) {
                keyList.add('data' + x);
    
            }
            BSD.FyYear = String.join(keyList, ',');
            BSD.yfields = String.join(new List < String > (temp_Map.keyset()), ',');
    
    
            for (AccountGroup AG: BSD.compareBalanceSheetMap.values()) {
                for (String s: AG.FywiseValues.keyset()) {
                    Map < integer, Decimal > AV = new Map < integer, Decimal > (AG.FywiseValues.get(s));
                    Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                    for (Integer aVal: AV.keyset()) {
                        ERP7__Transaction__c trans = new ERP7__Transaction__c();
                        trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                        if (BSD.multiCurrencyEnabled && BSD.isoCode != '' && BSD.isoCode != null) trans.put('CurrencyIsoCode', BSD.isoCode);
                        setAV.put(aVal, trans);
                    }
                    AG.GContainerFyWValues.put(s, setAV);
                }
                for (AccountGroup AGS: AG.SubAccountList) {
                    for (String s: AGS.FywiseValues.keyset()) {
                        Map < integer, Decimal > AVS = new Map < integer, Decimal > (AGS.FywiseValues.get(s));
                        Map < integer, ERP7__Transaction__c > setAVS = new Map < integer, ERP7__Transaction__c > ();
                        for (Integer aVal: AVS.keyset()) {
                            ERP7__Transaction__c trans = new ERP7__Transaction__c();
                            trans.ERP7__Amount__c = (AVS.get(aVal) >= 0) ? AVS.get(aVal) : (0 - AVS.get(aVal));
                            if (BSD.multiCurrencyEnabled && BSD.isoCode != '' && BSD.isoCode != null) trans.put('CurrencyIsoCode', BSD.isoCode);
                            setAVS.put(aVal, trans);
                        }
                        AGS.GContainerFyWValues.put(s, setAVS);
                    }
    
                }
            }
            return BSD;
        } catch (Exception e) {
            BSD.errMsg = String.valueOf(e.getMessage()) + String.valueOf(e.getLineNumber());
            return null;
        }
    }
    
    public class BSWrapper{
        @AuraEnabled public List<AggregateResult> aggResult {get;set;}
        @AuraEnabled public List<ERP7__Finance_General_Ledger_Entry__c> ledgerList   {get;set;}
        @AuraEnabled public Date eDate {get;set;}
        @AuraEnabled public String orgId {get;set;}
        @AuraEnabled public Set<Id> ledgerIds {get;set;}
        @AuraEnabled public String lastId {get;set;}
        public BSWrapper(){
            aggResult = new List<AggregateResult>();
            eDate = null;
            orgId = null;
            ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
            ledgerIds = new Set<Id>();
            lastId = '';
        }
    }
    
    @AuraEnabled
    public static List<String> fetchLedgerIds(Date eDate,String orgId, String FiscalYear){
        system.debug('eDate-->'+eDate);
        if(orgId==null) orgId = ERP7.UtilClass.getOrganisationByLogin_Employee().Id;
        if(eDate==null) eDate = system.today();
        List<ERP7__Finance_General_Ledger_Entry__c> ledgerArrayList = new List<ERP7__Finance_General_Ledger_Entry__c>();
        if(FiscalYear=='THIS_FISCAL_YEAR'){
            ledgerArrayList = [SELECT Id FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND ERP7__Organisation__c =: orgId AND ERP7__General_Ledger_Entry_DateTime__c <=:eDate AND ERP7__General_Ledger_Entry_DateTime__c =THIS_FISCAL_YEAR limit 40000];
        }else{
            ledgerArrayList = [SELECT Id FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND ERP7__Organisation__c =: orgId AND ERP7__General_Ledger_Entry_DateTime__c <=:eDate AND ERP7__General_Ledger_Entry_DateTime__c >= LAST_FISCAL_YEAR AND ERP7__General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR limit 40000];
        }
        List<Id> LedgerList = new List<Id>();
        for (ERP7__Finance_General_Ledger_Entry__c fgle : ledgerArrayList) {
            LedgerList.add(String.valueOf(fgle.id));
        }
        return LedgerList;
        
    }
    
    @AuraEnabled
    public static List<String> fetchNeLedgerIds(Date eDate, String orgId, List<String> ledgerIds) {
        system.debug('fetchNeLedgerIds-->' + ledgerIds);

        // Set default values if null
        if (orgId == null) {
            orgId = ERP7.UtilClass.getOrganisationByLogin_Employee().Id;
        }
        
        if (eDate == null) {
            eDate = system.today();
        }

        // Query and filter the ledger entries
        List<ERP7__Finance_General_Ledger_Entry__c> ledgerEntries = [
            SELECT Id 
            FROM ERP7__Finance_General_Ledger_Entry__c 
            WHERE ERP7__Active__c = true 
                AND ERP7__Organisation__c = :orgId 
                AND ERP7__General_Ledger_Entry_DateTime__c <= :eDate 
                AND Id NOT IN :ledgerIds 
            LIMIT 40000
        ];

        // Convert to List of String
        List<String> newLedgerIds = new List<String>();
        for (ERP7__Finance_General_Ledger_Entry__c entry : ledgerEntries) {
            newLedgerIds.add(String.valueOf(entry.Id));
        }

        return newLedgerIds;
    }
    
    public class JsonWrapper {
        public Decimal Credit;
        public Decimal Debit;
        public String AccountId;
        public String AccountName;
        public String AccountGroup;
        public String SubAccountGroup;
        public Boolean ContraAccount;
        public Integer FY;

        public JsonWrapper(Decimal credit, Decimal debit, String accountId, String accountName, 
                           String accountGroup, String subAccountGroup, Boolean contraAccount, Integer fy) {
            this.Credit = credit;
            this.Debit = debit;
            this.AccountId = accountId;
            this.AccountName = accountName;
            this.AccountGroup = accountGroup;
            this.SubAccountGroup = subAccountGroup;
            this.ContraAccount = contraAccount;
            this.FY = fy;
        }
    }
    
    @AuraEnabled
    public static List<AggregateResult> fetchOpeniBalanceCOA(String aggList, String orgId) {
        System.debug('aggList-->' + aggList);

        // Deserialize the JSON string into a list of lists of wrapper objects
        List<List<JsonWrapper>> jsonList = (List<List<JsonWrapper>>) JSON.deserialize(aggList, List<List<JsonWrapper>>.class);

        // Extract AccountIds from the deserialized JSON
        Set<Id> coaIds = new Set<Id>();
        for (List<JsonWrapper> innerList : jsonList) {
            for (JsonWrapper wrapper : innerList) {
                System.debug('AccountId-->' + wrapper.AccountId);

                // Extract 'AccountId' from each wrapper
                if (wrapper.AccountId != null) {
                    coaIds.add((Id) wrapper.AccountId);
                }
            }
        }
		system.debug('coaIds-->'+coaIds);
        // Perform the SOQL query based on AccountIds
        if (!coaIds.isEmpty()) {
            List<AggregateResult> moreRecord = [
                SELECT SUM(ERP7__Credit_Entry__c) Credit, SUM(ERP7__Debit_Entry__c) Debit,
                       ERP7__Chart_of_Account__c AccountId, ERP7__Chart_of_Account__r.Name AccountName, 
                       ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                       ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, 
                       ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, 
                       ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, 
                       CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
                FROM ERP7__Finance_General_Ledger_Entry__c
                WHERE ERP7__Active__c = true 
                    AND ERP7__Organisation__c = :orgId 
                    AND Id NOT IN :coaIds 
                    AND ERP7__Accounting_Period__c = null 
                    AND ERP7__Transactions__c = null 
                GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), 
                         ERP7__Chart_of_Account__r.Name, 
                         ERP7__Chart_of_Account__c, 
                         ERP7__Chart_of_Account__r.RecordType.DeveloperName, 
                         ERP7__Chart_of_Account__r.ERP7__Account_Type__c, 
                         ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, 
                         ERP7__Chart_of_Account__r.ERP7__isContra_Account__c 
                ORDER BY ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST
            ];
			system.debug('moreRecord-->'+moreRecord);
            return moreRecord;
        }
		//AND ERP7__Chart_of_Account__r.ERP7__Opening_Balance__c != null 
        //AND ERP7__Chart_of_Account__r.ERP7__Opening_Balance__c > 0 
                    
        return new List<AggregateResult>();
    }


    
    @AuraEnabled
    public static BSWrapper computeDataUpdated(Date eDate, String orgId, String FiscalYear, String lastId){
        system.debug('eDate-->'+eDate);
        system.debug('orgId-->'+orgId);
        BSWrapper bsrap = new BSWrapper();
        if(eDate==null) eDate = system.today();
        Date sDate = eDate.addYears(-1);
        if(orgId==null) orgId = ERP7.UtilClass.getOrganisationByLogin_Employee().Id;
        List < AggregateResult > BalanceSheetData = new List < AggregateResult > ();
        system.debug('Inside If');
        BalanceSheetData = new List < AggregateResult > ();
        Map<Id, ERP7__Finance_General_Ledger_Entry__c> ledgerMap = new  Map<Id, ERP7__Finance_General_Ledger_Entry__c>();
        system.debug('lastId-->'+lastId);
        if(lastId!=null && lastId!=''){
            system.debug('Inside If');
            ledgerMap = new  Map<Id, ERP7__Finance_General_Ledger_Entry__c>([select Id, Name from ERP7__Finance_General_Ledger_Entry__c where Id >:lastId ORDER BY Id Limit 20000]);
        }else{
            system.debug('Inside Else');
            ledgerMap = new  Map<Id, ERP7__Finance_General_Ledger_Entry__c>([select Id, Name from ERP7__Finance_General_Ledger_Entry__c ORDER BY Id Limit 20000]);
        }
        Set<Id> keyset = new Set<Id>(ledgerMap.keySet());
        system.debug('keyset-->'+keyset);
        List<Id> keys = new List<Id>(keyset);
        if(keys.size()>0){
        String lastKey = keys[keys.size() - 1];
        bsrap.lastId = lastKey;
        }
        //bsrap.ledgerIds = ledgerMap.keyset();
        /*if(FirstRun){
            if(FiscalYear=='THIS_FISCAL_YEAR'){
                BalanceSheetData = [SELECT SUM(ERP7__Credit_Entry__c) Credit, SUM(ERP7__Debit_Entry__c) Debit,
                                    ERP7__Chart_of_Account__c AccountId, ERP7__Chart_of_Account__r.Name AccountName, ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                                    ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
                                    FROM ERP7__Finance_General_Ledger_Entry__c
                                    WHERE ERP7__Active__c = true AND ERP7__Organisation__c =:orgId AND
                                    ERP7__General_Ledger_Entry_DateTime__c >=:sDate AND ERP7__General_Ledger_Entry_DateTime__c <=:eDate AND ERP7__General_Ledger_Entry_DateTime__c =THIS_FISCAL_YEAR
                                    AND Id IN :LedgerIds AND ERP7__Transactions__c!=null AND ERP7__Accounting_Period__c!=null //AND  ERP7__Organisation__c = :BSDInstance.Select_Organisation.ERP7__Organisation__c
                                    GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.ERP7__Account_Type__c, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c Order By ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST
                                   ]; 
            }else{
                BalanceSheetData = [SELECT SUM(ERP7__Credit_Entry__c) Credit, SUM(ERP7__Debit_Entry__c) Debit,
                                    ERP7__Chart_of_Account__c AccountId, ERP7__Chart_of_Account__r.Name AccountName, ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                                    ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
                                    FROM ERP7__Finance_General_Ledger_Entry__c
                                    WHERE ERP7__Active__c = true AND ERP7__Organisation__c =:orgId AND ERP7__General_Ledger_Entry_DateTime__c >=:sDate AND
                                    ERP7__General_Ledger_Entry_DateTime__c <=:eDate AND ERP7__General_Ledger_Entry_DateTime__c >= LAST_FISCAL_YEAR AND ERP7__General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR
                                    AND Id IN :LedgerIds  AND ERP7__Transactions__c!=null AND ERP7__Accounting_Period__c!=null //AND  ERP7__Organisation__c = :BSDInstance.Select_Organisation.ERP7__Organisation__c
                                    GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.ERP7__Account_Type__c, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c Order By ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST
                                   ]; 
            }
        }else{*/
            BalanceSheetData = [SELECT SUM(ERP7__Credit_Entry__c) Credit, SUM(ERP7__Debit_Entry__c) Debit,
                            ERP7__Chart_of_Account__c AccountId, ERP7__Chart_of_Account__r.Name AccountName, ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                            ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
                            FROM ERP7__Finance_General_Ledger_Entry__c
                            WHERE ERP7__Active__c = true AND ERP7__Organisation__c =:orgId AND
                            DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=:eDate 
                            AND Id IN :ledgerMap.keyset() AND ERP7__Transactions__c!=null AND ERP7__Accounting_Period__c!=null //AND  ERP7__Organisation__c = :BSDInstance.Select_Organisation.ERP7__Organisation__c
                            GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.ERP7__Account_Type__c, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c Order By ERP7__Chart_of_Account__r.Name ASC NULLS LAST 
                           ];
        //}// AND ERP7__General_Ledger_Entry_DateTime__c >=:sDate
        /*List < AggregateResult > moreRecord = new List< AggregateResult>();
        List<ERP7__Chart_of_Accounts__c> coaList = new List<ERP7__Chart_of_Accounts__c>();
        Set<Id> coaIds = new Set<Id>();
        for(AggregateResult agg : BalanceSheetData){
            coaIds.add((ID) agg.get('AccountId'));
        }
        system.debug('coaIds-->'+coaIds);
        moreRecord = [SELECT SUM(ERP7__Credit_Entry__c) Credit, SUM(ERP7__Debit_Entry__c) Debit,
                            ERP7__Chart_of_Account__c AccountId, ERP7__Chart_of_Account__r.Name AccountName, ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                            ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
                            FROM ERP7__Finance_General_Ledger_Entry__c
                            WHERE ERP7__Active__c = true AND ERP7__Organisation__c =:orgId AND ERP7__Chart_of_Account__r.ERP7__Opening_Balance__c!=null AND ERP7__Chart_of_Account__r.ERP7__Opening_Balance__c>0 
                            AND Id NOT IN :coaIds AND ERP7__Accounting_Period__c=null AND ERP7__Transactions__c=null //AND  ERP7__Organisation__c = :BSDInstance.Select_Organisation.ERP7__Organisation__c
                            GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.ERP7__Account_Type__c, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c Order By ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST
                           ];
        BalanceSheetData.addAll(moreRecord);*/
        system.debug('BalanceSheetData 1: '+BalanceSheetData.size());
        bsrap.aggResult = BalanceSheetData;
        bsrap.eDate = eDate;
        bsrap.orgId = orgId;
        //bsrap.ledgerList = [select Id, ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c, ERP7__General_Ledger_Entry_DateTime__c FROM ERP7__Finance_General_Ledger_Entry__c where Id IN:ledgerMap.keyset()];
        return bsrap;
    }
    @AuraEnabled
    public static BalanceSheetLightning ComputeSelectedFyData(BalanceSheetLightning b) {
        system.debug('ComputeSelectedFyData called');
        BalanceSheetLightning BSDInstance = b;
        String isocodd = BSDInstance.isoCode;
        List < W1 > wrapper = new List < W1 > ();
        set < Id > coaIds = new set < Id > ();
        try {
            
            BSDInstance.Total_Assets = new ERP7__Chart_of_Accounts__c(ERP7__Opening_Balance__c = 0.00);
            BSDInstance.Total_Liab_Equity = new ERP7__Chart_of_Accounts__c(ERP7__Opening_Balance__c = 0.00);
            if (BSDInstance.multiCurrencyEnabled) {
                BSDInstance.Total_Assets.put('CurrencyIsoCode', BSDInstance.isoCode);
                BSDInstance.Total_Liab_Equity.put('CurrencyIsoCode', BSDInstance.isoCode);
            }
            BSDInstance.FinancialYearWiseAssetMap = new Map < String, AccountGroup > ();
            BSDInstance.FyWiseIncomeMap = new Map < String, Decimal > ();
            BSDInstance.FyWiseExpenseMap = new Map < String, Decimal > ();
            Map < Id, ERP7__Chart_of_Accounts__c > chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c >();
            chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c >([SELECT Name, RecordTypeId, ERP7__isContra_Account__c,
                                          ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c,ERP7__Organisation__c FROM ERP7__Chart_of_Accounts__c where ERP7__Active__c = true ]);

            if ((chart_Of_Accounts.size() == 0 || chart_Of_Accounts == null) && BSDInstance.showBalancesheet) {
                BSDInstance.showBalancesheet = false;
                BSDInstance.errMsg = 'Error: No Chart of Accounts, found For selected Organisation.';
                return null;
            }
            // For converting to other currency
            Boolean ismultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            String isoCodee;
            Decimal conversionRate = 1;
            if (ismultiCurrency) {
                isoCodee = (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
                String iso = UserInfo.getDefaultCurrency();
                String q = 'SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso';
                conversionRate = (Decimal) Database.Query(q)[0].get('conversionRate');
            }
            // End of converting to other currency  = THIS_FISCAL_YEAR  
            
            
            List < AggregateResult > BalanceSheetData = new List < AggregateResult > ();
            Map<String, Module__c> runModule = new Map<String, Module__c>(Module__c.getAll());
            
            Integer RecordCount = 2000;
            if (runModule.size() > 0 ) {
                if(runModule.get('Finance').ERP7__BS_Record_Cound__c!=null && runModule.get('Finance').ERP7__BS_Record_Cound__c!=0){
                    RecordCount=Integer.valueOf(runModule.get('Finance').ERP7__BS_Record_Cound__c);
                }
            }
            system.debug('RecordCount-->'+RecordCount);
            //AND ERP7__General_Ledger_Entry_DateTime__c >=: BSDInstance.sDate  Moin Removed this
            if (BSDInstance.FiscalYearQuarter.get(BSDInstance.SelectedFy) == '= THIS_FISCAL_YEAR') {
                system.debug('Inside If');
                BalanceSheetData = new List < AggregateResult > ();
                Map<Id, ERP7__Finance_General_Ledger_Entry__c> ledgerMap = new Map<Id,ERP7__Finance_General_Ledger_Entry__c>([SELECT Id FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND ERP7__Organisation__c =: BSDInstance.Select_Organisation.ERP7__Organisation__c AND
                    ERP7__General_Ledger_Entry_DateTime__c <=: BSDInstance.eDate limit 20000]);
                system.debug('ledgerMap-->'+ledgerMap.size());
                BalanceSheetData = [SELECT SUM(ERP7__Credit_Entry__c) Credit, SUM(ERP7__Debit_Entry__c) Debit,
                    ERP7__Chart_of_Account__c AccountId, ERP7__Chart_of_Account__r.Name AccountName, ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                    ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
                    FROM ERP7__Finance_General_Ledger_Entry__c
                    WHERE ERP7__Active__c = true AND ERP7__Organisation__c =: BSDInstance.Select_Organisation.ERP7__Organisation__c AND
                    ERP7__General_Ledger_Entry_DateTime__c <=: BSDInstance.eDate 
                    AND Id IN :ledgerMap.keyset() //AND  ERP7__Organisation__c = :BSDInstance.Select_Organisation.ERP7__Organisation__c
                    GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.ERP7__Account_Type__c, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c Order By ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST limit 40
                ]; 
                if(runModule.get('Finance').ERP7__Execute_More_Than_50K_Records__c){
                    List < AggregateResult > moreRecord = new List< AggregateResult>();
                    moreRecord = [SELECT SUM(ERP7__Credit_Entry__c) Credit, SUM(ERP7__Debit_Entry__c) Debit,
                    ERP7__Chart_of_Account__c AccountId, ERP7__Chart_of_Account__r.Name AccountName, ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,
                    ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY
                    FROM ERP7__Finance_General_Ledger_Entry__c
                    WHERE ERP7__Active__c = true AND ERP7__Organisation__c =: BSDInstance.Select_Organisation.ERP7__Organisation__c AND
                    ERP7__General_Ledger_Entry_DateTime__c <=: BSDInstance.eDate 
                    AND Id Not IN :ledgerMap.keyset() //AND  ERP7__Organisation__c = :BSDInstance.Select_Organisation.ERP7__Organisation__c
                    GROUP BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c), ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.RecordType.DeveloperName, ERP7__Chart_of_Account__r.ERP7__Account_Type__c, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c Order By ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST limit :RecordCount
                    ]; 
                    BalanceSheetData.addAll(moreRecord);
                }
            } else {
                system.debug('Else');
                String Query = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit,' +
                    'ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,' +
                    ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup, ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c subCategory, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount,CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) FY ' +
                    ' FROM ERP7__Finance_General_Ledger_Entry__c where ERP7__Active__c=true AND' +
                    ' (ERP7__General_Ledger_Entry_DateTime__c ' + BSDInstance.FiscalYearQuarter.get(BSDInstance.SelectedFy) + ' ) AND ' + //' OR ERP7__General_Ledger_Entry_DateTime__c >= :'+Date.parse(BSDInstance.StartDate)+' OR  ERP7__General_Ledger_Entry_DateTime__c <= :'+Date.parse(BSDInstance.endDate)+' ) AND '+ 
                    ' ERP7__Organisation__c =\'' + BSDInstance.Select_Organisation.ERP7__Organisation__c + '\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Assets\',\'Liability\',\'Equity\',\'Income_Revenue\',\'Expense\')' +
                    ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__Sub_Account_Type__c, ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY ERP7__Chart_of_Account__r.ERP7__Account_Type__c DESC NULLS LAST  limit 2000';
                BalanceSheetData = Database.query(Query);
            }
            system.debug('BalanceSheetData 1: '+BalanceSheetData.size());
            
            List < AccountGroup > AccountNameValueList = new List < AccountGroup > ();
            List < AccountGroup > subAccsList = new List < AccountGroup > ();
            for (AggregateResult bsd: BalanceSheetData) {
                coaIds.add((ID) bsd.get('AccountId'));
                Decimal openingBal = (chart_Of_Accounts.get((ID) bsd.get('AccountId')) != null) ? chart_Of_Accounts.get((ID) bsd.get('AccountId')).ERP7__Opening_Balance__c : 0.00;
                Decimal creditSum = 0.0;
                Decimal debitsum = 0.0;
                Decimal ClosingBalance = 0.0;
                Decimal TotalIncome = 0.00;
                Decimal TotalExpense = 0.00;
                AccountGroup AccountNameValue = new AccountGroup();
                if (BSDInstance.multiCurrencyEnabled) {
                    AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                AccountGroup ParentAccount = new AccountGroup();
                if (BSDInstance.multiCurrencyEnabled) {
                    ParentAccount.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    ParentAccount.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                //List<AccountGroup> AccountNameValueList = new List<AccountGroup>();
                //List<AccountGroup> subAccsList = new List<AccountGroup>();
    
                // For mulitiplication of currencies
                if (bsd.get('Credit') != null) {
                    if (ismultiCurrency) {
                        if (isoCodee != UserInfo.getDefaultCurrency()) {
                            creditSum = double.valueOf(bsd.get('Credit')) * double.valueOf(conversionRate);
                            creditSum = creditSum / double.valueOf(conversionRate);
                        } else {
                            creditSum = double.valueOf(bsd.get('Credit'));
                        }
                    } else {
                        creditSum = double.valueOf(bsd.get('Credit'));
                    }
                }
                if (bsd.get('Debit') != null) {
                    if (ismultiCurrency) {
                        if (isoCodee != UserInfo.getDefaultCurrency()) {
                            debitsum = double.valueOf(bsd.get('Debit')) * double.valueOf(conversionRate);
                            debitsum = debitsum / double.valueOf(conversionRate);
                        } else {
                            debitsum = double.valueOf(bsd.get('Debit'));
                        }
                    } else {
                        debitsum = double.valueOf(bsd.get('Debit'));
                    }
                }
                // End of mulitiplication of currencies   
                system.debug('bsd.get(AccountGroup) : '+bsd.get('AccountGroup'));
                
                if (bsd.get('AccountGroup') == 'Assets') {
                    if ((Boolean) bsd.get('ContraAccount')) {
                        system.debug('Assets c' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = (openingBal + (creditSum - debitsum));
                        AccountNameValue = AccountGroup3('Less:' + String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                        ClosingBalance = -ClosingBalance;
                    }
                    else {
                        system.debug('Assets' + String.valueOf(bsd.get('subCategory')));
                        system.debug('openingBal-->' + openingBal);
                        ClosingBalance = (openingBal - (creditSum - debitsum));
                        AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                    }
                } 
                else if (bsd.get('AccountGroup') == 'Liability') {
                    system.debug('Liabiltiy' + String.valueOf(bsd.get('subCategory')));
                    ClosingBalance = (openingBal + (creditSum - debitsum));
                    AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                    if (BSDInstance.multiCurrencyEnabled) {
                        AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                        AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                    }
                } 
                else if (bsd.get('AccountGroup') == 'Equity') {
                    system.debug('Equity' + String.valueOf(bsd.get('subCategory')));
                    if ((Boolean) bsd.get('ContraAccount')) {
                        ClosingBalance = (openingBal + (creditSum - debitsum));
                        AccountNameValue = AccountGroup3('Less:' + String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); // new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount')); 
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                        ClosingBalance = -ClosingBalance;
                    } else {
                        system.debug('Equity E' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = (openingBal + (creditSum - debitsum));
                        AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                    }
                } 
                else if (bsd.get('AccountGroup') == 'Income_Revenue') {
                    
                } 
                else if (bsd.get('AccountGroup') == 'Expense') {
                    
                }
                AccountNameValueList = new List < AccountGroup > ();
                AccountNameValueList.add(AccountNameValue);
                system.debug('AccountNameValueList size: '+AccountNameValueList.size());
                system.debug('openingBal : '+openingBal);
                system.debug('ClosingBalance-->' + ClosingBalance);
                
                AccountGroup subAccGrp = AccountGroup1(String.valueOf(bsd.get('SubAccountGroup')), String.valueOf(bsd.get('subCategory')), ClosingBalance, AccountNameValueList, isocodd); //new AccountGroup(String.valueOf(bsd.get('SubAccountGroup')),ClosingBalance,AccountNameValueList);
                if (BSDInstance.multiCurrencyEnabled) {
                    subAccGrp.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    subAccGrp.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                subAccsList = new List < AccountGroup > ();
                subAccsList.add(subAccGrp);
                ParentAccount = AccountGroup1(String.valueOf(bsd.get('AccountGroup')), String.valueOf(bsd.get('subCategory')), ClosingBalance, subAccsList, isocodd); // new AccountGroup(String.valueOf(bsd.get('AccountGroup')), ClosingBalance,subAccsList);
                if (BSDInstance.multiCurrencyEnabled) {
                    ParentAccount.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    ParentAccount.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                
                if (String.valueOf(bsd.get('AccountGroup')) == 'Assets' || String.valueOf(bsd.get('AccountGroup')) == 'Liability' || String.valueOf(bsd.get('AccountGroup')) == 'Equity') {
                    if (BSDInstance.FinancialYearWiseAssetMap.get(String.valueOf(bsd.get('AccountGroup'))) == null) {
                        BSDInstance.FinancialYearWiseAssetMap.put(String.valueOf(bsd.get('AccountGroup')), ParentAccount);
                    } else {
                        AccountGroup PAccount = BSDInstance.FinancialYearWiseAssetMap.get(String.valueOf(bsd.get('AccountGroup')));
                        if (BSDInstance.multiCurrencyEnabled) {
                            PAccount.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            PAccount.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
    
                        if (PAccount.SubAccountList != null && PAccount.SubAccountList.size() > 0) {
                            Boolean flag = true;
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
                                if (PAccount.SubAccountList[i].Name == String.valueOf(bsd.get('SubAccountGroup'))) {
                                    Boolean sflag = true;
                                    if (PAccount.SubAccountList[i].SubAccountList != null && PAccount.SubAccountList[i].SubAccountList.size() > 0) {
                                        for (Integer j = 0; j < PAccount.SubAccountList[i].SubAccountList.size(); j++) {
                                            if (PAccount.SubAccountList[i].SubAccountList[j].Name == String.valueOf(bsd.get('AccountName'))) {
                                                PAccount.SubAccountList[i].SubAccountList[j].value += ClosingBalance;
                                                sflag = false;
                                            }
                                        }
    
                                        for (Integer j = 0; j < PAccount.SubAccountList[i].SubAccountList.size(); j++) {
                                            PAccount.SubAccountList[i].SubAccountList[j].Container.ERP7__Amount__c = PAccount.SubAccountList[i].SubAccountList[j].value;
                                            PAccount.SubAccountList[i].SubAccountList[j].NContainer.ERP7__Amount__c = 0 - PAccount.SubAccountList[i].SubAccountList[j].value;
                                        }
                                        /*
                                        for (AccountGroup AG: PAccount.SubAccountList[i].SubAccountList) {
                                            for (String s: AG.FywiseValues.keyset()) {
                                                Map < integer, Decimal > AV = new Map < integer, Decimal > (AG.FywiseValues.get(s));
                                                Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                                                for (Integer aVal: AV.keyset()) {
                                                    ERP7__Transaction__c trans = new ERP7__Transaction__c();
                                                    trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                                                    if (BSDInstance.multiCurrencyEnabled) trans.put('CurrencyIsoCode', BSDInstance.isoCode);
                                                    setAV.put(aVal, trans);
                                                }
                                                AG.GContainerFyWValues.put(s, setAV);
                                            }
                                        }*/
    
                                    }
                                    
                                    if (sflag) {
                                        PAccount.SubAccountList[i].SubAccountList.add(AccountNameValue);
                                    }
                                    
                                    PAccount.SubAccountList[i].value += ClosingBalance;
                                    flag = false;
                                }
                            }
    
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
                                PAccount.SubAccountList[i].Container.ERP7__Amount__c = PAccount.SubAccountList[i].value;
                                PAccount.SubAccountList[i].NContainer.ERP7__Amount__c = 0 - PAccount.SubAccountList[i].value;
                            }
                            /*
                            for (AccountGroup AG: PAccount.SubAccountList) {
                                for (String s: AG.FywiseValues.keyset()) {
                                    Map < integer, Decimal > AV = new Map < integer, Decimal > (AG.FywiseValues.get(s));
                                    Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                                    for (Integer aVal: AV.keyset()) {
                                        ERP7__Transaction__c trans = new ERP7__Transaction__c();
                                        trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                                        if (BSDInstance.multiCurrencyEnabled) trans.put('CurrencyIsoCode', BSDInstance.isoCode);
                                        setAV.put(aVal, trans);
                                    }
                                    AG.GContainerFyWValues.put(s, setAV);
                                }
                            }*/
                            if (flag) {
                                PAccount.SubAccountList.add(subAccGrp);
                            }
    
                            PAccount.value += ClosingBalance;
                            PAccount.Container.ERP7__Amount__c = PAccount.value;
                            PAccount.NContainer.ERP7__Amount__c = 0 - PAccount.value;
                        }
                    }
                }
            }
            
            
            BalanceSheetData = new List < AggregateResult > ();
            system.debug('org -->'+BSDInstance.Select_Organisation.Id);
            //if(BSDInstance.Select_Organisation.Id != null){
                //if(BSDInstance.Select_Organisation.ERP7__Organisation__c != null){
                    BalanceSheetData = [select Id AccountId, Name AccountName, RecordType.DeveloperName AccountGroup, ERP7__Account_Type__c SubAccountGroup, ERP7__Sub_Account_Type__c subCategory, ERP7__isContra_Account__c ContraAccount from ERP7__Chart_of_Accounts__c where Id Not IN: coaIds and ERP7__Opening_Balance__c != null and ERP7__Opening_Balance__c > 0  GROUP BY Name, Id, RecordType.DeveloperName, ERP7__Account_Type__c, ERP7__Sub_Account_Type__c, ERP7__isContra_Account__c Order By ERP7__Account_Type__c DESC NULLS LAST Limit 2000];
                //}
            //}
            system.debug('BalanceSheetData 2: ' + BalanceSheetData.size());
            
            for (AggregateResult bsd: BalanceSheetData) {
                Decimal openingBal = (chart_Of_Accounts.get((ID) bsd.get('AccountId')) != null) ? chart_Of_Accounts.get((ID) bsd.get('AccountId')).ERP7__Opening_Balance__c : 0.00;
                system.debug('openingBal' + openingBal);
                Decimal creditSum = 0.0;
                Decimal debitsum = 0.0;
                Decimal ClosingBalance = 0.0;
                Decimal TotalIncome = 0.00;
                Decimal TotalExpense = 0.00;
                AccountGroup AccountNameValue = new AccountGroup();
                if (BSDInstance.multiCurrencyEnabled) {
                    AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                AccountGroup ParentAccount = new AccountGroup();
                if (BSDInstance.multiCurrencyEnabled) {
                    ParentAccount.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    ParentAccount.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                system.debug('bsd-->3' + bsd.get('AccountGroup'));
                if (bsd.get('AccountGroup') == 'Assets') {
                    if ((Boolean) bsd.get('ContraAccount')) {
                        system.debug('Assets c' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = openingBal;
                        AccountNameValue = AccountGroup3('Less:' + String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                        ClosingBalance = -ClosingBalance;
                    } else {
                        system.debug('Assets' + String.valueOf(bsd.get('subCategory')));
                        system.debug('openingBal-->' + openingBal);
                        ClosingBalance = openingBal;
                        AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                    }
                } else if (bsd.get('AccountGroup') == 'Liability') {
                    system.debug('Liabiltiy' + String.valueOf(bsd.get('subCategory')));
                    ClosingBalance = openingBal;
                    AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                    if (BSDInstance.multiCurrencyEnabled) {
                        AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                        AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                    }
                } else if (bsd.get('AccountGroup') == 'Equity') {
                    system.debug('Equity' + String.valueOf(bsd.get('subCategory')));
                    if ((Boolean) bsd.get('ContraAccount')) {
                        ClosingBalance = openingBal;
                        AccountNameValue = AccountGroup3('Less:' + String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); // new AccountGroup('Less:'+String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount')); 
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                        ClosingBalance = -ClosingBalance;
                    } else {
                        system.debug('Equity E' + String.valueOf(bsd.get('subCategory')));
                        ClosingBalance = openingBal;
                        AccountNameValue = AccountGroup3(String.valueOf(bsd.get('AccountName')), String.valueOf(bsd.get('subCategory')), ClosingBalance, (Boolean) bsd.get('ContraAccount')); //new AccountGroup(String.valueOf(bsd.get('AccountName')),ClosingBalance,(Boolean)bsd.get('ContraAccount'));
                        if (BSDInstance.multiCurrencyEnabled) {
                            AccountNameValue.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            AccountNameValue.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
                    }
                } else if (bsd.get('AccountGroup') == 'Income_Revenue') {
                    
                } else if (bsd.get('AccountGroup') == 'Expense') {
                    
                }
                AccountNameValueList = new List < AccountGroup > ();
                AccountNameValueList.add(AccountNameValue);
                
                system.debug('ClosingBalance-->' + ClosingBalance);
                AccountGroup subAccGrp = AccountGroup1(String.valueOf(bsd.get('SubAccountGroup')), String.valueOf(bsd.get('subCategory')), ClosingBalance, AccountNameValueList, isocodd); //new AccountGroup(String.valueOf(bsd.get('SubAccountGroup')),ClosingBalance,AccountNameValueList);
                if (BSDInstance.multiCurrencyEnabled) {
                    subAccGrp.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    subAccGrp.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                subAccsList = new List < AccountGroup > ();
                subAccsList.add(subAccGrp);
                ParentAccount = AccountGroup1(String.valueOf(bsd.get('AccountGroup')), String.valueOf(bsd.get('subCategory')), ClosingBalance, subAccsList, isocodd); // new AccountGroup(String.valueOf(bsd.get('AccountGroup')), ClosingBalance,subAccsList);
                if (BSDInstance.multiCurrencyEnabled) {
                    ParentAccount.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                    ParentAccount.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                }
                if (String.valueOf(bsd.get('AccountGroup')) == 'Assets' || String.valueOf(bsd.get('AccountGroup')) == 'Liability' || String.valueOf(bsd.get('AccountGroup')) == 'Equity') {
                    if (BSDInstance.FinancialYearWiseAssetMap.get(String.valueOf(bsd.get('AccountGroup'))) == null) {
                        BSDInstance.FinancialYearWiseAssetMap.put(String.valueOf(bsd.get('AccountGroup')), ParentAccount);
                    } else {
                        AccountGroup PAccount = BSDInstance.FinancialYearWiseAssetMap.get(String.valueOf(bsd.get('AccountGroup')));
                        if (BSDInstance.multiCurrencyEnabled) {
                            PAccount.Container.put('CurrencyIsoCode', BSDInstance.isoCode);
                            PAccount.NContainer.put('CurrencyIsoCode', BSDInstance.isoCode);
                        }
    
                        if (PAccount.SubAccountList != null && PAccount.SubAccountList.size() > 0) {
                            Boolean flag = true;
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
                                if (PAccount.SubAccountList[i].Name == String.valueOf(bsd.get('SubAccountGroup'))) {
                                    Boolean sflag = true;
                                    if (PAccount.SubAccountList[i].SubAccountList != null && PAccount.SubAccountList[i].SubAccountList.size() > 0) {
                                        for (Integer j = 0; j < PAccount.SubAccountList[i].SubAccountList.size(); j++) {
                                            if (PAccount.SubAccountList[i].SubAccountList[j].Name == String.valueOf(bsd.get('AccountName'))) {
                                                PAccount.SubAccountList[i].SubAccountList[j].value += ClosingBalance;
                                                sflag = false;
                                            }
    
                                        }
    
                                        for (Integer j = 0; j < PAccount.SubAccountList[i].SubAccountList.size(); j++) {
                                            PAccount.SubAccountList[i].SubAccountList[j].Container.ERP7__Amount__c = PAccount.SubAccountList[i].SubAccountList[j].value;
                                            PAccount.SubAccountList[i].SubAccountList[j].NContainer.ERP7__Amount__c = 0 - PAccount.SubAccountList[i].SubAccountList[j].value;
                                        }
                                        /*for (AccountGroup AG: PAccount.SubAccountList[i].SubAccountList) {
                                            for (String s: AG.FywiseValues.keyset()) {
                                                Map < integer, Decimal > AV = new Map < integer, Decimal > (AG.FywiseValues.get(s));
                                                Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                                                for (Integer aVal: AV.keyset()) {
                                                    ERP7__Transaction__c trans = new ERP7__Transaction__c();
                                                    trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                                                    if (BSDInstance.multiCurrencyEnabled) trans.put('CurrencyIsoCode', BSDInstance.isoCode);
                                                    setAV.put(aVal, trans);
                                                }
                                                AG.GContainerFyWValues.put(s, setAV);
                                            }
                                        }*/
    
                                    }
                                    if (sflag) {
                                        PAccount.SubAccountList[i].SubAccountList.add(AccountNameValue);
                                    }
                                    PAccount.SubAccountList[i].value += ClosingBalance;
                                    flag = false;
                                }
                            }
    
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
                                PAccount.SubAccountList[i].Container.ERP7__Amount__c = PAccount.SubAccountList[i].value;
                                PAccount.SubAccountList[i].NContainer.ERP7__Amount__c = 0 - PAccount.SubAccountList[i].value;
                            }
    
                            /*for (AccountGroup AG: PAccount.SubAccountList) {
                                for (String s: AG.FywiseValues.keyset()) {
                                    Map < integer, Decimal > AV = new Map < integer, Decimal > (AG.FywiseValues.get(s));
                                    Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                                    for (Integer aVal: AV.keyset()) {
                                        ERP7__Transaction__c trans = new ERP7__Transaction__c();
                                        trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                                        if (BSDInstance.multiCurrencyEnabled) trans.put('CurrencyIsoCode', BSDInstance.isoCode);
                                        setAV.put(aVal, trans);
                                    }
                                    AG.GContainerFyWValues.put(s, setAV);
                                }
                            }*/
                            if (flag) {
                                PAccount.SubAccountList.add(subAccGrp);
                            }
    
                            PAccount.value += ClosingBalance;
                            PAccount.Container.ERP7__Amount__c = PAccount.value;
                            PAccount.NContainer.ERP7__Amount__c = 0 - PAccount.value;
                        }
                    }
                }
            }
            
            BSDInstance = addCurrentYearEarnings(BSDInstance);
            BSDInstance = buildAccountsRendereingMap(BSDInstance);
            if (BSDInstance.FinancialYearWiseAssetMap != null && BSDInstance.FinancialYearWiseAssetMap.get('Assets') != null){
                BSDInstance.Total_Assets.ERP7__Opening_Balance__c = BSDInstance.FinancialYearWiseAssetMap.get('Assets').value;
                system.debug('Total_Assets.ERP7__Opening_Balance__c set here~>'+BSDInstance.Total_Assets.ERP7__Opening_Balance__c);
            } 
            if (BSDInstance.FinancialYearWiseAssetMap != null && BSDInstance.FinancialYearWiseAssetMap.get('Equity') != null && BSDInstance.FinancialYearWiseAssetMap.get('Liability') != null){
                BSDInstance.Total_Liab_Equity.ERP7__Opening_Balance__c = BSDInstance.FinancialYearWiseAssetMap.get('Liability').value + BSDInstance.FinancialYearWiseAssetMap.get('Equity').value;
                system.debug('Total_Liab_Equity.ERP7__Opening_Balance__c set here~>'+BSDInstance.Total_Assets.ERP7__Opening_Balance__c);
            }
            List < W3 > FW = new List < W3 > ();
    
            return BSDInstance;
        } catch (Exception e) {
            BSDInstance.errMsg = String.valueOf(e);
            system.debug('BSDInstance.errMsg : ' + BSDInstance.errMsg);
            return BSDInstance;
        }
        // return BSDInstance;  
    }
    
    public class W1 {
        @AuraEnabled
        public String W1COA {
            get;
            set;
        }
        @AuraEnabled
        public List < ERP7__Transaction__c > W1trans {
            get;
            set;
        }
        public W1() {
            W1trans = new List < ERP7__Transaction__c > ();
        }
    }
    
    public class W2 {
        @AuraEnabled
        public String W2COA {
            get;
            set;
        }
        @AuraEnabled
        public List < ERP7__Transaction__c > W2trans {
            get;
            set;
        }
        @AuraEnabled
        public List < W1 > innerWrapperW1 {
            get;
            set;
        }
    
        public W2() {
            innerWrapperW1 = new List < W1 > ();
            W2trans = new List < ERP7__Transaction__c > ();
        }
    }
    
    public class W3 {
        @AuraEnabled
        public String W3COA {
            get;
            set;
        }
        @AuraEnabled
        public List < W2 > innnerWrpperW2 {
            get;
            set;
        }
        @AuraEnabled
        public List < ERP7__Transaction__c > W3trans {
            get;
            set;
        }
    }
    
    public static BalanceSheetLightning buildAccountsRendereingMap(BalanceSheetLightning BSDInstance) {
        BalanceSheetLightning BSD = BSDInstance;
        try {
            for (String s: BSD.balanceSheetAccounts.keyset()) {
                BSD.balanceSheetAccounts.put(s, BSD.FinancialYearWiseAssetMap.containskey(s));
            }
            return BSD;
        } catch (Exception e) {
            BSD.errMsg = String.valueOf(e.getMessage()) + String.valueOf(e.getLineNumber());
            return BSD;
        }
    }
    
    public static BalanceSheetLightning addCurrentYearEarnings(BalanceSheetLightning b) {
        BalanceSheetLightning BSD = b;
        try {
            Boolean IsmultiCurrencyEnabled;
            String isoCode;
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if (IsmultiCurrencyEnabled) {
                isoCode = (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
    
            AccountGroup ParentAccount = new AccountGroup();
            if (IsmultiCurrencyEnabled) {
                ParentAccount.Container.put('CurrencyIsoCode', isoCode);
                ParentAccount.NContainer.put('CurrencyIsoCode', isoCode);
            }
            List < AccountGroup > AccountNameValueList = new List < AccountGroup > ();
            List < AccountGroup > SubAccountList = new List < AccountGroup > ();
            List < AccountGroup > subAccsList = new List < AccountGroup > ();
            Decimal Income = (BSD.FyWiseIncomeMap.get('Income_Revenue') != null) ?
                BSD.FyWiseIncomeMap.get('Income_Revenue') : 0.00;
            Decimal Expense = (BSD.FyWiseExpenseMap.get('Expense') != null) ? BSD.FyWiseExpenseMap.get('Expense') : 0.00;
            Decimal TotalEarnings = Income - Expense; //(Income-Expense) 
            AccountGroup AccountNameValue = AccountGroup3(BSD.RE_COA, BSD.RE_COA, TotalEarnings, false); // new AccountGroup(RE_COA,TotalEarnings,false); 
            if (IsmultiCurrencyEnabled) {
                AccountNameValue.Container.put('CurrencyIsoCode', isoCode);
                AccountNameValue.NContainer.put('CurrencyIsoCode', isoCode);
            }
            AccountNameValueList = new List < AccountGroup > ();
            AccountNameValueList.add(AccountNameValue);
            AccountGroup subAccGrp = AccountGroup1(BSD.RE_COA, BSD.RE_COA, TotalEarnings, AccountNameValueList, isoCode); //new AccountGroup(RE_COA,TotalEarnings,AccountNameValueList); 
            if (IsmultiCurrencyEnabled) {
                subAccGrp.Container.put('CurrencyIsoCode', isoCode);
                subAccGrp.NContainer.put('CurrencyIsoCode', isoCode);
            }
            if (BSD.FinancialYearWiseAssetMap.get('Liability') != null)
                if (BSD.FinancialYearWiseAssetMap.get('Equity') == null) {
                    subAccsList = new List < AccountGroup > ();
                    subAccsList.add(subAccGrp);
                    ParentAccount = AccountGroup1('Equity', BSD.RE_COA, TotalEarnings, subAccsList, isoCode); //new AccountGroup('Equity', TotalEarnings,subAccsList);
                    if (IsmultiCurrencyEnabled) {
                        ParentAccount.Container.put('CurrencyIsoCode', isoCode);
                        ParentAccount.NContainer.put('CurrencyIsoCode', isoCode);
                    }
                    BSD.FinancialYearWiseAssetMap.put('Equity', ParentAccount);
                } else {
    
                    AccountGroup PAccount = BSD.FinancialYearWiseAssetMap.get('Equity');
                    if (IsmultiCurrencyEnabled) {
                        PAccount.Container.put('CurrencyIsoCode', isoCode);
                        PAccount.NContainer.put('CurrencyIsoCode', isoCode);
                    }
                    if (PAccount.SubAccountList != null && PAccount.SubAccountList.size() > 0) {
                        PAccount.SubAccountList.add(subAccGrp);
                    } else {
                        PAccount.SubAccountList = subAccsList;
                    }
                    PAccount.value += TotalEarnings;
                }
            return BSD;
        } catch (Exception e) {
            BSD.errMsg = String.valueOf(e.getMessage()) + String.valueOf(e.getLineNumber());
            return BSD;
        }
    
    }
    
    public static string getRE_AccountName(String OrgId) {
        try {
            return 'Equity';
        } catch (Exception e) {
            return 'Net Profit'; //[Select Name From ERP7__Chart_of_Accounts__c Where  ERP7__Account_Type__c = 'Retained_Earnings' limit 1].Name;//Organisation__c=:OrgId AND
    
        }
    
    }
    
    public static BalanceSheetLightning BuildMOnthMap(BalanceSheetLightning m) {
        BalanceSheetLightning BSD = m;
        BSD.IntegerToMonthName = new Map < Integer, String > ();
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
            'MAR',
            'APR',
            'MAY',
            'JUN',
            'JUL',
            'AUG',
            'SEP',
            'OCT',
            'NOV',
            'DEC'
        };
        BSD.monthNames = new List < String > ();
        BSD.monthNames = MonthNames;
        for (Integer i = 0; i <= 11; i++)
            BSD.IntegerToMonthName.put(i + 1, MonthNames[(i - 1) + BSD.mon]);
        return BSD;
    }
    
    @AuraEnabled
    public Static BalanceSheetLightning buildConditions(BalanceSheetLightning b) {
        BalanceSheetLightning BSD = b;
        BSD.FiscalYearQuarter = new Map < String, String > ();
        BSD.FiscalYearQuarter.put('1', '= THIS_FISCAL_YEAR');
        BSD.FiscalYearQuarter.put('2', '>= LAST_FISCAL_YEAR AND ERP7__General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        BSD.FiscalYearQuarter.put('3', '>= LAST_N_FISCAL_YEARS:2 AND ERP7__General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        BSD.FiscalYearQuarter.put('4', '= THIS_FISCAL_QUARTER');
        BSD.FiscalYearQuarter.put('5', '= NEXT_FISCAL_QUARTER OR ERP7__General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        BSD.FiscalYearQuarter.put('6', '= NEXT_FISCAL_QUARTER');
        BSD.FiscalYearQuarter.put('7', '= LAST_FISCAL_QUARTER OR ERP7__General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        /*Fiscal Year*/
        BSD.FiscalYear = new Map < String, String > ();
        BSD.FiscalYear.put('1', 'Startdate = THIS_FISCAL_YEAR');
        BSD.FiscalYear.put('2', 'Startdate >= LAST_FISCAL_YEAR AND Startdate <= THIS_FISCAL_YEAR');
        BSD.FiscalYear.put('3', 'Startdate >= LAST_N_FISCAL_YEARS:2 AND Startdate <= THIS_FISCAL_YEAR');
        BSD.FiscalYear.put('4', 'Startdate = THIS_FISCAL_QUARTER');
        BSD.FiscalYear.put('5', 'Startdate <= NEXT_FISCAL_QUARTER AND Startdate >= THIS_FISCAL_QUARTER');
        BSD.FiscalYear.put('6', 'Startdate = NEXT_FISCAL_QUARTER');
        BSD.FiscalYear.put('7', 'StartDate >= LAST_FISCAL_QUARTER AND StartDate <= THIS_FISCAL_QUARTER ');
        return BSD;
    
    }
    
    @AuraEnabled
    public static AccountGroup AccountGroup1(String AccName, String subName, Decimal val, List < AccountGroup > subAcclist, String IScode) {
        system.debug('AccountGroup1 called');
        AccountGroup AGroup = new AccountGroup();
        AGroup.Name = AccName;
        AGroup.subName = subName;
        AGroup.value = val;
        AGroup.SubAccountList = subAcclist;
        AGroup.Container = new ERP7__Transaction__c();
        AGroup.Container.ERP7__Amount__c = val.setscale(2);
        AGroup.NContainer = new ERP7__Transaction__c();
        AGroup.NContainer.ERP7__Amount__c = 0 - val.setscale(2);
        Map < String, Map < Integer, decimal >> Fy = new Map < String, Map < Integer, decimal >> ();
        String isoCode;
        if (IScode != null) isoCode = IScode;
        /*Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(multiCurrencyEnabled){
            isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
        }*/
        for (AccountGroup AG: AGroup.SubAccountList) {
            for (String s: AG.FywiseValues.keyset()) {
                Map < integer, Decimal > AV = new Map < integer, Decimal > (AGroup.FywiseValues.get(s));
                Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                for (Integer aVal: AV.keyset()) {
                    ERP7__Transaction__c trans = new ERP7__Transaction__c();
                    trans.ERP7__Amount__c = AV.get(aVal); //(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                    if (AG.IsmultiCurrencyEnabled && isoCode != '' && isoCode != null) trans.put('CurrencyIsoCode', isoCode);
                    setAV.put(aVal, trans);
                }
                AG.GContainerFyWValues.put(s, setAV);
            }
        }
        for (AccountGroup AG: AGroup.SubAccountList) {
            AG.Container.ERP7__Amount__c = AG.Value.setscale(2);
            AG.NContainer.ERP7__Amount__c = AG.Value.setscale(2); // 0-AG.Value.setscale(2);
        }
        return AGroup;
    }
    
    @AuraEnabled
    public static AccountGroup AccountGroup2(String AccName, String subName, Map < String, Map < Integer, decimal >> val, List < AccountGroup > subAcclist, Boolean IsmultiCurrencyEnabled) {
        system.debug('AccountGroup2 called');
        AccountGroup AGroup = new AccountGroup();
        AGroup.Name = AccName;
        AGroup.subName = subName;
        AGroup.FywiseValues = val;
        AGroup.SubAccountList = subAcclist;
        AGroup.Container = new ERP7__Transaction__c();
        AGroup.NContainer = new ERP7__Transaction__c();
        String isoCode;
        Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if (multiCurrencyEnabled) {
            isoCode = (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
        }
        for (AccountGroup AG: AGroup.SubAccountList) {
            for (String s: AG.FywiseValues.keyset()) {
                Map < integer, Decimal > AV = new Map < integer, Decimal > (AGroup.FywiseValues.get(s));
                Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                for (Integer aVal: AV.keyset()) {
                    ERP7__Transaction__c trans = new ERP7__Transaction__c();
                    trans.ERP7__Amount__c = AV.get(aVal); //(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                    if (AG.IsmultiCurrencyEnabled && isoCode != '' && isoCode != null) trans.put('CurrencyIsoCode', isoCode);
                    setAV.put(aVal, trans);
                }
                AG.GContainerFyWValues.put(s, setAV);
            }
        }
        for (String FWV: val.keyset()) {
            Map < integer, Decimal > AV = new Map < integer, Decimal > (AGroup.FywiseValues.get(FWV));
            Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
            for (Integer aVal: AV.keyset()) {
                ERP7__Transaction__c trans = new ERP7__Transaction__c();
                trans.ERP7__Amount__c = AV.get(aVal); //(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                if (IsmultiCurrencyEnabled && isoCode != '' && isoCode != null) trans.put('CurrencyIsoCode', isoCode);
                setAV.put(aVal, trans);
            }
            AGroup.GContainerFyWValues.put(FWV, setAV);
        }
        for (AccountGroup AG: AGroup.SubAccountList) {
            AG.Container.ERP7__Amount__c = AG.Value.setscale(2);
            AG.NContainer.ERP7__Amount__c = AG.Value.setscale(2); // 0-AG.Value.setscale(2);
        }
        return AGroup;
    }
    @AuraEnabled
    
    public static AccountGroup AccountGroup3(String AccName, String subName, Decimal val, Boolean flag) {
        system.debug('AccountGroup3 called');
        AccountGroup AG = new AccountGroup();
        AG.Name = AccName;
        AG.value = val;
        AG.subName = subName;
        AG.contraFlag = flag;
        AG.Container = new ERP7__Transaction__c();
        AG.Container.ERP7__Amount__c = val.setscale(2);
        AG.NContainer = new ERP7__Transaction__c();
        AG.NContainer.ERP7__Amount__c = val.setscale(2); // 0-val.setscale(2);
        return AG;
    }
    
    @AuraEnabled
    public static AccountGroup AccountGroup4(String AccName, String subName, Map < String, Map < Integer, decimal >> val, Boolean flag) {
        AccountGroup AGroup = new AccountGroup();
        AGroup.Name = AccName;
        AGroup.subName = subName;
        AGroup.FywiseValues = val;
        AGroup.contraFlag = flag;
        for (String FWV: val.keyset()) {
            Map < integer, Decimal > AV = new Map < integer, Decimal > (AGroup.FywiseValues.get(FWV));
            Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
            for (Integer aVal: AV.keyset()) {
                ERP7__Transaction__c trans = new ERP7__Transaction__c();
                trans.ERP7__Amount__c = AV.get(aVal); //(AV.get(aVal) >= 0 )? AV.get(aVal) : (0-AV.get(aVal));
                setAV.put(aVal, trans);
            }
            AGroup.GContainerFyWValues.put(FWV, setAV);
        }
        AGroup.Container = new ERP7__Transaction__c();
        AGroup.NContainer = new ERP7__Transaction__c();
        return AGroup;
    }
    
    public class AccountGroup {
        @AuraEnabled
        public String Name {
            get;
            set;
        }
        @AuraEnabled
        public String subName {
            get;
            set;
        }
        @AuraEnabled
        public decimal Value {
            get;
            set;
        }
        @AuraEnabled
        public List < AccountGroup > SubAccountList {
            get;
            set;
        }
        @AuraEnabled
        public Boolean contraFlag {
            get;
            set;
        }
        @AuraEnabled
        public Map < String, Map < Integer, decimal >> FywiseValues {
            get;
            set;
        }
        @AuraEnabled
        public Map < String, Map < Integer, ERP7__Transaction__c >> GContainerFyWValues {
            get;
            set;
        }
        @AuraEnabled
        public ERP7__Transaction__c Container {
            get;
            set;
        }
        @AuraEnabled
        public ERP7__Transaction__c NContainer {
            get;
            set;
        }
        @AuraEnabled
        public Boolean IsmultiCurrencyEnabled {
            get;
            set;
        }
        @AuraEnabled public String isoCode {
            get;
            set;
        }
    
        /*Instance Intialization Block*/
        {
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if (IsmultiCurrencyEnabled) {}
            Name = subName = '';
            value = 0.00;
            SubAccountList = new List < AccountGroup > ();
            contraFlag = false;
            FywiseValues = new Map < String, Map < Integer, decimal >> ();
            GContainerFyWValues = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
            this.Container = new ERP7__Transaction__c();
            this.Container.ERP7__Amount__c = 0.00;
            this.NContainer = new ERP7__Transaction__c();
            this.NContainer.ERP7__Amount__c = 0.00;
        }
        public AccountGroup() {}
        public AccountGroup(String AccName, Decimal val, List < AccountGroup > subAcclist) {
            this.Name = AccName;
            this.value = val;
            this.SubAccountList = subAcclist;
            this.Container = new ERP7__Transaction__c();
            this.Container.ERP7__Amount__c = val.setscale(2);
            this.NContainer = new ERP7__Transaction__c();
            this.NContainer.ERP7__Amount__c = 0 - val.setscale(2);
            if (IsmultiCurrencyEnabled) {}
            Map < String, Map < Integer, decimal >> Fy = new Map < String, Map < Integer, decimal >> ();
            for (AccountGroup AG: this.SubAccountList) {
                for (String s: AG.FywiseValues.keyset()) {
                    Map < integer, Decimal > AV = new Map < integer, Decimal > (this.FywiseValues.get(s));
                    Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                    for (Integer aVal: AV.keyset()) {
                        ERP7__Transaction__c trans = new ERP7__Transaction__c();
                        trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                        if (AG.IsmultiCurrencyEnabled && isoCode != '' && isoCode != null) trans.put('CurrencyIsoCode', isoCode);
                        setAV.put(aVal, trans);
                    }
                    AG.GContainerFyWValues.put(s, setAV);
                }
            }
            for (AccountGroup AG: this.SubAccountList) {
                AG.Container.ERP7__Amount__c = AG.Value.setscale(2);
                AG.NContainer.ERP7__Amount__c = 0 - AG.Value.setscale(2);
            }
        }
    
    
        public AccountGroup(String AccName, Map < String, Map < Integer, decimal >> val, List < AccountGroup > subAcclist) {
            this.Name = AccName;
            this.FywiseValues = val;
            this.SubAccountList = subAcclist;
            this.Container = new ERP7__Transaction__c();
            this.NContainer = new ERP7__Transaction__c();
    
            if (IsmultiCurrencyEnabled) {}
    
            for (AccountGroup AG: this.SubAccountList) {
                for (String s: AG.FywiseValues.keyset()) {
                    Map < integer, Decimal > AV = new Map < integer, Decimal > (this.FywiseValues.get(s));
                    Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                    for (Integer aVal: AV.keyset()) {
                        ERP7__Transaction__c trans = new ERP7__Transaction__c();
                        trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                        if (AG.IsmultiCurrencyEnabled && isoCode != '' && isoCode != null) trans.put('CurrencyIsoCode', isoCode);
                        setAV.put(aVal, trans);
                    }
                    AG.GContainerFyWValues.put(s, setAV);
                }
            }
            for (String FWV: val.keyset()) {
                Map < integer, Decimal > AV = new Map < integer, Decimal > (this.FywiseValues.get(FWV));
                Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                for (Integer aVal: AV.keyset()) {
                    ERP7__Transaction__c trans = new ERP7__Transaction__c();
                    trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                    if (IsmultiCurrencyEnabled && isoCode != '' && isoCode != null) trans.put('CurrencyIsoCode', isoCode);
                    setAV.put(aVal, trans);
                }
                this.GContainerFyWValues.put(FWV, setAV);
            }
            for (AccountGroup AG: this.SubAccountList) {
                AG.Container.ERP7__Amount__c = AG.Value.setscale(2);
                AG.NContainer.ERP7__Amount__c = 0 - AG.Value.setscale(2);
            }
        }
    
        public AccountGroup(String AccName, Decimal val, Boolean flag) {
            this.Name = AccName;
            this.value = val;
            this.contraFlag = flag;
            this.Container = new ERP7__Transaction__c();
            this.Container.ERP7__Amount__c = val.setscale(2);
            this.NContainer = new ERP7__Transaction__c();
            this.NContainer.ERP7__Amount__c = 0 - val.setscale(2);
        }
        public AccountGroup(String AccName, Map < String, Map < Integer, decimal >> val, Boolean flag) {
            this.Name = AccName;
            this.FywiseValues = val;
            this.contraFlag = flag;
            for (String FWV: val.keyset()) {
                Map < integer, Decimal > AV = new Map < integer, Decimal > (this.FywiseValues.get(FWV));
                Map < integer, ERP7__Transaction__c > setAV = new Map < integer, ERP7__Transaction__c > ();
                for (Integer aVal: AV.keyset()) {
                    ERP7__Transaction__c trans = new ERP7__Transaction__c();
                    trans.ERP7__Amount__c = (AV.get(aVal) >= 0) ? AV.get(aVal) : (0 - AV.get(aVal));
                    setAV.put(aVal, trans);
                }
                this.GContainerFyWValues.put(FWV, setAV);
            }
            this.Container = new ERP7__Transaction__c();
            this.NContainer = new ERP7__Transaction__c();
    
            if (IsmultiCurrencyEnabled) {}
        }
    
    
    }
    
    public class selectOptions {
        @AuraEnabled public String label {
            get;
            set;
        }
        @AuraEnabled public String value {
            get;
            set;
        }
        @AuraEnabled public Boolean selected {
            get;
            set;
        }
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab;
            value = val;
            selected = sel;
        }
    }
    
}