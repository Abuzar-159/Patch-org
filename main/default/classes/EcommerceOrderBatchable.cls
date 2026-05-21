public class EcommerceOrderBatchable implements Database.Batchable<sObject>{
    //https://help.salesforce.com/s/articleView?id=000331053&type=1
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id,Name,Status,ERP7__Sync_Status__c from Order where ERP7__Sync_Status__c != null AND ERP7__Is_Status_Equal__c='false' AND ERP7__Is_Status_Equal__c != '' AND ERP7__Is_Status_Equal__c != null AND ERP7__Total_Number_of_Items__c > 0 AND LastModifiedDate <:Datetime.now().addMinutes(-30) Limit 10000]);  // AND CreatedDate >: Datetime.now().addMinutes(-60) 
    }
    
    public void execute(Database.BatchableContext BC, List<Order> ordList) { for(Order ord:ordList){ if(ord.ERP7__Sync_Status__c != ord.Status) ord.Status=ord.ERP7__Sync_Status__c;} if(ordList.size() > 0){PreventRecursiveLedgerEntry.testCasesTransactions=true; PreventRecursiveLedgerEntry.Taxed=true; PreventRecursiveLedgerEntry.Loged=true; update ordList;}}
    
    
    public void finish(Database.BatchableContext BC) { 
        List<CronTrigger> apexJobs = [SELECT Id, State,StartTime, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger Where CronJobDetail.Name like 'EcommerceSchedular %' And NextFireTime  > :system.Now()];
        if(apexJobs.size()==0){
            System.debug('finish');
            List<ERP7__E_Commerce_Sync_Control__mdt> md=[select Id,ERP7__Amazon_Sync_Time__c,ERP7__Etsy_Sync_Time__c,ERP7__Shopify_Sync_Time__c from ERP7__E_Commerce_Sync_Control__mdt limit 10];
            System.debug('md:'+md);
            //DateTime dtime = system.now().addMinutes(15);//Integer.valueOf(System.Label.EcommerceScheduleTime)
            DateTime dtime = system.now().addMinutes(Integer.valueOf(md[0].ERP7__Shopify_Sync_Time__c));
            String day = string.valueOf(dtime.day());
            String month = string.valueOf(dtime.month());
            String hour = string.valueOf(dtime.hour());
            String minute = string.valueOf(dtime.minute());
            String second = string.valueOf(dtime.second());
            String year = string.valueOf(dtime.year());        
            String strJobName = 'EcommerceSchedular '+ day + '/' + month + '/' + year + ' ' + hour + ':' + minute;
            String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
            System.schedule(strJobName, strSchedule, new EcommerceOrderSchedulable());
        }        
    }
}