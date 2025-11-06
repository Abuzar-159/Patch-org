trigger TrackInTransitOrDelivered on Shipment_Flow__c (after insert, after update) {
    /*Map<String, String> ShipStatus = new Map<String, String>();
    
    // Determine the latest status of each shipment
    for (Shipment_Flow__c shipFlows : Trigger.new) {
        if (shipFlows.ERP7__Shipment_Flow_Status__c == 'Picked up') {
            if ((ShipStatus.containsKey(shipFlows.ERP7__Shipment__c) && ShipStatus.get(shipFlows.ERP7__Shipment__c) != 'Delivered') || !ShipStatus.containsKey(shipFlows.ERP7__Shipment__c)) {
                ShipStatus.put(shipFlows.ERP7__Shipment__c, shipFlows.ERP7__Shipment_Flow_Status__c);
            }
        } else if (shipFlows.ERP7__Shipment_Flow_Status__c == 'Delivered') {
            ShipStatus.put(shipFlows.ERP7__Shipment__c, shipFlows.ERP7__Shipment_Flow_Status__c);
        }
    }
    
    if (ShipStatus.size() > 0) {
        // Retrieve relevant packages and package lists
        List<ERP7__Package__c> shiplist = [
            SELECT Id, Name,
            (SELECT Id, Name, ERP7__Quantity__c, ERP7__Logistic_Line_Item__c 
             FROM Package_Lists__r)
            FROM ERP7__Package__c 
            WHERE ERP7__Shipment__c IN :ShipStatus.keySet()
        ];
        
        Map<String, Decimal> loglineqty = new Map<String, Decimal>();
        Map<String, String> loglineStatus = new Map<String, String>();
        
        // Aggregate quantities for each logistic line item and track statuses
        for (ERP7__Package__c pck : shiplist) {
            for (ERP7__Package_List__c packList : pck.Package_Lists__r) {
                if (packList.ERP7__Logistic_Line_Item__c != null) {
                    if (ShipStatus.containsKey(pck.ERP7__Shipment__c)) {
                        loglineStatus.put(packList.ERP7__Logistic_Line_Item__c, ShipStatus.get(pck.ERP7__Shipment__c));
                    }
                    if (loglineqty.containsKey(packList.ERP7__Logistic_Line_Item__c)) {
                        Decimal qty = loglineqty.get(packList.ERP7__Logistic_Line_Item__c);
                        loglineqty.put(packList.ERP7__Logistic_Line_Item__c, (packList.ERP7__Quantity__c + qty));
                    } else {
                        loglineqty.put(packList.ERP7__Logistic_Line_Item__c, packList.ERP7__Quantity__c);
                    }
                }
            }
        }
        
        // Update stock outward line items based on logistic line item quantities and statuses
        List<ERP7__Stock_Outward_Line_Item__c> stockoutwards2update = [
            SELECT Id, Name, ERP7__Status__c, ERP7__Logistic_Line_Item__c, Quantity__c
            FROM ERP7__Stock_Outward_Line_Item__c
            WHERE ERP7__Logistic_Line_Item__c IN :loglineqty.keySet() AND ERP7__Status__c = 'Picked'
        ];
        Decimal cumulativeQty = 0;
        for (ERP7__Stock_Outward_Line_Item__c sout : stockoutwards2update) {
            if (loglineqty.containsKey(sout.ERP7__Logistic_Line_Item__c)) {
                Decimal availableQty = loglineqty.get(sout.ERP7__Logistic_Line_Item__c);               
                if (availableQty != null) {
                    cumulativeQty += sout.Quantity__c;
                    if (availableQty >= cumulativeQty) {
                        String shipmentStatus = loglineStatus.get(sout.ERP7__Logistic_Line_Item__c);
                        if (shipmentStatus == 'Picked up') {
                            sout.ERP7__Status__c = 'In Transit';
                        } else if (shipmentStatus == 'Delivered') {
                            sout.ERP7__Status__c = 'Committed';
                        }
                    }
                }
            }
            
        }
        
        
        if(stockoutwards2update.size() > 0) update stockoutwards2update;
    }*/
}