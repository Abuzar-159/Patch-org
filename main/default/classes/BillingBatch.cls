/*Changes made by - Moin
 * Date - 20th November 2023
 * Reason - Amount oaid was not getting updated for voucher
 * Fix Applied - added the change in line 
*/
global class BillingBatch implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        //Returning the Billing records which are Active and Next Billing Date is Today
        return Database.getQueryLocator([
            SELECT Id, Name, ERP7__Next_Billing_Date__c, ERP7__Create_Voucher__c, ERP7__Total_Amount__c, ERP7__Credit_Chart_of_Account__c, ERP7__Debit_Chart_of_Account__c, ERP7__Organisation__c, ERP7__Account__c, ERP7__Bank_Account__c,ERP7__Type__c, ERP7__Billing_Start_Date__c, ERP7__Billing_Frequency__c, ERP7__Last_Billing_Date__c,
            ERP7__Status__c, ERP7__Approve_Voucher__c, ERP7__Create_Payment__c, ERP7__Post_Bill__c, ERP7__Post_Invoice__c FROM ERP7__Billing__c
            WHERE ERP7__Status__c = 'Active' AND ERP7__Next_Billing_Date__c = Today
        ]);
    }
    
    global void execute(Database.BatchableContext context, List<ERP7__Billing__c> scope) { 
        try{
            System.debug('In try');
            List<ERP7__Bill__c> billRecords = new List<ERP7__Bill__c>();
            List<ERP7__Bill_Line_Item__c> billItems = new List<ERP7__Bill_Line_Item__c>();
            List<ERP7__Invoice_Line_Item__c> invList = new List<ERP7__Invoice_Line_Item__c>();
            List<ERP7__Invoice__c> invoiceRecords = new List<ERP7__Invoice__c>();
            List<ERP7__Transaction__c> transactionsToCreate = new List<ERP7__Transaction__c>();
            List<ERP7__Billing__c> billingRecordsToUpdate = new List<ERP7__Billing__c>();
            List<ERP7__Voucher__c> voucherRecords = new List<ERP7__Voucher__c>();
            List<ERP7__Payment__c> paymentRecords = new List<ERP7__Payment__c>();
            List<ERP7__Finance_General_Ledger_Entry__c> ledgerEntry = new List<ERP7__Finance_General_Ledger_Entry__c>();
            List<ERP7__Finance_General_Ledger_Entry__c> ledgerEntrycredit = new List<ERP7__Finance_General_Ledger_Entry__c>();
            
            Map<Id, List<ERP7__Billing_Item__c>> BillMap = new Map<Id, List<ERP7__Billing_Item__c>>();
            Set<Id> billing = new Set<Id>();
            for (ERP7__Billing__c record : scope) {
                billing.add(record.Id); 
            }
             
            List<ERP7__Billing_Item__c> billingItems = [Select Id, Name, ERP7__Type__c, ERP7__Quantity__c, ERP7__Price__c, ERP7__Tax__c, ERP7__Total__c,ERP7__Chart_of_Account__c, ERP7__Billing__c From ERP7__Billing_Item__c Where ERP7__Billing__c=: billing];
            
            for (ERP7__Billing_Item__c item : billingItems) {
                if (!BillMap.containsKey(item.ERP7__Billing__c)) {
                    BillMap.put(item.ERP7__Billing__c, new List<ERP7__Billing_Item__c>());
                }
                BillMap.get(item.ERP7__Billing__c).add(item);
            }
            
            for (ERP7__Billing__c record : scope) {
                Date startDate = record.ERP7__Billing_Start_Date__c;
                String frequency = record.ERP7__Billing_Frequency__c;
                Date nextBillingDate = record.ERP7__Next_Billing_Date__c;
                Date lastBill = record.ERP7__Last_Billing_Date__c ;
                
                // calculate next billing date based on frequency
                Date newNextBillingDate;
                if (frequency == 'Daily') newNextBillingDate = nextBillingDate.addDays(1);
                else if (frequency == 'Weekly') newNextBillingDate = nextBillingDate.addDays(7);
                else if (frequency == 'Fortnightly') newNextBillingDate = nextBillingDate.addDays(14);
                else if (frequency == 'Annually') newNextBillingDate = nextBillingDate.addYears(1);
                else if (frequency == 'Monthly') newNextBillingDate = nextBillingDate.addMonths(1);
                
                // update next billing date
                if(lastBill != null && newNextBillingDate != Null){
                    if(newNextBillingDate>=startDate && newNextBillingDate<=lastBill) record.ERP7__Next_Billing_Date__c = newNextBillingDate;
                }
                billingRecordsToUpdate.add(record);
                
                if (record.ERP7__Type__c == 'Bill') {
                    Id ExpenseBillRT = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByDeveloperName().get('Expense_Bill').getRecordTypeId();
                    
                    ERP7__Bill__c bill = new ERP7__Bill__c(Name = record.Name, recordTypeId=ExpenseBillRT, ERP7__Type__c='Credit', ERP7__Organisation__c=record.ERP7__Organisation__c, ERP7__Account__c= record.ERP7__Account__c, ERP7__Billing__c = record.Id ,ERP7__Amount__c=record.ERP7__Total_Amount__c, ERP7__Total_Amount__c=record.ERP7__Total_Amount__c, ERP7__Bill_Date__c=Date.today());
                    billRecords.add(bill);
                } 
                else if (record.ERP7__Type__c == 'Invoice') {
                    ERP7__Invoice__c inv = new ERP7__Invoice__c(Name = 'Invoice-'+record.Name, ERP7__Organisation__c=record.ERP7__Organisation__c, ERP7__Account__c= record.ERP7__Account__c, ERP7__Billing__c = record.Id, ERP7__Invoice_Amount__c=record.ERP7__Total_Amount__c);
                    invoiceRecords.add(inv);
                }
                else if (record.ERP7__Type__c == 'Adjustment Entries') {
                    List<ERP7__Billing_Item__c> bilitem = BillMap.get(record.Id);
                    for(ERP7__Billing_Item__c bil:bilitem){
                        // Create a new transaction record for each billing record returned
                        ERP7__Transaction__c trans = new ERP7__Transaction__c();
                        trans.ERP7__Amount__c=bil.ERP7__Total__c;
                        trans.ERP7__Transaction_Date__c=Date.today();
                        trans.ERP7__Transaction_Type__c='Adjustment';
                        trans.ERP7__Billing__c=record.Id;
                        trans.ERP7__Billing_Item__c=bil.Id;
                        trans.ERP7__Organisation__c=record.ERP7__Organisation__c;
                        trans.ERP7__Transaction_Status__c='Completed';
                        if(bil.ERP7__Type__c=='Credit'){ trans.ERP7__Credit_Chart_of_Account__c= bil.ERP7__Chart_of_Account__c; trans.ERP7__Debit_Chart_of_Account__c= record.ERP7__Bank_Account__c; trans.ERP7__Finance_Category_Type__c='Credit';
                        }else{
                            trans.ERP7__Debit_Chart_of_Account__c= bil.ERP7__Chart_of_Account__c; trans.ERP7__Credit_Chart_of_Account__c= record.ERP7__Bank_Account__c; trans.ERP7__Finance_Category_Type__c='Debit';   
                        }
                        transactionsToCreate.add(trans); 
                    }
                }
            }
            update billingRecordsToUpdate;
            
            //Adjustment Entries Records
            if (!transactionsToCreate.isEmpty()) {
                insert transactionsToCreate;
                
                Id FGLEDebitRecordTypeId = Schema.SObjectType.ERP7__Finance_General_Ledger_Entry__c.getRecordTypeInfosByDeveloperName().get('Debit_General_Ledger_Entry').getRecordTypeId();
                Id FGLECreditRecordTypeId = Schema.SObjectType.ERP7__Finance_General_Ledger_Entry__c.getRecordTypeInfosByDeveloperName().get('Credit_General_Ledger_Entry').getRecordTypeId();
                
                String FGLrecordIdForAdjBillingBatch = System.Label.FGLrecordIdForAdjBillingBatch;
                
                Id FGLid;
                system.debug('FGLrecordIdForAdjBillingBatch~>'+FGLrecordIdForAdjBillingBatch);
                
                List<ERP7__Finance_General_Ledger__c> genLedgr = [SELECT Id, Name, ERP7__Active__c from ERP7__Finance_General_Ledger__c Where ERP7__Active__c = true AND Name =:FGLrecordIdForAdjBillingBatch];
                system.debug('genLedgr~>'+genLedgr.size());

                if(genLedgr.size() > 0) FGLid = genLedgr[0].Id;
                
                for (ERP7__Transaction__c tran : transactionsToCreate) {                        
                    ERP7__Finance_General_Ledger_Entry__c entryCredit = new ERP7__Finance_General_Ledger_Entry__c(); 
                    entryCredit.ERP7__General_Ledger_Entry_Type__c='Credit';
                    entryCredit.ERP7__Finance_General_Ledger__c=FGLid;
                    entryCredit.ERP7__General_Ledger_Entry_DateTime__c= DateTime.now();
                    entryCredit.ERP7__Transactions__c=tran.Id;
                    entryCredit.ERP7__Chart_of_Account__c=tran.ERP7__Credit_Chart_of_Account__c;
                    entryCredit.RecordTypeId = FGLECreditRecordTypeId;
                    entryCredit.ERP7__Credit_Entry__c=tran.ERP7__Amount__c;
                    entryCredit.ERP7__Organisation__c=tran.ERP7__Organisation__c;
                    ledgerEntry.add(entryCredit);
                   
                    ERP7__Finance_General_Ledger_Entry__c entryDebit = new ERP7__Finance_General_Ledger_Entry__c(); 
                    entryDebit.ERP7__General_Ledger_Entry_Type__c='Debit';
                    entryDebit.ERP7__Finance_General_Ledger__c=FGLid;
                    entryDebit.ERP7__General_Ledger_Entry_DateTime__c= DateTime.now();
                    entryDebit.ERP7__Transactions__c=tran.Id;
                    entryDebit.ERP7__Chart_of_Account__c=tran.ERP7__Debit_Chart_of_Account__c;
                    entryDebit.RecordTypeId = FGLEDebitRecordTypeId;
                    entryDebit.ERP7__Debit_Entry__c=tran.ERP7__Amount__c;
                    entryDebit.ERP7__Organisation__c=tran.ERP7__Organisation__c;
                    ledgerEntry.add(entryDebit);
                }
            }  
            
            if (!ledgerEntry.isEmpty()) {
                System.debug('bfr insert');
                insert ledgerEntry;
            }
            
            system.debug('billRecords.size()~>'+billRecords.size());
            
            //Bills Records
            if (!billRecords.isEmpty()) {//
                insert billRecords;
                List<ERP7__Bill__c> bills=[Select Id, Name, ERP7__Organisation__c,ERP7__Billing__r.ERP7__Post_Bill__c, ERP7__Billing__r.Id, ERP7__Total_Amount__c, ERP7__Amount__c,ERP7__Billing__r.ERP7__Debit_Chart_of_Account__c, ERP7__Billing__r.ERP7__Bank_Account__c, ERP7__Billing__r.ERP7__Create_Voucher__c, ERP7__Billing__r.ERP7__Approve_Voucher__c, ERP7__Posted__c, ERP7__Posting_Date__c   FROM ERP7__Bill__c where Id=:billRecords];
                System.debug('Bills'+ bills);
                for(ERP7__Bill__c bill:bills){ if(bill.ERP7__Billing__r.ERP7__Post_Bill__c){ bill.ERP7__Posted__c=true;  bill.ERP7__Posting_Date__c=Date.today();
                    }
                    
                    if(bill.ERP7__Billing__r.ERP7__Create_Voucher__c){ ERP7__Voucher__c voucher = new ERP7__Voucher__c(Name = bill.Name, ERP7__Vendor_invoice_Bill__c = bill.Id, ERP7__Date__c=Date.today(), ERP7__Total_Amount__c=bill.ERP7__Total_Amount__c,ERP7__Amount_Paid__c=bill.ERP7__Total_Amount__c, ERP7__Amount__c=bill.ERP7__Total_Amount__c, ERP7__Organisation__c=bill.ERP7__Organisation__c, ERP7__Payment_Account__c=bill.ERP7__Billing__r.ERP7__Bank_Account__c);//ERP7__Amount_Paid__c=bill.ERP7__Total_Amount__c,
                        if(bill.ERP7__Billing__r.ERP7__Approve_Voucher__c){ voucher.ERP7__Approved__c=true;
                        }
                        voucherRecords.add(voucher);
                    }
                    
                    List<ERP7__Billing_Item__c> bilitem = BillMap.get(bill.ERP7__Billing__r.Id);
                    for(ERP7__Billing_Item__c bil:bilitem){ ERP7__Bill_Line_Item__c billLine = new ERP7__Bill_Line_Item__c(); billLine.Name=bil.Name; billLine.ERP7__Bill__c=bill.Id; billLine.ERP7__Quantity__c=(bil.ERP7__Quantity__c != Null)? bil.ERP7__Quantity__c : 1; billLine.ERP7__Amount__c=bil.ERP7__Price__c; billLine.ERP7__Tax_Amount__c=bil.ERP7__Tax__c; billLine.ERP7__Total_Amount__c=bil.ERP7__Total__c; billLine.ERP7__Chart_Of_Account__c=bil.ERP7__Chart_of_Account__c; billItems.add(billLine);
                    }                        
                }
                if(!billItems.isEmpty()){
                    System.debug('billItems---> '+ billItems);
                    insert billItems; 
                }    
                update bills;
            } 
            
            if (!voucherRecords.isEmpty()) {
                insert voucherRecords;  List<ERP7__Voucher__c> vouchs=[SELECT Id, Name, ERP7__Payment_Account__c, ERP7__Vendor_invoice_Bill__r.ERP7__Billing__r.ERP7__Create_Payment__c, ERP7__Total_Amount__c, ERP7__Vendor_invoice_Bill__r.Id, ERP7__Organisation__c, ERP7__Vendor_invoice_Bill__r.ERP7__Billing__r.ERP7__Post_Payment__c FROM ERP7__Voucher__c  where Id=:voucherRecords];
                for(ERP7__Voucher__c vou:vouchs){
                    if(vou.ERP7__Vendor_invoice_Bill__r.ERP7__Billing__r.ERP7__Create_Payment__c){ ERP7__Payment__c payment = new ERP7__Payment__c(Name = 'Payment-'+vou.Name, ERP7__Payment_Account__c = vou.ERP7__Payment_Account__c, ERP7__Voucher__c = vou.Id, ERP7__Account__c=vou.ERP7__Organisation__c, ERP7__Payment_Date__c=Date.today(), ERP7__Status__c='Paid',ERP7__Type__c='Credit', ERP7__Transaction_Type__c='BillPayment', ERP7__Bill__c=vou.ERP7__Vendor_invoice_Bill__r.Id, ERP7__Amount__c=vou.ERP7__Total_Amount__c); if(vou.ERP7__Vendor_invoice_Bill__r.ERP7__Billing__r.ERP7__Post_Payment__c){ payment.ERP7__Posted__c=true;
                        }
                        paymentRecords.add(payment);
                    }
                }
            } 
            
            // Invoice Records
            if (!invoiceRecords.isEmpty()) {
                insert invoiceRecords;
                List<ERP7__Invoice__c> invs=[Select Id,Name, ERP7__Billing__r.Name, ERP7__Billing__r.Id, ERP7__Billing__r.ERP7__Create_Payment__c, ERP7__Invoice_Amount__c, ERP7__Organisation__c, ERP7__Billing__r.ERP7__Post_Payment__c, ERP7__Billing__r.ERP7__Post_Invoice__c, ERP7__Posted__c, ERP7__Posted_Date__c FROM ERP7__Invoice__c where Id=:invoiceRecords];
                for(ERP7__Invoice__c invv: invs){
                    if(invv.ERP7__Billing__r.ERP7__Post_Invoice__c){ invv.ERP7__Posted__c=true;  invv.ERP7__Posted_Date__c=system.today();  }
                    if(invv.ERP7__Billing__r.ERP7__Create_Payment__c){ ERP7__Payment__c payment = new ERP7__Payment__c(Name = invv.ERP7__Billing__r.Name, ERP7__Invoice__c = invv.Id, ERP7__Account__c=invv.ERP7__Organisation__c , ERP7__Payment_Date__c=Date.today(), ERP7__Status__c='Paid', ERP7__Transaction_Type__c='InvoicePayment', ERP7__Amount__c=invv.ERP7__Invoice_Amount__c);if(invv.ERP7__Billing__r.ERP7__Post_Payment__c){ payment.ERP7__Posted__c=true;  }  paymentRecords.add(payment);
                    }
                    List<ERP7__Billing_Item__c> bilitem = BillMap.get(invv.ERP7__Billing__r.Id);
                    for(ERP7__Billing_Item__c bil:bilitem){ ERP7__Invoice_Line_Item__c invLine = new ERP7__Invoice_Line_Item__c(); invLine.Name=bil.Name;invLine.ERP7__Invoice__c=invv.Id; invLine.ERP7__Sub_Total__c=bil.ERP7__Price__c;  invLine.ERP7__VAT_Amount__c=bil.ERP7__Tax__c;  invLine.ERP7__Total_Price__c=bil.ERP7__Total__c;  invList.add(invLine);
                                                           //invLine.ERP7__Chart_Of_Account__c=bil.ERP7__Chart_of_Account__c;     
                    }       
                }
                if (!invList.isEmpty()) { insert invList;
                }
                update invs;
            }
            
            if (!paymentRecords.isEmpty()) { insert paymentRecords;
            } 
        }
        catch(exception e){
            System.debug('Exception transaction > '+ e.getMessage()+'; at line > '+e.getStackTraceString());
            System.debug('Exception transaction > '+ e.getMessage()+'; at line > '+e.getLinenumber());
        }
    }
    
    public void finish(Database.BatchableContext context) {}
}