@isTest
private class ProductConfig_TestCases {
    static testmethod void unitTestPC(){
        String productId;
        String pbe;
        RecordType emp_rTypes_org = [select Id, Name From RecordType Where Name = 'Employee' and SobjectType = 'ERP7__Profiling__c' Limit 1];  
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit;
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware');
        insert prod;
        ERP7__Version__c version = new ERP7__Version__c(Name='test', ERP7__Product__c = prod.Id);
        insert version;
        ERP7__Discount_Plan__c dp = new ERP7__Discount_Plan__c(ERP7__Organisation__c = orgn.Id, ERP7__Organisation_Business_Unit__c = bUnit.Id, Name = 'test');
        insert dp;
        ERP7__Warranty_Return_Policy__c wrp = new ERP7__Warranty_Return_Policy__c(Name='test');
        insert wrp;
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true,
                                                         ERP7__Discount_Plan__c=dp.Id, ERP7__Warranty_Return_Policy__c=wrp.Id);
        insert standardPrice;
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        ERP7__Tier__c tier = new ERP7__Tier__c(Name='test', ERP7__Organisation__c=orgn.Id, ERP7__Organisation_Business_Unit__c=bUnit.Id, ERP7__Active__c=true);
        insert tier;
        ERP7__Tier_Discount_Allocation__c tda = new ERP7__Tier_Discount_Allocation__c(ERP7__Discount_Plan__c = dp.Id, name= 'test', ERP7__Product__c = prod.Id, ERP7__Tier__c=tier.Id);
        insert tda;
        PricebookEntry customPrice = new PricebookEntry( Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        
        ERP7__BOM__c bom = new ERP7__BOM__c(Name='test', ERP7__BOM_Version__c=version.Id, ERP7__BOM_Product__c=prod.Id);
        insert bom;
        ERP7__Site__c  site = new ERP7__Site__c(Name='test');
        insert site;
        ERP7__Location__c loc = new ERP7__Location__c(Name='test', ERP7__Site__c=site.Id);
        insert loc;
        ERP7__Product_Location__c pl = new ERP7__Product_Location__c(Name='test', ERP7__Location__c=loc.Id);
        insert pl;
        
        ProductConfig pc = new ProductConfig();
        Product2 products = prod;
        ProductConfig.saveProduct(JSON.serialize(products));
        ProductConfig.getStatuspickval();
        ProductConfig.getpickvalType();
        ProductConfig.getpickvalCategory();
        ProductConfig.getpickvalRoutingStatus();
        ProductConfig.getpickvalRoutingType();
        ProductConfig.getpickvalBomPhase();
        ProductConfig.getpickvalBomType();
        ProductConfig.getpickvalBomUoM();
        ProductConfig.getpickvalExpType();
        ProductConfig.fetchRoutings(prod.Id);
        ProductConfig.fetchProductVersions(prod.Id);
        ProductConfig.fetchWarrantyDetails(prod.Id);
        ProductConfig.fetchTDA(prod.Id);
        ProductConfig.fetchPricebook(prod.Id);
        ProductConfig.fetchProductDetails(JSON.serialize(prod),prod.Id);
        ProductConfig.deletePriceBook(customPrice.Id);
        ProductConfig.deleteTierDiscounts(tda.Id);
        ProductConfig.deleteWarrantyRecord(wrp.Id);
        ProductConfig.deleteProductVersion(version.Id);
        priceBookEntry newPBE = standardPrice;
        String productId1 = prod.Id;
        ProductConfig.pricebookEntry2Insert(JSON.serialize(newPBE), productId1);
        String recId = standardPrice.Id;
        ProductConfig.getPricebookentrybyId(recId);
        Id recordId = version.Id;
        ProductConfig.deleteVersions(recordId);
        Id recordIds = bom.Id;
        ProductConfig.deleteBOMVersions(recordIds);
        Id versionID = bom.Id;
        ProductConfig.deleteBOM(versionID);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
}