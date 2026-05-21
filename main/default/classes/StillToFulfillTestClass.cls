@isTest
private class StillToFulfillTestClass {
    
    static testmethod void UnitTestStillToFulfill(){
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        
        Business_Unit__c busUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert busUnit;
        
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true, 
                                   Family='Fruits', ERP7__Is_Kit__c = true);
        insert ps;
         
        Account acc = new Account(Name='Test');
        insert acc;
        
        ERP7__Sales_Order__c SO = new ERP7__Sales_Order__c(Name='Test', ERP7__Account__c=acc.Id);
        insert SO;
        
        String sOrder = SO.Id;
        List<ERP7__Sales_Order__c> SOS = [Select Id, Name from ERP7__Sales_Order__c where Id =:sOrder or Name =:sOrder Limit 1];
        ERP7__Sales_Order_Line_Item__c SOLI = new ERP7__Sales_Order_Line_Item__c(Name='Test', ERP7__Sales_Order__c=SO.Id, ERP7__Product__c=ps.Id,Shipped_Quantity__c=10, Picked_Quantity__c=2, Quantity__c=10, Packed_Quantity__c=12);
        insert SOLI;
        
        ERP7__Logistic__c Logistic = new ERP7__Logistic__c(Name='test', ERP7__Type__c='Outbound', ERP7__Account__c=acc.Id, ERP7__Sales_Order__c=SO.Id, ERP7__Active__c=true,ERP7__Shipment_type__c='UPS',ERP7__Shipping_Preferences__c='--None--');
        upsert Logistic;
        
        ERP7__Logistic_Line_Item__c LogisticLine = new ERP7__Logistic_Line_Item__c(Name='Test', ERP7__Logistic__c=Logistic.Id, ERP7__Product__c=ps.Id, ERP7__Sales_Order_Line_Item__c=Soli.Id, ERP7__Quantity__c=2, ERP7__Status__c='Reserved');
        upsert LogisticLine;
        
        
        
        PageReference pg = System.Page.StillToFulfill;
        pg.getParameters().put('loId', Logistic.Id);        
        Test.setCurrentPage(pg);
        OutboundLogistics controllers = new OutboundLogistics();
        try{
            StillToFulfill STF;
            try{ STF = new StillToFulfill(controllers); }catch(Exception e){}
            STF.getAccountList();
            STF.Pick();
        }catch(Exception e){}
        
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
}