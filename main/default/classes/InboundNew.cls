public With Sharing class InboundNew{

    @AuraEnabled
    public static List<ContentDocument> createDocuments(String recordId, String filesData) {
        List<ContentDocument> documents = new List<ContentDocument>();
        
       List<Object> filesListRaw = (List<Object>) JSON.deserializeUntyped(filesData);
        
        // Convert each object to a Map<String, Object> if possible
        List<Map<String, Object>> filesToUpload = new List<Map<String, Object>>();
        for (Object fileObj : filesListRaw) {
            if (fileObj instanceof Map<String, Object>) {                filesToUpload.add((Map<String, Object>) fileObj);
            }
        }
        try {
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            
            for (Map<String, Object> fileData : filesToUpload) {
                ContentVersion contentVersion = new ContentVersion();                contentVersion.Title = (String) fileData.get('title');
                contentVersion.PathOnClient = (String) fileData.get('fileName');
                contentVersion.VersionData = EncodingUtil.base64Decode((String) fileData.get('base64Data'));
                contentVersion.FirstPublishLocationId = recordId;  // Link the document to the record
                
                contentVersions.add(contentVersion);
            }
            
            // Insert ContentVersion records
            insert contentVersions;
            
            // Now query for the ContentDocument associated with the inserted ContentVersion records
            List<ContentDocument> contentDocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions)];
            documents.addAll(contentDocuments);
            
            return documents;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error creating documents: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Attachment> createAttachments(Id recordId, String filesData) {        List<Attachment> attch2return = new List<Attachment>();
        if (String.isEmpty(recordId) || String.isEmpty(filesData)) {            throw new AuraHandledException('Record ID and file data are required.');
        }

        // Parse the JSON string into a list of file data maps
        List<Object> filesListRaw = (List<Object>) JSON.deserializeUntyped(filesData);
        
        // Convert each object to a Map<String, Object> if possible
        List<Map<String, Object>> filesList = new List<Map<String, Object>>();
        for (Object fileObj : filesListRaw) {
            if (fileObj instanceof Map<String, Object>) {                filesList.add((Map<String, Object>) fileObj);
            }
        }        List<Attachment> attachmentsToInsert = new List<Attachment>();

        for (Map<String, Object> fileData : filesList) {
            String fileName = (String) fileData.get('fileName');            String fileContent = (String) fileData.get('fileContent');
            String fileType = (String) fileData.get('fileType');

            Attachment attachment = new Attachment();            attachment.ParentId = recordId;
            attachment.Name = fileName;            attachment.ContentType = fileType;            attachment.Body = EncodingUtil.base64Decode(fileContent);

            attachmentsToInsert.add(attachment);
        }

        insert attachmentsToInsert;
        attch2return = [Select Id, Name, ParentId from Attachment where ParentId = :recordId Order By CreatedDate ASC];
        if(attch2return.size() > 0)        return attch2return;
        else return null;
    }


    @AuraEnabled      
    public static comWrap getAll(String logisticId, String searchText, String Channel, String Site, Integer Offset, Integer Show, String filter,String accId){
        comWrap comW = new comWrap();
        try{
            
            system.debug('filter : '+filter);
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            logFields += ', ERP7__Sales_Order__r.Name , ERP7__Purchase_Order__r.ERP7__Customer__c ,ERP7__Purchase_Order__r.ERP7__Customer__r.Name,  ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name ';
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c'); 
             ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){ comW.showInboundDescription = FC.ERP7__showInboundDescription__c; comW.showBarcodes = FC.ERP7__showProdCode__c; comW.showAttachment = FC.ERP7__Inbound_Receive_Attachment__c; comW.enableQAMO = FC.ERP7__Enable_QA_in_Manufacturing_process__c;}
            
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                       ERP7__Organisation_Business_Unit__c
                       From ERP7__Employees__c
                       Where ERP7__Employee_User__c = : UserInfo.getUserId()
                       Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                comW.Employee = empList[0]; 
                if(Channel != Null && Channel != '') comW.Employee.Channel__c = Channel;
                if(comW.Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name
                                                                                  From ERP7__Distribution_Channel__c
                                                                                  Where ERP7__Channel__c = : comW.Employee.Channel__c And ERP7__Active__c = true And ERP7__Site__c != Null
                                                                                  Order By ERP7__Priority__c ASC]; //changed to sort by priority bfr it was primary SM - 25_07_24
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            comW.channelSites.add(new SelectOptions(DC.Site__c, DC.Name));
                        }
                        comW.selectedSite = DistributionChannels[0].Site__c;
                    }  
                    if(Site != Null && Site != '') comW.selectedSite = Site;
                } 
            } 
            /*'*** comW.channelSites : '+comW.channelSites);*/
            system.debug('accId : '+accId);
            String tempPOChannel = comW.Employee.Channel__c;   
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>(); 
            List<ERP7__Logistic__c> Recs = new List<ERP7__Logistic__c>(); 
            String selectedSite = comW.selectedSite;  
            String query1 = 'select ' + String.escapeSingleQuotes(logFields) + ' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null'; // Or ERP7__Sales_Order__r.ERP7__Tracking_Number__c like :searchTextPat
            if(accId != '' && accId != null) query1 += ' and ERP7__Account__c = :accId ';
            comW.allLogs = Database.query(query1);
            system.debug('comW.allLogs size~>'+comW.allLogs.size());
            
            if(logisticId != null && logisticId != '') {
                Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null And ERP7__Closed__c = false And (ERP7__Barcode__c =:logisticId Or Id =:logisticId) Order by CreatedDate Desc Limit 1');
            } else {
                String searchTextPat = '%'+searchText+'%';
                
                String query = 'select ' + String.escapeSingleQuotes(logFields) + ' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null  And (Name like :searchTextPat Or ERP7__RMA__r.Name like :searchTextPat or ERP7__Transfer_Order__r.Name like :searchTextPat or ERP7__Purchase_Order__r.Name like :searchTextPat or ERP7__Order_S__r.Name like :searchTextPat Or ERP7__Barcode__c like :searchTextPat)'; // Or ERP7__Sales_Order__r.ERP7__Tracking_Number__c like :searchTextPat //Removed  Or ERP7__Account__r.Name like :searchTextPat by shaguftha on 04_07_24
                if(accId != '' && accId != null) query += ' and ERP7__Account__c = :accId ';
                if(filter == 'NonReceivedItems') query += ' and ERP7__Putaway_Quantity__c = 0 ';
                else if(filter == 'PartialReceivedItems') query += ' and ERP7__Putaway_Quantity__c > 0  ';
                // else if(filter == 'FullReceivedItems') query += ' or ERP7__Closed__c = true';
                if(filter != 'FullReceivedItems' && searchText == '')  query += ' and ERP7__Closed__c = false';
                query += ' Order by CreatedDate Desc Limit 10000 ';
                Logs = Database.query(query);
                system.debug('Logs size~>'+Logs.size());
                List<ERP7__Logistic__c> QALogs = new List<ERP7__Logistic__c>();
                List<ERP7__Manufacturing_Order__c> QAMos = new List<ERP7__Manufacturing_Order__c>();
                if(Logs.size() > 0){
                    Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> myAwaitingQALists = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
                    for(ERP7__Logistic__c log : comW.allLogs){
                        myAwaitingQALists.put(log.Id, new List<ERP7__Stock_Inward_Line_Item__c>());
                    }
                   // system.debug('myAwaitingQALists size~>'+myAwaitingQALists.size());
                    
                    List<ERP7__Stock_Inward_Line_Item__c> mySOLIs = [Select Id, Name, ERP7__Logistic__c, ERP7__Status__c From ERP7__Stock_Inward_Line_Item__c Where (ERP7__Status__c = 'Quality Check(QA)' OR ERP7__Status__c = 'QC hold') And ERP7__Quantity__c  > 0 And ERP7__Logistic__c != Null And ERP7__Logistic__c In :myAwaitingQALists.KeySet()];
                    //system.debug('mySOLIs size~>'+mySOLIs.size());
                    
                    for(ERP7__Stock_Inward_Line_Item__c mysoli : mySOLIs){
                        if(myAwaitingQALists.containsKey(mysoli.ERP7__Logistic__c)) myAwaitingQALists.get(mysoli.ERP7__Logistic__c).add(mysoli);
                        //else myAwaitingQALists.push(mysoli.ERP7__Logistic__c,new Lis)
                    }
                    for(ERP7__Logistic__c log : comW.allLogs){
                        if(myAwaitingQALists.get(log.Id).size() > 0) QALogs.add(log);
                    }
                    comW.QALogCount = QALogs.size();
                }
                system.debug('comW.enableQAMO : '+comW.enableQAMO);
                if(comW.enableQAMO){
                    system.debug('selectedSite : '+selectedSite);
                    List<ERP7__Manufacturing_Order__c> MoInQA = [Select Id,Name,ERP7__ExpectedDate__c,ERP7__Order__c,ERP7__Order__r.AccountId,ERP7__Order__r.Account.Name,ERP7__Finished_Products_SiteId__c from ERP7__Manufacturing_Order__c where ERP7__Routing__r.ERP7__Finished_Products_Site__c =:selectedSite and ERP7__Product__c != null and ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c = true and ERP7__Status__c = 'Complete'];
                    System.debug('MoInQA.size() : '+MoInQA.size());
                    if(MoInQA.size() > 0){                        Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> myAwaitingQALists = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
                        for(ERP7__Manufacturing_Order__c mo : MoInQA){
                            myAwaitingQALists.put(mo.Id, new List<ERP7__Stock_Inward_Line_Item__c>());
                        }
                        List<ERP7__Stock_Inward_Line_Item__c> mySOLIs = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Status__c From ERP7__Stock_Inward_Line_Item__c Where (ERP7__Status__c = 'Quality Check(QA)' OR ERP7__Status__c = 'QC hold') And ERP7__Quantity__c  > 0 And ERP7__Manufacturing_Order__c != Null And ERP7__Manufacturing_Order__c In :myAwaitingQALists.KeySet()];
                        system.debug('mySOLIs : '+mySOLIs.size());
                        for(ERP7__Stock_Inward_Line_Item__c mysoli : mySOLIs){                            if(myAwaitingQALists.containsKey(mysoli.ERP7__Manufacturing_Order__c)) myAwaitingQALists.get(mysoli.ERP7__Manufacturing_Order__c).add(mysoli);
                        }
                        for(ERP7__Manufacturing_Order__c mo : MoInQA){                            if(myAwaitingQALists.get(mo.Id).size() > 0) QAMos.add(mo);
                        }
                        comW.QAMOsCount =  QAMos.size();
                    }
                    else comW.QAMOsCount = 0;
                    System.debug('comW.QAMOsCount : '+comW.QAMOsCount);
                }
                if(filter == 'PartialReceivedItems'){
                    List<ERP7__Logistic__c> partialLogs = new List<ERP7__Logistic__c>();
                    for(ERP7__Logistic__c log : Logs){
                        if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Putaway_Quantity__c > 0 && log.ERP7__Total_Quantity__c > log.ERP7__Putaway_Quantity__c) partialLogs.add(log);
                    }
                    Logs = partialLogs;
                }
                else if(filter == 'FullReceivedItems'){
                    List<ERP7__Logistic__c> fullLogs = new List<ERP7__Logistic__c>();
                    for(ERP7__Logistic__c log : Logs){
                        if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Putaway_Quantity__c > 0 && log.ERP7__Total_Quantity__c == log.ERP7__Putaway_Quantity__c) fullLogs.add(log);
                    }
                    Logs = fullLogs;
                }
                else if(filter == 'AwaitingQualityCheck'){
                    Logs = QALogs;
                }
                
                comW.recSize = Logs.size();
                comW.PNS = new List<Integer>();
                comW.show = Show;
                comW.Offset = Offset;
                Integer ES = comW.recSize;
                Integer j=0;
                while(ES >= comW.show){ j++; comW.PNS.add(j); ES=ES-comW.show;} 
                if(ES > 0) comW.PNS.add(j+1);
                
                for(Integer i = 0; i < Logs.size(); i++){
                    if(i >= comW.Offset+comW.show) break;
                    if(i >= comW.Offset) {
                        Recs.add(Logs[i]);
                    }
                }
                Logs = Recs;
                if(Logs.size() > 0 && comW.Offset != 0){ comW.startCount = comW.Offset + 1; comW.endCount = comW.Offset + Logs.size(); comW.PageNum = (comW.Offset+comW.show)/comW.show;}
                else if(Logs.size() > 0 && comW.Offset == 0){
                    comW.startCount = 1;
                    comW.endCount = Logs.size();
                    comW.PageNum = 1;
                }  
            }
           
            if(Logs.size() > 0) {
                Set<Id> soIds = new Set<Id>();
                Map<Id, Map<Id, String>> logOrders = new Map<Id, Map<Id, String>>();
                for(ERP7__Logistic__c log : Logs) {
                    soIds.add(log.Id);
                    logOrders.put(log.Id, new Map<Id, String>());
                }
                String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
                utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
                logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c, ERP7__Order_Product__r.OrderId ,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c, ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
                    +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c, ERP7__Order_Product__r.Order.Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name, ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name';
                
                List<ERP7__Logistic_Line_Item__c> soliss = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In: soIds order by ERP7__Logistic__c ASC'); 
                
                for(ERP7__Logistic_Line_Item__c solis: soliss) {
                    Map<Id, String> myLogOrders = logOrders.get(solis.ERP7__Logistic__c);
                    
                    if(solis.ERP7__Order_Product__r.OrderId != Null) {                        myLogOrders.put(solis.ERP7__Order_Product__r.OrderId, solis.ERP7__Order_Product__r.Order.Name);
                    }
                    if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) {	                        myLogOrders.put(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name);
                    } 
                    if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) {
                        myLogOrders.put(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name);
                    }
                    if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null){                        myLogOrders.put(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name);
                    }
                    if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) {                        myLogOrders.put(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name);
                    }
                    if(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c != Null) {                        myLogOrders.put(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name);
                    }
                    logOrders.put(solis.ERP7__Logistic__c, myLogOrders);
                }
                
                List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Logs Order By CreatedDate ASC];
                
                Map<Id,List<Attachment>> LogisticAttachments = new Map<Id,List<Attachment>>();
                for(Attachment attch : Attachments){
                    List<Attachment> attachlist = new List<Attachment>();
                    if(LogisticAttachments.containsKey(attch.ParentId)){ attachlist = LogisticAttachments.get(attch.ParentId); }
                    attachlist.add(attch);
                    LogisticAttachments.put(attch.ParentId,attachlist);
                } 
                
                List<LogisticWrapper> LogisticWrapperList = new List<LogisticWrapper>();
                for(ERP7__Logistic__c log : Logs){ 
                    LogisticWrapper logWrapper = new LogisticWrapper();
                    
                    Map<Id, String> myLogOrders = logOrders.get(log.Id);
                    for(Id oId : myLogOrders.keySet()) {
                        orderWrapper owrap = new orderWrapper(); owrap.OrderId = oId; owrap.OrderName = myLogOrders.get(oId); logWrapper.orderWrapperList.add(owrap);
                    }
                    
                    logWrapper.Logistic = log; 
                    //logWrapper.Attach = (LogisticAttachments.ContainsKey(log.Id))? LogisticAttachments.get(log.Id) : new Attachment(); 
                    logWrapper.Attachments = (LogisticAttachments.containsKey(log.Id))? LogisticAttachments.get(log.Id) : new List<Attachment>(); 
                    if(logisticId != Null && logisticId != '' && (log.ERP7__Barcode__c == logisticId || log.Id == logisticId)) logWrapper.isSelected = true; 
                    else logWrapper.isSelected = false; 
                    LogisticWrapperList.add(logWrapper); 
                }
                comW.LogisticWrapperList = LogisticWrapperList;
            } else comW.exceptionError = 'Sorry, no records available to view.'; 
            
            
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    @AuraEnabled public static comWrap getQualityCheckMOs(String searchText, String Channel, String Site, Integer Offset, Integer Show){ comWrap comW = new comWrap(); try{ ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid()); if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  } if(FC != null){ comW.showInboundDescription = FC.ERP7__showInboundDescription__c; comW.showBarcodes = FC.ERP7__showProdCode__c; comW.showAttachment = FC.ERP7__Inbound_Receive_Attachment__c; comW.enableQAMO = FC.ERP7__Enable_QA_in_Manufacturing_process__c;} String searchTextPat = '%'+searchText+'%'; List<ERP7__Manufacturing_Order__c> QAMos = new List<ERP7__Manufacturing_Order__c>(); if(Channel == '' || Channel == null){                List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>(); empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c From ERP7__Employees__c Where ERP7__Employee_User__c = : UserInfo.getUserId() Order by CreatedDate Asc Limit 1]; if(empList.size() > 0) {                     comW.Employee = empList[0]; if(Channel != Null && Channel != '') comW.Employee.Channel__c = Channel; if(comW.Employee.Channel__c != Null){ List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Primary__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Site__r.Name From ERP7__Distribution_Channel__c Where ERP7__Channel__c = : comW.Employee.Channel__c And ERP7__Active__c = true And ERP7__Site__c != Null Order By ERP7__Primary__c Desc]; if(DistributionChannels.size() > 0) { for(Distribution_Channel__c DC: DistributionChannels) {                                comW.channelSites.add(new SelectOptions(DC.Site__c, DC.Name)); } comW.selectedSite = DistributionChannels[0].Site__c; } } } } if(Site != Null && Site != '') comW.selectedSite = Site; String selectedSite = comW.selectedSite; system.debug('selectedSite : '+selectedSite); List<ERP7__Manufacturing_Order__c> MoInQA = new List<ERP7__Manufacturing_Order__c>();            List<ERP7__Manufacturing_Order__c> Recs = new List<ERP7__Manufacturing_Order__c>(); if(searchText != '' && searchText != null){                MoInQA =  [Select Id,Name,ERP7__ExpectedDate__c,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order__r.AccountId,ERP7__Order__r.Account.Name,ERP7__Finished_Products_SiteId__c,ERP7__Quantity_Produced__c,ERP7__Scrap_Quantity__c,ERP7__Quantity__c from ERP7__Manufacturing_Order__c where ERP7__Routing__r.ERP7__Finished_Products_Site__c =:selectedSite and ERP7__Product__c != null and ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c = true and ERP7__Status__c = 'Complete' and Name Like :searchTextPat ]; } else MoInQA =  [Select Id,Name,ERP7__ExpectedDate__c,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order__r.AccountId,ERP7__Order__r.Account.Name,ERP7__Finished_Products_SiteId__c,ERP7__Quantity_Produced__c,ERP7__Scrap_Quantity__c,ERP7__Quantity__c from ERP7__Manufacturing_Order__c where ERP7__Routing__r.ERP7__Finished_Products_Site__c =:selectedSite and ERP7__Product__c != null and ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c = true and ERP7__Status__c = 'Complete']; System.debug('MoInQA.size() : '+MoInQA.size()); if(MoInQA.size() > 0){ Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> myAwaitingQALists = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>(); for(ERP7__Manufacturing_Order__c mo : MoInQA){	                    myAwaitingQALists.put(mo.Id, new List<ERP7__Stock_Inward_Line_Item__c>()); } List<ERP7__Stock_Inward_Line_Item__c> mySOLIs = [Select Id, Name, ERP7__Manufacturing_Order__c, ERP7__Status__c From ERP7__Stock_Inward_Line_Item__c Where (ERP7__Status__c = 'Quality Check(QA)' OR ERP7__Status__c = 'QC hold') And ERP7__Quantity__c  > 0 And ERP7__Manufacturing_Order__c != Null And ERP7__Manufacturing_Order__c In :myAwaitingQALists.KeySet()]; system.debug('mySOLIs : '+mySOLIs.size()); for(ERP7__Stock_Inward_Line_Item__c mysoli : mySOLIs){ if(myAwaitingQALists.containsKey(mysoli.ERP7__Manufacturing_Order__c)) myAwaitingQALists.get(mysoli.ERP7__Manufacturing_Order__c).add(mysoli); } for(ERP7__Manufacturing_Order__c mo : MoInQA){                    if(myAwaitingQALists.get(mo.Id).size() > 0) QAMos.add(mo); } comW.QAMOsCount =  QAMos.size(); } comW.recSize = QAMos.size();            comW.PNS = new List<Integer>(); comW.show = Show;            comW.Offset = Offset; Integer ES = comW.recSize;            Integer j=0; while(ES >= comW.show){ j++; comW.PNS.add(j); ES=ES-comW.show;} if(ES > 0) comW.PNS.add(j+1); for(Integer i = 0; i < QAMos.size(); i++){ if(i >= comW.Offset+comW.show) break; if(i >= comW.Offset) Recs.add(QAMos[i]); } QAMos = Recs; if(QAMos.size() > 0 && comW.Offset != 0){ comW.startCount = comW.Offset + 1; comW.endCount = comW.Offset + QAMos.size(); comW.PageNum = (comW.Offset+comW.show)/comW.show;} else if(QAMos.size() > 0 && comW.Offset == 0){ comW.startCount = 1;                comW.endCount = QAMos.size();                comW.PageNum = 1; } List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :QAMos Order By CreatedDate ASC]; Map<Id,List<Attachment>> MOAttachments = new Map<Id,List<Attachment>>(); for(Attachment attch : Attachments){                List<Attachment> attachlist = new List<Attachment>(); if(MOAttachments.containsKey(attch.ParentId)){ attachlist = MOAttachments.get(attch.ParentId); } attachlist.add(attch); MOAttachments.put(attch.ParentId,attachlist); } List<MOWrapper> LogisticWrapperList = new List<MOWrapper>(); if(QAMos.size() > 0){ for(ERP7__Manufacturing_Order__c Mos : QAMos){ MOWrapper logWrapper = new MOWrapper(); logWrapper.MOrders = Mos; logWrapper.Attachments = (MOAttachments.containsKey(Mos.Id))? MOAttachments.get(Mos.Id) : new List<Attachment>(); LogisticWrapperList.add(logWrapper); } comW.MOWrapperList = LogisticWrapperList; } else comW.exceptionError = 'Sorry, no records available to view.'; } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); } return comW; }
    @AuraEnabled      
    public static comWrap  fetchSortedLogistics(String OrderBy,String SortOrder, String Site,String Channel ,Integer Show,Integer Offset, String filterType,String accId){
        comWrap comW = new comWrap();
        try{
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            logFields += ', ERP7__Sales_Order__r.Name , ERP7__Purchase_Order__r.ERP7__Customer__c ,ERP7__Purchase_Order__r.ERP7__Customer__r.Name,  ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name ';
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c'); 
            
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                       ERP7__Organisation_Business_Unit__c From ERP7__Employees__c Where ERP7__Employee_User__c =: UserInfo.getUserId() Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                comW.Employee = empList[0]; 
                if(Channel != Null && Channel != '') comW.Employee.Channel__c = Channel;
                if(comW.Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name
                                                                                  From Distribution_Channel__c
                                                                                  Where Channel__c = : comW.Employee.Channel__c And Active__c = true And Site__c != Null
                                                                                  Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            comW.channelSites.add(new SelectOptions(DC.Site__c, DC.Name));
                        }
                        comW.selectedSite = DistributionChannels[0].Site__c;
                    }  
                    if(Site != Null && Site != '') comW.selectedSite = Site;
                } 
            } 
            /*'*** comW.channelSites : '+comW.channelSites);*/
            
            String tempPOChannel = comW.Employee.Channel__c;   
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>(); 
            List<ERP7__Logistic__c> Recs = new List<ERP7__Logistic__c>(); 
            String selectedSite = comW.selectedSite;      
            if(!Schema.sObjectType.ERP7__Logistic__c.isAccessible()) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.ERP7__Logistic__c.Label));
            else{
                //Moin added below code on 30th october 2023 since the sorting was not working
                /*String query = ' Select '+ String.escapeSingleQuotes(logFields) +' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null And ERP7__Closed__c = false Order by ';
                query = query + String.escapeSingleQuotes(OrderBy) + ' ' + String.escapeSingleQuotes(SortOrder)+'  NULLS  Last';
                String query2 = String.escapeSingleQuotes(OrderBy) + ' ' + String.escapeSingleQuotes(SortOrder);
                //Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null And ERP7__Closed__c = false And (Name like :searchTextPat Or ERP7__Sales_Order__r.Name like :searchTextPat Or ERP7__Account__r.Name like :searchTextPat Or ERP7__Barcode__c like :searchTextPat) Order by CreatedDate Desc Limit 10000'); // Or ERP7__Sales_Order__r.ERP7__Tracking_Number__c like :searchTextPat
                System.debug('query : '+query);
                System.debug('query2 : '+query2);
                Logs = Database.query(query);*/
                String query = 'SELECT ' + String.escapeSingleQuotes(logFields) +
               ' FROM ERP7__Logistic__c ' +
               ' WHERE ERP7__Active__c = true ' +
               ' AND ERP7__Type__c = \'Inbound\' ' +
               ' AND Channel__c = :tempPOChannel ' +
               ' AND ERP7__Distribution_Channel__r.ERP7__Site__c = :selectedSite ' +
               ' AND Total_Quantity__c > 0 ' +
               ' AND ERP7__Sales_Order__c = null ' +
               ' AND ERP7__Closed__c = false ' ;
                if(accId != '' && accId != null) query += ' and ERP7__Account__c = :accId ';
                query +=   ' ORDER BY ' + String.escapeSingleQuotes(OrderBy) + ' ' + String.escapeSingleQuotes(SortOrder) + ' NULLS LAST';
                String query2 = String.escapeSingleQuotes(OrderBy) + ' ' + String.escapeSingleQuotes(SortOrder);
                //Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null And ERP7__Closed__c = false And (Name like :searchTextPat Or ERP7__Sales_Order__r.Name like :searchTextPat Or ERP7__Account__r.Name like :searchTextPat Or ERP7__Barcode__c like :searchTextPat) Order by CreatedDate Desc Limit 10000'); // Or ERP7__Sales_Order__r.ERP7__Tracking_Number__c like :searchTextPat
                System.debug('query : '+query);
                System.debug('query2 : '+query2);
                Logs = Database.query(query);
                for(ERP7__Logistic__c log : Logs){ 
                    system.debug('log-->'+log);
                }
                List<ERP7__Logistic__c> QALogs = new List<ERP7__Logistic__c>();
                
                if(Logs.size() > 0){
                    Map<Id, List<ERP7__Stock_Inward_Line_Item__c>> myAwaitingQALists = new Map<Id, List<ERP7__Stock_Inward_Line_Item__c>>();
                    for(ERP7__Logistic__c log : comW.allLogs){                        myAwaitingQALists.put(log.Id, new List<ERP7__Stock_Inward_Line_Item__c>());
                    }
                   // system.debug('myAwaitingQALists size~>'+myAwaitingQALists.size());
                    
                    List<ERP7__Stock_Inward_Line_Item__c> mySOLIs = [Select Id, Name, ERP7__Logistic__c, ERP7__Status__c From ERP7__Stock_Inward_Line_Item__c Where (ERP7__Status__c = 'Quality Check(QA)' OR ERP7__Status__c = 'QC hold') And ERP7__Quantity__c  > 0 And ERP7__Logistic__c != Null And ERP7__Logistic__c In :myAwaitingQALists.KeySet()];
                    //system.debug('mySOLIs size~>'+mySOLIs.size());
                    
                    for(ERP7__Stock_Inward_Line_Item__c mysoli : mySOLIs){                        if(myAwaitingQALists.containsKey(mysoli.ERP7__Logistic__c)) myAwaitingQALists.get(mysoli.ERP7__Logistic__c).add(mysoli);
                        //else myAwaitingQALists.push(mysoli.ERP7__Logistic__c,new Lis)
                    }
                    for(ERP7__Logistic__c log : comW.allLogs){                        if(myAwaitingQALists.get(log.Id).size() > 0) QALogs.add(log);
                    }
                    comW.QALogCount = QALogs.size();
                }
                if(filterType == 'PartialReceivedItems'){
                    List<ERP7__Logistic__c> partialLogs = new List<ERP7__Logistic__c>();
                    for(ERP7__Logistic__c log : Logs){
                        if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Putaway_Quantity__c > 0 && log.ERP7__Total_Quantity__c > log.ERP7__Putaway_Quantity__c) partialLogs.add(log);
                    }
                    Logs = partialLogs;
                }
                else if(filterType == 'FullReceivedItems'){
                    List<ERP7__Logistic__c> fullLogs = new List<ERP7__Logistic__c>();
                    for(ERP7__Logistic__c log : Logs){
                        if(log.ERP7__Total_Quantity__c > 0 && log.ERP7__Putaway_Quantity__c > 0 && log.ERP7__Total_Quantity__c == log.ERP7__Putaway_Quantity__c) fullLogs.add(log);
                    }
                    Logs = fullLogs;
                }
                else if(filterType == 'AwaitingQualityCheck'){
                    Logs = QALogs;
                }
                else if(filterType == 'NonReceivedItems'){
                    List<ERP7__Logistic__c> nonRecivedLogs = new List<ERP7__Logistic__c>();
                    for(ERP7__Logistic__c log : Logs){
                        if(log.ERP7__Putaway_Quantity__c == 0) nonRecivedLogs.add(log);
                    }
                    Logs = nonRecivedLogs;
                }
                    
                comW.recSize = Logs.size();
                comW.PNS = new List<Integer>();
                comW.show = Show;
                comW.Offset = Offset;
                Integer ES = comW.recSize;
                Integer j=0;
                while(ES >= comW.show){ j++; comW.PNS.add(j); ES=ES-comW.show;} 
                if(ES > 0) comW.PNS.add(j+1);
                
                for(Integer i = 0; i < Logs.size(); i++){
                    if(i >= comW.Offset+comW.show) break;
                    if(i >= comW.Offset) Recs.add(Logs[i]);
                }
                Logs = Recs;
                for(ERP7__Logistic__c log : Logs){ 
                    system.debug('log-->'+log);
                }
                if(Logs.size() > 0 && comW.Offset != 0){ comW.startCount = comW.Offset + 1; comW.endCount = comW.Offset + Logs.size(); comW.PageNum = (comW.Offset+comW.show)/comW.show;}
                else if(Logs.size() > 0 && comW.Offset == 0){
                    comW.startCount = 1;
                    comW.endCount = Logs.size();
                    comW.PageNum = 1;
                }  
            }
            if(Logs.size() > 0) {
                Set<Id> soIds = new Set<Id>();
                Map<Id, Map<Id, String>> logOrders = new Map<Id, Map<Id, String>>();
                for(ERP7__Logistic__c log : Logs) {
                    
                    soIds.add(log.Id);
                    logOrders.put(log.Id, new Map<Id, String>());
                }
                system.debug('soIds : '+soIds);
                String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
                utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
                logLineFields += ', ERP7__Logistic__r.ERP7__Order__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Product__r.ProductCode, ERP7__Logistic__r.Name, ERP7__Product__r.ERP7__Item_Description__c, ERP7__Product__r.ERP7__Weight__c, ERP7__Product__r.ERP7__Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c, ERP7__Order_Product__r.OrderId ,ERP7__Order_Product__r.Order.ERP7__Shipment_Type__c,ERP7__Order_Product__r.Order.ERP7__Special_Instructions__c,ERP7__Order_Product__r.Order.ERP7__UPS_Service__c, ERP7__Order_Product__r.Order.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Shipment_Type__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Special_Instructions__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__UPS_Service__c, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.ERP7__Purchase_Order_Number__c,  ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, '+
                    +'ERP7__Logistic__r.Channel__c, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Logistic__r.ERP7__Channel__r.Name, ERP7__Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__r.Name, ERP7__Logistic__r.Account__c, ERP7__Logistic__r.ERP7__Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__Purchase_Line_Items__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__r.ERP7__Serialise__c, ERP7__Order_Product__r.Order.Name, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name, ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name, ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name, ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name';
                
                List<ERP7__Logistic_Line_Item__c> soliss = Database.query('select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In: soIds order by ERP7__Logistic__c ASC'); 
                
                for(ERP7__Logistic_Line_Item__c solis: soliss) {
                    Map<Id, String> myLogOrders = logOrders.get(solis.ERP7__Logistic__c);
                    
                    if(solis.ERP7__Order_Product__r.OrderId != Null) {                        myLogOrders.put(solis.ERP7__Order_Product__r.OrderId, solis.ERP7__Order_Product__r.Order.Name);
                    }
                    if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) {                        myLogOrders.put(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name);
                    } 
                    if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) {
                        myLogOrders.put(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name);
                    }
                    if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null){                        myLogOrders.put(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name);
                    }
                    if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) {                        myLogOrders.put(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name);
                    }
                    if(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c != Null) {                        myLogOrders.put(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name);
                    }
                    logOrders.put(solis.ERP7__Logistic__c, myLogOrders);
                }
                
                List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Logs Order By CreatedDate ASC];
                
                Map<Id,List<Attachment>> LogisticAttachments = new Map<Id,List<Attachment>>();
                for(Attachment attch : Attachments){
                    List<Attachment> attachlist = new List<Attachment>();
                    if(LogisticAttachments.containsKey(attch.ParentId)){ attachlist = LogisticAttachments.get(attch.ParentId); }
                    attachlist.add(attch);
                    LogisticAttachments.put(attch.ParentId,attachlist);
                } 
                
                List<LogisticWrapper> LogisticWrapperList = new List<LogisticWrapper>();
                for(ERP7__Logistic__c log : Logs){ 
                    system.debug('log-->'+log);
                    LogisticWrapper logWrapper = new LogisticWrapper();
                    
                    Map<Id, String> myLogOrders = logOrders.get(log.Id);
                    for(Id oId : myLogOrders.keySet()) {
                        orderWrapper owrap = new orderWrapper(); owrap.OrderId = oId; owrap.OrderName = myLogOrders.get(oId); logWrapper.orderWrapperList.add(owrap);
                    }
                    
                    
                    logWrapper.Logistic = log; 
                    //logWrapper.Attach = (LogisticAttachments.ContainsKey(log.Id))? LogisticAttachments.get(log.Id) : new Attachment(); 
                    logWrapper.Attachments = (LogisticAttachments.containsKey(log.Id))? LogisticAttachments.get(log.Id) : new List<Attachment>(); 
                    //if(logisticId != Null && logisticId != '' && (log.ERP7__Barcode__c == logisticId || log.Id == logisticId)) logWrapper.isSelected = true; 
                    //else logWrapper.isSelected = false; 
                    LogisticWrapperList.add(logWrapper); 
                }
                comW.LogisticWrapperList = LogisticWrapperList;
            } else comW.exceptionError = 'Sorry, no records available to view.'; 
            
            
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
                             system.debug('Excpetion-->'+e+e.getLineNumber());}
        return comW; 
    }
    
    @AuraEnabled
    public static String UpdateSILI(String sili){
        try{
            List<ERP7__Stock_Inward_Line_Item__c> returnsili = (List<ERP7__Stock_Inward_Line_Item__c>) JSON.deserialize(sili,List<ERP7__Stock_Inward_Line_Item__c>.class);
            if(returnsili != null &&  returnsili.size() > 0) { upsert returnsili;  return 'Success';}  else return null;
        } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } 
    }
    
    @AuraEnabled
    public static ERP7__Logistic__c saveLogisticDescription(String LogId, String textvalue){
        try{
            if(String.isNotEmpty(LogId) && String.isNotEmpty(textvalue)){
                ERP7__Logistic__c lognew = new ERP7__Logistic__c(Id=LogId,ERP7__Special_Instructions__c=textvalue);
                update lognew; return lognew;
            }
            return null;
        } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } 
    }
    @AuraEnabled public static comWrap ReceiveMOItems(String MOrderIds){ comWrap comW = new comWrap(); Map<String,String> statusMap = new Map<String,String> ();        List<SelectOptions> options = new List<SelectOptions>(); Schema.DescribeFieldResult fieldResult = ERP7__Stock_Inward_Line_Item__c.ERP7__Status__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) { options.add(new SelectOptions(f.getValue(), f.getLabel())); statusMap.put(f.getLabel(),f.getValue()); } comW.status = options; ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid()); if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  } if(FC != null){ comW.showVendorCode  = FC.ERP7__Show_Vendor_Product_Code__c; comW.PreventStatusEdit = FC.ERP7__Prevent_Status_edit_after_Receiving__c;  comW.AllocationAccess = FC.ERP7__Allocation_Process__c; comW.showUpload = FC.ERP7__Show_uplaod_for_Batch_creation__c; comW.showProdBarcodeReceive = FC.ERP7__showProdBarcodeReceive__c;   comW.disableNameReceive = FC.ERP7__disableNameReceive__c;   comW.disableLocReceive = FC.ERP7__disableLocReceive__c; comW.showStatus = FC.ERP7__Show_Status_in_Inbound_Flow__c; comW.showInboundQA = FC.ERP7__Show_QA_in_Inbound__c; comW.showUplaodforItems = FC.ERP7__Show_upload_for_each_item_in_Receive__c;} List<String> MoIdss = (List<String>) JSON.deserialize(MOrderIds, List<String>.class); List<ERP7__Manufacturing_Order__c> MOList = [Select Id,Name,ERP7__ExpectedDate__c,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order__r.AccountId,ERP7__Order__r.Account.Name,ERP7__Finished_Products_SiteId__c,ERP7__Quantity_Produced__c,ERP7__Scrap_Quantity__c,ERP7__Quantity__c  from ERP7__Manufacturing_Order__c where Id IN:MoIdss]; for(ERP7__Manufacturing_Order__c MO : MOList){ MOWrapper mWrapper = new MOWrapper();             mWrapper.MOrders = MO;             mWrapper.isSelected = true; comW.MOWrapperList.add(mWrapper); comW.selectedSite = MO.ERP7__Finished_Products_SiteId__c; } if(comW.selectedSite != null && comW.selectedSite != ''){ List<ERP7__Distribution_Channel__c> dclist = [Select Id,Name,ERP7__Channel__c,ERP7__Channel__r.Name,ERP7__Site__c,ERP7__Site__r.Name from ERP7__Distribution_Channel__c where ERP7__Site__c =:comW.selectedSite limit 1]; if(dclist.size() > 0){                comW.SiteName = dclist[0].ERP7__Site__r.Name; comW.ChannelName = dclist[0].Channel__r.Name;                comW.ChannelId = dclist[0].Channel__c; } } List<ERP7__Stock_Inward_Line_Item__c> SPLIS = [Select Id,ERP7__Quantity__c,ERP7__Logistic_Line_Item__c, ERP7__Status__c,ERP7__Location__c,ERP7__StorageContainer__c, Name, ERP7__Material_Batch_Lot__c,ERP7__Serial__c,ERP7__Transfer_Order_Line_Item__c,ERP7__RMA_Line_Item__c,ERP7__Serial_Number__c,ERP7__Product__c, ERP7__Product__r.Name,ERP7__Logistic__r.Name,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__r.Name,ERP7__Location__r.Name,ERP7__Product__r.ERP7__Is_OverSized_Item__c,ERP7__Product__r.ERP7__Quality_Check_QA__c,ERP7__Manufacturing_Order__c,ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c from ERP7__Stock_Inward_Line_Item__c where ERP7__Manufacturing_Order__c     In :MoIdss and ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c = true  order by CreatedDate ASC]; set<Id> QAProdIds = new set<Id>();        set<Id> receivedSili= new set<Id>(); for(ERP7__Stock_Inward_Line_Item__c SPLI : SPLIS){            QAProdIds.add(SPLI.ERP7__Product__c);            receivedSili.add(SPLI.Id); } List<ERP7__Checklist__c> checklists = new List<ERP7__Checklist__c>(); checklists = [Select Id,Name,ERP7__Is_Mandatory__c,ERP7__Action_Detail__c ,ERP7__Has_Checklist__c, toLabel(ERP7__Comply__c), toLabel(ERP7__Result__c), ERP7__Notes__c, ERP7__Product__c from ERP7__Checklist__c where ERP7__Product__c != null AND ERP7__Product__c IN: QAProdIds AND ERP7__Product__r.ERP7__QA_Handling_Inbound_Post_MO_Completion__c = true Order by createdDate asc]; Map<Id, UserRecordAccess> userAccessMap = new Map<Id, UserRecordAccess>(); system.debug('checklists : '+checklists); if(checklists.size() > 0){            Set<Id> checklistIds = new Set<Id>(); for(ERP7__Checklist__c chk: checklists){ checklistIds.add(chk.Id); } userAccessMap = new Map<Id, UserRecordAccess>([SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :checklistIds]); } List<ERP7__Guideline_Checklists__c> enteredChecklists = new List<ERP7__Guideline_Checklists__c>(); if(receivedSili.size() > 0){ enteredChecklists = [Select Id, Name, ERP7__Checklist__c,ERP7__Is_Mandatory__c, ERP7__Status__c,ERP7__Instructions__c, ERP7__Stock_Inward_Line_Item__c, ERP7__Checklist__r.ERP7__Is_Mandatory__c, ERP7__Checklist__r.ERP7__Action_Detail__c, ERP7__Checklist__r.ERP7__Has_Checklist__c,ERP7__Checklist__r.Name, toLabel(ERP7__Checklist__r.ERP7__Comply__c), toLabel(ERP7__Checklist__r.ERP7__Result__c), ERP7__Checklist__r.ERP7__Product__c, (Select Id, Name, ParentId from Attachments) from ERP7__Guideline_Checklists__c where ERP7__Stock_Inward_Line_Item__c IN: receivedSili AND ERP7__Checklist__c != null AND ERP7__Stock_Inward_Line_Item__c != null]; } Map<String,List<ERP7__Guideline_Checklists__c>> guideMAp = new Map<String,List<ERP7__Guideline_Checklists__c>>(); for(ERP7__Guideline_Checklists__c guide: enteredChecklists){ String key = ''+guide.ERP7__Stock_Inward_Line_Item__c+guide.ERP7__Checklist__c; system.debug('key setting~>'+key); if(guideMAp.containsKey(key)) guideMAp.get(key).add(guide); else guideMAp.put(key, new List<ERP7__Guideline_Checklists__c>{guide}); } for(ERP7__Stock_Inward_Line_Item__c stinReceived : SPLIS){ ReceivedSILIWrap wrapReceive = new ReceivedSILIWrap();            wrapReceive.sili = stinReceived; for(ERP7__Checklist__c check : checklists){                String key = ''+stinReceived.Id+check.Id; system.debug('key checkinghere~>'+key); system.debug('guideMAp.containsKey(key)~>'+guideMAp.containsKey(key)); if(guideMAp.containsKey(key)){ system.debug('inhere1'); wrapReceive.guideline.addAll(guideMAp.get(key)); system.debug('wrapReceive.guideline~>'+wrapReceive.guideline.size()); for(ERP7__Guideline_Checklists__c gu : wrapReceive.guideline){ if(gu.ERP7__Checklist__c != null){ UserRecordAccess userAccess = (userAccessMap.containsKey(gu.ERP7__Checklist__c)) ? userAccessMap.get(gu.ERP7__Checklist__c) : null; gu.Name = gu.ERP7__Checklist__r.Name; if(gu.ERP7__Checklist__r.ERP7__Comply__c != null && gu.ERP7__Checklist__r.ERP7__Comply__c != '' && gu.ERP7__Checklist__r.ERP7__Comply__c != '--None--') gu.Name = gu.ERP7__Checklist__r.ERP7__Comply__c; gu.ERP7__Is_Mandatory__c = false; if (userAccess != null){ if(userAccess.HasEditAccess) gu.ERP7__Is_Mandatory__c = true; } } } } else{ if(check.ERP7__Product__c == stinReceived.ERP7__Product__c){ system.debug('inhere2'); UserRecordAccess userAccess = (userAccessMap.containsKey(check.Id)) ? userAccessMap.get(check.Id) : null; ERP7__Guideline_Checklists__c guideChecks = new ERP7__Guideline_Checklists__c(); guideChecks.Name = check.Name; if(check.ERP7__Comply__c != null && check.ERP7__Comply__c != '' && check.ERP7__Comply__c != '--None--') guideChecks.Name = check.ERP7__Comply__c; guideChecks.ERP7__Checklist__c = check.Id; guideChecks.ERP7__Checklist__r = new  ERP7__Checklist__c(ERP7__Is_Mandatory__c = check.ERP7__Is_Mandatory__c,ERP7__Comply__c = check.ERP7__Comply__c,ERP7__Result__c = check.ERP7__Result__c,ERP7__Notes__c = check.ERP7__Notes__c); guideChecks.ERP7__Instructions__c =  check.ERP7__Has_Checklist__c ? check.ERP7__Result__c : check.ERP7__Action_Detail__c; if(check.ERP7__Has_Checklist__c) guideChecks.ERP7__Status__c = check.ERP7__Result__c; guideChecks.ERP7__Stock_Inward_Line_Item__c = stinReceived.Id; guideChecks.ERP7__Is_Mandatory__c = false; if (userAccess != null){ if(userAccess.HasEditAccess) guideChecks.ERP7__Is_Mandatory__c = true; } wrapReceive.guideline.add(guideChecks); } } } comW.SILILOLI.add(wrapReceive); } return comW; }
    
    @AuraEnabled
    public static comWrap ReceiveAl(String LogisticIdss){
        system.debug('ReceiveAll called');
        comWrap comW = new comWrap();
        Map<String,String> statusMap = new Map<String,String> ();
        List<SelectOptions> options = new List<SelectOptions>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Stock_Inward_Line_Item__c.ERP7__Status__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) {
            options.add(new SelectOptions(f.getValue(), f.getLabel()));
            statusMap.put(f.getLabel(),f.getValue());
            //if(f.getValue() != 'Awaiting Stock') options.add(f.getValue()); 
        }
        comW.status = options;
        
        
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
        if(FC != null){ comW.showVendorCode  = FC.ERP7__Show_Vendor_Product_Code__c; comW.PreventStatusEdit = FC.ERP7__Prevent_Status_edit_after_Receiving__c;  comW.AllocationAccess = FC.ERP7__Allocation_Process__c; comW.showUpload = FC.ERP7__Show_uplaod_for_Batch_creation__c; comW.showProdBarcodeReceive = FC.ERP7__showProdBarcodeReceive__c;   comW.disableNameReceive = FC.ERP7__disableNameReceive__c;   comW.disableLocReceive = FC.ERP7__disableLocReceive__c; comW.showStatus = FC.ERP7__Show_Status_in_Inbound_Flow__c; comW.showInboundQA = FC.ERP7__Show_QA_in_Inbound__c; comW.showUplaodforItems = FC.ERP7__Show_upload_for_each_item_in_Receive__c;}
       
        List<String> soIdss = (List<String>) JSON.deserialize(LogisticIdss, List<String> .class);
        String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
        utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
        List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>();        
        Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' , ERP7__Sales_Order__r.Name, ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, '+
                              +'ERP7__Distribution_Channel__r.ERP7__Site__c, Channel__r.Name, ERP7__Distribution_Channel__r.ERP7__Site__r.Name,  ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where Id IN :soIdss'); 
        if(Logs.size() > 0){
            comW.SiteName = Logs[0].ERP7__Distribution_Channel__r.ERP7__Site__r.Name;
            comW.ChannelName = Logs[0].Channel__r.Name;
            comW.ChannelId = Logs[0].Channel__c;
            comW.selectedSite = Logs[0].ERP7__Distribution_Channel__r.ERP7__Site__c;
        }
        List<ERP7__Location__c> defaultloc = [Select Id,Name from ERP7__Location__c where ERP7__Site__c=:comW.selectedSite and ERP7__Active__c = true order by createddate];
        List<ERP7__Logistic__c> Logistics = Logs;
        String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
        utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
        logLineFields += ' ,ERP7__Purchase_Line_Items__r.ERP7__Vendor_product_Name__c,ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name,Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Is_OverSized_Item__c,ERP7__Product__r.ERP7__Preview_Image__c, ERP7__Product__r.ERP7__Picture__c, ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Barcode__c, ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Default_Location__c, ERP7__Product__r.ERP7__Default_Location__r.ERP7__Site__c, ERP7__Product__r.Is_Asset__c,ERP7__Product__r.Item_Description__c, ERP7__Product__r.Weight__c, ERP7__Product__r.Special_Instructions__c, ERP7__Product__r.ERP7__Is_Kit__c, ERP7__Product__r.ERP7__Kit_Protected__c,  ERP7__Logistic__r.Name, ERP7__Order_Product__r.OrderId, Sales_Order_Line_Item__r.Sales_Order__c, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, ERP7__Purchase_Line_Items__r.ERP7__Sales_Order_Line_Item__c, ERP7__Purchase_Line_Items__r.ERP7__Sales_Order__c,ERP7__Purchase_Line_Items__r.ERP7__Order_Product__c, ERP7__Purchase_Line_Items__r.ERP7__Order__c, ERP7__Purchase_Line_Items__r.Purchase_Orders__c, ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__c, ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c, ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Unit__c, ERP7__Work_Order_Line_Items__r.Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c, Logistic__r.Account__c, Logistic__r.Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__RMA_Line_Item__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name,  ERP7__Fixed_Asset__r.Serialise__c, ERP7__RMA_Line_Item__r.ERP7__Serial_Number__c, ERP7__RMA_Line_Item__r.ERP7__Serial_Number__r.Name,ERP7__RMA_Line_Item__r.ERP7__Serial_Number__r.ERP7__Serial_Number__c,ERP7__RMA_Line_Item__r.ERP7__Serial_Number__r.ERP7__Serial_No__c, ERP7__Transfer_Order_Line_Item__r.ERP7__SerialNumber__c, ERP7__RMA_Line_Item__r.ERP7__SOLI__c,ERP7__RMA_Line_Item__r.ERP7__Ord_Item__c ';
        List<Id> soIds = new List<Id>();
        for(ERP7__Logistic__c log : Logs){ 
            LogisticWrapper logWrapper = new LogisticWrapper(); 
            logWrapper.Logistic = log; 
            logWrapper.isSelected = true; 
            comW.LogisticWrapperList.add(logWrapper); 
        }
        String query1 = 'select ' + String.escapeSingleQuotes(logLineFields) + ',ERP7__Product__r.ERP7__Quality_Check_QA__c from ERP7__Logistic_Line_Item__c where Logistic__c in : soIdss AND ERP7__Product__c != null ORDER BY ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c ASC NULLS FIRST'; //Order By ERP7__Purchase_Line_Items__r.ERP7__Sort_Order__c
        List<ERP7__Logistic_Line_Item__c> Lolis = Database.query(query1);
        System.debug('Lolis:'+Lolis.size());
        List<String> productIds = new List<String>();
        List<String> LOLIIds = new List<String>();
        Set<Id> OrderLineIds = new Set<Id>(); Set<Id> poliLineIds = new Set<Id>();
        Set<Id> rmasoliIds = new Set<Id>();
        Set<Id> TOIds = new Set<Id>();
        set<Id> QAProdIds = new Set<Id>(); // 20_03
        for(Logistic_Line_Item__c loli : Lolis){
            if(loli.Product__c != Null) productIds.add(loli.Product__c);
            LOLIIds.add(loli.Id);
            if(loli.ERP7__RMA_Line_Item__c != Null) {                OrderLineIds.add(loli.ERP7__RMA_Line_Item__c); 
                if(loli.ERP7__RMA_Line_Item__r.ERP7__SOLI__c != null) rmasoliIds.add(loli.ERP7__RMA_Line_Item__r.ERP7__SOLI__c); 
                if(loli.ERP7__RMA_Line_Item__r.ERP7__Ord_Item__c != null) rmasoliIds.add(loli.ERP7__RMA_Line_Item__r.ERP7__Ord_Item__c);
            }
            else if(loli.ERP7__Purchase_Line_Items__c != Null){ OrderLineIds.add(loli.ERP7__Purchase_Line_Items__c); poliLineIds.add(loli.ERP7__Purchase_Line_Items__c); }
            else if(loli.ERP7__Work_Order_Line_Items__c != Null) OrderLineIds.add(loli.ERP7__Work_Order_Line_Items__c);
            else if(loli.ERP7__Transfer_Order_Line_Item__c != Null) { OrderLineIds.add(loli.ERP7__Transfer_Order_Line_Item__c); TOIds.add(loli.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c); }
        }
        List<Attachment> attachList = new List<Attachment>();
        if(LOLIIds.size() > 0) attachList = [Select Id,Name,ParentId from Attachment where ParentId IN:LOLIIds];
        Map<Id,List<Attachment>> mapAttchList=new Map<Id,List<Attachment>>();
         for(Attachment con : attachList){
            if(mapAttchList.containsKey(con.ParentId))    mapAttchList.get(con.ParentId).add( con );
            else  mapAttchList.put(con.ParentId,new List<Attachment> {con} );  
        }
        List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
        if(LOLIIds.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility,ContentDocument.Title From ContentDocumentLink where LinkedEntityId In :LOLIIds]; 
        
        system.debug('conDocLink'+conDocLink);
        
        Map<Id,List<ContentDocumentLink>> mapList=new Map<Id,List<ContentDocumentLink>>();
        for(ContentDocumentLink con : conDocLink){
            if(mapList.containsKey(con.LinkedEntityId))    mapList.get(con.LinkedEntityId).add( con );
            else  mapList.put(con.LinkedEntityId,new List<ContentDocumentLink> {con} );  
        }
        //New code added by Arshad 14/02/2023
        List<ERP7__Dimension__c> poliDimensions = new List<ERP7__Dimension__c>();
        if(poliLineIds.size() > 0){
            String dimensionFields = UtilClass.selectStarFromSObject('ERP7__Dimension__c');   
            utilClass.FLSCheck(dimensionFields.split(','),'ERP7__Dimension__c');
            dimensionFields += ' ,ERP7__Chart_of_Account__r.Name, ERP7__Project__r.Name ';
            String poliDimensionsQry = 'select ' + String.escapeSingleQuotes(dimensionFields) + ' from ERP7__Dimension__c where ERP7__Purchase_Line_Items__c != null AND ERP7__Active__c = true AND ERP7__Purchase_Line_Items__c IN : poliLineIds ORDER BY ERP7__Sort_Order__c ASC NULLS FIRST';
            poliDimensions = Database.query(poliDimensionsQry);
        }
        comW.poliDimensions = poliDimensions;
        //
        
        String InwardFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');   
        utilClass.FLSCheck(InwardFields.split(','),'ERP7__Stock_Inward_Line_Item__c');
        //String allFields3 = InwardFields;
        //UtilClass.FlSCheck(allFields3.split(',') ,'ERP7__Stock_Inward_Line_Item__c');
        
        //if(comW.PreventStatusEdit) allFields3 = allFields3.replace('erp7__status__c', 'toLabel(erp7__status__c)' );
        //String allFields3 = 'Id,ERP7__Quantity__c,ERP7__Logistic_Line_Item__c, toLabel(ERP7__Status__c),ERP7__Location__c,ERP7__StorageContainer__c, Name, ERP7__Material_Batch_Lot__c,ERP7__Serial__c,ERP7__Transfer_Order_Line_Item__c,ERP7__RMA_Line_Item__c,ERP7__Serial_Number__c,ERP7__Product__c';
        //String query3 = 'Select Id,ERP7__Quantity__c,ERP7__Logistic_Line_Item__c, toLabel(ERP7__Status__c),ERP7__Location__c,ERP7__StorageContainer__c, Name, ERP7__Material_Batch_Lot__c,ERP7__Serial__c,ERP7__Transfer_Order_Line_Item__c,ERP7__RMA_Line_Item__c,ERP7__Serial_Number__c,ERP7__Product__c, ERP7__Product__r.Name,ERP7__Logistic__r.Name,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__r.Name,ERP7__Location__r.Name,ERP7__Fixed_Asset__r.Product__c,ERP7__Product__r.ERP7__Is_OverSized_Item__c,ERP7__Product__r.ERP7__Quality_Check_QA__c from ERP7__Stock_Inward_Line_Item__c where (ERP7__Transfer_Order_Line_Item__c In :OrderLineIds Or ERP7__Work_Order_Line_Items__c In :OrderLineIds Or ERP7__Purchase_Line_Items__c In :OrderLineIds Or ERP7__RMA_Line_Item__c In :OrderLineIds) AND ERP7__Logistic_Line_Item__c In :LOLIIds order by CreatedDate ASC';
        List<ERP7__Stock_Inward_Line_Item__c> SPLIS = [Select Id,ERP7__Quantity__c,ERP7__Logistic_Line_Item__c, ERP7__Status__c,ERP7__Location__c,ERP7__StorageContainer__c, Name, ERP7__Material_Batch_Lot__c,ERP7__Serial__c,ERP7__Transfer_Order_Line_Item__c,ERP7__RMA_Line_Item__c,ERP7__Serial_Number__c,ERP7__Product__c, ERP7__Product__r.Name,ERP7__Logistic__r.Name,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Serial__r.Name,ERP7__Material_Batch_Lot__r.Name,ERP7__Location__r.Name,ERP7__Product__r.ERP7__Is_OverSized_Item__c,ERP7__Product__r.ERP7__Quality_Check_QA__c from ERP7__Stock_Inward_Line_Item__c where (ERP7__Transfer_Order_Line_Item__c In :OrderLineIds Or ERP7__Work_Order_Line_Items__c In :OrderLineIds Or ERP7__Purchase_Line_Items__c In :OrderLineIds Or ERP7__RMA_Line_Item__c In :OrderLineIds) AND ERP7__Logistic_Line_Item__c In :LOLIIds order by CreatedDate ASC];
        Map<String,List<ERP7__Stock_Inward_Line_Item__c>> loliSILIMap = new Map<String,List<ERP7__Stock_Inward_Line_Item__c>>();
        Map<Id,Decimal> SILIqtyMap = new Map<Id,Decimal>();
        set<Id> receivedSerialIds= new set<Id>();
        set<Id> receivedSili= new set<Id>();
        for(ERP7__Stock_Inward_Line_Item__c sli : SPLIS){
            //if(sli.ERP7__Status__c != '') sli.ERP7__Status__c = toLabel(sli.ERP7__Status__c); //Arshad 05july
            receivedSili.add(sli.Id);
            if(sli.ERP7__Serial__c != null) receivedSerialIds.add(sli.ERP7__Serial__c);
            if(sli.ERP7__Logistic_Line_Item__c != null){
                if(loliSILIMap.containsKey(sli.ERP7__Logistic_Line_Item__c)) loliSILIMap.get(sli.ERP7__Logistic_Line_Item__c).add(sli); else loliSILIMap.put(sli.ERP7__Logistic_Line_Item__c,New List<ERP7__Stock_Inward_Line_Item__c>{sli});
            }
        }
        
        // Stock outwards for transfer order
        List<ERP7__Stock_Outward_Line_Item__c> stockoutwards = new List<ERP7__Stock_Outward_Line_Item__c>();
        system.debug('receivedSerialIds : '+receivedSerialIds.size() );
        system.debug('TOIds : '+TOIds.size());
        if(TOIds.size() > 0 && receivedSerialIds.size() > 0) stockoutwards =  [Select Id,Name,ERP7__Serial__c,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Serial__r.ERP7__Serial_No__c, ERP7__Material_Batch_Lot__c,ERP7__Transfer_Order_Line_Item__c,ERP7__Transfer_Order__c from ERP7__Stock_Outward_Line_Item__c where ERP7__Transfer_Order_Line_Item__c IN :OrderLineIds and ERP7__Transfer_Order__c IN: TOIds and ERP7__Serial__c NOT IN :receivedSerialIds];
        else if(TOIds.size() > 0) stockoutwards =  [Select Id,Name,ERP7__Serial__c,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Serial__r.ERP7__Serial_No__c, ERP7__Material_Batch_Lot__c,ERP7__Transfer_Order_Line_Item__c,ERP7__Transfer_Order__c from ERP7__Stock_Outward_Line_Item__c where ERP7__Transfer_Order_Line_Item__c IN :OrderLineIds and ERP7__Transfer_Order__c IN: TOIds];
        system.debug('stockoutwards : '+stockoutwards.size());
        
        // comW.SILILOLI = SPLIS;
        for(ERP7__Logistic_Line_Item__c poli : Lolis){
            if(poli.ERP7__Product__r.ERP7__Quality_Check_QA__c) QAProdIds.add(poli.ERP7__Product__c); // 20_03
            decimal totalqty = 0;
            if(loliSILIMap.containsKey(poli.Id)){
                system.debug('totalqty : '+totalqty);
                List<ERP7__Stock_Inward_Line_Item__c> allsili =  loliSILIMap.get(poli.Id);
                for(ERP7__Stock_Inward_Line_Item__c sili1 :  allsili){ totalqty += sili1.ERP7__Quantity__c;  }
                system.debug('totalqty : '+totalqty);
                if(totalqty > 0) SILIqtyMap.put(poli.Id,totalqty);
            }
        }
        
        system.debug('QAProdIds : '+QAProdIds.size());
        system.debug('receivedSili : '+receivedSili.size());
        
        List<ERP7__Checklist__c> checklists = new List<ERP7__Checklist__c>();
        checklists = [Select Id,Name,ERP7__Is_Mandatory__c,ERP7__Action_Detail__c ,ERP7__Has_Checklist__c, toLabel(ERP7__Comply__c), toLabel(ERP7__Result__c), ERP7__Notes__c, ERP7__Product__c   
                      from ERP7__Checklist__c where ERP7__Product__c != null AND ERP7__Product__c IN: QAProdIds AND ERP7__Product__r.ERP7__Quality_Check_QA__c = true Order by createdDate asc];
        
        system.debug('checklists : '+checklists.size());
        
        Map<Id, UserRecordAccess> userAccessMap = new Map<Id, UserRecordAccess>();
        if(checklists.size() > 0){            Set<Id> checklistIds = new Set<Id>();
            for(ERP7__Checklist__c chk: checklists){ checklistIds.add(chk.Id); }
            userAccessMap = new Map<Id, UserRecordAccess>([SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :checklistIds]);
        }
        
        List<ERP7__Guideline_Checklists__c> enteredChecklists = new List<ERP7__Guideline_Checklists__c>();
        
        if(receivedSili.size() > 0){
            enteredChecklists = [Select Id, Name, ERP7__Has_Checklist__c,ERP7__Checklist__c,ERP7__Is_Mandatory__c, ERP7__Status__c,ERP7__Instructions__c, ERP7__Stock_Inward_Line_Item__c, ERP7__Checklist__r.ERP7__Is_Mandatory__c, ERP7__Checklist__r.ERP7__Action_Detail__c, ERP7__Checklist__r.ERP7__Has_Checklist__c,ERP7__Checklist__r.Name, toLabel(ERP7__Checklist__r.ERP7__Comply__c), toLabel(ERP7__Checklist__r.ERP7__Result__c), ERP7__Checklist__r.ERP7__Product__c,
                                 (Select Id, Name, ParentId from Attachments) 
                                 from ERP7__Guideline_Checklists__c where ERP7__Stock_Inward_Line_Item__c IN: receivedSili AND ERP7__Checklist__c != null AND ERP7__Stock_Inward_Line_Item__c != null];
        }
        
        system.debug('enteredChecklists : '+enteredChecklists.size());
        
        Map<String,List<ERP7__Guideline_Checklists__c>> guideMAp = new Map<String,List<ERP7__Guideline_Checklists__c>>();
        for(ERP7__Guideline_Checklists__c guide: enteredChecklists){
            String key = ''+guide.ERP7__Stock_Inward_Line_Item__c+guide.ERP7__Checklist__c;
            system.debug('key setting~>'+key);
            if(guideMAp.containsKey(key)) guideMAp.get(key).add(guide);
            else guideMAp.put(key, new List<ERP7__Guideline_Checklists__c>{guide});
        }
        
        for(ERP7__Stock_Inward_Line_Item__c stinReceived : SPLIS){
            ReceivedSILIWrap wrapReceive = new ReceivedSILIWrap();            wrapReceive.sili = stinReceived;
            
            for(ERP7__Checklist__c check : checklists){                String key = ''+stinReceived.Id+check.Id;
                system.debug('key checkinghere~>'+key);
                system.debug('check name : '+check.Name);
                system.debug('guideMAp.containsKey(key)~>'+guideMAp.containsKey(key));
                if(guideMAp.containsKey(key)){
                    system.debug('inhere1');
                    wrapReceive.guideline.addAll(guideMAp.get(key));
                    system.debug('wrapReceive.guideline~>'+wrapReceive.guideline.size());
                    for(ERP7__Guideline_Checklists__c gu : wrapReceive.guideline){
                        if(gu.ERP7__Checklist__c != null){
                            UserRecordAccess userAccess = (userAccessMap.containsKey(gu.ERP7__Checklist__c)) ? userAccessMap.get(gu.ERP7__Checklist__c) : null;
                            gu.Name = gu.ERP7__Checklist__r.Name;
                            if(gu.ERP7__Checklist__r.ERP7__Comply__c != null && gu.ERP7__Checklist__r.ERP7__Comply__c != '' && gu.ERP7__Checklist__r.ERP7__Comply__c != '--None--') gu.Name = gu.ERP7__Checklist__r.ERP7__Comply__c; 
                            gu.ERP7__Is_Mandatory__c = false;
                            gu.ERP7__Has_Checklist__c = gu.ERP7__Checklist__r.ERP7__Has_Checklist__c;
                            if (userAccess != null){
                                if(userAccess.HasEditAccess) gu.ERP7__Is_Mandatory__c = true; //set to true if it has edit access - used to disable picklist/input on UI
                            }
                        }
                    }
                }
                else{
                    if(check.ERP7__Product__c == stinReceived.ERP7__Product__c){
                        system.debug('inhere2');
                        UserRecordAccess userAccess = (userAccessMap.containsKey(check.Id)) ? userAccessMap.get(check.Id) : null;
                        ERP7__Guideline_Checklists__c guideChecks = new ERP7__Guideline_Checklists__c();
                        guideChecks.Name = check.Name;
                        system.debug('check.ERP7__Comply__c : '+check.ERP7__Comply__c);
                        if(check.ERP7__Comply__c != null && check.ERP7__Comply__c != '' && check.ERP7__Comply__c != '--None--') guideChecks.Name = check.ERP7__Comply__c; 
                        guideChecks.ERP7__Checklist__c = check.Id;
                        guideChecks.ERP7__Checklist__r = new  ERP7__Checklist__c(ERP7__Is_Mandatory__c = check.ERP7__Is_Mandatory__c,ERP7__Comply__c = check.ERP7__Comply__c,ERP7__Result__c = check.ERP7__Result__c,ERP7__Notes__c = check.ERP7__Notes__c); 
                        guideChecks.ERP7__Instructions__c  = check.ERP7__Has_Checklist__c ? check.ERP7__Result__c : check.ERP7__Action_Detail__c;
                        if(check.ERP7__Has_Checklist__c) guideChecks.ERP7__Status__c = check.ERP7__Result__c; // added by shaguftha on 05_07_24 to set status only when it has checklists
                        guideChecks.ERP7__Stock_Inward_Line_Item__c = stinReceived.Id;
                        guideChecks.ERP7__Is_Mandatory__c = false;
                        guideChecks.ERP7__Has_Checklist__c = check.ERP7__Has_Checklist__c;
                        if (userAccess != null){
                            if(userAccess.HasEditAccess) guideChecks.ERP7__Is_Mandatory__c = true; //set to true if it has edit access - used to disable picklist/input on UI
                        }
                        system.debug('guideChecks : '+guideChecks);
                        wrapReceive.guideline.add(guideChecks);
                    }
                }
            }
           
           
            comW.SILILOLI.add(wrapReceive);
        }
        
        Map<Id,ERP7__Stock_Inward_Line_Item__c> assignedSerials = new  Map<Id,ERP7__Stock_Inward_Line_Item__c>();
        for(ERP7__Logistic_Line_Item__c poli : Lolis){
            string batchId = '';
            Integer x = 0;
            if(poli.ERP7__Product__c != null){
                
                List<newStockwrap> stkwraplist = new List<newStockwrap>();
                decimal requiredqty = 0;
                decimal receivedqty = 0;
                if(SILIqtyMap.containsKey(poli.Id)){                    receivedqty = SILIqtyMap.get(poli.Id); requiredqty = poli.ERP7__Quantity__c - SILIqtyMap.get(poli.Id);
                    system.debug(' poli.ERP7__Quantity__c : '+ poli.ERP7__Quantity__c);
                    system.debug('  SILIqtyMap.get(poli.Id) : '+  SILIqtyMap.get(poli.Id));
                }
                else requiredqty = poli.ERP7__Quantity__c;
                
                system.debug('receivedqty : '+receivedqty);
                system.debug('requiredqty : '+requiredqty);
                if(poli.ERP7__Product__r.ERP7__Serialise__c){
                    for(Integer i=0; i<requiredqty; i++){
                        ERP7__Stock_Inward_Line_Item__c silinew = new ERP7__Stock_Inward_Line_Item__c(); 
                        silinew.ERP7__Active__c = true;
                        silinew.Name = poli.ERP7__Product__r.Name;
                        system.debug('comW.showInboundQA : '+comW.showInboundQA);
                        system.debug('poli.ERP7__Product__r.ERP7__Quality_Check_QA__c : '+poli.ERP7__Product__r.ERP7__Quality_Check_QA__c);
                        if(comW.showInboundQA && poli.ERP7__Product__r.ERP7__Quality_Check_QA__c) silinew.ERP7__Status__c = statusMap.containsKey(System.Label.Quality_Check_QA) ? statusMap.get(System.Label.Quality_Check_QA) : System.Label.Quality_Check_QA;
                        else if(comW.showInboundQA && !poli.ERP7__Product__r.ERP7__Quality_Check_QA__c) silinew.ERP7__Status__c = statusMap.containsKey(System.Label.InStockPickListValue) ? statusMap.get(System.Label.InStockPickListValue) : System.Label.InStockPickListValue;
                        else if(comW.showStatus && (silinew.ERP7__Status__c == null || silinew.ERP7__Status__c == '')) silinew.ERP7__Status__c = statusMap.containsKey(System.Label.StatusOfInwardForQA) ? statusMap.get(System.Label.StatusOfInwardForQA) : System.Label.StatusOfInwardForQA; 
                        silinew.ERP7__Logistic__c = poli.ERP7__Logistic__c;
                        silinew.ERP7__Logistic_Line_Item__c = poli.Id;
                        silinew.ERP7__Logistic_Line_Item__r = poli;
                        silinew.ERP7__Product__c = poli.ERP7__Product__c;
                        silinew.ERP7__Product__r = new Product2(Id=poli.ERP7__Product__c,Name=poli.ERP7__Product__r.Name,ERP7__Lot_Tracked__c=poli.ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Serialise__c = poli.ERP7__Product__r.ERP7__Serialise__c, ERP7__Barcode__c =poli.ERP7__Product__r.ERP7__Barcode__c,ERP7__Is_OverSized_Item__c = poli.ERP7__Product__r.ERP7__Is_OverSized_Item__c);
                        if(poli.ERP7__Product__r.ERP7__Default_Location__r.ERP7__Site__c == poli.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c) silinew.ERP7__Location__c = poli.ERP7__Product__r.ERP7__Default_Location__c;
                        else if(defaultloc.size() == 1) silinew.ERP7__Location__c = defaultloc[0].Id;
                        silinew.ERP7__Quantity__c =1;
                        if(poli.ERP7__Purchase_Line_Items__c != null) {
                            silinew.ERP7__Purchase_Line_Items__c = poli.ERP7__Purchase_Line_Items__c;
                            silinew.ERP7__Purchase_Orders__c = poli.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c;
                        }
                        if(poli.ERP7__Transfer_Order_Line_Item__c != null) {                            silinew.ERP7__Transfer_Order_Line_Item__c = poli.ERP7__Transfer_Order_Line_Item__c;
                            silinew.ERP7__Transfer_Order__c = poli.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c;
                            if(stockoutwards.size() > 0){
                                for(Integer j=i; j < stockoutwards.size(); j++){
                                    system.debug('j : '+j);
                                    system.debug('silinew.ERP7__Serial__c : '+silinew.ERP7__Serial__c);
                                    if(stockoutwards[j].ERP7__Transfer_Order_Line_Item__c == poli.ERP7__Transfer_Order_Line_Item__c && !assignedSerials.containsKey(stockoutwards[j].ERP7__Serial__c)){
                                        system.debug('if');
                                        silinew.ERP7__Serial__c = stockoutwards[j].ERP7__Serial__c;
                                        silinew.ERP7__Serial_Number__c = stockoutwards[j].ERP7__Serial__r.ERP7__Serial_No__c;
                                        //silinew.ERP7__Serial_Number__c = stockoutwards[j].ERP7__Serial__r.ERP7__Serial_Number__c;
                                        silinew.ERP7__Material_Batch_Lot__c=   stockoutwards[j].ERP7__Material_Batch_Lot__c;
                                        batchId =  stockoutwards[j].ERP7__Material_Batch_Lot__c;
                                        break;
                                    }
                                }
                            }
                        }
                        if(poli.ERP7__RMA_Line_Item__c != null) {
                            silinew.ERP7__RMA_Line_Item__c = poli.ERP7__RMA_Line_Item__c;                            silinew.ERP7__RMA__c = poli.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c;
                            if(poli.ERP7__RMA_Line_Item__r.ERP7__Serial_Number__c != null){
                                if(String.isNotEmpty(poli.ERP7__RMA_Line_Item__r.ERP7__Serial_Number__r.ERP7__Serial_No__c)){
                                    silinew.ERP7__Serial__c = poli.ERP7__RMA_Line_Item__r.ERP7__Serial_Number__c;
                                    silinew.ERP7__Serial_Number__c = poli.ERP7__RMA_Line_Item__r.ERP7__Serial_Number__r.ERP7__Serial_No__c;
                                }
                            }
                        }
                        stkwraplist.add(new newStockwrap(silinew,false,poli.ERP7__Remaining_Quantity__c,receivedqty,1,poli.Id));
                        comW.SPLIS.add(new newStockwrap(silinew,false,poli.ERP7__Remaining_Quantity__c,receivedqty,1,poli.Id));
                        system.debug('silinew.ERP7__Serial__c : '+silinew.ERP7__Serial__c);
                        system.debug('assignedSerials.containsKey(silinew.ERP7__Serial__c) :'+assignedSerials.containsKey(silinew.ERP7__Serial__c));
                        if(silinew.ERP7__Serial__c != null) assignedSerials.put(silinew.ERP7__Serial__c,silinew);
                        system.debug('assignedSerials : '+assignedSerials.size());
                    }
                }
                else{
                    ERP7__Stock_Inward_Line_Item__c silinew = new ERP7__Stock_Inward_Line_Item__c();
                    silinew.ERP7__Active__c = true;
                    if(comW.showInboundQA && poli.ERP7__Product__r.ERP7__Quality_Check_QA__c) silinew.ERP7__Status__c = statusMap.containsKey(System.Label.Quality_Check_QA) ? statusMap.get(System.Label.Quality_Check_QA) : System.Label.Quality_Check_QA; 
                    else if(comW.showInboundQA && !poli.ERP7__Product__r.ERP7__Quality_Check_QA__c) silinew.ERP7__Status__c = statusMap.containsKey(System.Label.InStockPickListValue) ? statusMap.get(System.Label.InStockPickListValue) : System.Label.InStockPickListValue; 
                    else if(comW.showStatus && (silinew.ERP7__Status__c == null || silinew.ERP7__Status__c == ''))  silinew.ERP7__Status__c =  statusMap.containsKey(System.Label.StatusOfInwardForQA) ? statusMap.get(System.Label.StatusOfInwardForQA) : System.Label.StatusOfInwardForQA; 
                    silinew.Name = poli.ERP7__Product__r.Name;
                    silinew.ERP7__Logistic__c = poli.ERP7__Logistic__c;
                    silinew.ERP7__Logistic_Line_Item__c = poli.Id;
                    silinew.ERP7__Logistic_Line_Item__r = poli;
                    //silinew.ERP7__Logistic_Line_Item__r = new ERP7__Logistic_Line_Item__c(ERP7__Quantity__c = poli.ERP7__Quantity__c,ERP7__Quantity_Received__c = poli.ERP7__Quantity_Received__c);
                    silinew.ERP7__Product__c = poli.ERP7__Product__c;
                    silinew.ERP7__Product__r = new Product2(Id=poli.ERP7__Product__c,Name=poli.ERP7__Product__r.Name,ERP7__Lot_Tracked__c=poli.ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Serialise__c = poli.ERP7__Product__r.ERP7__Serialise__c, ERP7__Barcode__c =poli.ERP7__Product__r.ERP7__Barcode__c,ERP7__Is_OverSized_Item__c = poli.ERP7__Product__r.ERP7__Is_OverSized_Item__c);
                    if(poli.ERP7__Product__r.ERP7__Default_Location__r.ERP7__Site__c == poli.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c) silinew.ERP7__Location__c = poli.ERP7__Product__r.ERP7__Default_Location__c;
                    else if(defaultloc.size() == 1) silinew.ERP7__Location__c = defaultloc[0].Id;   
                    if(SILIqtyMap.containsKey(poli.Id)) silinew.ERP7__Quantity__c = poli.ERP7__Quantity__c - SILIqtyMap.get(poli.Id);
                    else silinew.ERP7__Quantity__c = poli.ERP7__Quantity__c;
                    system.debug('silinew.ERP7__Quantity__c  : '+silinew.ERP7__Quantity__c );
                    if(poli.ERP7__Purchase_Line_Items__c != null) {
                        silinew.ERP7__Purchase_Line_Items__c = poli.ERP7__Purchase_Line_Items__c;
                        silinew.ERP7__Purchase_Orders__c = poli.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c;
                    }
                    if(poli.ERP7__Transfer_Order_Line_Item__c != null) {
                        silinew.ERP7__Transfer_Order_Line_Item__c = poli.ERP7__Transfer_Order_Line_Item__c;
                        silinew.ERP7__Transfer_Order__c = poli.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c;
                        if(stockoutwards.size() > 0){
                            for(Integer j=0; j < stockoutwards.size(); j++){ //ERP7__Stock_Outward_Line_Item__c stout : stockoutwards){
                                if(stockoutwards[j].ERP7__Transfer_Order_Line_Item__c == poli.ERP7__Transfer_Order_Line_Item__c && x == j){
                                    silinew.ERP7__Material_Batch_Lot__c=   stockoutwards[j].ERP7__Material_Batch_Lot__c;                                    batchId =  stockoutwards[j].ERP7__Material_Batch_Lot__c;
                                }
                            }
                        }
                    }
                    if(poli.ERP7__RMA_Line_Item__c != null) {                        silinew.ERP7__RMA_Line_Item__c = poli.ERP7__RMA_Line_Item__c; silinew.ERP7__RMA__c = poli.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c;
                    }
                    if(silinew.ERP7__Quantity__c > 0){
                        stkwraplist.add(new newStockwrap(silinew,false,poli.ERP7__Remaining_Quantity__c,receivedqty,poli.ERP7__Quantity__c,poli.Id));
                        comW.SPLIS.add(new newStockwrap(silinew,false,poli.ERP7__Remaining_Quantity__c,receivedqty,poli.ERP7__Quantity__c,poli.Id));
                    } 
                }
                if (stkwraplist.size() > 0) {
                    comW.LOLIS.add(new LOLISPLIS(
                        poli,
                        poli.ERP7__Product__c,
                        poli.ERP7__Product__r != null ? poli.ERP7__Product__r.ERP7__Barcode__c : null,
                        poli.ERP7__Product__r != null ? poli.ERP7__Product__r.ERP7__Serialise__c : null,
                        poli.ERP7__Product__r != null ? poli.ERP7__Product__r.ERP7__Lot_Tracked__c : null,
                        poli.Id,
                        poli.ERP7__Quantity__c,
                        poli.ERP7__Remaining_Quantity__c,
                        receivedqty,
                        batchId,
                        stkwraplist.size(),
                        poli.ERP7__Product__r != null ? !poli.ERP7__Product__r.ERP7__Is_OverSized_Item__c : false,
                        mapList.containsKey(poli.Id) ? mapList.get(poli.Id) : new List<ContentDocumentLink>(),
                        mapAttchList.containsKey(poli.Id) ? mapAttchList.get(poli.Id) : new List<Attachment>()
                    ));
                }
                
                //if(stkwraplist.size() > 0) comW.LOLIS.add(new LOLISPLIS(poli,poli.ERP7__Product__c,poli.ERP7__Product__r.ERP7__Barcode__c,poli.ERP7__Product__r.ERP7__Serialise__c,poli.ERP7__Product__r.ERP7__Lot_Tracked__c,poli.Id,poli.ERP7__Quantity__c,poli.ERP7__Remaining_Quantity__c,receivedqty,batchId,stkwraplist.size(),!poli.ERP7__Product__r.ERP7__Is_OverSized_Item__c,mapList.containskey(poli.Id) ? mapList.get(poli.Id)) : new List<ContentDocumentLink>(),mapAttchList.containskey(poli.Id) ? mapAttchList.get(poli.Id) : new List<Attachement>());
                // else if (stkwraplist.size() > 0) comW.LOLIS.add(new LOLISPLIS(poli,poli.ERP7__Product__c,poli.ERP7__Product__r.ERP7__Barcode__c,poli.ERP7__Product__r.ERP7__Serialise__c,poli.ERP7__Product__r.ERP7__Lot_Tracked__c,poli.Id,poli.ERP7__Quantity__c,poli.ERP7__Remaining_Quantity__c,receivedqty,batchId,stkwraplist.size(),!poli.ERP7__Product__r.ERP7__Is_OverSized_Item__c,new List<ContentDocumentLink>()));
                x++;
            }
        }
        
        
        return comW;
    }
      
   @AuraEnabled
  public static comWrap saveAlldetail(String sili,string selectecSite,String createdsili){ system.debug('sili : '+sili); comWrap cmw = new comWrap(); Savepoint sp = Database.setSavepoint(); try{ system.debug('createdsili : '+createdsili); Object deserializedSili = JSON.deserializeUntyped(sili); List<Map<String, Object>> siliRawList = new List<Map<String, Object>>(); System.debug('siliRawList : '+siliRawList); if (deserializedSili instanceof List<Object>) { for (Object item : (List<Object>) deserializedSili) { if (item instanceof Map<String, Object>) { siliRawList.add((Map<String, Object>) item); } else { System.debug('Warning: JSON item is not a Map<String, Object> at index ' + siliRawList.size()); } } } else { System.debug('Error: sili JSON did not deserialize to a List<Object>'); throw new DmlException('Failed to update existing inventories: '); } Map<String, Date> expiryDateMap = new Map<String, Date>(); Map<String, Date> serialExpiryDateMap = new Map<String, Date>(); for (Map<String, Object> siliRaw : siliRawList) { String logisticLineItemId = String.valueOf(siliRaw.get('ERP7__Logistic_Line_Item__c')); String serialNumber = String.valueOf(siliRaw.get('ERP7__Serial_Number__c')); String expiryDateStr = String.valueOf(siliRaw.get('ERP7__Expiry_Date__c')); if (String.isNotBlank(expiryDateStr) && String.isNotBlank(logisticLineItemId)) { try { Date expiryDate = Date.valueOf(expiryDateStr); if (String.isNotBlank(serialNumber)) {                            String serialKey = logisticLineItemId + '-' + serialNumber; serialExpiryDateMap.put(serialKey, expiryDate); system.debug('Added to serialExpiryDateMap: ' + serialKey + ' => ' + expiryDate); } else { expiryDateMap.put(logisticLineItemId, expiryDate); system.debug('Added to expiryDateMap: ' + logisticLineItemId + ' => ' + expiryDate); } } catch (Exception e) { system.debug('Invalid date format for ERP7__Expiry_Date__c: ' + expiryDateStr + '; Error: ' + e.getMessage()); } } else { system.debug('Skipping expiry date mapping: Missing logisticLineItemId or expiryDateStr for ' + siliRaw); } } system.debug('serialExpiryDateMap: ' + serialExpiryDateMap); System.debug('expiryDateMap : ' + expiryDateMap); List<ERP7__Stock_Inward_Line_Item__c> siliLst = (List<ERP7__Stock_Inward_Line_Item__c>) JSON.deserialize(sili,List<ERP7__Stock_Inward_Line_Item__c>.class); System.debug(' siliLst : '+siliLst); List<ReceivedSILIWrap> sili2updateWrap = new List<ReceivedSILIWrap>(); if(createdsili != null && createdsili != '')    sili2updateWrap = (List<ReceivedSILIWrap>) JSON.deserialize(createdsili,List<ReceivedSILIWrap>.class); List<ERP7__Stock_Inward_Line_Item__c> sili2return = new List<ERP7__Stock_Inward_Line_Item__c>(); List<ERP7__Stock_Inward_Line_Item__c> sili2update = new List<ERP7__Stock_Inward_Line_Item__c>(); List<ERP7__Guideline_Checklists__c>  guidelines2update = new List<ERP7__Guideline_Checklists__c>(); Map<Id,Id> invprodMap = new Map<Id,Id>(); Map<Id, List<ERP7__Inventory_Stock__c>> prodInvM = new Map<Id, List<ERP7__Inventory_Stock__c>>(); Map<String,ERP7__Inventory_Stock__c> ProdNWL=new Map<String,ERP7__Inventory_Stock__c>(); Map<String,ERP7__Inventory_Stock__c> ProdBT=new Map<String,ERP7__Inventory_Stock__c>(); set<Id> receivedserials = new set<Id>(); set<Id> receivedSili = new set<Id>(); Map<String,ERP7__Inventory_Stock__c> invmap = new Map<String,ERP7__Inventory_Stock__c>(); Map<string,ERP7__Serial_Number__c> serMap = new Map<string,ERP7__Serial_Number__c>(); set<Id> QAProdIds = new Set<Id>(); set<String> logisticIDs = new set<String>(); set<String> MOIDs = new set<String>(); if(sili2updateWrap.size() > 0) { for(ReceivedSILIWrap wrap : sili2updateWrap){ sili2update.add(wrap.sili); system.debug('sili wrap status : '+wrap.sili.ERP7__Status__c); if(wrap.guideline != null) guidelines2update.addAll(wrap.guideline); } System.debug('First set silis updates'); update sili2update; for(ERP7__Stock_Inward_Line_Item__c sinw : sili2update){ if(sinw.ERP7__Logistic__c != null) logisticIDs.add(sinw.ERP7__Logistic__c); if(sinw.ERP7__Manufacturing_Order__c != null) MOIDs.add(sinw.ERP7__Manufacturing_Order__c); if(sinw.ERP7__Product__c != null){ QAProdIds.add(sinw.ERP7__Product__c); } receivedSili.add(sinw.Id); if(sinw.ERP7__Serial__c != null) receivedserials.add(sinw.ERP7__Serial__c); } } system.debug('QAProdIds : '+QAProdIds.size()); List<ERP7__Checklist__c> checklists = new List<ERP7__Checklist__c>(); checklists = [Select Id,Name,ERP7__Is_Mandatory__c,ERP7__Action_Detail__c ,ERP7__Has_Checklist__c, toLabel(ERP7__Comply__c), toLabel(ERP7__Result__c), ERP7__Notes__c, ERP7__Product__c from ERP7__Checklist__c where ERP7__Product__c != null AND ERP7__Product__c IN: QAProdIds AND ERP7__Product__r.ERP7__Quality_Check_QA__c = true Order by createdDate asc]; Map<Id, UserRecordAccess> userAccessMap = new Map<Id, UserRecordAccess>(); if(checklists.size() > 0){               Set<Id> checklistIds = new Set<Id>(); for(ERP7__Checklist__c chk: checklists){ checklistIds.add(chk.Id); } userAccessMap = new Map<Id, UserRecordAccess>([SELECT RecordId, HasEditAccess  FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId IN :checklistIds]); } if(guidelines2update.size() > 0){ List<ERP7__Guideline_Checklists__c> updatedGuidelines = new List<ERP7__Guideline_Checklists__c>(); for(ERP7__Guideline_Checklists__c guide : guidelines2update){ if(guide.ERP7__Checklist__c != null){ UserRecordAccess userAccess = (userAccessMap.containsKey(guide.ERP7__Checklist__c)) ? userAccessMap.get(guide.ERP7__Checklist__c) : null; if (userAccess != null){ if(userAccess.HasEditAccess){ if(guide.ERP7__Checklist__r.ERP7__Has_Checklist__c) guide.ERP7__Status__c = guide.ERP7__Instructions__c; guide.ERP7__Checklist__r = null; guide.ERP7__Is_Mandatory__c = false; updatedGuidelines.add(guide); } } } } upsert updatedGuidelines; } List<ERP7__Guideline_Checklists__c> enteredChecklists = new List<ERP7__Guideline_Checklists__c>(); if(receivedSili.size() > 0){ enteredChecklists = [Select Id, Name, ERP7__Has_Checklist__c,ERP7__Checklist__c,ERP7__Is_Mandatory__c, ERP7__Status__c, ERP7__Instructions__c, ERP7__Stock_Inward_Line_Item__c, ERP7__Checklist__r.ERP7__Is_Mandatory__c, ERP7__Checklist__r.ERP7__Action_Detail__c, ERP7__Checklist__r.ERP7__Has_Checklist__c,ERP7__Checklist__r.Name, toLabel(ERP7__Checklist__r.ERP7__Comply__c), toLabel(ERP7__Checklist__r.ERP7__Result__c), ERP7__Checklist__r.ERP7__Product__c, (Select Id, Name, ParentId from Attachments) from ERP7__Guideline_Checklists__c where ERP7__Stock_Inward_Line_Item__c IN: receivedSili AND ERP7__Checklist__c != null AND ERP7__Stock_Inward_Line_Item__c != null]; } Map<String,List<ERP7__Guideline_Checklists__c>> guideMAp = new Map<String,List<ERP7__Guideline_Checklists__c>>(); for(ERP7__Guideline_Checklists__c guide: enteredChecklists){ String key = ''+guide.ERP7__Stock_Inward_Line_Item__c+guide.ERP7__Checklist__c; system.debug('key setting~>'+key); if(guideMAp.containsKey(key)) guideMAp.get(key).add(guide); else guideMAp.put(key, new List<ERP7__Guideline_Checklists__c>{guide}); } for(ERP7__Stock_Inward_Line_Item__c stinReceived : sili2update){ ReceivedSILIWrap wrapReceive = new ReceivedSILIWrap(); wrapReceive.sili = stinReceived; for(ERP7__Checklist__c check : checklists){                   String key = ''+stinReceived.Id+check.Id; system.debug('key checkinghere~>'+key); system.debug('guideMAp.containsKey(key)~>'+guideMAp.containsKey(key)); if(guideMAp.containsKey(key)){ system.debug('inhere1'); wrapReceive.guideline.addAll(guideMAp.get(key)); system.debug('wrapReceive.guideline~>'+wrapReceive.guideline.size()); for(ERP7__Guideline_Checklists__c gu : wrapReceive.guideline){ if(gu.ERP7__Checklist__c != null){ UserRecordAccess userAccess = (userAccessMap.containsKey(gu.ERP7__Checklist__c)) ? userAccessMap.get(gu.ERP7__Checklist__c) : null; gu.Name = gu.ERP7__Checklist__r.Name; if(gu.ERP7__Checklist__r.ERP7__Comply__c != null && gu.ERP7__Checklist__r.ERP7__Comply__c != '' && gu.ERP7__Checklist__r.ERP7__Comply__c != '--None--') gu.Name = gu.ERP7__Checklist__r.ERP7__Comply__c; gu.ERP7__Is_Mandatory__c = false; gu.ERP7__Has_checklist__c = gu.ERP7__Checklist__r.ERP7__Has_checklist__c; if (userAccess != null){ if(userAccess.HasEditAccess) gu.ERP7__Is_Mandatory__c = true; } } } } else{ if(check.ERP7__Product__c == stinReceived.ERP7__Product__c){ system.debug('inhere2'); UserRecordAccess userAccess = (userAccessMap.containsKey(check.Id)) ? userAccessMap.get(check.Id) : null; ERP7__Guideline_Checklists__c guideChecks = new ERP7__Guideline_Checklists__c();                           guideChecks.Name = check.Name; if(check.ERP7__Comply__c !=  null && check.ERP7__Comply__c != '' && check.ERP7__Comply__c != '--None--') guideChecks.Name = check.ERP7__Comply__c; guideChecks.ERP7__Checklist__c = check.Id; guideChecks.ERP7__Checklist__r = new  ERP7__Checklist__c(ERP7__Is_Mandatory__c = check.ERP7__Is_Mandatory__c,ERP7__Comply__c = check.ERP7__Comply__c,ERP7__Result__c = check.ERP7__Result__c,ERP7__Notes__c = check.ERP7__Notes__c); guideChecks.ERP7__Instructions__c = check.ERP7__Has_Checklist__c ? check.ERP7__Result__c : check.ERP7__Action_Detail__c; if(check.ERP7__Has_Checklist__c) guideChecks.ERP7__Status__c = check.ERP7__Result__c; guideChecks.ERP7__Has_checklist__c = check.ERP7__Has_checklist__c; guideChecks.ERP7__Stock_Inward_Line_Item__c = stinReceived.Id; guideChecks.ERP7__Is_Mandatory__c = false; if (userAccess != null){ if(userAccess.HasEditAccess) guideChecks.ERP7__Is_Mandatory__c = true; } wrapReceive.guideline.add(guideChecks); } } } cmw.SILILOLI.add(wrapReceive); } if(siliLst.size() > 0){ set<Id> logIDs = new set<Id>(); logisticIDs = new set<String>(); set<Id> batchIds = new set<Id>(); set<Id> ProdIds = new set<Id>(); set<Id> serialIDs = new set<Id>(); List<ERP7__Serial_Number__c> serials2Upsert = new List<ERP7__Serial_Number__c>(); List<ERP7__Inventory_Stock__c> invlst = new List<ERP7__Inventory_Stock__c>(); Map<String,Decimal> totalReceivedQty = new  Map<String,Decimal>(); Map<Id,List<ERP7__Inventory_Stock__c>> invbatchMap = new  Map<id,List<ERP7__Inventory_Stock__c>>(); Map<Id,List<ERP7__Inventory_Stock__c>> invNormProdMap = new  Map<id,List<ERP7__Inventory_Stock__c>>(); Map<Id,ERP7__Inventory_Stock__c> invSerialProdMap = new  Map<id,ERP7__Inventory_Stock__c>(); system.debug('siliLst : '+siliLst.size()); for(ERP7__Stock_Inward_Line_Item__c sil1 : siliLst){ if(sil1.ERP7__Material_Batch_Lot__c != null) batchIds.add(sil1.ERP7__Material_Batch_Lot__c); if(sil1.ERP7__Material_Batch_Lot__c == null && sil1.ERP7__Serial_Number__c == null) ProdIds.add(sil1.ERP7__Product__c); if(sil1.ERP7__Serial__c != null) { ProdIds.add(sil1.ERP7__Product__c);  serialIDs.add(sil1.ERP7__Serial__c); } } List<ERP7__Inventory_Stock__c> invbatch = [Select Id,Name,ERP7__Location__c,ERP7__Batch_Lot__c,ERP7__Product__c,ERP7__StorageContainer__c from ERP7__Inventory_Stock__c where ERP7__Active__c = true and (ERP7__Batch_Lot__c In:batchIds or ERP7__Product__c In:ProdIds) and ERP7__Serial__c = null  and ERP7__Warehouse__c = :selectecSite and Name != 'Awaiting Stock' and (ERP7__Number_of_Items_In_Quality_Check__c > 0 or ERP7__Number_of_Item_In_Stock__c > 0) Order By CreatedDate ASC LIMIT 2000]; if(invbatch.size() > 0){ for(ERP7__Inventory_Stock__c inv : invbatch){ if(inv.ERP7__Batch_Lot__c != null){ if(invbatchMap.containsKey(inv.ERP7__Batch_Lot__c))  invbatchMap.get(inv.ERP7__Batch_Lot__c).add(inv); else invbatchMap.put(inv.ERP7__Batch_Lot__c, new List<ERP7__Inventory_Stock__c>{inv}); } else{ if(invNormProdMap.containsKey(inv.ERP7__Product__c))  invNormProdMap.get(inv.ERP7__Product__c).add(inv); else invNormProdMap.put(inv.ERP7__Product__c, new List<ERP7__Inventory_Stock__c>{inv}); } } } if(serialIDs.size() > 0){ List<ERP7__Inventory_Stock__c> invserial = [Select Id,Name,ERP7__Location__c,ERP7__Serial__c,ERP7__Product__c,ERP7__StorageContainer__c from ERP7__Inventory_Stock__c where ERP7__Active__c = true and (ERP7__Serial__c In:serialIDs and ERP7__Product__c In:ProdIds and ERP7__Serial__c Not In :receivedserials)  and ERP7__Warehouse__c = :selectecSite and Name != 'Awaiting Stock' and ERP7__Number_of_Item_In_Stock__c > 0 Order By CreatedDate ASC]; for(ERP7__Inventory_Stock__c inv : invserial){ if(inv.ERP7__Serial__c != null){ invSerialProdMap.put(inv.ERP7__Serial__c,inv); } } } Map<Id, ERP7__Inventory_Stock__c> existingInvToUpdate = new Map<Id, ERP7__Inventory_Stock__c>(); for(ERP7__Stock_Inward_Line_Item__c sil : siliLst){ system.debug('Processing SIL: ' + sil.Id + '; LogisticLineItem: ' + sil.ERP7__Logistic_Line_Item__c + '; Serial: ' + sil.ERP7__Serial_Number__c); String serialKey = (sil.ERP7__Logistic_Line_Item__c != null ? sil.ERP7__Logistic_Line_Item__c : '') + '-' + (sil.ERP7__Serial_Number__c != null ? sil.ERP7__Serial_Number__c : ''); if (sil.ERP7__Serial__c != null && invSerialProdMap.containsKey(sil.ERP7__Serial__c)) { ERP7__Inventory_Stock__c existingInv = invSerialProdMap.get(sil.ERP7__Serial__c); sil.ERP7__Site_ProductService_InventoryStock__c = existingInv.Id; } else if (sil.ERP7__Material_Batch_Lot__c != null && invbatchMap.containsKey(sil.ERP7__Material_Batch_Lot__c) && (sil.ERP7__Serial_Number__c == null || sil.ERP7__Serial_Number__c == '')) { List<ERP7__Inventory_Stock__c> batchInv = invbatchMap.get(sil.ERP7__Material_Batch_Lot__c); Integer i = 1; system.debug('batchInv : ' + batchInv.size()); for (ERP7__Inventory_Stock__c inv : batchInv) { system.debug('i batch: ' + i); if ((sil.ERP7__Location__c != null && sil.ERP7__StorageContainer__c == null) && inv.ERP7__Location__c == sil.ERP7__Location__c) { system.debug('Inventory batch exists for location: ' + sil.ERP7__Location__c); sil.ERP7__Site_ProductService_InventoryStock__c = inv.Id; if (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c)) { if (inv.ERP7__Expiry_Date__c == null || inv.ERP7__Expiry_Date__c < expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)) { existingInvToUpdate.put(inv.Id, new ERP7__Inventory_Stock__c( Id = inv.Id, ERP7__Expiry_Date__c = expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) )); system.debug('Added existing batch inventory to update: ' + inv.Id + ' with ERP7__Expiry_Date__c: ' + expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)); } } break; } else if ((sil.ERP7__Location__c != null && sil.ERP7__StorageContainer__c != null) && inv.ERP7__Location__c == sil.ERP7__Location__c && inv.ERP7__StorageContainer__c == sil.ERP7__StorageContainer__c) { system.debug('Inventory batch exists for location and container: ' + sil.ERP7__Location__c + ', ' + sil.ERP7__StorageContainer__c); sil.ERP7__Site_ProductService_InventoryStock__c = inv.Id; if (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c)) { if (inv.ERP7__Expiry_Date__c == null || inv.ERP7__Expiry_Date__c < expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)) { existingInvToUpdate.put(inv.Id, new ERP7__Inventory_Stock__c( Id = inv.Id, ERP7__Expiry_Date__c = expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) )); system.debug('Added existing batch inventory to update: ' + inv.Id + ' with ERP7__Expiry_Date__c: ' + expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)); } } break; } else if (sil.ERP7__Material_Batch_Lot__c == null && sil.ERP7__Location__c == null && sil.ERP7__Product__c == inv.ERP7__Product__c && inv.ERP7__Location__c == null) { system.debug('Inventory normal exists without location for product: ' + sil.ERP7__Product__c); sil.ERP7__Site_ProductService_InventoryStock__c = inv.Id; if (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c)) { if (inv.ERP7__Expiry_Date__c == null || inv.ERP7__Expiry_Date__c < expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)) { existingInvToUpdate.put(inv.Id, new ERP7__Inventory_Stock__c( Id = inv.Id, ERP7__Expiry_Date__c = expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) )); system.debug('Added existing normal inventory to update: ' + inv.Id + ' with ERP7__Expiry_Date__c: ' + expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)); } } break; } else if (sil.ERP7__Location__c == null && sil.ERP7__Material_Batch_Lot__c == inv.ERP7__Batch_Lot__c && inv.ERP7__Product__c == sil.ERP7__Product__c && inv.ERP7__Location__c == null) { system.debug('Inventory batch exists without location for batch: ' + sil.ERP7__Material_Batch_Lot__c); sil.ERP7__Site_ProductService_InventoryStock__c = inv.Id; if (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c)) { if (inv.ERP7__Expiry_Date__c == null || inv.ERP7__Expiry_Date__c < expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)) { existingInvToUpdate.put(inv.Id, new ERP7__Inventory_Stock__c( Id = inv.Id, ERP7__Expiry_Date__c = expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) )); system.debug('Added existing batch inventory to update: ' + inv.Id + ' with ERP7__Expiry_Date__c: ' + expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)); } } break; } else if (batchInv.size() == i) { system.debug('Creating new batch inventory for batch: ' + sil.ERP7__Material_Batch_Lot__c); ERP7__Inventory_Stock__c newInv = new ERP7__Inventory_Stock__c(Name = sil.Name,ERP7__Product__c = sil.ERP7__Product__c,ERP7__Active__c = true,ERP7__Batch_Lot__c = sil.ERP7__Material_Batch_Lot__c,                                ERP7__Warehouse__c = selectecSite,ERP7__Location__c = sil.ERP7__Location__c,ERP7__Serial_Number__c = sil.ERP7__Serial_Number__c,ERP7__StorageContainer__c = sil.ERP7__StorageContainer__c, ERP7__Expiry_Date__c = expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c) ? expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) : null ); system.debug('New batch inventory: ' + newInv + ' with ERP7__Expiry_Date__c: ' + newInv.ERP7__Expiry_Date__c); invlst.add(newInv); break; } i++; } } else if (invNormProdMap.containsKey(sil.ERP7__Product__c)) { system.debug('inventory exists : ' + invNormProdMap); List<ERP7__Inventory_Stock__c> NormalInv = invNormProdMap.get(sil.ERP7__Product__c); system.debug('NormalInv : ' + NormalInv.size()); Integer i = 1; for (ERP7__Inventory_Stock__c inv : NormalInv) { system.debug('i : ' + i); system.debug('sil.ERP7__Location__c : ' + sil.ERP7__Location__c); system.debug('inv.ERP7__Location__c : ' + inv.ERP7__Location__c); system.debug('inv.ERP7__Product__c : ' + inv.ERP7__Product__c); system.debug('sil.ERP7__Product__c : ' + sil.ERP7__Product__c); System.debug('sil' + sil); if ((sil.ERP7__Location__c != null && sil.ERP7__StorageContainer__c == null) && inv.ERP7__Location__c == sil.ERP7__Location__c) { system.debug('Inventory normal exists for location: ' + sil.ERP7__Location__c); sil.ERP7__Site_ProductService_InventoryStock__c = inv.Id; if (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c)) { if (inv.ERP7__Expiry_Date__c == null || inv.ERP7__Expiry_Date__c < expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)) { existingInvToUpdate.put(inv.Id, new ERP7__Inventory_Stock__c( Id = inv.Id, ERP7__Expiry_Date__c = expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) )); system.debug('Added existing normal inventory to update: ' + inv.Id + ' with ERP7__Expiry_Date__c: ' + expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)); } } break; } if ((sil.ERP7__Location__c != null && sil.ERP7__StorageContainer__c != null) && inv.ERP7__Location__c == sil.ERP7__Location__c && inv.ERP7__StorageContainer__c == sil.ERP7__StorageContainer__c) { system.debug('Inventory normal exists for location and container: ' + sil.ERP7__Location__c + ', ' + sil.ERP7__StorageContainer__c); sil.ERP7__Site_ProductService_InventoryStock__c = inv.Id; if (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c)) { if (inv.ERP7__Expiry_Date__c == null || inv.ERP7__Expiry_Date__c < expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)) { existingInvToUpdate.put(inv.Id, new ERP7__Inventory_Stock__c(Id = inv.Id,ERP7__Expiry_Date__c = expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c))); system.debug('Added existing normal inventory to update: ' + inv.Id + ' with ERP7__Expiry_Date__c: ' + expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)); } } break; } else if ((sil.ERP7__Location__c == null) && inv.ERP7__Location__c == null && inv.ERP7__Product__c == sil.ERP7__Product__c) {      sil.ERP7__Site_ProductService_InventoryStock__c = inv.Id; if (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c)) { if (inv.ERP7__Expiry_Date__c == null || inv.ERP7__Expiry_Date__c < expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)) { existingInvToUpdate.put(inv.Id, new ERP7__Inventory_Stock__c(Id = inv.Id,ERP7__Expiry_Date__c = expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c))); system.debug('Added existing normal inventory to update: ' + inv.Id + ' with ERP7__Expiry_Date__c: ' + expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c)); } } break; } else if (NormalInv.size() == i) { system.debug('Creating new normal inventory for product: ' + sil.ERP7__Product__c); ERP7__Inventory_Stock__c newInv = new ERP7__Inventory_Stock__c(Name = sil.Name,ERP7__Product__c = sil.ERP7__Product__c,ERP7__Active__c = true,ERP7__Batch_Lot__c = sil.ERP7__Material_Batch_Lot__c,ERP7__Warehouse__c = selectecSite,ERP7__Location__c = sil.ERP7__Location__c,ERP7__Serial_Number__c = sil.ERP7__Serial_Number__c,ERP7__StorageContainer__c = sil.ERP7__StorageContainer__c,ERP7__Expiry_Date__c = expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c) ? expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) : null ); system.debug('New normal inventory: ' + newInv + ' with ERP7__Expiry_Date__c: ' + newInv.ERP7__Expiry_Date__c); invlst.add(newInv); break; } i++; } } else { System.debug('in else last 1397'); String productId = String.valueOf(sil.ERP7__Product__c); String locationId = sil.ERP7__Location__c != null ? String.valueOf(sil.ERP7__Location__c) : 'null'; String batchId = sil.ERP7__Material_Batch_Lot__c != null ? String.valueOf(sil.ERP7__Material_Batch_Lot__c) : 'null'; String productLocationKey = productId + '-' + locationId; String productLocationBatchKey = productId + '-' + locationId + '-' + batchId; if (sil.ERP7__Serial_Number__c != null && String.isNotEmpty(sil.ERP7__Serial_Number__c)) { ERP7__Inventory_Stock__c newInv = new ERP7__Inventory_Stock__c( Name = sil.Name,ERP7__Product__c = sil.ERP7__Product__c,ERP7__Active__c = true,ERP7__Batch_Lot__c = sil.ERP7__Material_Batch_Lot__c, ERP7__Warehouse__c = selectecSite,ERP7__Location__c = sil.ERP7__Location__c,ERP7__Serial_Number__c = sil.ERP7__Serial_Number__c,ERP7__StorageContainer__c = sil.ERP7__StorageContainer__c, ERP7__Expiry_Date__c = (String.isNotBlank(sil.ERP7__Logistic_Line_Item__c) && String.isNotBlank(sil.ERP7__Serial_Number__c) && serialExpiryDateMap.containsKey(serialKey)) ? serialExpiryDateMap.get(serialKey) : null ); system.debug('New serialized inventory: ' + newInv + ' with ERP7__Expiry_Date__c: ' + newInv.ERP7__Expiry_Date__c); invlst.add(newInv); } else if (sil.ERP7__Material_Batch_Lot__c != null && String.isNotEmpty(sil.ERP7__Material_Batch_Lot__c)) { if (!ProdBT.containsKey(productLocationBatchKey)) { ERP7__Inventory_Stock__c newInv = new ERP7__Inventory_Stock__c(Name = sil.Name,ERP7__Product__c = sil.ERP7__Product__c,ERP7__Active__c = true,ERP7__Batch_Lot__c = sil.ERP7__Material_Batch_Lot__c,ERP7__Warehouse__c = selectecSite,ERP7__Location__c = sil.ERP7__Location__c,ERP7__Serial_Number__c = sil.ERP7__Serial_Number__c,ERP7__StorageContainer__c = sil.ERP7__StorageContainer__c,ERP7__Expiry_Date__c = expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c) ? expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) : null ); system.debug('New batch inventory: ' + newInv + ' with ERP7__Expiry_Date__c: ' + newInv.ERP7__Expiry_Date__c); invlst.add(newInv); ProdBT.put(productLocationBatchKey, newInv); } } else if (!ProdNWL.containsKey(productLocationKey)) { ERP7__Inventory_Stock__c newInv = new ERP7__Inventory_Stock__c( Name = sil.Name, ERP7__Product__c = sil.ERP7__Product__c, ERP7__Active__c = true, ERP7__Batch_Lot__c = sil.ERP7__Material_Batch_Lot__c, ERP7__Warehouse__c = selectecSite, ERP7__Location__c = sil.ERP7__Location__c, ERP7__Serial_Number__c = sil.ERP7__Serial_Number__c, ERP7__StorageContainer__c = sil.ERP7__StorageContainer__c, ERP7__Expiry_Date__c = expiryDateMap.containsKey(sil.ERP7__Logistic_Line_Item__c) ? expiryDateMap.get(sil.ERP7__Logistic_Line_Item__c) : null ); system.debug('New normal inventory: ' + newInv + ' with ERP7__Expiry_Date__c: ' + newInv.ERP7__Expiry_Date__c); invlst.add(newInv); ProdNWL.put(productLocationKey, newInv); } } system.debug('invlst : '+invlst.size()); if(sil.ERP7__Logistic_Line_Item__c != null) { decimal totalqty = 0; logIDs.add(sil.ERP7__Logistic_Line_Item__c); logisticIDs.add(sil.ERP7__Logistic__c); system.debug('totalqty bfr: '+totalqty); if(totalReceivedQty.containsKey(sil.ERP7__Logistic_Line_Item__c)) { system.debug('totalqty if: '+totalReceivedQty.get(sil.ERP7__Logistic_Line_Item__c)); totalqty = totalReceivedQty.get(sil.ERP7__Logistic_Line_Item__c) + sil.ERP7__Quantity__c; system.debug('totalqty : '+totalqty); totalReceivedQty.put(sil.ERP7__Logistic_Line_Item__c,totalqty); } else totalReceivedQty.put(sil.ERP7__Logistic_Line_Item__c,sil.ERP7__Quantity__c); system.debug('totalReceivedQty : '+totalReceivedQty); } if(sil.ERP7__Material_Batch_Lot__c != null) batchIds.add(sil.ERP7__Material_Batch_Lot__c); system.debug('sil : '+sil); if(sil.ERP7__Product__r.ERP7__Serialise__c){ system.debug('sil.ERP7__Serial__c : '+sil.ERP7__Serial__c); if(sil.ERP7__Serial__c != null){ ERP7__Serial_Number__c newserial = new ERP7__Serial_Number__c(Id=sil.ERP7__Serial__c); newserial.ERP7__Available__c = true; newserial.ERP7__Barcode__c = sil.ERP7__Serial_Number__c; newserial.Name =sil.ERP7__Serial_Number__c; newserial.ERP7__Product__c = sil.ERP7__Product__c; newserial.ERP7__Barcode_Type__c = 'Code128'; newserial.ERP7__Serial_No__c = sil.ERP7__Serial_Number__c; if(sil.ERP7__Material_Batch_Lot__c != null) newserial.ERP7__Material_Batch_Lot__c = sil.ERP7__Material_Batch_Lot__c; newserial.ERP7__Availability_date__c = system.today(); newserial.ERP7__Warehouse__c = selectecSite; newserial.ERP7__Cost_Price__c  = sil.ERP7__Logistic_Line_Item__r.ERP7__Price_Product__c; newserial.ERP7__Purchase_Cost__c   = sil.ERP7__Logistic_Line_Item__r.ERP7__Price_Product__c; serials2Upsert.add(newserial); } else if(String.isNotEmpty(sil.ERP7__Serial_Number__c)) { ERP7__Serial_Number__c newserial = new ERP7__Serial_Number__c(); newserial.ERP7__Available__c = true; newserial.ERP7__Barcode__c = sil.ERP7__Serial_Number__c;       newserial.Name =sil.ERP7__Serial_Number__c;  newserial.ERP7__Product__c = sil.ERP7__Product__c; newserial.ERP7__Barcode_Type__c = 'Code128';                           newserial.ERP7__Serial_No__c = sil.ERP7__Serial_Number__c; if(sil.ERP7__Material_Batch_Lot__c != null) newserial.ERP7__Material_Batch_Lot__c = sil.ERP7__Material_Batch_Lot__c; newserial.ERP7__Availability_date__c = system.today(); newserial.ERP7__Warehouse__c = selectecSite;                           newserial.ERP7__Cost_Price__c = sil.ERP7__Logistic_Line_Item__r.ERP7__Price_Product__c;                           newserial.ERP7__Purchase_Cost__c = sil.ERP7__Logistic_Line_Item__r.ERP7__Price_Product__c; serials2Upsert.add(newserial); } } } system.debug('serials2Upsert : '+serials2Upsert.size()); if(serials2Upsert.size() > 0) { upsert serials2Upsert; system.debug('No trigger on serial'); for(ERP7__Serial_Number__c ser: serials2Upsert){ if(ser.ERP7__Serial_No__c != null && String.isNotEmpty(ser.ERP7__Serial_No__c) && ser.ERP7__Product__c != null){ String serialProdKey = ser.ERP7__Serial_No__c+''+ser.ERP7__Product__c; system.debug('serMap.put serialProdKey~>'+serialProdKey+' ser~>'+ser.Id); serMap.put(serialProdKey,ser); } } } if (!existingInvToUpdate.isEmpty()) { try { upsert existingInvToUpdate.values(); system.debug('Updated existing inventories: ' + existingInvToUpdate.values()); } catch (Exception e) { system.debug('Error updating existing inventories: ' + e.getMessage()); throw new DmlException('Failed to update existing inventories: ' + e.getMessage()); } } if(invlst.size() > 0) { for(ERP7__Inventory_Stock__c newInv : invlst) { String name = newInv.Name; if(name.length() > 80) newInv.Name = name.subString(0,79); if(newInv.ERP7__Serial_Number__c != null && String.isNotEmpty(newInv.ERP7__Serial_Number__c) && newInv.ERP7__Product__c != null){ String serialProdKey = newInv.ERP7__Serial_Number__c+''+newInv.ERP7__Product__c; system.debug('serMap.get serialProdKey~>'+serialProdKey+' ser ~>'+serMap.get(serialProdKey).Id); if(serMap.containskey(serialProdKey)) newInv.ERP7__Serial__c = serMap.get(serialProdKey).Id; } } System.debug('invlist->'+invlst+'size->'+invlst.size()); upsert invlst; system.debug('return from UpdateInventoryStock trigger'); for(ERP7__Inventory_Stock__c inv : invlst) { 		invprodMap.put(inv.ERP7__Product__c, inv.Id); if(prodinvM.containsKey(inv.ERP7__Product__c)){                           prodInvM.get(inv.ERP7__Product__c).add(inv); } else {   prodInvM.put(inv.ERP7__Product__c, new List<ERP7__Inventory_Stock__c>{inv}); } if(inv.ERP7__Serial_Number__c != null && String.isNotEmpty(inv.ERP7__Serial_Number__c) && inv.ERP7__Product__c != null){ String serialProdKey = inv.ERP7__Serial_Number__c+''+inv.ERP7__Product__c; invmap.put(serialProdKey, inv); }else if(inv.ERP7__Batch_Lot__c != null) invmap.put(inv.ERP7__Batch_Lot__c, inv); } } system.debug('invmap : '+invmap.size()); if(logIDs.size() > 0){                   List<ERP7__Logistic_Line_Item__c> lolilst = [Select Id,Name,ERP7__Quantity_Received__c,ERP7__Putaway_Quantity__c from ERP7__Logistic_Line_Item__c where Id In:logIDs]; for(ERP7__Logistic_Line_Item__c loli : lolilst){ if(totalReceivedQty.containsKey(loli.Id)){ system.debug('totalReceivedQty.get(loli.Id) : '+totalReceivedQty.get(loli.Id)); if(loli.ERP7__Quantity_Received__c == null) loli.ERP7__Quantity_Received__c =0; if(loli.ERP7__Putaway_Quantity__c == null) loli.ERP7__Putaway_Quantity__c =0; loli.ERP7__Quantity_Received__c = loli.ERP7__Quantity_Received__c + totalReceivedQty.get(loli.Id); system.debug('loli.ERP7__Quantity_Received__c : '+loli.ERP7__Quantity_Received__c); loli.ERP7__Putaway_Quantity__c = loli.ERP7__Putaway_Quantity__c + totalReceivedQty.get(loli.Id); system.debug('loli.ERP7__Putaway_Quantity__c : '+loli.ERP7__Putaway_Quantity__c); } } upsert lolilst; system.debug('return from LogisticLineTrigger'); } System.debug('sililst->'+siliLst+'size->'+siliLst.size()); for(ERP7__Stock_Inward_Line_Item__c sil1 : siliLst){ String name = sil1.Name; if(name.length() > 80) sil1.Name = name.subString(0,79); system.debug('sil1 : '+sil1.ERP7__Site_ProductService_InventoryStock__c); String serialProdKey = sil1.ERP7__Serial_Number__c+''+sil1.ERP7__Product__c; if(sil1.ERP7__Site_ProductService_InventoryStock__c == null){ if(!sil1.ERP7__Product__r.ERP7__Serialise__c && !sil1.ERP7__Product__r.ERP7__Lot_Tracked__c ) { if(prodInvM.containsKey(sil1.ERP7__Product__c)){ System.debug('prodInvM->'+prodInvM.get(sil1.ERP7__Product__c)); List<ERP7__Inventory_Stock__c> prodinvs = prodInvM.get(sil1.ERP7__Product__c); for (ERP7__Inventory_Stock__c inv : prodinvs) { if (inv.ERP7__Location__c == sil1.ERP7__Location__c) {                               sil1.ERP7__Site_ProductService_InventoryStock__c = inv.Id; System.debug('Matching Inventory Record -> ' + inv); break; } } if(sil1.ERP7__Site_ProductService_InventoryStock__c == null) {                            sil1.ERP7__Site_ProductService_InventoryStock__c=invprodMap.get(sil1.ERP7__Product__c); } } system.debug('sil1.ERP7__Site_ProductService_InventoryStock__c : '+sil1.ERP7__Site_ProductService_InventoryStock__c); } else if(sil1.ERP7__Product__r.ERP7__Serialise__c && invmap.containsKey(serialProdKey)){                           sil1.ERP7__Site_ProductService_InventoryStock__c = invmap.get(serialProdKey).Id; system.debug('else serial assigned : '+sil1.ERP7__Site_ProductService_InventoryStock__c); } else if(sil1.ERP7__Product__r.ERP7__Lot_Tracked__c && !sil1.ERP7__Product__r.ERP7__Serialise__c){ system.debug('LOt product : '+sil1.ERP7__Material_Batch_Lot__c); if(prodInvM.containsKey(sil1.ERP7__Product__c)){				List<ERP7__Inventory_Stock__c> prodinvs = prodInvM.get(sil1.ERP7__Product__c); System.debug('prodinvs->'+prodinvs); for (ERP7__Inventory_Stock__c inv : prodinvs) { System.debug('in loop inv->'+inv); if (inv.ERP7__Batch_Lot__c == sil1.ERP7__Material_Batch_Lot__c && inv.ERP7__Location__c == sil1.ERP7__Location__c) {                                    sil1.ERP7__Site_ProductService_InventoryStock__c = inv.Id; System.debug('Matching Inventory Record LOT -> ' + inv); break; } } if(sil1.ERP7__Site_ProductService_InventoryStock__c == null) {                                sil1.ERP7__Site_ProductService_InventoryStock__c=invMap.get(sil1.ERP7__Material_Batch_Lot__c).Id; } } } } if(sil1.ERP7__Product__r.ERP7__Serialise__c && serMap.containsKey(serialProdKey)){                       sil1.ERP7__Serial__c = serMap.get(serialProdKey).Id; } system.debug('sil1.ERP7__Site_ProductService_InventoryStock__c : '+sil1.ERP7__Site_ProductService_InventoryStock__c); } if(siliLst.size() > 0) { PreventRecursiveLedgerEntry.StockInwardTrigger = true; upsert siliLst; system.debug('updating Stock inward line items');} } system.debug('logisticIDs.size() : '+logisticIDs.size()); if(logisticIDs.size() > 0){                List<String> alllogs = new List<String>(); alllogs.addAll(logisticIDs); cmw = ReceiveAl(JSON.serialize(alllogs)); } if(MOIDs.size() > 0){               List<String> allMOIds = new List<String>(); allMOIds.addAll(MOIDs); cmw = ReceiveMOItems(JSON.serialize(allMOIds)); } } catch (Exception e) { cmw.exceptionError='Error Message:'+e.getMessage()+'   Line Number:'+e.getLineNumber(); System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); Database.RollBack(sp); } return cmw; }
    
    @AuraEnabled
    public static createBatchWrapper createBatch1(String newBatch1){
        ERP7__Batch__c newBatch = (ERP7__Batch__c) JSON.deserialize(newBatch1,ERP7__Batch__c.class);
        system.debug('newBatch : '+newBatch);
        createBatchWrapper batchWr=new createBatchWrapper();
        try {
            if(newBatch.ERP7__Shelf_Life_Expiration_Date__c != null && newBatch.ERP7__Shelf_Life_Expiration_Date__c < System.today()){batchWr.exError='Please select today or future date';return batchWr;}
            List<ERP7__Batch__c> batchList=[Select Id,Name,ERP7__Expired__c,ERP7__Vendor__c from ERP7__Batch__c where (Name=:newBatch.Name Or ERP7__Barcode__c=:newBatch.Name) AND ERP7__Product__c=:newBatch.ERP7__Product__c];
            if(batchList.size() > 0){
                
                if(batchList[0].ERP7__Expired__c) batchWr.exError='Expired batch already available for this product with name : '+newBatch.Name; else batchWr.exError='Batch already available for this product with name : '+newBatch.Name;
            }else{
                if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Active__c.isUpdateable()) newBatch.ERP7__Active__c=true;
                if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Barcode_Type__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Barcode_Type__c.isUpdateable()) newBatch.ERP7__Barcode_Type__c='Code128';                
                if(Schema.sObjectType.ERP7__Batch__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.isUpdateable()) { upsert newBatch; }  else{ }
                batchWr.batch=newBatch;
            }            
            
        } catch (Exception e) { batchWr.exError='Error Message:'+e.getMessage()+'   Line Number:'+e.getLineNumber(); }
        return batchWr;
    }
    
    @AuraEnabled
    public static List<Attachment> DeleteAttachFromInboundList(String attachId,String parentId){
        try{
            List<Attachment> Attachments = new List<Attachment>(); Attachment attach2del = new Attachment(); 
            if(String.isNotEmpty(attachId)){ attach2del = [Select Id, Name, ParentId from Attachment where Id =: attachId AND ParentId != null]; if(attach2del.Id != null){ delete attach2del; } } 
            if(String.isNotEmpty(parentId)) Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:parentId Order By CreatedDate ASC]; return Attachments; 
        } catch(Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } }
    
    @AuraEnabled
    public static comWrap DeleteAttach(String RAId, String ObjName){   
        comWrap comW = new comWrap();
        try{
            String query = 'select Id from ' +String.escapeSingleQuotes(ObjName)+ ' Where Id =:RAId';
            SObject AT = Database.query(query); SObjectType sObjType = ((SObject) Type.forName(ObjName).newInstance()).getSObjectType(); if(sObjType.getDescribe().isDeletable()){ delete AT;}else{/*No access*/}
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }   return comW;
    }
    
    @AuraEnabled 
    public static scannerWrapper getscandetailsnew(String barcode,String prodId,Integer count,String sili,String loli,String site){
        try{ scannerWrapper scanwrap = new scannerWrapper(); comWrap cmW = new comWrap(); List<newStockwrap> siliLst = new List<newStockwrap>(); if(String.isNotEmpty(sili)) siliLst = (List<newStockwrap>) JSON.deserialize(sili,List<newStockwrap>.class); List<LOLISPLIS> loliLst = new List<LOLISPLIS>(); if(String.isNotEmpty(loli)) loliLst = (List<LOLISPLIS>) JSON.deserialize(loli,List<LOLISPLIS>.class); cmW.DisMsg = ''; system.debug('siliLst ~>'+siliLst.size()+' barcode~>'+barcode+' site~>'+site); if(siliLst.size() > 0 && String.isNotEmpty(barcode) && String.isNotEmpty(site)){                List<Location__c> SSLList = new List<Location__c>(); SSLList = [Select Id, Name, ERP7__Barcode__c, ERP7__Site__c from ERP7__Location__c where ERP7__Barcode__c =:barcode.trim() and ERP7__Active__c = true AND ERP7__Site__c =: site limit 1]; system.debug('SSLList : '+SSLList.size()); List<ERP7__StorageContainer__c> binList = new List<ERP7__StorageContainer__c>(); binList = [Select Id, Name, ERP7__Barcode__c, ERP7__Site__c, ERP7__Location__c from ERP7__StorageContainer__c where ERP7__Barcode__c =:barcode.trim() and ERP7__Active__c = true AND ERP7__Site__c =: site AND ERP7__Location__c != null limit 1]; system.debug('binList : '+binList.size()); List<ERP7__Batch__c> batchprod = new List<ERP7__Batch__c>(); if(String.isNotEmpty(prodId)){                    batchprod = [Select Id,Name,ERP7__Product__c,ERP7__Expired__c,ERP7__Barcode__c from ERP7__Batch__c where ERP7__Barcode__c =:barcode.trim() AND ERP7__Product__c =: prodId AND ERP7__Expired__c=false Limit 1]; }else{                    batchprod = [Select Id,Name,ERP7__Product__c,ERP7__Expired__c,ERP7__Barcode__c from ERP7__Batch__c where ERP7__Barcode__c =:barcode.trim() AND ERP7__Product__c != null AND ERP7__Expired__c=false Limit 1]; } if(SSLList.size() > 0 && count >= 0){ siliLst[count].sili.ERP7__Location__c = SSLList[0].Id;  } else if(binList.size() > 0 && count >= 0){                    siliLst[count].sili.ERP7__StorageContainer__c = binList[0].Id;  siliLst[count].sili.ERP7__Location__c = binList[0].ERP7__Location__c; } else if(batchprod.size() > 0) { if(count >= 0){ if(siliLst[count].sili.ERP7__Product__c != null){ if(siliLst[count].sili.ERP7__Product__r.ERP7__Lot_Tracked__c && batchprod[0].ERP7__Product__c == siliLst[count].sili.ERP7__Product__c){ ERP7__Batch__c scanbatch = new ERP7__Batch__c(Id = batchprod[0].Id,Name = batchprod[0].Name,ERP7__Product__c = batchprod[0].ERP7__Product__c,ERP7__Barcode__c = batchprod[0].ERP7__Barcode__c); scanwrap.batchAssigned = true; scanwrap.prodName = siliLst[count].sili.ERP7__Product__r.Name; scanwrap.BatchName = batchprod[0].Name; scanwrap.BatchId = batchprod[0].Id;                                scanwrap.scanBatch = scanbatch; if(siliLst[count].sili.ERP7__Product__r.ERP7__Serialise__c == false ){ if(siliLst[count].sili.ERP7__Material_Batch_Lot__c != null && siliLst[count].sili.ERP7__Material_Batch_Lot__c == batchprod[0].Id){                                        scanwrap.alreadybatchscanned = true; } siliLst[count].sili.ERP7__Material_Batch_Lot__c = batchprod[0].Id;  siliLst[count].sili.ERP7__Material_Batch_Lot__r = scanbatch;                                    siliLst[count].isSelected = true;  siliLst[count].siliverified = true; } else if(siliLst[count].sili.ERP7__Product__r.ERP7__Serialise__c){ for(Integer i=0;i<siliLst.size();i++){ newStockwrap stk = siliLst[i]; if(stk.sili.ERP7__Product__c != null && String.isNotEmpty(prodId)){ if(stk.sili.ERP7__Product__r.ERP7__Lot_Tracked__c && stk.sili.ERP7__Product__r.ERP7__Serialise__c && batchprod[0].ERP7__Product__c == stk.sili.ERP7__Product__c && stk.sili.ERP7__Product__c == prodId){ stk.sili.ERP7__Material_Batch_Lot__c = batchprod[0].Id;  stk.sili.ERP7__Material_Batch_Lot__r = scanbatch; stk.isSelected = true; if(count == i) stk.siliverified = true; if(stk.sili.ERP7__Serial_Number__c == null) scanwrap.serialscan = true; } } } } if(String.isNotEmpty(siliLst[count].loliId)){ for(Integer i=0;i<loliLst.size();i++){                                        LOLISPLIS lol = loliLst[i]; if(String.isNotEmpty(lol.loliId) && lol.LOLI.Id != null){ if(siliLst[count].loliId == lol.loliId && lol.LOLI.ERP7__Product__c != null){ if(lol.LOLI.ERP7__Product__r.ERP7__Lot_Tracked__c && siliLst[count].sili.ERP7__Product__c == lol.LOLI.ERP7__Product__c && batchprod[0].ERP7__Product__c == lol.LOLI.ERP7__Product__c){ lol.assignedBatch = batchprod[0].Id; break; } } } } } } } }else{ String loliId = ''; String loliProd = ''; for(Integer i=0;i<loliLst.size();i++){ LOLISPLIS lol = loliLst[i]; if(String.isNotEmpty(lol.loliId) && lol.LOLI.Id != null){ if(lol.LOLI.ERP7__Product__c != null){ if(lol.LOLI.ERP7__Product__r.ERP7__Lot_Tracked__c && batchprod[0].ERP7__Product__c == lol.LOLI.ERP7__Product__c){ lol.assignedBatch = batchprod[0].Id; loliId = lol.loliId; loliProd = lol.LOLI.ERP7__Product__c; break; } } } } if(String.isNotEmpty(loliId) && String.isNotEmpty(loliProd)){ for(Integer i=0;i<siliLst.size();i++){ newStockwrap stk = siliLst[i]; if(stk.sili.ERP7__Product__c != null && String.isNotEmpty(stk.loliId)){ if(stk.sili.ERP7__Product__c == loliProd && stk.loliId == loliId && stk.sili.ERP7__Product__r.ERP7__Lot_Tracked__c && batchprod[0].ERP7__Product__c == stk.sili.ERP7__Product__c && batchprod[0].ERP7__Product__c == loliProd){ stk.sili.ERP7__Material_Batch_Lot__c = batchprod[0].Id; stk.sili.ERP7__Material_Batch_Lot__r = new ERP7__Batch__c(Id = batchprod[0].Id,Name = batchprod[0].Name,ERP7__Product__c = batchprod[0].ERP7__Product__c,ERP7__Barcode__c = batchprod[0].ERP7__Barcode__c); stk.isSelected = true; stk.siliverified = true;  scanwrap.scannedProdId = stk.sili.ERP7__Product__c; scanwrap.scannedIndx = i; scanwrap.bool = true; if(stk.sili.ERP7__Product__r.ERP7__Serialise__c){ if(stk.sili.ERP7__Serial_Number__c == null) scanwrap.serialscan = true; } break; } } } } } } else { cmW.DisMsg = 'Invalid Barcode Scanned'; } } cmW.SPLIS = siliLst; cmW.LOLIS = loliLst; scanwrap.comWrapper = cmW; return scanwrap; } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } 
    }
    
  @AuraEnabled
