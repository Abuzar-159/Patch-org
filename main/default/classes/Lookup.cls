public with sharing class Lookup {

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter) {
        system.debug('searchTerm : '+searchTerm);
        system.debug('myObject : '+myObject);
        system.debug('filter : '+filter);
        String myQuery = null;
        if(filter != null && filter != ''){
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
        }
        else {
            if(searchTerm != null && searchTerm != ''){
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
            }
            else {
                myQuery = 'Select Id, Name from '+myObject+' ORDER BY LastViewedDate DESC LIMIT  5';  
            }
        }
        system.debug('myQuery : '+myQuery);
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
     @AuraEnabled(cacheable=true)
    public static sObject fetchLookUpValueById(String ObjectName,String SearchField,String recordId) {
        try{
        system.debug('ObjectName : '+ObjectName);
        system.debug('recordId : '+recordId);
        String sQuery =  'SELECT Id, Name FROM ' +String.escapeSingleQuotes(ObjectName) + ' WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
        system.debug('fetchLookUpValueById sQuery==>'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        system.debug('lstOfRecords : '+lstOfRecords.size());
        if(lstOfRecords.size()>0) return lstOfRecords[0]; 
        else return null; }catch(Exception e){system.debug('Error : '+e.getMessage()+ ' At line : '+e.getLineNumber()); return null;}
    }
}