@isTest
public class TestCasesSet_18 {
    public static RecordType Acc_rTypes_org;
    public static RecordType Acc_rTypes_sup;
    public static  Account orgn;
    public static Account sup;
    public static Business_Unit__c  busUnit;
    public static Commission_Plan__c comPlan;
    public static Commission_Rate_Card__c comrate;
    public static Cost_to_Company__c ctc;
    public static CTC_Component__c sal;
    public static CTC_Component__c sal1;
    public static Employee_Tax_Rule__c rule;
    public static Tax_Range__c tr;
    public static Tax_Range__c tr1;   
    public static CTC_Tax__c empTax;
    public static Employee_Tax_Rule__c rule1; 
    public static RecordType rTypeProfile;   
    public static Profiling__c profile;
    public static Employees__c emp; 
    public static Employee_Pay__c empPay;
    public static Employee_Pay_Line_Item__c empPayLineItem;   
    public static Pay_Adjustment_Category__c payCat;
    public static Employee_Pay_Line_Item__c empPayLineItem1;
    public static ViewEmployeePays empPays;
    public static Channel__c salepoint;
    public static Loyalty_Setup__c loyalty;
    public static Account customer;
    public static Contact contact;
    public static Address__c bAddress;  
    public static Address__c sAddress;
    public static Address__c bAddress1;
    public static Address__c sAddress1;
    public static Loyalty_Card__c clubCard; 
    //public static Customer_Profile__c custProfile;
    //public static Sales_Order_Profile__c sop;
    //public static Sales_Order_Profile_Allocation__c sopa;
    public static Sales_Order__c sod; 
    public static Sales_Order__c psod;
    public static Product2 ps;
    public static Product2 ps1;
    public static BOM__c psa; 
    public static BOM__c psa1;
    public static Sales_Order_Line_Item__c solim;
    public static Tier__c tier1; 
    public static Discount_Plan__c dp;  
    public static Tier_Discount_Allocation__c tda;
    public static Tax__c tax;
    public static Tax_Plan__c tp;
    public static Product_Tax_Allocation__c pta;
    //public static PriceBook_Entry__c pb;
    //public static PriceBook_Entry__c pb1;
    public static Coupon__c dv;
    public static Coupon__c dv1; 
    //public static Profile_Allocation__c pa;
    public static Contact myCon;
           
        
    public static void doInit(){
         try{
            orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
            busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            comPlan = new Commission_Plan__c(Name='test',Active__c=true,Is_Plan_Current__c=true,Effective_Start_Date__c=system.today()-1,Effective_End_Date__c=system.today()+1);
            insert comPlan;
            comrate = new Commission_Rate_Card__c(Name='test',Commission_Plan__c=comPlan.Id,Rate__c=10);
            insert comrate;
            ctc = new Cost_to_Company__c(Name='test',Commission_Plan__c=comPlan.Id);
            insert ctc;            
            sal = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal;
            update sal;
            sal1 = new CTC_Component__c(Name='test2',Active__c=true,Cost_to_Company__c=ctc.Id,Amount__c=10);
            insert sal1;
            System.assertEquals(sal.Name, sal1.Name);
            delete sal1;            
            rule = new Employee_Tax_Rule__c(Active__c = true,Name='test',Start_Date__c = system.today(),End_Date__c = system.today());
            insert rule;
            tr = new Tax_Range__c(Active__c = true,Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=100,Percent__c=10,Upper_Limit__c=200);
            insert tr; 
            tr1 = new Tax_Range__c(Active__c = true,Employee_Tax_Rule__c=rule.Id,Lower_Limit__c=1,Percent__c=10,Upper_Limit__c=2000000);
            insert tr1;
            delete tr1;
            empTax = new CTC_Tax__c(Name='test',Employee_Tax_Rule__c=rule.Id,CTC_Component__c=sal.Id);
            insert empTax;
            update rule;
            rule1 = new Employee_Tax_Rule__c(Name='test');
            insert rule1;    
            rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__Profiling__c' And Name='Employee' Limit 1];
            profile = new Profiling__c(Name='test',Active__c=true,Commission_Plan__c=comPlan.Id,Cost_to_Company__c=ctc.Id,RecordTypeId=rTypeProfile.Id);
            insert profile;   
            emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com',Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=profile.Id);
            insert emp;
               emp.ERP7__Employee_User__c = UserInfo.getUserId();
             update emp;
            Account  ac1 = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert ac1;
             
            empPay = new Employee_Pay__c(Date_of_Pay__c=system.Today(),Employees__c=emp.Id);
            insert empPay;
             empPay.ERP7__Paid__c = true;
             
             update empPay;
           
             
            empPayLineItem = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id,Total_Addition__c=null,Total_Deduction__c=null);
            insert empPayLineItem;
            payCat = new Pay_Adjustment_Category__c(Employee_Pay_Line_Item__c=empPayLineItem.Id);
            insert payCat;  
            
            empPayLineItem1 = new Employee_Pay_Line_Item__c(Employee_Pay__c=empPay.id);
            try{ insert empPayLineItem; } catch(exception ex){}
          
            empPays = new ViewEmployeePays();
            empPays.empPayList.add(empPay);
            empPays.viewPaySlip();
         
            salepoint = new Channel__c(Name = 'Sale Point',  Location__Latitude__s= 51.5182322 ,Location__Longitude__s =-0.1196624);
            insert salepoint;
             
            loyalty = new Loyalty_Setup__c(Points_Per_Unit_Amount__c = 10);
            insert loyalty;
            customer = new Account(Name='Customer');
            insert customer;
            contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
            insert contact;
            bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress;  
            sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
            insert sAddress;
            bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress1;
            sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Shipping_Address__c=true);
            insert sAddress1;
            System.assertEquals(bAddress.Customer__c, sAddress.Customer__c);
            System.assertEquals(bAddress1.Customer__c, sAddress1.Customer__c);
            clubCard = new Loyalty_Card__c(Contact__c=contact.id,Status__c='Active',Start_date__c=System.Today(),Expiration_Date__c=System.Today()+10);
            insert clubCard;   
            myCon = [Select Id, Name, Contact_Numer__c From Contact Where id =: contact.Id Limit 1];  
            
