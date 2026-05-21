trigger HandleSerials on ERP7__Serial_Number__c (after update, before insert, before update) {
    system.debug('PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation-->'+PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation);
    Boolean enableProdPrefixValidation = false;
    ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
    FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
    if(FC == null){   
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());  if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
    }
    if(FC != null){
        enableProdPrefixValidation = FC.ERP7__Enable_product_code_Prefix_validation__c;
    }

    if(PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation && Trigger.isBefore){
        Set<Id> prodIds = new Set<Id>();
        Set<Id> TriggeredSerialsIds = new Set<Id>();
        Set<String> TriggeredSerialsNumbers = new Set<String>(); // added by shaguftha 04/12/23 and it's functionality to limit the number of records queried
        Map<Id, List<String>> prodSerialMap = new Map<Id, List<String>>();
        for (ERP7__Serial_Number__c ser : System.trigger.new) {
            if(ser.Id != null) TriggeredSerialsIds.add(ser.Id);
            if(ser.ERP7__Serial_No__c != null && ser.ERP7__Serial_No__c != '') TriggeredSerialsNumbers.add(ser.ERP7__Serial_No__c);
            if(ser.ERP7__Product__c !=null){
                prodIds.add(ser.ERP7__Product__c);
            }
        }
        
        if(prodIds.size()>0){
            List<ERP7__Serial_Number__c> serialList = new List<ERP7__Serial_Number__c>();
            serialList = [select Id, Name, ERP7__Product__c,ERP7__Product__r.ProductCode, ERP7__Serial_No__c from ERP7__Serial_Number__c where ERP7__Product__c IN :prodIds and Id Not In :TriggeredSerialsIds and ERP7__Serial_No__c IN : TriggeredSerialsNumbers Limit 50000];
            system.debug('serialList-->'+serialList);
            if(serialList.size()>0){
                for(ERP7__Serial_Number__c ser : serialList){
                    if(ser.ERP7__Serial_No__c != null && String.isNotEmpty(ser.ERP7__Serial_No__c)){
                        if(prodSerialMap.containskey(ser.ERP7__Product__c)){
                            prodSerialMap.get(ser.ERP7__Product__c).add(ser.ERP7__Serial_No__c);
                        }else{
                            List<String> serialToAdd = new List<String>();
                            serialToAdd.add(ser.ERP7__Serial_No__c);
                            prodSerialMap.put(ser.ERP7__Product__c, serialToAdd);
                        }
                    }
                }
            }
        }
        Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id, Name, ProductCode, Description, IsActive  FROM Product2  WHERE Id IN :prodIds]); 
        system.debug('prodSerialMap-->'+prodSerialMap);
        for (ERP7__Serial_Number__c ser : System.trigger.new) {
            if (!prodSerialMap.isEmpty() && prodSerialMap.containskey(ser.ERP7__Product__c) && prodSerialMap.size()>0) {
                List<String>  serial = prodSerialMap.get(ser.ERP7__Product__c);
                system.debug('ser.ERP7__Serial_No__c-->'+ser.ERP7__Serial_No__c);
                system.debug('serial.contains(ser.ERP7__Serial_No__c)-->'+serial.contains(ser.ERP7__Serial_No__c));
                if(ser.ERP7__Serial_No__c != null && String.isNotEmpty(ser.ERP7__Serial_No__c) && serial.contains(ser.ERP7__Serial_No__c)){
                    // if(ser.ERP7__Serial_No__c == serial.ERP7__Serial_No__c){
                    ser.addError(System.Label.Duplicate_Serial_Numbers_Found+' ' + ser.ERP7__Serial_No__c);
                    break;
                    // }
                }
            }
            else if(enableProdPrefixValidation && prodMap.containskey(ser.ERP7__Product__c)){
                string prodCode = prodMap.get(ser.ERP7__Product__c).ProductCode;
                string serNo = ser.ERP7__Serial_No__c;
                if(prodCode != null && prodCode != ''){
                    if(ser.ERP7__Serial_No__c != null && String.isNotEmpty(ser.ERP7__Serial_No__c) && !serNo.startsWithIgnoreCase(prodCode)){
                        ser.addError('Serial number should start with the product code prefix');
                        break;
                    }
                }
            }
        }
        PreventRecursiveLedgerEntry.ProceedSerialsTriggerValidation = false;
    }
    
    if(PreventRecursiveLedgerEntry.ProceedSerialsTrigger && Trigger.isUpdate){
        Set<String> existingSerialNumbers = new Set<String>();
        Set<Id> serialsIds = new Set<Id>();
        Set<Id> TriggeredSerialsIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        Set<String> TriggeredSerialsNumbers = new Set<String>(); // added by shaguftha 04/12/23 and it's functionality
        Map<Id, List<String>> prodSerialMap = new Map<Id, List<String>>();
        for (ERP7__Serial_Number__c ser : System.trigger.new) {
            TriggeredSerialsIds.add(ser.Id);
            if(ser.ERP7__Serial_No__c != null && ser.ERP7__Serial_No__c != '') TriggeredSerialsNumbers.add(ser.ERP7__Serial_No__c);
            if(ser.ERP7__Product__c !=null){
                prodIds.add(ser.ERP7__Product__c);
            }
        }
        
        if(prodIds.size()>0){
           
            List<ERP7__Serial_Number__c> serialList = new List<ERP7__Serial_Number__c>();
            serialList = [select Id, Name, ERP7__Product__c, ERP7__Serial_No__c  from ERP7__Serial_Number__c where ERP7__Product__c IN :prodIds and Id NOT IN :TriggeredSerialsIds and ERP7__Serial_No__c IN : TriggeredSerialsNumbers LIMIT 50000];
            if(serialList.size()>0){
                for(ERP7__Serial_Number__c ser : serialList){
                    if(ser.ERP7__Serial_No__c != null && String.isNotEmpty(ser.ERP7__Serial_No__c)){
                        if(prodSerialMap.containskey(ser.ERP7__Product__c)){
                            prodSerialMap.get(ser.ERP7__Product__c).add(ser.ERP7__Serial_No__c);
                        }else{
                            List<String> serialToAdd = new List<String>();
                            serialToAdd.add(ser.ERP7__Serial_No__c);
                            prodSerialMap.put(ser.ERP7__Product__c, serialToAdd);
                        }
                    }
                }
            }
        }
        Map<Id, Product2> prodMap = new Map<Id, Product2>([SELECT Id, Name, ProductCode, Description, IsActive  FROM Product2  WHERE Id IN :prodIds]); 
        
        for (ERP7__Serial_Number__c ser : System.trigger.new) {
            // Check if the serial number already exists in the system
            if (!prodSerialMap.isEmpty() && prodSerialMap.containskey(ser.ERP7__Product__c) && prodSerialMap.size()>0) {
                List<String>  serial = prodSerialMap.get(ser.ERP7__Product__c);
                system.debug('ser.ERP7__Serial_No__c : '+ser.ERP7__Serial_No__c);
                system.debug('serial.contains(ser.ERP7__Serial_No__c) : '+serial.contains(ser.ERP7__Serial_No__c));
                if(ser.ERP7__Serial_No__c != null && String.isNotEmpty(ser.ERP7__Serial_No__c) && serial.contains(ser.ERP7__Serial_No__c)){
                    ser.addError(System.Label.Duplicate_Serial_Numbers_Found+' ' + ser.ERP7__Serial_No__c);
                    break;
                }
            }
            else if(enableProdPrefixValidation && prodMap.containskey(ser.ERP7__Product__c)){
                string prodCode = prodMap.get(ser.ERP7__Product__c).ProductCode;
                string serNo = ser.ERP7__Serial_No__c;
                if(ser.ERP7__Serial_No__c != null && String.isNotEmpty(ser.ERP7__Serial_No__c) && !serNo.startsWithIgnoreCase(prodCode)){
                     ser.addError('Serial number should start with the product code prefix');
                    break;
                }
            }
            if ((ser.ERP7__Available__c || ser.ERP7__Scrap__c) && ser.ERP7__Product__c != null && ser.ERP7__WIP__c != null) {
                serialsIds.add(ser.Id);
            }
        } 
       
        if (serialsIds.size() > 0) {
             //new code below
            List<ERP7__Serial_Number__c> ser2= [select Id, Name, ERP7__Product__c, ERP7__Serial_No__c, ERP7__WIP__c,ERP7__WIP__r.ERP7__Material_Batch_Lot__c   from ERP7__Serial_Number__c where Id in :TriggeredSerialsIds limit 1];
        //	List<ERP7__Batch__c> batch=[Select Id, Name, ERP7__Account__c, ERP7__Active__c, ERP7__Inward_Quantity__c, ERP7__Outward_Quantity__c, ERP7__Product__c From ERP7__Batch__c Where ];
        	String batchLotId='';
            if(!ser2.isEmpty() && ser2[0].ERP7__WIP__c!=null && ser2[0].ERP7__WIP__r.ERP7__Material_Batch_Lot__c !=null){
                batchLotId=ser2[0].ERP7__WIP__r.ERP7__Material_Batch_Lot__c ;
                System.debug('ser2 to check serial fields');
                System.debug(ser2[0]);
            }
            System.debug('batchlot --- '+batchLotId);
            //new code end
            PreventRecursiveLedgerEntry.ProceedSerialsTrigger = false;
            if(batchLotId!=''){//new condition
               MaintainBatchStocks.createInventorySB(serialsIds,batchLotId); 
            }else{
               MaintainBatchStocks.createInventory(serialsIds); 
            }
            
        }
    }
}