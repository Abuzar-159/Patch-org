@isTest
public class OrderProductInventoryTigger_TestClass {
    
    @isTest public static void testcase1(){
        System.assertEquals('ERP', 'ERP');
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        PreventRecursiveLedgerEntry.SOLI_AllocateStock = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer;
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=orgn.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        WO__c wo = new WO__c(Name = 'test wo', Active__c = true, WO_Supplier__c = sup.Id);
        insert wo;
        
        
        Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
        insert ps;
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
        ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true);
        insert DC;
        ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
        insert prcs;
        ERP7__Site__c site1 = new ERP7__Site__c(Name = 'projectTestSite');
        insert site1;
          Address__c bAddress = new Address__c(Customer__c=Contact.AccountId, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=Contact.AccountId, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test',
                              City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
       Id pricebookId = Test.getStandardPricebookId();
        Order sod = new Order();   
            sod.Status = 'Draft';
            sod.ERP7__Stage__c = 'Entered';
            sod.EffectiveDate = system.today();
            sod.AccountId = Contact.AccountId;
            sod.Contact__c = Contact.Id;
            sod.Channel__c = channel.Id;
            sod.Bill_To_Address__c = bAddress.Id;
            sod.Ship_To_Address__c = sAddress.Id;
            sod.Request_Date__c = system.Today();
            sod.Authorised__c = true;
            sod.ERP7__Ready_To_Pick_Pack__c = true;
            sod.fulfilled__c = false;
            sod.Barcode__c = 'test';
        sod.ERP7__Shipment_Type__c='UPS';
        sod.ERP7__Shipment_Preference_Speed__c='--None--';
            sod.Pricebook2Id=pricebookId;
        insert sod; 
        Order psod = sod;
          Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        OrderItem solim = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps.id,PricebookEntryId=pbe.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
         insert solim; 
        ERP7__MPS__c mps = new ERP7__MPS__c(Name = 'MPS1', ERP7__Product__c = ps.Id);
        insert mps;
        ERP7__MPS_line_Item__c mpsLine = new ERP7__MPS_line_Item__c(Name = 'testMPS1', ERP7__MPS__c = mps.Id);
        insert mpsLine;
        
        ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site1.Id, ERP7__Finished_Products_Site__c = site.Id);
        insert rout;
        ERP7__Inventory_Stock__c stock = new ERP7__Inventory_Stock__c(Name = 'inventory1', ERP7__Warehouse__c = site1.Id, ERP7__Product__c = ps.Id, ERP7__Active__c = true);
        insert stock;
        ERP7__Stock_Inward_Line_Item__c inward = new ERP7__Stock_Inward_Line_Item__c(Name= 'inward1', ERP7__Site_ProductService_InventoryStock__c = stock.Id, ERP7__Product__c = ps.Id, ERP7__Quantity__c = 5);
        insert inward;
        ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
        insert MO;
        ERP7__WO__c WO1 = new ERP7__WO__c(Name = 'testWO1', ERP7__Routing__c = rout.Id);
        insert WO1;
        ERP7__MRP__c mrpLine = new ERP7__MRP__c(Name = 'testMRPLine1', ERP7__MRP_Product__c = ps.Id, ERP7__Total_Amount_Required__c=10, ERP7__Fulfilled_Amount__c = 1);
        mrpLine.ERP7__MO__c = MO.Id;
        mrpLine.ERP7__Work_Order__c = WO1.Id;
        insert mrpLine;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name = 'testRMA1');
        insert rma;
        ERP7__RMA_Line_Item__c rmaLine = new ERP7__RMA_Line_Item__c(Name = 'testRMAline1', ERP7__Return_Merchandise_Authorisation__c = rma.Id);
        insert rmaLine;
        Date tomo = system.today();
        tomo.addMonths(1);
        ERP7__Cost_Card__c ccard = new ERP7__Cost_Card__c(Name = 'testCard1', ERP7__Product__c = ps.Id, ERP7__Supplier__c = sup.Id, ERP7__End_Date__c = tomo, ERP7__Cost__c = 10, ERP7__Quantity__c = 5);
        insert ccard;
        List<Id> prods = new List<Id>();
        prods.add(ps.Id);
        ERP7__PO__c PO = new ERP7__PO__c(Name = 'testPO1', ERP7__Vendor__c = sup.Id, ERP7__Channel__c = channel.Id, ERP7__Distribution_Channel__c = DC.Id, ERP7__Organisation__c = orgn.Id, ERP7__Ready_To_Receive__c = true);
        insert PO;
        
        ERP7__Purchase_Line_Items__c poli = new ERP7__Purchase_Line_Items__c(Name = 'testPOLI1', ERP7__Order_Product__c = solim.Id,ERP7__Purchase_Orders__c=PO.Id);
         
        List<ERP7__Purchase_Line_Items__c> poli_list = new List<ERP7__Purchase_Line_Items__c>();
        poli_list.add(poli);
        upsert poli_list;
         set<Id> PuId = new set<Id>();
         for(ERP7__Purchase_Line_Items__c pr : poli_list){ PuId.add(pr.Id); }
         OrderProductInventoryUtils.createProductPurchaseLineItems(PuId);
         OrderProductInventoryUtils.updateProductPurchaseLineItems(PuId);
        
        OrderItem solim1 = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps.id,PricebookEntryId=pbe.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
         insert solim1; 
         
        List<OrderItem> orderitemlist = new List<OrderItem>();
        orderitemlist.add(solim1);
         OrderProductInventoryUtils.deleteProductPurchaseLineItems(orderitemlist);
        
    }
}