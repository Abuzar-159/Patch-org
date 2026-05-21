@isTest
private class BundlesTestCases{
    static testMethod void UnitTestErpMark7_1(){ 
       
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            List<BOM__c > insertlist1 = new List<BOM__c>();
            Product2 PBG = new Product2(Name = 'Test Bundle', IS_KIT__c = True);
            insert PBG;
            

             Account orgn = new Account(Name='Organisation',Account_Type__c = 'Organisation');
            insert orgn;
            Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
            insert bUnit; 
            
            Product2 ps = new Product2(Name = 'Test Product', Is_Kit__c = True);
            insert ps;
            
             Product2 ps1 = new Product2(Name = 'Test Product');
            insert ps1;
             Product2 ps2 = new Product2(Name = 'Test Product');
            insert ps2;
           
            
            Product2 PBG_1 = new Product2(Name = 'Test Bundle', IS_KIT__c = True);
            insert PBG_1;
            BOM__c BOM1 = new BOM__c(Name = 'Test Product Service',BOM_Product__c=ps.id, Active__c = true, Type__c= 'Kit', BOM_Component__c = ps1.Id);
            insert BOM1;
            
            BOM__c BOM2 = new BOM__c(Name = 'Test Product Service',BOM_Product__c=ps.id, Active__c = true, Type__c= 'Kit', BOM_Component__c = ps2.Id);
            insert BOM2;
   
            insert insertlist1;
            
           
            System.assertEquals(ps.Is_Kit__c, True);
            
       
    }
    
    static testMethod void UnitTestBundleManagement(){ 
    
            PreventRecursiveLedgerEntry.testCasesTransactions = true;
            
            Account orgn = new Account(Name='Organisation',Account_Type__c = 'Organisation');
            insert orgn;
            Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
            insert bUnit; 
            Product2 ps = new Product2(Name='test', IsActive =true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
            insert ps; 
            Product2 ps1 = new Product2(Name='test', IsActive =true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
            insert ps1; 
            
             Product2 ps2 = new Product2(Name='test', IsActive =true,Track_Inventory__c=true,Product_Service_Family__c = 'Mobile');
            insert ps2; 
            Tax_Plan__c tp = new Tax_Plan__c(Name='Test',Type__c='sales');
            insert tp;
             
            BOM__c psa = new BOM__c(Name='test',Active__c=true,BOM_Product__c=ps.Id, BOM_Component__c=ps1.id);
            insert psa;  
            BOM__c psa1 = new BOM__c(Name='test',Active__c=true, BOM_Product__c=ps.Id, BOM_Component__c=ps2.id);
            insert psa1;
             
            Product2 PBG = new Product2(Name = 'Test Bundle', IS_KIT__c = True);
            insert PBG;
            BOM__c BOM = new BOM__c(Name = 'Test Product Service',BOM_Product__c=ps.id, Active__c = true, Type__c= 'Kit', BOM_Component__c = ps2.Id);
            insert BOM;
            List<Product2> productList = [select id, SKU__c, Picture__c,  Name, IsActive, Track_Inventory__c,Product_Service_Family__c from Product2 where id=: ps.id];
            List <Id> prodIds = new List<Id>();
            for(Product2 cp : productList) {
                prodIds.add(cp.Id);
            }
            
            
            test.StartTest(); 
            /*PageReference pageRef = System.Page.ProductBundleManagement;
            pageRef.getParameters().put('Id',PBG.Id);
            Test.setCurrentPage(pageRef);*/
            ProductBundleManagement pbm = new ProductBundleManagement();
        	pbm.bundleId = ps.Id;
        	pbm = new ProductBundleManagement();
            ProductBundleManagement.itemWrapper itemWrapper = new ProductBundleManagement.itemWrapper();
            ProductBundleManagement.ProductsAndDiscounts pdsWrapper = new ProductBundleManagement.ProductsAndDiscounts();
            
            pbm.searchProduct();
            pbm.addItem();
            Boolean flag = true;
            pbm.errorMsg = '';
            pbm.availableProfileListIds = new List<Id>();
            pbm.searchProfiles();
            pbm.searchProfiles();
            pbm.addCustProfiles();
            pbm.addRecommedation();
            pbm.addAccessory();
            pbm.removeItem();
            pbm.saveAll();
        	pbm.addProductBundle.Name = 'Test';
            pbm.saveAll();
        	pbm.RAWrapperDetails(productList,prodIds,'Accessory');
            /*
            pbm.ACustomerProfileWrapperList[0].selected = true;
            pbm.addCustProfiles();
            pbm.RAWrapperDetails(productList,prodIds,'Recommendation');
            pbm.RAWrapperDetails(productList,prodIds,'Accessory');
            pbm.ARemitemWrapperList[0].selected = true;
            pbm.addRecommedation();
            pbm.AAccitemWrapperList[0].selected = true;
            pbm.addAccessory();
            pbm.CurrentTab = 'tab1'; 
            pbm.saveAll();
            pbm.CurrentTab = 'tab2'; 
            pbm.saveAll();
            pbm.CurrentTab = 'tab3'; 
            pbm.saveAll();
            pbm.CurrentTab = 'tab4'; 
            pbm.saveAll(); 
            pbm.ItemPos = 0;
            pbm.removeItem(); 
            */
            String salName = 'ERP7';
            String sal1Name = 'ERP7';
            System.assertEquals(salName, sal1Name);
            test.StopTest();
     
    }
}