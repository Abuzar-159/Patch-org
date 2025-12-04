global without sharing class ProductListCommSignIn {
    
    @AuraEnabled
    public static Wrapper checkPortal(String username, String password, String urlReturn, boolean navigateToSec) {
        Wrapper WP = new Wrapper();
        try {
            string redirectURL = '/s/';
            if (urlReturn != null && urlReturn != 'null' && urlReturn != '') redirectURL = urlReturn;
            ApexPages.PageReference lgn = Site.login(username, password, redirectURL);
            WP.url = lgn.getUrl();  
            string query = 'SELECT Id, Name, ERP7__Security_Question1__c, ERP7__Security_Question2__c, ERP7__SecurityAnswer1__c, ERP7__SecurityAnswer2__c FROM USER WHERE username = \'' + String.escapeSingleQuotes(userName) + '\' LIMIT 1';
            List < User > u = Database.query(query);
            if (u.size() > 0 && u[0].ERP7__Security_Question1__c != null && u[0].ERP7__Security_Question2__c != null && u[0].ERP7__SecurityAnswer1__c != null && u[0].ERP7__SecurityAnswer2__c != null && u[0].ERP7__Security_Question1__c != null && u[0].ERP7__Security_Question2__c != '' && u[0].ERP7__SecurityAnswer1__c != '' && u[0].ERP7__SecurityAnswer2__c != '') WP.needQuestion = true; 
            else WP.needQuestion = false; 
            WP.PortalUser = false; 
            User LU = [Select Id, Name, ContactId From User Where Id =: UserInfo.getUserId()];
            if(LU!=Null)WP.PortalUser = true; 
            return WP;
        } catch (Exception e) {
            WP.url = e.getMessage(); 
            system.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            return WP; 
        }
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
        String query = 'SELECT SecurityAnswer' + String.escapeSingleQuotes(randomN) + '__c FROM USER WHERE username = \'' + String.escapeSingleQuotes(userName) + '\' LIMIT 1';
        List < User > u = Database.query(query);
        if (u.size() > 0) {
            String sAns = (String) u[0].get('SecurityAnswer' + randomN + '__c');
            if (securityAns.toLowerCase().equals(sAns.toLowerCase())) { return 'Success';} }  return 'Failure';
    }
    
    @AuraEnabled
    global static String forgotPassowrd(String username) {
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
            WP.imageURL = imageURL;
            
            List<User> curUser=new List<User>();
            if(String.isEmpty(UserName)) curUser=[Select Id,Name,ContactId, isActive, SecurityAnswer1__c, SecurityAnswer2__c, Security_Question1__c, Security_Question2__c From User where id=:UserInfo.getUserId() Limit 1];        
            else curUser=[Select Id,Name,ContactId, isActive, SecurityAnswer1__c,SecurityAnswer2__c, Security_Question1__c, Security_Question2__c From User where Username=:Username AND IsActive=true Limit 1];        
            if(String.isEmpty(UserName)){ Contact con=[Select Id,Account.Subscribe_To_NewsLetters__c From Contact where id=:curUser[0].ContactId]; Account acc=[Select id,Subscribe_To_NewsLetters__c From Account where id=:con.AccountId]; WP.isActive=acc.Subscribe_To_NewsLetters__c; 
                                        }   
            WP.curUser=curUser;    
            if(curUser.size()>0) WP.username=curUser[0].Name;  
            
            string query = 'SELECT Id, Name,Security_Question1__c,Security_Question2__c, SecurityAnswer1__c, SecurityAnswer2__c FROM USER WHERE Id = \'' + curUser[0].Id + '\' LIMIT 1';
            List < User > u = Database.query(query);  WP.SecurityQuestions.add(u[0].Security_Question1__c); WP.SecurityQuestions.add(u[0].Security_Question2__c);
            
            //For SecurityQuestion 1
            Schema.DescribeFieldResult fieldResult = User.Security_Question1__c.getDescribe();List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for( Schema.PicklistEntry pickListVal : ple){ WP.optns.add(new selectOptions(pickListVal.getLabel(), pickListVal.getLabel())); }      Schema.DescribeFieldResult fieldResult2 = User.Security_Question2__c.getDescribe(); List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues(); for( Schema.PicklistEntry pickListVal : ple2){ WP.SQ2.add(new selectOptions(pickListVal.getLabel(), pickListVal.getLabel())); } 
            
            //For Random SQ
            Integer randNum;  randNum = Math.round(Math.random()) + 1;query = 'SELECT Security_Question' + randNum + '__c, SecurityAnswer' + randNum + '__c FROM USER WHERE Id = \'' + curUser[0].Id + '\' LIMIT 1';  u = Database.query(query); WP.SQForPassword= (String) u[0].get('Security_Question' + randNum + '__c'); 
            WP.SAForPassword= (String) u[0].get('SecurityAnswer' + randNum + '__c');
            
        }
        catch(Exception e){
            system.debug('err~>'+e.getMessage()+' at line~>'+e.getStackTraceString());
        }    
        return WP;
    }
    
    @AuraEnabled
    public static Wrapper updateSecurityQuestions(String SQ1, String SQ2, String SQAns1, String SQAns2, String UserName) {
     		Wrapper wrapper=new Wrapper();
            List<User> curUser=new List<User>();
            if(String.isEmpty(UserName)) curUser=[Select Id,Name,ContactId From User where id=:UserInfo.getUserId() Limit 1];
            else curUser=[Select Id,Name,ContactId From User where UserName=:UserName And IsActive=true Limit 1];
        
        string query = 'SELECT Id, Name, Security_Question1__c, Security_Question2__c, SecurityAnswer1__c, SecurityAnswer2__c FROM USER WHERE Id = \'' + curUser[0].Id + '\' LIMIT 1'; List < User > u = Database.query(query);  if(Schema.sObjectType.User.fields.Security_Question1__c.isUpdateable()){u[0].Security_Question1__c=SQ1;}else{/* no access*/ } if(Schema.sObjectType.User.fields.SecurityAnswer1__c.isUpdateable()){u[0].SecurityAnswer1__c=SQAns1;}else{/* no access*/ } if(Schema.sObjectType.User.fields.Security_Question2__c.isUpdateable()){u[0].Security_Question2__c=SQ2; } else{/* no access*/ } if(Schema.sObjectType.User.fields.SecurityAnswer2__c.isUpdateable()) {u[0].SecurityAnswer2__c=SQAns2;}else{/* no access*/ } if(Schema.sObjectType.User.isUpdateable()){update u;}else{/*'User have not permission to update User FLS');*/} query = 'SELECT Id, Name, Security_Question1__c, Security_Question2__c,SecurityAnswer1__c,SecurityAnswer2__c FROM USER WHERE Id = \'' + curUser[0].Id + '\' LIMIT 1'; u = Database.query(query);  wrapper.SecurityQuestions.add(u[0].Security_Question1__c); wrapper.SecurityQuestions.add(u[0].Security_Question2__c);return wrapper;
        
    }
    
    @AuraEnabled
    public static Wrapper deactivateUser(){
        Wrapper wrapper=new Wrapper();
        List<User> curUser=[Select Id,Name,ContactId From User where id=:UserInfo.getUserId() Limit 1];
        String query = 'SELECT Id, Name,IsActive, Security_Question1__c, Security_Question2__c, SecurityAnswer1__c, SecurityAnswer2__c FROM USER WHERE Id = \'' + curUser[0].Id + '\' LIMIT 1';
        List<User> u = Database.query(query); 
        if(Schema.sObjectType.User.fields.IsActive.isUpdateable()){ u[0].IsActive=false; } else{/* no access*/}
        if(Schema.sObjectType.User.isCreateable()){update u;}else{/*('User have not permission to update User FLS');*/} return wrapper;
    }   
    
    @AuraEnabled
    public static Wrapper updateSPNCheckbox(Boolean subsActive){
        Wrapper wrapper=new Wrapper();
        List<User> curUser=[Select Id,Name,isActive,ContactId From User where id=:UserInfo.getUserId() Limit 1];
        Contact con=[Select Id,AccountId From Contact where id=:curUser[0].ContactId]; Account acc=[Select id,Subscribe_To_NewsLetters__c From Account where id=:con.AccountId];  acc.Subscribe_To_NewsLetters__c=subsActive; if(Schema.sObjectType.Account.isUpdateable()){update acc;}else{/*('User have not permission to update record in Address FLS');*/}  return wrapper;
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
        @AuraEnabled public String imageURL               { get; set; }
        @AuraEnabled public List<User> curUser        { get; set; }
         
        public Wrapper() {
            isActive=false;
            SQForPassword = '';
            SAForPassword = '';
            errmsg = '';
            imageURL = '';
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
	    @AuraEnabled
    public static profileWrapper getProfileId(){
        profileWrapper pr=new profileWrapper();
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        //pr.profId=profileId;
        pr.profId=profileName;
        String name = userinfo.getFirstName()+' '+userinfo.getLastName();
        pr.name=name;
        
        if(profileName != 'ERP Product catalog Community Profile'  && profileName != System.Label.Supplier_Community_Guest_Profile){ // if(pr.profId != '00e1o000000JWJeAAO'){	//profileId of "ERP Product catalog Community Profile"	(Guest user)
            String userId=userinfo.getUserId();
            pr.user1=[Select Id, Name, CommunityNickname,ContactId from User where id =:userId and IsActive=true Limit 1];
            if(pr.user1.ContactId != null){
                List<Contact> conList=[Select Id, Name,AccountId from Contact where Id=:pr.user1.ContactId Limit 1];
                pr.acc=[Select Id, Name from Account where Id =:conList[0].AccountId Limit 1];
                List<ERP7__Cart__c> cart=[Select Id, Name from ERP7__Cart__c where ERP7__Account__c =:pr.acc.Id Limit 1];
                if(cart.size() == 0){
                    ERP7__Cart__c ct=new ERP7__Cart__c();
                    if(Schema.sObjectType.ERP7__Cart__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Cart__c.fields.Name.isUpdateable()) { ct.Name='Product Cart';} else{/* no acces*/}
                    if(Schema.sObjectType.ERP7__Cart__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Cart__c.fields.ERP7__Account__c.isUpdateable()){ct.ERP7__Account__c = pr.acc.Id;} else{/* no acces*/}
                    if(Schema.sObjectType.ERP7__Cart__c.isCreateable() && Schema.sObjectType.ERP7__Cart__c.isUpdateable()){ upsert ct;} else{/*No Permission*/}
                }
            }
        }
        
        return pr;
    }
    public class profileWrapper{
        @AuraEnabled public String profId 				{ get; set; }
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
}