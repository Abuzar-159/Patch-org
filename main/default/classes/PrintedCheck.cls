public with sharing class PrintedCheck {
    /*
    Public Account Vendor { get; set; }
    Public List<Bill__c> VendorBillList { get; set; }
    public Decimal TotalAmount {get;set;}
    public Decimal SubTotalAmount {get;set;}
    public Decimal TotalTaxAmount {get;set;}
    public Decimal TotalAmountPaid {get;set;}
    
    public PrintedCheck(ApexPages.StandardController controller) {
        TotalAmount=0.00;
        SubTotalAmount = 0.00;
        TotalTaxAmount=0.00;
        TotalAmountPaid = 0.00;
        String accID = controller.getId();//ApexPages.CurrentPage().getParameters().get('Id');
        
        Vendor = [select Id,Name,BillingStreet,Billingcity,BillingState,Company_Registration_Number__c,BillingCountry,BillingPostalCode FROM Account where id=:accID];
        VendorBillList = [Select Id,Name,Purchase_Order__c,Purchase_Order__r.Code__c,Vendor__c,Due_Date__c,Received_date__c,Amount__c,Total_Amount__c,Amount_Paid__c,VAT_TAX_Amount__c FROM Bill__c Where Vendor__c =:accId And Status__c = 'Paid'];
        for(Bill__c  b:VendorBillList){
            TotalAmount +=b.Total_Amount__c;
            SubTotalAmount += b.Amount__c;
            TotalTaxAmount +=b.VAT_TAX_Amount__c ;
            TotalAmountPaid += b.Amount_Paid__c;
        
        }
    
    }
*/
}