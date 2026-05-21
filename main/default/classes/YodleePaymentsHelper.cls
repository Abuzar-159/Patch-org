global class YodleePaymentsHelper {
    @future(callout=true)
    public static void createPayments(){  
        try{
                List<String> voucherNameList = new List<String>();
                List<ERP7__Voucher__c> voucherList = new List<ERP7__Voucher__c>();
                List<ERP7__Payment__c> paymentList = new List<ERP7__Payment__c>();
            	List<ERP7__Payment__c> existPaymentList = new List<ERP7__Payment__c>();
            	Map<Id, List<ERP7__Payment__c>> vouPayMap = new Map<Id, List<ERP7__Payment__c>>();
            	Set<Id> vouIds = new Set<Id>();
                List<ERP7__Payment_Applied_on_Voucher__c> paymentAppliedList = new List<ERP7__Payment_Applied_on_Voucher__c>();
                voucherList = [select Id, Name, ERP7__Payment_Summary__c, ERP7__Vendor_invoice_Bill__c, ERP7__Organisation__c from ERP7__Voucher__c where ERP7__Paid__c = false and ERP7__Payment_Summary__c!=null];
            	for(ERP7__Voucher__c vou : voucherList){
                	vouIds.add(vou.Id);
            	}
            	if(!vouIds.isEmpty() && vouIds.size()>0){
                	existPaymentList = [select Id, Name, ERP7__Voucher__c, ERP7__Amount__c, ERP7__Payment_Summary__c from ERP7__Payment__c where ERP7__Voucher__c IN :vouIds];
                    if(!existPaymentList.isEmpty() && existPaymentList.size()>0){
                        for(ERP7__Payment__c pay : existPaymentList){
                            if(vouPayMap.containskey(pay.ERP7__Voucher__c)){
                                vouPayMap.get(pay.ERP7__Voucher__c).add(pay);
                            }else{
                                List<ERP7__Payment__c> newPaymentList = new List<ERP7__Payment__c>();
                                newPaymentList.add(pay);
                                vouPayMap.put(pay.ERP7__Voucher__c, newPaymentList);
                            }
                        }
                    }
           		}
                String AccessToken = generateToken();
                system.debug('AccessToken-->'+AccessToken);
                String token = 'Bearer '+generateToken();
                Date myDate = system.today().adddays(-3);
                system.debug('myDate-->'+myDate);
                String sdate = String.valueOf(myDate);
                Date myDate2 = system.today().adddays(-90);
                system.debug('myDate-->'+myDate2);
                String edate = String.valueOf(myDate2);
                String requestEndPoint1 = 'https://development.api.yodlee.uk/ysl/transactions';
                requestEndPoint1 +='?fromDate='+sdate+'&toDate'+edate;
                requestEndPoint1 +='&top='+500;//'&Container=Bills'+
                
                HttpRequest req1 = new HttpRequest();
                req1.setEndpoint(requestEndPoint1);
                req1.setMethod('GET');
                req1.setTimeout(2000);
                req1.setHeader('Content-Type','application/json');
                req1.setHeader('Api-Version','1.1');
                req1.setHeader('Authorization',token);
                
                Http http1 = new Http();
                httpResponse response1=http1.send(req1); 
                String response_2 = response1.getBody();
                System.debug('Expense ~>'+response_2);
                if(response1.getStatusCode()==200){                 
                    Map<String,Object> results1=(Map<String,Object>)JSON.deserializeUntyped(response_2);   
                    list<ERP7__Bank_Statement__c> org_bankStmtlist=new list<ERP7__Bank_Statement__c>();     
                    List<Object> data = (List<Object>)results1.get('transaction');
                    if(data!=null){
                        for (Integer i = 0; i < data.size(); i++) {
                            Map<String, Object> mainresults = (Map<String, Object>) data[i];
                            Map<String, Object> amountFetch = (Map<String, Object>) mainresults.get('amount');
                            Map<String, Object> amountFetch1 = (Map<String, Object>) mainresults.get('runningBalance');
                            Map<String, Object> descr = (Map<String, Object>) mainresults.get('description');
                            system.debug('Description-->'+String.valueOf(descr.get('original')));
                            system.debug('Amount-->'+Decimal.valueOf(String.valueOf(amountFetch.get('amount'))));
                            for (ERP7__Voucher__c vou : voucherList) {
                                if (String.valueOf(descr.get('original')) != null && String.valueOf(descr.get('original')).contains(vou.ERP7__Payment_Summary__c)) {
                                    // Create a Payment_Object__c record
                                    system.debug('Amount-->'+Decimal.valueOf(String.valueOf(amountFetch.get('amount'))));
                                    system.debug('Description-->'+String.valueOf(descr.get('original')));
                                    List<ERP7__Chart_of_Accounts__c> coaList = new List<ERP7__Chart_of_Accounts__c>();
                                    coaList = [select Id, Name, ERP7__Yodlee_Payment_Account__c from ERP7__Chart_of_Accounts__c where ERP7__Yodlee_Payment_Account__c=true];
                                    if(!vouPayMap.isEmpty() && vouPayMap.size()>0 && vouPayMap.containskey(vou.Id)){
                                        system.debug('Entered');
                                        Boolean existPayment = false;
                                        for(ERP7__Payment__c payVou : vouPayMap.get(vou.Id)){
                                            if((payVou.ERP7__Amount__c==Decimal.valueOf(String.valueOf(amountFetch.get('amount')))) && payVou.ERP7__Payment_Summary__c==String.valueOf(descr.get('original'))){
                                                existPayment = true;
                                            }
                                        }
                                        system.debug('existPayment-->'+existPayment);
                                        if(!existPayment){
                                            ERP7__Payment__c paymentObj = new ERP7__Payment__c();
                                            paymentObj.ERP7__Payment_Summary__c = String.valueOf(descr.get('original')); // Set the name or relevant field
                                            paymentObj.ERP7__Total_Amount__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount'))); 
                                            paymentObj.ERP7__Amount__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));
                                            paymentObj.ERP7__Voucher__c = vou.Id;
                                            paymentObj.ERP7__Bill__c = vou.ERP7__Vendor_invoice_Bill__c;
                                            paymentObj.ERP7__Account__c = vou.ERP7__Organisation__c;
                                            paymentObj.ERP7__Payment_Account__c = coaList[0].Id;//'a110600000YLaXLAA1';
                                            paymentObj.ERP7__Transaction_Type__c='BillPayment';
                                            paymentObj.ERP7__Posted__c = true;
                                            paymentList.add(paymentObj);
                                        }
                                    }else{
                                        ERP7__Payment__c paymentObj = new ERP7__Payment__c();
                                        paymentObj.ERP7__Payment_Summary__c = String.valueOf(descr.get('original')); // Set the name or relevant field
                                        paymentObj.ERP7__Total_Amount__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount'))); 
                                        paymentObj.ERP7__Amount__c = Decimal.valueOf(String.valueOf(amountFetch.get('amount')));
                                        paymentObj.ERP7__Voucher__c = vou.Id;
                                        paymentObj.ERP7__Bill__c = vou.ERP7__Vendor_invoice_Bill__c;
                                        paymentObj.ERP7__Account__c = vou.ERP7__Organisation__c;
                                        paymentObj.ERP7__Payment_Account__c = coaList[0].Id;//'a110600000YLaXLAA1';
                                        paymentObj.ERP7__Transaction_Type__c='BillPayment';
                                        paymentObj.ERP7__Posted__c = true;
                                        paymentList.add(paymentObj);
                                    }
                                }
                            }
                        }
                    }
                    if(!paymentList.isEmpty()&&paymentList.size()>0){
                        upsert paymentList;
                        for(ERP7__Payment__c pay : paymentList){
                            ERP7__Payment_Applied_on_Voucher__c payApplied = new ERP7__Payment_Applied_on_Voucher__c();
                            payApplied.ERP7__Amount__c = pay.ERP7__Total_Amount__c;
                            payApplied.ERP7__Payment__c = pay.Id;
                            payApplied.ERP7__Voucher__c = pay.ERP7__Voucher__c;
                            paymentAppliedList.add(payApplied);
                        }
                        if(paymentAppliedList.size()>0){
                            insert paymentAppliedList;
                        }
                    }
                    
                    
                }
        }catch(Exception e){
            system.debug('Exception'+e+e.getLineNumber());
        }
    }
        
    
    
    public static String generateToken(){
        // Generation of Token //
        String yodlee = '%Yodlee%';
        Credentials__c cred = [Select Id, Name, Active__c, ERP7__Password_Transkey__c, Channel_Id__c, ERP7__Signature__c, URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c, ERP7__Account_Id__c, ERP7__Bank_COA_ID__c  
                               From Credentials__c
                               Where Active__c =: true And
                               Name Like :yodlee order by CreatedDate desc
                               Limit 1];
        Blob cryptoKey, userData, passwordData;
        cryptoKey = encodingUtil.convertFromHex(cred.Encrypted_Key__c);
        userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Username_Login__c));
        passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Password_Transkey__c));
        if(userData != null) system.debug(userData.toString());
        if(passwordData != null) system.debug(passwordData.toString());
        String requestEndPoint = cred.URL__c; 
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(requestEndPoint);  
        req.setMethod('POST');    
        req.setTimeout(2000); 
        req.setHeader('Content-Type','application/x-www-form-urlencoded');   
        req.setHeader('Api-Version','1.1');  
        req.setHeader('loginName',userData.toString());  
        String body='clientId='+userData.toString()+'&secret='+passwordData.toString();  
        req.setBody(body);
        Http http = new Http(); 
        httpResponse response=http.send(req); 
        String response_1 = response.getBody(); 
        Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
        Object data = (Object)results.get('token');  
        Map<String,Object> mainresults=(Map<String,Object>)data; 
        system.debug('mainresults-->'+mainresults);
        String AccessToken=String.valueOf(mainresults.get('accessToken'));
        return AccessToken;
     }
}