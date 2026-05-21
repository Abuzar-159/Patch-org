/******************************************************************************************
 *  ERP_MARK7 -  AdjustmentEntrieslightning
 *
 *  Purpose : To create adjustment entries
 *  Author  : Aqxolt - Irfan Khan 
 *  Started Date    : 2019-08-29
 *  End Date        :
 *  Version : 1.0
 *  Project : ERP_MARK7
 *  
 *      - This Class helps to create adjustment entries
 *      
 *  
 *  Modification History
 *  Date    Who    Description  
 *  yyyy-mm-dd - XX - xxxxxxxxxxxxxxxxxxxxxxxxxxxx
 * 
 * LastModifiedBy - Arshad 23/01/2023
 * Reason - Adjustment Entries not showing up even when dates changes Issue,
 *          In method getAdjTransactions,fetchDetails
 * 
 * 
 * LastModifiedBy - Saqlain Khan 30/04/2026
 * Reason - Adjustment Entries was setting the currency from the org insted of selected currency
 *          Added a fix for that in both save method.
 *
 * 
 ********************************************************************************************/

public with sharing class AdjustmentEntriesLightning {
    @AuraEnabled 
    public ERP7__Transaction__c DefaultOrg                                                       { get; set; }
    @AuraEnabled 
    public Date endDate                                                                    { get; set; }
    @AuraEnabled 
    public String adjDate                                                                  { get; set; }
    @AuraEnabled 
    public date startDate                                                                  { get; set; }
    @AuraEnabled 
    public List<ERP7__Transaction__c> adjustmentList                                             { get; set; }
    @AuraEnabled 
    public list<Finance_General_Ledger_Entry__c> FGLE2Insert                               { get; set; }
    @AuraEnabled 
    public Finance_General_Ledger_Entry__c  Debit_FGLE                                     { get; set; }
    @AuraEnabled 
    public Finance_General_Ledger_Entry__c Credit_FGLE                                     { get; set; }
    @AuraEnabled 
    public Finance_General_Ledger__c Gledger                                               { get; set; }
    @AuraEnabled 
    Public Map<Transaction__c,List<Finance_General_Ledger_Entry__c>> Transaction_FGLE_Map  { get; set; }
    @AuraEnabled 
    public Adjustment_Wrapper AdjwrapperList                                               { get; set; }
    @AuraEnabled 
    public Integer selectedIndex                                                           { get; set; }
    @AuraEnabled 
    public String rTypeCredit                                                              { get; set; }
    @AuraEnabled 
    public String rTypedebit                                                               { get; set; }
    @AuraEnabled 
    public Adjust_Wrapper   adjEntries                                                     { get; set; }
    @AuraEnabled 
    public List<Finance_General_Ledger_Entry__c>   editAdjustments                         { get; set; }
    @AuraEnabled 
    public Adjust_Wrapper   dummyadjEntries                                                { get; set; }
    @AuraEnabled 
    public String transName                                                                { get; set; }
    @AuraEnabled
    public Integer recSize                                                                 { get; set; }
    @AuraEnabled
    public  ERP7__Transaction__c  editTrans                                                { get; set; }
    
    
    public AdjustmentEntriesLightning (){
        DefaultOrg = editTrans = new ERP7__Transaction__c();
        adjustmentList = new List<ERP7__Transaction__c>();
        FGLE2Insert = editAdjustments = new list<Finance_General_Ledger_Entry__c>();
        adjDate = transName = rTypedebit = rTypeCredit = '';
        Debit_FGLE = Credit_FGLE = new Finance_General_Ledger_Entry__c();
        Gledger = new Finance_General_Ledger__c();
        dummyadjEntries = adjEntries = new Adjust_Wrapper();
        AdjwrapperList = new Adjustment_Wrapper();
        Transaction_FGLE_Map = new Map<Transaction__c,List<Finance_General_Ledger_Entry__c>>();
        recSize = selectedIndex = 0;
    }
   
    @AuraEnabled
    public static AdjustmentEntriesLightning saveEditEntries(String selId, String ins){
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        if(instance != null){
            if(instance.editTrans != null && Schema.sObjectType.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.isUpdateable()){ upsert instance.editTrans; }else{ }
            if(instance.editAdjustments != null && Schema.sObjectType.Finance_General_Ledger_Entry__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.isUpdateable()){ upsert instance.editAdjustments; }else{ }
        }
        return instance;
    }
    
    @AuraEnabled
    public static AdjustmentEntriesLightning saveCloneEntries(String selId, String ins){
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        if(Schema.sObjectType.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.isUpdateable()){ upsert instance.editTrans; }else{ }
        if(Schema.sObjectType.Finance_General_Ledger_Entry__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.isUpdateable()){ 
            List<ERP7__Finance_General_Ledger__c> ledger = [select id from ERP7__Finance_General_Ledger__c];
            for(Finance_General_Ledger_Entry__c fgle : instance.editAdjustments){
                fgle.Id=null;
                fgle.ERP7__Transactions__c = instance.editTrans.Id;
                fgle.Finance_general_ledger__c = ledger[0].Id;
            }
            upsert instance.editAdjustments;
        }else{ }
        return instance;
    }
    
    
    @AuraEnabled
    public static AdjustmentEntriesLightning getFGLES(String selId, String ins){
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        instance.editAdjustments = [Select id,ERP7__Chart_of_Account__c,ERP7__CustomerVendor__c,ERP7__General_Ledger_Entry_Type__c,Organisation__c,Credit_Entry__c,Debit_Entry__c From ERP7__Finance_General_Ledger_Entry__c where ERP7__Transactions__c =: selId];
        instance.editTrans = [Select id,ERP7__Finance_Category_Type__c,ERP7__Transaction_Summary__c,ERP7__Amount__c, ERP7__Transaction_Date__c, ERP7__is_Adjustment__c, ERP7__Organisation__c,ERP7__Transaction_Status__c from ERP7__Transaction__c where id =:selId ];
        return instance;
    }
    
    @AuraEnabled
    public static AdjustmentEntriesLightning fetchDetails(String Offset, integer RecordLimit, String searchString){
        system.debug('fetchDetails called');
        AdjustmentEntriesLightning instance = new AdjustmentEntriesLightning();
        instance.selectedIndex=0;
        instance.adjDate = System.Today().format();
        Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
        instance.Transaction_FGLE_Map = new Map<Transaction__c,List<Finance_General_Ledger_Entry__c>>();
        instance.startDate = Date.newInstance((FiscalYearStartMonth==1)?System.today().Year():System.today().Year()-1,FiscalYearStartMonth,1);
        datetime FiscalYearSD = datetime.newInstanceGMT(instance.startDate,Time.newInstance(0, 0, 0, 0));
        Integer year = (FiscalYearStartMonth >2)?instance.startDate.year()+1:instance.startDate.year();
        instance.endDate = (Date.isLeapYear(year))?instance.startDate.adddays(365):instance.startDate.adddays(364);
        
        datetime FiscalYearED = datetime.newInstanceGMT(instance.endDate,Time.newInstance(23, 59, 59, 999));
        instance.rTypeCredit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Credit_General_Ledger_Entry');   
        instance.rTypeDebit = RecordTypeUtil.getObjectRecordTypeIds('Finance_General_Ledger_Entry__c','Debit_General_Ledger_Entry');       
        instance.DefaultOrg = new Transaction__c();
        instance.transName = '';
        instance.adjustmentList = new List<Transaction__c>();
        instance.Debit_FGLE = instance.Credit_FGLE = new Finance_General_Ledger_Entry__c();
        instance.FGLE2Insert = new list<Finance_General_Ledger_Entry__c>();
        List<ERP7__Employees__c> empForOrganisation = [ Select id,ERP7__Organisation__c from ERP7__Employees__c where ERP7__Employee_User__c =: UserInfo.getUserId() ];
        if( empForOrganisation.size() > 0 )  instance.DefaultOrg.ERP7__Organisation__c = empForOrganisation[0].ERP7__Organisation__c;  
        
        instance.AdjwrapperList = new Adjustment_Wrapper((instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null)? instance.DefaultOrg.Organisation__c:null);
        //instance.adjEntries = new Adjust_Wrapper((instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null)? instance.DefaultOrg.Organisation__c:null);
        system.debug('fetchdetails instance.adjEntries.FGLEs~>'+instance.adjEntries.FGLEs.size());
        instance.dummyadjEntries = new Adjust_Wrapper(( instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null )? instance.DefaultOrg.Organisation__c:null);
        List<Finance_General_Ledger__c> FinanceGeneralLedgers = [Select Id, Name, Accounting_Period_End_Date__c, Accounting_Period_Start_Date__c, Active__c, Description__c,CreatedDate,
                                                                 Organisation__c, Organisation_Business_Unit__c From Finance_General_Ledger__c
                                                                 Where Active__c = true And Organisation__c =:instance.DefaultOrg.Organisation__c AND
                                                                 Accounting_Period_Start_Date__c = :instance.startDate And Accounting_Period_End_Date__c = :instance.endDate];
        if(FinanceGeneralLedgers != null && FinanceGeneralLedgers.size()>0) instance.Gledger = FinanceGeneralLedgers[0];
        else instance.Gledger = new Finance_General_Ledger__c(Organisation__c=(instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null)? instance.DefaultOrg.Organisation__c:null,Start_Date__c= instance.startDate,End_Date__c = instance.endDate,Active__c=true);
       
        //code added by Arshad 23/01/23
        Date startDate = instance.startDate; 
        Date endDate   = instance.endDate;
        String org = (instance.DefaultOrg.ERP7__Organisation__c != null) ? String.valueof(Instance.DefaultOrg.ERP7__Organisation__c) : '';
        //
        
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String s= '%'+searchString+'%';
        String query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and ERP7__Amount__c > 0 '; // and CreatedDate =THIS_FISCAL_YEAR //changed by Arshad 23/01/23
        if(searchString!=null && searchString!='') query += ' AND Name Like :s ';
        //code added by Arshad 23/01/23
        if(String.isNotEmpty(org)) query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null) query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null) query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        //
        query += 'order by Name  desc limit 2000 ';
        instance.adjustmentList = Database.query(query);
        instance.recSize = instance.adjustmentList.size();
        query=null;
        query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and ERP7__Amount__c > 0 '; // and CreatedDate =THIS_FISCAL_YEAR //changed by Arshad 23/01/23
        if(searchString!=null && searchString!='') query += ' AND Name Like :s ';
        //code added by Arshad 23/01/23
        if(String.isNotEmpty(org)) query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null) query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null) query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        //
        query += '  order by Name desc limit :ikRecordLimit Offset :ikOffset ';
        instance.adjustmentList = Database.query(query);
        system.debug('fetchDetails instance.adjustmentList size~>'+instance.adjustmentList.size());
        return instance;
    }
    
    @AuraEnabled 
    public static AdjustmentEntriesLightning getAdjTransactions(String Offset, integer RecordLimit, String searchString, String ins){
        system.debug('getAdjTransactions called');
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        Date startDate = instance.startDate; 
        Date endDate   = instance.endDate;
        String org = String.valueof(Instance.DefaultOrg.ERP7__Organisation__c);
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String s= '%'+searchString+'%';
        String query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' FROM  Transaction__c Where is_Adjustment__c = true and ERP7__Amount__c > 0 '; // and CreatedDate =THIS_FISCAL_YEAR //changed by Arshad 23/01/23
        if(searchString!=null && searchString!='') query += ' AND Name Like :s '; 
        if(org != null && org != '') query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null) query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null) query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += ' order by Name  desc limit 2000 ';
        instance.adjustmentList = Database.query(query);
        instance.recSize = instance.adjustmentList.size();
        query=null;
        query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and ERP7__Amount__c > 0 '; // and CreatedDate =THIS_FISCAL_YEAR //changed by Arshad 23/01/23
        if(searchString!=null && searchString!='') query += ' AND Name Like :s ';
        if(org != null && org != '') query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null) query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null) query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += '  order by Name desc limit :ikRecordLimit Offset :ikOffset ';
        instance.adjustmentList = Database.query(query);
        system.debug('getAdjTransactions instance.adjustmentList size~>'+instance.adjustmentList.size());
        return instance;
    }
    
    @AuraEnabled
    public static AdjustmentEntriesLightning deleteAdjsTransaction(String Offset, String RecordLimit, String searchString, String selId, String ins ){
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        if(selId != null){
        List<ERP7__Transaction__c> deleteTransaction = [Select id from ERP7__Transaction__c where id =:selId ];
            if(Schema.sObjectType.ERP7__Transaction__c.isDeletable()) delete deleteTransaction; else{ }
        }
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        Date startDate = instance.startDate; 
        Date endDate   = instance.endDate;
        String org = String.valueof(Instance.DefaultOrg.ERP7__Organisation__c);
        String s= '%'+searchString+'%';
        String query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and CreatedDate =THIS_FISCAL_YEAR and ERP7__Amount__c > 0';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if( org != null && org != '' )query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null)query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null)query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += 'order by Name  asc limit 2000 ';
        instance.adjustmentList = Database.query(query);
        instance.recSize        =  instance.adjustmentList.size();
        query=null;
        query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and CreatedDate =THIS_FISCAL_YEAR and ERP7__Amount__c > 0';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if( org != null && org != '' )query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null)query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null)query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
        instance.adjustmentList = Database.query(query);
        return instance;
    }
    
    @AuraEnabled
    public static Entries addCreditEntries(String ins) {
       AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
       return new Entries(instance.adjEntries.FGLEs.size(),(instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null)? instance.DefaultOrg.Organisation__c:null,'Credit' );
    }
    
    @AuraEnabled
    public static Entries addDebitEntries(String ins) {
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize(ins, AdjustmentEntriesLightning.class );
        return new Entries(instance.adjEntries.FGLEs.size(),(instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null)? instance.DefaultOrg.Organisation__c:null,'Debit' );
    }
   
    @AuraEnabled
    public static AdjustmentEntriesLightning saveandNew(String Offset, integer RecordLimit, String searchString, String ins) {
           Boolean isMC = Schema.getGlobalDescribe().containsKey('CurrencyType'); 
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        instance = saveandClose(Offset,  RecordLimit,  searchString,  ins);
        //instance.adjEntries = new Adjust_Wrapper((instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null)? instance.DefaultOrg.Organisation__c:null);
        // 🔥 preserve currency from saved transaction
        String curr = null;
        if(isMC && instance.adjEntries != null && instance.adjEntries.Trans != null){
            curr = (String)instance.adjEntries.Trans.get('CurrencyIsoCode');
        }
       System.debug('=== DEBUG START ===');
System.debug('Is MultiCurrency Enabled => ' + isMC);

String debugCurr = 'NULL';

if(isMC 
   && Schema.sObjectType.ERP7__Transaction__c.fields.getMap().containsKey('CurrencyIsoCode')
   && instance.adjEntries != null 
   && instance.adjEntries.Trans != null){

    debugCurr = String.valueOf(instance.adjEntries.Trans.get('CurrencyIsoCode'));
}

System.debug('Transaction Currency => ' + debugCurr);
System.debug('FULL INSTANCE => ' + JSON.serialize(instance));
        
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        Date startDate = instance.startDate; 
        Date endDate   = instance.endDate;
        String s= '%'+searchString+'%';
        String org = String.valueof(Instance.DefaultOrg.ERP7__Organisation__c);
        String query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and CreatedDate =THIS_FISCAL_YEAR and ERP7__Amount__c > 0';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if( org != null && org != '' )query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null)query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null)query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += 'order by Name  asc limit 2000 ';
        instance.adjustmentList = Database.query(query);
        instance.recSize        =  instance.adjustmentList.size();
        query=null;
        query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and CreatedDate =THIS_FISCAL_YEAR and ERP7__Amount__c > 0';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if( org != null && org != '' )query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null)query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null)query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
        instance.adjustmentList = Database.query(query);
        instance.dummyadjEntries = new Adjust_Wrapper(( instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null )? instance.DefaultOrg.Organisation__c:null);
        // 🔥 restore currency into new wrapper
       
        system.debug('saveandNew before returning instance.adjEntries.FGLEs~>'+instance.adjEntries.FGLEs.size());
        return instance;
    }
     
    @AuraEnabled
    public static AdjustmentEntriesLightning saveandClose(String Offset, integer RecordLimit, String searchString, String ins) {
        Boolean isMC = Schema.getGlobalDescribe().containsKey('CurrencyType');

        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning ) JSON.deserialize( ins, AdjustmentEntriesLightning.Class);
        Map<String, Decimal> accountCreditToUpdate = new Map<String, Decimal>();
        Map<String, Decimal> accountDebitToUpdate = new Map<String, Decimal>();
        Set<String> accountIds = new Set<String>();
        Map<String, String> checkCredit = new Map<String, String>();
        Map<String, String> checkDebit = new Map<String, String>();
        List<ERP7__Accounting_Period__c> ap = new List<ERP7__Accounting_Period__c>();
        
      	System.debug('=== DEBUG START ===');
