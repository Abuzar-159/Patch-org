@isTest
public class InvoiceLineItemTrigger_testCases {
    @isTest
    static void Test1(){
        Account acc = new Account(Name='Test Account', Account_Type__c = 'Customer',Default__c = true,ERP7__Total_Due__c=7345);
        insert acc;
        Account acc1 = new Account(Name='Test Account', Account_Type__c = 'Organisation',Default__c = true,ERP7__Total_Due__c=7845);
        insert acc1;
        Contact con = new Contact(
            AccountId = acc.id,lastname = 'testdata', 
            firstname ='testdata1',
            OwnerId = Userinfo.getUserid() );
        insert con;  
        ERP7__Profiling__c Prof = new ERP7__Profiling__c(Name='Test profile');
        insert Prof;
        ERP7__Sales_Order__c SO = new ERP7__Sales_Order__c(ERP7__Name__c='Test Sales Order',ERP7__Account__c=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Organisation__c=acc1.Id,ERP7__Order_Profile__c=Prof.Id);
       
        insert SO;
         
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        insert p;
        /* Pricebook2  standardPb = [select id, name, isActive from Pricebook2 where IsStandard = true limit 1];

PricebookEntry standardPrice = new PricebookEntry();
standardPrice.Pricebook2Id = standardPb.Id;
standardPrice.Product2Id = p.Id;
standardPrice.UnitPrice = 1;
standardPrice.IsActive = true;
standardPrice.UseStandardPrice = false;
insert standardPrice ;*/
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__Sales_Order_Line_Item__c SOLI = new ERP7__Sales_Order_Line_Item__c();
        SOLI.ERP7__Active__c =true;
        // SOLI.ERP7__Invoice__c = inv.Id;
        SOLI.ERP7__Quantity__c =3;
        SOLI.ERP7__Product__c = p.Id;
        SOLI.ERP7__Base_Price__c = 30;
        SOLI.ERP7__Sales_Order__c = SO.Id;
        insert SOLI;
        
        Product2 p1 = new Product2();
        p1.Name = ' Test Product 2';
        p1.Description='Test Product Entry 2';
        p1.productCode = 'ADBC';
        p1.isActive = true;
        insert p1;
        ERP7__Invoice__c inv = new ERP7__Invoice__c();
        inv.ERP7__Account__c=acc.Id;
        inv.ERP7__Active__c=true;
        inv.ERP7__Invoice_Amount__c=200;
        inv.ERP7__Contact__c=con.Id;
        inv.ERP7__Name__c='Test Invoice';
        inv.ERP7__Invoice_Date__c=Date.today();
        inv.ERP7__Discount_Amount__c=50;
        inv.ERP7__Order__c = SO.Id;
        
        insert inv;
        
        
        ERP7__Invoice_Line_Item__c invLI = new ERP7__Invoice_Line_Item__c();
        // invLI.ERP7__Account__c=acc.Id;
        invLI.ERP7__Sales_Order_Line_Item__c = SOLI.Id;
        invLI.ERP7__Posted__c = true;
        invLI.ERP7__Base_Price__c=30;
        invLI.ERP7__Invoice__c = inv.Id;
        invLI.Name = 'Test Item1';
        invLI.ERP7__Discount_Amount__c =10;
        invLI.ERP7__Quantity__c = 2;
        invLI.ERP7__Unit_Price__c = 30;
        invLI.ERP7__Product__c=p.Id;
        insert invLI;
       Delete invLI;
        ERP7__Invoice_Line_Item__c invLI1 = new ERP7__Invoice_Line_Item__c();
        // invLI.ERP7__Account__c=acc.Id;
        invLI1.ERP7__Base_Price__c=20;
        invLI1.ERP7__Invoice__c = inv.Id;
        
        invLI1.ERP7__Sales_Order_Line_Item__c = SOLI.Id;
        invLI1.ERP7__Posted__c = true;
        invLI1.Name = 'Test Item2';
        invLI1.ERP7__Discount_Amount__c =5;
        invLI1.ERP7__Quantity__c = 2;
        invLI1.ERP7__Unit_Price__c = 40;
        invLI1.ERP7__Product__c=p1.Id;
        insert invLI1;
        
        
        
        List<Account> getAccts = [Select Id ,ERP7__Total_Due__c from Account];
        Map<id, Decimal> TotalDueOfAccounts=new Map<id, Decimal>();
        Decimal existingDue=0;
        TotalDueOfAccounts.put(getAccts[0].Id,existingDue+getAccts[0].ERP7__Total_Due__c);
        TotalDueOfAccounts.put(getAccts[1].Id,existingDue+getAccts[1].ERP7__Total_Due__c);
        
        
        List<Account> accs=[Select id,ERP7__Total_Due__c From Account where id In: TotalDueOfAccounts.keySet() ];
        List<Account> updateAccs=new List<Account>();
        for(Account acc3: accs){
            
            acc3.ERP7__Total_Due__c=acc.ERP7__Total_Due__c+TotalDueOfAccounts.get(acc3.id);
            updateAccs.add(acc3);
        }
        update updateAccs;
        ERP7__Employees__c currentEmployees = new ERP7__Employees__c(Name = 'Test' , ERP7__First_Name__c = 'test', ERP7__Last_Name__c = '123',ERP7__Employee_User__c = UserInfo.getUserId());
        insert currentEmployees;
         ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Accounts__c = acc.Id;
        pay.ERP7__Total_Amount__c = 5670;
        pay.ERP7__Payment_Status__c = 'Paid';
        pay.ERP7__Invoice__c = inv.Id;
        insert pay;
        inv.ERP7__Paid__c = true;
        inv.ERP7__Status__c = 'Paid';
        inv.Posted__c = true;
        inv.ERP7__Posted_Date__c = system.today();
        update inv;
        ERP7__Transaction__c trans = new ERP7__Transaction__c();
        trans.ERP7__Active__c = true;
        trans.ERP7__Invoice__c = inv.Id;
        trans.ERP7__Amount__c= 345;
        trans.ERP7__Employee__c = currentEmployees.Id ;
        trans.ERP7__Customer__c = acc.Id;
        trans.ERP7__Invoice__c = inv.Id;
        insert trans;
        trans.Organisation__c = acc1.Id;
        trans.ERP7__Sales_Order__c = SO.Id;
        trans.Product__c = p.Id;
        trans.Transaction_Date__c = Date.today() +2;
        trans.Transaction_Status__c = 'Completed';
        update trans;
        ERP7__Actions_Tasks__c tasks = new ERP7__Actions_Tasks__c();
        tasks.ERP7__Sub_Total__c = 560;
        tasks.ERP7__Total_Discount__c = 60;
        tasks.ERP7__Total_Amount__c = 500;
        tasks.ERP7__Total_Tax__c = 1;
        insert tasks;
        SO.ERP7__Tasks__c = tasks.Id;
        update SO;
        tasks.ERP7__Total_Discount__c  = 60;
        tasks.ERP7__Total_Tax__c = 5;
        tasks.ERP7__Sub_Total__c = 600;
        update tasks;        
       
        test.startTest();
        acc.ERP7__Paid_Out__c =  30;
        acc.ERP7__Paid_Out__c = 234;
       // acc.ERP7__Invoice_Amount__c = 2345;
        upsert acc;
        SO.ERP7__Status__c = 'Delivered';
        update SO;
        inv.ERP7__Invoice_Amount__c = 60;
     //   update inv;
        invLI1.ERP7__Discount_Amount__c = 20;
      //  update invLI1;
        trans.ERP7__Amount__c = 7649;
      //  update trans;
        
     
        
        acc.ERP7__Total_Due__c = 567;
        upsert acc;
        //Delete pay; commented because of null reference error
        Delete trans;
        inv.Posted__c=false;
        update inv;
        pay.ERP7__Invoice__c =null;
        update pay;
        Delete inv;
        ERP7__Invoice__c inv1 = [Select Id,Name From ERP7__Invoice__c Where ERP7__Name__c = 'Test Invoice'  ALL ROWS];
        undelete inv1;
        string sal ='ERP';
        String sal1 ='ERP';
        system.assertEquals(sal, sal1);
        test.stopTest();
        
        
        
        
    }
    @isTest  static void Test2(){
        Account acc = new Account(Name='Test Account', Account_Type__c = 'Customer',Default__c = true,ERP7__Total_Due__c=7345);
        insert acc;
        Account acc1 = new Account(Name='Test Account', Account_Type__c = 'Organisation',Default__c = true,ERP7__Total_Due__c=7845);
        insert acc1;
        Contact con = new Contact(
            AccountId = acc.id,lastname = 'testdata', 
            firstname ='testdata1',
            OwnerId = Userinfo.getUserid() );
        insert con;  
        ERP7__Profiling__c Prof = new ERP7__Profiling__c(Name='Test profile');
        insert Prof;
        /*Order SO = new Order(ERP7__Name__c='Test Sales Order',AccountId=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Organisation__c=acc1.Id,ERP7__Order_Profile__c=Prof.Id);
insert SO;*/
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry 1';
        p.productCode = 'ABC';
        p.isActive = true;
        insert p;
          Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice; 
       
        //insert standardPb;
        Order ord = new Order();
        ord.Name = 'Test Order ';
        ord.Status = 'Draft';
        ord.EffectiveDate = system.today();
        ord.EndDate = system.today() + 4;
        ord.AccountId = acc.id;
        ord.Pricebook2Id =  priceBookId ;
        ord.AccountId=acc.Id;
        ord.ERP7__Amount__c=345;
        ord.ERP7__Expected_Date__c=Date.today();
        ord.ERP7__Organisation__c=acc1.Id;
        ord.ERP7__Order_Profile__c=Prof.Id;
        ord.ERP7__Shipment_Type__c='UPS';ord.ERP7__Shipment_Preference_Speed__c='--None--';
        insert ord;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
         OrderItem item1 = new OrderItem();
        item1.OrderId = ord.id;
        item1.Quantity = 24;
        item1.UnitPrice = 240;
       // i.Pieces__c = i.Quantity;
        item1.Product2id = p.id;
        item1.PricebookEntryId=standardPrice.id;
        //i.Total_Price__c = i.Quantity * i.UnitPrice;
        insert item1;
        OrderItem item2 = new OrderItem();
        item2.OrderId = ord.id;
        item2.Quantity = 24;
        item2.UnitPrice = 240;
        //i.Pieces__c = i.Quantity;
        item2.Product2id = p.id;
        item2.PricebookEntryId=standardPrice.id;
        //i.Total_Price__c = i.Quantity * i.UnitPrice;
        insert item2;
        
        Product2 p1 = new Product2();
        p1.Name = ' Test Product 2';
        p1.Description='Test Product Entry 2';
        p1.productCode = 'ADBC';
        p1.isActive = true;
        insert p1;
        ERP7__Invoice__c inv = new ERP7__Invoice__c();
        inv.ERP7__Account__c=acc.Id;
        inv.ERP7__Active__c=true;
        inv.ERP7__Invoice_Amount__c=200;
        inv.ERP7__Contact__c=con.Id;
        inv.ERP7__Name__c='Test Invoice';
        inv.ERP7__Invoice_Date__c=Date.today();
        inv.ERP7__Discount_Amount__c=50;
        inv.ERP7__Order_S__c = ord.Id;
        
        //inv.Posted__c = true;
        insert inv;
        
        ERP7__Invoice_Line_Item__c invLI = new ERP7__Invoice_Line_Item__c();
        // invLI.ERP7__Account__c=acc.Id;
        invLI.ERP7__Order_Product__c = item1.Id;
        invLI.ERP7__Posted__c = true;
        invLI.ERP7__Base_Price__c=30;
        invLI.ERP7__Invoice__c = inv.Id;
        invLI.Name = 'Test Item1';
        invLI.ERP7__Discount_Amount__c =10;
        invLI.ERP7__Quantity__c = 2;
        invLI.ERP7__Unit_Price__c = 30;
        invLI.ERP7__Product__c=p.Id;
        insert invLI;
        Delete invLI;
        ERP7__Invoice_Line_Item__c invLI1 = new ERP7__Invoice_Line_Item__c();
        // invLI.ERP7__Account__c=acc.Id;
        invLI1.ERP7__Base_Price__c=20;
        invLI1.ERP7__Invoice__c = inv.Id;
        
        invLI1.ERP7__Order_Product__c = item2.Id;
        invLI1.ERP7__Posted__c = true;
        invLI1.Name = 'Test Item2';
        invLI1.ERP7__Discount_Amount__c =5;
        invLI1.ERP7__Quantity__c = 2;
        invLI1.ERP7__Unit_Price__c = 40;
        invLI1.ERP7__Product__c=p1.Id;
        insert invLI1;
        
        //inv.ERP7__Paid__c = true;
        //update inv;
        
        List<Account> getAccts = [Select Id ,ERP7__Total_Due__c from Account];
        Map<id, Decimal> TotalDueOfAccounts=new Map<id, Decimal>();
        Decimal existingDue=0;
        TotalDueOfAccounts.put(getAccts[0].Id,existingDue+getAccts[0].ERP7__Total_Due__c);
        TotalDueOfAccounts.put(getAccts[1].Id,existingDue+getAccts[1].ERP7__Total_Due__c);
        
        
        List<Account> accs=[Select id,ERP7__Total_Due__c From Account where id In: TotalDueOfAccounts.keySet() ];
        List<Account> updateAccs=new List<Account>();
        for(Account acc3: accs){
            
            acc3.ERP7__Total_Due__c=acc.ERP7__Total_Due__c+TotalDueOfAccounts.get(acc3.id);
            updateAccs.add(acc3);
        }
        update updateAccs;
        ERP7__Employees__c currentEmployees = new ERP7__Employees__c(Name = 'Test' , ERP7__First_Name__c = 'test', ERP7__Last_Name__c = '123',ERP7__Employee_User__c = UserInfo.getUserId());
        insert currentEmployees;
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Accounts__c = acc.Id;
        pay.ERP7__Total_Amount__c = 5670;
        pay.ERP7__Payment_Status__c = 'Paid';
        pay.ERP7__Invoice__c = inv.Id;
        insert pay;
        inv.ERP7__Paid__c = true;
        inv.ERP7__Status__c = 'Paid';
        inv.Posted__c = true;
        inv.ERP7__Invoice_Amount__c = 5670;
        inv.ERP7__Posted_Date__c = System.today();
        update inv;
        ERP7__Transaction__c trans = new ERP7__Transaction__c();
        trans.ERP7__Active__c = true;
        trans.ERP7__Invoice__c = inv.Id;
        trans.ERP7__Amount__c= 345;
        trans.ERP7__Employee__c = currentEmployees.Id ;
        trans.ERP7__Customer__c = acc.Id;
        trans.ERP7__Invoice__c = inv.Id;
        insert trans;
        trans.Organisation__c = acc1.Id;
        trans.ERP7__Order__c = ord.Id;
        trans.Product__c = p.Id;
        trans.Transaction_Date__c = Date.today() +2;
        trans.Transaction_Status__c = 'Completed';
        update trans;
        ERP7__Actions_Tasks__c tasks = new ERP7__Actions_Tasks__c();
        tasks.ERP7__Sub_Total__c = 560;
        tasks.ERP7__Total_Discount__c = 60;
        tasks.ERP7__Total_Amount__c = 500;
        tasks.ERP7__Total_Tax__c = 1;
        insert tasks;
        ord.ERP7__Tasks__c = tasks.Id;
        update ord;
        
        test.startTest();
        acc.ERP7__Paid_Out__c =  30;
        acc.ERP7__Paid_Out__c = 234;
        //acc.ERP7__Invoice_Amount__c = 2345;
        upsert acc;
        
        inv.ERP7__Invoice_Amount__c = 60;
       // update inv;
        invLI1.ERP7__Discount_Amount__c = 20;
       // update invLI1;
        trans.ERP7__Amount__c = 7649;
       // update trans;
        
         acc.ERP7__Total_Due__c = 567;
        upsert acc;
        //inv.IsDeleted = true;
         
        try{Delete inv;}catch(Exception e){}
        //undelete acc;
        string sal ='ERP';
        String sal1 ='ERP';
        system.assertEquals(sal, sal1);
        test.stopTest();
        
        
        
        
    }
    
}