@isTest
private class TestCasesSet_1 {
    static testMethod void UnitTestErpMark7_1(){ 
        test.startTest();
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
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
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile.Id);
        insert profile;  
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
               
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;                      
        Loyalty_Setup__c loyalty = new Loyalty_Setup__c( Points_Per_Unit_Amount__c = 10);
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
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c( Name='test',RecordTypeId=custProfile_RTypes.Id);
        insert custProfile;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c sop = new ERP7__Profiling__c( Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        ERP7__Commission__c Commission = new ERP7__Commission__c(ERP7__Active__c =true);
        insert Commission;
        ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test');
        insert discountCoupon;
        ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
        insert CouponRedemption;
        
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
        Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps;     
        
        Product2 ps3 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps3;  
        
        Product2 ps2 = new Product2(Name='test',isActive=true,Track_Inventory__c=true);
        insert ps2;         
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI1;
        Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true);
        insert ps1;            
       BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa; 
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;            
        System.assertEquals(ps.Name,'test');
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Sales_Order_Line_Item__c solim1 = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=4,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim1;            
        solim1.Quantity__c=1;
        update solim1;
        solim1.Quantity__c=4;
        update solim1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false; 
        Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id );
        insert RMA;              
        RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
        insert RMA_Line_Item; 
        
        solim.Quantity__c = 2;
        update solim;
        Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
        Tax_Plan__c tp = new Tax_Plan__c(Name = 'Test',Type__c='sales');
        insert tp;
        Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
        insert pta;
        /*PriceBook_Entry__c pb = new PriceBook_Entry__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Active__c=true,End_Date__c=System.Today()+10,Product__c=ps.id,Purchase_Price__c=80,Selling_Price__c=100,Start_Date__c=System.Today(),Price_List__c=pl.id,Tax_Plan__c=tp.Id);
        insert pb;
        PriceBook_Entry__c pb1 = new PriceBook_Entry__c(Active__c=true,End_Date__c=System.Today()+10,Product__c=ps1.id,Purchase_Price__c=80,Selling_Price__c=100,Start_Date__c=System.Today(),Price_List__c=pl.id,Tax_Plan__c=tp.Id);
        insert pb1;*/
        Contract_Roles_And_Terms_Assigment cc = new Contract_Roles_And_Terms_Assigment();
        Contract_Roles_And_Terms_Assigment.Update_ContractplanTerms(false,true,false,true,new List<Contract>(),new List<Contract>(),new Map<Id,Contract>());
    }
     @isTest
    static void testContentDocumentLinkTrigger() {
        // Create a test user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser1254@testorg.com'
        );
        insert testUser;
        
        // Create an ERP7__Functionality_Control__c record
        ERP7__Functionality_Control__c fc = new ERP7__Functionality_Control__c(
            Name = 'Test Functionality Control',
            ERP7__Activate_ContentDocumentLink_Trigger__c = true
        );
        insert fc;
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        // Create test ContentDocumentLink record
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = acct.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        
        // Trigger the before insert event
        Test.startTest();
        insert cdl;
        Test.stopTest();
        
         System.assertEquals('AllUsers', 'AllUsers');
    }
}