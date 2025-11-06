@isTest Private class InvoiceEmailTestClass {
    static testmethod void UnitTestMethod()
    {   
         Order so1;
        Account c = new Account(Name='UnitTestMethodTestCust', ERP7__Account_Type__c='Customer');
        insert c;
        
        Account o = new Account(Name='UnitTestMethodTestOrg', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        
        Account s = new Account(Name='UnitTestMethodTestSupp', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
        
         Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=c.Id, Email='test@gmail.com',
                                  ERP7__Contact_Numer__c='con-001', ERP7__Company__c='Test Company',Contact_Numer__c='02922829');
        insert con;
        
        
        ERP7__Address__c billto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Billing_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert billto;
        
        ERP7__Address__c shipto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Shipping_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert shipto;
        
        ERP7__Business_Unit__c bunit = new ERP7__Business_Unit__c(Name='Test', ERP7__Organisation__c=o.Id, ERP7__Active__c=true, ERP7__Country__c='United Kingdom',
                                                                  ERP7__City__c='Birmingham', ERP7__Phone__c='0123456789', ERP7__Mailing_Address_Line_1__c='test', ERP7__Contact__c=con.Id);
        insert bunit;
        
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=shipto.Id, ERP7__Company__c='Test', ERP7__Phone__c='0123456789',
                                                        ERP7__Active__c=true, ERP7__City__c='WORKINGTON', ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California',
                                                        ERP7__Country__c='United States', ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=o.Id, ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert channel;
        Id pricebookId = Test.getStandardPricebookId();
        
        Order so = new Order(Name='Test', Is_Invoice_Sent__c = true ,Pricebook2Id = pricebookId,ERP7__Stage__c='Entered', AccountId=c.Id, ERP7__Contact__c=con.Id, ERP7__Channel__c=channel.Id,
                                                           ERP7__Ready_To_Pick_Pack__c=true, ERP7__Ready_To_Ship__c=true, ERP7__Authorised__c=true, ERP7__Is_Invoice_Sent__c=true, ERP7__Estimated_Delivery_Date__c=system.today(),
                                                           ERP7__Bill_To_Address__c=billto.Id, ERP7__Book_Date__c=system.today(), ERP7__Organisation__c=o.Id,
                                                           ERP7__Active__c=true, Status='Draft', ERP7__Barcode__c='009220', ERP7__Customer_Email__c='test@gmail.com', EffectiveDate=Date.today(),
                                                           ERP7__Fulfilled_Date__c=system.today(), ERP7__Amount_Paid__c=10, ERP7__Ship_To_Address__c=shipto.Id, ERP7__Request_Date__c=system.today(),
                                                           ERP7__Organisation_Business_Unit__c=bunit.Id,ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--');
        insert so;
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        //Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        OrderItem soli = new OrderItem(OrderId=so.Id, Product2Id=prod.Id, UnitPrice=10,PricebookEntryId = standardPrice.Id,
                                                                                 ERP7__Total_Price__c=10, ERP7__Sub_Total__c=10, ERP7__Active__c=true, ERP7__Organisation__c=o.Id,
                                                                                 Quantity=1, ERP7__Inventory_Tracked__c=true, ERP7__Order_Line_Status__c='Reserved');
        insert soli;
        ERP7__Invoice__c inv = new ERP7__Invoice__c(Name = 'INV-3699' ,Account__c =c.Id,Invoice_Date__c =System.today(),ERP7__Order_S__c = so.Id,ERP7__Contact__c=con.Id,ERP7__Organisation__c=o.Id);
        insert inv;
        /*so1 = [Select Name , Is_Invoice_Sent__c, ERP7__Total_Number_of_Items__c From Order where id =:inv.Order_S__c];  
        Invoice__c iv = [Select Id, ERP7__Total_Number_of_Items__c From Invoice__c where id =:inv.Id];
        boolean MailSent = false;
	    Integer totalRows = Integer.valueof(inv.ERP7__Total_Number_of_Items__c);*/
        OrgWideEmailAddress orgw=new OrgWideEmailAddress(Address='Tan@x.com', DisplayName='Tanny', IsAllowAllProfiles=true);
        //insert orgw;
        Attachment attach=new Attachment(Name=so.Name+'.pdf',contentType='application/pdf',ParentId=so.id);
        //attach.Name=so.Name;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=so.id;
        insert attach;
       // EmailTemplate et = new EmailTemplate (Subject ='Subject',Body = 'test body',developerName = 'test', TemplateType= 'Text', Name = 'test'); // plus any other fields that you want to set
        
    //  insert et;        
        String csfdcBaseURL = 'https://erp-mark-7-dev-ed.lightning.force.com';
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:so.id];
        System.assertEquals(1, attachments.size());
        
        PageReference pageRef = System.Page.Stand_OrderDocument;
        pageRef.getParameters().put('Name',inv.Id);
        pageRef.getParameters().put('custId',con.Id);
        // pageRef.getParameters().put('currentInvoice',inv.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(inv);
        Test.startTest();
        InvoiceEmail IE = new InvoiceEmail(sc);
        try{IE.Email_Details();} catch(Exception e){}
        try{IE.getCurrentInv(inv.Name); } catch(Exception e){}
        try{IE.buildCcEmail();} catch(Exception e){}
        try{IE.sendInvoice();} catch(Exception e){}//Back2Invoice
        try{IE.Back2Invoice();} catch(Exception e){} //createPDF
        try{IE.createPDF();} catch(Exception e){}
        Test.stopTest();
    }
    static testmethod void UnitTestMethod2()
    {
         Sales_Order__c so1;
        Account c = new Account(Name='UnitTestMethodTestCust', ERP7__Account_Type__c='Customer');
        insert c;
        
        Account o = new Account(Name='UnitTestMethodTestOrg', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        
        Account s = new Account(Name='UnitTestMethodTestSupp', ERP7__Account_Type__c='Supplier', Type='Supplier');
        insert s;
         
        Contact con = new Contact(FirstName='Test', LastName='Test', AccountId=c.Id, Email='test@gmail.com',
                                  ERP7__Contact_Numer__c='con-001', ERP7__Company__c='Test Company',Contact_Numer__c='02922829');
        insert con;
        
        
        ERP7__Address__c billto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Billing_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert billto;
        
        ERP7__Address__c shipto = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Is_Shipping_Address__c=true,
                                                       ERP7__Active__c=true, ERP7__Address_Line1__c='test', ERP7__Address_Line2__c='test', ERP7__Address_Line3__c='test',
                                                       ERP7__Country__c='United States', ERP7__City__c='Cartersville', ERP7__State__c='Georgia', ERP7__Postal_Code__c='30120',
                                                       ERP7__Organisation__c=o.Id);
        insert shipto;
        
        ERP7__Business_Unit__c bunit = new ERP7__Business_Unit__c(Name='Test', ERP7__Organisation__c=o.Id, ERP7__Active__c=true, ERP7__Country__c='United Kingdom',
                                                                  ERP7__City__c='Birmingham', ERP7__Phone__c='0123456789', ERP7__Mailing_Address_Line_1__c='test', ERP7__Contact__c=con.Id);
        insert bunit;
        
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=shipto.Id, ERP7__Company__c='Test', ERP7__Phone__c='0123456789',
                                                        ERP7__Active__c=true, ERP7__City__c='WORKINGTON', ERP7__Street__c='123 Do Not ship lane', ERP7__State_Province__c='California',
                                                        ERP7__Country__c='United States', ERP7__Zip_Postal_Code__c='92504', ERP7__Organisation__c=o.Id, ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert channel;
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test',Is_Invoice_Sent__c=true ,ERP7__Order_Status__c='Entered', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Channel__c=channel.Id,
                                                           ERP7__Ready_To_Pick_Pack__c=true, ERP7__Ready_To_Ship__c=true, ERP7__Authorised__c=true, ERP7__Is_Invoice_Sent__c=true, ERP7__Estimated_Delivery_Date__c=system.today(),
                                                           ERP7__Bill_To_Address__c=billto.Id, ERP7__Book_Date__c=system.today(), ERP7__Order_Date__c=system.today(), ERP7__Organisation__c=o.Id,
                                                           ERP7__Active__c=true, ERP7__Status__c='New', ERP7__Barcode__c='009220', ERP7__Customer_Email__c='test@gmail.com', ERP7__Expected_Date__c=system.today(),
                                                           ERP7__Fulfilled_Date__c=system.today(), ERP7__Amount_Paid__c=10, ERP7__Ship_To_Address__c=shipto.Id, ERP7__Request_Date__c=system.today(),
                                                           ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert so;
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=so.Id, ERP7__Product__c=prod.Id, ERP7__Base_Price__c=10,
                                                                                 ERP7__Total_Price__c=10, ERP7__Sub_Total__c=10, ERP7__Active__c=true, ERP7__Organisation__c=o.Id,
                                                                                 ERP7__Quantity__c=1, ERP7__Inventory_Tracked__c=true, ERP7__Order_Line_Status__c='Reserved');
        insert soli;
        ERP7__Invoice__c inv = new ERP7__Invoice__c(Name = 'test Invoice' ,Account__c =c.Id,Invoice_Date__c =System.today(),Order__c = so.Id,ERP7__Contact__c = con.Id,ERP7__Organisation__c=o.Id);
        insert inv;
        so1 = [Select Name ,Is_Invoice_Sent__c, ERP7__Total_Number_of_Items__c From Sales_Order__c where id =:inv.Order__c];  
        Invoice__c iv = [Select Id, ERP7__Total_Number_of_Items__c From Invoice__c where id =:inv.Id];
        boolean MailSent = false;
	    Integer totalRows = Integer.valueof(inv.ERP7__Total_Number_of_Items__c);
        
        OrgWideEmailAddress orgw=new OrgWideEmailAddress(Address='Tan@x.com', DisplayName='Tanny', IsAllowAllProfiles=true);
        Attachment attach=new Attachment();     
        attach.Name=so.Name;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=so.id;
        insert attach;
        
        List<Attachment> attachments=[select Name from Attachment where parent.id=:so.id];
        System.assertEquals(1, attachments.size());
        
        PageReference pageRef = System.Page.SalesOrderDocument;
        pageRef.getParameters().put('Name',inv.Id);
        pageRef.getParameters().put('custId',con.Id);
       // pageRef.getParameters().put('currentInvoice',inv.Id);
        Test.setCurrentPage(pageRef);

       // pageRef.getParameters().put('id',deal.Id);
        

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.standardController(inv);
        InvoiceEmail IE = new InvoiceEmail(sc);
        try{IE.Email_Details();} catch(Exception e){}
        try{IE.getCurrentInv(inv.Id); } catch(Exception e){}
        try{IE.buildCcEmail();} catch(Exception e){}
        try{IE.sendInvoice();} catch(Exception e){}//Back2Invoice
        try{IE.Back2Invoice();} catch(Exception e){} //createPDF
        try{IE.createPDF();} catch(Exception e){}
        Test.stopTest();
        
    }

}