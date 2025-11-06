public with sharing class AccountAttachmentsController {

    @AuraEnabled
    public static AccountWrapper getAccountDetailsWithFilesAndAttachments(Id accountId) {
        // Fetch Account Details
        Account account = [SELECT Id, Name, AccountNumber, ERP7__Opening_Balance__c,Phone , ERP7__Payment_Terms__c, ERP7__Paid_Amount__c , ERP7__Total_Due__c,ERP7__Debit_Note_Balance__c,ERP7__Credit_Balance__c, ERP7__Email__c    FROM Account WHERE Id = :accountId LIMIT 1];

        // Fetch Attachments
        List<Attachment> attachments = [SELECT Id, Name, ContentType FROM Attachment WHERE ParentId = :accountId order by CreatedDate desc];

        // Fetch ContentDocuments (Salesforce Files)
        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension 
                                                           FROM ContentDocumentLink 
                                                           WHERE LinkedEntityId = :accountId];

        return new AccountWrapper(account, attachments, contentDocumentLinks);
    }

    @AuraEnabled
    public static void saveAttachment(Attachment attachment) {
        insert attachment;
    }

    @AuraEnabled
    public static void deleteRecord(Id recordId, String sObjectType) {
        system.debug('recordId-->'+recordId);
        system.debug('sObjectType-->'+sObjectType);
        if (sObjectType == 'Attachment') {
            Attachment attachment = [SELECT Id FROM Attachment WHERE Id = :recordId LIMIT 1];
            delete attachment;
        } else if (sObjectType == 'ContentDocument') {
            ContentDocumentLink docLink = [SELECT Id FROM ContentDocumentLink WHERE ContentDocumentId = :recordId LIMIT 1];
            delete docLink;
        }
    }
    
    @AuraEnabled
    public static AccountPaginationWrapper getAccounts(String searchKeyword, Integer pageNumber) {
        Integer pageSize = 10;
        Integer offset = (pageNumber - 1) * pageSize;

        List<Account> accounts;
        Integer totalRecords;

        if (String.isNotBlank(searchKeyword)) {
            String searchQuery = '%' + searchKeyword + '%';
            accounts = [SELECT Id, Name, AccountNumber, ERP7__Opening_Balance__c,Phone , ERP7__Email__c, ERP7__Payment_Terms__c, ERP7__Paid_Amount__c , ERP7__Total_Due__c,ERP7__Debit_Note_Balance__c,ERP7__Credit_Balance__c   FROM Account WHERE Name LIKE :searchQuery LIMIT :pageSize OFFSET :offset];
            totalRecords = [SELECT COUNT() FROM Account WHERE Name LIKE :searchQuery];
        } else {
            accounts = [SELECT Id, Name, AccountNumber, ERP7__Opening_Balance__c,Phone , ERP7__Email__c, ERP7__Payment_Terms__c, ERP7__Paid_Amount__c , ERP7__Total_Due__c,ERP7__Debit_Note_Balance__c,ERP7__Credit_Balance__c   FROM Account LIMIT :pageSize OFFSET :offset];
            totalRecords = [SELECT COUNT() FROM Account];
        }

        Integer totalPages = (totalRecords + pageSize - 1) / pageSize;

        return new AccountPaginationWrapper(accounts, totalPages);
    }

    public class AccountWrapper {
        @AuraEnabled
        public Account account { get; set; }
        @AuraEnabled
        public List<Attachment> attachments { get; set; }
        @AuraEnabled
        public List<ContentDocumentLink> contentDocuments { get; set; }

        public AccountWrapper(Account account, List<Attachment> attachments, List<ContentDocumentLink> contentDocuments) {
            this.account = account;
            this.attachments = attachments;
            this.contentDocuments = contentDocuments;
        }
    }

    public class AccountPaginationWrapper {
        @AuraEnabled
        public List<Account> accounts { get; set; }
        @AuraEnabled
        public Integer totalPages { get; set; }

        public AccountPaginationWrapper(List<Account> accounts, Integer totalPages) {
            this.accounts = accounts;
            this.totalPages = totalPages;
        }
    }
}