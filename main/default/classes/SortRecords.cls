Global with sharing class SortRecords { 
   @AuraEnabled
    Public static list<sObject> getRecord(String ObjectAPIName, String OrderBy, String Order, String Query, String Fields, Integer show){
    String ObjectFields='';
    //if(String.isEmpty(Fields)) ObjectFields= UtilClass.selectStarFromSObject(ObjectAPIName);
    //else ObjectFields=Fields;
    ObjectFields= UtilClass.selectStarFromSObject(ObjectAPIName);
           
    String sQuery =  'SELECT ' +ObjectFields+' '+Fields+ ' FROM ' +ObjectAPIName+ ' WHERE Name!=Null '+Query+' order by ' +OrderBy+' '+Order+' NULLS LAST Limit '+show;     
       
    List < sObject > Records = Database.query(sQuery);  
    return Records;  
    }
    
   @AuraEnabled
   Public static list<sObject> getdoInit(String ObjectAPIName, String OrderBy, String Order, String Query){
    String Fields='';
    Fields= UtilClass.selectStarFromSObject('Position__c');   
    String sQuery =  'SELECT ' +String.escapeSingleQuotes(Fields) + ' FROM ' +String.escapeSingleQuotes(ObjectAPIName) + ' WHERE Name!=Null '+String.escapeSingleQuotes(Query)+' order by ' +String.escapeSingleQuotes(OrderBy)+' '+String.escapeSingleQuotes(Order);      
        
    List < sObject > Records = Database.query(sQuery);    
    return Records;  
    }  
    
}