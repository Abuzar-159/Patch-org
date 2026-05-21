public with sharing class paymentRefund {
    
    public list<Credentials__c> paymentCredentials          { get; set; }
    public list<Payment__c> paymentObject                   { get; set; }
    public String credentialFields                          { get; set; }
    public String paymentFields                             { get; set; }
    public String paymentGateway                            { get; set; }
    public String paymentGatewayURL                         { get; set; }
    public String paymentGatewayEp                          { get; set; }
    public String transactionId                             { get; set; }
    public String request_1                                 { get; set; }    
    public String response_1                                { get; set; }
    public String request_2                                 { get; set; }    
    public String response_2                                { get; set; }
    public String resStatus                                 { get; set; }
    public String Result                                    { get; set; }
    public String ErrorMsg                                  { get; set; }
    public String SuccessMsg                                { get; set; }
    public String refundableAmt                             { get; set; }
    public String errorMessage                              { get; set; }
    public String recordId                                  { get; set; }
    
    public String errormsg2                                 { get; set; }
    public Boolean hasAccess                                { get; set; }
    
    public paymentRefund(ApexPages.StandardController controller) {
        ErrorMsg = '';
        SuccessMsg = '';
        errorMessage = '';
        credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
        paymentFields = UtilClass.selectStarFromSObject('ERP7__Payment__c');
        
        recordId = ApexPages.currentPage().getParameters().get('Id');
        paymentObject = Database.query('select ' + String.escapeSingleQuotes(paymentFields) + ' from Payment__c where Id =\''+ String.escapeSingleQuotes(recordId) + '\' And Refund__c = false Limit 1');
        
    } 
    
    public PageReference processRefund(){ 
        if(paymentObject.size() > 0){
        
            paymentGateway = paymentObject[0].Payment_Gateway__c;
            transactionId = paymentObject[0].Transaction_ID__c;
            refundableAmt = string.valueOf(paymentObject[0].Refund_Amount__c);
            
            paymentCredentials = Database.query('select ' + String.escapeSingleQuotes(credentialFields) + ' from Credentials__c where (Name =: paymentGateway And Active__c = true) Limit 1');
            paymentGatewayURL = paymentCredentials[0].URL__c;
            
            if(paymentGateway == 'Authorize.Net'){
                return authorizeRefund();
            } else if(paymentGateway == 'Paypal'){
                return paypalRefund();
            }    
        }else errorMessage = 'Payment already refunded!!!';
        return null;
    }
    
    public PageReference authorizeRefund(){
    
        if(paymentCredentials != null && transactionId != null){
            Blob cryptoKey, userData, passwordData;
            if(paymentCredentials[0].Encrypted_Key__c != null) if(Schema.sObjectType.Credentials__c.fields.Encrypted_Key__c.isAccessible()) cryptoKey = encodingUtil.convertFromHex(paymentCredentials[0].Encrypted_Key__c);
            if(paymentCredentials[0].Username_Login__c != null) if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible()) userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paymentCredentials[0].Username_Login__c));
            if(paymentCredentials[0].Password_Transkey__c != null) if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible()) passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paymentCredentials[0].Password_Transkey__c));
            if(userData != null) if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible()) paymentCredentials[0].Username_Login__c = userData.toString();
            if(passwordData != null) if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible()) paymentCredentials[0].Password_Transkey__c = passwordData.toString();
            if(paymentGatewayURL !=null && paymentGatewayURL == 'https://test.authorize.net/gateway/transact.dll') paymentGatewayEp = 'https://apitest.authorize.net/xml/v1/request.api';
            else paymentGatewayEp = paymentGatewayURL;
        }
        
        String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
        soapXML += '<getTransactionDetailsRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
            soapXML += '<merchantAuthentication>';
                soapXML += '<name>'+ paymentCredentials[0].Username_Login__c +'</name>';
                soapXML += '<transactionKey>'+ paymentCredentials[0].Password_Transkey__c +'</transactionKey>';
            soapXML += '</merchantAuthentication>';
            soapXML += '<transId>'+ transactionId +'</transId>';
        soapXML += '</getTransactionDetailsRequest>';
        
        HttpRequest req = new HttpRequest();
        Http h = new Http();
        
        req.setBody(soapXML);   
        req.setMethod('POST');
        req.setEndpoint(paymentGatewayEp);
        req.setHeader('Content-length', '2000');
        req.setHeader('Content-Type', 'text/xml');
        
        if(Test.isRunningTest()){
            result = '<getTransactionDetailsResponse ><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transaction><transId>40009291868</transId><submitTimeUTC>2018-01-02T11:47:27.57Z</submitTimeUTC><submitTimeLocal>2018-01-02T03:47:27.57</submitTimeLocal><transactionType>authCaptureTransaction</transactionType><transactionStatus>settledSuccessfully</transactionStatus><responseCode>1</responseCode><responseReasonCode>1</responseReasonCode><responseReasonDescription>Approval</responseReasonDescription><authCode>KK5C9P</authCode><AVSResponse>Y</AVSResponse><cardCodeResponse>P</cardCodeResponse><batch><batchId>7788515</batchId><settlementTimeUTC>2018-01-03T01:59:10.687Z</settlementTimeUTC><settlementTimeLocal>2018-01-02T17:59:10.687</settlementTimeLocal><settlementState>settledSuccessfully</settlementState></batch><order><description>0</description></order><authAmount>100.00</authAmount><settleAmount>100.00</settleAmount><taxExempt>false</taxExempt><payment><creditCard><cardNumber>XXXX3945</cardNumber><expirationDate>XXXX</expirationDate><cardType>MasterCard</cardType></creditCard></payment><billTo><firstName>Fiona</firstName><lastName>Pinto</lastName><address>test1 test 2</address><city>Test</city><state>Greater London</state><zip>565656</zip><country>United Kingdom</country></billTo><recurringBilling>false</recurringBilling><product>Card Not Present</product><marketType>eCommerce</marketType></transaction></getTransactionDetailsResponse>';
        } else{
            HttpResponse res = h.send(req);
            request_1 = soapXML; //response_1 = res.getBody(); //resStatus = res.getStatus();
            result = res.getBody();
        }
        
        string autCardNum = result.substringBetween('<cardNumber>', '</cardNumber>');
        string autCardExp = result.substringBetween('<expirationDate>', '</expirationDate>');
        
        if(autCardNum != null && autCardNum != '' && autCardExp!= null && autCardExp !=''){
            String soapXMLr  = '<?xml version="1.0" ?>';
            soapXMLr += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                soapXMLr += '<merchantAuthentication>';
                    soapXMLr += '<name>'+ paymentCredentials[0].Username_Login__c +'</name>';
                    soapXMLr += '<transactionKey>'+ paymentCredentials[0].Password_Transkey__c +'</transactionKey>';
                soapXMLr += '</merchantAuthentication>';
                soapXMLr += '<refId>123456</refId>'; 
                soapXMLr += '<transactionRequest>';
                    soapXMLr += '<transactionType>refundTransaction</transactionType>';
                    soapXMLr += '<amount>'+ refundableAmt +'</amount>';
                    soapXMLr += '<payment>';
                        soapXMLr += '<creditCard>';
                            soapXMLr += '<cardNumber>'+ autCardNum +'</cardNumber>';
                            soapXMLr += '<expirationDate>'+ autCardExp +'</expirationDate>';
                        soapXMLr += '</creditCard>';
                    soapXMLr += '</payment>';
                    soapXMLr += '<refTransId>'+ transactionId +'</refTransId>';
                soapXMLr += '</transactionRequest>'; 
            soapXMLr += '</createTransactionRequest>';
            
            HttpRequest reqr = new HttpRequest();
            Http hr = new Http(); 
            
            reqr.setBody(soapXMLr);   
            reqr.setMethod('POST');
            reqr.setEndpoint(paymentGatewayEp);
            reqr.setHeader('Content-length', '2000');  
            reqr.setHeader('Content-Type', 'text/xml');
            
            if(Test.isRunningTest()){
                response_2 = '<createTransactionResponse><refId>123456</refId><messages><resultCode>Error</resultCode><message><code>E00027</code><text>The transaction was unsuccessful.</text></message></messages><transactionResponse><responseCode>3</responseCode><authCode/><avsResultCode>P</avsResultCode><cvvResultCode/><cavvResultCode/><transId>0</transId><refTransID>40009291868</refTransID><transHash>1A7CA8FC5C4028E33751F903449FF515</transHash><testRequest>0</testRequest><accountNumber>XXXX3945</accountNumber><accountType>MasterCard</accountType><errors><error><errorCode>55</errorCode><errorText>The sum of credits against the referenced transaction would exceed original debit amount.</errorText></error></errors><transHashSha2></transactionResponse></createTransactionResponse>';
            } else{
                HttpResponse resr = hr.send(reqr);            
                request_2 = soapXMLr;
                response_2 = resr.getBody();
            }
            
            if(response_2!=null){
                string resultCode = response_2.substringBetween('<resultCode>', '</resultCode>');
                if(resultCode == 'Ok'){
                    string messages = response_2.substringBetween('<messages>', '</messages>');
                    if(messages != null){ 
                        SuccessMsg = response_2.substringBetween('<description>', '</description>');
                        paymentObject[0].Refund__c = true;
                        if(Schema.sObjectType.Payment__c.fields.Refund__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Refund__c.isUpdateable()){hasAccess=true; upsert paymentObject;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    } else{ 
                        errorMessage = 'Failed Transaction. ';
                        string errors = response_2.substringBetween('<errors>', '</errors>');
                        string errorText = response_2.substringBetween('<errorText>', '</errorText>');
                        if(errors != null) errorMessage += errorText;
                    }
                }else {
                    errorMessage = 'Failed Transaction. ';
                    string errors = response_2.substringBetween('<errors>', '</errors>');
                    string errorText = response_2.substringBetween('<errorText>', '</errorText>');
                    string Text = response_2.substringBetween('<Text>', '</Text>');
                    if(errors != null) errorMessage += errorText;
                    else errorMessage += Text;
                }
            }else errorMessage = 'Null Response.';
        }else errorMessage = 'Null Response.';
        
        return null;
    }
    
    public PageReference paypalRefund(){
        if(paymentCredentials != null && transactionId != null){
            Blob cryptoKey, userData, passwordData;
            cryptoKey = encodingUtil.convertFromHex(paymentCredentials[0].Encrypted_Key__c);
            userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paymentCredentials[0].Username_Login__c));
            passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paymentCredentials[0].Password_Transkey__c));
            if(userData != null) paymentCredentials[0].Username_Login__c = userData.toString();
            if(passwordData != null) paymentCredentials[0].Password_Transkey__c = passwordData.toString();
            if(paymentGatewayURL !=null && paymentGatewayURL == 'https://api-3t.sandbox.paypal.com/2.0/') paymentGatewayEp = 'https://api-3t.sandbox.paypal.com/nvp';
            else paymentGatewayEp = paymentGatewayURL;
         
        }
        
        String soapXML;
        
        soapXML =  '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi= '+System.label.paymentRefund+'';
        soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
        soapXML += '<Username>'+ paymentCredentials[0].Username_Login__c +'</Username>';
        soapXML += '<Password>'+ paymentCredentials[0].Password_Transkey__c +'</Password>';
        soapXML += '<Signature>'+ paymentCredentials[0].Signature__c +'</Signature>';
        soapXML += '<Subject/>';
        soapXML += '</Credentials></RequesterCredentials></SOAP-ENV:Header><SOAP-ENV:Body>';
        soapXML += '<RefundTransactionReq xmlns="urn:ebay:api:PayPalAPI">';
        soapXML += '<RefundTransactionRequest>';
        soapXML += '<Version xmlns="urn:ebay:apis:eBLBaseComponents">94</Version>';
        soapXML += '<TransactionID>'+ transactionId +'</TransactionID>'; //0YX13025FY697382K
        soapXML += '<RefundType>'+ paymentObject[0].Refund_Type__c +'</RefundType>'; // Full, Partial
        if(paymentObject[0].Refund_Type__c == 'Partial'){
            soapXML += '<Amount>'+ refundableAmt +'</Amount>'; // Required if RefundType is Partial or for refunds greater than 100%.
        } 
        soapXML += '</RefundTransactionRequest>';
        soapXML += '</RefundTransactionReq>'; 
        soapXML += '</SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(soapXML);
  
        req.setEndpoint(paymentGatewayEp); 
        req.setMethod('POST');
        req.setHeader('Content-length', '1753' );
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
        req.setHeader('SOAPAction','');
        req.setHeader('Host','api-aa.sandbox.paypal.com');
        
        if(Test.isRunningTest()){
            response_1 = '<RefundTransactionResponse xmlns="urn:ebay:api:PayPalAPI"><Timestamp xmlns="urn:ebay:apis:eBLBaseComponents">2018-01-15T15:54:24Z</Timestamp><Ack xmlns="urn:ebay:apis:eBLBaseComponents">Failure</Ack><CorrelationID xmlns="urn:ebay:apis:eBLBaseComponents">b3117b3080823</CorrelationID><Errors xmlns="urn:ebay:apis:eBLBaseComponents" xsi:type="ebl:ErrorType"><ShortMessage xsi:type="xs:string">Transaction refused</ShortMessage><LongMessage xsi:type="xs:string">This transaction has already been fully refunded</LongMessage><ErrorCode xsi:type="xs:token">10009</ErrorCode><SeverityCode xmlns="urn:ebay:apis:eBLBaseComponents">Error</SeverityCode></Errors><Version xmlns="urn:ebay:apis:eBLBaseComponents">94</Version><Build xmlns="urn:ebay:apis:eBLBaseComponents">000000</Build><RefundTransactionID></RefundTransactionID></RefundTransactionResponse>';
        } else{
            HttpResponse res = h.send(req);
            request_1 = soapXML;
            response_1 = res.getBody();    
        }
        
        string Ack = response_1.substringBetween('<Ack xmlns="urn:ebay:apis:eBLBaseComponents">', '</Ack>');
        if(Ack != null && Ack != '' && Ack == 'Success'){ SuccessMsg = 'Submitted successfully.'; paymentObject[0].Refund__c = true; if(Schema.sObjectType.Payment__c.fields.Refund__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Refund__c.isUpdateable()){hasAccess=true; upsert paymentObject;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } }
        else if(Ack != null && Ack != '' && Ack == 'Failure'){
            string sErrMsg = response_1.substringBetween('<ShortMessage xsi:type="xs:string">', '</ShortMessage>');
            string ErrMsg = response_1.substringBetween('<LongMessage xsi:type="xs:string">', '</LongMessage>');
            if(sErrMsg != null && sErrMsg != '') errorMessage = sErrMsg +'. '+ ErrMsg;
        } else errorMessage = 'Null Response.';
                
        return null;
    }
    
    public PageReference ClosePage() {
        PageReference pg = new PageReference('/'+recordId);
        pg.setRedirect(true);
        return pg;  
    }
   
}