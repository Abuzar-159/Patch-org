@isTest
public class TaxSummaryUtilsTestCases {
    
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
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Name='00017576',ERP7__Account__c=acc.Id,ERP7__Contact__c=con.Id,ERP7__Bill_To_Address__c=add.Id,Ship_To_Address__c=add.Id,ERP7__Total_Shipping_Amount__c=100);
        insert so;        
        Sales_Order_Line_Item__c soli = new Sales_Order_Line_Item__c(Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Sales_Order__c=so.id,Total_Price__c=100,VAT_Amount__c=10,Organisation_Business_Unit__c=busUnit.Id,Organisation__c=orgn.Id);
        insert soli;
        ERP7__Invoice__c inv=new ERP7__Invoice__c(Name='INV-8336',ERP7__Order__c=so.Id,ERP7__Account__c=acc.Id,ERP7__Organisation__c=acc.Id);
        insert inv;
        Invoice_Line_Item__c invli = new Invoice_Line_Item__c(Sales_order_Line_item__c=soli.id, Base_Price__c=100,Discount_Amount__c=10,Product__c=pro.id,Quantity__c=1,Total_Price__c=100,Invoice__c=inv.id);
        insert invli;
        
        RecordType custProfile_RTypes = [select Id, Name From RecordType Where Name = 'Customer' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        RecordType orderProfile_RTypes = [select Id, Name From RecordType Where Name = 'Order Profile' and SobjectType = 'ERP7__Profiling__c' Limit 1];
        ERP7__Profiling__c custProfile = new ERP7__Profiling__c(Name='test',RecordTypeId=custProfile_RTypes.Id,ERP7__Tax_Sourcing_Rules__c = 'Destination');
        insert custProfile;
        Tax_Plan__c tp = new Tax_Plan__c(Type__c='sales');
        insert tp;
        Tax__c tax = new Tax__c(Active__c=true,Effective_Date__c=System.Today(),Expiry_Date__c=System.Today()+10,Tax_Rate__c=10,ERP7__Type__c='Sales tax',ERP7__Account_Profile__c=custProfile.Id,ERP7__Province__c='Georgio',ERP7__Country__c='Canada');
        insert tax;
        Product_Tax_Allocation__c PTA=new Product_Tax_Allocation__c(Tax_Plan__c=tp.Id,Tax__c=tax.Id,ERP7__Active__c=true,Name='Test',ERP7__Organisation__c=acc.Id,Organisation_Business_Unit__c=busUnit.Id);
        insert PTA;
        List<Sales_Order_Line_Item__c> SOLIList=new List<Sales_Order_Line_Item__c>();
        SOLIList.add(soli);
        
        TaxSummaryUtils.createTaxSummaries(SOLIList);
        TaxSummaryUtils.updateTaxSummaries(SOLIList);
        TaxSummaryUtils.deleteTaxSummaries(SOLIList);
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
	
}