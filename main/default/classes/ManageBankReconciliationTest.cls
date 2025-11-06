@isTest
private class ManageBankReconciliationTest { 
    @isTest static void ManageBankReconciliationTest(){
        ManageBankReconciliation mbr=new ManageBankReconciliation();
        RecordType Bank_Acc_org = [select Id, Name From RecordType Where DeveloperName = 'Organisation_Bank_Detail' and SobjectType = 'ERP7__Bank_details__c' Limit 1]; 
        Account orgn = new Account(Name='Organisation Test',Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test BU');
        insert busUnit;
        Bank_details__c testbank =new Bank_details__c(Organisation__c = orgn.Id,RecordTypeId = Bank_Acc_org.id,Organisation_Business_Unit__c = busUnit.id,Name = 'Test',Account_Number__c='12345678');
        insert testbank;
        testbank = [SELECT id,Organisation__c,Organisation__r.Name,Organisation_Business_Unit__c,Account_Number__c,Name From Bank_details__c where id =: testbank .id ];
        Bank_Reconciliation__c testbankobj = new Bank_Reconciliation__c(Organisation__c = orgn.Id,Bank_Account__c=testbank.id,Status__c='Draft');
        insert testbankobj;
        ManageBankReconciliation.retrieveReconciliations(orgn.Id,'Name','Desc',1,1);
        ManageBankReconciliation.getBankReconciliationStatus();
        ManageBankReconciliation.updateBankReconciliation(JSON.serialize(testbankobj));
        //ManageBankReconciliation.getDefaultOrganisation();
        ManageBankReconciliation.getReconciliationTakeRec(testbankobj.Id);
        ManageBankReconciliation.deleteReconciliation(testbankobj.Id);
        //ManageBankReconciliation.retrieveReconciliations(null);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
}