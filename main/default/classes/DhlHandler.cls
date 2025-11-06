public with sharing class DhlHandler { 
      
    public String userName                                    { get; set; }
    public String password                                    { get; set; }
    public String endPoint                                    { get; set; }
    
    public String accountNumber                               { get; set; }
    public Boolean flag                                       { get; set; }
    public String result                                      { get; set; } public String shipResult                                  { get; set; }    
    public String shipId;    
    public String retValue;
    public List<Id> packIds;
    public String totalNetCharges                             { get; set; }
    public String amount                                      { get; set; } public String service                                     { get; set; }
    public String errorMsg                                    { get; set; }
    
    public String resStatus                                   { get; set; } public String errorMsg1                                   { get; set; }        
    public String request_1                                   { get; set; } 
    public String response_1                                  { get; set; }
    public String request_2                                   { get; set; } 
    public String response_2                                  { get; set; } public String shipmentImages                              { get; set; }
    
    public String response_Message                            { get; set; }
    public String tab1_Message                                { get; set; }              
    public String weightUnit                                  { get; set; } public String originStreet                                { get; set; }   
    public Attachment upsLabel                                { get; set; }
    public Shipment__c Shipment                               { get; set; }
    public Sales_Order__c toAddr                              { get; set; }        
    public String addressFields                               { get; set; } 
    public String packageFields                               { get; set; }    
    public String shipmentFields                              { get; set; }
    public Attachment spodLetter                              { get; set; }
    public Address__c fromAddress                             { get; set; }
    public Boolean toShipmentType                             { get; set; } 
    public Sales_Order__c fromAddr                            { get; set; }
    public String MasterTrackingId                            { get; set; } 
    public String credentialFields                            { get; set; }      
    public Integer toalWeightValue                            { get; set; }   
    public String packageListFields                           { get; set; }
    public Boolean fromShipmentType                           { get; set; }
    public Boolean time_in_cost_tab                           { get; set; }
    public String destinationStreet                           { get; set; } 
    public String originCountryCode                           { get; set; } public String originProvinceCode                          { get; set; }
    public String shipperCountryCode                          { get; set; }    
    public List<Package__c> Packages                          { get; set; } public String shipperProvinceCode                         { get; set; }     
    public Address__c shippingAddress                         { get; set; }                    
    public Decimal totaldeclaredValue                         { get; set; } 
    public List<Package_List__c> pkgList                      { get; set; }
    public String destinationCountryCode                      { get; set; }
    public String destinationProvinceCode                     { get; set; }     
    public Map<String, String> recordIdMap                    { get; set; } 
    public List<Credentials__c> upsCredentials                { get; set; } public String errormsg2                                    { get; set; }
    public Map<Integer, Boolean> showAndHideMap               { get; set; } public Boolean hasAccess                                  { get; set; } 

    /*
      Constructor.
    */
    public DhlHandler() {  
        try {
            addressFields = UtilClass.selectStarFromSObject('ERP7__Address__c');
            packageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
            shipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c'); 
            flag = false;                
            toalWeightValue = 0;
            totaldeclaredValue = 0.0;
            time_in_cost_tab = false;                 
            packIds = new List<Id>();
            Shipment = new Shipment__c();
            toAddr = new Sales_Order__c();
            fromAddress = new Address__c();
            fromAddr = new Sales_Order__c(); 
            Packages = new List<Package__c>();  
            pkgList = new List<Package_List__c>();
            
            recordIdMap = new Map<String, String>();          
            toShipmentType = fromShipmentType = false;
            Shipment.Shipment_Date__c = System.Today().addDays(1);
            Shipment.Payment_Info__c = 'DDP';
            totalNetCharges = amount = errorMsg = MasterTrackingId = '';
            response_Message = tab1_Message = '';   
            showAndHideMap = new Map<Integer, Boolean>();  
            for(Integer i=1; i<=12; i++) { if(i==1 || i==10) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
            //Commenting the below as using description from package object
            //List<Package_Details__c> pkgs = new List<Package_Details__c> ([select Id, Name, Shipment_Description__c from Package_Details__c where Shipment_Description__c != null limit 1]);
            //if(pkgs.size() > 0 && pkgs[0].Shipment_Description__c != null) shipment.Description__c = pkgs[0].Shipment_Description__c;
            
            upsCredentials = Database.query('select ' + String.escapeSingleQuotes(credentialFields) + ' from Credentials__c where (Name = \'DHL\' And Active__c = true) Limit 1');
            if(upsCredentials != null && upsCredentials.size() > 0) { Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(upsCredentials[0].Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsCredentials[0].Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsCredentials[0].Password_Transkey__c));
                if(userData != null) upsCredentials[0].Username_Login__c = userData.toString();
                if(passwordData != null) upsCredentials[0].Password_Transkey__c = passwordData.toString();
                password = upsCredentials[0].Password_Transkey__c; 
                userName = upsCredentials[0].Username_Login__c;
                endPoint = upsCredentials[0].URL__c;
                accountNumber = upsCredentials[0].UPS_Account_Number__c;
                
                if(getCountryCode(upsCredentials[0].Shipper_Country__c) != '') shipperCountryCode = getCountryCode(upsCredentials[0].Shipper_Country__c); else errorMsg = 'DHL Shipping Service Unavailable : Shipper Country Code not found'; } else errorMsg = 'DHL Shipping Service Unavailable : Please setup DHL credentials';                      
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
    
    /*
      getter method definitions.
    */
    public String getProvinceCode(String provinceName) { List<Province_Codes__c> provinceList;
        if(provinceName != null && provinceName != '') {
            provinceList = [Select Id, Name, Code__c, Province__c From Province_Codes__c Where Province__c =: String.escapeSingleQuotes(provinceName) Limit 1];
        } if(provinceList != null && provinceList.size() > 0) return provinceList[0].Code__c;
          else return '';
    }
    public String getCountryCode(String countryName) { List<Country_Codes__c> countryList;
        if(countryName != null && countryName != '') {
            countryList = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: String.escapeSingleQuotes(countryName) Limit 1];
        } if(countryList != null && countryList.size() > 0) return countryList[0].Code__c;
          else return ''; 
    }
    public String getStreet(String AddressLine1, String AddressLine2, String AddressLine3) {
        if((AddressLine1 != Null && AddressLine1 != '') && (AddressLine2 != Null && AddressLine2 != '') && (AddressLine3 != Null && AddressLine3 != '')) {
            return AddressLine1 +', '+ AddressLine2 +', '+ AddressLine3; } 
        else if((AddressLine1 != Null && AddressLine1 != '') && (AddressLine2 != Null && AddressLine2 != '')) { return AddressLine1 +', '+ AddressLine2; }
        else if(AddressLine1 != Null && AddressLine1 != '') { return AddressLine1; }
        else return '';
    }
       
    public static String getCurrencyIsoCode(SObject someObject) { 
        return UserInfo.isMultiCurrencyOrganization() ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
    }
    public List<Id> getpackIds() { return packIds; }
    public void setpackIds(List<Id> s) { if(s != null && s.size() > 0) { packIds = s; if(!flag) init(); } }    
    public String getshipId() { return shipId; }
    public void setshipId(String s) { if(s != null && s != '') { shipId = s; if(!flag) init(); } }    
    public String getretValue() { return retValue; }
    public void setretValue(String s) { retValue = s; } 
    
    /*
      Init method called after setting the package Id / shipment Id.
    */
    public void init() {
        try { 
            if(packIds.size() > 0) { String bFilter, sFilter;
                for(Package__c p : Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, ERP7__Logistic__r.ERP7__Sales_Order__c, Logistic__r.Sales_Order__r.Id, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, '+
                                   +' Transfer_Order__r.To_Address__c, Sales_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.Message__c,Return_Merchandise_Authorisation__r.Address__c,Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c, '+
                                   +' (select ' + String.escapeSingleQuotes(packageListFields) + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Base_Price__c, Sales_Order_Line_Item__r.Product__r.SKU__c, Logistic_Line_Item__r.Product__r.Name, Logistic_Line_Item__r.Product__r.Declared_Shipment_Value__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c, '+
                                   +' Purchase_Line_Items__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Commodity_Code__c, Work_Order_Line_Items__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Commodity_Code__c, Transfer_Order_Line_Item__r.Products__r.Commodity_Code__c, RMA_Line_Item__r.SOLI__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c, Transfer_Order_Line_Item__r.Products__r.Name, Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c,RMA_Line_Item__r.ERP7__Product__r.Declared_Shipment_Value__c,RMA_Line_Item__r.ERP7__Product__r.Name,RMA_Line_Item__r.ERP7__Sale_Price__c, '+
                                   +' RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Unit_Price__c, Purchase_Line_Items__r.Total_Price__c, Purchase_Line_Items__r.Unit_Price__c, RMA_Line_Item__r.Total_Deduction__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Price_Product__c, Logistic_Line_Item__r.Price_Product__c From Package_Lists__r) '+
                                   +' from Package__c where Id In: packIds And Active__c = true')) {
                    for(sObject c : p.Package_Lists__r) { 
                        if(((Package_List__c)c).Sales_Order_Line_Item__c != null && ((Package_List__c)c).Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c != null) { totaldeclaredValue += (((Package_List__c)c).Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c * ((Package_List__c)c).Quantity__c).setScale(2); }
                        else if(((Package_List__c)c).Work_Order_Line_Items__c != null && ((Package_List__c)c).Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c != null) { totaldeclaredValue += (((Package_List__c)c).Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c * ((Package_List__c)c).Quantity__c).setScale(2); }
                        else if(((Package_List__c)c).Purchase_Line_Items__c != null && ((Package_List__c)c).Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c != null) { totaldeclaredValue += (((Package_List__c)c).Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c * ((Package_List__c)c).Quantity__c).setScale(2); }
                        else if(((Package_List__c)c).Transfer_Order_Line_Item__c != null && ((Package_List__c)c).Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c != null) { totaldeclaredValue += (((Package_List__c)c).Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c * ((Package_List__c)c).Quantity__c).setScale(2); }
                        else if(((Package_List__c)c).RMA_Line_Item__c != null && ((Package_List__c)c).RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c != null) { totaldeclaredValue += (((Package_List__c)c).RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c * ((Package_List__c)c).Quantity__c).setScale(2); }
                        pkgList.add((Package_List__c)c); 
                    } if(p.Weight_Unit__c != null) weightUnit = p.Weight_Unit__c;
                      if(p.Weight__c != null) toalWeightValue += Integer.valueof(p.Weight__c);   
                      Packages.add(p);                     
                }                     
                 // generating map of sobject record Ids to associate with shipment record
                if(Packages[0].Logistic__c != null) recordIdMap.put('LO', Packages[0].Logistic__c);
                if(Packages[0].Sales_Order__c != null) recordIdMap.put('SO', Packages[0].Sales_Order__c); else if(Packages[0].Work_Order__c != null) recordIdMap.put('WO', Packages[0].Work_Order__c); else if(Packages[0].Purchase_Order__c != null) recordIdMap.put('PO', Packages[0].Purchase_Order__c);
                else if(Packages[0].Transfer_Order__c != null) recordIdMap.put('TO', Packages[0].Transfer_Order__c); else if(Packages[0].Return_Merchandise_Authorisation__c != null) recordIdMap.put('SR', Packages[0].Return_Merchandise_Authorisation__c);                
                 // from address filter
                //if(Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c + '\''; }
                if(Packages[0].Logistic__r.From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Logistic__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Logistic__r.From_Address__c + '\''; }
                else if(Packages[0].Work_Order__r.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Work_Order__r.Billing_Address__c; bFilter = 'Id =\'' + Packages[0].Work_Order__r.Billing_Address__c + '\''; }
                else if(Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c + '\''; }
                else if(Packages[0].Transfer_Order__r.From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Transfer_Order__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Transfer_Order__r.From_Address__c + '\''; }
                else if(Packages[0].Return_Merchandise_Authorisation__r.Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.Address__c; bFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.Address__c + '\''; }
                 // to address filter  
                //if(Packages[0].Sales_Order__r.Ship_To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Sales_Order__r.Ship_To_Address__c; sFilter = 'Id =\'' + Packages[0].Sales_Order__r.Ship_To_Address__c + '\''; }
                if(Packages[0].Logistic__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Logistic__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Logistic__r.To_Address__c + '\''; }
                else if(Packages[0].Work_Order__r.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Work_Order__r.Shipping_Address__c; sFilter = 'Id =\'' + Packages[0].Work_Order__r.Shipping_Address__c + '\''; } else if(Packages[0].Purchase_Order__r.Vendor_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Purchase_Order__r.Vendor_Address__c; sFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Vendor_Address__c + '\''; }
                else if(Packages[0].Transfer_Order__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Transfer_Order__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Transfer_Order__r.To_Address__c + '\''; } else if(Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c; sFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c + '\''; }
                else if(Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c; sFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c + '\''; }
                                    
                if(bFilter != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ bFilter +' Limit 1');
                if(sFilter != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ sFilter +' Limit 1');
                
                 // fetching origin province and country code
                if(fromAddress != null) {
                    if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                    
                    if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                    else errorMsg = 'DHL Shipping Service Unavailable : Origin Country Code not found';            
                    if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                    fromAddr.Bill_To_Address__c = fromAddress.Id;
                }
                 // fetching destination province and country code
                if(shippingAddress != null) {
                    if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c);
                    if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c);
                    else errorMsg = 'DHL Shipping Service Unavailable : Destination Country Code not found';            
                    if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                    toAddr.Ship_To_Address__c = shippingAddress.Id;
                }
                shipment.Description__c = '';
                if(Packages[0].PO_Reference__c != null && Packages[0].PO_Reference__c != '') shipment.Description__c += Packages[0].PO_Reference__c + ' ';
                if(Packages[0].Description__c != null && Packages[0].Description__c != '') shipment.Description__c += Packages[0].Description__c;
                
            } else if(shipId != null && shipId  != '') {
                for(Package__c p : Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, '+
                                   +' Transfer_Order__r.To_Address__c, Sales_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, '+
                                   +' (select ' + String.escapeSingleQuotes(packageListFields) + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Base_Price__c, Sales_Order_Line_Item__r.Product__r.SKU__c, Logistic_Line_Item__r.Product__r.Name, Logistic_Line_Item__r.Product__r.Declared_Shipment_Value__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c, '+
                                   +' Purchase_Line_Items__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Commodity_Code__c, Work_Order_Line_Items__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Commodity_Code__c, Transfer_Order_Line_Item__r.Products__r.Commodity_Code__c, RMA_Line_Item__r.SOLI__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c, Transfer_Order_Line_Item__r.Products__r.Name, Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c,RMA_Line_Item__r.ERP7__Product__r.Declared_Shipment_Value__c,RMA_Line_Item__r.ERP7__Product__r.Name,RMA_Line_Item__r.ERP7__Sale_Price__c, '+
                                   +' RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Unit_Price__c, Purchase_Line_Items__r.Total_Price__c, Purchase_Line_Items__r.Unit_Price__c, RMA_Line_Item__r.Total_Deduction__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Price_Product__c, Logistic_Line_Item__r.Price_Product__c From Package_Lists__r) '+
                                   +' from Package__c where Id In: packIds And Active__c = true')) {
                    if(p.Weight_Unit__c != null) weightUnit = p.Weight_Unit__c; if(p.Weight__c != null) toalWeightValue += Integer.valueof(p.Weight__c);  
                    Packages.add(p);                     
                }               
                String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','DHL_Shipping');
                Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1');
                Shipment = (Shipment != null) ? Shipment : new Shipment__c();
                
                if(Shipment.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Shipment.Billing_Address__c; fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Billing_Address__c) + '\' Limit 1'); }
                if(Shipment.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Shipment.Shipping_Address__c; shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Shipping_Address__c) + '\' Limit 1'); }
                
                // fetching origin province and country code
                if(fromAddress != null) {
                    if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                    
                    if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                    else errorMsg = 'DHL Shipping Service Unavailable : Origin Country Code not found';            
                    if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                    fromAddr.Bill_To_Address__c = fromAddress.Id;
                }
                 // fetching destination province and country code
                if(shippingAddress != null) {
                    if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c);
                    
                    if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c);
                    else errorMsg = 'DHL Shipping Service Unavailable : Destination Country Code not found';            
                    if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                    toAddr.Ship_To_Address__c = shippingAddress.Id;
                }
                List<Attachment> myAttachment = new List<Attachment>();
                if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%DHL_Label%' order by CreatedDate DESC];
                                       for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9) showAndHideMap.put(i, false); else showAndHideMap.put(i, true); }
                } upsLabel = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment();  
                myAttachment = new List<Attachment>();
                if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%Proof of Delivery%' order by CreatedDate DESC Limit 1];                    
                                       showAndHideMap.put(8, false); showAndHideMap.put(9, true);  
                } spodLetter = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment();                
             } flag = true;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }    
    }
    
    /*
      method for getting from and to address upon change.
    */
    public PageReference fetchAddress() {
        try { 
            if(toAddr.Ship_To_Address__c != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(toAddr.Ship_To_Address__c) + '\' Limit 1');  
            if(fromAddr.Bill_To_Address__c != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(fromAddr.Bill_To_Address__c) + '\' Limit 1');
             // fetching origin province and country code
            if(fromAddress != null) { errorMsg = '';
                if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                
                if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                else errorMsg = 'DHL Shipping Service Unavailable : Origin Country Code not found';            
                if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                fromAddr.Bill_To_Address__c = fromAddress.Id;
            }
             // fetching destination province and country code
            if(shippingAddress != null) { errorMsg = '';
                if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c);
                
                if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c);
                else errorMsg = 'DHL Shipping Service Unavailable : Destination Country Code not found';            
                if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                toAddr.Bill_To_Address__c = shippingAddress.Id;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for generating DHL label as pdf to print.
    */
    public PageReference CreateFedexLabel() {
        PageReference pg = page.Pickpackship_PrintUPSLabel;
        pg.getParameters().put('shipmentsId',Shipment.Id);
        pg.getParameters().put('fileName','DHL_Label');
        //pg.getParameters().put('val','pdf');
        return pg;        
    }
    
    /*
      method for returning back to respective flows (SO, WO, PO, TO, SR)
    */
    public PageReference back() { 
        pageReference pg;
        /*if(retValue == 'SO') { pg = new pageReference('/apex/ERP7__Stockdispatching_SalesOrder'); pg.setRedirect(true); }
        else if(retValue == 'WO') { pg = new pageReference('/apex/ERP7__stockdispatching_WorkOrder'); pg.setRedirect(true); }
        else if(retValue == 'PO') { pg = new pageReference('/apex/ERP7__stockdispatching_PurchaseOrder'); pg.setRedirect(true); }
        else if(retValue == 'TO') { pg = new pageReference('/apex/ERP7__stockdispatching_TransferOrder'); pg.setRedirect(true); } */
        if(retValue == 'SR') { pg = new pageReference('/apex/ERP7__RMAPackage?id='+recordIdMap.get('SR')); pg.setRedirect(true); }
        else { pg = new pageReference('/apex/ERP7__OutboundLogistics'); pg.setRedirect(true); }
        return pg; 
    }
    
    /*
      shipping rate API request.
    */
    public PageReference Shipping_Rate() {
        try {
            if(errorMsg != '') { return null; } resStatus = Result = '';
            if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This package has already been ' + Shipment.Status__c; }  else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; }
            else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; }  else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } 
            else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; } else if (Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment date unavailable'; }
            else { errorMsg1 = '';  DateTime dt = Shipment.Shipment_Date__c;
                   //String shipmentDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'GMT\','America/New_York'); // YYYY-MM-DDTHH:MM:SSGMT+k 2018-03-15T12:00:00GMT+01:00
                   String shipmentDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'GMT\'') + '+01:00'; String createdSecurity = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                   /*Shipping_Rate_Request(fromAddress, shippingAddress, packages, shipmentDate, createdSecurity);*/
                  Shipping_Rate_Request(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), shipmentDate, createdSecurity);
                 }   
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference Shipping_Rate_Request(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String shipDate, String createdSec) { 
    public PageReference Shipping_Rate_Request(String fromAddress1, String toAddress1, String packList1, String shipDate, String createdSec) { 
        try {
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);
            Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            system.debug('DHL username~>'+userName);
            system.debug('DHL password~>'+password);
            system.debug('DHL accountNumber~>'+accountNumber);
            String xmlBody = '<?xml version="1.0" encoding="utf-8" ?>';
            xmlBody += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                xmlBody += '<soap:Header>';
                    xmlBody += '<wsse:Security xmlns:wsse="http://schemas.xmlsoap.org/ws/2003/06/secext">';
                        xmlBody += '<wsse:UsernameToken wsu:Id="sample" xmlns:wsu="http://schemas.xmlsoap.org/ws/2003/06/utility">';
                            xmlBody += '<wsse:Username>' + userName + '</wsse:Username>';
                            xmlBody += '<wsse:Password Type="wsse:PasswordText">' + password + '</wsse:Password>';
                            xmlBody += '<wsu:Created>'+ createdSec +'</wsu:Created>';
                        xmlBody += '</wsse:UsernameToken>';
                    xmlBody += '</wsse:Security>';
                xmlBody += '</soap:Header>';
                xmlBody += '<soap:Body>';
                    xmlBody += '<RateRequest>';
                        xmlBody += '<RequestedShipment>';
                            xmlBody += '<DropOffType>REQUEST_COURIER</DropOffType>';
                            xmlBody += '<Ship>';
                                if(upsCredentials != null && upsCredentials.size() > 0) {
                                    xmlBody += '<Shipper>';
                                        xmlBody += '<StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</StreetLines>';
                                        xmlBody += '<City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</City>';
                                        xmlBody += '<PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';
                                        if(shipperCountryCode != null) xmlBody += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';
                                    xmlBody += '</Shipper>';
                                }
                                if(toAddress != null) {
                                    xmlBody += '<Recipient>';
                                        xmlBody += '<StreetLines>' + DestinationStreet.escapeXml() + '</StreetLines>';
                                        xmlBody += '<City>' + toAddress.City__c.escapeXml() + '</City>';
                                        xmlBody += '<PostalCode>' + toAddress.Postal_Code__c.escapeXml() + '</PostalCode>';
                                        if(DestinationCountryCode != null) xmlBody += '<CountryCode>' + DestinationCountryCode.escapeXml() + '</CountryCode>';
                                    xmlBody += '</Recipient>';
                                }
                            xmlBody += '</Ship>';
                            for(Integer i=1; i<=packList.size(); i++) {
                                xmlBody += '<Packages>';
                                    xmlBody += '<RequestedPackages number="'+ i +'">';
                                    xmlBody += '<Weight>';
                                        xmlBody += '<Value>'+ Integer.valueOf(packList[i-1].Weight__c) +'</Value>';
                                    xmlBody += '</Weight>';
                                    xmlBody += '<Dimensions>';
                                        xmlBody += '<Length>'+ Integer.valueOf(packList[i-1].Length__c) +'</Length>';
                                        xmlBody += '<Width>'+ Integer.valueOf(packList[i-1].Width__c) +'</Width>';
                                        xmlBody += '<Height>'+ Integer.valueOf(packList[i-1].Height__c) +'</Height>';
                                    xmlBody += '</Dimensions>';
                                    xmlBody += '</RequestedPackages>';
                                xmlBody += '</Packages>';
                            }
                            xmlBody += '<ShipTimestamp>'+ shipDate +'</ShipTimestamp>';
                            xmlBody += '<UnitOfMeasurement>SU</UnitOfMeasurement>';
                            xmlBody += '<Content>NON_DOCUMENTS</Content>';
                            xmlBody += '<PaymentInfo>' + Shipment.Payment_Info__c + '</PaymentInfo>';
                            xmlBody += '<Account>' + accountNumber.escapeXml() + '</Account>';
                        xmlBody += '</RequestedShipment>';
                    xmlBody += '</RateRequest>';
                xmlBody += '</soap:Body>';
            xmlBody += '</soap:Envelope>';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://wsbexpress.dhl.com/sndpt/expressRateBook');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml'); 
            req.setBody(xmlBody);
            request_1 = xmlBody; 
             
            Http http = new Http();
            HttpResponse res = http.send(req);
            resStatus = res.getStatus(); 
            response_1 = res.getBody();
            
             
            if(resStatus == 'OK') { XmlStreamReader reader = res.getXmlStreamReader(); Result = readXMLResponseWithAtt(reader, 'Notification', 'code'); if(integer.ValueOf(Result) == 0){ XmlStreamReader reader1 = res.getXmlStreamReader(); readDhlXMLResponseRateTransitDetails(reader1, 'Provider'); Result = 'Available DHL Services For The Selected Location';  time_in_cost_tab = true; } else{ XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message'); Result = 'Shipping Rate is not available : ' + msg2; }
            } else Result = 'Result not available';
            
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    public void readDhlXMLResponseRateTransitDetails(XmlStreamReader reader, String sxmltag) {
        try {
            rateWrapper rw; rateWrapperList = new List<rateWrapper>();
            while(reader.hasNext()) {
                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { 
                    while(reader.hasNext()) {
                        rw = new rateWrapper(); 
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Service') {
                            rw.service = reader.getAttributeValue(reader.getNamespace(),'type'); 
                            reader.next(); 
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNet') {  reader.next();  if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); reader.next(); } reader.next(); if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next();  if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText() +' '+ rw.currencyCode;    } 
                                
                            } reader.next();
                            
                            Boolean nameFound = false;
                            while(!nameFound){
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ChargeType') {
                                    reader.next();
                                    rw.serviceName = reader.getText();
                                    break;
                                }
                                reader.next();
                            }
                            
                            Boolean found = false;
                            while(!found){
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'DeliveryTime') {
                                    reader.next();
                                    rw.CommitmentDate = reader.getText();
                                    break;
                                }
                                reader.next();
                            }
                            rateWrapperList.add(rw);
                        }
                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();
                    } 
                   /*'--- rateWrapperList Size : ' +rateWrapperList.size()*/
                } reader.next();
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
     
    /*
      shipment & label generation API request.
    */
    public PageReference Shipping_Request() {  
        try {
            system.debug('Shipping_Request called');
            if(errorMsg != '') { return null; } resStatus = Result = '';
            if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This Package Has Already Been ' + Shipment.Status__c; }  else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; } 
            else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; }  else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } 
            else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; } else if(Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment Date Unavailable'; } 
            else if(service == null || service == '') { errorMsg1 = 'Service Is Unavailable, Please Select At Least One Service From Shipping Service And Cost' ; } 
            else { errorMsg1 = '';  DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'GMT\'') + '+01:00'; String createdSecurity = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); String packages1=JSON.serialize(packages);
                   /*Shipping_Request_Reply(fromAddress, shippingAddress, packages, service, shipmentDate, createdSecurity);*/
                  Shipping_Request_Reply(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), packages1, service, shipmentDate, createdSecurity);
                 }                    
        } catch(Exception e) {
            system.debug('error Shipping_Request~>'+e.getMessage() +', '+ e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); 
        }
        return null;
    }
    //public PageReference Shipping_Request_Reply(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String service, String ShipDateStamp, String createdSec) {
    public PageReference Shipping_Request_Reply(String fromAddress1, String toAddress1, String packList1, String service, String ShipDateStamp, String createdSec) {
        try{
            system.debug('Shipping_Request_Reply called');
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);
            Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);
        	List<Package__c> packList =(List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            /*'ShipDateStamp : '+ShipDateStamp);
             'createdSec : '+createdSec);
            'service :  '+service);*/
            
            String xmlBody = '<?xml version="1.0" encoding="utf-8" ?>';
            xmlBody += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                xmlBody += '<soap:Header>';
                    xmlBody += '<wsse:Security xmlns:wsse="http://schemas.xmlsoap.org/ws/2003/06/secext">';
                        xmlBody += '<wsse:UsernameToken wsu:Id="sample" xmlns:wsu="http://schemas.xmlsoap.org/ws/2003/06/utility">';
                            xmlBody += '<wsse:Username>' + userName + '</wsse:Username>';
                            xmlBody += '<wsse:Password Type="wsse:PasswordText">' + password + '</wsse:Password>';
                            xmlBody += '<wsu:Created>'+ createdSec +'</wsu:Created>';
                        xmlBody += '</wsse:UsernameToken>';
                    xmlBody += '</wsse:Security>';
                xmlBody += '</soap:Header>';
                xmlBody += '<soap:Body>';
                    xmlBody += '<ShipmentRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="ShipmentMsgRequest.xsd">';
                        xmlBody += '<RequestedShipment>';
                            xmlBody += '<ShipmentInfo>';
                                xmlBody += '<DropOffType>REQUEST_COURIER</DropOffType>';
                                xmlBody += '<ServiceType>' + service + '</ServiceType>';
                                xmlBody += '<Account>' + accountNumber.escapeXml() + '</Account>';
                                xmlBody += '<Currency>GBP</Currency>';
                                xmlBody += '<UnitOfMeasurement>SU</UnitOfMeasurement>';
                                xmlBody += '<PackagesCount>'+ packList.size() +'</PackagesCount>';
                                xmlBody += '<LabelType>PDF</LabelType>';
                                xmlBody += '<LabelTemplate />';
                            xmlBody += '</ShipmentInfo>';
                            xmlBody += '<ShipTimestamp>'+ ShipDateStamp +'</ShipTimestamp>';
                            xmlBody += '<PaymentInfo>' + Shipment.Payment_Info__c + '</PaymentInfo>';
                            xmlBody += '<InternationalDetail>';
                                List<Product_Unit_Code__c> productType;
                                if(Shipment.Product_Unit_Code__c != null) productType = [select Id, Name, Product_Code__c, Product_Description__c from Product_Unit_Code__c where Product_Description__c =: Shipment.Product_Unit_Code__c limit 1];                    
                                for(Package_List__c pl: pkgList) {
                                    xmlBody += '<Commodities>';
                                        xmlBody += '<NumberOfPieces>'+ Integer.valueOf(pl.Quantity__c) +'</NumberOfPieces>';
                                         
                                        if(pl.Sales_Order_Line_Item__c != null) { xmlBody += '<Description>'+ pl.Sales_Order_Line_Item__r.Product__r.Name +'</Description>';  } else if(pl.Logistic_Line_Item__c != null) { xmlBody += '<Description>'+ pl.Logistic_Line_Item__r.Product__r.Name +'</Description>'; }
                                        else if(pl.Work_Order_Line_Items__c != null) { xmlBody += '<Description>'+ pl.Work_Order_Line_Items__r.Product__r.Name +'</Description>'; } else if(pl.Purchase_Line_Items__c != null) { xmlBody += '<Description>'+ pl.Purchase_Line_Items__r.Product__r.Name +'</Description>'; }
                                        else if(pl.Transfer_Order_Line_Item__c != null) {
                                            xmlBody += '<Description>'+ pl.Transfer_Order_Line_Item__r.Products__r.Name +'</Description>'; 
                                        } else if(pl.RMA_Line_Item__c != null) {
                                                xmlBody += '<Description>'+ pl.RMA_Line_Item__r.ERP7__Product__r.Name +'</Description>'; 
                                        }
                                    
                                    if(OriginCountryCode != DestinationCountryCode) { if(originCountryCode != null) xmlBody += '<CountryOfManufacture>'+ originCountryCode.escapeXML() +'</CountryOfManufacture>'; }xmlBody += '<Quantity>'+ Integer.valueOf(pl.Quantity__c) +'</Quantity>';
                                            
                                            if(pl.Sales_Order_Line_Item__c != null)         { xmlBody += '<UnitPrice>'+ pl.Sales_Order_Line_Item__r.Price_Product__c +'</UnitPrice>';} else if(pl.Logistic_Line_Item__c != null)       { xmlBody += '<UnitPrice>'+ pl.Logistic_Line_Item__r.Price_Product__c +'</UnitPrice>';}
                                            else if(pl.Work_Order_Line_Items__c != null)    { xmlBody += '<UnitPrice>'+ pl.Work_Order_Line_Items__r.Unit_Price__c +'</UnitPrice>';} else if(pl.Purchase_Line_Items__c != null)      { xmlBody += '<UnitPrice>'+ pl.Purchase_Line_Items__r.Unit_Price__c +'</UnitPrice>';}
                                            else if(pl.Transfer_Order_Line_Item__c != null) { xmlBody += '<UnitPrice>0</UnitPrice>';} else if(pl.RMA_Line_Item__c != null)    { xmlBody += '<UnitPrice>'+ pl.RMA_Line_Item__r.ERP7__Sale_Price__c +'</UnitPrice>';}

                                            if(pl.Sales_Order_Line_Item__c != null)         { xmlBody += '<CustomsValue>'+ pl.Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c +'</CustomsValue>';} else if(pl.Logistic_Line_Item__c != null)       { xmlBody += '<CustomsValue>'+ pl.Logistic_Line_Item__r.Product__r.Declared_Shipment_Value__c +'</CustomsValue>';}
                                            else if(pl.Work_Order_Line_Items__c != null)    { xmlBody += '<CustomsValue>'+ pl.Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c +'</CustomsValue>';} else if(pl.Purchase_Line_Items__c != null)      { xmlBody += '<CustomsValue>'+ pl.Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c +'</CustomsValue>';}
                                            else if(pl.Transfer_Order_Line_Item__c != null) { xmlBody += '<CustomsValue>'+ pl.Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c +'</CustomsValue>';}
                                    		else if(pl.RMA_Line_Item__c != null) { xmlBody += '<CustomsValue>'+ pl.RMA_Line_Item__r.ERP7__Product__r.Declared_Shipment_Value__c +'</CustomsValue>';}
                                        //}
                                    xmlBody += '</Commodities>';
                                }
                                
                                xmlBody += '<Content>NON_DOCUMENTS</Content>';
                            xmlBody += '</InternationalDetail>';
                            xmlBody += '<Ship>';
                                if(upsCredentials != null && upsCredentials.size() > 0) {
                                    xmlBody += '<Shipper>';
                                        xmlBody += '<Contact>';
                                            xmlBody += '<PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</PersonName>';
                                            xmlBody += '<CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</CompanyName>';
                                            xmlBody += '<PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</PhoneNumber>';
                                        xmlBody += '</Contact>';
                                        xmlBody += '<Address>';
                                            xmlBody += '<StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</StreetLines>';
                                            xmlBody += '<City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</City>';
                                            xmlBody += '<PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';
                                            if(shipperCountryCode != null) xmlBody += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';
                                        xmlBody += '</Address>';
                                    xmlBody += '</Shipper>';
                                }
                                if(toAddress != null) {
                                    xmlBody += '<Recipient>';
                                        xmlBody += '<Contact>';
                                            xmlBody += '<PersonName>'+ toAddress.Contact__r.Name.escapeXml() +'</PersonName>';
                                            if(toAddress.Contact__r.Company__c != null) xmlBody += '<CompanyName>'+ toAddress.Contact__r.Company__c.escapeXml() +'</CompanyName>';
                                            if(toAddress.Contact__r.Phone != null)      xmlBody += '<PhoneNumber>'+ toAddress.Contact__r.Phone.escapeXml() +'</PhoneNumber>';
                                        xmlBody += '</Contact>';
                                        xmlBody += '<Address>';
                                            xmlBody += '<StreetLines>' + DestinationStreet.escapeXml() + '</StreetLines>';
                                            xmlBody += '<City>' + toAddress.City__c.escapeXml() + '</City>';
                                            xmlBody += '<PostalCode>' + toAddress.Postal_Code__c.escapeXml() + '</PostalCode>';
                                            if(DestinationCountryCode != null) xmlBody += '<CountryCode>' + DestinationCountryCode.escapeXml() + '</CountryCode>';
                                        xmlBody += '</Address>';
                                    xmlBody += '</Recipient>';
                                }
                            xmlBody += '</Ship>';
                            for(Integer i=1; i<=packList.size(); i++) {
                                xmlBody += '<Packages>';
                                    xmlBody += '<RequestedPackages number="'+ i +'">';
                                        xmlBody += '<Weight>'+ Integer.valueOf(packList[i-1].Weight__c) +'</Weight>';
                                        xmlBody += '<Dimensions>';
                                            xmlBody += '<Length>'+ Integer.valueOf(packList[i-1].Length__c) +'</Length>';
                                            xmlBody += '<Width>'+ Integer.valueOf(packList[i-1].Width__c) +'</Width>';
                                            xmlBody += '<Height>'+ Integer.valueOf(packList[i-1].Height__c) +'</Height>';
                                        xmlBody += '</Dimensions>';
                                        xmlBody += '<CustomerReferences>'+ packList[i-1].name +'</CustomerReferences>';
                                    xmlBody += '</RequestedPackages>';
                                xmlBody += '</Packages>';
                            }
                        xmlBody += '</RequestedShipment>';
                    xmlBody += '</ShipmentRequest>';
                xmlBody += '</soap:Body>';
            xmlBody += '</soap:Envelope>';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://wsbexpress.dhl.com/sndpt/expressRateBook');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml'); 
            req.setBody(xmlBody);
            request_1 = xmlBody; 
             
            Http http = new Http();
            HttpResponse res = http.send(req);
            resStatus = res.getStatus(); 
            response_1 = res.getBody();
            
           /* '*** Ship req : '+xmlBody);
           '*** Ship res : '+response_1);
            '*** Ship resStatus : '+resStatus);*/
            
            String ShipmentIdentificationNumber, DispatchConfirmationNumber, TrackingNumber; 
            List<String> trackingNoList = new List<String>(); 
            List<String> shipmentImageLists = new List<String>();
            
            if(resStatus == 'OK') {
                XmlStreamReader reader1 = res.getXmlStreamReader(); Result = readXMLResponseWithAtt(reader1, 'Notification', 'code');
                /*'*** Result : ' +Result);*/
                if(integer.ValueOf(Result) == 0){
                    XmlStreamReader reader = res.getXmlStreamReader();
                    
                    while(reader.hasNext()){ if(reader.isStartElement()){ if(reader.getLocalName() == 'TrackingNumber'){ if(!reader.isCharacters())reader.next(); trackingNoList.add(reader.getText()); } } if(reader.isEndElement() && reader.getLocalName() == 'PackagesResult')break; reader.next(); }
                    
                    XmlStreamReader reader2 = res.getXmlStreamReader(); shipmentImages = readXMLResponse(reader2, 'GraphicImage');
                    
                    XmlStreamReader reader3 = res.getXmlStreamReader(); ShipmentIdentificationNumber = readXMLResponse(reader3, 'ShipmentIdentificationNumber');
                    
                    XmlStreamReader reader4 = res.getXmlStreamReader(); DispatchConfirmationNumber = readXMLResponse(reader4, 'DispatchConfirmationNumber');
                    
                    Id RTID; RTID = Schema.SObjectType.ERP7__Shipment__c.getRecordTypeInfosByDeveloperName().get('DHL_Shipping').getRecordTypeId();
                    if(Schema.sObjectType.Shipment__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Active__c.isUpdateable()) { Shipment.Active__c = true; }                        
                    if(Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isUpdateable()) { Shipment.Billing_Address__c = toAddress.Id; }                        
                    if(Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer__c.isUpdateable() && Shipment.Customer__c == Null) Shipment.Customer__c = toAddress.Customer__c; 
                    if(Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isUpdateable()) { Shipment.Customer_Contact__c = toAddress.Contact__c; }
                    if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipment.Status__c = 'Shipped'; }                                                                       
                    if(Schema.sObjectType.Shipment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment__c.fields.RecordTypeId.isUpdateable() && RTID != null) { Shipment.RecordTypeId = RTID; }
                    if(Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isUpdateable()) { Shipment.Shipping_Address__c = toAddress.Id; }
                    
                    if(recordIdMap.get('LO') != null) {
                        //if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name =  'LO-Shipment' ;
                        if(Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable()) Shipment.Logistic__c = recordIdMap.get('LO'); 
                        if(packList != null && packList.size() > 0){  if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = packList[0].Logistic__r.Sales_Order__c; }
                    }
                    if(recordIdMap.get('SO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name =  'SO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = recordIdMap.get('SO'); }
                    if(recordIdMap.get('WO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'WO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isUpdateable()) Shipment.Work_Order__c = recordIdMap.get('WO'); }
                    if(recordIdMap.get('PO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'PO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isUpdateable()) Shipment.Purchase_Orders__c = recordIdMap.get('PO'); }
                    if(recordIdMap.get('TO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'TO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isUpdateable()) Shipment.Transfer_Order__c = recordIdMap.get('TO'); }
                    if(recordIdMap.get('SR') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'SR-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable()) Shipment.Return_Merchandise_Authorisation__c = recordIdMap.get('SR'); }
                    
                    
                    if(Schema.sObjectType.Shipment__c.fields.DHL_Service__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.DHL_Service__c.isUpdateable()) { Shipment.DHL_Service__c = service; }
                    if(Schema.sObjectType.Shipment__c.fields.Tracking_Unique_Id__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Unique_Id__c.isUpdateable()) { if(DispatchConfirmationNumber != null) Shipment.Tracking_Unique_Id__c = DispatchConfirmationNumber; }  
                    //if(Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isUpdateable()) { Shipment.Shipping_Amount__c = (amount != '') ? Decimal.valueOf(amount) : 0.00; }
                    if(Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isUpdateable()) Shipment.Number_Of_Pieces_In_Shipment__c = String.valueof(Packages.size());
                    if(Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isUpdateable()) {  for(String s: trackingNoList) { if(Shipment.ERP7__TrackingNumber__c == null) Shipment.ERP7__TrackingNumber__c = s; else Shipment.ERP7__TrackingNumber__c += ',' + s; }} 
                    if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Shipment;} else {}                    
                    
                    // Adding below code to assign tracking number in sales order.
                    if(packList[0].Sales_Order__c != null){
                        ERP7__Sales_Order__c SalesOrder = new ERP7__Sales_Order__c(); SalesOrder = Database.query('select Id, Name, ERP7__Tracking_Number__c from ERP7__Sales_Order__c where (Id =\'' + String.escapeSingleQuotes(packList[0].Logistic__r.Sales_Order__r.Id) + '\') Limit 1');
                        
                        if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isUpdateable()) { for(String s: trackingNoList) { if(SalesOrder.ERP7__Tracking_Number__c == null) SalesOrder.ERP7__Tracking_Number__c = s; else SalesOrder.ERP7__Tracking_Number__c += ', ' + s; } }
                        if(Schema.sObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; update SalesOrder; }
                    }
                    
                        
                        // Additional code ends.
                    
                    // updating tracking number in corresponding packages.
                    for(Integer i=0; i<packList.size(); i++) { if(Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()) packList[i].Shipment__c = Shipment.Id;  if(Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) packList[i].Status__c = Shipment.Status__c;   if(trackingNoList.size() > i && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable()) packList[i].Tracking_Number__c = trackingNoList[i]; }
                    if(packList.size() > 0) if(Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert packList; } else{}
                    
                    // creating DHL label attachments and associating to new shipment created.
                    if(shipmentImages != null){ attachment att = new attachment(Name = 'DHL_Label', parentId = Shipment.Id, ContentType = 'application/pdf'); if(Schema.sObjectType.attachment.fields.body.isCreateable() && Schema.sObjectType.attachment.fields.body.isUpdateable()) { att.body = EncodingUtil.base64Decode(shipmentImages); } else{}
                                               if(Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.attachment.fields.Name.isUpdateable() && Schema.sObjectType.Attachment.fields.parentId.isCreateable() && Schema.sObjectType.Attachment.fields.ContentType.isCreateable() && Schema.sObjectType.attachment.fields.ContentType.isUpdateable()) { upsert att; } else{}
                                              }
                    
                    Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Id =\'' + String.escapeSingleQuotes(Shipment.Id) + '\') Limit 1'); Result = 'Package Shipped Successfully'; time_in_cost_tab = false; for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9) showAndHideMap.put(i, false); else showAndHideMap.put(i, true); }
                }
                else{
                    system.debug('response Result not 0 error else');
                    XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message'); Result = 'Could not ship : ' + msg2;
                }
            } else{
                system.debug('response Result not OK error else');
                Result = 'Result not available';
            }
            system.debug('response Result in Shipping_Request_Reply~>'+Result);
        } catch(Exception e) {
            system.debug('error Shipping_Request_Reply~>'+e.getMessage() +', '+ e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); 
        }
        return null;
    }
    
    /*
      cancel shipping API request.
    */
    
    public PageReference Cancel_Request() {
        try {
            if(errorMsg != '') { return null; } resStatus = Result = '';
            if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Unavailable'; }  else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Request To Cancel Shipment Cannot Be Processed'; }  else if(Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment Date Unavailable'; } 
            else { errorMsg1 = ''; DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd');
                   /*Cancel_Request_Reply(Shipment, packages, shipmentDate);*/
                  Cancel_Request_Reply(JSON.serialize(Shipment), JSON.serialize(packages), shipmentDate);
                 }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    } 
    
    //public PageReference Cancel_Request_Reply(Shipment__c shipments, List<Package__c> packList, String ShipDate) {
    public PageReference Cancel_Request_Reply(String shipments1, String packList1, String ShipDate) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            DateTime dt = System.today();
            String createdSecurity = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            
            String xmlBody = '<?xml version="1.0" encoding="utf-8" ?>';
            xmlBody += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                xmlBody += '<soap:Header>';
                    xmlBody += '<wsse:Security xmlns:wsse="http://schemas.xmlsoap.org/ws/2003/06/secext">';
                        xmlBody += '<wsse:UsernameToken wsu:Id="sample" xmlns:wsu="http://schemas.xmlsoap.org/ws/2003/06/utility">';
                            xmlBody += '<wsse:Username>' + userName + '</wsse:Username>';
                            xmlBody += '<wsse:Password Type="wsse:PasswordText">' + password + '</wsse:Password>';
                            xmlBody += '<wsu:Created>'+ createdSecurity +'</wsu:Created>';
                        xmlBody += '</wsse:UsernameToken>';
                    xmlBody += '</wsse:Security>';
                xmlBody += '</soap:Header>';
                xmlBody += '<soap:Body>';
                    xmlBody += '<DeleteRequest>'; 
                        xmlBody += '<PickupDate>' + ShipDate + '</PickupDate>';
                        xmlBody += '<PickupCountry>GB</PickupCountry>';
                        if(shipments.Tracking_Unique_Id__c != null)xmlBody += '<DispatchConfirmationNumber>'+ shipments.Tracking_Unique_Id__c +'</DispatchConfirmationNumber>';
                        xmlBody += '<RequestorName>Mohammed Uzair</RequestorName>';
                        xmlBody += '<Reason>001</Reason>';
                    xmlBody += '</DeleteRequest>';
                xmlBody += '</soap:Body>';
            xmlBody += '</soap:Envelope>';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://wsbexpress.dhl.com/sndpt/expressRateBook');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml'); 
            req.setBody(xmlBody);
            request_2 = xmlBody; 
             
            Http http = new Http();
            HttpResponse res = http.send(req);
            resStatus = res.getStatus(); 
            response_2 = res.getBody();
            
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); Result = readXMLResponseWithAtt(reader1, 'Notification', 'code');
                
                if(integer.ValueOf(Result) == 0){ if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipments.Status__c = 'Cancelled'; } else{}
                    if(Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Payment_Info__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Payment_Info__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Unique_Id__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Unique_Id__c.isUpdateable() ){ hasAccess=true; upsert Shipments;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } if(Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()){hasAccess=true; upsert packList;}    
					else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } } Shipment = new Shipment__c();  Result = 'Successfully cancelled'; for(Integer i=1; i<=7; i++) { if(i==1) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
                }else{
                    XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message'); Result = 'Request to cancel shipment cannot be processed : ' + msg2;
                }
            } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      shipment tracking API request.
    */
    
    public PageReference Track_Request() {
        try {
            if(errorMsg != '') { return null; } resStatus = Result = ''; if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Unavailable'; }            
            else { errorMsg1 = '';  /*Track_Request_Reply(shipment, packages);*/ Track_Request_Reply(JSON.serialize(shipment), JSON.serialize(packages)); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    //public PageReference Track_Request_Reply(Shipment__c shipments, List<Package__c> packList) {
    public PageReference Track_Request_Reply(String shipments1, String packList1) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
        List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            DateTime dt = System.today();
            String createdSecurity = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
              
            String xmlBody = '<?xml version="1.0" encoding="utf-8" ?>';
            xmlBody += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                xmlBody += '<soap:Header>';
                    xmlBody += '<wsse:Security xmlns:wsse="http://schemas.xmlsoap.org/ws/2003/06/secext">';
                        xmlBody += '<wsse:UsernameToken wsu:Id="sample" xmlns:wsu="http://schemas.xmlsoap.org/ws/2003/06/utility">';
                            xmlBody += '<wsse:Username>' + userName + '</wsse:Username>';
                            xmlBody += '<wsse:Password Type="wsse:PasswordText">' + password + '</wsse:Password>';
                            xmlBody += '<wsu:Created>'+ createdSecurity +'</wsu:Created>';
                        xmlBody += '</wsse:UsernameToken>';
                    xmlBody += '</wsse:Security>';
                xmlBody += '</soap:Header>';
                xmlBody += '<soap:Body>';
                    xmlBody += '<trackShipmentRequest>';
                        xmlBody += '<trackingRequest>';
                            xmlBody += '<TrackingRequest>';
                                xmlBody += '<Request>';
                                    xmlBody += '<ServiceHeader>';
                                        xmlBody += '<MessageTime>'+ createdSecurity +'</MessageTime>';
                                        //xmlBody += '<MessageReference>'+ Shipment.Name +'</MessageReference>';
                                       
                                        xmlBody += '<MessageReference>896ab310ba5311e38d9ffb21b7e57543</MessageReference>';
                                    xmlBody += '</ServiceHeader>';
                                xmlBody += '</Request>';
                                xmlBody += '<AWBNumber>';
                                    
                                    //xmlBody += '<ArrayOfAWBNumberItem>'+ Shipment.ERP7__TrackingNumber__c +'</ArrayOfAWBNumberItem>';
                                    // Test Track No 7895083910  7777777770
                                    xmlBody += '<ArrayOfAWBNumberItem>7777777770</ArrayOfAWBNumberItem>';
                                xmlBody += '</AWBNumber>';
                                xmlBody += '<LevelOfDetails>ALL_CHECK_POINTS</LevelOfDetails>';
                                xmlBody += '<PiecesEnabled>S</PiecesEnabled>';
                            xmlBody += '</TrackingRequest>';
                        xmlBody += '</trackingRequest>';
                    xmlBody += '</trackShipmentRequest>';
                xmlBody += '</soap:Body>';
            xmlBody += '</soap:Envelope>';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://wsbexpress.dhl.com/sndpt/glDHLExpressTrack');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml'); 
            req.setBody(xmlBody);
            request_1 = xmlBody; 
             
            Http http = new Http();
            HttpResponse res = http.send(req);
            resStatus = res.getStatus(); 
            response_1 = res.getBody();
            
            
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'ActionStatus');
                
                if(msg == 'Success'){ XmlStreamReader reader = res.getXmlStreamReader(); readDhlXMLResponseTrackHistory(reader,'ShipmentEvent');
                    
                    List<Shipment_Flow__c> existingSFList;  Map<String, Shipment_Flow__c> sfMap = new Map<String, Shipment_Flow__c>();
                    if(Shipment != null) { for(Shipment_Flow__c sf: [select Id, Name, Shipment__c, Shipment_DateTime__c, Description__c, Shipment_Flow_Start_Date__c, Shipment_Flow_End_Date__c from Shipment_Flow__c where Shipment__c =: Shipment.Id Order by Name Asc]) { sfMap.put(sf.Shipment_DateTime__c, sf); }}
                    
                    for(Integer i=0; i<trackWrapperList.size(); i++) { Shipment_Flow__c sf = new Shipment_Flow__c(Shipment_DateTime__c = String.valueof(trackWrapperList[i].dtValue));
                        if(!sfMap.keyset().contains(String.valueof(trackWrapperList[i].dtValue))) {
                            //sf.Name = 'Shipment Flow ' + i+1;
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Name.isUpdateable()) sf.Name = 'Shipment Flow ' + i;
                            if(Shipments != null && Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isUpdateable()) sf.Shipment__c = Shipments.Id;
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isUpdateable()) sf.Active__c = true;                            
                            if(trackWrapperList[i].dtValue != null &&  Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isUpdateable()) sf.Shipment_Flow_Start_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                            if(trackWrapperList[i].dtValue != null &&  Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isUpdateable()) sf.Shipment_Flow_End_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                            if(trackWrapperList[i].Event != null &&  Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isUpdateable()) sf.Description__c = trackWrapperList[i].Event;
                            if(trackWrapperList[i].Event != null && trackWrapperList[i].Event == 'Delivery ' &&  Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) Shipments.Status__c = 'Delivered';
                            
                            sfMap.put(String.valueof(trackWrapperList[i].dtValue), sf);
                        } 
                    }
                    
                    if(Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Payment_Info__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Payment_Info__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__TrackingNumber__c.isUpdateable()){hasAccess=true; upsert Shipments;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { pac.Status__c = Shipments.Status__c; } if(Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()){hasAccess=true; upsert packList;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } }
                    if(sfMap.size() > 0){ if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment_DateTime__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_DateTime__c.isUpdateable() && Schema.sObjectType.Shipment_Flow__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.isUpdateable()){ upsert sfMap.values();  } else{ } if(Shipments.Status__c == 'Delivered') { showAndHideMap.put(8, true); Result = 'Track Shipment Activities';}
                	} else{ Result = 'Request to track shipment cannot be processed : ' + msg; }
            } else Result = 'Result not available';
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    public void readDhlXMLResponseTrackHistory(XmlStreamReader reader, String sxmltag) {
        try {
            trackwrapper tw; trackwrapperlist = new List<trackwrapper>();
            while(reader.hasNext()) {
                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { 
                    while(reader.hasNext()) { 
                        tw = new trackwrapper(); 
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ArrayOfShipmentEventItem') { reader.next();reader.next();
                            
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Date') { reader.next();
                                tw.EventDate = reader.getText();
                            }reader.next();reader.next();reader.next();
                            
                            // EventDate EventTime dtValue Event SignedForByName
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Time') {
                                reader.next();
                                    tw.EventTime = reader.getText();
                            }reader.next();reader.next();reader.next();
                            
                            string datetimevalue = tw.EventDate + ' ' + tw.EventTime;
                            tw.dtValue = Datetime.valueOf(datetimevalue);
                            
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceEvent') { reader.next();
                                Boolean nameFound = false;
                                while(!nameFound){
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Description') { reader.next();
                                        tw.Event = reader.getText(); reader.next();reader.next();reader.next();reader.next();reader.next(); 
                                        break;
                                        
                                    }
                                    reader.next();
                                }
                            }
                            
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Signatory') { reader.next();
                                tw.SignedForByName = reader.getText();
                                reader.next(); reader.next(); reader.next();
                            }
                            
                            
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceArea') { reader.next();
                                Boolean nameFound = false;
                                while(!nameFound){
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Description') { reader.next();
                                        tw.EventCity = reader.getText(); break;
                                    }
                                    reader.next();
                                }
                            }reader.next();
                            
                            if(tw.Event != null && tw.EventCity != null) tw.EventDesc = tw.Event + ' ' + tw.EventCity;
                            
                            trackwrapperlist.add(tw);
                        }
                        
                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();
                    } 
                    /*'--- trackwrapperlist Size : ' +trackwrapperlist.size()); */
                } reader.next();
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
     
    /*
      signature proof API request.
    */
    public PageReference Signature_Proof() {
        try {
            if(errorMsg != '') { return null; } resStatus = Result = ''; if(Shipment.Status__c == '' || Shipment.Status__c == Null) errorMsg1 = 'The shipment is unavailable'; else if(Shipment.Status__c != 'Delivered') errorMsg1 = 'Request to get signature proof of delivery for this shipment cannot be processed';
            else {  errorMsg1 = ''; DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd');  Signature_Proof_Reply(JSON.serialize(Shipment), shipmentDate); }            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public PageReference Signature_Proof_Reply(String Shipment1, String shipDate) {
        try {
            Shipment__c Shipment = (Shipment__c)JSON.deserialize(Shipment1, Shipment__c.class);
            DateTime dt = System.now();
            String createdSecurity = dt.format('yyyy-MM-dd\'T\'HH:mm:ss');
            
            String xmlBody = '<?xml version="1.0" encoding="utf-8" ?>';
            xmlBody += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">';
                xmlBody += '<soap:Header>';
                    xmlBody += '<wsse:Security xmlns:wsse="http://schemas.xmlsoap.org/ws/2003/06/secext">';
                        xmlBody += '<wsse:UsernameToken wsu:Id="sample" xmlns:wsu="http://schemas.xmlsoap.org/ws/2003/06/utility">';
                            xmlBody += '<wsse:Username>' + userName + '</wsse:Username>';
                            xmlBody += '<wsse:Password Type="wsse:PasswordText">' + password + '</wsse:Password>';
                            //xmlBody += '<wsu:Created>'+ createdSecurity +'</wsu:Created>';
                        xmlBody += '</wsse:UsernameToken>';
                    xmlBody += '</wsse:Security>';
                xmlBody += '</soap:Header>';
                xmlBody += '<soap:Body>';
                    xmlBody += '<shipmentDocumentRetrieveReq>';
                        xmlBody += '<MSG>';
                            //xmlBody += '<Hdr Id="'+ Shipment.Name +'" Ver="1.038" Dtm="' + createdSecurity + '">';
                            xmlBody += '<Hdr Id="TestPOD" Ver="1.038" Dtm="' + createdSecurity + '">';
                                xmlBody += '<Sndr AppNm="DCG" AppCd="DCG"/>';
                            xmlBody += '</Hdr>';
                            xmlBody += '<Bd>';
                                xmlBody += '<Shp Id="'+ Shipment.ERP7__TrackingNumber__c +'">';
                                //xmlBody += '<Shp Id="7895083910">';
                                    xmlBody += '<ShpTr>';
                                        xmlBody += '<SCDtl AccNo="' + accountNumber.escapeXml() + '" CRlTyCd="TC"/>';
                                    xmlBody += '</ShpTr>';
                                    xmlBody += '<ShpInDoc>';
                                        xmlBody += '<SDoc DocTyCd="POD"/>';
                                    xmlBody += '</ShpInDoc>';
                                xmlBody += '</Shp>';
                                xmlBody += '<GenrcRq>';
                                    xmlBody += '<GenrcRqCritr TyCd="IMG_CONTENT" Val="epod-detail-esig"/>';
                                    xmlBody += '<GenrcRqCritr TyCd="IMG_FORMAT" Val="PDF"/>';
                                    xmlBody += '<GenrcRqCritr TyCd="DOC_RND_REQ" Val="true"/>';
                                    xmlBody += '<GenrcRqCritr TyCd="EXT_REQ" Val="true"/>';
                                    xmlBody += '<GenrcRqCritr TyCd="DUPL_HANDL" Val="CORE_WB_NO"/>';
                                    xmlBody += '<GenrcRqCritr TyCd="SORT_BY" Val="$INGEST_DATE,D"/>';
                                    xmlBody += '<GenrcRqCritr TyCd="LANGUAGE" Val="en"/>';
                                xmlBody += '</GenrcRq>';
                            xmlBody += '</Bd>';
                        xmlBody += '</MSG>';
                    xmlBody += '</shipmentDocumentRetrieveReq>';
                xmlBody += '</soap:Body>';
            xmlBody += '</soap:Envelope>';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://wsbexpress.dhl.com/sndpt/getePOD');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml'); 
            req.setBody(xmlBody);
            request_1 = xmlBody; 
             
            Http http = new Http();
            HttpResponse res = http.send(req);
            resStatus = res.getStatus(); 
            response_1 = res.getBody();
            
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); Result = readXMLResponseWithAtt(reader1, 'ErrMsgDtl', 'MsgCIgd');
                
                if(integer.ValueOf(Result) == 100000){  XmlStreamReader reader = res.getXmlStreamReader(); String letter = readXMLResponseWithAtt(reader, 'Img', 'Img'); if(letter != null && letter !='') { attachment att = new attachment(Name = 'Proof of Delivery', parentId = Shipment.Id, ContentType = 'application/pdf'); if(Schema.sObjectType.attachment.fields.body.isCreateable()) { att.body = EncodingUtil.base64Decode(letter); }
                        if(Schema.sObjectType.Attachment.fields.body.isCreateable() && Schema.sObjectType.Attachment.fields.body.isUpdateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isUpdateable() && Schema.sObjectType.Attachment.fields.parentId.isCreateable() && Schema.sObjectType.Attachment.fields.ContentType.isCreateable() && Schema.sObjectType.Attachment.fields.ContentType.isUpdateable()){hasAccess=true; upsert att;} else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } 
 						spodLetter = att; if(spodLetter != null) showAndHideMap.put(9, true); Result = 'Request for ePOD processed successfully';
                    } 
                }
                else{ XmlStreamReader reader3 = res.getXmlStreamReader(); Result = readXMLResponseWithAtt(reader3, 'ErrMsgDtl', 'DtlDsc');
                }
            } else Result = 'Result not available';
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      wrapper class definitions.
    */
     // rate wrapper class
    public List<rateWrapper> rateWrapperList       { get; set; }    
    public class rateWrapper {
        public String Service                      { get; set; }
        public String ServiceName                  { get; set; }                   
        public String totalCharges                 { get; set; }
        public String currencyCode                 { get; set; }   
        public String totalSurcharges              { get; set; }   
        public String CommitmentDate               { get; set; }
        
        public rateWrapper() {
            Service = '';
            ServiceName = '';
            totalCharges = '';
            currencyCode = '';
            totalSurcharges = '';
            CommitmentDate = '';
        }
    }
     // track wrapper class
    public List<trackwrapper> trackwrapperlist                             { get; set; }    
    public class trackwrapper {                 
        public String EventTime                                            { get; set; }  
        public String EventDate                                            { get; set; }  
        public String Event                                                { get; set; }  
        public String SignedForByName                                      { get; set; }   
        public String EventCity                                            { get; set; }
        public String EventDesc                                            { get; set; }
        public DateTime dtValue                                            { get; set; } 
            
        public trackwrapper() {    
            EventTime = '';
            EventDate = '';
            Event = '';
            SignedForByName = '';
            EventCity = '';
            EventDesc = '';
        }        
    }
    
    /* ------------------------- User Defined Function Reading XMLResponse -------------------------*/                
    public String readXMLResponse(XmlStreamReader reader, String sxmltag) { String retValue = ''; 
        try { while (reader.hasNext()) { if (reader.getEventType() == XmlTag.START_ELEMENT) { if (sxmltag == reader.getLocalName()) { while (reader.hasNext()) { if (reader.getEventType() == XmlTag.END_ELEMENT) { break; }  else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); } reader.next(); } } } reader.next();   }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return retValue;
    }
    /* ------------------------- User Defined Function Reading XMLResponse with Attribute-------------------------*/                
    public String readXMLResponseWithAtt(XmlStreamReader reader, String sxmltag, string attLocalName) {
        String retValue = ''; // Read through the XML
        try {                                                                        
            while (reader.hasNext()) {              
                if (reader.getEventType() == XmlTag.START_ELEMENT) { 
                    if (sxmltag == reader.getLocalName()) {
                        retValue = reader.getAttributeValue(reader.getNamespace(),attLocalName); 
                    }
                } reader.next(); 
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return retValue;
    }
}