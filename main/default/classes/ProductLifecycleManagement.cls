Public with sharing class ProductLifecycleManagement {    
    @AuraEnabled
    Public Product2 Product              {set;get;}
    @AuraEnabled
    Public list<Product2> ProductList    {set;get;}
    @AuraEnabled
    Public ERP7__Media__c Media              {set;get;}  
    @AuraEnabled
    Public list<ERP7__Media__c> MediaList        {set;get;}
    @AuraEnabled
    Public Map<String,ERP7__Media__c> MediaMap  {set;get;}  
    @AuraEnabled
    Public ERP7__Routing__c Routing              {set;get;}
    @AuraEnabled
    Public list<ERP7__Routing__c> RoutingList    {set;get;}
    @AuraEnabled
    Public ERP7__Version__c Version              {set;get;}
    @AuraEnabled
    Public list<ERP7__Version__c> VersionList    {set;get;}    
    @AuraEnabled 
    Public ERP7__Warranty_Return_Policy__c WarrantyRP   {set;get;}
    @AuraEnabled
    Public list<ERP7__Warranty_Return_Policy__c> WarrantyRPList   {set;get;}
    @AuraEnabled
    Public ERP7__Change_Order__c ChangeOrder              {set;get;}
    @AuraEnabled
    Public list<ERP7__Change_Order__c> ChangeOrderList    {set;get;}
    @AuraEnabled
    Public ERP7__Quality_Order__c QualityOrder              {set;get;}
    @AuraEnabled
    Public list<ERP7__Quality_Order__c> QualityOrderList    {set;get;}
    @AuraEnabled
    Public PricebookEntry PBE              {set;get;}
    @AuraEnabled
    Public list<PricebookEntry> PBEList    {set;get;}  
    @AuraEnabled
    Public ERP7__BOM__c   BOM             {set;get;}
    @AuraEnabled
    Public list<ERP7__BOM__c> BOMList     {set;get;}    
    @AuraEnabled
    Public ERP7__Operation__c   Operation             {set;get;}
    @AuraEnabled
    Public list<ERP7__Operation__c> OperationList     {set;get;}
    @AuraEnabled
    Public Attachment AttachmentRecord                {set;get;}
    @AuraEnabled
    Public ERP7__Approved_Vendor__c AVendor              {set;get;}  
    @AuraEnabled
    Public list<ERP7__Approved_Vendor__c> AVendorList        {set;get;}
    @AuraEnabled
    Public ERP7__WIP_Link__c  WIP              {set;get;}  
    @AuraEnabled
    Public list<ERP7__WIP_Link__c> WIPList        {set;get;}
  
    @AuraEnabled
    Public Static ProductLifecycleManagement getRecords(String ProductId){
        ProductLifecycleManagement plm=new ProductLifecycleManagement();
        plM.Product=new Product2();
        plM.Media=new ERP7__Media__c();
        plM.Routing=new ERP7__Routing__c();
        plM.Version=new ERP7__Version__c();
        plM.WarrantyRP=new ERP7__Warranty_Return_Policy__c();
        plM.ChangeOrder=new ERP7__Change_Order__c();
        plM.QualityOrder=new ERP7__Quality_Order__c();
        plM.PBE=new PricebookEntry();
        plm.AVendor=new ERP7__Approved_Vendor__c();
        plm.BOM=new ERP7__BOM__c();
        plm.WIP=new ERP7__WIP_Link__c();
     
       if(String.isNotEmpty(ProductId)){ 
         plm.Product=[SELECT Id, Name, IsActive, ProductCode, ERP7__Approved_by__c, ERP7__ASIN_Code__c, ERP7__Available_on_eCommerce_platform__c, ERP7__Barcode__c, ERP7__Brand__c, ERP7__Bullet_Point_1__c, ERP7__Bullet_Point_2__c, 
            ERP7__Category__c, ERP7__Colour__c, ERP7__Commodity_Code__c, ERP7__Customer_Segments__c, ERP7__Declared_Shipment_Value__c, ERP7__Routing__c, ERP7__Routing__r.Name, 
            ERP7__Version__c, ERP7__Version__r.Name, ERP7__Description__c, ERP7__Directions__c, DisplayUrl, ERP7__eBay_Id__c, ERP7__Expense_Account__c, ERP7__Expiration_Date__c,                        
            ExternalDataSourceId, ExternalId, ERP7__Goods_Description__c, ERP7__Height__c, ERP7__Ingredients__c, ERP7__Inspection_Routing__c, ERP7__Inventory_Account__c, ERP7__Inventory_Type__c,
            ERP7__Invoiceable__c, ERP7__Is_Asset__c, ERP7__Is_Kit__c, ERP7__Is_OverSized_Item__c, ERP7__Issue_Manufacturing_Order__c, ERP7__Issue_Purchase_Order__c, ERP7__Issue_Work_Order__c,
            ERP7__Item_Description__c, ERP7__Kit_Protected__c, ERP7__Length__c, ERP7__Length_Width_Height_Dimensions__c, ERP7__Line_Of_Business__c, ERP7__Locked__c, ERP7__Locked_By__c,
            ERP7__Locked_Date__c,  ERP7__Lot_Tracked__c, ERP7__Magento_Id__c, ERP7__Manufacture_Lead_Time_days__c, ERP7__Manufacturer__c, ERP7__Manufacturing_Type__c, ERP7__MOQ__c,
            ERP7__Out_Of_Stock__c, ERP7__Picture__c, ERP7__Preview_Image__c, ERP7__Price_Entry_Amount__c, ERP7__Product_Service_Family__c,Description, Family, ERP7__Product_Lifecycle_Stage__c,
            StockKeepingUnit, ERP7__Profiling__c, ERP7__Purchase_Lead_Time_days__c, ERP7__Purge_And_Replace__c, QuantityUnitOfMeasure, ERP7__Revenue_Account__c, ERP7__Serialise__c, 
            ERP7__Shopify_Id__c, ERP7__Special_Instructions__c, ERP7__Status__c, ERP7__Sub_Category__c, ERP7__Submitted_to_Amazon__c, ERP7__Tag_Name__c, ERP7__Tax_Band__c,
            ERP7__Tax_Code__c, ERP7__Thickness__c, ERP7__Track_Inventory__c, ERP7__Transactable__c, ERP7__Item_Type__c, ERP7__Item_Unit__c, ERP7__Item_Unit_Value__c, ERP7__UoM__c,
            ERP7__Weight__c, ERP7__Weight_Dimensions__c, ERP7__Width__c, ERP7__WooCommerce_Id__c, ERP7__Allow_Pre_Orders__c, ERP7__Allow_Back_Orders__c, ERP7__SKU__c                          
            FROM Product2 WHERE Id=:ProductId];
          
        plm.RoutingList=[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                         ERP7__Work_Center__c, ERP7__Work_Center__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                         ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                         ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                         FROM ERP7__Routing__c WHERE Name!=Null AND ERP7__Product__C=:ProductId Order By Name ASC];
        
       plm.VersionList=[SELECT Id, Name, ERP7__Active__c, ERP7__Asset__c,ERP7__Asset__r.Name, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Inventory_Stock__r.Name, ERP7__Picture__c, ERP7__Preview_Image__c,
                        ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c,ERP7__Product__r.Name , ERP7__Quantity__c, RecordTypeId, RecordType.DeveloperName, RecordType.Name, ERP7__Sales_Ready__c, ERP7__Start_Date__c,     
                        ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c
                        FROM ERP7__Version__c WHERE NAME!=Null AND ERP7__Product__c=:ProductId Order By Name ASC];
                        
       plm.WarrantyRPList=[SELECT Id, Name, ERP7__Active__c, ERP7__Code__c, ERP7__Days_of_Warranty__c, ERP7__Description__c, ERP7__Exchange__c,
                    ERP7__Asset__c, ERP7__Asset__r.Name, ERP7__Guideline__c, ERP7__Guideline__r.Name, ERP7__Number_Days_From_Trans_Return_Accepted__c, ERP7__Organisation__c, ERP7__Organisation__r.Name,
                    ERP7__Organisation_Business_Unit__c, ERP7__Organisation_Business_Unit__r.Name, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Return_Policy_Refund_Option__c, ERP7__Standard_Manufacturing_Warranty__c
                    FROM ERP7__Warranty_Return_Policy__c WHERE NAME!=Null  AND ERP7__Product__c=:ProductId Order By Name ASC];


        plm.ChangeOrderList=[SELECT Id, Name, ERP7__Category__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Status__c, ERP7__type__c
                            FROM ERP7__Change_Order__c WHERE Name!=Null Order By Name ASC];                 
         
        plm.QualityOrderList=[SELECT Id, Name FROM  ERP7__Quality_Order__c WHERE Name !=Null Order By Name ASC];
        
        plm.PBEList=[SELECT Id, Name, IsActive, ERP7__Admin_Shipping_Price__c, ERP7__Barcode__c, ERP7__Check_Out_Process__c, ERP7__Description__c, ERP7__Discount_Plan__c, ERP7__Discount_Plan__r.Name, 
                    ERP7__End_Date__c, UnitPrice, ERP7__Notes__c, Pricebook2Id, Pricebook2.Name ,Product2Id, Product2.Name, ProductCode, ERP7__Product_Version__c, ERP7__Product_Version__r.Name, 
                    ERP7__Purchase_Price__c, ERP7__Selling_Price__c, ERP7__Shipping_Price__c, ERP7__Start_Date__c, ERP7__Tax_Exempt__c, ERP7__Tax_Plan__c, ERP7__Tax_Plan__r.Name, ERP7__Tax_Rate__c, UseStandardPrice, ERP7__Warranty_Return_Policy__c, ERP7__Warranty_Return_Policy__r.Name
                    FROM PriceBookEntry WHERE Name !=Null  AND Product2Id=:ProductId Order By Name ASC];
         
        plm.AVendorList=[SELECT Id, Name, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Lead_Time__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Status__c, ERP7__Type__c, ERP7__Vendor__c, ERP7__Vendor__r.Name
                        FROM ERP7__Approved_Vendor__c
                        WHERE ERP7__Product__c=:ProductId Order By Name ASC];
         
        plm.BOMList=[SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, ERP7__BOM_Asset_Component__c, ERP7__BOM_Asset_Component__r.Name, 
                    ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Product__c, ERP7__BOM_Product__r.Name, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name,
                    ERP7__Code__c, ERP7__Component_Type__c, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Finished_Product_Amount_Delivered__c,
                    ERP7__Is_Protected__c, ERP7__PIN__c, ERP7__Partial_Replacement__c, ERP7__Phase__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name,ERP7__Procurement_Type__c,
                    ERP7__Product_Feature__c, ERP7__Quantity__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, 
                    ERP7__Requirement_Period_Start_Date__c, ERP7__Routing_Link__c,ERP7__Routing_Link__r.Name, ERP7__Scrap__c, ERP7__Status__c, ERP7__Type__c,ERP7__Sort__c, ERP7__Unit_of_Measure__c, ERP7__BOM_Asset__c, ERP7__BOM_Asset__r.Name,
                    ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c FROM ERP7__BOM__c WHERE ERP7__BOM_Product__c=:ProductId Order By Name ASC];
           
         plm.WIPList=[Select Id, Name, ERP7__Type__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Process_Output_Product__c, ERP7__Process_Output_Product__r.Name,
                     ERP7__Process_Output_Version__c, ERP7__Process_Output_Version__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Version__c, ERP7__Version__r.Name,
                     ERP7__Quantity_Unit__c, ERP7__Product__c, ERP7__Product__r.Name From ERP7__WIP_Link__c Where ERP7__Product__c=:ProductId Order By Name ASC]; 
              
       // plm.MediaList
        list<ERP7__Media__c>  Medias =[SELECT Id, Name, ERP7__Active__c, ERP7__Description__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c
                                       FROM ERP7__Media__c WHERE Name!=Null AND ERP7__Product__c=:ProductId Order By ERP7__Order__c ASC];// AND ERP7__Active__c=true 
       // plm.MediaList=Medias;
          
        Map<String, ERP7__Media__c>  MediaMap=new Map<String, ERP7__Media__c>();
        for(ERP7__Media__c m:Medias){
           Attachment attach=new Attachment();
            
            try{ 
              attach=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:m.Id LIMIT 1];
            }catch(Exception ex){  }
            if(String.isNotEmpty(attach.Id)){ 
              String attachBody=EncodingUtil.base64Encode(attach.Body);
              m.ERP7__File__c=attach.Id;  
              MediaMap.put(attachBody, m); 
            }    
        }
        plm.MediaMap=MediaMap; 
           
        return plm;
       } else return plm;      
    }
    
    @AuraEnabled
    Public Static ProductLifecycleManagement getCreateRecord(String Record, String Action, String Tab, String ProductId, String ParentId, String FileName, String MediaBody, String ContentType){
        ProductLifecycleManagement plm=new ProductLifecycleManagement();
       
        if(Tab=='pro'){
            Product2 sRecord=(Product2) JSON.deserialize(Record, Product2.class); if(String.isEmpty(sRecord.Id)) sRecord.Id=null; if(Schema.SObjectType.Product2.isCreateable() && Schema.SObjectType.Product2.isUpdateable()) upsert sRecord;
            plm.Product=[SELECT Id, Name, IsActive, ERP7__Approved_by__c, ERP7__ASIN_Code__c, ERP7__Available_on_eCommerce_platform__c, ERP7__Barcode__c, ERP7__Brand__c, ERP7__Bullet_Point_1__c, ERP7__Bullet_Point_2__c, 
            ERP7__Category__c, ERP7__Colour__c, ERP7__Commodity_Code__c, ERP7__Customer_Segments__c, ERP7__Declared_Shipment_Value__c, ERP7__Routing__c, ERP7__Routing__r.Name, 
            ERP7__Version__c, ERP7__Version__r.Name, ERP7__Description__c, ERP7__Directions__c, DisplayUrl, ERP7__eBay_Id__c, ERP7__Expense_Account__c, ERP7__Expiration_Date__c,                        
            ExternalDataSourceId, ExternalId, ERP7__Goods_Description__c, ERP7__Height__c, ERP7__Ingredients__c, ERP7__Inspection_Routing__c, ERP7__Inventory_Account__c, ERP7__Inventory_Type__c,
            ERP7__Invoiceable__c, ERP7__Is_Asset__c, ERP7__Is_Kit__c, ERP7__Is_OverSized_Item__c, ERP7__Issue_Manufacturing_Order__c, ERP7__Issue_Purchase_Order__c, ERP7__Issue_Work_Order__c,
            ERP7__Item_Description__c, ERP7__Kit_Protected__c, ERP7__Length__c, ERP7__Length_Width_Height_Dimensions__c, ERP7__Line_Of_Business__c, ERP7__Locked__c, ERP7__Locked_By__c,
            ERP7__Locked_Date__c,  ERP7__Lot_Tracked__c, ERP7__Magento_Id__c, ERP7__Manufacture_Lead_Time_days__c, ERP7__Manufacturer__c, ERP7__Manufacturing_Type__c, ERP7__MOQ__c,
            ERP7__Out_Of_Stock__c, ERP7__Picture__c, ERP7__Preview_Image__c, ERP7__Price_Entry_Amount__c, ERP7__Product_Service_Family__c,Description, Family, ERP7__Product_Lifecycle_Stage__c,
            StockKeepingUnit, ERP7__Profiling__c, ERP7__Purchase_Lead_Time_days__c, ERP7__Purge_And_Replace__c, QuantityUnitOfMeasure, ERP7__Revenue_Account__c, ERP7__Serialise__c, 
            ERP7__Shopify_Id__c, ERP7__Special_Instructions__c, ERP7__Status__c, ERP7__Sub_Category__c, ERP7__Submitted_to_Amazon__c, ERP7__Tag_Name__c, ERP7__Tax_Band__c,
            ERP7__Tax_Code__c, ERP7__Thickness__c, ERP7__Track_Inventory__c, ERP7__Transactable__c, ERP7__Item_Type__c, ERP7__Item_Unit__c, ERP7__Item_Unit_Value__c, ERP7__UoM__c,
            ERP7__Weight__c, ERP7__Weight_Dimensions__c, ERP7__Width__c, ERP7__WooCommerce_Id__c                          
            FROM Product2 WHERE Id=:sRecord.Id];
        }
        
        if(String.isNotEmpty(ProductId)) { 
            if(Tab=='rou'){  ERP7__Routing__c sRecord=(ERP7__Routing__c) JSON.deserialize(Record, ERP7__Routing__c.class); if(Action!='delete'){ if(Schema.SObjectType.ERP7__Routing__c.isCreateable() && Schema.SObjectType.ERP7__Routing__c.isUpdateable()) upsert sRecord;}  else{ if(ERP7__Routing__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Routing__c(Id=sRecord.Id); }else{ /*no access*/ } } 
            plm.RoutingList=[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                         ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                         ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                         ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                         FROM ERP7__Routing__c WHERE Name!=Null AND ERP7__Product__c=:ProductId Order By Name ASC]; 
           
        }
            else if(Tab=='ver'){ ERP7__Version__c sRecord=(ERP7__Version__c) JSON.deserialize(Record, ERP7__Version__c.class); if(Action!='delete') if(Schema.SObjectType.ERP7__Version__c.isCreateable() && Schema.SObjectType.ERP7__Version__c.isUpdateable()) upsert sRecord; else{ if(ERP7__Version__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Version__c(Id=sRecord.Id);	}else{ /*no access*/ } }
            plm.VersionList=[SELECT Id, Name, ERP7__Active__c, ERP7__Asset__c,ERP7__Asset__r.Name, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Inventory_Stock__r.Name, ERP7__Picture__c, ERP7__Preview_Image__c,
                        ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c,ERP7__Product__r.Name , ERP7__Quantity__c, RecordTypeId, RecordType.DeveloperName, RecordType.Name, ERP7__Sales_Ready__c, ERP7__Start_Date__c,     
                        ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c
                        FROM ERP7__Version__c WHERE NAME!=Null  AND ERP7__Product__c=:ProductId Order By Name ASC];              
        }
            else if(Tab=='wr'){ ERP7__Warranty_Return_Policy__c sRecord=(ERP7__Warranty_Return_Policy__c) JSON.deserialize(Record, ERP7__Warranty_Return_Policy__c.class); if(Action!='delete') if(Schema.SObjectType.ERP7__Warranty_Return_Policy__c.isCreateable() && Schema.SObjectType.ERP7__Warranty_Return_Policy__c.isUpdateable()) {upsert sRecord;} else{ if(ERP7__Warranty_Return_Policy__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Warranty_Return_Policy__c(Id=sRecord.Id); } else{ /*no access*/ } }
            plm.WarrantyRPList=[SELECT Id, Name, ERP7__Active__c, ERP7__Code__c, ERP7__Days_of_Warranty__c, ERP7__Description__c, ERP7__Exchange__c,
                    ERP7__Asset__c, ERP7__Asset__r.Name, ERP7__Guideline__c, ERP7__Guideline__r.Name, ERP7__Number_Days_From_Trans_Return_Accepted__c, ERP7__Organisation__c, ERP7__Organisation__r.Name,
                    ERP7__Organisation_Business_Unit__c, ERP7__Organisation_Business_Unit__r.Name, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Return_Policy_Refund_Option__c, ERP7__Standard_Manufacturing_Warranty__c
                    FROM ERP7__Warranty_Return_Policy__c WHERE NAME!=Null  AND ERP7__Product__c=:ProductId Order By Name ASC];  
        }
            else if(Tab=='bom'){  ERP7__BOM__c sRecord=(ERP7__BOM__c) JSON.deserialize(Record, ERP7__BOM__c.class); if(Action!='delete') if(Schema.SObjectType.ERP7__BOM__c.isCreateable() && Schema.SObjectType.ERP7__BOM__c.isUpdateable()) upsert sRecord;  else{if(ERP7__BOM__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__BOM__c(Id=sRecord.Id); }else{ /*no access*/ } }  
        plm.BOMList=[SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, ERP7__BOM_Asset_Component__c, ERP7__BOM_Asset_Component__r.Name, 
                    ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Product__c, ERP7__BOM_Product__r.Name, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name,
                    ERP7__Code__c, ERP7__Component_Type__c, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Finished_Product_Amount_Delivered__c,
                    ERP7__Is_Protected__c, ERP7__PIN__c, ERP7__Partial_Replacement__c, ERP7__Phase__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.Name, ERP7__Procurement_Type__c,
                    ERP7__Product_Feature__c, ERP7__Quantity__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, 
                    ERP7__Requirement_Period_Start_Date__c, ERP7__Routing_Link__c,ERP7__Routing_Link__r.Name, ERP7__Scrap__c, ERP7__Status__c, ERP7__Type__c, ERP7__Sort__c, ERP7__Unit_of_Measure__c, ERP7__BOM_Asset__c, ERP7__BOM_Asset__r.Name
                    FROM ERP7__BOM__c WHERE ERP7__BOM_Product__c=:ProductId Order By Name ASC];
                                      }
            else if(Tab=='co'){ ERP7__Change_Order__c sRecord=(ERP7__Change_Order__c) JSON.deserialize(Record, ERP7__Change_Order__c.class); if(Action!='delete') {if(Schema.SObjectType.ERP7__Change_Order__c.isCreateable() && Schema.SObjectType.ERP7__Change_Order__c.isUpdateable()) upsert sRecord;} else{if(ERP7__Change_Order__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Change_Order__c(Id=sRecord.Id);	}  else{ /*no access*/ }	}
            plm.ChangeOrderList=[SELECT Id, Name, ERP7__Category__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Status__c, ERP7__type__c
                            FROM ERP7__Change_Order__c WHERE Name!=Null Order By Name ASC]; // AND ERP7__Product__c=:ProductId   
        }
            else if(Tab=='qua'){ ERP7__Quality_Order__c sRecord=(ERP7__Quality_Order__c) JSON.deserialize(Record, ERP7__Quality_Order__c.class); if(Action!='delete') {if(Schema.SObjectType.ERP7__Quality_Order__c.isCreateable() && Schema.SObjectType.ERP7__Quality_Order__c.isUpdateable()) upsert sRecord;} else{if(ERP7__Quality_Order__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Quality_Order__c(Id=sRecord.Id);	 } else{ /*no access*/ } }
            plm.QualityOrderList=[SELECT Id, Name FROM  ERP7__Quality_Order__c WHERE Name !=Null Order By Name ASC];
        }
            else if(Tab=='pbe'){  PricebookEntry sRecord=(PricebookEntry) JSON.deserialize(Record, PricebookEntry.class); if(Action!='delete') if(Schema.SObjectType.PricebookEntry.isCreateable() && Schema.SObjectType.PricebookEntry.isUpdateable()) upsert sRecord; else{if(PricebookEntry.sObjectType.getDescribe().isDeletable()) {delete new PricebookEntry(Id=sRecord.Id); }else{ /*no access*/ }}
            plm.PBEList=[SELECT Id, Name, IsActive, ERP7__Admin_Shipping_Price__c, ERP7__Barcode__c, ERP7__Check_Out_Process__c, ERP7__Description__c, ERP7__Discount_Plan__c, ERP7__Discount_Plan__r.Name, 
            ERP7__End_Date__c, UnitPrice, ERP7__Notes__c, Pricebook2Id, Pricebook2.Name ,Product2Id, Product2.Name, ProductCode, ERP7__Product_Version__c, ERP7__Product_Version__r.Name, 
            ERP7__Purchase_Price__c, ERP7__Selling_Price__c, ERP7__Shipping_Price__c, ERP7__Start_Date__c, ERP7__Tax_Exempt__c, ERP7__Tax_Plan__c, ERP7__Tax_Plan__r.Name, ERP7__Tax_Rate__c, UseStandardPrice, ERP7__Warranty_Return_Policy__c, ERP7__Warranty_Return_Policy__r.Name
            FROM PriceBookEntry WHERE Name !=Null  AND Product2Id=:ProductId Order By Name ASC];
         }
         else if(Tab=='av'){  ERP7__Approved_Vendor__c sRecord=(ERP7__Approved_Vendor__c) JSON.deserialize(Record, ERP7__Approved_Vendor__c.class);
                            if(Action!='delete') {if(Schema.SObjectType.ERP7__Approved_Vendor__c.isCreateable() && Schema.SObjectType.ERP7__Approved_Vendor__c.isUpdateable()) upsert sRecord;} else{if(ERP7__Approved_Vendor__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Approved_Vendor__c(Id=sRecord.Id);}else{ /*no access*/ }}
           plm.AVendorList=[SELECT Id, Name, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Lead_Time__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Status__c, ERP7__Type__c, ERP7__Vendor__c, ERP7__Vendor__r.Name
                            FROM ERP7__Approved_Vendor__c
                            WHERE ERP7__Product__c=:ProductId Order By Name ASC];
         }   
            else if(Tab=='wip'){  ERP7__WIP_Link__c sRecord=(ERP7__WIP_Link__c) JSON.deserialize(Record, ERP7__WIP_Link__c.class);
                                if(Action!='delete') {if(Schema.SObjectType.ERP7__WIP_Link__c.isCreateable() && Schema.SObjectType.ERP7__WIP_Link__c.isUpdateable()) upsert sRecord;} else{if(ERP7__WIP_Link__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__WIP_Link__c(Id=sRecord.Id);}else{ /*no access*/ }}
           plm.WIPList=[Select Id, Name, ERP7__Type__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Process_Output_Product__c, ERP7__Process_Output_Product__r.Name,
                     ERP7__Process_Output_Version__c, ERP7__Process_Output_Version__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Version__c, ERP7__Version__r.Name,
                     ERP7__Quantity_Unit__c, ERP7__Product__c, ERP7__Product__r.Name From ERP7__WIP_Link__c Where ERP7__Product__c=:ProductId Order By Name ASC]; 
              
         }
        else if(Tab=='med'){ 
            ERP7__Media__c sRecord=(ERP7__Media__c) JSON.deserialize(Record, ERP7__Media__c.class);
            if(Action!='delete'){
                if(Schema.SObjectType.ERP7__Media__c.isCreateable() && Schema.SObjectType.ERP7__Media__c.isUpdateable()) upsert sRecord;
                
                try{
                UploadFile.saveChunk(sRecord.Id, FileName, MediaBody,ContentType,'');// String Id=
                  }catch(Exception ex){ }     
           } 
           else{
               if(ERP7__Media__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Media__c(Id=sRecord.Id);}else{ /*no access*/ }
                 list<Attachment> attachList=new list<Attachment>();
                try{
                    attachList=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:sRecord.Id];
                 }catch(Exception ex){ }    
               if(attachList.size()>0 && Attachment.sObjectType.getDescribe().isDeletable()) {delete attachList;}else{ /*no access*/ }
            }    
           
            list<ERP7__Media__c>  Medias =[SELECT Id, Name, ERP7__Active__c,ERP7__Description__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c
                                             FROM ERP7__Media__c WHERE Name!=Null AND ERP7__Product__c=:ProductId Order By ERP7__Order__c ASC]; //AND ERP7__Active__c=true 
            //plm.MediaList=Medias;
            
            Map<String, ERP7__Media__c>  MediaMap=new Map<String, ERP7__Media__c>();
            for(ERP7__Media__c m:Medias){
                   Attachment attach=new Attachment();
                    try{ 
                      attach=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:m.Id LIMIT 1]; 
                    }catch(Exception ex){  }
                    if(String.isNotEmpty(attach.Id)){ 
                      String attachBody=EncodingUtil.base64Encode(attach.Body); 
                       m.ERP7__File__c=attach.Id;    
                      MediaMap.put(attachBody, m); 
                    }    
                }
             plm.MediaMap=MediaMap; 
            
        }
            
        }     
        return plm;
    }
    
    
    Public Class PLMWrapper{
       @AuraEnabled
       Public list<SelectOption>  ProductFamilyList {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ProductTypeList   {set;get;}        
       @AuraEnabled
       Public list<SelectOption>  ProductCategoryList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ProductTaxCodeList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ProductSubCategoryList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ProductUoMList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ProductQuantityUnitOfMeasureList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ProductStatusList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ProductWeightDimensionsList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  RoutingStatusList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  RoutingTypeList   {set;get;}
      
       @AuraEnabled
       Public list<SelectOption>  VersionCategoryList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  VersionStatusList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  VersionTypeList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  ReturnPolicyRefundOptionList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  MediaTypeList              {set;get;} 
       @AuraEnabled
       Public list<SelectOption>  COCategoryList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  COTypeList              {set;get;} 
       @AuraEnabled
       Public list<SelectOption>  COStatusList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  COProjectList              {set;get;} 
       @AuraEnabled
       Public list<SelectOption>  WarrantyRPRO              {set;get;}      
       @AuraEnabled
       Public list<SelectOption>  BOMTypeList   {set;get;}
       @AuraEnabled
       Public list<SelectOption>  BOMComponentTypeList {set;get;} 
       @AuraEnabled
       Public list<SelectOption>  BOMStatusList              {set;get;}
        @AuraEnabled
       Public list<SelectOption>  BOMUoMList              {set;get;}

       @AuraEnabled
       Public list<SelectOption> AVendorTypeList  {set;get;}  
       @AuraEnabled
       Public list<SelectOption> AVendorStatusList  {set;get;}  
       @AuraEnabled
       Public list<SelectOption> VersionRTList             {set;get;}  
       @AuraEnabled
       Public list<SelectOption> RoutingRTList             {set;get;}
       @AuraEnabled
       Public list<SelectOption> BOMRTList             {set;get;}
       @AuraEnabled
       Public list<SelectOption> WIPTypeList  {set;get;}
       @AuraEnabled
       Public list<SelectOption> WIPUoMList  {set;get;}

        
       public PLMWrapper(){
            ProductFamilyList=new list<SelectOption>();
            ProductTypeList=new list<SelectOption>();            
            ProductCategoryList=new list<SelectOption>();
            ProductTaxCodeList=new list<SelectOption>();            
            ProductSubCategoryList=new list<SelectOption>();
            ProductUoMList=new list<SelectOption>();
            ProductQuantityUnitOfMeasureList=new list<SelectOption>();
            ProductStatusList=new list<SelectOption>();
            ProductWeightDimensionsList=new list<SelectOption>();
            RoutingStatusList=new list<SelectOption>();
            RoutingTypeList=new list<SelectOption>();           
            VersionCategoryList=new list<SelectOption>();
            VersionStatusList=new list<SelectOption>();
            VersionTypeList=new list<SelectOption>();
            ReturnPolicyRefundOptionList=new list<SelectOption>();
            MediaTypeList=new list<SelectOption>(); 
            COCategoryList=new list<SelectOption>(); 
            COTypeList=new list<SelectOption>(); 
            COStatusList=new list<SelectOption>(); 
            COProjectList=new list<SelectOption>(); 
            WarrantyRPRO=new list<SelectOption>();
            
            BOMTypeList=new list<SelectOption>(); 
            BOMComponentTypeList=new list<SelectOption>(); 
            BOMStatusList=new list<SelectOption>();
            BOMUoMList=new list<SelectOption>();
            AVendorTypeList=new list<SelectOption>();
            AVendorStatusList=new list<SelectOption>();
            WIPTypeList= new list<SelectOption>();
            WIPUoMList=new list<SelectOption>();
            VersionRTList=new list<SelectOption>();
            RoutingRTList=new list<SelectOption>();
            BOMRTList=new list<SelectOption>();
                
        } 
    }
    
    @AuraEnabled
    public static PLMWrapper getPicklistValues(){  
        PLMWrapper wr=new PLMWrapper();     
        wr.ProductFamilyList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values1 = Schema.sObjectType.Product2.Fields.Family.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values1) wr.ProductFamilyList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.ProductTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values2 = Schema.sObjectType.Product2.Fields.ERP7__Item_Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values2) wr.ProductTypeList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.ProductCategoryList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values3 = Schema.sObjectType.Product2.Fields.ERP7__Category__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values3) wr.ProductCategoryList.add(new SelectOption(a.getValue(),a.getLabel()));        
        
        wr.ProductSubCategoryList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values4 = Schema.sObjectType.Product2.Fields.ERP7__Sub_Category__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values4) wr.ProductSubCategoryList.add(new SelectOption(a.getValue(),a.getLabel()));            
            
        wr.ProductTaxCodeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values5 = Schema.sObjectType.Product2.Fields.ERP7__Tax_Code__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values5) wr.ProductTaxCodeList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        
        wr.ProductUoMList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values6 = Schema.sObjectType.Product2.Fields.ERP7__UoM__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values6) wr.ProductUoMList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.ProductQuantityUnitOfMeasureList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values7 = Schema.sObjectType.Product2.Fields.QuantityUnitOfMeasure.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values7) wr.ProductQuantityUnitOfMeasureList.add(new SelectOption(a.getValue(),a.getLabel())); 
          
        wr.ProductStatusList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values8 = Schema.sObjectType.Product2.Fields.ERP7__Status__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values8) wr.ProductStatusList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.ProductWeightDimensionsList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values9 = Schema.sObjectType.Product2.Fields.ERP7__Weight_Dimensions__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values9) wr.ProductWeightDimensionsList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.RoutingStatusList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values10 = Schema.sObjectType.ERP7__Routing__c.Fields.ERP7__Status__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values10) wr.RoutingStatusList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.RoutingTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values11 = Schema.sObjectType.ERP7__Routing__c.Fields.ERP7__Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values11) wr.RoutingTypeList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
         wr.VersionCategoryList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values12 = Schema.sObjectType.ERP7__Version__c.Fields.ERP7__Category__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values12) wr.VersionCategoryList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.VersionStatusList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values13 = Schema.sObjectType.ERP7__Version__c.Fields.ERP7__Status__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values13) wr.VersionStatusList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.VersionTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values14 = Schema.sObjectType.ERP7__Version__c.Fields.ERP7__Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values14) wr.VersionTypeList.add(new SelectOption(a.getValue(),a.getLabel())); 
        
        wr.ReturnPolicyRefundOptionList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values15 = Schema.sObjectType.ERP7__Warranty_Return_Policy__c.Fields.ERP7__Return_Policy_Refund_Option__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values15) wr.ReturnPolicyRefundOptionList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.MediaTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values16 = Schema.sObjectType.ERP7__Media__c.Fields.ERP7__Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values16) wr.MediaTypeList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.COCategoryList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values17 = Schema.sObjectType.ERP7__Change_Order__c.Fields.ERP7__Category__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values17) wr.COCategoryList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.COTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values18 = Schema.sObjectType.ERP7__Change_Order__c.Fields.ERP7__Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values18) wr.COTypeList.add(new SelectOption(a.getValue(),a.getLabel()));
                
        wr.COStatusList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values19 = Schema.sObjectType.ERP7__Change_Order__c.Fields.ERP7__Status__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values19) wr.COStatusList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.COProjectList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values20 = Schema.sObjectType.ERP7__Change_Order__c.Fields.ERP7__Project__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values20) wr.COProjectList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.WarrantyRPRO.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values21 = Schema.sObjectType.ERP7__Warranty_Return_Policy__c.Fields.ERP7__Return_Policy_Refund_Option__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values21) wr.WarrantyRPRO.add(new SelectOption(a.getValue(),a.getLabel()));

        wr.BOMTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values22 = Schema.sObjectType.ERP7__BOM__c.Fields.ERP7__Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values22) wr.BOMTypeList.add(new SelectOption(a.getValue(),a.getLabel()));
            
        wr.BOMComponentTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values23 = Schema.sObjectType.ERP7__BOM__c.Fields.ERP7__Component_Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values23) wr.BOMComponentTypeList.add(new SelectOption(a.getValue(),a.getLabel()));
           
        wr.BOMStatusList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values24 = Schema.sObjectType.ERP7__BOM__c.Fields.ERP7__Status__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values24) wr.BOMStatusList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.BOMUoMList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values27 = Schema.sObjectType.ERP7__BOM__c.Fields.ERP7__Unit_of_Measure__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values27) wr.BOMUoMList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.AVendorTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values25 = Schema.sObjectType.ERP7__Approved_Vendor__c.Fields.ERP7__Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values25) wr.AVendorTypeList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.AVendorStatusList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values26 = Schema.sObjectType.ERP7__Approved_Vendor__c.Fields.ERP7__Status__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values26) wr.AVendorStatusList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.WIPTypeList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values28 = Schema.sObjectType.ERP7__WIP_Link__c.Fields.ERP7__Type__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values28) wr.WIPTypeList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        wr.WIPUoMList.add(new SelectOption('',' --None-- ')); 
        List<Schema.PicklistEntry> pick_list_values29 = Schema.sObjectType.ERP7__WIP_Link__c.Fields.ERP7__Quantity_Unit_Of_Measure__c.getPickListValues();
        for(Schema.PicklistEntry a:pick_list_values29) wr.WIPUoMList.add(new SelectOption(a.getValue(),a.getLabel()));
        
        list<RecordType> VersionRTList=[SELECT Id, Name FROM RecordType WHERE sObjectType='ERP7__Version__c'];
        for(RecordType rt:VersionRTList) wr.VersionRTList.add(new SelectOption(rt.Id,rt.Name));
       
        list<RecordType> RoutingRTList=[SELECT Id, Name FROM RecordType WHERE sObjectType='ERP7__Routing__c'];
        for(RecordType rt:RoutingRTList) wr.RoutingRTList.add(new SelectOption(rt.Id,rt.Name));
        
        list<RecordType> BOMRTList=[SELECT Id, Name FROM RecordType WHERE sObjectType='ERP7__BOM__c'];
        for(RecordType bm:BOMRTList) wr.BOMRTList.add(new SelectOption(bm.Id,bm.Name));
        
      return wr;
    }
    
   public class SelectOption {
    @AuraEnabled 
    public String value { get;set; }  
    @AuraEnabled
    public String label { get;set; }
    public SelectOption(String value, String label) {
        this.value = value;
        this.label = label;     
    }
   } 
    
   @AuraEnabled  
   Public Static Product2 getProduct(){
         return new Product2();
   } 
    
    @AuraEnabled  
   Public Static ERP7__Media__c getMed(){
         return new ERP7__Media__c();
   } 
   @AuraEnabled   
   Public Static ERP7__Routing__c getRou(){
         return new ERP7__Routing__c();
   }
   @AuraEnabled  
   Public Static ERP7__Version__c getVer(){
           return new ERP7__Version__c();
   }  
   @AuraEnabled  
   Public Static ERP7__Warranty_Return_Policy__c getWR(){
           return new ERP7__Warranty_Return_Policy__c();
   }  
   @AuraEnabled  
   Public Static ERP7__Change_Order__c getCO(){
           return new ERP7__Change_Order__c();
   }  
   @AuraEnabled   
   Public Static ERP7__Quality_Order__c getQua(){
           return new ERP7__Quality_Order__c();
   }  
   @AuraEnabled  
   Public Static PriceBookEntry getPriceBookEntry(){
           return new PriceBookEntry();
   }  
    
   @AuraEnabled  
   Public Static ERP7__BOM__c getBom(){
         return new ERP7__BOM__c();
   } 
   @AuraEnabled  
   Public Static ERP7__Operation__c getOperation(){
         return new ERP7__Operation__c();
   } 
   
   @AuraEnabled  
   Public Static ERP7__Approved_Vendor__c getAVendor(){
         return new ERP7__Approved_Vendor__c();
   }
       @AuraEnabled  
   Public Static ERP7__WIP_Link__c getwip(){
         return new ERP7__WIP_Link__c();
   } 
    
  
    
   @AuraEnabled
    Public Static ProductLifecycleManagement getVersionRecordDetails(String VersionId){ 
        ProductLifecycleManagement plm=new ProductLifecycleManagement();
        plM.Version=new ERP7__Version__c();                                                                               
        plM.Media=new ERP7__Media__c();
        plM.Routing=new ERP7__Routing__c();
        plM.BOM=new ERP7__BOM__c();
       
    if(String.isNotEmpty(VersionId)){ 
         plm.Version=[SELECT Id, Name, ERP7__Active__c, ERP7__Asset__c,ERP7__Asset__r.Name, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Inventory_Stock__r.Name, ERP7__Picture__c, ERP7__Preview_Image__c,
                     ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c,ERP7__Product__r.Name , ERP7__Quantity__c, RecordTypeId, RecordType.DeveloperName, RecordType.Name, ERP7__Sales_Ready__c, ERP7__Start_Date__c,     
                     ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c
                     FROM ERP7__Version__c WHERE Id=:VersionId];
           
        /*plm.MediaList=[SELECT Id, Name, ERP7__Active__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c
                         FROM ERP7__Media__c WHERE ERP7__Version__c=:VersionId Order By Name ASC]; 
         */   
        plm.RoutingList=[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                         ERP7__Work_Center__c, ERP7__Work_Center__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                         ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                         ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                         FROM ERP7__Routing__c WHERE ERP7__BOM_Version__c=:VersionId Order By Name ASC];
        
       
                          
       plm.BOMList=[SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, ERP7__BOM_Asset_Component__c, ERP7__BOM_Asset_Component__r.Name, 
                    ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Product__c, ERP7__BOM_Product__r.Name, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name,
                    ERP7__Code__c, ERP7__Component_Type__c, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Finished_Product_Amount_Delivered__c,
                    ERP7__Is_Protected__c, ERP7__PIN__c, ERP7__Partial_Replacement__c, ERP7__Phase__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.Name, ERP7__Procurement_Type__c,
                    ERP7__Product_Feature__c, ERP7__Quantity__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, 
                    ERP7__Requirement_Period_Start_Date__c, ERP7__Routing_Link__c,ERP7__Routing_Link__r.Name, ERP7__Scrap__c, ERP7__Status__c, ERP7__Type__c, ERP7__Sort__c, ERP7__Unit_of_Measure__c, ERP7__BOM_Asset__c, ERP7__BOM_Asset__r.Name
                    FROM ERP7__BOM__c WHERE ERP7__BOM_Version__c=:VersionId]; 
        
        
       
        list<ERP7__Media__c>  Medias =[SELECT Id, Name, ERP7__Active__c, ERP7__Description__c,ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c
                                       FROM ERP7__Media__c WHERE Name!=Null AND ERP7__Version__c=:VersionId Order By ERP7__Order__c ASC]; // AND ERP7__Active__c=true 
     
        Map<String, ERP7__Media__c>  MediaMap=new Map<String, ERP7__Media__c>();
        for(ERP7__Media__c m:Medias){ Attachment attach=new Attachment();
            try{   attach=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:m.Id LIMIT 1]; 
            }catch(Exception ex){  }  if(String.isNotEmpty(attach.Id)){   String attachBody=EncodingUtil.base64Encode(attach.Body);  m.ERP7__File__c=attach.Id;   MediaMap.put(attachBody, m); 
            }    
        }
        plm.MediaMap=MediaMap; 
        
        
      
       
        return plm; 
       
       
    } else return plm;      
    }
    
   @AuraEnabled
   Public Static ProductLifecycleManagement getRoutingRecordDetails(String RoutingId){ 
        ProductLifecycleManagement plm=new ProductLifecycleManagement();      
        plm.Routing=new ERP7__Routing__c();
        plm.Operation=new ERP7__Operation__c();                                                   
       
    if(String.isNotEmpty(RoutingId)){ 
        plm.Routing=[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                         ERP7__Work_Center__c, ERP7__Work_Center__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                         ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                         ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                         FROM ERP7__Routing__c WHERE Id=:RoutingId];
        
       
                          
       plm.OperationList=[SELECT Id, Name, ERP7__Auto_Clock_In__c, ERP7__Description__c, ERP7__Fixed_Cost__c, ERP7__Move_Time__c, ERP7__Next_Operation_No__c, ERP7__Operation_No__c,  ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, 
                         ERP7__Quantity__c, ERP7__Required__c, ERP7__Routing__c, ERP7__Routing__r.Name, ERP7__Routing_Link__c, ERP7__Run_Time__c, ERP7__Setup_Time__c, ERP7__Type__c , ERP7__Variable_Cost__c,
                         ERP7__Wait_Time__c, ERP7__Work_Center__c, ERP7__Work_Center__r.Name, ERP7__Work_Planner__c, ERP7__Work_Planner__r.Name 
                         FROM ERP7__Operation__c WHERE ERP7__Routing__c=:RoutingId]; 
      
       
        return plm; 
       
       
    } else return plm;      
    }
    
    
    
    @AuraEnabled
    Public Static ProductLifecycleManagement getCreateVersionRecord(String Record, String Action, String Tab, String VersionId, String ParentId, String FileName, String MediaBody, String ContentType){
        
        ProductLifecycleManagement plm=new ProductLifecycleManagement();      
        if(Tab=='ver'){  ERP7__Version__c sRecord=(ERP7__Version__c) JSON.deserialize(Record, ERP7__Version__c.class); if(String.isEmpty(sRecord.Id)) sRecord.Id=null; if(Schema.SObjectType.ERP7__Version__c.isCreateable() && Schema.SObjectType.ERP7__Version__c.isUpdateable()) upsert sRecord;
            plm.Version=[SELECT Id, Name, ERP7__Active__c, ERP7__Asset__c,ERP7__Asset__r.Name, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Inventory_Stock__r.Name, ERP7__Picture__c, ERP7__Preview_Image__c,
                        ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c,ERP7__Product__r.Name , ERP7__Quantity__c, RecordTypeId, RecordType.DeveloperName, RecordType.Name, ERP7__Sales_Ready__c, ERP7__Start_Date__c,     
                        ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c
                        FROM ERP7__Version__c WHERE Id=:sRecord.Id]; 
        }
        
        if(String.isNotEmpty(VersionId)) { 
        if(Tab=='med'){ 

		/*ERP7__Media__c sRecord=(ERP7__Media__c) JSON.deserialize(Record, ERP7__Media__c.class); if(Action!='delete') upsert sRecord;  else delete new ERP7__Media__c(Id=sRecord.Id);
            plm.MediaList=[SELECT Id, Name, ERP7__Active__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c
                         FROM ERP7__Media__c WHERE ERP7__Version__c=:VersionId Order By Name ASC]; 
            
			*/
			
	       ERP7__Media__c sRecord=(ERP7__Media__c) JSON.deserialize(Record, ERP7__Media__c.class);  if(Action!='delete'){ if(Schema.SObjectType.ERP7__Media__c.isCreateable() && Schema.SObjectType.ERP7__Media__c.isUpdateable()) upsert sRecord;
               
                try{   UploadFile.saveChunk(sRecord.Id, FileName, MediaBody,ContentType,'');  }catch(Exception ex){
                      
                 }     
           } 
           else{
               if(ERP7__Media__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Media__c(Id=sRecord.Id);}else{ /*no access*/ }  list<Attachment> attachList=new list<Attachment>();  try{ attachList=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:sRecord.Id]; }catch(Exception ex){
                      
                 }    
               if(attachList.size()>0 && Attachment.sObjectType.getDescribe().isDeletable()) {delete attachList;}else{ /*no access*/ }
            }    
           
            list<ERP7__Media__c>  Medias =[SELECT Id, Name, ERP7__Description__c, ERP7__Active__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c FROM ERP7__Media__c WHERE Name!=Null AND ERP7__Version__c=:VersionId Order By ERP7__Order__c ASC]; //AND ERP7__Active__c=true
            
            Map<String, ERP7__Media__c>  MediaMap=new Map<String, ERP7__Media__c>();
            for(ERP7__Media__c m:Medias){ Attachment attach=new Attachment(); try{  attach=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:m.Id LIMIT 1];   }catch(Exception ex){  } if(String.isNotEmpty(attach.Id)){   String attachBody=EncodingUtil.base64Encode(attach.Body);  m.ERP7__File__c=attach.Id;  MediaMap.put(attachBody, m); 
                    }    
                }
             plm.MediaMap=MediaMap; 
        }
            else if(Tab=='rou'){  ERP7__Routing__c sRecord=(ERP7__Routing__c) JSON.deserialize(Record, ERP7__Routing__c.class); if(Action!='delete') if(Schema.SObjectType.ERP7__Routing__c.isCreateable() && Schema.SObjectType.ERP7__Routing__c.isUpdateable()) upsert sRecord;  else{ if(ERP7__Routing__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Routing__c(Id=sRecord.Id); }else{ /*no access*/ }}  plm.RoutingList=[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                         ERP7__Work_Center__c, ERP7__Work_Center__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                         ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                         ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                         FROM ERP7__Routing__c WHERE ERP7__BOM_Version__c=:VersionId Order By Name ASC]; 
            
        }           
        else if(Tab=='bom'){
            ERP7__BOM__c sRecord=(ERP7__BOM__c) JSON.deserialize(Record, ERP7__BOM__c.class);  if(Action!='delete'){ if(Schema.SObjectType.ERP7__BOM__c.isCreateable() && Schema.SObjectType.ERP7__BOM__c.isUpdateable()) upsert sRecord;}  else { if(ERP7__BOM__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__BOM__c(Id=sRecord.Id); }else{ /*no access*/ }} plm.BOMList=[SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, ERP7__BOM_Asset_Component__c, ERP7__BOM_Asset_Component__r.Name, 
                    ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Product__c, ERP7__BOM_Product__r.Name, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name,
                    ERP7__Code__c, ERP7__Component_Type__c, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Finished_Product_Amount_Delivered__c,
                    ERP7__Is_Protected__c, ERP7__PIN__c, ERP7__Partial_Replacement__c, ERP7__Phase__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.Name, ERP7__Procurement_Type__c,
                    ERP7__Product_Feature__c, ERP7__Quantity__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, 
                    ERP7__Requirement_Period_Start_Date__c, ERP7__Routing_Link__c,ERP7__Routing_Link__r.Name, ERP7__Scrap__c, ERP7__Status__c, ERP7__Type__c,ERP7__Sort__c, ERP7__Unit_of_Measure__c, ERP7__BOM_Asset__c, ERP7__BOM_Asset__r.Name
                    FROM ERP7__BOM__c WHERE ERP7__BOM_Version__c=:VersionId];
            
        }
        
        }     
        return plm;
    }
    
    @AuraEnabled
    Public Static ProductLifecycleManagement getCreateRoutingRecord(String Record, String Action, String Tab, String RoutingId){
        
        ProductLifecycleManagement plm=new ProductLifecycleManagement();      
        if(Tab=='rou'){  ERP7__Routing__c sRecord=(ERP7__Routing__c) JSON.deserialize(Record, ERP7__Routing__c.class); if(String.isEmpty(sRecord.Id)) sRecord.Id=null; if(Schema.SObjectType.ERP7__Routing__c.isCreateable() && Schema.SObjectType.ERP7__Routing__c.isUpdateable()) upsert sRecord;  plm.Routing=[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                         ERP7__Work_Center__c, ERP7__Work_Center__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                         ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                         ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                         FROM ERP7__Routing__c WHERE Id=:sRecord.Id]; 
        }
        
        if(String.isNotEmpty(RoutingId)) { 
            if(Tab=='ope'){  ERP7__Operation__c sRecord=(ERP7__Operation__c) JSON.deserialize(Record, ERP7__Operation__c.class); if(Action!='delete') if(Schema.SObjectType.ERP7__Operation__c.isCreateable() && Schema.SObjectType.ERP7__Operation__c.isUpdateable()) {upsert sRecord;}  else{if(ERP7__Operation__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Operation__c(Id=sRecord.Id); }else{ /*no access*/ } }
                         plm.OperationList=[SELECT Id, Name, ERP7__Auto_Clock_In__c, ERP7__Description__c, ERP7__Fixed_Cost__c, ERP7__Move_Time__c, ERP7__Next_Operation_No__c, ERP7__Operation_No__c,  ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, 
                         ERP7__Quantity__c, ERP7__Required__c, ERP7__Routing__c, ERP7__Routing__r.Name, ERP7__Routing_Link__c, ERP7__Run_Time__c, ERP7__Setup_Time__c, ERP7__Type__c , ERP7__Variable_Cost__c,
                         ERP7__Wait_Time__c, ERP7__Work_Center__c, ERP7__Work_Center__r.Name, ERP7__Work_Planner__c, ERP7__Work_Planner__r.Name 
                         FROM ERP7__Operation__c WHERE ERP7__Routing__c=:RoutingId Order By Name ASC]; 
            
        }        
        } 
        
        return plm;
    }
     @AuraEnabled
   public static ProductLifecycleManagement getCloneRelatedRecords (String ProductIdOld, String ProductIdNew){

       ProductLifecycleManagement PLM = new ProductLifecycleManagement();
       list<ERP7__Media__c> medialist = new list<ERP7__Media__c>();
       list<ERP7__Version__c> VersionList  = new list<ERP7__Version__c>();
       list<ERP7__Routing__c> RoutingList= new list<ERP7__Routing__c>();
       list<PricebookEntry> PBEList = new list<PricebookEntry>();
       list<ERP7__Warranty_Return_Policy__c> WarrantyRPList = new list<ERP7__Warranty_Return_Policy__c>();
       list<ERP7__Approved_Vendor__c> AVendorList = new list<ERP7__Approved_Vendor__c>();
       list<ERP7__BOM__c> BOMList = new list<ERP7__BOM__c>();
       list<ERP7__Change_Order__c> ChangeOrderList = new list<ERP7__Change_Order__c>();
       list<ERP7__Quality_Order__c> QualityOrderList = new list<ERP7__Quality_Order__c>();
       list<ERP7__WIP_Link__c> WIPList = new list<ERP7__WIP_Link__c>();
       
       if(String.isNotEmpty(ProductIdOld) && String.isNotEmpty(ProductIdNew) && Schema.sObjectType.Product2.fields.Name.isAccessible()){
          //For Version
          Map<String, String> ver = new Map<String, String>();
          if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isAccessible())
              for(ERP7__Version__c version:[SELECT Id, Name, ERP7__Active__c, ERP7__Asset__c,ERP7__Asset__r.Name, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Inventory_Stock__r.Name, ERP7__Picture__c, ERP7__Preview_Image__c,
                                            ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c,ERP7__Product__r.Name , ERP7__Quantity__c, RecordTypeId, RecordType.DeveloperName, RecordType.Name, ERP7__Sales_Ready__c, ERP7__Start_Date__c,     
                                            ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c
                                            FROM ERP7__Version__c WHERE ERP7__Product__c=:ProductIdOld]){
                                            ERP7__Version__c versionclonecopy = version.clone(false, false, false, false); 
                                              if ( Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isAccessible() &&  Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isUpdateable()) {
                                                  versionclonecopy.ERP7__Product__c = ProductIdNew;
                                                  }
                                                VersionList.add(versionclonecopy);
                                                ver.put(version.Id, null);
                                            }
          if(VersionList.size()>0 && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isUpdateable() && Schema.SObjectType.ERP7__Version__c.isCreateable() && Schema.SObjectType.ERP7__Version__c.isUpdateable()) upsert VersionList;
          integer c=0; 
          for(String v : ver.keyset()){
              ver.put(v, VersionList[c].Id); c = c+1;
          }
          integer count = 0;
          
          //For Routings
          Map<String, String> RouVersion = new Map<String, String>();
          if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Product__c.isAccessible())
              for(ERP7__Routing__c rou:[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                                        ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                                        ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                                        ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                                        FROM ERP7__Routing__c WHERE ERP7__Product__c=:ProductIdOld ]){
                                        RouVersion.Put(rou.Id,ver.get(rou.ERP7__BOM_Version__c));
                                        
                                      }
            for(ERP7__Routing__c rou:[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                                      ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                                      ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                                      ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                                      FROM ERP7__Routing__c WHERE ERP7__Product__c=:ProductIdOld ]){
                                          
                                          ERP7__Routing__c rouclonecopy = rou.clone(false, false, false, false);
                                          
                                          rouclonecopy.ERP7__Product__c=ProductIdNew;
                                          rouclonecopy.ERP7__BOM_Version__c=RouVersion.get(rou.Id);//VersionList[count].Id;
                                          RoutingList.add(rouclonecopy);
                                          count = count + 1;
                                      }
          if(RoutingList.size()>0 && schema.SObjectType.ERP7__Routing__c.isCreateable() && schema.SObjectType.ERP7__Routing__c.isUpdateable()){upsert RoutingList;}
           
           //For PBE
           Product2 Product =new Product2();
           Product=[Select name from Product2 where id=:ProductIdOld];
           PriceBook2 pb =new PriceBook2();
           pb.name=Product.Name+String.Valueof(' Custom Price Book');
           pb.IsActive=true;
          //insert pb;
           
           List<Pricebook2>  spb=[SELECT Id, Name, IsActive, IsStandard FROM Pricebook2 WHERE IsStandard=true Order By LastModifiedDate DESC LIMIT 1];
          
       if(Schema.sObjectType.PricebookEntry.fields.Product2Id.isAccessible())
            for(PricebookEntry Pbe :[SELECT Id, Name, IsActive, ERP7__Admin_Shipping_Price__c, ERP7__Barcode__c, ERP7__Check_Out_Process__c, ERP7__Description__c, ERP7__Discount_Plan__c, ERP7__Discount_Plan__r.Name, 
                                     ERP7__End_Date__c, UnitPrice, ERP7__Notes__c, Pricebook2Id, Pricebook2.Name ,Product2Id, Product2.Name, ProductCode, ERP7__Product_Version__c, ERP7__Product_Version__r.Name, 
                                     ERP7__Purchase_Price__c, ERP7__Selling_Price__c, ERP7__Shipping_Price__c, ERP7__Start_Date__c, ERP7__Tax_Exempt__c, ERP7__Tax_Plan__c, ERP7__Tax_Plan__r.Name, ERP7__Tax_Rate__c, UseStandardPrice, ERP7__Warranty_Return_Policy__c, ERP7__Warranty_Return_Policy__r.Name
                                     FROM PriceBookEntry WHERE Product2Id=:ProductIdOld Order By Name ASC limit 1]){
                                          PricebookEntry pbeclonecopy = Pbe.clone(false, false, false, false);
                                          pbeclonecopy.Product2Id = ProductIdNew;
                                          pbeclonecopy.UseStandardPrice=false;
                                          if(spb.size()>0)pbeclonecopy.Pricebook2Id=spb[0].id;
                                          PBEList.add(pbeclonecopy);
                                      }
                    
          if(PBEList.size()>0 && Schema.SObjectType.PricebookEntry.isCreateable() && Schema.SObjectType.PricebookEntry.isUpdateable()){upsert PBEList;}
          
      //For WRP
      if(Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.ERP7__Product__c.isAccessible())
          for(ERP7__Warranty_Return_Policy__c wrp :[SELECT Id, Name, ERP7__Active__c, ERP7__Code__c, ERP7__Days_of_Warranty__c, ERP7__Description__c, ERP7__Exchange__c,
                                                    ERP7__Asset__c, ERP7__Asset__r.Name, ERP7__Guideline__c, ERP7__Guideline__r.Name, ERP7__Number_Days_From_Trans_Return_Accepted__c, ERP7__Organisation__c, ERP7__Organisation__r.Name,
                                                    ERP7__Organisation_Business_Unit__c, ERP7__Organisation_Business_Unit__r.Name, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Return_Policy_Refund_Option__c, ERP7__Standard_Manufacturing_Warranty__c
                                                    FROM ERP7__Warranty_Return_Policy__c WHERE NAME!=Null  AND ERP7__Product__c=:ProductIdOld Order By Name ASC]){
                                                        ERP7__Warranty_Return_Policy__c wrpclonecopy = wrp.clone(false, false, false, false);
                                                        if ( Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.ERP7__Product__c.isAccessible() && Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.ERP7__Product__c.isUpdateable()){
                                                            wrpclonecopy.ERP7__Product__c=ProductIdNew; 
                                                        }
                                                        WarrantyRPList.add(wrpclonecopy);
                                                        }
          if(WarrantyRPList.size()>0 && Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.ERP7__Product__c.isUpdateable() && schema.SObjectType.ERP7__Warranty_Return_Policy__c.isCreateable() && schema.SObjectType.ERP7__Warranty_Return_Policy__c.isUpdateable()){upsert WarrantyRPList;}
      
        //For AV
      if(Schema.sObjectType.ERP7__Approved_Vendor__c.fields.ERP7__Product__c.isAccessible())
          for(ERP7__Approved_Vendor__c AV :[SELECT Id, Name, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Lead_Time__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Status__c, ERP7__Type__c, ERP7__Vendor__c, ERP7__Vendor__r.Name
                                            FROM ERP7__Approved_Vendor__c WHERE ERP7__Product__c=:ProductIdOld Order By Name ASC]){
                                            ERP7__Approved_Vendor__c AVclonecopy = AV.clone(false, false, false, false);
                                                if ( Schema.sObjectType.ERP7__Approved_Vendor__c.fields.ERP7__Product__c.isAccessible() && Schema.sObjectType.ERP7__Approved_Vendor__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Approved_Vendor__c.fields.ERP7__Product__c.isUpdateable()){
                                                    AVclonecopy.ERP7__Product__c=ProductIdNew; 
                                                }
                                                AVendorList.add(AVclonecopy);
                                                }
            if(AVendorList.size()>0 && schema.SObjectType.ERP7__Approved_Vendor__c.isCreateable() && schema.SObjectType.ERP7__Approved_Vendor__c.isUpdateable()){upsert AVendorList;}
      
       //For BOM
        Map<String, String> BomVer = new Map<String, string>();
           
       if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isAccessible())
           for(ERP7__BOM__c BO:[SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, ERP7__BOM_Asset_Component__c, ERP7__BOM_Asset_Component__r.Name, 
                                ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Product__c, ERP7__BOM_Product__r.Name, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name,
                                ERP7__Code__c, ERP7__Component_Type__c, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Finished_Product_Amount_Delivered__c,
                                ERP7__Is_Protected__c, ERP7__PIN__c, ERP7__Partial_Replacement__c, ERP7__Phase__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Process_Cycle__c, ERP7__Procurement_Type__c,
                                ERP7__Product_Feature__c, ERP7__Quantity__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, 
                                ERP7__Requirement_Period_Start_Date__c, ERP7__Routing_Link__c, ERP7__Scrap__c, ERP7__Status__c, ERP7__Type__c,ERP7__Sort__c, ERP7__Unit_of_Measure__c, ERP7__BOM_Asset__c, ERP7__BOM_Asset__r.Name,
                                ERP7__Maximum_Variance__c, ERP7__Minimum_Variance__c FROM ERP7__BOM__c WHERE ERP7__BOM_Product__c=:ProductIdOld Order By Name ASC]){
                                    BomVer.put(BO.Id, ver.get(String.valueof(BO.ERP7__BOM_Version__c)));
                                    }
                               
          for(ERP7__BOM__c BO:[SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, ERP7__BOM_Asset_Component__c, ERP7__BOM_Asset_Component__r.Name, 
                               ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Product__c, ERP7__BOM_Product__r.Name, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name,
                               ERP7__Code__c, ERP7__Component_Type__c, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Finished_Product_Amount_Delivered__c,
                               ERP7__Is_Protected__c, ERP7__PIN__c, ERP7__Partial_Replacement__c, ERP7__Phase__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.Name, ERP7__Procurement_Type__c,
                               ERP7__Product_Feature__c, ERP7__Quantity__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, 
                               ERP7__Requirement_Period_Start_Date__c, ERP7__Routing_Link__c,ERP7__Routing_Link__r.Name, ERP7__Scrap__c, ERP7__Status__c, ERP7__Type__c, ERP7__Sort__c, ERP7__Unit_of_Measure__c, ERP7__BOM_Asset__c, ERP7__BOM_Asset__r.Name,
                               ERP7__Maximum_Variance__c, ERP7__Minimum_Variance__c FROM ERP7__BOM__c WHERE ERP7__BOM_Product__c=:ProductIdOld Order By Name ASC]){
                                   ERP7__BOM__c BOclonecopy = BO.clone(false, false, false, false);
                                   BOclonecopy.ERP7__BOM_Product__c=ProductIdNew;
                                   BOclonecopy.ERP7__BOM_Version__c= BomVer.get(BO.Id);   //VersionList[i].Id;
                                   BOMList.add(BOclonecopy);
                                            } 
          if(BOMList.size()>0 && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isUpdateable() && Schema.SObjectType.ERP7__BOM__c.isCreateable() && Schema.SObjectType.ERP7__BOM__c.isUpdateable()){upsert BOMList;} 
          
  //For wip
  if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Product__c.isAccessible())
  for( ERP7__WIP_Link__c wi:[Select Id, Name, ERP7__Type__c, ERP7__Quantity_Unit_Of_Measure__c, ERP7__Process_Cycle__c, ERP7__Process_Cycle__r.Name, ERP7__Process_Output_Product__c, ERP7__Process_Output_Product__r.Name,
                             ERP7__Process_Output_Version__c, ERP7__Process_Output_Version__r.Name, ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Version__c, ERP7__Version__r.Name,
                             ERP7__Quantity_Unit__c, ERP7__Product__c, ERP7__Product__r.Name From ERP7__WIP_Link__c Where ERP7__Product__c=:ProductIdOld Order By Name ASC]){
                                 ERP7__WIP_Link__c wiclonecopy= wi.clone(false, false, false, false);
                                 wiclonecopy.ERP7__Product__c =ProductIdNew;
                                 
                                 WIPList.add(wiclonecopy);
                             } 
          if(WIPList.size()>0 && Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Product__c.isUpdateable() && Schema.SObjectType.ERP7__WIP_Link__c.isCreateable() && Schema.SObjectType.ERP7__WIP_Link__c.isUpdateable()){upsert WIPList;}
          
          //For Media
          if(Schema.sObjectType.ERP7__Media__c.fields.ERP7__Product__c.isAccessible())
              for(ERP7__Media__c Medias:[SELECT Id, Name, ERP7__Active__c, ERP7__Description__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c
                                         FROM ERP7__Media__c WHERE ERP7__Product__c=:ProductIdOld Order By ERP7__Order__c ASC]){
                                             ERP7__Media__c mediaclonecopy=Medias.clone(false, false, false, false);
                                             mediaclonecopy.ERP7__Product__c= ProductIdNew;
                                             medialist.add(mediaclonecopy);
                                         }
          if(medialist.size()>0 && Schema.SObjectType.ERP7__Media__c.isCreateable() && Schema.SObjectType.ERP7__Media__c.isUpdateable() && Schema.sObjectType.ERP7__Media__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Media__c.fields.ERP7__Product__c.isUpdateable()){upsert medialist;} 
          
      //For CO
      if(Schema.sObjectType.ERP7__Change_Order__c.fields.ERP7__type__c.isAccessible())
         for(ERP7__Change_Order__c CO :[SELECT Id, Name, ERP7__Category__c, ERP7__Project__c, ERP7__Project__r.Name, ERP7__Status__c, ERP7__type__c
                                        FROM ERP7__Change_Order__c WHERE Name!=Null Order By Name ASC]){
                                            ERP7__Change_Order__c COclonecopy = CO.clone(false, false, false, false);
                                            ChangeOrderList.add(COclonecopy);    
                                        }
                 //if(ChangeOrderList.size()>0 && schema.SObjectType.ERP7__Change_Order__c.isCreateable() && schema.SObjectType.ERP7__Change_Order__c.isUpdateable()){upsert ChangeOrderList;}

       //For QO
       if(Schema.sObjectType.ERP7__Quality_Order__c.isAccessible())
          for(ERP7__Quality_Order__c QO :[SELECT Id, Name FROM  ERP7__Quality_Order__c WHERE Name !=Null Order By Name ASC limit 2]){
                                          ERP7__Quality_Order__c QOclonecopy = QO.clone(false, false, false, false);
                                              QualityOrderList.add(QOclonecopy);
                }
              //if(QualityOrderList.size()>0 && schema.SObjectType.ERP7__Quality_Order__c.isCreateable() && schema.SObjectType.ERP7__Quality_Order__c.isUpdateable()){upsert QualityOrderList;}

          //For media
       list<ERP7__Media__c>  Medias =[SELECT Id, Name, ERP7__Active__c, ERP7__Description__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c
                                       FROM ERP7__Media__c WHERE Name!=Null AND ERP7__Product__c=:ProductIdOld Order By ERP7__Order__c ASC];
                                     //mediaclonecopy.ERP7__Product__c= ProductIdNew;
                                    // medialist.add(mediaclonecopy);
        Map<String, ERP7__Media__c>  MediaMap=new Map<String, ERP7__Media__c>();
        for(ERP7__Media__c m:Medias){ Attachment attach=new Attachment();
            try{   attach=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:m.Id LIMIT 1]; 
            }catch(Exception ex){  }  if(String.isNotEmpty(attach.Id)){   String attachBody=EncodingUtil.base64Encode(attach.Body);  m.ERP7__File__c=attach.Id;   MediaMap.put(attachBody, m); 
            }    
        }
        plm.MediaMap=MediaMap; 
          //if(medialist.size()>0){ upsert medialist;}
          if(Medias.size()>0 && Schema.SObjectType.ERP7__Media__c.isCreateable() && Schema.SObjectType.ERP7__Media__c.isUpdateable()){ upsert Medias;}
          
      ProductLifeCycleManagement Reclist=getRecords(ProductIdNew); 
          PLM.VersionList= Reclist.VersionList; PLM.RoutingList=Reclist.RoutingList; 
          PLM.PBEList=Reclist.PBEList;
          PLM.WarrantyRPlist = Reclist.WarrantyRPlist; 
          PLM.AVendorList = Reclist.AVendorList; 
          PLm.ChangeOrderList=Reclist.ChangeOrderList;
          PLM.QualityOrderList = Reclist.QualityOrderList;
          PLM.BOMList = RecList.BOMList;
          PLM.WIPList = RecList.WIPList;
          PLM.medialist = Reclist.medialist;
          return PLM;
      }
    else
       return PLM;
   }
     @AuraEnabled
   public static ProductLifecycleManagement getVersionCloneRelatedRecords (String VersionIdOld, String VersionIdNew){
       ProductLifecycleManagement PLM = new ProductLifecycleManagement();
        list<ERP7__BOM__c> BOMList = new list<ERP7__BOM__c>();
        list<ERP7__Routing__c> RoutingList= new list<ERP7__Routing__c>();
        list<ERP7__Media__c> medialist = new list<ERP7__Media__c>();
       if(String.isNotEmpty(VersionIdOld) && String.isNotEmpty(VersionIdNew) && Schema.sObjectType.Product2.fields.Name.isAccessible()){
        //For Bom
          if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isAccessible())
          for(ERP7__BOM__c BO:[SELECT Id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__BOM_Alternate_Of__c, ERP7__BOM_Alternate_Of__r.Name, ERP7__BOM_Asset_Component__c, ERP7__BOM_Asset_Component__r.Name, 
                               ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Product__c, ERP7__BOM_Product__r.Name, ERP7__BOM_Level__c, ERP7__BOM_Notes__c, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name,
                               ERP7__Code__c, ERP7__Component_Type__c, ERP7__Cost_Card__c, ERP7__Cost_Card__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Finished_Product_Amount_Delivered__c,
                               ERP7__Is_Protected__c, ERP7__PIN__c, ERP7__Partial_Replacement__c, ERP7__Phase__c, ERP7__Manufacturing_Assembly_Process__c, ERP7__Process_Cycle__c,ERP7__Process_Cycle__r.Name, ERP7__Procurement_Type__c,
                               ERP7__Product_Feature__c, ERP7__Quantity__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, ERP7__Reference_Designators__c, ERP7__Requirement_Period_End_Time__c, 
                               ERP7__Requirement_Period_Start_Date__c, ERP7__Routing_Link__c,ERP7__Routing_Link__r.Name, ERP7__Scrap__c, ERP7__Status__c, ERP7__Type__c,ERP7__Sort__c, ERP7__Unit_of_Measure__c, ERP7__BOM_Asset__c, ERP7__BOM_Asset__r.Name,
                               ERP7__Maximum_Variance__c, ERP7__Minimum_Variance__c FROM ERP7__BOM__c WHERE ERP7__BOM_Version__c=:VersionIdOld Order By Name ASC]){
                                   ERP7__BOM__c BOclonecopy = BO.clone(false, false, false, false);
                                   BOclonecopy.ERP7__BOM_Version__c=VersionIdNew;
                                   BOMList.add(BOclonecopy);
                                   
                                            }
          if(BOMList.size()>0 && Schema.SObjectType.ERP7__BOM__c.isCreateable() && Schema.SObjectType.ERP7__BOM__c.isUpdateable()){upsert BOMList;} 
           
           //For Routings
        if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__BOM_Version__c.isAccessible())
            for(ERP7__Routing__c rou:[SELECT Id, Name, ERP7__BOM_Version__c, ERP7__BOM_Version__r.Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Description__c, ERP7__Distribution_Channel__c, ERP7__Distribution_Channel__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__Expected_Date__c,
                                      ERP7__Finished_Products_Site__c, ERP7__Finished_Products_Site__r.Name, ERP7__Loading_Dropping_point__c, ERP7__Loading_Dropping_point__r.Name, ERP7__Maximum_Lot_Size__c, ERP7__Minimum_Lot_Size__c, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Process__c, ERP7__Process__r.Name,
                                      ERP7__Product__c, ERP7__Product__r.Name, ERP7__Raw_Materials_Site__c, ERP7__Raw_Materials_Site__r.Name, RecordTypeId, RecordType.Name, RecordType.DeveloperName,
                                      ERP7__Shipment_Type__c, ERP7__Shipper__c, ERP7__Shipper__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Status__c, ERP7__Type__c
                                      FROM ERP7__Routing__c WHERE ERP7__BOM_Version__c=:VersionIdOld]){
                                          ERP7__Routing__c rouclonecopy = rou.clone(false, false, false, false);
                                          rouclonecopy.ERP7__BOM_Version__c=VersionIdNew;
                                          RoutingList.add(rouclonecopy);
                                      }
          if(RoutingList.size()>0 && schema.SObjectType.ERP7__Routing__c.isCreateable() && schema.SObjectType.ERP7__Routing__c.isUpdateable()){upsert RoutingList;}
           
           //For Media
          if(Schema.sObjectType.ERP7__Media__c.fields.ERP7__Version__c.isAccessible())
              for(ERP7__Media__c Medias:[SELECT Id, Name, ERP7__Active__c, ERP7__Description__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c
                                         FROM ERP7__Media__c WHERE ERP7__Version__c=:VersionIdOld Order By ERP7__Order__c ASC]){
                                             ERP7__Media__c mediaclonecopy=Medias.clone(false, false, false, false);
                                             mediaclonecopy.ERP7__Product__c= VersionIdNew;
                                             medialist.add(mediaclonecopy);  
                                         }
          if(medialist.size()>0 && Schema.SObjectType.ERP7__Media__c.isCreateable() && Schema.SObjectType.ERP7__Media__c.isUpdateable()){upsert medialist;} 
           
          //For media
        list<ERP7__Media__c>  Medias =[SELECT Id, Name, ERP7__Description__c, ERP7__Active__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Type__c, ERP7__Version__c, ERP7__Version__r.Name, ERP7__File__c, ERP7__Order__c FROM ERP7__Media__c WHERE Name!=Null AND ERP7__Version__c=:VersionIdOld Order By ERP7__Order__c ASC];
          //mediaclonecopy.ERP7__Product__c= ProductIdNew;
         // medialist.add(mediaclonecopy);
        Map<String, ERP7__Media__c>  MediaMap=new Map<String, ERP7__Media__c>();
        for(ERP7__Media__c m:Medias){ Attachment attach=new Attachment();
            try{   attach=[SELECT Id, Name, ParentId, Body FROM  Attachment WHERE ParentId=:m.Id LIMIT 1]; 
            }catch(Exception ex){  }  if(String.isNotEmpty(attach.Id)){   String attachBody=EncodingUtil.base64Encode(attach.Body);  m.ERP7__File__c=attach.Id;   MediaMap.put(attachBody, m); 
            }    
        }
        plm.MediaMap=MediaMap; 
          //if(medialist.size()>0){ upsert medialist;}
          if(Medias.size()>0&& Schema.SObjectType.ERP7__Media__c.isCreateable() && Schema.SObjectType.ERP7__Media__c.isUpdateable()){ upsert Medias;} 
           
           ProductLifeCycleManagement Reclist=getVersionRecordDetails(VersionIdNew);
           PLM.BOMList = RecList.BOMList;
           PLM.RoutingList=Reclist.RoutingList;
           PLM.medialist = Reclist.medialist;
            //PLM.mediamap = Reclist.mediamap;
             return PLM;
       }
       else
       return PLM;
   }
       
    @AuraEnabled 
    Public Static Attachment AttachmentmentDetails(String atId){   
       return [SELECT Id, Name FROM Attachment WHERE Id=:atId];     
    } 
 
}