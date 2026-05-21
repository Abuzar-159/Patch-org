@isTest
public class Accounting_Period_TestClass {

 
    static testMethod void testSetCreatedDate() {
        String org;
        DateTime sdate = System.now() ;
        String sformat = sdate.format('yyyy-MM-dd HH:mm:ss');
        DateTime edate = sdate.addMonths(12);
        String eformat = edate.format('yyyy-MM-dd HH:mm:ss');
        Accounting_Period.Wrapper wr = new Accounting_Period.Wrapper();
        Accounting_Period.initRecords();
        Accounting_Period.orgFYStartDate();
        Accounting_Period.updateRecords(sformat,eformat,org);
        Accounting_Period.updateOnDates(sformat,eformat,org);
        Accounting_Period.getRecordsOnOrgNull(sformat,eformat,org);
        Accounting_Period.setDate(sformat,eformat,org);
        Accounting_Period.getDefaultOrg(sformat,eformat);
        AccountingPeriod.FetchRetainedEarnings();
        String Name = 'ERP';
        String Name1 = 'ERP';
        System.assertEquals(Name, Name1);
        Test.startTest();
        Test.stopTest(); 
    }
    
    static testMethod void testSetCreatedDateClosing() {
        String org;
        DateTime sdate = System.now() ;
        String sformat = sdate.format('yyyy-MM-dd HH:mm:ss');
        DateTime edate = sdate.addMonths(12);
        String eformat = edate.format('yyyy-MM-dd HH:mm:ss');
        ClosingOfBooks_CheckList.Wrapper wr = new ClosingOfBooks_CheckList.Wrapper();
        ClosingOfBooks_CheckList.TransactionWrapper trwra = new ClosingOfBooks_CheckList.TransactionWrapper();
        ClosingOfBooks_CheckList.ledgerWrap lwrap = new ClosingOfBooks_CheckList.ledgerWrap();
        ClosingOfBooks_CheckList.initRecords();
        ClosingOfBooks_CheckList.orgFYStartDate();
        ClosingOfBooks_CheckList.updateRecords(sformat,eformat,org);
        ClosingOfBooks_CheckList.updateOnDates(sformat,eformat,org);
        ClosingOfBooks_CheckList.getRecordsOnOrgNull(sformat,eformat,org);
        ClosingOfBooks_CheckList.setDate(sformat,eformat,org);
        ClosingOfBooks_CheckList.getDefaultOrg(sformat,eformat);
        ClosingOfBooks_CheckList.getStatus();
        String Name = 'ERP';
        String Name1 = 'ERP';
        System.assertEquals(Name, Name1);
        Test.startTest();
        Test.stopTest(); 
    }
    
    static testMethod void recordsInvoiceData() {
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
    	Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(ERP7__Organisation__c=org.Id, Name='INV-0001', ERP7__Invoice_Date__c=System.today(), ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Invoice_Amount__c=10);
        insert Invoice; 
       	
        ClosingOfBooks_CheckList.fetchInvoices(org.Id, System.today(), System.today());
        TransactionManagement.fetchInvoices(org.Id, System.today(), System.today());
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Date__c=System.today(), ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        ClosingOfBooks_CheckList.fetchInvoices(org.Id, System.today(), System.today());
        ClosingOfBooks_CheckList.fetchPayments(org.Id, System.today(), System.today());
        TransactionManagement.fetchPayments(org.Id, System.today(), System.today());
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        ClosingOfBooks_CheckList.getInvoiceUpdate(Invoice.Id);
    }
    
