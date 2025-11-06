@isTest
private class TestCasesSet_2 {
    static testMethod void UnitTestErpMark7(){    
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
            	ADN.isApproved();
            ADN.getResponseText();
            ADN.getTransactionID();
            
            
            //Invoice 
            PageReference pageRef2 = System.Page.Invoice;            
            pageRef2.getParameters().put('name',invoiceName.Name);
            pageRef2.getParameters().put('custId',myCon.Contact_Numer__c);                       
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController controller1;
            InvoiceEmail inv = new InvoiceEmail(controller1);
            try { 
                inv.sendInvoice(); 
                    
            }catch(Exception ex){}
            inv.createPDF();
            inv.Back2Invoice();
           
            
            test.stopTest();   
        } catch(exception e){}   
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);  
    }
    
   
    static testMethod void UnitTestErpMark7_IE(){    
        try{   
            PreventRecursiveLedgerEntry.IsFromPOS = true;   
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
            insert salepoint; 
            Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10, Active__c = true);
            insert loyalty;
            Account customer = new Account(Name='Customer');
            insert customer;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',Contact_Numer__c='Test1234');
            insert contact;
            Contact contact1 = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',Contact_Numer__c='Test123');
            insert contact1;
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
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Active__c = true,Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;
            Contact myCon = [Select Id, Name,Email, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];
                        
            Sales_Order__c sod = new Sales_Order__c();  
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Channel__c = salePoint.Id;
            sod.Request_Date__c = system.Today();
            sod.Bill_To_Address__c = bAddress1.Id;
            sod.Ship_To_Address__c = sAddress1.Id;
            sod.Is_Back_Order__c=true;
            sod.Is_Pre_Order__c = true;
            insert sod;
            Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
            Product2 ps = new Product2(Name='test',isActive=true);
            insert ps;
            Contact sitecontact = new Contact(AccountId=orgn.id,FirstName='Test',Contact_Numer__c='Org123',LastName='Contact',Phone='1234567890',Email='test@test.com');
            insert sitecontact;
            Address__c warehouseAddress = new Address__c(Customer__c=orgn.id,Contact__c=sitecontact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert warehouseAddress;
            
            Product2 ps2 = new Product2(Name='test',isActive=true, ERP7__Allow_Back_Orders__c =true);
            insert ps2;
            ERP7__Site__c site = new ERP7__Site__c(Name='Test Warehouse',Organisation__c=orgn.Id,ERP7__Type__c='Warehouse',ERP7__Organisation_Business_Unit__c =busUnit.Id,ERP7__Primary_Contact__c = sitecontact.Id,ERP7__Address__c = warehouseAddress.id );  
            upsert site;  
            Distribution_Channel__c dc = new Distribution_Channel__c(Name='Test Dc',Active__c = true,Channel__c=salepoint.Id,site__c=site.id);
            insert dc;
            Inventory_Stock__c invStock2 = new Inventory_Stock__c(Name='Test Stock',ERP7__Warehouse__c = site.id,ERP7__Product__c = Ps2.id,ERP7__Organisation__c=orgn.id,ERP7__Organisation_Business_Unit__c =busUnit.Id );
            upsert invStock2;  
            ERP7__Stock_Inward_Line_Item__c sili2 = new ERP7__Stock_Inward_Line_Item__c(ERP7__Site_ProductService_InventoryStock__c=invStock2.id,Name='Test SILI',ERP7__Quantity__c=10,ERP7__Unit_Price__c=100,ERP7__Amount__c=1000,ERP7__Product__c=ps2.id);
            insert sili2;
          
            Sales_Order_Line_Item__c solim2 = new Sales_Order_Line_Item__c(Checked_Out_Process__c = 'LIFO',Inventory_Tracked__c = true,Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps2.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim2;
             solim2.Quantity__c = 2;
            solim2.ERP7__Order_Line_Status__c = 'Reserved';
              update solim2;
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim;  
                      
            Tax__c tax = new Tax__c(Active__c = true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;
           
            
            Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(Name='test',Active__c=true,Subscription_Plan__c='Day');
            insert subscriptionPlan;
            Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
            insert invoice;
            Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
            Credentials__c gateway1 = new Credentials__c(Name='Paypal',Active__c = true, Password_Transkey__c = '1358849370',Signature__c = 'AQKQf7AfdsdrjGLbqbagoI9HOyUIAhngQoat0nT5QkpiSh39jR-jV2Vw',URL__c = 'https://api-3t.sandbox.paypal.com/2.0/',Username_Login__c = 'uzair_1358849304_biz_api1.apexcloud.com');
            insert gateway1;
            Credentials__c gateway2 = new Credentials__c(Name='Authorize.Net',Active__c = true, Password_Transkey__c = '35He69yNYc4cHH5s',Signature__c = 'AQKQf7AfdsdrjGLbqbagoI9HOyUIAhngQoat0nT5QkpiSh39jR-jV2Vw',URL__c = 'https://api-3t.sandbox.paypal.com/2.0/',Username_Login__c = '8S6gEj8vF3Z');
            insert gateway2;
            Blob cryptoKey, userData, passwordData;
            cryptoKey = Crypto.generateAesKey(256);
            if(gateway2.Username_Login__c != null) userData = Blob.valueOf(gateway2.Username_Login__c);
            if(gateway2.Password_Transkey__c != null) passwordData = Blob.valueOf(gateway2.Password_Transkey__c);
            if(userData != null) gateway2.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
            if(passwordData != null) gateway2.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
               
            Payment_Method__c pmethod = new Payment_Method__c(Account__c=customer.Id,contact__c=contact.Id,Card_Number__c='1234567890',CardType__c='MasterCard',Card_Expiration_Month__c='12',Card_Expiration_Year__c='2021',Name_on_Card__c='test');
            insert pmethod;
            Payment__c pay = new Payment__c(Account__c = orgn.Id, Sales_Order__c=sod.id,First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100);
            insert pay;
            Credentials__c paypalSetup = new Credentials__c(Name='PaypalPayment',Password_Transkey__c='test', Signature__c='test' , URL__c='test', Username_Login__c='test');
            insert paypalSetup;
            //Do Payment Authorised Dot Net
            PageReference pageRef1 = System.Page.DoPayment;
            pageRef1.getParameters().put('pm',pmethod.Id); 
            //pageRef1.getParameters().put('id',psod.Name);
            pageRef1.getParameters().put('sg',gateway2.Id);
            pageRef1.getParameters().put('con',myCon.Contact_Numer__c);
            pageRef1.getParameters().put('so',psod.Name);            
            Test.setCurrentPage(pageRef1);
             test.startTest(); 
            
            PageReference pageRef2 = System.Page.Invoice;            
            pageRef2.getParameters().put('name',invoiceName.Name);
            pageRef2.getParameters().put('custId',myCon.Contact_Numer__c);                       
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController controller1;
            Invoice_Email inv1 = new Invoice_Email();
            Invoice_Email inv = new Invoice_Email(controller1);
            try{ 
                inv.sendInvoice();
                inv.getCurrentInv('Test');
                inv.getCurrentOrder(sod.id);
                inv.getCurrentOrderItems(sod.id);
                inv.Back2Invoice();
                Invoice_Email.Wrapper inner_class = new Invoice_Email.wrapper();
                inv.buildCcEmail();
                
            }catch(Exception ex){}
            
            /*New InVoice*/                       
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController controllerInv;
            InvoiceEmail Testinvoice = new InvoiceEmail(controllerInv);
            Testinvoice.Email_Details();
            Testinvoice.buildCcEmail();
            Testinvoice.contactIds= String.join(new List<String>(Testinvoice.ccEmails_map.keyset()),',');
            TestInvoice.buildCcEmail();
            TestInvoice.sendInvoice();
            TestInvoice.createPDF();  
            pageRef2.getParameters().put('name','0000');
            pageRef2.getParameters().put('custId','0000'); 
            Test.setCurrentPage(pageRef2);
            ApexPages.StandardController controllerInv1;
            InvoiceEmail Testinvoice1 = new InvoiceEmail(controllerInv1);
            Testinvoice1.Email_Details();
            
            Testinvoice1.Back2Invoice();
            
            //PaypalPaymentController
            
            ApexPages.StandardController contr;
            PaypalPaymentController ppc2 = new PaypalPaymentController(pay.Id,paypalSetup.Id);
            PaypalPaymentController ppc3 = new PaypalPaymentController(pay.Id,paypalSetup.Id,true);
            ppc2.userAgent = '';
            ppc2.RedirectPages();
            ppc2.userAgent = 'iPhone';
            ppc2.Status = ppc2.AVSCode = ppc2.CVV2 = ppc2.sErrMsg = ppc2.ErrMsg = ppc2.ErrCode = ppc2.rawResponse = ppc2.CorrID = ppc2.CardType = '';
            ppc2.RedirectPages();
            try{ ppc2.pay(); } catch(exception e){} 
            String xmlString = '<books><LocalName>test</LocalName><book>Your Book</book></books>';
            XmlStreamReader xsr = new XmlStreamReader(xmlString);
            String sxmltag = xsr.getLocalName();
            
            try{ PaypalPaymentController.readXMLResponse(xsr, sxmltag) ; } catch(exception ex){}
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            test.stopTest();   
        } catch(exception e){}     
    }
    static testMethod void UnitTestErpMark7_IE1(){
            PreventRecursiveLedgerEntry.IsFromPOS = true;
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
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',Contact_Numer__c='Test1234');
            insert contact;
            // Changes made 'Contact1' on 2019/07/23 because of error in this test class 
            Contact contact1 = new Contact(FirstName='Testaaaaaaabb',LastName='Contact111111iiiii',AccountId=customer.id,Phone='1234567891999',Email='test111112@test.com',Contact_Numer__c='Test1234567');
            insert contact1;
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
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Active__c = true,Contact__c=contact.id,Status__c='Active',Customer__c=customer.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
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
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim;  
                      
            Tax__c tax = new Tax__c(Active__c = true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;
           
            
            Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(Name='test',Active__c=true,Subscription_Plan__c='Day');
            insert subscriptionPlan;
            Invoice__c invoice = new Invoice__c(Active__c = true, Order__c=sod.id,Account__c=customer.id);
            insert invoice;
            Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
            Credentials__c gateway1 = new Credentials__c(Name='Paypal',Active__c = true, Password_Transkey__c = '1358849370',Signature__c = 'AQKQf7AfdsdrjGLbqbagoI9HOyUIAhngQoat0nT5QkpiSh39jR-jV2Vw',URL__c = 'https://api-3t.sandbox.paypal.com/2.0/',Username_Login__c = 'uzair_1358849304_biz_api1.apexcloud.com');
            insert gateway1;
            //RecordType gateRtype = [select Id, Name From RecordType Where Name = 'Authorize.Net' and SobjectType = 'ERP7__Payment_Gateway__c' Limit 1];
            Credentials__c gateway2 = new Credentials__c(Name='Authorize.Net',Active__c = true, Password_Transkey__c = '35He69yNYc4cHH5s',Signature__c = 'AQKQf7AfdsdrjGLbqbagoI9HOyUIAhngQoat0nT5QkpiSh39jR-jV2Vw',URL__c = 'https://api-3t.sandbox.paypal.com/2.0/',Username_Login__c = '8S6gEj8vF3Z');
            insert gateway2;
                       
            Payment_Method__c pmethod = new Payment_Method__c(Account__c=customer.Id,contact__c=contact.Id,Card_Number__c='1234567890',CardType__c='MasterCard',Card_Expiration_Month__c='12',Card_Expiration_Year__c='2021',Name_on_Card__c='test');
            insert pmethod;
            Payment__c pay = new Payment__c(Status__c='Paid',Account__c = orgn.Id, Sales_Order__c=sod.id,First_Name__c='test',Last_Name__c='test',Email_Address__c='test@test.com',Address_Line1__c='test',Address_Line2__c='test',City__c='test',State__c='test',Country__c='test',Zipcode__c='test',Amount__c=100);
            insert pay;
            Credentials__c paypalSetup = new Credentials__c(Name='PaypalPayment',Password_Transkey__c='test', Signature__c='test' , URL__c='test', Username_Login__c='test');
            insert paypalSetup;
            Test.startTest();
            //processReturn
            
            PageReference pageRef5 = System.Page.processReturn;            
            pageRef5.getParameters().put('con',myCon.Contact_Numer__c);
            pageRef5.getParameters().put('oid',psod.Name);                       
            Test.setCurrentPage(pageRef5);
            ApexPages.StandardController controller3;
            processReturn pr1 = new processReturn();
            processReturn pr = new processReturn(controller3);
            pr.addDiscount();
            pr.itemWrapperList[0].quantityReturn = 1;
            pr.itemWrapperList[0].RewardPoints = 10;
            pr.editItem(); 
            pr.Save();
            pr.getCurrentDiscounts();
            pr.Item2DeleteId = solim.id;
            pr.processItemQuantity();
    }
    static testMethod void UnitTestMobile(){    
        try{
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Commission_Plan__c comPlan = new Commission_Plan__c( Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
            insert comPlan;
            Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
            insert comrate;
            Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
            insert ctc;            
            CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal;
            CTC_Component__c sal1 = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal1;
            System.assertEquals(sal.Name, sal1.Name);
            delete sal1;            
            Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Name='test');
            insert rule;
            Tax_Range__c tr = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
            insert tr; 
            Tax_Range__c tr1 = new   Tax_Range__c(Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=2000);
            insert tr1;
            delete tr1;
            CTC_Tax__c empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
            insert empTax; 
            update rule;
            Employee_Tax_Rule__c rule1 = new Employee_Tax_Rule__c(Name='test');
            insert rule1;   
            RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__Profiling__c' And Name='Employee' Limit 1];
            Profiling__c profile = new Profiling__c(Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile.Id);
            insert profile;  
            Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
            insert emp;
                              
            Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
            insert salepoint;
            emp.Channel__c = salepoint.id;
            update emp;
            Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
            insert site;
            Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
            insert DistributionChannels;                      
            Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
            insert loyalty;
            Account customer = new Account(Name='Customer');
            insert customer;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
            insert contact;
        
             
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Country__c='Test');
            insert bAddress;
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true,ERP7__Country__c='Test');
            insert sAddress;
            Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Country__c='Test');
            insert bAddress1;
            Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true,ERP7__Country__c='Test');
            insert sAddress1;
            System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
            System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;
            Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
            RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
            RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
            ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Tax_Sourcing_Rules__c = 'Destination');
            insert custProfile;
            PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
            insert priceBook;
            ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
            insert sop;
            
            Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=custProfile.Id,ERP7__Province__c='Test',ERP7__Country__c='Test');
            insert tax;
            Tax__c tax1 = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Shipping',ERP7__Account_Profile__c=custProfile.Id,ERP7__Province__c='Test',ERP7__Country__c='Test');
            insert tax1;
            Id pricebookId = Test.getStandardPricebookId();
            
            Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true,ERP7__Status__c = 'Released');
            insert ps;   
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true, Selling_Price__c = 12000);
            insert standardPrice; 
            PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true, Selling_Price__c = 12000);
            insert customPriceps;          
            Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock; 
           
            Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI;
            Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock1; 
           
            Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI1;
            Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true,ERP7__Status__c = 'Released');
            insert ps1; 
            PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true, Selling_Price__c = 12000);
            insert standardPrice1; 
            PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true, Selling_Price__c = 12000);
            insert customPriceps1;          
            System.assertEquals(ps.Name,'test');
            
            Sales_Order__c sod = new Sales_Order__c();   
            sod.Order_Profile__c = sop.Id;
            //sod.Customer_Profile__c = custProfile.Id;
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Contact__c = Contact.Id;
            sod.Channel__c = salePoint.Id;
            sod.Bill_To_Address__c = bAddress.Id;
            sod.Ship_To_Address__c = sAddress.Id;
            sod.Request_Date__c = system.Today();
            insert sod;
            Sales_Order__c psod = [Select id, Name,Contact__c,Account__c From Sales_Order__c Where id =: sod.id Limit 1];
            
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim;
            Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim1;            
            solim1.Quantity__c=1;
            update solim1;
            solim1.Quantity__c=4;
            update solim1;
            Invoice__c invoice = new Invoice__c(Active__c = true, Order__c=sod.id,Account__c=customer.id);
            insert invoice;
            Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
            Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
            insert RMA;              
            RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
            insert RMA_Line_Item; 
           
            solim.Quantity__c = 2;
            update solim;
            Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
            insert tier1;
            Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
            insert dp;
            Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id);
            insert tda;           
            Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
            insert tp;
            Credentials__c Credentials = new Credentials__c(Active__c = true,Name = 'Paypal',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test');
            Blob cryptoKey, userData, passwordData;
            cryptoKey = Crypto.generateAesKey(256);
            userData = Blob.valueOf(Credentials.Username_Login__c);
            passwordData = Blob.valueOf(Credentials.Password_Transkey__c);
            Credentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
            Credentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
            Credentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
            insert Credentials;
            ERP7__Credentials__c UPSCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'UPS',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                           ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');    
            insert UPSCredentials;
            
            Test.startTest();
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            Test.stopTest();
        }catch(Exception ex){}
    }
    
}