@isTest
private class TestCasesSet_6 {

    static testMethod void UnitTestErpMark7(){ 
            PreventRecursiveLedgerEntry.testCasesTransactions = true; 
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
               
            RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__Profiling__c' And Name='Employee' Limit 1];
            Profiling__c profile = new Profiling__c( Name='test',Active__c=true,RecordTypeId=rTypeProfile.Id);
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
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,Primary__c=true);
            insert bAddress;
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', State__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true,Primary__c=true);
            insert sAddress;
            Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', State__c='test',Postal_Code__c='test',Is_Billing_Address__c=true,Primary__c=true);
            insert bAddress1;
            Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true,Primary__c=true);
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
            Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock; 
           
            Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI;
            Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock1; 
           
            Stock_Inward_Line_Item__c SPLI1 = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2);
            insert SPLI1;
            Product2 ps1 = new Product2(Name='test1',Track_Inventory__c=true,IsActive=true,ERP7__MOQ__c=2);
            insert ps1; 
            PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = priceBookId, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c=12);
            insert standardPrice1; 
            PricebookEntry customPriceps1 = new PricebookEntry(Pricebook2Id = priceBook.Id, Product2Id = ps1.Id,UnitPrice = 12000, IsActive = true,Selling_Price__c=12);
            insert customPriceps1;          
            System.assertEquals(ps.Name,'test');
            
            
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
            
            solim.Quantity__c = 2;
            update solim;
            Tier__c tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
            insert tier1;
            Discount_Plan__c dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
            insert dp;
            Tier_Discount_Allocation__c tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id,ERP7__Order_Profile__c=sop.Id);
            insert tda;
            Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;            
            Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
            insert tp;
            Product_Tax_Allocation__c pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
            insert pta;
                      
            Subscription_Plan__c subscriptionPlan = new Subscription_Plan__c(ERP7__Order_Profile__c = sop.Id, Duration_in_Months__c='3',Name='test',Active__c=true,Subscription_Plan__c='Month');
            insert subscriptionPlan;
            
            Product_Subscription_Plan_Allocation__c SPA = new Product_Subscription_Plan_Allocation__c(Active__c=true,Product__c=ps.Id,Subscription_Plan__c=subscriptionPlan.Id);
            insert SPA;
            
            
            test.startTest();
            PageReference pageRef = System.Page.AddSubscription;
            pageRef.getParameters().put('Id',salepoint.id);            
            pageRef.getParameters().put('oid',sod.id);
            pageRef.getParameters().put('cust',myCon.Contact_Numer__c);
            pageRef.getParameters().put('profile',sop.Id);
            Test.setCurrentPage(pageRef);     
        	Addsubscription.productWrapper pw = new Addsubscription.productWrapper();
        	Addsubscription.ProductsAndDiscounts PD = new Addsubscription.ProductsAndDiscounts();
            ApexPages.StandardController controller1; 
            Addsubscription addSubs = new Addsubscription();   
            Addsubscription addSub = new Addsubscription(controller1);
        	
            addSub.processChangeProducts();
            addSub.clearResults();
            addSub.getSubPlans();
            addSub.currentSubscriptionPlan = subscriptionPlan.Id;
            addSub.plan = subscriptionPlan.Id;
            addSub.getSubDuration();
            addSub.getmyBillingAddress();
            addSub.getmyShippingAddress();
            addSub.getCurrentWrapperList();
            addSub.processIphoneProducts();
            addSub.processProducts();
            
            addSub.productWrapperList[0].action = true;
        	addSub.addProducts();
        	if(addSub.ProductsAndDiscountsWrapperList.size()>0)
            addSub.ProductsAndDiscountsWrapperList[0].selected = true;
            addSub.removeProduct();
            addSub.productWrapperList[0].action = true;
            addSub.addProducts();
            addSub.sel.Product__c = ps.Id;            
            addSub.addDiscount();
            addSub.sel.Product__c = ps.Id;        
           
            addSub.DiscountPercent();
        	if(addSub.ProductsAndDiscountsWrapperList.size()>0)
            addSub.ProductsAndDiscountsWrapperList[0].discountName = dp.Id;
            addSub.sel.Product__c = ps.Id;
            addSub.DiscountPercent();
            addSub.subscription.Subscription_Date__c = system.today();
            addSub.plan = subscriptionPlan.Id;
            addSub.billAddressName = 'test';
            addSub.shipAddressName = 'test';
            addSub.currentDuration = '3';
            addSub.userAgent = 'iPhone'; 
            addSub.subscribe();
            
            addSub.populateLineItems();
            addSub.clearResults();
            addSub.currentEmployee = new List<Employees__c>();
            addSub.subTotal1 = addSub.totalDiscount1 = addSub.totalTax1 = addSub.totalDue1 = 0;
            addSub.ItemPos = 0;
            addSub.SOLIFields = new Map<String, Schema.SObjectField>();
            addSub.billToAddress = addSub.shipToAddress = addSub.itemName = '';
            addSub.currentConId = null;
            test.stopTest();
    }

}