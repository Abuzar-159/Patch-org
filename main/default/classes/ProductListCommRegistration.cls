global without sharing class ProductListCommRegistration {
    private static final Integer NUM_SEC_QUESTIONS = 2;
     private static final String profileName2= 'Customer Community Portal User';
    private static final String profileName3= System.Label.Supplier_Community_Portal_Profile;
    private static String salutation;
    private static String firstname;
    private static String lastname;
    private static String email;
    private static String dob;
    private static String middlename;
    private static String rAddressLookup;
    private static Boolean rAddressNotFound;
    private static String rAptSuite;
    private static String rAddressLine1;
    private static String rCity;
    private static String rPostalCode;
    private static String rProvince;
    private static String rCountry;
    private static Boolean isMailingAddressSame;
    private static String mAddressLookup;
    private static Boolean mAddressNotFound;
    private static String mAptSuite;
    private static String mAddressLine1;
    private static String mCity;
    private static String mPostalCode;
    private static String mProvince;
    private static String mCountry;
    private static String methodOfContact;
    private static String homePhone;
    private static String mobilePhone;
    private static Boolean peelNewsletter;
    private static Boolean newsNofification;
    private static String cellphone;
    private static String currentContactId;
    private static String programName;
    private static Id profileId;
    global static Id contactRTId;
    private static Id accountRTID;
    private static Id residentAddressId;
    private static Id mailingAddressId;
    private static User registeredUser;
    private static Account newCreatedAccount;
    private static Contact newCreatedContact;
    private static String currentUserId;
    private static String passInfo = '';
    private static boolean newLetterSub;
    
    @AuraEnabled
    Global static String registerUserSelf(String email, String firstName, String middleName, String lastName, String pass, Boolean newLetterSub, String UserRegProfName) { //Map < String, Object > userInfo
        String result = 'SUCCESSsss' + email;
        String tempNickName;
        try{
            system.debug('registerUserSelf called UserRegProfName~>'+UserRegProfName);
            String UserId;
            List < Profile > profList = [SELECT Id FROM Profile WHERE Name ='System Administrator'];
            if( profList.size() >0 ){
                List<User> userForRole = [Select id from User where profileId =:profList[0].Id AND isActive=true AND UserRoleId != Null ];
                if(userForRole.size() >0) UserId = userForRole[0].Id;
            } 
            /*firstname = '' + userInfo.get('firstName');
lastname = '' + userInfo.get('lastName');
email = '' + userInfo.get('email');
newLetterSub = (boolean) userInfo.get('newLetterSub');
*/
            if (doesUserExist(email)) { return 'Already Registered with this email'; }
            registeredUser = new User();
            List<Account> Organisations = new List<Account>();
            Organisations = [Select Id, Name From Account Where ERP7__Account_Type__c = 'Organisation' Limit 1];
            List<Account> Accounts = new List<Account>();
            if(String.isNotEmpty(email)) Accounts = [Select Id, Name,ERP7__Organisation__c, ERP7__Email__c, Phone, ERP7__Is_Portal_Account__c, ERP7__Subscribe_To_NewsLetters__c From Account Where ERP7__Email__c =: email Limit 1];
            newCreatedContact = new Contact();
            if(Accounts.size() > 0){
                newCreatedAccount = Accounts[0];
                newCreatedAccount.Is_Portal_Account__c = true;
                newCreatedAccount.ERP7__Subscribe_To_NewsLetters__c = newLetterSub;
                if(UserRegProfName == System.Label.Supplier_Community_Guest_User) newCreatedAccount.ERP7__Account_Type__c='Vendor'; //'ERP Supplier Portal Community Site Guest User'
                if(Organisations.size() > 0) newCreatedAccount.ERP7__Organisation__c = Organisations[0].Id;
                if( UserId != null) {newCreatedAccount.OwnerId =UserId;} 
                update newCreatedAccount;
                List<Contact> Contacts = [Select Id, FirstName, LastName, Email, AccountId, Phone From Contact Where Email =: email And AccountId =: Accounts[0].Id Limit 1];
                if(Contacts.size() > 0){ 
                    newCreatedContact = Contacts[0]; 
                    newCreatedContact.firstName = firstName; 
                    newCreatedContact.lastName = lastName;
                    update newCreatedContact;
                } else {  
                    newCreatedContact.firstName = firstName; 
                     newCreatedContact.lastName = lastName; 
                    newCreatedContact.email = email;
                    newCreatedContact.AccountId = newCreatedAccount.Id;
                    newCreatedContact.ERP7__Primary__c=true;
                     insert newCreatedContact;
                }
            }
            else {
                if(UserRegProfName == 'ERP Product catalog Community Site Guest User'){  newCreatedAccount = new Account();  newCreatedAccount.Name = firstName.capitalize() + ' ' + lastName.capitalize();  newCreatedAccount.ERP7__Email__c = email;  newCreatedAccount.ERP7__Is_Portal_Account__c = true;  newCreatedAccount.ERP7__Active__c='Yes'; newCreatedAccount.ERP7__Subscribe_To_NewsLetters__c = newLetterSub;} 
                else if(UserRegProfName == System.Label.Supplier_Community_Guest_User){  newCreatedAccount = new Account(); newCreatedAccount.Name = firstName.capitalize() + ' ' + lastName.capitalize(); newCreatedAccount.ERP7__Email__c = email; newCreatedAccount.ERP7__Is_Portal_Account__c = true; newCreatedAccount.ERP7__Active__c='Yes'; newCreatedAccount.ERP7__Account_Type__c='Vendor';  newCreatedAccount.ERP7__Subscribe_To_NewsLetters__c = newLetterSub; } 
                if(Organisations.size() > 0) newCreatedAccount.ERP7__Organisation__c = Organisations[0].Id;
                if( UserId != Null ) newCreatedAccount.OwnerId =UserId;
                insert newCreatedAccount;
                newCreatedContact.firstName = firstName; 
                newCreatedContact.lastName = lastName; 
                newCreatedContact.email = email;
                newCreatedContact.AccountId = newCreatedAccount.Id;
                newCreatedContact.ERP7__Primary__c=true;
                insert newCreatedContact;
            }
            registeredUser.Username = email;
            registeredUser.FirstName = firstName;
            registeredUser.LastName = lastName;
            registeredUser.Email = email;
            registeredUser.ProfileId = getProfileId(UserRegProfName); //
            tempNickName = ((firstname != null && firstname.length() > 0) ? firstname.substring(0, 1) : '') + lastname.substring(0, 1);
            tempNickName += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
            registeredUser.Alias = tempNickName; 
            registeredUser.CommunityNickname = tempNickName; 
            registeredUser.EmailEncodingKey = 'ISO-8859-1';
            registeredUser.IsActive = true;
            String accountId = newCreatedContact.AccountId;
            if (accountId != null) {
                system.debug('registerUserSelf accountId not null creating new user');
                currentUserId = Site.createPortalUser(registeredUser, accountId, null);
                system.debug('createduser Id~>'+currentUserId);
            }else system.debug('registerUserSelf accountId null not creating new user');
        } catch (Exception e) {
             system.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            return e.getMessage()+' '+e.getLineNumber();
        }
        if(String.isNotEmpty(currentUserId)) return 'User Created Successfully'; 
        else return 'Unsuccessfull';
    }
    
    private static boolean doesUserExist(String email) {
        List < User > users = [SELECT Id FROM User WHERE username = : email];
        if (users.size() > 0) return true;
        else return false;
    }
    
    private static Id getProfileId(String UserRegProfName) {
        String profileName;
        if(UserRegProfName == 'ERP Product catalog Community Site Guest User') profileName=profileName2;
        else if(UserRegProfName == System.Label.Supplier_Community_Guest_User)	profileName=profileName3;
        if (String.isNotEmpty(profileName)) {
            List < Profile > idList = [SELECT Id FROM Profile WHERE Name = : profileName];
            if (idList.size() > 0) {
                profileId = idList[0].id;
            }
        }
        return profileId;
    }
    
    @AuraEnabled
    public static profileWrapper getProfileId2(){
        profileWrapper pr=new profileWrapper();
        Id profileId= userinfo.getProfileId();
        String profileName1=[Select Id,Name from Profile where Id=:profileId].Id;
        //pr.profId=profileId;
        pr.profId=profileName1;
        String name = userinfo.getFirstName()+' '+userinfo.getLastName();
        pr.name=name;
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