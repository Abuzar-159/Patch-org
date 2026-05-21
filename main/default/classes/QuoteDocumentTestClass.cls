@isTest
private class QuoteDocumentTestClass {
	
    static testmethod void UnitTestMethod()
    {
        Account c = new Account(Name='UnitTestMethod10TestCust', ERP7__Account_Type__c='Customer');
        insert c;
        
        Account o = new Account(Name='UnitTestMethod10TestOrg', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        
        Account s = new Account(Name='UnitTestMethod10TestSupp', ERP7__Account_Type__c='Supplier', Type='Supplier');
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
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        
        ERP7__Quotes__c quote = new ERP7__Quotes__c(Name='Test', ERP7__Customer__c=c.Id, ERP7__Channel__c=channel.Id, ERP7__Status__c='Draft',
                                                    ERP7__Request_Date__c=system.today(), ERP7__Bill_To_Address__c=billto.Id, ERP7__Organisation__c=o.Id,
                                                    ERP7__Contact__c=con.Id, ERP7__Ship_To_Address__c=shipto.Id, ERP7__Organisation_Business_Unit__c=bunit.Id);
        insert quote;
        
        ERP7__Quote_Line_Items__c quotelineitem = new ERP7__Quote_Line_Items__c(Name='Test', ERP7__Quantity__c=10, ERP7__Total_Price__c=10, ERP7__Organisation__c=o.Id,
                                                                                ERP7__Organisation_Business_Unit__c=bunit.Id, ERP7__Quotes__c=quote.Id, ERP7__Base_Price__c=10);
        insert quotelineitem;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
       
        
        OrgWideEmailAddress orgw=new OrgWideEmailAddress(Address='Tan@x.com', DisplayName='Tanny', IsAllowAllProfiles=true);
        Attachment attach=new Attachment();   	
    	attach.Name=quote.Name;
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=quote.id;
        insert attach;
    	
    	List<Attachment> attachments=[select id, name from Attachment where parent.id=:quote.id];
    	System.assertEquals(1, attachments.size());
        
        PageReference pageRef = System.Page.QuoteDocument;
        pageRef.getParameters().put('Quote Id',quote.Id);
        pageRef.getParameters().put('custId',con.Id);
        Test.setCurrentPage(pageRef);
        
        QuoteDocument QD = new QuoteDocument();
        QD.Email_Details();
        String QONum = quote.Id;
        QD.getQuotes(QONum);
        try{QD.buildCcEmail();}catch(Exception e){}
        QD.sendQuote();
        try{QD.Back2Quote();}catch(Exception e){}
        
    }
}