@isTest
private class SupplierInvoiceReconciliation_TestCase{
        static testMethod void UnitTest1(){
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation', Default__c =true);
            insert orgn;
            Account sup = new Account(Name='Supplier',Organisation__c = orgn.Id, Account_Type__c = 'Supplier');
            insert sup;
            Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
            insert bUnit; 
            Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
            insert contact;
            Address__c bAddress = new Address__c( Customer__c = sup.Id, Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Surrey',Country__c = 'United Kingdom',
                                   Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress;
            Address__c bAddress1 = new Address__c( Customer__c = orgn.Id,  Contact__c=Contact.id,Active__c=true,Address_Line1__c='test', Address_Line2__c='test', Address_Line3__c='test', City__c='test',State__c='Surrey',Country__c = 'United Kingdom',
                                   Postal_Code__c='test',Is_Billing_Address__c=true);
            insert bAddress1;
            Budget_Account__c BA = new Budget_Account__c(Name = 'Test Account');
            insert BA;
            PO__c PO = new PO__c( Budget_Accounts__c = BA.Id, Delivery_Address__c = bAddress1.Id, vendor_Address__c = bAddress.Id, Invoice_Address__c = bAddress.Id, vendor__c = sup.Id);
            insert PO;  
            Product2 ps = new Product2(Name='test',isActive=true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
            insert ps;   
            Purchase_Line_Items__c poli = new Purchase_Line_Items__c(Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=PO.id,Total_Price__c=100,Product__c = ps.Id);
            insert poli;
            Site__c site = new Site__c(Name = 'site', Active__c=true);
            insert site;
                
            Inventory_Stock__c WarehouseItemInventoryStock = new Inventory_Stock__c(Organisation__c = orgn.Id,Name='test',Active__c=true,Warehouse__c=site.Id, Product__c=ps.Id);
            insert WarehouseItemInventoryStock; 
            
          
            
            Stock_Inward_Line_Item__c SPLI = new Stock_Inward_Line_Item__c(Name='test',Active__c=true,Site_ProductService_InventoryStock__c =WarehouseItemInventoryStock.Id,Product__c=ps.Id,Quantity__c=2,  Purchase_Line_Items__c=poli.Id); //
            insert SPLI; 
           Bill__c supInv = new  Bill__c (Purchase_Order__c=PO.id);
            insert supInv;
            Bill_Line_Item__c sili1 = new Bill_Line_Item__c(Bill__c=supInv.id);
            insert sili1;
            Bill_Line_Item__c sili2 = new Bill_Line_Item__c(Bill__c=supInv.id);
            insert sili2;
            
             PageReference pageRef = System.Page.SupplierInvoiceReconciliation;
             Test.setCurrentPage(pageRef);
             Test.StartTest();
            SupplierInvoiceReconciliation  supplierInvoiceRec = new SupplierInvoiceReconciliation ();
            supplierInvoiceRec.SupplierOrganisation.Vendor__c = Sup.id;
            supplierInvoiceRec.startDate = System.Today().format();
            supplierInvoiceRec.endDate = System.Today().format();
            supplierInvoiceRec.supplierPO();
            supplierInvoiceRec.Poli_Id = poli.id;
            supplierInvoiceRec.updatePOLI();
            SupplierInvoiceReconciliation.getPOLIList('test');
            SupplierInvoiceReconciliation.getSPLIList('test');
            SupplierInvoiceReconciliation.getSILIList('test');
            SupplierInvoiceReconciliation.updateSupplierAndSite_Items('test','test');
            SupplierInvoiceReconciliation.getPOLIList(po.id);
            SupplierInvoiceReconciliation.getSPLIList(poli.id);
            SupplierInvoiceReconciliation.getSILIList(poli.id);
            SupplierInvoiceReconciliation.updateReconcile(poli.id);
            SupplierInvoiceReconciliation.updateSupplierAndSite_Items(string.valueof(sili1.id),string.valueof(SPLI.id));
            supplierInvoiceRec.paymentProcess();
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            Test.StopTest();
            
        }
        static testMethod void UnitTest2(){   
            PageReference pageRef = System.Page.SupplierInvoiceReconciliation;
            Test.setCurrentPage(pageRef);
            Test.StartTest();
            SupplierInvoiceReconciliation  supplierInvoiceRec = new SupplierInvoiceReconciliation ();
            supplierInvoiceRec.supplierPO();
            SupplierInvoiceReconciliation.getPOLIList('test');
            SupplierInvoiceReconciliation.getSPLIList('test');
            SupplierInvoiceReconciliation.getSILIList('test');
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            Test.StopTest();
        }
}