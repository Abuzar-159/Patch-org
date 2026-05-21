trigger ManageExpenseTransactions on Expense__c (after insert, after update) {

    List<Id> ExpIds = new List<Id>();
    
    Map<Id, Transaction__c> creditTransaction_AccPay = new Map<Id, Transaction__c>();
    Map<Id, Transaction__c> debitTransaction_Expense = new Map<Id, Transaction__c>();
    
    Map<Id, Transaction__c> debitTransaction_AccPay = new Map<Id, Transaction__c>();
    
    Map<Id, Transaction__c> creditTransaction_VatPay = new Map<Id, Transaction__c>();
    Map<Id, Transaction__c> creditTransaction_Expense = new Map<Id, Transaction__c>();
    
    
    for(Expense__c Exp : System.Trigger.New){
        ExpIds.add(Exp.Id);
    }
    
    if(!PreventRecursiveLedgerEntry.testCasesTransactions){
    
        Id CIT; CIT = Schema.SObjectType.ERP7__Transaction__c.getRecordTypeInfosByDeveloperName().get('Expense_Transaction').getRecordTypeId();
        
        List<Transaction__c> existingDebitTransactions_AccPay = [Select Id, Name, Active__c, Amount__c, Employee_Pay__c, 
                                                                                Expense__c, Finance_Category_Type__c, Invoice__c, 
                                                                                Organisation__c, Organisation_Business_Unit__c, Payment__c, 
                                                                                Sales_Order__c,  Transaction_Date__c, 
                                                                                Transaction_Method__c, Transaction_Status__c, Transaction_Type__c 
                                                                                From Transaction__c
                                                                                Where Expense__c In : ExpIds]; 
        
         
        for(Transaction__c debitTrans : existingDebitTransactions_AccPay){     debitTransaction_AccPay.put(debitTrans.Expense__c, debitTrans);
        }
        
        List<Transaction__c> Transactions2update = new List<Transaction__c>();
        List<ERP7__Expense_Line_Item__c> expLineItems = new List<ERP7__Expense_Line_Item__c>();
        expLineItems = [select Id, Name, ERP7__Expense_Type__c, ERP7__Expense__c, ERP7__Bill__c, ERP7__Refund__c, ERP7__VAT_Amount__c, ERP7__Expensed_Submitted__c, ERP7__Expense_Line_Item__c from ERP7__Expense_Line_Item__c where ERP7__Expense__c IN :Trigger.NewMap.KeySet()];
        Map<Id,List<ERP7__Expense_Line_Item__c>> lineItemsMap = new Map<Id,List<ERP7__Expense_Line_Item__c>>();
        for(ERP7__Expense_Line_Item__c eline : expLineItems){
            if(lineItemsMap.containsKey(eline.ERP7__Expense__c)){
                lineItemsMap.get(eline.ERP7__Expense__c).add(eline);
            }else{
                List<ERP7__Expense_Line_Item__c> ExpLineItemList = new List<ERP7__Expense_Line_Item__c>();
                ExpLineItemList.add(eline);
                lineItemsMap.put(eline.ERP7__Expense__c,ExpLineItemList);
            }
        }
        for(Expense__c Exp : System.Trigger.New){
            if (Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Approver__c.isAccessible()){
                if(Exp.Active__c  && Exp.Status__c == 'Approved' && Exp.Paid__c == true && !(debitTransaction_AccPay.containsKey(Exp.Id))){
                    for(ERP7__Expense_Line_Item__c expline : lineItemsMap.get(Exp.Id)){
                        Transaction__c trans = new Transaction__c();
                        if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                        if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = expline.ERP7__VAT_Amount__c + expline.ERP7__Expensed_Submitted__c;
                        if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Debit';
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Expenses';
                        if(Schema.sObjectType.Transaction__c.fields.Expense__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Expense__c.isUpdateable()) trans.Expense__c = Exp.Id;
                        if(Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isUpdateable()) trans.ERP7__Expense_Line_Item__c = expline.Id;
                        if(CIT != null){ if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = CIT; } Transactions2update.add(trans);
                    }
                }
            }else{
                if(Exp.Active__c  && Exp.Paid__c == true && !(debitTransaction_AccPay.containsKey(Exp.Id))){
                    for(ERP7__Expense_Line_Item__c expline : lineItemsMap.get(Exp.Id)){
                        if(expline.ERP7__Expense_Type__c == 'Refund Payment'){ //removed || expline.ERP7__Expense_Type__c == 'Interim payment' imran 26th July 23
                            Transaction__c trans = new Transaction__c();
                            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                            if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = expline.ERP7__VAT_Amount__c + expline.ERP7__Expensed_Submitted__c;
                            if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Debit';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Refund';
                            if(Schema.sObjectType.Transaction__c.fields.Expense__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Expense__c.isUpdateable()) trans.Expense__c = Exp.Id;
                            if(Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isUpdateable()) trans.ERP7__Expense_Line_Item__c = expline.Id;
                            if(CIT != null){ if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = CIT; } Transactions2update.add(trans);
                        }
                        else if(expline.ERP7__Expense_Type__c == 'Interim payment'){//added imran 26th July 23
                            Transaction__c trans = new Transaction__c();
                            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                            if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = expline.ERP7__Expensed_Submitted__c;
                            if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Credit';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Interim Payment';
                            if(Schema.sObjectType.Transaction__c.fields.Expense__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Expense__c.isUpdateable()) trans.Expense__c = Exp.Id;
                            if(Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isUpdateable()) trans.ERP7__Expense_Line_Item__c = expline.Id;
                            if(CIT != null){ if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = CIT; } Transactions2update.add(trans);
                        }
                        else if(expline.ERP7__Expense_Type__c != 'Bill Payment' && expline.ERP7__Expense_Line_Item__c == null) {
                            Transaction__c trans = new Transaction__c();
                            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                            if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable() && expline.ERP7__VAT_Amount__c != null) trans.Amount__c = expline.ERP7__VAT_Amount__c + expline.ERP7__Expensed_Submitted__c;
                            else trans.Amount__c = expline.ERP7__Expensed_Submitted__c;
                            if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Debit';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Expenses';
                            if(Schema.sObjectType.Transaction__c.fields.Expense__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Expense__c.isUpdateable()) trans.Expense__c = Exp.Id;
                            if(Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Expense_Line_Item__c.isUpdateable()) trans.ERP7__Expense_Line_Item__c = expline.Id;
                            if(CIT != null){ if(Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()) trans.RecordTypeId = CIT; } Transactions2update.add(trans);
                        }
                    }
                 }
            } 
        }
        if(Transactions2update.size()>0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){
            upsert Transactions2update;
            PostingPreventingHandler.handleExpenseAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap);
        }else{/*Not allowed to upsert*/}
        
        
    }
}