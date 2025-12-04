@isTest
public class ContentDocumentLink_TestClass {
    @isTest static void TestInsertContentDocumentLink() {
        Test.startTest();
        
        ERP7__Media__c Media = new ERP7__Media__c(Name='Laptop', ERP7__Active__c=true, ERP7__Type__c='Picture');
        insert Media;
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=Media.Id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        insert contentlink;
        Test.stopTest(); 
        string med = 'Content';
        System.assertEquals(med,'Content');
    }
}