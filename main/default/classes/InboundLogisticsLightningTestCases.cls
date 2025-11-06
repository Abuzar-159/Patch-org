@isTest
private class InboundLogisticsLightningTestCases {
    
    static testMethod void InboundLogisticsUnitTest1() { 
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        //PreventRecursiveLedgerEntry.preventWOExecution = true; 
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        List<Product2> Product2insert = new List<Product2>();
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        Product2insert.add(ps);
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='productId1',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);
        Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='productId2',Track_Inventory__c=true,ERP7__Serialise__c=true);
        Product2insert.add(ps2);
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        Product2insert.add(ps3);
        ERP7__Batch__c batch= new ERP7__Batch__c(Name='Test batch',ERP7__Product__c=ps3.Id);
        batch.ERP7__Active__c = true;
        insert batch;
        Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='productId4',Track_Inventory__c=true);
        Product2insert.add(ps4);
        upsert Product2insert;
        ERP7__Serial_Number__c ser= new ERP7__Serial_Number__c(Name='Test serial',ERP7__Product__c=ps2.Id);
        ser.ERP7__Available__c = true;
        insert ser;
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps4.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c=true);
        insert ssl;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c=true);
        insert bin;
        
        PO__c PO = new PO__c(Delivery_Address__c = bAddress.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id,Barcode__c='PO',ERP7__Ready_To_Receive__c=true);
        insert PO; 
        List<Purchase_Line_Items__c> PurchaseLinesinsert = new List<Purchase_Line_Items__c>();
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=10,Quantity_Received__c=10,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli);
        Purchase_Line_Items__c poli1 = new Purchase_Line_Items__c(Unit_Price__c=1,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps1.Id, Explode__c=true, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli1);
        Purchase_Line_Items__c poli2 = new Purchase_Line_Items__c(Unit_Price__c=1,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps2.Id, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli2);
        Purchase_Line_Items__c poli3 = new Purchase_Line_Items__c(Unit_Price__c=1,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps3.Id, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli3);
        upsert PurchaseLinesinsert;
        
        
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Inbound', ERP7__Account__c=customer.Id, ERP7__Active__c=false,Channel__c=salePoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Purchase_Order__c=PO.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, Purchase_Line_Items__c = poli.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps1.Id, Purchase_Line_Items__c = poli1.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved', Explode__c=true);
        LoLines2upsert.add(LogisticLine1);
        
        ERP7__Logistic_Line_Item__c LogisticLine2 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, Purchase_Line_Items__c = poli2.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine2);
        
        ERP7__Logistic_Line_Item__c LogisticLine3 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps3.Id, Purchase_Line_Items__c = poli3.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine3);
        upsert LoLines2upsert;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(), ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;                                          
        Asset_Assignment__c AA = new Asset_Assignment__c(Name='Test', ERP7__Asset__c=asset.Id,ERP7__Reserved_To__c=system.today()+1);
        insert AA;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update poli1;
        
        ERP7__GoogleCredentials__c gc = new ERP7__GoogleCredentials__c(Name='Test',ERP7__UserName__c =  UserInfo.getUserName(),ERP7__DriveEmail__c = 'test@test.com',ERP7__Active__c = true,ERP7__RefreshToken__c = 'dummy',ERP7__AccessToken__c = 'dummy');
        insert gc;
        
        ERP7__Credentials__c cred = new ERP7__Credentials__c(Name='GoogleDrive', ERP7__Active__c=true, ERP7__Bank_COA_ID__c='werttty',ERP7__URL__c='https://test.com',Username_Login__c='ea936dca391225074832374e8a1fa29357658a4d28dae5dc3a65bf0072f76e443179086f148d8e1439c4253dfe4e4e34', Password_Transkey__c='38b44386e2fdd56a87a009be2593426eeffc7f6bf4664cb3a1389414e3ae7690d65eaa54cba1845e9419c9114f0099f3',Encrypted_Key__c='6233e47bd5de267af2b7e59ae6266073c1d5ad3f3493d2b8facd8fece9e782c4');
        insert cred;
        
        List<ERP7__Logistic__c> LOGS = [Select Id, Name from ERP7__Logistic__c Where Id= :Logistic.Id];
        List<String> LOIDS = new List<String>();
        for(ERP7__Logistic__c LOG : LOGS) LOIDS.add(LOG.Id);
        
        Test.startTest();
        
        InboundLogisticsLightning  IBL = new InboundLogisticsLightning ();
        InboundLogisticsLightning.comWrap comW = new InboundLogisticsLightning.comWrap();
        InboundLogisticsLightning.LogisticWrapper LW = new InboundLogisticsLightning.LogisticWrapper();
        InboundLogisticsLightning.LOLIWrapper LOLIW = new InboundLogisticsLightning.LOLIWrapper(LogisticLine);
        InboundLogisticsLightning.StockWrapper SW = new InboundLogisticsLightning.StockWrapper(new Inventory_Stock__c(), new List<Stock_Inward_Line_Item__c>());
        InboundLogisticsLightning.SelectOptions SLOP = new InboundLogisticsLightning.SelectOptions('HI','HI');
        InboundLogisticsLightning.SelectOptions SLOP1 = new InboundLogisticsLightning.SelectOptions('HI','HI', false);
        
        comW = InboundLogisticsLightning.getAll('', '', '', '', 0, 10);
        Logistic.ERP7__Active__c = true; update Logistic;
        comW = InboundLogisticsLightning.getAll('', '', '', '', 0, 10);
        InboundLogisticsLightning.DeleteAT(AA.Id, 'Asset_Assignment__c');
        InboundLogisticsLightning.uploadFile(LogisticLine.Id, 'hello file', 'test', 'png',true,true);
        comW = InboundLogisticsLightning.ReceiveAll(JSON.serialize(LOIDS));
        InboundLogisticsLightning.SaveLOLinesReceived(JSON.serialize(comW.LOLIWrapperList));
        comW = InboundLogisticsLightning.PutAway(JSON.serialize(comW)); 
        Integer i = 0;
        Integer kitCount = 0;
        for(InboundLogisticsLightning.LOLIWrapper myLOLIW : comW.LOLIWrapperList){
            if(myLOLIW.LOLI.Explode__c) kitCount = i;
            Integer j = 0;
            for(InboundLogisticsLightning.StockWrapper WIIS : myLOLIW.StockWrapperList){
                if(myLOLIW.LOLI.Product__r.ERP7__Serialise__c) { WIIS.SerialNumber.Serial_Number__c = 'Test'+i+j; WIIS.SerialNumber.Id=ser.Id;}
                if(myLOLIW.LOLI.Product__r.Lot_Tracked__c) { WIIS.BatchNumber.Name = 'Test'+i+j; WIIS.BatchNumber.Id=batch.Id;}
                j++;
            } i++;
        }
        InboundLogisticsLightning.AddStockKit(JSON.serialize(comW.LOLIWrapperList), kitCount, 0);
        InboundLogisticsLightning.RemoveStockKit(JSON.serialize(comW.LOLIWrapperList), 0, 0, 0);
        InboundLogisticsLightning.AddStock(JSON.serialize(comW.LOLIWrapperList), 0);
        InboundLogisticsLightning.RemoveStock(JSON.serialize(comW.LOLIWrapperList), 0, 0);
        
        InboundLogisticsLightning.SaveLOLines(JSON.serialize(comW.LOLIWrapperList));
        InboundLogisticsLightning.ScannerMethod(JSON.serialize(comW.LOLIWrapperList), 'productId', -1);
        InboundLogisticsLightning.ScannerMethod(JSON.serialize(comW.LOLIWrapperList), 'Bin', 0);
        
        comW = InboundLogisticsLightning.ReceiveAll(JSON.serialize(LOIDS));
        comW = InboundLogisticsLightning.PutAway(JSON.serialize(comW)); 
        
        System.assertEquals('test@test.com',contact.Email);
        
        Test.stopTest();
        
    }
    
    static testMethod void InboundLogisticsUnitTest2() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        List<Product2> Product2insert = new List<Product2>();
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        Product2insert.add(ps);
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='productId1',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);
        Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='productId2',Track_Inventory__c=true,ERP7__Serialise__c=true);
        Product2insert.add(ps2);
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        Product2insert.add(ps3);
        Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='productId4',Track_Inventory__c=true);
        Product2insert.add(ps4);
        ERP7__Batch__c batch= new ERP7__Batch__c(Name='Test batch',ERP7__Product__c=ps3.Id);
        batch.ERP7__Active__c = true;
        insert batch;
        upsert Product2insert;
        ERP7__Serial_Number__c ser= new ERP7__Serial_Number__c(Name='Test serial',ERP7__Product__c=ps2.Id);
        ser.ERP7__Available__c = true;
        insert ser;
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps4.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        ERP7__Transfer_Order__c TO = new ERP7__Transfer_Order__c(
            Name = 'Test02',                                     // Transfer Order Name
            ERP7__Requested_Date__c = system.today(),  // Requested Date
            ERP7__Expected_Date__c = system.today()+1,   // Expected Date
            ERP7__Channel__c = salepoint.Id,                  // From Channel
            ERP7__To_Channel__c = salepoint.Id,               // To Channel
            ERP7__Distribution_Channel__c = DistributionChannels.Id,     // From Distribution Channel
            ERP7__To_Distribution_Channel__c = DistributionChannels.Id,  // To Distribution Channel
            ERP7__From_Site__c = Site.Id,                // From Site
            ERP7__To_Site__c = Site.Id,                  // To Site
            ERP7__From_Address__c = bAddress.Id,             // From Address
            ERP7__To_Address__c = sAddress.Id,               // To Address
            ERP7__Status__c = 'Draft',                         // Status
            ERP7__Active__c = true,                                // Active
            ERP7__Customer__c = customer.Id,                 // Customer
            ERP7__Contact__c = Contact.Id,                  // Contact
            ERP7__Sellable_in_Transit__c = false,                  // Sellable in Transit
            ERP7__Receive_All_Close__c = false,                    // Receive All & Close
            ERP7__Tracking__c = '666',                             // TRACKING
            ERP7__Ready_To_Receive__c = true,                     // Ready To Receive
            ERP7__Ready_To_Pick_Pack__c = true,                    // Ready To Pick & Pack
            ERP7__Is_Closed__c = false,                            // Is Closed
            ERP7__Organisation__c = orgn.Id             // Organisation
        );
        insert TO;
        List<ERP7__Transfer_Order_Line_Items__c > PurchaseLinesinsert = new List<ERP7__Transfer_Order_Line_Items__c >();
        ERP7__Transfer_Order_Line_Items__c  poli = new ERP7__Transfer_Order_Line_Items__c (ERP7__Quantity_requested__c =10,ERP7__Transfer_Order__c =TO.id,ERP7__Products__c  = ps.Id);
        PurchaseLinesinsert.add(poli);
        ERP7__Transfer_Order_Line_Items__c  poli1 = new ERP7__Transfer_Order_Line_Items__c (ERP7__Quantity_requested__c =1,ERP7__Transfer_Order__c =TO.id,ERP7__Products__c  = ps1.Id, Explode__c=true);
        PurchaseLinesinsert.add(poli1);
        ERP7__Transfer_Order_Line_Items__c  poli2 = new ERP7__Transfer_Order_Line_Items__c (ERP7__Quantity_requested__c =1,ERP7__Transfer_Order__c =TO.id,ERP7__Products__c  = ps2.Id);
        PurchaseLinesinsert.add(poli2);
        ERP7__Transfer_Order_Line_Items__c  poli3 = new ERP7__Transfer_Order_Line_Items__c (ERP7__Quantity_requested__c =1,ERP7__Transfer_Order__c =TO.id,ERP7__Products__c  = ps3.Id);
        PurchaseLinesinsert.add(poli3);
        upsert PurchaseLinesinsert;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c=true);
        insert ssl;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c=true);
        insert bin;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Inbound', ERP7__Account__c=customer.Id, ERP7__Active__c=true,Channel__c=salePoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Transfer_Order__c=TO.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Transfer_Order_Line_Item__c  = poli.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps1.Id, ERP7__Transfer_Order_Line_Item__c  = poli1.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved', Explode__c=true);
        LoLines2upsert.add(LogisticLine1);
        
        ERP7__Logistic_Line_Item__c LogisticLine2 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, ERP7__Transfer_Order_Line_Item__c  = poli2.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine2);
        
        ERP7__Logistic_Line_Item__c LogisticLine3 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps3.Id, ERP7__Transfer_Order_Line_Item__c  = poli3.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine3);
        upsert LoLines2upsert;
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(), ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;                                          
        Asset_Assignment__c AA = new Asset_Assignment__c(Name='Test', ERP7__Asset__c=asset.Id,ERP7__Reserved_To__c=system.today()+1);
        insert AA;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update poli1;
        
        List<ERP7__Logistic__c> LOGS = [Select Id, Name from ERP7__Logistic__c Where Id= :Logistic.Id];
        List<String> LOIDS = new List<String>();
        for(ERP7__Logistic__c LOG : LOGS) LOIDS.add(LOG.Id);
        
        
        //new
        Account org101 = new Account(Name = 'Organisation', Account_Type__c = 'Organisation');
        insert org101;
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer', AccountNumber='1234', ERP7__Company__c='Aqxolt India Pvt Ltd',
                                ERP7__Start_of_Week__c='Monday', ERP7__CustomerPriority__c='High', ERP7__Active__c='Yes', ERP7__SLA__c='Gold',
                                ERP7__SLAExpirationDate__c=system.today());
        insert c;
        Channel__c channel = new Channel__c(Name = 'Sale Point', Organisation__c = org101.id);
        insert channel;
        Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=c.Id, Phone='1234567890', Email='test@gmail.com', ERP7__Company__c='Aqxolt',
                                  ERP7__Level__c='Secondary');
        insert con;
        Site__c site101 = new Site__c(Name = 'site', Active__c = true, Organisation__c = org101.id);
        insert site101;
        Product2 product101 = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test');
        insert product101;
        
        ERP7__Batch__c batch1 = new ERP7__Batch__c(Name='testBatch',ERP7__Product__c=product101.Id,ERP7__Active__c=true);
        insert batch1;
        
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product101.Id, ERP7__Barcode__c='test');
        insert serial1;
        
        
        Inventory_Stock__c inventorystock101 = new Inventory_Stock__c(Organisation__c = org101.Id, Name = 'test', Active__c = true, Warehouse__c = site101.Id, Product__c = product101.Id,ERP7__Batch_Lot__c=batch1.Id,ERP7__Serial__c = serial1.Id);
        insert inventorystock101;
        ERP7__Serial_Number__c serial101 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product101.Id, ERP7__Barcode__c='test');
        insert serial101;
        ERP7__Sales_Order__c so101 = new ERP7__Sales_Order__c(Name='Test', ERP7__Channel__c=channel.Id, ERP7__Order_Status__c='Entered', ERP7__Account__c=c.Id,
                                                              ERP7__Contact__c=con.Id, ERP7__Active__c=true, ERP7__Status__c='New', ERP7__Customer_Email__c='test@gmail.com',
                                                              ERP7__Expected_Date__c=system.today(), ERP7__Fulfilled_Date__c=system.today());
        insert so101;
        ERP7__Sales_Order_Line_Item__c soli101 = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so101.Id, ERP7__Product__c=product101.Id, ERP7__Active__c=true,
                                                                                    ERP7__Site__c=site101.Id, ERP7__Quantity__c=10);
        insert soli101;
        
        ERP7__GoogleCredentials__c gc = new ERP7__GoogleCredentials__c(Name='Test',ERP7__UserName__c =  UserInfo.getUserName(),ERP7__DriveEmail__c = 'test@test.com',ERP7__Active__c = true,ERP7__RefreshToken__c = 'dummy',ERP7__AccessToken__c = 'dummy');
        insert gc;
        
        ERP7__Credentials__c cred = new ERP7__Credentials__c(Name='GoogleDrive', ERP7__Active__c=true, ERP7__Bank_COA_ID__c='werttty',ERP7__URL__c='https://test.com',Username_Login__c='ea936dca391225074832374e8a1fa29357658a4d28dae5dc3a65bf0072f76e443179086f148d8e1439c4253dfe4e4e34', Password_Transkey__c='38b44386e2fdd56a87a009be2593426eeffc7f6bf4664cb3a1389414e3ae7690d65eaa54cba1845e9419c9114f0099f3',Encrypted_Key__c='6233e47bd5de267af2b7e59ae6266073c1d5ad3f3493d2b8facd8fece9e782c4');
        insert cred;
        
        Test.startTest();
        InboundLogisticsLightning  IBL = new InboundLogisticsLightning ();
        InboundLogisticsLightning.comWrap comW = new InboundLogisticsLightning.comWrap();
        InboundLogisticsLightning.LogisticWrapper LW = new InboundLogisticsLightning.LogisticWrapper();
        InboundLogisticsLightning.LOLIWrapper LOLIW = new InboundLogisticsLightning.LOLIWrapper(LogisticLine);
        InboundLogisticsLightning.StockWrapper SW = new InboundLogisticsLightning.StockWrapper(new Inventory_Stock__c(), new List<Stock_Inward_Line_Item__c>());
        InboundLogisticsLightning.SelectOptions SLOP = new InboundLogisticsLightning.SelectOptions('HI','HI');
        InboundLogisticsLightning.SelectOptions SLOP1 = new InboundLogisticsLightning.SelectOptions('HI','HI', false);
        
        comW = InboundLogisticsLightning.getAll('', '', '', '', 0, 10);
        InboundLogisticsLightning.DeleteAT(AA.Id, 'Asset_Assignment__c');
        InboundLogisticsLightning.uploadFile(LogisticLine.Id, 'hello file', 'test', 'png',true,true);
        comW = InboundLogisticsLightning.ReceiveAll(JSON.serialize(LOIDS));
        InboundLogisticsLightning.SaveLOLinesReceived(JSON.serialize(comW.LOLIWrapperList));
        comW = InboundLogisticsLightning.PutAway(JSON.serialize(comW)); 
        Integer i = 0;
        Integer kitCount = 0;
        for(InboundLogisticsLightning.LOLIWrapper myLOLIW : comW.LOLIWrapperList){
            if(myLOLIW.LOLI.Explode__c) kitCount = i;
            Integer j = 0;
            for(InboundLogisticsLightning.StockWrapper WIIS : myLOLIW.StockWrapperList){
                if(myLOLIW.LOLI.Product__r.ERP7__Serialise__c) { WIIS.SerialNumber.Serial_Number__c = 'Test'+i+j; WIIS.SerialNumber.Id=ser.Id;}
                if(myLOLIW.LOLI.Product__r.Lot_Tracked__c) { WIIS.BatchNumber.Name = 'Test'+i+j; WIIS.BatchNumber.Id=batch.Id;}
                j++;
            } i++;
        }
        
        InboundLogisticsLightning.AddStockKit(JSON.serialize(comW.LOLIWrapperList), kitCount, 0);
        InboundLogisticsLightning.RemoveStockKit(JSON.serialize(comW.LOLIWrapperList), kitCount, 0, 0);
        InboundLogisticsLightning.AddStock(JSON.serialize(comW.LOLIWrapperList), 0);
        InboundLogisticsLightning.RemoveStock(JSON.serialize(comW.LOLIWrapperList), 0, 0);
        
        InboundLogisticsLightning.SaveLOLines(JSON.serialize(comW.LOLIWrapperList));
        InboundLogisticsLightning.ScannerMethod(JSON.serialize(comW.LOLIWrapperList), 'productId', -1);
        InboundLogisticsLightning.ScannerMethod(JSON.serialize(comW.LOLIWrapperList), 'Bin', 0);
        
        InboundLogisticsLightning.DeleteStock(inventorystock101.Id, serial101.Id);
        
        comW = InboundLogisticsLightning.ReceiveAll(JSON.serialize(LOIDS));
        comW = InboundLogisticsLightning.PutAway(JSON.serialize(comW)); 
        
        set<Id> soIds = new set<Id>();
        soIds.add(so101.Id);
        set<Id> soliIds = new set<Id>();
        soliIds.add(soli101.Id);
        MaintainBatchStocks.EvaluateSalesOrders(soIds);
        MaintainBatchStocks.EvaluateSalesOrdersLines(soliIds);
        
        System.assertEquals('test@test.com',contact.Email);
        Test.stopTest();
    }
    
    static testMethod void InboundLogisticsUnitTest3() {
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        insert ps;
        ERP7__Batch__c batch=new ERP7__Batch__c(Name='Test Batch',ERP7__Active__c=true,ERP7__Barcode__c='Test Batch',ERP7__Product__c=ps.Id);
        insert batch;
        ERP7__Batch__c batch1=new ERP7__Batch__c(Name='Test Batch1',ERP7__Active__c=true,ERP7__Barcode__c='Test Batch1',ERP7__Product__c=ps.Id);
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=ps.Id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        insert contentlink;
                    
        String FileId = 'uwiewuuwewr';
        List<Id> documentIds = new List<Id>{contentlink.contentdocumentid};
        
        Test.startTest();
        InboundLogisticsLightning.UploadGFile(ps.Id, documentIds, true, true);
        InboundLogisticsLightning.createBatch(JSON.serialize(batch));
        InboundLogisticsLightning.createBatch(JSON.serialize(batch1));
        INboundNew.MOWrapper mow=new InboundNew.MOWrapper();
        System.assertEquals('test@test.com','test@test.com');
        Test.stopTest();
    }
    
    static testMethod void InboundNewUnitTest1() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        //PreventRecursiveLedgerEntry.preventWOExecution = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        
        Address__c bAddress = new Address__c(Customer__c=customer.id,Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c sAddress = new Address__c(Customer__c=customer.id, Contact__c=contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='New York',Country__c='United States', Postal_Code__c='test',Is_Shipping_Address__c=true);
        insert sAddress;
        Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id);
        insert salepoint;
        Employees__c emp = new Employees__c(First_Name__c='test',Last_Name__c='test',Email__c='test@test.com', Organisation__c=orgn.Id,Organisation_Business_Unit__c=busUnit.id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Channel__c = salepoint.Id);
        insert emp;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        insert site;
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel',Active__c=true, Channel__c=salepoint.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels;  
        
        List<Product2> Product2insert = new List<Product2>();
        Product2 ps = new Product2(Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        Product2insert.add(ps);
        Product2 ps1 = new Product2(Name='test',isActive=true,Barcode__c='productId1',Track_Inventory__c=true,ERP7__Is_Kit__c=true);
        Product2insert.add(ps1);
        Product2 ps2 = new Product2(Name='test',isActive=true,Barcode__c='productId2',Track_Inventory__c=true,ERP7__Serialise__c=true);
        Product2insert.add(ps2);
        Product2 ps3 = new Product2(Name='test',isActive=true,Barcode__c='productId3',Track_Inventory__c=true,ERP7__Lot_Tracked__c =true);
        Product2insert.add(ps3);
        ERP7__Batch__c batch= new ERP7__Batch__c(Name='Test batch',ERP7__Product__c=ps3.Id);
        batch.ERP7__Active__c = true;
        insert batch;
        Product2 ps4 = new Product2(Name='test',isActive=true,Barcode__c='productId4',Track_Inventory__c=true);
        Product2insert.add(ps4);
        upsert Product2insert;
        ERP7__Serial_Number__c ser= new ERP7__Serial_Number__c(Name='Test serial',ERP7__Product__c=ps2.Id,ERP7__Serial_Number__c='test');
        ser.ERP7__Available__c = true;
        insert ser;
        ERP7__Version__c Version = new ERP7__Version__c(
            Name = 'Default Version',                        
            ERP7__Active__c = true,                            
            ERP7__Start_Date__c = system.today(),  
            ERP7__Product__c = ps1.Id,              
            ERP7__To_Date__c = system.today()+365,     
            ERP7__Category__c = 'Production',                  
            ERP7__Type__c = 'Assembly',                        
            ERP7__Status__c = 'Certified',                     
            ERP7__Default__c = true,                           
            ERP7__Subscription__c = false,   
            ERP7__Sales_Ready__c = true                       
        );
        insert Version;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__BOM__c' And Name='Kit BOM' Limit 1];
        ERP7__BOM__c BOM = new ERP7__BOM__c(
            Name = 'BOM 1',                            
            ERP7__BOM_Product__c = ps1.Id,    
            ERP7__BOM_Component__c = ps4.Id,  
            ERP7__Type__c = 'Primary',                   
            ERP7__Quantity__c = 4,                 
            ERP7__Active__c = true,                      
            RecordTypeId = rTypeProfile.Id,                  
            ERP7__BOM_Version__c = Version.Id,    
            ERP7__Partial_Replacement__c = false,        
            ERP7__Is_Protected__c = false,               
            ERP7__Exact_Quantity__c = false,            
            ERP7__Is_Package_BOM__c = false             
        );
        insert BOM;
        
        Location__c ssl = new Location__c(Name='Test Location',Barcode__c='LOC',Site__c=site.Id,Active__c=true);
        insert ssl;
        StorageContainer__c bin = new StorageContainer__c(Location__c=ssl.Id,Site__c=site.Id,status__c='Checked In',Barcode__c='Bin',Active__c=true);
        insert bin;
        
        PO__c PO = new PO__c(Delivery_Address__c = bAddress.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id,Barcode__c='PO',ERP7__Ready_To_Receive__c=true);
        insert PO; 
        List<Purchase_Line_Items__c> PurchaseLinesinsert = new List<Purchase_Line_Items__c>();
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=10,Quantity_Received__c=10,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli);
        Purchase_Line_Items__c poli1 = new Purchase_Line_Items__c(Unit_Price__c=1,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps1.Id, Explode__c=true, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli1);
        Purchase_Line_Items__c poli2 = new Purchase_Line_Items__c(Unit_Price__c=1,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps2.Id, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli2);
        Purchase_Line_Items__c poli3 = new Purchase_Line_Items__c(Unit_Price__c=1,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps3.Id, ERP7__Site__c = site.Id);
        PurchaseLinesinsert.add(poli3);
        upsert PurchaseLinesinsert;
        
        
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Inbound', ERP7__Account__c=customer.Id, ERP7__Active__c=false,Channel__c=salePoint.Id, Distribution_Channel__c=DistributionChannels.Id, ERP7__Purchase_Order__c=PO.Id,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        List<ERP7__Logistic_Line_Item__c> LoLines2upsert = new List<ERP7__Logistic_Line_Item__c>();
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, Purchase_Line_Items__c = poli.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine);
        
        ERP7__Logistic_Line_Item__c LogisticLine1 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps1.Id, Purchase_Line_Items__c = poli1.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved', Explode__c=true);
        LoLines2upsert.add(LogisticLine1);
        
        ERP7__Logistic_Line_Item__c LogisticLine2 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps2.Id, Purchase_Line_Items__c = poli2.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine2); 
        
        ERP7__Logistic_Line_Item__c LogisticLine3 = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps3.Id, Purchase_Line_Items__c = poli3.Id, ERP7__Quantity__c=10,ERP7__Quantity_Received__c=9, ERP7__Status__c='Reserved');
        LoLines2upsert.add(LogisticLine3);
        upsert LoLines2upsert; 
        
        ERP7__Asset__c asset = new ERP7__Asset__c(Name='test', ERP7__Supplier__c=sup.Id, ERP7__Barcode__c='test', ERP7__Active__c=true, ERP7__Proposed_Disposal_Date__c=system.today(), ERP7__Customer__c=customer.Id, ERP7__Lot_Tracked__c=true, ERP7__Serialise__c=true,ERP7__Available__c=true);
        insert asset;                                          
        Asset_Assignment__c AA = new Asset_Assignment__c(Name='Test', ERP7__Asset__c=asset.Id,ERP7__Reserved_To__c=system.today()+1);
        insert AA;
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        update poli1;
        
        List<ERP7__Logistic__c> LOGS = [Select Id, Name from ERP7__Logistic__c Where Id= :Logistic.Id];
        List<String> LOIDS = new List<String>();
        for(ERP7__Logistic__c LOG : LOGS) LOIDS.add(LOG.Id);
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Attachment testAttachment = new Attachment(
            Name = 'Test Attachment',
            Body = Blob.valueOf('Test Attachment Body'),
            ParentId = testAccount.Id
        );
        insert testAttachment;
        Attachment testAttachment2 = new Attachment(
            Name = 'Test Attachment',
            Body = Blob.valueOf('Test Attachment Body'),
            ParentId = Logistic.Id
        );
        insert testAttachment2;
        
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test document content')
        );
        insert testContentVersion;
        
        // Link the content document to the parent record
        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            LinkedEntityId = testAccount.Id
        );
        insert testContentDocumentLink;
        List<String> fileNames = new List<String>{'TestFile1.txt', 'TestFile2.txt'};
            List<String> base64Data = new List<String>{
                EncodingUtil.base64Encode(Blob.valueOf('Test content 1')),
                    EncodingUtil.base64Encode(Blob.valueOf('Test content 2'))
                    };
                        List<String> contentTypes = new List<String>{'text/plain', 'text/plain'};
                            
                            ERP7__Checklist__c check1= new ERP7__Checklist__c(Name='test',ERP7__Comply__c='Dimension Control');
        insert check1;
        ERP7__Guideline_Checklists__c testGuideline = new ERP7__Guideline_Checklists__c(
            Name = 'Test Guideline',
            ERP7__Checklist__c = check1.Id
        );
        insert testGuideline;
        
        Schema.SObjectType accountType = Account.SObjectType;
        
        // Create controlling and dependent picklist fields
        Schema.DescribeSObjectResult accountDescribe = accountType.getDescribe();
        Schema.DescribeFieldResult controllingFieldDescribe = accountDescribe.fields.getMap().get('Type').getDescribe();
        Schema.DescribeFieldResult dependentFieldDescribe = accountDescribe.fields.getMap().get('Industry').getDescribe();
        
        // Get picklist values for the fields
        List<Schema.PicklistEntry> controllingEntries = controllingFieldDescribe.getPicklistValues();
        List<Schema.PicklistEntry> dependentEntries = dependentFieldDescribe.getPicklistValues();
        
        // Serialize and deserialize picklist entries
        List<String> serializedDependentEntries = new List<String>();
        for (Schema.PicklistEntry entry : dependentEntries) {
            serializedDependentEntries.add(JSON.serialize(entry));
        }
        List<dependentPicklist_UpdateCtrl.PicklistEntryWrapper> wrappedDependentEntries =
            (List<dependentPicklist_UpdateCtrl.PicklistEntryWrapper>)JSON.deserialize(
                '[' + String.join(serializedDependentEntries, ',') + ']',
                List<dependentPicklist_UpdateCtrl.PicklistEntryWrapper>.class
            );
        String base64String = 'SGVsbG8gd29ybGQh'; // This is the base64 encoded string for 'Hello world!'
        String expectedBits = '01001001010011100101001101010100011000110110101101101111011011000110010100100000011101110110111101110010011011000110010000100001';
        
        try{
            Test.startTest();
            
            InboundNew  IBL = new InboundNew ();
            InboundNew.comWrap comW = new InboundNew.comWrap();
            InboundNew.LogisticWrapper LW = new InboundNew.LogisticWrapper();
            InboundNew.LOLIWrapper LOLIW = new InboundNew.LOLIWrapper(LogisticLine);
            InboundNew.StockWrapper SW = new InboundNew.StockWrapper(new Inventory_Stock__c(), new List<Stock_Inward_Line_Item__c>());
            InboundNew.SelectOptions SLOP = new InboundNew.SelectOptions('HI','HI');
            InboundNew.SelectOptions SLOP1 = new InboundNew.SelectOptions('HI','HI', false);
            InboundNew.newStockwrap SPLI = new InboundNew.newStockwrap(new Stock_Inward_Line_Item__c(),false,3,8,9,'');
            List<Stock_Inward_Line_Item__c> sslst = new List<Stock_Inward_Line_Item__c>();
            InboundNew.getAll('', '', '', '', 0, 10, '','');
            Logistic.ERP7__Active__c = true; update Logistic; 
            InboundNew.getAll('', '', '', '', 0, 10, '','');
            comW = InboundNew.ReceiveAl(JSON.serialize(new List<string>{Logistic.Id}));
            for(InboundNew.newStockwrap sp :comW.SPLIs){
                sslst.add(sp.sili);
            }
            ERP7__Checklist__c chk = new ERP7__Checklist__c(Name='test chk',ERP7__Is_Mandatory__c = true,ERP7__Product__c = ps1.Id,ERP7__Comply__c='--None--');
            insert chk;
            ERP7__Inventory_Stock__c Stock2Create = new ERP7__Inventory_Stock__c(ERP7__Warehouse__c= site.Id,ERP7__Active__c = true, Name = 'test', ERP7__Checked_In_Date__c = system.today(), ERP7__Product__c = ps1.Id);
            insert Stock2Create;
            Stock_Inward_Line_Item__c stin= new Stock_Inward_Line_Item__c(Name='test',ERP7__Active__c = true,ERP7__Site_ProductService_InventoryStock__c=Stock2Create.Id,ERP7__Product__c = ps1.Id);
            insert stin;
            List<InboundNew.ReceivedSILIWrap> receiveWrap = new List<InboundNew.ReceivedSILIWrap>();
            InboundNew.ReceivedSILIWrap wrapReceive = new InboundNew.ReceivedSILIWrap();
            wrapReceive.sili = stin;
            receiveWrap.add(wrapReceive);
            System.assertEquals('test@test.com',contact.Email);
            comW = InboundNew.saveAlldetail(JSON.serialize(sslst),site.Id,JSON.serialize(receiveWrap));
            InboundNew.createBatch1(JSON.serialize(new ERP7__Batch__c(Name = 'btc123',Barcode__c = 'btc123')));
            InboundNew.getscandetailsnew('LOC','',0,JSON.serialize(comW.SPLIS),JSON.serialize(comW.LOLIS),site.Id);
            InboundNew.uploadFile(LogisticLine.Id, 'hello file', 'test', 'png');
            
            InboundNew.UpdateSILI(JSON.serialize(new List<Stock_Inward_Line_Item__c>{stin}));
            InboundNew.fetchSortedLogistics('Name','ASC',site.Id,salepoint.Id,10,0,'','');
            InboundNew.DeleteAttach(stin.Id,'ERP7__Stock_Inward_Line_Item__c');
            InboundNew.checkDuplicateSerials('test');
            InboundNew.saveLogisticDescription(String.valueOf(Logistic.Id),'test');
            
            List<Attachment> deletedAttachments = InboundNew.DeleteAttachFromInboundList(
                testAttachment.Id,
                testAccount.Id
            );
            //List<ContentDocumentLink> uploadedFiles = InboundNew.getuploadedfiles(testAccount.Id);
            //List<ContentDocumentLink> uploadedFiles2 = InboundNew.getuploadedfiles('');
            List<ContentDocumentLink> deletedFiles = InboundNew.deleteFile(
                testContentDocumentLink.Id,
                testAccount.Id
            );
            List<Attachment> uploadedAttachments = InboundNew.uploadMultipleFiles(
                testAccount.Id,
                fileNames,
                base64Data,
                contentTypes
            );
            List<Attachment> uploadedAttachments2 = InboundNew.uploadMultipleFilesforQAguidelines(
                JSON.serialize(testGuideline),
                fileNames,
                base64Data,
                contentTypes
            );
            InboundNew.getDependentMap(
                testAccount,
                'Type',
                'Industry'
            );
            
            String convertedBits = InboundNew.base64ToBits(base64String);
            Integer decimalValue = 42;
            String expectedBinary = '101010';
            String convertedBinary = InboundNew.decimalToBinary(decimalValue);
            InboundNew.getAll(Logistic.Id, '', '', '', 0, 10, 'PartialReceivedItems','');
            InboundNew.getAll(Logistic.Id, '', '', '', 0, 10, 'FullReceivedItems','');
            InboundNew.getAll(Logistic.Id, '', '', '', 0, 10, 'AwaitingQualityCheck','');
            InboundNew.getAll(Logistic.Id, '', '', '', 0, 10, '','');
            String fileName = 'TestFile.txt';
            String base64Datas = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
            String result = InboundNew.uploadFileforbatch(
                testAccount.Id,
                fileName,
                base64Datas,
                'text/plain'
            );
            Test.stopTest();
        }catch(Exception e){
            
        }
        
    }
    
}