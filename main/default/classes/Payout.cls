public with sharing class Payout {
	@AuraEnabled
    public static ERP7__Voucher__c fetchVoucherDetails(String vId){
        ERP7__Voucher__c vou = new ERP7__Voucher__c();
        if(vId!=null) {
            vou = [select Id, ERP7__Amount__c, ERP7__Amount_Due__c, ERP7__Amount_Paid__c, ERP7__Vendor__c, ERP7__Vendor__r.Name, ERP7__Vendor__r.ERP7__Stripe_Account_Id__c from ERP7__Voucher__c where Id=:vId];
            return vou;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static List<ERP7__Voucher__c> fetchVouchers(String vId){
        List<ERP7__Voucher__c> vou = new List<ERP7__Voucher__c>();
        if(vId!=null && vId!='') {
            vou = [select Id, Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name, ERP7__Vendor_invoice_Bill__c, ERP7__Vendor_invoice_Bill__r.Name, ERP7__Vendor_invoice_Bill__r.ERP7__Bill_Date__c, ERP7__Vendor_invoice_Bill__r.ERP7__Due_Date__c, ERP7__Amount__c, ERP7__Amount_Due__c, ERP7__Amount_Paid__c, ERP7__Vendor__c, ERP7__Vendor__r.Name, ERP7__Vendor__r.ERP7__Stripe_Account_Id__c from ERP7__Voucher__c where ERP7__Vendor__c=:vId and ERP7__Paid__c=false and ERP7__Approved__c=true and ERP7__Payment_Schedule__c=null];
            return vou;
        }else{
            return null;
        }
        
    }
    
    @AuraEnabled
    public static String scheduleStripePayment(List<String> VIds, String VendorId){
        try{
            system.debug('VIds-->'+VIds[0]);
            ERP7__Payment_Schedule__c ps = new ERP7__Payment_Schedule__c();
            ps.ERP7__Schedule_Date__c = system.today();
            ps.ERP7__Vendor__c = VendorId;
            ps.ERP7__Approved__c = true;
            insert ps;
            List<ERP7__Voucher__c> vouList = new List<ERP7__Voucher__c>();
            vouList = [select Id, Name from ERP7__Voucher__c where Id IN :VIds];
            for(ERP7__Voucher__c vou : vouList){
                vou.ERP7__Payment_Schedule__c = ps.Id;
            }
            update vouList;
            return 'success';
        }catch(Exception e){
            system.debug('Exception-->'+e+e.getLineNumber());
            return String.valueOf(e);
        }
    }
    
    @AuraEnabled
    public static String recordStripePayment(String vId, Decimal Amount){
        String srequestEndPoint = 'https://api.stripe.com/v1/transfers'; 
        HttpRequest sreq = new HttpRequest(); 
        sreq.setEndpoint(srequestEndPoint);  
        sreq.setMethod('POST');    
        sreq.setTimeout(2000); 
        
        
        String myCur;
        Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(isMultiCurrency){  
            String acc='Select CurrencyIsoCode from ERP7__Voucher__c '; 
            acc+='where Id=:vId'; 
            String Currency_Code=(String)Database.Query(acc)[0].get('CurrencyIsoCode');
            myCur = Currency_Code;
        }else{
            myCur = UserInfo.getDefaultCurrency();
        }
        
        ERP7__Voucher__c vou = new ERP7__Voucher__c();
        vou = [select Id, ERP7__Amount__c, ERP7__Organisation__c, ERP7__Amount_Due__c, ERP7__Vendor_invoice_Bill__c, ERP7__Vendor__c, ERP7__Vendor__r.Name, ERP7__Vendor__r.ERP7__Stripe_Account_Id__c from ERP7__Voucher__c where Id=:vId];
        String s1url = 'amount='+Integer.valueOf(Amount*100)+'&currency='+myCur+'&destination='+vou.ERP7__Vendor__r.ERP7__Stripe_Account_Id__c;
        
        sreq.setHeader('Content-Type','application/x-www-form-urlencoded'); 
        sreq.setBody(s1url);
        String token1 = 'Bearer '+ 'sk_test_rzHeHAVhrWhTpzJoZvD1FEX7';
        sreq.setHeader('Authorization',token1);
        Http http1 = new Http(); 
        httpResponse response1=http1.send(sreq); 
        String response_12 = response1.getBody();
        system.debug('response_12-->'+response_12);
        Map<String,Object> results1=(Map<String,Object>)JSON.deserializeUntyped(response_12);
        system.debug('results1-->'+results1);
        if(results1.get('id') != null){
            ERP7__Payment__c pay = new ERP7__Payment__c();
            pay.ERP7__Total_Amount__c = Amount;
            pay.ERP7__Amount__c = Amount;
            pay.ERP7__Voucher__c = vId;
            pay.ERP7__Bill__c = vou.ERP7__Vendor_invoice_Bill__c;
            pay.ERP7__Transaction_ID__c = String.valueOf(results1.get('id'));
            pay.ERP7__Accounts__c = vou.ERP7__Vendor__c;
            pay.ERP7__Account__c = vou.ERP7__Organisation__c;
            insert pay;
            ERP7__Payment_Applied_on_Voucher__c pvou = new ERP7__Payment_Applied_on_Voucher__c();
            pvou.ERP7__Voucher__c = vId;
            pvou.ERP7__Payment__c = pay.Id;
            pvou.ERP7__Amount__c = Amount;
            insert pvou;
            return 'success';
        }else{
            return String.valueOf(results1);
        }
    }
}