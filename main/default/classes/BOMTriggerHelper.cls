public with sharing class BOMTriggerHelper {
    
    public static void createSupportingBOMs(Boolean isInsert,Boolean isUpdate,List<ERP7__BOM__c> BOMsList1){
        
        /*'createSupportingBOMs BOMsList1 size():'+BOMsList1.size()*/
        Set<Id> BomProducts=new Set<Id>();
        Set<Id> BomsId=new Set<Id>();
        for(ERP7__BOM__c BOM:BOMsList1){
            BomProducts.add(BOM.ERP7__BOM_Component__c);
            BomsId.add(BOM.Id);
        }
        
        List<ERP7__BOM__c> BOMsList=[Select Id,Name,ERP7__BOM_Product__c,ERP7__BOM_Component__c,ERP7__BOM_Component__r.Name,ERP7__BOM_Version__c,ERP7__Quantity__c, ERP7__Process_Cycle__c,ERP7__Routing_Link__c
                                     from ERP7__BOM__c where Id In:BomsId];
        
        /*'BomProducts :'+BomProducts.size()*/
        List<ERP7__Supporting_BOMs__c> suppBOMsList=[Select Id,Name,ERP7__BOM_Product__c,ERP7__BOM_Component__c,ERP7__Quantity__c,ERP7__BOM_Component__r.Name from ERP7__Supporting_BOMs__c 
                                                     where ERP7__BOM_Product__c In:BomProducts  AND ERP7__BOM_Component__c != null AND ERP7__Quantity__c != null AND ERP7__Type__c ='Manufacturing'];
        /*'suppBOMsList :'+suppBOMsList.size()*/
        if(suppBOMsList.size()>0){
            Id BOMRt = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_BOM').getRecordTypeId();
            
            List<ERP7__BOM__c> BOMsToInsert=new List<ERP7__BOM__c>();
            for(ERP7__BOM__c BOM:BOMsList){                
                for(ERP7__Supporting_BOMs__c suppBom:suppBOMsList){
                    ERP7__BOM__c BOMIns=new ERP7__BOM__c();
                    if(BOM.ERP7__BOM_Component__c == suppBom.ERP7__BOM_Product__c){
                        if(Schema.sObjectType.ERP7__BOM__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.RecordTypeId.isUpdateable()){BOMIns.RecordTypeId=BOMRt;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Parent_BOM__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Parent_BOM__c.isUpdateable()){BOMIns.ERP7__Parent_BOM__c=BOM.Id;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isUpdateable()){BOMIns.ERP7__Process_Cycle__c=BOM.ERP7__Process_Cycle__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isUpdateable()){BOMIns.ERP7__Routing_Link__c=BOM.ERP7__Routing_Link__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.Name.isUpdateable()){BOMIns.Name=suppBom.ERP7__BOM_Component__r.Name;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isUpdateable()){BOMIns.ERP7__BOM_Product__c=BOM.ERP7__BOM_Product__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isUpdateable()){BOMIns.ERP7__Active__c=true;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isUpdateable()){BOMIns.ERP7__BOM_Version__c=BOM.ERP7__BOM_Version__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isUpdateable()){BOMIns.ERP7__Type__c='Primary';}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isUpdateable()){BOMIns.ERP7__Status__c='Certified';}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isUpdateable()){BOMIns.ERP7__Unit_of_Measure__c='Each';}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Is_Supporting_BOM__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Is_Supporting_BOM__c.isUpdateable()){BOMIns.ERP7__Is_Supporting_BOM__c=true;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isUpdateable()){BOMIns.ERP7__BOM_Component__c=suppBom.ERP7__BOM_Component__c;}else{/*No access*/}
                        if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable()){BOMIns.ERP7__Quantity__c=BOM.ERP7__Quantity__c * suppBom.ERP7__Quantity__c;}else{/*No access*/}
                        
                        BOMsToInsert.add(BOMIns);
                    }
                }
            }
            PreventRecursiveLedgerEntry.BOMsProcess=false;
            if(BOMsToInsert.size()>0){
                if(Schema.sObjectType.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.isUpdateable()){upsert BOMsToInsert;}else{/*No access*/}
            }
        }
    }
    
    public static void updateSupportingBOMs(Boolean isInsert,Boolean isUpdate,List<ERP7__BOM__c> BOMsList1){
        
        /*'updateSupportingBOMs BOMsList1 size():'+BOMsList1.size()*/
        Set<Id> BomProducts=new Set<Id>();
        Set<Id> BomsId=new Set<Id>();
        for(ERP7__BOM__c BOM:BOMsList1){
            BomProducts.add(BOM.ERP7__BOM_Component__c);
            BomsId.add(BOM.Id);
        }
        
        List<ERP7__Supporting_BOMs__c> suppBOMsList=[Select Id,Name,ERP7__BOM_Product__c,ERP7__BOM_Component__c,ERP7__Quantity__c,ERP7__BOM_Component__r.Name from ERP7__Supporting_BOMs__c 
                                                     where ERP7__BOM_Product__c In:BomProducts AND ERP7__BOM_Component__c != null AND ERP7__Quantity__c != null AND ERP7__Type__c ='Manufacturing'];
        Map<String,Decimal> compAndQunatity=new Map<String,Decimal>();
        for(ERP7__Supporting_BOMs__c sBom1:suppBOMsList){
            compAndQunatity.put(sBom1.ERP7__BOM_Component__c,sBom1.ERP7__Quantity__c);
        }
                
        List<ERP7__BOM__c> SBOMsList=[Select Id,Name,ERP7__Quantity__c,ERP7__Parent_BOM__c,ERP7__BOM_Component__c from ERP7__BOM__c Where ERP7__Is_Supporting_BOM__c=true
                                                   AND ERP7__Parent_BOM__c In:BomsId];
        if(SBOMsList.size()>0){
            for(ERP7__BOM__c BOM:BOMsList1){
               for(ERP7__BOM__c sBOM:SBOMsList){
                   if(BOM.Id == sBOM.ERP7__Parent_BOM__c){
                       if(Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isUpdateable()){sBOM.ERP7__Quantity__c=compAndQunatity.get(sBOM.ERP7__BOM_Component__c) * BOM.ERP7__Quantity__c;}else{/*No access*/}
                   }
                }                
            }
            PreventRecursiveLedgerEntry.BOMsProcess=false;
            if(Schema.sObjectType.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.isUpdateable()){upsert SBOMsList;}else{/*No access*/}
        }
        
    }

    public static void deleteSupportingBoms(List<ERP7__BOM__c> BOMsList){
        set<Id> bomIds=new set<Id>();
        for(ERP7__BOM__c BOM:BOMsList) bomIds.add(BOM.Id);
        
        List<ERP7__BOM__c> bomsToDel=[Select Id,Name
                                                  from ERP7__BOM__c
                                                  where ERP7__Is_Supporting_BOM__c=true
                                                  AND ERP7__Parent_BOM__c In:bomIds];
        PreventRecursiveLedgerEntry.BOMsProcess=false;
        if(bomsToDel.size() > 0){
            if(ERP7__BOM__c.sObjectType.getDescribe().isDeletable()){delete bomsToDel;}else{/*No access*/}
        } 
    }
    
    public static void undeleteSupportingBoms(List<ERP7__BOM__c> BOMsList){
        set<Id> bomIds=new set<Id>();
        for(ERP7__BOM__c BOM:BOMsList) bomIds.add(BOM.Id);
        
        List<ERP7__BOM__c> bomsToUnDel=[Select Id,Name
                                                  from ERP7__BOM__c
                                                  where ERP7__Is_Supporting_BOM__c=true
                                                  AND ERP7__Parent_BOM__c In:bomIds ALL ROWS];
        
        PreventRecursiveLedgerEntry.BOMsProcess=false;
        if(bomsToUnDel.size() > 0){
            if(ERP7__BOM__c.sObjectType.getDescribe().isCreateable()){undelete bomsToUnDel;}else{/*No access*/}
        } 
    }
    
    /*public static void assignProsAndRouting(List<ERP7__BOM__c> BOMsList1){
        Set<Id> BomsId=new set<Id>();
        for(ERP7__BOM__c BOM:BOMsList1){
            BomsId.add(BOM.Id);
        }
        
        List<ERP7__BOM__c> BOMsList=[Select Id,Name,ERP7__Parent_BOM__c,ERP7__Parent_BOM__r.ERP7__Process_Cycle__c,
                                     ERP7__Parent_BOM__r.ERP7__Routing_Link__c from ERP7__BOM__c
                                    where ERP7__Is_Supporting_BOM__c = true
                                    AND ERP7__Parent_BOM__c!=null];
        for(ERP7__BOM__c BOM:BOMsList){
            BOM.ERP7__Process_Cycle__c=BOM.ERP7__Parent_BOM__r.ERP7__Process_Cycle__c;
            BOM.ERP7__Routing_Link__c=BOM.ERP7__Parent_BOM__r.ERP7__Routing_Link__c;
        }
        PreventRecursiveLedgerEntry.BOMsProcessupdate=false;
        if(BOMsList.size() > 0) update BOMsList;
    }*/
}