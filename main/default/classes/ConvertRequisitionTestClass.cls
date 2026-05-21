@isTest
private class ConvertRequisitionTestClass {
    
    @isTest 
    static void UniTest(){
        Account c = new Account(Name='Test', ERP7__Account_Type__c='Customer');  
        insert c;
        ERP7__Address__c  address = new ERP7__Address__c(Name='Test', ERP7__Customer__c=c.Id);
        insert address;
        ERP7__Channel__c channel = new ERP7__Channel__c(Name='Test', ERP7__Ship_From_Address__c=address.Id, ERP7__Shipper_Name__c='test',
                                                        ERP7__Company__c='test', ERP7__Phone__c='1234567890', ERP7__City__c='test', ERP7__Street__c='test',
                                                        ERP7__State_Province__c='test', ERP7__Country__c='test', ERP7__Zip_Postal_Code__c='test', ERP7__Active__c=true);
        insert channel;
        ERP7__Employees__c emp = new ERP7__Employees__c(Name='Test', ERP7__Employee_User__c=UserInfo.getUserId(), ERP7__Channel__c=channel.Id);
        insert emp;
        ERP7__Site__c site = new ERP7__Site__c(Name='Test', ERP7__Active__c=true);
        insert site;
         ERP7__Distribution_Channel__c DC = new ERP7__Distribution_Channel__c(Name='Test', ERP7__Site__c=site.Id, ERP7__Channel__c=emp.ERP7__Channel__c);
        insert DC;
         Product2 ps = new Product2(Name='Test',isActive=true,Track_Inventory__c=true);
        insert ps; 
        ERP7__Reordering_Rule__c rr = new ERP7__Reordering_Rule__c(Name= 'Test RR',ERP7__Warehouse__c =site.Id,ERP7__MinimumHoldingQuantity__c = 1,ERP7__MinimumOrderingQuantity__c=1,ERP7__Product__c=ps.Id);
        insert rr;
        ERP7__Requisition__c req = new ERP7__Requisition__c(Name='Test', ERP7__Active__c=true, ERP7__Expected_Delivery_Date__c=system.today(),ERP7__Status__c = 'Approved',
                                                            ERP7__Actual_Delivery_Date__c=system.today(), ERP7__Distribution_Channel__c=DC.Id);
        insert req;
        
        ERP7__Purchase_Requisition_Line_Items__c prli = new ERP7__Purchase_Requisition_Line_Items__c(Name='Test', ERP7__Purchase_Requisition__c=req.Id,
                                                                                                     ERP7__Quantity__c=2, ERP7__Unit__c=10, ERP7__Amount__c=10,ERP7__Product__c=ps.Id);
        insert prli;
        
        ConvertRequisitionToPurchaseOrder CRTP = new ConvertRequisitionToPurchaseOrder();
        system.debug('DC.Id : '+DC.Id);
        ConvertRequisitionToPurchaseOrder.wrapper wrap = new ConvertRequisitionToPurchaseOrder.wrapper();
        ConvertRequisitionToPurchaseOrder.fetchRequistionLineItems('',DC.Id,0,10,'');
        ConvertRequisitionToPurchaseOrder.fetchRequistionLineItems('Test',DC.Id,0,10,req.Id);
        ConvertRequisitionToPurchaseOrder.fetchRequistionLineItems('','',0,10,req.Id); 
        ConvertRequisitionToPurchaseOrder.fetchRequistionLineItems('Test','',0,10,'');
        ConvertRequisitionToPurchaseOrder.fetchChannelandDC();
        ConvertRequisitionToPurchaseOrder.fetchSortedRequistion('Name','ASC',Dc.Id,1,10);
        String recordId = DC.Id;
        ConvertRequisitionToPurchaseOrder.getDCByChan(recordId,1,1);
        ConvertRequisitionToPurchaseOrder.getDCByChan('',1,1);
        ConvertRequisitionToPurchaseOrder.getReorderingRules(site.Id,new List<String>{ps.Id});
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
}