public static List<ContentDocumentLink> deleteFile(String recId, String LoId) {
    List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
    
    // Delete the file if recId is provided
    if (String.isNotBlank(recId)) {
        delete new ContentDocumentLink(Id = recId);
    }
    
    // Get uploaded files if LoId is provided
    if (String.isNotBlank(LoId)) {
        Map<String, Object> response = getuploadedfiles(LoId);
        // Extract the 'links' key from the response map
        if (response.containsKey('links')) {
            conDocLink = (List<ContentDocumentLink>) response.get('links');
        }
    }
    
    // Return conDocLink if it contains records, otherwise return null
    return conDocLink.size() > 0 ? conDocLink : null;
}

@AuraEnabled
public static Map<String, Object> getuploadedfiles(String recId) { Map<String, Object> response = new Map<String, Object>(); System.debug('Starting getuploadedfiles method with recId: ' + recId); try { if (String.isNotBlank(recId)) { System.debug('recId is valid: ' + recId); List<ContentDocumentLink> conDocLinks = [ SELECT Id, ContentDocumentId, LinkedEntityId, Visibility, ContentDocument.Title, ContentDocument.ContentSize FROM ContentDocumentLink WHERE LinkedEntityId = :recId ]; System.debug('Queried ContentDocumentLinks: ' + conDocLinks.size() + ' records found'); for (ContentDocumentLink link : conDocLinks) { System.debug('ContentDocumentLink Id: ' + link.Id + ', Title: ' + link.ContentDocument.Title + ', ContentSize: ' + link.ContentDocument.ContentSize + ' bytes'); } List<Id> filesToDelete = new List<Id>(); List<ContentDocumentLink> validLinks = new List<ContentDocumentLink>(); Integer maxFileSize = 2097152; System.debug('Max individual file size: ' + maxFileSize + ' bytes'); Integer maxTotalSize = 6000000; System.debug('Max total file size: ' + maxTotalSize + ' bytes'); Integer totalSize = 0; System.debug('Initial totalSize: ' + totalSize); for (ContentDocumentLink link : conDocLinks) { System.debug('Processing ContentDocumentLink Id: ' + link.Id + ', Title: ' + link.ContentDocument.Title); if (link.ContentDocument.ContentSize > maxFileSize) { System.debug('File size ' + link.ContentDocument.ContentSize + ' exceeds maxFileSize, marking for deletion: ' + link.ContentDocumentId); filesToDelete.add(link.ContentDocumentId); } else { totalSize += link.ContentDocument.ContentSize; System.debug('File size ' + link.ContentDocument.ContentSize + ' is valid, adding to totalSize: ' + totalSize); validLinks.add(link); System.debug('Added to validLinks, current validLinks size: ' + validLinks.size()); } } System.debug('Total size of valid files: ' + totalSize + ' bytes'); if (totalSize > maxTotalSize) { System.debug('Total size ' + totalSize + ' exceeds maxTotalSize ' + maxTotalSize + ', marking all valid files for deletion'); for (ContentDocumentLink link : validLinks) { filesToDelete.add(link.ContentDocumentId); System.debug('Marked for deletion: ' + link.ContentDocumentId + ', Title: ' + link.ContentDocument.Title); } validLinks.clear(); System.debug('Cleared validLinks, filesToDelete size: ' + filesToDelete.size()); response.put('error', 'Total file size exceeds 6 MB limit.'); System.debug('Error added to response: Total file size exceeds 6 MB limit.'); } if (!filesToDelete.isEmpty()) { System.debug('Preparing to delete ' + filesToDelete.size() + ' files: ' + filesToDelete); List<ContentDocument> docsToDelete = [SELECT Id, Title FROM ContentDocument WHERE Id IN :filesToDelete]; System.debug('Queried ContentDocuments for deletion: ' + docsToDelete.size() + ' records'); for (ContentDocument doc : docsToDelete) { System.debug('ContentDocument to delete: Id=' + doc.Id + ', Title=' + doc.Title); } if (!docsToDelete.isEmpty()) { try { Database.DeleteResult[] deleteResults = Database.delete(docsToDelete, false); System.debug('Deletion attempted for ' + docsToDelete.size() + ' ContentDocuments'); Integer successCount = 0; Integer failureCount = 0; List<String> deletionErrors = new List<String>(); for (Database.DeleteResult result : deleteResults) { if (result.isSuccess()) { successCount++; System.debug('Successfully deleted ContentDocument Id: ' + result.getId()); } else { failureCount++; String errorMsg = 'Failed to delete ContentDocument Id: ' + result.getId() + ', Errors: ' + result.getErrors(); deletionErrors.add(errorMsg); System.debug(errorMsg); } } System.debug('Deletion summary: ' + successCount + ' succeeded, ' + failureCount + ' failed'); if (failureCount > 0) { response.put('error', 'Failed to delete some files: ' + String.join(deletionErrors, '; ')); } else if (!response.containsKey('error')) { response.put('error', ' file exceeded the 2 MB size limit .'); } } catch (Exception deleteEx) { System.debug('Deletion exception: ' + deleteEx.getMessage() + ', Line: ' + deleteEx.getLineNumber()); response.put('error', 'Failed to delete files: ' + deleteEx.getMessage()); } } else { System.debug('No ContentDocuments found for deletion with IDs: ' + filesToDelete); response.put('error', 'No files found to delete.'); } } else { System.debug('No files marked for deletion'); } if (!filesToDelete.isEmpty()) { List<ContentDocument> remainingDocs = [SELECT Id, Title FROM ContentDocument WHERE Id IN :filesToDelete]; if (!remainingDocs.isEmpty()) { System.debug('WARNING: ' + remainingDocs.size() + ' files were not deleted: ' + remainingDocs); response.put('error', 'Some files could not be deleted.'); } else { System.debug('All targeted files successfully deleted'); } } System.debug('Adding validLinks to response, size: ' + validLinks.size()); response.put('links', validLinks); System.debug('Returning response: ' + response); return response; } else { System.debug('recId is blank or invalid'); response.put('error', 'Invalid record ID.'); return response; } } catch (Exception e) { System.debug('Exception occurred: ' + e.getMessage() + ', Line: ' + e.getLineNumber() + ', StackTrace: ' + e.getStackTraceString()); response.put('error', 'An error occurred: ' + e.getMessage()); return response; } }
    @AuraEnabled  
    public static List<ContentDocument> UpdateFiles(string documentId,string title,string recordId){ system.debug('title: ' +title); ContentDocument cd = [select id,title from ContentDocument where Id=:documentId]; cd.Title = title; try{ update cd; } catch(DMLException e){ system.debug('Exception has occurred! ' +e.getMessage()); } List<ContentDocument> DocumentList = new List<ContentDocument>(); Set<Id> documentIds = new Set<Id>(); List<ContentDocumentLink> cdl=[select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink where LinkedEntityId=:recordId]; for(ContentDocumentLink cdLink:cdl){  documentIds.add(cdLink.ContentDocumentId);  }      DocumentList = [select Id,Title,FileType,ContentSize,Description from ContentDocument where id IN: documentIds];  return DocumentList; }  
    
   
    public class scannerWrapper{
        @AuraEnabled public comWrap comWrapper        { get; set; }
        @AuraEnabled public String scannedProdId { get; set; }
        @AuraEnabled public String prodName { get; set; }
        @AuraEnabled public String BatchName { get; set; }
        @AuraEnabled public String BatchId { get; set; }
        @AuraEnabled public Integer scannedIndx { get; set; }
        @AuraEnabled public Boolean bool { get; set; }
        @AuraEnabled public Boolean serialscan { get; set; }
        @AuraEnabled public Boolean alreadybatchscanned { get; set; }
        @AuraEnabled public Boolean batchAssigned { get; set; }
        @AuraEnabled public ERP7__Batch__c scanBatch { get; set; }
        public scannerWrapper(){
            comWrapper = new comWrap();
            scannedIndx = -1;
            scannedProdId = prodName = BatchName = BatchId = '';
            bool = serialscan = alreadybatchscanned = batchAssigned = false;
            scanBatch = new ERP7__Batch__c();
        }
    }
    
    @AuraEnabled
    public static String checkDuplicateSerials(String value){
        try{
            if(String.isNotEmpty(value)){
                List<ERP7__Serial_Number__c> duplicates = new List<ERP7__Serial_Number__c>();
                duplicates = [SELECT Id, ERP7__Serial_Number__c FROM ERP7__Serial_Number__c where ERP7__Serial_No__c =: value AND ERP7__Available__c = true limit 10000 ];
                if(duplicates.size()>0){
                    return 'Duplicate Serial No '+value+' exists.';
                }else{
                    return null;
                }
            }
        }catch(Exception e){ throw new AuraHandledException(e.getMessage()); } 
        return null;
    }
    
    //new method for multiple files upload arshad 30/03/23
    @AuraEnabled
    public static List<Attachment> uploadMultipleFiles(String parent, List<String> fileName, List<String> base64Data, List<String> contentType) { try{ List<Attachment> attachments2Insert = new List<Attachment>(); List<Attachment> Attachments = new List<Attachment>(); if(String.isNotEmpty(parent)){ for (Integer i = 0; i < fileName.size(); i++) { base64Data[i] = EncodingUtil.urlDecode(base64Data[i], 'UTF-8'); Attachment a = new Attachment(); a.parentId = parent;  a.Body = EncodingUtil.base64Decode(base64Data[i]); a.Name = fileName[i];  a.ContentType = contentType[i]; attachments2Insert.add(a); } insert attachments2Insert; Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:parent Order By CreatedDate ASC]; } return Attachments; } catch(Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } }
    
    //new method for multiple files upload arshad 30/03/23
    @AuraEnabled
    public static List<Attachment> uploadMultipleFilesforQAguidelines(String parent, List<String> fileName, List<String> base64Data, List<String> contentType) { 
        try{
            List<Attachment> attachments2Insert = new List<Attachment>(); 
            List<Attachment> Attachments = new List<Attachment>(); 
            if(String.isNotEmpty(parent)){
                
                ERP7__Guideline_Checklists__c guidelines2update = (ERP7__Guideline_Checklists__c) JSON.deserialize(parent,ERP7__Guideline_Checklists__c.class);
                if(guidelines2update.ERP7__Checklist__r.ERP7__Has_Checklist__c) guidelines2update.ERP7__Status__c = guidelines2update.ERP7__Instructions__c;
                guidelines2update.ERP7__Checklist__r = null;
                //guidelines2update.ERP7__Status__c = guidelines2update.ERP7__Instructions__c;
                guidelines2update.ERP7__Is_Mandatory__c = false;
                //guidelines2update.Attachments = null;
                
                upsert guidelines2update;
                
                for (Integer i = 0; i < fileName.size(); i++) {
                    base64Data[i] = EncodingUtil.urlDecode(base64Data[i], 'UTF-8'); 
                    Attachment a = new Attachment(); a.parentId = guidelines2update.Id;  a.Body = EncodingUtil.base64Decode(base64Data[i]); a.Name = fileName[i];  a.ContentType = contentType[i];
                    attachments2Insert.add(a); 
                } 
                insert attachments2Insert; 
                Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:guidelines2update.Id Order By CreatedDate ASC]; 
            } 
            return Attachments;  } catch(Exception e) {  throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); 
        } 
    }
    
    
    @AuraEnabled
    public static comWrap uploadFile(String parent, String fileName, String base64Data, String contentType) { 
        comWrap comW = new comWrap();
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8'); Attachment a = new Attachment(); if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable()) { a.parentId = parent; } else {} if(Schema.sObjectType.Attachment.fields.body.isCreateable()) {a.Body = EncodingUtil.base64Decode(base64Data);} else{} if(Schema.sObjectType.Attachment.fields.Name.isCreateable() ) { a.Name = fileName; } else{} if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) { a.ContentType = contentType; } if(Attachment.sObjectType.getDescribe().isCreateable()) { insert a; } else{ } comW.universalAttachment = a;
            /*'*** a : '+a);*/
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }   return comW;        
    }
    
    @AuraEnabled
    public static String uploadFileforbatch(String parent, String fileName, String base64Data, String contentType) { 
        system.debug('uploadFile-->');
        try{  base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');  Attachment a = new Attachment();  a.parentId = parent; a.Body = EncodingUtil.base64Decode(base64Data);  a.Name = fileName; a.ContentType = contentType; if(Schema.SObjectType.Attachment.isCreateable()){ system.debug('Attachment-->'+a); insert a; } else{ } return 'Success'; } catch(Exception e) { system.debug('Error:'+e.getMessage()+' Line:'+e.getLineNumber()); String exc=Json.serialize(e); return exc; }
        
    }
    
    public class createBatchWrapper{
        @AuraEnabled public ERP7__Batch__c batch        { get; set; }
        @AuraEnabled public String exError              { get; set; }
        public createBatchWrapper(){
            batch=new ERP7__Batch__c();
            exError='';
        }
    }
    
    public class checklstWrap {
        @AuraEnabled public ERP7__Checklist__c Checks                                     { get; set; } 
        @AuraEnabled public List<String> uplodedfilescontent                                     { get; set; } 
        @AuraEnabled public String Sinward                                     { get; set; }
        public checklstWrap(ERP7__Checklist__c newcheck,List<String> filescontent,String SiliId){
            Checks = newcheck;
            uplodedfilescontent = filescontent;
            Sinward = SiliId;
        }
    }
    
    public class comWrap {
        @AuraEnabled public Attachment universalAttachment                                          { get; set; }
        @AuraEnabled public String PreparePushAttachmentId                                          { get; set; } 
        @AuraEnabled public Employees__c Employee                                                   { get; set; }
        @AuraEnabled public List<SelectOptions> channelSites                                        { get; set; }
        @AuraEnabled public String ChannelName                                                      { get; set; } 
        @AuraEnabled public String ChannelId                                                        { get; set; } 
        @AuraEnabled public String SiteName                                                         { get; set; } 
        @AuraEnabled public String selectedSite                                                     { get; set; }
        @AuraEnabled public List<LogisticWrapper> LogisticWrapperList                               { get; set; }
        @AuraEnabled public List<MOWrapper> MOWrapperList                                           { get; set; }
        @AuraEnabled public String barcode                                                          { get; set; } 
        @AuraEnabled public Boolean initialScan                                                     { get; set; } 
        @AuraEnabled public String exceptionError                                                   { get; set; }
        @AuraEnabled public List<LOLIWrapper> LOLIWrapperList                                       { get; set; }
        @AuraEnabled public Boolean itemFoundOnScan                                                 { get; set; }
        @AuraEnabled public Integer counter                                                         { get; set; }
        @AuraEnabled public String DisMsg                                                           { get; set; } 
        @AuraEnabled public boolean showReceiveAtt                                                  { get; set; } 
        @AuraEnabled public boolean putawayLocationReq                                              { get; set; }
        @AuraEnabled public List<ReceivedSILIWrap> SILILOLI                                         { get; set; }
        @AuraEnabled public List<ERP7__MRP__c> MRPS                                                 { get; set; }
        @AuraEnabled public List<newStockwrap> SPLIS                                                { get; set; }
        @AuraEnabled public List<LOLISPLIS> LOLIS                                                   { get; set; }
        @AuraEnabled public List<Inventory_Stock__c> warehouseStocks                                { get; set; }
        @AuraEnabled public Map<Id, List<Stock_Inward_Line_Item__c>> stockLines                     { get; set; }
        @AuraEnabled public Map<Id,Serial_Number__c> SerialMap                                      { get; set; }
        @AuraEnabled public Boolean Putaway                                                         { get; set; }
        @AuraEnabled public List<ERP7__Logistic__c> allLogs                                         { get; set; }
        @AuraEnabled public Integer QALogCount                                                      { get; set; }
         @AuraEnabled public Integer QAMOsCount                                                      { get; set; }
        @AuraEnabled public List<Integer> PNS                                                       { get; set; }
        @AuraEnabled public Integer startCount                                                      { get; set; }
        @AuraEnabled public Integer endCount                                                        { get; set; }
        @AuraEnabled public Integer Offset                                                          { get; set; }
        @AuraEnabled public Integer recSize                                                         { get; set; }
        @AuraEnabled public Integer PageNum                                                         { get; set; }
        @AuraEnabled public Integer show                                                            { get; set; }
        @AuraEnabled public Boolean showBarcodes                                                    { get; set; }
        @AuraEnabled public Boolean showAttachment                                                  { get; set; }
        @AuraEnabled public Boolean showUpload                                                      { get; set; }
        @AuraEnabled public Boolean showProdBarcodeReceive                                          { get; set; }
        @AuraEnabled public Boolean disableNameReceive                                              { get; set; }
        @AuraEnabled public Boolean disableLocReceive                                               { get; set; }
        @AuraEnabled public Boolean showStatus                                                      { get; set; }
        @AuraEnabled public List<SelectOptions> status                                                     { get; set; }
        @AuraEnabled public List<ERP7__Dimension__c> poliDimensions                                 { get; set; }
        @AuraEnabled public Boolean AllocationAccess                                                { get; set; }
        @AuraEnabled public Boolean showInboundDescription                                          { get; set; }
        @AuraEnabled public Boolean showInboundQA                                                   { get; set; }
        @AuraEnabled public Boolean enableQAMO                                                      { get; set; }
        
        @AuraEnabled public Boolean showUplaodforItems                                              { get; set; } 
        @AuraEnabled public Boolean PreventStatusEdit                                               { get; set; }
         @AuraEnabled public Boolean showVendorCode                                                 { get; set; }
        @AuraEnabled public List<checklstWrap> ProdChecks                                           { get; set; }
        @AuraEnabled public List<ERP7__Guideline_Checklists__c> SILIChecks                          { get; set; }
        public comWrap() {
            PreventStatusEdit = showVendorCode = false;
            MOWrapperList = new  List<MOWrapper>();
            showUplaodforItems = false;
            showInboundQA = false;
            ProdChecks= new List<checklstWrap>();
            SILIChecks = new List<ERP7__Guideline_Checklists__c>();
            universalAttachment = new Attachment();
            PreparePushAttachmentId = selectedSite = barcode = exceptionError = ChannelName = ChannelId = SiteName = DisMsg = '';
            Employee = new Employees__c();
            channelSites = new List<SelectOptions>();
            LogisticWrapperList = new List<LogisticWrapper>();
            LOLIWrapperList = new List<LOLIWrapper>();
            initialScan = Putaway = itemFoundOnScan = putawayLocationReq=false;
            showReceiveAtt=true;
            SILILOLI = new List<ReceivedSILIWrap>();
            MRPS = new List<ERP7__MRP__c>();
            SPLIS = new List<newStockwrap>();
            LOLIS = new List<LOLISPLIS>();
            warehouseStocks = new List<Inventory_Stock__c>();
            stockLines = new Map<Id, List<Stock_Inward_Line_Item__c>>();
            SerialMap = new Map<Id,Serial_Number__c>();
            status = new List<SelectOptions>();
            PNS = new List<Integer>();
            show = 25;
            QALogCount = startCount = endCount = Offset = recSize = PageNum = QAMOsCount = 0;
            showBarcodes = true; showAttachment = true;
            showProdBarcodeReceive = disableNameReceive = disableLocReceive = false;
            counter = -1;
            allLogs = new List<ERP7__Logistic__c>();
            poliDimensions = new List<ERP7__Dimension__c>();
            showStatus = false;
            AllocationAccess = showInboundDescription = enableQAMO = false;
        }
    }
    
    public class LogisticWrapper{
        @AuraEnabled public Logistic__c Logistic                  { get; set; }
        @AuraEnabled public Attachment Attach                     { get; set; }
        @AuraEnabled public List<Attachment> Attachments                     { get; set; }
        @AuraEnabled public Boolean isSelected                    { get; set; }
        @AuraEnabled public List<orderWrapper> orderWrapperList   { get; set; }
        
        public LogisticWrapper() {
            Logistic = new Logistic__c();
            Attach = new Attachment();
            Attachments = new List<Attachment>();
            isSelected = false;
            orderWrapperList = new List<orderWrapper>();
        }        
    }
    
     public class MOWrapper{
        @AuraEnabled public ERP7__Manufacturing_Order__c MOrders                  { get; set; }
        @AuraEnabled public Attachment Attach                     { get; set; }
        @AuraEnabled public List<Attachment> Attachments                     { get; set; }
        @AuraEnabled public Boolean isSelected                    { get; set; }
        
        public MOWrapper() {
            MOrders = new ERP7__Manufacturing_Order__c();
            Attach = new Attachment();
            Attachments = new List<Attachment>();
            isSelected = false;
        }        
    }
    
    public class StockWrapper {
        @AuraEnabled public Inventory_Stock__c Stock                { get; set; }            
        @AuraEnabled public List<Stock_Inward_Line_Item__c> SPLI    { get; set; }  
        @AuraEnabled public Channel__c  SP                          { get; set; } 
        @AuraEnabled public ERP7__Serial_Number__c SerialNumber     { get; set; }
        @AuraEnabled public ERP7__Batch__c BatchNumber              { get; set; }
        
        public StockWrapper(Inventory_Stock__c WIIS, List<Stock_Inward_Line_Item__c> SPLI) {
            this.Stock = WIIS;
            this.SPLI = SPLI;
            if(!(SPLI.size() > 0)) this.SPLI.add(new Stock_Inward_Line_Item__c());
            this.SP = new Channel__c();
            SerialNumber = new ERP7__Serial_Number__c(); 
            BatchNumber = new ERP7__Batch__c();
        }
    } 
    
    public class LOLIWrapper {
        @AuraEnabled public ERP7__Logistic_Line_Item__c LOLI                       { get; set; } 
        @AuraEnabled public List<StockWrapper> StockWrapperList                    { get; set; }
        @AuraEnabled public Attachment Attach                                      { get; set; }
        @AuraEnabled public String  errMsg                                         { get; set; }
        @AuraEnabled public Decimal lineItemprocessedQuantity                      { get; set; } 
        @AuraEnabled public Decimal Incount                                        { get; set; }
        @AuraEnabled public Decimal ReceiveQty                                     { get; set; }
        @AuraEnabled public Boolean collaps                                        { get; set; } 
        @AuraEnabled public Boolean selected                                       { get; set; }
        @AuraEnabled public List<LOLIWrapper> BOMS                                 { get; set; }
        @AuraEnabled public ERP7__BOM__c BOM                                       { get; set; }
        @AuraEnabled public ERP7__MRP__c MRP                                       { get; set; } 
        
        public LOLIWrapper(ERP7__Logistic_Line_Item__c LOLI) {
            this.LOLI = LOLI;
            attach = new attachment();
            StockWrapperList = new List<StockWrapper>();
            this.errMsg = ''; 
            Incount = 0;
            ReceiveQty = LOLI.Remaining_Quantity__c;
            lineItemprocessedQuantity = 0;
            collaps = false; 
            selected = false;
            BOMS = new List<LOLIWrapper>();  
            BOM = new ERP7__BOM__c();
            MRP = new ERP7__MRP__c();  
        } 
    }
    
    public class SelectOptions {
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public SelectOptions(String val, string lab) {
            value = val;
            label = lab;
        }
        public SelectOptions(String val, string lab, Boolean sel) {
            value = val;
            label = lab;
            selected = sel;
        }
    }
    
    public class orderWrapper{
        @AuraEnabled public String OrderId        { get; set; }
        @AuraEnabled public String OrderName      { get; set; }
        public orderWrapper(){
            OrderId = OrderName = '';
        }
    }
    
    public class LOLISPLIS{
        @AuraEnabled public ERP7__Logistic_Line_Item__c LOLI  { get; set; }
        @AuraEnabled public List<ContentDocumentLink> Attach  { get; set; }
        @AuraEnabled public List<Attachment> Attachlist  { get; set; }
        @AuraEnabled public String prodId  { get; set; }
        @AuraEnabled public String ProdBarcode      { get; set; }
        @AuraEnabled public String loliId      { get; set; }
        @AuraEnabled public Decimal ExpectedQty { get; set; }
        @AuraEnabled public Decimal RemainingQty { get; set; }
        @AuraEnabled public Decimal ReceivedQty { get; set; }
        @AuraEnabled public String assignedBatch { get; set; }
        @AuraEnabled public Boolean isSerialized { get; set; }
        @AuraEnabled public Boolean isBatchLot { get; set; }
        @AuraEnabled public Integer silisize { get; set; }
        @AuraEnabled public Boolean showBin { get; set; }
        public LOLISPLIS(ERP7__Logistic_Line_Item__c lol,String prdId,String prdBarcode,Boolean isSerial,Boolean isLot,String lolId,Decimal expQTY,Decimal remQTY,Decimal recQTY,String batchId,Integer size,Boolean shwbin,List<ContentDocumentLink> LOLIAttach,List<Attachment> Attachlist1){
            Attach = LOLIAttach;
            LOLI = lol;
            prodId = prdId;
            loliId = lolId;
            assignedBatch = batchId;
            ExpectedQty = expQTY;
            RemainingQty = remQTY;
            ReceivedQty = recQTY;
            isSerialized = isSerial;
            isBatchLot = isLot;
            ProdBarcode = prdBarcode;
            silisize = size;
            showBin = shwbin;
            Attachlist = Attachlist1;
        }
    }
     @AuraEnabled
    public static List<Attachment> DeleteAttachment(String attachId,String parentId){ try{ List<Attachment> Attachments = new List<Attachment>(); Attachment attach2del = new Attachment(); if(String.isNotEmpty(attachId)){ attach2del = [Select Id, Name, ParentId from Attachment where Id =: attachId AND ParentId != null]; if(attach2del.Id != null){ delete attach2del; } } if(String.isNotEmpty(parentId)) Attachments = [Select Id, Name, ParentId from Attachment where ParentId =:parentId Order By CreatedDate ASC]; return Attachments; } catch(Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } }
    
    
    public class ReceivedSILIWrap{
        @AuraEnabled public  Stock_Inward_Line_Item__c sili                                           { get; set; }
        @AuraEnabled public List<ERP7__Guideline_Checklists__c>  guideline                            { get; set; }
        public ReceivedSILIWrap(){
            sili = new Stock_Inward_Line_Item__c();
            guideline = new List<ERP7__Guideline_Checklists__c>();
        }
    }
    public class newStockwrap {
        @AuraEnabled public  Stock_Inward_Line_Item__c sili { get; set; }
        @AuraEnabled public Boolean isSelected { get; set; }
        @AuraEnabled public Decimal ExpectedQty { get; set; }
        @AuraEnabled public Decimal RemainingQty { get; set; }
        @AuraEnabled public Decimal ReceivedQty { get; set; }
        @AuraEnabled public Boolean siliverified { get; set; }
        @AuraEnabled public String loliId { get; set; }
        public newStockwrap(Stock_Inward_Line_Item__c sil,Boolean selected,Decimal rmqty,Decimal rcqty,Decimal exqty,String lolId){
            sili = sil;
            isSelected = selected;
            RemainingQty = rmqty;
            ReceivedQty = rcqty;
            ExpectedQty = exqty;
            siliverified = false;
            loliId = lolId;
        }
    }
    public static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    //changes made by arsahd for value & label and also to handle translations label display
    @AuraEnabled 
    public static Map<String, List<SelectOptions>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<SelectOptions>> objResults = new Map<String,List<SelectOptions>>();
        //Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){  return objResults; }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){ return objResults;     
                                                                                                   }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            String value = ple.getValue();
            //objResults.put(label, new List<String>());
            //controllingValues.add(label);
            objResults.put(label, new List<SelectOptions>());
            controllingValues.add(label);
        }
        for (PicklistEntryWrapper plew : depEntries) {
            
            String label = plew.label;
            String value = plew.value;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    //objResults.get(controllingValues.get(i)).add(label);
                    objResults.get(controllingValues.get(i)).add(new SelectOptions(value,label));
                }
            }
        }
        return objResults;
    }
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        
        public String label {get;set;} public String active {get;set;} public String value {get;set;}
        public String validFor {get;set;} public String defaultValue {get;set;}public PicklistEntryWrapper(){            
        }
        
    }
    
}