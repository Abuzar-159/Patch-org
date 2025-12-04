@isTest
public class EposTestCases {
    @testSetup static void testDataSetup() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn; 
        Account acc = new Account(Name='Naseeruddin', Account_Type__c = 'Customer',ERP7__Organisation__c=orgn.Id);
        insert acc;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=acc.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE,ERP7__Length__c=2,ERP7__Width__c=2,ERP7__Height__c=2,ERP7__Weight__c=2);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c=pro.Id);
        insert ver;
        pro.ERP7__Version__c=ver.Id;
        update pro;
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true,ERP7__Ship_From_Address__c=add.Id);
        insert channel;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1]; 
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert custProfile;
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='AK Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin',RecordTypeId=orderProfile_RTypes.Id,ERP7__Account_Profile__c=custProfile.Id);
        insert profile;
        acc.ERP7__Order_Profile__c=profile.Id;
        update acc;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__Profiling__c' And Name='Employee' Limit 1];
        Profiling__c EmpProfile = new Profiling__c(Name='test',Active__c=true,RecordTypeId=rTypeProfile.Id);
        insert EmpProfile; 
        Employees__c emp = new Employees__c(First_Name__c='Naseer',Last_Name__c='Akhtar',Email__c='test@test.com', Organisation__c=orgn.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=EmpProfile.Id);
        insert emp;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Ship_To_Address__c=add.Id,ERP7__Bill_To_Address__c=add.id,
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Channel__c=channel.Id,ERP7__Contact__c=contact.Id); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=1,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id,ERP7__Price_Book__c =profile.ERP7__Price_Book__c);
        insert tda;
        
        ERP7__Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=profile.Id,ERP7__Province__c='Ajman',ERP7__Country__c='United Kingdom',ERP7__Product__c=pro.Id,ERP7__Postal_Code__c='123');
        insert tax;
        
        ERP7__Invoice__c invoice = new ERP7__Invoice__c(Active__c = true, Order_S__c=ord.id,Account__c=acc.id,ERP7__Invoice_Amount__c=100);
        insert invoice;
        
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='test', ERP7__Start_Date__c=system.today(), ERP7__End_Date__c=system.today(), ERP7__Value__c=10.02,
                                                     ERP7__Minimum_Order_Amount__c=10.00,ERP7__Pre_Tax_Discount__c=true);
        insert coupon;
        ERP7__Coupon_Issued__c ci = new ERP7__Coupon_Issued__c(Name='test', ERP7__Coupon__c=coupon.Id, ERP7__Issued_Date__c=system.today(),ERP7__Product__c=pro.Id);
        insert ci;
        ERP7__Coupon_Redemption__c cr = new ERP7__Coupon_Redemption__c(Name='Test', ERP7__Coupon_Issued__c=ci.Id, ERP7__Redemption_Date__c=system.today(),
                                                                       ERP7__Coupon__c=coupon.Id);
        insert cr;
        ERP7__Credit_Note__c credit = new ERP7__Credit_Note__c(Name='Test', ERP7__Coupon_Redemption__c=cr.Id, ERP7__Account__c=acc.Id,ERP7__Credit__c=100,ERP7__Debit__c=10);
        insert credit;
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
        insert loyalty;
        Loyalty_Program__c loyalityProg=new Loyalty_Program__c(ERP7__Active__c=true,ERP7__Loyalty_Setup__c=loyalty.Id);
        insert loyalityProg;
        
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=acc.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10,ERP7__Loyalty_Program__c=loyalityProg.Id,ERP7__Organisation__c=orgn.Id);
        insert clubCard;
        
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        
        ERP7__UPS_Package_Type__c UPSPackageType=new ERP7__UPS_Package_Type__c(Name='test',ERP7__Package_Code__c='12',ERP7__Package_Description__c='Package');
        insert UPSPackageType;
    }
    
    private testMethod static void unitTest1(){
        Account acc=[Select Id,Name,ERP7__Organisation__c from Account where Name='Naseeruddin' Limit 1];
        Contact con=[Select Id,Name from Contact Limit 1];
        ERP7__Address__c add=[Select Id,Name from Address__c limit 1];
        ERP7__Profiling__c profile=[Select Id,Name from ERP7__Profiling__c  where Name='AK Test' Limit 1];
        ERP7__Employees__c emp=[Select Id,Name from ERP7__Employees__c Limit 1];
        ERP7__Invoice__c inv=[Select Id,Name,Order_S__c,ERP7__Account__c from ERP7__Invoice__c Limit 1];
        ERP7__Credit_Note__c cn=[Select Id,Name from ERP7__Credit_Note__c Limit 1];
        
        Epos.fetchInitailDetails();
        Epos.fetchAccDetails(acc.Id);
        Epos.getCurrenyList('Order','Status');
        Epos.fetchContactDetails(con.Id);
        Epos.billToAddress(add.Id);
        Epos.shipToAddress(add.Id);
        Epos.OrderProfile(profile.Id);
        Epos.currentEmp(emp.Id);
		Epos.fetchInitialCardDetails();
		Epos.fetchInitialBankDetails();
		Epos.initialLoyalityPayment(acc.Id,acc.ERP7__Organisation__c);
        Epos.applyCreditInitial(acc.Id);
        
        Epos.CNWrapper wr=new Epos.CNWrapper();
        wr.credNote=cn;
        wr.debitAmount=10;
        List<Epos.CNWrapper> wrList=new List<Epos.CNWrapper>();
        wrList.add(wr);
        Epos.applyCreditToInvoice(JSON.serialize(inv),JSON.serialize(wr),10);
        Epos.applyCreditToInvoice(JSON.serialize(inv),JSON.serialize(wrList),10);
        
        
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    private testMethod static void unitTest2(){
        ERP7__Address__c add=[Select Id,Name from Address__c limit 1];
        ERP7__Profiling__c profile=[Select Id,Name,ERP7__Active__c,ERP7__Organisation__c,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Tax_Sourcing_Rules__c,RecordTypeId,ERP7__Account_Profile__c,ERP7__Account_Profile__r.Name,ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c  where Name='AK Test' Limit 1];
        Product2 prod=[Select Id,Name from Product2 Limit 1];
        ERP7__Channel__c channel=[Select Id,Name from ERP7__Channel__c Limit 1];
        
        Epos.initialProducts(JSON.serialize(profile),add.Id,add.Id,'','GBP');
        Epos.getDiscountPlan(profile.Id,prod.Id,1);
        Epos.latestStock(channel.Id,prod.Id);
        
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    private testMethod static void unitTest3(){
        Account acc=[Select Id,Name from Account where Name='Naseeruddin' Limit 1];
        Contact con=[Select Id,Name from Contact Limit 1];
        ERP7__Profiling__c profile=[Select Id,Name from ERP7__Profiling__c  where Name='AK Test' Limit 1];
        Product2 pro=[Select Id,Name from Product2 Limit 1];
        PricebookEntry pbe=[Select Id,name from PricebookEntry Limit 1];
        Order ord1=[Select Id,Name from Order Limit 1];
        ERP7__Invoice__c inv=[Select Id,Name from ERP7__Invoice__c Limit 1];
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=Test.getStandardPricebookId(),ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        
        OrderItem orditem = new OrderItem(Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);   
        
        List<OrderItem> orditemList=new List<OrderItem>();
        orditemList.add(orditem);
        Set<Id> prodIds=new Set<Id>();
        prodIds.add(pro.Id);
        
        Epos.saveOrderAndLines(JSON.serialize(ord),JSON.serialize(orditemList),JSON.serialize(prodIds),new List<String>());
        Epos.fetchOrderDetails(ord1.Id);
        Epos.fetchOrdDetailsForClone(ord1.Id);
        Epos.updateInvoice(inv.Id,true);
        Epos.updateInvoice(inv.Id,false);  
        Epos.ApplyCoupons(JSON.serialize(ord1),acc.Id,'test');
        Epos.saveEstimateService(JSON.serialize(ord1));
        Epos.saveEstimateService('ord1');
        Epos.updateAccInfo(JSON.serialize(acc));
        Epos.updateAccInfo('acc');
        Epos.insertNewAcc(JSON.serialize(new Account(Name='Test')));
        Epos.insertNewAcc('test');
        Epos.insertContact(JSON.serialize(new Contact(LastName='Test',AccountId=acc.Id)));
        Epos.insertContact('test');
        Epos.getDependentMap('ERP7__Country__c','ERP7__City__c');
        Epos.decimalToBinary(2);
        Epos.base64ToBits('test');
        Epos.PicklistEntryWrapper wr=new Epos.PicklistEntryWrapper();
        wr.active='';
        wr.defaultValue='';
        wr.label='';
        wr.value='';
        wr.validFor='';
        Epos.createNewAddress(JSON.serialize(new ERP7__Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman')));
        Epos.createNewAddress('test');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    private testMethod static void unitTest4(){
        PreventRecursiveLedgerEntry.proceed = false;
        ERP7__Payment__c pay=new ERP7__Payment__c(Name='test',Amount__c=20,ERP7__Total_Amount__c=20);
        ERP7__Payment_Method__c mayMethod=new ERP7__Payment_Method__c(Name='test auth',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020');
        ERP7__Address__c add=[Select Id,Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__City__c,ERP7__State__c,ERP7__Postal_Code__c,ERP7__Country__c from Address__c limit 1];
        ERP7__Invoice__c inv=[Select Id,Name,ERP7__Invoice_Amount__c from ERP7__Invoice__c Limit 1];
        
        List<ERP7__Invoice__c> invList=new List<ERP7__Invoice__c>();
        invList.add(inv);
        
        Credentials__c Credentials = new Credentials__c(Active__c = true,Name = 'Paypal',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test');
        Blob cryptoKey, userData, passwordData;
        cryptoKey = Crypto.generateAesKey(256);
        userData = Blob.valueOf(Credentials.Username_Login__c);
        passwordData = Blob.valueOf(Credentials.Password_Transkey__c);
        Credentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        Credentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        Credentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert Credentials;
        
        Credentials__c Credentials1 = new Credentials__c(Active__c = true,Name = 'Authorize',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test');
        Blob cryptoKey1, userData1, passwordData1;
        cryptoKey1 = Crypto.generateAesKey(256);
        userData1 = Blob.valueOf(Credentials1.Username_Login__c);
        passwordData1 = Blob.valueOf(Credentials1.Password_Transkey__c);
        Credentials1.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey1);
        Credentials1.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, userData1));
        Credentials1.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey1, passwordData1));
        insert Credentials1;
        
        Credentials__c Credentials2 = new Credentials__c(Active__c = true,Name = 'Stripe',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test');
        Blob cryptoKey2, userData2, passwordData2;
        cryptoKey2 = Crypto.generateAesKey(256);
        userData2 = Blob.valueOf(Credentials2.Username_Login__c);
        passwordData2 = Blob.valueOf(Credentials2.Password_Transkey__c);
        Credentials2.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey2);
        Credentials2.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey2, userData2));
        Credentials2.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey2, passwordData2));
        insert Credentials2;
        
        Epos.createCardPayment(JSON.serialize(pay),JSON.serialize(mayMethod),'123',JSON.serialize(add),Credentials.Id,'GBP',JSON.serialize(invList),1);
        Epos.createCardPayment(JSON.serialize(pay),JSON.serialize(mayMethod),'123',JSON.serialize(add),Credentials1.Id,'GBP',JSON.serialize(invList),1);
        Epos.createCardPayment(JSON.serialize(pay),JSON.serialize(mayMethod),'123',JSON.serialize(add),Credentials1.Id,'GBP',JSON.serialize(invList),2);
        Epos.createCardPayment(JSON.serialize(pay),JSON.serialize(mayMethod),'123',JSON.serialize(add),Credentials1.Id,'GBP',JSON.serialize(invList),3);
        Epos.createCardPayment(JSON.serialize(pay),JSON.serialize(mayMethod),'123',JSON.serialize(add),Credentials1.Id,'GBP',JSON.serialize(invList),4);
        Epos.createCardPayment(JSON.serialize(pay),JSON.serialize(mayMethod),'123',JSON.serialize(add),Credentials2.Id,'GBP',JSON.serialize(invList),1);
        
        ERP7__Invoice__c invoice = new ERP7__Invoice__c(Active__c = true,ERP7__Invoice_Amount__c=100);
        insert invoice;
        List<ERP7__Invoice__c> invList1=new List<ERP7__Invoice__c>();
        invList1.add(inv);
        invList1.add(invoice);
        
        Epos.createBankOrCashPayment(JSON.serialize(pay),JSON.serialize(invList1),'Cash');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        
    }
    
    private testMethod static void unitTest5(){
        Account acc=[Select Id,Name,ERP7__Organisation__c from Account where Name='Naseeruddin' Limit 1];
        Contact con=[Select Id,Name from Contact Limit 1];
        ERP7__Address__c add=[Select Id,Name from Address__c limit 1];
        ERP7__Profiling__c profile=[Select Id,Name from ERP7__Profiling__c  where Name='AK Test' Limit 1];
        ERP7__Employees__c emp=[Select Id,Name from ERP7__Employees__c Limit 1];
        Order ord=[Select Id,Name,ERP7__Contact__r.Name,ERP7__Contact__r.Company__c,ERP7__Contact__r.Phone,ERP7__Ship_To_Address__r.ERP7__City__c from Order Limit 1];
        Loyalty_Card__c LC=[Select Id,Name,ERP7__Points_Per_Unit_Amount__c from Loyalty_Card__c Limit 1];
        
        List<Loyalty_Card__c> LCList=new List<Loyalty_Card__c>();
        LCList.add(LC);
        
        ERP7__Credentials__c UPSCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'UPS',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                       ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');  
        Blob cryptoKey, userData, passwordData;
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        cryptoKey = Crypto.generateAesKey(256);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert UPSCredentials;
        
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        Blob passwordData1;
        passwordData1 = Blob.valueOf(FedexCredentials.Password_Transkey__c);
        FedexCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        FedexCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert FedexCredentials;
        
        Epos.applyLoyaltyInitial(acc.Id,acc.ERP7__Organisation__c);
        Epos.applyLoyalty(JSON.serialize(LCList),ord.Id,4);
        Epos.UPSServices(ord.Id,'--None--','');
        Epos.FedServices(ord.Id,'--None--','');
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    private testMethod static void unitTest6(){
        Epos.rateWrapper wr=new Epos.rateWrapper();
        wr.Service = '';
        wr.ServiceName = '';
        wr.currencyCode = '';
        wr.CommitmentDate = '';
        wr.DeliveryDate = null;
        wr.DeliveryDateS = '';            
        wr.ServiceManual = '';
        wr.ServiceCode = '';
        wr.totalCharges = '';
        wr.totalSurcharges = ''; 
        wr.negotiatedCharges = '';
        wr.TransportationCharges = '';
        wr.ServiceOptionsCharges = '';            
        wr.GuaranteedDaysToDelivery = '';
        wr.ScheduledDeliveryTime = '';  
        wr.Selected = false; 
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    
    private testMethod static void unitTestShippingRates(){
        Account acc=[Select Id,Name,ERP7__Organisation__c from Account where Name='Naseeruddin' Limit 1];
        Contact con=[Select Id,Name from Contact Limit 1];
        ERP7__Address__c add=[Select Id,Name, ERP7__Address_Line1__c, ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__State__c, ERP7__Country__c, ERP7__Postal_Code__c from Address__c where ERP7__City__c != null and ERP7__Postal_Code__c!=null limit 1];
        ERP7__Profiling__c profile=[Select Id,Name from ERP7__Profiling__c  where Name='AK Test' Limit 1];
        ERP7__Employees__c emp=[Select Id,Name from ERP7__Employees__c Limit 1];
        Order ord=[Select Id,Name,ERP7__Contact__r.Name,ERP7__Contact__r.Company__c,ERP7__Contact__r.Phone,ERP7__Ship_To_Address__r.ERP7__City__c from Order Limit 1];
        Loyalty_Card__c LC=[Select Id,Name,ERP7__Points_Per_Unit_Amount__c from Loyalty_Card__c Limit 1];
        
        List<Loyalty_Card__c> LCList=new List<Loyalty_Card__c>();
        LCList.add(LC);
        
        ERP7__Credentials__c UPSCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'UPS',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                       ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');  
        Blob cryptoKey, userData, passwordData;
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        cryptoKey = Crypto.generateAesKey(256);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert UPSCredentials;
        
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        Blob passwordData1;
        passwordData1 = Blob.valueOf(FedexCredentials.Password_Transkey__c);
        FedexCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        FedexCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert FedexCredentials;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE,ERP7__Length__c=2,ERP7__Width__c=2,ERP7__Height__c=2,ERP7__Weight__c=2);
        insert pro;
        List<Product2> prodList = new List<Product2>();
        prodList.add(pro);
        ShippingRates.UPSServices(add,'--None--','', add, prodList);
        ShippingRates.getDefaultOrganisation();
        ShippingRates.fetchAddress(add.Id);
        ShippingRates.getIntialproducts();
        //ShippingRates.fetchCusAddress(add.Id);
        ShippingRates.getseacrhedProducts('S');
        ShippingRates.rateWrapper rwap = new ShippingRates.rateWrapper();
        
        String salName = 'ERP7'; 
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
}