public with sharing class UPS_Setup { 
    
    public String key                                  { get; set; }        
    public Account acct                                { get; set; }    
    public String Result                               { get; set; }
    public String UserId                               { get; set; }           
    public String request                              { get; set; }
    public String response                             { get; set; }    
    public String endpoint                             { get; set; }
    public String password                             { get; set; }
    public String errorMsg                             { get; set; }    
    public Boolean accMsg                              { get; set; }                   
    public String errorMsg1                            { get; set; }
    public Boolean backBtn                             { get; set; }      
    public String resStatus                            { get; set; }     
    public String accountId                            { get; set; } 
    public String resultHeader                         { get; set; } 
    public String License_Text                         { get; set; }
    public Boolean LicenseShow                         { get; set; }
    public String addAccErrMsg                         { get; set; }       
    public String DeveloperKey                         { get; set; }        
    public Boolean LicenseBtn                          { get; set; }    
    public Boolean registerBtn                         { get; set; }    
    public Boolean agreementBtn                        { get; set; }
    public String User_IPaddress                       { get; set; }       
    public Boolean LicenseAgreed                       { get; set; }     
    public Boolean addAccountBtn                       { get; set; }
    public Boolean invoiceSection                      { get; set; }  
    public Boolean IsInvoiceExist                      { get; set; }
    public String regCountryCode                       { get; set; }     
    public String regProvinceCode                      { get; set; }
    public Attachment upsAgreement                     { get; set; }
    public String SoftwareProvider                     { get; set; }  
    public String credentialFields                     { get; set; }
    public String SoftwareInstaller                    { get; set; }
    public Credentials__c upsSetup                     { get; set; }
    public Boolean registerSection                     { get; set; }   
    public Boolean updateInvoiceBtn                    { get; set; }          
    public String SoftwareProductName                  { get; set; }
    public String SoftwareVersionNumber                { get; set; }                            
    public Boolean accountDetailSection                { get; set; }        
    public List<ERP7__Credentials__c> credentials      { get; set; }                 

    /*
      Constructor
    */
    public UPS_Setup() {        
        //try{
            // Initialization
            List<Credentials__c> credentials = [select Id, Name, Active__c, Key__c, Shipper_Name__c, Shipper_Company_Name__c, Shipper_Email__c, Shipper_Phone_Number__c, Shipper_Street__c, Shipper_City__c,  Shipper_Postal_Code__c, Shipper_Province__c, 
                                               Shipper_Country__c, URL__c, Encrypted_Key__c, Password_Transkey__c, Username_Login__c, UPS_Account_Number__c, Signature__c From Credentials__c where Name =: 'UPS Setup' And Active__c = true  Limit 1]; 
            if (credentials.size() > 0) {
                Blob cryptoKey, userData, passwordData;
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Encrypted_Key__c.isAccessible()) cryptoKey = encodingUtil.convertFromHex(credentials[0].Encrypted_Key__c);
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials[0].Username_Login__c));
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials[0].Password_Transkey__c));
                if(userData != null) if(Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) credentials[0].Username_Login__c = userData.toString();
                if(passwordData != null) if(Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) credentials[0].Password_Transkey__c = passwordData.toString();
        
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) userID = credentials[0].Username_Login__c;
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) password = credentials[0].Password_Transkey__c; 
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Key__c.isAccessible()) key = credentials[0].Key__c; 
                if(Schema.sObjectType.ERP7__Credentials__c.fields.URL__c.isAccessible()) endPoint = credentials[0].URL__c;      
                if(Schema.sObjectType.ERP7__Credentials__c.fields.URL__c.isAccessible()) DeveloperKey = credentials[0].Signature__c;
            }            
            SoftwareVersionNumber = '7';
            SoftwareProvider = 'Aqxolt LTD';        
            SoftwareProductName = 'ERP Mark 7';
            SoftwareInstaller = 'Salesforce.com';
            addAccErrMsg = 'An account number is already added to this profile. To add new account number, clone the shipping credential record and register';
                        
            User_IPaddress = (ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP') == null)? ApexPages.currentPage().getHeaders().get('True-Client-IP') : ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');               
            if(Apexpages.currentpage().getparameters().get('id') != null) accountId = EncodingUtil.urlEncode(apexpages.currentpage().getparameters().get('id'),'UTF-8');     
            
            if(accountId != null) if(Schema.sObjectType.Account.isAccessible()) acct = [select Id, Name, Agreement_Text__c from Account where Id =: accountId];
            
            credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            UtilClass.FlSCheck(credentialFields.split(',') ,'ERP7__Credentials__c');
            
            if(Schema.sObjectType.Credentials__c.isAccessible()){
                upsSetup = new Credentials__c();
                if(accountId != Null && accountId != ''){
                    System.debug('accountId : '+accountId);
                    list<Credentials__c> upsSetups = (Database.query('select ' + String.escapeSingleQuotes(credentialFields) + ' from Credentials__c where Name = \'SS UPS\' And Account_Id__c =\'' + String.escapeSingleQuotes(accountId) + '\' Limit 1'));   
                    if(upsSetups.size()>0) upsSetup = upsSetups[0];
                }
            }
        system.debug('upsSetup : '+upsSetup);
            if(Schema.sobjectType.Credentials__c.fields.Stage__c.isAccessible()) {
                if(upsSetup.Stage__c == 'New' || upsSetup.Stage__c == null) { agreementBtn = true; } 
                else if(upsSetup.Stage__c == 'Accepted') { registerSection = true; registerBtn = true; backBtn = true; }
                else if(upsSetup.Stage__c == 'Registered') { registerSection = true; LicenseBtn = true; addAccountBtn = true; }
                else if(upsSetup.Stage__c == 'Processed' && upsSetup.UPS_Account_Number__c == null) { registerSection = true; addAccountBtn = true; }
                else if(upsSetup.Stage__c == 'Processed' && upsSetup.Invoice_Number__c == null && upsSetup.Invoice_Date__c == null && upsSetup.Invoice_Currency_Code__c == null && upsSetup.Invoice_Amount__c == null && upsSetup.Invoice_Control_Id__c == null) {
                    accMsg = true; registerSection = true; accountDetailSection = true; updateInvoiceBtn = true;                        
                } else { registerSection = true; accountDetailSection = true; invoiceSection = true; accMsg = true; }
            } LicenseShow = false;
        //} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    }
     
    /*
      method for random string generation
    */    
    public static String generateRandomString(Integer len) {
        String randStrFinal;
        try{
            final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            String randStr = '';
            while(randStr.length() < len) { Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62); randStr += chars.substring(idx, idx+1); }
            randStrFinal = randStr.left(1).isNumeric()? 'A'+randStr : randStr;        
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return randStrFinal; 
    }
    
    /*
      method for access license agreement request 
    */
    public PageReference AccessLicenseAgreement() {                   
        try{ 
            List<Country_Codes__c> countryCodes;
            if(Schema.sObjectType.Country_Codes__c.isAccessible()) countryCodes = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: upsSetup.Shipper_Country__c Limit 1];            
            for(Country_Codes__c c :countryCodes) { if(c.Country__c == upsSetup.Shipper_Country__c) { if(Schema.sObjectType.Country_Codes__c.fields.Code__c.isAccessible()) regCountryCode = c.Code__c; } }                               
            
            if(regCountryCode == null || regCountryCode == '') { errorMsg1 = 'Country Code Is Unavailable';
            } else { 
                String soapXML1 ='<?xml version="1.0" encoding="UTF‐8"?>';
                soapXML1 += '<AccessLicenseAgreementRequest>';
            
                soapXML1 += '<Request>';
                soapXML1 += '<TransactionReference>';
                soapXML1 += '<CustomerContext>License Test</CustomerContext>';
                soapXML1 += '<XpciVersion>1.0</XpciVersion>';
                soapXML1 += '</TransactionReference>';
                soapXML1 += '<RequestAction>AccessLicense</RequestAction>';
                soapXML1 += '</Request>';
            system.debug('DeveloperKey : '+DeveloperKey);
                
                 DeveloperKey = 'BCDDD0AF74867BE5';
                soapXML1 += '<DeveloperLicenseNumber>'+ DeveloperKey.escapeXml() +'</DeveloperLicenseNumber>';
            system.debug('regCountryCode : '+regCountryCode);
                soapXML1 += '<AccessLicenseProfile>';
                soapXML1 += '<CountryCode>'+ regCountryCode.escapeXml() +'</CountryCode>';
                soapXML1 += '<LanguageCode>EN</LanguageCode>';
                soapXML1 += '</AccessLicenseProfile>';
            
                soapXML1 += '<OnLineTool>';
                soapXML1 += '<ToolID>RateXML</ToolID>';
                soapXML1 += '<ToolVersion>1.0</ToolVersion>';
                soapXML1 += '</OnLineTool>';
                
                soapXML1 += '</AccessLicenseAgreementRequest>';         
            
                HttpRequest req1 = new HttpRequest();
                Http h1 = new Http();
            
                req1.setBody(soapXML1);
                req1.setMethod('POST');
                String myEndPoint = Endpoint + '/ups.app/xml/License';
                system.debug('myEndPoint : '+myEndPoint);
                req1.setEndpoint(myEndPoint);             
                HttpResponse res1 = h1.send(req1);
                
                request = req1.getBody();
                response = res1.getBody();
                resStatus = res1.getStatus();
            	system.debug('resStatus : '+res1.getStatus());
                system.debug('response.statusCode : '+res1.getStatusCode());
                if(resStatus == 'OK' || res1.getStatusCode() == 200) {
                    XmlStreamReader reader = res1.getXmlStreamReader();
                    String Response_Msg = readXMLResponse(reader,'ResponseStatusDescription');
                    if(Response_Msg != null && Response_Msg == 'Success') {
                        XmlStreamReader reader1 = res1.getXmlStreamReader();
                        License_Text = readXMLResponse(reader1,'AccessLicenseText');                        
                        if(License_Text != Null && accountId != null) {
                            Account ac1 = new Account(Id = accountId);
                            if(Schema.sObjectType.Account.fields.Agreement_Text__c.isCreateable() && Schema.sObjectType.Account.fields.Agreement_Text__c.isUpdateable()) ac1.Agreement_Text__c = License_Text;
                            if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()) DMLManager.upsertAsUser(ac1); else{ }
                        }                                                 
                        Result = 'Successfully Generated The UPS Agreement, scroll down to accept or decline';
                        LicenseShow = true; LicenseAgreed = false;
                    } else {
                         XmlStreamReader reader3 = res1.getXmlStreamReader();
                         String msg1 = readXMLResponse(reader3, 'ErrorDescription');
                         Result = 'Unable To Generated The UPS Agreement : ' + msg1;
                    }                        
                } else { Result = 'Result not available'; }   
            }
       } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
       return null;
    }
    
    /*
      method on accepting license agreement action
    */    
    public PageReference acceptLicense() {
        try{
            if(Schema.sObjectType.Credentials__c.fields.Stage__c.isCreateable() && Schema.sObjectType.Credentials__c.fields.Stage__c.isUpdateable()) upsSetup.Stage__c = 'Accepted';
           	system.debug('upsSetup.Stage__c : '+upsSetup.Stage__c);
            system.debug('upsSetup : '+upsSetup);
            system.debug('upsSetup AccId: '+upsSetup.ERP7__Account_Id__c);
            system.debug('upsSetup Name: '+upsSetup.Name);
            system.debug('upsSetup Id :'+upsSetup.Id);
            if(Schema.sObjectType.Credentials__c.isCreateable() && Schema.sObjectType.Credentials__c.isUpdateable()) upsert upsSetup;//DMLManager.upsertAsUser(upsSetup); else{ }
            LicenseAgreed = true; LicenseShow = false; registerSection = true; registerBtn = true; backBtn = true; 
            agreementBtn = false; licenseBtn = false; result = 'Agreement accepted you can now request for Registration';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }        
        return null;
    } 
    /*
      method on decline license agreement action
    */
    public PageReference declineLicense() {
        try{
            result = '';agreementBtn = true; LicenseShow = false; registerBtn = false; backBtn = false; licenseBtn = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    
    /*
      method for registration request
    */
    public PageReference Register() {
        try{
            if(upsSetup.Invoice_Details__c == true) { accountDetailSection = true; invoiceSection = true;                  
                if(upsSetup.UPS_Account_Number__c == null || upsSetup.Invoice_Number__c == null || upsSetup.Invoice_Date__c == null || upsSetup.Invoice_Currency_Code__c == null || upsSetup.Invoice_Amount__c == null || upsSetup.Invoice_Control_Id__c == null) {
                    errorMsg = '';
                    errorMsg1 = 'The account has not been added to the profile, all the fields in above section are required to complete this process';                    
                } else { RegisterReply(); }                                              
            } else {      
                if(Schema.sobjectType.ERP7__Credentials__c.fields.ERP7__UPS_Account_Number__c.isAccessible()) upsSetup.UPS_Account_Number__c = null;
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Number__c.isAccessible()) upsSetup.Invoice_Number__c = null;
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Date__c.isAccessible()) upsSetup.Invoice_Date__c = null;
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Currency_Code__c.isAccessible()) upsSetup.Invoice_Currency_Code__c = null;
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Amount__c.isAccessible()) upsSetup.Invoice_Amount__c = null;
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Control_Id__c.isAccessible()) upsSetup.Invoice_Control_Id__c = null;
                accountDetailSection = false;  invoiceSection = false;  RegisterReply();                                             
            }     
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for registration request
    */
    public PageReference RegisterReply() {
        try{                 
            if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isCreateable() && Schema.sObjectType.Credentials__c.fields.Username_Login__c.isUpdateable()) upsSetup.Username_Login__c = generateRandomString(10);
            if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isCreateable() && Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isUpdateable()) upsSetup.Password_Transkey__c = generateRandomString(10);
            /*if(upsSetup.size() > 0){
                Blob cryptoKey, userData, passwordData;
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Encrypted_Key__c.isAccessible()) cryptoKey = encodingUtil.convertFromHex(upsSetup.Encrypted_Key__c);
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsSetup.Username_Login__c));
                if(Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsSetup.Password_Transkey__c));
                if(userData != null) if(Schema.sObjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) upsSetup.Username_Login__c = userData.toString();
                if(passwordData != null) if(Schema.sObjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) upsSetup.Password_Transkey__c = passwordData.toString();
            }*/
            
            
            if(Schema.sObjectType.Credentials__c.fields.End_User_IP_Address__c.isCreateable() && Schema.sObjectType.Credentials__c.fields.End_User_IP_Address__c.isUpdateable()) upsSetup.End_User_IP_Address__c = User_IPaddress;
             
            if(Schema.sobjectType.ERP7__Credentials__c.fields.Company_URL__c.isAccessible()) String comURL = upsSetup.Company_URL__c;                                              
            if(Schema.sobjectType.Account.fields.Agreement_Text__c.isAccessible()) License_Text = acct.Agreement_Text__c;     
            LicenseAgreed = true; LicenseShow = false; errorMsg1 = '';
           
            List<Province_Codes__c> recProvinceCodes;
            if(Schema.sObjectType.Province_Codes__c.isAccessible()) recProvinceCodes = [Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c = : upsSetup.Shipper_Province__c Limit 1];
            if(recProvinceCodes.Size() > 0) { if(Schema.sobjectType.Province_Codes__c.fields.Code__c.isAccessible()) regProvinceCode = recProvinceCodes[0].Code__c; }         
            List<Country_Codes__c> countryCodes;
            if(Schema.sobjectType.Country_Codes__c.isAccessible()) countryCodes = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: upsSetup.Shipper_Country__c Limit 1];            
            if(Schema.sobjectType.Country_Codes__c.fields.Country__c.isAccessible() && Schema.sobjectType.Country_Codes__c.fields.Code__c.isAccessible() && Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Country__c.isAccessible()) for(Country_Codes__c c :countryCodes) { if(c.Country__c == upsSetup.Shipper_Country__c) { regCountryCode = c.Code__c; } } 
                                    
            if(regCountryCode == null || regCountryCode == '') { errorMsg1 = 'Country Code Is Unavailable'; } 
            else if(regProvinceCode == null || regProvinceCode == '') { errorMsg1 = 'Province Code Is Unavailable'; }
            else {
                String soapXML = System.label.ups_setup1;
                soapXML += '<SOAP-ENV:Header>';                 
                soapXML += '<ns3:UPSSecurity>';
                
                soapXML += '<ns3:UsernameToken>';
                soapXML += '<ns3:Username>'+ UserId.escapeXml() +'</ns3:Username>';
                soapXML += '<ns3:Password>BlueFish5771!</ns3:Password>';//'+ password.escapeXml() +'
                soapXML += '</ns3:UsernameToken>';
                
                soapXML += '<ns3:ServiceAccessToken>';
                soapXML += '<ns3:AccessLicenseNumber>'+ key.escapeXml() +'</ns3:AccessLicenseNumber>';
                soapXML += '</ns3:ServiceAccessToken>';
                
                soapXML += '</ns3:UPSSecurity>';
                soapXML += '</SOAP-ENV:Header>';
                soapXML += '<SOAP-ENV:Body>';
                
                soapXML += '<ns2:RegisterRequest>';
                soapXML += '<ns2:Request/>';            
                
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) soapXML += '<ns2:Username>'+ upsSetup.Username_Login__c.escapeXml() +'</ns2:Username>';
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) soapXML += '<ns2:Password>'+ upsSetup.Password_Transkey__c.escapeXml() +'</ns2:Password>';                     
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Company_Name__c.isAccessible()) { if(upsSetup.Shipper_Company_Name__c != null) soapXML += '<ns2:CompanyName>'+ upsSetup.Shipper_Company_Name__c.escapeXml() +'</ns2:CompanyName>'; }
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Name__c.isAccessible()) { if(upsSetup.Shipper_Name__c != null) soapXML += '<ns2:CustomerName>'+ upsSetup.Shipper_Name__c.escapeXml() +'</ns2:CustomerName>'; }
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Title__c.isAccessible()) { if(upsSetup.Title__c != null) soapXML += '<ns2:Title>'+ upsSetup.Title__c.escapeXml() +'</ns2:Title>'; }
                
                soapXML += '<ns2:Address>';
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Street__c.isAccessible()) { if(upsSetup.Shipper_Street__c != null) soapXML += '<ns2:AddressLine>'+ upsSetup.Shipper_Street__c.escapeXml() +'</ns2:AddressLine>'; }
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_City__c.isAccessible()) { if(upsSetup.Shipper_City__c != null) soapXML += '<ns2:City>'+ upsSetup.Shipper_City__c.escapeXml() +'</ns2:City>';}
                if(regProvinceCode != null) soapXML += '<ns2:StateProvinceCode>'+ regProvinceCode.escapeXml() +'</ns2:StateProvinceCode>';            
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Postal_Code__c.isAccessible()) { if(upsSetup.Shipper_Postal_Code__c != null) soapXML += '<ns2:PostalCode>'+ upsSetup.Shipper_Postal_Code__c.escapeXml() +'</ns2:PostalCode>'; }
                if(regCountryCode != null) soapXML += '<ns2:CountryCode>'+ regCountryCode.escapeXml() +'</ns2:CountryCode>';
                soapXML += '</ns2:Address>';
             
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Phone_Number__c.isAccessible()) { if(upsSetup.Shipper_Phone_Number__c != null) soapXML += '<ns2:PhoneNumber>'+ upsSetup.Shipper_Phone_Number__c.escapeXml() +'</ns2:PhoneNumber>'; }
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Email__c.isAccessible()) { if(upsSetup.Shipper_Email__c != null) soapXML += '<ns2:EmailAddress>'+ upsSetup.Shipper_Email__c.escapeXml() +'</ns2:EmailAddress>'; }
                if(Schema.sobjectType.ERP7__Credentials__c.fields.End_User_IP_Address__c.isAccessible()) { if(upsSetup.End_User_IP_Address__c != null) soapXML += '<ns2:EndUserIPAddress>'+ upsSetup.End_User_IP_Address__c.escapeXml() +'</ns2:EndUserIPAddress>'; }
                soapXML += '<ns2:NotificationCode>01</ns2:NotificationCode>';
                  
                if(upsSetup.Invoice_Details__c == true) { DateTime dt = (upsSetup.Invoice_Date__c != Null) ? upsSetup.Invoice_Date__c : null;
                    string invoiceDate = (dt != Null) ? dt.format('yyyyMMdd') : '';  
                         
                    soapXML += '<ns2:ShipperAccount>';
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.Account_Name__c.isAccessible()) { if(upsSetup.Account_Name__c != null) soapXML += '<ns2:AccountName>'+ upsSetup.Account_Name__c.escapeXml() +'</ns2:AccountName>'; }
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.UPS_Account_Number__c.isAccessible()) { if(upsSetup.UPS_Account_Number__c != null) soapXML += '<ns2:AccountNumber>'+ upsSetup.UPS_Account_Number__c.escapeXml() +'</ns2:AccountNumber>'; }
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Postal_Code__c.isAccessible()) {  if(upsSetup.Shipper_Postal_Code__c != null) soapXML += '<ns2:PostalCode>'+ upsSetup.Shipper_Postal_Code__c.escapeXml() +'</ns2:PostalCode>'; }
                        if(regCountryCode != null) soapXML += '<ns2:CountryCode>'+ regCountryCode.escapeXml() +'</ns2:CountryCode>'; 
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.End_User_IP_Address__c.isAccessible()) soapXML += '<ns2:InvoiceInfo>';
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Number__c.isAccessible()) { 
                            if(upsSetup.Invoice_Number__c != null) soapXML += '<ns2:InvoiceNumber>'+ upsSetup.Invoice_Number__c.escapeXml() +'</ns2:InvoiceNumber>'; }
                            if(invoiceDate != null) soapXML += '<ns2:InvoiceDate>'+ invoiceDate.escapeXml() +'</ns2:InvoiceDate>';
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Currency_Code__c.isAccessible()) { if(upsSetup.Invoice_Currency_Code__c != null) soapXML += '<ns2:CurrencyCode>'+ upsSetup.Invoice_Currency_Code__c.escapeXml() +'</ns2:CurrencyCode>'; }
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Amount__c.isAccessible()) { if(upsSetup.Invoice_Amount__c != null) soapXML += '<ns2:InvoiceAmount>'+ String.valueof(upsSetup.Invoice_Amount__c).escapeXml() +'</ns2:InvoiceAmount>'; }
                        if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Control_Id__c.isAccessible()) { if(upsSetup.Invoice_Control_Id__c != null) soapXML += '<ns2:ControlID>'+ upsSetup.Invoice_Control_Id__c.escapeXml() +'</ns2:ControlID>'; }
                        soapXML += '</ns2:InvoiceInfo>';
                    soapXML += '</ns2:ShipperAccount>';
                }
                soapXML += '<ns2:SuggestUsernameIndicator>N</ns2:SuggestUsernameIndicator>';
                
                soapXML += '</ns2:RegisterRequest>';            
                soapXML += '</SOAP-ENV:Body>';
                soapXML += '</SOAP-ENV:Envelope>';
            
                HttpRequest req = new HttpRequest(); 
                Http h = new Http();
                
                req.setBody(soapXML);        
                req.setMethod('POST');
                String myEndPoint = Endpoint + '/webservices/Registration';                     
                req.setEndpoint(myEndPoint);             
                req.setHeader('Content-length', '175');
                req.setHeader('Content-Type', 'charset=utf-8');
                req.setHeader('SOAPAction', ''); 
                HttpResponse res;   
                String xml; 
                String Response_Desp = '';
                
                if(!Test.isRunningTest()) {           
                    res = h.send(req);
                    xml = res.getBody();
                    response = xml; request = soapXML; resStatus = res.getStatus(); 
                    
                }
                System.debug('resStatus:'+resStatus);
                System.debug('--request:'+request);
                System.debug('--response:'+response);
                if(resStatus == 'OK') {
                    XmlStreamReader reader = res.getXmlStreamReader();
                    String Response_Msg = readXMLResponseFirstValue(reader,'Description');
                    if(Response_Msg != null && Response_Msg == 'Success') {
                        XmlStreamReader reader1 = res.getXmlStreamReader();
                        Response_Desp = readXMLResponse(reader1,'Description');                      
                        if(Schema.sObjectType.Credentials__c.fields.stage__c.isCreateable() && Schema.sObjectType.Credentials__c.fields.stage__c.isUpdateable()) upsSetup.stage__c = 'Registered';
                        if(Schema.sObjectType.Credentials__c.fields.End_User_IP_Address__c.isCreateable() && Schema.sObjectType.Credentials__c.fields.End_User_IP_Address__c.isUpdateable())  upsSetup.End_User_IP_Address__c = User_IPaddress;
                        AccessLicenseRequest();                     
                        registerBtn = false; agreementBtn = false; backBtn = false; LicenseBtn = true; 
                        if(Schema.sObjectType.Credentials__c.isCreateable() && Schema.sObjectType.Credentials__c.isUpdateable()) DMLManager.upsertAsUser(upsSetup); else{ } 
                        Result = 'Registered Successfully';
                                                         
                        if(upsSetup.UPS_Account_Number__c == null) { addAccountBtn = true; }                                                                                                                                                                                    
                    } else {Result = 'Unable To Process Registration Request : '+ Response_Msg; }
                } else { Result = 'Result Not Available '; }
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for access license request
    */
    public PageReference AccessLicenseRequest() {
        try{            
            if(Schema.sobjectType.Account.fields.Agreement_Text__c.isAccessible()) License_Text = acct.Agreement_Text__c;            
            LicenseAgreed = true; LicenseShow = false;
            List<Province_Codes__c > recProvinceCodes;
            if(Schema.sObjectType.Province_Codes__c.isAccessible()) recProvinceCodes = [Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c = : upsSetup.Shipper_Province__c Limit 1];
            if(recProvinceCodes.Size() > 0) { if(Schema.sObjectType.Province_Codes__c.fields.Code__c.isAccessible()) regProvinceCode = recProvinceCodes[0].Code__c; }         
            List<Country_Codes__c > countryCodes;
            if(Schema.sObjectType.Country_Codes__c.isAccessible()) countryCodes = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: upsSetup.Shipper_Country__c Limit 1];            
            for(Country_Codes__c c :countryCodes) { if(c.Country__c == upsSetup.Shipper_Country__c) { if(Schema.sObjectType.Country_Codes__c.fields.Code__c.isAccessible()) regCountryCode = c.Code__c; } }                       
        
            if(regCountryCode == null || regCountryCode == '') { errorMsg1 = 'Country Code Is Unavailable'; } 
            else if(regProvinceCode == null || regProvinceCode == '') { errorMsg1 = 'Province Code Is Unavailable'; } 
            else if(!LicenseAgreed) { errorMsg1 = 'License Agreement not agreed'; } 
            else {   
                system.debug('else in access license');
                errorMsg1 = ''; 
                LicenseShow = false;
                License_Text = License_Text.replace('&','&amp;');                
                system.debug('License_Text : '+License_Text);
                String soapXML2 = '<?xml version="1.0" encoding="UTF‐8" ?>';            
                soapXML2 += '<AccessLicenseRequest>';        
                
                soapXML2 += '<Request>';
                soapXML2 += '<TransactionReference>';
                soapXML2 += '<CustomerContext>License Test</CustomerContext>';
                soapXML2 += '<XpciVersion>1.0</XpciVersion>';
                soapXML2 += '</TransactionReference>';
                soapXML2 += '<RequestAction>AccessLicense</RequestAction>';          
                soapXML2 += '</Request>';
                system.debug('soapXML2 11 : '+soapXML2);
                
                 if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Company_Name__c.isAccessible()) soapXML2 += '<CompanyName>'+ upsSetup.Shipper_Company_Name__c.escapeXml() +'</CompanyName>';
                 system.debug('upsSetup.Shipper_Company_Name__c 11 : '+upsSetup.Shipper_Company_Name__c);
                soapXML2 += '<Address>';
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Street__c.isAccessible()) soapXML2 += '<AddressLine1>'+ upsSetup.Shipper_Street__c.escapeXml() +'</AddressLine1>';
                 if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_City__c.isAccessible()) soapXML2 += '<City>'+ upsSetup.Shipper_City__c.escapeXml() +'</City>';
                soapXML2 += '<StateProvinceCode>'+ regProvinceCode.escapeXml() +'</StateProvinceCode>';
                 if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Postal_Code__c.isAccessible()) soapXML2 += '<PostalCode>'+ upsSetup.Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';
                soapXML2 += '<CountryCode>'+ regCountryCode.escapeXml() +'</CountryCode>';
                soapXML2 += '</Address>';
                 system.debug('soapXML2 12 : '+soapXML2);
                soapXML2 += '<PrimaryContact>';
                 if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Name__c.isAccessible()) soapXML2 += '<Name>'+ upsSetup.Shipper_Name__c.escapeXml() +'</Name>';
                soapXML2 += '<Title>'+ upsSetup.Title__c.escapeXml() +'</Title>';
                 if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Email__c.isAccessible()) soapXML2 += '<EMailAddress>'+ upsSetup.Shipper_Email__c.escapeXml() +'</EMailAddress>';
                 if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Phone_Number__c.isAccessible()) soapXML2 += '<PhoneNumber>'+ upsSetup.Shipper_Phone_Number__c.escapeXml() +'</PhoneNumber>';
                soapXML2 += '</PrimaryContact>';
                
                 if(Schema.sobjectType.ERP7__Credentials__c.fields.Company_URL__c.isAccessible()) soapXML2 += '<CompanyURL>'+ upsSetup.Company_URL__c.escapeXml() +'</CompanyURL>';
                DeveloperKey = 'BCDDD0AF74867BE5';
                system.debug('DeveloperKey 12 : '+DeveloperKey);
                soapXML2 += '<DeveloperLicenseNumber>'+ DeveloperKey.escapeXml() +'</DeveloperLicenseNumber>';
                system.debug('regCountryCode 12 : '+regCountryCode);
                soapXML2 += '<AccessLicenseProfile>';
                soapXML2 += '<CountryCode>'+ regCountryCode.escapeXml() +'</CountryCode>';
                soapXML2 += '<LanguageCode>EN</LanguageCode>';
                soapXML2 += '<AccessLicenseText>'+ License_Text.escapeXml() +'</AccessLicenseText>';        
                soapXML2 += '</AccessLicenseProfile>';
                
                soapXML2 += '<OnLineTool>';
                soapXML2 += '<ToolID>RateXML</ToolID>';
                soapXML2 += '<ToolVersion>1.0</ToolVersion>';
                soapXML2 += '</OnLineTool>';
                system.debug('SoftwareInstaller 12 : '+SoftwareInstaller);
                soapXML2 += '<ClientSoftwareProfile>';
                soapXML2 += '<SoftwareInstaller>'+ SoftwareInstaller.escapeXml() +'</SoftwareInstaller>';
                 system.debug('SoftwareProductName 12 : '+SoftwareProductName);
                soapXML2 += '<SoftwareProductName>'+ SoftwareProductName.escapeXml() +'</SoftwareProductName>';
                 system.debug('SoftwareProvider 12 : '+SoftwareProvider);
                soapXML2 += '<SoftwareProvider>'+ SoftwareProvider.escapeXml() +'</SoftwareProvider>';
                 system.debug('SoftwareVersionNumber 12 : '+SoftwareVersionNumber);
                soapXML2 += '<SoftwareVersionNumber>'+ SoftwareVersionNumber.escapeXml() +'</SoftwareVersionNumber>';
                soapXML2 += '</ClientSoftwareProfile>';
                
                soapXML2 += '</AccessLicenseRequest>';                         
                system.debug('soapXML2 : '+soapXML2);
                request = soapXML2;
                HttpRequest req2 = new HttpRequest();
                Http h2 = new Http();
                
                req2.setBody(soapXML2);
                req2.setMethod('POST');
                String myEndPoint = Endpoint + '/ups.app/xml/License';
                req2.setEndpoint(myEndPoint);
                HttpResponse res2 = h2.send(req2);
                
                request = req2.getBody();
                system.debug('request : '+request);
                response = res2.getBody();  
                system.debug('response : '+response);
                resStatus = res2.getStatus();           
                system.debug('resStatus : '+resStatus);
                if(resStatus == 'OK') {
                    XmlStreamReader reader = res2.getXmlStreamReader();
                    String Msg = readXMLResponse(reader,'ResponseStatusDescription');
                    if(Msg != null && Msg == 'Success') {                    
                        XmlStreamReader reader1 = res2.getXmlStreamReader();
                        String LicenseKey = readXMLResponse(reader1,'AccessLicenseNumber');
                        system.debug('LicenseKey : '+LicenseKey);
                        if(Schema.sobjectType.Credentials__c.fields.Stage__c.isCreateable() && Schema.sobjectType.Credentials__c.fields.Stage__c.isUpdateable()) upsSetup.Stage__c = 'Processed';
                        if(Schema.sobjectType.Credentials__c.fields.Key__c.isCreateable() && Schema.sobjectType.Credentials__c.fields.Key__c.isUpdateable()) upsSetup.Key__c = LicenseKey;
                        if(Schema.sObjectType.Credentials__c.isCreateable() && Schema.sObjectType.Credentials__c.isUpdateable()) DMLManager.upsertAsUser(upsSetup); else{ }
                        LicenseBtn = false;  agreementBtn = false; registerBtn = false; 
                        if(upsSetup.UPS_Account_Number__c == null) { addAccountBtn = true; }             
                        Result = 'License Key Generated Successfully';               
                    } else {
                        XmlStreamReader reader1 = res2.getXmlStreamReader();
                        String err_Msg = readXMLResponse(reader1,'ErrorDescription');
                        Result = 'Unable To Generated License Key : ' + err_Msg;
                    }
                } else { Result = 'Result Not Available '; } 
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for manage account request
    */
    public PageReference ManageAccount() { 
        try{              
            if(upsSetup.UPS_Account_Number__c == null) { errorMsg = ''; accountDetailSection = true;                 
                errorMsg1 = 'The account has not been added to the profile, all the fields in above section are required to complete this process'; 
            }  
            system.debug('upsSetup.UPS_Account_Number__c : '+upsSetup.UPS_Account_Number__c);
            if(upsSetup.UPS_Account_Number__c != null) { ManageAccountRequest(upsSetup.UPS_Account_Number__c); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for manage invoice request
    */                  
    public PageReference ManageInvoice() {               
        try{
            if(upsSetup.Invoice_Number__c == null || upsSetup.Invoice_Date__c == null || upsSetup.Invoice_Amount__c == null || upsSetup.Invoice_Currency_Code__c == null || upsSetup.Invoice_Control_Id__c == null) {
                Result = ''; errorMsg = ''; invoiceSection = true;  errorMsg1 = 'All the fields in above section are required to complete this process';  
            } else { ManageAccountRequest(upsSetup.UPS_Account_Number__c); }            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for account request reply
    */
    public PageReference ManageAccountRequest(String accNumber) {
        try{
            List<Province_Codes__c > recProvinceCodes;
            if(Schema.sObjectType.Province_Codes__c.isAccessible()) recProvinceCodes = [Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c = : upsSetup.Shipper_Province__c Limit 1];
            if(recProvinceCodes.Size() > 0) { if(Schema.sObjectType.Province_Codes__c.fields.Code__c.isAccessible()) regProvinceCode = recProvinceCodes[0].Code__c; }         
            
            List<Country_Codes__c > countryCodes;
            if(Schema.sObjectType.Country_Codes__c.isAccessible()) countryCodes = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: upsSetup.Shipper_Country__c Limit 1];            
            for(Country_Codes__c c :countryCodes) { if(c.Country__c == upsSetup.Shipper_Country__c) { if(Schema.sObjectType.Country_Codes__c.fields.Code__c.isAccessible()) regCountryCode = c.Code__c; } }                               
            
            if(regCountryCode == null || regCountryCode == '') { errorMsg1 = 'Country Code Is Unavailable'; } 
            else if(regProvinceCode == null || regProvinceCode == '') { errorMsg1 = 'Province Code Is Unavailable'; }
            else {    
                String soapXML = system.label.ups_setup2;
                soapXML += '<SOAP-ENV:Header>';                 
                soapXML += '<ns3:UPSSecurity>';
                
                soapXML += '<ns3:UsernameToken>';
                soapXML += '<ns3:Username>'+ UserId.escapeXml() +'</ns3:Username>';
                soapXML += '<ns3:Password>'+ password.escapeXml() +'</ns3:Password>';
                soapXML += '</ns3:UsernameToken>';
                
                soapXML += '<ns3:ServiceAccessToken>';
                soapXML += '<ns3:AccessLicenseNumber>'+ key.escapeXml() +'</ns3:AccessLicenseNumber>';
                soapXML += '</ns3:ServiceAccessToken>';
                
                soapXML += '</ns3:UPSSecurity>';
                soapXML += '</SOAP-ENV:Header>';
                soapXML += '<SOAP-ENV:Body>';
                
                soapXML += '<ns2:ManageAccountRequest>';
                soapXML += '<ns2:Request/>';                                    
                                         
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) soapXML += '<ns2:Username>'+ upsSetup.Username_Login__c.escapeXml() +'</ns2:Username>';
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) soapXML += '<ns2:Password>'+ upsSetup.Password_Transkey__c.escapeXml() +'</ns2:Password>'; 
                
                soapXML += '<ns2:ShipperAccount>'; 
                soapXML += '<ns2:AccountNumber>'+ accNumber.escapeXml() +'</ns2:AccountNumber>';            
                if(Schema.sobjectType.ERP7__Credentials__c.fields.Shipper_Postal_Code__c.isAccessible()) {
                    if(upsSetup.Shipper_Postal_Code__c != null) soapXML += '<ns2:PostalCode>'+ upsSetup.Shipper_Postal_Code__c.escapeXml() +'</ns2:PostalCode>'; }
                if(regCountryCode != null) soapXML += '<ns2:CountryCode>'+ regCountryCode.escapeXml() +'</ns2:CountryCode>';
                soapXML += '</ns2:ShipperAccount>';                             
                        
                if(accNumber != null && upsSetup.Invoice_Number__c != null && upsSetup.Invoice_Date__c != null && upsSetup.Invoice_Amount__c != null && upsSetup.Invoice_Currency_Code__c != null && upsSetup.Invoice_Control_Id__c != null) {            
                    DateTime dt = (upsSetup.Invoice_Date__c != Null) ? upsSetup.Invoice_Date__c : null;
                    string invoiceDate = (dt != Null) ? dt.format('yyyyMMdd') : '';  
                         
                    soapXML += '<ns2:InvoiceInfo>';
                    if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Number__c.isAccessible()) soapXML += '<ns2:InvoiceNumber>'+ upsSetup.Invoice_Number__c.escapeXml() +'</ns2:InvoiceNumber>';
                    soapXML += '<ns2:InvoiceDate>'+ invoiceDate.escapeXml() +'</ns2:InvoiceDate>';
                    if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Currency_Code__c.isAccessible()) soapXML += '<ns2:CurrencyCode>'+ upsSetup.Invoice_Currency_Code__c.escapeXml() +'</ns2:CurrencyCode>';
                    if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Amount__c.isAccessible()) soapXML += '<ns2:InvoiceAmount>'+ String.valueof(upsSetup.Invoice_Amount__c).escapeXml() +'</ns2:InvoiceAmount>';
                    if(Schema.sobjectType.ERP7__Credentials__c.fields.Invoice_Control_Id__c.isAccessible()) soapXML += '<ns2:ControlID>'+ upsSetup.Invoice_Control_Id__c.escapeXml() +'</ns2:ControlID>';
                    soapXML += '</ns2:InvoiceInfo>';               
                }                
                soapXML += '</ns2:ManageAccountRequest>';
                            
                soapXML += '</SOAP-ENV:Body>';
                soapXML += '</SOAP-ENV:Envelope>';
                                
                HttpRequest req = new HttpRequest(); 
                Http h = new Http();
                
                req.setBody(soapXML);        
                req.setMethod('POST');
                String myEndPoint = Endpoint + '/webservices/Registration';                     
                req.setEndpoint(myEndPoint);             
                req.setHeader('Content-length', '175');
                req.setHeader('Content-Type', 'charset=utf-8');
                req.setHeader('SOAPAction', '');               
                                 
                HttpResponse res = h.send(req);
                String xml = req.getBody();
                request = xml;
                response = res.getBody();
                resStatus = res.getStatus(); 
                String Response_Desp = '';
                system.debug('resStatus : '+resStatus);
                if(resStatus == 'OK') {
                    XmlStreamReader reader = res.getXmlStreamReader();
                    String Response_Msg = readXMLResponseFirstValue(reader,'Description');
                    system.debug('Response_Msg : '+Response_Msg);
                    if(Response_Msg != null && Response_Msg == 'Success') {
                        XmlStreamReader reader1 = res.getXmlStreamReader();
                        Response_Desp = readXMLResponseOnce(reader1,'Description');
                        Result = Response_Desp;                                                                                                          
                        
                        XmlStreamReader reader2 = res.getXmlStreamReader();
                        string code = readXMLResponse(reader2,'ShipperAccountStatus');                    
                        
                        if(code == '010' || code == '040') {
                        if(Schema.sObjectType.Credentials__c.isCreateable() && Schema.sObjectType.Credentials__c.isUpdateable()) DMLManager.upsertAsUser(upsSetup); else{ }
                            accMsg = true; }                       
                        if(Schema.sObjectType.Credentials__c.isAccessible()) upsSetup = (accountId != Null && accountId != '') ? Database.query('select ' + String.escapeSingleQuotes(credentialFields) + ' from Credentials__c '+ 
                                    +' where Name = \'UPS\' And Account_Id__c =\'' + String.escapeSingleQuotes(accountId) + '\'') : new Credentials__c();
                        if(upsSetup.UPS_Account_Number__c != null && upsSetup.Invoice_Number__c == null && upsSetup.Invoice_Date__c == null && upsSetup.Invoice_Amount__c == null && upsSetup.Invoice_Currency_Code__c == null && upsSetup.Invoice_Control_Id__c == null) {
                            updateInvoiceBtn = true; invoiceSection = true;                        
                            accMsg = true; errorMsg = ''; errorMsg1 = ''; addAccountBtn = false;                        
                        }                                                                                                   
                    } else { Result = 'Unable To Process Manage Account Request : '+ Response_Msg; }
                } else { Result = 'Result Not Available '; } 
            }        
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    } 
    /*
      method for back button action
    */
    public PageReference backAction() {  
        try{
            PageReference pg = new PageReference('/' + accountId);
            pg.setRedirect(true);
            return pg;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
     
    /* ------------------------- User Defined Function for reading response -------------------------*/    
    public String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        try{
        String retValue = ''; // Read through the XML
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {                    
                    if (sxmltag == reader.getLocalName()) {                    
                        while (reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                            else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); }
                            reader.next(); }
                    }
                } reader.next();
            } return retValue;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }        
    
    /* ------------------------- User Defined Function for getting First Value -------------------------*/        
    public String readXMLResponseFirstValue(XmlStreamReader reader, String sxmltag) {
        try{
        String retValue = ''; // Read through the XML
            Boolean resultAchieved = false;
            while (reader.hasNext() && resultAchieved == false) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {                    
                    if (sxmltag == reader.getLocalName()) {
                        while (reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) { break; }
                            else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); resultAchieved = true; break; }
                            reader.next(); }
                    }
                } reader.next();
            } return retValue;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }     
    
    /* ------------------------- User Defined Function for getting responce only once -------------------------*/      
    public static String readXMLResponseOnce(XmlStreamReader reader, String sxmltag) {
        try{
        String retValue = ''; // Read through the XML
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {                    
                    if (sxmltag == reader.getLocalName()) {
                        while (reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                            else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); }
                            reader.next(); }
                    }
                } reader.next();
            } return retValue;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
}