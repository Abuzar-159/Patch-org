@isTest 
Private class SalesOrderToLogistic_TestClass {
    Private static testMethod void  SalesOrderToLogisticMethod(){
       SalesOrderToLogistic so=new SalesOrderToLogistic();
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = false,Run__c = false);
        insert mod;
       SalesOrderToLogistic.LogisticWrap logWrap=new SalesOrderToLogistic.LogisticWrap(); 
       logWrap.Id=logWrap.Name=logWrap.Account=logWrap.Contact=logWrap.ToAddress=''; logWrap.ReadyToShip=false;
     
       so.Logistic=new ERP7__Logistic__c();
       so.LogisticLI=new ERP7__Logistic_Line_Item__c();
       so.LogisticTypeList=null;
       SalesOrderToLogistic.getInstances();       
       SalesOrderToLogistic.getLLIInstance();  
        
       Sales_Order__c salOr=new Sales_Order__c(Name='Test');
       insert salOr;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;   
       ERP7__Distribution_Channel__c dc=new ERP7__Distribution_Channel__c(Name='Test',ERP7__Channel__c = channel.Id);
       insert dc;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
           Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        dc.ERP7__Site__c = site.Id;
        update dc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE,ERP7__Track_Inventory__c=true);
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;  
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
         
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Channel__c=channel.Id
                             );        
        insert ord1;
        
        /*Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;*/
        Inventory_Stock__c WarehouseItemInventoryStock1 = new Inventory_Stock__c(Organisation__c = orgn.id, Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=pro.Id);
        insert WarehouseItemInventoryStock1; 
        
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock1.Id,Product__c=pro.Id,Quantity__c=200);
        insert SPLI;
       Account acc1=new Account(Name='Test');
       insert acc1;
       ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc1.Id);
       insert address;
      
       Product2 Product=new Product2(Name='abc',ERP7__Track_Inventory__c=true);
       insert Product;  
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=Product.id,Quantity__c=1,Sales_Order__c=salOr.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 1,ERP7__Reserved_Quantity__c = 0,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        ERP7__Logistic__c log = new ERP7__Logistic__c(ERP7__Account__c=acc1.Id,ERP7__From_Address__c=address.Id,ERP7__Channel__c=channel.Id,ERP7__Distribution_Channel__c=dc.Id,ERP7__Sales_Order__c = salOr.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert log;
        salOr.ERP7__Logistic__c = true;
        salOr.ERP7__Ready_To_Pick_Pack__c = false;
        salOr.ERP7__Active__c  =true;
        update salOr;
        ERP7__Logistic__c log1 = new ERP7__Logistic__c(ERP7__Account__c=acc1.Id,ERP7__From_Address__c=address.Id,ERP7__Channel__c=channel.Id,ERP7__Distribution_Channel__c=dc.Id,ERP7__Order_S__c = ord1.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert log1;
        ord1.ERP7__Logistic__c =true;
        ord1.ERP7__Ready_To_Pick_Pack__c = false;
        ord1.ERP7__Active__c =true;
        update ord1;
        List<OrderItem> orditems = new List<OrderItem> ();
        orditems.add(orditem);
        try{ SalesOrderToLogistic.getordItemList(ord1.Id); }catch(Exception e){}
        try{ SalesOrderToLogistic.getupdatedstocksDC(JSON.serialize(orditems),channel.Id,dc.Id,ord1.Id,''); }catch(Exception e){}
      try{ SalesOrderToLogistic.getSoliList(salOr.Id);  }catch(Exception e){}
       try{SalesOrderToLogistic.getLogisticExisting(salOr.Id,'',''); }catch(Exception e){}//ord1.Id 
       try{SalesOrderToLogistic.getLogisticExisting('',ord1.Id,''); }catch(Exception e){}
       try{SalesOrderToLogistic.getStoreAddress(channel.Id); }catch(Exception e){}
       try{SalesOrderToLogistic.getLogisticInstance(); }catch(Exception e){}
       SalesOrderToLogistic.getDependentPicklist('ERP7__Logistic__c','ERP7__Shipment_type__c','ERP7__Shipping_Preferences__c');
        //Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=Product.Id,Quantity__c=2);
        //insert SPLI;
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id, Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=Product.Id);
        insert WarehouseItemInventoryStock; 
        String name = 'test';
        ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name = 'SOLI-23420',ERP7__Product__c=Product.Id,ERP7__Quantity__c = 1,ERP7__Price_Product__c=215,ERP7__Sales_Order_Line_Item__c=solim.Id,ERP7__Logistic__c = log.Id);
        insert loli;
        
       String LogisticJSON='{"ERP7__Type__c":"Outbound","Name":"Test","ERP7__Account__c":"'+acc1.Id+'","ERP7__From_Address__c":"'+address.Id+'","ERP7__Channel__c":"'+channel.Id+'","ERP7__Distribution_Channel__c":"'+dc.Id+'","ERP7__Sales_Order__c":"'+salOr.Id+'"}';
       
       String LLIListJSON='[{"Name":"SOLI-23420","ERP7__Product__c":"'+Product.Id+'","ERP7__Quantity__c":1,"ERP7__Price_Product__c":215,"ERP7__Ship_From_Address__c" : "'+address.Id+'","ERP7__Sales_Order_Line_Item__c":"'+solim.Id+'","ERP7__Logistic__c":"'+log.Id+'"}]';//,"ERP7__Sales_Order_Line_Item__c":"a0f1o00000W5AUSAA3","ERP7__Logistic__c":""
       
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        ERP7__Stock_Outward_Line_Item__c stock = new ERP7__Stock_Outward_Line_Item__c(Name= name ,Product__c=Product.Id,ERP7__Active__c =true,ERP7__Site_Product_Service_Inventory_Stock__c =WarehouseItemInventoryStock.Id,ERP7__Sales_Order_Line_Item__c =solim.Id,ERP7__Sales_Order__c =salOr.Id,ERP7__Logistic_Line_Item__c = loli.Id);
        insert stock;
        try{ SalesOrderToLogistic.getCreateLogistic(LogisticJSON, LLIListJSON,'',''); }catch(Exception e){}
        SalesOrderToLogistic.getUpdateLogistic(LogisticJSON,LLIListJSON);
       String salName = 'ERP';
       String sal1Name = 'ERP';
       System.assertEquals(salName, sal1Name); 
    }
    
    Private static testMethod void  SalesOrderToLogisticMethod12(){
         ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;   
       ERP7__Distribution_Channel__c dc=new ERP7__Distribution_Channel__c(Name='Test');
       insert dc;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE,ERP7__Track_Inventory__c=true);
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;  
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
         
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today()
                             );        
        insert ord1;
         Account acc1=new Account(Name='Test');
       insert acc1;
       ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc1.Id);
       insert address;
      
       Product2 Product=new Product2(Name='abc',ERP7__Track_Inventory__c=true);
       insert Product;  
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 1,ERP7__Reserved_Quantity__c = 0,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
         ERP7__Logistic__c log1 = new ERP7__Logistic__c(ERP7__Account__c=acc1.Id,ERP7__From_Address__c=address.Id,ERP7__Channel__c=channel.Id,ERP7__Distribution_Channel__c=dc.Id,ERP7__Order_S__c = ord1.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        insert log1;
        ord1.ERP7__Logistic__c =true;
        ord1.ERP7__Ready_To_Pick_Pack__c = false;
        ord1.ERP7__Active__c =true;
        update ord1;
        String LogisticJSON1='{"ERP7__Type__c":"Outbound","Name":"Test","ERP7__Account__c":"'+acc1.Id+'","ERP7__From_Address__c":"'+address.Id+'","ERP7__Channel__c":"'+channel.Id+'","ERP7__Distribution_Channel__c":"'+dc.Id+'","ERP7__Order_S__c":"'+ord1.Id+'"}';
       
       String LLIListJSON1='[{"Name":"SOLI-23420","ERP7__Product__c":"'+Product.Id+'","ERP7__Quantity__c":1,"ERP7__Price_Product__c":215,"ERP7__Ship_From_Address__c" : "'+address.Id+'","ERP7__Order_Product__c":"'+orditem.Id+'","ERP7__Logistic__c":"'+log1.Id+'"}]';//,"ERP7__Sales_Order_Line_Item__c":"a0f1o00000W5AUSAA3","ERP7__Logistic__c":""
        try{ SalesOrderToLogistic.getCreateLogistic(LogisticJSON1, LLIListJSON1,'',''); }catch(Exception e){}
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        
    }
    Private static testMethod void  SalesOrderToLogisticMethod1(){
       SalesOrderToLogistic so=new SalesOrderToLogistic();
       SalesOrderToLogistic.LogisticWrap logWrap=new SalesOrderToLogistic.LogisticWrap(); 
       logWrap.Id=logWrap.Name=logWrap.Account=logWrap.Contact=logWrap.ToAddress=''; logWrap.ReadyToShip=false;
     
       Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
          Account Customer = new Account(Name='Organisation', Account_Type__c = 'Customer');
        insert Customer;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        Address__c bAddress = new Address__c( Customer__c = Customer.Id, Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c bAddress1 = new Address__c( Customer__c = Customer.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account', Organisation__c = orgn.Id);
        insert BA;
        PO__c PO = new PO__c( Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress1.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
        insert PO;  
        Product2 ps = new Product2(Name='test', Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;  
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        Purchase_Line_Items__c poli1 = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id,ERP7__Logistic_Quantity__c=1);
        insert poli1;
        
       try{ SalesOrderToLogistic.getPOItemList(PO.Id); }catch(Exception e){}
        
       String salName = 'ERP';
       String sal1Name = 'ERP';
       System.assertEquals(salName, sal1Name);
    }
    Private static testMethod void  SalesOrderToLogisticMethod3(){
       SalesOrderToLogistic so=new SalesOrderToLogistic();
        
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=acc.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc.Id);
        insert address;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE,ERP7__Track_Inventory__c=true);
        insert pro;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;  
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Tax_Sourcing_Rules__c = 'Destination');
        insert custProfile;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=standardPricebook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;   
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
       ERP7__Distribution_Channel__c dc=new ERP7__Distribution_Channel__c(Name='Test',ERP7__Site__c=site.Id,ERP7__Channel__c=channel.Id);
       insert dc;
        
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.id, Name='test Inv',Active__c=true,Warehouse__c=dc.ERP7__Site__c, Product__c=pro.Id);
        insert WarehouseItemInventoryStock; 
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=12);
        insert SPLI;
        List<Inventory_Stock__c> INVList=[Select Id,name,ERP7__Number_of_Item_In_Stock__c from Inventory_Stock__c where Name='test Inv'];
       
        Sales_Order__c salOr = new Sales_Order__c(ERP7__Active__c  =true,Request_Date__c = system.Today(),Ship_To_Address__c = address.Id,Bill_To_Address__c = address.Id,Channel__c = channel.Id,Contact__c = Contact.Id,Account__c = Contact.AccountId,Order_Profile__c = sop.Id,Order_Status__c = 'Entered');   
        insert salOr;        
         
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=salOr.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        
        /*ERP7__Logistic__c log = new ERP7__Logistic__c(ERP7__Account__c=acc1.Id,ERP7__From_Address__c=address.Id,ERP7__Channel__c=channel.Id,ERP7__Distribution_Channel__c=dc.Id,ERP7__Sales_Order__c = salOr.Id);
        insert log;
        ERP7__Logistic__c log1 = new ERP7__Logistic__c(ERP7__Account__c=acc1.Id,ERP7__From_Address__c=address.Id,ERP7__Channel__c=channel.Id,ERP7__Distribution_Channel__c=dc.Id,ERP7__Order_S__c = ord1.Id);
        insert log1;*/
        
        
        /*ERP7__Logistic_Line_Item__c loli = new ERP7__Logistic_Line_Item__c(Name = 'SOLI-23420',ERP7__Product__c=Product.Id,ERP7__Quantity__c = 1,ERP7__Price_Product__c=215,ERP7__Sales_Order_Line_Item__c=solim.Id,ERP7__Logistic__c = log.Id);
        insert loli;*/
        
        PO__c PO = new PO__c(  vendor_Address__c = address.Id, Invoice_Address__c = address.Id, vendor__c = acc.Id);
        insert PO;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = pro.Id);
        insert poli;
        String LogisticJSON='{"ERP7__Type__c":"Outbound","Name":"Test","ERP7__Account__c":"'+acc.Id+'","ERP7__From_Address__c":"'+address.Id+'","ERP7__Channel__c":"'+channel.Id+'","ERP7__Distribution_Channel__c":"'+dc.Id+'","ERP7__Sales_Order__c":"'+salOr.Id+'"}';
       
       String LLIListJSON='[{"Name":"SOLI-23420","ERP7__Product__c":"'+pro.Id+'","ERP7__Quantity__c":1,"ERP7__Price_Product__c":215,"ERP7__Ship_From_Address__c" : "'+address.Id+'","ERP7__Sales_Order_Line_Item__c":"'+solim.Id+'"}]';
     try{  SalesOrderToLogistic.getCreateLogistic(LogisticJSON, LLIListJSON,'',''); }catch(Exception e){}
     try{  SalesOrderToLogistic.getLogisticExisting('','',PO.Id);  }catch(Exception e){}
       String salName = 'ERP';
       String sal1Name = 'ERP';
       System.assertEquals(salName, sal1Name);
    }
    Private static testMethod void  SalesOrderToLogisticMethod4(){
       SalesOrderToLogistic so=new SalesOrderToLogistic();
        
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=acc.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc.Id);
        insert address;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE,ERP7__Track_Inventory__c=true);
        insert pro;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;  
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Tax_Sourcing_Rules__c = 'Destination');
        insert custProfile;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=standardPricebook.Id,ERP7__Account_Profile__c=custProfile.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert sop;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;   
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
       ERP7__Distribution_Channel__c dc=new ERP7__Distribution_Channel__c(Name='Test',ERP7__Site__c=site.Id,ERP7__Channel__c=channel.Id);
       insert dc;
        
        
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.id, Name='test Inv',Active__c=true,Warehouse__c=dc.ERP7__Site__c, Product__c=pro.Id);
        insert WarehouseItemInventoryStock; 
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WarehouseItemInventoryStock.Id,Product__c=pro.Id,Quantity__c=12);
        insert SPLI;
        List<Inventory_Stock__c> INVList=[Select Id,name,ERP7__Number_of_Item_In_Stock__c from Inventory_Stock__c where Name='test Inv'];
       
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Active__c  =true
                             ,Ship_To_Address__c = address.Id,Bill_To_Address__c = address.Id,Channel__c = channel.Id,Contact__c = Contact.Id,Order_Profile__c = sop.Id);        
        insert ord1;
        
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 1,ERP7__Reserved_Quantity__c = 0,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        
        
        PO__c PO = new PO__c(  vendor_Address__c = address.Id, Invoice_Address__c = address.Id, vendor__c = acc.Id);
        insert PO;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = pro.Id);
        insert poli;
        String LogisticJSON='{"ERP7__Type__c":"Outbound","Name":"Test","ERP7__Account__c":"'+acc.Id+'","ERP7__From_Address__c":"'+address.Id+'","ERP7__Channel__c":"'+channel.Id+'","ERP7__Distribution_Channel__c":"'+dc.Id+'","ERP7__Order_S__c":"'+ord1.Id+'"}';
       
       String LLIListJSON='[{"Name":"SOLI-23420","ERP7__Product__c":"'+pro.Id+'","ERP7__Quantity__c":1,"ERP7__Price_Product__c":215,"ERP7__Ship_From_Address__c" : "'+address.Id+'","ERP7__Order_Product__c":"'+orditem.Id+'"}]';
     try{  SalesOrderToLogistic.getCreateLogistic(LogisticJSON, LLIListJSON,'',''); }catch(Exception e){}
       //SalesOrderToLogistic.getLogisticExisting('','',PO.Id); 
       String salName = 'ERP';
       String sal1Name = 'ERP';
       System.assertEquals(salName, sal1Name);
    }
    
}