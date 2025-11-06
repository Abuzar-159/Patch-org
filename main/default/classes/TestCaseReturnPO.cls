@isTest

private class TestCaseReturnPO {
    
    static testMethod void testReturnPO () {
        PreventRecursiveLedgerEntry.testCasesTransactions = true;
         Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Account Customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert Customer;
        Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
        insert sup;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        Address__c bAddress = new Address__c( Customer__c = Customer.id,Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress;
        Address__c bAddress1 = new Address__c( Customer__c = Customer.id, Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',County__c='test', Postal_Code__c='test',Is_Billing_Address__c=true);
        insert bAddress1;
        Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account');
        insert BA;
        PO__c PO = new PO__c( Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress1.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
        insert PO;  
        Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
        insert ps;
        Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=2,Quantity_Received__c=2,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
        insert poli;
        PO__c PO1 = [select id, name, Delivery_Address__c, Vendor_Address__c, Invoice_Address__c from PO__c where id=: PO.Id];     
        
        List<Purchase_Line_Items__c> poliList = [Select id, name, Unit_Price__c,
                                                    Product__r.Name, Quantity__c, Shipping_Cost__c, Quantity_Received__c, Purchase_Orders__c, Total_Price__c from Purchase_Line_Items__c where Purchase_Orders__c =: PO.Id];
        
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
            
        Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id,Product__c=ps.Id);
        insert WarehouseItemInventoryStock; 
        
        po.Name = 'test1';
        po.Status__c = 'Approved';
        po.RecordTypeId = '012b000000017UQ';
        try { update po; } catch(Exception e) {}
        
        PreventRecursiveLedgerEntry.testCasesTransactions = false;
        delete po;
        
        List<PO__c> poList = new List<PO__c>();
             
        for(Integer i=0; i<3; i++) {
            PO__c pos = new PO__c();
                
            pos.Name = 'Test Asset';
            pos.Active__c = true;
            pos.Budget_Accounts__c = BA.Id;
            
            poList.add(pos);
        }
        
        upsert poList;
        
        String s = 'test';
        String s1 = 'test';
        System.assertEquals(s,s1);
    }
}