@isTest 
private class FedexHandlerTestCaseSet {    
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
            
            Product2 ps2 = new Product2(Name='test',isActive=true, ERP7__Weight__c = 5.0, ERP7__Width__c = 5.0, ERP7__Height__c = 5.0, ERP7__Length__c = 5.0, ERP7__Weight_Dimensions__c = 'KGS');
            insert ps2;
            List<Product2> prodList = new List<Product2>();
            prodList.add(ps2);
            
            Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true, Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
            insert solim; 
            Credentials__c newCredentials = new Credentials__c(Name='Fedex', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                             Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                             Shipper_Province__c='California',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='b41c58070d0e2f1158e22908fa040a3e338b63b437ec23a0ef533944dd2278ae',
                                             Username_Login__c='Fedex', Password_Transkey__c='9399519ff7e2318ae7ea29ed7ccba7e28822517b475c2fd406d37c831ace9e2b9cc46397e2fe8f33e583bd37a60edb60',
                                             Meter_Number__c='100175015',UPS_Account_Number__c='RY9704', Parent_Password__c='FwSr0GnMFJ4ZhN93cUfXxslVm', Parent_Key__c='tEkXuBO9dc6aX7bG');
            insert newCredentials;
            Country_Codes__c countryCode = new Country_Codes__c(Name='United States', Code__c='US', Country__c='United States');
            insert countryCode;
            Province_Codes__c ProvinceCode = new Province_Codes__c(Name='California', Code__c='CA', Province__c='California');
            insert ProvinceCode;             
            Product_Unit_Code__c puc = new Product_Unit_Code__c(Name='test', Product_Code__c='PUC Code', Product_Description__c='PUC Code');
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
            Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',ETD__c =true,
                                Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id);
            insert testpack; 
            Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id);
            insert testpack1; 
            Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2, ERP7__Work_Orders__c=wo.Id);
            insert pl1;
            pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;
        
            
            String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
            Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                    UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, Tracking_Number__c = '1234567878', 
                                    Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
            insert shipments;
            
            
                
            test.startTest();
                FEDEXHandler uh = new FEDEXHandler();
                /*FEDEXHandler.rateWrapper rtw = new FEDEXHandler.rateWrapper();
                FEDEXHandler.trackwrapper trw = new FEDEXHandler.trackwrapper();
                
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
                uh.shipperProvinceCode = uh.getProvinceCode('California');
                uh.getCountryCode('United States');
                uh.getStreet('test', 'test' , 'test');
                uh.getStreet('test', 'test' , '');
                uh.getStreet('test', '' , '');
                uh.getIsUPSPaperlessInvoice('United States');
                FEDEXHandler.getCurrencyIsoCode(testpack);
                
                uh.toAddr.Bill_To_Address__c = bAddress.Id;
                uh.fetchAddress();
                uh.fromAddr.Ship_To_Address__c = sAddress.Id;
                uh.fetchAddress();
                uh.getretValue();
                String s ='test';
                uh.setretValue(s);
                uh.CreateFedexLabel();
                
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
                uh.RedirectFedexEulaPdf();
                List<Package__c> packList = new List<Package__c>{testpack};
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
                uh.Shipping_Rate();
                uh.Shipment.Status__c = 'Delivered';
                uh.Shipping_Rate();
                String soapXML = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="https://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="https://www.w3.org/2001/XMLSchema" xmlns="https://fedex.com/ws/rate/v20">';
                uh.Shipping_Rate_Request(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test');
                
                String rateXmlString = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><RateReply xmlns="https://fedex.com/ws/rate/v20"><HighestSeverity>SUCCESS</HighestSeverity><Notifications><Severity>SUCCESS</Severity><Source>crs</Source><Code>304</Code><Message>SUCCESS</Message><LocalizedMessage>SUCCESS</LocalizedMessage></Notifications><Notifications><Severity>SUCCESS</Severity><Source>crs</Source><Code>872</Code><Message>SUCCESS</Message><LocalizedMessage>SUCCESS</LocalizedMessage><MessageParameters><Id>SERVICE_TYPE_1</Id><Value>INTERNATIONAL_ECONOMY</Value></MessageParameters></Notifications><Notifications><Severity>NOTE</Severity><Source>crs</Source><Code>886</Code><Message>Money Back Guarantee is not eligible for this pick up/delivery postal/zip code. FDXG</Message><LocalizedMessage>Money Back Guarantee is not eligible for this pick up/delivery postal/zip code. FDXG</LocalizedMessage><MessageParameters><Id>OPERATING_COMPANY</Id><Value>FDXG</Value></MessageParameters></Notifications><TransactionDetail><CustomerTransactionId>US_PRIORITY_OVERNIGHTwithYourPackaging</CustomerTransactionId></TransactionDetail><Version><ServiceId>crs</ServiceId><Major>20</Major><Intermediate>0</Intermediate><Minor>0</Minor></Version><RateReplyDetails><ServiceType>INTERNATIONAL_PRIORITY</ServiceType><PackagingType>YOUR_PACKAGING</PackagingType><DestinationAirportId>YYZ</DestinationAirportId><IneligibleForMoneyBackGuarantee>false</IneligibleForMoneyBackGuarantee><OriginServiceArea>A1</OriginServiceArea><DestinationServiceArea>AM</DestinationServiceArea><SignatureOption>SERVICE_DEFAULT</SignatureOption><ActualRateType>PAYOR_ACCOUNT_SHIPMENT</ActualRateType><RatedShipmentDetails><ShipmentRateDetail><RateType>PAYOR_ACCOUNT_SHIPMENT</RateType><RateScale>0000000</RateScale><RateZone>US001O</RateZone><PricingCode>ACTUAL</PricingCode><RatedWeightMethod>ACTUAL</RatedWeightMethod><CurrencyExchangeRate><FromCurrency>USD</FromCurrency><IntoCurrency>USD</IntoCurrency><Rate>1.0</Rate></CurrencyExchangeRate><DimDivisor>139</DimDivisor><DimDivisorType>COUNTRY</DimDivisorType><FuelSurchargePercent>3.5</FuelSurchargePercent><TotalBillingWeight><Units>LB</Units><Value>60.0</Value></TotalBillingWeight><TotalBaseCharge><Currency>USD</Currency><Amount>420.55</Amount></TotalBaseCharge><TotalFreightDiscounts><Currency>USD</Currency><Amount>0.0</Amount></TotalFreightDiscounts><TotalNetFreight><Currency>USD</Currency><Amount>420.55</Amount></TotalNetFreight><TotalSurcharges><Currency>USD</Currency><Amount>14.72</Amount></TotalSurcharges><TotalNetFedExCharge><Currency>USD</Currency><Amount>435.27</Amount></TotalNetFedExCharge><TotalTaxes><Currency>USD</Currency><Amount>0.0</Amount></TotalTaxes><TotalNetCharge><Currency>USD</Currency><Amount>435.27</Amount></TotalNetCharge><TotalRebates><Currency>USD</Currency><Amount>0.0</Amount></TotalRebates><TotalDutiesAndTaxes><Currency>USD</Currency><Amount>0.0</Amount></TotalDutiesAndTaxes><TotalAncillaryFeesAndTaxes><Currency>USD</Currency><Amount>0.0</Amount></TotalAncillaryFeesAndTaxes><TotalDutiesTaxesAndFees><Currency>USD</Currency><Amount>0.0</Amount></TotalDutiesTaxesAndFees><TotalNetChargeWithDutiesAndTaxes><Currency>USD</Currency><Amount>435.27</Amount></TotalNetChargeWithDutiesAndTaxes><Surcharges><SurchargeType>FUEL</SurchargeType><Description>Fuel</Description><Amount><Currency>USD</Currency><Amount>14.72</Amount></Amount></Surcharges></ShipmentRateDetail></RatedShipmentDetails></RateReplyDetails></RateReply></SOAP-ENV:Body></SOAP-ENV:Envelope>';
                XmlStreamReader xsr1 = new XmlStreamReader(rateXmlString); 
                uh.readXMLResponseRateTransitDetails(xsr1,'RateReplyDetails');           
                
                packList.add(testpack1);
                uh.Shipping_Request();  
                
                
                packList[0].ETD__c = true;
                uh.Shipping_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test');
                uh.retValue = 'SR'; 
                uh.Shipment.Email_from_Third_Party__c = true;
                uh.Shipping_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test');
                uh.MasterTrackingId = '123123123';
                uh.amount = '10.00';
                uh.Shipping_Request_Reply(JSON.serialize(bAddress), JSON.serialize(sAddress), JSON.serialize(packList), 'test', 'test');
                uh.Cancel_Request();
                uh.Shipment.Status__c = 'Shipped';
                uh.Cancel_Request();
                uh.Shipment.Shipment_Date__c = System.Today() + 1;
                try { uh.Cancel_Request(); } catch(Exception e) {}
                uh.Shipment.Pickup_Requested__c = false;
                try { uh.Cancel_Request(); } catch(Exception e) {}
                                
                uh.PickupAvailability();
                uh.Shipment.Package_Ready_Time__c  = System.Now() + 1;
                uh.PickupAvailability();
                uh.Shipment.Customer_Close_Time__c = System.Now() + 1;
                try { uh.PickupAvailability(); } catch(Exception e) {}
                try { uh.PickupAvailability_Reply(JSON.serialize(bAddress), JSON.serialize(packList), JSON.serialize(shipments), 'test', 'test', 'test'); } catch(Exception e) {}
                
                uh.Shipment.Fedex_Service__c = 'test';  
                uh.Shipment.Package_Ready_Time__c  = System.Now() + 1; 
                uh.Shipment.Customer_Close_Time__c = System.Now() + 1;  
                try { uh.CreatePickup(); } catch(Exception e) {}
                  
                uh.Shipment.Pickup_Requested__c = true;
                uh.CancelPickup();
                uh.Shipment.Pickup_Confirmation_Number__c = 'Test';
                uh.CancelPickup();
                uh.Shipment.Package_Ready_Time__c = null;
                try { uh.CancelPickup(); } catch(Exception e) {}
                try { uh.CancelPickup_Reply(JSON.serialize(shipments), JSON.serialize(packList), 'test'); } catch(Exception e) {}
                
                try { uh.Track_Request(); } catch(Exception e) {}
                String trackXmlString = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><TrackReply xmlns="https://fedex.com/ws/track/v6"><HighestSeverity>SUCCESS</HighestSeverity><Notifications><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notifications><TransactionDetail><CustomerTransactionId>Ground Track By Number</CustomerTransactionId></TransactionDetail><Version><ServiceId>trck</ServiceId><Major>6</Major><Intermediate>0</Intermediate><Minor>0</Minor></Version><MoreData>false</MoreData><TrackDetails><Notification><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notification><TrackingNumber>122816215025810</TrackingNumber><TrackingNumberUniqueIdentifier>12013~122816215025810~FDEG</TrackingNumberUniqueIdentifier><StatusCode>DL</StatusCode><StatusDescription>Delivered</StatusDescription><CarrierCode>FDXG</CarrierCode><OtherIdentifiers><Value>PO#174724</Value><Type>CUSTOMER_REFERENCE</Type></OtherIdentifiers><ServiceInfo>FedEx Ground</ServiceInfo><ServiceType>FEDEX_GROUND</ServiceType><PackageWeight><Units>LB</Units><Value>21.5</Value></PackageWeight><Packaging>Package</Packaging><PackagingType>YOUR_PACKAGING</PackagingType><PackageSequenceNumber>1</PackageSequenceNumber><PackageCount>1</PackageCount><ActualDeliveryTimestamp>2014-01-09T13:31:00-05:00</ActualDeliveryTimestamp><ActualDeliveryAddress><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><CountryCode>US</CountryCode><Residential>false</Residential></ActualDeliveryAddress><DeliverySignatureName>ROLLINS</DeliverySignatureName><SignatureProofOfDeliveryAvailable>true</SignatureProofOfDeliveryAvailable><NotificationEventsAvailable>ON_DELIVERY</NotificationEventsAvailable><RedirectToHoldEligibility>INELIGIBLE</RedirectToHoldEligibility><Events><Timestamp>2014-01-09T13:31:00-05:00</Timestamp><EventType>DL</EventType><EventDescription>Delivered</EventDescription><Address><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><PostalCode>24273</PostalCode><CountryCode>US</CountryCode><Residential>false</Residential></Address><ArrivalLocation>DELIVERY_LOCATION</ArrivalLocation></Events></TrackDetails></TrackReply></SOAP-ENV:Body></SOAP-ENV:Envelope>';
                XmlStreamReader xsr5 = new XmlStreamReader(trackXmlString);
                uh.readXMLResponseTrackHistory(xsr5,'Events'); 
                
                try { uh.Signature_Proof(); } catch(Exception e) {}
                uh.Shipment.Status__c = 'Delivered';
                try { uh.Signature_Proof(); } catch(Exception e) {}
                
                Shipment__c Shipment = shipments;
                String shipDate = '05/05/2017';
                uh.Signature_Proof_Reply(JSON.serialize(Shipment), JSON.serialize(sAddress));
                String xmlString5 = '<soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="https://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
                XmlStreamReader xsr51 = new XmlStreamReader(xmlString5);
                
                String xmlString52 = '<soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="https://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
                XmlStreamReader xsr52 = new XmlStreamReader(xmlString52);
                
                String xmlString53 = '<soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="https://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
                XmlStreamReader xsr53 = new XmlStreamReader(xmlString53);
                
                String xmlString54 = '<soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="https://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
                XmlStreamReader xsr54 = new XmlStreamReader(xmlString54);
                
                FEDEXHandler.readXMLResponse(xsr51,'test');
                FEDEXHandler.readXMLResponseFirstValue(xsr52,'test');
                FEDEXHandler.readXMLResponseOnce(xsr53,'test');*/
                List<Package__c> packList = new List<Package__c>();
                ShippingRates.rateWrapper rwap = new ShippingRates.rateWrapper();
                ShippingRates.Shipping_Request_Reply(packList, sAddress.Id, bAddress.Id, '2022-07-20', 'test', 'test', JSON.serialize(rwap), prodList);
                System.assertEquals(contact.Email, 'test@test.com');
            test.stopTest();             
        //} catch(Exception e) {}
    }
    
    static testMethod void unitTestCase2() {
        Credentials__c fedUsr = new Credentials__c();
        Country_Codes__c countryCode = new Country_Codes__c(Name='England', Code__c='GB', Country__c='England');
        insert countryCode;
        Province_Codes__c ProvinceCode = new Province_Codes__c(Name='Greater London', Code__c='JS', Province__c='Greater London');
        insert ProvinceCode; 
        
        test.startTest();
        
            FedexRegister fedReg = new FedexRegister();
            fedReg.Panel1();
            fedReg.Panel2();
            fedReg.RedirectFedexEulaPdf();
            fedReg.CancelBtn();
            fedReg.getProvinceCode('England');
            fedReg.getCountryCode('Greater London');
        
        
            fedUsr.Shipper_Name__c         = 'Mohammed Uzair';
            fedUsr.Shipper_Company_Name__c = 'Aqxolt Ltd';
            fedUsr.Shipper_Street__c       = '14 TOTTENHAM COURT ROAD';
            fedUsr.Shipper_City__c         = 'London';
            fedUsr.Shipper_Province__c     = 'Greater London';
            fedUsr.Shipper_Postal_Code__c  = 'W1T1JY';
            fedUsr.Shipper_Country__c      = 'England';
            fedUsr.Shipper_Email__c        = 'mohammed.uzair@aqxolt.com';
            fedUsr.Shipper_Phone_Number__c = '+919741788657';
            fedUsr.Company_URL__c          = 'www.aqxolt.com';
            
           // FedexRegister fedReg1 = new FedexRegister();
            
            System.Test.setMock(HTTPCalloutMock.class, new MockHttpResponseGenerator());
            String soapXML = '<soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/" xmlns="https://fedex.com/ws/registration/v7">';
            
            fedReg.fedexUser = fedUsr;
            
            fedReg.RegisterRequest();
            String regXmlString = '<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"/><SOAP-ENV:Body xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"><v7:RegisterWebUserReply xmlns:v7="https://fedex.com/ws/registration/v7"><v7:HighestSeverity>SUCCESS</v7:HighestSeverity><v7:Notifications><v7:Severity>SUCCESS</v7:Severity><v7:Source>fcas</v7:Source><v7:Code>0000</v7:Code><v7:Message>Success</v7:Message></v7:Notifications><v7:TransactionDetail><v7:CustomerTransactionId>FedEx - Register User</v7:CustomerTransactionId></v7:TransactionDetail><v7:Version><v7:ServiceId>fcas</v7:ServiceId><v7:Major>7</v7:Major><v7:Intermediate>0</v7:Intermediate><v7:Minor>0</v7:Minor></v7:Version><v7:UserCredential><v7:Key>9xONGetYWjW13zOC</v7:Key><v7:Password>22r197KghmMmiU4Bu4Tbie3tP</v7:Password></v7:UserCredential></v7:RegisterWebUserReply></SOAP-ENV:Body></soapenv:Envelope> ';
            XmlStreamReader xsr1 = new XmlStreamReader(regXmlString); 
            
            fedReg.Subscription('9xONGetYWjW13zOC', '22r197KghmMmiU4Bu4Tbie3tP');
            String subXmlString = '<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"/><SOAP-ENV:Body xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"><v7:SubscriptionReply xmlns:v7="https://fedex.com/ws/registration/v7"><v7:HighestSeverity>SUCCESS</v7:HighestSeverity><v7:Notifications><v7:Severity>SUCCESS</v7:Severity><v7:Source>auto</v7:Source><v7:Code>0000</v7:Code><v7:Message/><v7:LocalizedMessage/></v7:Notifications><v7:Version><v7:ServiceId>fcas</v7:ServiceId><v7:Major>7</v7:Major><v7:Intermediate>0</v7:Intermediate><v7:Minor>0</v7:Minor></v7:Version><v7:MeterDetail><v7:MeterNumber>118817497</v7:MeterNumber><v7:GroundShipperNumber/><v7:EpdiCode>ESWSXI0100</v7:EpdiCode><v7:ReconcileTime> 04:24:07.871</v7:ReconcileTime><v7:GroundTrackingNumberStart/><v7:GroundTrackingNumberEnd/></v7:MeterDetail><v7:RegisteredServices>EXPRESS_SHIPPING</v7:RegisteredServices></v7:SubscriptionReply></SOAP-ENV:Body></soapenv:Envelope>';
            XmlStreamReader xsr2 = new XmlStreamReader(subXmlString);
            
            fedReg.Version_Capture('9xONGetYWjW13zOC', '22r197KghmMmiU4Bu4Tbie3tP','118817497');
            String vcXmlString = '<?xml version="1.0" encoding="UTF-8"?> <soapenv:Envelope xmlns:soapenv="https://schemas.xmlsoap.org/soap/envelope/"><env:Header xmlns:env="https://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance"/><soapenv:Body><v7:VersionCaptureReply xmlns:v7="https://fedex.com/ws/registration/v7"><v7:HighestSeverity xmlns:env="https://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance">SUCCESS</v7:HighestSeverity><v7:Notifications xmlns:env="https://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance"><v7:Severity>SUCCESS</v7:Severity><v7:Source>auto</v7:Source><v7:Code>0000</v7:Code></v7:Notifications><v7:TransactionDetail><v7:CustomerTransactionId>601662400</v7:CustomerTransactionId></v7:TransactionDetail><v7:Version><v7:ServiceId>fcas</v7:ServiceId><v7:Major>7</v7:Major><v7:Intermediate>0</v7:Intermediate><v7:Minor>0</v7:Minor></v7:Version></v7:VersionCaptureReply></soapenv:Body></soapenv:Envelope>';
            XmlStreamReader xsr3 = new XmlStreamReader(vcXmlString);
        FedexRegister.readXMLResponse(xsr3,'Severity');
            System.assertEquals(countryCode.Name, 'England');
            
        test.stopTest();
        
    }
}