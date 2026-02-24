trigger DebitNoteItemTrigger on ERP7__Debit_Note_Item__c (after insert, after update) {
    List<ERP7__Debit_Note_Item__c> debitNoteItems = [
        SELECT Id, 
        ERP7__Posted__c,
        ERP7__Total_Amount__c,
        ERP7__Debit_Note__c,
        ERP7__Debit_Note__r.ERP7__Organisation__c
        FROM ERP7__Debit_Note_Item__c 
        WHERE Id IN :Trigger.newMap.keySet()
    ];
    Map<Id, ERP7__Transaction__c> transactionMap = new Map<Id, ERP7__Transaction__c>();
    List<ERP7__Transaction__c> transactionList = new List<ERP7__Transaction__c>();
    List<ERP7__Transaction__c> Transactions2update = new List<ERP7__Transaction__c>();
    transactionList = [select Id, Name, ERP7__Debit_Note_Item__c from ERP7__Transaction__c where ERP7__Debit_Note_Item__c IN :Trigger.newMap.keyset()];
    if(transactionList.size()>0){
        for(ERP7__Transaction__c trans : transactionList){
            transactionMap.put(trans.ERP7__Debit_Note_Item__c, trans);
        }
    }
    for(ERP7__Debit_Note_Item__c deline : debitNoteItems){//Trigger.new chnaged by asra 11/2/1
        if(deline.ERP7__Posted__c){
            ERP7__Transaction__c trans;
            if(transactionMap.containsKey(deline.Id)){
                trans = transactionMap.get(deline.Id);
            }else{
               trans  = new  ERP7__Transaction__c();
            }
            //Transaction__c trans = new Transaction__c();
            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true; 
            //if(Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isUpdateable()) trans.ERP7__Customer__c = dNote.Account__c; 
            System.debug('DB value: ' + deline.ERP7__Debit_Note__r.ERP7__Organisation__c);
            if(Schema.sObjectType.Transaction__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Organisation__c.isUpdateable()) trans.ERP7__Organisation__c = deline.ERP7__Debit_Note__r.ERP7__Organisation__c;//added by asra 11/2/26
            System.debug('trans.ERP7__Organisation__c: ' + trans.ERP7__Organisation__c);
            if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = deline.ERP7__Total_Amount__c!=null?deline.ERP7__Total_Amount__c:0;//+dNote.Tax_Amount__c!=null?dNote.Tax_Amount__c:0;
            if(Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isUpdateable()) trans.ERP7__Debit_Note__c = deline.ERP7__Debit_Note__c; 
            trans.ERP7__Debit_Note_Item__c = deline.Id;
            if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();  
            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'POReturn'; 
            //if(SalesReturn != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = SalesReturn;
            Transactions2update.add(trans);
        }
    }
    
    if(Transactions2update.size()>0){
        upsert Transactions2update;
    }

}