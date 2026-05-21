@isTest
public class VoucherTestClass {
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
        
        ERP7__Voucher__c Vou = new ERP7__Voucher__c(Name='Test',ERP7__Amount__c=360,ERP7__Vendor__c=s.id,Posted__c =true);
        insert Vou;
        Transaction__c trans = new Transaction__c(Name='test trans',Voucher_Bill_Payment__c=Vou.Id);
        insert trans;
        Vou.ERP7__Amount_Paid__c = 20;
        update Vou;
        Attachment attach=new Attachment();     
        attach.Name=Vou.Name;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=Vou.id;
        insert attach;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:Vou.id];
        System.assertEquals(1, attachments.size());
        
        PageReference pageRef2 = System.Page.Voucher;
        pageRef2.getParameters().put('id','');
            pageRef2.getParameters().put('custId','');                       
            Test.setCurrentPage(pageRef2);
        VoucherDocument inv = new VoucherDocument();
        try{
            inv.sendVoucher();
            inv.Back2Voucher();
        }catch(Exception ex){}
        
        Test.setCurrentPage(pageRef2);
        PageReference pageRef = System.Page.Voucher;
        pageRef.getParameters().put('Vou Id',Vou.Id);
        pageRef.getParameters().put('custId',o.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        VoucherDocument VD = new VoucherDocument();
        VD.Email_Details();
        String VouNum = Vou.Id;
        VD.getVou(VouNum);
        try{VD.buildCcEmail();}catch(Exception e){}
        VD.sendVoucher();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSenderDisplayName('Aqxolt India Private Limited');
        try{VD.Back2Voucher();VD.createPDF();}catch(Exception e){}
        Test.stopTest();

    }
}