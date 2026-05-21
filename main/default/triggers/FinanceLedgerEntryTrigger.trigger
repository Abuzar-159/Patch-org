trigger FinanceLedgerEntryTrigger on Finance_General_Ledger_Entry__c (after delete, after insert,after update, after undelete) {
     
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(Trigger.isUpdate && Trigger.isAfter && RunModule.get('Finance').ERP7__Accounting_Period_Password__c){
        List<Date> transDateList = new List<Date>();
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();   }
        for(Finance_General_Ledger_Entry__c fgle : Trigger.new){
            system.debug('password -->'+fgle.ERP7__Accounting_Period_Password__c);
            if(fgle.ERP7__General_Ledger_Entry_DateTime__c!=null){
                transDateList.add(Date.valueOf(fgle.ERP7__General_Ledger_Entry_DateTime__c));
            }
        }
        if(transDateList.size()>0){
            system.debug('transDateList-->'+transDateList.size());
            if(Trigger.new[0].ERP7__Accounting_Period_Password__c==null){
                if(PostingPreventingHandler.checkForAccountingPeriodClosing(transDateList[0])){
                    Trigger.new[0].addError('Accounting Period is closed please enter the password from Edit Transactions');
                }
            }else{
                if(PostingPreventingHandler.checkForAccountingPeriodClosingPassword(transDateList[0], Trigger.new[0].ERP7__Accounting_Period_Password__c) && FC.ERP7__Closing_Period_Password_Process__c){
                    Trigger.new[0].addError('Password does not match with the Accounting Period Password');
                }
            }
        }
    }
    if(PreventRecursiveLedgerEntry.Proceed && (trigger.isInsert || trigger.isUpdate || trigger.isUnDelete)){
    list<RollUpSummaryUtility.fieldDefinition> fieldDefinitions = 
        new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Credit_Entry__c', 
            'ERP7__Total_Credit__c'),
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Debit_Entry__c', 
            'ERP7__Total_Debit__c')
            };
    RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, trigger.new, 
        'ERP7__Finance_General_Ledger_Entry__c', 'ERP7__Chart_of_Account__c', 'ERP7__Chart_of_Accounts__c', '');
        PreventRecursiveLedgerEntry.Proceed = false;
    }
    if(trigger.isDelete){
    list<RollUpSummaryUtility.fieldDefinition> fieldDefinitions = 
        new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Credit_Entry__c', 
            'ERP7__Total_Credit__c'),
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Debit_Entry__c', 
            'ERP7__Total_Debit__c')
            };
    RollUpSummaryUtility.rollUpTrigger(fieldDefinitions, trigger.old, 
        'ERP7__Finance_General_Ledger_Entry__c', 'ERP7__Chart_of_Account__c', 'ERP7__Chart_of_Accounts__c', '');
    }
}