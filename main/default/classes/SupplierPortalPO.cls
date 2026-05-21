global Without Sharing class SupplierPortalPO {
    /*public static final String FIELDS_PARAM = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';*/
    
    @AuraEnabled
    public static String initData(String jsonData){
        /*system.debug('label~>'+System.Label.SupplierSiteURL);
        system.debug('label~>'+System.Label.SupplierUserProfile);
        system.debug('label~>'+System.Label.Supplier_Community_Guest_Profile);
        system.debug('label~>'+System.Label.Supplier_Community_Guest_User);
        system.debug('label~>'+System.Label.Supplier_Community_Portal_Profile);
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
        String recordId = (String)requestMap.get(RECORD_ID_PARAM);
        String relatedFieldApiName = (String)requestMap.get(RELATED_FIELD_API_NAME_PARAM);
        responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName, relatedFieldApiName));
        
        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        return JSON.serialize(responseMap);*/
        return null;
    }
    
	@AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
		/*Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
		Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
		String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
		String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
		String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);        
        
        String query = 'Select '+String.escapeSingleQuotes(fields)+' From '+String.escapeSingleQuotes(sobjectApiName)+' WHERE ' +String.escapeSingleQuotes(relatedFieldApiName)+ '= :recordId ORDER BY ' +String.escapeSingleQuotes(orderBy)+' Limit :numberOfRecords';
        return Database.query(String.escapeSingleQuotes(query));*/
        return null;
	}
        
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        /*Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }
        return name;*/
        return null;
    }

	@AuraEnabled
    public static Boolean deleteRecord(Id recordId){
        Sobject sobj = recordId.getSObjectType().newSObject(recordId);
        Database.DeleteResult result;
        if(sobj.getSObjectType().getDescribe().isDeletable())  {  result = Database.delete(sobj, true); }
        else{ /* no access */ }
		return result.isSuccess();
	}       
    
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        /*String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            //if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            //}
        }
        return iconName;*/
        return null;
    }
    
    @AuraEnabled
    global static List<String> getFieldsSetApiName(){
        return null;
    }
    global static Id contactRTId;
    @AuraEnabled
    global static String forgotPassowrd(String username) {
        return null;
    }
    
    // ---------------------- Purchase Orders ---------------
    @AuraEnabled 
    public static List<ERP7__PO__c> getPOList(String AccId){
        String Vendor=UserInfo.getUserId();        
        String query='SELECT Id, Name, ERP7__Expected_Date__c, ERP7__Total_Amount__c ,ERP7__Inbound_Total_Quantity__c,ERP7__Inbound_Received_Quantity__c, ERP7__Tax_Amount__c  , ERP7__Status__c , ERP7__Total_Quantity__c ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Amount_Paid__c FROM ERP7__PO__c WHERE ERP7__Vendor__c =\''+AccId+'\'';
        //query +=' AND ERP7__Vendor__c IN: VendorId  order by Name  asc limit 2000 ';
        List<ERP7__PO__c> PoList=DataBase.query(query);
        return PoList;
        
    }
    
    @AuraEnabled 
    public static List<ERP7__Purchase_Line_Items__c> getPOLis(String recordId){
        String query='SELECT Id, Name, ERP7__Product__c, ERP7__Quantity__c ,ERP7__Quantity_Received__c FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c =\''+String.escapeSingleQuotes(recordId)+'\'';
        //query +=' AND ERP7__Vendor__c IN: VendorId  order by Name  asc limit 2000 ';
        List<ERP7__Purchase_Line_Items__c> PoList=DataBase.query(query);
        return PoList;
        
    }
    
    @AuraEnabled   
    public static wrapper1 fetchPO(Integer Offset,String AccId, Integer RecordLimit,String searchString, String OrderBy, String Order){
        try{
            Wrapper1 ar=new Wrapper1();
            String s= '%'+searchString+'%';
            Integer ikOffset = Integer.valueof(Offset);
            Integer ikRecordLimit = Integer.valueof(RecordLimit);
            String OrderBy2=OrderBy;
            String Order2=Order;
            List<Id> ids = new List<id>();        
            String query='SELECT Id, Name, ERP7__Expected_Date__c, ERP7__Total_Amount__c ,ERP7__Inbound_Total_Quantity__c,ERP7__Inbound_Received_Quantity__c,ERP7__Total_Due__c,ERP7__Order_Date__c, ERP7__Stage__c,ERP7__Tax_Amount__c  , ERP7__Status__c , ERP7__Total_Quantity__c ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Amount_Paid__c FROM ERP7__PO__c WHERE ERP7__Vendor__c =\''+String.escapeSingleQuotes(AccId)+'\'';
            if(searchString!=null && searchString!='') query += ' AND Name Like :s ';
            //if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
            //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name  asc limit 2000 ';
            query += ' order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2);
            ar.POSL = Database.query(query);
            ar.recSize = ar.POSL.size(); 
            query=null;
            query='SELECT Id, Name, ERP7__Expected_Date__c, ERP7__Total_Amount__c ,ERP7__Inbound_Total_Quantity__c,ERP7__Inbound_Received_Quantity__c, ERP7__Total_Due__c,ERP7__Order_Date__c, ERP7__Stage__c,ERP7__Tax_Amount__c  , ERP7__Status__c , ERP7__Total_Quantity__c ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Amount_Paid__c FROM ERP7__PO__c WHERE ERP7__Vendor__c =\''+String.escapeSingleQuotes(AccId)+'\'';//ERP7__Vendor__c =\''+AccId+'\''
            if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
            // if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
            //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name limit :ikRecordLimit Offset :ikOffset ';
            query += '  order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2)+' limit :ikRecordLimit Offset :ikOffset ';
            List<ERP7__PO__c> poList = new List<ERP7__PO__c>();
            ar.PO = Database.query(query);
            return ar;
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    public class wrapper1{
        
        public list<Account> acc             {set;get;} 
        @AuraEnabled     
        public list<Account> accSL             {set;get;} 
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public list<ERP7__PO__c> PO          {get;set;} 
        @AuraEnabled 
        public list<ERP7__PO__c> POSL          {get;set;} 
        
        public wrapper1(){
            acc = new List<Account>();
            accSL = new List<Account>();
            PO  = new List<ERP7__PO__c>();
            POSL = new List<ERP7__PO__c>(); 
        }
        
    } 
    //---------------- /Purchase Orders ---------------------
    
    //----------------Sign In----------------------
    @AuraEnabled
    public static Wrapper checkPortal(String username, String password, String urlReturn, boolean navigateToSec) {
        Wrapper WP = new Wrapper();
        /*try {
            string redirectURL = '/s/';
            if (urlReturn != null && urlReturn != 'null' && urlReturn != '') redirectURL = urlReturn;
            ApexPages.PageReference lgn = Site.login(username, password, redirectURL);
            WP.url = lgn.getUrl();  
            string query = 'SELECT Id, Name, ERP7__Security_Question1__c, ERP7__Security_Question2__c, ERP7__SecurityAnswer1__c, ERP7__SecurityAnswer2__c FROM USER WHERE username = \'' + String.escapeSingleQuotes(userName) + '\' LIMIT 1';
            List < User > u = Database.query(query);
            if (u.size() > 0 && u[0].ERP7__Security_Question1__c != null && u[0].ERP7__Security_Question2__c != null && u[0].ERP7__SecurityAnswer1__c != null && u[0].ERP7__SecurityAnswer2__c != null && u[0].ERP7__Security_Question1__c != null && u[0].ERP7__Security_Question2__c != '' && u[0].ERP7__SecurityAnswer1__c != '' && u[0].ERP7__SecurityAnswer2__c != '') 
                WP.needQuestion = true; 
            else 
                WP.needQuestion = false; 
            WP.PortalUser = false; 
            User LU = [Select Id, Name, ContactId From User Where Id =: UserInfo.getUserId()];  
            if(LU!=Null)
                WP.PortalUser = true; 
            return WP;
        } catch (Exception ex) { WP.url = ex.getMessage(); return WP; }*/
        return WP;
    }
    
    @AuraEnabled
    public static SecurityQuestionDetails getRandomSecurityQuestion(String userName) {
        Integer randNum; 
        randNum = Math.round(Math.random()) + 1;
        string email = UserInfo.getUserName();
        string query = 'SELECT Security_Question' + randNum + '__c FROM USER WHERE username = \'' + String.escapeSingleQuotes(userName) + '\' LIMIT 1';
        List < User > u = Database.query(query);
        string finalQuestion = (String) u[0].get('Security_Question' + randNum + '__c');
        return new SecurityQuestionDetails(finalQuestion, randNum + '', '');
    }
    
    @AuraEnabled
    public static string verifiedSecurityQuestion(String userName, String securityAns, String randomN) {
        String query = 'SELECT SecurityAnswer' + randomN + '__c FROM USER WHERE username = \'' + String.escapeSingleQuotes(userName) + '\' LIMIT 1';
        List < User > u = Database.query(query);
        if (u.size() > 0) {
            String sAns = (String) u[0].get('SecurityAnswer' + randomN + '__c');
            if (securityAns.toLowerCase().equals(sAns.toLowerCase())) { return 'Success';} }  return 'Failure';
    }
    
    @AuraEnabled
    global static String forgotPassword(String username) {
        String procesMsg = '';
        if (Site.isValidUsername(username)) {
            Site.forgotPassword(username);
            procesMsg = 'Please check your email and proceed with further steps';} else { procesMsg = 'Unable to reset';
                                                                                         
                                                                                         
                                                                                        }
        return procesMsg;
    }
    
    @AuraEnabled
    public static Wrapper getUserDetails(String UserName) {
        Wrapper WP = new Wrapper(); 
        /*try{
            List<User> curUser=new List<User>();
            if(String.isEmpty(UserName)) curUser=[Select Id,Name,ContactId, isActive, SecurityAnswer1__c, SecurityAnswer2__c, Security_Question1__c, Security_Question2__c From User where id=:UserInfo.getUserId() Limit 1];        
            else curUser=[Select Id,Name,ContactId, isActive, SecurityAnswer1__c,SecurityAnswer2__c, Security_Question1__c, Security_Question2__c From User where Username=:Username AND IsActive=true Limit 1];        
            if(String.isEmpty(UserName)){ Contact con=[Select Id,Account.Subscribe_To_NewsLetters__c From Contact where id=:curUser[0].ContactId]; Account acc=[Select id,Subscribe_To_NewsLetters__c From Account where id=:con.AccountId]; WP.isActive=acc.Subscribe_To_NewsLetters__c; 
                                        }   
            WP.curUser=curUser;    
            if(curUser.size()>0) WP.username=curUser[0].Name;  
            
            string query = 'SELECT Id, Name, ERP7__Security_Question1__c, ERP7__Security_Question2__c, ERP7__SecurityAnswer1__c, ERP7__SecurityAnswer2__c FROM USER WHERE Id = \'' + String.escapeSingleQuotes(curUser[0].Id) + '\' LIMIT 1';
            List < User > u = Database.query(query); 
            WP.SecurityQuestions.add(u[0].ERP7__Security_Question1__c); 
            WP.SecurityQuestions.add(u[0].ERP7__Security_Question2__c);
            
            //For SecurityQuestion 1
            Schema.DescribeFieldResult fieldResult = User.Security_Question1__c.getDescribe();List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for( Schema.PicklistEntry pickListVal : ple){ WP.optns.add(new selectOptions(pickListVal.getLabel(), pickListVal.getLabel())); }      Schema.DescribeFieldResult fieldResult2 = User.Security_Question2__c.getDescribe(); List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues(); for( Schema.PicklistEntry pickListVal : ple2){ WP.SQ2.add(new selectOptions(pickListVal.getLabel(), pickListVal.getLabel())); } 
            
            //For Random SQ
            Integer randNum;  randNum = Math.round(Math.random()) + 1;query = 'SELECT Security_Question' + randNum + '__c, SecurityAnswer' + randNum + '__c FROM USER WHERE Id = \'' + String.escapeSingleQuotes(curUser[0].Id) + '\' LIMIT 1';  u = Database.query(query); WP.SQForPassword= (String) u[0].get('Security_Question' + randNum + '__c'); WP.SAForPassword= (String) u[0].get('SecurityAnswer' + randNum + '__c');  return  WP;
        }
        
        catch(Exception e){
            WP.url = 'Exception : '+e.getMessage(); return WP;
        }   */
        return WP;
    }
    
    @AuraEnabled
    public static Wrapper updateSecurityQuestions(String SQ1, String SQ2, String SQAns1, String SQAns2, String UserName) {
        Wrapper wrapper=new Wrapper();
        List<User> curUser=new List<User>();
        if(String.isEmpty(UserName)) curUser=[Select Id,Name,ContactId From User where id=:UserInfo.getUserId() Limit 1];
        else curUser=[Select Id,Name,ContactId From User where UserName=:UserName And IsActive=true Limit 1];
        return wrapper;
        
    }
    
    @AuraEnabled
    public static Wrapper deactivateUser(){
        /*User curUser=[Select Id, Name,IsActive, ERP7__Security_Question1__c, ERP7__Security_Question2__c, ERP7__SecurityAnswer1__c, ERP7__SecurityAnswer2__c From User where id=:UserInfo.getUserId() Limit 1];
        String query = 'SELECT Id, Name,IsActive, ERP7__Security_Question1__c, ERP7__Security_Question2__c, ERP7__SecurityAnswer1__c, ERP7__SecurityAnswer2__c FROM USER WHERE Id =: UserInfo.getUserId() LIMIT 1';
        List<User> u = Database.query(query); 
        if(curUser.Id != null){
            curUser.IsActive=false;
            if(Schema.sObjectType.User.fields.IsActive.isUpdateable()) { update curUser; } else{ /* no access/ }
        }
        return null;*/
		return null;
    }
    
    @AuraEnabled
    public static Wrapper updateSPNCheckbox(Boolean subsActive){
        Wrapper wrapper=new Wrapper(); Contact con = new Contact(); Account acc = new Account();
        List<User> curUser=[Select Id,Name,isActive,ContactId From User where id=:UserInfo.getUserId() Limit 1];
        if(curUser[0].ContactId != null) con=[Select Id,AccountId From Contact where id=:curUser[0].ContactId]; 
        if(con.AccountId != null) acc=[Select id,Subscribe_To_NewsLetters__c From Account where id=:con.AccountId];  
        if(acc.Id != null) {acc.Subscribe_To_NewsLetters__c=subsActive; If(Schema.sObjectType.Account.fields.ERP7__Subscribe_To_NewsLetters__c.isUpdateable()) { update acc;} else{ /* no acess */ } } return wrapper;
    }
    
    @AuraEnabled
    public static Wrapper updatePassword(String newPass, String verifyNewPass,String oldPass){
        Wrapper wrapper=new Wrapper();
        try{
            //lgn=Site.changePassword(newPass, verifyNewPass);
            Site.changePassword(newPass, verifyNewPass, oldPass);
            return Wrapper;   }catch(Exception e){   wrapper.errmsg=String.valueof(e);  return wrapper;
                                                 }   
    } 
    
    
    public class SecurityQuestionDetails {
        @AuraEnabled public String question                 { get; set; }
        @AuraEnabled public String randumNumber             { get; set; }
        @AuraEnabled public String userId                   { get; set; }
        
        public SecurityQuestionDetails(string question, String randumNumber, String userId) {
            this.question = question;
            this.randumNumber = randumNumber;
            this.userId = userId;
        }
        
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab; value = val; selected = sel;
        }
    }
    
    public class Wrapper {
        @AuraEnabled public String url               { get; set; }
        @AuraEnabled public Boolean needQuestion      { get; set; }
        @AuraEnabled public List<String> SecurityQuestions      { get; set; }
        @AuraEnabled public String username               { get; set; }
        @AuraEnabled public String errmsg               { get; set; }
        @AuraEnabled public Boolean PortalUser       { get; set; }
        @AuraEnabled public List<selectOptions>  optns    { get; set; }    
        @AuraEnabled public List<selectOptions>  SQ2    { get; set; }
        @AuraEnabled public String SQForPassword               { get; set; } 
        @AuraEnabled public String SAForPassword               { get; set; }
        @AuraEnabled public Boolean isActive               { get; set; } 
        
        @AuraEnabled public List<User> curUser        { get; set; }
        
        public Wrapper() {
            isActive=false;
            SQForPassword = '';
            SAForPassword = '';
            errmsg = '';
            optns=new List<selectOptions>();
            SQ2=new List<selectOptions>();
            username = '';
            url = '';
            needQuestion = false;
            SecurityQuestions=new List<String>();
            PortalUser = false;
            User LU = [Select Id, Name, ContactId From User Where Id =: UserInfo.getUserId()]; 
            if(LU.ContactId != Null) PortalUser = true;
            curUser=new List<User>();
        }
    }
    
    //---------------/Sign In----------------------
    
    //------------------- Bills -------------------
    
    @AuraEnabled 
    public static wrapper2 fetchBills(String AccId, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString){
        
        try{
            Wrapper2 ar=new Wrapper2();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String OrderBy2=OrderBy;
        String Order2=Order;
        List<Id> ids = new List<id>();
        String query='SELECT Id, Name, ERP7__Status__c,ERP7__Due_Date__c, RecordTypeId, ERP7__Amount_Due__c , ERP7__Amount_Paid__c  , ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c=\''+String.escapeSingleQuotes(AccId)+'\'  and RecordTypeId != null ';// 
        //ids = accId.split(',');
        /*List<Id> vendids = new List<id>();
vendids = vids.split(',');*/
        
        //ids.add('a321o000000wzJrAAI');
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        //if(String.isNotEmpty(accId))query+=' AND ERP7__Purchase_Order__c IN: ids ';
        //if(String.isNotEmpty(vids))query+=' AND ERP7__Vendor__c IN: vendids ';
        query += ' order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2);
        ar.BillsSL = Database.query(query);
        ar.recSize = ar.BillsSL.size(); 
        query=null;
        query='SELECT Id, Name, ERP7__Status__c,ERP7__Due_Date__c, RecordTypeId, ERP7__Amount_Due__c , ERP7__Amount_Paid__c  , ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c=\''+String.escapeSingleQuotes(AccId)+'\'  and RecordTypeId != null ';// 
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        //if(String.isNotEmpty(accId))query+=' AND ERP7__Purchase_Order__c IN: ids ';
        //if(String.isNotEmpty(vids))query+=' AND ERP7__Vendor__c IN: vendids ';
        query += '  order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2)+' limit :ikRecordLimit Offset :ikOffset ';
        ar.Bills = Database.query(query);
        List<ERP7__Bill__c> billList = new List<ERP7__Bill__c>();
        ar.Bills = Database.query(query);
             return ar;
            } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
       
        
    }
    public class wrapper2{
        
        @AuraEnabled     
        public list<Account> acc             {set;get;} 
        @AuraEnabled     
        public list<Account> accSL             {set;get;} 
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public list<ERP7__BILL__c> Bills     {get;set;}
        @AuraEnabled 
        public list<ERP7__BILL__c> BillsSL     {get;set;}
        
        public wrapper2(){
            acc = new List<Account>();
            accSL = new List<Account>();
            Bills = new List<ERP7__BILL__c>();
            BillsSL = new List<ERP7__BILL__c>();
            
        }
        
    } 
    
    //------------------- /Bills -------------------
    
    //---------------Work Orders------------------
    
    
    @AuraEnabled 
    public static wrapper3 fetchWO(String AccId, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString){
        Wrapper3 ar=new Wrapper3();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String OrderBy2=OrderBy;
        String Order2=Order;
        String query='SELECT Id, Name, ERP7__ExpectedDate__c,ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name, ERP7__Product__c,ERP7__Product__r.Name,  ERP7__Status__c,ERP7__Total_Quantity__c, ERP7__End_Date__c ,ERP7__WO_Supplier__r.Name,ERP7__WO_Supplier__c FROM ERP7__WO__c WHERE ERP7__WO_Supplier__c =: AccId';//,RecordType.DeveloperName
        List<Id> ids = new List<id>();
        ids = accId.split(',');
        if(searchString!=null && searchString!='')query += ' AND Name Like: s ';
        //if(String.isNotEmpty(accId))query+=' AND ERP7__Purchase_Order__c IN: ids ';
        //if(String.isNotEmpty(vids))query+=' AND ERP7__Vendor__c IN: vendids ';
        query += ' order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2);
        ar.WOSL = Database.query(query);
        ar.recSize = ar.WOSL.size(); 
        query=null;
        query='SELECT Id, Name, ERP7__ExpectedDate__c,ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name, ERP7__Product__c,ERP7__Product__r.Name,  ERP7__Status__c,ERP7__Total_Quantity__c, ERP7__End_Date__c ,ERP7__WO_Supplier__r.Name,ERP7__WO_Supplier__c FROM ERP7__WO__c WHERE ERP7__WO_Supplier__c =: AccId'; 
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        //if(String.isNotEmpty(accId))query+=' AND ERP7__Purchase_Order__c IN: ids ';
        //if(String.isNotEmpty(vids))query+=' AND ERP7__Vendor__c IN: vendids ';
        query += '  order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2)+' limit :ikRecordLimit Offset :ikOffset ';
        ar.WO = Database.query(query);
        List<ERP7__WO__c> WOList = new List<ERP7__WO__c>();
        ar.WO = Database.query(query);
        return ar;
        
    }
    public class wrapper3{
        
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public list<ERP7__WO__c> WO          {get;set;} 
        @AuraEnabled 
        public list<ERP7__WO__c> WOSL          {get;set;} 
        
        public wrapper3(){
            WO  = new List<ERP7__WO__c>();
            WOSL = new List<ERP7__WO__c>(); 
        }
        
    }
    
    //------------- /Work Orders--------------
    
    //-------------Payments------------------
    
    @AuraEnabled
    public static Wrapper4 fetchPayments(String AccId,String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString){
        Wrapper4 ar=new Wrapper4();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String OrderBy2=OrderBy;
        String Order2=Order;
        String query='SELECT Id, Name, ERP7__Amount__c, ERP7__Posted__c, ERP7__Status__c, ERP7__Voucher__c, ERP7__Voucher__r.Name, ERP7__Bill__c, ERP7__Bill__r.Name, ERP7__Accounts__r.Name, ERP7__Bill__r.ERP7__Purchase_Order__r.Name FROM ERP7__Payment__c WHERE ERP7__Bill__r.ERP7__Vendor__c =: AccId';//ERP7__Bill__r.ERP7__Purchase_Order__r.Name,
        List<Id> ids = new List<id>(); 
        //ids = accId.split(',');
        //List<Id> vouids = new List<id>(); 
        //vouids = vouchIds.split(','); 
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        //if(String.isNotEmpty(accId))query +='AND ERP7__Accounts__c IN: ids ';
        //if(String.isNotEmpty(vouchIds))query +='AND ERP7__Voucher__c IN: vouids ';
        //"Apex methods that are to be cached must be marked as @AuraEnabled(cacheable=true)"
        ar.PaymentsSL = Database.query(query);
        ar.recSize = ar.PaymentsSL.size(); 
        query=null;
        query='SELECT Id, Name, ERP7__Amount__c, ERP7__Posted__c, ERP7__Status__c, ERP7__Voucher__c, ERP7__Voucher__r.Name, ERP7__Bill__c, ERP7__Bill__r.Name, ERP7__Accounts__r.Name, ERP7__Bill__r.ERP7__Purchase_Order__r.Name FROM ERP7__Payment__c WHERE ERP7__Bill__r.ERP7__Vendor__c =: AccId';//ERP7__Bill__r.ERP7__Purchase_Order__r.Name,
        
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        // if(String.isNotEmpty(accId))query +='AND ERP7__Accounts__c IN: ids ';
        //if(String.isNotEmpty(vouchIds))query +='AND ERP7__Voucher__c IN: vouids ';
        query += '  order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2)+' limit :ikRecordLimit Offset :ikOffset ';
        ar.Payments = Database.query(query);
        List<ERP7__Payment__c> PList = new List<ERP7__Payment__c>();
        ar.Payments = Database.query(query);
        return ar;
        
    }
    public class wrapper4{
        
        @AuraEnabled     
        public list<Account> acc             {set;get;} 
        @AuraEnabled     
        public list<Account> accSL             {set;get;} 
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public List<Payment__c> Payments     {get;set;}
        @AuraEnabled 
        public List<Payment__c> PaymentsSL     {get;set;}
        
        public wrapper4(){
            acc = new List<Account>();
            accSL = new List<Account>();
            Payments = new List<Payment__c>();
            PaymentsSL = new List<Payment__c>();
        }
        
    }
    
    //------------------/Payments--------------
    
    //----------------Expense---------
    
    
    @AuraEnabled   
    public static wrapper5 fetchExpense(Integer Offset,String AccId, Integer RecordLimit,String searchString, String OrderBy, String Order){
        Wrapper5 ar=new Wrapper5();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String OrderBy2=OrderBy;
        String Order2=Order;
        List<Id> ids = new List<id>();        
        String query='SELECT Id, Name, ERP7__Project__c,ERP7__Project__r.Name ,ERP7__Amount_Submitted__c,	ERP7__VAT_Amount__c, ERP7__Amount__c  , ERP7__Date__c, ERP7__Status__c FROM ERP7__Expense__c WHERE ERP7__Vendor_Account__c =\''+String.escapeSingleQuotes(AccId)+'\'';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        //if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name  asc limit 2000 ';
        query += ' order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2);
        ar.ExpSL = Database.query(query);
        ar.recSize = ar.ExpSL.size(); 
        query=null;
        query='SELECT Id, Name, ERP7__Project__c ,ERP7__Project__r.Name, ERP7__Amount_Submitted__c,	ERP7__VAT_Amount__c, ERP7__Amount__c  , ERP7__Date__c, ERP7__Status__c FROM ERP7__Expense__c WHERE ERP7__Vendor_Account__c =\''+String.escapeSingleQuotes(AccId)+'\'';//ERP7__Vendor__c =\''+AccId+'\''
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        // if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name limit :ikRecordLimit Offset :ikOffset ';
        query += '  order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2)+' limit :ikRecordLimit Offset :ikOffset ';
        List<ERP7__Expense__c> poList = new List<ERP7__Expense__c>();
        ar.Exp = Database.query(query);
        return ar;
    }
    
    public class wrapper5{
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public list<ERP7__Expense__c> Exp         {get;set;} 
        @AuraEnabled 
        public list<ERP7__Expense__c> ExpSL          {get;set;} 
        
        public wrapper5(){
            Exp  = new List<ERP7__Expense__c>();
            ExpSL = new List<ERP7__Expense__c>(); 
            
        }
        
    } 
    
    //--------------- /Expense---------------
    
    //-------------- Timesheets-------------
    
    @AuraEnabled   
    public static wrapper6 fetchTimesheet(Integer Offset,String AccId, Integer RecordLimit,String searchString, String OrderBy, String Order){
        Wrapper6 ar=new Wrapper6();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String OrderBy2=OrderBy;
        String Order2=Order;
        List<Id> ids = new List<id>();        
        String query='SELECT Id, Name, ERP7__Project__c,ERP7__Project__r.Name ,ERP7__Total_Hours__c,ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Week_Date__c, ERP7__Status__c FROM ERP7__Timesheet__c WHERE ERP7__Vendor_Account__c =\''+String.escapeSingleQuotes(AccId)+'\''; //ERP7__Vendor_Account__c
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        //if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name  asc limit 2000 ';
        query += ' order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2);
        ar.TimesheetSL = Database.query(query);
        ar.recSize = ar.TimesheetSL.size(); 
        query=null;
        query='SELECT Id, Name, ERP7__Project__c ,ERP7__Project__r.Name, ERP7__Total_Hours__c,ERP7__Approver__c, ERP7__Approver__r.Name, ERP7__Week_Date__c, ERP7__Status__c FROM ERP7__Timesheet__c WHERE ERP7__Vendor_Account__c =\''+String.escapeSingleQuotes(AccId)+'\'';//ERP7__Vendor__c =\''+AccId+'\''
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        // if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name limit :ikRecordLimit Offset :ikOffset ';
        query += '  order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2)+' limit :ikRecordLimit Offset :ikOffset ';
        List<ERP7__Timesheet__c> TSList = new List<ERP7__Timesheet__c>();
        ar.Timesheet = Database.query(query);
        return ar;
    }
    
    public class wrapper6{
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public list<ERP7__Timesheet__c> Timesheet        {get;set;} 
        @AuraEnabled 
        public list<ERP7__Timesheet__c> TimesheetSL          {get;set;} 
        
        public wrapper6(){
            Timesheet  = new List<ERP7__Timesheet__c>();
            TimesheetSL = new List<ERP7__Timesheet__c>(); 
            
        }
        
    } 
    
    //----------------/Timesheets-------------
    
    //---------------Contracts-------------
    
    @AuraEnabled   
    public static wrapper7 fetchContract(Integer Offset,String AccId, Integer RecordLimit,String searchString, String OrderBy, String Order){
        Wrapper7 ar=new Wrapper7();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String OrderBy2=OrderBy;
        String Order2=Order;
        List<Id> ids = new List<id>();        
        String query='SELECT Id, Name, Status ,StartDate,EndDate, ContractTerm FROM Contract WHERE AccountId =\''+String.escapeSingleQuotes(AccId)+'\'';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        //if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name  asc limit 2000 ';
        query += ' order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2);
        ar.ContractSL = Database.query(query);
        ar.recSize = ar.ContractSL.size(); 
        query=null;
        query='SELECT Id, Name, Status ,StartDate,EndDate, ContractTerm FROM Contract WHERE AccountId =\''+String.escapeSingleQuotes(AccId)+'\'';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        // if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        //if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name limit :ikRecordLimit Offset :ikOffset ';
        query += '  order by '+String.escapeSingleQuotes(OrderBy2)+' '+String.escapeSingleQuotes(Order2)+' limit :ikRecordLimit Offset :ikOffset ';
        List<Contract> contractList = new List<Contract>();
        ar.Contract = Database.query(query);
        return ar;
    }
    
    public class wrapper7{
        
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public list<Contract> Contract          {get;set;} 
        @AuraEnabled 
        public list<Contract> ContractSL          {get;set;} 
        
        public wrapper7(){
            
            Contract = new List<Contract>();
            ContractSL = new List<Contract>(); 
            
        }
        
    } 
    
    //------------------------DetailPage-------------------
    @AuraEnabled
    public static PageLayout getPageLayoutMetadata(String pageLayoutName) {
        List<String> componentNameList = new List<String>{pageLayoutName};
            
            if (String.isBlank(pageLayoutName)) {
                return new PageLayout();
            }
        
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);
        if (layouts.size() > 0) {
            return new PageLayout((Metadata.Layout) layouts[0]);
        }
        
        return new PageLayout();
    }
    
    public class PageLayout {
        @AuraEnabled
        public List<PageLayoutSection> Sections { get; set; }
        
        public PageLayout() {
            Sections = new List<PageLayoutSection>();
        }
        
        public PageLayout(Metadata.Layout layout) {
            /*this();
            
            for (Metadata.LayoutSection section : layout.layoutSections) {
                if (section.style != Metadata.LayoutSectionStyle.CustomLinks) {
                    Sections.add(new PageLayoutSection(section));
                }
            }*/
        }
    }
    
    public class PageLayoutSection {
        /*@AuraEnabled
        public List<PageLayoutSectionColumn> Columns { get; set; }
        
        @AuraEnabled
        public String Label { get; set; }
        
        public PageLayoutSection(Metadata.LayoutSection section) {
            Columns = new List<PageLayoutSectionColumn>();
            
            Label = section.label;
            
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                Columns.add(new PageLayoutSectionColumn(column));
            }
        }*/
    }
    
    public class PageLayoutSectionColumn {
        /*@AuraEnabled
        public List<PageLayoutField> Fields { get; set; }
        
        public PageLayoutSectionColumn(Metadata.LayoutColumn column) {
            Fields = new List<PageLayoutField>();
            
            if (column.layoutItems == null) {
                return;
            }
            
            for (Metadata.LayoutItem item : column.layoutItems) {
                Fields.add(new PageLayoutField(item));
            }
        }*/
    }
    
    public class PageLayoutField {
        /*@AuraEnabled
        public String APIName { get; set; }
        
        public PageLayoutField(Metadata.LayoutItem item) {
            APIName = item.field;
        }*/
    }
    
    //--------------------- DetailPage End------------------------
    
        
    //---------------- Profile ----------------------
    
    
    private static final Integer NUM_SEC_QUESTIONS = 2;
    private static final String profileName = System.Label.Supplier_Community_Portal_Profile; //'Partner Community Portal User';
    private static String salutation = '';
    private static String firstname = '';
    private static String lastname = '';
    private static String email = '';
    private static String dob = '';
    private static String middlename = '';
    private static String rAddressLookup = '';
    private static Boolean rAddressNotFound = false;
    private static String rAptSuite = '';
    private static String rAddressLine1 = '';
    private static String rCity = '';
    private static String rPostalCode = '';
    private static String rProvince = '';
    private static String rCountry = '';
    private static Boolean isMailingAddressSame = false;
    private static String mAddressLookup = '';
    private static Boolean mAddressNotFound = false;
    private static String mAptSuite = '';
    private static String mAddressLine1 = '';
    private static String mCity = '';
    private static String mPostalCode = '';
    private static String mProvince = '';
    private static String mCountry = '';
    private static String methodOfContact = '';
    private static String homePhone = '';
    private static String mobilePhone = '';
    private static Boolean peelNewsletter = false;
    private static Boolean newsNofification = false;
    private static String cellphone = '';
    private static String currentContactId = '';
    private static String programName = '';
    private static Id profileId;
    //global static Id contactRTId;
    private static Id accountRTID;
    private static Id residentAddressId;
    private static Id mailingAddressId;
    private static User registeredUser = new User();
    private static Account newCreatedAccount = new Account();
    private static Contact newCreatedContact = new Contact();
    private static String currentUserId = '';
    private static String passInfo = '';
    private static boolean newLetterSub = false;
    
    @AuraEnabled
    public static profileWrapper getProfileId(){
        profileWrapper pr=new profileWrapper();
        try{
            String imageURL = '/servlet/servlet.ImageServer?id=';
            String oid = userInfo.getOrganizationId();
            if(Schema.sObjectType.Document.isAccessible()) {
                List<Document> documentList = new List<Document>();
                documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
                if(documentList.size() > 0){
                    imageURL += documentList[0].id;
                    imageURL += '&oid='+oid;
                } else imageURL = '';
            } else imageURL = '';
            pr.imageURL = imageURL;
            Id profileId = userinfo.getProfileId();
            String profileId1 =[Select Id,Name from Profile where Id=:profileId].Id;
            String profileName1 =[Select Id,Name from Profile where Id=:profileId].Id;
            //pr.profId=profileId;
            pr.profId = profileId1;
            String name = userinfo.getFirstName()+' '+userinfo.getLastName();
            pr.name=name;
            
            if(profileName1 != 'ERP Product catalog Community Profile' && profileName1 != System.Label.Supplier_Community_Guest_Profile){ // 'ERP Supplier Portal Community Profile' //if(pr.profId != '00e1o000000JWJeAAO'){	//profileId of "ERP Product catalog Community Profile"	(Guest user)
                String userId=userinfo.getUserId();
                pr.user1=[Select Id, Name, CommunityNickname,ContactId from User where id =:userId and IsActive=true Limit 1];
                if(pr.user1.ContactId != null){
                    List<Contact> conList=[Select Id, Name,AccountId from Contact where Id=:pr.user1.ContactId Limit 1];
                    if(conList.size()>0){
                        if(conList[0].AccountId != null) pr.acc=[Select Id, Name from Account where Id =:conList[0].AccountId Limit 1];
                    } 
                    List<ERP7__Cart__c> cart=[Select Id, Name from ERP7__Cart__c where ERP7__Account__c =:pr.acc.Id Limit 1];
                    if(cart.size() == 0){
                        ERP7__Cart__c ct=new ERP7__Cart__c();
                        if(Schema.sObjectType.ERP7__Cart__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Cart__c.fields.Name.isUpdateable()){ct.Name='Product Cart'; }  else { /* no access */ }
                        if(Schema.sObjectType.ERP7__Cart__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Cart__c.fields.ERP7__Account__c.isUpdateable()){ct.ERP7__Account__c = pr.acc.Id; }  else { /* no access */ }
                        if(Schema.sObjectType.ERP7__Cart__c.isUpdateable() && Schema.sObjectType.ERP7__Cart__c.isUpdateable()){ upsert ct; } else { /* no access */ }
                    }
                }
            }
        }catch(Exception e){
            system.debug('exception~>'+e.getMessage()+' at line~>'+e.getStackTraceString());
        }
        return pr;
    }
    
    public class profileWrapper{
        @AuraEnabled public String profId 				{ get; set; } 
        @AuraEnabled public String imageURL 				{ get; set; }
        @AuraEnabled public String name 				{ get; set; }
        @AuraEnabled public User user1			{ get; set; }
        @AuraEnabled public Account acc					{ get; set; }
        public profileWrapper(){
            profId = '';
            name = '';
            user1=new User();
            acc= new Account();
        }
    }
    
    //======================Registration---------------------------
        
   @AuraEnabled
    Global static String registerUserSelf(String email, String firstName, String middleName, String lastName, String pass, Boolean newLetterSub) { //Map < String, Object > userInfo
        String result = 'SUCCESS' + email;
        String tempNickName = '';
        try{
           String UserId = '';
            List < Profile > profList = [SELECT Id FROM Profile WHERE Name ='System Administrator'];
            if( profList.size() >0 ){
                List<User> userForRole =[Select id from User where profileId =:profList[0].Id AND isActive=true AND UserRoleId != Null ];
                if( userForRole.size() >0 )UserId = userForRole[0].Id;
            } 
            /*firstname = '' + userInfo.get('firstName');
            lastname = '' + userInfo.get('lastName');
            email = '' + userInfo.get('email');
            newLetterSub = (boolean) userInfo.get('newLetterSub');
            */
            if (doesUserExist(email)) {return 'Already Registered with this email';
            }
            registeredUser = new User();
            List<Account> Accounts = [Select Id, Name, ERP7__Email__c, Phone, ERP7__Is_Portal_Account__c, ERP7__Subscribe_To_NewsLetters__c From Account Where ERP7__Email__c =: email Limit 1];
            newCreatedContact = new Contact();
            if(Accounts.size() > 0){ newCreatedAccount = Accounts[0]; newCreatedAccount.Is_Portal_Account__c = true; newCreatedAccount.ERP7__Subscribe_To_NewsLetters__c = newLetterSub;
                if( UserId != Null ) 
                newCreatedAccount.OwnerId =UserId;
                                    if(Schema.sObjectType.Account.fields.OwnerId.isUpdateable() && Schema.sObjectType.Account.fields.ERP7__Subscribe_To_NewsLetters__c.isUpdateable() && Schema.sObjectType.Account.fields.Is_Portal_Account__c.isUpdateable()) { update newCreatedAccount; } else{ /* no access */ }
                List<Contact> Contacts = [Select Id, FirstName, LastName, Email, AccountId, Phone From Contact Where Email =: email And AccountId =: Accounts[0].Id Limit 1];
                if(Contacts.size() > 0){
                    newCreatedContact = Contacts[0]; newCreatedContact.firstName = firstName; newCreatedContact.lastName = lastName;
                    if(Schema.sObjectType.Contact.fields.firstName.isUpdateable() && Schema.sObjectType.Contact.fields.lastName.isUpdateable()) { update newCreatedContact; } else{ /* no acess */ }
                } else {
                    newCreatedContact.firstName = firstName; newCreatedContact.lastName = lastName; newCreatedContact.email = email; newCreatedContact.AccountId = newCreatedAccount.Id;
                    if(Schema.sObjectType.Contact.fields.firstName.isCreateable() && Schema.sObjectType.Contact.fields.lastName.isCreateable() && Schema.sObjectType.Contact.fields.email.isCreateable() && Schema.sObjectType.Contact.fields.AccountId.isCreateable()) { insert newCreatedContact; } else{ return 'User not allowed to insert  contact';}
                }
            }
            else {
                newCreatedAccount = new Account(Name = firstName + ' ' + lastName, ERP7__Email__c = email, ERP7__Is_Portal_Account__c = true, ERP7__Account_Type__c='Vendor', ERP7__Subscribe_To_NewsLetters__c = newLetterSub);
                if( UserId != Null ) 
                newCreatedAccount.OwnerId =UserId;
                if(Schema.sObjectType.Account.fields.OwnerId.isCreateable() && Schema.sObjectType.Account.fields.Name.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Email__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Is_Portal_Account__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Account_Type__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Subscribe_To_NewsLetters__c.isCreateable() ) { insert newCreatedAccount; } else { return 'User is not allowed to create Account';}
                newCreatedContact.firstName = firstName;
                newCreatedContact.lastName = lastName;
                newCreatedContact.email = email;
                newCreatedContact.AccountId = newCreatedAccount.Id;
                if(Schema.sObjectType.Contact.fields.firstName.isCreateable() && Schema.sObjectType.Contact.fields.lastName.isCreateable() && Schema.sObjectType.Contact.fields.email.isCreateable() && Schema.sObjectType.Contact.fields.AccountId.isCreateable()) { insert newCreatedContact; } else{ return 'User not allowed to insert  contact';} 
            }
            registeredUser.Username = email;
            registeredUser.FirstName = firstName;
            registeredUser.LastName = lastName;
            registeredUser.Email = email;
            registeredUser.ProfileId = getProfileIdDetails(); //
            tempNickName = ((firstname != null && firstname.length() > 0) ? firstname.substring(0, 1) : '') + lastname.substring(0, 1);
            tempNickName += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
            registeredUser.Alias = tempNickName; 
            registeredUser.CommunityNickname = tempNickName; 
            registeredUser.EmailEncodingKey = 'ISO-8859-1';
            registeredUser.IsActive = true;
            String accountId = newCreatedContact.AccountId;
            if (accountId != null) {
                currentUserId = Site.createPortalUser(registeredUser, accountId, null);
            }
        } catch (Exception e) {return 'Exception => '+e.getMessage()+' '+e.getLineNumber(); }
        return 'User Created Successfully';
        //return null;
    }
    
    @TestVisible
    private static boolean doesUserExist(String email) {
        List < User > users = [SELECT Id FROM User WHERE username = : email];
        if (users.size() > 0) return true;
        else return false;
    }
    @TestVisible
    private static Id getProfileIdDetails() {
        if (profileId == null || profileId == '') {
            List < Profile > idList = [SELECT Id FROM Profile WHERE Name = : profileName];
            if (idList.size() > 0) {
                profileId = idList[0].id;
            }
        }
        return profileId;
    }
    
    @AuraEnabled 
    public static List<String> getFieldsSetApiName2(String sObjectName,String fieldSetApiName){
        return UtilClass.getFieldsSetApiName(sObjectName, fieldSetApiName);
    }
    
    @AuraEnabled 
    public static List<Id> RelatedList(String RecordId,String sObjectName,String relationship){
        List<sObject> poli=new List<sObject>();
        List<Id> relatedIds=new List<Id>();
        String query='select Id,Name from '+String.escapeSingleQuotes(sObjectName)+' where '+String.escapeSingleQuotes(relationship)+'=:RecordId';
        poli=database.query(query);
        for(sObject pp:poli){
            relatedIds.add(pp.Id);
        }
        return relatedIds;
    }
    
}