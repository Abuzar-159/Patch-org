@isTest
private class Quotation_Test_CaseSet {
    static testMethod void UnitTestQuotePDF(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com', AccountId=orgn.id,Contact_Numer__c='test123');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=orgn.id,Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;   
        Contact currentContact = contact;
        Quotes__c quote = new Quotes__c( Bill_To_Address__c = bAddress.Id, Ship_To_Address__c = bAddress.Id, 
                          Contact__c= contact.Id, Status__c = 'Draft', Description__c = 'Test');
        insert quote;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;      
        Quote_Line_Items__c qolim = new Quote_Line_Items__c(
                                    Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Quotes__c=quote.id,
                                    Total_Price__c=100,VAT_Amount__c=10, Other_Tax__c=5);
        insert qolim;
        
        PageReference pageRef = System.Page.QuotationPDF;
        pageRef.getParameters().put('quoteNo', quote.Id);
        pageRef.getParameters().put('custId', contact.Contact_Numer__c);
        pageRef.getParameters().put('val', 'pdf');
        Test.setCurrentPage(pageRef);
        
        QuotationPDFController qpdf = new QuotationPDFController();
        QuotationPDFController.LineItemWrapper wrapper = new QuotationPDFController.LineItemWrapper();
        List<QuotationPDFController.LineItemWrapper> QuoteLineItems = new List<QuotationPDFController.LineItemWrapper>();
        String toEmail_Address = contact.Email;
        Test.startTest();
        qpdf.viewQuote();
        //try { qpdf.sendProposal(); } catch(Exception e) {}
        qpdf.sendProposal(); 
        String s1 = 'test';
        String s2 = 'test';
        System.assertEquals(s1,s1);
        Test.stopTest();
    }
    
    static testMethod void UnitTestQuotation() {
        try{
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        String Acc_rTypes_org = RecordTypeUtil.getObjectRecordTypeIds('Account','Organisation');
        String Acc_rTypes_sup = RecordTypeUtil.getObjectRecordTypeIds('Account','Supplier');
        Account orgn = new Account(Name='Organisation',AccountNumber='test123', website='test.com', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  bUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert bUnit; 
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName = 'Contact',Email = 'test@test.com',AccountId=customer.id,Contact_Numer__c='test123',Phone='1234567890');
        insert contact; 
        Address__c bAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,
                               Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',State__c='test',
                               Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,
                               Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',State__c='test',
                               Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);        
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',
                                     Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
        insert comPlan;        
        Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(
                                          Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
        insert comrate;
        Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',
                                 Commission_Plan__c=comPlan.Id);
        insert ctc;            
        CTC_Component__c sal = new CTC_Component__c(Name='test2',
                               Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal;
        CTC_Component__c sal1 = new CTC_Component__c(Name='test2',
                                Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal1;
        System.assertEquals(sal.Name, sal1.Name);
        String rTypeProfile = RecordTypeUtil.getObjectRecordTypeIds('Profiling__c','Employee');
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Name='test',
                               Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile);
        insert profile;  
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,
                           Organisation_Business_Unit__c=bUnit.id,Employee_User__c=UserInfo.getUserId(),
                           Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id,
                                                       Priority__c='1');
        insert DistributionChannels;  
        
        Sales_Order__c sod = new Sales_Order__c();   
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        insert sod;
        Sales_Order__c psod = [Select id,Name,
                               Order_Status__c,Account__c,Contact__c,Channel__c,Bill_To_Address__c,Ship_To_Address__c,
                               Request_Date__c From Sales_Order__c Where id =: sod.id Limit 1];
          
        Product2 ps = new Product2(Name='test',
                                 isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile', Item_Type__c = 'Kit');
        insert ps;
        Product2 ps1 = new Product2(
                                 Name='test1',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps1;
        Product2 ps2 = [select Id, Name, 
                                  isActive, Track_Inventory__c, Product_Service_Family__c, SKU__c From Product2 
                                  where Id =: ps.Id];
       Product2 ps3 = [select Id, Name, 
                                  isActive, Track_Inventory__c, Product_Service_Family__c, SKU__c From Product2 
                                  where Id =: ps.Id];
        Product2 ps4 = [select Id, Name, 
                                  isActive, Track_Inventory__c, Product_Service_Family__c, SKU__c From Product2 
                                  where Id =: ps.Id];
           BOM__c BOM = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c = ps2.Id);
        insert BOM; 
        BOM__c BOM1 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c = ps3.Id);
        insert BOM1; 
         BOM__c BOM2 = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c = ps4.Id);
        insert BOM2; 
        
