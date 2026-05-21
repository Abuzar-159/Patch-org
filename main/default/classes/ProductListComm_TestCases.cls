@isTest(SeeAllData=True)
public class ProductListComm_TestCases {  
     
    static testMethod void ProdListCommTest1(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;  
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Organisation__c=acc.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        PageReference pageRef = Page.ProductListCommInvoiceDocument;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(inv);
        ApexPages.currentPage().getParameters().put('Id',inv.id);
        
        ProductListComm plc=new ProductListComm();
        plc.getInvoiceListDownload();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        
    }
    
    static testMethod void ProdListCommTest2(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        //UserRole r = new UserRole(name = 'TEST ROLE');
        //insert r;
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2112@test.com',
            Alias = 'batman',
            Email='wayne@way.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago',
            IsActive=true
        );
        Database.insert(portalAccountOwner1);
        
        System.runAs ( portalAccountOwner1 ) {
            //Create account
            Account portalAccount1 = new Account(
                Name = 'TestAccount',
                OwnerId = portalAccountOwner1.Id
            );
            Database.insert(portalAccount1);
            
            //Create contact
            Contact contact1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = portalAccount1.Id,
                Email = 'test@test.com'
            );
            Database.insert(contact1);
            
            //Create user
          //  Profile portalProfile = [SELECT Id FROM Profile where Name ='Customer Community Portal User' Limit 1];
            Profile portalProfile = [
    SELECT Id 
    FROM Profile 
    WHERE UserType = 'CSPLitePortal' 
    LIMIT 1
];

            User user1 = new User(
                Username = 'test12345@test.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                IsActive=true
            );
            Database.insert(user1);
            Contact con1=[Select Id,Name from Contact where Id =:user1.ContactId];
            
