@isTest
public class DebitNoteTestClass {
    static testmethod void UnitTestMethod(){
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');
        insert c;
        
        Account o = new Account(Name='Test', ERP7__Account_Type__c='Organisation', Type='Organisation');
        insert o;
        
        Account s = new Account(Name='Test', ERP7__Account_Type__c='Supplier', Type='Supplier');
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
        
        ERP7__Debit_Note__c DBN = new ERP7__Debit_Note__c(Name='Test',ERP7__Amount__c=200,ERP7__Active__c=true,	ERP7__Credit__c=200,ERP7__Account__c=s.id, ERP7__Organisation__c = o.Id);
         insert DBN;
        ERP7__Debit_Note_Item__c dline = new ERP7__Debit_Note_Item__c(Name='Test', ERP7__Debit_Note__c = DBN.Id, ERP7__Posted__c = true);
        insert dline;
        TransactionManagement.fetchDebitNotes(o.Id, null, null);
         Attachment attach=new Attachment();   	
    	attach.Name=DBN.Name;
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=DBN.id;
        insert attach;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:DBN.id];
    	System.assertEquals(1, attachments.size());
        
        PageReference pageRef2 = System.Page.DebitNote;            
            pageRef2.getParameters().put('id','');
            pageRef2.getParameters().put('custId','');                       
            Test.setCurrentPage(pageRef2);
            DebitNoteDocument inv = new DebitNoteDocument();
            try { 
                inv.sendDebitNote(); 
                 inv.Back2DebitNote();
            }catch(Exception ex){}
            //inv.createPDF();
            
        Test.setCurrentPage(pageRef2);
        PageReference pageRef = System.Page.DebitNote;
        pageRef.getParameters().put('DBN Id',DBN.Id);
        pageRef.getParameters().put('custId',o.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        DebitNoteDocument DN = new DebitNoteDocument();
        DN.Email_Details();
        String DBNNum = DBN.Id;
        DN.getDBN(DBNNum);
        try{DN.buildCcEmail();}catch(Exception e){}
        DN.sendDebitNote();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSenderDisplayName('Aqxolt India Private Limited');
        try{DN.Back2DebitNote();DN.createPDF();}catch(Exception e){}
        Test.stopTest();
    }

}