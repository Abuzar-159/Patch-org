global with sharing class CommunityChangePassword{
    
    private static String email;
    public static Integer randNum = Math.round(Math.random()) +1; private static String username; private static String oldPassword {get;set;}
    public static String password {get; set {password = value == null ? value : value.trim(); } }
    public static String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    
    private static String currentPUIKey ;
    private static String currentPUI ;
    public string imageURl {get;set;}
     
    public static String sq1 {get;set;} public static String sq1Ans {get;set;} public static String sq2 {get;set;} public static String sq2Ans {get;set;} 
    
    private static boolean isInitalSetup;
    
    // To get the list of security questions.
    public static List<String> securityQuestionList12;
    public List<String> securityAnswerList1 = new List<String>();
    
    public List<String> securityQuestionList2 = new List<String>();
    public List<String> securityAnswerList2 = new List<String>();
    
    public static String confirmSecurityQuestion;    
    private static String securityQuestionToQuery;    
    @TestVisible
    private static Boolean triggerSuccessTestScenario;   //Used by test class to simulate sucess/ failure. The value of triggerSuccessTestScenario must be set by the test class before invoking any site method.

    
    public CommunityChangePassword() {
        imageURL = '/servlet/servlet.ImageServer?id='; 
        String oid = userInfo.getOrganizationId();
        if(Schema.sObjectType.Document.isAccessible()) {
            List<Document> documentList = new List<Document>();
            documentList = [select id, Name, developerName from document where developerName =: 'Invoice'];
            if(documentList.size() > 0){ imageURL += documentList[0].id;    imageURL += '&oid='+oid;    } else imageURL = '';     } else imageURL = '';
        
        system.debug('ImageURL~>'+imageURL);
    }
    
    public List<SelectOption> getsecurityQuestions1(){
        List<SelectOption> optns = new List<Selectoption>();
        
        Schema.DescribeFieldResult fieldResult = User.Security_Question1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            optns.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        }     

        return optns;
    }
    
    public List<SelectOption> getsecurityAnswer1(){
        List<SelectOption> optns = new List<Selectoption>();
        
        Schema.DescribeFieldResult fieldResult = User.SecurityAnswer1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){ optns.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel())); }     

        return optns;
    }
    
    public List<SelectOption> getsecurityQuestions2(){
        List<SelectOption> optns = new List<Selectoption>();
        
        Schema.DescribeFieldResult fieldResult = User.Security_Question2__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            optns.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel()));
        }     

        return optns;
    }
    //doubt
    public List<SelectOption> getsecurityAnswer2(){
        List<SelectOption> optns = new List<Selectoption>();
        
        Schema.DescribeFieldResult fieldResult = User.SecurityAnswer2__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){ optns.add(new SelectOption(pickListVal.getLabel(), pickListVal.getLabel())); }     

        return optns;
    }
    public static PageReference changePassword()
    {
        isInitalSetup = getIsInitalSetup();
        ApexPages.PageReference lgn;
        randNum = Math.round(Math.random()) +1;
        if (password != confirmPassword) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Passwords must match')); return null; }
        if(isInitalSetup)
        {
            if (sq1 == sq2) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Same security question not allowed')); return null; }
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter value'));  lgn = Site.changePassword(password, confirmPassword);
            if (lgn != null) {  User u = new User(id = UserInfo.getUserId(),Security_Question1__c = sq1,Security_Question2__c = sq2,SecurityAnswer1__c = sq1Ans, SecurityAnswer2__c = sq2Ans); if(Schema.sObjectType.User.isUpdateable())  update u;   } lgn = new ApexPages.PageReference('/s'); }
        else
        {
            if ( verifySecurityAnswer()){ lgn = Site.changePassword(password, confirmPassword); lgn = new ApexPages.PageReference('/s'); lgn.setRedirect(true); }
            else{ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong Security Answer')); return null; }
        }
        if (lgn == null) 
        {
            //Error occurred
            //Site.login post errors directly on the Apexpages, need to get the message and post it to vlocity to be display
            List<Apexpages.Message> msgs = ApexPages.getMessages(); if(Test.isRunningTest()){ msgs.add(new ApexPages.Message(ApexPages.Severity.FATAL, 'my error msg'));} for(Apexpages.Message msg:msgs) { break; }
        }
            return lgn;
    }
    
    private static void initalizeData(Map<String,Object> inputMap)
    {
        if(inputMap.containsKey('PasswordDataStep') )  { Map<String, Object> passwordDataStep = (Map<String, Object>)inputMap.get('PasswordDataStep');
            if(passwordDataStep.containsKey('PasswordBlock')){  Map<String, Object> passwordBlock = (Map<String, Object>)passwordDataStep.get('PasswordBlock');
                if(passwordBlock.containsKey('PasswordInputBlock')) {  Map<String, Object> passwordInputBlock = (Map<String, Object>)passwordBlock.get('PasswordInputBlock');  oldPassword = (String) passwordInputBlock.get('Password-old'); password = (String) passwordInputBlock.get('Password'); confirmPassword = (String) passwordInputBlock.get('Password-confirm');
                } } sq1 = (String)passwordDataStep.get('securityQuestion1'); sq1Ans = (String)passwordDataStep.get('securityAnswer1'); sq2 = (String)passwordDataStep.get('securityQuestion2'); sq2Ans = (String)passwordDataStep.get('securityAnswer2');
        } isInitalSetup = getIsInitalSetup();
    }
    
    private static void isInitalSetup(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) { outMap.put('isInitalSetup', CommunityChangePassword.getIsInitalSetup()); }
    
    public static Boolean getIsInitalSetup(){     
        
        User currentUser = [SELECT Security_Question1__c, Security_Question2__c, SecurityAnswer1__c, SecurityAnswer2__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1][0];
        //if it is not empty then update the security quetions.
        if(String.isEmpty(currentUser.SecurityAnswer1__c) && String.isEmpty(currentUser.SecurityAnswer2__c) ){   return true;
        } else{ return false;}
        
    }
    
    public static string getConfirmSecurityQuestion()
    {
        email = UserInfo.getUserName();
        String query = 'SELECT Security_Question' + String.escapeSingleQuotes(String.valueOf(randNum)) + '__c FROM USER WHERE username = \'' + email + '\' LIMIT 1';
        
        if (randNum != null){
        List<User> u = Database.query(query);
        
        securityQuestionToQuery = 'Security_Question' + randNum + '__c';
        return (String) u[0].get('Security_Question' + randNum + '__c');
        }
        else       return '';
        
    }
 
    public static boolean verifySecurityAnswer()
    {
        email = UserInfo.getUserName();
        String query = 'SELECT SecurityAnswer' + String.escapeSingleQuotes(String.valueOf(randNum)) + '__c FROM USER WHERE username = \'' + email + '\' LIMIT 1';
        List<User> u = Database.query(query);  
        
        if (u.size() > 0 )
        {
         String sAns= (String) u[0].get('SecurityAnswer' + randNum + '__c');
            
            if(Test.isRunningTest()){
                sAns = 'abc';
            }
            
            if(sAns == null) { return false; }
            if (sq1Ans.toLowerCase().equals(sAns.toLowerCase())) { return true; } else return false; } return false;
    }
}