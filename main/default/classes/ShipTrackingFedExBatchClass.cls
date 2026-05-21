/*
* CreatedBy - Arshad
* LastModifiedBy - Arshad
* Date - 12/03/23
* Reason - Batch class to track Fedex shipments in chunks of 100 callouts (Solution for Too many callouts 101), called from scheduler - IntegratedShipmentScheduler
*/
global class ShipTrackingFedExBatchClass implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful{
    
    Set<id> shipIds = new Set<id>();
    
    global ShipTrackingFedExBatchClass(Set<id> mapIds){
        shipIds = mapIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id, Name,ERP7__TrackingNumber__c, ERP7__Status__c, ERP7__Shipment_Status__c,ERP7__Shipment_Date__c from ERP7__Shipment__c where Id IN :shipIds]); // limit 100
    }
    
    global void execute(Database.BatchableContext BC, List<ERP7__Shipment__c> shipmentrecords) {
        try{
            system.debug('ShipTrackingFedexBatch called shipmentrecords size~>'+shipmentrecords.size());
            String credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            Credentials__c cred = new Credentials__c();
            cred = Database.query('select ' + credentialFields + ' from Credentials__c where (Name = \'Fedex\' And Active__c = true) Limit 1');
            if(cred.Id != null){
                if(cred.Encrypted_Key__c != null && cred.Encrypted_Key__c != '' && cred.Password_Transkey__c != null && cred.Password_Transkey__c != ''){
                    Blob cryptoKey, passwordData;
                    cryptoKey = encodingUtil.convertFromHex(cred.Encrypted_Key__c);
                    passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(cred.Password_Transkey__c));
                    if(passwordData != null) cred.Password_Transkey__c = passwordData.toString();
                }
                List<ERP7__Shipment_Flow__c> shipmentFlows = new List<ERP7__Shipment_Flow__c>();
                List<ERP7__Shipment__c> shipments = new List<ERP7__Shipment__c>();
                Map<Id, String> shipTrackMap = new Map<Id, String>();
                Map<Id, ERP7__Shipment__c> shipmentMap = new Map<Id, ERP7__Shipment__c>();
                
                system.debug('fedex shipmentrecords~>'+shipmentrecords.size());
                if(shipmentrecords.size() > 0) shipmentMap = new Map<Id, ERP7__Shipment__c>(shipmentrecords);
                system.debug('fedex shipmentMap~>'+shipmentMap.size());
                
                if(shipmentMap.size()>0){
                    for(Id shipId : shipmentMap.keyset()){
                        system.debug('Tracking Number-->'+shipmentMap.get(shipId).ERP7__TrackingNumber__c);
                        List<String> s = new List<String>(); String mastertrackingnumber = '';
                        if(shipmentMap.get(shipId).ERP7__TrackingNumber__c != null) s = shipmentMap.get(shipId).ERP7__TrackingNumber__c.split(',');
                        if(s.size() > 0) mastertrackingnumber = s[0];
                        system.debug('s.size()~>'+s.size());
                        system.debug('mastertrackingnumber~>'+mastertrackingnumber);
                        String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://fedex.com/ws/track/v16">';
                        soapXML += '<soapenv:Body>';
                        soapXML += '<ns:TrackRequest>';
                        soapXML += '<ns:WebAuthenticationDetail>';
                        if(cred.Parent_Key__c != '' && cred.Parent_Key__c != null && cred.Parent_Password__c != '' && cred.Parent_Password__c != null ){
                            soapXML += '<ns:ParentCredential>';
                            soapXML += '<ns:Key>' + cred.Parent_Key__c.escapeXml() + '</ns:Key>';
                            soapXML += '<ns:Password>' + cred.Parent_Password__c.escapeXml() + '</ns:Password>';
                            soapXML += '</ns:ParentCredential>';
                        }
                        soapXML += '<ns:UserCredential>';
                        soapXML += '<ns:Key>'+ cred.key__c.escapeXml() +'</ns:Key>';
                        soapXML += '<ns:Password>'+ cred.Password_Transkey__c.escapeXml() +'</ns:Password>';
                        soapXML += '</ns:UserCredential>';
                        soapXML += '</ns:WebAuthenticationDetail>';
                        
                        soapXML += '<ns:ClientDetail>';
                        soapXML += '<ns:AccountNumber>'+ cred.UPS_Account_Number__c.escapeXml() +'</ns:AccountNumber>';
                        soapXML += '<ns:MeterNumber>'+ cred.Meter_Number__c.escapeXml() +'</ns:MeterNumber>';
                        soapXML += '</ns:ClientDetail>';
                        
                        soapXML += '<ns:TransactionDetail>';
                        soapXML += '<ns:CustomerTransactionId>Track By Number</ns:CustomerTransactionId>';
                        soapXML += '</ns:TransactionDetail>';
                        
                        soapXML += '<ns:Version>';
                        soapXML += '<ns:ServiceId>trck</ns:ServiceId>';
                        soapXML += '<ns:Major>16</ns:Major>'; 
                        soapXML += '<ns:Intermediate>0</ns:Intermediate>';
                        soapXML += '<ns:Minor>0</ns:Minor>';
                        soapXML += '</ns:Version>';
                        
                        soapXML += '<ns:SelectionDetails>';
                        soapXML += '<ns:PackageIdentifier>';
                        if(s.size() > 1) soapXML += '<ns:Type>STANDARD_MPS</ns:Type>'; else soapXML += '<ns:Type>TRACKING_NUMBER_OR_DOORTAG</ns:Type>';
                        //soapXML += '<ns:Value>122816215025810</ns:Value>'; // 231300687629630, 797806677146, 568838414941, 999999999999, 797843158299, 123456789012, 403934084723025
                        soapXML += '<ns:Value>'+ mastertrackingnumber +'</ns:Value>'; 
                        soapXML += '</ns:PackageIdentifier>'; 
                        soapXML += '</ns:SelectionDetails>';
                        soapXML += '<ns:ProcessingOptions>INCLUDE_DETAILED_SCANS</ns:ProcessingOptions>';
                        soapXML += '</ns:TrackRequest>';
                        soapXML += '</soapenv:Body>'; 
                        soapXML += '</soapenv:Envelope>';
                        
                        HttpRequest req = new HttpRequest();
                        Http h = new Http();
                        
                        req.setBody(soapXML);
                        req.setEndpoint(cred.URL__c); //req.setEndpoint('https://ws.fedex.com:443/web-services');
                        req.setMethod('POST');
                        req.setHeader('Content-length', '200');
                        req.setHeader('Content-Type', 'text/xml');
                        req.setHeader('SOAPAction', '');
                        HttpResponse res = new HttpResponse();
                        String resStatus = ''; String response_1 = '';
                        if(Test.isRunningTest()){
                            resStatus = 'OK'; 
                            response_1 = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><TrackReply xmlns="http://fedex.com/ws/track/v10"><HighestSeverity>SUCCESS</HighestSeverity><Notifications><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notifications><TransactionDetail><CustomerTransactionId>Track By Number</CustomerTransactionId></TransactionDetail><Version><ServiceId>trck</ServiceId><Major>10</Major><Intermediate>0</Intermediate><Minor>0</Minor></Version><CompletedTrackDetails><HighestSeverity>SUCCESS</HighestSeverity><Notifications><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notifications><DuplicateWaybill>false</DuplicateWaybill><MoreData>false</MoreData><TrackDetailsCount>0</TrackDetailsCount><TrackDetails><Notification><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notification><TrackingNumber>122816215025810</TrackingNumber><TrackingNumberUniqueIdentifier>12013~122816215025810~FDEG</TrackingNumberUniqueIdentifier><StatusDetail><CreationTime>2014-01-09T00:00:00</CreationTime><Code>DL</Code><Description>Delivered</Description><Location><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Location></StatusDetail><CarrierCode>FDXG</CarrierCode><OperatingCompanyOrCarrierDescription>FedEx Ground</OperatingCompanyOrCarrierDescription><OtherIdentifiers><PackageIdentifier><Type>CUSTOMER_REFERENCE</Type><Value>PO#174724</Value></PackageIdentifier></OtherIdentifiers><Service><Type>FEDEX_GROUND</Type><Description>FedEx Ground</Description><ShortDescription>FG</ShortDescription></Service><PackageWeight><Units>LB</Units><Value>21.5</Value></PackageWeight><PackageDimensions><Length>22</Length><Width>17</Width><Height>10</Height><Units>IN</Units></PackageDimensions><Packaging>Package</Packaging><PackagingType>YOUR_PACKAGING</PackagingType><PackageSequenceNumber>1</PackageSequenceNumber><PackageCount>1</PackageCount><SpecialHandlings><Type>DIRECT_SIGNATURE_OPTION</Type><Description>Direct Signature Required</Description><PaymentType>OTHER</PaymentType></SpecialHandlings><ShipperAddress><City>POST FALLS</City><StateOrProvinceCode>ID</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></ShipperAddress><OriginLocationAddress><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></OriginLocationAddress><ShipTimestamp>2016-08-01T00:00:00</ShipTimestamp><DestinationAddress><City>NORTON</City><StateOrProvinceCode>VA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></DestinationAddress><ActualDeliveryTimestamp>2014-01-09T13:31:00-05:00</ActualDeliveryTimestamp><ActualDeliveryAddress><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></ActualDeliveryAddress><DeliveryLocationType>SHIPPING_RECEIVING</DeliveryLocationType><DeliveryLocationDescription>Shipping/Receiving</DeliveryLocationDescription><DeliveryAttempts>0</DeliveryAttempts><DeliverySignatureName>ROLLINS</DeliverySignatureName><TotalUniqueAddressCountInConsolidation>0</TotalUniqueAddressCountInConsolidation><AvailableImages>SIGNATURE_PROOF_OF_DELIVERY</AvailableImages><NotificationEventsAvailable>ON_DELIVERY</NotificationEventsAvailable><DeliveryOptionEligibilityDetails><Option>INDIRECT_SIGNATURE_RELEASE</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><DeliveryOptionEligibilityDetails><Option>REDIRECT_TO_HOLD_AT_LOCATION</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><DeliveryOptionEligibilityDetails><Option>REROUTE</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><DeliveryOptionEligibilityDetails><Option>RESCHEDULE</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><Events><Timestamp>2014-01-09T13:31:00-05:00</Timestamp><EventType>DL</EventType><EventDescription>Delivered</EventDescription><Address><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><PostalCode>24273</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>DELIVERY_LOCATION</ArrivalLocation></Events><Events><Timestamp>2014-01-09T04:18:00-05:00</Timestamp><EventType>OD</EventType><EventDescription>On FedEx vehicle for delivery</EventDescription><Address><City>KINGSPORT</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37663</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>VEHICLE</ArrivalLocation></Events><Events><Timestamp>2014-01-09T04:09:00-05:00</Timestamp><EventType>AR</EventType><EventDescription>At local FedEx facility</EventDescription><Address><City>KINGSPORT</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37663</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>DESTINATION_FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-08T23:26:00-05:00</Timestamp><EventType>IT</EventType><EventDescription>In transit</EventDescription><Address><City>KNOXVILLE</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37921</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-08T18:14:07-06:00</Timestamp><EventType>DP</EventType><EventDescription>Departed FedEx location</EventDescription><Address><City>NASHVILLE</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37207</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-08T15:16:00-06:00</Timestamp><EventType>AR</EventType><EventDescription>Arrived at FedEx location</EventDescription><Address><City>NASHVILLE</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37207</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-07T00:29:00-06:00</Timestamp><EventType>AR</EventType><EventDescription>Arrived at FedEx location</EventDescription><Address><City>CHICAGO</City><StateOrProvinceCode>IL</StateOrProvinceCode><PostalCode>60638</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-03T19:12:30-08:00</Timestamp><EventType>DP</EventType><EventDescription>Left FedEx origin facility</EventDescription><Address><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><PostalCode>99216</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>ORIGIN_FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-03T18:33:00-08:00</Timestamp><EventType>AR</EventType><EventDescription>Arrived at FedEx location</EventDescription><Address><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><PostalCode>99216</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-03T15:00:00-08:00</Timestamp><EventType>PU</EventType><EventDescription>Picked up</EventDescription><Address><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><PostalCode>99216</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>PICKUP_LOCATION</ArrivalLocation></Events><Events><Timestamp>2014-01-03T14:31:00-08:00</Timestamp><EventType>OC</EventType><EventDescription>Shipment information sent to FedEx</EventDescription><Address><PostalCode>83854</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>CUSTOMER</ArrivalLocation></Events></TrackDetails></CompletedTrackDetails></TrackReply></SOAP-ENV:Body></SOAP-ENV:Envelope>';
                        }else {  res = h.send(req); response_1 = res.getBody();  resStatus = res.getStatus();  }
                        system.debug('resStatus-->'+resStatus);
                        system.debug('Limits.getCallouts() == '+Limits.getCallouts()); 
                        system.debug('Limits.getLimitCallouts() == '+Limits.getLimitCallouts());
                        if(resStatus == 'OK') { 
                            XmlStreamReader reader1; String msg = '';
                            if(Test.isRunningTest()) { reader1 = new XmlStreamReader(response_1);  msg = 'SUCCESS'; }else { reader1 = res.getXmlStreamReader();  msg = readXMLResponseOnce(reader1, 'Severity'); } 
                            
                            system.debug('msg Severity-->'+msg);
                            if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                                system.debug('msg-->');
                                trackwrapper tw;  List<trackwrapper> trackwrapperlist = new List<trackwrapper>(); XmlStreamReader reader;
                                if(Test.isRunningTest()) { reader = new XmlStreamReader(response_1); } else { reader = res.getXmlStreamReader(); }
                                
                                while(reader.hasNext()) {
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Events') { 
                                        tw = new trackwrapper();
                                        while(reader.hasNext()) { 
                                            // time stamp
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Timestamp') { reader.next(); tw.timestamp = reader.getText(); String yys, mms, dds, hhs, mins, secs; if(tw.timestamp != null) { yys = tw.timestamp.substring(0,4);  mms = tw.timestamp.substring(5,7); dds = tw.timestamp.substring(8,10);  hhs = tw.timestamp.substring(11,13); mins = tw.timestamp.substring(14,16);  secs = tw.timestamp.substring(17,19); tw.dateTimeString = yys +'-'+ mms +'-'+ dds + ' '+ hhs +':'+ mins +':'+ secs; tw.dtValue = Datetime.valueOf(tw.dateTimeString); } }
                                            // event description
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventDescription') { reader.next(); tw.activityDesp = reader.getText(); }
                                            //city
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'City') { reader.next(); tw.location = reader.getText(); }                        
                                            //CountryCode
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CountryCode') { reader.next(); if(tw.location != '') tw.location = tw.location +', '+ reader.getText(); else tw.location = reader.getText(); }
                                            // arrival Location
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ArrivalLocation') { reader.next(); tw.arrivalLocation = reader.getText(); }
                                            if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'Events') break; else reader.next(); 
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
                                        system.debug('Here');
                                    }else if(trackwrapperlist[i].activityDesp != null && trackwrapperlist[i].activityDesp == 'Delivered' && ExistingsfMap.get(String.valueof(trackwrapperlist[i].dtValue)).ERP7__Description__c == 'Delivered'){
                                        shipmentMap.get(shipId).ERP7__Status__c = 'Delivered';
                                    } 
                                }
                                system.debug('Shipment-->');
                                shipments.add(shipmentMap.get(shipId)); 
                                system.debug('Shipment Flows~>'+sf2create.size());
                                if(sf2create.size() > 0){ shipmentFlows.addAll(sf2create); }                                                                    
                            } else { 
                                XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'Message');
                                system.debug('Request to track shipment cannot be processed : ' + mesage);
                            }
                        } 
                    }
                }
                
                system.debug('fedex shipments-->'+shipments.size());
                system.debug('fedex shipmentFlows-->'+shipmentFlows.size());
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
                if (reader.getEventType() == XmlTag.START_ELEMENT) {  if (sxmltag == reader.getLocalName()) { while (reader.hasNext()) { if (reader.getEventType() == XmlTag.END_ELEMENT) { break; }  else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); } reader.next(); } }   } reader.next();
            } 
        } catch(Exception e) { system.debug('readXMLResponseOnce Error :' +e.getMessage() +' Line Number @ : '+ e.getLineNumber()); }
        return retValue;   
    } 
    
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; 
        try {           
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) { if (sxmltag == reader.getLocalName()) { while (reader.hasNext()) { if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); } reader.next(); } } } reader.next();
            }
        } catch(Exception e) { system.debug('readXMLResponse Error :' +e.getMessage() +' Line Number @ : '+ e.getLineNumber()); }
        return retValue;
    }
    
    global void finish(Database.BatchableContext BC){}
}