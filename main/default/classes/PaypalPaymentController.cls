Public With Sharing Class PaypalPaymentController {
    public string TransId { get; set; }
    public string Status  { get; set; }
    public string AVSCode{ get; set; }
    public string CVV2{get; set; }
    public string sErrMsg{get; set;}
    public string ErrMsg{get; set; }
    public string ErrCode{get; set; }
    public string rawResponse {get; set; }
    public string CorrID {get; set;}
    public Id Id {get; set;}
    public Id pgId {get; set;}
    public String userAgent;
    public string FirstName{get; set;}
    public string LastName{get; set;}
    public string Email{get; set;}
    public string City{get; set;}
    public string State{get; set;}    
    public string Country{get; set;}
    public string Zipcode{get; set;}
    public string CardType{get; set;}
    public string Expiry_Month{get; set;}
    public string Card_Number{get; set;}
    public string Expiry_Year{get; set;}
    public string Amount{get; set;}
    public string Card_Type{get; set;} 
    public string CVV{get; set;} 
    public string myCurrency{get; set;}    
    public string Address_Line1{get; set;} 
    public string Address_Line2{get; set;} 
    public string AccId{get; set;} 
    public string ObuId{get; set;} 
    public string Orderid{get; set;} 
    public string methodId{get; set;}
    public string comAppend{get; set;}
    public List<Payment__c> paymt = new List<Payment__c>();    
    public Payment__c payment{get; set;}
    public String ipstring{get; set;}
    public String request_1{get; set;}
    public String response_1{get; set;}
    
    public PaypalPaymentController(Id pId, Id mypgId) {
        comAppend = Community_Util.communityValue();
        if(comAppend == null || comAppend == '') { comAppend = '/apex'; } 
        else { comAppend = '/' + comAppend + '/apex'; }
        
        TransId = '';
        userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        
        pgId = mypgId;            
        if(pId != null) {  
            Id = pId;   
            if(Schema.sObjectType.Payment__c.isAccessible()) {                           
                paymt = [Select Id, Name, Address_Line1__c, Address_Line2__c, Amount__c, AVS_Code__c, CardType__c, 
                           City__c, Correlation_ID__c, Country__c, CVV2_Code__c, Email_Address__c, Error_Message__c,
                           Error_Code__c, First_Name__c, Last_Name__c, Payment_Status__c, sError__c, State__c,
                           Transaction_ID__c, Transaction_Status__c, Zipcode__c, Payment_Gateway__c, Account__c, Sales_Order__c, 
                           Organisation_Business_Unit__c, Payment_Method__c, Bank__c, Reference_Cheque_No__c, RecordTypeId
                           From Payment__c Where id = :Id limit 1];
            }           
            payment = paymt.get(0);
        } else { payment = new Payment__c(); }            
    }
    
    public PaypalPaymentController(Id pId, Id mypgId, Boolean isLightning) {
        TransId = '';
        pgId = mypgId;            
        if(pId != null) {  
            Id = pId;   
            if(Schema.sObjectType.Payment__c.isAccessible()) {                           
                paymt = [Select Id, Name, Address_Line1__c, Address_Line2__c, Amount__c, AVS_Code__c, CardType__c, 
                           City__c, Correlation_ID__c, Country__c, CVV2_Code__c, Email_Address__c, Error_Message__c,
                           Error_Code__c, First_Name__c, Last_Name__c, Payment_Status__c, sError__c, State__c,
                           Transaction_ID__c, Transaction_Status__c, Zipcode__c, Payment_Gateway__c, Account__c, Sales_Order__c, 
                           Organisation_Business_Unit__c, Payment_Method__c, Bank__c, Reference_Cheque_No__c, RecordTypeId
                           From Payment__c Where id = :Id limit 1];
            }           
            payment = paymt.get(0);
        } else { payment = new Payment__c(); }            
    }
    
    public PaypalPaymentController() {}
    
    public PageReference pay() {  
        // Get Setup parameters
        String selectedGatewayId = pgId;
        Credentials__c paypalSetup;
        if(Schema.sObjectType.Credentials__c.isAccessible()) {
            paypalSetup = [Select Id, Name, Password_Transkey__c, Signature__c , URL__c, Encrypted_Key__c, Username_Login__c From Credentials__c 
            Where Id =: selectedGatewayId Limit 1];
        }
        if(AccId != Null) { if(Schema.sObjectType.Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Account__c.isUpdateable()) { payment.Account__c = AccId; } }
        if(ObuId != Null) { if(Schema.sObjectType.Payment__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Organisation_Business_Unit__c.isUpdateable()) { payment.Organisation_Business_Unit__c = ObuId; } }
        if(OrderId != Null) { if(payment.Sales_Order__c == Null) payment.Sales_Order__c = OrderId; }
        if(FirstName != Null) { if(Schema.sObjectType.Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.Payment__c.fields.First_Name__c.isUpdateable()) { payment.First_Name__c = FirstName; } }
        if(LastName != Null) { if(Schema.sObjectType.Payment__c.fields.Last_Name__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Last_Name__c.isUpdateable()) { payment.Last_Name__c  = LastName; } }
        if(Email != Null) { if(Schema.sObjectType.Payment__c.fields.Email_Address__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Email_Address__c.isUpdateable()) { payment.Email_Address__c = Email; } }
        if(Address_Line1 != Null) { if(Schema.sObjectType.Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Address_Line1__c.isUpdateable()) { payment.Address_Line1__c = Address_Line1; } }
        if(Address_Line2 != Null) { if(Schema.sObjectType.Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Address_Line2__c.isUpdateable()) { payment.Address_Line2__c = Address_Line2; } }        
        if(City != Null) { if(Schema.sObjectType.Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.Payment__c.fields.City__c.isUpdateable()) { payment.City__c = City; } }
        if(State != Null) { if(Schema.sObjectType.Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.Payment__c.fields.State__c.isUpdateable()) { payment.State__c = State; } }
        if(Country != Null) { if(Schema.sObjectType.Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Country__c.isUpdateable()) { payment.Country__c = Country; } }
        if(Zipcode != Null) { if(Schema.sObjectType.Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Zipcode__c.isUpdateable()) { payment.Zipcode__c  = Zipcode; } }    
          
        if(Amount != Null) { if(Schema.sObjectType.Payment__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Amount__c.isUpdateable()) { payment.Amount__c = Decimal.valueof(Amount); } }
        if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
        if(methodId != Null) { if(Schema.sObjectType.Payment_Method__c.isCreateable() && Schema.sObjectType.Payment_Method__c.isUpdateable())  { payment.Payment_Method__c = methodId; } }
        // Instantiate a new https object
        Http h = new Http();
            
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        
        // The webservice url -  Pass in the endpoint to be used using the string url
        String url = String.valueof(paypalSetup.URL__c);
        String soapXML;
        Blob cryptoKey, userData, passwordData;
        cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
        userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
        passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
        if(userData != null) paypalSetup.Username_Login__c = userData.toString();
        if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                
        soapXML =  System.label.paypal1;
        soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
        soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
        soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
        soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
        soapXML += '<Subject/>';
        soapXML += '</Credentials></RequesterCredentials></SOAP-ENV:Header><SOAP-ENV:Body><DoDirectPaymentReq xmlns="urn:ebay:api:PayPalAPI">';
        soapXML += '<DoDirectPaymentRequest><Version xmlns=urn:ebay:apis:eBLBaseComponents">84.00</Version>';
        soapXML += '<DoDirectPaymentRequestDetails xmlns="urn:ebay:apis:eBLBaseComponents">';
        soapXML += '<PaymentAction>Sale</PaymentAction><PaymentDetails><OrderTotal currencyID=' + myCurrency.escapeXml()+ '>' + Amount.escapeXml() + '</OrderTotal></PaymentDetails>';
        soapXML += '<IPAddress>' + ipstring.escapeXml() + '</IPAddress><CreditCard><CreditCardType>' + Card_Type.escapeXml() + '</CreditCardType><CreditCardNumber>' + Card_Number.escapeXml() + '</CreditCardNumber>';
        soapXML += '<ExpMonth>' + Expiry_Month.escapeXml() + '</ExpMonth><ExpYear>' + Expiry_Year.escapeXml() + '</ExpYear><CVV2>' + CVV.escapeXml() + '</CVV2>';
        soapXML += '<CardOwner><Payer>' + Email.escapeXml() + '</Payer><PayerStatus></PayerStatus><PayerName><FirstName>' + FirstName.escapeXml() + '</FirstName><LastName>' + LastName.escapeXml() + '</LastName></PayerName>';
        soapXML += '<Address><Street1>' + Address_Line1.escapeXml() + '</Street1><Street2>' + Address_Line2.escapeXml() + '</Street2><CityName>' + City.escapeXml() + '</CityName>';
        soapXML += '<StateOrProvince>' + State.escapeXml() + '</StateOrProvince><Country>' + Country.escapeXml() + '</Country><PostalCode>' + Zipcode.escapeXml() + '</PostalCode><Phone></Phone></Address></CardOwner></CreditCard>';
        soapXML += '</DoDirectPaymentRequestDetails></DoDirectPaymentRequest></DoDirectPaymentReq></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        req.setBody(soapXML);        req.setEndpoint(url);        req.setMethod('POST');        req.setHeader('Content-length', '1753' );        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');         req.setHeader('SOAPAction','');        req.setHeader('Host','api-3t.sandbox.paypal.com');        req.setTimeout(20000);        HttpResponse res = h.send(req);        String xml = res.getBody();        XmlStreamReader reader = res.getXmlStreamReader();        Status = readXMLResponse(reader,'Ack');        reader = res.getXmlStreamReader();        CorrID = readXMLResponse(reader, 'CorrelationID');         reader = res.getXmlStreamReader();        CVV2 = readXMLResponse(reader, 'CVV2Code');         reader = res.getXmlStreamReader();        AVSCode = readXMLResponse(reader, 'AVSCode');         rawResponse = xml;        reader = res.getXmlStreamReader();        ErrMsg = readXMLResponse(reader, 'LongMessage');        reader = res.getXmlStreamReader();        sErrMsg = readXMLResponse(reader, 'ShortMessage');        reader = res.getXmlStreamReader();        ErrCode= readXMLResponse(reader, 'ErrorCode');         reader = res.getXmlStreamReader();        transid = readXMLResponse(reader, 'TransactionID');              
       
        payment.AVS_Code__c = AVSCode; payment.CVV2_Code__c = CVV2; payment.Transaction_Status__c = Status; payment.Error_Code__c = ErrCode; payment.Transaction_ID__c = transid; payment.sError__c = sErrMsg; payment.Correlation_ID__c = CorrID; payment.Error_Message__c = ErrMsg;
        
        String cardRt = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
        if(String.isNotEmpty(cardRt)){ payment.RecordTypeId = cardRt; }
                
        try{ if(Schema.sObjectType.Payment__c.isCreateable()&& Schema.sObjectType.Payment__c.isUpdateable()) upsert payment; } catch(Exception e){}
        PageReference Pg = RedirectPages();
        return Pg;
        
    }
    
    /* commented, as need to discuss on this
    public PageReference refundPay() {
        Credentials__c paypalSetup;
        if(Schema.sObjectType.Credentials__c.isAccessible()) {
            paypalSetup = [Select Id, Name, Password_Transkey__c, Signature__c , URL__c, Encrypted_Key__c, Username_Login__c From Credentials__c 
            Where name = 'Paypal' Limit 1];
        }
        
        String url = String.valueof(paypalSetup.URL__c);
        Blob cryptoKey, userData, passwordData;
        cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
        userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
        passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
        if(userData != null) paypalSetup.Username_Login__c = userData.toString();
        if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
        
        String soapXML;
        soapXML =  '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi= " h__ttp://www.w3.org/2001/XMLSchema-instance"xmlns:SOAP-ENC="h__ttp://schemas.xmlsoap.org/soap/encoding/"xmlns:SOAP-ENV="h__ttp://schemas.xmlsoap.org/soap/envelope/"xmlns:xsd="h__ttp://www.w3.org/2001/XMLSchema"SOAP-ENV:encodingStyle="h__ttp://schemas.xmlsoap.org/soap/encoding/">';
        soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
        soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
        soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
        soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
        soapXML += '<Subject/>';
        soapXML += '</Credentials></RequesterCredentials></SOAP-ENV:Header><SOAP-ENV:Body>';
        soapXML += '<RefundTransactionReq xmlns="urn:ebay:api:PayPalAPI">';
        soapXML += '<RefundTransactionRequest>';
        soapXML += '<Version xmlns="urn:ebay:apis:eBLBaseComponents">94</Version>';
        soapXML += '<TransactionID>' + payment.Transaction_ID__c + '</TransactionID>';
        soapXML += '<RefundType>Full</RefundType>'; // Full, Partial
        //soapXML += '<Amount>50</Amount>'; // Required if RefundType is Partial or for refunds greater than 100%.
        soapXML += '</RefundTransactionRequest>';
        soapXML += '</RefundTransactionReq>'; 
        soapXML += '</SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(soapXML);
  
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-length', '1753' );
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
        req.setHeader('SOAPAction','');
        req.setHeader('Host','api-aa.sandbox.paypal.com');
        HttpResponse res = h.send(req);
        request_1 = soapXML;
        response_1 = res.getBody();
        return null;
    } */
    
    public PageReference RedirectPages(){
        PageReference paymentPage1 = new PageReference('/apex/Paypal_Payment?id='+payment.Id);
        if(ApexPages.currentPage().getParameters().get('con')!=null) paymentPage1.getParameters().put('con', String.escapeSingleQuotes(EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('con'),'UTF-8')));
        if(ApexPages.currentPage().getParameters().get('frm') !=null) paymentPage1.getParameters().put('frm', String.escapeSingleQuotes(EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('frm'),'UTF-8')));
        if(ApexPages.currentPage().getParameters().get('txt') !=null) paymentPage1.getParameters().put('txt', String.escapeSingleQuotes(EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('txt'),'UTF-8')));
        if(ApexPages.currentPage().getParameters().get('sg') != null) paymentPage1.getParameters().put('sg', String.escapeSingleQuotes(EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('sg'),'UTF-8')));
        if(ApexPages.currentPage().getParameters().get('so') !=null) paymentPage1.getParameters().put('so', String.escapeSingleQuotes(EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('so'),'UTF-8')));
        paymentPage1.setRedirect(true);
        return paymentPage1;
    }
        
   public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        string retValue;    // Read through the XML
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == sxmltag) {
                    reader.next(); if (reader.getEventType() == XmlTag.characters) retValue = reader.getText();
                }
            } 
            reader.next();
        }
        return retValue;//retValue.escapeXml();
    }               
}