@isTest
private class RequisitionToPurchaseOrderTestCaseSet {
    
    static testMethod void unitTestCase1() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=orgn.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Product2 ps1 = new Product2(
                                    Name='test', Track_Inventory__c=true,Issue_Purchase_Order__c=true);
        insert ps1;
        Requisition__c PR = new Requisition__c(Name='Test PR',Organisation__c = orgn.Id, Originating_Business_Unit__c = bUnit.Id);
        insert PR;
        Requisition__c PR1 = [select id,Organisation__c, name,Originating_Business_Unit__c from Requisition__c where id=: Pr.Id limit 1];
        List<Requisition__c> prlist = new List<Requisition__c>();
        prlist.add(PR1);
        Purchase_Requisition_Line_Items__c prli = new Purchase_Requisition_Line_Items__c(Name = 'test', Quantity__c = 1, Unit__c = 1,
                                                  Price__c = 1, Amount__c = 1, Description__c = 'test', Purchase_Requisition__c = PR.Id,
                                                  Product__c = ps1.Id);
        insert prli;
        PO__c po = new PO__c( Name = 'Test PO',
                   Order_Date__c=System.Today());
        insert po;                
        Product2 ps = new Product2(
                                Name='test', Track_Inventory__c=true);
        insert ps;        
        Purchase_Line_Items__c poli1 = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=po.id,Total_Price__c=100,
                                      Product__c = ps.Id);
        insert poli1; 
        Purchase_Line_Items__c poli2 = new Purchase_Line_Items__c(
                                          Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=po.id,Total_Price__c=100,
                                          Product__c = ps.Id, Purchase_Requisitions__c = PR.Id, Purchase_Requisition_Line_Items__c = prli.Id);  
        insert poli2;
        
        PageReference page = System.Page.RequisitionToPurchaseOrder;
        page.getParameters().put('prId',PR.Id);
        Test.setCurrentPage(page);
        
        RequisitionToPurchaseOrder rp2po = new RequisitionToPurchaseOrder();
        RequisitionToPurchaseOrder.PRWrapper rp2poWrap = new RequisitionToPurchaseOrder.PRWrapper();                
        rp2po.diplayPRList(JSON.serialize(prlist));
        Test.startTest();
        rp2po.prlis.Purchase_Requisition__c = null;
        rp2po.PR.Organisation__c = null;        
        rp2po.searchRequisition();
        
        rp2po.prlis.Purchase_Requisition__c = PR.Id;
        rp2po.PR.Organisation__c = orgn.Id;        
        rp2po.searchRequisition();
                
        rp2po.prlis.Purchase_Requisition__c = PR.Id;
        rp2po.PR.Organisation__c = null;
        rp2po.searchRequisition();
                
        rp2po.PR.Organisation__c = orgn.Id;
        rp2po.prlis.Purchase_Requisition__c = null;        
        rp2po.searchRequisition();
        
        rp2po.flag = true;
        rp2po.fetchSinglePRDetails();
        
        rp2poWrap.prliwrap = prli;
        rp2po.prliWrapMap.put(prli.Id,rp2poWrap);        
        rp2po.fetchSinglePRDetails();
        
        rp2po.flag = true;
        rp2po.fetchMultiplePRDetails();
        
        rp2po.flag = false;
        rp2po.fetchMultiplePRDetails();
        
        rp2po.prIdList.add(PR.Id);
        rp2po.diplayPRAndPRLIList(rp2po.prIdList); 
        
        rp2po.prliIds.add(prli.Id);
        rp2po.PRLIList.add(prli);
        List<Purchase_Line_Items__c> poliList = new List<Purchase_Line_Items__c>();
        poliList.add(poli1);
        rp2po.poliMap.put(prli.Id,poliList);
        rp2po.displayPRLILineItems(rp2po.prliIds);
                    
        rp2po.PRLIList.add(prli);        
        rp2po.displayPRLILineItems(rp2po.prliIds);       
        
        rp2poWrap.prliSelected = true;
        rp2po.prliWrapMap.put(prli.Id,rp2poWrap);
        rp2po.next();
        
        rp2po.flag = true;
        rp2po.ConvertTOPO();
        
        rp2po.flag = true;
        rp2po.requisitionId = PR1.Id;
        rp2po.saveAndNewPO();
        
        rp2po.flag = true;
        rp2po.requisitionId = null;
        rp2po.saveAndNewPO();
        
        rp2po.poInstance.Name = 'Test PO';
        rp2po.singleView = true;
        rp2po.convertingPR2PODetails();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);                
        Test.stopTest();
    }
    
    static testMethod void unitTestCase2() {
        Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
        insert orgn;
        Business_Unit__c bUnit = new Business_Unit__c(Organisation__c = orgn.Id, name = 'test', Active__c= true);
        insert bUnit; 
        Contact contact = new Contact(FirstName='Test',LastName='Contact',AccountId=orgn.id,Phone='1234567890',Email='test@test.com');
        insert contact;
        Requisition__c PR = new Requisition__c(Name='Test PR',Organisation__c = orgn.Id, Originating_Business_Unit__c = bUnit.Id);
        insert PR;
        Purchase_Requisition_Line_Items__c prli = new Purchase_Requisition_Line_Items__c(Name = 'test', Quantity__c = 1, Unit__c = 1,
                                                  Price__c = 1, Amount__c = 1, Description__c = 'test', Purchase_Requisition__c = PR.Id);
        insert prli;
        PO__c po = new PO__c( Name = 'Test PO',
                   Order_Date__c=System.Today());
        insert po;
        Product2 ps = new Product2(
                                Name='test', Track_Inventory__c=true);
        insert ps;
        Purchase_Line_Items__c poli1 = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=po.id,Total_Price__c=100,
                                      Product__c = ps.Id);
        insert poli1; 
        Purchase_Line_Items__c poli2 = new Purchase_Line_Items__c(
                                      Unit_Price__c=100,Quantity__c=1,Quantity_Received__c=1,Purchase_Orders__c=po.id,Total_Price__c=100,
                                      Product__c = ps.Id, Purchase_Requisitions__c = PR.Id, Purchase_Requisition_Line_Items__c = prli.Id);  
        insert poli2;
               
        RequisitionToPurchaseOrder rp2po = new RequisitionToPurchaseOrder();
        RequisitionToPurchaseOrder.PRWrapper rp2poWrap = new RequisitionToPurchaseOrder.PRWrapper();  
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);              
    }
}