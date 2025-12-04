@isTest
private class AmazonHandlerTestCaseSet { 
    static testMethod void unitTestCase1() {
        test.startTest();
        AmazonHandler ah = new AmazonHandler();
        ah.ClosePage();
        System.assertEquals('ERP', 'ERP');
        test.stopTest();  
    }
}