public with sharing class USPS { 
    
    
    public String userName                                    { get; set; } public String Key                                         { get; set; }
    public String password                                    { get; set; }
    public String endPoint                                    { get; set; }
    public Boolean flag                                       { get; set; }
    public String result                                      { get; set; }
    public String shipId;    
    public String retValue;
    public List<Id> packIds;
    public String totalNetCharges                             { get; set; }
    public String amount                                      { get; set; } public String service                                     { get; set; }
    public String errorMsg                                    { get; set; }
    
    public String resStatus                                   { get; set; }             
    public String errorMsg1                                   { get; set; }        
    public String request_1                                   { get; set; } 
    public String response_1                                  { get; set; }
    public Boolean USPS_Returned_Error                        { get; set; }
    
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
    public String packageListFields                           { get; set; } public String shipperCountryCode                          { get; set; }  
    public Boolean fromShipmentType                           { get; set; }
    public Boolean time_in_cost_tab                           { get; set; }
    public String destinationStreet                           { get; set; } public String originCountryCode                           { get; set; }
     
      
    public List<Package__c> Packages                          { get; set; } public String originProvinceCode                          { get; set; }   
    public String shipperProvinceCode                         { get; set; }     
    public Address__c shippingAddress                         { get; set; }                    
    public Decimal totaldeclaredValue                         { get; set; } 
    public List<Package_List__c> pkgList                      { get; set; }
    public String destinationCountryCode                      { get; set; }
    public String destinationProvinceCode                     { get; set; }     
    public Map<String, String> recordIdMap                    { get; set; } 
    public List<Credentials__c> upsCredentials                { get; set; }
    public Map<Integer, Boolean> showAndHideMap               { get; set; }  public String errormsg2                                    { get; set; }  
    
    
    public Boolean hasAccess                                  { get; set; } 
       
    /*
      Constructor.
    */
    public USPS() {  
        try {
            addressFields = UtilClass.selectStarFromSObject('ERP7__Address__c');
            packageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
            shipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c'); 
            flag = false;
            USPS_Returned_Error = false;                
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
            Shipment.Shipment_Date__c = System.Today();
            totalNetCharges = amount = errorMsg = MasterTrackingId = '';
            response_Message = tab1_Message = '';   
            showAndHideMap = new Map<Integer, Boolean>();  
            for(Integer i=1; i<=12; i++) { if(i==1 || i==10) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
            //List<Package_Details__c> pkgs = new List<Package_Details__c> ([select Id, Name, Shipment_Description__c from Package_Details__c where Shipment_Description__c != null limit 1]);
            //if(pkgs.size() > 0 && pkgs[0].Shipment_Description__c != null) shipment.Description__c = pkgs[0].Shipment_Description__c;
            
            upsCredentials = Database.query('select ' + String.escapeSingleQuotes(credentialFields) + ' from Credentials__c where (Name = \'USPS\' And Active__c = true) Limit 1');
            if(upsCredentials != null && upsCredentials.size() > 0) { Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(upsCredentials[0].Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsCredentials[0].Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsCredentials[0].Password_Transkey__c));
                if(userData != null) upsCredentials[0].Username_Login__c = userData.toString();
                if(passwordData != null) upsCredentials[0].Password_Transkey__c = passwordData.toString();
                password = upsCredentials[0].Password_Transkey__c; 
                userName = upsCredentials[0].Username_Login__c;
                endPoint = upsCredentials[0].URL__c;  } else errorMsg = 'USPS Shipping Service Unavailable : Please setup USPS credentials';                       } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
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
    public void setpackIds(List<Id> s) { if(s != null && s.size() > 0) { system.debug(s); packIds = s; if(!flag) init(); } }    
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
                for(Package__c p : Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, '+
                                   +' Transfer_Order__r.To_Address__c, Sales_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.Message__c, '+
                                   +' (select ' + String.escapeSingleQuotes(packageListFields) + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Base_Price__c, Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c, '+
                                   +' Purchase_Line_Items__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Commodity_Code__c, Work_Order_Line_Items__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Commodity_Code__c, Transfer_Order_Line_Item__r.Products__r.Commodity_Code__c, RMA_Line_Item__r.SOLI__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c, Transfer_Order_Line_Item__r.Products__r.Name, Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c, '+
                                   +' RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Unit_Price__c, Purchase_Line_Items__r.Total_Price__c, Purchase_Line_Items__r.Unit_Price__c, RMA_Line_Item__r.Total_Deduction__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Price_Product__c From Package_Lists__r) '+
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
                if(Packages[0].Sales_Order__c != null) recordIdMap.put('SO', Packages[0].Sales_Order__c); else if(Packages[0].Work_Order__c != null) recordIdMap.put('WO', Packages[0].Work_Order__c); else if(Packages[0].Purchase_Order__c != null) recordIdMap.put('PO', Packages[0].Purchase_Order__c); else if(Packages[0].Transfer_Order__c != null) recordIdMap.put('TO', Packages[0].Transfer_Order__c); else if(Packages[0].Return_Merchandise_Authorisation__c != null) recordIdMap.put('SR', Packages[0].Return_Merchandise_Authorisation__c);                
                 // from address filter
                //if(Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Sales_Order__r.Channel__r.Ship_From_Address__c + '\''; }
                if(Packages[0].Logistic__r.From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Logistic__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Logistic__r.From_Address__c + '\''; }
                else if(Packages[0].Work_Order__r.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Work_Order__r.Billing_Address__c; bFilter = 'Id =\'' + Packages[0].Work_Order__r.Billing_Address__c + '\''; }
                else if(Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c + '\''; }
                else if(Packages[0].Transfer_Order__r.From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Transfer_Order__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Transfer_Order__r.From_Address__c + '\''; }
                else if(Packages[0].Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c + '\''; }
                 // to address filter  
                //if(Packages[0].Sales_Order__r.Ship_To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Sales_Order__r.Ship_To_Address__c; sFilter = 'Id =\'' + Packages[0].Sales_Order__r.Ship_To_Address__c + '\''; }
                if(Packages[0].Logistic__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Logistic__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Logistic__r.To_Address__c + '\''; }
                else if(Packages[0].Work_Order__r.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Work_Order__r.Shipping_Address__c; sFilter = 'Id =\'' + Packages[0].Work_Order__r.Shipping_Address__c + '\''; } else if(Packages[0].Purchase_Order__r.Vendor_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Purchase_Order__r.Vendor_Address__c; sFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Vendor_Address__c + '\''; } else if(Packages[0].Transfer_Order__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Transfer_Order__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Transfer_Order__r.To_Address__c + '\''; } else if(Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c; sFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c + '\''; }
                system.debug('String.escapeSingleQuotes(bFilter) : '+bFilter);
                if(bFilter != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ bFilter +' Limit 1');
                if(sFilter != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ sFilter +' Limit 1');
                
                 // fetching origin province and country code
                if(fromAddress != null) {
                    if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c); else errorMsg = 'USPS Shipping Service Unavailable : Origin Province Code not found';            
                    if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c); else errorMsg = 'USPS Shipping Service Unavailable : Origin Country Code not found';            
                    if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                    fromAddr.Bill_To_Address__c = fromAddress.Id;
                }
                 // fetching destination province and country code
                if(shippingAddress != null) {
                    if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c);
                    else errorMsg = 'USPS Shipping Service Unavailable : Destination Province Code not found';            
                    if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'USPS Shipping Service Unavailable : Destination Country Code not found';            
                    if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                    toAddr.Ship_To_Address__c = shippingAddress.Id;
                }
                
                shipment.Description__c = '';
                if(Packages[0].PO_Reference__c != null && Packages[0].PO_Reference__c != '') shipment.Description__c += Packages[0].PO_Reference__c + ' ';
                if(Packages[0].Description__c != null && Packages[0].Description__c != '') shipment.Description__c += Packages[0].Description__c;
                     
            } else if(shipId != null && shipId  != '') {
                for(Package__c p : Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, '+
                                   +' Transfer_Order__r.To_Address__c, Sales_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, '+
                                   +' (select ' + String.escapeSingleQuotes(packageListFields) + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Base_Price__c, Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c, '+
                                   +' Purchase_Line_Items__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Commodity_Code__c, Work_Order_Line_Items__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Commodity_Code__c, Transfer_Order_Line_Item__r.Products__r.Commodity_Code__c, RMA_Line_Item__r.SOLI__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c, Transfer_Order_Line_Item__r.Products__r.Name, Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c, '+
                                   +' RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Unit_Price__c, Purchase_Line_Items__r.Total_Price__c, Purchase_Line_Items__r.Unit_Price__c, RMA_Line_Item__r.Total_Deduction__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Price_Product__c From Package_Lists__r) '+
                                   +' from Package__c where Id In: packIds And Active__c = true')) {
                    if(p.Weight_Unit__c != null) weightUnit = p.Weight_Unit__c; if(p.Weight__c != null) toalWeightValue += Integer.valueof(p.Weight__c);   Packages.add(p);                     
                }               
                String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','USPS_Shipping');
                Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1');
                Shipment = (Shipment != null) ? Shipment : new Shipment__c();
                
                if(Shipment.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Shipment.Billing_Address__c; fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Billing_Address__c) + '\' Limit 1'); }
                if(Shipment.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Shipment.Shipping_Address__c; shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Shipping_Address__c) + '\' Limit 1'); }
                
                // fetching origin province and country code
                if(fromAddress != null) {
                    if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                    else errorMsg = 'USPS Shipping Service Unavailable : Origin Province Code not found';            
                    if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                    else errorMsg = 'USPS Shipping Service Unavailable : Origin Country Code not found';            
                    if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                    fromAddr.Bill_To_Address__c = fromAddress.Id;
                }
                 // fetching destination province and country code
                if(shippingAddress != null) {
                    if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c); else errorMsg = 'USPS Shipping Service Unavailable : Destination Province Code not found';            
                    if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'USPS Shipping Service Unavailable : Destination Country Code not found';            
                    if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                    toAddr.Ship_To_Address__c = shippingAddress.Id;
                }
                List<Attachment> myAttachment = new List<Attachment>();
                if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%USPS_Label%' order by CreatedDate DESC];
                                       for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9) showAndHideMap.put(i, false); else showAndHideMap.put(i, true); }
                } upsLabel = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment();  
                myAttachment = new List<Attachment>();
                if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%Proof of Delivery.doc%' order by CreatedDate DESC Limit 1];                    
                                       showAndHideMap.put(8, false); showAndHideMap.put(9, true);  
                } spodLetter = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment();                
             } flag = true; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }    
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
                else errorMsg = 'USPS Shipping Service Unavailable : Origin Province Code not found';            
                if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                else errorMsg = 'USPS Shipping Service Unavailable : Origin Country Code not found';            
                if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                fromAddr.Bill_To_Address__c = fromAddress.Id;
            }
             // fetching destination province and country code
            if(shippingAddress != null) { errorMsg = '';
                if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c); else errorMsg = 'USPS Shipping Service Unavailable : Destination Province Code not found';            
                if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'USPS Shipping Service Unavailable : Destination Country Code not found';            
                if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                toAddr.Bill_To_Address__c = shippingAddress.Id;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for generating fedex label as pdf to print.
    */
    public PageReference CreateUSPSLabel() {
        PageReference pg = page.Pickpackship_PrintUPSLabel;
        pg.getParameters().put('shipmentsId',Shipment.Id);
        pg.getParameters().put('fileName','USPS_Label');
        pg.getParameters().put('val','pdf');
        return pg;        
    }
    
    /*
      method for returning back to respective flows (SO, WO, PO, TO, SR)
    */
    public PageReference back() { 
        pageReference pg;
        if(retValue == 'SR') { pg = new pageReference('/apex/ERP7__RMAPackage?id='+recordIdMap.get('SR')); pg.setRedirect(true); }
        else { pg = new pageReference('/apex/ERP7__OutboundLogistics'); pg.setRedirect(true); }
        return pg; 
    }
    
    /*
      shipping rate API request.
    */
    public PageReference Shipping_Rate() {
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This package has already been ' + Shipment.Status__c; } else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; } else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; } else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; } else if (Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment date unavailable'; } else { errorMsg1 = '';  DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd'); Shipping_Rate_Request(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), shipmentDate);}   
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference Shipping_Rate_Request(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String shipDate) { 
    public PageReference Shipping_Rate_Request(string  fromAddress1, String toAddress1, String packList1, String shipDate) { 
        try{
            ERP7__Address__c fromAddress = (ERP7__Address__c) JSON.deserialize(fromAddress1, ERP7__Address__c.class);
            ERP7__Address__c toAddress = (ERP7__Address__c) JSON.deserialize(toAddress1, ERP7__Address__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            String BaseURL = System.Label.USPSxml1;
            system.debug('BaseURL : '+BaseURL);
            String ReturnValue = '<RateV4Request USERID="' + userName + '">';
                ReturnValue += '<Revision>2</Revision>';
                for(Integer i=1; i<=packList.size(); i++) {
                    ReturnValue += '<Package ID="'+ i +'">';
                        ReturnValue += '<Service>ALL</Service>'; // use plus FOR COMMMERCIAL SERVICES
                        ReturnValue += '<ZipOrigination>'+ upsCredentials[0].Shipper_Postal_Code__c +'</ZipOrigination>';  
                        ReturnValue += '<ZipDestination>' + toAddress.Postal_Code__c + '</ZipDestination>';
                        ReturnValue += '<Pounds>'+ Integer.valueOf(packList[i-1].Weight__c) +'</Pounds>';
                        ReturnValue += '<Ounces>00</Ounces>'; 
                        ReturnValue += '<Container>NONRECTANGULAR</Container>';
                        ReturnValue += '<Size>LARGE</Size>';
                        ReturnValue += '<Width>'+ Integer.valueOf(packList[i-1].Width__c) +'</Width>';  
                    	system.debug('Integer.valueOf(packList[i-1].Length__c) : '+Integer.valueOf(packList[i-1].Length__c));
                        ReturnValue += '<Length>'+ Integer.valueOf(packList[i-1].Length__c) +'</Length>';  
                        ReturnValue += '<Height>'+ Integer.valueOf(packList[i-1].Height__c) +'</Height>'; 
                        Integer girth = 2 * Integer.valueOf(packList[i-1].Width__c) + 2 * Integer.valueOf(packList[i-1].Height__c) ; 
                        ReturnValue += '<Girth>'+ girth +'</Girth>';
                        ReturnValue += '<Machinable>False</Machinable>';
                        ReturnValue += '<ShipDate>'+ shipDate +'</ShipDate>';
                    ReturnValue += '</Package>';
                } 
            ReturnValue += '</RateV4Request>';
            
            ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
            ReturnValue = BaseURL + ReturnValue;
            system.debug('ReturnValue : '+ReturnValue);
            HttpRequest USPSRequest = new HttpRequest();
            Http USPSHttp = new Http();
               
            USPSRequest.setMethod('GET');
            USPSRequest.setEndpoint(ReturnValue);
     
            HttpResponse USPSResponse = USPSHttp.send(USPSRequest);
            request_1  = string.valueOf(USPSRequest);
            response_1 = USPSResponse.getBody(); 
            system.debug('response_1 : '+response_1);
            resStatus  = USPSResponse.getStatus();
            system.debug('resStatus : '+resStatus);
            if(resStatus == 'OK' || Test.isRunningTest()) {
                XmlStreamReader reader = USPSResponse.getXmlStreamReader();  reader.setCoalescing(true); readXMLResponseRateTransitDetails(reader,'Package');
                if(!USPS_Returned_Error){ Result = 'Available USPS Services For The Selected Zipcodes'; time_in_cost_tab = true;  } } else Result = 'Result not available'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    public void readXMLResponseRateTransitDetails(XmlStreamReader reader, String sxmltag) {
        try {
            rateWrapper rw; rateWrapperList = new List<rateWrapper>();
            while(reader.hasNext()) {
                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { 
                    while(reader.hasNext()) {
                        rw = new rateWrapper(); 
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Error') { errorMsg1 = ParseUSPSErrorXML(reader); USPS_Returned_Error = true; break; 
                        }
                        else if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Postage') {
                            reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MailService') { reader.next();
                                rw.service = reader.getText().unescapexml();
                                reader.next(); reader.next();
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Rate') { reader.next(); rw.totalCharges = reader.getText(); reader.next(); reader.next(); }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MaxDimensions') { reader.next(); rw.currencyCode = reader.getText(); reader.next(); reader.next(); }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CommitmentDate') { reader.next(); rw.CommitmentDate = reader.getText(); } 
                            rateWrapperList.add(rw);
                        }
                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();
                    } 
                } reader.next();
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
    
    /*
      shipment & label generation API request.
    */
    public PageReference Shipping_Request() {  
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This Package Has Already Been ' + Shipment.Status__c; } else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; } else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; } else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; } else if(Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment Date Unavailable'; } else if(service == null || service == '') { errorMsg1 = 'Service Is Unavailable, Please Select At Least One Service From Shipping Service And Cost' ; } else { errorMsg1 = '';  DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd'); Shipping_Request_Reply(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), service, shipmentDate); }                    
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference Shipping_Request_Reply(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String service, String ShipDateStamp) {
    public PageReference Shipping_Request_Reply(String fromAddress1, String toAddress1, String packList1, String service, String ShipDateStamp) {
        try{ 
            system.debug('service : '+service);
            ERP7__Address__c fromAddress = (ERP7__Address__c) JSON.deserialize(fromAddress1, ERP7__Address__c.class);
            ERP7__Address__c toAddress = (ERP7__Address__c) JSON.deserialize(toAddress1, ERP7__Address__c.class);
              List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class); 
            String BaseURL = System.Label.USPSxml2;
            system.debug('BaseURL : '+BaseURL);
        	system.debug('userName : '+userName);
            String ReturnValue = '<eVSRequest USERID="' + userName + '">'; 
//ReturnValue  =+ '<Option/><Revision/><ImageParameters><LabelSequence><PackageNumber>1</PackageNumber><TotalPackages>1</TotalPackages></LabelSequence></ImageParameters><FromName>Lina Smith</FromName><FromFirm>Horizon</FromFirm><FromAddress1>Apt 303</FromAddress1><FromAddress2>1309 S Agnew Avenue</FromAddress2><FromCity>Oklahoma City</FromCity><FromState>OK</FromState><FromZip5>73108</FromZip5><FromZip4>2427</FromZip4><FromPhone>1234567890</FromPhone><POZipCode/><AllowNonCleansedOriginAddr>false</AllowNonCleansedOriginAddr><ToName>Tall Tom</ToName><ToFirm>ABC Corp.</ToFirm><ToAddress1/><ToAddress2>1098 N Fraser Street</ToAddress2><ToCity>Georgetown</ToCity><ToState>SC</ToState><ToZip5>29440</ToZip5><ToZip4>2849</ToZip4><ToPhone>8005554526</ToPhone><POBox/>';
//ReturnValue  =+ '<ToContactPreference>email</ToContactPreference><ToContactMessaging/><ToContactEMail>talltom@aol.com</ToContactEMail><AllowNonCleansedDestAddr>false</AllowNonCleansedDestAddr><WeightInOunces>32</WeightInOunces><ServiceType>PRIORITY</ServiceType><Container>VARIABLE</Container><Width>5.5</Width><Length>11</Length><Height>11</Height><Machinable>TRUE</Machinable><ProcessingCategory/><PriceOptions/><InsuredAmount>100.00</InsuredAmount><AddressServiceRequested>true</AddressServiceRequested><ExpressMailOptions><DeliveryOption/><WaiverOfSignature/></ExpressMailOptions><ShipDate></ShipDate><CustomerRefNo>EF789UJK</CustomerRefNo><CustomerRefNo2>EE66GG87</CustomerRefNo2><ExtraServices><ExtraService>120</ExtraService></ExtraServices><HoldForPickup/><OpenDistribute/><PermitNumber/><PermitZIPCode/><PermitHolderName/><CRID>4569873</CRID><MID>456789354</MID><VendorCode>1234</VendorCode><VendorProductVersionNumber>5.02.1B</VendorProductVersionNumber><SenderName>Adam Johnson</SenderName><SenderEMail>Adam1234d@aol.com</SenderEMail><RecipientName>Robert Jones</RecipientName><RecipientEMail>bobjones@aol.com</RecipientEMail><ReceiptOption>SAME PAGE</ReceiptOption><ImageType>PDF</ImageType><HoldForManifest>N</HoldForManifest><NineDigitRoutingZip>false</NineDigitRoutingZip><ShipInfo>True</ShipInfo><CarrierRelease>False</CarrierRelease><DropOffTime/><ReturnCommitments>True</ReturnCommitments><PrintCustomerRefNo>False</PrintCustomerRefNo><PrintCustomerRefNo2>True</PrintCustomerRefNo2><Content><ContentType>Perishable</ContentType><ContentDescription>Other</ContentDescription></Content><ActionCode>M0</ActionCode><OptOutOfSPE>false</OptOutOfSPE><SortationLevel/><DestinationEntryFacilityType/>';


                for(Integer i=1; i<=packList.size(); i++) {
                    ReturnValue += '<ImageParameters>';
                        ReturnValue += '<ImageParameter>4X6LABEL</ImageParameter>';
                            ReturnValue += '<LabelSequence>';
                                ReturnValue += '<PackageNumber>'+ i +'</PackageNumber>';
                                ReturnValue += '<TotalPackages>'+ packList.size() +'</TotalPackages>';
                            ReturnValue += '</LabelSequence>';
                    ReturnValue += '</ImageParameters>';
                    if(upsCredentials != null && upsCredentials.size() > 0) { 
                        ReturnValue += '<FromName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</FromName>';
                        ReturnValue += '<FromFirm>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</FromFirm>'; 
                        ReturnValue += '<FromAddress1>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</FromAddress1>';
                        ReturnValue += '<FromAddress2>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</FromAddress2>';
                        ReturnValue += '<FromCity>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</FromCity>';
                        if(shipperProvinceCode != null) ReturnValue += '<FromState>'+ shipperProvinceCode.escapeXml() +'</FromState>';
                        ReturnValue += '<FromZip5>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</FromZip5>';
                        ReturnValue += '<FromZip4>'+ upsCredentials[0].Shipper_Zip4__c.escapeXml() +'</FromZip4>';
                        ReturnValue += '<FromPhone>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</FromPhone>';
                    }
                    if(toAddress != null) {
                        ReturnValue += '<ToName>'+ toAddress.Contact__r.Name.escapeXml() +'</ToName>';
                        ReturnValue += '<ToFirm>'+ toAddress.Contact__r.Company__c.escapeXml() +'</ToFirm>';
                        ReturnValue += '<ToAddress1>' + toAddress.Address_Line1__c.escapeXml() + '</ToAddress1>';
                        system.debug('toAddress.Address_Line2__c.escapeXml() : '+toAddress);
                        if(toAddress.Address_Line2__c != null && toAddress.Address_Line2__c != '') ReturnValue += '<ToAddress2>' + toAddress.Address_Line2__c.escapeXml() + '</ToAddress2>';
                        ReturnValue += '<ToCity>' + toAddress.City__c.escapeXml() + '</ToCity>';
                        if(DestinationProvinceCode != null) ReturnValue += '<ToState>' + DestinationProvinceCode.escapeXml() + '</ToState>';
                        ReturnValue += '<ToZip5>' + toAddress.Postal_Code__c.escapeXml() + '</ToZip5>';
                        if(toAddress.Zip_4__c != null && toAddress.Zip_4__c != '') ReturnValue += '<ToZip4>' + toAddress.Zip_4__c.escapeXml() + '</ToZip4>';
                        ReturnValue += '<ToPhone>'+ toAddress.Contact__r.Phone.escapeXml() +'</ToPhone>';
                    }
                    ReturnValue += '<WeightInOunces>'+ Integer.valueOf(packList[i-1].Weight__c) +'</WeightInOunces>';
                    ReturnValue += '<ServiceType>' + service + '</ServiceType>';
                    ReturnValue += '<Container>NONRECTANGULAR</Container>';
                    ReturnValue += '<Width>'+ Integer.valueOf(packList[i-1].Width__c) +'</Width>';
                    ReturnValue += '<Length>'+ Integer.valueOf(packList[i-1].Length__c) +'</Length>';
                    ReturnValue += '<Height>'+ Integer.valueOf(packList[i-1].Height__c) +'</Height>';
                    ReturnValue += '<ShipDate>'+ ShipDateStamp +'</ShipDate>';
                    ReturnValue += '<SenderName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</SenderName>';
                    ReturnValue += '<SenderEMail>'+ upsCredentials[0].Shipper_Email__c.escapeXml() +'</SenderEMail>';
                    ReturnValue += '<RecipientName>'+ toAddress.Contact__r.Name.escapeXml() +'</RecipientName>';
                    ReturnValue += '<RecipientEMail>'+ toAddress.Contact__r.Email.escapeXml() +'</RecipientEMail>';
                    ReturnValue += '<ImageType>TIF</ImageType>';
                }
            ReturnValue += '</eVSRequest>';       
            
            
            ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
            ReturnValue = BaseURL + ReturnValue;
            
            HttpRequest USPSRequest = new HttpRequest();      
            Http USPSHttp = new Http();
            USPSRequest.setHeader('Content-Length', '0'); 
            USPSRequest.setMethod('POST');
            USPSRequest.setEndpoint(ReturnValue);
            
     
            HttpResponse USPSResponse = USPSHttp.send(USPSRequest);
            request_1  = ReturnValue;
            response_1 = USPSResponse.getBody();
            resStatus  = USPSResponse.getStatus();
            system.debug('request_1 : '+request_1);
            system.debug('response_1 : '+response_1);
            List<String> trackingNoList = new List<String>(); 
            List<String> shipmentImageLists = new List<String>();
            system.debug('resStatus : '+resStatus);
            if(resStatus == 'OK' || Test.isRunningTest()) {
                XmlStreamReader reader0 = USPSResponse.getXmlStreamReader();
                String msg = readXMLResponse(reader0, 'Error');
                if(msg != null && msg != '' && msg == 'Error'){ errorMsg1 = ParseUSPSErrorXML(reader0); USPS_Returned_Error = true; }
                if(!USPS_Returned_Error){
                    XmlStreamReader reader = USPSResponse.getXmlStreamReader();
                    while(reader.hasNext()){
                        if(reader.isStartElement()){ if(reader.getLocalName() == 'BarcodeNumber'){ if(!reader.isCharacters()) reader.next();   trackingNoList.add(reader.getText()); } }
                        if(reader.isEndElement() && reader.getLocalName() == 'eVSCertifyResponse')break;
                        reader.next();
                    }
    
                    XmlStreamReader reader1 = USPSResponse.getXmlStreamReader(); while(reader1.hasNext()){ if(reader1.isStartElement()){ if(reader1.getLocalName() == 'LabelImage'){ if(!reader1.isCharacters()) reader1.next(); shipmentImageLists.add(reader1.getText()); } } if(reader1.isEndElement() && reader1.getLocalName() == 'eVSCertifyResponse') break; reader1.next(); }
    
                    XmlStreamReader reader2 = USPSResponse.getXmlStreamReader(); amount = readXMLResponse(reader2, 'Postage');
                      
                    Id RTID; RTID = Schema.SObjectType.ERP7__Shipment__c.getRecordTypeInfosByDeveloperName().get('USPS_Shipping').getRecordTypeId();  

                    if(amount != Null && amount != '') {
                        if(Schema.sObjectType.Shipment__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Active__c.isUpdateable()) { Shipment.Active__c = true; } if(Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isUpdateable()) { Shipment.Billing_Address__c = toAddress.Id; } if(Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer__c.isUpdateable() && Shipment.Customer__c == Null) Shipment.Customer__c = toAddress.Customer__c; if(Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isUpdateable()) { Shipment.Customer_Contact__c = toAddress.Contact__c; } if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipment.Status__c = 'Shipped'; } if(Schema.sObjectType.Shipment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment__c.fields.RecordTypeId.isUpdateable() && RTID != null) { Shipment.RecordTypeId = RTID; } if(Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isUpdateable()) { Shipment.Shipping_Address__c = toAddress.Id; } if(recordIdMap.get('LO') != null) { if(Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable()) Shipment.Logistic__c = recordIdMap.get('LO'); if(packList != null && packList.size() > 0){  if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = packList[0].Logistic__r.Sales_Order__c; } } if(recordIdMap.get('SO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name =  'SO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = recordIdMap.get('SO'); } if(recordIdMap.get('WO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'WO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isUpdateable()) Shipment.Work_Order__c = recordIdMap.get('WO'); } if(recordIdMap.get('PO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'PO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isUpdateable()) Shipment.Purchase_Orders__c = recordIdMap.get('PO'); } if(recordIdMap.get('TO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'TO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isUpdateable()) Shipment.Transfer_Order__c = recordIdMap.get('TO'); } if(recordIdMap.get('SR') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'SR-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable()) Shipment.Return_Merchandise_Authorisation__c = recordIdMap.get('SR'); } if(Schema.sObjectType.Shipment__c.fields.USPS_Service__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.USPS_Service__c.isUpdateable()) { Shipment.USPS_Service__c = service; } if(Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isUpdateable()) { Shipment.Shipping_Amount__c = (amount != '') ? Decimal.valueOf(amount) : 0.00; } if(Schema.sObjectType.Shipment__C.fields.Number_Of_Pieces_In_Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isUpdateable()) Shipment.Number_Of_Pieces_In_Shipment__c = String.valueof(Packages.size()); if(Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isUpdateable()) { for(String s: trackingNoList) { if(Shipment.Tracking_Number__c == null) Shipment.Tracking_Number__c = s; else Shipment.Tracking_Number__c += ',' + s; } }
                        if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Shipment; }else{ }
                        
                        // Adding below code to assign tracking number in sales order.
                        ERP7__Sales_Order__c SalesOrder = new ERP7__Sales_Order__c(); SalesOrder = Database.query('select Id, Name, ERP7__Tracking_Number__c from ERP7__Sales_Order__c where (Id =\'' + String.escapeSingleQuotes(packList[0].Logistic__r.Sales_Order__r.Id) + '\') Limit 1'); if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isUpdateable()) { for(String s: trackingNoList) { if(SalesOrder.ERP7__Tracking_Number__c == null) SalesOrder.ERP7__Tracking_Number__c = s; else SalesOrder.ERP7__Tracking_Number__c += ', ' + s; } } if(Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; update SalesOrder; }else{ }
                        // Additional code ends.
                        
                         // updating tracking number in corresponding packages.
                        for(Integer i=0; i<packList.size(); i++) { if(Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()) packList[i].Shipment__c = Shipment.Id; if(Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) packList[i].Status__c = Shipment.Status__c; if(trackingNoList.size() > i){ if(Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable()) packList[i].Tracking_Number__c = trackingNoList[i]; } } if(packList.size() > 0 && Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()){hasAccess=true; upsert packList;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                        // creating USPS label attachments and associating to new shipment created.
                        List<attachment> attList = new List<attachment>(); if(shipmentImageLists.size() > 0) { for(Integer i=1; i<=shipmentImageLists.size(); i++) { attachment att = new attachment(); if(Schema.sObjectType.attachment.fields.Name.isCreateable() && Schema.sObjectType.attachment.fields.Name.isUpdateable()) att.Name = 'USPS_Label_'+i; if(Schema.sObjectType.attachment.fields.parentId.isCreateable() && Schema.sObjectType.attachment.fields.parentId.isUpdateable()) att.parentId = Shipment.Id; if(Schema.sObjectType.attachment.fields.ContentType.isCreateable() && Schema.sObjectType.attachment.fields.ContentType.isUpdateable()) att.ContentType = 'image/tiff'; if(Schema.sObjectType.attachment.fields.body.isCreateable() && Schema.sObjectType.attachment.fields.body.isUpdateable()) { att.body = EncodingUtil.base64Decode(shipmentImageLists[i-1]); } attList.add(att); } } if(attList.size() > 0 && Schema.sObjectType.attachment.isCreateable() && Schema.sObjectType.attachment.isUpdateable()){hasAccess=true; upsert attList;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Id =\'' + String.escapeSingleQuotes(Shipment.Id) + '\') Limit 1'); attList = new List<attachment>(); shipmentImageLists = new List<String>(); Result = 'Package Shipped Successfully'; time_in_cost_tab = false; for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9){ showAndHideMap.put(i, false);} else {showAndHideMap.put(i, true);} }
                    }
                }
            }  else Result = 'Result not available';
         
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      cancel shipping API request.
    */
    public PageReference Cancel_Request() {
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Unavailable'; } 
            else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Request To Cancel Shipment Cannot Be Processed'; } 
            else if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Active Thus, Request To Cancel The Shipment Cannot Be Processed'; } 
            else { errorMsg1 = ''; /*Cancel_Request_Reply(Shipment, packages); */Cancel_Request_Reply(JSON.serialize(Shipment), JSON.serialize(packages));} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference Cancel_Request_Reply(Shipment__c shipments, List<Package__c> packList) {
    public PageReference Cancel_Request_Reply(String shipments1, String packList1) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            String BaseURL = System.Label.USPSxml3;
            
            String ReturnValue = '<eVSCancelRequest USERID="' + userName + '">';
                ReturnValue += '<BarcodeNumber>'+ shipments.Tracking_Number__c.escapeXml() +'</BarcodeNumber>';
            ReturnValue += '</eVSCancelRequest>';
            
            ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
            ReturnValue = BaseURL + ReturnValue;
            
            HttpRequest USPSRequest = new HttpRequest();
            Http USPSHttp = new Http();
               
            USPSRequest.setMethod('POST');
            USPSRequest.setEndpoint(ReturnValue);
     
            HttpResponse USPSResponse = USPSHttp.send(USPSRequest);
            request_1  = string.valueOf(USPSRequest);
            response_1 = USPSResponse.getBody(); 
            resStatus  = USPSResponse.getStatus();
            
            if(resStatus == 'OK'  || Test.isRunningTest()) { 
                XmlStreamReader reader = USPSResponse.getXmlStreamReader(); String Reason = readXMLResponse(reader, 'Reason');
                if(Reason == 'Order Cancelled Successfully'){ if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipments.Status__c = 'Cancelled'; } if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()){hasAccess=true; upsert Shipments;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } if(packList != null && packList.size() > 0 && Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) { for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } hasAccess=true; upsert packList; } else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } Shipment = new Shipment__c();  Result = 'Order Cancelled Successfully'; for(Integer i=1; i<=7; i++) { if(i==1) showAndHideMap.put(i, true); else showAndHideMap.put(i, false);} } 
                else  Result = 'Request to cancel shipment cannot be processed : ' + Reason; } else Result = 'Result not available'; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      pickup availability API request.
    */
    public PageReference PickupAvailability() {
        try { 
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Already Active For This Package'; } 
            else if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 
            else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Shipment Status Must Be shipped To Process, Pickup Rate Request'; } 
            else if(Shipment.Package_Ready_Time__c == null) { errorMsg1 = 'Package Ready Time Unavailable'; } 
            else if(Shipment.Package_Ready_Time__c < System.Now()) { errorMsg1 = 'Package Ready Time Invalid'; }
            else { errorMsg1 = '';  DateTime PRT = Shipment.Package_Ready_Time__c;
                   String PackageReadyTime = PRT.format('yyyy-MM-dd\'T\'HH:mm:ss');
                   /*PickupAvailability_Reply(fromAddress, packages, shipment, PackageReadyTime);*/ 
                 PickupAvailability_Reply(JSON.serialize(fromAddress), JSON.serialize(packages), JSON.serialize(shipment), PackageReadyTime); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;  
    }
    //public PageReference PickupAvailability_Reply(Address__c fromAddress, List<Package__c> packList, Shipment__c shipments, String PackageReadyTime) {
    public PageReference PickupAvailability_Reply(String fromAddress1, String packList1, String shipments1, String PackageReadyTime) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Shipment__c.class); List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class); String BaseURL = System.Label.USPSxml4; String ReturnValue = '<CarrierPickupAvailabilityRequest USERID="' + userName + '">'; ReturnValue += '<FirmName>'+ fromAddress.Contact__r.Company__c.escapeXml() +'</FirmName>'; ReturnValue += '<SuiteOrApt></SuiteOrApt>'; if(OriginStreet != null) ReturnValue += '<Address2>'+ OriginStreet.escapeXml() +'</Address2>'; ReturnValue += '<Urbanization></Urbanization>'; if(fromAddress.City__c != null) ReturnValue += '<City>'+ fromAddress.City__c.escapeXml() +'</City>'; if(originProvinceCode != null) ReturnValue += '<State>'+ originProvinceCode.escapeXml() +'</State>'; if(fromAddress.Postal_Code__c != null) ReturnValue += '<ZIP5>'+ fromAddress.Postal_Code__c.escapeXml() +'</ZIP5>'; if(fromAddress.Zip_4__c != null) ReturnValue += '<ZIP4>'+ fromAddress.Zip_4__c.escapeXml() +'</ZIP4>'; ReturnValue += '<Date>' + PackageReadyTime + '</Date>'; ReturnValue += '</CarrierPickupAvailabilityRequest>'; ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8'); ReturnValue = BaseURL + ReturnValue; HttpRequest USPSRequest = new HttpRequest(); Http USPSHttp = new Http(); USPSRequest.setMethod('POST'); USPSRequest.setEndpoint(ReturnValue); HttpResponse USPSResponse = USPSHttp.send(USPSRequest); request_1  = string.valueOf(USPSRequest); response_1 = USPSResponse.getBody(); resStatus  = USPSResponse.getStatus(); if(resStatus == 'OK' || Test.isRunningTest()) { XmlStreamReader reader1 = USPSResponse.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Error'); if(msg != null && msg != '' && msg == 'Error'){ errorMsg1 = ParseUSPSErrorXML(reader1); USPS_Returned_Error = true; } if(!USPS_Returned_Error){ Result = 'Shipment Pickup for this package is available'; } } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      create pickup API request.
    */
    public PageReference CreatePickup() {
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Already Active For This Package'; } 
            else if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 
            else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Shipment Status Must Be Shipped To Process, Create Pickup Request'; } 
            else if(Shipment.Package_Ready_Time__c == null) { errorMsg1 = 'Package Ready Time Unavailable'; }
            else if(Shipment.Package_Ready_Time__c < System.Now()) { errorMsg1 = 'Package Ready Time Invalid'; } 
            
            else {    errorMsg1 = '';  DateTime PRT = Shipment.Package_Ready_Time__c;
                      String PackageReadyTime = PRT.format('yyyy-MM-dd\'T\'HH:mm:ss');
                      /*CreatePickup_Reply(fromAddress, packages, shipment, PackageReadyTime); */
                  CreatePickup_Reply(JSON.serialize(fromAddress), JSON.serialize(packages), JSON.serialize(shipment), PackageReadyTime);
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference CreatePickup_Reply(Address__c fromAddress, List<Package__c> packList, Shipment__c shipments, String PackageReadyTime) {
    public PageReference CreatePickup_Reply(String fromAddress1, String packList1, String shipments1, String PackageReadyTime) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Shipment__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class); String BaseURL = System.Label.USPSxml5; String ReturnValue = '<CarrierPickupScheduleRequest USERID="' + userName + '">'; ReturnValue += '<FirstName>'+ fromAddress.Contact__r.FirstName +'</FirstName>'; ReturnValue += '<LastName>'+ fromAddress.Contact__r.LastName +'</LastName>'; ReturnValue += '<FirmName>'+ fromAddress.Contact__r.Company__c +'</FirmName>'; ReturnValue += '<SuiteOrApt></SuiteOrApt>'; if(OriginStreet != null) ReturnValue += '<Address2>'+ OriginStreet.escapeXml() +'</Address2>'; ReturnValue += '<Urbanization></Urbanization>'; if(fromAddress.City__c != null) ReturnValue += '<City>'+ fromAddress.City__c.escapeXml() +'</City>'; if(originProvinceCode != null) ReturnValue += '<State>'+ originProvinceCode.escapeXml() +'</State>'; if(fromAddress.Postal_Code__c != null) ReturnValue += '<ZIP5>'+ fromAddress.Postal_Code__c.escapeXml() +'</ZIP5>'; if(fromAddress.Zip_4__c != null) ReturnValue += '<ZIP4>'+ fromAddress.Zip_4__c.escapeXml() +'</ZIP4>'; ReturnValue += '<Phone>'+ fromAddress.Contact__r.Phone +'</Phone>'; ReturnValue += '<Extension></Extension>'; ReturnValue += '<Package>'; ReturnValue += '<ServiceType>'+ shipments.USPS_Services__c +'</ServiceType>'; if(packList != null && packList.size() > 0) ReturnValue += '<Count>'+ packList.size() +'</Count>'; ReturnValue += '</Package>'; ReturnValue += '<EstimatedWeight>' + toalWeightValue + '</EstimatedWeight>'; ReturnValue += '<PackageLocation>Front Door</PackageLocation>'; ReturnValue += '<SpecialInstructions>Packages are behind the screen door.</SpecialInstructions>'; ReturnValue += '</CarrierPickupScheduleRequest>'; ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8'); ReturnValue = BaseURL + ReturnValue; HttpRequest USPSRequest = new HttpRequest(); Http USPSHttp = new Http(); USPSRequest.setMethod('POST'); USPSRequest.setEndpoint(ReturnValue); HttpResponse USPSResponse = USPSHttp.send(USPSRequest); request_1  = string.valueOf(USPSRequest); response_1 = USPSResponse.getBody(); resStatus  = USPSResponse.getStatus(); if(resStatus == 'OK' || Test.isRunningTest()) { XmlStreamReader reader1 = USPSResponse.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Error'); if(msg != null && msg != '' && msg == 'Error'){ errorMsg1 = ParseUSPSErrorXML(reader1); USPS_Returned_Error = true; } if(!USPS_Returned_Error){ XmlStreamReader reader = USPSResponse.getXmlStreamReader(); String PickupConfirmNumber = readXMLResponse(reader, 'ConfirmationNumber'); XmlStreamReader reader2 = USPSResponse.getXmlStreamReader(); String CarrierRoute = readXMLResponse(reader2, 'CarrierRoute'); if(PickupConfirmNumber != Null && CarrierRoute != Null) { Result = 'Shipment Pickup for this package created successfully'; if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Picked Up'; } if(Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isUpdateable()) { Shipments.Pickup_Confirmation_Number__c = PickupConfirmNumber; } if(Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isUpdateable()) { Shipments.Pickup_Location__c = CarrierRoute; } if(Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isUpdateable()) { Shipments.Pickup_Requested__c = true; } if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()){hasAccess=true; upsert Shipments;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { if(Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) pac.Status__c = shipments.Status__c; } if(Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()) upsert packList; else{ } } for(Integer i=1; i<=7; i++) { if(i==7 || i==2) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); } } } } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      cancel pickup API request.
    */
    public PageReference CancelPickup() {
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Delivered') errorMsg1 = 'Shipment delivered : Request cannot be processed';
            else if(Shipment.Pickup_Requested__c == false) errorMsg1 = 'Shipment Pickup unavailable to cancel';
            else if(Shipment.Pickup_Confirmation_Number__c == null || Shipment.Pickup_Confirmation_Number__c == '') errorMsg1 = 'Pickup Confirmation Number is required to cancel shipment pickup';
            else {  errorMsg1 = '';  
                    /*CancelPickup_Reply(fromAddress, shipment, packages);*/
                 CancelPickup_Reply(JSON.serialize(fromAddress), JSON.serialize(shipment), JSON.serialize(packages));} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference CancelPickup_Reply(Address__c fromAddress, Shipment__c shipments, List<Package__c> packList) {
    public PageReference CancelPickup_Reply(String fromAddress1, String shipments1, String packList1) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Shipment__c.class); List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class); String BaseURL = System.Label.USPSxml6; String ReturnValue = '<CarrierPickupCancelRequest USERID="' + userName + '">'; ReturnValue += '<FirmName>'+ fromAddress.Contact__r.Company__c.escapeXml() +'</FirmName>'; ReturnValue += '<SuiteOrApt></SuiteOrApt>'; if(OriginStreet != null) ReturnValue += '<Address2>'+ OriginStreet.escapeXml() +'</Address2>'; ReturnValue += '<Urbanization></Urbanization>'; if(fromAddress.City__c != null) ReturnValue += '<City>'+ fromAddress.City__c.escapeXml() +'</City>'; if(originProvinceCode != null) ReturnValue += '<State>'+ originProvinceCode.escapeXml() +'</State>'; if(fromAddress.Postal_Code__c != null) ReturnValue += '<ZIP5>'+ fromAddress.Postal_Code__c.escapeXml() +'</ZIP5>'; if(fromAddress.Zip_4__c != null) ReturnValue += '<ZIP4>'+ fromAddress.Zip_4__c.escapeXml() +'</ZIP4>'; ReturnValue += '<ConfirmationNumber>'+ Shipments.Pickup_Confirmation_Number__c +'</ConfirmationNumber>'; ReturnValue += '</CarrierPickupCancelRequest>'; ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8'); ReturnValue = BaseURL + ReturnValue; HttpRequest USPSRequest = new HttpRequest(); Http USPSHttp = new Http(); USPSRequest.setMethod('POST'); USPSRequest.setEndpoint(ReturnValue); HttpResponse USPSResponse = USPSHttp.send(USPSRequest); request_1  = string.valueOf(USPSRequest); response_1 = USPSResponse.getBody(); resStatus  = USPSResponse.getStatus(); if(resStatus == 'OK' || Test.isRunningTest()) { XmlStreamReader reader1 = USPSResponse.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Error'); if(msg != null && msg != '' && msg == 'Error'){ errorMsg1 = ParseUSPSErrorXML(reader1); USPS_Returned_Error = true; } if(!USPS_Returned_Error){ XmlStreamReader reader = USPSResponse.getXmlStreamReader(); String Status = readXMLResponse(reader, 'Status'); if(Status == 'Your pickup request was cancelled.') { Result = 'Shipment Pickup for this package cancelled successfully'; if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Shipped'; } if(Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isUpdateable()) { Shipments.Pickup_Confirmation_Number__c = null; } if(Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isUpdateable()) { Shipments.Pickup_Location__c = null; } if(Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isUpdateable()) { Shipments.Pickup_Requested__c = false; } if(Schema.sObjectType.Shipment__c.fields.Package_Ready_Time__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Package_Ready_Time__c.isUpdateable()) { Shipments.Package_Ready_Time__c = null; } if(Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.SObjectType.Shipment__c.isCreateable() && Schema.SObjectType.Shipment__c.isUpdateable()){hasAccess=true; upsert Shipments;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } if(packList != null && packList.size() > 0 && Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) { for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } hasAccess=true; upsert packList; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } for(Integer i=1; i<=7; i++) { if(i==4 || i==5) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); } } } } else Result = 'Result not available';
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      shipment tracking API request.
    */
    public PageReference Track_Request() {
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; }             
            if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Unavailable'; }            
            else { errorMsg1 = '';  /*Track_Request_Reply(shipment, packages); */Track_Request_Reply(JSON.serialize(shipment), JSON.serialize(packages));} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
   // public PageReference Track_Request_Reply(Shipment__c shipments, List<Package__c> packList) {
    public PageReference Track_Request_Reply(String shipments1, String packList1) {
        try {
            Shipment__c shipments = (Shipment__c) JSON.deserialize(shipments1, Shipment__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            String BaseURL = System.Label.USPSxml7;
          
            String ReturnValue = '<TrackFieldRequest USERID="' + userName + '">';
                ReturnValue += '<TrackID ID="'+ shipments.Tracking_Number__c +'"></TrackID>';  //9102969010383081813033   EJ123456780US
            ReturnValue += '</TrackFieldRequest>';
            
            ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
            ReturnValue = BaseURL + ReturnValue;
            
            HttpRequest USPSRequest = new HttpRequest();
            Http USPSHttp = new Http();
               
            USPSRequest.setMethod('POST');
            USPSRequest.setEndpoint(ReturnValue);
     
            HttpResponse USPSResponse = USPSHttp.send(USPSRequest);
            request_1  = string.valueOf(USPSRequest);
            response_1 = USPSResponse.getBody(); 
            resStatus  = USPSResponse.getStatus();
            
            if(resStatus == 'OK'  || Test.isRunningTest()) {
                XmlStreamReader reader = USPSResponse.getXmlStreamReader();
                reader.setCoalescing(true);
                readXMLResponseTrackHistory(reader,'TrackResponse');
                if(!USPS_Returned_Error){
                    List<Shipment_Flow__c> existingSFList;  Map<String, Shipment_Flow__c> sfMap = new Map<String, Shipment_Flow__c>();
                    if(Shipment != null) { 
                        for(Shipment_Flow__c sf: [select Id, Name, Shipment__c, Shipment_DateTime__c, Description__c, Shipment_Flow_Start_Date__c, 
                                                  Shipment_Flow_End_Date__c from Shipment_Flow__c where Shipment__c =: Shipment.Id Order by Name Asc]) {  sfMap.put(sf.Shipment_DateTime__c, sf); }
                    }
                    for(Integer i=0; i<trackWrapperList.size(); i++) { Shipment_Flow__c sf = new Shipment_Flow__c(Shipment_DateTime__c = String.valueof(trackWrapperList[i].dtValue)); if(!sfMap.keyset().contains(String.valueof(trackWrapperList[i].dtValue))) { if(Schema.sObjectType.Shipment_Flow__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) sf.Name = 'Shipment Flow ' +Shipments.Tracking_Number__c +' ' + i; if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isUpdateable()) if(Shipments != null) sf.Shipment__c = Shipments.Id; if(Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isUpdateable()) sf.Active__c = true; if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isUpdateable()) if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_Start_Date__c = Datetime.valueof(trackWrapperList[i].dtValue); if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isUpdateable()) if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_End_Date__c = Datetime.valueof(trackWrapperList[i].dtValue); if(Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isUpdateable()) if(trackWrapperList[i].Event != null) sf.Description__c = trackWrapperList[i].Event; if(trackWrapperList[i].Event != null && trackWrapperList[i].Event.contains('Delivered')){ if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) Shipments.Status__c = 'Delivered';} sfMap.put(String.valueof(trackWrapperList[i].dtValue), sf); } }
                    if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable()){hasAccess=true; upsert Shipments; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    
                    if(packList != null && packList.size() > 0 && Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) { for(Package__c pac : packList) { pac.Status__c = Shipments.Status__c; } hasAccess=true; upsert packList; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    
                    if(sfMap.size() > 0 && Schema.SObjectType.Shipment_Flow__c.isCreateable() && Schema.SObjectType.Shipment_Flow__c.isUpdateable()) upsert sfMap.values(); else{ }
                    if(Shipments.Status__c == 'Delivered') showAndHideMap.put(8, true); Result = 'Track Shipment Activities';          
                }
            } else Result = 'Result not available';
            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
     
    public DateTime getConvertDateTime(string strDT){
        Map<string,integer> MapMonthList = new Map<string,integer>();
        MapMonthList.put('January',1);
        MapMonthList.put('February',2);
        MapMonthList.put('March',3);
        MapMonthList.put('April',4);
        MapMonthList.put('May',5);
        MapMonthList.put('June',6);
        MapMonthList.put('July',7);
        MapMonthList.put('August',8);
        MapMonthList.put('September',9);
        MapMonthList.put('October',10);
        MapMonthList.put('November',11);
        MapMonthList.put('December',12);
    
        String[] strDTDivided = strDT.split(' ');
        
        string month = String.ValueOf(MapMonthList.get(strDTDivided.get(0)));
        string day = strDTDivided.get(1).replace(',', '');
        string year = strDTDivided.get(2);
        string hour = strDTDivided.get(3).split(':').get(0);
        string minute = strDTDivided.get(3).split(':').get(1);
        string second = '00';
        
        if (strDTDivided.get(4) == 'PM' && hour != '12'){ hour = String.ValueOf(Integer.ValueOf(hour) + 12); }
        string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;
        
        return datetime.valueOf(stringDate);
    }
    
    public void readXMLResponseTrackHistory(XmlStreamReader reader, String sxmltag) {
        try {
            trackwrapper tw; trackwrapperlist = new List<trackwrapper>();
            
            while(reader.hasNext()) {
                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { 
                    while(reader.hasNext()) { 
                        tw = new trackwrapper(); 
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Error') { errorMsg1 = ParseUSPSErrorXML(reader); USPS_Returned_Error = true; break; }
                        else if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TrackDetail') { 
                            reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventTime') { reader.next();
                                tw.EventTime = reader.getText(); reader.next(); reader.next();
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventDate') { reader.next();
                                tw.EventDate = reader.getText(); reader.next(); reader.next();
                            }
                            
                            string datetimevalue = tw.EventDate + ' ' + tw.EventTime;
                            tw.dtValue = getConvertDateTime(datetimevalue).addHours(1);
                            
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Event') { reader.next();
                                tw.Event = reader.getText(); reader.next(); reader.next();
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventCity') { reader.next();
                                tw.EventCity = reader.getText(); reader.next(); reader.next();
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventState') { reader.next();
                                if(reader.hasText()) { tw.EventState = reader.getText(); reader.next(); reader.next(); }
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventZIPCode') { reader.next();
                                if(reader.hasText()) tw.EventZIPCode = reader.getText();
                            } 
                            trackwrapperlist.add(tw);
                        }
                        else if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TrackSummary') { 
                            reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventTime') { reader.next();
                                tw.EventTime = reader.getText(); reader.next(); reader.next();
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventDate') { reader.next();
                                tw.EventDate = reader.getText(); reader.next(); reader.next();
                            }
                            string datetimevalue = tw.EventDate + ' ' + tw.EventTime;
                            tw.dtValue = getConvertDateTime(datetimevalue).addHours(1);
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Event') { reader.next();
                                tw.Event = reader.getText(); reader.next(); reader.next();
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventCity') { reader.next();
                                tw.EventCity = reader.getText(); reader.next(); reader.next();
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventState') { reader.next();
                                if(reader.hasText()) { tw.EventState = reader.getText(); reader.next(); reader.next(); }
                            }
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'EventZIPCode') { reader.next();
                                if(reader.hasText()) tw.EventZIPCode = reader.getText();
                            } 
                            trackwrapperlist.add(tw);
                        }
                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();
                    } 
                } reader.next();
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
     
    /*
      signature proof API request.
    */
    public PageReference Signature_Proof() {
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == '' || Shipment.Status__c == Null) errorMsg1 = 'The shipment is unavailable';
            else if(Shipment.Status__c != 'Delivered') errorMsg1 = 'Request to get signature proof of delivery for this shipment cannot be processed';
            else {  
                errorMsg1 = ''; DateTime dt = Shipment.Shipment_Date__c;
                String shipmentDate = dt.format('yyyy-MM-dd'); 
                Signature_Proof_Reply(JSON.serialize(Shipment), shipmentDate,JSON.serialize(fromAddress)); }            } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public PageReference Signature_Proof_Reply(String Shipment1, String shipDate, String fromAddress1) {
        try {
            Shipment__c  Shipment = (Shipment__c) JSON.deserialize(Shipment1, Shipment__c.class);
            Address__c  fromAddress = (Address__c) JSON.deserialize(fromAddress1, Address__c.class);
            String BaseURL = System.Label.USPSxml8;
            
            String ReturnValue = '<PTSPodRequest USERID="' + userName + '">';
                ReturnValue += '<TrackId>'+ Shipment.Tracking_Number__c +'</TrackId >';
                //ReturnValue += '<ClientIp>127.0.0.1</ClientIp>';
                ReturnValue += '<MpSuffix>9402</MpSuffix>';
                ReturnValue += '<MpDate>2009-07-02 00:42:23.35744</MpDate>';
                ReturnValue += '<RequestType>Email</RequestType>';
                ReturnValue += '<FirstName>'+ fromAddress.Contact__r.FirstName +'</FirstName>';
                ReturnValue += '<LastName>'+ fromAddress.Contact__r.LastName +'</LastName>';
                ReturnValue += '<Email1>'+ fromAddress.Contact__r.Email +'</Email1>';
                ReturnValue += '<Email2></Email2>';
                ReturnValue += '<Email3></Email3>';
                ReturnValue += '<TableCode>T</TableCode>';
            ReturnValue += '</PTSPodRequest>';
            
            ReturnValue = EncodingUtil.urlEncode(ReturnValue, 'UTF-8');
            ReturnValue = BaseURL + ReturnValue;
            
            HttpRequest USPSRequest = new HttpRequest();
            Http USPSHttp = new Http();
               
            USPSRequest.setMethod('POST');
            USPSRequest.setEndpoint(ReturnValue);
     
            HttpResponse USPSResponse = USPSHttp.send(USPSRequest); request_1  = string.valueOf(USPSRequest); response_1 = USPSResponse.getBody();  resStatus  = USPSResponse.getStatus();
        
            if(resStatus == 'OK' ) { XmlStreamReader reader = USPSResponse.getXmlStreamReader(); String ReturnCode = readXMLResponse(reader, 'ReturnCode'); if(ReturnCode == '0'){ showAndHideMap.put(9, true); Result = 'Your Proof of Delivery record is complete and will be processed shortly'; } } else Result = 'Result not available';
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
        public String totalCharges                 { get; set; }
        public String currencyCode                 { get; set; }   
        public String totalSurcharges              { get; set; }   
        public String CommitmentDate               { get; set; }
        public String USPS_ERROR_DESC              { get; set; }   
        public String USPS_ERROR_SOURCE            { get; set; }   
        public String USPS_ERROR_CODE              { get; set; }
        
        public rateWrapper() {
            Service = '';
            totalCharges = '';
            currencyCode = '';
            totalSurcharges = '';
            CommitmentDate = '';
            USPS_ERROR_DESC = '';
            USPS_ERROR_SOURCE = '';
            USPS_ERROR_CODE = '';
        } 
    }
    
    public List<trackwrapper> trackwrapperlist                             { get; set; }    
    public class trackwrapper {                 
        
        public String eventTime                                            { get; set; }  
        public String eventDate                                            { get; set; }  
        public String event                                                { get; set; }  
        public String eventCity                                            { get; set; }  
        public String eventState                                           { get; set; }  
        public String eventZipCode                                         { get; set; }
        
        public String location                                             { get; set; }  
        public DateTime dtValue                                            { get; set; } 
        public String timeStamp                                            { get; set; }
        public String activityDesp                                         { get; set; }          
        public String arrivalLocation                                      { get; set; }  
        public String dateTimeString                                       { get; set; }               
        public String SignedForByName                                      { get; set; }   
            
        public trackwrapper() { 
            eventTime = '';
            eventDate = '';
            event = '';
            eventCity = '';
            eventState = '';
            eventZipCode = '';
           
            location = '';
            timeStamp = '';            
            activityDesp = ''; 
            dateTimeString = ''; 
            arrivalLocation = '';          
            SignedForByName = '';
        }        
    } 
    
    /* ------------------------- ParseUSPSErrorXML -------------------------*/                
    public String ParseUSPSErrorXML(XMLStreamReader USPSErrorXMLReader) {
        rateWrapper rW = new rateWrapper();
        String retValue = ''; // Read through the XML
        while(USPSErrorXMLReader.hasNext()) { 
            if(USPSErrorXMLReader.getEventType() == XmlTag.END_ELEMENT) {
                if('Error' == USPSErrorXMLReader.getLocalName()) {
                    break; // quit parsing when we hit the end of this record
                }
            } else if('Number' == USPSErrorXMLReader.getLocalName()) { 
                USPSErrorXMLReader.next();
                if(USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {
                    
                    rW.USPS_ERROR_CODE = USPSErrorXMLReader.getText();
                    retValue += USPSErrorXMLReader.getText();
                } 
            } else if('Source' == USPSErrorXMLReader.getLocalName()) {
                USPSErrorXMLReader.next();
                if(USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {
                    rW.USPS_ERROR_SOURCE = USPSErrorXMLReader.getText();
                    retValue +=' : '+USPSErrorXMLReader.getText();
                } 
            } else if('Description' == USPSErrorXMLReader.getLocalName()) {
                USPSErrorXMLReader.next();
                if(USPSErrorXMLReader.getEventType() == XmlTag.CHARACTERS) {
                    rW.USPS_ERROR_DESC = USPSErrorXMLReader.getText();
                    retValue +=' : '+USPSErrorXMLReader.getText();
                } 
            } 
            USPSErrorXMLReader.next();
        } 
        return retValue; 
    }
    
    /* ------------------------- User Defined Function Reading XMLResponse -------------------------*/                
    public String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; // Read through the XML
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
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return retValue;
    }
}