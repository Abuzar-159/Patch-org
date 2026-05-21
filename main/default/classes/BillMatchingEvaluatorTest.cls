@isTest
private class BillMatchingEvaluatorTest {

    @testSetup
    static void setupData() {
        // Create PO
        PO__c po = new PO__c(Name = 'PO-001');
        insert po;

        // Account + Address
        Account Acc = new Account(Name = 'Tester', Account_Type__c = 'Customer');
        insert Acc;

        Address__c addr = new Address__c(Name = 'Test Address', Customer__c = Acc.Id);
        insert addr;

        // Logistic with no line items
        Logistic__c logNoItems = new Logistic__c(Name = 'Log1', Purchase_Order__c = po.Id, To_Address__c = addr.Id);
        insert logNoItems;

        // Logistic with received line item
        Logistic__c logReceived = new Logistic__c(Name = 'Log2', Purchase_Order__c = po.Id, To_Address__c = addr.Id);
        insert logReceived;

        Logistic_Line_Item__c itemReceived = new Logistic_Line_Item__c(
            Name = 'LineItem1',
            Logistic__c = logReceived.Id,
            Quantity__c = 10
            // Remaining_Quantity__c = 0
        );
        insert itemReceived;

        // Logistic with pending line item
        Logistic__c logPending = new Logistic__c(Name = 'Log3', Purchase_Order__c = po.Id, To_Address__c = addr.Id);
        insert logPending;

        Logistic_Line_Item__c itemPending = new Logistic_Line_Item__c(
            Name = 'LineItem2',
            Logistic__c = logPending.Id,
            Quantity__c = 10
            // Remaining_Quantity__c = 5
        );
        insert itemPending;

        // Bill without PO
        insert new Bill__c(Name = 'Bill-NoPO', Matched__c = false);

        // Bill with PO but no logistics
        insert new Bill__c(Name = 'Bill-NoLog', Matched__c = false, Purchase_Order__c = po.Id);

        // Bill with received logistics
        insert new Bill__c(Name = 'Bill-Received', Matched__c = false, Purchase_Order__c = po.Id);

        // Bill with pending logistics
        insert new Bill__c(Name = 'Bill-Pending', Matched__c = false, Purchase_Order__c = po.Id);

        // Bill already matched
        insert new Bill__c(Name = 'Bill-Matched', Matched__c = true, Purchase_Order__c = po.Id);
    }

    @isTest
    static void testWithPeriodAndAutoMatch() {
        Test.startTest();

        BillMatchingEvaluator.Request req = new BillMatchingEvaluator.Request();
        req.period = 'LAST_N_DAYS:365'; // Valid dynamic SOQL date
        req.shouldMatchBills = true;
        req.specificBillName = null;

        List<BillMatchingEvaluator.Response> responses = BillMatchingEvaluator.BillMatchCheck(new List<BillMatchingEvaluator.Request>{ req });

        System.assertEquals(1, responses.size());
        System.assertNotEquals(null, responses[0].BillsWithNoLogisticsHtml);
        System.assertNotEquals(null, responses[0].BillsWithFullyReceivedLogisticsHtml);
        System.assertNotEquals(null, responses[0].BillsWithPendingLogisticsHtml);
        System.assertNotEquals(null, responses[0].AutoMatchResultsHtml);
        System.assertNotEquals(null, responses[0].PendingLogisticsEmailNotice);

        Test.stopTest();
    }

    @isTest
    static void testInvalidPeriodFormat() {
        Test.startTest();

        BillMatchingEvaluator.Request req = new BillMatchingEvaluator.Request();
        req.period = 'InvalidSoqlDate';
        req.shouldMatchBills = false;

        List<BillMatchingEvaluator.Response> responses = BillMatchingEvaluator.BillMatchCheck(new List<BillMatchingEvaluator.Request>{ req });
        System.assertEquals(1, responses.size());
        System.assert(responses[0].MatchPrompt.contains('Invalid period format'));

        Test.stopTest();
    }

}