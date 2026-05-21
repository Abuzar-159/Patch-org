public without sharing class ManageSupplierRFP {
    
    public class CustomException extends Exception {}
    
    @AuraEnabled
    public static RFPWrapper fetchAllDetails(String vendorId, String SearchStr, Integer rfpOffset, Integer RecordLimit, String rfpStatus){//, String sortField, String sortOrder
        RFPWrapper rfpWrp = new RFPWrapper(RecordLimit);
        try{
            List<ERP7__Request_Supplier__c>  suppList = new List<ERP7__Request_Supplier__c>();
            List<ERP7__Request__c> reqList = new List<ERP7__Request__c>();
            ERP7__Request__c emptyReq = new ERP7__Request__c();
            List<SuppWrapper> reqSuppliersSize = new List<SuppWrapper>();
            if(searchStr != null && searchStr != '') searchStr = '%'+searchStr+'%';
            Date currentDay = system.today();
            Integer countRS = 0;
            
            if(String.isEmpty(vendorId)){
                List<Account> accs = new List<Account>();
                String userId = userinfo.getUserId();
                User usr = [Select Id, Name, CommunityNickname,ContactId from User where id =:userId and IsActive=true Limit 1];
                List<Contact> conList = [Select Id, Name,AccountId from Contact where Id=:usr.ContactId Limit 1];
                if(conList.size()>0){
                    if(conList[0].AccountId != null) accs = [Select Id, Name from Account where Id =:conList[0].AccountId Limit 1];
                } 
                if(accs.size()>0){
                    vendorId = accs[0].Id;
                }
            }
            
            if(Schema.sObjectType.Account.isAccessible()){
                if(String.isNotEmpty(vendorId)){
                    rfpWrp.vendor = [SELECT Id, Name FROM Account Where Id =: vendorId LIMIT 1];
                    if(Schema.sObjectType.ERP7__Request_Supplier__c.isAccessible()){
                        String suppListQuery = 'SELECT Name, ERP7__Request__c, ERP7__Request__r.ERP7__Status__c, ERP7__Is_Submitted__c FROM ERP7__Request_Supplier__c';
                        suppListQuery += ' WHERE ERP7__Supplier__c =: vendorId AND ERP7__Request__c != null AND';
                        suppListQuery += ' ERP7__Request__r.ERP7__Expiry_Date__c >=: currentDay';
                        suppListQuery += ' ORDER BY ERP7__Request__r.ERP7__Response_Due_Date__c ASC';
                        suppList = Database.query(suppListQuery);
                        set<Id> reqIds = new set<Id>();
                        
                        for(ERP7__Request_Supplier__c resup : suppList){
                            reqIds.add(resup.ERP7__Request__c);
                            if(resup.ERP7__Request__r.ERP7__Status__c == 'Review') rfpWrp.reviewCount += 1;
                            if(resup.ERP7__Request__r.ERP7__Status__c == 'Open') rfpWrp.openCount += 1;
                            if(resup.ERP7__Request__r.ERP7__Status__c == 'Closed') rfpWrp.closeCount += 1;
                            if(resup.ERP7__Request__r.ERP7__Status__c == 'Cancelled') rfpWrp.cancelCount += 1;
                        }
                        if(Schema.sObjectType.ERP7__Request__c.isAccessible()){
                            String RFPQuery = 'SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.Name,';
                            RFPQuery += ' ERP7__Expiry_Date__c, ERP7__Request_Date__c, ERP7__Response_Due_Date__c, ';
                            RFPQuery += ' ERP7__Organisation__c, ERP7__Organisation__r.Name, ';
                            RFPQuery += ' ERP7__Channel__r.Name,  ERP7__Channel__c, ERP7__Status__c ';
                            RFPQuery += ' FROM ERP7__Request__c WHERE Id IN: reqIds AND ERP7__Expiry_Date__c >=: currentDay ';
                            if(searchStr != null && searchStr != '') RFPQuery += ' AND (Name LIKE: searchStr OR ERP7__Product__r.Name LIKE: searchStr)';
                            if(rfpStatus != 'All' && rfpStatus != '') RFPQuery += ' AND ERP7__Status__c =: rfpStatus';
                            RFPQuery += ' ORDER BY ERP7__Response_Due_Date__c ASC';
                            reqList = Database.query(RFPQuery);
                            
                            for(ERP7__Request_Supplier__c resup : suppList){
                                SuppWrapper ReqandSup = new SuppWrapper();
                                for(ERP7__Request__c req1 : reqList){
                                    ReqandSup.reqSupplier = resup;
                                    if(req1.Id == resup.ERP7__Request__c){
                                        ReqandSup.request = req1;
                                        break;
                                    }
                                }
                                if(ReqandSup.request != emptyReq){
                                    reqSuppliersSize.add(ReqandSup);
                                    if(countRS < (rfpOffset+RecordLimit) && countRS >= rfpOffset) {
                                        rfpWrp.reqSuppliers.add(ReqandSup);
                                    }
                                    countRS++;
                                }
                            }
                            rfpWrp.recSize = reqSuppliersSize.size();
                        }
                        else throw new customException('No Access to Request');
                    }
                    else throw new customException('No Access to Request Supplier');
                }else throw new customException('No Vendor Account found');
            }else throw new customException('No Access to Account');
            
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
        return rfpWrp;
    }
    
    @AuraEnabled
    public static List<requestPWrap> fetchPublicReqs(String SearchStr,String reqs){
        List<requestPWrap> reqPublicList = new List<requestPWrap>();
        List<SuppWrapper> reqSups = new List<SuppWrapper>();
        List<String> reqIds = new List<String>();
        if(String.isNotEmpty(reqs)){
            reqSups = (List<SuppWrapper>) JSON.deserialize(reqs, List<SuppWrapper>.class);
            for(SuppWrapper ReqandSup : reqSups){
                if(ReqandSup.request.Id != null){
                    reqIds.add(ReqandSup.request.Id);
                }
            }
        }
        
        try{
            if(String.isNotEmpty(SearchStr) && String.isNotBlank(SearchStr)) SearchStr = '%'+SearchStr+'%';
            List<ERP7__Request__c> reqList = new List<ERP7__Request__c>();
            Date currentDay = system.today();
            if(Schema.sObjectType.ERP7__Request__c.isAccessible()){
                if(searchStr != null && searchStr != ''){
                    if(reqIds.size() > 0){
                        reqList = [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.Name, 
                                   ERP7__Expiry_Date__c, ERP7__Request_Date__c, ERP7__Response_Due_Date__c, 
                                   ERP7__Organisation__c, ERP7__Organisation__r.Name, 
                                   ERP7__Channel__r.Name,  ERP7__Channel__c, ERP7__Status__c 
                                   FROM ERP7__Request__c WHERE ERP7__Private__c = false AND 
                                   ERP7__Expiry_Date__c >=: currentDay AND Id NOT IN : reqIds AND 
                                   ERP7__Status__c != 'Closed' AND ERP7__Status__c != 'Cancelled' AND 
                                   (Name LIKE: searchStr OR ERP7__Product__r.Name LIKE: searchStr)
                                   ORDER BY ERP7__Response_Due_Date__c ASC];
                    }else{
                        reqList = [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.Name, 
                                   ERP7__Expiry_Date__c, ERP7__Request_Date__c, ERP7__Response_Due_Date__c, 
                                   ERP7__Organisation__c, ERP7__Organisation__r.Name, 
                                   ERP7__Channel__r.Name,  ERP7__Channel__c, ERP7__Status__c 
                                   FROM ERP7__Request__c WHERE ERP7__Private__c = false AND 
                                   ERP7__Expiry_Date__c >=: currentDay AND Id NOT IN : reqIds AND 
                                   ERP7__Status__c != 'Closed' AND ERP7__Status__c != 'Cancelled' AND 
                                   (Name LIKE: searchStr OR ERP7__Product__r.Name LIKE: searchStr)
                                   ORDER BY ERP7__Response_Due_Date__c ASC];
                    }
                }
                else{
                    if(reqIds.size() > 0){
                        reqList = [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.Name, 
                                   ERP7__Expiry_Date__c, ERP7__Request_Date__c, ERP7__Response_Due_Date__c, 
                                   ERP7__Organisation__c, ERP7__Organisation__r.Name, 
                                   ERP7__Channel__r.Name,  ERP7__Channel__c, ERP7__Status__c 
                                   FROM ERP7__Request__c WHERE ERP7__Private__c = false AND
                                   ERP7__Expiry_Date__c >=: currentDay AND Id NOT IN : reqIds AND 
                                   ERP7__Status__c != 'Closed' AND ERP7__Status__c != 'Cancelled'
                                   ORDER BY ERP7__Response_Due_Date__c ASC];
                    }else{
                        reqList = [SELECT Id, Name, ERP7__Product__c, ERP7__Product__r.Name, 
                                   ERP7__Expiry_Date__c, ERP7__Request_Date__c, ERP7__Response_Due_Date__c, 
                                   ERP7__Organisation__c, ERP7__Organisation__r.Name, 
                                   ERP7__Channel__r.Name,  ERP7__Channel__c, ERP7__Status__c 
                                   FROM ERP7__Request__c WHERE ERP7__Private__c = false AND
                                   ERP7__Expiry_Date__c >=: currentDay AND
                                   ERP7__Status__c != 'Closed' AND ERP7__Status__c != 'Cancelled'
                                   ORDER BY ERP7__Response_Due_Date__c ASC];
                    }
                }
                for(ERP7__Request__c req : reqList){
                    reqPublicList.add(new requestPWrap(req));
                }
            }
            
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        } 
        return reqPublicList;
    }
    
    @AuraEnabled
    public static void applyForRFPs(String requestsToApply, String vendorId){
        try{
            List<ERP7__Request__c> allRFPApplications = (List<ERP7__Request__c>) JSON.deserialize(requestsToApply, List<ERP7__Request__c>.class);
            List<ERP7__Request_Supplier__c> newReqSuppliers = new List<ERP7__Request_Supplier__c>();
            for(ERP7__Request__c req : allRFPApplications){
                ERP7__Request_Supplier__c reqSup = new ERP7__Request_Supplier__c();
                if(Schema.sObjectType.ERP7__Request_Supplier__c.fields.ERP7__Request__c.isCreateable()){ reqSup.ERP7__Request__c = req.Id; }else{/*No access*/}
                if(Schema.sObjectType.ERP7__Request_Supplier__c.fields.ERP7__Supplier__c.isCreateable() && String.isNotEmpty(vendorId)){ reqSup.ERP7__Supplier__c = vendorId; }else{/*No access*/}
                newReqSuppliers.add(reqSup);
            }
            if(Schema.SObjectType.ERP7__Request_Supplier__c.isCreateable()){ insert newReqSuppliers; }else{ /*No access*/ }
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        } 
    }
    
    public class RFPWrapper{
        @AuraEnabled public Account vendor                                          { get; set; }
        @AuraEnabled public List<SuppWrapper> reqSuppliers                          { get; set; }
        @AuraEnabled public Integer reviewCount                                     { get; set; }
        @AuraEnabled public Integer openCount                                       { get; set; }
        @AuraEnabled public Integer closeCount                                      { get; set; }
        @AuraEnabled public Integer cancelCount                                     { get; set; }
        
        @AuraEnabled public List<Integer> PNS                                        { get; set; }
        @AuraEnabled public Integer recSize                                          { get; set; }
        @AuraEnabled public Integer PageNum                                          { get; set; }
        
        public RFPWrapper(Integer total){
            vendor = new Account();
            reqSuppliers = new List<SuppWrapper>();
            reviewCount = 0;
            openCount = 0;
            closeCount = 0;
            cancelCount = 0;
            
            PNS = new List<Integer>();
            recSize = total;
            PageNum = 0;
        }
    }
    
    public class SuppWrapper{
        @AuraEnabled public ERP7__Request_Supplier__c reqSupplier                   { get; set; }
        @AuraEnabled public ERP7__Request__c request                                { get; set; }
        public SuppWrapper(){
            reqSupplier = new ERP7__Request_Supplier__c();
            request = new ERP7__Request__c();
        }
    }
    
    public class requestPWrap{
        @AuraEnabled public ERP7__Request__c request                                { get; set; }
        @AuraEnabled public boolean selected                                        { get; set; }
        public requestPWrap(ERP7__Request__c rq){
            request = rq;
            selected = false;
        }
    }
    
}