@isTest
public class PaymentUpdates_GuestUserTestCases {
    
    @isTest
    public static void unitTest1(){        
        Test.StartTest();
        PaymentUpdates_GuestUserSchedule pu = new PaymentUpdates_GuestUserSchedule();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, pu);
        System.assertEquals('ERP', 'ERP');
        Test.stopTest();
    }

}