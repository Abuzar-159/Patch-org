public with sharing class SchedulerCustomLookups {

    public String NameSearch                                     { get; set; } 
    public List<Schedule__c> Schedules                           { get; set; } 
    public List<Process__c> Processes                            { get; set; } 
    public List<WO__c> WorkOrders                                { get; set; } 
    public List<Work_Order_Line_Items__c> WorkOrderLineItems     { get; set; }
    public List<Work_Center__c> WorkStations                     { get; set; }
    public List<Work_Center_Assignment__c > WorkStationassigns   { get; set; }
    public List<Process_Cycle__c> processCycles                  { get; set; } public List< ERP7__Project__c > Projects                     { get; set; } public List< ERP7__Version__c > Versions                     { get; set; }
    public List<workOrders> workOrderList                        { get; set; } 
    public static Map<String, Schema.SObjectType> schemaMap;
    
    public SchedulerCustomLookups(){
        NameSearch = '';
    }
    
    public PageReference ScheduleSelect(){
        schemaMap = Schema.getGlobalDescribe();
           String allFields = fetchAllFields('ERP7__Schedule__c');
        String query;
        allFields += ',Work_Order_Line_Item__r.Name, Process__r.Name, Work_Order__r.Name, Product__r.Name, Work_Center_Assignment__r.Work_Center__c, Work_Center_Assignment__r.Work_Center__r.Name, Process_Cycle__r.Name,RecordType.Name';
        if(NameSearch != ''){ String NameSrch = '%' + NameSearch + '%'; query = 'select ' + allFields + ' from Schedule__c where name like :NameSrch order by CreatedDate asc';
        }else{
            query = 'select ' + allFields + ' from Schedule__c order by CreatedDate asc';
        }
        if(Schema.sObjectType.ERP7__Schedule__c.isAccessible()){
        UtilClass.FlSCheck(fetchAllFields('ERP7__Schedule__c').split(',') ,'ERP7__Schedule__c');
         Schedules = Database.query(query);
        } 
        return Null;
    }
    
    public PageReference ProcessSelect() {
        schemaMap = Schema.getGlobalDescribe();
        String allFields = fetchAllFields('ERP7__Process__c');
        String query;
        allFields += ', RecordType.Name';
        if(NameSearch != ''){
            String NameSrch = '%' + NameSearch + '%'; query = 'select ' + allFields + ' from Process__c where name like :NameSrch order by CreatedDate asc';
        }else{
            query = 'select ' + allFields + ' from Process__c order by CreatedDate asc';
        }
        if(Schema.sObjectType.Process__c.isAccessible()) {
        UtilClass.FlSCheck(fetchAllFields('ERP7__Process__c').split(',') ,'Process__c');
        Processes = Database.query(query);
        }        
        return Null;
    }
    
    public PageReference ProjectSelect() { schemaMap = Schema.getGlobalDescribe(); String allFields = fetchAllFields('ERP7__Project__c'); String query;if(NameSearch != ''){ String NameSrch = '%' + NameSearch + '%'; query = 'select ' + allFields + ' from ERP7__Project__c where name like :NameSrch order by CreatedDate asc';
        }else{
            query = 'select ' + allFields + ' from ERP7__Project__c order by CreatedDate asc';
        }
        if(Schema.sObjectType.Process__c.isAccessible()) { UtilClass.FlSCheck(fetchAllFields('ERP7__Project__c').split(',') ,'Process__c');Projects = Database.query(query);  }         return Null;
    }
    
    public PageReference VersionSelect() {schemaMap = Schema.getGlobalDescribe(); String allFields = fetchAllFields('ERP7__Version__c'); String query;if(NameSearch != ''){ String NameSrch = '%' + NameSearch + '%'; query = 'select ' + allFields + ' from ERP7__Version__c where name like :NameSrch order by CreatedDate asc';
        }else{
            query = 'select ' + allFields + ' from ERP7__Version__c order by CreatedDate asc';
        }
        if(Schema.sObjectType.Process__c.isAccessible()) { UtilClass.FlSCheck(fetchAllFields('ERP7__Version__c').split(',') ,'ERP7__Version__c'); Versions = Database.query(query);  }         return Null;
    }
    
    public PageReference WorkOrderSelect() {
        schemaMap = Schema.getGlobalDescribe();
        String allFields = fetchAllFields('ERP7__WO__c');
        String query;
        allFields += ', Process__r.Name, Process__r.Work_Station__r.Name, Process__r.RecordType.Name, Process__r.Work_Center__c, Process__r.Work_Center__r.Name';
        if(NameSearch != ''){ String NameSrch = '%' + NameSearch + '%'; query = 'select ' + allFields + ' from WO__c where Process__c != Null && Name like :NameSrch order by CreatedDate asc';
        }else{
            query = 'select ' + allFields + ' from WO__c where Process__c != Null order by CreatedDate asc';
        }
        if(Schema.sObjectType.WO__c.isAccessible()) 
        UtilClass.FlSCheck(fetchAllFields('ERP7__WO__c').split(',') ,'ERP7__WO__c');
        WorkOrders = Database.query(query);
        
        List<Id> woIds = new List<Id>();
        for(WO__c wo : WorkOrders){ woIds.add(wo.Id);
        }
        
        List<Work_Order_Line_Items__c> wolis;
        if(Schema.sObjectType.Work_Order_Line_Items__c.isAccessible()) wolis = [Select Id, Name, Work_Orders__c from Work_Order_Line_Items__c where Work_Orders__c In : woIds order by CreatedDate asc];
        workOrderList = new List<workOrders>();
        for(WO__c wo : WorkOrders){
            List<Work_Order_Line_Items__c> mywolis = new List<Work_Order_Line_Items__c>();
            for(Work_Order_Line_Items__c woli : wolis){
                if(wo.Id == woli.Work_Orders__c) mywolis.add(woli);
            }
            workOrders wocls = (mywolis.size() == 1)? new workOrders(wo, mywolis.get(0)) : new workOrders(wo, new Work_Order_Line_Items__c());
            workOrderList.add(wocls);
        }
        
        return Null;
    }
    
    public PageReference WorkOrderLineItemSelect() {
        String woId = ApexPages.currentPage().getParameters().get('woId');
        if(Schema.sObjectType.Work_Order_Line_Items__c.isAccessible()) WorkOrderLineItems = (woId != '')? [Select Id, Name, Work_Orders__c, Work_Orders__r.Name, Product__c, Product__r.Name from Work_Order_Line_Items__c where Work_Orders__c =: woId] : new List<Work_Order_Line_Items__c>();
        return null;
    }
    
    public PageReference WorkStationSelect() {
       if(Schema.sObjectType.Work_Center__c.isAccessible()) WorkStations = [Select Id, Name, Active__c from Work_Center__c where Active__c = true];
        return null;
    }
    
    public PageReference WorkStationSelectAssign() {
        String cycleId = ApexPages.currentPage().getParameters().get('cycle');
        if(Schema.sObjectType.Work_Center_Assignment__c.isAccessible()) WorkStationassigns = [Select Id, Name, Process_Cycle__c, Work_Center__c, Work_Center__r.Name, Work_Center__r.Active__c from Work_Center_Assignment__c where Work_Center__r.Active__c = true And Process_Cycle__c =: cycleId];
        return null;
    }
    
    public PageReference cycleSelect() {
        String process = ApexPages.currentPage().getParameters().get('process');
        if(Schema.sObjectType.Process_Cycle__c.isAccessible()) processCycles = (process != '')? [Select Id, Name, Process__c from Process_Cycle__c where Process__c =: process] : [Select Id, Name, Process__c from Process_Cycle__c limit 10000];
        return null;
    }

    public String fetchAllFields(String sObj){
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObj).getDescribe().fields.getMap();
        String allFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(allFields == null || allFields == ''){
                allFields = fieldName;
            }else{
                allFields = allFields + ', ' + fieldName;
            }
        }
        return allFields;
    }
    
    public class workOrders{
        public WO__c Rec                                   { get; set; } 
        public Work_Order_Line_Items__c lineItem           { get; set; } 
        public String lineItemName                         { get; set; }
        public String lineItemId                           { get; set; }
        public workOrders(WO__c wo, Work_Order_Line_Items__c woli){
            Rec = wo;
            lineItem = woli;
            lineItemId = (lineItem.Id == Null) ? '' : lineItem.Id;
            lineItemName = (lineItem.Name == Null) ? '' : lineItem.Name;
        }
    }
    
    public string getFormTag() {
        return System.currentPageReference().getParameters().get('frm');
    }
    public string getTextBox() {
        return System.currentPageReference().getParameters().get('txt');
    }
    public string getidlp() {
        return System.currentPageReference().getParameters().get('idlp');
    }
    public string getcnn() {
        return System.currentPageReference().getParameters().get('cnn');
    }
}