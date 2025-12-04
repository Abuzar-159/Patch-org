public With Sharing class InputLookUpProduct {
    // Changes made on 30/3/23 by shaguftha 
    // To limit the number of rows queried on line 12. To fix Too many query rows: 50001
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String queryFilter,String SearchField) {
        /*'ObjectName-->' + ObjectName+'  ,queryFilter==>'+queryFilter);*/
        String searchKey ='%' + String.escapeSingleQuotes(searchKeyWord) + '%';     
        queryFilter = (String.isBlank(queryFilter))? '' : queryFilter;
        List < sObject > returnList = new List < sObject > ();
        Integer lim = 20;
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10   
        String sQuery =  'select id, ProductCode,Family,' +String.escapeSingleQuotes(SearchField) + ' from ' +String.escapeSingleQuotes(ObjectName) + ' where (Name LIKE: searchKey Or ProductCode LIKE: searchKey or Family LIKE: searchKey) '+String.valueOf(queryFilter)+' order by createdDate DESC Limit 10'; //LastModifiedDate limit 6      
        system.debug('sQuery : '+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        Integer NameLength=0, Index=0;
        list<sObject> returnListFinal=new list<sObject>();  
        returnListFinal.AddAll(returnList);   
        try{ 
        if(returnList.size()>lim && String.isNotEmpty(searchKeyWord)){
          //  returnListFinal.clear();
            for(Integer i=0; i<returnList.size(); i++){ 
                String nm=(String)returnList[i].get('Name');
                Integer NameLengthRecod=nm.length(); 
                if(i==0) NameLength=NameLengthRecod;               
                if(NameLength>NameLengthRecod){   NameLength=NameLengthRecod;    Index=i;                            
                }    
            }                      
          for(Integer i=0; i<lim; i++){
                returnListFinal.add(returnList[i]);
          }
          sObject firstObj=returnList[Index];          
          returnListFinal.remove(0);
          returnListFinal.add(0,firstObj);        
          returnList=returnListFinal;
        } else returnListFinal=returnList;
       
        if(returnListFinal.size()>lim){
        list<sObject> RecordList=new list<sObject>(); 
        RecordList.AddAll(returnListFinal);
        returnListFinal.clear();    
        for(Integer i=0; i<lim; i++){
                returnListFinal.add(RecordList[i]);
         }
        }    
       }catch(Exception ex){} 
        system.debug('returnListFinal : '+returnListFinal);
        return returnListFinal;
    }
    @AuraEnabled 
    public static sObject fetchLookUpValueById(String ObjectName,String SearchField,String recordId) {
        String sQuery =  'SELECT Id,ProductCode,Family, ' +String.escapeSingleQuotes(SearchField) + ' FROM ' +String.escapeSingleQuotes(ObjectName) + ' WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
        system.debug('fetchLookUpValueById sQuery==>'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        if(lstOfRecords.size()>0)return lstOfRecords[0]; return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<sobject> findRecords(String searchKey, String objectName){
        String searchText ='%' + String.escapeSingleQuotes(searchKey) + '%'; 
        string query = 'SELECT Id, Name ,ProductCode,Family FROM ' +String.escapeSingleQuotes(objectName)+ ' WHERE (Name LIKE :searchText Or ProductCode Like :searchText or Family LIKE: searchKey) LIMIT 10';
        system.debug('query : '+query);
        return Database.query(query);
        //return Database.query('SELECT Id, Name,ProductCode FROM ' +String.escapeSingleQuotes(objectName)+ ' WHERE (Name LIKE '+String.escapeSingleQuotes(searchText)+' Or ProductCode Like ' + String.escapeSingleQuotes(searchText)+ ') LIMIT 10');
    }
}