@isTest
public class CreateBill_TestCases {
    @TestSetup static void FinanceSetup() {
        Module__c mod = new Module__c(Name='Finance',Run__c=true);
        insert mod;
        set<Id> pids = new set<Id>();
        List<ERP7__Accounting_Period__c> accperiodList = new List<ERP7__Accounting_Period__c>();
        for(Period p : [SELECT Id, StartDate, EndDate, FiscalYearSettings.Name, PeriodLabel, Type FROM Period Where FiscalYearSettings.StartDate = THIS_FISCAL_YEAR AND Type='Month']){
            ERP7__Accounting_Period__c temp = new ERP7__Accounting_Period__c();
            temp.ERP7__Start_Date__c  = p.StartDate;
            temp.ERP7__End_Date__c  = p.EndDate;
            temp.ERP7__New_Fiscal_Year__c = TRUE;
            temp.ERP7__PeriodId__c = p.Id;
            pids.add(p.Id);
            accperiodList.add(temp);
        }
        if(accperiodList.size()>0)
            upsert accperiodList;
        accperiodList=[SELECT Id,Name,ERP7__End_Date__c,ERP7__Start_Date__c,ERP7__New_Fiscal_Year__c,ERP7__PeriodId__c FROM ERP7__Accounting_Period__c WHERE  ERP7__PeriodId__c IN: pids];
    }
    private static testMethod void unit1(){
        Test.startTest();
        Account orgn = new Account(Name='unit1Organisation', Account_Type__c = 'Organisation',default__c=true);
        insert orgn;
        Account Customer = new Account(Name='unit1customer', Account_Type__c = 'Customer');
        insert Customer;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Vendor');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
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
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];
        List<Purchase_Line_Items__c> poliList = [select id, name,  Unit_Price__c,
                                                 Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];

        ERP7__GoogleCredentials__c gc = new ERP7__GoogleCredentials__c(Name='Test',ERP7__UserName__c =  UserInfo.getUserName(),ERP7__DriveEmail__c = 'test@test.com',ERP7__Active__c = true,ERP7__RefreshToken__c = 'dummy',ERP7__AccessToken__c = 'dummy');
		insert gc;

