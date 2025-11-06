@IsTest(SeeAllData=true)
private class PreventPostingTestClass {
	    static testMethod void DebitNotePosting() {
        // Create a Finance module with the ERP7__Run_Posting_Trigger__c field set to true
               
        Account s = new Account(Name='Test', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
            
        Account o = new Account(Name='Test', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        // Create a Debit Note record
        ERP7__Debit_Note__c debitNote = new ERP7__Debit_Note__c(Name='Test',ERP7__Amount__c=200,ERP7__Active__c=true,	ERP7__Credit__c=200,ERP7__Account__c=s.id, ERP7__Organisation__c = o.Id);
        insert debitNote;
		
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id);
        insert coa;
        ERP7__COA_Mapping__c coaMap = new ERP7__COA_Mapping__c(Name='POReturn');
        insert coaMap;
        ERP7__COA_Mapping__c coaMap1 = new ERP7__COA_Mapping__c(Name='POReturn');
        insert coaMap1;
        // Create a Debit Note Item record with a null ERP7__Chart_Of_Account__c field
        ERP7__Debit_Note_Item__c debitNoteItem = new ERP7__Debit_Note_Item__c(
            Name = 'Test Debit Note Item', 
            ERP7__Debit_Note__c = debitNote.Id,
            ERP7__Chart_Of_Account__c = coa.Id
        );
        insert debitNoteItem;
        
        Test.startTest();
        // Update the Debit Note record to trigger the trigger
        debitNote.ERP7__Posted__c = true;
        update debitNote;
            
        List<ERP7__Debit_Note__c> newInvoices = new List<ERP7__Debit_Note__c>{debitNote};
        Map<Id, ERP7__Debit_Note__c> newInvoiceMap = new Map<Id, ERP7__Debit_Note__c>{debitNote.Id => debitNote};
        Map<Id, ERP7__Debit_Note__c> oldInvoiceMap = new Map<Id, ERP7__Debit_Note__c>();
        PostingPreventingHandler.handleDebitNoteAfterInsert(newInvoices, newInvoiceMap, oldInvoiceMap);
        Test.stopTest();
        
        
    }
    
    
  static testMethod void BillPosting() {
        // Create a Finance module with the ERP7__Run_Posting_Trigger__c field set to true
           
        Account orgn = new Account(Name='unit2Organisation', Account_Type__c = 'Organisation', default__c=true);
        insert orgn;
        Account Customer = new Account(Name='unit2Customer', Account_Type__c = 'Customer');
        insert Customer;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Vendor');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        Contact Supcontact = new Contact(AccountId=sup.Id,LastName = 'testoiuhwsdgybnacontact', Email = 'tjKCXHQSXBKQvxest@test.com' ,Contact_Numer__c='tesjkFXQVSGXVWQITt_123');
        insert supcontact;
        Address__c bAddress = new Address__c( Customer__c = sup.Id, Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c bAddress1 = new Address__c( Customer__c = sup.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account', Organisation__c = orgn.Id);
        insert BA;
        PO__c PO = new PO__c( Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress1.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
        insert PO;  
        Product2 ps = new Product2(Name='test', Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps; 
        
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = orgn.Id);
        insert coa;
        ERP7__COA_Mapping__c coaMap = new ERP7__COA_Mapping__c(Name='Purchase');
        insert coaMap;
        ERP7__COA_Mapping__c coaMap1 = new ERP7__COA_Mapping__c(Name='Purchase');
        insert coaMap1;
        ERP7__COA_Mapping__c coaMap2 = new ERP7__COA_Mapping__c(Name='Expense');
        insert coaMap2;
        ERP7__COA_Mapping__c coaMap3 = new ERP7__COA_Mapping__c(Name='Expense');
        insert coaMap3;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=3,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];     
        List<Purchase_Line_Items__c> poliList = [select id, name,  Unit_Price__c,
                                                 Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
        Bill__c bill = new Bill__c(Vendor__c=sup.id,ERP7__Purchase_Order__c=PO1.Id,ERP7__Vendor_Address__c=bAddress.Id,ERP7__Vendor_Contact__c=Supcontact.Id,ERP7__Vendor_Bill_Number__c='1234', ERP7__Amount__c=2000, ERP7__VAT_TAX_Amount__c = 0,  ERP7__Matched__c=true, ERP7__Issue_Voucher__c=true);  
        insert bill;
        
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Bill_Line_Item__c billLine1 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000, ERP7__Discount__c =0 , ERP7__Chart_Of_Account__c=coa.Id);
        insert billLine1;
        Test.startTest();
        // Update the bill record to trigger the trigger
        bill.ERP7__Posted__c = true;
        bill.ERP7__Posting_Date__c = system.today();
        update bill;
        
        List<Bill__c> newInvoices = new List<Bill__c>{bill};
        Map<Id, Bill__c> newInvoiceMap = new Map<Id, Bill__c>{bill.Id => bill};
        Map<Id, Bill__c> oldInvoiceMap = new Map<Id, Bill__c>();
        PostingPreventingHandler.handleBillAfterInsert(newInvoices, newInvoiceMap, oldInvoiceMap);
        Test.stopTest();
        
        
    }
    
    static testMethod void PaymentPosting() {
        // Create a Finance module with the ERP7__Run_Posting_Trigger__c field set to true
        
        Account s = new Account(Name='Test', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
            
        Account o = new Account(Name='Test', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id);
        insert coa;
        
        ERP7__COA_Mapping__c coaMap = new ERP7__COA_Mapping__c(Name='AdvancePayment');
        insert coaMap;
        ERP7__COA_Mapping__c coaMap1 = new ERP7__COA_Mapping__c(Name='InvoicePayment');
        insert coaMap1;
        ERP7__COA_Mapping__c coaMap2 = new ERP7__COA_Mapping__c(Name='InvoicePayment');
        insert coaMap2;
        ERP7__COA_Mapping__c coaMap3 = new ERP7__COA_Mapping__c(Name='BillPayment');
        insert coaMap3;
        ERP7__COA_Mapping__c coaMap4 = new ERP7__COA_Mapping__c(Name='BillPayment');
        insert coaMap4;
        ERP7__COA_Mapping__c coaMap5 = new ERP7__COA_Mapping__c(Name='CreditPayment');
        insert coaMap5;
        ERP7__COA_Mapping__c coaMap6 = new ERP7__COA_Mapping__c(Name='CreditPayment');
        insert coaMap6;
        ERP7__COA_Mapping__c coaMap7 = new ERP7__COA_Mapping__c(Name='VoucherPayment');
        insert coaMap7;
        ERP7__COA_Mapping__c coaMap8 = new ERP7__COA_Mapping__c(Name='VoucherPayment');
        insert coaMap8;
        // Create a Payment record
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Payment_Account__c = coa.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        pay.ERP7__Transaction_Type__c = 'InvoicePayment';
        insert pay;
        
        Test.startTest();
        // Update the Payment record to trigger the trigger
        //pay.ERP7__Posted__c = true;
        //update pay;
        List<ERP7__Payment__c> newInvoices = new List<ERP7__Payment__c>{pay};
        Map<Id, ERP7__Payment__c> newInvoiceMap = new Map<Id, ERP7__Payment__c>{pay.Id => pay};
        Map<Id, ERP7__Payment__c> oldInvoiceMap = new Map<Id, ERP7__Payment__c>();
        PostingPreventingHandler.handlePaymentAfterInsert(newInvoices, newInvoiceMap, oldInvoiceMap);
        Test.stopTest();
        
        
    }
    
    static testMethod void CreditNotePosting() {
        // Create a Finance module with the ERP7__Run_Posting_Trigger__c field set to true
            
        Account s = new Account(Name='Test', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
            
        Account o = new Account(Name='Test', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        // Create a Credit Note record
        ERP7__Credit_Note__c creditNote = new ERP7__Credit_Note__c(Name='Test',ERP7__Amount__c=200,ERP7__Active__c=true,	ERP7__Credit__c=200,ERP7__Account__c=s.id, ERP7__Organisation__c = o.Id);
        insert creditNote;
		
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id);
        insert coa;
        Id recordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Income/Revenue').getRecordTypeId();
        
        ERP7__Chart_of_Accounts__c coa1 = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id, RecordTypeId=recordType);
        insert coa1;
        ERP7__COA_Mapping__c coaMap = new ERP7__COA_Mapping__c(Name='CreditsReturn');
        insert coaMap;
        ERP7__COA_Mapping__c coaMap1 = new ERP7__COA_Mapping__c(Name='CreditsReturn');
        insert coaMap1;
        Product2 ps = new Product2(Name='test',isActive=true, ERP7__Expense_Account__c = coa.Id, ERP7__Revenue_Account__c = coa1.Id, ERP7__Inventory_Account__c = coa.Id);
        insert ps;
        // Create a Credit Note Item record
        ERP7__Credit_Note_Item__c creditNoteItem = new ERP7__Credit_Note_Item__c(
            Name = 'Test Credit Note Item', 
            ERP7__Credit_Note__c = creditNote.Id,
            ERP7__Chart_Of_Account__c = coa.Id,
            ERP7__Product__c = ps.Id
        );
        insert creditNoteItem;
        
        Test.startTest();
        // Update the Credit Note record to trigger the trigger
        //creditNote.ERP7__Posted__c = true;
        //update creditNote;
        List<ERP7__Credit_Note__c> newInvoices = new List<ERP7__Credit_Note__c>{creditNote};
        Map<Id, ERP7__Credit_Note__c> newInvoiceMap = new Map<Id, ERP7__Credit_Note__c>{creditNote.Id => creditNote};
        Map<Id, ERP7__Credit_Note__c> oldInvoiceMap = new Map<Id, ERP7__Credit_Note__c>();
        PostingPreventingHandler.handleCreditNoteAfterInsert(newInvoices, newInvoiceMap, oldInvoiceMap);
        Test.stopTest();
        
        
    }
    
    static testMethod void InvoicePosting() {
        // Create a Finance module with the ERP7__Run_Posting_Trigger__c field set to true
            
        Account s = new Account(Name='Test', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
            
        Account o = new Account(Name='Test', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        // Create a Invoice record
        ERP7__Invoice__c invoice = new ERP7__Invoice__c(Name='Test',ERP7__Active__c=true,ERP7__Account__c=s.id, ERP7__Organisation__c = o.Id);
        insert invoice;
		
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id);
        insert coa;
        Id recordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Income/Revenue').getRecordTypeId();
        
        ERP7__Chart_of_Accounts__c coa1 = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id, RecordTypeId=recordType);
        insert coa1;
        ERP7__COA_Mapping__c coaMap = new ERP7__COA_Mapping__c(Name='Sales');
        insert coaMap;
        ERP7__COA_Mapping__c coaMap1 = new ERP7__COA_Mapping__c(Name='Sales');
        insert coaMap1;
        Product2 ps = new Product2(Name='test',isActive=true, ERP7__Expense_Account__c = coa.Id, ERP7__Revenue_Account__c = coa1.Id, ERP7__Inventory_Account__c = coa.Id);
        insert ps;
        // Create a Invoice Item record
        ERP7__Invoice_Line_Item__c invoiceItem = new ERP7__Invoice_Line_Item__c(
            Name = 'Test Invoice Item', 
            ERP7__Invoice__c = invoice.Id,
            ERP7__Product__c = ps.Id
        );
        insert invoiceItem;
        
        Test.startTest();
        // Update the Invoice record to trigger the trigger
        invoice.ERP7__Posted__c = true;
        invoice.ERP7__Posted_Date__c = system.today();
        update invoice;
        
        
        List<ERP7__Invoice__c> newInvoices = new List<ERP7__Invoice__c>{invoice};
        Map<Id, ERP7__Invoice__c> newInvoiceMap = new Map<Id, ERP7__Invoice__c>{invoice.Id => invoice};
        Map<Id, ERP7__Invoice__c> oldInvoiceMap = new Map<Id, ERP7__Invoice__c>();
        PostingPreventingHandler.handleInvoiceAfterInsert(newInvoices, newInvoiceMap, oldInvoiceMap);
        Test.stopTest();
        
        
    }
    
    
    static testMethod void ManageInvoice() {
        // Create a Finance module with the ERP7__Run_Posting_Trigger__c field set to true
           
        Account s = new Account(Name='Test', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
            
        Account o = new Account(Name='Test', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        // Create a Invoice record
        ERP7__Invoice__c invoice = new ERP7__Invoice__c(Name='Test',ERP7__Active__c=true,ERP7__Account__c=s.id, ERP7__Organisation__c = o.Id);
        insert invoice;
		
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id);
        insert coa;
        Id recordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Income/Revenue').getRecordTypeId();
        
        ERP7__Chart_of_Accounts__c coa1 = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = o.Id, RecordTypeId=recordType);
        insert coa1;
        ERP7__COA_Mapping__c coaMap = new ERP7__COA_Mapping__c(Name='Sales');
        insert coaMap;
        ERP7__COA_Mapping__c coaMap1 = new ERP7__COA_Mapping__c(Name='Sales');
        insert coaMap1;
        Product2 ps = new Product2(Name='test',isActive=true, ERP7__Expense_Account__c = coa.Id, ERP7__Revenue_Account__c = coa1.Id, ERP7__Inventory_Account__c = coa.Id);
        insert ps;
        // Create a Invoice Item record
        ERP7__Invoice_Line_Item__c invoiceItem = new ERP7__Invoice_Line_Item__c(
            Name = 'Test Invoice Item', 
            ERP7__Invoice__c = invoice.Id,
            ERP7__Product__c = ps.Id
        );
        insert invoiceItem;
        ERP7__Invoice_Line_Item__c invoiceItem2 = new ERP7__Invoice_Line_Item__c(
            Name = 'Test Invoice Item2', 
            ERP7__Invoice__c = invoice.Id,
            ERP7__Product__c = ps.Id
        );
        insert invoiceItem2;
        List<ERP7__Invoice_Line_Item__c> invList = new List<ERP7__Invoice_Line_Item__c>();
        invList.add(invoiceItem);
        List<Id> invListDel = new List<Id>();
        invListDel.add(invoiceItem2.Id);
        String OrdId='';
        Test.startTest();
        ManageInvoice.fetchRecord(invoice.Id);
        ManageInvoice.getInvoiceLineItems(invoice.Id);
        ManageInvoice.updateRecords(invList,invoice,invListDel);
        ManageInvoice.delItem(invList);
        ManageInvoice.getFieldsSetApiName('ERP7__Invoice__c','ERP7__Create_Order_Invoice');
        ManageInvoice.getInvoicesofOrder(OrdId,invoice.Id);
        ManageInvoice.getInvoicesofSales(OrdId,invoice.Id);
        //ManageInvoice.getInvoicesofOrder()
        // Update the Invoice record to trigger the trigger
        //invoice.ERP7__Posted__c = true;
        //update invoice;
        Test.stopTest();
        
        
    }
    
    static testmethod void manufacturingOrder(){
        Account o = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert o;
         
        Account s = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert s;
        
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer', AccountNumber='1234', ERP7__Company__c='Aqxolt India Pvt Ltd',
                                ERP7__Start_of_Week__c='Monday', ERP7__CustomerPriority__c='High', ERP7__Active__c='Yes', ERP7__SLA__c='Gold',
                                ERP7__SLAExpirationDate__c=system.today());
        insert c;
        
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = o.id);
        insert channel;
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = o.id);
        insert site;
        
        Product2 product = new Product2(Name='Test', ProductCode='PC-017', Family='Fruits', ERP7__Status__c='In Developement', ERP7__Track_Inventory__c=true, ERP7__Transactable__c=true, 
                                        ERP7__Weight_Dimensions__c='Gram', ERP7__Category__c='IT', ERP7__Sub_Category__c='Software', ERP7__Weight__c=10,
                                        ERP7__Is_Kit__c=true, ERP7__Price_Entry_Amount__c=45, ERP7__MOQ__c=20, ERP7__Serialise__c=true, ERP7__ASIN_Code__c='test',
                                        ERP7__Width__c=2, ERP7__Lot_Tracked__c=true, ERP7__Manufacturing_Type__c='Process', ERP7__Item_Description__c='test');
        insert product;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        
        
        Inventory_Stock__c inventorystock = new Inventory_Stock__c(Organisation__c = o.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=product.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock;
        
        Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=c.Id, Phone='1234567890', Email='test@gmail.com', ERP7__Company__c='Aqxolt',
                                  ERP7__Level__c='Secondary');
        insert con;
        
        ERP7__Process__c process = new ERP7__Process__c(Name='Test', ERP7__Process_Name__c='Test', ERP7__Manufacturing_Assembly_Costs__c=10,
                                                        ERP7__Workforce_Hour_Required__c=12, ERP7__Machine_Hour_Required__c=15, ERP7__Other_Material_Cost__c=10,
                                                        ERP7__Machine_Usage_Cost__c=10, ERP7__Workforce_Cost__c=10);
        insert process;
        
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name='Test', ERP7__Progress__c=3, ERP7__Process__c=process.Id);
        insert processcycle;
        
        //Id pricebookId = Test.getStandardPricebookId();
        //PricebookEntry pricebookentry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = product.Id, UnitPrice = 10000, IsActive = true);
        //insert pricebookentry;
        
        Pricebook2 pricebook = new Pricebook2(Name='Standard Pricebook', isActive=true);
        insert pricebook;
        
        ERP7__Version__c version = new ERP7__Version__c(Name='test', ERP7__Product__c = product.Id, ERP7__Category__c='Production', ERP7__Price_Book__c=pricebook.Id, ERP7__Inventory_Stock__c=inventorystock.Id,
                                                        ERP7__Start_Date__c=system.today(), ERP7__To_Date__c=system.today(), ERP7__Type__c='Assembly', ERP7__Status__c='Certified', ERP7__Default__c=true);
        insert version;
        
        ERP7__Routing__c routing = new ERP7__Routing__c(Name='Test', ERP7__Status__c='Certified', ERP7__Type__c='Parallel', ERP7__BOM_Version__c=version.Id, ERP7__Product__c=product.Id, ERP7__Channel__c=channel.Id,
                                                        ERP7__Raw_Materials_Site__c=site.Id, ERP7__Description__c='test', ERP7__Process__c=process.Id, ERP7__Finished_Products_Site__c=site.Id,
                                                        ERP7__Minimum_Lot_Size__c=100, ERP7__Maximum_Lot_Size__c=1000);
        insert routing;
        
        ERP7__Project__c project = new ERP7__Project__c(Name='Test', ERP7__Active__c=true, ERP7__Start_Date__c=system.today(), ERP7__End_Date__c=system.today(), ERP7__Requisition_Type__c='Goods',
                                                        ERP7__Status__c='New');
        insert project;
        
        ERP7__Manufacturing_Order__c manuorder = new ERP7__Manufacturing_Order__c(Name='Test', ERP7__Product__c=product.Id, ERP7__Version__c=version.Id, ERP7__Status__c='Complete', ERP7__Quantity__c=10, ERP7__Routing__c=routing.Id,
                                                                                  ERP7__Lead_Time__c=system.today(), ERP7__Progress__c=100, ERP7__Project__c=project.Id, ERP7__StartDate__c=system.Now(),
                                                                                  ERP7__End_Date__c=system.today(), ERP7__Expected_Date__c=system.today(), ERP7__Completion_Date__c=system.today(), ERP7__Labour_Cost__c=10, ERP7__Material_Cost__c=10,
                                                                                  ERP7__Overhead_Cost__c=10, ERP7__In_Production__c=true, ERP7__Manufactured_Quantity__c=9, ERP7__Scrapped_Quantity__c=1);
        insert manuorder;
        List<ERP7__Manufacturing_Order__c> moList = new List<ERP7__Manufacturing_Order__c>();
        moList.add(manuorder);
        Set<Id> moids = new Set<Id>();
        for(ERP7__Manufacturing_Order__c man : moList){
            moids.add(man.Id); 
        }
        PostingPreventingHandler.createTransactionsAndLedgerEntries(moList, moids);
    }
    
