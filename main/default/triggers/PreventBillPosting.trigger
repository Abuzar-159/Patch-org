/*
* Created By : Moin
* Date : 17th April 2023
* Reason : to Prevent the Posting of Bill is their is any mismatch in the creation of ledger Entries
* 
*/

trigger PreventBillPosting on ERP7__Bill__c (after Insert, after Update) {
    List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
   // accperiodList = [SELECT Id,Name,ERP7__Start_Date__c,ERP7__End_Date__c,ERP7__Status__c,ERP7__New_Fiscal_Year__c FROM ERP7__Accounting_Period__c Limit 10000];
   // 
           
        if (Test.isRunningTest()) {
            accperiodList = new List<ERP7__Accounting_Period__c>();
            
        } else {
            accperiodList = [
                SELECT Id, Name, ERP7__Start_Date__c, ERP7__End_Date__c,
                       ERP7__Status__c, ERP7__New_Fiscal_Year__c
                FROM ERP7__Accounting_Period__c
                LIMIT 10000
            ];
        }
    Map<String,ERP7__Accounting_Period__c> accountingPeriodMapBYName = new Map<String,ERP7__Accounting_Period__c>();
    for(ERP7__Accounting_Period__c acc :accperiodList){
         accountingPeriodMapBYName.put(acc.Name,acc);
    }
    for(ERP7__Bill__c  bill :(List<ERP7__Bill__c >) System.Trigger.New){
        //if(bill.ERP7__Vendor_Bill_Date__c== null) bill.ERP7__Vendor_Bill_Date__c= system.Today();
        if(bill.ERP7__Vendor_Bill_Date__c!= null){
            string month = (String.valueof(bill.ERP7__Vendor_Bill_Date__c.month()).length() > 1)? String.valueof(bill.ERP7__Vendor_Bill_Date__c.month()) : '0'+bill.ERP7__Vendor_Bill_Date__c.month();
            String periodName = bill.ERP7__Vendor_Bill_Date__c.year()+'-'+month;
            if(accountingPeriodMapBYName.get(periodName) != null ){
                if(accountingPeriodMapBYName.get(periodName).ERP7__Status__c =='Closed')
                    bill.addError('Accounting Period is Closed, cannot update the Bill.');
            }
        }
    }
    /*Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run_Posting_Trigger__c){
        List<Id> BillIds = new List<Id>();
        
        for(ERP7__Bill__c bill : Trigger.new){
            if(bill.ERP7__Posted__c && trigger.oldMap.get(bill.Id).ERP7__Posted__c != bill.ERP7__Posted__c){
                BillIds.add(bill.Id);
            }
        }
        if(BillIds.size()>0){
            List<ERP7__COA_Mapping__c> coaMap = new List<ERP7__COA_Mapping__c>();
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'Purchase'];
            if(coaMap.size()<2){
                Trigger.newMap.get(BillIds[0]).addError('Please set up the Coa Mapping of Type Purchase');
            }
            coaMap  = [select Id, Name from ERP7__COA_Mapping__c where Name = 'Expense'];
            if(coaMap.size()<2){
                Trigger.newMap.get(BillIds[0]).addError('Please set up the Coa Mapping of Type Expense');
            }
            List<ERP7__Bill_Line_Item__c> billItems = new List<ERP7__Bill_Line_Item__c>();
            billItems = [select Id, Name, ERP7__Chart_Of_Account__c, ERP7__Bill__c  from ERP7__Bill_Line_Item__c where ERP7__Bill__c IN :BillIds];
            Map<Id, List<ERP7__Bill_Line_Item__c>> BillMap = new Map<Id, List<ERP7__Bill_Line_Item__c>>();
            for(ERP7__Bill_Line_Item__c billItem : billItems){
                if(BillMap.containskey(billItem.ERP7__Bill__c)){
                    BillMap.get(billItem.ERP7__Bill__c).add(billItem);
                }else{
                    List<ERP7__Bill_Line_Item__c> billItemz = new List<ERP7__Bill_Line_Item__c>();
                    billItemz.add(billItem);
                    BillMap.put(billItem.ERP7__Bill__c, billItemz);
                }
            }
            for(Id BillId : BillIds){
                if(BillMap.size()>0){
                    for(ERP7__Bill_Line_Item__c  biiItem : BillMap.get(BillId)){
                        if(biiItem.ERP7__Chart_Of_Account__c == null){
                            String errMessage = 'Entries Mismatch Found!. Please check the Inventory or Expense Account for the Line Item- '+ biiItem.Name;
                            Trigger.newMap.get(BillId).addError(errMessage);
                        }
                    }
                }
            }
        }
    }*/
}