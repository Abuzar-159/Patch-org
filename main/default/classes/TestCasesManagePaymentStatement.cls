@isTest
private class TestCasesManagePaymentStatement {
    static testMethod void UnitTestErpMark1(){         
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
        Profiling__c profile = new Profiling__c(Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile.Id);
        insert profile;  
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
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
        Loyalty_Card__c clubCard = new Loyalty_Card__c(Organisation_Business_Unit__c = busUnit.Id,Customer__c=customer.id,Contact__c=contact.id,Status__c='Active',Organisation__c = orgn.id,Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
        insert clubCard;
        Contact myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Organisation__c = orgn.Id;
        sod.Organisation_Business_Unit__c = busUnit.Id; 
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
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
       
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
        insert SPLI;
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
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
        
        RecordType rTypeB = [select Id, Name From RecordType Where Name = 'Bank Payment Method' and SobjectType = 'ERP7__Payment_Method__c' Limit 1];  
        
        Payment_Method__c pmethod = new Payment_Method__c(Account__c=customer.Id,contact__c=contact.Id,Card_Number__c='1234567890',CardType__c='MasterCard',Card_Expiration_Month__c='12',Card_Expiration_Year__c='2021',Name_on_Card__c='test',RecordTypeId=rTypeB.Id);
        insert pmethod;
        
        PageReference pageRef = System.Page.ManagePaymentStatement;
        pageRef.getParameters().put('Id',contact.id);
        Test.setCurrentPage(pageRef);
        
        test.startTest();
        ApexPages.StandardController controller;
        ManagePaymentStatement MPS = new ManagePaymentStatement(controller);
        List <Sales_Order__c> currentSO = [select id, name, barcode__c, Order_Status__c, Account__c, Contact__c from Sales_Order__c where id =: psod.Id limit 1];
        MPS.selectAllOrders();
        MPS.selAll = true;
        MPS.selectAllOrders();
        
        MPS.selectPaymentMethod();
        MPS.paymentMethodId = pmethod.Id;
        MPS.selectPaymentMethod();
        MPS.paymentMethodWrapperList[0].sel = true;
        MPS.selectPaymentMethod();
        string ik = MPS.TotalDueStr;
        MPS.TotalDueStr = '10';
        
        MPS.close();
        MPS.paymentType = 'Cash';
        MPS.Pay();
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        List<Payment__c> payments = [select id, name from Payment__c];
       // delete payments;
        MPS.customFlexibleConstructor();
        MPS.paymentType = 'Bank';
        MPS.selAll = true;
        MPS.selectAllOrders();
        MPS.paymentMethodWrapperList[0].sel = true;
        MPS.Pay();
        test.stopTest();         
    }
}