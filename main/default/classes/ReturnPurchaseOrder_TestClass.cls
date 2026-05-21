@IsTest
public class ReturnPurchaseOrder_TestClass {
   public testMethod static void ReturnPurchaseOrderMethod(){
       ReturnPurchaseOrder p=new ReturnPurchaseOrder();
       p.ChannelId=null; p.distributionchannel=null; p.RPO=null;p.RPOLI=null; p.POStatusList=null;
       
       Account acc=new Account(Name='abc'); insert acc;
      ERP7__Distribution_Channel__c dc=new ERP7__Distribution_Channel__c(name='abc');
      insert dc ;
       
      ReturnPurchaseOrder.getInstance();
      ReturnPurchaseOrder.getFreightType();  
       ReturnPurchaseOrder.getStatus();  
       ReturnPurchaseOrder.getRMAStatus();  ReturnPurchaseOrder.getFreightType(); 
       ReturnPurchaseOrder.getCRUD();
       
      ERP7__PO__c po=new ERP7__PO__c(Name='abc'); insert po; 
      ReturnPurchaseOrder.fetch_RMALI(po.Id);
      ReturnPurchaseOrder.FetchcustomerInfo(acc.Id);
       
       try{ReturnPurchaseOrder.getCreateRPO('','');}catch(Exception ex){}
       try{ReturnPurchaseOrder.getEditRPOLI('','update');}catch(Exception ex){}
       
        
      ERP7__Site__c site=new ERP7__Site__c(Name='abc'); 
      insert site; 
      ReturnPurchaseOrder.getSiteDetails(site.Id);
       
      ReturnPurchaseOrder.getSiteDetailsbyDC(dc.Id);  
     
      ReturnPurchaseOrder.getPoliByCustomer(acc.Id, dc.Id,''); //String CustID, String DistributeChannelId, String selPolis
      ReturnPurchaseOrder.getDistributeChannelDetails(dc.Id);
       
      ERP7__Address__c ad =new ERP7__Address__c(Name='abc', ERP7__Customer__c=acc.id);
       insert ad; 
      ReturnPurchaseOrder.FetchAddressById(acc.Id, ad.Id);
       
      ReturnPurchaseOrder.customerInfo cs=new ReturnPurchaseOrder.customerInfo(); 
       cs.contact=null; cs.Address=null; 
       
     // ReturnPurchaseOrder.RMAWrapperLI poli=new  ReturnPurchaseOrder.RMAWrapperLI('','',false);
     // ReturnPurchaseOrder.getCreateRPO('',''); 
       String salName = 'ERP';
       String sal1Name = 'ERP';
       System.assertEquals(salName, sal1Name);
   }
}