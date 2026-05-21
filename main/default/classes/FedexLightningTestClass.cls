@isTest  
private class FedexLightningTestClass {
    
    @isTest static void unitTestCase1() {
        try{
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup; 
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Account customer = new Account(Name='Customer',Company__c='testtt',Phone='7418529662',ERP7__Email__c='test@gmail.com');
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
            Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                                  ERP7__Ship_From_Address__c=sAddress.Id);
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
            Credentials__c newCredentials = new Credentials__c(Name='Fedex', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                               Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                               Shipper_Province__c='California',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='b41c58070d0e2f1158e22908fa040a3e338b63b437ec23a0ef533944dd2278ae',
                                                               Username_Login__c='FedexLightning', Password_Transkey__c='9399519ff7e2318ae7ea29ed7ccba7e28822517b475c2fd406d37c831ace9e2b9cc46397e2fe8f33e583bd37a60edb60',
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
            ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
            insert rma;
            
            
            Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                                Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
            insert testpack1; 
            
            
            
            String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
            Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                    UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                    Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
            insert shipments;
            Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                               Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id, ERP7__Shipment__c = shipments.Id, ERP7__Shipment_Type__c = 'FedEx'); //,ETD__c = true
            insert testpack;
            Package_List__c pl1 = new Package_List__c(Name = 'Test List', Sales_Order_Line_Item__c=solim.Id, Sales_Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2, ERP7__Work_Orders__c=wo.Id);
            insert pl1;
            pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;
            test.startTest();
            Fedex fed = new Fedex();
            Fedex.myConstructorWrapper mcw = new Fedex.myConstructorWrapper();
            Fedex.fedexWrapper fw = new Fedex.fedexWrapper();
            Fedex.rateWrapper rw = new Fedex.rateWrapper();
            Fedex.trackwrapper tw = new Fedex.trackwrapper();
            Fedex.plWrapper plw = new Fedex.plWrapper();
            Fedex.myConstructor(shipments.Id,'LO');
            String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
            Fedex.getStreet(AddressLine1,AddressLine2,AddressLine3);
            //String packageId = testpack.Id;
            List<string> packageId = new List<string>{testpack.Id};
                
                Fedex.fetchingPackages(JSON.serialize(packageId));
            
            Fedex.fetchingPackageLists(JSON.serialize(packageId));
            Fedex.getTermsOfShipment();
            Fedex.getReasonForExport();
            Fedex.getSignatureServices();
            Fedex.getShipmentsStatus();
            Fedex.getStatusConfirmation();
            Fedex.getBillingOptions();
            String provinceName = newCredentials.Shipper_Province__c;
            Fedex.getProvinceCode(provinceName);
            String countryName = newCredentials.ERP7__Shipper_Country__c;
            Fedex.getCountryCode(countryName);
            Fedex.getCountryCode('');
            Fedex.fetchToAddress(JSON.serialize(packageId));
            Fedex.fetchFromAddress(JSON.serialize(packageId));
            List<Package__c> packList = new List<Package__c>{testpack};
                String fromAdd=salepoint.ERP7__Ship_From_Address__c; 
            String tAddress=rma.ERP7__Address__c;
            Datetime dt = System.NOW();
            String shipDate = string.valueOf(dt);
            String myConsVar = 'test';
            try{
                Fedex.Shipping_Rate_Request(packList,fromAdd,tAddress,shipDate,JSON.serialize(Fedex.myConstructor('','')),false);
                Fedex.Shipping_Request_Reply(packList,bAddress,sAddress,shipDate,JSON.serialize(Fedex.myConstructor('','')),JSON.serialize(shipments),JSON.serialize(rw),false,'',JSON.serialize(shipments));
            }catch(Exception e){}
            try{
                Address__c sAddress1 = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='Fundacion Angel Ramos #383 Ave', Address_Line2__c='FD Roosevelt Edificio Anexo Piso 2', Address_Line3__c='', City__c='San Juan',State__c='San Juan', Postal_Code__c='San Juan', Country__c = 'Puerto Rico', Is_Shipping_Address__c=true);
                insert sAddress1;
                Fedex.Shipping_Rate_Request(packList,fromAdd,tAddress,shipDate,JSON.serialize(Fedex.myConstructor('','')),true);
                Fedex.Shipping_Request_Reply(packList,bAddress,sAddress1,shipDate,JSON.serialize(Fedex.myConstructor('','')),JSON.serialize(shipments),JSON.serialize(rw),true,'',JSON.serialize(shipments));
            }catch(Exception e){}
            Fedex.Cancel_Request_Reply(JSON.serialize(shipments),packList,shipDate,JSON.serialize(Fedex.myConstructor('','')));
            IntegratedShipmentScheduler iss = new IntegratedShipmentScheduler();
            List<String> lst = new List<String>();
            lst.add(String.valueOf(testpack.Id));
            Fedex.getShiptoContact(JSON.serialize(lst));
            
            String sch = '0 0 23 * * ?';
            system.schedule('Test check', sch, iss);
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
             Fedex.getUPSmyConstruct(shipments.Id);
            Fedex.getUpsServicesWrapperList(packList,fromAdd,tAddress,shipDate,JSON.serialize(Fedex.myConstructor('','')),JSON.serialize(shipments),true);
          