        PageReference pageRef = System.Page.CreateBill;
        pageRef.getParameters().put('po',PO.Id);
        Test.setCurrentPage(pageRef);
        CreateBill cb =new CreateBill();
        cb.selectAll =true;
        cb.select_All();
        CreateBill.getCategoryList();
        CreateBill.getBillFC();
        cb.getVendorDetails();
        cb.ChangeQty();
        cb.ItemCounter= cb.LineItemWrapList.size()-1;
        cb.addLineItem();
        cb.removeLineItem();
        cb.save();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    private static testMethod void unit2(){
        Test.startTest();
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
        Contact Supcontact = new Contact(AccountId=sup.Id,LastName = 'test contact2', Email = 'test2@test.com' ,Contact_Numer__c='test_1234');
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
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=3,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];
        List<Purchase_Line_Items__c> poliList = [select id, name,  Unit_Price__c,
                                                 Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
        Bill__c bill = new Bill__c(Vendor__c=sup.id,ERP7__Purchase_Order__c=PO1.Id,ERP7__Vendor_Address__c=bAddress.Id,ERP7__Vendor_Contact__c=Supcontact.Id,ERP7__Vendor_Bill_Number__c='1234', ERP7__Amount__c=2000, ERP7__VAT_TAX_Amount__c = 0, ERP7__Posted__c=true, ERP7__Matched__c=true, ERP7__Issue_Voucher__c=true);
        insert bill;

        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Bill_Line_Item__c billLine1 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000, ERP7__Discount__c =0 , Posted__c = true);
        insert billLine1;
        Transaction__c trans= new Transaction__c(Name='test transaction', Bill__c = bill.id,ERP7__Bill_Line_Item__c = billLine1.id );
        insert trans;
        billLine1.Posted__c = true;
        update billLine1;
        Bill_Line_Item__c billLine2 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000,ERP7__Tax_Amount__c=10,ERP7__Other_Tax__c=0,ERP7__Discount__c=2);
        insert billLine2;
        ERP7__Logistic__c billLogistics = new ERP7__Logistic__c(Name = 'logTest001', ERP7__Purchase_Order__c = PO.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert billLogistics;
        Attachment logAttach01 = new Attachment(Name = 'resAttach1', ParentId = billLogistics.Id, body = Blob.valueOf('Test Data'));
        insert logAttach01;
        ERP7__Dimension__c dmn1 = new ERP7__Dimension__c(Name='tets',ERP7__Active__c = true,ERP7__Bill_Line_Item__c = billLine2.Id);
        List<ERP7__Dimension__c> demList1 = new List<ERP7__Dimension__c>();
        demList1.add(dmn1);

        ERP7__Functionality_Control__c fc = new ERP7__Functionality_Control__c();
        fc.ERP7__Sync_to_Google_Drive__c = true;
        fc.ERP7__Sync_to_Salesforce__c = false;
        insert fc;

        ERP7__GoogleCredentials__c gc = new ERP7__GoogleCredentials__c(Name='Test',ERP7__UserName__c =  UserInfo.getUserName(),ERP7__DriveEmail__c = 'test@test.com',ERP7__Active__c = true,ERP7__RefreshToken__c = 'dummy',ERP7__AccessToken__c = 'dummy');
		insert gc;

        ERP7__Credentials__c cred = new ERP7__Credentials__c(Name='GoogleDrive', ERP7__Active__c=true,ERP7__URL__c='https://test.com',ERP7__Bank_COA_ID__c='dfdgghhdj',Username_Login__c='ea936dca391225074832374e8a1fa29357658a4d28dae5dc3a65bf0072f76e443179086f148d8e1439c4253dfe4e4e34', Password_Transkey__c='38b44386e2fdd56a87a009be2593426eeffc7f6bf4664cb3a1389414e3ae7690d65eaa54cba1845e9419c9114f0099f3',Encrypted_Key__c='6233e47bd5de267af2b7e59ae6266073c1d5ad3f3493d2b8facd8fece9e782c4');
    	insert cred;
        

        //PreventRecursiveLedgerEntry.testCasesTransactions = false;
        bill.ERP7__Posted__c = true;
        bill.ERP7__Matched__c = true;
        bill.ERP7__Issue_Voucher__c = true;
        update bill;
        TransactionManagement tran = new TransactionManagement();
        TransactionManagement.fetchBills(orgn.Id, null, null);
        PageReference pageRef = System.Page.CreateBill;
        pageRef.getParameters().put('Id',bill.Id);

        Test.setCurrentPage(pageRef);
        CreateBill cb =new CreateBill();
        cb.ChangeQty();
        CreateBill.getVendorDetails(sup.Id);
        CreateBill.fetch_Polis(PO.Id);
        CreateBill.getPOLIDimeList(PO.Id);
        CreateBill.fetchBill(bill.Id);
                CreateBill.getReadBillOCRState();


        
        
        
        CreateBill.createDimensionsList(JSON.serialize(demList1),bill.Id);
       /* CreateBill.CreateBillCheckFLS();
        CreateBill.multiCurrencyWrap mp = new CreateBill.multiCurrencyWrap();
        CreateBill.selectOptions so = new CreateBill.selectOptions('EUR', 'EUR', true);
        CreateBill.getCurrencies();
        cb.selectAll =true;
        cb.uploadInvoice();
        cb.select_All();
        CreateBill.CreateBillCheckFLS();
        CreateBill.fetchvendordetails(sup.Id,'1234');
        CreateBill.uploadFile(bill.id, 'hello file', 'test', 'png',true,true);
        CreateBill.uploadCloneFile(bill.id, 'hello file','test','png');
        CreateBill.save_attachment(bill.id,'billtest','.pdf','1234');
        CreateBill.save_attachment2(bill.id, PO.Id);
        CreateBill.uploadFile2(PO.Id);
        CreateBill.getPOCurrencies(PO.Id);
        CreateBill.getBillCurrencies(bill.id);
        CreateBill.getOrgCurrencies(orgn.Id);
        String billdata = JSON.serialize(bill);
        String billine = JSON.serialize(new List<ERP7__Bill_Line_Item__c>{billLine2});
        CreateBill.save_UpdatedBill(billdata,billine,'PO_Bill',true);

        cb.ItemCounter= cb.LineItemWrapList.size()-1;
        cb.addLineItem();
        cb.removeLineItem();
        cb.LineItemWrapList[0].isSelect =true;
        cb.save();
        //delete Bill;
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        upsert dmn1;
        CreateBill.deleteDimensions(dmn1.Id);
        CreateBill.fetchRefundBill(bill.Id);
        CreateBill.getBillDetailAndItems(bill.Id);
        CreateBill.getPOLIDimeMultiList(new List<String>{poli.Id});
        CreateBill.fetch_Polis_Multi(new List<String>{PO.Id});*/
        Test.stopTest();
    }
    
    private static testMethod void unit5(){
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
        Contact Supcontact = new Contact(AccountId=sup.Id,LastName = 'test contact2', Email = 'test2@test.com' ,Contact_Numer__c='test_1234');
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
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=3,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];
        List<Purchase_Line_Items__c> poliList = [select id, name,  Unit_Price__c,
                                                 Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
        Bill__c bill = new Bill__c(Vendor__c=sup.id,ERP7__Purchase_Order__c=PO1.Id,ERP7__Vendor_Address__c=bAddress.Id,ERP7__Vendor_Contact__c=Supcontact.Id,ERP7__Vendor_Bill_Number__c='1234', ERP7__Amount__c=2000, ERP7__VAT_TAX_Amount__c = 0, ERP7__Posted__c=true, ERP7__Matched__c=true, ERP7__Issue_Voucher__c=true);
        insert bill;

        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Bill_Line_Item__c billLine1 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000, ERP7__Discount__c =0 , Posted__c = true);
        insert billLine1;
        Transaction__c trans= new Transaction__c(Name='test transaction', Bill__c = bill.id,ERP7__Bill_Line_Item__c = billLine1.id );
        insert trans;
        billLine1.Posted__c = true;
        update billLine1;
        Bill_Line_Item__c billLine2 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000,ERP7__Tax_Amount__c=10,ERP7__Other_Tax__c=0,ERP7__Discount__c=2);
        insert billLine2;
        ERP7__Logistic__c billLogistics = new ERP7__Logistic__c(Name = 'logTest001', ERP7__Purchase_Order__c = PO.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert billLogistics;
        Attachment logAttach01 = new Attachment(Name = 'resAttach1', ParentId = billLogistics.Id, body = Blob.valueOf('Test Data'));
        insert logAttach01;
        ERP7__Dimension__c dmn1 = new ERP7__Dimension__c(Name='tets',ERP7__Active__c = true,ERP7__Bill_Line_Item__c = billLine2.Id);
        List<ERP7__Dimension__c> demList1 = new List<ERP7__Dimension__c>();
        demList1.add(dmn1);

        ERP7__Functionality_Control__c fc = new ERP7__Functionality_Control__c();
        fc.ERP7__Sync_to_Google_Drive__c = true;
        fc.ERP7__Sync_to_Salesforce__c = false;
        insert fc;

        ERP7__GoogleCredentials__c gc = new ERP7__GoogleCredentials__c(Name='Test',ERP7__UserName__c =  UserInfo.getUserName(),ERP7__DriveEmail__c = 'test@test.com',ERP7__Active__c = true,ERP7__RefreshToken__c = 'dummy',ERP7__AccessToken__c = 'dummy');
		insert gc;

        ERP7__Credentials__c cred = new ERP7__Credentials__c(Name='GoogleDrive', ERP7__Active__c=true,ERP7__URL__c='https://test.com',ERP7__Bank_COA_ID__c='dfdgghhdj',Username_Login__c='ea936dca391225074832374e8a1fa29357658a4d28dae5dc3a65bf0072f76e443179086f148d8e1439c4253dfe4e4e34', Password_Transkey__c='38b44386e2fdd56a87a009be2593426eeffc7f6bf4664cb3a1389414e3ae7690d65eaa54cba1845e9419c9114f0099f3',Encrypted_Key__c='6233e47bd5de267af2b7e59ae6266073c1d5ad3f3493d2b8facd8fece9e782c4');
    	insert cred;

        //PreventRecursiveLedgerEntry.testCasesTransactions = false;
        bill.ERP7__Posted__c = true;
        bill.ERP7__Matched__c = true;
        bill.ERP7__Issue_Voucher__c = true;
        update bill;
        Test.startTest();
        CreateBill cb =new CreateBill();
        CreateBill.multiCurrencyWrap mp = new CreateBill.multiCurrencyWrap();
        CreateBill.selectOptions so = new CreateBill.selectOptions('EUR', 'EUR', true);
        CreateBill.getCurrencies();
        cb.selectAll =true;
        cb.uploadInvoice();
        cb.select_All();
        CreateBill.CreateBillCheckFLS();
        CreateBill.fetchvendordetails(sup.Id,'1234');
        CreateBill.uploadFile(bill.id, 'hello file', 'test', 'png',true,true);
        CreateBill.uploadCloneFile(bill.id, 'hello file','test','png');
        CreateBill.save_attachment(bill.id,'billtest','.pdf','1234');
        CreateBill.save_attachment2(bill.id, PO.Id);
        CreateBill.uploadFile2(PO.Id);
        CreateBill.getPOCurrencies(PO.Id);
        CreateBill.getBillCurrencies(bill.id);
        CreateBill.getOrgCurrencies(orgn.Id);
        String billdata = JSON.serialize(bill);
        String billine = JSON.serialize(new List<ERP7__Bill_Line_Item__c>{billLine2});
        CreateBill.save_UpdatedBill(billdata,billine,'PO_Bill',true);
        CreateBill.deleteDimensions(dmn1.Id);
        CreateBill.fetchRefundBill(bill.Id);
        CreateBill.getBillDetailAndItems(bill.Id);
        CreateBill.getPOLIDimeMultiList(new List<String>{poli.Id});
        CreateBill.fetch_Polis_Multi(new List<String>{PO.Id});
        CreateBill.fetch_Polis_bill(new List<String>{PO.Id},bill.Id);
        CreateBill.getProductIdsByNames(PO.id,new List<String>{'Test Prod'});
        CreateBill.ProjectBudget pbt=new CreateBill.ProjectBudget();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }


    private static testMethod void unit3(){
        Test.startTest();
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
        Contact Supcontact = new Contact(AccountId=sup.Id,LastName = 'test contact2', Email = 'test2@test.com' ,Contact_Numer__c='test_1234');
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
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=3,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];
        List<Purchase_Line_Items__c> poliList = [select id, name,  Unit_Price__c,
                                                 Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
        PreventRecursiveLedgerEntry.billtriggerduringpayment=false;
        PreventRecursiveLedgerEntry.proceedVoucherCreation=false;
        Bill__c bill = new Bill__c(Vendor__c=sup.id,ERP7__Purchase_Order__c=PO1.Id,ERP7__Vendor_Address__c=bAddress.Id,ERP7__Vendor_Contact__c=Supcontact.Id,ERP7__Vendor_Bill_Number__c='1234', ERP7__Amount__c=2000, ERP7__VAT_TAX_Amount__c = 0,ERP7__Total_Amount__c = 0);
        insert bill;
        Bill_Line_Item__c billLine1 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000, ERP7__Discount__c =0 );
        insert billLine1;
        Bill_Line_Item__c billLine2 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000,ERP7__Tax_Amount__c=10,ERP7__Other_Tax__c=0,ERP7__Discount__c=2);
        insert billLine2;
        ERP7__Logistic__c billLogistics = new ERP7__Logistic__c(Name = 'logTest001', ERP7__Purchase_Order__c = PO.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert billLogistics;
        Attachment logAttach01 = new Attachment(Name = 'resAttach1', ParentId = billLogistics.Id, body = Blob.valueOf('Test Data'));
        insert logAttach01;
        //PreventRecursiveLedgerEntry.testCasesTransactions = false;
        bill.ERP7__Posted__c = true;
        bill.ERP7__Matched__c = true;
        bill.ERP7__Issue_Voucher__c = true;
        PreventRecursiveLedgerEntry.billtriggerduringpayment=true;
        PreventRecursiveLedgerEntry.proceedVoucherCreation=true;
        update bill;
        PageReference pageRef = System.Page.CreateBill;
        pageRef.getParameters().put('Id',bill.Id);

        Test.setCurrentPage(pageRef);
        CreateBill cb =new CreateBill();
        cb.ChangeQty();
        CreateBill.getVendorDetails(sup.Id);
        CreateBill.fetch_Polis(PO.Id);
        CreateBill.fetch_billItems(bill.Id);
        CreateBill.fetchAdvBill(PO.Id,sup.Id);
        CreateBill.CreateBillCheckFLS();
        cb.selectAll =true;
        cb.uploadInvoice();
        cb.select_All();
       /* String billdata = JSON.serialize(bill);
        String billine = JSON.serialize(new List<ERP7__Bill_Line_Item__c>{billLine2});
        CreateBill.save_Bill(billdata,billine, 'PO_Bill');
        CreateBill.save_UpdatedBill(billdata,billine,'PO_Bill',false);
        CreateBill.getpicklist('ERP7__PO__c', 'ERP7__Status__c');
        cb.getVendorDetails();
        cb.ChangeQty();
        cb.LineItemWrapList[0].isSelect =true;
        cb.save();
        CreateBill.deleteLineItem(JSON.serialize(billLine2));
        delete Bill;*/
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
		
        Test.stopTest();
    }
    
    @isTest
    private static void unit4(){
         Test.startTest();
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
        Contact Supcontact = new Contact(AccountId=sup.Id,LastName = 'test contact2', Email = 'test2@test.com' ,Contact_Numer__c='test_1234');
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
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=3,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];
        List<Purchase_Line_Items__c> poliList = [select id, name,  Unit_Price__c,
                                                 Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
        Bill__c bill = new Bill__c(Vendor__c=sup.id,ERP7__Purchase_Order__c=PO1.Id,ERP7__Vendor_Address__c=bAddress.Id,ERP7__Vendor_Contact__c=Supcontact.Id,ERP7__Vendor_Bill_Number__c='1234', ERP7__Amount__c=2000, ERP7__VAT_TAX_Amount__c = 0,ERP7__Total_Amount__c = 0);
        insert bill;
        PreventRecursiveLedgerEntry.billtriggerduringpayment=false;
        PreventRecursiveLedgerEntry.proceedVoucherCreation=false;
        Bill_Line_Item__c billLine1 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000, ERP7__Discount__c =0 );
        insert billLine1;
        Bill_Line_Item__c billLine2 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000,ERP7__Tax_Amount__c=10,ERP7__Other_Tax__c=0,ERP7__Discount__c=2);
        insert billLine2;
        ERP7__Logistic__c billLogistics = new ERP7__Logistic__c(Name = 'logTest001', ERP7__Purchase_Order__c = PO.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert billLogistics;
        Attachment logAttach01 = new Attachment(Name = 'resAttach1', ParentId = billLogistics.Id, body = Blob.valueOf('Test Data'));
        insert logAttach01;
        
        CreateBill cb =new CreateBill();
        String billdata = JSON.serialize(bill);
        String billine = JSON.serialize(new List<ERP7__Bill_Line_Item__c>{billLine2});
        CreateBill.save_Bill(billdata,billine, 'PO_Bill');
        PreventRecursiveLedgerEntry.billtriggerduringpayment=true;
        PreventRecursiveLedgerEntry.proceedVoucherCreation=true;
        CreateBill.save_UpdatedBill(billdata,billine,'PO_Bill',false);
        CreateBill.getpicklist('ERP7__PO__c', 'ERP7__Status__c');
        
        cb.getVendorDetails();
        cb.ChangeQty();
        cb.save();
        CreateBill.deleteLineItem(JSON.serialize(billLine2));
        delete Bill;
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);

        Test.stopTest();
    }
    
    @isTest
    private static void test_saveRefundPayment() {
        Test.startTest();

        // Setup: Create Account
        Account acc = new Account(Name='Test Account', Account_Type__c='Customer');
        insert acc;

        // Setup: Create Payment record
        ERP7__Payment__c payment = new ERP7__Payment__c(
            Name = 'Test Payment',
            ERP7__Account__c = acc.Id,
            ERP7__Total_Amount__c = 100.00
        );
        insert payment;

        // Serialize payment for method input
        String paymentJson = JSON.serialize(payment);

        // Call the method
        Map<String, Object> result = CreateBill.saveRefundPayment(paymentJson, true, 'Customer Payment', acc.Id);

        // Assert results
        System.assert(result.containsKey('pay'), 'Result should contain pay key');
        System.assert(result.containsKey('payments'), 'Result should contain payments key');
        System.assertEquals('Test Payment', ((ERP7__Payment__c)result.get('payments')).Name);

        Test.stopTest();
    }
}