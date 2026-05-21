public with sharing class MaintenanceBuilder {
          
    @AuraEnabled
    public static WCCP getAll(String View, String Site, String WC, String SO, String statusWO){
        WCCP WCCP = new WCCP(); 
        try{
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
            String allFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(allFields.split(','),'ERP7__WO__c');
            allFields += ',ERP7__Project__r.Name, ERP7__Sales_Order__r.Name, ERP7__Routing__r.ERP7__Process__c, ERP7__Product__r.Name, ERP7__Work_Center__r.Name, ERP7__Product__r.ERP7__Picture__c ';
            String tempWCPlant = (Site != '')? Site : '';
            String tempWCPlantVal = tempWCPlant;
            String workStationSrc = (WC != '')? WC : '';
            String tempSO = (SO != Null)? SO : '';
            String tempSOVal = tempSO;
            String workStationSrcVal = workStationSrc;
            Map<Id, ERP7__WO__c> mapWOs = new Map<Id, ERP7__WO__c>();
            List<Id> routingIds = new List<Id>();
            String Complete = 'Complete';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__WO__c where ERP7__Quantity_Ordered__c > 0 And ERP7__Is_Closed__c = false And ERP7__Routing__c != Null And ERP7__Routing__r.ERP7__Process__r.RecordType.Name = \'Maintenance Process\' And (ERP7__Type__c  = \'Maintenance\' Or ERP7__Type__c  = \'Installation\') '; 
            if(tempWCPlant != '') query += ' and ERP7__Site__c != null and ERP7__Site__c = : tempWCPlantVal ';
            if(tempSOVal != '') query += ' and ERP7__Sales_Order__c = : tempSOVal ';
            if(workStationSrc != '') query += 'and ERP7__Work_Center__c != null and ERP7__Work_Center__c = : workStationSrcVal ';
            if(!Superuser && !Supervisor) query += ' and OwnerId = : loggedInUser ';
            if(!Superuser && Supervisor) query += ' and OwnerId IN : teamUsers ';
            if(statusWO != '') query += ' and ERP7__Status__c =: statusWO ';
            query += 'order by CreatedDate asc ';
            List<ERP7__WO__c> WOS = Database.query(query);
            
            for(ERP7__WO__c wo : WOS) {  routingIds.add(wo.ERP7__Routing__c);  mapWOs.put(wo.Id,wo); 
            }
            List<ERP7__Routing__c> Routings = [Select Id, Name, ERP7__Product__c , ERP7__Product__r.Name, ERP7__Product__r.Picture__c, ERP7__Process__c from ERP7__Routing__c where Id In :routingIds Limit 10000];
            Map<Id,List<WO__c>> WCWOS = new Map<Id,List<WO__c>>();
            for(ERP7__WO__c wo : WOS){
                if(wo.ERP7__Work_Center__c != Null){
                    if(WCWOS.containsKey(wo.ERP7__Work_Center__c)){
                        List<WO__c> myWCWOS = WCWOS.get(wo.ERP7__Work_Center__c);
                        myWCWOS.add(wo);
                        WCWOS.put(wo.ERP7__Work_Center__c,myWCWOS);
                    } else{
                        List<WO__c> myWCWOS = new List<WO__c>(); myWCWOS.add(wo); WCWOS.put(wo.ERP7__Work_Center__c,myWCWOS);
                    }
                }
            }
            Map<Id,Work_Center__c> WCSMap = new Map<Id,Work_Center__c>([Select Id, Name From Work_Center__c Where Id In : WCWOS.keySet()]);
            List<routingWrapper> PWL = new List<routingWrapper>();
            if(View == 'List' || View == 'Grid'){
                for(Id sch : WCWOS.keySet()){
                    Work_Center__c WCK = WCSMap.get(sch);
                    routingWrapper rw = new routingWrapper();
                    rw.WorkCenter = WCK; rw.WOs = new List<ERP7__WO__c>(); rw.WOs = WCWOS.get(sch);
                    if(rw.WOs.size() > 0) PWL.add(rw);    
                }  
            }
            WCCP.PWIK = PWL;
        } catch(Exception e) { WCCP.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return WCCP;
    }
    
    @AuraEnabled
    public static WCCP GetWORec(String RecId){
        WCCP WCCP = new WCCP();
        try{
            String allFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            utilClass.FLSCheck(allFields.split(','),'ERP7__WO__c');
            String querywo = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__WO__c ';
            querywo += 'where Id = :RecId';
            ERP7__WO__c WO2Finish = Database.query(querywo);
            WCCP.WO2Finish = WO2Finish;
        } catch(Exception e) { WCCP.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return WCCP;
    }
    
    @AuraEnabled
    public static WCCP GetMORec(String RecId){
        WCCP WCCP = new WCCP();
        try{
            String allFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            utilClass.FLSCheck(allFields.split(','),'ERP7__Manufacturing_Order__c');
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Manufacturing_Order__c ';
            query += 'where Id = :RecId';
            ERP7__Manufacturing_Order__c WO2Finish = Database.query(query);
            WCCP.MO2Finish = WO2Finish;
        } catch(Exception e) { WCCP.errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return WCCP;
    }
    
    public class routingWrapper{
        @AuraEnabled public ERP7__Routing__c Routing                        { get; set; }
        @AuraEnabled public List<ERP7__WO__c> WOS                           { get; set; }
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
        
        public WCCP(){
            WO2Finish = new ERP7__WO__c();
            MO2Finish = new ERP7__Manufacturing_Order__c();
            WC = new Work_Center__c();
            errMsg = '';
            NOW = system.Now();
        }
    }
}