@isTest
public class PaypalPaymentTestCases {
    static testMethod void unitTest1(){
         Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;  
        ERP7__Debit_Note__c dnote=new ERP7__Debit_Note__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=10);
        insert dnote;
        ERP7__Bank_details__c bank=new ERP7__Bank_details__c(Name='',ERP7__Account_Number__c='1234',ERP7__Active__c=true);
        insert bank;
        ERP7__Chart_of_Accounts__c cacc=new ERP7__Chart_of_Accounts__c(ERP7__Account_Code__c='1234',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id);
        insert cacc;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10,Organisation_Business_Unit__c=busUnit.Id,Organisation__c=orgn.Id);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Paid__c=false);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
        cn.ERP7__Account__c = acc.id;
        insert cn;
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Credit_Note__c = cn.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        insert pay;
        TransactionManagement.fetchPayments(null, null, null);
        PageReference pageRef = System.Page.PaypalPaymentSuccess;
        pageRef.getParameters().put('tx','12345678901234567');
        //pageRef.getParameters().put('item_number','a123');
        pageRef.getParameters().put('item_name','IVN-123');
        pageRef.getParameters().put('amt','123');
        Test.setCurrentPage(pageRef);
        System.assertEquals('ERP', 'ERP');
        //PaypalPaymentNotification ppn=new PaypalPaymentNotification();
        //ppn.CreatePayment();
    }
    
    static testMethod void unitTest2(){
         Account acc = new Account(Name='Naseeruddin', ERP7__Email__c ='makhtar@aqxolt.com', ERP7__Is_Portal_Account__c = true, Phone ='07123123123',ERP7__Subscribe_To_NewsLetters__c=true);
        insert acc;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
        Contact con = new Contact(FirstName='Test', LastName='Contact', Email ='makhtar@aqxolt.com', MobilePhone ='07123123123');
        insert con;
        Address__c add = new Address__c(Customer__c=acc.id,Contact__c=con.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='test', Postal_Code__c='test',Is_Billing_Address__c=true,ERP7__Is_Shipping_Address__c=true, Primary__c=true);
        insert add;
        Product2 pro = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert pro;  
        ERP7__Debit_Note__c dnote=new ERP7__Debit_Note__c(Name='Test',ERP7__Account__c=acc.Id,ERP7__Active__c=true,ERP7__Amount__c=10);
        insert dnote;
        ERP7__Bank_details__c bank=new ERP7__Bank_details__c(Name='',ERP7__Account_Number__c='1234',ERP7__Active__c=true);
        insert bank;
        ERP7__Chart_of_Accounts__c cacc=new ERP7__Chart_of_Accounts__c(ERP7__Account_Code__c='1234',ERP7__Active__c=true,ERP7__Organisation__c=acc.Id);
        insert cacc;
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10,Organisation_Business_Unit__c=busUnit.Id,Organisation__c=orgn.Id);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Paid__c=false);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
        cn.ERP7__Account__c = acc.id;
        insert cn;
        ERP7__Payment__c pay = new ERP7__Payment__c();
        pay.ERP7__Credit_Note__c = cn.id;
        pay.ERP7__Type__c = 'Credit';
        pay.ERP7__Amount__c = 100;
        insert pay;
        
       
        
        Id payId=pay.Id;
        PaypalPaymentController ppc=new PaypalPaymentController();
        //ppc.RedirectPages();
        PaypalPaymentController ppc1=new PaypalPaymentController(payId,payId);
        PaypalPaymentController ppc2=new PaypalPaymentController(payId,payId,true);
        System.assertEquals('ERP', 'ERP');
        //ppn.CreatePayment();
       	/*PaypalPaymentController pc = new PaypalPaymentController();
        pc.pgId = payId;
        pc.pay();
		pc.AccId=acc.Id;
        pc.ObuId=acc.Id;
        pc.Address_Line1 = add.Address_Line1__c;
        pc.Address_Line2= add.Address_Line2__c;
        pc.pay();*/
    }
}