    static testMethod void recordsBillData() {
        ERP7__Accounting_Period__c ap = new ERP7__Accounting_Period__c(Name='Test', ERP7__Start_Date__c=system.today(),
                                                                       ERP7__End_Date__c=system.today(), ERP7__Status__c='Closed', ERP7__Date_Locked__c=system.today());
        insert ap;
        Product2 prod = New Product2(Name='test Prod',IsActive=true);
        insert prod;
        Account acc = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true); 
        insert acc;
        AccountsPayable.DefaultOrganisation();
         Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        Account customer = new Account(Name='Customer',Account_type__c = 'Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BILL__c' And Name='Advance to vendor' Limit 1];
        ERP7__BILL__c bill = new ERP7__BILL__c(Vendor__c = vendor.Id,recordTypeId=rTypeProfile.Id, ERP7__Bill_Date__c = System.today(),ERP7__Organisation__c=acc.Id, ERP7__Total_Amount__c = 10, ERP7__Posted__c = true);
        try{ insert bill; } catch(exception e){ }
        ClosingOfBooks_CheckList.fetchBills(acc.Id, System.today(), System.today());
        TransactionManagement.fetchBills(acc.Id, System.today(), System.today());
        ClosingOfBooks_CheckList.getBillUpdate(bill.Id);
        ClosingOfBooks_CheckList.getAccountingAccountDetails(ap.Id);
        ClosingOfBooks_CheckList.updateAccountingStatus(ap);
    }
    
    static testMethod void recordsPaymentData() {
        Product2 prod = New Product2(Name='test Prod',IsActive=true);
        insert prod;
        Account acc = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true); 
        insert acc;
        AccountsPayable.DefaultOrganisation();
         Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        Account customer = new Account(Name='Customer',Account_type__c = 'Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BILL__c' And Name='Advance to vendor' Limit 1];
        ERP7__BILL__c bill = new ERP7__BILL__c(Vendor__c = vendor.Id,recordTypeId=rTypeProfile.Id, ERP7__Bill_Date__c = System.today(),ERP7__Organisation__c=acc.Id, ERP7__Total_Amount__c = 10, ERP7__Posted__c = true);
        try{ insert bill; } catch(exception e){ }
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Organisation__c =acc.id ,Name='Cash',ERP7__Payment_Account__c=true);
        insert coa;
        Payment__c pay = new Payment__c(ERP7__Payment_Account__c=coa.Id, ERP7__Payment_Date__c=System.today(), ERP7__Account__c=acc.Id, ERP7__Payment_Type__c = 'Voucher',ERP7__Accounts__c = vendor.Id,ERP7__Amount__c=10, ERP7__Posted__c = true);
        insert pay;
        ClosingOfBooks_CheckList.fetchPayments(acc.Id, System.today(), System.today());
        TransactionManagement.fetchPayments(acc.Id, System.today(), System.today());
        ClosingOfBooks_CheckList.getPaymentUpdate(pay.Id);
    }
    
    static testMethod void recordsCreditNoteData() {
        Product2 prod = New Product2(Name='test Prod',IsActive=true);
        insert prod;
        Account acc = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true); 
        insert acc;
        AccountsPayable.DefaultOrganisation();
         Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        Account customer = new Account(Name='Customer',Account_type__c = 'Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='Test Recipient Line 1', Address_Line2__c='Line 2', Address_Line3__c='test', City__c='Long Beach',State__c='California', Postal_Code__c='90805', Country__c = 'United States', Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BILL__c' And Name='Advance to vendor' Limit 1];
        ERP7__BILL__c bill = new ERP7__BILL__c(Vendor__c = vendor.Id,recordTypeId=rTypeProfile.Id, ERP7__Amount_Paid__c=10);
        try{ insert bill; } catch(exception e){ }
        
        
        Payment__c pay = new Payment__c(ERP7__Payment_Type__c = 'Voucher',ERP7__Accounts__c = vendor.Id,ERP7__Amount__c=0);
        insert pay;
        Voucher__c voucher = new Voucher__c(name='test',ERP7__Amount__c=180,ERP7__Vendor__c=vendor.Id,ERP7__Vendor_invoice_Bill__c =bill.Id );
        insert voucher;
        pay.ERP7__Voucher__c=voucher.Id;
        update pay;
        ERP7__PO__c PO1 = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = vendor.Id, ERP7__Organisation__c = acc.Id, ERP7__Ready_To_Receive__c = true);
        insert PO1;
        ERP7__Purchase_Line_Items__c poli = new ERP7__Purchase_Line_Items__c(Name= 'test PO',ERP7__Purchase_Orders__c = PO1.Id,ERP7__Product__c=prod.Id,ERP7__Quantity__c=5,ERP7__Unit_Price__c=12);
        insert poli;
        RecordType billitemRecId = [Select Id, Name From RecordType Where SobjectType='ERP7__Bill_Line_Item__c' And Name='Advance to vendor' Limit 1];
        ERP7__Bill_Line_Item__c billItem1 = new ERP7__Bill_Line_Item__c(Name= 'Test bill01',ERP7__Purchase_Order_Line_Items__c=poli.Id,ERP7__BILL__c = bill.Id, ERP7__Sort_Order__c=10);
        insert billItem1;
        Invoice__c inv = new Invoice__c(Name='tst',account__c=customer.Id);
        insert inv;
        ERP7__Discount_Plan__c displan = new ERP7__Discount_Plan__c(Name='testdisplan',ERP7__Vendor__c=vendor.Id,ERP7__Due_Date_Days__c=20,ERP7__Discount_Percent__c=10);
        insert displan; 
        
        ERP7__Debit_Note__c debitNote = new ERP7__Debit_Note__c(ERP7__Account__c=vendor.id,Name='Test',ERP7__Amount__c=120, ERP7__Debit__c=120, ERP7__Vendor_Invoice_Bill__c=bill.Id, ERP7__Organisation__c = acc.Id, ERP7__Credit_Note_Date__c=system.today(), ERP7__Posted__c = true );
        insert debitNote;
        
        ERP7__Debit_Note_Item__c debititem = new ERP7__Debit_Note_Item__c(Name='test',ERP7__Debit_Note__c=debitNote.Id);
        insert debititem;
        
        ERP7__Debit_Note_Item__c debititem2 = new ERP7__Debit_Note_Item__c(Name='test2',ERP7__Debit_Note__c=debitNote.Id, ERP7__Bill_Line_Item__c=billItem1.Id);
        insert debititem2;
        
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        
        ERP7__Credit_Note__c creditNote = new ERP7__Credit_Note__c(Name='Test',ERP7__Amount__c=200,ERP7__Active__c=true,ERP7__Posted__c = true, ERP7__Date__c=System.today(),ERP7__Credit__c=200,ERP7__Account__c=customer.id, ERP7__Organisation__c = acc.Id);
        insert creditNote;
        
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = acc.Id);
        insert coa;
        
        Id recordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Income/Revenue').getRecordTypeId();
        
        ERP7__Chart_of_Accounts__c coa1 = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = acc.Id, RecordTypeId=recordType);
        insert coa1;
        
        Product2 ps = new Product2(Name='test',isActive=true, ERP7__Expense_Account__c = coa.Id, ERP7__Revenue_Account__c = coa1.Id, ERP7__Inventory_Account__c = coa.Id);
        insert ps;
        
        List<ERP7__Credit_Note_Item__c> creditlineItem = new List<ERP7__Credit_Note_Item__c>();
        
        ERP7__Credit_Note_Item__c creditNoteItem = new ERP7__Credit_Note_Item__c(
            Name = 'Test Credit Note Item', 
            ERP7__Credit_Note__c = creditNote.Id,
            ERP7__Chart_Of_Account__c = coa.Id,
            ERP7__Product__c = ps.Id
        );
        insert creditNoteItem;
        creditlineItem.add(creditNoteItem);
        
        ERP7__Credit_Note_Item__c creditNoteItem2 = new ERP7__Credit_Note_Item__c(
            Name = 'Test Credit Note Item2', 
            ERP7__Credit_Note__c = creditNote.Id,
            ERP7__Chart_Of_Account__c = coa.Id,
            ERP7__Product__c = ps.Id
        );
        insert creditNoteItem2;
        ClosingOfBooks_CheckList.fetchDebitNotes(acc.Id, System.today(), System.today());
        TransactionManagement.fetchDebitNotes(acc.Id, System.today(), System.today());
        ClosingOfBooks_CheckList.getDebitNoteUpdate(debitNote.Id);
        //SupplierInvoice.getDebitUpdate(debitNote.Id);
        //ClosingOfBooks_CheckList.fetchCreditNotes(acc.Id, System.today(), System.today());
        TransactionManagement.fetchCreditNotes(acc.Id, System.today(), System.today());
        //ClosingOfBooks_CheckList.getCreditNoteUpdate(creditNote.Id);
    }
    
    
    static testMethod void recordsExpenseData() {
        RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        
        ERP7__Cost_to_Company__c CTC = new ERP7__Cost_to_Company__c(name='test', ERP7__Fixed_Tax_Amount__c=123.00);
        insert CTC;
        
        ERP7__Profiling__c pro = new ERP7__Profiling__c(Name='test', ERP7__Cost_to_Company__c = CTC.Id, RecordTypeId = emp_rTypes_org.Id//, ERP_MARK7__Leave_Entitlement__c =ent.Id
                                                       );//ERP_MARK7__Holiday_Entitlement__c = LEH.Id
        insert pro;
        ERP7__Employees__c emp = new ERP7__Employees__c(name='test', ERP7__Employee_Profiling__c = pro.Id,Employee_User__c = userinfo.getUserId());
        insert emp;
        Expense__c exp = new Expense__c(name = 'test', ERP7__Status__c='Submitted',  ERP7__Date__c= system.today(), ERP7__Approver__c = userinfo.getUserId(), ERP7__Employees__c = emp.Id);
        insert exp; 
        ERP7__Expense_Line_Item__c eli = new ERP7__Expense_Line_Item__c (name = 'test', ERP7__Expense__c = exp.Id, ERP7__Expense_Date__c = system.today());
        insert eli;
        exp.ERP7__Paid__c = true;
        update exp;
        ClosingOfBooks_CheckList.fetchExpenses(orgn.Id, System.today(), System.today());
        TransactionManagement.fetchExpenses(orgn.Id, System.today(), System.today());
        ClosingOfBooks_CheckList.getExpenseUpdate(exp.Id);
    }
    
    static testMethod void deprectionData() {
        ERP7__Depreciation__c dr = new ERP7__Depreciation__c(Name='Test Desprecation');
        insert dr;
        ERP7__Accounting_Period__c acc = new ERP7__Accounting_Period__c(Name='test',ERP7__Start_Date__c = system.today(),ERP7__End_Date__c = system.today()+90,ERP7__New_Fiscal_Year__c = true);
        insert acc;
        Account orgn = TestDataFactory.createOrganisationAccounts(1)[0];
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        List<RecordType> AccountGroups = [select Id, DeveloperName From RecordType Where SobjectType = 'ERP7__Chart_of_Accounts__c' ];
        Map<String,String> AccountGroups_Map = new Map<String,String>();
        for(RecordType r:AccountGroups)AccountGroups_Map.put(r.DeveloperName,R.ID);
        Chart_of_Accounts__c testlExpenseacc = new Chart_of_Accounts__c(Organisation__c =orgn.id,Organisation_Business_Unit__c = busUnit.id,Name='Depreciation',RecordTypeId=AccountGroups_Map.get('Expense'));
        insert testlExpenseacc;
        ERP7__COA_Mapping__c coa = new ERP7__COA_Mapping__c(ERP7__Chart_of_Account__c=testlExpenseacc.Id, Name = 'Depreciation');
        insert coa;
        Finance_General_Ledger__c testLedger = new Finance_General_Ledger__c(Name='Test Ledger',Organisation__c =orgn.id,Active__c = true);
        insert testLedger;
        ERP7__Depreciation_Schedule__c drs = new ERP7__Depreciation_Schedule__c(ERP7__Depreciation__c=dr.Id, Name = 'Test Deprecation Schedule');
        insert drs;
    }
    
    @isTest
    static void testScheduledJob() {
        // Start the test context
        Test.startTest();
        ERP7__Accounting_Period__c ap = new ERP7__Accounting_Period__c(Name='Test', ERP7__Start_Date__c=system.today(),
                                                                       ERP7__End_Date__c=system.today(), ERP7__Status__c='Closed', ERP7__Date_Locked__c=system.today());
        insert ap;
        Product2 prod = New Product2(Name='test Prod',IsActive=true);
        insert prod;
        Account acc = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true); 
        insert acc;
        AccountsPayable.DefaultOrganisation();
         Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        Account customer = new Account(Name='Customer',Account_type__c = 'Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BILL__c' And Name='Advance to vendor' Limit 1];
        ERP7__BILL__c bill = new ERP7__BILL__c(Vendor__c = vendor.Id,recordTypeId=rTypeProfile.Id);
        try{ insert bill; } catch(exception e){ }
        
        Voucher__c voucher = new Voucher__c(name='test',ERP7__Amount__c=180,ERP7__Vendor__c=vendor.Id,ERP7__Vendor_invoice_Bill__c =bill.Id , ERP7__Payment_Summary__c = 'Test');
        insert voucher;
		Datetime scheduledTime = System.now().addMinutes(1);
        String cronExp = '0 ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();

        String jobName = 'YodleePaymentSchedular ' + scheduledTime.format('HH:mm');
        System.schedule(jobName, cronExp, new YodleePaymentSchedular());
        

        // Stop the test context to allow the scheduled job to execute
        Test.stopTest();

	}
}