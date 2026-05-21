public with sharing class LocationUtility{
    
    public static List<sObject> retrieveResults(String latitude, string longitude, String sObjectAPI){
        
        String q = 'select '+String.escapeSingleQuotes(UtilClass.selectStarFromSObject(sObjectAPI));
        q += ' from '+String.escapeSingleQuotes(sObjectAPI);
        q += 'where DISTANCE(ERP7__Location__c, GEOLOCATION( ';
        q += String.escapeSingleQuotes(latitude) + ', ' + String.escapeSingleQuotes(longitude);
        q += ' ), \'km\') < 100 ';
        q += 'Order By DISTANCE(ERP7__Location__c, GEOLOCATION( ';
        q += String.escapeSingleQuotes(latitude) + ', ' + String.escapeSingleQuotes(longitude);
        q += ' ), \'km\') asc limit 25';
        
        List<sObject>  nearByLocations = new List<sObject>();
        nearByLocations = Database.query(q); if(nearByLocations.size()>0){ return nearByLocations; }else{ return null; }
    }
    
    
    
}