public with sharing class MOProductConfiguaration {
    @AuraEnabled public Boolean allowWIPValidation {get;set;}
    @AuraEnabled public Boolean showVenCode {get;set;}
    @AuraEnabled
    public static MOProductConfiguaration geFC(){
        MOProductConfiguaration MOConfig = new MOProductConfiguaration();
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        
        if(FC == null){ 
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
        }
        if(FC != null){
            MOConfig.allowWIPValidation = FC.ERP7__Add_validation_for_WIP_creation_MOSetup__c;
            MOConfig.showVenCode = FC.ERP7__Show_Vendor_Product_Code__c;
        }
        return MOConfig;
    }
    @AuraEnabled
    public static List<wrapper> getAllProds(String processId,String ProductId,String search,String Family,String SubFamily){
        string siteId = '';
        if(processId != null && processId != '' && ProductId != null && ProductId != ''){
            List<ERP7__Routing__c> route = [Select Id,Name,ERP7__Process__c,ERP7__Raw_Materials_Site__c from ERP7__Routing__c where ERP7__Process__c=:processId and ERP7__Product__c =: ProductId limit 1]; 
            if(route.size() > 0) siteId = route[0].ERP7__Raw_Materials_Site__c;
        }
        List<wrapper> wrap = new List<wrapper>();
        if(search != null && search != '') search = '%'+search+'%';
        string query = '';
        query = 'Select Id,Name,Description,ProductCode,ERP7__Purchase_Lead_Time_days__c,ERP7__Vendor_product_Name__c,QuantityUnitOfMeasure from Product2 where IsActive = true and ERP7__Track_Inventory__c = true';
        
        if(Family != null && Family != ''){
            query+= ' and Family = :Family';
        }
        if(SubFamily != null && SubFamily != ''){
            query+= ' and ERP7__Product_Service_Family__c = :SubFamily';
        }
        if(search != null && search != ''){
            
            system.debug('search : '+search);
            query+= ' and (Name LIKE :search or ProductCode LIKE :search or StockKeepingUnit LIKE :search )';
        }
        query+= ' Order By Name Limit 100';
        List<Product2> prodList = Database.query(query);
        set<Id> productIds = new set<Id>();
        system.debug('prodList.size() 1 : '+prodList.size());
        for(Product2 pr:prodList)    productIds.add(pr.Id);
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(siteId != null && siteId != ''){
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,ERP7__No_of_Items_Requested__c,ERP7__Number_of_Items_Awaiting_in_Stock__c,
                                            ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                            Where product__c In: productIds And
                                            Active__c = true And
                                            Warehouse__c =: siteId 
                                            and (ERP7__Number_of_Item_In_Stock__c > 0 Or ERP7__No_of_Items_Requested__c > 0 or ERP7__Number_of_Items_Awaiting_in_Stock__c > 0)
                                           ];
        }
        
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        Map<String, Decimal> demandView = new Map<String, Decimal>();
        Map<String, Decimal> AwaitingstockView = new Map<String, Decimal>();
        List<ERP7__Cost_Card__c> CC = [Select Id,Name,ERP7__Cost__c,ERP7__Product__c from ERP7__Cost_Card__c where ERP7__Product__c IN: productIds and ERP7__Cost__c != null and ERP7__Active__c = true and ERP7__Default__c = true and ERP7__Start_Date__c <=:System.today() and ERP7__End_Date__c >= : System.today() and ERP7__Supplier__c = null Order By ERP7__Default__c ];
        Map<Id,ERP7__Cost_Card__c> ccMap = new Map<Id,ERP7__Cost_Card__c>();
        for(ERP7__Cost_Card__c cc1 : CC){
            if(!ccMap.containsKey(cc1.ERP7__Product__c)) ccMap.put(cc1.ERP7__Product__c,cc1);
            
        }
        for(Id prId:productIds){
            Decimal stock = 0;
            Decimal demand = 0;
            Decimal Awaitingstock=0;
            for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                if(prId == inven.product__c){
                    stock += inven.ERP7__Number_of_Item_In_Stock__c;
                    demand += inven.ERP7__No_of_Items_Requested__c;
                    Awaitingstock += inven.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                }
            }
            stockView.put(prId,stock);
            demandView.put(prId,demand);
            AwaitingstockView.put(prId,Awaitingstock);
        }
        for(Product2 pr:prodList){
            wrapper wrapNew = new wrapper();
            wrapNew.prod = pr;
            WrapNew.UOM = pr.QuantityUnitOfMeasure;
            wrapNew.quantity = 0;
            wrapNew.MaxVariance = 0;
            wrapNew.MinVariance = 0;
            wrapNew.Multiples = 0;
            if(stockView.containsKey(pr.Id))  wrapNew.stock = stockView.get(pr.Id);
            else  wrapNew.stock = 0;
            if(demandView.containsKey(pr.Id)) wrapNew.demand = demandView.get(pr.Id);
            else  wrapNew.demand = 0;
            if(AwaitingstockView.containsKey(pr.Id)) wrapNew.AwaitStock = AwaitingstockView.get(pr.Id);
            else  wrapNew.demand = 0;
            if(ccMap.containsKey(pr.Id)) {
                wrapNew.CostPrice = ccMap.get(pr.Id).ERP7__Cost__c;
                wrapNew.CostcardId = ccMap.get(pr.Id).Id;
            }
            else wrapNew.CostPrice = 0;
            wrap.add(wrapNew);
        }
        if(wrap.size() > 0){
            return wrap;
        }
        else return null;
    }
    @AuraEnabled
    public static List<String> getFamily(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled
    public static List<String> getSubFamily(){
        List<String> options = new List<String>(); 
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Product2.ERP7__Product_Service_Family__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled
    public static Boolean fetchFCResult(){
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ 
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
        }
        if(FC != null){
            return FC.ERP7__Allow_non_inventory_BOMs_in_MO__c;
        }
        else return null;
        
    }
    
    @AuraEnabled
    public static string Updatealldetails(string PId,String PRID,String VRId){
        List<ERP7__Routing__c> route = [Select Id,Name,ERP7__Process__c from ERP7__Routing__c where ERP7__Product__c=:PId and ERP7__BOM_Version__c = :VRId limit 1];
        if(route.size() > 0) {
            if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Process__c.isUpdateable()){route[0].ERP7__Process__c = PRID;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Routing__c.isUpdateable()){update route;}else{/*No access*/}
        }
        return 'Success';
        
    }//from below
        public class SelectOptionWrapper {
        public String label;
        public String value;

        public SelectOptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    @AuraEnabled
    public static List<SelectOptionWrapper> getpicklistvallues(String objectApiName,String fieldApiName){
        List<SelectOptionWrapper> picklistValues = new List<SelectOptionWrapper>();
        Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();
        
            for (Schema.PicklistEntry entry : fieldDescribe.getPicklistValues()) {
                picklistValues.add(new SelectOptionWrapper(entry.getLabel(), entry.getValue()));
            }
        return picklistValues;
    }//till here
    
    @AuraEnabled
    public static List<ProcessCyclewrap> CreateNewChklst(String check,String versionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__Checklist__c newcheck = (ERP7__Checklist__c) JSON.deserialize(check, ERP7__Checklist__c.class); 
            if((newcheck.ERP7__Comply__c == null || newcheck.ERP7__Comply__c == '') && Schema.sObjectType.ERP7__Checklist__c.fields.ERP7__Comply__c.isCreateable()){ newcheck.ERP7__Comply__c = '--None--';}else{/*No access*/}
            //from here
            List<SelectOptionWrapper> picklistValues = getpicklistvallues('ERP7__Checklist__c', 'ERP7__Comply__c');
            List<SelectOptionWrapper> picklistValues2 = getpicklistvallues('ERP7__Checklist__c', 'ERP7__Result__c');
            for (SelectOptionWrapper option : picklistValues) {
                if (option.label.equals(newcheck.ERP7__Comply__c)) { newcheck.ERP7__Comply__c =option.value;
                }
            }
            for (SelectOptionWrapper option : picklistValues2) {
                if (option.label.equals(newcheck.ERP7__Result__c)) { newcheck.ERP7__Result__c =option.value;
                }
            }//till here
            if(Schema.sObjectType.ERP7__Checklist__c.isCreateable()){insert newcheck;}else{/*No access*/}
            string PrcsID = newcheck.ERP7__Process_Cycle__c;
            ERP7__Process_Cycle__c currPR = [Select ID,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:PrcsID limit 1];
            string selectedPR = currPR.ERP7__Process__c;
            List<ERP7__Process_Cycle__c> prcslst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c =:selectedPR Order By CreatedDate ASC limit 1000];
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prcslst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(selectedPR,WCIds,versionId,'');
            /*for(ERP7__Process_Cycle__c pp: prcslst) { 
pcwrap =.add(new ProcessCyclewrap(pp,getAll(pp.Id,''),false)); 
}*/
        }
        catch(Exception e) { 
            //('Error:'+e.getMessage()+'  Line:'+e.getLineNumber()); 
        }
        return pcwrap;
        
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> DeleteAT(String AttachId,String versionId){   
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            Attachment deleteAtt = [select Id,Name,ParentId from Attachment Where Id =:AttachId];
            String mediaId = deleteAtt.ParentId;
            ERP7__Media__c med =[Select Id,Name,ERP7__Operation__c,ERP7__Operation__r.ERP7__Process_Cycle__c from ERP7__Media__c where Id=:mediaId limit 1];
            String ProcesscycleId =med.ERP7__Operation__r.ERP7__Process_Cycle__c;
            if(Schema.sObjectType.Attachment.isDeletable()) delete deleteAtt;
            ERP7__Process_Cycle__c currPR = [Select ID,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:ProcesscycleId limit 1];
            string selectedPR = currPR.ERP7__Process__c;
            List<ERP7__Process_Cycle__c> prcslst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c =:selectedPR Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prcslst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(selectedPR,WCIds,versionId,'');
            //pcwrap = getAll(ProcesscycleId,'');
        } catch(Exception e) { 
            //('Error : '+e.getMessage() +' Line Number @ : '+ e.getLineNumber()); 
        }
        return pcwrap;
    }
    @AuraEnabled
    public static List<Productwrap> getsearchedProducts(String searchStr){
        List<Productwrap> pwrap =  new List<Productwrap>();
        try{
            if(searchStr == null) searchStr = '';
            searchStr = '%'+searchStr+'%';
            
            List<Product2> prodList = [Select Id,Name,ProductCode,Description,ERP7__Status__c,QuantityUnitOfMeasure from Product2 where ERP7__Issue_Manufacturing_Order__c = true and ERP7__Status__c != 'Obsolete' and IsActive = true ANd (Name Like :searchStr or ProductCode Like :searchStr) Order by CreatedDate Desc limit 1000];
            for(Product2 pro : prodList){ 
                pwrap.add(new Productwrap(pro,new ERP7__Version__c(),prodList.size(),new ERP7__Process__c()));
            }
        }catch(exception e){ 
            //('Error occured : '+e.getMessage()+ ' at : '+e.getLineNumber());
        }
        return pwrap;
        
    }
    @AuraEnabled
    public static String deleteallcloned(String PrId,String ProdId, String VerId){
        system.debug('deleteallcloned called');
        removeallcloned(PrId,ProdId,VerId);
        return 'sucess';
    }
    
    @future 
    public static void removeallcloned(String PrId, String prodId, String VerId){
        try{
            system.debug('removeallcloned called');
            if(PrId != null && PrId != ''){

                system.debug('VerId~>'+VerId);
                
                /*if(String.isNotEmpty(VerId)){
                    ERP7__Version__c ver = [Select Id, Name from ERP7__Version__c where Id =: VerId];
                    if(Schema.sObjectType.ERP7__Version__c.isDeletable()) delete  ver; 
                }*/
                
                List<ERP7__Process_Cycle__c> pr = [Select Id,Name,ERP7__Work_Center__c,ERP7__Process__c from ERP7__Process_Cycle__c where ERP7__Process__c =:PrId];
                set<Id> WC = new set<Id>();
                for(ERP7__Process_Cycle__c pp : pr) WC.add(pp.ERP7__Work_Center__c);
                List< ERP7__Work_Planner__c > WPS = [Select Id,Name from  ERP7__Work_Planner__c  where ERP7__WorkCenter__c =:WC and ERP7__Process__c =:PrId];
                List<ERP7__Resource_Group__c> rgroup = [Select Id,Name from ERP7__Resource_Group__c where ERP7__Process__c =:PrId or ERP7__Process_Cycle__c IN:pr];
                List< ERP7__Resource_Requirement__c > RRS = [Select Id,Name from ERP7__Resource_Requirement__c where ERP7__Work_Planner__c In :WPS and ERP7__Resource_Group__c In :rgroup];
                List<ERP7__Resource__c> res = [Select Id,Name from ERP7__Resource__c where ERP7__Resource_Group__c IN:rgroup];
                List<ERP7__Operation__c> oprlst = [Select Id,Name from ERP7__Operation__c where ERP7__Process_Cycle__c IN:pr];
                List<ERP7__BOM__c> bomlst = [Select Id,Name from ERP7__BOM__c where ERP7__Process_Cycle__c IN:pr];
                List<ERP7__WIP_Link__c> wiplst = [Select Id,Name from ERP7__WIP_Link__c where ERP7__Process_Cycle__c IN:pr];
                List<ERP7__Routing_Link__c> routlnk = [Select Id,Name from ERP7__Routing_Link__c where ERP7__Process_Cycle__c IN:pr];
                List<ERP7__Media__c> medialst = [Select Id,Name from ERP7__Media__c where ERP7__Operation__c IN: oprlst];
                List<Attachment> attchlst = [Select Id,Name from Attachment where ParentId IN:medialst];
                List<ERP7__Checklist__c> checklst = [Select Id,Name from ERP7__Checklist__c where ERP7__Process_Cycle__c IN:pr];
                
                if(Schema.sObjectType.ERP7__WIP_Link__c.isDeletable()) delete  attchlst; 
                if(Schema.sObjectType.ERP7__Media__c.isDeletable()) delete  medialst;   
                if(Schema.sObjectType.ERP7__Routing_Link__c.isDeletable()) delete  routlnk;  
                if(Schema.sObjectType.ERP7__WIP_Link__c.isDeletable()) delete  wiplst;   
                if(Schema.sObjectType.ERP7__BOM__c.isDeletable()) delete  bomlst;  
                if(Schema.sObjectType.ERP7__Operation__c.isDeletable()) delete  oprlst;   
                if(Schema.sObjectType.ERP7__Resource__c.isDeletable()) delete  res;  
                if(Schema.sObjectType.ERP7__Resource_Requirement__c.isDeletable()) delete  RRS;  
                if(Schema.sObjectType.ERP7__Resource_Group__c.isDeletable()) delete  rgroup; 
                if(Schema.sObjectType.ERP7__Work_Planner__c.isDeletable()) delete  WPS;   
                if(Schema.sObjectType.ERP7__Checklist__c.isDeletable()) delete checklst;  
                if(Schema.sObjectType.ERP7__Process_Cycle__c.isDeletable()) delete  pr;
                List<ERP7__Routing__c> rr = [Select Id,Name from ERP7__Routing__c where ERP7__Product__c=:prodId and ERP7__Process__c=:PrId limit 1];
                if(Schema.sObjectType.ERP7__Routing__c.isDeletable()) delete rr;
                ERP7__Process__c prcs = [Select Id,Name from ERP7__Process__c where Id=:PrId limit 1];
                if(Schema.sObjectType.ERP7__Process__c.isDeletable()) delete prcs;
                
            }
        }catch(Exception e){
            system.debug('Error ~>'+e.getMessage()+' at~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static List<Productwrap> getProducts(Integer pjtOffset, Integer RecordLimit){
        List<Productwrap> pwrap =  new List<Productwrap>();
        try{
            List<Product2> prodList = [Select Id,Name,ERP7__Status__c,ProductCode,QuantityUnitOfMeasure,Description from Product2 where ERP7__Issue_Manufacturing_Order__c = true and ERP7__Track_Inventory__c=true and ERP7__Status__c != 'Obsolete' and IsActive = true Order by CreatedDate Desc limit 1000];
            List<Product2> newProductList = new List<Product2>();
            Integer countPjt = 0;
            for(Product2 pro : prodList){
                if(countPjt < (pjtOffset+RecordLimit) && countPjt >= pjtOffset) {
                    newProductList.add(pro);
                }
                countPjt++;
            }
            for(Product2 pro : newProductList){
                pwrap.add(new Productwrap(pro,new ERP7__Version__c(),prodList.size(),new ERP7__Process__c()));
            }
        }catch(exception e){ 
            //('Error occured : '+e.getMessage()+ ' at : '+e.getLineNumber());
        }
        return pwrap;
        
    }
    @AuraEnabled
    public static List<String> getVerStatus(){
        List<String> options = new List<String>(); options.add('--None--'); Schema.DescribeFieldResult fieldResult = ERP7__Version__c.ERP7__Status__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(f.getLabel());} return options;
    }
    @AuraEnabled
    public static List<String> getchecklstpicklists(){
        List<String> options = new List<String>(); options.add('--None--'); Schema.DescribeFieldResult fieldResult = ERP7__Checklist__c.ERP7__Comply__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(f.getLabel());} return options;
    }
    @AuraEnabled
    public static List<String> getchekresult(){
        List<String> options = new List<String>(); options.add('--None--'); Schema.DescribeFieldResult fieldResult = ERP7__Checklist__c.ERP7__Result__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(f.getLabel());} return options;
    }
    @AuraEnabled
    public static List<SelectOptions> getBOMUOMPicklist(){
        List<SelectOptions> options = new List<SelectOptions>(); options.add(new SelectOptions('--None--', '--None--')); Schema.DescribeFieldResult fieldResult = ERP7__BOM__c.ERP7__Unit_of_Measure__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(new SelectOptions(f.getLabel(), f.getValue()));} return options;
    }
    @AuraEnabled
    public static List<SelectOptions> getProductUOMPicklist(){
        List<SelectOptions> options = new List<SelectOptions>(); options.add(new SelectOptions('--None--', '--None--')); Schema.DescribeFieldResult fieldResult = Product2.QuantityUnitOfMeasure.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(new SelectOptions(f.getLabel(), f.getValue()));} return options;
    }
    @AuraEnabled
    public static List<SelectOptions> WIPUompickval(){
        List<SelectOptions> options = new List<SelectOptions>(); options.add(new SelectOptions('--None--', '--None--')); Schema.DescribeFieldResult fieldResult = ERP7__WIP_Link__c.ERP7__Quantity_Unit_Of_Measure__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(new SelectOptions(f.getLabel(), f.getValue()));} return options;
    }
    @AuraEnabled
    public static List<String> getVerType(){
        List<String> options = new List<String>(); options.add('--None--'); Schema.DescribeFieldResult fieldResult = ERP7__Version__c.ERP7__Type__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(f.getLabel());} return options;
    }
    @AuraEnabled
    public static void saveNewVersion(String Ver){
        Id rTypeManufacturing; rTypeManufacturing = Schema.SObjectType.ERP7__Version__c.getRecordTypeInfosByDeveloperName().get('Manufacturing').getRecordTypeId();
        
        ERP7__Version__c version = (ERP7__Version__c) JSON.deserialize(Ver, ERP7__Version__c.class);
        if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Active__c.isCreateable()){version.ERP7__Active__c = true;}else{/*No access*/}
        if(Schema.sObjectType.ERP7__Version__c.fields.RecordTypeId.isCreateable() && rTypeManufacturing != null){version.RecordTypeId = rTypeManufacturing;}else{/*No access*/}
        if(Schema.sObjectType.ERP7__Version__c.isCreateable()){insert version;}else{/*No access*/}
    }
    @AuraEnabled
    public static String CreateMedia(String media){
        ERP7__Media__c med = (ERP7__Media__c) JSON.deserialize(media, ERP7__Media__c.class);
        if(Schema.sObjectType.ERP7__Media__c.fields.ERP7__Active__c.isCreateable()){med.ERP7__Active__c = true;}else{/*No access*/}
        if(Schema.sObjectType.ERP7__Media__c.isCreateable()){insert med;}else{/*No access*/}
        return med.Id;
    }
    @AuraEnabled
    public static List<ProcessCyclewrap>  uploadFile(String parent, String fileName, String base64Data, String contentType, String versionId) { 
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{  
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');  
            Attachment a = new Attachment();  
            if(Schema.sObjectType.Attachment.fields.parentId.isCreateable()){a.parentId = parent; }else{/*No access*/}
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){a.Body = EncodingUtil.base64Decode(base64Data);  }else{/*No access*/}
            if(Schema.sObjectType.Attachment.fields.Name.isCreateable()){a.Name = fileName; }else{/*No access*/}
            if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){a.ContentType = contentType; }else{/*No access*/}
            if(Schema.sObjectType.Attachment.isCreateable()){insert a;}else{/*No access*/}
            List<ERP7__Media__c> medlst = [Select Id,Name,ERP7__Operation__c,ERP7__Operation__r.ERP7__Process_Cycle__c from ERP7__Media__c where Id=:parent];
            if(medlst.size() > 0) {
                string ProcesscycleId =medlst[0].ERP7__Operation__r.ERP7__Process_Cycle__c;
                ERP7__Process_Cycle__c currPR = [Select ID,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:ProcesscycleId limit 1];
                string selectedPR = currPR.ERP7__Process__c;
                List<ERP7__Process_Cycle__c> prcslst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c =:selectedPR Order By CreatedDate ASC limit 1000];
                List<Id> WCIds = new List<Id>();
                for(ERP7__Process_Cycle__c pp: prcslst) {
                    WCIds.add(pp.ERP7__Work_Center__c);
                }
                pcwrap = alldetails(selectedPR,WCIds,versionId,'');
                //pcwrap = getAll(ProcesscycleId,'');
            }
            
        }catch(exception e){ 
            //('Error occured : '+e.getMessage()+ ' at : '+e.getLineNumber());
        }
        return pcwrap; 
    }
    @AuraEnabled
    public static List<ProcessCyclewrap> getProcessdetails(String selectedPR,String ProductId,String versionId,string action){
        List<ProcessCyclewrap> pcs = new List<ProcessCyclewrap>();
        if(ProductId != null && ProductId != ''){
            Product2 prod = [Select Id,Name  from Product2 where Id=:ProductId limit 1];
            List<ERP7__Routing__c> avilableroute = [Select Id,Name from ERP7__Routing__c where ERP7__Process__c =:selectedPR and ERP7__Product__c =:ProductId];
            if(selectedPR != null && selectedPR != ''){
                List<ERP7__Process_Cycle__c> prcslst = [Select Id,Name, ERP7__Sort__c, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c =:selectedPR Order By CreatedDate ASC limit 1000];
                set<Id> prcsyleIds = new set<Id>();
                List<Id> WCIDs = new List<Id>();
                for(ERP7__Process_Cycle__c prc :prcslst) { prcsyleIds.add(prc.Id); WCIDs.add(prc.ERP7__Work_Center__c);}
                if(prcslst.size() > 0){
                    pcs = alldetails(selectedPR,WCIDs,versionId,action);
                    return pcs;
                    /* for(ERP7__Process_Cycle__c pp: prcslst) { 
Boolean show = false;
if(avilableroute.size() > 0) show = false;
else show =true;
pcs.add(new ProcessCyclewrap(pp,getAll(pp.Id,''),show)); 
}*/
                }
                else{
                    Boolean show = true;
                    if(avilableroute.size() > 0) show = false;
                    pcs.add(new ProcessCyclewrap(new ERP7__Process_Cycle__c(),new comwrap(),show));
                }
                
                
                
            }
            
        }
        return pcs;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> cloneProcess(String selectedPR,String ProductId,String versionId){
        Savepoint sp = Database.setSavepoint();
        List<ProcessCyclewrap> pcs = new List<ProcessCyclewrap>();
        try{
            if(ProductId != null && ProductId != ''){
                Product2 prod = [Select Id,Name from Product2 where Id=:ProductId limit 1];
                
                List<ERP7__Routing__c> avilableroute = [Select Id, Name, ERP7__Auto_Stock_Allocation__c, ERP7__BOM_Version__c, ERP7__Finished_Products_Site__c, ERP7__Raw_Materials_Site__c, 
                                                        ERP7__Status__c, ERP7__Type__c, ERP7__Channel__c, ERP7__Product__c, ERP7__Process__c, RecordTypeId 
                                                        from ERP7__Routing__c where ERP7__Process__c =:selectedPR and ERP7__Product__c =:ProductId];
                
                if(selectedPR != null && selectedPR != ''){
                    ERP7__Process__c PR = [Select Id,Name,ERP7__Type__c,ERP7__Process_Description__c,ERP7__Other_Material_Cost__c,ERP7__Site__c,ERP7__Work_Center__c,ERP7__Work_Station__c,ERP7__Workforce_Cost__c,ERP7__Workforce_Hour_Required__c,RecordTypeId,ERP7__Process_Name__c,ERP7__Organisation__c  
                                           from ERP7__Process__c where Id= :selectedPR limit 1];
                    
                    ERP7__Process__c cloneProcess = PR.clone(false, false, false, false);
                    cloneProcess.Name = 'Process '+ prod.Name;
                    if(Schema.SObjectType.ERP7__Process__c.isCreateable()){insert cloneProcess;}else{/*No access*/}
                    system.debug('cloneProcess after insert~>'+cloneProcess);
                    
                    List<ERP7__Process_Cycle__c> prcslst = [Select Id, Name, ERP7__Description__c,ERP7__Work_Center__c from ERP7__Process_Cycle__c 
                                                            where Name != '' and ERP7__Process__c =:selectedPR];
                    system.debug('prcslst : '+prcslst);
                    List<ERP7__Process_Cycle__c> clonedProcesscycles = new List<ERP7__Process_Cycle__c>();
                    Integer sortcount = 1;
                    for(ERP7__Process_Cycle__c Prcs : prcslst){
                        ERP7__Process_Cycle__c newcylce = Prcs.clone(false, false, false, false);
                        newcylce.ERP7__Sort__c = sortcount;
                        if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Process__c.isCreateable()){newcylce.ERP7__Process__c = cloneProcess.Id;}else{/*No access*/}
                        clonedProcesscycles.add(newcylce);
                        sortcount++;
                    }
                    if(Schema.sObjectType.ERP7__Process_Cycle__c.isCreateable()){insert clonedProcesscycles;}else{/*No access*/}
                    system.debug('clonedProcesscycles size after insert~>'+clonedProcesscycles.size());
                    
                    set<Id> PcsIds = new set<Id>();
                    set<Id> newPcsIds = new set<Id>();
                    for(ERP7__Process_Cycle__c prc : prcslst){ PcsIds.add(prc.Id); }
                    
                    system.debug('PcsIds : '+PcsIds);
                    set<id> WCIds =  new set<id>() ;
                    for(ERP7__Process_Cycle__c newprc : clonedProcesscycles){
                        newPcsIds.add(newprc.Id);
                        if(newprc.ERP7__Work_Center__c != null) WCIds.add(newprc.ERP7__Work_Center__c);
                    }
                    
                    List<ERP7__Process_Cycle__c> newPrcslst = [Select Id,Name, ERP7__Description__c,ERP7__Sort__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name,ERP7__Process__r.Name 
                                                               from ERP7__Process_Cycle__c where Name != '' and Id IN : newPcsIds Order By CreatedDate ASC limit 1000];
                    
                    if(newPrcslst.size() > 1){
                        Integer i;
                        for(i=0;i<newPrcslst.size();i++) {
                            if(i == 0){ if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Next_Process_Cycle__c.isUpdateable()){newPrcslst[i].ERP7__Next_Process_Cycle__c = newPrcslst[i+1].Id;}else{/*No access*/} }
                            else if(i == newPrcslst.size()){ if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Previous_Process_Cycle__c.isUpdateable()){newPrcslst[i].ERP7__Previous_Process_Cycle__c = newPrcslst[i-1].Id;}else{/*No access*/}  }
                            else if(newPrcslst.size() > 2){
                                if(i+1 == newPrcslst.size()) break;
                                else{
                                    if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Next_Process_Cycle__c.isUpdateable()){newPrcslst[i].ERP7__Next_Process_Cycle__c = newPrcslst[i+1].Id;}else{/*No access*/}
                                    if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Previous_Process_Cycle__c.isUpdateable()){newPrcslst[i].ERP7__Previous_Process_Cycle__c = newPrcslst[i-1].Id; }else{/*No access*/} 
                                }
                            }
                        }
                    }
                    
                    if(Schema.sObjectType.ERP7__Process_Cycle__c.isUpdateable()){ update newPrcslst; }else{/*No access*/} 
                    
                    if(PcsIds.size() > 0 && newPcsIds.size() > 0 && WCIds.size() > 0){
                        system.debug('calling createAllPrcsrealted');
                        
                        //below code added by Arshad 08 Aug 2023
                        ERP7__Version__c oldVersion = new ERP7__Version__c();
                        if(String.isNotEmpty(versionId)) oldVersion = [Select Id, Name, ERP7__Active__c, ERP7__Default__c, ERP7__Category__c, ERP7__Product__c, ERP7__Start_Date__c, 
                                                                       ERP7__Status__c, ERP7__Type__c, ERP7__To_Date__c, ERP7__Process__c from ERP7__Version__c where Id =: versionId];
                        
                     //   ERP7__Version__c cloneVersion = new ERP7__Version__c();
                        
                        system.debug('oldVersion~>'+oldVersion);
                        
                        system.debug('versionId before~>'+versionId);
                        /*if(oldVersion.Id != null){
                            cloneVersion = oldVersion.clone(false, false, false, false);
                            cloneVersion.ERP7__Process__c = cloneProcess.Id;
                            insert cloneVersion;
                            versionId = cloneVersion.Id;
                        }*/
                        system.debug('newversionId after~>'+versionId);
                        
                        ERP7__Routing__c oldRouting = new ERP7__Routing__c();
                        
                        ERP7__Routing__c cloneRouting = new ERP7__Routing__c();
                        
                        String routingId = '';
                        
                        if(avilableroute.size() > 0){
                            oldRouting = avilableroute[0];
                            routingId = oldRouting.Id;
                            system.debug('routingId before~>'+routingId);
                            cloneRouting = oldRouting.clone(false, false, false, false);
                            cloneRouting.ERP7__BOM_Version__c = versionId;
                            cloneRouting.ERP7__Process__c = cloneProcess.Id;
                            insert cloneRouting;
                            routingId = cloneRouting.Id;
                        }
                        
                        system.debug('newroutingId after~>'+routingId);
                        //above code added by Arshad 08 Aug 2023
                        
                        createAllPrcsrealted(PcsIds,ProductId,versionId,routingId,newPcsIds);
                        
                        String wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Planner__c');
                        String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Work_Planner__c Where ERP7__WorkCenter__c =: WCIds Order by CreatedDate Asc limit 1000';
                        List< ERP7__Work_Planner__c > WPS = Database.query(query);
                        system.debug('WPS size~>'+WPS.size());
                        
                        wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Requirement__c');
                        wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Preferred_Resource__r.Name, ERP7__Preferred_Resource__r.ERP7__Employee__c, ERP7__Preferred_Resource__r.ERP7__Employee__r.Name, ERP7__Preferred_Resource__r.ERP7__Machine__c, ERP7__Preferred_Resource__r.ERP7__Machine__r.Name ';
                        utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Requirement__c');  
                        query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Requirement__c Where ERP7__Work_Planner__c In :WPS Order by CreatedDate Asc limit 1000';
                        List< ERP7__Resource_Requirement__c > RRS = Database.query(query);
                        system.debug('RRS size~>'+RRS.size());
                        
                        set<Id> rrId = new set<Id>();
                        List<ERP7__Resource_Group__c> rgroup = [Select Id,Name from ERP7__Resource_Group__c where ERP7__Process__c =:cloneProcess.Id or ERP7__Process_Cycle__c In:newPcsIds];
                        system.debug('new rgroup size~>'+rgroup.size());
                        
                        for(ERP7__Resource_Group__c rrg : rgroup) rrId.add(rrg.Id);
                        
                        system.debug('new rrId size~>'+rrId.size());
                        
                        List<ERP7__Resource__c> allresource = [Select Id,Name,ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__Resource_Group__c,ERP7__Resource_Group__r.Name from ERP7__Resource__c where ERP7__Resource_Group__c IN :rrId];
                        system.debug('new allresource size~>'+allresource.size());
                        
                        Map<Id,List<ERP7__Resource__c> > resMap = new Map<Id,List<ERP7__Resource__c> >();
                        for(ERP7__Resource__c rr :allresource){
                            if(resMap.containsKey(rr.ERP7__Resource_Group__c)){ resMap.get(rr.ERP7__Resource_Group__c).add(rr); }
                            else{ resMap.put(rr.ERP7__Resource_Group__c,new List<ERP7__Resource__c>{rr}); }
                        } 
                        
                        List<ERP7__Operation__c> operationlst = [Select Id,Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name,ERP7__Timer__c,ERP7__Is_Signature_Required__c,ERP7__Auto_Clock_In__c,ERP7__Process_Cycle__c 
                                                                 from ERP7__Operation__c where ERP7__Process_Cycle__c =:newPcsIds Order By CreatedDate Asc];
                        system.debug('new operationlst size~>'+operationlst.size());
                        
                        set<Id> operationIds = new set<Id>();
                        Map<id,List<ERP7__Operation__c>> opmap = new Map<id,List<ERP7__Operation__c>>();
                        for(ERP7__Operation__c opp : operationlst) {
                            operationIds.add(opp.Id);
                            if(opmap.containsKey(opp.ERP7__Process_Cycle__c)){ opmap.get(opp.ERP7__Process_Cycle__c).add(opp); }
                            else{ opmap.put(opp.ERP7__Process_Cycle__c,new List<ERP7__Operation__c>{opp}); }
                        }
                        
                        List<ERP7__BOM__c> bollst = [Select Id,Name,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Component__r.ProductCode,ERP7__BOM_Component__r.ERP7__Vendor_product_Name__c,ERP7__Process_Cycle__c,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c 
                                                     from ERP7__BOM__c where ERP7__Process_Cycle__c =:newPcsIds Order By CreatedDate Asc];
                        
                        system.debug('new bollst size~>'+bollst.size());
                        Map<id,List<ERP7__BOM__c>> BOMmap = new Map<id,List<ERP7__BOM__c>>();
                        for(ERP7__BOM__c bom : bollst) {
                            if(BOMmap.containsKey(bom.ERP7__Process_Cycle__c)){ BOMmap.get(bom.ERP7__Process_Cycle__c).add(bom); }
                            else{ BOMmap.put(bom.ERP7__Process_Cycle__c,new List<ERP7__BOM__c>{bom}); }
                        }
                        
                        List<ERP7__WIP_Link__c> wiplst = [Select Id,Name,ERP7__Process_Output_Product__c,ERP7__Process_Output_Product__r.Name,ERP7__Quantity_Unit_Of_Measure__c,ERP7__Quantity_Unit__c,ERP7__Type__c ,ERP7__Process_Cycle__c 
                                                          from ERP7__WIP_Link__c where ERP7__Process_Cycle__c =:newPcsIds  Order By CreatedDate Asc];
                        system.debug('new wiplst size~>'+wiplst.size());
                        Map<id,List<ERP7__WIP_Link__c>> WIPmap = new Map<id,List<ERP7__WIP_Link__c>>();
                        for(ERP7__WIP_Link__c wip : wiplst) {
                            if(WIPmap.containsKey(wip.ERP7__Process_Cycle__c)){ WIPmap.get(wip.ERP7__Process_Cycle__c).add(wip); }
                            else{ WIPmap.put(wip.ERP7__Process_Cycle__c,new List<ERP7__WIP_Link__c>{wip}); }
                        }
                        
                        List<ERP7__Checklist__c> chklst = [Select Id,Name,ERP7__Has_Checklist__c,ERP7__Result__c,ERP7__Action_Detail__c,ERP7__Process_Cycle__c,ERP7__Comply__c,ERP7__Operation__c,ERP7__Operation__r.Name 
                                                           from ERP7__Checklist__c where ERP7__Process_Cycle__c =:newPcsIds  Order By CreatedDate Asc];
                        system.debug('new chklst size~>'+chklst.size());
                        Map<id,List<ERP7__Checklist__c>> checkmap = new Map<id,List<ERP7__Checklist__c>>();
                        for(ERP7__Checklist__c chkl : chklst) {
                            if(checkmap.containsKey(chkl.ERP7__Process_Cycle__c)){ checkmap.get(chkl.ERP7__Process_Cycle__c).add(chkl); }
                            else{ checkmap.put(chkl.ERP7__Process_Cycle__c,new List<ERP7__Checklist__c>{chkl}); }
                        }
                        
                        List<ERP7__Media__c> medialst = [select Id,Name,ERP7__Operation__c,ERP7__Operation__r.Name,ERP7__Operation__r.ERP7__Process_Cycle__c 
                                                         from ERP7__Media__c where ERP7__Active__c = true and ERP7__Operation__c in :operationIds Order By CreatedDate Asc];
                        system.debug('new medialst size~>'+medialst.size());
                        Map<id,List<ERP7__Media__c>> Mediamap = new Map<id,List<ERP7__Media__c>>();
                        for(ERP7__Media__c med : medialst) {
                            if(Mediamap.containsKey(med.ERP7__Operation__r.ERP7__Process_Cycle__c)){ Mediamap.get(med.ERP7__Operation__r.ERP7__Process_Cycle__c).add(med); }
                            else{ Mediamap.put(med.ERP7__Operation__r.ERP7__Process_Cycle__c,new List<ERP7__Media__c>{med}); }
                        }
                        
                        List<Attachment> doclst = [select Id,Name,ParentId from Attachment where ParentId In :medialst Order By CreatedDate Asc];
                        system.debug('new doclst size~>'+doclst.size());
                        Map<id,List<Attachment>> Atttmap = new Map<id,List<Attachment>>();
                        for(Attachment att : doclst) {
                            if(Atttmap.containsKey(att.ParentId)){ Atttmap.get(att.ParentId).add(att); }
                            else{ Atttmap.put(att.ParentId,new List<Attachment>{att}); }
                        }
                        
                        for(ERP7__Process_Cycle__c prc : newPrcslst){
                            boolean show = true;
                            if(avilableroute.size() > 0) show = false;
                            comwrap wr = new comwrap();
                            if(opmap.containsKey(prc.Id)) wr.oprlst = opmap.get(prc.Id);
                            system.debug('BOMmap.containsKey(prc.Id) : '+BOMmap.containsKey(prc.Id));
                            if(BOMmap.containsKey(prc.Id)) wr.bomlst = BOMmap.get(prc.Id);
                            
                            if(WIPmap.containsKey(prc.Id)) wr.wiplinks = WIPmap.get(prc.Id);
                            if(checkmap.containsKey(prc.Id)) wr.checklists = checkmap.get(prc.Id);
                            if(Mediamap.values().size() > 0){
                                if(Mediamap.containsKey(prc.Id)){
                                    wr.med = Mediamap.get(prc.Id);
                                    for(ERP7__Media__c med : Mediamap.get(prc.Id)){
                                        if(Atttmap.containsKey(med.Id)) wr.attchment = Atttmap.get(med.Id);
                                    } 
                                }
                            }
                            if(rgroup.size() > 0){
                                wr.RRGroup = rgroup[0];
                                if(resMap.containsKey(rgroup[0].Id)) wr.availableResource = resMap.get(rgroup[0].Id);
                            }
                            
                            ProcessCyclewrap pprwr = new ProcessCyclewrap(prc,wr,show,oldVersion); // cloneVersion - changed by Arshad 08 Aug 2023
                            pcs.add(pprwr); 
                        }
                        system.debug('returning pcs size~>'+pcs.size());
                    }
                    else{
                        //nothing?
                    }
                    
                    /* for(ERP7__Process_Cycle__c prc : newPrcslst){
                    boolean show = true;
                    if(avilableroute.size() > 0) show = false;
                    ProcessCyclewrap pprwr = new ProcessCyclewrap(prc,getAll(prc.Id,''),show);
                    //pprwr.prcscycl = prc;
                    // pprwr.showsite = false;
                    pcs.add(pprwr); 
                    }*/
                }
            }
        }catch (Exception e){ 
            system.debug('Error~>'+e.getMessage()+' at ~> '+e.getStackTraceString()); 
            Database.rollback(sp);  
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
        return pcs;
    }
    
    
    @AuraEnabled 
    public static List<ProcessCyclewrap> cloneDataSave(String PId,String PRID,string VRId,String alldetails,List<string> mediaIds){
         Savepoint sp = Database.setSavepoint();
        List<ProcessCyclewrap> pcs = new List<ProcessCyclewrap>();
        try{
            if(alldetails != '' && alldetails != null) pcs = (List<ProcessCyclewrap>) JSON.deserialize(alldetails,List<ProcessCyclewrap>.class);
            Product2 prod = new Product2();
            system.debug('PId : '+PId);
            if(String.isNotEmpty(PId))  prod = [Select Id,Name,ProductCode from Product2 where Id=:PId limit 1];
            pcs[0].product = prod;
            ERP7__Process__c PR  = new ERP7__Process__c();
            if(String.isNotEmpty(PRID))  PR = [Select Id,Name,ERP7__Type__c,ERP7__Process_Description__c,ERP7__Other_Material_Cost__c,ERP7__Site__c,ERP7__Work_Center__c,ERP7__Work_Station__c,ERP7__Workforce_Cost__c,ERP7__Workforce_Hour_Required__c,RecordTypeId,ERP7__Process_Name__c,ERP7__Organisation__c  
                                               from ERP7__Process__c where Id= :PRID limit 1];
            
            ERP7__Process__c cloneProcess = PR.clone(false, false, false, false);
            string name = prod.name;
            if(name.length() > 45) name = prod.name.substring(0,45);
            cloneProcess.Name = 'Process '+ name+' '+system.today().format();
            if(Schema.SObjectType.ERP7__Process__c.isCreateable()){insert cloneProcess; pcs[0].process = cloneProcess;}else{/*No access*/}
            
            ERP7__Version__c oldVersion = new ERP7__Version__c();
            ERP7__Version__c cloneVersion = new ERP7__Version__c();
            if(String.isNotEmpty(VRId)) oldVersion = [Select Id, Name, ERP7__Active__c, ERP7__Default__c, ERP7__Category__c, ERP7__Product__c, ERP7__Start_Date__c, 
                                                                       ERP7__Status__c, ERP7__Type__c, ERP7__To_Date__c, ERP7__Process__c from ERP7__Version__c where Id =: VRId];
            
            if(oldVersion.Id != null){
                cloneVersion = oldVersion.clone(false, false, false, false);
                cloneVersion.Name = 'Version : '+system.today().format();
                cloneVersion.ERP7__Process__c = cloneProcess.Id;
                cloneVersion.ERP7__Default__c = false; // added by khaleeq on june 09 2025
                insert cloneVersion;
                pcs[0].version = cloneVersion;
            }
            ERP7__Routing__c oldRouting = new ERP7__Routing__c();
            List<ERP7__Routing__c> avilableroute = [Select Id, Name, ERP7__Auto_Stock_Allocation__c, ERP7__BOM_Version__c, ERP7__Finished_Products_Site__c, ERP7__Raw_Materials_Site__c, 
                                                    ERP7__Status__c, ERP7__Type__c, ERP7__Channel__c, ERP7__Product__c, ERP7__Process__c, RecordTypeId 
                                                    from ERP7__Routing__c where ERP7__Process__c =:PRID ]; //and ERP7__Product__c =:PId and ERP7__BOM_Version__c = :VRId
            
            ERP7__Routing__c cloneRouting = new ERP7__Routing__c();
            if(avilableroute.size() > 0){
                oldRouting = avilableroute[0];
                cloneRouting = oldRouting.clone(false, false, false, false);
                cloneRouting.ERP7__Product__c = PId;
                cloneRouting.ERP7__BOM_Version__c = cloneVersion.Id;
                cloneRouting.ERP7__Process__c = cloneProcess.Id;
                insert cloneRouting;
            }
            List<ERP7__Process_Cycle__c> prclst = new List<ERP7__Process_Cycle__c>();
            for(ProcessCyclewrap prcs : pcs){
                prcs.prcscycl.Id= null;
                prcs.prcscycl.ERP7__Process__c = cloneProcess.Id;
                prcs.prcscycl.ERP7__Next_Process_Cycle__c = null;
                prcs.prcscycl.ERP7__Previous_Process_Cycle__c = null;
                prclst.add(prcs.prcscycl);
            }
            if(prclst.size() > 0) insert prclst;
            List<ERP7__Operation__c> opertaion2upsert = new List<ERP7__Operation__c>();
            List<ERP7__Routing_Link__c> clonedRoute = new List<ERP7__Routing_Link__c>();
            Map<Id,ERP7__Routing_Link__c> PrcsRouteMap = new Map<Id,ERP7__Routing_Link__c>(); 
            Map<String,ERP7__Operation__c> operationMap = new Map<String,ERP7__Operation__c>(); 
            for(ProcessCyclewrap prcs : pcs){
                system.debug('prcs.prcscycl.Id 1: '+prcs.prcscycl.Id);
                if(prcs.prcscycl.Id != null){
                    ERP7__Routing_Link__c newRout = new ERP7__Routing_Link__c();
                    if(Schema.sObjectType.ERP7__Routing_Link__c.fields.Name.isCreateable()){newRout.Name = prcs.prcscycl.Name+ 'Routing Link';}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Routing_Link__c.fields.ERP7__Process_Cycle__c.isCreateable()){newRout.ERP7__Process_Cycle__c = prcs.prcscycl.Id;}else{/*No access*/}
                    clonedRoute.add(newRout);
                    PrcsRouteMap.put(prcs.prcscycl.Id,newRout);
                    comwrap comW = prcs.allRelateddetails;
                    for(ERP7__Operation__c opr : comW.oprlst){
                        opr.Id = null;
                        opr.ERP7__Routing__c = cloneRouting.Id;
                        opr.ERP7__Process_Cycle__c = prcs.prcscycl.Id;
                        opertaion2upsert.add(opr);
                        operationMap.put(opr.Name,opr);
                    }
                }
            }
            if(clonedRoute.size() > 0) insert clonedRoute;
            if(opertaion2upsert.size() > 0) insert opertaion2upsert;
            List<ERP7__BOM__c> clonedBOMs = new List<ERP7__BOM__c>();
            List<ERP7__Checklist__c> clonedchecks = new List<ERP7__Checklist__c>();
            List<ERP7__WIP_Link__c> clonedWips = new List<ERP7__WIP_Link__c>();
            List<ERP7__Media__c> clonedMedia = new List<ERP7__Media__c>();
            List<Attachment> clonedattachment = new List<Attachment>();
            Map<String,ERP7__Media__c> MediaMap = new Map<String,ERP7__Media__c>();
            Map<Id, List<Attachment>> attchlist = new Map<Id, List<Attachment>>();
            List<Attachment> attachments = [SELECT Id, Name, Body, ContentType, Description, ParentId,Parent.Name FROM Attachment WHERE ParentId IN :mediaIds];
            
            for (Attachment att : attachments) {
                if(attchlist.containskey(att.ParentId)) attchlist.get(att.ParentId).add(att);
                    else attchlist.put(att.ParentId, new List<Attachment>{att});
            }
            for(ProcessCyclewrap prcs : pcs){
                system.debug('prcs.prcscycl.Id 2: '+prcs.prcscycl.Id);
                if(prcs.prcscycl.Id != null){
                    comwrap comW = prcs.allRelateddetails;
                    if(comW.bomlst != null && comW.bomlst.size() > 0){
                        for(ERP7__BOM__c BOM : comW.bomlst){
                            system.debug('BOM : '+BOM);
                            if(BOM != null){
                                BOM.Id = null;
                                BOM.ERP7__Process_Cycle__c = prcs.prcscycl.Id;
                                BOM.ERP7__BOM_Product__c = PId;
                                BOM.ERP7__BOM_Version__c = cloneVersion.Id;
                                if(PrcsRouteMap.containsKey(prcs.prcscycl.Id)) BOM.ERP7__Routing_Link__c = PrcsRouteMap.get(prcs.prcscycl.Id).Id;
                                clonedBOMs.add(BOM);
                            }
                        }
                    }
                    system.debug('comW.checklists : '+comW.checklists);
                    if(comW.checklists != null && comW.checklists.size() > 0){
                        for(ERP7__Checklist__c chk : comW.checklists){
                            system.debug('chk : '+chk);
                            chk.Id = null;
                            chk.ERP7__Process_Cycle__c = prcs.prcscycl.Id;
                            clonedchecks.add(chk);
                        } 
                    }
                    system.debug('comW.wiplinks : '+comW.wiplinks);
                    if(comW.wiplinks != null && comW.wiplinks.size() > 0){
                        for(integer x = 0;x < comW.wiplinks.size(); x++){
                            comW.wiplinks[x].ERP7__Process_Cycle__c = prcs.prcscycl.Id;
                            comW.wiplinks[x].ERP7__Product__c =PId;
                            comW.wiplinks[x].ERP7__Version__c = cloneVersion.Id;
                            comW.wiplinks[x].Id = null;
                            clonedWips.add(comW.wiplinks[x]);
                        }
                    }
                    if(comW.med != null && comW.med.size() > 0){
                        for(ERP7__Media__c media : comW.med){
                            system.debug('media : '+media);
                            media.Id = null;
                            media.ERP7__Product__c = PId;
                            media.ERP7__Version__c = cloneVersion.Id;
                            if(operationMap.containsKey(media.ERP7__Operation__r.Name)) media.ERP7__Operation__c = operationMap.get(media.ERP7__Operation__r.Name).Id;
                            MediaMap.put(media.Name,media);
                            clonedMedia.add(media);
                        }  
                    }
                }
            }
            if(clonedBOMs.size() > 0) insert clonedBOMs;
            if(clonedchecks.size() > 0) insert clonedchecks;
            if(clonedWips.size() > 0) insert clonedWips;
            if(clonedMedia.size() > 0) insert clonedMedia;
            system.debug('MediaMap : '+MediaMap);
            if(attchlist.size() > 0){
                Map<Id, String> parentNamesMap = new Map<Id, String>();
                for (ERP7__Media__c obj : [SELECT Id, Name FROM ERP7__Media__c WHERE Id IN :attchlist.keySet()]) {
                    parentNamesMap.put((Id)obj.get('Id'), (String)obj.get('Name'));
                }
                for (List<Attachment> attList : attchlist.values()) {
                    for(Attachment att : attList){
                        if (mediaIds.contains(att.ParentId)) {
                            att.Id = null;
                            if (parentNamesMap.containsKey(att.ParentId)) {
                                String parentName = parentNamesMap.get(att.ParentId);
                                if (MediaMap.containsKey(parentName)) {
                                    att.ParentId = MediaMap.get(parentName).Id;
                                }
                            }
                            System.debug('att : ' + att);
                            clonedattachment.add(att);
                        }
                    } 
                }
            }
            system.debug('clonedattachment.size() : '+clonedattachment.size());
            if(clonedattachment.size() > 0) insert clonedattachment;
            
            return pcs;
        }
        catch (Exception e){ 
            system.debug('Error~>'+e.getMessage()+' at ~> '+e.getStackTraceString()); 
            Database.rollback(sp);  
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }
    public static void createAllPrcsrealted(set<Id> prcslst, String ProductId, String versionId, String routingId, set<Id> newPrcklIds){
        try{
            Product2 prod = [Select Id,Name from Product2 where Id =:ProductId];
            system.debug('createAllPrcsrealted called');
            system.debug('prcslst size~>'+prcslst.size());
            system.debug('prcslst~>'+prcslst);
            system.debug('ProductId~>'+ProductId);
            system.debug('versionId~>'+versionId);
            system.debug('routingId~>'+routingId);
            system.debug('newPrcklIds size~>'+newPrcklIds.size());
            system.debug('newPrcklIds~>'+newPrcklIds);
            
            List<ERP7__Process_Cycle__c> clonedProcesscycles = [Select Id,Name, ERP7__Description__c,ERP7__Work_Center__c,ERP7__Process__c from ERP7__Process_Cycle__c where Id In:newPrcklIds];
            system.debug('clonedProcesscycles size~>'+clonedProcesscycles.size());
            if(clonedProcesscycles.size() > 0){
                List<ERP7__Routing_Link__c> clonedRoute = new List<ERP7__Routing_Link__c>();
                
                for(ERP7__Process_Cycle__c pcykl : clonedProcesscycles){
                    ERP7__Routing_Link__c newRout = new ERP7__Routing_Link__c();
                    if(Schema.sObjectType.ERP7__Routing_Link__c.fields.Name.isCreateable()){newRout.Name = pcykl.Name+ 'Routing Link';}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Routing_Link__c.fields.ERP7__Process_Cycle__c.isCreateable()){newRout.ERP7__Process_Cycle__c = pcykl.Id;}else{/*No access*/}
                    clonedRoute.add(newRout);
                }
                string newProcessId = clonedProcesscycles[0].ERP7__Process__c;
                system.debug('newProcessId~>'+newProcessId);
                List<ERP7__Operation__c> oprlst = [Select Id,Name,ERP7__Process_Cycle__c from ERP7__Operation__c where ERP7__Process_Cycle__c IN:prcslst Order By ERP7__Process_Cycle__c];
                system.debug('existing oprlst size~>'+oprlst.size());
                List<ERP7__BOM__c> bomlst = [Select Id,Name,ERP7__Process_Cycle__c,ERP7__BOM_Product__c from ERP7__BOM__c where ERP7__Process_Cycle__c IN:prcslst Order By ERP7__Process_Cycle__c];
                system.debug('existing bomlst size~>'+bomlst.size());
                List<ERP7__Checklist__c> checklsts = [Select Id,Name,ERP7__Process_Cycle__c from ERP7__Checklist__c where ERP7__Process_Cycle__c IN:prcslst Order By ERP7__Process_Cycle__c];
                system.debug('existing checklsts size~>'+checklsts.size());
                Id MainProduct;
                if(bomlst.size() > 0) MainProduct = bomlst[0].ERP7__BOM_Product__c;
                system.debug('MainProduct~>'+MainProduct);
                List<ERP7__WIP_Link__c> wiplst = [Select Id,Name,ERP7__Process_Cycle__c,ERP7__Process_Output_Product__c from ERP7__WIP_Link__c where ERP7__Process_Cycle__c IN:prcslst Order By ERP7__Process_Cycle__c];
                system.debug('existing wiplst size~>'+wiplst.size());
                
                Map<String,List<ERP7__Operation__c>> PrcsOperMap = new Map<String,List<ERP7__Operation__c>>();
                Map<String,List<ERP7__BOM__c>> PrcsBOMMap = new Map<String,List<ERP7__BOM__c>>();
                Map<Id,ERP7__Routing_Link__c> PrcsRouteMap = new Map<Id,ERP7__Routing_Link__c>();
                Map<String,List<ERP7__WIP_Link__c>> PrcsWIPMap = new Map<String,List<ERP7__WIP_Link__c>>();
                Map<String,List<ERP7__Checklist__c>> PrcschklstMap = new Map<String,List<ERP7__Checklist__c>>();
                set<Id> WCIds = new set<Id>();
                String ProcessId = '';
                for(ERP7__Operation__c op : oprlst){
                    for(ERP7__Process_Cycle__c pc : [Select Id,Name,ERP7__Process__c,ERP7__Work_Center__c from ERP7__Process_Cycle__c where Id In :prcslst]){
                        if(op.ERP7__Process_Cycle__c == pc.Id){
                            if(pc.ERP7__Work_Center__c != null) WCIds.add(pc.ERP7__Work_Center__c);
                            if(pc.ERP7__Process__c != null) ProcessId = pc.ERP7__Process__c;
                            if(op.ERP7__Process_Cycle__c == pc.Id){
                                System.debug('pc.Name : '+pc.Name);
                                if(PrcsOperMap.containsKey(pc.Name)) {
                                    system.debug('if');
                                    PrcsOperMap.get(pc.Name).add(op);
                                }
                                else {
                                    system.debug('else');
                                    PrcsOperMap.put(pc.Name, new List<ERP7__Operation__c>{op});
                                }
                            }  
                        }
                    }
                }
                system.debug('existing PrcsOperMap~>'+PrcsOperMap);
                system.debug('existing routingId~>'+routingId);
                for(ERP7__Checklist__c ch : checklsts){
                    for(ERP7__Process_Cycle__c pc : [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id In :prcslst]){
                        if(ch.ERP7__Process_Cycle__c == pc.Id){
                            if(PrcschklstMap.containsKey(pc.Name)) PrcschklstMap.get(pc.Name).add(ch);
                            else PrcschklstMap.put(pc.Name, new List<ERP7__Checklist__c>{ch});
                        }
                    }
                }
                
                for(ERP7__BOM__c bom : bomlst){
                    for(ERP7__Process_Cycle__c pc : [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id In :prcslst]){
                        if(bom.ERP7__Process_Cycle__c == pc.Id){
                            if(PrcsBOMMap.containsKey(pc.Name)) PrcsBOMMap.get(pc.Name).add(bom);
                            else PrcsBOMMap.put(pc.Name, new List<ERP7__BOM__c>{bom});
                        }
                    }
                }
                
                for(ERP7__WIP_Link__c wip : wiplst){
                    for(ERP7__Process_Cycle__c pc : [Select Id,Name from ERP7__Process_Cycle__c where Id In :prcslst]){
                        if(wip.ERP7__Process_Cycle__c == pc.Id){
                            if(PrcsWIPMap.containsKey(pc.Name)) PrcsWIPMap.get(pc.Name).add(wip);
                            else PrcsWIPMap.put(pc.Name, new List<ERP7__WIP_Link__c>{wip});
                        }
                    }
                }
                
                List<ERP7__Operation__c> clonedOP = new List<ERP7__Operation__c>();
                
                for(ERP7__Operation__c opp : [Select Id,Name,ERP7__Description__c,ERP7__Quantity__c,ERP7__Required__c,ERP7__Sort__c,ERP7__Type__c,ERP7__Variable_Cost__c,ERP7__Work_Planner__c,ERP7__Routing__c,ERP7__Timer__c,ERP7__Fixed_Cost__c,
                                              ERP7__Auto_Clock_In__c,ERP7__Is_Signature_Required__c,ERP7__Label_Generator__c,ERP7__Next_Operation_No__c,ERP7__Operation_No__c,ERP7__Operation_Time__c,ERP7__Work_Center__c
                                              ,ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.Name
                                              from ERP7__Operation__c where ERP7__Process_Cycle__c IN:prcslst]){
                                                  for(ERP7__Process_Cycle__c pcykl : clonedProcesscycles){
                                                      if(PrcsOperMap.containsKey(pcykl.Name) && pcykl.Name == opp.ERP7__Process_Cycle__r.Name){
                                                          ERP7__Operation__c newOP = opp.clone(false, false, false, false);
                                                          if(String.isNotEmpty(routingId)){
                                                              newOP.ERP7__Routing__c = routingId; //added by Arshad 08 Aug 23
                                                          }
                                                          if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Process_Cycle__c.isCreateable()){newOP.ERP7__Process_Cycle__c = pcykl.Id;}else{/*No access*/}
                                                          clonedOP.add(newOP);
                                                      } 
                                                      
                                                  }
                                              }
                
                if(Schema.sObjectType.ERP7__Operation__c.isCreateable()){insert clonedOP;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Routing_Link__c.isCreateable()){insert clonedRoute;}else{/*No access*/}
                system.debug('clonedOP size after insert~>'+clonedOP.size());
                system.debug('clonedRoute size after insert~>'+clonedRoute.size());
                
                for(ERP7__Process_Cycle__c pcykl : clonedProcesscycles){
                    for(ERP7__Routing_Link__c rout : clonedRoute){
                        if(rout.ERP7__Process_Cycle__c == pcykl.Id){ PrcsRouteMap.put(pcykl.Id,rout); } 
                    }
                }
                
                List<ERP7__BOM__c> clonedBOMs = new List<ERP7__BOM__c>();
                for(ERP7__BOM__c boms : [Select Id,Name,ERP7__Cost_Price__c,ERP7__Type__c,ERP7__Process_Cycle__r.Name,ERP7__Status__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c from ERP7__BOM__c where ERP7__Process_Cycle__c IN :prcslst Order By ERP7__Sort__c]){
                    for(ERP7__Process_Cycle__c prkl : clonedProcesscycles){
                        if(PrcsBOMMap.containsKey(prkl.Name) && prkl.Name == boms.ERP7__Process_Cycle__r.Name){
                            ERP7__BOM__c newBOM = boms.clone(false, false, false, false);
                            if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isCreateable()){newBOM.ERP7__Process_Cycle__c = prkl.Id;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable()){newBOM.ERP7__BOM_Product__c = ProductId;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable()){newBOM.ERP7__BOM_Version__c = versionId;}else{/*No access*/}
                            if(PrcsRouteMap.containsKey(prkl.Id)) {
                                if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isCreateable()){newBOM.ERP7__Routing_Link__c = PrcsRouteMap.get(prkl.Id).Id;}else{/*No access*/}
                            }
                            clonedBOMs.add(newBOM);
                        }
                        
                    }
                }
                
                if(Schema.sObjectType.ERP7__BOM__c.isCreateable()){insert clonedBOMs;}else{/*No access*/}
                system.debug('clonedBOMs size after insert~>'+clonedBOMs.size());
                
                List<ERP7__Checklist__c> clonedchecklst = new List<ERP7__Checklist__c>();
                for(ERP7__Checklist__c chk : [Select Id,Name,ERP7__Action_Detail__c,ERP7__Result__c,ERP7__Comply__c,ERP7__Notes__c,ERP7__Action_Type__c,ERP7__Status__c ,ERP7__Process_Cycle__r.Name
                                              from ERP7__Checklist__c where ERP7__Process_Cycle__c IN:prcslst]){
                                                  for(ERP7__Process_Cycle__c prkl : clonedProcesscycles){
                                                      if(PrcschklstMap.containsKey(prkl.Name) && prkl.Name == chk.ERP7__Process_Cycle__r.Name){
                                                          ERP7__Checklist__c newchcek =  chk.clone(false, false, false, false);
                                                          if(Schema.sObjectType.ERP7__Checklist__c.fields.ERP7__Process_Cycle__c.isCreateable()){newchcek.ERP7__Process_Cycle__c = prkl.Id;}else{/*No access*/}
                                                          clonedchecklst.add(newchcek);
                                                      }
                                                  }
                                              }
                
                if(Schema.sObjectType.ERP7__Checklist__c.isCreateable()){insert clonedchecklst;}else{/*No access*/}
                system.debug('clonedchecklst size after insert~>'+clonedchecklst.size());
                
                List<ERP7__WIP_Link__c> clonedWIPs = new List<ERP7__WIP_Link__c>();
                for(ERP7__WIP_Link__c wiplnk : [Select Id,Name,ERP7__Bypass_quantity__c,ERP7__Finished_Products_Site__c,ERP7__Process_Output_Product__c,ERP7__Quantity_Unit_Of_Measure__c,ERP7__Quantity_Unit__c,ERP7__Type__c ,ERP7__Process_Cycle__r.Name
                                                from ERP7__WIP_Link__c where ERP7__Process_Cycle__c IN:prcslst]){
                                                    for(ERP7__Process_Cycle__c prkl : clonedProcesscycles){
                                                        if(PrcsWIPMap.containsKey(prkl.Name) && wiplnk.ERP7__Process_Output_Product__c != MainProduct && prkl.Name == wiplnk.ERP7__Process_Cycle__r.Name){
                                                            ERP7__WIP_Link__c newip = wiplnk.clone(false, false, false, false);
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Process_Cycle__c.isCreateable()){newip.ERP7__Process_Cycle__c = prkl.Id;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Product__c.isCreateable()){newip.ERP7__Product__c = ProductId;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Version__c.isCreateable()){newip.ERP7__Version__c = versionId;}else{/*No access*/}
                                                            clonedWIPs.add(newip);
                                                        }
                                                        if(wiplnk.ERP7__Process_Output_Product__c == MainProduct && PrcsWIPMap.containsKey(prkl.Name) && prkl.Name == wiplnk.ERP7__Process_Cycle__r.Name){
                                                            ERP7__WIP_Link__c newip =  new ERP7__WIP_Link__c();
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Finished_Products_Site__c.isCreateable()){newip.ERP7__Finished_Products_Site__c = wiplnk.ERP7__Finished_Products_Site__c;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Process_Output_Product__c.isCreateable()){newip.ERP7__Process_Output_Product__c = ProductId;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Quantity_Unit__c.isCreateable()){newip.ERP7__Quantity_Unit__c = wiplnk.ERP7__Quantity_Unit__c;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Quantity_Unit_Of_Measure__c.isCreateable()){newip.ERP7__Quantity_Unit_Of_Measure__c =wiplnk.ERP7__Quantity_Unit_Of_Measure__c;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Type__c.isCreateable()){newip.ERP7__Type__c = wiplnk.ERP7__Type__c;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Process_Cycle__c.isCreateable()){newip.ERP7__Process_Cycle__c = prkl.Id;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Product__c.isCreateable()){newip.ERP7__Product__c = ProductId;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Version__c.isCreateable()){newip.ERP7__Version__c = versionId;}else{/*No access*/}
                                                            if(Schema.sObjectType.ERP7__WIP_Link__c.fields.Name.isCreateable()){newip.Name = prod.Name;}else{/*No access*/}
                                                            clonedWIPs.add(newip);
                                                        }
                                                    }
                                                }
                
                if(Schema.sObjectType.ERP7__WIP_Link__c.isCreateable()){insert clonedWIPs;}else{/*No access*/}
                system.debug('clonedWIPs size after insert~>'+clonedWIPs.size());
                
                List<ERP7__Work_Planner__c> WPs = [Select Id,Name,ERP7__Product__c,ERP7__Status__c,ERP7__Is_Manufacturing__c ,ERP7__Description__c ,ERP7__Is_Service__c,ERP7__WorkCenter__c,ERP7__WorkCenter__r.Name from  ERP7__Work_Planner__c where ERP7__WorkCenter__c In : WCIds AND (ERP7__Process__c=:ProcessId or ERP7__Process_Cycle__c=:prcslst)];
                system.debug('existing WPs size~>'+WPs.size());
                
                List<ERP7__Work_Planner__c> newWPs = new List<ERP7__Work_Planner__c>(); 
                string WCName = '',WCID = '';
                if(WPs.size() > 0){
                    if(WPs[0].ERP7__WorkCenter__c != null){
                        WCName = WPs[0].ERP7__WorkCenter__r.Name;  
                        WCID = WPs[0].ERP7__WorkCenter__c;
                    }
                }
                
                for(ERP7__Work_Planner__c wp : WPs){
                    ERP7__Work_Planner__c newwp = new ERP7__Work_Planner__c(Name =wp.Name,ERP7__Process__c = newProcessId,ERP7__Status__c = wp.ERP7__Status__c,ERP7__Is_Manufacturing__c = wp.ERP7__Is_Manufacturing__c,ERP7__Is_Service__c = wp.ERP7__Is_Service__c,ERP7__Description__c = wp.ERP7__Description__c,ERP7__WorkCenter__c=wp.ERP7__WorkCenter__c);
                    if((wp.ERP7__Product__c != null || wp.ERP7__Product__c != '') && Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__Product__c.isCreateable()){ newwp.ERP7__Product__c=ProductId; }else{/*No access*/}
                    newWPs.add(newwp);
                }
                
                if(Schema.sObjectType.ERP7__Work_Planner__c.isCreateable()){insert newWPs;}else{/*No access*/}
                system.debug('newWPs size after insert~>'+newWPs.size());
                
                if(WCID != null && WCID != ''){
                    ERP7__Capacity_Planner__c newCP = new ERP7__Capacity_Planner__c();  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.Name.isCreateable()){newCP.Name = 'CP '+WCName;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.ERP7__Work_Center__c.isCreateable()){newCP.ERP7__Work_Center__c = WCID;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.ERP7__Start_Date__c.isCreateable()){newCP.ERP7__Start_Date__c = system.today();}else{/*No access*/}  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.ERP7__End_Date__c.isCreateable()){newCP.ERP7__End_Date__c=System.today().addYears(1);}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Capacity_Planner__c.isCreateable()){insert newCP;}else{/*No access*/}
                    system.debug('newCP after insert~>'+newCP);
                }
                
                List<ERP7__Resource_Group__c> rgroup = [Select Id,Name,ERP7__Billing_Price__c,ERP7__Default_Team__c,ERP7__End_Date__c,ERP7__Is_Manufacturing__c,ERP7__Is_Service__c,ERP7__Site__c,ERP7__Start_Date__c,ERP7__Skill__c from ERP7__Resource_Group__c where ERP7__Process__c =:ProcessId or ERP7__Process_Cycle__c IN:prcslst];
                system.debug('existing rgroup size~>'+rgroup.size());
                
                List<ERP7__Resource_Group__c> newRRgroup = new List<ERP7__Resource_Group__c>();
                
                for(ERP7__Resource_Group__c rrg : rgroup){
                    ERP7__Resource_Group__c newRgroup = rrg.clone(false, false, false, false);
                    if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__Process__c.isCreateable()){ newRgroup.ERP7__Process__c = newProcessId; }else{/*No access*/}
                    newRRgroup.add(newRgroup);
                }
                
                if(Schema.sObjectType.ERP7__Resource_Group__c.isCreateable()){insert newRRgroup;}else{/*No access*/}
                system.debug('newRRgroup size after insert~>'+newRRgroup.size());
                
                List<ERP7__Resource_Requirement__c> rr = [Select Id,Name,ERP7__Resource_Group__r.Name,ERP7__Runtime__c,ERP7__Runtime_Cost__c,ERP7__Type__c,ERP7__Work_Planner__r.Name from ERP7__Resource_Requirement__c where ERP7__Work_Planner__c In:WPs and ERP7__Resource_Group__c IN:rgroup];
                system.debug('existing rr size~>'+rr.size());
                
                List<ERP7__Resource_Requirement__c> newRRlst = new List<ERP7__Resource_Requirement__c>();
                for(ERP7__Resource_Requirement__c req : rr){
                    for(ERP7__Resource_Group__c rrgnew : newRRgroup){
                        if(rrgnew.Name == req.ERP7__Resource_Group__r.Name) {
                            ERP7__Resource_Requirement__c newRR = new ERP7__Resource_Requirement__c();
                            if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.Name.isCreateable()){newRR.Name = req.Name;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Runtime__c.isCreateable()){newRR.ERP7__Runtime__c = req.ERP7__Runtime__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Runtime_Cost__c.isCreateable()){newRR.ERP7__Runtime_Cost__c = req.ERP7__Runtime_Cost__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Type__c.isCreateable()){newRR.ERP7__Type__c = req.ERP7__Type__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Resource_Group__c.isCreateable()){newRR.ERP7__Resource_Group__c = rrgnew.Id;}else{/*No access*/}
                            for(ERP7__Work_Planner__c newwpsss : WPs){
                                if(newwpsss.Name == req.ERP7__Work_Planner__r.Name){ if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Work_Planner__c.isCreateable()){newRR.ERP7__Work_Planner__c = newwpsss.Id;}else{/*No access*/}}
                            }
                            newRRlst.add(newRR);
                        }
                    } 
                }
                if(Schema.sObjectType.ERP7__Resource_Requirement__c.isCreateable()){insert newRRlst;}else{/*No access*/}
                system.debug('newRRlst size after insert~>'+newRRlst.size());
                
                List<ERP7__Resource__c> newReslst = new List<ERP7__Resource__c> ();
                List<ERP7__Resource__c> res = [Select  Id,Name,ERP7__Break_End_Time__c,ERP7__Break_Start_Time__c,ERP7__Employee__c,ERP7__End_Date__c,ERP7__Friday__c,ERP7__Fri_Break_End_Time__c,ERP7__Fri_Break_Start_Time__c  ,ERP7__Fri_End_Time__c,ERP7__Fri_Start_Time__c,ERP7__Machine__c,ERP7__Monday__c,ERP7__Mon_Break_End_Time__c,ERP7__Mon_Break_Start_Time__c,
                                               ERP7__Mon_End_Time__c,ERP7__Mon_Start_Time__c,ERP7__Override_Holidays__c,RecordTypeId,ERP7__Resource_Group__r.Name,ERP7__Saturday__c,ERP7__Sat_Break_End_Time__c,ERP7__Sat_Break_Start_Time__c,ERP7__Sat_End_Time__c,ERP7__Sat_Start_Time__c,
                                               ERP7__Shift_End_Time__c,ERP7__Start_Date__c,ERP7__Sunday__c,ERP7__Sun_Break_End_Time__c,ERP7__Sun_Break_Start_Time__c,ERP7__Sun_End_Time__c,ERP7__Supervisor_User__c,ERP7__Team__c
                                               ,ERP7__Thursdays__c,ERP7__Thu_Break_End_Time__c,ERP7__Thu_Break_Start_Time__c,ERP7__Thu_End_Time__c,ERP7__Thu_Start_Time__c,ERP7__Tuesday__c,ERP7__Tue_Break_End_Time__c,ERP7__Tue_Break_Start_Time__c,ERP7__Tue_End_Time__c,ERP7__Tue_Start_Time__c,
                                               ERP7__User__c,ERP7__Wednesday__c,ERP7__Wed_Break_End_Time__c,ERP7__Wed_Break_Start_Time__c,ERP7__Wed_End_Time__c,ERP7__Wed_Start_Time__c
                                               from ERP7__Resource__c where ERP7__Resource_Group__c IN:rgroup limit 100];
                system.debug('existing res size~>'+res.size());
                
                for(ERP7__Resource__c resource : res){
                    for(ERP7__Resource_Group__c rrgs : newRRgroup){
                        ERP7__Resource__c newres = resource.clone(false);
                        if(rrgs.Name == resource.ERP7__Resource_Group__r.Name) newres.ERP7__Resource_Group__c = rrgs.Id;
                        newReslst.add(newres);
                    }
                    
                }
                
                List<ERP7__Media__c> medialst = [Select Id,Name,ERP7__Active__c,ERP7__Description__c,ERP7__Type__c,ERP7__Product__c,ERP7__Version__c,ERP7__Operation__r.Name from ERP7__Media__c where ERP7__Operation__c IN: oprlst];
                system.debug('existing medialst from existing oprlst size~>'+medialst.size());
                
                List<Attachment> attchlst = [Select Id,Name,body,ContentType,Description,ParentId from Attachment where ParentId IN:medialst];
                system.debug('existing attchlst from existing medialst size~>'+attchlst.size());
                
                Map<String,List<Attachment>> medAttchMap = new Map<String,List<Attachment>>();
                for(ERP7__Media__c med : medialst){
                    for(Attachment att : attchlst){
                        if(att.ParentId == med.Id){
                            if(medAttchMap.containsKey(med.Name)) medAttchMap.get(med.Name).add(att);
                            else medAttchMap.put(med.Name, new List<Attachment>{att});
                        }
                    }
                }
                
                List<ERP7__Media__c> newmedialst = new List<ERP7__Media__c>();
                List<Attachment> newattchment = new List<Attachment>();
                for(ERP7__Media__c med : medialst){
                    for(ERP7__Operation__c pop : clonedOP){
                        if(pop.Name == med.ERP7__Operation__r.Name){
                            ERP7__Media__c newmed = new ERP7__Media__c();
                            if(Schema.sObjectType.ERP7__Media__c.fields.Name.isCreateable()){newmed.Name=med.Name;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Media__c.fields.ERP7__Active__c.isCreateable()){newmed.ERP7__Active__c = med.ERP7__Active__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Media__c.fields.ERP7__Description__c.isCreateable()){newmed.ERP7__Description__c=med.ERP7__Description__c;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Media__c.fields.ERP7__Type__c.isCreateable()){newmed.ERP7__Type__c = med.ERP7__Type__c;}else{/*No access*/}
                            if(med.ERP7__Product__c != null && Schema.sObjectType.ERP7__Media__c.fields.ERP7__Product__c.isCreateable()){ newmed.ERP7__Product__c = ProductId; }else{/*No access*/}
                            if(med.ERP7__Version__c != null && Schema.sObjectType.ERP7__Media__c.fields.ERP7__Version__c.isCreateable()){ newmed.ERP7__Version__c = versionId; }else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Media__c.fields.ERP7__Operation__c.isCreateable()){newmed.ERP7__Operation__c = pop.Id;}else{/*No access*/}
                            newmedialst.add(newmed);
                        }
                    }
                }
                
                if(Schema.sObjectType.ERP7__Media__c.isCreateable()){insert  newmedialst;}else{/*No access*/}
                system.debug('newmedialst size after insert~>'+newmedialst.size());
                
                for(Attachment att : attchlst){
                    for(ERP7__Media__c nmed : newmedialst){
                        if(medAttchMap.containsKey(nmed.Name)){
                            Attachment newatt = new Attachment();
                            if(Schema.sObjectType.Attachment.fields.Name.isCreateable()){newatt.Name = att.Name;}else{/*No access*/}
                            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){newatt.Body = att.Body;}else{/*No access*/}
                            if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){newatt.ContentType  = att.ContentType;}else{/*No access*/}
                            if(Schema.sObjectType.Attachment.fields.Description.isCreateable()){newatt.Description = att.Description;}else{/*No access*/}
                            if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable()){newatt.ParentId = nmed.Id;}else{/*No access*/}
                            newattchment.add(newatt);
                        }
                    }
                }
                
                if(Schema.sObjectType.Attachment.isCreateable()){insert newattchment;}else{/*No access*/}
                system.debug('newattchment size after insert~>'+newattchment.size());
            } 
        }catch(Exception e){
            system.debug('Error~>'+e.getMessage()+' at~> '+e.getStackTraceString());
            //throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> SaveNewPrcycle(String NewPrc,String versionId){
        List<ProcessCyclewrap> pcs = new List<ProcessCyclewrap>();
        try{
            
            ERP7__Process_Cycle__c newprcycle = (ERP7__Process_Cycle__c) JSON.deserialize(NewPrc, ERP7__Process_Cycle__c.class);
            if(Schema.sObjectType.ERP7__Process_Cycle__c.isCreateable()){insert newprcycle;}else{/*No access*/}
            ERP7__Routing_Link__c newRoutingLnk = new ERP7__Routing_Link__c();
            if(Schema.sObjectType.ERP7__Routing_Link__c.fields.Name.isCreateable()){newRoutingLnk.Name = newprcycle.Name +' Routing Link';}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Routing_Link__c.fields.ERP7__Process_Cycle__c.isCreateable()){newRoutingLnk.ERP7__Process_Cycle__c = newprcycle.Id;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Routing_Link__c.isCreateable()){insert newRoutingLnk;}else{/*No access*/}
            String processId = newprcycle.ERP7__Process__c;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:processId Order By CreatedDate ASC limit 1000];
            if(prclst.size() == 0)  prclst.add(newprcycle);  
            if(prclst.size() > 1){
                Integer i;
                for(i=0;i<prclst.size();i++) {
                    if(i == 0){ if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Next_Process_Cycle__c.isUpdateable()){prclst[i].ERP7__Next_Process_Cycle__c = prclst[i+1].Id;}else{/*No access*/} }
                    else if(i == prclst.size()){if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Previous_Process_Cycle__c.isUpdateable()){ prclst[i].ERP7__Previous_Process_Cycle__c = prclst[i-1].Id;}else{/*No access*/}  }
                    else if(prclst.size() > 2){
                        if(i+1 == prclst.size()) break;
                        else{
                            if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Next_Process_Cycle__c.isUpdateable()){prclst[i].ERP7__Next_Process_Cycle__c = prclst[i+1].Id;}else{/*No access*/}
                            if(Schema.sObjectType.ERP7__Process_Cycle__c.fields.ERP7__Previous_Process_Cycle__c.isUpdateable()){ prclst[i].ERP7__Previous_Process_Cycle__c = prclst[i-1].Id;  }else{/*No access*/}
                        }
                    }
                }
            }
            if(Schema.sObjectType.ERP7__Process_Cycle__c.isUpdateable()){update prclst; }else{/*No access*/}
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcs = alldetails(processId,WCIds,versionId,'');
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcs;
        
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> updatePrcycle(String editPrc,String versionId){
        List<ProcessCyclewrap> pcs = new List<ProcessCyclewrap>();
        ERP7__Process_Cycle__c editresult = (ERP7__Process_Cycle__c) JSON.deserialize(editPrc, ERP7__Process_Cycle__c.class);
        if(Schema.sObjectType.ERP7__Process_Cycle__c.isUpdateable()){update editresult;}else{/*No access*/}
        String processId = editresult.ERP7__Process__c;
        if(processId !='' && processId != null){
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Sort__c, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:processId Order By ERP7__Sort__c limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcs = alldetails(processId,WCIds,versionId,'');  
        }
        return pcs;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> deletePrcycle(String PrcssrecordId,String versionId){
        List<ProcessCyclewrap> pcs = new List<ProcessCyclewrap>();
        
        try{
            ERP7__Process_Cycle__c todeletePr = [select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:PrcssrecordId];
            String processId = todeletePr.ERP7__Process__c;
            if(Schema.sObjectType.ERP7__Process_Cycle__c.isDeletable()) delete todeletePr;
            if(processId !='' && processId != null){
                List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:processId Order By CreatedDate ASC limit 1000];
                
                List<Id> WCIds = new List<Id>();
                for(ERP7__Process_Cycle__c pp: prclst) {
                    WCIds.add(pp.ERP7__Work_Center__c);
                }
                pcs = alldetails(processId,WCIds,versionId,'');    
            }
            //if(pcs.size() > 0) pcs[0].isselected =true;
            
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcs;
        
    }
    
    @AuraEnabled
    public static Boolean checkDefaultVersion(String Id){ //created by khaleeq on 09 june 2025 [for having only one version as default]
        system.debug('product id --'+Id);
        Productwrap proWrap = new Productwrap();
        try{
            List<ERP7__Version__c> defaultVersion = [SELECT Id, ERP7__Product__c FROM ERP7__Version__c WHERE ERP7__Default__c = true AND ERP7__Active__c = true AND ERP7__Product__c =: Id];
            if(defaultVersion.size() > 0){
                proWrap.errmsg = 'There is already an default version. PLease uncheck that to create a new default version'; // no use just setting this in JS 
                return true;
            }            
        }catch(Exception e){
            system.debug('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return false;
    }
    
    @AuraEnabled
    public static PcandVer createRouting(String ProdId,String FinshSiteId,String RawsiteId,String VersionId,String ProcessId,String NewVersion){
        PcandVer pvr = new PcandVer();
        ERP7__Process__c Pr = new ERP7__Process__c();
        ERP7__Version__c vrr = new ERP7__Version__c();
        try{
            Boolean routingexists = false;
            Product2 Prod = [Select Id,Name from Product2 where Id=:ProdId];
            
            List<ERP7__Routing__c> availablerouting =new List<ERP7__Routing__c>();
            if(ProcessId !='' && ProcessId != null && VersionId != '' && VersionId != null) availablerouting =[Select Id,Name from ERP7__Routing__c where ERP7__Product__c =:ProdId and ERP7__BOM_Version__c =:VersionId and ERP7__Process__c =:ProcessId and ERP7__Process__c != null];
            if(availablerouting.size() > 0){ routingexists = true; } 
            else{
                string chanId =getChannel();
                
                if(ProcessId == '' || ProcessId == null) {
                    Id rTypePrMO; rTypePrMO = Schema.SObjectType.ERP7__Process__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_Process').getRecordTypeId();
                    Pr = new ERP7__Process__c();
                    if(Schema.sObjectType.ERP7__Process__c.fields.Name.isCreateable()){Pr.Name=Prod.Name+'Process';}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Process__c.fields.ERP7__Type__c.isCreateable()){Pr.ERP7__Type__c='Process Manufacturing';}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Process__c.fields.RecordTypeId.isCreateable() && rTypePrMO != null){Pr.RecordTypeId = rTypePrMO; }else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Process__c.isCreateable()){insert Pr;}else{/*No access*/}
                    ProcessId = Pr.Id;
                    pvr.pr = Pr;
                }
                
                if(VersionId == '' || VersionId == null){
                    ERP7__Version__c newv = (ERP7__Version__c) JSON.deserialize(NewVersion, ERP7__Version__c.class);
                    ERP7__Version__c ver =new ERP7__Version__c();
                    if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Active__c.isCreateable()){ver.ERP7__Active__c = true;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Default__c.isCreateable()){ver.ERP7__Default__c = newv.ERP7__Default__c ;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Category__c.isCreateable()){ver.ERP7__Category__c = 'Production';}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isCreateable()){ver.ERP7__Product__c = Prod.Id;}else{/*No access*/}
                    if(newv.ERP7__Start_Date__c == null){ if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Start_Date__c.isCreateable()){ver.ERP7__Start_Date__c = system.Today();}else{/*No access*/}}
                    else{ if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Start_Date__c.isCreateable()){ver.ERP7__Start_Date__c =newv.ERP7__Start_Date__c; }else{/*No access*/}}
                    if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Status__c.isCreateable()){ver.ERP7__Status__c = 'Certified';}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Type__c.isCreateable()){ver.ERP7__Type__c = 'Production';}else{/*No access*/}
                    if(newv.ERP7__To_Date__c == null){ if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__To_Date__c.isCreateable()){ver.ERP7__To_Date__c = Date.newInstance(system.today().year()+5, system.today().month(), system.today().Day());}else{/*No access*/}}
                    else{ if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__To_Date__c.isCreateable()){ver.ERP7__To_Date__c = newv.ERP7__To_Date__c;}else{/*No access*/}}
                    if(newv.Name == '' || newv.Name == null){ if(Schema.sObjectType.ERP7__Version__c.fields.Name.isCreateable()){ver.Name ='Version '+Prod.Name;}else{/*No access*/} }
                    else{ if(Schema.sObjectType.ERP7__Version__c.fields.Name.isCreateable()){ver.Name = newv.Name;}else{/*No access*/}}
                    if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Process__c.isCreateable()){ver.ERP7__Process__c = ProcessId;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Version__c.isCreateable()){insert ver;}else{/*No access*/}
                    pvr.vr = ver;
                    VersionId = ver.Id; 
                }
                
                ERP7__Routing__c newrouting = new ERP7__Routing__c();
                if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Auto_Stock_Allocation__c.isCreateable()){newrouting.ERP7__Auto_Stock_Allocation__c = true; }else{/*No access*/}
                if(Schema.sObjectType.ERP7__Routing__c.fields.Name.isCreateable()){newrouting.Name = 'Routing '+Prod.Name; }else{/*No access*/}
                if(VersionId != '' && VersionId != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__BOM_Version__c.isCreateable()){ newrouting.ERP7__BOM_Version__c = VersionId;}else{/*No access*/}
                if(FinshSiteId != '' && FinshSiteId != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Finished_Products_Site__c.isCreateable()){ newrouting.ERP7__Finished_Products_Site__c = FinshSiteId;}else{/*No access*/}
                if(RawsiteId != '' && RawsiteId != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Raw_Materials_Site__c.isCreateable()){ newrouting.ERP7__Raw_Materials_Site__c = RawsiteId;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Status__c.isCreateable()){newrouting.ERP7__Status__c ='Certified';}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Type__c.isCreateable()){newrouting.ERP7__Type__c = 'Parallel';}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Channel__c.isCreateable()){newrouting.ERP7__Channel__c = chanId;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Product__c.isCreateable()){newrouting.ERP7__Product__c = Prod.Id;}else{/*No access*/}
                
                Id rTypeMO; rTypeMO = Schema.SObjectType.ERP7__Routing__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_Routing').getRecordTypeId();                
                
                if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Process__c.isCreateable()){newrouting.ERP7__Process__c = ProcessId;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Routing__c.fields.RecordTypeId.isCreateable() && rTypeMO != null){newrouting.RecordTypeId = rTypeMO;}else{/*No access*/}
                if((newrouting.ERP7__Process__c != null || newrouting.ERP7__Process__c != '') && Schema.sObjectType.ERP7__Routing__c.isCreateable()){ insert newrouting;}else{/*No access*/}
                
                Id routeId = newrouting.Id;
                if(routeId != null){
                    List<ERP7__Operation__c> operationlist = [Select Id,Name,ERP7__Routing__c from ERP7__Operation__c where ERP7__Process_Cycle__r.ERP7__Process__c =:ProcessId];
                    if(operationlist.size() > 0){
                        for(ERP7__Operation__c op : operationlist){
                            op.ERP7__Routing__c = routeId;
                        }
                        update operationlist;
                    }
                }
            }
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pvr;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> saveOperation(String Operation,String versionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__Operation__c opp = (ERP7__Operation__c) JSON.deserialize(Operation, ERP7__Operation__c.class);
            String ProcesscycleId = opp.ERP7__Process_Cycle__c;
            List<ERP7__Process_Cycle__c> currPR = [Select Id,Name,ERP7__Process__c,ERP7__Work_Center__c from ERP7__Process_Cycle__c  where Id=:ProcesscycleId limit 1];
            string ProcsId =currPR[0].ERP7__Process__c;
            List<ERP7__Routing__c> rout = [ Select Id,Name,ERP7__Process__c,ERP7__Product__c from ERP7__Routing__c where ERP7__Process__c = :ProcsId Limit 1 ];
            //if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Timer__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Timer__c.isUpdateable()){opp.ERP7__Timer__c = true;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Label_Generator__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Label_Generator__c.isUpdateable()){opp.ERP7__Label_Generator__c = true;}else{/*No access*/}
            //if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Is_Signature_Required__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Is_Signature_Required__c.isUpdateable()){opp.ERP7__Is_Signature_Required__c = true;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isUpdateable()){opp.ERP7__Routing__c = rout[0].Id;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Work_Center__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Work_Center__c.isUpdateable()){opp.ERP7__Work_Center__c =  currPR[0].ERP7__Work_Center__c;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Operation__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.isUpdateable()){upsert opp;}else{/*No access*/}
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcsId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcsId,WCIds,versionId,''); 
            
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
    }
    
    @AuraEnabled
    public static ProdCC getProductUOM(String ProductId){
        ProdCC retProduct = new ProdCC();
        if(ProductId != null && ProductId != ''){
            List<Product2> prod = [Select Id,Name,QuantityUnitOfMeasure from Product2 where Id=:ProductId limit 1];
            List<ERP7__Cost_Card__c> CC = [Select Id,Name,ERP7__Cost__c from ERP7__Cost_Card__c where ERP7__Product__c=:ProductId and ERP7__Cost__c != null and ERP7__Active__c = true and ERP7__Default__c = true and ERP7__Start_Date__c <=:System.today() and ERP7__End_Date__c >= : System.today() and ERP7__Supplier__c = null Order By ERP7__Default__c ];
            
            if(prod.size() > 0){
                retProduct.prod = prod[0];
            }
            if(CC.size() > 0){
                retProduct.costCard = CC[0];  
            }
        }
        return retProduct;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> saveBOM(String BOM,String versionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        String version = versionId;
        try{
            List<ERP7__BOM__c> listbom = (List<ERP7__BOM__c>) JSON.deserialize(BOM, List<ERP7__BOM__c>.class);
            String ProcesscycleId = '';
            string ProcsId = '';
            List<ERP7__Process_Cycle__c> prclst;
            system.debug('listbom : '+listbom.size());
            if(listbom.size() > 0){
                
                ProcesscycleId = listbom[0].ERP7__Process_Cycle__c;
                system.debug('ProcesscycleId : '+ProcesscycleId);
                List<ERP7__Process_Cycle__c> currPR = [Select Id,Name,ERP7__Process__c,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c  where Id=:ProcesscycleId limit 1];
                List<ERP7__Routing_Link__c> routLnk = [Select Id,Name from ERP7__Routing_Link__c where ERP7__Process_Cycle__c =:ProcesscycleId limit 1];
                if(currPR.size() > 0) ProcsId =currPR[0].ERP7__Process__c;
                set<Id> WCIds = new set<Id>();
                prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcsId Order By CreatedDate ASC limit 1000];
                for(ERP7__Process_Cycle__c ppcc : prclst) WCIds.add(ppcc.ERP7__Work_Center__c);
                List<ERP7__Routing__c> rout = [ Select Id,Name,ERP7__Process__c,ERP7__Product__c,ERP7__BOM_Version__c,ERP7__Product__r.QuantityUnitOfMeasure from ERP7__Routing__c where ERP7__Process__c = :ProcsId Limit 1 ];
                Id rTypeMO; rTypeMO = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_BOM').getRecordTypeId();   
                
                for(ERP7__BOM__c newbom : listbom){
                    if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable()){newbom.ERP7__Active__c = true;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable()){newbom.ERP7__BOM_Product__c = rout[0].ERP7__Product__c;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable()){newbom.ERP7__BOM_Version__c = rout[0].ERP7__BOM_Version__c;}else{/*No access*/}
                    if(routLnk.size() > 0 && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isCreateable()){ newbom.ERP7__Routing_Link__c = routLnk[0].Id;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isCreateable()){newbom.ERP7__Status__c = 'Certified';}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable()){newbom.ERP7__Type__c = 'Primary';}else{/*No access*/}
                    if((newbom.ERP7__Unit_of_Measure__c == '' || newbom.ERP7__Unit_of_Measure__c == null || newbom.ERP7__Unit_of_Measure__c == '--None--') && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable()) newbom.ERP7__Unit_of_Measure__c = rout[0].ERP7__Product__r.QuantityUnitOfMeasure;else{/*No access*/}
                    if(Schema.sObjectType.ERP7__BOM__c.fields.RecordTypeId.isCreateable() && rTypeMO != null){newbom.RecordTypeId = rTypeMO;}else{/*No access*/}
                }
                
                
                
                if(Schema.sObjectType.ERP7__BOM__c.isCreateable()){upsert listbom;}else{/*No access*/}
            }
            String wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Planner__c');
            String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Work_Planner__c Where ERP7__WorkCenter__c IN: WCIds Order by CreatedDate Asc limit 1000';
            List< ERP7__Work_Planner__c > WPS = Database.query(query);
            
            wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Requirement__c');
            wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Preferred_Resource__r.Name, ERP7__Preferred_Resource__r.ERP7__Employee__c, ERP7__Preferred_Resource__r.ERP7__Employee__r.Name, ERP7__Preferred_Resource__r.ERP7__Machine__c, ERP7__Preferred_Resource__r.ERP7__Machine__r.Name ';
            utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Requirement__c');  
            query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Requirement__c Where ERP7__Work_Planner__c In :WPS Order by CreatedDate Asc limit 1000';
            List< ERP7__Resource_Requirement__c > RRS = Database.query(query);
            set<Id> rrId = new set<Id>();
            List<ERP7__Resource_Group__c> rgroup = [Select Id,Name from ERP7__Resource_Group__c where ERP7__Process__c =:ProcsId or ERP7__Process_Cycle__c In:prclst];
            for(ERP7__Resource_Group__c rrg : rgroup) rrId.add(rrg.Id);
            
            List<ERP7__Resource__c> allresource = [Select Id,Name,ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__Resource_Group__c,ERP7__Resource_Group__r.Name from ERP7__Resource__c where ERP7__Resource_Group__c IN :rrId];
            Map<Id,List<ERP7__Resource__c> > resMap = new Map<Id,List<ERP7__Resource__c> >();
            for(ERP7__Resource__c rr :allresource){
                if(resMap.containsKey(rr.ERP7__Resource_Group__c)){
                    resMap.get(rr.ERP7__Resource_Group__c).add(rr);
                }
                else{ resMap.put(rr.ERP7__Resource_Group__c,new List<ERP7__Resource__c>{rr}); }
                
            } 
            List<ERP7__Operation__c> operationlst = [Select Id,Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name,ERP7__Timer__c,ERP7__Is_Signature_Required__c,ERP7__Auto_Clock_In__c,ERP7__Process_Cycle__c from ERP7__Operation__c where ERP7__Process_Cycle__c =:prclst Order By CreatedDate Asc];
            set<Id> operationIds = new set<Id>();
            Map<id,List<ERP7__Operation__c>> opmap = new Map<id,List<ERP7__Operation__c>>();
            for(ERP7__Operation__c opp : operationlst) {
                operationIds.add(opp.Id);
                if(opmap.containsKey(opp.ERP7__Process_Cycle__c)){
                    opmap.get(opp.ERP7__Process_Cycle__c).add(opp);
                }
                else{ opmap.put(opp.ERP7__Process_Cycle__c,new List<ERP7__Operation__c>{opp}); }
            }
            String queryBomList = 'Select Id,Name,ERP7__Cost_Price__c,ERP7__Cost_Card__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Component__r.ProductCode,ERP7__BOM_Component__r.ERP7__Vendor_product_Name__c,ERP7__Process_Cycle__c,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c from ERP7__BOM__c where ERP7__Process_Cycle__c = :prclst';
                   if (String.isNotBlank(version)) { queryBomList += ' and ERP7__BOM_Version__c = :version'; }
                   queryBomList += ' Order By ERP7__Sort__c';
            List<ERP7__BOM__c> bollst = Database.query(queryBomList);
            //List<ERP7__BOM__c> bollst = [Select Id,Name,ERP7__Cost_Price__c,ERP7__Cost_Card__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Component__r.ProductCode,ERP7__BOM_Component__r.ERP7__Vendor_product_Name__c,ERP7__Process_Cycle__c,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c from ERP7__BOM__c where ERP7__Process_Cycle__c =:prclst Order By CreatedDate Asc];
            Map<id,List<ERP7__BOM__c>> BOMmap = new Map<id,List<ERP7__BOM__c>>();
            for(ERP7__BOM__c bom1 : bollst) {
                if(BOMmap.containsKey(bom1.ERP7__Process_Cycle__c)){
                    BOMmap.get(bom1.ERP7__Process_Cycle__c).add(bom1);
                }
                else{ BOMmap.put(bom1.ERP7__Process_Cycle__c,new List<ERP7__BOM__c>{bom1}); }
            }
            List<ERP7__WIP_Link__c> wiplst = [Select Id,Name,ERP7__Process_Output_Product__c,ERP7__Process_Output_Product__r.Name,ERP7__Quantity_Unit_Of_Measure__c,ERP7__Quantity_Unit__c,ERP7__Type__c ,ERP7__Process_Cycle__c from ERP7__WIP_Link__c where ERP7__Process_Cycle__c =:prclst  Order By CreatedDate Asc];
            Map<id,List<ERP7__WIP_Link__c>> WIPmap = new Map<id,List<ERP7__WIP_Link__c>>();
            for(ERP7__WIP_Link__c wip : wiplst) {
                if(WIPmap.containsKey(wip.ERP7__Process_Cycle__c)){
                    WIPmap.get(wip.ERP7__Process_Cycle__c).add(wip);
                }
                else{ WIPmap.put(wip.ERP7__Process_Cycle__c,new List<ERP7__WIP_Link__c>{wip}); }
            }
            List<ERP7__Checklist__c> chklst = [Select Id,Name,ERP7__Has_Checklist__c,ERP7__Result__c,ERP7__Action_Detail__c ,ERP7__Process_Cycle__c,ERP7__Comply__c,ERP7__Operation__c,ERP7__Operation__r.Name from ERP7__Checklist__c where ERP7__Process_Cycle__c =:prclst  Order By CreatedDate Asc];
            Map<id,List<ERP7__Checklist__c>> checkmap = new Map<id,List<ERP7__Checklist__c>>();
            for(ERP7__Checklist__c chkl : chklst) {
                if(checkmap.containsKey(chkl.ERP7__Process_Cycle__c)){
                    checkmap.get(chkl.ERP7__Process_Cycle__c).add(chkl);
                }
                else{ checkmap.put(chkl.ERP7__Process_Cycle__c,new List<ERP7__Checklist__c>{chkl}); }
            }
            List<ERP7__Media__c> medialst = [select Id,Name,ERP7__Operation__c,ERP7__Operation__r.Name,ERP7__Operation__r.ERP7__Process_Cycle__c from ERP7__Media__c where ERP7__Active__c = true and ERP7__Operation__c in :operationIds Order By CreatedDate Asc];
            Map<id,List<ERP7__Media__c>> Mediamap = new Map<id,List<ERP7__Media__c>>();
            for(ERP7__Media__c med : medialst) {
                if(Mediamap.containsKey(med.ERP7__Operation__r.ERP7__Process_Cycle__c)){
                    Mediamap.get(med.ERP7__Operation__r.ERP7__Process_Cycle__c).add(med);
                }
                else{ Mediamap.put(med.ERP7__Operation__r.ERP7__Process_Cycle__c,new List<ERP7__Media__c>{med}); }
            }
            List<Attachment> doclst = [select Id,Name,ParentId from Attachment where ParentId In :medialst Order By CreatedDate Asc];
            Map<id,List<Attachment>> Atttmap = new Map<id,List<Attachment>>();
            for(Attachment att : doclst) {
                if(Atttmap.containsKey(att.ParentId)){
                    Atttmap.get(att.ParentId).add(att);
                }
                else{ Atttmap.put(att.ParentId,new List<Attachment>{att}); }
            }
            for(ERP7__Process_Cycle__c prc : prclst){
                boolean show = true;
                comwrap wr = new comwrap();
                wr.oprlst = opmap.get(prc.Id);
                wr.bomlst = BOMmap.get(prc.Id);
                wr.wiplinks = WIPmap.get(prc.Id);
                wr.checklists  =checkmap.get(prc.Id);
                if(Mediamap.size() > 0){
                    if(Mediamap.values().size() > 0 && Mediamap.containsKey(prc.Id)){
                        wr.med = Mediamap.get(prc.Id);
                        for(ERP7__Media__c med : Mediamap.get(prc.Id)){
                            wr.attchment = Atttmap.get(med.Id);
                        } 
                    }  
                }
                
                if(rgroup.size() > 0){
                    wr.RRGroup = rgroup[0];
                    wr.availableResource = resMap.get(rgroup[0].Id);
                }
                
                ProcessCyclewrap pprwr = new ProcessCyclewrap(prc,wr,false); 
                pcwrap.add(pprwr); 
            }
            /* for(ERP7__Process_Cycle__c pp : prclst){
ProcessCyclewrap newPc = new ProcessCyclewrap(pp,getAll(pp.Id,''),false);
pcwrap.add(newPc);
}*/
            //pcwrap = getAll(ProcesscycleId,'');
        }catch(Exception e){
            system.debug('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> alldetails(String ProcsId,List<Id> WCIds,String versionId,String action){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        String version = versionId;
        try{
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Sort__c, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcsId Order By ERP7__Sort__c limit 1000];
            String wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Planner__c');
            String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Work_Planner__c Where ERP7__WorkCenter__c IN: WCIds Order by CreatedDate Asc limit 1000';
            List< ERP7__Work_Planner__c > WPS = Database.query(query);
            
            wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Requirement__c');
            wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Preferred_Resource__r.Name, ERP7__Preferred_Resource__r.ERP7__Employee__c, ERP7__Preferred_Resource__r.ERP7__Employee__r.Name, ERP7__Preferred_Resource__r.ERP7__Machine__c, ERP7__Preferred_Resource__r.ERP7__Machine__r.Name ';
            utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Requirement__c');  
            query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Requirement__c Where ERP7__Work_Planner__c In :WPS Order by CreatedDate Asc limit 1000';
            List< ERP7__Resource_Requirement__c > RRS = Database.query(query);
            set<Id> rrId = new set<Id>();
            List<ERP7__Resource_Group__c> rgroup = [Select Id,Name from ERP7__Resource_Group__c where ERP7__Process__c =:ProcsId or ERP7__Process_Cycle__c In:prclst];
            for(ERP7__Resource_Group__c rrg : rgroup) rrId.add(rrg.Id);
            
            List<ERP7__Resource__c> allresource = [Select Id,Name,ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__Resource_Group__c,ERP7__Resource_Group__r.Name from ERP7__Resource__c where ERP7__Resource_Group__c IN :rrId];
            Map<Id,List<ERP7__Resource__c> > resMap = new Map<Id,List<ERP7__Resource__c> >();
            for(ERP7__Resource__c rr :allresource){
                if(resMap.containsKey(rr.ERP7__Resource_Group__c)){
                    resMap.get(rr.ERP7__Resource_Group__c).add(rr);
                }
                else{ resMap.put(rr.ERP7__Resource_Group__c,new List<ERP7__Resource__c>{rr}); }
                
            } 
            List<ERP7__Operation__c> operationlst = [Select Id,Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name,ERP7__Timer__c,ERP7__Is_Signature_Required__c,ERP7__Auto_Clock_In__c,ERP7__Process_Cycle__c from ERP7__Operation__c where ERP7__Process_Cycle__c =:prclst Order By ERP7__Sort__c];
            set<Id> operationIds = new set<Id>();
            Map<id,List<ERP7__Operation__c>> opmap = new Map<id,List<ERP7__Operation__c>>();
            for(ERP7__Operation__c opp : operationlst) {
                operationIds.add(opp.Id);
                if(opmap.containsKey(opp.ERP7__Process_Cycle__c)){
                    opmap.get(opp.ERP7__Process_Cycle__c).add(opp);
                }
                else{ opmap.put(opp.ERP7__Process_Cycle__c,new List<ERP7__Operation__c>{opp}); }
            }
            system.debug('action : '+action);
            String queryBomList = 'Select Id,Name,ERP7__Cost_Price__c,ERP7__Cost_Card__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Component__r.ProductCode,ERP7__BOM_Component__r.ERP7__Vendor_product_Name__c,ERP7__Process_Cycle__c,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c,ERP7__Type__c,ERP7__Status__c from ERP7__BOM__c where ERP7__Process_Cycle__c = :prclst';
                   if (String.isNotBlank(version) && action != 'clone') { queryBomList += ' and ERP7__BOM_Version__c = :version'; }
                   queryBomList += ' Order By ERP7__Sort__c';
            List<ERP7__BOM__c> bollst = Database.query(queryBomList);
            //List<ERP7__BOM__c> bollst = [Select Id,Name,ERP7__Cost_Price__c,ERP7__Cost_Card__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Component__r.ProductCode,ERP7__BOM_Component__r.ERP7__Vendor_product_Name__c,ERP7__Process_Cycle__c,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c from ERP7__BOM__c where ERP7__Process_Cycle__c =:prclst and ERP7__BOM_Version__c =: version Order By ERP7__Sort__c];
            Map<id,List<ERP7__BOM__c>> BOMmap = new Map<id,List<ERP7__BOM__c>>();            
            for(ERP7__BOM__c bom1 : bollst) {
                if(BOMmap.containsKey(bom1.ERP7__Process_Cycle__c)){
                    BOMmap.get(bom1.ERP7__Process_Cycle__c).add(bom1);
                }
                else{ BOMmap.put(bom1.ERP7__Process_Cycle__c,new List<ERP7__BOM__c>{bom1}); }
            }
            List<ERP7__WIP_Link__c> wiplst = [Select Id,Name,ERP7__Process_Output_Product__c,ERP7__Process_Output_Product__r.Name,ERP7__Quantity_Unit_Of_Measure__c,ERP7__Quantity_Unit__c,ERP7__Type__c ,ERP7__Process_Cycle__c,ERP7__Finished_Products_Site__c from ERP7__WIP_Link__c where ERP7__Process_Cycle__c =:prclst  Order By ERP7__Sort__c];           
            Map<id,List<ERP7__WIP_Link__c>> WIPmap = new Map<id,List<ERP7__WIP_Link__c>>();
            for(ERP7__WIP_Link__c wip : wiplst) {
                if(WIPmap.containsKey(wip.ERP7__Process_Cycle__c)){
                    WIPmap.get(wip.ERP7__Process_Cycle__c).add(wip);
                }
                else{ WIPmap.put(wip.ERP7__Process_Cycle__c,new List<ERP7__WIP_Link__c>{wip}); }
            }
            List<ERP7__Checklist__c> chklst = [Select Id,Name,ERP7__Has_Checklist__c,toLabel(ERP7__Result__c),ERP7__Action_Detail__c ,ERP7__Process_Cycle__c,toLabel(ERP7__Comply__c),ERP7__Operation__c,ERP7__Operation__r.Name from ERP7__Checklist__c where ERP7__Process_Cycle__c =:prclst  Order By CreatedDate Asc];
            Map<id,List<ERP7__Checklist__c>> checkmap = new Map<id,List<ERP7__Checklist__c>>();
            for(ERP7__Checklist__c chkl : chklst) {
                if(checkmap.containsKey(chkl.ERP7__Process_Cycle__c)){
                    checkmap.get(chkl.ERP7__Process_Cycle__c).add(chkl);
                }
                else{ checkmap.put(chkl.ERP7__Process_Cycle__c,new List<ERP7__Checklist__c>{chkl}); }
            }
            List<ERP7__Media__c> medialst = [select Id,Name,ERP7__Operation__c,ERP7__Operation__r.Name,ERP7__Operation__r.ERP7__Process_Cycle__c from ERP7__Media__c where ERP7__Active__c = true and ERP7__Operation__c in :operationIds Order By CreatedDate Asc];
            Map<id,List<ERP7__Media__c>> Mediamap = new Map<id,List<ERP7__Media__c>>();
            for(ERP7__Media__c med : medialst) {
                if(Mediamap.containsKey(med.ERP7__Operation__r.ERP7__Process_Cycle__c)){
                    Mediamap.get(med.ERP7__Operation__r.ERP7__Process_Cycle__c).add(med);
                }
                else{ Mediamap.put(med.ERP7__Operation__r.ERP7__Process_Cycle__c,new List<ERP7__Media__c>{med}); }
            }
            List<Attachment> doclst = [select Id,Name,ParentId from Attachment where ParentId In :medialst Order By CreatedDate Asc];
            system.debug('doclst : '+doclst.size());
            Map<id,List<Attachment>> Atttmap = new Map<id,List<Attachment>>();
            for(Attachment att : doclst) {
                if(Atttmap.containsKey(att.ParentId)){
                    Atttmap.get(att.ParentId).add(att);
                }
                else{ Atttmap.put(att.ParentId,new List<Attachment>{att}); }
            }
            system.debug('Atttmap : '+Atttmap);
            for(ERP7__Process_Cycle__c prc : prclst){
                List<Attachment> PCattch = new List<Attachment>();
                boolean show = true;
                comwrap wr = new comwrap();
                wr.oprlst = opmap.get(prc.Id);
                wr.bomlst = BOMmap.get(prc.Id);
                wr.wiplinks = WIPmap.get(prc.Id);
                wr.checklists  =checkmap.get(prc.Id);
                if(Mediamap.values().size() > 0 && Mediamap.size() > 0 && Mediamap.containsKey(prc.Id)){
                    wr.med = Mediamap.get(prc.Id);
                    for(ERP7__Media__c med : Mediamap.get(prc.Id)){
                        if(Atttmap.containsKey(med.Id)) PCattch.addAll(Atttmap.get(med.Id));
                        system.debug('PCattch : '+PCattch);
                    } 
                }
                if(rgroup.size() > 0){
                    wr.RRGroup = rgroup[0];
                    wr.availableResource = resMap.get(rgroup[0].Id);
                }
                wr.attchment = PCattch;
                ProcessCyclewrap pprwr = new ProcessCyclewrap(prc,wr,false); 
                pcwrap.add(pprwr); 
            }
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        
        return pcwrap;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> saveWIP(String WIP,String versionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            List<ERP7__WIP_Link__c> allwiplnk = (List<ERP7__WIP_Link__c>) JSON.deserialize(WIP,  List<ERP7__WIP_Link__c>.class);
            String ProcesscycleId;
            if(allwiplnk.size() > 0) ProcesscycleId = allwiplnk[0].ERP7__Process_Cycle__c;
            List<ERP7__Process_Cycle__c> currPR = [Select Id,Name,ERP7__Process__c,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c  where Id=:ProcesscycleId limit 1];
            string ProcsId;
            if(currPR.size() > 0) ProcsId = currPR[0].ERP7__Process__c;
            List<ERP7__Routing__c> rout = [ Select Id,Name,ERP7__Process__c,ERP7__Product__c,ERP7__BOM_Version__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Finished_Products_Site__c from ERP7__Routing__c where ERP7__Process__c = :ProcsId Limit 1 ];
            for(ERP7__WIP_Link__c newwiplnk : allwiplnk){
                if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Product__c.isCreateable()){newwiplnk.ERP7__Product__c = rout[0].ERP7__Product__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Version__c.isCreateable()){newwiplnk.ERP7__Version__c = rout[0].ERP7__BOM_Version__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Finished_Products_Site__c.isCreateable()){newwiplnk.ERP7__Finished_Products_Site__c = rout[0].ERP7__Finished_Products_Site__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Type__c.isCreateable()){newwiplnk.ERP7__Type__c = 'Produced';}else{/*No access*/}
                if((newwiplnk.ERP7__Quantity_Unit_Of_Measure__c == '' || newwiplnk.ERP7__Quantity_Unit_Of_Measure__c == null || newwiplnk.ERP7__Quantity_Unit_Of_Measure__c == '--None--') && Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Quantity_Unit_Of_Measure__c.isCreateable()){ newwiplnk.ERP7__Quantity_Unit_Of_Measure__c = rout[0].ERP7__Product__r.QuantityUnitOfMeasure; }else{/*No access*/}
            }
            if(Schema.sObjectType.ERP7__WIP_Link__c.isCreateable()){upsert allwiplnk;}else{/*No access*/}
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcsId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcsId,WCIds,versionId,'');
            // pcwrap = getAll(ProcesscycleId,'');
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> deleteOP(String opId,String versionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__Operation__c deleteop = [Select Id,Name,ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.ERP7__Process__c from ERP7__Operation__c where Id=:opId];
            string ProcessId = deleteop.ERP7__Process_Cycle__r.ERP7__Process__c;
            if(Schema.sObjectType.ERP7__Operation__c.isDeletable()) delete deleteop;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcessId,WCIds,versionId,'');
            // pcwrap = getAll(ProcesscycleId,'');
            
            
            
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
        
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> deleteRR(String RRId,String PRID,String versionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__Resource__c deleteResource = [Select Id,Name,ERP7__Resource_Group__c,ERP7__Resource_Group__r.ERP7__Process_Cycle__c from ERP7__Resource__c where Id=:RRId];
            string ProcesscycleId = '';
            if(PRID == '' && PRID == null)  ProcesscycleId = deleteResource.ERP7__Resource_Group__r.ERP7__Process_Cycle__c;
            else ProcesscycleId = PRID;
            ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:ProcesscycleId limit 1];
            string ProcessId = currPR.ERP7__Process__c;
            if (Schema.sObjectType.ERP7__Resource__c.isDeletable()) delete deleteResource;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcessId,WCIds,versionId,'');
            //pcwrap = getAll(ProcesscycleId,'');
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
        
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> deleteattchMedia(String mediaId,String VersionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__Media__c med =[Select Id,Name,ERP7__Operation__c,ERP7__Operation__r.ERP7__Process_Cycle__c from ERP7__Media__c where Id=:mediaId limit 1];
            String ProcesscycleId =med.ERP7__Operation__r.ERP7__Process_Cycle__c;
            List<Attachment> deleteAtt = [select Id,Name,ParentId from Attachment Where ParentId =:mediaId];
            
            ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:ProcesscycleId limit 1];
            string ProcessId = currPR.ERP7__Process__c;
            if(deleteAtt.size() > 0 && Schema.sObjectType.Attachment.isDeletable()) delete deleteAtt;
            if(Schema.sObjectType.ERP7__Media__c.isDeletable()) delete med;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcessId,WCIds,VersionId,'');
            //pcwrap = getAll(ProcesscycleId,'');            
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
        
    }
    @AuraEnabled
    public static List<ProcessCyclewrap> deleteBOM(String BOMId,String VersionId){
        String version = VersionId;
        
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__BOM__c deleteBOMrecord = [Select Id,Name,ERP7__Process_Cycle__c from ERP7__BOM__c where Id=:BOMId limit  1];
            string ProcesscycleId = deleteBOMrecord.ERP7__Process_Cycle__c;
            ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:ProcesscycleId limit 1];
            string ProcessId = currPR.ERP7__Process__c;
            if(Schema.sObjectType.ERP7__BOM__c.isDeletable()) delete deleteBOMrecord;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcessId,WCIds,version,'');
            // pcwrap = getAll(ProcesscycleId,'');
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
        
    }
    @AuraEnabled
    public static List<ProcessCyclewrap> deletechecks(String chklstId,String VersionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__Checklist__c deletecheckrecord = [Select Id,Name,ERP7__Process_Cycle__c from ERP7__Checklist__c where Id=:chklstId limit  1];
            string ProcesscycleId = deletecheckrecord.ERP7__Process_Cycle__c;
            ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:ProcesscycleId limit 1];
            string ProcessId = currPR.ERP7__Process__c;
            
            if(Schema.sObjectType.ERP7__Checklist__c.isDeletable()) delete deletecheckrecord;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcessId,WCIds,VersionId,'');
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
        
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> deleteWIPlink(String WIPId,String versionId){
        List<ProcessCyclewrap> pcwrap = new List<ProcessCyclewrap>();
        try{
            ERP7__WIP_Link__c deleteWIPrecord = [Select Id,Name,ERP7__Process_Cycle__c from ERP7__WIP_Link__c where Id=:WIPId limit  1];
            string ProcesscycleId = deleteWIPrecord.ERP7__Process_Cycle__c;
            ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:ProcesscycleId limit 1];
            string ProcessId = currPR.ERP7__Process__c;
            
            if(Schema.sObjectType.ERP7__WIP_Link__c.isDeletable()) delete deleteWIPrecord;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            pcwrap = alldetails(ProcessId,WCIds,versionId,'');
            //pcwrap = getAll(ProcesscycleId,'');
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return pcwrap; 
        
    }
    @AuraEnabled
    public static List<ProcessCyclewrap> updateOPeration(String OPtoUpdate,String versionId){
        ERP7__Operation__c op = (ERP7__Operation__c) JSON.deserialize(OPtoUpdate, ERP7__Operation__c.class);
        string prcsId =op.ERP7__Process_Cycle__c;
        if(Schema.sObjectType.ERP7__Operation__c.isUpdateable()){update op;}else{/*No access*/}
        List<ProcessCyclewrap> cwrap = new List<ProcessCyclewrap>();
        ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:prcsId limit 1];
        string ProcessId = currPR.ERP7__Process__c;
        List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
        
        List<Id> WCIds = new List<Id>();
        for(ERP7__Process_Cycle__c pp: prclst) {
            WCIds.add(pp.ERP7__Work_Center__c);
        }
        cwrap = alldetails(ProcessId,WCIds,versionId,'');
        
        return cwrap;
    }
    @AuraEnabled
    public static List<ProcessCyclewrap> updateBOM(String BOMtoUpdate,String versionId){
        ERP7__BOM__c bom = (ERP7__BOM__c) JSON.deserialize(BOMtoUpdate, ERP7__BOM__c.class);
        string prcsId =bom.ERP7__Process_Cycle__c;
        if(Schema.sObjectType.ERP7__BOM__c.isUpdateable()){update bom;}else{/*No access*/}
        List<ProcessCyclewrap> cwrap = new List<ProcessCyclewrap>();
        ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:prcsId limit 1];
        string ProcessId = currPR.ERP7__Process__c;
        List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
        List<Id> WCIds = new List<Id>();
        for(ERP7__Process_Cycle__c pp: prclst) {
            WCIds.add(pp.ERP7__Work_Center__c);
        }
        cwrap = alldetails(ProcessId,WCIds,versionId,'');
        
        return cwrap;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> updateBOMList (List<ERP7__BOM__c> BomsToUpdate,string PrcsId,String versionId){
        
        /*Set<String> ProcessCycleIds = new Set<String>();
for(ERP7__BOM__c bom :BomsToUpdate){
if(bom.ERP7__Process_Cycle__c != null) {
ProcessCycleIds.add(bom.ERP7__Process_Cycle__c);
}
}
String prcsId = String.join(new List<String>(ProcessCycleIds), ',');*/
        
        if(Schema.sObjectType.ERP7__BOM__c.isUpdateable()){update BomsToUpdate;}else{}
        List<ProcessCyclewrap> cwrap = new List<ProcessCyclewrap>();
        ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:prcsId limit 1];
        string ProcessId = currPR.ERP7__Process__c;
        List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
        List<Id> WCIds = new List<Id>();
        for(ERP7__Process_Cycle__c pp: prclst) {
            WCIds.add(pp.ERP7__Work_Center__c);
        }
        cwrap = alldetails(ProcessId,WCIds,versionId,'');
        
        return cwrap;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> updateOpList (List<ERP7__Operation__c> OperationsToUpdate,string PrcsId,String versionId){
        
        if(Schema.sObjectType.ERP7__Operation__c.isUpdateable()){update OperationsToUpdate;}else{}
        List<ProcessCyclewrap> cwrap = new List<ProcessCyclewrap>();
        ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:prcsId limit 1];
        string ProcessId = currPR.ERP7__Process__c;
        List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
        List<Id> WCIds = new List<Id>();
        for(ERP7__Process_Cycle__c pp: prclst) {
            WCIds.add(pp.ERP7__Work_Center__c);
        }
        cwrap = alldetails(ProcessId,WCIds,versionId,'');
        
        return cwrap;
    }
    @AuraEnabled
    public static List<ProcessCyclewrap> updateWiPList (List<ERP7__WIP_Link__c> WiPToUpdate,string PrcsId,String versionId){
        
        if(Schema.sObjectType.ERP7__WIP_Link__c.isUpdateable()){update WiPToUpdate;}else{}
        List<ProcessCyclewrap> cwrap = new List<ProcessCyclewrap>();
        ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:prcsId limit 1];
        string ProcessId = currPR.ERP7__Process__c;
        List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
        List<Id> WCIds = new List<Id>();
        for(ERP7__Process_Cycle__c pp: prclst) {
            WCIds.add(pp.ERP7__Work_Center__c);
        }
        cwrap = alldetails(ProcessId,WCIds,'','');
        
        return cwrap;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> updateProcessList (List<ERP7__Process_Cycle__c> ProcessToUpdate,string processId,String versionId){
        
        if(Schema.sObjectType.ERP7__Process_Cycle__c.isUpdateable()){update ProcessToUpdate;}else{}
        List<ProcessCyclewrap> pcs = new List<ProcessCyclewrap>();
        List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Sort__c, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:processId Order By ERP7__Sort__c limit 1000];
        List<Id> WCIds = new List<Id>();
        for(ERP7__Process_Cycle__c pp: prclst) {
            WCIds.add(pp.ERP7__Work_Center__c);
        }
        pcs = alldetails(processId,WCIds,versionId,'');
        
        return pcs;
    }
    
    @AuraEnabled
    public static List<ProcessCyclewrap> updatechklist(String checktoUpdate,String versionId){
        ERP7__Checklist__c chceklst = (ERP7__Checklist__c) JSON.deserialize(checktoUpdate, ERP7__Checklist__c.class);
        string prcsId =chceklst.ERP7__Process_Cycle__c;
        //from here
            List<SelectOptionWrapper> picklistValues = getpicklistvallues('ERP7__Checklist__c', 'ERP7__Comply__c');
            List<SelectOptionWrapper> picklistValues2 = getpicklistvallues('ERP7__Checklist__c', 'ERP7__Result__c');
            for (SelectOptionWrapper option : picklistValues) {
                if (option.label.equals(chceklst.ERP7__Comply__c)) {chceklst.ERP7__Comply__c =option.value;
                }
            }
            for (SelectOptionWrapper option : picklistValues2) {
                if (option.label.equals(chceklst.ERP7__Result__c)) {chceklst.ERP7__Result__c =option.value;
                }
            }//till here
        if(Schema.sObjectType.ERP7__Checklist__c.isUpdateable()){update chceklst;}else{/*No access*/}
        List<ProcessCyclewrap> cwrap = new List<ProcessCyclewrap>();
        if(prcsId != '' && prcsId != null) {
            ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:prcsId limit 1];
            string ProcessId = currPR.ERP7__Process__c;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            cwrap = alldetails(ProcessId,WCIds,versionId,'');
            
        }
        return cwrap;
    } 
    
    @AuraEnabled
    public static List<ProcessCyclewrap> updateWIP(String WIPtoUpdate,String versionId){
        ERP7__WIP_Link__c wiplink = (ERP7__WIP_Link__c) JSON.deserialize(WIPtoUpdate, ERP7__WIP_Link__c.class);
        string prcsId =wiplink.ERP7__Process_Cycle__c;
        if(Schema.sObjectType.ERP7__WIP_Link__c.isUpdateable()){update wiplink;}else{/*No access*/}
        List<ProcessCyclewrap> cwrap = new List<ProcessCyclewrap>();
        if(prcsId != '' && prcsId != null) {
            ERP7__Process_Cycle__c currPR = [Select Id,Name,ERP7__Process__c from ERP7__Process_Cycle__c where Id=:prcsId limit 1];
            string ProcessId = currPR.ERP7__Process__c;
            List<ERP7__Process_Cycle__c> prclst = [Select Id,Name, ERP7__Description__c,ERP7__Next_Process_Cycle__c,ERP7__Previous_Process_Cycle__c,ERP7__Process__c,ERP7__Next_Process_Cycle__r.Name,ERP7__Previous_Process_Cycle__r.Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name from ERP7__Process_Cycle__c where Name != '' and ERP7__Process__c=:ProcessId Order By CreatedDate ASC limit 1000];
            List<Id> WCIds = new List<Id>();
            for(ERP7__Process_Cycle__c pp: prclst) {
                WCIds.add(pp.ERP7__Work_Center__c);
            }
            cwrap = alldetails(ProcessId,WCIds,versionId,'');
            
        }
        return cwrap;
    } 
    @AuraEnabled
    public static comwrap getAll(String ProcesscycleId,string finishsite,String versionId){
        comwrap cwrap = new comwrap();
        try{
            ERP7__Process_Cycle__c pr = [Select Id,Name,ERP7__Work_Center__c,ERP7__Process__c,ERP7__Process__r.Name from ERP7__Process_Cycle__c where Id =: ProcesscycleId limit 1];
            string WC = pr.ERP7__Work_Center__c;
            String wcFields = UtilClass.selectStarFromSObject('ERP7__Work_Planner__c');
            String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Work_Planner__c Where ERP7__WorkCenter__c =: WC Order by CreatedDate Asc limit 1000';
            List< ERP7__Work_Planner__c > WPS = Database.query(query);
            
            wcFields = UtilClass.selectStarFromSObject('ERP7__Resource_Requirement__c');
            wcFields += ', ERP7__Resource_Group__r.Name, ERP7__Preferred_Resource__r.Name, ERP7__Preferred_Resource__r.ERP7__Employee__c, ERP7__Preferred_Resource__r.ERP7__Employee__r.Name, ERP7__Preferred_Resource__r.ERP7__Machine__c, ERP7__Preferred_Resource__r.ERP7__Machine__r.Name ';
            utilClass.FLSCheck(wcFields.split(','),'ERP7__Resource_Requirement__c');  
            query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Resource_Requirement__c Where ERP7__Work_Planner__c In :WPS Order by CreatedDate Asc limit 1000';
            List< ERP7__Resource_Requirement__c > RRS = Database.query(query);
            
            query = 'select Id,Name from ERP7__Capacity_Planner__c Where ERP7__Work_Center__c  =: WC And ERP7__Start_Date__c <= Today And ERP7__End_Date__c >= Today Order by CreatedDate Desc limit 1';
            List<ERP7__Capacity_Planner__c> CPS = Database.query(query);
            set<Id> rrId = new set<Id>();
            if(WPS.size() == 0){
                ERP7__Work_Planner__c newWPS = new ERP7__Work_Planner__c();    if(Schema.sObjectType.ERP7__Work_Planner__c.fields.Name.isCreateable()){newWPS.Name = 'Work Planner '+pr.ERP7__Process__r.Name;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__WorkCenter__c.isCreateable()){newWPS.ERP7__WorkCenter__c = WC;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__Status__c.isCreateable()){newWPS.ERP7__Status__c = 'Approved';}else{/*No access*/}   if(Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__Process_Cycle__c.isCreateable()){newWPS.ERP7__Process_Cycle__c=pr.Id;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Work_Planner__c.fields.ERP7__Process__c.isCreateable()){newWPS.ERP7__Process__c = pr.ERP7__Process__c;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Work_Planner__c.isCreateable()){insert newWPS;}else{/*No access*/}
                if(CPS.size() == 0) {
                    ERP7__Capacity_Planner__c newCP = new ERP7__Capacity_Planner__c();  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.Name.isCreateable()){newCP.Name = 'CP '+pr.ERP7__Process__r.Name;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.ERP7__Work_Center__c.isCreateable()){newCP.ERP7__Work_Center__c = WC;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.ERP7__Start_Date__c.isCreateable()){newCP.ERP7__Start_Date__c = system.today();}else{/*No access*/}  if(Schema.sObjectType.ERP7__Capacity_Planner__c.fields.ERP7__End_Date__c.isCreateable()){newCP.ERP7__End_Date__c=System.today().addYears(1);}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Capacity_Planner__c.isCreateable()){insert newCP;}else{/*No access*/}
                }
                ERP7__Resource_Group__c newRgroup =  new ERP7__Resource_Group__c(); if(Schema.sObjectType.ERP7__Resource_Group__c.fields.Name.isCreateable()){newRgroup.Name=pr.ERP7__Process__r.Name+ ' Group';}else{/*No access*/}   if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__Start_Date__c.isCreateable()){newRgroup.ERP7__Start_Date__c = (system.today() - 10);}else{/*No access*/}  if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__End_Date__c.isCreateable()){newRgroup.ERP7__End_Date__c = System.Now().addYears(1);}else{/*No access*/}   if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__Process__c.isCreateable()){newRgroup.ERP7__Process__c = pr.ERP7__Process__c;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Resource_Group__c.fields.ERP7__Process_Cycle__c.isCreateable()){newRgroup.ERP7__Process_Cycle__c = pr.Id;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Resource_Group__c.isCreateable()){insert newRgroup;}else{/*No access*/}
                cwrap.RRGroup = newRgroup;
                rrId.add(newRgroup.Id);
                ERP7__Resource_Requirement__c newRR = new ERP7__Resource_Requirement__c();  if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.Name.isCreateable()){newRR.Name ='Resource Requirement '+pr.ERP7__Process__r.Name;}else{/*No access*/}   if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Work_Planner__c.isCreateable()){newRR.ERP7__Work_Planner__c = newWPS.Id;}else{/*No access*/}  if(Schema.sObjectType.ERP7__Resource_Requirement__c.fields.ERP7__Resource_Group__c.isCreateable()){newRR.ERP7__Resource_Group__c = newRgroup.Id;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Resource_Requirement__c.isCreateable()){insert newRR;}else{/*No access*/}
            }
            else{
                List<ERP7__Resource_Group__c> rgroup = [Select Id,Name from ERP7__Resource_Group__c where ERP7__Process__c =:pr.ERP7__Process__c or ERP7__Process_Cycle__c =:pr.Id];
                if(rgroup.size() > 0) cwrap.RRGroup = rgroup[0];
                for(ERP7__Resource_Group__c rrg : rgroup) rrId.add(rrg.Id);
            }
            
            
            List<ERP7__Resource__c> allresource = [Select Id,Name,ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__Resource_Group__c,ERP7__Resource_Group__r.Name from ERP7__Resource__c where ERP7__Resource_Group__c IN :rrId];
            
            List<ERP7__Operation__c> operationlst = [Select Id,Name,ERP7__Work_Center__c,ERP7__Work_Center__r.Name,ERP7__Timer__c,ERP7__Is_Signature_Required__c,ERP7__Auto_Clock_In__c,ERP7__Process_Cycle__c from ERP7__Operation__c where ERP7__Process_Cycle__c =:ProcesscycleId Order By CreatedDate Asc];
            set<Id> operationIds = new set<Id>();
            for(ERP7__Operation__c opp : operationlst) operationIds.add(opp.Id);
            String queryBomList = 'Select Id,Name,ERP7__Cost_Price__c,ERP7__Cost_Card__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Component__r.ProductCode,ERP7__BOM_Component__r.ERP7__Vendor_product_Name__c,ERP7__Process_Cycle__c,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c from ERP7__BOM__c where ERP7__Process_Cycle__c = :prclst';
            if (String.isNotBlank(versionId)) { queryBomList += ' and ERP7__BOM_Version__c = :versionId'; }
            queryBomList += ' Order By ERP7__Sort__c';
            List<ERP7__BOM__c> bollst = Database.query(queryBomList);
            //List<ERP7__BOM__c> bollst = [Select Id,Name,ERP7__Cost_Price__c,ERP7__Cost_Card__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__Process_Cycle__c,ERP7__Quantity__c,ERP7__Unit_of_Measure__c,ERP7__Maximum_Variance__c,ERP7__Minimum_Variance__c,ERP7__For_Multiples__c from ERP7__BOM__c where ERP7__Process_Cycle__c =:ProcesscycleId Order By CreatedDate Asc];
            List<ERP7__WIP_Link__c> wiplst = new List<ERP7__WIP_Link__c>();
            if(finishsite != '' &&  finishsite != null) wiplst = [Select Id,Name,ERP7__Process_Output_Product__c,ERP7__Process_Output_Product__r.Name,ERP7__Quantity_Unit_Of_Measure__c,ERP7__Quantity_Unit__c,ERP7__Type__c,ERP7__Process_Cycle__c from ERP7__WIP_Link__c where ERP7__Process_Cycle__c =:ProcesscycleId and ERP7__Finished_Products_Site__c =: finishsite Order By CreatedDate Asc];
            else wiplst = [Select Id,Name,ERP7__Process_Output_Product__c,ERP7__Process_Output_Product__r.Name,ERP7__Quantity_Unit_Of_Measure__c,ERP7__Quantity_Unit__c,ERP7__Type__c ,ERP7__Process_Cycle__c from ERP7__WIP_Link__c where ERP7__Process_Cycle__c =:ProcesscycleId  Order By CreatedDate Asc];
            List<ERP7__Media__c> medialst = [select Id,Name,ERP7__Operation__c,ERP7__Operation__r.Name from ERP7__Media__c where ERP7__Active__c = true and ERP7__Operation__c in :operationIds Order By CreatedDate Asc];
            List<Attachment> doclst = [select Id,Name,ParentId from Attachment where ParentId In :medialst Order By CreatedDate Asc];
            List<ERP7__Checklist__c> checklst = [select Id,Name,ERP7__Action_Detail__c,ERP7__Comply__c,ERP7__Result__c,ERP7__Has_Checklist__c,ERP7__Process_Cycle__c,ERP7__Operation__c,ERP7__Operation__r.Name from ERP7__Checklist__c where ERP7__Process_Cycle__c = :ProcesscycleId Order By CreatedDate Asc];
            cwrap.oprlst = operationlst;
            cwrap.bomlst = bollst;
            cwrap.wiplinks = wiplst;
            cwrap.med= medialst;
            cwrap.attchment = doclst;
            cwrap.availableResource = allresource;
            cwrap.checklists = checklst;
        }catch(Exception e){
            //('Error : '+e.getMessage()+' at  : '+e.getLineNumber());
        }
        return cwrap;
        
    }
    @AuraEnabled
    public static string getChannel(){
        String chanId = '';
        List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                            where ERP7__Employee_User__c=:UserInfo.getUserId()];
        if(empList.size()>0 && empList != null){
            chanId = empList[0].ERP7__Channel__c;
        }
        
        return chanId;
    }
    @AuraEnabled
    public static Productwrap getProcess(String VerId,String ProductId){
        Productwrap pwrap = new Productwrap();
        List<ERP7__Routing__c> routlst = [Select Id,Name,ERP7__Process__c from ERP7__Routing__c where ERP7__BOM_Version__c =:VerId and ERP7__Product__c =: ProductId and ERP7__Process__c != null];
        if(routlst.size() > 0){
            ERP7__Process__c prcss = [Select Id,Name from ERP7__Process__c where Id=:routlst[0].ERP7__Process__c limit 1];
            ERP7__Version__c ver = [Select Id,Name from ERP7__Version__c where Id=:VerId and  ERP7__Product__c =:ProductId limit 1];
            Product2 prod= [Select Id,Name,ERP7__Status__c,QuantityUnitOfMeasure,ProductCode,Description from Product2 where Id=:ProductId limit 1];
            pwrap.prod = prod;
            pwrap.version = ver;
            pwrap.Process = prcss;
        }
        else{
            Product2 prod= [Select Id,Name,ERP7__Status__c,QuantityUnitOfMeasure,ProductCode,Description from Product2 where Id=:ProductId limit 1];
            List<ERP7__Version__c> ver = [Select Id,Name from ERP7__Version__c where Id=:VerId and  ERP7__Product__c =:ProductId limit 1];
            if(ver.size() > 0) pwrap.version = ver[0];
            pwrap.prod = prod;
            
        }
        
        return pwrap;
    }
    public class ProdCC{
        @AuraEnabled public Product2 prod                                    { get; set; }
        @AuraEnabled public ERP7__Cost_Card__c costCard                                    { get; set; }
    }
    public class Productwrap{
        @AuraEnabled public Product2 prod                                    { get; set; }
        @AuraEnabled public String errmsg                                    { get; set; }
        @AuraEnabled public Boolean isselected                               { get; set; }
        @AuraEnabled public ERP7__Version__c version                         { get; set; }
        @AuraEnabled public ERP7__Process__c Process                         { get; set; }
        @AuraEnabled public Integer recSize                                          { get; set; }
        @AuraEnabled public String defaultVersion           { get; set; }
        public  Productwrap(Product2 pro,ERP7__Version__c vers,Integer totalrecs,ERP7__Process__c pr){
            prod = pro;
            isselected = false; 
            version = vers;
            errmsg = '';
            recSize = totalrecs;
            Process = pr;
            defaultVersion = '';
        }
        public  Productwrap(){
            prod = new Product2();
            version = new ERP7__Version__c(); 
            Process = new ERP7__Process__c();
            isselected = false;
            recSize = 0; 
        }
    }
    
    public class ProcessCyclewrap{
        @AuraEnabled public ERP7__Process_Cycle__c prcscycl                     { get; set; }
        @AuraEnabled public Boolean isselected                                  { get; set; }
        @AuraEnabled public Boolean showsite                                    { get; set; }
        @AuraEnabled public comwrap allRelateddetails                           { get; set; }
        @AuraEnabled public ERP7__Version__c version                            { get; set; }
        @AuraEnabled public ERP7__Process__c process                            { get; set; }
        @AuraEnabled public Product2 product                            { get; set; }
        
        public ProcessCyclewrap(ERP7__Process_Cycle__c currPr,comwrap Prdetail,Boolean getroute){
            prcscycl = currPr;
            isselected = false;
            showsite = getroute;
            allRelateddetails = Prdetail;
            version = new ERP7__Version__c(); 
        }
        
        public ProcessCyclewrap(ERP7__Process_Cycle__c currPr,comwrap Prdetail,Boolean getroute,ERP7__Version__c myversion){
            prcscycl = currPr;
            isselected = false;
            showsite = getroute;
            allRelateddetails = Prdetail;
            version = myversion; 
        }
        
    }
    public  class PcandVer{
        @AuraEnabled public ERP7__Process__c pr     {get;set;}
        @AuraEnabled public ERP7__Version__c vr     {get;set;}
        public PcandVer(){
            pr = new ERP7__Process__c();
            vr = new ERP7__Version__c();
        }
    }
    public class comwrap{
        @AuraEnabled public List<ERP7__Operation__c> oprlst                     { get; set; }
        @AuraEnabled public List<ERP7__BOM__c> bomlst                           { get; set; }
        @AuraEnabled public List<ERP7__WIP_Link__c> wiplinks                    { get; set; }
        @AuraEnabled public List<ERP7__Media__c> med                            { get; set; }
        @AuraEnabled public  List<Attachment> attchment                         { get; set; }
        @AuraEnabled public ERP7__Resource_Group__c RRGroup                     { get; set; }
        @AuraEnabled public List<ERP7__Resource__c> availableResource           { get; set; }
        @AuraEnabled public List<ERP7__Checklist__c> checklists                { get; set; }
        public comwrap(){
            oprlst = new List<ERP7__Operation__c>();
            bomlst = new List<ERP7__BOM__c>();
            wiplinks = new List<ERP7__WIP_Link__c>();
            attchment = new List<Attachment>();
            med = new List<ERP7__Media__c>();
            RRGroup = new ERP7__Resource_Group__c();
            availableResource = new List<ERP7__Resource__c>();
            checklists = new List<ERP7__Checklist__c>();
        }
        public comwrap(List<ERP7__Operation__c> oper,List<ERP7__BOM__c> bom ,List<ERP7__WIP_Link__c> wips,List<ERP7__Media__c> media,List<Attachment> attch,ERP7__Resource_Group__c rr,List<ERP7__Resource__c> res){
            oprlst = oper;
            bomlst = bom;
            wiplinks = wips;
            attchment = attch;
            med = media;
            RRGroup =rr;
            availableResource = res;
        }
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();//List<SelectOptions>
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            //ple.getvalue();
            objResults.put(label, new List<String>());// objResults.put(value, new List<SelectOptions>());
            controllingValues.add(label);//controllingValues.add(selectoptions(label,ple.getValue()));
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
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
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    public class wrapper{
        @AuraEnabled public Product2 prod{get;set;}
        @AuraEnabled public Decimal stock {get;set;}
        @AuraEnabled public Decimal demand {get;set;}
        @AuraEnabled public Decimal AwaitStock {get;set;}
        @AuraEnabled public Decimal quantity {get;set;}
        @AuraEnabled public Decimal MaxVariance  {get;set;}
        @AuraEnabled public Decimal MinVariance {get;set;}
        @AuraEnabled public Decimal Multiples {get;set;}
        @AuraEnabled public String  UOM {get;set;}
        @AuraEnabled public Decimal CostPrice {get;set;}
        @AuraEnabled public String CostcardId  {get;set;}
    }
    
    //For dependent picklist 
    
    
    
    @AuraEnabled 
    public static PicklistWrapper getDependentPicklist(String ObjectName, string parentField, string childField) {
        System.debug('ObjectName : '+ObjectName);
        System.debug('parentField: '+parentField);
        System.debug('childField: '+childField);
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){
            return pw;
        }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){
            return pw;     
        }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    
    public class PicklistWrapper{
        @AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;      
    }
    
    public class selectOptions {
        @AuraEnabled public String label {
            get;
            set;
        }
        @AuraEnabled public String value {
            get;
            set;
        }
        @AuraEnabled public Boolean selected {
            get;
            set;
        }
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab;
            value = val;
            selected = sel;
        }
    }
    
    @AuraEnabled 
    public static List<String> getFieldsSetApiName(String sObjectName,String fieldSetApiName){
        return UtilClass.getFieldsSetApiName(sObjectName, fieldSetApiName);
    } 
    @AuraEnabled 
    public static List<String> getFieldsSetLabelName(String sObjectName,String fieldSetApiName){
        return UtilClass.getFieldsSetLabelName(sObjectName, fieldSetApiName);
    }
    
    public class UpdatedProdWrap {
        @AuraEnabled public String msg;
        @AuraEnabled public Product2 productDetails;
        
        public UpdatedProdWrap() {
            this.msg = '';
            this.productDetails = new Product2();
        }
    }
    
   
    @AuraEnabled
    public static UpdatedProdWrap updateProd(String prodId) {
        UpdatedProdWrap prodWrap = new UpdatedProdWrap();
        
        if (String.isNotBlank(prodId)) {
            try {
                Product2 prod = [SELECT Id, Name FROM Product2 WHERE Id = :prodId LIMIT 1];
                prod.ERP7__Issue_Manufacturing_Order__c = true; 
                prod.IsActive = true;
                prod.ERP7__Track_Inventory__c = true;
                update prod;
                prodWrap.productDetails = prod;
                prodWrap.msg = 'Updated';
            } catch (Exception e) {
                prodWrap.msg = 'Product not found or update failed: ' + e.getMessage();
            }
        } else {
            prodWrap.msg = 'Invalid Product ID';
        }
        
        return prodWrap;
    }
    
 @AuraEnabled
    public static Boolean checkManufacturingOrders(Id VersionId) {
        List<ERP7__Manufacturing_Order__c> moList = [
            SELECT Id 
            FROM ERP7__Manufacturing_Order__c 
            WHERE ERP7__Version__c = :VersionId 
            AND ERP7__Status__c IN ('Draft', 'In Progress')
            
        ];
        return !moList.isEmpty();
    }

    
    
    
}