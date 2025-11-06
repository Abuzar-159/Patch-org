trigger ManageCustomRollupSummaries on Finance_General_Ledger__c (before update) {
    List<Id> ledgerIds = new List<Id>();
    
    for(Finance_General_Ledger__c FGL : System.Trigger.New){
        ledgerIds.add(FGL.Id);
    }   
            
    List<Finance_General_Ledger_Entry__c> debitLedgerEntries = [Select Id, Name, Active__c, Category_Type__c, Credit_Entry__c, Debit_Entry__c,
                                                                  Ending_Balance__c, Entry_Description__c, Finance_General_Ledger__c, General_Ledger_Entry_DateTime__c, General_Ledger_Type__c,
                                                                  General_Ledger_Entry_Type__c, Organisation__c, Organisation_Business_Unit__c, Reclaimable_VAT__c,Transactions__c 
                                                                  From Finance_General_Ledger_Entry__c
                                                                  Where Finance_General_Ledger__c In :ledgerIds And
                                                                  General_Ledger_Entry_Type__c = 'Debit'
                                                                  order by CreatedDate Asc];
                                                                      
    List<Finance_General_Ledger_Entry__c> creditLedgerEntries = [Select Id, Name, Active__c, Category_Type__c, Credit_Entry__c, Debit_Entry__c,
                                                                  Ending_Balance__c, Entry_Description__c, Finance_General_Ledger__c, General_Ledger_Entry_DateTime__c, General_Ledger_Type__c,
                                                                  General_Ledger_Entry_Type__c, Organisation__c, Organisation_Business_Unit__c, Reclaimable_VAT__c, Transactions__c 
                                                                  From Finance_General_Ledger_Entry__c
                                                                  Where Finance_General_Ledger__c In :ledgerIds And
                                                                  General_Ledger_Entry_Type__c = 'Credit'
                                                                  order by CreatedDate Asc];
    
    Decimal VatPayableDebit = 0;
    Decimal VatPayableCredit = 0;
    Decimal ReclaimableVat = 0;
                                                                
    for(Finance_General_Ledger_Entry__c DLE : debitLedgerEntries){
        if(DLE.Debit_Entry__c != Null && DLE.General_Ledger_Type__c == 'VAT Payable'){
            VatPayableDebit += DLE.Debit_Entry__c;
        }
    }
    
    for(Finance_General_Ledger_Entry__c CLE : creditLedgerEntries){
        if(CLE.Credit_Entry__c != Null && CLE.General_Ledger_Type__c == 'VAT Payable'){
            VatPayableCredit += CLE.Credit_Entry__c;
            ReclaimableVat += CLE.Reclaimable_VAT__c;
        }
    }
    
    for(Finance_General_Ledger__c FGL : System.Trigger.New){
        FGL.Vat_Payable_Debit__c = VatPayableDebit;
        FGL.Vat_Payable_Credit__c = VatPayableCredit;
        FGL.Reclaimable_VAT__c = ReclaimableVat;
    }
    
}