@isTest
public class CanadaPost_TestClass {
    
    @isTest static void unitTestCase1() {
        Account orgn = new Account(Name='Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier');
        insert sup;
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
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id,Address__c = sAddress.Id);
        insert site;
        Distribution_Channel__c salepoint = new Distribution_Channel__c(Name='Test',Active__c=true,Primary__c=true,Site__c=site.id);
        insert salepoint;    
        
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware',IsActive=TRUE);
        insert pro;
        Product2 pro1 = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro1;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        //update standardPricebook;       
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        PricebookEntry pbe1 = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = pro1.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe1;
        Order sod = new Order(Name = 'Test Order',Status = 'Draft',EffectiveDate = system.today(),EndDate = system.today() + 4,
                              AccountId = Contact.AccountId,Pricebook2Id=standardPricebook.Id,Expected_Date__c=Date.today(),
                              Stage__c='Entered');  
        sod.Bill_To_Address__c = bAddress.Id; sod.Ship_To_Address__c = sAddress.Id;
        insert sod;
        
        
        
        Order psod = [Select id, Name From Order Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        OrderItem solim = new OrderItem(OrderId = sod.Id,Quantity = 1,UnitPrice = 100,Product2Id = pro.Id,PricebookEntryId=pbe.Id);        
        insert solim;
        
        
        Credentials__c newCredentials = new Credentials__c(Name='Canada Post', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                           Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='V6B4A2',
                                                           Shipper_Province__c='California',Account_Id__c='42708517',Shipper_Country__c='United States',URL__c='https://ct.soa-gw.canadapost.ca', Encrypted_Key__c='6233e47bd5de267af2b7e59ae6266073c1d5ad3f3493d2b8facd8fece9e782c4',
                                                           Username_Login__c='ea936dca391225074832374e8a1fa29357658a4d28dae5dc3a65bf0072f76e443179086f148d8e1439c4253dfe4e4e34', Password_Transkey__c='38b44386e2fdd56a87a009be2593426eeffc7f6bf4664cb3a1389414e3ae7690d65eaa54cba1845e9419c9114f0099f3',
                                                           UPS_Account_Number__c='11110000');
        insert newCredentials;
        List<Credentials__c> newCredentialsList = new List<Credentials__c>();
        newCredentialsList.add(newCredentials);
        System.debug('newCredentials:'+newCredentials.URL__c);
        CanadaPost.credentialWrapper credWrap= new CanadaPost.credentialWrapper();
        credWrap.CPCredentials=newCredentialsList;
        credWrap.password=newCredentialsList[0].Password_Transkey__c;
        credWrap.username=newCredentialsList[0].Username_Login__c;
        credWrap.endPoint=newCredentialsList[0].URL__c;
        credWrap.accountNumber=newCredentialsList[0].UPS_Account_Number__c;
        credWrap.contractNumber=newCredentialsList[0].Account_Id__c;
        credWrap.PostalCode=newCredentialsList[0].Shipper_Postal_Code__c;
        credWrap.Email=newCredentialsList[0].Shipper_Email__c;
        
        Country_Codes__c countryCode = new Country_Codes__c(Name='United States', Code__c='US', Country__c='United States');
        insert countryCode;
        Province_Codes__c ProvinceCode = new Province_Codes__c(Name='California', Code__c='CA', Province__c='California');
        insert ProvinceCode;             
        Product_Unit_Code__c puc = new Product_Unit_Code__c(Name='test', Product_Code__c='Box', Product_Description__c='Box');
        insert puc;             
        Return_Services__c rs = new Return_Services__c(Name='test', Return_Service_Code__c='test', Return_Service_Description__c='test');
        insert rs;
        Reason_For_Export__c reasonForExportList = new Reason_For_Export__c(Name = 'Test Sale', Value__c = 'sale');
        insert reasonForExportList;
        Terms_Of_Shipment__c termsOfShipmentList = new Terms_Of_Shipment__c(Name = 'Test Name', Terms_Of_Shipment_Value__c = 'Test Carriage', Terms_Of_Shipment_Code__c = 'DAF');
        insert termsOfShipmentList;
        Return_Merchandise_Authorisation__c rma = new Return_Merchandise_Authorisation__c(Name='test', Distribution_Channel__c=salepoint.Id, Address__c=sAddress.Id);
        insert rma;
        Package__c testpack=new Package__c(Name='Test Package',Package_Type__c = 'Package', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='Shipped',
                                           Description__c='https://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/manifest/370961732103878371\nhttps://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/shipment?manifestId=370961732103878371',Weight_Unit__c='KGS',Weight__c=5.0, Length__c=5.0,Width__c=5.0,Height__c=5.0,Declared_Value__c=999.99, Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack;
        
        Package__c testpack1=new Package__c(Name='Test Package', ETD__c=true, Package_Type__c = 'Package', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='Shipped',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0,  Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack1; 
        
        PO__c PO1 = new PO__c(Name = 'testPO1', Vendor__c = sup.Id,  Distribution_Channel__c = salepoint.Id, Organisation__c = orgn.Id, Ready_To_Receive__c = false);
        insert PO1;
        Purchase_Line_Items__c pli = new Purchase_Line_Items__c(Name = 'testPOLI1',Purchase_Orders__c=PO1.Id,Product__c = ps.Id,Unit_Price__c = 10,Quantity__c=3);
        insert pli;
        
        
        RMA_Line_Item__c rli = new RMA_Line_Item__c(Name='Test', Active__c=true, Return_Merchandise_Authorisation__c=rma.Id, Return_Status__c='Quality Check');
        insert rli;
        
        /*Package_Line_Item__c pl1 = new Package_Line_Item__c(Name = 'Test List', Order_Product__c=solim.Id, Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
insert pl1;
Package_Line_Item__c pl2 = new Package_Line_Item__c(Name = 'Test List', Purchase_Line_Items__c = pli.Id, Purchase_Order__c=PO1.Id, Package__c = testpack.Id, Quantity__c = 2);
insert pl2;
Package_Line_Item__c pl3 = new Package_Line_Item__c(Name = 'Test List', RMA_Line_Item__c = rli.Id, Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2);
insert pl3;*/
        //pl1 = [select Id, Name, Order_Product__c, Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_Line_Item__c where Id=: pl1.Id];
        
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Canada_Post_shipping');
        Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'Box', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'LB', UPS_Package_Weight_Unit__c = 'LBS', Description__c='https://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/manifest/370961732103878371\nhttps://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/shipment?manifestId=370961732103878371',
                                                UPS_Package_Type__c = 'Package',Shipment_Type__c = 'Residential',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, Tracking_Number__c = '123456789012', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        
        test.startTest();
        CanadaPost fed = new CanadaPost();
        CanadaPost.request_UD = '';
        CanadaPost.response_UD = '';
        CanadaPost.resStatusUD = '';
        CanadaPost.errorMsg1 = '';
        CanadaPost.errorMsg='';
        CanadaPost.MasterTrackingId='';
        CanadaPost.amount= CanadaPost.result = '';
        CanadaPost.CPCredentials = new List<Credentials__c>();
        CanadaPost.Shipment = new Shipment__c();
        
        
        CanadaPost.credentialWrapper mcw = new CanadaPost.credentialWrapper();
        CanadaPost.CPWrapper fw = new CanadaPost.CPWrapper();
        CanadaPost.rateWrapper rw = new CanadaPost.rateWrapper();
        CanadaPost.trackwrapper tw = new CanadaPost.trackwrapper();
        tw.dtValue = system.now();
        CanadaPost.getCredentialDetails(shipments.Id,'','');
        CanadaPost.getCredentialDetails('','','');
        String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
        CanadaPost.getStreet(AddressLine1,AddressLine2,AddressLine3);
        
        CanadaPost.getStreet(AddressLine1,AddressLine2,'');
        CanadaPost.getStreet(AddressLine1,'','');
        CanadaPost.getStreet('','','');
        CanadaPost.checkCred();
       
        
        List<string> packageId = new List<string>{testpack.Id};
            List<string> packageId2 = new List<string>{shipments.Id,testpack.Id};
                CanadaPost.fetchingPackages(JSON.serialize(packageId));
        
        try{
            CanadaPost.fetchingPackages('hgfjh');
        }catch(Exception e){
            
        }
        CanadaPost.fetchingPackages(JSON.serialize(packageId));
        
        CanadaPost.getTermsOfShipment();
        CanadaPost.getServices();
        CanadaPost.getReasonForExport();
        CanadaPost.getShipmentsStatus();
        CanadaPost.getStatusConfirmation();
        String provinceName = newCredentials.Shipper_Province__c;
        CanadaPost.getProvinceCode(provinceName);
        String countryName = newCredentials.Shipper_Country__c;
        CanadaPost.getCountryCode(countryName);
        CanadaPost.fetchToAddress(JSON.serialize(packageId));
        CanadaPost.fetchFromAddress(JSON.serialize(packageId));
        List<Package__c> packList = new List<Package__c>{testpack};
            String fromAdd=sAddress.Id;//rma.Ship_From_Address__c; 
        String tAddress=rma.Address__c;
        Datetime dt = System.NOW();
        String shipDate = string.valueOf(dt);
        String stime = '11:00AM';
        String ctime = '8:00PM';
        String ShipService = 'Dc';
        String myConsVar = 'test';
        CanadaPost.Shipping_Rate_Request(packList,fromAdd,tAddress,shipDate,ShipService,JSON.serialize(credWrap));        
        CanadaPost.Refund_Request_Reply(JSON.serialize(shipments),packList,tAddress,fromAdd,JSON.serialize(credWrap));
         CanadaPost.Void_Request_Reply(JSON.serialize(shipments),packList,tAddress,JSON.serialize(credWrap));
        CanadaPost.Transmit_Request_Reply(JSON.serialize(shipments),packList,tAddress,fromAdd,JSON.serialize(credWrap));
        String salName = 'logistic';
        String sal1Name = 'logistic';
        System.assertEquals(salName, sal1Name);
        
        CanadaPost.Shipping_Request_Reply(packList,fromAdd,tAddress,ShipService,JSON.serialize(credWrap),JSON.serialize(shipments),JSON.serialize(rw));
        // CanadaPost.PickupAvailability_Reply(fromAdd,JSON.serialize(CanadaPost.getCredentialDetails('','','')));
        // CanadaPost.CreatePickup_Reply(fromAdd,packList,JSON.serialize(shipments),shipDate,stime,ctime,JSON.serialize(CanadaPost.getCredentialDetails('','','')));
        // CanadaPost.CancelPickup_Reply(JSON.serialize(shipments),packList,JSON.serialize(CanadaPost.getCredentialDetails('','','')));
        CanadaPost.Track_Request_Reply(JSON.serialize(shipments),packList,JSON.serialize(credWrap));
        //CanadaPost.Signature_Proof_Reply(JSON.serialize(shipments),JSON.serialize(CanadaPost.getCredentialDetails('','','')));
        
        String strTmp = '<xml><ToUserName>tUN</ToUserName><FromUserName>fUN</FromUserName><MsgType>mT</MsgType></xml>';
        XmlStreamReader reader = new XmlStreamReader(Blob.valueOf(strTmp).toString());
        //CanadaPost.readXMLResponse(reader,'MsgType');
        test.stopTest();
    }
}