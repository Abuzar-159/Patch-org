/*
* Created By : Moin
* Date : 17th April 2023
* Reason : to Prevent the Posting of Debit Note is their is any mismatch in the creation of ledger Entries
* 
*/

trigger PreventDebitNotePosting on ERP7__Debit_Note__c (after insert, after update) { //changed from after to  before 
    List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
    accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];
    Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
    for(ERP7__Accounting_Period__c acc :accperiodList){
         accountingPeriodMapBYName.put(acc.Name,acc);
    }
    for(ERP7__Debit_Note__c db:(List<ERP7__Debit_Note__c>) System.Trigger.New){
        //if(db.ERP7__Credit_Note_Date__c== null) db.ERP7__Credit_Note_Date__c= system.Today();
        if(db.ERP7__Credit_Note_Date__c!= null){
            string month = (String.valueof(db.ERP7__Credit_Note_Date__c.month()).length() > 1)? String.valueof(db.ERP7__Credit_Note_Date__c.month()) : '0'+db.ERP7__Credit_Note_Date__c.month();
            String periodName = db.ERP7__Credit_Note_Date__c.year()+'-'+month;
            if(accountingPeriodMapBYName.get(periodName) != null ){
                if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed')
                    db.addError('Accounting Period is Closed, cannot update the Debit Note.');
            }
        }
    }
    /*Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
        List<Id> DBIds = new List<Id>();
        for(ERP7__Debit_Note__c debit : Trigger.new){
            if(debit.ERP7__Posted__c && trigger.oldMap.get(debit.Id).ERP7__Posted__c != debit.ERP7__Posted__c){
                DBIds.add(debit.Id);
            }
        }
        if(DBIds.size()>0){
            List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'POReturn'];
            if(coaMap.size()<2){
                Trigger.newMap.get(DBIds[0]).addError('Please set up the Coa Mapping of Type POReturn');
            }
            
            
            List<ERP7__Debit_Note_Item__c> dbItems = new List<ERP7__Debit_Note_Item__c>();
            dbItems = [select Id, Name, ERP7__Chart_Of_Account__c, ERP7__Bill__c, ERP7__Debit_Note__c  from ERP7__Debit_Note_Item__c where ERP7__Debit_Note__c IN :DBIds];
            Map<Id, List<ERP7__Debit_Note_Item__c>> DBMap = new Map<Id, List<ERP7__Debit_Note_Item__c>>();
            for(ERP7__Debit_Note_Item__c dbItem : dbItems){
                if(DBMap.containskey(dbItem.ERP7__Debit_Note__c)){
                    DBMap.get(dbItem.ERP7__Debit_Note__c).add(dbItem);
                }else{
                    List<ERP7__Debit_Note_Item__c> dbItemz = new List<ERP7__Debit_Note_Item__c>();
                    dbItemz.add(dbItem);
                    DBMap.put(dbItem.ERP7__Debit_Note__c, dbItemz);
                }
            }
            for(Id DBId : DBIds){
                if(DBMap.size()>0){
                    for(ERP7__Debit_Note_Item__c  dbItem : DBMap.get(DBId)){
                        if(dbItem.ERP7__Chart_Of_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Inventory or Expense Account for the Line Item- '+ dbItem.Name;
                            Trigger.newMap.get(DBId).addError(errMessage);
                        }
                    }
                }
            }
        }
    }*/
}