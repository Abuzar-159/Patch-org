global with sharing class RecordTypeUtil {
    global static String getObjectRecordTypeIds(String objName, String recordTypeDeveloperName) {        
        //Retrieve the record type id by name 
        if(objName.containsIgnoreCase('__c')) objName = (objName.containsIgnoreCase('ERP7__')) ? objName : 'ERP7__'+objName;               
        return Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
    }
    
    global static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName) { 
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = sObjectType.getDescribe().getRecordTypeInfosByName(); 
        if(!recordTypeInfo.containsKey(recordTypeName))  
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');  
        return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        
    }
      public static String getObjectRecordTypeIdByDeveloperName(SObjectType sObjectType, String recordTypeName) { 
         Map<String,Schema.RecordTypeInfo> recordTypeInfo = new Map<String,Schema.RecordTypeInfo>();
        for(Schema.RecordTypeInfo sr:sObjectType.getDescribe().getRecordTypeInfosByName().values())
            recordTypeInfo.put(sr.getDeveloperName(),sr);
        if(!recordTypeInfo.containsKey(recordTypeName))  
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');  
        return recordTypeInfo.get(recordTypeName).getRecordTypeId();
        
    }

    global class RecordTypeException extends Exception{}
}