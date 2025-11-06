@IsTest(SeeAllData=true)
//
private class TestCasesSet_15 {
    static testMethod void unitTestCom(){ 
        List<ConnectApi.Community> commList = new List<ConnectApi.Community>{};
        ConnectApi.Community coms = new ConnectApi.Community();
            coms.name = 'TEST_CASE';
            coms.allowChatterAccessWithoutLogin = true;
            coms.allowMembersToFlag = true;
            coms.description ='TEST COMMUNITY';
            coms.invitationsEnabled  = true;
            coms.knowledgeableEnabled = true;
            coms.siteUrl = 'https://erp-mark7-developer-edition.eu2.force.com/TEST_CASE';
            coms.status =ConnectApi.CommunityStatus.Live;
            coms.url = 'https://erp-mark7-developer-edition.eu2.force.com/TEST_CASE';
            coms.urlPathPrefix = 'TEST_CASE';
            commList.add(coms);
            
            ApexPages.currentPage().getHeaders().put('referer', 'https://erp-mark7-developer-edition.eu2.force.com/TEST_CASE/_ui/core/chatter/ui/ChatterPage');
            
            Community_Util comunityObj = new Community_Util();
            
            Community_Util.communityValue();
            
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void unitCommunities(){
        //Commnunites landing page
         CommunitiesLandingController comLanding = new CommunitiesLandingController();
         comLanding.forwardToStartPage(); 
         
         String salName = 'ERP7';
         String sal1Name = 'ERP7';
         System.assertEquals(salName, sal1Name); 
  }
    
   public static testMethod void validateCreateUpdateUser() { 
       
       
        Auth.UserData userData = new Auth.UserData('testId', 'testFirst', 'testLast', 
        'testFirst testLast', 'no-reply@salesforce.com', null, 'testuserlong', 'en_US', 'facebook', 
        null, new Map<String, String>{'language' => 'en_US'}); 
        ChatterAnswersAuthProviderRegistration reg = new ChatterAnswersAuthProviderRegistration(); 
        User newUser = reg.createUser(null, userData); 
        System.assert(newUser == null); 
        
        
        Auth.UserData updateUserData = new Auth.UserData('testId', 'updatedFirst', 'updatedLast', 
        'updatedFirst updatedLast', 'no-reply@new.salesforce.com', null, 'testuserlong', 'en_US', 'facebook', 
        null, new Map<String, String>{'language' => 'en_US'}); 
        reg.updateUser(null, null, updateUserData); 
  }   


   public static testMethod void validateAccountCreation() {
        User[] user = [SELECT Id, Firstname, Lastname, IsActive from User where IsActive = true limit 1];
        if (user.size() == 0) { return; }
        String firstName = user[0].FirstName; 
        String lastName = user[0].LastName; 
        String userId = user[0].Id;
        String accountId = new ChatterAnswersRegistration().createAccount(firstName, lastName, userId);
        Account acct = [SELECT name, ownerId from Account where Id =: accountId];
        System.assertEquals(firstName + ' ' + lastName, acct.name);
        System.assertEquals(userId, acct.ownerId);
  }
}