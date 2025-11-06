public With Sharing class RecordPayment {
    @AuraEnabled  
    public static ERP7__Debit_Note__c getDebitDetails(String debitId){
        return [Select id, Name, ERP7__Amount__c, ERP7__Account__c, ERP7__Debit__c From ERP7__Debit_Note__c where id =: debitId ];
    }
    
    @AuraEnabled
    public static List<ERP7__Chart_of_Accounts__c> fetchBankAccount(String OrgId){
        return [select id,Name from ERP7__Chart_of_Accounts__c where ERP7__Bank_Account__c != null AND ERP7__Organisation__c=:OrgId];
    }
    
    public class CNWrapper{ @AuraEnabled public ERP7__Credit_Note__c credNote {get;set;} @AuraEnabled public Decimal debitAmount {get;set;} public CNWrapper(){ debitAmount = 0.00; credNote = new ERP7__Credit_Note__c(); } }
    
    @AuraEnabled
    public static List<CNWrapper> fetchCreditNote(String CusAccId){ List<CNWrapper> cnwrap = new List<CNWrapper>(); system.debug('CusAccId'+CusAccId); List<ERP7__Credit_Note__c> cnList = new List<ERP7__Credit_Note__c>(); if(CusAccId!=null){ cnList = [select id, Name, ERP7__Credit__c, ERP7__Debit__c,  ERP7__Sales_Order__c,ERP7__Sales_Order__r.Name, ERP7__Account__c, ERP7__Balance__c from ERP7__Credit_Note__c where ERP7__Balance__c>0 and ERP7__Account__c= :CusAccId order by CreatedDate DESC]; if(cnList.size()>0){ for(ERP7__Credit_Note__c cc : cnList){ CNWrapper cwrap = new CNWrapper(); cwrap.credNote = cc; /*if(cc.ERP7__Debit__c!=null) cwrap.debitAmount = cc.ERP7__Debit__c;*/ cnwrap.add(cwrap); } } return cnwrap; }else{ return null; } }
    
    @AuraEnabled
    public static ERP7__Invoice__c getInvoiceDetails(String recordId){
        
        return [SELECT Id, Name, ERP7__Invoice_Date__c, ERP7__Organisation__c, ERP7__Payment_Terms__c, ERP7__Order__c, ERP7__Paid_Amount__c, ERP7__Invoice_Amount__c, ERP7__Total_Due__c,ERP7__Account__c,ERP7__Account__r.ERP7__Organisation__c,RecordType.DeveloperName, ERP7__Down_Payment__c, ERP7__Total_Down_Payment_Amount__c,ERP7__Credit_Note__c
                FROM ERP7__Invoice__c WHERE Id =:recordId 
                AND ERP7__Paid__c= false  AND ERP7__Total_Due__c != 0.00 AND ERP7__Account__c !=null];//AND ERP7__Posted__c=true
        
        
    }
    
    @AuraEnabled
    public static Integer getDaysBetween(Date invDate, Date payDate){ system.debug('M'+invDate.daysBetween(payDate)); return invDate.daysBetween(payDate); }
    
    @AuraEnabled
    public static invPayWrapper getRefundInvoiceDetails(String recordId, String paymentId){ invPayWrapper invWrap = new invPayWrapper(); invWrap.inv = [SELECT Id, Name, ERP7__Invoice_Date__c, ERP7__Organisation__c, ERP7__Order__c, ERP7__Paid_Amount__c, ERP7__Invoice_Amount__c, ERP7__Total_Due__c,ERP7__Account__c,ERP7__Account__r.ERP7__Organisation__c,RecordType.DeveloperName, ERP7__Down_Payment__c, ERP7__Total_Down_Payment_Amount__c,ERP7__Credit_Note__c FROM ERP7__Invoice__c WHERE Id =:recordId limit 1];/*AND ERP7__Posted__c=true*/ ERP7__Payment__c pay = [SELECT Id, Name, ERP7__Amount__c FROM ERP7__Payment__c WHERE Id =:paymentId limit 1]; system.debug('Payment ---->'+pay); invWrap.totalAmount = pay.ERP7__Amount__c; return invWrap; }
    
    public class invPayWrapper{ @AuraEnabled public ERP7__Invoice__c inv {get;set;} @AuraEnabled public Decimal totalAmount  {get;set;} public invPayWrapper(){ inv = new ERP7__Invoice__c(); totalAmount = 0.00; } }
    
    @AuraEnabled
    public static void updateInvoiceCreditNotes(List<CNWrapper> cnList, String inv){ try{ system.debug('inv-->'+inv); system.debug('cnList-->'+cnList); List<ERP7__Credit_Note_Applied_on_Invoice__c> appliedNotes = new List<ERP7__Credit_Note_Applied_on_Invoice__c>(); List<ERP7__Credit_Note__c> cn2Update = new List<ERP7__Credit_Note__c>(); List<Account> account2Update = new List<Account>(); ERP7__Invoice__c invoices = (ERP7__Invoice__c)JSON.deserialize(inv, ERP7__Invoice__c.class); PreventRecursiveLedgerEntry.proceed = false; update invoices; if(invoices!=null){ if(invoices.ERP7__Order__c != null && invoices.ERP7__Credit_Note__c!=null){/*Moin added invoices.ERP7__Credit_Note__c!=null*/ ERP7__Sales_Order__c so = [select Id, Name, ERP7__Amount_Paid__c from ERP7__Sales_Order__c where Id=:invoices.ERP7__Order__c]; if(so.ERP7__Amount_Paid__c==null) so.ERP7__Amount_Paid__c = invoices.ERP7__Credit_Note__c; else so.ERP7__Amount_Paid__c = so.ERP7__Amount_Paid__c + invoices.ERP7__Credit_Note__c; update so; } } system.debug('invoices-->'+invoices); if(cnList!=null && cnList.size()>0) { for(CNWrapper cwrap : cnList){ system.debug('cwrap-->'+cwrap); if(cwrap!=null){ if(cwrap.debitAmount>0){ ERP7__Credit_Note_Applied_on_Invoice__c capplied = new ERP7__Credit_Note_Applied_on_Invoice__c(); capplied.ERP7__Amount__c = cwrap.debitAmount; capplied.ERP7__Credit_Note__c = cwrap.credNote.Id; capplied.ERP7__Invoice__c = invoices.Id; capplied.Name = invoices.Name + ' ' + cwrap.credNote.Name; appliedNotes.add(capplied); if(cwrap.credNote.ERP7__Debit__c!=null) cwrap.credNote.ERP7__Debit__c = cwrap.credNote.ERP7__Debit__c + cwrap.debitAmount; else cwrap.credNote.ERP7__Debit__c = cwrap.debitAmount; cwrap.credNote.ERP7__Applied_Date__c = system.today(); cn2Update.add(cwrap.credNote); } } } } if(appliedNotes.size()>0) upsert appliedNotes; if(cn2Update.size()>0)  { PreventRecursiveLedgerEntry.testCasesTransactions = true; update cn2Update; } if(invoices!=null){ if(invoices.ERP7__Account__c!=null){ Account acc2update = [select Id, Name, ERP7__Debit_Balance__c from Account where Id =:invoices.ERP7__Account__c]; if(acc2update.ERP7__Debit_Balance__c==null) acc2update.ERP7__Debit_Balance__c = invoices.ERP7__Credit_Note__c; else acc2update.ERP7__Debit_Balance__c = acc2update.ERP7__Debit_Balance__c + invoices.ERP7__Credit_Note__c; system.debug('acc2update'+acc2update); ERP7.PreventRecursiveLedgerEntry.proceed = false; update acc2update; } } /*if(invList != null) update invList;*/ }catch(Exception e){ system.debug('Exception updateInvoiceCreditNotes-->'+e+e.getLineNumber()); } }
    
    @AuraEnabled
    public static void updateInvoiceCreditNotesUpdated(List<ERP7__Credit_Note__c> cnList, String inv){ system.debug('inv-->'+inv); system.debug('cnList-->'+cnList); if(cnList!=null && cnList.size()>0) update cnList; /*if(invList != null) update invList;*/ ERP7__Invoice__c invoices = (ERP7__Invoice__c)JSON.deserialize(inv, ERP7__Invoice__c.class); update invoices; Decimal debitSum = invoices.ERP7__Credit_Note__c; if(invoices!=Null){ if(invoices.ERP7__Account__c!=null){ Account acc = [select Id, Name, ERP7__Debit_Balance__c from Account where Id=:invoices.ERP7__Account__c]; if(acc.ERP7__Debit_Balance__c != null) acc.ERP7__Debit_Balance__c = acc.ERP7__Debit_Balance__c + debitSum; else acc.ERP7__Debit_Balance__c = debitSum; update acc; } } }
    
    @AuraEnabled
    public static Map<String,Object> getAccountBalance(String accountId){
        system.debug('accountId-->'+accountId);
        Map<String,Object> returnValue = new Map<String,Object>();
        try{
            if(String.isNotEmpty(accountId)){
                returnValue.put('invoiceList',[SELECT Id, Name, ERP7__Invoice_Date__c,ERP7__Paid_Amount__c, ERP7__Invoice_Amount__c, ERP7__Total_Due__c  
                                               FROM ERP7__Invoice__c WHERE ERP7__Account__c =:accountId 
                                               AND ERP7__Paid__c= false  order by CreatedDate desc]);//AND ERP7__Posted__c=true AND ERP7__Total_Due__c > 0.00 
                returnValue.put('availableCredits',[SELECT Id, ERP7__Available_Credit_Balance__c,ERP7__Organisation__c 
                                                    FROM Account WHERE Id =:accountId]); } }catch(Exception ex){ returnValue.put('error',ex.getMessage());
                                                                                                               }
        return returnValue;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveTaxPayment(String payment){
        ERP7__Payment__c pay = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) pay.ERP7__Transaction_Type__c = 'Tax Payment';
        Map<String,Object> returnValue = new Map<String,Object>();
        
        try{
            if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){upsert pay;} else{ returnValue.put('error','Not allowed to upsert payment');} }catch(Exception e){  returnValue.put('error',e.getMessage());
                                                                                                                                                                                                                          }
        return returnValue;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveAppliedPayment(String payment,String appliedPaymentList,String PM,Boolean post,String RType,String accId, Boolean isAdvance){
        Map<String,Object> returnValue = new Map<String,Object>();
        try{
            List<ERP7__Payment_Applied_on_Invoice__c> appliedPayments = (List<ERP7__Payment_Applied_on_Invoice__c>)JSON.deserialize(appliedPaymentList, List<ERP7__Payment_Applied_on_Invoice__c>.class);
            ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
            if(payments.ERP7__Account__c==null && accId!=null && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){  payments.ERP7__Account__c = (String) Database.Query('SELECT ERP7__Organisation__c FROM Account WHERE id =: accId')[0].get('ERP7__Organisation__c');  }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
            Id RT;
            if(RType == 'Customer Payment' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId(); 
            if(RType == 'Debit_Note_Payments' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Debit_Note_Payments').getRecordTypeId();
           
            if(RType=='Customer Payment'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Customer Payment';
                                         }
            if(RType == 'Debit_Note_Payments'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Debit Payment';
                                              }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Debit';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payments.ERP7__Status__c='Paid';
            if( RType != 'Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && !isAdvance) payments.ERP7__Transaction_Type__c='InvoicePayment';
            if(isAdvance) payments.ERP7__Transaction_Type__c='AdvancePayment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=post;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c=PM;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isUpdateable()) payments.ERP7__Payment_Gateway__c = PM;
            if(PM=='Credit' && RType!='Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable())payments.ERP7__Transaction_Type__c='CreditPayment';
            if(RType =='Customer Payment' || RType == 'Debit_Note_Payments' ){
                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments;} else{returnValue.put('error', 'Not allowed to upsert payment'); }
                ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                returnValue.put('pay', payName); 
                returnValue.put('payments',payments);
            }else{
                ERP7__Invoice__c INV=new ERP7__Invoice__c();
                if(appliedPayments.size()>0) INV=[Select id,ERP7__Organisation__c,RecordType.DeveloperName, ERP7__Order__c,ERP7__Order_S__c,ERP7__Invoice_Amount__c, RecordTypeId,ERP7__Amount_Paid__c from ERP7__Invoice__c where id=:appliedPayments[0].ERP7__Invoice__c limit  1 ];
                if(appliedPayments.size()>0 && !payments.ERP7__Refund__c){
                    if(INV.RecordType.DeveloperName=='On_Account_Payment'){ 
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Credit';  
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='CreditPayment';
                    }
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()) payments.ERP7__Account__c=INV.ERP7__Organisation__c;
                }
                System.debug('INV '+INV);
                System.debug('appliedPayments '+appliedPayments);
                System.debug('payments '+payments);
                if(INV != null && INV.ERP7__Order__c == null && INV.ERP7__Order_S__c == null){
                    List<ERP7__Invoice_Line_Item__c> INVLine = new List<ERP7__Invoice_Line_Item__c>();
                    INVLine = [SELECT Id, ERP7__Total_Price__c, ERP7__Order_Product__r.OrderId, ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c FROM ERP7__Invoice_Line_Item__c Where ERP7__Invoice__c =:INV.Id];
                    Map<Id, Decimal> SOrderMAp = new Map<Id, Decimal>();
                    Map<Id, Decimal> OrderMAp = new Map<Id, Decimal>();
                    for(ERP7__Invoice_Line_Item__c INVli: INVLine){
                        if(INVli.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c!=null){
                            Decimal OrdAmount = SOrderMAp.containsKey(INVli.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c) ? SOrderMAp.get(INVli.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c) : 0.00;
                            OrdAmount += INVli.ERP7__Total_Price__c;
                            SOrderMAp.put(INVli.ERP7__Sales_Order_Line_Item__r.ERP7__Sales_Order__c, OrdAmount);
                        }else if(INVli.ERP7__Order_Product__r.OrderId!=null){
                            Decimal OrdAmount = OrderMAp.containsKey(INVli.ERP7__Order_Product__r.OrderId) ? OrderMAp.get(INVli.ERP7__Order_Product__r.OrderId) : 0.00;
                            OrdAmount += INVli.ERP7__Total_Price__c;
                            OrderMAp.put(INVli.ERP7__Order_Product__r.OrderId, OrdAmount);
                        }                           
                    }
                    Decimal payPercent = payments.ERP7__Amount__c / INV.ERP7__Invoice_Amount__c * 100;
                    Decimal payPercentRound = payPercent;
                    if(appliedPayments.size()==1){ if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable()) payments.ERP7__Invoice__c=appliedPayments[0].ERP7__Invoice__c;}
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments; }  else{returnValue.put('error', 'Cannot upsert paymnet accounts');  }
                    ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                    returnValue.put('pay', payName); 
                    if (!SOrderMAp.isEmpty()) {
                        List<ERP7__Sales_Order__c> SOList = [SELECT Id, Name, ERP7__Amount_Paid__c FROM ERP7__Sales_Order__c WHERE Id IN :SOrderMap.keySet()];
                        List<ERP7__Sales_Order__c> SOUpdateList = new List<ERP7__Sales_Order__c>();
                        List<ERP7__Payment_Applied_on_Invoice__c> appliedMultipay = new List<ERP7__Payment_Applied_on_Invoice__c>();
                        for (ERP7__Sales_Order__c SO : SOList) {
                            ERP7__Payment_Applied_on_Invoice__c appPay = new ERP7__Payment_Applied_on_Invoice__c();
                            ERP7__Sales_Order__c SOrder = new ERP7__Sales_Order__c();
                            Decimal Amt = SOrderMap.get(SO.Id);
                            if(Amt != null){
                                Decimal OrdAmt = payPercentRound*Amt/100; Decimal OrdAmtRound = OrdAmt; appPay.ERP7__Sales_Order__c = SO.Id;appPay.ERP7__Amount__c = OrdAmtRound;appPay.ERP7__Payment__c = payments.id;appPay.ERP7__Invoice__c = INV.Id;appPay.ERP7__Applied_Date__c = System.Today();appPay.ERP7__Type__c = 'Debit';appliedMultipay.add(appPay); SOrder.Id = SO.Id;
                                if(SO.ERP7__Amount_Paid__c!=null){ SOrder.ERP7__Amount_Paid__c = SO.ERP7__Amount_Paid__c + OrdAmtRound; } else { SOrder.ERP7__Amount_Paid__c = OrdAmtRound; }                            
                                SOUpdateList.add(SOrder);
                            }                        
                        }

                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isUpdateable()) { upsert appliedMultipay; } else{/*connot upsertapplied payment*/}
                        if(SOUpdateList.size() > 0)update SOUpdateList;
                        returnValue.put('payments',payments);
                    }else if(!OrderMAp.isEmpty()){
                        List<Order> OrdList = [SELECT Id, Name, ERP7__Amount_Paid__c FROM Order WHERE Id IN :OrderMap.keySet()];
                        List<Order> OrdUpdateList = new List<Order>();
                        List<ERP7__Payment_Applied_on_Invoice__c> appliedMultipay = new List<ERP7__Payment_Applied_on_Invoice__c>();
                        for (Order Ord : OrdList) {
                            ERP7__Payment_Applied_on_Invoice__c appPay = new ERP7__Payment_Applied_on_Invoice__c();
                            Order Order = new Order();
                            Decimal Amt = OrderMap.get(Ord.Id);
                            if(Amt != null){ Decimal OrdAmt = payPercentRound*Amt/100; Decimal OrdAmtRound = OrdAmt;
                                appPay.ERP7__Order__c = Ord.Id;  appPay.ERP7__Amount__c = OrdAmtRound;appPay.ERP7__Payment__c = payments.id; appPay.ERP7__Invoice__c = INV.Id; appPay.ERP7__Applied_Date__c = System.Today(); appPay.ERP7__Type__c = 'Debit'; appliedMultipay.add(appPay); Order.Id = Ord.Id;
                                if(Ord.ERP7__Amount_Paid__c!=null){ Order.ERP7__Amount_Paid__c = Ord.ERP7__Amount_Paid__c + OrdAmtRound; } else { Order.ERP7__Amount_Paid__c = OrdAmtRound; }                            
                                OrdUpdateList.add(Order);
                            }                        
                        }

                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isUpdateable()) { upsert appliedMultipay; } else{/*connot upsertapplied payment*/}
                        if(OrdUpdateList.size() > 0) update OrdUpdateList;
                        returnValue.put('payments',payments);
                    }


                }else if((INV.ERP7__Order__c != null || INV.ERP7__Order_S__c != null) && appliedPayments.size()==1){
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable()) payments.ERP7__Invoice__c=appliedPayments[0].ERP7__Invoice__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable()) payments.ERP7__Sales_Order__c=INV.ERP7__Order__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isUpdateable()) payments.ERP7__Order__c=INV.ERP7__Order_S__c;
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){upsert payments; } else{returnValue.put('error', 'Cannot upsert paymnet');  }
                    ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                    returnValue.put('pay', payName); 
                }else{
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments; }  else{returnValue.put('error', 'Cannot upsert paymnet accounts');  }
                    ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                    returnValue.put('pay', payName);    
                    
                    for(Integer i=0;i<appliedPayments.size();i++) if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isUpdateable()) appliedPayments[i].ERP7__Payment__c = payments.id;
                    if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isUpdateable()) { upsert appliedPayments; } else{/*connot upsertapplied payment*/}
                    returnValue.put('payments',payments);
                }
            }
        }catch(Exception ex){  returnValue.put('error',ex.getMessage());
                            }
        return returnValue;
    }
    
    
    @AuraEnabled
    public static Map<String,Object> saveRefundPayment(String payment,String PM,Boolean post,String RType,String accId){
        Map<String,Object> returnValue = new Map<String,Object>();
        try{
            ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
            if(payments.ERP7__Account__c==null && accId!=null && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){  payments.ERP7__Account__c = (String) Database.Query('SELECT ERP7__Organisation__c FROM Account WHERE id =: accId')[0].get('ERP7__Organisation__c');  }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
            Id RT;
            if(RType == 'Customer Payment' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId(); 
            if(RType == 'Debit_Note_Payments' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Debit_Note_Payments').getRecordTypeId();
            
            if(RType=='Customer Payment'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Customer Payment';
                                         }
            if(RType == 'Debit_Note_Payments'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Debit Payment';
                                              }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Debit';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payments.ERP7__Status__c='Paid';
            if( RType != 'Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='InvoicePayment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=post;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c=PM;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isUpdateable()) payments.ERP7__Payment_Gateway__c = PM;
            if(PM=='Credit' && RType!='Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable())payments.ERP7__Transaction_Type__c='CreditPayment';
            if(RType =='Customer Payment' || RType == 'Debit_Note_Payments' ){
                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments;} else{returnValue.put('error', 'Not allowed to upsert payment'); }
                ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                returnValue.put('pay', payName); 
                returnValue.put('payments',payments);
            }
            if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){
                upsert payments; 
                ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                returnValue.put('pay', payName); 
                returnValue.put('payments',payments);
            } else{returnValue.put('error', 'Cannot upsert paymnet');  }
        }catch(Exception ex){  
            returnValue.put('error',ex.getMessage());
            system.debug('Exception-->'+ex+ex.getLineNumber());
        }
        return returnValue;
    }
    
    @AuraEnabled
    public static Map<String,Object> saveAppliedPaymentAgainstCreditNote(String payment,String appliedPaymentList,String PM,Boolean post,String RType,String accId, Integer credNoteAmount, Boolean isAdvance){
        Map<String,Object> returnValue = new Map<String,Object>();
        try{
            List<ERP7__Payment_Applied_on_Invoice__c> appliedPayments = (List<ERP7__Payment_Applied_on_Invoice__c>)JSON.deserialize(appliedPaymentList, List<ERP7__Payment_Applied_on_Invoice__c>.class);
            ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
            if(payments.ERP7__Account__c==null && accId!=null && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){  payments.ERP7__Account__c = (String) Database.Query('SELECT ERP7__Organisation__c FROM Account WHERE id =: accId')[0].get('ERP7__Organisation__c');  }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
            Id RT;
            if(RType == 'Customer Payment' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId(); 
            if(RType == 'Debit_Note_Payments' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Debit_Note_Payments').getRecordTypeId();
           
            if(RType=='Customer Payment'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Customer Payment';
                                         }
            if(RType == 'Debit_Note_Payments'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Debit Payment';
                                              }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Debit';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payments.ERP7__Status__c='Paid';
            if( RType != 'Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && !isAdvance) payments.ERP7__Transaction_Type__c='InvoicePayment';
            if(isAdvance) payments.ERP7__Transaction_Type__c='AdvancePayment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=post;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c=PM;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isUpdateable()) payments.ERP7__Payment_Gateway__c = PM;
            if(PM=='Credit' && RType!='Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable())payments.ERP7__Transaction_Type__c='CreditPayment';
            if(RType =='Customer Payment' || RType == 'Debit_Note_Payments' ){
                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments;} else{returnValue.put('error', 'Not allowed to upsert payment'); }
                ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                returnValue.put('pay', payName); 
                returnValue.put('payments',payments);
            }else{
                ERP7__Invoice__c INV=new ERP7__Invoice__c();
                if(appliedPayments.size()>0){
                    INV=[Select id,ERP7__Organisation__c,RecordType.DeveloperName, RecordTypeId,ERP7__Amount_Paid__c from ERP7__Invoice__c where id=:appliedPayments[0].ERP7__Invoice__c limit  1 ];
                    if(INV.RecordType.DeveloperName=='On_Account_Payment'){ 
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Credit';  
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='CreditPayment';
                    }
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()) payments.ERP7__Account__c=INV.ERP7__Organisation__c;
                }
                if(appliedPayments.size()==1){
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable()) payments.ERP7__Invoice__c=appliedPayments[0].ERP7__Invoice__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable()) payments.ERP7__Sales_Order__c=[Select Id,ERP7__Order__c from ERP7__Invoice__c where Id =:appliedPayments[0].ERP7__Invoice__c].ERP7__Order__c;
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){upsert payments; } else{returnValue.put('error', 'Cannot upsert paymnet');  }
                    ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                    returnValue.put('pay', payName); 
                }else{
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments; }  else{returnValue.put('error', 'Cannot upsert paymnet accounts');  }
                    ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                    returnValue.put('pay', payName);    
                    
                    for(Integer i=0;i<appliedPayments.size();i++) if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isUpdateable()) appliedPayments[i].ERP7__Payment__c = payments.id;
                    if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isUpdateable()) { upsert appliedPayments; } else{/*connot upsertapplied payment*/}
                    returnValue.put('payments',payments);
                }
            }
        }catch(Exception ex){  returnValue.put('error',ex.getMessage());
                            }
        return returnValue;
    }
    
    @AuraEnabled
    public static List<SelectOptions> credList(){ List<SelectOptions> credList = new List<SelectOptions>(); if(Schema.sObjectType.Credentials__c.isAccessible()) { for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c From ERP7__Credentials__c Where ERP7__Active__c =: true And (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize' or Name = 'Stripe') ]){ credList.add(new SelectOptions(crd.Name, crd.Name)); } return credList; }else{ return null; } }
    
    @AuraEnabled
    public static cardDetailWrp cardDetails(String accId,String OrgId){
        cardDetailWrp comW=new cardDetailWrp();
        try{
            List<ERP7__Address__c> addList=[Select Id,Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Country__c,ERP7__City__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where ERP7__Customer__c =:accId and ERP7__Is_Shipping_Address__c=true Limit 1];
            if(addList.size() > 0) comW.shipAdd=addList[0]; else comW.errorMsg='Shipping Address not found for selected Customer.';
            Schema.DescribeFieldResult fieldResultCardtype= ERP7__Payment_Method__c.ERP7__CardType__c.getDescribe();
            List < Schema.PicklistEntry > cardtype = fieldResultCardtype.getPicklistValues();
            for(Schema.PicklistEntry f: cardtype) {
                comW.CardTypes.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            comW.ExpiryMonth.add(new SelectOptions('01','01'));
            comW.ExpiryMonth.add(new SelectOptions('02','02'));
            comW.ExpiryMonth.add(new SelectOptions('03','03'));
            comW.ExpiryMonth.add(new SelectOptions('04','04'));
            comW.ExpiryMonth.add(new SelectOptions('05','05'));
            comW.ExpiryMonth.add(new SelectOptions('06','06'));
            comW.ExpiryMonth.add(new SelectOptions('07','07'));
            comW.ExpiryMonth.add(new SelectOptions('08','08'));
            comW.ExpiryMonth.add(new SelectOptions('09','09'));
            comW.ExpiryMonth.add(new SelectOptions('10','10'));
            comW.ExpiryMonth.add(new SelectOptions('11','11'));
            comW.ExpiryMonth.add(new SelectOptions('12','12'));
            Integer curMonth = system.today().year();
            for(integer i=1;i<10;i++){
                comW.ExpiryYear.add(new SelectOptions(curMonth + '',curMonth++ + ''));
            }
            
            Schema.DescribeFieldResult fieldResultCntry = ERP7__Address__c.ERP7__Country__c.getDescribe();
            List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
            for(Schema.PicklistEntry f: cntry) {
                comW.CountryList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            
            comW.CountyList.add(new SelectOptions('--None--', ''));
            Schema.DescribeFieldResult fieldResultCnty = ERP7__Address__c.ERP7__State__c.getDescribe();
            List < Schema.PicklistEntry > cnty = fieldResultCnty.getPicklistValues();
            for(Schema.PicklistEntry f: cnty) {
                comW.CountyList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            
            comW.isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(comW.isMultiCurrency)  comW.orderCurrency  = (String)Database.query('SELECT CurrencyIsoCode FROM Account where Id=:OrgId Limit 1')[0].get('CurrencyIsoCode');  }catch(Exception ex){comW.errorMsg=ex.getMessage()+' Line Number:'+ex.getLineNumber();}
        
        
        return comW;
    }
    
    public class cardDetailWrp{
        @AuraEnabled public List<selectOptions> CountryList                          { get; Set; }
        @AuraEnabled public List<selectOptions> CountyList                           { get; Set; }
        @AuraEnabled public List<selectOptions> CardTypes                            { get; Set; }
        @AuraEnabled public List<selectOptions> ExpiryMonth                          { get; Set; }
        @AuraEnabled public List<selectOptions> ExpiryYear                           { get; Set; }
        @AuraEnabled public ERP7__Address__c shipAdd                                 { get; Set; }
        @AuraEnabled public boolean isMultiCurrency                                  { get; Set; } @AuraEnabled public String orderCurrency                                     { get; set; }
        @AuraEnabled public String errorMsg                                          { get; set; }
        @AuraEnabled public ERP7__Payment__c payment                                 { get; Set; }
        @AuraEnabled public String navigateURL                                 { get; Set; }
        public cardDetailWrp(){
            CountryList = new List < selectOptions > ();
            CountyList = new List < selectOptions > ();
            CardTypes = new List < selectOptions > ();
            ExpiryMonth = new List < selectOptions > ();
            ExpiryYear = new List < selectOptions > ();
            shipAdd = new ERP7__Address__c();
            isMultiCurrency=false;
            errorMsg='';
            navigateURL = '';
            payment=new ERP7__Payment__c();
        }        
    }
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; } @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) { label = lab;  value = val; } public selectOptions(String lab, string val, Boolean sel) { label = lab; value = val; selected = sel; }
    }
    
    @AuraEnabled public static String response_1                    { get; set; } @AuraEnabled public static String resStatus                     { get; set; }
    
    @AuraEnabled
    public static cardDetailWrp cardPaymentUpdate(String customer,string billingAdd1,String payment,String paymentMode,Boolean post,String RType,String appliedList,String PaymentMethod1,String cvvs,String orgId, String payGate){
        ERP7__Address__c billingAdd = (ERP7__Address__c) JSON.deserialize(billingAdd1, ERP7__Address__c .class);
        cardDetailWrp pay=new cardDetailWrp();
        try{
            pay.errorMsg='';
            List<ERP7__Payment_Applied_on_Invoice__c> appliedPayments = (List<ERP7__Payment_Applied_on_Invoice__c>)JSON.deserialize(appliedList, List<ERP7__Payment_Applied_on_Invoice__c>.class);
            
            ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethod1, ERP7__Payment_Method__c .class);
            
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account_Holder_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account_Holder_Name__c.isUpdateable()) payments.ERP7__Account_Holder_Name__c = PaymentMethod.ERP7__Name_on_Card__c;
            
            Id RT;
            if(RType == 'Customer Payment' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId(); 
            if(RType == 'Debit_Note_Payments' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Debit_Note_Payments').getRecordTypeId();
           
            if(RType=='Customer Payment'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Customer Payment';
                                         }
            if(RType == 'Debit_Note_Payments'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Debit Payment';
                                              }
            
            if( RType != 'Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='InvoicePayment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=post;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c=paymentMode;
            if(paymentMode=='Credit' && RType!='Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='CreditPayment';
            
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP) && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable()) payments.RecordTypeId = rTypeP; 
            
            ERP7__Credentials__c paypalSetup;
            String paymentGate = '%'+payGate+'%';
            system.debug('paymentGate-->'+paymentGate);
            if(Schema.sObjectType.Credentials__c.isAccessible()) {
                if(orgId != '' && orgId != null){
                    for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name Like :paymentGate) AND //
                                              ERP7__Channel_Id__c =: orgId
                                              Limit 1])
                    paypalSetup=crd;
                }else{
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name Like :paymentGate) AND //
                                              ERP7__Channel_Id__c =: orgId
                                              Limit 1])
                    paypalSetup=crd;
                }
                /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal') AND //
                               ERP7__Channel_Id__c =: currentSalesorder.ERP7__Channel__c
                               Limit 1];*/
                
                if(paypalSetup == null){
                    for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                                  From ERP7__Credentials__c
                                                  Where ERP7__Active__c =: true And
                                                  (Name Like :paymentGate)
                                                  Limit 1])
                    paypalSetup=crd;
                    /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];*/
                }
                //if(paypalSetup == null){ ErrorMsgPayment='Paymnet Credential Setup is not completed.';return ErrorMsgPayment;}
                
            }
            
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable()) { payments.First_Name__c= FirstName=PaymentMethod.ERP7__Name_on_Card__c; } 
            //if(Schema.sObjectType.Payment__c.Fields.ERP7__Last_Name__c.isAccessible() && payments.ERP7__Last_Name__c!=null) LastName=payments.ERP7__Last_Name__c;
            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable()) { payments.Address_Line1__c=Address_Line1 = billingAdd.ERP7__Address_Line1__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable()) { payments.Address_Line2__c=Address_Line2 = billingAdd.ERP7__Address_Line2__c; } else{ }       
            if(Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable()) { payments.City__c=City = billingAdd.ERP7__City__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable()) { payments.State__c=State = billingAdd.ERP7__State__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable()) { payments.Country__c=Country = billingAdd.ERP7__Country__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable()) { payments.Zipcode__c=Zipcode = billingAdd.ERP7__Postal_Code__c;} else{ }
            
            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            
            //if(isMultiCurrency) myCur = (String)Database.query('SELECT CurrencyIsoCode FROM ERP7__Invoice__c where ERP7__Account__c=:accId AND ERP7__Organisation__c=:orgId Limit 1')[0].get('CurrencyIsoCode');
            if(isMultiCurrency) myCur = (String)Database.query('SELECT CurrencyIsoCode FROM Account where Id=:orgId Limit 1')[0].get('CurrencyIsoCode');
            else myCur = UserInfo.getDefaultCurrency();
            
            myCurrency = myCur;  
            if(payments.Total_Amount__c != Null) Amount = String.valueof(payments.Total_Amount__c);
            
            
            if(paypalSetup.Name == 'Authorize.Net' || paypalSetup.Name == 'Authorize'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                string url = paypalSetup.ERP7__URL__c;
                String Expiration = Expiry_Month + Expiry_Year;
                
                String Address = billingAdd.ERP7__Address_Line1__c +' '+ billingAdd.ERP7__Address_Line2__c; 
                string expiryDate = Expiry_Year + '-' + Expiry_Month;
                /*'###name: '+paypalSetup.Username_Login__c.escapeXml());
'###transactionKey: '+paypalSetup.Password_Transkey__c.escapeXml());
'###address: '+address);
'###state: '+State);
'###email: '+email);
'###city: '+city);
'###country: '+country);
'###zipcode: '+Zipcode);
'###expiryDate: '+expiryDate);*/
                
                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                soapXML += '<merchantAuthentication>';
                soapXML += '<name>' + paypalSetup.Username_Login__c.escapeXml() + '</name>';
                soapXML += '<transactionKey>' + paypalSetup.Password_Transkey__c.escapeXml() + '</transactionKey>';
                soapXML += '</merchantAuthentication>';
                soapXML += '<transactionRequest>'; 
                soapXML += '<transactionType>authCaptureTransaction</transactionType>';
                soapXML += '<amount>' + Amount.escapeXml() + '</amount>';
                soapXML += '<payment>';
                soapXML += '<creditCard>';
                soapXML += '<cardNumber>' + Card_Number.escapeXml() + '</cardNumber>';
                soapXML += '<expirationDate>' + expiryDate.escapeXml() + '</expirationDate>';
                soapXML += '<cardCode>' + cvvs.escapeXml() + '</cardCode>';
                soapXML += '</creditCard>';
                soapXML += '</payment>';
                soapXML += '<billTo>';
                soapXML += '<firstName>' + FirstName.escapeXml() + '</firstName>'; 
                soapXML += '<lastName>' + LastName.escapeXml() + '</lastName>';
                soapXML += '<address>' + address.escapeXml() + '</address>';
                soapXML += '<city>' + billingAdd.ERP7__City__c.escapeXml() + '</city>';
                soapXML += '<state>' + billingAdd.ERP7__State__c.escapeXml() + '</state>';
                soapXML += '<zip>' + billingAdd.ERP7__Postal_Code__c.escapeXml() + '</zip>';
                soapXML += '<country>' + billingAdd.ERP7__Country__c.escapeXml() + '</country>';
                soapXML += '</billTo>';
                soapXML += '</transactionRequest>';
                soapXML += '</createTransactionRequest>';
                
                HttpRequest reqr = new HttpRequest();
                Http hr = new Http();
                
                reqr.setBody(soapXML);   
                reqr.setMethod('POST');
                reqr.setEndpoint(url);
                reqr.setHeader('Content-length', '2000');
                reqr.setHeader('Content-Type', 'text/xml');
                
                if(Test.isRunningTest()){
                    response_1 = System.label.recordPaymant;
                } else{ HttpResponse resr = hr.send(reqr);     response_1 = soapXML;   response_1 = resr.getBody();   resStatus = resr.getStatus(); /*'--- response_1 : ' +response_1*/ }
                
                if (response_1 != null) {
                    string resultCode = response_1.substringBetween('<resultCode>', '</resultCode>');
                    string responseCode = response_1.substringBetween('<responseCode>', '</responseCode>');
                    
                    if (resultCode == 'Ok') {
                        if (responseCode == '1'){
                            /*--- Inside Approved.*/
                            string description = response_1.substringBetween('<description>', '</description>');
                            transId = response_1.substringBetween('<transId>', '</transId>');
                            string transHash = response_1.substringBetween('<transHash>', '</transHash>');
                            
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable()) payments.Transaction_ID__c = transId;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable()) payments.Transaction_Status__c = 'Approved';
                            if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) payments.sError__c = description;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable())  payments.ERP7__Status__c = 'Paid';                                
                        }
                        
                        if (responseCode == '2'){
                            /*'--- Inside Declined.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');                            
                            if (errors != null) errorMessage += errorText;  else errorMessage += Text;                            
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable()) payments.Transaction_ID__c = transId; if(Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable()) payments.Transaction_Status__c = 'Declined'; if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) payments.sError__c = errorMessage;                            
                        }
                        
                        if (responseCode == '4'){
                            /*'--- Inside Held for Review.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable()) payments.Transaction_ID__c = transId; if(Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable()) payments.Transaction_Status__c = 'Held for Review'; if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) payments.sError__c = description;                            
                        }
                        
                    }else {
                        if (responseCode == '3'){
                            /*'--- Inside Error.'*/
                            string description = response_1.substringBetween('<description>', '</description>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');                            
                            if (errors != null) errorMessage += errorText; else errorMessage += Text;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable()) payments.Transaction_Status__c = 'Error'; if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) payments.sError__c = errorMessage;
                            
                        }
                    } 
                } else payments.sError__c = 'Null Response.';  
                
               if(Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isUpdateable()) payments.Payment_Gateway__c = 'Authorize.Net';
                
            } 
            else if(paypalSetup.Name.contains('Stripe')){
                system.debug('Stripe Called');
                system.debug('billingAdd-->'+billingAdd);
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payments.Payment_Gateway__c = 'Stripe'; }
                String surl = 'type=card&billing_details[name]='+FirstName+' '+LastName+'&billing_details[address][city]='+billingAdd.ERP7__City__c+'&billing_details[address][line1]='+billingAdd.ERP7__Address_Line1__c+'&billing_details[address][line2]='+billingAdd.ERP7__Address_Line2__c+'&billing_details[address][postal_code]='+billingAdd.ERP7__Postal_Code__c+'&billing_details[address][state]='+billingAdd.ERP7__State__c+'&card[exp_month]='+Expiry_Month+'&card[exp_year]='+Expiry_Year+'&card[number]='+Card_Number+'&card[cvc]='+CVVV;
                String srequestEndPoint = 'https://api.stripe.com/v1/payment_methods'; 
                HttpRequest sreq = new HttpRequest(); 
                sreq.setEndpoint(srequestEndPoint);  
                sreq.setMethod('POST');    
                sreq.setTimeout(2000); 
                sreq.setHeader('Content-Type','application/x-www-form-urlencoded');
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                system.debug('paypalSetup.Username_Login__c-->'+paypalSetup.Username_Login__c);
                system.debug('paypalSetup.Password_Transkey__c-->'+paypalSetup.Password_Transkey__c);
                String strToken = paypalSetup.Username_Login__c + paypalSetup.Password_Transkey__c;
                String token = 'Bearer '+ strToken;
                sreq.setHeader('Authorization',token);  
                sreq.setBody(surl);
                Http shttp = new Http(); 
                httpResponse sresponse=shttp.send(sreq); 
                String response_1 = sresponse.getBody(); 
                system.debug('Code-->'+sresponse.getBody());
                if (sresponse.getStatus() == 'Ok') {
                    Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
                    system.debug('results-->'+results);
                    system.debug('Payment Id-->'+results.get('id'));
                    String s1url = 'confirm=true&amount='+Integer.valueOf(payments.Total_Amount__c*100)+'&currency='+myCurrency+'&payment_method='+results.get('id');
                    system.debug('surl-->'+s1url);
                    //String url = 'card[exp_month]=12&card[exp_year]=2024&card[number]=4242424242424242&card[cvc]=222&card[name]=Sam Jaba&amount=20&currency=USD&payment_method_types=[card]&description=Test&message=testing';
                    String s1requestEndPoint = 'https://api.stripe.com/v1/payment_intents'; 
                    HttpRequest S1req = new HttpRequest(); 
                    S1req.setEndpoint(s1requestEndPoint);  
                    S1req.setMethod('POST');    
                    S1req.setTimeout(20000); 
                    S1req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
                    String str1Token = System.label.Stripe_Token;
                    system.debug('str1Token-->'+str1Token);
                    String strToken2 = paypalSetup.Username_Login__c + paypalSetup.Password_Transkey__c;
                    system.debug('strToken2-->'+strToken2);
                    String token1 = 'Bearer '+ strToken2;
                    S1req.setHeader('Authorization',token1);  
                    S1req.setBody(s1url);
                    Http http1 = new Http(); 
                    httpResponse response1=http1.send(S1req); 
                    String response_12 = response1.getBody(); 
                    Map<String,Object> results1=(Map<String,Object>)JSON.deserializeUntyped(response_12); 
                    system.debug('results-->'+results1);
                    if(results1.get('status') == 'succeeded'){
                    if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                        payments.Transaction_Status__c = 'Approved';
                    }
                    if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                        payments.Status__c = 'Paid';
                    } 
                    if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                        payments.Transaction_ID__c = String.valueOf(results1.get('id'));
                    }
                    }else{
                        payments.sError__c  = 'Transaction Failed';
                    }
                }else{
                    payments.sError__c = 'Transaction Failed';
                }
            } 
            else
                pay.errorMsg = 'Please setup the payment terminal';
            
            if(payments.Transaction_Status__c == 'Completed' || payments.Transaction_Status__c == 'SuccessWithWarning' || payments.Transaction_Status__c == 'Success' || payments.Transaction_Status__c == 'Approved'){
                /* '*** Inside Status.'*/
                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c = 'Debit';
                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c = 'Card';
                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Date__c.isUpdateable()) payments.ERP7__Payment_Date__c=System.today();
                
                
                if(RType =='Customer Payment' || RType == 'Debit_Note_Payments' ){
                    /*'upserting payments'*/
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments;} else{ pay.errorMsg =  'Not allowed to upsert payment'; }    
                    
                    ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Name.isUpdateable()) payments.Name=payName.Name;
                }else{
                    ERP7__Invoice__c INV=new ERP7__Invoice__c();
                    
                    if(appliedPayments.size()>0){
                        INV=[Select id,ERP7__Organisation__c,RecordType.DeveloperName, RecordTypeId,ERP7__Amount_Paid__c from ERP7__Invoice__c where id=:appliedPayments[0].ERP7__Invoice__c limit  1 ];
                        orgId=INV.ERP7__Organisation__c;
                        if(INV.RecordType.DeveloperName=='On_Account_Payment'){ if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable())  payments.ERP7__Type__c='Credit'; if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='CreditPayment'; }
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()) payments.ERP7__Account__c=INV.ERP7__Organisation__c;
                    }
                    if(appliedPayments.size()==1){
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable()) payments.ERP7__Invoice__c=appliedPayments[0].ERP7__Invoice__c;
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable()) payments.ERP7__Sales_Order__c=[Select Id,ERP7__Order__c from ERP7__Invoice__c where Id =:appliedPayments[0].ERP7__Invoice__c].ERP7__Order__c;
                        if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments; } else{ pay.errorMsg = 'Not allowed to upsert Payment';}
                        ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isUpdateable()) payments.Name=payName.Name;
                        
                    }else{
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){ upsert payments;   } else{ pay.errorMsg = 'Not allowed to upsert Payment';}
                        ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isUpdateable()) payments.Name=payName.Name;
                        
                        for(Integer i=0;i<appliedPayments.size();i++) if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isUpdateable()) appliedPayments[i].ERP7__Payment__c = payments.id;
                       if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isUpdateable()) { upsert appliedPayments; } else{ pay.errorMsg = 'Not allowed to upsert appliedPayments'; }
                        
                    }
                }
            } else { 
                if(payments.sError__c != Null) pay.errorMsg = payments.sError__c;
            }
            
            pay.payment=payments;
            
        }catch(Exception ex){pay.errorMsg=ex.getMessage()+' Line Number:'+ex.getLineNumber();}
        
        
        return pay;        
    }
    
    @AuraEnabled
    public static cardDetailWrp cardPaymentUpdateStripe(String customer,string billingAdd1,String payment,String paymentMode,Boolean post,String RType,String appliedList,String PaymentMethod1,String cvvs,String orgId, String invId){
        ERP7__Address__c billingAdd = (ERP7__Address__c) JSON.deserialize(billingAdd1, ERP7__Address__c .class);
        cardDetailWrp pay=new cardDetailWrp();
        String Url = '';
        try{
            pay.errorMsg='';
            List<ERP7__Payment_Applied_on_Invoice__c> appliedPayments = (List<ERP7__Payment_Applied_on_Invoice__c>)JSON.deserialize(appliedList, List<ERP7__Payment_Applied_on_Invoice__c>.class);
            
            ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethod1, ERP7__Payment_Method__c .class);
            
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account_Holder_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account_Holder_Name__c.isUpdateable()) payments.ERP7__Account_Holder_Name__c = PaymentMethod.ERP7__Name_on_Card__c;
            
            Id RT;
            if(RType == 'Customer Payment' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId(); 
            if(RType == 'Debit_Note_Payments' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Debit_Note_Payments').getRecordTypeId();
           
            if(RType=='Customer Payment'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Customer Payment';
                                         }
            if(RType == 'Debit_Note_Payments'){ if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Debit Payment';
                                              }
            
            if( RType != 'Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='InvoicePayment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=post;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c=paymentMode;
            if(paymentMode=='Credit' && RType!='Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='CreditPayment';
            
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP) && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable()) payments.RecordTypeId = rTypeP; 
            String paymentGate = '%Stripe%';
            ERP7__Credentials__c paypalSetup;
            if(orgId != '' && orgId != null){
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name Like :paymentGate) AND //
                                              ERP7__Channel_Id__c =: orgId
                                              Limit 1])
                    paypalSetup=crd;
            }
            if(paypalSetup == null){
                paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name Like :paymentGate)
                               Limit 1];
            }
            
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable()) { payments.First_Name__c= FirstName=PaymentMethod.ERP7__Name_on_Card__c; } 
            //if(Schema.sObjectType.Payment__c.Fields.ERP7__Last_Name__c.isAccessible() && payments.ERP7__Last_Name__c!=null) LastName=payments.ERP7__Last_Name__c;
            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable()) { payments.Address_Line1__c=Address_Line1 = billingAdd.ERP7__Address_Line1__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable()) { payments.Address_Line2__c=Address_Line2 = billingAdd.ERP7__Address_Line2__c; } else{ }       
            if(Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable()) { payments.City__c=City = billingAdd.ERP7__City__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable()) { payments.State__c=State = billingAdd.ERP7__State__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable()) { payments.Country__c=Country = billingAdd.ERP7__Country__c;} else{ }
            if(Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable()) { payments.Zipcode__c=Zipcode = billingAdd.ERP7__Postal_Code__c;} else{ }
            
            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            
            //if(isMultiCurrency) myCur = (String)Database.query('SELECT CurrencyIsoCode FROM ERP7__Invoice__c where ERP7__Account__c=:accId AND ERP7__Organisation__c=:orgId Limit 1')[0].get('CurrencyIsoCode');
            if(isMultiCurrency) myCur = (String)Database.query('SELECT CurrencyIsoCode FROM Account where Id=:orgId Limit 1')[0].get('CurrencyIsoCode');
            else myCur = UserInfo.getDefaultCurrency();
            
            myCurrency = myCur;  
            if(payments.Total_Amount__c != Null) Amount = String.valueof(payments.Total_Amount__c);
            
            
            if(paypalSetup.Name.contains('Stripe')){
                system.debug('Stripe Called');
                String navigateUrl = '';
                navigateUrl = System.Label.NavigatetoReceivable+invId;
                //navigateUrl = navigateUrl + 'SON='+currentSalesorder.Name;
                //String surl = 'type=card'+'&billing_details[address][city]='+billingAddress.ERP7__City__c+'&billing_details[address][country]='+'CA'+'&billing_details[address][line1]='+billingAddress.ERP7__Address_Line1__c+'&billing_details[address][line2]='+billingAddress.ERP7__Address_Line2__c+'&billing_details[address][postal_code]='+billingAddress.ERP7__Postal_Code__c+'&billing_details[address][state]='+billingAddress.ERP7__State__c+'&card[exp_month]='+Expiry_Month+'&card[exp_year]='+Expiry_Year+'&card[number]='+Card_Number+'&card[cvc]='+CVV;
                String url2 = 'cancel_url='+ navigateUrl+'&success_url='+navigateUrl+'&line_items[0][price_data][currency]='+myCurrency+'&line_items[0][price_data][product_data][name]='+'Aqxolt ERP'+'&line_items[0][price_data][unit_amount]='+Integer.valueOf(payments.Total_Amount__c*100)+'&line_items[0][quantity]='+1+'&mode='+'payment';
                String srequestEndPoint = 'https://api.stripe.com/v1/checkout/sessions'; 
                HttpRequest sreq = new HttpRequest(); 
                sreq.setEndpoint(srequestEndPoint);  
                sreq.setMethod('POST');    
                sreq.setTimeout(2000); 
                sreq.setHeader('Content-Type','application/x-www-form-urlencoded');
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                system.debug('paypalSetup.Username_Login__c-->'+paypalSetup.Username_Login__c);
                system.debug('paypalSetup.Password_Transkey__c-->'+paypalSetup.Password_Transkey__c);
                String strToken = paypalSetup.Username_Login__c + paypalSetup.Password_Transkey__c;
                String token = 'Bearer '+ strToken;
                sreq.setHeader('Authorization',token);  
                sreq.setBody(url2);
                Http shttp = new Http(); 
                httpResponse sresponse=shttp.send(sreq); 
                String response_1 = sresponse.getBody(); 
                system.debug('Code-->'+sresponse.getStatus());
                if (sresponse.getStatus() == 'Ok') {
                    Map<String,Object> results1=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
                    if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                        payments.Transaction_Status__c = 'Approved';
                    }
                    if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                        payments.Status__c = 'Paid';
                    } 
                    if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                        payments.ERP7__Stripe_Payment_Link__c= String.valueOf(results1.get('url'));
                        Url = String.valueOf(results1.get('url'));
                    }
                }else{
                    payments.sError__c = 'Transaction Failed';
                }
            }
            else
                pay.errorMsg = 'Please setup the payment terminal';
            
            if(payments.Transaction_Status__c == 'Completed' || payments.Transaction_Status__c == 'SuccessWithWarning' || payments.Transaction_Status__c == 'Success' || payments.Transaction_Status__c == 'Approved'){
                /* '*** Inside Status.'*/
                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c = 'Debit';
                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c = 'Card';
                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Date__c.isUpdateable()) payments.ERP7__Payment_Date__c=System.today();
                
                
                if(RType =='Customer Payment' || RType == 'Debit_Note_Payments' ){
                    /*'upserting payments'*/
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments;} else{ pay.errorMsg =  'Not allowed to upsert payment'; }    
                    
                    ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Name.isUpdateable()) payments.Name=payName.Name;
                }else{
                    ERP7__Invoice__c INV=new ERP7__Invoice__c();
                    
                    if(appliedPayments.size()>0){
                        INV=[Select id,ERP7__Organisation__c,RecordType.DeveloperName, RecordTypeId,ERP7__Amount_Paid__c from ERP7__Invoice__c where id=:appliedPayments[0].ERP7__Invoice__c limit  1 ];
                        orgId=INV.ERP7__Organisation__c;
                        if(INV.RecordType.DeveloperName=='On_Account_Payment'){ if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable())  payments.ERP7__Type__c='Credit'; if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='CreditPayment'; }
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()) payments.ERP7__Account__c=INV.ERP7__Organisation__c;
                    }
                    if(appliedPayments.size()==1){
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable()) payments.ERP7__Invoice__c=appliedPayments[0].ERP7__Invoice__c;
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable()) payments.ERP7__Sales_Order__c=[Select Id,ERP7__Order__c from ERP7__Invoice__c where Id =:appliedPayments[0].ERP7__Invoice__c].ERP7__Order__c;
                        if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments; } else{ pay.errorMsg = 'Not allowed to upsert Payment';}
                        ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isUpdateable()) payments.Name=payName.Name;
                        
                    }else{
                        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){ upsert payments;   } else{ pay.errorMsg = 'Not allowed to upsert Payment';}
                        ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.Name.isUpdateable()) payments.Name=payName.Name;
                        
                        for(Integer i=0;i<appliedPayments.size();i++) if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isUpdateable()) appliedPayments[i].ERP7__Payment__c = payments.id;
                       if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isUpdateable()) { upsert appliedPayments; } else{ pay.errorMsg = 'Not allowed to upsert appliedPayments'; }
                        
                    }
                }
            } else { 
                if(payments.sError__c != Null) pay.errorMsg = payments.sError__c;
            }
            if(payments.sError__c == Null) pay.navigateURL = URL;
            pay.payment=payments;
            
        }catch(Exception ex){pay.errorMsg=ex.getMessage()+' Line Number:'+ex.getLineNumber();}
        
        
        return pay;        
    }
    
    
    @AuraEnabled
    public static Map<String,Object> saveRefundPay(String payment, String accId, String RType, String PM, Boolean post){
        Map<String,Object> returnValue = new Map<String,Object>();
        ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
        if(payments.ERP7__Account__c==null && accId!=null && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){  payments.ERP7__Account__c = (String) Database.Query('SELECT ERP7__Organisation__c FROM Account WHERE id =: accId')[0].get('ERP7__Organisation__c');  }
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
        Id RT;
        
        RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Refund').getRecordTypeId();
        payments.RecordTypeId=RT;
        /*if(RType == 'Customer Payment' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId(); 
        if(RType == 'Debit_Note_Payments' )RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Debit_Note_Payments').getRecordTypeId();
        
        if(RType=='Customer Payment'){ 
            if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Customer Payment';
                                     }
        if(RType == 'Debit_Note_Payments'){ 
            if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable() && RT != null) payments.RecordTypeId=RT; payments.ERP7__Transaction_Type__c='Debit Payment';
        }
        RT= Schema.SObjectType.ERP7__Payment__c.getRecordTypeInfosByDeveloperName().get('Customer_Payment').getRecordTypeId();*/ 
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Debit';
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payments.ERP7__Status__c='Paid';
        if( Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='RefundPay';
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=post;
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c=PM;
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isUpdateable()) payments.ERP7__Payment_Gateway__c = PM;
        //if(PM=='Credit' && RType!='Customer Payment' && RType != 'Debit_Note_Payments' && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable())payments.ERP7__Transaction_Type__c='CreditPayment';
        if(RType =='Customer Payment' || RType == 'Debit_Note_Payments' ){
            if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert payments;} else{returnValue.put('error', 'Not allowed to upsert payment'); }
            ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
            returnValue.put('pay', payName); 
            returnValue.put('payments',payments);
        }
        return returnValue;
    }
    
    @AuraEnabled
    public static void updatePaymentCreditNotes(List<CNWrapper> cnList, String payId, String payName){ List<ERP7__Credit_Note_Applied_on_Invoice__c> appliedNotes = new List<ERP7__Credit_Note_Applied_on_Invoice__c>(); List<ERP7__Credit_Note__c> cn2Update = new List<ERP7__Credit_Note__c>(); if(cnList!=null && cnList.size()>0) { for(CNWrapper cwrap : cnList){ system.debug('cwrap-->'+cwrap); if(cwrap!=null){ if(cwrap.debitAmount>0){ ERP7__Credit_Note_Applied_on_Invoice__c capplied = new ERP7__Credit_Note_Applied_on_Invoice__c(); capplied.ERP7__Amount__c = cwrap.debitAmount; capplied.ERP7__Credit_Note__c = cwrap.credNote.Id; capplied.ERP7__Payment__c = payId; capplied.Name = payName + ' ' + cwrap.credNote.Name; appliedNotes.add(capplied); if(cwrap.credNote.ERP7__Debit__c!=null) cwrap.credNote.ERP7__Debit__c = cwrap.credNote.ERP7__Debit__c + cwrap.debitAmount; else cwrap.credNote.ERP7__Debit__c = cwrap.debitAmount; cwrap.credNote.ERP7__Paid_Date__c = system.today(); cn2Update.add(cwrap.credNote); } } } } if(appliedNotes.size()>0) upsert appliedNotes; if(cn2Update.size()>0)  { PreventRecursiveLedgerEntry.testCasesTransactions = true; update cn2Update; } }
}