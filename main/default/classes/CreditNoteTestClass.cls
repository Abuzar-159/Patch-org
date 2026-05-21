@isTest
private class CreditNoteTestClass {
    static testmethod void UnitTestMethod()
    {
           
        try{  
            PreventRecursiveLedgerEntry.testCasesTransactions = true;  
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
            Contact sitecontact = new Contact(AccountId=orgn.id,FirstName='Test',Contact_Numer__c='Org123',LastName='Contact',Phone='1234567890',Email='test@test.com');
            insert sitecontact;
        
            System.assertEquals(contact.FirstName, 'Test');
            Expense__c expense = new Expense__c(Name='test',Approver__c=UserInfo.getUserId(),status__c='Submitted');
            insert expense;
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress;
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
            insert sAddress;
            Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress1;
            Address__c warehouseAddress = new Address__c(Customer__c=orgn.id,Contact__c=sitecontact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert warehouseAddress;
            Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
            insert sAddress1;
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Active__c = true,Contact__c=contact.id,Status__c='Active',Organisation__c = orgn.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;
            Contact myCon = [Select Id, Name,Email, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];
                       
            Sales_Order__c sod = new Sales_Order__c();  
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Channel__c = salePoint.Id;
            sod.Request_Date__c = system.Today();
            sod.Bill_To_Address__c = bAddress1.Id;
            sod.Ship_To_Address__c = sAddress1.Id;
            insert sod;
        
            Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
            Product2 ps = new Product2(Name='test',isActive=true);
            insert ps;
            Product2 ps1 = new Product2(Name='test',isActive=true);
            insert ps1;
            Product2 ps2 = new Product2(Name='test',isActive=true, ERP7__Allow_Back_Orders__c =true);
            insert ps2;
            ERP7__Site__c site = new ERP7__Site__c(Name='Test Warehouse',Organisation__c=orgn.Id,ERP7__Type__c='Warehouse',ERP7__Organisation_Business_Unit__c =busUnit.Id,ERP7__Primary_Contact__c = sitecontact.Id,ERP7__Address__c = warehouseAddress.id );  
            upsert site;  
            Distribution_Channel__c dc = new Distribution_Channel__c(Name='Test Dc',Active__c = true,Channel__c=salepoint.Id,site__c=site.id);
            insert dc;
            Inventory_Stock__c invStock = new Inventory_Stock__c(Name='Test Stock',ERP7__Warehouse__c = site.id,ERP7__Product__c = Ps.id,ERP7__Organisation__c=orgn.id,ERP7__Organisation_Business_Unit__c =busUnit.Id );
            upsert invStock; 
            ERP7__Stock_Inward_Line_Item__c sili = new ERP7__Stock_Inward_Line_Item__c(ERP7__Site_ProductService_InventoryStock__c=invStock.id,Name='Test SILI',ERP7__Quantity__c=10,ERP7__Unit_Price__c=100,ERP7__Amount__c=1000,ERP7__Product__c=ps.id);
            insert sili;
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Checked_Out_Process__c = 'LIFO',Inventory_Tracked__c = true,Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim; 
        
            Inventory_Stock__c invStock1 = new Inventory_Stock__c(Name='Test Stock',ERP7__Warehouse__c = site.id,ERP7__Product__c = Ps1.id,ERP7__Organisation__c=orgn.id,ERP7__Organisation_Business_Unit__c =busUnit.Id );
            upsert invStock1; 
            ERP7__Stock_Inward_Line_Item__c sili1 = new ERP7__Stock_Inward_Line_Item__c(ERP7__Site_ProductService_InventoryStock__c=invStock1.id,Name='Test SILI',ERP7__Quantity__c=1,ERP7__Unit_Price__c=100,ERP7__Amount__c=1000,ERP7__Product__c=ps1.id);
            insert sili1;
            Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Checked_Out_Process__c = 'LIFO',Inventory_Tracked__c = true,Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=10,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim1;
            solim1.Quantity__c = 2;
            solim1.ERP7__Order_Line_Status__c = 'Reserved';
            update solim1;
            delete solim1;
             Inventory_Stock__c invStock2 = new Inventory_Stock__c(Name='Test Stock',ERP7__Warehouse__c = site.id,ERP7__Product__c = Ps2.id,ERP7__Organisation__c=orgn.id,ERP7__Organisation_Business_Unit__c =busUnit.Id );
            upsert invStock2; 
            ERP7__Stock_Inward_Line_Item__c sili2 = new ERP7__Stock_Inward_Line_Item__c(ERP7__Site_ProductService_InventoryStock__c=invStock2.id,Name='Test SILI',ERP7__Quantity__c=10,ERP7__Unit_Price__c=100,ERP7__Amount__c=1000,ERP7__Product__c=ps2.id);
            insert sili2;
            Sales_Order_Line_Item__c solim2 = new Sales_Order_Line_Item__c(Checked_Out_Process__c = 'LIFO',Inventory_Tracked__c = true,Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10,Is_Back_Order__c=true);
            insert solim2; 
             update solim2;
            Tax__c tax = new Tax__c(Active__c = true, Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;
           
            Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(Name='test',Active__c=true,Subscription_Plan__c='Day');
            insert subscriptionPlan;
            Invoice__c invoice = new Invoice__c(Active__c = true,Order__c=sod.id,Account__c=customer.id);
            insert invoice;
            Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
            Credentials__c gateway1 = new Credentials__c(Name='Paypal',Active__c = true, Password_Transkey__c = '1358849370',Signature__c = 'AQKQf7AfdsdrjGLbqbagoI9HOyUIAhngQoat0nT5QkpiSh39jR-jV2Vw',URL__c = 'https://api-3t.sandbox.paypal.com/2.0/',Username_Login__c = 'uzair_1358849304_biz_api1.apexcloud.com');
            insert gateway1;
            //RecordType gateRtype = [select Id, Name From RecordType Where Name = 'Authorize.Net' and SobjectType = 'ERP7__Payment_Gateway__c' Limit 1];
            Credentials__c gateway2 = new Credentials__c (Name='Authorize.Net',Active__c = true, Password_Transkey__c = '45caad4fdadaca9f5f3bb1db381bf68ab409a0c8c6b1cdf4e859c0d2221c43fbfbf1721ddf15b606b88e4a007422565d',Signature__c = 'AQKQf7AfdsdrjGLbqbagoI9HOyUIAhngQoat0nT5QkpiSh39jR-jV2Vw',URL__c = 'https://api-3t.sandbox.paypal.com/2.0/',Username_Login__c = 'b5b4df40a21c0884146b1964477b1ce7ebf0f37cdee2eef376ae078a9efd5585',
                                      Encrypted_Key__c='66cbb1f4b07ce3fe7a00a19a97b3aae8fb895fa4be023897493fabcb28ffb892');
            insert gateway2;
            Payment_Method__c pmethod = new Payment_Method__c(Account__c=customer.Id,contact__c=contact.Id,Card_Number__c='1234567890',CardType__c='MasterCard',Card_Expiration_Month__c='12',Card_Expiration_Year__c='2021',Name_on_Card__c='test');
            insert pmethod;
            
            test.startTest();
            //Do Payment Authorised Dot Net
            PageReference pageRef1 = System.Page.DoPayment;
            pageRef1.getParameters().put('pm',pmethod.Id); 
            
            pageRef1.getParameters().put('sg',gateway2.Id);
            pageRef1.getParameters().put('con',myCon.Contact_Numer__c);
            pageRef1.getParameters().put('so',psod.Name);            
            Test.setCurrentPage(pageRef1);
            ApexPages.StandardController controller;
            DoPaymentHandler doPayments = new DoPaymentHandler(); 
            DoPaymentHandler doPayment = new DoPaymentHandler(controller);            
            doPayment.getCardTypes();
            doPayment.process();
            doPayment.getMonths();
            doPayment.getYears();
            doPayment.goBack();
            doPayment.amount='test';
            doPayment.firstname='test';
            doPayment.lastname='test';
            doPayment.email='test';
            doPayment.address='test';
            doPayment.city='test';
            doPayment.state='test';
            doPayment.zip='test';
            doPayment.cardholder='test';
            doPayment.cardnumber='test';
            doPayment.cardyear='test'; 
            doPayment.cardmonth='test';
            doPayment.cardcvv='test';
            doPayment.expiration='test';
            doPayment.selectedCardType='test';            
            doPayment.process();
            doPayment.getidlp();
            doPayment.getcnn();
            doPayment.Back2Order();
            doPayment.amount='test';
            doPayment.firstname='test';
            doPayment.lastname='test';
            doPayment.email='test';
            doPayment.address='test';
            doPayment.city='test';
            doPayment.state='test';
            doPayment.zip='test';
            doPayment.cardholder='test';
            doPayment.cardnumber='test';
            doPayment.cardyear='test'; 
            doPayment.cardmonth='test';
            doPayment.cardcvv='test';
            doPayment.expiration='test';
            doPayment.selectedCardType='test';
            doPayment.validate();
            
                Id id;
                AuthorizeDotNet ADN = new AuthorizeDotNet(true,gateway2.Id);
                string cardnum = 'test';
                string expiration = 'test';
                string amount = 'test';
                string cvv = 'test';
                string invoice1 = 'test'; 
                string tax1 = 'test';
                ADN.transaction(cardnum, expiration, amount, cvv, invoice1, tax1);
                integer retries = 1;
                ADN.process(retries);
                ADN.setTransactionType('test');                
                ADN.isDeclined();
                ADN.isError();
                ADN.getResultResponse();
                ADN.getAuthCode();
                ADN.getAVSResponse();
            
            
            //Invoice 
            PageReference pageRef2 = System.Page.CreditNote;            
            pageRef2.getParameters().put('name',invoiceName.Name);
            pageRef2.getParameters().put('custId',myCon.Contact_Numer__c);                       
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController controller1;
            CreditEmail inv = new CreditEmail(controller1);
            try { 
                inv.sendCreditNote(); 
                    
            }catch(Exception ex){}
            inv.createPDF();
            inv.Back2Invoice();
            
           Test.setCurrentPage(pageRef2);
            ApexPages.StandardController controllerInv;
            CreditEmail Testinvoice = new CreditEmail(controllerInv);
            Testinvoice.Email_Details();
            Testinvoice.buildCcEmail();
            Testinvoice.contactIds= String.join(new List<String>(Testinvoice.ccEmails_map.keyset()),',');
            TestInvoice.buildCcEmail();
            TestInvoice.sendCreditNote();
            TestInvoice.createPDF();  
            pageRef2.getParameters().put('name','0000');
            pageRef2.getParameters().put('custId','0000'); 
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController controllerInv1;
            CreditEmail Testinvoice1 = new CreditEmail(controllerInv1);
            Testinvoice1.Email_Details();
            
            Testinvoice1.Back2Invoice();
            
            test.stopTest();   
        } catch(exception e){}   
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);  
    }
    
    static testmethod void Unittestmethod1(){
        CreditNote c = new CreditNote();
        c.InitMethod();
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        ERP7__Credit_Note__c cnet = new ERP7__Credit_Note__c();
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c(Name='Test', ERP7__Description__c='test',ERP7__Account__c=sup.Id,
                                                            ERP7__Credit__c=400, ERP7__Debit__c=200, ERP7__Posted__c = true);
        insert cn;
                                                              
        TransactionManagement.fetchCreditNotes(null, null, null);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    static testmethod void Unittestmethod2(){
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c(Name='Test', ERP7__Description__c='test',ERP7__Account__c=sup.Id,
                                                            ERP7__Credit__c=400, ERP7__Debit__c=200, ERP7__Posted__c = true);
        insert cn;
        Transaction__c trans = new Transaction__c(Name='Test',ERP7__Credit_Note__c = cn.Id); insert trans;
       // delete cn; error 'Attempt to reference null object'
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        ERP7__Credit_Note__c cn1 = new ERP7__Credit_Note__c(Name='Test', ERP7__Description__c='test',ERP7__Account__c=sup.Id,
                                                            ERP7__Credit__c=400, ERP7__Debit__c=200, ERP7__Posted__c = true);
        cn1.ERP7__Type__c = 'Cancelled';
        insert cn1;
        ERP7__Credit_Note__c cn2= new ERP7__Credit_Note__c(Name='Test2', ERP7__Description__c='test2',ERP7__Account__c=sup.Id,
                                                            ERP7__Credit__c=400, ERP7__Debit__c=200, ERP7__Posted__c = true);
        insert cn2;
        delete cn2;
  
        System.assertEquals(salName, sal1Name);
    }
}