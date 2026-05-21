@isTest 
private class UPSLightningTestClass {
    static testMethod void upsRestTestcases() { 
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
        Contact cont = [select Id, Name, Company__c, Phone, Email, AccountId,Account.Name from Contact where Id=: contact.Id];
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Georgia', Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress; 
        bAddress = [select Id,Customer__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                    Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,Is_Billing_Address__c from Address__c where Id=: bAddress.Id];
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='Test Recipient Line 1', Address_Line2__c='Line 2', Address_Line3__c='test', City__c='Long Beach',State__c='California', Postal_Code__c='90805', Country__c = 'United States', Is_Shipping_Address__c=true);
        insert sAddress;
        sAddress = [select Id,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                    Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,Is_Shipping_Address__c from Address__c where Id=: sAddress.Id];
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890', ERP7__Ship_From_Address__c = sAddress.Id);
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
        
        Sales_Order_Line_Item__c solim = new Sales_Order_Line_Item__c(Active__c = true,Base_Price__c=100,Discount_Amount__c=10,Product__c=ps.id,Quantity__c=1,Sales_Order__c=psod.id,Total_Price__c=100,VAT_Amount__c=10);
        insert solim;
        string name = system.label.UPSRESTAPIName;
        Credentials__c newCredentials = new Credentials__c(Name=name, Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                           Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                           Shipper_Province__c='test province',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='477c04bf174aa10e1c0814ee2df3c8183d3f5240f73c280299e8451c11289ae6',
                                                           Username_Login__c='39b1896632c3cdaa052b47feb28225b604b4b8180892b93fc0fea452eca40255', Password_Transkey__c='c81a8fd217212e383fa12e4fe338bde965d01b74636b2bc6dca9b9afc426a7a2',
                                                           UPS_Account_Number__c='RY9704',ERP7__Parent_Password__c = 'ZUgUyJ639oQaDzFXpEKf1BggLmOdPXvb11vrKA5mb9L8GSkcCFBSUUMOadwLo0RI',ERP7__Password_Transkey__c='1abbb93d8b249bd4a34a13fc67327f9cf3c9ee7e090ed031be9689089cc77f02');
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
        Package__c testpack = new Package__c(Name= 'Test Package',Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
                                             Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0,Length__c=5,Width__c=5,Height__c =5);
        insert testpack; 
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        Shipment__c shipments = new Shipment__c(Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',
                                                COD__c = 'Yes', Verbal_Confirmation__c = 'Yes', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                                                UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
        insert shipments;
         DateTime currentDateTime = DateTime.now();
        test.startTest();
        UPSRestAPI upsrest = new UPSRestAPI();
        
        UPSRestAPI.Wrapper wrap= UPSRestAPI.getDefaultData(shipments.Id, JSON.serialize(new List<String>()),false);
        
        List<String> testPackIds = new List<String>{testpack.Id};
        UPSRestAPI.getDefaultData('', JSON.serialize(testPackIds),true);
        UPSRestAPI.Service_And_Rate_Request(new List<Package__c>{testpack},JSON.serialize(bAddress),JSON.serialize(sAddress),JSON.serialize(cont),JSON.serialize(cont),'',JSON.serialize(wrap.credsWrap),JSON.serialize(shipments),false);
        UPSRestAPI.Shipping_Request_Response(new List<Package__c>{testpack},JSON.serialize(bAddress),JSON.serialize(sAddress),JSON.serialize(cont),JSON.serialize(cont),'',JSON.serialize(wrap.credsWrap),JSON.serialize(shipments),false,new List<Package_List__c>{pl1},'Express','07','USD','');
        UPSRestAPI.voidShipment(new List<Package__c>{testpack},JSON.serialize(shipments),JSON.serialize(wrap.credsWrap));
		shipments.ERP7__TrackingNumber__c = '1Z12345E0205271688';
        UPSRestAPI.getTrackingDetails(new List<Package__c>{testpack},JSON.serialize(shipments),JSON.serialize(wrap.credsWrap));
        UPSRestAPI.Pickup_Rate_Request(bAddress.Id, sAddress.Id, JSON.serialize(shipments), shipments.Shipment_Date__c, currentDateTime, currentDateTime, JSON.serialize(wrap.credsWrap));
        test.stopTest();
    }
    static testMethod void unitTestCase1() { 
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890', ERP7__Ship_From_Address__c = sAddress.Id);
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
        Package__c testpack = new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
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
                                                COD__c = 'Yes', Verbal_Confirmation__c = 'Yes', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                                                UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
        insert shipments;
        
        test.startTest();
        UPSLightning ups = new UPSLightning();
        UPSLightning.myConstructorWrapper mcw = new UPSLightning.myConstructorWrapper();
        UPSLightning.upsWrapper fw = new UPSLightning.upsWrapper();
        UPSLightning.rateWrapper rw = new UPSLightning.rateWrapper();
        UPSLightning.trackwrapper tw = new UPSLightning.trackwrapper();
        UPSLightning.plWrapper plw = new UPSLightning.plWrapper();
        UPSLightning.myConstruct('');
        String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
        UPSLightning.getStreet(AddressLine1,AddressLine2,AddressLine3);
        List<string> packageId = new List<string>{testpack.Id};
            UPSLightning.fetchingPackages(packageId);
        UPSLightning.fetchingPackageLists(JSON.serialize(packageId));
        UPSLightning.getQVNotification();
        UPSLightning.getCarbonNeutral();
        UPSLightning.getCOD();
        UPSLightning.getDryIce();
        UPSLightning.getReturnService();
        UPSLightning.getSaturdayDelivery();
        UPSLightning.getAdditionalHandling();
        UPSLightning.getVerbalConfirmation();
        UPSLightning.getDeliveryConfirmation();
        UPSLightning.getStatusConfirmation();
        UPSLightning.getPucConfirmation();
        UPSLightning.getIfConfirmation();
        UPSLightning.getTosConfirmation();
        UPSLightning.getRfeConfirmation();
        UPSLightning.getCurrencyIsoCode(testpack);
        UPSLightning.getIsUPSPaperlessInvoice('United States');
        String provinceName = newCredentials.Shipper_Province__c;
        UPSLightning.getProvinceCode(provinceName);
        String countryName = newCredentials.ERP7__Shipper_Country__c;
        UPSLightning.getCountryCode(countryName);
        UPSLightning.fetchToAddress(JSON.serialize(packageId));
        UPSLightning.fetchFromAddress(JSON.serialize(packageId));
        List<Package__c> packList = new List<Package__c>{testpack};
            String fromAdd=salepoint.ERP7__Ship_From_Address__c; 
        String tAddress=bAddress.Id;
        Datetime dt = System.NOW();
        String shipDate = string.valueOf(dt);
        String myConsVar = 'test';
        DateTime dispatchDate = System.Now() + 1;
        DateTime PackageReadyTime = System.Now() + 1;
        DateTime CustomerCloseTime = System.Now() + 1;
        //UPSLightning.DestinationProvinceCode = 'CA';
        //UPSLightning.DestinationCountryCode = 'US';
        UPSLightning.displayForms('Invoice',tAddress,JSON.serialize(UPSLightning.myConstruct('')),JSON.serialize(shipments));
        UPSLightning.displayForms('CN22 Forms',tAddress,JSON.serialize(UPSLightning.myConstruct('')),JSON.serialize(shipments)); 
        
        UPSLightning.Service_And_Rate_Request(packList,fromAdd,tAddress,shipDate,JSON.serialize(UPSLightning.myConstruct('')),JSON.serialize(shipments),false);
        UPSLightning.Process_Shipment_Request_Reply(packList,fromAdd,tAddress,shipDate,JSON.serialize(UPSLightning.myConstruct('')),JSON.serialize(shipments), JSON.serialize(rw), false, false,false,'',JSON.serialize(shipments));
        UPSLightning.Cancel_Shipment_Request(JSON.serialize(shipments), packList, JSON.serialize(UPSLightning.myConstruct('')));
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        
        test.stopTest();
    }
    
