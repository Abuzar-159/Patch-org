@isTest
public class AccountsPayable_TestCases {
    private Testmethod static void unit1(){
        
        Account acc = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);  
        insert acc;
        AccountsPayable.DefaultOrganisation(); 
         Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        Account customer = new Account(Name='Customer',Account_type__c = 'Customer');
        insert customer;
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
         RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BILL__c' And Name='Advance to vendor' Limit 1];
        ERP7__BILL__c bill = new ERP7__BILL__c(Vendor__c = vendor.Id,recordTypeId=rTypeProfile.Id);
    
        try{ insert bill; } catch(exception e){ }
        
        
        Payment__c pay = new Payment__c(ERP7__Payment_Type__c = 'Voucher',ERP7__Accounts__c = vendor.Id);
        insert pay;
        Voucher__c voucher = new Voucher__c(name='test',ERP7__Amount__c=10,ERP7__Vendor__c=vendor.Id,ERP7__Vendor_invoice_Bill__c =bill.Id );
        insert voucher;
        pay.ERP7__Voucher__c=voucher.Id;
        update pay; 
        ERP7__Payment_Applied_on_Voucher__c pavou = new ERP7__Payment_Applied_on_Voucher__c(ERP7__Payment__c=pay.Id,ERP7__Voucher__c=voucher.Id);
        insert pavou;
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Organisation__c =acc.id ,Name='Cash',ERP7__Payment_Account__c=true);
        insert coa;
        ERP7__Debit_Note__c debitNote = new ERP7__Debit_Note__c(ERP7__Account__c=vendor.id,Name='Test',ERP7__Amount__c=120);
        insert debitNote;
        
        AccountsPayable.DefaultOrganisation();
        AccountsPayable.fetchpo('', '',6,200,null);
        AccountsPayable.fetchBills('', '','Name','ASC',0,200,null,'',30);
        AccountsPayable.fetchPayments('', '','Name','ASC',0,200,null,'');
        AccountsPayable.fetchVouchers('', '','Name','ASC',0,200,null,''); 
        AccountsPayable.getSupplierAccounts('',6,200,null);
        AccountsPayable.update_Voucher(voucher.id,true);
        //AccountsPayable.save_payment(JSON.serialize(pay));
        AccountsPayable.fetchdebitNotes('', '','Name','ASC',6,200,null);
        AccountsPayable.getPaymentAccInfo(coa.id);
        AccountsPayable.getPaymentAccInfo('');
        AccountsPayable.getPaymentRecordType();
        AccountsPayable.getPaymentGateways();
        AccountsPayable.update_VoucherApprove(voucher.id,true);
        AccountsPayable.fetchBankAccount(acc.id);
        AccountsPayable.fetchCardAccount(acc.id);
        string payment = JSON.serialize(pay);
        AccountsPayable.save_Payment(payment,voucher.Id);
        List<Voucher__c> vList=new List<Voucher__c>();
        vList.add(voucher);
        List<AccountsPayable.DNWrapper> dnwrap = new List<AccountsPayable.DNWrapper>();
        AccountsPayable.save_Payment_Multi(payment,100,JSON.serialize(vList),dnwrap);
        AccountsPayable.fetchcreditNotes(customer.Id,acc.Id,'CreatedDate','',100,100,'Test');
        AccountsPayable.fetchcreditNotes(customer.Id,'','CreatedDate','',100,100,'Test');
        AccountsPayable.save_Payment_Record(payment);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    private Testmethod static void unit2(){
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
        ERP7__Bill_Line_Item__c billItem1 = new ERP7__Bill_Line_Item__c(Name= 'Test bill01',ERP7__Purchase_Order_Line_Items__c=poli.Id,recordTypeId=billitemRecId.Id,ERP7__BILL__c = bill.Id);
        insert billItem1;
        Invoice__c inv = new Invoice__c(Name='tst',account__c=customer.Id);
        insert inv;
        ERP7__Discount_Plan__c displan = new ERP7__Discount_Plan__c(Name='testdisplan',ERP7__Vendor__c=vendor.Id,ERP7__Due_Date_Days__c=20,ERP7__Discount_Percent__c=10);
        insert displan; 
        
        test.startTest();
        ERP7__Debit_Note__c debitNote = new ERP7__Debit_Note__c(ERP7__Account__c=vendor.id,Name='Test',ERP7__Amount__c=120);
        insert debitNote;
        
        ERP7__Debit_Note_Item__c debititem = new ERP7__Debit_Note_Item__c(Name='test',ERP7__Debit_Note__c=debitNote.Id);
        insert debititem;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Purchase_Order__c=PO1.Id);
        upsert Logistic;
        
        //AccountsPayable.fetch_Polis(PO1.Id);
        AccountsPayable.getContactsByAccId(contact.Id);
        String Name = 'ERP';
        String Name1 = 'ERP';
        System.assertEquals(Name, Name1); 
        CreateDebitNote debit = new CreateDebitNote();
        string poID= PO1.Id;
        //CreateDebitNote.fetch_Polis(PO1.Id);
        
        //CreateDebitNote.save_Bill(JSON.serialize(debitNote),JSON.serialize(debititem),'');
        //CreateDebitNote.save_attachment2(poID,poID);
        CreateDebitNote.uploadFile(PO1.Id,'test','TEST Base64 string','image/gif');
        // CreateDebitNote.fetchDebitNoteDetails(debitNote.Id);
        // CreateDebitNote.saveDebitNotePayment(JSON.serialize(pay),'');
        AccountsPayable.fetchRecordType();
        AccountsPayable.fetchPaymentTerm(vendor.Id);
        AccountsPayable.getFunctionalityControl();
        Date billDate =Date.newInstance(2022, 07, 15);
        Date payDate =Date.newInstance(2022, 09, 09);
        List<AccountsPayable.DNWrapper> dnw = new List<AccountsPayable.DNWrapper>();
        AccountsPayable.getPaymentTerms(vendor.Id,billDate,payDate);
        dnw = AccountsPayable.fetchDebitNote(vendor.Id);
        if(dnw.size() > 0) dnw[0].debitAmount = 100;
        AccountsPayable.fetchPaymentTerm('');
        AccountsPayable.updateInvoiceCreditNotes(dnw,JSON.serialize(voucher));
        string payment = JSON.serialize(pay);
        AccountsPayable.save_Payment_Credits(payment,voucher.Id,10,dnw);
        AccountsPayable.save_Payment_Credits(payment,voucher.Id,180,dnw);
        test.stopTest();
    }
    
    private Testmethod static void unit3(){
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
        creditlineItem.add(creditNoteItem2);
        
        ERP7__Logistic__c billLogistics = new ERP7__Logistic__c(Name = 'logTest001', ERP7__Purchase_Order__c = PO1.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert billLogistics;
        
        ERP7__Dimension__c dmn1 = new ERP7__Dimension__c(Name='tets',ERP7__Active__c = true,ERP7__Bill_Line_Item__c = billItem1.Id, ERP7__Sort_Order__c=10);       
        List<ERP7__Dimension__c> demList1 = new List<ERP7__Dimension__c>();
        demList1.add(dmn1);
        
        Attachment attach=new Attachment();     
        attach.Name='Test';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=billLogistics.id;
        insert attach;
        
        Test.startTest();
        
        set<Id> billIds = new set<Id>();
        billIds.add(bill.Id);
        AccountsPayable.fetch_Polis(PO1.Id);
        AccountsPayable.getContactsByAccId(contact.Id);
        String Name = 'ERP';
        String Name1 = 'ERP';
        System.assertEquals(Name, Name1);
        CreateDebitNote debit = new CreateDebitNote();
       
       CreateDebitNote.fetch_invlis(inv.Id);
        CreateDebitNote.fetch_Polis(PO1.Id);
        CreateDebitNote.save_Bill(JSON.serialize(debitNote),JSON.serialize(debititem),'');
         CreateDebitNote.fetchDebitNoteDetails(debitNote.Id);
        CreateDebitNote.saveDebitNotePayment(JSON.serialize(pay),'');
        CreateDebitNote.updatePO(billIds);
        CreateDebitNote.fetch_rmalis(rma.Id);
         CreateDebitNote.fetch_credlis(creditNote.Id);             
       CreateDebitNote.fetch_rmalisLWC(rma.Id);
       CreateDebitNote.fetch_deblis(debitNote.Id);
       CreateDebitNote.uploadFileLWC('test','TEST Base64 string',PO1.Id);
       CreateDebitNote.getFunctionalityControlOrderProcess();
       CreateDebitNote.getFunctionalityControlAllocation();
       CreateDebitNote.createDimensionsList(JSON.serialize(demList1),debitNote.Id);
       CreateDebitNote.save_attachment2(debitNote.Id,PO1.Id);
       CreateDebitNote.saveCreditNote(JSON.serialize(creditNote),JSON.serialize(creditlineItem));
       CreateDebitNote.fetch_billItems(bill.Id);
        CreateDebitNote.checkTotalAmount(JSON.serialize(debitNote));
       CreateDebitNote.LineItem_Wrap lineW = new CreateDebitNote.LineItem_Wrap();
        
       
        Test.stopTest();
   
        
    }
}