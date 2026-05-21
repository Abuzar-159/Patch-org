trigger DepreciationTrigger on ERP7__Depreciation__c (after insert, after update) {
    Id unitofProductionTypeId = Schema.SObjectType.ERP7__Depreciation__c.getRecordTypeInfosByName().get('Units of Production').getRecordTypeId();
    List<ERP7__Depreciation__c> unitofProdDepreciation = new List<ERP7__Depreciation__c>();
    List<ERP7__Asset__c> assetToUpdate = new List<ERP7__Asset__c>();
    Map<Id,List<ERP7__Inventory_Stock__c>> mapofProdInevntory = new Map<Id,List<ERP7__Inventory_Stock__c>>();
    List<ERP7__Inventory_Stock__c> invertoryToUpdate = new List<ERP7__Inventory_Stock__c>();
    Set<Id> productIds = new Set<Id>();
    Set<Id> AssetIds = new Set<Id>();
    for(ERP7__Depreciation__c dep : Trigger.new){
        if(dep.RecordTypeId == unitofProductionTypeId && dep.ERP7__Asset__c!=null){
            unitofProdDepreciation.add(dep);
        }
    }
    if(!unitofProdDepreciation.isEmpty() && unitofProdDepreciation.size()>0){
        for(ERP7__Depreciation__c dep : unitofProdDepreciation){
            AssetIds.add(dep.ERP7__Asset__c);
        }
        if(!AssetIds.isEmpty() && AssetIds.size()>0){
            Map<Id, ERP7__Asset__c> assetMap = new Map<Id, ERP7__Asset__c>([select Id, Name from ERP7__Asset__c where Id IN:AssetIds]);
            if(!assetMap.isEmpty() && assetMap.size()>0){
                for(ERP7__Depreciation__c dep : unitofProdDepreciation){
                    if(assetMap.containskey(dep.ERP7__Asset__c)){
                        ERP7__Asset__c asset = assetMap.get(dep.ERP7__Asset__c);
                        asset.ERP7__Depreciation__c = dep.Id;
                        asset.ERP7__Initial_Purchase_Produced_Value__c = dep.ERP7__Purchase_Cost__c;
                        assetToUpdate.add(asset);
                    }
                }
            }
        }
    }
    if(!assetToUpdate.isEmpty() && assetToUpdate.size()>0){
        update assetToUpdate;
    }
}