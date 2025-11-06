public With Sharing Class InboundLogisticsLightning { 
    @AuraEnabled public static String response_1                                   { get; set; }
    @AuraEnabled      
    public static comWrap getAll(String logisticId, String searchText, String Channel, String Site, Integer Offset, Integer Show){
        comWrap comW = new comWrap();
        try{
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            logFields += ', ERP7__Sales_Order__r.Name , ERP7__Purchase_Order__r.ERP7__Customer__c ,ERP7__Purchase_Order__r.ERP7__Customer__r.Name,  ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name ';
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c'); 
            
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
            if(logisticId != null && logisticId != '') { Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null And ERP7__Closed__c = false And (ERP7__Barcode__c =:logisticId Or Id =:logisticId) Order by CreatedDate Desc Limit 1');
            } else {
                String searchTextPat = '%'+searchText+'%';
                Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' from ERP7__Logistic__c where ERP7__Active__c = true And (ERP7__Type__c =\'Inbound\') And Channel__c =: tempPOChannel And ERP7__Distribution_Channel__r.ERP7__Site__c =: selectedSite And Total_Quantity__c > 0 And ERP7__Sales_Order__c = Null And ERP7__Closed__c = false And (Name like :searchTextPat Or ERP7__Sales_Order__r.Name like :searchTextPat Or ERP7__Account__r.Name like :searchTextPat Or ERP7__Barcode__c like :searchTextPat) Order by CreatedDate Desc Limit 10000'); // Or ERP7__Sales_Order__r.ERP7__Tracking_Number__c like :searchTextPat
                
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
                   
                    if(solis.ERP7__Order_Product__r.OrderId != Null) {
                        myLogOrders.put(solis.ERP7__Order_Product__r.OrderId, solis.ERP7__Order_Product__r.Order.Name);
                    }
                    if(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c != Null) {
                        myLogOrders.put(solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, solis.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__r.Name);
                    } 
                    if(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c != Null) {
                        myLogOrders.put(solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__c, solis.ERP7__Purchase_Line_Items__r.ERP7__Purchase_Orders__r.Name);
                    }
                    if(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c != Null){
                        myLogOrders.put(solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__c, solis.ERP7__Work_Order_Line_Items__r.ERP7__Work_Orders__r.Name);
                    }
                    if(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c != Null) {
                        myLogOrders.put(solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__c, solis.ERP7__Transfer_Order_Line_Item__r.ERP7__Transfer_Order__r.Name);
                    }
                    if(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c != Null) {
                        myLogOrders.put(solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, solis.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__r.Name);
                    }
                    logOrders.put(solis.ERP7__Logistic__c, myLogOrders);
                }
                
                List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Logs Order By CreatedDate ASC];
                Map<Id,Attachment> LogisticAttachments = new Map<Id,Attachment>();
                for(Attachment A : Attachments) LogisticAttachments.put(A.ParentId,A);

                List<ERP7__Google_Drive__c> DriveList = [Select Id, Name, ERP7__File_Link__c, ERP7__Logistic__c from ERP7__Google_Drive__c where ERP7__Logistic__c IN :Logs Order By CreatedDate ASC];
                Map<Id,ERP7__Google_Drive__c> LogisticDrive = new Map<Id,ERP7__Google_Drive__c>();
                for(ERP7__Google_Drive__c G : DriveList) LogisticDrive.put(G.ERP7__Logistic__c,G);
                
                Set<Id> linkedEntityIds = new Set<Id>();
                for (ERP7__Logistic__c log : logs) {
                    linkedEntityIds.add(log.Id);
                }
                List<ContentDocumentLink> CDL = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityIds];
                Map<Id, ContentDocumentLink> contentDocumentLinkMap = new Map<Id, ContentDocumentLink>();
                for (ContentDocumentLink link : CDL) {
                    contentDocumentLinkMap.put(link.ContentDocumentId, link);
                }
                
                Set<Id> contentDocumentIds = contentDocumentLinkMap.keySet();
                List<ContentVersion> CVList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
                Map<Id, ContentVersion> LogisticConAttach = new Map<Id, ContentVersion>();
                
                for (ContentVersion contentVersion : CVList) {
                    Id linkedEntityId = contentDocumentLinkMap.get(contentVersion.ContentDocumentId).LinkedEntityId;
                    LogisticConAttach.put(linkedEntityId, contentVersion);
                }

                List<ERP7__GoogleCredentials__c> ActUser = [Select Id, Name, ERP7__UserName__c, ERP7__DriveEmail__c, ERP7__Active__c, ERP7__RefreshToken__c, ERP7__AccessToken__c From ERP7__GoogleCredentials__c Where ERP7__UserName__c = : UserInfo.getUserName() and ERP7__Active__c=true Limit 1];
            		if(ActUser.size() > 0){ comW.SalesFile = false; comW.DriveFile = true; }
            		else if(ActUser.size() == 0){ comW.SalesFile = true; comW.DriveFile = false; }

                List<LogisticWrapper> LogisticWrapperList = new List<LogisticWrapper>();
                for(ERP7__Logistic__c log : Logs){ 
                    LogisticWrapper logWrapper = new LogisticWrapper();
                    
                    Map<Id, String> myLogOrders = logOrders.get(log.Id);
                    for(Id oId : myLogOrders.keySet()) {
                        orderWrapper owrap = new orderWrapper();
                        owrap.OrderId = oId;
                        owrap.OrderName = myLogOrders.get(oId);
                        logWrapper.orderWrapperList.add(owrap);
                    }   

                    if(comW.DriveFile == true) { logWrapper.isGDrive = true; }
                    if(comW.SalesFile == true) { logWrapper.isSales = true; }
                    logWrapper.Logistic = log; 
                    logWrapper.Attach = (LogisticAttachments.ContainsKey(log.Id))? LogisticAttachments.get(log.Id) : new Attachment();
                    logWrapper.GDrive = (LogisticDrive.ContainsKey(log.Id))? LogisticDrive.get(log.Id) : new ERP7__Google_Drive__c();
                    logWrapper.conAttach = (LogisticConAttach.ContainsKey(log.Id))? LogisticConAttach.get(log.Id) : new ContentVersion();
                    if(logisticId != Null && logisticId != '' && (log.ERP7__Barcode__c == logisticId || log.Id == logisticId)) logWrapper.isSelected = true; 
                    else logWrapper.isSelected = false; 
                    LogisticWrapperList.add(logWrapper); 
                }
                comW.LogisticWrapperList = LogisticWrapperList;
            } else comW.exceptionError = 'Sorry, no records available to view.'; 
           
            
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap DeleteAT(String RAId, String ObjName){   
        comWrap comW = new comWrap();
        try{
            String query = 'select Id from ' +String.escapeSingleQuotes(ObjName)+ ' Where Id =:RAId';
            SObject AT = Database.query(query);
            SObjectType sObjType = ((SObject) Type.forName(ObjName).newInstance()).getSObjectType();
            if(sObjType.getDescribe().isDeletable()){ delete AT;}else{/*No access*/}
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }   return comW;
    }

    @AuraEnabled
    public static comWrap uploadGFile(Id parent, List<Id> documentIds, boolean SyncSales, boolean SyncGDrive) {
        comWrap comW = new comWrap();
        try{            
            if(SyncGDrive == true){
                GoogleDriveController.uploadGFile(parent, documentIds, SyncSales, SyncGDrive);
                List<ERP7__Google_Drive__c> DriveList = [Select Id, Name, ERP7__File_Link__c, ERP7__Logistic__c from ERP7__Google_Drive__c where ERP7__Logistic__c =:parent Order By CreatedDate ASC];
                if(DriveList.size() > 0)comW.uniGdrive = DriveList[0];
            }   
            if(SyncSales == true){
                List<ContentVersion> CVList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :documentIds];
                if(CVList.size() > 0)comW.uniContentVersion = CVList[0];
            }
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }   return comW;
    }
    
    @AuraEnabled
    public static comWrap uploadFile(String parent, String fileName, String base64Data, String contentType,boolean SyncSales, boolean SyncGDrive) { 
        comWrap comW = new comWrap();
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment a = new Attachment();
            if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable()) { a.parentId = parent; } else {}
            if(Schema.sObjectType.Attachment.fields.body.isCreateable()) {a.Body = EncodingUtil.base64Decode(base64Data);} else{}
            if(Schema.sObjectType.Attachment.fields.Name.isCreateable() ) { a.Name = fileName; } else{}
            if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) { a.ContentType = contentType; }
            if(Attachment.sObjectType.getDescribe().isCreateable() && SyncSales == true) { insert a; } else{ }
            String AttString = a.Name + ',' + EncodingUtil.base64Encode(a.Body) + ',' + a.ContentType + ',' + a.parentId;
            comW.universalAttachment = a;            
            
            /*'*** a : '+a);*/
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }   return comW;        
    } 
    
    @AuraEnabled
    public static comWrap ReceiveAll(String LogisticIds){
        comWrap comW = new comWrap();
        try {
            String InwardFields = UtilClass.selectStarFromSObject('ERP7__Stock_Inward_Line_Item__c');   
            utilClass.FLSCheck(InwardFields.split(','),'ERP7__Stock_Inward_Line_Item__c');
            String PPLIFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');   
            utilClass.FLSCheck(PPLIFields.split(','),'ERP7__Stock_Outward_Line_Item__c');
            String warehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');       
            utilClass.FLSCheck(warehouseFields.split(','),'ERP7__Inventory_Stock__c'); 
            String siteFields = UtilClass.selectStarFromSObject('ERP7__Site__c');         
            utilClass.FLSCheck(siteFields.split(','),'ERP7__Site__c'); 
            
            String logFields = UtilClass.selectStarFromSObject('ERP7__Logistic__c');
            utilClass.FLSCheck(logFields.split(','),'ERP7__Logistic__c');    
            String logLineFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
            utilClass.FLSCheck(logLineFields.split(','),'ERP7__Logistic_Line_Item__c'); 
            logLineFields += ' ,Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c, Product__r.Is_Asset__c, ERP7__Logistic__r.Name, Product__r.Item_Description__c, Product__r.Weight__c, Product__r.Special_Instructions__c, Product__r.ERP7__Is_Kit__c, Product__r.ERP7__Kit_Protected__c, ERP7__Order_Product__r.OrderId, Sales_Order_Line_Item__r.Sales_Order__c, ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c, ERP7__Purchase_Line_Items__r.ERP7__Sales_Order_Line_Item__c, ERP7__Purchase_Line_Items__r.ERP7__Sales_Order__c,ERP7__Purchase_Line_Items__r.ERP7__Order_Product__c, ERP7__Purchase_Line_Items__r.ERP7__Order__c, ERP7__Purchase_Line_Items__r.Purchase_Orders__c, ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__c, ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c, ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Unit__c, ERP7__Work_Order_Line_Items__r.Work_Orders__c, ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c, Logistic__r.Account__c, Logistic__r.Account__r.Name, ERP7__Sales_Order_Line_Item__r.Name, ERP7__RMA_Line_Item__r.Name, ERP7__Work_Order_Line_Items__r.Name, ERP7__Transfer_Order_Line_Item__r.Name, Product__r.Name, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Is_OverSized_Item__c, ERP7__Fixed_Asset__r.ERP7__Lot_Tracked__c, ERP7__Fixed_Asset__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c, Product__r.Barcode__c, Product__r.Serialise__c, Product__r.ERP7__Default_Location__c, Product__r.ERP7__Default_Location__r.ERP7__Site__c, ERP7__Fixed_Asset__r.Serialise__c, ERP7__RMA_Line_Item__r.ERP7__Serial_Number__c, ERP7__RMA_Line_Item__r.ERP7__Serial_Number__r.Name, ERP7__Transfer_Order_Line_Item__r.ERP7__SerialNumber__c, ERP7__RMA_Line_Item__r.ERP7__SOLI__c,ERP7__RMA_Line_Item__r.ERP7__Ord_Item__c ';
            
            List<String> soIdss = (List<String>) JSON.deserialize(LogisticIds, List<String> .class);
            String selectedSite = '';
            Set<Id> OrderIds = new Set<Id>();
            Set<Id> spIds = new Set<Id>();
            
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__First_Name__c, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Last_Name__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                         ERP7__Organisation_Business_Unit__c
                         From ERP7__Employees__c
                         Where ERP7__Employee_User__c = : UserInfo.getUserId()
                         Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                comW.Employee = empList[0]; 
                
                if(comW.Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c, Channel__c, Site__c, Site__r.Name
                                                                                        From Distribution_Channel__c
                                                                                        Where Channel__c = : comW.Employee.Channel__c And Active__c = true And Site__c != Null
                                                                                        Order By ERP7__Primary__c Desc];
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            comW.channelSites.add(new SelectOptions(DC.Site__c, DC.Name));
                        }
                    } 
                } 
            } 
            /*'*** comW.channelSites : '+comW.channelSites);*/
            List<ERP7__Logistic__c> Logs = new List<ERP7__Logistic__c>();
            Logs = Database.query('select ' + String.escapeSingleQuotes(logFields) + ' , ERP7__Sales_Order__r.Name, ERP7__To_Address__r.Address_Line1__c, ERP7__To_Address__r.Address_Line2__c, ERP7__To_Address__r.Address_Line3__c, ERP7__To_Address__r.City__c, ERP7__To_Address__r.County__c, '+
                     +'ERP7__Distribution_Channel__r.ERP7__Site__c, Channel__r.Name, ERP7__Distribution_Channel__r.ERP7__Site__r.Name,  ERP7__To_Address__r.Country__c, ERP7__To_Address__r.State__c, ERP7__To_Address__r.Postal_Code__c, Account__r.Name from ERP7__Logistic__c where Id IN :soIdss'); 
            if(Logs.size() > 0){
                comW.SiteName = Logs[0].ERP7__Distribution_Channel__r.ERP7__Site__r.Name;
                comW.ChannelName = Logs[0].Channel__r.Name;
                comW.ChannelId = Logs[0].Channel__c;
                comW.selectedSite = Logs[0].ERP7__Distribution_Channel__r.ERP7__Site__c;
                selectedSite = comW.selectedSite;
            }
            List<Id> soIds = new List<Id>();
            for(ERP7__Logistic__c log : Logs){ 
                LogisticWrapper logWrapper = new LogisticWrapper(); 
                logWrapper.Logistic = log; 
                logWrapper.isSelected = false; 
                comW.LogisticWrapperList.add(logWrapper); 
            }
            /*'*** comW.LogisticWrapperList : '+comW.LogisticWrapperList); */           
            
            
            List<LOLIWrapper> LOLIWrapperList = new List<LOLIWrapper>();
            List<Stock_Inward_Line_Item__c> SPLIS2Delete = new List<Stock_Inward_Line_Item__c>();
            List<Inventory_Stock__c> stocks2Delete = new List<Inventory_Stock__c>();
            List<Serial_Number__c> SerialNumbers2Delete = new List<Serial_Number__c>();
            Map<String, Decimal> lineItemprocessedQuantities = new Map<String, Decimal>();
            
            List<ERP7__Logistic__c> Logistics = Logs;
            /*'soIdss : '+soIdss);*/
            //String query1 = 'select ' + logLineFields + ' from ERP7__Logistic_Line_Item__c where Logistic__c in : soIdss order by CreatedDate ASC';
            String query1 = 'select ' + String.escapeSingleQuotes(logLineFields) + ' from ERP7__Logistic_Line_Item__c where Logistic__c in : soIdss order by ERP7__Purchase_Line_Items__r.ERP7__Sort_Order__c';
            List<ERP7__Logistic_Line_Item__c> Lolis = Database.query(query1);
           System.debug('Lolis:'+Lolis.size());
            List<String> productIds = new List<String>();
            List<String> LOLIIds = new List<String>();
            Set<Id> OrderLineIds = new Set<Id>();
            Set<Id> rmasoliIds = new Set<Id>();
            for(Logistic_Line_Item__c loli : Lolis){
                if(loli.Product__c != Null) productIds.add(loli.Product__c);
                LOLIIds.add(loli.Id);
                if(loli.ERP7__RMA_Line_Item__c != Null) { OrderLineIds.add(loli.ERP7__RMA_Line_Item__c); if(loli.ERP7__RMA_Line_Item__r.ERP7__SOLI__c != null) rmasoliIds.add(loli.ERP7__RMA_Line_Item__r.ERP7__SOLI__c); if(loli.ERP7__RMA_Line_Item__r.ERP7__Ord_Item__c != null) rmasoliIds.add(loli.ERP7__RMA_Line_Item__r.ERP7__Ord_Item__c);}
                else if(loli.ERP7__Purchase_Line_Items__c != Null) OrderLineIds.add(loli.ERP7__Purchase_Line_Items__c);
                else if(loli.ERP7__Work_Order_Line_Items__c != Null) OrderLineIds.add(loli.ERP7__Work_Order_Line_Items__c);
                else if(loli.ERP7__Transfer_Order_Line_Item__c != Null) OrderLineIds.add(loli.ERP7__Transfer_Order_Line_Item__c);
                
            }
            /*'OrderLineIds : '+OrderLineIds);*/
            List<ERP7__MRP__c> MRPS = [Select Id, Name, ERP7__Transfer_Order_Line_Item__c, ERP7__RMA_Line_Item__c, ERP7__Work_Order_Line_Items__c,  ERP7__Purchase_Line_Items__c, ERP7__Total_Amount_Required__c, ERP7__BOM__c, ERP7__MRP_Product__c, ERP7__MRP_Product__r.Name, ERP7__MRP_Product__r.Serialise__c,ERP7__MRP_Product__r.ERP7__Is_OverSized_Item__c, ERP7__MRP_Product__r.ERP7__Default_Location__c, ERP7__MRP_Product__r.ERP7__Default_Location__r.ERP7__Site__c, ERP7__MRP_Product__r.Lot_Tracked__c, ERP7__MRP_Product__r.Picture__c, ERP7__MRP_Product__r.Preview_Image__c, RecordType.Name From ERP7__MRP__c Where (ERP7__Transfer_Order_Line_Item__c In :OrderLineIds Or ERP7__Work_Order_Line_Items__c In :OrderLineIds Or ERP7__Purchase_Line_Items__c In :OrderLineIds Or ERP7__RMA_Line_Item__c In :OrderLineIds) And RecordType.Name = 'MRP Kit'];
            
            String allFields3 = InwardFields;
            UtilClass.FlSCheck(allFields3.split(',') ,'ERP7__Stock_Inward_Line_Item__c');
            String query3 = 'select ' + String.escapeSingleQuotes(allFields3) + ', ERP7__Fixed_Asset__r.Product__c from ERP7__Stock_Inward_Line_Item__c where (ERP7__Transfer_Order_Line_Item__c In :OrderLineIds Or ERP7__Work_Order_Line_Items__c In :OrderLineIds Or ERP7__Purchase_Line_Items__c In :OrderLineIds Or ERP7__RMA_Line_Item__c In :OrderLineIds) AND ERP7__Logistic_Line_Item__c In :LOLIIds order by CreatedDate ASC';
            List<ERP7__Stock_Inward_Line_Item__c> SPLIS = Database.query(query3);
            
            for(Logistic_Line_Item__c loli : Lolis){
                Decimal quantityProcessed = 0;
                if(loli.Explode__c != true){
                    for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                        if(((loli.ERP7__RMA_Line_Item__c != Null && SPLI.ERP7__RMA_Line_Item__c == loli.ERP7__RMA_Line_Item__c) || (loli.ERP7__Transfer_Order_Line_Item__c != Null && SPLI.ERP7__Transfer_Order_Line_Item__c == loli.ERP7__Transfer_Order_Line_Item__c) || (loli.ERP7__Work_Order_Line_Items__c != Null && SPLI.ERP7__Work_Order_Line_Items__c == loli.ERP7__Work_Order_Line_Items__c) || (loli.ERP7__Purchase_Line_Items__c != Null && SPLI.ERP7__Purchase_Line_Items__c == loli.ERP7__Purchase_Line_Items__c)) && SPLI.Quantity__c != Null && ((!loli.Product__r.Is_Asset__c && loli.Product__c == SPLI.Product__c) || (loli.Product__r.Is_Asset__c && loli.Product__c == SPLI.ERP7__Fixed_Asset__r.Product__c))){  if(Schema.sobjectType.ERP7__Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) quantityProcessed += SPLI.Quantity__c;
                        }
                    }
                }
                lineItemprocessedQuantities.put(loli.Id, quantityProcessed);
            }
            
            List<Id> stockIds = new List<Id>();
            List<Id> serialIds = new List<Id>();
            List<Id> batchIds = new List<Id>();
           
            for(Stock_Inward_Line_Item__c SPLI : SPLIS){    stockIds.add(SPLI.Site_ProductService_InventoryStock__c);  if(SPLI.Serial__c != Null)  {serialIds.add(SPLI.Serial__c);} if(SPLI.ERP7__Material_Batch_Lot__c != Null)  {batchIds.add(SPLI.ERP7__Material_Batch_Lot__c);}  }
            
            String allFieldsPPLI = PPLIFields;
            UtilClass.FlSCheck(allFieldsPPLI.split(',') ,'ERP7__Stock_Outward_Line_Item__c');
            allFieldsPPLI += ', Sales_Order_Line_Item__r.Sales_Order__c';
            String queryppli = 'select ' + String.escapeSingleQuotes(allFieldsPPLI) + ' from ERP7__Stock_Outward_Line_Item__c where (ERP7__Sales_Order_Line_Item__c In :rmasoliIds Or ERP7__Order_Product__c In :rmasoliIds Or ERP7__RMA_Line_Item__c In :OrderLineIds Or ERP7__Transfer_Order_Line_Item__c In :OrderLineIds Or ERP7__Work_Order_Line_Items__c In :OrderLineIds Or ERP7__Purchase_Line_Items__c In :OrderLineIds) and ERP7__Quantity__c > 0 order by CreatedDate ASC';
            List<ERP7__Stock_Outward_Line_Item__c> PPLIs2Update = Database.query(queryppli);
            
            for(Stock_Outward_Line_Item__c PPLI : PPLIs2Update){ stockIds.add(PPLI.Site_Product_Service_Inventory_Stock__c); if(PPLI.Serial__c != Null)  serialIds.add(PPLI.Serial__c); if(PPLI.ERP7__Material_Batch_Lot__c != Null)  batchIds.add(PPLI.ERP7__Material_Batch_Lot__c);}
            /*'serialIds : '+serialIds);*/
            Map<Id,Serial_Number__c> SerialMap = new Map<Id,Serial_Number__c>([Select Id, Name, Serial_Number__c, Product__c, ERP7__Asset__c from Serial_Number__c Where Id In :serialIds]);
            /*'*** SerialMap : '+SerialMap);*/
            Map<Id,ERP7__Batch__c> BatchMap = new Map<Id,ERP7__Batch__c>([Select Id, Name, ERP7__Barcode__c, ERP7__Production_Version__c From ERP7__Batch__c Where Id In: batchIds]);
            
            String allFields2 = warehouseFields;
            UtilClass.FlSCheck(allFields2.split(',') ,'ERP7__Inventory_Stock__c');
            allFields2 += ', Warehouse__r.Name, ERP7__Fixed_Asset__r.Product__c';
            /*'stockIds : '+stockIds);*/
            String query2 = 'select ' + String.escapeSingleQuotes(allFields2) + ' from ERP7__Inventory_Stock__c where Id In :stockIds order by CreatedDate ASC';
            List<ERP7__Inventory_Stock__c> warehouseStocks = Database.query(query2);
            
            String allFields4 = siteFields;
            UtilClass.FlSCheck(allFields4.split(',') ,'ERP7__Site__c');
            
            String query4 = 'select ' + String.escapeSingleQuotes(allFields4) + ' from ERP7__Site__c where Active__c = true order by CreatedDate ASC';
            List<ERP7__Site__c> Sites = Database.query(query4);
            
            Map<Id, List<Stock_Inward_Line_Item__c>> stockLines = new Map<Id, List<Stock_Inward_Line_Item__c>>();
            for(Inventory_Stock__c WIIS : warehouseStocks){
                List<Stock_Inward_Line_Item__c> mySPLIS = new List<Stock_Inward_Line_Item__c>();
                for(Stock_Inward_Line_Item__c SPLI : SPLIS){
                    if(WIIS.Id == SPLI.Site_ProductService_InventoryStock__c){ mySPLIS.add(SPLI);   break; }
                }  
                stockLines.put(WIIS.Id, mySPLIS);
            }
            
            List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :Lolis Order By CreatedDate Asc];
            Map<Id,Attachment> POLIAttachment = new Map<Id,Attachment>();
            for(Attachment A : Attachments) POLIAttachment.put(A.ParentId,A);
              
            for(ERP7__Logistic_Line_Item__c poli : Lolis){
                
                if(poli.ERP7__RMA_Line_Item__c != Null || poli.ERP7__Transfer_Order_Line_Item__c != Null){
                 if(poli.Product__r.ERP7__Serialise__c && (poli.ERP7__RMA_Line_Item__r.ERP7__Serial_Number__c != Null || poli.ERP7__Transfer_Order_Line_Item__r.ERP7__SerialNumber__c != Null)){
                        for(Inventory_Stock__c WIIS : warehouseStocks){
                            //if((!poli.Product__r.Is_Asset__c && poli.Product__c == WIIS.Product__c) || (poli.Product__r.Is_Asset__c && WIIS.ERP7__Fixed_Asset__c != Null && WIIS.ERP7__Fixed_Asset__r.Product__c == poli.Product__c)){
                                Decimal count_In = 0;
                                for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS.Id)){
                                    if(SPLI.ERP7__Site_ProductService_InventoryStock__c == WIIS.Id && SPLI.ERP7__Serial__c != Null && (SPLI.ERP7__Serial__c == poli.ERP7__RMA_Line_Item__r.ERP7__Serial_Number__c || SPLI.ERP7__Serial__c == poli.ERP7__Transfer_Order_Line_Item__r.ERP7__SerialNumber__c)) {
                                        count_In += SPLI.Quantity__c; 
                                        if(count_In > 0){
                                            LOLIWrapper PLIWrap = new LOLIWrapper(poli);
                                            PLIWrap.attach = (POLIAttachment.ContainsKey(poli.Id))? POLIAttachment.get(poli.Id) : new Attachment();
                                            PLIWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(poli.Id);
                                            PLIWrap.Incount = 1;
                                            if(SPLI.Product__c == poli.Product__c || (SPLI.ERP7__Fixed_Asset__c != Null && SPLI.ERP7__Fixed_Asset__r.Product__c == poli.Product__c) && (SPLI.ERP7__RMA_Line_Item__c == poli.ERP7__RMA_Line_Item__c || SPLI.ERP7__Transfer_Order_Line_Item__c == poli.ERP7__Transfer_Order_Line_Item__c || SPLI.ERP7__Work_Order_Line_Items__c == poli.ERP7__Work_Order_Line_Items__c || SPLI.ERP7__Purchase_Line_Items__c == poli.ERP7__Purchase_Line_Items__c)){
                                                List<Stock_Inward_Line_Item__c> tsLOLI = new List<Stock_Inward_Line_Item__c>();
                                                Stock_Inward_Line_Item__c sLOLITemp = SPLI;
                                                tsLOLI.add(sLOLITemp);
                                                StockWrapper stockWrap = new StockWrapper(WIIS, tsLOLI);
                                                stockWrap.SP.Site__c = WIIS.Warehouse__c;
                                                PLIWrap.Incount = 1;
                                                
                                                if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                                                if(SPLI.ERP7__Material_Batch_Lot__c != Null && BatchMap.containsKey(SPLI.ERP7__Material_Batch_Lot__c)) stockWrap.BatchNumber = BatchMap.get(SPLI.ERP7__Material_Batch_Lot__c);
                                                PLIWrap.StockWrapperList.add(stockWrap);
                                                LOLIWrapperList.add(PLIWrap);
                                            }
                                        }
                                    }
                                }
                                if(count_In == 0){
                                    for(ERP7__Stock_Outward_Line_Item__c SPLI : PPLIs2Update){
                                        if(SPLI.ERP7__Site_Product_Service_Inventory_Stock__c == WIIS.Id && SPLI.ERP7__Serial__c != Null && (SPLI.ERP7__Serial__c == poli.ERP7__RMA_Line_Item__r.ERP7__Serial_Number__c || SPLI.ERP7__Serial__c == poli.ERP7__Transfer_Order_Line_Item__r.ERP7__SerialNumber__c)) {
                                            LOLIWrapper PLIWrap = new LOLIWrapper(poli);
                                            PLIWrap.attach = (POLIAttachment.ContainsKey(poli.Id))? POLIAttachment.get(poli.Id) : new Attachment();
                                            PLIWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(poli.Id);
                                            PLIWrap.Incount = 1;
                                            if(SPLI.Product__c == poli.Product__c || (WIIS.ERP7__Fixed_Asset__c != Null && WIIS.ERP7__Fixed_Asset__r.Product__c == poli.Product__c) && (SPLI.ERP7__RMA_Line_Item__c == poli.ERP7__RMA_Line_Item__c || SPLI.ERP7__Transfer_Order_Line_Item__c == poli.ERP7__Transfer_Order_Line_Item__c || SPLI.ERP7__Work_Order_Line_Items__c == poli.ERP7__Work_Order_Line_Items__c || SPLI.ERP7__Purchase_Line_Items__c == poli.ERP7__Purchase_Line_Items__c)){
                                                List<Stock_Inward_Line_Item__c> tsLOLI = new List<Stock_Inward_Line_Item__c>();
                                                Stock_Inward_Line_Item__c sLOLITemp = new Stock_Inward_Line_Item__c(ERP7__Site_ProductService_InventoryStock__c=WIIS.Id);
                                                if(WIIS.ERP7__Fixed_Asset__c != Null) sLOLITemp.ERP7__Fixed_Asset__c = WIIS.ERP7__Fixed_Asset__c;
                                                else sLOLITemp.ERP7__Product__c = WIIS.ERP7__Product__c;
                                                sLOLITemp.Quantity__c = 1;
                                                tsLOLI.add(sLOLITemp);
                                                StockWrapper stockWrap = new StockWrapper(WIIS, tsLOLI);
                                                stockWrap.SP.Site__c = WIIS.Warehouse__c;
                                                PLIWrap.Incount = 1;
                                                if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                                                if(SPLI.ERP7__Material_Batch_Lot__c != Null && BatchMap.containsKey(SPLI.ERP7__Material_Batch_Lot__c)) stockWrap.BatchNumber = BatchMap.get(SPLI.ERP7__Material_Batch_Lot__c);
                                                PLIWrap.StockWrapperList.add(stockWrap);
                                                LOLIWrapperList.add(PLIWrap);
                                                //break;
                                            }
                                        }
                                    }
                                }
                            //}
                        }
                    } 
                    else {
                        LOLIWrapper PLIWrap = new LOLIWrapper(poli);
                        PLIWrap.attach = (POLIAttachment.ContainsKey(poli.Id))? POLIAttachment.get(poli.Id) : new Attachment();
                        PLIWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(poli.Id);
                        PLIWrap.Incount  = 0;
                        for(Inventory_Stock__c WIIS : warehouseStocks){
                            if((!poli.Product__r.Is_Asset__c && poli.Product__c == WIIS.Product__c) || (poli.Product__r.Is_Asset__c && WIIS.ERP7__Fixed_Asset__c != Null && WIIS.ERP7__Fixed_Asset__r.Product__c == poli.Product__c)){
                                for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS.Id)){
                                    if(SPLI.Product__c == poli.Product__c || (WIIS.ERP7__Fixed_Asset__c != Null && WIIS.ERP7__Fixed_Asset__r.Product__c == poli.Product__c) && (SPLI.ERP7__RMA_Line_Item__c == poli.ERP7__RMA_Line_Item__c || SPLI.ERP7__Transfer_Order_Line_Item__c == poli.ERP7__Transfer_Order_Line_Item__c || SPLI.ERP7__Work_Order_Line_Items__c == poli.ERP7__Work_Order_Line_Items__c || SPLI.ERP7__Purchase_Line_Items__c == poli.ERP7__Purchase_Line_Items__c)){
                                        StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS.Id));
                                        stockWrap.SP.Site__c = WIIS.Warehouse__c;
                                        PLIWrap.Incount += SPLI.Quantity__c;
                                        if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);
                                        if(SPLI.ERP7__Material_Batch_Lot__c != Null && BatchMap.containsKey(SPLI.ERP7__Material_Batch_Lot__c)) stockWrap.BatchNumber = BatchMap.get(SPLI.ERP7__Material_Batch_Lot__c);
                                        PLIWrap.StockWrapperList.add(stockWrap);
                                        //break;
                                    }
                                }
                                
                            }
                        }
                        LOLIWrapperList.add(PLIWrap);
                    }
                } 
                else {
                    LOLIWrapper PLIWrap = new LOLIWrapper(poli);
                    PLIWrap.attach = (POLIAttachment.ContainsKey(poli.Id))? POLIAttachment.get(poli.Id) : new Attachment();
                    PLIWrap.lineItemprocessedQuantity = lineItemprocessedQuantities.get(poli.Id);
                    PLIWrap.Incount  = 0;
                    for(Inventory_Stock__c WIIS : warehouseStocks){
                        if((!poli.Product__r.Is_Asset__c && poli.Product__c == WIIS.Product__c) || (poli.Product__r.Is_Asset__c && WIIS.ERP7__Fixed_Asset__c != Null && WIIS.ERP7__Fixed_Asset__r.Product__c == poli.Product__c)){
                            for(Stock_Inward_Line_Item__c SPLI : stockLines.get(WIIS.Id)){
                                if(SPLI.Product__c == poli.Product__c || (WIIS.ERP7__Fixed_Asset__c != Null && WIIS.ERP7__Fixed_Asset__r.Product__c == poli.Product__c) && (SPLI.ERP7__RMA_Line_Item__c == poli.ERP7__RMA_Line_Item__c || SPLI.ERP7__Transfer_Order_Line_Item__c == poli.ERP7__Transfer_Order_Line_Item__c || SPLI.ERP7__Work_Order_Line_Items__c == poli.ERP7__Work_Order_Line_Items__c || SPLI.ERP7__Purchase_Line_Items__c == poli.ERP7__Purchase_Line_Items__c)){
                                    StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS.Id));  stockWrap.SP.Site__c = WIIS.Warehouse__c;   PLIWrap.Incount += SPLI.Quantity__c; if(SPLI.Serial__c != Null && SerialMap.containsKey(SPLI.Serial__c)) {stockWrap.SerialNumber = SerialMap.get(SPLI.Serial__c);}if(SPLI.ERP7__Material_Batch_Lot__c != Null && BatchMap.containsKey(SPLI.ERP7__Material_Batch_Lot__c)) {stockWrap.BatchNumber = BatchMap.get(SPLI.ERP7__Material_Batch_Lot__c);} PLIWrap.StockWrapperList.add(stockWrap);
                                    //break;
                                }
                            }
                            
                        }
                    }
                    LOLIWrapperList.add(PLIWrap);  
                }
            }
            comW.LOLIWrapperList = LOLIWrapperList;
            
            comW.MRPS = MRPS;
            comW.SPLIS = SPLIS;
            comW.warehouseStocks = warehouseStocks;
            comW.stockLines = stockLines;
            comW.SerialMap = SerialMap;
            
            /*Visibility Control*/
            ERP7__Functionality_Control__c FC=new ERP7__Functionality_Control__c();
            FC=ERP7__Functionality_Control__c.getValues(userInfo.getUserId());
            if(FC==null){ FC=ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());  if(FC==null) FC=ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){ comW.showReceiveAtt=FC.ERP7__Inbound_Receive_Attachment__c;  comW.putawayLocationReq=FC.ERP7__Inbound_Putaway_Location_Required__c;}
            
            
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }   return comW;
    }
    
    @AuraEnabled
    public static comWrap SaveLOLinesReceived(String LWL){        
        comWrap comW = new comWrap();
        try {
            List<LOLIWrapper> LOLIWrapperList = (List<LOLIWrapper>) JSON.deserialize(LWL, List<LOLIWrapper> .class);
            List<Logistic_Line_Item__c> LOLIS2Upsert = new List<Logistic_Line_Item__c>();
            Map<string,decimal> lolis=new Map<string,decimal>();
            for(LOLIWrapper LOLIW : LOLIWrapperList){
                LOLIS2Upsert.add(LOLIW.LOLI);
                lolis.put(LOLIW.LOLI.ERP7__Purchase_Line_Items__c,LOLIW.ReceiveQty);
            }
            
            //for(Logistic_Line_Item__c loli : LOLIS2Upsert ){lolis.put(loli.ERP7__Purchase_Line_Items__c,loli.ERP7__Quantity_Received__c);}
            List<ERP7__Purchase_Line_Items__c> POLI=[select id,ERP7__Quantity_Received__c,ERP7__Quantity__c from  ERP7__Purchase_Line_Items__c where id In : lolis.keySet() ];
            List<ERP7__Purchase_Line_Items__c> PoliToUpdate=new List<ERP7__Purchase_Line_Items__c>();
            for(ERP7__Purchase_Line_Items__c politem : POLI){
                //politem.ERP7__Quantity_Received__c+=lolis.get(politem.Id);
                if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Quantity_Received__c.isUpdateable()){
                    if((politem.ERP7__Quantity__c > lolis.get(politem.Id)) && (politem.ERP7__Quantity_Received__c < politem.ERP7__Quantity__c)) politem.ERP7__Quantity_Received__c+=lolis.get(politem.Id);
                    else politem.ERP7__Quantity_Received__c=lolis.get(politem.Id); 
                }
                
                //if(politem.ERP7__Quantity_Received__c > politem.ERP7__Quantity__c) politem.ERP7__Quantity_Received__c=politem.ERP7__Quantity__c;
                PoliToUpdate.add(politem);
            }
            if(PoliToUpdate.size() > 0){
                 update PoliToUpdate;
            } 
            if(LOLIS2Upsert.size() > 0) {
                 update LOLIS2Upsert;
            }
            
        } catch(Exception e) {
            system.debug('exception SaveLOLinesReceived~>'+e.getMessage() +' Line Number @ : '+ e.getStackTraceString());
            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); 
        } return comW;
    }
    
    
    
    @AuraEnabled
    public static comWrap AddStockKit(String LWL, Integer counter, Integer subcounter){        
        comWrap comW = new comWrap();
        try {
            List<LOLIWrapper> LOLIWrapperList = (List<LOLIWrapper>) JSON.deserialize(LWL, List<LOLIWrapper> .class);
            
            /*counter :'+counter);
            '*** subcounter :'+subcounter); */
            LOLIWrapper LOLIWrap = LOLIWrapperList.get(counter).BOMS.get(subcounter);
            List<Stock_Inward_Line_Item__c> tspli = new List<Stock_Inward_Line_Item__c>();
            ERP7__Stock_Inward_Line_Item__c spliTemp = new ERP7__Stock_Inward_Line_Item__c(ERP7__Material_Batch_Lot__c=null);
            //if(LOLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c != true) spliTemp.Quantity__c = (LOLIWrap.LOLI.Quantity_Received__c != Null && LOLIWrap.lineItemprocessedQuantity != Null)? (((LOLIWrap.LOLI.Quantity_Received__c*LOLIWrap.MRP.ERP7__Total_Amount_Required__c)/LOLIWrap.LOLI.Quantity__c)-LOLIWrap.lineItemprocessedQuantity) : 0;
            if(LOLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c != true) spliTemp.Quantity__c = (LOLIWrap.LOLI.Quantity_Received__c != Null)? (((LOLIWrap.LOLI.Quantity_Received__c*LOLIWrap.MRP.ERP7__Total_Amount_Required__c)/LOLIWrap.LOLI.Quantity__c)) : 0;
            if(LOLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c == true) spliTemp.Quantity__c = 1;
            tspli.add(spliTemp);                                                         
            StockWrapper SW = new StockWrapper(new Inventory_Stock__c(ERP7__Batch_Lot__c=null, ERP7__Version__c = null, ERP7__Location__c = null, ERP7__StorageContainer__c = null, ERP7__Active__c = true, ERP7__Product__c = LOLIWrap.MRP.ERP7__MRP_Product__c, Name=LOLIWrap.LOLI.Name,ERP7__Checked_In_Date__c=system.today()), tspli);
            if(LOLIWrap.LOLI.ERP7__Production_Version__c != Null){   SW.Stock.ERP7__Version__c = LOLIWrap.LOLI.ERP7__Production_Version__c;   }
            if(LOLIWrap.MRP.ERP7__MRP_Product__r.Serialise__c == true){    SW.SerialNumber.ERP7__Serial_Number__c = (LOLIWrap.LOLI.Starting_Number__c != Null)? LOLIWrap.LOLI.Serial_Number_Prefix__c+String.valueof(Integer.valueof(LOLIWrap.LOLI.Starting_Number__c)+LOLIWrap.StockWrapperList.size()) : LOLIWrap.LOLI.Serial_Number_Prefix__c;  SW.SerialNumber.ERP7__Product__c = LOLIWrap.MRP.ERP7__MRP_Product__c; }
            if(LOLIWrap.MRP.ERP7__MRP_Product__r.ERP7__Default_Location__c != Null  && LOLIWrap.MRP.ERP7__MRP_Product__r.ERP7__Default_Location__r.ERP7__Site__c != Null && LOLIWrap.MRP.ERP7__MRP_Product__r.ERP7__Default_Location__r.ERP7__Site__c == LOLIWrap.LOLI.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c){  SW.Stock.ERP7__Location__c = LOLIWrap.MRP.ERP7__MRP_Product__r.ERP7__Default_Location__c; }
            LOLIWrap.StockWrapperList.add(SW);
            LOLIWrapperList[counter].BOMS[subcounter] = LOLIWrap;
            
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }     return comW;
    }
    
    @AuraEnabled
    public static comWrap RemoveStock(String LWL, Integer counter, Integer subcounter){        
        comWrap comW = new comWrap();
        try {
            List<LOLIWrapper> LOLIWrapperList = (List<LOLIWrapper>) JSON.deserialize(LWL, List<LOLIWrapper> .class);
            StockWrapper SW = LOLIWrapperList.get(counter).StockWrapperList.remove(subcounter);
            
            List<Stock_Inward_Line_Item__c> SPLIS2delete = new List<Stock_Inward_Line_Item__c>();
            if(SW.stock != Null && SW.stock.Id != Null) { 
                if(SW.SPLI.size() > 0){  for(Stock_Inward_Line_Item__c SPLI : SW.SPLI) if(SPLI.Id != Null) SPLIS2delete.add(SPLI); }
                if(SPLIS2delete.size() > 0 && (Stock_Inward_Line_Item__c.sObjectType.getDescribe().isDeletable())) { delete SPLIS2delete; } else{ }
                if(Inventory_Stock__c.sObjectType.getDescribe().isDeletable()) { delete SW.stock; } else{ }
            }  
            if(SW.SerialNumber != Null && SW.SerialNumber.Id != Null && (ERP7__Serial_Number__c.sObjectType.getDescribe().isDeletable())) { delete SW.SerialNumber; } else { }
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  } return comW;
    }
    
    @AuraEnabled
    public static comWrap RemoveStockKit(String LWL, Integer counter, Integer subcounter, Integer lastcounter){        
        comWrap comW = new comWrap();
        try {
            
            List<LOLIWrapper> LOLIWrapperList = (List<LOLIWrapper>) JSON.deserialize(LWL, List<LOLIWrapper> .class);
            StockWrapper SW = LOLIWrapperList.get(lastcounter).BOMS.get(counter).StockWrapperList.get(subcounter);
            //LOLIWrapperList.get(lastcounter).BOMS.get(counter).StockWrapperList.remove(subcounter);
            
            if(SW.stock != Null && SW.stock.Id != Null && (Inventory_Stock__c.sObjectType.getDescribe().isDeletable())) { delete SW.stock; } else{ } //stocks2Delete.add(SW.stock);
            if(SW.SerialNumber != Null && SW.SerialNumber.Id != Null && (ERP7__Serial_Number__c.sObjectType.getDescribe().isDeletable())) { delete SW.SerialNumber; } else{ } //SerialNumbers2Delete.add(SW.SerialNumber);
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }
        return comW;
    }
    
   
    
    @AuraEnabled
    public static comWrap DeleteStock(String StockId, String SerialId){        
        comWrap comW = new comWrap();
        try {
            /*'*** StockId2delete :'+StockId);
            '*** SerialId2Delete :'+SerialId);*/
            if(StockId != '') {
                List<Inventory_Stock__c> Stock2delete  = [Select Id From Inventory_Stock__c Where Id =: StockId];
                if(Stock2delete.size() > 0){  if(Inventory_Stock__c.sObjectType.getDescribe().isDeletable()) delete Stock2delete;} 
            }
            if(SerialId != '') {
                List<Serial_Number__c> Serial2delete  = [Select Id From Serial_Number__c Where Id =: SerialId];
                if(Serial2delete.size() > 0){ if(Serial_Number__c.sObjectType.getDescribe().isDeletable()) delete Serial2delete;} 
            }
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }   return comW;
    }
    
    /**These code has been implemented in js file. Methods:(ExplodeKit,AddStock,AddStock)
     * It was not working when items were more than 500. Apex CPU Time limit exceed error.
     * Now we can uncommnet these methods
	*/

    @AuraEnabled
    public static comWrap ExplodeKit(String comWS, Integer counter){        
        comWrap comW = (comWrap) JSON.deserialize(comWS, comWrap .class);
        try {
            List<LOLIWrapper> LOLIWrapperList = comW.LOLIWrapperList;
            LOLIWrapper LOLIWrap = LOLIWrapperList.get(counter);
           
            List<LOLIWrapper> BomsWrapper = new List<LOLIWrapper>();
            Map<String, Decimal> lineItemprocessedQuantities = new Map<String, Decimal>();
            
            List<ERP7__MRP__c> MRPS = comW.MRPS;
            List<Stock_Inward_Line_Item__c> SPLIS = comW.SPLIS;
            List<Inventory_Stock__c> warehouseStocks = comW.warehouseStocks;
            Map<Id, List<Stock_Inward_Line_Item__c>> stockLines = comW.stockLines;
            Map<Id,Serial_Number__c> SerialMap = comW.SerialMap;
            
            for(ERP7__MRP__c mrp : MRPS){
                Decimal quantityProcessed = 0;
                for(Stock_Inward_Line_Item__c SLOLI : SPLIS){                    Id LineId;                    if(SLOLI.ERP7__RMA_Line_Item__c != Null) {LineId = SLOLI.ERP7__RMA_Line_Item__c;} else if(SLOLI.ERP7__Purchase_Line_Items__c != Null) {LineId = SLOLI.ERP7__Purchase_Line_Items__c;}  else if(SLOLI.ERP7__Work_Order_Line_Items__c != Null) {LineId = SLOLI.ERP7__Work_Order_Line_Items__c;}   else if(SLOLI.ERP7__Transfer_Order_Line_Item__c != Null) {LineId = SLOLI.ERP7__Transfer_Order_Line_Item__c;} if(SLOLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SLOLI.Product__c && LineId != Null && (mrp.ERP7__RMA_Line_Item__c == LineId || mrp.ERP7__Work_Order_Line_Items__c == LineId || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineId)){    quantityProcessed += SLOLI.Quantity__c;  }
                }
                lineItemprocessedQuantities.put(mrp.ERP7__MRP_Product__c, quantityProcessed);
            }
           
            for(ERP7__MRP__c mrp : MRPS){
                Id LineId;
                if(mrp.ERP7__RMA_Line_Item__c != Null) LineId = mrp.ERP7__RMA_Line_Item__c;
                else if(mrp.ERP7__Purchase_Line_Items__c != Null) LineId = mrp.ERP7__Purchase_Line_Items__c;
                else if(mrp.ERP7__Work_Order_Line_Items__c != Null) LineId = mrp.ERP7__Work_Order_Line_Items__c;
                else if(mrp.ERP7__Transfer_Order_Line_Item__c != Null) LineId = mrp.ERP7__Transfer_Order_Line_Item__c;
                
                
                if(LineId != Null && (mrp.ERP7__RMA_Line_Item__c == LineId || mrp.ERP7__Work_Order_Line_Items__c == LineId || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineId)){
                    LOLIWrapper LOLIWrapIN = new LOLIWrapper(LOLIWrap.LOLI);
                    LOLIWrapIN.mrp = mrp;
                    LOLIWrapIN.lineItemprocessedQuantity = lineItemprocessedQuantities.get(mrp.ERP7__MRP_Product__c);
                    LOLIWrapIN.Incount  = 0;
                    for(Inventory_Stock__c WIIS : warehouseStocks){
                        if(mrp.ERP7__MRP_Product__c == WIIS.Product__c){ for(Stock_Inward_Line_Item__c SLOLI : stockLines.get(WIIS.Id)){  Id LineIdStock;  if(SLOLI.ERP7__RMA_Line_Item__c != Null) {LineIdStock = SLOLI.ERP7__RMA_Line_Item__c;}  else if(SLOLI.ERP7__Purchase_Line_Items__c != Null) {LineIdStock = SLOLI.ERP7__Purchase_Line_Items__c;}  else if(SLOLI.ERP7__Work_Order_Line_Items__c != Null) {LineIdStock = SLOLI.ERP7__Work_Order_Line_Items__c;}  else if(SLOLI.ERP7__Transfer_Order_Line_Item__c != Null) {LineIdStock = SLOLI.ERP7__Transfer_Order_Line_Item__c;}
                                
                                if(SLOLI.Quantity__c != Null && mrp.ERP7__MRP_Product__c == SLOLI.Product__c && LineIdStock != Null && (mrp.ERP7__RMA_Line_Item__c == LineIdStock || mrp.ERP7__Work_Order_Line_Items__c == LineIdStock || mrp.ERP7__Purchase_Line_Items__c == LineId || mrp.ERP7__Transfer_Order_Line_Item__c == LineIdStock)){   StockWrapper stockWrap = new StockWrapper(WIIS,stockLines.get(WIIS.Id));  if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) LOLIWrapIN.Incount += SLOLI.Quantity__c; if(SLOLI.Serial__c != Null && SerialMap.containsKey(SLOLI.Serial__c)){  stockWrap.SerialNumber = SerialMap.get(SLOLI.Serial__c); }  LOLIWrapIN.StockWrapperList.add(stockWrap);
                                    
                                }
                            }
                            
                        }
                    }
                    if(LOLIWrapIN.StockWrapperList.size() == 0){
                        if(mrp.ERP7__MRP_Product__r.Serialise__c != true){
                            List<Stock_Inward_Line_Item__c> tsLOLI = new List<Stock_Inward_Line_Item__c>();
                            Stock_Inward_Line_Item__c sLOLITemp = new Stock_Inward_Line_Item__c();
                            sLOLITemp.Quantity__c = (LOLIWrapIN.LOLI.Quantity_Received__c != Null && LOLIWrapIN.lineItemprocessedQuantity != Null)? ((LOLIWrapIN.LOLI.Quantity_Received__c * LOLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/LOLIWrapIN.LOLI.Quantity__c) - LOLIWrapIN.lineItemprocessedQuantity : 0;
                            tsLOLI.add(sLOLITemp);
                            StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Version__c = LOLIWrapIN.LOLI.ERP7__Production_Version__c, Active__c = true, Product__c = LOLIWrapIN.MRP.ERP7__MRP_Product__c, Name=LOLIWrapIN.LOLI.Name,Checked_In_Date__c=system.today()), tsLOLI);
                            LOLIWrapIN.StockWrapperList.add(SW);
                        }else{ if(LOLIWrapIN.LOLI.Quantity_Received__c != Null && LOLIWrapIN.lineItemprocessedQuantity != Null){  Integer N = Integer.valueof(((LOLIWrapIN.LOLI.Quantity_Received__c * LOLIWrapIN.mrp.ERP7__Total_Amount_Required__c)/LOLIWrapIN.LOLI.Quantity__c) - LOLIWrapIN.lineItemprocessedQuantity);  for(Integer i=0; i<N; i++){  List<Stock_Inward_Line_Item__c> tsLOLI = new List<Stock_Inward_Line_Item__c>(); Stock_Inward_Line_Item__c sLOLITemp = new Stock_Inward_Line_Item__c(ERP7__Material_Batch_Lot__c=null); sLOLITemp.Quantity__c = 1;  tsLOLI.add(sLOLITemp);    StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Batch_Lot__c = null, Version__c = LOLIWrapIN.LOLI.ERP7__Production_Version__c, Active__c = true, Product__c = LOLIWrapIN.MRP.ERP7__MRP_Product__c, Name=LOLIWrapIN.LOLI.Name,Checked_In_Date__c=system.today()), tsLOLI);    SW.SerialNumber.Serial_Number__c = (LOLIWrapIN.LOLI.Starting_Number__c != Null)? LOLIWrapIN.LOLI.Serial_Number_Prefix__c+String.valueof(LOLIWrapIN.LOLI.Starting_Number__c+i) : LOLIWrapIN.LOLI.Serial_Number_Prefix__c;  SW.SerialNumber.Product__c = LOLIWrapIN.MRP.ERP7__MRP_Product__c; LOLIWrapIN.StockWrapperList.add(SW);
                                }
                            }
                        }
                    }
                    BomsWrapper.add(LOLIWrapIN);
                }
            }
            
            LOLIWrap.BOMS = BomsWrapper;
            LOLIWrapperList[counter] = LOLIWrap;
            
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }    return comW;
    }

    @AuraEnabled
    public static comWrap AddStock(String LWL, Integer counter){        
        comWrap comW = new comWrap();
        try {
            List<LOLIWrapper> LOLIWrapperList = (List<LOLIWrapper>) JSON.deserialize(LWL, List<LOLIWrapper> .class);
           
            LOLIWrapper LOLIWrap = LOLIWrapperList.get(counter);
            List<Stock_Inward_Line_Item__c> tsLOLI = new List<Stock_Inward_Line_Item__c>();
            Stock_Inward_Line_Item__c sLOLITemp = new Stock_Inward_Line_Item__c(ERP7__Material_Batch_Lot__c=null);
            //if(LOLIWrap.LOLI.Product__r.Serialise__c != true) sLOLITemp.Quantity__c = (LOLIWrap.LOLI.Quantity_Received__c != Null && LOLIWrap.lineItemprocessedQuantity != Null)? LOLIWrap.LOLI.Quantity_Received__c-LOLIWrap.lineItemprocessedQuantity : 0;
            if(LOLIWrap.LOLI.Product__r.Serialise__c != true) sLOLITemp.Quantity__c = (LOLIWrap.LOLI.Quantity_Received__c != Null)? LOLIWrap.LOLI.Quantity_Received__c : 0;
            if(LOLIWrap.LOLI.Product__r.Serialise__c == true) sLOLITemp.Quantity__c = 1;
            tsLOLI.add(sLOLITemp);
            StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Batch_Lot__c=null, Version__c = LOLIWrap.LOLI.ERP7__Production_Version__c, Active__c = true, Product__c = LOLIWrap.LOLI.Product__c, Name=LOLIWrap.LOLI.Name,Checked_In_Date__c=system.today()), tsLOLI);
            if(LOLIWrap.LOLI.Product__r.Serialise__c == true){
                SW.SerialNumber.Serial_Number__c = (LOLIWrap.LOLI.Starting_Number__c != Null)? LOLIWrap.LOLI.Serial_Number_Prefix__c+String.valueof(LOLIWrap.StockWrapperList.size() + Integer.valueof(LOLIWrap.LOLI.Starting_Number__c)) : LOLIWrap.LOLI.Serial_Number_Prefix__c;
                SW.SerialNumber.Product__c = LOLIWrap.LOLI.Product__c;
            }
            
            if(LOLIWrap.LOLI.Product__r.ERP7__Default_Location__c != Null  && LOLIWrap.LOLI.Product__r.ERP7__Default_Location__r.ERP7__Site__c != Null && LOLIWrap.LOLI.Product__r.ERP7__Default_Location__r.ERP7__Site__c == LOLIWrap.LOLI.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c){   SW.Stock.ERP7__Location__c = LOLIWrap.LOLI.Product__r.ERP7__Default_Location__c; }
            LOLIWrap.StockWrapperList.add(SW);
            LOLIWrapperList[counter] = LOLIWrap;
            
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  } return comW;
    }
    
    
    @AuraEnabled
    public static comWrap PutAway(String comWS){        
        comWrap comW = (comWrap) JSON.deserialize(comWS, comWrap .class);
        
        try {
            List<LOLIWrapper> LOLIWrapperList = comW.LOLIWrapperList;
            Boolean proceed = false;
            for(Integer i=0; i< LOLIWrapperList.size(); i++){
                Integer counter = i;
                LOLIWrapper LOLI = LOLIWrapperList[i];
                if(LOLI.selected) proceed = true;
                if(LOLI.StockWrapperList.size()==0 && LOLI.LOLI.Quantity__c > 0 && LOLI.LOLI.Quantity_Received__c > 0 && LOLI.LOLI.Quantity_Received__c > LOLI.lineItemprocessedQuantity){
                   if((LOLI.LOLI.Product__r.ERP7__Is_Kit__c == true && LOLI.LOLI.ERP7__Explode__c == false) || LOLI.LOLI.Product__r.ERP7__Is_Kit__c != true){
                       counter = i;
                       if(LOLI.LOLI.Product__r.Serialise__c){
                           Integer N = Integer.valueof(LOLI.LOLI.Quantity_Received__c - LOLI.lineItemprocessedQuantity);
                           for(Integer j=0; j<N; j++) { 
                               counter = i; 
                               LOLIWrapperList[counter] = AddStock(JSON.serialize(LOLIWrapperList), counter).LOLIWrapperList[counter]; 
                           }
                       } else {
                           LOLIWrapperList[counter] = AddStock(JSON.serialize(LOLIWrapperList), counter).LOLIWrapperList[counter];
                       }
                   } else if(LOLI.LOLI.Product__r.ERP7__Is_Kit__c == true && LOLI.LOLI.ERP7__Explode__c == true){
                      counter = i; 
                      comW.LOLIWrapperList = LOLIWrapperList;
                      LOLIWrapperList[counter] = ExplodeKit(JSON.serialize(comW), counter).LOLIWrapperList[counter];
                       
                   }
                }
            }
            
          //  List<ERP7__StorageContainer__c> sto = [Select Id ,ERP7__Active__c, Name,ERP7__Site__c From ERP7__StorageContainer__c where ERP7__Site__c =:comW.selectedSite LIMIT 10];
            //'sto : '+sto);
            //if(sto.size() > 0){
            //if(Schema.sObjectType.ERP7__StorageContainer__c.fields.ERP7__Active__c.isAccessible()){ comW.showbinn = true;}
            //else comW.showbinn = false;
            //}
           
            if(proceed) comW.Putaway = true;
            else comW.Putaway = false;
            
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) { comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  }
        
        return comW;
    }
    
    
    @AuraEnabled
    public static comWrap SaveLOLines(String LWL){        
        comWrap comW = new comWrap();
        Savepoint sp = Database.setSavepoint();
        try {
            List<LOLIWrapper> LOLIWrapperList = (List<LOLIWrapper>) JSON.deserialize(LWL, List<LOLIWrapper> .class);
            List<Logistic_Line_Item__c> PLIS2Upsert = new List<Logistic_Line_Item__c>();                   
            List<Inventory_Stock__c> Stocks2Upsert = new List<Inventory_Stock__c>();                    
            List<Stock_Inward_Line_Item__c> SPLIS2Upsert = new List<Stock_Inward_Line_Item__c>();   
            List<Serial_Number__c> Serials2Upsert = new List<Serial_Number__c>();
            List<ERP7__Batch__c> Batches2Upsert = new List<ERP7__Batch__c>();
            Map<String,Decimal> totalPutawayQTY = new  Map<String,Decimal>();
            Boolean Error = false;
            Set<String> BatchIds = new Set<String>();
            Set<String> SerialNumbers = new Set<String>();
            Set<String> BatchNumbers = new Set<String>();
            String selectedSite = LOLIWrapperList[0].LOLI.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c; 
            String ErrMsg = '';
            
            // Required Validations
            for(LOLIWrapper LOLIW : LOLIWrapperList){
                LOLIW.errMsg = '';
                if(LOLIW.LOLI.Explode__c != true){ //Product__r.ERP7__Is_Kit__c
                    for(StockWrapper WIIS : LOLIW.StockWrapperList){
                        WIIS.SP.Site__c = selectedSite;
                        if(LOLIW.LOLI.Quantity_Received__c == Null || WIIS.stock.Name == '' || WIIS.stock.Name == Null || (LOLIW.LOLI.Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){      Error = true; LOLIW.errMsg = 'Please fill the fields marked as *'; break;  }
                        for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                            if(SPL.Quantity__c == Null || (LOLIW.LOLI.Product__r.Lot_Tracked__c && (WIIS.BatchNumber.Id == Null))){ //|| WIIS.BatchNumber.Id == ''      Batch_Lot_Code__c  Batch_Lot__c
                                Error = true; LOLIW.errMsg = 'Please fill the fields marked as *'; break;
                            }
                        }
                    }
                } else{
                    for(LOLIWrapper LOLIW_IN : LOLIW.BOMS){
                        LOLIW_IN.errMsg = '';
                        for(StockWrapper WIIS : LOLIW_IN.StockWrapperList){
                            WIIS.SP.Site__c = selectedSite;
                            if(LOLIW_IN.LOLI.Quantity_Received__c == Null || WIIS.stock.Name == '' || WIIS.stock.Name == Null || (LOLIW_IN.MRP.ERP7__MRP_Product__r.Serialise__c && (WIIS.SerialNumber.Serial_Number__c == Null || WIIS.SerialNumber.Serial_Number__c == ''))){ Error = true; LOLIW_IN.errMsg = 'Please fill the fields marked as *'; break;  }
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                if(SPL.Quantity__c == Null || (LOLIW_IN.MRP.ERP7__MRP_Product__r.Lot_Tracked__c && (WIIS.BatchNumber.Id == Null))){      Error = true; LOLIW_IN.errMsg = 'Please fill the fields marked as *'; break;  }
                            }
                        }
                    }
                }
            }
            
            if(!Error){
                // Calculation Validations
                Boolean isOkmainWrapper = true;
                for(LOLIWrapper LOLIW : LOLIWrapperList){
                    if(LOLIW.LOLI.Explode__c != true){
                        if(LOLIW.LOLI.Quantity_Received__c > LOLIW.LOLI.Quantity__c){   Error = true; LOLIW.errMsg = 'Quantity Received cannot be greater than actual Quantity'; isOkmainWrapper = false; }
                        if(LOLIW.LOLI.Quantity_Received__c < LOLIW.lineItemprocessedQuantity){  Error = true; LOLIW.errMsg = 'Quantity Received cannot be less than Quantity added'; isOkmainWrapper = false; }
                        
                    } else{
                        for(LOLIWrapper LOLIW_IN : LOLIW.BOMS){
                            if(LOLIW_IN.LOLI.Quantity_Received__c > LOLIW_IN.LOLI.Quantity__c){      Error = true; LOLIW_IN.errMsg = 'Quantity Received cannot be greater than actual Quantity.'; isOkmainWrapper = false; }
                            if(((LOLIW_IN.LOLI.Quantity_Received__c * LOLIW_IN.MRP.ERP7__Total_Amount_Required__c)/LOLIW_IN.LOLI.Quantity__c) < LOLIW_IN.lineItemprocessedQuantity){ Error = true; LOLIW_IN.errMsg = 'Quantity Received cannot be less than Quantity added.'; isOkmainWrapper = false;  }
                        }
                    }

                }
                if(!isOkmainWrapper) { ErrMsg = 'Records not updating on save, please verify the errors below.'; }
            }
      
            if(!Error){
                for(LOLIWrapper LOLIW : LOLIWrapperList){
                    if(LOLIW.LOLI.Explode__c != true){
                        Decimal subQuantity = 0;
                        for(StockWrapper WIIS : LOLIW.StockWrapperList){
                            if(WIIS.BatchNumber.Id != null) BatchIds.add(WIIS.BatchNumber.Id);
                            if(WIIS.BatchNumber.Id != null) BatchNumbers.add(WIIS.BatchNumber.Id);
                            if(LOLIW.LOLI.Product__r.Serialise__c && WIIS.SerialNumber.Serial_Number__c != '' && WIIS.SerialNumber.Serial_Number__c != null) SerialNumbers.add(WIIS.SerialNumber.Serial_Number__c);
                            for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){subQuantity += SPL.Quantity__c;
                                /*'*** SPL.Quantity__c : '+SPL.Quantity__c);*/
                                if(LOLIW.LOLI.Product__r.Serialise__c && SPL.Quantity__c > 1){   Error = true; LOLIW.errMsg = 'Serialised Product cannot have quantity greater than one'; }
                            }
                        }
                        if((LOLIW.lineItemprocessedQuantity - LOLIW.Incount + subQuantity) > LOLIW.LOLI.Quantity_Received__c){  Error = true; LOLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(LOLIW.LOLI.Quantity_Received__c - (LOLIW.lineItemprocessedQuantity - LOLIW.Incount)); }
                    } else{
                        for(LOLIWrapper LOLIW_IN : LOLIW.BOMS){
                            Decimal subQuantity_IN = 0;
                            for(StockWrapper WIIS : LOLIW_IN.StockWrapperList){
                                if(WIIS.BatchNumber.Id != null) BatchIds.add(WIIS.BatchNumber.Id);
                                if(WIIS.BatchNumber.Id != null) BatchNumbers.add(WIIS.BatchNumber.Id);
                                if(LOLIW_IN.LOLI.Product__r.Serialise__c && WIIS.SerialNumber.Serial_Number__c != '' && WIIS.SerialNumber.Serial_Number__c != null) SerialNumbers.add(WIIS.SerialNumber.Serial_Number__c);
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    subQuantity_IN += SPL.Quantity__c;
                                    if(LOLIW_IN.MRP.ERP7__MRP_Product__r.Serialise__c && SPL.Quantity__c > 1){   Error = true; LOLIW.errMsg = 'Serialised Product component cannot have quantity greater than one.'; }
                                }
                            }
                            if((LOLIW_IN.lineItemprocessedQuantity - LOLIW_IN.Incount + subQuantity_IN) > (LOLIW_IN.LOLI.Quantity_Received__c)*(LOLIW_IN.MRP.ERP7__Total_Amount_Required__c)){  Error = true; LOLIW_IN.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof((LOLIW_IN.LOLI.Quantity_Received__c)*(LOLIW_IN.MRP.ERP7__Total_Amount_Required__c)/LOLIW.LOLI.ERP7__Quantity__c)+'.';}
                        }
                    }
                }
            }
            
            if(Error){ ErrMsg = 'Records not updating on save, please verify the errors below'; }
            
            // Successful Processing
            if(!Error){
                system.debug('Successful Processing doing');
                Map<String, ERP7__Stock_Inward_Line_Item__c> SerialRec = new Map<String, ERP7__Stock_Inward_Line_Item__c>();
                Map<String, ERP7__Stock_Inward_Line_Item__c> BatchRec = new Map<String, ERP7__Stock_Inward_Line_Item__c>();
                
                List<ERP7__Stock_Inward_Line_Item__c> SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c, ERP7__Site_ProductService_InventoryStock__r.Version__c,
                                                                   Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Site_ProductService_InventoryStock__r.Warehouse__c
                                                                   From ERP7__Stock_Inward_Line_Item__c 
                                                                   Where (ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c In : BatchIds Or 
                                                                   ERP7__Serial__r.ERP7__Serial_Number__c In : SerialNumbers) And ERP7__Site_ProductService_InventoryStock__r.Warehouse__c =:selectedSite];
                
                List<ERP7__Batch__c> existingBatches = [Select Id, Name, ERP7__Barcode__c, ERP7__Production_Version__c From ERP7__Batch__c Where Id In: BatchNumbers];
                Map<String, ERP7__Batch__c> existingBatchesMap = new Map<String, ERP7__Batch__c>();
                for(ERP7__Batch__c eb : existingBatches){
                    existingBatchesMap.put(eb.Id, eb);
                }
                
                for(String BatchId : BatchIds){
                    for(ERP7__Stock_Inward_Line_Item__c SDLI : SDLIs){     if(BatchId == SDLI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c) {      BatchRec.put(BatchId,SDLI);     break;  }
                    }
                }
                
                for(String SerialNumber : SerialNumbers){
                    for(ERP7__Stock_Inward_Line_Item__c SDLI : SDLIs){    if(SerialNumber == SDLI.ERP7__Serial__r.ERP7__Serial_Number__c) {    SerialRec.put(SerialNumber,SDLI);   break;  }
                    }
                }
                
                for(LOLIWrapper LOLIW : LOLIWrapperList){
                    PLIS2Upsert.add(LOLIW.LOLI);
                    if(LOLIW.LOLI.Explode__c != true){
                        LOLIW.errMsg = '';
                        for(StockWrapper WIIS : LOLIW.StockWrapperList){
                           if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isUpdateable()) WIIS.Stock.Warehouse__c = LOLIW.LOLI.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c;
                            //if(WIIS.Stock.Name == Null || WIIS.Stock.Name == '') WIIS.Stock.Name = LOLIW.LOLI.Product__r.Name;
                            if(WIIS.BatchNumber.Id != Null) if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()) WIIS.Stock.ERP7__Batch_Lot__c = WIIS.BatchNumber.Id;
                            if(WIIS.BatchNumber.Id != Null && BatchRec.containsKey(WIIS.BatchNumber.Id)) {  WIIS.Stock.Id = BatchRec.get(WIIS.BatchNumber.Id).ERP7__Site_ProductService_InventoryStock__c;
                                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isUpdateable()) WIIS.Stock.Version__c = BatchRec.get(WIIS.BatchNumber.Id).ERP7__Site_ProductService_InventoryStock__r.Version__c;
                            }
                            if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){
                                /*'not exploid and Serial not empty or null');*/
                               if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()) WIIS.Stock.Name = WIIS.Stock.Name = LOLIW.LOLI.Product__r.Name;//WIIS.SerialNumber.Serial_Number__c;
                               if(Schema.sObjectType.ERP7__Serial_Number__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.Name.isUpdateable()) WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                               if(Schema.sObjectType.ERP7__Serial_Number__c.fields.Available__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.Available__c.isUpdateable()) WIIS.SerialNumber.Available__c = true;
                                if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isUpdateable()) WIIS.SerialNumber.Warehouse__c = LOLIW.LOLI.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c;
                                if(SerialRec.containsKey(WIIS.SerialNumber.Serial_Number__c)) {
                                    WIIS.SerialNumber.Id = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Serial__c;
                                    if(LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__c != Null) if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Card__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Card__c.isUpdateable()){ WIIS.SerialNumber.ERP7__Cost_Card__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__c; }
                                    if(LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c != Null) if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Price__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Price__c.isUpdateable()){ WIIS.SerialNumber.ERP7__Cost_Price__c = (LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Unit__c > 0)? (LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c/LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Unit__c) : LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c; }
                                    WIIS.Stock.Id = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__c;
                                   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isUpdateable()) WIIS.Stock.Version__c = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__r.Version__c;
                                   if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isUpdateable()) WIIS.SerialNumber.Warehouse__c = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__r.Warehouse__c;
                                }
                                Serials2Upsert.add(WIIS.SerialNumber);
                            }
                            if(WIIS.BatchNumber.Id != Null){    // && WIIS.BatchNumber.Id != ''
                                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()) WIIS.Stock.Name = WIIS.Stock.Name = LOLIW.LOLI.Product__r.Name;//WIIS.SerialNumber.Serial_Number__c;
                                WIIS.BatchNumber.ERP7__Active__c = true;
                                //WIIS.BatchNumber.ERP7__Barcode__c = WIIS.BatchNumber.Name;
                                WIIS.BatchNumber.ERP7__Product__c = LOLIW.LOLI.Product__c;
                                if(WIIS.Stock.Version__c != Null) WIIS.BatchNumber.ERP7__Production_Version__c = WIIS.Stock.Version__c;
                                if(existingBatchesMap.containsKey(WIIS.BatchNumber.Id)) {
                                    WIIS.BatchNumber = existingBatchesMap.get(WIIS.BatchNumber.Id);
                                    if(existingBatchesMap.get(WIIS.BatchNumber.Id).ERP7__Production_Version__c != Null) if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isUpdateable()) WIIS.Stock.Version__c = existingBatchesMap.get(WIIS.BatchNumber.Id).ERP7__Production_Version__c;
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()) WIIS.Stock.ERP7__Batch_Lot__c = WIIS.BatchNumber.Id;
                                    
                                }
                                Batches2Upsert.add(WIIS.BatchNumber);
                            }
                            Stocks2Upsert.add(WIIS.Stock);
                        }
                    } 
                    else{
                        for(LOLIWrapper LOLIW_IN : LOLIW.BOMS){
                            LOLIW_IN.errMsg = '';
                            for(StockWrapper WIIS : LOLIW_IN.StockWrapperList){
                                if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Warehouse__c.isUpdateable()) WIIS.Stock.Warehouse__c = LOLIW.LOLI.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c;
                                if(WIIS.BatchNumber.Id != Null) WIIS.Stock.ERP7__Batch_Lot__c = WIIS.BatchNumber.Id;
                                if(WIIS.BatchNumber.Id != Null && BatchRec.containsKey(WIIS.BatchNumber.Id)) {     WIIS.Stock.Id = BatchRec.get(WIIS.BatchNumber.Id).ERP7__Site_ProductService_InventoryStock__c;
                                   if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isUpdateable()) WIIS.Stock.Version__c = BatchRec.get(WIIS.BatchNumber.Id).ERP7__Site_ProductService_InventoryStock__r.Version__c;
                                }
                                if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != ''){    WIIS.Stock.Name = WIIS.Stock.Name = LOLIW_IN.LOLI.Product__r.Name;//WIIS.SerialNumber.Serial_Number__c;               if(Schema.sObjectType.ERP7__Serial_Number__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.Name.isUpdateable()) WIIS.SerialNumber.Name = WIIS.SerialNumber.Serial_Number__c;
                                    if(Schema.sObjectType.ERP7__Serial_Number__c.fields.Available__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.Available__c.isUpdateable()) WIIS.SerialNumber.Available__c = true;
                                    if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isUpdateable()) WIIS.SerialNumber.ERP7__Warehouse__c = LOLIW.LOLI.Logistic__r.ERP7__Distribution_Channel__r.ERP7__Site__c;
                                    if(SerialRec.containsKey(WIIS.SerialNumber.Serial_Number__c)) {
                                        WIIS.SerialNumber.Id = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Serial__c;
                                        if(LOLIW_IN.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__c != Null) if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Card__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Card__c.isUpdateable()){ WIIS.SerialNumber.ERP7__Cost_Card__c = LOLIW_IN.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__c; }
                                        if(LOLIW_IN.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c != Null) if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Price__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Cost_Price__c.isUpdateable()){ WIIS.SerialNumber.ERP7__Cost_Price__c = (LOLIW_IN.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Unit__c > 0)? (LOLIW_IN.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c/LOLIW_IN.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Unit__c) : LOLIW_IN.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Cost_Card__r.ERP7__Cost__c; }
                                        WIIS.Stock.Id = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__c;
                                       if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Version__c.isUpdateable()) WIIS.Stock.Version__c = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__r.Version__c;
                                       if(Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.fields.ERP7__Warehouse__c.isUpdateable()) WIIS.SerialNumber.ERP7__Warehouse__c = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__r.Version__c;
                                    }
                                    Serials2Upsert.add(WIIS.SerialNumber);
                                }
                                if(WIIS.BatchNumber.Id != Null){    // && WIIS.BatchNumber.Id != ''
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.Name.isUpdateable()) WIIS.Stock.Name = WIIS.Stock.Name = LOLIW_IN.LOLI.Product__r.Name;//WIIS.SerialNumber.Serial_Number__c;
                                    WIIS.BatchNumber.ERP7__Active__c = true; WIIS.BatchNumber.ERP7__Product__c = LOLIW_IN.LOLI.Product__c;
                                    if(WIIS.Stock.Version__c != Null) WIIS.BatchNumber.ERP7__Production_Version__c = WIIS.Stock.Version__c;
                                    if(existingBatchesMap.containsKey(WIIS.BatchNumber.Id)) { WIIS.BatchNumber = existingBatchesMap.get(WIIS.BatchNumber.Id);
                                        if(existingBatchesMap.get(WIIS.BatchNumber.Id).ERP7__Production_Version__c != Null) WIIS.Stock.Version__c = existingBatchesMap.get(WIIS.BatchNumber.Id).ERP7__Production_Version__c;
                                       if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable())  WIIS.Stock.ERP7__Batch_Lot__c = WIIS.BatchNumber.Id;
                                        
                                    }
                                    Batches2Upsert.add(WIIS.BatchNumber);
                                }
                                Stocks2Upsert.add(WIIS.Stock);
                            }
                        }
                    }
                }
              
                List<String> SNs = new List<String>();
                for(ERP7__Serial_Number__c  SR : Serials2Upsert){
                    if(SR.Id == null) SNs.add(SR.ERP7__Serial_Number__c);
                }
                
                if(SNs.size() > 0){
                    List<ERP7__Serial_Number__c> dupSRs = [Select Id, Name, ERP7__Serial_Number__c From ERP7__Serial_Number__c Where ERP7__Serial_Number__c != Null And ERP7__Serial_Number__c In: SNs];
                    
                    if(dupSRs.size() > 0){
                        Error = true; ErrMsg = 'Duplicate serial numbers found : ';
                        for(ERP7__Serial_Number__c  SR : dupSRs){     if(ErrMsg == 'Duplicate serial numbers found : ') {ErrMsg = ErrMsg + SR.ERP7__Serial_Number__c;}  else ErrMsg = ErrMsg + ', ' + SR.ERP7__Serial_Number__c;
                        }
                    }
                }
                
                /*SNs = new List<String>();
                for(ERP7__Batch__c  SR : Batches2Upsert){
                    if(SR.Id == null) SNs.add(SR.Name);
                }
                if(SNs.size() > 0){
                    List<ERP7__Batch__c> dupSRs = [Select Id, Name From ERP7__Batch__c Where Name In: SNs];
                    '*** dupSRs : '+dupSRs);
                    if(dupSRs.size() > 0){
                        Error = true;
                        ErrMsg = 'Duplicate Batch numbers found : ';
                        for(ERP7__Batch__c  SR : dupSRs){
                            if(ErrMsg == 'Duplicate Batch numbers found : ') ErrMsg = ErrMsg + SR.Name;
                            else ErrMsg = ErrMsg + ', ' + SR.Name;
                        }
                    }
                }*/
                
                if(!Error){
                    system.debug('Successful Processing doing 2');
                    if(Serials2Upsert.size() > 0) {
                        if(Schema.sObjectType.ERP7__Serial_Number__c.isCreateable() && Schema.sObjectType.ERP7__Serial_Number__c.isUpdateable()){ system.debug('Serials2Upsert upserting : '+Serials2Upsert.size()); upsert Serials2Upsert; } else{ }
                    }
                    //if(Batches2Upsert.size() > 0) upsert Batches2Upsert;
                    
                    //****For assign Serial no. on Inventorty****
                    if(Stocks2Upsert.size() > 0){                        
                        if(Serials2Upsert.size() > 0){
                            Set<Id> proIds=new Set<Id>();
                            for(ERP7__Inventory_Stock__c inv:Stocks2Upsert) proIds.add(inv.ERP7__Product__c);                            
                            List<Product2> proList=[Select Id,Name,ERP7__Serialise__c from Product2 where Id In:proIds];
                            Map<String,Boolean> proSerialize=new Map<String,Boolean>();
                            for(Product2 pr:proList) proSerialize.put(pr.Id,pr.ERP7__Serialise__c);
                            Integer count=0;
                            for(Integer i=0;i<Stocks2Upsert.size();i++) {
                                if(proSerialize.get(Stocks2Upsert[i].ERP7__Product__c)){ 
                                    Stocks2Upsert[i].ERP7__Serial__c=Serials2Upsert[count].Id; count++; 
                                }                               
                            }
                        }                           
                    }
                    //****For assign Serial no. on Inventorty end****
                    
                    if(Stocks2Upsert.size() > 0) {
                        
                        //assign batch to stock//
                        for(LOLIWrapper LOLIW : LOLIWrapperList){
                            if(LOLIW.LOLI.Explode__c != true){
                                for(StockWrapper WIIS : LOLIW.StockWrapperList){
                                    if(WIIS.BatchNumber.Id != Null) if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()) WIIS.Stock.ERP7__Batch_Lot__c = WIIS.BatchNumber.Id;
                                }
                            }
                            else{
                                for(LOLIWrapper LOLIW_IN : LOLIW.BOMS){
                                    for(StockWrapper WIIS : LOLIW_IN.StockWrapperList){
                                        if(WIIS.BatchNumber.Id != Null) if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()) WIIS.Stock.ERP7__Batch_Lot__c = WIIS.BatchNumber.Id;
                                    }
                                }
                            }
                        }
                        //assign batch to stock//
                        
                        //***In case, with same batch Inventory exist for multiple same products***
                        Map<Id, Inventory_Stock__c> invMap = new Map<Id, Inventory_Stock__c>();
                        for(Inventory_Stock__c inv:stocks2upsert){ if(invMap.containskey(inv.Id)) inv.Id=null; else invMap.put(inv.Id,inv); }
                        //***In case, with same batch Inventory exist for multiple same products ends***
                        if(Schema.sObjectType.ERP7__Inventory_Stock__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.isUpdateable()) { system.debug('stocks2upsert upserting : '+stocks2upsert.size()); upsert stocks2upsert; } else{}
                    }
                    //if(stocks2Delete.size() > 0) delete stocks2Delete;
                    //if(SPLIS2Delete.size() > 0) delete SPLIS2Delete;
                    
                    //if(SerialNumbers2Delete.size() > 0) delete SerialNumbers2Delete;
                    
                    for(LOLIWrapper LOLIW : LOLIWrapperList){
                        if(LOLIW.LOLI.Explode__c != true){
                            Decimal subquant = 0;
                            for(StockWrapper WIIS : LOLIW.StockWrapperList){
                                if(WIIS.BatchNumber.Id != Null) if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()) WIIS.Stock.ERP7__Batch_Lot__c = WIIS.BatchNumber.Id;
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    
                                    if(SPL.Name == Null || SPL.Name == '') if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isUpdateable()) SPL.Name = LOLIW.LOLI.Product__r.Name;
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isUpdateable()) SPL.Active__c = true;
                                    if(SPL.ERP7__Fixed_Asset__c == Null && SPL.Product__c == Null && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isUpdateable() ) SPL.Product__c = LOLIW.LOLI.Product__c;
                                    
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) SPL.ERP7__Logistic_Line_Item__c = LOLIW.LOLI.Id;
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable()) SPL.ERP7__Logistic__c = LOLIW.LOLI.ERP7__Logistic__c;
                                    
                                    if(LOLIW.LOLI.ERP7__RMA_Line_Item__c != Null){
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA_Line_Item__c.isUpdateable()) SPL.ERP7__RMA_Line_Item__c = LOLIW.LOLI.ERP7__RMA_Line_Item__c;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA__c.isUpdateable()) SPL.ERP7__RMA__c = LOLIW.LOLI.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c;
                                    }
                                    else if(LOLIW.LOLI.ERP7__Purchase_Line_Items__c != Null){ 
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable()) SPL.ERP7__Purchase_Line_Items__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__c;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) SPL.Purchase_Orders__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__r.Purchase_Orders__c;
                                        if(LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Sales_Order_Line_Item__c != Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable()) SPL.ERP7__Sales_Order_Line_Item__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Sales_Order_Line_Item__c;          if(LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Order_Product__c != Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Order_Product__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Order_Product__c.isUpdateable()) SPL.ERP7__Order_Product__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Order_Product__c;
                                        if(LOLIW.LOLI.ERP7__Purchase_Line_Items__r.Sales_Order__c != Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Sales_Order__c.isUpdateable()) SPL.Sales_Order__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__r.Sales_Order__c;          if(LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Order__c != Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Order__c.isUpdateable()) SPL.ERP7__Order__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__r.ERP7__Order__c;
                                    }
                                    else if(LOLIW.LOLI.ERP7__Work_Order_Line_Items__c != Null){
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable()) SPL.ERP7__Work_Order_Line_Items__c = LOLIW.LOLI.ERP7__Work_Order_Line_Items__c;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Work_Order__c.isUpdateable()) SPL.Work_Order__c = LOLIW.LOLI.ERP7__Work_Order_Line_Items__r.Work_Orders__c;
                                    }
                                    else if(LOLIW.LOLI.ERP7__Transfer_Order_Line_Item__c != Null){
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable()) SPL.ERP7__Transfer_Order_Line_Item__c = LOLIW.LOLI.ERP7__Transfer_Order_Line_Item__c;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Transfer_Order__c.isUpdateable()) SPL.Transfer_Order__c = LOLIW.LOLI.ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c;
                                    }
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) SPL.ERP7__Material_Batch_Lot__c = (WIIS.BatchNumber.Id != Null)? WIIS.BatchNumber.Id : Null;
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Version__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Version__c.isUpdateable()) SPL.Version__c = (WIIS.Stock.Version__c != Null)? WIIS.Stock.Version__c : Null;
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isUpdateable()) SPL.Unit_Price__c = (LOLIW.LOLI.ERP7__Price_Product__c >= 0)? LOLIW.LOLI.ERP7__Price_Product__c : 0;
                                    if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                    if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Amount__c.isUpdateable()) SPL.Amount__c = SPL.Unit_Price__c * SPL.Quantity__c; 
                                    if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') {
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isUpdateable()) SPL.Serial__c = WIIS.SerialNumber.Id;
                                        if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()) SPL.Site_ProductService_InventoryStock__c = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__c;
                                    }
                                    SPLIS2Upsert.add(SPL);  
                                    subquant += SPL.Quantity__c;
                                }
                            }
                            LOLIW.lineItemprocessedQuantity = LOLIW.lineItemprocessedQuantity - LOLIW.Incount + subquant;
                            LOLIW.Incount = subquant;
                        } 
                        else{
                            for(LOLIWrapper LOLIW_IN : LOLIW.BOMS){
                                Decimal subquant = 0;
                                for(StockWrapper WIIS : LOLIW_IN.StockWrapperList){
                                    if(Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isCreateable() && Schema.sObjectType.ERP7__Inventory_Stock__c.fields.ERP7__Batch_Lot__c.isUpdateable()) WIIS.Stock.ERP7__Batch_Lot__c = (WIIS.BatchNumber.Id != Null)? WIIS.BatchNumber.Id : Null;
                                    for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                        if(SPL.Name == Null || SPL.Name == '') if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Name.isUpdateable()) SPL.Name = LOLIW_IN.MRP.ERP7__MRP_Product__r.Name;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Active__c.isUpdateable()) SPL.Active__c = true;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Product__c.isUpdateable()) SPL.Product__c = LOLIW_IN.MRP.ERP7__MRP_Product__c;
                                        
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic_Line_Item__c.isUpdateable()) SPL.ERP7__Logistic_Line_Item__c = LOLIW.LOLI.Id;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Logistic__c.isUpdateable()) SPL.ERP7__Logistic__c = LOLIW.LOLI.ERP7__Logistic__c;
                                        
                                        if(LOLIW.LOLI.ERP7__RMA_Line_Item__c != Null){
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA_Line_Item__c.isUpdateable()) SPL.ERP7__RMA_Line_Item__c = LOLIW.LOLI.ERP7__RMA_Line_Item__c;
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__RMA__c.isUpdateable()) SPL.ERP7__RMA__c = LOLIW.LOLI.ERP7__RMA_Line_Item__r.ERP7__Return_Merchandise_Authorisation__c;
                                        }
                                        else if(LOLIW.LOLI.ERP7__Purchase_Line_Items__c != Null){ 
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable()) SPL.ERP7__Purchase_Line_Items__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__c;
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Purchase_Orders__c.isUpdateable()) SPL.Purchase_Orders__c = LOLIW.LOLI.ERP7__Purchase_Line_Items__r.Purchase_Orders__c;
                                        }
                                        else if(LOLIW.LOLI.ERP7__Work_Order_Line_Items__c != Null){
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Work_Order_Line_Items__c.isUpdateable()) SPL.ERP7__Work_Order_Line_Items__c = LOLIW.LOLI.ERP7__Work_Order_Line_Items__c;
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Work_Order__c.isUpdateable()) SPL.Work_Order__c = LOLIW.LOLI.ERP7__Work_Order_Line_Items__r.Work_Orders__c;
                                        }
                                        else if(LOLIW.LOLI.ERP7__Transfer_Order_Line_Item__c != Null){
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Transfer_Order_Line_Item__c.isUpdateable()) SPL.ERP7__Transfer_Order_Line_Item__c = LOLIW.LOLI.ERP7__Transfer_Order_Line_Item__c;
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Transfer_Order__c.isUpdateable()) SPL.Transfer_Order__c = LOLIW.LOLI.ERP7__Transfer_Order_Line_Item__r.Transfer_Order__c;
                                        }
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.ERP7__Material_Batch_Lot__c.isUpdateable()) SPL.ERP7__Material_Batch_Lot__c = (WIIS.BatchNumber.Id != Null)? WIIS.BatchNumber.Id : Null;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Version__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Version__c.isUpdateable()) SPL.Version__c = (WIIS.Stock.Version__c != Null)? WIIS.Stock.Version__c : Null;
                                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Unit_Price__c.isUpdateable()) SPL.Unit_Price__c = (LOLIW.LOLI.ERP7__Price_Product__c >= 0)? LOLIW.LOLI.ERP7__Price_Product__c : 0;
                                        if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()) SPL.Site_ProductService_InventoryStock__c =  WIIS.Stock.Id;
                                        if(WIIS.SerialNumber.Serial_Number__c != Null && WIIS.SerialNumber.Serial_Number__c != '') {
                                            if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Serial__c.isUpdateable())  SPL.Serial__c = WIIS.SerialNumber.Id;
                                            if(SPL.Site_ProductService_InventoryStock__c == Null) if(Schema.sObjectType.Stock_Inward_Line_Item__c.fields.Site_ProductService_InventoryStock__c.isCreateable()) SPL.Site_ProductService_InventoryStock__c = SerialRec.get(WIIS.SerialNumber.Serial_Number__c).ERP7__Site_ProductService_InventoryStock__c;
                                        }
                                        SPLIS2Upsert.add(SPL);  
                                        subquant += SPL.Quantity__c;
                                    }
                                }
                                LOLIW_IN.lineItemprocessedQuantity = LOLIW_IN.lineItemprocessedQuantity - LOLIW_IN.Incount + subquant;
                                LOLIW_IN.Incount = subquant;
                            }
                        }
                    }
                    
                    for(ERP7__Stock_Inward_Line_Item__c sil : SPLIS2Upsert){
                        if(sil.ERP7__Logistic_Line_Item__c != null) {
                            decimal totalqty = 0;
                            if(sil.ERP7__Quantity__c == null) sil.ERP7__Quantity__c = 0;
                            if(totalPutawayQTY.containsKey(sil.ERP7__Logistic_Line_Item__c)) {
                                system.debug('totalqty if : '+totalPutawayQTY.get(sil.ERP7__Logistic_Line_Item__c));
                                totalqty = totalPutawayQTY.get(sil.ERP7__Logistic_Line_Item__c) + sil.ERP7__Quantity__c;
                                totalPutawayQTY.put(sil.ERP7__Logistic_Line_Item__c,totalqty);
                            }
                            else totalPutawayQTY.put(sil.ERP7__Logistic_Line_Item__c,sil.ERP7__Quantity__c);
                            system.debug('totalPutawayQTY : '+totalPutawayQTY);
                        }
                    }
                    
                    if(PLIS2Upsert.size() > 0){
                        for(ERP7__Logistic_Line_Item__c loli : PLIS2Upsert){
                            if(totalPutawayQTY.containsKey(loli.Id)){
                                system.debug('totalPutawayQTY.get(loli.Id) : '+totalPutawayQTY.get(loli.Id));
                                if(loli.ERP7__Putaway_Quantity__c == null) loli.ERP7__Putaway_Quantity__c =0;
                                loli.ERP7__Putaway_Quantity__c = loli.ERP7__Putaway_Quantity__c + totalPutawayQTY.get(loli.Id);
                                system.debug('loli.ERP7__Putaway_Quantity__c : '+loli.ERP7__Putaway_Quantity__c);
                            }
                        }
                        if(Logistic_Line_Item__c.sObjectType.getDescribe().isCreateable() && Logistic_Line_Item__c.sObjectType.getDescribe().isUpdateable()){
                            system.debug('PLIS2Upsert upserting : '+PLIS2Upsert.size()); upsert PLIS2Upsert; 
                        } else{ }  
                    } 
                    
                    if(SPLIS2Upsert.size() > 0){ 
                        if(Schema.sObjectType.Stock_Inward_Line_Item__c.isCreateable() && Schema.sObjectType.Stock_Inward_Line_Item__c.isUpdateable()) { system.debug('SPLIS2Upsert upserting : '+SPLIS2Upsert.size()); upsert SPLIS2Upsert; } else {} 
                    }
                }
            }
            comW.exceptionError = ErrMsg; 
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) {
            Database.RollBack(sp);
            system.debug(e.getMessage() +' Line Number @ : '+ e.getLineNumber()+'  strace Trace:'+e.getStackTraceString());
            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber()+'  strace Trace:'+e.getStackTraceString(); 
        }
        return comW;
    }

    @AuraEnabled
    public static createBatchWrapper createBatch(String newBatch1){
        ERP7__Batch__c newBatch = (ERP7__Batch__c) JSON.deserialize(newBatch1,ERP7__Batch__c.class);
        createBatchWrapper batchWr=new createBatchWrapper();
        try {
            if(newBatch.ERP7__Shelf_Life_Expiration_Date__c != null && newBatch.ERP7__Shelf_Life_Expiration_Date__c < System.today()){batchWr.exError='Please select today or future date';return batchWr;}
            List<ERP7__Batch__c> batchList=[Select Id,Name,ERP7__Expired__c from ERP7__Batch__c where Name=:newBatch.Name AND ERP7__Product__c=:newBatch.ERP7__Product__c];
            if(batchList.size() > 0){
                if(batchList[0].ERP7__Expired__c) batchWr.exError='Expired batch already available for this product with name : '+newBatch.Name; else batchWr.exError='Batch already available for this product with name : '+newBatch.Name;
            }else{
                if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Active__c.isUpdateable()) newBatch.ERP7__Active__c=true;
                if(Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Barcode_Type__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.fields.ERP7__Barcode_Type__c.isUpdateable()) newBatch.ERP7__Barcode_Type__c='Code128';                
                if(Schema.sObjectType.ERP7__Batch__c.isCreateable() && Schema.sObjectType.ERP7__Batch__c.isUpdateable()) { upsert newBatch; }  else{ }
                batchWr.batch=newBatch;
            }            
            
        } catch (Exception e) { batchWr.exError='Error Message:'+e.getMessage()+'   Line Number:'+e.getLineNumber();
        }
        return batchWr;
    }

    public class createBatchWrapper{
        @AuraEnabled public ERP7__Batch__c batch        { get; set; }
        @AuraEnabled public String exError              { get; set; }
        public createBatchWrapper(){
            batch=new ERP7__Batch__c();
            exError='';
        }
    }
    
    public class orderWrapper{
        @AuraEnabled public String OrderId        { get; set; }
        @AuraEnabled public String OrderName      { get; set; }
        public orderWrapper(){
            OrderId = OrderName = '';
        }
    }
    
    @AuraEnabled
    public static comWrap ScannerMethod(String LWL, String barcode, Integer counter){     
        system.debug('ScannerMethod called');
        comWrap comW = new comWrap();
        try {
            List<LOLIWrapper> LOLIWrapperList = (List<LOLIWrapper>) JSON.deserialize(LWL, List<LOLIWrapper> .class);
            String ErrMsg = '';
            String DisMsg = '';
            boolean found = false;
            boolean itemFoundOnScan = false;
            /*'*** counter : '+counter);*/
            if(counter >= 0){
                StockWrapper randonScannedStock = LOLIWrapperList[counter].StockWrapperList[0];
                if(randonScannedStock != Null){
                    List<Site__c> siteList = [Select Id, Name, Barcode__c from Site__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
                    List<Location__c> SSLList = [Select Id, Name, Barcode__c, Site__c from Location__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];
                    system.debug('SSLList : '+SSLList.size());
                    List<StorageContainer__c> binList = [Select Id, Name, Barcode__c, Site__c, Location__c from StorageContainer__c where Barcode__c =:barcode.trim() and Active__c = true limit 1];   
                    List<ERP7__Batch__c> batchprod = [Select Id,Name,ERP7__Product__c,ERP7__Expired__c from ERP7__Batch__c where Barcode__c =:barcode.trim() Limit 1];
                    system.debug('batchprod : '+batchprod);
                    if(binList.size() > 0) { 
                        randonScannedStock.Stock.StorageContainer__c = binList[0].Id;
                        randonScannedStock.Stock.Location__c = binList[0].Location__c;
                        randonScannedStock.Stock.Warehouse__c = binList[0].Site__c;
                        randonScannedStock.SP.Site__c = binList[0].Site__c;
                       
                        /* *** randonScannedStock.Stock : '+randonScannedStock.Stock);*/
                    }
                    else if(SSLList.size() > 0){   randonScannedStock.Stock.Location__c = SSLList[0].Id;  randonScannedStock.Stock.Warehouse__c = SSLList[0].Site__c;  randonScannedStock.SP.Site__c = SSLList[0].Site__c;}
                    else if(siteList.size() > 0){   randonScannedStock.Stock.Warehouse__c = siteList[0].Id;   randonScannedStock.SP.Site__c = siteList[0].Id; }
                    DisMsg = '';
                    if(binList.size() > 0 || SSLList.size() > 0 || siteList.size() > 0) {
                        found = true;
                        LOLIWrapperList[counter].StockWrapperList[0] = randonScannedStock;
                    }
                    if(batchprod.size() > 0){randonScannedStock.BatchNumber =  batchprod[0];}
                }
            }
            if(!found){
                system.debug('in not found counter~>'+counter);
                List<Product2> productList = [select id, name, Barcode__c,ERP7__Serialise__c,ERP7__Lot_Tracked__c from Product2 where Barcode__c =: barcode.trim() Limit 1];
                List<ERP7__Batch__c> batchprod = [Select Id,Name,ERP7__Product__c,ERP7__Expired__c from ERP7__Batch__c where Barcode__c =:barcode.trim() Limit 1];
                if(productList.size() > 0) {
                    //addQuantityScanner(productList[0]); 
                    String productId = productList[0].Id;
                    Boolean iserial = productList[0].ERP7__Serialise__c;
                    Boolean isbatch = productList[0].ERP7__Lot_Tracked__c;
                    system.debug('iserial : '+iserial);
                    Boolean Error = false;
                    ErrMsg = '';
                    Boolean exist = false;
                    counter = -1;
                    
                    for(Integer i=0; i<LOLIWrapperList.size(); i++){
                        LOLIWrapper LOLIW = LOLIWrapperList[i];
                        if(LOLIW.LOLI.Product__c == productId) barcode = '#'+productId;
                        
                        if(LOLIW.LOLI.Product__c == productId && LOLIW.LOLI.Quantity_Received__c > 0 && LOLIW.LOLI.Quantity__c > 0 && LOLIW.LOLI.Quantity_Received__c <= LOLIW.LOLI.Quantity__c && LOLIW.lineItemprocessedQuantity < LOLIW.LOLI.Quantity_Received__c){
                            Decimal subQuantity = 0; 
                            for(StockWrapper WIIS : LOLIW.StockWrapperList){
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c != Null) subQuantity += SPL.Quantity__c;
                                }
                            }
                            
                            if((LOLIW.lineItemprocessedQuantity - LOLIW.Incount + subQuantity) > LOLIW.LOLI.Quantity_Received__c){    Error = true; LOLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(LOLIW.LOLI.Quantity_Received__c - (LOLIW.lineItemprocessedQuantity - LOLIW.Incount));  }
                            
                            if(!Error){
                                if(!(LOLIW.StockWrapperList.size() > 0)){
                                    StockWrapper SW = new StockWrapper(new Inventory_Stock__c(Active__c = true, Product__c = LOLIW.LOLI.Product__c, Name=LOLIW.LOLI.Name,Checked_In_Date__c=system.today()), new List<Stock_Inward_Line_Item__c>()); LOLIW.StockWrapperList.add(SW);
                                }
                                if(!(LOLIW.StockWrapperList[0].SPLI.size() > 0)) LOLIW.StockWrapperList[0].SPLI.add(new Stock_Inward_Line_Item__c());
                                Stock_Inward_Line_Item__c SPL = LOLIW.StockWrapperList[0].SPLI[0];
                                if(iserial) SPL.Quantity__c =(LOLIW.LOLI.Quantity_Received__c != Null)? 1 : 0;
                                else SPL.Quantity__c = (LOLIW.LOLI.Quantity_Received__c != Null)? LOLIW.LOLI.Quantity_Received__c : 0;
                                LOLIW.lineItemprocessedQuantity = SPL.Quantity__c;
                                LOLIW.Incount = LOLIW.lineItemprocessedQuantity;
                            }
                            counter = i;
                            if(isbatch) DisMsg = 'Product "'+LOLIW.LOLI.Product__r.Name+'" found please scan the batch or create a new';
                            else DisMsg = 'Product "'+LOLIW.LOLI.Product__r.Name+'" found please scan the location';
                            exist = true;
                            barcode = '#'+LOLIW.LOLI.Id;
                            itemFoundOnScan = true;
                            break;
                        }
                    }
                    if(Error) ErrMsg = 'Please verify the errors below';
                    if(!exist) { ErrMsg = 'Product not found or its already added to the inventory'; DisMsg = '';}
                }
                else if(batchprod.size() > 0){
                    system.debug('batchprod ');
                     String productId = batchprod[0].ERP7__Product__c;
                   if(batchprod[0].ERP7__Expired__c) ErrMsg = 'Scanned Batch is Expired';
                    else{
                      Boolean Error = false;
                    ErrMsg = '';
                    Boolean exist = false;
                    counter = -1;
                    
                    for(Integer i=0; i<LOLIWrapperList.size(); i++){
                        LOLIWrapper LOLIW = LOLIWrapperList[i];
                        if(LOLIW.LOLI.Product__c == productId) barcode = '#'+productId;
                        
                         system.debug(' 1'+LOLIW.LOLI.Product__c);
                        system.debug(' 2'+ productId);
                         system.debug(' 3'+LOLIW.LOLI.Quantity_Received__c);
                         system.debug(' 4'+LOLIW.LOLI.Quantity__c);
                         system.debug(' 5'+LOLIW.lineItemprocessedQuantity);
                        
                        if(LOLIW.LOLI.Product__c == productId && LOLIW.LOLI.Quantity_Received__c > 0 && LOLIW.LOLI.Quantity__c > 0 && LOLIW.LOLI.Quantity_Received__c <= LOLIW.LOLI.Quantity__c && LOLIW.lineItemprocessedQuantity <= LOLIW.LOLI.Quantity_Received__c){
                            system.debug('inside if');
                            Decimal subQuantity = 0; 
                            for(StockWrapper WIIS : LOLIW.StockWrapperList){
                                for(Stock_Inward_Line_Item__c SPL : WIIS.SPLI){
                                    if(Schema.sobjectType.Stock_Inward_Line_Item__c.fields.Quantity__c.isAccessible()) if(SPL.Quantity__c != Null) subQuantity += SPL.Quantity__c;
                                }
                            }
                            
                            if((LOLIW.lineItemprocessedQuantity - LOLIW.Incount + subQuantity) > LOLIW.LOLI.Quantity_Received__c){    Error = true; LOLIW.errMsg = 'Sum of Quantities that you can add to this Stocks should be less than or equal to '+String.valueof(LOLIW.LOLI.Quantity_Received__c - (LOLIW.lineItemprocessedQuantity - LOLIW.Incount));  }
                            system.debug('Error : '+Error);
                            if(!Error){
                                if(!(LOLIW.StockWrapperList.size() > 0)){
                                    StockWrapper SW = new StockWrapper(new Inventory_Stock__c(ERP7__Batch_Lot__c=batchprod[0].Id,Active__c = true, Product__c = LOLIW.LOLI.Product__c, Name=LOLIW.LOLI.Name,Checked_In_Date__c=system.today()), new List<Stock_Inward_Line_Item__c>()); LOLIW.StockWrapperList.add(SW);
                                }
                                system.debug('LOLIW.StockWrapperList[0].SPLI.size() : '+LOLIW.StockWrapperList[0].SPLI.size());
                                if(!(LOLIW.StockWrapperList[0].SPLI.size() > 0)){
                                    LOLIW.StockWrapperList[0].SPLI.add(new Stock_Inward_Line_Item__c());
                                } 
                                Stock_Inward_Line_Item__c SPL = LOLIW.StockWrapperList[0].SPLI[0];
                                SPL.Quantity__c = (LOLIW.LOLI.Quantity_Received__c != Null)? LOLIW.LOLI.Quantity_Received__c : 0;
                                SPL.ERP7__Material_Batch_Lot__c = batchprod[0].Id;
                                system.debug('SPL.ERP7__Material_Batch_Lot__c : '+SPL.ERP7__Material_Batch_Lot__c);
                                LOLIW.lineItemprocessedQuantity = SPL.Quantity__c;
                                LOLIW.Incount = LOLIW.lineItemprocessedQuantity;
                                LOLIW.StockWrapperList[0].BatchNumber = batchprod[0];
                            }
                            counter = i;
                            DisMsg = 'The Batch for"'+LOLIW.LOLI.Product__r.Name+'" is found please scan the location';
                            exist = true;
                            barcode = '#'+LOLIW.LOLI.Id;
                            itemFoundOnScan = true;
                            break;
                        }   else{
                            system.debug('inside else');
                        }
                    }
                        if(Error) ErrMsg = 'Please verify the errors below';
                    if(!exist) { ErrMsg = 'Batch not found'; DisMsg = '';}
                }
                }
                else ErrMsg = 'Product not found';
            }
            comW.exceptionError = ErrMsg;
            comW.itemFoundOnScan = itemFoundOnScan;
            comW.counter = counter;
            comW.DisMsg = DisMsg;
            comW.LOLIWrapperList = LOLIWrapperList;
        } catch(Exception e) {
            system.debug('exceptionError '+e.getMessage());
            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();  
        }
        
        return comW;
    }
    
    public class comWrap {
        @AuraEnabled public Attachment universalAttachment                                          { get; set; }
        @AuraEnabled public ERP7__Google_Drive__c uniGdrive                                          { get; set; }
        @AuraEnabled public ContentVersion uniContentVersion                                         { get; set; }
        @AuraEnabled public String PreparePushAttachmentId                                          { get; set; } 
        @AuraEnabled public Employees__c Employee                                                   { get; set; }
        @AuraEnabled public List<SelectOptions> channelSites                                        { get; set; }
        @AuraEnabled public String ChannelName                                                      { get; set; } 
        @AuraEnabled public String ChannelId                                                        { get; set; } 
        @AuraEnabled public String SiteName                                                         { get; set; } 
        @AuraEnabled public String selectedSite                                                     { get; set; }
        @AuraEnabled public List<LogisticWrapper> LogisticWrapperList                               { get; set; }
        @AuraEnabled public String barcode                                                          { get; set; } 
        @AuraEnabled public Boolean initialScan                                                     { get; set; } 
        @AuraEnabled public String exceptionError                                                   { get; set; }
        @AuraEnabled public Boolean DriveFile                                                     { get; set; }
        @AuraEnabled public Boolean SalesFile                                                     { get; set; }
        @AuraEnabled public List<LOLIWrapper> LOLIWrapperList                                       { get; set; }
        @AuraEnabled public Boolean itemFoundOnScan                                                 { get; set; }
        @AuraEnabled public Integer counter                                                         { get; set; }
        @AuraEnabled public String DisMsg                                                           { get; set; } 
        @AuraEnabled public boolean showReceiveAtt                                                  { get; set; } 
        @AuraEnabled public boolean putawayLocationReq                                              { get; set; }
        
        @AuraEnabled public List<ERP7__MRP__c> MRPS                                                 { get; set; }
        @AuraEnabled public List<Stock_Inward_Line_Item__c> SPLIS                                   { get; set; }
        @AuraEnabled public List<Inventory_Stock__c> warehouseStocks                                { get; set; }
        @AuraEnabled public Map<Id, List<Stock_Inward_Line_Item__c>> stockLines                     { get; set; }
        @AuraEnabled public Map<Id,Serial_Number__c> SerialMap                                      { get; set; }
        @AuraEnabled public Boolean Putaway                                                         { get; set; }
        
        @AuraEnabled public List<Integer> PNS                                                       { get; set; }
        @AuraEnabled public Integer startCount                                                      { get; set; }
        @AuraEnabled public Integer endCount                                                        { get; set; }
        @AuraEnabled public Integer Offset                                                          { get; set; }
        @AuraEnabled public Integer recSize                                                         { get; set; }
        @AuraEnabled public Integer PageNum                                                         { get; set; }
        @AuraEnabled public Integer show                                                            { get; set; }
        // @AuraEnabled public Boolean showbinn                                                      { get; set; }
        public comWrap() {
            universalAttachment = new Attachment();
            uniGdrive = new ERP7__Google_Drive__c();
            uniContentVersion = new ContentVersion();
            PreparePushAttachmentId = selectedSite = barcode = exceptionError = ChannelName = ChannelId = SiteName = DisMsg = '';
            Employee = new Employees__c();
            channelSites = new List<SelectOptions>();
            LogisticWrapperList = new List<LogisticWrapper>();
            LOLIWrapperList = new List<LOLIWrapper>();
            initialScan = Putaway = itemFoundOnScan = putawayLocationReq=SalesFile=DriveFile=false;
            showReceiveAtt=true;
           
            MRPS = new List<ERP7__MRP__c>();
            SPLIS = new List<Stock_Inward_Line_Item__c>();
            warehouseStocks = new List<Inventory_Stock__c>();
            stockLines = new Map<Id, List<Stock_Inward_Line_Item__c>>();
            SerialMap = new Map<Id,Serial_Number__c>();
            
            PNS = new List<Integer>();
            show = 25;
            startCount = endCount = Offset = recSize = PageNum = 0;
            
            counter = -1;
        }
    }
    
    public class LogisticWrapper{
        @AuraEnabled public Logistic__c Logistic                  { get; set; }
        @AuraEnabled public Attachment Attach                     { get; set; }
        @AuraEnabled public ERP7__Google_Drive__c GDrive                     { get; set; }
        @AuraEnabled public ContentVersion conAttach					{ get; set; }
        @AuraEnabled public Boolean isSelected                    { get; set; }
        @AuraEnabled public Boolean isSales                    { get; set; }
        @AuraEnabled public Boolean isGDrive                    { get; set; }
        @AuraEnabled public Boolean showUpload                    { get; set; }
        @AuraEnabled public List<orderWrapper> orderWrapperList   { get; set; }
        
        public LogisticWrapper() {
            Logistic = new Logistic__c();
            Attach = new Attachment();
            conAttach = new ContentVersion();
            GDrive = new ERP7__Google_Drive__c();
            isSelected = isGDrive = isSales = showUpload = false;
            orderWrapperList = new List<orderWrapper>();
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
            //selected = false;
        }
        public SelectOptions(String val, string lab, Boolean sel) {
            value = val;
            label = lab;
            selected = sel;
        }
    }
}