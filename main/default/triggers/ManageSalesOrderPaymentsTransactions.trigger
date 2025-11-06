/*
 * 
 * Changes made by - Moin
 * Date - 31st january 2022
 * Reason - to prevent any effect on the invoice and the sales order against the Refund payment 
 * Change made - commented the line from 96 to 127 and 77, 78
 * 
 * * Changes made by - Moin
 * Date - 21st december 2022
 * Reason - to fix the unable to lock row issue 
 * Change made - added for update in line 165, 174 query
 * 
 * * Changes made by - Moin
 * Date - 31st july 2023
 * Reason - to fix payment issue as the payments were not getting created
 * Fix Applied - moved code from line 151 to 149
 *
 * * Changes made by - Parveez
 * Date - 3rd November 2023
 * Reason - To Update the order Amount Paid when a payment is created
 * Fix Applied - code added from line 225 to 256
 *
*/

trigger ManageSalesOrderPaymentsTransactions on Payment__c(before insert,before update,after insert, after update,before delete, after delete, after undelete) {
    if(!Test.isRunningTest() && PreventRecursiveLedgerEntry.proceed)
        
        PreventRecursiveLedgerEntry.proceed = false; 
    Map<string, Module__c > RunModule = new Map<string, Module__c >();
    RunModule =  Module__c.getAll();
    String TriggerHandlerName = 'ERP7.PaymentImpl';
    Global_Trigger_Handlers__c gv = Global_Trigger_Handlers__c.getValues('ERP7__Payment__c');
    
    if(gv != null)TriggerHandlerName = gv.ClassName__c;
    
    Type t = Type.ForName(TriggerHandlerName);
    
    ITrigger th =(ITrigger)t.newInstance();
    
    if(Trigger.isAfter){
        if(Trigger.isInsert)
            th.afterInsert();
        else if(Trigger.isUpdate)
            th.afterUpdate();
        else if(Trigger.isUndelete)
            th.afterUndelete();
        else if(Trigger.isdelete)
            th.afterDelete();
    }else{
        if(Trigger.isInsert)
            th.beforeInsert();
        else if(Trigger.isUpdate){
            //new code to validate if the payment is unposted after the accounting perios is closed
            Set<Id> paymentIdsToValidate = new Set<Id>();boolean hasErrors = false;
            for (ERP7__Payment__c newPayment : Trigger.new) {
                ERP7__Payment__c oldPayment = Trigger.oldMap.get(newPayment.Id);
    
                if (oldPayment.ERP7__Posted__c == true && newPayment.ERP7__Posted__c == false) {
                    paymentIdsToValidate.add(newPayment.Id);
                }
                if (oldPayment.ERP7__Posted__c == true && newPayment.ERP7__Posted__c == true) {
                    if (oldPayment.ERP7__Amount__c != newPayment.ERP7__Amount__c
                       ) {
                           hasErrors = true;
                         //  newPayment.addError('You cannot modify this payment because it has already been posted.');
                       }
                }
            }
            if (paymentIdsToValidate.isEmpty()) {
                return;
            }
            Map<Id, String> paymentToAccountingPeriodStatus = new Map<Id, String>();
            
            for (ERP7__Transaction__c trans : [SELECT ERP7__Payment__c, ERP7__Accounting_Period__c, ERP7__Accounting_Period__r.ERP7__Status__c FROM ERP7__Transaction__c WHERE ERP7__Payment__c IN :paymentIdsToValidate]) {
                if (!paymentToAccountingPeriodStatus.containsKey(trans.ERP7__Payment__c)) {
                    paymentToAccountingPeriodStatus.put(trans.ERP7__Payment__c, trans.ERP7__Accounting_Period__c!=null ? trans.ERP7__Accounting_Period__r.ERP7__Status__c:'');
                }
            }
           /* for (ERP7__Payment__c newPayment : Trigger.new) {
                if (paymentIdsToValidate.contains(newPayment.Id)) {
                    String accountingPeriodStatus = paymentToAccountingPeriodStatus.get(newPayment.Id);
                    if (accountingPeriodStatus!=null && accountingPeriodStatus == 'Closed') { hasErrors = true;
                        newPayment.addError('You cannot unpost the payment because the associated accounting period is permanently closed. No changes are allowed.');
                    }else if (accountingPeriodStatus!=null && accountingPeriodStatus == 'Close Pending') { hasErrors = true;
                        newPayment.addError('You cannot unpost this payment. The associated accounting period is "Close Pending." You must open the accounting period first.');
                    }
                }
            }*/ //new code ends here
            if (!hasErrors){th.beforeUpdate();}
        }
        else if(Trigger.isdelete){
            Set<Id> paymentIdsToValidate = new Set<Id>();boolean hasErrors = false;
            for (ERP7__Payment__c oldPayment : Trigger.old) {
                paymentIdsToValidate.add(oldPayment.Id);
            }
            
            if (paymentIdsToValidate.isEmpty()) {
                return;
            }
            
            Map<Id, String> paymentToAccountingPeriodStatus = new Map<Id, String>();
            for (ERP7__Transaction__c trans : [SELECT ERP7__Payment__c, ERP7__Accounting_Period__r.ERP7__Status__c FROM ERP7__Transaction__c WHERE ERP7__Payment__c IN :paymentIdsToValidate]) {
                if (!paymentToAccountingPeriodStatus.containsKey(trans.ERP7__Payment__c)) {
                    paymentToAccountingPeriodStatus.put(trans.ERP7__Payment__c, trans.ERP7__Accounting_Period__c != null ? trans.ERP7__Accounting_Period__r.ERP7__Status__c : '');
                }
            }
            
            for (ERP7__Payment__c oldPayment : Trigger.old) {
                String accountingPeriodStatus = paymentToAccountingPeriodStatus.get(oldPayment.Id);
                
               /* if (accountingPeriodStatus != null) {
                    if (accountingPeriodStatus == 'Closed') {
                        oldPayment.addError('You cannot delete this payment because the associated accounting period is permanently closed.');hasErrors = true;continue;
                    } else if (accountingPeriodStatus == 'Close Pending') {
                        oldPayment.addError('You cannot delete this payment because the associated accounting period is "Close Pending."');hasErrors = true;continue;
                    }
                }*/
                if (oldPayment.ERP7__Posted__c == true) {
                	// oldPayment.addError('This payment cannot be deleted because it has already been posted.');
            	}
            }
            if(!hasErrors){
            th.beforeDelete();}}
        
    }
    //Moin added below line on 13th june 2023
    //if(trigger.isAfter && trigger.isUpdate) PostingPreventingHandler.handlePaymentAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap); 
    //PreventRecursiveLedgerEntry.proceed = false;
    
    
    // trigger to handle Payment delete and update account, delete transaction
    if(trigger.isBefore){
        //try{
            Map<String, Decimal>  vendorUpdate = new Map<String, Decimal>();   
            Map<String, Decimal> accToUpdate = new Map<String, Decimal>();
            Map<String, String> payInvoice = new Map<String, String>();
            Set<id> Pids = new Set<id>(); Set<Id> invoiceIds = new Set<id>();
            Set<id> soIds = new Set<id>();
            Set<id> invIds = new Set<id>();
            Map <Id, ERP7__Sales_Order__c> soMap = new Map<Id, ERP7__Sales_Order__c>();
            Map <Id, ERP7__Invoice__c> invMap = new Map<Id, ERP7__Invoice__c>();
            Map < Id, Id > existingTransactionForPayment_MAP = new Map < Id, Id > ();
            List<Transaction__c> transList = new List<Transaction__c>();
            if(Trigger.isUpdate) transList = [SELECT id, Payment__c, Transaction_Type__c FROM Transaction__c WHERE Payment__c in : Trigger.newMap.keyset() and Transaction_Type__c = 'Refund'];
            if(transList.size()>0){
            for (Transaction__c trans: transList) 
                existingTransactionForPayment_MAP.put(trans.Payment__c, trans.id);
            }
            List < Transaction__c > Transactions2update = new List < Transaction__c > ();
            List < ERP7__Sales_Order__c > orders2update = new List < ERP7__Sales_Order__c > ();
            List < ERP7__Invoice__c > invoices2update = new List < ERP7__Invoice__c > ();
            //if(trigger.isInsert){
            Id CIT = RecordTypeUtil.getObjectRecordTypeId(Transaction__c.SObjectType, 'Customer Invoice Transaction');
            Id SIT = RecordTypeUtil.getObjectRecordTypeId(Transaction__c.SObjectType, 'Supplier Invoice Transaction');
        if(!Trigger.isDelete){
            for(Payment__c payment : trigger.new){
                if(payment.ERP7__Refund__c){
                    if(payment.ERP7__Sales_Order__c!=null) soIds.add(payment.ERP7__Sales_Order__c);
                    if(payment.ERP7__Invoice__c != null) invIds.add(payment.ERP7__Invoice__c);
                }
            }
        }
            if(soIds.size()>0 && invIds.size()>0){
                //soMap = new Map<Id,ERP7__Sales_Order__c>([select Id, ERP7__Refund_Amount__c from ERP7__Sales_Order__c where Id IN :soIds]);
                //invMap = new Map<Id,ERP7__Invoice__c>([select Id, ERP7__Refund_Amount__c from ERP7__Invoice__c where Id IN :invIds]);
                for(Payment__c payment : trigger.new){
                    if(payment.ERP7__Refund__c){
                        Transaction__c trans = new Transaction__c(id = (existingTransactionForPayment_MAP.get(payment.id) != null) ? existingTransactionForPayment_MAP.get(payment.id) : null);
                        if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){trans.Active__c = true;}else{/*No access*/}
                        if(payment.ERP7__Refund_Amount__c!=null){ if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = payment.ERP7__Refund_Amount__c;}else{/*No access*/} }
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = (payment.Posted_Date__c != null) ? payment.Posted_Date__c : System.Today();}else{/*No access*/}
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed';}else{/*No access*/}
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isUpdateable()){trans.Transaction_Method__c = payment.Payment_Gateway__c;}else{/*No access*/}
                        if(payment.ERP7__Debit_Note__c != null){ if(Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isUpdateable()){trans.ERP7__Debit_Note__c = payment.ERP7__Debit_Note__c;}else{/*No access*/}}
                        if(payment.ERP7__Pre_Payment__c){ if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'PrePayment';}else{/*No access*/} }
                        else{ if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'RefundPay';}else{/*No access*/} }//Moin changed 'Refund' to 'RefundPay'
                        if(Schema.sObjectType.Transaction__c.fields.Payment__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Payment__c.isUpdateable()){trans.Payment__c = payment.Id;}else{/*No access*/}
                        if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){trans.Organisation__c = payment.ERP7__Account__c;}else{/*No access*/}
                        if (payment.ERP7__Voucher__c != null || payment.ERP7__Bill__c != null){   if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){trans.RecordTypeId =  SIT;}else{/*No access*/} }
                        else{    if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){trans.RecordTypeId = CIT;}else{/*No access*/} }
                        Transactions2update.add(trans);
                        /*
                        if(invMap.containskey(payment.ERP7__Invoice__c) ){
                            ERP7__Invoice__c inv = invMap .get(payment.ERP7__Invoice__c);
                            if(Trigger.isInsert){
                                if(inv.ERP7__Refund_Amount__c == null) inv.ERP7__Refund_Amount__c = payment.ERP7__Refund_Amount__c;
                                else inv.ERP7__Refund_Amount__c = inv.ERP7__Refund_Amount__c + payment.ERP7__Refund_Amount__c;
                            }
                            if(Trigger.isUpdate){
                                if(inv.ERP7__Refund_Amount__c == null) inv.ERP7__Refund_Amount__c = payment.ERP7__Refund_Amount__c;
                                else{
                                    Payment__c pp = Trigger.oldMap.get(payment.Id);
                                    if(pp.ERP7__Refund_Amount__c!=null) inv.ERP7__Refund_Amount__c = inv.ERP7__Refund_Amount__c - pp.ERP7__Refund_Amount__c + payment.ERP7__Refund_Amount__c;
                                    else inv.ERP7__Refund_Amount__c = inv.ERP7__Refund_Amount__c + payment.ERP7__Refund_Amount__c;
                                }
                            }
                            invoices2update.add(inv);
                        }
                        if(soMap.containskey(payment.ERP7__Sales_Order__c) ){
                            ERP7__Sales_Order__c so = soMap.get(payment.ERP7__Sales_Order__c);
                            if(Trigger.isInsert){
                                if(so.ERP7__Refund_Amount__c == null) so.ERP7__Refund_Amount__c = payment.ERP7__Refund_Amount__c;
                                else so.ERP7__Refund_Amount__c = so.ERP7__Refund_Amount__c + payment.ERP7__Refund_Amount__c;
                            }
                            if(Trigger.isUpdate){
                                if(so.ERP7__Refund_Amount__c == null) so.ERP7__Refund_Amount__c = payment.ERP7__Refund_Amount__c;
                                else{
                                    Payment__c pp = Trigger.oldMap.get(payment.Id);
                                    if(pp.ERP7__Refund_Amount__c!=null) so.ERP7__Refund_Amount__c = so.ERP7__Refund_Amount__c - pp.ERP7__Refund_Amount__c + payment.ERP7__Refund_Amount__c;
                                    else so.ERP7__Refund_Amount__c = so.ERP7__Refund_Amount__c + payment.ERP7__Refund_Amount__c;
                                }
                            }
                            orders2update.add(so);
                        }
                        */
                    }
                }
            }  
         
            system.debug('here Transactions2update.size()~>'+Transactions2update.size());
            //PreventRecursiveLedgerEntry.proceed = true;
            if (Transactions2update.size() > 0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){ upsert Transactions2update;PostingPreventingHandler.handlePaymentAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap); }else{ /*('Not allowed to upsert transaction');*/ }
            //Moin Commented this on 13th june 2023
            //PostingPreventingHandler.handlePaymentAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap); 
            //if (orders2update.size()>0) update orders2update;
            system.debug('invoices2update.size()~>'+invoices2update.size());
        
            if (invoices2update.size()>0) update invoices2update;
            //}
            if(trigger.isDelete){
                // Getting the records Ids to update 
                for(ERP7__Payment__c Pa:trigger.old){
                    
                    // getting the vendor ids for updating the vendor paid in field
                    if(Pa.ERP7__Bill__c != Null && Pa.ERP7__Accounts__c != null) vendorUpdate.put(Pa.ERP7__Accounts__c, vendorUpdate.get(Pa.ERP7__Accounts__c) ==null ? Pa.ERP7__Total_Amount__c : vendorUpdate.get(Pa.ERP7__Accounts__c) + Pa.ERP7__Total_Amount__c);
                    // End of getting the vendor ids for updating the vendor paid in field
                    
                    if(Pa.ERP7__Invoice__c != Null)invoiceIds.add(Pa.ERP7__Invoice__c);
                    
                    Pids.add(Pa.id);
                    
                    if(Pa.ERP7__Bill__c == null && Pa.ERP7__Accounts__c != null){
                        accToUpdate.put(Pa.ERP7__Accounts__c, accToUpdate.get(Pa.ERP7__Accounts__c)==null ? Pa.ERP7__Total_Amount__c : accToUpdate.get(Pa.ERP7__Account__c) + Pa.ERP7__Total_Amount__c );
                    }
                }
                
                //End Of  Getting the records Ids to update 
                //updating the invoice to paid false on payment deletion
                List<ERP7__Invoice__c> updateInvoices = [Select id,ERP7__Paid__c  FROM ERP7__Invoice__c WHERE Id IN : invoiceIds  ];
                if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Paid__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Paid__c.isUpdateable()){ for( ERP7__Invoice__c inv : updateInvoices){ inv.ERP7__Paid__c = false; } }
                if( updateInvoices.size() > 0 && Schema.SObjectType.ERP7__Invoice__c.isCreateable() && Schema.SObjectType.ERP7__Invoice__c.isUpdateable()) upsert updateInvoices; else{ }
                //End Of updating the invoice to paid false on payment deletion
                
                //updating the vendor paid in records
                if( vendorUpdate.size() > 0 ){
                    List<Account> vendorAccounts = [Select id,ERP7__Paid_In__c from Account where ID IN : vendorUpdate.keyset() for update];
                    for( Account a : vendorAccounts ){
                        if(Schema.sObjectType.Account.fields.ERP7__Paid_In__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Paid_In__c.isUpdateable()) a.ERP7__Paid_In__c = a.ERP7__Paid_In__c == Null ? vendorUpdate.get( a.Id ) : a.ERP7__Paid_In__c - vendorUpdate.get( a.Id );
                    }
                    if( vendorAccounts.size() > 0 && Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()) upsert vendorAccounts; else{ }
                }
                //updating the vendor paid in records
                
                //updating the accounts total due and piad out on payment delete   
                List<Account> accounts = [Select id,ERP7__Total_Due__c,ERP7__Paid_Out__c from Account where id IN : accToUpdate.keyset() for update];
                //Moin commented this on 27th december 2023
                /*for(Account a:accounts){
                    if(Schema.sObjectType.Account.fields.ERP7__Paid_Out__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Paid_Out__c.isUpdateable()){
                        if(a.ERP7__Paid_Out__c == null)a.ERP7__Paid_Out__c = 0;
                        if(accToUpdate!=null && accToUpdate.containskey(a.Id)) a.ERP7__Paid_Out__c -= accToUpdate.get(a.Id);//Moin added this condition if(accToUpdate!=null && accToUpdate.containskey(a.Id)) on 20th december 2023
                    }
                    if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()){
                        if(accToUpdate!=null && accToUpdate.containskey(a.Id)) a.ERP7__Total_Due__c += accToUpdate.get(a.Id);//Moin added this condition if(accToUpdate!=null && accToUpdate.containskey(a.Id)) on 20th december 2023
                    }
                }
                if(accounts.size() > 0 && Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()) upsert accounts; else{ }*/
                //End Of updating the accounts total due on payment delete 
                
                //transactions to delete on payment delete
                list<Transaction__c> trans= new list<Transaction__c>();
                trans = [select id,ERP7__Payment__c from Transaction__c where ERP7__Payment__c in:Pids];
                if(trans.size()>0 && Transaction__c.sObjectType.getDescribe().isDeletable()) delete trans; else{ }
                //End Of transactions to delete on payment delete
            }
        //}catch(Exception e){}
    }
    //End of  trigger to handle Payment delete and update account, delete transaction
    //
    //
    if(trigger.isAfter){System.debug('set the ERP7__Amount_Paid__c on Bill from  payment');System.debug(trigger.new);
        list<RollUpSummaryUtility.fieldDefinition> MPSfieldDefinitions = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Amount__c', 'ERP7__Amount_Paid__c')
                };System.debug('trigger new data');System.debug(trigger.new);
                    RollUpSummaryUtility.rollUpTrigger(MPSfieldDefinitions, trigger.new, 'ERP7__Payment__c','ERP7__Bill__c', 'ERP7__Bill__c', '');
        
        //Added To update the order Amount Paid when a payment is cretead
        /*List<Order> OrdertoUpdate = new List<Order>();
        List<Order> FetchOrders = new List<Order>();
        List<ERP7__Invoice__c> InvList = new List<ERP7__Invoice__c>();
        set<Id> OrderIds = new set<Id>();
        set<Id> InvoceIds = new set<Id>();
        
        for(Payment__c payment : trigger.new){
            InvoceIds.add(payment.ERP7__Invoice__c);
        }
        
        if(InvoceIds.size()>0){
                InvList = [SELECT Id, Name,ERP7__Order_S__c  FROM ERP7__Invoice__c WHERE Id IN :InvoceIds];
                for(ERP7__Invoice__c Inv : InvList){
                    OrderIds.add(Inv.ERP7__Order_S__c);
                }
        }
        
        if(OrderIds.size()>0){
            FetchOrders = [SELECT Id, Name, ERP7__Amount__c, ERP7__Amount_Paid__c, ERP7__Order_Amount__c, ERP7__Due_Amount__c FROM Order WHERE ERP7__Active__c = true AND Id IN :OrderIds];
        }
        
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Payment__c pay : trigger.new){
                for(Order ord : FetchOrders){
                    if(Schema.sObjectType.Order.fields.ERP7__Amount_Paid__c.isCreateable() && Schema.sObjectType.Order.fields.ERP7__Amount_Paid__c.isUpdateable()){
                        ord.ERP7__Amount_Paid__c = ord.ERP7__Amount_Paid__c + pay.ERP7__Amount__c;
                        OrdertoUpdate.add(Ord);
                    }
                } 
            } 
        }
        if( OrdertoUpdate.size() > 0 && Schema.SObjectType.Order.isCreateable() && Schema.SObjectType.Order.isUpdateable()) {upsert OrdertoUpdate;} else{ }*/
    }
}