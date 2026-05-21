/*
* CreatedBy - Arshad
* LastModifiedBy - Arshad
* Date - 12/03/23
* Reason - Batch class to track UPS shipments in chunks of 100 callouts (Solution for Too many callouts 101), called from scheduler - IntegratedShipmentScheduler
*/
global class ShipTrackingUPSBatchClass implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    
    Set<id> shipIds = new Set<id>();
    
    global ShipTrackingUPSBatchClass(Set<id> mapIds){
        shipIds = mapIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id, Name,ERP7__TrackingNumber__c, ERP7__Status__c, ERP7__Shipment_Status__c,ERP7__Shipment_Date__c from ERP7__Shipment__c where Id IN :shipIds]); // limit 100
    }
    
    global void execute(Database.BatchableContext BC, List<ERP7__Shipment__c> shipmentrecords) {
        try{
            system.debug('ShipTrackingUPSBatchClass called shipmentrecords size~>'+shipmentrecords.size());
            String credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            Credentials__c cred = new Credentials__c();
            cred = Database.query('select ' + credentialFields + ' from Credentials__c where (Name = \'UPS\' And Active__c = true) Limit 1');
            if(cred.Id != null){ 
                if(cred.Encrypted_Key__c != null && cred.Encrypted_Key__c != '' && cred.Password_Transkey__c != null && cred.Password_Transkey__c != ''){
                    Blob cryptoKey, userData, passwordData;
                    cryptoKey = encodingUtil.convertFromHex(cred.Encrypted_Key__c);
                    userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Username_Login__c));
                    passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Password_Transkey__c));
                    if(userData != null) cred.Username_Login__c = userData.toString();
                    if(passwordData != null) cred.Password_Transkey__c = passwordData.toString();
                }
                List<ERP7__Shipment_Flow__c> shipmentFlows = new List<ERP7__Shipment_Flow__c>();
                List<ERP7__Shipment__c> shipments = new List<ERP7__Shipment__c>();
                Map<Id, String> shipTrackMap = new Map<Id, String>();
                Map<Id, ERP7__Shipment__c> shipmentMap = new Map<Id, ERP7__Shipment__c>();
                
                system.debug('ups shipmentrecords~>'+shipmentrecords.size());
                if(shipmentrecords.size() > 0) shipmentMap = new Map<Id, ERP7__Shipment__c>(shipmentrecords);
                system.debug('ups shipmentMap~>'+shipmentMap.size());
                
                if(shipmentMap.size()>0){
                    for(Id shipId : shipmentMap.keyset()){
                        system.debug('Tracking Number-->'+shipmentMap.get(shipId).ERP7__TrackingNumber__c);
                        List<String> s = new List<String>(); String mastertrackingnumber = '';
                        if(shipmentMap.get(shipId).ERP7__TrackingNumber__c != null) s = shipmentMap.get(shipId).ERP7__TrackingNumber__c.split(',');
                        if(s.size() > 0) mastertrackingnumber = s[0];
                        string soapXML = '<?xml version="1.0"?>';
                        soapXML += '<AccessRequest xml:lang="en-US">';
                        soapXML += '<AccessLicenseNumber>'+ cred.key__c.escapeXml()  +'</AccessLicenseNumber>';
                        soapXML += '<UserId>'+ cred.Username_Login__c.escapeXml() +'</UserId>';
                        soapXML += '<Password>'+ cred.Password_Transkey__c.escapeXml() +'</Password>';
                        soapXML += '</AccessRequest>';
                        
                        soapXML += '<?xml version="1.0"?>';
                        soapXML += '<TrackRequest>';
                        soapXML += '<Request>';
                        soapXML += '<RequestAction>Track</RequestAction>';
                        soapXML += '<RequestOption>03</RequestOption>';
                        soapXML += '</Request>';                
                        soapXML += '<TrackingNumber>'+ mastertrackingnumber +'</TrackingNumber>';
                        //soapXML += '<TrackingNumber>1Z5506R30300841498</TrackingNumber>'; // Test Tracking Number
                        soapXML += '</TrackRequest>';
                        
                        Http h = new Http();
                        HttpRequest req = new HttpRequest();
                        
                        req.setBody(soapXML);
                        req.setMethod('POST');
                        String myEndPoint = cred.URL__c + '/ups.app/xml/Track';
                        req.setEndpoint(myEndPoint);
                        //String myEndPoint = 'https://onlinetools.ups.com' + '/ups.app/xml/Track';
                        //req.setEndpoint(myEndPoint);
                        
                        HttpResponse res = new HttpResponse();
                        String response_1 = ''; String resStatus = '';
                        if(Test.isRunningTest()){
                            response_1 = '<TrackResponse><Response><ResponseStatusCode>1</ResponseStatusCode><ResponseStatusDescription>Success</ResponseStatusDescription></Response><Shipment><Shipper><ShipperNumber>5506R3</ShipperNumber><Address><AddressLine1>13818 RIDER TRAIL DR</AddressLine1><City>EARTH CITY</City><StateProvinceCode>MO</StateProvinceCode><PostalCode>63045</PostalCode><CountryCode>US</CountryCode></Address></Shipper><ShipTo><Address><City>FLORISSANT</City><StateProvinceCode>MO</StateProvinceCode><PostalCode>63033</PostalCode><CountryCode>US</CountryCode></Address></ShipTo><ShipmentWeight><UnitOfMeasurement><Code>LBS</Code></UnitOfMeasurement><Weight>2.30</Weight></ShipmentWeight><Service><Code>003</Code><Description>UPS Ground</Description></Service><ReferenceNumber><Code>01</Code><Value>1016316586303001</Value></ReferenceNumber><ShipmentIdentificationNumber>1Z5506R30300841498</ShipmentIdentificationNumber><PickupDate>20190624</PickupDate><DeliveryDateUnavailable><Type>Scheduled Delivery</Type><Description>Scheduled Delivery Date is not currently available, please try back later</Description></DeliveryDateUnavailable><Package><TrackingNumber>1Z5506R30300841498</TrackingNumber><DeliveryIndicator>Y</DeliveryIndicator><DeliveryDate>20190624</DeliveryDate><Activity><ActivityLocation><Address><City>FLORISSANT</City><StateProvinceCode>MO</StateProvinceCode><PostalCode>63033</PostalCode><CountryCode>US</CountryCode></Address><Code>M1</Code><Description>Residential</Description><SignedForByName>BRIDGES</SignedForByName></ActivityLocation><Status><StatusType><Code>D</Code><Description>Delivered</Description></StatusType><StatusCode><Code>KB</Code></StatusCode></Status><Date>20190624</Date><Time>144318</Time><GMTDate>2019-06-24</GMTDate><GMTTime>19:43:18</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><City>Earth City</City><StateProvinceCode>MO</StateProvinceCode><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>I</Code><Description>Out For Delivery Today</Description></StatusType><StatusCode><Code>OT</Code></StatusCode></Status><Date>20190624</Date><Time>083057</Time><GMTDate>2019-06-24</GMTDate><GMTTime>13:30:57</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><City>Earth City</City><StateProvinceCode>MO</StateProvinceCode><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>I</Code><Description>Destination Scan</Description></StatusType><StatusCode><Code>DS</Code></StatusCode></Status><Date>20190624</Date><Time>033315</Time><GMTDate>2019-06-24</GMTDate><GMTTime>08:33:15</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><City>Hazelwood</City><StateProvinceCode>MO</StateProvinceCode><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>I</Code><Description>Origin Scan</Description></StatusType><StatusCode><Code>OC</Code></StatusCode></Status><Date>20190624</Date><Time>000519</Time><GMTDate>2019-06-24</GMTDate><GMTTime>05:05:19</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>M</Code><Description>Order Processed: Ready for UPS</Description></StatusType><StatusCode><Code>MP</Code></StatusCode></Status><Date>20190624</Date><Time>021308</Time><GMTDate>2019-06-24</GMTDate><GMTTime>07:13:08</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><PackageWeight><UnitOfMeasurement><Code>LBS</Code></UnitOfMeasurement><Weight>2.30</Weight></PackageWeight><ReferenceNumber><Code>01</Code><Value>AN5-4023101-4800111</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>DTSTJR2XP</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>NA</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>NA</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>UPS-MOEAR-PPD0190624  PDSTL5EARMOUP</Value></ReferenceNumber></Package></Shipment></TrackResponse>';
                            resStatus = '200';
                        }else{ res = h.send(req); response_1 = res.getBody(); resStatus = res.getStatus(); }
                        system.debug('resStatus-->'+resStatus);
                        system.debug('Limits.getCallouts() == '+Limits.getCallouts()); 
                        system.debug('Limits.getLimitCallouts() == '+Limits.getLimitCallouts());
                        if(resStatus == 'OK' || resStatus == '200') { 
                            XmlStreamReader reader1;
                            String msg = '';
                            if(Test.isRunningTest()) {reader1 = new XmlStreamReader(response_1); msg = 'SUCCESS';} else {reader1 = res.getXmlStreamReader(); msg = readXMLResponseOnce(reader1, 'ResponseStatusDescription'); }
                            system.debug('msg ResponseStatusDescription-->'+msg);
                            if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                                
                                trackwrapper tw;  List<trackwrapper> trackwrapperlist = new List<trackwrapper>(); XmlStreamReader reader;
                                if(Test.isRunningTest()) {reader = new XmlStreamReader(response_1);} else { reader = res.getXmlStreamReader(); }
                                
                                while (reader.hasNext()) {
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Activity') {
                                        tw = new trackwrapper();
                                        while(reader.hasNext()) {        
                                            //city
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'City') {  reader.next(); tw.location = reader.getText();  }                        
                                            //CountryCode
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CountryCode') { reader.next(); if(tw.location != null && tw.location != '') tw.location = tw.location +', '+ reader.getText(); else tw.location = reader.getText(); } 
                                            //SignedForByName
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SignedForByName') {  reader.next();  if(reader.hasText()) { tw.SignedForByName = reader.getText(); } else { tw.SignedForByName = '-'; } }
                                            //StatusType
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'StatusType') { reader.next(); reader.next(); reader.next(); reader.next(); reader.next(); tw.activityDesp = reader.getText(); }                        
                                            //Date
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Date') { reader.next(); tw.tDate = reader.getText(); String yys, mms, dds; if(tw.tDate != null) { yys = tw.tDate.substring(0,4); mms = tw.tDate.substring(4,6); dds = tw.tDate.substring(6,8); tw.dateTimeString = yys +'-'+ mms +'-'+ dds; } }                        
                                            //Time
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Time') { reader.next(); tw.tTime = reader.getText(); String hhs, mins, secs; if(tw.tTime != null) { hhs = tw.tTime.substring(0,2); mins = tw.tTime.substring(2,4); secs = tw.tTime.substring(4,6); if(tw.dateTimeString != null) tw.dateTimeString += ' '+ hhs +':'+ mins +':'+ secs; tw.dtValue = Datetime.valueOf(tw.dateTimeString); } }                        
                                            if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'Activity') break; else reader.next(); 
                                        } trackwrapperlist.add(tw);
                                    } reader.next();
                                }
                                
                                system.debug('--- trackwrapperlist : ' +trackwrapperlist.size());
                                Map<String, ERP7__Shipment_Flow__c> ExistingsfMap = new Map<String, ERP7__Shipment_Flow__c>();
                                List<ERP7__Shipment_Flow__c> sf2create = new List<ERP7__Shipment_Flow__c>();
                                if(shipId != null) { 
                                    for(ERP7__Shipment_Flow__c sf: [select Id, Name, ERP7__Shipment__c, ERP7__Shipment_DateTime__c, ERP7__Description__c, ERP7__Shipment_Flow_Start_Date__c,  ERP7__Shipment_Flow_End_Date__c from ERP7__Shipment_Flow__c where ERP7__Shipment__c =: shipId Order by Name Asc]) { 
                                        ExistingsfMap.put(sf.ERP7__Shipment_DateTime__c, sf); }
                                }
                                system.debug('--- ExistingsfMap : ' +ExistingsfMap);
                                for(Integer i=0; i<trackwrapperlist.size(); i++) {
                                    system.debug('trackwrapperlist[i].dtValue~>'+String.valueof(trackwrapperlist[i].dtValue));
                                    system.debug('trackwrapperlist[i].activityDesp~>'+String.valueof(trackwrapperlist[i].activityDesp));
                                    ERP7__Shipment_Flow__c sf = new ERP7__Shipment_Flow__c(ERP7__Shipment_DateTime__c = String.valueof(trackwrapperlist[i].dtValue));
                                    system.debug('Key Set-->'+ExistingsfMap.keyset().contains(String.valueof(trackwrapperlist[i].dtValue)));
                                    if(!ExistingsfMap.keyset().contains(String.valueof(trackwrapperlist[i].dtValue))) {
                                        system.debug('Entered');
                                        sf.Name = 'SF ' + shipmentMap.get(shipId).Name + '-' + i;
                                        sf.ERP7__Shipment__c = shipId; sf.ERP7__Active__c = true;                            
                                        if(trackwrapperlist[i].dtValue != null) sf.ERP7__Shipment_Flow_Start_Date__c = Datetime.valueof(trackwrapperlist[i].dtValue);
                                        if(trackwrapperlist[i].dtValue != null) sf.ERP7__Shipment_Flow_End_Date__c = Datetime.valueof(trackwrapperlist[i].dtValue);
                                        if(trackwrapperlist[i].activityDesp != null) sf.ERP7__Description__c = trackwrapperlist[i].activityDesp;
                                        if(trackwrapperlist[i].activityDesp != null && trackwrapperlist[i].activityDesp == 'Delivered') { shipmentMap.get(shipId).ERP7__Status__c = 'Delivered';  }
                                        else if(trackwrapperlist[i].activityDesp != null) shipmentMap.get(shipId).ERP7__Shipment_Status__c = trackwrapperlist[i].activityDesp; 
                                        sf2create.add(sf);
                                        system.debug('here');
                                    }else if(trackwrapperlist[i].activityDesp != null && trackwrapperlist[i].activityDesp == 'Delivered' && ExistingsfMap.get(String.valueof(trackwrapperlist[i].dtValue)).ERP7__Description__c == 'Delivered'){
                                        shipmentMap.get(shipId).ERP7__Status__c = 'Delivered';
                                    } 
                                }
                                system.debug('Shipment-->');
                                shipments.add(shipmentMap.get(shipId)); 
                                system.debug('Shipment Flows~>'+sf2create.size());
                                if(sf2create.size() > 0){ shipmentFlows.addAll(sf2create); }
                            } else { 
                                XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'ErrorDescription');
                                system.debug('Request to track shipment cannot be processed : ' + mesage);
                            }
                        } 
                    }
                }
                
                system.debug('ups shipments-->'+shipments.size());
                system.debug('ups shipmentFlows-->'+shipmentFlows.size());
                if(shipments.size()>0){ PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; PreventRecursiveLedgerEntry.shippedItemsCheck = false; Database.update(shipments,false); }
                if(shipmentFlows.size()>0) Database.upsert(shipmentFlows,false); 
            }
        } catch (Exception e) {
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
    }
    
    public class trackwrapper {
        @AuraEnabled public String location                                             { get; set; }  
        @AuraEnabled public DateTime dtValue                                            { get; set; } 
        @AuraEnabled public String timeStamp                                            { get; set; }
        @AuraEnabled public String activityDesp                                         { get; set; }          
        @AuraEnabled public String arrivalLocation                                      { get; set; }  
        @AuraEnabled public String dateTimeString                                       { get; set; }               
        @AuraEnabled public String SignedForByName                                      { get; set; }   
        @AuraEnabled public String tDate                     { get;set; }
        @AuraEnabled public String tTime                     { get;set; }
        
        public trackwrapper() {    
            location = '';
            timeStamp = '';            
            activityDesp = ''; 
            dateTimeString = ''; 
            arrivalLocation = '';          
            SignedForByName = '';
            tDate = '';
            tTime = '';
        }        
    }
    
    public static String readXMLResponseOnce(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; 
        try {                   
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) { if (sxmltag == reader.getLocalName()) { while (reader.hasNext()) { if (reader.getEventType() == XmlTag.END_ELEMENT) { break; }  else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); } reader.next(); } } } reader.next();
            } 
        } catch(Exception e) { system.debug('readXMLResponseOnce Error :' +e.getMessage() +' Line Number @ : '+ e.getLineNumber()); }
        return retValue;   
    } 
    
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; 
        try {           
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) { if (sxmltag == reader.getLocalName()) { while (reader.hasNext()) { if (reader.getEventType() == XmlTag.END_ELEMENT) { break; }  else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); } reader.next(); } } } reader.next();
            }
        } catch(Exception e) { system.debug('readXMLResponse Error :' +e.getMessage() +' Line Number @ : '+ e.getLineNumber()); }
        return retValue;
    }
    
    global void finish(Database.BatchableContext BC){}
}