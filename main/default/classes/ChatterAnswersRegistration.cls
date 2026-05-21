/**
 * This class has been generated to allow customization of Account creation for Chatter Answers Portal Users.
 * Chatter Answers requires that this class exist and implement ChatterAnswers.AccountCreator, renaming the class
 *   or removing the interface implementation is prohibited. */
public with sharing class ChatterAnswersRegistration implements ChatterAnswers.AccountCreator {
    public String createAccount(String firstname, String lastname, Id siteAdminId) {
         Account a = new Account(name = firstname + ' ' + lastname, ownerId = siteAdminId);
        if(Schema.sObjectType.Account.isCreateable() && Schema.sObjectType.Account.isUpdateable()){
            DMLManager.insertAsUser(a);
            return a.Id;
        } else{ return null; }
         
    }
}