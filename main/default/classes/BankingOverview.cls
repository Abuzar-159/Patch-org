public  With Sharing class BankingOverview {
    @AuraEnabled 
    public List<Selectoptions> getPickList                                          {get;set;}
    @AuraEnabled 
    public Account TB                                                         {get;set;}
    @AuraEnabled
    public ERP7__Finance_General_Ledger__c CurrentLedger                      {get;set;}
    @AuraEnabled
    public String startDate                                                   {get;set;}
    @AuraEnabled
    public String endDate                                                     {get;set;}
    @AuraEnabled
    public double totalallDebit                                               {get;set;}
    @AuraEnabled
    public double totalbankAcc                                              {get;set;}
    @AuraEnabled
    public double totalcreditCards                                              {get;set;}
    @AuraEnabled
    public double totalloans                                               {get;set;}
    @AuraEnabled
    public Decimal totalallCredit                                             {get;set;}
    @AuraEnabled
    public double previoustotalallDebit                                       {get;set;}
    @AuraEnabled
    public Decimal previoustotalallCredit                                     {get;set;}
    @AuraEnabled
    public List<ERP7__Chart_of_Accounts__c> chart_Of_Accounts                 {get;set;}
    @AuraEnabled
    public list<AcountsGroupMap> AssetsGroup                                  {get;set;}
    @AuraEnabled
    public list<AcountsGroupMap> LiabilityGroup                               {get;set;}
    @AuraEnabled
    public list<AcountsGroupMap> RevenueGroup                                 {get;set;}
    @AuraEnabled
    public list<AcountsGroupMap> ExpenseGroup                                 {get;set;}
    @AuraEnabled
    public list<AcountsGroupMap> EquityGroup                                  {get;set;} 
    @AuraEnabled
    public Map<Object ,AggregateResult> creditMap                             {get;set;}
    @AuraEnabled
    public Map<Object ,AggregateResult> debitMap                              {get;set;}
    @AuraEnabled
    public Map<Id,RecordType> account_Groups_map                              {get;set;}
    @AuraEnabled
    public String DocumentLogoUrl                                             {get;set;}
    @AuraEnabled
    public ERP7__Chart_of_Accounts__c totaldebit_cur_type                     {get;set;} 
    @AuraEnabled
    public ERP7__Chart_of_Accounts__c totalcredit_cur_type                    {get;set;} 
    @AuraEnabled
    public Account  trial_Balance                                             {get;set;}
    @AuraEnabled
    public ERP7__Transaction__c trans                                         {get;set;}
    @AuraEnabled
    public date                 transSdate                                    {get;set;}
    @AuraEnabled
    public date                 transEdate                                    {get;set;}
    @AuraEnabled
    public String OrgnisationName                                             {get;set;}
    @AuraEnabled
    public String ProjectName                                                 {get;set;}
    @AuraEnabled
    public Date end_date                                                      {get;set;}
    @AuraEnabled
    public Date start_date                                                    {get;set;}
    @AuraEnabled
    public Decimal  conversionRate                                            {get;set;}
    @AuraEnabled
    public Map<String, double> debitValues                                    {get;set;}
    @AuraEnabled
    public Map<String, double> previousdebitValues                            {get;set;}
    @AuraEnabled
    public Map<String, double> PreviouscreditValues                           {get;set;}
    @AuraEnabled
    public Map<String, double> creditValues                                   {get;set;}
    @AuraEnabled
    public checkMultiCurrency checkCurrency                                   {get;set;}
    @AuraEnabled
    public Boolean multiCurrencyEnabled                                       {get;set;} 
    @AuraEnabled
    public Boolean isCreditCard                                       {get;set;} 
    @AuraEnabled 
    public String ErrorMsg                                                    {get;set;}
    @AuraEnabled 
    public String isoCode                                                     {get;set;}
    @AuraEnabled 
    public String userIsoCode                                                 {get;set;}
    @AuraEnabled 
    public String CurrencyISO                                                 {get;set;}
    @AuraEnabled 
    public Decimal currencyRate                                               {get;set;} 
    
    
    
    
    
    
   @AuraEnabled 
    public static BankingOverview fetchDetails(String Ins, String selectedIso){
        BankingOverview TBD = new BankingOverview();  
        TBD.TB = new Account();
        if(Ins != null && Ins != 'null' && Ins.trim() != ''){ // changed by khaleeq as package upload failed -> && Ins.trim() != ''
        //    if (!String.isEmpty(Ins) && Ins != 'null') { 
            TBD = ( BankingOverview ) JSON.deserialize(Ins, BankingOverview.class);
        }
        try {
            TBD.multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(selectedIso != null) TBD.CurrencyISO=selectedIso;
            else TBD.CurrencyISO =  UserInfo.getDefaultCurrency();
            
            if(TBD.multiCurrencyEnabled){
                TBD.userIsoCode = TBD.CurrencyISO;
                String iso  = TBD.userIsoCode; String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso'; TBD.currencyRate= (Decimal) Database.Query(q)[0].get('conversionRate');   
            }else{
                TBD.userIsoCode = TBD.CurrencyISO;
                TBD.currencyRate=1;
            }
            TBD.getPickList = new List<Selectoptions>();
            TBD.TB =(Ins == null || Ins == 'null')?new Account():TBD.TB; 
            TBD.CurrentLedger = new ERP7__Finance_General_Ledger__c();
            if(Ins == null || Ins == 'null')TBD.trans = new ERP7__Transaction__c();
            TBD.trial_Balance =new Account();
            TBD.AssetsGroup = new list < AcountsGroupMap > ();
            TBD.LiabilityGroup = new list < AcountsGroupMap > ();
            TBD.RevenueGroup = new list < AcountsGroupMap > ();
            TBD.EquityGroup = new list < AcountsGroupMap > ();
            TBD.ExpenseGroup = new list < AcountsGroupMap > ();
            TBD.creditMap = new Map < Object, AggregateResult > ();
            TBD.debitMap = new Map < Object, AggregateResult > ();
            TBD.totaldebit_cur_type = new ERP7__Chart_of_Accounts__c();
            TBD.totaldebit_cur_type.ERP7__Opening_Balance__c = 0.00;
            TBD.totalcredit_cur_type = new ERP7__Chart_of_Accounts__c();
            TBD.totalcredit_cur_type.ERP7__Opening_Balance__c = 0.00;
            TBD.checkCurrency = new checkMultiCurrency();
            TBD.totalallCredit = TBD.totalallDebit = TBD.totalbankAcc = TBD.totalcreditCards = TBD.totalloans = 0.00;
            TBD.previoustotalallCredit = TBD.previoustotalallDebit = 0.00;
            TBD.conversionRate = 0.00;
            TBD.debitValues = new Map<String, double>();
            TBD.creditValues = new Map<String, double>();
            TBD.previousdebitValues = new Map<String, double>();
            TBD.previouscreditValues = new Map<String, double>();
            TBD.account_Groups_map = new Map < Id, RecordType > ([Select id, DeveloperName FROM RecordType where sObjectType = 'ERP7__Chart_of_Accounts__c']);
            List < Document > docs = [Select Id, Name, DeveloperName, LastModifiedById from Document where DeveloperName = 'Company_logo'  limit 1 ];
            if (docs.size() > 0) TBD.DocumentLogoUrl = '/servlet/servlet.ImageServer?id=' + docs[0].Id + '&oid=' + UserInfo.getOrganizationId();
            else TBD.DocumentLogoUrl = '';
            TBD.OrgnisationName = '';
            Account Organisation = ERP7.UtilClass.getOrganisationByLogin_Employee();
            system.debug('Organisation----'+Organisation.Id);
            if(Organisation.Id != null ){
                TBD.OrgnisationName = Organisation.Name;                TBD.trial_Balance =new Account(ERP7__Organisation__c= Organisation.id);
                TBD.TB = (Ins == null || Ins == 'null')? ERP7.UtilClass.getOrganisationByLogin_Employee():TBD.TB;
                if (TBD.trial_Balance.ERP7__Organisation__c != null) {
                    Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id =: Userinfo.getOrganizationId()].FiscalYearStartMonth;
                    TBD.start_date = Date.newinstance((FiscalYearStartMonth == 1) ? System.today().Year() : System.today().Year() - 1, FiscalYearStartMonth, 1);
                    if( TBD.transSdate == null )TBD.transSdate = TBD.start_date.addDays(304);
                    if( TBD.transSdate != null )TBD.startDate = TBD.transSdate.format();
                    Integer year = (FiscalYearStartMonth > 2) ? ((FiscalYearStartMonth == 1) ? System.today().Year() : System.today().Year() - 1) + 1 : ((FiscalYearStartMonth == 1) ? System.today().Year() : System.today().Year() - 1);
                        TBD.end_date = (Date.isLeapYear(year)) ? TBD.start_date.adddays(365) : TBD.start_date.adddays(364);
                    if( TBD.transEdate == null )TBD.transEdate = TBD.start_date.addDays(360);
                    if( TBD.transEdate != null )TBD.endDate = TBD.transEdate.format();
                    TBD.checkCurrency.ismultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
                    if(TBD.checkCurrency.ismultiCurrency){
                        TBD.checkCurrency.isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
                        String iso  = UserInfo.getDefaultCurrency();                        String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso'; 
                        TBD.checkCurrency.conversionRate= (Decimal) Database.Query(q)[0].get('conversionRate'); 
                        TBD.checkCurrency.userISO = UserInfo.getDefaultCurrency(); 
                    }
                    system.debug('End Date'+TBD.transEdate);
                    system.debug('Start Date'+TBD.transSdate);
                    TBD = fetchTrialRows(JSON.serialize(TBD));
                }
            }
            
            Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); 
            if(multiCurrencyEnabled){
                String isoCode= (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
                TBD.totaldebit_cur_type.put('CurrencyIsoCode',isoCode); TBD.totalcredit_cur_type.put('CurrencyIsoCode',isoCode); TBD.trans.put('CurrencyIsoCode',isoCode);
            }
            TBD.trial_Balance = new Account();
            TBD.trial_Balance.ERP7__Organisation__c = Organisation.id;
            List<String> picklist = new List<String>();
            picklist.add('--None--');
            Schema.DescribeFieldResult fieldResult = ERP7__Transaction__c.ERP7__Industry__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {picklist.add(f.getLabel());}
            for(integer i=0;i<=picklist.size()-1;i++)
            {
                TBD.getPickList.add(new selectOptions(picklist[i], picklist[i]));
            }
            return TBD; 
        } catch (Exception e) { return TBD; }
        //return TBD;
    }
    
    @AuraEnabled
    public static List<selectOptions> getCurrencies(){
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(IsmultiCurrencyEnabled){
            List <sObject> currencies = Database.Query('SELECT IsoCode FROM CurrencyType');
            for(sObject a : currencies){                options.add(new SelectOptions(String.valueof(a.get('IsoCode')),String.valueof(a.get('IsoCode'))));
            }
        }
        return options;
    }
    
    @AuraEnabled
    public static BankingOverview fetchTrialRows(String TBDInstance) {
        BankingOverview TBD = new BankingOverview();
       if(TBDInstance != '' && TBDInstance != null)  TBD = ( BankingOverview )JSON.deserialize(TBDInstance, BankingOverview.class); 
        try {
            BankingOverview TBDFinal = new BankingOverview();
            Id rTypeCredit = ERP7.RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c', 'Credit_General_Ledger_Entry');
            Id rTypeDebit = ERP7.RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c', 'Debit_General_Ledger_Entry');
            TBD.totalcredit_cur_type.ERP7__Opening_Balance__c = 0.00;TBD.totaldebit_cur_type.ERP7__Opening_Balance__c = 0.00; TBD.creditMap.clear(); TBD.debitMap.clear(); TBD.AssetsGroup.clear(); TBD.RevenueGroup.clear(); TBD.EquityGroup.clear(); TBD.LiabilityGroup.clear(); TBD.ExpenseGroup.clear(); TBD.totalallCredit = 0.0; TBD.totalalldebit = 0.0; Date sDate = date.parse(TBD.startDate); Date eDate = date.parse(TBD.endDate); eDate = eDate + 1; String def = '%Deferred%'; String loan = '%loan%';
            
            if (TBD.trial_Balance != null)
                TBD.chart_Of_Accounts = [SELECT Name, ERP7__IsCreditCard__c, ERP7__Account_Code__c, RecordTypeId, ERP7__isContra_Account__c, ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c,ERP7__Total_Credit__c,ERP7__Total_Debit__c FROM ERP7__Chart_of_Accounts__c where ERP7__Active__c = true And ERP7__Organisation__c = :TBD.TB.Id AND (ERP7__IsCreditCard__c=true OR ERP7__Payment_Account__c=true OR Name Like :loan)];//OR Name Like :def 
            if (TBD.chart_Of_Accounts != null && TBD.chart_Of_Accounts.size() > 0) {
                TBD.CurrentLedger = [SELECT id, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation__r.Name From ERP7__Finance_General_Ledger__c where ERP7__Active__c = true limit 1];
                TBD.OrgnisationName = TBD.CurrentLedger.ERP7__Organisation__r.Name;
                if (TBD.CurrentLedger != null) {
                    String project = (TBD.trans.ERP7__Project__c != Null) ? String.valueOf(TBD.trans.ERP7__Project__c) : '';
                    String customer = (TBD.trans.ERP7__Customer__c != Null) ? String.valueOf(TBD.trans.ERP7__Customer__c) : '';
                    String supplier = (TBD.trans.ERP7__Supplier__c != Null) ? String.valueOf(TBD.trans.ERP7__Supplier__c) : '';
                    String product = (TBD.trans.ERP7__Product__c != Null) ? String.valueOf(TBD.trans.ERP7__Product__c) : '';
                    String employee = (TBD.trans.ERP7__Employee__c != Null) ? String.valueOf(TBD.trans.ERP7__Employee__c) : '';
                    String site = (TBD.trans.ERP7__Site__c != Null) ? String.valueOf(TBD.trans.ERP7__Site__c) : '';
                    String channel = (TBD.trans.ERP7__Channel__c != Null) ? String.valueOf(TBD.trans.ERP7__Channel__c) : '';
                    String industry = (TBD.trans.ERP7__Industry__c != Null) ? String.valueOf(TBD.trans.ERP7__Industry__c) : '';
                    String CurrentLedgerId = TBD.CurrentLedger.id;
                    
                    // TBD.trial_Balance.ERP7__Organisation__c = TBD.TB.Id;
                    String Org = TBD.TB.Id; //TBD.trial_Balance.ERP7__Organisation__c;
                    
                    String Credit = 'Credit';                    String Debit = 'Debit';                     String Open = 'Open';
                    
                    //Fectching all credit entries
                    String creditQuery = ' Select ERP7__Credit_Entry__c, ERP7__Chart_of_Account__c from ERP7__Finance_General_Ledger_Entry__c';
                    creditQuery += ' Where ERP7__Active__c = true And ERP7__Organisation__c = :Org  AND  ERP7__General_Ledger_Entry_DateTime__c <= :eDate AND RecordTypeId = :rTypeCredit AND ERP7__Accounting_period__C != null ';//AND ERP7__Accounting_period__r.ERP7__Status__c = :Open //AND ERP7__Finance_General_Ledger__c = :CurrentLedgerId 
                    List<ERP7__Finance_General_Ledger_Entry__c> FGLE_Credit = Database.query(creditQuery);
                    
                    
                    for(ERP7__Finance_General_Ledger_Entry__c f : FGLE_Credit){
                        if(f.ERP7__Credit_Entry__c == null)f.ERP7__Credit_Entry__c = 0;
                        if(TBD.creditValues.get(f.ERP7__Chart_of_Account__c) != null)TBD.creditValues.put(f.ERP7__Chart_of_Account__c, TBD.creditValues.get(f.ERP7__Chart_of_Account__c)+f.ERP7__Credit_Entry__c.setScale(2));
                        else TBD.creditValues.put(f.ERP7__Chart_of_Account__c, f.ERP7__Credit_Entry__c);
                    }
                    
                    //Fetching all credit entries 
                    String debitQuery = ' Select ERP7__Debit_Entry__c,ERP7__Chart_of_Account__c  from ERP7__Finance_General_Ledger_Entry__c ';
                    debitQuery += ' Where ERP7__Active__c = true  And ERP7__Organisation__c = :Org  AND  ERP7__General_Ledger_Entry_DateTime__c <= :eDate AND RecordTypeId = :rTypeDebit AND ERP7__Accounting_period__C != null ';//AND ERP7__Accounting_period__r.ERP7__Status__c = :Open//AND ERP7__Finance_General_Ledger__c = :CurrentLedgerId
                    List<ERP7__Finance_General_Ledger_Entry__c> FGLE_Debit = Database.query(debitQuery);
                    for(ERP7__Finance_General_Ledger_Entry__c f : FGLE_Debit){
                        if(f.ERP7__Debit_Entry__c == null)f.ERP7__Debit_Entry__c=0;
                        if(TBD.debitValues.get(f.ERP7__Chart_of_Account__c) != null)TBD.debitValues.put(f.ERP7__Chart_of_Account__c, TBD.debitValues.get(f.ERP7__Chart_of_Account__c)+f.ERP7__Debit_Entry__c.setScale(2));
                        else TBD.debitValues.put(f.ERP7__Chart_of_Account__c, f.ERP7__Debit_Entry__c);
                    }
                    
                    
                    
                    //Calculating the debits and credits for all COA'S
                    //if (TBD.debitValues.size() > 0 || TBD.creditValues.size() > 0){ 
                        //TBDFinal = classficationOfAccounts(JSON.serialize(TBD));
                        
                        if (TBD.chart_Of_Accounts != null) {
                            Decimal clsngBalance=0.00;                            Decimal closingBalance = 0.00;                            Decimal openingBalance = 0.00;
                            for (ERP7__Chart_of_Accounts__c temp: TBD.chart_Of_Accounts) {
                                temp.ERP7__Opening_Balance__c = (temp.ERP7__Opening_Balance__c != null) ? temp.ERP7__Opening_Balance__c : 0.00;
                                openingBalance = temp.ERP7__Opening_Balance__c;
                                
                                Decimal previoustotalCredit =  (TBD.previouscreditValues != null)?(TBD.previouscreditValues.get(temp.id) != null) ? TBD.previouscreditValues.get(temp.id) : 0.00 : 0.00; 
                                Decimal previoustotalDebit = (TBD.previousdebitValues != null)?(TBD.previousdebitValues.get(temp.id) != null) ? TBD.previousdebitValues.get(temp.id) : 0.00 : 0.00;
                                openingBalance = openingBalance + previoustotalDebit-previoustotalCredit;
                                
                                temp.ERP7__Total_Debit__c = (temp.ERP7__Total_Debit__c != null) ? temp.ERP7__Total_Debit__c : 0.00;                                temp.ERP7__Total_Credit__c = (temp.ERP7__Total_Credit__c != null) ? temp.ERP7__Total_Credit__c : 0.00;
                                if (TBD.account_Groups_map.get(temp.RecordTypeID) != null && TBD.account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Assets') {
                                    clsngBalance=0;closingBalance = 0.00; 
                                    Decimal totalCredit =  (TBD.creditValues != null)?(TBD.creditValues.get(temp.id) != null) ? TBD.creditValues.get(temp.id) : 0.00 : 0.00; 
                                    Decimal totalDebit = (TBD.debitValues != null)?(TBD.debitValues.get(temp.id) != null) ? TBD.debitValues.get(temp.id) : 0.00 : 0.00;
                                    
                                    TBD.totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;                                    TBD.totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                                    system.debug('Debit-->'+totalDebit);
                                    system.debug('Credit-->'+totalCredit);
                                    
                                    if (!temp.ERP7__isContra_Account__c) {
                                        closingBalance = openingBalance + (totalDebit - totalCredit);                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);                                        TBD.totalallDebit += closingBalance;
                                    } else {
                                        closingBalance = openingBalance + (totalCredit - totalDebit);                                         TBD.totalallCredit += closingBalance;                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);
                                    }
                                    
                                    if(openingBalance != 0.0) TBD.AssetsGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c, openingBalance, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                    else TBD.AssetsGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                    TBD.totalbankAcc = TBD.totalbankAcc + closingBalance;
                                        
                                } else if (TBD.account_Groups_map.get(temp.RecordTypeID) != null && TBD.account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Liability') {                                    clsngBalance=0;closingBalance=0; 
                                    
                                    Decimal totalCredit = (TBD.creditValues != null)?(TBD.creditValues.get(temp.id) != null) ? TBD.creditValues.get(temp.id) : 0.00 : 0.00;                                    Decimal totalDebit = (TBD.debitValues != null)?(TBD.debitValues.get(temp.id) != null) ? TBD.debitValues.get(temp.id) : 0.00 : 0.00;
                                    
                                    if (!temp.ERP7__isContra_Account__c) {
                                        closingBalance = openingBalance + (totalCredit- totalDebit);                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Credit__c - temp.ERP7__Total_Debit__c);                                        TBD.totalallCredit += closingBalance;
                                    } else {
                                        closingBalance = openingBalance + (totalDebit - totalCredit);                                         TBD.totalallDebit += closingBalance;                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);
                                    }
                                    
                                    TBD.totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;                                    TBD.totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                                    system.debug('Debit-->'+totalDebit);
                                    system.debug('Credit-->'+totalCredit);
                                    
                                    if(openingBalance != 0.0) TBD.LiabilityGroup.add(setValuesLiabRevnue(temp.Name,temp.ERP7__Account_Code__c,openingBalance, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                    else TBD.LiabilityGroup.add(setValuesLiabRevnue(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                    if(temp.ERP7__IsCreditCard__c) TBD.totalcreditCards = TBD.totalcreditCards + closingBalance;
                                    else TBD.totalloans = TBD.totalloans + closingBalance;
                                
                                } else if (TBD.account_Groups_map.get(temp.RecordTypeID) != null && TBD.account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Income_Revenue') {
                                    
                                    clsngBalance=0;closingBalance=0; 
                                    Decimal totalCredit = (TBD.creditValues != null)?(TBD.creditValues.get(temp.id) != null) ? TBD.creditValues.get(temp.id) : 0.00 : 0.00;                                    Decimal totalDebit = (TBD.debitValues != null)?(TBD.debitValues.get(temp.id) != null) ? TBD.debitValues.get(temp.id) : 0.00 : 0.00;
                                    
                                    TBD.totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;                                    TBD.totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                                    system.debug('Debit-->'+totalDebit);
                                    system.debug('Credit-->'+totalCredit);
                                    system.debug('temp-->'+temp);
                                    if (!temp.ERP7__isContra_Account__c) {
                                        closingBalance = openingBalance + (totalCredit - totalDebit);                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);                                        TBD.totalallCredit += closingBalance;
                                    } else {
                                        closingBalance = openingBalance + (totalDebit - totalCredit);                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);                                        TBD.totalallDebit += closingBalance;
                                    }
                                    system.debug('closingBalance-->'+closingBalance);
                                    
                                    if(openingBalance != 0.0) TBD.RevenueGroup.add(setValuesLiabRevnue(temp.Name,temp.ERP7__Account_Code__c,openingBalance, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                    else TBD.RevenueGroup.add(setValuesLiabRevnue(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                       
                                } else if (TBD.account_Groups_map.get(temp.RecordTypeID) != null && TBD.account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Expense') {
                                    
                                    clsngBalance=0;closingBalance=0; 
                                    Decimal totalCredit = (TBD.creditValues != null)?(TBD.creditValues.get(temp.id) != null) ? TBD.creditValues.get(temp.id) : 0.00 : 0.00;                                    Decimal totalDebit = (TBD.debitValues != null)?(TBD.debitValues.get(temp.id) != null) ? TBD.debitValues.get(temp.id) : 0.00 : 0.00;
                                    
                                    if (!temp.ERP7__isContra_Account__c) {
                                        closingBalance = openingBalance + (totalDebit - totalCredit);                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);                                        TBD.totalallDebit += closingBalance;
                                    } else {
                                        closingBalance = openingBalance + (totalCredit - totalDebit);                                         TBD.totalallCredit += closingBalance;                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);
                                    }
                                    
                                    TBD.totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;                                    TBD.totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                                    system.debug('Debit-->'+totalDebit);
                                    system.debug('Credit-->'+totalCredit);
                                    
                                    if(openingBalance != 0.0) TBD.ExpenseGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,openingBalance, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                    else TBD.ExpenseGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                       
                                } else if (TBD.account_Groups_map.get(temp.RecordTypeID) != null && TBD.account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Equity') {
                                    
                                    clsngBalance=0;closingBalance=0;   
                                    Decimal totalCredit = (TBD.creditValues != null)?(TBD.creditValues.get(temp.id) != null) ? TBD.creditValues.get(temp.id) : 0.00 : 0.00;                                    Decimal totalDebit = (TBD.debitValues != null)?(TBD.debitValues.get(temp.id) != null) ? TBD.debitValues.get(temp.id) : 0.00 : 0.00;
                                    if (!temp.ERP7__isContra_Account__c) {
                                        closingBalance = openingBalance + (totalDebit - totalCredit);                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);                                        TBD.totalallDebit += closingBalance;
                                    } else {
                                        closingBalance = openingBalance + (totalCredit - totalDebit);                                         TBD.totalallCredit += closingBalance;                                        clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);
                                    }
                                    
                                    if(openingBalance != 0.0) TBD.EquityGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,openingBalance, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                    else TBD.EquityGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,TBD.checkCurrency));
                                }
                            } //End of chart Accounts For Loop  
                            // try{
                            if(TBD.checkCurrency.ismultiCurrency){
                                if(TBD.checkCurrency.userISO != TBD.checkCurrency.isoCode){                                    TBD.totaldebit_cur_type.ERP7__Opening_Balance__c  = TBD.totaldebit_cur_type.ERP7__Opening_Balance__c /TBD.checkCurrency.conversionRate;   TBD.totalcredit_cur_type.ERP7__Opening_Balance__c = TBD.totalcredit_cur_type.ERP7__Opening_Balance__c /TBD.checkCurrency.conversionRate;
                                }
                            }
                        }else {
                        TBD.ErrorMsg = 'No Financial Data Found.';
                    }
                }
            } else {
                TBD.ErrorMsg =  'Please setup Organisation Chart of Accounts.';
            }
            return TBD;
        } catch (Exception e) {return TBD;  }
        //return TBD;
    }
    
    public static AcountsGroupMap setValues(String accountName,String accCode,Decimal opBlnce, Decimal totalDebit,Decimal cridted, Decimal clBlnce, Boolean iscontra,checkMultiCurrency multiCurrency) {
        AcountsGroupMap AG = new AcountsGroupMap();
        AG.accountName = accountName;  AG.accountCode = accCode;  AG.totalDebit = totalDebit.setscale(2);  AG.iscontra = iscontra;  AG.totalCrited = cridted.setScale(2);  AG.openingBalance = opBlnce.setScale(2);   AG.closingBalance =  clBlnce.setScale(2);
        AG.Container = new ERP7__Transaction__c();  AG.Container.ERP7__Amount__c = totalDebit.setscale(2);  AG.NContainer = new ERP7__Transaction__c();  AG.NContainer.ERP7__Amount__c = 0-totalDebit.setscale(2);
        AG.opbContainer = new ERP7__Transaction__c();  AG.opbContainer.ERP7__Amount__c =AG.openingBalance.setscale(2); AG.opbNContainer = new ERP7__Transaction__c();  AG.opbNContainer.ERP7__Amount__c = 0-AG.openingBalance.setscale(2);
        AG.creditContainer = new ERP7__Transaction__c();  AG.creditContainer.ERP7__Amount__c =AG.totalCrited.setscale(2); AG.creditNContainer = new ERP7__Transaction__c();  AG.creditNContainer.ERP7__Amount__c = 0-AG.totalCrited.setscale(2);
        AG.clbContainer = new ERP7__Transaction__c(); AG.clbContainer.ERP7__Amount__c =AG.openingBalance.setscale(2)+totalDebit.setscale(2)-AG.totalCrited.setscale(2);   AG.clbNContainer = new ERP7__Transaction__c();  AG.clbNContainer.ERP7__Amount__c = 0-AG.closingBalance.setscale(2);
        try{
            if(multiCurrency.ismultiCurrency){ if(multiCurrency.userISO != multiCurrency.isoCode){
                    // making conversions
                    AG.Container.ERP7__Amount__c       = AG.Container.ERP7__Amount__c / multiCurrency.conversionRate ;              AG.NContainer.ERP7__Amount__c           = AG.NContainer.ERP7__Amount__c / multiCurrency.conversionRate ;                    AG.opbContainer.ERP7__Amount__c    = AG.opbContainer.ERP7__Amount__c / multiCurrency.conversionRate ;       AG.opbNContainer.ERP7__Amount__c        = AG.opbNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;                    AG.clbContainer.ERP7__Amount__c    = AG.clbContainer.ERP7__Amount__c / multiCurrency.conversionRate ;       AG.clbNContainer.ERP7__Amount__c        = AG.clbNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;                    AG.creditContainer.ERP7__Amount__c = AG.creditContainer.ERP7__Amount__c / multiCurrency.conversionRate ;    AG.creditNContainer.ERP7__Amount__c = AG.creditNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;
                    
                }
                AG.Container.put('CurrencyIsoCode',multiCurrency.isoCode);         AG.NContainer.put('CurrencyIsoCode',multiCurrency.isoCode);        AG.opbContainer.put('CurrencyIsoCode',multiCurrency.isoCode); AG.opbNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);                AG.creditContainer.put('CurrencyIsoCode',multiCurrency.isoCode);   AG.creditNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);  AG.clbContainer.put('CurrencyIsoCode',multiCurrency.isoCode); AG.clbNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);
            }
        }catch(Exception e){}
        return AG;
    }
    
    
    public static AcountsGroupMap setValuesLiabRevnue(String accountName,String accCode,Decimal opBlnce, Decimal totalDebit,Decimal cridted, Decimal clBlnce, Boolean iscontra,checkMultiCurrency multiCurrency) {
        AcountsGroupMap AG = new AcountsGroupMap();
        AG.accountName = accountName;  AG.accountCode = accCode;  AG.totalDebit = totalDebit.setscale(2);  AG.iscontra = iscontra;  AG.totalCrited = cridted.setScale(2);  AG.openingBalance = opBlnce.setScale(2);   AG.closingBalance =  clBlnce.setScale(2);
        AG.Container = new ERP7__Transaction__c();  AG.Container.ERP7__Amount__c = totalDebit.setscale(2);  AG.NContainer = new ERP7__Transaction__c();  AG.NContainer.ERP7__Amount__c = 0-totalDebit.setscale(2);
        AG.opbContainer = new ERP7__Transaction__c();  AG.opbContainer.ERP7__Amount__c =AG.openingBalance.setscale(2); AG.opbNContainer = new ERP7__Transaction__c();  AG.opbNContainer.ERP7__Amount__c = 0-AG.openingBalance.setscale(2);
        AG.creditContainer = new ERP7__Transaction__c();  AG.creditContainer.ERP7__Amount__c =AG.totalCrited.setscale(2); AG.creditNContainer = new ERP7__Transaction__c();  AG.creditNContainer.ERP7__Amount__c = 0-AG.totalCrited.setscale(2);
        AG.clbContainer = new ERP7__Transaction__c(); AG.clbContainer.ERP7__Amount__c =AG.openingBalance.setscale(2)+AG.totalCrited.setscale(2)-totalDebit.setscale(2);   AG.clbNContainer = new ERP7__Transaction__c();  AG.clbNContainer.ERP7__Amount__c = 0-AG.closingBalance.setscale(2);
        try{
            if(multiCurrency.ismultiCurrency){
                if(multiCurrency.userISO != multiCurrency.isoCode){
                    // making conversions
                    AG.Container.ERP7__Amount__c       = AG.Container.ERP7__Amount__c / multiCurrency.conversionRate ;              AG.NContainer.ERP7__Amount__c           = AG.NContainer.ERP7__Amount__c / multiCurrency.conversionRate ;                    AG.opbContainer.ERP7__Amount__c    = AG.opbContainer.ERP7__Amount__c / multiCurrency.conversionRate ;       AG.opbNContainer.ERP7__Amount__c        = AG.opbNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;                    AG.clbContainer.ERP7__Amount__c    = AG.clbContainer.ERP7__Amount__c / multiCurrency.conversionRate ;       AG.clbNContainer.ERP7__Amount__c        = AG.clbNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;                    AG.creditContainer.ERP7__Amount__c = AG.creditContainer.ERP7__Amount__c / multiCurrency.conversionRate ;    AG.creditNContainer.ERP7__Amount__c = AG.creditNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;
                    
                }
                AG.Container.put('CurrencyIsoCode',multiCurrency.isoCode);         AG.NContainer.put('CurrencyIsoCode',multiCurrency.isoCode);        AG.opbContainer.put('CurrencyIsoCode',multiCurrency.isoCode); AG.opbNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);                AG.creditContainer.put('CurrencyIsoCode',multiCurrency.isoCode);   AG.creditNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);  AG.clbContainer.put('CurrencyIsoCode',multiCurrency.isoCode); AG.clbNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);
            }
        }catch(Exception e){}
        return AG;
    }
    
    public class AcountsGroupMap {
        @AuraEnabled
        public Decimal totalDebit                          {get;set;}   
        @AuraEnabled
        public Decimal openingBalance                      {get;set;}  
        @AuraEnabled
        public Decimal closingBalance                      {get;set;}  
        @AuraEnabled
        public Decimal totalCrited                         {get;set;}
        @AuraEnabled
        public String accountName                          {get;set;}  
        @AuraEnabled
        public String accountCode                          {get;set;}  
        @AuraEnabled
        public Boolean iscontra                            {get;set;}  
        @AuraEnabled
        public ERP7__Transaction__c Container              {get;set;}
        @AuraEnabled
        public ERP7__Transaction__c NContainer             {get;set;}  
        @AuraEnabled
        public ERP7__Transaction__c opbContainer           {get;set;} 
        @AuraEnabled
        public ERP7__Transaction__c opbNContainer          {get;set;} 
        @AuraEnabled
        public ERP7__Transaction__c clbContainer           {get;set;}
        @AuraEnabled
        public ERP7__Transaction__c clbNContainer          {get;set;}  
        @AuraEnabled
        public ERP7__Transaction__c creditContainer        {get;set;} 
        @AuraEnabled
        public ERP7__Transaction__c creditNContainer       {get;set;}
        @AuraEnabled
        public Boolean IsmultiCurrencyEnabled              {get;set;}
        @AuraEnabled
        public String isoCode                              {get;set;}
        {
            accountName = '';  accountCode = '';  totalDebit = 0.00; iscontra = false;
            this.Container       = new ERP7__Transaction__c();      this.Container.ERP7__Amount__c       = 0.00;     this.NContainer       =  new ERP7__Transaction__c();   this.NContainer.ERP7__Amount__c       = 0.00;
            this.opbContainer    = new ERP7__Transaction__c();      this.opbContainer.ERP7__Amount__c    = 0.00;     this.opbNContainer    =  new ERP7__Transaction__c();   this.opbNContainer.ERP7__Amount__c    = 0.00;
            this.clbContainer    = new ERP7__Transaction__c();      this.clbContainer.ERP7__Amount__c    = 0.00;     this.clbNContainer    =  new ERP7__Transaction__c();   this.clbNContainer.ERP7__Amount__c    = 0.00;
            this.creditContainer = new ERP7__Transaction__c();      this.creditContainer.ERP7__Amount__c = 0.00;     this.creditNContainer =  new ERP7__Transaction__c();   this.creditNContainer.ERP7__Amount__c = 0.00;
            
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(IsmultiCurrencyEnabled){                isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
            if(IsmultiCurrencyEnabled){                this.Container.put('CurrencyIsoCode',isoCode);  this.NContainer.put('CurrencyIsoCode',isoCode);  this.opbContainer.put('CurrencyIsoCode',isoCode);   this.opbNContainer.put('CurrencyIsoCode',isoCode); this.clbContainer.put('CurrencyIsoCode',isoCode);  this.clbNContainer.put('CurrencyIsoCode',isoCode);  this.creditContainer.put('CurrencyIsoCode',isoCode);  this.creditNContainer.put('CurrencyIsoCode',isoCode);
            }
        }
        public AcountsGroupMap(){
            
        }
    }
    
    @AuraEnabled
    public static CustomerReceivableWrap fetchAllCustomerReceivables(Date ReceivableDate) {
        CustomerReceivableWrap cusWrap = new CustomerReceivableWrap();
        List<CustomerReceivableWrapper> receivableList = new List<CustomerReceivableWrapper>();
        Decimal totalReceivableAmount = 0;
        // Query to sum the total due amounts for all accounts (customers)
        AggregateResult[] groupedResults = [
            SELECT ERP7__Account__c, SUM(ERP7__Total_Due__c) totalDue
            FROM ERP7__Invoice__c
            WHERE ERP7__Total_Due__c != null AND ERP7__Invoice_Date__c <=:ReceivableDate
            GROUP BY ERP7__Account__c
        ];
        
        // List to store account IDs for later querying
        Set<Id> accountIds = new Set<Id>();
        
        // Loop through the aggregated results to collect account IDs
        for (AggregateResult ar : groupedResults) {            accountIds.add((Id)ar.get('ERP7__Account__c'));
        }
        
        // Query to fetch customer details from the Account object
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT Id, Name, ERP7__Email__c, Phone
             FROM Account
             WHERE Id IN :accountIds]
        );
        
        // Loop through the aggregated results and add to the wrapper list
        for (AggregateResult ar : groupedResults) {
            CustomerReceivableWrapper wrapper = new CustomerReceivableWrapper();
            Id accountId = (Id)ar.get('ERP7__Account__c');            wrapper.customerId = accountId;            wrapper.receivableAmount = (Decimal)ar.get('totalDue');            totalReceivableAmount += (Decimal)ar.get('totalDue');
            // Fetch account details from the map
            Account acc = accountMap.get(accountId);
            if (acc != null) {                wrapper.firstName = acc.Name;                wrapper.email = acc.ERP7__Email__c;                wrapper.phone = acc.Phone;
            }
            
            receivableList.add(wrapper);
        }
        cusWrap.cWrap = receivableList;
        cusWrap.totalReceivableAmount = totalReceivableAmount;
        return cusWrap;
    }
    
    // Wrapper class to hold customer receivable information and details
    public class CustomerReceivableWrapper {
        @AuraEnabled public Id customerId { get; set; }
        @AuraEnabled public Decimal receivableAmount { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        
        public CustomerReceivableWrapper() {
            customerId = null;
            receivableAmount = 0;
            firstName = '';
            lastName = '';
            email = '';
            phone = '';
        }
    }
    
    public class CustomerReceivableWrap{
        @AuraEnabled public Decimal totalReceivableAmount { get; set; }
        @AuraEnabled public List<CustomerReceivableWrapper> cWrap {get;set;}
        public CustomerReceivableWrap(){
            totalReceivableAmount = 0;
            cWrap = new List<CustomerReceivableWrapper>();
        }
    }
    @AuraEnabled
    public static vendorPayableWrap fetchAllVendorPayables(Date ReceivableDate) {
        vendorPayableWrap vendorrap = new vendorPayableWrap();
        Decimal totalPayableAmount = 0;
        List<VendorPayableWrapper> payableList = new List<VendorPayableWrapper>();
        
        // Query to sum the total amount due for all vendors
        AggregateResult[] groupedResults = [
            SELECT ERP7__Vendor__c, SUM(ERP7__Amount_Due__c) totalDue
            FROM ERP7__Bill__c
            WHERE ERP7__Amount_Due__c != null AND ERP7__Vendor_Bill_Date__c<=:ReceivableDate
            GROUP BY ERP7__Vendor__c
        ];
        
        // List to store vendor IDs for later querying
        Set<Id> vendorIds = new Set<Id>();
        
        // Loop through the aggregated results to collect vendor IDs
        for (AggregateResult ar : groupedResults) {            vendorIds.add((Id)ar.get('ERP7__Vendor__c'));
        }
        
        // Query to fetch vendor details from the Account object
        Map<Id, Account> vendorMap = new Map<Id, Account>(
            [SELECT Id, Name, Phone, ERP7__Email__c, BillingCity, BillingCountry
             FROM Account
             WHERE Id IN :vendorIds]
        );
        
        // Loop through the aggregated results and add to the wrapper list
        for (AggregateResult ar : groupedResults) {            VendorPayableWrapper wrapper = new VendorPayableWrapper();
           Id vendorId = (Id)ar.get('ERP7__Vendor__c');
            wrapper.vendorId = vendorId;            wrapper.payableAmount = (Decimal)ar.get('totalDue');            totalPayableAmount += (Decimal)ar.get('totalDue');
            // Fetch vendor details from the map
            Account vendor = vendorMap.get(vendorId);
            if (vendor != null) {
                wrapper.vendorName = vendor.Name;                wrapper.phone = vendor.Phone;                wrapper.email = vendor.ERP7__Email__c;                wrapper.billingCity = vendor.BillingCity;                wrapper.billingCountry = vendor.BillingCountry;
            }
            
            payableList.add(wrapper);
        }
        vendorrap.vwrap = payableList;
        vendorrap.totalPayableAmount = totalPayableAmount;
        return vendorrap;
    }
    
    public class vendorPayableWrap{
        @AuraEnabled public Decimal totalPayableAmount { get; set; }
        @AuraEnabled public List<VendorPayableWrapper> vwrap {get;set;}
        public vendorPayableWrap(){
            totalPayableAmount = 0;
            vwrap = new List<VendorPayableWrapper>();
        }
        
    }
    // Wrapper class to hold vendor payable information and details
    public class VendorPayableWrapper {
        @AuraEnabled public Id vendorId { get; set; }
        @AuraEnabled public Decimal payableAmount { get; set; }
        @AuraEnabled public String vendorName { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String billingCity { get; set; }
        @AuraEnabled public String billingCountry { get; set; }
        
        public VendorPayableWrapper() {
            vendorId = null;
            payableAmount = 0;
            vendorName = '';
            phone = email = '';
            billingCity = '';
            billingCountry = '';
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
    
     @AuraEnabled
public static List < Account > searchOrg(String searchString) {
List < Account > orgList = (String.isNotEmpty(searchString)) ? Database.query('Select Id, Name FROM Account where Account_Type__c=\'Organisation\' AND name like \'%' + String.escapeSingleQuotes(searchString) + '%\'') : Database.query('Select Id, Name FROM Account where Account_Type__c=\'Organisation\' ORDER BY Name');
return orgList;
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
    
    
}