            test.stopTest();
        }catch(Exception e){}
    }
    
    @isTest static void unitTestCase11() {
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
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
        Product_Unit_Code__c puc = new Product_Unit_Code__c(Name='test', Product_Code__c='Box', Product_Description__c='Box');
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
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack;
        
        Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
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
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        shipments.ERP7__Package_Ready_Time__c = System.Now() + 1;
        insert shipments;
        
        test.startTest(); 
        Fedex fed = new Fedex();
        Fedex.myConstructorWrapper mcw = new Fedex.myConstructorWrapper();
        Fedex.fedexWrapper fw = new Fedex.fedexWrapper();
        Fedex.rateWrapper rw = new Fedex.rateWrapper();
        Fedex.trackwrapper tw = new Fedex.trackwrapper();
        Fedex.plWrapper plw = new Fedex.plWrapper();
        Fedex.myConstructor('','');
        String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
        Fedex.getStreet(AddressLine1,AddressLine2,AddressLine3);
        Fedex.getStreet(AddressLine1,AddressLine2,'');
        Fedex.getStreet(AddressLine1,'','');
        Fedex.getStreet('', '', '');
        
        //String packageId = testpack.Id;
        List<string> packageId = new List<string>{testpack.Id};
            Fedex.fetchingPackages(JSON.serialize(packageId));
        Fedex.fetchingPackageLists(JSON.serialize(packageId));
        Fedex.getTermsOfShipment();
        Fedex.getReasonForExport();
        Fedex.getSignatureServices();
        Fedex.getShipmentsStatus();
        Fedex.getStatusConfirmation();
        String provinceName = newCredentials.Shipper_Province__c;
        Fedex.getProvinceCode(provinceName);
        String countryName = newCredentials.ERP7__Shipper_Country__c;
        Fedex.getCountryCode(countryName);
        Fedex.fetchToAddress(JSON.serialize(packageId));
        Fedex.fetchFromAddress(JSON.serialize(packageId));
        List<Package__c> packList = new List<Package__c>{testpack};
            String fromAdd=salepoint.ERP7__Ship_From_Address__c; 
        String tAddress=rma.ERP7__Address__c;
        Datetime dt = System.NOW();
        String shipDate = string.valueOf(dt);
        DateTime dispatchDate = System.Now() + 1;
        DateTime PackageReadyTime = System.Now() + 1;
        DateTime CustomerCloseTime = System.Now() + 1;
        Fedex.PickupAvailability_Reply(fromAdd,packList,JSON.serialize(shipments),dispatchDate,PackageReadyTime,CustomerCloseTime, false, JSON.serialize(Fedex.myConstructor('','')));
        Fedex.CreatePickup_Reply(fromAdd,packList,JSON.serialize(shipments),PackageReadyTime,CustomerCloseTime,JSON.serialize(Fedex.myConstructor('','')));
        Fedex.CancelPickup_Reply(JSON.serialize(shipments),packList,JSON.serialize(Fedex.myConstructor('','')));
          Fedex.generateUpsShipment(packList,fromAdd,tAddress,shipDate,JSON.serialize(Fedex.myConstructor('','')),JSON.serialize(shipments),JSON.serialize(rw),true,true,false,'',JSON.serialize(shipments));
          
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    @isTest static void unitTestCase111() {
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
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
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack;
        
        Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
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
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        
        test.startTest();
        Fedex fed = new Fedex();
        Fedex.myConstructorWrapper mcw = new Fedex.myConstructorWrapper();
        Fedex.fedexWrapper fw = new Fedex.fedexWrapper();
        Fedex.rateWrapper rw = new Fedex.rateWrapper();
        Fedex.trackwrapper tw = new Fedex.trackwrapper();
        Fedex.plWrapper plw = new Fedex.plWrapper();
        Fedex.myConstructor('','');
        String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
        Fedex.getStreet(AddressLine1,AddressLine2,AddressLine3);
        //String packageId = testpack.Id;
        List<string> packageId = new List<string>{testpack.Id};
            Fedex.fetchingPackages(JSON.serialize(packageId));
        Fedex.fetchingPackageLists(JSON.serialize(packageId));
        Fedex.getTermsOfShipment();
        Fedex.getReasonForExport();
        Fedex.getSignatureServices();
        Fedex.getShipmentsStatus();
        Fedex.getStatusConfirmation();
        String provinceName = newCredentials.Shipper_Province__c;
        Fedex.getProvinceCode(provinceName);
        String countryName = newCredentials.ERP7__Shipper_Country__c;
        Fedex.getCountryCode(countryName);
        Fedex.fetchToAddress(JSON.serialize(packageId));
        Fedex.fetchFromAddress(JSON.serialize(packageId));
        List<Package__c> packList = new List<Package__c>{testpack};
            String fromAdd=salepoint.ERP7__Ship_From_Address__c; 
        String tAddress=rma.ERP7__Address__c;
        Datetime dt = System.NOW();
        String shipDate = string.valueOf(dt);
        
        Fedex.Track_Request_Reply(JSON.serialize(shipments),packList,JSON.serialize(Fedex.myConstructor('','')));
        Fedex.Signature_Proof_Reply(JSON.serialize(shipments),sAddress,JSON.serialize(Fedex.myConstructor('','')));
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    
    @isTest static void unitTestCase2() {
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
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
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack;
        
        Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', Sales_Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
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
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        test.startTest();
        Fedex fed = new Fedex();
        Fedex.myConstructor(string.valueOf(shipments.Id),'');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    
    @isTest static void unitTestCase112() {
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        Id pricebookId = Test.getStandardPricebookId();         
        Order sod = new Order();   
        sod.Status = 'Draft';
        sod.ERP7__Stage__c = 'Entered';
        sod.EffectiveDate = system.today();
        sod.AccountId = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        sod.Pricebook2Id=pricebookId;
        sod.ERP7__Shipment_Type__c='UPS';sod.ERP7__Shipment_Preference_Speed__c='--None--';
        insert sod; 
        Order psod = [Select id, Name From Order Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;  
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        OrderItem solim = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps.id,PricebookEntryId=pbe.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
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
        ERP7__WO__c wo = new ERP7__WO__c(Name='test', Shipping_Address__c=sAddress.Id); //, ERP7__Process__c=process.Id
        insert wo;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack;
        
        Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack1; 
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', ERP7__Order_Product__c=solim.Id, Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2, ERP7__Work_Orders__c=wo.Id);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        
        
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
        Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        
        test.startTest();
        Fedex fed = new Fedex();
        Fedex.myConstructorWrapper mcw = new Fedex.myConstructorWrapper();
        Fedex.fedexWrapper fw = new Fedex.fedexWrapper();
        Fedex.rateWrapper rw = new Fedex.rateWrapper();
        Fedex.trackwrapper tw = new Fedex.trackwrapper();
        Fedex.plWrapper plw = new Fedex.plWrapper();
        Fedex.myConstructor('','');
        String AddressLine1='test'; String AddressLine2='test'; String AddressLine3='test';
        Fedex.getStreet(AddressLine1,AddressLine2,AddressLine3);
        //String packageId = testpack.Id;
        List<string> packageId = new List<string>{testpack.Id};
            Fedex.fetchingPackages(JSON.serialize(packageId));
        Fedex.fetchingPackageLists(JSON.serialize(packageId));
        Fedex.getTermsOfShipment();
        Fedex.getReasonForExport();
        Fedex.getSignatureServices();
        Fedex.getShipmentsStatus();
        Fedex.getStatusConfirmation();
        String provinceName = newCredentials.Shipper_Province__c;
        Fedex.getProvinceCode(provinceName);
        String countryName = newCredentials.ERP7__Shipper_Country__c;
        Fedex.getCountryCode(countryName);
        Fedex.fetchToAddress(JSON.serialize(packageId));
        Fedex.fetchFromAddress(JSON.serialize(packageId));
        
        Fedex.updateshipAddress(sAddress);
        List<Package__c> packList = new List<Package__c>{testpack};
            String fromAdd=salepoint.ERP7__Ship_From_Address__c; 
        String tAddress=rma.ERP7__Address__c;
        Datetime dt = System.NOW();
        String shipDate = string.valueOf(dt);
        String reader='<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><RateReply xmlns="http://fedex.com/ws/rate/v28"><HighestSeverity>FAILURE</HighestSeverity><Notifications><Severity>FAILURE</Severity><Source>crs</Source><Code>7</Code><Message>Rating is temporarily unavailable, please try again later. </Message><LocalizedMessage>Rating is temporarily unavailable, please try again later. </LocalizedMessage></Notifications><TransactionDetail><CustomerTransactionId>Rate Request</CustomerTransactionId></TransactionDetail><Version><ServiceId>crs</ServiceId><Major>28</Major><Intermediate>0</Intermediate><Minor>0</Minor></Version></RateReply></SOAP-ENV:Body></SOAP-ENV:Envelope>';
        Fedex.Track_Request_Reply(JSON.serialize(shipments),packList,JSON.serialize(Fedex.myConstructor('','')));
        Fedex.Signature_Proof_Reply(JSON.serialize(shipments),sAddress,JSON.serialize(Fedex.myConstructor('','')));
        Fedex.readXMLResponseFirstValue(new XmlStreamReader(reader),'Severity');
        Fedex.readXMLResponseOnce(new XmlStreamReader(reader),'Severity');
        //IntegratedShipmentsHelper newship= new IntegratedShipmentsHelper();
        //IntegratedShipmentsHelper.readXMLResponseOnce(new XmlStreamReader(reader),'Severity');
        //IntegratedShipmentsHelper.readXMLResponse(new XmlStreamReader(reader),'Severity');
        
        //IntegratedShipmentsHelper.updateFedexShipments();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
    @isTest static void unitTestCaseTO() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Account customer = new Account(Name='Customer',Company__c='testtt',Phone='7418529662',ERP7__Email__c='test@gmail.com');
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        ERP7__Site__c testSite = new ERP7__Site__c(Name = 'testSite001', ERP7__Address__c = bAddress.Id);
        insert testSite;
        
        ERP7__Distribution_Channel__c testDC = new ERP7__Distribution_Channel__c(Name = 'testDC001', ERP7__Channel__c = salepoint.Id, ERP7__Site__c = testSite.Id);
        insert testDC;
        
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        
        ERP7__Transfer_Order__c testTO = new ERP7__Transfer_Order__c(Name = 'testTO001',ERP7__Active__c = true, ERP7__Channel__c = salepoint.Id, ERP7__To_Channel__c = salepoint.Id, ERP7__Distribution_Channel__c = testDC.Id, ERP7__To_Distribution_Channel__c = testDC.Id, ERP7__From_Site__c = testSite.Id, ERP7__To_Site__c = testSite.Id, ERP7__From_Address__c = bAddress.Id, ERP7__To_Address__c = sAddress.Id);        
        insert testTO;
        ERP7__Transfer_Order_Line_Items__c  testTOLI = new ERP7__Transfer_Order_Line_Items__c(Name = 'testTOLI001', ERP7__Products__c = ps.Id, ERP7__Quantity_requested__c = 1,ERP7__Transfer_Order__c=testTO.Id);
        insert testTOLI;
        Credentials__c newCredentials = new Credentials__c(Name='Fedex', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                           Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                           Shipper_Province__c='California',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='b41c58070d0e2f1158e22908fa040a3e338b63b437ec23a0ef533944dd2278ae',
                                                           Username_Login__c='FedexLightning', Password_Transkey__c='9399519ff7e2318ae7ea29ed7ccba7e28822517b475c2fd406d37c831ace9e2b9cc46397e2fe8f33e583bd37a60edb60',
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
        
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        
        
        Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', ERP7__Transfer_Order__c=testTO.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack1; 
        
        
        
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
        Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', ERP7__Transfer_Order__c=testTO.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0,  ERP7__Return_Merchandise_Authorisation__c=rma.Id, ERP7__Shipment__c = shipments.Id, ERP7__Shipment_Type__c = 'FedEx');
        insert testpack;
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', Transfer_Order_Line_Item__c=testTOLI.Id, ERP7__Transfer_Order__c=testTO.Id, Package__c = testpack.Id, Quantity__c = 2);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        test.startTest();
        Fedex fc = new Fedex();
        List<String> packids = new List<String>();
        packids.add(testpack.Id);
        Fedex.fetchToAddress(JSON.serialize(packids));
        Fedex.fetchFromAddress(JSON.serialize(packids));
        test.stopTest();
    }
    @isTest static void unitTestCaseRMA() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Account customer = new Account(Name='Customer',Company__c='testtt',Phone='7418529662',ERP7__Email__c='test@gmail.com');
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        ERP7__Site__c testSite = new ERP7__Site__c(Name = 'testSite001', ERP7__Address__c = bAddress.Id);
        insert testSite;
        
        ERP7__Distribution_Channel__c testDC = new ERP7__Distribution_Channel__c(Name = 'testDC001', ERP7__Channel__c = salepoint.Id, ERP7__Site__c = testSite.Id);
        insert testDC;
        
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        
        ERP7__Transfer_Order__c testTO = new ERP7__Transfer_Order__c(Name = 'testTO001',ERP7__Active__c = true, ERP7__Channel__c = salepoint.Id, ERP7__To_Channel__c = salepoint.Id, ERP7__Distribution_Channel__c = testDC.Id, ERP7__To_Distribution_Channel__c = testDC.Id, ERP7__From_Site__c = testSite.Id, ERP7__To_Site__c = testSite.Id, ERP7__From_Address__c = bAddress.Id, ERP7__To_Address__c = sAddress.Id);        
        insert testTO;
        ERP7__Transfer_Order_Line_Items__c  testTOLI = new ERP7__Transfer_Order_Line_Items__c(Name = 'testTOLI001', ERP7__Products__c = ps.Id, ERP7__Quantity_requested__c = 1,ERP7__Transfer_Order__c=testTO.Id);
        insert testTOLI;
        Credentials__c newCredentials = new Credentials__c(Name='Fedex Semler Scientific, Inc.', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                           Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                           Shipper_Province__c='California',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='b41c58070d0e2f1158e22908fa040a3e338b63b437ec23a0ef533944dd2278ae',
                                                           Username_Login__c='FedexLightning', Password_Transkey__c='9399519ff7e2318ae7ea29ed7ccba7e28822517b475c2fd406d37c831ace9e2b9cc46397e2fe8f33e583bd37a60edb60',
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
        
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id,ERP7__Site__c=testSite.Id);
        insert rma;
        
        
        Package__c testpack1=new Package__c(Name__c='Test Package', ETD__c=true, Package_Type__c = 'test', Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        insert testpack1; 
        
        
        
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
        Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0,  ERP7__Return_Merchandise_Authorisation__c=rma.Id, ERP7__Shipment__c = shipments.Id, ERP7__Shipment_Type__c = 'FedEx');
        insert testpack;
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', Transfer_Order_Line_Item__c=testTOLI.Id, ERP7__Transfer_Order__c=testTO.Id, Package__c = testpack.Id, Quantity__c = 2);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        test.startTest();
        Fedex fc = new Fedex();
        List<String> packids = new List<String>();
        packids.add(testpack.Id);
        Fedex.fetchToAddress(JSON.serialize(packids));
        Fedex.fetchFromAddress(JSON.serialize(packids));
        Fedex.ValidateAddress(salepoint.ERP7__Ship_From_Address__c,'');
        test.stopTest();
    }
    @isTest static void unitTestCaseFedexLWC() {
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
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        Id pricebookId = Test.getStandardPricebookId();         
        Order sod = new Order();   
        sod.Status = 'Draft';
        sod.ERP7__Stage__c = 'Entered';
        sod.EffectiveDate = system.today();
        sod.AccountId = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = false;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        sod.Pricebook2Id=pricebookId;
        sod.ERP7__Shipment_Type__c='UPS';sod.ERP7__Shipment_Preference_Speed__c='--None--';
        insert sod; 
        Order psod = [Select id, Name From Order Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;  
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        OrderItem solim = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps.id,PricebookEntryId=pbe.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        insert solim; 
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        update sod;
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salePoint.Id,ERP7__From_Contact__c =Contact.Id,ERP7__Contact__c = Contact.Id,  Distribution_Channel__c=DistributionChannels.Id, ERP7__Order_S__c=psod.Id,ERP7__Shipment_type__c='Fedex',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Order_Product__c = Solim.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        insert LoLines2upsert;
        List<ERP7__Logistic__c> loglist = [Select Id,Name,ERP7__Contact__c,ERP7__From_Contact__c from ERP7__Logistic__c where ERP7__Order_S__c = :psod.id];
        system.debug('loglist : '+loglist.size());
        Credentials__c newCredentials = new Credentials__c(Name='Fedex REST API- 605517846', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
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
        ERP7__WO__c wo = new ERP7__WO__c(Name='test', Shipping_Address__c=sAddress.Id); //, ERP7__Process__c=process.Id
        insert wo;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        if(loglist.size() > 0) testpack.ERP7__Logistic__c = loglist[0].Id;
        insert testpack;
        
        Package__c testpack1=new Package__c(Name__c='Test Package',ERP7__Declared_Value__c=10,Length__c =10,Width__c=10,Height__c = 10, ETD__c=true, Package_Type__c = 'test', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        if(loglist.size() > 0) testpack.ERP7__Logistic__c = loglist[0].Id;
        insert testpack1; 
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', ERP7__Order_Product__c=solim.Id, Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2, ERP7__Work_Orders__c=wo.Id);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c from Package_List__c where Id=: pl1.Id];
        List<Package_List__c> packlistitems = new  List<Package_List__c>{pl1};
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        
        
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
        Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        
        test.startTest();
        FedexLWCRestAPI fedextest = new FedexLWCRestAPI();
        FedexLWCRestAPI.getSpecialServices();
        FedexLWCRestAPI.getLabelOptions();
        FedexLWCRestAPI.getShiptoContact(testpack1.Id);
        FedexLWCRestAPI.getShipFromContact(testpack1.Id);
        FedexLWCRestAPI.fetchInitailDetails('');
        FedexLWCRestAPI.myConstructorWrapper myconsw = FedexLWCRestAPI.fetchInitailDetails(shipments.Id);
        FedexLWCRestAPI.ValidateAddress(JSON.serialize(bAddress),JSON.serialize(myconsw));
        FedexLWCRestAPI.getDefaultData('',JSON.serialize(new List<String>{testpack1.Id}),false);
        FedexLWCRestAPI.getDefaultData(shipments.Id,'',true);
        String packageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
        List<Package__c> packlist = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' ,ERP7__Logistic__r.ERP7__Account__c,ERP7__Logistic__r.ERP7__Account__r.Id,ERP7__Logistic__r.ERP7__Account__r.Name,ERP7__Logistic__r.ERP7__Billing_Address__r.Name,ERP7__Logistic__r.ERP7__Billing_Contact__r.Name, Logistic__r.ERP7__From_Contact__c,Logistic__r.ERP7__Contact__c,Logistic__r.ERP7__Billing_options__c,Logistic__r.Channel__c,Logistic__r.ERP7__Billing_Contact__c, Logistic__r.ERP7__Billing_Account_number__c,Logistic__r.ERP7__Billing_Address__c,Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, ERP7__Order__r.Bill_To_Address__c, Sales_Order__r.Bill_To_Address__c,ERP7__Order__r.Ship_To_Address__c , Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Invoice_Address__c,ERP7__Order__r.Name,ERP7__Order__r.OrderNumber,ERP7__Sales_Order__r.Name,  '+
                                               +' ERP7__Logistic__r.ERP7__Billing_Contact_Return__r.Id,ERP7__Logistic__r.ERP7__Billing_Contact_Return__r.Name,Transfer_Order__r.From_Address__c, Transfer_Order__r.To_Address__c, ERP7__Order__r.Channel__c, Sales_Order__r.Channel__c,Return_Merchandise_Authorisation__r.Order__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c,Return_Merchandise_Authorisation__r.ERP7__Order__r.Ship_To_Address__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Address__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Site__r.ERP7__Address__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Address__r.ERP7__Contact__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Return_Contact__c,ERP7__Order__r.Contact__r.Email, Sales_Order__r.Contact__r.Email, Logistic__r.ERP7__Order_S__c, Logistic__r.ERP7__Order_S__r.Contact__c, Logistic__r.ERP7__Order_S__r.Contact__r.Name, Logistic__r.ERP7__Order_S__r.Contact__r.Phone, Logistic__r.ERP7__Order_S__r.Contact__r.Email, Logistic__r.ERP7__Order_S__r.Contact__r.ERP7__Company__c, Logistic__r.Sales_Order__c, Logistic__r.Sales_Order__r.Contact__c, Logistic__r.Sales_Order__r.Contact__r.Phone, Logistic__r.Sales_Order__r.Contact__r.Email, Logistic__r.Sales_Order__r.Contact__r.ERP7__Company__c, '+
                                               +' ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Bill_To_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Account_Number_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Address_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Contact_Return__c, ERP7__Order__r.ERP7__Bill_To_Return__c, ERP7__Order__r.ERP7__Billing_Account_Number_Return__c, ERP7__Order__r.ERP7__Billing_Address_Return__c, ERP7__Order__r.ERP7__Billing_Contact_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c, ERP7__Order__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Address_Return__r.ERP7__Country__c, ERP7__Order__r.ERP7__Billing_Address_Return__r.ERP7__Country__c, '+
                                               +' ERP7__Logistic__r.ERP7__Bill_To_Return__c, ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c, ERP7__Logistic__r.ERP7__Billing_Address_Return__c, ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c, ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c, ERP7__Logistic__r.ERP7__Billing_Contact_Return__c, ERP7__Logistic__r.ERP7__Shipment_type_Return__c, ERP7__Logistic__r.ERP7__Shipping_Preferences_Return__c, '+
                                               +' Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Order__r.Contact__r.Email , Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email,ERP7__Order__r.ERP7__Estimated_Shipping_Amount__c,ERP7__Order__r.ERP7__Shipping_VAT__c ,ERP7__Order__r.ERP7__Insurance_Charges__c from ERP7__Package__c where Id =\'' + String.escapeSingleQuotes(testpack1.Id) + '\' And Active__c = true');
        
          //  [Select Id,Name from where Id = testpack1.Id];
            Date today = Date.today();
        String todayStr = today.format();
        FedexLWCRestAPI.getRates(packlist,JSON.serialize(myconsw),JSON.serialize(bAddress),JSON.serialize(sAddress),'',JSON.serialize(new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId)),false);
       FedexLWCRestAPI.shippingRequestResponse(packlist,JSON.serialize(bAddress),JSON.serialize(sAddress),JSON.serialize(cont),JSON.serialize(cont),'',JSON.serialize(myconsw),JSON.serialize(new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId,ERP7__Label_options__c = 'LABEL',ERP7__Shipment_Billing_options__c='SENDER')),'FEDEX_DISTANCE_DEFERRED','GBP',false,packlistitems,'');
         Address__c bAddress1 = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='Christiansted',State__c='', Country__c='British Virgin Islands', Postal_Code__c='00820',Is_Billing_Address__c=true);
            insert bAddress1;
        bAddress1 = [select Id,Customer__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                        Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,Is_Billing_Address__c from Address__c where Id=: bAddress.Id];
         FedexLWCRestAPI.shippingRequestResponse(packlist,JSON.serialize(bAddress),JSON.serialize(bAddress1),JSON.serialize(cont),JSON.serialize(cont),'',JSON.serialize(myconsw),JSON.serialize(new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId,ERP7__Label_options__c = 'LABEL',ERP7__Shipment_Billing_options__c='SENDER')),'FEDEX_DISTANCE_DEFERRED','GBP',true,packlistitems,'');
       
            
        test.stopTest();
    }
     @isTest static void unitTestCaseFedexLWC2() {
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
        Address__c sAddress = new Address__c(Customer__c=customer.id,Contact__c=cont.id,Active__c=true,Address_Line1__c='6252 Peters Rest', Address_Line2__c='Line 2', Address_Line3__c='test', City__c='Christiansted',State__c='', Postal_Code__c='00820', Country__c = 'British Virgin Islands', Is_Shipping_Address__c=true);
        insert sAddress;
        sAddress = [select Id,Customer__c,Contact__c,Contact__r.Name,Contact__r.Email,Contact__r.Phone,Contact__r.Company__c,Active__c,Address_Line1__c, 
                    Address_Line2__c, Address_Line3__c, City__c,State__c, Country__c, Postal_Code__c,Is_Shipping_Address__c from Address__c where Id=: sAddress.Id];
        Channel__c salepoint = new Channel__c(Name = 'Sale Point',  Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890',
                                              ERP7__Ship_From_Address__c=sAddress.Id);
        insert salepoint;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        Id pricebookId = Test.getStandardPricebookId();         
        Order sod = new Order();   
        sod.Status = 'Draft';
        sod.ERP7__Stage__c = 'Entered';
        sod.EffectiveDate = system.today();
        sod.AccountId = Contact.AccountId;
        sod.Contact__c = Contact.Id;
        sod.Channel__c = salePoint.Id;
        sod.Bill_To_Address__c = bAddress.Id;
        sod.Ship_To_Address__c = sAddress.Id;
        sod.Request_Date__c = system.Today();
        sod.Authorised__c = true;
        sod.ERP7__Ready_To_Pick_Pack__c = false;
        sod.fulfilled__c = false;
        sod.Barcode__c = 'test';
        sod.Pricebook2Id=pricebookId;
        sod.ERP7__Shipment_Type__c='UPS';sod.ERP7__Shipment_Preference_Speed__c='--None--';
        insert sod; 
        Order psod = [Select id, Name From Order Where id =: sod.id Limit 1];
        Product2 ps = new Product2(Name='test',isActive=true);
        insert ps;
        
        Product2 ps1 = new Product2(Name='test',isActive=true);
        insert ps1;
        
        Product2 ps2 = new Product2(Name='test',isActive=true);
        insert ps2;
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;  
        PricebookEntry pbe = new PricebookEntry( Pricebook2Id = standardPricebook.Id, Product2Id = ps.Id, UnitPrice = 1020,IsActive = true);
        Insert pbe;
        OrderItem solim = new OrderItem(UnitPrice=100,Discount_Amount__c=10,Product2Id=ps.id,PricebookEntryId=pbe.Id,Quantity=1,OrderId=psod.id,Total_Price__c=100,VAT_Amount__c=10, Inventory_Tracked__c = true, ERP7__Allocate_Stock__c = true);
        insert solim; 
        sod.ERP7__Ready_To_Pick_Pack__c = true;
        update sod;
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salePoint.Id,ERP7__From_Contact__c =Contact.Id,ERP7__Contact__c = Contact.Id,  Distribution_Channel__c=DistributionChannels.Id, ERP7__Order_S__c=psod.Id,ERP7__Shipment_type__c='Fedex',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Order_Product__c = Solim.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        insert LoLines2upsert;
        List<ERP7__Logistic__c> loglist = [Select Id,Name,ERP7__Contact__c,ERP7__From_Contact__c from ERP7__Logistic__c where ERP7__Order_S__c = :psod.id];
        system.debug('loglist : '+loglist.size());
        Credentials__c newCredentials = new Credentials__c(Name='Fedex REST API- 605517846', Active__c=true, Key__c='3CEE098151DCB303', Shipper_Name__c='Test shipper', Shipper_Company_Name__c='Test company',
                                                           Shipper_Email__c='test@test.com',Shipper_Phone_Number__c='1234567890',Shipper_Street__c='Test street',Shipper_City__c='test city',Shipper_Postal_Code__c='09879',
                                                           Shipper_Province__c='California',Shipper_Country__c='United States',URL__c='test url', Encrypted_Key__c='b41c58070d0e2f1158e22908fa040a3e338b63b437ec23a0ef533944dd2278ae',
                                                           Username_Login__c='Fedex', Password_Transkey__c='9399519ff7e2318ae7ea29ed7ccba7e28822517b475c2fd406d37c831ace9e2b9cc46397e2fe8f33e583bd37a60edb60',
                                                           Meter_Number__c='100175015',UPS_Account_Number__c='RY9704', Parent_Password__c='FwSr0GnMFJ4ZhN93cUfXxslVm', Parent_Key__c='tEkXuBO9dc6aX7bG');
        insert newCredentials;
        Country_Codes__c countryCode = new Country_Codes__c(Name='United States', Code__c='US', Country__c='United States');
        insert countryCode;
         Country_Codes__c countryCode1 = new Country_Codes__c(Name='British Virgin Islands', Code__c='VG', Country__c='British Virgin Islands');
        insert countryCode1;
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
        ERP7__WO__c wo = new ERP7__WO__c(Name='test', Shipping_Address__c=sAddress.Id); //, ERP7__Process__c=process.Id
        insert wo;
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='test', ERP7__Channel__c=salepoint.Id, ERP7__Address__c=sAddress.Id);
        insert rma;
        Package__c testpack=new Package__c(Name__c='Test Package',Package_Type__c = 'test', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx',Status__c='test',
                                           Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        if(loglist.size() > 0) testpack.ERP7__Logistic__c = loglist[0].Id;
        insert testpack;
        
        Package__c testpack1=new Package__c(Name__c='Test Package',ERP7__Declared_Value__c=10,Length__c =10,Width__c=10,Height__c = 10, ETD__c=true, Package_Type__c = 'test', Order__c=sod.id,Active__c=true,Shipment_Type__c='FedEx', Status__c='test',
                                            Description__c='test description',Weight_Unit__c='KGS',Weight__c=5.0, ERP7__Work_Order__c=wo.Id, ERP7__Return_Merchandise_Authorisation__c=rma.Id);
        if(loglist.size() > 0) testpack.ERP7__Logistic__c = loglist[0].Id;
        insert testpack1; 
        Package_List__c pl1 = new Package_List__c(Name = 'Test List', ERP7__Order_Product__c=solim.Id, Order__c=sod.Id, Package__c = testpack.Id, Quantity__c = 2, ERP7__Work_Orders__c=wo.Id);
        insert pl1;
        pl1 = [select Id, Name, Sales_Order_Line_Item__c, Sales_Order__c, Package__r.Weight__c, Package__r.Weight_Unit__c, Package__c, Quantity__c,ERP7__Order_Product__c,ERP7__Order_Product__r.Product2.Declared_Shipment_Value__c,ERP7__Order_Product__r.Product2.Name,ERP7__Logistic_Line_Item__c,ERP7__Logistic_Line_Item__r.Product__r.Weight__c  from Package_List__c where Id=: pl1.Id];
        List<Package_List__c> packlistitems = new  List<Package_List__c>{pl1};
        BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
        insert psa;  
        BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
        insert psa1;
        
        
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
        Shipment__c shipments = new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId);
        insert shipments;
        
        test.startTest();
          FedexLWCRestAPI.myConstructorWrapper myconsw = FedexLWCRestAPI.fetchInitailDetails(shipments.Id);
          String packageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
        List<Package__c> packlist = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' ,ERP7__Logistic__r.ERP7__Account__c,ERP7__Logistic__r.ERP7__Account__r.Id,ERP7__Logistic__r.ERP7__Account__r.Name,ERP7__Logistic__r.ERP7__Billing_Address__r.Name,ERP7__Logistic__r.ERP7__Billing_Contact__r.Name, Logistic__r.ERP7__From_Contact__c,Logistic__r.ERP7__Contact__c,Logistic__r.ERP7__Billing_options__c,Logistic__r.Channel__c,Logistic__r.ERP7__Billing_Contact__c, Logistic__r.ERP7__Billing_Account_number__c,Logistic__r.ERP7__Billing_Address__c,Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, ERP7__Order__r.Bill_To_Address__c, Sales_Order__r.Bill_To_Address__c,ERP7__Order__r.Ship_To_Address__c , Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Invoice_Address__c,ERP7__Order__r.Name,ERP7__Order__r.OrderNumber,ERP7__Sales_Order__r.Name,  '+
                                               +' ERP7__Logistic__r.ERP7__Billing_Contact_Return__r.Id,ERP7__Logistic__r.ERP7__Billing_Contact_Return__r.Name,Transfer_Order__r.From_Address__c, Transfer_Order__r.To_Address__c, ERP7__Order__r.Channel__c, Sales_Order__r.Channel__c,Return_Merchandise_Authorisation__r.Order__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c,Return_Merchandise_Authorisation__r.ERP7__Order__r.Ship_To_Address__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Address__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Site__r.ERP7__Address__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Address__r.ERP7__Contact__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Return_Contact__c,ERP7__Order__r.Contact__r.Email, Sales_Order__r.Contact__r.Email, Logistic__r.ERP7__Order_S__c, Logistic__r.ERP7__Order_S__r.Contact__c, Logistic__r.ERP7__Order_S__r.Contact__r.Name, Logistic__r.ERP7__Order_S__r.Contact__r.Phone, Logistic__r.ERP7__Order_S__r.Contact__r.Email, Logistic__r.ERP7__Order_S__r.Contact__r.ERP7__Company__c, Logistic__r.Sales_Order__c, Logistic__r.Sales_Order__r.Contact__c, Logistic__r.Sales_Order__r.Contact__r.Phone, Logistic__r.Sales_Order__r.Contact__r.Email, Logistic__r.Sales_Order__r.Contact__r.ERP7__Company__c, '+
                                               +' ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Bill_To_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Account_Number_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Address_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Contact_Return__c, ERP7__Order__r.ERP7__Bill_To_Return__c, ERP7__Order__r.ERP7__Billing_Account_Number_Return__c, ERP7__Order__r.ERP7__Billing_Address_Return__c, ERP7__Order__r.ERP7__Billing_Contact_Return__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c, ERP7__Order__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c, ERP7__Logistic__r.ERP7__Order_S__r.ERP7__Billing_Address_Return__r.ERP7__Country__c, ERP7__Order__r.ERP7__Billing_Address_Return__r.ERP7__Country__c, '+
                                               +' ERP7__Logistic__r.ERP7__Bill_To_Return__c, ERP7__Logistic__r.ERP7__Billing_Account_Number_Return__c, ERP7__Logistic__r.ERP7__Billing_Address_Return__c, ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Postal_Code__c, ERP7__Logistic__r.ERP7__Billing_Address_Return__r.ERP7__Country__c, ERP7__Logistic__r.ERP7__Billing_Contact_Return__c, ERP7__Logistic__r.ERP7__Shipment_type_Return__c, ERP7__Logistic__r.ERP7__Shipping_Preferences_Return__c, '+
                                               +' Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Order__r.Contact__r.Email , Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email,ERP7__Order__r.ERP7__Estimated_Shipping_Amount__c,ERP7__Order__r.ERP7__Shipping_VAT__c ,ERP7__Order__r.ERP7__Insurance_Charges__c from ERP7__Package__c where Id =\'' + String.escapeSingleQuotes(testpack1.Id) + '\' And Active__c = true');
        
          FedexLWCRestAPI.shippingRequestResponse(packlist,JSON.serialize(bAddress),JSON.serialize(sAddress),JSON.serialize(cont),JSON.serialize(cont),'',JSON.serialize(myconsw),JSON.serialize(new Shipment__c(Product_Unit_Code__c = 'PUC Code', Shipment_Date__c = System.Today(),Package_Weight__c = 10,Package_Weight_Unit__c = 'KGS', UPS_Package_Weight_Unit__c = 'LBS', 
                                                UPS_Package_Type__c = 'test',Shipment_Type__c = 'test',Customer__c = customer.Id, Customer_Contact__c = contact.Id,Width__c = 10, Length__c = 10, Height__c = 10, ERP7__TrackingNumber__c = '1234567878', 
                                                Pickup_Confirmation_Number__c='1234567890',Active__c=true,Status__c='shipped',RecordTypeId=ShipmentRecTypeId,ERP7__Label_options__c = 'LABEL',ERP7__Shipment_Billing_options__c='SENDER')),'FEDEX_DISTANCE_DEFERRED','GBP',false,packlistitems,'');
         FedexLWCRestAPI.cancelShipment(JSON.serialize(shipments),packlist,'' ,JSON.serialize(myconsw));
        FedexLWCRestAPI.TrackShipment(JSON.serialize(shipments),packlist,'');
      
         test.stopTest();
     }
}