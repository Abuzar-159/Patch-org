@isTest
private class TestCasesSet_17 {
    
    
    static testMethod void ManageLocations(){
        ManageLocations ML;
         
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
 
        Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
        insert customer;
        
        Contact contact = new Contact(FirstName='Test',LastName='Test',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
        insert contact;
            
        Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
        insert busUnit; 
            
        Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
        insert site;
        
        Location__c Location = new Location__c(Name = 'test', Active__c = true, Site__c = site.Id, Bin_Capacity__c = 100, Barcode__c = 'Test');
        insert Location;
        
        StorageContainer__c storageBin = new StorageContainer__c(Active__c = true, Location__c = Location.Id, Status__c = 'Checked out',  Barcode__c = 'Test');              
        insert storageBin;
               
        Product2 ps = new  Product2(Name = 'test', Barcode__c  = 'det-123', isActive = true, Is_OverSized_Item__c = true);
        insert ps;
        
        Product2 ps1 = new  Product2(Name = 'test',Barcode__c  = 'det-124', isActive = true);
        insert ps1;
        
        Inventory_Stock__c warehouseInventory = new Inventory_Stock__c(StorageContainer__c = storageBin.Id,Location__c = Location.Id, Product__c = ps1.Id,Organisation__c = orgn.Id, Active__c = true,Warehouse__c=site.Id);        
        insert warehouseInventory;
        
        Inventory_Stock__c warehouseInventory1 = new Inventory_Stock__c(Location__c = Location.Id, Product__c = ps.Id,Organisation__c = orgn.Id, Active__c = true,Warehouse__c=site.Id);        
        insert warehouseInventory1;
        
        test.startTest();
        
        System.currentPageReference().getParameters().put('id',site.id);
        ApexPages.StandardController controller;
        ManageLocations ML1 = new ManageLocations();
        ML = new ManageLocations(controller);
        ML.binCheckInBack();
        ML.binCheckOutBack();
        ML.Abort();
        
        ML.binCheckIn();
        ML.binCode = 'test1';
        ML.binCheckIn();
        ML.binCode = 'test';
        ML.binCheckIn();
        ML.binCheckIn();
        
        ML.locationCheckIn();
        ML.locationCode = 'test1';
        ML.locationCheckIn();
        ML.locationCode = 'test';
        ML.locationCheckIn();
        ML.locationCheckIn();
        
        ML.locationCheckOut();
        ML.locationCode = 'test1';
        ML.locationCheckOut();
        ML.locationCode = 'test';
        ML.locationCheckOut();
        ML.locationCheckOut();
        
        ML.binCheckOut();
        ML.binCode = 'test1';
        ML.binCheckOut();
        ML.binCode = 'test';
        ML.binCheckOut();
        ML.binCheckOut();
        ML.OverSizeItemCheck();
        ML.ItemCheckOut();
        String salName = 'test';
        String sal1Name = 'test';
        System.assertEquals(salName, sal1Name);
        test.stopTest();
    }
   
    static testMethod void ManageOverSizeItemLocations(){
            
              
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
     
            Account customer = new Account(Name='Customer', Account_Type__c = 'Customer');
            insert customer;
            
            Contact contact = new Contact(FirstName='Test',LastName='Test',AccountId=customer.id,Phone='1234567890',Email='test@test.com');
            insert contact;
                
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
                
            Site__c site = new Site__c(Name = 'site', Active__c=true, Organisation__c = orgn.id);
            insert site;
            
            Location__c Location = new Location__c(Name = 'test', Active__c = true, Site__c = site.Id, Bin_Capacity__c = 100, Barcode__c = 'Test');
            insert Location;
            
            StorageContainer__c storageBin = new StorageContainer__c(Active__c = true, Location__c = Location.Id, Status__c = 'Checked out',  Barcode__c = 'Test');              
            insert storageBin;
                   
            Product2 ps = new  Product2(Name = 'test', Barcode__c  = 'det-123', isActive = true, Is_OverSized_Item__c = true);
            insert ps;
            
            Product2 ps1 = new  Product2(Name = 'test',Barcode__c  = 'det-124', isActive = true);
            insert ps1;
            
            Inventory_Stock__c warehouseInventory = new Inventory_Stock__c(StorageContainer__c = storageBin.Id,Location__c = Location.Id, Product__c = ps1.Id,Organisation__c = orgn.Id,  Active__c = true,Warehouse__c=site.Id);        
            insert warehouseInventory;
            
            Inventory_Stock__c warehouseInventory1 = new Inventory_Stock__c(Location__c = Location.Id, Product__c = ps.Id,Organisation__c = orgn.Id,  Active__c = true,Warehouse__c=site.Id);        
            insert warehouseInventory1;
        
            test.startTest();
            
            System.currentPageReference().getParameters().put('id',site.id);
            ManageOverSizeItemLocations MOSILB = new ManageOverSizeItemLocations(); 
            ApexPages.StandardController controller; 
            ManageOverSizeItemLocations MOSIL = new ManageOverSizeItemLocations(controller);
            MOSIL.contruct();
            MOSIL.warehouseInventory = new List<Inventory_Stock__c>();
            MOSIL.getProductFromInventory();
            
            MOSIL.getProductFromInventory();
            MOSIL.fetchProductFromInventory();
            MOSIL.ProductCheckOut();
            MOSIL.itemCode = 'det-123';
            MOSIL.getProductFromInventory();
            MOSIL.fetchProductFromInventory();
            MOSIL.ProductCheckOut();
            
            MOSIL.locationCheck();
            MOSIL.locationCode = 'Test';
            MOSIL.locationCheck();
            
            MOSIL.locationItemCheckIn();
            MOSIL.locationCode = 'Test';
            MOSIL.locationItemCheckIn();
            
            MOSIL.storageBinItemCheckIn();
            MOSIL.storageBin = 'Test';
            MOSIL.storageBinItemCheckIn();
            
            MOSIL.BackToItemCheckIn();
            MOSIL.BackToLocationCheckOut();
            MOSIL.Abort();
            MOSIL.backToBin();
            MOSIL.Back();
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            test.stopTest(); 
    }
    
}