trigger RMATrigger on Return_Merchandise_Authorisation__c (after insert, after update,before delete) {
    if(!PreventRecursiveLedgerEntry.testCasesTransactions){ 
        SalesOrderTrigger.ManageRMALogistics(Trigger.IsInsert,Trigger.IsUpdate, JSON.serialize(Trigger.New), JSON.serialize(Trigger.Old));
    }
    /*Issuing Credit Note of Authorize and Closed RMA*/
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        List<Transaction__c> Transactions2update = new List<Transaction__c>();
        List<ERP7__Credit_Note__c> CreditNote2Upsert = new List<ERP7__Credit_Note__c>();
        Map<Id,Id> RMA_CreditNoteMap = new Map<Id,Id>();
        Set<Id> RMAIds = new Set<Id>();
        Set<Id> soIds = new Set<Id>();
        Map<Id,List<Payment__c>> soMap2PaymentList = new Map<Id,List<Payment__c>>();
        Id SalesReturn = Schema.SObjectType.ERP7__Transaction__c.getRecordTypeInfosByDeveloperName().get('Merchandise_Return').getRecordTypeId(); 
        Map<Id,Id> ExistingTransaction = new Map<Id,Id>();
        for(Transaction__c trans: [Select Id, ERP7__Return_Merchandise_Authorisation_RMA__c FROM Transaction__c WHERE ERP7__Return_Merchandise_Authorisation_RMA__c IN: Trigger.newMap.keyset()])
            ExistingTransaction.put(trans.ERP7__Return_Merchandise_Authorisation_RMA__c,trans.Id);
        Map<string, Module__c > RunModule = new Map<string, Module__c >();
        RunModule =  Module__c.getAll();  
        if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run__c && PreventRecursiveLedgerEntry.proceed){
            PreventRecursiveLedgerEntry.proceed = false;
            
            for(Return_Merchandise_Authorisation__c rma : Trigger.newMap.values()){
                if(rma.ERP7__Authorize__c && rma.ERP7__Is_Closed__c){
                    RMAIds.add(rma.id);//Storing only Authorize and closed RMA Ids.
                    if(rma.ERP7__SO__c != null && rma.ERP7__AmountPaid__c  > 0.00)
                        soIds.add(rma.ERP7__SO__c);
                } 
            }
            if(soIds.size()>0){
                List<ERP7__Payment__c> PaymentList = [SELECT Id,Amount__c, ERP7__Payment_Account__c, ERP7__Invoice__c, ERP7__Sales_Order__c    FROM ERP7__Payment__c WHERE ERP7__Sales_Order__c IN: soIds];
                for(Payment__c payment : PaymentList){
                List<ERP7__Payment__c> tempPaymentList =(soMap2PaymentList.get(payment.ERP7__Sales_Order__c) != null)? soMap2PaymentList.get(payment.ERP7__Sales_Order__c): new List<ERP7__Payment__c>();
                tempPaymentList.add(payment);
                soMap2PaymentList.put(payment.ERP7__Sales_Order__c,tempPaymentList); 
                }
            }
            if(RMAIds.size()>0 && RMA_CreditNoteMap.size()==0){
                for(ERP7__Credit_Note__c creditNote : [SELECT Id,Name,ERP7__Return_Merchandise_Authorisation__c FROM ERP7__Credit_Note__c WHERE ERP7__Return_Merchandise_Authorisation__c In : RMAIds])
                    RMA_CreditNoteMap.put(creditNote.ERP7__Return_Merchandise_Authorisation__c,creditNote.Id);
            }
            for(Return_Merchandise_Authorisation__c rma : Trigger.newMap.values()){
                if(rma.ERP7__Authorize__c && rma.ERP7__Is_Closed__c && rma.ERP7__AmountPaid__c  > 0.00){
                    ERP7__Credit_Note__c cn = new ERP7__Credit_Note__c();
                        if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.isUpdateable()){cn.Id = RMA_CreditNoteMap.get(rma.Id); } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Return_Merchandise_Authorisation__c.isUpdateable()){cn.ERP7__Return_Merchandise_Authorisation__c = rma.id; } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isUpdateable()){cn.ERP7__Account__c = rma.ERP7__Account__c;  } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Credit__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Credit__c.isUpdateable()){cn.ERP7__Credit__c = rma.ERP7__AmountPaid__c; } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.Name.isUpdateable()){cn.Name = rma.Name; } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Tax_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Tax_Amount__c.isUpdateable()){cn.ERP7__Tax_Amount__c = rma.ERP7__Tax__c; } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Discount_Amount__c.isUpdateable()){cn.ERP7__Discount_Amount__c = rma.ERP7__Discount__c; } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Contact__c.isUpdateable()){cn.ERP7__Contact__c = rma.ERP7__Return_Contact__c; } else{ /* nO ACCESS*/}
                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Description__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Description__c.isUpdateable()){cn.ERP7__Description__c = 'Refund Process for RMA'+rma.Name; } else{ /* nO ACCESS*/}
                    if(rma.ERP7__SO__c != null){
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Sales_Order__c.isUpdateable()){cn.ERP7__Sales_Order__c = rma.ERP7__SO__c; } else{ /* nO ACCESS*/}
                        if(soMap2PaymentList.size()>0)
                            if(Schema.sObjectType.ERP7__Credit_Note__c.fields.Payment__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.fields.Payment__c.isUpdateable()){ cn.Payment__c = (soMap2PaymentList.get(rma.ERP7__SO__c) != null)? soMap2PaymentList.get(rma.ERP7__SO__c)[0].Id:null; } else{/* no access*/}
                    }
                    CreditNote2Upsert.add(cn);
                }
                    
            }//
            if(CreditNote2Upsert.size()>0){
                if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note__c.isUpdateable()) { upsert CreditNote2Upsert; } else{ /* no access */ }
                for(ERP7__Credit_Note__c creditNote : CreditNote2Upsert)
                    RMA_CreditNoteMap.put(creditNote.ERP7__Return_Merchandise_Authorisation__c,creditNote.Id);
            }
            for(Return_Merchandise_Authorisation__c rma : Trigger.newMap.values()){
                if(rma.ERP7__Authorize__c && rma.ERP7__Is_Closed__c && rma.ERP7__Refund_Amount__c >0.00){
                    Transaction__c trans = new Transaction__c(Id=(ExistingTransaction.get(rma.Id)!= null)?ExistingTransaction.get(rma.Id):null);
                    if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){trans.Active__c = true;} else{/* no access*/}
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isUpdateable()){trans.ERP7__Customer__c = rma.Account__c;} else{/* no access*/}
                    if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = rma.ERP7__Refund_Amount__c;} else{/* no access*/}
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Credit_Note__c.isUpdateable()){trans.ERP7__Credit_Note__c = RMA_CreditNoteMap.get(rma.Id);} else{/* no access*/}
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = System.Today();} else{/* no access*/}
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed';} else{/* no access*/}
                    if(Schema.sObjectType.Transaction__c.fields.ERP7__Return_Merchandise_Authorisation_RMA__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Return_Merchandise_Authorisation_RMA__c.isUpdateable()){trans.ERP7__Return_Merchandise_Authorisation_RMA__c = rma.Id;} else{/* no access*/}
                    if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'SalesReturn';} else{/* no access*/}
                    if(SalesReturn != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){trans.RecordTypeId = SalesReturn;} else{/* no access*/}
                    Transactions2update.add(trans);
                }
                
            }
        
            if(Transactions2update.size() > 0 && Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()) { upsert Transactions2update; } else{ /* no access */ }
        }        
    }else{
            
        Set<Id> soIds = new Set<Id>();
            if(Trigger.IsDelete) {
                for(Return_Merchandise_Authorisation__c rma : Trigger.old){
                    if(rma.ERP7__SO__c!= Null) soIds.add(rma.ERP7__SO__c);
                }
            }
         List<Sales_Order_Line_Item__c> solis = [Select Id, Name, ERP7__ReturnAmount__c, ERP7__ReturnedQuantity__c, ERP7__RMALines_to_Process__c from Sales_Order_Line_Item__c where ERP7__Sales_Order__c In : soIds];
        for(Sales_Order_Line_Item__c soli : solis){
            if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnedQuantity__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnedQuantity__c.isUpdateable()){soli.ERP7__ReturnedQuantity__c =0.00;} else{/* no access*/}
            if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnAmount__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__ReturnAmount__c.isUpdateable()){soli.ERP7__ReturnAmount__c = 0.0;} else{/* no access*/}
            if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__RMALines_to_Process__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__RMALines_to_Process__c.isUpdateable()){soli.ERP7__RMALines_to_Process__c = 0;} else{/* no access*/}
        }
        if(Schema.sObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.isUpdateable()){ upsert solis; } else{ /* no access */ }
    }
    
}