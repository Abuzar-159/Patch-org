@isTest
private class ShipmentHandlerTestCaseSet {
    
    static testMethod void unitTestCase1() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Company__c='Test',Phone='1234567890',Email='test@test.com');
        insert contact;
        Contact cont = [select Id, Name, Company__c, Phone, Email, AccountId from Contact where Id=: contact.Id];
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Georgia', Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        bAddress = [select Id,Customer__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                    Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,Is_Billing_Address__c from Address__c where Id=: bAddress.Id];
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='Test Recipient Line 1', Address_Line2__c='Line 2', Address_Line3__c='test', City__c='Long Beach',State__c='California', Postal_Code__c='90805', Country__c = 'United States', Is_Shipping_Address__c=true);
        insert sAddress;
        sAddress = [select Id,Customer__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                    Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,Is_Shipping_Address__c from Address__c where Id=: sAddress.Id];
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890');
        insert salepoint;
        Sales_Order__c sod = new Sales_Order__c();  
        sod.Order_Status__c = 'Entered';
        sod.Account__c = Contact.AccountId;
        sod.Channel__c = salePoint.Id;
        sod.Request_Date__c = system.Today();
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        insert sod;
        Sales_Order__c psod = [Select id, Name From Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        WO__c wo = new WO__c(Name='Test WO');
        insert wo;
        PO__c po = new PO__c(Name='Test PO');
        insert po;
        Transfer_Order__c to = new Transfer_Order__c(Name='Test TO');
        insert to;
        Return_Merchandise_Authorisation__c rma = new Return_Merchandise_Authorisation__c(Name='Test RMA');
        insert rma;
        Package__c testpack = new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
                              Work_Order__c=wo.Id, Purchase_Order__c=po.Id, Transfer_Order__c=to.Id, Return_Merchandise_Authorisation__c=rma.Id, Description__c='test description',Weight_Unit__c='KGS',
                              Weight__c=5.0);
        insert testpack; 
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
       BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Shipping');     
        Shipment__c shipments = new Shipment__c(Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, Tracking_Number__c = '1234567878', 
                                Shipment_Identification_Number__c='1234567878', UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        Shipment__c shipments1 = [select Id, Name, Shipment_Date__c, Package_Weight__c, Package_Weight_Unit__c, UPS_Package_Weight_Unit__c, 
                                  UPS_Package_Type__c, Shipment_Type__c, Customer__c, Customer_Contact__c, Width__c, Length__c, Height__c, Tracking_Number__c, Shipment_Identification_Number__c,
                                  UPS_Service_Code__c, Pickup_Confirmation_Number__c, RecordTypeId from Shipment__c where Id=: shipments.Id limit 1];
        String pickupRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment_Flow__c','Pickup');
        String dropoffRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment_Flow__c','DropOff');
        String deliveryRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment_Flow__c','Delivery');
        Shipment_Flow__c sfP = new Shipment_Flow__c(Name='Pickup',Shipment__c=shipments.Id, Active__c = true, Time__c = System.Now(), RecordTypeId=pickupRecTypeId);
        insert sfP;
        Shipment_Flow__c sfD = new Shipment_Flow__c(Name='DropOff',Shipment__c=shipments.Id, Active__c = true, Time__c = System.Now(), RecordTypeId=dropoffRecTypeId);
        insert sfD;
        Shipment_Flow__c sfDel = new Shipment_Flow__c(Name='Delivery',Shipment__c=shipments.Id, Active__c = true, Time__c = System.Now(), RecordTypeId=deliveryRecTypeId);
        insert sfDel; 
        Package_Details__c pkgs = new Package_Details__c(Name='Package1', Shipment_Description__c='Test Desp');
        insert pkgs;
        
        test.startTest();
            ShipmentHandler sh = new ShipmentHandler();
            
            sh.packIds = new List<Id>{testpack.Id};
            sh.getpackIds();
            sh.setpackIds(sh.packIds);
            sh.packIds = new List<Id>();
            sh.flag = false;
            sh.shipId = shipments.Id;
            sh.getshipId(); 
            sh.setshipId(shipments.Id);   
            sh.retValue = 'PO';
            sh.getretValue();
            sh.setretValue('PO');
            sh.fetchSignature();        
            
            sh.toAddr.Bill_To_Address__c = bAddress.Id;
            sh.fetchAddress();
            sh.fromAddr.Ship_To_Address__c = sAddress.Id;
            sh.fetchAddress();      
            
            sh.retValue = 'SO';
            sh.back();
            sh.retValue = 'WO';
            sh.back();
            sh.retValue = 'PO';
            sh.back();
            sh.retValue = 'TO';
            sh.back();
            sh.retValue = 'SR';
            sh.back();  
            
            sh.Shipment.Name = null;
            sh.SaveDetails();
            sh.Shipment = shipments1;
            sh.Packages.add(testpack); 
            sh.recordIdMap.put('SO', testpack.Sales_Order__c);
            sh.SaveDetails();
            sh.recordIdMap.put('WO', testpack.Work_Order__c);
            sh.SaveDetails();
            sh.recordIdMap.put('PO', testpack.Purchase_Order__c);
            sh.SaveDetails();
            sh.recordIdMap.put('TO', testpack.Transfer_Order__c);
            sh.SaveDetails();
            sh.recordIdMap.put('SR', testpack.Return_Merchandise_Authorisation__c);
            sh.SaveDetails();
                
            sh.recordTypeName = 'Pickup';
            sh.saveShipmentFlows();
            sh.recordTypeName = 'DropOff';
            sh.saveShipmentFlows();
            sh.recordTypeName = 'Delivery';
            sh.saveShipmentFlows();
            sh.sf.Name = 'Test Flow';
            sh.recordTypeName = 'Delivery';
            sh.saveShipmentFlows();
            
            sh.recordTypeName = 'Pickup';
            sh.NewShipmentFlows();
            sh.recordTypeName = 'DropOff';
            sh.NewShipmentFlows();
            sh.recordTypeName = 'Delivery';
            sh.NewShipmentFlows();
            
            sh.shipmentFlowId = sfP.Id;
            sh.recordTypeName = 'Pickup';
            sh.editShipmentFlow();
            sh.shipmentFlowId = sfP.Id;
            sh.recordTypeName = 'DropOff';
            sh.editShipmentFlow();
            sh.shipmentFlowId = sfP.Id;
            sh.recordTypeName = 'Delivery';
            sh.editShipmentFlow();
            
            sh.Shipment = shipments;
            sh.recordTypeName = 'Pickup';
            sh.cancelShipmentFlow();
            
            sh.shipmentFlowId = sfP.Id;
            sh.deleteShipmentFlow();
            
            ShipmentHandler.captureSignature('Test Signature', shipments.Id, 'Signature');
            
            System.assertEquals(contact.Email, 'test@test.com');  
        test.stopTest();            
    }
    
}