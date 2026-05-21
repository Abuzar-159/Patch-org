public without sharing class ManageRFP {
    
    public class CustomException extends Exception {}
    
    @AuraEnabled
    public static RFPWrapper fetchAllDetails(String RSId, Boolean isEvaluate){
        try{
            RFPWrapper rfpWrp = new RFPWrapper();
            //get Request Supplier
            if(Schema.sObjectType.ERP7__Request_Supplier__c.isAccessible() && String.isNotEmpty(RSId)) rfpWrp.reqSupplier = [Select ID, Name, ERP7__Request__c, ERP7__Submit_Date__c, ERP7__Supplier__c, ERP7__Is_Submitted__c, ERP7__Is_Approved__c, ERP7__Score__c From ERP7__Request_Supplier__c Where Id =: RSId LIMIT 1];
            ERP7__Request__c emptyObj=new ERP7__Request__c();
            String reqId = '';
            if(rfpWrp.reqSupplier.Id != null){
                if(rfpWrp.reqSupplier.ERP7__Request__c != null){
                    reqId = rfpWrp.reqSupplier.ERP7__Request__c;
                }
            } 
            //get Request.
            if(Schema.sObjectType.ERP7__Request__c.isAccessible()){
                if(String.isNotEmpty(reqId)){
                    rfpWrp.request = [Select Id, Name, ERP7__Description__c, ERP7__Organisation__c, ERP7__Expiry_Date__c, ERP7__Organisation_Business_Unit__c, ERP7__Organisation__r.Name, ERP7__Organisation_Business_Unit__r.Name, ERP7__Channel__r.Name, ERP7__Request_Date__c, ERP7__Response_Due_Date__c,
                                      ERP7__Channel__c, ERP7__Status__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name From ERP7__Request__c Where Id =: reqId Limit 1];
                    
                    // boolean closeCheck = rfpWrp.reqSupplier.ERP7__Is_Submitted__c && (rfpWrp.request.ERP7__Status__c == 'Closed');
                    boolean issubmitted = false; boolean statusclosed = false;
                    if(rfpWrp.reqSupplier.Id != null){
                        issubmitted = rfpWrp.reqSupplier.ERP7__Is_Submitted__c;
                    }
                    if(rfpWrp.request.Id != null){
                        if(String.isNotEmpty(rfpWrp.request.ERP7__Status__c)){
                            if(rfpWrp.request.ERP7__Status__c == 'Closed') statusclosed = true;
                        }
                    }
                    boolean closeCheck = (issubmitted && statusclosed);
                    if(rfpWrp.request.ERP7__Status__c == 'Open' || isEvaluate || closeCheck){
                        //get request contact.
                        if(Schema.sObjectType.ERP7__Request_Contact__c.isAccessible()){    
                            List<ERP7__Request_Contact__c> RFPContacts = [Select Id, Name, ERP7__Contact__c, ERP7__Department__c, ERP7__Email__c, ERP7__Name__c, ERP7__Phone__c, ERP7__Request__c, ERP7__Role__c From Request_Contact__c Where ERP7__Request__c =: reqId];
                            rfpWrp.reqContact = RFPContacts;
                        } 
                        //get request attachments.
                        if(Schema.sObjectType.Attachment.isAccessible()){
                            List<ContentDocumentLink> RFPAttachments = [SELECT Id, LinkedEntityId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: reqId];
                            rfpWrp.rfpAttact = RFPAttachments;
                            System.debug('Id:'+ reqId);
                            System.debug('Attachments:'+ RFPAttachments);
                        }
                        //get request FAQ Assignments.
                        set<Id> faqAssignIds = new set<Id>();
                        if(Schema.sObjectType.ERP7__FAQ_Assignment__c.isAccessible()){
                            List<ERP7__FAQ_Assignment__c> RFPFAQs = [Select Id, Name, ERP7__FAQ__c, ERP7__Question__c, ERP7__FAQ__r.Answer__c, ERP7__Request__c From ERP7__FAQ_Assignment__c Where ERP7__Request__c =: reqId];
                            for(ERP7__FAQ_Assignment__c FAQA: RFPFAQs){
                                faqAssignIds.add(FAQA.ERP7__FAQ__c);
                            }
                            rfpWrp.FAQAssigns = RFPFAQs;
                        }
                        if(Schema.sObjectType.ERP7__FAQ__c.isAccessible()){
                            List<ERP7__FAQ__c> FAQss = [Select Id, Name, ERP7__Question__c, ERP7__Answer__c From ERP7__FAQ__c Where Id IN: faqAssignIds];
                            rfpWrp.FAQs = FAQss;
                        }
                        
                        //get request Requirement & responses.
                        List<ERP7__Requirement__c> RFPReqs = new List<ERP7__Requirement__c>();
                        List<ERP7__Response__c> RFPRess = new List<ERP7__Response__c>();
                        Map<Id, List<Response__c>> reqResponses = new Map<Id, List<Response__c>>();
                        Map<Id,Attachment> resAttachment = new Map<Id,Attachment>();
                        List<requirementWrappers> reqWrapperLists = new List<requirementWrappers>();
                        if(Schema.sObjectType.ERP7__Requirement__c.isAccessible()){
                            RFPReqs = [Select Id, Name, ERP7__Answer_Required__c, ERP7__Depricated__c, ERP7__Parent_Requirement__c, ERP7__Question__c, ERP7__Responses__c, ERP7__Request__c, ERP7__Request_Plan__c, 
                                       ERP7__RFPS_Plan_Requirement__c, ERP7__Upload_Required__c, RecordTypeId, RecordType.Name, ERP7__Multiple_Responses_Required__c, ERP7__Section__c, ERP7__Sub_Section__c, ERP7__Section__r.name, ERP7__Sub_Section__r.Name
                                       From ERP7__Requirement__c
                                       Where ERP7__Request__c =: reqId 
                                       Order by ERP7__Sort__c, ERP7__Section__r.name, ERP7__Sub_Section__r.Name, CreatedDate ASC];
                            
                            List<responseWrapper> RFPResponses = new List<responseWrapper>();
                            if(Schema.sObjectType.ERP7__Response__c.isAccessible()) {
                                if(String.isNotEmpty(RSId) && String.isNotEmpty(reqId)){
                                    RFPRess = [Select Id, Name, ERP7__Response_Answer__c, ERP7__Upload_Required__c, ERP7__Request_Supplier__c, ERP7__Question__c, ERP7__Requirement__c, ERP7__Request__c, ERP7__Manufacturing_Order__c, ERP7__Score__c, ERP7__Supplier__c, ERP7__Supplier_Compliancy__c,
                                               ERP7__Supplier_Rating__c, ERP7__Actual_Compliancy__c, ERP7__Actual_Rating__c                       
                                               From ERP7__Response__c
                                               Where ERP7__Request__c =: reqId And
                                               ERP7__Request_Supplier__c =: RSId ORDER BY CreatedDate ASC];
                                }
                                rfpWrp.RFPResslength = RFPRess.size();
                                for(Requirement__c Rq : RFPReqs){
                                    List<Response__c> myRes = new List<Response__c>();
                                    for(Response__c Rs : RFPRess){
                                        if(Rs.Requirement__c != null){
                                            if(Rs.Requirement__c == Rq.Id){
                                                myRes.add(Rs);
                                            }
                                        } 
                                    }
                                    reqResponses.put(Rq.Id, myRes);
                                }
                                
                                set<Id> resIds = new set<Id>();
                                for(Response__c Res : RFPRess){
                                    resIds.add(Res.Id);
                                }
                                
                                if(Schema.sObjectType.Attachment.isAccessible()) 
                                    for(Attachment att : [Select Id, Name, ParentId, CreatedDate From Attachment Where ParentId In : resIds]){
                                        resAttachment.put(att.ParentId, att);
                                    }
                            }
                            if(RFPReqs.size() > 0){
                                for(ERP7__Requirement__c pReq : RFPReqs){
                                    if(pReq.RecordType.Name == 'Request_Requirement'){
                                        requirementWrappers pReqWrap = new requirementWrappers();
                                        if(pReq.ERP7__Parent_Requirement__c == null){
                                            pReqWrap.Req = pReq;
                                            List<responseWrapper> RPWList = new List<responseWrapper>();
                                            List<ERP7__Response__c> myRes = new List<ERP7__Response__c>();
                                            if(reqResponses.containsKey(pReq.Id)) myRes = reqResponses.get(pReq.Id); else system.debug('map reqResponses not contains');
                                            for(Response__c Res : myRes){
                                                responseWrapper RPW = new responseWrapper();
                                                RPW.Res = Res;
                                                RPW.Att = resAttachment.containsKey(Res.Id)? resAttachment.get(Res.Id) : new Attachment();
                                                RPWList.add(RPW);
                                            }
                                            pReqWrap.ResPackList = RPWList;
                                            
                                            List<requirementWrappers> myChildReqs = new List<requirementWrappers>();
                                            for(Requirement__c cReq : RFPReqs){
                                                if(cReq.Parent_Requirement__c == pReq.Id){
                                                    requirementWrappers cReqWrap = new requirementWrappers();
                                                    cReqWrap.Req = cReq;
                                                    
                                                    List<responseWrapper> cRPWList = new List<responseWrapper>();
                                                    List<Response__c> cMyRes = reqResponses.get(cReq.Id);
                                                    for(Response__c Res : cMyRes){
                                                        responseWrapper RPW = new responseWrapper();
                                                        RPW.Res = Res;
                                                        RPW.Att = resAttachment.containsKey(Res.Id)? resAttachment.get(Res.Id) : new Attachment();
                                                        cRPWList.add(RPW);
                                                    }
                                                    cReqWrap.ResPackList = cRPWList;
                                                    myChildReqs.add(cReqWrap);
                                                }
                                            }  
                                            pReqWrap.childReqs = myChildReqs;
                                            reqWrapperLists.add(pReqWrap);
                                        }
                                        else system.debug('pReq.ERP7__Parent_Requirement__c not null');
                                    }
                                    else system.debug('recordtype not Request_Requirement');
                                }
                                rfpWrp.rfpRequirements = reqWrapperLists;
                            }
                        }
                    }
                    else {
                        if(rfpWrp.request.ERP7__Status__c == 'Review')
                            rfpWrp.errorMsg = rfpWrp.request.Name + ' is in Review. Currently responses cannot be added.';
                        else
                            rfpWrp.errorMsg = rfpWrp.request.Name + ' is '+ rfpWrp.request.ERP7__Status__c+ '. Responses can no longer be added.';
                    }
                }
            }
            return rfpWrp;
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static RFPWrapper fetchAllSupDetails(String reqId){
        RFPWrapper rfpWrp = new RFPWrapper();
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC != null){ 
             rfpWrp.showReceive = FC.ERP7__Show_Receive_on_PO__c; 
} 
 
        List<ERP7__Request_Supplier__c> allSuppliers = new List<ERP7__Request_Supplier__c>();
        List<ERP7__Response__c> RFPRess = new List<ERP7__Response__c>();
        if(Schema.sObjectType.ERP7__Request__c.isAccessible()){
            rfpWrp.request = [Select Id, Name, ERP7__Description__c, ERP7__Organisation__c, ERP7__Expiry_Date__c, 
                              ERP7__Organisation_Business_Unit__c, ERP7__Organisation__r.Name, ERP7__Product__c,
                              ERP7__Organisation_Business_Unit__r.Name, ERP7__Channel__r.Name, 
                              ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name,
                              ERP7__Request_Date__c, ERP7__Response_Due_Date__c, ERP7__Channel__c, ERP7__Status__c 
                              From ERP7__Request__c Where Id =: reqId AND ERP7__Status__c = 'Open' Limit 1];
            
            ERP7__Request__c emptyObj = new ERP7__Request__c();
            if(rfpWrp.request != emptyObj){
                if(Schema.sObjectType.ERP7__Request_Supplier__c.isAccessible()){
                    allSuppliers = [Select Id, Name, ERP7__Request__c, ERP7__Submit_Date__c, ERP7__Supplier__c, 
                                    ERP7__Supplier__r.Name, ERP7__Is_Submitted__c, ERP7__Is_Approved__c, ERP7__Score__c 
                                    From ERP7__Request_Supplier__c Where ERP7__Is_Submitted__c = true AND 
                                    ERP7__Request__c =: reqId Order By ERP7__Score__c DESC];
                    set<Id> supIds = new set<Id>();
                    for(ERP7__Request_Supplier__c sp: allSuppliers) supIds.add(sp.Id);
                    
                    if(Schema.sObjectType.ERP7__Response__c.isAccessible() && supIds.size() > 0){
                        RFPRess = [Select Id, Name, ERP7__Request_Supplier__c, ERP7__Request__c, ERP7__Score__c,
                                   ERP7__Actual_Compliancy__c, ERP7__Actual_Rating__c                       
                                   From ERP7__Response__c
                                   Where ERP7__Request__c =: reqId And ERP7__Request_Supplier__c IN: supIds
                                   ORDER BY CreatedDate ASC];
                        for(ERP7__Request_Supplier__c sp : allSuppliers){
                            List<ERP7__Response__c> resL = new List<ERP7__Response__c>();
                            for(ERP7__Response__c res: RFPRess){
                                if(res.ERP7__Request_Supplier__c == sp.Id) resL.add(res);
                            }
                            supRFPWrapper supplierWP = new supRFPWrapper();
                            supplierWP.supplier = sp;
                            if(resL.size() > 0) supplierWP.supResList = resL;
                            rfpWrp.supplierList.add(supplierWP);
                        }
                    }
                }
            }
            else{/*'EMPTY REQUEST...');*/ }
        }
        return rfpWrp;
    }
    
    @AuraEnabled
    public static String delete_Response(String responseId){
        ERP7__Response__c res = [SELECT Id FROM ERP7__Response__c WHERE Id =: responseId];
        if(ERP7__Response__c.sObjectType.getDescribe().isDeletable()) delete res;
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static List<ERP7__Response__c> save_reqResponses(String allRess, Boolean isSubmit, String rfpSupp){
        try{
            List<ERP7__Response__c> allRFPResponses = new List<ERP7__Response__c>();
            allRFPResponses = (List<ERP7__Response__c>) JSON.deserialize(allRess, List<ERP7__Response__c>.class);
            if(allRFPResponses.size() > 0){
                if(Schema.SObjectType.ERP7__Response__c.isCreateable() && Schema.SObjectType.ERP7__Response__c.isUpdateable()) upsert allRFPResponses; 
                else throw new CustomException('No Access to upsert Response'); 
            }else throw new CustomException('Responses Empty'); 
            if(isSubmit){
                ERP7__Request_Supplier__c RFPSupplier = (ERP7__Request_Supplier__c) JSON.deserialize(rfpSupp, ERP7__Request_Supplier__c.class);
                if(Schema.sObjectType.ERP7__Request_Supplier__c.fields.ERP7__Is_Submitted__c.isCreateable() && Schema.sObjectType.ERP7__Request_Supplier__c.fields.ERP7__Is_Submitted__c.isUpdateable()){RFPSupplier.ERP7__Submit_Date__c = system.today();}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Request_Supplier__c.fields.ERP7__Submit_Date__c.isCreateable() && Schema.sObjectType.ERP7__Request_Supplier__c.fields.ERP7__Submit_Date__c.isUpdateable()){RFPSupplier.ERP7__Is_Submitted__c = true;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Request_Supplier__c.isCreateable() && Schema.sObjectType.ERP7__Request_Supplier__c.isUpdateable()){
                    upsert RFPSupplier;
                }else{
                    throw new CustomException('No Access to upsert Request Supplier');
                }
            }else system.debug('isSubmit false');
            return allRFPResponses;
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    @AuraEnabled
    public static String uploadFile(String parent, String fileName, String base64Data, String contentType) { 
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        //Attachment a = new Attachment();
        //if(Schema.SObjectType.Attachment.fields.parentId.isCreateable()){a.parentId = parent;}else{/*No access*/}
        //if(Schema.SObjectType.Attachment.fields.Body.isCreateable()){a.Body = EncodingUtil.base64Decode(base64Data);}else{/*No access*/}
        //if(Schema.SObjectType.Attachment.fields.Name.isCreateable()){a.Name = fileName;}else{/*No access*/}
        //if(Schema.SObjectType.Attachment.fields.ContentType.isCreateable()){a.ContentType = contentType; }else{/*No access*/}
        //if(Schema.SObjectType.Attachment.isCreateable()) insert a;
        //return 'SUCCESS';      
        system.debug('uploadFile-->');
        try{  base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');  Attachment a = new Attachment();  a.parentId = parent; a.Body = EncodingUtil.base64Decode(base64Data);  a.Name = fileName; a.ContentType = contentType; if(Schema.SObjectType.Attachment.isCreateable()){ system.debug('Attachment-->'+a); insert a; } else{ } return 'Success'; } catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber()); String exc=Json.serialize(e); return exc; }
          
    }
    
    @AuraEnabled
    public static String DeleteAT(String RAId, String ObjName){   
        Attachment responseAT = [select Id from Attachment Where Id =:RAId];
        if(Attachment.sObjectType.getDescribe().isDeletable()) delete responseAT;
        return 'SUCCESS';
    }
    
    @AuraEnabled
    public static List<ERP7__FAQ__c> fetchFAQs(String FAQList, String searchStr){
        if(searchStr != null && searchStr != '') searchStr = '%'+searchStr+'%';
        List<ERP7__FAQ__c> allFAQs = (List<ERP7__FAQ__c>) JSON.deserialize(FAQList, List<ERP7__FAQ__c>.class);
        set<Id> FAQIds = new set<Id>();
        for(ERP7__FAQ__c FAQ: allFAQs){
            FAQIds.add(FAQ.Id);
        }
        if(Schema.sObjectType.ERP7__FAQ__c.isAccessible()){
            allFAQs = [Select Id, ERP7__Question__c, ERP7__Answer__c From ERP7__FAQ__c Where ERP7__Question__c LIKE:searchStr AND Id IN: FAQIds ORDER BY CreatedDate Asc LIMIT 500];
        }
        return allFAQs;
    }
    
    @AuraEnabled
    public static List < SelectOptions > fetchSupRating() {
        List<SelectOptions> ratingOpts = new List<SelectOptions>();
        ratingOpts.add(new SelectOptions('--None--','--None--',true));
        try{
            system.debug('ERP7__Supplier_Rating__c accessible~>'+Schema.SObjectType.ERP7__Response__c.fields.ERP7__Supplier_Rating__c.isAccessible()+' creatable~>'+Schema.SObjectType.ERP7__Response__c.fields.ERP7__Supplier_Rating__c.isCreateable()+'updateable~>'+Schema.SObjectType.ERP7__Response__c.fields.ERP7__Supplier_Rating__c.isUpdateable());
            Schema.DescribeFieldResult fieldResult = ERP7__Response__c.ERP7__Supplier_Rating__c.getDescribe();
            system.debug('ERP7__Supplier_Rating__c fieldResult isAccessible~>'+fieldResult.isAccessible());
            system.debug('ERP7__Supplier_Rating__c fieldResult isWriteRequiresMasterRead~>'+fieldResult.isWriteRequiresMasterRead());
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
             System.debug('ERP7__Supplier_Rating__c ple size~>'+ple.size());
            for (Schema.PicklistEntry f: ple) {
                ratingOpts.add(new SelectOptions(f.getValue(), f.getLabel(), false));
            }
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
        return ratingOpts;
    }
    
    @AuraEnabled
    public static List < SelectOptions > fetchSupCompliance() {
        List<SelectOptions> compOpts = new List<SelectOptions>();
        compOpts.add(new SelectOptions('--None--','--None--',true));
        try{
            system.debug('ERP7__Supplier_Compliancy__c accessible~>'+Schema.SObjectType.ERP7__Response__c.fields.ERP7__Supplier_Compliancy__c.isAccessible()+' creatable~>'+Schema.SObjectType.ERP7__Response__c.fields.ERP7__Supplier_Compliancy__c.isCreateable()+'updateable~>'+Schema.SObjectType.ERP7__Response__c.fields.ERP7__Supplier_Compliancy__c.isUpdateable());
            Schema.DescribeFieldResult fieldResult = ERP7__Response__c.ERP7__Supplier_Compliancy__c.getDescribe();
            system.debug('ERP7__Supplier_Compliancy__c fieldResult isAccessible~>'+fieldResult.isAccessible());
            system.debug('ERP7__Supplier_Compliancy__c fieldResult isWriteRequiresMasterRead~>'+fieldResult.isWriteRequiresMasterRead());
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            System.debug('ERP7__Supplier_Compliancy__c ple size~>'+ple.size());
            for (Schema.PicklistEntry f: ple) {
                compOpts.add(new SelectOptions(f.getValue(), f.getLabel(), false));
            }
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
        return compOpts;
    }
    
    @AuraEnabled
    public static List < SelectOptions > fetchRating() {
        List<SelectOptions> ratingOpts = new List<SelectOptions>();
        ratingOpts.add(new SelectOptions('--None--','--None--',true));
        Schema.DescribeFieldResult fieldResult = ERP7__Response__c.ERP7__Actual_Rating__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            ratingOpts.add(new SelectOptions(f.getValue(), f.getLabel(), false));
        }
        return ratingOpts;
    }
    
    @AuraEnabled
    public static List < SelectOptions > fetchCompliance() {
        List<SelectOptions> compOpts = new List<SelectOptions>();
        compOpts.add(new SelectOptions('--None--','--None--',true));
        Schema.DescribeFieldResult fieldResult = ERP7__Response__c.ERP7__Actual_Compliancy__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            compOpts.add(new SelectOptions(f.getValue(), f.getLabel(), false));
        }
        return compOpts;
    }
    
    
    public class responseWrapper{
        @AuraEnabled public ERP7__Response__c Res                                   { get; set; }
        @AuraEnabled public Attachment Att                                          { get; set; }
    }
    
    public class requirementWrappers {
        @AuraEnabled public ERP7__Requirement__c Req                                { get; set; }
        @AuraEnabled public List<responseWrapper> ResPackList                       { get; set; }
        @AuraEnabled public List<requirementWrappers> childReqs                     { get; set; }
        @AuraEnabled public boolean isCurrentReq                                    { get; set; }
        
        public requirementWrappers(){
            Req = new ERP7__Requirement__c();
            ResPackList = new List<responseWrapper>();
            childReqs = new List<requirementWrappers>();
            isCurrentReq = false;
        }
    }
    
    public class RFPWrapper{
        @AuraEnabled public ERP7__Request_Supplier__c reqSupplier                   { get; set; }
        @AuraEnabled public ERP7__Request__c request                                { get; set; }
        @AuraEnabled public List<ERP7__Request_Contact__c> reqContact               { get; set; }
        @AuraEnabled public List<ContentDocumentLink> rfpAttact                              { get; set; }
        @AuraEnabled public List<ERP7__FAQ_Assignment__c> FAQAssigns                { get; set; }
        @AuraEnabled public List<ERP7__FAQ__c> FAQs                                 { get; set; }
        @AuraEnabled public List<requirementWrappers> rfpRequirements               { get; set; }
        @AuraEnabled public List<supRFPWrapper> supplierList                        { get; set; }
        @AuraEnabled public String errorMsg                                         { get; set; }
        @AuraEnabled public Integer RFPResslength                                         { get; set; }
        @AuraEnabled public Boolean showReceive                                         { get; set; }
        public RFPWrapper(){
            request = new ERP7__Request__c();
            reqContact = new List<ERP7__Request_Contact__c>();
            rfpAttact = new List<ContentDocumentLink>(); 
            rfpRequirements = new List<requirementWrappers>();
            supplierList = new List<supRFPWrapper>();
            errorMsg = '';
            RFPResslength = 0;
            showReceive = false;
        }
    }
    
    public class supRFPWrapper{
        @AuraEnabled public ERP7__Request_Supplier__c supplier                      { get; set; }
        @AuraEnabled public List<ERP7__Response__c> supResList                      { get; set; }
        @AuraEnabled public Decimal avgScore                                        { get; set; }
        @AuraEnabled public Decimal avgRating                                       { get; set; }
        
        public supRFPWrapper(){
            Supplier = new ERP7__Request_Supplier__c();
            supResList = new List<ERP7__Response__c>();
            avgScore = 0.00;
            avgRating = 0.00;
        }
    }
    
    public class SelectOptions {
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public SelectOptions(String val, string lab, Boolean sel) {
            value = val;
            label = lab;
            selected = sel;
        }
    }
    
}