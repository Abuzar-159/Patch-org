/*
* Changes made by - Syed Moin Pasha
* Date - 26th Spetember 2022
* Reason - Prevented the transaction creation on invoice level
* Change for - Moved all the transaction process to invoice line items level
* Code Change - Commented line 155 and 351
*/

/*
* Changes made by - Syed Moin Pasha
* Date -  12th May 2023
* Reason - Removed try catch to entries mismatch Error
* Change for - 
* Code Change - Commented line 22 and 442 and 443
*/


trigger ManageCustomerInvoiceTransactions on Invoice__c (after update,before delete,before update, after insert) {//after insert,
    
    /* For updating the total due in customer account on new invoice posted */
    public class ErrorException extends Exception {}
    //the below code to validate when the updates are done and invoice is posted
    Boolean hasError = false;Boolean hasError2 = false;
    if(Trigger.isBefore && Trigger.isUpdate){
        for (ERP7__Invoice__c newInvoice : Trigger.new) {
            ERP7__Invoice__c oldInvoice = Trigger.oldMap.get(newInvoice.Id);
            
            if (oldInvoice.ERP7__Posted__c == true && newInvoice.ERP7__Posted__c == true) {
                if (newInvoice.ERP7__Discount_Amount__c != oldInvoice.ERP7__Discount_Amount__c ||
                    newInvoice.ERP7__Invoice_Shipping_Amount__c != oldInvoice.ERP7__Invoice_Shipping_Amount__c ||
                    newInvoice.ERP7__Tax_Amount__c != oldInvoice.ERP7__Tax_Amount__c ||
                    newInvoice.ERP7__Invoice_Amount__c != oldInvoice.ERP7__Invoice_Amount__c ||
                    newInvoice.ERP7__Down_Payment__c != oldInvoice.ERP7__Down_Payment__c ||
                    newInvoice.ERP7__Invoice_Amount__c != oldInvoice.ERP7__Invoice_Amount__c ||
                    newInvoice.ERP7__Total_Down_Payment_Amount__c != oldInvoice.ERP7__Total_Down_Payment_Amount__c) {
                    //    newInvoice.addError('Changes cannot be made to a posted invoice.');hasError=true;
                }
            }
        }
    }//end
  /*  if(Trigger.isBefore && Trigger.isDelete){
        Set<Id> invoiceIdsToDelete = new Set<Id>();
        for (ERP7__Invoice__c invoice : Trigger.old) {
            invoiceIdsToDelete.add(invoice.Id);
        }
        List<ERP7__Payment__c> postedPayments = [
            SELECT ERP7__Invoice__c 
            FROM ERP7__Payment__c 
            WHERE ERP7__Invoice__c IN :invoiceIdsToDelete //AND ERP7__Posted__c = true removed this to have validation for unposted payments too
        ];
        if (postedPayments.isEmpty()) {
            return;
        }
        Set<Id> invoicesWithPostedPayments = new Set<Id>();
        for (ERP7__Payment__c payment : postedPayments) {
            invoicesWithPostedPayments.add(payment.ERP7__Invoice__c);
        }
        for (ERP7__Invoice__c invoice : Trigger.old) {
            if (invoicesWithPostedPayments.contains(invoice.Id)) {System.debug('throw error');
                invoice.addError('This invoice cannot be deleted because it is linked to an existing payment.');hasError=true;
            }
        }
    }*///the above block of code to not allow invoice deletion if the payments are made
    if(hasError){return;}
    try{
        Set<Id> InvWithOrd=new Set<Id>();
        Set<Id> InvWithSO=new Set<Id>();
        if(Trigger.New!=null){
            if(Trigger.New.size() > 0){
                for(ERP7__Invoice__c inv: Trigger.New){        
                    if(inv.ERP7__Order__c != null){
                        InvWithSO.add(inv.ERP7__Order__c);
                    }else if(inv.ERP7__Order_S__c != null){
                        InvWithOrd.add(inv.ERP7__Order_S__c);
                    }
                }
            }
        }
        else if(Trigger.old != null){
            if(Trigger.old.size() > 0){
                for(ERP7__Invoice__c inv: Trigger.old){        
                    if(inv.ERP7__Order__c != null){
                        InvWithSO.add(inv.ERP7__Order__c);
                    }else if(inv.ERP7__Order_S__c != null){
                        InvWithOrd.add(inv.ERP7__Order_S__c);
                    }
                }
            }
        }
        
        if(InvWithSO.size() > 0){  
            if(Trigger.isInsert){
                Map<id, Decimal> TotalDueOfAccounts=new Map<id, Decimal>();
                for( Integer i=0;i<Trigger.New.size();i++){
                    if(Trigger.New[i].ERP7__Total_Due__c>0 && Trigger.New[i].ERP7__Active__c==true && (Trigger.New[i].Record_Type_Name__c=='On_Account_Payment' || Trigger.New[i].Record_Type_Name__c=='Sale')){
                        Decimal existingDue=0;
                        if(TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c)!=null)existingDue=TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c); 
                        TotalDueOfAccounts.put(Trigger.New[i].ERP7__Account__c,existingDue+Trigger.New[i].ERP7__Total_Due__c); 
                    }
                    
                }
                List<Account> accs=[Select id,ERP7__Total_Due__c From Account where id In: TotalDueOfAccounts.keySet() for update];
                List<Account> updateAccs=new List<Account>();
                for(Account acc : accs){
                    if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()){
                        if(acc.ERP7__Total_Due__c==null)acc.ERP7__Total_Due__c=0;
                        acc.ERP7__Total_Due__c=acc.ERP7__Total_Due__c+TotalDueOfAccounts.get(acc.id);
                    }
                    updateAccs.add(acc);
                }
                if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){upsert updateAccs;}else{/*Not allowed to upsert*/}
            }
            /* For updating the total due in customer account on payment made. */
            
            //Closing the invoice
            if(Trigger.isupdate){
                try{
                    Map<ID, ERP7__Invoice__c> InvoiceClosed = new Map<ID, ERP7__Invoice__c>();
                    for(ERP7__Invoice__c inv : Trigger.New){
                        if( inv.ERP7__Paid__c && inv.ERP7__Status__c == 'Paid' ){
                            ERP7__Invoice__c invc = new ERP7__Invoice__c();
                            invc = inv;
                            InvoiceClosed.put(inv.ERP7__Order__c, invc); 
                        }
                    }
                    if( InvoiceClosed.size() > 0 ){
                        List<ERP7__Sales_Order__c> SOrders = [ Select id,ERP7__Status__c from ERP7__Sales_Order__c where Id IN : InvoiceClosed.keyset() ];
                        for(ERP7__Sales_Order__c SO : SOrders){
                            if( SO.ERP7__Status__c != 'Delivered' )InvoiceClosed.remove(SO.ID);
                        }
                        if( InvoiceClosed.values().size() > 0){
                            List<ERP7__Invoice__c> allInvcs = InvoiceClosed.values();
                            list<String> finv = new list<String>();
                            for( integer i=0;i<allInvcs.size();i++ ){ 
                                finv.add(allInvcs[i].Id);                       
                            }
                            List<ERP7__Invoice__c> invcs = [Select id,ERP7__Status__c from ERP7__Invoice__c where id IN : finv ];
                            if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Status__c.isUpdateable()){
                                for(ERP7__Invoice__c  inv : invcs) inv.ERP7__Status__c = 'Closed';
                            }
                            if(invcs.size() > 0 && Schema.SObjectType.ERP7__Invoice__c.isCreateable() && Schema.SObjectType.ERP7__Invoice__c.isUpdateable()){upsert invcs;}else{/*Not allowed to upsert*/}
                        }
                    }
                }Catch(Exception e){ }
            }
            //End of the closing invoice
            
            if(Trigger.isupdate){
                Map<id, Decimal> TotalDueOfAccounts=new Map<id, Decimal>();
                for( Integer i=0;i<Trigger.New.size();i++){
                    if(Trigger.old[i].ERP7__Final_Due_Amount__c>0 && Trigger.New[i].ERP7__Active__c==true && (Trigger.New[i].Record_Type_Name__c=='On_Account_Payment' || Trigger.New[i].Record_Type_Name__c=='Sale')){
                        if(Trigger.New[i].ERP7__Final_Due_Amount__c != Trigger.old[i].ERP7__Final_Due_Amount__c   ){
                            Decimal existingDue=0;
                            if(TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c)!=null)existingDue=TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c); 
                            TotalDueOfAccounts.put(Trigger.New[i].ERP7__Account__c,existingDue+Trigger.old[i].ERP7__Final_Due_Amount__c);
                        }
                    }
                }
                List<Account> accs=[Select id,ERP7__Total_Due__c,ERP7__Paid_Out__c From Account where id In: TotalDueOfAccounts.keySet() for update];
                List<Account> updateAccs=new List<Account>();
                for(Account acc : accs){
                    if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()){
                        if(acc.ERP7__Total_Due__c == null)acc.ERP7__Total_Due__c = 0;
                        acc.ERP7__Total_Due__c=acc.ERP7__Total_Due__c-TotalDueOfAccounts.get(acc.id);
                    }
                    if(Schema.sObjectType.Account.fields.ERP7__Paid_Out__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Paid_Out__c.isUpdateable()){
                        if(acc.ERP7__Paid_Out__c == null)acc.ERP7__Paid_Out__c = 0;
                        acc.ERP7__Paid_Out__c += TotalDueOfAccounts.get(acc.id);  
                    }
                    updateAccs.add(acc);
                }
                if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){upsert updateAccs;}else{/*Not allowed to upsert*/}
            }
            System.debug('before transaction');
            
            if(Trigger.isupdate || (Trigger.isAfter && Trigger.isInsert)){
                //if(Trigger.isupdate){
                /*Creating Transaction for  Customer Invoice line Items when Invoice is Posted */
                Map<string, Module__c > RunModule = new Map<string, Module__c >();
                RunModule =  Module__c.getAll();
                System.debug('RunModule.get.Run__c:'+RunModule.get('Finance').Run__c);
                System.debug('PreventRecursiveLedgerEntry.proceed:'+PreventRecursiveLedgerEntry.proceed);
                System.debug('PreventRecursiveLedgerEntry.InvoiceProcess:'+PreventRecursiveLedgerEntry.InvoiceProcess);
                if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c)){    //  && PreventRecursiveLedgerEntry.InvoiceProcess//&& PreventRecursiveLedgerEntry.proceed       (Comment: PreventRecursiveLedgerEntry.proceed become true when update the Account)
                    List<Id> postedInvoiceIds = new List<Id>();
                    Map<Id, Id> InvoiceExisting_Transactions = new Map<Id, id>();
                    Id CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Customer_Invoice_Transaction'); 
                    List<Transaction__c> Transactions2update = new List<Transaction__c>();
                    for(Transaction__c eTransaction :[Select Id,Invoice__c, Organisation__c,  Product__c, ERP7__Amount__c, ERP7__Invoice_Line_Item__c   From Transaction__c Where Invoice__c In : Trigger.NewMap.keyset() And Payment__c = NULL AND RecordTypeId=:CIT ])
                        InvoiceExisting_Transactions.put(eTransaction.Invoice__c, eTransaction.id);
                    
                    List< Invoice__c > invList = new List< Invoice__c >();
                    for( Integer i=0;i<Trigger.New.size();i++){
                        if(Trigger.New[i].Posted__c && (Trigger.New[i].Record_Type_Name__c=='Sale'  || Trigger.New[i].Record_Type_Name__c == 'Schedule_Invoice')){ // || Trigger.New[i].Record_Type_Name__c=='Advance'
                            Transaction__c trans = new Transaction__c(Id=(InvoiceExisting_Transactions.get(Trigger.New[i].Id)!=null)?InvoiceExisting_Transactions.get(Trigger.New[i].Id):null);
                            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = Trigger.New[i].Posted__c;
                            if(InvoiceExisting_Transactions.get(Trigger.New[i].Id) == null && Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = Trigger.New[i].ERP7__Invoice_Amount__c;
                            if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = Trigger.New[i].Organisation__c;
                            if(Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isUpdateable()) trans.Organisation_Business_Unit__c = Trigger.New[i].Organisation_Business_Unit__c;
                            if(Schema.sObjectType.Transaction__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Sales_Order__c.isUpdateable()) trans.Sales_Order__c = Trigger.New[i].Order__c;
                            if(Schema.sObjectType.Transaction__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Customer__c.isUpdateable()) trans.Customer__c = Trigger.New[i].Account__c;
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = (Trigger.New[i].Posted_Date__c != null)? Trigger.New[i].Posted_Date__c:System.Today();
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Sales';
                            if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT;}
                            if(Schema.sObjectType.Transaction__c.fields.Invoice__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Invoice__c.isUpdateable()) trans.Invoice__c = Trigger.New[i].Id;
                            Transactions2update.add(trans);
                            if(Trigger.New[i].ERP7__Total_Number_of_Items__c>0) invList.add(Trigger.New[i]);
                        }
                    }    
                    if(Transactions2update.size()>0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){upsert Transactions2update;}else{/*Not allowed to upsert*/}
                    System.debug('PostingPreventingHandler.handleInvoiceAfterInsert:');
                    PostingPreventingHandler.handleInvoiceAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap);
                    PreventRecursiveLedgerEntry.InvoiceProcess = false;
                }
            }
            else{
                /* Deleting Invoice line items for to Invoiced quantity  on sales order Line item (Rollup summary) */
                
                if(Trigger.isdelete){
                    Map<String, Decimal> accountToUpdate = new Map<String, Decimal>();
                    //Deleting the invoice line Items
                    //Moin commented line 184 and added below code as we getting null pointer exception
                    if(ERP7__Invoice__c.sObjectType.getDescribe().isDeletable()){
                        List<ERP7__Invoice_Line_Item__c> invline= new List<ERP7__Invoice_Line_Item__c>();
                        invline = [Select Id,ERP7__Invoice__c From ERP7__Invoice_Line_Item__c Where ERP7__Invoice__c In : Trigger.oldMap.keyset() ];
                        if(invline != null && invline.size() > 0){ delete invline; }
                        //delete [Select Id,ERP7__Invoice__c From ERP7__Invoice_Line_Item__c Where ERP7__Invoice__c In : Trigger.oldMap.keyset() ]; else{ }
                    }
                    
                    //updating the account on deleting the invoice
                    //Commented below and Added below - Arshad 18 Oct 23
                    /*for(integer i = 0; i < Trigger.old.size(); i++){                        
                        if(Trigger.old[i].ERP7__Invoice_Amount__c > 0 ){          
                            system.debug('inhere 1');
                            if( accountToUpdate.get(Trigger.old[i].ERP7__Account__c) == Null )accountToUpdate.put( Trigger.old[i].ERP7__Account__c, Trigger.old[i].ERP7__Invoice_Amount__c );
                            else accountToUpdate.put(Trigger.old[i].ERP7__Account__c, Trigger.old[i].ERP7__Invoice_Amount__c );
                            //else accountToUpdate.put(Trigger.old[i].ERP7__Account__c, accountToUpdate.get( Trigger.old[i].ERP7__Account__c ) + Trigger.old[i].ERP7__Invoice_Amount__c );
                        }
                    }*/
                    if(Trigger.old != null){
                        if(Trigger.old.size() > 0){
                            for(integer i = 0; i < Trigger.old.size(); i++){                        
                                if(Trigger.old[i].ERP7__Account__c != null && Trigger.old[i].ERP7__Invoice_Amount__c != null && Trigger.old[i].ERP7__Invoice_Amount__c > 0){                         
                                    accountToUpdate.put( Trigger.old[i].ERP7__Account__c, Trigger.old[i].ERP7__Invoice_Amount__c);
                                }
                            }
                        }
                    }
                    
                    //Changed by Arshad 18 Oct 23
                    if(accountToUpdate != null){
                        if(accountToUpdate.keyset().size() > 0){ 
                            List<Account> acc = new List<Account>();
                            acc = [Select Id, ERP7__Total_Due__c from Account where Id IN: accountToUpdate.keyset() for update];
                            if(acc.size() > 0){
                                for(Account a : acc){
                                    if(accountToUpdate.containsKey(a.Id)){ 
                                        if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()) a.ERP7__Total_Due__c -=  accountToUpdate.get(a.Id);
                                    }
                                }
                            }
                            if(acc.size() > 0 && Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){ upsert acc; }else{/*Not allowed to upsert*/}
                        }
                    }
                    // End of updating the account on deleting the invoice
                    
                    // Deleting the transaction and payment of the invoice
                    if(Trigger.oldMap != null){
                        if(Trigger.oldMap.keyset().size() > 0){
                            List<ERP7__Transaction__c> invoiceTransactions = [Select Id from ERP7__Transaction__c where ERP7__Invoice__c In : Trigger.oldMap.keyset()];
                            List<ERP7__Payment__c> invoicePayments = [Select Id from ERP7__Payment__c where ERP7__Invoice__c IN : Trigger.oldMap.Keyset()];
                            if(invoiceTransactions.size() > 0 && ERP7__Transaction__c.sObjectType.getDescribe().isDeletable()) delete invoiceTransactions; else{ }
                            if(invoicePayments.size() > 0 && ERP7__Payment__c.sObjectType.getDescribe().isDeletable()) delete invoicePayments; else{ }
                        }
                    }
                }
            }
            
            //task
            if(PreventRecursiveLedgerEntry.InvoiceRollup && trigger.isAfter && trigger.isInsert){
                PreventRecursiveLedgerEntry.InvoiceRollup = false;
                Integer i=0;
                if(trigger.new[i].ERP7__Order__c != null){
                    ERP7__Sales_Order__c invoiceSO = [SELECT Id, Name, ERP7__Tasks__c FROM ERP7__Sales_Order__c WHERE Id =: trigger.new[i].ERP7__Order__c];
                    if(invoiceSO.ERP7__Tasks__c != null && trigger.isAfter){
                        if (trigger.isInsert || trigger.isDelete || trigger.isUndelete || trigger.isUpdate){
                            List<ERP7__Sales_Order__c> SOlist = [SELECT Id, Name, ERP7__Sub_Total__c, ERP7__TotalDiscount__c, ERP7__Total_Tax_Amount__c FROM ERP7__Sales_Order__c 
                                                                 WHERE ERP7__Tasks__c =: invoiceSO.ERP7__Tasks__c AND Id IN (SELECT ERP7__Order__c FROM ERP7__Invoice__c WHERE ERP7__Order__c != null)];
                            ERP7__Actions_Tasks__c task = [SELECT Id, ERP7__Sub_Total__c, ERP7__Total_Amount__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c, ERP7__Milestone__c FROM ERP7__Actions_Tasks__c WHERE Id =: invoiceSO.ERP7__Tasks__c];
                            
                            if(SOlist != null && task != null){
                                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isUpdateable()) task.ERP7__Sub_Total__c      = 0;
                                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isUpdateable()) task.ERP7__Total_Tax__c      = 0;
                                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isUpdateable()) task.ERP7__Total_Discount__c = 0;
                                for(ERP7__Sales_Order__c SO : SOlist) {
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isUpdateable()) task.ERP7__Total_Tax__c      += SO.ERP7__Total_Tax_Amount__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isUpdateable()) task.ERP7__Sub_Total__c      += SO.ERP7__Sub_Total__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isUpdateable()) task.ERP7__Total_Discount__c += SO.ERP7__TotalDiscount__c;
                                }
                                if(Schema.SObjectType.ERP7__Actions_Tasks__c.isCreateable() && Schema.SObjectType.ERP7__Actions_Tasks__c.isUpdateable()){upsert task;}else{/*Not allowed to upsert*/}
                            }
                        }
                    }
                }
            }
        }
        
        else if(InvWithOrd.size() > 0){ 
            if(Trigger.isInsert){
                Map<id, Decimal> TotalDueOfAccounts=new Map<id, Decimal>();
                for( Integer i=0;i<Trigger.New.size();i++){
                    
                    if(Trigger.New[i].ERP7__Total_Due__c>0 && Trigger.New[i].ERP7__Active__c==true && (Trigger.New[i].Record_Type_Name__c=='On_Account_Payment' || Trigger.New[i].Record_Type_Name__c=='Sale')){
                        Decimal existingDue=0;
                        if(TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c)!=null)existingDue=TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c); 
                        TotalDueOfAccounts.put(Trigger.New[i].ERP7__Account__c,existingDue+Trigger.New[i].ERP7__Total_Due__c); 
                    }
                    
                }
                List<Account> accs=[Select id,ERP7__Total_Due__c From Account where id In: TotalDueOfAccounts.keySet() for update];
                List<Account> updateAccs=new List<Account>();
                for(Account acc : accs){
                    if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()){
                        if(acc.ERP7__Total_Due__c==null)acc.ERP7__Total_Due__c=0;
                        acc.ERP7__Total_Due__c=acc.ERP7__Total_Due__c+TotalDueOfAccounts.get(acc.id);
                    }
                    updateAccs.add(acc);
                }
                if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){upsert updateAccs;}else{/*Not allowed upsert*/}
            }
            /* For updating the total due in customer account on payment made. */
            
            //Closing the invoice
            if(Trigger.isupdate){
                try{
                    Map<ID, ERP7__Invoice__c> InvoiceClosed = new Map<ID, ERP7__Invoice__c>();
                    for(ERP7__Invoice__c inv : Trigger.New){
                        if( inv.ERP7__Paid__c && inv.ERP7__Status__c == 'Paid' ){
                            ERP7__Invoice__c invc = new ERP7__Invoice__c();
                            invc = inv;
                            InvoiceClosed.put(inv.ERP7__Order_S__c, invc); 
                        }
                    } 
                    if( InvoiceClosed.size() > 0 ){
                        List<Order> SOrders = [ Select id,Status from Order where Id IN : InvoiceClosed.keyset() ];
                        for(Order SO : SOrders){
                            if( SO.Status != 'Delivered' )InvoiceClosed.remove(SO.ID);
                        }
                        if( InvoiceClosed.values().size() > 0){
                            List<ERP7__Invoice__c> allInvcs = InvoiceClosed.values();
                            list<String> finv = new list<String>();
                            for( integer i=0;i<allInvcs.size();i++ ){ 
                                finv.add(allInvcs[i].Id);                       
                            }
                            List<ERP7__Invoice__c> invcs = [Select id,ERP7__Status__c from ERP7__Invoice__c where id IN : finv ];
                            if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Status__c.isUpdateable()){ for(ERP7__Invoice__c  inv : invcs) inv.ERP7__Status__c = 'Closed'; }
                            if(invcs.size() > 0 && Schema.SObjectType.ERP7__Invoice__c.isCreateable() && Schema.SObjectType.ERP7__Invoice__c.isUpdateable()){upsert invcs;}else{/*Not allowed to upsert*/}
                        }
                    }
                }Catch(Exception e){ }
            }
            //End of the closing invoice
            
            if(Trigger.isupdate){
                Map<id, Decimal> TotalDueOfAccounts=new Map<id, Decimal>();
                for( Integer i=0;i<Trigger.New.size();i++){
                    if(Trigger.old[i].ERP7__Final_Due_Amount__c>0 && Trigger.New[i].ERP7__Active__c==true && (Trigger.New[i].Record_Type_Name__c=='On_Account_Payment' || Trigger.New[i].Record_Type_Name__c=='Sale')){
                        if(Trigger.New[i].ERP7__Final_Due_Amount__c != Trigger.old[i].ERP7__Final_Due_Amount__c   ){
                            Decimal existingDue=0;
                            if(TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c)!=null)existingDue=TotalDueOfAccounts.get(Trigger.New[i].ERP7__Account__c); 
                            TotalDueOfAccounts.put(Trigger.New[i].ERP7__Account__c,existingDue+Trigger.old[i].ERP7__Final_Due_Amount__c);
                        }
                    }
                }
                List<Account> accs=[Select id,ERP7__Total_Due__c,ERP7__Paid_Out__c From Account where id In: TotalDueOfAccounts.keySet() for update];
                List<Account> updateAccs=new List<Account>();
                for(Account acc : accs){
                    if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()){
                        if(acc.ERP7__Total_Due__c == null)acc.ERP7__Total_Due__c = 0;
                        acc.ERP7__Total_Due__c=acc.ERP7__Total_Due__c-TotalDueOfAccounts.get(acc.id);
                    }
                    if(Schema.sObjectType.Account.fields.ERP7__Paid_Out__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Paid_Out__c.isUpdateable()){
                        if(acc.ERP7__Paid_Out__c == null)acc.ERP7__Paid_Out__c = 0;
                        acc.ERP7__Paid_Out__c += TotalDueOfAccounts.get(acc.id);
                    }
                    updateAccs.add(acc);
                }
                if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){upsert updateAccs;}else{/*Not allowed to upsert*/}
            }
            
            if(Trigger.isupdate || (Trigger.isAfter && Trigger.isInsert)){
                //if(Trigger.isupdate){
                /*Creating Transaction for  Customer Invoice line Items when Invoice is Posted */
                Map<string, Module__c > RunModule = new Map<string, Module__c >();
                RunModule =  Module__c.getAll();
                if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c && PreventRecursiveLedgerEntry.InvoiceProcess)){//&& PreventRecursiveLedgerEntry.proceed  (Comment: PreventRecursiveLedgerEntry.proceed become true when update the Account)
                    List<Id> postedInvoiceIds = new List<Id>();
                    Map<Id, Id> InvoiceExisting_Transactions = new Map<Id, id>();
                    Id CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Customer_Invoice_Transaction'); 
                    List<Transaction__c> Transactions2update = new List<Transaction__c>();
                    for(Transaction__c eTransaction :[Select Id,Invoice__c, Organisation__c,  Product__c, ERP7__Amount__c, ERP7__Invoice_Line_Item__c   From Transaction__c Where Invoice__c In : Trigger.NewMap.keyset() And Payment__c = NULL AND RecordTypeId=:CIT ])
                        InvoiceExisting_Transactions.put(eTransaction.Invoice__c, eTransaction.id);
                    
                    List< ERP7__Invoice_Line_Item__c > lineItems = new List< ERP7__Invoice_Line_Item__c >();
                    for( Integer i=0;i<Trigger.New.size();i++){                    
                        if(Trigger.New[i].Posted__c && (Trigger.New[i].Record_Type_Name__c=='Sale' || Trigger.New[i].Record_Type_Name__c == 'Schedule_Invoice')){   // || Trigger.New[i].Record_Type_Name__c=='Advance' //Moin commented this  != Trigger.old[i].Posted__c  on 07th june 2023
                            Transaction__c trans = new Transaction__c(Id=(InvoiceExisting_Transactions.get(Trigger.New[i].Id)!=null)?InvoiceExisting_Transactions.get(Trigger.New[i].Id):null);
                            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = Trigger.New[i].Posted__c;
                            if(InvoiceExisting_Transactions.get(Trigger.New[i].Id) == null && Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = Trigger.New[i].ERP7__Invoice_Amount__c;
                            if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = Trigger.New[i].Organisation__c;
                            //trans.Organisation_Business_Unit__c = Trigger.New[i].Organisation_Business_Unit__c;
                            if(Schema.sObjectType.Transaction__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Order__c.isUpdateable()) trans.ERP7__Order__c = Trigger.New[i].ERP7__Order_S__c;
                            if(Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isUpdateable()) trans.ERP7__Customer__c = Trigger.New[i].ERP7__Account__c;
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = (Trigger.New[i].Posted_Date__c != null)? Trigger.New[i].Posted_Date__c:System.Today();
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Sales';
                            if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT;}
                            if(Schema.sObjectType.Transaction__c.fields.Invoice__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Invoice__c.isUpdateable()) trans.Invoice__c = Trigger.New[i].Id;
                            Transactions2update.add(trans);
                        }
                    }    
                    if(Transactions2update.size()>0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){upsert Transactions2update;PreventRecursiveLedgerEntry.InvoiceProcess = false;}else{/*Not allowed to upsert*/}
                    //Moin added this 24th August 2024
                    System.debug('PostingPreventingHandler.handleInvoiceAfterInsert:');
                    PostingPreventingHandler.handleInvoiceAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap);
                    PreventRecursiveLedgerEntry.InvoiceProcess = false;
                }
            }
            else{
                /* * Deleting Invoice line items for to Invoiced quantity  on sales order Line item (Rollup summary) */
                
                if(Trigger.isdelete){
                    Map<String, Decimal> accountToUpdate = new Map<String, Decimal>();
                    //Deleting the invoice line Items
                    if(ERP7__Invoice__c.sObjectType.getDescribe().isDeletable()) delete [Select Id,ERP7__Invoice__c From ERP7__Invoice_Line_Item__c Where ERP7__Invoice__c In : Trigger.oldMap.keyset() ]; else{ }
                    
                    //updating the account on deleting the invoice
                    if(Trigger.old != null){
                        if(Trigger.old.size() > 0){
                            for(integer i = 0; i < Trigger.old.size(); i++){                        
                                if(Trigger.old[i].ERP7__Account__c != null && Trigger.old[i].ERP7__Invoice_Amount__c != null && Trigger.old[i].ERP7__Invoice_Amount__c > 0){                         
                                    accountToUpdate.put(Trigger.old[i].ERP7__Account__c, Trigger.old[i].ERP7__Invoice_Amount__c);
                                }
                            }
                        }
                    }
                    
                    //Changed by Arshad 18 Oct 23
                    if(accountToUpdate != null){
                        if(accountToUpdate.keyset().size() > 0){ 
                            List<Account> acc = new List<Account>();
                            acc = [Select Id, ERP7__Total_Due__c from Account where Id IN: accountToUpdate.keyset() for update];
                            if(acc.size() > 0){
                                for(Account a : acc){
                                    if(accountToUpdate.containsKey(a.Id)){ 
                                        if(Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Total_Due__c.isUpdateable()) a.ERP7__Total_Due__c -=  accountToUpdate.get(a.Id);
                                    }
                                }
                            }
                            if(acc.size() > 0 && Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){ upsert acc; }else{/*Not allowed to upsert*/}
                        }
                    }
                    
                    // End of updating the account on deleting the invoice
                    
                    // Deleting the transaction and payment of the invoice
                    if(Trigger.oldMap != null){
                        if(Trigger.oldMap.keyset().size() > 0){
                            List<ERP7__Transaction__c> invoiceTransactions = [Select Id from ERP7__Transaction__c where ERP7__Invoice__c In : Trigger.oldMap.keyset()];
                            List<ERP7__Payment__c> invoicePayments = [Select Id from ERP7__Payment__c where ERP7__Invoice__c IN : Trigger.oldMap.Keyset()];
                            if( invoiceTransactions.size() > 0 && ERP7__Transaction__c.sObjectType.getDescribe().isDeletable()) delete invoiceTransactions; else{ }
                            if( invoicePayments.size() > 0 && ERP7__Payment__c.sObjectType.getDescribe().isDeletable()) delete invoicePayments; else{ }
                        }
                    }
                    
                }
            }
            
            //task
            if(PreventRecursiveLedgerEntry.InvoiceRollup && trigger.isAfter && trigger.isInsert){
                PreventRecursiveLedgerEntry.InvoiceRollup = false;
                Integer i=0;
                if(trigger.new[i].ERP7__Order_S__c != null){
                    Order invoiceSO = [SELECT Id, Name, ERP7__Tasks__c FROM Order WHERE Id =: trigger.new[i].ERP7__Order_S__c];
                    if(invoiceSO.ERP7__Tasks__c != null && trigger.isAfter){
                        if (trigger.isInsert || trigger.isDelete || trigger.isUndelete || trigger.isUpdate){
                            List<Order> SOlist = [SELECT Id, Name, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Tax_Amount__c FROM Order 
                                                  WHERE ERP7__Tasks__c =: invoiceSO.ERP7__Tasks__c AND Id IN (SELECT ERP7__Order_S__c FROM ERP7__Invoice__c WHERE ERP7__Order_S__c != null)];
                            ERP7__Actions_Tasks__c task = [SELECT Id, ERP7__Sub_Total__c, ERP7__Total_Amount__c, ERP7__Total_Discount__c, ERP7__Total_Tax__c, ERP7__Milestone__c FROM ERP7__Actions_Tasks__c WHERE Id =: invoiceSO.ERP7__Tasks__c];
                            
                            if(SOlist != null && task != null){
                                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isUpdateable()) task.ERP7__Sub_Total__c      = 0;
                                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isUpdateable()) task.ERP7__Total_Tax__c      = 0;
                                if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isUpdateable()) task.ERP7__Total_Discount__c = 0;
                                for(Order SO : SOlist) {
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Tax__c.isUpdateable()) task.ERP7__Total_Tax__c      += SO.ERP7__Total_Tax_Amount__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Sub_Total__c.isUpdateable()) task.ERP7__Sub_Total__c      += SO.ERP7__Sub_Total__c;
                                    if(Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Actions_Tasks__c.fields.ERP7__Total_Discount__c.isUpdateable()) task.ERP7__Total_Discount__c += SO.ERP7__Total_Discount__c;
                                }
                                if(Schema.SObjectType.ERP7__Actions_Tasks__c.isCreateable() && Schema.SObjectType.ERP7__Actions_Tasks__c.isUpdateable()){upsert task;}else{/*Not allowed to upsert*/}
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    catch(Exception ex){ 
        System.debug('trigger Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString());
        String exceptionError = ex.getMessage();
        exceptionError += ' Line No: ' + ex.getLineNumber(); 
        exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();  
        if(!Test.isRunningTest()) throw new ErrorException(ex.getMessage());
    }  
    
}