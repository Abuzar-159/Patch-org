Global class BillingScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {        
        Database.executeBatch(new BillingBatch(), 1);
    }
}