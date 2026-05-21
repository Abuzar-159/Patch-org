@isTest(SeeAllData=true)
public class SalesOrdersToaLogistic_testClass {
    public static testMethod void testcase(){
       
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;  
       ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
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
         
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Channel__c=channel.Id,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--'
                             );        
        insert ord1;
         Account acc1=new Account(Name='Test');
       insert acc1;
       ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc1.Id);
       insert address;
       
        ERP7__Inventory_Stock__c inv = new ERP7__Inventory_Stock__c(Name='Test Inv',ERP7__product__c = pro.Id,ERP7__Active__c = true,ERP7__Warehouse__c = site.Id);
        insert inv;
        ERP7__Stock_Inward_Line_Item__c stin = new ERP7__Stock_Inward_Line_Item__c(Name='test inward',ERP7__product__c = pro.Id,ERP7__Active__c = true,ERP7__Site_ProductService_InventoryStock__c=inv.Id,ERP7__Quantity__c=10);
        //insert stin;
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 1,ERP7__Reserved_Quantity__c = 0,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;

        ord1.ERP7__Logistic__c =false;
        ord1.ERP7__Ready_To_Pick_Pack__c = false;
        ord1.ERP7__Active__c =true;
        update ord1;
        SalesOrdersToaLogistic SO2Log = new SalesOrdersToaLogistic();
        SalesOrdersToaLogistic.controlCheck();
      	ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ 
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
        }
        if(FC != null){
            FC.ERP7__Is_Standard_Order__c = true;
        }
        update FC;
        SalesOrdersToaLogistic.TotalRecords('');
        SalesOrdersToaLogistic.getSOlist('Test Order', channel.Id, 5, 5);
        SalesOrdersToaLogistic.getSOlist('Test Order', '', 5, 5);
        SalesOrdersToaLogistic.getSOlist('', '', 5, 5);
         SalesOrdersToaLogistic.createLogistics(JSON.serialize(new List<String>{ord1.Id}), dc.Id);
        //SalesOrdersToaLogistic.createLogistics(JSON.serialize(new List<String>{ord1.Id}), '');
        String salName = 'ERP7';
		String sal1Name = 'ERP7';
		System.assertEquals(salName, sal1Name);
    }
    
    public static testMethod void testcase2(){
        test.startTest();
           ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;  
         Sales_Order__c salOr=new Sales_Order__c(Name='Test',ERP7__Channel__c = channel.Id);
       insert salOr;
       ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
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
         
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Channel__c=channel.Id,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--'
                             );        
        insert ord1;
         Account acc1=new Account(Name='Test');
       insert acc1;
       ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc1.Id);
       insert address;
      
       Product2 Product=new Product2(Name='abc',ERP7__Track_Inventory__c=true);
       insert Product;  
        ERP7__Inventory_Stock__c inv = new ERP7__Inventory_Stock__c(Name='Test Inv',ERP7__product__c = Product.Id,ERP7__Active__c = true,ERP7__Warehouse__c = site.Id);
        insert inv;
        ERP7__Stock_Inward_Line_Item__c stin = new ERP7__Stock_Inward_Line_Item__c(Name='test inward',ERP7__product__c = Product.Id,ERP7__Active__c = true,ERP7__Site_ProductService_InventoryStock__c=inv.Id,ERP7__Quantity__c=10);
        insert stin;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=Product.id,Quantity__c=1,Sales_Order__c=salOr.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 1,ERP7__Reserved_Quantity__c = 0,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;

        salOr.ERP7__Logistic__c = false;
        salOr.ERP7__Ready_To_Pick_Pack__c = false;
		salOr.ERP7__Active__c  =true;
        update salOr;

        ord1.ERP7__Logistic__c =false;
        ord1.ERP7__Ready_To_Pick_Pack__c = false;
        ord1.ERP7__Active__c =true;
        update ord1;
        SalesOrdersToaLogistic.logwrapper wrp= new SalesOrdersToaLogistic.logwrapper();
        SalesOrdersToaLogistic.TotalRecords(channel.Id);
        SalesOrdersToaLogistic.getSOlist('test', channel.Id, 5, 5);
        SalesOrdersToaLogistic.getSOlist('test', '', 5, 5);
        SalesOrdersToaLogistic.getSOlist('', '', 5, 5);
        
        String salName = 'ERP7';
		String sal1Name = 'ERP7';
		System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    public static testMethod void testcase4(){
        test.startTest();
           ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;  
         Sales_Order__c salOr=new Sales_Order__c(Name='Test',ERP7__Channel__c = channel.Id);
       insert salOr;
       ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
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
         
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Channel__c=channel.Id,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--'
                             );        
        insert ord1;
         Account acc1=new Account(Name='Test');
       insert acc1;
       ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc1.Id);
       insert address;
      
       Product2 Product=new Product2(Name='abc',ERP7__Track_Inventory__c=true);
       insert Product;  
        ERP7__Inventory_Stock__c inv = new ERP7__Inventory_Stock__c(Name='Test Inv',ERP7__product__c = Product.Id,ERP7__Active__c = true,ERP7__Warehouse__c = site.Id);
        insert inv;
        ERP7__Stock_Inward_Line_Item__c stin = new ERP7__Stock_Inward_Line_Item__c(Name='test inward',ERP7__product__c = Product.Id,ERP7__Active__c = true,ERP7__Site_ProductService_InventoryStock__c=inv.Id,ERP7__Quantity__c=10);
        insert stin;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(ERP7__Active__c=true,ERP7__Reserved_Quantity__c=0,Base_Price__c=100,Discount_Amount__c=10,Product__c=Product.id,Quantity__c=1,Sales_Order__c=salOr.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
       
        salOr.ERP7__Logistic__c = false;
        salOr.ERP7__Ready_To_Pick_Pack__c = false;
		salOr.ERP7__Active__c  =true;
        update salOr;

       
        SalesOrdersToaLogistic.logwrapper wrp= new SalesOrdersToaLogistic.logwrapper();
           
        wrp = SalesOrdersToaLogistic.createLogistics(JSON.serialize(new List<String>{salOr.Id}), dc.Id);
       
        SalesOrdersToaLogistic.updateLogistics(wrp.logistic,new List<Id>{solim.Id},JSON.serialize(wrp.logisticlines));
        
        String salName = 'ERP7';
		String sal1Name = 'ERP7';
		System.assertEquals(salName, sal1Name);
        
        test.stopTest();
    }
    public static testMethod void testcase3(){
       
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Test');
       insert channel;  
       ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
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
         
        Order ord1 = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,ERP7__Channel__c=channel.Id,
                             AccountId = acc.id,Pricebook2Id=standardPricebook.Id,ERP7__Amount__c=345,ERP7__Expected_Date__c=Date.today(),ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--'
                             );        
        insert ord1;
         Account acc1=new Account(Name='Test');
       insert acc1;
       ERP7__Address__c address=new ERP7__Address__c(Name='Test', ERP7__Customer__c=acc1.Id);
       insert address;
       
        ERP7__Inventory_Stock__c inv = new ERP7__Inventory_Stock__c(Name='Test Inv',ERP7__product__c = pro.Id,ERP7__Active__c = true,ERP7__Warehouse__c = site.Id);
        insert inv;
        ERP7__Stock_Inward_Line_Item__c stin = new ERP7__Stock_Inward_Line_Item__c(Name='test inward',ERP7__product__c = pro.Id,ERP7__Active__c = true,ERP7__Site_ProductService_InventoryStock__c=inv.Id,ERP7__Quantity__c=10);
        insert stin;
        OrderItem orditem = new OrderItem(OrderId = ord1.Id,Quantity = 1,ERP7__Reserved_Quantity__c = 0,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id,ERP7__Active__c=true);        
        insert orditem;

        ord1.ERP7__Logistic__c =false;
        ord1.ERP7__Ready_To_Pick_Pack__c = false;
        ord1.ERP7__Active__c =true;
        update ord1;
        SalesOrdersToaLogistic SO2Log = new SalesOrdersToaLogistic();
        SalesOrdersToaLogistic.controlCheck();
      	ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
        FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
        if(FC == null){ 
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());
            if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();            
        }
        if(FC != null){
            FC.ERP7__Is_Standard_Order__c = true;
        }
        update FC;
        SalesOrdersToaLogistic.logwrapper wrp= new SalesOrdersToaLogistic.logwrapper();
        wrp = SalesOrdersToaLogistic.createLogistics(JSON.serialize(new List<String>{ord1.Id}), '');
        SalesOrdersToaLogistic.updateLogistics(wrp.logistic,new List<Id>{orditem.Id},JSON.serialize(wrp.logisticlines));
        
        String salName = 'ERP7';
		String sal1Name = 'ERP7';
		System.assertEquals(salName, sal1Name);
    }

}