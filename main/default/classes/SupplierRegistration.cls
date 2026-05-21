public with sharing class SupplierRegistration {

    public SupplierRegistration(RFPConsole controller) {

    }

    public Account supplierAccount                   { get; set; }
    public Contact primaryContact                    { get; set; }
    public List<contactWrapper> additionalContacts   { get; set; }
    public User supplierPortalUser                   { get; set; }
    public List<Request__c> RFP                      { get; set; }
    public Request_Supplier__c RFPS                  { get; set; }
    public Id RFPId                                  { get; set; }
    public Integer currentContactIndex               { get; set; }
                       
    public SupplierRegistration() {
        supplierAccount = new Account();
        primaryContact = new Contact();
        additionalContacts = new List<contactWrapper>();
        RFPS = new Request_Supplier__c();
        supplierPortalUser = new User(); 
        if(ApexPages.currentPage().getParameters().get('RFPId') != null)
        RFPId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('RFPId'),'UTF-8');
         if(Schema.sObjectType.Request__c.isAccessible())
        RFP = [Select Id, Name, Description__c, Organisation__c, Organisation_Business_Unit__c, Request_Date__c, Response_Due_Date__c, Channel__c, Status__c 
                      From Request__c 
                      Where Id =: RFPId Limit 1];
    }
    
    public class contactWrapper {
        public Contact wrapCon      { get; set; }
        public contactWrapper() {
            wrapCon = new Contact();
        }
    }
    
    public PageReference addContact() {
        contactWrapper cw = new contactWrapper(); 
        additionalContacts.add(cw);
        return null;
    }
    
    public PageReference removeContact() {
        contactWrapper cw2delete = additionalContacts.remove(currentContactIndex);
        return null;
    }
    
    public PageReference Register() {
        if(RFP.size() > 0) {
            supplierAccount.Active__c = 'Yes';
            if(Schema.sObjectType.Account.fields.Active__c.isUpdateable() && Schema.sObjectType.Account.fields.Active__c.isUpdateable()){ DMLManager.upsertAsUser(supplierAccount); } else{ /* no access */ }
            if(Schema.sObjectType.Contact.fields.Phone.isCreateable()&& Schema.sObjectType.Contact.fields.Phone.isUpdateable()) { primaryContact.Phone = supplierAccount.Phone; } else{ /* no acess */ }
            if(Schema.sObjectType.Contact.fields.AccountId.isCreateable()&& Schema.sObjectType.Contact.fields.AccountId.isUpdateable()){ primaryContact.AccountId = supplierAccount.Id; } else{ /* no access */ }
            if(Schema.sObjectType.Contact.isCreateable()&& Schema.sObjectType.Contact.isUpdateable())  { DMLManager.upsertAsUser(primaryContact); } else { /* no access */ }
            List<Contact> addContacts = new List<Contact>();
            for(contactWrapper cWrap : additionalContacts){
                cWrap.wrapCon.AccountId = supplierAccount.Id;
                addContacts.add(cWrap.wrapCon);
            } 
            if(addContacts.size() > 0) 
                if(Schema.sObjectType.Contact.fields.AccountId.isCreateable()&& Schema.sObjectType.Contact.fields.AccountId.isUpdateable()){  DMLManager.upsertAsUser(addContacts); } else { /* no access */ }
            RFPS.Request__c = RFP[0].Id;
            RFPS.Supplier__c = supplierAccount.Id;
            if(Schema.sObjectType.Request_Supplier__c.fields.Supplier__c.isCreateable() && Schema.sObjectType.Request_Supplier__c.fields.Supplier__c.isUpdateable() && Schema.sObjectType.Request_Supplier__c.fields.Request__c.isCreateable() && Schema.sObjectType.Request_Supplier__c.fields.Request__c.isUpdateable()){ DMLManager.upsertAsUser(RFPS);  } else {/* no access */ }
            
            PageReference Page = new PageReference('/apex/ThankYouPage');
            Page.setRedirect(true);
            return Page;
        }
        return null;
    }
    
    public PageReference Cancel() {
        PageReference Page = new PageReference('/apex/ThankYouPage');
        Page.setRedirect(true);
        return Page;
    }
}