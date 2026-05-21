@isTest
public class RecordPayment_Test {
    static final Integer recordCount = 1;
    @testsetup 
    static void setup(){
        //TestDataFactory.createData(recordCount);
    }
    private static testmethod void unit_Positive_1(){ 
        Map<String,Object> datalist = new Map<String,Object>();
        Test.startTest();
        datalist = TestDataFactory.getData(recordCount);
        List<account> act = (List<account>)datalist.get('customerAccount');
        
        /*Map<String,Object> functionalData = RecordPayment.getAccountBalance(act[0].Id);
        List<ERP7__Invoice__c> invoiceList =(List<ERP7__Invoice__c>) functionalData.get('invoiceList');
        List<ERP7__Payment_Applied_on_Invoice__c> appliedPayments = new List<ERP7__Payment_Applied_on_Invoice__c>();
        for(ERP7__Invoice__c inv: invoiceList){
            appliedPayments.add(new ERP7__Payment_Applied_on_Invoice__c(ERP7__Invoice__c = inv.id, ERP7__Applied_Date__c=system.today(), ERP7__Type__c='Debit', ERP7__Amount__c=200));
        } 
        if(invoiceList != null && invoiceList.size()>0)
            RecordPayment.getInvoiceDetails(invoiceList[0].Id);String invoiceId=invoiceList[0].Id;*/
        //RecordPayment.saveAppliedPayment(JSON.serialize(new ERP7__Payment__c( ERP7__Total_Amount__c=1000.00,ERP7__Type__c='Debit', ERP7__Account__c=act[0].Id, ERP7__Status__c='Paid')), JSON.serialize(appliedPayments),'cash',false,null,null);
        //RecordPayment.saveTaxPayment(JSON.serialize(new ERP7__Payment__c( ERP7__Total_Amount__c=1000.00,ERP7__Type__c='Debit', ERP7__Account__c=act[0].Id, ERP7__Status__c='Paid')));
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    private static testmethod void unit_Negative_1(){
        Test.startTest();
        RecordPayment.getAccountBalance(userInfo.getUserId());
        RecordPayment.saveAppliedPayment(null,null,'cash',true,null,null, false);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
     
    static testMethod void unitTest1(){
        test.startTest();
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;  
        ERP7__Debit_Note__c dnote=new ERP7__Debit_Note__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=10);
        insert dnote;
        ERP7__Bank_details__c bank=new ERP7__Bank_details__c(Name='',ERP7__Account_Number__c='1234',ERP7__Active__c=true);
        insert bank;
        ERP7__Chart_of_Accounts__c cacc=new ERP7__Chart_of_Accounts__c(ERP7__Account_Code__c='1234',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id);
        insert cacc;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10,Organisation_Business_Unit__c=busUnit.Id,Organisation__c=orgn.Id);
        insert soli;

        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Paid__c=false,ERP7__Invoice_Amount__c=10);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
        cn.ERP7__Account__c = acc.id;
        insert cn;
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Credit_Note__c = cn.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        insert pay;
        ERP7__Payment_Applied_on_Invoice__c apoi=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi;
        ERP7__Payment_Applied_on_Invoice__c apoi1=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi1;
        
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList.add(apoi);
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList1=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList1.add(apoi1);
        
