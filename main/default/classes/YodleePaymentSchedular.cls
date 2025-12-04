Global class YodleePaymentSchedular implements Schedulable {
    global void execute(SchedulableContext SC) {        
        YodleePaymentsHelper.createPayments();
    }
}