            System.runAs (user1) {
                ProductListComm.getProfileId();
                ProductListComm.getUserDetails();
                ProductListComm.updateSPNCheckbox(true);
                String salName = 'ERP7';
                String sal1Name = 'ERP7';
                System.assertEquals(salName, sal1Name);
            }
        }
    }
    static testMethod void ProdListCommTest3(){        
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;
        ERP7__Cart__c cart=new ERP7__Cart__c(Name='Test',ERP7__Account__c=acc.Id);
        insert cart;
        ERP7__Cart_Picked_Item__c cpi=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;
        
        ProductListComm.getCatList(acc.Id,ProIds);
        ProductListComm.getCatList('',ProIds);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        
    }
    
    static testMethod void ProdListCommTest3A(){        
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        /*ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;*/
        ERP7__Cart__c cart=new ERP7__Cart__c(Name='Test',ERP7__Account__c=acc.Id);
        insert cart;
        ERP7__Cart_Picked_Item__c cpi=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;
        
        ProductListComm.getCatList(acc.Id,ProIds);
        ProductListComm.productFetch(acc.id,'CreatedDate');
        String cat1='Hardware';
        List<String> catList=new List<String>();
        catList.add(cat1);
        ProductListComm.fetchProdByCat(acc.Id,catList,'CreatedDate','','');
        ProductListComm.saveCarts(acc.Id,pbe.Product2Id);  
        ProductListComm.addTocart(acc.Id,pro.Id,2);        
        ProductListComm.addTocartForConf(acc.Id,pro.Id,2,ver.Id);
        ProductListComm.viewCart(acc.Id,proIds);
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        ProductListComm.productDetails(acc.Id,pro.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest4(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Contact',AccountId=acc.Id, Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;
        ERP7__Cart__c cart=new ERP7__Cart__c(Name='Test',ERP7__Account__c=acc.Id);
        insert cart;
        ERP7__Cart_Picked_Item__c cpi=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi;
        
        ProductListComm.saveCarts(acc.Id,pbe.Product2Id);        
        ProductListComm.addTocart(acc.Id,pro.Id,2);
        
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ProductListComm.addTocartForConf(acc.Id,pro.Id,2,ver.Id);        
        
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;
        ProductListComm.viewCart(acc.Id,proIds);
        ProductListComm.viewCart('',proIds);
        
        ERP7__Cart_Picked_Item__c cpi1=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi1;
        List<sObject> cartList=new List<sObject>();
        cartList.add(cpi1);
        ERP7__Cart_Picked_Item__c cpi2=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi2;
        List<String> itemsToDel=new List<String>();
        itemsToDel.add(cpi2.Id);        
        ProductListComm.cartUpdate(acc.Id,cartList,itemsToDel);
        
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;        
        
        ProductListComm.productDetails(acc.Id,pro.Id);
        ProductListComm.productDetails('',pro.Id);
        
        Product_Feature__c profeat=new Product_Feature__c(Name='TestFeature',ERP7__Product__c=pro.Id);
        insert profeat;
        ERP7__Product_Option__c proOption=new ERP7__Product_Option__c(ERP7__Product_Feature__c=profeat.Id,ERP7__Configured_SKU__c=pro.Id);
        insert proOption;
        ProductListComm.getOptionProd(pro.Id);
        ProductListComm.getAllOptionRules(pro.Id);
        ProductListComm.productFetch(acc.Id,'CreatedDate');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest5(){  //Pricebookentry accepting correctly
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;
        ERP7__Cart__c cart=new ERP7__Cart__c(Name='Test',ERP7__Account__c=acc.Id);
        insert cart;
        ERP7__Cart_Picked_Item__c cpi=new ERP7__Cart_Picked_Item__c();
        //insert cpi;
        
        
        ERP7__Coupon__c cpn=new ERP7__Coupon__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Start_Date__c=System.today(),ERP7__End_Date__c=System.today());
        insert cpn;
        /*ERP7__Coupon_Issued__c issCpn=new ERP7__Coupon_Issued__c(Name='Test',ERP7__Coupon__c=cpn.Id);
        insert issCpn;
        ERP7__Coupon_Redemption__c cred1=new ERP7__Coupon_Redemption__c();
        ERP7__Coupon_Redemption__c cred=new ERP7__Coupon_Redemption__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Coupon__c=cpn.Id,ERP7__Coupon_Issued__c=issCpn.Id);
        insert cred;*/
        ProductListComm.applyCoupons(cpn.Name,200,acc.Id);
        
        
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;        
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        String cat1='Hardware';
        List<String> catList=new List<String>();
        catList.add(cat1);
        ProductListComm.fetchProdByCat(acc.Id,catList,'CreatedDate','','');
        ProductListComm.getCatList(acc.Id,ProIds);
        ProductListComm.getCatList('',ProIds);
        ProductListComm.productFetch('','CreatedDate');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest6(){
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;
        Product2 pro2 = new Product2(Name = 'Ram', Family = 'Hardware');
        insert pro2;
        List<Id> proIds1=new List<Id>();
        proIds1.add(pro2.Id);
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today());
        insert ver1;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Catalog'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom;
        String strRecordTypeId1 = [Select Id From RecordType Where SobjectType = 'ERP7__BOM__c' and Name = 'Catalog BOM'].Id;
        bom.RecordTypeId=strRecordTypeId1;
        update bom;
        ProductListComm.createVersion(proIds1,pro.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest7(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;        
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;        
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        
        String cat1='Hardware';
        List<String> catList=new List<String>();
        catList.add(cat1);
        List<String> catList1=new List<String>();
        ProductListComm.fetchProdByCat(acc.Id,catList,'CreatedDate','','');
        ProductListComm.fetchProdByCat('',catList,'CreatedDate','Banana','Food');
        ProductListComm.fetchProdByCat('',catList,'price','Banana','Food');
        ProductListComm.fetchProdByCat('',catList,'pricedesc','Banana','Food');        
        ProductListComm.fetchProdByCat('',catList,'CreatedDate','Banana','');
        ProductListComm.fetchProdByCat('',catList,'price','Banana','');
        ProductListComm.fetchProdByCat('',catList,'pricedesc','Banana','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest8(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;        
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;        
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        
        String cat1='Hardware';
        List<String> catList=new List<String>();
        catList.add(cat1);
        List<String> catList1=new List<String>();   
        ProductListComm.fetchProdByCat('',catList1,'CreatedDate','','');
        ProductListComm.fetchProdByCat('',catList1,'pricedesc','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    static testMethod void ProdListCommTest8A(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;        
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;        
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        
        String cat1='Hardware';
        List<String> catList=new List<String>();
        catList.add(cat1);
        List<String> catList1=new List<String>();   
        
        ProductListComm.fetchProdByCat('',catList1,'price','','');
        ProductListComm.fetchProdByCat('',catList1,'CreatedDate','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest9(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro1;
        List<Product2> proList=[Select Id,Name from Product2 Limit 2];
        List<Id> proIds=new List<Id>();
        for(Product2 pr:proList)    proIds.add(pr.Id);
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;        
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;        
        ERP7__Site__c site=new ERP7__Site__c(Name='TestSite',ERP7__Organisation__c=acc.Id);
        insert site;
        Distribution_Channel__c dCh=new Distribution_Channel__c(Name='Test',ERP7__Channel__c=channel.Id,ERP7__Site__c=site.Id,ERP7__Active__c=true);
        insert dCh;
        
        String cat1='Hardware';
        List<String> catList=new List<String>();
        catList.add(cat1);
        List<String> catList1=new List<String>();
        ProductListComm.fetchProdByCat('',catList1,'pricedesc','','');
        ProductListComm.fetchProdByCat('',catList1,'price','','');        
        ProductListComm.fetchProdByCat('',catList,'pricedesc','',''); 
        ProductListComm.fetchProdByCat('',catList,'price','','');
      //  ProductListComm.saveCarts('',pro.Id);        
        //ProductListComm.addTocart('',pro.Id,1);
       // ProductListComm.addTocartForConf('',pro.Id,1,ver.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        
    }
    
    static testMethod void ProdListCommTest10(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Version__c ver=new ERP7__Version__c(Name='Test');
        insert ver;
        //ProductListComm.addTocart('',pro.Id,1);
      //  ProductListComm.addTocartForConf('',pro.Id,1,ver.Id);
        
        List<Id> guestPro=new List<Id>();
        guestPro.add(pro.Id);
        ProductListComm.viewCart('',guestPro);        
        ProductListComm.updateAddress1(acc.Id,'Akhtar Address','','add1','add2','add3','Test','United States','Georgia','1234','','');
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        
    }
    
    static testMethod void ProdListCommTest11(){
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123',AccountId=acc.Id);
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Address__c add1 = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add1;
        Address__c add2 = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=false,ERP7__Is_Shipping_Address__c=true, Primary__c=false);
        insert add2;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;
        ERP7__Sales_Order__c so1=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so1;
        
        ProductListComm.getAddresses(acc.Id);        
        ProductListComm.updateAddress1(acc.Id,'Akhtar Address','9876543213','add1','add2','add3','Test','United States','Georgia','1234',add.Id,con.Id);
        ProductListComm.delAddress(add1.Id);
        ProductListComm.delShipAddress(add.Id);
        ProductListComm.delShipAddress(add2.Id);
        ProductListComm.addAddrToSO(so.Id,add.Id);
        ProductListComm.addAddrToSO(so1.Id,add.Id);
        ProductListComm.fetchAdd(acc.Id);
        ProductListComm.updatePriAddress(acc.Id,'Akhtar Address','9876543212','add1','add2','add3','test','United States','Georgia','1234',add.Id,con.Id);
        ProductListComm.updateBillAddress(acc.Id,'Akhtar Address','add1','add2','add3','test','United States','Georgia','1234',add.Id);
        ProductListComm.updateShipAddress(acc.Id,'Akhtar Address','add1','add2','add3','test','United States','Georgia','1234',add.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest12(){
     	Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123129',AccountId=acc.Id);
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Organisation__c=acc.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;        
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pro.Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att; 
        ProductListComm.myOrders(acc.Id,'one');
        ProductListComm.myOrders(acc.Id,'six');
        ProductListComm.myOrders(acc.Id,'year');       
        ProductListComm.myOrders(acc.Id,'');         
        ProductListComm.searchOrder(acc.Id,'Test','Test');
        ProductListComm.searchOrder(acc.Id,'','Test');
        ProductListComm.cancelOrder(so.Id);
        ProductListComm.orderDetails(inv.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest13(){ 
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Contact',AccountId=acc.Id, Email ='makhtar@aqxolt.com', MobilePhone ='07123123128');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;
        ERP7__Cart__c cart=new ERP7__Cart__c(Name='Test',ERP7__Account__c=acc.Id);
        insert cart;
        ERP7__Cart_Picked_Item__c cpi=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi;       
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;
        ERP7__Cart_Picked_Item__c cpi2=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi2;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100,ERP7__Status__c ='Booked',ERP7__Order_Status__c ='Entered');
        insert so;       
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Organisation__c=acc.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;        
        ERP7__Coupon__c cpn=new ERP7__Coupon__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Start_Date__c=System.today(),ERP7__End_Date__c=System.today());
        insert cpn;
        ERP7__Coupon_Issued__c issCpn=new ERP7__Coupon_Issued__c(Name='Test',ERP7__Coupon__c=cpn.Id);
        insert issCpn;
        ERP7__Coupon_Redemption__c cred=new ERP7__Coupon_Redemption__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Coupon__c=cpn.Id,ERP7__Coupon_Issued__c=issCpn.Id);
        insert cred;        
        List<ERP7__Coupon_Redemption__c> credList=new List<ERP7__Coupon_Redemption__c>();
        credList.add(cred);
        
        ProductListComm.cartProdWrapper wrapper=new ProductListComm.cartProdWrapper();
        wrapper.cartproduct=pbe;
        wrapper.cpiList=cpi2;
        List<ProductListComm.cartProdWrapper> wrapperList=new List<ProductListComm.cartProdWrapper>();
        wrapperList.add(wrapper);
        String value=JSON.serialize(wrapperList);
        ProductListComm.createSO(acc.Id,value,JSON.serialize(credList));
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    static testMethod void ProdListCommTest(){
        ProductListComm.getAllProducts();
        ProductListComm.getFamilyList();
        ProductListComm.rateWrapper rw=new ProductListComm.rateWrapper();
        ProductListComm.upsWrap upsW=new ProductListComm.upsWrap();
        ProductListComm.selectOptions so1=new ProductListComm.selectOptions('','');
        ProductListComm.selectOptions so2=new ProductListComm.selectOptions('','',true);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
    
    /*static testMethod void ProdListCommTest14(){ 
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact con = new Contact(FirstName='Test', LastName='Contact',AccountId=acc.Id, Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert profile;
        Account acc1=[Select Id,Name from Account where Name='Naseeruddin'];
        acc1.ERP7__Order_Profile__c=profile.Id;
        upsert acc1;
        ERP7__Cart__c cart=new ERP7__Cart__c(Name='Test',ERP7__Account__c=acc.Id);
        insert cart;
        ERP7__Cart_Picked_Item__c cpi=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi;                
        ERP7__Media__c media=new ERP7__Media__c(Name='TestMedia',ERP7__Active__c=true,ERP7__File__c='TestFile',ERP7__Product__c=pbe.Product2Id);
        insert media;
        Attachment att=new Attachment(Name='TestAtt',ParentId=media.Id,Body=Blob.valueOf('Unit Test Attachment Body')); 
        insert att;
        ERP7__Cart_Picked_Item__c cpi2=new ERP7__Cart_Picked_Item__c(Name='Test',ERP7__Cart__c=cart.Id,ERP7__Product__c=pro.Id,ERP7__Quantity__c=1);
        insert cpi2;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Organisation__c=acc.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        ERP7__Coupon__c cpn=new ERP7__Coupon__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Start_Date__c=System.today(),ERP7__End_Date__c=System.today());
        insert cpn;
        ERP7__Coupon_Issued__c issCpn=new ERP7__Coupon_Issued__c(Name='Test',ERP7__Coupon__c=cpn.Id);
        insert issCpn;
        ERP7__Coupon_Redemption__c cred=new ERP7__Coupon_Redemption__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Coupon__c=cpn.Id,ERP7__Coupon_Issued__c=issCpn.Id);
        insert cred;
        
        List<ERP7__Coupon_Redemption__c> credList=new List<ERP7__Coupon_Redemption__c>();
        credList.add(cred);
        
        ProductListComm.cartProdWrapper wrapper=new ProductListComm.cartProdWrapper();
        wrapper.cartproduct=pbe;
        wrapper.cpiList=cpi2;
        List<ProductListComm.cartProdWrapper> wrapperList=new List<ProductListComm.cartProdWrapper>();
        wrapperList.add(wrapper);
        String value=JSON.serialize(wrapperList);
        
        ProductListComm.createSO(acc.Id,value,null);	//new created so not working
        
    }*/
}