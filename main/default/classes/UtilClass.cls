global with sharing Class UtilClass{
    
     global static string selectStarFromSObject(String sObjectName){
         //system.debug('sObjectName before~>'+sObjectName);
         if(sObjectName.containsIgnoreCase('__c')) sObjectName = (sObjectName.containsIgnoreCase('ERP7__'))? sObjectName:'ERP7__'+ String.escapeSingleQuotes(sObjectName);
         //system.debug('sObjectName after~>'+sObjectName);
         Map<String, Schema.SObjectField> fieldMap = schema.getGlobalDescribe().get(String.escapeSingleQuotes(sObjectName)).getDescribe().fields.getMap();           
         String allFields = '';
         Set<String> ignoredFieldsSet = new Set<String>{'isdeleted', 'systemmodstamp', 'lastvieweddate', 'lastreferenceddate'}; //Added by Arshad 12 Oct
         
         set<String> allfieldsSet = new set<String>();
         for(String fieldName : fieldMap.keyset())
             if(!allfieldsSet.contains(fieldName) && !ignoredFieldsSet.contains(fieldName)){ //Added by Arshad 12 Oct && !ignoredFieldsSet.contains(fieldName)
                 allfieldsSet.add(fieldName);
                 if(String.isEmpty(allFields))
                     allFields = String.escapeSingleQuotes(fieldName); 
                 else
                     allFields +=', '+fieldName; 
                 
             }
         
         return String.escapeSingleQuotes(allFields);
     }
    /*Get Organisation data by login Employee*/ 
    global static Account getOrganisationByLogin_Employee(){
        try{
        List<ERP7__Employees__c> employeeList = new List<ERP7__Employees__c>();
        employeeList = [SELECT Id, Name, ERP7__Organisation__c,ERP7__Organisation__r.Name  FROM ERP7__Employees__c WHERE ERP7__Employee_User__c = : UserInfo.getUserId()];
        if(employeeList.size()>0 && employeeList[0].ERP7__Organisation__c != null)
            return new Account(Id=employeeList[0].ERP7__Organisation__c,Name=employeeList[0].ERP7__Organisation__r.Name);
        else{
            return [Select Id,Name FROM Account WHERE (Account_Type__c = 'Organisation' OR ERP7__Account_Type__c='Organisation/Vendor') AND Default__c =true limit 1];
        }
        }catch(QueryException ex){
            try{
                return [Select Id,Name FROM Account WHERE (Account_Type__c = 'Organisation' OR ERP7__Account_Type__c='Organisation/Vendor') AND Default__c =true limit 1];
            }catch(Exception e){return  new Account();}            
        }catch(Exception ex){
            return  new Account();
        }
       // return  new Account();
    }
    global static List<String> getFieldsSetApiName(String sObjectName,string fieldSetApiName){
        List<String> fields = new List<String>();
        for(Schema.FieldSetMember field:
            schema.getGlobalDescribe().get(sObjectName).getDescribe().fieldSets.getMap().get(fieldSetApiName).getFields())
            fields.add(field.getFieldPath());
        return fields;
    }
    global static List<String> getFieldsSetLabelName(String sObjectName,string fieldSetApiName){
        List<String> fields = new List<String>();
        for(Schema.FieldSetMember field:
            schema.getGlobalDescribe().get(sObjectName).getDescribe().fieldSets.getMap().get(fieldSetApiName).getFields())
            fields.add(field.getLabel());
        return fields;
    }
    global static void FlSCheck(String [] fieldsToCheck,String  sObjectName){
        try{
            if(sObjectName.containsIgnoreCase('__c'))sObjectName = (sObjectName.containsIgnoreCase('ERP7__'))? sObjectName:'ERP7__'+sObjectName;
            Map<String, Schema.SObjectField> fieldMap = schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap(); 
            for (String fieldToCheck : fieldsToCheck) {
                if(fieldMap.get(fieldToCheck.toLowerCase().trim()) == null) throw new FLSException('Invalid Field '+fieldToCheck+' does not belongs to sObject '+schema.getGlobalDescribe().get(sObjectName).getDescribe().getLabel());
                if (!fieldMap.get(fieldToCheck.toLowerCase().trim()).getDescribe().isAccessible()) {
                    throw new FLSException('Insufficient access To Field For Field '+fieldToCheck+'(API NAME) '+fieldMap.get(fieldToCheck.toLowerCase().trim()).getDescribe().getLabel()+' of sObject '+schema.getGlobalDescribe().get(sObjectName).getDescribe().getLabel());
                //    return ;
                }
            }
        }catch(FLSException e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,e.getMessage()+' @ line Number '+e.getLineNumber()));
            return ;
        }
        catch(Exception e){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Exception Occured: '+e.getMessage()+'Line No:'+e.getLineNumber()));
        }
    }
    global class FLSException extends Exception{}
}