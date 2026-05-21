@isTest
private class RMADocumentTestClass {
    static testmethod void UnitTestMethod()
    {
        Account c = new Account(Name='Arshad', ERP7__Account_Type__c='Customer'); 
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
        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='Test', ERP7__Order_Status__c='Entered', ERP7__Account__c=c.Id, ERP7__Contact__c=con.Id, ERP7__Channel__c=channel.Id,
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
        
        ERP7__Return_Merchandise_Authorisation__c rma = new ERP7__Return_Merchandise_Authorisation__c(Name='Test', ERP7__SO__c=so.Id, ERP7__Expected_Date__c=system.today(), ERP7__Account__c=c.Id,
                                                                                                      ERP7__Return_Contact__c=con.Id, ERP7__Active__c=true, ERP7__Organisation__c=o.Id, ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert rma;
        
        ERP7__RMA_Line_Item__c rmalineitem = new ERP7__RMA_Line_Item__c(Name='Test', ERP7__SOLI__c=soli.Id, ERP7__Organisation__c=o.Id, ERP7__Organisation_Business_Unit__c=bunit.Id,
                                                                        ERP7__Active__c=true, ERP7__Return_Merchandise_Authorisation__c=rma.Id, ERP7__Return_Status__c='Quality Check');
        insert rmalineitem;
        
        OrgWideEmailAddress orgw=new OrgWideEmailAddress(Address='Tan@x.com', DisplayName='Tanny', IsAllowAllProfiles=true);
        Attachment attach=new Attachment();   	
    	attach.Name=so.Name;
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=rma.id;
        insert attach;
    	
    	List<Attachment> attachments=[select id, name from Attachment where parent.id=:rma.id];
    	System.assertEquals(1, attachments.size());
        
        PageReference pageRef = System.Page.SalesOrderDocument;
        pageRef.getParameters().put('RMA Id',rma.Id);
        pageRef.getParameters().put('custId',con.Id);
        Test.setCurrentPage(pageRef);
        
        RMADocument RD = new RMADocument();
        RD.Email_Details();
        String RMANum = rma.Id;
        RD.getRMA(RMANum);
        try{RD.buildCcEmail();}catch(Exception e){}
        RD.sendRMA();
        try{RD.Back2RMA();}catch(Exception e){}
    }
}