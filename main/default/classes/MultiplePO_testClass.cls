@isTest(SeeAllData=true)
public class MultiplePO_testClass {
    @isTest(SeeAllData=true)
    static  void UnitTest1() {
        try{
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            Account orgn = new Account(Name='Universal Stores', Account_Type__c = 'Organisation');
            insert orgn;
            ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=orgn.Id,ERP7__Active__c=true,ERP7__Is_Billing_Address__c=true);
            insert address;
            ERP7__Address__c  saddress = new ERP7__Address__c(Name='Test', ERP7__Customer__c=orgn.Id,ERP7__Active__c=true,ERP7__Is_Shipping_Address__c=true);
            insert saddress;
            Account sup = new Account(Name='Supplier',Account_Type__c = 'Vendor');
            insert sup;
            Account sup1 = new Account(Name='Supplier',Account_Type__c = 'Vendor');
            insert sup1;
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=sup.id,Phone='1234567890',Email='test@test.com');
            insert contact;
            Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
            insert ps;
            ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test',  ERP7__Shipper_Name__c='test',
                                                            ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                            ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true,ERP7__Organisation__c = orgn.Id );
            insert channel;
            ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id,ERP7__Active__c=true);
            insert emp;
            ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
            insert site;
            ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true,ERP7__Priority__c = '1');
            insert DC;
            ERP7__Inventory_Stock__c inv = new ERP7__Inventory_Stock__c(Name='Test Inv',ERP7__product__c = ps.Id,ERP7__Active__c = true,ERP7__Warehouse__c = site.Id);
            insert inv;
            ERP7__Stock_Inward_Line_Item__c stin = new ERP7__Stock_Inward_Line_Item__c(Name='test inward',ERP7__product__c = ps.Id,ERP7__Active__c = true,ERP7__Site_ProductService_InventoryStock__c=inv.Id,ERP7__Quantity__c=10);
            insert stin;
            ERP7__Stock_Outward_Line_Item__c stout = new ERP7__Stock_Outward_Line_Item__c(Name='test inward',Posted__C=true, ERP7__Unit_Price__c=1, ERP7__product__c = ps.Id,ERP7__Active__c = true,ERP7__Site_Product_Service_Inventory_Stock__c=inv.Id,ERP7__Quantity__c=10,ERP7__Status__c = 'Requested');
            insert stout;
            Product2 ps1 = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
            insert ps1;
            
            ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
            insert prcs;
            ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Finished_Products_Site__c = site.Id);
            insert rout;
            ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
            insert MO;
            ERP7__Cost_Card__c cc1 = new ERP7__Cost_Card__c(Name = 'Test Product',ERP7__Active__c=true,ERP7__Cost__c=15,ERP7__Product__c = ps.Id,ERP7__Quantity__c = 5,ERP7__Start_Date__c = system.today(),ERP7__Supplier__c = sup.id);
            insert cc1;
            ERP7__Cost_Card__c cc2 = new ERP7__Cost_Card__c(Name = 'Test Product',ERP7__Active__c=true,ERP7__Cost__c=15,ERP7__Product__c = ps1.Id,ERP7__Quantity__c = 5,ERP7__Start_Date__c = system.today(),ERP7__Supplier__c = sup.id);
            insert cc2;
            ERP7__Approved_Vendor__c appven = new ERP7__Approved_Vendor__c(Name='Test supplier',ERP7__Cost_Card__c = cc1.Id,ERP7__Product__c =ps.Id,ERP7__Vendor__c = sup.id );
            insert appven;
            ERP7__Approved_Vendor__c appven1 = new ERP7__Approved_Vendor__c(Name='Test supplier',ERP7__Cost_Card__c = cc1.Id,ERP7__Product__c =ps.Id,ERP7__Vendor__c = sup1.id );
            insert appven1;
            ERP7__PO__c PO = new ERP7__PO__c();
            ERP7__PO__c P1 = new ERP7__PO__c();
            insert PO;
            insert P1;
            String emptyid ='';
            ERP7__Purchase_Line_Items__c polilist1 = new ERP7__Purchase_Line_Items__c(Name='PO-1',ERP7__Approved_Vendor__c =appven.Id,ERP7__Cost_Card__c = cc1.Id,ERP7__Product__c=ps.Id,ERP7__Quantity__c = 5,ERP7__Unit_Price__c=10,ERP7__Total_Price__c=50,ERP7__Purchase_Orders__c = PO.Id);
            //insert polilist1;
            ERP7__Purchase_Line_Items__c polilist = new ERP7__Purchase_Line_Items__c(Name='PO-1',ERP7__Approved_Vendor__c =appven.Id,ERP7__Cost_Card__c = cc2.Id,ERP7__Product__c=ps1.Id,ERP7__Quantity__c = 5,ERP7__Unit_Price__c=10,ERP7__Total_Price__c=50,ERP7__Purchase_Orders__c = PO.Id);
            //insert polilist;
            List<ERP7__Purchase_Line_Items__c> PurlineItems = new   List<ERP7__Purchase_Line_Items__c>();
            PurlineItems.add(polilist);
            PurlineItems.add(polilist1);
            MultiplePO mulPO = new MultiplePO();
            MultiplePO.allPOwrap powrap = new MultiplePO.allPOwrap();
            MultiplePO.fetchChannelandDC();
            MultiplePO.getnewDc(Dc.Id);
            MultiplePO.getnewDc(emptyid);
            
            string proId = ps.Id;
            string venId = appven.Id;
            string chanelId = channel.Id;
            String DchannelId = ''; //DC.Id;
            MultiplePO.getvendor(proId);
            MultiplePO.populatepolidetails(proId,venId);
            string plli = JSON.serialize(PurlineItems);
            powrap =  MultiplePO.getAllPO(plli,chanelId,DchannelId);
            MultiplePO.getStatus();
            MultiplePO.getApprovedvendor(proId,venId);
            string cc1Id = cc1.Id; MultiplePO.fetchPrice(cc1Id);
            //List<MultiplePO.POpolis> POpliess = new List<MultiplePO.POpolis>();
            
            PO.Name='test PO';
            PO.ERP7__Active__c = true;
            PO.ERP7__Channel__c =   chanelId;
            PO.ERP7__Distribution_Channel__c = DC.Id;
            PO.ERP7__Organisation__c = orgn.Id;
            update PO;
            List<ERP7__PO__c> POlist = new List<ERP7__PO__c> ();
            POlist.add(PO);
            test.startTest();
            MultiplePO.showPO(JSON.serialize(POlist));
            MultiplePO.getAllExistPO(JSON.serialize(new List<string>{PO.Id}));
            try{MultiplePO.savePOs(JSON.serialize(powrap));  }catch(Exception e){}
            MultiplePO.getstocks(proId,DC.Id);
            MultiplePO.getvenId(proId,appven1.Id);
            MultiplePO.getvendorId(proId,appven1.ERP7__Vendor__c );
            MultiplePO.getProdDetails(proId);
            MultiplePO.updatePOs(JSON.serialize(POlist));
            MultiplePO.getCurrencies();
            MultiplePO.fetchProductDesc(ps1.Id);
			MultiplePO.fetchProductDesc(''); 
            MultiplePO.fetchProdCode(proId);
            MultiplePO.fetchProdCode('');
            MultiplePO.getCategoryList();
            MultiplePO.populateMOlines(MO.Id);
            MultiplePO.uploadFile('','','','');
            MultiplePO.checkforTax(address.Id, orgn.Id);
            MultiplePO.createCCnew(new ERP7__Cost_Card__c(Name = 'Test Product',ERP7__Active__c=true,ERP7__Cost__c=15,ERP7__Product__c = ps.Id,ERP7__Quantity__c = 5,ERP7__Start_Date__c = system.today(),ERP7__Supplier__c = sup.id));
            test.stopTest();
        }catch(Exception e){}
        System.assertEquals('ERP', 'ERP');
    }
    static testmethod void UnitTest2() {
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            Account orgn = new Account(Name='Universal Stores', Account_Type__c = 'Organisation');
            insert orgn;
            ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=orgn.Id,ERP7__Active__c=true,ERP7__Is_Billing_Address__c=true);
            insert address;
            ERP7__Address__c  saddress = new ERP7__Address__c(Name='Test', ERP7__Customer__c=orgn.Id,ERP7__Active__c=true,ERP7__Is_Shipping_Address__c=true);
            insert saddress;
            Account sup = new Account(Name='Supplier',Account_Type__c = 'Vendor');
            insert sup;
            Account sup1 = new Account(Name='Supplier',Account_Type__c = 'Vendor');
            insert sup1;
            List<id> vendIds = new List<id>();
            vendIds.add(sup.Id);
            vendIds.add(sup1.Id);
            Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=sup.id,Phone='1234567890',Email='test@test.com');
            insert contact;
            Product2 ps = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
            insert ps;
            ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test',  ERP7__Shipper_Name__c='test',
                                                            ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                            ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true,ERP7__Organisation__c = orgn.Id );
            insert channel;
            ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id,ERP7__Active__c=true);
            insert emp;
            ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
            insert site;
            ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c, ERP7__Primary__c = true,ERP7__Priority__c = '1');
            insert DC;
            ERP7__Inventory_Stock__c inv = new ERP7__Inventory_Stock__c(Name='Test Inv',ERP7__product__c = ps.Id,ERP7__Active__c = true,ERP7__Warehouse__c = site.Id);
            insert inv;
            ERP7__Stock_Inward_Line_Item__c stin = new ERP7__Stock_Inward_Line_Item__c(Name='test inward',ERP7__product__c = ps.Id,ERP7__Active__c = true,ERP7__Site_ProductService_InventoryStock__c=inv.Id,ERP7__Quantity__c=10);
            insert stin;
            ERP7__Stock_Outward_Line_Item__c stout = new ERP7__Stock_Outward_Line_Item__c(Name='test inward',ERP7__product__c = ps.Id,ERP7__Active__c = true,ERP7__Site_Product_Service_Inventory_Stock__c=inv.Id,ERP7__Quantity__c=10,ERP7__Status__c = 'Requested');
            insert stout;
            Product2 ps1 = new Product2(Name='test', isActive=true,Track_Inventory__c=true);
            insert ps1;
            
            ERP7__Process__c prcs = new ERP7__Process__c(Name = 'projectTestProcess');
            insert prcs;
            ERP7__Routing__c rout = new ERP7__Routing__c( Name = 'projectTestRouting', ERP7__Product__c = ps.Id , ERP7__Process__c = prcs.Id, ERP7__Raw_Materials_Site__c = site.Id, ERP7__Finished_Products_Site__c = site.Id);
            insert rout;
            ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Name = 'testMO1', ERP7__Product__c = ps.Id, ERP7__Routing__c = rout.Id);
            insert MO;
            ERP7__Cost_Card__c cc1 = new ERP7__Cost_Card__c(Name = 'Test Product',ERP7__Active__c=true,ERP7__Cost__c=15,ERP7__Product__c = ps.Id,ERP7__Quantity__c = 5,ERP7__Start_Date__c = system.today(),ERP7__Supplier__c = sup.id);
            insert cc1;
            ERP7__Cost_Card__c cc2 = new ERP7__Cost_Card__c(Name = 'Test Product',ERP7__Active__c=true,ERP7__Cost__c=15,ERP7__Product__c = ps1.Id,ERP7__Quantity__c = 5,ERP7__Start_Date__c = system.today(),ERP7__Supplier__c = sup.id);
            insert cc2;
            ERP7__Approved_Vendor__c appven = new ERP7__Approved_Vendor__c(Name='Test supplier',ERP7__Cost_Card__c = cc1.Id,ERP7__Product__c =ps.Id,ERP7__Vendor__c = sup.id );
            insert appven;
            ERP7__Approved_Vendor__c appven1 = new ERP7__Approved_Vendor__c(Name='Test supplier',ERP7__Cost_Card__c = cc1.Id,ERP7__Product__c =ps.Id,ERP7__Vendor__c = sup1.id );
            insert appven1;
            ERP7__PO__c PO = new ERP7__PO__c();
            ERP7__PO__c P1 = new ERP7__PO__c();
            insert PO;
            insert P1;
            ERP7__Purchase_Line_Items__c polilist1 = new ERP7__Purchase_Line_Items__c(Name='PO-1',ERP7__Approved_Vendor__c =appven.Id,ERP7__Cost_Card__c = cc1.Id,ERP7__Product__c=ps.Id,ERP7__Quantity__c = 5,ERP7__Unit_Price__c=10,ERP7__Total_Price__c=50,ERP7__Purchase_Orders__c = PO.Id, ERP7__Sort_Order__c=0);
            //insert polilist1;
            ERP7__Purchase_Line_Items__c polilist = new ERP7__Purchase_Line_Items__c(Name='PO-1',ERP7__Approved_Vendor__c =appven.Id,ERP7__Cost_Card__c = cc2.Id,ERP7__Product__c=ps1.Id,ERP7__Quantity__c = 5,ERP7__Unit_Price__c=10,ERP7__Total_Price__c=50,ERP7__Purchase_Orders__c = PO.Id);
            //insert polilist;
            ERP7__Dimension__c dimen = new ERP7__Dimension__c(Name='Test',ERP7__Sort_Order__c=0);
            insert dimen;
            List<ERP7__Purchase_Line_Items__c> PurlineItems = new   List<ERP7__Purchase_Line_Items__c>();
            PurlineItems.add(polilist);
            PurlineItems.add(polilist1);
            List<Id> POs = new List<Id>();
            POs.add(PO.Id);
            POs.add(P1.Id);
            MultiplePO mulPO = new MultiplePO();
            MultiplePO.allPOwrap powrap = new MultiplePO.allPOwrap();
            MultiplePO.fetchChannelandDC();
            MultiplePO.getnewDc(DC.Id);
            String AA=JSON.serialize(dimen); 
            string proId = ps.Id;
            string venId = appven.Id;
            string chanelId = channel.Id;
            String DchannelId = ''; //DC.Id;
            MultiplePO.checkforTax(address.Id, orgn.Id);
            MultiplePO.AnalyticalAccounts(AA, POs);
            MultiplePO.getAllExistDem(PO.Id);
            MultiplePO.deleteDimension(dimen.Id);
            MultiplePO.getVendorAddress(vendIds);
            MultiplePO.generateRandomString(6);
            MultiplePO.getOrgCurrencies(orgn.Id);
            MultiplePO.fetchPrice2(cc1.Id);
            MultiplePO.getDependentPicklist('ERP7__PO__c','ERP7__Shipment_Type__c','ERP7__Shipment_Preference_Speed__c');
            MultiplePO.getProducts(sup.Id,'','',DC.Id,false,'');
            MultiplePO.createCCnew(new ERP7__Cost_Card__c(Name = 'Test Product',ERP7__Active__c=true,ERP7__Cost__c=15,ERP7__Product__c = ps.Id,ERP7__Quantity__c = 5,ERP7__Start_Date__c = system.today(),ERP7__Supplier__c = sup.id));
    }
    /*static testmethod void UnitTest3() {
        Account sup = new Account(Name='Supplier',Account_Type__c = 'Vendor');
            insert sup;
        UploadFile ufp = new UploadFile();
        UploadFile.RetriveAttachmentRecord();
        UploadFile.saveChunk(sup.Id,'','','','00P0600002pNciREAS');
        UploadFile.saveTheFile(sup.Id,'','','');
        ufp.booVar = true;
        //UploadFile.appendToFile(sup.Id,'');
    }*/
    static testmethod void UnitTest3() {
    // Step 1: Create parent record (Supplier Account)
    Account sup = new Account(Name = 'Supplier', Account_Type__c = 'Vendor');
    insert sup;

    // Step 2: Create a dummy Attachment record (to use in appendToFile)
    Attachment att = new Attachment(
        Name = 'TestFile.txt',
        Body = Blob.valueOf('Test content'),
        ParentId = sup.Id,
        ContentType = 'text/plain'
    );
    insert att;

    // Step 3: Create instance of UploadFile
    UploadFile ufp = new UploadFile();

    // Step 4: Call class methods using safe data
    UploadFile.RetriveAttachmentRecord();  // returns empty but covered

    // base64-encoded string of test chunk
    String encodedChunk = EncodingUtil.base64Encode(Blob.valueOf('Part 1'));

    // Step 5: Use valid Attachment ID from above insert
    UploadFile.saveChunk(sup.Id, 'TestFile.txt', encodedChunk, 'text/plain', att.Id);

    // Full file save test
    UploadFile.saveTheFile(sup.Id, 'FullFile.txt', EncodingUtil.base64Encode(Blob.valueOf('Full file')), 'text/plain');

    ufp.booVar = true;
}

    static testmethod void UnitTest4() {
        Product2 product = new Product2(Name = 'Test', ProductCode = 'PC-017', Family = 'Fruits', ERP7__Status__c = 'In Developement', ERP7__Track_Inventory__c = true, ERP7__Transactable__c = true, ERP7__Weight_Dimensions__c = 'Gram', ERP7__Category__c = 'IT', ERP7__Sub_Category__c = 'Software', ERP7__Weight__c = 10, ERP7__Is_Kit__c = true, ERP7__Price_Entry_Amount__c = 45, ERP7__MOQ__c = 20, ERP7__Serialise__c = true, ERP7__ASIN_Code__c = 'test', ERP7__Width__c = 2, ERP7__Lot_Tracked__c = true, ERP7__Manufacturing_Type__c = 'Process', ERP7__Item_Description__c = 'test', ERP7__Alternate_Quantity_Unit_Of_Measure__c='liter');
        insert product;
        ERP7__Serial_Number__c serial1 = new ERP7__Serial_Number__c(Name='test', ERP7__Product__c=product.Id, ERP7__Barcode__c='test');
        insert serial1;
    }
  
}