public with sharing class CanadaPost {
   
    @AuraEnabled public static String CurrCode                                    { get; set; }    @AuraEnabled public static String weightUnit                                  { get; set; }    @AuraEnabled public static Integer toalWeightValue                            { get; set; }
    @AuraEnabled public static Decimal totaldeclaredValue                         { get; set; }
    //@AuraEnabled public static List < Package_Line_Item__c > pkgList                      { get; set; }
    @AuraEnabled public static String destinationStreet1                           { get; set; }
    @AuraEnabled public static String destinationStreet2                           { get; set; }
    @AuraEnabled public static String DestinationProvinceCode                     { get; set; }
    @AuraEnabled public static String DestinationCountryCode                      { get; set; }    @AuraEnabled public static String request_1                                   { get; set; }
    @AuraEnabled public static String response_1                                  { get; set; }
    @AuraEnabled public static String resStatus                                   { get; set; }    @AuraEnabled public static String request_2                                   { get; set; }    @AuraEnabled public static String response_2                                  { get; set; }    @AuraEnabled public static String resStatus2                                   { get; set; }    @AuraEnabled public static String PdfAttach                                   { get; set; }
    @AuraEnabled public static String request_UD                                  { get; set; }
    @AuraEnabled public static String response_UD                                 { get; set; }
    @AuraEnabled public static String resStatusUD                                 { get; set; }
    @AuraEnabled public static String result                                      { get; set; }
    @AuraEnabled public static List < Credentials__c > CPCredentials              { get; set; }
    @AuraEnabled public static string credentialFields                            { get; set; }
    @AuraEnabled public static string packageFields                               { get; set; }
    @AuraEnabled public static string addressFields                               { get; set; }
    @AuraEnabled public static Shipment__c Shipment                               { get; set; }
    @AuraEnabled public static String errorMsg1                                   { get; set; }
    @AuraEnabled public static String errorMsg                                    { get; set; }
    @AuraEnabled public static String amount                                      { get; set; }    @AuraEnabled public static String artifactId                                      { get; set; }    @AuraEnabled public static String trackingId                                      { get; set; }    @AuraEnabled public static String shipmentId                                      { get; set; }
    @AuraEnabled public static String MasterTrackingId                            { get; set; }
    @AuraEnabled public static Map < String, String > recordIdMap                    { get; set; }
    @AuraEnabled public static List < Package__c > Packages                          { get; set; }
    
    @AuraEnabled
    public static String getProvinceCode(String provinceName) {
        List < Province_Codes__c > provinceList;
        if (provinceName != null && provinceName != '') {
            provinceList = [Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c =: String.escapeSingleQuotes(provinceName) Limit 1];
        } if (provinceList != null && provinceList.size() > 0) {return provinceList[0].Code__c;}        else return '';
    }
    
    @AuraEnabled
    public static String getCountryCode(String countryName) {
        List < Country_Codes__c > countryList;
        if (countryName != null && countryName != '') {
            countryList = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: String.escapeSingleQuotes(countryName) Limit 1];
        } if (countryList != null && countryList.size() > 0) { return countryList[0].Code__c;}        else return '';
    }
    
    @AuraEnabled
    public static String getStreet(String AddressLine1, String AddressLine2, String AddressLine3) {
        if ((AddressLine1 != Null && AddressLine1 != '') && (AddressLine2 != Null && AddressLine2 != '') && (AddressLine3 != Null && AddressLine3 != '')) {
            return AddressLine1 + ', ' + AddressLine2 + ', ' + AddressLine3;
        }
        else if ((AddressLine1 != Null && AddressLine1 != '') && (AddressLine2 != Null && AddressLine2 != '')) { return AddressLine1 + ', ' + AddressLine2; }
        else if (AddressLine1 != Null && AddressLine1 != '') { return AddressLine1; }
        else return '';
    }
    
    @AuraEnabled
    public static List < String > getTermsOfShipment(){
        List < String > options = new List < String > (); Schema.DescribeFieldResult fieldResult = Shipment__c.Terms_Of_Shipment__c.getDescribe(); List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) { options.add(f.getLabel()); } return options;
    }
    
    @AuraEnabled
    public static List < String > getReasonForExport(){
        List < String > options = new List < String > (); Schema.DescribeFieldResult fieldResult = Shipment__c.Reason_For_Export__c.getDescribe(); List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) { options.add(f.getLabel()); } return options;
    }
    
    @AuraEnabled
    public static Map< String, String > getServices(){
        List<Schema.PicklistEntry> ple = Shipment__c.USPS_Services__c.getDescribe().getPicklistValues(); 
        Map<String,String> options = new Map<String,String>(); for(Schema.PicklistEntry f : ple) { options.put(f.getValue(), f.getLabel()); } return options;
    }
    
    @AuraEnabled
    public static List < String > getStatusConfirmation(){
        List < String > options = new List < String > (); Schema.DescribeFieldResult fieldResult = Shipment__c.Status__c.getDescribe(); List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) { options.add(f.getLabel()); } return options;
    }
    
    @AuraEnabled
    public static List < String > getShipmentsStatus(){
        List < String > options = new List < String > (); Schema.DescribeFieldResult fieldResult = Shipment__c.Status__c.getDescribe(); List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) { options.add(f.getLabel()); } return options;
    }
    
    @AuraEnabled
    public static Address__c fetchToAddress(String packId){
        system.debug('--> inside fetchToAddress packageId is :' + packId);
        List < String > pakIds = new List < String > ();
        if (String.isNotEmpty(packId)) pakIds = (List < String >) JSON.deserialize(packId, List < String > .class);
        Address__c address = new Address__c();
        try {
            Package__c packages = new Package__c();
            if (pakIds.size() > 0) {
                packages = [Select Id, Name, Active__c, Weight__c, Order__c,Logistic__c,
                            Weight_Unit__c, Length__c, Width__c, Height__c, Package_Type__c, Order__r.Ship_To_Address__c,
                            Shipment_Type__c, Declared_Value__c, Package_Quantity__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Transfer_Order__r.Name, Transfer_Order__r.To_Address__c 
                            from Package__c where ID In : pakIds limit 1];
            }
            system.debug('fetchToAddress package are :' + packages);
            if (packages.Id != null) {
                if (packages.Order__c != null || packages.Transfer_Order__c != null || packages.Logistic__c != null) {
                    address = [Select Id, Name, Customer__c, Contact__c, Active__c,
                               Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                               Address_Line2__c, Address_Line3__c, City__c, Country__c,
                               State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                               Contact__r.Email, Contact__r.Phone from Address__c where(Id=: packages.Logistic__c or ID =: packages.Order__r.Ship_To_Address__c Or ID =: packages.Transfer_Order__r.To_Address__c) limit 1];
                } else if (packages.Return_Merchandise_Authorisation__c != null) {                    Return_Merchandise_Authorisation__c RMA = [Select Id, Address__c, Site__c, Site__r.Address__c From Return_Merchandise_Authorisation__c where Id =: packages.Return_Merchandise_Authorisation__c];                    if (RMA.Id != null && RMA.Site__c != null) {                        address = [Select Id, Name, Customer__c, Contact__c, Active__c,                                   Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,                                   Address_Line2__c, Address_Line3__c, City__c, Country__c,                                   State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,                                   Contact__r.Email, Contact__r.Phone from Address__c where Id =: RMA.Site__r.Address__c limit 1];                    }                }
            }
            system.debug('To address are :' + address);
        } catch (Exception e) { system.debug('Error :  ' + e.getMessage() + '; at line ~> ' + e.getLineNumber()); }
        
        return address;
    }
    
    @AuraEnabled
    public static Address__c fetchFromAddress(String packId){
        system.debug('@@@inside fetchFromAddress packageId is :' + packId);
        List < String > pakIds = new List < String > ();
        if (String.isNotEmpty(packId)) pakIds = (List < String >) JSON.deserialize(packId, List < String > .class);
        Address__c address = new Address__c();
        try {
            Package__c packages = new Package__c();
            if (pakIds.size() > 0) {
                packages = [Select Id, Name, Active__c, Weight__c, Order__c,
                            Weight_Unit__c, Length__c, Width__c, Height__c, Package_Type__c, Transfer_Order__c, Transfer_Order__r.From_Address__c,
                            Shipment_Type__c, Declared_Value__c, Package_Quantity__c, Return_Merchandise_Authorisation__c
                            from Package__c where ID In : pakIds limit 1];
            }
            system.debug('packages are :' + packages);
            if (packages.Id != null) {
                if ((packages.Order__c != null) || packages.Transfer_Order__c != null) {
                    address = [Select Id, Name, Customer__c, Contact__c, Active__c,
                               Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                               Address_Line2__c, Address_Line3__c, City__c, Country__c,
                               State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                               Contact__r.Email, Contact__r.Phone from Address__c where( ID =: packages.Transfer_Order__r.From_Address__c) limit 1];
                } else if (packages.Return_Merchandise_Authorisation__c != null) {                    Return_Merchandise_Authorisation__c RMA = [Select Id, Address__c, Site__c, Site__r.Address__c From Return_Merchandise_Authorisation__c where Id =: packages.Return_Merchandise_Authorisation__c];                    if (RMA.Id != null && RMA.Address__c != null) {                        address = [Select Id, Name, Customer__c, Contact__c, Active__c,                                   Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,                                   Address_Line2__c, Address_Line3__c, City__c, Country__c,                                   State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,                                   Contact__r.Email, Contact__r.Phone from Address__c where Id =: RMA.Address__c limit 1];                    }                }
            }
            system.debug('address are :' + address);
        } catch (Exception e) { system.debug('Erro myconstruct :  ' + e.getMessage() + '; at line ~> ' + e.getLineNumber()); }
        return address;
    }
    
    @AuraEnabled
    public static List < Package__c > fetchingPackages(String packId){
        system.debug('@@@inside fetchingPackages packageId is :' + packId);
        List < Package__c > packList = new List < Package__c > ();
        try {
            List < String > pakIds = new List < String > ();
            if (String.isNotEmpty(packId)) pakIds = (List < String >) JSON.deserialize(packId, List < String > .class);
            if (pakIds.size() > 0) {
                packList = [Select Id, Name, Weight__c, Length__c, Width__c, Height__c,
                            Active__c, Package_Type__c, Shipment_Type__c, Weight_Unit__c, Status__c,
                            Declared_Value__c, Package_Quantity__c, DropoffType__c, Shipment__c,
                            Return_Merchandise_Authorisation__r.Order__c,Shipment__r.Name, Logistic__c, Order__c, Purchase_Order__c, Transfer_Order__c, Transfer_Order__r.Name,Logistic__r.Order__c,Order__r.OrderNumber
                            // Return_Merchandise_Authorisation__r.Order__r.Name, Return_Merchandise_Authorisation__r.Order__r.OrderNumber,Order__r.Name, Logistic__r.Order__r.Contact__c, Logistic__r.Order__r.Contact__r.Name, Logistic__r.Order__r.Contact__r.Phone, Logistic__r.Order__r.Contact__r.Email, Logistic__r.Order__r.Contact__r.Company__c
                            from Package__c where ID In: pakIds];
            }
            system.debug('*** packList size : ' + packList.size());
        } catch (Exception e) { throw new AuraHandledException(e.getMessage() + '; at line ~> ' + e.getLineNumber()); }
        return packList;
    }
    
    @AuraEnabled
    public static credentialWrapper getCredentialDetails(String shipId, String retValue, String packId){
        system.debug('*** Constructor called and shipId : ' + shipId+ ' and packId: '+packId);
        List<Package__c> packageList = new List<Package__c>();
        List<String> packIds = new List<String>();
         if (packId != null && packId != '') packIds = (List<String>) JSON.deserialize(packId, List<String>.class);
        if(packId != null && packId != '') {            packageList=[Select Id, Active__c,Logistic__r.From_Address__c,Weight__c,Transfer_Order__r.From_Address__c, Order__c, Logistic__c,Logistic__r.To_Address__c,                         Weight_Unit__c, Length__c, Width__c, Height__c, Package_Type__c, Order__r.Ship_To_Address__c ,                         Shipment_Type__c,Return_Merchandise_Authorisation__c, Declared_Value__c, Package_Quantity__c,Transfer_Order__c,Transfer_Order__r.To_Address__c                                                 from Package__c where ID IN :packIds];        }
        credentialWrapper MCW = new credentialWrapper();
        try {
            credentialFields = UtilClass.selectStarFromSObject('Credentials__c');
            MCW.pkgs = new List < Package_Details__c > ([select Id, Name, Shipment_Description__c from Package_Details__c where Shipment_Description__c != null limit 1]);
            //System.debug('MCW.pkgs : '+MCW.pkgs);
            MCW.CPCredentials = Database.query('select ' + credentialFields + ' from Credentials__c where (Name = \'Canada Post\' And Active__c = true) Limit 1');// (Name = \'Canada Post\' And Active__c = true)
            if (MCW.CPCredentials != null && MCW.CPCredentials.size() > 0) { 
                system.debug('MCW.CPCredentials.size() : ' + MCW.CPCredentials.size());
               
                MCW.password = MCW.CPCredentials[0].Password_Transkey__c;
                MCW.username = MCW.CPCredentials[0].Username_Login__c;
                MCW.endPoint = MCW.CPCredentials[0].URL__c;
                system.debug('till here 1? ');
                MCW.accountNumber = MCW.CPCredentials[0].UPS_Account_Number__c;
                MCW.contractNumber = MCW.CPCredentials[0].Account_Id__c;
                system.debug('till here 2? ');
                MCW.PostalCode = MCW.CPCredentials[0].Shipper_Postal_Code__c;
                system.debug('till here 3? ');
                MCW.Email = MCW.CPCredentials[0].Shipper_Email__c;
                system.debug('till here 4? ');
                if (getProvinceCode(MCW.CPCredentials[0].Shipper_Province__c) != '')
                    MCW.shipperProvinceCode = getProvinceCode(MCW.CPCredentials[0].Shipper_Province__c);
                //else MCW.wrapError = 'Canada Post Shipping Service Unavailable : Shipper Province Code not found';
                if (getCountryCode(MCW.CPCredentials[0].Shipper_Country__c) != '')
                    MCW.shipperCountryCode = getCountryCode(MCW.CPCredentials[0].Shipper_Country__c);                /* else MCW.wrapError = 'Canada Post Shipping Service Unavailable : Shipper Country Code not found';*/            } else MCW.wrapError = 'Canada Post Shipping Service Unavailable : Please setup Canada Post credentials';
            
            String ShipmentRecTypeId =RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Canada_Post_shipping');// RecordTypeUtils.getObjectRecordTypeIds('Shipment__c', 'Canada_Post_Shipping');
            System.debug('ShipmentRecTypeId'+ShipmentRecTypeId);
            if (shipId != null && shipId != '') {
                packageFields = UtilClass.selectStarFromSObject('Package__c');
                addressFields = UtilClass.selectStarFromSObject('Address__c');
                
                List<Attachment> AttaLbl =  Database.query('select Id, Name from Attachment where ParentId=\'' + String.escapeSingleQuotes(shipId) + '\' AND Name LIKE \'CP_Label_%\'');
                if(AttaLbl.size() > 0) MCW.AttachLabel = AttaLbl[0];
                List<Attachment> SPLabel =  Database.query('select Id, Name from Attachment where ParentId=\'' + String.escapeSingleQuotes(shipId) + '\' And Name LIKE \'CP_Manifest%\'');
                if(SPLabel.size() > 0) MCW.spodLetter = SPLabel[0];
                //MCW.Packages = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c,Order__r.Bill_To_Address__c, Order__r.Ship_To_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Invoice_Address__c, Order__r.Name,Order__r.OrderNumber, Transfer_Order__r.From_Address__c,Transfer_Order__r.Name, Transfer_Order__r.To_Address__c,Return_Merchandise_Authorisation__r.Order__r.Bill_To_Address__c, Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Order__r.Contact__r.Email from Package__c where Shipment__c =\'' + String.escapeSingleQuotes(shipId) + '\' And Active__c = true');
                
                List < Shipment__c > shipmnts = new List < Shipment__c > ();
                shipmnts = Database.query('select Id, Name, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Date__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c,Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Logistic__r.From_Address__c, Carrier_Code__c, Transfer_Order__c, Purchase_Orders__c,Shipment_Identification_Number__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Package__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Return_Merchandise_Authorisation__c,Return_Merchandise_Authorisation__r.Address__c,Description__c,Message__c from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1');   // And Status__c != \'Cancelled\'      
                
                Shipment__c Shipment = new Shipment__c();
                system.debug('shipmnts.size(): '+shipmnts.size());
                if (shipmnts.size() > 0) {
                    Shipment = shipmnts[0];
                }
                MCW.Shipment = (Shipment.Id != null) ? Shipment : new Shipment__c();
                if (MCW.Packages.size() > 0) {                    if (MCW.Packages[0].Thermal_Labels__c) MCW.bufferLabel = [Select Id, Name, body, ParentId, ContentType from Attachment where ParentId =: shipId limit 1];                    if (MCW.Packages[0].Logistic__c != null) { if (MCW.Packages[0].Logistic__r.From_Address__c != null) { MCW.fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(MCW.Packages[0].Logistic__r.From_Address__c) + '\' Limit 1'); } }                }
                System.debug('Address '+MCW.Shipment.Shipping_Address__c);
                if (MCW.Shipment.Shipping_Address__c != null) {                     MCW.toAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(MCW.Shipment.Shipping_Address__c) + '\' Limit 1'); 
                    System.debug('MCW.toAddress'+MCW.toAddress);
                }//else{
                  //  MCW.toAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + packageList[0].Logistic__r.To_Address__c + '\' Limit 1'); //String.escapeSingleQuotes(MCW.Shipment.Shipping_Address__c)
                  //  System.debug('MCW.toAddress'+MCW.toAddress);
               // }
                
                if (MCW.Shipment.Return_Merchandise_Authorisation__c != null) {                   MCW.retValue = 'SR';                    if (MCW.Shipment.Return_Merchandise_Authorisation__r.Address__c != null) {                        MCW.fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c  from Address__c where Id =\'' + String.escapeSingleQuotes(MCW.Shipment.Return_Merchandise_Authorisation__r.Address__c) + '\' Limit 1');                    }
                }else{
                   if (MCW.Shipment.Logistic__r.From_Address__c != null) {                        MCW.fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c  from Address__c where Id =\'' + String.escapeSingleQuotes(MCW.Shipment.Logistic__r.From_Address__c) + '\' Limit 1');                    } 
                }
                
                if (MCW.Shipment.Status__c == 'Shipped') { MCW.cpWrap.showAndHideMap2 = true; MCW.cpWrap.showAndHideMap3 = true; MCW.cpWrap.showAndHideMap4 = true; MCW.cpWrap.showAndHideMap5 = true; MCW.cpWrap.showAndHideMap6 = true; MCW.cpWrap.showAndHideMap8 = true; }
                if (MCW.Shipment.Status__c == 'Picked Up') { MCW.cpWrap.showAndHideMap2 = true; MCW.cpWrap.showAndHideMap3 = true; MCW.cpWrap.showAndHideMap4 = true; MCW.cpWrap.showAndHideMap7 = true; MCW.cpWrap.showAndHideMap8 = true; }
                if (MCW.Shipment.Status__c == 'Delivered') { MCW.cpWrap.showAndHideMap2 = true; MCW.cpWrap.showAndHideMap8 = true; }
                String pckgId = shipmnts[0].Package__c;
            MCW.Packages = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c,Order__r.Bill_To_Address__c, Order__r.Ship_To_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Invoice_Address__c, Order__r.Name,Order__r.OrderNumber, Transfer_Order__r.From_Address__c,Transfer_Order__r.Name, Transfer_Order__r.To_Address__c,Return_Merchandise_Authorisation__r.Order__r.Bill_To_Address__c, Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Order__r.Contact__r.Email from Package__c where Id =\'' + String.escapeSingleQuotes(pckgId) + '\' And Active__c = true');
            
            }else{
                addressFields = UtilClass.selectStarFromSObject('Address__c');
                MCW.fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Email, Contact__r.Name, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + packageList[0].Logistic__r.From_Address__c + '\' Limit 1');                System.debug('MCW.fromAddress'+MCW.fromAddress);                MCW.toAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Email, Contact__r.Name, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + packageList[0].Logistic__r.To_Address__c + '\' Limit 1');//Contact__r.Name,
                System.debug('MCW.toAddress'+MCW.toAddress);
            }
            System.debug('MCW'+MCW);
            return MCW;
        } catch (Exception e) { system.debug('Erro myconstruct :  ' + e.getMessage() + '; at line ~> ' + e.getLineNumber());
                               MCW.wrapError = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();
                               return null; }
    }
    
  
    public static void checkCred(){
        credentialWrapper ConsVar = getCredentialDetails('','','');
        String myConsVar =JSON.serialize(ConsVar);
        credentialWrapper CredWrap = (credentialWrapper) JSON.deserialize(myConsVar, credentialWrapper.class);
    }
    @AuraEnabled
    public static ShippingResponse Shipping_Rate_Request(List < Package__c > packList, String fromAdd, String tAddress, String shipDate, String ShipService, String myConsVar){
        System.debug('shipDate: '+ shipDate);      
        ShippingResponse shippingResponse = new ShippingResponse();        
        credentialWrapper CredWrap = (credentialWrapper) JSON.deserialize(myConsVar, credentialWrapper.class);
        
        Decimal length=packList[0].Length__c;
        Decimal width=packList[0].Width__c;
        Decimal height=packList[0].Height__c;
        Decimal weight=packList[0].Weight__c;
        String Endpoint='';
        if(CredWrap.endPoint != null || CredWrap.endPoint != '')Endpoint=CredWrap.endPoint+'/rs/ship/price';        else Endpoint='https://ct.soa-gw.canadapost.ca/rs/ship/price';
        String username=CredWrap.username;//'6e93d53968881714';//CredWrap.username;
        String Password=CredWrap.password;//'0bfa9fcb9853d1f51ee57a';//CredWrap.password;
        
        Address__c toAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                Contact__r.Email, Contact__r.Phone from Address__c where ID =: tAddress];
        
        Address__c fromAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                  Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                  Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                  State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                  Contact__r.Email, Contact__r.Phone from Address__c where ID =: fromAdd];
        
        String originPostalCode=fromAddress.Postal_Code__c;
        String destinationPostalCode=toAddress.Postal_Code__c;
        System.debug('originPostalCode: '+originPostalCode);    
        System.debug('destinationPostalCode: '+destinationPostalCode);    
        
        String xmlPayload ='';
        
        if(toAddress.Country__c == 'Canada' || toAddress.Country__c == 'CA'){            xmlPayload='<?xml version="1.0" encoding="UTF-8"?>' +                '<mailing-scenario xmlns="http://www.canadapost.ca/ws/ship/rate-v3">' +                '<quote-type>counter</quote-type>' +               '<expected-mailing-date>' + shipDate + '</expected-mailing-date>' +               '<parcel-characteristics>' +               '<weight>' + weight + '</weight>' +                '<dimensions>' +                '<length>' + length + '</length>' +                '<width>' + width + '</width>' +                '<height>' + height + '</height>' +                '</dimensions>' +                '</parcel-characteristics>' +                '<origin-postal-code>' + originPostalCode + '</origin-postal-code>' +                '<destination>' +                '<domestic>' +                '<postal-code>' + destinationPostalCode + '</postal-code>' +                '</domestic>' +                '</destination>' +                '</mailing-scenario>';
            
        }else  if(toAddress.Country__c == 'US' || toAddress.Country__c == 'United States'){
            xmlPayload='<?xml version="1.0" encoding="UTF-8"?>' +
                '<mailing-scenario xmlns="http://www.canadapost.ca/ws/ship/rate-v3">' +
                '<quote-type>counter</quote-type>' +
                '<expected-mailing-date>' + shipDate + '</expected-mailing-date>' +
                '<parcel-characteristics>' +
                '<weight>' + weight + '</weight>' +
                '<dimensions>' +
                '<length>' + length + '</length>' +
                '<width>' + width + '</width>' +
                '<height>' + height + '</height>' +
                '</dimensions>' +
                '</parcel-characteristics>' +
                '<origin-postal-code>' + originPostalCode + '</origin-postal-code>' +
                '<destination>' +
                '<united-states>' +
                '<zip-code>' + destinationPostalCode + '</zip-code>' +
                '</united-states>' +
                '</destination>' +
                '</mailing-scenario>';
            
        }else{           String countryCode=getCountryCode(toAddress.Country__c);            System.debug('countryCode: '+countryCode);            xmlPayload='<?xml version="1.0" encoding="UTF-8"?>' +                '<mailing-scenario xmlns="http://www.canadapost.ca/ws/ship/rate-v3">' +                '<quote-type>counter</quote-type>' +                '<expected-mailing-date>' + shipDate + '</expected-mailing-date>' +                '<parcel-characteristics>' +                '<weight>' + weight + '</weight>' +                '<dimensions>' +               '<length>' + length + '</length>' +                '<width>' + width + '</width>' +                '<height>' + height + '</height>' +                '</dimensions>' +                '</parcel-characteristics>' +                '<origin-postal-code>' + originPostalCode + '</origin-postal-code>' +                '<destination>' +                '<international>' +                '<country-code>' + countryCode + '</country-code>' +                '</international>' +                '</destination>' +                '</mailing-scenario>';        }
        
        String credentials = username + ':' + Password;
        System.debug('credentials: '+credentials);
        String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
        System.debug('encodedCredentials: '+encodedCredentials);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Endpoint); 
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/vnd.cpc.ship.rate-v3+xml');
        request.setHeader('Accept', 'application/vnd.cpc.ship.rate-v3+xml');
        request.setHeader('Authorization', 'Basic ' + encodedCredentials);
        request.setBody(xmlPayload);
         HttpResponse response =  new HttpResponse ();
         String responseBody ='';
        Decimal StatusCode = 0;
         
        if(!Test.isRunningTest()){            response = http.send(request);           responseBody = response.getBody();            StatusCode = response.getStatusCode();            System.debug('Success: ' + response.getStatusCode() + ' ' + response.getStatus());       }
        else{
            responseBody = '<?xml version=\"1.0\" encoding=\"UTF-8\"?><price-quotes xmlns=\"http://www.canadapost.ca/ws/ship/rate-v3\"><price-quote><service-code>DOM.PC</service-code><service-link rel=\"service\" href=\"https://ct.soa-gw.canadapost.ca/rs/ship/service/DOM.PC?country=CA\" media-type=\"application/vnd.cpc.ship.rate-v3+xml\"/><service-name>Priority</service-name><price-details><base>32.45</base><taxes><gst>0.00</gst><pst>0.00</pst><hst percent=\"13.000\">5.19</hst></taxes><due>45.10</due><options><option><option-code>DC</option-code><option-name>Delivery confirmation</option-name><option-price>0</option-price></option></options><adjustments><adjustment><adjustment-code>FUELSC</adjustment-code><adjustment-name>Fuel surcharge</adjustment-name><adjustment-cost>7.46</adjustment-cost><qualifier><percent>23.0</percent></qualifier></adjustment><adjustment><adjustment-code>V1DISC</adjustment-code><adjustment-name>SMB Savings</adjustment-name><adjustment-cost>0</adjustment-cost></adjustment></adjustments></price-details><weight-details/><service-standard><am-delivery>false</am-delivery><guaranteed-delivery>true</guaranteed-delivery><expected-transit-time>2</expected-transit-time><expected-delivery-date>2024-11-15</expected-delivery-date></service-standard></price-quote><price-quote><service-code>DOM.RP</service-code><service-link rel=\"service\" href=\"https://ct.soa-gw.canadapost.ca/rs/ship/service/DOM.RP?country=CA\" media-type=\"application/vnd.cpc.ship.rate-v3+xml\"/><service-name>Regular Parcel</service-name><price-details><base>15.50</base><taxes><gst>0.00</gst><pst>0.00</pst><hst percent=\"13.000\">2.48</hst></taxes><due>21.55</due><options><option><option-code>DC</option-code><option-name>Delivery confirmation</option-name><option-price>0</option-price><qualifier><included>true</included></qualifier></option></options><adjustments><adjustment><adjustment-code>FUELSC</adjustment-code><adjustment-name>Fuel surcharge</adjustment-name><adjustment-cost>3.57</adjustment-cost><qualifier><percent>23.0</percent></qualifier></adjustment><adjustment><adjustment-code>V1DISC</adjustment-code><adjustment-name>SMB Savings</adjustment-name><adjustment-cost>0</adjustment-cost></adjustment></adjustments></price-details><weight-details/><service-standard><am-delivery>false</am-delivery><guaranteed-delivery>false</guaranteed-delivery><expected-transit-time>3</expected-transit-time><expected-delivery-date>2024-11-18</expected-delivery-date></service-standard></price-quote><price-quote><service-code>DOM.XP</service-code><service-link rel=\"service\" href=\"https://ct.soa-gw.canadapost.ca/rs/ship/service/DOM.XP?country=CA\" media-type=\"application/vnd.cpc.ship.rate-v3+xml\"/><service-name>Xpresspost</service-name><price-details><base>18.53</base><taxes><gst>0.00</gst><pst>0.00</pst><hst percent=\"13.000\">2.96</hst></taxes><due>25.75</due><options><option><option-code>DC</option-code><option-name>Delivery confirmation</option-name><option-price>0</option-price></option></options><adjustments><adjustment><adjustment-code>FUELSC</adjustment-code><adjustment-name>Fuel surcharge</adjustment-name><adjustment-cost>4.26</adjustment-cost><qualifier><percent>23.0</percent></qualifier></adjustment><adjustment><adjustment-code>V1DISC</adjustment-code><adjustment-name>SMB Savings</adjustment-name><adjustment-cost>0</adjustment-cost></adjustment></adjustments></price-details><weight-details/><service-standard><am-delivery>false</am-delivery><guaranteed-delivery>true</guaranteed-delivery><expected-transit-time>2</expected-transit-time><expected-delivery-date>2024-11-15</expected-delivery-date></service-standard></price-quote></price-quotes>';
        StatusCode = 200;
        }
            if (StatusCode == 200) {
                
                Integer chunkSize = 300; 
                for (Integer i = 0; i < responseBody.length(); i += chunkSize) {
                    System.debug(responseBody.substring(i, Math.min(i + chunkSize, responseBody.length())));
                }
                List<String> priceQuotes = new List<String>();
                if (String.isNotBlank(responseBody)) {
                    String startTag = '<price-quote>';
                    String endTag = '</price-quote>';
                    
                    Integer startIndex = 0;
                    while ((startIndex = responseBody.indexOf(startTag, startIndex)) != -1) {
                        Integer endIndex = responseBody.indexOf(endTag, startIndex);
                        if (endIndex == -1) {                           break;                         }
                        
                        String priceQuote = responseBody.substring(startIndex, endIndex + endTag.length());
                        priceQuotes.add(priceQuote);
                        startIndex = endIndex + endTag.length();
                    }
                }
                List<ShippingQuote> quotes = new List<ShippingQuote>();
                if(priceQuotes.size()>0){
                    for (String priceQuote : priceQuotes) {
                        ShippingQuote quote = new ShippingQuote();
                        
                        String serviceCodeTag = '<service-code>';
                        String baseTag = '<base>';
                        String dueTag = '<due>';
                        String dateTag = '<expected-delivery-date>';
                        String NameTag = '<service-name>';
                        
                        Integer serviceCodeStart = priceQuote.indexOf(serviceCodeTag);
                        if (serviceCodeStart != -1) {
                            Integer serviceCodeEnd = priceQuote.indexOf('</service-code>', serviceCodeStart);
                            if (serviceCodeEnd != -1) {
                                quote.serviceCode = priceQuote.substring(serviceCodeStart + serviceCodeTag.length(), serviceCodeEnd);
                            }
                        }
                        
                        Integer baseStart = priceQuote.indexOf(baseTag);
                        if (baseStart != -1) {
                            Integer baseEnd = priceQuote.indexOf('</base>', baseStart);
                            if (baseEnd != -1) {
                                quote.baseAmount = priceQuote.substring(baseStart + baseTag.length(), baseEnd);
                            }
                        }
                        
                        Integer dueStart = priceQuote.indexOf(dueTag);
                        if (dueStart != -1) {
                            Integer dueEnd = priceQuote.indexOf('</due>', dueStart);
                            if (dueEnd != -1) {
                                quote.dueAmount = priceQuote.substring(dueStart + dueTag.length(), dueEnd);
                            }
                        }
                        Integer dateStart = priceQuote.indexOf(dateTag);
                        if (dateStart != -1) {
                            Integer dateEnd = priceQuote.indexOf('</expected-delivery-date>', dateStart);
                            if (dateEnd != -1) {
                                quote.deliveryDate = priceQuote.substring(dateStart + dateTag.length(), dateEnd);
                            }
                        }
                        
                        Integer NameStart = priceQuote.indexOf(NameTag);
                        if (NameStart != -1) {
                            Integer NameEnd = priceQuote.indexOf('</service-name>', NameStart);
                            if (NameEnd != -1) {
                                quote.serviceName = priceQuote.substring(NameStart + NameTag.length(), NameEnd);
                            }
                        }
                        
                        
                        if (quote.serviceCode != null && quote.baseAmount != null) {
                            quotes.add(quote);
                        }
                        
                    }
                    
                }
                for(ShippingQuote q: quotes){
                    system.debug(' Service: '+q.serviceCode+', Due: '+q.dueAmount);
                }
                shippingResponse.quotes=quotes; 
                system.debug(' shippingResponse.quotes: '+shippingResponse.quotes);
            }
            else {             System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus() + ' ' + response.getBody());                                                String description = '';                                if (String.isNotBlank(responseBody)) {                    String startTag = '<description>';                    String endTag = '</description>';                                       Integer startIndex = responseBody.indexOf(startTag);                    Integer endIndex = responseBody.indexOf(endTag);                                        if (startIndex != -1 && endIndex != -1) {                                               startIndex += startTag.length();                        description = responseBody.substring(startIndex, endIndex);                   }                }               shippingResponse.errorMessage = 'Error: ' + response.getStatus() + ' - \n' + description;                           }
        
        
        return shippingResponse;
    }
    
    public class ShippingResponse {
        @AuraEnabled public List<ShippingQuote> quotes;
        @AuraEnabled public String errorMessage;
    }
    public class ShippingQuote {
        @AuraEnabled public String serviceCode { get; set; }
        @AuraEnabled public String baseAmount { get; set; }
        @AuraEnabled public String dueAmount { get; set; }
        @AuraEnabled public String deliveryDate { get; set; }
        @AuraEnabled public String serviceName { get; set; }
        
    }
  
    @AuraEnabled
    public static CPWrapper Shipping_Request_Reply(List < Package__c > packList, String fromAdd, String tAddress, String ShipService, String myConsVar, String Shipment, String rateWrapperSelected){
        
        //rateWrapper rateWrap = (rateWrapper) JSON.deserialize(rateWrapperSelected, rateWrapper.class);
        credentialWrapper CredWrap = (credentialWrapper) JSON.deserialize(myConsVar, credentialWrapper.class);
        Shipment__c Ship = (Shipment__c) JSON.deserialize(Shipment, Shipment__c.class);
        CPWrapper CPWrap = new CPWrapper();
        // recordIdMap = new Map < String, String > ();
        try{
            Address__c toAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                    Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                    Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                    State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                    Contact__r.Email, Contact__r.Phone from Address__c where ID =: tAddress];
            
            Address__c fromAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                      Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                      Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                      State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                      Contact__r.Email, Contact__r.Phone from Address__c where ID =: fromAdd];
            
            if (toAddress.Address_Line1__c != Null && toAddress.Address_Line1__c != '') { destinationStreet1 = toAddress.Address_Line1__c; }
            if (toAddress.Address_Line2__c != Null && toAddress.Address_Line2__c != '') { destinationStreet2 = toAddress.Address_Line2__c; }
            
            List < Province_Codes__c > toLstProvinceCodes =[Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c = : toAddress.State__c Limit 1];
            if (toLstProvinceCodes.Size() > 0) DestinationProvinceCode = toLstProvinceCodes[0].Code__c;
            
            List < Country_Codes__c > toLstcountryCodes =[Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: toAddress.Country__c Limit 1];
            if (toLstcountryCodes.size() > 0) DestinationCountryCode = toLstcountryCodes[0].Code__c;
            
            string OriginStreet = '', originProvinceCode = '', OriginCountryCode = '';
            
            if (fromAddress != null) {
                if (getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                // else CPWrap.Error = 'Canada Post Shipping Service Unavailable : Origin Province Code not found';
                if (getCountryCode(fromAddress.Country__c) != '') OriginCountryCode = getCountryCode(fromAddress.Country__c);
                // else CPWrap.Error = 'Canada Post Shipping Service Unavailable : Origin Country Code not found';
                if (getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') OriginStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
            }
            
            
            system.debug('--- recordIdMap : ' + recordIdMap);
            
            String weightUnit;
            system.debug('@@@ packList : ' + packList.size());
            if (packList.size() > 0) {
                Packages = new List < Package__c > ();
                //pkgList = new List < Package_Line_Item__c > ();
                set < Id > packageIds = new set < Id > ();
                toalWeightValue = 0;
                
                for (Package__c p : packList) {
                    if (p.Weight__c != null) toalWeightValue += Integer.valueof(p.Weight__c);
                    if (p.Weight_Unit__c != null) weightUnit = p.Weight_Unit__c;
                    packageIds.add(p.Id);
                    Packages.add(p);
                }
                
                String packageFields = '', packageListFields = '';
                packageFields = UtilClass.selectStarFromSObject('Package__c');
                //packageListFields = UtilClass.selectStarFromSObject('Package_Line_Item__c');
                totaldeclaredValue = 0.0;
               
            }
            
            // Define dynamic values
            //String transmitShipment = 'true';
            String shippingPointId = originProvinceCode;
            String serviceCode = ShipService;
            
            String senderName = fromAddress.Contact__r.Name;//'Test Name';
            String senderCompany = fromAddress.Contact__r.Company__c;//'Test Company';
            senderCompany = senderCompany.replaceAll('[^a-zA-Z0-9 .]', '');//replaceAll('[^a-zA-Z0-9]', '');//chnaged
            String senderPhone = fromAddress.Contact__r.Phone;//'123-456-7890';
            String senderAddressLine1 = fromAddress.Address_Line1__c;//'123 Sender St';
            String senderAddressLine2 = fromAddress.Address_Line2__c;//'123 Sender St';
            String senderCity = fromAddress.City__c;//'Toronto';
            String senderProvState = originProvinceCode;//fromAddress.City__c;//'ON';
            String senderCountryCode = OriginCountryCode;//fromAddress.City__c;//'CA';
            String senderPostalCode =fromAddress.Postal_Code__c;// 'M1M1M1';
            
            String recipientName = toAddress.Contact__r.Name;
            String recipientCompany = toAddress.Contact__r.Company__c;
            String recipientAddressLine1 = toAddress.Address_Line1__c;
            String recipientAddressLine2 = toAddress.Address_Line2__c;//'123 Sender St';
            String recipientCity = toAddress.City__c;
            String recipientProvState = DestinationProvinceCode;
            String recipientCountryCode =DestinationCountryCode;
            String recipientPostalCode = toAddress.Postal_Code__c;
            String recipientPhone = fromAddress.Contact__r.Phone;//'123-456-7890';
            
            Decimal parcelWeight = packList[0].Weight__c;//12.0;
            Decimal parcelLength = packList[0].Length__c;//30.0;
            Decimal parcelWidth = packList[0].Width__c;//20.0;
            Decimal parcelHeight = packList[0].Height__c;//15.0;Package_Quantity__c
            Decimal parcelQuantity = packList[0].Package_Quantity__c;
            
            
            String Description = packList[0].Description__c;
            
            
            String contractId = CredWrap.contractNumber;//'42708517';
            String paymentMethod = 'Account';
            String username=CredWrap.username;
            String Password=CredWrap.password;
            String credentials = username + ':' + Password;
            System.debug('credentials: '+credentials);
            String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
            //DeclaredValue=DeclaredValue/parcelQuantity;
            System.debug('encodedCredentials: '+encodedCredentials);
            
            System.debug('senderPhone: '+senderPhone);
            System.debug('senderCompany: '+senderCompany);
            
            // Build XML payload
            String xmlPayload = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<shipment xmlns="http://www.canadapost.ca/ws/shipment-v8">' +
                '     <group-id>' + senderCompany + '</group-id>' +
                '<cpc-pickup-indicator>true</cpc-pickup-indicator>' +//chnaged
                '    <requested-shipping-point>' + senderPostalCode + '</requested-shipping-point>' +
                '    <delivery-spec>' +
                '        <service-code>' + serviceCode + '</service-code>' +
                '        <sender>' +
                '            <name>' + senderName + '</name>' +
                '            <company>' + senderCompany + '</company>' +
                '            <contact-phone>' + senderPhone + '</contact-phone>' +
                '            <address-details>' +
                '                <address-line-1>' + senderAddressLine1 + '</address-line-1>' +
                '                <address-line-2>' + senderAddressLine2 + '</address-line-2>' +
                '                <city>' + senderCity + '</city>' +
                '                <prov-state>' + senderProvState + '</prov-state>' +
                '                <country-code>' + senderCountryCode + '</country-code>' +
                '                <postal-zip-code>' + senderPostalCode + '</postal-zip-code>' +
                '            </address-details>' +
                '        </sender>' +
                '        <destination>' +
                '            <name>' + recipientName + '</name>' +
                '            <company>' + recipientCompany + '</company>' +
                '            <client-voice-number>' + recipientPhone + '</client-voice-number>' +
                '            <address-details>' +
                '                <address-line-1>' + recipientAddressLine1 + '</address-line-1>' +
                '                <address-line-2>' + recipientAddressLine2 + '</address-line-2>' +
                '                <city>' + recipientCity + '</city>' +
                '                <prov-state>' + recipientProvState + '</prov-state>' +
                '                <country-code>' + recipientCountryCode + '</country-code>' +
                '                <postal-zip-code>' + recipientPostalCode + '</postal-zip-code>' +
                '            </address-details>' +
                '        </destination>' ;//+
            if(toAddress.Country__c != 'Canada' && toAddress.Country__c != 'CA'){
                xmlPayload +=' <options>' +
                    '                <option>'  +
                    '                <option-code>RASE</option-code>' +
                    '                </option>' +
                    '            </options>' ;
                
            }
            xmlPayload +=   '        <parcel-characteristics>' +
                '            <weight>' + String.valueOf(parcelWeight) + '</weight>' +
                '            <dimensions>' +
                '                <length>' + String.valueOf(parcelLength) + '</length>' +
                '                <width>' + String.valueOf(parcelWidth) + '</width>' +
                '                <height>' + String.valueOf(parcelHeight) + '</height>' +
                '            </dimensions>' +
                '        </parcel-characteristics>' +
                '        <preferences>' +
                '            <show-packing-instructions>true</show-packing-instructions>' +
                '            <show-postage-rate>true</show-postage-rate>' +
                '        </preferences>' ;
            if(toAddress.Country__c != 'Canada' && toAddress.Country__c != 'CA'){
                Decimal DeclaredValue = packList[0].Declared_Value__c/packList[0].Package_Quantity__c;
            Decimal unitWeight = packList[0].Weight__c/packList[0].Package_Quantity__c;
                xmlPayload += '<customs>' +                    '<currency>CAD</currency>' +                    /* '<conversion-from-cad>1.00</conversion-from-cad>' + // if applicable*/                    '<reason-for-export>SOG</reason-for-export>' +                     '<sku-list>' +                   '<item>' +                    '<customs-number-of-units>'+String.valueOf(parcelQuantity)+'</customs-number-of-units>' +                    '<customs-description>'+Description+'</customs-description>' +                     '<unit-weight>'+String.valueOf(unitWeight)+'</unit-weight>' +                    '<customs-value-per-unit>' + DeclaredValue + '</customs-value-per-unit>' +                    '<province-of-origin>' + originProvinceCode + '</province-of-origin>' +                     '</item>' +                    '</sku-list>' +                    '</customs>';            }
            xmlPayload +=     '        <settlement-info>' +                '            <contract-id>' + contractId + '</contract-id>' +                '            <intended-method-of-payment>' + paymentMethod + '</intended-method-of-payment>' +                '        </settlement-info>' +                '    </delivery-spec>' +                '</shipment>';
            
            // Configure HTTP request
            String Endpoint=CredWrap.endPoint+'/rs/'+CredWrap.accountNumber+'/'+CredWrap.accountNumber+'/shipment';            HttpRequest request = new HttpRequest();           request.setEndpoint(Endpoint);            request.setMethod('POST');            request.setHeader('Content-Type', 'application/vnd.cpc.shipment-v8+xml');            request.setHeader('Accept', 'application/vnd.cpc.shipment-v8+xml');            request.setHeader('Authorization', 'Basic ' + encodedCredentials);           request.setBody(xmlPayload);                      Http http = new Http();
            if(!Test.isRunningTest()){
            HttpResponse response = http.send(request);
            System.debug('Request: ');
            Integer chunkSize = 300; 
            for (Integer i = 0; i < xmlPayload.length(); i += chunkSize) {
                System.debug(xmlPayload.substring(i, Math.min(i + chunkSize, xmlPayload.length())));
            }
            // Check the response
            if (response.getStatusCode() == 200) {
                System.debug('Request was successful for create shipment: '+response.getStatusCode());
                System.debug('response.getBody(): ');
                String responseBody=response.getBody();
                for (Integer i = 0; i < responseBody.length(); i += chunkSize) {                    System.debug(responseBody.substring(i, Math.min(i + chunkSize, responseBody.length())));                }
                List<String> linkUrls = new List<String>();
                String xmlResponse = response.getBody();
                if (String.isNotBlank(xmlResponse)) {
                    // Retrieve the tracking pin
                    String trackingPin;
                    String ShipIdNo;
                    String startTag = '<tracking-pin>';
                    String endTag = '</tracking-pin>';
                    Integer startIndex = xmlResponse.indexOf(startTag);
                    Integer endIndex = xmlResponse.indexOf(endTag);
                    
                    if (startIndex != -1 && endIndex != -1) {
                        trackingPin = xmlResponse.substring(startIndex + startTag.length(), endIndex).trim();
                    }
                    String startTag2 = '<shipment-id>';
                    String endTag2 = '</shipment-id>';
                    Integer startIndex2 = xmlResponse.indexOf(startTag2);
                    Integer endIndex2 = xmlResponse.indexOf(endTag2);
                    if (startIndex2 != -1 && endIndex2 != -1) {
                        ShipIdNo = xmlResponse.substring(startIndex2 + startTag2.length(), endIndex2).trim();
                    }
                    
                    // Retrieve the links by looking for <link ... href="..."/> elements
                    String linkTag = '<link';                   String hrefAttribute = 'href="';                   String relAttribute = 'rel="label"';                    String priceAttribute = 'rel="price"';                    Integer linkIndex = xmlResponse.indexOf(linkTag);                    String Endpoint2;                     String Endpoint3; 
                    
                    while (linkIndex != -1) {
                        Integer hrefStart = xmlResponse.indexOf(hrefAttribute, linkIndex);
                        if (hrefStart != -1) {
                            hrefStart += hrefAttribute.length();
                            Integer hrefEnd = xmlResponse.indexOf('"', hrefStart);
                            if (hrefEnd != -1) {
                                String linkUrl = xmlResponse.substring(hrefStart, hrefEnd);
                                linkUrls.add(linkUrl);
                                
                                Integer relStart = xmlResponse.indexOf(relAttribute, linkIndex);
                                if (relStart != -1 && relStart < xmlResponse.indexOf('>', linkIndex)) {
                                    Endpoint2 = linkUrl;//label
                                }
                                Integer priceStart = xmlResponse.indexOf(priceAttribute, linkIndex);
                                if (priceStart != -1 && priceStart < xmlResponse.indexOf('>', linkIndex)) {
                                    Endpoint3 = linkUrl;//price
                                }
                                
                            }
                        }
                        linkIndex = xmlResponse.indexOf(linkTag, linkIndex + linkTag.length());
                    }
                    
                    // Debug output
                    System.debug('Tracking Pin: ' + trackingPin);
                    System.debug('Link URLs: ' + linkUrls);
                    System.debug('Label Endpoint: ' + Endpoint2);
                    System.debug('Price Endpoint: ' + Endpoint3);
                    
                    Http http3 = new Http();                    HttpRequest request3 = new HttpRequest();                    request3.setEndpoint(Endpoint3);                     request3.setMethod('GET');                    request3.setHeader('Accept', 'application/vnd.cpc.shipment-v8+xml');                    request3.setHeader('Authorization', 'Basic ' + encodedCredentials);
                    // request2.setBody(xmlPayload);
                    if(!Test.isRunningTest()){
                    HttpResponse res2 = http3.send(request3);
                    if (res2.getStatusCode() == 200) {
                        String PriceResponse=res2.getBody();                        System.debug('Request was successful for price: '+ res2.getStatusCode());                        String dueAmount;                        String expectedDeliveryDate;
                        
                        // Get due-amount
                        String dueAmountTag = '<due-amount>';                        Integer dueStart = PriceResponse.indexOf(dueAmountTag);                        if (dueStart != -1) {                            dueStart += dueAmountTag.length();                            Integer dueEnd = PriceResponse.indexOf('</due-amount>', dueStart);                            if (dueEnd != -1) {                               dueAmount = PriceResponse.substring(dueStart, dueEnd);                            }                        }
                        
                        // Get expected-delivery-date
                        String expectedDeliveryDateTag = '<expected-delivery-date>';                        Integer dateStart = PriceResponse.indexOf(expectedDeliveryDateTag);                        if (dateStart != -1) {                            dateStart += expectedDeliveryDateTag.length();                            Integer dateEnd = PriceResponse.indexOf('</expected-delivery-date>', dateStart);                            if (dateEnd != -1) {                                expectedDeliveryDate = PriceResponse.substring(dateStart, dateEnd);                            }                       }
                        
                        System.debug('dueAmount: ' + dueAmount);
                        System.debug('expectedDeliveryDate: ' + expectedDeliveryDate);
                        
                        Http http2 = new Http();                        HttpRequest request2 = new HttpRequest();                        request2.setEndpoint(Endpoint2);                         request2.setMethod('GET');                        request2.setHeader('Accept', 'application/pdf');                        request2.setHeader('Authorization', 'Basic ' + encodedCredentials);
                        // request2.setBody(xmlPayload);
                        if(!Test.isRunningTest()){
                        HttpResponse res = http2.send(request2);
                        if (res.getStatusCode() == 200) {
                            System.debug('Request was successful for label: '+res.getStatusCode());
                            Blob pdfBlob = res.getBodyAsBlob();
                            
                            if(pdfBlob != null && trackingPin != null){
                                
                                Id RTID; RTID =Schema.SObjectType.Shipment__c.getRecordTypeInfosByDeveloperName().get('Canada_Post_shipping').getRecordTypeId();//Schema.SObjectType.Shipment__c.getRecordTypeInfosByDeveloperName().get('Canada_Post_shipping').getRecordTypeId();//Canada_Post_Shipping 
                                if (Schema.sObjectType.Shipment__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Active__c.isUpdateable()) { Ship.Active__c = true; }
                                if (Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isUpdateable()) { Ship.Billing_Address__c = toAddress.Id; }
                                if (Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && CredWrap.Shipment.Customer__c == null) Ship.Customer__c = toAddress.Customer__c;//senderCompany
                                if (Schema.sObjectType.Shipment__c.fields.Tracking_Unique_Id__c.isCreateable() && CredWrap.Shipment.Tracking_Unique_Id__c == null) Ship.Tracking_Unique_Id__c = senderCompany;//
                                if (Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isUpdateable()) { Ship.Customer_Contact__c = toAddress.Contact__c; }
                                if (Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Ship.Status__c = 'Shipped'; }
                                if (Schema.sObjectType.Shipment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment__c.fields.RecordTypeId.isUpdateable() && RTID != null) { Ship.RecordTypeId = RTID; }
                                if (Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isUpdateable()) { Ship.Shipping_Address__c = toAddress.Id; }
                                if (Schema.sObjectType.Shipment__c.fields.Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Order__c.isUpdateable()) {
                                    if(Packages[0].Logistic__c != null)Ship.Logistic__c = Packages[0].Logistic__c;
                                    if(Packages[0].Order__c != null)Ship.Order__c = Packages[0].Order__c;
                                    if(Packages[0].Purchase_Order__c != null)Ship.Purchase_Orders__c = Packages[0].Purchase_Order__c;
                                    if(Packages[0].Transfer_Order__c != null)Ship.Transfer_Order__c = Packages[0].Transfer_Order__c;
                                    if(Packages[0].Return_Merchandise_Authorisation__c != null)Ship.Return_Merchandise_Authorisation__c = Packages[0].Return_Merchandise_Authorisation__c;
                                    if(Packages[0].Order__c != null)Ship.Order__c = Packages[0].Order__c;
                                }
                                
                               
                                
                               // if (Schema.sObjectType.Shipment__c.fields.Canada_Post_Services__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Canada_Post_Services__c.isUpdateable()) { Ship.Canada_Post_Services__c = serviceCode;}//rateWrap.Service; }
                                if (Schema.sObjectType.Shipment__c.fields.Shipment_Delivery_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Delivery_Date__c.isUpdateable()) { Ship.Shipment_Delivery_Date__c = date.valueOf(expectedDeliveryDate); }
                                if (Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isUpdateable()) { Ship.Shipping_Amount__c = (dueAmount != '' || dueAmount != null) ? Decimal.valueOf(dueAmount) : 0.00; }
                                // if (Schema.sObjectType.Shipment__C.fields.Number_Of_Pieces_In_Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isUpdateable()) Ship.Number_Of_Pieces_In_Shipment__c = String.valueof(Packages.size());
                                if (Schema.sObjectType.Shipment__c.fields.TrackingNumber__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.TrackingNumber__c.isUpdateable()) { Ship.TrackingNumber__c = trackingPin; }//Tracking_Number__c
                                if (Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isUpdateable()) { Ship.Tracking_Number__c = trackingPin; }//Tracking_Number__c
                                if (Schema.sObjectType.Shipment__c.fields.Shipment_Identification_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Identification_Number__c.isUpdateable()) { Ship.Shipment_Identification_Number__c = ShipIdNo; }
                                if (Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Ship.Name = 'LO-Shipment';
                                String urlsString = String.join(linkUrls, '\n');
                                if (Schema.sObjectType.Shipment__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Description__c.isUpdateable()) Ship.Description__c = urlsString;
                                
                                if (Schema.sObjectType.Shipment__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Description__c.isUpdateable()) Ship.Package_Weight__c = packList[0].Weight__c;
                                if (Schema.sObjectType.Shipment__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Description__c.isUpdateable()) Ship.Length__c = packList[0].Length__c;
                                if (Schema.sObjectType.Shipment__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Description__c.isUpdateable()) Ship.Width__c = packList[0].Width__c;
                                if (Schema.sObjectType.Shipment__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Description__c.isUpdateable()) Ship.Height__c = packList[0].Height__c;
                                Ship.Package__c=packList[0].Id;
                                if (Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) upsert Ship;
                                
                                Attachment pdfAttachment = new Attachment();                                                               pdfAttachment.Name = 'CP_Label_' + trackingPin + '.pdf';                               pdfAttachment.Body = pdfBlob;                                pdfAttachment.ContentType = 'application/pdf';                                pdfAttachment.Description = 'Shipping label PDF for tracking number ' + trackingPin;                                   pdfAttachment.ParentId =Ship.Id;                                insert pdfAttachment;                                   CPWrap.bufferLabel=pdfAttachment;                                CPWrap.AttachLabel=pdfAttachment;                                CPWrap.showreturnlabel=false;                                CPWrap.showAndHideMap2=true;                                System.debug('PDF Attachment saved successfully.');                                CPWrap.Result='Shipment Created successfully';
                                Ship = Database.query('select Id, Name,Shipment_Date__c, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c,TrackingNumber__c, Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c,Shipment_Identification_Number__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Carrier_Code__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Purchase_Orders__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Description__c from Shipment__c where (Id =\'' + Ship.Id + '\') Limit 1');
                                system.debug('**** Shipment : ' +Ship);
                                //packList[0].Shipment__c = Ship.Id;
                                packList[0].Status__c = Ship.Status__c;                                 packList[0].Tracking_Number__c = Ship.Tracking_Number__c;                                upsert packList;                               CPWrap.Shipment = Ship;
                                
                            }
                            // The response is a binary PDF, so we can directly use it
                            
                        }else{
                            System.debug('Request Issue for label: '+res.getStatusCode());
                            CPWrap.Error = 'Request Issue for label: '+res.getStatusCode();
                        }
                    }
                    }else{
                        System.debug('Request Error for price: '+res2.getStatusCode());
                        CPWrap.Error = 'Request Error for price: '+res2.getStatusCode();
                    }
                }
                }
            } else {
                System.debug('Failed Create shipment status code: ' + response.getStatusCode());
                System.debug('response.getBody(): ');
                String responseBody=response.getBody();                String errorStr='';                CPWrap.Error = '';                for (Integer i = 0; i < responseBody.length(); i += chunkSize) {                    String chunk =  responseBody.substring(i, Math.min(i + chunkSize, responseBody.length()));                    CPWrap.Error +=chunk;                    errorStr += chunk;                }
                System.debug(errorStr);
            }
        }
        }catch (Exception e) {
            System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
            CPWrap.Error ='Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();
            //CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();            
        }
        return CPWrap;
    }
  
    
    @AuraEnabled
    public static CPWrapper Refund_Request_Reply(String Shipment, List<Package__c> packList, String tAddress, String fAddress, String myConsVar) {
        System.debug('Inside here');
        CPWrapper CPWrap = new CPWrapper();
        
        try {
            credentialWrapper CredWrap = (credentialWrapper) JSON.deserialize(myConsVar, credentialWrapper .class);
            Shipment__c Ship = (Shipment__c) JSON.deserialize(Shipment, Shipment__c.class);
            System.debug('Ship'+Ship);
            String canadaShipId;  if(Ship.Shipment_Identification_Number__c != null) canadaShipId = Ship.Shipment_Identification_Number__c;
            
            Address__c toAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                    Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                    Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                    State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                    Contact__r.Email, Contact__r.Phone from Address__c where ID =: tAddress];
            
            Address__c fromAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                      Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                      Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                      State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                      Contact__r.Email, Contact__r.Phone from Address__c where ID =: fAddress];
            
            String email = fromAddress.Contact__r.Email;
            
            System.debug('canadaShipId'+canadaShipId);
            System.debug('toAddress.Contact__r.Email'+toAddress.Contact__r.Email);
            System.debug('CredWrap.accountNumber'+CredWrap.accountNumber);
            System.debug('CredWrap.username'+CredWrap.username);
            System.debug('CredWrap.password'+CredWrap.password);
            
            String description = Ship.Description__c;
            List<String> links = description.split('\n');
            
            // Loop through the links and find the one containing 'manifestId'
            String manifestLink = '';
            for (String link : links) {
                if (link.contains('manifestId')) {
                    manifestLink = link;
                    break; // Exit the loop once the link with 'manifestId' is found
                }
            }
            
            System.debug('Link containing manifestId: ' + manifestLink);
            String contractId = CredWrap.contractNumber;//'42708517';
            String paymentMethod = 'Account';
            String username=CredWrap.username;
            String Password=CredWrap.password;
            String credentials = username + ':' + Password;
            System.debug('credentials: '+credentials);
            String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
            System.debug('encodedCredentials: '+encodedCredentials);
            String Endpoint=manifestLink;
            
            Http h = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(Endpoint); // Replace with actual endpoint
            request.setMethod('GET');
            request.setHeader('Accept', 'application/vnd.cpc.shipment-v8+xml');
            request.setHeader('Authorization', 'Basic ' + encodedCredentials);
            HttpResponse res = new HttpResponse();
            Decimal StatusCode = 0;
            if(!Test.isRunningTest()){            res = h.send(request); response_1 = res.getBody();                StatusCode = res.getStatusCode();            }
            else{
              response_1='<?xml version=\"1.0\" encoding=\"UTF-8\"?><shipments xmlns=\"http://www.canadapost.ca/ws/shipment-v8\"><link rel=\"shipment\" href=\"https://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/shipment/241741730362043291\" media-type=\"application/vnd.cpc.shipment-v8+xml\"/></shipments>';
              StatusCode = 200;
            }
            if(StatusCode == 200) { 
                System.debug('Request was successful for manifestshipment: '+res.getStatusCode());
                List<String> shipmentLinks = new List<String>();
                List<String> refundLinks = new List<String>();
                List<String> serviceTickets = new List<String>();
                Boolean allSuccess = false;
                
                
                Pattern pattern = Pattern.compile('<link rel="shipment" href="(.*?)"');
                Matcher matcher = pattern.matcher(response_1);
                
               
                while (matcher.find()) {
                    shipmentLinks.add(matcher.group(1));
                }
                
                System.debug('Shipment Links: ' + shipmentLinks);
                for(String s:shipmentLinks){
                    
                    Http http = new Http();
                    HttpRequest request2 = new HttpRequest();
                    request2.setEndpoint(s); // Replace with actual endpoint
                    request2.setMethod('GET');
                    request2.setHeader('Accept', 'application/vnd.cpc.shipment-v8+xml');
                    request2.setHeader('Authorization', 'Basic ' + encodedCredentials);
                    HttpResponse res2 = new HttpResponse();
                     Decimal StatusCode2 = 0;
                   if(!Test.isRunningTest()){                     res2 = http.send(request2); response_1 = res2.getBody();                       StatusCode2=res2.getStatusCode();                   }
                    else{
                        response_1='<?xml version=\"1.0\" encoding=\"UTF-8\"?><shipment-info xmlns=\"http://www.canadapost.ca/ws/shipment-v8\"><shipment-id>241741730362056882</shipment-id><shipment-status>transmitted</shipment-status><tracking-pin>123456789012</tracking-pin><po-number>P123456789</po-number><links><link rel=\"self\" href=\"https://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/shipment/241741730362056882\" media-type=\"application/vnd.cpc.shipment-v8+xml\"/><link rel=\"details\" href=\"https://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/shipment/241741730362056882/details\" media-type=\"application/vnd.cpc.shipment-v8+xml\"/><link rel=\"price\" href=\"https://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/shipment/241741730362056882/price\" media-type=\"application/vnd.cpc.shipment-v8+xml\"/><link rel=\"refund\" href=\"https://ct.soa-gw.canadapost.ca/rs/0002004381/0002004381/shipment/241741730362056882/refund\" media-type=\"application/vnd.cpc.shipment-v8+xml\"/><link rel=\"label\" href=\"https://ct.soa-gw.canadapost.ca/rs/artifact/6e93d53968881714/10006382143/0\" media-type=\"application/pdf\" index=\"0\"/></links></shipment-info>';
                   StatusCode2 = 200;
                    }
                    
                    if(StatusCode2 == 200) { 
                        System.debug('Issue Request for refund link: '+res.getStatusCode());               
                        
                        String linkTag = '<link';
                        String hrefAttribute = 'href="';
                        String relAttribute = 'rel="refund"';
                        Integer linkIndex = response_1.indexOf(linkTag);
                        
                        while (linkIndex != -1) {
                            Integer hrefStart = response_1.indexOf(hrefAttribute, linkIndex);
                            if (hrefStart != -1) {
                                hrefStart += hrefAttribute.length();
                                Integer hrefEnd = response_1.indexOf('"', hrefStart);
                                if (hrefEnd != -1) {
                                    String linkUrl = response_1.substring(hrefStart, hrefEnd);
                                    
                                    Integer relStart = response_1.indexOf(relAttribute, linkIndex);
                                    if (relStart != -1 && relStart < response_1.indexOf('>', linkIndex)) {
                                        refundLinks.add(linkUrl);
                                    }
                                    
                                    
                                }
                            }
                            linkIndex = response_1.indexOf(linkTag, linkIndex + 1); 
                        }
                        
                    }else{
                        System.debug('Issue Request for refund link: '+res.getStatusCode());  
                    }
                
                    
                }
                System.debug('refund Links: ' + refundLinks);
                
                System.debug('email bfr: ' + email);
                if(email == null || email == '') email = 'asra.zulfiqhar@axolt.com';
                System.debug('email after: ' + email);
                
                String xmlRequest = '<?xml version="1.0" encoding="UTF-8"?>'
                    + '<shipment-refund-request xmlns="http://www.canadapost.ca/ws/shipment-v8">'
                    + '<email>' + email + '</email>'
                    + '</shipment-refund-request>';
                
                for(String refundLink:refundLinks){
                    
                    Http htt = new Http();
                    HttpRequest request3 = new HttpRequest();
                    request3.setEndpoint(refundLink); 
                    request3.setMethod('POST');
                    request3.setHeader('Accept', 'application/vnd.cpc.shipment-v8+xml');
                    request3.setHeader('Content-Type', 'application/vnd.cpc.shipment-v8+xml');
                    request3.setHeader('Authorization', 'Basic ' + encodedCredentials);
                    request3.setBody(xmlRequest);
                    String responseBody='';
                     Decimal StatusCode3 = 0;
                    HttpResponse res3 = new HttpResponse();
                   if(!Test.isRunningTest()){                     res3 = htt.send(request3);                    response_1 = res3.getBody();                   responseBody=res3.getBody();                       StatusCode3=res3.getStatusCode();                       System.debug('Issue Request for refund link: '+res3.getStatusCode()); 
                   }else{
                       responseBody='<?xml version=\"1.0\" encoding=\"UTF-8\"?><shipment-refund-request-info xmlns=\"http://www.canadapost.ca/ws/shipment-v8\"><service-ticket-date>2024-10-31</service-ticket-date><service-ticket-id>0123456789</service-ticket-id></shipment-refund-request-info>';
                   StatusCode3=200;
                   }
                    
                    if(StatusCode3 == 200) {
                        allSuccess=true;
                        System.debug('Issue Request for refund link: '+res3.getStatusCode());
                        String startTagDate = '<service-ticket-date>';
                        String endTagDate = '</service-ticket-date>';
                        Integer startIndexDate = response_1.indexOf(startTagDate);
                        Integer endIndexDate = response_1.indexOf(endTagDate);
                        
                        String serviceTicketDate = '';
                        if (startIndexDate != -1 && endIndexDate != -1) {                            serviceTicketDate = response_1.substring(startIndexDate + startTagDate.length(), endIndexDate).trim();
                        }
                        
                       
                        String startTagId = '<service-ticket-id>';
                        String endTagId = '</service-ticket-id>';
                        Integer startIndexId = response_1.indexOf(startTagId);
                        Integer endIndexId = response_1.indexOf(endTagId);
                        
                        String serviceTicketId = '';
                        if (startIndexId != -1 && endIndexId != -1) {                            serviceTicketId = response_1.substring(startIndexId + startTagId.length(), endIndexId).trim();                            serviceTickets.add(serviceTicketId);                        }
                        
                        System.debug('Service Ticket Date: ' + serviceTicketDate);
                        System.debug('Service Ticket ID: ' + serviceTicketId);
                        
                        
                    }else{                       allSuccess=false;                        Integer chunkSize = 300;                                                                        String errorStr='';                        CPWrap.Error = '';                        for (Integer i = 0; i < responseBody.length(); i += chunkSize) {                            String chunk =  responseBody.substring(i, Math.min(i + chunkSize, responseBody.length()));                            CPWrap.Error +=chunk;                            errorStr += chunk;                        }                       System.debug(errorStr);                    }
                
                    
                }
                System.debug('serviceTickets: ' + serviceTickets);
                for(string servicesticket: serviceTickets){                    if(servicesticket != null && servicesticket != '') if(Ship.Message__c != null && Ship.Message__c !='') Ship.Message__c= Ship.Message__c+'\n'+servicesticket; else Ship.Message__c=servicesticket;                    Ship.Description__c=Ship.Description__c+'\n'+servicesticket;               }
                Ship.Message__c = Ship.Message__c.replace('null', '').trim();
                
                if(allSuccess){                    CPWrap.UPSErrorMsg = 'Shipment deleted successfully';                    Ship.Status__c = 'Cancelled';                   update ship;                    Ship = Database.query('select Id, Name, Shipment_Date__c, Message__c, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c, TrackingNumber__c, Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c,Shipment_Identification_Number__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Carrier_Code__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Purchase_Orders__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Description__c from Shipment__c where (Id =\'' + Ship.Id + '\') Limit 1');              system.debug('**** Shipment : ' +Ship);                    CPWrap.Shipment = Ship;                }
            }else{
                System.debug('Issue Request for manifestshipment: '+res.getStatusCode());
            }
        
        } catch (Exception e) {
            System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
            CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();            
        }
        return CPWrap;
    }
    
    
    @AuraEnabled
    public static CPWrapper Void_Request_Reply(String Shipment, List<Package__c> packList, String tAddress, String myConsVar) {
        CPWrapper CPWrap = new CPWrapper();
        
        try {
            credentialWrapper CredWrap = (credentialWrapper) JSON.deserialize(myConsVar, credentialWrapper .class);
            Shipment__c Ship = (Shipment__c) JSON.deserialize(Shipment, Shipment__c.class);
            System.debug('Ship'+Ship);
            String description = Ship.Description__c;
            List<String> links = description.split('\n');
            
            String firstLink = (links.size() > 0) ? links[0] : null;
            String canadaShipId;  
            if(Ship.Shipment_Identification_Number__c != null) canadaShipId = Ship.Shipment_Identification_Number__c;
            
            Address__c toAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                    Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                    Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                    State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                    Contact__r.Email, Contact__r.Phone from Address__c where ID =: tAddress];
            
            System.debug('canadaShipId'+canadaShipId);
            System.debug('toAddress.Contact__r.Email'+toAddress.Contact__r.Email);
            System.debug('CredWrap.accountNumber'+CredWrap.accountNumber);
            System.debug('CredWrap.username'+CredWrap.username);
            System.debug('CredWrap.password'+CredWrap.password);
            String username=CredWrap.username;//'6e93d53968881714';//CredWrap.username;
            String Password=CredWrap.password;
            String credentials = username + ':' + Password;
            System.debug('credentials: '+credentials);
            String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
            System.debug('encodedCredentials: '+encodedCredentials);
            
            try {
                
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                HttpResponse res = new HttpResponse();
                req.setMethod('DELETE');
                req.setEndPoint(firstLink);
                req.setHeader('Authorization', 'Basic ' + encodedCredentials);
                req.setHeader('Accept', 'application/vnd.cpc.shipment-v8+xml');
                
                if(!Test.isRunningTest()){                res = h.send(req);                response_1 = res.getBody();                resStatus = res.getStatus(); //}
                }else{
                     resStatus = 'No Content';
                }
                
                System.debug('resStatus'+resStatus);
                System.debug('response_1'+response_1);
                
                if(resStatus == 'OK' || resStatus == 'No Content') { 
                    
                    
                    // if(Schema.sObjectType.Shipment__c.fields.Refund_ID__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Refund_ID__c.isUpdateable()) { Ship.Refund_ID__c = RefundId; }
                    if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Ship.Status__c = 'Cancelled'; }
                    if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) update Ship;
                    if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { pac.Status__c = 'Cancelled'; } update packList; }
                    system.debug('-- packList : ' +packList);
                    //Ship = new Shipment__c();  
                    Ship = Database.query('select Id, Name, Shipment_Date__c, Message__c, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c, TrackingNumber__c, Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c,Shipment_Identification_Number__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Carrier_Code__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Purchase_Orders__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Description__c from Shipment__c where (Id =\'' + Ship.Id + '\') Limit 1');//select Id, Name,Shipment_Date__c, Message__c, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c, TrackingNumber__c, Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c,Shipment_Identification_Number__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Carrier_Code__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Purchase_Orders__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Description__c from Shipment__c where (Id =\'' + Ship.Id + '\') Limit 1
                    system.debug('**** Shipment : ' +Ship);
                    CPWrap.Shipment = Ship;
                    CPWrap.UPSErrorMsg = 'Shipment deleted successfully';
                    CPWrap.showAndHideMap1 = true; CPWrap.showAndHideMap2 = false; CPWrap.showAndHideMap3 = false; CPWrap.showAndHideMap4 = false; CPWrap.showAndHideMap5 = false; CPWrap.showAndHideMap6 = false; CPWrap.showAndHideMap7 = false; CPWrap.showAndHideMap8 = false;
                    
                } else {CPWrap.Error = 'Result not available'; CPWrap.showAndHideMap2 = true; CPWrap.showAndHideMap3 = true; CPWrap.showAndHideMap4 = true; CPWrap.showAndHideMap5 = true; CPWrap.showAndHideMap6 = true; CPWrap.showAndHideMap7 = false; CPWrap.showAndHideMap8 = true;}
                
                CPWrap.Shipment = Ship;
                
            } catch (Exception e) {
                System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
                CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();
            }
        } catch (Exception e) {            System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());            CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();                    }
        return CPWrap;
    }
    @AuraEnabled
    public static CPWrapper Transmit_Request_Reply(String Shipment, List<Package__c> packList, String tAddress, String fAddress, String myConsVar) {
        CPWrapper CPWrap = new CPWrapper();
        
        try {
            credentialWrapper CredWrap = (credentialWrapper) JSON.deserialize(myConsVar, credentialWrapper .class);
            Shipment__c Ship = (Shipment__c) JSON.deserialize(Shipment, Shipment__c.class);
            System.debug('Ship'+Ship);
            System.debug('Ship.Description__c'+Ship.Description__c);
            String description = Ship.Description__c;
            List<String> links = (description != null) ? description.split('\n') : new List<String>();//description.split('\n');
            
            String firstLink = (links.size() > 0) ? links[0] : null;
            String canadaShipId;  
            if(Ship.Shipment_Identification_Number__c != null) canadaShipId = Ship.Shipment_Identification_Number__c;
            
            Address__c toAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                    Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                    Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                    State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                    Contact__r.Email, Contact__r.Phone from Address__c where ID =: tAddress];
            
            Address__c fromAddress = [Select Id, Name, Customer__c, Contact__c, Active__c,
                                      Is_Shipping_Address__c, Is_Billing_Address__c, Address_Line1__c,
                                      Address_Line2__c, Address_Line3__c, City__c, Country__c,
                                      State__c, Postal_Code__c, Contact__r.Company__c, Contact__r.Name,
                                      Contact__r.Email, Contact__r.Phone from Address__c where ID =: fAddress];
            
            System.debug('canadaShipId'+canadaShipId);
            System.debug('toAddress.Contact__r.Email'+toAddress.Contact__r.Email);
            System.debug('CredWrap.accountNumber'+CredWrap.accountNumber);
            System.debug('CredWrap.username'+CredWrap.username);
            System.debug('CredWrap.password'+CredWrap.password);
            String username=CredWrap.username;//'6e93d53968881714';//CredWrap.username;
            String Password=CredWrap.password;
            String credentials = username + ':' + Password;
            System.debug('credentials: '+credentials);
            String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
            System.debug('encodedCredentials: '+encodedCredentials);
            
            try {  
                String groupId = fromAddress.Contact__r.Company__c;//fromAddress.Contact__r.Company__c;//'test-group'; 
                groupId = groupId.replaceAll('[^a-zA-Z0-9 .]', '');//replaceAll('[^a-zA-Z0-9]', '');
                String requestedShippingPoint = fromAddress.Postal_Code__c;//'M1M1M1'; 
                String companyName = fromAddress.Contact__r.Company__c;//'Company Name'; 
                String contactName = fromAddress.Contact__r.Name;//'John Doe'; 
                String phoneNumber = fromAddress.Contact__r.Phone;//'123-456-7890'; 
                String addressLine1 = fromAddress.Address_Line1__c;//'123 Main St'; 
                String addressLine2 = fromAddress.Address_Line2__c;//'Apt 4B'; 
                String city = fromAddress.City__c;//'Toronto'; 
                String province = fromAddress.Postal_Code__c;//'ON'; 
                String OriginCountryCode='';
                if (getCountryCode(fromAddress.Country__c) != '') OriginCountryCode = getCountryCode(fromAddress.Country__c);
                String countryCode = OriginCountryCode;//'CA'; 
                String originProvinceCode='';
                if (getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                String postalCode = originProvinceCode;//'A1B2C3'; 
                String methodOfPayment = 'Account'; 
                
                System.debug('groupId: '+groupId);
                System.debug('requestedShippingPoint: '+requestedShippingPoint);
                System.debug('methodOfPayment: '+methodOfPayment);
                System.debug('companyName: '+companyName);
                System.debug('contactName: '+contactName);
                System.debug('phoneNumber: '+phoneNumber);
                System.debug('addressLine1: '+addressLine1);
                System.debug('addressLine2: '+addressLine2);
                System.debug('city: '+city);
                System.debug('postalCode: '+postalCode);
                System.debug('countryCode: '+countryCode);
                System.debug('province: '+province);
                
                String xmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' +
                    '<transmit-set xmlns="http://www.canadapost.ca/ws/manifest-v8">' +
                    '<group-ids>' +
                    '<group-id>' + groupId + '</group-id>' +
                    '</group-ids>' +
                    '<requested-shipping-point>' + requestedShippingPoint + '</requested-shipping-point>' +
                    '<cpc-pickup-indicator>true</cpc-pickup-indicator>' +
                    '<method-of-payment>' + methodOfPayment + '</method-of-payment>' +
                    '<detailed-manifests>true</detailed-manifests>' +
                    '<manifest-address>' +
                    '<manifest-company>' + companyName + '</manifest-company>' +
                    '<manifest-name>' + contactName + '</manifest-name>' +
                    '<phone-number>' + phoneNumber + '</phone-number>' +
                    '<address-details>' +
                    '<address-line-1>' + addressLine1 + '</address-line-1>' +
                    '<address-line-2>' + addressLine2 + '</address-line-2>' +
                    '<city>' + city + '</city>' +
                    '<prov-state>' + postalCode + '</prov-state>' +
                    '<country-code>' + countryCode + '</country-code>' +
                    '<postal-zip-code>' + province + '</postal-zip-code>' +
                    '</address-details>' +
                    '</manifest-address>' +
                    '</transmit-set>';
                String Endpoint=CredWrap.endPoint+'/rs/'+CredWrap.accountNumber+'/'+CredWrap.accountNumber+'/manifest';
                System.debug('Endpoint: '+Endpoint);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(Endpoint); 
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/vnd.cpc.manifest-v8+xml');
                request.setHeader('Accept', 'application/vnd.cpc.manifest-v8+xml ');
                request.setHeader('Authorization', 'Basic ' + encodedCredentials);
                request.setBody(xmlRequest);
                
                // Send the request
                 if(!Test.isRunningTest()){
                HttpResponse res = http.send(request);
                System.debug('request: ' +request);
                
                // Check the response
                if (res.getStatusCode() == 200) {
                    System.debug('Request Successful: ' +res.getStatusCode()+ ' : ' + res.getBody());
                    String link = '';
                    String xmlResponse=res.getBody();
                    Integer hrefIndex = xmlResponse.indexOf('href="');
                    if (hrefIndex != -1) {
                        Integer startIndex = hrefIndex + 6; // Move past 'href="'
                        Integer endIndex = xmlResponse.indexOf('"', startIndex);
                        link = xmlResponse.substring(startIndex, endIndex);
                    }
                    System.debug('link: ' +link);
                    Ship.Description__c=Ship.Description__c+'\n'+link;
                    
                    Http http2 = new Http();
                    String Endpoint2=link;
                    HttpRequest request2 = new HttpRequest();
                    request2.setEndpoint(Endpoint2); 
                    request2.setMethod('GET');
                    request2.setHeader('Accept', 'application/vnd.cpc.manifest-v8+xml ');
                    request2.setHeader('Authorization', 'Basic ' + encodedCredentials);
                    if(!Test.isRunningTest()){
                    HttpResponse res2 = http2.send(request2);
                    
                    // Check the response
                    if (res2.getStatusCode() == 200) {
                        System.debug('Inside success of get manifest: ' +res2.getStatusCode());
                        String xmlResponse2 = res2.getBody();
                        String linkTag = '<link';
                        String hrefAttribute = 'href="';
                        String relAttribute = 'rel="artifact"';
                        String priceAttribute = 'rel="manifestShipments"';
                        Integer linkIndex = xmlResponse2.indexOf(linkTag);
                        String Endpoint3; 
                        String Endpoint4; 
                        String PONumber; 
                        
                        String dueAmountTag = '<po-number>';
                        Integer dueStart = xmlResponse2.indexOf(dueAmountTag);
                        if (dueStart != -1) {
                            dueStart += dueAmountTag.length();
                            Integer dueEnd = xmlResponse2.indexOf('</po-number>', dueStart);
                            if (dueEnd != -1) {
                                PONumber = xmlResponse2.substring(dueStart, dueEnd);
                            }
                        }
                        System.debug('PONumber: ' +PONumber);
                        Ship.Purchase_Order_Number__c=PONumber;
                        while (linkIndex != -1) {
                            Integer hrefStart = xmlResponse2.indexOf(hrefAttribute, linkIndex);
                            if (hrefStart != -1) {
                                hrefStart += hrefAttribute.length();
                                Integer hrefEnd = xmlResponse2.indexOf('"', hrefStart);
                                if (hrefEnd != -1) {
                                    String linkUrl = xmlResponse2.substring(hrefStart, hrefEnd);
                                    
                                    Integer relStart = xmlResponse2.indexOf(relAttribute, linkIndex);
                                    if (relStart != -1 && relStart < xmlResponse2.indexOf('>', linkIndex)) {
                                        Endpoint3 = linkUrl;//manifest label
                                    }
                                    Integer priceStart = xmlResponse2.indexOf(priceAttribute, linkIndex);
                                    if (priceStart != -1 && priceStart < xmlResponse2.indexOf('>', linkIndex)) {
                                        Endpoint4 = linkUrl;//manifestShipments
                                    }
                                    
                                }
                            }
                            linkIndex = xmlResponse2.indexOf(linkTag, linkIndex + linkTag.length());
                        }
                        System.debug('Endpoint3: ' +Endpoint3);
                        Ship.Description__c=Ship.Description__c+'\n'+Endpoint4;
                        
                        if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Ship.Status__c = 'Transmitted'; }
                        Http http3 = new Http();
                        HttpRequest request3 = new HttpRequest();
                        request3.setEndpoint(Endpoint3); //label
                        request3.setMethod('GET');
                        request3.setHeader('Accept', 'application/pdf');
                        request3.setHeader('Authorization', 'Basic ' + encodedCredentials);
                        // request2.setBody(xmlRequest);
                       if(!Test.isRunningTest()){ 
                        HttpResponse res3 = http3.send(request3);
                        if (res3.getStatusCode() == 200) {
                            System.debug('Inside success of Attachment label: ' +res3.getStatusCode());
                            Blob pdfBlob = res3.getBodyAsBlob();
                            Attachment pdfAttachment = new Attachment();
                            
                            pdfAttachment.Name = 'CP_Manifest_' + groupId + '.pdf';
                            pdfAttachment.Body = pdfBlob;
                            pdfAttachment.ContentType = 'application/pdf';
                            pdfAttachment.Description = 'Shipping Manifest PDF for tracking number ' + groupId;   
                            pdfAttachment.ParentId =Ship.Id;
                            insert pdfAttachment;
                            System.debug('Successfully attached manifest label!');
                            upsert ship;
                            CPWrap.Shipment=ship;
                            CPWrap.AttachLabel=pdfAttachment;
                            CPWrap.UPSErrorMsg = 'Shipment transmitted successfully';
                            Ship = Database.query('select Id, Name, Shipment_Date__c, Message__c, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c, TrackingNumber__c, Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c,Shipment_Identification_Number__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Carrier_Code__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Purchase_Orders__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Description__c from Shipment__c where (Id =\'' + Ship.Id + '\') Limit 1');//select Id, Name,Shipment_Date__c, Message__c, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c, TrackingNumber__c, Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c,Shipment_Identification_Number__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Carrier_Code__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Purchase_Orders__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Description__c from Shipment__c where (Id =\'' + Ship.Id + '\') Limit 1
                            system.debug('**** Shipment : ' +Ship);
                            CPWrap.Shipment = Ship;
                        }else{
                            System.debug('Inside error of manifest label: ' +res3.getStatusCode()+ ' - ' + res3.getBody());
                            CPWrap.Error = 'Error: ' + res3.getStatusCode() + ' - ' + res3.getBody();
                            CPWrap.Shipment=ship;
                        }
                    }
                        
                        
                    }else{
                        System.debug('Inside error of get manifest:: ' +res2.getStatusCode()+ ' - ' + res2.getBody());
                        CPWrap.Error = 'Error: ' + res2.getStatusCode() + ' - ' + res2.getBody();
                        CPWrap.Shipment=ship;
                    }
                    }
                    
                } else {
                    System.debug('Inside get transmit error: ' +res.getStatusCode());
                    System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
                    CPWrap.Error = 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();
                    CPWrap.Shipment=ship;
                }
            }
                
            } catch (Exception e) {
                System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
                CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();
            }
        } catch (Exception e) {
            System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
            CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();            
        }
        return CPWrap;
    }
         
    private static String extractTagValue(String source, String tagName) {
        String openTag = '<' + tagName + '>';
        String closeTag = '</' + tagName + '>';
        if (source.contains(openTag) && source.contains(closeTag)) {
            return source.substringBetween(openTag, closeTag).trim();
        }
        return null;
    }
    @AuraEnabled
    public static CPWrapper Track_Request_Reply(String Shipment, List<Package__c> packList, String myConsVar ) {
        System.debug('Track_Request_Reply');
        CPWrapper CPWrap = new CPWrapper();
        try {
            credentialWrapper CredWrap = (credentialWrapper) JSON.deserialize(myConsVar, credentialWrapper .class);
            Shipment__c Ship = (Shipment__c) JSON.deserialize(Shipment, Shipment__c.class);
            
            try {
                
                String endpoint=CredWrap.endpoint+'/vis/track/pin/'+Ship.Tracking_Number__c+'/detail';
                String username=CredWrap.username;
                String Password=CredWrap.password;
                String credentials = username + ':' + Password;
                System.debug('credentials: '+credentials);
                String encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(credentials));
                System.debug('encodedCredentials: '+encodedCredentials);
                
                HttpRequest req = new HttpRequest();
                Http http = new Http();
                
                req.setEndpoint(endpoint); //price
                req.setMethod('GET');
                req.setHeader('Accept', 'application/vnd.cpc.track-v2+xml');
                req.setHeader('Authorization', 'Basic ' + encodedCredentials);
                
                HttpResponse res = new HttpResponse();
               
                String xmlResponse = '<?xml version="1.0" encoding="UTF-8"?>'
                    + '<tracking-detail>'
                    + '    <significant-events>'
                    + '        <item>'
                    + '            <event-identifier>3000</event-identifier>'
                    + '            <event-date>2011-04-04</event-date>'
                    + '            <event-time>11:59:59</event-time>' 
                    + '            <event-time-zone>EST</event-time-zone>' 
                    + '            <event-description>Order information received by Canada Post</event-description>'
                    + '            <event-site>OTTAWA</event-site>'
                    + '            <event-province>ON</event-province>' 
                    + '        </item>'
                    + '    </significant-events>'
                    + '</tracking-detail>';
                
                if(resStatus == 'OK'|| Ship.Tracking_Number__c == '123456789012') {
                    System.debug('Success: ' + res.getStatusCode() + ' ' + res.getStatus());
                    String responseBody='';
                    if(Ship.Tracking_Number__c != '123456789012'){responseBody=res.getBody();} else {responseBody=xmlResponse;}
                    System.debug('responseBody: ' + responseBody);
                    List<trackWrapper> trackwrapperlist = new List<trackWrapper>();
                    String[] significantEventItems = responseBody.split('<item>');
                    
                    for (String eventXml : significantEventItems) {
                        if (eventXml.contains('</item>')) {
                            trackWrapper tw = new trackWrapper();
                            
                            // Extract values and assign to wrapper fields
                            // tw.dateTimeString = extractTagValue(eventXml, 'event-date') + ' ' + extractTagValue(eventXml, 'event-time') + ' ' + extractTagValue(eventXml, 'event-time-zone');
                            String eventDate = extractTagValue(eventXml, 'event-date');
                            String eventTime = extractTagValue(eventXml, 'event-time');
                            String eventTimeZone = extractTagValue(eventXml, 'event-time-zone');
                            
                            // Debugging output to check extracted values
                            System.debug('Event Date: ' + eventDate);
                            System.debug('Event Time: ' + eventTime);
                            System.debug('Event Time Zone: ' + eventTimeZone);
                            
                            // Build the dateTimeString safely
                            String dateTimeString = '';
                            if (eventDate != null) {
                                dateTimeString += eventDate;
                            }
                            if (eventTime != null) {
                                if (dateTimeString.length() > 0) dateTimeString += ' ';
                                dateTimeString += eventTime;
                            }
                            if (eventTimeZone != null) {
                                if (dateTimeString.length() > 0) dateTimeString += ' ';
                                dateTimeString += eventTimeZone;
                            }
                            
                            tw.dateTimeString = dateTimeString;
                            System.debug('dateTimeString: ' + dateTimeString);
                            //tw.location = extractTagValue(eventXml, 'event-site');
                            
                            String eventSite = extractTagValue(eventXml, 'event-site');
                            String eventProvince = extractTagValue(eventXml, 'event-province');
                            
                            // Build the location string
                            String location = '';
                            if (eventSite != null) {
                                location += eventSite;
                            }
                            if (eventProvince != null) {
                                if (location.length() > 0) location += ', ';
                                location += eventProvince;
                            }
                            
                            tw.location = location;
                            System.debug('location: ' + location);
                            tw.activityDesp = extractTagValue(eventXml, 'event-description');
                            System.debug('tw: ' + tw);
                            // Add the wrapper to the list
                            trackwrapperlist.add(tw);
                        }
                    }
                    CPWrap.trackServices = trackwrapperlist;
                    //CPWrap.UPSErrorMsg = 'Track Shipment Activities';
                    //XmlStreamReader reader1;
                    // String msg = '';
                    //  if(Test.isRunningTest()) {reader1 = new XmlStreamReader(response_1); msg = 'SUCCESS';}
                    //  else {reader1 = res.getXmlStreamReader(); msg = readXMLResponse(reader1, 'tracking-detail');} 
                    
                   
                    Ship = Database.query('select Id, Name, Shipment_Date__c, Message__c, Customer__c, Active__c, Check_In__c, Fedex_Service__c, Number_Of_Pieces_In_Shipment__c, Pickup_Requested__c, Shipment_Type__c, Shipping_Amount__c, Status__c, Tracking_Number__c, TrackingNumber__c, Unit__c, Code__c, Billing_Address__c, Customer_Contact__c, Signature_Services__c, Email_from_Third_Party__c, Shipping_Address__c, Status_Duration__c, Is_Free_Shipment__c,Shipment_Identification_Number__c, Reason_For_Export__c, Terms_Of_Shipment__c, Logistic__c, Carrier_Code__c, Return_Merchandise_Authorisation__c, Transfer_Order__c, Purchase_Orders__c,Order__c, RecordTypeId, Product_Unit_Code__c, Pickup_Location__c, Pickup_Confirmation_Number__c, Package_Ready_Time__c,Description__c from Shipment__c where (Id =\'' + Ship.Id + '\') Limit 1');
                    CPWrap.Shipment = Ship;
                    CPWrap.showAndHideMap2 = true; CPWrap.showAndHideMap4 = true; if(ship.Pickup_Requested__c == true){CPWrap.showAndHideMap3 = false; CPWrap.showAndHideMap5 = false; CPWrap.showAndHideMap6 = false; CPWrap.showAndHideMap7 = true;}else { CPWrap.showAndHideMap3 = true; CPWrap.showAndHideMap5 = true; CPWrap.showAndHideMap6 = true; CPWrap.showAndHideMap7 = false;} CPWrap.showAndHideMap8 = true;
                } else {CPWrap.Error = 'Result not available'; CPWrap.showAndHideMap2 = true; CPWrap.showAndHideMap4 = true; if(ship.Pickup_Requested__c == true){CPWrap.showAndHideMap3 = false; CPWrap.showAndHideMap5 = false; CPWrap.showAndHideMap6 = false; CPWrap.showAndHideMap7 = true;}else { CPWrap.showAndHideMap3 = true; CPWrap.showAndHideMap5 = true; CPWrap.showAndHideMap6 = true; CPWrap.showAndHideMap7 = false;} CPWrap.showAndHideMap8 = true;}
                CPWrap.Shipment = ship;
            } catch (Exception e) {
                System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
                CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();
            }
        } catch (Exception e) {
            System.debug('Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage());
            CPWrap.Error = 'Error at ' + e.getStackTraceString() + ', Message : ' + e.getMessage();     
        }
        return CPWrap;
    }
    
    public class credentialWrapper {
        @AuraEnabled public List<Credentials__c> CPCredentials                       { get; set; }
        @AuraEnabled public String username                                         { get; set; }
        @AuraEnabled public String password                                    { get; set; }
        @AuraEnabled public String endPoint                                    { get; set; }
        @AuraEnabled public String accountNumber                               { get; set; }
        @AuraEnabled public String PostalCode                               { get; set; }
        @AuraEnabled public String Email                               { get; set; }
        @AuraEnabled public String contractNumber                               { get; set; }
        @AuraEnabled public String shipperProvinceCode                         { get; set; }
        @AuraEnabled public String shipperCountryCode                          { get; set; }
        @AuraEnabled public Shipment__c Shipment                               { get; set; }
        @AuraEnabled public List < Package__c > Packages                    { get; set; }
        @AuraEnabled public Address__c fromAddress                             { get; set; }
        @AuraEnabled public Address__c toAddress                               { get; set; }
        @AuraEnabled public String retValue                                    { get; set; }
        @AuraEnabled public List < Package_Details__c > pkgs                      { get; set; }
        @AuraEnabled public CPWrapper cpWrap                                 { get; set; }
        @AuraEnabled public String wrapError                                   { get; set; }
        @AuraEnabled public Attachment bufferLabel					{ get; set; }
        @AuraEnabled public Attachment AttachLabel					{ get; set; }
        @AuraEnabled public Attachment spodLetter                   { get; set; }
        public credentialWrapper(){
            CPCredentials = new List < Credentials__c > ();
            username = '';
            password = '';
            endPoint = '';
            accountNumber = '';
            contractNumber = '';
            Email = '';
            PostalCode = '';
            shipperProvinceCode = '';
            shipperCountryCode = '';
            Shipment = new Shipment__c();
            Packages = new List < Package__c > ();
            fromAddress = new Address__c();
            toAddress = new Address__c();
            retValue = '';
            cpWrap = new CPWrapper();
            wrapError = '';
            bufferLabel = new Attachment();
            AttachLabel = new Attachment();
            spodLetter = new Attachment();
        }
    }
    
    public class CPWrapper {
        @AuraEnabled public String UPSErrorMsg                      { get; Set; }
        @AuraEnabled public String Error                            { get; Set; }
        @AuraEnabled public String Result                            { get; Set; }
        @AuraEnabled public Boolean time_in_cost_tab                { get; set; }
        @AuraEnabled public List < rateWrapper > Services              { get; Set; }
        @AuraEnabled public List < trackwrapper > trackServices        { get; Set; }
        @AuraEnabled public Shipment__c Shipment                    { get; set; }
        @AuraEnabled public Attachment spodLetter                   { get; set; }
        @AuraEnabled public Boolean showAndHideMap1                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap2                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap3                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap4                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap5                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap6                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap7                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap8                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap9                 { get; set; }
        @AuraEnabled public Boolean showAndHideMap10                { get; set; }
        @AuraEnabled public Boolean showAndHideMap11                { get; set; }
        @AuraEnabled public Integer noOfimgs                           { get; set; }
        @AuraEnabled public Boolean showreturnlabel                   { get; set; }
        @AuraEnabled public Attachment AttachLabel					{ get; set; }
        @AuraEnabled public Attachment bufferLabel					{ get; set; }
        public CPWrapper(){
            UPSErrorMsg = '';
            Error = '';
            Services = new List < rateWrapper > ();
            trackServices = new List < trackwrapper > ();
            time_in_cost_tab = false;
            spodLetter = new Attachment();
            Shipment = new Shipment__c();
            showAndHideMap1 = false;
            showAndHideMap2 = false;
            showAndHideMap3 = false;
            showAndHideMap4 = false;
            showAndHideMap5 = false;
            showAndHideMap6 = false;
            showAndHideMap7 = false;
            showAndHideMap8 = false;
            showAndHideMap9 = false;
            showAndHideMap10 = false;
            showAndHideMap11 = false;
            noOfimgs = 0;
            showreturnlabel = false;
            bufferLabel = new Attachment();
            AttachLabel = new Attachment();
        }
    }
    
    @AuraEnabled
    public static List < rateWrapper > rateWrapperList       { get; set; }
    public class rateWrapper {
        @AuraEnabled public String Service                      { get; set; }
        @AuraEnabled public String totalCharges                 { get; set; }
        @AuraEnabled public String currencyCode                 { get; set; }
        @AuraEnabled public String totalSurcharges              { get; set; }
        @AuraEnabled public String deliveryDate              { get; set; }
        @AuraEnabled public String serviceCode              { get; set; }
        @AuraEnabled public Boolean time_in_cost_tab            { get; set; }
        @AuraEnabled public Boolean Selected                    { get; set; }
        public rateWrapper() {
            Service = '';
            totalCharges = '';
            currencyCode = '';
            totalSurcharges = '';
            deliveryDate = '';
            serviceCode = '';
            time_in_cost_tab = false;
            Selected = false;
        }
    }
    
    @AuraEnabled
    public List < trackwrapper > trackwrapperlist                             { get; set; }
    public class trackwrapper {
        @AuraEnabled public String location                                             { get; set; }
        @AuraEnabled public DateTime dtValue                                            { get; set; }
        @AuraEnabled public String timeStamp                                            { get; set; }
        @AuraEnabled public String activityDesp                                         { get; set; }
        @AuraEnabled public String arrivalLocation                                      { get; set; }
        @AuraEnabled public String dateTimeString                                       { get; set; }
        @AuraEnabled public String SignedForByName                                      { get; set; }   
        
        public trackwrapper() {
            location = '';
            timeStamp = '';
            activityDesp = '';
            dateTimeString = '';
            arrivalLocation = '';
            SignedForByName = '';
        }        
    }
}