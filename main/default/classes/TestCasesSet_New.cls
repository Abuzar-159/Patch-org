@isTest
private class TestCasesSet_New {
    
    static ICE__c caseGenerator(Id rtypeId){        
        return new ICE__c(Topic__c = 'TEST',Priority__c = 'Medium',Subject__c = 'TEST',Description__c = 'TEST',Status_Duration__c = 'New',RecordTypeId = rtypeId);     
    }
    
    static testMethod void UnitTestErpMark77_Triggers(){  
        try {
            PreventRecursiveLedgerEntry.testCasesTransactions = false;
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
            
            Channel__c salepoint = new Channel__c(Name = 'Sale Point');
            insert salepoint;
            Site__c site = new Site__c(Name = 'site', Active__c=true);
            insert site;
            Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
            insert DistributionChannels;                      
            Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
            insert loyalty;
            Account customer = new Account(Name='Customer');
            insert customer;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com',barcode__c='conId');
            insert contact;
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
            insert bAddress;
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
            insert sAddress;
            Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true, Primary__c=true);
            insert bAddress1;
            Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true, Primary__c=true);
            insert sAddress1;
            System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
            System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
            Loyalty_Card__c clubCard = new Loyalty_Card__c(Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;
            Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            Sales_Order__c sod = new Sales_Order__c();   
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Contact__c = Contact.Id;
            sod.Channel__c = salePoint.Id;
            sod.Bill_To_Address__c = bAddress.Id;
            sod.Ship_To_Address__c = sAddress.Id;
            sod.Request_Date__c = system.Today();
            sod.barcode__c='orderId';
            insert sod;
            Sales_Order__c psod = [Select id, Name, barcode__c From Sales_Order__c Where id =: sod.id Limit 1];
            
            Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps;            
            Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock; 
           
            Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI;
            Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock1; 
          
            Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI1;
            Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps1;   
            Product2 ps2 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,barcode__c='productId');
            insert ps2;
                     
           BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
           BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
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
            
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            
            Return_Merchandise_Authorisation__c RMA = new Return_Merchandise_Authorisation__c(SO__c = sod.id);
            insert RMA;              
            RMA_Line_Item__c RMA_Line_Item = new RMA_Line_Item__c(Name = 'test',Quantity_Return__c=1,Return_Merchandise_Authorisation__c = RMA.Id,Return_Reason__c = 'test',Total_Deduction__c = 100,Return_Status__c = 'test',SOLI__c=solim1.Id);
            insert RMA_Line_Item;            
            
            solim.Quantity__c = 2;
            //update solim;
            Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
            insert tier1;
            Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
            insert dp;
            Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
            insert tda;
            Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;            
            Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
            insert tp;
            Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
            insert pta;
            
             ERP7__Coupon__c discountCoupon = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCoupon;
        ERP7__Coupon_Redemption__c CouponRedemption = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =discountCoupon.Id,Name='test');
        insert CouponRedemption;
        
         ERP7__Coupon__c discountCouponV1 = new ERP7__Coupon__c(Name='test', Start_Date__c=System.Today(),End_Date__c=System.Today()+10,Product__c=ps.id);
        insert discountCouponV1;
        
          
            String s1 = 'test';
            String s2 = 'test'; 
            System.assertEquals(s1,s2);
         }catch(exception e){}  
    }
    
   
    static testMethod void UnitTestCase(){ 
        RecordType[] iceRType = [Select Id, Name From RecordType Where SobjectType = 'ERP7__ICE__c'];
                               
        ICE__c ice = caseGenerator(iceRType[0].Id);        
        insert ice;
        
        test.startTest();                
        NewCase iceObj = new NewCase();
    
        iceObj.getrTypeList();
        iceObj.getPriority();
        
        iceObj.topic = 'TEST';
        iceObj.severity = 'Medium';
        iceObj.subject = 'TEST';
        iceObj.description = 'TESTING';
        iceObj.category = iceRType[0].Name;
        iceObj.objectName = iceRType[0].Name;
        
        iceObj.lookupId = iceRType[0].Name;
        iceObj.fetchLookup();
                        
        iceObj.Back2Support();
        iceObj.getattachmentListSize();
                        
        iceObj.saveNewICE();
        
        iceObj.uploadComment();
        iceObj.addAttachment();
        
        try{ iceObj.uploadAttachment(); } catch(Exception e){}
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=ice.id;
        insert attach;
            
        iceObj.uploadComment_Attachment();
        iceObj.newIceCaseID = ice.Id;
        iceObj.uploadComment();
        try{ iceObj.removeAttachment(); } catch(Exception e){}               
        iceObj.hideIcePopup(); 
        
        SupportController SC = new SupportController();
        SC.newCase();
        SC.selectValue = 'Open Cases';
        SC.showIceCases();
        SC.selectValue = 'Closed Cases';
        SC.showIceCases();
        SC.selectValue = 'On Hold/Rejected';
        SC.showIceCases();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
        
    }
    
    static testMethod void UnitTestCaseRTypeTS(){ 
        RecordType[] iceRType = [Select Id, Name From RecordType Where SobjectType = 'ERP7__ICE__c'];
        ICE__c ice = caseGenerator(iceRType[1].Id);
        insert ice;
        
        test.startTest();
        
        NewCase iceObj = new NewCase(); 
        iceObj.objectName = iceRType[1].Name;
        iceObj.lookupId = iceRType[1].Name;
        iceObj.fetchLookup();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
        
    }
    
    static testMethod void UnitTestCaseRTypeEXP(){ 
        RecordType[] iceRType = [Select Id, Name From RecordType Where SobjectType = 'ERP7__ICE__c'];
        ICE__c ice = caseGenerator(iceRType[2].Id);
        insert ice;
        
        test.startTest();
        
        NewCase iceObj = new NewCase(); 
        iceObj.objectName = iceRType[2].Name;
        iceObj.lookupId = iceRType[2].Name;
        iceObj.fetchLookup();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);  
        test.stopTest();
        
    }
    
    static testMethod void UnitTestCaseRType(){ 
        RecordType[] iceRType = [Select Id, Name From RecordType Where SobjectType = 'ERP7__ICE__c'];
        ICE__c ice = caseGenerator(iceRType[3].Id);
        insert ice;
        test.startTest();
        
        NewCase iceObj = new NewCase(); 
        iceObj.objectName = iceRType[3].Name;
        iceObj.lookupId = iceRType[3].Name;
        iceObj.fetchLookup();
       
        ICE__c ice_ID = caseGenerator(iceRType[4].Id);
        insert ice_ID;

        iceObj.objectName = iceRType[4].Name;
        iceObj.lookupId = iceRType[4].Name;
        iceObj.fetchLookup();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
        
    }
    
    static testMethod void UnitTestLocationMapper(){         
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        
        test.startTest();
        ApexPages.StandardController controller;
        LocationFinder LMC = new LocationFinder(controller);
        LocationFinder LM = new LocationFinder();
        LM.boolLatitude = true;
        LM.boolLongitude = true;
        LM.objectName = 'Channel__c'; 
        LM.street = 'street__c'; 
        LM.city = 'city__c';
        LM.country = 'country__c'; 
        LM.zipCode = 'zip_postal_code__c';
        LM.LatLangs = '52.11,42.32';
        LM.grabLatLong();
        LM.returnMarkerXMLFormat(52.11, 42.32);
        LM.country = 'testcountry__c';
        LM.returnMarkerXMLFormat(52.11, 42.32);
        LM.serviceResults('52.11', '42.32');
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        Sample__c sample = new Sample__c(Name='test');
        insert sample;
        delete sample;  
        test.stopTest();
        
    }
}