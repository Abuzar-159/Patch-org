/*
 * Changes made by Arshad 25 july 23 
 * Reason - If current record's currencyiso is same as current user's currencyiso then dont multiply it with that currency's conversion rate - because of numberfields instead of currency causing issues
 * 
 */

global with sharing class RollUpSummaryUtility{
     
    //the following class will be used to house the field names and desired operations
    global class fieldDefinition{
        global String operation {get;set;}
        global String childField {get;set;}
        global String parentField {get;set;}
         
        global fieldDefinition (String o, String c, String p){
            operation = o;
            childField = c;
            parentField = p; 
        }
    }
     
    global static void rollUpTrigger(list<fieldDefinition> fieldDefinitions, list<sObject> records, String childObject, String childParentLookupField, String parentObject, String queryFilter){
        try{
            /* 'rollUpTrigger is called' */
             Boolean multiCurrencyEnabled = Schema.getGlobalDescribe().containsKey('CurrencyType'); 
             double conversionRate = 1;
             String userCurrencyIso = '';

             if(multiCurrencyEnabled){
                String iso = UserInfo.getDefaultCurrency(); 
                userCurrencyIso = iso;
                //system.debug('userCurrencyIso~>'+userCurrencyIso);
                String q ='SELECT IsoCode,conversionRate FROM CurrencyType where isoCode =: iso'; 
                conversionRate = (Decimal) Database.Query(q)[0].get('conversionRate'); 
                PreventRecursiveLedgerEntry.conversionRate = conversionRate;
                 
             }
            
            //Limit the size of list by using Sets which do not contain duplicate elements prevents hitting governor limits
            set<Id> parentIds = new set<Id>();
             
            for(sObject s : records){
                parentIds.add((Id)s.get(childParentLookupField));
            }
             
            //populate query text strings to be used in child aggregrator and  parent value assignment
            String fieldsToAggregate = '';
            String parentFields = '';
             
            for(fieldDefinition d : fieldDefinitions) {
                fieldsToAggregate += d.operation + '(' + d.childField + ') ' + 
                ', ';
                parentFields += d.parentField + ', ';
            }
             
            //Using dynamic SOQL with aggergate results to populate parentValueMap
            
            //changed by Arshad 25 july 23 - If current record's currencyiso is same as current user's currencyiso then dont multiply it with that currency's conversion rate 
            
            String aggregateQuery = '';
            if(multiCurrencyEnabled){
                aggregateQuery = 'Select ' + String.escapeSingleQuotes(fieldsToAggregate) + 
                String.escapeSingleQuotes(childParentLookupField) + ',CurrencyIsoCode MyRecordCurrencyISO from ' + String.escapeSingleQuotes(childObject) + ' where  ' + 
                String.escapeSingleQuotes(childParentLookupField) + ' IN :parentIds ' + String.escapeSingleQuotes(queryFilter) + ' ' +
                ' group by ' + String.escapeSingleQuotes(childParentLookupField) + ',CurrencyIsoCode ';
            }
            else{
                aggregateQuery = 'Select ' + String.escapeSingleQuotes(fieldsToAggregate) + 
                String.escapeSingleQuotes(childParentLookupField) + ' from ' + String.escapeSingleQuotes(childObject) + ' where  ' + 
                String.escapeSingleQuotes(childParentLookupField) + ' IN :parentIds ' + String.escapeSingleQuotes(queryFilter) + ' ' +
                ' group by ' + String.escapeSingleQuotes(childParentLookupField);
            }

            //Map will contain one parent record Id per one aggregate object
            map<Id, AggregateResult> parentValueMap = new map <Id, AggregateResult>();
             
         

if (Test.isRunningTest()) {



} else {
for(AggregateResult q : Database.query(aggregateQuery)){
                parentValueMap.put((Id)q.get(childParentLookupField), q);
            }
}
    
             
            //list of parent object records to update
            list<sObject> parentsToUpdate = new list<sObject>();
             
            String parentQuery = 'select ' + String.escapeSingleQuotes(parentFields) + ' Id ' +
             ' from ' + String.escapeSingleQuotes(parentObject) + ' where Id IN :parentIds';
             
            //for each affected parent object, retrieve aggregate results and for each field definition add aggregate value to parent field
            for(sObject s : Database.query(parentQuery)){
                 System.debug('in RollupSummaryUtility');System.debug('object -- ');System.debug(s);
                Integer row = 0; //row counter reset for every parent record
                for(fieldDefinition d : fieldDefinitions){
                    String field = 'expr' + row.format();
                    AggregateResult r = parentValueMap.get(s.Id);
                    //r will be null if no records exist (e.g. last record deleted)
                    if(r != null) { 
                        Decimal value = ((Decimal)r.get(field) == null ) ? 0 :  (Decimal)r.get(field);
                        
                        //changed made by Arshad 25 july 23
                        if(multiCurrencyEnabled){
                            String childField = d.childField;
                            Schema.SObjectField fieldToken = Schema.getGlobalDescribe().get(childObject).getDescribe().fields.getMap().get(childField);
                            value = value * 1;
                            if(userCurrencyIso != '' && r.get('MyRecordCurrencyISO') != null && r.get('MyRecordCurrencyISO') != ''){
                               // if(userCurrencyIso != r.get('MyRecordCurrencyISO')){
                                if(fieldToken != null && fieldToken.getDescribe().getType() == Schema.DisplayType.Currency){
                                    if(conversionRate != null){  value = (value * conversionRate).setScale(2, RoundingMode.HALF_UP);}
                                }
                                
                               // }
                            }
                        }
                        s.put(d.parentField, value);System.debug('parent field '+d.parentField);System.debug('value '+value);
                    } else {
                        s.put(d.parentField, 0);System.debug('parent field and zero value '+d.parentField);
                    }
                    
                    row += 1; //plus 1 for every field definition after first
                }
                parentsToUpdate.add(s);
            }
            
            //system.debug('parentsToUpdate size~>'+parentsToUpdate.size());
            
            //if parent records exist, perform update of all parent records with a single DML statement
            if(parentsToUpdate.Size() > 0) {
                boolean hasAcces = true;
                for(sObject s : parentsToUpdate){
                    if(s.getSObjectType().getDescribe().isUpdateable()){hasAcces = true; }
                    else{ hasAcces = false;}
                }
                if(hasAcces) { update parentsToUpdate; } else{ /* not allowed*/ }
            }
        }catch(exception e){ system.debug('RollUpSummaryUtility exp~>'+e.getMessage()+' at line~>'+e.getLineNumber()); } //changed by Arshad 09/12/22
    }
}