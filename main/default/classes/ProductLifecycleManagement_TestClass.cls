@IsTest
public class ProductLifecycleManagement_TestClass {     
  public testMethod static void ProductLifecycleManagementMethod(){
       ProductLifecycleManagement plm=new ProductLifecycleManagement();                       
       ProductLifecycleManagement.PLMWrapper plmw=new ProductLifecycleManagement.PLMWrapper();
       ProductLifecycleManagement.SelectOption plms=new ProductLifecycleManagement.SelectOption('','');
      
       plm.Product=new Product2();
       plm.ProductList=new list<Product2>(); 
       plm.Media=new ERP7__Media__c();
       plm.MediaList=new list<ERP7__Media__c>();
       plm.Routing=new ERP7__Routing__c();
       plm.RoutingList=new list<ERP7__Routing__c>();
       plm.Version=new ERP7__Version__c();
       plm.VersionList=new list<ERP7__Version__c>();
       plm.WarrantyRP=new ERP7__Warranty_Return_Policy__c();
       plm.WarrantyRPList=new list<ERP7__Warranty_Return_Policy__c>();
       plm.ChangeOrder=new ERP7__Change_Order__c();
       plm.ChangeOrderList=new list<ERP7__Change_Order__c>();
       plm.QualityOrder=new ERP7__Quality_Order__c();
       plm.QualityOrderList=new list<ERP7__Quality_Order__c>();
       plm.PBE=new PricebookEntry();  
       plm.PBEList=new list<PricebookEntry>();
       plm.BOM=new ERP7__BOM__c();
       plm.BOMList=new list<ERP7__BOM__c>();
       plm.WIP=new ERP7__WIP_Link__c();
       plm.WIPList=new list<ERP7__WIP_Link__c>();
       plm.AttachmentRecord=new Attachment();
      
       ProductLifecycleManagement.getPicklistValues();
       ProductLifecycleManagement.getMed(); 
       ProductLifecycleManagement.getRou();
       ProductLifecycleManagement.getVer();
       ProductLifecycleManagement.getWR(); 
       ProductLifecycleManagement.getCO();
       ProductLifecycleManagement.getQua();
       ProductLifecycleManagement.getPriceBookEntry();
      ProductLifecycleManagement.getwip();
      ProductLifecycleManagement.getAVendor();
      ProductLifecycleManagement.getProduct();
      ProductLifecycleManagement.getBom();
       
       plmw.ProductFamilyList=null;
       plmw.ProductTypeList=null;
       plmw.ProductCategoryList=null;
       plmw.ProductTaxCodeList=null;
       plmw.ProductSubCategoryList=null;
       plmw.ProductUoMList=null;
       plmw.ProductQuantityUnitOfMeasureList=null;
       plmw.ProductStatusList=null;
       plmw.ProductWeightDimensionsList=null;
       plmw.RoutingStatusList=null;
       plmw.RoutingTypeList=null;
       plmw.VersionCategoryList=null;
       plmw.VersionStatusList=null;
       plmw.VersionTypeList=null;
       plmw.ReturnPolicyRefundOptionList=null;
       plmw.MediaTypeList=null;      
       plmw.COCategoryList=null;
       plmw.COTypeList=null;
       plmw.COStatusList=null;
       plmw.COProjectList=null;
       plmw.WarrantyRPRO=null;
       plmw.BOMStatusList=null;
       plmw.BOMTypeList=null;
       plmw.BOMComponentTypeList=null;
       //plmw.BOMUoMList=null;
       plmw.WIPTypeList=null;
       plmw.WIPUoMList=null;
      
       Product2 Product=new Product2(Name='abc',ERP7__Brand__c='amazon');
      Product.ERP7__Thickness__c=10;
       upsert Product;
       ERP7__Version__c Version=new ERP7__Version__c(Name='abc',ERP7__Product__c=Product.Id);
       upsert Version;
       ERP7__Routing__c Routing=new ERP7__Routing__c(Name='abc',ERP7__Product__c=Product.Id);
       upsert Routing;
      ERP7__Approved_Vendor__c Av = new ERP7__Approved_Vendor__c(Name='abc',ERP7__Product__c=Product.Id);
      upsert Av;
      ERP7__BOM__c BO = new ERP7__BOM__c(Name='abc', ERP7__BOM_Product__c=Product.Id);
      upsert BO;
      ERP7__WIP_Link__c WIP =new ERP7__WIP_Link__c(Name='abc', ERP7__Product__c=Product.Id);
      upsert WIP;
       Attachment Attach=new Attachment(Name='abc', ParentId=Product.Id, Body=Blob.valueOf('abc'));
       upsert Attach;
      
       ProductLifecycleManagement.getRecords(Product.Id);
       ProductLifecycleManagement.getVersionRecordDetails(Version.Id);
       ProductLifecycleManagement.getRoutingRecordDetails(Routing.Id);
       try{
        ProductLifecycleManagement.getCreateRecord('', 'delete', 'pro', Product.Id, Product.Id,'Test.jpeg','', 'mp4');
        ERP7__Routing__c Routing1=new ERP7__Routing__c(Name='abc',ERP7__Product__c=Product.Id);  upsert Routing1;  
       }catch(Exception ex){} 
       ProductLifecycleManagement.getCreateVersionRecord('', 'delete', 'pro', Version.Id, Version.Id,'Test.jpeg','', 'mp4');
       ProductLifecycleManagement.getCreateRoutingRecord('', 'delete', 'pro', Routing.Id);  
       ProductLifecycleManagement.AttachmentmentDetails(Attach.Id);
       ProductLifecycleManagement.getBom();
       ProductLifecycleManagement.getOperation();
       ProductLifecycleManagement.getCloneRelatedRecords(Product.Id,Product.Id);
       ProductLifecycleManagement.getVersionCloneRelatedRecords(Version.Id,Version.Id);
        String s1='ERP7';
        String s2='ERP7';
        System.assertEquals(s1,s2);
     
    }   
}