System.debug('Is MultiCurrency Enabled => ' + isMC);

String debugCurr = 'NULL';

if(isMC 
   && Schema.sObjectType.ERP7__Transaction__c.fields.getMap().containsKey('CurrencyIsoCode')
   && instance.adjEntries != null 
   && instance.adjEntries.Trans != null){

    debugCurr = String.valueOf(instance.adjEntries.Trans.get('CurrencyIsoCode'));
}

System.debug('Transaction Currency => ' + debugCurr);
System.debug('FULL INSTANCE => ' + JSON.serialize(instance));
        try{
            String getAPName; 
            Datetime CurrentDateTime=system.now();
            if(CurrentDateTime.month()<10){
                getAPName=String.valueOf(CurrentDateTime.year())+'-0'+String.valueOf(CurrentDateTime.month());
            }else{
                getAPName = String.valueOf(CurrentDateTime.year())+'-'+String.valueOf(CurrentDateTime.month());
            }
            ap = [Select id from ERP7__Accounting_Period__c where ERP7__Organisation__c=:instance.DefaultOrg.Organisation__c and Name=:getAPName and ERP7__Status__c='Open'];
        }catch(Exception e){
            
        }
        //Setting the total amount for the transaction
        if(instance.adjEntries != null){
            try{
                if(instance.adjEntries.FGLEs!=null){
                    instance.adjEntries.Trans.Amount__c=0.00;
                    for(Integer i=0;i<instance.adjEntries.FGLEs.size();i++){
                        if(instance.adjEntries.FGLEs[i].GEntries.Credit_Entry__c != NULL) if(Schema.sObjectType.ERP7__Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.fields.Amount__c.isUpdateable()) instance.adjEntries.Trans.Amount__c  += instance.adjEntries.FGLEs[i].GEntries.Credit_Entry__c;
                    }
                }
            }catch(Exception e){ }
        }
        // Ending of Setting the total amount for the transaction 
        if(Schema.sObjectType.Finance_General_Ledger__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger__c.fields.ERP7__Organisation__c.isUpdateable()) instance.Gledger.ERP7__Organisation__c = instance.DefaultOrg.Organisation__c;  
        if(instance.adjEntries.Trans.Organisation__c == null) if(Schema.sObjectType.ERP7__Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.fields.Organisation__c.isUpdateable())instance.adjEntries.Trans.Organisation__c =  instance.DefaultOrg.Organisation__c;   
        List<ERP7__Finance_General_Ledger__c> ledger = [select id from ERP7__Finance_General_Ledger__c where ERP7__Organisation__c=:instance.DefaultOrg.ERP7__Organisation__c];    
        if(instance.Gledger.id == null && ledger.size()==0 && instance.Gledger.ERP7__Organisation__c != null && Schema.sObjectType.Finance_General_Ledger__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger__c.isUpdateable()){ upsert instance.Gledger;} else{/*not allowed to upsert*/}
        if(instance.adjEntries != null && instance.adjEntries.Trans != null && instance.adjEntries.Trans.Organisation__c !=null){
           if(Schema.sObjectType.ERP7__Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.fields.Transaction_Date__c.isUpdateable()) instance.adjEntries.Trans.Transaction_Date__c = Date.parse(instance.adjDate);
            //Moin added this on 20th October 2023
            if(instance.adjEntries.FGLEs.size()>0){
                for(Entries entry : instance.adjEntries.FGLEs){
                    system.debug('Id-->'+entry.GEntries.ERP7__Chart_of_Account__c);
                    List<ERP7__Chart_of_Accounts__c> coa = new List<ERP7__Chart_of_Accounts__c>();
                    coa =[select Id, Name from ERP7__Chart_of_Accounts__c where Id=:entry.GEntries.ERP7__Chart_of_Account__c and ERP7__Payment_Account__c=true];
                    if(coa!=null && entry.GEntries.ERP7__General_Ledger_Entry_Type__c == 'Credit' && coa.size()>0){
                        instance.adjEntries.Trans.ERP7__Finance_Category_Type__c= 'Credit';
                        break;
                    }
                    
                }
            }
               
if(isMC 
   && Schema.sObjectType.ERP7__Transaction__c.fields.getMap().containsKey('CurrencyIsoCode')
   && instance.adjEntries != null 
   && instance.adjEntries.Trans != null){

    String curr = (String)instance.adjEntries.Trans.get('CurrencyIsoCode');

    if(String.isBlank(curr)){
        instance.adjEntries.Trans.put('CurrencyIsoCode', UserInfo.getDefaultCurrency());
    }
}
    		
            if(Schema.sObjectType.ERP7__Transaction__c.isCreateable() && Schema.sObjectType.ERP7__Transaction__c.isUpdateable()) upsert instance.adjEntries.Trans; else{ }
            if(instance.adjEntries.Trans.id != null){
                instance.transName = [Select id,Name,ERP7__Organisation__c,ERP7__Transaction_Summary__c,ERP7__Amount__c,ERP7__is_Adjustment__c,ERP7__Transaction_Status__c,ERP7__Transaction_date__c from ERP7__Transaction__c where id =:instance.adjEntries.Trans.id  ][0].Name;
            }
        }
        if(instance.adjEntries.FGLEs.size()>0){
            for(Entries entry : instance.adjEntries.FGLEs){
                accountIds.add(entry.GEntries.ERP7__CustomerVendor__c);
                if( entry.GEntries.ERP7__General_Ledger_Entry_Type__c == 'Credit' && entry.GEntries.ERP7__CustomerVendor__c != null ){
                    checkCredit.put(entry.GEntries.ERP7__CustomerVendor__c, 'Credit'); 
                    if(accountCreditToUpdate.get(entry.GEntries.ERP7__CustomerVendor__c) == null){
                        accountCreditToUpdate.put(entry.GEntries.ERP7__CustomerVendor__c, entry.GEntries.Credit_Entry__c);
                    }else{
                         accountCreditToUpdate.put(entry.GEntries.ERP7__CustomerVendor__c, accountCreditToUpdate.get(entry.GEntries.ERP7__CustomerVendor__c) + entry.GEntries.Credit_Entry__c);
                    }
                }else{
                     checkDebit.put(entry.GEntries.ERP7__CustomerVendor__c, 'Debit');
                     if(accountDebitToUpdate.get(entry.GEntries.ERP7__CustomerVendor__c) == null){
                        accountDebitToUpdate.put(entry.GEntries.ERP7__CustomerVendor__c, entry.GEntries.ERP7__Debit_Entry__c);
                    }else{
                        accountDebitToUpdate.put(entry.GEntries.ERP7__CustomerVendor__c, accountDebitToUpdate.get(entry.GEntries.ERP7__CustomerVendor__c) + entry.GEntries.ERP7__Debit_Entry__c);
                    }
                }
                entry.GEntries.Entry_Description__c=instance.adjEntries.Trans.Transaction_Summary__c;
                if(isMC){
                    String curr = (String)instance.adjEntries.Trans.get('CurrencyIsoCode');
                    if(String.isNotBlank(curr)){
                        entry.GEntries.put('CurrencyIsoCode', curr);
                    }
                }
                entry.GEntries.Transactions__c = instance.adjEntries.Trans.id;
                if(ledger.size()==0)entry.GEntries.Finance_general_ledger__c = instance.Gledger.id;
                else entry.GEntries.Finance_general_ledger__c = ledger[0].id;
                if(entry.GEntries.ERP7__General_Ledger_Entry_Type__c == 'Credit')entry.GEntries.RecordTypeId = instance.rTypeCredit;
                if(entry.GEntries.ERP7__General_Ledger_Entry_Type__c == 'Debit')entry.GEntries.RecordTypeId = instance.rTypeDebit;
                entry.GEntries.ERP7__Organisation__c = instance.DefaultOrg.Organisation__c;
                entry.GEntries.General_Ledger_Entry_DateTime__c = Datetime.newInstance(Date.parse(instance.adjDate),DateTime.now().Time());
                if(ap.size()>0)entry.GEntries.ERP7__Accounting_Period__c = ap[0].id;
                instance.FGLE2Insert.add(entry.GEntries);
               }
        }
        
        List<Account> accounToUpdate = [Select id,ERP7__Debit_Note_Balance__c,ERP7__Credit_Balance__c from Account where id IN : accountIds ];
        for(Account a : accounToUpdate){
            if(checkCredit.get(a.Id) == 'Credit'){
                 if(accountCreditToUpdate.get(a.Id) != null) if(Schema.sObjectType.Account.fields.ERP7__Credit_Balance__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Credit_Balance__c.isUpdateable())a.ERP7__Credit_Balance__c += accountCreditToUpdate.get(a.Id);
                }
            if(checkDebit.get(a.Id) == 'Debit'){ 
               if(accountDebitToUpdate.get(a.Id) != null) if(Schema.sObjectType.Account.fields.ERP7__Debit_Note_Balance__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Debit_Note_Balance__c.isUpdateable())a.ERP7__Debit_Note_Balance__c += accountDebitToUpdate.get(a.Id);
            }
        }
        if(accounToUpdate.size() > 0 && Schema.sObjectType.Account.isCreateable() && Schema.sObjectType.Account.isUpdateable()){upsert accounToUpdate;}else{/*upsert not allowed*/}
        if(instance.FGLE2Insert.size()>0 && instance.DefaultOrg.Organisation__c != null){
            if(Schema.sObjectType.Finance_General_Ledger_Entry__c.isCreateable() && Schema.sObjectType.Finance_General_Ledger_Entry__c.isUpdateable()) upsert instance.FGLE2Insert;
        }
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        Date startDate = instance.startDate; 
        Date endDate   = instance.endDate;
        String s= '%'+searchString+'%';
        String org = String.valueof(Instance.DefaultOrg.ERP7__Organisation__c);
        String query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and CreatedDate =THIS_FISCAL_YEAR and ERP7__Amount__c > 0';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if( org != null && org != '' )query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null)query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null)query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += 'order by Name  asc limit 2000 ';
        instance.adjustmentList = Database.query(query);
        instance.recSize        =  instance.adjustmentList.size();
        query=null;
        query = 'SELECT ' +String.escapeSingleQuotes(UtilClass.selectStarFromSObject('Transaction__c'))+' , ERP7__Accounting_Period__r.Name '+' FROM  Transaction__c Where is_Adjustment__c = true and CreatedDate =THIS_FISCAL_YEAR and ERP7__Amount__c > 0';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if( org != null && org != '' )query += ' AND ERP7__Organisation__c =:org ';
        if(startDate != null)query += ' AND ERP7__Transaction_Date__c >=: startDate ';
        if(endDate != null)query += ' AND ERP7__Transaction_Date__c <=: endDate ';
        query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
        instance.adjustmentList = Database.query(query);
        //instance.adjEntries = new Adjust_Wrapper(( instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null )? instance.DefaultOrg.Organisation__c:null);
        instance.dummyadjEntries = new Adjust_Wrapper(( instance.DefaultOrg != null && instance.DefaultOrg.Organisation__c !=null )? instance.DefaultOrg.Organisation__c:null);
        system.debug('saveandClose before returning instance.adjEntries.FGLEs~>'+instance.adjEntries.FGLEs.size());
        return instance;
    }
    
    
    @AuraEnabled
    public static multiCurrencyWrap getCurrencies(){
        multiCurrencyWrap mc = new multiCurrencyWrap();
        List<selectOptions> options = new List<selectOptions>();
        boolean IsmultiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        mc.isMulticurrency = IsmultiCurrencyEnabled;
        if(IsmultiCurrencyEnabled){   
            List <sObject> currencies = Database.Query('SELECT IsoCode FROM CurrencyType');    
            for(sObject a : currencies){   
                options.add(new SelectOptions(String.valueof(a.get('IsoCode')),String.valueof(a.get('IsoCode')))); 
            }
            mc.currencyList = options;
        }
        return mc;
    }
    
    public class multiCurrencyWrap{
        @AuraEnabled
        public Boolean isMulticurrency {get;set;}
        @AuraEnabled
        public List<selectOptions> currencyList {get;set;}
        public multiCurrencyWrap(){
            isMulticurrency = false;
            currencyList = new List<selectOptions>();
        }
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        public selectOptions(String lab, string val) {
            label = lab; value = val; 
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab; value = val; selected = sel;
        }
    }
    
    @AuraEnabled
    public static AdjustmentEntriesLightning setCOA(integer count, String selID, string ins){
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        Account accounts = [ Select id, ERP7__Customer_Account__c from Account where id  =: selID limit 1];
        if(accounts.ERP7__Customer_Account__c != null)instance.adjEntries.FGLEs[count].GEntries.Chart_of_Account__c = accounts.ERP7__Customer_Account__c;
        return instance;
    }
    
    @AuraEnabled
    public static String setCOANew(integer count, String selID, string ins){
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        Account accounts = [ Select id, ERP7__Customer_Account__c from Account where id  =: selID limit 1];
        if(accounts.ERP7__Customer_Account__c != null) return String.valueOf(accounts.ERP7__Customer_Account__c);
        return null;
    }
    
    @AuraEnabled
    public static AdjustmentEntriesLightning setEditCOA(integer count, String selID, string ins){
        AdjustmentEntriesLightning instance = ( AdjustmentEntriesLightning )JSON.deserialize( ins, AdjustmentEntriesLightning.class );
        Account accounts = [ Select id, ERP7__Customer_Account__c from Account where id  =: selID limit 1]; 
        if(accounts.ERP7__Customer_Account__c != null)instance.editAdjustments[count].Chart_of_Account__c = accounts.ERP7__Customer_Account__c;
        return instance;
    }
    
    public class Adjustment_Wrapper{
        @AuraEnabled public Transaction__c Trans         { get; set; }
        @AuraEnabled public list<wrapper_Entry> FGLEs    { get; set; }
        @AuraEnabled public integer index                { get; set; }
        
        public Adjustment_Wrapper(){
            Trans = new Transaction__c();
            FGLEs = new list<wrapper_Entry>();
            index = 0;
        }
        
        public Adjustment_Wrapper(Id orgID){
            this.index = 0;
            this.Trans = new Transaction__c(Organisation__c =orgId,Amount__c=0.00,is_Adjustment__c =true,Transaction_Status__c='Completed',Transaction_date__c=System.Today());
            this.FGLEs = new List<wrapper_Entry>();
            this.FGLEs.add(new wrapper_Entry(FGLEs.size(),orgId));
        }
    }
    public class wrapper_Entry{
        @AuraEnabled
        public integer index                                          { get; set; }
        @AuraEnabled
        public Finance_General_Ledger_Entry__c Credit_FGLE            { get; set; }
        @AuraEnabled
        public Finance_General_Ledger_Entry__c Debit_FGLE             { get; set; }
        public wrapper_Entry(Integer index,Id orgID){
            Credit_FGLE = new Finance_General_Ledger_Entry__c(Organisation__c = orgId,Credit_Entry__c=0.00,Debit_Entry__c=0.00);
            Debit_FGLE = new Finance_General_Ledger_Entry__c(Organisation__c = orgId,Credit_Entry__c=0.00,Debit_Entry__c=0.00);
            this.index=index;
        }
    }
    
    public class Entries{
        @AuraEnabled public Finance_General_Ledger_Entry__c GEntries          { get; set; }
        @AuraEnabled public  Contact customerVendorAccount                { get; set; }
        @AuraEnabled public integer index                { get; set; }
        public Entries(){
            GEntries = new Finance_General_Ledger_Entry__c();
            customerVendorAccount = new Contact();
            index = 0;
        }   
        
        public Entries(Integer index, Id orgID,String entryType){
            this.index = 0;
            this.customerVendorAccount = new Contact(lastName='Test');
            if(entryType == 'Credit'){
                this.GEntries = new Finance_General_Ledger_Entry__c(ERP7__General_Ledger_Entry_Type__c='Credit',Organisation__c = orgId,Credit_Entry__c=0.00,Debit_Entry__c=0.00);
            }else{
                this.GEntries = new Finance_General_Ledger_Entry__c(ERP7__General_Ledger_Entry_Type__c='Debit',Organisation__c = orgId,Credit_Entry__c=0.00,Debit_Entry__c=0.00);
            }
        }
    }
    
    public class Adjust_Wrapper{
        @AuraEnabled public Transaction__c Trans                    { get; set; }
        @AuraEnabled public list<Entries> FGLEs                     { get; set; }
        @AuraEnabled public integer index                           { get; set; }
        
        public Adjust_Wrapper(){
            Trans = new Transaction__c();
            FGLEs = new list<Entries>();
            index = 0;
        }
        
        public Adjust_Wrapper(Id orgID){
            this.index = 0;
            this.Trans = new Transaction__c(Organisation__c =orgId,Amount__c=0.00,is_Adjustment__c =true,Transaction_Status__c='Completed',Transaction_date__c=System.Today());
            this.FGLEs = new List<Entries>();
            this.FGLEs.add(new Entries(0,orgId,'Debit'));
            system.debug('Adjust_Wrapper FGLEs size~>'+this.FGLEs.size());
        }
    }
    
}