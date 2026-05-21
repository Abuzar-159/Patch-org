@isTest 
private class USPSTestCaseSet {
	static testMethod void unitTestCase1() {
        //try {
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup; 
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Account customer = new Account(Name='Customer'); 
            insert customer;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Company__c='Test Company',Phone='1234567890',Email='test@test.com');
            insert contact;
            Contact cont = [select Id, Name, Company__c, Phone, Email, AccountId from Contact where Id=: contact.Id];
            Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Georgia', Country__c='United States', Postal_Code__c='test', ERP7__Zip_4__c='1234',Is_Billing_Address__c=true);
            insert bAddress;
            bAddress = [select Id,Customer__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                        Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,ERP7__Zip_4__c,Is_Billing_Address__c from Address__c where Id=: bAddress.Id];
            Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='Test Recipient Line 1', Address_Line2__c='Line 2', Address_Line3__c='test', City__c='Long Beach',State__c='California', Postal_Code__c='90805', ERP7__Zip_4__c ='1234',Country__c = 'United States', Is_Shipping_Address__c=true);
            insert sAddress;
            sAddress = [select Id,Customer__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                        Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,ERP7__Zip_4__c,Is_Shipping_Address__c from Address__c where Id=: sAddress.Id];
            Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890');
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
            
            Product2 ps2 = new Product2(Name='test',isActive=true);
            insert ps2;
            
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true, Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim; 
            Credentials__c newCredentials = new Credentials__c(Name='USPS', Active__c=true, Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company', Shipper_Phone_Number__c='1234567890',
                                             Shipper_Email__c='test@test.com', Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='W1T1JY', Shipper_Zip4__c='1234',Shipper_Province__c='Georgia',Shipper_Country__c='United Kingdom',URL__c='https://wsbexpress.dhl.com', 
                                             Encrypted_Key__c='561576bb53d01208f05094f700c4f771a3df829156f89141ca49e1215510a85a',
                                             Username_Login__c='35fdf3ea7158aa2e48a8980624070eedbbb8cfe0fcd075dcca3d7920c187288c', Password_Transkey__c='a0bd9d4bbee0f57521cb98ebfd4adf1d8b5c896bd45236d55aac248af20154b9', UPS_Account_Number__c='7895083910' );
            insert newCredentials;
            Country_Codes__c countryCode = new Country_Codes__c(Name='United States', Code__c='US', Country__c='United States');
            insert countryCode;
            Province_Codes__c ProvinceCode = new Province_Codes__c(Name='Georgia ', Code__c='GA', Province__c='Georgia ');
            insert ProvinceCode;            
            Product_Unit_Code__c puc = new Product_Unit_Code__c(Name='test', Product_Code__c='test', Product_Description__c='test');
            insert puc;            
            Return_Services__c rs = new Return_Services__c(Name='test', Return_Service_Code__c='test', Return_Service_Description__c='test');
            insert rs;
            Reason_For_Export__c reasonForExportList = new Reason_For_Export__c(Name = 'Test Sale', Value__c = 'sale');
            insert reasonForExportList;
            Terms_Of_Shipment__c termsOfShipmentList = new Terms_Of_Shipment__c(Name = 'Test Name', Terms_Of_Shipment_Value__c = 'Test Carriage', Terms_Of_Shipment_Code__c = 'DAF');
            insert termsOfShipmentList;
            RecordType rec = [Select Id From RecordType where sObjectType='ERP7__Process__c' and Name='Manufacturing Process' Limit 1];
            ERP7__Process__c process = new ERP7__Process__c(Name='test', RecordTypeId=rec.Id);
            insert process;
            ERP7__WO__c wo = new ERP7__WO__c(Name='test', ERP7__Sales_Order__c=sod.Id, Shipping_Address__c=sAddress.Id); //, ERP7__Process__c=process.Id
            insert wo;
            Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='USPS',Status__c='test',
                                Description__c='test description',Weight_Unit__c='KGS',Weight__c= 5.0, Width__c = 5.0, Length__c = 5.0, Height__c = 5.0, ERP7__Work_Order__c=wo.Id);
            insert testpack; 
            Package__c testpack1=new Package__c(Name__c='Test Package', Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='USPS', Status__c='test',
                                Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, Width__c = 5.0, Length__c = 5.0, Height__c = 5.0, ERP7__Work_Order__c=wo.Id);
            insert testpack1; 
            Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2, ERP7__Work_Orders__c=wo.Id);
            insert pl1;
            pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;
            String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','USPS_Shipping');
            Shipment__c shipments = new Shipment__c(Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                    UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, Tracking_Number__c = 'EJ123456780US', 
                                    Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
            insert shipments;
            
            test.startTest();
        		
                USPS  uh = new USPS ();
                USPS.rateWrapper rtw = new USPS.rateWrapper();
                USPS.trackwrapper trw = new USPS.trackwrapper();
                
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
                uh.init();
                uh.getProvinceCode('Georgia');
                uh.getCountryCode('United States');
                uh.getStreet('test', 'test' , 'test');
                uh.getStreet('test', 'test' , '');
                uh.getStreet('test', '' , '');
                
                USPS.getCurrencyIsoCode(testpack);
                
                uh.toAddr.Bill_To_Address__c = bAddress.Id;
                uh.fetchAddress();
                uh.fromAddr.Ship_To_Address__c = sAddress.Id;
                uh.fetchAddress();
                uh.getretValue();
                String s ='test';
                uh.setretValue(s);
                uh.CreateUSPSLabel();
                
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
                uh.errorMsg = '';
                uh.Shipping_Rate();
                uh.fromAddress.Postal_Code__c = null;
                uh.Shipping_Rate();
                uh.fromAddress.Postal_Code__c = '';
                uh.Shipping_Rate();
                uh.fromAddress.Country__c = null;
                uh.Shipping_Rate();
                uh.fromAddress.Country__c = '';
                uh.Shipping_Rate();
                uh.shippingAddress.Postal_Code__c = null;
                uh.Shipping_Rate();
                uh.shippingAddress.Postal_Code__c = '';
                uh.Shipping_Rate();
                uh.shippingAddress.Country__c = null;
                uh.Shipping_Rate();
                uh.Shipment.Shipment_Date__c = null;
                uh.Shipping_Rate();
                uh.Shipment.Status__c = 'Shipped';
                uh.USPS_Returned_Error = True;
        		uh.Shipping_Rate();
                uh.Shipment.Status__c = 'Delivered';
                uh.USPS_Returned_Error = false;
        		uh.Shipping_Rate();
        		
                String soapXML = 'System.HttpRequest[Endpoint=http://production.shippingapis.com/ShippingAPI.dll?API=RateV4&XML=%3CRateV4Request+USERID%3D%22329AQXOL3838%22%3E%3CPackage+ID%3D%220%22%3E%3CService%3EPRIORITY%3C%2FService%3E%3CZipOrigination%3E44106%3C%2FZipOrigination%3E%3CZipDestination%3E20770%3C%2FZipDestination%3E%3CPounds%3E1%3C%2FPounds%3E%3COunces%3E8%3C%2FOunces%3E%3CContainer%3ENONRECTANGULAR%3C%2FContainer%3E%3CSize%3ELARGE%3C%2FSize%3E%3CWidth%3E15%3C%2FWidth%3E%3CLength%3E30%3C%2FLength%3E%3CHeight%3E15%3C%2FHeight%3E%3CGirth%3E60%3C%2FGirth%3E%3C%2FPackage%3E%3C%2FRateV4Request%3E, Method=GET]';
                uh.Shipping_Rate_Request(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), '2018-05-18');
                
                String rateXmlString = '<RateV4Response><Package ID="0"><ZipOrigination>44106</ZipOrigination><ZipDestination>20770</ZipDestination><Pounds>1</Pounds><Ounces>8</Ounces><Container>NONRECTANGULAR</Container><Size>LARGE</Size><Zone>3</Zone><Postage CLASSID="1"><MailService>Priority Mail 2-Day&amp;lt;sup&amp;gt;&amp;#8482;&amp;lt;/sup&amp;gt;</MailService><Rate>25.35</Rate></Postage></Package></RateV4Response>';
                XmlStreamReader xsr1 = new XmlStreamReader(rateXmlString); 
                uh.readXMLResponseRateTransitDetails(xsr1,'Package');
  
                XmlStreamReader xsr2 = new XmlStreamReader(rateXmlString); 
                uh.readXMLResponse(xsr2,'ZipOrigination');
                
        		String errorString = '<RateV4Response><Error><Number>-2147219498</Number><Source>DomesticRatesV4;RateEngineV4.ProcessRequest</Source><Description>Please enter a valid ZIP Code for the sender.</Description><HelpFile></HelpFile><HelpContext>1000440</HelpContext></Error></RateV4Response>';
        		XmlStreamReader xsr3 = new XmlStreamReader(errorString); 
        		uh.ParseUSPSErrorXML(xsr3);
        
                packList.add(testpack1);
                uh.Shipping_Request();  
                
                uh.resStatus = 'OK'; 
                String shipmentDate = '2018-05-18';
        		uh.amount = '10';
                uh.Shipping_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'LIBRARY', shipmentDate);
                uh.Cancel_Request();
                uh.Shipment.Status__c = 'Shipped';
                uh.Cancel_Request();
                uh.Shipment.Shipment_Date__c = System.Today() + 1;
                try { uh.Cancel_Request(); } catch(Exception e) {}
                uh.Shipment.Pickup_Requested__c = false;
                try { uh.Cancel_Request(); } catch(Exception e) {}
                uh.Cancel_Request_Reply(JSON.serialize(shipments),JSON.serialize(packList));
        
        		uh.PickupAvailability();
                uh.Shipment.Package_Ready_Time__c  = System.Now() + 1;
                uh.PickupAvailability();
        		
        		try { uh.PickupAvailability_Reply(JSON.serialize(bAddress), JSON.serialize(packList), JSON.serialize(shipments), 'test'); } catch(Exception e) {}
                try { uh.CreatePickup(); } catch(Exception e) {}
        		   
                uh.Shipment.Pickup_Requested__c = true;
                uh.CancelPickup(); 
        		uh.Shipment.Pickup_Confirmation_Number__c = 'Test';
                uh.CancelPickup();
        		uh.Shipment.Package_Ready_Time__c = null;
                try { uh.CancelPickup(); } catch(Exception e) {}
                try { uh.CancelPickup_Reply(JSON.serialize(bAddress), JSON.serialize(shipments), JSON.serialize(packList)); } catch(Exception e) {}
        
                try { uh.Track_Request(); } catch(Exception e) {}
        		try { uh.Track_Request_Reply(JSON.serialize(shipments),JSON.serialize(packList)); } catch(Exception e) {}
                
                
                String trackXmlString = '<TrackResponse><TrackInfo ID="XXXXXXXXXX1"><TrackSummary><EventTime>10:45 pm</EventTime><EventDate>January 6, 2016</EventDate><Event>Arrived at USPS Facility</Event><EventCity>COLUMBUS</EventCity><EventState>OH</EventState><EventZIPCode>43218</EventZIPCode><EventCountry>Country</EventCountry><FirmName>Firm Name</FirmName><Name>Name</Name><AuthorizedAgent>false</AuthorizedAgent></TrackSummary><TrackDetail><EventTime>9:10 am</EventTime><EventDate>January 6, 2016</EventDate><Event>Acceptance</Event><EventCity>LAKE CHARLES</EventCity><EventState>IL</EventState><EventZIPCode>12345</EventZIPCode><EventCountry>Country</EventCountry><FirmName></FirmName><Name>Name</Name><AuthorizedAgent>false</AuthorizedAgent></TrackDetail></TrackInfo></TrackResponse>';
                XmlStreamReader xsr5 = new XmlStreamReader(trackXmlString);
                uh.readXMLResponseTrackHistory(xsr5,'TrackResponse'); 
                
                
                try { uh.Signature_Proof(); } catch(Exception e) {}
                uh.Shipment.Status__c = 'Delivered';
                try { uh.Signature_Proof(); } catch(Exception e) {}
                
                Shipment__c Shipment = shipments;
                String shipDate = '2018-04-03';
                uh.Signature_Proof_Reply(JSON.serialize(Shipment), shipDate, JSON.serialize(bAddress));
                String xmlString5 = '<PTSPODRESULT><ResultText>Your Proof of Delivery record is complete and will be processed shortly.</ResultText><ReturnCode>0</ReturnCode></PTSPODRESULT>';             
                System.assertEquals(contact.Email, 'test@test.com');                  
            test.stopTest();              
        //} catch(Exception e) {}
    }
}