/******************************************************************************************
*  ERP_MARK7 -  IncomeStatement lightning Controller
*
*  Purpose : Generates Income Statement for Given Date limit.
*  Author  : Aqxolt - Irfan Khan
*  Started Date    : 2019-09-26
*  End Date        :
*  Version : 1.0
*  Project : ERP_MARK7
*  
*      - This Class generates Income Statement for Organisation Chart of accounts 
*      
*  
*  Modification History
*  Date    Who    Description  
*  yyyy-mm-dd - XX - xxxxxxxxxxxxxxxxxxxxxxxxxxxx
*
* 
* Chnages made by - Moin
* Reason - query was returning the day-only in gmt format not with login usewr time wzowne
* fix applied - add convertTimezone  
********************************************************************************************/
public With Sharing class IncomeStatementLightning{ 
    @AuraEnabled
    Public String       CurrencyISO                                             { get; set; }
    
    @AuraEnabled public List<Selectoptions>     getPickList                                         { get; set; }  @AuraEnabled public List<String>     CurrencyTypes                                  { get; set;}
   
    @AuraEnabled
    public List<Selectoptions> getPickListFY                                           { get; set; }
  
    @AuraEnabled
    public date                 transSdate                                      { get; set; }
    
    @AuraEnabled
    public date                 transEdate                                      { get; set; }
    
     @AuraEnabled
    public String                 SelectedCurrency                                      { get; set; }
   
    @AuraEnabled  
    public List<String> monthNames                                              { get; set; }
   
    @AuraEnabled 
    public List<String> quarterNames                                            { get; set; }  @AuraEnabled public List<W3> FinancialAccountIncomeStmt2Wrapper                          { get; set; } @AuraEnabled public List<W3> FinancialCOGSExpenseStmt2Wrapper                         { get; set; } @AuraEnabled public List<W3> FinancialAccountExpenseStmt2Wrapper                          { get; set; } @AuraEnabled public List<W2> TotalIncomeStmt2Wrapper                                     { get; set; } @AuraEnabled public List<W2> TotalNetProfitStmt2Wrapper                                  { get; set; } @AuraEnabled public List<W2> TotalExpenseStmt2Wrapper                                    { get; set; } @AuraEnabled public List<W2> TotalCOGSStmt2Wrapper                                        { get; set; }
    @AuraEnabled
    public List<Data> datalist                                                   { get; set; }
    @AuraEnabled
    public String revdisplayaccsMap                                              { get; set; }
    @AuraEnabled
    public String expdisplayaccsMap                                              { get; set; }
    @AuraEnabled
    public String ErrMsg                                                         { get; set; }
    @AuraEnabled
    public Map<String,AccountGroup> FinancialYearWiseAccountMap                  { get; set; }
    @AuraEnabled
    public List<AccountGroup> RevenueValues                                      { get; set; }
    @AuraEnabled
    public List<AccountGroup> expenseValues                                      { get; set; }
    @AuraEnabled
    public ERP7__Transaction__c Select_Organisation                              { get; set; }
    @AuraEnabled
    public String endDate                                                        { get; set; }
    @AuraEnabled
    public string startDate                                                      { get; set; }
    @AuraEnabled
    public String minDate                                                             { get; set; }
    @AuraEnabled
    public String max_Date                                                            { get; set; }
    @AuraEnabled
    public Map<Id,ERP7__Chart_of_Accounts__c> chart_Of_Accounts                       { get; set; }
    @AuraEnabled
    public ERP7__Chart_of_Accounts__c Net_Profit                                      { get; set; }
    @AuraEnabled
    public ERP7__Chart_of_Accounts__c Total_Revenue                                   { get; set; } 
    @AuraEnabled
    public ERP7__Chart_of_Accounts__c Total_Expense                                   { get; set; }
    @AuraEnabled
    public Map<String,string> displayaccsMap                                          { get; set; }
    @AuraEnabled
    public Map<String,Map<String,Map<Integer,decimal>>> FinancialAccountIncomeStmt    { get; set; }
    @AuraEnabled
    public Map<String,Map<String,Map<Integer,ERP7__Transaction__c>>> FinancialAccountIncomeStmt2   { get; set; }
    @AuraEnabled
    public Map<String,Map<String,Map<Integer,decimal>>> FinancialAccountExpenseStmt   { get; set; }
    @AuraEnabled
    public Map<String,Map<String,Map<Integer,decimal>>> FinancialCOGSExpenseStmt      { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,decimal>> TotalIncomeStmt                           { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,decimal>> TotalExpenseStmt                          { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,decimal>> TotalCOGSStmt                             { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,decimal>> TotalNetProfitStmt                        { get; set; }
    @AuraEnabled
    public Map<String,Map<String,Map<Integer,ERP7__Transaction__c>>> FinancialAccountExpenseStmt2   { get; set; }
    @AuraEnabled
    public Map<String,Map<String,Map<Integer,ERP7__Transaction__c>>> FinancialCOGSExpenseStmt2      { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalIncomeStmt2                           { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalExpenseStmt2                          { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalCOGSStmt2                             { get; set; }
    @AuraEnabled
    public Map<String,Map<Integer,ERP7__Transaction__c>> TotalNetProfitStmt2                        { get; set; } @AuraEnabled public String newOrganisationId                                                   { get; set; } @AuraEnabled public string yfields                                                             { get; set; }
    @AuraEnabled
    public Map<String,Map<String,decimal>> CurrentChartofAccounts                     { get; set; }
    @AuraEnabled public String SelectedFy                                                          { get; set; } @AuraEnabled public  Map<String,Integer> FinancialYears                                        { get; set; }
    @AuraEnabled
    public string startfy                                                             { get; set; }
    @AuraEnabled
    public string endfy                                                               { get; set; }
    @AuraEnabled
    public Boolean  showChart                                                         { get; set; }
    @AuraEnabled public String FyYear                                                              { get; set; } @AuraEnabled public String Colorset                                                            { get; set; } @AuraEnabled public set<String> DataType                                                       { get; set; }
    @AuraEnabled
    public Boolean ShowFyWise                                                         { get; set; }
    @AuraEnabled
    public Boolean ShowMonthly                                                        { get; set; }
    @AuraEnabled
    public Boolean ShowQuartely                                                       { get; set; }
    @AuraEnabled public List<String> FYNames                                                       { get; set; } @AuraEnabled public String ChartTitle                                                          { get; set; }
    @AuraEnabled public List<string> Colors                                                        { get; set; }  @AuraEnabled public Map<string,boolean> IncomeStatementAccounts                                { get; set; }
    @AuraEnabled
    public String YearorQuarter                                                       { get; set; }
    @AuraEnabled
    public Map<Integer,String> IntegerToMonthName                                     { get; set; }
    @AuraEnabled public Map<Integer,String> IntegerToQuarterName                                   { get; set; } @AuraEnabled public Map<String,String> YearToString                                            { get; set; }
    @AuraEnabled public Boolean multiCurrencyEnabled                                                  { get; set; } @AuraEnabled public String isoCode                                                            { get; set; }
    @AuraEnabled
    public Integer mon                                                                { get; set;}
    @AuraEnabled
    public Map<String,String> FiscalYearQuarter                                       { get; set; }
    @AuraEnabled
    public Decimal currencyRate                                                       { get; set; } 
    @AuraEnabled
    public String userIsoCode                                                         { get; set; }
    
   
    
   
     @AuraEnabled
     public static IncomeStatementLightning fetchDetails( String Ins, String  selectedIso) {
        IncomeStatementLightning IncomeInstance = new IncomeStatementLightning();
        IncomeInstance.Select_Organisation = new ERP7__Transaction__c();
        try{
        if(Ins != null && Ins != 'null'){ 
            IncomeInstance = ( IncomeStatementLightning ) JSON.deserialize(Ins, IncomeStatementLightning.class);
           
           }
         IncomeInstance.getPickList = new List<selectOptions>();
         List<String> picklist = new List<String>();
             picklist.add('--None--');
             Schema.DescribeFieldResult fieldResult = ERP7__Transaction__c.ERP7__Industry__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {picklist.add(f.getLabel());}
             for(integer i=0;i<=picklist.size()-1;i++)
            {
            IncomeInstance.getPickList.add(new selectOptions(picklist[i], picklist[i]));
            }
           /*'PickList'+IncomeInstance.getPickList);*/
            // IncomeInstance.currencyRate = 91;
            //IncomeInstance.userIsoCode  = 'INR';
            
        IncomeInstance.multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
          if(selectedIso != null) IncomeInstance.CurrencyISO=selectedIso;
                else IncomeInstance.CurrencyISO =  UserInfo.getDefaultCurrency();
            if(IncomeInstance.multiCurrencyEnabled){ IncomeInstance.isoCode= (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode'); IncomeInstance.userIsoCode = IncomeInstance.CurrencyISO; String iso  =IncomeInstance.userIsoCode; String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso'; IncomeInstance.currencyRate= (Decimal) Database.Query(q)[0].get('conversionRate');    }
            else{
                IncomeInstance.userIsoCode=IncomeInstance.CurrencyISO;
                IncomeInstance.currencyRate=1;
            }
            /*'userISO=>'+IncomeInstance.userIsoCode); 
            'rate=>'+IncomeInstance.currencyRate); 
            'corporateISo=>'+IncomeInstance.isoCode); */
            IncomeInstance.SelectedCurrency=IncomeInstance.userIsoCode;
            IncomeInstance.getPickListFY = new List<selectOptions>();
        IncomeInstance.getPickListFY.add(new selectOptions('Fiscal year', '1', true));
        IncomeInstance.getPickListFY.add(new selectOptions('Current FY', '1'));
        IncomeInstance.getPickListFY.add(new selectOptions('Current and Previous FY', '2'));
        IncomeInstance.getPickListFY.add(new selectOptions('Current and Previous 2 FY', '3'));
        IncomeInstance.getPickListFY.add(new selectOptions('Fiscal Quarter', '4', true));
        IncomeInstance.getPickListFY.add(new selectOptions('Current FQ', '4'));
        IncomeInstance.getPickListFY.add(new selectOptions('Current and Next FQ', '5'));
        IncomeInstance.getPickListFY.add(new selectOptions('Next FQ', '6'));
        IncomeInstance.getPickListFY.add(new selectOptions('Current and Previous FQ', '7'));
       
        IncomeInstance.multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); 
        if(IncomeInstance.multiCurrencyEnabled){ IncomeInstance.isoCode= (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode'); }
        IncomeInstance.FYNames = new List<String>();
        IncomeInstance.FinancialYearWiseAccountMap = new Map < String, AccountGroup > ();
        IncomeInstance.CurrentChartofAccounts = new Map < String, Map < String, decimal >> ();
        //IncomeInstance.Select_Organisation = new ERP7__Transaction__c();
       
        IncomeInstance.Total_Revenue = new ERP7__Chart_of_Accounts__c();
        IncomeInstance.Total_Expense = new ERP7__Chart_of_Accounts__c();
        IncomeInstance.FiscalYearQuarter = new Map < String, String > ();
        IncomeInstance = buildConditions(JSON.serialize(IncomeInstance));
        IncomeInstance.SelectedFy = '1';
        Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id =: Userinfo.getOrganizationId()].FiscalYearStartMonth;
        List < Period > FiscalPeriod = [SELECT StartDate, EndDate FROM Period WHERE Type = 'Year'
                                        AND StartDate <= TODAY AND EndDate >= TODAY
                                       ];
        IncomeInstance.mon = FiscalYearStartMonth;
        Date mydate = system.today().adddays(-365);
        date end_Date = system.today();
        
        IncomeInstance.minDate = mydate.format();
        IncomeInstance.startDate = mydate.format();
        IncomeInstance.endDate = end_Date.format();
            
            
            
            
        date start_date1 = Date.parse(IncomeInstance.StartDate);
        date end_date1 = Date.parse(IncomeInstance.endDate);
        if( IncomeInstance.transEdate == null )IncomeInstance.transEdate = end_date1;
        if( IncomeInstance.transEdate != null )end_date1 = IncomeInstance.transEdate ;
         
        if( IncomeInstance.transSdate == null )IncomeInstance.transSdate = start_date1;
        if( IncomeInstance.transSdate != null )start_date1 = IncomeInstance.transSdate ;
        
        IncomeInstance.max_Date = end_Date.format();
        IncomeInstance.YearorQuarter = 'Fyear';//'Fyear';
        IncomeInstance.showChart = false;
        IncomeInstance.ShowFyWise = true;
        IncomeInstance.ShowMonthly = false;
        IncomeInstance.ShowQuartely = false;
        IncomeInstance.FyYear = 'data1,data2,data3';
        IncomeInstance.displayaccsMap = new Map < String, String > ();
        IncomeInstance.displayaccsMap.put('Income_Revenue', 'Operating Income');
        IncomeInstance.displayaccsMap.put('Expense', 'Operating Expenses');
        IncomeInstance.displayaccsMap.put('Sales', 'Net Sales');
        IncomeInstance.expdisplayaccsMap = 'Operating Expenses';
        IncomeInstance.revdisplayaccsMap = 'Operating Income';
        IncomeInstance.IntegerToMonthName = new Map<integer, String>();
        IncomeInstance.IntegerToMonthName = BuildMOnthMap(FiscalYearStartMonth);
         
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
                'DEC'
                };
        IncomeInstance.monthNames = new List<String>();
        IncomeInstance.monthNames =  MonthNames;  
        IncomeInstance.IntegerToQuarterName = new Map < Integer, String > ();
        IncomeInstance.IntegerToQuarterName.put(1, 'Q-1');
        IncomeInstance.IntegerToQuarterName.put(2, 'Q-2');
        IncomeInstance.IntegerToQuarterName.put(3, 'Q-3');
        IncomeInstance.IntegerToQuarterName.put(4, 'Q-4');
        IncomeInstance.quarterNames = new List<String>(); 
        IncomeInstance.quarterNames.add('Q-1');IncomeInstance.quarterNames.add('Q-2');IncomeInstance.quarterNames.add('Q-3'); IncomeInstance.quarterNames.add('Q-4');
           
        Account Organisation = ERP7.UtilClass.getOrganisationByLogin_Employee();
            
           
        if(Organisation.Id != null ){
            if(IncomeInstance.Select_Organisation.ERP7__Organisation__c==null)IncomeInstance.Select_Organisation.ERP7__Organisation__c = Organisation.id;
            IncomeInstance.showChart = false;
            IncomeInstance.colors = new List < String > {
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
           //IncomeInstance = ComputeSelectedFyData(JSON.serialize(IncomeInstance));
           IncomeInstance.expenseValues = new List<AccountGroup>();
           IncomeInstance.RevenueValues = new List<AccountGroup>();
           IncomeInstance.expenseValues.add(IncomeInstance.FinancialYearWiseAccountMap.get('Expense')); 
           IncomeInstance.RevenueValues.add(IncomeInstance.FinancialYearWiseAccountMap.get('Income_Revenue'));
            /*'IncomeInstance.expenseValues'+IncomeInstance.expenseValues);*/
            //IncomeInstance=ComputeData(JSon.serialize(IncomeInstance));
            if(IncomeInstance.multiCurrencyEnabled){   IncomeInstance.Net_Profit.put('CurrencyIsoCode',IncomeInstance.CurrencyISO); IncomeInstance.Total_Revenue.put('CurrencyIsoCode',IncomeInstance.CurrencyISO); IncomeInstance.Total_Expense.put('CurrencyIsoCode',IncomeInstance.CurrencyISO);
           }
          }
          /*List<AccountGroup> expenseValues =IncomeInstance.expenseValues;
            for(integer i=0;i<expenseValues.size();i++){
                for(integer j=0;j<expenseValues[i].SubAccountList.size();j++){
                    decimal sum=0;
                    for(integer k=0;k<expenseValues[i].SubAccountList[j].SubAccountList.size();k++){
                        system.debug('Amount-->'+expenseValues[i].SubAccountList[j].SubAccountList[k].Container.ERP7__Amount__c);
                            sum+=expenseValues[i].SubAccountList[j].SubAccountList[k].Container.ERP7__Amount__c;
                        }
                    if(sum!=0) IncomeInstance.expenseValues[i].SubAccountList[j].Container.ERP7__Amount__c=sum;
                    system.debug('Expense-->'+IncomeInstance.expenseValues[i].SubAccountList[j].Container.ERP7__Amount__c);
                    /*'SUM'+sum);*
                }
            }
            
            
            
            List<AccountGroup> revenueValues =IncomeInstance.RevenueValues;
            for(integer i=0;i<revenueValues.size();i++){
                for(integer j=0;j<revenueValues[i].SubAccountList.size();j++){
                    decimal sum=0;
                    for(integer k=0;k<revenueValues[i].SubAccountList[j].SubAccountList.size();k++){
                            system.debug('Exp Amount-->'+revenueValues[i].SubAccountList[j].SubAccountList[k].Container.ERP7__Amount__c);
                            sum+=revenueValues[i].SubAccountList[j].SubAccountList[k].Container.ERP7__Amount__c;
                        }
                    system.debug('sum-->'+sum);
                    if(sum!=0) IncomeInstance.revenueValues[i].SubAccountList[j].Container.ERP7__Amount__c=sum;
                    system.debug('Revenue-->'+IncomeInstance.RevenueValues[i].SubAccountList[j].Container.ERP7__Amount__c);
                    /*'SUM'+sum);*
                }
            }*/
          return IncomeInstance; 
         }catch(Exception e){
                System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
                IncomeInstance.errMsg = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString();
                
                return IncomeInstance; 
            }
        
    }
     
    @AuraEnabled
     public static IncomeStatementLightning ComputeSelectedFyData(String Ins) {
         IncomeStatementLightning Instance = (IncomeStatementLightning)JSON.deserialize(Ins, IncomeStatementLightning.class);
         Boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
         String isoCode = '';
         if(IsmultiCurrencyEnabled){ isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode'); }
        //IncomeStatementLightning Instance = Ins1;  
        try{
        Instance.Total_Revenue = new ERP7__Chart_of_Accounts__c();
        Instance.Total_Expense = new ERP7__Chart_of_Accounts__c();
        Instance.Net_Profit = new ERP7__Chart_of_Accounts__c();
        Instance.FinancialYearWiseAccountMap = new Map < String, AccountGroup > ();
        Instance.FinancialYearWiseAccountMap.put('Income_Revenue', new AccountGroup());
        Instance.FinancialYearWiseAccountMap.put('Expense', new AccountGroup());
        
        Instance.chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c > ([SELECT Name, RecordTypeId, ERP7__isContra_Account__c,
                                                                   ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where RecordType.DeveloperName in ('Income_Revenue', 'Expense')
                                                                  ]); 
        if ((Instance.chart_Of_Accounts.size() == 0 || Instance.chart_Of_Accounts == null)) { Instance.ErrMsg = 'Error: No Chart of Accounts found.'; return Instance; }
        String qryFilter = '';
        if (Instance.Select_Organisation.ERP7__Organisation__c != null) qryFilter += ' AND ERP7__Organisation__c = \'' + Instance.Select_Organisation.ERP7__Organisation__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Customer__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Customer__c = \'' + Instance.Select_Organisation.ERP7__Customer__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Product__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Product__c = \'' + Instance.Select_Organisation.ERP7__Product__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Sales_Order__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Sales_Order__c = \'' + Instance.Select_Organisation.ERP7__Sales_Order__c + '\' ';
        
        if (Instance.Select_Organisation.ERP7__Project__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Project__c = \'' +Instance.Select_Organisation.ERP7__Project__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Supplier__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Supplier__c = \'' + Instance.Select_Organisation.ERP7__Supplier__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Employee__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Employee__c = \'' + Instance.Select_Organisation.ERP7__Employee__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Site__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Site__c = \'' + Instance.Select_Organisation.ERP7__Site__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Channel__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Channel__c = \'' + Instance.Select_Organisation.ERP7__Channel__c + '\' ';
        if (Instance.Select_Organisation.ERP7__Industry__c != null && Instance.Select_Organisation.ERP7__Industry__c != '' && Instance.Select_Organisation.ERP7__Industry__c != '--None--') qryFilter += ' AND ERP7__Transactions__r.ERP7__Industry__c = \'' + Instance.Select_Organisation.ERP7__Industry__c + '\' ';
        
        date start_date = Date.parse(Instance.StartDate);
        date end_date = Date.parse(Instance.endDate);
        if( Instance.transEdate == null )Instance.transEdate = end_date;
        if( Instance.transEdate != null )end_date = Instance.transEdate ;
         
        if( Instance.transSdate == null )Instance.transSdate = start_date;
        if( Instance.transSdate != null )start_date = Instance.transSdate ;
         
         
        String Query = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount' +
            ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
            ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Income_Revenue\',\'Expense\') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
            ' GROUP BY ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c limit 100';
        
        List < AggregateResult > BalanceSheetData = Database.query(Query);
        Set<Id> coaIds = new Set<Id>();
        for (AggregateResult bsd: BalanceSheetData) {
            coaIds.add(String.valueOf(bsd.get('AccountId')));       Decimal openingBal = (Instance.chart_Of_Accounts.get((ID) bsd.get('AccountId')) != null) ? Instance.chart_Of_Accounts.get((ID) bsd.get('AccountId')).ERP7__Opening_Balance__c : 0.00;        Decimal creditSum = 0.0;  Decimal debitsum = 0.0; Decimal ClosingBalance = 0.0;       AccountGroup AccountNameValue = new AccountGroup();  AccountGroup ParentAccount = new AccountGroup();     List < AccountGroup > AccountNameValueList = new List < AccountGroup > (); List < AccountGroup > subAccsList = new List < AccountGroup > ();   if (bsd.get('Credit') != null) creditSum = double.valueOf(bsd.get('Credit'));        if (bsd.get('Debit') != null) debitsum = double.valueOf(bsd.get('Debit'));   if (bsd.get('AccountGroup') == 'Income_Revenue') {
                
                if ((Boolean) bsd.get('ContraAccount')) {    ClosingBalance = (debitsum - creditSum);  AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'), isoCode);
                    //ClosingBalance = -ClosingBalance;
                } else {  ClosingBalance = (creditSum - debitsum); AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'),isoCode);
                }
                
            } else if (bsd.get('AccountGroup') == 'Expense') {
                if ((Boolean) bsd.get('ContraAccount')) {    ClosingBalance = (creditSum - debitsum); AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'), isoCode);      ClosingBalance = -ClosingBalance;
                } else {
                    //ClosingBalance = (openingBal - (creditSum - debitsum));
                    ClosingBalance = (debitsum - creditSum); AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'), isoCode);
                }
            }
            AccountNameValueList = new List < AccountGroup > ();  AccountNameValueList.add(AccountNameValue);  AccountGroup subAccGrp;
            if (String.valueOf(bsd.get('SubAccountGroup')) != null) {          subAccGrp = new AccountGroup(String.valueOf(bsd.get('SubAccountGroup')), ClosingBalance, AccountNameValueList, isoCode);     subAccsList = new List < AccountGroup > (); subAccsList.add(subAccGrp); ParentAccount = new AccountGroup(String.valueOf(bsd.get('AccountGroup')), ClosingBalance, subAccsList, isoCode);
            } else {
                ParentAccount = new AccountGroup(String.valueOf(bsd.get('AccountGroup')), ClosingBalance, AccountNameValueList,isoCode);
                 
            }
            
            if (String.valueOf(bsd.get('AccountGroup')) == 'Income_Revenue' || String.valueOf(bsd.get('AccountGroup')) == 'Expense') {
                if (Instance.FinancialYearWiseAccountMap.get(String.valueOf(bsd.get('AccountGroup'))).Name == null || Instance.FinancialYearWiseAccountMap.get(String.valueOf(bsd.get('AccountGroup'))).Name == '') {      Instance.FinancialYearWiseAccountMap.put(String.valueOf(bsd.get('AccountGroup')), ParentAccount);
                } else {
                    AccountGroup PAccount = Instance.FinancialYearWiseAccountMap.get(String.valueOf(bsd.get('AccountGroup')));
                    if (PAccount.Name == String.valueOf(bsd.get('AccountGroup')) && PAccount.SubAccountList != null && PAccount.SubAccountList.size() > 0) {
                        Boolean sflag = true;
                        if (String.valueOf(bsd.get('SubAccountGroup')) != null) {
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
                                
                                if (PAccount.SubAccountList[i].Name == String.valueOf(bsd.get('SubAccountGroup'))) {
                                    if (PAccount.SubAccountList[i].SubAccountList != null && PAccount.SubAccountList[i].SubAccountList.size() > 0) {
                                        boolean ssflag = true;
                                        for (integer m = 0; m < PAccount.SubAccountList[i].SubAccountList.size(); m++) {
                                            if (PAccount.SubAccountList[i].SubAccountList[m].Name == String.valueOf(bsd.get('AccountName'))) {
                                                if ((Boolean) bsd.get('ContraAccount'))     PAccount.SubAccountList[i].SubAccountList[m].value -= ClosingBalance;
                                                else     PAccount.SubAccountList[i].SubAccountList[m].value += ClosingBalance;
                                                
                                                ssflag = false;
                                            }
                                        }
                                        if (ssflag) PAccount.SubAccountList[i].SubAccountList.add(AccountNameValue);
                                    } else {          PAccount.SubAccountList[i].SubAccountList = AccountNameValueList;
                                    }
                                    if ((Boolean) bsd.get('ContraAccount'))           PAccount.SubAccountList[i].value -= ClosingBalance;
                                    else         PAccount.SubAccountList[i].value += ClosingBalance;
                                    sflag = false;
                                }
                            }
                            if (sflag) PAccount.SubAccountList.add(subAccGrp);
                        } else {
                            PAccount.SubAccountList.add(AccountNameValue);
                            
                        }
                    } else if (PAccount.Name == String.valueOf(bsd.get('AccountGroup'))) {       PAccount.SubAccountList = AccountNameValueList;
                    }
                    if ((Boolean) bsd.get('ContraAccount'))  PAccount.value -= ClosingBalance;
                    else PAccount.value += ClosingBalance;
                }
            }
        }
            
        
            
        Instance.Total_Revenue.ERP7__Opening_Balance__c = (Instance.FinancialYearWiseAccountMap.get('Income_Revenue') != null) ? Instance.FinancialYearWiseAccountMap.get('Income_Revenue').value : 0.00;
            /*'Instance.Total_Revenue.ERP7__Opening_Balance__c'+Instance.Total_Revenue.ERP7__Opening_Balance__c);*/
        Instance.Total_Expense.ERP7__Opening_Balance__c = (Instance.FinancialYearWiseAccountMap.get('Expense') != null) ? Instance.FinancialYearWiseAccountMap.get('Expense').value : 0.00;
        if( Instance.Total_Expense.ERP7__Opening_Balance__c>0)     Instance.Net_Profit.ERP7__Opening_Balance__c = Instance.Total_Revenue.ERP7__Opening_Balance__c - Instance.Total_Expense.ERP7__Opening_Balance__c;
        else Instance.Net_Profit.ERP7__Opening_Balance__c = Instance.Total_Revenue.ERP7__Opening_Balance__c + Instance.Total_Expense.ERP7__Opening_Balance__c;
        
        BalanceSheetData = [select Id AccountId, Name AccountName, RecordType.DeveloperName AccountGroup, ERP7__Account_Type__c SubAccountGroup, ERP7__Sub_Account_Type__c subCategory, ERP7__isContra_Account__c ContraAccount from ERP7__Chart_of_Accounts__c where Id Not IN:coaIds and ERP7__Opening_Balance__c!= null and ERP7__Opening_Balance__c>0 GROUP BY Name,Id,RecordType.DeveloperName,ERP7__Account_Type__c ,ERP7__Sub_Account_Type__c, ERP7__isContra_Account__c Order By ERP7__Account_Type__c DESC NULLS LAST limit 100];    
        for (AggregateResult bsd: BalanceSheetData) {  Decimal openingBal = (Instance.chart_Of_Accounts.get((ID) bsd.get('AccountId')) != null) ? Instance.chart_Of_Accounts.get((ID) bsd.get('AccountId')).ERP7__Opening_Balance__c : 0.00;    Decimal creditSum = 0.0;  Decimal debitsum = 0.0; Decimal ClosingBalance = 0.0;     AccountGroup AccountNameValue = new AccountGroup();  AccountGroup ParentAccount = new AccountGroup();    List < AccountGroup > AccountNameValueList = new List < AccountGroup > (); List < AccountGroup > subAccsList = new List < AccountGroup > ();
            //if (bsd.get('Credit') != null) creditSum = double.valueOf(bsd.get('Credit'));
            //if (bsd.get('Debit') != null) debitsum = double.valueOf(bsd.get('Debit'));
            if (bsd.get('AccountGroup') == 'Income_Revenue') {
                
                if ((Boolean) bsd.get('ContraAccount')) {      ClosingBalance = openingBal;  AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'), isoCode);
                    //ClosingBalance = -ClosingBalance;
                } else {
                    ClosingBalance = openingBal; AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'),isoCode);
                }
                
            } else if (bsd.get('AccountGroup') == 'Expense') {
                if ((Boolean) bsd.get('ContraAccount')) {     ClosingBalance = openingBal; AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'), isoCode);
                    //ClosingBalance = -ClosingBalance;
                } else {
                    //ClosingBalance = (openingBal - (creditSum - debitsum));
                    ClosingBalance = openingBal; AccountNameValue = new AccountGroup(String.valueOf(bsd.get('AccountName')), ClosingBalance, (Boolean) bsd.get('ContraAccount'), isoCode);
                }
            }
            AccountNameValueList = new List < AccountGroup > ();  AccountNameValueList.add(AccountNameValue);      AccountGroup subAccGrp;
            if (String.valueOf(bsd.get('SubAccountGroup')) != null) {      subAccGrp = new AccountGroup(String.valueOf(bsd.get('SubAccountGroup')), ClosingBalance, AccountNameValueList, isoCode);        subAccsList = new List < AccountGroup > (); subAccsList.add(subAccGrp); ParentAccount = new AccountGroup(String.valueOf(bsd.get('AccountGroup')), ClosingBalance, subAccsList, isoCode);
            } else {
                ParentAccount = new AccountGroup(String.valueOf(bsd.get('AccountGroup')), ClosingBalance, AccountNameValueList,isoCode);
                
            }
            
            if (String.valueOf(bsd.get('AccountGroup')) == 'Income_Revenue' || String.valueOf(bsd.get('AccountGroup')) == 'Expense') {
                if (Instance.FinancialYearWiseAccountMap.get(String.valueOf(bsd.get('AccountGroup'))).Name == null || Instance.FinancialYearWiseAccountMap.get(String.valueOf(bsd.get('AccountGroup'))).Name == '') {         Instance.FinancialYearWiseAccountMap.put(String.valueOf(bsd.get('AccountGroup')), ParentAccount);
                } else {
                    AccountGroup PAccount = Instance.FinancialYearWiseAccountMap.get(String.valueOf(bsd.get('AccountGroup')));
                    if (PAccount.Name == String.valueOf(bsd.get('AccountGroup')) && PAccount.SubAccountList != null && PAccount.SubAccountList.size() > 0) {
                        Boolean sflag = true;
                        if (String.valueOf(bsd.get('SubAccountGroup')) != null) {
                            for (Integer i = 0; i < PAccount.SubAccountList.size(); i++) {
                                
                                if (PAccount.SubAccountList[i].Name == String.valueOf(bsd.get('SubAccountGroup'))) {
                                    if (PAccount.SubAccountList[i].SubAccountList != null && PAccount.SubAccountList[i].SubAccountList.size() > 0) {
                                        boolean ssflag = true;
                                        for (integer m = 0; m < PAccount.SubAccountList[i].SubAccountList.size(); m++) {
                                            if (PAccount.SubAccountList[i].SubAccountList[m].Name == String.valueOf(bsd.get('AccountName'))) {
                                                if ((Boolean) bsd.get('ContraAccount'))   PAccount.SubAccountList[i].SubAccountList[m].value -= ClosingBalance;
                                                else                                                
                                                ssflag = false;
                                            }
                                        }
                                        if (ssflag) PAccount.SubAccountList[i].SubAccountList.add(AccountNameValue);
                                    } else {
                                        PAccount.SubAccountList[i].SubAccountList = AccountNameValueList;
                                    }
                                    if ((Boolean) bsd.get('ContraAccount'))    PAccount.SubAccountList[i].value -= ClosingBalance;
                                    else
                                        PAccount.SubAccountList[i].value += ClosingBalance;
                                    sflag = false;
                                }
                            }
                            if (sflag) PAccount.SubAccountList.add(subAccGrp);
                        } else {
                            PAccount.SubAccountList.add(AccountNameValue);
                            
                        }
                    } else if (PAccount.Name == String.valueOf(bsd.get('AccountGroup'))) {   PAccount.SubAccountList = AccountNameValueList;
                    }
                    if ((Boolean) bsd.get('ContraAccount'))  PAccount.value -= ClosingBalance;
                    else PAccount.value += ClosingBalance;
                }
            }
        }
            
           
        Instance.Total_Revenue.ERP7__Opening_Balance__c = (Instance.FinancialYearWiseAccountMap.get('Income_Revenue') != null) ? Instance.FinancialYearWiseAccountMap.get('Income_Revenue').value : 0.00;
            /*'Instance.Total_Revenue.ERP7__Opening_Balance__c'+Instance.Total_Revenue.ERP7__Opening_Balance__c);*/
        Instance.Total_Expense.ERP7__Opening_Balance__c = (Instance.FinancialYearWiseAccountMap.get('Expense') != null) ? Instance.FinancialYearWiseAccountMap.get('Expense').value : 0.00;
        if( Instance.Total_Expense.ERP7__Opening_Balance__c>0) Instance.Net_Profit.ERP7__Opening_Balance__c = Instance.Total_Revenue.ERP7__Opening_Balance__c - Instance.Total_Expense.ERP7__Opening_Balance__c;
        else Instance.Net_Profit.ERP7__Opening_Balance__c = Instance.Total_Revenue.ERP7__Opening_Balance__c + Instance.Total_Expense.ERP7__Opening_Balance__c;
        return Instance; }catch(Exception e){ System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); Instance.errMsg = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString(); return Instance; }
    }
   
    
     @AuraEnabled
     public static IncomeStatementLightning buildConditions(String Ins) {
         IncomeStatementLightning Instance = (IncomeStatementLightning)JSON.deserialize(Ins, IncomeStatementLightning.class);
        //IncomeStatementLightning Instance = Ins;
        try{
        Instance.FiscalYearQuarter.put('1', '= THIS_FISCAL_YEAR');
        Instance.FiscalYearQuarter.put('2', '>= LAST_FISCAL_YEAR AND General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        Instance.FiscalYearQuarter.put('3', '>= LAST_N_FISCAL_YEARS:2 AND General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR');
        Instance.FiscalYearQuarter.put('4', '= THIS_FISCAL_QUARTER');
        Instance.FiscalYearQuarter.put('5', '= NEXT_FISCAL_QUARTER OR General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        Instance.FiscalYearQuarter.put('6', '= NEXT_FISCAL_QUARTER');
        Instance.FiscalYearQuarter.put('7', '= LAST_FISCAL_QUARTER OR General_Ledger_Entry_DateTime__c = THIS_FISCAL_QUARTER');
        return  Instance; }catch(Exception e){ System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); Instance.errMsg = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString();  return Instance;  }
        
    }
    @AuraEnabled
    public static  Map< Integer, String > BuildMOnthMap(Integer m) {
        
        Map < Integer, String > IntegerToMonthName = new Map < Integer, String > ();
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
          
                    for (Integer i = 0; i <= 11; i++)
                    IntegerToMonthName.put(i + 1, MonthNames[(i - 1) + m]);
        return IntegerToMonthName;
    }
    
   @AuraEnabled
   public static IncomeStatementLightning ComputeData(String Ins) {
       IncomeStatementLightning Instance = (IncomeStatementLightning)JSON.deserialize(Ins, IncomeStatementLightning.class);
       try{
           date start_date = Date.parse(Instance.StartDate);
           date end_date = Date.parse(Instance.endDate);
           if( Instance.transEdate == null )Instance.transEdate = end_date;
           if( Instance.transEdate != null )end_date = Instance.transEdate ;
           
           if( Instance.transSdate == null )Instance.transSdate = start_date;
           if( Instance.transSdate != null )start_date = Instance.transSdate ;
           Date Sfy = Date.parse(Instance.minDate);
           if (Instance.SelectedFy.equalsIgnoreCase('2') || Instance.SelectedFy.equalsIgnoreCase('3')) sfy = sfy.addYears(1 - Integer.valueof(Instance.SelectedFy));
           Instance.startfy = sfy.format();
           Instance.endfy = Instance.max_date;
           Instance.TotalIncomeStmt = new Map < String, Map < Integer, decimal >> ();
           Instance.TotalExpenseStmt = new Map < String, Map < Integer, decimal >> ();
           Instance.TotalCOGSStmt = new Map < String, Map < Integer, decimal >> ();
           Instance.TotalNetProfitStmt = new Map < String, Map < Integer, decimal >> ();
           Instance.FinancialAccountIncomeStmt = new Map < String, Map < String, Map < Integer, decimal >>> (); 
           Instance.FinancialCOGSExpenseStmt = new Map < String, Map < String, Map < Integer, decimal >>> ();
           Instance.FinancialAccountExpenseStmt = new Map < String, Map < String, Map < Integer, decimal >>> ();
           Instance.FinancialAccountIncomeStmt2 = new Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>> ();
           Instance.TotalIncomeStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
           Instance.TotalExpenseStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
           Instance.TotalCOGSStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
           Instance.TotalNetProfitStmt2 = new Map < String, Map < Integer, ERP7__Transaction__c >> ();
           Instance.FinancialCOGSExpenseStmt2 = new Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>> ();
           Instance.FinancialAccountExpenseStmt2 = new Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>> ();
           system.debug('Instance-->'+Instance);
           system.debug('start_date-->'+start_date);
           system.debug('end_date-->'+end_date);
           Instance.chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c > ([SELECT Name, RecordTypeId, ERP7__isContra_Account__c,
                                                                                      ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where RecordType.DeveloperName in ('Income_Revenue', 'Expense')
                                                                                     ]); 
           system.debug('Instance.Select_Organisation.ERP7__Organisation__c-->'+Instance.Select_Organisation.ERP7__Organisation__c);
           
           String DbQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit,' +
               'ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,' +
               ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount,CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly' +
               ' FROM ERP7__Finance_General_Ledger_Entry__c where ERP7__Active__c = true AND ' +
               ' DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND '+
               ' ERP7__Organisation__c =\'' + Instance.Select_Organisation.ERP7__Organisation__c + '\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Income_Revenue\',\'Expense\')' +
               ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC limit 100';
           
           String CoaQuery = 'SELECT ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,' +
               ' ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) Fyear,CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c) FQuarter,CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c) FMonthly' +
               ' FROM ERP7__Finance_General_Ledger_Entry__c where ERP7__Active__c = true AND ' +
               ' DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND '+
               ' ERP7__Organisation__c =\'' + Instance.Select_Organisation.ERP7__Organisation__c + '\' AND ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Income_Revenue\',\'Expense\')' +
               ' group by CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_MONTH(ERP7__General_Ledger_Entry_DateTime__c),CALENDAR_QUARTER(ERP7__General_Ledger_Entry_DateTime__c),ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ORDER BY CALENDAR_YEAR(ERP7__General_Ledger_Entry_DateTime__c) DESC limit 100';
           
           List < AggregateResult > BalanceSheetData = Database.query(DbQuery);     List < AggregateResult > COAList = Database.query(CoaQuery);   Map < integer, Decimal > TempList = new Map < integer, Decimal > (); Map < String, Map < Integer, decimal >> TempYear = new Map < String, Map < Integer, decimal >> ();
           
           if (Instance.YearorQuarter.containsIgnoreCase('Month')) { Instance.showMonthly = true; Instance.showFywise = false; Instance.ShowQuartely = false; } else if (Instance.YearorQuarter.containsIgnoreCase('Quarter') || Instance.FiscalYearQuarter.get(Instance.SelectedFy).containsIgnoreCase('Quarter')) { Instance.showMonthly = false; Instance.showFywise = false; Instance.ShowQuartely = true; } else { Instance.showMonthly = false; Instance.showFywise = true; Instance.ShowQuartely = false; }
           Map < Integer, decimal > quarterMap = new Map < Integer, decimal > ();     Integer NoQ_M;
           if (!Instance.FiscalYearQuarter.get(Instance.SelectedFy).containsIgnoreCase('Quarter') && (Instance.SelectedFy.containsAny('123'))) {     NoQ_M = (Instance.YearorQuarter.containsIgnoreCase('Month')) ? 12 : ((Instance.YearorQuarter.containsIgnoreCase('Quarter')) ? 4 : 1);
                   // Integer YLen =(FiscalYearQuarter.get(SelectedFy).containsIgnoreCase('Quarter'))? 1 : Integer.valueOf(SelectedFy);
                   Integer Ylen = Integer.valueOf(Instance.SelectedFy);    TempYear = new Map < String, Map < Integer, Decimal >> ();
               
               for (Integer j = 0; j < YLen; j++) {
                   Map < Integer, Decimal > TList = new Map < Integer, Decimal > ();
                   Map < Integer, Decimal > TotalList = new Map < Integer, Decimal > ();
                   if (Instance.YearorQuarter.containsIgnoreCase('Year') && (Instance.SelectedFy.containsAny('123'))) {    TotalList.put(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j, 0.00);           Tlist.put(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j, 0.00);  TempYear.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TList));    Instance.TotalIncomeStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), TotalList);    Instance.TotalExpenseStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));     Instance.TotalCOGSStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));      Instance.TotalNetProfitStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                   } else if ((Instance.YearorQuarter.containsIgnoreCase('Month') || Instance.YearorQuarter.containsIgnoreCase('Quarter')) && (Instance.SelectedFy.containsAny('123'))) {
                       for (integer i = 1; i < NoQ_M + 1; i++) {       TempList.put(i, 0.00);     TotalList.put(i, 0.00);     }                TempYear.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), TempList);              Instance.TotalIncomeStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), TotalList);                Instance.TotalExpenseStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));      Instance.TotalCOGSStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));     Instance.TotalNetProfitStmt.put(String.valueOf(((Instance.mon == 1) ? System.today().Year() : System.today().Year() - 1) - j), new Map < Integer, Decimal > (TotalList));
                   }
                   
               }
               
           } else {
               for (AggregateResult coa: COAList) {
                   quarterMap = new Map < Integer, decimal > ();              if (TempYear.get(String.valueOf(coa.get('Fyear'))) != null)                    quarterMap = TempYear.get(String.valueOf(coa.get('Fyear')));          quarterMap.put(Integer.valueOf(coa.get('FQuarter')), 0.00);          TempYear.put(String.valueOf(coa.get('Fyear')), quarterMap);             Instance.TotalIncomeStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));         Instance.TotalExpenseStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));         Instance.TotalCOGSStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));            Instance.TotalNetProfitStmt.put(String.valueOf(coa.get('Fyear')), new Map < Integer, Decimal > (quarterMap));
               }
               
               
           }
           
           for (AggregateResult coa: COAList) {      Map < String, Map < Integer, Decimal >> TempY = new Map < String, Map < Integer, Decimal >> ();
               
               for (String s: TempYear.keyset()) {          Map < Integer, Decimal > innerMap = new Map < Integer, Decimal > ();         innerMap = TempYear.get(s);     TempY.put(s, new Map < Integer, Decimal > (innerMap));
               }
               
               
               if (String.valueOf(Coa.get('AccountGroup')) == 'Income_Revenue'){      Instance.FinancialAccountIncomeStmt.put(String.valueOf(Coa.get('AccountName')), new Map < String, Map < Integer, Decimal >> (TempY));
               }
               else {
                   if (String.valueOf(Coa.get('SubAccountGroup')) != null)      Instance.FinancialCOGSExpenseStmt.put(String.valueOf(Coa.get('AccountName')), new Map < String, Map < Integer, Decimal >> (TempY));
                   else          Instance.FinancialAccountExpenseStmt.put(String.valueOf(Coa.get('AccountName')), new Map < String, Map < Integer, Decimal >> (TempY));
                   
               }
           }
           
           
           for (AggregateResult bsd: BalanceSheetData) {     
               system.debug('bdbsd-->'+bsd);
               Decimal TotalIncome = 0.00;            Decimal creditSum = 0.0;          Decimal debitsum = 0.0;           Decimal ClosingBalance = 0.0;    
               system.debug('Account Id-->'+Instance.chart_Of_Accounts.get((ID) bsd.get('AccountId')));
               Decimal openingBal = (Instance.chart_Of_Accounts.get((ID) bsd.get('AccountId')) != null) ? Instance.chart_Of_Accounts.get((ID) bsd.get('AccountId')).ERP7__Opening_Balance__c : 0.00;
               if (bsd.get('Credit') != null) creditSum = double.valueOf(bsd.get('Credit'));     if (bsd.get('Debit') != null) debitsum = double.valueOf(bsd.get('Debit'));   if ((Boolean) bsd.get('ContraAccount')) {    ClosingBalance = (debitsum - creditSum);
                   //ClosingBalance = -ClosingBalance;
               } else {
                   ClosingBalance = (creditSum - debitsum);
                   
               }
               Instance.YearorQuarter = (Instance.FiscalYearQuarter.get(Instance.SelectedFy).containsIgnoreCase('Quarter')) ? 'FQuarter' : Instance.YearorQuarter;
               if (String.valueOf(bsd.get('AccountGroup')) == 'Income_Revenue') {
                   /*'called==>'+Instance.FinancialAccountIncomeStmt);*/
                   if (Instance.FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName'))) != null && Instance.FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName'))).get(String.valueOf(bsd.get('Fyear'))) != null && Instance.FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName'))).get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(Instance.YearorQuarter))) != null) {
                                         Map < String, Map < Integer, decimal >> AccountMap = Instance.FinancialAccountIncomeStmt.get(String.valueOf(bsd.get('AccountName')));               Map < Integer, decimal > QuarterlyMap = AccountMap.get(String.valueOf(bsd.get('Fyear')));              Map < Integer, decimal > TotalMap = Instance.TotalIncomeStmt.get(String.valueOf(bsd.get('Fyear')));                   Decimal total = QuarterlyMap.get(Integer.valueof(bsd.get(Instance.YearorQuarter)));     Decimal RowTotal = TotalMap.get(Integer.valueof(bsd.get(Instance.YearorQuarter)));
                       if ((Boolean) bsd.get('ContraAccount')) {                   QuarterlyMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), total - ClosingBalance);       TotalMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), RowTotal - ClosingBalance);
                       } else {
                           QuarterlyMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), total + ClosingBalance);         TotalMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), RowTotal + ClosingBalance);
                       }
                       AccountMap.put(String.valueOf(bsd.get('Fyear')), QuarterlyMap);        Instance.TotalIncomeStmt.put(String.valueOf(bsd.get('Fyear')), TotalMap);
                   }
               } else {
                   if (Instance.FinancialAccountExpenseStmt != null && bsd.get('SubAccountGroup') != null && String.valueOf(bsd.get('SubAccountGroup')) == null && Instance.FinancialAccountExpenseStmt.get(String.valueOf(bsd.get('AccountName'))) != null && Instance.FinancialAccountExpenseStmt.get(String.valueOf(bsd.get('AccountName'))).get(String.valueOf(bsd.get('Fyear'))).get(Integer.valueOf(bsd.get(Instance.YearorQuarter))) != null) {
                       Map < String, Map < Integer, decimal >> AccountMap = Instance.FinancialAccountExpenseStmt.get(String.valueOf(bsd.get('AccountName')));    Map < Integer, decimal > QuarterlyMap = AccountMap.get(String.valueOf(bsd.get('Fyear')));  Map < Integer, decimal > TotalMap = Instance.TotalExpenseStmt.get(String.valueOf(bsd.get('Fyear')));   Decimal total = QuarterlyMap.get(Integer.valueof(bsd.get(Instance.YearorQuarter)));    Decimal RowTotal = TotalMap.get(Integer.valueof(bsd.get(Instance.YearorQuarter)));
                       if ((Boolean) bsd.get('ContraAccount')) {       QuarterlyMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), total - ClosingBalance);  TotalMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), RowTotal - ClosingBalance);
                       } else {
                           QuarterlyMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), total + ClosingBalance);  TotalMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), RowTotal + ClosingBalance);
                       }
                       AccountMap.put(String.valueOf(bsd.get('Fyear')), QuarterlyMap);  Instance.TotalExpenseStmt.put(String.valueOf(bsd.get('Fyear')), TotalMap);  Instance.FinancialAccountExpenseStmt.put(String.valueOf(bsd.get('AccountName')), AccountMap);
                   } else {
                       Map < String, Map < Integer, decimal >> AccountMap = Instance.FinancialCOGSExpenseStmt.get(String.valueOf(bsd.get('AccountName')));
                       if (AccountMap != null) {
                           Map < Integer, decimal > QuarterlyMap = AccountMap.get(String.valueOf(bsd.get('Fyear')));   Map < Integer, decimal > TotalMap = Instance.TotalCOGSStmt.get(String.valueOf(bsd.get('Fyear')));
                           if (QuarterlyMap != null) {
                               Decimal total = QuarterlyMap.get(Integer.valueof(bsd.get(Instance.YearorQuarter)));    Decimal RowTotal = TotalMap.get(Integer.valueof(bsd.get(Instance.YearorQuarter)));
                               //QuarterlyMap.put(Integer.valueof(bsd.get(YearorQuarter)),total+ClosingBalance);
                               //TotalMap.put(Integer.valueof(bsd.get(YearorQuarter)),RowTotal+ClosingBalance);
                               if ((Boolean) bsd.get('ContraAccount')) { 
                                   QuarterlyMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), total - ClosingBalance);    TotalMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), RowTotal - ClosingBalance);
                               } else {
                                   QuarterlyMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), total + ClosingBalance);       TotalMap.put(Integer.valueof(bsd.get(Instance.YearorQuarter)), RowTotal + ClosingBalance);
                               }
                               AccountMap.put(String.valueOf(bsd.get('Fyear')), QuarterlyMap);                    Instance.TotalCOGSStmt.put(String.valueOf(bsd.get('Fyear')), TotalMap);      Instance.FinancialCOGSExpenseStmt.put(String.valueOf(bsd.get('AccountName')), AccountMap);
                           }
                       }
                   }
               }
           }
           
           for (String s: Instance.TotalIncomeStmt.keyset()) {        Map < Integer, decimal > NettempMap = new Map < Integer, decimal > ();       for (Integer i: Instance.TotalIncomeStmt.get(s).keyset()) {            NettempMap.put(i, Instance.TotalIncomeStmt.get(s).get(i) - (Instance.TotalExpenseStmt.get(s).get(i) + Instance.TotalCOGSStmt.get(s).get(i)));     Instance.TotalNetProfitStmt.put(s, NettempMap);
               }
           }
           
           // Transaaction for currency display
           for(String M1 : Instance.FinancialAccountIncomeStmt.keyset()){
               Map<String, Map<Integer, ERP7__Transaction__c>> M22 = new Map<String, Map<Integer, ERP7__Transaction__c>>();     for(String M2 : Instance.FinancialAccountIncomeStmt.get(M1).keyset()){         Map<Integer, ERP7__Transaction__c> M33 = new Map<Integer, ERP7__Transaction__c>();       for(Integer M3 : Instance.FinancialAccountIncomeStmt.get(M1).get(M2).keyset()){                   ERP7__Transaction__c tran = new ERP7__Transaction__c();         tran.ERP7__Amount__c = Instance.FinancialAccountIncomeStmt.get(M1).get(M2).get(M3);            if(Instance.multiCurrencyEnabled) tran.put('CurrencyIsoCode',Instance.isoCode);          M33.put(M3, tran);                  }             M22.put(M2, M33);              }    Instance.FinancialAccountIncomeStmt2.put(M1, M22);
           }
           /*' FinancialAccountIncomeStmt2 ==> '+Instance.FinancialAccountIncomeStmt2);*/
           
           
           for(String M1 : Instance.FinancialAccountExpenseStmt.keyset()){
               Map<String, Map<Integer, ERP7__Transaction__c>> M22 = new Map<String, Map<Integer, ERP7__Transaction__c>>();
               for(String M2 : Instance.FinancialAccountExpenseStmt.get(M1).keyset()){
                   Map<Integer, ERP7__Transaction__c> M33 = new Map<Integer, ERP7__Transaction__c>();
                   for(Integer M3 : Instance.FinancialAccountExpenseStmt.get(M1).get(M2).keyset()){             ERP7__Transaction__c tran = new ERP7__Transaction__c();             tran.ERP7__Amount__c = Instance.FinancialAccountExpenseStmt.get(M1).get(M2).get(M3);                 if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;          if(Instance.multiCurrencyEnabled) tran.put('CurrencyIsoCode',Instance.isoCode);      M33.put(M3, tran);
                   }
                   M22.put(M2, M33);
               }
               Instance.FinancialAccountExpenseStmt2.put(M1, M22);
           }
           /*'*** FinancialAccountExpenseStmt2 ==> '+Instance.FinancialAccountExpenseStmt2);*/
           
           for(String M1 : Instance.FinancialCOGSExpenseStmt.keyset()){
               Map<String, Map<Integer, ERP7__Transaction__c>> M22 = new Map<String, Map<Integer, ERP7__Transaction__c>>();
               for(String M2 : Instance.FinancialCOGSExpenseStmt.get(M1).keyset()){
                   Map<Integer, ERP7__Transaction__c> M33 = new Map<Integer, ERP7__Transaction__c>();
                   for(Integer M3 : Instance.FinancialCOGSExpenseStmt.get(M1).get(M2).keyset()){           ERP7__Transaction__c tran = new ERP7__Transaction__c();             tran.ERP7__Amount__c = Instance.FinancialCOGSExpenseStmt.get(M1).get(M2).get(M3);            if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;            if(Instance.multiCurrencyEnabled) tran.put('CurrencyIsoCode',Instance.isoCode);          M33.put(M3, tran);
                   }
                   M22.put(M2, M33);
               }
               Instance.FinancialCOGSExpenseStmt2.put(M1, M22);
           }
           for(String M1 : Instance.TotalIncomeStmt.keyset()){
               Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
               for(Integer M2 : Instance.TotalIncomeStmt.get(M1).keyset()){           ERP7__Transaction__c tran = new ERP7__Transaction__c();            tran.ERP7__Amount__c = Instance.TotalIncomeStmt.get(M1).get(M2);          if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;            if(Instance.multiCurrencyEnabled) tran.put('CurrencyIsoCode',Instance.isoCode);   M22.put(M2, tran);
               }
               Instance.TotalIncomeStmt2.put(M1, M22);
           }
           
           for(String M1 : Instance.TotalExpenseStmt.keyset()){
               Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
               for(Integer M2 : Instance.TotalExpenseStmt.get(M1).keyset()){              ERP7__Transaction__c tran = new ERP7__Transaction__c();            tran.ERP7__Amount__c = Instance.TotalExpenseStmt.get(M1).get(M2);                if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;            if(Instance.multiCurrencyEnabled) tran.put('CurrencyIsoCode',Instance.isoCode);    M22.put(M2, tran);
               }
               Instance.TotalExpenseStmt2.put(M1, M22);
           }
           for(String M1 : Instance.TotalCOGSStmt.keyset()){
               Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
               for(Integer M2 : Instance.TotalCOGSStmt.get(M1).keyset()){               ERP7__Transaction__c tran = new ERP7__Transaction__c();            tran.ERP7__Amount__c = Instance.TotalCOGSStmt.get(M1).get(M2);          if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;            if(Instance.multiCurrencyEnabled) tran.put('CurrencyIsoCode',Instance.isoCode);            M22.put(M2, tran);
               }
               Instance.TotalCOGSStmt2.put(M1, M22);
           }
           for(String M1 : Instance.TotalNetProfitStmt.keyset()){
               Map<Integer, ERP7__Transaction__c> M22 = new Map<Integer, ERP7__Transaction__c>();
               for(Integer M2 : Instance.TotalNetProfitStmt.get(M1).keyset()){           ERP7__Transaction__c tran = new ERP7__Transaction__c();       tran.ERP7__Amount__c = Instance.TotalNetProfitStmt.get(M1).get(M2);          if(tran.ERP7__Amount__c < 0) tran.ERP7__Amount__c = 0-tran.ERP7__Amount__c;             if(Instance.multiCurrencyEnabled) tran.put('CurrencyIsoCode',Instance.isoCode);      M22.put(M2, tran);
               }
               Instance.TotalNetProfitStmt2.put(M1, M22);
           }
           Instance = getdata(JSON.serialize(Instance));      Instance.FinancialAccountIncomeStmt2Wrapper = new List<W3>(); Instance.FinancialAccountIncomeStmt2Wrapper = getW3(JSON.serialize(Instance.FinancialAccountIncomeStmt2));  Instance.FinancialCOGSExpenseStmt2Wrapper = new List<W3>(); Instance.FinancialCOGSExpenseStmt2Wrapper = getW3(JSON.serialize(Instance.FinancialCOGSExpenseStmt2));      Instance.FinancialAccountExpenseStmt2Wrapper = new List<W3>(); Instance.FinancialAccountExpenseStmt2Wrapper = getW3(JSON.serialize(Instance.FinancialAccountExpenseStmt2));       Instance.TotalIncomeStmt2Wrapper = new List<W2>();  Instance.TotalIncomeStmt2Wrapper = getW2(JSON.serialize(Instance.TotalIncomeStmt2));           Instance.TotalExpenseStmt2Wrapper = new List<W2>();  Instance.TotalExpenseStmt2Wrapper = getW2(JSON.serialize(Instance.TotalExpenseStmt2));               Instance.TotalNetProfitStmt2Wrapper = new List<W2>();  Instance.TotalNetProfitStmt2Wrapper = getW2(JSON.serialize(Instance.TotalNetProfitStmt2));         Instance.TotalCOGSStmt2Wrapper = new List<W2>(); Instance.TotalCOGSStmt2Wrapper = getW2(JSON.serialize(Instance.TotalCOGSStmt2));   return Instance;
       }catch(Exception e){
           System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
           Instance.errMsg = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString();
           return Instance; 
       }
   }
    
    public static List<W3> getW3(String  Ins1 )
    {  
        Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>> Ins  = (Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>>) JSON.deserialize(Ins1, Map < String, Map < String, Map < Integer, ERP7__Transaction__c >>>.class);
        List<W3> w3Wrapper = new List<W3>();
        for(String s1 : Ins.keyset()){ W3 w3Instnace = new W3(); w3Instnace.W3COA = s1; Map < String, Map < Integer, ERP7__Transaction__c >> T1 = Ins.get(s1); List<W2> w2all =new List<W2>(); for(String s2 : T1.keyset()){ W2 w2Instance = new W2(); w2Instance.W2COA = s2; Map < Integer, ERP7__Transaction__c > T2 = T1.get(s2); List<W1> w1all =new List<W1>(); for( Integer i : T2.keyset()){ W1 w1Instance = new W1(); w1Instance.num = i; w1Instance.W1trans = T2.get(i); w1all.add(w1Instance); } w2Instance.innerWrapperW1 = w1all; w2all.add(w2Instance); } w3Instnace.innnerWrpperW2 = w2all; w3Wrapper.add(w3Instnace); }
        return w3Wrapper; 
    
    }
    
    public static List<W2> getW2(String Ins1)
    {
        Map<String, Map<Integer, ERP7__Transaction__c>> Ins  = (Map<String, Map<Integer, ERP7__Transaction__c>>) JSON.deserialize(Ins1, Map<String, Map<Integer, ERP7__Transaction__c>>.class);
        List<W2> w2Wrapper = new List<W2>();
          for(String s : Ins.keySet() ){ W2 wouter = new W2(); wouter.W2COA = s; Map < Integer, ERP7__Transaction__c > t = Ins.get(s); List<W1> w1All = new List<W1>(); for(Integer ss : t.keySet() ){ W1 winner = new W1(); winner.W1trans = t.get(ss); winner.num = ss; w1All.add(winner); } wouter.innerWrapperW1 = w1All; w2Wrapper.add(wouter); }
        return w2Wrapper;
    }
    
    
    public class W1 {
        @AuraEnabled  public ERP7__Transaction__c W1trans { get; set;} @AuraEnabled  public String       W1COA  { get; set; } @AuraEnabled  public Integer       num  { get; set; } 
        public W1(){
            W1trans = new ERP7__Transaction__c();
            
            Boolean multiCurrencyEnabled =  Schema.getGlobalDescribe().containsKey('CurrencyType'); String isoCode;
            if(multiCurrencyEnabled){ isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode'); }
            if(multiCurrencyEnabled) W1trans.put('CurrencyIsoCode',isoCode);
        }
    }
    
    public class W2 { @AuraEnabled public String      W2COA                   { get; set; } @AuraEnabled public List<ERP7__Transaction__c> W2trans { get; set;} @AuraEnabled public List<W1> innerWrapperW1               { get; set;} public W2() { innerWrapperW1 = new List<W1>(); W2trans     = new List<ERP7__Transaction__c>(); } }
   
   public class W3 { @AuraEnabled public String W3COA  { get; set; } @AuraEnabled public List<W2> innnerWrpperW2 { get; set; } @AuraEnabled public List<ERP7__Transaction__c> W3trans { get; set;} }
    
     public class Data {
        @AuraEnabled 
        public String name   { get; set; }
        @AuraEnabled
        public Decimal data1 { get; set; }
        @AuraEnabled
        public Decimal data2 { get; set; }
        @AuraEnabled 
        public Decimal data3 { get; set;}
        @AuraEnabled 
        public Decimal data4 { get; set; }
        public Data(String name, Decimal data1, Decimal data2, Decimal data3, Decimal data4) { this.name = name; this.data1 = data1; this.data2 = data2;  this.data3 = data3;  this.data4 = data4;
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
 public static IncomeStatementLightning  getdata(String Ins) {
        IncomeStatementLightning Instance = ( IncomeStatementLightning ) JSON.deserialize(Ins, IncomeStatementLightning.class);
     try{
     //IncomeStatementLightning Instance = Ins;   
     Instance.showchart = true;
        Instance.CurrentChartofAccounts = new Map < String, Map < String, decimal >> ();
        Instance.datalist = new List < data > ();
        Instance.Colorset = String.join(Instance.colors, ','); Map < String, decimal > tempMap; integer m = 1; Instance.FyYear = ''; if (Instance.SelectedFy.containsAny('14567')) { Instance.ChartTitle = (Instance.YearorQuarter.containsIgnoreCase('Month')) ? 'FISCAL MONTH' : (Instance.YearorQuarter.containsIgnoreCase('Quarter')) ? 'FISCAL QUARTERS' : 'FISCAL YEAR';
            for (String s: Instance.TotalIncomeStmt.keyset()) {
                List < Integer > keyList = new List < Integer > (Instance.TotalIncomeStmt.get(s).keyset());
                for (Integer i = 0; i < keyList.size(); i++) { String str;
                    if (Instance.YearorQuarter.containsIgnoreCase('Quarter'))      str = Instance.IntegerToQuarterName.get(keyList[i]);
                    else if (Instance.YearorQuarter.containsIgnoreCase('Month')) str = Instance.IntegerToMonthName.get(keyList[i]);
                    else     str = String.valueOf(keyList[i]);
                    Instance.datalist.add(new Data(str, Instance.TotalIncomeStmt.get(s).get(keyList[i]), Instance.TotalExpenseStmt.get(s).get(keyList[i]), Instance.TotalIncomeStmt.get(s).get(keyList[i]) - (Instance.TotalExpenseStmt.get(s).get(keyList[i]) + Instance.TotalCOGSStmt.get(s).get(keyList[i]))));
                } }
            Instance.yfields = 'Total Income,Total Expense,Net Profit';    Instance.FyYear = 'data1,data2,data3';
        } else if (Instance.YearorQuarter.containsIgnoreCase('Quarter')) {
            Instance.FyYear = ''; Instance.yfields = ''; Instance.ChartTitle = 'Net Profit / Loss'; tempMap = new Map < String, decimal > (); Map < String, decimal > ExpensetempMap = new Map < String, decimal > (); Map < String, decimal > NettempMap = new Map < String, decimal > (); List < String > Year_List = new List < String > (Instance.TotalIncomeStmt.keyset()); Integer j = 0;
            for (Integer i: Instance.IntegerToQuarterName.keyset()) {
                String str = (Instance.YearorQuarter.containsIgnoreCase('Quarter')) ? Instance.IntegerToQuarterName.get(i) : String.valueOf(i);
                if (Year_List.size() == 2) {  Instance.datalist.add(new Data(str, Instance.TotalIncomeStmt.get(Year_List[j]).get(i) - (Instance.TotalExpenseStmt.get(Year_List[j]).get(i) + Instance.TotalCOGSStmt.get(Year_List[j]).get(i)), Instance.TotalIncomeStmt.get(Year_List[j + 1]).get(i) - (Instance.TotalExpenseStmt.get(Year_List[j + 1]).get(i) + Instance.TotalCOGSStmt.get(Year_List[j + 1]).get(i))));  Instance.FyYear = 'data1,data2';
                } else if (Year_List.size() == 3) {   Instance.datalist.add(new Data(str, Instance.TotalIncomeStmt.get(Year_List[j]).get(i) - (Instance.TotalExpenseStmt.get(Year_List[j]).get(i) + Instance.TotalCOGSStmt.get(Year_List[j]).get(i)), Instance.TotalIncomeStmt.get(Year_List[j + 1]).get(i) - (Instance.TotalExpenseStmt.get(Year_List[j + 1]).get(i) + Instance.TotalCOGSStmt.get(Year_List[j + 1]).get(i)), Instance.TotalIncomeStmt.get(Year_List[j + 2]).get(i) - (Instance.TotalExpenseStmt.get(Year_List[j + 2]).get(i) + Instance.TotalCOGSStmt.get(Year_List[j + 2]).get(i))));    Instance.FyYear = 'data1,data2,data3';
                }
            }
            Instance.yfields = String.join(new List < String > (Instance.TotalIncomeStmt.keyset()), ',');    
        } else {
            Instance.FyYear = ''; Instance.yfields = ''; Instance.ChartTitle = 'Profit / Loss'; tempMap = new Map < String, decimal > (); Map < String, decimal > ExpensetempMap = new Map < String, decimal > (); Map < String, decimal > NettempMap = new Map < String, decimal > ();
            for (String s: Instance.TotalIncomeStmt.keyset()) {
                for (Integer i: Instance.TotalIncomeStmt.get(s).keyset()) {  String str = (Instance.YearorQuarter.containsIgnoreCase('Quarter')) ? Instance.IntegerToQuarterName.get(i) : String.valueOf(i);   tempMap.put(str, Instance.TotalIncomeStmt.get(s).get(i));    Instance.CurrentChartofAccounts.put('Total Income', tempMap);     ExpensetempMap.put(str, Instance.TotalExpenseStmt.get(s).get(i));      Instance.CurrentChartofAccounts.put('Total Expense', ExpensetempMap);    NettempMap.put(str, Instance.TotalIncomeStmt.get(s).get(i) - (Instance.TotalExpenseStmt.get(s).get(i) + Instance.TotalCOGSStmt.get(s).get(i)));  Instance.CurrentChartofAccounts.put('Net Profit', NettempMap);
                }
            }
            Map < String, decimal > temp_Map;
            for (String s: Instance.CurrentChartofAccounts.keyset()) {   temp_Map = Instance.CurrentChartofAccounts.get(s);   List < Decimal > valueList = temp_Map.values();   INteger k = 0;  if (valueList.size() == 4) Instance.datalist.add(new Data(s, valueList[k], valueList[k + 1], valueList[k + 2], valueList[k + 3]));     else if (valueList.size() == 3) Instance.datalist.add(new Data(s, valueList[k], valueList[k + 1], valueList[k + 2]));    else if (valueList.size() == 2) Instance.datalist.add(new Data(s, valueList[k], valueList[k + 1])); else     Instance.datalist.add(new Data(s, valueList[k]));
                
            }
            List < String > keyList = new List < String > ();  for (integer x = 1; x <= temp_Map.keyset().size(); x++) {      keyList.add('data' + x);  }           Instance.FyYear = String.join(keyList, ',');      Instance.yfields = String.join(new List < String > (temp_Map.keyset()), ',');
        }
     /*'dataList=>'+Instance.datalist);*/
     return Instance;
     }catch(Exception e){
         System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
                Instance.errMsg = 'Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString();
                
                return Instance; 
            }
    }
   
    /*Wrapper datatype*/
    public class AccountGroup {
        @AuraEnabled
        public String Name                              { get; set;}
        @AuraEnabled
        public Decimal Value                            { get; set; }
        @AuraEnabled
        public List < AccountGroup > SubAccountList     { get; set; }
        @AuraEnabled
        public Boolean contraFlag                       { get; set; }
        @AuraEnabled
        public ERP7__Transaction__c Container           { get; set; }
        @AuraEnabled
        public ERP7__Transaction__c NContainer          { get; set; }
        @AuraEnabled public Boolean IsmultiCurrencyEnabled           { get; set; } @AuraEnabled  public String isoCode                           { get; set; }
        
        /*Instance Intialization Block*/
        {
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
                /*isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
                this.Container.put('CurrencyIsoCode',isoCode);  
                this.NContainer.put('CurrencyIsoCode',isoCode);*/
                
                
            }
        }
        public AccountGroup() {}
        
        public AccountGroup(String AccName, Decimal val, List < AccountGroup > subAcclist, String isoCode) { this.Name = AccName;  this.value = val; this.SubAccountList = subAcclist;  this.Container = new ERP7__Transaction__c();  this.Container.ERP7__Amount__c = val.setscale(2);  this.NContainer = new ERP7__Transaction__c();  this.NContainer.ERP7__Amount__c = 0-val.setscale(2); IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); if(IsmultiCurrencyEnabled){ this.Container.put('CurrencyIsoCode',isoCode); this.NContainer.put('CurrencyIsoCode',isoCode); } for(AccountGroup AG : this.SubAccountList){ AG.Container.ERP7__Amount__c = AG.Value.setscale(2); AG.NContainer.ERP7__Amount__c = 0-AG.Value.setscale(2); } }      public AccountGroup(String AccName, Decimal val, Boolean flag, String isoCode) { this.Name = AccName; this.value = val; this.contraFlag = flag; this.Container = new ERP7__Transaction__c(); this.Container.ERP7__Amount__c = val.setscale(2);  this.NContainer = new ERP7__Transaction__c();  this.NContainer.ERP7__Amount__c = 0-val.setscale(2); IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); if(IsmultiCurrencyEnabled){ this.Container.put('CurrencyIsoCode',isoCode); this.NContainer.put('CurrencyIsoCode',isoCode); } }
        
    }
    
     @AuraEnabled
    public static List<selectOptions> getCurrencies(){
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(IsmultiCurrencyEnabled){ List <sObject> currencies = Database.Query('SELECT IsoCode FROM CurrencyType'); for(sObject a : currencies){ options.add(new SelectOptions(String.valueof(a.get('IsoCode')),String.valueof(a.get('IsoCode')))); } }
        return options;
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab; value = val; selected = sel;
        }
    }
    public class ledgerWrap{
        @AuraEnabled public String ParentName {get;set;}
        @AuraEnabled public List < AggregateResult > ledgerList {get;set;}
        @AuraEnabled public double parentSum {get;set;}
        public ledgerWrap(){
            ParentName = '';
            ledgerList = new List < AggregateResult >();
            parentSum = 0.00;
        }
    }
    
    public class icWrap{
        @AuraEnabled public String AccontType {get;set;}
        @AuraEnabled public Double totalIncome {get;set;}
        @AuraEnabled public List<ledgerWrap> subAccountList {get;set;}
        @AuraEnabled public List<icWrapper> wraplist {get;set;}
        @AuraEnabled public Double totalExpense {get;set;}
        @AuraEnabled public List < AggregateResult > incomeList {get;set;}
        @AuraEnabled public List < AggregateResult > ExpenseList {get;set;}
        @AuraEnabled public Map<String, Double> incomeSubMap {get;set;}
        @AuraEnabled public Map<String, Double> expenseSubMap {get;set;}
        @AuraEnabled public Map<String, List < AggregateResult >> incomeMap {get;set;}
        @AuraEnabled public Map<String, List < AggregateResult >> ExpenseMap {get;set;}
        public icWrap(){
            wraplist = new List<icWrapper>();
            AccontType = '';
            incomeMap = new Map<String, List < AggregateResult >>();
            ExpenseMap = new Map<String, List < AggregateResult >>();
            incomeList = new List < AggregateResult > ();
            ExpenseList = new List < AggregateResult > ();
            totalIncome = totalExpense = 0.00;
            incomeSubMap = new Map<String, Double>();
            expenseSubMap = new Map<String, Double>();
            subAccountList = new List<ledgerWrap>();
        }
    }
    
    public class icWrapper{
        @AuraEnabled public String AccontType {get;set;}
        @AuraEnabled public Double totalIncome {get;set;}
        @AuraEnabled public List<ledgerWrap> subAccountList {get;set;}
        @AuraEnabled public Double totalExpense {get;set;}
        @AuraEnabled public List < AggregateResult > incomeList {get;set;}
        @AuraEnabled public List < AggregateResult > ExpenseList {get;set;}
        @AuraEnabled public Map<String, Double> incomeSubMap {get;set;}
        @AuraEnabled public Map<String, Double> expenseSubMap {get;set;}
        @AuraEnabled public Map<String, List < AggregateResult >> incomeMap {get;set;}
        @AuraEnabled public Map<String, List < AggregateResult >> ExpenseMap {get;set;}
        public icWrapper(){
            AccontType = '';
            incomeMap = new Map<String, List < AggregateResult >>();
            ExpenseMap = new Map<String, List < AggregateResult >>();
            incomeList = new List < AggregateResult > ();
            ExpenseList = new List < AggregateResult > ();
            totalIncome = totalExpense = 0.00;
            incomeSubMap = new Map<String, Double>();
            expenseSubMap = new Map<String, Double>();
            subAccountList = new List<ledgerWrap>();
        }
    }
    
    @AuraEnabled
    public static icWrap ComputeUpdatedData(String Ins) {
        icWrap ic = new icWrap();
        IncomeStatementLightning Instance = (IncomeStatementLightning)JSON.deserialize(Ins, IncomeStatementLightning.class);
        Boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        String isoCode = '';
        if(IsmultiCurrencyEnabled){ isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode'); }
        //IncomeStatementLightning Instance = Ins1;  
        try{
            Instance.Total_Revenue = new ERP7__Chart_of_Accounts__c();
            Instance.Total_Expense = new ERP7__Chart_of_Accounts__c();
            Instance.Net_Profit = new ERP7__Chart_of_Accounts__c();
            Instance.FinancialYearWiseAccountMap = new Map < String, AccountGroup > ();
            Instance.FinancialYearWiseAccountMap.put('Income_Revenue', new AccountGroup());
            Instance.FinancialYearWiseAccountMap.put('Expense', new AccountGroup());
            
            Instance.chart_Of_Accounts = new Map < Id, ERP7__Chart_of_Accounts__c > ([SELECT Name, RecordTypeId, ERP7__isContra_Account__c,
                                                                                      ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c FROM ERP7__Chart_of_Accounts__c where RecordType.DeveloperName in ('Income_Revenue', 'Expense')
                                                                                     ]); 
            if ((Instance.chart_Of_Accounts.size() == 0 || Instance.chart_Of_Accounts == null)) { Instance.ErrMsg = 'Error: No Chart of Accounts found.'; return ic; }
            String qryFilter = '';
            if (Instance.Select_Organisation.ERP7__Organisation__c != null) qryFilter += ' AND ERP7__Organisation__c = \'' + Instance.Select_Organisation.ERP7__Organisation__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Customer__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Customer__c = \'' + Instance.Select_Organisation.ERP7__Customer__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Product__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Product__c = \'' + Instance.Select_Organisation.ERP7__Product__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Sales_Order__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Sales_Order__c = \'' + Instance.Select_Organisation.ERP7__Sales_Order__c + '\' ';
            
            if (Instance.Select_Organisation.ERP7__Project__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Project__c = \'' +Instance.Select_Organisation.ERP7__Project__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Supplier__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Supplier__c = \'' + Instance.Select_Organisation.ERP7__Supplier__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Employee__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Employee__c = \'' + Instance.Select_Organisation.ERP7__Employee__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Site__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Site__c = \'' + Instance.Select_Organisation.ERP7__Site__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Channel__c != null) qryFilter += ' AND ERP7__Transactions__r.ERP7__Channel__c = \'' + Instance.Select_Organisation.ERP7__Channel__c + '\' ';
            if (Instance.Select_Organisation.ERP7__Industry__c != null && Instance.Select_Organisation.ERP7__Industry__c != '' && Instance.Select_Organisation.ERP7__Industry__c != '--None--') qryFilter += ' AND ERP7__Transactions__r.ERP7__Industry__c = \'' + Instance.Select_Organisation.ERP7__Industry__c + '\' ';
            
            date start_date = Date.parse(Instance.StartDate);     date end_date = Date.parse(Instance.endDate);      if( Instance.transEdate == null )Instance.transEdate = end_date;     if( Instance.transEdate != null )end_date = Instance.transEdate ;          if( Instance.transSdate == null )Instance.transSdate = start_date;  if( Instance.transSdate != null )start_date = Instance.transSdate ;
            
            
            String Query = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c coa, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name coaName ' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\'Income_Revenue\',\' \') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
                ' GROUP BY   ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c';
            
            List < AggregateResult > BalanceSheetData = Database.query(Query);   Double amount = 0.00;  Map<String, List < AggregateResult >> aggMap = new Map<String, List < AggregateResult >>();
            system.debug('BalanceSheetData size~>'+BalanceSheetData.size());
            for(AggregateResult agg : BalanceSheetData){
                system.debug('agg-->'+String.valueOf(agg.get('coaName')));
                if(String.valueOf(agg.get('coaName'))!=null){   if(aggMap.containsKey(String.valueOf(agg.get('coaName')))){    system.debug('Entered if');    aggMap.get(String.valueOf(agg.get('coaName'))).add(agg);
                    }else{   List < AggregateResult > aggList = new List < AggregateResult >();     aggList.add(agg);      aggMap.put(String.valueOf(agg.get('coaName')), aggList);
                    }
                }else{
                    if(aggMap.containsKey(String.valueOf(agg.get('SubAccountGroup')))){   system.debug('Entered if');     aggMap.get(String.valueOf(agg.get('SubAccountGroup'))).add(agg);
                    }else{
                        List < AggregateResult > aggList = new List < AggregateResult >();  aggList.add(agg);  aggMap.put(String.valueOf(agg.get('SubAccountGroup')), aggList);
                    }
                }  ic.totalIncome = ic.totalIncome + double.valueOf(agg.get('Credit')) - double.valueOf(agg.get('Debit'));
            }
            system.debug('ic.totalIncome here1~>'+ic.totalIncome);
            
            if(aggMap!=null && aggMap.size()>0){   for(String key : aggMap.keyset()){  List<AggregateResult> aggResult = aggMap.get(key);    Double subSum = 0.00; for(AggregateResult agg:aggResult){    subSum = subSum + double.valueOf(agg.get('Credit')) - double.valueOf(agg.get('Debit'));    }   ic.incomeSubMap.put(key, subSum);
                }
            }            
            String EQuery = 'SELECT SUM(ERP7__Credit_Entry__c ) Credit, SUM(ERP7__Debit_Entry__c) Debit, ERP7__Chart_of_Account__c AccountId,ERP7__Chart_of_Account__r.Name AccountName,ERP7__Chart_of_Account__r.RecordType.DeveloperName AccountGroup,ERP7__Chart_of_Account__r.ERP7__Account_Type__c SubAccountGroup,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c ContraAccount, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c coa, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name coaName' +
                ' FROM ERP7__Finance_General_Ledger_Entry__c WHERE ERP7__Active__c = true AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) >=: start_date AND DAY_ONLY(convertTimezone(ERP7__General_Ledger_Entry_DateTime__c)) <=: end_date AND ' +
                ' ERP7__Chart_of_Account__r.RecordType.DeveloperName in (\' \',\'Expense\') AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = \'Open\' ' + qryFilter +
                ' GROUP BY ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__r.Name, ERP7__Chart_of_Account__r.ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name,ERP7__Chart_of_Account__c,ERP7__Chart_of_Account__r.RecordType.DeveloperName,ERP7__Chart_of_Account__r.ERP7__Account_Type__c ,ERP7__Chart_of_Account__r.ERP7__isContra_Account__c order by ERP7__Chart_of_Account__r.Name';
            
            List < AggregateResult > BalanceSheetData1 = Database.query(EQuery); Map<String, List < AggregateResult >> aggMapExp = new Map<String, List < AggregateResult >>();    List<icWrapper> icWrapperlist = new List<icWrapper>(); Map<String, icWrapper> mainMap = new Map<String, icWrapper>(); Map<String, List<AggregateResult>> subMap = new Map<String, List<AggregateResult>>();
            
            
            for(AggregateResult agg : BalanceSheetData1){
                if(mainMap.containsKey(String.valueOf(agg.get('SubAccountGroup')))){
                    if(String.valueOf(agg.get('coaName'))!=null){   String NameCoa = String.valueOf(agg.get('SubAccountGroup')) +'-' +String.valueOf(agg.get('coaName'));
                        if(subMap.containsKey(NameCoa)){    subMap.get(NameCoa).add(agg);}else{
                            List < AggregateResult > aggList = new List < AggregateResult >();      aggList.add(agg);     subMap.put(NameCoa, aggList);
                        }}else{icWrapper icw= mainMap.get(String.valueOf(agg.get('SubAccountGroup')));   icw.ExpenseList.add(agg);}}else{
                    if(String.valueOf(agg.get('coaName'))!=null){   String NameCoa = String.valueOf(agg.get('SubAccountGroup')) +'-' +String.valueOf(agg.get('coaName'));
                        if(subMap.containsKey(NameCoa)){    subMap.get(NameCoa).add(agg);
                        }else{        List < AggregateResult > aggList1 = new List < AggregateResult >();      aggList1.add(agg);     subMap.put(NameCoa, aggList1);
                        }
                    }else{     List < AggregateResult > aggList = new List < AggregateResult >();     aggList.add(agg);    icWrapper icwr = new icWrapper();   icwr.AccontType = String.valueOf(agg.get('SubAccountGroup'));    icwr.ExpenseList = aggList;        icWrapperlist.add(icwr);      mainMap.put(String.valueOf(agg.get('SubAccountGroup')), icwr);
                    }}
                
            }
            system.debug('subMap-->'+subMap);
            for(AggregateResult agg : BalanceSheetData1){
                String NameCoa = String.valueOf(agg.get('SubAccountGroup')) +'-' +String.valueOf(agg.get('AccountName'));
                if(subMap.containskey(NameCoa)){
                    subMap.get(NameCoa).add(agg);
                    for(icWrapper icl : icWrapperlist){
                        for(integer i=0; i<icl.ExpenseList.size(); i++){
                            if(icl.ExpenseList[i] == agg){
                                icl.ExpenseList.remove(i);
                            }
                        }
                    }
                }
            }
            if(subMap!=null && subMap.size()>0){   for(String key : subMap.keyset()){   system.debug('subMap key~>'+key);     List<String> res = key.split('-');    ledgerWrap lwrap = new ledgerWrap();  lwrap.ParentName = res[1];  lwrap.ledgerList = subMap.get(key);  for(icWrapper icl : icWrapperlist){   if(icl.AccontType == res[0]){         icl.subAccountList.add(lwrap);
                         }
                     }
                 }
            }
            ic.totalExpense = 0.00;
            double parentSum = 0.00;
            if(icWrapperlist.size()>1){  
                for(Integer i=0;i<icWrapperlist.size();i++){ //for(Integer i=0;i<2;i++){  Moin changed this on 03rd june 2024 sine calculation was not working 
                    icWrapper icl = icWrapperlist[i];  
                    parentSum = 0.00;
                    for(AggregateResult agg : icl.ExpenseList){      
                        icl.totalExpense = icl.totalExpense +double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));
                    }
                    for(ledgerWrap leg : icl.subAccountList){    
                        for(AggregateResult agg : leg.ledgerList){    
                            leg.parentSum = leg.parentSum +  double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));    
                            parentSum = parentSum + double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));
                        }
                    }   icl.totalExpense = icl.totalExpense + parentSum;
                    //system.debug('icl-->'+icl.subAccountList);
                    //}
                }
            }else{
                parentSum = 0.00; 
                for(icWrapper icl : icWrapperlist){    
                    for(AggregateResult agg : icl.ExpenseList){       
                        icl.totalExpense = icl.totalExpense + double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));
                    }
                    for(ledgerWrap leg : icl.subAccountList){  
                        for(AggregateResult agg : leg.ledgerList){     
                            leg.parentSum = leg.parentSum +  double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));   
                            parentSum = parentSum + double.valueOf(agg.get('Debit')) - double.valueOf(agg.get('Credit'));
                        }
                    }
                    icl.totalExpense = icl.totalExpense + parentSum;
                }
            }
            //system.debug('total-->'+icl.totalExpense);
            ic.wraplist = icWrapperlist; ic.incomeMap = aggMap; ic.ExpenseMap = aggMapExp; return ic;
        }catch(Exception e){
            system.debug('Exception-->'+e+'Line Number-->'+e.getLineNumber());
            return ic;
        }
    }

}