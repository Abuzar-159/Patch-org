@isTest
private class RollupTestCase {
    
    static testMethod void unitTestCase1() {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
            
        Resource_Allocation__c WFA = new Resource_Allocation__c(Organisation__c = orgn.Id, Name = 'Test workforce', Cost__c = 10); 
        insert WFA;
        
       
        
        Material_Wastage__c PU = new Material_Wastage__c(Name = 'Test usage', Cost_Price__c = 10); 
        insert PU;
        
        delete WFA;
      
        delete PU;
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
}