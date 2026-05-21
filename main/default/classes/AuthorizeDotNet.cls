Global With Sharing Class AuthorizeDotNet{
    //Set Merchant's Login id and transaction key    
    private static string login;
    private static string transkey;
    
    //Class level useful variables
    private list<string> results;
    private boolean approved;
    private boolean declined;
    private boolean error;
    private string url;
    private boolean isTest;
    private string fields;
    private string response;
    private map<string, string> params;
    
    global AuthorizeDotNet(boolean isTest, String gatewayId){
        Credentials__c gateway;
        Blob cryptoKey, userData, passwordData;
        if(Schema.sObjectType.Credentials__c.isAccessible())
        gateway = [Select Id, Name, Active__c, Password_Transkey__c, Signature__c, URL__c, Username_Login__c, Encrypted_Key__c
                   From Credentials__c Where Id =: gatewayId ];
        
        if(gateway.Encrypted_Key__c != null) if(Schema.sObjectType.Credentials__c.fields.Encrypted_Key__c.isAccessible()) cryptoKey = encodingUtil.convertFromHex(gateway.Encrypted_Key__c);
        if(gateway.Username_Login__c != null) if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible()) userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(gateway.Username_Login__c));
        if(gateway.Password_Transkey__c != null) if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible()) passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(gateway.Password_Transkey__c));
        if(userData != null) if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible()) gateway.Username_Login__c = userData.toString();
        if(passwordData != null) if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible()) gateway.Password_Transkey__c = passwordData.toString();
                
        if(Schema.sObjectType.Credentials__c.fields.Username_Login__c.isAccessible()) login = gateway.Username_Login__c;
        if(Schema.sObjectType.Credentials__c.fields.Password_Transkey__c.isAccessible()) transkey = gateway.Password_Transkey__c;
        results = new list<string>();
        approved = false;
        declined = false;
        error    = true;
        fields = '';
        params = new map<string, string>();
        
        //For setting sandbox or production
        
        if (gateway.URL__c != Null && gateway.URL__c != ''){
            if(Schema.sObjectType.Credentials__c.fields.URL__c.isAccessible()) this.url = gateway.URL__c;
        }
        else {
            this.url = 'https://test.authorize.net/gateway/transact.dll';
        }
        
        //Some Predefined useful parameters for authorize.net API
        params.put('x_delim_data', 'true');
        params.put('x_delim_char', '|');
        params.put('x_relay_response', 'false');
        params.put('x_url', 'false');
        params.put('x_version', '3.0');
        params.put('x_method', 'CC');
        params.put('x_type', 'AUTH_CAPTURE');
        params.put('x_login', login);
        params.put('x_tran_key', transkey);
        params.put('x_description', 'Sample Transaction');
        params.put('x_description', '0');            
        
    }
    
    global void transaction(string cardnum, string expiration, string amount, string cvv, string invoice, string tax){
         params.put('x_card_num', cardnum);
        params.put('x_exp_date', expiration);
        params.put('x_amount', amount);
        params.put('x_po_num', invoice);
         params.put('x_card_code', cvv);       
    }
    
    //Calls the Authorize.Net service and fetch the response
    global void process(integer retries){
        retries = 3;
        this.prepareParameters();        
        integer count = 0;
        
        while (count < retries){
            HttpRequest hReq = new HttpRequest();
            hReq.setEndpoint(this.url);
            hReq.setMethod('POST');
            hReq.setBody(this.fields);
            Http con = new Http();
            if(!Test.isRunningTest()){                
                HttpResponse res = con.send(hReq);
                this.response = res.getBody();                
            }else{
                //Test response filling in case Test class is running
                this.response = '1|1|1|This transaction has been approved.|LDV9JR|Y|2160295577||0|600.00|CC|auth_capture||aslam|bari||dfsdf||wa|5555||||||||||||||||||71AFA2003D02930E47E84F23E14E07C3|P|2|||||||||||XXXX1111|Visa|||||||||||||||||false|1';
            }
             this.parseResults();
            if (this.getResultResponseFull() == 'Approved'){
                this.approved = true;
                this.declined = false;
                this.error    = false;
                break;
            }
            else if (this.getResultResponseFull() == 'Declined'){
                this.approved = false; this.declined = true; this.error    = false; break;
            }
            count++;
        }
    }

    private void parseResults(){
        this.results = this.response.split('\\|');
    }

    global void setParameter(String param, String value){
        param                = param.trim();
        value                = value.trim();
        this.params.put(param, value);
    }

    global void setTransactionType(String types){
        this.params.put('x_type', types.toUpperCase().trim());
    }

    private void prepareParameters(){
        for(String ss: params.keyset()){
            this.fields += ss + '=' +  EncodingUtil.UrlEncode(params.get(ss),'UTF-8') + '&';
        }
        this.fields = this.fields.substring(0,this.fields.length() - 1);
    }

    global string getResultResponse(){
        return this.results[0];
    }

    global string getResultResponseFull(){
        list<string> response = new list<string>();
        response.add('');
        response.add('Approved');
        response.add('Declined');
        response.add('Error');
        if(this.results[0] == '1') return response[1];
        else if(this.results[0] == '2') return response[2];
        else if(this.results[0] == '3') return response[3];
        
        return '';
    }
    
	global boolean isApproved() { return this.approved; }
	global boolean isDeclined() { return this.declined; }
	global boolean isError() { return this.error; }
	global string getResponseText() { return this.results[3]; }
	global string getAuthCode() { return this.results[4]; }
	global string getAVSResponse(){ return this.results[5]; }
	global string getTransactionID() { return this.results[6]; }

}