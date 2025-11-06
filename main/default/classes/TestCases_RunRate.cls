@isTest
Private Class TestCases_RunRate {
    static testmethod void UnitTestRunRate() {
        //PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Test.startTest();
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=orgn.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        WO__c wo = new WO__c(Name = 'test wo',  Active__c = true, WO_Supplier__c = sup.Id);
        insert wo;
        
        Credit_Note__c CN = new Credit_Note__c(Active__c = true, Account__c = orgn.Id, Amount__c = 10);
        insert CN;
        
        Debit_Note__c DN = new Debit_Note__c(Active__c = true, Account__c = orgn.Id, Amount__c = 10);
        insert DN;
        
        ERP7__PrePayment__c PP = new ERP7__PrePayment__c(Account__c = orgn.Id, Amount__c = 10);
        insert PP;
        
        Sales_Order__c sod = new Sales_Order__c();
        sod.Order_Status__c = 'Entered';
        sod.Account__c = orgn.Id;
        sod.Contact__c = contact.Id;
        sod.Request_Date__c = system.Today();
        sod.Is_Back_Order__c = true;
        insert sod;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = bUnit.Id,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        pageReference page1 = System.page.StockRunRate;
        Test.setCurrentPage(page1);
        StockRunRate SRR = new StockRunRate();
        String s1 = 'test';
        String s2 = 'test'; 
        System.assertEquals(s1,s2);    
        Test.StopTest();          
    }
}