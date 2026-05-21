public with sharing class FedexRegister { 

    public String parentKey                            { get; set; }
    public String parentPassword                       { get; set; }
    public String accountNumber                        { get; set; }
    public String endPoint                             { get; set; }
    public String Key                                  { get; set; }    public String password                             { get; set; }
    public String meterNumber                          { get; set; }
    public String CountryCode                          { get; set; }
    public String ProvinceCode                         { get; set; }
    
    public String request_1                            { get; set; } 
    public String request_2                            { get; set; } 
    public String request_3                            { get; set; } 
    public String response_1                           { get; set; }
    public String response_2                           { get; set; }
    public String response_3                           { get; set; }
    
    public String resStatus1                           { get; set; }
    public String resStatus2                           { get; set; }
    public String resStatus3                           { get; set; }
    public String result1                              { get; set; } public String result2                              { get; set; }     public String result3                              { get; set; }         public String errorMsg1                            { get; set; }          public String errorMsg2                            { get; set; }         public String errorMsg3                            { get; set; }        
    
    public Credentials__c fedexUser                    { get; set; }
    public Boolean panelOne                            { get; set; }  
    public Boolean panelTwo                            { get; set; }
    public Boolean panelThree                          { get; set; }
    public String  agreement = 'False'; 
    public Boolean showNext                            { get; set; }  public List<ERP7__Credentials__c> credentials      { get; set; }
    
    public FedexRegister(){
        result1 = '';
        panelOne = true; 
        panelTwo = false;
        panelThree = false; 
        showNext = false;
        ProvinceCode = '';
        //parentKey = 'tEkXuBO9dc6aX7bG';
        //parentPassword = 'FwSr0GnMFJ4ZhN93cUfXxslVm';
        //accountNumber = '605517846'; 
        endpoint = '';
        
        fedexUser = new Credentials__c();
    }
    
    /*
      getter method definitions.
    */
    public String getProvinceCode(String provinceName) { List<Province_Codes__c> provinceList;
        if(provinceName != null && provinceName != '') {
            provinceList = [Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c =: String.escapeSingleQuotes(provinceName) Limit 1];
        } if(provinceList != null && provinceList.size() > 0) return provinceList[0].Code__c;
          else return '';
    }
    public String getCountryCode(String countryName) { List<Country_Codes__c> countryList;
        if(countryName != null && countryName != '') {
            countryList = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: String.escapeSingleQuotes(countryName) Limit 1];
        } if(countryList != null && countryList.size() > 0) return countryList[0].Code__c;
          else return ''; 
    }
    
    public PageReference Panel1() {
        panelOne = true;
        panelTwo = false;
        return null;
    }
    
    public PageReference Panel2() {
        panelOne = false;
        panelTwo = true;
        return null;
    }
    
    public PageReference CancelBtn() {
        PageReference pg = new PageReference('/home/home.jsp');
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference RedirectFedexEulaPdf() {
        PageReference pg = new PageReference('/apex/ERP7__FedexEulaPdf');
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference RegisterRequest() {
        
        if(fedexUser.Shipper_Province__c != null && fedexUser.Shipper_Province__c != '') ProvinceCode = getProvinceCode(fedexUser.Shipper_Province__c);
        CountryCode = getCountryCode(fedexUser.Shipper_Country__c);
        string[] ShipperName = fedexUser.Shipper_Name__c.split('\\s');
        string firstName = ShipperName[0];
        string lastName = ShipperName[1];
        
        String soapXML = System.Label.fedexReg1;
            soapXML += '<soapenv:Body>';
                soapXML += '<RegisterWebUserRequest>';
                    soapXML += '<WebAuthenticationDetail>';
                        soapXML += '<ParentCredential>';
                            soapXML += '<Key>' + parentKey + '</Key>';
                            soapXML += '<Password>'+ parentPassword +'</Password>';
                        soapXML += '</ParentCredential>';
                    soapXML += '</WebAuthenticationDetail>';
                    soapXML += '<ClientDetail>';
                        soapXML += '<AccountNumber>' + accountNumber + '</AccountNumber>';
                    soapXML += '</ClientDetail>';
                    soapXML += '<TransactionDetail>';
                        soapXML += '<CustomerTransactionId>FedEx - Register User</CustomerTransactionId>';
                    soapXML += '</TransactionDetail>';
                    soapXML += '<Version>';
                        soapXML += '<ServiceId>fcas</ServiceId>';
                        soapXML += '<Major>7</Major>';
                        soapXML += '<Intermediate>0</Intermediate>';
                        soapXML += '<Minor>0</Minor>';
                    soapXML += '</Version>';
                    soapXML += '<ShippingAddress>';
                        soapXML += '<StreetLines>' + fedexUser.Shipper_Street__c + '</StreetLines>';
                        soapXML += '<City>' + fedexUser.Shipper_City__c + '</City>';
                        if(ProvinceCode != null && ProvinceCode != '') soapXML += '<StateOrProvinceCode>' + ProvinceCode + '</StateOrProvinceCode>';
                        soapXML += '<PostalCode>' + fedexUser.Shipper_Postal_Code__c + '</PostalCode>';
                        soapXML += '<CountryCode>' + CountryCode + '</CountryCode>';
                    soapXML += '</ShippingAddress>';
                    soapXML += '<UserContactAndAddress>';
                        soapXML += '<Contact>';
                            soapXML += '<PersonName>';
                                soapXML += '<FirstName>' + firstName + '</FirstName>';
                                soapXML += '<LastName>' + lastName + '</LastName>';
                            soapXML += '</PersonName>';
                            soapXML += '<CompanyName>' + fedexUser.Shipper_Company_Name__c.escapeXml() + '</CompanyName>';
                            soapXML += '<PhoneNumber>' + fedexUser.Shipper_Phone_Number__c.escapeXml() + '</PhoneNumber>';
                            soapXML += '<EMailAddress>' + fedexUser.Shipper_Email__c + '</EMailAddress>';
                        soapXML += '</Contact>';
                        soapXML += '<Address>';
                            soapXML += '<StreetLines>' + fedexUser.Shipper_Street__c + '</StreetLines>';
                            soapXML += '<City>' + fedexUser.Shipper_City__c + '</City>';
                            if(ProvinceCode != null && ProvinceCode != '') soapXML += '<StateOrProvinceCode>' + ProvinceCode + '</StateOrProvinceCode>';
                            soapXML += '<PostalCode>' + fedexUser.Shipper_Postal_Code__c + '</PostalCode>';
                            soapXML += '<CountryCode>' + CountryCode + '</CountryCode>';
                        soapXML += '</Address>';
                    soapXML += '</UserContactAndAddress>';
                soapXML += '</RegisterWebUserRequest>';
            soapXML += '</soapenv:Body>';
        soapXML += '</soapenv:Envelope>';
        
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        
        req.setBody(soapXML);
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-length', '175');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '');
        //req.setHeader('Host', 'wsbeta.fedex.com');
        
        HttpResponse res = h.send(req);            
        request_1 = soapXML;
        response_1 = res.getBody();
        resStatus1 = res.getStatus();
        
        if(resStatus1 == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
            if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') {   XmlStreamReader reader2 = res.getXmlStreamReader(); key = readXMLResponse(reader2, 'Key'); XmlStreamReader reader3 = res.getXmlStreamReader();     password = readXMLResponse(reader3, 'Password');
            } else { XmlStreamReader reader4 = res.getXmlStreamReader();     String msg2 = readXMLResponse(reader4, 'Message');  result1 = msg2;
            }
        }
        
        
        if(key != null && key != '' && password != null && password != '') Subscription(key, password);
        return null;
    }
    
    public PageReference Subscription(string sKey, string sPassword) {
        String soapXML = System.Label.fedexReg1;
            soapXML += '<soapenv:Body>';
                soapXML += '<SubscriptionRequest>';
                    soapXML += '<WebAuthenticationDetail>';
                        soapXML += '<ParentCredential>';
                            soapXML += '<Key>' + parentKey + '</Key>';
                            soapXML += '<Password>'+ parentPassword +'</Password>';
                        soapXML += '</ParentCredential>';
                        soapXML += '<UserCredential>';
                            soapXML += '<Key>' + sKey + '</Key>';
                            soapXML += '<Password>' + sPassword + '</Password>';
                        soapXML += '</UserCredential>';
                    soapXML += '</WebAuthenticationDetail>';
                    soapXML += '<ClientDetail>';
                        soapXML += '<AccountNumber>' + accountNumber + '</AccountNumber>';
                    soapXML += '</ClientDetail>';
                    soapXML += '<Version>';
                        soapXML += '<ServiceId>fcas</ServiceId>';
                        soapXML += '<Major>7</Major>';
                        soapXML += '<Intermediate>0</Intermediate>';
                        soapXML += '<Minor>0</Minor>';
                    soapXML += '</Version>'; 
                    soapXML += '<CspSolutionId>216</CspSolutionId>';
                    soapXML += '<CspType>CERTIFIED_SOLUTION_PROVIDER</CspType>';
                    soapXML += '<Subscriber>';
                        soapXML += '<AccountNumber>' + accountNumber + '</AccountNumber>'; //soapXML += '<AccountNumber>605517846</AccountNumber>';
                        soapXML += '<Contact>';
                            soapXML += '<PersonName>' + fedexUser.Shipper_Name__c.escapeXml() + '</PersonName>';
                            soapXML += '<CompanyName>' + fedexUser.Shipper_Company_Name__c.escapeXml() + '</CompanyName>';
                            soapXML += '<PhoneNumber>' + fedexUser.Shipper_Phone_Number__c.escapeXml() + '</PhoneNumber>';
                            soapXML += '<EMailAddress>' + fedexUser.Shipper_Email__c.escapeXml() + '</EMailAddress>';
                        soapXML += '</Contact>';
                        soapXML += '<Address>';
                            soapXML += '<StreetLines>' + fedexUser.Shipper_Street__c + '</StreetLines>';
                            soapXML += '<City>' + fedexUser.Shipper_City__c + '</City>';
                            if(ProvinceCode != null && ProvinceCode != '') soapXML += '<StateOrProvinceCode>' + ProvinceCode + '</StateOrProvinceCode>';
                            soapXML += '<PostalCode>' + fedexUser.Shipper_Postal_Code__c + '</PostalCode>';
                            soapXML += '<CountryCode>' + CountryCode + '</CountryCode>';
                        soapXML += '</Address>';
                    soapXML += '</Subscriber>';  
                    soapXML += '<AccountShippingAddress>';
                        soapXML += '<StreetLines>' + fedexUser.Shipper_Street__c + '</StreetLines>';
                        soapXML += '<City>' + fedexUser.Shipper_City__c + '</City>';
                        if(ProvinceCode != null && ProvinceCode != '') soapXML += '<StateOrProvinceCode>' + ProvinceCode + '</StateOrProvinceCode>';
                        soapXML += '<PostalCode>' + fedexUser.Shipper_Postal_Code__c + '</PostalCode>';
                        soapXML += '<CountryCode>' + CountryCode + '</CountryCode>';
                    soapXML += '</AccountShippingAddress>';
                soapXML += '</SubscriptionRequest>';
            soapXML += '</soapenv:Body>';
        soapXML += '</soapenv:Envelope>';
        
        
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        
        req.setBody(soapXML);
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-length', '175');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '');
        //req.setHeader('Host', 'wsbeta.fedex.com');
        
        HttpResponse res = h.send(req);            
        request_2 = soapXML;
        response_2 = res.getBody();
        resStatus2 = res.getStatus();
        
        if(resStatus2 == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');  
            if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') {   XmlStreamReader reader2 = res.getXmlStreamReader();  meterNumber = readXMLResponse(reader2, 'MeterNumber');
            } else { XmlStreamReader reader3 = res.getXmlStreamReader();    String msg2 = readXMLResponse(reader3, 'Message');   result1 = msg2;
            }
        }
      
        if(sKey != null && sKey != '' && sPassword != null && sPassword != '' && meterNumber != null && meterNumber != '') Version_Capture(sKey, sPassword, meterNumber);
        return null;
    }
    
    public PageReference Version_Capture(string vKey, string vPassword, string vMeterNumber) {
        String soapXML = System.Label.fedexReg1;
            soapXML += '<soapenv:Body>';
                soapXML += '<VersionCaptureRequest>';
                    soapXML += '<WebAuthenticationDetail>';
                        soapXML += '<ParentCredential>';
                            soapXML += '<Key>' + parentKey + '</Key>';
                            soapXML += '<Password>'+ parentPassword +'</Password>';
                        soapXML += '</ParentCredential>';
                        soapXML += '<UserCredential>';
                            soapXML += '<Key>' + vKey + '</Key>';
                            soapXML += '<Password>' + vPassword + '</Password>';
                        soapXML += '</UserCredential>';
                    soapXML += '</WebAuthenticationDetail>';
                    soapXML += '<ClientDetail>';
                        soapXML += '<AccountNumber>' + accountNumber + '</AccountNumber>';
                        soapXML += '<MeterNumber>' + vMeterNumber + '</MeterNumber>';
                    soapXML += '</ClientDetail>';
                    soapXML += '<TransactionDetail>';
                        soapXML += '<CustomerTransactionId>601662400</CustomerTransactionId>';
                    soapXML += '</TransactionDetail>';
                    soapXML += '<Version>';
                        soapXML += '<ServiceId>fcas</ServiceId>';
                        soapXML += '<Major>7</Major>';
                        soapXML += '<Intermediate>0</Intermediate>';
                        soapXML += '<Minor>0</Minor>';
                    soapXML += '</Version>';
                    soapXML += '<OriginLocationId>YTOC</OriginLocationId>';
                    soapXML += '<VendorProductPlatform>AQXL5119</VendorProductPlatform>';
                soapXML += '</VersionCaptureRequest>';
            soapXML += '</soapenv:Body>';
        soapXML += '</soapenv:Envelope>';
        
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        
        req.setBody(soapXML);
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Content-length', '175');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('SOAPAction', '');
        //req.setHeader('Host', 'wsbeta.fedex.com');
        
        HttpResponse res = h.send(req);            
        request_3 = soapXML; 
        response_3 = res.getBody(); 
        resStatus3 = res.getStatus();   
        
        if(resStatus2 == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
         if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') { if(Schema.sobjectType.ERP7__Credentials__c.fields.Name.isAccessible()) {fedexUser.Name = 'Fedex ' + fedexUser.Shipper_Name__c;}else{/*no access*/}  if(Schema.sobjectType.ERP7__Credentials__c.fields.Active__c.isAccessible()) {fedexUser.Active__c = true;}else{/*no access*/} if(Schema.sobjectType.ERP7__Credentials__c.fields.Parent_Key__c.isAccessible()) {fedexUser.Parent_Key__c = parentKey;}else{/*no access*/}  if(Schema.sobjectType.ERP7__Credentials__c.fields.Parent_Password__c.isAccessible()) {fedexUser.Parent_Password__c = parentPassword;}else{/*no access*/} if(Schema.sobjectType.ERP7__Credentials__c.fields.Key__c.isAccessible()) {fedexUser.Key__c = vKey;}else{/*no access*/}  if(Schema.sobjectType.ERP7__Credentials__c.fields.UPS_Account_Number__c.isAccessible()) {fedexUser.UPS_Account_Number__c = accountNumber;}else{/*no access*/} if(Schema.sobjectType.ERP7__Credentials__c.fields.Meter_Number__c.isAccessible()) {fedexUser.Meter_Number__c = vMeterNumber; }else{/*no access*/}  if(Schema.sobjectType.ERP7__Credentials__c.fields.URL__c.isAccessible()) {fedexUser.URL__c = endpoint;}else{/*no access*/} if(Schema.sobjectType.ERP7__Credentials__c.fields.Type__c.isAccessible()) {fedexUser.Type__c = 'Shipment';}else{/*no access*/}  if(Schema.sobjectType.ERP7__Credentials__c.fields.Username_Login__c.isAccessible()) {fedexUser.Username_Login__c = 'Fedex';}else{/*no access*/}  if(Schema.sobjectType.ERP7__Credentials__c.fields.Password_Transkey__c.isAccessible()) {fedexUser.Password_Transkey__c = vPassword;}else{/*no access*/} Blob cryptoKey, userData, passwordData;cryptoKey = Crypto.generateAesKey(256); if(cryptoKey != null) { if(Schema.sObjectType.Credentials__c.fields.Encrypted_Key__c.isAccessible()) fedexUser.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);} if(fedexUser.Username_Login__c != null){ if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible())    userData = Blob.valueOf(fedexUser.Username_Login__c);} if(fedexUser.Password_Transkey__c != null){ if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible()) passwordData = Blob.valueOf(fedexUser.Password_Transkey__c);} cryptoKey = encodingUtil.convertFromHex(fedexUser.Encrypted_Key__c); if(userData != null){ if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible()) fedexUser.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData)); } if(passwordData != null){ if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible()) fedexUser.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));} DMLManager.upsertAsUser(fedexUser);  panelOne = false;  panelTwo = false;  panelThree = True; }else { XmlStreamReader reader3 = res.getXmlStreamReader();   String msg2 = readXMLResponse(reader3, 'Message');  result1 = msg2; }
        } 
           
        return null;   
    } 
    
    /* ------------------------- User Defined Function Reading XMLResponse -------------------------*/  
                  
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; // Read through the XML
        try {           
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    if (sxmltag == reader.getLocalName()) {
                        while (reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                            else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); }
                            reader.next(); } }
                } reader.next();
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return retValue;
    }
    
}