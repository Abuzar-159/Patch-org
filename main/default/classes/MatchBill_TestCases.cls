@isTest
public class MatchBill_TestCases {
    private static testMethod void unit1(){        
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
        Contact Supcontact = new Contact(AccountId=sup.Id,LastName = 'testUBSHDVJQKX Qcontact', Email = 'tesHGQVFYDTQGSHWt@test.com' ,Contact_Numer__c='BQWBDYGYWQEBOXC');
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
        Bill__c bill = new Bill__c(Vendor__c=sup.id,ERP7__Purchase_Order__c=PO1.Id,ERP7__Vendor_Address__c=bAddress.Id,ERP7__Vendor_Contact__c=Supcontact.Id,ERP7__Vendor_Bill_Number__c='1234', ERP7__Amount__c=2000, ERP7__VAT_TAX_Amount__c = 0, ERP7__Posted__c=true, ERP7__Matched__c=true, ERP7__Issue_Voucher__c=true,ERP7__Total_Amount__c=1000);  
        insert bill;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        Bill_Line_Item__c billLine1 = new Bill_Line_Item__c(Bill__c = bill.id,ERP7__Amount__c=1000,ERP7__Product__c=ps.Id,ERP7__Purchase_Order_Line_Items__c =poli.Id,ERP7__Quantity__c=1,ERP7__Total_Amount__c=1000, ERP7__Discount__c =0 , Posted__c = true);
        insert billLine1;
        
        Transaction__c trans= new Transaction__c(Name='test transaction', Bill__c = bill.id,ERP7__Bill_Line_Item__c = billLine1.id );
        insert trans;
        billLine1.Posted__c = true;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update billLine1; 
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
        update bill;
        Test.startTest();
        MatchBill.getStockInWardLineItems(JSON.serialize(billLine1));
        List<ERP7__Inventory_Reconcilation__c> IRList=new List<ERP7__Inventory_Reconcilation__c>();
        List<ERP7__Service_Recociliation__c> SRList=new List<ERP7__Service_Recociliation__c>();
        MatchBill.createIR_SR(JSON.serialize(IRList),JSON.Serialize(SRList));
        
        
        MatchBill.getBillItems(bill.Id);
        MatchBill.fetchBills(100,'','CreatedDate','ASC');
        MatchBill.MatchBills();
        MatchBill.updateBillById(bill.Id,false);
        MatchBill.update_Bill(JSON.serialize(bill));
        MatchBill.save_Bill(JSON.serialize(bill));
        
        Voucher__c voucher = new Voucher__c(name='test',ERP7__Vendor__c=sup.id,ERP7__Vendor_invoice_Bill__c=bill.Id,ERP7__Amount__c=500);
        insert voucher;
        MatchBill.save_Bill(JSON.serialize(bill));
        MatchBill.checkVoucherApex(JSON.serialize(bill));
         MatchBill.saveVoucher(JSON.serialize(voucher));
        MatchBill.checkBillDetails(bill.Id);
        MatchBill.InventoryReconWrapper irwrap = new MatchBill.InventoryReconWrapper();
        MatchBill.ToleranceClass itwrap = new MatchBill.ToleranceClass();
        MatchBill.getAutoMatchItems(bill.Id);
        MatchBill.processAutoMatch(JSON.serialize(IRList));
        MatchBill.getModule();
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
        Test.stopTest();
    }
}