public with sharing class ProductConfig 
{ 
    @AuraEnabled public String productId {get;set;}
    
    @AuraEnabled
    public static Product2 saveProduct(String products1) {
        Product2 products = (Product2) JSON.deserialize(products1, Product2.class);
        if (products != null) {               
                if(Schema.sObjectType.Product2.fields.IsActive.isCreateable() && Schema.sObjectType.Product2.fields.IsActive.isUpdateable())  {products.IsActive = true; }else{ /* no access*/ }
            if (Schema.SObjectType.Product2.isCreateable() && Schema.SObjectType.Product2.isUpdateable()){ upsert products; } else{ /* no access*/ }
        }
        return products;} 
    @AuraEnabled public static list < priceBookEntry > SavePricebook(String pbe, String productId) { list < priceBookEntry > pbEnt = (list < priceBookEntry > ) JSON.deserialize(pbe, list < priceBookEntry > .class); for (integer i = 0; i < pbEnt.size(); i++) { if(pbEnt[i].Product2Id == null && Schema.sObjectType.priceBookEntry.fields.product2id.isCreateable() && Schema.sObjectType.priceBookEntry.fields.product2id.isUpdateable()){ pbEnt[i].Product2Id = productId; } else{/* no access*/ } } if(Schema.sObjectType.priceBookEntry.isCreateable() && Schema.sObjectType.priceBookEntry.isUpdateable()){ upsert pbEnt;}else{/* no access*/ } return pbEnt;}
    
    @AuraEnabled
    public static priceBookEntry pricebookEntry2Insert(String newPBE1, String productId) {
        priceBookEntry newPBE = (priceBookEntry) JSON.deserialize(newPBE1, priceBookEntry.class);
        if (newPBE != null) {
            if (Schema.SObjectType.priceBookEntry.isCreateable() && Schema.SObjectType.priceBookEntry.isUpdateable())
                if(newPBE.Product2Id == null && Schema.sObjectType.priceBookEntry.fields.Product2Id.isCreateable() && Schema.sObjectType.priceBookEntry.fields.Product2Id.isUpdateable()) {newPBE.Product2Id = productId;} else{/* no access*/}
            if(Schema.sObjectType.priceBookEntry.isCreateable() && Schema.sObjectType.priceBookEntry.isUpdateable()) {upsert newPBE;} else{/* no access*/}
        }
        return newPBE;
    }
    
    @AuraEnabled
    public static list < priceBookEntry > fetchPricebook(String prId) {
        List<priceBookEntry> pbe;
        pbe = [Select Id, Name, IsActive, UnitPrice,Pricebook2Id, Pricebook2.IsStandard, Pricebook2.Name, Product2Id, ERP7__Barcode__c, ERP7__Purchase_Price__c, ERP7__Selling_Price__c, Product2.ERP7__Track_Inventory__c, ERP7__Warranty_Return_Policy__c, ERP7__Tax_Exempt__c, ERP7__Discount_Plan__c   
               From priceBookEntry Where Product2Id =: prId];
        return pbe;
    }
    
    @AuraEnabled
    public static priceBookEntry getPricebookentrybyId(String recId){
        return [select id, Name, IsActive, UnitPrice, Product2.ERP7__Track_Inventory__c, ERP7__Selling_Price__c, Product2Id, Pricebook2Id, ERP7__Purchase_Price__c, ERP7__Barcode__c, Pricebook2.Name, ERP7__Warranty_Return_Policy__c, ERP7__Tax_Exempt__c, ERP7__Discount_Plan__c
                From priceBookEntry where Id =: recId];
    }
    
    @AuraEnabled
    public static Boolean deletePriceBook(Id recId) {
        priceBookEntry pbes = [SELECT Id FROM priceBookEntry WHERE Id = :recId];
        if(priceBookEntry.sObjectType.getDescribe().isDeletable()) { delete pbes; } else{ /* no access*/ }
        return true;} 
    @AuraEnabled public static ERP7__Tier_Discount_Allocation__c SaveTDA2(String tda2, String tdaId) { list < ERP7__Tier_Discount_Allocation__c > tdaVal = (list < ERP7__Tier_Discount_Allocation__c > ) JSON.deserialize(tda2, list < ERP7__Tier_Discount_Allocation__c > .class); for (integer i = 0; i < tdaVal.size(); i++) tdaVal[i].ERP7__Product__c = tdaId;if(Schema.sObjectType.ERP7__Tier_Discount_Allocation__c.fields.erp7__product__c.isCreateable() && Schema.sObjectType.ERP7__Tier_Discount_Allocation__c.fields.erp7__product__c.isUpdateable()){ upsert tdaVal;}else{ } return null;} @AuraEnabled public static ERP7__Tier_Discount_Allocation__c tdaRecord2Insert(String newTDA1, String productId) { ERP7__Tier_Discount_Allocation__c newTDA = (ERP7__Tier_Discount_Allocation__c)JSON.deserialize(newTDA1, ERP7__Tier_Discount_Allocation__c.class);  if (newTDA != null) {if (Schema.SObjectType.ERP7__Tier_Discount_Allocation__c.isCreateable() && Schema.SObjectType.ERP7__Tier_Discount_Allocation__c.isUpdateable()) newTDA.ERP7__Product__c = productId; if(Schema.sObjectType.ERP7__Tier_Discount_Allocation__c.fields.erp7__product__c.isCreateable() && Schema.sObjectType.ERP7__Tier_Discount_Allocation__c.fields.erp7__product__c.isUpdateable()){ upsert newTDA;}else{ } } return newTDA;}
    
    @AuraEnabled
    public static Boolean deleteTierDiscounts(Id recId) {
        ERP7__Tier_Discount_Allocation__c tda = [SELECT Id FROM ERP7__Tier_Discount_Allocation__c WHERE Id = :recId];
        if(ERP7__Tier_Discount_Allocation__c.sObjectType.getDescribe().isDeletable()) {delete tda; } else{ /* no access*/ }
        return true; }
    @AuraEnabled public static ERP7__Tier_Discount_Allocation__c getTDAbyId(String recId){ return [select id, Name, ERP7__Active__c, ERP7__Code__c, ERP7__Default__c, ERP7__Discount_Plan__r.Name, ERP7__Order_Profile__r.Name, ERP7__Price_Book__c, ERP7__Tier__r.Name From ERP7__Tier_Discount_Allocation__c where Id =: recId];}
    @AuraEnabled public static ERP7__Warranty_Return_Policy__c SaveWarranty(String war, String warId) { list < ERP7__Warranty_Return_Policy__c > warListToUpsert = (list < ERP7__Warranty_Return_Policy__c > ) JSON.deserialize(war, list < ERP7__Warranty_Return_Policy__c > .class); for (integer i = 0; i < warListToUpsert.size(); i++) warListToUpsert[i].ERP7__Product__c = warId; if(Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.erp7__product__c.isCreateable() && Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.erp7__product__c.isUpdateable()){ upsert warListToUpsert;}else{ } return null;} @AuraEnabled public static ERP7__Warranty_Return_Policy__c warrantyAndReturn2Insert(String newWarrantyReturn1, String productId) { ERP7__Warranty_Return_Policy__c newWarrantyReturn = (ERP7__Warranty_Return_Policy__c)JSON.deserialize(newWarrantyReturn1, ERP7__Warranty_Return_Policy__c.class);  if (newWarrantyReturn != null) { if (Schema.SObjectType.ERP7__Warranty_Return_Policy__c.isCreateable() && Schema.SObjectType.ERP7__Warranty_Return_Policy__c.isUpdateable()) newWarrantyReturn.ERP7__Product__c = productId; if(newWarrantyReturn.ERP7__Product__c == null) newWarrantyReturn.ERP7__Product__c = productId;if(Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.erp7__product__c.isCreateable() && Schema.sObjectType.ERP7__Warranty_Return_Policy__c.fields.erp7__product__c.isUpdateable()){upsert newWarrantyReturn;}else{ } } return newWarrantyReturn; } @AuraEnabled public static ERP7__Warranty_Return_Policy__c getWarrantyById(String recId){ return [select id, Name, ERP7__Active__c, ERP7__Code__c, ERP7__Days_of_Warranty__c, ERP7__Exchange__c , ERP7__Asset__c, ERP7__Number_Days_From_Trans_Return_Accepted__c, ERP7__Product__c, ERP7__Standard_Manufacturing_Warranty__c From ERP7__Warranty_Return_Policy__c where Id =: recId]; }
    
    @AuraEnabled
    public static Boolean deleteWarrantyRecord(Id recId) {
        ERP7__Warranty_Return_Policy__c warranty = [SELECT Id FROM ERP7__Warranty_Return_Policy__c WHERE Id = :recId];
        if(ERP7__Warranty_Return_Policy__c.sObjectType.getDescribe().isDeletable()){ delete warranty;} else{ /* no access*/ }
        return true;}@AuraEnabled public static ERP7__Version__c SaveBOMVersion(String bomV, String bomVId) { list < ERP7__Version__c > bomVersionListToUpsert = (list < ERP7__Version__c > ) JSON.deserialize(bomV, list < ERP7__Version__c > .class); for (integer i = 0; i < bomVersionListToUpsert.size(); i++) bomVersionListToUpsert[i].ERP7__Product__c = bomVId; if(Schema.sObjectType.ERP7__Version__c.fields.erp7__product__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.erp7__product__c.isUpdateable()){ upsert bomVersionListToUpsert;}else{ } return bomVersionListToUpsert[0];}
    
    @AuraEnabled
    public static Boolean deleteProductVersion(Id recId) {
        ERP7__Version__c versions = [SELECT Id FROM ERP7__Version__c WHERE Id = :recId];
        if(ERP7__Version__c.sObjectType.getDescribe().isDeletable()) {delete versions;} else{ /* no access*/ }
        return true;
    }
    
    @AuraEnabled
    public static Id deleteVersions(Id recordId) {
        Id oldVersionId = null;
        try {
            if(ERP7__Version__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__Version__c(Id = recordId);} else{ /* no access*/ } oldVersionId = recordId;
        }
        catch (System.Exception caught) {
        }
        
        return oldVersionId;
    }
    
    @AuraEnabled
    public static Id deleteBOMVersions(Id recordId) {
        Id oldVersionId = null;
        try {if(ERP7__BOM__c.sObjectType.getDescribe().isDeletable()){ delete new ERP7__BOM__c(Id = recordId); } else{/* no aceess*/} oldVersionId = recordId;} catch (System.Exception caught) {}
        return oldVersionId;}@AuraEnabled public static ERP7__BOM__c SaveBillOfMaterials(String bom, String bomId, String vId) { list < ERP7__BOM__c > bomListToUpsert = (list < ERP7__BOM__c > ) JSON.deserialize(bom, list < ERP7__BOM__c > .class); for (integer i = 0; i < bomListToUpsert.size(); i++) { bomListToUpsert[i].ERP7__BOM_Product__c = bomId; bomListToUpsert[i].ERP7__BOM_Version__c = vId; }if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isUpdateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()){ upsert bomListToUpsert;}else{ }return bomListToUpsert[0];} 
    @AuraEnabled public static ERP7__Routing__c insertRoutings(String rout, String routId, String vId) {list < ERP7__Routing__c > routingListToUpsert = (list < ERP7__Routing__c > ) JSON.deserialize(rout, list < ERP7__Routing__c > .class); for (integer i = 0; i < routingListToUpsert.size(); i++){ routingListToUpsert[i].ERP7__Product__c = routId; routingListToUpsert[i].ERP7__BOM_Version__c = vId; }if(Schema.sObjectType.ERP7__Routing__c .fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Routing__c .fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Routing__c .fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Routing__c .fields.ERP7__BOM_Version__c.isUpdateable()){ upsert routingListToUpsert;}else{ } return routingListToUpsert[0];  } @AuraEnabled public static ERP7__Operation__c insertOperations(String opr, String rId) { list < ERP7__Operation__c > operationToUpsert = (list < ERP7__Operation__c > ) JSON.deserialize(opr, list < ERP7__Operation__c > .class); for (integer i = 0; i < operationToUpsert.size(); i++) {operationToUpsert[i].ERP7__Routing__c = rId;} if(Schema.sObjectType.ERP7__Operation__c .fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c .fields.ERP7__Routing__c.isUpdateable()){ upsert operationToUpsert;}else{ } return operationToUpsert[0];} @AuraEnabled public static ERP7__Product_Location__c insertPLocations(String ploc, String pId) { list < ERP7__Product_Location__c > locationToUpsert = (list < ERP7__Product_Location__c > ) JSON.deserialize(ploc, list < ERP7__Product_Location__c > .class);  for (integer i = 0; i < locationToUpsert.size(); i++) { locationToUpsert[i].ERP7__Product__c = pId;} if(Schema.sObjectType.ERP7__Product_Location__c .fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Product_Location__c .fields.ERP7__Product__c.isUpdateable()){ upsert locationToUpsert;}else{ }  return locationToUpsert[0]; } @AuraEnabled public static Boolean deleteProductLocation(Id recId) {ERP7__Product_Location__c ploc = [SELECT Id FROM ERP7__Product_Location__c WHERE Id = :recId]; if(ERP7__Product_Location__c.sObjectType.getDescribe().isDeletable()){ delete ploc;} else{/* no access */ } return true;}
    
    @AuraEnabled
    public static Product2 fetchProductDetails(String products1, String prId) {
        Product2 products = (Product2) JSON.deserialize(products1, Product2.class);
        products = [select id, name,ERP7__Picture__c, ProductCode,Family, IsActive,ERP7__Barcode__c,ERP7__Category__c,
                    ERP7__Colour__c,ERP7__Expense_Account__c, ERP7__Height__c,ERP7__Inventory_Account__c,ERP7__Is_Kit__c,
                    ERP7__Length__c,ERP7__Mass__c, ERP7__Product_Service_Family__c,
                    ERP7__Revenue_Account__c,ERP7__SKU__c,ERP7__Status__c,ERP7__Sub_Category__c,ERP7__Thickness__c,
                    ERP7__Track_Inventory__c,ERP7__Item_Type__c, ERP7__Weight__c,ERP7__Width__c from Product2 where id =:prId];
        return products;
    }
    
    
    @AuraEnabled
    public static list < ERP7__Tier_Discount_Allocation__c > fetchTDA(String prId) {
        List < ERP7__Tier_Discount_Allocation__c > tda;
        tda = [Select Id, Name,ERP7__Active__c, ERP7__Code__c, ERP7__Default__c, ERP7__Discount_Plan__r.Name, ERP7__Order_Profile__r.Name, ERP7__Price_Book__c, ERP7__Tier__r.Name 
               From ERP7__Tier_Discount_Allocation__c Where ERP7__Product__c =: prId ORDER BY CREATEDDATE desc];
        return tda;
    }
    
    @AuraEnabled
    public static list < ERP7__Warranty_Return_Policy__c > fetchWarrantyDetails(String prId) {
        List < ERP7__Warranty_Return_Policy__c > warranty;
        warranty = [Select Id, Name,ERP7__Active__c, ERP7__Code__c, ERP7__Days_of_Warranty__c, ERP7__Number_Days_From_Trans_Return_Accepted__c, ERP7__Exchange__c, ERP7__Standard_Manufacturing_Warranty__c
                    From ERP7__Warranty_Return_Policy__c Where ERP7__Product__c =: prId ORDER BY CREATEDDATE desc];
        return warranty;
    }
    @AuraEnabled public static list < ERP7__Product_Location__c > fetchProductLocations(String prId) { List < ERP7__Product_Location__c > pLocations; pLocations = [Select Id, Name,ERP7__Active__c, ERP7__Capacity__c, ERP7__Location__r.Name, ERP7__Site__r.Name, ERP7__Storage_Container__r.Name From ERP7__Product_Location__c Where ERP7__Product__c =: prId ORDER BY CREATEDDATE desc]; return pLocations;}
    
    @AuraEnabled
    public static list < ERP7__Version__c > fetchProductVersions(String prId) {
        List < ERP7__Version__c > pVersions;
        pVersions = [Select Id, Name,ERP7__Active__c, ERP7__Start_Date__c, ERP7__Description__c, ERP7__To_Date__c, ERP7__Status__c, ERP7__Quantity__c, ERP7__Type__c
                     From ERP7__Version__c Where ERP7__Product__c =: prId];
        return pVersions;
    }
    
    @AuraEnabled
    public static list < ERP7__Routing__c > fetchRoutings(String prId) {
        List < ERP7__Routing__c > routings;
        routings = [Select Id, Name,ERP7__Status__c, ERP7__Type__c, ERP7__Product__c, ERP7__Process__c, ERP7__Process__r.Name, ERP7__Planner__c, ERP7__Planner__r.Name, ERP7__Site__c, ERP7__Site__r.Name, ERP7__Engineer__c, ERP7__Engineer__r.Name, ERP7__BOM_Version__c 
                    From ERP7__Routing__c Where ERP7__Product__c =: prId];
        return routings;
    }
    
    @AuraEnabled
    public static List < String > getStatuspickval() {
        List < String > options = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__Version__c.ERP7__Status__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List < String > getpickvalExpType() {
        List < String > UoMType = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__Version__c.ERP7__Unit_of_Measure__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            UoMType.add(f.getLabel());
        }
        return UoMType;
    }
    
    @AuraEnabled
    public static List < String > getpickvalType() {
        List < String > Type = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__Version__c.ERP7__Type__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            Type.add(f.getLabel());
        }
        return Type;
    }
    
    @AuraEnabled
    public static List < String > getpickvalCategory() {
        List < String > Category = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__Version__c.ERP7__Category__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            Category.add(f.getLabel());
        }
        return Category;
    }
    
    @AuraEnabled
    public static List < String > getpickvalRoutingStatus() {
        List < String > RoutingStatus = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__Routing__c.ERP7__Status__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            RoutingStatus.add(f.getLabel());
        }
        return RoutingStatus;
    }
    
    @AuraEnabled
    public static List < String > getpickvalRoutingType() {
        List < String > RoutingType = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__Routing__c.ERP7__Type__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            RoutingType.add(f.getLabel());
        }
        return RoutingType;
    }
    
    @AuraEnabled
    public static List < String > getpickvalBomPhase() {
        List < String > BomPhase = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__BOM__c.ERP7__Phase__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            BomPhase.add(f.getLabel());
        }
        return BomPhase;
    }
    
    @AuraEnabled
    public static List < String > getpickvalBomType() {
        List < String > BomType = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__BOM__c.ERP7__Type__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            BomType.add(f.getLabel());
        }
        return BomType;
    }
    
    @AuraEnabled
    public static List < String > getpickvalBomUoM() {
        List < String > BomUoM = new List < String > ();
        Schema.DescribeFieldResult fieldResult = ERP7__BOM__c.ERP7__Unit_of_Measure__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            BomUoM.add(f.getLabel());
        }
        return BomUoM; }
    @AuraEnabled public static ERP7__Product_Location__c ProductLocation2Insert(String newPLoc1, String productId) { ERP7__Product_Location__c newPLoc = (ERP7__Product_Location__c) JSON.deserialize(newPLoc1, ERP7__Product_Location__c.class);  if (newPLoc != null && Schema.SObjectType.ERP7__Product_Location__c.isCreateable() && Schema.SObjectType.ERP7__Product_Location__c.isUpdateable()) { newPLoc.ERP7__Product__c = productId;if(newPLoc.ERP7__Product__c == null) newPLoc.ERP7__Product__c = productId;if(Schema.sObjectType.ERP7__Product_Location__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Product_Location__c.fields.ERP7__Product__c.isUpdateable()){ upsert newPLoc;}else{ }} return newPLoc;} @AuraEnabled public static ERP7__Product_Location__c getProductlocationById(String recId){return [select id, Name, ERP7__Active__c, ERP7__Capacity__c, ERP7__Location__r.Name, ERP7__Product__c, ERP7__Site__r.Name, ERP7__Storage_Container__c From ERP7__Product_Location__c where Id =: recId];} 
    @AuraEnabled public static ERP7__Version__c productVersionRecord2Insert(String newVersion1, String productId,String relatedBom) {ERP7__Version__c newVersion= (ERP7__Version__c) JSON.deserialize(newVersion1,ERP7__Version__c.class);  list < ERP7__BOM__c > relatedBoMList = (list < ERP7__BOM__c > ) JSON.deserialize(relatedBom, list < ERP7__BOM__c > .class); if (newVersion != null) {if (Schema.SObjectType.ERP7__Version__c.isCreateable() && Schema.SObjectType.ERP7__Version__c.isUpdateable()) newVersion.ERP7__Product__c = productId; if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isUpdateable()){ upsert newVersion;}else{ }}if(relatedBoMList.size()>0){for(Integer i=0;i<relatedBoMList.size();i++){relatedBoMList[i].BOM_Product__c = productId; relatedBoMList[i].ERP7__BOM_Version__c = newVersion.id; } if(Schema.sObjectType.ERP7__BOM__c.fields.BOM_Product__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.BOM_Product__c.isUpdateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()){ upsert relatedBoMList;}else{ } } return newVersion;} @AuraEnabled public static ERP7__BOM__c saveBOM(String bom, ERP7__BOM__c verBOM) { if(bom != null && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()) { verBOM.ERP7__BOM_Version__c=bom; upsert verBOM;  }else{ }  return null;} @AuraEnabled public ERP7__Version__c version; @AuraEnabled public List<ERP7__BOM__c> bomList; @AuraEnabled public static ProductConfig getProductVersionsById(String recId){ ProductConfig temp = new ProductConfig(); temp.version =(String.isNotEmpty(recId))?[select id, Name, ERP7__Active__c, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Process__c, ERP7__Start_Date__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Status__c, ERP7__Unit_of_Measure__c From ERP7__Version__c where Id =: recId]: new ERP7__Version__c(); temp.bomList = (String.isNotEmpty(recId))?[Select Id, Name, ERP7__Process_Cycle__c, ERP7__Active__c, ERP7__BOM_Version__c, ERP7__Quantity__c, ERP7__Type__c, ERP7__Phase__c, ERP7__Unit_of_Measure__c From ERP7__BOM__c where ERP7__BOM_Version__c = :recId]: new List<ERP7__BOM__c>();  return temp; } 
    @AuraEnabled public static ERP7__Routing__c routingRecord2Insert(String newRouting1, String productId, String versionId, String relatedOper){ ERP7__Routing__c newRouting = (ERP7__Routing__c) JSON.deserialize(newRouting1, ERP7__Routing__c.class);  list < ERP7__Operation__c > relatedOperList = (list < ERP7__Operation__c > ) JSON.deserialize(relatedOper, list < ERP7__Operation__c > .class); if(newRouting != null){ if (newRouting.ERP7__Product__c == null) newRouting.ERP7__Product__c = productId; if (newRouting.ERP7__BOM_Version__c == null) newRouting.ERP7__BOM_Version__c = versionId; if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__BOM_Version__c.isUpdateable()){ upsert newRouting;}else{ } } if(relatedOperList.size()>0){ for(Integer i=0;i<relatedOperList.size();i++){ relatedOperList[i].ERP7__Routing__c = newRouting.id; } if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isUpdateable()){ upsert relatedOperList;}else{ } } return newRouting; }@AuraEnabled public ERP7__Routing__c routing; @AuraEnabled public List<ERP7__Operation__c> operationList; @AuraEnabled public static ProductConfig getRoutingbyId(String recId){ ProductConfig temp = new ProductConfig(); temp.routing =(String.isNotEmpty(recId))?[select id, Name, ERP7__Status__c, ERP7__Type__c, ERP7__Description__c, ERP7__Process__c, ERP7__Site__c, ERP7__Planner__c, ERP7__BOM_Version__c, ERP7__Engineer__c From ERP7__Routing__c where Id =: recId]: new ERP7__Routing__c(); temp.operationList = (String.isNotEmpty(recId))?[Select Id, Name, ERP7__Operation_No__c, ERP7__Setup_Time__c, ERP7__Run_Time__c, ERP7__Wait_Time__c, ERP7__Move_Time__c, ERP7__Quantity__c, ERP7__Variable_Cost__c, ERP7__Fixed_Cost__c From ERP7__Operation__c where ERP7__Routing__c = :recId]: new List<ERP7__Operation__c>();  return temp; } @AuraEnabled public static Boolean deleteRouting(Id recId) {ERP7__Routing__c routing = [SELECT Id FROM ERP7__Routing__c WHERE Id =: recId]; if(ERP7__Routing__c.sObjectType.getDescribe().isDeletable()) { delete routing; } else { /* no access*/ } return true;}
    
    
    @AuraEnabled
    public static Id deleteBOM(Id recordId) {
        Id oldAccountId = null;
        try {if(ERP7__BOM__c.sObjectType.getDescribe().isDeletable()) {delete new ERP7__BOM__c(Id = recordId); } else { /*  no access */} oldAccountId = recordId;}
        catch (System.Exception caught) {}
        return oldAccountId;
    }
    
    
}