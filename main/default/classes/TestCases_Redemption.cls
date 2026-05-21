@isTest
Private Class TestCases_Redemption {
    @isTest(SeeAllData=true)
    static void UnitTestRedemption1() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,Active__c=true);
        insert salepoint;
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10, Active__c = true, Organisation_Business_Unit__c=busUnit.id,Organisation__c=orgn.id);
        insert loyalty;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',Contact_Numer__c='Test1234',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        System.assertEquals(contact.FirstName, 'Test');
        Expense__c expense = new Expense__c(Name='test',Approver__c=UserInfo.getUserId(),status__c='Submitted');
        insert expense;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Active__c = true,Contact__c=contact.id,Status__c='Active',Organisation__c = orgn.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Loyalty_Points__c creditReward = new Loyalty_Points__c(
        Name = 'Test',
        Loyalty_Card__c = clubCard.id, 
        Points__c = 20, 
        Transaction_Status__c ='credit', 
        Valid_Date__c = System.Today() + 30,
        Organisation__c = orgn.Id, 
        Organisation_Business_Unit__c = busUnit.Id);
        insert creditReward;
                    
        Contact myCon = [Select Id, Name,Email, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];
                   
        Sales_Order__c sod = new Sales_Order__c();  
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Request_Date__c = system.Today();
        sod.Bill_To_Address__c = bAddress1.Id;
        sod.Ship_To_Address__c = sAddress1.Id;
        sod.Organisation_Business_Unit__c=busUnit.id;
        sod.Organisation__c=orgn.id;
        insert sod;
        Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;  
                  
        Tax__c tax = new Tax__c(Active__c = true, Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;
       
        Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(Name='test',Active__c=true,Subscription_Plan__c='Day');
        insert subscriptionPlan;
        Invoice__c invoice = new Invoice__c(Active__c = true,Order__c=sod.id,Account__c=customer.id);
        insert invoice;
        Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
        Credit_Note__c CN = new Credit_Note__c(Active__c = true, Account__c = customer.Id, Amount__c = 10, ERP7__Credit__c=10);
        insert CN;
        ERP7__PrePayment__c PP = new ERP7__PrePayment__c(Account__c = customer.Id, Amount__c = 10, ERP7__Credit__c=10);
        insert PP;
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='test',ERP7__Value__c = 10,ERP7__Minimum_Order_Amount__c=0,ERP7__Start_Date__c=system.today(),ERP7__End_Date__c=system.today(),ERP7__Pre_Tax_Discount__c=false);
        insert coupon;
        ERP7__Coupon_Issued__c CIS = new ERP7__Coupon_Issued__c(Name='test', ERP7__Coupon__c=coupon.Id);
        insert CIS;
        
        test.startTest();
            PageReference pageRef1 = System.Page.Redemption;
            pageRef1.getParameters().put('rp','INV'); 
            pageRef1.getParameters().put('id',invoiceName.Id);     
            Test.setCurrentPage(pageRef1);
            Redemption RD = new Redemption();
            RD.redeemPoints = 1;
            RD.ProcessLoyalty();
            RD.redeemCredit = 30;
            RD.ApplyCredits();
            RD.couponCode = 'Test';
            RD.RedeemCoupon();
        test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void UnitTestRedemption2() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,Active__c=true);
        insert salepoint;
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10, Active__c = true);
        insert loyalty;
        Loyalty_Setup__c loyal = [Select Id, Name from Loyalty_Setup__c where Id=:loyalty.Id];
        Account customer = new Account(Name='Customer',ERP7__Credit_Balance__c=100, ERP7__Debit_Balance__c=50);
        insert customer;
        Account Customer2 = [Select Id, Name, ERP7__Available_Credit_Balance__c from Account where Id=:customer.id];
        Contact contact = new Contact(FirstName='Test',Contact_Numer__c='Test1234',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        System.assertEquals(contact.FirstName, 'Test');
        Expense__c expense = new Expense__c(Name='test',Approver__c=UserInfo.getUserId(),status__c='Submitted');
        insert expense;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Active__c = true,Contact__c=contact.id,Status__c='Active',Organisation__c = orgn.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Loyalty_Points__c creditReward = new Loyalty_Points__c(
        Name = 'Test',
        Loyalty_Card__c = clubCard.id, 
        Points__c = 20, 
        Transaction_Status__c ='credit', 
        Valid_Date__c = System.Today() + 30,
        Organisation__c = orgn.Id, 
        Organisation_Business_Unit__c = busUnit.Id);
        insert creditReward;
                    
        Contact myCon = [Select Id, Name,Email, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];
                   
        Sales_Order__c sod = new Sales_Order__c();  
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Request_Date__c = system.Today();
        sod.Bill_To_Address__c = bAddress1.Id;
        sod.Ship_To_Address__c = sAddress1.Id;
        insert sod;
        Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;  
                  
        Tax__c tax = new Tax__c(Active__c = true, Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;
       
        Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(Name='test',Active__c=true,Subscription_Plan__c='Day');
        insert subscriptionPlan;
        Invoice__c invoice = new Invoice__c(Active__c = true,Order__c=sod.id,Account__c=customer.id);
        insert invoice;
        Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
        Credit_Note__c CN = new Credit_Note__c(Active__c = true, Account__c = customer.Id, Amount__c = 10, ERP7__Credit__c=10);
        insert CN;
        ERP7__PrePayment__c PP = new ERP7__PrePayment__c(Account__c = customer.Id, Amount__c = 10, ERP7__Credit__c=10);
        insert PP;
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='test',ERP7__Value__c = 10,ERP7__Minimum_Order_Amount__c=0,ERP7__Start_Date__c=system.today(),ERP7__End_Date__c=system.today(),ERP7__Pre_Tax_Discount__c=true);
        insert coupon;
        ERP7__Coupon_Issued__c CIS = new ERP7__Coupon_Issued__c(Name='test', ERP7__Coupon__c=coupon.Id);
        insert CIS;
        
        test.startTest();
            PageReference pageRef1 = System.Page.Redemption;
            pageRef1.getParameters().put('rp','INV'); 
            pageRef1.getParameters().put('id',invoiceName.Id);     
            Test.setCurrentPage(pageRef1);
            Redemption RD = new Redemption();
            RD.redeemPoints = 1;
            RD.ProcessLoyalty();
            RD.redeemCredit = 13;
        	RD.Customer = Customer2;
            RD.ApplyCredits();
            RD.couponCode = 'Test';
            RD.RedeemCoupon();
        test.stopTest();
    }

	@isTest(SeeAllData=true)
    static void UnitTestRedemption3() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,Active__c=true);
        insert salepoint;
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10, Active__c = true);
        insert loyalty;
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',Contact_Numer__c='Test1234',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        System.assertEquals(contact.FirstName, 'Test');
        Expense__c expense = new Expense__c(Name='test',Approver__c=UserInfo.getUserId(),status__c='Submitted');
        insert expense;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Active__c = true,Contact__c=contact.id,Status__c='Active',Organisation__c = orgn.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Loyalty_Points__c creditReward = new Loyalty_Points__c(
        Name = 'Test',
        Loyalty_Card__c = clubCard.id, 
        Points__c = 20, 
        Transaction_Status__c ='credit', 
        Valid_Date__c = System.Today() + 30,
        Organisation__c = orgn.Id, 
        Organisation_Business_Unit__c = busUnit.Id);
        insert creditReward;
                    
        Contact myCon = [Select Id, Name,Email, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];
                   
        Sales_Order__c sod = new Sales_Order__c();  
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Request_Date__c = system.Today();
        sod.Bill_To_Address__c = bAddress1.Id;
        sod.Ship_To_Address__c = sAddress1.Id;
        insert sod;        
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim; 
        Sales_Order__c psod = [Select id, Name, Due_Amount__c From Sales_Order__c Where id =: sod.id Limit 1];
                  
        Tax__c tax = new Tax__c(Active__c = true, Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;
       
        Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(Name='test',Active__c=true,Subscription_Plan__c='Day');
        insert subscriptionPlan;
        Invoice__c invoice = new Invoice__c(Active__c = true,Order__c=sod.id,Account__c=customer.id);
        insert invoice;
        Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
        Credit_Note__c CN = new Credit_Note__c(Active__c = true, Account__c = customer.Id, Amount__c = 10, ERP7__Credit__c=10);
        insert CN;
        ERP7__PrePayment__c PP = new ERP7__PrePayment__c(Account__c = customer.Id, Amount__c = 10, ERP7__Credit__c=10);
        insert PP;
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='test',ERP7__Value__c = 10,ERP7__Minimum_Order_Amount__c=0,ERP7__Start_Date__c=system.today(),ERP7__End_Date__c=system.today(),ERP7__Pre_Tax_Discount__c=false,Account__c=Customer.Id);
        insert coupon;
        ERP7__Coupon_Issued__c CIS = new ERP7__Coupon_Issued__c(Name='test', ERP7__Coupon__c=coupon.Id);
        insert CIS;
        
        test.startTest();
            PageReference pageRef1 = System.Page.Redemption;
            pageRef1.getParameters().put('rp','ACC'); 
            pageRef1.getParameters().put('id',customer.Id);     
            Test.setCurrentPage(pageRef1);
            Redemption RD = new Redemption();
            RD.couponCode = 'Test';
            RD.RedeemAccountCoupon();
        test.stopTest();
    }
}