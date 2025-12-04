@IsTest
public class fedexRestAPIRegisterTest {
    @TestSetup
    static void setup() {
        // Create necessary test data
        ERP7__Credentials__c testFedexUser = new ERP7__Credentials__c(
            Name = 'Test User',
            ERP7__Shipper_Province__c = 'Test Province',
            ERP7__Shipper_Country__c = 'Test Country',
            ERP7__Shipper_Street__c = '123 Test Street\nApt 4',
            Shipper_City__c = 'Test City',
            ERP7__Shipper_Postal_Code__c = '12345',
            ERP7__Shipper_Name__c = 'Test Shipper',
            ERP7__URL__c = 'https://apis-sandbox.fedex.com'
        );
        insert testFedexUser;
    }

    @IsTest
    static void testConstructor() {
        fedexRestAPIRegister register = new fedexRestAPIRegister();
        System.assertNotEquals(null, register);
    }

    @IsTest
    static void testParentRegisterRequest() {
        fedexRestAPIRegister register = new fedexRestAPIRegister();
        register.parentKey = 'testKey';
        register.parentPassword = 'testPassword';
        register.endPoint = 'https://test.endpoint.com';

        Test.startTest();
        // Mock the HTTP response
        HttpResponse mockResponse = MockHttpResponseGenerator.generateResponse(200, '{"access_token":"test_access_token"}');
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(mockResponse));

        register.parentRegisterRequest();
        Test.stopTest();

        System.assertEquals('test_access_token', register.parentAccessToken);
        System.assert(register.panelTwo);
        System.assert(!register.panelOne);
    }

    @IsTest
    static void testValidateAddress() {
        ERP7__Credentials__c testFedexUser = [SELECT Id,Name,ERP7__URL__c,ERP7__Shipper_Name__c,ERP7__Shipper_Postal_Code__c,ERP7__Shipper_Province__c,ERP7__Shipper_Country__c,ERP7__Shipper_Street__c,Shipper_City__c FROM ERP7__Credentials__c LIMIT 1];

        fedexRestAPIRegister register = new fedexRestAPIRegister();
        register.fedexUser = testFedexUser;
        register.accountNumber = '123456';
        register.parentAccessToken = 'test_access_token';
        register.endPoint = 'https://test.endpoint.com';

        Test.startTest();
        // Mock the HTTP response
        HttpResponse mockResponse = MockHttpResponseGenerator.generateResponse(200, '{"output":{"mfaOptions":[{"accountAuthToken":"test_account_oauth_token"}]}}');
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(mockResponse));

        register.vaidateAddress();
        Test.stopTest();

        System.assertEquals('test_account_oauth_token', register.accountOauthToken);
        System.assert(register.panelThree);
    }

    @IsTest
    static void testGetPIN() {
        fedexRestAPIRegister register = new fedexRestAPIRegister();
        register.selectedOptionForPinGeneration = 'SMS';
        register.parentAccessToken = 'test_access_token';
        register.accountOauthToken = 'test_account_oauth_token';
        register.endPoint = 'https://test.endpoint.com';

        Test.startTest();
        // Mock the HTTP response
        HttpResponse mockResponse = MockHttpResponseGenerator.generateResponse(200, '{"pin":"1234"}');
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(mockResponse));

        register.getPIN();
        Test.stopTest();

        System.assert(register.pinGenerationResponse.contains('1234'));
        System.assertEquals('Pin Validation', register.selectedOption);
    }

    @IsTest
    static void testGetChildCredentials_PinValidation() {
        fedexRestAPIRegister register = new fedexRestAPIRegister();
        register.selectedOption = 'Pin Validation';
        register.pinValue = '1234';
        register.parentAccessToken = 'test_access_token';
        register.accountOauthToken = 'test_account_oauth_token';
        register.endPoint = 'https://test.endpoint.com';

        Test.startTest();
        // Mock the HTTP response
        HttpResponse mockResponse = MockHttpResponseGenerator.generateResponse(200, '{"output":{"child_Key":"test_child_key","child_secret":"test_child_secret"}}');
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(mockResponse));

        register.getChildCredentials();
        Test.stopTest();

        System.assertEquals('test_child_key', register.childAPIkey);
        System.assertEquals('test_child_secret', register.childAPISecret);
    }

    @IsTest
    static void testGetChildCredentials_InvoiceValidation() {
        fedexRestAPIRegister register = new fedexRestAPIRegister();
        register.selectedOption = 'Invoice Validation';
        register.invoiceNumber = 'INV123';
        register.invoiceCurrency = 'USD';
        register.invoiceDate = System.today();
        register.invoiceAmount = 100.0;
        register.parentAccessToken = 'test_access_token';
        register.accountOauthToken = 'test_account_oauth_token';
        register.endPoint = 'https://test.endpoint.com';

        Test.startTest();
        // Mock the HTTP response
        HttpResponse mockResponse = MockHttpResponseGenerator.generateResponse(200, '{"output":{"child_Key":"test_child_key","child_secret":"test_child_secret"}}');
        Test.setMock(HttpCalloutMock.class, new MockHttpCallout(mockResponse));

        register.getChildCredentials();
        Test.stopTest();

        System.assertEquals('test_child_key', register.childAPIkey);
        System.assertEquals('test_child_secret', register.childAPISecret);
    }

    private class MockHttpCallout implements HttpCalloutMock {
        private HttpResponse mockResponse;

        public MockHttpCallout(HttpResponse response) {
            this.mockResponse = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}