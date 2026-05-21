/*
* LastModifiedBy - Arshad
* To supprt MPS multiple package shipment tracking using mastertrackingno for fedex,ups & shipment flows creation flow - control duplicates, batch classes for ups/fedex
*
*/
Global Class IntegratedShipmentScheduler implements Schedulable{
    global void execute(SchedulableContext b) {       
        try{
            String credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            
            List<Credentials__c> cred = new List<Credentials__c>();
            cred = Database.query('select ' + credentialFields + ' from Credentials__c where (Name = \'Fedex\' And Active__c = true) Limit 1');
            
            if(cred != null){
                if(cred.size() > 0){
                    List<ERP7__Package__c> packageList = new List<ERP7__Package__c>();
                    packageList = [select Id, Name, ERP7__Shipment__c, ERP7__Shipment__r.ERP7__TrackingNumber__c, ERP7__Shipment__r.ERP7__Status__c, ERP7__Shipment__r.ERP7__Shipment_Status__c, ERP7__Shipment__r.ERP7__Shipment_Date__c from ERP7__Package__c where ERP7__Shipment__c != null AND ERP7__Shipment_Type__c = 'FedEx' AND ERP7__Shipment__r.ERP7__Status__c != 'Delivered' AND ERP7__Shipment__r.ERP7__Status__c != 'Cancelled' order by ERP7__Shipment__r.ERP7__Shipment_Date__c asc]; //AND ERP7__Shipment__r.ERP7__TrackingNumber__c != null 
                    system.debug('packageList~>'+packageList.size());
                    set<Id> shipIds = new set<Id>();
                    if(packageList.size()>0){
                        for(ERP7__Package__c pkg : packageList){
                            if(pkg.ERP7__Shipment__c != null){
                                if(pkg.ERP7__Shipment__r.ERP7__TrackingNumber__c != null) shipIds.add(pkg.ERP7__Shipment__c);
                            }
                        }
                    }
                    system.debug('shipIds~>'+shipIds.size());
                    if(shipIds.size()>0){database.executeBatch(new ShipTrackingFedExBatchClass(shipIds),100);}
                } 
            }
            
            List<Credentials__c> upscred = new List<Credentials__c>();
            upscred = Database.query('select ' + credentialFields + ' from Credentials__c where (Name = \'UPS\' And Active__c = true) Limit 1');
            
            if(upscred != null){
                if(upscred.size() > 0){
                    List<ERP7__Package__c> upspackageList = new List<ERP7__Package__c>();
                    upspackageList = [select Id, Name, ERP7__Shipment__c, ERP7__Shipment__r.ERP7__TrackingNumber__c, ERP7__Shipment__r.ERP7__Status__c, ERP7__Shipment__r.ERP7__Shipment_Status__c, ERP7__Shipment__r.ERP7__Shipment_Date__c from ERP7__Package__c where ERP7__Shipment__c != null AND ERP7__Shipment_Type__c = 'UPS' AND ERP7__Shipment__r.ERP7__Status__c != 'Delivered' AND ERP7__Shipment__r.ERP7__Status__c != 'Cancelled' order by ERP7__Shipment__r.ERP7__Shipment_Date__c asc]; //AND ERP7__Shipment__r.ERP7__TrackingNumber__c != null
                    system.debug('upspackageList~>'+upspackageList.size());
                    set<Id> upsshipIds = new set<Id>();
                    if(upspackageList.size()>0){
                        for(ERP7__Package__c pkg : upspackageList){
                            if(pkg.ERP7__Shipment__c != null){
                                if(pkg.ERP7__Shipment__r.ERP7__TrackingNumber__c != null) upsshipIds.add(pkg.ERP7__Shipment__c);
                            }
                        }
                    }
                    system.debug('upsshipIds~>'+upsshipIds.size());
                    if(upsshipIds.size()>0){database.executeBatch(new ShipTrackingUPSBatchClass(upsshipIds),100);}
                }
            }
        }catch(Exception e){
            system.debug('Exception-ShipTrackingUpdate->'+e.getMessage()+' at line ~>'+e.getStackTraceString());
        }  
        
        DateTime dtime = system.now().addMinutes(60);
        String day = string.valueOf(dtime.day());
        String month = string.valueOf(dtime.month());
        String hour = string.valueOf(dtime.hour());
        String minute = string.valueOf(dtime.minute());
        String second = string.valueOf(dtime.second());
        String year = string.valueOf(dtime.year());        
        String strJobName = 'IntegratedShipmentScheduler '+ day + '/' + month + '/' + year + ' ' + hour + ':' + minute;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new IntegratedShipmentScheduler());
        system.abortJob(b.getTriggerId()); 
    }  
}