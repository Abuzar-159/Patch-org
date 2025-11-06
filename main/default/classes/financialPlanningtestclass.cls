@isTest
public with sharing class financialPlanningtestclass {
    @isTest
    private static void unit1() {

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
        
        ERP7__Debit_Note__c debitNote = new ERP7__Debit_Note__c(ERP7__Account__c=vendor.id,Name='Test',ERP7__Amount__c=120, ERP7__Vendor_Invoice_Bill__c=bill.Id);
        insert debitNote;
        
        ERP7__Debit_Note_Item__c debititem = new ERP7__Debit_Note_Item__c(Name='test',ERP7__Debit_Note__c=debitNote.Id);
        insert debititem;
        
        ERP7__Debit_Note_Item__c debititem2 = new ERP7__Debit_Note_Item__c(Name='test2',ERP7__Debit_Note__c=debitNote.Id, ERP7__Bill_Line_Item__c=billItem1.Id);
        insert debititem2;
        
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        
        ERP7__Credit_Note__c creditNote = new ERP7__Credit_Note__c(Name='Test',ERP7__Amount__c=200,ERP7__Active__c=true,    ERP7__Credit__c=200,ERP7__Account__c=customer.id, ERP7__Organisation__c = acc.Id);
        insert creditNote;
        
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = acc.Id);
        insert coa;
        
        Id recordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Income/Revenue').getRecordTypeId();
        
        ERP7__Chart_of_Accounts__c coa1 = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = acc.Id, RecordTypeId=recordType);
        insert coa1;
        
        Product2 ps = new Product2(Name='test',isActive=true, ERP7__Expense_Account__c = coa.Id, ERP7__Revenue_Account__c = coa1.Id, ERP7__Inventory_Account__c = coa.Id);
        insert ps;

          ERP7__Chart_of_Accounts__c coa3 = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = acc.Id);
        insert coa3;

         ERP7__Project__c proj = new ERP7__Project__c(Name = 'Test project',ERP7__Active__c = true);
        insert proj;

         Date fromDate = Date.today().addDays(-10); // 10 days ago
        Date toDate = Date.today();                // today
 test.startTest();
       
         financialplanning.getMonthlyCreditDebitSummary(2024);
         financialplanning.getMonthlyIncomeExpense(2024);
            financialplanning.getChartOfAccountsByType('Expense');
            financialplanning.getCustomerInvoiceSummary('Overdue');
            financialplanning.getRevenueCostPerProduct();
            financialplanning.getMonthlyIncomeExpensenew(fromDate, toDate);
            financialplanning.getOverallIncomeAndExpenseTotals();
            financialplanning.getOverallExpenseBreakdown();
            financialplanning.getFilteredExpenseBreakdown(fromDate, toDate);
            financialplanning.getBudgetPlanData();
            financialplanning.getChartOfAccountTotals();
            financialplanning.getProjectBudgetsByChartOfAccount(coa.Id);
            financialplanning.getProjectsByChartOfAccount(coa.Id);
            financialplanning.getSingleProjectBudget(coa.Id, proj.Id);
            financialplanning.getChartOfAccountsWithBudgetAccounts();
        financialplanning.getCurrencySymbol();
        financialplanning.getGroupedInvoiceBillDetails('Overdue');
        financialplanning.getMonthlyIncomeExpenseWithPrediction();
          Map<String, Object> result = financialplanning.getYearlyIncomeAndExpenseWithPrediction();

  test.stopTest();



        

    }
    
  
}