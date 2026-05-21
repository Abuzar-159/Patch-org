trigger InvoiceLineItemTrigger on Invoice_Line_Item__c (before delete, before update, after insert, after update, after delete, after undelete) {

   /* if(Trigger.isBefore && Trigger.isDelete){
        List<Id> invoiceIds = new List<Id>();
        for(Invoice_Line_Item__c lineItem : Trigger.old){
            invoiceIds.add(lineItem.ERP7__Invoice__c);
        }
        if(invoiceIds.size()>0){
            Map<Id, ERP7__Invoice__c> invoiceMap = new Map<Id, ERP7__Invoice__c>([SELECT Id, ERP7__Posted__c FROM ERP7__Invoice__c WHERE Id IN :invoiceIds]);
            for(Invoice_Line_Item__c lineItem : Trigger.old){
                if(invoiceMap.get(lineItem.ERP7__Invoice__c)!=null && invoiceMap.get(lineItem.ERP7__Invoice__c).ERP7__Posted__c == true){
                    lineItem.addError('You cannot delete line items from a posted invoice.');
                }
            }
        }
    }*/
    //the below if block to have validations when changes are made to line item and invoice is posted
    if (Trigger.isBefore && Trigger.isUpdate) {
        Set<Id> invoiceIds = new Set<Id>();
        for (ERP7__Invoice_Line_Item__c lineItem : Trigger.new) {
            invoiceIds.add(lineItem.ERP7__Invoice__c);
        }
        
        Map<Id, ERP7__Invoice__c> invoices = new Map<Id, ERP7__Invoice__c>(
            [SELECT Id, ERP7__Posted__c FROM ERP7__Invoice__c WHERE Id IN :invoiceIds]
        );
        
        for (ERP7__Invoice_Line_Item__c newLineItem : Trigger.new) {
            ERP7__Invoice_Line_Item__c oldLineItem = Trigger.oldMap.get(newLineItem.Id);
            if(newLineItem.ERP7__Invoice__c!=null){
                ERP7__Invoice__c parentInvoice = invoices.get(newLineItem.ERP7__Invoice__c);
                if (parentInvoice != null && parentInvoice.ERP7__Posted__c == true) {
                    
                    if (newLineItem.ERP7__Quantity__c != oldLineItem.ERP7__Quantity__c ||
                        newLineItem.ERP7__Unit_Price__c != oldLineItem.ERP7__Unit_Price__c ||
                        newLineItem.ERP7__Base_Price__c != oldLineItem.ERP7__Base_Price__c ||
                        newLineItem.ERP7__Total_Price__c != oldLineItem.ERP7__Total_Price__c ||
                        newLineItem.ERP7__Sub_Total__c != oldLineItem.ERP7__Sub_Total__c ||
                        newLineItem.ERP7__Tax_Rate__c != oldLineItem.ERP7__Tax_Rate__c) {
                          //  newLineItem.addError('Changes cannot be made to a line item of a posted invoice.');
                        }
                } 
            }
        }
    }else if (Trigger.isAfter) {
    
    try{
        Set<Id> ILIIdsWithOP=new Set<Id>(); Set<Id> ILIIdsWithSOLI=new Set<Id>();
        
        if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete){
            for(Invoice_Line_Item__c inv: Trigger.New){   
                if(inv.ERP7__Sales_Order_Line_Item__c != null){ 
                    ILIIdsWithSOLI.add(inv.ERP7__Sales_Order_Line_Item__c);
                }else if(inv.ERP7__Order_Product__c != null){ 
                    ILIIdsWithOP.add(inv.ERP7__Order_Product__c);
                }
            }
        }
        if (Trigger.isDelete){ 
            for(Invoice_Line_Item__c inv: Trigger.old){        
                if(inv.ERP7__Sales_Order_Line_Item__c != null){ 
                    ILIIdsWithSOLI.add(inv.ERP7__Sales_Order_Line_Item__c);
                }else if(inv.ERP7__Order_Product__c != null){ 
                    ILIIdsWithOP.add(inv.ERP7__Order_Product__c);
                }
            }
        }
        
        if(ILIIdsWithSOLI.size() > 0){
            
            Set<Id> SOLISId = new Set<Id>(); List < Invoice_Line_Item__c > InvoiceItemtrigger = new List < Invoice_Line_Item__c > (); List < Invoice_Line_Item__c > InvoiceItemOldtrigger = new List < Invoice_Line_Item__c > ();
            
            if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) { InvoiceItemtrigger = Trigger.new; InvoiceItemOldtrigger = Trigger.old;
                                                                             
                                                                            }
            if (Trigger.isDelete){ InvoiceItemtrigger = Trigger.old;}
            if(PreventRecursiveLedgerEntry.InvoiceLinesProcess){  
                if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {
                    Map<string, Module__c > RunModule = new Map<string, Module__c >();
                    List<Transaction__c> Transactions2update = new List<Transaction__c>();
                    List<ERP7__Sales_Order_Line_Item__c> SolisToUpdate=new List<ERP7__Sales_Order_Line_Item__c>();
                    set<Id> soliIds=new set<Id>();
                    set<Id> soIds=new set<Id>();
                    set<Id> orgIds=new set<Id>();
                    Map<Id,String> orgCountry=new Map<Id,String>();
                    Map<Id,String> shipToCountry=new Map<Id,String>();
                    //List<ERP7__Invoice_Line_Item__c> inli=new List<ERP7__Invoice_Line_Item__c>([select Id,Name,ERP7__Sales_Order_Line_Item__c from ERP7__Invoice_Line_Item__c where Id IN:System.Trigger.new]);
                    for(ERP7__Invoice_Line_Item__c inv:Trigger.new){ 
                        soliIds.add(inv.ERP7__Sales_Order_Line_Item__c);
                        if(inv.ERP7__Order__c!=null) soIds.add(inv.ERP7__Order__c);
                        if(inv.ERP7__Organisation__c!=null) orgIds.add(inv.ERP7__Organisation__c);
                    }
                    if(orgIds.size()>0){
                        List<Account> orgAcc = [select Id, Name, ShippingCountry from Account where Id IN :orgIds];
                        for(Account acc : orgAcc){
                            if(acc.ShippingCountry != null){
                                orgCountry.put(acc.Id, acc.ShippingCountry);
                            }
                        }
                    }
                    
                    if(soIds.size()>0){
                        List<ERP7__Sales_Order__c> salesOrder = [select Id, name, ERP7__Ship_To_Address__c, ERP7__Ship_To_Address__r.ERP7__Country__c from ERP7__Sales_Order__c where Id IN :soIds];
                        for(ERP7__Sales_Order__c so : salesOrder){
                            if(so.ERP7__Ship_To_Address__r.ERP7__Country__c!=null){
                                shipToCountry.put(so.Id, so.ERP7__Ship_To_Address__r.ERP7__Country__c);
                            }
                        }
                    }
                    
                    Map<Id,ERP7__Sales_Order_Line_Item__c> solis=new Map<Id,ERP7__Sales_Order_Line_Item__c>([select Id,Name,ERP7__Invoiced_Quantity__c from ERP7__Sales_Order_Line_Item__c where Id IN:soliIds]);
                    RunModule =  Module__c.getAll();
                    if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c )){//&& PreventRecursiveLedgerEntry.proceed
                        List<Id> postedInvoiceIds = new List<Id>();
                        Map<Id, Id> InvoiceExisting_Transactions = new Map<Id, id>();
                        Map<Id, Id> InvoiceSalesExisting_Transactions = new Map<Id, id>();
                        Id CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Customer_Invoice_Transaction'); 
                        
                        for(Transaction__c eTransaction :[Select Id,Invoice__c, Organisation__c,  Product__c, ERP7__Amount__c, ERP7__Invoice_Line_Item__c, ERP7__Transaction_Type__c   From Transaction__c Where ERP7__Invoice_Line_Item__c  In : Trigger.NewMap.keyset() And Payment__c = NULL AND RecordTypeId=:CIT and ERP7__Transaction_Type__c = 'Sale Completed'])
                            InvoiceExisting_Transactions.put(eTransaction.ERP7__Invoice_Line_Item__c, eTransaction.id);
                        
                        for(Transaction__c eTransaction :[Select Id,Invoice__c, Organisation__c,  Product__c, ERP7__Amount__c, ERP7__Invoice_Line_Item__c, ERP7__Transaction_Type__c   From Transaction__c Where ERP7__Invoice_Line_Item__c  In : Trigger.NewMap.keyset() And Payment__c = NULL AND RecordTypeId=:CIT and ERP7__Transaction_Type__c = 'Invoice Sales'])
                            InvoiceSalesExisting_Transactions.put(eTransaction.ERP7__Invoice_Line_Item__c, eTransaction.id);
                        
                        
                        for( Integer i=0;i<InvoiceItemtrigger.size();i++){
                            system.debug('InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c-->'+InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c);
                            if(InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c == 'Sale'){
                                SOLISId.add(InvoiceItemtrigger[i].ERP7__Sales_Order_Line_Item__c);
                                ERP7__Sales_Order_Line_Item__c soli=solis.get(InvoiceItemtrigger[i].ERP7__Sales_Order_Line_Item__c);
                                if(soli!=null && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Invoiced_Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Invoiced_Quantity__c.isUpdateable()){
                                    
                                    if(soli.ERP7__Invoiced_Quantity__c>0 && soli.ERP7__Invoiced_Quantity__c < InvoiceItemtrigger[i].ERP7__Quantity__c ) {soli.ERP7__Invoiced_Quantity__c+=InvoiceItemtrigger[i].ERP7__Quantity__c; }
                                    else{
                                        Decimal sum=0;
                                        sum+=InvoiceItemtrigger[i].ERP7__Quantity__c;
                                        soli.ERP7__Invoiced_Quantity__c=sum;
                                    }
                                }
                                else{ /* no access*/}
                                SolisToUpdate.add(soli);
                            }
                            if(InvoiceItemtrigger[i].Posted__c && InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c == 'Sale' ){
                                ERP7__Invoice_Line_Item__c  InvLine = InvoiceItemtrigger[i];
                                Transaction__c trans = new Transaction__c(Id=(InvoiceExisting_Transactions.get(InvLine.Id)!=null)?InvoiceExisting_Transactions.get(InvLine.Id):null);
                                if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){trans.Active__c = InvLine.Posted__c;  } else { /* no access */ }
                                if(InvoiceExisting_Transactions.get(InvLine.Id) == null && Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){
                                    trans.Amount__c = InvLine.ERP7__Quantity__c * InvLine.ERP7__Cost_Price__c;} else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){trans.Organisation__c = InvLine.Organisation__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isUpdateable()){trans.Organisation_Business_Unit__c = InvLine.Organisation_Business_Unit__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Sales_Order__c.isUpdateable()){trans.Sales_Order__c = InvLine.Order__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Customer__c.isUpdateable()){trans.Customer__c = InvLine.Account__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Product__c.isUpdateable()){trans.Product__c = InvLine.Product__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Project__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Project__c.isUpdateable()){trans.Project__c = InvLine.Project__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = (InvLine.Posted_Date__c != null)? InvLine.Posted_Date__c:System.Today(); } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed'; } else { /* no access */ }
                                //if(RunModule.get('Finance').ERP7__Foreign_Sales__c){
                                if(orgCountry.size()>0 && shipToCountry.size()>0 && InvLine.ERP7__Order__c!=null && InvLine.ERP7__Organisation__c!=null){
                                    if(orgCountry.get(InvLine.ERP7__Organisation__c)!=shipToCountry.get(InvLine.ERP7__Order__c)){
                                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'Sale Completed'; } else { /* no access */ }
                                    }else{
                                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'Sale Completed'; } else { /* no access */ }
                                    }
                                }
                                
                                if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT;}  else { /* no access */ }
                                //trans.Invoice__c = InvLine.Invoice__c;
                                if(Schema.sObjectType.Transaction__c.fields.Invoice_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Invoice_Line_Item__c.isUpdateable()){trans.Invoice_Line_Item__c = InvLine.Id; } else { /* no access */ }
                                //Transactions2update.add(trans);
                                //PreventRecursiveLedgerEntry.InvoiceLinesProcess = false;
                            }
                            
                            if(InvoiceItemtrigger[i].Posted__c && InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c == 'Sale' ){
                                ERP7__Invoice_Line_Item__c  InvLine = InvoiceItemtrigger[i];
                                Transaction__c trans = new Transaction__c(Id=(InvoiceSalesExisting_Transactions.get(InvLine.Id)!=null)?InvoiceSalesExisting_Transactions.get(InvLine.Id):null);
                                if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){trans.Active__c = InvLine.Posted__c;  } else { /* no access */ }
                                if(InvoiceSalesExisting_Transactions.get(InvLine.Id) == null && Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){
                                    trans.Amount__c = InvLine.ERP7__Total_Price_Per_Item__c;} else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){trans.Organisation__c = InvLine.Organisation__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isUpdateable()){trans.Organisation_Business_Unit__c = InvLine.Organisation_Business_Unit__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Sales_Order__c.isUpdateable()){trans.Sales_Order__c = InvLine.Order__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Customer__c.isUpdateable()){trans.Customer__c = InvLine.Account__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Product__c.isUpdateable()){trans.Product__c = InvLine.Product__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Project__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Project__c.isUpdateable()){trans.Project__c = InvLine.Project__c; } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = (InvLine.Posted_Date__c != null)? InvLine.Posted_Date__c:System.Today(); } else { /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed'; } else { /* no access */ }
                                //if(RunModule.get('Finance').ERP7__Foreign_Sales__c){
                                if(orgCountry.size()>0 && shipToCountry.size()>0 && InvLine.ERP7__Order__c!=null && InvLine.ERP7__Organisation__c!=null){
                                    if(orgCountry.get(InvLine.ERP7__Organisation__c)!=shipToCountry.get(InvLine.ERP7__Order__c)){
                                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'Invoice Sales'; } else { /* no access */ }
                                    }else{
                                        if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'Invoice Sales'; } else { /* no access */ }
                                    }
                                }
                                /*}else{
trans.Transaction_Type__c = 'Sale Completed';
}*/
                                if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT;}  else { /* no access */ }
                                trans.Invoice__c = InvLine.Invoice__c;
                                if(Schema.sObjectType.Transaction__c.fields.Invoice_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Invoice_Line_Item__c.isUpdateable()){trans.Invoice_Line_Item__c = InvLine.Id; } else { /* no access */ }
                                Transactions2update.add(trans);
                                PreventRecursiveLedgerEntry.InvoiceLinesProcess = false;
                            }
                        } 
                        
                        
                    }
                    
                    //PreventRecursiveLedgerEntry.InvoiceLinesProcess = false;
                    if(Transactions2update.size() > 0 &&  Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()){ upsert Transactions2update; } else { /* no access */ }
                    if(SolisToUpdate.size() > 0 &&  Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()) { upsert SolisToUpdate; } else { /* no access */ }
                    
                }    
                if(trigger.isDelete) {
                    list<ERP7.RollUpSummaryUtility.fieldDefinition> CommfieldDefinitions = new list<ERP7.RollUpSummaryUtility.fieldDefinition> {
                        new ERP7.RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity__c', 'ERP7__Invoiced_Quantity__c')
                            };
                                
                                ERP7.RollUpSummaryUtility.rollUpTrigger(CommfieldDefinitions, trigger.old, 'ERP7__Invoice_Line_Item__c', 
                                                                        'ERP7__Sales_Order_Line_Item__c', 'ERP7__Sales_Order_Line_Item__c', '');
                }
                
                
            }
        }
        
        else if(ILIIdsWithOP.size() > 0){
            Set<Id> SOLISId = new Set<Id>();
            List < Invoice_Line_Item__c > InvoiceItemtrigger = new List < Invoice_Line_Item__c > ();
            List < Invoice_Line_Item__c > InvoiceItemOldtrigger = new List < Invoice_Line_Item__c > ();
            
            if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
                InvoiceItemtrigger = Trigger.new;
                InvoiceItemOldtrigger = Trigger.old;
                
            }
            if (Trigger.isDelete){ InvoiceItemtrigger = Trigger.old;}
            
            if(PreventRecursiveLedgerEntry.InvoiceLinesProcess){
                if(trigger.isInsert || trigger.isUpdate || trigger.isUnDelete) {
                    Map<string, Module__c > RunModule = new Map<string, Module__c >();
                    List<Transaction__c> Transactions2update = new List<Transaction__c>();
                    List<OrderItem> SolisToUpdate=new List<OrderItem>();
                    set<Id> soliIds=new set<Id>();
                    //List<ERP7__Invoice_Line_Item__c> inli=new List<ERP7__Invoice_Line_Item__c>([select Id,Name,ERP7__Order_Product__c from ERP7__Invoice_Line_Item__c where Id IN:System.Trigger.new]);
                    for(ERP7__Invoice_Line_Item__c inv:Trigger.new){
                        soliIds.add(inv.ERP7__Order_Product__c);
                    }
                    Map<Id,OrderItem> solis=new Map<Id,OrderItem>([select Id,ERP7__Invoiced_Quantity__c from OrderItem where Id IN:soliIds]);
                    RunModule =  Module__c.getAll();
                    if(Test.isRunningTest() || (RunModule.size() > 0 && RunModule.get('Finance').Run__c && PreventRecursiveLedgerEntry.proceed)){
                        List<Id> postedInvoiceIds = new List<Id>();
                        Map<Id, Id> InvoiceExisting_Transactions = new Map<Id, id>();
                        Id CIT = RecordTypeUtil.getObjectRecordTypeIds('Transaction__c','Customer_Invoice_Transaction'); 
                        
                        for(Transaction__c eTransaction :[Select Id,Invoice__c, Organisation__c,  Product__c, ERP7__Amount__c, ERP7__Invoice_Line_Item__c   From Transaction__c Where ERP7__Invoice_Line_Item__c  In : Trigger.NewMap.keyset() And Payment__c = NULL AND RecordTypeId=:CIT ])
                            InvoiceExisting_Transactions.put(eTransaction.ERP7__Invoice_Line_Item__c, eTransaction.id);
                        //////////////////////FROM HERE
                        Map<Id, Decimal> soliToInvoiceQtyMap = new Map<Id, Decimal>();
                        Map<Id, Id> iliToSoliMap = new Map<Id, Id>(); // Needed to link Credit Note Items back to SOLI
                        
                        for (Invoice_Line_Item__c ili : [
                            SELECT Id, ERP7__Quantity__c, ERP7__Order_Product__c
                            FROM ERP7__Invoice_Line_Item__c
                            WHERE ERP7__Order_Product__c IN :soliIds and ERP7__Invoice_Record_Type_Name__c='Sale'
                        ]) {
                            Id soliId = ili.ERP7__Order_Product__c;
                            iliToSoliMap.put(ili.Id, soliId);
                            
                            if (!soliToInvoiceQtyMap.containsKey(soliId)) {
                                soliToInvoiceQtyMap.put(soliId, 0);
                            }
                            soliToInvoiceQtyMap.put(soliId, soliToInvoiceQtyMap.get(soliId) + (ili.ERP7__Quantity__c != null ? ili.ERP7__Quantity__c : 0));
                        }
                        
                        // Step 2: Build credit quantity map per SOLI
                        Map<Id, Decimal> soliToCreditQtyMap = new Map<Id, Decimal>();
                        
                        for (Credit_Note_Item__c cni : [
                            SELECT Id, Quantity__c, Invoice_Line_Item__c
                            FROM Credit_Note_Item__c
                            WHERE Invoice_Line_Item__c IN :iliToSoliMap.keySet()
                        ]) {
                            Id soliId = iliToSoliMap.get(cni.Invoice_Line_Item__c);
                            if (!soliToCreditQtyMap.containsKey(soliId)) {
                                soliToCreditQtyMap.put(soliId, 0);
                            }
                            soliToCreditQtyMap.put(soliId, soliToCreditQtyMap.get(soliId) + (cni.Quantity__c != null ? cni.Quantity__c : 0));
                        }
                        ///////////////////////////TILL HERE
                        
                        for( Integer i=0;i<InvoiceItemtrigger.size();i++){
                            system.debug('InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c-->'+InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c);
                            if(InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c == 'Sale'){
                                SOLISId.add(InvoiceItemtrigger[i].ERP7__Order_Product__c);
                                OrderItem soli=solis.get(InvoiceItemtrigger[i].ERP7__Order_Product__c);
                                if(soli!=null && Schema.sObjectType.OrderItem.fields.ERP7__Invoiced_Quantity__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Invoiced_Quantity__c.isUpdateable()){
                                    /*if(soli.ERP7__Invoiced_Quantity__c>0 && soli.ERP7__Invoiced_Quantity__c < InvoiceItemtrigger[i].ERP7__Quantity__c) {soli.ERP7__Invoiced_Quantity__c+=InvoiceItemtrigger[i].ERP7__Quantity__c; }
else{
Decimal sum=0;
sum+=InvoiceItemtrigger[i].ERP7__Quantity__c;
soli.ERP7__Invoiced_Quantity__c=sum;
}*/
                                    Decimal totalInvoice = soliToInvoiceQtyMap.get(InvoiceItemtrigger[i].ERP7__Order_Product__c) != null ? soliToInvoiceQtyMap.get(InvoiceItemtrigger[i].ERP7__Order_Product__c) : 0;
                                    Decimal totalCredit = soliToCreditQtyMap.get(InvoiceItemtrigger[i].ERP7__Order_Product__c) != null ? soliToCreditQtyMap.get(InvoiceItemtrigger[i].ERP7__Order_Product__c) : 0;
                                    soli.ERP7__Invoiced_Quantity__c=totalInvoice - totalCredit;
                                }
                                else{ /* no access */ }
                                
                                SolisToUpdate.add(soli);
                            }
                            if(InvoiceItemtrigger[i].Posted__c && InvoiceItemtrigger[i].ERP7__Invoice_Record_Type_Name__c == 'Sale' && ((trigger.isInsert || trigger.isUnDelete) || (InvoiceItemtrigger[i].Posted__c != InvoiceItemOldtrigger[i].Posted__c))){
                                ERP7__Invoice_Line_Item__c  InvLine = InvoiceItemtrigger[i];
                                Transaction__c trans = new Transaction__c(Id=(InvoiceExisting_Transactions.get(InvLine.Id)!=null)?InvoiceExisting_Transactions.get(InvLine.Id):null);
                                if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){ trans.Active__c = InvLine.Posted__c; } else{ /* no access */ }
                                if(InvoiceExisting_Transactions.get(InvLine.Id) == null && Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){
                                    trans.Amount__c = InvLine.ERP7__Total_Price_Per_Item__c; } else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){trans.Organisation__c = InvLine.Organisation__c; } else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation_Business_Unit__c.isUpdateable()){trans.Organisation_Business_Unit__c = InvLine.Organisation_Business_Unit__c; } else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Order__c.isUpdateable()){trans.ERP7__Order__c = InvLine.ERP7__Order_S__c; } else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Customer__c.isUpdateable()){trans.Customer__c = InvLine.Account__c;} else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Product__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Product__c.isUpdateable()){trans.Product__c = InvLine.Product__c;} else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Project__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Project__c.isUpdateable()){trans.Project__c = InvLine.Project__c;} else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = (InvLine.Posted_Date__c != null)? InvLine.Posted_Date__c:System.Today(); } else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed';} else{ /* no access */ }
                                if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = 'Sale Completed'; } else{ /* no access */ }
                                if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT;} else{ /* no access */ }
                                //trans.Invoice__c = InvLine.Invoice__c;
                                if(Schema.sObjectType.Transaction__c.fields.Invoice_Line_Item__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Invoice_Line_Item__c.isUpdateable()){trans.Invoice_Line_Item__c = InvLine.Id; } else{ /* no access */ }
                                //Transactions2update.add(trans);
                            }
                        } 
                        
                        
                    }
                    
                    PreventRecursiveLedgerEntry.InvoiceLinesProcess = false;
                    if(Transactions2update.size() > 0 &&  Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()){ upsert Transactions2update; } else{ /* no access */ }
                    if(SolisToUpdate.size() > 0 && Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()) { upsert SolisToUpdate; } else { /* no access */ }
                    
                }    
                if(trigger.isDelete) {
                    if(trigger.isAfter) {
                        List<Id> oldCreditNoteIds = new List<Id>();
                        
                        for (Invoice_Line_Item__c oldRec : Trigger.old) {
                            oldCreditNoteIds.add(oldRec.ERP7__Order_Product__c);
                        }
                        CreateDebitNote.handleOPAfterDelete(oldCreditNoteIds);
                    }
                    list<ERP7.RollUpSummaryUtility.fieldDefinition> CommfieldDefinitions = new list<ERP7.RollUpSummaryUtility.fieldDefinition> {
                        new ERP7.RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Quantity__c', 'ERP7__Invoiced_Quantity__c')
                            };
                                
                                ERP7.RollUpSummaryUtility.rollUpTrigger(CommfieldDefinitions, trigger.old, 'ERP7__Invoice_Line_Item__c', 
                                                                        'OrderItem', 'OrderItem', '');
                }
                
                PreventRecursiveLedgerEntry.InvoiceLinesProcess = false;
            }
        }
    }catch(Exception ex){
        System.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString());
        String exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString(); 
    } 
    }
}