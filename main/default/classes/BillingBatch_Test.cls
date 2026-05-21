@isTest
public class BillingBatch_Test {
    static testMethod void UnitTest(){
        List<ERP7__Billing__c> Billing= new List<ERP7__Billing__c>();
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account Vendor = new Account(Name='Vendor', Account_Type__c = 'Vendor');
        insert Vendor;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        ERP7__Chart_of_Accounts__c chartacc = new ERP7__Chart_of_Accounts__c(Name='Chart acct', ERP7__Opening_Balance__c = 450000, ERP7__Organisation__c=orgn.Id);
        insert chartacc;
        ERP7__Billing__c bill = new ERP7__Billing__c(Name='Test Bill', ERP7__Last_Billing_Date__c = Date.today()-30, ERP7__Next_Billing_Date__c= Date.today(), ERP7__Billing_Frequency__c='Monthly', ERP7__Total__c=200, ERP7__Organisation__c=orgn.Id, ERP7__Bank_Account__c=chartacc.Id,ERP7__Account__c=Vendor.Id  ,ERP7__Type__c='Bill',ERP7__Post_Bill__c=true,ERP7__Create_Voucher__c=true,ERP7__Post_Invoice__c=true);
        insert bill;
        ERP7__Billing_Item__c billItem = new ERP7__Billing_Item__c(Name ='Test Bill', ERP7__Billing__c = bill.Id, ERP7__Total__c = 200);
        insert billItem;
        Id AdjEntRecordTypeId = Schema.SObjectType.ERP7__Billing__c.getRecordTypeInfosByName().get('Adjustment Entries').getRecordTypeId();
        Id ExpenseBillRT = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get('Expense_Bill').getRecordTypeId();
        
        ERP7__Bill__c billinsert = new ERP7__Bill__c(Name = 'Bill Test', recordTypeId=ExpenseBillRT, ERP7__Type__c='Credit', ERP7__Organisation__c=orgn.Id, ERP7__Account__c= Vendor.Id, ERP7__Billing__c = Bill.Id ,ERP7__Amount__c=20, ERP7__Total_Amount__c=20,ERP7__Bill_Date__c=Date.today());
        insert billinsert;
        
        ERP7__Billing__c bill1 = new ERP7__Billing__c(Name='Test Bill', ERP7__Last_Billing_Date__c = Date.today()-30, ERP7__Next_Billing_Date__c= Date.today(), ERP7__Billing_Frequency__c='Monthly', ERP7__Total__c=200, ERP7__Organisation__c=orgn.Id, ERP7__Bank_Account__c=chartacc.Id,ERP7__Account__c=Vendor.Id  ,ERP7__Type__c='Adjustment Entries', RecordTypeId=AdjEntRecordTypeId);
        insert bill1;
        ERP7__Billing_Item__c billItem3 = new ERP7__Billing_Item__c(Name ='Test Bill', ERP7__Billing__c = bill1.Id, ERP7__Total__c = 200);
        insert billItem3;
        Id InvRecordTypeId = Schema.SObjectType.ERP7__Billing__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        ERP7__Billing__c bill2 = new ERP7__Billing__c(Name='Test Bill', ERP7__Last_Billing_Date__c = Date.today()-30, ERP7__Next_Billing_Date__c= Date.today(), ERP7__Billing_Frequency__c='Monthly', ERP7__Total__c=200, ERP7__Organisation__c=orgn.Id, ERP7__Bank_Account__c=chartacc.Id,ERP7__Account__c=Vendor.Id  ,ERP7__Type__c='Invoice', RecordTypeId=InvRecordTypeId);
        insert bill2;
        ERP7__Billing_Item__c billItem4 = new ERP7__Billing_Item__c(Name ='Test Bill', ERP7__Billing__c = bill2.Id, ERP7__Total__c = 200);
        insert billItem4;
        ERP7__Finance_General_Ledger__c genLedger= new ERP7__Finance_General_Ledger__c(Name='Trial Gen Ledger', ERP7__Organisation__c= orgn.Id);
        insert genLedger;
        
        Test.startTest();
        BillingBatch ba= new BillingBatch();
        Database.executeBatch(ba,5);
        Test.stopTest();        
    }
    static testMethod void UnitTest1(){
        List<ERP7__Billing__c> Billing= new List<ERP7__Billing__c>();
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account Vendor = new Account(Name='Vendor', Account_Type__c = 'Vendor');
        insert Vendor;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        ERP7__Chart_of_Accounts__c chartacc = new ERP7__Chart_of_Accounts__c(Name='Chart acct', ERP7__Opening_Balance__c = 450000, ERP7__Organisation__c=orgn.Id);
        insert chartacc;
        Id AdjEntRecordTypeId = Schema.SObjectType.ERP7__Billing__c.getRecordTypeInfosByName().get('Adjustment Entries').getRecordTypeId();
        ERP7__Billing__c bill = new ERP7__Billing__c(Name='Test Bill0', ERP7__Last_Billing_Date__c = Date.today()-30, ERP7__Next_Billing_Date__c= Date.today(), ERP7__Billing_Frequency__c='Monthly', ERP7__Total__c=200, ERP7__Organisation__c=orgn.Id, ERP7__Bank_Account__c=chartacc.Id,ERP7__Account__c=Vendor.Id  ,ERP7__Type__c='Bill',ERP7__Post_Bill__c=true,ERP7__Create_Voucher__c=true,ERP7__Post_Invoice__c=true);
        insert bill;
        ERP7__Billing_Item__c billItem0 = new ERP7__Billing_Item__c(Name ='Test Bill', ERP7__Billing__c = bill.Id, ERP7__Total__c = 200);
        insert billItem0;
        ERP7__Billing__c bill1 = new ERP7__Billing__c(Name='Test Bill', ERP7__Last_Billing_Date__c = Date.today()-30, ERP7__Next_Billing_Date__c= Date.today(), ERP7__Billing_Frequency__c='Monthly', ERP7__Total__c=200, ERP7__Organisation__c=orgn.Id, ERP7__Bank_Account__c=chartacc.Id,ERP7__Account__c=Vendor.Id  ,ERP7__Type__c='Adjustment Entries', RecordTypeId=AdjEntRecordTypeId);
        insert bill1;
        ERP7__Billing_Item__c billItem3 = new ERP7__Billing_Item__c(Name ='Test Bill', ERP7__Billing__c = bill1.Id, ERP7__Total__c = 200,ERP7__Chart_of_Account__c=chartacc.Id, ERP7__Type__c ='Credit');
        insert billItem3;
        Id InvRecordTypeId = Schema.SObjectType.ERP7__Billing__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
        ERP7__Billing__c bill2 = new ERP7__Billing__c(Name='Test Bill', ERP7__Last_Billing_Date__c = Date.today()-30, ERP7__Next_Billing_Date__c= Date.today(), ERP7__Billing_Frequency__c='Monthly', ERP7__Total__c=200, ERP7__Organisation__c=orgn.Id, ERP7__Bank_Account__c=chartacc.Id,ERP7__Account__c=Vendor.Id  ,ERP7__Type__c='Invoice', RecordTypeId=InvRecordTypeId);
        insert bill2;
        ERP7__Billing_Item__c billItem4 = new ERP7__Billing_Item__c(Name ='Test Bill', ERP7__Billing__c = bill2.Id, ERP7__Total__c = 200);
        insert billItem4;
        ERP7__Finance_General_Ledger__c genLedger= new ERP7__Finance_General_Ledger__c(Name='Trial Gen Ledger', ERP7__Organisation__c= orgn.Id);
        insert genLedger;
        
        Test.startTest();
        BillingBatch ba= new BillingBatch();
        Database.executeBatch(ba,5);
        Test.stopTest();        
    }
    static testMethod void testBillingTransactionScheduler() {
        BillingScheduler scheduler = new BillingScheduler();
        Test.startTest();
        Datetime scheduledTime = System.now().addMinutes(1);
        String cronExp = '0 ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
        
        String jobName = 'Test Billing Transaction Scheduler ' + scheduledTime.format('HH:mm');
        String jobId = System.schedule(jobName, cronExp, new BillingScheduler());
        	//String jobId = System.schedule('Test Billing Transaction Scheduler', '0 0 0 1 1 ? 2024', scheduler);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}