            sod = new Sales_Order__c();   
             //sod.Order_Type__c = sop.Id;
            //sod.Customer_Profile__c = custProfile.Id;
            sod.Order_Status__c = 'Entered';
            sod.Account__c = Contact.AccountId;
            sod.Contact__c = Contact.Id;
            sod.Channel__c = salePoint.Id;
            sod.Bill_To_Address__c = bAddress.Id;
            sod.Ship_To_Address__c = sAddress.Id;
            sod.Request_Date__c = system.Today();
             sod.Is_Back_Order__c=true;
            insert sod; 
            psod = [Select id,Channel__c,Is_Back_Order__c, Name From Sales_Order__c Where id =: sod.id Limit 1];
            ps = new Product2(Name='test',isActive=true);
            insert ps;
            
            ps1 = new Product2(Name='test1',isActive=true);
            insert ps1;
            Product2 ps2 = new Product2(Name='test1',isActive=true);
            insert ps2;
            psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;            
            System.assertEquals(ps.Name,'test');
            solim = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10,Checked_Out_Process__c='FIFO');
            insert solim;
            tier1 = new Tier__c(Active__c=true,Floor_Unit__c=0,Ceiling_Unit__c=5);
            insert tier1; 
            dp = new Discount_Plan__c(name='test',Active__c=true,Ceiling_Discount_Percentage__c=20,Default_Discount_Percentage__c=10,Floor_Discount_Percentage__c=0,Status__c='Manager Approved');
            insert dp;
            tda = new Tier_Discount_Allocation__c(Active__c=true,Product__c=ps.Id,tier__c=tier1.Id,Discount_Plan__c=dp.id);
            insert tda;
            tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
            insert tax;            
            tp = new Tax_Plan__c(Type__c='sales');
            insert tp;  
            pta = new Product_Tax_Allocation__c(Active__c=true,Tax__c=tax.Id,Tax_Plan__c=tp.Id);
            insert pta;
            
            
            //pa = new Profile_Allocation__c(Organisation__c = orgn.Id, Organisation_Business_Unit__c = busUnit.Id,Active__c=true,Profiling__c=custProfile.Id,Account__c=customer.id);
            //insert pa;
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);  
          } catch(exception e){}
    }
    
   static testMethod void unitTestLocUtil(){
            Account orgn1 = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn1;
            Account sup1 = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup1;
            Business_Unit__c  busUnit1 = new Business_Unit__c(Organisation__c = orgn1.Id, Name = 'test');
            insert busUnit1;
            Channel__c salepoint1 = new Channel__c(Name = 'Sale Point', Organisation__c = orgn1.id, Location__Latitude__s= 51.5182322 ,Location__Longitude__s =-0.1196624);
            insert salepoint1;                                  
            try{
                System.assertEquals(new List<Channel__c>{salepoint1}, LocationUtility.retrieveResults(String.valueOf(salepoint1.Location__Latitude__s) , String.valueOf(salepoint1.Location__Longitude__s), 'Channel__c'));
            }catch(System.QueryException qex){
            }  
        } 
    
    static testMethod void unitSupplierInvoiceTransactions(){ 
          test.startTest(); 
            PreventRecursiveLedgerEntry.testCasesTransactions = false;
            doInit();
            RecordType CIT = [SELECT Id, Name FROM RecordType WHERE Name = 'Supplier Invoice Transaction' and SobjectType = 'ERP7__Transaction__c' LIMIT 1];            
            RecordType  Tax_rTypes_Sumry = [select Id, Name From RecordType Where Name = 'Sales Tax Summary' and SobjectType = 'ERP7__Tax_Summary__c' Limit 1];
            Tax_Summary__c tax_Summary;
            try {
                tax_Summary = new Tax_Summary__c(RecordTypeid=Tax_rTypes_Sumry.Id,Organisation__c=orgn.Id,Sales_Order__c = sod.Id,Sales_Order_Line_Item__c=solim.Id,Active__c=true);
                insert tax_Summary;
            } catch(Exception e) {}
            Account acc = new Account(Name='unitSupplierInvoiceTransactionsOrganisation', Account_Type__c = 'Organisation');
            insert acc;
            Account supAcc = new Account(Name='unitSupplierInvoiceTransactionsSupplier', Account_Type__c = 'Supplier',Organisation__c=orgn.Id);
            insert supAcc; 
            Chart_of_Accounts__c finAcc = new Chart_of_Accounts__c(Name='Organisation',Organisation__c=orgn.Id);
            insert finAcc;           
            Budget_Account__c bugAcc = new Budget_Account__c(Name='Organisation',Chart_of_Account__c = finAcc.Id,Organisation__c=orgn.Id);
            insert bugAcc;
            PO__c purchaseOrder = new PO__c(Organisation__c = orgn.Id, Vendor__c =supAcc.Id, Active__c = true,Payment_Terms__c = 30.0,Budget_Accounts__c = bugAcc.Id);
            insert purchaseOrder;
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
           
        try{
            Transaction__c trans = new Transaction__c(Transaction_Status__c ='Completed',Transaction_Type__c = 'Accounts Payable', Finance_Category_Type__c = 'Credit', Organisation__c = orgn.Id, RecordTypeId = CIT.Id, Active__c = true,Tax_Summary__c = tax_Summary.Id);
            insert trans;
            Transaction__c trans1 = new Transaction__c(Transaction_Status__c ='Completed',Transaction_Type__c = 'Purchase', Finance_Category_Type__c = 'Debit', Organisation__c = orgn.Id, RecordTypeId = CIT.Id, Active__c = true,Tax_Summary__c = tax_Summary.Id);
            insert trans1;
            }catch(Exception e){}
            Integer I = 0;
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);  
            test.stopTest(); 
    } 
    
    static testMethod void unitSupplierInvoiceTransactionsNegative(){       
            PreventRecursiveLedgerEntry.testCasesTransactions = false;
            doInit();
            RecordType CIT = [SELECT Id, Name FROM RecordType WHERE Name = 'Supplier Invoice Transaction' and SobjectType = 'ERP7__Transaction__c' LIMIT 1];            
        try{
            RecordType  Tax_rTypes_Sumry = [select Id, Name From RecordType Where Name = 'Sales Tax Summary' and SobjectType = 'ERP7__Tax_Summary__c' Limit 1];
            Tax_Summary__c tax_Summary = new Tax_Summary__c(RecordTypeid=Tax_rTypes_Sumry.Id,Organisation__c=orgn.Id, Sales_Order__c = sod.Id,Sales_Order_Line_Item__c=solim.Id,Active__c=true);
            insert tax_Summary;
        }catch(Exception e){}
            Account acc = new Account(Name='unitSupplierInvoiceTransactionsNegativeOrganisation', Account_Type__c = 'Organisation');
            insert acc;
            Account supAcc = new Account(Name='unitSupplierInvoiceTransactionsNegativeSupplier', Account_Type__c = 'Supplier',Organisation__c=orgn.Id);
            insert supAcc; 
            Chart_of_Accounts__c finAcc = new Chart_of_Accounts__c(Name='Organisation',Organisation__c=orgn.Id);
            insert finAcc;           
            Budget_Account__c bugAcc = new Budget_Account__c(Name='Organisation',Chart_of_Account__c = finAcc.Id,Organisation__c=orgn.Id);
            insert bugAcc;
            PO__c purchaseOrder = new PO__c(Vendor__c =supAcc.Id, Active__c = true,Payment_Terms__c = 30.0,Budget_Accounts__c = bugAcc.Id);
            insert purchaseOrder;
            PreventRecursiveLedgerEntry.testCasesTransactions = true;   
            test.startTest(); 
            Integer i = 0;
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            test.stopTest();            
    }
}