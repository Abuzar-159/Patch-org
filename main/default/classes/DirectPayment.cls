public class DirectPayment {
    @AuraEnabled
    public static Map<String,Object> savePayment(String payment,String accId, String ledger, Decimal TaxAmount){
        Map<String,Object> returnValue = new Map<String,Object>();
        try{
            ERP7__Payment__c payments = (ERP7__Payment__c)JSON.deserialize(payment, ERP7__Payment__c.class);
            List<lederClass> ledgerwrap = (List<lederClass>)JSON.deserialize(ledger, List<lederClass>.class);
            List<ERP7__Finance_General_Ledger_Entry__c> ledgerList = new List<ERP7__Finance_General_Ledger_Entry__c>();
            for(lederClass led : ledgerwrap){
                ledgerList.add(led.ledger);
            }
            if(payments.ERP7__Account__c==null && accId!=null && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()){  payments.ERP7__Account__c = (String) Database.Query('SELECT ERP7__Organisation__c FROM Account WHERE id =: accId')[0].get('ERP7__Organisation__c');  }
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payments.ERP7__Amount__c=payments.ERP7__Total_Amount__c;
            
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payments.ERP7__Type__c='Debit';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payments.ERP7__Status__c='Paid';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable()) payments.ERP7__Transaction_Type__c='DirectPayment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) payments.ERP7__Posted__c=false;
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) payments.ERP7__Payment_Type__c='Direct Payment';
            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Gateway__c.isUpdateable()) payments.ERP7__Payment_Gateway__c = 'Direct Payment';
            PreventRecursiveLedgerEntry.proceed = false;
            PreventRecursiveLedgerEntry.Payment = false;
            upsert payments; 
            ERP7__Payment__c payName = [Select id, Name from ERP7__Payment__c where id=:payments.id limit 1]; 
            returnValue.put('pay', payName); 
            returnValue.put('payments',payments);
            
            Transaction__c trans = new Transaction__c();
            if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()){trans.Active__c = true;}else{/*No access*/}
            if(payments.ERP7__Amount__c!=null){ if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = payments.ERP7__Amount__c;}else{/*No access*/} }
            else{ if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c = payments.ERP7__Total_Amount__c;}else{/*No access*/} }
            if(payments.ERP7__Bank_Charges__c >0 ){ if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()){trans.Amount__c += payments.ERP7__Bank_Charges__c;}else{/*No access*/}   }              
            if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()){trans.Transaction_Date__c = (payments.Posted_Date__c != null) ? payments.Posted_Date__c : System.Today();}else{/*No access*/}
            if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()){trans.Transaction_Status__c = 'Completed';}else{/*No access*/}
            if(Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Method__c.isUpdateable()){trans.Transaction_Method__c = payments.ERP7__Payment_Gateway__c;}else{/*No access*/}
            if(payments.ERP7__Debit_Note__c != null){ if(Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Debit_Note__c.isUpdateable()){trans.ERP7__Debit_Note__c = payments.ERP7__Debit_Note__c;}else{/*No access*/}}
            if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()){trans.Transaction_Type__c = payments.ERP7__Transaction_Type__c;}else{/*No access*/} 
            if(Schema.sObjectType.Transaction__c.fields.ERP7__Payment__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.ERP7__Payment__c.isUpdateable()){trans.ERP7__Payment__c = payments.Id;}else{/*No access*/}
            
            if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()){trans.Organisation__c = payments.ERP7__Account__c;}else{/*No access*/}
            upsert trans;
            List < Finance_General_Ledger__c > FinanceGeneralLedgers = [Select Id, Name, Accounting_Period_End_Date__c, Accounting_Period_Start_Date__c, Active__c, Description__c, CreatedDate,
                                                                        Organisation__c, Organisation_Business_Unit__c
                                                                        From Finance_General_Ledger__c
                                                                        Where Active__c = true limit 1
                                                                       ];
            Transaction__c tran = [select Id, Name from Transaction__c where Id=:trans.Id];
            List<ERP7__Finance_General_Ledger_Entry__c> fgltoUpsert = new List<ERP7__Finance_General_Ledger_Entry__c>();
            for(ERP7__Finance_General_Ledger_Entry__c fgl : ledgerList){
                fgl.ERP7__Transactions__c = tran.Id;
                fgl.ERP7__Finance_General_Ledger__c = FinanceGeneralLedgers[0].Id;
                fgltoUpsert.add(fgl);
            }
            ERP7__Finance_General_Ledger_Entry__c fgle = new ERP7__Finance_General_Ledger_Entry__c(ERP7__Finance_General_Ledger__c=FinanceGeneralLedgers[0].Id,ERP7__Credit_Entry__c = payments.ERP7__Total_Amount__c,ERP7__Chart_of_Account__c= payments.ERP7__Payment_Account__c,ERP7__Transactions__c = tran.Id);
            fgltoUpsert.add(fgle);
            system.debug('fgle-->'+fgle);
            if(TaxAmount>0){
                List<ERP7__COA_Mapping__c> coaMap = [select Id, Name, ERP7__Chart_of_Account__c from ERP7__COA_Mapping__c where Name = 'Direct Payment Tax'];
                ERP7__Finance_General_Ledger_Entry__c fgle1 = new ERP7__Finance_General_Ledger_Entry__c(ERP7__Finance_General_Ledger__c=FinanceGeneralLedgers[0].Id,ERP7__Debit_Entry__c = TaxAmount,ERP7__Chart_of_Account__c= coaMap[0].ERP7__Chart_of_Account__c,ERP7__Transactions__c = tran.Id);
                fgltoUpsert.add(fgle1);
            }
            upsert fgltoUpsert;
            
        }catch(Exception ex){  
            returnValue.put('error',ex.getMessage());
            system.debug('Exception-->'+ex+ex.getLineNumber());
        }
        return returnValue;
    }
    
    @AuraEnabled 
    public static Account getDefaultOrganisation(){
        return UtilClass.getOrganisationByLogin_Employee();
    } 
    
    public class lederClass{                   
        @AuraEnabled public ERP7__Finance_General_Ledger_Entry__c ledger            { get; set; }
        @AuraEnabled public Decimal taxAmount            { get; set; }
        public lederClass(){
            taxAmount=0.00;
            ledger=new ERP7__Finance_General_Ledger_Entry__c();
        }
    }
}