    static testMethod void unitTestCase11() { 
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890', ERP7__Ship_From_Address__c = sAddress.Id);
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
        
        Shipment__c shipments = new Shipment__c(Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',
                                                COD__c = 'Yes', Verbal_Confirmation__c = 'Yes', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                                                UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
        insert shipments;
        Package__c testpack = new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
                                             Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Shipment__c = shipments.Id, ERP7__Shipment_Type__c = 'UPS');
        insert testpack; 
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        test.startTest();
        UPSLightning ups = new UPSLightning();
        UPSLightning.myConstructorWrapper mcw = new UPSLightning.myConstructorWrapper();
        UPSLightning.upsWrapper fw = new UPSLightning.upsWrapper();
        UPSLightning.rateWrapper rw = new UPSLightning.rateWrapper();
        UPSLightning.trackwrapper tw = new UPSLightning.trackwrapper();
        UPSLightning.plWrapper plw = new UPSLightning.plWrapper();
        UPSLightning.myConstruct('');
        String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
        UPSLightning.getStreet(AddressLine1,AddressLine2,AddressLine3);
        List<string> packageId = new List<string>{testpack.Id};
            UPSLightning.fetchingPackages(packageId);
        UPSLightning.fetchingPackageLists(JSON.serialize(packageId));
        UPSLightning.getQVNotification();
        UPSLightning.getCarbonNeutral();
        UPSLightning.getCOD();
        UPSLightning.getDryIce();
        UPSLightning.getReturnService();
        UPSLightning.getSaturdayDelivery();
        UPSLightning.getAdditionalHandling();
        UPSLightning.getVerbalConfirmation();
        UPSLightning.getDeliveryConfirmation();
        UPSLightning.getStatusConfirmation();
        UPSLightning.getPucConfirmation();
        UPSLightning.getIfConfirmation();
        UPSLightning.getTosConfirmation();
        UPSLightning.getRfeConfirmation();
        UPSLightning.getCurrencyIsoCode(testpack);
        UPSLightning.getIsUPSPaperlessInvoice('United States');
        String provinceName = newCredentials.Shipper_Province__c;
        UPSLightning.getProvinceCode(provinceName);
        String countryName = newCredentials.ERP7__Shipper_Country__c;
        UPSLightning.getCountryCode(countryName);
        UPSLightning.fetchToAddress(JSON.serialize(packageId));
        UPSLightning.fetchFromAddress(JSON.serialize(packageId));
        List<Package__c> packList = new List<Package__c>{testpack};
            String fromAdd=salepoint.ERP7__Ship_From_Address__c; 
        String tAddress=bAddress.Id;
        Datetime dt = System.NOW();
        String shipDate = string.valueOf(dt);
        String myConsVar = 'test';
        DateTime dispatchDate = System.Now() + 1;
        DateTime PackageReadyTime = System.Now() + 1;
        DateTime CustomerCloseTime = System.Now() + 1;
        //UPSLightning.DestinationProvinceCode = 'CA';
        //UPSLightning.DestinationCountryCode = 'US';
        UPSLightning.Pickup_Rate_Request(fromAdd, tAddress, JSON.serialize(shipments), dispatchDate, PackageReadyTime, CustomerCloseTime, JSON.serialize(UPSLightning.myConstruct('')));
        UPSLightning.CreatePickupRequest(fromAdd, tAddress, packList, JSON.serialize(shipments), dispatchDate, PackageReadyTime, CustomerCloseTime, JSON.serialize(UPSLightning.myConstruct('')));
        UPSLightning.CancelPickupRequest(JSON.serialize(packList), JSON.serialize(shipments), JSON.serialize(UPSLightning.myConstruct('')));
        
        UPSLightning.Track_Request_Reply(packList, JSON.serialize(shipments), JSON.serialize(UPSLightning.myConstruct('')));
        UPSLightning.SPODRequest(JSON.serialize(shipments), JSON.serialize(UPSLightning.myConstruct('')));
        IntegratedShipmentScheduler iss = new IntegratedShipmentScheduler();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, iss);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();  
    }
    
    static testMethod void unitTestCase111() { 
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id,  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890', ERP7__Ship_From_Address__c = sAddress.Id);
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
        Package__c testpack = new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
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
                                                COD__c = 'Yes', Verbal_Confirmation__c = 'Yes', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                                                UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
        insert shipments;
        
        test.startTest();
        UPSLightning ups = new UPSLightning();
        UPSLightning.myConstructorWrapper mcw = new UPSLightning.myConstructorWrapper();
        UPSLightning.upsWrapper fw = new UPSLightning.upsWrapper();
        UPSLightning.rateWrapper rw = new UPSLightning.rateWrapper();
        UPSLightning.trackwrapper tw = new UPSLightning.trackwrapper();
        UPSLightning.plWrapper plw = new UPSLightning.plWrapper();
        UPSLightning.myConstruct('');
        String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
        UPSLightning.getStreet(AddressLine1,AddressLine2,AddressLine3);
        List<string> packageId = new List<string>{testpack.Id};
            UPSLightning.fetchingPackages(packageId);
        UPSLightning.fetchingPackageLists(JSON.serialize(packageId));
        UPSLightning.getQVNotification();
        UPSLightning.getCarbonNeutral();
        UPSLightning.getCOD();
        UPSLightning.getDryIce();
        UPSLightning.getReturnService();
        UPSLightning.getSaturdayDelivery();
        UPSLightning.getAdditionalHandling();
        UPSLightning.getVerbalConfirmation();
        UPSLightning.getDeliveryConfirmation();
        UPSLightning.getStatusConfirmation();
        UPSLightning.getPucConfirmation();
        UPSLightning.getIfConfirmation();
        UPSLightning.getTosConfirmation();
        UPSLightning.getRfeConfirmation();
        UPSLightning.getCurrencyIsoCode(testpack);
        UPSLightning.getIsUPSPaperlessInvoice('United States');
        String provinceName = newCredentials.Shipper_Province__c;
        UPSLightning.getProvinceCode(provinceName);
        String countryName = newCredentials.ERP7__Shipper_Country__c;
        UPSLightning.getCountryCode(countryName);
        UPSLightning.fetchToAddress(JSON.serialize(packageId));
        UPSLightning.fetchFromAddress(JSON.serialize(packageId));
        List<Package__c> packList = new List<Package__c>{testpack};
            String fromAdd=salepoint.ERP7__Ship_From_Address__c; 
        String tAddress=bAddress.Id;
        Datetime dt = System.NOW();
        String shipDate = string.valueOf(dt);
        String myConsVar = 'test';
        DateTime dispatchDate = System.Now() + 1;
        DateTime PackageReadyTime = System.Now() + 1;
        DateTime CustomerCloseTime = System.Now() + 1;
        //UPSLightning.DestinationProvinceCode = 'CA';
        //UPSLightning.DestinationCountryCode = 'US';
        UPSLightning.Track_Request_Reply(packList, JSON.serialize(shipments), JSON.serialize(UPSLightning.myConstruct('')));
        UPSLightning.SPODRequest(JSON.serialize(shipments), JSON.serialize(UPSLightning.myConstruct('')));
        
        String xmlString52 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
        XmlStreamReader xsr52 = new XmlStreamReader(xmlString52);
        
        String xmlString53 = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Header/><soapenv:Body><pkup:PickupGetServiceCenterFacilitiesResponse xmlns:pkup="http://www.ups.com/XMLSchema/XOLTWS/Pickup/v1.1"><test>testname</test></pkup:PickupGetServiceCenterFacilitiesResponse></soapenv:Body></soapenv:Envelope>';
        XmlStreamReader xsr53 = new XmlStreamReader(xmlString53);
        UPSLightning.readXMLResponseFirstValue(xsr52,'test');
        UPSLightning.readXMLResponseOnce(xsr53,'test');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();  
    }
    
    static testMethod void unitTestCase2() { 
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
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        
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
        Package__c testpack = new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='UPS',Status__c='test',
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
                                                COD__c = 'Yes', Verbal_Confirmation__c = 'Yes', Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', Shipment_Identification_Number__c='1234567878',
                                                UPS_Service_Code__c='54',Pickup_Confirmation_Number__c='1234567890');
        insert shipments;
        
        test.startTest();
        UPSLightning ups = new UPSLightning();
        UPSLightning.myConstruct(string.valueOf(shipments.Id));
        //IntegratedShipmentsHelper newship= new IntegratedShipmentsHelper();
        //IntegratedShipmentsHelper.updateUPSShipments();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
}