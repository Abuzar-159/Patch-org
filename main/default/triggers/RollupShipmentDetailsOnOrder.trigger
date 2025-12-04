trigger RollupShipmentDetailsOnOrder on Shipment__c(After insert, After update) {
    if(PreventRecursiveLedgerEntry.shippedItemsCheck){
        Set < Id > orderIds = new Set < Id > ();
        Set < Id > packIDs = new Set < Id > ();
        list<Id> StandorderIds = new list < Id > ();
        for(Shipment__c s: Trigger.new) {
            if(s.ERP7__Logistic__c != Null) 
                orderIds.add(s.ERP7__Logistic__c);
            //if(s.ERP7__order_Ids__c != null && s.ERP7__order_Ids__c != '') StandorderIds.addAll(s.ERP7__order_Ids__c.split(','));
        }
        if(orderIds.size() > 0){
            system.debug('RollupShipmentDetailsOnOrder orderIds : '+orderIds);
            List<ERP7__Package__c> pack = [Select Id,Name,ERP7__Multi_Order_Ids__c from ERP7__Package__c where ERP7__Shipment__c IN: trigger.newMap.keyset()];
            for(ERP7__Package__c pck : pack){
                packIDs.add(pck.Id);
            }
            List< Package_List__c > PLs = [Select Id, Name, ERP7__Logistic__c,ERP7__Logistic__r.ERP7__Order_S__c From Package_List__c Where  ERP7__Package__c IN :packIDs]; //ERP7__Logistic__c In :orderIds or
            system.debug('PLs : '+PLs.size());
            for(Package_List__c pck : PLs) { if(pck.ERP7__Logistic__r.ERP7__Order_S__c != null) StandorderIds.add(pck.ERP7__Logistic__r.ERP7__Order_S__c ); } 
            if(PLs.size() > 0 && Schema.sObjectType.Package_List__c.isCreateable() && Schema.sObjectType.Package_List__c.isUpdateable()) { upsert PLs; } else { /* no access */ }
        }
        system.debug('RollupShipmentDetailsOnOrder StandorderIds : '+StandorderIds.size());
    }
}