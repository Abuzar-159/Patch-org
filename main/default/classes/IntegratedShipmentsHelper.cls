// commented by Arshad 12/03/23 - not being used, moved to batch class ShipTrackingFedExBatchClass, ShipTrackingUPSBatchClass

public class IntegratedShipmentsHelper {
    /*
    @AuraEnabled public static String CurrCode                                    { get; set; }
    @AuraEnabled public static String weightUnit                                  { get; set; }
    @AuraEnabled public static Integer toalWeightValue                            { get; set; }
    @AuraEnabled public static Decimal totaldeclaredValue                         { get; set; }
    @AuraEnabled public static List<Package_List__c> pkgList                      { get; set; }
    @AuraEnabled public static String destinationStreet                           { get; set; }
    @AuraEnabled public static String DestinationProvinceCode                     { get; set; }
    @AuraEnabled public static String DestinationCountryCode                      { get; set; }
    @AuraEnabled public static String request_1                                   { get; set; } 
    @AuraEnabled public static String response_1                                  { get; set; }
    @AuraEnabled public static String resStatus                                   { get; set; }
    @AuraEnabled public static String request_UD                                  { get; set; } 
    @AuraEnabled public static String response_UD                                 { get; set; } 
    @AuraEnabled public static String resStatusUD                                 { get; set; } 
    @AuraEnabled public static String result                                      { get; set; }
    @AuraEnabled public static List<Credentials__c> fedexCredentials              { get; set; }
    @AuraEnabled public static string credentialFields                            { get; set; }
    @AuraEnabled public static string packageFields                               { get; set; }
    @AuraEnabled public static string addressFields                               { get; set; }
    @AuraEnabled public static Shipment__c Shipment                               { get; set; }
    @AuraEnabled public static String errorMsg1                                   { get; set; }
    @AuraEnabled public static String errorMsg                                    { get; set; }
    @AuraEnabled public static String amount                                      { get; set; }
    @AuraEnabled public static String MasterTrackingId                            { get; set; } 
    @AuraEnabled public static Map<String, String> recordIdMap                    { get; set; }
    @AuraEnabled public static List<Package__c> Packages                          { get; set; }
    
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
                if (reader.getEventType() == XmlTag.START_ELEMENT) { 
                    if (sxmltag == reader.getLocalName()) {
                        while (reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                            else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); }
                            reader.next(); } }  
                } reader.next();
            } 
        } catch(Exception e) { system.debug('readXMLResponseOnce Error :' +e.getMessage() +' Line Number @ : '+ e.getLineNumber()); }
        return retValue;   
    } 
    
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; 
        try {           
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) {
                    if (sxmltag == reader.getLocalName()) {
                        while (reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                            else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); }
                            reader.next(); } }
                } reader.next();
            }
        } catch(Exception e) { system.debug('readXMLResponse Error :' +e.getMessage() +' Line Number @ : '+ e.getLineNumber()); }
        return retValue;
    }
    
    @future(callout=true)
    public static void updateFedexShipments(){  
        try{
            String credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            Credentials__c cred = new Credentials__c();
            List<Shipment_Flow__c> shipmentFlows = new List<Shipment_Flow__c>();
            List<ERP7__Shipment__c> shipments = new List<ERP7__Shipment__c>();
            Set<Id> shipmentIds = new Set<Id>();
            cred = Database.query('select ' + credentialFields + ' from Credentials__c where (Name = \'Fedex\' And Active__c = true) Limit 1');
            if(cred != null){
                List<ERP7__Package__c> packageList = new List<ERP7__Package__c>();
                Map<Id, String> shipTrackMap = new Map<Id, String>();
                Map<Id, ERP7__Shipment__c> shipmentMap = new Map<Id, ERP7__Shipment__c>();
                packageList = [select Id, Name, ERP7__Shipment__c, ERP7__Shipment__r.ERP7__Tracking_Number__c from ERP7__Package__c where ERP7__Shipment__c!=null AND ERP7__Shipment_Type__c = 'FedEx' AND ERP7__Shipment__r.ERP7__Status__c != 'Delivered' AND ERP7__Shipment__r.ERP7__Tracking_Number__c != null order by CreatedDate desc];
                if(packageList.size()>0){
                    for(ERP7__Package__c pack : packageList){
                        shipmentIds.add(pack.ERP7__Shipment__c);
                    }
                    if(shipmentIds.size()>0){
                        shipmentMap = new Map<Id, ERP7__Shipment__c>([select Id, ERP7__Tracking_Number__c, ERP7__Status__c from ERP7__Shipment__c where Id IN :shipmentIds limit 15]);
                    }
                    if(shipmentMap.size()>0){
                        for(Id shipId : shipmentMap.keyset()){
                            system.debug('Tracking Number-->'+shipmentMap.get(shipId).ERP7__Tracking_Number__c);
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
                            soapXML += '<ns:Type>TRACKING_NUMBER_OR_DOORTAG</ns:Type>'; 
                            //soapXML += '<ns:Value>122816215025810</ns:Value>'; // 231300687629630, 797806677146, 568838414941, 999999999999, 797843158299, 123456789012, 403934084723025
                            soapXML += '<ns:Value>'+ shipmentMap.get(shipId).ERP7__Tracking_Number__c +'</ns:Value>'; 
                            soapXML += '</ns:PackageIdentifier>'; 
                            soapXML += '</ns:SelectionDetails>';
                            soapXML += '<ns:ProcessingOptions>INCLUDE_DETAILED_SCANS</ns:ProcessingOptions>';
                            soapXML += '</ns:TrackRequest>';
                            soapXML += '</soapenv:Body>'; 
                            soapXML += '</soapenv:Envelope>';
                            
                            HttpRequest req = new HttpRequest();
                            Http h = new Http();
                            
                            req.setBody(soapXML);
                            req.setEndpoint(cred.URL__c);
                            req.setMethod('POST');
                            req.setHeader('Content-length', '200');
                            req.setHeader('Content-Type', 'text/xml');
                            req.setHeader('SOAPAction', '');
                            request_1 = soapXmL;
                            HttpResponse res = new HttpResponse();
                            if(Test.isRunningTest()){
                                resStatus = 'OK'; 
                                response_1 = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Header/><SOAP-ENV:Body><TrackReply xmlns="http://fedex.com/ws/track/v10"><HighestSeverity>SUCCESS</HighestSeverity><Notifications><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notifications><TransactionDetail><CustomerTransactionId>Track By Number</CustomerTransactionId></TransactionDetail><Version><ServiceId>trck</ServiceId><Major>10</Major><Intermediate>0</Intermediate><Minor>0</Minor></Version><CompletedTrackDetails><HighestSeverity>SUCCESS</HighestSeverity><Notifications><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notifications><DuplicateWaybill>false</DuplicateWaybill><MoreData>false</MoreData><TrackDetailsCount>0</TrackDetailsCount><TrackDetails><Notification><Severity>SUCCESS</Severity><Source>trck</Source><Code>0</Code><Message>Request was successfully processed.</Message><LocalizedMessage>Request was successfully processed.</LocalizedMessage></Notification><TrackingNumber>122816215025810</TrackingNumber><TrackingNumberUniqueIdentifier>12013~122816215025810~FDEG</TrackingNumberUniqueIdentifier><StatusDetail><CreationTime>2014-01-09T00:00:00</CreationTime><Code>DL</Code><Description>Delivered</Description><Location><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Location></StatusDetail><CarrierCode>FDXG</CarrierCode><OperatingCompanyOrCarrierDescription>FedEx Ground</OperatingCompanyOrCarrierDescription><OtherIdentifiers><PackageIdentifier><Type>CUSTOMER_REFERENCE</Type><Value>PO#174724</Value></PackageIdentifier></OtherIdentifiers><Service><Type>FEDEX_GROUND</Type><Description>FedEx Ground</Description><ShortDescription>FG</ShortDescription></Service><PackageWeight><Units>LB</Units><Value>21.5</Value></PackageWeight><PackageDimensions><Length>22</Length><Width>17</Width><Height>10</Height><Units>IN</Units></PackageDimensions><Packaging>Package</Packaging><PackagingType>YOUR_PACKAGING</PackagingType><PackageSequenceNumber>1</PackageSequenceNumber><PackageCount>1</PackageCount><SpecialHandlings><Type>DIRECT_SIGNATURE_OPTION</Type><Description>Direct Signature Required</Description><PaymentType>OTHER</PaymentType></SpecialHandlings><ShipperAddress><City>POST FALLS</City><StateOrProvinceCode>ID</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></ShipperAddress><OriginLocationAddress><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></OriginLocationAddress><ShipTimestamp>2016-08-01T00:00:00</ShipTimestamp><DestinationAddress><City>NORTON</City><StateOrProvinceCode>VA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></DestinationAddress><ActualDeliveryTimestamp>2014-01-09T13:31:00-05:00</ActualDeliveryTimestamp><ActualDeliveryAddress><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></ActualDeliveryAddress><DeliveryLocationType>SHIPPING_RECEIVING</DeliveryLocationType><DeliveryLocationDescription>Shipping/Receiving</DeliveryLocationDescription><DeliveryAttempts>0</DeliveryAttempts><DeliverySignatureName>ROLLINS</DeliverySignatureName><TotalUniqueAddressCountInConsolidation>0</TotalUniqueAddressCountInConsolidation><AvailableImages>SIGNATURE_PROOF_OF_DELIVERY</AvailableImages><NotificationEventsAvailable>ON_DELIVERY</NotificationEventsAvailable><DeliveryOptionEligibilityDetails><Option>INDIRECT_SIGNATURE_RELEASE</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><DeliveryOptionEligibilityDetails><Option>REDIRECT_TO_HOLD_AT_LOCATION</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><DeliveryOptionEligibilityDetails><Option>REROUTE</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><DeliveryOptionEligibilityDetails><Option>RESCHEDULE</Option><Eligibility>INELIGIBLE</Eligibility></DeliveryOptionEligibilityDetails><Events><Timestamp>2014-01-09T13:31:00-05:00</Timestamp><EventType>DL</EventType><EventDescription>Delivered</EventDescription><Address><City>Norton</City><StateOrProvinceCode>VA</StateOrProvinceCode><PostalCode>24273</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>DELIVERY_LOCATION</ArrivalLocation></Events><Events><Timestamp>2014-01-09T04:18:00-05:00</Timestamp><EventType>OD</EventType><EventDescription>On FedEx vehicle for delivery</EventDescription><Address><City>KINGSPORT</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37663</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>VEHICLE</ArrivalLocation></Events><Events><Timestamp>2014-01-09T04:09:00-05:00</Timestamp><EventType>AR</EventType><EventDescription>At local FedEx facility</EventDescription><Address><City>KINGSPORT</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37663</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>DESTINATION_FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-08T23:26:00-05:00</Timestamp><EventType>IT</EventType><EventDescription>In transit</EventDescription><Address><City>KNOXVILLE</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37921</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-08T18:14:07-06:00</Timestamp><EventType>DP</EventType><EventDescription>Departed FedEx location</EventDescription><Address><City>NASHVILLE</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37207</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-08T15:16:00-06:00</Timestamp><EventType>AR</EventType><EventDescription>Arrived at FedEx location</EventDescription><Address><City>NASHVILLE</City><StateOrProvinceCode>TN</StateOrProvinceCode><PostalCode>37207</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-07T00:29:00-06:00</Timestamp><EventType>AR</EventType><EventDescription>Arrived at FedEx location</EventDescription><Address><City>CHICAGO</City><StateOrProvinceCode>IL</StateOrProvinceCode><PostalCode>60638</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-03T19:12:30-08:00</Timestamp><EventType>DP</EventType><EventDescription>Left FedEx origin facility</EventDescription><Address><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><PostalCode>99216</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>ORIGIN_FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-03T18:33:00-08:00</Timestamp><EventType>AR</EventType><EventDescription>Arrived at FedEx location</EventDescription><Address><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><PostalCode>99216</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>FEDEX_FACILITY</ArrivalLocation></Events><Events><Timestamp>2014-01-03T15:00:00-08:00</Timestamp><EventType>PU</EventType><EventDescription>Picked up</EventDescription><Address><City>SPOKANE</City><StateOrProvinceCode>WA</StateOrProvinceCode><PostalCode>99216</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>PICKUP_LOCATION</ArrivalLocation></Events><Events><Timestamp>2014-01-03T14:31:00-08:00</Timestamp><EventType>OC</EventType><EventDescription>Shipment information sent to FedEx</EventDescription><Address><PostalCode>83854</PostalCode><CountryCode>US</CountryCode><CountryName>United States</CountryName><Residential>false</Residential></Address><ArrivalLocation>CUSTOMER</ArrivalLocation></Events></TrackDetails></CompletedTrackDetails></TrackReply></SOAP-ENV:Body></SOAP-ENV:Envelope>';
                            }else { 
                                res = h.send(req);
                                response_1 = res.getBody(); 
                                resStatus = res.getStatus(); 
                            }
                            if(resStatus == 'OK') { 
                                system.debug('resStatus-->');
                                XmlStreamReader reader1;
                                String msg = '';
                                if(Test.isRunningTest()) {
                                    reader1 = new XmlStreamReader(response_1); 
                                    msg = 'SUCCESS';
                                }else {
                                    reader1 = res.getXmlStreamReader(); 
                                    msg = readXMLResponseOnce(reader1, 'Severity');
                                } 
                                
                                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                                    system.debug('msg-->');
                                    trackwrapper tw; 
                                    List<trackwrapper> trackwrapperlist = new List<trackwrapper>();
                                    
                                    XmlStreamReader reader;
                                    if(Test.isRunningTest()) {reader = new XmlStreamReader(response_1);}
                                    else { reader = res.getXmlStreamReader(); }
                                    
                                    while(reader.hasNext()) {
                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Events') { 
                                            tw = new trackwrapper();
                                            while(reader.hasNext()) { 
                                                // time stamp
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Timestamp') { 
                                                    reader.next(); tw.timestamp = reader.getText(); String yys, mms, dds, hhs, mins, secs;
                                                    if(tw.timestamp != null) { yys = tw.timestamp.substring(0,4);  mms = tw.timestamp.substring(5,7);
                                                                              dds = tw.timestamp.substring(8,10);  hhs = tw.timestamp.substring(11,13);
                                                                              mins = tw.timestamp.substring(14,16);  secs = tw.timestamp.substring(17,19);                                                      
                                                                              tw.dateTimeString = yys +'-'+ mms +'-'+ dds + ' '+ hhs +':'+ mins +':'+ secs;
                                                                              tw.dtValue = Datetime.valueOf(tw.dateTimeString); } }
                                                // event description
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventDescription') { reader.next(); tw.activityDesp = reader.getText(); }
                                                //city
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'City') { reader.next(); tw.location = reader.getText(); }                        
                                                //CountryCode
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CountryCode') { reader.next();
                                                                                                                                             if(tw.location != '') tw.location = tw.location +', '+ reader.getText(); else tw.location = reader.getText(); }
                                                // arrival Location
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ArrivalLocation') { reader.next(); tw.arrivalLocation = reader.getText(); }
                                                if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'Events') break; else reader.next(); 
                                            } trackwrapperlist.add(tw);
                                        } reader.next();
                                    }
                                    
                                    system.debug('--- trackwrapperlist : ' +trackwrapperlist);
                                    List<Shipment_Flow__c> existingSFList;  Map<String, Shipment_Flow__c> sfMap = new Map<String, Shipment_Flow__c>();
                                    if(shipId != null) { 
                                        for(Shipment_Flow__c sf: [select Id, Name, Shipment__c, Shipment_DateTime__c, Description__c, Shipment_Flow_Start_Date__c, 
                                                                  Shipment_Flow_End_Date__c from Shipment_Flow__c where Shipment__c =: shipId Order by Name Asc]) { 
                                                                      sfMap.put(sf.Shipment_DateTime__c, sf); }
                                    }
                                    system.debug('--- sfMap : ' +sfMap);
                                    for(Integer i=0; i<trackWrapperList.size(); i++) {
                                        Shipment_Flow__c sf = new Shipment_Flow__c(Shipment_DateTime__c = String.valueof(trackWrapperList[i].dtValue));
                                        system.debug('sf-->'+sf);
                                        system.debug('Key Set-->'+sfMap.keyset().contains(String.valueof(trackWrapperList[i].dtValue)));
                                        if(sfMap.keyset().contains(String.valueof(trackWrapperList[i].dtValue))) {
                                            system.debug('Entered');
                                            sf.Name = 'Shipment Flow ' +shipmentMap.get(shipId).ERP7__Tracking_Number__c +' ' + i;
                                            if(shipmentMap.get(shipId) != null) sf.Shipment__c = shipId;
                                            sf.Active__c = true;                            
                                            if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_Start_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                                            if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_End_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                                            if(trackWrapperList[i].activityDesp != null) sf.Description__c = trackWrapperList[i].activityDesp;
                                            if(trackWrapperList[i].activityDesp != null && trackWrapperList[i].activityDesp == 'Delivered') {
                                                shipmentMap.get(shipId).ERP7__Status__c = 'Delivered'; 
                                            }
                                            else shipmentMap.get(shipId).ERP7__Shipment_Status__c = trackWrapperList[i].activityDesp;
                                            system.debug('Here');
                                            sfMap.put(String.valueof(trackWrapperList[i].dtValue), sf);
                                        } 
                                    }
                                    system.debug('Shipment-->');
                                    if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) {
                                        shipments.add(shipmentMap.get(shipId));
                                    }
                                    //if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { pac.Status__c = shipmentMap.get(shipId).Status__c; } update packList; }
                                    system.debug('Shipment Flows');
                                    if(sfMap.size() > 0){
                                        shipmentFlows.add(sfMap.values());
                                    }
                                    // break;
                                    //fWrap.UPSErrorMsg = 'Track Shipment Activities';                                                                                   
                                } else { 
                                    XmlStreamReader message = res.getXmlStreamReader();
                                    String mesage = readXMLResponse(message, 'Message');
                                    system.debug('Request to track shipment cannot be processed : ' + mesage);
                                }
                            } 
                        }
                    }
                }
            }
            system.debug('259 Shipment');
            system.debug('shipments-->'+shipments);
            system.debug('shipmentFlows-->'+shipmentFlows);
            if(shipments.size()>0) update shipments;
            if(shipmentFlows.size()>0) upsert shipmentFlows;
        }catch(Exception e){
            system.debug('Exception-->'+e+'--'+e.getMessage()+'--'+e.getLineNumber()+'--'+e.getStackTraceString()+'---'+e.getCause());
        }
    }
    
    
    
    @future(callout=true)
    public static void updateUPSShipments(){  
        try{
            String credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            Credentials__c cred = new Credentials__c();
            List<Shipment_Flow__c> shipmentFlows = new List<Shipment_Flow__c>();
            List<ERP7__Shipment__c> shipments = new List<ERP7__Shipment__c>();
            Set<Id> shipmentIds = new Set<Id>();
            cred = Database.query('select ' + credentialFields + ' from Credentials__c where (Name = \'UPS\' And Active__c = true) Limit 1');
            if(cred != null){
                List<ERP7__Package__c> packageList = new List<ERP7__Package__c>();
                Map<Id, String> shipTrackMap = new Map<Id, String>();
                Map<Id, ERP7__Shipment__c> shipmentMap = new Map<Id, ERP7__Shipment__c>();
                packageList = [select Id, Name, ERP7__Shipment__c, ERP7__Shipment__r.ERP7__Tracking_Number__c from ERP7__Package__c where ERP7__Shipment__c!=null AND ERP7__Shipment_Type__c = 'UPS' AND ERP7__Shipment__r.ERP7__Status__c != 'Delivered' AND ERP7__Shipment__r.ERP7__Tracking_Number__c != null order by CreatedDate desc];
                if(packageList.size()>0){
                    for(ERP7__Package__c pack : packageList){
                        shipmentIds.add(pack.ERP7__Shipment__c);
                    }
                    if(shipmentIds.size()>0){
                        shipmentMap = new Map<Id, ERP7__Shipment__c>([select Id, ERP7__Tracking_Number__c, ERP7__Status__c from ERP7__Shipment__c where Id IN :shipmentIds limit 15]);
                    }
                    if(shipmentMap.size()>0){
                        for(Id shipId : shipmentMap.keyset()){
                            system.debug('Tracking Number-->'+shipmentMap.get(shipId).ERP7__Tracking_Number__c);
                            
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
                            soapXML += '<TrackingNumber>'+ shipmentMap.get(shipId).ERP7__Tracking_Number__c +'</TrackingNumber>';
                            //soapXML += '<TrackingNumber>1Z5506R30300841498</TrackingNumber>'; // Test Tracking Number
                            soapXML += '</TrackRequest>';
                            
                            Http h = new Http();
                            HttpRequest req = new HttpRequest();
                            
                            req.setBody(soapXML);
                            req.setMethod('POST');
                            String myEndPoint = cred.URL__c + '/ups.app/xml/Track';
                            req.setEndpoint(myEndPoint);
                            
                            HttpResponse res = new HttpResponse();
                            if(Test.isRunningTest()){
                                response_1 = '<TrackResponse><Response><ResponseStatusCode>1</ResponseStatusCode><ResponseStatusDescription>Success</ResponseStatusDescription></Response><Shipment><Shipper><ShipperNumber>5506R3</ShipperNumber><Address><AddressLine1>13818 RIDER TRAIL DR</AddressLine1><City>EARTH CITY</City><StateProvinceCode>MO</StateProvinceCode><PostalCode>63045</PostalCode><CountryCode>US</CountryCode></Address></Shipper><ShipTo><Address><City>FLORISSANT</City><StateProvinceCode>MO</StateProvinceCode><PostalCode>63033</PostalCode><CountryCode>US</CountryCode></Address></ShipTo><ShipmentWeight><UnitOfMeasurement><Code>LBS</Code></UnitOfMeasurement><Weight>2.30</Weight></ShipmentWeight><Service><Code>003</Code><Description>UPS Ground</Description></Service><ReferenceNumber><Code>01</Code><Value>1016316586303001</Value></ReferenceNumber><ShipmentIdentificationNumber>1Z5506R30300841498</ShipmentIdentificationNumber><PickupDate>20190624</PickupDate><DeliveryDateUnavailable><Type>Scheduled Delivery</Type><Description>Scheduled Delivery Date is not currently available, please try back later</Description></DeliveryDateUnavailable><Package><TrackingNumber>1Z5506R30300841498</TrackingNumber><DeliveryIndicator>Y</DeliveryIndicator><DeliveryDate>20190624</DeliveryDate><Activity><ActivityLocation><Address><City>FLORISSANT</City><StateProvinceCode>MO</StateProvinceCode><PostalCode>63033</PostalCode><CountryCode>US</CountryCode></Address><Code>M1</Code><Description>Residential</Description><SignedForByName>BRIDGES</SignedForByName></ActivityLocation><Status><StatusType><Code>D</Code><Description>Delivered</Description></StatusType><StatusCode><Code>KB</Code></StatusCode></Status><Date>20190624</Date><Time>144318</Time><GMTDate>2019-06-24</GMTDate><GMTTime>19:43:18</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><City>Earth City</City><StateProvinceCode>MO</StateProvinceCode><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>I</Code><Description>Out For Delivery Today</Description></StatusType><StatusCode><Code>OT</Code></StatusCode></Status><Date>20190624</Date><Time>083057</Time><GMTDate>2019-06-24</GMTDate><GMTTime>13:30:57</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><City>Earth City</City><StateProvinceCode>MO</StateProvinceCode><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>I</Code><Description>Destination Scan</Description></StatusType><StatusCode><Code>DS</Code></StatusCode></Status><Date>20190624</Date><Time>033315</Time><GMTDate>2019-06-24</GMTDate><GMTTime>08:33:15</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><City>Hazelwood</City><StateProvinceCode>MO</StateProvinceCode><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>I</Code><Description>Origin Scan</Description></StatusType><StatusCode><Code>OC</Code></StatusCode></Status><Date>20190624</Date><Time>000519</Time><GMTDate>2019-06-24</GMTDate><GMTTime>05:05:19</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><Activity><ActivityLocation><Address><CountryCode>US</CountryCode></Address><Description>Residential</Description></ActivityLocation><Status><StatusType><Code>M</Code><Description>Order Processed: Ready for UPS</Description></StatusType><StatusCode><Code>MP</Code></StatusCode></Status><Date>20190624</Date><Time>021308</Time><GMTDate>2019-06-24</GMTDate><GMTTime>07:13:08</GMTTime><GMTOffset>-05:00</GMTOffset></Activity><PackageWeight><UnitOfMeasurement><Code>LBS</Code></UnitOfMeasurement><Weight>2.30</Weight></PackageWeight><ReferenceNumber><Code>01</Code><Value>AN5-4023101-4800111</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>DTSTJR2XP</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>NA</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>NA</Value></ReferenceNumber><ReferenceNumber><Code>01</Code><Value>UPS-MOEAR-PPD0190624  PDSTL5EARMOUP</Value></ReferenceNumber></Package></Shipment></TrackResponse>';
                                resStatus = '200';
                            }else{
                                res = h.send(req); request_1 = req.getBody(); response_1 = res.getBody(); resStatus = res.getStatus();
                                
                            }
                            system.debug('resStatus-->'+resStatus);
                            if(resStatus == 'OK') { 
                                system.debug('resStatus-->');
                                XmlStreamReader reader1;
                                String msg = '';
                                if(Test.isRunningTest()) {reader1 = new XmlStreamReader(response_1); msg = 'SUCCESS';}
                				else {reader1 = res.getXmlStreamReader(); system.debug('reader1-->'+reader1);msg = readXMLResponseOnce(reader1, 'ResponseStatusDescription'); }
                                system.debug('msg-->');
                                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                                    
                                    trackwrapper tw; 
                                    List<trackwrapper> trackwrapperlist = new List<trackwrapper>();
                                    
                                    XmlStreamReader reader;
                                    if(Test.isRunningTest()) {reader = new XmlStreamReader(response_1);}
                                    else { reader = res.getXmlStreamReader(); }
                                    
                                    while (reader.hasNext()) {
                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Activity') {
                                            tw = new trackwrapper();
                                            while(reader.hasNext()) {        
                                                //city
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'City') { 
                                                    reader.next(); tw.location = reader.getText(); 
                                                }                        
                                                //CountryCode
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CountryCode') {
                                                    reader.next();
                                                    if(tw.location != null && tw.location != '') tw.location = tw.location +', '+ reader.getText(); else tw.location = reader.getText();
                                                } 
                                                //SignedForByName
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SignedForByName') { 
                                                    reader.next(); 
                                                    if(reader.hasText()) { tw.SignedForByName = reader.getText(); } else { tw.SignedForByName = '-'; }
                                                }
                                                //StatusType
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'StatusType') { 
                                                    reader.next(); reader.next(); reader.next(); reader.next(); reader.next(); tw.activityDesp = reader.getText(); }                        
                                                //Date
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Date') { 
                                                    reader.next();
                                                    tw.tDate = reader.getText(); String yys, mms, dds;
                                                    if(tw.tDate != null) { yys = tw.tDate.substring(0,4);
                                                                          mms = tw.tDate.substring(4,6);
                                                                          dds = tw.tDate.substring(6,8);
                                                                          tw.dateTimeString = yys +'-'+ mms +'-'+ dds; }                         
                                                }                        
                                                //Time
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Time') { reader.next();
                                                                                                                                      tw.tTime = reader.getText(); String hhs, mins, secs;
                                                                                                                                      if(tw.tTime != null) { hhs = tw.tTime.substring(0,2);
                                                                                                                                                            mins = tw.tTime.substring(2,4);
                                                                                                                                                            secs = tw.tTime.substring(4,6);
                                                                                                                                                            if(tw.dateTimeString != null) tw.dateTimeString += ' '+ hhs +':'+ mins +':'+ secs;                            
                                                                                                                                                            tw.dtValue = Datetime.valueOf(tw.dateTimeString); }
                                                                                                                                     }                        
                                                if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'Activity') break; else reader.next(); 
                                            } trackwrapperlist.add(tw);
                                        } reader.next();
                                    }
                                    
                                    system.debug('--- trackwrapperlist : ' +trackwrapperlist);
                                    List<Shipment_Flow__c> existingSFList;  Map<String, Shipment_Flow__c> sfMap = new Map<String, Shipment_Flow__c>();
                                    if(shipId != null) { 
                                        for(Shipment_Flow__c sf: [select Id, Name, Shipment__c, Shipment_DateTime__c, Description__c, Shipment_Flow_Start_Date__c, 
                                                                  Shipment_Flow_End_Date__c from Shipment_Flow__c where Shipment__c =: shipId Order by Name Asc]) { 
                                                                      sfMap.put(sf.Shipment_DateTime__c, sf); }
                                    }
                                    system.debug('--- sfMap : ' +sfMap);
                                    for(Integer i=0; i<trackWrapperList.size(); i++) {
                                        Integer wrapperSize = integer.valueOf(trackWrapperList.size());
                                        Shipment_Flow__c sf = new Shipment_Flow__c(Shipment_DateTime__c = String.valueof(trackWrapperList[i].dtValue));
                                        if(!sfMap.keyset().contains(String.valueof(trackWrapperList[i].dtValue))) {
                                            if(Schema.sObjectType.Shipment_Flow__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Name.isUpdateable()) sf.Name = 'SF ' + shipmentMap.get(shipId).Name + '-' + string.valueOf(wrapperSize - i);
                                            if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isUpdateable()) if(shipmentMap.get(shipId) != null) sf.Shipment__c = shipmentMap.get(shipId).Id;
                                            if(Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isUpdateable()) sf.Active__c = true;                            
                                            if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isUpdateable()) if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_Start_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                                            if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isUpdateable()) if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_End_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                                            if(Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isUpdateable()) if(trackWrapperList[i].activityDesp != null) sf.Description__c = trackWrapperList[i].activityDesp;
                                            if(trackWrapperList[i].activityDesp != null && trackWrapperList[i].activityDesp == 'Delivered') { if(Schema.sObjectType.Shipment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Status__c.isUpdateable()) shipmentMap.get(shipId).ERP7__Status__c = 'Delivered'; }
                                            else shipmentMap.get(shipId).ERP7__Shipment_Status__c = trackWrapperList[i].activityDesp;
                                            
                                            sfMap.put(String.valueof(trackWrapperList[i].dtValue), sf);
                                        } 
                                    }
                                    system.debug('Shipment-->');
                                    if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) {
                                        shipments.add(shipmentMap.get(shipId));
                                    }
                                    //if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { pac.Status__c = shipmentMap.get(shipId).Status__c; } update packList; }
                                    system.debug('Shipment Flows');
                                    if(sfMap.size() > 0){
                                        shipmentFlows.add(sfMap.values());
                                    }
                                    // break;
                                    //fWrap.UPSErrorMsg = 'Track Shipment Activities';                                                                                   
                                } else { 
                                    XmlStreamReader message = res.getXmlStreamReader();
                                    String mesage = readXMLResponse(message, 'Message');
                                    system.debug('Request to track shipment cannot be processed : ' + mesage);
                                }
                            } 
                        }
                    }
                }
            }
            system.debug('259 Shipment');
            system.debug('shipments-->'+shipments);
            system.debug('shipmentFlows-->'+shipmentFlows);
            if(shipments.size()>0) update shipments;
            if(shipmentFlows.size()>0) upsert shipmentFlows;
        }catch(Exception e){
            system.debug('Exception-->'+e+'--'+e.getMessage()+'--'+e.getLineNumber()+'--'+e.getStackTraceString()+'---'+e.getCause());
        }
    }
    */
}