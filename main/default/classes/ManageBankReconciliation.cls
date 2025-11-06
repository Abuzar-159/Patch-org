public With Sharing class ManageBankReconciliation {
    @AuraEnabled
    public list<ERP7__Bank_Reconciliation__c> BankRecon_obj                   {get;set;}
    public ManageBankReconciliation(){
        BankRecon_obj=null;
    } 
     public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        //@AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) { label = lab; value = val; }
        //public selectOptions(String lab, string val, Boolean sel) { label = lab; value = val; selected = sel; }
    }

    @AuraEnabled
    public static Wrapper retrieveReconciliations(String orgId, String OrderBy, String Order,Integer Offset, Integer RecordLimit){
        Wrapper wrap=new Wrapper();
        list<ERP7__Bank_Reconciliation__c> BankRecon_obj=new list<ERP7__Bank_Reconciliation__c>();
        try{
        String OrgFilter='';
        String Status='Draft';
        String StatusFilter = ' (ERP7__Status__c=:Status ';
        String Status2='In-Progress';
        String StatusFilter1='OR ERP7__Status__c=:Status2)';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String OrderBy2=OrderBy;
        String Order2=Order;
        //String Limit += '  order by '+OrderBy2+' '+Order2+' limit :ikRecordLimit Offset :ikOffset ';
        if(String.isNotEmpty(orgId)) OrgFilter=' AND ERP7__Organisation__c=:orgId';
       	else OrgFilter=' AND ERP7__Organisation__c=null';
        String query2='select id,Name,ERP7__Organisation__c,ERP7__Bank_Account__c,ERP7__Status__c,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Beginning_Balance__c,ERP7__Ending_Balance__c,ERP7__Uncleared_Amount__c,ERP7__Calculated_Ending_Balance__c,ERP7__Cleared_Deposit__c,ERP7__Cleared_Disbursement__c,ERP7__Organisation__r.Name,ERP7__Bank_Account__r.Account_Number__c From ERP7__Bank_Reconciliation__c where'+String.escapeSingleQuotes(StatusFilter)+String.escapeSingleQuotes(StatusFilter1)+String.escapeSingleQuotes(OrgFilter)+' order by createddate desc';
       System.debug('query2'+query2);
            wrap.CompleteBRList=database.query(query2);
        wrap.recSize=wrap.CompleteBRList.size();
         OrgFilter+= '  order by createddate desc limit :ikRecordLimit Offset :ikOffset ';
         String query3='select id,Name,ERP7__Organisation__c,ERP7__Bank_Account__c,ERP7__Status__c,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Beginning_Balance__c,ERP7__Ending_Balance__c,ERP7__Uncleared_Amount__c,ERP7__Calculated_Ending_Balance__c,ERP7__Cleared_Deposit__c,ERP7__Cleared_Disbursement__c,ERP7__Organisation__r.Name,ERP7__Bank_Account__r.Account_Number__c From ERP7__Bank_Reconciliation__c where'+String.escapeSingleQuotes(StatusFilter)+String.escapeSingleQuotes(StatusFilter1)+String.escapeSingleQuotes(OrgFilter);
       System.debug('query3'+database.query(query3));
            wrap.FilteredBRList=database.query(query3);
        //BankRecon_obj=database.query(query2);
        }
        catch(Exception ex){
            
        }
        return wrap;
    }
	
    /*@AuraEnabled
    public static void updateSoli(List<ERP7__Sales_Order_Line_Item__c> soli){
        update soli;
    }*/
     @AuraEnabled
    public static string deleteReconciliation(String brId){
        try{
            if(brId != null && brId!= ''){
            	ERP7__Bank_Reconciliation__c brRec = [select id,Name,ERP7__Organisation__c,ERP7__Bank_Account__c,ERP7__Status__c,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Beginning_Balance__c,ERP7__Ending_Balance__c,ERP7__Uncleared_Amount__c,ERP7__Calculated_Ending_Balance__c,ERP7__Cleared_Deposit__c,ERP7__Cleared_Disbursement__c,ERP7__Organisation__r.Name,ERP7__Bank_Account__r.Account_Number__c From ERP7__Bank_Reconciliation__c where Id =: brId Limit 1];
        		if(brRec != null && ERP7__Bank_Reconciliation__c.sObjectType.getDescribe().isDeletable()) delete brRec;    
            }
            return '';
        } catch (Exception ex){ return ex.getMessage(); }
    }
     @AuraEnabled
    public static ERP7__Bank_Reconciliation__c getReconciliationTakeRec(String brId){
		ERP7__Bank_Reconciliation__c brRec = [select id,Name,ERP7__Organisation__c,ERP7__Bank_Account__c,ERP7__Status__c,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Beginning_Balance__c,ERP7__Ending_Balance__c,ERP7__Uncleared_Amount__c,ERP7__Calculated_Ending_Balance__c,ERP7__Cleared_Deposit__c,ERP7__Cleared_Disbursement__c,ERP7__Organisation__r.Name,ERP7__Bank_Account__r.Account_Number__c From ERP7__Bank_Reconciliation__c where Id =: brId Limit 1];
        return brRec;
    }
     @AuraEnabled 
    public static Account getDefaultOrganisation(){
        return UtilClass.getOrganisationByLogin_Employee();
    }  
    
    @AuraEnabled
    public static List<selectOptions> getBankReconciliationStatus(){
        List<selectOptions> options = new List<selectOptions>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Bank_Reconciliation__c.Status__c .getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(new SelectOptions(f.getLabel(), f.getValue())); 
        return options;
    }
    
    @AuraEnabled
    public static string updateBankReconciliation(String BRRec){
        try{
            if(BRRec != null && BRRec != ''){
            	ERP7__Bank_Reconciliation__c BankReconciliationRec = (ERP7__Bank_Reconciliation__c) JSON.deserialize(BRRec, ERP7__Bank_Reconciliation__c.class);
                if(BankReconciliationRec != null && Schema.SObjectType.ERP7__Bank_Reconciliation__c.isCreateable() && Schema.SObjectType.ERP7__Bank_Reconciliation__c.isUpdateable()){ upsert BankReconciliationRec;}else{/*No access*/}
            }
            return '';
        } catch (Exception ex){ return ex.getMessage(); }
    }
    
    public class Wrapper{
        @AuraEnabled public list<ERP7__Bank_Reconciliation__c> CompleteBRList                   {get;set;}
         @AuraEnabled public list<ERP7__Bank_Reconciliation__c> FilteredBRList                   {get;set;}
        @AuraEnabled public Integer recSize                                                     {get;set;}
        public Wrapper(){
            CompleteBRList=new list<ERP7__Bank_Reconciliation__c>();
            FilteredBRList=new list<ERP7__Bank_Reconciliation__c>();
        }
    }
}