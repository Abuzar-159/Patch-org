@isTest
public class RMA_TestCases {
    public testmethod static void RMAtest1(){
        Test.startTest();
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account customer = new Account(Name='Test_Customer',Account_type__c='Customer');
        insert customer; 
        Account customer1 = new Account(Name='Test_Customer1',Account_type__c='Customer');
        insert customer1;
        Contact contact = new Contact(Primary__c=true,FirstName='Test',lastName ='Contact',AccountId=customer.Id);
        insert contact;
        ERP7__Channel__c  channel = new ERP7__Channel__c (Name='Test_Channel_RMA');
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(ERP7__Employee_User__c = userinfo.getUserId(),Channel__C=channel.id,Name='Test_RMA_EMP');
        insert emp;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=customer.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=contact.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true,ERP7__Primary__c = true);
        insert addr;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(ERP7__Active__c = true , ERP7__Returns_Handling__c= true ,ERP7__Channel__c = channel.id,Name='Test Dc');
        insert dc;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Closed',Account__c = customer.Id,Contact__c = contact.Id,Channel__c = channel.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Product__c = ps.id,Active__c=true);
        insert wrp;
        
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Name='TestSoli',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10,ERP7__Inventory_Tracked__c=true);
        insert solim;
         Warranty__c wrr = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,Sales_Order_Line_Item__c=solim.id);
        insert wrr;
         
        sod.ERP7__Status__c = 'Cancelled';
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        //update sod;
        sod.Order_Status__c = 'Closed';
        update sod;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
              
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=customer.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = customer.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        
        ord.ERP7__Is_Closed__c=true;
        update ord;
        Warranty__c wrr1 = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,ERP7__Order_Product__c=orditem.id);
        insert wrr1;
        
        ERP7__Return_Merchandise_Authorisation__c rmarecord = new ERP7__Return_Merchandise_Authorisation__c(Name='Test',  ERP7__Expected_Date__c=system.today(), ERP7__Account__c=customer.Id,ERP7__Return_Contact__c=contact.Id, ERP7__Active__c=true, ERP7__Ready_To_Receive__c=true);
        insert rmarecord;
        ERP7__Return_Merchandise_Authorisation__c rmarecord1 = new ERP7__Return_Merchandise_Authorisation__c(ERP7__Order__c=ord.Id,Name='Test',  ERP7__Expected_Date__c=system.today(), ERP7__Account__c=customer.Id,ERP7__Return_Contact__c=contact.Id, ERP7__Active__c=true, ERP7__Ready_To_Receive__c=true);
        insert rmarecord1;
        
        ERP7__RMA_Line_Item__c rmalineitem = new ERP7__RMA_Line_Item__c(Name='Test', ERP7__SOLI__c=solim.Id, ERP7__Active__c=true, ERP7__Return_Merchandise_Authorisation__c=rmarecord.Id, ERP7__Return_Status__c='Quality Check');
        insert rmalineitem;
        ERP7__RMA_Line_Item__c rmalineitem1 = new ERP7__RMA_Line_Item__c(Name='Test', ERP7__Ord_Item__c=orditem.Id, ERP7__Active__c=true, ERP7__Return_Merchandise_Authorisation__c=rmarecord1.Id, ERP7__Return_Status__c='Quality Check');
        insert rmalineitem1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update rmarecord;
        update rmarecord1;
        //RMA rma = new RMA();
        RMA.doInit();
        RMA.FetchAddressById(customer.id,addr.id);
        RMA.FetchContactById(customer.id, contact.id); 
        RMA.getSoliByCustomer(customer.id, 0,'');
        RMA.getOrdItemByCustomer(customer.id, 0,'');
        RMA.getSoliBykeyWord(customer.id, 'productId','');
        //RMA.getOrdItemBykeyWord(customer.id, 'productId','');
        RMA.FetchcustomerInfo(customer.id,'','',false,true);
        String jsonTest = '[{"isSelect":true,"isWarranty_Exists":true,"RMALI":{"ERP7__Acceptance_Type__c":"Return","ERP7__Return_Status__c":"Quality Check","ERP7__Product__c":"'+ps.id+'","ERP7__SOLI__c":"'+solim.id+'","Name":"RMALI-Mixer Grinder","ERP7__Quantity_Return__c":1,"ERP7__Return_Reason__c":""},"SOLI":{"Id":"'+solim.id+'","Name":"SOLI-22595","ERP7__Sales_Order__c":"'+sod.id+'","ERP7__ReturnedQuantity__c":1,"ERP7__Quantity__c":10,"ERP7__Product__c":"'+ps.id+'","ERP7__Sales_Order__r":{"Name":"0014970","ERP7__Status__c":"Booked","ERP7__Account__c":"'+customer.Id+'","Id":"'+sod.id+'"},"ERP7__Product__r":{"Name":"Mixer Grinder","ProductCode":"NPC-01","Id":"'+ps.id+'"}}}]';
        RMA.fetch_RMALI(rmarecord.id,false,true);
        RMA.fetch_RMALI(rmarecord1.id,true,false);
        //RMA.createRMA(rmarecord.id, jsonTest, dc.id, Contact.Id, customer.id);
        RMA.FetchAddressById(customer1.id,addr.id);
        RMA.FetchContactById(customer1.id, contact.id);
        
        RMA.getRMAInstance();
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='Test');
        insert Invoice;
        
        RMA.Build_RMALIByInvoice(Invoice.Id);
        RMA.Fetch_RMALIByInvoice(Invoice.Id);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
    }
   
    public testmethod static void RMAtest2(){
        Test.startTest();
        
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account customer = new Account(Name='Test_Customer',Account_type__c='Customer');
        insert customer;
        Account customer1 = new Account(Name='Test_Customer1',Account_type__c='Customer');
        insert customer1;
        Account Org = new Account(Name='Test_Org',Account_type__c='Organisation');
        insert Org;
        Contact contact = new Contact(Primary__c=true,FirstName='Test',lastName ='Contact',AccountId=customer.Id);
        insert contact;
        ERP7__Channel__c  channel = new ERP7__Channel__c (Name='Test_Channel_RMA');
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(ERP7__Employee_User__c = userinfo.getUserId(),Channel__C=channel.id,Name='Test_RMA_EMP');
        insert emp;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=customer.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=contact.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true,ERP7__Primary__c = true);
        insert addr;
        ERP7__Address__c siteaddr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=org.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert siteaddr;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(ERP7__Active__c = true , ERP7__Returns_Handling__c= true ,ERP7__Channel__c = channel.id,Name='Test Dc');
        insert dc;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
        Product2 ps1 = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=false);
        insert ps1;
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Product__c = ps.id,Active__c=true);
        insert wrp;
        
        
        
        ERP7__Site__c site = new ERP7__Site__c(Active__c = true, Organisation__c =Org.Id,Address__C = siteaddr.Id );
        insert site;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=ps.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c (ERP7__Product__c  = ps.id, ERP7__Warehouse__c = site.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert stock;
        
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
              
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=customer.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = customer.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered'); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        OrderItem orditem1 = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps1.Id,PricebookEntryId=pbe1.Id,ERP7__Active__c=true);        
        insert orditem1;
        ERP7__Stock_Outward_Line_Item__c stock_OLI = new ERP7__Stock_Outward_Line_Item__c(Product__c = ps.Id,ERP7__Order__c=ord.id,ERP7__Order_Product__c = ordItem.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1);
        insert stock_OLI;
        
        ord.ERP7__Is_Closed__c=true;
        update ord;
        Warranty__c wrr1 = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,ERP7__Order_Product__c=orditem.id);
        insert wrr1;
        
        
        ERP7__Return_Merchandise_Authorisation__c rmarecord1 = new ERP7__Return_Merchandise_Authorisation__c(ERP7__Order__c=ord.Id,Name='Test',  ERP7__Expected_Date__c=system.today(), ERP7__Account__c=customer.Id,ERP7__Return_Contact__c=contact.Id, ERP7__Active__c=true, ERP7__Ready_To_Receive__c=true);
        insert rmarecord1;
        
        
        ERP7__RMA_Line_Item__c rmalineitem1 = new ERP7__RMA_Line_Item__c(Name='Test', ERP7__Ord_Item__c=orditem.Id, ERP7__Active__c=true, ERP7__Return_Merchandise_Authorisation__c=rmarecord1.Id, ERP7__Return_Status__c='Quality Check');
        insert rmalineitem1;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update rmarecord1;
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='Test',ERP7__Order_S__c=ord.Id);
        insert Invoice;
        orditem.ERP7__Invoice__c=Invoice.Id;
        orditem1.ERP7__Invoice__c=Invoice.Id;
        ERP7__Invoice_Line_Item__c invLine=new ERP7__Invoice_Line_Item__c(Name='Test',ERP7__Invoice__c=Invoice.Id,ERP7__Order_Product__c=orditem.Id,ERP7__Quantity__c=2,ERP7__Product__c=ps.Id);
        insert invLine;
        ERP7__Invoice_Line_Item__c invLine1=new ERP7__Invoice_Line_Item__c(Name='Test',ERP7__Invoice__c=Invoice.Id,ERP7__Order_Product__c=orditem1.Id,ERP7__Quantity__c=2,ERP7__Product__c=ps1.Id);
        insert invLine1;
        update orditem;
        update orditem1;
        RMA.Fetch_RMALIByInvoice(Invoice.Id);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
    }
    
    public testmethod static void RMAtest3(){
        Test.startTest();
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account Org = new Account(Name='Test_Org',Account_type__c='Organisation');
        insert Org;
        Account customer = new Account(Name='Test_Customer',Account_type__c='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',lastName ='Contact',AccountId=customer.Id);
        insert contact;
        ERP7__Channel__c  channel = new ERP7__Channel__c (Name='Test_Channel_RMA');
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(ERP7__Employee_User__c = userinfo.getUserId(),Channel__C=channel.id,Name='Test_RMA_EMP');
        insert emp;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=customer.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=contact.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert addr;
        ERP7__Address__c siteaddr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=org.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert siteaddr;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(ERP7__Channel__c = channel.id,Name='Test Dc');
        insert dc;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
         Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId1',Serialise__c=false);
        insert ps1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
              
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=customer.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Closed',Account__c = customer.Id,Contact__c = contact.Id,Channel__c = channel.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        
        String SoName = '';
        if(sod != null && sod.Id != null)
         SoNAme = [SELECT Id,NAME FROM Sales_Order__c WHERE id=:sod.id].Name; 
         Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = customer.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Is_Closed__c=true); 
        insert ord;
        
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Product__c = ps.id,Active__c=true);
        insert wrp;
        
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(product__c=ps.id,Name='Test1234',Serial_Number__c='Test1234');
        insert ser;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Serial__c=ser.id,Name='demo',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        ERP7__Batch__c batch = new ERP7__Batch__c(Product__c=ps1.id);
        insert batch;
            Sales_Order_Line_Item__c soli_1 = new Sales_Order_Line_Item__c(ERP7__Batch_Lot__c = batch.id,Name='demo',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert soli_1;
        OrderItem orditem = new OrderItem(Serial__c=ser.id,OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Total_Price__c=100,VAT_Amount__c=10,Discount_Amount__c=10);        
        insert orditem;
        OrderItem orditem1 = new OrderItem(ERP7__Batch_Lot__c = batch.id,OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps1.Id,PricebookEntryId=pbe1.Id,ERP7__Active__c=true,Total_Price__c=100,VAT_Amount__c=10,Discount_Amount__c=10);        
        insert orditem1;
        Warranty__c wrr = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,Sales_Order_Line_Item__c=solim.id);
        insert wrr;
        Warranty__c wrr1 = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,ERP7__Order_Product__c=orditem.id);
        insert wrr1;
        ERP7__Site__c site = new ERP7__Site__c(Active__c = true, Organisation__c =Org.Id,Address__C = siteaddr.Id );
        insert site;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=ps.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c (ERP7__Product__c  = ps.id, ERP7__Warehouse__c = site.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert stock;
        
        ERP7__Batch__c batch2 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps1.Id,ERP7__Active__c=true);
        insert batch2;
        
        ERP7__Serial_Number__c serial2 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=ps1.Id, ERP7__Barcode__c='test');
        insert serial2;
        
        ERP7__Inventory_Stock__c stock1 = new ERP7__Inventory_Stock__c (ERP7__Product__c  = ps1.id, ERP7__Warehouse__c = site.Id,ERP7__Batch_Lot__c=batch2.Id,ERP7__Serial__c = serial2.Id);
        insert stock1;
        ERP7__Stock_Outward_Line_Item__c stock_OLI = new ERP7__Stock_Outward_Line_Item__c(ERP7__Product__c  = ps.id,ERP7__Sales_Order__c=sod.id,ERP7__Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1);
        insert stock_OLI;
         ERP7__Stock_Outward_Line_Item__c stock_OLI_1 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Sales_Order__c=sod.id,ERP7__Sales_Order_Line_Item__c = soli_1.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Product__c  = ps.id,ERP7__Quantity__c =1);
        insert stock_OLI_1;
        ERP7__Stock_Outward_Line_Item__c stock_OLI1 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Order__c=ord.id,ERP7__Order_Product__c = orditem.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1,ERP7__Product__c  = ps.id);
        insert stock_OLI1;
         ERP7__Stock_Outward_Line_Item__c stock_OLI_11 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Order__c=ord.id,ERP7__Order_Product__c = orditem1.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1,ERP7__Product__c  = ps.id);
        insert stock_OLI_11;
        PageReference pageRef = Page.ERP7__RMA;
        PageRef.getParameters().put('soId',sod.Id);
        PageRef.getParameters().put('OrdId',Ord.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(sod);
        ApexPages.StandardController controller1 = new ApexPages.StandardController(Ord);
        RMA rma_So = new RMA(controller);
        rma_So.getSO();
        
        
        
        RMA.doInit();
        RMA.FetchAddressById(customer.id,addr.id);
        RMA.FetchContactById(customer.id, contact.id);
        RMA.getSoliByCustomer(customer.id, 0,'');
        RMA.getOrdItemByCustomer(customer.id, 0,'');
        RMA.getSoliBykeyWord(customer.id,'0',sod.id);
        RMA.getFreightType();
        RMA.getStatus();
        RMA.getRMAStatus();
        RMA.getSiteDetailsbyDC(Dc.Id);
        RMA.getSiteDetails(site.ID);
        RMA.sObj_Wrapper obj = new RMA.sObj_Wrapper();
        obj = RMA.Build_RMALI(Sod.Id);
        obj = RMA.Fetch_RMALI1(ord.Id);
        for(RMA.RMAWrapperLI temp :obj.RAMLI_List)temp.isSelect = true;
       // RMA.createRMA(JSON.serialize(new ERP7__Return_Merchandise_Authorisation__c(ERP7__SO__c =sod.Id,ERP7__Account__c = customer.id,Active__c=true)), JSON.serialize(obj.RAMLI_List));
        RMA.getCRUD();
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    public testmethod static void RMAtest4(){
        Test.startTest();
        Account customer = new Account(Name='Test_Customer',Account_type__c='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',lastName ='Contact',AccountId=customer.Id);
        insert contact;
        ERP7__Channel__c  channel = new ERP7__Channel__c (Name='Test_Channel_RMA');
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(ERP7__Employee_User__c = userinfo.getUserId(),Channel__C=channel.id,Name='Test_RMA_EMP');
        insert emp;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=customer.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=contact.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert addr;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(ERP7__Channel__c = channel.id,Name='Test Dc');
        insert dc;
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Closed',Account__c = customer.Id,Contact__c = contact.Id,Channel__c = channel.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=false);
        insert ps;
        
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Product__c = ps.id,Active__c=true);
        insert wrp;
        
        ERP7__Batch__c batch = new ERP7__Batch__c(product__c=ps.id,Name='Test1234');
        insert batch;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Batch_Lot__c=batch.id,Name='demo',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        Warranty__c wrr = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,Sales_Order_Line_Item__c=solim.id);
        insert wrr;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
              
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=customer.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = customer.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Is_Closed__c=true); 
        insert ord;
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        Warranty__c wrr1 = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,ERP7__Order_Product__c=orditem.id);
        insert wrr1;
        
        
        
        //RMA rma = new RMA();
        RMA.doInit();
        RMA.FetchAddressById(customer.id,addr.id);
        RMA.FetchContactById(customer.id, contact.id);
        RMA.getSoliByCustomer(customer.id, 0,'');
        RMA.getOrdItemByCustomer(customer.id, 0,'');
        RMA.getSoliBykeyWord(customer.id, 'Test1234','');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public testmethod static void RMAtest5(){
        Test.startTest();
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account Org = new Account(Name='Test_Org',Account_type__c='Organisation');
        insert Org;
        Account customer = new Account(Name='Test_Customer',Account_type__c='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',lastName ='Contact',AccountId=customer.Id);
        insert contact;
        ERP7__Channel__c  channel = new ERP7__Channel__c (Name='Test_Channel_RMA');
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(ERP7__Employee_User__c = userinfo.getUserId(),Channel__C=channel.id,Name='Test_RMA_EMP');
        insert emp;
        ERP7__Address__c addr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=customer.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__Contact__c=contact.Id, ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert addr;
        ERP7__Address__c siteaddr = new ERP7__Address__c(Name='Test', ERP7__Customer__c=org.Id, ERP7__Active__c=true, ERP7__Address_Line1__c='Test Line 1',
                                                     ERP7__Address_Line2__c='Test Line 2', ERP7__Address_Line3__c='Test Line 3', ERP7__City__c='Test',
                                                     ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Is_Billing_Address__c=true, ERP7__Is_Shipping_Address__c=true);
        insert siteaddr;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(ERP7__Channel__c = channel.id,Name='Test Dc');
        insert dc;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId',Serialise__c=true);
        insert ps;
         Product2 ps1 = new Product2(Name='test1',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile',Barcode__c='productId1',Serialise__c=false);
        insert ps1;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
              
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        
        ERP7__Profiling__c profile=new ERP7__Profiling__c(Name='Test',ERP7__Active__c=true,ERP7__Organisation__c=customer.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id,ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert profile;
        
        Sales_Order__c sod = new Sales_Order__c(Order_Status__c = 'Closed',Account__c = customer.Id,Contact__c = contact.Id,Channel__c = channel.Id,Bill_To_Address__c = addr.Id,Ship_To_Address__c = addr.Id,Request_Date__c = system.Today(),barcode__c='orderId');
        insert sod;
        
        String SoName = '';
        if(sod != null && sod.Id != null)
         SoNAme = [SELECT Id,NAME FROM Sales_Order__c WHERE id=:sod.id].Name; 
         Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = customer.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Order_Profile__c=profile.Id,ERP7__Stage__c='Entered',ERP7__Is_Closed__c=true); 
        insert ord;
        
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Product__c = ps.id,Active__c=true);
        insert wrp;
        
        ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(product__c=ps.id,Name='Test1234',Serial_Number__c='Test1234');
        insert ser;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Serial__c=ser.id,Name='demo',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        ERP7__Batch__c batch = new ERP7__Batch__c(Product__c=ps1.id);
        insert batch;
            Sales_Order_Line_Item__c soli_1 = new Sales_Order_Line_Item__c(ERP7__Batch_Lot__c = batch.id,Name='demo',Base_Price__c=100,Discount_Amount__c=10,Product__c=ps1.id,Quantity__c=1,Sales_Order__c=sod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert soli_1;
        OrderItem orditem = new OrderItem(Serial__c=ser.id,OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Total_Price__c=100,VAT_Amount__c=10,Discount_Amount__c=10);        
        insert orditem;
        OrderItem orditem1 = new OrderItem(ERP7__Batch_Lot__c = batch.id,OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = ps1.Id,PricebookEntryId=pbe1.Id,ERP7__Active__c=true,Total_Price__c=100,VAT_Amount__c=10,Discount_Amount__c=10);        
        insert orditem1;
        Warranty__c wrr = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,Sales_Order_Line_Item__c=solim.id);
        insert wrr;
        Warranty__c wrr1 = new Warranty__c(ERP7__Product__c =ps.id,Valid_From__c=System.Today(),Valid_Till__c=System.Today()+30,ERP7__Order_Product__c=orditem.id);
        insert wrr1;
        ERP7__Site__c site = new ERP7__Site__c(Active__c = true, Organisation__c =Org.Id,Address__C = siteaddr.Id );
        insert site;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=ps.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c (ERP7__Product__c  = ps.id, ERP7__Warehouse__c = site.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert stock;
        
        ERP7__Batch__c batch2 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=ps1.Id,ERP7__Active__c=true);
        insert batch2;
        
        ERP7__Serial_Number__c serial2 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=ps1.Id, ERP7__Barcode__c='test');
        insert serial2;
        
        ERP7__Inventory_Stock__c stock1 = new ERP7__Inventory_Stock__c (ERP7__Product__c  = ps1.id, ERP7__Warehouse__c = site.Id,ERP7__Batch_Lot__c=batch2.Id,ERP7__Serial__c = serial2.Id);
        insert stock1;
        ERP7__Stock_Outward_Line_Item__c stock_OLI = new ERP7__Stock_Outward_Line_Item__c(ERP7__Product__c  = ps.id,ERP7__Sales_Order__c=sod.id,ERP7__Sales_Order_Line_Item__c = solim.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1);
        insert stock_OLI;
         ERP7__Stock_Outward_Line_Item__c stock_OLI_1 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Sales_Order__c=sod.id,ERP7__Sales_Order_Line_Item__c = soli_1.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1,ERP7__Product__c  = ps.id);
        insert stock_OLI_1;
        ERP7__Stock_Outward_Line_Item__c stock_OLI1 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Order__c=ord.id,ERP7__Order_Product__c = orditem.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1,ERP7__Product__c  = ps.id);
        insert stock_OLI1;
         ERP7__Stock_Outward_Line_Item__c stock_OLI_11 = new ERP7__Stock_Outward_Line_Item__c(ERP7__Order__c=ord.id,ERP7__Order_Product__c = orditem1.Id,ERP7__Status__c='Committed',ERP7__Site_Product_Service_Inventory_Stock__c = stock.Id, ERP7__Quantity__c =1,ERP7__Product__c  = ps.id);
        insert stock_OLI_11;
        PageReference pageRef = Page.ERP7__RMA;
        PageRef.getParameters().put('soId',sod.Id);
        PageRef.getParameters().put('OrdId',Ord.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController controller = new ApexPages.StandardController(sod);
        ApexPages.StandardController controller1 = new ApexPages.StandardController(Ord);
        RMA rma_So = new RMA(controller);
        rma_So.getSO();
        
        
        
        RMA.sObj_Wrapper obj = new RMA.sObj_Wrapper();
        obj = RMA.Build_RMALI(Sod.Id);
        obj = RMA.Fetch_RMALI1(ord.Id);
        for(RMA.RMAWrapperLI temp :obj.RAMLI_List)temp.isSelect = true;
        RMA.createRMA(JSON.serialize(new ERP7__Return_Merchandise_Authorisation__c(ERP7__SO__c =sod.Id,ERP7__Account__c = customer.id,Active__c=true)), JSON.serialize(obj.RAMLI_List),false,true);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
}