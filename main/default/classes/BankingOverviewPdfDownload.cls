public with sharing class BankingOverviewPdfDownload{
    
    public ERP7__Finance_General_Ledger__c CurrentLedger                      {get;set;}
    public String startDate                                                   {get;set;}    public String selectedIso                                                   {get;set;}
    public String endDate                                                     {get;set;}
    public double totalallDebit                                               {get;set;}
    public Decimal totalallCredit                                             {get;set;}
    public List<ERP7__Chart_of_Accounts__c> chart_Of_Accounts                 {get;set;}
    public List<ERP7__Finance_General_Ledger_Entry__c> ledgerList            {get;set;}
    public list<AcountsGroupMap> AssetsGroup                                  {get;set;}
    public list<AcountsGroupMap> LiabilityGroup                               {get;set;}
    public list<AcountsGroupMap> RevenueGroup                                 {get;set;}
    public list<AcountsGroupMap> ExpenseGroup                                 {get;set;}
    public list<AcountsGroupMap> EquityGroup                                  {get;set;} 
    public Map<Object ,AggregateResult> creditMap                             {get;set;}
    public Map<Object ,AggregateResult> debitMap                              {get;set;}
    public Map<Id,RecordType> account_Groups_map                              {get;set;}
    public String DocumentLogoUrl                                             {get;set;}
    public ERP7__Chart_of_Accounts__c totaldebit_cur_type                     {get;set;} 
    public ERP7__Chart_of_Accounts__c totalcredit_cur_type                    {get;set;} 
    public Account  trial_Balance                                             {get;set;}  
    public ERP7__Transaction__c trans                                         {get;set;} 
    public String OrgnisationName                                             {get;set;}    public String ProjectName                                                 {get;set;}
    public String coaName                                                 {get;set;}    public Date end_date                                                      {get;set;}    public Date start_date                                                    {get;set;}
    public Decimal  conversionRate                                            {get;set;}
    public Map<String, double> debitValues                                    {get;set;}
    public Map<String, double> previousdebitValues                                    {get;set;}
    public Map<String, double> creditValues                                   {get;set;}
    public Map<String, double> previouscreditValues                                   {get;set;}
    public checkMultiCurrency checkCurrency                                   {get;set;}
    
    public BankingOverviewPdfDownload() {
        try {
            /*Allocating Memeory to collections*/
            //trial_Balance = new Finance_General_Ledger_Entry__c();
            CurrentLedger = new ERP7__Finance_General_Ledger__c();
            trans = new ERP7__Transaction__c();
            ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
            AssetsGroup = new list < AcountsGroupMap > ();
            LiabilityGroup = new list < AcountsGroupMap > ();
            RevenueGroup = new list < AcountsGroupMap > ();
            EquityGroup = new list < AcountsGroupMap > ();
            ExpenseGroup = new list < AcountsGroupMap > ();
            creditMap = new Map < Object, AggregateResult > ();
            debitMap = new Map < Object, AggregateResult > ();
            totaldebit_cur_type = new ERP7__Chart_of_Accounts__c();
            totaldebit_cur_type.ERP7__Opening_Balance__c = 0.00;
            totalcredit_cur_type = new ERP7__Chart_of_Accounts__c();
            totalcredit_cur_type.ERP7__Opening_Balance__c = 0.00;
            checkCurrency = new checkMultiCurrency();
            /*Intializing Instance Variables*/
            totalallCredit = totalallDebit = 0.00;
            conversionRate = 0.00;
            debitValues = new Map<String, double>();
            previousdebitValues = new Map<String, double>();
            creditValues = new Map<String, double>();
            previouscreditValues = new Map<String, double>();
            /*Fetching RecordType of Finanace Account */
            account_Groups_map = new Map < Id, RecordType > ([Select id, DeveloperName FROM RecordType where sObjectType = 'ERP7__Chart_of_Accounts__c']);
            /*Fetching Organisation logo*/
            List < Document > docs = [Select Id, Name, DeveloperName, LastModifiedById from Document where DeveloperName = 'Company_logo'  limit 1 ];
            if (docs.size() > 0) DocumentLogoUrl = '/servlet/servlet.ImageServer?id=' + docs[0].Id + '&oid=' + UserInfo.getOrganizationId();
            else DocumentLogoUrl = '';
            OrgnisationName = '';
            coaName = apexpages.currentpage().getparameters().get('coaName');
            Account Organisation = ERP7.UtilClass.getOrganisationByLogin_Employee();
            if(Organisation.Id != null ){
                system.debug('org rows');
                OrgnisationName = Organisation.Name; trial_Balance =new Account(ERP7__Organisation__c= Organisation.id); if (trial_Balance.ERP7__Organisation__c != null) { Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id =: Userinfo.getOrganizationId()].FiscalYearStartMonth;
                    start_date = Date.newinstance((FiscalYearStartMonth == 1) ? System.today().Year() : System.today().Year() - 1, FiscalYearStartMonth, 1); startDate = start_date.format();Integer year = (FiscalYearStartMonth > 2) ? ((FiscalYearStartMonth == 1) ? System.today().Year() : System.today().Year() - 1) + 1 : ((FiscalYearStartMonth == 1) ? System.today().Year() : System.today().Year() - 1);end_date = (Date.isLeapYear(year)) ? start_date.adddays(365) : start_date.adddays(364); endDate = System.Today().format(); checkCurrency.ismultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
                    if(checkCurrency.ismultiCurrency){ String selectedIso = apexpages.currentpage().getparameters().get('CurrencyIso'); checkCurrency.selectedIso=selectedIso;String q1 ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: selectedIso'; checkCurrency.selectedconversionRate=(Decimal) Database.Query(q1)[0].get('conversionRate');checkCurrency.isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode'); String iso  = UserInfo.getDefaultCurrency(); String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso';  checkCurrency.conversionRate= (Decimal) Database.Query(q)[0].get('conversionRate'); checkCurrency.userISO = UserInfo.getDefaultCurrency(); 
                    }
                    else{                        String selectedIso = apexpages.currentpage().getparameters().get('CurrencyIso');  checkCurrency=new checkMultiCurrency(); checkCurrency.conversionRate= 1; checkCurrency.userISO = selectedIso;
                    }
                    system.debug('trial rows'); fetchTrialRows();
                }
            }
            Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); 
            if(multiCurrencyEnabled){
                String isoCode= (String) Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');                totaldebit_cur_type.put('CurrencyIsoCode',isoCode); totalcredit_cur_type.put('CurrencyIsoCode',isoCode); trans.put('CurrencyIsoCode',isoCode);
            }
        } catch (Exception e) {            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + ' Line Number @ : ' + e.getLineNumber()));
        }
    }
    
    public PageReference fetchTrialRows() {
        try {
            system.debug('trial rows 1');
            Id rTypeCredit = ERP7.RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c', 'Credit_General_Ledger_Entry');
            Id rTypeDebit = ERP7.RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c', 'Debit_General_Ledger_Entry');
            totalcredit_cur_type.ERP7__Opening_Balance__c = 0.00;
            totaldebit_cur_type.ERP7__Opening_Balance__c = 0.00;
            creditMap.clear();
            debitMap.clear();
            AssetsGroup.clear();
            RevenueGroup.clear();
            EquityGroup.clear();
            LiabilityGroup.clear();
            ExpenseGroup.clear();
            totalallCredit = 0.0;
            totalalldebit = 0.0;
            Date sDate;
            if(apexpages.currentpage().getparameters().get('stDate')!=''){
                sDate = Date.valueOf(apexpages.currentpage().getparameters().get('stDate'));
            }
            Date eDate = Date.valueOf(apexpages.currentpage().getparameters().get('enDate'));
            if(apexpages.currentpage().getparameters().get('stDate')!='') startDate = sDate.format();
            endDate = eDate.format();
            eDate = eDate + 1;
            system.debug('trial rows 136');
            system.debug('startDate-->'+startDate);
            system.debug('org-->'+trial_Balance.ERP7__Organisation__c);
            if (trial_Balance != null) chart_Of_Accounts = [SELECT Name, ERP7__Account_Code__c, RecordTypeId, ERP7__isContra_Account__c, ERP7__Account_Type__c, RecordType.DeveloperName, ERP7__Opening_Balance__c,ERP7__Total_Credit__c,ERP7__Total_Debit__c FROM ERP7__Chart_of_Accounts__c where ERP7__Active__c = true  And ERP7__Organisation__c = :trial_Balance.ERP7__Organisation__c AND Name=:coaName];
            if (chart_Of_Accounts != null && chart_Of_Accounts.size() > 0) { CurrentLedger = [SELECT id, ERP7__Active__c, ERP7__Organisation__c, ERP7__Organisation__r.Name From ERP7__Finance_General_Ledger__c where ERP7__Active__c = true limit 1];OrgnisationName = CurrentLedger.ERP7__Organisation__r.Name;
                if (CurrentLedger != null) { String project = (trans.ERP7__Project__c != Null) ? String.valueOf(trans.ERP7__Project__c) : '';  String supplier = (trans.ERP7__Supplier__c != Null) ? String.valueOf(trans.ERP7__Supplier__c) : ''; String product = (trans.ERP7__Product__c != Null) ? String.valueOf(trans.ERP7__Product__c) : ''; String employee = (trans.ERP7__Employee__c != Null) ? String.valueOf(trans.ERP7__Employee__c) : '';  String site = (trans.ERP7__Site__c != Null) ? String.valueOf(trans.ERP7__Site__c) : ''; String channel = (trans.ERP7__Channel__c != Null) ? String.valueOf(trans.ERP7__Channel__c) : ''; String industry = (trans.ERP7__Industry__c != Null) ? String.valueOf(trans.ERP7__Industry__c) : ''; String CurrentLedgerId = CurrentLedger.id; String Org = trial_Balance.ERP7__Organisation__c;String Credit = 'Credit'; String Debit = 'Debit'; String Open = 'Open';
                    system.debug('startDate-->'+startDate); system.debug('endDate-->'+endDate); system.debug('coaName-->'+coaName); if(startDate!=null && startDate!=''){
                        //Fectching all credit entries
                        String creditQuery = ' Select ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__General_Ledger_Entry_DateTime__c  from ERP7__Finance_General_Ledger_Entry__c'; creditQuery += ' Where ERP7__Active__c = true  AND ERP7__Chart_of_Account__r.Name=:coaName And ERP7__Organisation__c = :Org  And ERP7__General_Ledger_Entry_DateTime__c >= :sDate AND  ERP7__General_Ledger_Entry_DateTime__c <= :eDate AND RecordTypeId = :rTypeCredit AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = :Open';//AND ERP7__Finance_General_Ledger__c = :CurrentLedgerId
                        List<ERP7__Finance_General_Ledger_Entry__c> FGLE_Credit = Database.query(creditQuery); ledgerList = FGLE_Credit;
                        for(ERP7__Finance_General_Ledger_Entry__c f : FGLE_Credit){ if(f.ERP7__Credit_Entry__c == null)f.ERP7__Credit_Entry__c = 0; if(creditValues.get(f.ERP7__Chart_of_Account__c) != null)creditValues.put(f.ERP7__Chart_of_Account__c, creditValues.get(f.ERP7__Chart_of_Account__c)+f.ERP7__Credit_Entry__c.setScale(2)); else creditValues.put(f.ERP7__Chart_of_Account__c, f.ERP7__Credit_Entry__c);
                        }
                        //Fetching all credit entries 
                        String debitQuery = ' Select ERP7__Credit_Entry__c, ERP7__Debit_Entry__c,ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__General_Ledger_Entry_DateTime__c   from ERP7__Finance_General_Ledger_Entry__c '; debitQuery += ' Where ERP7__Active__c = true  AND ERP7__Chart_of_Account__r.Name=:coaName And ERP7__Organisation__c = :Org  And ERP7__General_Ledger_Entry_DateTime__c >= :sDate AND  ERP7__General_Ledger_Entry_DateTime__c <= :eDate AND RecordTypeId = :rTypeDebit AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = :Open';//AND ERP7__Finance_General_Ledger__c = :CurrentLedgerId
                        List<ERP7__Finance_General_Ledger_Entry__c> FGLE_Debit = Database.query(debitQuery);
                        for(ERP7__Finance_General_Ledger_Entry__c f : FGLE_Debit){  if(f.ERP7__Debit_Entry__c == null)f.ERP7__Debit_Entry__c=0;  if(debitValues.get(f.ERP7__Chart_of_Account__c) != null)debitValues.put(f.ERP7__Chart_of_Account__c, debitValues.get(f.ERP7__Chart_of_Account__c)+f.ERP7__Debit_Entry__c.setScale(2));
                            else debitValues.put(f.ERP7__Chart_of_Account__c, f.ERP7__Debit_Entry__c);
                        }
                        ledgerList.addAll(FGLE_Debit);
                    }else{
                        //Fectching all credit entries
                        String creditQuery = ' Select ERP7__Credit_Entry__c, ERP7__Debit_Entry__c, ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__General_Ledger_Entry_DateTime__c  from ERP7__Finance_General_Ledger_Entry__c'; creditQuery += ' Where ERP7__Active__c = true  AND ERP7__Chart_of_Account__r.Name=:coaName And ERP7__Organisation__c = :Org  AND  ERP7__General_Ledger_Entry_DateTime__c <= :eDate AND RecordTypeId = :rTypeCredit AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = :Open';//AND ERP7__Finance_General_Ledger__c = :CurrentLedgerId
                        List<ERP7__Finance_General_Ledger_Entry__c> FGLE_Credit = Database.query(creditQuery); ledgerList = FGLE_Credit;
                        for(ERP7__Finance_General_Ledger_Entry__c f : FGLE_Credit){ if(f.ERP7__Credit_Entry__c == null)f.ERP7__Credit_Entry__c = 0; if(creditValues.get(f.ERP7__Chart_of_Account__c) != null)creditValues.put(f.ERP7__Chart_of_Account__c, creditValues.get(f.ERP7__Chart_of_Account__c)+f.ERP7__Credit_Entry__c.setScale(2));
                            else creditValues.put(f.ERP7__Chart_of_Account__c, f.ERP7__Credit_Entry__c);
                        }
                        
                        //Fetching all credit entries 
                        String debitQuery = ' Select ERP7__Credit_Entry__c, ERP7__Debit_Entry__c,ERP7__Chart_of_Account__c, ERP7__Chart_of_Account__r.Name, ERP7__General_Ledger_Entry_DateTime__c   from ERP7__Finance_General_Ledger_Entry__c ';  debitQuery += ' Where ERP7__Active__c = true  AND ERP7__Chart_of_Account__r.Name=:coaName And ERP7__Organisation__c = :Org AND  ERP7__General_Ledger_Entry_DateTime__c <= :eDate AND RecordTypeId = :rTypeDebit AND ERP7__Accounting_period__C != null AND ERP7__Accounting_period__r.ERP7__Status__c = :Open';//AND ERP7__Finance_General_Ledger__c = :CurrentLedgerId
                        List<ERP7__Finance_General_Ledger_Entry__c> FGLE_Debit = Database.query(debitQuery); for(ERP7__Finance_General_Ledger_Entry__c f : FGLE_Debit){
                            if(f.ERP7__Debit_Entry__c == null)f.ERP7__Debit_Entry__c=0; if(debitValues.get(f.ERP7__Chart_of_Account__c) != null)debitValues.put(f.ERP7__Chart_of_Account__c, debitValues.get(f.ERP7__Chart_of_Account__c)+f.ERP7__Debit_Entry__c.setScale(2)); else debitValues.put(f.ERP7__Chart_of_Account__c, f.ERP7__Debit_Entry__c);
                        }
                        ledgerList.addAll(FGLE_Debit);
                    }
                    system.debug('classficationOfAccounts-->'+ledgerList);
                    system.debug('classficationOfAccounts-->'+debitValues.size());
                    system.debug('classficationOfAccounts-->'+ creditValues.size());
                    //Calculating the debits and credits for all COA'S
                    if (debitValues.size() > 0 || creditValues.size() > 0)
                        classficationOfAccounts();
                    else {                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Financial Data Found.'); ApexPages.addMessage(myMsg);
                    }
                }
            } else {                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please setup Organisation Chart of Accounts.'); ApexPages.addMessage(myMsg);
            }
            return null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + ' Line Number @ : ' + e.getLineNumber()));
            return null;
        }
    }
    
    public PageReference classficationOfAccounts() {
        try {
            if (chart_Of_Accounts != null) {                Decimal clsngBalance=0.00;Decimal closingBalance = 0.00;Decimal openingBalance = 0.00;
                for (ERP7__Chart_of_Accounts__c temp: chart_Of_Accounts) { temp.ERP7__Opening_Balance__c = (temp.ERP7__Opening_Balance__c != null) ? temp.ERP7__Opening_Balance__c : 0.00; temp.ERP7__Total_Debit__c = (temp.ERP7__Total_Debit__c != null) ? temp.ERP7__Total_Debit__c : 0.00; temp.ERP7__Total_Credit__c = (temp.ERP7__Total_Credit__c != null) ? temp.ERP7__Total_Credit__c : 0.00;
                    if (account_Groups_map.get(temp.RecordTypeID) != null && account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Assets') { clsngBalance=0;closingBalance = 0.00;  Decimal totalCredit =  (creditValues != null)?(creditValues.get(temp.id) != null) ? creditValues.get(temp.id) : 0.00 : 0.00; Decimal totalDebit = (debitValues != null)?(debitValues.get(temp.id) != null) ? debitValues.get(temp.id) : 0.00 : 0.00; Decimal previoustotalCredit =  (previouscreditValues != null)?(previouscreditValues.get(temp.id) != null) ? previouscreditValues.get(temp.id) : 0.00 : 0.00; Decimal previoustotalDebit = (previousdebitValues != null)?(previousdebitValues.get(temp.id) != null) ? previousdebitValues.get(temp.id) : 0.00 : 0.00;  totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit; totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                        if (!temp.ERP7__isContra_Account__c) {  closingBalance = openingBalance + (totalDebit - totalCredit); clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);totalallDebit += closingBalance;
                        } else {                            closingBalance = openingBalance + (totalCredit - totalDebit); totalallCredit += closingBalance; clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);
                        }
                        //if (totalCredit>0 || totalDebit>0){ 
                        Decimal openingB=temp.ERP7__Opening_Balance__c+previoustotalDebit-previoustotalCredit;
                        if(openingB != 0.0) AssetsGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c, openingB, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        else AssetsGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        //AssetsGroup.add(new AcountsGroupMap(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, temp.ERP7__Total_Debit__c, temp.ERP7__Total_Credit__c, closingBalance, temp.ERP7__isContra_Account__c)); //} 
                    } else if (account_Groups_map.get(temp.RecordTypeID) != null && account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Liability') {  clsngBalance=0;closingBalance=0; 
                        
                        Decimal totalCredit = (creditValues != null)?(creditValues.get(temp.id) != null) ? creditValues.get(temp.id) : 0.00 : 0.00; Decimal totalDebit = (debitValues != null)?(debitValues.get(temp.id) != null) ? debitValues.get(temp.id) : 0.00 : 0.00;  Decimal previoustotalCredit =  (previouscreditValues != null)?(previouscreditValues.get(temp.id) != null) ? previouscreditValues.get(temp.id) : 0.00 : 0.00; Decimal previoustotalDebit = (previousdebitValues != null)?(previousdebitValues.get(temp.id) != null) ? previousdebitValues.get(temp.id) : 0.00 : 0.00;  closingBalance = openingBalance + (totalCredit- totalDebit); clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c); totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit; totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                        if (!temp.ERP7__isContra_Account__c) {  closingBalance = openingBalance + (totalCredit - totalDebit); clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);  totalallDebit += closingBalance;
                        } else {                            closingBalance = openingBalance + (totalDebit - totalCredit);   totalallCredit += closingBalance; clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);
                            
                        }
                        
                        totalallCredit += closingBalance;  Decimal openingB=temp.ERP7__Opening_Balance__c+previoustotalCredit-previoustotalDebit;
                        if(openingB != 0.0) LiabilityGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,openingB, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        else LiabilityGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        
                    } else if (account_Groups_map.get(temp.RecordTypeID) != null && account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Income_Revenue') { clsngBalance=0;closingBalance=0; 
                        Decimal totalCredit = (creditValues != null)?(creditValues.get(temp.id) != null) ? creditValues.get(temp.id) : 0.00 : 0.00; Decimal totalDebit = (debitValues != null)?(debitValues.get(temp.id) != null) ? debitValues.get(temp.id) : 0.00 : 0.00; Decimal previoustotalCredit =  (previouscreditValues != null)?(previouscreditValues.get(temp.id) != null) ? previouscreditValues.get(temp.id) : 0.00 : 0.00;  Decimal previoustotalDebit = (previousdebitValues != null)?(previousdebitValues.get(temp.id) != null) ? previousdebitValues.get(temp.id) : 0.00 : 0.00;
                        totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;   totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;
                        if (!temp.ERP7__isContra_Account__c) {  closingBalance = openingBalance + (totalCredit - totalDebit); clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c); totalallCredit += closingBalance;
                            
                        } else {                            closingBalance = openingBalance + (totalDebit - totalCredit); clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c); totalallDebit += closingBalance;
                            
                        }
                        
                        Decimal openingB=temp.ERP7__Opening_Balance__c+previoustotalDebit-previoustotalCredit;
                        if(openingB != 0.0) RevenueGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,openingB, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        else RevenueGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        
                    } else if (account_Groups_map.get(temp.RecordTypeID) != null && account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Expense') {clsngBalance=0;closingBalance=0; 
                        Decimal totalCredit = (creditValues != null)?(creditValues.get(temp.id) != null) ? creditValues.get(temp.id) : 0.00 : 0.00; Decimal totalDebit = (debitValues != null)?(debitValues.get(temp.id) != null) ? debitValues.get(temp.id) : 0.00 : 0.00;Decimal previoustotalCredit =  (previouscreditValues != null)?(previouscreditValues.get(temp.id) != null) ? previouscreditValues.get(temp.id) : 0.00 : 0.00;   Decimal previoustotalDebit = (previousdebitValues != null)?(previousdebitValues.get(temp.id) != null) ? previousdebitValues.get(temp.id) : 0.00 : 0.00;
                        closingBalance = openingBalance + (totalDebit -totalCredit); clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c); totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;  totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                        if (!temp.ERP7__isContra_Account__c) { closingBalance = openingBalance + (totalDebit - totalCredit); clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c); totalallDebit += closingBalance;
                        } else {                            closingBalance = openingBalance + (totalCredit - totalDebit);  totalallCredit += closingBalance; clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);
                            
                        }
                        Decimal openingB=temp.ERP7__Opening_Balance__c+previoustotalDebit-previoustotalCredit;
                        if(openingB != 0.0) ExpenseGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,openingB, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        else ExpenseGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        
                    } else if (account_Groups_map.get(temp.RecordTypeID) != null && account_Groups_map.get(temp.RecordTypeID).DeveloperName == 'Equity') { clsngBalance=0;closingBalance=0;   
                        Decimal totalCredit = (creditValues != null)?(creditValues.get(temp.id) != null) ? creditValues.get(temp.id) : 0.00 : 0.00;  Decimal totalDebit = (debitValues != null)?(debitValues.get(temp.id) != null) ? debitValues.get(temp.id) : 0.00 : 0.00;Decimal previoustotalCredit =  (previouscreditValues != null)?(previouscreditValues.get(temp.id) != null) ? previouscreditValues.get(temp.id) : 0.00 : 0.00;   Decimal previoustotalDebit = (previousdebitValues != null)?(previousdebitValues.get(temp.id) != null) ? previousdebitValues.get(temp.id) : 0.00 : 0.00; totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;  totalcredit_cur_type.ERP7__Opening_Balance__c += totalCredit;
                        if (!temp.ERP7__isContra_Account__c) { closingBalance = openingBalance + (totalDebit - totalCredit);  clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);  totalallCredit += closingBalance;
                        } else {                            closingBalance = openingBalance + (totalCredit - totalDebit);  clsngBalance = openingBalance + ( temp.ERP7__Total_Debit__c - temp.ERP7__Total_Credit__c);  totalallDebit += closingBalance;  totaldebit_cur_type.ERP7__Opening_Balance__c += totalDebit;
                        }
                        
                        Decimal openingB=temp.ERP7__Opening_Balance__c+previoustotalDebit-previoustotalCredit;
                        if(openingB != 0.0) EquityGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,openingB, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                        else EquityGroup.add(setValues(temp.Name,temp.ERP7__Account_Code__c,temp.ERP7__Opening_Balance__c, totalDebit, totalCredit, closingBalance, temp.ERP7__isContra_Account__c,checkCurrency));
                    }
                } //End of chart Accounts For Loop  
                try{
                    if(checkCurrency.ismultiCurrency){
                        if(checkCurrency.userISO != checkCurrency.isoCode){    totaldebit_cur_type.ERP7__Opening_Balance__c  = totaldebit_cur_type.ERP7__Opening_Balance__c / checkCurrency.conversionRate;   totalcredit_cur_type.ERP7__Opening_Balance__c = totalcredit_cur_type.ERP7__Opening_Balance__c / checkCurrency.conversionRate;
                        }
                    }
                }catch(Exception e){ }
            }
            return null;
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + ' Line Number @ : ' + e.getLineNumber()));
            return null; 
        }
    }
    
    public class checkMultiCurrency{
        public Boolean ismultiCurrency  {get;set;} public String  userISO          {get;set;} public String  isoCode          {get;set;}
        public double  conversionRate   {get;set;}        public String  selectedIso          {get;set;}        public double selectedconversionRate   {get;set;}
        public checkMultiCurrency(){
            ismultiCurrency = false;
            conversionRate  = 0.00;
        }
    }
    
    
    
    public static AcountsGroupMap setValues(String accountName,String accCode,Decimal opBlnce, Decimal totalDebit,Decimal cridted, Decimal clBlnce, Boolean iscontra,checkMultiCurrency multiCurrency) {
        AcountsGroupMap AG = new AcountsGroupMap();        AG.accountName = accountName;  AG.accountCode = accCode;  AG.totalDebit = totalDebit.setscale(2);  AG.iscontra = iscontra;  AG.totalCrited = cridted.setScale(2);  AG.openingBalance = opBlnce.setScale(2);   AG.closingBalance =  clBlnce.setScale(2); AG.Container = new ERP7__Transaction__c();  AG.Container.ERP7__Amount__c = totalDebit.setscale(2);  AG.NContainer = new ERP7__Transaction__c();  AG.NContainer.ERP7__Amount__c = 0-totalDebit.setscale(2); AG.opbContainer = new ERP7__Transaction__c();  AG.opbContainer.ERP7__Amount__c =AG.openingBalance.setscale(2); AG.opbNContainer = new ERP7__Transaction__c();  AG.opbNContainer.ERP7__Amount__c = 0-AG.openingBalance.setscale(2); AG.creditContainer = new ERP7__Transaction__c();  AG.creditContainer.ERP7__Amount__c =AG.totalCrited.setscale(2); AG.creditNContainer = new ERP7__Transaction__c();  AG.creditNContainer.ERP7__Amount__c = 0-AG.totalCrited.setscale(2);AG.clbContainer = new ERP7__Transaction__c(); AG.clbContainer.ERP7__Amount__c =AG.closingBalance.setscale(2);   AG.clbNContainer = new ERP7__Transaction__c();  AG.clbNContainer.ERP7__Amount__c = 0-AG.closingBalance.setscale(2);
        try{
            if(multiCurrency.ismultiCurrency){  if(multiCurrency.userISO != multiCurrency.isoCode){
                    // making conversions
                    AG.Container.ERP7__Amount__c       = AG.Container.ERP7__Amount__c / multiCurrency.conversionRate ;              AG.NContainer.ERP7__Amount__c           = AG.NContainer.ERP7__Amount__c / multiCurrency.conversionRate ;AG.opbContainer.ERP7__Amount__c    = AG.opbContainer.ERP7__Amount__c / multiCurrency.conversionRate ;       AG.opbNContainer.ERP7__Amount__c        = AG.opbNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;
                    AG.clbContainer.ERP7__Amount__c    = AG.clbContainer.ERP7__Amount__c / multiCurrency.conversionRate ;       AG.clbNContainer.ERP7__Amount__c        = AG.clbNContainer.ERP7__Amount__c / multiCurrency.conversionRate ; AG.creditContainer.ERP7__Amount__c = AG.creditContainer.ERP7__Amount__c / multiCurrency.conversionRate ;    AG.creditNContainer.ERP7__Amount__c = AG.creditNContainer.ERP7__Amount__c / multiCurrency.conversionRate ;
                    
                }
                AG.Container.put('CurrencyIsoCode',multiCurrency.isoCode);         AG.NContainer.put('CurrencyIsoCode',multiCurrency.isoCode);        AG.opbContainer.put('CurrencyIsoCode',multiCurrency.isoCode); AG.opbNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);  AG.creditContainer.put('CurrencyIsoCode',multiCurrency.isoCode);   AG.creditNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);  AG.clbContainer.put('CurrencyIsoCode',multiCurrency.isoCode); AG.clbNContainer.put('CurrencyIsoCode',multiCurrency.isoCode);
            }
        }catch(Exception e){}
        return AG;
    }
    
    
    
    public PageReference downloadAsPdf() {
        PageReference trialbalancepdf = Page.ERP7__BankingOverviewAsPDF;
        trialbalancepdf.setRedirect(false);
        return trialbalancepdf;
        
    }
    
    public class AcountsGroupMap {
        public Decimal totalDebit                          {get;set;}   public Decimal openingBalance                      {get;set;}  public Decimal closingBalance                      {get;set;}   public Decimal totalCrited                         {get;set;}   public String accountName                          {get;set;}   public String accountCode                          {get;set;}  public Boolean iscontra                            {get;set;}   public ERP7__Transaction__c Container              {get;set;}        public ERP7__Transaction__c NContainer             {get;set;}   public ERP7__Transaction__c opbContainer           {get;set;}  public ERP7__Transaction__c opbNContainer          {get;set;}   public ERP7__Transaction__c clbContainer           {get;set;}     public ERP7__Transaction__c clbNContainer          {get;set;}   public ERP7__Transaction__c creditContainer        {get;set;}  public ERP7__Transaction__c creditNContainer       {get;set;}   public Boolean IsmultiCurrencyEnabled              {get;set;}      public String isoCode                              {get;set;}
        {
            accountName = '';  accountCode = '';  totalDebit = 0.00; iscontra = false;
            this.Container       = new ERP7__Transaction__c();      this.Container.ERP7__Amount__c       = 0.00;     this.NContainer       =  new ERP7__Transaction__c();   this.NContainer.ERP7__Amount__c       = 0.00;     this.opbContainer    = new ERP7__Transaction__c();      this.opbContainer.ERP7__Amount__c    = 0.00;     this.opbNContainer    =  new ERP7__Transaction__c();   this.opbNContainer.ERP7__Amount__c    = 0.00;     this.clbContainer    = new ERP7__Transaction__c();      this.clbContainer.ERP7__Amount__c    = 0.00;     this.clbNContainer    =  new ERP7__Transaction__c();   this.clbNContainer.ERP7__Amount__c    = 0.00;     this.creditContainer = new ERP7__Transaction__c();      this.creditContainer.ERP7__Amount__c = 0.00;     this.creditNContainer =  new ERP7__Transaction__c();   this.creditNContainer.ERP7__Amount__c = 0.00;
            
            IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); if(IsmultiCurrencyEnabled){
                //isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
            }
            if(IsmultiCurrencyEnabled){
                //this.Container.put('CurrencyIsoCode',isoCode);  this.NContainer.put('CurrencyIsoCode',isoCode);  this.opbContainer.put('CurrencyIsoCode',isoCode);   this.opbNContainer.put('CurrencyIsoCode',isoCode); this.clbContainer.put('CurrencyIsoCode',isoCode);  this.clbNContainer.put('CurrencyIsoCode',isoCode);  this.creditContainer.put('CurrencyIsoCode',isoCode);  this.creditNContainer.put('CurrencyIsoCode',isoCode);
            }
        }
        public AcountsGroupMap(){
            
        }
        /*constructors*/
        /*public AcountsGroupMap(String accountName,String accCode,Decimal opBlnce, Decimal totalDebit,Decimal cridted, Decimal clBlnce, Boolean iscontra) {
this.accountName = accountName;  this.accountCode = accCode;  this.totalDebit = totalDebit.setscale(2);  this.iscontra = iscontra;  this.totalCrited = cridted.setScale(2);  this.openingBalance = opBlnce.setScale(2);   this.closingBalance =  clBlnce.setScale(2);

this.Container = new ERP7__Transaction__c();  this.Container.ERP7__Amount__c = totalDebit.setscale(2);  this.NContainer = new ERP7__Transaction__c();  this.NContainer.ERP7__Amount__c = 0-totalDebit.setscale(2);

this.opbContainer = new ERP7__Transaction__c();  this.opbContainer.ERP7__Amount__c =openingBalance.setscale(2); this.opbNContainer = new ERP7__Transaction__c();  this.opbNContainer.ERP7__Amount__c = 0-openingBalance.setscale(2);


this.creditContainer = new ERP7__Transaction__c();  this.creditContainer.ERP7__Amount__c =totalCrited.setscale(2); this.creditNContainer = new ERP7__Transaction__c();  this.creditNContainer.ERP7__Amount__c = 0-totalCrited.setscale(2);

this.clbContainer = new ERP7__Transaction__c(); this.clbContainer.ERP7__Amount__c =closingBalance.setscale(2);   this.clbNContainer = new ERP7__Transaction__c();  this.clbNContainer.ERP7__Amount__c = 0-closingBalance.setscale(2);

IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
try{
if(IsmultiCurrencyEnabled){
String iso = UserInfo.getDefaultCurrency();   String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso'; 
Decimal conRate= (Decimal) Database.Query(q)[0].get('conversionRate'); 
if(iso != isoCode){
// making conversions
this.Container.ERP7__Amount__c = this.Container.ERP7__Amount__c / conRate ; this.NContainer.ERP7__Amount__c = this.NContainer.ERP7__Amount__c / conRate ;
this.opbContainer.ERP7__Amount__c = this.opbContainer.ERP7__Amount__c / conRate ; this.opbNContainer.ERP7__Amount__c = this.opbNContainer.ERP7__Amount__c / conRate ;
this.clbContainer.ERP7__Amount__c = this.clbContainer.ERP7__Amount__c / conRate ; this.clbNContainer.ERP7__Amount__c = this.clbNContainer.ERP7__Amount__c / conRate ;
this.creditContainer.ERP7__Amount__c = this.creditContainer.ERP7__Amount__c / conRate ; this.creditNContainer.ERP7__Amount__c = this.creditNContainer.ERP7__Amount__c / conRate ;

}
this.Container.put('CurrencyIsoCode',isoCode);  this.NContainer.put('CurrencyIsoCode',isoCode);  this.opbContainer.put('CurrencyIsoCode',isoCode); this.opbNContainer.put('CurrencyIsoCode',isoCode);

this.creditContainer.put('CurrencyIsoCode',isoCode);   this.creditNContainer.put('CurrencyIsoCode',isoCode);  this.clbContainer.put('CurrencyIsoCode',isoCode); this.clbNContainer.put('CurrencyIsoCode',isoCode);
}
}catch(Exception e){}
}*/
        
        
    }
    @RemoteAction
    public static List < Account > searchOrg(String searchString) {
        List < Account > orgList = (String.isNotEmpty(searchString)) ? Database.query('Select Id, Name FROM Account where Account_Type__c=\'Organisation\' AND name like \'%' + String.escapeSingleQuotes(searchString) + '%\'') : Database.query('Select Id, Name FROM Account where Account_Type__c=\'Organisation\' ORDER BY Name');
        return orgList;
    }
}