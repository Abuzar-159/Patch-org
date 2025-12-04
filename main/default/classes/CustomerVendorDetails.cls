public with sharing class CustomerVendorDetails {
    @AuraEnabled    
    public static Account DefaultOrganisation(){
         return UtilClass.getOrganisationByLogin_Employee();
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchInvoices(String customerVendorId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Invoice__c> invoices = new List<ERP7__Invoice__c>();
        Set<Id> invoiceIds = new Set<Id>();
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Customer_Id__c , ERP7__Organisation__r.Name, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Total_Due__c   from ERP7__Invoice__c where ERP7__Paid_Amount__c = 0 and ERP7__Account__c=:customerVendorId order by CreatedDate DESC];
        if(invoices.size()>0){
            tw.nopaymentInvoices.addall(invoices);
        }
        invoices = new List<ERP7__Invoice__c>(); 
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Customer_Id__c , ERP7__Organisation__r.Name, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Total_Due__c    from ERP7__Invoice__c where ERP7__Paid_Amount__c > 0 and ERP7__Account__c=:customerVendorId  and ERP7__Paid__c = false order by CreatedDate DESC];
        if(invoices.size()>0){
            tw.partiallyInvoices.addall(invoices);
        }
        invoices = new List<ERP7__Invoice__c>(); 
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Customer_Id__c , ERP7__Organisation__r.Name, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Total_Due__c   from ERP7__Invoice__c where ERP7__Paid__c = true and ERP7__Account__c=:customerVendorId order by CreatedDate DESC];
        if(invoices.size()>0){
            tw.paidInvoices.addall(invoices);
        }
        return tw;
    }
    
    
    @AuraEnabled
    public static TransactionWrapper fetchBills(String customerVendorId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Bill__c> bills = new List<ERP7__Bill__c>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Vendor_Bill_Date__c, ERP7__Total_Amount__c, ERP7__Amount_Due__c   from ERP7__Bill__c where ERP7__Vendor__c=:customerVendorId and ERP7__Amount_Paid__c=0 order by CreatedDate DESC];
        if(bills.size()>0){
            tw.nopaymentBills.addall(bills);
        }
        bills = new List<ERP7__Bill__c>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Vendor_Bill_Date__c, ERP7__Total_Amount__c, ERP7__Amount_Due__c  from ERP7__Bill__c where ERP7__Vendor__c=:customerVendorId and ERP7__Amount_Paid__c>0 and ERP7__Amount_Due__c>0 order by CreatedDate DESC];
        if(bills.size()>0){
            tw.partiallyBills.addall(bills);
        }
        bills = new List<ERP7__Bill__c>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Vendor_Bill_Date__c, ERP7__Total_Amount__c, ERP7__Amount_Due__c  from ERP7__Bill__c where ERP7__Vendor__c=:customerVendorId and ERP7__Amount_Due__c<=0 order by CreatedDate DESC];
        if(bills.size()>0){
            tw.paidBills.addall(bills);
        }
        return tw;
    }
	
    @AuraEnabled
    public static TransactionWrapper fetchPayments(String customerVendorId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Payment__c> payments = new List<ERP7__Payment__c>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Account__r.Name, ERP7__Total_Amount__c, ERP7__Payment_Date__c   from ERP7__Payment__c where ERP7__Accounts__c=:customerVendorId and ERP7__Invoice__c!= null order by CreatedDate DESC];
        if(payments.size()>0){
            tw.invoicePayments.addall(payments);
        }
        payments = new List<ERP7__Payment__c>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Account__r.Name, ERP7__Total_Amount__c, ERP7__Payment_Date__c  from ERP7__Payment__c where ERP7__Accounts__c=:customerVendorId and ERP7__Bill__c!= null order by CreatedDate DESC];
        if(payments.size()>0){
            tw.billPayments.addall(payments);
        }
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchCreditNotes(String customerVendorId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Credit_Note__c> creditnotes = new List<ERP7__Credit_Note__c>();
        creditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate,ERP7__Balance__c , ERP7__Organisation__r.Name, ERP7__Credit__c, ERP7__Date__c  from ERP7__Credit_Note__c where ERP7__Account__c =:customerVendorId and ERP7__Debit__c=0 order by CreatedDate DESC];
        if(creditnotes.size()>0){
            tw.unpaidCreditnotes.addall(creditnotes);
        }
        creditnotes = new List<ERP7__Credit_Note__c>();
        creditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Balance__c ,ERP7__Organisation__r.Name, ERP7__Credit__c, ERP7__Date__c from ERP7__Credit_Note__c where ERP7__Account__c =:customerVendorId and ERP7__Debit__c>0 and ERP7__Balance__c>0 order by CreatedDate DESC];
        if(creditnotes.size()>0){
            tw.partiallyCreditnotes.addall(creditnotes);
        }
        creditnotes = new List<ERP7__Credit_Note__c>();
        creditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Balance__c , ERP7__Organisation__r.Name, ERP7__Credit__c, ERP7__Date__c  from ERP7__Credit_Note__c where ERP7__Account__c =:customerVendorId and ERP7__Balance__c<=0 order by CreatedDate DESC];
        if(creditnotes.size()>0){
            tw.paidCreditnotes.addall(creditnotes);
        }
        return tw;
    }
    
    
    @AuraEnabled
    public static TransactionWrapper fetchDebitNotes(String customerVendorId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Debit_Note__c> debitnotes = new List<ERP7__Debit_Note__c>();
        debitnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Debit__c , ERP7__Remaining_Amount__c , ERP7__Credit_Note_Date__c , ERP7__Organisation__r.Name from ERP7__Debit_Note__c where ERP7__Account__c=:customerVendorId and ERP7__Credit__c=0 order by CreatedDate DESC];
        if(debitnotes.size()>0){
            tw.unpaidDebitnotes.addall(debitnotes);
        }
        debitnotes = new List<ERP7__Debit_Note__c>();
        debitnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Debit__c , ERP7__Remaining_Amount__c , ERP7__Credit_Note_Date__c , ERP7__Organisation__r.Name from ERP7__Debit_Note__c where ERP7__Account__c=:customerVendorId and ERP7__Credit__c>0 and ERP7__Remaining_Amount__c>0 order by CreatedDate DESC];
        if(debitnotes.size()>0){
            tw.partaillyDebitnotes.addall(debitnotes);
        }
        debitnotes = new List<ERP7__Debit_Note__c>();
        debitnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Debit__c , ERP7__Remaining_Amount__c , ERP7__Credit_Note_Date__c , ERP7__Organisation__r.Name from ERP7__Debit_Note__c where ERP7__Account__c=:customerVendorId and ERP7__Remaining_Amount__c<=0 order by CreatedDate DESC];
        if(debitnotes.size()>0){
            tw.paidDebitnotes.addall(debitnotes);
        }
        return tw;
    }
    
    @AuraEnabled
    public static TransactionAmountWrapper fetchAmounts(String customerVendorId, Date StartDate, Date EndDate){
        TransactionAmountWrapper taWrap = new TransactionAmountWrapper();
        List<ERP7__Invoice__c> invoices = new List<ERP7__Invoice__c>();
        Set<Id> invoiceIds = new Set<Id>();
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Invoice_Amount__c, ERP7__Total_Due__c  from ERP7__Invoice__c where ERP7__Invoice_Amount__c!=null and ERP7__Total_Due__c!=null and ERP7__Account__c=:customerVendorId order by CreatedDate DESC];
        if(invoices.size()>0){
            Decimal invAmount = 0;
            Decimal recievableAmount = 0;
            for(ERP7__Invoice__c inv : invoices){
                invAmount = invAmount + inv.ERP7__Invoice_Amount__c;
                recievableAmount = recievableAmount + inv.ERP7__Total_Due__c;
            }
            taWrap.invoiceAmount = invAmount.setScale(2);
            taWrap.recievableAmount = recievableAmount.setScale(2);
        }
        List<ERP7__Bill__c> bills = new List<ERP7__Bill__c>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Total_Amount__c, ERP7__Amount_Due__c  from ERP7__Bill__c where ERP7__Vendor__c=:customerVendorId and ERP7__Total_Amount__c!=null and ERP7__Amount_Due__c!=null order by CreatedDate DESC];
        if(bills.size()>0){
            Decimal billAmount = 0;
            Decimal payableAmount = 0;
            for(ERP7__Bill__c bill : bills){
                billAmount = billAmount + bill.ERP7__Total_Amount__c;
                payableAmount = payableAmount + bill.ERP7__Amount_Due__c;
            }
            taWrap.billAmount = billAmount.setScale(2);
            taWrap.payableAmount = payableAmount.setScale(2);
        }
        List<ERP7__Payment__c> payments = new List<ERP7__Payment__c>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Account__r.Name, ERP7__Total_Amount__c  from ERP7__Payment__c where ERP7__Accounts__c=:customerVendorId and ERP7__Invoice__c!= null and ERP7__Total_Amount__c!=null order by CreatedDate DESC];
        if(payments.size()>0){
            Decimal invPayAmount = 0;
            for(ERP7__Payment__c pay : payments){
                invPayAmount = invPayAmount + pay.ERP7__Total_Amount__c;
            }
            taWrap.invPaymentAmount = invPayAmount.setScale(2);
        }
        payments = new List<ERP7__Payment__c>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Account__r.Name, ERP7__Total_Amount__c from ERP7__Payment__c where ERP7__Accounts__c=:customerVendorId and ERP7__Bill__c!= null and ERP7__Total_Amount__c!=null order by CreatedDate DESC];
        if(payments.size()>0){
            Decimal billPayAmount = 0;
            for(ERP7__Payment__c pay : payments){
                billPayAmount = billPayAmount + pay.ERP7__Total_Amount__c;
            }
            taWrap.billPaymentAmount = billPayAmount.setScale(2);
        }
        List<ERP7__Credit_Note__c> creditnotes = new List<ERP7__Credit_Note__c>();
        creditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Balance__c  from ERP7__Credit_Note__c where ERP7__Account__c =:customerVendorId and ERP7__Balance__c>0 order by CreatedDate DESC];
        if(creditnotes.size()>0){
            Decimal creditAmount = 0;
            for(ERP7__Credit_Note__c cred : creditnotes){
                creditAmount = creditAmount + cred.ERP7__Balance__c;
            }
            taWrap.availableCredit = creditAmount.setScale(2);
        }
        return taWrap;
    }
    public class TransactionAmountWrapper{
        @AuraEnabled public Decimal invoiceAmount {get;set;}
        @AuraEnabled public Decimal invPaymentAmount {get;set;}
        @AuraEnabled public Decimal billAmount {get;set;}
        @AuraEnabled public Decimal billPaymentAmount {get;set;}
        @AuraEnabled public Decimal availableCredit {get;set;}
        @AuraEnabled public Decimal returnedAmount {get;set;}
        @AuraEnabled public Decimal recievableAmount {get;set;}
        @AuraEnabled public Decimal payableAmount {get;set;}
        public TransactionAmountWrapper(){
            invoiceAmount = invPaymentAmount = billAmount = billPaymentAmount = availableCredit = returnedAmount = recievableAmount = payableAmount = 0;
        }
    }
    // Wrapper Class
    public class TransactionWrapper{
        @AuraEnabled public Date StartDate {get;set;}
        @AuraEnabled public Date EndDate {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> nopaymentInvoices {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> partiallyInvoices {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> paidInvoices {get;set;}
        
        @AuraEnabled public List<ERP7__Bill__c> nopaymentBills {get;set;}
        @AuraEnabled public List<ERP7__Bill__c> partiallyBills {get;set;}
        @AuraEnabled public List<ERP7__Bill__c> paidBills {get;set;}
        
        @AuraEnabled public List<ERP7__Payment__c> billPayments {get;set;}
        @AuraEnabled public List<ERP7__Payment__c> invoicePayments {get;set;}
        
        @AuraEnabled public List<ERP7__Credit_Note__c> unpaidCreditnotes {get;set;}
        @AuraEnabled public List<ERP7__Credit_Note__c> partiallyCreditnotes {get;set;}
        @AuraEnabled public List<ERP7__Credit_Note__c> paidCreditnotes {get;set;}
        
        @AuraEnabled public List<ERP7__Debit_Note__c> unpaidDebitnotes {get;set;}
        @AuraEnabled public List<ERP7__Debit_Note__c> partaillyDebitnotes {get;set;}
        @AuraEnabled public List<ERP7__Debit_Note__c> paidDebitnotes {get;set;}
        
        public TransactionWrapper(){
            nopaymentInvoices = new List<ERP7__Invoice__c>();
            partiallyInvoices = new List<ERP7__Invoice__c>();
            paidInvoices = new List<ERP7__Invoice__c>();
            
            nopaymentBills = new List<ERP7__Bill__c>();
            partiallyBills = new List<ERP7__Bill__c>();
            paidBills = new List<ERP7__Bill__c>();
            
            billPayments = new List<ERP7__Payment__c>();
            invoicePayments = new List<ERP7__Payment__c>();
            
            unpaidCreditnotes = new List<ERP7__Credit_Note__c>();
            partiallyCreditnotes = new List<ERP7__Credit_Note__c>();
            paidCreditnotes = new List<ERP7__Credit_Note__c>();
            
            unpaidDebitnotes = new List<ERP7__Debit_Note__c>();
            partaillyDebitnotes = new List<ERP7__Debit_Note__c>();
            paidDebitnotes = new List<ERP7__Debit_Note__c>();
        }
        
    }
}