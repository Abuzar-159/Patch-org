public with sharing class UPS_Agreement {

    public Attachment Agreement                { get; set; }
    public String agreementText                { get; set; }
    public Account acct                        { get; set; }
    public String agreementId                  { get; set; }
    
    public UPS_Agreement(ApexPages.StandardController controller) {
        agreementText = '';
        Agreement = new Attachment();
        if(ApexPages.currentPage().getParameters().get('agreementId') != null) agreementId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('agreementId'),'UTF-8');
        if(agreementId != null) { if(Schema.sObjectType.Account.isAccessible()) acct = [select Id, Name, Agreement_Text__c from Account where Id =: agreementId]; }                    
    }
}