/*
* Created By : Moin
* Date : 17th April 2023
* Reason : to Prevent the Posting of Credit Note is their is any mismatch in the creation of ledger Entries
* 
*/
trigger PreventCreditNotePosting on ERP7__Credit_Note__c (after insert, after update) {
    List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
    accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];
    Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
    for(ERP7__Accounting_Period__c acc :accperiodList){
         accountingPeriodMapBYName.put(acc.Name,acc);
    }
    for(ERP7__Credit_Note__c  cn:(List<ERP7__Credit_Note__c>) System.Trigger.New){
        //if(cn.ERP7__Date__c== null) cn.ERP7__Date__c= system.Today();
        if(cn.ERP7__Date__c!= null){
            string month = (String.valueof(cn.ERP7__Date__c.month()).length() > 1)? String.valueof(cn.ERP7__Date__c.month()) : '0'+cn.ERP7__Date__c.month();
            String periodName = cn.ERP7__Date__c.year()+'-'+month;
            if(accountingPeriodMapBYName.get(periodName) != null ){
                if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed')
                    cn.addError('Accounting Period is Closed, cannot update the Credit Note.');
            }
        }
    }
    /*Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
        List<Id> CreditIds = new List<Id>();
        for(ERP7__Credit_Note__c cred : Trigger.new){
            if(cred.ERP7__Posted__c && trigger.oldMap.get(cred.Id).ERP7__Posted__c != cred.ERP7__Posted__c){
                CreditIds.add(cred.Id);
            }
        }
        
        if(CreditIds.size()>0){
            List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'CreditsReturn'];
            if(coaMap.size()<2){
                Trigger.newMap.get(CreditIds[0]).addError('Please set up the Coa Mapping of Type CreditsReturn');
            }
            List<ERP7__Credit_Note_Item__c> credItems = new List<ERP7__Credit_Note_Item__c>();
            credItems = [select Id, Name, ERP7__Product__c, ERP7__Credit_Note__c, ERP7__Product__r.ERP7__Expense_Account__c, ERP7__Product__r.ERP7__Revenue_Account__c, ERP7__Product__r.ERP7__Inventory_Account__c   from ERP7__Credit_Note_Item__c where ERP7__Credit_Note__c IN :CreditIds];
            Map<Id, List<ERP7__Credit_Note_Item__c>> credMap = new Map<Id, List<ERP7__Credit_Note_Item__c>>();
            for(ERP7__Credit_Note_Item__c credItem : credItems){
                if(credMap.containskey(credItem.ERP7__Credit_Note__c)){
                    credMap.get(credItem.ERP7__Credit_Note__c).add(credItem);
                }else{
                    List<ERP7__Credit_Note_Item__c> credItemz = new List<ERP7__Credit_Note_Item__c>();
                    credItemz.add(credItem);
                    credMap.put(credItem.ERP7__Credit_Note__c, credItemz);
                }
            }
            for(Id credId : CreditIds){
                if(credMap.size()>0){
                    for(ERP7__Credit_Note_Item__c  credline : credMap.get(credId)){
                        if(credline.ERP7__Product__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Product for line item - '+ credline.Name;
                            Trigger.newMap.get(credId).addError(errMessage);
                        }
                        else if(credline.ERP7__Product__r.ERP7__Expense_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Expense Account of the Product for line item - '+ credline.Name;
                            Trigger.newMap.get(credId).addError(errMessage);
                        }
                        else if(credline.ERP7__Product__r.ERP7__Revenue_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check  the Revenue Account of the the Product for line item - '+ credline.Name;
                            Trigger.newMap.get(credId).addError(errMessage);
                        }
                        else if(credline.ERP7__Product__r.ERP7__Inventory_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Inventory Account of the Product for line item - '+ credline.Name;
                            Trigger.newMap.get(credId).addError(errMessage);
                        }
                    }
                }
            }
        }
    }*/
}