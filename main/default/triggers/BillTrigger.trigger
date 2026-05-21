/*
* Changes made by - Syed Moin Pasha
* Date - 06th September 2021
* Reason - Transaction was not getting created for Expense Bills
* Fix - Made the changes in the Query in line number 51 as we fetching the line items based on the issue voucher selected bills
* 
*/


/*
* Changes made by - Syed Moin Pasha
* Date - 12th May 2023
* Reason - Removed try catch to entries to displaymismatch Error
* Fix - Commented line 25 and 108 and 109
* 
*/

trigger BillTrigger on Bill__c (after insert,before delete,before update, after update){
    
    public class ErrorException extends Exception {}
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    List<Transaction__c> Transactions2update = new List<Transaction__c>();
    Map<Id,Id> ExistingTransaction_Map2Bill = new Map<Id,Id>();
    system.debug('PreventRecursiveLedgerEntry.proceedVoucherCreation-->'+PreventRecursiveLedgerEntry.proceedVoucherCreation);
    //Creating vouchers 
    if (Trigger.isBefore && Trigger.isUpdate) {//this new block of code is to validate if bill is unposted after the accounting period is closed
        Set<Id> billIdsToValidate = new Set<Id>();
        for (ERP7__Bill__c newBill : Trigger.new) {
            ERP7__Bill__c oldBill = Trigger.oldMap.get(newBill.Id);

           // if (oldBill.ERP7__Posted__c == true && newBill.ERP7__Posted__c == false) {
                billIdsToValidate.add(newBill.Id);
           // }
        }
        if (billIdsToValidate.isEmpty()) {
            return;
        }
        Map<Id, String> billToAccountingPeriodStatus = new Map<Id, String>();

        for (ERP7__Transaction__c trans : [SELECT ERP7__Bill__c,ERP7__Accounting_Period__c, ERP7__Accounting_Period__r.ERP7__Status__c FROM ERP7__Transaction__c WHERE ERP7__Bill__c IN :billIdsToValidate]) {
            if (!billToAccountingPeriodStatus.containsKey(trans.ERP7__Bill__c)) {
                billToAccountingPeriodStatus.put(trans.ERP7__Bill__c, trans.ERP7__Accounting_Period__c!=null ? trans.ERP7__Accounting_Period__r.ERP7__Status__c:'');
            }
        }

       /* for (ERP7__Bill__c newBill : Trigger.new) {
            if (billIdsToValidate.contains(newBill.Id)) {
                String accountingPeriodStatus = billToAccountingPeriodStatus.get(newBill.Id);
                if (accountingPeriodStatus!=null && accountingPeriodStatus == 'Closed') {
                     newBill.addError('You cannot update the bill because the associated accounting period is permanently closed. No changes are allowed.');
                }else if (accountingPeriodStatus!=null && accountingPeriodStatus == 'Close Pending') {
                     newBill.addError('You cannot update this bill. The associated accounting period is "Close Pending." You must open the accounting period first.');
                }
            }
        }*/
    }
    if(PreventRecursiveLedgerEntry.proceedVoucherCreation && !trigger.isDelete){ //Added && !trigger.isDelete Moin on 13th june 2023
        try{
            //Getting all the bills
            List<ERP7__Bill__c> Bills = new List<ERP7__Bill__c>();
            if(trigger.isafter || trigger.isUpdate){
                for(ERP7__Bill__c b : Trigger.New){ 
                    if(Trigger.oldMap !=null){
                        if(!(Trigger.oldMap.get(b.Id).ERP7__Posted__c) && b.ERP7__Matched__c && b.ERP7__Issue_Voucher__c && b.ERP7__Posted__c) Bills.add(b);   
                        else if(!(Trigger.oldMap.get(b.Id).ERP7__Posted__c) && b.ERP7__Posted__c && b.ERP7__Issue_Voucher__c) Bills.add(b);
                    }
                    else if(b.ERP7__Matched__c && b.ERP7__Posted__c && b.ERP7__Issue_Voucher__c) Bills.add(b);
                    else if(b.ERP7__Posted__c && b.ERP7__Issue_Voucher__c) Bills.add(b);
                } 
            }
            //End of Getting all the bills
            
            //Creating the vouchers
            if( Bills.size() > 0 ){ List<ERP7__Voucher__c> vouchers = new List<ERP7__Voucher__c>();
                for( ERP7__Bill__c b : Bills ){
                    ERP7__Voucher__c v = new ERP7__Voucher__c();
                    if( b.ERP7__Organisation__c != null && Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Organisation__c.isUpdateable()){v.ERP7__Organisation__c = b.ERP7__Organisation__c;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Amount__c.isUpdateable()){v.ERP7__Amount__c = b.ERP7__Total_Amount__c;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Vendor__c.isCreateable() && Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Vendor__c.isUpdateable()){v.ERP7__Vendor__c = b.ERP7__Vendor__c;}else{/*No access*/}
                    if(Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Vendor_invoice_Bill__c.isCreateable() && Schema.sObjectType.ERP7__Voucher__c.fields.ERP7__Vendor_invoice_Bill__c.isUpdateable()){v.ERP7__Vendor_invoice_Bill__c = b.Id;}else{/*No access*/}
                    //v.ERP7__Approved__c=true;
                    vouchers.add(v); 
                }
                if(vouchers.size() > 0 && Schema.sObjectType.ERP7__Voucher__c.isCreateable() && Schema.sObjectType.ERP7__Voucher__c.isUpdateable()){ upsert vouchers; } else{ /* no access */ }
            }
            //End of Creating the vouchers
            
            //Posting the bill line items
            Map<Id, ERP7__Bill_Line_Item__c> BilllineItems = new Map<Id, ERP7__Bill_Line_Item__c>();
            Map<Id, List< ERP7__Bill_Line_Item__c >> BilllineItemsBillMap = new Map<Id, List< ERP7__Bill_Line_Item__c >>();
            
            for(ERP7__Bill_Line_Item__c BilllineItem :[Select Id, Bill__c,RecordTypeId ,RecordType.DeveloperName,Total_Amount__c,Organisation__c,Cost_Centre_Unit__c,ERP7__Posted_Date__c,Vendor__c,Product__c,Project__c,Purchase_Order__c,Purchase_Order_Line_Items__c From ERP7__Bill_Line_Item__c Where Bill__c In : Trigger.newMap.keySet()]){
                billlineItems.put(BilllineItem.id, BilllineItem);
                List< ERP7__Bill_Line_Item__c > billis = new List< ERP7__Bill_Line_Item__c >();
                if(BilllineItemsBillMap.containsKey(BilllineItem.Bill__c)) billis = BilllineItemsBillMap.get(BilllineItem.Bill__c);
                billis.add(BilllineItem);
                BilllineItemsBillMap.put(BilllineItem.Bill__c, billis);
            }
            
            Map<Id,Id> ExistingTransaction_Map2BilllineItemlineItem = new Map<Id,Id>();
            for(Transaction__c trans:[SELECT Id,Bill__c,ERP7__Bill_Line_Item__c FROM Transaction__c Where ERP7__Bill_Line_Item__c in:billlineItems.keyset()])  ExistingTransaction_Map2BilllineItemlineItem.put(trans.ERP7__Bill_Line_Item__c,trans.Id);
            List< ERP7__Bill_Line_Item__c > BillItems = new List< ERP7__Bill_Line_Item__c >();
            Set< String > BillItemsIds = new Set< String >();
            
            for( Integer i=0;i<System.Trigger.New.size();i++){
                if(Trigger.isUpdate){ 
                    //if(System.Trigger.New[i].Posted__c != System.Trigger.old[i].Posted__c){ 
                    if(BilllineItemsBillMap.containsKey(System.Trigger.New[i].Id)){ //Added by arshad 21 Sep 2023
                        for(ERP7__Bill_Line_Item__c Billitem : BilllineItemsBillMap.get(System.Trigger.New[i].Id)){ //changed by arshad 21 Sep 2023 BilllineItems.values()
                            if(!BillItemsIds.contains(Billitem.Id)){ //Added by arshad 21 Sep 2023
                                Billitem.Posted__c = System.Trigger.New[i].Posted__c;
                                Billitem.Posted_date__c = System.Today();
                                if(System.Trigger.New[i].ERP7__Project__c!=null)  Billitem.Project__c = System.Trigger.New[i].ERP7__Project__c;
                                BillItems.add(Billitem);
                                BillItemsIds.add(Billitem.Id);
                            }
                        }
                    }
                    //}
                }else{
                    if(BilllineItemsBillMap.containsKey(System.Trigger.New[i].Id)){ //Added by arshad 21 Sep 2023
                        for(ERP7__Bill_Line_Item__c Billitem : BilllineItemsBillMap.get(System.Trigger.New[i].Id)){ //changed by arshad 21 Sep 2023 BilllineItems.values()
                            if(!BillItemsIds.contains(Billitem.Id)){ Billitem.Posted__c = System.Trigger.New[i].Posted__c; Billitem.Posted_date__c = System.Today();
								if(System.Trigger.New[i].ERP7__Project__c!=null)  Billitem.Project__c = System.Trigger.New[i].ERP7__Project__c; BillItems.add(Billitem); BillItemsIds.add(Billitem.Id);
                            }
                        }
                    }
                }
            } 
            if(BillItems.size() > 0 && Schema.sObjectType.ERP7__Bill_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Bill_Line_Item__c.isUpdateable()){ 
                //Set<ERP7__Bill_Line_Item__c> uniqueSet = new Set<ERP7__Bill_Line_Item__c>(BillItems);
                
                // Convert the Set back to a list
                //List<ERP7__Bill_Line_Item__c> BillItemss = new List<ERP7__Bill_Line_Item__c>(uniqueSet);
                //BillItems=BillItemss;
                if(PreventRecursiveLedgerEntry.parentbillTriggerCase1){
                    PreventRecursiveLedgerEntry.parentbillTriggerCase1=false;
                    upsert BillItems; 
                }
                
            } else{ /* no access */ }
            
            //Posting the bill line items
            Id SIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Supplier_Invoice_Transaction'); 
            for(ERP7__Bill_Line_Item__c billlineitem : BillItems){
                if(billlineitem.Posted__c){
                    Transaction__c trans = new Transaction__c(Id=(ExistingTransaction_Map2BilllineItemlineItem.get(billlineitem.Id)!=null)?ExistingTransaction_Map2BilllineItemlineItem.get(billlineitem.Id):null);
                    if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){
                        trans.Active__c = true;   
                    }else{/*No access*/}    
                    if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = billlineitem.Total_Amount__c;}else{/*No access*/}    if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){trans.Organisation__c = billlineitem.Organisation__c;   }else{/*No access*/}   if(Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isUpdateable()){trans.Organisation_Business_Unit__c = billlineitem.Cost_Centre_Unit__c;}else{/*No access*/}   if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = (billlineitem.ERP7__Posted_Date__c != null)?billlineitem.ERP7__Posted_Date__c:System.Today();  }else{/*No access*/}   if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed';}else{/*No access*/}
                    if(billlineitem.RecordType.DeveloperName=='Expense_Bill'){ if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'Expense';}else{/*No access*/} } else{ if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'Purchase';}else{/*No access*/} }
                    if(Schema.sObjectType.Transaction__c.fields.Bill__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Bill__c.isUpdateable()){trans.Bill__c = billlineitem.Bill__c;  }else{/*No access*/} if(Schema.sObjectType.Transaction__c.fields.ERP7__Supplier__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Supplier__c.isUpdateable()){trans.ERP7__Supplier__c =  billlineitem.Vendor__c;  }else{/*No access*/}  if(Schema.sObjectType.Transaction__c.fields.ERP7__Bill_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Bill_Line_Item__c.isUpdateable()){trans.ERP7__Bill_Line_Item__c = billlineitem.Id;}else{/*No access*/}  if(Schema.sObjectType.Transaction__c.fields.Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Product__c.isUpdateable()){trans.Product__c = billlineitem.Product__c;  }else{/*No access*/}  if(Schema.sObjectType.Transaction__c.fields.Project__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Project__c.isUpdateable()){trans.Project__c = billlineitem.Project__c;  }else{/*No access*/}  if(Schema.sObjectType.Transaction__c.fields.Purchase_Return_PO__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Purchase_Return_PO__c.isUpdateable()){trans.Purchase_Return_PO__c =billlineitem.Purchase_Order__c;}else{/*No access*/} if(Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Purchase_Line_Items__c.isUpdateable()){trans.ERP7__Purchase_Line_Items__c =billlineitem.Purchase_Order_Line_Items__c; }else{/*No access*/}
                    if(SIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = SIT; }else{/*No access*/}
                    Transactions2update.add(trans);
                }
            }
            
            System.debug('From trigger'+ Transactions2update);
            if(Transactions2update.size() > 0 && Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()){ 
                upsert Transactions2update;
                System.debug('Created'+ Transactions2update);
                PostingPreventingHandler.handleBillAfterInsert(trigger.new, Trigger.newMap, trigger.oldMap);
                PreventRecursiveLedgerEntry.proceedVoucherCreation = false;
            } else{ /* no access */
                System.debug('else not created'+ Transactions2update); 
            }
            
        }catch(Exception e){
            system.debug('Exception~>'+e.getMessage()+e.getLineNumber());
            if(!Test.isRunningTest()) throw new ErrorException(e.getMessage());
        }
        //PreventRecursiveLedgerEntry.proceedVoucherCreation = false; 
    }
    //End of creting voucher 
    
    if(trigger.isInsert || trigger.isUpdate ){
        //if(PreventRecursiveLedgerEntry.proceed)
        if(PreventRecursiveLedgerEntry.billtriggerduringpayment){//this condition to prevent this trigger from invoking multiple times during payment 
        for(Transaction__c trans:[SELECT Id,Bill__c FROM Transaction__c Where Bill__c in:Trigger.newMap.keyset()])  ExistingTransaction_Map2Bill.put(trans.Bill__c,trans.Id);
        //}
        RunModule =  Module__c.getAll();
        if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c) ){
            if(!PreventRecursiveLedgerEntry.testCasesTransactions){
                List<Id> postedInvoiceIds = new List<Id>();
                if(PreventRecursiveLedgerEntry.proceed){
                    Map<Id, ERP7__Bill_Line_Item__c> BilllineItems = new Map<Id, ERP7__Bill_Line_Item__c>(); Map<Id, List< ERP7__Bill_Line_Item__c >> BilllineItemsBillMap = new Map<Id, List< ERP7__Bill_Line_Item__c >>();
                    for(ERP7__Bill_Line_Item__c BilllineItem :[Select Id, Bill__c From ERP7__Bill_Line_Item__c Where Bill__c In : Trigger.NewMap.keyset()]){ billlineItems.put(BilllineItem.id, BilllineItem);  
                        List< ERP7__Bill_Line_Item__c > billis = new List< ERP7__Bill_Line_Item__c >();
                        if(BilllineItemsBillMap.containsKey(BilllineItem.Bill__c)) billis = BilllineItemsBillMap.get(BilllineItem.Bill__c); billis.add(BilllineItem); BilllineItemsBillMap.put(BilllineItem.Bill__c, billis);
                    }
                    
                    List< ERP7__Bill_Line_Item__c > BillItems = new List< ERP7__Bill_Line_Item__c >();
                    Set< String > BillItemsIds = new Set< String >();
                    
                    for( Integer i=0;i<System.Trigger.New.size();i++){
                        if(Trigger.isUpdate){
                            if(System.Trigger.New[i].Posted__c != System.Trigger.old[i].Posted__c){
                                if(BilllineItemsBillMap.containsKey(System.Trigger.New[i].Id)){ //Added by arshad 21 Sep 2023
                                    for(ERP7__Bill_Line_Item__c Billitem : BilllineItemsBillMap.get(System.Trigger.New[i].Id)){ //changed by arshad 21 Sep 2023 BilllineItems.values()
                                        if(!BillItemsIds.contains(Billitem.Id)){ Billitem.Posted__c = System.Trigger.New[i].Posted__c; Billitem.Posted_date__c = System.Today(); BillItems.add(Billitem);  BillItemsIds.add(Billitem.Id);
                                        }
                                    }
                                }
                            }
                        }else{
                            if(BilllineItemsBillMap.containsKey(System.Trigger.New[i].Id)){ //Added by arshad 21 Sep 2023
                                for(ERP7__Bill_Line_Item__c Billitem : BilllineItemsBillMap.get(System.Trigger.New[i].Id)){  //changed by arshad 21 Sep 2023 BilllineItems.values()
                                    if(!BillItemsIds.contains(Billitem.Id)){ Billitem.Posted__c = System.Trigger.New[i].Posted__c;  Billitem.Posted_date__c = System.Today();   BillItems.add(Billitem);  BillItemsIds.add(Billitem.Id);
                                    }
                                }
                            }
                        }
                    } 
                    if(BillItems.size() > 0  && Schema.sObjectType.ERP7__Bill_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Bill_Line_Item__c.isUpdateable()){ 
                        if(PreventRecursiveLedgerEntry.parentbillTriggerCase2){
                            PreventRecursiveLedgerEntry.parentbillTriggerCase2=false;
        					upsert BillItems; 
                        }
                    } else{ /* no access */ }
                }
                //PreventRecursiveLedgerEntry.proceed = false;
                
                
                //Below code for Multiple PO payment
                Set<Id> mulBillIds = new Set<Id>();
                Set<Id> mulPOIds = new Set<Id>();
                List<ERP7__Bill_Line_Item__c> billItems = new List<ERP7__Bill_Line_Item__c>();
                List<ERP7__PO__c> po2Upsert = new List<ERP7__PO__c>();
                Id devRecordTypeId = Schema.SObjectType.ERP7__Bill__c.getRecordTypeInfosByName().get('PO Bill').getRecordTypeId();
                Decimal totalamount=0;
                Decimal payedamountnew=0;Decimal payedamountold=0;
                for( ERP7__Bill__c b : Trigger.New){
                    if(trigger.isafter && trigger.isUpdate){System.debug('Bill trigger fields ');System.debug(b);
                    		ERP7__Bill__c oldbill= Trigger.oldMap.get(b.Id);
                    		if(oldbill!=null){
                       			payedamountold = oldbill.ERP7__Amount_Paid__c!=null? oldbill.ERP7__Amount_Paid__c : 0;
                        	}
                    		if(b.RecordTypeId == devRecordTypeId && b.ERP7__Purchase_Order__c == null){
                        		mulBillIds.add(b.Id);
                    		}
                    		if(b.ERP7__Total_Amount__c!=null){
                        		totalamount = b.ERP7__Total_Amount__c;
                    		}
                    		if(b.ERP7__Amount_Paid__c!=null){
                        		payedamountnew = b.ERP7__Amount_Paid__c;
                    		}
                        }
                }System.debug('totalamount '+totalamount);System.debug('payedamountold '+payedamountold);System.debug('payedamountnew '+payedamountnew);
                if(mulBillIds.size()>0){
                    PreventRecursiveLedgerEntry.AwaitingStockPO = false;
                    PreventRecursiveLedgerEntry.LogisticLineRollup = false;
                    //Moin Added this !System.isBatch()
                    if(!System.isFuture() && !System.isBatch()) CreateDebitNote.updatePO(mulBillIds);
                }else{
                    if(totalamount!=0){
                        if(payedamountnew!=payedamountold){System.debug('set ERP7__Amount_Paid__c on PO from Bill ');System.debug(trigger.new);
                         	list<RollUpSummaryUtility.fieldDefinition> MPSfieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition> {
                        	new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount_Paid__c', 'ERP7__Amount_Paid__c')
                            	};PreventRecursiveLedgerEntry.billtriggerduringpayment=false;
                                	RollUpSummaryUtility.rollUpTrigger(MPSfieldDefinitions, trigger.new, 'ERP7__Bill__c','ERP7__Purchase_Order__c', 'ERP7__PO__c', ' ');
                      	} 
                     }  
                }
            }
        }
      }  
    }
    
    //Bills
    /*if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete && PreventRecursiveLedgerEntry.proceed) {

list<RollUpSummaryUtility.fieldDefinition> BillfieldDefinition = new list<RollUpSummaryUtility.fieldDefinition>{
new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Total_Amount__c', 'ERP7__Billed_Amount__c')
};
RollUpSummaryUtility.rollUpTrigger(BillfieldDefinition, trigger.new, 'ERP7__Bill__c','ERP7__Purchase_Order__c','ERP7__PO__c','');
if(trigger.isInsert || trigger.isUnDelete) {
List<Id> accIds = new List<Id>();
List<Account> accList = new List<Account>();
for(ERP7__Bill__c b : Trigger.new){
if(b.ERP7__Vendor__c!=null){
accIds.add(b.ERP7__Vendor__c);
}
}
Map<Id, Account> accMap = new Map<ID, Account>([select Id, ERP7__Total_Due__c, ERP7__Credit_Balance__c from Account where Id IN :accIds]);
for(ERP7__Bill__c b : Trigger.new){
if(b.ERP7__Total_Amount__c!=null && b.ERP7__Total_Amount__c>0 && b.ERP7__Vendor__c!=null && accMap.containsKey(b.ERP7__Vendor__c)){
Account acc = accMap.get(b.ERP7__Vendor__c);
if(acc.ERP7__Total_Due__c!=null) acc.ERP7__Total_Due__c = acc.ERP7__Total_Due__c + b.ERP7__Total_Amount__c;
if(acc.ERP7__Credit_Balance__c!=null) acc.ERP7__Credit_Balance__c = acc.ERP7__Credit_Balance__c + b.ERP7__Total_Amount__c;
accList.add(acc);
}
}
if(accList.size()>0 && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable() && Schema.sObjectType.Account.fields.ERP7__Credit_Balance__c.isUpdateable()){
update accList;
}
else{ /* no access *}
}
}*/
    if (Trigger.isBefore && Trigger.isDelete) {
       /* for (ERP7__Bill__c bill : Trigger.old) {
            if (bill.ERP7__Posted__c == true) {
                bill.addError('This Bill cannot be deleted because it has already been posted.');
            }
        }*/
        Set<Id> billIdsToValidate = new Set<Id>();
        for (ERP7__Bill__c bill : Trigger.old) {
            billIdsToValidate.add(bill.Id);
        }
        if (billIdsToValidate.isEmpty()) {
            return;
        }
        Map<Id, String> billToAccountingPeriodStatus = new Map<Id, String>();
        for (ERP7__Transaction__c trans : [SELECT ERP7__Bill__c,ERP7__Accounting_Period__c, ERP7__Accounting_Period__r.ERP7__Status__c FROM ERP7__Transaction__c WHERE ERP7__Bill__c IN :billIdsToValidate]) {
            if (!billToAccountingPeriodStatus.containsKey(trans.ERP7__Bill__c)) {
                billToAccountingPeriodStatus.put(trans.ERP7__Bill__c, trans.ERP7__Accounting_Period__c!=null ? trans.ERP7__Accounting_Period__r.ERP7__Status__c:'');
            }
        }
        Set<Id> billsWithDebitNotes = new Set<Id>();
        for (ERP7__Debit_Note__c debitNote : [
            SELECT Id, ERP7__Vendor_Invoice_Bill__c
            FROM ERP7__Debit_Note__c
            WHERE ERP7__Vendor_Invoice_Bill__c IN :billIdsToValidate
        ]) {
            if (debitNote.ERP7__Vendor_Invoice_Bill__c != null) {
                billsWithDebitNotes.add(debitNote.ERP7__Vendor_Invoice_Bill__c);
            }
        }
        for (ERP7__Bill__c bill : Trigger.old) {
            String accountingPeriodStatus = billToAccountingPeriodStatus.get(bill.Id);
           /* if (accountingPeriodStatus != null) {
                if (accountingPeriodStatus == 'Closed') {
                    bill.addError('Cannot delete this bill because the associated accounting period is permanently closed.');continue;
                } else if (accountingPeriodStatus == 'Close Pending') {
                    bill.addError('Cannot delete this bill because the associated accounting period is "Close Pending."');continue;
                }
            }*/
            if (bill.ERP7__Posted__c == true) {
              //  bill.addError('This Bill cannot be deleted because it has already been posted.'); continue;
            }
            if (billsWithDebitNotes.contains(bill.Id)) {
              //  bill.addError('This Bill cannot be deleted because it has associated Debit Notes.');
            }
        }
    }
    
    if(trigger.isDelete) {
        list<RollUpSummaryUtility.fieldDefinition> BillfieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition>{
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Total_Amount__c', 'ERP7__Billed_Amount__c')
                };
                    RollUpSummaryUtility.rollUpTrigger(BillfieldDefinitions, trigger.old, 'ERP7__Bill__c','ERP7__Purchase_Order__c','ERP7__PO__c','');
    }
    
    //deleting the transaction, vouchers and payments on Bill deletion
    if(Trigger.isafter && trigger.isDelete){
        List<ERP7__Transaction__c> billTransactions = [Select Id from ERP7__Transaction__c where ERP7__Bill__c In : Trigger.oldMap.keyset() ];
        List<ERP7__Payment__c> billPayments = [Select Id from ERP7__Payment__c where ERP7__Bill__c IN : Trigger.oldMap.Keyset() ];
        List<ERP7__Voucher__c> billVoucher = [Select Id from ERP7__Voucher__c where ERP7__Vendor_invoice_Bill__c IN : Trigger.oldMap.keyset() ];
        if( billTransactions.size() > 0  && ERP7__Transaction__c.sObjectType.getDescribe().isDeletable()) { delete billTransactions; }  else{ /* no access */ }
        if( billPayments.size() > 0 &&  ERP7__Payment__c.sObjectType.getDescribe().isDeletable()) { delete billPayments; } else{ /* no access */ }
        if( billVoucher.size() > 0 && ERP7__Voucher__c.sObjectType.getDescribe().isDeletable()) { delete billVoucher; } else{ /* no access */ }
    }
    
    //task
    /*
if(PreventRecursiveLedgerEntry.BillRollup && trigger.isAfter && trigger.isInsert){
PreventRecursiveLedgerEntry.BillRollup= false;
Integer i=0;
if(trigger.new[i].ERP7__Purchase_Order__c != null){
ERP7__PO__c billPO = [SELECT Id, Name, ERP7__Tasks__c FROM ERP7__PO__c WHERE Id =: trigger.new[i].ERP7__Purchase_Order__c];
if(billPO.ERP7__Tasks__c != null){
List<ERP7__PO__c> POlist = [SELECT Id, Name, ERP7__Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Amount__c, ERP7__Tasks__c FROM ERP7__PO__c 
WHERE ERP7__Tasks__c =: billPO.ERP7__Tasks__c AND Id IN (SELECT ERP7__Purchase_Order__c FROM ERP7__Bill__c WHERE ERP7__Purchase_Order__c != null)];

ERP7__Actions_Tasks__c task = [SELECT Id, ERP7__Expense_Amount__c, ERP7__Total_Expense_Tax__c, ERP7__Milestone__c FROM ERP7__Actions_Tasks__c WHERE Id =: billPO.ERP7__Tasks__c];
if(POlist != null && task != null){
task.ERP7__Expense_Amount__c = 0;  
task.ERP7__Total_Expense_Tax__c = 0;
//task.ERP7__Total_Expense_Amount__c    = 0;
//task.ERP7__Expense_Amount__c       += trigger.new[0].ERP7__Amount__c;
for(ERP7__PO__c PO : POlist) { 
task.ERP7__Total_Expense_Tax__c += PO.ERP7__Tax_Amount__c;   task.ERP7__Expense_Amount__c    += PO.ERP7__Amount__c;
}
if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Expense_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Expense_Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Expense_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Expense_Amount__c.isUpdateable()){ upsert task;} else{ } //Total_Exp_Amount
}
}
}
}
*/
    
    
}