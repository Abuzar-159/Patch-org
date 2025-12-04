trigger Credit_Note_Trigger on Credit_Note__c (after insert, after update, before delete, after delete, after undelete, before insert, before update) {
    system.debug('PreventRecursiveLedgerEntry.testCasesTransactions-->'+PreventRecursiveLedgerEntry.testCasesTransactions);
    if (!PreventRecursiveLedgerEntry.testCasesTransactions) {
        Set<Id> RMAIds = new Set<Id>();
        Map<Id, ERP7__Return_Merchandise_Authorisation__c> RMAMap = new Map<Id, ERP7__Return_Merchandise_Authorisation__c>();
        if(Trigger.isBefore && !Trigger.isDelete){
            for(Credit_Note__c cred : Trigger.new){
                if(cred.ERP7__Return_Merchandise_Authorisation__c!=null){
                    RMAIds.add(cred.ERP7__Return_Merchandise_Authorisation__c);
                }
            }
            if(RMAIds.size()>0){
                RMAMap = new Map<Id, ERP7__Return_Merchandise_Authorisation__c>([select Id, ERP7__Refund_Amount__c, ERP7__Total_Refund_Amount__c, ERP7__Total_Tax__c, ERP7__Restock_Fee__c, ERP7__ReStock_Tax__c, ERP7__Shipping_Tax__c, ERP7__Shipping_Amount__c, ERP7__Invoice__c, ERP7__SO__c, ERP7__Organisation__c from ERP7__Return_Merchandise_Authorisation__c where Id IN :RMAIds]);
            }
            for(Credit_Note__c cred : Trigger.new){
                /*if(RMAMap.containskey(cred.ERP7__Return_Merchandise_Authorisation__c)){
                    ERP7__Return_Merchandise_Authorisation__c rma = RMAMap.get(cred.ERP7__Return_Merchandise_Authorisation__c);
                    if(rma.ERP7__Restock_Fee__c!=null) cred.ERP7__Fees__c = rma.ERP7__Restock_Fee__c;
                    if(rma.ERP7__Total_Tax__c!=null) cred.ERP7__Tax_Amount__c = rma.ERP7__Total_Tax__c;
                    if(rma.ERP7__Invoice__c != null) cred.ERP7__Invoice__c = rma.ERP7__Invoice__c;
                    if(rma.ERP7__SO__c!=null) cred.ERP7__Sales_Order__c = rma.ERP7__SO__c;
                    if(rma.ERP7__ReStock_Tax__c != null){
                        if(cred.ERP7__Tax_Amount__c!=null) cred.ERP7__Tax_Amount__c = cred.ERP7__Tax_Amount__c + rma.ERP7__ReStock_Tax__c;
                        else cred.ERP7__Tax_Amount__c = 0 - rma.ERP7__ReStock_Tax__c;
                    }  
                    if(rma.ERP7__Shipping_Tax__c!=null){
                        if(cred.ERP7__Tax_Amount__c!=null) cred.ERP7__Tax_Amount__c = cred.ERP7__Tax_Amount__c + rma.ERP7__Shipping_Tax__c;
                        else cred.ERP7__Tax_Amount__c = rma.ERP7__Shipping_Tax__c;
                    }
                    if(rma.ERP7__Refund_Amount__c!=null) cred.ERP7__Amount__c = rma.ERP7__Refund_Amount__c - rma.ERP7__Total_Tax__c;
                    if(rma.ERP7__Shipping_Amount__c!=null) cred.ERP7__Amount__c = cred.ERP7__Amount__c + rma.ERP7__Shipping_Amount__c;
                    if(rma.ERP7__Restock_Fee__c!=null) cred.ERP7__Amount__c = cred.ERP7__Amount__c + rma.ERP7__Restock_Fee__c;
                    if(rma.ERP7__Total_Refund_Amount__c!=null){
                        cred.ERP7__Credit__c = rma.ERP7__Total_Refund_Amount__c;
                    }
                    if(rma.ERP7__Organisation__c != null) cred.ERP7__Organisation__c = rma.ERP7__Organisation__c;
                        //cred.ERP7__Credit__c = cred.ERP7__Amount__c - rma.ERP7__Restock_Fee__c + cred.ERP7__Tax_Amount__c ;
                        //cred.ERP7__Amount__c = cred.ERP7__Amount__c - rma.ERP7__Restock_Fee__c;
                    /*}else{
                        cred.ERP7__Credit__c = cred.ERP7__Amount__c + cred.ERP7__Tax_Amount__c;      
                    }*/
                    /*if(rma.ERP7__Shipping_Amount__c!=null){
                        cred.ERP7__Credit__c = cred.ERP7__Credit__c + rma.ERP7__Shipping_Amount__c ;
                    }*
                }*/
            }
        }
        if(Trigger.isAfter){
            List<Transaction__c> Transactions2update = new List<Transaction__c>();
            if(!Trigger.isDelete){
                Id SalesReturn = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Transaction__c','Merchandise_Return'); 
                Map<Id,Transaction__c> ExistingTransaction = new Map<Id,Transaction__c>();
                for(Transaction__c trans: [Select Id, ERP7__Credit_Note__c FROM Transaction__c WHERE ERP7__Credit_Note__c IN: Trigger.newMap.keyset()])  ExistingTransaction.put(trans.ERP7__Credit_Note__c,trans);
                Map<string, Module__c > RunModule = new Map<string, Module__c >();
                RunModule =  Module__c.getAll();  
                if(RunModule.size() > 0 && RunModule.get('Finance').ERP7__Run__c && PreventRecursiveLedgerEntry.proceed){  
                    
                    for(ERP7__Credit_Note__c cNote : Trigger.New){
                        system.debug('Posted -->'+cNote.Posted__c);
                        if(cNote.Posted__c){
                            //Moin Commented line 64
                            Transaction__c trans = ExistingTransaction.containsKey(cNote.Id)?ExistingTransaction.get(cNote.Id):new Transaction__c();//Id=(ExistingTransaction.get(cNote.Id)!= null)?ExistingTransaction.get(cNote.Id):null
                            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){trans.Active__c = true; }else{/*No access*/} 
                            //if(cNote.ERP7__Invoice__c!=null && Schema.sObjectType.Transaction__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Invoice__c.isUpdateable()){ trans.ERP7__Invoice__c = cNote.ERP7__Invoice__c;}else{/*No access*/} 
                            if(Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Customer__c.isUpdateable()){trans.ERP7__Customer__c = cNote.Account__c; }else{/*No access*/}if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = cNote.ERP7__Balance__c!=null?cNote.ERP7__Balance__c:0+cNote.Tax_Amount__c!=null?cNote.Tax_Amount__c:0;}else{/*No access*/}
                            if(Schema.sObjectType.Transaction__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Credit_Note__c.isUpdateable()){trans.ERP7__Credit_Note__c = cNote.Id;  }else{/*No access*/} if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = System.Today();  }else{/*No access*/} if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed';}else{/*No access*/}
                            //if(cNote.ERP7__Return_Merchandise_Authorisation__c != null){
                            //trans.ERP7__Return_Merchandise_Authorisation_RMA__c = cNote.ERP7__Return_Merchandise_Authorisation__c;
                            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){
                                if(cNote.ERP7__Return_Merchandise_Authorisation__c!=null) {
                                    trans.Transaction_Type__c = 'CreditsReturn';
                                }   else if(cNote.ERP7__Invoice__c!=null) {
                                    trans.Transaction_Type__c = 'CreditsReturn';
                                } else{
                                    trans.Transaction_Type__c = 'CustomerReturn';
                                }
                            }else{/*No access*/}
                            if(SalesReturn != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = SalesReturn;}else{/*No access*/}  Transactions2update.add(trans);   
                        }
                    } 
                    
                }
                if(Transactions2update.size() > 0 && Schema.SObjectType.Transaction__c.isCreateable() && Schema.SObjectType.Transaction__c.isUpdateable()){
                    upsert Transactions2update;
                    PostingPreventingHandler.handleCreditNoteAfterInsert(Trigger.new, Trigger.newMap, Trigger.OldMap); 
                    PreventRecursiveLedgerEntry.proceed = false;
                }else{/*Not allowed to upsert*/
                
                    Set<Id> AccIds = new Set<Id>();
                    List<Account> accounts2update = new List<Account>();
                    Map<Id, Account> accMap = new Map<Id, Account>();
                    for(ERP7__Credit_Note__c cc : Trigger.new){
                        if(cc.ERP7__Account__c != null) AccIds.add(cc.ERP7__Account__c);
                    }
                    if(AccIds.size()>0){
                        List<Account> accList = [select Id, Name, ERP7__Credit_Note_Credit_Balance__c, ERP7__Credit_Balance__c from Account where Id IN :AccIds];
                        List<ERP7__Credit_Note__c> cnoteList = new List<ERP7__Credit_Note__c>();
                        cnoteList = [select Id, Name, ERP7__Account__c, ERP7__Credit__c from ERP7__Credit_Note__c where ERP7__Account__c IN :AccIds];
                        if(cnoteList.size()>0){
                            Map<Id, List<ERP7__Credit_Note__c>> appCredList = new Map<Id, List<ERP7__Credit_Note__c>>();
                            for(ERP7__Credit_Note__c cr : cnoteList){
                                if(appCredList.containskey(cr.ERP7__Account__c)){
                                    appCredList.get(cr.ERP7__Account__c).add(cr);
                                }else{
                                    List<ERP7__Credit_Note__c> cred = new List<ERP7__Credit_Note__c>();
                                    cred.add(cr);
                                    appCredList.put(cr.ERP7__Account__c, cred);
                                }
                            }
                            
                            for(Account acc : accList){
                                Decimal accCrdit = 0;
                                if(appCredList.containskey(acc.Id)){
                                    for(ERP7__Credit_Note__c cr : appCredList.get(acc.Id)){
                                        if(cr.ERP7__Credit__c!=null){
                                            accCrdit = accCrdit + cr.ERP7__Credit__c;
                                        }
                                    }
                                    acc.ERP7__Credit_Balance__c = 0;
                                    acc.ERP7__Credit_Balance__c = accCrdit;
                                    accounts2update.add(acc);
                                }
                            }
                        }
                        if(accounts2update.size()>0 && Schema.SObjectType.Account.isUpdateable()){update accounts2update;}else{/*No access*/}
                    }
                }
            } 
            if (Trigger.isAfter && Trigger.isDelete) {
                system.debug('Going Inside handle deleting cred notes'); 
                List<Id> deletedCreditNoteInvs = new List<Id>();
                for (ERP7__Credit_Note__c cn : Trigger.old) {
                    if (cn.ERP7__Invoice__c != null) deletedCreditNoteInvs.add(cn.ERP7__Invoice__c);
                }
                
                if (deletedCreditNoteInvs.size() > 0) {
                    system.debug('Inside handle deleting cred notes');
                    CreateDebitNote.handleAfterDelete(deletedCreditNoteInvs);
                }
            }
            if (Trigger.isAfter && Trigger.isundelete) {
                system.debug('Going Inside handle deleting cred notes'); 
                List<Id> deletedCreditNoteInvs = new List<Id>();
                for (ERP7__Credit_Note__c cn : Trigger.New) {
                    if (cn.ERP7__Invoice__c != null) deletedCreditNoteInvs.add(cn.ERP7__Invoice__c);
                }
                
                if (deletedCreditNoteInvs.size() > 0) {
                    system.debug('Inside handle deleting cred notes');
                    CreateDebitNote.handleAfterDelete(deletedCreditNoteInvs);
                }
            }
            
        } else {
            
            if(Trigger.isDelete){
                list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
                    new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Credit__c', 'ERP7__Credit_Note_Credit_Balance__c')
                        };
                            RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.old, 'ERP7__Credit_Note__c','ERP7__Account__c', 'Account', ' And ERP7__Active__c = true');
                
                list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions2 = new list<RollUpSummaryUtility.fieldDefinition> {
                    new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Debit__c', 'ERP7__Credit_Note_Debit_Balance__c')
                        };
                            RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions2, trigger.old, 'ERP7__Credit_Note__c','ERP7__Account__c', 'Account', ' And ERP7__Active__c = true');
            } 
        }
    }
}