public With Sharing class InputLookUp {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName,String queryFilter,String SearchField) {
        system.debug('ObjectName-->' + ObjectName+'  ,queryFilter==>'+queryFilter);
        String searchKey ='%' + String.escapeSingleQuotes(searchKeyWord) + '%';     
        queryFilter = (String.isBlank(queryFilter))? '' : queryFilter;
        List < sObject > returnList = new List < sObject > ();
        Integer lim = 20;
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 10   
        String sQuery =  'select id, ' +String.escapeSingleQuotes(SearchField) + ' from ' +String.escapeSingleQuotes(ObjectName) + ' where ' +String.escapeSingleQuotes(SearchField) + ' LIKE: searchKey '+String.valueOf(queryFilter)+' order by createdDate DESC LIMIT 100	'; //LastModifiedDate limit 6      
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
        
        return returnListFinal;
    }
    @AuraEnabled 
    public static sObject fetchLookUpValueById(String ObjectName,String SearchField,String recordId) {
        String sQuery =  'SELECT Id, ' +String.escapeSingleQuotes(SearchField) + ' FROM ' +String.escapeSingleQuotes(ObjectName) + ' WHERE Id =\''+String.escapeSingleQuotes(recordId)+'\'';
        system.debug('fetchLookUpValueById sQuery==>'+sQuery);
        List < sObject > lstOfRecords = Database.query(sQuery);
        if(lstOfRecords.size()>0)return lstOfRecords[0]; return null;
    }

    @AuraEnabled(cacheable=true)
    public static List<sobject> findRecords(String searchKey, String objectName){
        string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';
        string query = 'SELECT Id, Name FROM ' +String.escapeSingleQuotes(objectName)+ ' WHERE Name LIKE '+String.escapeSingleQuotes(searchText)+' LIMIT 10';
        system.debug('query old: '+query);
        return Database.query('SELECT Id, Name FROM ' +String.escapeSingleQuotes(objectName)+ ' WHERE Name LIKE '+String.escapeSingleQuotes(searchText)+' LIMIT 10');
    }
}