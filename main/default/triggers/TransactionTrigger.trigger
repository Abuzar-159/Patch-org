/*
 * Changes made by - Syed Moin Pasha
 * Date - 10th November 2021
 * Reason - ledger entries was not getting created for invoice line items post
 * changes made to line : 16 removed the && PreventRecursiveLedgerEntry.proceed condition
 * 
 * 
 * Changes made by - Syed Moin Pasha
 * Date - 31St January 2022
 * Reason - Entries were not getting created for refund payment
 * changes made to line : add || trans.Transaction_Type__c == 'Refund' in the line 30
 * 
 * 
 * * Changes made by - Syed Moin Pasha
 * Date - 21St September 2022
 * Reason - Entries were getting duplicated for sales completed transactions
 * changes made to line : commented line 37

*/

trigger TransactionTrigger on Transaction__c(before Insert,before update,before delete,after Insert, after Update, after Delete, after unDelete) {
    if(!Test.isRunningTest())
    PreventRecursiveLedgerEntry.proceed = true; 
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    String TriggerHandlerName = 'ERP7.TransactionImpl';
    Global_Trigger_Handlers__c gv = Global_Trigger_Handlers__c.getValues('TransactionTrigger');
    if(gv != null)TriggerHandlerName = gv.ClassName__c;
    if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run__c && PreventRecursiveLedgerEntry.preventTriggerMO){//&& PreventRecursiveLedgerEntry.proceed
        if(Trigger.isUpdate && Trigger.isAfter && RunModule.get('Finance').ERP7__Accounting_Period_Password__c){
            List<Date> transDateList = new List<Date>();
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        	if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();   }
            for(Transaction__c trans : Trigger.new){
                system.debug('password -->'+trans.ERP7__Accounting_Period_Password__c);
                if(trans.ERP7__Transaction_Date__c!=null){   transDateList.add(trans.ERP7__Transaction_Date__c);
                }
            }
            if(transDateList.size()>0){
                system.debug('transDateList-->'+transDateList.size());
                if(Trigger.new[0].ERP7__Accounting_Period_Password__c==null){ if(PostingPreventingHandler.checkForAccountingPeriodClosing(transDateList[0])){   Trigger.new[0].addError('Accounting Period is closed please enter the password from Edit Transactions');
                    }
                }else{ if(PostingPreventingHandler.checkForAccountingPeriodClosingPassword(transDateList[0], Trigger.new[0].ERP7__Accounting_Period_Password__c) && FC.ERP7__Closing_Period_Password_Process__c){
                        Trigger.new[0].addError('Password does not match with the Accounting Period Password');
                    }
                }
            }
        }
        /*if (Trigger.isUpdate && Trigger.isAfter) {
            PostingPreventingHandler.handleUpdateAfter(Trigger.new, Trigger.oldMap);
        }*/
        Type t = Type.ForName(TriggerHandlerName);
        ITrigger th =(ITrigger)t.newInstance();
        if(Trigger.isAfter){
            Set<Id> TransIds = new Set<Id>();
            if(Trigger.isInsert){
                for(Transaction__c trans : Trigger.new){
                    if(trans.Transaction_Type__c == 'Sale Completed'){// || trans.Transaction_Type__c == 'Refund'
                        //TransIds.add(trans.Id);
                    }
                }
            }
            if(TransIds.size()>0){
                system.debug('calling TransactionsLedgerEntry.TriggerHandler_Insert_Update from TransactionTrigger');
                TransactionsLedgerEntry.TriggerHandler_Insert_Update(TransIds,Trigger.IsInsert);
            }
            //else{
                if(Trigger.isInsert)
                    th.afterInsert();
                /*else if(Trigger.isUpdate)
                    th.afterUpdate();*/
                else if(Trigger.isUndelete)   th.afterUndelete();
                else if(Trigger.isdelete)
                    th.afterDelete();
           // }
        }else{
            if(Trigger.isInsert)
              th.beforeInsert();
          /*else if(Trigger.isUpdate)
               th.beforeUpdate(); */
            else if(Trigger.isdelete){
                //below code to not allow tarnsaction deletion from a Closed accounting period
                Set<Id> accountingPeriodIds = new Set<Id>();Boolean hasError = false; 
                for (ERP7__Transaction__c oldTransaction : Trigger.old) {
                    if (oldTransaction.ERP7__Accounting_Period__c != null) {
                        accountingPeriodIds.add(oldTransaction.ERP7__Accounting_Period__c);
                    }
                }
                if (!accountingPeriodIds.isEmpty()) {
                    Map<Id, ERP7__Accounting_Period__c> accountingPeriods = new Map<Id, ERP7__Accounting_Period__c>([
                        SELECT Id, ERP7__Status__c
                        FROM ERP7__Accounting_Period__c
                        WHERE Id IN :accountingPeriodIds
                    ]);
                   /* for (ERP7__Transaction__c oldTransaction : Trigger.old) {
                        ERP7__Accounting_Period__c parentPeriod = accountingPeriods.get(oldTransaction.ERP7__Accounting_Period__c);
                        if (parentPeriod != null && parentPeriod.ERP7__Status__c == 'Closed') {    oldTransaction.addError('Cannot delete a transaction from a Closed accounting period. No changes are allowed once the period is closed.');hasError = true;
                        }else if (parentPeriod != null && parentPeriod.ERP7__Status__c == 'Close Pending') {   oldTransaction.addError('Cannot delete this transaction. First, open the accounting period that is currently "Close Pending" and then try again.');hasError = true;
                        }
                    }*/
                }//new code end
                if (!hasError) {th.beforeDelete();}
            }
        
        }
    }
}