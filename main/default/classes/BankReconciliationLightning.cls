/*
* LastModifiedBy - Arshad 23 Aug 2023
* Reason - Bank statements from yodlee - correct filters to add in deposit/withdrawal columns
* method - yodleeTransaction
* 
*/

public With Sharing class BankReconciliationLightning { 
    @AuraEnabled public static List<Bank_Statement__c> org_bankStmtlist               {get;set;}
    @AuraEnabled public static List<Bank_Statement__c> bankStmtlist                   {get;set;} @AuraEnabled public static Boolean showInputFile                                  {get;set;} @AuraEnabled public static Boolean showBanksection                                {get;set;}
    @AuraEnabled public static Boolean showFileData                                   {get;set;}  public String AccessToken {get;set;}
    public String ProviderId {get;set;}
    public BankReconciliationLightning(){
        showFileData = false;
        org_bankStmtlist = new List<Bank_Statement__c>();
        String yodlee = '%Yodlee%';
        Credentials__c cred = [Select Id, Name, Active__c,ERP7__Source_Drive_ID__c, ERP7__Password_Transkey__c, Channel_Id__c, ERP7__Signature__c, URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c, ERP7__Account_Id__c, ERP7__Bank_COA_ID__c  
                               From Credentials__c
                               Where Active__c =: true And
                               Name Like :yodlee order by CreatedDate desc
                               Limit 1];
        system.debug('ProviderId-->'+cred.ERP7__Source_Drive_ID__c);
        ProviderId = cred.ERP7__Source_Drive_ID__c.toString();
        Blob cryptoKey, userData, passwordData;
        cryptoKey = encodingUtil.convertFromHex(cred.Encrypted_Key__c);
        userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Username_Login__c));
        passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Password_Transkey__c));
        if(userData != null) system.debug(userData.toString());
        if(passwordData != null) system.debug(passwordData.toString());
        String requestEndPoint = cred.URL__c;//'https://development.api.yodlee.uk/ysl/auth/token'; 
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(requestEndPoint);  
        req.setMethod('POST');    
        req.setTimeout(2000); 
        req.setHeader('Content-Type','application/x-www-form-urlencoded');   
        req.setHeader('Api-Version','1.1');  
        req.setHeader('loginName',userData.toString());  
        String body='clientId='+userData.toString()+'&secret='+passwordData.toString();  
        req.setBody(body);
        Http http = new Http(); 
        httpResponse response=http.send(req); 
        String response_1 = response.getBody(); 
        Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
        Object data = (Object)results.get('token');  
        Map<String,Object> mainresults=(Map<String,Object>)data; 
        system.debug('mainresults-->'+mainresults);
        if(mainresults != null){            AccessToken=String.valueOf(mainresults.get('accessToken'));   String issuedAt = String.valueOf(mainresults.get('issuedAt'));
            system.debug('AccessToken-->'+AccessToken);    system.debug('issuedAt-->'+issuedAt);
        }
        
    }
    
    
    public PageReference navigateToPage1() {        return Page.yodlee; }// Replace Page1 with the name of your first Visualforce page
    
    
    public PageReference navigateToPage2() {        return Page.EditYodlee; }// Replace Page2 with the name of your second Visualforce page
    
    
    // Wrapper Classes
    public class BRconcileWrp{
        @AuraEnabled
        public ERP7__Bank_Reconciliation__c BankRecon_obj           {get;set;}
        @AuraEnabled
        public list<ERP7__Bank_Statement__c> bankStmtlist           {get;set;}
        @AuraEnabled
        public list<Account> OrganisationId                         {get;set;}
        public BRconcileWrp(){
            BankRecon_obj=null;
            bankStmtlist=null;
            OrganisationId=null;
        }
    }
    
    public class WrapperTransaclist{
        public ERP7__Transaction__c tobj  {get;set;}
        public WrapperTransaclist(ERP7__Transaction__c t){
            tobj=t;
        }
        
    }
    
    public class WrapperBankUnReconcile{   
        @AuraEnabled
        public ERP7__Bank_Transaction__c bTrans                          {get;set;}
        @AuraEnabled
        public Bank_Statement__c bStmt                                  {get;set;}
        @AuraEnabled
        public List<ERP7__Transaction__c>   tTranslist                  {get;set;}
        @AuraEnabled
        public set<ERP7__Bank_Transaction__c> related_BankTransaction_Ids     {get;set;}
        public WrapperBankUnReconcile()
        {
            bTrans = null; bStmt = null; tTranslist = new List<ERP7__Transaction__c>();
            related_BankTransaction_Ids= new set<ERP7__Bank_Transaction__c>();
        }
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        public selectOptions(String lab, string val) { label = lab; value = val; }
    }
    
    //Retreiving Bank Statement
    @AuraEnabled
    public static BRconcileWrp retrieveDetails(String bankAccid, String bReconcileId){
        BRconcileWrp brwrp=new BRconcileWrp();
        try{
            String query2='select id,Name,ERP7__Organisation__c,ERP7__Bank_Account__c,ERP7__Status__c,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Beginning_Balance__c,ERP7__Ending_Balance__c,ERP7__Uncleared_Amount__c,ERP7__Calculated_Ending_Balance__c,ERP7__Cleared_Deposit__c,ERP7__Cleared_Disbursement__c,ERP7__Organisation__r.Name,ERP7__Bank_Account__r.Account_Number__c From ERP7__Bank_Reconciliation__c where id =:bReconcileId';
            brwrp.BankRecon_obj=database.query(query2);
            brwrp.bankStmtlist = [SELECT id,ERP7__Balance__c,ERP7__Bank_Account__c,ERP7__Deposits__c,ERP7__Reference_Number__c,ERP7__Cheque_Number__c,ERP7__Transaction_Date__c,ERP7__Transaction_Mode__c,ERP7__Transaction_Summary__c,ERP7__Withdrawals__c,ERP7__Bank_Reconciliation__c FROM ERP7__Bank_Statement__c where ERP7__Bank_Account__c =: brwrp.BankRecon_obj.ERP7__Bank_Account__c  AND ERP7__Status__c = 'UnReconciled' AND ERP7__Bank_Reconciliation__c =: brwrp.BankRecon_obj.id ];
            brwrp.OrganisationId=[select Name from Account where ERP7__Account_Type__C = 'Organisation'];
            
        }
        catch(Exception ex){ /*'retrieveDetails ex=>'+ex.getMessage()+' @'+ex.getLineNumber()*/ } 
        return brwrp;
    }
    
    
    @AuraEnabled
    public static String processAutoReconcile(String bankTrans) {
        try{
            List<ERP7__Bank_Transaction__c> bankTransList = (List<ERP7__Bank_Transaction__c>) JSON.deserialize(bankTrans, List<ERP7__Bank_Transaction__c>.class);
            set<Id> bstatIds = new set<Id>();
            set<Id> transIds = new set<Id>();
            for(ERP7__Bank_Transaction__c btrans : bankTransList){
                bstatIds.add(btrans.ERP7__Bank_Statement__c);
                transIds.add(btrans.ERP7__Transaction__c);
            }
            if(!bstatIds.isEmpty()){
                List<ERP7__Bank_Statement__c> bstatementList = new List<ERP7__Bank_Statement__c>();
                bstatementList = [select Id, Name, ERP7__Status__c from ERP7__Bank_Statement__c where Id IN:bstatIds];
                for(ERP7__Bank_Statement__c bstat : bstatementList){
                    bstat.ERP7__Status__c = 'Reconciled';
                }
                update bstatementList;
            }
            if(!transIds.isEmpty()){
                List<ERP7__Transaction__c> transList = new List<ERP7__Transaction__c>();
                transList = [select Id, Name from ERP7__Transaction__c where Id IN:transIds];
                for(ERP7__Transaction__c trans : transList){
                    trans.Reconciled__c = true;
                }
                update transList;
            }
            update bankTransList;
            return null;
        }
        Catch(Exception e){
            return String.valueOf(e.getmessage());
        }
    }
    @AuraEnabled
    public static List<ERP7__Bank_Transaction__c> fetchAutoReconcileRecords(String bReconcileId) {
        System.debug('bReconcileId-->' + bReconcileId);
        List<ERP7__Bank_Transaction__c> bankTransactionList = new List<ERP7__Bank_Transaction__c>();
        
        try {
            // Fetching Bank Statements
            List<ERP7__Bank_Statement__c> bankStatementList = [
                SELECT Id, ERP7__Balance__c, ERP7__Bank_Account__c, ERP7__Deposits__c, ERP7__Reference_Number__c,
                ERP7__Cheque_Number__c, ERP7__Transaction_Date__c, ERP7__Transaction_Mode__c, ERP7__Transaction_Summary__c,
                ERP7__Withdrawals__c, ERP7__Bank_Reconciliation__c 
                FROM ERP7__Bank_Statement__c 
                WHERE ERP7__Bank_Reconciliation__c = :bReconcileId 
            ];
            
            System.debug('bankStatementList-->' + bankStatementList);
            if (bankStatementList.isEmpty()) {
                return bankTransactionList;
            }
            
            // Collecting Bank Account IDs
            Set<Id> bankAccountIds = new Set<Id>();
            Map<Id, Id> bancoaMap = new Map<Id, Id>();
            
            for (ERP7__Bank_Statement__c bankStatement : bankStatementList) {
                bankAccountIds.add(bankStatement.ERP7__Bank_Account__c);
            }
            
            // Fetching Chart of Accounts
            if (!bankAccountIds.isEmpty()) {
                List<ERP7__Chart_of_Accounts__c> coaList = [
                    SELECT Id, Name, ERP7__Bank_Account__c 
                    FROM ERP7__Chart_of_Accounts__c 
                    WHERE ERP7__Bank_Account__c IN :bankAccountIds
                ];
                
                for (ERP7__Chart_of_Accounts__c coa : coaList) {
                    bancoaMap.put(coa.ERP7__Bank_Account__c, coa.Id);
                }
            }
            
            System.debug('bankAccountIds-->' + bancoaMap.values());
            
            // Fetching Ledger Entries
            List<ERP7__Finance_General_Ledger_Entry__c> ledgerEntries = [
                SELECT Id, ERP7__Debit_Entry__c, ERP7__Transactions__r.Name, ERP7__Credit_Entry__c, ERP7__Chart_of_Account__c, ERP7__Transactions__c, 
                ERP7__General_Ledger_Entry_DateTime__c
                FROM ERP7__Finance_General_Ledger_Entry__c 
                WHERE ERP7__Chart_of_Account__c IN :bancoaMap.values()
            ];
            
            System.debug('ledgerEntries-->' + ledgerEntries.size());
            
            // Mapping Ledger Entries
            Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>> ledgerEntryMap = new Map<Id, List<ERP7__Finance_General_Ledger_Entry__c>>();
            for (ERP7__Finance_General_Ledger_Entry__c ledgerEntry : ledgerEntries) {
                if(ledgerEntryMap.containskey(ledgerEntry.ERP7__Chart_of_Account__c)){
                    ledgerEntryMap.get(ledgerEntry.ERP7__Chart_of_Account__c).add(ledgerEntry);
                }else{
                    List<ERP7__Finance_General_Ledger_Entry__c> fgle = new List<ERP7__Finance_General_Ledger_Entry__c>();
                    fgle.add(ledgerEntry);
                    ledgerEntryMap.put(ledgerEntry.ERP7__Chart_of_Account__c, fgle);
                }
            }
            
            // Processing Bank Statements and Ledger Entries
            for (ERP7__Bank_Statement__c bs : bankStatementList) {
                system.debug('bs-->'+bs);
                if(ledgerEntryMap.containskey(bancoaMap.get(bs.ERP7__Bank_Account__c))){
                    for(ERP7__Finance_General_Ledger_Entry__c fgle : ledgerEntryMap.get(bancoaMap.get(bs.ERP7__Bank_Account__c))){
                        system.debug('fgle-->'+fgle);
                        if (fgle != null && bs.ERP7__Transaction_Date__c==Date.valueOf(fgle.ERP7__General_Ledger_Entry_DateTime__c) && ((bs.ERP7__Deposits__c!=null && bs.ERP7__Deposits__c>0 && (bs.ERP7__Deposits__c==fgle.ERP7__Debit_Entry__c)) || (bs.ERP7__Withdrawals__c!=null && bs.ERP7__Withdrawals__c>0 && (bs.ERP7__Withdrawals__c==fgle.ERP7__Credit_Entry__c)))) {
                            ERP7__Bank_Transaction__c temp = new ERP7__Bank_Transaction__c();
                            
                            if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Reconciliation__c.isCreateable()) {
                                temp.ERP7__Bank_Reconciliation__c = bReconcileId;
                            }
                            if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isCreateable() && 
                                Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isUpdateable()) {
                                    temp.ERP7__Transaction__c = fgle.ERP7__Transactions__c;
                                }
                            if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Statement__c.isCreateable() && 
                                Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Statement__c.isUpdateable()) {
                                    temp.ERP7__Bank_Statement__c = bs.Id;
                                }
                            if (bs.ERP7__Deposits__c != null && bs.ERP7__Deposits__c > 0) {
                                if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isCreateable() && 
                                    Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isUpdateable()) {
                                        temp.ERP7__Debit__c = fgle.ERP7__Debit_Entry__c;
                                        temp.ERP7__Statement_Amount__c = bs.ERP7__Deposits__c;
                                        temp.ERP7__Statement_Type__c = 'Received'; 
                                    }
                            } else if (bs.ERP7__Withdrawals__c != null && bs.ERP7__Withdrawals__c > 0) {
                                if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isCreateable() && 
                                    Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isUpdateable()) {
                                        temp.ERP7__Disbursement__c = fgle.ERP7__Credit_Entry__c;
                                        temp.ERP7__Statement_Amount__c = bs.ERP7__Withdrawals__c;
                                        temp.ERP7__Statement_Type__c = 'Spent';
                                    }
                            }
                            if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Cleared_Date__c.isCreateable() && 
                                Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Cleared_Date__c.isUpdateable()) {
                                    temp.ERP7__Cleared_Date__c = System.Today();
                                }
                            temp.ERP7__Transaction_Date__c = bs.ERP7__Transaction_Date__c;
                            temp.ERP7__Internal_Reference__c = fgle.ERP7__Transactions__r.Name;
                            temp.ERP7__Transaction_Summary__c = bs.ERP7__Transaction_Summary__c;
                            bankTransactionList.add(temp);
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Exception in fetchAutoReconcileRecords: ' + ex.getMessage() + ' at line ' + ex.getLineNumber());
        }
        System.debug('bankTransactionList-->' + bankTransactionList);
        return bankTransactionList;
    }


    
    //Updating Bank Reconciliation
    @AuraEnabled
    public static string updateBankReconciliation(String BRRec){
        try{
            ERP7__Bank_Reconciliation__c BankReconciliationRec = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BRRec, ERP7__Bank_Reconciliation__c.class);
            if(BankReconciliationRec != null) {
                if(Schema.SObjectType.ERP7__Bank_Reconciliation__c.isCreateable() && Schema.SObjectType.ERP7__Bank_Reconciliation__c.isUpdateable()){upsert BankReconciliationRec;} else {/*No access*/}
            } 
            return ''; } catch (Exception ex){ return ex.getMessage(); }
    }
    
    //Fetching Document
    @AuraEnabled
    Public static DOCUMENT fetchDocuments(){
        DOCUMENT doc = [SELECT id FROM DOCUMENT WHERE DeveloperName = 'Bank_Statement_Template_xlsx'];
        return doc;
    }
    
    @AuraEnabled
    public static List<selectOptions> getTransactionStatus(){
        List<selectOptions> options = new List<selectOptions>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Transaction__c.ERP7__Transaction_Type__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(new SelectOptions(f.getLabel(), f.getValue())); 
        return options;
    }
    
    @AuraEnabled
    public static List<selectOptions> getTransactionType(){
        List<selectOptions> options = new List<selectOptions>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Transaction__c.ERP7__Finance_Category_Type__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(new SelectOptions(f.getLabel(), f.getValue())); 
        return options;
    }
    
    @AuraEnabled
    public static void importedDetails(){
    }
    
    //Importing File
    @AuraEnabled
    public static List<Bank_Statement__c> importCSVFile(String BankRecon_obj1,String selectedBankAccount, String csvAsString) {
        system.debug('csvAsString-->'+csvAsString);
        //ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BRRec, ERP7__Bank_Reconciliation__c.class);
        
        try{
            ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
            List<Bank_Statement__c> org_bankStmtlist = new List<Bank_Statement__c>();
            if(String.isNotBlank(selectedBankAccount) && !selectedBankAccount.equals('null')){
                String[] csvFileLines = csvAsString.split('\n');
                system.debug('csvFileLines-->'+csvFileLines.size());
                for(Integer i=1;i<csvFileLines.size();i++) {
                    Bank_Statement__c  bankStmt = new Bank_Statement__c(); 
                    if(Schema.sObjectType.Bank_Statement__c.fields.Bank_Account__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Bank_Account__c.isUpdateable()){
                        bankStmt.Bank_Account__c = selectedBankAccount;
                    }else{/*No access*/}                    
                    if(Schema.sObjectType.Bank_Statement__c.fields.Bank_Reconciliation__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Bank_Reconciliation__c.isUpdateable()){
                        bankStmt.Bank_Reconciliation__c = BankRecon_obj.id;
                    }else{/*No access*/}
                    string[] csvRecordData = csvFileLines[i].split(',');
                    system.debug('csvRecordData-->'+csvRecordData);
                    system.debug('1-->'+csvRecordData[0]);
                    /*Add Record if it's Non Empty*/
                    if(String.isNotEmpty(csvRecordData[0])){
                        if(Schema.sObjectType.Bank_Statement__c.fields.Transaction_Date__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Date__c.isUpdateable()) {
                            string[] dateData =  csvRecordData[0].split('/');
                            bankStmt.Transaction_Date__c =  Date.newInstance(Integer.valueOf(dateData[2]), Integer.valueOf(dateData[0]), Integer.valueOf(dateData[1]));
                        }else{/*No access*/}                        
                        if(Schema.sObjectType.Bank_Statement__c.fields.Transaction_Mode__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Mode__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Mode__c.isUpdateable() ) {                            bankStmt.Transaction_Mode__c = csvRecordData[12];                        }else{/*No access*/}                        
                        if(Schema.sObjectType.Bank_Statement__c.fields.Transaction_Summary__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Summary__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Summary__c.isUpdateable()){                             bankStmt.Transaction_Summary__c = csvRecordData[4];                        }else{/*No access*/}                        
                        if(Schema.sObjectType.Bank_Statement__c.fields.Cheque_Number__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Cheque_Number__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Cheque_Number__c.isUpdateable()){                             bankstmt.Cheque_Number__c = csvRecordData[9];                        }else{/*No access*/}                        
                        if(Schema.sObjectType.Bank_Statement__c.fields.Reference_Number__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Reference_Number__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Reference_Number__c.isUpdateable()) {                            bankstmt.Reference_Number__c = csvRecordData[8];                        }else{/*No access*/}                        
                        if(Schema.sObjectType.Bank_Statement__c.fields.Deposits__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Deposits__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Deposits__c.isUpdateable() && csvRecordData[6]=='Credit') {                            bankStmt.Deposits__c = Math.ABS(Double.valueOf(csvRecordData[7]));                        }else{/*No access*/}                        
                        if(Schema.sObjectType.Bank_Statement__c.fields.Withdrawals__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Withdrawals__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Withdrawals__c.isUpdateable() && csvRecordData[6]=='Debit') {                           bankStmt.Withdrawals__c = Math.ABS(Double.valueOf(csvRecordData[7]));                         }else{/*No access*/}       org_bankStmtlist.add(bankStmt);                    
                        /*if(Schema.sObjectType.Bank_Statement__c.fields.Balance__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Balance__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Balance__c.isUpdateable()) {
                            bankStmt.Balance__c = Double.valueOf(csvRecordData[7]);
                        }else{/*No access*}*/    
                       
                    }
                }
                
            }
            system.debug('org_bankStmtlist-->'+org_bankStmtlist);
            if(org_bankStmtlist.size()>0){                  showInputFile = false;                 if(Schema.sObjectType.Bank_Statement__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.isUpdateable()){                    DMLManager.upsertAsUser(org_bankStmtlist);                }else{/*No access*/}                 list<ERP7__Bank_Statement__c> bankStmtlist=new list<ERP7__Bank_Statement__c>();                  bankStmtlist.addAll(org_bankStmtlist);showFileData=true;showBanksection = true;                 if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.Ending_Balance__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.Ending_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.Ending_Balance__c.isUpdateable()) {                    BankRecon_obj.Ending_Balance__c = bankStmtlist[bankStmtlist.size()-1].Balance__c;                }else{/*No access*/}                 if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.isUpdateable()){                    DMLManager.upsertAsUser(BankRecon_obj);                }else{/*No access*/}                List<Bank_Reconciliation__c> BankRecon_obj_list = new List<Bank_Reconciliation__c>();                BankRecon_obj_list.add(BankRecon_obj);                    BankRecon_obj = updateInstance(BankRecon_obj_list);
                //if(Schema.sObjectType.Bank_Statement__c.fields.Balance__c.isAccessible()) BankRecon_obj.Beginning_Balance__c = bankStmtlist[0].Balance__c;
                
            }
            return org_bankStmtlist;
            
        }//end try
        Catch(Exception e){
            system.debug('Exception-->'+e+e.getLineNumber());
            /*'e'+e+'Line Number'+e.getLineNumber()*/
            return null;
        }
    }
    
    @AuraEnabled
    public static Bank_Reconciliation__c updateInstance(List<Bank_Reconciliation__c> InstanceList)
    {
        Bank_Reconciliation__c t = InstanceList[InstanceList.size()-1];
        if (Schema.sObjectType.Bank_Reconciliation__c.isAccessible())
            UtilClass.FLSCheck(new String[]{'Name','ERP7__Organisation__c','ERP7__Bank_Account__c','ERP7__Bank_Account__c','ERP7__Uncleared_Amount__c','ERP7__Cleared_Deposit__c','ERP7__Calculated_Ending_Balance__c','ERP7__Status__c','ERP7__Cleared_Disbursement__c','ERP7__Start_Date__c','ERP7__Beginning_Balance__c','ERP7__Ending_Balance__c','ERP7__End_Date__c'},'Bank_Reconciliation__c');   
        if (Schema.sObjectType.Bank_Reconciliation__c.isAccessible())
            return (t.id!= null)?[select id,Name,Organisation__c,Bank_Account__c,Status__c,Start_Date__c,End_Date__c,Beginning_Balance__c,Ending_Balance__c,Uncleared_Amount__c,Calculated_Ending_Balance__c,Cleared_Deposit__c,Cleared_Disbursement__c,Organisation__r.Name,Bank_Account__r.Account_Number__c From Bank_Reconciliation__c where id =: t.id]:new Bank_Reconciliation__c();
        return null;
        
    }
    
    
    
    public class JWT {  public String clientId {get;set;} public String secret {get;set;}    public JWT(){     clientId=null; secret=null;    }  }
    
    @AuraEnabled
    public static String genBody(String Client, String Secr){ JWT jwt=new JWT();   jwt.clientId=Client;  jwt.secret=Secr;    return JSON.serialize(jwt); }
    
    @AuraEnabled
    public static void CreateToken(){ String requestEndPoint = 'https://production.api.yodlee.uk/ysl/auth/token'; HttpRequest req = new HttpRequest(); req.setEndpoint(requestEndPoint);  req.setMethod('POST');     req.setTimeout(2000); req.setHeader('Content-Type','application/x-www-form-urlencoded');   req.setHeader('Api-Version','1.1');  req.setHeader('loginName','ea74bc69-28de-4d93-94fc-15d2441947c4_ADMIN');  String bodies=genBody('98KnhhzczrIplNSt3ZxO0IpqfUuzHPWQ','H1HbEAP36HMwqXCh');  String bodiesbuild='clientId='+'UTkm3uQYl9EztCOQ02cSyxnsCvwVTCVA'+'&secret='+'IHWhS0kTbQhTeujP';   req.setBody(bodiesbuild); Http http = new Http();  httpResponse response=http.send(req);  String response_1 = response.getBody();  Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1);  Object data = (Object)results.get('token');  Map<String,Object> mainresults=(Map<String,Object>)data; String AccessToken; if(mainresults != null)  AccessToken=String.valueOf(mainresults.get('accessToken'));}
    
    //Finding Transations
    @AuraEnabled 
    public static List<ERP7__Transaction__c> Find_and_Match(String searchString, String searchAmount, Date startDate, Date endDate, String orgId, String OrderBy, String Order){
        try{
            List<ERP7__Transaction__c> TransactionSearchList;
            if(String.isNotEmpty(searchString) && String.isNotEmpty(searchAmount)){
                Decimal amt= 0.0;
                try{amt = Decimal.valueOf(searchAmount);}catch(TypeException e){amt=0.0;}
                String sstr='%'+searchString+'%';
                if(startDate!=null){
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())                          TransactionSearchList=[SELECT Id,Name,ERP7__Transaction_Date__c,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name, ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c                                                where Reconciled__c=false AND ERP7__Organisation__c=:orgId AND ERP7__Transaction_Date__c>=:startDate AND ERP7__Transaction_Date__c<=:endDate AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or ERP7__Expense_Line_Item__c!=null)                                               And                                               ( ERP7__Expense_Line_Item__r.Name like :sstr or ERP7__Payment__r.Name like :sstr  or ERP7__Payment__r.ERP7__Bill__r.Name like :sstr                                                 or ERP7__Payment__r.ERP7__Invoice__r.Name like :sstr or ERP7__Customer__r.Name like :sstr or ERP7__Supplier__r.Name like :sstr) And                                               (ERP7__Amount__c =:amt or ERP7__Payment__r.ERP7__Invoice__r.ERP7__Invoice_Amount__c =:amt or ERP7__Payment__r.ERP7__Bill__r.ERP7__Total_Amount__c =:amt )                                            ];
                }else{
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())  
                        TransactionSearchList=[SELECT Id,Name,ERP7__Transaction_Date__c,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name, ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c 
                                               where Reconciled__c=false AND ERP7__Organisation__c=:orgId AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or ERP7__Expense_Line_Item__c!=null)
                                               And
                                               ( ERP7__Expense_Line_Item__r.Name like :sstr or ERP7__Payment__r.Name like :sstr  or ERP7__Payment__r.ERP7__Bill__r.Name like :sstr 
                                                or ERP7__Payment__r.ERP7__Invoice__r.Name like :sstr or ERP7__Customer__r.Name like :sstr or ERP7__Supplier__r.Name like :sstr) And
                                               (ERP7__Amount__c =:amt or ERP7__Payment__r.ERP7__Invoice__r.ERP7__Invoice_Amount__c =:amt or ERP7__Payment__r.ERP7__Bill__r.ERP7__Total_Amount__c =:amt )
                                              ];
                }
            }else if(String.isNotEmpty(searchString)){
                Decimal amt= 0.0;
                try{amt = Decimal.valueOf(searchAmount);}catch(TypeException e){amt=0.0;}
                String sstr='%'+searchString+'%';
                if(startDate!=null){
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())                          TransactionSearchList=[SELECT Id,Name,ERP7__Transaction_Date__c,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name,  ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c                                                where Reconciled__c=false AND ERP7__Organisation__c=:orgId AND ERP7__Transaction_Date__c>=:startDate AND ERP7__Transaction_Date__c<=:endDate AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or  ERP7__Expense_Line_Item__c!=null)                                               And                                               (  ERP7__Expense_Line_Item__r.Name like :sstr or ERP7__Payment__r.Name like :sstr  or ERP7__Payment__r.ERP7__Bill__r.Name like :sstr                                                 or ERP7__Payment__r.ERP7__Invoice__r.Name like :sstr or ERP7__Customer__r.Name like :sstr or ERP7__Supplier__r.Name like :sstr)                                               ];                }else{
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())  
                        TransactionSearchList=[SELECT Id,Name,ERP7__Transaction_Date__c,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name,  ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c 
                                               where Reconciled__c=false AND ERP7__Organisation__c=:orgId AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or  ERP7__Expense_Line_Item__c!=null)
                                               And
                                               (  ERP7__Expense_Line_Item__r.Name like :sstr or ERP7__Payment__r.Name like :sstr  or ERP7__Payment__r.ERP7__Bill__r.Name like :sstr 
                                                or ERP7__Payment__r.ERP7__Invoice__r.Name like :sstr or ERP7__Customer__r.Name like :sstr or ERP7__Supplier__r.Name like :sstr) 
                                              ];
                }
            }else if(String.isNotEmpty(searchAmount)){
                Decimal amt= 0.0;
                try{amt = Decimal.valueOf(searchAmount);}catch(TypeException e){amt=0.0;}
                String sstr='%'+searchString+'%';
                if(startDate!=null){
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())  
                        TransactionSearchList=[SELECT Id,Name,ERP7__Transaction_Date__c,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name,  ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c 
                                               where Reconciled__c=false AND ERP7__Organisation__c=:orgId  AND ERP7__Transaction_Date__c>=:startDate AND ERP7__Transaction_Date__c<=:endDate AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or  ERP7__Expense_Line_Item__c!=null)
                                               And
                                               (ERP7__Amount__c =:amt or ERP7__Payment__r.ERP7__Invoice__r.ERP7__Invoice_Amount__c =:amt or ERP7__Payment__r.ERP7__Bill__r.ERP7__Total_Amount__c =:amt )
                                              ];
                }else{
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())  
                        TransactionSearchList=[SELECT Id,Name,ERP7__Transaction_Date__c,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name,  ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c 
                                               where Reconciled__c=false AND ERP7__Organisation__c=:orgId  AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or  ERP7__Expense_Line_Item__c!=null)
                                               And
                                               (ERP7__Amount__c =:amt or ERP7__Payment__r.ERP7__Invoice__r.ERP7__Invoice_Amount__c =:amt or ERP7__Payment__r.ERP7__Bill__r.ERP7__Total_Amount__c =:amt )
                                              ];
                }
            }
            else{
                String sstr='%'+searchString+'%';
                if(startDate!=null){
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())
                        TransactionSearchList=[SELECT Id,Name,ERP7__Payment__r.ERP7__Accounts__r.Name, ERP7__Transaction_Date__c, ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name, ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c 
                                               where Reconciled__c=false AND ERP7__Organisation__c=:orgId  AND ERP7__Transaction_Date__c>=:startDate AND ERP7__Transaction_Date__c<=:endDate AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or ERP7__Expense_Line_Item__c!=null)
                                               And
                                               (  ERP7__Expense_Line_Item__r.Name like :sstr or ERP7__Payment__r.Name like :sstr  or ERP7__Payment__r.ERP7__Bill__r.Name like :sstr 
                                                or ERP7__is_Adjustment__c=true  or  ERP7__Payment__r.ERP7__Invoice__r.Name like :sstr )];
                }else{
                    if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())
                        TransactionSearchList=[SELECT Id,Name,ERP7__Payment__r.ERP7__Accounts__r.Name, ERP7__Transaction_Date__c, ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name, ERP7__Expense_Line_Item__r.Name FROM ERP7__Transaction__c 
                                               where Reconciled__c=false AND ERP7__Organisation__c=:orgId  AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or  ERP7__Expense_Line_Item__c!=null)
                                               And
                                               (  ERP7__Expense_Line_Item__r.Name like :sstr or ERP7__Payment__r.Name like :sstr  or ERP7__Payment__r.ERP7__Bill__r.Name like :sstr 
                                                or ERP7__is_Adjustment__c=true  or  ERP7__Payment__r.ERP7__Invoice__r.Name like :sstr )];
                }
            }
            if(TransactionSearchList.size()==0){   
                /*'No Transactions'*/
                return null;
            }
            else{
                List<ERP7__Transaction__c> TransList;
                List<WrapperTransaclist> TransactionWrapperList;
                if (Schema.sObjectType.ERP7__Transaction__c.isAccessible()){
                    String dynamicQuery = 'SELECT Id, Name, ERP7__is_Adjustment__c, ERP7__Amount__c, Finance_Category_Type__c, ' +
                        'ERP7__Expense_Line_Item__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Transaction_Date__c, ' +
                        'ERP7__Payment__r.ERP7__Invoice__r.Name, ERP7__Payment__r.ERP7__Accounts__r.Name ' +
                        'FROM ERP7__Transaction__c ' +
                        'WHERE Id IN :TransactionSearchList ' +
                        'AND (ERP7__Payment__c != null OR ERP7__is_Adjustment__c = true OR ERP7__Expense_Line_Item__c != null) ' +
                        'ORDER BY ';
                    
                    // Building the ORDER BY clause dynamically
                    if (OrderBy != null && Order != null) {
                        dynamicQuery += OrderBy + ' ' + Order + ', Name';
                    } else {
                        dynamicQuery += 'Name';
                    }
                    dynamicQuery += ' Limit 100';
                    // Execute the dynamic query
                    TransList = Database.query(dynamicQuery);
                }
                //TransList=[Select Id,Name,ERP7__is_Adjustment__c, ERP7__Amount__c,Finance_Category_Type__c, ERP7__Expense_Line_Item__r.Name, ERP7__Payment__c,ERP7__Payment__r.Name,ERP7__Transaction_Date__c, ERP7__Payment__r.ERP7__Invoice__r.Name, ERP7__Payment__r.ERP7__Accounts__r.Name  From ERP7__Transaction__c where  Id in :TransactionSearchList AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true or  ERP7__Expense_Line_Item__c!=null) order by :OrderBy :Order];
                return TransList;
            }
        }catch(Exception e){   
            system.debug('Exception-->'+e+e.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled 
    public static List<ERP7__Transaction__c> MatchingTrasaction(String searchAmount){
        try{
            List<ERP7__Transaction__c> TransactionSearchList;
            if(String.isNotEmpty(searchAmount)){
                Decimal amt= 0.0;
                try{amt = Decimal.valueOf(searchAmount);}catch(TypeException e){amt=0.0;}
                if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())  
                    TransactionSearchList=[SELECT Id,Name,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Transaction_Date__c, ERP7__Payment__r.Name ,ERP7__Payment__r.ERP7__Bill__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name FROM ERP7__Transaction__c 
                                           where Reconciled__c=false AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true)
                                           And
                                           ( ERP7__Amount__c =:amt or ERP7__Payment__r.ERP7__Invoice__r.ERP7__Invoice_Amount__c =:amt or ERP7__Payment__r.ERP7__Bill__r.ERP7__Total_Amount__c =:amt) order by LastModifiedDate DESC limit 1
                                          ];
            }
            
            if(TransactionSearchList.size()==0){        return null;
                                               }
            else{               List<ERP7__Transaction__c> TransList;   List<WrapperTransaclist> TransactionWrapperList; if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())   TransList=[Select Id,Name,ERP7__Payment__r.ERP7__Accounts__r.Name,ERP7__Amount__c,ERP7__Transaction_Date__c, ERP7__is_Adjustment__c, Finance_Category_Type__c,ERP7__Payment__c,ERP7__Payment__r.Name,ERP7__Payment__r.ERP7__Invoice__r.Name From ERP7__Transaction__c where  Id in :TransactionSearchList AND (ERP7__Payment__c !=null or ERP7__is_Adjustment__c=true)];                return TransList;            }        }catch(Exception e){    return null;
                           }
    }
    
    
    @AuraEnabled
    public static String ProcessReconcile(String statement1,String translist1,String BankRecon_obj1){
        try{ 
            ERP7__Bank_Statement__c statement = (ERP7__Bank_Statement__c) JSON.deserialize(statement1, ERP7__Bank_Statement__c.class);
            ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
            List < ERP7__Transaction__c > translist = (List < ERP7__Transaction__c > ) JSON.deserialize(translist1, List < ERP7__Transaction__c > .class);
            
            List<Finance_General_Ledger_Entry__c> trans_ledgerEntry=new List<Finance_General_Ledger_Entry__c>();
            Map<Id,ERP7__Transaction__c> map_transId_Rec = new Map<Id,ERP7__Transaction__c>();
            ERP7__Bank_Statement__c select_bstmt = statement;
            if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Status__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Status__c.isUpdateable()){ select_bstmt.ERP7__Status__c = 'Reconciled';}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Bank_Statement__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.isUpdateable()){DMLManager.upsertAsUser(select_bstmt);}else{/*No access*/}
            for(integer i=0;i<translist.size();i++){
                map_transId_Rec.put(translist[i].Id,translist[i]);
                if(Schema.sObjectType.ERP7__Transaction__c.fields.ERP7__Reconciled__c.isAccessible() && Schema.sObjectType.ERP7__Transaction__c.fields.ERP7__Reconciled__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.fields.ERP7__Reconciled__c.isUpdateable()) {translist[i].ERP7__Reconciled__c = true;}else{/*No access*/}
                
            }
            if(Schema.sObjectType.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.isUpdateable()){DMLManager.upsertAsUser(translist);}else{/*No access*/}
            List<ERP7__Bank_Transaction__c> Reconciled_list=new List<ERP7__Bank_Transaction__c>();
            if(map_transId_Rec.size()>0){
                if (!Schema.sObjectType.ERP7__Finance_General_Ledger_Entry__c.isAccessible()){                     return null;
                }else{
                    if(Schema.sObjectType.ERP7__Finance_General_Ledger_Entry__c.Fields.ERP7__Transactions__c.isAccessible())    
                        trans_ledgerEntry=[SELECT Id,ERP7__Transactions__c,ERP7__Transactions__r.ERP7__Finance_Category_Type__c,ERP7__Transactions__r.ERP7__Amount__c FROM ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__c in :map_transId_Rec.keyset()];
                }
                
                //Moin added this on 28th february 2024
                for(integer j=0;j<translist.size();j++){//Moin commented this for(integer j=trans_ledgerEntry.size()-1;j<trans_ledgerEntry.size();j++){ on 28th february 2024
                    ERP7__Bank_Transaction__c temp = new ERP7__Bank_Transaction__c();
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Reconciliation__c.isCreateable()){temp.ERP7__Bank_Reconciliation__c=BankRecon_obj.id;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isUpdateable()){temp.ERP7__Transaction__c=translist[j].Id;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Statement__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Statement__c.isUpdateable()){temp.ERP7__Bank_Statement__c=select_bstmt.id; }else{/*No access*/}
                    //ERP7__Finance_General_Ledger_Entry__c=trans_ledgerEntry[j].Id,
                    /*'trans_ledgerEntry[j].ERP7__Transactions__r.ERP7__Finance_Category_Type__c'+trans_ledgerEntry[j].ERP7__Transactions__r.ERP7__Finance_Category_Type__c*/
                    if(translist[j].ERP7__Finance_Category_Type__c=='Credit'){ if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isUpdateable()){temp.ERP7__Disbursement__c=translist[j].ERP7__Amount__c;}else{/*No access*/}} else if(translist[j].ERP7__Finance_Category_Type__c=='Debit'){ if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isUpdateable()){temp.ERP7__Debit__c=translist[j].ERP7__Amount__c;}else{/*No access*/}}
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Cleared_Date__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Cleared_Date__c.isUpdateable()){temp.ERP7__Cleared_Date__c= system.Today();}else{/*No access*/}
                    Reconciled_list.add(temp);
                    system.debug('temp--->'+temp);
                }
                //Moin commented this on 28th february 2024
                /*for(integer j=0;j<trans_ledgerEntry.size();j++){//Moin commented this for(integer j=trans_ledgerEntry.size()-1;j<trans_ledgerEntry.size();j++){ on 28th february 2024
                    ERP7__Bank_Transaction__c temp = new ERP7__Bank_Transaction__c();
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Reconciliation__c.isCreateable()){temp.ERP7__Bank_Reconciliation__c=BankRecon_obj.id;}else{/*No access/}
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isUpdateable()){temp.ERP7__Transaction__c=trans_ledgerEntry[j].ERP7__Transactions__c;}else{/*No access/}
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Statement__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Bank_Statement__c.isUpdateable()){temp.ERP7__Bank_Statement__c=select_bstmt.id; }else{/*No access/}
                    //ERP7__Finance_General_Ledger_Entry__c=trans_ledgerEntry[j].Id,
                    ERP7__Transaction__c t=map_transId_Rec.get(trans_ledgerEntry[j].ERP7__Transactions__c);
                    /*'trans_ledgerEntry[j].ERP7__Transactions__r.ERP7__Finance_Category_Type__c'+trans_ledgerEntry[j].ERP7__Transactions__r.ERP7__Finance_Category_Type__c/
                    if(t.ERP7__Finance_Category_Type__c=='Credit'){ if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isUpdateable()){temp.ERP7__Disbursement__c=t.ERP7__Amount__c;}else{/*No access/}} else if(t.ERP7__Finance_Category_Type__c=='Debit'){ if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isUpdateable()){temp.ERP7__Debit__c=t.ERP7__Amount__c;}else{/*No access/}}
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Cleared_Date__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Cleared_Date__c.isUpdateable()){temp.ERP7__Cleared_Date__c= system.Today();}else{/*No access/}
                    Reconciled_list.add(temp);
                    system.debug('temp--->'+temp);
                }
                */
                if(Reconciled_list.size()>0){
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.isUpdateable()){DMLManager.UpsertAsUser(Reconciled_list);}else{/*No access*/}List<Bank_Reconciliation__c> BankRecon_obj_list = new List<Bank_Reconciliation__c>();BankRecon_obj_list.add(BankRecon_obj);BankRecon_obj = updateInstance(BankRecon_obj_list);  if(BankRecon_obj.ERP7__Uncleared_Amount__c == 0.0){ if(Schema.sObjectType.Bank_Reconciliation__c.fields.ERP7__Status__c.isAccessible() && Schema.sObjectType.Bank_Reconciliation__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Bank_Reconciliation__c.fields.ERP7__Status__c.isUpdateable()){BankRecon_obj.ERP7__Status__c = 'Completed';}else{/*No access*/}}   else if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isAccessible() && Schema.sObjectType.Bank_Reconciliation__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Bank_Reconciliation__c.fields.ERP7__Status__c.isUpdateable()){ BankRecon_obj.ERP7__Status__c = 'In-Progress';}else{/*No access*/}
                }
                if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.isUpdateable()){upsert BankRecon_obj;}else{/*No access*/}
            }
            return null;    }catch(Exception de){   system.debug('Exception-->'+de+de.getLineNumber()); return null;
                                                 
                                                 
                                                }    
    }
    
    /*
@AuraEnabled
public static List<WrapperBankUnReconcile> processUnReconcile(String BankRecon_obj1){
ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
list<ERP7__Bank_Transaction__c> undoReconciledlist;
if (Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible())
utilClass.FLSCheck(new String[]{'ERP7__Bank_Reconciliation__c','ERP7__Bank_Statement__c','ERP7__Cleared_Date__c','ERP7__Debit__c ','ERP7__Disbursement__c','ERP7__Finance_General_Ledger_Entry__c','ERP7__Internal_Reference__c','ERP7__ERP7__Transaction__c'},'ERP7__Bank_Transaction__c');
utilClass.FLSCheck(new String[]{'ERP7__Transaction_Summary__c','ERP7__Transaction_Mode__c','ERP7__Transaction_Date__c ','ERP7__Reference_Number__c ','ERP7__Balance__c','ERP7__Name','ERP7__Withdrawals__c','ERP7__Deposits__c'},'Bank_Statement__c');
if (Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible())
undoReconciledlist=[SELECT id,Bank_Reconciliation__c,Bank_Statement__c,Cleared_Date__c,Debit__c ,ERP7__Disbursement__c,Finance_General_Ledger_Entry__c,Internal_Reference__c,ERP7__Transaction__c 
,Bank_Statement__r.Transaction_Mode__c,Bank_Statement__r.Transaction_Date__c ,Bank_Statement__r.Reference_Number__c ,Bank_Statement__r.Balance__c,Bank_Statement__r.Name,Bank_Statement__r.Withdrawals__c,Bank_Statement__r.Deposits__c,Transaction__r.Name,Transaction__r.Sales_Order__c,Transaction__r.Sales_Order__r.Contact__r.Name
,Transaction__r.Sales_Order__r.Contact__c,Bank_Statement__r.Transaction_Summary__c, Transaction__r.ERP7__Transaction_Date__c, Transaction__r.ERP7__Amount__c
FROM  ERP7__Bank_Transaction__c WHERE Bank_Reconciliation__c =: BankRecon_obj.id];
List<WrapperBankUnReconcile> undoReconcile_Wrapperlist = new List<WrapperBankUnReconcile>();
Map<String,WrapperBankUnReconcile> map_undoList = new Map<String,WrapperBankUnReconcile>();
List<String> listid = new List<String>();
for(ERP7__Bank_Transaction__c b: undoReconciledlist)
{
if(map_undoList.get(b.Bank_Statement__c) != null)  {
WrapperBankUnReconcile oldUndoReconcile = map_undoList.get(b.Bank_Statement__c); 
if (Schema.sObjectType.ERP7__Transaction__c.isAccessible())   {    oldUndoReconcile.tTranslist.add([Select id,Name,Sales_Order__c,Sales_Order__r.name,Sales_Order__r.Contact__r.Name, ERP7__Transaction_Date__c, ERP7__Amount__c FROM ERP7__Transaction__c where id =: b.ERP7__Transaction__c]);   } 
oldUndoReconcile.related_BankTransaction_Ids.add(b); 
if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible())  map_undoList.put(b.Bank_Statement__c,oldUndoReconcile);  
}else{
listid.clear();
Bank_Statement__c btemp = new Bank_Statement__c(id = b.Bank_Statement__c);
WrapperBankUnReconcile newUndoReconcile = new WrapperBankUnReconcile();
newUndoReconcile.bTrans=b;
newUndoReconcile.bStmt=btemp;
if(Schema.sObjectType.ERP7__Transaction__c.isAccessible())
newUndoReconcile.tTranslist.add([Select id,Name,Sales_Order__c,Sales_Order__r.name,Sales_Order__r.Contact__r.Name, ERP7__Transaction_Date__c, ERP7__Amount__c FROM ERP7__Transaction__c where id =: b.ERP7__Transaction__c]);
newUndoReconcile.related_BankTransaction_Ids.add(b);
if (Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible()) map_undoList.put(b.Bank_Statement__c,newUndoReconcile);
}

}
undoReconcile_Wrapperlist = map_undoList.values();
return undoReconcile_Wrapperlist;
}
*/
    
    @AuraEnabled
    public static List<WrapperBankUnReconcile> processUnReconcile(String BankRecon_obj1) {
        // Deserialize JSON input
        ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
        
        // Ensure Bank Transaction object accessibility
        if (!Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible()) {            return new List<WrapperBankUnReconcile>();
        }
        
        // Query for unreconciled bank transactions
        List<ERP7__Bank_Transaction__c> undoReconciledlist = [SELECT Id, Bank_Reconciliation__c, Bank_Statement__c, Cleared_Date__c, Debit__c, ERP7__Disbursement__c, Finance_General_Ledger_Entry__c, Internal_Reference__c, ERP7__Transaction__c,ERP7__Transaction__r.Name, ERP7__Transaction__r.ERP7__Transaction_Date__c, ERP7__Transaction__r.ERP7__Amount__c, 
                                                              Bank_Statement__r.Transaction_Mode__c, Bank_Statement__r.Transaction_Date__c, Bank_Statement__r.Reference_Number__c, Bank_Statement__r.Balance__c, Bank_Statement__r.Name, ERP7__Bank_Statement__r.ERP7__Transaction_Summary__c, Bank_Statement__r.Withdrawals__c, Bank_Statement__r.Deposits__c
                                                              FROM ERP7__Bank_Transaction__c
                                                              WHERE Bank_Reconciliation__c = :BankRecon_obj.Id];
        
        Map<Id, Set<Id>> bstatementMap = new Map<Id, Set<Id>>();
        Set<Id> transactionIds = new Set<Id>();
        List<ERP7__Transaction__c> transList = new List<ERP7__Transaction__c>();
        for (ERP7__Bank_Transaction__c b : undoReconciledlist) {
            transactionIds.add(b.ERP7__Transaction__c);
            if(!bstatementMap.containskey(b.Bank_Statement__c)){
                Set<Id> transId = new Set<Id>();
                transId.add(b.ERP7__Transaction__c);
                bstatementMap.put(b.Bank_Statement__c, transId);            }else{                bstatementMap.get(b.Bank_Statement__c).add(b.ERP7__Transaction__c);
            }
        }
        system.debug('transactionIds-->'+transactionIds);
        if(!bstatementMap.isEmpty() && bstatementMap!=null){
            transList = [Select id,Name,Sales_Order__c,Sales_Order__r.name,Sales_Order__r.Contact__r.Name, ERP7__Transaction_Date__c, ERP7__Amount__c FROM ERP7__Transaction__c where Id IN:transactionIds];
        }
         
        // Map to store unique bank statement IDs and their corresponding wrapper objects
        Map<Id, WrapperBankUnReconcile> map_undoList = new Map<Id, WrapperBankUnReconcile>();
        
        // Iterate over unreconciled bank transactions
        for (ERP7__Bank_Transaction__c b : undoReconciledlist) {
            WrapperBankUnReconcile wrapper;
            
            // Check if wrapper already exists for the bank statement
            if (!map_undoList.containsKey(b.Bank_Statement__c)) {
                // If not, create a new wrapper and add it to the map
                Bank_Statement__c btemp = new Bank_Statement__c(Id = b.Bank_Statement__c);
                wrapper = new WrapperBankUnReconcile();
                wrapper.bTrans = b;
                wrapper.bStmt = btemp;
                for(ERP7__Transaction__c trans : transList){
                    if(!bstatementMap.isEmpty() && bstatementMap.containskey(b.Bank_Statement__c)){
                        for(Id TransId : bstatementMap.get(b.Bank_Statement__c)){
                            if(TransId == trans.Id){
                                wrapper.tTranslist.add(trans);
                            }
                        }
                    }
                }
                map_undoList.put(b.Bank_Statement__c, wrapper);            } else {                wrapper = map_undoList.get(b.Bank_Statement__c);      map_undoList.put(b.Bank_Statement__c, wrapper);            }
            
            // Add the bank transaction to the wrapper's related transaction IDs
            wrapper.related_BankTransaction_Ids.add(b);
        }
        
        
        // Return values of the map as a list
        return new List<WrapperBankUnReconcile>(map_undoList.values());
    }
    
    
    @AuraEnabled
    public static List<ERP7__Bank_Transaction__c> CreateTransactionApex(string statement1, String newTransaction1,String BankRecon_obj1  ){
        List<ERP7__Bank_Transaction__c> Reconciled_list=new List<ERP7__Bank_Transaction__c>();
        Bank_Statement__c statement = (Bank_Statement__c) JSON.deserialize(statement1, Bank_Statement__c.class);
        ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
        ERP7__Transaction__c newTransaction = (ERP7__Transaction__c) JSON.deserialize(newTransaction1, ERP7__Transaction__c.class);
        try{
            if(Schema.sObjectType.ERP7__Transaction__c.fields.Amount__c.isAccessible())
            {
                if(Schema.sObjectType.Bank_Statement__c.fields.Status__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Status__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.fields.Status__c.isUpdateable()){statement.Status__c = 'Reconciled';}else{/*No access*/}
                if(Schema.sObjectType.Bank_Statement__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.isUpdateable()){DMLManager.upsertAsUser(statement);}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.isUpdateable()){DMLManager.upsertAsUser(newTransaction);}else{/*No access*/}
                ERP7__Bank_Transaction__c temp = new ERP7__Bank_Transaction__c();
                if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Reconciliation__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Reconciliation__c.isUpdateable()){temp.Bank_Reconciliation__c=BankRecon_obj.id;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Transaction__c.isUpdateable()){temp.ERP7__Transaction__c=newTransaction.id;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isUpdateable()){temp.Bank_Statement__c=statement.id; }else{/*No access*/}
                if(newTransaction.ERP7__Finance_Category_Type__c == 'Credit'){  if(Schema.sObjectType.ERP7__Transaction__c.fields.ERP7__Amount__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Disbursement__c.isUpdateable()){ temp.ERP7__Disbursement__c=newTransaction.ERP7__Amount__c;}else{/*No access*/}   }               else if(newTransaction.ERP7__Finance_Category_Type__c == 'Debit'){ if(Schema.sObjectType.ERP7__Transaction__c.fields.ERP7__Amount__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.ERP7__Debit__c.isUpdateable()){ temp.ERP7__Debit__c=newTransaction.ERP7__Amount__c;}else{/*No access*/}  }
                if(Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Cleared_Date__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Cleared_Date__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Cleared_Date__c.isUpdateable()){temp.Cleared_Date__c= system.Today();}else{/*No access*/}
                Reconciled_list.add(temp);
                if(Reconciled_list.size()>0){
                    if(Schema.sObjectType.ERP7__Bank_Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Transaction__c.isUpdateable()){DMLManager.upsertAsUser(Reconciled_list);}else{/*No access*/}                    List<Bank_Reconciliation__c> BankRecon_obj_list = new List<Bank_Reconciliation__c>();BankRecon_obj_list.add(BankRecon_obj);  BankRecon_obj = updateInstance(BankRecon_obj_list); if(BankRecon_obj.ERP7__Uncleared_Amount__c == 0.00){ if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isUpdateable()){BankRecon_obj.ERP7__Status__c = 'Completed';}else{/*No access*/}   } else if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isAccessible()) BankRecon_obj.ERP7__Status__c = 'In-Progress';
                    
                }               if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.isUpdateable()){upsert BankRecon_obj;}else{/*No access*/} return Reconciled_list;    }   else{         return Reconciled_list;   }
        }
        catch(Exception de){
            /*'Exception '+de+'Line Number '+de.getLineNumber()*/
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String RemoveUndoList(Integer ArrayIndex,String BankRecon_obj1,String undoReconcile_Wrapperlist_A){//List<WrapperBankUnReconcile>
        try{
            List<Bank_Statement__c> org_bankStmtlist = new List<Bank_Statement__c>();
            ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
            List < WrapperBankUnReconcile > GroupList = (List < WrapperBankUnReconcile > ) JSON.deserialize(undoReconcile_Wrapperlist_A, List < WrapperBankUnReconcile > .class);
            //list<WrapperBankUnReconcile> BankReconciliationRec = (list<WrapperBankUnReconcile>) JSON.deserialize(undoReconcile_Wrapperlist_A, WrapperBankUnReconcile.class);
            WrapperBankUnReconcile RemUndoReconcile = GroupList.remove(Integer.valueOf(ArrayIndex));
            String TransId = '';
            TransId = RemUndoReconcile.bTrans.ERP7__Transaction__c;
            Bank_Statement__c bankTempStmt = new Bank_Statement__c();
            if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Status__c.isUpdateable()){bankTempStmt.Status__c = 'UnReconciled';}else{/*No access*/}
            bankTempStmt.id = RemUndoReconcile.bTrans.ERP7__Bank_Statement__c;
            if(Schema.sObjectType.Bank_Statement__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Date__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Date__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Date__c.isUpdateable()){bankTempStmt.Transaction_Date__c = RemUndoReconcile.bTrans.Bank_Statement__r.Transaction_Date__c ;}else{/*No access*/}
            if(Schema.sObjectType.Bank_Statement__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Mode__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Mode__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Mode__c.isUpdateable()){bankTempStmt.Transaction_Mode__c= RemUndoReconcile.bTrans.Bank_Statement__r.Transaction_Mode__c ;}else{/*No access*/}
            if(Schema.sObjectType.Bank_Statement__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Transaction_Summary__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Summary__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Summary__c.isUpdateable()){ bankTempStmt.Transaction_Summary__c = RemUndoReconcile.bTrans.Bank_Statement__r.Transaction_Summary__c; }else{/*No access*/}
            if(Schema.sObjectType.Bank_Statement__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Reference_Number__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Reference_Number__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Reference_Number__c.isUpdateable()){ bankTempStmt.Reference_Number__c = RemUndoReconcile.bTrans.Bank_Statement__r.Reference_Number__c ;}else{/*No access*/}
            if(Schema.sObjectType.Bank_Statement__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Deposits__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Deposits__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Deposits__c.isUpdateable()) {bankTempStmt.Deposits__c = RemUndoReconcile.bTrans.Bank_Statement__r.Deposits__c;}else{/*No access*/}
            if(Schema.sObjectType.Bank_Statement__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Withdrawals__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Withdrawals__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Withdrawals__c.isUpdateable()){ bankTempStmt.Withdrawals__c = RemUndoReconcile.bTrans.Bank_Statement__r.Withdrawals__c;}else{/*No access*/}       
            if(Schema.sObjectType.Bank_Statement__c.isAccessible() && Schema.sObjectType.Bank_Statement__c.fields.Balance__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Transaction__c.fields.Bank_Statement__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Balance__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Balance__c.isUpdateable()){bankTempStmt.Balance__c = RemUndoReconcile.bTrans.Bank_Statement__r.Balance__c;}else{/*No access*/}
            
            if(Schema.sObjectType.Bank_Statement__c.isCreateable() && Schema.sObjectType.Bank_Statement__c.isUpdateable()){upsert bankTempStmt;}else{/*No access*/}
            List<Bank_Statement__c> bankStmtlist  =new List<Bank_Statement__c> ();
            bankStmtlist.add(bankTempStmt);
            if(ERP7__Bank_Transaction__c.sObjectType.getDescribe().isDeletable()) DMLManager.deleteAsUser((new List<ERP7__Bank_Transaction__c>(RemUndoReconcile.related_BankTransaction_Ids)));
            List<Bank_Reconciliation__c> BankRecon_obj_list = new List<Bank_Reconciliation__c>();BankRecon_obj_list.add(BankRecon_obj);
            BankRecon_obj = updateInstance(BankRecon_obj_list);
            if(TransId!='' && TransId!=null){
                ERP7__Transaction__c trans = [select Id, Name, ERP7__Reconciled__c from ERP7__Transaction__c where Id=:TransId];
                trans.ERP7__Reconciled__c = false;
                update trans;
            }
            //if(BankRecon_obj.ERP7__Uncleared_Amount__c == 0.00){ if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isUpdateable()){ BankRecon_obj.ERP7__Status__c = 'Completed';}else{/*No access*/} }// ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Success:Reconcile Done!'));}
            //else 
            if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isAccessible() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.fields.ERP7__Status__c.isUpdateable()){ BankRecon_obj.ERP7__Status__c = 'In-Progress';}else{/*No access*/}
            
            if(Schema.sObjectType.ERP7__Bank_Reconciliation__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Reconciliation__c.isUpdateable()) { upsert BankRecon_obj; } else {/*No access*/}
            return null;  }catch(Exception E){  /*'Exception'+E+'Line Number'+E.getLineNumber()*/  return null;
                                             }
        
    }
    
    @AuraEnabled
    public static List<yodleeTransractionWrap> getYodleeTransactionList(String bankAccid, DateTime startDate, DateTime endDate){
        List<yodleeTransractionWrap> trapList = new List<yodleeTransractionWrap>();
        try{
            String accountId = '';
            if(bankAccid!=null && bankAccid!=''){
                ERP7__Chart_of_Accounts__c cred = [Select Id, Name, ERP7__External_System_Id__c
                                                   From ERP7__Chart_of_Accounts__c
                                                   Where ERP7__Bank_Account__c=:bankAccid
                                                   Limit 1];
                accountId = cred.ERP7__External_System_Id__c;
            }
            
            String token = generateToken();
            token = 'Bearer '+token;
            Date myDate2 = date.newinstance(startDate.year(), startDate.month(), startDate.day());
            String sdate = String.valueOf(myDate2);
            myDate2 = date.newinstance(endDate.year(), endDate.month(), endDate.day());
            String edate = String.valueOf(myDate2);
            String requestEndPoint = 'https://development.api.yodlee.uk/ysl/transactions';
            requestEndPoint +='?toDate'+edate+'&fromDate='+sdate;
            if(accountId!='' && accountId!=null) requestEndPoint +='&accountId='+accountId+'&top='+500;
            else requestEndPoint +='&top='+500;
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestEndPoint);
            req.setMethod('GET');
            req.setTimeout(10000);
            req.setHeader('Content-Type','application/json');
            req.setHeader('Api-Version','1.1');
            req.setHeader('Authorization',token);
            
            
            String yodlee = '%yodlee%';
            
            Http http = new Http();
            httpResponse response=http.send(req); String response_1 = ''; 
            Decimal statusCode = 0;
            if(Test.isRunningTest()) 
            {
                statusCode = 200;
                response_1 = '{"transaction":[';
                
                // Creating 500 transactions
                for (Integer i = 1; i <= 200; i++) { // changed from 500 to 200 by shaguftha on 18_07_24
                    response_1 += '{';
                    response_1 += '"date": "2024-02-21",';
                    response_1 += '"sourceId": "source_id_' + i + '",';
                    response_1 += '"symbol": "symbol_' + i + '",';
                    response_1 += '"cusipNumber": "cusip_' + i + '",';
                    response_1 += '"highLevelCategoryId": ' + i + ',';
                    response_1 += '"detailCategoryId": ' + (1000 + i) + ',';
                    response_1 += '"description": {';
                    response_1 += '"security": "security_' + i + '",';
                    response_1 += '"original": "original_' + i + '",';
                    response_1 += '"simple": "simple_' + i + '",';
                    response_1 += '"consumer": "consumer_' + i + '"';
                    response_1 += '},';
                    response_1 += '"memo": "memo_' + i + '",';
                    response_1 += '"settleDate": "2024-02-21",';
                    response_1 += '"type": "type_' + i + '",';
                    response_1 += '"intermediary": ["intermediary_' + i + '"],';
                    response_1 += '"baseType": "CREDIT",';
                    response_1 += '"categorySource": "SYSTEM",';
                    response_1 += '"principal": {';
                    response_1 += '"amount": ' + (10.5 * i) + ',';
                    response_1 += '"convertedAmount": ' + (7.2 * i) + ',';
                    response_1 += '"currency": "USD",';
                    response_1 += '"convertedCurrency": "USD"';
                    response_1 += '},';
                    response_1 += '"lastUpdated": "2024-02-21",';
                    response_1 += '"interest": {';
                    response_1 += '"amount": ' + (2.3 * i) + ',';
                    response_1 += '"convertedAmount": ' + (1.8 * i) + ',';
                    response_1 += '"currency": "USD",';
                    response_1 += '"convertedCurrency": "USD"';
                    response_1 += '},';
                    response_1 += '"price": {';
                    response_1 += '"amount": ' + (3.7 * i) + ',';
                    response_1 += '"convertedAmount": ' + (2.6 * i) + ',';
                    response_1 += '"currency": "USD",';
                    response_1 += '"convertedCurrency": "USD"';
                    response_1 += '},';
                    response_1 += '"commission": {';
                    response_1 += '"amount": ' + (1.2 * i) + ',';
                    response_1 += '"convertedAmount": ' + (0.9 * i) + ',';
                    response_1 += '"currency": "USD",';
                    response_1 += '"convertedCurrency": "USD"';
                    response_1 += '},';
                    response_1 += '"id": ' + i + ',';
                    response_1 += '"merchantType": "merchant_type_' + i + '",';
                    response_1 += '"amount": {';
                    response_1 += '"amount": ' + (5.8 * i) + ',';
                    response_1 += '"convertedAmount": ' + (4.3 * i) + ',';
                    response_1 += '"currency": "USD",';
                    response_1 += '"convertedCurrency": "USD"';
                    response_1 += '},';
                    response_1 += '"checkNumber": "check_' + i + '",';
                    response_1 += '"isPhysical": true,';
                    response_1 += '"quantity": ' + (1.2 * i) + ',';
                    response_1 += '"valoren": "valoren_' + i + '",';
                    response_1 += '"isManual": true,';
                    response_1 += '"merchant": {';
                    response_1 += '"website": "website_' + i + '",';
                    response_1 += '"address": {';
                    response_1 += '"zip": "zip_' + i + '",';
                    response_1 += '"country": "country_' + i + '",';
                    response_1 += '"address3": "address3_' + i + '",';
                    response_1 += '"address2": "address2_' + i + '",';
                    response_1 += '"city": "city_' + i + '",';
                    response_1 += '"sourceType": "source_type_' + i + '",';
                    response_1 += '"address1": "address1_' + i + '",';
                    response_1 += '"street": "street_' + i + '",';
                    response_1 += '"state": "state_' + i + '",';
                    response_1 += '"type": "HOME"';
                    response_1 += '},';
                    response_1 += '"contact": {';
                    response_1 += '"phone": "phone_' + i + '",';
                    response_1 += '"email": "email_' + i + '"';
                    response_1 += '},';
                    response_1 += '"categoryLabel": ["category_label_' + i + '"],';
                    response_1 += '"coordinates": {';
                    response_1 += '"latitude": ' + (51.5 + i) + ',';
                    response_1 += '"longitude": ' + (-0.1 * i) + '';
                    response_1 += '},';
                    response_1 += '"name": "merchant_name_' + i + '",';
                    response_1 += '"id": "merchant_id_' + i + '",';
                    response_1 += '"source": "YODLEE",';
                    response_1 += '"logoURL": "logo_url_' + i + '"';
                    response_1 += '},';
                    response_1 += '"sedol": "sedol_' + i + '",';
                    response_1 += '"transactionDate": "2024-02-21",';
                    response_1 += '"categoryType": "TRANSFER",';
                    response_1 += '"accountId": ' + (10000 + i) + ',';
                    response_1 += '"createdDate": "2024-02-21",';
                    response_1 += '"sourceType": "AGGREGATED",';
                    response_1 += '"CONTAINER": "bank",';
                    response_1 += '"postDate": "2024-02-21",';
                    response_1 += '"parentCategoryId": ' + i + ',';
                    response_1 += '"subType": "OVERDRAFT_CHARGE",';
                    response_1 += '"category": "category_' + i + '",';
                    response_1 += '"runningBalance": {';
                    response_1 += '"amount": ' + (20.3 * i) + ',';
                    response_1 += '"convertedAmount": ' + (15.6 * i) + ',';
                    response_1 += '"currency": "USD",';
                    response_1 += '"convertedCurrency": "USD"';
                    response_1 += '},';
                    response_1 += '"categoryId": ' + (2000 + i) + ',';
                    response_1 += '"holdingDescription": "holding_description_' + i + '",';
                    response_1 += '"isin": "isin_' + i + '",';
                    response_1 += '"status": "POSTED"';
                    response_1 += '}';
                    if (i < 200) {
                        response_1 += ',';
                    }
                }
                
                response_1 += ']}';
                // response_1 = '{"transaction":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+''; 
            }
            else {                statusCode = response.getStatusCode();                response_1 = response.getBody();            }
            if(statusCode == 200){  
                system.debug('response-->'+response_1);
                Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1);   
                list<ERP7__Bank_Statement__c> org_bankStmtlist=new list<ERP7__Bank_Statement__c>();     
                List<Object> data = (List<Object>)results.get('transaction');
                for(integer i=0;i<data.size();i++){   
                    yodleeTransractionWrap ywrap = new yodleeTransractionWrap();
                    Map<String,Object> mainresults=(Map<String,Object>)data[i];            
                    Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');       
                    Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');      
                    Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');
                    if(accountId!='' && accountId!=null && accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){                         ywrap.AccountId = String.valueOf(mainresults.get('accountId'));                        if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));                        ywrap.Reference = String.valueOf(mainresults.get('id'));                        ywrap.TransDate = String.valueOf(mainresults.get('date'));                        if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));                        ywrap.decsription = String.valueOf(descr.get('original'));                        trapList.add(ywrap);
                    }else if(Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){
                        ywrap.AccountId = String.valueOf(mainresults.get('accountId'));
                        if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));
                        ywrap.Reference = String.valueOf(mainresults.get('id'));
                        ywrap.TransDate = String.valueOf(mainresults.get('date'));
                        if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));
                        ywrap.decsription = String.valueOf(descr.get('original'));
                        trapList.add(ywrap);
                    }
                }
                List<Object> data1 = new List<Object>();
                if(data.size()==200){
                    String requestEndPoint1 = 'https://development.api.yodlee.uk/ysl/transactions';
                    requestEndPoint1 +='?toDate'+edate+'&fromDate='+sdate;
                    //requestEndPoint1 +='&Container=Bills&accountId='+accountId+'&top='+500+'&skip='+500;
                    if(accountId!='' && accountId!=null) requestEndPoint1 +='&Container=Bills&accountId='+accountId+'&top='+500+'&skip='+500;
                    else requestEndPoint1 +='&Container=Bills'+'&top='+500+'&skip='+500;
                    
                    HttpRequest req1 = new HttpRequest();
                    req1.setEndpoint(requestEndPoint1);
                    req1.setMethod('GET');
                    req1.setTimeout(10000);
                    req1.setHeader('Content-Type','application/json');
                    req1.setHeader('Api-Version','1.1');
                    req1.setHeader('Authorization',token);
                    
                    
                    String yodlee1 = '%yodlee%';
                    
                    Http http1 = new Http();
                    httpResponse response1=http1.send(req1); 
                    String response_2 = ''; 
                    if(Test.isRunningTest()) {
                        response_2 = '{"transaction":[';
                        
                        // Creating 500 transactions
                        for (Integer i = 1; i <= 2; i++) {
                            response_2 += '{';
                            response_2 += '"date": "2024-02-21",';
                            response_2 += '"sourceId": "source_id_' + i + '",';
                            response_2 += '"symbol": "symbol_' + i + '",';
                            response_2 += '"cusipNumber": "cusip_' + i + '",';
                            response_2 += '"highLevelCategoryId": ' + i + ',';
                            response_2 += '"detailCategoryId": ' + (1000 + i) + ',';
                            response_2 += '"description": {';
                            response_2 += '"security": "security_' + i + '",';
                            response_2 += '"original": "original_' + i + '",';
                            response_2 += '"simple": "simple_' + i + '",';
                            response_2 += '"consumer": "consumer_' + i + '"';
                            response_2 += '},';
                            response_2 += '"memo": "memo_' + i + '",';
                            response_2 += '"settleDate": "2024-02-21",';
                            response_2 += '"type": "type_' + i + '",';
                            response_2 += '"intermediary": ["intermediary_' + i + '"],';
                            response_2 += '"baseType": "CREDIT",';
                            response_2 += '"categorySource": "SYSTEM",';
                            response_2 += '"principal": {';
                            response_2 += '"amount": ' + (10.5 * i) + ',';
                            response_2 += '"convertedAmount": ' + (7.2 * i) + ',';
                            response_2 += '"currency": "USD",';
                            response_2 += '"convertedCurrency": "USD"';
                            response_2 += '},';
                            response_2 += '"lastUpdated": "2024-02-21",';
                            response_2 += '"interest": {';
                            response_2 += '"amount": ' + (2.3 * i) + ',';
                            response_2 += '"convertedAmount": ' + (1.8 * i) + ',';
                            response_2 += '"currency": "USD",';
                            response_2 += '"convertedCurrency": "USD"';
                            response_2 += '},';
                            response_2 += '"price": {';
                            response_2 += '"amount": ' + (3.7 * i) + ',';
                            response_2 += '"convertedAmount": ' + (2.6 * i) + ',';
                            response_2 += '"currency": "USD",';
                            response_2 += '"convertedCurrency": "USD"';
                            response_2 += '},';
                            response_2 += '"commission": {';
                            response_2 += '"amount": ' + (1.2 * i) + ',';
                            response_2 += '"convertedAmount": ' + (0.9 * i) + ',';
                            response_2 += '"currency": "USD",';
                            response_2 += '"convertedCurrency": "USD"';
                            response_2 += '},';
                            response_2 += '"id": ' + i + ',';
                            response_2 += '"merchantType": "merchant_type_' + i + '",';
                            response_2 += '"amount": {';
                            response_2 += '"amount": ' + (5.8 * i) + ',';
                            response_2 += '"convertedAmount": ' + (4.3 * i) + ',';
                            response_2 += '"currency": "USD",';
                            response_2 += '"convertedCurrency": "USD"';
                            response_2 += '},';
                            response_2 += '"checkNumber": "check_' + i + '",';
                            response_2 += '"isPhysical": true,';
                            response_2 += '"quantity": ' + (1.2 * i) + ',';
                            response_2 += '"valoren": "valoren_' + i + '",';
                            response_2 += '"isManual": true,';
                            response_2 += '"merchant": {';
                            response_2 += '"website": "website_' + i + '",';
                            response_2 += '"address": {';
                            response_2 += '"zip": "zip_' + i + '",';
                            response_2 += '"country": "country_' + i + '",';
                            response_2 += '"address3": "address3_' + i + '",';
                            response_2 += '"address2": "address2_' + i + '",';
                            response_2 += '"city": "city_' + i + '",';
                            response_2 += '"sourceType": "source_type_' + i + '",';
                            response_2 += '"address1": "address1_' + i + '",';
                            response_2 += '"street": "street_' + i + '",';
                            response_2 += '"state": "state_' + i + '",';
                            response_2 += '"type": "HOME"';
                            response_2 += '},';
                            response_2 += '"contact": {';
                            response_2 += '"phone": "phone_' + i + '",';
                            response_2 += '"email": "email_' + i + '"';
                            response_2 += '},';
                            response_2 += '"categoryLabel": ["category_label_' + i + '"],';
                            response_2 += '"coordinates": {';
                            response_2 += '"latitude": ' + (51.5 + i) + ',';
                            response_2 += '"longitude": ' + (-0.1 * i) + '';
                            response_2 += '},';
                            response_2 += '"name": "merchant_name_' + i + '",';
                            response_2 += '"id": "merchant_id_' + i + '",';
                            response_2 += '"source": "YODLEE",';
                            response_2 += '"logoURL": "logo_url_' + i + '"';
                            response_2 += '},';
                            response_2 += '"sedol": "sedol_' + i + '",';
                            response_2 += '"transactionDate": "2024-02-21",';
                            response_2 += '"categoryType": "TRANSFER",';
                            response_2 += '"accountId": ' + (10000 + i) + ',';
                            response_2 += '"createdDate": "2024-02-21",';
                            response_2 += '"sourceType": "AGGREGATED",';
                            response_2 += '"CONTAINER": "bank",';
                            response_2 += '"postDate": "2024-02-21",';
                            response_2 += '"parentCategoryId": ' + i + ',';
                            response_2 += '"subType": "OVERDRAFT_CHARGE",';
                            response_2 += '"category": "category_' + i + '",';
                            response_2 += '"runningBalance": {';
                            response_2 += '"amount": ' + (20.3 * i) + ',';
                            
                            response_2 += '"convertedAmount": ' + (15.6 * i) + ',';
                            response_2 += '"currency": "USD",';
                            response_2 += '"convertedCurrency": "USD"';
                            response_2 += '},';
                            response_2 += '"categoryId": ' + (2000 + i) + ',';
                            response_2 += '"holdingDescription": "holding_description_' + i + '",';
                            response_2 += '"isin": "isin_' + i + '",';
                            response_2 += '"status": "POSTED"';
                            response_2 += '}';
                            if (i < 500) {
                                response_2 += ',';
                            }
                        }
                        
                        response_2 += ']}';
                        // response_2 = '{"transactions":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+'';  
                    }                    else response_2 = response1.getBody();
                    if(response1.getStatusCode()==200){                 
                        Map<String,Object> results1=(Map<String,Object>)JSON.deserializeUntyped(response_2);                           data1 = (List<Object>)results1.get('transaction');                        for(integer i=0;i<data1.size();i++){                               yodleeTransractionWrap ywrap = new yodleeTransractionWrap();                            Map<String,Object> mainresults=(Map<String,Object>)data1[i];                                        Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');                                   Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');                                  Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');                            if(accountId!='' && accountId!=null && accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){                                 ywrap.AccountId = String.valueOf(mainresults.get('accountId'));                                if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));                                ywrap.Reference = String.valueOf(mainresults.get('id'));                                ywrap.TransDate = String.valueOf(mainresults.get('date'));                                if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));                                ywrap.decsription = String.valueOf(descr.get('original'));                                trapList.add(ywrap);                            }else if(Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){                                ywrap.AccountId = String.valueOf(mainresults.get('accountId'));                                if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));                                ywrap.Reference = String.valueOf(mainresults.get('id'));                                ywrap.TransDate = String.valueOf(mainresults.get('date'));                                if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));                                ywrap.decsription = String.valueOf(descr.get('original'));                                trapList.add(ywrap);                            }                       }
                    }
                }
                List<Object> data2 = new List<Object>();
                if(data1.size()==500){
                    String requestEndPoint2 = 'https://development.api.yodlee.uk/ysl/transactions';                    requestEndPoint2 +='?toDate'+edate+'&fromDate='+sdate;                    if(accountId!='' && accountId!=null) { requestEndPoint2 +='&Container=Bills&accountId='+accountId+'&top='+500+'&skip='+1000; }                    else { requestEndPoint2 +='&Container=Bills'+'&top='+500+'&skip='+1000;  }                                    HttpRequest req2 = new HttpRequest();                   req2.setEndpoint(requestEndPoint2);                    req2.setMethod('GET');                    req2.setTimeout(10000);                   req2.setHeader('Content-Type','application/json');                    req2.setHeader('Api-Version','1.1');                   req2.setHeader('Authorization',token);                                                           String yodlee1 = '%yodlee%';                                        Http http2 = new Http();                    httpResponse response2=http2.send(req2);                     String response_3 = ''; 
                    if(Test.isRunningTest()) response_3 = '{"transactions":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+'';  
                    else response_3 = response2.getBody();
                    if(response2.getStatusCode()==200){                 
                        Map<String,Object> results2=(Map<String,Object>)JSON.deserializeUntyped(response_3);   
                        data2 = (List<Object>)results2.get('transaction');
                        for(integer i=0;i<data2.size();i++){                               yodleeTransractionWrap ywrap = new yodleeTransractionWrap();                            Map<String,Object> mainresults=(Map<String,Object>)data2[i];                                        Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');                             Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');                                  Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');                            if(accountId!='' && accountId!=null && accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){                                 ywrap.AccountId = String.valueOf(mainresults.get('accountId'));                                if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));                                ywrap.Reference = String.valueOf(mainresults.get('id'));                                ywrap.TransDate = String.valueOf(mainresults.get('date'));                                if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));                                ywrap.decsription = String.valueOf(descr.get('original'));                                trapList.add(ywrap);                            }else if(Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){                                ywrap.AccountId = String.valueOf(mainresults.get('accountId'));                                if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));                                ywrap.Reference = String.valueOf(mainresults.get('id'));                                ywrap.TransDate = String.valueOf(mainresults.get('date'));                                if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));                               ywrap.decsription = String.valueOf(descr.get('original'));                                trapList.add(ywrap);                            }                        }                    }                }
                if(data2.size()==500){
                    String requestEndPoint3 = 'https://development.api.yodlee.uk/ysl/transactions';                    requestEndPoint3 +='?toDate'+edate+'&fromDate='+sdate;                    if(accountId!='' && accountId!=null) {requestEndPoint3 +='&Container=Bills&accountId='+accountId+'&top='+500+'&skip='+1500;}                    else {requestEndPoint3 +='&Container=Bills'+'&top='+500+'&skip='+1500;   }                                     HttpRequest req3 = new HttpRequest();                   req3.setEndpoint(requestEndPoint3);
                    req3.setMethod('GET');                    req3.setTimeout(10000);                    req3.setHeader('Content-Type','application/json');                    req3.setHeader('Api-Version','1.1');                    req3.setHeader('Authorization',token);                                                            String yodlee1 = '%yodlee%';                                        Http http3 = new Http();                    httpResponse response3=http3.send(req3);                     String response_4 = ''; 
                    if(Test.isRunningTest()) response_4 = '{"transactions":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+'';                      else response_4 = response3.getBody();
                    if(response3.getStatusCode()==200){                                         Map<String,Object> results3=(Map<String,Object>)JSON.deserializeUntyped(response_4);                           List<Object> data3 = (List<Object>)results3.get('transaction');                        for(integer i=0;i<data3.size();i++){                               yodleeTransractionWrap ywrap = new yodleeTransractionWrap();                            Map<String,Object> mainresults=(Map<String,Object>)data3[i];                                        Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');                                   Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');                                  Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');                            if(accountId!='' && accountId!=null && accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){                                 ywrap.AccountId = String.valueOf(mainresults.get('accountId'));                                if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));                                ywrap.Reference = String.valueOf(mainresults.get('id'));                                ywrap.TransDate = String.valueOf(mainresults.get('date'));                                if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));                                ywrap.decsription = String.valueOf(descr.get('original'));                                trapList.add(ywrap);                           }else if(Date.valueOf(String.valueOf(mainresults.get('date')))<=endDate){                                ywrap.AccountId = String.valueOf(mainresults.get('accountId'));                                if(String.valueOf(mainresults.get('subType'))!=null) ywrap.subType = String.valueOf(mainresults.get('subType'));                                ywrap.Reference = String.valueOf(mainresults.get('id'));                                ywrap.TransDate = String.valueOf(mainresults.get('date'));                               if(amountFetch!=null) ywrap.TransAmount = String.valueOf(amountFetch.get('amount'));                                ywrap.decsription = String.valueOf(descr.get('original'));                                trapList.add(ywrap);                            }                        }                    }
                }
            }
            return trapList;
        }catch(Exception e){
            system.debug('Exception-->'+e+'LineNumber-->'+e.getLineNumber());
            return trapList;
        }
    }
    
    public class yodleeTransractionWrap{
        @AuraEnabled
        public String AccountId {get;set;}
        @AuraEnabled
        public String subType {get;set;}
        @AuraEnabled
        public String Reference {get;set;}
        @AuraEnabled
        public String TransDate {get;set;}
        @AuraEnabled
        public String TransAmount {get;set;}        @AuraEnabled        public String TransSummary {get;set;}
        @AuraEnabled
        public String decsription {get;set;}
        public yodleeTransractionWrap(){
            AccountId = subType = Reference = TransDate = TransAmount = decsription = '';
        }
    }
    
    
    @AuraEnabled
    public static void yodleeTransaction(String bankAccid, String bReconcileId, Date startDate, Date endDate,String BankRecon_obj1){
        try{
            
            ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
            ERP7__Chart_of_Accounts__c cred = [Select Id, Name, ERP7__External_System_Id__c
                                               From ERP7__Chart_of_Accounts__c
                                               Where ERP7__Bank_Account__c=:BankRecon_obj.ERP7__Bank_Account__c
                                               Limit 1];
            String accountId = cred.ERP7__External_System_Id__c;
            String token = generateToken();
            token = 'Bearer '+token;
            //DateTime dT = startDate;
            Date myDate = startDate;//date.newinstance(dT.year(), dT.month(), dT.day());
            String sdate = String.valueOf(myDate);
            //DateTime dT2 = endDate;
            Date myDate2 = endDate;//date.newinstance(dT2.year(), dT2.month(), dT2.day());
            String edate = String.valueOf(myDate2);
            
            system.debug('sdate~>'+sdate);
            system.debug('edate~>'+edate);
            
            String requestEndPoint = 'https://development.api.yodlee.uk/ysl/transactions';
            requestEndPoint +='?toDate'+edate+'&fromDate='+sdate;
            requestEndPoint +='&accountId='+accountId+'&top='+500;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(requestEndPoint);
            req.setMethod('GET');
            req.setTimeout(10000);
            req.setHeader('Content-Type','application/json');
            req.setHeader('Api-Version','1.1');
            req.setHeader('Authorization',token);
            
            
            String yodlee = '%yodlee%';
            
            Http http = new Http();
            httpResponse response=http.send(req); String response_1 = ''; if(Test.isRunningTest()) response_1 = '{"transaction":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+'';  else response_1 = response.getBody();
            if(response.getStatusCode()==200){                 
                Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1);   
                list<ERP7__Bank_Statement__c> org_bankStmtlist=new list<ERP7__Bank_Statement__c>();     
                List<Object> data = (List<Object>)results.get('transaction');
                for(integer i=0;i<data.size();i++){   
                    ERP7__Bank_Statement__c tr=new ERP7__Bank_Statement__c();               
                    Map<String,Object> mainresults=(Map<String,Object>)data[i]; 
                    Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');                 
                    Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');        
                    Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');
                    if(accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=myDate2){
                        system.debug('arshadyodleeTransaction - Description = '+String.valueOf(descr.get('original'))+', subtype = '+String.valueOf(mainresults.get('subType'))+', baseType = '+String.valueOf(mainresults.get('baseType'))+', amount = '+Decimal.valueOf(String.valueOf(amountFetch.get('amount'))));
                        
                        if(String.valueOf(mainresults.get('baseType')) != null){                            if(String.valueOf(mainresults.get('baseType')).equals('CREDIT')){                                system.debug('adding to deposit column');                                tr.ERP7__Deposits__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                            }else if(String.valueOf(mainresults.get('baseType')).equals('DEBIT')){                                system.debug('adding to withdrawal column');                                 tr.ERP7__Withdrawals__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                            }                        }else system.debug('baseType null');                         tr.ERP7__Reference_Number__c = String.valueOf(mainresults.get('id'));                         tr.ERP7__Transaction_Mode__c='OTHERS';                                                  system.debug('transacition date = '+Date.valueOf(String.valueOf(mainresults.get('date'))));                        tr.ERP7__Transaction_Date__c = Date.valueOf(String.valueOf(mainresults.get('date')));                                                 if(amountFetch1 != null) {tr.ERP7__Balance__c = Decimal.valueOf(String.valueOf(amountFetch1.get('amount')));}                        tr.ERP7__Transaction_Summary__c = String.valueOf(descr.get('original'));                        tr.ERP7__Status__c='UnReconciled';                        tr.ERP7__Bank_Reconciliation__c=bReconcileId;                        tr.ERP7__Bank_Account__c=bankAccid;                                               system.debug('tr-->'+tr);                        org_bankStmtlist.add(tr);                    }                }
                List<Object> data2 = new List<Object>();
                if(data!=null && data.size()==500){
                    String requestEndPoint2 = 'https://development.api.yodlee.uk/ysl/transactions';
                    requestEndPoint2 +='?toDate'+edate+'&fromDate='+sdate;
                    requestEndPoint2 +='&accountId='+accountId+'&top='+500+'&skip='+500;
                    HttpRequest req2 = new HttpRequest();
                    req2.setEndpoint(requestEndPoint2);
                    req2.setMethod('GET');
                    req2.setTimeout(10000);
                    req2.setHeader('Content-Type','application/json');
                    req2.setHeader('Api-Version','1.1');
                    req2.setHeader('Authorization',token);
                    
                    
                    String yodlee2 = '%yodlee%';
                    
                    Http http2 = new Http();
                    httpResponse response2=http2.send(req2); String response_2 = ''; 
                    if(Test.isRunningTest()) response_2 = '{"transactions":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+''; 
                    else response_2 = response2.getBody();
                    if(response2.getStatusCode()==200){                 
                        Map<String,Object> results2=(Map<String,Object>)JSON.deserializeUntyped(response_2);   
                        data2 = (List<Object>)results2.get('transaction');
                        for(integer i=0;i<data2.size();i++){                               ERP7__Bank_Statement__c tr=new ERP7__Bank_Statement__c();                                           Map<String,Object> mainresults=(Map<String,Object>)data2[i];                         Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');                                             Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');                                    Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');                            if(accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=myDate2){                                system.debug('arshadyodleeTransaction - Description = '+String.valueOf(descr.get('original'))+', subtype = '+String.valueOf(mainresults.get('subType'))+', baseType = '+String.valueOf(mainresults.get('baseType'))+', amount = '+Decimal.valueOf(String.valueOf(amountFetch.get('amount'))));                                                                if(String.valueOf(mainresults.get('baseType')) != null){                                    if(String.valueOf(mainresults.get('baseType')).equals('CREDIT')){                                        system.debug('adding to deposit column');                                        tr.ERP7__Deposits__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                                    }else if(String.valueOf(mainresults.get('baseType')).equals('DEBIT')){                                        system.debug('adding to withdrawal column');                                      tr.ERP7__Withdrawals__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                                    }                                }else system.debug('baseType null');                                 tr.ERP7__Reference_Number__c = String.valueOf(mainresults.get('id'));                                 tr.ERP7__Transaction_Mode__c='OTHERS';                                                              system.debug('transacition date = '+Date.valueOf(String.valueOf(mainresults.get('date'))));                               tr.ERP7__Transaction_Date__c = Date.valueOf(String.valueOf(mainresults.get('date')));                                                                 if(amountFetch1 != null) tr.ERP7__Balance__c = Decimal.valueOf(String.valueOf(amountFetch1.get('amount')));                                tr.ERP7__Transaction_Summary__c = String.valueOf(descr.get('original'));                               tr.ERP7__Status__c='UnReconciled';                               tr.ERP7__Bank_Reconciliation__c=bReconcileId;                                tr.ERP7__Bank_Account__c=bankAccid;                                                                system.debug('tr-->'+tr);                                org_bankStmtlist.add(tr);                            }                        }                    }                }
                List<Object> data3 = new List<Object>();
                if(data2!=null && data2.size()==500){
                    String requestEndPoint3 = 'https://development.api.yodlee.uk/ysl/transactions';
                    requestEndPoint3 +='?toDate'+edate+'&fromDate='+sdate;
                    requestEndPoint3 +='&accountId='+accountId+'&top='+500+'&skip='+1000;
                    HttpRequest req3 = new HttpRequest();
                    req3.setEndpoint(requestEndPoint3);
                    req3.setMethod('GET');
                    req3.setTimeout(10000);
                    req3.setHeader('Content-Type','application/json');
                    req3.setHeader('Api-Version','1.1');
                    req3.setHeader('Authorization',token);
                    
                    
                    String yodlee3 = '%yodlee%';
                    
                    Http http3 = new Http();
                    httpResponse response3=http3.send(req3); String response_3 = ''; 
                    if(Test.isRunningTest()) response_3 = '{"transactions":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+''; 
                    else response_3 = response3.getBody();
                    if(response3.getStatusCode()==200){                 
                        Map<String,Object> results3=(Map<String,Object>)JSON.deserializeUntyped(response_3);   
                        data3 = (List<Object>)results3.get('transaction');
                        for(integer i=0;i<data3.size();i++){                              ERP7__Bank_Statement__c tr=new ERP7__Bank_Statement__c();                                           Map<String,Object> mainresults=(Map<String,Object>)data3[i];                           Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');                                          Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');                                   Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');                            if(accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=myDate2){                                system.debug('arshadyodleeTransaction - Description = '+String.valueOf(descr.get('original'))+', subtype = '+String.valueOf(mainresults.get('subType'))+', baseType = '+String.valueOf(mainresults.get('baseType'))+', amount = '+Decimal.valueOf(String.valueOf(amountFetch.get('amount'))));                                                                if(String.valueOf(mainresults.get('baseType')) != null){                                    if(String.valueOf(mainresults.get('baseType')).equals('CREDIT')){                                        system.debug('adding to deposit column');                                       tr.ERP7__Deposits__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                                    }else if(String.valueOf(mainresults.get('baseType')).equals('DEBIT')){                                        system.debug('adding to withdrawal column');                                      tr.ERP7__Withdrawals__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                                    }                                }else system.debug('baseType null');                                 tr.ERP7__Reference_Number__c = String.valueOf(mainresults.get('id'));                                tr.ERP7__Transaction_Mode__c='OTHERS';                                                                  system.debug('transacition date = '+Date.valueOf(String.valueOf(mainresults.get('date'))));                                tr.ERP7__Transaction_Date__c = Date.valueOf(String.valueOf(mainresults.get('date')));                                                                 if(amountFetch1 != null) tr.ERP7__Balance__c = Decimal.valueOf(String.valueOf(amountFetch1.get('amount')));                                tr.ERP7__Transaction_Summary__c = String.valueOf(descr.get('original'));                               tr.ERP7__Status__c='UnReconciled';                                tr.ERP7__Bank_Reconciliation__c=bReconcileId;                                tr.ERP7__Bank_Account__c=bankAccid;                                                                system.debug('tr-->'+tr);                                org_bankStmtlist.add(tr);                            }                        }                    }                }
                List<Object> data4 = new List<Object>();
                if(data3!=null && data3.size()==500){                    String requestEndPoint4 = 'https://development.api.yodlee.uk/ysl/transactions';                    requestEndPoint4 +='?toDate'+edate+'&fromDate='+sdate;                    requestEndPoint4 +='&accountId='+accountId+'&top='+500+'&skip='+1500;                    HttpRequest req4 = new HttpRequest();                    req4.setEndpoint(requestEndPoint4);                    req4.setMethod('GET');                    req4.setTimeout(10000);                    req4.setHeader('Content-Type','application/json');                   req4.setHeader('Api-Version','1.1');                    req4.setHeader('Authorization',token);                                                            String yodlee4 = '%yodlee%';                                        Http http4 = new Http();                    httpResponse response4=http4.send(req4); String response_4 = '';                     if(Test.isRunningTest()) response_4 = '{"transactions":[{"totalPrice":5.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":1.0,"Quantity":5.0,"ProductName":"Pencil"},{"UnitPrice":0.5,"Quantity":1.0,"ProductName":"Eraser"}],"invoiceNumber":1}'+',{"totalPrice":11.5,"statementDate":"2011-10-04T16:58:54.858Z","lineItems":[{"UnitPrice":6.0,"Quantity":1.0,"ProductName":"Notebook"},{"UnitPrice":2.5,"Quantity":1.0,"ProductName":"Ruler"},{"UnitPrice":1.5,"Quantity":2.0,"ProductName":"Pen"}],"invoiceNumber":2}]}'+'';                     else response_4 = response4.getBody();                    if(response4.getStatusCode()==200){                                         Map<String,Object> results4=(Map<String,Object>)JSON.deserializeUntyped(response_4);                           data4 = (List<Object>)results4.get('transaction');                        for(integer i=0;i<data4.size();i++){                               ERP7__Bank_Statement__c tr=new ERP7__Bank_Statement__c();                                           Map<String,Object> mainresults=(Map<String,Object>)data4[i];                          Map<String, Object> amountFetch = (Map<String, Object>)mainresults.get('amount');                                          Map<String, Object> amountFetch1 = (Map<String, Object>)mainresults.get('runningBalance');                                    Map<String, Object> descr = (Map<String, Object>)mainresults.get('description');                            if(accountId==String.valueOf(mainresults.get('accountId')) &&  Date.valueOf(String.valueOf(mainresults.get('date')))<=myDate2){                                system.debug('arshadyodleeTransaction - Description = '+String.valueOf(descr.get('original'))+', subtype = '+String.valueOf(mainresults.get('subType'))+', baseType = '+String.valueOf(mainresults.get('baseType'))+', amount = '+Decimal.valueOf(String.valueOf(amountFetch.get('amount'))));                                                                if(String.valueOf(mainresults.get('baseType')) != null){                                    if(String.valueOf(mainresults.get('baseType')).equals('CREDIT')){                                        system.debug('adding to deposit column');                                      tr.ERP7__Deposits__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                                    }else if(String.valueOf(mainresults.get('baseType')).equals('DEBIT')){                                        system.debug('adding to withdrawal column');                                         tr.ERP7__Withdrawals__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));                                    }                                }else system.debug('baseType null');                                tr.ERP7__Reference_Number__c = String.valueOf(mainresults.get('id'));                                 tr.ERP7__Transaction_Mode__c='OTHERS';                                                             system.debug('transacition date = '+Date.valueOf(String.valueOf(mainresults.get('date'))));                                tr.ERP7__Transaction_Date__c = Date.valueOf(String.valueOf(mainresults.get('date')));                                                                 if(amountFetch1 != null) tr.ERP7__Balance__c = Decimal.valueOf(String.valueOf(amountFetch1.get('amount')));                                tr.ERP7__Transaction_Summary__c = String.valueOf(descr.get('original'));                                tr.ERP7__Status__c='UnReconciled';                                tr.ERP7__Bank_Reconciliation__c=bReconcileId;                                tr.ERP7__Bank_Account__c=bankAccid;                                                                system.debug('tr-->'+tr);                                org_bankStmtlist.add(tr);                            }                        }                    }                }
                //system.debug('org_bankStmtlist-->'+org_bankStmtlist.size());
                //upsert org_bankStmtlist;    
                
                if(org_bankStmtlist.size()>0){                   showInputFile = false;                      upsert org_bankStmtlist;                                             list<ERP7__Bank_Statement__c> bankStmtlist=new list<ERP7__Bank_Statement__c>();                         bankStmtlist.addAll(org_bankStmtlist);                          showFileData=true;                    showBanksection = true;                                        BankRecon_obj.Beginning_Balance__c = bankStmtlist[0].Balance__c;                    BankRecon_obj.Ending_Balance__c = bankStmtlist[bankStmtlist.size()-1].Balance__c;                    System.debug('BankRecon_obj'+BankRecon_obj);                                        System.debug('BankRecon_obj upsert');                    upsert BankRecon_obj;                                       List<Bank_Reconciliation__c> BankRecon_obj_list = new List<Bank_Reconciliation__c>();                              BankRecon_obj_list.add(BankRecon_obj);                      System.debug('BankRecon_obj_list'+BankRecon_obj_list.size());                      BankRecon_obj = updateInstance(BankRecon_obj_list);                                      }
            }
        }catch(Exception e){
            system.debug('Exception-->'+e+'LineNumber-->'+e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static void plaidTransaction(String bankAccid, String bReconcileId, DateTime startDate, DateTime endDate,String BankRecon_obj1){
        try{
            system.debug('bankAccid-->'+bankAccid);
            ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c();
            if(bankAccid!=null) coa = [select Id, Name, ERP7__Bank_Account__c, ERP7__External_System_Id__c from ERP7__Chart_of_Accounts__c where ERP7__Bank_Account__c =:bankAccid];
            if(coa != null){
                ERP7__Bank_Reconciliation__c BankRecon_obj = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BankRecon_obj1, ERP7__Bank_Reconciliation__c.class);
                DateTime dT = startDate;
                Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
                String sdate = String.valueOf(myDate);
                DateTime dT2 = endDate;
                Date myDate2 = date.newinstance(dT2.year(), dT2.month(), dT2.day());
                String edate = String.valueOf(myDate2);
                String plaid = '%plaid%';
                Credentials__c cred = [Select Id, Name, Active__c, ERP7__Password_Transkey__c, Channel_Id__c, ERP7__Signature__c, URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c, ERP7__Account_Id__c, ERP7__Bank_COA_ID__c  
                                       From Credentials__c
                                       Where Active__c =: true And
                                       Name Like :plaid 
                                       Limit 1];
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(cred.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Password_Transkey__c));
                String accountId = cred.ERP7__Bank_COA_ID__c; 
                String requestEndPoint = cred.ERP7__URL__c; 
                HttpRequest req = new HttpRequest(); 
                req.setEndpoint(requestEndPoint);  
                req.setMethod('POST');    
                req.setTimeout(2000); 
                req.setHeader('Content-Type','application/json');   
                String body='{"client_id": "'+userData.toString()+'","secret": "'+passwordData.toString()+'","access_token": "'+cred.ERP7__Signature__c+'","start_date":' +'"'+sdate+'"'+',"end_date": '+'"'+edate+'"'+','+'"options": {'+'"count":'+500+',"offset":'+0+'}'+' }';
                system.debug('body-->'+body);
                req.setBody(body);
                Http http = new Http(); 
                httpResponse response=http.send(req); 
                String response_1 = response.getBody(); 
                system.debug('response_1-->'+response_1);
                Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
                Object data = (Object)results.get('item');
                Map<String,Object> mainresults=(Map<String,Object>)data; 
                list<ERP7__Bank_Statement__c> org_bankStmtlist=new list<ERP7__Bank_Statement__c>(); 
                if(response.getStatusCode()==200){                 
                    List<Object> data1 = (List<Object>)results.get('transactions');                    system.debug('data1--->'+data1.size());                    if(data1!=null){                                                for(integer i=0;i<data1.size();i++){                               Map<String,Object> mainresults1=(Map<String,Object>)data1[i];                            system.debug(String.valueOf(mainresults1.get('account_id')));                            system.debug(accountId);                            if(String.valueOf(mainresults1.get('account_id'))==coa.ERP7__External_System_Id__c){                                ERP7__Bank_Statement__c tr=new ERP7__Bank_Statement__c();  tr.ERP7__Withdrawals__c = Decimal.valueOf(String.valueOf(mainresults1.get('amount')));                                if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Reference_Number__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Reference_Number__c.isUpdateable()){     String descript =  String.valueOf(mainresults1.get('account_id'));    if(descript.length()>18) tr.ERP7__Reference_Number__c = descript.substring(0, 18);    else tr.ERP7__Reference_Number__c = descript; }else{/*No access*/}                                                  if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Mode__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Mode__c.isUpdateable()){     tr.ERP7__Transaction_Mode__c='OTHERS';                                                                                                                                                                                                                             }else{/*No access*/}                                                  if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Date__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Date__c.isUpdateable()){    tr.ERP7__Transaction_Date__c = Date.valueOf(String.valueOf(mainresults1.get('date')));                                                                                                                                                                                                                            }else{/*No access*/}                                                      if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Summary__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Transaction_Summary__c.isUpdateable()){    tr.ERP7__Transaction_Summary__c = String.valueOf(mainresults1.get('name'));                                                                                                                                                                                                                                  }else{/*No access*/}                                                         if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Status__c.isUpdateable()){     tr.ERP7__Status__c='UnReconciled';                                                                                                                                                                                                        }else{/*No access*/}                                                      if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Bank_Reconciliation__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Bank_Reconciliation__c.isUpdateable()){       tr.ERP7__Bank_Reconciliation__c=bReconcileId;                                                                                                                                                                                                                                  }else{/*No access*/}                                                     if(Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Bank_Account__c.isCreateable() && Schema.sObjectType.ERP7__Bank_Statement__c.fields.ERP7__Bank_Account__c.isUpdateable()){     tr.ERP7__Bank_Account__c=bankAccid;                                                                                                                                                                                                                    }else{/*No access*/}                                                    org_bankStmtlist.add(tr);                                system.debug('tr-->'+tr);                           }                        }                    }
                }
                if(org_bankStmtlist.size()>0){     upsert org_bankStmtlist;                                             }
            }
        }catch(Exception e){
            system.debug('Exception-->'+e+'LineNumber-->'+e.getLineNumber());
        }
    }
    
    
    @AuraEnabled
    public static String generateToken(){
        //system.debug('OrgId-->'+OrgId);
        String yodlee = '%yodlee%';
        Credentials__c cred = [Select Id, Name, Active__c, ERP7__Password_Transkey__c, Channel_Id__c, ERP7__Signature__c, URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c, ERP7__Account_Id__c, ERP7__Bank_COA_ID__c  
                               From Credentials__c
                               Where Active__c =: true And
                               Name Like :yodlee
                               Limit 1];
        system.debug('cred'+cred);
        Blob cryptoKey, userData, passwordData;
        cryptoKey = encodingUtil.convertFromHex(cred.Encrypted_Key__c);
        userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Username_Login__c));
        passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Password_Transkey__c));
        if(userData != null) system.debug(userData.toString());
        if(passwordData != null) system.debug(passwordData.toString());
        String requestEndPoint = cred.URL__c;//'https://development.api.yodlee.uk/ysl/auth/token';//cred.URL__c;//'https://development.api.yodlee.uk/ysl/auth/token'; 
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(requestEndPoint);  
        req.setMethod('POST');    
        req.setTimeout(2000); 
        req.setHeader('Content-Type','application/x-www-form-urlencoded');   
        req.setHeader('Api-Version','1.1');  
        //req.setHeader('loginName',String.valueOf(cred.ERP7__Username_Login__c));          
        req.setHeader('loginName',userData.toString());  
        String body='clientId='+userData.toString()+'&secret='+passwordData.toString(); 
        //String body='clientId='+String.valueOf(cred.ERP7__Username_Login__c)+'&secret='+String.valueOf(cred.ERP7__Password_Transkey__c); 
        req.setBody(body);
        Http http = new Http(); 
        httpResponse response=http.send(req); 
        String response_1 = response.getBody(); 
        Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
        Object data = (Object)results.get('token');  
        Map<String,Object> mainresults=(Map<String,Object>)data; 
        system.debug('mainresults-->'+mainresults);
        String AccessToken;
        if(mainresults != null)  AccessToken=String.valueOf(mainresults.get('accessToken'));
        return AccessToken;
    }
    
}