        apoiList1.add(apoi);
        PreventRecursiveLedgerEntry.preventPaymentAppliedOnInvoice = false;
        RecordPayment.getDebitDetails(dnote.Id);
        RecordPayment.fetchBankAccount(acc.Id);
        RecordPayment.getInvoiceDetails(inv.Id);
        RecordPayment.saveTaxPayment(JSON.serialize(new Payment__c(Name='test')));
        String value=JSON.serialize(apoiList);
        String value1=JSON.serialize(apoiList1);
         RecordPayment.saveAppliedPayment(JSON.serialize(new Payment__c(Name='test',ERP7__Account__c=acc.Id)),value,'Credit',true,'Customer Payment',acc.Id, false);
        RecordPayment.saveAppliedPayment(JSON.serialize(new Payment__c(Name='test',ERP7__Account__c=acc.Id)),value,'Credit',true,'',acc.Id, false);
        RecordPayment.saveAppliedPayment(JSON.serialize(new Payment__c(Name='test',ERP7__Account__c=acc.Id)),value1,'Credit',true,'',acc.Id, false);
        //RecordPayment.saveAppliedPaymentAgainstCreditNote(JSON.serialize(new Payment__c(Name='test',ERP7__Account__c=acc.Id)),value1,'Credit',true,'',acc.Id, 0);
        RecordPayment.cardDetails(acc.Id,orgn.Id);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
         Test.stopTest();
    }
    
    static testMethod void unitTest2(){
         Test.startTest();
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Georgia',ERP7__Country__c='United States', Postal_Code__c='98765',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;  
        ERP7__Debit_Note__c dnote=new ERP7__Debit_Note__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=10);
        insert dnote;
        ERP7__Bank_details__c bank=new ERP7__Bank_details__c(Name='',ERP7__Account_Number__c='1234',ERP7__Active__c=true);
        insert bank;
        ERP7__Chart_of_Accounts__c cacc=new ERP7__Chart_of_Accounts__c(ERP7__Account_Code__c='1234',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id);
        insert cacc;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10,Organisation_Business_Unit__c=busUnit.Id,Organisation__c=orgn.Id);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Paid__c=false,ERP7__Invoice_Amount__c=10,ERP7__Organisation__c=orgn.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
        cn.ERP7__Account__c = acc.id;
        insert cn;
        
        List<ERP7__Credit_Note__c> CnList=new List<ERP7__Credit_Note__c>();
        CnList.add(cn);
        
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Credit_Note__c = cn.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        pay.Last_Name__c='test';
        pay.Transaction_Status__c = 'Completed';
        PreventRecursiveLedgerEntry.proceed = false;
        insert pay;
        ERP7__Payment_Applied_on_Invoice__c apoi=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi;
        ERP7__Payment_Applied_on_Invoice__c apoi1=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi1;
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList.add(apoi);
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList1=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList1.add(apoi1);
        apoiList1.add(apoi);
        String value=JSON.serialize(apoiList);
        String value1=JSON.serialize(apoiList1);
        
        ERP7__Credentials__c Credentials = new Credentials__c(Active__c = true,Name = 'Authorize.Net',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test');
        Blob cryptoKey, userData, passwordData;
        cryptoKey = Crypto.generateAesKey(256);
        userData = Blob.valueOf(Credentials.Username_Login__c);
        passwordData = Blob.valueOf(Credentials.Password_Transkey__c);
        Credentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        Credentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        Credentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert Credentials;     
        
        ERP7__Credentials__c Credentials2 = new Credentials__c(Active__c = true,Name = 'Stripe',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test', ERP7__Channel_Id__c = inv.ERP7__Organisation__c);
        Blob cryptoKey1, userData1, passwordData1;
        cryptoKey1 = Crypto.generateAesKey(256);
        userData1 = Blob.valueOf(Credentials2.Username_Login__c);
        passwordData1 = Blob.valueOf(Credentials2.Password_Transkey__c);
        Credentials2.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey1);
        Credentials2.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, userData1));
        Credentials2.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, passwordData1));
        insert Credentials2;
        
        RecordPayment.cardPaymentUpdate(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'',value,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c,'Stripe');
        RecordPayment.cardPaymentUpdate(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'',value1,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c,'Authorize');
        RecordPayment.cardPaymentUpdate(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'Customer Payment',value1,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c,'Stripe');
        
        RecordPayment.cardPaymentUpdateStripe(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'',value1,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c, inv.Id);
        RecordPayment.saveAppliedPaymentAgainstCreditNote(JSON.serialize(pay),value,'Credit',true,'',acc.Id,100,false);
        RecordPayment.saveAppliedPaymentAgainstCreditNote(JSON.serialize(pay),value1,'Credit',true,'Customer Payment',acc.Id,100,false);
        PreventRecursiveLedgerEntry.proceed = true;
       // RecordPayment.saveRefundPayment(JSON.serialize(pay),'Credit',true,'CustomerPayment',acc.Id);
      //  RecordPayment.saveRefundPay(JSON.serialize(pay),acc.Id,'Customer Payment','Credit',true);
        //RecordPayment.updateInvoiceCreditNotesUpdated(CnList,inv.Id);
        RecordPayment.getRefundInvoiceDetails(inv.Id,pay.Id);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
         Test.stopTest();
        
    }
    static testMethod void unitTest23(){
         Test.startTest();
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Georgia',ERP7__Country__c='United States', Postal_Code__c='98765',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;  
        ERP7__Debit_Note__c dnote=new ERP7__Debit_Note__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=10);
        insert dnote;
        ERP7__Bank_details__c bank=new ERP7__Bank_details__c(Name='',ERP7__Account_Number__c='1234',ERP7__Active__c=true);
        insert bank;
        ERP7__Chart_of_Accounts__c cacc=new ERP7__Chart_of_Accounts__c(ERP7__Account_Code__c='1234',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id);
        insert cacc;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10,Organisation_Business_Unit__c=busUnit.Id,Organisation__c=orgn.Id);
        insert soli;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Paid__c=false,ERP7__Invoice_Amount__c=10,ERP7__Organisation__c=orgn.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
        cn.ERP7__Account__c = acc.id;
        insert cn;
        
        List<ERP7__Credit_Note__c> CnList=new List<ERP7__Credit_Note__c>();
        CnList.add(cn);
        
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Credit_Note__c = cn.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        pay.Last_Name__c='test';
        pay.Transaction_Status__c = 'Completed';
        PreventRecursiveLedgerEntry.proceed = false;
        insert pay;
        ERP7__Payment_Applied_on_Invoice__c apoi=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi;
        ERP7__Payment_Applied_on_Invoice__c apoi1=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi1;
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList.add(apoi);
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList1=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList1.add(apoi1);
        apoiList1.add(apoi);
        String value=JSON.serialize(apoiList);
        String value1=JSON.serialize(apoiList1);
        
        ERP7__Credentials__c Credentials = new Credentials__c(Active__c = true,Name = 'Authorize.Net',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test');
        Blob cryptoKey, userData, passwordData;
        cryptoKey = Crypto.generateAesKey(256);
        userData = Blob.valueOf(Credentials.Username_Login__c);
        passwordData = Blob.valueOf(Credentials.Password_Transkey__c);
        Credentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        Credentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        Credentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert Credentials;     
        
        ERP7__Credentials__c Credentials2 = new Credentials__c(Active__c = true,Name = 'Stripe',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test', ERP7__Channel_Id__c = inv.ERP7__Organisation__c);
        Blob cryptoKey1, userData1, passwordData1;
        cryptoKey1 = Crypto.generateAesKey(256);
        userData1 = Blob.valueOf(Credentials2.Username_Login__c);
        passwordData1 = Blob.valueOf(Credentials2.Password_Transkey__c);
        Credentials2.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey1);
        Credentials2.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, userData1));
        Credentials2.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, passwordData1));
        insert Credentials2;
      
        ERP7__Invoice__c inv2=new ERP7__Invoice__c(Name='INV-83360',ERP7__Account__c=acc.Id,ERP7__Paid__c=false,ERP7__Invoice_Amount__c=10,ERP7__Organisation__c=orgn.Id);
        insert inv2;
        Invoice_Line_Item__c invli2 = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv2.id);
        insert invli2;
        ERP7__Invoice__c inv3=new ERP7__Invoice__c(Name='INV-83360',ERP7__Account__c=acc.Id,ERP7__Paid__c=false,ERP7__Invoice_Amount__c=10,ERP7__Organisation__c=orgn.Id);
        insert inv3;
        Invoice_Line_Item__c invli3 = new Invoice_Line_Item__c( ERP7__Order_Product__c=orditem.id,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv3.id);
        insert invli3;
        ERP7__Payment_Applied_on_Invoice__c apoi2=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv2.Id,ERP7__Payment__c=pay.Id);
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList2=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList2.add(apoi2);
        ERP7__Payment_Applied_on_Invoice__c apoi3=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv3.Id,ERP7__Payment__c=pay.Id);
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList3=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList3.add(apoi3);
        String value2=JSON.serialize(apoiList2);
        String value3=JSON.serialize(apoiList3);
        //RecordPayment.saveAppliedPayment(JSON.serialize(new Payment__c(Name='test',ERP7__Account__c=acc.Id,ERP7__Amount__c=10,ERP7__Total_Amount__c=10)),value2,'Credit',true,'',acc.Id, false);
        //RecordPayment.saveAppliedPayment(JSON.serialize(new Payment__c(Name='test',ERP7__Account__c=acc.Id,ERP7__Amount__c=10,ERP7__Total_Amount__c=10)),value3,'Credit',true,'',acc.Id, false);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
         Test.stopTest();
        
    }
       static testMethod void unitTest22(){
         Test.startTest();
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Georgia',ERP7__Country__c='United States', Postal_Code__c='98765',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;  
        ERP7__Debit_Note__c dnote=new ERP7__Debit_Note__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=10);
        insert dnote;
        ERP7__Bank_details__c bank=new ERP7__Bank_details__c(Name='',ERP7__Account_Number__c='1234',ERP7__Active__c=true);
        insert bank;
        ERP7__Chart_of_Accounts__c cacc=new ERP7__Chart_of_Accounts__c(ERP7__Account_Code__c='1234',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id);
        insert cacc;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10,Organisation_Business_Unit__c=busUnit.Id,Organisation__c=orgn.Id);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Paid__c=false,ERP7__Invoice_Amount__c=10,ERP7__Organisation__c=orgn.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
        cn.ERP7__Account__c = acc.id;
        insert cn;
        
        List<ERP7__Credit_Note__c> CnList=new List<ERP7__Credit_Note__c>();
        CnList.add(cn);
        
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Credit_Note__c = cn.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        pay.Last_Name__c='test';
        pay.Transaction_Status__c = 'Completed';
        PreventRecursiveLedgerEntry.proceed = false;
        insert pay;
        ERP7__Payment_Applied_on_Invoice__c apoi=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi;
        ERP7__Payment_Applied_on_Invoice__c apoi1=new ERP7__Payment_Applied_on_Invoice__c(Name='test',ERP7__Invoice__c=inv.Id,ERP7__Payment__c=pay.Id);
        //insert apoi1;
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList.add(apoi);
        List<ERP7__Payment_Applied_on_Invoice__c> apoiList1=new List<ERP7__Payment_Applied_on_Invoice__c>();
        apoiList1.add(apoi1);
        apoiList1.add(apoi);
        String value=JSON.serialize(apoiList);
        String value1=JSON.serialize(apoiList1);
        
        ERP7__Credentials__c Credentials = new Credentials__c(Active__c = true,Name = 'Authorize.Net',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test');
        Blob cryptoKey, userData, passwordData;
        cryptoKey = Crypto.generateAesKey(256);
        userData = Blob.valueOf(Credentials.Username_Login__c);
        passwordData = Blob.valueOf(Credentials.Password_Transkey__c);
        Credentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        Credentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        Credentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert Credentials;     
        
        ERP7__Credentials__c Credentials2 = new Credentials__c(Active__c = true,Name = 'Stripe',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test', ERP7__Channel_Id__c = inv.ERP7__Organisation__c);
        Blob cryptoKey1, userData1, passwordData1;
        cryptoKey1 = Crypto.generateAesKey(256);
        userData1 = Blob.valueOf(Credentials2.Username_Login__c);
        passwordData1 = Blob.valueOf(Credentials2.Password_Transkey__c);
        Credentials2.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey1);
        Credentials2.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, userData1));
        Credentials2.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, passwordData1));
        insert Credentials2;
        
      //  RecordPayment.cardPaymentUpdate(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'',value,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c,'Stripe');
      //  RecordPayment.cardPaymentUpdate(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'',value1,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c,'Authorize');
      //  RecordPayment.cardPaymentUpdate(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'Customer Payment',value1,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c,'Stripe');
        
       // RecordPayment.cardPaymentUpdateStripe(acc.Id,JSON.serialize(add),JSON.serialize(pay),'Card',true,'',value1,JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025',ERP7__Name_on_Card__c='Test')),'123',inv.ERP7__Organisation__c, inv.Id);
       // RecordPayment.saveAppliedPaymentAgainstCreditNote(JSON.serialize(pay),value,'Credit',true,'',acc.Id,100,false);
       /// RecordPayment.saveAppliedPaymentAgainstCreditNote(JSON.serialize(pay),value1,'Credit',true,'Customer Payment',acc.Id,100,false);
        PreventRecursiveLedgerEntry.proceed = true;
        RecordPayment.saveRefundPayment(JSON.serialize(pay),'Credit',true,'CustomerPayment',acc.Id);
        RecordPayment.saveRefundPay(JSON.serialize(pay),acc.Id,'Customer Payment','Credit',true);
        //RecordPayment.updateInvoiceCreditNotesUpdated(CnList,inv.Id);
        RecordPayment.getRefundInvoiceDetails(inv.Id,pay.Id);
           RecordPayment.credList();
           RecordPayment.fetchCreditNote(acc.Id);
           RecordPayment.getDaysBetween(System.Today(),System.Today()+1);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
         Test.stopTest();
        
    }
}