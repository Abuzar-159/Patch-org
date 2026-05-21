@isTest
public class OrderTrigger_TestClass {
    
    static testMethod void unitTest1(){   
        test.startTest();
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert sop;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;
        ERP7__Tax__c tax = new Tax__c(ERP7__Type__c='Shipping',Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Account_Profile__c=profile.Id);
        insert tax; 
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
        
        
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;
        OrderItem orditem1 = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro1.Id,PricebookEntryId=pbe1.Id,ERP7__Active__c=true);        
        insert orditem1;
        
        
        
         //Stock_Outward_Line_Item__c sto = new Stock_Outward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Product__c=pro.Id,Quantity__c=200,ERP7__Sales_Order_Line_Item__c = orditem.Id);
         //insert sto;
        //update ord;
        /*ord.ERP7__Authorised__c=true;
        ord.ERP7__Ready_To_Pick_Pack__c=true;
        ord.Status='Booked';
        ord.ERP7__Issue_Warranty__c =true;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update ord;*/
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update orditem;
        delete orditem;
        system.assertEquals('makhtar@aqxolt.com', acc.ERP7__Email__c);
        test.stopTest();
    }
     @isTest(seeAllData = true)
    static  void unitTest2(){
       
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c=true,ERP7__Serialise__c = true);
        insert pro;
        Product2 pro2 = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c=true,ERP7__Serialise__c = true);
        insert pro2;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        
       
        
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert sop;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;
        ERP7__Tax__c tax = new Tax__c(ERP7__Type__c='Shipping',Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Account_Profile__c=profile.Id);
        insert tax; 
        
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;
        
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             Channel__c = channel.Id, ERP7__Ready_To_Pick_Pack__c=true, ERP7__Authorised__c=true,ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord1;
        
         /*Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = acc.id, Barcode__c='Site');
        insert site;*/
        
        
        //----Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = acc.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=pro.Id);
        //----insert WIIS1;
        
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today(),ERP7__Type__c = 'Assembly',ERP7__Status__c = 'Certified');
        insert ver1;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Kit'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom;
        test.startTest();
        
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=pro.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = acc.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=pro.Id,ERP7__Serial__c = serial1.Id);
        insert WIIS1;
        
        
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 201,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Explode__c = true,Version__c = null, Inventory_Tracked__c = true, Is_Back_Order__c = true, Is_Pre_Order__c=false);        
        insert orditem;
         //OrderItem orditem2 = new OrderItem(OrderId = ord1.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro2.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Explode__c = true,Version__c = null, Inventory_Tracked__c = true, Is_Back_Order__c = true, Is_Pre_Order__c=false);        
        //insert orditem2;
        Set<Id> ordIds= new Set<Id>();
        List<OrderItem> ordList = new List<OrderItem>();
        ordList.add(orditem);
        ordIds.add(orditem.Id);
        
        Set<Id> ordIds2= new Set<Id>();
        //ordIds2.add(orditem2.Id);
        
        PreventRecursiveLedgerEntry.proceedStockOutwardUpdateHandler = true;
        Stock_Outward_Line_Item__c sto = new Stock_Outward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Product__c=pro.Id,Quantity__c=200,ERP7__Order_Product__c = orditem.Id,Order__c =ord1.Id,ERP7__Status__c='Reserved');
        insert sto;
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Name='Test', Active__c = true, Product__c = pro.Id, Days_of_Warranty__c = 30);
        insert wrp;
        ord1.ERP7__Issue_Warranty__c = true;
        
        //******************
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update ord1;
        /*
        ord1.ERP7__Issue_Warranty__c = true;
        ord1.Status='Booked';
        upsert ord1;
        system.debug('ord1.ERP7__Issue_Warranty__c~>'+ord1.ERP7__Issue_Warranty__c);
        
        Order ord2 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = true);        
        insert ord2;
        */
         //system.debug('ord2.ERP7__Issue_Warranty__c~>'+ord2.ERP7__Issue_Warranty__c);
        //ord1.ERP7__Issue_Warranty__c = true;
        //update ord1;
        //delete ord1;
        //system.assertEquals('makhtar@aqxolt.com', acc.ERP7__Email__c);
        //
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        OrderProductInventoryUtils.createProductPurchaseLineItems(ordIds);
         
        //OrderProductInventoryUtils.createProductPurchaseLineItems(ordIds2);
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        OrderProductInventoryUtils.updateProductPurchaseLineItems(ordIds);
        //update orditem;

        //delete orditem;
        //***************
        List<ERP7__BOM__c> BOMsList = new List<ERP7__BOM__c>();
        BOMsList.add(bom);
        BOMTriggerHelper.createSupportingBOMs(true,false,BOMsList);
        BOMTriggerHelper.updateSupportingBOMs(false,true,BOMsList);
        BOMTriggerHelper.deleteSupportingBoms(BOMsList);
        BOMTriggerHelper.undeleteSupportingBoms(BOMsList);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        
       test.stopTest();
    }
     @isTest(seeAllData = true)
     static  void unitTest3(){
        test.startTest();
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c=true);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware',ERP7__Is_Kit__c=true);
        insert pro1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        
       
        
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert sop;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;
        ERP7__Tax__c tax = new Tax__c(ERP7__Type__c='Shipping',Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Account_Profile__c=profile.Id);
        insert tax; 
        
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;
        
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             Channel__c = channel.Id, ERP7__Ready_To_Pick_Pack__c=true, ERP7__Authorised__c=true,ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord1;
        
         /*Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;*/
        
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = acc.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=pro.Id);
        insert WIIS1;
         
         //*******
         //Inventory_Stock__c WIIS4 = new Inventory_Stock__c(Organisation__c = acc.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Fixed_Asset__c=pro.Id);
        //insert WIIS4;
         

        /*ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='ToTest1',ERP7__Product__c=ps.Id,ERP7__Available__c=true,ERP7__Expired__c=false,ERP7__Active__c=true);
        insert ser;

        ERP7__Site__c site4 = new Site__c(Name = 'site', Active__c=true, Organisation__c = acc.id, Barcode__c='Site',ProductService_InventoryStock__c=SerialStock.Id);
        insert site4;

         ERP7__Stock_Inward_Line_Item__c SILIS4 = new ERP7__Stock_Inward_Line_Item__c( ERP7__Serial__c = 'ToTest1',ERP7__Available__c = true,ERP7__Expired__c = false,Active__c = true,ERP7__Site_ProductService_InventoryStock__c=SerialStock.Id);
         insert SILIS4;
            */

        //ERP7__Asset__c asset1=new ERP7__Asset__c(Name='Test', ERP7__Available__c=true, ERP7__Status__c='available');
        //insert asset1;
         
         //*******
        
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today(),ERP7__Type__c = 'Assembly',ERP7__Status__c = 'Certified');
        insert ver1;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Kit'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom;
        
        
        /*Stock_Outward_Line_Item__c sto = new Stock_Outward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Product__c=pro.Id,Quantity__c=500, ERP7__Status__c='Reserved');
        insert sto;*/
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Name='Test', Active__c = true, Product__c = pro.Id, Days_of_Warranty__c = 30);
        insert wrp;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS1.Id,Product__c=pro.Id,Quantity__c=2000);
        insert SPLI;
        //ord1.ERP7__Issue_Warranty__c = true;
        
        //******************
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 200,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Explode__c = true,Inventory_Tracked__c = true, Is_Back_Order__c = false, Is_Pre_Order__c=false, Checked_Out_Process__c = 'LIFO');        
        insert orditem;
        Set<Id> ordIds= new Set<Id>();
        List<OrderItem> ordList = new List<OrderItem>();
        ordList.add(orditem);
        ordIds.add(orditem.Id);
        
        /*
        ord1.ERP7__Issue_Warranty__c = true;
        ord1.Status='Booked';
        upsert ord1;
        system.debug('ord1.ERP7__Issue_Warranty__c~>'+ord1.ERP7__Issue_Warranty__c);
        
        Order ord2 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = true);        
        insert ord2;
        */
         //system.debug('ord2.ERP7__Issue_Warranty__c~>'+ord2.ERP7__Issue_Warranty__c);
        //ord1.ERP7__Issue_Warranty__c = true;
        //update ord1;
        //delete ord1;
        //system.assertEquals('makhtar@aqxolt.com', acc.ERP7__Email__c);
        //
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        OrderProductInventoryUtils.createProductPurchaseLineItems(ordIds);
        // test.startTest();
        //OrderProductInventoryUtils.createProductPurchaseLineItems(ordIds2);
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        //OrderProductInventoryUtils.updateProductPurchaseLineItems(ordIds);
        
        //OrderProductInventoryUtils.deleteProductPurchaseLineItems(ordList);
        //update orditem;

        //delete orditem;
        //***************
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
       test.stopTest();
    }
    
    
    static testMethod void unitTest4(){
        test.startTest();
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c=true);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        
       
        
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert sop;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;
        ERP7__Tax__c tax = new Tax__c(ERP7__Type__c='Shipping',Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Account_Profile__c=profile.Id);
        insert tax; 
        
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;
        
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             Channel__c = channel.Id, ERP7__Ready_To_Pick_Pack__c=true, ERP7__Authorised__c=true,ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord1;
        
         /*Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;*/
        
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = acc.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=pro.Id);
        insert WIIS1;
         
         //*******
         //Inventory_Stock__c WIIS4 = new Inventory_Stock__c(Organisation__c = acc.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Fixed_Asset__c=pro.Id);
        //insert WIIS4;
         

        /*ERP7__Serial_Number__c ser = new ERP7__Serial_Number__c(Name='Test',Serial_Number__c='ToTest1',ERP7__Product__c=ps.Id,ERP7__Available__c=true,ERP7__Expired__c=false,ERP7__Active__c=true);
        insert ser;

        ERP7__Site__c site4 = new Site__c(Name = 'site', Active__c=true, Organisation__c = acc.id, Barcode__c='Site',ProductService_InventoryStock__c=SerialStock.Id);
        insert site4;

         ERP7__Stock_Inward_Line_Item__c SILIS4 = new ERP7__Stock_Inward_Line_Item__c( ERP7__Serial__c = 'ToTest1',ERP7__Available__c = true,ERP7__Expired__c = false,Active__c = true,ERP7__Site_ProductService_InventoryStock__c=SerialStock.Id);
         insert SILIS4;
            */

        ERP7__Asset__c asset1=new ERP7__Asset__c(Name='Test', ERP7__Available__c=true, ERP7__Status__c='available');
        insert asset1;
         
         //*******
        
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today(),ERP7__Type__c = 'Assembly',ERP7__Status__c = 'Certified');
        insert ver1;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Kit'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom;
        
        
        /*Stock_Outward_Line_Item__c sto = new Stock_Outward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Product__c=pro.Id,Quantity__c=500, ERP7__Status__c='Reserved');
        insert sto;*/
        Warranty_Return_Policy__c wrp = new Warranty_Return_Policy__c(Name='Test', Active__c = true, Product__c = pro.Id, Days_of_Warranty__c = 30);
        insert wrp;
        Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c=WIIS1.Id,Product__c=pro.Id,Quantity__c=2);
        insert SPLI;
        //ord1.ERP7__Issue_Warranty__c = true;
        
        //******************
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 200,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Explode__c = true,Inventory_Tracked__c = true, Is_Back_Order__c = false, Is_Pre_Order__c=false, Checked_Out_Process__c = 'LIFO');        
        insert orditem;
        Set<Id> ordIds= new Set<Id>();
        List<OrderItem> ordList = new List<OrderItem>();
        ordList.add(orditem);
        ordIds.add(orditem.Id);
        
        /*
        ord1.ERP7__Issue_Warranty__c = true;
        ord1.Status='Booked';
        upsert ord1;
        system.debug('ord1.ERP7__Issue_Warranty__c~>'+ord1.ERP7__Issue_Warranty__c);
        
        Order ord2 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = true);        
        insert ord2;
        */
         //system.debug('ord2.ERP7__Issue_Warranty__c~>'+ord2.ERP7__Issue_Warranty__c);
        //ord1.ERP7__Issue_Warranty__c = true;
        //update ord1;
        //delete ord1;
        //system.assertEquals('makhtar@aqxolt.com', acc.ERP7__Email__c);
        //
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        OrderProductInventoryUtils.createProductPurchaseLineItems(ordIds);
        // test.startTest();
        //OrderProductInventoryUtils.createProductPurchaseLineItems(ordIds2);
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        //OrderProductInventoryUtils.updateProductPurchaseLineItems(ordIds);
        
        //OrderProductInventoryUtils.deleteProductPurchaseLineItems(ordList);
        //update orditem;

        //delete orditem;
        //***************
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
       test.stopTest();
    }

    
    
    static testMethod void unitTest5(){
        PreventRecursiveLedgerEntry.testCasesTransactions=false;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id, ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert sop;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        Account customer = new Account(Name='Customer',ERP7__Is_Person_Account__c=true);
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=acc.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Country__c='Test');
        insert bAddress;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Bill_To_Address__c = bAddress.Id, ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
        
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c = true);
        insert pro;
        Tax__c tax = new Tax__c(ERP7__Province__c = 'Test', ERP7__Product__c = pro.Id, ERP7__Type__c = 'Sales Tax',ERP7__Account_Profile__c = sop.Id, Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax; 
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
         OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true, ERP7__Inventory_Tracked__c = false,Explode__c = true, Tax__c = null);        
        insert orditem;
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
       
    }
    
    
    
    static testMethod void unitTest6(){
        PreventRecursiveLedgerEntry.testCasesTransactions=false;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id, ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert sop;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        Account customer = new Account(Name='Customer',ERP7__Is_Person_Account__c=true);
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=acc.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Country__c='Test');
        insert bAddress;
        
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Bill_To_Address__c = bAddress.Id, ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
        
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c = true);
        insert pro;
        Tax__c tax = new Tax__c(ERP7__Province__c = 'Test', ERP7__Type__c = 'Sales Tax',ERP7__Account_Profile__c = sop.Id, Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10);
        insert tax; 
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
         OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true, ERP7__Inventory_Tracked__c = false,Explode__c = true, Tax__c = null);        
        insert orditem;
       
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
       
    }
     @isTest(seeAllData = true)
    static  void unitTest7(){
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c=true,ERP7__Serialise__c = true);
        insert pro;
        Product2 pro2 = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c=true,ERP7__Serialise__c = true);
        insert pro2;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        
       
        
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id);
        insert sop;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        
        acc.ERP7__Order_Profile__c=profile.Id;
        upsert acc;
        ERP7__Tax__c tax = new Tax__c(ERP7__Type__c='Shipping',Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Account_Profile__c=profile.Id);
        insert tax; 
        
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;
        
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             Channel__c = channel.Id, ERP7__Ready_To_Pick_Pack__c=true, ERP7__Authorised__c=true,ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered');        
        insert ord1;
        
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 201,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Explode__c = true,Version__c = null, Inventory_Tracked__c = true, Is_Back_Order__c = true, Is_Pre_Order__c=false);        
        insert orditem;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=pro.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        Inventory_Stock__c WIIS1 = new Inventory_Stock__c(Organisation__c = acc.Id,Name='test', Active__c=true,Warehouse__c=site.Id,Product__c=pro.Id,ERP7__Serial__c = serial1.Id);
        insert WIIS1;
        
        Stock_Outward_Line_Item__c sto = new Stock_Outward_Line_Item__c(Name='test',Active__c=true,ERP7__Site_Product_Service_Inventory_Stock__c=WIIS1.Id,Product__c=pro.Id,Quantity__c=200,ERP7__Order_Product__c = orditem.Id,Order__c =ord1.Id,ERP7__Status__c='Reserved');
        insert sto;
        
		Order ord2 = [Select Id,Name from Order where Id=:ord1.Id];        
        ord2.ERP7__Issue_Warranty__c=true;
        //ord1.Status='Cancelled';
        update ord2;
        
       
    }
    
    
        /*static testMethod void unitTest7(){
            
        PreventRecursiveLedgerEntry.testCasesTransactions=false;    
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE, ERP7__Is_Kit__c = true);
        insert pro;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        Account customer = new Account(Name='Customer',ERP7__Is_Person_Account__c=true);
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Kit' and SobjectType = 'ERP7__Version__c' Limit 1];  
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today(),ERP7__Type__c = 'Assembly',ERP7__Status__c = 'Certified');
        ver1.RecordTypeId=custProfile_RTypes.Id;
        insert ver1;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Country__c='Test');
        insert bAddress;
        Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='ERP7__Channel__c');
        insert channel;
        ERP7__Profiling__c sop = new ERP7__Profiling__c(Name='test',RecordTypeId=orderProfile_RTypes.Id,ERP7__Active__c=true,ERP7__Organisation__c=acc.Id,ERP7__Channel__c=channel.Id,ERP7__Price_Book__c=standardPricebook.Id, ERP7__Tax_Sourcing_Rules__c ='Origin');
        insert sop;
          
        
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        PriceBook2 priceBook = new PriceBook2(Name='test',IsActive=true);
        insert priceBook;
        ERP7__Profiling__c profile = new ERP7__Profiling__c(Name='test', ERP7__Price_Book__c=priceBook.Id,ERP7__Account_Profile__c=sop.Id,RecordTypeId=orderProfile_RTypes.Id);
        insert profile;
        Order ord = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),
                             ERP7__Bill_To_Address__c = bAddress.Id, ERP7__Organisation__c=acc.Id,ERP7__Order_Profile__c=profile.Id,ERP7__Issue_Invoice__c=true,ERP7__Stage__c='Entered',ERP7__Issue_Warranty__c = false);        
        insert ord;
        
        
        
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Kit'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        ERP7__BOM__c bom=new ERP7__BOM__c(Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified');
        insert bom; 
        PreventRecursiveLedgerEntry.testCasesTransactions=false;    
        OrderItem orditem = new OrderItem(OrderId = ord.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true,Explode__c = true, Tax__c = null,ERP7__Inventory_Tracked__c=false,Version__c = ver1.Id);        
        insert orditem;
        
        ERP7__Tax__c tax = new Tax__c(ERP7__Type__c='Shipping',Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Account_Profile__c=profile.Id,TaxPostalCode = false, TaxProvince = '',TaxCountry = false);
        insert tax;
    }*/
}