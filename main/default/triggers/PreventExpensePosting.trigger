trigger PreventExpensePosting on ERP7__Expense__c(after insert, after update) {
    List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
    accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];
    Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
    for(ERP7__Accounting_Period__c acc :accperiodList){
         accountingPeriodMapBYName.put(acc.Name,acc);
    }
    for(ERP7__Expense__c exp:(List<ERP7__Expense__c>) System.Trigger.New){
        //if(exp.ERP7__Date__c== null) exp.ERP7__Date__c= system.Today();
        if(exp.ERP7__Date__c!= null){
            string month = (String.valueof(exp.ERP7__Date__c.month()).length() > 1)? String.valueof(exp.ERP7__Date__c.month()) : '0'+exp.ERP7__Date__c.month();
            String periodName = exp.ERP7__Date__c.year()+'-'+month;
            if(accountingPeriodMapBYName.get(periodName) != null ){
                if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed')
                    exp.addError('Accounting Period is Closed, cannot update the Expense.');
            }
        }
    }
}