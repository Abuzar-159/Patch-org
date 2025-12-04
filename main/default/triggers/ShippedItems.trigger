trigger ShippedItems on Package_List__c (after insert, after update, after delete, after undelete) {
    if(PreventRecursiveLedgerEntry.shippedItemsCheck){
        List<Id> soliIds = new List<Id>();
        Set < Id > StandorderIds = new Set < Id > ();
        List <ERP7__Logistic_Line_Item__c> solis = new List <ERP7__Logistic_Line_Item__c>();
        String SOLIFields = UtilClass.selectStarFromSObject('ERP7__Logistic_Line_Item__c');
        SOLIFields += ',ERP7__Product__r.ERP7__Is_Kit__c';
        String PLSFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c');
        
        
        PLSFields += ',ERP7__Logistic__r.ERP7__Order_S__c';
        String StockOutwardFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');
        if(!Trigger.IsDelete){
            for(ERP7__Package_List__c PL : System.Trigger.New){
                if(PL.ERP7__Logistic_Line_Item__c != Null) soliIds.add(PL.ERP7__Logistic_Line_Item__c);
            }
        }else{
            for(ERP7__Package_List__c PL : System.Trigger.Old){
                if(PL.ERP7__Logistic_Line_Item__c != Null) soliIds.add(PL.ERP7__Logistic_Line_Item__c);
            }
        }
        if(soliIds.size() > 0){
            String bl = '';
            solis = Database.query('Select ' + String.escapeSingleQuotes(SOLIFields) + ' From ERP7__Logistic_Line_Item__c Where Id In :soliIds');
            List<ERP7__Package_List__c> PLS = Database.query('Select ' + String.escapeSingleQuotes(PLSFields) + ' From ERP7__Package_List__c Where ERP7__Logistic_Line_Item__c In :soliIds ');
            for(ERP7__Logistic_Line_Item__c soli :solis){
                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Shipped_Quantity__c.isUpdateable()){soli.ERP7__Shipped_Quantity__c = 0;}else{/*No access*/}
                if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Packed_Quantity__c.isUpdateable()){soli.ERP7__Packed_Quantity__c = 0;}else{/*No access*/}
                for(ERP7__Package_List__c pl :PLS){
                    StandorderIds.add(pl.ERP7__Logistic__r.ERP7__Order_S__c);
                    if(soli.Id == pl.ERP7__Logistic_Line_Item__c && pl.ERP7__Quantity__c != Null && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Packed_Quantity__c.isUpdateable()){ soli.ERP7__Packed_Quantity__c = soli.ERP7__Packed_Quantity__c + pl.ERP7__Quantity__c;}else{/*No access*/}
                    if(soli.Id == pl.ERP7__Logistic_Line_Item__c && pl.ERP7__Quantity__c != Null && pl.ERP7__Shipment_ID__c != Null && pl.ERP7__Shipment_ID__c != '' && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__Shipped_Quantity__c.isUpdateable()){ soli.ERP7__Shipped_Quantity__c = soli.ERP7__Shipped_Quantity__c + pl.ERP7__Quantity__c;}else{/*No access*/}
                    //system.debug('soli.ERP7__DeliveredQuantity__c : '+soli.ERP7__DeliveredQuantity__c);
                    //system.debug('pl.ERP7__Delivered_Quantity__c : '+pl.ERP7__Delivered_Quantity__c);
                    //system.debug('pl.ERP7__Quantity__c : '+pl.ERP7__Quantity__c);
                     
                    //if(soli.Id == pl.ERP7__Logistic_Line_Item__c && pl.ERP7__Delivered_Quantity__c != Null && pl.ERP7__Shipment_ID__c != Null && pl.ERP7__Shipment_ID__c != '' && pl.ERP7__Status__c == 'Delivered' && Schema.sObjectType.ERP7__Logistic_Line_Item__c.fields.ERP7__DeliveredQuantity__c.isUpdateable()){ soli.ERP7__DeliveredQuantity__c = soli.ERP7__DeliveredQuantity__c + pl.ERP7__Delivered_Quantity__c;}else{/*No access*/}
                }
            }
            
            PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false;
            if(Schema.sObjectType.ERP7__Logistic_Line_Item__c.isUpdateable()){PreventRecursiveLedgerEntry.LogisticLineRollup =true; update solis;  system.debug('ShippedItems solis : '+solis.size());} else { /* no access */ }
        }
        PreventRecursiveLedgerEntry.shippedItemsCheck = false;
        system.debug('Shipped Items StandorderIds : '+StandorderIds);
        if(StandorderIds.size() > 0){
          /*  List<Order> ordlist = [Select Id,Name,ERP7__Total_Quantity__c,ERP7__Shipped_Quantity__c,ERP7__Total_Logistic_Quantity_U__c,Status from Order where Id IN : StandorderIds];
            system.debug('ordlist StandorderIds : '+ordlist.size());
            for(order ord:ordlist){
                if(ord.ERP7__Total_Logistic_Quantity_U__c > 0 && ord.ERP7__Shipped_Quantity__c > 0 && ord.ERP7__Shipped_Quantity__c == ord.ERP7__Total_Logistic_Quantity_U__c) ord.Status = 'Shipped';
                else if(ord.Status == 'Shipped') ord.Status = 'Activated';
            }
            update ordlist;
			*/
            //arshad commented 11/03/23
        }
    }
}