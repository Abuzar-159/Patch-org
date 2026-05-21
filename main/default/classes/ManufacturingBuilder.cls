public with sharing class ManufacturingBuilder {  
             
    @AuraEnabled (Cacheable = true)
    public static WCCP getAll(String View, String Site, String WC, String SO, String WOstate, Decimal durationMO, String timelineMO,String order){
        WCCP WCCP = new WCCP();    
        try{
            //duration calc.
            DateTime startWO = system.now();
            DateTime endWO   = system.now();
            //if(math.mod(durationMO, 2) != 0) durationMO = durationMO - 1;
            Integer S =0; Integer E = 0;
            if(durationMO == 1 && timelineMO == 'D'){
                startWO = startWO.addHours(12);
                endWO = endWO.addHours(12);
            }
            else if(durationMO > 0){
                switch on timelineMO{
                    when 'D' {
                        if(math.mod(Integer.valueOf(durationMO), 2) != 0){
                            durationMO = durationMO - 1;
                            startWO = startWO.addHours(12);
                            endWO = endWO.addHours(12); 
                        }
                        if(durationMO > 1){
                            S = Integer.valueOf(-durationMO/2);
                            E = Integer.valueOf(durationMO/2);
                            startWO = startWO.addDays(S);
                            endWO = endWO.addDays(E);
                        }
                    }
                    when 'W' {
                        S = Integer.valueOf(-6*(durationMO/2));
                        E = Integer.valueOf(6*(durationMO/2));
                        startWO = startWO.addDays(S);
                        endWO = endWO.addDays(E);
                    }
                    when 'M' {
                        S = Integer.valueOf(-30*(durationMO/2));
                        E = Integer.valueOf(30*(durationMO/2));
                        startWO = startWO.addDays(S);
                        endWO = endWO.addDays(E);
                    }
                    when 'Y' {
                        S = Integer.valueOf(-364*(durationMO/2));
                        E = Integer.valueOf(364*(durationMO/2));
                        startWO = startWO.addDays(S);
                        endWO = endWO.addDays(E);
                    }
                }
            }
            WCCP.startTimeline = startWO;
            WCCP.endTimeline   = endWO;
            //duration calc end.
            
            Boolean Supervisor = false;
            Boolean Superuser = false;
            Id loggedInUser = userInfo.getUserId();
            Set<Id> teamUsers = new Set<Id>();
            Set<Id> teamIds = new Set<Id>();
            List<ERP7__Resource__c> Resources = [Select Id, Name, ERP7__Super_User__c, ERP7__Supervisor_User__c From ERP7__Resource__c Where ERP7__User__c =: loggedInUser And ERP7__Super_User__c = true];
            if(Resources.size() > 0) Superuser = true;
            else{
                Resources = [Select Id, Name, ERP7__Super_User__c, ERP7__Supervisor_User__c From ERP7__Resource__c Where ERP7__User__c =: loggedInUser And ERP7__Supervisor_User__c = true];
                if(Resources.size() > 0) Supervisor = true;
            }
            if(!Superuser && Supervisor){
                List<ERP7__Team_Member__c> teamMembers = [Select Id, Name, ERP7__Resource__c, ERP7__Team__c From ERP7__Team_Member__c Where ERP7__Resource__r.ERP7__User__c =: loggedInUser And ERP7__Team__c != Null];
                for(ERP7__Team_Member__c TM : teamMembers) teamIds.add(TM.ERP7__Team__c);
                List<ERP7__Team_Member__c> teamResources = [Select Id, Name, ERP7__Resource__c, ERP7__Resource__r.ERP7__User__c, ERP7__Team__c From ERP7__Team_Member__c Where ERP7__Team__c In : teamIds And ERP7__Resource__c != Null And ERP7__Resource__r.ERP7__User__c != Null];
                for(ERP7__Team_Member__c T : teamResources) teamUsers.add(T.ERP7__Resource__r.ERP7__User__c);
            }
            
            String stateWO = WOstate;
            String tempSite = (Site != Null)? Site : '';
            String workStationSrc = (WC != Null)? WC : '';
            String tempSO = (SO != Null)? SO : '';
            String allWOFields = 'ERP7__Product__c,Id,Name,ERP7__Is_Closed__c ,ERP7__MO__c,ERP7__Quantity_Built__c,ERP7__Quantity_Ordered__c,ERP7__Quantity_Scrapped__c,ERP7__Active__c,ERP7__Status__c,ERP7__Progress__c,ERP7__Start_Date__c,ERP7__ExpectedDate__c,ERP7__Work_Center__c';
                //UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(allWOFields.split(','),'ERP7__WO__c');
            String querywo = 'select ' + String.escapeSingleQuotes(allWOFields) + ',ERP7__MO__r.ERP7__StartDate__c, ERP7__MO__r.Name, ERP7__Project__r.Name, ERP7__Sales_Order__r.Name, ERP7__Product__r.Name, ERP7__Process_Cycle__r.CreatedDate, ERP7__Site__r.Name, ERP7__Work_Center__r.Name, ERP7__Product__r.ERP7__Picture__c,ERP7__MO__r.ERP7__Sales_Order__c from ERP7__WO__c ';
            querywo += 'where Id != Null ';
            //querywo += ' and ERP7__MO__c In :moIds';
            if(stateWO != '' && stateWO != 'All') 
                querywo += ' and ERP7__Status__c =: stateWO';
            if(startWO != system.now() && endWO != system.now()) 
                querywo += ' and ERP7__Start_Date__c >=: startWO and ERP7__ExpectedDate__c <=: endWO';
            if(tempSite != '')  querywo += ' and ERP7__Site__c != null and ERP7__Site__c = : tempSite ';
            if(!Superuser && !Supervisor) 
                querywo += ' and OwnerId = : loggedInUser ';
            if(!Superuser && Supervisor)   querywo += ' and OwnerId IN : teamUsers ';
            if(workStationSrc != '')   querywo += ' and ERP7__Work_Center__c != null and ERP7__Work_Center__c = : workStationSrc ';
            if(tempSO != '') querywo += ' and ERP7__MO__r.ERP7__Sales_Order__c != null and ERP7__MO__r.ERP7__Sales_Order__c = : tempSO ';
            if(order != '' && order != null) querywo += ' and ERP7__MO__r.ERP7__Order__c != null and ERP7__MO__r.ERP7__Order__c = : order ';
            querywo += ' order by CreatedDate DESC limit 999';
            List<ERP7__WO__c> WOS = Database.query(querywo);
            set<Id> moidfrmwos = new set<Id>();
            for(ERP7__WO__c wo : WOS) moidfrmwos.add(wo.ERP7__MO__c);
            
            String allFields = 'Id,Name,ERP7__Routing__c,ERP7__Project__c,ERP7__Sales_Order__c,ERP7__Sales_Order_Line_Item__c,ERP7__Quantity__c,ERP7__Is_Closed__c,ERP7__Version__c,ERP7__Status__c';
                //UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            utilClass.FLSCheck(allFields.split(','),'ERP7__Manufacturing_Order__c');
            allFields += ',ERP7__Project__r.Name, ERP7__Sales_Order__r.Name,ERP7__Order_Product__c, ERP7__Product__c,ERP7__Order__c,ERP7__Routing__r.ERP7__Process__c, ERP7__Routing__r.ERP7__Finished_Products_Site__c ';
            Map<Id, ERP7__Manufacturing_Order__c> mapMOs = new Map<Id, ERP7__Manufacturing_Order__c>();
            List<Id> routingIds = new List<Id>();
            List<Id> moIds = new List<Id>();
            List<Id> processIds = new List<Id>();
            List<Id> cycleIds = new List<Id>();
            ERP7__Manufacturing_Order__c MO2Finish = new ERP7__Manufacturing_Order__c();
            
            String Complete = 'Complete';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Manufacturing_Order__c where ERP7__Quantity__c > 0 And ERP7__Is_Closed__c = false And ERP7__Version__c != Null And ERP7__Status__c != \'Complete\' And ERP7__Routing__c != Null And ERP7__Product__c != Null  ';
            if(moidfrmwos.size() > 0) query += ' and Id IN :moidfrmwos';
            if(tempSite != '') query += ' and ERP7__Routing__r.ERP7__Finished_Products_Site__c = : tempSite ';
            if(tempSO != '') query += ' and ERP7__Sales_Order__c != null and ERP7__Sales_Order__c = : tempSO ';
            //if(workStationSrc != '') query += 'and ERP7__Routing__r.ERP7__Work_Center__c != null and ERP7__Routing__r.ERP7__Work_Center__c =: workStationSrc';
            //if(startWO != system.now() && endWO != system.now()) query += ' and ERP7__StartDate__c =: startWO and ERP7__ExpectedDate__c =: endWO';
            query += ' order by CreatedDate desc';
            List<ERP7__Manufacturing_Order__c> MOS = Database.query(query);
            
            Map<Id, List< ERP7__WO__c >> MOWOs = new  Map<Id, List<ERP7__WO__c>>();
            Map<Id, List< ERP7__Manufacturing_Order__c >> routingMOs = new  Map<Id, List<ERP7__Manufacturing_Order__c>>();
            Map<Id, List< ERP7__Process_Cycle__c >> proCycles = new  Map<Id, List<ERP7__Process_Cycle__c>>();
            
            for(ERP7__Manufacturing_Order__c mo : MOS){
                mapMOs.put(mo.Id,mo);
                moIds.add(mo.Id);
                processIds.add(mo.ERP7__Routing__r.ERP7__Process__c);
                routingIds.add(mo.ERP7__Routing__c);
                if(routingMOs.containsKey(mo.ERP7__Routing__c)){ routingMOs.get(mo.ERP7__Routing__c).add(mo);
                } else {
                    List< ERP7__Manufacturing_Order__c > mymos = new List< ERP7__Manufacturing_Order__c >();
                    mymos.add(mo);
                    routingMOs.put(mo.ERP7__Routing__c,mymos);
                }
                MOWOs.put(mo.Id, new List< ERP7__WO__c >());
            }
            
            List<ERP7__Routing__c> Routings = [Select Id, Name, ERP7__Type__c , ERP7__Product__c , ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Process__c from ERP7__Routing__c where Id In :routingIds Limit 10000];
            
            
            
            //List<Process_Cycle__c> PCs = [Select Id, Name, ERP7__Process__c from ERP7__Process_Cycle__c where ERP7__Process__c In :processIds order by createddate asc];
            
            List<routingWrapper> PWL = new List<routingWrapper>();
            Integer issuedWO = 0;
            Integer InProgressWO = 0; Integer backLogWO = 0; Integer completedWO = 0;
            if(View == 'List' || View == 'Grid'){
                Map<Id,List<WO__c>> WCWOS = new Map<Id,List<WO__c>>();
                Map<Id,WO__c> mapAllWOs = new Map<Id,WO__c>();
                for(ERP7__WO__c wo : WOS){
                    if(wo.ERP7__MO__c != Null && MOWOs.containsKey(wo.ERP7__MO__c)) MOWOs.get(wo.ERP7__MO__c).add(wo);
                    mapAllWOs.put(wo.Id,wo);
                    if(wo.ERP7__Status__c == 'Issued') issuedWO +=1;
                    else if (wo.ERP7__Status__c == 'In Progress') InProgressWO +=1;
                    else if(wo.ERP7__Status__c == 'Backlog') backLogWO +=1;
                    else if(wo.ERP7__Status__c == 'Complete') completedWO +=1;
                    if(stateWO == 'Complete'){
                        if(wo.ERP7__Work_Center__c != Null && !wo.ERP7__Is_Closed__c){
                            if(WCWOS.containsKey(wo.ERP7__Work_Center__c)){
                                List<WO__c> myWCWOS = WCWOS.get(wo.ERP7__Work_Center__c);
                                myWCWOS.add(wo);
                                WCWOS.put(wo.ERP7__Work_Center__c,myWCWOS);
                            } else{
                                List<WO__c> myWCWOS = new List<WO__c>();
                                myWCWOS.add(wo);
                                WCWOS.put(wo.ERP7__Work_Center__c,myWCWOS);
                            }
                        }
                        
                    }
                    else{
                        if(wo.ERP7__Work_Center__c != Null && wo.ERP7__Status__c != 'Complete' && !wo.ERP7__Is_Closed__c){
                            if(WCWOS.containsKey(wo.ERP7__Work_Center__c)){
                                List<WO__c> myWCWOS = WCWOS.get(wo.ERP7__Work_Center__c);
                                myWCWOS.add(wo);
                                WCWOS.put(wo.ERP7__Work_Center__c,myWCWOS);
                            } else{
                                List<WO__c> myWCWOS = new List<WO__c>();
                                myWCWOS.add(wo);
                                WCWOS.put(wo.ERP7__Work_Center__c,myWCWOS);
                            }
                        }
                        
                    }
                }  
                
                Map<Id,ERP7__Work_Center__c> WCSMap = new Map<Id,ERP7__Work_Center__c>([Select Id, Name From ERP7__Work_Center__c Where Id In : WCWOS.keySet()]);
                
                for(Id sch : WCWOS.keySet()){
                    ERP7__Work_Center__c WCK = WCSMap.get(sch);
                    routingWrapper rw = new routingWrapper();
                    rw.WorkCenter = WCK;
                    rw.moWrapperList = new List<moWrapper>();
                    moWrapper mowrap = new moWrapper();
                        mowrap.WOS = WCWOS.get(sch);
                    rw.moWrapperList.add(mowrap);
                    PWL.add(rw);   
                }  
            }
            WCCP.PWIK = PWL;
            WCCP.IssuedWO = issuedWO;
             WCCP.ProgressWO = InProgressWO;
             WCCP.CompletedWO = completedWO;
             WCCP.BackLogWO = backLogWO;
            if(WCCP.PWIK.size() == 0){ WCCP.errMsg = System.Label.No_Records_Available; }
           
            /* Visibility Control */
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){   FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());  if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
            }
            if(FC != null){
                WCCP.showMO = FC.ERP7__Manufacturing_Builder_Show_MO__c;
                WCCP.showBuilder = FC.ERP7__Manufacturing_Builder__c;
                WCCP.showPlanner = FC.ERP7__Manufacturing_Planner__c;
                WCCP.showSheduler = FC.ERP7__Manufacturing_Scheduler__c;
                WCCP.isStandardOrder = FC.ERP7__Is_Standard_Order__c;
            }
        } catch(Exception e) { WCCP.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return WCCP;
    }
    
    public class moWrapper{
        //@AuraEnabled public ERP7__Manufacturing_Order__c MO                 { get; set; }
        @AuraEnabled public List<ERP7__WO__c> WOS                           { get; set; }
        
        public moWrapper(){
        }
    }
    
    public class routingWrapper{
        //@AuraEnabled public ERP7__Routing__c Routing                        { get; set; }
        //@AuraEnabled public List<Process_Cycle__c> processCycles            { get; set; }
        @AuraEnabled public List<moWrapper> moWrapperList                   { get; set; }
        @AuraEnabled public Work_Center__c WorkCenter                       { get; set; }
        
        public routingWrapper(){
        }
    }
    
    public class WCCP{
        @AuraEnabled public Work_Center__c WC                               { get; set; }
        @AuraEnabled public List<routingWrapper> PWIK                       { get; set; }
        @AuraEnabled public String errMsg                                   { get; set; }
        @AuraEnabled public ERP7__WO__c WO2Finish                           { get; set; }
        @AuraEnabled public ERP7__Manufacturing_Order__c MO2Finish          { get; set; }
        @AuraEnabled public DateTime NOW                                    { get; set; }
        @AuraEnabled public DateTime startTimeline                          { get; set; }
        @AuraEnabled public DateTime endTimeline                            { get; set; }
        
        @AuraEnabled public Boolean showPlanner                             { get; set; }
        @AuraEnabled public Boolean showSheduler                            { get; set; }
         @AuraEnabled public Boolean isStandardOrder                        { get; set; }
        @AuraEnabled public Boolean showBuilder                             { get; set; }
        @AuraEnabled public Boolean showMO                                  { get; set; }
       
        @AuraEnabled public Integer IssuedWO                                 { get; set; }
        @AuraEnabled public Integer ProgressWO                               { get; set; }
        @AuraEnabled public Integer CompletedWO                              { get; set; }
        @AuraEnabled public Integer BackLogWO                                { get; set; }
        
        public WCCP(){
            IssuedWO = ProgressWO = CompletedWO = BackLogWO = 0;
            WO2Finish = new ERP7__WO__c();
            MO2Finish = new ERP7__Manufacturing_Order__c();
            WC = new Work_Center__c();
            errMsg = '';
            NOW = system.Now();
            startTimeline = system.Now();
            endTimeline = system.Now();
            showPlanner=true;
            showSheduler=true;
            showBuilder=true;
            showMO=true;
            isStandardOrder = false;
        }
    }
}