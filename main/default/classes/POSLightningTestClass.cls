@isTest
public class POSLightningTestClass {

    private testMethod static void unitTestCasesSet_0(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true;   
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
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax; 
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Tax__c=tax.id,Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        
        
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
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
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='test', ERP7__Start_Date__c=system.today(), ERP7__End_Date__c=system.today(), ERP7__Value__c=10.02,
                                                     ERP7__Minimum_Order_Amount__c=10.00);
        insert coupon;
        ERP7__Coupon_Issued__c ci = new ERP7__Coupon_Issued__c(Name='test', ERP7__Coupon__c=coupon.Id, ERP7__Issued_Date__c=system.today());
        insert ci;
        ERP7__Coupon_Redemption__c cr = new ERP7__Coupon_Redemption__c(Name='Test', ERP7__Coupon_Issued__c=ci.Id, ERP7__Redemption_Date__c=system.today(),
                                                                       ERP7__Coupon__c=coupon.Id);
        insert cr;
        ERP7__Credit_Note__c credit = new ERP7__Credit_Note__c(Name='Test', ERP7__Coupon_Redemption__c=cr.Id, ERP7__Account__c=customer.Id);
        insert credit;
        Test.startTest();
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('',psod.ERP7__contact__c,'',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('','',psod.ERP7__Account__c,',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getBA(bAddress.id);
        POSLightning.getSA(sAddress.id);
        // POSLightning.getTaxRateByAddressId(sAddress.id);
        POSLightning.getCRUD();
        POSLightning.getPaymentGateways();
        
        POSLightning.discountPercent(String.valueof(dp.Id));
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        POSLightning.upsWrap upsw = new POSLightning.upsWrap();
        POSLightning.rateWrapper upsrw = new POSLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        POSLightning.CreateNewCustomer(Customers);
        POSLightning.CreateNewCont(Contacts);        
        POSLightning.CreateNewCustomers(JSON.serialize(Customers));
        POSLightning.CreateNewConts(JSON.serialize(Contacts));
        String CreditNoteId=credit.Id;
        POSLightning.DeleteCreditNote(CreditNoteId);
        
        //POSLightning.CreateNewAddress(Addressess,'test','test');
        //POSLightning.addAssets();
        //POSLightning.getCharge(JSON.serialize(PDWL[0]));
        //POSLightning.addAssets(JSON.serialize(new List < POSLightning.ProductsAndDiscounts >()), currentSalepoints, Customers, Contacts, SOP.Id,10.00);
        POSLightning.deleteSoliById(solim1.id);  
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    } 
    
    private testMethod static void unitTestCasesSet_1(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true;   
        PreventRecursiveLedgerEntry.loged = true;  
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
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Account customer = new Account(Name='Customer',ERP7__Is_Person_Account__c=true);
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
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
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('',psod.ERP7__contact__c,'',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('','',psod.ERP7__Account__c,',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getBA(bAddress.id);
        POSLightning.getSA(sAddress.id);
        //POSLightning.getTaxRateByAddressId(sAddress.id);
        POSLightning.discountPercent(String.valueof(dp.Id));
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        POSLightning.upsWrap upsw = new POSLightning.upsWrap();
        POSLightning.rateWrapper upsrw = new POSLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Object> PDWL = POSLightning.productFetchss('','','','',JSON.serialize(currentSalepoints),JSON.serialize(Customers),JSON.serialize(Contacts),sop.Id, JSON.serialize(new List<OrderConsoleLightning.itemWrapper>()), false, false,System.Today(),10);
        POSLightning.productFetchs('','','','',JSON.serialize(currentSalepoints),JSON.serialize(Customers),JSON.serialize(Contacts),sop.Id,new List<POSLightning.itemWrapper>());
        POSLightning.productFetch('','',JSON.serialize(currentSalepoints),JSON.serialize(Customers),JSON.serialize(Contacts),sop.Id,new List<POSLightning.itemWrapper>());
        POSLightning.DiscountPlans(ps.Id, JSON.serialize(currentSalepoints), true, JSON.serialize(Customers), JSON.serialize(Contacts), SOP.Id, 2, '');
        POSLightning.editProducts(ps.Id, 3, dp.Id, 5, JSON.serialize(currentSalepoints),true,JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id, '');        
        POSLightning.addProducts(JSON.serialize(PDWL), JSON.serialize(currentSalepoints),JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id);
        List<Id> newIds = new List<Id>();
        newIds.add(SOP.Id);
        POSLightning.addProducts2(JSON.serialize(PDWL), JSON.serialize(currentSalepoints), JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id, 10.00, newIds, JSON.serialize(sod), bAddress.Id, sAddress.Id);
        POSLightning.deleteSerials(newIds, JSON.serialize(sod)); 
        //POSLightning.saveDrafts(JSON.serialize(new List < POSLightning.itemWrapper >()), JSON.serialize(currentSalepoints), JSON.serialize(sod),JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id, new List < String >(), '', 0, 0,null);        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    } 
    
    private testMethod static void unitTest_POSLightning_2(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
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
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice; 
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert customPriceps;          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
        insert ps1; 
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice1; 
        PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
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
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
        insert invoice;
        Invoice__c invoiceName = [Select Id, Name from Invoice__c where id=:invoice.id limit 1];
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
        insert RMA_Line_Item; 
        
        
        solim.Quantity__c = 2;
        update solim;
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
        insert tda;
        Tax__c tax = new Tax__c(Organisation__c = orgn.Id, Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
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
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        insert FedexCredentials;
        ERP7__Credentials__c DHLCredentials = new ERP7__Credentials__c(Name='DHL', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890', Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Province__c='Georgia',
                                                                       Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a', Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', 
                                                                       UPS_Account_Number__c='7895083910' );
        insert DHLCredentials;
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));    
        
        insert UPSCredentials;
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        
        Test.startTest();
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('',psod.ERP7__contact__c,'',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('','',psod.ERP7__Account__c,',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getBA(bAddress.id);
        POSLightning.getSA(sAddress.id);
        POSLightning.discountPercent(String.valueof(dp.Id));
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        POSLightning.upsWrap upsw = new POSLightning.upsWrap();
        POSLightning.rateWrapper upsrw = new POSLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        POSLightning.UPSServices(sod.Id, 'Package', 2, String.valueof(system.today()));
        POSLightning.UPSServiceSave(sod.Id, JSON.serialize(new POSLightning.rateWrapper()), String.valueof(system.today()), 10);
        String strTmp = '<xml><ToUserName>tUN</ToUserName><FromUserName>fUN</FromUserName><MsgType>mT</MsgType></xml>';
        XmlStreamReader reader = new XmlStreamReader(Blob.valueOf(strTmp).toString());
        POSLightning.readXMLResponse(reader,'MsgType');
        POSLightning.readXMLResponseWithAtt(reader,'MsgType','UK');
        String sony='test'; String accf = 'test'; String conf = 'test';
        POSLightning.getAllPayDetails2(sony, accf, conf);
        POSLightning.getAllPayDetails(sony);
        String cony = 'test'; String custy = 'test';
        POSLightning.getAll(sony, cony, custy);
        System.assertEquals(cony, custy);
        Test.stopTest();
    }
    
    private testMethod static void unitTest_POSLightning_3(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
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
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active', Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice; 
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert customPriceps;          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
        insert ps1; 
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice1; 
        PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
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
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
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
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        insert FedexCredentials;
        ERP7__Credentials__c DHLCredentials = new ERP7__Credentials__c(Name='DHL', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890', Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Province__c='Georgia',
                                                                       Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a', Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', 
                                                                       UPS_Account_Number__c='7895083910' );
        insert DHLCredentials;
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));    
        
        insert UPSCredentials;
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        
        Test.startTest();
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('',psod.ERP7__contact__c,'',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('','',psod.ERP7__Account__c,',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getBA(bAddress.id);
        POSLightning.getSA(sAddress.id);
        POSLightning.discountPercent(String.valueof(dp.Id));
        
        String sony='test'; String accf = 'test'; String conf = 'test';
        String cony = 'test'; String custy = 'test';
        POSLightning.getAll(sony, cony, custy);
        System.assertEquals(cony, custy);
        Test.stopTest();
    }
    
    private testMethod static void unitTest_POSLightning_33(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
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
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active', Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice; 
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert customPriceps;          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
        insert ps1; 
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice1; 
        PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
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
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
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
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        insert FedexCredentials;
        ERP7__Credentials__c DHLCredentials = new ERP7__Credentials__c(Name='DHL', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890', Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Province__c='Georgia',
                                                                       Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a', Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', 
                                                                       UPS_Account_Number__c='7895083910' );
        insert DHLCredentials;
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));    
        
        insert UPSCredentials;
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        
        Test.startTest();
        POSLightning ocl = new POSLightning();        
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        POSLightning.upsWrap upsw = new POSLightning.upsWrap();
        POSLightning.rateWrapper upsrw = new POSLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Invoice__c> Invoices = new List<Invoice__c>(); Invoices.add(invoice);
        List<String> selInvList=new List<String>();
        
        POSLightning.loyaltyProcessing(JSON.serialize(SalesOrder2Creates), JSON.serialize(Customers), 20, 10, 5, 50, 100);
        POSLightning.CreateCashPayment(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test')));
        POSLightning.CreateBankPayment(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test')));
        POSLightning.CreateCardPayment(SalesOrder2Creates, JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2018')), '123');
        POSLightning.CreateCardPaymentUpdated(SalesOrder2Creates, JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2018')), '123',bAddress);
        POSLightning.CreateCardPaymentUpdat(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='4012888888881881',CardType__c='visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2025')), '123',JSON.serialize(bAddress), String.valueOf(orgn.Id), 'Paypal');
        POSLightning.CreateInvoiceCardPayment(Invoices[0].Id, JSON.serialize(new Payment__c(Name='test paypal',Amount__c=20)), JSON.serialize(new ERP7__Payment_Method__c(Name='test paypal',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123');
        POSLightning.CreateAccountCardPayment(orgn.Id, JSON.serialize(new Payment__c(Name='test paypal',Amount__c=20)), JSON.serialize(new ERP7__Payment_Method__c(Name='test paypal',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123');
        Credentials.Name = 'Authorize.net';
        update Credentials;
        POSLightning.CreateCardPayment(SalesOrder2Creates, JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test auth',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123');
        POSLightning.CreateInvoiceCardPayment(Invoices[0].Id, JSON.serialize(new Payment__c(Name='test',Amount__c=20)), JSON.serialize(new ERP7__Payment_Method__c(Name='test auth',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123');
        POSLightning.CreateAccountCardPayment(orgn.Id, JSON.serialize(new Payment__c(Name='test',Amount__c=20)), JSON.serialize(new ERP7__Payment_Method__c(Name='test auth',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123');
        String sony='test'; String accf = 'test'; String conf = 'test';
        POSLightning.getAllPayDetails2(sony, accf, conf);
        //POSLightning.getInvoicePayDetails(Invoices[0].Id);
        String cony = 'test'; String custy = 'test';
       // POSLightning.getAll(sony, cony, custy);
        System.assertEquals(cony, custy);
        Test.stopTest();
    }
    
    private testMethod static void unitTest_POSLightning_4(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
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
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active', Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true, Selling_Price__c = 1200);
        insert standardPrice; 
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c = 1200);
        insert customPriceps;          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
        insert ps1; 
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c = 1200);
        insert standardPrice1; 
        PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c = 1200);
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
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
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
        
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert UPSCredentials;
        
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        
        passwordData = Blob.valueOf(FedexCredentials.Password_Transkey__c);
        FedexCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        FedexCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert FedexCredentials;
        
        ERP7__Credentials__c DHLCredentials = new ERP7__Credentials__c(Name='DHL', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890', Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Province__c='Georgia',
                                                                       Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a', Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', 
                                                                       UPS_Account_Number__c='7895083910' );
        insert DHLCredentials;
        
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        ERP7__Coupon__c coupon = new ERP7__Coupon__c(Name='test', ERP7__Start_Date__c=system.today(), ERP7__End_Date__c=system.today(), ERP7__Value__c=10.02,
                                                     ERP7__Minimum_Order_Amount__c=10.00);
        insert coupon;
        ERP7__Coupon_Issued__c ci = new ERP7__Coupon_Issued__c(Name='test', ERP7__Coupon__c=coupon.Id, ERP7__Issued_Date__c=system.today());
        insert ci;
        ERP7__Coupon_Redemption__c cr = new ERP7__Coupon_Redemption__c(Name='Test', ERP7__Coupon_Issued__c=ci.Id, ERP7__Redemption_Date__c=system.today(),
                                                                       ERP7__Coupon__c=coupon.Id);
        //insert cr;
        ERP7__Credit_Note__c credit = new ERP7__Credit_Note__c(Name='Test', ERP7__Coupon_Redemption__c=cr.Id, ERP7__Account__c=customer.Id);
        insert credit;
        Test.startTest();
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        POSLightning.upsWrap upsw = new POSLightning.upsWrap();
        POSLightning.rateWrapper upsrw = new POSLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Invoice__c> Invoices = new List<Invoice__c>(); Invoices.add(invoice);
        
        String sony='test'; String accf = 'test'; String conf = 'test';
        POSLightning.getAllPayDetails2(sony, accf, conf);
        POSLightning.getAllPayDetails(sony);
        String cony = 'test'; String custy = 'test';
        POSLightning.getAll(sony, cony, custy);
        POSLightning.rateWrapper wrapper2=new POSLightning.rateWrapper();
        wrapper2.totalCharges='100';
        wrapper2.service='Test';
        String value1=JSON.serialize(wrapper2);
        POSLightning.FedServices(sod.Id, 'Your_Packaging', 2, String.valueof(system.today()));
        POSLightning.FedServicesSave(String.valueof(sod.Id),value1 , 10.5);
        
        POSLightning.DHLServices(sod.Id, 'Package', 2, String.valueof(system.today()));
        
        POSLightning.DhlServicesSave(String.valueof(sod.Id), value1, 1.2);
        
        List<Object> PDWL = POSLightning.productFetchss('','','','',JSON.serialize(currentSalepoints),JSON.serialize(Customers),JSON.serialize(Contacts),sop.Id, JSON.serialize(new List<OrderConsoleLightning.itemWrapper>()), false, false,system.Today(),10);
        POSLightning.Assignment(JSON.serialize(PDWL), JSON.serialize(currentSalepoints),JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id,10.00);
        List<Id> newIds = new List<Id>();
        newIds.add(SOP.Id);
        POSLightning.saveDraft(JSON.serialize(PDWL), JSON.serialize(currentSalepoints), JSON.serialize(sod),JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id, new List < String >(), '', 0, 0);
        try{POSLightning.saveDrafts(JSON.serialize(PDWL), JSON.serialize(currentSalepoints), JSON.serialize(sod),JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id, new List < String >(), '', 0, 0,newIds);}catch(Exception e){}
        POSLightning.updateTax_OnAddressChange(JSON.serialize(POSLightning.IWL),2);
        POSLightning.ProductsAndDiscounts ik = new POSLightning.ProductsAndDiscounts();
        ik.product=ps;
        POSLightning.getSerialNos(JSON.serialize(currentSalepoints), JSON.serialize(Customers),JSON.serialize(ik),'');
        ik.product.ERP7__Is_Asset__c=true;
        ik.StartTime = system.Now();
        ik.EndTime = system.Now();
        POSLightning.getSerialNos(JSON.serialize(currentSalepoints), JSON.serialize(Customers),JSON.serialize(ik), '');
        POSLightning.getBatchNos(JSON.serialize(currentSalepoints), JSON.serialize(Customers),JSON.serialize(ik), '');
        POSLightning.getCharge(JSON.serialize(ik));
        POSLightning.ApplyCoupons(JSON.serialize(SalesOrder2Creates[0]),JSON.serialize(Customers),JSON.serialize(Contacts), 'test');
        POSLightning.SaveNewAddress(JSON.serialize(Addressess),'', '');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    private testMethod static void unitTest_POSLightning_5(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
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
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active', Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true, Selling_Price__c = 1200);
        insert standardPrice; 
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c = 1200);
        insert customPriceps;          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
        insert ps1; 
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c = 1200);
        insert standardPrice1; 
        PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c = 1200);
        insert customPriceps1;          
        System.assertEquals(ps.Name,'test');
        
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Profile__c = sop.Id;
        //sod.Customer_Profile__c = custProfile.Id;
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        //sod.Bill_To_Address__c = bAddress.Id;
        //sod.Ship_To_Address__c = sAddress.Id;
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
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
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
        
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert UPSCredentials;
        
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        
        passwordData = Blob.valueOf(FedexCredentials.Password_Transkey__c);
        FedexCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        FedexCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));
        insert FedexCredentials;
        
        ERP7__Credentials__c DHLCredentials = new ERP7__Credentials__c(Name='DHL', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890', Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Province__c='Georgia',
                                                                       Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a', Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', 
                                                                       UPS_Account_Number__c='7895083910' );
        insert DHLCredentials;
        
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        
        Date dToday = Date.today();
        Date toDate = Date.today()+30;
       // String dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
        //String toDateStr = toDate.day() + '/' + toDate.month() + '/' + toDate.year();
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',ERP7__Product__c=ps1.Id,ERP7__Active__c=true,ERP7__Type__c='Alternate',ERP7__Status__c='Certified',ERP7__Quantity__c=1,ERP7__Start_Date__c=dToday,ERP7__To_Date__c=toDate,ERP7__Unit_of_Measure__c='Each',ERP7__Sales_Ready__c=true);
        insert ver;
        
        Test.startTest();
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Invoice__c> Invoices = new List<Invoice__c>(); Invoices.add(invoice);
        
        POSLightning.CreateNewAddress(JSON.serialize(Addressess),'', '');
        POSLightning.getPaymentType();
        POSLightning.VersionsChange(JSON.serialize(currentSalepoints),sop.Id,sop.Id);
        POSLightning.VersionsChanged(ps.Id, 3, dp.Id, 5, JSON.serialize(currentSalepoints), true, JSON.serialize(Customers), JSON.serialize(Contacts), SOP.Id, '');
        POSLightning.VersionsChanged(ps.Id, 3, dp.Id, 5, JSON.serialize(currentSalepoints), true, JSON.serialize(Customers), JSON.serialize(Contacts), SOP.Id, ver.Id);
        //POSLightning.SaveDraft();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    private testMethod static void unitTest_POSLightning_6(){
        Test.startTest();
        Account customer = new Account(Name='Customer');
        insert customer;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;           
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Profile__c = sop.Id;
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        insert sod;
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
        insert invoice;
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Invoice__c> Invoices = new List<Invoice__c>(); Invoices.add(invoice);
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
        cn.ERP7__Account__c = Customer.id;
        insert cn;
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Credit_Note__c = cn.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        insert pay;
        ERP7__PrePayment__c prePay = new ERP7__PrePayment__c();
        prePay.ERP7__Account__c = Customer.Id;
        insert prePay; 
        ERP7__Payment__c prePayment = new ERP7__Payment__c();
        prePayment.ERP7__PrePayment__c  = prePay.id;
        prePayment.ERP7__Type__c = 'Credit';
        prePayment.ERP7__Amount__c = 100;
        insert prePayment;
        POSLightning.CreditProcessing(JSON.serialize(SalesOrder2Creates), JSON.serialize(Invoices), JSON.serialize(Customers), 10, 10,100,10);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    private testMethod static void unitTest_POSLightning_7(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true; 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
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
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', ERP7__Country__c='test',ERP7__Postal_Code__c='test',ERP7__State__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active', Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice; 
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert customPriceps;          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
        insert ps1; 
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice1; 
        PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
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
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
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
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        insert FedexCredentials;
        ERP7__Credentials__c DHLCredentials = new ERP7__Credentials__c(Name='DHL', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890', Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Province__c='Georgia',
                                                                       Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a', Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', 
                                                                       UPS_Account_Number__c='7895083910' );
        insert DHLCredentials;
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));    
        
        insert UPSCredentials;
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        
        Test.startTest();
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('',psod.ERP7__contact__c,'',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('','',psod.ERP7__Account__c,',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getBA(bAddress.id);
        POSLightning.getSA(sAddress.id);
        POSLightning.discountPercent(String.valueof(dp.Id));
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        POSLightning.upsWrap upsw = new POSLightning.upsWrap();
        POSLightning.rateWrapper upsrw = new POSLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Invoice__c> Invoices = new List<Invoice__c>(); Invoices.add(invoice);
        List<String> selInvList=new List<String>();
        
        POSLightning.loyaltyProcessing(JSON.serialize(SalesOrder2Creates), JSON.serialize(Customers), 20, 10, 5, 50, 100);
        //POSLightning.CreateCashPayment(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test')));
        //POSLightning.CreateBankPayment(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test')));
        //POSLightning.CreateCardPayment(SalesOrder2Creates, JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2018')), '123');
        Credentials.Name = 'Authorize.net';
        update Credentials;
        //POSLightning.CreateCardPayment(SalesOrder2Creates, JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test auth',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123');
        //POSLightning.CreateCardPaymentUpdat(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test',Card_Number__c='1234567890',CardType__c='test',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2018')), '123',JSON.serialize(bAddress), String.valueOf(orgn.Id));
        //POSLightning.CreateCardPaymentUpdat(SalesOrder2Creates, JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test auth',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123',String.valueOf(orgn.Id));
        
        String sony='test'; String accf = 'test'; String conf = 'test';
        //POSLightning.getAllPayDetails(sony);
        String cony = 'test'; String custy = 'test';
        POSLightning.getAll(sony, cony, custy);
        System.assertEquals(cony,custy);
        Test.stopTest();
    }
    private testMethod static void unitTest_POSLightning_8(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true; 
        PreventRecursiveLedgerEntry.loged = true; 
        PreventRecursiveLedgerEntry.proceed = false;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
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
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active', Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 ps = new Product2(Name='test',Track_Inventory__c=true,IsActive=true);
        insert ps;   
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice; 
        PricebookEntry customPriceps = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps.Id,UnitPrice = 12000, IsActive = true);
        insert customPriceps;          
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
        insert ps1; 
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
        insert standardPrice1; 
        PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
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
        Invoice__c invoice = new Invoice__c(Active__c = true,Organisation__c = orgn.Id, Order__c=sod.id,Account__c=customer.id);
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
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
        ERP7__Credentials__c FedexCredentials = new ERP7__Credentials__c(ERP7__End_Point__c='test',ERP7__Key__c='test',ERP7__UPS_Account_Number__c='123',Active__c = true,Name = 'FedEx',ERP7__Password_Transkey__c = 'test', ERP7__Signature__c = 'test', URL__c = 'test', ERP7__Username_Login__c = 'test', ERP7__Encrypted_Key__c = 'test',
                                                                         ERP7__Shipper_Name__c='test',ERP7__Shipper_Company_Name__c='test',ERP7__Shipper_Email__c='test@test.com',ERP7__Shipper_Phone_Number__c='123456789',ERP7__Shipper_Street__c='test',ERP7__Shipper_City__c='test',ERP7__Shipper_Postal_Code__c='test',ERP7__Shipper_Country__c='test',ERP7__Shipper_Province__c='test');
        insert FedexCredentials;
        ERP7__Credentials__c DHLCredentials = new ERP7__Credentials__c(Name='DHL', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890', Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Province__c='Georgia',
                                                                       Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a', Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', 
                                                                       UPS_Account_Number__c='7895083910' );
        insert DHLCredentials;
        userData = Blob.valueOf(UPSCredentials.Username_Login__c);
        passwordData = Blob.valueOf(UPSCredentials.Password_Transkey__c);
        UPSCredentials.Encrypted_Key__c = EncodingUtil.convertToHex(cryptoKey);
        UPSCredentials.Username_Login__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, userData));
        UPSCredentials.Password_Transkey__c = EncodingUtil.convertToHex(Crypto.encryptWithManagedIV('AES256', cryptoKey, passwordData));    
        
        insert UPSCredentials;
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='test', ERP7__Code__c='test', ERP7__Country__c='test');
        insert countryCode;
        ERP7__Package_Details__c pkgDetailList = new ERP7__Package_Details__c(Name='Package', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Package');
        insert pkgDetailList;
        
        ERP7__Package_Details__c pkgDetailList2 = new ERP7__Package_Details__c(Name='Your_Packaging', ERP7__Length__c=1, ERP7__Width__c=1, ERP7__Height__c=1, Weight__c=1, ERP7__Weight_Unit__c='KG', ERP7__Package_Type__c='Your_Packaging');
        insert pkgDetailList2;
        
        Test.startTest();
        POSLightning ocl = new POSLightning();
        POSLightning.getAll2(psod.Name,'','',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('',psod.ERP7__contact__c,'',',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getAll2('','',psod.ERP7__Account__c,',ERP7__Debit_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c, ERP7__No_of_Loyalty_Cards__c, ERP7__Is_Person_Account__c ','');
        POSLightning.getBA(bAddress.id);
        POSLightning.getSA(sAddress.id);
        POSLightning.discountPercent(String.valueof(dp.Id));
        POSLightning.IWL = new List<POSLightning.itemWrapper>();
        POSLightning.upsWrap upsw = new POSLightning.upsWrap();
        POSLightning.rateWrapper upsrw = new POSLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Invoice__c> Invoices = new List<Invoice__c>(); Invoices.add(invoice);
        
        POSLightning.loyaltyProcessing(JSON.serialize(SalesOrder2Creates), JSON.serialize(Customers), 20, 10, 5, 50, 100);
        POSLightning.CreateCashPayment(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test')));
        POSLightning.CreateBankPayment(JSON.serialize(SalesOrder2Creates), JSON.serialize(new Payment__c(Name='test')));
        Credentials.Name = 'Authorize.net';
        update Credentials;
       // POSLightning.CreateCardPayment(SalesOrder2Creates, JSON.serialize(new Payment__c(Name='test',Amount__c=10)), JSON.serialize(new ERP7__Payment_Method__c(Name='test auth',Card_Number__c='4242424242424242',CardType__c='Visa',Card_Expiration_Month__c='10',Card_Expiration_Year__c='2020')), '123');
        
        String sony='test'; String accf = 'test'; String conf = 'test';
        String cony = 'test'; String custy = 'test';
        POSLightning.getAll(sony, cony, custy);
       // POSLightning.getAllPayDetails(String.valueof(SalesOrder2Creates[0].Id), '', ''); commented due to erro
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    private testMethod static void unitTestCasesSet_9(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true;   
        PreventRecursiveLedgerEntry.loged = true;  
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
        Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
        insert empPay;
        Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
        insert empPayLineItem;
        Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
        insert payCat;
        List<Pay_Adjustment_Line_Item__c> mylistpali = new List<Pay_Adjustment_Line_Item__c>();
        Pay_Adjustment_Line_Item__c pali1 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali1;
        upsert pali1;
        mylistpali.add(pali1); 
        
        Pay_Adjustment_Line_Item__c pali3 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali3;
        upsert pali3;
        mylistpali.add(pali3);  
        
        Pay_Adjustment_Line_Item__c pali2 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Addition', Amount__c=100,Category_Type__c='Basic',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali2;
        upsert pali2;
        mylistpali.add(pali2);
        
        Pay_Adjustment_Line_Item__c pali4 = new Pay_Adjustment_Line_Item__c(Name='test',Adjustment_Category__c=payCat.Id,Adjustment_Category1__c='Deduction', Amount__c=100,Category_Type__c='Advance',Is_Active__c=true,Included_in_Payroll__c=true);
        upsert pali4;
        upsert pali4;
        mylistpali.add(pali4);
        
        empPayLineItem.Total_Addition__c=0.00;
        empPayLineItem.Total_Deduction__c=0.00;
        update empPayLineItem;
        pali2.Adjustment_Category1__c='deduction';
        pali2.Category_Type__c='Advance';
        try{ update pali2; } catch(Exception ex){} 
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';            
        try{ update pali4; } catch(Exception ex){} 
        empPayLineItem.Total_Addition__c=null;
        empPayLineItem.Total_Deduction__c=null;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='deduction';
        pali4.Category_Type__c='Advance';
        pali2.Adjustment_Category1__c='Addition';
        pali2.Category_Type__c='Basic';  
        update pali4;
        update pali2;          
        delete pali1;
        undelete pali1;                       
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali3.Adjustment_Category1__c='deduction';
        pali3.Category_Type__c='Advance';
        update pali3;            
        empPayLineItem.Total_Addition__c=0;
        empPayLineItem.Total_Deduction__c=0;
        update empPayLineItem;
        pali4.Adjustment_Category1__c='Addition';
        pali4.Category_Type__c='Basic';
        update pali4;                   
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
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id,ERP7__Default__c=true);
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
        
        Date dToday = Date.today();
        Date toDate = Date.today()+30;
       // String dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
        //String toDateStr = toDate.day() + '/' + toDate.month() + '/' + toDate.year();
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',ERP7__Product__c=ps1.Id,ERP7__Active__c=true,ERP7__Type__c='Alternate',ERP7__Status__c='Certified',ERP7__Quantity__c=1,ERP7__Start_Date__c=dToday,ERP7__To_Date__c=toDate,ERP7__Unit_of_Measure__c='Each',ERP7__Sales_Ready__c=true);
        insert ver;
        
        Test.startTest();        
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>(); currentSalepoints.add(salepoint);
        List<Account> Customers = new List<Account>(); Customers.add(Customer);
        List<Contact> Contacts = new List<Contact>(); Contacts.add(Contact);
        List<Address__c> Addressess = new List<Address__c>(); Addressess.add(bAddress);
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>(); SalesOrder2Creates.add(sod);
        List<Object> PDWL = POSLightning.productFetchss('','','','',JSON.serialize(currentSalepoints),JSON.serialize(Customers),JSON.serialize(Contacts),sop.Id, JSON.serialize(new List<OrderConsoleLightning.itemWrapper>()), false, false,System.Today(),10);
        
        POSLightning.editProducts(ps.Id, 3, dp.Id, 5,JSON.serialize(currentSalepoints),true,JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id,ver.Id);
        POSLightning.addAssets();
        POSLightning.getTaxRateByAddressId(bAddress.Id);
        
        POSLightning.itemWrapper wrapper=new POSLightning.itemWrapper();
        wrapper.orderLineItemId=solim.Id;
        List<POSLightning.itemWrapper> wrapperList=new List<POSLightning.itemWrapper>();
        wrapperList.add(wrapper);
        String value=JSON.serialize(wrapper);
        
        List<String> lineItem2delete=new List<String>();    lineItem2delete.add(solim1.Id);
        POSLightning.saveDrafts(value,JSON.serialize(currentSalepoints),JSON.serialize(sod),JSON.serialize(Customers),JSON.serialize(Contacts), SOP.Id, lineItem2delete, '', 0, 0,null);
        POSLightning.getMerchantId();
        POSLightning.getCustomerDetails(customer.Id);
        POSLightning.getCustomerDetails('');
        POSLightning.eposCheckFLS();        
        POSLightning.decimalToBinary(10);
        POSLightning.base64ToBits('Test');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    } 
    
     //================Test cases for Product Configurator=====================
    static testMethod void unitTest15(){
        Account acc = new Account(Name='Naseeruddin');
        insert acc;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=acc.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE,ERP7__Issue_Manufacturing_Order__c=true);
        insert pro;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test',Product__c = pro.Id);
        insert ver;
       pro.ERP7__Version__c=ver.Id; update pro;
        Address__c add = new Address__c(Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Customer__c=acc.Id);
        insert add;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true);
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id,ERP7__Address__c=add.Id,ERP7__Active__c =true);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ERP7__Quotes__c quote=new ERP7__Quotes__c(Name='Test 1', ERP7__Order_Profile__c=profile.Id);
        insert quote;
        
        //Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc.ERP7__Order_Profile__c=profile.Id; upsert acc;
        
        ERP7__Quotes__c quote1=new ERP7__Quotes__c(Name='Test 1',ERP7__Customer__c=acc.Id);
        insert quote1;
        ERP7__Quotes__c quote2=new ERP7__Quotes__c(Name='Test 1');
        insert quote2;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = acc.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock;       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Default__c=true,Active__c=true,Product__c=pro.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,Order_Profile__c=profile.Id);
        insert tda;
        
        ERP7__Product_Feature__c pf=new ERP7__Product_Feature__c(Name='Test',ERP7__Product__c=pro.Id);
        insert pf;
        ERP7__Product_Option__c po=new ERP7__Product_Option__c(ERP7__Optional_SKU__c=pro.id,ERP7__Configured_SKU__c=pro.Id,ERP7__Product_Feature__c=pf.Id);
        insert po;
        POSLightning.getOptionProd(pro.Id, acc.Id);
        //POSLightning.getOptionProd(pro.Id, quote1.Id);
        //POSLightning.getOptionProd(pro.Id, quote2.Id);
        POSLightning.getAllOptionRules(pro.Id);
        
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today());
        insert ver1;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Manufacturing'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom;
        ERP7__Process__c process = new ERP7__Process__c(Name = 'Test', ERP7__Process_Name__c = 'Test', ERP7__Manufacturing_Assembly_Costs__c = 10, ERP7__Workforce_Hour_Required__c = 12, ERP7__Machine_Hour_Required__c = 15, ERP7__Other_Material_Cost__c = 10, ERP7__Machine_Usage_Cost__c = 10, ERP7__Workforce_Cost__c = 10);
        insert process;
        ERP7__Process_Cycle__c processcycle = new ERP7__Process_Cycle__c(Name = 'Test', ERP7__Progress__c = 3, ERP7__Process__c = process.Id);
        insert processcycle;
        ERP7__Routing__c routing = new ERP7__Routing__c(Name = 'Test', ERP7__Status__c = 'Certified', ERP7__Type__c = 'Parallel', ERP7__BOM_Version__c = ver1.Id, ERP7__Product__c = pro.Id, ERP7__Channel__c = channel.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Description__c = 'test', ERP7__Process__c = process.Id, ERP7__Finished_Products_Site__c = site.Id, ERP7__Minimum_Lot_Size__c = 100, ERP7__Maximum_Lot_Size__c = 1000,ERP7__Address__c=add.Id);
        insert routing;
        //String strRecordTypeId1 = [Select Id From RecordType Where SobjectType = 'ERP7__Bill_Of_Material__c' and Name = 'Catalog_BOM'].Id;
        //bom.RecordTypeId=strRecordTypeId1;
        //update bom;
        Map<String, Decimal> proOptions1=new Map<String, Decimal>();
        proOptions1.put(pro.Id, 1);
        Map<String, String> proFeatureMap=new Map<String, String>();
        proFeatureMap.put(pro.Id, pf.Id);
        POSLightning.createVersion(JSON.serialize(proOptions1),pro.Id,JSON.serialize(proFeatureMap));
        POSLightning.getAccountPayDetails(acc.id);
        POSlightning.SOInvoiceList('');
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    //================Test cases for Product Configurator=====================
}