public with sharing class fedexRestAPIRegister {
    public Boolean panelOne                            { get; set; }
    public Boolean panelTwo                            { get; set; }
    public Boolean panelEula                           { get; set; }
    public Boolean panelfive                            { get; set; }
    public Boolean panelThree                          { get; set; }
    public Boolean panelFour                           { get; set; }
    public Boolean showPinGen                          { get; set; }
    public Boolean showPinValid                        { get; set; }
    public Boolean showInvValid                          { get; set; }
    public String parentKey                            { get; set; }
    public String parentPassword                       { get; set; }
    public String endPoint                             { get; set; }
    public Boolean showNext                            { get; set; } 
    public String parentAccessToken                    { get; set; } 
    public String accountOauthToken                    { get; set; } 
    public ERP7__Credentials__c fedexUser              { get; set; }
    public String accountNumber                        { get; set; }
    public String ProvinceCode                         { get; set; }
    public String CountryCode                          { get; set; }
    public String selectedOption                       { get; set; }
    public String pinValue                             { get; set; }
    public String invoiceNumber                             { get; set; }
    public String invoiceCurrency                             { get; set; }
    public Date invoiceDate                             { get; set; }
    public Decimal invoiceAmount                             { get; set; }
    public String request_1                            { get; set; } 
    public String request_2                            { get; set; } 
    public String request_3                            { get; set; } 
    public String pinGenerationRequest                 { get; set; } 
    public String pinGenerationResponse                { get; set; } 
    public String response_1                           { get; set; }
    public String response_2                           { get; set; }
    public String response_3                           { get; set; }
    public String childAPIkey                          { get; set; }
    public String childAPISecret                       { get; set; }
    public String selectedOptionForPinGeneration       { get; set; }
    public fedexRestAPIRegister(){
        pinGenerationRequest = '';
        pinGenerationResponse = '';
        selectedOptionForPinGeneration = 'SMS';
        panelfive = false;
        childAPIkey = '';
        childAPISecret = '';
        request_1 = ''; request_2 = ''; request_3 = '';
        response_1 = ''; response_2 ='';  response_3 = '';
        showPinGen = false;
        showPinValid = false;
        showInvValid = false;
        invoiceNumber = '';
        invoiceCurrency = '';
        invoiceDate = system.today();
        invoiceAmount = 0.0;
        pinValue = '';
        selectedOption = '';
        panelOne = true; 
        parentKey = '';
        parentPassword = '';
        endPoint = '';
        showNext = true;
        parentAccessToken = '';
        accountOauthToken = '';
        panelTwo= false;
        panelThree = false;
        panelFour= false;
        panelfive = false;
        accountNumber = '';
        fedexUser = new ERP7__Credentials__c();
        ProvinceCode = '';
        CountryCode = '';
        
    }
    public PageReference parentRegisterRequest(){
        if(parentKey == null && parentKey == '') ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Parent Key'));
        if(parentPassword == null && parentPassword == '') ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter Parent Password'));
        if(endPoint == null && endPoint == '') ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter endpoint'));
        HttpRequest request = new HttpRequest();
        String parentEndPoint = endPoint +'/oauth/token';
        request.setEndpoint(parentEndPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String requestBody = 'grant_type=client_credentials'
            + '&client_id=' + EncodingUtil.urlEncode(parentKey, 'UTF-8')
            + '&client_secret=' + EncodingUtil.urlEncode(parentPassword, 'UTF-8');
        request.setBody(requestBody);
        String headers = request.getHeader('Content-Type');
        // Convert the HttpRequest object to a string for debugging or logging
        String headersString = '';
        headersString += 'Content-Type: ' + request.getHeader('Content-Type') + '\n';
        String requestString = 'Endpoint: ' + request.getEndpoint() + '\n'
            + 'Method: ' + request.getMethod() + '\n'
            + 'Body: ' + request.getBody()+'\n'
            +'Header : '+headersString ;
        request_1 = requestString;
        Http http = new Http();
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            // Successful callout, extract access token from response body
            response_1 = response.getBody();
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String accessToken = (String)jsonResponse.get('access_token');
            system.debug('accessToken : '+accessToken);
            parentAccessToken = accessToken;
            panelTwo = true;
            panelOne = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Access token generated using Parent credentials. Enter below details to get child credentials')); 
        } else {
            // Handle error
            System.debug('Error occurred: ' +response.getStatusCode() + ' ' +response.getStatus());
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String error = (String)jsonResponse.get('errors[0].message');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please check credentials : '+error)); 
            // You can also check response.getBody() for more error details
            return null;
        }
        return null;
        
    }
    public PageReference vaidateAddress(){
        if(fedexUser.Shipper_Province__c != null && fedexUser.Shipper_Province__c != '') ProvinceCode = getProvinceCode(fedexUser.Shipper_Province__c);
        if(fedexUser.Shipper_Country__c != null && fedexUser.Shipper_Country__c != '')  CountryCode = getCountryCode(fedexUser.Shipper_Country__c);
        system.debug('CountryCode : '+CountryCode);
        system.debug('ProvinceCode : '+ProvinceCode);
        List<string> streetLines = new List<string>();
       /* if (fedexUser.ERP7__Shipper_Street__c.contains(',')) {
            // Split by comma if multiple address lines are separated by comma
            streetLines = fedexUser.ERP7__Shipper_Street__c.split(',');
        } else {*/
            // Split by new line character if multiple address lines are separated by new lines
            streetLines = fedexUser.ERP7__Shipper_Street__c.split('\n');
       // }
        System.debug('streetLines : '+streetLines);
        if(accountNumber == null && accountNumber == '') ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter account Number'));
        String addressEndPoint = endPoint +'/registration/v2/address/keysgeneration';
        HttpRequest request = new HttpRequest();
        request.setEndpoint(addressEndPoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' +parentAccessToken);
        Map<String, Object> requestBody = new Map<String, Object>{
            'address' => new Map<String, Object>{
                'city' => fedexUser.Shipper_City__c,
                    'countryCode' => CountryCode,
                    'postalCode' => fedexUser.ERP7__Shipper_Postal_Code__c,
                    'streetLines' => streetLines,
                    'stateOrProvinceCode' => ProvinceCode
                    },
                        'accountNumber' => new Map<String, Object>{
                            'value' => accountNumber
                                },
                                    'customerName' => fedexUser.ERP7__Shipper_Name__c
                                    };
                                        System.debug('request body : '+JSON.serialize(requestBody));
        String requestBodyJson = JSON.serialize(requestBody);
        request.setBody(requestBodyJson);
        String headersString = '';
        headersString += 'Content-Type: ' + request.getHeader('Content-Type') + '\n';
        headersString += 'Authorization: ' + request.getHeader('Authorization') + '\n';
        String requestString = 'Endpoint: ' + request.getEndpoint() + '\n'
            + 'Method: ' + request.getMethod() + '\n'
            + 'Body: ' + request.getBody()+'\n'
            +'Header : '+headersString ;
        request_2 = requestString;
        Http http = new Http();
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            String responseJson = response.getBody();
            response_2 = responseJson;
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseJson);
            List<Object> mfaOptions = (List<Object>) ((Map<String, Object>)jsonResponse.get('output')).get('mfaOptions');
            if (mfaOptions != null && !mfaOptions.isEmpty()) {
                for (Object option : mfaOptions) {
                    Map<String, Object> mfaOption = (Map<String, Object>)option;
                    String accountAuthToken = (String)mfaOption.get('accountAuthToken');
                    accountOauthToken =  accountAuthToken;
                    // Use accountAuthToken as needed
                }
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Account validated! Please proceed.')); 
                panelThree = true;
                panelOne = false;
                panelTwo = false;
                panelEula = false;
            }
        }
        else {
            // Handle error
            System.debug('Error occurred: ' + response.getStatusCode() + ' ' + response.getStatus());
            Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String error = (String)jsonResponse.get('errors[0].message');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please check credentials : '+error)); 
            return null;
            // You can also check response.getBody() for more error details
        }
        return null;        
    }
    public String getProvinceCode(String provinceName) { 
        List<Province_Codes__c> provinceList;
        if(provinceName != null && provinceName != '') {
            provinceList = [Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c =: String.escapeSingleQuotes(provinceName) Limit 1];
        } if(provinceList != null && provinceList.size() > 0) return provinceList[0].Code__c;
        else return '';
    }
    public String getCountryCode(String countryName) { 
        List<Country_Codes__c> countryList;
        if(countryName != null && countryName != '') {
            countryList = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: String.escapeSingleQuotes(countryName) Limit 1];
        } if(countryList != null && countryList.size() > 0) return countryList[0].Code__c;
        else return ''; 
    }
    
    public List<SelectOption> getOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Pin Generation', 'Pin Generation'));
        options.add(new SelectOption('Pin Validation', 'Pin Validation'));
        options.add(new SelectOption('Invoice Validation', 'Invoice Validation'));
        return options;
    }
    
    public PageReference setValue() {
        System.debug('Selected option: ' + selectedOption);
        if (selectedOption == 'Pin Generation') {
            showPinGen = true;
            showPinValid = false;
            showInvValid = false;
        } else if (selectedOption == 'Pin Validation') {
            showPinGen = false;
            showPinValid = true;
            showInvValid = false;
        } else {
            showPinGen = false;
            showPinValid = false;
            showInvValid = true;
        }
        return null;
    }
    public void selectOnClick(){
        system.debug('selectedOption::'+selectedOption);
    }
    public void onSelectPinGenerationOption(){
      system.debug('selectedOptionForPinGeneration::'+selectedOptionForPinGeneration);  
    }
    public void showNextPanel(){
        panelThree = false;
        panelOne = false;
        panelTwo = false;
        panelFour = true;
    }
    public void back2panel3(){
        panelThree = true ;
        panelOne = false;
        panelTwo = false;
        panelFour = false;
    }
    public pageReference getPIN(){
        system.debug('selectedOptionForPinGeneration : '+selectedOptionForPinGeneration);
        if(selectedOptionForPinGeneration == null && selectedOptionForPinGeneration == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please select one of the option for pin generation pin '));
        }
        else{
          String pinGenerationEndPoint = endPoint +'/registration/v2/customerkeys/pingeneration';
                HttpRequest request = new HttpRequest();
                request.setEndpoint(pinGenerationEndPoint);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + parentAccessToken);
                request.setHeader('accountAuthToken', accountOauthToken);
                Map<String, Object> requestBodyMap = new Map<String, Object>{
                    'locale' => 'en_US',
                        'option' => selectedOptionForPinGeneration
                        };
                            String requestBodyJson = JSON.serialize(requestBodyMap);
                request.setBody(requestBodyJson);
                Http http = new Http();
                String headersString = '';
                headersString += 'Content-Type: ' + request.getHeader('Content-Type') + '\n';
                headersString += 'Authorization: ' + request.getHeader('Authorization') + '\n';
                headersString += 'accountAuthToken: ' + request.getHeader('accountAuthToken');
                String requestString = 'Endpoint: ' + request.getEndpoint() + '\n'
                    + 'Method: ' + request.getMethod() + '\n'
                    + 'Body: ' + request.getBody()+'\n'
                    +'Header : '+headersString ;
                pinGenerationRequest = requestString;
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    String responseBody = response.getBody();
                    pinGenerationResponse = responseBody;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Pin is sent to your registered number. Please enter the pin and proceed'));
                    selectedOption =   'Pin Validation';                
                }
                else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error in pin generation '));
                    // Handle error
                    System.debug('Error occurred: ' + response.getStatusCode() + ' ' + response.getStatus());
                    // You can also check response.getBody() for more error details
                }
            } 
        
        return null;
    }
    public pageReference getChildCredentials(){
        if(selectedOption == 'Pin Validation'){
            if(pinValue == '' || pinValue == null) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter pin '));
            else{
                String pinValidationEndPoint = endPoint +'/registration/v2/pin/keysgeneration';
                HttpRequest request = new HttpRequest();
                request.setEndpoint(pinValidationEndPoint);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + parentAccessToken);
                request.setHeader('accountAuthToken', accountOauthToken);
                Map<String, Object> requestBodyMap = new Map<String, Object>{
                    'locale' => 'en_US',
                        'secureCodePin' => pinValue
                        };
                            String requestBodyJson = JSON.serialize(requestBodyMap);
                request.setBody(requestBodyJson);
                Http http = new Http();
                String headersString = '';
                headersString += 'Content-Type: ' + request.getHeader('Content-Type') + '\n';
                headersString += 'Authorization: ' + request.getHeader('Authorization') + '\n';
                headersString += 'accountAuthToken: ' + request.getHeader('accountAuthToken');
                String requestString = 'Endpoint: ' + request.getEndpoint() + '\n'
                    + 'Method: ' + request.getMethod() + '\n'
                    + 'Body: ' + request.getBody()+'\n'
                    +'Header : '+headersString ;
                request_3 = requestString;
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    String responseBody = response.getBody();
                    response_3 = responseBody;
                    handleResponse(responseBody);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Child Credentials generated.')); 
                    if(childAPIkey != '' && childAPIkey != null && childAPISecret != null && childAPISecret != '') {
                        panelThree = false;
                        panelOne = false;
                        panelTwo = false;
                        panelFour = false; 
                        panelfive = true;
                        createCredentials();
                    }
                }
                else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error in pin validation '));
                    // Handle error
                    System.debug('Error occurred: ' + response.getStatusCode() + ' ' + response.getStatus());
                    // You can also check response.getBody() for more error details
                }
            }
        }
        else if(selectedOption == 'Invoice Validation'){
            invoiceAmount = 658.12;
            system.debug('invoiceDate : '+invoiceDate);
            if(invoiceNumber == '' || invoiceNumber == null) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter invoice Number'));
            if(invoiceCurrency == '' || invoiceCurrency == null) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter invoice currency '));
            if(invoiceDate == null) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter invoice date '));
            if(invoiceAmount <= 0.0 || invoiceAmount == null) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Please enter invoice amount '));            
            else{
                String InvoiceValidationEndPoint = endPoint +'/registration/v2/invoice/keysgeneration';
                HttpRequest request = new HttpRequest();
                request.setEndpoint(InvoiceValidationEndPoint);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + parentAccessToken);
                request.setHeader('accountAuthToken', accountOauthToken);
                String year = String.valueOf(invoiceDate.year());
                String month = invoiceDate.month() < 10 ? '0' + String.valueOf(invoiceDate.month()) : String.valueOf(invoiceDate.month());
                String day = invoiceDate.day() < 10 ? '0' + String.valueOf(invoiceDate.day()) : String.valueOf(invoiceDate.day());
                
                String formattedDate = year + '-' + month + '-' + day;
                system.debug(' date 2 : '+formattedDate);
                Map<String, Object> requestBodyMap = new Map<String, Object>{
                    'invoiceDetail' => new Map<String, Object>{
                        'number' => invoiceNumber,
                            'currency' => invoiceCurrency,
                            'date' =>formattedDate,// String.valueOf(invoiceDate.year()) + '-' + String.valueOf(invoiceDate.month()) + '-' + String.valueOf(invoiceDate.day()),
                            'amount' => invoiceAmount
                            },
                                'locale' => 'en_US'
                                };
                                    String requestBodyJson = JSON.serialize(requestBodyMap);
                request.setBody(requestBodyJson);
                Http http = new Http();
                String headersString = '';
                headersString += 'Content-Type: ' + request.getHeader('Content-Type') + '\n';
                headersString += 'Authorization: ' + request.getHeader('Authorization') + '\n';
                headersString += 'accountAuthToken: ' + request.getHeader('accountAuthToken');
                String requestString = 'Endpoint: ' + request.getEndpoint() + '\n'
                    + 'Method: ' + request.getMethod() + '\n'
                    + 'Body: ' + request.getBody()+'\n'
                    +'Header : '+headersString ;
                
                request_3 = requestString;
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    String responseBody = response.getBody();
                    response_3 = responseBody;
                    handleResponse(responseBody);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Child Credentials generated.'));
                    if(childAPIkey != '' && childAPIkey != null && childAPISecret != null && childAPISecret != '') {
                        panelThree = false;
                        panelOne = false;
                        panelTwo = false;
                        panelFour = false; 
                        panelfive = true;
                        createCredentials();
                    }
                }
                else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Error in pin validation : '+response.getStatusCode() + ' ' + response.getStatus()+ ' '+response.getBody()));
                    // Handle error
                    System.debug('Error occurred: ' + response.getStatusCode() + ' ' + response.getStatus());
                    // You can also check response.getBody() for more error details
                }
            }
        }
        return null;
    }
    public void handleResponse(String response) {
        Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(response);
        String childKey = (String)((Map<String, Object>)jsonResponse.get('output')).get('child_Key');
        String childSecret = (String)((Map<String, Object>)jsonResponse.get('output')).get('child_secret');
        childAPIkey = childKey;
        childAPISecret = childSecret;
        System.debug('Child Key: ' + childKey);
        System.debug('Child Secret: ' + childSecret);
    }
    public  void createCredentials() {
        // Check if the object and fields are accessible
        if (Schema.sObjectType.ERP7__Credentials__c.isAccessible()) {
            ERP7__Credentials__c credentials = new ERP7__Credentials__c();
            credentials = fedexUser;
            // Populate accessible fields
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Name.isAccessible()) {
                credentials.Name = fedexUser.Shipper_Name__c +'-'+accountNumber; // You can modify this as per your requirement
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Active__c.isAccessible()) {
                credentials.Active__c = true; // Assuming you want to set it to true
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Parent_Key__c.isAccessible()) {
                credentials.Parent_Key__c = parentKey;
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Parent_Password__c.isAccessible()) {
                credentials.Parent_Password__c = parentPassword;
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Key__c.isAccessible()) {
                credentials.Key__c = childAPIkey;
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.UPS_Account_Number__c.isAccessible()) {
                credentials.UPS_Account_Number__c = accountNumber;
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Meter_Number__c.isAccessible()) {
                credentials.Meter_Number__c = '';
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.URL__c.isAccessible()) {
                credentials.URL__c = endpoint;
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Type__c.isAccessible()) {
                credentials.Type__c = 'Shipment'; // Assuming you want to set it to 'Shipment'
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) {
                credentials.Username_Login__c = 'Fedex'; // You can modify this as per your requirement
            }
            if (Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) {
                credentials.Password_Transkey__c = childAPISecret;
            }
            
            // Encrypt sensitive data
            Blob cryptoKey = Crypto.generateAesKey(256);
            if (cryptoKey != null) {
                if (Schema.sObjectType.ERP7__Credentials__c.fields.Encrypted_Key__c.isAccessible()) {
                    credentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
                }
            }
            
            Blob userData;
            if (credentials.Username_Login__c != null) {
                if (Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) {
                    userData = Blob.valueOf(credentials.Username_Login__c);
                }
            }
            
            Blob passwordData;
            if (credentials.Password_Transkey__c != null) {
                if (Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) {
                    passwordData = Blob.valueOf(credentials.Password_Transkey__c);
                }
            }
            
            cryptoKey = EncodingUtil.convertFromHex(credentials.Encrypted_Key__c);
            if (userData != null) {
                if (Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) {
                    credentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
                }
            }
            if (passwordData != null) {
                if (Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) {
                    credentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
                }
            }
            
            // Upsert the record
            DMLManager.upsertAsUser(credentials);
        } else {
            // Handle no access to object and fields
        }
    }
    public PageReference CancelBtn() {
        PageReference pg = new PageReference('/lightning/page/home');
        pg.setRedirect(true);
        return pg;
    }
     public PageReference RedirectFedexEulaPdf() {
        PageReference pg = new PageReference('/apex/ERP7__FedexEulaPdf');
        pg.setRedirect(true);
        return pg;
    }
     public PageReference Panel1() {
        panelOne = false;
        panelTwo = true;
         panelEula = false;
        return null;
    }
    public PageReference  panel2action(){
        panelOne = false;
        panelTwo = false;
        panelEula = true;
        return null;
        
    }
      @RemoteAction
    public static void updateInvoiceAmount(Decimal amount) {
        
        system.debug('amount : '+amount);
    }
    
}