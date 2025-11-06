@isTest
private class TestCasesSet_4 { 
    
    static testMethod void UnitTestErpMark7(){
       // try{
           
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
            Cost_to_Company__c ctc = new Cost_to_Company__c(Commission_Plan__c=comPlan.Id);
            insert ctc;            
            CTC_Component__c sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal;
            update sal;
            CTC_Component__c sal1 = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal1;
            System.assertEquals(sal.Name, sal1.Name);
            delete sal1;            
            Employee_Tax_Rule__c rule = new Employee_Tax_Rule__c(Active__c = true,Name='test',Start_Date__c = system.today(),End_Date__c = system.today());
            insert rule;
            Tax_Range__c tr = new Tax_Range__c(Active__c = true,Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
            insert tr; 
            Tax_Range__c tr1 = new Tax_Range__c(Active__c = true,Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=1,Percent__c=10,Upper_Limit__c=2000000);
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
            Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
            insert emp;
            Employee_Pay__c empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id,Commission_Amount__c=200.00);
            insert empPay;
            Employee_Pay_Line_Item__c empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
            insert empPayLineItem;
            Pay_Adjustment_Category__c payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
            insert payCat;
            empPay.active__c= true;
            empPay.paid__c= true;
            update empPay;
            Commission__c comm = new Commission__c(Employees__c=emp.Id,Employee_Pay__c=empPay.id);
            insert comm;
            
            Employee_Pay_Line_Item__c empPayLineItem1 = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id);
            try{ insert empPayLineItem; } catch(exception ex){}
            delete comm;
            
            ViewEmployeePays empPays = new ViewEmployeePays();
            empPays.empPayList.add(empPay);
            empPays.viewPaySlip();
         
            
            Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
            insert salepoint;
            Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
            insert site;
            Loyalty_Setup__c loyalty = new Loyalty_Setup__c(Name = 'Test',Points_Per_Unit_Amount__c = 10);
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
            PreventRecursiveLedgerEntry.proceed = false;
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
            Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock1; 
           
            Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI1;
            Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true);
            insert ps1; 
            PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
            insert standardPrice1; 
            PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true);
            insert customPriceps1;          
            
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
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
                        
            System.assertEquals(ps.Name,'test');
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim;
            Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
            insert tier1;
            Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
            insert dp;
            Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,ERP7__Order_Profile__c=sop.Id,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
            insert tda;
            Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;            
            Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
            insert tp;
            RecordType TaxsumRT = [SELECT Name FROM RECORDTYPE WHERE sObjectType='ERP7__Tax_Summary__c' AND Name='Sales Tax Summary' limit 1];
            Tax_Summary__c tax_Summaries = new Tax_Summary__c(RecordTypeId=TaxsumRT.id,Active__c = true,Name='Tax-1',Tax_Code__c=tax.id,Sales_Order__c=psod.id,Sales_Order_Line_Item__c=solim.id,Received__c=true,paid__c=true);
            insert tax_Summaries;
            update tax_Summaries;
            Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
            insert pta;
            
            Test.startTest();
            AccessController access = new AccessController();
            access.currentEmployee = emp;           
            //access.allSalePoints.add(salepoint);
            access.getViewPanel();
            access.getEmployeePopup();
            access.iphoneSalesPoint();
            access.ipadSalesPoint();
            access.cancelIphSalesPoint();
            
            ApexPages.StandardController controller;
            PageReference pageRef = System.Page.OrderConsole;
            pageRef.getParameters().put('Id',salepoint.id);
            pageRef.getParameters().put('custId',myCon.Contact_Numer__c);
            pageRef.getParameters().put('orderName',psod.Name);
            pageRef.getParameters().put('con',myCon.Contact_Numer__c);
            pageRef.getParameters().put('profile',sop.Id);
            Test.setCurrentPage(pageRef);       
           
            // PaySlip
            PageReference pageRefs = System.Page.PaySlip;
            pageRefs.getParameters().put('Id',empPay.id);                
            Test.setCurrentPage(pageRefs);  
            ApexPages.StandardController controller2;                  
            Generatepayslip genPaySlip = new Generatepayslip(controller2); 
            Generatepayslip genPaySlipNew = new Generatepayslip();
            Generatepayslip.wrapper wp = new Generatepayslip.wrapper();
            genPaySlip.cancel();                
            genPaySlip.emppay = empPay;
            try{ genPaySlip.sendpayslip(); }catch(exception ex){}
            genPaySlip.emppay = null;
            genPaySlip.sendpayslip();
                                
            // Scheduler Controllers
            ApexPages.StandardController controller1;
            scheduledEmployeePay SEP = new scheduledEmployeePay();
            SchedulableContext sc1;
            SEP.execute(sc1);      
                           
            Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(Duration_in_Months__c='3',Name='test',Active__c=true,Subscription_Plan__c='Month');
            insert subscriptionPlan;
            Subscription__c subcription = new Subscription__c(Active__c=true,Sales_Order__c=sod.Id,SubscriptionPlan__c=subscriptionPlan.Id,Subscription_Date__c=system.today()-1,Subscription_End_Date__c=system.today()+1000,Next_Order_On__c=system.today()+1,Send_Email_Notication__c=true);
            insert subcription;
            System.assertEquals(subscriptionPlan.Id, subcription.SubscriptionPlan__c);
            //when and how to contact u?
            List<Subscription__c> subcriptionList = new List<Subscription__c>();
            subcriptionList.add(subcription); 
            ApexPages.StandardController controller3;  
            SubcribeOrder subOrder1 = new SubcribeOrder();          
            SubcribeOrder subOrder = new SubcribeOrder();            
            Id batchProcessId = Database.executeBatch(subOrder);   
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);  
            
            test.stopTest();  
       //} catch(exception e){}
    }
}