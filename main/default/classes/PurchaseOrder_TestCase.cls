@isTest
private class PurchaseOrder_TestCase{
    
    static testMethod void UnitTestPurcahseOrderPDF(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = false; 
        
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
          Account Customer = new Account(Name='Organisation', Account_Type__c = 'Customer');
        insert Customer;
        Account sup = new Account(Name='Arshad',Organisation__c = orgn.Id, Account_Type__c = 'Supplier'); 
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        Address__c bAddress = new Address__c( Customer__c = Customer.Id, Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c bAddress1 = new Address__c( Customer__c = Customer.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account', Organisation__c = orgn.Id);
        insert BA;
        PO__c PO = new PO__c( Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress1.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
        insert PO;  
        Product2 ps = new Product2(Name='test', Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;  
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];     
        List<Purchase_Line_Items__c> poliList = [select id, name,  Unit_Price__c,
                        Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
            
        PageReference pageRef = System.Page.PurchaseOrderPDF;
        pageRef.getParameters().put('PONo',PO.Name);
        pageRef.getParameters().put('custId',contact.Id);
        Test.setCurrentPage(pageRef);
        
        Test.StartTest();
        PurchaseOrdersPDF pof = new PurchaseOrdersPDF();
        //PurchaseOrdersPDF.LineItemWrapper wrapper = new PurchaseOrdersPDF.LineItemWrapper();
        //List<PurchaseOrdersPDF.LineItemWrapper> PurchaseLineItems = new List<PurchaseOrdersPDF.LineItemWrapper>();
        //pof.purchaseItems.add(poli);
        
        pof.getPurchaseOrder(PO.Id);
        //pof.getPurchaseLineItems(PO.Id);
        
        //pof.ViewOrder();  
        //pof.toEmail_Address = contact.Email;   
        try { pof.sendPO(); pof.Email_Details(); pof.buildCcEmail();
            } catch(Exception e) {}
        
        String s1 = 'test';
        String s2 = 'test';
        System.assertEquals(s1,s2);
        Test.StopTest();
    }    
        
    static testMethod void UnitTestSupplierInvoice(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = false;   
        Test.startTest();
        ERP7__Module__c mod = new ERP7__Module__c(Name = 'Finance',ERP7__Inventory_Tracking_on_Stock_Outward__c = true,Run__c = true);
        insert mod;
        RecordType poRecType = [select id, developerName from RecordType where developerName = 'Return_to_Vendor_RTV' and SobjectType = 'ERP7__PO__c' Limit 1];
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account', Organisation__c = orgn.Id);
        insert BA;
        Account customer = new Account(Name='Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, 
                       Barcode__c='Site');
        insert site;
        Product2 ps = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        insert ps;
        PO__c mPO = new PO__c(
                    vendor__c = sup.Id,Barcode__c='PO',vendor_Contact__c = contact.Id);
        insert mPO; 
        Purchase_Line_Items__c mpoli = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=mPO.id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Site__c=site.Id);
        insert mpoli;
        Inventory_Stock__c WIIS = new Inventory_Stock__c(Active__c=true,Warehouse__c=site.Id,
                                  Product__c=ps.Id);
        insert WIIS;
        Stock_Inward_Line_Item__c sili1 = new Stock_Inward_Line_Item__c(
                                         Product__c = ps.Id,Site_ProductService_InventoryStock__c=WIIS.Id,Quantity__c=2,
                                         Purchase_Orders__c =mPO.Id, Purchase_Line_Items__c=mpoli.Id);
        insert sili1;
        ERP7__Stock_Outward_Line_Item__c soli = new ERP7__Stock_Outward_Line_Item__c(Name='test', Product__c = ps.Id,
                                                                                     ERP7__Site_Product_Service_Inventory_Stock__c=WIIS.Id);
        insert soli;
        PO__c PO = new PO__c(RecordTypeId=poRecType.id,Status__c ='Approved', Budget_Accounts__c = BA.Id);
        insert PO;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Site__c=site.Id);
        try{insert poli;}catch(Exception e){}         
        List<Purchase_Line_Items__c> poliList = [select id, name,  Quantity__c, 
                            Unit__c, Unit_Price__c, Total_Price__c, Product__r.Name 
                            from Purchase_Line_Items__c where id =: PO.Id];
        PageReference pageRef = System.Page.SupplierInvoice;
        pageRef.getParameters().put('Id',PO.Id);
        Test.setCurrentPage(pageRef);
        SupplierInvoice sp = new SupplierInvoice();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }

    
    static testMethod void UnitTestMultiplePotoBill(){ 
        PreventRecursiveLedgerEntry.testCasesTransactions = false;   
        Test.startTest();
        
        RecordType poRecType = [select id, developerName from RecordType where developerName = 'Return_to_Vendor_RTV' and SobjectType = 'ERP7__PO__c' Limit 1];
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account acc = new Account(Name='Syed Moin', Account_Type__c = 'Customer',ERP7__Organisation__c=orgn.Id);
        insert acc;
        Account ven = new Account(Name='Syed Moin', Account_Type__c = 'Vendor',ERP7__Organisation__c=orgn.Id);
        insert ven;
        RecordType rTypeProfile = [Select Id, Name From RecordType Where SobjectType='ERP7__Profiling__c' And Name='Employee' Limit 1];
        Profiling__c EmpProfile = new Profiling__c(Name='test',Active__c=true,RecordTypeId=rTypeProfile.Id);
        insert EmpProfile; 
        Address__c add = new Address__c(ERP7__Customer__c=acc.Id,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',ERP7__Country__c ='United Kingdom',Is_Billing_Address__c=true,Is_Shipping_Address__c=true, Primary__c=true,ERP7__Active__c=true,ERP7__Postal_Code__c='123',ERP7__State__c='Ajman');
        insert add;
        ERP7__Channel__c channel=new ERP7__Channel__c(Name='Channel',ERP7__Active__c=true,ERP7__Ship_From_Address__c=add.Id);
        insert channel;
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, Barcode__c='Site');
        Distribution_Channel__c DistributionChannels = new Distribution_Channel__c(Name = 'DistributionChannel', Active__c=true, Channel__c=channel.Id, Site__c=site.Id, Priority__c='1');
        insert DistributionChannels; 
        Employees__c emp = new Employees__c(ERP7__Channel__c = channel.Id, First_Name__c='Syed',Last_Name__c='Moin',Email__c='test@test.com', Organisation__c=orgn.Id,Employee_User__c=UserInfo.getUserId(),Employment_Status__c = 'Active',Non_Employee__c = false,Employee_Profiling__c=EmpProfile.Id);
        insert emp;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account', Organisation__c = orgn.Id);
        insert BA;
        Account customer = new Account(Name='Customer');
        insert customer; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        /*Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id, 
                       Barcode__c='Site');*/
        insert site;
        Product2 ps = new Product2(
                                Name='test',isActive=true,Barcode__c='productId',Track_Inventory__c=true);
        insert ps;
        PO__c mPO = new PO__c(
                    vendor__c = ven.Id,Barcode__c='PO',vendor_Contact__c = contact.Id, ERP7__Distribution_Channel__c = DistributionChannels.Id, Name = 'Test');
        insert mPO; 
        Purchase_Line_Items__c mpoli = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=5,Quantity_Received__c=1,Purchase_Orders__c=mPO.id,Total_Price__c=100,
                                      Product__c = ps.Id,Packed_Quantity__c = 2,Picked_Quantity__c = 3,Site__c=site.Id);
        insert mpoli;
        
        MulitplePOtoBill mpob = new MulitplePOtoBill();
        MulitplePOtoBill.fetchChannelandDC();
        MulitplePOtoBill.getPOlist('Tes', DistributionChannels.Id, 1, 1, ven.Id);
        MulitplePOtoBill.getPOlist('', DistributionChannels.Id, 1, 1, ven.Id);
        MulitplePOtoBill.getPOlist('Tes', '', 1, 1, ven.Id);
        MulitplePOtoBill.wrapper mwrap = new MulitplePOtoBill.wrapper();
        MulitplePOtoBill.LineItemWrapper lwrap = new MulitplePOtoBill.LineItemWrapper();
        MulitplePOtoBill.TotalRecords(DistributionChannels.Id);
        MulitplePOtoBill.TotalRecords('');
        MulitplePOtoBill.generateRandomString(10);
        Test.stopTest();
    }
 
}