public with sharing class AccountsPayable {  
    @AuraEnabled    
    public static Account DefaultOrganisation(){
         return UtilClass.getOrganisationByLogin_Employee();
        /*List<Account> accs = new List<Account>();
         * 
        accs = [SELECT Id,Name FROM Account WHERE Account_Type__c = 'Organisation' AND default__c=true];
        if(accs.size()>0) return accs[0];
        return new Account();*/
    }  
    
    @AuraEnabled
    public static String fetchRecordType(){
        //Moin added this on 09th june 2023
        String RectypeName = System.Label.Account_Record_Name;
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RectypeName).getRecordTypeId();
        //return Schema.SObjectType.Account.getRecordTypeInfosByName().get('Vendor Account').getRecordTypeId();
    }
    
    @AuraEnabled
    public static String getPaymentRecordType(){
        return JSON.serialize(ERP7__Payment__c.SObjectType.getDescribe().getRecordTypeInfos());
          
    } 
    
    @AuraEnabled
    public static List<String> getPaymentGateways(){
        List<String> gateways = new List<String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('ERP7__Payment__c');
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('ERP7__Payment_Gateway__c').getDescribe();
            List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
            for(Schema.PicklistEntry plv: picklistvalues) {
                gateways.add(plv.getValue());
            }
        return gateways;//JSON.serialize(ERP7__Payment__c.SObjectType.getDescribe().fields.getMap().get('ERP7__Payment_Gateway__c'));
          
    } 
    @AuraEnabled   
    public static wrapper getSupplierAccounts(String OrgID,Integer Offset, Integer RecordLimit,String searchString){
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String query='SELECT Id, Name, AccountNumber, ERP7__Opening_Balance__c,Phone , ERP7__Payment_Terms__c, ERP7__Paid_Amount__c , ERP7__Total_Due__c,ERP7__Debit_Note_Balance__c,ERP7__Credit_Balance__c   FROM Account WHERE (ERP7__Account_Type__c  = \'Vendor\' Or ERP7__Account_Type__c  = \'Organisation/Vendor\' Or ERP7__Account_Type__c = \'Organisation/Vendor\') ';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s)';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name  asc limit 2000 ';
        if(String.isEmpty(OrgID))query += '  order by Name  asc limit 2000 ';
        ar.accSL = Database.query(query);
        ar.recSize     =  ar.accSL.size(); 
        query=null;
        query='SELECT Id, Name, AccountNumber, Phone , ERP7__Payment_Terms__c,ERP7__Opening_Balance__c, ERP7__Paid_Amount__c , ERP7__Total_Due__c,ERP7__Credit_Balance__c,ERP7__Debit_Note_Balance__c   FROM Account WHERE (ERP7__Account_Type__c  = \'Vendor\'  Or ERP7__Account_Type__c  = \'Organisation/Vendor\' Or ERP7__Account_Type__c = \'Organisation/Vendor\')';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s)';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by Name limit :ikRecordLimit Offset :ikOffset ';
        if(String.isEmpty(OrgID))query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
        ar.acc = Database.query(query);
        return  ar; 
    }
    @AuraEnabled   
    public static wrapper fetchPO(String accId,String OrgID,Integer Offset, Integer RecordLimit,String searchString){
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        List<Id> ids = new List<id>();
        ids = accId.split(',');
        String query='SELECT Id, Name, ERP7__Total_Amount__c,ERP7__Total_Due__c ,CreatedDate,ERP7__Order_Date__c,ERP7__Ready_To_Receive__c,ERP7__Putaway_Quantity__c,ERP7__Reconciled_Quantity__c,ERP7__Inbound_Total_Quantity__c,ERP7__Inbound_Received_Quantity__c, ERP7__Tax_Amount__c  ,ERP7__Logistic_Quantity__c, toLabel(ERP7__Status__c) , ERP7__Total_Quantity__c ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Amount_Paid__c, RecordType.DeveloperName, toLabel(ERP7__Stage__c)    FROM ERP7__PO__c WHERE ERP7__Vendor__c !=null';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Vendor__r.Name Like :s) ';
        if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by CreatedDate  desc limit 2000 ';
        if(String.isEmpty(OrgID))query += '  order by CreatedDate  desc limit 2000 ';
        ar.POSL = Database.query(query);
        ar.recSize = ar.POSL.size(); 
        query=null;
        query='SELECT Id, Name, ERP7__Total_Amount__c,ERP7__Total_Due__c ,ERP7__Logistic_Quantity__c,CreatedDate, ERP7__Order_Date__c,ERP7__Ready_To_Receive__c,ERP7__Putaway_Quantity__c,ERP7__Reconciled_Quantity__c,ERP7__Inbound_Total_Quantity__c,ERP7__Inbound_Received_Quantity__c, ERP7__Tax_Amount__c  , toLabel(ERP7__Status__c) , ERP7__Total_Quantity__c ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Amount_Paid__c, RecordType.DeveloperName,toLabel(ERP7__Stage__c)    FROM ERP7__PO__c WHERE ERP7__Vendor__c !=null';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Vendor__r.Name Like :s)';
        if(String.isNotEmpty(accId))query +=' AND ERP7__Vendor__c IN: ids';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
        if(String.isEmpty(OrgID))query += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
        List<ERP7__PO__c> poList = new List<ERP7__PO__c>();
        ar.PO = Database.query(query);
        return ar;
    }
    
    @AuraEnabled 
    public static wrapper fetchBills(String accId,String OrgID, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString,String vids, Integer Aging){
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
        String paid='paid';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        Integer Age = Integer.valueof(Aging);
        Integer StartAge = 0;
        system.debug('Age-->'+Age);
        if(Age == 30) StartAge = 0;
        else if(Age == 60) StartAge = 30;
        else if(Age == 90) StartAge = 60;
        else if(Age == 2000) StartAge = 90;
        system.debug('StartAge-->'+StartAge);
        String query = '';
        if(Age > 0) query='SELECT Id, Name, ERP7__Amount__c  , ERP7__Due_Date_Days__c, ERP7__PO_Name__c, ERP7__Bill_Date__c, ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,toLabel(ERP7__Status__c) ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c !=null and RecordTypeId != null AND ERP7__Due_Date_Days__c<=:Age AND ERP7__Due_Date_Days__c>=:StartAge AND ERP7__Amount_Due__c>0 ';
        else if(Age < 0) query='SELECT Id, Name, ERP7__Amount__c  , ERP7__Due_Date_Days__c, ERP7__PO_Name__c, ERP7__Bill_Date__c, ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,toLabel(ERP7__Status__c) ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c !=null and RecordTypeId != null  AND ERP7__Amount_Due__c>0 ';
        else query='SELECT Id, Name, ERP7__Amount__c  , ERP7__Due_Date_Days__c, ERP7__PO_Name__c, ERP7__Bill_Date__c, ERP7__Amount_Due__c  ,ERP7__Issue_Voucher__c,ERP7__Organisation__c, ERP7__TDS_Amount__c ,ERP7__Due_Date__c, ERP7__Amount_Paid__c  ,RecordTypeId, ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,toLabel(ERP7__Status__c) ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c !=null and RecordTypeId != null AND ERP7__Due_Date_Days__c<:Age AND ERP7__Amount_Due__c>0 ';
        List<Id> ids = new List<id>();
        ids = accId.split(',');
        Set<Id> BillIds = new Set<Id>();
        List<ERP7__Bill_Line_Item__c> billlineList = new List<ERP7__Bill_Line_Item__c>();
        billlineList = [select Id,ERP7__Purchase_Orders__c, ERP7__Bill__c from ERP7__Bill_Line_Item__c where ERP7__Purchase_Orders__c In :ids];
        for(ERP7__Bill_Line_Item__c bb : billlineList){
            BillIds.add(bb.ERP7__Bill__c);
        }
        List<Id> vendids = new List<id>();
        vendids = vids.split(',');
        
        //ids.add('a321o000000wzJrAAI');
        //query+=' AND ERP7__Status__c!=:paid';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Purchase_Order__r.Name Like :s OR ERP7__Vendor__r.Name Like :s OR ERP7__PO_Name__c Like :s) ';
        if(String.isNotEmpty(accId))query+=' AND (ERP7__Purchase_Order__c IN: ids)';//OR Id IN :BillIds
        if(String.isNotEmpty(vids))query+=' AND ERP7__Vendor__c IN: vendids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by ERP7__Due_Date__c  desc limit 2000 ';
        if(String.isEmpty(OrgID))query += '  order by ERP7__Due_Date__c  desc limit 2000 ';
        ar.BillsSL = Database.query(query);
        ar.recSize = ar.BillsSL.size(); 
        query=null;
        if(Age > 0) query='SELECT Id, Name, ERP7__Amount__c  ,ERP7__PO_Name__c,  ERP7__Due_Date_Days__c, ERP7__Bill_Date__c, ERP7__Organisation__c, ERP7__Amount_Due__c , ERP7__TDS_Amount__c  ,ERP7__Due_Date__c,ERP7__Issue_Voucher__c,RecordTypeId, ERP7__Amount_Paid__c  , ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,toLabel(ERP7__Status__c) ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c !=null  and RecordTypeId != null  AND ERP7__Due_Date_Days__c<=:Age AND ERP7__Due_Date_Days__c>=:StartAge AND ERP7__Amount_Due__c>0 ';
        else if(Age < 0) query='SELECT Id, Name, ERP7__Amount__c  ,ERP7__PO_Name__c,  ERP7__Due_Date_Days__c, ERP7__Bill_Date__c, ERP7__Organisation__c, ERP7__Amount_Due__c , ERP7__TDS_Amount__c  ,ERP7__Due_Date__c,ERP7__Issue_Voucher__c,RecordTypeId, ERP7__Amount_Paid__c  , ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,toLabel(ERP7__Status__c) ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c !=null  and RecordTypeId != null  AND ERP7__Amount_Due__c>0 ';
        else query='SELECT Id, Name, ERP7__Amount__c  ,ERP7__PO_Name__c,  ERP7__Due_Date_Days__c, ERP7__Bill_Date__c, ERP7__Organisation__c, ERP7__Amount_Due__c , ERP7__TDS_Amount__c  ,ERP7__Due_Date__c,ERP7__Issue_Voucher__c,RecordTypeId, ERP7__Amount_Paid__c  , ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,toLabel(ERP7__Status__c) ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c,RecordType.DeveloperName FROM ERP7__BILL__c WHERE ERP7__Vendor__c !=null  and RecordTypeId != null  AND ERP7__Due_Date_Days__c<:Age AND ERP7__Amount_Due__c>0 ';
        //query+=' AND ERP7__Status__c!=:paid';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Purchase_Order__r.Name Like :s OR ERP7__Vendor__r.Name Like :s OR ERP7__PO_Name__c Like :s) ';
        if(String.isNotEmpty(accId))query+=' AND (ERP7__Purchase_Order__c IN: ids)';// OR Id IN :BillIds
        if(String.isNotEmpty(vids))query+=' AND ERP7__Vendor__c IN: vendids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by ERP7__Due_Date__c desc limit :ikRecordLimit Offset :ikOffset ';
        if(String.isEmpty(OrgID))query += '  order by ERP7__Due_Date__c desc limit :ikRecordLimit Offset :ikOffset ';
        ar.Bills = Database.query(query);
        return ar;
         
        
        //String QryFilter = (String.isNotEmpty(accId))?' AND ERP7__Purchase_Order__c IN: ids':'';
       /* QryFilter += (String.isNotEmpty(OrgID))?'  AND ERP7__Organisation__c = \''+OrgID+'\'':'';
        List<ERP7__BILL__c> billList = new List<ERP7__Bill__c>(); 
        billList = Database.query('SELECT Id, Name, ERP7__Amount__c  , ERP7__Amount_Due__c   , ERP7__Amount_Paid__c  , ERP7__Purchase_Order__c , ERP7__Purchase_Order__r.Name ,ERP7__Vendor__r.Name,ERP7__Vendor__c , ERP7__Posted__c,ERP7__Status__c ,ERP7__Total_Amount__c ,ERP7__Total_Quantity__c, ERP7__VAT_TAX_Amount__c,ERP7__Approved__c,ERP7__Matched__c FROM ERP7__BILL__c WHERE ERP7__Vendor__c !=null  AND ERP7__Purchase_Order__c!=Null '+ QryFilter);//+' Order By '+OrderBy+' '+ Order);
        Map<Id,ERP7__Bill__c> BillMap = new Map<Id,ERP7__Bill__c>(billList);
        for(ERP7__Transaction__c trans : [SELECT Id, ERP7__Bill__c, ERP7__Accounting_Period__c  FROM ERP7__Transaction__c WHERE ERP7__Bill__c IN: BillMap.keySet() AND ERP7__Accounting_Period__c != null AND ERP7__Accounting_Period__r.ERP7__Status__c != 'Open'])
            BillMap.remove(trans.ERP7__Bill__c);
            return BillMap.values();*/
       
    }
    
    /*@AuraEnabled  
    public static Wrapper fetchPayments(String accId,String OrgID, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString,String vouchIds){
        try{
        
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String query='SELECT Id,Name,ERP7__Amount__c,ERP7__Posted__c,ERP7__Status__c,ERP7__Voucher__c,ERP7__Voucher__r.Name,ERP7__Bill__c,ERP7__Bill__r.ERP7__Purchase_Order__r.Name,ERP7__Bill__r.Name,ERP7__Accounts__r.Name FROM ERP7__Payment__c WHERE ERP7__Payment_Type__c = \'Voucher\' AND ERP7__Accounts__c != null and ERP7__Accounts__r.ERP7__Account_Type__c = \'Vendor\'';
        List<Id> ids = new List<id>(); 
        ids = accId.split(',');
        List<Id> vouids = new List<id>(); 
        vouids = vouchIds.split(','); 
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if(String.isNotEmpty(accId))query +='AND ERP7__Accounts__c IN: ids ';
        if(String.isNotEmpty(vouchIds))query +='AND ERP7__Voucher__c IN: vouids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Account__c=:OrgID order by Name  asc limit 2000 ';
        if(String.isEmpty(OrgID))query += '  order by Name  asc limit 2000 ';
        ar.PaymentsSL = Database.query(query);
        ar.recSize = ar.PaymentsSL.size(); 
        query=null;
        query='SELECT Id,Name,ERP7__Amount__c,ERP7__Posted__c,ERP7__Status__c,ERP7__Voucher__c,ERP7__Voucher__r.Name,ERP7__Bill__c,ERP7__Bill__r.ERP7__Purchase_Order__r.Name,ERP7__Bill__r.Name,ERP7__Accounts__r.Name FROM ERP7__Payment__c WHERE ERP7__Payment_Type__c = \'Voucher\' AND ERP7__Accounts__c != null and ERP7__Accounts__r.ERP7__Account_Type__c = \'Vendor\'';
        if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if(String.isNotEmpty(accId))query +='AND ERP7__Accounts__c IN: ids ';
        if(String.isNotEmpty(vouchIds))query +='AND ERP7__Voucher__c IN: vouids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Account__c=:OrgID order by Name limit :ikRecordLimit Offset :ikOffset ';
        if(String.isEmpty(OrgID))query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
        ar.Payments = Database.query(query);
        
        return ar;
            
        }catch(Exception e){
            return null;
        }
       /* String QryFilter = (String.isNotEmpty(accId))?' AND ERP7__Accounts__c IN: ids':'';
        QryFilter += (String.isNotEmpty(OrgID))?' AND ERP7__Account__c =\''+OrgID+'\'':''; 
        List<Payment__c> paymentList = new List<Payment__c>();
        paymentList = Database.query('SELECT Id,Name,ERP7__Amount__c,ERP7__Posted__c,ERP7__Status__c,ERP7__Voucher__c,ERP7__Voucher__r.Name,ERP7__Bill__c,ERP7__Bill__r.Name FROM ERP7__Payment__c WHERE ERP7__Payment_Type__c = \'Voucher\' AND ERP7__Accounts__c != null and ERP7__Accounts__r.ERP7__Account_Type__c = \'Vendor\''+QryFilter+' Order By '+OrderBy+' '+ Order);
         Map<Id,Payment__c> paymentMap = new Map<Id,Payment__c>(paymentList);
        for(ERP7__Transaction__c trans : [SELECT Id, ERP7__Payment__c , ERP7__Accounting_Period__c  FROM ERP7__Transaction__c WHERE ERP7__Payment__c  IN: paymentMap.keySet() AND ERP7__Accounting_Period__c != null AND ERP7__Accounting_Period__r.ERP7__Status__c != 'Open'])
            paymentMap.remove(trans.ERP7__Payment__c );
            return paymentMap.values();
        
        
    }*/
    
    @AuraEnabled  
    public static Wrapper fetchPayments(String accId,String OrgID, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString,String vouchIds){
        system.debug('OrderBy-->'+OrderBy);
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String orderformat = String.valueOf(Order);
        system.debug('orderformat-->'+orderformat);
        String query='SELECT Id,Name,CreatedDate,ERP7__Payment_Date__c,ERP7__Posted_Date__c,ERP7__Amount__c,ERP7__Posted__c,toLabel(ERP7__Status__c),ERP7__Voucher__c,ERP7__Voucher__r.Name,ERP7__Bill__c,ERP7__Bill__r.Name,ERP7__Bill__r.ERP7__Purchase_Order__r.Name,ERP7__Accounts__r.Name FROM ERP7__Payment__c WHERE ERP7__Payment_Type__c = \'Voucher\' AND ERP7__Accounts__c != null and (ERP7__Accounts__r.ERP7__Account_Type__c = \'Vendor\' Or ERP7__Accounts__r.ERP7__Account_Type__c = \'Organisation/Vendor\')';
        List<Id> ids = new List<id>(); 
        ids = accId.split(',');
        List<Id> vouids = new List<id>(); 
        vouids = vouchIds.split(','); 
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Voucher__r.Name Like :s OR ERP7__Bill__r.Name Like :s OR ERP7__Bill__r.ERP7__Purchase_Order__r.Name Like :s OR ERP7__Accounts__r.Name Like :s) ';
        if(String.isNotEmpty(accId))query +='AND ERP7__Accounts__c IN: ids ';
        if(String.isNotEmpty(vouchIds))query +='AND ERP7__Voucher__c IN: vouids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Account__c=:OrgID  ';
        if(OrderBy!= 'Name') query += '  order by '+ OrderBy + ' '+ orderformat + ' limit 2000 ';
        else query += '  order by CreatedDate  desc limit 2000 ';
        ar.PaymentsSL = Database.query(query);
        ar.recSize = ar.PaymentsSL.size(); 
        query=null;
        query='SELECT Id,Name,ERP7__Amount__c,CreatedDate,ERP7__Payment_Date__c,ERP7__Posted_Date__c,ERP7__Posted__c,toLabel(ERP7__Status__c),ERP7__Voucher__c,ERP7__Voucher__r.Name,ERP7__Bill__c,ERP7__Bill__r.Name,ERP7__Bill__r.ERP7__Purchase_Order__r.Name,ERP7__Accounts__r.Name FROM ERP7__Payment__c WHERE ERP7__Payment_Type__c = \'Voucher\' AND ERP7__Accounts__c != null and (ERP7__Accounts__r.ERP7__Account_Type__c = \'Vendor\' or ERP7__Accounts__r.ERP7__Account_Type__c = \'Organisation/Vendor\')';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Voucher__r.Name Like :s OR ERP7__Bill__r.Name Like :s OR ERP7__Bill__r.ERP7__Purchase_Order__r.Name Like :s OR ERP7__Accounts__r.Name Like :s) ';
        if(String.isNotEmpty(accId))query +='AND ERP7__Accounts__c IN: ids ';
        if(String.isNotEmpty(vouchIds))query +='AND ERP7__Voucher__c IN: vouids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Account__c=:OrgID ';
        if(OrderBy!= 'Name') query += '  order by '+ OrderBy + ' '+ orderformat + ' limit :ikRecordLimit Offset :ikOffset ';
        else query += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
        ar.Payments = Database.query(query);
        
        Set<Id> PId = new Set<Id>();
        List<PayWraper> pWrapList = new List<PayWraper>();
        List<ERP7__Payment_Applied_on_Voucher__c> pvoucher = new List<ERP7__Payment_Applied_on_Voucher__c>();
        for(ERP7__Payment__c pay : ar.Payments){
            PId.add(pay.Id);
        }
        Map<Id, List<ERP7__Payment_Applied_on_Voucher__c>> payAppliedMap = new Map<Id, List<ERP7__Payment_Applied_on_Voucher__c>>();
        if(PId.size()>0){
            pvoucher = [select Id, Name, ERP7__Payment__c, ERP7__Voucher__c, ERP7__Voucher__r.Name, ERP7__Voucher__r.ERP7__Vendor_invoice_Bill__c, ERP7__Voucher__r.ERP7__Vendor_invoice_Bill__r.Name, ERP7__Voucher__r.ERP7__Purchase_Orders__c, ERP7__Voucher__r.ERP7__Purchase_Orders__r.Name from ERP7__Payment_Applied_on_Voucher__c where ERP7__Payment__c IN :PId];
            if(pvoucher.size()>0){
                for(ERP7__Payment_Applied_on_Voucher__c pvou : pvoucher){
                    if(payAppliedMap.containsKey(pvou.ERP7__Payment__c)){
                        payAppliedMap.get(pvou.ERP7__Payment__c).add(pvou);
                    }else{
                        List<ERP7__Payment_Applied_on_Voucher__c> pvouList = new List<ERP7__Payment_Applied_on_Voucher__c>();
                        pvouList.add(pvou);
                        payAppliedMap.put(pvou.ERP7__Payment__c, pvouList);
                    }
                }
            }
            for(ERP7__Payment__c pay : ar.Payments){
                PayWraper pwr = new PayWraper();
                if(payAppliedMap.containskey(pay.Id)){
                    pwr.pay = pay;
                    pwr.pvou = payAppliedMap.get(pay.Id);
                }else{
                    pwr.pay = pay;
                    pwr.pvou = payAppliedMap.get(pay.Id);
                }
                pWrapList.add(pwr);
            }
        }
        ar.pWrap = pWrapList;
       /* String QryFilter = (String.isNotEmpty(accId))?' AND ERP7__Accounts__c IN: ids':'';
        QryFilter += (String.isNotEmpty(OrgID))?' AND ERP7__Account__c =\''+OrgID+'\'':''; 
        List<Payment__c> paymentList = new List<Payment__c>();
        paymentList = Database.query('SELECT Id,Name,ERP7__Amount__c,ERP7__Posted__c,ERP7__Status__c,ERP7__Voucher__c,ERP7__Voucher__r.Name,ERP7__Bill__c,ERP7__Bill__r.Name FROM ERP7__Payment__c WHERE ERP7__Payment_Type__c = \'Voucher\' AND ERP7__Accounts__c != null and ERP7__Accounts__r.ERP7__Account_Type__c = \'Vendor\''+QryFilter+' Order By '+OrderBy+' '+ Order);
         Map<Id,Payment__c> paymentMap = new Map<Id,Payment__c>(paymentList);
        for(ERP7__Transaction__c trans : [SELECT Id, ERP7__Payment__c , ERP7__Accounting_Period__c  FROM ERP7__Transaction__c WHERE ERP7__Payment__c  IN: paymentMap.keySet() AND ERP7__Accounting_Period__c != null AND ERP7__Accounting_Period__r.ERP7__Status__c != 'Open'])
            paymentMap.remove(trans.ERP7__Payment__c );
            return paymentMap.values();*/
        return ar;
        
    }
    
    @AuraEnabled  
    public static wrapper fetchVouchers(String accId,String OrgID, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString, String selbills){
        try{
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
            String Paid='Paid';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String query='SELECT Id,Name,CreatedDate,ERP7__Purchase_Orders__c, ERP7__Amount__c,ERP7__Amount_Due__c,ERP7__Approved__c,ERP7__Paid__c,ERP7__Amount_Paid__c,ERP7__Amount_Paid_Rollup__c,ERP7__Status__c,ERP7__Posted__c, ERP7__Vendor__c,ERP7__Vendor__r.Name ,ERP7__Vendor_invoice_Bill__c,ERP7__Vendor_invoice_Bill__r.ERP7__Purchase_Order__r.Name,ERP7__Vendor_invoice_Bill__r.ERP7__Due_Date__c,ERP7__Vendor_invoice_Bill__r.ERP7__Bill_Date__c, Vendor_invoice_Bill__r.Name,ERP7__Vendor_invoice_Bill__r.RecordTypeId,ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName, ERP7__Credit_Applied__c  FROM ERP7__Voucher__c WHERE Name != null AND ERP7__Paid__c = False AND ERP7__Status__c !=:Paid ';
        
        List<Id> ids = new List<Id>();
        ids = accId.split(',');
        List<Id> billids = new List<Id>();
        billids = selbills.split(',');
        
        query+='';
        if(searchString!=null && searchString!='') query += ' AND (Name Like :s OR ERP7__Vendor__r.Name Like :s OR Vendor_invoice_Bill__r.Name Like :s OR ERP7__Vendor_invoice_Bill__r.ERP7__Purchase_Order__r.Name Like :s) ';
        if(String.isNotEmpty(accId)) query+=' AND ERP7__Vendor__c IN: ids ';
        if(String.isNotEmpty(selbills)) query+=' AND ERP7__Vendor_invoice_Bill__c IN: billids ';
        if(String.isNotEmpty(OrgID)) query += ' AND ERP7__Organisation__c=:OrgID order by CreatedDate  desc limit 2000 ';
        if(String.isEmpty(OrgID)) query += '  order by CreatedDate  desc limit 2000 ';
        ar.vouchersSL = Database.query(query);
        ar.recSize = ar.vouchersSL.size(); 
        query=null;
        query='SELECT Id,Name,ERP7__Amount__c,ERP7__Purchase_Orders__c, ERP7__Vendor_invoice_Bill__r.ERP7__Bill_Date__c, ERP7__Vendor_invoice_Bill__r.ERP7__Due_Date__c,CreatedDate,ERP7__Amount_Due__c,ERP7__Approved__c,ERP7__Paid__c,ERP7__Amount_Paid__c,ERP7__Amount_Paid_Rollup__c,ERP7__Status__c,ERP7__Posted__c, ERP7__Vendor__c,ERP7__Vendor__r.Name ,ERP7__Vendor_invoice_Bill__c,ERP7__Vendor_invoice_Bill__r.ERP7__Purchase_Order__r.Name,Vendor_invoice_Bill__r.Name,ERP7__Vendor_invoice_Bill__r.RecordTypeId,ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName, ERP7__Credit_Applied__c  FROM ERP7__Voucher__c WHERE Name != null AND ERP7__Paid__c = False AND ERP7__Status__c !=:Paid ';
        query+='';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Vendor__r.Name Like :s OR Vendor_invoice_Bill__r.Name Like :s OR ERP7__Vendor_invoice_Bill__r.ERP7__Purchase_Order__r.Name Like :s) ';
        if(String.isNotEmpty(accId))query+=' AND ERP7__Vendor__c IN: ids ';
        if(String.isNotEmpty(selbills))query+=' AND ERP7__Vendor_invoice_Bill__c IN: billids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
        if(String.isEmpty(OrgID))query += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
        ar.vouchers = Database.query(query);
        return ar;
        }catch(Exception e){ Wrapper ars=new Wrapper(); return ars; }
        /*String QryFilter = (String.isNotEmpty(accId))?' AND ERP7__Vendor__c IN: ids':'';
        QryFilter += (String.isNotEmpty(OrgID))?' AND ERP7__Organisation__c =\''+OrgID+'\'':'';
        List<Voucher__c> voucherList = new List<Voucher__c>();
        voucherList = Database.query('SELECT Id,Name,ERP7__Amount__c,ERP7__Amount_Due__c,ERP7__Approved__c,ERP7__Paid__c,ERP7__Amount_Paid__c,ERP7__Amount_Paid_Rollup__c,ERP7__Status__c,ERP7__Posted__c, ERP7__Vendor__c,ERP7__Vendor__r.Name ,ERP7__Vendor_invoice_Bill__c,Vendor_invoice_Bill__r.Name  FROM ERP7__Voucher__c WHERE Name != null '+ QryFilter+' Order By '+OrderBy+' '+ Order);
         Map<Id,Voucher__c> voucherMap = new Map<Id,Voucher__c>(voucherList);
        for(ERP7__Transaction__c trans : [SELECT Id, ERP7__Voucher_Bill_Payment__c  , ERP7__Accounting_Period__c  FROM ERP7__Transaction__c WHERE ERP7__Voucher_Bill_Payment__c   IN: voucherMap.keySet() AND ERP7__Accounting_Period__c != null AND ERP7__Accounting_Period__r.ERP7__Status__c != 'Open'])
            voucherMap.remove(trans.ERP7__Voucher_Bill_Payment__c  );
            return voucherMap.values();*/
    }
    
    @AuraEnabled
    public static void update_Voucher(String recordId,Boolean fieldValue){
        if(String.isNotEmpty(recordId)){
            Voucher__c vou = new Voucher__c();
            vou.Id = recordId;
            if(Schema.sObjectType.Voucher__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.Voucher__c.fields.ERP7__Posted__c.isUpdateable()) vou.ERP7__Posted__c = fieldValue;
            if(Schema.sObjectType.Voucher__c.isCreateable() && Schema.sObjectType.Voucher__c.isUpdateable()) upsert vou; else { }
        }
    }
    
    @AuraEnabled
    public static void update_VoucherApprove(String recordId,Boolean fieldValue){
        if(String.isNotEmpty(recordId)){
            Voucher__c vou = new Voucher__c();
            vou.Id = recordId;
            if(Schema.sObjectType.Voucher__c.fields.ERP7__Approved__c.isCreateable() && Schema.sObjectType.Voucher__c.fields.ERP7__Approved__c.isUpdateable()) vou.ERP7__Approved__c = fieldValue;
            if(Schema.sObjectType.Voucher__c.isCreateable() && Schema.sObjectType.Voucher__c.isUpdateable()) upsert vou; else{ }
        }
    } 
    
     @AuraEnabled
    public static List<ERP7__Chart_of_Accounts__c> fetchBankAccount(String OrgId){
        /*
        
        return [select id,Name from ERP7__Chart_of_Accounts__c where ERP7__Bank_Account__c != null AND ERP7__Organisation__c=:OrgId];*/
        /*RecordType RT = new RecordType();
        RT=[Select id,DeveloperName,Name from RecordType where SobjectType='ERP7__Bank_details__c' and DeveloperName='Organisation_card_details'];*/
        return [select id,Name,ERP7__Bank_Account__r.RecordTypeId from ERP7__Chart_of_Accounts__c where ERP7__Bank_Account__c != null AND ERP7__Organisation__c=:OrgId AND ERP7__Payment_Account__c=true];
    }
    /*
    @AuraEnabled
    public static List<ERP7__Chart_of_Accounts__c> fetchAllAccount(String OrgId){
        
        return [select id,Name from ERP7__Chart_of_Accounts__c where ERP7__Bank_Account__c != null AND ERP7__Organisation__c=:OrgId];
    }*/
    
    @AuraEnabled
    public static List<ERP7__Chart_of_Accounts__c> fetchCardAccount(String OrgId){
        /*
        RecordType RT = new RecordType();
        RT=[Select id,DeveloperName,Name from RecordType where SobjectType='ERP7__Bank_details__c' and DeveloperName='Organisation_card_details'];
        return [select id,Name,ERP7__Bank_Account__r.RecordTypeId from ERP7__Chart_of_Accounts__c where ERP7__Bank_Account__c != null AND ERP7__Organisation__c=:OrgId AND ERP7__Bank_Account__r.RecordTypeId=:RT.Id AND ERP7__Bank_Account__r.ERP7__Expiry_Date__c>:system.today()];*/
        return [select id,Name from ERP7__Chart_of_Accounts__c where ERP7__IsCreditCard__c = true];        
        
    }
    
    @AuraEnabled 
    public static wrapper getPaymentAccInfo(String recordId){
        wrapper wrapper=new wrapper();
        Boolean multiCurrencyEnabled;
        multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(multiCurrencyEnabled){ wrapper.isoCode= (String)Database.Query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true')[0].get('isoCode');
                
        }
        if(multiCurrencyEnabled){            wrapper.currencyType=UserInfo.getDefaultCurrency();            wrapper.coaConCurrency=[SELECT Id, Name, convertCurrency(ERP7__Calculated_Ending_Balance__c) FROM ERP7__Chart_of_Accounts__c WHERE Id =: recordId];
         } 
       if(String.isNotEmpty(recordId)){
            wrapper.coa= [SELECT Id, Name, ERP7__Calculated_Ending_Balance__c FROM ERP7__Chart_of_Accounts__c WHERE Id =: recordId]; 
           
        }
        
        return wrapper;
    }
    @AuraEnabled
    public static String save_Payment(String record, String singleVoucherToPay){
        try{
            PreventRecursiveLedgerEntry.potrigger=false;
            PreventRecursiveLedgerEntry.LogisticLineRollup = false;///this one to prevent po trigger from executing
            PreventRecursiveLedgerEntry.parentbillTriggerCase1=false;
            PreventRecursiveLedgerEntry.parentbillTriggerCase2=false;//these two conditions to disable bill line item trigger as its not required in this case.
            Payment__c payment = (Payment__c) JSON.deserialize(record, Payment__c.class);
            Voucher__c vou=[select Id, Name,ERP7__Amount_Paid__c,ERP7__Amount_Paid_Rollup__c,ERP7__Amount__c,ERP7__Paid__c,ERP7__Vendor_invoice_Bill__c,ERP7__Vendor_invoice_Bill__r.RecordTypeId,ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName,ERP7__Payment__c from Voucher__c where id =:singleVoucherToPay Limit 1];
            
            if((vou.ERP7__Amount_Paid_Rollup__c+payment.ERP7__Amount__c)>vou.ERP7__Amount__c){
                return 'Please enter the correct amount';
            }else{
                //Calculate previous payment amount
                /*List<ERP7__Payment_Applied_on_Voucher__c> PAVList=[Select Id,Name,ERP7__Amount__c from ERP7__Payment_Applied_on_Voucher__c where ERP7__Voucher__c =:singleVoucherToPay];
                System.debug('PAVList:'+PAVList.size());                
                Decimal paidAmount=0.0;
                for(ERP7__Payment_Applied_on_Voucher__c pav:PAVList){
                    if(pav.ERP7__Amount__c >0) paidAmount+=pav.ERP7__Amount__c;
                }  
                vou.ERP7__Amount_Paid__c=paidAmount+payment.ERP7__Amount__c;
                if(Schema.sObjectType.Voucher__c.isUpdateable()) update vou;*/
                
                //Check for Advance Bill and make payment
                if(vou.ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName == 'Advance_to_vendor'){
                    Id rectypId = Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('PrePayments').getRecordTypeId(); 
                    if(rectypId != null) payment.RecordTypeId=rectypId;   
                    if(Schema.sObjectType.Payment__c.fields.ERP7__Pre_Payment__c.isCreateable() && Schema.sObjectType.Payment__c.fields.ERP7__Pre_Payment__c.isUpdateable()) payment.ERP7__Pre_Payment__c=true;        
                }
                if(Schema.sObjectType.Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payment.ERP7__Payment_Type__c='Voucher';                
                if(Schema.sObjectType.Payment__c.isCreateable() && Schema.sObjectType.Payment__c.isUpdateable()) upsert payment; else{ }
                System.debug('Entered');
                
                //Create new ERP7__Payment_Applied_on_Voucher__c
                ERP7__Payment_Applied_on_Voucher__c PAV=new ERP7__Payment_Applied_on_Voucher__c();
                PAV.ERP7__Amount__c=payment.ERP7__Amount__c;
                PAV.ERP7__Payment__c=payment.Id;
                PAV.ERP7__Voucher__c=vou.Id;
                insert PAV;
            }
            
        }catch(Exception e){
            
        }
        return '';           
    }
    
    
    @AuraEnabled
    public static String save_Payment_Record(String record){
        Payment__c payment = (Payment__c) JSON.deserialize(record, Payment__c.class);
        if(Schema.sObjectType.Payment__c.isCreateable() && Schema.sObjectType.Payment__c.isUpdateable()) update payment; else{ }
        return '';           
    }
    
    
   @AuraEnabled
    public static String save_Payment_Credits(String record, String singleVoucherToPay, Decimal cnAmount, List<DNWrapper> dnList){
        try{
            List<ERP7__Debit_Note_Applied_on_Voucher__c> appliedNotes = new List<ERP7__Debit_Note_Applied_on_Voucher__c>();
            List<ERP7__Debit_Note__c> dn2Update = new List<ERP7__Debit_Note__c>();
            List<Account> account2Update = new List<Account>();
            Payment__c payment = (Payment__c) JSON.deserialize(record, Payment__c.class);
            Voucher__c vou=[select Id, Name,ERP7__Credit_Applied__c, ERP7__Amount_Paid__c,ERP7__Amount_Paid_Rollup__c,ERP7__Amount__c,ERP7__Paid__c,ERP7__Vendor_invoice_Bill__c,ERP7__Vendor_invoice_Bill__r.RecordTypeId,ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName,ERP7__Payment__c from Voucher__c where id =:singleVoucherToPay Limit 1];
            
            if((vou.ERP7__Amount_Paid_Rollup__c+payment.ERP7__Amount__c+cnAmount)>vou.ERP7__Amount__c){
                return 'Please enter the correct amount';
            }else{
                if(vou.ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName == 'Advance_to_vendor'){
                    Id rectypId = Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('PrePayments').getRecordTypeId(); 
                    if(rectypId != null) payment.RecordTypeId=rectypId;   
                    if(Schema.sObjectType.Payment__c.fields.ERP7__Pre_Payment__c.isCreateable() && Schema.sObjectType.Payment__c.fields.ERP7__Pre_Payment__c.isUpdateable()) payment.ERP7__Pre_Payment__c=true;        
                }
                if(Schema.sObjectType.Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payment.ERP7__Payment_Type__c='Voucher';                
                if(Schema.sObjectType.Payment__c.isCreateable() && Schema.sObjectType.Payment__c.isUpdateable()) upsert payment; else{ }
                
                //Create new ERP7__Payment_Applied_on_Voucher__c
                ERP7__Payment_Applied_on_Voucher__c PAV=new ERP7__Payment_Applied_on_Voucher__c();
                PAV.ERP7__Amount__c=payment.ERP7__Amount__c;
                PAV.ERP7__Payment__c=payment.Id;
                PAV.ERP7__Voucher__c=vou.Id;
                insert PAV;
                
                //Create Credit applied on Vouchers//
                
                if(vou.ERP7__Credit_Applied__c!=null) vou.ERP7__Credit_Applied__c = vou.ERP7__Credit_Applied__c + cnAmount;
                else vou.ERP7__Credit_Applied__c = cnAmount;
                
                if(vou.ERP7__Amount_Paid__c!=null) vou.ERP7__Amount_Paid__c = vou.ERP7__Amount_Paid_Rollup__c + vou.ERP7__Credit_Applied__c;
                //Moin added this on 12th febrauray 2024 as the amount paid was not getting updated on bill when applying credits
                PreventRecursiveLedgerEntry.testCasesTransactions = false;
                update vou;
                
                if(dnList!=null && dnList.size()>0) {
                    for(DNWrapper dwrap : dnList){
                        system.debug('dwrap-->'+dwrap);
                        if(dwrap!=null){
                            if(dwrap.debitAmount>0){
                                ERP7__Debit_Note_Applied_on_Voucher__c capplied = new ERP7__Debit_Note_Applied_on_Voucher__c();
                                capplied.ERP7__Amount__c = dwrap.debitAmount;
                                capplied.ERP7__Debit_Note__c= dwrap.debNote.Id;
                                capplied.ERP7__Voucher__c = vou.Id;
                                capplied.ERP7__Payment__c = payment.Id;//Moin added this 21st october 2024
                                capplied.Name = vou.Name + ' ' + dwrap.debNote.Name;
                                appliedNotes.add(capplied);
                                if(dwrap.debNote.ERP7__Credit__c!=null) dwrap.debNote.ERP7__Credit__c = dwrap.debNote.ERP7__Credit__c + dwrap.debitAmount;
                                else dwrap.debNote.ERP7__Credit__c = dwrap.debitAmount;
                                dn2Update.add(dwrap.debNote);
                            }
                        }
                    }
                }
                if(appliedNotes.size()>0) upsert appliedNotes;
                if(dn2Update.size()>0)  {
                    PreventRecursiveLedgerEntry.testCasesTransactions = true;
                    update dn2Update;
                }
            }
            
            
        }catch(Exception e){
            
        }
        return '';           
    }
    
    @AuraEnabled
    public static void save_Payment_Multi(String record, Decimal totalAmount, String voucherList, List<DNWrapper> dnList) {
        List<ERP7__Debit_Note_Applied_on_Voucher__c> appliedNotes = new List<ERP7__Debit_Note_Applied_on_Voucher__c>();
        List<ERP7__Debit_Note__c> dn2Update = new List<ERP7__Debit_Note__c>();
        Set<Id> debitNotesAdded = new Set<Id>(); // Track debit notes that have been added to dn2Update to prevent duplicates
        List<ERP7__Voucher__c> vouList = (List<ERP7__Voucher__c>) JSON.deserialize(voucherList, List<ERP7__Voucher__c>.class);
        List<ERP7__Voucher__c> vouchersToUpdate = new List<ERP7__Voucher__c>(); // List to batch update vouchers
        ERP7__Payment__c payment = (ERP7__Payment__c) JSON.deserialize(record, ERP7__Payment__c.class);
        system.debug('payment-->'+payment.Id);
        // Initialize cnAmount to 0
        Decimal cnAmount = 0;
        
        // Calculate cnAmount from debit notes
        for (DNWrapper dwrap : dnList) {
            if (dwrap != null && dwrap.debitAmount > 0) {
                cnAmount += dwrap.debitAmount;
            }
        }
        
        // Update payment's amount with cnAmount
        if (Schema.sObjectType.Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.Payment__c.fields.ERP7__Amount__c.isUpdateable()) {
            payment.ERP7__Amount__c = totalAmount - cnAmount;
            payment.ERP7__Debit_Note_Applied_Amount__c = cnAmount;
        }
        
        List<ERP7__Payment_Applied_on_Voucher__c> PAVList = new List<ERP7__Payment_Applied_on_Voucher__c>();
        
        // Apply debit notes and payments to vouchers
        if (cnAmount != null && cnAmount > 0) {
            // Iterate through the vouchers to apply debit notes
            for (ERP7__Voucher__c vou : vouList) {
                Decimal remainingVoucherAmount = vou.ERP7__Amount__c; // Track remaining voucher amount after debit notes are applied
                
                // Iterate through the debit notes and apply them across vouchers
                for (DNWrapper dwrap : dnList) {
                    if (dwrap.debitAmount > 0) { // Only apply debit notes with remaining amount
                        Decimal remainingDebitAmount = dwrap.debitAmount;
                        
                        // Apply debit notes until either the voucher amount or debit note amount is exhausted
                        if (remainingVoucherAmount > 0 && remainingDebitAmount > 0) {
                            Decimal amountToApply = Math.min(remainingDebitAmount, remainingVoucherAmount);
                            
                            // Create Debit Note Applied on Voucher record
                            ERP7__Debit_Note_Applied_on_Voucher__c capplied = new ERP7__Debit_Note_Applied_on_Voucher__c();
                            capplied.ERP7__Amount__c = amountToApply;
                            capplied.ERP7__Debit_Note__c = dwrap.debNote.Id;
                            capplied.ERP7__Voucher__c = vou.Id;
                            capplied.ERP7__Payment__c = payment.Id;//Moin added this 21st october 2024
                            capplied.Name = vou.Name + ' ' + dwrap.debNote.Name;
                            appliedNotes.add(capplied);
                            system.debug('Debit payment-->'+payment.Id);
                            // Update remaining amounts
                            dwrap.debitAmount -= amountToApply;
                            remainingVoucherAmount -= amountToApply;
                            
                            // Update debit note's credit applied field
                            if (dwrap.debNote.ERP7__Credit__c != null) {
                                dwrap.debNote.ERP7__Credit__c += amountToApply;
                            } else {
                                dwrap.debNote.ERP7__Credit__c = amountToApply;
                            }
                            
                            // Update the voucher's credit applied field
                            if (vou.ERP7__Credit_Applied__c != null) {
                                vou.ERP7__Credit_Applied__c += amountToApply;
                            } else {
                                vou.ERP7__Credit_Applied__c = amountToApply;
                            }
                            
                            // Add the debit note to dn2Update if it hasn't been added yet
                            if (!debitNotesAdded.contains(dwrap.debNote.Id)) {
                                debitNotesAdded.add(dwrap.debNote.Id);
                                dn2Update.add(dwrap.debNote);
                            }
                        }
                    }
                }
                
                // After applying debit notes, calculate if there is any remaining voucher amount for payments
                if (remainingVoucherAmount > 0) {
                    ERP7__Payment_Applied_on_Voucher__c PAV = new ERP7__Payment_Applied_on_Voucher__c();
                    PAV.ERP7__Amount__c = remainingVoucherAmount;
                    PAV.ERP7__Payment__c = payment.Id;
                    PAV.ERP7__Voucher__c = vou.Id;
                    PAVList.add(PAV);
                }
                
                // Update the voucher's amount paid field
                if (vou.ERP7__Amount_Paid__c != null) {
                    vou.ERP7__Amount_Paid__c = vou.ERP7__Amount_Paid_Rollup__c + vou.ERP7__Credit_Applied__c;
                }
                
                vouchersToUpdate.add(vou); // Add the voucher to the list for batch update
            }
        } else {
            // Handle case when there are no debit notes applied, only payments
            for (ERP7__Voucher__c vou : vouList) {
                ERP7__Payment_Applied_on_Voucher__c PAV = new ERP7__Payment_Applied_on_Voucher__c();
                if (Schema.sObjectType.ERP7__Payment_Applied_on_Voucher__c.fields.ERP7__Voucher__c.isCreateable()) {
                    PAV.ERP7__Voucher__c = vou.Id;
                }
                if (Schema.sObjectType.ERP7__Payment_Applied_on_Voucher__c.fields.ERP7__Amount__c.isCreateable()) {
                    PAV.ERP7__Amount__c = vou.ERP7__Amount__c;
                }
                PAV.ERP7__Payment__c = payment.Id;
                PAVList.add(PAV);
                
                if (vou.ERP7__Vendor_invoice_Bill__r.RecordType.DeveloperName == 'Advance_to_vendor') {
                    Id rectypId = Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('PrePayments').getRecordTypeId();
                    if (rectypId != null) payment.RecordTypeId = rectypId;
                    payment.ERP7__Pre_Payment__c = true;
                }
            }
        }
        
        
        // Upsert the payment record
        if (Schema.sObjectType.Payment__c.isCreateable() && Schema.sObjectType.Payment__c.isUpdateable()) {
            upsert payment;
        }
        
        // Batch insert debit notes applied
        if (!appliedNotes.isEmpty()) {
            for (ERP7__Debit_Note_Applied_on_Voucher__c dav : appliedNotes) {
                dav.ERP7__Payment__c = payment.Id;
            }
            upsert appliedNotes;
        }
        
        // Batch update debit notes
        if (!dn2Update.isEmpty()) {
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            update dn2Update;
        }
        
        
        
        // Batch insert payment applied on voucher
        if (!PAVList.isEmpty() && Schema.sObjectType.ERP7__Payment_Applied_on_Voucher__c.isCreateable()) {
            for (ERP7__Payment_Applied_on_Voucher__c pav : PAVList) {
                pav.ERP7__Payment__c = payment.Id;
            }
            insert PAVList;
        }
        
        // Batch update the vouchers
        if (!vouchersToUpdate.isEmpty()) {
            PreventRecursiveLedgerEntry.testCasesTransactions = false;
            update vouchersToUpdate;
        }
        
    }
    
    @AuraEnabled
    public static void save_Payment_Multi_Applied(String voucherList, List<DNWrapper> dnList) {
        List<ERP7__Debit_Note_Applied_on_Voucher__c> appliedNotes = new List<ERP7__Debit_Note_Applied_on_Voucher__c>();
        List<ERP7__Debit_Note__c> dn2Update = new List<ERP7__Debit_Note__c>();
        Set<Id> debitNotesAdded = new Set<Id>(); // Track debit notes that have been added to dn2Update to prevent duplicates
        List<ERP7__Voucher__c> vouList = (List<ERP7__Voucher__c>) JSON.deserialize(voucherList, List<ERP7__Voucher__c>.class);
        List<ERP7__Voucher__c> vouchersToUpdate = new List<ERP7__Voucher__c>(); 
        
        // Initialize cnAmount to 0
        Decimal cnAmount = 0;
        
        // Calculate cnAmount from debit notes
        for (DNWrapper dwrap : dnList) {
            if (dwrap != null && dwrap.debitAmount > 0) {
                cnAmount += dwrap.debitAmount;
            }
        }
        // Apply debit notes and payments to vouchers
        if (cnAmount != null && cnAmount > 0) {
            // Iterate through the vouchers to apply debit notes
            for (ERP7__Voucher__c vou : vouList) {
                Decimal remainingVoucherAmount = vou.ERP7__Amount__c; // Track remaining voucher amount after debit notes are applied
                
                // Iterate through the debit notes and apply them across vouchers
                for (DNWrapper dwrap : dnList) {
                    if (dwrap.debitAmount > 0) { // Only apply debit notes with remaining amount
                        Decimal remainingDebitAmount = dwrap.debitAmount;
                        
                        // Apply debit notes until either the voucher amount or debit note amount is exhausted
                        if (remainingVoucherAmount > 0 && remainingDebitAmount > 0) {
                            Decimal amountToApply = Math.min(remainingDebitAmount, remainingVoucherAmount);
                            
                            // Create Debit Note Applied on Voucher record
                            ERP7__Debit_Note_Applied_on_Voucher__c capplied = new ERP7__Debit_Note_Applied_on_Voucher__c();
                            capplied.ERP7__Amount__c = amountToApply;
                            capplied.ERP7__Debit_Note__c = dwrap.debNote.Id;
                            capplied.ERP7__Voucher__c = vou.Id;
                            capplied.Name = vou.Name + ' ' + dwrap.debNote.Name;
                            appliedNotes.add(capplied);
                            
                            // Update remaining amounts
                            dwrap.debitAmount -= amountToApply;
                            remainingVoucherAmount -= amountToApply;
                            
                            // Update debit note's credit applied field
                            if (dwrap.debNote.ERP7__Credit__c != null) {
                                dwrap.debNote.ERP7__Credit__c += amountToApply;
                            } else {
                                dwrap.debNote.ERP7__Credit__c = amountToApply;
                            }
                            
                            // Update the voucher's credit applied field
                            if (vou.ERP7__Credit_Applied__c != null) {
                                vou.ERP7__Credit_Applied__c += amountToApply;
                            } else {
                                vou.ERP7__Credit_Applied__c = amountToApply;
                            }
                            
                            // Add the debit note to dn2Update if it hasn't been added yet
                            if (!debitNotesAdded.contains(dwrap.debNote.Id)) {
                                debitNotesAdded.add(dwrap.debNote.Id);
                                dn2Update.add(dwrap.debNote);
                            }
                        }
                    }
                }
                // Update the voucher's amount paid field
                if (vou.ERP7__Amount_Paid__c != null) {
                    vou.ERP7__Amount_Paid__c = vou.ERP7__Amount_Paid_Rollup__c + vou.ERP7__Credit_Applied__c;
                }
                
                vouchersToUpdate.add(vou); // Add the voucher to the list for batch update
            }
        }
        
        // Batch update the vouchers
        if (!vouchersToUpdate.isEmpty()) {
            update vouchersToUpdate;
        }
        
        // Batch insert debit notes applied
        if (!appliedNotes.isEmpty()) {
            upsert appliedNotes;
        }
        
        // Batch update debit notes
        if (!dn2Update.isEmpty()) {
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            update dn2Update;
        }
        
        
    }






    
    @AuraEnabled 
    public static Wrapper fetchdebitNotes(String accId,String OrgID, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString){
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        String query='SELECT Id,Name, ERP7__Type__c ,ERP7__Amount__c, CreatedDate, ERP7__Debit__c, ERP7__Vendor_Invoice_Bill__c, ERP7__Vendor_Invoice_Bill__r.Name, ERP7__Account__c,ERP7__Account__r.Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name,ERP7__Posted__c, ERP7__Remaining_Amount__c, ERP7__Credit_Note_Date__c    FROM ERP7__Debit_Note__c WHERE ERP7__Remaining_Amount__c>0 AND Name != null AND ERP7__Account__c != NULL AND (ERP7__Account__r.ERP7__Account_Type__c = \'Vendor\' Or ERP7__Account__r.ERP7__Account_Type__c = \'Organisation/Vendor\')';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Vendor_Invoice_Bill__r.Name Like :s OR ERP7__Purchase_Orders__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';//Moin added this on 07th august 2023 to expand the search option 
        //if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if(String.isNotEmpty(accId))query +=' AND ERP7__Account__c IN: ids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by CreatedDate  desc limit 2000 ';
        if(String.isEmpty(OrgID))query += '  order by CreatedDate desc limit 2000 ';
        ar.DebitNotesSL = Database.query(query);
        ar.recSize = ar.DebitNotesSL.size(); 
        query=null;
        query='SELECT Id,Name, ERP7__Type__c ,CreatedDate,ERP7__Amount__c, ERP7__Debit__c, ERP7__Vendor_Invoice_Bill__c, ERP7__Vendor_Invoice_Bill__r.Name, ERP7__Account__c,ERP7__Account__r.Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name,ERP7__Posted__c, ERP7__Remaining_Amount__c,ERP7__Credit_Note_Date__c  FROM ERP7__Debit_Note__c WHERE ERP7__Remaining_Amount__c>0 AND  Name != null AND ERP7__Account__c != NULL AND (ERP7__Account__r.ERP7__Account_Type__c = \'Vendor\'  Or ERP7__Account__r.ERP7__Account_Type__c = \'Organisation/Vendor\')';
        if(searchString!=null && searchString!='')query += ' AND (Name Like :s OR ERP7__Vendor_Invoice_Bill__r.Name Like :s OR ERP7__Purchase_Orders__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';//Moin added this on 07th august 2023 to expand the search option 
        //if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
        if(String.isNotEmpty(accId))query +=' AND ERP7__Account__c IN: ids ';
        if(String.isNotEmpty(OrgID))query += ' AND ERP7__Organisation__c=:OrgID order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
        if(String.isEmpty(OrgID))query += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
        ar.DebitNotes = Database.query(query);
        return ar;
        
        
       /* List<Id> ids = new List<Id>();
        ids = accId.split(',');
        String QryFilter = (String.isNotEmpty(accId))?' AND ERP7__Account__c IN: ids':'';
        QryFilter += (String.isNotEmpty(OrgID))?' AND ERP7__Organisation__c =\''+OrgID+'\'':'';
        List<ERP7__Debit_Note__c> debitNotes = new List<ERP7__Debit_Note__c>();
        debitNotes = Database.query('SELECT Id,Name, ERP7__Type__c ,ERP7__Amount__c, ERP7__Debit__c, ERP7__Vendor_Invoice_Bill__c, ERP7__Vendor_Invoice_Bill__r.Name, ERP7__Account__c,ERP7__Account__r.Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name,ERP7__Posted__c FROM ERP7__Debit_Note__c WHERE Name != null AND ERP7__Account__c != NULL AND ERP7__Account__r.ERP7__Account_Type__c = \'Vendor\''+ QryFilter+' Order By '+OrderBy+' '+ Order);
         Map<Id,ERP7__Debit_Note__c> debitNotesMap = new Map<Id,ERP7__Debit_Note__c>(debitNotes);
        for(ERP7__Transaction__c trans : [SELECT Id, ERP7__Debit_Note__c  , ERP7__Accounting_Period__c  FROM ERP7__Transaction__c WHERE ERP7__Debit_Note__c   IN: debitNotesMap.keySet() AND ERP7__Accounting_Period__c != null AND ERP7__Accounting_Period__r.ERP7__Status__c != 'Open'])
            debitNotesMap.remove(trans.ERP7__Debit_Note__c);
            return debitNotesMap.values();*/
    }
    
    
    @AuraEnabled 
    public static Wrapper fetchcreditNotes(String accId,String OrgID, String OrderBy, String Order,Integer Offset, Integer RecordLimit,String searchString){
        Wrapper ar=new Wrapper();
        String s= '%'+searchString+'%';
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        if(String.isEmpty(orgId)){   
                String CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Amount__c,ERP7__Bill__c, ERP7__Posted__c, ERP7__Purchase_Orders__r.Name, ERP7__Bill__r.Name, ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) AND ERP7__Bill__c != Null ';//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isEmpty(orgId))CreditQuery += '  order by Name  asc limit 2000 ';
                ar.CreditNotes=Database.query(CreditQuery); 
                ar.CreditNotesSL = ar.CreditNotes;
                ar.recSize     =  ar.CreditNotes.size();
                CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Amount__c,ERP7__Bill__c, ERP7__Posted__c, ERP7__Purchase_Orders__r.Name, ERP7__Bill__r.Name, ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) AND ERP7__Bill__c != Null ';//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isEmpty(orgId))CreditQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                ar.CreditNotes=Database.query(CreditQuery);
                return ar;
            }   
            else{
                String CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Amount__c,ERP7__Bill__c, ERP7__Posted__c, ERP7__Purchase_Orders__r.Name, ERP7__Bill__r.Name, ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null)  AND ERP7__Bill__c != Null  AND ERP7__Organisation__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' ';//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))CreditQuery += '  order by Name  asc limit 2000 ';
                ar.CreditNotes=Database.query(CreditQuery); 
                ar.CreditNotesSL = ar.CreditNotes;
                ar.recSize     =  ar.CreditNotes.size();
                CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Amount__c, ERP7__Bill__c, ERP7__Posted__c, ERP7__Purchase_Orders__r.Name, ERP7__Bill__r.Name, ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true  AND ERP7__Bill__c != Null AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) AND ERP7__Organisation__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' ';//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))CreditQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                ar.CreditNotes=Database.query(CreditQuery);
                return ar;
                
            }
        
        
       /* List<Id> ids = new List<Id>();
        ids = accId.split(',');
        String QryFilter = (String.isNotEmpty(accId))?' AND ERP7__Account__c IN: ids':'';
        QryFilter += (String.isNotEmpty(OrgID))?' AND ERP7__Organisation__c =\''+OrgID+'\'':'';
        List<ERP7__Debit_Note__c> debitNotes = new List<ERP7__Debit_Note__c>();
        debitNotes = Database.query('SELECT Id,Name, ERP7__Type__c ,ERP7__Amount__c, ERP7__Debit__c, ERP7__Vendor_Invoice_Bill__c, ERP7__Vendor_Invoice_Bill__r.Name, ERP7__Account__c,ERP7__Account__r.Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name,ERP7__Posted__c FROM ERP7__Debit_Note__c WHERE Name != null AND ERP7__Account__c != NULL AND ERP7__Account__r.ERP7__Account_Type__c = \'Vendor\''+ QryFilter+' Order By '+OrderBy+' '+ Order);
         Map<Id,ERP7__Debit_Note__c> debitNotesMap = new Map<Id,ERP7__Debit_Note__c>(debitNotes);
        for(ERP7__Transaction__c trans : [SELECT Id, ERP7__Debit_Note__c  , ERP7__Accounting_Period__c  FROM ERP7__Transaction__c WHERE ERP7__Debit_Note__c   IN: debitNotesMap.keySet() AND ERP7__Accounting_Period__c != null AND ERP7__Accounting_Period__r.ERP7__Status__c != 'Open'])
            debitNotesMap.remove(trans.ERP7__Debit_Note__c);
            return debitNotesMap.values();*/
    }
    
    @AuraEnabled
    public static List<String> fetch_Polis(String Id){
        List<String> returnList = new List<String>();
        Set<Id> poliIds=new Set<Id>();
        List<ERP7__Purchase_Line_Items__c> updatedPoli=new List<ERP7__Purchase_Line_Items__c>();
        ERP7__PO__c po = [SELECT Id,Name, ERP7__Vendor__c , ERP7__Vendor__r.Id, ERP7__Vendor__r.Name,ERP7__Vendor_Address__c , ERP7__Vendor_Address__r.Id, ERP7__Vendor_Address__r.Name,ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Id, ERP7__Vendor_Contact__r.Name, ERP7__Organisation__c,ERP7__Total_Due__c, toLabel(ERP7__Stage__c)  FROM ERP7__PO__c WHERE Id =: Id];
        returnList.add(JSON.serialize(po)); 
        
        List<ERP7__Purchase_Line_Items__c> polist =  [SELECT Id,ERP7__Quantity_Received__c,Name,ERP7__Product__c,ERP7__Product__r.ERP7__Expense_Account__c,ERP7__Product__r.ERP7__Inventory_Account__c, ERP7__Product__r.Id, ERP7__Product__r.Name,ERP7__Quantity__c,ERP7__Unit_Price__c,ERP7__Total_Price__c, ERP7__Purchase_Orders__c, ERP7__Special_Instruction__c,ERP7__Tax__c  FROM ERP7__Purchase_Line_Items__c Where ERP7__Purchase_Orders__c =:Id];
        //returnList.add(JSON.serialize(polist));
        for(ERP7__Purchase_Line_Items__c p:polist) poliIds.add(p.Id);
        
        List<ERP7__Bill_Line_Item__c> BillItems=new List<ERP7__Bill_Line_Item__c>();
        Map < Id, ERP7__Bill_Line_Item__c > Existing_billItems_Map = new Map < Id, ERP7__Bill_Line_Item__c > ();
        Map < Id, List<ERP7__Bill_Line_Item__c> > Existing_billItem_Map = new Map < Id, List<ERP7__Bill_Line_Item__c> > ();
        for(ERP7__Bill_Line_Item__c billItem:[select id,Name,ERP7__Quantity__c, ERP7__Purchase_Order_Line_Items__c,RecordTypeId,RecordType.DeveloperName from ERP7__Bill_Line_Item__c where ERP7__Purchase_Order_Line_Items__c IN :poliIds AND RecordType.DeveloperName != 'Advance_to_vendor']){
            Existing_billItems_Map.put(billItem.ERP7__Purchase_Order_Line_Items__c, billItem);
            if(Existing_billItem_Map.containskey(billItem.ERP7__Purchase_Order_Line_Items__c)){
                Existing_billItem_Map.get(billItem.ERP7__Purchase_Order_Line_Items__c).add(billItem);
            }else{
                List<ERP7__Bill_Line_Item__c> billItemList = new List<ERP7__Bill_Line_Item__c>();
                billItemList.add(billItem);
                Existing_billItem_Map.put(billItem.ERP7__Purchase_Order_Line_Items__c, billItemList);
            }
        }
        for(ERP7__Purchase_Line_Items__c p:polist){  
            List<ERP7__Bill_Line_Item__c> billItemsList=((Existing_billItem_Map.get(p.Id) != null) ? Existing_billItem_Map.get(p.Id) : null);  
            if(billItemsList==null) updatedPoli.add(p);
            else{
                Decimal BillQuantity = 0;
                for(ERP7__Bill_Line_Item__c bi : billItemsList){
                    if(bi.ERP7__Quantity__c != null){
                        BillQuantity = BillQuantity + bi.ERP7__Quantity__c;
                    }
                } 
                if(BillQuantity != p.ERP7__Quantity__c){
                    updatedPoli.add(p);
                }
            }
        }
        returnList.add(JSON.serialize(updatedPoli)); 
        return returnList;
    }
    
    @AuraEnabled
    public static List<Contact> getContactsByAccId(String Id)
    {
        List<Contact> contacts = [Select Name,ERP7__Primary__c From Contact Where AccountId=:Id];
        return contacts;
    }
    
    @AuraEnabled
    public static ERP7__Discount_Plan__c getPaymentTerms(String CusAccId, Date billDate, Date payDate){
        List<ERP7__Discount_Plan__c> disPlan = new List<ERP7__Discount_Plan__c>();
        system.debug('CusAccId-->'+CusAccId);
        system.debug('billDate-->'+billDate);
        system.debug('payDate-->'+payDate);
        if(CusAccId!=null && billDate!=null){
            Integer daysB = billDate.daysBetween(payDate);
            disPlan = [select Id, ERP7__Vendor__c, ERP7__Due_Date_Days__c, ERP7__Discount_Percent__c from ERP7__Discount_Plan__c where ERP7__Vendor__c =:CusAccId and ERP7__Due_Date_Days__c!= null and ERP7__Discount_Percent__c != null order by ERP7__Due_Date_Days__c asc];
            if(disPlan.size()>0){
                List<String> payTerms = new List<String>();
                for(ERP7__Discount_Plan__c dis : disPlan){
                    //String payT = dis.ERP7__Due_Date_Days__c + ' Days '+dis.ERP7__Discount_Percent__c + ' Percent';
                    //payTerms.add(payT);
                    if(dis.ERP7__Due_Date_Days__c>=daysB){
                        return dis;
                    }
                }
                return null;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static List<String> fetchPaymentTerm(String CusAccId){
        List<ERP7__Discount_Plan__c> disPlan = new List<ERP7__Discount_Plan__c>();
        system.debug('CusAccId-->'+CusAccId);
        if(CusAccId!=null){
            disPlan = [select Id, ERP7__Vendor__c, ERP7__Due_Date_Days__c, ERP7__Discount_Percent__c from ERP7__Discount_Plan__c where ERP7__Vendor__c =:CusAccId and ERP7__Due_Date_Days__c!= null and ERP7__Discount_Percent__c != null order by ERP7__Due_Date_Days__c asc];
            if(disPlan.size()>0){
                List<String> payTerms = new List<String>();
                payTerms.add('--None--');
                for(ERP7__Discount_Plan__c dis : disPlan){
                    //String payT = dis.ERP7__Due_Date_Days__c + ' Days '+dis.ERP7__Discount_Percent__c + ' Percent';
                    String payT = dis.ERP7__Discount_Percent__c + ' %';
                    payTerms.add(payT);
                }
                return payTerms;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    
    
    
    /*
    @AuraEnabled
    public static List<DNWrapper> fetchCreditNote(String CusAccId){
        List<DNWrapper> cnwrap = new List<DNWrapper>();
        system.debug('CusAccId'+CusAccId);
        List<ERP7__Credit_Note__c> cnList = new List<ERP7__Credit_Note__c>();
        if(CusAccId!=null){
            cnList = [select id, Name, ERP7__Credit__c, ERP7__Debit__c,  ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name, ERP7__Account__c, ERP7__Balance__c from ERP7__Credit_Note__c where ERP7__Balance__c>0 and ERP7__Account__c= :CusAccId order by CreatedDate DESC];
            if(cnList.size()>0){
                for(ERP7__Credit_Note__c cc : cnList){
                    DNWrapper cwrap = new DNWrapper();
                    cwrap.credNote = cc;
                    //if(cc.ERP7__Debit__c!=null) cwrap.debitAmount = cc.ERP7__Debit__c;
                    cnwrap.add(cwrap);
                }
            }
            return cnwrap;
        }else{
            return null;
        }
    }
    */
    
   
  @AuraEnabled 
    public static FCvars getFunctionalityControl(){
        FCvars fccontrol = new FCvars();
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){ 
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            fccontrol.Credit_Notes = customList.ERP7__Payable_Credit_Notes__c;
            fccontrol.MultiPO =  customList.ERP7__Show_Multi_PO__c;
            fccontrol.displayCurrency = customList.ERP7__Display_Currency_Symbol_on_AP__c;
            fccontrol.undisplayVoucher = customList.ERP7__Undisplay_Voucher__c;
            fccontrol.undisplayEditVou_Pay = customList.ERP7__Undisplay_Edit_Vou_Pay__c;
            fccontrol.approvalProcess = customList.ERP7__AP_Approval_Process__c;
        }
        return fccontrol;
    }
    
    public class FCvars{
        @AuraEnabled  public Boolean Credit_Notes {get;set;}
        @AuraEnabled  public Boolean MultiPO {get;set;}
        @AuraEnabled  public Boolean displayCurrency {get;set;}
        @AuraEnabled  public Boolean undisplayVoucher {get;set;}
        @AuraEnabled  public Boolean undisplayEditVou_Pay {get;set;}
        @AuraEnabled  public Boolean approvalProcess {get;set;}
        public FCvars(){
            Credit_Notes = approvalProcess = false; MultiPO = false;displayCurrency = false;undisplayVoucher=false;undisplayEditVou_Pay=false;
        }
        
    }
    
    
    @AuraEnabled
    public static void updateInvoiceCreditNotes(List<DNWrapper> dnList, String vou){
        try{
        system.debug('vou-->'+vou);
        system.debug('dnList-->'+dnList);
        List<ERP7__Debit_Note_Applied_on_Voucher__c> appliedNotes = new List<ERP7__Debit_Note_Applied_on_Voucher__c>();
        List<ERP7__Debit_Note__c> dn2Update = new List<ERP7__Debit_Note__c>();
        List<Account> account2Update = new List<Account>();
        ERP7__Voucher__c vouchers = (ERP7__Voucher__c)JSON.deserialize(vou, ERP7__Voucher__c.class);
        PreventRecursiveLedgerEntry.proceed = false;
        update vouchers;
        system.debug('vouchers-->'+vouchers);
        if(dnList!=null && dnList.size()>0) {
            for(DNWrapper dwrap : dnList){
                system.debug('dwrap-->'+dwrap);
                if(dwrap!=null){
                    if(dwrap.debitAmount>0){
                        ERP7__Debit_Note_Applied_on_Voucher__c dapplied = new ERP7__Debit_Note_Applied_on_Voucher__c();
                        dapplied.ERP7__Amount__c = dwrap.debitAmount;
                        dapplied.ERP7__Debit_Note__c = dwrap.debNote.Id;
                        dapplied.ERP7__Voucher__c = vouchers.Id;
                        dapplied.Name = vouchers.Name + ' ' + dwrap.debNote.Name;
                        appliedNotes.add(dapplied);
                        if(dwrap.debNote.ERP7__Credit__c!=null) dwrap.debNote.ERP7__Credit__c = dwrap.debNote.ERP7__Credit__c + dwrap.debitAmount;
                        else dwrap.debNote.ERP7__Credit__c = dwrap.debitAmount;
                        dn2Update.add(dwrap.debNote);
                    }
                }
            }
        }
        if(appliedNotes.size()>0) upsert appliedNotes;
        if(dn2Update.size()>0)  {
                PreventRecursiveLedgerEntry.testCasesTransactions = true;
                update dn2Update;
        }
        if(vouchers!=null){
            if(vouchers.ERP7__Vendor__c !=null){
                Account acc2update = [select Id, Name, ERP7__Debit_Balance__c from Account where Id =:vouchers.ERP7__Vendor__c  ];
                if(acc2update.ERP7__Debit_Balance__c==null) acc2update.ERP7__Debit_Balance__c = vouchers.ERP7__Amount_Paid__c;
                else acc2update.ERP7__Debit_Balance__c = acc2update.ERP7__Debit_Balance__c + vouchers.ERP7__Amount_Paid__c;
                system.debug('acc2update'+acc2update);
                ERP7.PreventRecursiveLedgerEntry.proceed = false;
                update acc2update;
            }
        }
        //if(invList != null) update invList;
        }catch(Exception e){
            system.debug('Exception updateInvoiceCreditNotes-->'+e+e.getLineNumber());
        }
    }
    
    public class DNWrapper{
        @AuraEnabled public ERP7__Debit_Note__c debNote {get;set;}
        @AuraEnabled public Decimal debitAmount {get;set;}
        public DNWrapper(){
            debitAmount = 0.00;
            debNote = new ERP7__Debit_Note__c();
        }
    }
    
    
    
     @AuraEnabled
    public static List<DNWrapper> fetchDebitNote(String CusAccId){
        List<DNWrapper> dnwrap = new List<DNWrapper>();
        system.debug('CusAccId'+CusAccId);
        List<ERP7__Debit_Note__c> dnList = new List<ERP7__Debit_Note__c>();
        if(CusAccId!=null){
            dnList = [select id, Name, ERP7__Credit__c, ERP7__Debit__c, ERP7__Remaining_Amount__c from ERP7__Debit_Note__c where ERP7__Remaining_Amount__c>0 and ERP7__Account__c= :CusAccId order by CreatedDate DESC];
            if(dnList.size()>0){
                for(ERP7__Debit_Note__c db : dnList){
                    DNWrapper dwrap = new DNWrapper();
                    dwrap.debNote = db;
                    //if(cc.ERP7__Debit__c!=null) cwrap.debitAmount = cc.ERP7__Debit__c;
                    dnwrap.add(dwrap);
                }
            }
            return dnwrap;
        }else{
            return null;
        }
    }
    
    public class PayWraper{
        @AuraEnabled
        public ERP7__Payment__c pay {get;set;}
        @AuraEnabled
        public List<ERP7__Payment_Applied_on_Voucher__c> pvou {get;set;}
        PayWraper(){
            pay = new ERP7__Payment__c();
            pvou = new List<ERP7__Payment_Applied_on_Voucher__c>();
        }
    }
    public class wrapper{
        @AuraEnabled
        public String isoCode {get;set;}
        @AuraEnabled     
        public String  currencyType {set;get;}
        @AuraEnabled     
        public ERP7__Chart_of_Accounts__c  coa {set;get;}
        @AuraEnabled     
        public ERP7__Chart_of_Accounts__c  coaConCurrency {set;get;}
        @AuraEnabled     
        public list<Account> acc             {set;get;} 
        @AuraEnabled     
        public list<Account> accSL             {set;get;} 
        @AuraEnabled     
        public integer recSize               {set;get;} 
        @AuraEnabled 
        public list<ERP7__PO__c> PO          {get;set;} 
        @AuraEnabled 
        public list<ERP7__PO__c> POSL          {get;set;} 
        @AuraEnabled 
        public list<ERP7__BILL__c> Bills     {get;set;}
        @AuraEnabled 
        public list<ERP7__BILL__c> BillsSL     {get;set;}
        @AuraEnabled 
        public List<Voucher__c> vouchers     {get;set;}
        @AuraEnabled 
        public List<Voucher__c> vouchersSL     {get;set;}
        @AuraEnabled
        public List<PayWraper> pWrap {get;set;}
        @AuraEnabled 
        public List<ERP7__Payment__c> Payments     {get;set;}
        @AuraEnabled 
        public List<ERP7__Payment__c> PaymentsSL     {get;set;}
        @AuraEnabled 
        public List<ERP7__Debit_Note__c> DebitNotes    {get;set;}
        @AuraEnabled 
        public List<ERP7__Debit_Note__c> DebitNotesSL    {get;set;}
        @AuraEnabled 
        public List<ERP7__Credit_Note__c> CreditNotes    {get;set;}
        @AuraEnabled 
        public List<ERP7__Credit_Note__c> CreditNotesSL    {get;set;}
        public wrapper(){
            pWrap = new List<PayWraper>();
            coa = new ERP7__Chart_of_Accounts__c();
            coaConCurrency = new ERP7__Chart_of_Accounts__c();
            acc = new List<Account>();
            accSL = new List<Account>();
            PO  = new List<ERP7__PO__c>();
            POSL = new List<ERP7__PO__c>(); 
            Bills = new List<ERP7__BILL__c>();
            BillsSL = new List<ERP7__BILL__c>();
            vouchers = new List<Voucher__c>();
            vouchersSL = new List<Voucher__c>();
            Payments = new List<Payment__c>();
            PaymentsSL = new List<Payment__c>();
            DebitNotes = new List<ERP7__Debit_Note__c>();
            DebitNotesSL = new List<ERP7__Debit_Note__c>();
            CreditNotes = new List<ERP7__Credit_Note__c>();
            CreditNotesSL = new List<ERP7__Credit_Note__c>();
        }
        
    } 
}