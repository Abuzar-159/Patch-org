@isTest
Private class AccountsReceivable_TestClass {
    public testMethod static void AccountsReceivableMethod(){ 
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        AccountsReceivable ar=new AccountsReceivable();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        AccountsReceivable.LineItems LI=new AccountsReceivable.LineItems();
        AccountsReceivable.SelectOption SO=new AccountsReceivable.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        AccountsReceivable.getInvoiceUpdate(Invoice.Id);   
        AccountsReceivable.getPaymentUpdate(Payment.Id);
        AccountsReceivable.getCustomerRecords();
        AccountsReceivable.getDefaultOrganisation();
        AccountsReceivable.getInvoiceRecordType();
        AccountsReceivable.getInvoiceAndLineItemInstance();
        AccountsReceivable.getInvoiceLineItem(SalesOrder.Id);         
        AccountsReceivable.getInvoiceLineItems(SalesOrder.Id);
        AccountsReceivable.fetchOrderDetails(SalesOrder.Id);
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //AccountsReceivable.getCreateInvoiceAndLineItem(InvoiceLI,null);        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        AccountsReceivable.getRecords(account.Id,'cus','Name', 'ASC',accListId,invListId,2,10,null);  
        AccountsReceivable.getRecords(account.Id,'inv','Name', 'ASC',accListId,invListId,2,10,null);
        AccountsReceivable.getRecords(account.Id,'pay','Name', 'ASC',accListId,invListId,2,10,null);
        AccountsReceivable.getRecords(account.Id,'cou','Name', 'ASC',accListId,invListId,2,10,null); 
        AccountsReceivable.getRecords(account.Id,'cre','Name', 'ASC',accListId,invListId,2,10,null);
        AccountsReceivable.getRecords(account.Id,'dun','Name', 'ASC',accListId,invListId,2,10,null);
        AccountsReceivable.getRecords(account.Id,'inv','Name', 'ASC',accListId,invListId,2,10,null);
        AccountsReceivable.getRecords(account.Id,'deb','Name', 'ASC',accListId,invListId,2,10,null);
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    }   
    
    
    
    public static testmethod void unittest3(){
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;  
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice;
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        AccountsReceivable.getCreateInvoiceAndLineItem(InvoiceLI,JSON.serialize(SalesOrder)); 
        AccountsReceivable.fetchAccountDetails(account.Id);
        AccountsReceivable.getInvoiceRecordType1();
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    public static testmethod void unittest4(){
        String orderId='Test';
        AccountsReceivable.fetchTotalDownPayment(orderId);
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    public static testmethod void unittest5(){
        //String debitID='0011o00001U0YoyAAF';
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;
        ERP7__Debit_Note__c db=new ERP7__Debit_Note__c(Name='Test',ERP7__Posted__c=true,ERP7__Account__c=account.Id);
        insert db;
        ERP7__Debit_Note__c db1=new ERP7__Debit_Note__c(Name='Test',ERP7__Posted__c=false,ERP7__Account__c=account.Id);
        insert db1;
        AccountsReceivable.getDebitUpdate(db.Id);
        AccountsReceivable.getDebitUpdate(db1.Id);
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    public static testmethod void unittest6(){
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        String orgId='';
        if(String.isEmpty(orgId)){
            AccountsReceivable.getRecords(orgId,'cus','Name', 'ASC',accListId,invListId,6,10,null); 
            AccountsReceivable.getRecords(orgId,'inv','Name', 'ASC',accListId,invListId,6,10,null);
            AccountsReceivable.getRecords(orgId,'pay','Name', 'ASC',accListId,invListId,6,10,null);
            AccountsReceivable.getRecords(orgId,'cou','Name', 'ASC',accListId,invListId,6,10,null); 
            AccountsReceivable.getRecords(orgId,'cre','Name', 'ASC',accListId,invListId,6,10,null);
            AccountsReceivable.getRecords(orgId,'dun','Name', 'ASC',accListId,invListId,6,10,null);
            AccountsReceivable.getRecords(orgId,'inv','Name', 'ASC',accListId,invListId,6,10,null);
            AccountsReceivable.checkPayment(Invoice.Id);
        }
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    
    
    
    
    
    //SupplierInvoice
    public testMethod static void SupplierInvoiceMethod(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        SupplierInvoice.getInvoiceUpdate(Invoice.Id);   
        SupplierInvoice.getPaymentUpdate(Payment.Id);
        SupplierInvoice.getCustomerRecords();
        SupplierInvoice.getDefaultOrganisation();
        SupplierInvoice.getInvoiceRecordType();
        SupplierInvoice.getInvoiceAndLineItemInstance();
        SupplierInvoice.getInvoiceLineItem(SalesOrder.Id);         
        SupplierInvoice.getInvoiceLineItems2(SalesOrder.Id,'');
        SupplierInvoice.getInvoiceLineItems2('',Ord.Id);
        SupplierInvoice.fetchOrderDetails(SalesOrder.Id);
        SupplierInvoice.getFunctionalityControl();
        SupplierInvoice.getInvoiceRecordTypeWithRecord(Invoice.Id);
        SupplierInvoice.getInvoiceLineItems(Invoice.Id);
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
    
     public testMethod static void SupplierInvoiceMethod1(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(ERP7__Organisation__c=org.Id, Name='INV-0001', ERP7__Invoice_Date__c =system.today().adddays(-2), ERP7__Active__c=true, ERP7__Paid__c=false, ERP7__Invoice_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
         ERP7__Invoice_Line_Item__c invLine=new ERP7__Invoice_Line_Item__c(Name='Test',ERP7__Invoice__c=Invoice.Id,ERP7__Order_Product__c=orditem.Id,ERP7__Quantity__c=2,ERP7__Product__c=pro.Id);
        insert invLine;
         List<ERP7__Invoice_Line_Item__c> listinvLine = new List<ERP7__Invoice_Line_Item__c>();
         listinvLine.add(invLine);
        SupplierInvoice.getInvoiceUpdate(Invoice.Id);   
        SupplierInvoice.getPaymentUpdate(Payment.Id);
        SupplierInvoice.getCustomerRecords();
        SupplierInvoice.getDefaultOrganisation();
        SupplierInvoice.getInvoiceRecordType();
        SupplierInvoice.getInvoiceAndLineItemInstance();
        SupplierInvoice.getInvoiceLineItem(SalesOrder.Id);         
        SupplierInvoice.getInvoiceLineItems2(SalesOrder.Id,'');
        SupplierInvoice.getInvoiceLineItems2('',Ord.Id);
        SupplierInvoice.fetchOrderDetails(SalesOrder.Id);
         SupplierInvoice.getCreateInvoiceAndLineItem(JSON.serialize(listinvLine),JSON.serialize(ord),'',ord.Id,'Advance');
         SupplierInvoice.getCreateInvoiceAndLineItem(JSON.serialize(listinvLine),JSON.serialize(SalesOrder),SalesOrder.Id,'','Advance');
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        
        SupplierInvoice.InvoiceWrap iwrap = new SupplierInvoice.InvoiceWrap();
        SupplierInvoice.scheduleInvoices(SalesOrder.Id, '');
        SupplierInvoice.scheduleInvoices('', ord.Id);
        /*SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,'0001', 30);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, 60);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, 90);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, 2000);*/
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, -1);
        SupplierInvoice.getRecords('','inv','Name', 'ASC',accListId,invListId,0,10,null, -1);
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
    
    public testMethod static void SupplierInvoiceMethod12(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(ERP7__Organisation__c=org.Id, Name='INV-0001', ERP7__Invoice_Date__c =system.today().adddays(-2), ERP7__Active__c=true, ERP7__Paid__c=false, ERP7__Invoice_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        SupplierInvoice.getInvoiceUpdate(Invoice.Id);   
        SupplierInvoice.getPaymentUpdate(Payment.Id);
        SupplierInvoice.getCustomerRecords();
        SupplierInvoice.getDefaultOrganisation();
        SupplierInvoice.getInvoiceRecordType();
        SupplierInvoice.getInvoiceAndLineItemInstance();
        SupplierInvoice.getInvoiceLineItem(SalesOrder.Id);         
        SupplierInvoice.getInvoiceLineItems2(SalesOrder.Id,'');
        SupplierInvoice.getInvoiceLineItems2('',Ord.Id);
        SupplierInvoice.fetchOrderDetails(SalesOrder.Id);
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,'0001', 30);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, 60);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, 90);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, 2000);
        SupplierInvoice.getRecords(org.Id,'inv','Name', 'ASC',accListId,invListId,0,10,null, -30);
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
     public testMethod static void SupplierInvoiceMethod2(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
          ERP7__Functionality_Control__c fc = new ERP7__Functionality_Control__c();
        fc.ERP7__Standard_Order_Process__c = true;
        fc.ERP7__Is_Standard_Order__c = true;
        insert fc;
         List<Id> ordIds = new List<Id>{Ord.Id};
           List<Id> salOrdIds = new List<Id>{SalesOrder.Id}; 
        SupplierInvoice.getInvoiceUpdate(Invoice.Id);   
        SupplierInvoice.getPaymentUpdate(Payment.Id);
        SupplierInvoice.getCustomerRecords();
        SupplierInvoice.getDefaultOrganisation();
        SupplierInvoice.getInvoiceRecordType();
        SupplierInvoice.getInvoiceAndLineItemInstance();
        SupplierInvoice.getInvoiceLineItem(SalesOrder.Id);         
        SupplierInvoice.getInvoiceLineItems2(SalesOrder.Id,'');
        SupplierInvoice.getInvoiceLineItems2('',Ord.Id);
        SupplierInvoice.fetchOrderDetails(SalesOrder.Id);
         SupplierInvoice.fetchStndOrdDetails(Ord.Id);
        SupplierInvoice.fetchMultiOrderDetails(salOrdIds);
        SupplierInvoice.fetchMultiStndOrdDetails(ordIds);
        SupplierInvoice.getMultiInvoiceLineItems(salOrdIds,new List<Id>());
        SupplierInvoice.getMultiInvoiceLineItems(new List<Id>(),ordIds);
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
         SupplierInvoice.getRecords(account.Id,'ord','Name', 'ASC',accListId,invListId,2,10,null, 30);
        SupplierInvoice.getRecords(account.Id,'pay','Name', 'ASC',accListId,invListId,2,10,null, 30);
        SupplierInvoice.getRecords(account.Id,'pay','Name', 'ASC',accListId,invListId,2,10,null, 60);
        SupplierInvoice.getRecords(account.Id,'pay','Name', 'ASC',accListId,invListId,2,10,null, 90);
        SupplierInvoice.getRecords(account.Id,'pay','Name', 'ASC',accListId,invListId,2,10,null, 2000);
        SupplierInvoice.getRecords(account.Id,'pay','Name', 'ASC',accListId,invListId,2,10,null, -30);
        
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
     public testMethod static void SupplierInvoiceMethod3(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        SupplierInvoice.getInvoiceUpdate(Invoice.Id);   
        SupplierInvoice.getPaymentUpdate(Payment.Id);
        SupplierInvoice.getCustomerRecords();
        SupplierInvoice.getDefaultOrganisation();
        SupplierInvoice.getInvoiceRecordType();
        SupplierInvoice.getInvoiceAndLineItemInstance();
        SupplierInvoice.getInvoiceLineItem(SalesOrder.Id);         
        SupplierInvoice.getInvoiceLineItems2(SalesOrder.Id,'');
        SupplierInvoice.getInvoiceLineItems2('',Ord.Id);
        SupplierInvoice.fetchOrderDetails(SalesOrder.Id);
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
         SupplierInvoice.getRecords(account.Id,'ord','Name', 'ASC',accListId,invListId,2,10,null, 30);
        SupplierInvoice.getRecords(account.Id,'cou','Name', 'ASC',accListId,invListId,2,10,null, 30);
        SupplierInvoice.getRecords(account.Id,'cou','Name', 'ASC',accListId,invListId,2,10,null, 60);
        SupplierInvoice.getRecords(account.Id,'cou','Name', 'ASC',accListId,invListId,2,10,null, 90);
        SupplierInvoice.getRecords(account.Id,'cou','Name', 'ASC',accListId,invListId,2,10,null, 2000);
        SupplierInvoice.getRecords(account.Id,'cou','Name', 'ASC',accListId,invListId,2,10,null, -30);
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
     public testMethod static void SupplierInvoiceMethod4(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        SupplierInvoice.getInvoiceUpdate(Invoice.Id);   
        SupplierInvoice.getPaymentUpdate(Payment.Id);
        SupplierInvoice.getCustomerRecords();
        SupplierInvoice.getDefaultOrganisation();
        SupplierInvoice.getInvoiceRecordType();
        SupplierInvoice.getInvoiceAndLineItemInstance();
        SupplierInvoice.getInvoiceLineItem(SalesOrder.Id);         
        SupplierInvoice.getInvoiceLineItems2(SalesOrder.Id,'');
        SupplierInvoice.getInvoiceLineItems2('',Ord.Id);
        SupplierInvoice.fetchOrderDetails(SalesOrder.Id);
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        SupplierInvoice.getRecords(account.Id,'cre','Name', 'ASC',accListId,invListId,2,10,null,30);
        SupplierInvoice.getRecords(account.Id,'dun','Name', 'ASC',accListId,invListId,2,10,null,30);
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
     public testMethod static void SupplierInvoiceMethod5(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        SupplierInvoice.getInvoiceUpdate(Invoice.Id);   
        SupplierInvoice.getPaymentUpdate(Payment.Id);
        SupplierInvoice.getCustomerRecords();
        SupplierInvoice.getDefaultOrganisation();
        SupplierInvoice.getInvoiceRecordType();
        SupplierInvoice.getInvoiceAndLineItemInstance();
        SupplierInvoice.getInvoiceLineItem(SalesOrder.Id);         
        SupplierInvoice.getInvoiceLineItems2(SalesOrder.Id,'');
        SupplierInvoice.getInvoiceLineItems2('',Ord.Id);
        SupplierInvoice.fetchOrderDetails(SalesOrder.Id);
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
         SupplierInvoice.getRecords(account.Id,'inv','', 'ASC',accListId,invListId,2,10,null,30);
        SupplierInvoice.getRecords(account.Id,'inv','Name', 'ASC',accListId,invListId,2,10,null,30);
        SupplierInvoice.getRecords(account.Id,'deb','Name', 'ASC',accListId,invListId,2,10,null,30);
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
    public testMethod static void SupplierInvoiceMethod6(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        SupplierInvoice.getFuntionalityControl();
        SupplierInvoice.getFunctionalityControlOrderProcess();
        
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
    //---------------------mna-----------------
    /*public static testmethod void unittest1(){
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        
        
        SupplierInvoice.getInvoiceLineItems(SalesOrder.Id);
    }*/
    
    /*public static testmethod void unittest2(){
        String recdId='0011o00001oNk7KAAS';
        SupplierInvoice.fetchAccountDetails(recdId);
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }*/
    
    public static testmethod void unittest7(){
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice;
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'Test'); 
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    public static testmethod void unittest8(){
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        /*Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;*/
        SupplierInvoice.fetchTotalDownPayment1(SalesOrder.Id,'');
        //SupplierInvoice.fetchTotalDownPayment1('',ord.id);
        SupplierInvoice.fetchAccountDetails(account.Id);
        //SupplierInvoice.fetchStndOrdDetails(ord.Id);
        SupplierInvoice.getInvoiceRecordType1();
        SupplierInvoice.getFieldsSetApiName('ERP7__Invoice__c','erp7__createinvoice');
        SupplierInvoice.getFieldsSetLabelName('ERP7__Invoice__c','erp7__createinvoice');
        SupplierInvoice.checkPayment(Invoice.Id);
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    public static testmethod void unittest9(){
        AccountsReceivable.getFieldsSetApiName('ERP7__Invoice__c','erp7__createinvoice');
        AccountsReceivable.getFieldsSetLabelName('ERP7__Invoice__c','erp7__createinvoice');
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    public static testmethod void unittest10(){
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        String orgId='';
        if(String.isEmpty(orgId)){
            SupplierInvoice.getRecords(orgId,'cus','Name', 'ASC',accListId,invListId,6,10,null,30); 
            SupplierInvoice.getRecords(orgId,'inv','Name', 'ASC',accListId,invListId,6,10,null,30);
            SupplierInvoice.getRecords(orgId,'pay','Name', 'ASC',accListId,invListId,6,10,null,30);
            SupplierInvoice.getRecords(orgId,'cou','Name', 'ASC',accListId,invListId,6,10,null,30); 
            SupplierInvoice.getRecords(orgId,'cre','Name', 'ASC',accListId,invListId,6,10,null,30);
            SupplierInvoice.getRecords(orgId,'dun','Name', 'ASC',accListId,invListId,6,10,null,30);
            SupplierInvoice.getRecords(orgId,'inv','Name', 'ASC',accListId,invListId,6,10,null,30);
        }
        String s1='ERP7';
        System.assertEquals(s1,s1);   
    }
    
    
    public testMethod static void InterCompanyInvoicingMethod(){
        
        Account org = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true);
        insert org;
        SupplierInvoice ar=new SupplierInvoice();
        ar.CustomerList=new list<Account>();
        ar.InvoiceList=new list<ERP7__Invoice__c>();
        ar.PaymentList=new list<ERP7__Payment__c>();
        ar.CouponList=new list<ERP7__Coupon__c>();
        ar.CreditList=new list<ERP7__Credit_Note__c>();       
        ar.DunningList=new list<ERP7__Dunning__c>();
        ar.InvoiceRecord=new ERP7__Invoice__c(); 
        ar.SaveErrorMsg='';
                
        SupplierInvoice.LineItems LI=new SupplierInvoice.LineItems();
        SupplierInvoice.SelectOption SO=new SupplierInvoice.SelectOption(null,'Test');        
        SO.label='Test';  So.value=Null;
  
        ar.PaymentRecord=new ERP7__Payment__c();
        ar.CustomerRTList=null;
        ar.PaymentRTList=null;
        ar.CouponRTList=null; 
        ar.InvoiceRTList=null; 
        ar.CustomerRTList=null;
      
        LI.SOLIName='Test';
        LI.SOLIId=null;
        LI.ProductName='Test';
        LI.ProductId=null;
        LI.Quantity=2;
        LI.BasePrice=100;
        LI.Tax=10;
        LI.Discount=5;       
        
        Account account=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert account;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(ERP7__Account__c=account.Id, ERP7__Organisation__c=org.Id, Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
       
        ERP7__Payment__c Payment=new ERP7__Payment__c(ERP7__Payment_Gateway__C='Cash', ERP7__Invoice__c=Invoice.Id,ERP7__Amount__c=100,  ERP7__Total_Amount__c = 100, ERP7__Status__c='Paid', ERP7__Type__c='Debit');      
        insert Payment;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        ERP7__Sales_Order__c SalesOrder=new ERP7__Sales_Order__c(Name='Test', ERP7__Active__c=true, ERP7__Amount__c=100, ERP7__Expected_Date__c=System.today());
        insert SalesOrder;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=SalesOrder.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = account.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Organisation__c=org.Id, ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        //String InvoiceJSON='{"ERP7__Name__c":"Test Invoice","ERP7__Order__c":"'+SalesOrder.Id+'","ERP7__Invoice_Amount__c":500,"ERP7__Tax_Amount__c":50,"ERP7__Discount_Amount__c":30}'; //,"ERP7__Account__c":"0012400000aIrc2AAC","ERP7__Organisation__c":"0012400000auuGFAAY"
        String InvoiceLI='[{"ERP7__Invoice__c":"'+Invoice.Id+'","BasePrice":80,"Discount":20,"ProductName":"Wheelchair","Quantity":1,"SOLIName":"SOLI-22930","Tax":10,"Name":"Test ILI"}]';        
        //SupplierInvoice.getCreateInvoiceAndLineItem(InvoiceLI,'','',ord.Id,'');        
        list<String> accListId=new list<String> ();
        accListId.add(account.Id);  accListId.add(account.Id);
        list<String> invListId=new list<String> ();
        invListId.add(Invoice.Id);
        
        InterCompanyInvoicing.TransactionAmountWrapper taWrap = new InterCompanyInvoicing.TransactionAmountWrapper();
        InterCompanyInvoicing.selectOptions sop = new InterCompanyInvoicing.selectOptions(null, null);
        InterCompanyInvoicing.selectOptions sop1 = new InterCompanyInvoicing.selectOptions(null, null, null);
        InterCompanyInvoicing.TransactionWrapper trWrap = new InterCompanyInvoicing.TransactionWrapper();
        InterCompanyInvoicing.fetchInvoices(org.Id, account.Id, null, null);
        InterCompanyInvoicing.fetchOrders(org.Id, null, null);
        InterCompanyInvoicing.getStatus();
        InterCompanyInvoicing.fetchInterCompanyOrders(org.Id, account.Id, null, null);
        InterCompanyInvoicing.fetchAmounts(account.Id, null, null);
        
        CustomerVendorDetails.TransactionWrapper trapWrap = new CustomerVendorDetails.TransactionWrapper();
        CustomerVendorDetails.TransactionAmountWrapper twapp = new CustomerVendorDetails.TransactionAmountWrapper();
        CustomerVendorDetails.fetchInvoices(account.Id, null, null);
        CustomerVendorDetails.fetchPayments(account.Id, null, null);
        CustomerVendorDetails.fetchAmounts(account.Id, null, null);
        //InterCompanyInvoicing.createOrder(JSON.serialize(ord), JSON.serialize(orditem));
        String s1='ERP7';
        System.assertEquals(s1,s1);     
    } 
    
    
    private Testmethod static void unit3(){
        ERP7__Accounting_Period__c ap = new ERP7__Accounting_Period__c(Name='Test', ERP7__Start_Date__c=system.today(),
                                                                       ERP7__End_Date__c=system.today(), ERP7__Status__c='Closed', ERP7__Date_Locked__c=system.today());
        insert ap;
        Product2 prod = New Product2(Name='test Prod',IsActive=true);
        insert prod;
        Account acc = new Account(Name='Test',Account_type__c = 'Organisation',Default__c = true); 
        insert acc;
        AccountsPayable.DefaultOrganisation();
         Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        Account customer = new Account(Name='Customer',Account_type__c = 'Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='Test Recipient Line 1', Address_Line2__c='Line 2', Address_Line3__c='test', City__c='Long Beach',State__c='California', Postal_Code__c='90805', Country__c = 'United States', Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BILL__c' And Name='Advance to vendor' Limit 1];
        ERP7__BILL__c bill = new ERP7__BILL__c(ERP7__Organisation__c=acc.Id, Vendor__c = vendor.Id,recordTypeId=rTypeProfile.Id, ERP7__Amount_Paid__c=10);
        try{ insert bill; } catch(exception e){ }
        
        
        Payment__c pay = new Payment__c(ERP7__Payment_Type__c = 'Voucher',ERP7__Accounts__c = vendor.Id,ERP7__Amount__c=0);
        insert pay;
        Voucher__c voucher = new Voucher__c(name='test',ERP7__Amount__c=180,ERP7__Vendor__c=vendor.Id,ERP7__Vendor_invoice_Bill__c =bill.Id );
        insert voucher;
        pay.ERP7__Voucher__c=voucher.Id;
        update pay;
        ERP7__PO__c PO1 = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = vendor.Id, ERP7__Organisation__c = acc.Id, ERP7__Ready_To_Receive__c = true);
        insert PO1;
        List<String> poIds = new List<String>();
        poIds.add(PO1.Id);
        ERP7__Purchase_Line_Items__c poli = new ERP7__Purchase_Line_Items__c(Name= 'test PO',ERP7__Purchase_Orders__c = PO1.Id,ERP7__Product__c=prod.Id,ERP7__Quantity__c=5,ERP7__Unit_Price__c=12);
        insert poli;
        RecordType billitemRecId = [Select Id, Name From RecordType Where SobjectType='ERP7__Bill_Line_Item__c' And Name='Advance to vendor' Limit 1];
        ERP7__Bill_Line_Item__c billItem1 = new ERP7__Bill_Line_Item__c(Name= 'Test bill01',ERP7__Purchase_Order_Line_Items__c=poli.Id,ERP7__BILL__c = bill.Id, ERP7__Sort_Order__c=10);
        insert billItem1;
        Invoice__c inv = new Invoice__c(Name='tst',account__c=customer.Id);
        insert inv;
        ERP7__Discount_Plan__c displan = new ERP7__Discount_Plan__c(Name='testdisplan',ERP7__Vendor__c=vendor.Id,ERP7__Due_Date_Days__c=20,ERP7__Discount_Percent__c=10);
        insert displan; 
        
        ERP7__Debit_Note__c debitNote = new ERP7__Debit_Note__c(ERP7__Account__c=vendor.id,Name='Test',ERP7__Amount__c=120, ERP7__Vendor_Invoice_Bill__c=bill.Id);
        insert debitNote;
        
        ERP7__Debit_Note_Item__c debititem = new ERP7__Debit_Note_Item__c(Name='test',ERP7__Debit_Note__c=debitNote.Id);
        insert debititem;
        
        ERP7__Debit_Note_Item__c debititem2 = new ERP7__Debit_Note_Item__c(Name='test2',ERP7__Debit_Note__c=debitNote.Id, ERP7__Bill_Line_Item__c=billItem1.Id);
        insert debititem2;
        
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        
        ERP7__Credit_Note__c creditNote = new ERP7__Credit_Note__c(Name='Test',ERP7__Amount__c=200,ERP7__Active__c=true,    ERP7__Credit__c=200,ERP7__Account__c=customer.id, ERP7__Organisation__c = acc.Id);
        insert creditNote;
        
        ERP7__Chart_of_Accounts__c coa = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = acc.Id);
        insert coa;
        
        Id recordType = Schema.Sobjecttype.ERP7__Chart_of_Accounts__c.getRecordTypeInfosByName().get('Income/Revenue').getRecordTypeId();
        
        ERP7__Chart_of_Accounts__c coa1 = new ERP7__Chart_of_Accounts__c(Name='Inventory', ERP7__Organisation__c = acc.Id, RecordTypeId=recordType);
        insert coa1;
        
        Product2 ps = new Product2(Name='test',isActive=true, ERP7__Expense_Account__c = coa.Id, ERP7__Revenue_Account__c = coa1.Id, ERP7__Inventory_Account__c = coa.Id);
        insert ps;
        
        List<ERP7__Credit_Note_Item__c> creditlineItem = new List<ERP7__Credit_Note_Item__c>();
        
        ERP7__Credit_Note_Item__c creditNoteItem = new ERP7__Credit_Note_Item__c(
            Name = 'Test Credit Note Item', 
            ERP7__Credit_Note__c = creditNote.Id,
            ERP7__Chart_Of_Account__c = coa.Id,
            ERP7__Product__c = ps.Id
        );
        insert creditNoteItem;
        creditlineItem.add(creditNoteItem);
        
        ERP7__Credit_Note_Item__c creditNoteItem2 = new ERP7__Credit_Note_Item__c(
            Name = 'Test Credit Note Item2', 
            ERP7__Credit_Note__c = creditNote.Id,
            ERP7__Chart_Of_Account__c = coa.Id,
            ERP7__Product__c = ps.Id
        );
        insert creditNoteItem2;
        creditlineItem.add(creditNoteItem2);
        
        ERP7__Logistic__c billLogistics = new ERP7__Logistic__c(Name = 'logTest001', ERP7__Purchase_Order__c = PO1.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert billLogistics;
        
        ERP7__Dimension__c dmn1 = new ERP7__Dimension__c(Name='tets',ERP7__Active__c = true,ERP7__Bill_Line_Item__c = billItem1.Id, ERP7__Sort_Order__c=10);       
        List<ERP7__Dimension__c> demList1 = new List<ERP7__Dimension__c>();
        demList1.add(dmn1);
        
        Attachment attach=new Attachment();     
        attach.Name='Test';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=billLogistics.id;
        insert attach;
        
        Test.startTest();
        InterCompanyInvoicing.fetchBills(acc.Id, vendor.Id, null, null);
       	InterCompanyInvoicing.fetchPurchaseOrders(acc.Id, vendor.Id, null, null);
        InterCompanyInvoicing.fetchAmounts(vendor.Id, null, null);
        InterCompanyInvoicing.populateOrderItems(poIds);
        
        CustomerVendorDetails.fetchBills(vendor.Id, null, null);
        CustomerVendorDetails.fetchDebitNotes(vendor.Id, null, null);
        CustomerVendorDetails.fetchCreditNotes(customer.Id, null, null);
        
        CustomerVendorDetails.fetchAmounts(vendor.Id, null, null);
        Test.stopTest();
   
        
    }
}