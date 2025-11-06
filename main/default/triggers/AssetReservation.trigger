trigger AssetReservation on Asset_Assignment__c (after insert, after update) {
    Map<Id, Asset_Assignment__c> AssetAssignment = new Map<Id, Asset_Assignment__c>();
    for(Asset_Assignment__c AA : System.Trigger.New){
        if(AA.ERP7__Reserved_To__c != Null && AA.ERP7__Reserved_To__c >= System.Today()) AssetAssignment.put(AA.ERP7__Asset__c,AA);
    }
    if(AssetAssignment.size() > 0){
        List<ERP7__Asset__c> Assets = [Select Id, Name, ERP7__Account__c, ERP7__Reserved_From__c, ERP7__Reserved_To__c, ERP7__Is_Reserved__c
                                        From ERP7__Asset__c Where Id In : AssetAssignment.keySet()];
        for(ERP7__Asset__c Asset : Assets){
            if(Schema.sObjectType.ERP7__Asset__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.Account__c.isUpdateable()){Asset.Account__c = AssetAssignment.get(Asset.Id).ERP7__Account__c;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Reserved_From__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Reserved_From__c.isUpdateable()){Asset.ERP7__Reserved_From__c = AssetAssignment.get(Asset.Id).ERP7__Reserved_From__c;}else{/*No access*/}
        	if(Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Reserved_To__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Reserved_To__c.isUpdateable()){Asset.ERP7__Reserved_To__c = AssetAssignment.get(Asset.Id).ERP7__Reserved_To__c;}else{/*No access*/}
            if(Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Is_Reserved__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Is_Reserved__c.isUpdateable()){Asset.ERP7__Is_Reserved__c = true;}else{/*No access*/}
        }
        if(Schema.SObjectType.ERP7__Asset__c.isCreateable() && Schema.SObjectType.ERP7__Asset__c.isUpdateable()){upsert Assets;}else{/*not allowed to upsert Assert*/}
    }
}