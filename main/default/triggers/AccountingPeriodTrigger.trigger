/* changes made by - Moin
* Date - 25th july 2024
* Reason - for adding the password process for closing accounting period
*/
trigger AccountingPeriodTrigger on ERP7__Accounting_Period__c (before insert,before update) {
    if(trigger.isBefore){ 
        ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c(); FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());    if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();   }
        if(trigger.isInsert || trigger.isUpdate){
            Set<Id> closedAccoutingPeriod_Ids = new Set<Id>();
            Date previousStartDate;
            Date previousEndDate; 
            boolean Error_flag = false; 
            for(ERP7__Accounting_Period__c accountingPeriod : Trigger.new)
                if(accountingPeriod.Status__c == 'Closed' && FC.ERP7__Closing_Period_Password_Process__c && accountingPeriod.ERP7__Password__c == null){
                    accountingPeriod.addError('Please Enter the Password');
                }else if(accountingPeriod.Status__c == 'Closed'){
                    closedAccoutingPeriod_Ids.add(accountingPeriod.Id);
                    previousStartDate = date.newInstance(accountingPeriod.Start_Date__c.year(),accountingPeriod.Start_Date__c.month() -1,accountingPeriod.Start_Date__c.day());
                    previousEndDate = date.newInstance(previousStartDate.year(), previousStartDate.month(), date.daysInMonth(previousStartDate.year(),previousStartDate.month()));
                }
            List<ERP7__Accounting_Period__c> previousAccountingPeriod = new List<ERP7__Accounting_Period__c>();
            previousAccountingPeriod = [SELECT Id,Name,Status__c FROM ERP7__Accounting_Period__c WHERE Start_date__c =:previousStartDate AND End_date__c =: previousEndDate AND Status__c !='Closed'];
            if(previousAccountingPeriod.size()>0)Error_flag = true; integer j=0;
            if(Error_flag && Trigger.new.size()>0 ){Trigger.new[j].addError('Previous Accounting Period Must be closed,before Closing Current Accounting Period');}
            else{
                Map<string, Module__c > RunModule = new Map<string, Module__c >();
                RunModule =  Module__c.getAll();
                if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c ))
                    AccountingPeriod.closingEntries(closedAccoutingPeriod_Ids);
            }           
            
            
        }
    }
}