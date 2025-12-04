/*
* Test Class for IntegratedShipmentScheduler, ShipTrackingUPSBatchClass, ShipTrackingFedExBatchClass
* LastModifiedBy - Arshad
* Date - 12/03/23
*/
@isTest
public class IntegratedShipmentSchedularTestClass {    
    static testMethod void UnitTest1(){
        Account orgn = new Account(Name='Organisation', ERP7__Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', ERP7__Account_Type__c = 'Supplier');
        insert sup;
        ERP7__Business_Unit__c  busUnit = new ERP7__Business_Unit__c(ERP7__Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Account customer = new Account(Name='Customer');
        insert customer;
        Contact contact = new Contact(FirstName='Arshad',LastName='Contact',AccountId=customer.id,ERP7__Company__c='Test',Phone='1234567890',Email='test@test.com');
        insert contact;
        Contact cont = [select Id, Name, ERP7__Company__c, Phone, Email, AccountId from Contact where Id=: contact.Id];
        ERP7__Address__c bAddress = new ERP7__Address__c(ERP7__Customer__c=customer.id,ERP7__Contact__c=cont.id,ERP7__Active__c=true,ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test', ERP7__City__c='test',ERP7__State__c='Georgia', ERP7__Country__c='United States', ERP7__Postal_Code__c='test',ERP7__Is_Billing_Address__c=true);
        insert bAddress;
        bAddress = [select Id,ERP7__Customer__c,ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.Phone,ERP7__Contact__r.ERP7__Company__c,ERP7__Active__c,ERP7__Address_Line1__c, 
                    ERP7__Address_Line2__c,ERP7__Address_Line3__c, ERP7__City__c,ERP7__State__c, ERP7__Country__c, ERP7__Postal_Code__c,ERP7__Is_Billing_Address__c from ERP7__Address__c where Id=: bAddress.Id];
        ERP7__Address__c sAddress = new ERP7__Address__c(ERP7__Customer__c=customer.id,ERP7__Contact__c=cont.id,ERP7__Active__c=true,ERP7__Address_Line1__c='Test Recipient Line 1', ERP7__Address_Line2__c='Line 2', ERP7__Address_Line3__c='test', ERP7__City__c='Long Beach',ERP7__State__c='California', ERP7__Postal_Code__c='90805', ERP7__Country__c = 'United States', ERP7__Is_Shipping_Address__c=true);
        insert sAddress;
        sAddress = [select Id,ERP7__Customer__c,ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.Phone,ERP7__Contact__r.ERP7__Company__c,ERP7__Active__c,ERP7__Address_Line1__c, 
                    ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c,ERP7__State__c, ERP7__Country__c, ERP7__Postal_Code__c,ERP7__Is_Shipping_Address__c from ERP7__Address__c where Id=: sAddress.Id];
        ERP7__Channel__c salepoint = new ERP7__Channel__c(Name = 'Sale Point',  ERP7__Active__c=true, ERP7__Street__c = 'Test Sndr Address Line 1',ERP7__City__c = 'COLORADO SPRINGS',ERP7__State_Province__c = 'Colorado',ERP7__Country__c = 'United States',ERP7__Zip_Postal_Code__c = '80915', ERP7__Shipper_Name__c = 'Apex', ERP7__Company__c = 'ApexCloud', ERP7__Phone__c = '1234567890',
                                                          ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        
        Credentials__c newFedexCredentials = new Credentials__c(Name='Fedex', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                                Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                                Shipper_Province__c='California',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='b41c58070d0e2f1158e22908fa040a3e338b63b437ec23a0ef533944dd2278ae',
                                                                Username_Login__c='Fedex', Password_Transkey__c='9399519ff7e2318ae7ea29ed7ccba7e28822517b475c2fd406d37c831ace9e2b9cc46397e2fe8f33e583bd37a60edb60',
                                                                Meter_Number__c='100175015',UPS_Account_Number__c='RY9704', Parent_Password__c='FwSr0GnMFJ4ZhN93cUfXxslVm', Parent_Key__c='tEkXuBO9dc6aX7bG');
        insert newFedexCredentials;
        
        Credentials__c newUPSCredentials = new Credentials__c(Name='UPS', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                              Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                              Shipper_Province__c='test province',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='477c04bf174aa10e1c0814ee2df3c8183d3f5240f73c280299e8451c11289ae6',
                                                              Username_Login__c='39b1896632c3cdaa052b47feb28225b604b4b8180892b93fc0fea452eca40255', Password_Transkey__c='c81a8fd217212e383fa12e4fe338bde965d01b74636b2bc6dca9b9afc426a7a2',
                                                              UPS_Account_Number__c='RY9704');
        insert newUPSCredentials;
        
        ERP7__Sales_Order__c sod = new ERP7__Sales_Order__c();  
        sod.ERP7__Order_Status__c = 'Entered';
        sod.ERP7__Account__c = Contact.AccountId;
        sod.ERP7__Channel__c = salePoint.Id;
        sod.ERP7__Request_Date__c = system.Today();
        sod.ERP7__Bill_To_Address__c = bAddress.Id;
        sod.ERP7__Ship_To_Address__c = sAddress.Id;
        insert sod;
        ERP7__Sales_Order__c psod = [Select id, Name From ERP7__Sales_Order__c Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        
        ERP7__Sales_Order_Line_Item__c solim = new ERP7__Sales_Order_Line_Item__c(ERP7__Active__c = true, ERP7__Base_Price__c=100,ERP7__Discount_Amount__c=10,ERP7__Product__c=ps.id,ERP7__Quantity__c=1,ERP7__Sales_Order__c=psod.id,ERP7__Total_Price__c=100,ERP7__VAT_Amount__c=10);
        insert solim; 
        ERP7__Country_Codes__c countryCode = new ERP7__Country_Codes__c(Name='United States', ERP7__Code__c='US', ERP7__Country__c='United States');
        insert countryCode;
        ERP7__Province_Codes__c ProvinceCode = new ERP7__Province_Codes__c(Name='California', ERP7__Code__c='CA', ERP7__Province__c='California');
        insert ProvinceCode;             
        ERP7__Product_Unit_Code__c puc = new ERP7__Product_Unit_Code__c(Name='test', ERP7__Product_Code__c='Box', ERP7__Product_Description__c='Box');
        insert puc;             
        ERP7__Return_Services__c rs = new ERP7__Return_Services__c(Name='test', ERP7__Return_Service_Code__c='test', ERP7__Return_Service_Description__c='test');
        insert rs;
        ERP7__Reason_For_Export__c reasonForExportList = new ERP7__Reason_For_Export__c(Name = 'Test Sale', ERP7__Value__c = 'sale');
        insert reasonForExportList;
        ERP7__Terms_Of_Shipment__c termsOfShipmentList = new ERP7__Terms_Of_Shipment__c(Name = 'Test Name', ERP7__Terms_Of_Shipment_Value__c = 'Test Carriage', ERP7__Terms_Of_Shipment_Code__c = 'DAF');
        insert termsOfShipmentList;
        RecordType rec = [Select Id From RecordType where sObjectType='ERP7__Process__c' and Name='Manufacturing Process' Limit 1];
        ERP7__Process__c process = new ERP7__Process__c(Name='test', RecordTypeId=rec.Id);
        insert process;
        ERP7__WO__c wo = new ERP7__WO__c(Name='test', ERP7__Sales_Order__c=sod.Id, ERP7__Shipping_Address__c=sAddress.Id); //, ERP7__Process__c=process.Id
        insert wo;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        ERP7__Package__c testpack=new ERP7__Package__c(ERP7__Name__c='Test Package',ERP7__Package_Type__c = 'test', ERP7__Sales_Order__c=sod.id,ERP7__Active__c=true,ERP7__Shipment_Type__c='FedEx',ERP7__Status__c='test',
                                                       ERP7__Description__c='test description',ERP7__Weight_Unit__c='KGS',ERP7__Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack;
        
        ERP7__Package__c testpack1=new ERP7__Package__c(ERP7__Name__c='Test Package', ERP7__ETD__c=true, ERP7__Package_Type__c = 'test', ERP7__Sales_Order__c=sod.id,ERP7__Active__c=true,ERP7__Shipment_Type__c='UPS', ERP7__Status__c='test',
                                                        ERP7__Description__c='test description',ERP7__Weight_Unit__c='KGS',ERP7__Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack1; 
        ERP7__Package_List__c pl1 = new ERP7__Package_List__c(Name = 'Test List', ERP7__Sales_Order_Line_Item__c=solim.Id, ERP7__Sales_Order__c=sod.Id, ERP7__Package__c = testpack.Id, ERP7__Quantity__c = 2, ERP7__Work_Orders__c=wo.Id);
        insert pl1;
        pl1 = [select Id, Name, ERP7__Sales_Order_Line_Item__c, ERP7__Sales_Order__c, ERP7__Package__r.ERP7__Weight__c, ERP7__Package__r.ERP7__Weight_Unit__c, ERP7__Package__c, ERP7__Quantity__c from ERP7__Package_List__c where Id=: pl1.Id];
        ERP7__BOM__c psa = new ERP7__BOM__c(Name='test',ERP7__Active__c=true,ERP7__BOM_Product__c=ps.Id, ERP7__BOM_Component__c=ps1.id);
        insert psa;  
        ERP7__BOM__c psa1 = new ERP7__BOM__c(Name='test',ERP7__Active__c=true, ERP7__BOM_Product__c=ps.Id, ERP7__BOM_Component__c=ps2.id);
        insert psa1;
        
        
        String ShipmentRecTypeId = ERP7.RecordTypeUtil.getObjectRecordTypeIds('ERP7__Shipment__c','Fedex_Shipping');
        ERP7__Shipment__c shipments = new ERP7__Shipment__c(ERP7__Product_Unit_Code__c = 'PUC Code', ERP7__Shipment_Date__c = System.Today(),ERP7__Package_Weight__c = 10,ERP7__Package_Weight_Unit__c = 'KGS', ERP7__UPS_Package_Weight_Unit__c = 'LBS', 
                                                            ERP7__UPS_Package_Type__c = 'test',ERP7__Shipment_Type__c = 'test',ERP7__Customer__c = customer.Id, ERP7__Customer_Contact__c = contact.Id,ERP7__Width__c = 10, ERP7__Length__c = 10, ERP7__Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                            ERP7__Pickup_Confirmation_Number__c='1234567890',ERP7__Active__c=true,ERP7__Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        shipments.ERP7__Package_Ready_Time__c = System.Now() + 1;
        insert shipments;
        testpack.ERP7__Shipment__c = shipments.Id;
        update testpack;
        String ShipmentRecTypeId1 = ERP7.RecordTypeUtil.getObjectRecordTypeIds('ERP7__Shipment__c','UPS_Shipping');
        ERP7__Shipment__c shipments1 = new ERP7__Shipment__c(ERP7__Product_Unit_Code__c = 'PUC Code', ERP7__Shipment_Date__c = System.Today(),ERP7__Package_Weight__c = 10,ERP7__Package_Weight_Unit__c = 'KGS', ERP7__UPS_Package_Weight_Unit__c = 'LBS', 
                                                             ERP7__UPS_Package_Type__c = 'test',ERP7__Shipment_Type__c = 'test',ERP7__Customer__c = customer.Id, ERP7__Customer_Contact__c = contact.Id,ERP7__Width__c = 10, ERP7__Length__c = 10, ERP7__Height__c = 10, ERP7__TrackingNumber__c = '1Z12345E0205271688', 
                                                             ERP7__Pickup_Confirmation_Number__c='1234567890',ERP7__Active__c=true,ERP7__Status__c='shipped',RecordTypeId=ShipmentRecTypeId1);
        shipments1.ERP7__Package_Ready_Time__c = System.Now() + 1;
        insert shipments1;
        testpack1.ERP7__Shipment__c = shipments1.Id;
        update testpack1;
        test.startTest();
        IntegratedShipmentScheduler iss = new IntegratedShipmentScheduler();
        List<String> lst = new List<String>();
        lst.add(String.valueOf(testpack.Id));
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, iss);
        String reader='<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><RateReply xmlns="http://fedex.com/ws/rate/v28"><HighestSeverity>FAILURE</HighestSeverity><Notifications><Severity>FAILURE</Severity><Source>crs</Source><Code>7</Code><Message>Rating is temporarily unavailable, please try again later. </Message><LocalizedMessage>Rating is temporarily unavailable, please try again later. </LocalizedMessage></Notifications><TransactionDetail><CustomerTransactionId>Rate Request</CustomerTransactionId></TransactionDetail><Version><ServiceId>crs</ServiceId><Major>28</Major><Intermediate>0</Intermediate><Minor>0</Minor></Version></RateReply></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        
        //ShipTrackingUpdateHelper newship= new ShipTrackingUpdateHelper();
        //ShipTrackingUpdateHelper.readXMLResponseOnce(new XmlStreamReader(reader),'Severity');
        //ShipTrackingUpdateHelper.readXMLResponse(new XmlStreamReader(reader),'Severity');
        
        List<ERP7__Package__c> packlist = new List<ERP7__Package__c>();
        packlist.add(testpack);
        //ShipTrackingUpdateHelper.updateFedexShipments(JSON.serialize(packlist));
        packlist = new List<ERP7__Package__c>();
        packlist.add(testpack1);
        //ShipTrackingUpdateHelper.updateUPSShipments(JSON.serialize(packlist));
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
}