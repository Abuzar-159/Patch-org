@isTest
private class OrderDocumentTestClass {
    
    static testmethod void UnitTestMethod(){
        Account c = new Account(Name='UnitTestMethodTestCust', ERP7__Account_Type__c='Customer');
        insert c;
        
        Account o = new Account(Name='UnitTestMethodTestOrg', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        
        Account s = new Account(Name='UnitTestMethodTestSupp', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
        
        Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=c.Id, Email='test@gmail.com',
                                  ERP7__Contact_Numer__c='con-001', ERP7__Company__c='Test Company',Contact_Numer__c='02922829');
        insert con;
        
        ERP7__Address__c billto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Billing_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert billto;
        
        ERP7__Address__c shipto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Shipping_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert shipto;
        
        ERP7__Business_Unit__c bunit = new ERP7__Business_Unit__c(Name='Test', ERP7__Organisation__c=o.Id, ERP7__Active__c=true, ERP7__Country__c='United Kingdom',
                                                                  ERP7__City__c='Birmingham', ERP7__Phone__c='0123456789', ERP7__Mailing_Address_Line_1__c='test', ERP7__Contact__c=con.Id);
        insert bunit;
        
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=shipto.Id, ERP7__Company__c='Test', ERP7__Phone__c='0123456789',
                                                        ERP7__Active__c=true, ERP7__City__c='WORKINGTON', ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California',
                                                        ERP7__Country__c='United States', ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=o.Id, ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert channel;
        Id pricebookId = Test.getStandardPricebookId();
        
        Order so = new Order(Name='Test', Pricebook2Id = pricebookId,ERP7__Stage__c='Entered', AccountId=c.Id, ERP7__Contact__c=con.Id, ERP7__Channel__c=channel.Id,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             ERP7__Ready_To_Pick_Pack__c=true, ERP7__Ready_To_Ship__c=true, ERP7__Authorised__c=true, ERP7__Is_Invoice_Sent__c=true, ERP7__Estimated_Delivery_Date__c=system.today(),
                             ERP7__Bill_To_Address__c=billto.Id, ERP7__Book_Date__c=system.today(), ERP7__Organisation__c=o.Id,
                             ERP7__Active__c=true, Status='Draft', ERP7__Barcode__c='009220', ERP7__Customer_Email__c='test@gmail.com', EffectiveDate=Date.today(),
                             ERP7__Fulfilled_Date__c=system.today(), ERP7__Amount_Paid__c=10, ERP7__Ship_To_Address__c=shipto.Id, ERP7__Request_Date__c=system.today(),
                             ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert so;
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        //Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        OrderItem soli = new OrderItem(OrderId=so.Id, Product2Id=prod.Id, UnitPrice=10,PricebookEntryId = standardPrice.Id,
                                       ERP7__Total_Price__c=10, ERP7__Sub_Total__c=10, ERP7__Active__c=true, ERP7__Organisation__c=o.Id,
                                       Quantity=1, ERP7__Inventory_Tracked__c=true, ERP7__Order_Line_Status__c='Reserved');
        insert soli;
        
        OrgWideEmailAddress orgw=new OrgWideEmailAddress(Address='Tan@x.com', DisplayName='Tanny', IsAllowAllProfiles=true);
        //insert orgw;
        Attachment attach=new Attachment(Name=so.Name+'.pdf',contentType='application/pdf',ParentId=so.id);
        //attach.Name=so.Name;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=so.id;
        insert attach;
        // EmailTemplate et = new EmailTemplate (Subject ='Subject',Body = 'test body',developerName = 'test', TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
        
        //	insert et;        
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:so.id];
        System.assertEquals(1, attachments.size());
        
        PageReference pageRef = System.Page.Stand_OrderDocument;
        pageRef.getParameters().put('SO Id',SO.Id);
        pageRef.getParameters().put('custId',con.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        OrderDocument SOD = new OrderDocument();
        try{ SOD.Email_Details();} catch(Exception e){}
        String SONum = so.Id;
        try {SOD.getSalesOrder(SONum); } catch(Exception e){SOD.exceptionMethod(e, 'getSalesOrder');}
        try{SOD.buildCcEmail();}catch(Exception e){}
        SOD.sendSO();
        try{SOD.createPDF();} catch(Exception e){SOD.exceptionMethod(e, 'createPDF');}
        try{SOD.Back2SO();}catch(Exception e){}
        Test.stopTest();
        
    }
    
    
    static testmethod void UnitTestMethod2()
    {
        Account c = new Account(Name='UnitTestMethodTestCust', ERP7__Account_Type__c='Customer');
        insert c;
        
        Account o = new Account(Name='UnitTestMethodTestOrg', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        
        Account s = new Account(Name='UnitTestMethodTestSupp', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
        
        Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=c.Id, Email='test@gmail.com',
                                  ERP7__Contact_Numer__c='con-001', ERP7__Company__c='Test Company',Contact_Numer__c='02922829');
        insert con;
        Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
        ERP7__BILL__c bill = new ERP7__BILL__c(Vendor__c = vendor.Id);
        try{ insert bill; } catch(exception e){ }
        Payment__c pay = new Payment__c(ERP7__Payment_Type__c = 'Voucher',ERP7__Accounts__c = vendor.Id);
        insert pay;
        Voucher__c voucher = new Voucher__c(name='test');
        insert voucher;
        
        ERP7__Address__c billto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Billing_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert billto;
        
        ERP7__Address__c shipto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Shipping_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert shipto;
        
        ERP7__Business_Unit__c bunit = new ERP7__Business_Unit__c(Name='Test', ERP7__Organisation__c=o.Id, ERP7__Active__c=true, ERP7__Country__c='United Kingdom',
                                                                  ERP7__City__c='Birmingham', ERP7__Phone__c='0123456789', ERP7__Mailing_Address_Line_1__c='test', ERP7__Contact__c=con.Id);
        insert bunit;
        
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=shipto.Id, ERP7__Company__c='Test', ERP7__Phone__c='0123456789',
                                                        ERP7__Active__c=true, ERP7__City__c='WORKINGTON', ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California',
                                                        ERP7__Country__c='United States', ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=o.Id, ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert channel;
        Id pricebookId = Test.getStandardPricebookId();
        Order so = new Order(Name='Test', Pricebook2Id = pricebookId ,ERP7__Stage__c='Entered', AccountId=c.Id, ERP7__Contact__c=con.Id, ERP7__Channel__c=channel.Id,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             ERP7__Ready_To_Pick_Pack__c=true, ERP7__Ready_To_Ship__c=true, ERP7__Authorised__c=true, ERP7__Is_Invoice_Sent__c=true, ERP7__Estimated_Delivery_Date__c=system.today(),
                             ERP7__Bill_To_Address__c=billto.Id, ERP7__Book_Date__c=system.today(), ERP7__Organisation__c=o.Id,
                             ERP7__Active__c=true, Status='Draft', ERP7__Barcode__c='009220', ERP7__Customer_Email__c='test@gmail.com', EffectiveDate=system.today(),
                             ERP7__Fulfilled_Date__c=system.today(), ERP7__Amount_Paid__c=10, ERP7__Ship_To_Address__c=shipto.Id, ERP7__Request_Date__c=system.today(),
                             ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert so;
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        OrderItem soli = new OrderItem(OrderId=so.Id, Product2Id=prod.Id, UnitPrice=10,PricebookEntryId = standardPrice.Id,
                                       ERP7__Total_Price__c=10, ERP7__Sub_Total__c=10, ERP7__Active__c=true, ERP7__Organisation__c=o.Id,
                                       Quantity=1, ERP7__Inventory_Tracked__c=true, ERP7__Order_Line_Status__c='Reserved');
        insert soli;
        
        OrgWideEmailAddress orgw=new OrgWideEmailAddress(Address='Tan@x.com', DisplayName='Tanny', IsAllowAllProfiles=true);
        Attachment attach=new Attachment();   	
        attach.Name=so.Name;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=pay.id;
        insert attach;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:pay.id];
        System.assertEquals(1, attachments.size());
        
        PageReference pageRef = System.Page.PaymentDocument;
        pageRef.getParameters().put('SO Id',pay.Id);
        pageRef.getParameters().put('custId',con.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        PaymentDocument SOD = new PaymentDocument();
        SOD.Email_Details();
        String SONum = pay.Id;
        SOD.getSalesOrder(SONum);
        try{SOD.buildCcEmail();}catch(Exception e){}
        SOD.sendSO();
        try{SOD.Back2SO();}catch(Exception e){}
        Test.stopTest();
        
    }
    static testmethod void UnitTestMethod3(){
        BankingOverview banko = new BankingOverview();
        BankingOverview.fetchDetails('','');
        BankingOverview.getCurrencies();
        BankingOverview.checkMultiCurrency cur = new BankingOverview.checkMultiCurrency();
        BankingOverview.setValues('','',0,0,0,0,false,cur);
        BankingOverview.fetchTrialRows('');
        BankingOverview.setValuesLiabRevnue('','',0,0,0,0,false,cur);
        BankingOverview.AcountsGroupMap tset1 = new BankingOverview.AcountsGroupMap();
        BankingOverview.selectOptions test2 = new BankingOverview.selectOptions('','');
        BankingOverview.vendorPayableWrap test3 = new BankingOverview.vendorPayableWrap();
        BankingOverview.VendorPayableWrapper test8 = new BankingOverview.VendorPayableWrapper();
        BankingOverview.fetchAllVendorPayables(system.today());
        BankingOverview.CustomerReceivableWrap test4 = new BankingOverview.CustomerReceivableWrap();
        BankingOverview.CustomerReceivableWrapper test5 = new BankingOverview.CustomerReceivableWrapper();
        BankingOverview.AcountsGroupMap test6 = new BankingOverview.AcountsGroupMap();
        BankingOverview.fetchAllCustomerReceivables(system.today());
        BankingOverview.searchOrg('');
    }
    static testmethod void UnitTestMethod4(){
        Account orgAccount = new Account(Name = 'Test Organisation', Account_Type__c = 'Organisation');
        insert orgAccount;
        
        ERP7__Finance_General_Ledger__c ledger = new ERP7__Finance_General_Ledger__c(
            ERP7__Organisation__c = orgAccount.Id, 
            ERP7__Active__c = true
        );
        insert ledger;
        
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(
            Name = 'Test COA',
            ERP7__Account_Code__c = '12345',
            ERP7__isContra_Account__c = false,
            ERP7__Account_Type__c = 'Assets',
            ERP7__Organisation__c = orgAccount.Id,
            ERP7__Opening_Balance__c = 1000,
            ERP7__Total_Credit__c = 500,
            ERP7__Total_Debit__c = 1500,
            ERP7__Active__c = true
        );
        insert coa;
       
        ERP7__Finance_General_Ledger_Entry__c ledgerEntry = new ERP7__Finance_General_Ledger_Entry__c(
            ERP7__Credit_Entry__c = 500,
            ERP7__Debit_Entry__c = 1500,
            ERP7__Chart_of_Account__c = coa.Id,
            ERP7__General_Ledger_Entry_DateTime__c = Date.today(),
            ERP7__Organisation__c = orgAccount.Id,
            ERP7__Finance_General_Ledger__c = ledger.Id
        );
        insert ledgerEntry;
        Test.startTest();
        
        // Initialize the controller
        BankingOverviewPdfDownload controller = new BankingOverviewPdfDownload();
        
        // Assert initial values
        System.assertEquals(controller.totalallDebit, 0.00);
        System.assertEquals(controller.totalallCredit, 0.00);
        Test.stopTest();        
    }
    @isTest
    static void testFetchTrialRows() {
                Account orgAccount = new Account(Name = 'Test Organisation', Account_Type__c = 'Organisation');
        insert orgAccount;
        
       
        
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(
            Name = 'Test COA',
            ERP7__Account_Code__c = '12345',
            ERP7__isContra_Account__c = false,
            ERP7__Account_Type__c = 'Assets',
            ERP7__Organisation__c = orgAccount.Id,
            ERP7__Opening_Balance__c = 1000,
            ERP7__Total_Credit__c = 500,
            ERP7__Total_Debit__c = 1500,
            ERP7__Active__c = true
        );
        insert coa;
         ERP7__Finance_General_Ledger__c  ledger = new ERP7__Finance_General_Ledger__c(ERP7__Organisation__c = orgAccount.Id,Name = 'test',ERP7__Active__c = true, ERP7__Start_Date__c = system.today(),ERP7__End_Date__c = system.today().addDays(30));
        insert ledger;
        ERP7__Finance_General_Ledger_Entry__c ledgerEntry = new ERP7__Finance_General_Ledger_Entry__c(
            ERP7__Credit_Entry__c = 500,
            ERP7__Debit_Entry__c = 1500,
            ERP7__Chart_of_Account__c = coa.Id,
            ERP7__General_Ledger_Entry_DateTime__c = Date.today(),
            ERP7__Organisation__c = orgAccount.Id,
            ERP7__Finance_General_Ledger__c = ledger.Id
        );
        insert ledgerEntry;
        Test.startTest();
        
        // Initialize the controller
        BankingOverviewPdfDownload controller = new BankingOverviewPdfDownload();
        
        // Set the required parameters
        ApexPages.currentPage().getParameters().put('coaName', 'Test COA');
        ApexPages.currentPage().getParameters().put('stDate', String.valueOf(Date.today().addDays(-10)));
        ApexPages.currentPage().getParameters().put('enDate', String.valueOf(Date.today()));
        
        // Invoke the method
        PageReference result = controller.fetchTrialRows();
        
        // Assert
        
        BankingOverview.getCurrencies();
        
        BankingOverviewPdfDownload bankingOverview = new BankingOverviewPdfDownload();
	    bankingOverview.classficationOfAccounts();
        bankingOverview.downloadAsPdf();
        List<Account> accounts = BankingOverviewPdfDownload.searchOrg('');

        BankingOverview.selectOptions bs = new BankingOverview.selectOptions('','',false);
        
        Test.stopTest();
    }

    

    
    
    
}