    static testmethod void stockInward(){
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c TestEmp = new ERP7__Employees__c(Name='Test',ERP7__Employee_User__c=userInfo.getUserId());
        insert TestEmp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test',ERP7__Barcode__c='TestSite');
        insert site;
        ERP7__Location__c loc1 = new ERP7__Location__c(Name='loc1',ERP7__Site__c=site.id);
        insert loc1;
        ERP7__Location__c loc2 = new ERP7__Location__c(Name='loc2',ERP7__Site__c=site.id,ERP7__Barcode__c='Testlocation');
        insert loc2;
        ERP7__StorageContainer__c bin1 = new ERP7__StorageContainer__c(Name='Bin1',ERP7__Site__c=site.id,ERP7__Location__c=loc1.Id);
        insert bin1;
        ERP7__StorageContainer__c bin2 = new ERP7__StorageContainer__c(Name='Bin2',ERP7__Site__c=site.id,ERP7__Location__c=loc2.Id);
        insert bin2;
        product2 pro1 = new Product2(IsActive=true, Name='Test Product-1', ERP7__Track_Inventory__c = true, StockKeepingUnit='Test1',ERP7__Barcode__c='rec');
        insert pro1;
        ERP7__Inventory_Stock__c is = new ERP7__Inventory_Stock__c(Name='Test Inventory Stock', ERP7__Warehouse__c = site.id,ERP7__Location__c = loc1.id,ERP7__product__c = pro1.id);
        insert is;
        ERP7__Stock_Inward_Line_Item__c  sili = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true, ERP7__Site_ProductService_InventoryStock__c = is.id,ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 50.00);
        insert sili; 
        ERP7__Stock_Take__c sT = new ERP7__Stock_Take__c(Name = 'Test', ERP7__Approver__c = TestEmp.Id, ERP7__Employee__c =TestEmp.Id, ERP7__Start_Date__c = system.today(), ERP7__End_Date__c = system.today() , ERP7__Site__c = site.Id, ERP7__Status__c = 'Open');
        insert sT;
        ERP7__Stock_Take_Line_Item__c STLI = new ERP7__Stock_Take_Line_Item__c(ERP7__Stock_Take__c = sT.Id, ERP7__Inventory_Stock__c = is.Id, ERP7__Stock_Available__c = 50, ERP7__Stock_In_Hand__c = 0.00, ERP7__Variance__c = 0.00, ERP7__Unit_Price__c = 15);
        insert STLI;
        ERP7__Stock_Inward_Line_Item__c  sili1 = new ERP7__Stock_Inward_Line_Item__c (ERP7__Active__c =true, ERP7__Site_ProductService_InventoryStock__c = is.id, ERP7__Stock_Take_Line_Item__c = STLI.Id,ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 50.00);
        insert sili1;
        ERP7__Stock_Outward_Line_Item__c soli1 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c =true, ERP7__Site_Product_Service_Inventory_Stock__c  = is.id, ERP7__Stock_Take_Line_Item__c = STLI.Id, ERP7__Product__c  = pro1.id, ERP7__Quantity__c = 5.00);
        insert soli1; 
        List<ERP7__Stock_Take_Line_Item__c> siliList = new List<ERP7__Stock_Take_Line_Item__c>();
        siliList.add(STLI);
        Set<Id> siliids = new Set<Id>();
        for(ERP7__Stock_Take_Line_Item__c stock : siliList){
            siliids.add(stock.Id);
        }
        PostingPreventingHandler.createTransactionsAndLedgerEntriesSTLine(siliList, siliids);
    }
    

}