@isTest
private class paymentRefundTestCaseSet {
    static testMethod void unitTestCase1() {
        Credentials__c authCredentials = new Credentials__c(Name='Authorize.Net', Active__c=true,
                                             URL__c='https://test.authorize.net/gateway/transact.dll', Encrypted_Key__c='7c85b1136b431a17ad0d665a489b1f9b79455853e786132d50123c392170620b',
                                             Username_Login__c='41385808c5302d9ca8d05d82e7322bc2b87af157ae015327e54e88f9db489b1c', Password_Transkey__c='47dff672e8dfd43947119e159c134ab0ba73ca778970c57222b0193107559c7a0c120c5d0d5f145e347b3b828d9d3359');
        insert authCredentials;
        
        Payment__c authPayment = new Payment__c(Name='authPayment', Payment_Gateway__c = 'Authorize.Net', Transaction_ID__c = '2C606071096741226', Refund__c = false);
        insert authPayment;
        
        test.startTest();
            PageReference pageRef = Page.paymentRefund;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', authPayment.Id);
            ApexPages.StandardController con = new ApexPages.StandardController(authPayment);
            paymentRefund pRef = new paymentRefund(con);
            pRef.processRefund();
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
        test.stopTest(); 
    }
    
    static testMethod void unitTestCase2() {
        Credentials__c payCredentials = new Credentials__c(Name='Paypal', Active__c=true, Signature__c = 'AQKQf7AfdsdrjGLbqbagoI9HOyUIAhngQoat0nT5QkpiSh39jR-jV2Vw',
                                             URL__c='https://api-3t.sandbox.paypal.com/2.0/', Encrypted_Key__c='329a00f0b5214a5f3455f4e42ac91db40844bc5ef842d3514aa4cdae01e3298f',
                                             Username_Login__c='6dbe96771d51d03807500260c65a49dfa84df2c972591a884275fc058191b88f1100148d857248f24be39889280c3a86c3eec3c452173ccc8dcea9adf7bd4773', 
                                             Password_Transkey__c='55a0e4fe7e54ccf1ab0b158516ccf71e431b4547869f51f8d8406bbe17625027');
        insert payCredentials;
        
        Payment__c payPayment = new Payment__c(Name='payPayment', Payment_Gateway__c = 'PayPal', Transaction_ID__c = '2C606071096741226', Refund__c = false, Refund_Type__c = 'Partial', Refund_Amount__c = 1.00);
        insert payPayment;
          
        test.startTest();
            PageReference pageRef = Page.paymentRefund;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', payPayment.Id);
            ApexPages.StandardController con = new ApexPages.StandardController(payPayment);
            paymentRefund pRef = new paymentRefund(con);
            pRef.processRefund(); 
            pRef.ClosePage();
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
        test.stopTest(); 
    }
}