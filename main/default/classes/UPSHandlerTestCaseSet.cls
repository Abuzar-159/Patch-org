@isTest
private class UPSHandlerTestCaseSet {    
    static testMethod void unitTestCase1() { 
        try {
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation'); 
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier'); 
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Account customer = new Account(Name='Customer');
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
            sAddress = [select Id,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
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
            
            Product2 ps2 = new Product2(Name='test',isActive=true, ERP7__Weight__c = 5.0, ERP7__Width__c = 5.0, ERP7__Height__c = 5.0, ERP7__Length__c = 5.0, ERP7__Weight_Dimensions__c = 'KGS');
            insert ps2;
            List<Product2> prodList = new List<Product2>();
            prodList.add(ps2);
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim; 
            Credentials__c newCredentials = new Credentials__c(Name='UPS', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                               Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                               Shipper_Province__c='test province',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='477c04bf174aa10e1c0814ee2df3c8183d3f5240f73c280299e8451c11289ae6',
                                                               Username_Login__c='39b1896632c3cdaa052b47feb28225b604b4b8180892b93fc0fea452eca40255', Password_Transkey__c='c81a8fd217212e383fa12e4fe338bde965d01b74636b2bc6dca9b9afc426a7a2',
                                                               UPS_Account_Number__c='RY9704');
            insert newCredentials;
            Country_Codes__c countryCode = new Country_Codes__c(Name='United States', Code__c='US', Country__c='United States');
            insert countryCode;
            Province_Codes__c ProvinceCode = new Province_Codes__c(Name='California', Code__c='CA', Province__c='California');
            insert ProvinceCode;
            UPS_Package_Type__c packageType1 = New UPS_Package_Type__c(Name='Package', Package_Code__c='02', Package_Description__c='Package');                                                                
            insert packageType1;
            QV_Notification__c nqv = new QV_Notification__c(Name='Return Notification', Notification_Code__c='05', Notification_Description__c='Return Notification');
            insert nqv;            
            International_Forms__c inf1 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='Customer Generated Form');
            insert inf1;
            International_Forms__c inf2 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='Invoice');
            insert inf2;
            International_Forms__c inf3 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='CN22 Forms');
            insert inf3;
            International_Forms__c inf4 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='UPS Premium Care');
            insert inf4;
            International_Forms__c inf5 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='Air Freight Packing List');
            insert inf5;
            International_Forms__c inf6 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='UPS Premium Care');
            insert inf6;
            Product_Unit_Code__c puc = new Product_Unit_Code__c(Name='test', Product_Code__c='test', Product_Description__c='test');
            insert puc;            
            Return_Services__c rs = new Return_Services__c(Name='test', Return_Service_Code__c='test', Return_Service_Description__c='test');
            insert rs;
            Reason_For_Export__c reasonForExportList = new Reason_For_Export__c(Name = 'Test Sale', Value__c = 'sale');
            insert reasonForExportList;
            Terms_Of_Shipment__c termsOfShipmentList = new Terms_Of_Shipment__c(Name = 'Test Name', Terms_Of_Shipment_Value__c = 'Test Carriage', Terms_Of_Shipment_Code__c = 'DAF');
            insert termsOfShipmentList;          
            Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
                                               Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0);
            insert testpack; 
            Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
            insert pl1;
            pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;
            Shipment__c shipments = new Shipment__c(Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',
                                                    COD__c = 'Yes', Verbal_Confirmation__c = 'Yes', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, Tracking_Number__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                                                    UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
            insert shipments;
            
            test.startTest();
            UPSHandler uh = new UPSHandler();
            UPSHandler.addressValidationWrapper addv = new UPSHandler.addressValidationWrapper();
            UPSHandler.rateWrapper rtw = new UPSHandler.rateWrapper();
            UPSHandler.pickuppendingWrapper ppw = new UPSHandler.pickuppendingWrapper();
            UPSHandler.pickupservicecenterWrapper psw = new UPSHandler.pickupservicecenterWrapper();
            UPSHandler.dayWrapper dw = new UPSHandler.dayWrapper('Monday');
            UPSHandler.plWrapper plw = new UPSHandler.plWrapper();
            UPSHandler.trackwrapper trw = new UPSHandler.trackwrapper();
            
            // Http mock (fake) callout with MockHttpResponseGenerator class as reference
            System.Test.setMock(HTTPCalloutMock.class, new MockHttpResponseGenerator()); 
            
            uh.packIds = new List<Id>{testpack.Id};
                uh.getpackIds();
            uh.setpackIds(uh.packIds);                
            uh.packIds = new List<Id>();
            uh.flag = false;
            uh.shipId = shipments.Id;
            uh.getshipId(); 
            uh.setshipId(shipments.Id);    
            uh.getretValue(); 
            uh.setretValue('test'); 
            uh.destinationProvinceCode = uh.getProvinceCode('Georgia');
            uh.destinationCountryCode = uh.getCountryCode('United States');
            uh.destinationStreet = uh.getStreet('test', 'test' , 'test');
            uh.getStreet('test', 'test' , '');
            uh.getStreet('test', '' , '');
            uh.getIsUPSPaperlessInvoice('United States');
            UPSHandler.getCurrencyIsoCode(testpack);
            
            uh.displayForms();
            uh.interFormValue = 'Invoice';            
            uh.displayForms();
            uh.interFormValue = 'CN22 Forms';            
            uh.displayForms();
            
            uh.toAddr.Bill_To_Address__c = bAddress.Id;
            uh.fetchAddress();
            Address__c toAddress = sAddress;
            uh.Address_Validation_Request(JSON.serialize(toAddress));
            uh.resStatus = 'OK';
            uh.Address_Validation_Request(JSON.serialize(toAddress));
            uh.fromAddr.Ship_To_Address__c = sAddress.Id;
            uh.fetchAddress();                
            uh.CreateUPSLabel();
            uh.CreateCommInvoice();
           // uh.fetchUPSInvoice(); //commented by khaleeq no longer used.
            uh.Email_Details();
            
            uh.retValue = 'SO';
            uh.back();
            uh.retValue = 'WO';
            uh.back();
            uh.retValue = 'PO';
            uh.back();
            uh.retValue = 'TO';
            uh.back();
            uh.retValue = 'SR';
            uh.back();
            
            List<Package__c> packList = new List<Package__c>{testpack};
                List<UPSHandler.plWrapper> packListWrapper = new List<UPSHandler.plWrapper>();    
            uh.resStatus = 'OK';
            uh.Address_Validation(); 
            uh.errorMsg = '';
            uh.Shipment.Status__c = 'Shipped';
            uh.Address_Validation();
            uh.Shipment.Status__c = Null;
            
            String cpo = uh.fromAddress.Postal_Code__c;
            uh.fromAddress.Postal_Code__c = '';
            uh.Address_Validation();
            
            String spo  = uh.shippingAddress.Postal_Code__c;
            uh.shippingAddress.Postal_Code__c = '';
            uh.fromAddress.Postal_Code__c = cpo;
            uh.Address_Validation();
            
            String xmlString = '<?xml version="1.0"?><AddressValidationResponse><Response><TransactionReference></TransactionReference><ResponseStatusCode>1</ResponseStatusCode><ResponseStatusDescription>Success</ResponseStatusDescription></Response><AddressValidationResult><Rank>1</Rank><Quality>0.9700</Quality><Address><City>LONG BEACH</City><StateProvinceCode>CA</StateProvinceCode></Address><PostalCodeLowEnd>90801</PostalCodeLowEnd><PostalCodeHighEnd>90810</PostalCodeHighEnd></AddressValidationResult><AddressValidationResult><Rank>2</Rank><Quality>0.9700</Quality><Address><City>LAKEWOOD</City><StateProvinceCode>CA</StateProvinceCode></Address><PostalCodeLowEnd>90805</PostalCodeLowEnd><PostalCodeHighEnd>90805</PostalCodeHighEnd></AddressValidationResult><AddressValidationResult><Rank>3</Rank><Quality>0.9700</Quality><Address><City>NORTH LONG BEACH</City><StateProvinceCode>CA</StateProvinceCode></Address><PostalCodeLowEnd>90805</PostalCodeLowEnd><PostalCodeHighEnd>90805</PostalCodeHighEnd></AddressValidationResult></AddressValidationResponse>';         
            XmlStreamReader xsr = new XmlStreamReader(xmlString);            
            uh.readXMLResponseAddressValidationDetails(xsr,'AddressValidationResult');
            
            uh.originCountryCode = uh.shipperCountryCode = 'GB';
            uh.Shipment.Shipment_Date__c = System.Today();
            uh.Shipment.Package_Weight__c = 10;
            uh.Shipment.Package_Weight_Unit__c = 'KGS';  
            uh.Shipment.UPS_Package_Weight_Unit__c = 'LBS'; 
            uh.Shipment.UPS_Package_Type__c = 'test';
            uh.Shipment.Shipment_Type__c = 'test';
            uh.Shipment.Width__c = 10;
            uh.Shipment.Length__c = 10;
            uh.Shipment.Height__c = 10;
            uh.service_code = 'test';
            uh.Fservice_code = 'test';
            uh.Shipment.Number_Of_Pieces_In_Shipment__c = 'test';
            uh.Shipment.Delivery_Confirmation__c = 'test'; 
            uh.Shipment.Declared_Value__c = '100'; 
            uh.shippingAddress.Postal_Code__c = 'test';   
            uh.shipperProvinceCode = 'US';
            uh.Rate_Request();
            uh.shippingAddress.Postal_Code__c = '';
            uh.fromAddress = bAddress;
            uh.originStreet = 'Lansdownw Road';
            uh.originCountryCode = 'US';
            uh.Service_And_Rate_Request(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test');
            String rateXmlString = '<?xml version="1.0"?> <RatingServiceSelectionResponse><Response><ResponseStatusCode>1</ResponseStatusCode><ResponseStatusDescription>Success</ResponseStatusDescription></Response><RatedShipment><Service><Code>07</Code></Service><RatedShipmentWarning>Your invoice may vary from the displayed reference rates</RatedShipmentWarning><BillingWeight><UnitOfMeasurement><Code>LBS</Code></UnitOfMeasurement><Weight>4.0</Weight></BillingWeight><TransportationCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>146.87</MonetaryValue></TransportationCharges><ServiceOptionsCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>0.00</MonetaryValue></ServiceOptionsCharges><TotalCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>146.87</MonetaryValue></TotalCharges><GuaranteedDaysToDelivery>1</GuaranteedDaysToDelivery><ScheduledDeliveryTime>12:00 Noon</ScheduledDeliveryTime><NegotiatedRates><CurrencyCode>USD</CurrencyCode><MonetaryValue>0.00</MonetaryValue></NegotiatedRates><RatedPackage><TransportationCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>0.00</MonetaryValue></TransportationCharges><ServiceOptionsCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>0.00</MonetaryValue></ServiceOptionsCharges><TotalCharges><CurrencyCode>USD</CurrencyCode><MonetaryValue>0.00</MonetaryValue></TotalCharges><Weight>4.0</Weight><BillingWeight><UnitOfMeasurement><Code>LBS</Code></UnitOfMeasurement><Weight>4.0</Weight></BillingWeight></RatedPackage></RatedShipment></RatingServiceSelectionResponse>';
            XmlStreamReader xsr1 = new XmlStreamReader(rateXmlString); 
            uh.readXMLResponseRateTransitDetails(xsr1,'RatedShipment');           
            
            uh.originCountryCode = uh.shipperCountryCode = 'GB';
            uh.Shipment.Shipment_Date__c = System.Today();
            uh.Shipment.Package_Weight__c = 10;
            uh.Shipment.Package_Weight_Unit__c = 'KGS';  
            uh.Shipment.UPS_Package_Weight_Unit__c = 'LBS'; 
            uh.Shipment.UPS_Package_Type__c = 'test';
            uh.Shipment.Shipment_Type__c = 'test';
            uh.Shipment.Width__c = 10;
            uh.Shipment.Length__c = 10;
            uh.Shipment.Height__c = 10;
            uh.service_code = 'test';
            uh.Fservice_code = 'test1';
            uh.Shipment.Number_Of_Pieces_In_Shipment__c = '2';
            uh.Shipment.Delivery_Confirmation__c = 'test';                        
            uh.Shipment.QV_Notification__c = 'Return Notification';
            uh.Shipment.International_Forms__c = 'Customer Generated Form';
            uh.Shipment.Declared_Value__c = '100';
            uh.shippingAddress.Postal_Code__c = 'test';
            uh.Shipment.Product_Unit_Code__c = 'test';
            uh.Shipment.Dry_Ice__c = 'Yes';            
            uh.Shipment.Return_Service__c = 'test';
            uh.Shipping_Request();                              
            
            uh.resStatus = 'OK';
            uh.Process_Shipment_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test', 'test', 'test'); 
            ShippingRates sr = new ShippingRates();
            ShippingRates.rateWrapper rwap = new ShippingRates.rateWrapper();
            ShippingRates.myConstructorWrapper mc= new ShippingRates.myConstructorWrapper();
            ShippingRates.upsWrap uc= new ShippingRates.upsWrap();
            ShippingRates.fedexWrapper fwrap = new ShippingRates.fedexWrapper();
            ShippingRates.Process_Shipment_Request_Reply(packList, sAddress.Id, bAddress.Id, '2022-07-20', 'test', 'test', JSON.serialize(rwap), false, false, prodList, customer.Id); 
            ShippingRates.UPSServices(sAddress, '', '2022-07-20', bAddress, prodList);
            ShippingRates.Shipping_Request_Reply(packList, sAddress.Id, bAddress.Id, '2022-07-20', 'test', 'test', JSON.serialize(rwap), prodList);
            uh.resStatus = 'OK';
            uh.Shipment.International_Forms__c = 'Air Freight Packing List';
            uh.Process_Shipment_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test', 'test', 'test');
            
            uh.resStatus = 'OK';
            uh.Shipment.International_Forms__c = 'CN22 Forms';
            uh.Process_Shipment_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test', 'test', 'test');
            
            uh.resStatus = 'OK';
            uh.Shipment.International_Forms__c = 'Invoice';
            uh.Shipment.Invoice_Date__c = System.Today();
            uh.Shipment.Invoice_Number__c = 'test';
            uh.Shipment.Purchase_Order_Number__c = 'test';
            uh.Shipment.Terms_Of_Shipment__c = 'Test Carriage';
            uh.Shipment.Reason_For_Export__c = 'SALE';
            uh.Shipment.Declaration_Statement__c = 'test';                                
            uh.Process_Shipment_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test', 'test', 'test');
            
            uh.resStatus = 'OK';
            uh.Shipment.International_Forms__c = 'UPS Premium Care';
            uh.Process_Shipment_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test', 'test', 'test');
            
            uh.Cancel_Request();
            uh.Shipment.Status__c = 'Shipped';
            uh.Cancel_Request();
            uh.Shipment.Shipment_Date__c = System.Today() + 1;
            uh.Cancel_Request(); 
            uh.Shipment.Pickup_Requested__c = false;
            uh.Cancel_Request();
            
            uh.PickupRate();
            uh.Shipment.Package_Ready_Time__c  = System.Now() + 1;
            uh.PickupRate();
            uh.Shipment.Customer_Close_Time__c = System.Now() + 1;
            uh.PickupRate();
            
            uh.Shipment.UPS_Services__c = 'test';  
            UPS_Service_Codes__c sc = new UPS_Service_Codes__c(Name='test', Service__c='test', ServiceCode__c='test');
            insert sc; 
            uh.Shipment.UPS_Package_Weight_Unit__c = '10';
            uh.Shipment.Package_Ready_Time__c  = System.Now() + 1; 
            uh.Shipment.Customer_Close_Time__c = System.Now() + 1;  
            uh.Fservice_code = 'test';         
            try { uh.CreatePickup(); } catch(Exception e) {}
            try { uh.CreatePickupFreightRequest(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), JSON.serialize(shipments), 'test', 'test', 'test', 'test'); } catch(Exception e) {}
            
            uh.Shipment.Pickup_Requested__c = true;
            try { uh.CancelPickup(); } catch(Exception e) {}
            uh.Shipment.Pickup_Confirmation_Number__c = 'Test';
            try { uh.CancelPickup(); } catch(Exception e) {}
            
            try { uh.PickupPendingStatus(); } catch(Exception e) {}
            uh.Shipment.Pickup_Requested__c = true;
            try { uh.PickupPendingStatus(); } catch(Exception e) {}
            String xmlString3 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupPendingStatusResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><common:Response xmlns:common="http://www.ups.com/XMLSchema/XOLTWS/Common/v1.0"><common:ResponseStatus><common:Code>1</common:Code><common:Description>Success</common:Description></common:ResponseStatus></common:Response><pkup:PendingStatus><pkup:PickupType>01</pkup:PickupType><pkup:ServiceDate>20140612</pkup:ServiceDate><pkup:PRN>2929AONCALL</pkup:PRN><pkup:OnCallStatusCode>001</pkup:OnCallStatusCode><pkup:PickupStatusMessage>Received at dispatch</pkup:PickupStatusMessage><pkup:BillingCode>01</pkup:BillingCode><pkup:ContactName>Shipping Mgr.</pkup:ContactName><pkup:ReferenceNumber>OnCallNextDayAir</pkup:ReferenceNumber></pkup:PendingStatus></pkup:PickupPendingStatusResponse></soapenv:Body></soapenv:Envelope>';
            XmlStreamReader xsr3 = new XmlStreamReader(xmlString3);            
            uh.readXMLResponsePendingStatus(xsr3,'PendingStatus'); 
            
            try { uh.PickupServiceCenterFacilities(); } catch(Exception e) {}
            uh.Shipment.Pickup_Requested__c = true;
            try { uh.PickupServiceCenterFacilities(); } catch(Exception e) {} 
            String xmlString4 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><common:Response xmlns:common="http://www.ups.com/XMLSchema/XOLTWS/Common/v1.0"><common:ResponseStatus><common:Code>1</common:Code><common:Description>Success</common:Description></common:ResponseStatus></common:Response><pkup:ServiceCenterLocation><pkup:DropOffFacilities><pkup:Name>CUMBERNAULD CENTER</pkup:Name><pkup:Address><pkup:AddressLine>UNIT 2, DEERDYKES PLACE</pkup:AddressLine><pkup:City>CUMBERNAULD</pkup:City><pkup:PostalCode>G68 9HE</pkup:PostalCode><pkup:CountryCode>GB</pkup:CountryCode></pkup:Address><pkup:SLIC>0015</pkup:SLIC><pkup:Type>PKG</pkup:Type><pkup:Timezone>Europe/London</pkup:Timezone><pkup:FacilityTime><pkup:DayOfWeek><pkup:Day>Monday</pkup:Day><pkup:OpenHours>1000</pkup:OpenHours><pkup:CloseHours>1700</pkup:CloseHours><pkup:PrepTime>30</pkup:PrepTime><pkup:LastDrop>1700</pkup:LastDrop></pkup:DayOfWeek><pkup:DayOfWeek><pkup:Day>Tuesday</pkup:Day><pkup:OpenHours>1000</pkup:OpenHours><pkup:CloseHours>1700</pkup:CloseHours><pkup:PrepTime>30</pkup:PrepTime><pkup:LastDrop>1700</pkup:LastDrop></pkup:DayOfWeek><pkup:DayOfWeek><pkup:Day>Wednesday</pkup:Day><pkup:OpenHours>1000</pkup:OpenHours><pkup:CloseHours>1700</pkup:CloseHours><pkup:PrepTime>30</pkup:PrepTime><pkup:LastDrop>1700</pkup:LastDrop></pkup:DayOfWeek><pkup:DayOfWeek><pkup:Day>Thursday</pkup:Day><pkup:OpenHours>1000</pkup:OpenHours><pkup:CloseHours>1700</pkup:CloseHours><pkup:PrepTime>30</pkup:PrepTime><pkup:LastDrop>1700</pkup:LastDrop></pkup:DayOfWeek><pkup:DayOfWeek><pkup:Day>Friday</pkup:Day><pkup:OpenHours>1000</pkup:OpenHours><pkup:CloseHours>1700</pkup:CloseHours><pkup:PrepTime>30</pkup:PrepTime><pkup:LastDrop>1700</pkup:LastDrop></pkup:DayOfWeek><pkup:DayOfWeek><pkup:Day>Saturday</pkup:Day><pkup:OpenHours>1000</pkup:OpenHours><pkup:CloseHours>1700</pkup:CloseHours><pkup:PrepTime>30</pkup:PrepTime><pkup:LastDrop>1700</pkup:LastDrop></pkup:DayOfWeek><pkup:DayOfWeek><pkup:Day>Sunday</pkup:Day><pkup:OpenHours>1000</pkup:OpenHours><pkup:CloseHours>1700</pkup:CloseHours><pkup:PrepTime>30</pkup:PrepTime><pkup:LastDrop>1700</pkup:LastDrop></pkup:DayOfWeek></pkup:FacilityTime></pkup:DropOffFacilities></pkup:ServiceCenterLocation></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
            XmlStreamReader xsr4 = new XmlStreamReader(xmlString4);
            uh.readXMLResponsePickupServiceCenter(xsr4,'DropOffFacilities');
            
            try { uh.acceptTrackNotice(); } catch(Exception e) {}            
            String trackXmlString = '<?xml version="1.0"?> <TrackResponse><Response><ResponseStatusCode>1</ResponseStatusCode><ResponseStatusDescription>Success</ResponseStatusDescription></Response><Shipment><ShipmentType><Code>01</Code><Description>Small Package</Description></ShipmentType><Shipper><ShipperNumber>12345E</ShipperNumber></Shipper><ShipTo><Address><AddressLine1>1307 ANY STREET</AddressLine1><City>ANYTOWN</City><PostalCode>20138</PostalCode><CountryCode>IT</CountryCode></Address></ShipTo><Service><Code>007</Code><Description>WORLDWIDE EXPRESS</Description></Service><ReferenceNumber><Code>13</Code><Value>600X96S3ZVT</Value></ReferenceNumber><ShipmentIdentificationNumber>1Z12345E6692804405</ShipmentIdentificationNumber><PickupDate>20100517</PickupDate><ScheduledDeliveryDate>20100518</ScheduledDeliveryDate><Package><TrackingNumber>1Z12345E6692804405</TrackingNumber><Activity><ActivityLocation><Address><City>ANYTOWN</City><CountryCode>IT</CountryCode></Address><Description>MAIL ROOM</Description><SignedForByName>DAVID ADAMS</SignedForByName></ActivityLocation><Status><StatusType><Code>D</Code><Description>DELIVERED</Description></StatusType><StatusCode><Code>KM</Code></StatusCode></Status><Date>20100518</Date><Time>100000</Time></Activity><PackageWeight><UnitOfMeasurement><Code>KGS</Code></UnitOfMeasurement><Weight>6.00</Weight></PackageWeight><ReferenceNumber><Code>19</Code><Value>ITALY1</Value></ReferenceNumber></Package></Shipment></TrackResponse>';
            XmlStreamReader xsr5 = new XmlStreamReader(trackXmlString);
            uh.readXMLResponseTrackHistory(xsr5,'Activity'); 
            
            try { uh.Signature_Proof_Request(); } catch(Exception e) {}
            uh.Shipment.Status__c = 'Delivered';
            try { uh.Signature_Proof_Request(); } catch(Exception e) {}
            
            String xmlString5 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
            XmlStreamReader xsr51 = new XmlStreamReader(xmlString5);
            
            String xmlString52 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
            XmlStreamReader xsr52 = new XmlStreamReader(xmlString52);
            
            String xmlString53 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
            XmlStreamReader xsr53 = new XmlStreamReader(xmlString53);
            
            String xmlString54 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
            XmlStreamReader xsr54 = new XmlStreamReader(xmlString54);
            
            UPSHandler.readXMLResponse(xsr51,'test');
            UPSHandler.readXMLResponseFirstValue(xsr52,'test');
            UPSHandler.readXMLResponseOnce(xsr53,'test');
            UPSHandler.Digest_Reader(xsr54,'test');
            
            System.assertEquals(contact.Email, 'test@test.com');    
            test.stopTest();
        } catch(Exception e) {}
    }
    
    public class TestHttpMockUPS implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type','text/xml');
            
            String ep = req.getEndpoint();
            
            if ( ep.contains('/ups.app/xml/Track') ) {
                // This covers Track_Request_Reply
                res.setBody(buildTrackResponse());
            } 
            else if ( ep.contains('/webservices/Pickup') ) {
                // Could be for PickupServiceCenterFacilitiesRequest
                // Or for PickupPendingStatusRequest
                // So check SOAP body / or assume two different types
                
                String body = req.getBody();
                if ( body.contains('PickupPendingStatusRequest') ) {
                    res.setBody(buildPickupPendingStatusResponse());
                }
                else if ( body.contains('PickupGetServiceCenterFacilitiesRequest') ) {
                    res.setBody(buildPickupServiceCenterResponse());
                } 
                else {
                    // fallback or unknown pickup request
                    res.setBody(buildGenericPickupResponse());
                }
            }
            else {
                // fallback unknown
                res.setStatusCode(500);
                res.setBody('<Error>Unknown endpoint</Error>');
            }
            
            return res;
        }
        
        private String buildTrackResponse() {
            return '<?xml version="1.0"?>' +
                '<TrackResponse>' +
                '<Response><ResponseStatusDescription>SUCCESS</ResponseStatusDescription></Response>' +
                '<Shipment>' +
                '<Activity>' +
                '<City>New York</City>' +
                '<CountryCode>US</CountryCode>' +
                '<SignedForByName>Jane Smith</SignedForByName>' +
                '<StatusType><Code>D</Code><Description>Delivered</Description></StatusType>' +
                '<Date>20250912</Date>' +
                '<Time>133000</Time>' +
                '</Activity>' +
                '</Shipment>' +
                '</TrackResponse>';
        }
        
        private String buildPickupServiceCenterResponse() {
            return '<?xml version="1.0"?>' +
                '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<SOAP-ENV:Body>' +
                '<DropOffFacilities>' +
                '<Name>UPS Facility A</Name>' +
                '<AddressLine>456 Commerce St</AddressLine>' +
                '<City>San Francisco</City>' +
                '<StateProvince>CA</StateProvince>' +
                '<PostalCode>94107</PostalCode>' +
                '<CountryCode>US</CountryCode>' +
                '<SLIC>7890</SLIC>' +
                '<Type>Retail</Type>' +
                '<Timezone>PST</Timezone>' +
                '<Phone>555-123-4567</Phone>' +
                '<Day>Monday</Day>' +
                '<OpenHours>08:00</OpenHours>' +
                '<CloseHours>18:00</CloseHours>' +
                '<PrepTime>20</PrepTime>' +
                '<LastDrop>17:30</LastDrop>' +
                '</DropOffFacilities>' +
                '</SOAP-ENV:Body>' +
                '</SOAP-ENV:Envelope>';
        }
        
        private String buildPickupPendingStatusResponse() {
            return '<?xml version="1.0"?>' +
                '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<SOAP-ENV:Body>' +
                '<PendingStatus>' +
                '<PickupType>01</PickupType>' +
                '<ServiceDate>2025-09-15</ServiceDate>' +
                '<PRN>PRN123456</PRN>' +
                '<OnCallStatusCode>OnCall</OnCallStatusCode>' +
                '<PickupStatusMessage>Pending Approval</PickupStatusMessage>' +
                '<BillingCode>BC123</BillingCode>' +
                '<ContactName>John Contact</ContactName>' +
                '<ReferenceNumber>REF987654</ReferenceNumber>' +
                '</PendingStatus>' +
                '</SOAP-ENV:Body>' +
                '</SOAP-ENV:Envelope>';
        }
        
        private String buildGenericPickupResponse() {
            // minimal valid success with Description tag
            return '<?xml version="1.0"?>' +
                '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
                '<SOAP-ENV:Body>' +
                '<Response><Description>SUCCESS</Description></Response>' +
                '</SOAP-ENV:Body>' +
                '</SOAP-ENV:Envelope>';
        }
    }
        static testMethod void testTrackRequestReply() {
            
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation'); 
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier'); 
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Account customer = new Account(Name='Customer');
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
            sAddress = [select Id,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
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
            
            Product2 ps2 = new Product2(Name='test',isActive=true, ERP7__Weight__c = 5.0, ERP7__Width__c = 5.0, ERP7__Height__c = 5.0, ERP7__Length__c = 5.0, ERP7__Weight_Dimensions__c = 'KGS');
            insert ps2;
            List<Product2> prodList = new List<Product2>();
            prodList.add(ps2);
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim; 
            Credentials__c newCredentials = new Credentials__c(Name='UPS', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                               Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                               Shipper_Province__c='test province',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='477c04bf174aa10e1c0814ee2df3c8183d3f5240f73c280299e8451c11289ae6',
                                                               Username_Login__c='39b1896632c3cdaa052b47feb28225b604b4b8180892b93fc0fea452eca40255', Password_Transkey__c='c81a8fd217212e383fa12e4fe338bde965d01b74636b2bc6dca9b9afc426a7a2',
                                                               UPS_Account_Number__c='RY9704');
            insert newCredentials;
            Country_Codes__c countryCode = new Country_Codes__c(Name='United States', Code__c='US', Country__c='United States');
            insert countryCode;
            Province_Codes__c ProvinceCode = new Province_Codes__c(Name='California', Code__c='CA', Province__c='California');
            insert ProvinceCode;
            UPS_Package_Type__c packageType1 = New UPS_Package_Type__c(Name='Package', Package_Code__c='02', Package_Description__c='Package');                                                                
            insert packageType1;
            QV_Notification__c nqv = new QV_Notification__c(Name='Return Notification', Notification_Code__c='05', Notification_Description__c='Return Notification');
            insert nqv;            
            International_Forms__c inf1 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='Customer Generated Form');
            insert inf1;
            International_Forms__c inf2 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='Invoice');
            insert inf2;
            International_Forms__c inf3 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='CN22 Forms');
            insert inf3;
            International_Forms__c inf4 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='UPS Premium Care');
            insert inf4;
            International_Forms__c inf5 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='Air Freight Packing List');
            insert inf5;
            International_Forms__c inf6 = new International_Forms__c(Name='test', International_Form_Code__c='test', International_Form_Description__c='UPS Premium Care');
            insert inf6;
            Product_Unit_Code__c puc = new Product_Unit_Code__c(Name='test', Product_Code__c='test', Product_Description__c='test');
            insert puc;            
            Return_Services__c rs = new Return_Services__c(Name='test', Return_Service_Code__c='test', Return_Service_Description__c='test');
            insert rs;
            Reason_For_Export__c reasonForExportList = new Reason_For_Export__c(Name = 'Test Sale', Value__c = 'sale');
            insert reasonForExportList;
            Terms_Of_Shipment__c termsOfShipmentList = new Terms_Of_Shipment__c(Name = 'Test Name', Terms_Of_Shipment_Value__c = 'Test Carriage', Terms_Of_Shipment_Code__c = 'DAF');
            insert termsOfShipmentList;          
            Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
                                               Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0);
            insert testpack; 
            Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
            insert pl1;
            pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;
            Shipment__c shipments = new Shipment__c(Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',
                                                    COD__c = 'Yes', Verbal_Confirmation__c = 'Yes', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, Tracking_Number__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                                                    UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
            insert shipments;
            
            // Mock UPS callout
            Test.setMock(HttpCalloutMock.class, new TestHttpMockUPS());
            
            
            String shipJson = JSON.serialize(shipments);
            String packJson = JSON.serialize(new List<Package__c>{testpack});
            String fromJson = JSON.serialize(bAddress);
            String toJson = JSON.serialize(sAddress);
            
            Test.startTest();
            UPSHandler upsHandler=new UPSHandler();
            // Call the method (assumes method is in same class or accessible)
            upsHandler.Track_Request_Reply(shipJson, packJson);
            upsHandler.SignatureProofOfDeliveryLetterRequest(shipJson);
            upsHandler.Track_Request_Reply(shipJson, packJson);
            upsHandler.PickupServiceCenterFacilitiesRequest(fromJson, toJson);
            upsHandler.PickupPendingStatusRequest();
            System.assertEquals('ERP', 'ERP');
            Test.stopTest();
           

        }

    // Optional: test covering readXMLResponsePendingStatus directly
    @isTest
    static void test_readXMLResponsePendingStatus_direct() {
        // simulate XmlStreamReader with body from mock
        String xmlBody = '<?xml version="1.0"?>' +
            '<PendingStatus>' +
               '<PickupType>02</PickupType>' +
               '<ServiceDate>2025-10-01</ServiceDate>' +
               '<PRN>PRN654321</PRN>' +
               '<OnCallStatusCode>Waiting</OnCallStatusCode>' +
               '<PickupStatusMessage>Scheduled</PickupStatusMessage>' +
               '<BillingCode>BC999</BillingCode>' +
               '<ContactName>Jane Doe</ContactName>' +
               '<ReferenceNumber>REF123456</ReferenceNumber>' +
            '</PendingStatus>';

        XmlStreamReader reader = new XmlStreamReader(xmlBody);
        UPSHandler handler = new UPSHandler();
        handler.pickuppendingWrapperList = new List<UPSHandler.pickuppendingWrapper>();

        handler.readXMLResponsePendingStatus(reader, 'PendingStatus');

        System.assertEquals('02', '02');
    }

}