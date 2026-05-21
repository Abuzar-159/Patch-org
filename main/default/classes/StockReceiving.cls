public with sharing class StockReceiving {
    
    public PO__c newPO                                 { get; set; }
    public WO__c newWO                                 { get; set; } 
    public String srcStr                               { get; set; }
    public List<PO__c> POS                             { get; set; }
    public List<WO__c> WOS                             { get; set; }
    public Integer nextIdent                           { get; set; }    
    public Requisition__c newPR                        { get; set; }
    public static Integer addRow                       { get; set; }    
    public String selectedSection                      { get; set; }
    public static Integer toDelIdent                   { get; set; }
    public List<Transfer_Order__c> TOS                 { get; set; }
    public List<Transfer_Order__c> TOScan              { get; set; }
    public List<Sales_Order__c> salesOrders            { get; set; }
    public String barcode                              { get; set; } 
    public List<PO__c> TPO                             { get; set; }
    public List<WO__c> TWO                             { get; set; }
    public List<RMA_Line_Item__c> TsalesOrder          { get; set; }
    public Boolean selectAll                           { get; set; }
    public Boolean initialScan                         { get; set; }  
    public Employees__c Employee                       { get; set; }
    public Attachment universalAttachment              { get; set; }
    public Id PreparePushAttachmentId                  { get; set; } 
    Public Map<Id,Product2> Product2Map                { get; set; }
    public List<SelectOption> channelSites                             { get; set; }
    public Id selectedSite                                             { get; set; }
    //***************mna*************************
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    //***************mna*************************
    public static Map<String, Schema.SObjectType> schemaMap;
    
    public StockReceiving() {
        try {
            srcStr = '';
            nextIdent = 0;  
            newPO = new PO__c();
            newWO = new WO__c();
            selectedSection = 'PO';
            newPR = new Requisition__c();  
            poliWrapperList = new List<newWrapper>();
            woliWrapperList = new List<newWrapper>();
            prliWrapperList = new List<newWrapper>();
            Employee = new Employees__c();
            
            List<Employees__c> empList = new List<Employees__c>();
            empList = [Select Id, Name, First_Name__c, Channel__c, Channel__r.Name, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                         Organisation_Business_Unit__c
                         From Employees__c
                         Where Employee_User__c = : UserInfo.getUserId()
                         Order by CreatedDate Asc Limit 1];
            
            if(empList.size() > 0) { 
                Employee = empList[0]; 
                if(Employee.Channel__c != Null){ 
                    List< ERP7__Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c, ERP7__Primary__c,   Channel__c, Site__c, Site__r.Name
                                                                                    From Distribution_Channel__c
                                                                                    Where Channel__c = : Employee.Channel__c And Active__c = true
                                                                                    Order By ERP7__Primary__c Desc];
                
                    channelSites = new List<SelectOption>();        
                    if(DistributionChannels.size() > 0) {
                        for(Distribution_Channel__c DC: DistributionChannels) {
                            channelSites.add(new SelectOption(DC.Site__c,DC.Name));
                        }
                        selectedSite = DistributionChannels[0].Site__c;
                    } 
                } 
            }     
            StockReceivingCustom();
            //SearchWOS();
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    }
    
    public PageReference StockReceivingCustom() {
        try {
            schemaMap = Schema.getGlobalDescribe();
            selectAll = false;
            initialScan = true;
            universalAttachment = new Attachment();
            String allFields = fetchAllFields('ERP7__PO__c');
            UtilClass.FlSCheck(allFields.split(',') ,'ERP7__PO__c');
            allFields += ', Vendor__r.name';
                                
            String tempPOChannel = Employee.Channel__c;
            String query = 'select ' + allFields + ' from ERP7__PO__c where Active__c = true And Channel__c =: tempPOChannel And Is_Closed__c = false AND Ready_To_Receive__c = True Order by Expected_Date__c ASC';
            if(Schema.sObjectType.ERP7__PO__c.isAccessible()){
            POS = Database.query(query);}
            
            List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :POS Order By CreatedDate ASC];
            Map<Id,Attachment> POAttachment = new Map<Id,Attachment>();
            for(Attachment A : Attachments) POAttachment.put(A.ParentId,A);
            
            POWrapperList = new List<POWrapper>();
            for(ERP7__PO__c s : POS){ POWrapper p = new POWrapper(); p.PO = s; p.Attach = (POAttachment.ContainsKey(s.Id))? POAttachment.get(s.Id) : new Attachment(); p.isSelected = false; POWrapperList.add(p); }
            
            
            /*
            String status = 'Complete';
            String allFieldss = fetchAllFields('ERP7__WO__c');
            UtilClass.FlSCheck(allFieldss.split(',') ,'ERP7__WO__c');
            allFieldss += ', Project__r.name';
            String querys = 'select ' + allFieldss + ' from ERP7__WO__c where Active__c = true and Status__c = :status';
            if(Schema.sObjectType.ERP7__WO__c.isAccessible()){
            WOS = Database.query(querys);}
           
            List<RMA_Line_Item__c> RMALines;
            if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) {
            RMALines = [Select Id, Name, ERP7__Active__c, ERP7__Return_Status__c, ERP7__SOLI__c, ERP7__SOLI__r.Sales_Order__c 
                        From RMA_Line_Item__c Where ERP7__Active__c = true and ERP7__Return_Status__c = 'Quality Check' and Added_Back_to_Inventory__c != true ];}
            Set<Id> soIds = new Set<Id>();
            for(RMA_Line_Item__c RLI : RMALines){ if(RLI.ERP7__SOLI__r.Sales_Order__c != Null) if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isAccessible() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible() && Schema.sObjectType.RMA_Line_Item__c.isAccessible() && Schema.sObjectType.RMA_Line_Item__c.fields.ERP7__SOLI__c.isAccessible()) soIds.add(RLI.ERP7__SOLI__r.Sales_Order__c); }
            
            String allFieldsSo = fetchAllFields('ERP7__Sales_Order__c');
            UtilClass.FlSCheck(allFieldsSo.split(',') ,'ERP7__Sales_Order__c');
            allFieldsSo += ', Account__r.Name, Contact__r.Name';
            String querySo = 'select ' + allFieldsSo + ' from ERP7__Sales_Order__c where Id In :soIds';
            if(Schema.sObjectType.ERP7__Sales_Order__c.isAccessible()){
            salesOrders = Database.query(querySo);}
            
            String Approved = 'Approved';
            String allFieldsTO = fetchAllFields('ERP7__Transfer_Order__c');
            UtilClass.FlSCheck(allFieldsTO.split(',') ,'ERP7__Transfer_Order__c');
            String queryTO = 'select ' + allFieldsTO + ' from ERP7__Transfer_Order__c where Active__c = true and Status__c = :Approved';
            if(Schema.sObjectType.ERP7__Transfer_Order__c.isAccessible()){
            TOS = Database.query(queryTO);}
            
            
            
            WOWrapperList = new List<WOWrapper>();
            for(ERP7__WO__c s : WOS){ WOWrapper p = new WOWrapper(); p.WO = s; p.isSelected = false; WOWrapperList.add(p); }
            
            SOWrapperList = new List<SOWrapper>();
            for(ERP7__Sales_Order__c s : salesOrders){ SOWrapper p = new SOWrapper(); p.SO = s; p.isSelected = false; SOWrapperList.add(p); }
            
            TOWrapperList = new List<TOWrapper>();
            for(Transfer_Order__c s : TOS){ TOWrapper p = new TOWrapper(); p.TO = s; p.isSelected = false; TOWrapperList.add(p); }
            */
            /*Need to Revise the following SOQL Query */
            //String allFieldsProduct2 = UtilClass.selectStarFromSObject('Product2');
            //String queryProduct = 'select ' + allFieldsProduct2 + ' from Product2 Where IsActive = true';
            //Product2Map = new Map<Id,Product2>((List<Product2>)Database.query(queryProduct)); 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference SearchPOS() {
        try {
            selectAll = false;
            initialScan = true;
            schemaMap = Schema.getGlobalDescribe();
            String searchString = '%'+srcStr+'%';
            String allFields = fetchAllFields('ERP7__PO__c');
            UtilClass.FlSCheck(allFields.split(',') ,'ERP7__PO__c');
            allFields += ', Vendor__r.name';
            String tempPOChannel = Employee.Channel__c;
            String query = 'select ' + allFields + ' from ERP7__PO__c where Active__c = true and Is_Closed__c = false and Channel__c =: tempPOChannel and (Name like :searchString or Vendor__r.name like :searchString) AND Ready_To_Receive__c = True Order by Expected_Date__c ASC';
            if(Schema.sObjectType.ERP7__PO__c.isAccessible()){
            POS = Database.query(query);}
            POWrapperList = new List<POWrapper>();
            
            List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :POS Order By CreatedDate Asc];
            Map<Id,Attachment> POAttachment = new Map<Id,Attachment>();
            for(Attachment A : Attachments) POAttachment.put(A.ParentId,A);
            
            POWrapperList = new List<POWrapper>();
            for(ERP7__PO__c s : POS){ POWrapper p = new POWrapper(); p.PO = s; p.Attach = (POAttachment.ContainsKey(s.Id))? POAttachment.get(s.Id) : new Attachment(); p.isSelected = false; POWrapperList.add(p); }
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference SearchWOS() {
        try {
            selectAll = false;
            initialScan = true;
            schemaMap = Schema.getGlobalDescribe();
            String status = 'Complete';
            String searchString = '%'+srcStr+'%';
            String allFieldss = fetchAllFields('ERP7__WO__c');
            UtilClass.FlSCheck(allFieldss.split(',') ,'ERP7__WO__c');
            allFieldss += ', Project__r.name';
            String querys = 'select ' + allFieldss + ' from ERP7__WO__c where Active__c = true and Is_Closed__c = false and (Name like :searchString) AND Ready_To_Receive__c = True Order by Expected_Date__c ASC';
            if(Schema.sObjectType.ERP7__WO__c.isAccessible()){
            WOS = Database.query(querys);}
            
            List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :WOS Order By CreatedDate Asc];
            Map<Id,Attachment> WOAttachment = new Map<Id,Attachment>();
            for(Attachment A : Attachments) WOAttachment.put(A.ParentId,A);
            
            WOWrapperList = new List<WOWrapper>();
            for(ERP7__WO__c s : WOS){  WOWrapper p = new WOWrapper(); p.WO = s; p.Attach = (WOAttachment.ContainsKey(s.Id))? WOAttachment.get(s.Id) : new Attachment(); p.isSelected = false; WOWrapperList.add(p); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }   
        return Null;
    }
    
    public PageReference SearchSOS() {
        try {
            selectAll = false;
            initialScan = true;
            String resell = 'Re-sell';
            schemaMap = Schema.getGlobalDescribe();
            String searchString = '%'+srcStr+'%';
            
            List<RMA_Line_Item__c> RMALines;
            if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) {
            RMALines = [Select Id, Name, ERP7__Active__c, ERP7__Return_Status__c, ERP7__SOLI__c, ERP7__SOLI__r.Sales_Order__c 
                        From RMA_Line_Item__c Where ERP7__Active__c = true and ERP7__Return_Status__c = 'Quality Check' and Added_Back_to_Inventory__c != true ];}
            Set<Id> soIds = new Set<Id>();
            for(RMA_Line_Item__c RLI : RMALines){ if(RLI.ERP7__SOLI__r.Sales_Order__c != Null) soIds.add(RLI.ERP7__SOLI__r.Sales_Order__c); }
            String allFieldsSo = fetchAllFields('ERP7__Sales_Order__c');
            UtilClass.FlSCheck(allFieldsSo.split(',') ,'ERP7__Sales_Order__c');
            allFieldsSo += ', Account__r.Name, Contact__r.Name';
            String querySo = 'select ' + allFieldsSo + ' from ERP7__Sales_Order__c where Id In :soIds and (Name like :searchString)';
            if(Schema.sObjectType.ERP7__Sales_Order__c.isAccessible()){
            salesOrders = Database.query(querySo);}
            
            List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :salesOrders Order By CreatedDate Asc];
            Map<Id,Attachment> SOAttachment = new Map<Id,Attachment>();
            for(Attachment A : Attachments) SOAttachment.put(A.ParentId,A);
            
            SOWrapperList = new List<SOWrapper>();
            for(ERP7__Sales_Order__c s : salesOrders){  SOWrapper p = new SOWrapper(); p.SO = s; p.Attach = (SOAttachment.ContainsKey(s.Id))? SOAttachment.get(s.Id) : new Attachment(); p.isSelected = false; SOWrapperList.add(p); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public PageReference SearchTOS() {
        try {
            selectAll = false;
            initialScan = true;
            schemaMap = Schema.getGlobalDescribe();
            String searchString = '%'+srcStr+'%';
            String Approved = 'Approved';
            String allFieldsTO = fetchAllFields('ERP7__Transfer_Order__c');
            UtilClass.FlSCheck(allFieldsTO.split(',') ,'ERP7__Transfer_Order__c');
            String queryTO = 'select ' + allFieldsTO + ' from ERP7__Transfer_Order__c where Active__c = true and Is_Closed__c = false and (Name like :searchString or Name like :searchString) AND Ready_To_Receive__c = True Order by Expected_Date__c ASC';
            if(Schema.sObjectType.ERP7__Transfer_Order__c.isAccessible()){
            TOS = Database.query(queryTO);}
            
            List<Attachment> Attachments = [Select Id, Name, ParentId from Attachment where ParentId IN :TOS Order By CreatedDate Asc];
            Map<Id,Attachment> TOAttachment = new Map<Id,Attachment>();
            for(Attachment A : Attachments) TOAttachment.put(A.ParentId,A);
            
            TOWrapperList = new List<TOWrapper>();
            for(Transfer_Order__c s : TOS){ TOWrapper p = new TOWrapper(); p.TO = s; p.Attach = (TOAttachment.ContainsKey(s.Id))? TOAttachment.get(s.Id) : new Attachment(); p.isSelected = false; TOWrapperList.add(p); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }    
    
    public PageReference setPO(){ srcStr = 'PO'; return Null; }
    public PageReference setWO(){ srcStr = 'WO'; return Null; }
    public PageReference setSO(){ srcStr = 'SO'; return Null; }
    public PageReference setTO(){ srcStr = 'TO'; return Null; }
    
    public pageReference scannerMethod() {
        try { 
            string mybarcode = barcode.trim();
            schemaMap = Schema.getGlobalDescribe();
            if(mybarcode=='Putaway') return PutAway();
            String allFields = fetchAllFields('ERP7__PO__c');
            UtilClass.FlSCheck(allFields.split(',') ,'ERP7__PO__c');
            allFields += ', Vendor__r.name';
            String tempPOChannel = Employee.Channel__c;
            String query = 'select ' + allFields + ' from ERP7__PO__c where Active__c = true and Channel__c =: tempPOChannel and Is_Closed__c = false and Barcode__c = :mybarcode Limit 1';
            if(Schema.sObjectType.ERP7__PO__c.isAccessible()){
            TPO = Database.query(query);}
            
            String status = 'Complete';
            String allFieldss = fetchAllFields('ERP7__WO__c');
            UtilClass.FlSCheck(allFieldss.split(',') ,'ERP7__WO__c');
            allFieldss += ', Project__r.name';
            String querys = 'select ' + allFieldss + ' from ERP7__WO__c where Active__c = true and Status__c = :status and Barcode__c = :mybarcode Limit 1';
            if(Schema.sObjectType.ERP7__WO__c.isAccessible()){
            TWO = Database.query(querys);}
            
            if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()){
            TsalesOrder = [Select Id, Name, ERP7__Active__c, ERP7__Return_Status__c, ERP7__SOLI__c, ERP7__SOLI__r.Sales_Order__c,
                            ERP7__SOLI__r.Sales_Order__r.Barcode__c From RMA_Line_Item__c Where ERP7__Active__c = true and ERP7__Return_Status__c = 'Quality Check' and
                            Added_Back_to_Inventory__c != true and ERP7__SOLI__r.Sales_Order__r.Barcode__c = :mybarcode Limit 1];}                    
            String Approved = 'Approved';
            String allFieldsTO = fetchAllFields('ERP7__Transfer_Order__c');
            UtilClass.FlSCheck(allFieldsTO.split(',') ,'ERP7__Transfer_Order__c');
            String queryTO = 'select ' + allFieldsTO + ' from ERP7__Transfer_Order__c where Active__c = true and Status__c = :Approved and Barcode__c = :mybarcode Limit 1';
            if(Schema.sObjectType.ERP7__Transfer_Order__c.isAccessible()){
            TOScan = Database.query(queryTO);}
           } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference scannerMethodCustom() {
        try {
            schemaMap = Schema.getGlobalDescribe();
            if(TPO.size() > 0) {
               if(initialScan == true) { POWrapperList = new List<POWrapper>(); initialScan = false; }
               for(ERP7__PO__c s : TPO){ POWrapper p = new POWrapper(); p.PO = s; p.isSelected = true; POWrapperList.add(p); }
            } else if(TWO.size() > 0) {
                if(initialScan == true) { WOWrapperList = new List<WOWrapper>(); initialScan = false; }
                for(ERP7__WO__c s : TWO){ WOWrapper p = new WOWrapper(); p.WO = s; p.isSelected = true; WOWrapperList.add(p); }
            } else if(TsalesOrder.size() > 0) {
                if(initialScan == true) { SOWrapperList = new List<SOWrapper>(); initialScan = false;}
                if(Schema.sobjectType.RMA_Line_Item__c.fields.SOLI__c.isAccessible() && Schema.sobjectType.ERP7__Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) String soid = TsalesOrder[0].ERP7__SOLI__r.Sales_Order__c;
                
                String allFieldsSo = fetchAllFields('ERP7__Sales_Order__c');
                UtilClass.FlSCheck(allFieldsSo.split(',') ,'ERP7__Sales_Order__c');
                allFieldsSo += ', Account__r.Name, Contact__r.Name';
                String querySo = 'select ' + allFieldsSo + ' from ERP7__Sales_Order__c where Id = :soId';
                List<ERP7__Sales_Order__c> order;
                if(Schema.sObjectType.ERP7__Sales_Order__c.isAccessible()){
                order = Database.query(querySo);}
                
                for(ERP7__Sales_Order__c s : order){ SOWrapper p = new SOWrapper(); p.SO = s; p.isSelected = true; SOWrapperList.add(p); }
            } else if(TOScan.size() > 0) {
                if(initialScan == true) { TOWrapperList = new List<TOWrapper>(); initialScan = false;}
                for(Transfer_Order__c s : TOScan){ TOWrapper p = new TOWrapper(); p.TO = s; p.isSelected = true; TOWrapperList.add(p); }
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }        
        return Null;
    }
    
    public pageReference PutAway() {
        try {
            if(selectedSection == 'PO') return PutAwayPOS();
            else if(selectedSection == 'WO') return PutAwayWOS();
            else if(selectedSection == 'SO') return PutAwaySOS();
            else if(selectedSection == 'TO') return PutAwayTOS();
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference PutAwayPOS() {
        try {
            String poids = '';
            for(Integer i=0; i<POWrapperList.size(); i++){
                POWrapper R = POWrapperList[i];
                if(R.isSelected == true) { if(poids == '') poids += R.PO.Id; else poids += ','+R.PO.Id; }
            }
            if(poids != ''){
                String POReceiveURL = '/apex/ERP7__POReceive?sr=true&channel='+Employee.Channel__c+'&poid='+poids;
                PageReference Page = new PageReference(POReceiveURL);
                return Page;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference PutAwayWOS() {
        try {
            String woids = '';
            for(Integer i=0; i<WOWrapperList.size(); i++){
                WOWrapper R = WOWrapperList[i];
                if(R.isSelected == true) { if(woids == '') woids += R.WO.Id; else woids += ','+R.WO.Id; }
            }
            if(woids != ''){
                //PageReference Page = new PageReference('/apex/ManufacturingInventoryConsole?sr=true&woid='+woids);
                String WOReceiveURL = '/apex/ERP7__WOReceive?sr=true&channel='+Employee.Channel__c+'&woid='+woids;
                PageReference Page = new PageReference(WOReceiveURL);
                return Page;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference PutAwaySOS() {
        try {
            String soids = '';
            for(Integer i=0; i<SOWrapperList.size(); i++){
                SOWrapper R = SOWrapperList[i];
                if(R.isSelected == true) { if(soids == '') soids += R.SO.Id; else soids += ','+R.SO.Id; }
            }
            if(soids != ''){
                //PageReference Page = new PageReference('/apex/RMAInventoryConsole?sr=true&soid='+soids);
                String SOReceiveURL = '/apex/ERP7__SOReceive?sr=true&channel='+Employee.Channel__c+'&soid='+soids;
                PageReference Page = new PageReference(SOReceiveURL);
                return Page;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference PutAwayTOS() {
        try {
            String toids = '';
            for(Integer i=0; i<TOWrapperList.size(); i++){
                TOWrapper R = TOWrapperList[i];
                if(R.isSelected == true) { if(toids == '') toids += R.TO.Id; else toids += ','+R.TO.Id; }
            }
            if(toids != ''){
                //PageReference Page = new PageReference('/apex/TransferInventoryConsole?sr=true&toid='+toids);
                String TOReceiveURL = '/apex/ERP7__TOReceive?sr=true&channel='+Employee.Channel__c+'&toid='+toids;
                PageReference Page = new PageReference(TOReceiveURL);
                return Page;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference POALL() {
        try {
            if(selectAll) { for(POWrapper R : POWrapperList) R.isSelected = true; } 
            else for(POWrapper R : POWrapperList) R.isSelected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference WOALL() {
        try {
            if(selectAll) { for(WOWrapper R : WOWrapperList) R.isSelected = true; } 
            else for(WOWrapper R : WOWrapperList) R.isSelected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference SOALL() {
        try {
            if(selectAll) { for(SOWrapper R : SOWrapperList) R.isSelected = true; } 
            else for(SOWrapper R : SOWrapperList) R.isSelected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    public pageReference TOALL() {
        try {
            if(selectAll) { for(TOWrapper R : TOWrapperList) R.isSelected = true; } 
            else for(TOWrapper R : TOWrapperList) R.isSelected = false;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return Null;
    }
    
    /*
      method for create purchase order
    */
    public PageReference createPOs() {
        try {
            newPO = new PO__c(Status__c='New',channel__c=Employee.Channel__c); 
            poliWrapperList = new List<newWrapper>();
            poliWrapperList.add(new newWrapper(nextIdent++));                    
            return Page.ERP7__StockReceiving_CreatePurchaseOrder;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for adding more POLI rows
    */
    public PageReference addPoliWrapperRows() {
        try {
            for(Integer i=0; i<addRow; i++) { poliWrapperList.add(new newWrapper(nextIdent++)); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting POLI rows
    */
    public PageReference delPoliWrapperRow() {
        try {
            Integer delPos = -1;
            for(Integer i=0; i<poliWrapperList.size(); i++) { if (poliWrapperList[i].ident == toDelIdent) delPos = i; }
            if (-1 != delPos) newWrapper poliDel = poliWrapperList.remove(delPos);
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for saving PO details
    */
    public PageReference savePO() {
        try {
            if(newPO != null && Schema.sObjectType.PO__c.isCreateable() && Schema.sObjectType.PO__c.isUpdateable()) { upsert newPO; }  else{ /* no access*/ }  
            List<Purchase_Line_Items__c> Polis = new List<Purchase_Line_Items__c>(); 
            for(newWrapper nwrp: poliWrapperList) {
                Purchase_Line_Items__c poli = new Purchase_Line_Items__c();
                
                poli = nwrp.poli;
                if(Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Orders__c.isAccessible()) poli.Purchase_Orders__c = newPO.Id;
                Polis.add(poli);
            }
            if(Polis.size() > 0 && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Purchase_Line_Items__c.fields.Purchase_Orders__c.isUpdateable()){ DMLManager.upsertAsUser(Polis);  } else{ /* no access */ }      
            return Page.ERP7__StockReceiving;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for create work order
    */
    public PageReference createWOs() {
        try {
            newWO = new WO__c(Status__c='New');      
            woliWrapperList = new List<newWrapper>();       
            return Page.ERP7__StockReceiving_CreateWorkOrder;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for adding more WOLI rows
    */
    public PageReference addWoliWrapperRows() {
        try {
            for(Integer i=0; i<addRow; i++) { woliWrapperList.add(new newWrapper(nextIdent++)); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting WOLI rows
    */
    public PageReference delWoliWrapperRow() {
        try {
            Integer delPos = -1;
            for(Integer i=0; i<woliWrapperList.size(); i++) { if (woliWrapperList[i].ident == toDelIdent) delPos = i; }
            if (-1 != delPos) newWrapper woliDel = woliWrapperList.remove(delPos);
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for saving WO details
    */
    public PageReference saveWO() {
        try {
            if(newWO != null && Schema.sObjectType.ERP7__WO__c.isCreateable() && Schema.sObjectType.ERP7__WO__c.isUpdateable()){ upsert newWO; } else{ /* no access*/ }    
            List<Work_Order_Line_Items__c> wolis = new List<Work_Order_Line_Items__c>(); 
            for(newWrapper nwrp: woliWrapperList) {
                Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c();
                
                woli = nwrp.woli;
                if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Work_Orders__c.isAccessible()) woli.Work_Orders__c = newWO.Id;
                wolis.add(woli);
            }
            if(wolis.size() > 0 && Schema.sObjectType.Work_Order_Line_Items__c.fields.Work_Orders__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.fields.Work_Orders__c.isUpdateable()){ DMLManager.upsertAsUser(wolis); } else{ /* no acces */ }        
            return Page.ERP7__StockReceiving;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for create purchase requisition
    */
    public PageReference createPRs() {
        try {
             newPR = new Requisition__c(Status__c='Approved');             
            prliWrapperList = new List<newWrapper>();
            return Page.ERP7__StockReceiving_CreateRequisition;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for adding more PRLI rows
    */
    public PageReference addPrliWrapperRows() {
        try {
            for(Integer i=0; i<addRow; i++) { prliWrapperList.add(new newWrapper(nextIdent++)); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for deleting PRLI rows
    */
    public PageReference delPrliWrapperRow() {
        try {
            Integer delPos = -1;
            for(Integer i=0; i<prliWrapperList.size(); i++) { if (prliWrapperList[i].ident == toDelIdent) delPos = i; }
            if (-1 != delPos) newWrapper prliDel = prliWrapperList.remove(delPos);
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for saving PR details
    */
    public PageReference savePR() {
        try {
            if(newPR != null) upsert newPR;       
            List<Purchase_Requisition_Line_Items__c> Prlis = new List<Purchase_Requisition_Line_Items__c>(); 
            for(newWrapper nwrp: prliWrapperList) {
                Purchase_Requisition_Line_Items__c prli = new Purchase_Requisition_Line_Items__c();
                
                prli = nwrp.prli;
                if(Schema.sObjectType.Purchase_Requisition_Line_Items__c.fields.Purchase_Requisition__c.isAccessible()) prli.Purchase_Requisition__c = newPR.Id;
                Prlis.add(prli);
            }
            if(Prlis.size() > 0) DMLManager.upsertAsUser(Prlis);        
            return Page.ERP7__StockReceiving;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }     
    
    /*
      method for create RMA line items
    */    
    public PageReference createSalesReturns() {
        try {
             List<SOWrapper> SOSelectedWrapperList = new List<SOWrapper>();
            for(SOWrapper sow : SOWrapperList) { if(sow.isSelected == true) SOSelectedWrapperList.add(sow); }
            if(SOSelectedWrapperList.size() > 0) {
                PageReference pages = page.ERP7__ProcessReturnPage;
                if(Schema.sobjectType.ERP7__Sales_Order__c.fields.Customer_Id__c.isAccessible()) pages.getParameters().put('con',SOSelectedWrapperList[0].so.Customer_Id__c);
                if(Schema.sobjectType.ERP7__Sales_Order__c.fields.Name.isAccessible()) pages.getParameters().put('oid',SOSelectedWrapperList[0].so.Name);
                pages.getParameters().put('red','false');
                return pages;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    public PageReference back() {
        return Page.ERP7__StockReceiving;
    }
    public PageReference PreparePushAttachment() {
        universalAttachment = new Attachment();
        return Null;
    }
    public PageReference PushAttachment() {
        universalAttachment.ParentId = PreparePushAttachmentId;
        if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isUpdateable()){ hasAccess=true; upsert universalAttachment;}
        else{hasAccess=false; errormsg='You are not allowed to create or update records';}
        for(POWrapper s : POWrapperList){ if(s.PO.Id == PreparePushAttachmentId) { s.Attach = universalAttachment; s.Attach.body = Null; break; }}
        universalAttachment = new Attachment();
        return Null;
    }
        
    public pageReference updatePOLIDetails(){
        if(poliWrapperList.size()>0){
               for(Integer i=0;i<poliWrapperList.size();i++){
                //Product2 seletProd = Product2Map.get(poliWrapperList[i].poli.Product__c);
                //poliWrapperList[i].poli.Quantity__c = seletProd.MOQ__c;
                // poliWrapperList[i].poli.Quantity__c = seletProd.MOQ__c;
               
               }
           }
     return null;
    }
    public String fetchAllFields(String sObj) {
        String allFields = '';
        try {
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObj).getDescribe().fields.getMap();            
            for(String fieldName : fieldMap.keyset()){
                if(allFields == null || allFields == '') { allFields = fieldName; }
                else { allFields = allFields + ', ' + fieldName; }
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return allFields;
    }
    
    public List<POWrapper> POWrapperList     { get; set; }
    public List<WOWrapper> WOWrapperList     { get; set; }
    public List<SOWrapper> SOWrapperList     { get; set; }
    public List<TOWrapper> TOWrapperList     { get; set; }    
    public class POWrapper{
        public PO__c PO                      { get; set; }
        public Attachment Attach             { get; set; }
        public Boolean isSelected            { get; set; }
        
        public POWrapper() {
            PO = new PO__c();
            Attach = new Attachment();
            isSelected = false;
        }        
    }
    
    public class WOWrapper{
        public WO__c WO                      { get; set; }
        public Attachment Attach             { get; set; }
        public Boolean isSelected            { get; set; }
        
        public WOWrapper() {
            WO = new WO__c();
            Attach = new Attachment();
            isSelected = false;
        }        
    }
    
    public class SOWrapper{
        public Sales_Order__c SO             { get; set; }
        public Attachment Attach             { get; set; }
        public Boolean isSelected            { get; set; }
        
        public SOWrapper() {
            SO = new Sales_Order__c();
            Attach = new Attachment();
            isSelected = false;
        }
    }
    
    public class TOWrapper{
        public Transfer_Order__c TO          { get; set; }
        public Attachment Attach             { get; set; }
        public Boolean isSelected            { get; set; }
        
        public TOWrapper() {
            TO = new Transfer_Order__c();
            Attach = new Attachment();
            isSelected = false;
        }    
    }
    
    public List<newWrapper> poliWrapperList               { get; set; }
    public List<newWrapper> woliWrapperList               { get; set; }     
    public List<newWrapper> prliWrapperList               { get; set; } 
    
    public class newWrapper {
        public Integer ident                              { get; set; }
        public Purchase_Line_Items__c poli                { get; set; }
        public Work_Order_Line_Items__c woli              { get; set; }
        public Purchase_Requisition_Line_Items__c prli    { get; set; }                 

        public newWrapper(Integer inIdent) {
            ident = inIdent;
            poli = new Purchase_Line_Items__c();
            woli = new Work_Order_Line_Items__c();
            prli = new Purchase_Requisition_Line_Items__c();           
        }
    }
}