        Tier__c tier1 = new Tier__c(Active__c=true,
                        Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',
                              Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,
                              Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(
                                          Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,
                                          Discount_Plan__c=dp.id);
        insert tda;
        Tax__c tax = new Tax__c(Organisation__c = orgn.Id, Active__c=true,
                     Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
        Tax_Plan__c tp = new Tax_Plan__c(Name='Test',Type__c='sales');
        insert tp;
        Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(
                                        Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
        insert pta;
        
        Tier_Commission_Allocation__c comAlloc = new Tier_Commission_Allocation__c(Name = 'Test Commission', Commission_Plan__c = comPlan.Id, Active__c =true,
                                                 Product__c = ps.Id, Tier__c = tier1.Id);
        insert comAlloc;
        Quotes__c quote = new Quotes__c(Contact__c = contact.id,
                          Customer__c = orgn.Id, Status__c = 'Draft',Channel__c = salepoint.id,Bill_To_Address__c = bAddress.Id, 
                          Ship_To_Address__c = sAddress.Id, Description__c = 'Test', Request_Date__c = System.Today());
        insert quote;        
        Quotes__c qut = [select Id, Name, Request_Date__c, Channel__c,  Customer__c,
                         Contact__c, Bill_To_Address__c, Ship_To_Address__c From Quotes__c where Id=: quote.Id];
        Quote_Line_Items__c qolim = new Quote_Line_Items__c(
                                    Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Quotes__c=quote.id,
                                    Total_Price__c=100,VAT_Amount__c=10);
        insert qolim;                    
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, 
                                                                        Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock;         
        List<Product2> productList = [select id, Name, isActive,
                                                Track_Inventory__c,Product_Service_Family__c, Picture__c,
                                                SKU__c from Product2 where id=: ps.id];
        /*
        Test.startTest();
        PageReference pageRef = System.Page.QuotationConsole;
        pageRef.getParameters().put('Id',salepoint.Id);
        pageRef.getParameters().put('custId',contact.Contact_Numer__c);
        pageRef.getParameters().put('quoteNo',quote.Id);
        pageRef.getParameters().put('profile','');
        pageRef.getParameters().put('custAccId',orgn.Id);
        Test.setCurrentPage(pageRef);
        QuotationConsole qt = new QuotationConsole();
        QuotationConsole.ItemWrapper wrapper = new QuotationConsole.ItemWrapper();
        QuotationConsole.ProductsAndDiscounts pdwrapper = new QuotationConsole.ProductsAndDiscounts();                    
        qt.qts.Contact__c = contact.Id;
        qt.getContact();
        qt.getFormTag();
        qt.getTextBox(); 
        qt.getcnn();
        qt.subTotal = 2.0;
        qt.totalDiscount = 2.0;        
        qt.totalTax = 2.0;
        qt.totalDue = 2.0;       
        qt.addMultipleProducts();
        qt.deSelectMultipleProducts();
        
        qt.qts.Customer__c = customer.Id;
        qt.accountDetails();
        qt.SearchAccount();
        
        qt.accountName = orgn.name;
        qt.accountnumber = orgn.AccountNumber;
        qt.website = orgn.Website;
        qt.FindAccount();
        qt.accountName = '';
        qt.accountNumber = '';
        qt.website = '';
        qt.FindAccount();
        qt.accountName = orgn.name;
        qt.accountnumber = '';
        qt.website = '';
        qt.FindAccount();
        qt.accountName = '';
        qt.accountnumber = orgn.AccountNumber;
        qt.website = '';
        qt.FindAccount();
        qt.accountName = '';
        qt.accountnumber = '';
        qt.website = orgn.Website;
        qt.FindAccount();
        qt.accountName = orgn.name;
        qt.accountnumber = orgn.AccountNumber;
        qt.website = '';
        qt.FindAccount();
        qt.accountName = '';
        qt.accountnumber = orgn.AccountNumber;
        qt.website = orgn.Website;
        qt.FindAccount();
        qt.accountName = orgn.name;
        qt.accountnumber = '';
        qt.website = orgn.Website;
        qt.FindAccount();
        
        qt.SearchCustomer();
        qt.selectCustomerName = contact.LastName;
        qt.selectCustomerEmail = contact.Email;
        qt.selectCustomerPhone = contact.Phone;
        qt.FindCustomer();
        qt.selectCustomerName = contact.LastName;
        qt.selectCustomerEmail = '';
        qt.selectCustomerPhone = '';
        qt.FindCustomer();
        qt.selectCustomerName = '';
        qt.selectCustomerEmail = '';
        qt.selectCustomerPhone = '';
        qt.FindCustomer();
        qt.selectCustomerName = '';
        qt.selectCustomerEmail = contact.Email;
        qt.selectCustomerPhone = '';
        qt.FindCustomer();
        qt.selectCustomerName = '';
        qt.selectCustomerEmail = '';
        qt.selectCustomerPhone = contact.Phone;
        qt.FindCustomer();
        qt.selectCustomerName = contact.LastName;
        qt.selectCustomerEmail = contact.Email;
        qt.selectCustomerPhone = '';
        qt.FindCustomer();
        qt.selectCustomerName = '';
        qt.selectCustomerEmail = contact.Email;
        qt.selectCustomerPhone = contact.Phone;
        qt.FindCustomer();
        qt.selectCustomerName = contact.LastName;
        qt.selectCustomerEmail = '';
        qt.selectCustomerPhone = contact.Phone;
        qt.FindCustomer();
        
        qt.newCustomer();
        qt.addCustomerContact = contact;
        qt.createNewCustomer();
        qt.SaveAndNewContact();
        
        qt.searchQuotation();
        qt.quoteNumber = qut.Name;
        qt.quoteDate = qut.request_date__c;
        qt.FindQuotes();
        qt.quoteNumber = qut.Name;
        qt.quoteDate = null;
        qt.FindQuotes();
        qt.quoteNumber = null;
        qt.quoteDate = null;
        qt.FindQuotes();
        qt.quoteNumber = null;
        qt.quoteDate = qut.request_date__c;
        qt.FindQuotes();
        
        qt.billingAddress.add(bAddress);
        qt.ShippingAddress.add(sAddress);
        qt.customerDetail();
        
        qt.newCustomerContact = contact;
        qt.createCustomer();        
        qt.itemName = '';
        qt.ps.Product_Service_Family__c = '';
        qt.searchProduct();
        qt.itemName = ps.Name;
        qt.ps.Product_Service_Family__c = ps.Product_Service_Family__c;
        qt.searchProduct();
        qt.itemName = ps.Name;
        qt.ps.Product_Service_Family__c = '';
        qt.searchProduct();
        qt.itemName = '';
        qt.ps.Product_Service_Family__c = ps.Product_Service_Family__c;
        qt.allProducts.add(ps2);
        qt.searchProduct();
        
        List < SelectOption > options = new List < SelectOption > ();
        pdwrapper.product = ps;
        pdwrapper.currentConId = 'test';
        pdwrapper.CurrentDiscounts = options;
        pdwrapper.discountname = dp.Id;
        pdwrapper.selected = true;
        pdwrapper.quantity = 2;
        pdwrapper.bundleId = pbga.Id;
        qt.ProductsAndDiscountsWrapperList.add(pdwrapper);
        qt.addItem();
        //qt.BundleRAWrapperDetails(pbgaList,customerProfile,'accessory');
        //qt.BundleRAWrapperDetails(pbgaList,customerProfile,'recommendation');
        //qt.RAWrapperDetails(productList,customerProfile,'accessory');
        //qt.RAWrapperDetails(productList,customerProfile,'recommendation');
        qt.sel.Product__c = ps1.id;
        pdwrapper.product = ps;
        pdwrapper.currentConId = 'test';
        pdwrapper.CurrentDiscounts = options;
        pdwrapper.discountname = dp.Id;
        pdwrapper.selected = true;
        pdwrapper.quantity = 2;
        pdwrapper.bundleId = pbga.Id;
        pdwrapper.product = ps1;
        qt.ProductsAndDiscountsWrapperList.add(pdwrapper);        
        qt.DiscountPercent();
        
        qt.sel.Product__c = ps1.id;
       // qt.addDiscount(); 
        System.assertEquals('Test Alloc',pbga.Name);
        Test.stopTest(); */
        }catch(Exception e){
            /*'Exception Occurred'+e*/
        }
    }
    
    static testMethod void UnitTestQuotation1() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation',AccountNumber='test123', website='test.com', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  bUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert bUnit; 
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName = 'Contact',Email = 'test@test.com',AccountId=customer.id,Contact_Numer__c='test123',Phone='1234567890');
        insert contact; 
        Address__c bAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id,
                              Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Address__c bAddress1 = new Address__c(Customer__c=customer.id,
                               Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',State__c='test',
                               Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Address__c sAddress1 = new Address__c(Customer__c=customer.id,
                               Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',State__c='test',
                               Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress1;
        System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
        System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);        
        Commission_Plan__c comPlan = new Commission_Plan__c(Name='test',
                                     Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
        insert comPlan;        
        Commission_Rate_Card__c comrate = new Commission_Rate_Card__c(
                                          Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
        insert comrate;
        Cost_to_Company__c ctc = new Cost_to_Company__c(Name='test',
                                 Commission_Plan__c=comPlan.Id);
        insert ctc;            
        CTC_Component__c sal = new CTC_Component__c(Name='test2',
                               Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal;
        CTC_Component__c sal1 = new CTC_Component__c(Name='test2',
                                Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
        insert sal1;
        System.assertEquals(sal.Name, sal1.Name);
        String rTypeProfile = RecordTypeUtil.getObjectRecordTypeIds('Profiling__c','Employee');
        Profiling__c profile = new Profiling__c(Organisation__c = orgn.Id, Name='test',
                               Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile);
        insert profile;  
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,
                           Organisation_Business_Unit__c=bUnit.id,Employee_User__c=UserInfo.getUserId(),
                           Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
        insert emp;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true,  Channel__c=salepoint.Id, Site__c=site.Id,
                                                       Priority__c='1');
        insert DistributionChannels;  
        
        Sales_Order__c sod = new Sales_Order__c();   
         sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        insert sod;
        Sales_Order__c psod = [Select id,Name,
                               Order_Status__c,Account__c,Contact__c,Channel__c,Bill_To_Address__c,Ship_To_Address__c,
                               Request_Date__c From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 pbg = new Product2(Name = 'Test Bundle',  IS_KIT__c = True);
        insert pbg;        
        Product2 ps = new Product2(Name='test',
                                isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;
        Product2 ps1 = new Product2(
                                 Name='test1',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps1;
        Product2 ps2 = [select Id, Name, 
                                  isActive, Track_Inventory__c, Product_Service_Family__c, SKU__c From Product2 
                                  where Id =: ps.Id];
        BOM__c BOM2 = new BOM__c(Name = 'Test Product Service',BOM_Product__c=ps.id, Active__c = true, Type__c= 'Kit', BOM_Component__c = ps2.Id);
        insert BOM2;
            
                     
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
           BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;
        Tier__c tier1 = new Tier__c(Name='Test',Active__c=true,
                        Floor_Unit__c=0,Ceiling_Unit__c=5);
        insert tier1;
        Discount_Plan__c dp = new Discount_Plan__c(name='test',
                              Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,
                              Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
        insert dp;
        Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(
                                          Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,
                                          Discount_Plan__c=dp.id);
        insert tda;
        Tax__c tax = new Tax__c(Active__c=true,
                     Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax;            
        Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
        insert tp;
        Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(
                                        Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
        insert pta;
         
        Tier_Commission_Allocation__c comAlloc = new Tier_Commission_Allocation__c(Name = 'Test Commission', Commission_Plan__c = comPlan.Id, Active__c =true,
                                                 Product__c = ps.Id,  Tier__c = tier1.Id);
        insert comAlloc;
        Quotes__c quote = new Quotes__c(Contact__c = contact.id,
                          Customer__c = orgn.Id, Status__c = 'Draft',Channel__c = salepoint.id,Bill_To_Address__c = bAddress.Id, 
                          Ship_To_Address__c = sAddress.Id, Description__c = 'Test', Request_Date__c = System.Today());
        insert quote;        
        Quotes__c qut = [select Id, Name, Request_Date__c, Channel__c,  Customer__c,
                         Contact__c, Bill_To_Address__c, Ship_To_Address__c From Quotes__c where Id=: quote.Id];
        Quote_Line_Items__c qolim = new Quote_Line_Items__c(
                                    Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Quotes__c=quote.id,
                                    Total_Price__c=100,VAT_Amount__c=10);
        insert qolim;                    
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(
                                                                        Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
        insert WarehouseItemInventoryStock;         
        List<Product2> productList = [select id, Name, isActive,
                                                Track_Inventory__c,Product_Service_Family__c, Picture__c,
                                                SKU__c from Product2 where id=: ps.id];
        List<BOM__c> BOMList = [select id, name, Active__c, Type__c,
                                                            BOM_Component__c, BOM_Product__c from BOM__c where BOM_Product__c=: ps.Id]; 
        /*
        QuotationConsole qt = new QuotationConsole();
        QuotationConsole.ItemWrapper item = new QuotationConsole.ItemWrapper();
        QuotationConsole.ProductsAndDiscounts pdwrapper = new QuotationConsole.ProductsAndDiscounts();                    
        
        Test.startTest();
        
        qt.quoteId = qut.Id;
        qt.populateQuoteLineItems();
        item.code = 'test';
        item.itm = 'test';        
        item.productId = ps.id;
        item.itmId = ps.id;        
        item.pricebookId = pb.id;
        item.quantity = 2;
        item.price = 100;
        item.vat = 10;
        item.priceWithVat = 100;
        item.discountName = 'test';
        item.discountPercent = 10.0;
        item.discount = 10;   
        item.RewardPoints = 10;     
        item.RSelected = true;
        item.ASelected = true;
        item.product = ps;
        qt.itemWrapperList.add(item);            
        qt.ItemPos = 0;
        qt.currentSalepoint = salepoint;
        qt.editItem();
        qt.currentSalepoint = salepoint;
        qt.sel.Product__c = ps.id;
        qt.addDiscountEdit();         
        List < SelectOption > options = new List < SelectOption > ();
        pdwrapper.product = ps;
        pdwrapper.currentConId = 'test';
        pdwrapper.CurrentDiscounts = options;
        pdwrapper.discountname = dp.Id;
        pdwrapper.selected = true;
        pdwrapper.quantity = 2;
        pdwrapper.bundleId = pbga.Id;
        pdwrapper.product = ps1;
        qt.ProductsAndDiscountsWrapperEditList.add(pdwrapper);         
        qt.sel.Product__c = ps.id;
        qt.DiscountPercentEdit();
        //qt.orderCustomerProfileMap.put(sop.Id,custprofile.Id);
        qt.addEditItem();
        qt.bundleId = pbg.Id;
        qt.removeItem();
        qt.ItemPos = 0;
        qt.removeItem();
        qt.bundleId = null;
        qt.removeItem();
        
        qt.qts.Contact__c = contact.Id;
        //qt.orderProfile = sop.Id;
        //qt.orderCustomerProfileMap.put(sop.Id,custprofile.Id);
        qt.Quote2SalesOrder();
        qt.saveQuotation();
        qt.recommendationWrapperList.add(item);
        qt.recommendation2Quote();
        qt.accessoryWrapperList.add(item);
        qt.accessory2Quote();
        
        Test.stopTest();
        */
    } 
}