trigger Debit_Note_Trigger on Debit_Note__c (before update,before insert,after insert, after update, before delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {  new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount__c', 'ERP7__Debit_Note_Balance__c')
                };
                    RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.old, 'Debit_Note__c','ERP7__Account__c', 'Account', ' And ERP7__Active__c = true');
        }
    }
    else{ 
        if(!Trigger.isDelete){
            list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
                new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Remaining_Amount__c', 'ERP7__Debit_Note_Balance__c')
                    };
                        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.new, 'Debit_Note__c','ERP7__Account__c', 'Account', ' And ERP7__Active__c = true');
        }
    }
    
    if(Trigger.isAfter){
        Map<String, Decimal> accToUpdate = new Map<String, Decimal>();
        Set<Id> debIds = new Set<Id>();
        List<Transaction__c> Transactions2update = new List<Transaction__c>();
        if(!Trigger.isDelete){
            Id SalesReturn = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Transaction__c','Expense_Transaction'); 
            Map<Id,Id> ExistingTransaction = new Map<Id,Id>(); Boolean oldPosted = false;
            for(ERP7__Debit_Note__c dNote : Trigger.New){
                if(Trigger.oldMap != null){
                    if(Trigger.oldMap.get(dNote.Id).Posted__c){oldPosted = false;} else {oldPosted = true;}
                    
                }else{
                    oldPosted = true; 
                }
                if(dNote.Posted__c){
                    /*
                    Transaction__c trans = new Transaction__c();
                    if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true; 
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isUpdateable()) trans.ERP7__Customer__c = dNote.Account__c; 
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Organisation__c.isUpdateable()) trans.ERP7__Organisation__c = dNote.ERP7__Organisation__c;
                    if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = dNote.ERP7__Amount__c!=null?dNote.ERP7__Amount__c:0;//+dNote.Tax_Amount__c!=null?dNote.Tax_Amount__c:0;
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isUpdateable()) trans.ERP7__Debit_Note__c = dNote.Id; 
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();  
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Debit'; 
                    if(SalesReturn != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = SalesReturn;
                    Transactions2update.add(trans); 
                    if((dNote.ERP7__Amount__c>0 || dNote.ERP7__Debit__c>0 ) && dNote.Account__c != null){
                        if(accToUpdate.get(dNote.Account__c)==null) accToUpdate.put(dNote.Account__c, dNote.ERP7__Amount__c!=null?dNote.ERP7__Amount__c:dNote.ERP7__Debit__c!=null?dNote.ERP7__Debit__c:0);
                        else accToUpdate.put(dNote.Account__c, accToUpdate.get(dNote.Account__c)+dNote.ERP7__Amount__c!=null?dNote.ERP7__Amount__c:dNote.ERP7__Debit__c!=null?dNote.ERP7__Debit__c:0);
                    }
					*/
                    debIds.add(dNote.Id);
                }
                
            }
            List<ERP7__Debit_Note_Item__c> debItem = new List<ERP7__Debit_Note_Item__c>();
            debItem = [select Id, ERP7__Posted__c from ERP7__Debit_Note_Item__c where ERP7__Debit_Note__c IN:debIds and ERP7__Posted__c=false];
            if(debItem.size()>0){
                for(ERP7__Debit_Note_Item__c dline : debItem){
                    dline.ERP7__Posted__c = true;
                }
                update debItem;
                
                PostingPreventingHandler.handleDebitNoteAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap); 
            }
        }
        if(accToUpdate.size()>0){
            List<Account> accounts = [Select id,ERP7__Total_Due__c From Account where id IN : accToUpdate.keySet() ];
            for(Account acc : accounts ){
                if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()){
                    if(acc.ERP7__Total_Due__c == null) acc.ERP7__Total_Due__c = 0;
                    acc.ERP7__Total_Due__c  = acc.ERP7__Total_Due__c + accToUpdate.get(acc.id); 
                }
            }
            if(Schema.sObjectType.Account.isCreateable() && Schema.sObjectType.Account.isUpdateable()){ upsert accounts; } else{ /* no access */ }
        }
        if(Transactions2update.size() > 0 && Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()){ upsert Transactions2update; } else{ /* no access*/ }
        
    }
    
    // trigger to handle debit note delete and update account, delete transaction
    if(trigger.isbefore){
        try{
            Map<String, Decimal> accToUpdate= new Map<String, Decimal>();
            Map<String, Boolean> debitPosted =new Map<String, Boolean>();
            Set<id> Dbids = new Set<id>();
            if(trigger.isDelete){
                for(Debit_Note__c Db:trigger.old)
                {
                    Dbids.add(Db.Id);
                    if(Db.ERP7__Posted__c){  debitPosted.put(Db.ERP7__Account__c, true);
                                          }
                    if(accToUpdate.get(Db.ERP7__Account__c) == null){  accToUpdate.put( Db.ERP7__Account__c,  Db.ERP7__Amount__c );
                                                                    }else{
                                                                        accToUpdate.put( Db.ERP7__Account__c, accToUpdate.get(Db.ERP7__Account__c) + Db.ERP7__Amount__c );
                                                                    } 
                    
                }
                List<Account> accounts = [Select id,ERP7__Total_Due__c,ERP7__Debit_Note_Balance__c from Account where id IN : accToUpdate.keyset() ];
                for(Account a : accounts){
                    if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()){
                        if(debitPosted.size() > 0 && debitPosted.get(a.Id)){ a.ERP7__Total_Due__c -= accToUpdate.get(a.Id); }
                    }
                    if(Schema.sObjectType.Account.fields.ERP7__Debit_Note_Balance__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Debit_Note_Balance__c.isUpdateable()) a.ERP7__Debit_Note_Balance__c -= accToUpdate.get(a.Id); 
                }
                if(accounts.size() > 0 && Schema.sObjectType.Account.isCreateable() && Schema.sObjectType.Account.isUpdateable()){ upsert accounts; } else{ /* no access */ }
                list<Transaction__c> trans=[select id,Debit_Note__c from Transaction__c where Debit_Note__c in:Dbids];
                if(trans.size()>0 && Transaction__c.sObjectType.getDescribe().isDeletable()) { delete trans; } else{ /* no access */ } 
                list<ERP7__Payment__c> paymts =[select id,ERP7__Debit_Note__c from ERP7__Payment__c where ERP7__Debit_Note__c in:Dbids];
                if(paymts.size()>0 && ERP7__Payment__c.sObjectType.getDescribe().isDeletable()) { delete paymts; } else{ /* no access */ }
            }
        }catch(Exception e){
            /* 'Exception occured in Debit NOte Trigger' */
        }
    }
    
    
    
    //End of  trigger to handle debit note delete and update account, delete transaction
    
}