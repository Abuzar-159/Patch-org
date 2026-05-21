public with sharing class WorkCenterCapacityPlanning {
    
    @AuraEnabled
    public static WCCP getAll(String currentWCCP, String IsNew, String Flow, Integer wcOffset, Integer RecordLimit){
        WCCP WCCP = new WCCP();
        //=====================================        
        User user=[Select Id,Name,ProfileId,Profile.Name from user where Id=:UserInfo.getUserId()];        
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(user.Id);
        if(customList == null){ customList = ERP7__Functionality_Control__c.getValues(user.ProfileId);
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            WCCP.showBuilder=customList.ERP7__Manufacturing_Builder__c;
            WCCP.showPlanner=customList.ERP7__Manufacturing_Planner__c;
            WCCP.showSheduler=customList.ERP7__Manufacturing_Scheduler__c;
            WCCP.showOrderDetails=customList.ERP7__Show_Order_and_Order_Product_in_Planner__c;
            WCCP.ShowLangOptionForTraveller= customList.ERP7__ShowLangOptionForTraveller__c;
            WCCP.ReplaceTravellerOrgURL= customList.ERP7__Replace_Traveller_OrgURL__c;
            WCCP.showMOStage= customList.ERP7__Show_Stage_in_MO_Planner__c;
        }
        //==============================
        
        if(IsNew == 'false'){  
            WCCP = (WCCP) JSON.deserialize(currentWCCP, WCCP .class);
        }
        String wcFields = ''; String query = '';
        //MOs
        if(Flow == 'MO'){
            wcFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            wcFields += ', ERP7__Product__r.ProductCode,ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.Name,ERP7__Owner__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name,ERP7__Sales_Order_Line_Item__r.Name,ERP7__Order__r.OrderNumber,ERP7__Order_Product__r.OrderItemNumber ';
            utilClass.FLSCheck(wcFields.split(','),'ERP7__Manufacturing_Order__c');  
            query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Manufacturing_Order__c Where (ERP7__Is_Closed__c = false)';
            if(WCCP.searchMOs != '' && WCCP.searchMOs != null){
                String searchStr = '%'+WCCP.searchMOs+'%';
                system.debug('searchStr : '+searchStr);
                query += ' AND (Name LIKE: searchStr OR ERP7__Product__r.Name LIKE: searchStr or ERP7__Product__r.ProductCode LIKE: searchStr)';
            }
            system.debug('WCCP.statusMOs : '+WCCP.statusMOs);
            if(WCCP.statusMOs != '' && WCCP.statusMOs != null && WCCP.statusMOs != 'All'){
                String statusStr = WCCP.statusMOs;
                query += ' AND ERP7__Status__c =: statusStr';
            }
            query += ' Order by CreatedDate DESC limit 9999';
            List< ERP7__Manufacturing_Order__c > MOSvar = Database.query(query);
            List<AggregateResult> results = [SELECT ERP7__Status__c , COUNT(Id) recordCount FROM ERP7__Manufacturing_Order__c GROUP BY ERP7__Status__c ];
            WCCP.totalMOS = results ;
            WCCP.recSize = MOSvar.size();
            WCCP.MOS = new List< ERP7__Manufacturing_Order__c >();
            Integer countMO = 0;
            Set<Id> MOrderIds = new Set<Id>();
            for(ERP7__Manufacturing_Order__c curMO : MOSvar) {
                if(countMO < (wcOffset+RecordLimit) && countMO >= wcOffset) {
                    MOrderIds.add(curMO.Id);
                    WCCP.MOS.add(curMO);
                }
                countMO++;
            }
            WCCP.MOSWrp = new List<mosWrap>();
            List<ERP7__WO__c> WOlist = [SELECT Id, Name, ERP7__MO__c, ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Progress__c, ERP7__Status__c, ERP7__Active__c FROM ERP7__WO__c WHERE ERP7__MO__c IN: MOrderIds LIMIT 9999];
            for(ERP7__Manufacturing_Order__c curMO : WCCP.MOS) {
                mosWrap mosWp = new mosWrap();
                mosWp.Morder = curMO;
                for(ERP7__WO__c curWO : WOlist) {
                    if(curWO.ERP7__MO__c == curMO.Id){
                        mosWp.Worders.add(curWO);
                        mosWp.NOW = system.now();
                    }
                }
                WCCP.MOSWrp.add(mosWp);
            }
        }
        //WOs
        if (Flow == 'WO'){
            wcFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            wcFields += ', ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name ';
            utilClass.FLSCheck(wcFields.split(','),'ERP7__WO__c');  
            query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__WO__c Where (ERP7__Is_Closed__c = false And ERP7__Routing__c != Null And (ERP7__Type__c  = \'Maintenance\' Or ERP7__Type__c  = \'Installation\')) ';
            if(WCCP.searchWOs != '' && WCCP.searchWOs != null){
                String searchStr = '%'+WCCP.searchWOs+'%';
                query += ' AND (Name LIKE: searchStr OR ERP7__Product__r.Name LIKE: searchStr)';
            }
            if(WCCP.statusWOs != '' && WCCP.statusWOs != null && WCCP.statusWOs != 'All'){
                String statusStr = WCCP.statusWOs;
                query += ' AND ERP7__Status__c =: statusStr';
            }
            query += ' Order by CreatedDate Asc limit 9999';

            List<ERP7__WO__c> WOSvar = Database.query(query);
            WCCP.recSize = WOSvar.size();
            WCCP.WOS = new List<ERP7__WO__c>();
            Integer countWO = 0;
            Set<Id> WOrderIds = new Set<Id>();
            for(ERP7__WO__c curWO : WOSvar) {
                if(countWO < (wcOffset+RecordLimit) && countWO >= wcOffset) {
                    WOrderIds.add(curWO.Id);
                    WCCP.WOS.add(curWO);
                }
                countWO++;
            }
            WCCP.WOSWrp = new List<wosWrap>();
            List<ERP7__Actions_Tasks__c> tasklist = [SELECT Id, Name, ERP7__Work_Order__c, ERP7__Work_Order__r.Name, ERP7__Status__c FROM ERP7__Actions_Tasks__c WHERE ERP7__Work_Order__c IN: WOrderIds LIMIT 9999];
            for(ERP7__WO__c curWO : WCCP.WOS) {
                wosWrap wosWp = new wosWrap();
                wosWp.Worder = curWO;
                for(ERP7__Actions_Tasks__c curtask : tasklist) {
                    if(curtask.ERP7__Work_Order__c == curWO.Id){
                        wosWp.tasks.add(curtask);
                        wosWp.NOW = system.now();
                    }
                }
                WCCP.WOSWrp.add(wosWp);
            }
        }
        return WCCP;
    }
    
    @AuraEnabled
    public static WCCP getMOs(String currentWCCP, Integer wcOffset, Integer RecordLimit){
        WCCP WCCP = (WCCP) JSON.deserialize(currentWCCP, WCCP.class);
        //MOs
        String wcFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
        wcFields += ', ERP7__Product__r.Name, ERP7__Version__r.Name, ERP7__Routing__r.Name,ERP7__Owner__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name,ERP7__Sales_Order_Line_Item__r.Name,ERP7__Order__r.OrderNumber,ERP7__Order_Product__r.OrderItemNumber ';
        utilClass.FLSCheck(wcFields.split(','),'ERP7__Manufacturing_Order__c');  
        String query = 'select ' + String.escapeSingleQuotes(wcFields) + ' from ERP7__Manufacturing_Order__c Where (ERP7__Is_Closed__c = false) Order by CreatedDate DESC limit 9999';
        List< ERP7__Manufacturing_Order__c > MOS = Database.query(query);
        WCCP.recSize = MOS.size();
        WCCP.MOS = new List< ERP7__Manufacturing_Order__c >();
        WCCP.MOSWrp = new List<mosWrap>();
        Integer countMO = 0;
        Set<Id> MOrderIds = new Set<Id>();
        for(ERP7__Manufacturing_Order__c curMO : MOS) {
            if(countMO < (wcOffset+RecordLimit) && countMO >= wcOffset) {
                MOrderIds.add(curMO.Id);
                WCCP.MOS.add(curMO);
            }
            countMO++;
        }
        List<ERP7__WO__c> WOlist = [SELECT Id, Name, ERP7__MO__c, ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Progress__c, ERP7__Status__c, ERP7__Active__c FROM ERP7__WO__c WHERE ERP7__MO__c IN: MOrderIds LIMIT 9999];
        for(ERP7__Manufacturing_Order__c curMO : WCCP.MOS) {
            mosWrap mosWp = new mosWrap();
            mosWp.Morder = curMO;
            for(ERP7__WO__c curWO : WOlist) {
                if(curWO.ERP7__MO__c == curMO.Id){
                    mosWp.Worders.add(curWO);
                    mosWp.NOW = system.now();
                }
            }
            WCCP.MOSWrp.add(mosWp);
        }
        return WCCP;
    }
    
    public class WCCP {
        @AuraEnabled public ERP7__Work_Center__c WC                                   { get; set; }
        @AuraEnabled public List<ERP7__Work_Planner__c> WorkPlanners                  { get; set; }
        @AuraEnabled public List<ERP7__Resource_Requirement__c> ResourceRequirements  { get; set; }
        @AuraEnabled public Date StartDate                                            { get; set; }
        @AuraEnabled public Integer Days                                              { get; set; }
        @AuraEnabled public String errMsg                                             { get; set; }
        @AuraEnabled public String Overview                                           { get; set; }
        @AuraEnabled public List < SelectOptions > Overviews                          { get; set; }
        @AuraEnabled public List< ERP7__Manufacturing_Order__c > MOS                  { get; set; }
        @AuraEnabled public List<mosWrap> MOSWrp                                      { get; set; }
        @AuraEnabled public List<wosWrap> WOSWrp                                      { get; set; }
        @AuraEnabled public String searchMOs                                          { get; set; }
        @AuraEnabled public String statusMOs                                          { get; set; }
        @AuraEnabled public String searchWOs                                          { get; set; }
        @AuraEnabled public String statusWOs                                          { get; set; }
        @AuraEnabled public List< ERP7__WO__c > WOS                                   { get; set; }
        @AuraEnabled public List< ERP7__Resource_Allocation__c > RAS                  { get; set; }
        @AuraEnabled public List< AggregateResult> totalMOS                  { get; set; }
        @AuraEnabled public List<Integer> PNS                                         { get; set; }
        @AuraEnabled public Integer recSize                                           { get; set; }
        @AuraEnabled public Integer PageNum                                           { get; set; }
        
        @AuraEnabled public Boolean showPlanner                                        { get; set; }
        @AuraEnabled public Boolean showSheduler                                     { get; set; }
        @AuraEnabled public Boolean showBuilder                                       { get; set; }
       @AuraEnabled public Boolean  showOrderDetails                                { get; set; }
         @AuraEnabled public Boolean  ShowLangOptionForTraveller                                { get; set; }
         @AuraEnabled public Boolean  ReplaceTravellerOrgURL                                { get; set; }
       @AuraEnabled public Boolean   showMOStage								  { get; set; }
        public WCCP() {
            this.MOSWrp = new List<mosWrap>();
            this.WorkPlanners = new List<ERP7__Work_Planner__c>();
            this.ResourceRequirements = new List<ERP7__Resource_Requirement__c>();
            this.WC = new ERP7__Work_Center__c();
            this.StartDate = system.today();
            this.Days = 30;
            this.Overview = 'Work Centers';
            this.errMsg = '';
            this.Overviews = new List < SelectOptions > ();
            this.totalMOS = new List< AggregateResult>();
            this.MOS = new List< ERP7__Manufacturing_Order__c >();
            this.searchMOs = ''; this.statusMOs = 'All';
            this.searchWOs = ''; this.statusWOs = 'All';
            this.WOS = new List< ERP7__WO__c >(); 
            this.RAS = new List< ERP7__Resource_Allocation__c >();
            Overviews.add(new SelectOptions('Work Centers', 'Work Centers'));
            Overviews.add(new SelectOptions('Resource Groups', 'Resource Groups'));
            Overviews.add(new SelectOptions('Resources', 'Resources'));
            this.PNS = new List<Integer>();
            this.recSize = 0;
            this.PageNum = 1;
            this.showPlanner=true;
            this.showSheduler=true;
            this.showBuilder=true; 
            this.showOrderDetails = false;
            this.ShowLangOptionForTraveller= false;
            this.ReplaceTravellerOrgURL= false;
            this.showMOStage = false;
        }
    }
    
    public class mosWrap {
        @AuraEnabled public ERP7__Manufacturing_Order__c Morder           { get; set; }
        @AuraEnabled public List<ERP7__WO__c> Worders                     { get; set; }
        @AuraEnabled public DateTime NOW                                  { get; set; }
        public mosWrap() {
            this.Morder = new ERP7__Manufacturing_Order__c();
            this.Worders = new List<ERP7__WO__c>();
        }
    }

    public class wosWrap {
        @AuraEnabled public ERP7__WO__c Worder                            { get; set; }
        @AuraEnabled public List<ERP7__Actions_Tasks__c> tasks            { get; set; }
        @AuraEnabled public DateTime NOW                                  { get; set; }
        public wosWrap() {
            this.Worder = new ERP7__WO__c();
            this.tasks = new List<ERP7__Actions_Tasks__c>();
        }
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
        }
    }
}