public with sharing class FEDEXHandler { 
                
   /* public String CurrCode                                    { get; set; }  public String meterNumber                                 { get; set; }
    public String parentKey                                   { get; set; }  public String parentPassword                              { get; set; }
    public String Key                                         { get; set; } public String password                                    { get; set; }

    public Boolean flag                                       { get; set; } public String accountNumber                               { get; set; }
    public String result                                      { get; set; } public String endPoint                                    { get; set; }
     
    public String shipId;    
    public String retValue;
    public List<Id> packIds;
    public String totalNetCharges                             { get; set; }  public String shipResult                                  { get; set; }  
    public String amount                                      { get; set; }  public String service                                     { get; set; }
    public String errorMsg                                    { get; set; }  public String request_UD                                  { get; set; } 
       
    public String resStatus                                   { get; set; } public String response_UD                                 { get; set; }           
    public String errorMsg1                                   { get; set; }  public String resStatusUD                                 { get; set; }            
    
    public String response_Message                            { get; set; } public String request_1                                   { get; set; } 
    public String tab1_Message                                { get; set; } public String response_1                                  { get; set; }           
    public String weightUnit                                  { get; set; } public String response_2                                  { get; set; }
      
    public Attachment upsLabel                                { get; set; } public String request_2                                   { get; set; } 
    public Shipment__c Shipment                               { get; set; } public String originStreet                                { get; set; } 
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
    public Boolean fromShipmentType                           { get; set; } public String originProvinceCode                          { get; set; }
    public Boolean time_in_cost_tab                           { get; set; } public String shipperCountryCode                          { get; set; } 
    public String destinationStreet                           { get; set; }  public String originCountryCode                           { get; set; }
       
    public List<Package__c> Packages                          { get; set; }    
    public String shipperProvinceCode                         { get; set; }     
    public Address__c shippingAddress                         { get; set; }                    
    public Decimal totaldeclaredValue                         { get; set; } 
    public List<Package_List__c> pkgList                      { get; set; }
    public String destinationCountryCode                      { get; set; }
    public String destinationProvinceCode                     { get; set; }     
    public Map<String, String> recordIdMap                    { get; set; }  public Boolean hasAccess                                  { get; set; }  
    public List<Credentials__c> upsCredentials                { get; set; }  public String errormsg2                                   { get; set; }
    public Map<Integer, Boolean> showAndHideMap               { get; set; }  

    
    //  Constructor.
    
    public FEDEXHandler() {  
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
            Shipment.Signature_Services__c = 'SERVICE_DEFAULT';
            Shipment.Reason_For_Export__c = 'SAMPLE'; 
            Shipment.Product_Unit_Code__c = 'Each';
            recordIdMap = new Map<String, String>();          
            toShipmentType = fromShipmentType = false;
            Shipment.Shipment_Date__c = System.Today();
            totalNetCharges = amount = errorMsg = MasterTrackingId = '';
            response_Message = tab1_Message = '';   
            showAndHideMap = new Map<Integer, Boolean>();  
            for(Integer i=1; i<=12; i++) { if(i==1 || i==10) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
            //Commenting the below as using description from package object
            //List<Package_Details__c> pkgs = new List<Package_Details__c> ([select Id, Name, Shipment_Description__c from Package_Details__c where Shipment_Description__c != null limit 1]);
            //if(pkgs.size() > 0 && pkgs[0].Shipment_Description__c != null) shipment.Description__c = pkgs[0].Shipment_Description__c;
            
            upsCredentials = Database.query('select ' + String.escapeSingleQuotes(credentialFields) + ' from Credentials__c where (Name = \'Fedex\' And Active__c = true) Limit 1');
            if(upsCredentials != null && upsCredentials.size() > 0) { Blob cryptoKey, passwordData;
                cryptoKey = encodingUtil.convertFromHex(upsCredentials[0].Encrypted_Key__c);
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsCredentials[0].Password_Transkey__c));
                if(passwordData != null) upsCredentials[0].Password_Transkey__c = passwordData.toString();
                
                parentKey = upsCredentials[0].Parent_Key__c; 
                parentPassword = upsCredentials[0].Parent_Password__c; 
                Key = upsCredentials[0].key__c; 
                password = upsCredentials[0].Password_Transkey__c; 
                meterNumber = upsCredentials[0].Meter_Number__c;
                endPoint = upsCredentials[0].URL__c;  
                accountNumber = upsCredentials[0].UPS_Account_Number__c;

                if(getProvinceCode(upsCredentials[0].Shipper_Province__c) != '') shipperProvinceCode = getProvinceCode(upsCredentials[0].Shipper_Province__c);
                //else errorMsg = 'FedEx Shipping Service Unavailable : Shipper Province Code not found';
                if(getCountryCode(upsCredentials[0].Shipper_Country__c) != '') shipperCountryCode = getCountryCode(upsCredentials[0].Shipper_Country__c);
                else errorMsg = 'FedEx Shipping Service Unavailable : Shipper Country Code not found';                
            } else errorMsg = 'FedEx Shipping Service Unavailable : Please setup FedEx credentials';                      
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
    
    
    //  getter method definitions.
    
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
    public Boolean getIsUPSPaperlessInvoice(String countryName) { List<Country_Codes__c> countryList;
        if(countryName != null && countryName != '') {
            countryList = [Select Id, Name, Code__c, Country__c, UPS_Paperless_Invoice__c From Country_Codes__c Where Country__c =: String.escapeSingleQuotes(countryName) Limit 1];    
        } if(countryList != null && countryList.size() > 0 && countryList[0].UPS_Paperless_Invoice__c != false) return countryList[0].UPS_Paperless_Invoice__c;
          else return false;
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
    
    
    //  Init method called after setting the package Id / shipment Id.
    
    public void init() {
        try { 
            if(packIds.size() > 0) { String bFilter, sFilter; // Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, 
                for(Package__c p : Database.query('select ' + packageFields + ' , Logistic__r.Order__c, Logistic__r.Sales_Order__c, Logistic__r.Sales_Order__r.Id, Logistic__r.From_Address__c, Logistic__r.To_Address__c, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, '+
                                   +' Transfer_Order__r.To_Address__c, Sales_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Name, Return_Merchandise_Authorisation__r.Message__c, '+
                                   +' (select ' + packageListFields + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Base_Price__c, Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c, '+
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
                if(Packages[0].Sales_Order__c != null) recordIdMap.put('SO', Packages[0].Sales_Order__c);
                else if(Packages[0].Work_Order__c != null) recordIdMap.put('WO', Packages[0].Work_Order__c);
                else if(Packages[0].Purchase_Order__c != null) recordIdMap.put('PO', Packages[0].Purchase_Order__c);
                else if(Packages[0].Transfer_Order__c != null) recordIdMap.put('TO', Packages[0].Transfer_Order__c);
                else if(Packages[0].Return_Merchandise_Authorisation__c != null) recordIdMap.put('SR', Packages[0].Return_Merchandise_Authorisation__c);                
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
                else if(Packages[0].Work_Order__r.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Work_Order__r.Shipping_Address__c; sFilter = 'Id =\'' + Packages[0].Work_Order__r.Shipping_Address__c + '\''; }
                else if(Packages[0].Purchase_Order__r.Vendor_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Purchase_Order__r.Vendor_Address__c; sFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Vendor_Address__c + '\''; }
                else if(Packages[0].Transfer_Order__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Transfer_Order__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Transfer_Order__r.To_Address__c + '\''; }
                else if(Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c; sFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c + '\''; }
                
                if(bFilter != null) fromAddress = Database.query('select ' + addressFields + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ bFilter +' Limit 1');
                if(sFilter != null) shippingAddress = Database.query('select ' + addressFields + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ sFilter +' Limit 1');
                
                 // fetching origin province and country code
                if(fromAddress != null) {
                    if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                    //else errorMsg = 'FedEx Shipping Service Unavailable : Origin Province Code not found';            
                    if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                    else errorMsg = 'FedEx Shipping Service Unavailable : Origin Country Code not found';            
                    if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                    fromAddr.Bill_To_Address__c = fromAddress.Id;
                }
                 // fetching destination province and country code
                if(shippingAddress != null) {
                    if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c);
                    // Commenting as it is not mandatory
                    //else errorMsg = 'FedEx Shipping Service Unavailable : Destination Province Code not found';            
                    if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'FedEx Shipping Service Unavailable : Destination Country Code not found';            
                    if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                    toAddr.Ship_To_Address__c = shippingAddress.Id;
                }
                
                shipment.Description__c = '';
                if(Packages[0].PO_Reference__c != null && Packages[0].PO_Reference__c != '') shipment.Description__c += Packages[0].PO_Reference__c + ' ';
                if(Packages[0].Description__c != null && Packages[0].Description__c != '') shipment.Description__c += Packages[0].Description__c;
                     
            } else if(shipId != null && shipId  != '') { //Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, 
                for(Package__c p : Database.query('select ' + packageFields + ' , Logistic__r.Order__c, Logistic__r.Sales_Order__c, Logistic__r.Sales_Order__r.Id, Logistic__r.From_Address__c, Logistic__r.To_Address__c, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, '+
                                   +' Transfer_Order__r.To_Address__c, Sales_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, '+
                                   +' (select ' + packageListFields + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Base_Price__c, Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Product__r.Name, Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c, '+
                                   +' Purchase_Line_Items__r.Product__r.Name, Sales_Order_Line_Item__r.Product__r.Commodity_Code__c, Work_Order_Line_Items__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Commodity_Code__c, Transfer_Order_Line_Item__r.Products__r.Commodity_Code__c, RMA_Line_Item__r.SOLI__r.Product__r.Commodity_Code__c, Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c, Transfer_Order_Line_Item__r.Products__r.Name, Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c, '+
                                   +' RMA_Line_Item__r.SOLI__r.Product__r.Name, RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c, Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Unit_Price__c, Purchase_Line_Items__r.Total_Price__c, Purchase_Line_Items__r.Unit_Price__c, RMA_Line_Item__r.Total_Deduction__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Price_Product__c From Package_Lists__r) '+
                                   +' from Package__c where Id In: packIds And Active__c = true')) {
                    if(p.Weight_Unit__c != null) weightUnit = p.Weight_Unit__c; if(p.Weight__c != null) toalWeightValue += Integer.valueof(p.Weight__c);  
                    Packages.add(p);                     
                }               
                String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','Fedex_Shipping');
                Shipment = Database.query('select ' + shipmentFields + ' from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1');
                Shipment = (Shipment != null) ? Shipment : new Shipment__c();
                
                if(Shipment.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Shipment.Billing_Address__c; fromAddress = Database.query('select ' + addressFields + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + Shipment.Billing_Address__c + '\' Limit 1'); }
                if(Shipment.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Shipment.Shipping_Address__c; shippingAddress = Database.query('select ' + addressFields + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + Shipment.Shipping_Address__c + '\' Limit 1'); }
                
                // fetching origin province and country code
                if(fromAddress != null) {
                    if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                    //else errorMsg = 'FedEx Shipping Service Unavailable : Origin Province Code not found';            
                    if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                    else errorMsg = 'FedEx Shipping Service Unavailable : Origin Country Code not found';            
                    if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                    fromAddr.Bill_To_Address__c = fromAddress.Id;
                }
                 // fetching destination province and country code
                if(shippingAddress != null) {
                    if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c);
                    //Commenting as it is not mandatory
                    //else errorMsg = 'FedEx Shipping Service Unavailable : Destination Province Code not found';            
                    if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'FedEx Shipping Service Unavailable : Destination Country Code not found';            
                    if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                    toAddr.Ship_To_Address__c = shippingAddress.Id;
                }
                List<Attachment> myAttachment = new List<Attachment>();
                if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%Fedex_Label%' order by CreatedDate DESC];
                                       for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9) showAndHideMap.put(i, false); else showAndHideMap.put(i, true); }
                } upsLabel = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment();  
                myAttachment = new List<Attachment>();
                if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%Proof of Delivery%' order by CreatedDate DESC Limit 1];                    
                                       showAndHideMap.put(8, false); showAndHideMap.put(9, true);  
                } spodLetter = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment();                
             } flag = true;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }    
    }
    
    
    //  method for getting from and to address upon change.
    
    public PageReference fetchAddress() {
        try { 
            if(toAddr.Ship_To_Address__c != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + toAddr.Ship_To_Address__c + '\' Limit 1');  
            if(fromAddr.Bill_To_Address__c != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + fromAddr.Bill_To_Address__c + '\' Limit 1');
             // fetching origin province and country code
            if(fromAddress != null) { errorMsg = '';
                if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c);
                //else errorMsg = 'FedEx Shipping Service Unavailable : Origin Province Code not found';            
                if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c);
                else errorMsg = 'FedEx Shipping Service Unavailable : Origin Country Code not found';            
                if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c);
                fromAddr.Bill_To_Address__c = fromAddress.Id;
            }
             // fetching destination province and country code
            if(shippingAddress != null) { errorMsg = '';
                if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c);
                //Commenting as it is not mandatory
                //else errorMsg = 'FedEx Shipping Service Unavailable : Destination Province Code not found';            
                if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'FedEx Shipping Service Unavailable : Destination Country Code not found';            
                if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c);
                toAddr.Bill_To_Address__c = shippingAddress.Id;
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    
    //  method for generating fedex label as pdf to print.
    
    public PageReference CreateFedexLabel() {
        
        PageReference pg = page.Pickpackship_PrintUPSLabel;
        pg.getParameters().put('shipmentsId',Shipment.Id);
        pg.getParameters().put('fileName','Fedex_Label');
        pg.getParameters().put('val','pdf');
        return pg;        
    }
    
    
    //  method for returning back to respective flows (SO, WO, PO, TO, SR)
    
    public PageReference back() { 
        pageReference pg;
        //if(retValue == 'SO') { pg = new pageReference('/apex/ERP7__Stockdispatching_SalesOrder'); pg.setRedirect(true); }
        //else if(retValue == 'WO') { pg = new pageReference('/apex/ERP7__stockdispatching_WorkOrder'); pg.setRedirect(true); }
        //else if(retValue == 'PO') { pg = new pageReference('/apex/ERP7__stockdispatching_PurchaseOrder'); pg.setRedirect(true); }
       // else if(retValue == 'TO') { pg = new pageReference('/apex/ERP7__stockdispatching_TransferOrder'); pg.setRedirect(true); } 
        if(retValue == 'SR') { pg = new pageReference('/apex/ERP7__RMAPackage?id='+recordIdMap.get('SR')); pg.setRedirect(true); }
        else { pg = new pageReference('/apex/ERP7__OutboundLogistics'); pg.setRedirect(true); }
        return pg; 
    }
    
    public PageReference RedirectFedexEulaPdf() {
        PageReference pg = new PageReference('/apex/ERP7__FedexEulaPdf');
        pg.setRedirect(true);
        return pg;
    }    
    
    
    //  shipping rate API request.
    
    public PageReference Shipping_Rate() {
        try {
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This package has already been ' + Shipment.Status__c; } 
            else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; }
            else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; } 
            else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } 
            else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; }         
            else if (Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment date unavailable'; }
            else { errorMsg1 = '';  DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
                   //Shipping_Rate_Request(fromAddress, shippingAddress, packages, shipmentDate);
                  Shipping_Rate_Request(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), shipmentDate);
                 }   
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference Shipping_Rate_Request(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String shipDate) { 
    public PageReference Shipping_Rate_Request(String fromAddress1, String toAddress1, String packList1, String shipDate) { 
        try {
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);
            Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            String soapXML = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://fedex.com/ws/rate/v28">';
            soapXML += '<SOAP-ENV:Body>';
                soapXML += '<RateRequest>';    
                          
                    soapXML += '<WebAuthenticationDetail>';
                        if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                            soapXML += '<ParentCredential>';
                                soapXML += '<Key>' + parentkey.escapeXml() + '</Key>';
                                soapXML += '<Password>' + parentPassword.escapeXml() + '</Password>';
                            soapXML += '</ParentCredential>';
                        }  
                         
                        soapXML += '<UserCredential>';
                            soapXML += '<Key>' + key.escapeXml() + '</Key>';
                            soapXML += '<Password>' + password.escapeXml() + '</Password>';
                        soapXML += '</UserCredential>';
                    soapXML += '</WebAuthenticationDetail>';
                    
                    soapXML += '<ClientDetail>';
                        soapXML += '<AccountNumber>' + accountNumber.escapeXml() + '</AccountNumber>';
                        soapXML += '<MeterNumber>' + meterNumber.escapeXml() + '</MeterNumber>';
                    soapXML += '</ClientDetail>';
                    
                    soapXML += '<TransactionDetail>';
                        soapXML += '<CustomerTransactionId>Rate Request</CustomerTransactionId>';
                    soapXML += '</TransactionDetail>';
                    
                    soapXML += '<Version>';
                        soapXML += '<ServiceId>crs</ServiceId>';
                        soapXML += '<Major>28</Major>';
                        soapXML += '<Intermediate>0</Intermediate>';
                        soapXML += '<Minor>0</Minor>';
                    soapXML += '</Version>';
                     
                    soapXML += '<RequestedShipment>';
                        soapXML += '<ShipTimestamp>'+ shipDate +'</ShipTimestamp>';
                        soapXML += '<DropoffType>REGULAR_PICKUP</DropoffType>';
                        soapXML += '<PackagingType>YOUR_PACKAGING</PackagingType>';
                        //soapXML += '<PackagingType>FEDEX_PAK</PackagingType>';
                        soapXML+= '<TotalWeight>';
                            if(weightUnit == 'KGS') soapXMl += '<Units>KG</Units>'; else soapXMl += '<Units>LB</Units>';                         
                            soapXML += '<Value>'+ toalWeightValue +'</Value>';
                        soapXML += '</TotalWeight>';
                        
                        if(upsCredentials != null && upsCredentials.size() > 0) {
                            soapXML += '<Shipper>';                        
                                soapXML += '<Contact>';
                                    soapXML += '<PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</PersonName>';
                                    soapXML += '<CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</CompanyName>';
                                    soapXML += '<PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</PhoneNumber>';
                                soapXML += '</Contact>';
                                soapXML += '<Address>';
                                    soapXML += '<StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</StreetLines>';
                                    soapXML += '<City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</City>';
                                    if(shipperProvinceCode != null) soapXML += '<StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</StateOrProvinceCode>';
                                    soapXML += '<PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';
                                    if(shipperCountryCode != null) soapXML += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';
                                soapXML += '</Address>';
                            soapXML += '</Shipper>';
                        }
                        if(toAddress != null) {
                            soapXML += '<Recipient>';
                                soapXML += '<Contact>';
                                    soapXML += '<PersonName>'+ toAddress.Contact__r.Name.escapeXml() +'</PersonName>';
                                    if(toAddress.Contact__r.Company__c != null) soapXML += '<CompanyName>'+ toAddress.Contact__r.Company__c.escapeXml() +'</CompanyName>';
                                    if(toAddress.Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ toAddress.Contact__r.Phone.escapeXml() +'</PhoneNumber>';
                                soapXML += '</Contact>';
                                soapXML += '<Address>';
                                    soapXML += '<StreetLines>' + DestinationStreet.escapeXml() + '</StreetLines>';
                                    soapXML += '<City>' + toAddress.City__c.escapeXml() + '</City>';
                                    if(DestinationProvinceCode != null) soapXML += '<StateOrProvinceCode>' + DestinationProvinceCode.escapeXml() + '</StateOrProvinceCode>';
                                    soapXML += '<PostalCode>' + toAddress.Postal_Code__c.escapeXml() + '</PostalCode>';
                                    if(DestinationCountryCode != null) soapXML += '<CountryCode>' + DestinationCountryCode.escapeXml() + '</CountryCode>';
                                soapXML += '</Address>';
                            soapXML += '</Recipient>';
                        }
                        soapXML += '<ShippingChargesPayment>';
                            soapXML += '<PaymentType>SENDER</PaymentType>';
                            soapXML += '<Payor>';
                                soapXML += '<ResponsibleParty>';
                                    soapXML += '<AccountNumber>' + accountNumber.escapeXml() + '</AccountNumber>';
                                soapXML += '</ResponsibleParty>';
                            soapXML += '</Payor>';                        
                        soapXML += '</ShippingChargesPayment>';
                        soapXML += '<RateRequestTypes>LIST</RateRequestTypes>'; //NONE
                        if(packList != null && packList.size() > 0) soapXML += '<PackageCount>'+ packList.size() +'</PackageCount>';
                        
                        for(Integer i=1; i<=packList.size(); i++) { 
                            soapXML += '<RequestedPackageLineItems>';
                                soapXML += '<SequenceNumber>'+ i +'</SequenceNumber>';
                                soapXML += '<GroupNumber>1</GroupNumber>';
                                soapXML += '<GroupPackageCount>1</GroupPackageCount>';
                                
                                soapXML += '<Weight>';
                                    if(packList[i-1].Weight_Unit__c == 'KGS') soapXMl += '<Units>KG</Units>'; else soapXMl += '<Units>LB</Units>';    
                                    soapXML += '<Value>' + packList[i-1].Weight__c + '</Value>';                        
                                soapXML += '</Weight>';
                                
                                soapXML += '<ContentRecords>';
                                    soapXML += '<PartNumber>'+ packList[i-1].Name__c +'</PartNumber>';
                                    soapXML += '<ItemNumber>'+ packList[i-1].Name__c +'</ItemNumber>';
                                    soapXML += '<ReceivedQuantity>'+ Integer.valueof(packList[i-1].Package_Quantity__c) +'</ReceivedQuantity>';
                                    soapXML += '<Description>'+ packList[i-1].Description__c +'</Description>';
                                soapXML += '</ContentRecords>';
                            soapXML += '</RequestedPackageLineItems>';
                        }
                        
                    soapXML += '</RequestedShipment>';
                soapXML += '</RateRequest>';
            soapXML += '</SOAP-ENV:Body>';
            soapXML += '</SOAP-ENV:Envelope>';
            
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);
            //req.setTimeout(119999);   
            req.setMethod('POST');
            req.setEndpoint(endpoint);
            req.setHeader('Content-length', '200');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '');
            
            
            HttpResponse res = h.send(req);             
            request_1 = soapXML;
            response_1 = res.getBody();
                
            resStatus = res.getStatus();
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING' || msg == 'NOTE' || msg == 'WARNINGNOTE') {   XmlStreamReader reader2 = res.getXmlStreamReader();  String resMesage = readXMLResponse(reader2, 'Code');
                                                                            if (resMesage == '556') { Result = 'There are no valid services available.'; }
                                                                            else {  XmlStreamReader reader = res.getXmlStreamReader(); readXMLResponseRateTransitDetails(reader,'RateReplyDetails'); Result = 'Available FedEx Services For The Selected Location';  time_in_cost_tab = true; }                               
                } else { XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message'); Result = 'Shipping Rate is not available : ' + msg2;
                }
            } else Result = 'Result not available'; 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public void readXMLResponseRateTransitDetails(XmlStreamReader reader, String sxmltag) {
        try {
            rateWrapper rw; rateWrapperList = new List<rateWrapper>();
            while(reader.hasNext()) {
                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) {  rw = new rateWrapper();
                    while(reader.hasNext()) {
                        // service type
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceType') { reader.next();
                            rw.service = reader.getText(); }
                        // Service Name
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceDescription') {  reader.next(); 
                            Boolean valueFound = false;
                            string encd;
                            while(!valueFound){
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Value') {
                                    reader.next();
                                    rw.serviceName = reader.getText();
                                    break;
                                }
                                reader.next();
                                //if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Encoding') { 
                                  //  reader.next();
                                    //encd = reader.getText();
                                    //if(encd == 'ascii'){
                                                                               
                                      //  rw.serviceName = reader.getText();
                                        //    break;
                                   // } else {
                                     //   reader.next();    
                                  //  }
                                    
                               // }
                                //reader.next();
                            }
                        }
                        // sur charges
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalSurcharges') { reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); 
                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); CurrCode = reader.getText();  } reader.next(); reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); 
                                if(reader.hasText() && rw.totalSurcharges == '') rw.totalSurcharges = reader.getText() +' '+ rw.currencyCode; } }
                        // total charges
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNetCharge') { reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); 
                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText();  CurrCode = reader.getText();  } reader.next(); reader.next();
                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); 
                                if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText() +' '+ rw.currencyCode; } }    
                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();
                    } rateWrapperList.add(rw);
                } reader.next();
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
    
    
    //  shipment & label generation API request.
    
    public PageReference Shipping_Request() {   
        try {
            time_in_cost_tab = false;
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This Package Has Already Been ' + Shipment.Status__c; } 
            else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; } 
            else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; } 
            else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } 
            else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; }             
            else if(Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment Date Unavailable'; } 
            else if(service == null || service == '') { errorMsg1 = 'Service Is Unavailable, Please Select At Least One Service From Shipping Service And Cost' ; } 
            else { errorMsg1 = '';  DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'); 
                   //Shipping_Request_Reply(fromAddress, shippingAddress, packages, service, shipmentDate);
                 Shipping_Request_Reply(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), service, shipmentDate);}                    
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference Shipping_Request_Reply(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String service, String ShipDateStamp) {
    public PageReference Shipping_Request_Reply(String fromAddress1, String toAddress1, String packList1, String service, String ShipDateStamp) {
        try{
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);
            Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            string docId;
            string before = 'Testing base 64 encode';
            Blob beforeblob = Blob.valueOf(before);
            string myBase64String = EncodingUtil.base64Encode(beforeblob);
            
            if(packList[0].ETD__c == true){
                if(packList[0].ERP7__ETD_types__c == 'Upload Images'){
                    String soapXMLui =   '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://fedex.com/ws/uploaddocument/v19">' ;
                    soapXMLui  += '<soapenv:Body>';
                    soapXMLui  += '<UploadImagesRequest>';
                    soapXMLui  += '<WebAuthenticationDetail>';
                    soapXMLui += '<ParentCredential>';
                    soapXMLui += '<Key>' + parentkey.escapeXml() + '</Key>';
                    soapXMLui += '<Password>' + parentPassword.escapeXml() + '</Password>';
                    soapXMLui += '</ParentCredential>';
                    soapXMLui += '<UserCredential>';
                    soapXMLui += '<Key>' + key.escapeXml() + '</Key>';
                    soapXMLui += '<Password>' + password.escapeXml() + '</Password>';
                    soapXMLui += '</UserCredential>';
                    soapXMLui += '</WebAuthenticationDetail>';
                    soapXMLui +='<ClientDetail>';
                    soapXMLui += '<AccountNumber>'+ accountNumber.escapeXml() + '</AccountNumber>' ;
                    soapXMLui += '<MeterNumber>' + meterNumber.escapeXml() + '</MeterNumber>';
                    soapXMLui += '</ClientDetail>';
                    soapXMLui += '<TransactionDetail>';
                    soapXMLui += '<CustomerTransactionId>UploadImagesRequest</CustomerTransactionId>';
                    soapXMLui +=  '</TransactionDetail>';
                    soapXMLui += '<Version>';
                    soapXMLui += '<ServiceId>cdus</ServiceId>';
                    soapXMLui += '<Major>19</Major>';
                    soapXMLui += '<Intermediate>0</Intermediate>';
                    soapXMLui += '<Minor>0</Minor>';
                    soapXMLui += '</Version>';
                    soapXMLui += '<Images>';
                    soapXMLui +=  '<Id>'+ toAddress.Contact__r.Name.escapeXml() +'</Id>';
                    soapXMLui += '<Image>'+myBase64String+'</Image>';
                    soapXMLui += '</Images>';
                    soapXMLui += '</UploadImagesRequest>';
                    soapXMLui += '</soapenv:Body>';
                    HttpRequest req = new HttpRequest();
                    Http h = new Http();
                    
                    req.setBody(soapXMLui);
                    req.setMethod('POST');
                    req.setEndpoint(endpoint);
                    req.setHeader('Content-length', '175');
                    req.setHeader('Content-Type', 'text/xml');
                    req.setHeader('SOAPAction', '');
                    
                    HttpResponse res = h.send(req);            
                    request_UD = soapXMLui;
                    response_UD = res.getBody();
                    resStatusUD = res.getStatus();
                    
                    if(resStatusUD == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                                             if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') { XmlStreamReader reader2 = res.getXmlStreamReader(); docId = readXMLResponse(reader2, 'DocumentId');
                                                                                                     } else { XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message'); Result = msg2; }
                                            }
                    
                }
                
                if(packList[0].ERP7__ETD_types__c == 'Upload with Shipment'){
                    
                }
                String soapXMLe = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v7="http://fedex.com/ws/uploaddocument/v19">';
                    soapXMLe += '<soapenv:Body>';
                        soapXMLe += '<v7:UploadDocumentsRequest>';
                            soapXMLe += '<v7:WebAuthenticationDetail>';
                                soapXMLe += '<v7:ParentCredential>';
                                    soapXMLe += '<v7:Key>' + parentkey.escapeXml() + '</v7:Key>';
                                    soapXMLe += '<v7:Password>' + parentPassword.escapeXml() + '</v7:Password>';
                                soapXMLe += '</v7:ParentCredential>';
                                soapXMLe += '<v7:UserCredential>';
                                    soapXMLe += '<v7:Key>' + key.escapeXml() + '</v7:Key>';
                                    soapXMLe += '<v7:Password>' + password.escapeXml() + '</v7:Password>';
                                soapXMLe += '</v7:UserCredential>';
                            soapXMLe += '</v7:WebAuthenticationDetail>';
                            
                            soapXMLe += '<v7:ClientDetail>';
                                soapXMLe += '<v7:AccountNumber>' + accountNumber.escapeXml() + '</v7:AccountNumber>';
                                soapXMLe += '<v7:MeterNumber>' + meterNumber.escapeXml() + '</v7:MeterNumber>';
                            soapXMLe += '</v7:ClientDetail>';
                            
                            soapXMLe += '<v7:TransactionDetail>';
                                soapXMLe += '<v7:CustomerTransactionId>'+ toAddress.Contact__r.Name.escapeXml() +'</v7:CustomerTransactionId>';
                            soapXMLe += '</v7:TransactionDetail>';
                            
                            soapXMLe += '<v7:Version>';
                                soapXMLe += '<v7:ServiceId>cdus</v7:ServiceId>';
                                soapXMLe += '<v7:Major>11</v7:Major>';
                                soapXMLe += '<v7:Intermediate>0</v7:Intermediate>';
                                soapXMLe += '<v7:Minor>0</v7:Minor>';
                            soapXMLe += '</v7:Version>';
                            
                            soapXMLe += '<v7:OriginCountryCode>'+ OriginCountryCode +'</v7:OriginCountryCode>';
                            soapXMLe += '<v7:DestinationCountryCode>'+ DestinationCountryCode +'</v7:DestinationCountryCode>';
                            
                            soapXMLe += '<v7:Documents>';
                                soapXMLe += '<v7:LineNumber>200</v7:LineNumber>';
                                soapXMLe += '<v7:CustomerReference>'+ toAddress.Contact__r.Name.escapeXml() +'</v7:CustomerReference>';
                                soapXMLe += '<v7:DocumentType>COMMERCIAL_INVOICE</v7:DocumentType>';
                                soapXMLe += '<v7:FileName>CI.PNG</v7:FileName>';
                                soapXMLe += '<v7:DocumentContent>' + myBase64String + '</v7:DocumentContent>';
                            soapXMLe += '</v7:Documents>';
                                  
                        soapXMLe += '</v7:UploadDocumentsRequest>';
                    soapXMLe += '</soapenv:Body>';    
                soapXMLe += '</soapenv:Envelope>';
                
                HttpRequest req = new HttpRequest();
                Http h = new Http();
                
                req.setBody(soapXMLe);
                req.setMethod('POST');
                req.setEndpoint(endpoint);
                req.setHeader('Content-length', '175');
                req.setHeader('Content-Type', 'text/xml');
                req.setHeader('SOAPAction', '');
                
                HttpResponse res = h.send(req);            
                request_UD = soapXMLe;
                response_UD = res.getBody();
                resStatusUD = res.getStatus();
                
                if(resStatusUD == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                    if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') { XmlStreamReader reader2 = res.getXmlStreamReader(); docId = readXMLResponse(reader2, 'DocumentId');
                    } else { XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message'); Result = msg2; }
                }
                
            }
            
            if(retValue == 'SR' && shipment.Email_from_Third_Party__c == true) {
                String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v17="http://fedex.com/ws/openship/v20">';
                    soapXML += '<soapenv:Body>';
                        soapXML += '<v17:CreatePendingShipmentRequest>';
                            soapXML += '<v17:WebAuthenticationDetail>';
                                soapXML += '<v17:UserCredential>';
                                    soapXML += '<v17:Key>' + key.escapeXml() + '</v17:Key>';
                                    soapXML += '<v17:Password>' + password.escapeXml() + '</v17:Password>';
                                soapXML += '</v17:UserCredential>';
                            soapXML += '</v17:WebAuthenticationDetail>';
                            
                            soapXML += '<v17:ClientDetail>';
                                soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>';
                                soapXML += '<v17:MeterNumber>' + meterNumber.escapeXml() + '</v17:MeterNumber>';
                            soapXML += '</v17:ClientDetail>';
                    
                            soapXML += '<v17:TransactionDetail>';
                                soapXML += '<v17:CustomerTransactionId>RMA Label</v17:CustomerTransactionId>';
                            soapXML += '</v17:TransactionDetail>';
                            
                            soapXML += '<v17:Version>';
                                soapXML += '<v17:ServiceId>ship</v17:ServiceId>';
                                soapXML += '<v17:Major>20</v17:Major>';
                                soapXML += '<v17:Intermediate>0</v17:Intermediate>';
                                soapXML += '<v17:Minor>0</v17:Minor>';
                            soapXML += '</v17:Version>';
                    
                            soapXML += '<v17:Actions>TRANSFER</v17:Actions>';
                            
                            soapXML += '<v17:RequestedShipment>';
                                
                                soapXML += '<v17:ShipTimestamp>' + ShipDateStamp + '</v17:ShipTimestamp>';
                                soapXML += '<v17:DropoffType>REGULAR_PICKUP</v17:DropoffType>';
                                soapXML += '<v17:ServiceType>' + Service + '</v17:ServiceType>';
                                soapXML += '<v17:PackagingType>YOUR_PACKAGING</v17:PackagingType>';
                                
                                //commented as it is not mandatory
                                //soapXML += '<v17:TotalWeight>';    
                                  //  soapXML += '<v17:Units>LB</v17:Units>';                         
                                    //soapXML += '<v17:Value>10</v17:Value>';
                                //soapXML += '</v17:TotalWeight>';
                                
                                
                                // fromAddr toAddr
                                
                                soapXML += '<v17:Shipper>'; 
                                    soapXML += '<v17:Contact>';
                                        soapXML += '<v17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</v17:PersonName>';
                                        soapXML += '<v17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</v17:CompanyName>';
                                        soapXML += '<v17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</v17:PhoneNumber>';
                                    soapXML += '</v17:Contact>';
                                    soapXML += '<v17:Address>';
                                        soapXML += '<v17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</v17:StreetLines>';
                                        soapXML += '<v17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</v17:City>';
                                        soapXML += '<v17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</v17:StateOrProvinceCode>';
                                        soapXML += '<v17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</v17:PostalCode>';
                                        soapXML += '<v17:CountryCode>'+ shipperCountryCode.escapeXml() +'</v17:CountryCode>';
                                    soapXML += '</v17:Address>';
                                soapXML += '</v17:Shipper>';
                                
                                soapXML += '<v17:Recipient>';
                                    soapXML += '<v17:Contact>';
                                        soapXML += '<v17:PersonName>'+ toAddress.Contact__r.Name.escapeXml() +'</v17:PersonName>';
                                        soapXML += '<v17:CompanyName>'+ toAddress.Contact__r.Company__c.escapeXml() +'</v17:CompanyName>';
                                        soapXML += '<v17:PhoneNumber>'+ toAddress.Contact__r.Phone.escapeXml() +'</v17:PhoneNumber>';
                                    soapXML += '</v17:Contact>';
                                    soapXML += '<v17:Address>';
                                        soapXML += '<v17:StreetLines>' + DestinationStreet.escapeXml() + '</v17:StreetLines>';
                                        soapXML += '<v17:City>' + toAddress.City__c.escapeXml() + '</v17:City>';
                                        soapXML += '<v17:StateOrProvinceCode>' + DestinationProvinceCode.escapeXml() + '</v17:StateOrProvinceCode>';
                                        soapXML += '<v17:PostalCode>' + toAddress.Postal_Code__c.escapeXml() + '</v17:PostalCode>';
                                        soapXML += '<v17:CountryCode>' + DestinationCountryCode.escapeXml() + '</v17:CountryCode>';
                                    soapXML += '</v17:Address>';
                                soapXML += '</v17:Recipient>'; 
                    
                                soapXML += '<v17:ShippingChargesPayment>';
                                    soapXML += '<v17:PaymentType>SENDER</v17:PaymentType>';
                                    soapXML += '<v17:Payor>';
                                        soapXML += '<v17:ResponsibleParty>';
                                            soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>';
                                            soapXML += '<v17:Contact>';
                                                soapXML += '<v17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</v17:PersonName>';
                                                soapXML += '<v17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</v17:CompanyName>';
                                                soapXML += '<v17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</v17:PhoneNumber>';
                                            soapXML += '</v17:Contact>';
                                            soapXML += '<v17:Address>';
                                                soapXML += '<v17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</v17:StreetLines>';
                                                soapXML += '<v17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</v17:City>';
                                                soapXML += '<v17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</v17:StateOrProvinceCode>';
                                                soapXML += '<v17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</v17:PostalCode>';
                                                soapXML += '<v17:CountryCode>'+ shipperCountryCode.escapeXml() +'</v17:CountryCode>';
                                            soapXML += '</v17:Address>';
                                        soapXML += '</v17:ResponsibleParty>';
                                    soapXML += '</v17:Payor>'; 
                                soapXML += '</v17:ShippingChargesPayment>';
                    
                                soapXML += '<v17:SpecialServicesRequested>';
                                    soapXML += '<v17:SpecialServiceTypes>RETURN_SHIPMENT</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:SpecialServiceTypes>PENDING_SHIPMENT</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:EMailNotificationDetail>';
                                        soapXML += '<v17:PersonalMessage>PersonalMessage</v17:PersonalMessage>';
                                        soapXML += '<v17:Recipients>';
                                            soapXML += '<v17:EMailNotificationRecipientType>RECIPIENT</v17:EMailNotificationRecipientType>';
                                            soapXML += '<v17:EMailAddress>'+ toAddress.Contact__r.Email.escapeXml() +'</v17:EMailAddress>';
                                            soapXML += '<v17:NotificationEventsRequested>ON_DELIVERY</v17:NotificationEventsRequested>';
                                            soapXML += '<v17:NotificationEventsRequested>ON_EXCEPTION</v17:NotificationEventsRequested>';
                                            soapXML += '<v17:NotificationEventsRequested>ON_SHIPMENT</v17:NotificationEventsRequested>';
                                            soapXML += '<v17:NotificationEventsRequested>ON_TENDER</v17:NotificationEventsRequested>';
                                            soapXML += '<v17:Format>HTML</v17:Format>';
                                            soapXML += '<v17:Localization>';
                                                soapXML += '<v17:LanguageCode>ENGLISH</v17:LanguageCode>';
                                                soapXML += '<v17:LocaleCode>US</v17:LocaleCode>';
                                            soapXML += '</v17:Localization>';
                                        soapXML += '</v17:Recipients>';    
                                    soapXML += '</v17:EMailNotificationDetail>';
                                    
                                    soapXML += '<v17:ReturnShipmentDetail>';
                                        soapXML += '<v17:ReturnType>PENDING</v17:ReturnType>';
                                        soapXML += '<v17:Rma>';
                                            soapXML += '<v17:Reason>RMA REASON</v17:Reason>';
                                        soapXML += '</v17:Rma>';
                                        soapXML += '<v17:ReturnEMailDetail>';
                                            soapXML += '<v17:MerchantPhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</v17:MerchantPhoneNumber>';
                                            soapXML += '<v17:AllowedSpecialServices>SATURDAY_DELIVERY</v17:AllowedSpecialServices>';
                                        soapXML += '</v17:ReturnEMailDetail>';
                                    soapXML += '</v17:ReturnShipmentDetail>'; 
                                    
                                    soapXML += '<v17:PendingShipmentDetail>';
                                        soapXML += '<v17:Type>EMAIL</v17:Type>';
                                        // Need to confirm from fareed for Future Date
                                        //soapXML += '<v17:ExpirationDate>' + futureDate + '</v17:ExpirationDate>';
                                        soapXML += '<v17:EmailLabelDetail>';
                                            soapXML += '<v17:Message>'+ shipment.Message__c +'</v17:Message>';
                                            soapXML += '<v17:Recipients>';
                                                soapXML += '<v17:EmailAddress>'+ toAddress.Contact__r.Email.escapeXml() +'</v17:EmailAddress>';
                                                soapXML += '<v17:Role>SHIPMENT_COMPLETOR</v17:Role>';
                                            soapXML += '</v17:Recipients>';
                                        soapXML += '</v17:EmailLabelDetail>';
                                    soapXML += '</v17:PendingShipmentDetail>';
                                soapXML += '</v17:SpecialServicesRequested>';
                        
                                soapXML += '<v17:LabelSpecification>';
                                    soapXML += '<v17:LabelFormatType>COMMON2D</v17:LabelFormatType>';
                                    soapXML += '<v17:ImageType>PNG</v17:ImageType>';
                                    soapXML += '<v17:LabelStockType>PAPER_7X4.75</v17:LabelStockType>';
                                soapXML += '</v17:LabelSpecification>';
                            
                                soapXML += '<v17:PackageCount>1</v17:PackageCount>';
                                
                                soapXML += '<v17:RequestedPackageLineItems>';
                                    soapXML += '<v17:SequenceNumber>1</v17:SequenceNumber>';
                                    soapXML += '<v17:Weight>';    
                                        if(packList[0].Weight_Unit__c == 'KGS') soapXML += '<v17:Units>KG</v17:Units>'; else soapXML += '<v17:Units>LB</v17:Units>';
                                        soapXML += '<v17:Value>' + packList[0].Weight__c + '</v17:Value>';
                                    soapXML += '</v17:Weight>';
                                    soapXML += '<v17:Dimensions>';
                                        soapXML += '<v17:Length>'+ Integer.valueOf(packList[0].Length__c) +'</v17:Length>';
                                        soapXML += '<v17:Width>'+ Integer.valueOf(packList[0].Width__c) +'</v17:Width>';
                                        soapXML += '<v17:Height>'+ Integer.valueOf(packList[0].Height__c) +'</v17:Height>';
                                        if(packList[0].Weight_Unit__c == 'KGS') soapXML += '<v17:Units>CM</v17:Units>'; else soapXML += '<v17:Units>IN</v17:Units>';
                                    soapXML += '</v17:Dimensions>';
                                    soapXML += '<v17:ItemDescription>Test lable desc.</v17:ItemDescription>';
                                    soapXML += '<v17:CustomerReferences>';
                                        soapXML += '<v17:CustomerReferenceType>CUSTOMER_REFERENCE</v17:CustomerReferenceType>';
                                        soapXML += '<v17:Value>' + Packages[0].Return_Merchandise_Authorisation__r.Name + '</v17:Value>';
                                    soapXML += '</v17:CustomerReferences>';
                                    soapXML += '<v17:CustomerReferences>';
                                        soapXML += '<v17:CustomerReferenceType>RMA_ASSOCIATION</v17:CustomerReferenceType>';
                                        soapXML += '<v17:Value>' + Packages[0].Return_Merchandise_Authorisation__r.Name + '</v17:Value>';
                                    soapXML += '</v17:CustomerReferences>';
                                soapXML += '</v17:RequestedPackageLineItems>';
        
                            soapXML += '</v17:RequestedShipment>';
                                
                        soapXML += '</v17:CreatePendingShipmentRequest>';
                    soapXML += '</soapenv:Body>';
                soapXML += '</soapenv:Envelope>';
                
                
                HttpRequest req = new HttpRequest();
                Http h = new Http();
                
                req.setBody(soapXML);   
                req.setMethod('POST');
                req.setEndpoint(endpoint);
                req.setHeader('Content-length', '200');
                req.setHeader('Accept', 'image/gif'); 
                req.setHeader('Content-Type', 'text/xml');
                req.setHeader('SOAPAction', '');
                //req.setHeader('Host', 'wsbeta.fedex.com');
                
                HttpResponse res = h.send(req);             
                request_1 = soapXML;
                response_1 = res.getBody(); 
                resStatus = res.getStatus();
            }
            
            String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v17="http://fedex.com/ws/ship/v23">';
                soapXML += '<soapenv:Body>';
                    soapXML += '<v17:ProcessShipmentRequest>';
                           
                        soapXML += '<v17:WebAuthenticationDetail>';
                            if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                soapXML += '<v17:ParentCredential>';
                                    soapXML += '<v17:Key>' + parentkey.escapeXml() + '</v17:Key>';
                                    soapXML += '<v17:Password>' + parentPassword.escapeXml() + '</v17:Password>';
                                soapXML += '</v17:ParentCredential>';
                            }
                            soapXML += '<v17:UserCredential>';
                                soapXML += '<v17:Key>' + key.escapeXml() + '</v17:Key>';
                                soapXML += '<v17:Password>' + password.escapeXml() + '</v17:Password>';
                            soapXML += '</v17:UserCredential>';
                        soapXML += '</v17:WebAuthenticationDetail>';
                         
                        soapXML += '<v17:ClientDetail>';
                            soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>';
                            soapXML += '<v17:MeterNumber>' + meterNumber.escapeXml() + '</v17:MeterNumber>';
                        soapXML += '</v17:ClientDetail>';
                        
                        soapXML += '<v17:TransactionDetail>';
                            soapXML += '<v17:CustomerTransactionId>'+ toAddress.Contact__r.Name.escapeXml() +'</v17:CustomerTransactionId>';
                        soapXML += '</v17:TransactionDetail>';
                        
                        soapXML += '<v17:Version>';
                            soapXML += '<v17:ServiceId>ship</v17:ServiceId>';
                            soapXML += '<v17:Major>23</v17:Major>';
                            soapXML += '<v17:Intermediate>0</v17:Intermediate>';
                            soapXML += '<v17:Minor>0</v17:Minor>'; 
                        soapXML += '</v17:Version>';
                         
                        soapXML += '<v17:RequestedShipment>';
                            soapXML += '<v17:ShipTimestamp>' + ShipDateStamp + '</v17:ShipTimestamp>';
                            soapXML += '<v17:DropoffType>REGULAR_PICKUP</v17:DropoffType>';
                            soapXML += '<v17:ServiceType>' + Service + '</v17:ServiceType>';
                            soapXML += '<v17:PackagingType>YOUR_PACKAGING</v17:PackagingType>';
                              
                            soapXML+= '<v17:TotalWeight>'; 
                                if(weightUnit == 'KGS') soapXML += '<v17:Units>KG</v17:Units>'; else soapXML += '<v17:Units>LB</v17:Units>';                         
                                soapXML+= '<v17:Value>'+ toalWeightValue +'</v17:Value>';
                            soapXML+= '</v17:TotalWeight>';
                            
                            if(upsCredentials != null && upsCredentials.size() > 0) {
                                soapXML += '<v17:Shipper>';
                                    //Working
                                    soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>';
                                    
                                    //Working
                                    //soapXML += '<v17:Tins>';
                                      //  soapXML += '<v17:TinType>PERSONAL_STATE</v17:TinType>';
                                        //soapXML += '<v17:Number>123456789</v17:Number>';
                                    //soapXML += '</v17:Tins>';
                                    
                                    
                                    soapXML += '<v17:Contact>';
                                        soapXML += '<v17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</v17:PersonName>';
                                        soapXML += '<v17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</v17:CompanyName>';
                                        soapXML += '<v17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</v17:PhoneNumber>';
                                    soapXML += '</v17:Contact>';
                                    
                                    soapXML += '<v17:Address>';
                                        soapXML += '<v17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</v17:StreetLines>';
                                        soapXML += '<v17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</v17:City>';
                                        if(shipperProvinceCode != null) soapXML += '<v17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</v17:StateOrProvinceCode>';
                                        soapXML += '<v17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</v17:PostalCode>';
                                        if(shipperCountryCode != null)  soapXML += '<v17:CountryCode>'+ shipperCountryCode.escapeXml() +'</v17:CountryCode>';
                                    soapXML += '</v17:Address>';
                                soapXML += '</v17:Shipper>';
                            }
                            
                            if(toAddress != null) {
                                soapXML += '<v17:Recipient>';
                                    
                                    soapXML += '<v17:Contact>';
                                        soapXML += '<v17:PersonName>'+ toAddress.Contact__r.Name.escapeXml() +'</v17:PersonName>';
                                        if(toAddress.Contact__r.Company__c != null) soapXML += '<v17:CompanyName>'+ toAddress.Contact__r.Company__c.escapeXml() +'</v17:CompanyName>';
                                        if(toAddress.Contact__r.Phone != null) soapXML += '<v17:PhoneNumber>'+ toAddress.Contact__r.Phone.escapeXml() +'</v17:PhoneNumber>';
                                        if(toAddress.Contact__r.Email != null) soapXML += '<v17:EMailAddress>'+ toAddress.Contact__r.Email.escapeXml() +'</v17:EMailAddress>';
                                    soapXML += '</v17:Contact>';
                                    
                                    soapXML += '<v17:Address>';
                                        soapXML += '<v17:StreetLines>' + DestinationStreet.escapeXml() + '</v17:StreetLines>';
                                        soapXML += '<v17:City>' + toAddress.City__c.escapeXml() + '</v17:City>';
                                        if(DestinationProvinceCode != null) soapXML += '<v17:StateOrProvinceCode>' + DestinationProvinceCode.escapeXml() + '</v17:StateOrProvinceCode>';
                                        soapXML += '<v17:PostalCode>' + toAddress.Postal_Code__c.escapeXml() + '</v17:PostalCode>';
                                        if(DestinationCountryCode != null) soapXML += '<v17:CountryCode>' + DestinationCountryCode.escapeXml() + '</v17:CountryCode>';
                                    soapXML += '</v17:Address>';
                                soapXML += '</v17:Recipient>';
                            }
                            
                            soapXML += '<v17:ShippingChargesPayment>';  
                                soapXML += '<v17:PaymentType>SENDER</v17:PaymentType>';
                                soapXML += '<v17:Payor>';
                                     
                                    soapXML += '<v17:ResponsibleParty>';
                                        soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>';
                                        // Working
                                        //soapXML += '<v17:Contact>';
                                          //  soapXML += '<v17:PersonName>12345</v17:PersonName>';
                                        //soapXML += '</v17:Contact>';
                                        
                                        soapXML += '<v17:Contact>';
                                            soapXML += '<v17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</v17:PersonName>';
                                            soapXML += '<v17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</v17:CompanyName>';
                                            soapXML += '<v17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</v17:PhoneNumber>';
                                        soapXML += '</v17:Contact>';
                                        soapXML += '<v17:Address>';
                                            soapXML += '<v17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</v17:StreetLines>';
                                            soapXML += '<v17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</v17:City>';
                                            if(shipperProvinceCode != null) soapXML += '<v17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</v17:StateOrProvinceCode>';
                                            soapXML += '<v17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</v17:PostalCode>';
                                            if(shipperCountryCode != null) soapXML += '<v17:CountryCode>'+ shipperCountryCode.escapeXml() +'</v17:CountryCode>';
                                        soapXML += '</v17:Address>';
                                    soapXML += '</v17:ResponsibleParty>';
                                    
                                    
                                    //soapXML += '<v17:ResponsibleParty>';
                                      //  soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>';
                                        //soapXML += '<v17:AccountNumber>150067600</v17:AccountNumber>';
                                       
                                       // soapXML += '<v17:Contact>';
                                        //    soapXML += '<v17:PersonName>CSP testing</v17:PersonName>';
                                       // soapXML += '</v17:Contact>';
                                      //  soapXML += '<v17:Address>';
                                            //if(shipperCountryCode != null) soapXML += '<v17:CountryCode>'+ shipperCountryCode.escapeXml() +'</v17:CountryCode>';
                                        //soapXML += '</v17:Address>';
                                    //soapXML += '</v17:ResponsibleParty>';
                                    
                                soapXML += '</v17:Payor>'; 
                            soapXML += '</v17:ShippingChargesPayment>';
                            
                            //  Working
                            if(packList[0].ETD__c == true){   
                                soapXML += '<v17:SpecialServicesRequested>';
                                    soapXML += '<v17:SpecialServiceTypes>ELECTRONIC_TRADE_DOCUMENTS</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:EtdDetail>';
                                        soapXML += '<v17:RequestedDocumentCopies>COMMERCIAL_INVOICE</v17:RequestedDocumentCopies>';
                                        soapXML += '<v17:DocumentReferences>';
                                            //soapXML += '<v17:LineNumber>200</v17:LineNumber>';
                                            //soapXML += '<v17:DocumentProducer>OTHER</v17:DocumentProducer>';
                                            soapXML += '<v17:DocumentType>ETD_LABEL</v17:DocumentType>';
                                            soapXML += '<v17:DocumentId>'+ docId +'</v17:DocumentId>';
                                            //soapXML += '<v17:DocumentIdProducer>FEDEX_CSHP</v17:DocumentIdProducer>';
                                        soapXML += '</v17:DocumentReferences>';
                                    soapXML += '</v17:EtdDetail>';
                                soapXML += '</v17:SpecialServicesRequested>';
                            }
                            //
                            
                            //Working
                            //soapXML += '<v17:SpecialServicesRequested>';
                              //  soapXML += '<v17:SpecialServiceTypes>RETURNS_CLEARANCE</v17:SpecialServiceTypes>';
                                //soapXML += '<v17:ReturnShipmentDetail>';
                                  //  soapXML += '<v17:ReturnType>PRINT_RETURN_LABEL</v17:ReturnType>';
                                //soapXML += '</v17:ReturnShipmentDetail>';
                            //soapXML += '</v17:SpecialServicesRequested>';
                            
                             
                            //Working
                            if(retValue == 'SR') {
                                soapXML += '<v17:SpecialServicesRequested>';
                                    //soapXML += '<v17:SpecialServiceTypes>BROKER_SELECT_OPTION</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:SpecialServiceTypes>RETURN_SHIPMENT</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:ReturnShipmentDetail>';
                                        soapXML += '<v17:ReturnType>PRINT_RETURN_LABEL</v17:ReturnType>';
                                    soapXML += '</v17:ReturnShipmentDetail>';
                                soapXML += '</v17:SpecialServicesRequested>'; 
                            }   
                            
                            
                             
                            // Working
                            //soapXML += '<v17:SpecialServicesRequested>';
                              //  soapXML += '<v17:SpecialServiceTypes>HOLD_AT_LOCATION</v17:SpecialServiceTypes>';
                                //soapXML += '<v17:HoldAtLocationDetail>';
                                   // soapXML += '<v17:PhoneNumber>9012633035</v17:PhoneNumber>';
                                   // soapXML += '<v17:LocationContactAndAddress>';
                                       // soapXML += '<v17:Contact>';
                                          //  soapXML += '<v17:PersonName>James Weston</v17:PersonName>';
                                           // soapXML += '<v17:CompanyName>RTC</v17:CompanyName>';
                                           // soapXML += '<v17:PhoneNumber>9012633035</v17:PhoneNumber>';
                                       // soapXML += '</v17:Contact>';
                                       // soapXML += '<v17:Address>';
                                           // soapXML += '<v17:StreetLines>Via Vittorio Veneto 12</v17:StreetLines>';
                                           // soapXML += '<v17:City>Legnaro</v17:City>';
                                            //soapXML += '<v17:StateOrProvinceCode>TN</v17:StateOrProvinceCode>';
                                          //  soapXML += '<v17:PostalCode>35020</v17:PostalCode>';
                                           // soapXML += '<v17:CountryCode>IT</v17:CountryCode>';
                                      //  soapXML += '</v17:Address>'; 
                                   // soapXML += '</v17:LocationContactAndAddress>';
                                  //  soapXML += '<v17:LocationType>FEDEX_EXPRESS_STATION</v17:LocationType>';  
                                    //soapXML += '<v17:LocationId>1</v17:LocationId>';  
                                    //soapXML += '<v17:LocationNumber>1</v17:LocationNumber>';
                              //  soapXML += '</v17:HoldAtLocationDetail>';
                            //soapXML += '</v17:SpecialServicesRequested>';
                            //   
                            
                            //Working
                           // soapXML += '<v17:ExpressFreightDetail>';
                             //   soapXML += '<v17:PackingListEnclosed>1</v17:PackingListEnclosed>';
                               // soapXML += '<v17:ShippersLoadAndCount>101</v17:ShippersLoadAndCount>';
                                //soapXML += '<v17:BookingConfirmationNumber>123456789</v17:BookingConfirmationNumber>';
                           // soapXML += '</v17:ExpressFreightDetail>';
                            
                            
                            if(OriginCountryCode != DestinationCountryCode) {
                                                     
                                soapXML += '<v17:CustomsClearanceDetail>';
                                    // Working
                                   // soapXML += '<v17:Brokers>';
                                       // soapXML += '<v17:Type>IMPORT</v17:Type>';
                                        //soapXML += '<v17:Broker>';
                                          //  soapXML += '<v17:AccountNumber>222326460</v17:AccountNumber>';
                                            //soapXML += '<v17:Tins>';
                                              //  soapXML += '<v17:TinType>PERSONAL_STATE</v17:TinType>';
                                                //soapXML += '<v17:Number>1234567890</v17:Number>';
                                           // soapXML += '</v17:Tins>';
                                            //soapXML += '<v17:Contact>';
                                              //  soapXML += '<v17:ContactId>12345</v17:ContactId>';
                                                //soapXML += '<v17:PersonName>Shayilaja</v17:PersonName>';
                                                //soapXML += '<v17:Title>Mr.</v17:Title>';
                                              //  soapXML += '<v17:CompanyName>CompanyName</v17:CompanyName>';
                                                //soapXML += '<v17:PhoneNumber>8975898616</v17:PhoneNumber>';
                                               // soapXML += '<v17:PhoneExtension>3293</v17:PhoneExtension>';
                                               // soapXML += '<v17:EMailAddress>csptesting@xyz.com</v17:EMailAddress>';
                                          //  soapXML += '</v17:Contact>';
                                            //soapXML += '<v17:Address>';
                                              //  soapXML += '<v17:StreetLines>FEDEX PARKWAY</v17:StreetLines>';
                                                //soapXML += '<v17:City>ROME</v17:City>';
                                                //soapXML += '<v17:StateOrProvinceCode>IT</v17:StateOrProvinceCode>';
                                                //soapXML += '<v17:PostalCode>44030</v17:PostalCode>';
                                                //soapXML += '<v17:CountryCode>IT</v17:CountryCode>';
                                           // soapXML += '</v17:Address>';
                                        //soapXML += '</v17:Broker>'; 
                                    //soapXML += '</v17:Brokers>';
                                    
                                     
                                    //Working     
                                    //soapXML += '<v17:CustomsOptions>';
                                      //  soapXML += '<v17:Type>FAULTY_ITEM</v17:Type>';
                                        //soapXML += '<v17:Type>OTHER</v17:Type>';
                                       // soapXML += '<v17:Description>Sample</v17:Description>';
                                   // soapXML += '</v17:CustomsOptions>';
                                     
                                    
                                    // Working
                                   //start mulit commment
                                   // soapXML += '<v17:ImporterOfRecord>';
                                        soapXML += '<v17:AccountNumber>605517846</v17:AccountNumber>';
                                        soapXML += '<v17:Tins>';
                                            soapXML += '<v17:TinType>PERSONAL_STATE</v17:TinType>';
                                            soapXML += '<v17:Number>1234567890</v17:Number>';
                                        soapXML += '</v17:Tins>';
                                        soapXML += '<v17:Contact>';
                                            soapXML += '<v17:ContactId>12345</v17:ContactId>';
                                            soapXML += '<v17:PersonName>Takshak</v17:PersonName>';
                                            soapXML += '<v17:Title>Mr.</v17:Title>';
                                            soapXML += '<v17:CompanyName>CompanyName</v17:CompanyName>';
                                            soapXML += '<v17:PhoneNumber>8975898616</v17:PhoneNumber>';
                                            soapXML += '<v17:PhoneExtension>3293</v17:PhoneExtension>';
                                            soapXML += '<v17:EMailAddress>csptesting@xyz.com</v17:EMailAddress>';
                                        soapXML += '</v17:Contact>';
                                        soapXML += '<v17:Address>';
                                            soapXML += '<v17:StreetLines>80 Fedex Prkwy</v17:StreetLines>';
                                            soapXML += '<v17:City>Winnipeg</v17:City>';
                                            soapXML += '<v17:StateOrProvinceCode>MB</v17:StateOrProvinceCode>';
                                            soapXML += '<v17:PostalCode>R3Y1V3</v17:PostalCode>';
                                            soapXML += '<v17:CountryCode>CA</v17:CountryCode>';
                                        soapXML += '</v17:Address>';
                                    soapXML += '</v17:ImporterOfRecord>';
                                     //end mulit commment
                                    
                                    
                                     //start mulit commment 
                                     * Working
                                    soapXML += '<v17:RecipientCustomsId>';
                                        soapXML += '<v17:Type>PASSPORT</v17:Type>';
                                        soapXML += '<v17:Value>12345678</v17:Value>';
                                    soapXML += '</v17:RecipientCustomsId>';
                                     //end mulit commment
 
                                    soapXML += '<v17:DutiesPayment>';             
                                        soapXML += '<v17:PaymentType>SENDER</v17:PaymentType>';
                                        soapXML += '<v17:Payor>';
                                             
                                            soapXML += '<v17:ResponsibleParty>';
                                                soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>'; 
                                                soapXML += '<v17:Contact>';
                                                    //Commented as hard coded name passed
                                                    soapXML += '<v17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</v17:PersonName>';
                                                    soapXML += '<v17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</v17:CompanyName>';
                                                    soapXML += '<v17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</v17:PhoneNumber>';
                                                soapXML += '</v17:Contact>';
                                                soapXML += '<v17:Address>';
                                                    soapXML += '<v17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</v17:StreetLines>';
                                                    soapXML += '<v17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</v17:City>';
                                                    if(shipperProvinceCode != null) soapXML += '<v17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</v17:StateOrProvinceCode>';
                                                    soapXML += '<v17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</v17:PostalCode>';
                                                    if(shipperCountryCode != null) soapXML += '<v17:CountryCode>'+ shipperCountryCode.escapeXml() +'</v17:CountryCode>';
                                                soapXML += '</v17:Address>';
                                            soapXML += '</v17:ResponsibleParty>';
                                            
                                              //start mulit commment
                                            soapXML += '<v17:ResponsibleParty>';
                                                soapXML += '<v17:AccountNumber>' + accountNumber.escapeXml() + '</v17:AccountNumber>'; 
                                                //soapXML += '<v17:AccountNumber>214877600</v17:AccountNumber>'; 
                                                soapXML += '<v17:Contact>';
                                                    soapXML += '<v17:PersonName>CSP testing</v17:PersonName>';
                                                soapXML += '</v17:Contact>';
                                                soapXML += '<v17:Address>';
                                                    if(shipperCountryCode != null) soapXML += '<v17:CountryCode>'+ shipperCountryCode.escapeXml() +'</v17:CountryCode>';
                                                soapXML += '</v17:Address>';
                                            soapXML += '</v17:ResponsibleParty>';
                                            //  //end mulit commment
                                        soapXML += '</v17:Payor>';
                                    soapXML += '</v17:DutiesPayment>';        
                                    
                                    
                                    soapXML += '<v17:DocumentContent>NON_DOCUMENTS</v17:DocumentContent>';
                                              
                                    soapXML += '<v17:CustomsValue>';
                                        soapXML += '<v17:Currency>'+ CurrCode +'</v17:Currency>';
                                        soapXML += '<v17:Amount>'+ totalDeclaredValue +'</v17:Amount>';
                                    soapXML += '</v17:CustomsValue>';
                                    
                                    soapXML += '<v17:InsuranceCharges>';
                                        soapXML += '<v17:Currency>'+ CurrCode +'</v17:Currency>';
                                        soapXML += '<v17:Amount>100</v17:Amount>';
                                    soapXML += '</v17:InsuranceCharges>';
                                                    
                                    soapXML += '<v17:CommercialInvoice>';
                                        soapXML += '<v17:Comments>FEDEX BUSINESS</v17:Comments>';
                                        soapXML += '<v17:FreightCharge>';
                                            soapXML += '<v17:Currency>'+ CurrCode +'</v17:Currency>';
                                            soapXML += '<v17:Amount>100</v17:Amount>';
                                        soapXML += '</v17:FreightCharge>';
                                        soapXML += '<v17:TaxesOrMiscellaneousCharge>';
                                            soapXML += '<v17:Currency>'+ CurrCode +'</v17:Currency>';
                                            soapXML += '<v17:Amount>25</v17:Amount>';
                                        soapXML += '</v17:TaxesOrMiscellaneousCharge>';
                                        soapXML += '<v17:Purpose>'+ shipment.Reason_For_Export__c +'</v17:Purpose>';
                                        soapXML += '<v17:CustomerReferences>';
                                            soapXML += '<v17:CustomerReferenceType>CUSTOMER_REFERENCE</v17:CustomerReferenceType>';
                                            soapXML += '<v17:Value>123456789</v17:Value>';
                                        soapXML += '</v17:CustomerReferences>';
                                        soapXML += '<v17:OriginatorName>Originator Name</v17:OriginatorName>';
                                    soapXML += '</v17:CommercialInvoice>';
                                                    
                                    List<Product_Unit_Code__c> productType; 
                                    if(Shipment.Product_Unit_Code__c != null) productType = [select Id, Name, Product_Code__c, Product_Description__c from Product_Unit_Code__c where Product_Description__c =: Shipment.Product_Unit_Code__c limit 1];                    
                                    for(Package_List__c pl: pkgList) {
                                        soapXML += '<v17:Commodities>';  
                                            if(pl.Sales_Order_Line_Item__c != null) { soapXML += '<v17:Name>'+ pl.Sales_Order_Line_Item__r.Product__r.Name +'</v17:Name>'; }
                                            else if(pl.Work_Order_Line_Items__c != null) { soapXML += '<v17:Name>'+ pl.Work_Order_Line_Items__r.Product__r.Name +'</v17:Name>'; }
                                            else if(pl.Purchase_Line_Items__c != null) { soapXML += '<v17:Name>'+ pl.Purchase_Line_Items__r.Product__r.Name +'</v17:Name>'; }
                                            else if(pl.Transfer_Order_Line_Item__c != null) { soapXML += '<v17:Name>'+ pl.Transfer_Order_Line_Item__r.Products__r.Name +'</v17:Name>'; }
                                            else if(pl.RMA_Line_Item__c != null) { soapXML += '<v17:Name>'+ pl.RMA_Line_Item__r.SOLI__r.Product__r.Name +'</v17:Name>'; }                                
                                            
                                            soapXML += '<v17:NumberOfPieces>'+ Integer.valueOf(pl.Quantity__c) +'</v17:NumberOfPieces>';
                                            
                                            if(pl.Sales_Order_Line_Item__c != null) { soapXML += '<v17:Description>'+ pl.Sales_Order_Line_Item__r.Product__r.Name +'</v17:Description>';  }
                                            else if(pl.Work_Order_Line_Items__c != null) { soapXML += '<v17:Description>'+ pl.Work_Order_Line_Items__r.Product__r.Name +'</v17:Description>'; }
                                            else if(pl.Purchase_Line_Items__c != null) { soapXML += '<v17:Description>'+ pl.Purchase_Line_Items__r.Product__r.Name +'</v17:Description>'; }
                                            else if(pl.Transfer_Order_Line_Item__c != null) { soapXML += '<v17:Description>'+ pl.Transfer_Order_Line_Item__r.Products__r.Name +'</v17:Description>'; }
                                            else if(pl.RMA_Line_Item__c != null) { soapXML += '<v17:Description>'+ pl.RMA_Line_Item__r.SOLI__r.Product__r.Name +'</v17:Description>'; }                                
                                                                            
                                            if(originCountryCode != null) soapXML += '<v17:CountryOfManufacture>'+ originCountryCode.escapeXML() +'</v17:CountryOfManufacture>';
                                            
                                            if(pl.Sales_Order_Line_Item__c != null && pl.Sales_Order_Line_Item__r.Product__r.Commodity_Code__c != null) { soapXML += '<v17:HarmonizedCode>'+ pl.Sales_Order_Line_Item__r.Product__r.Commodity_Code__c +'</v17:HarmonizedCode>'; }
                                            else if(pl.Work_Order_Line_Items__c != null && pl.Work_Order_Line_Items__r.Product__r.Commodity_Code__c != null) { soapXML += '<v17:HarmonizedCode>'+ pl.Work_Order_Line_Items__r.Product__r.Commodity_Code__c +'</v17:HarmonizedCode>'; }
                                            else if(pl.Purchase_Line_Items__c != null && pl.Purchase_Line_Items__r.Product__r.Commodity_Code__c != null) { soapXML += '<v17:HarmonizedCode>'+ pl.Purchase_Line_Items__r.Product__r.Commodity_Code__c +'</v17:HarmonizedCode>'; }
                                            else if(pl.Transfer_Order_Line_Item__c != null && pl.Transfer_Order_Line_Item__r.Products__r.Commodity_Code__c != null) { soapXML += '<v17:HarmonizedCode>'+ pl.Transfer_Order_Line_Item__r.Products__r.Commodity_Code__c +'</v17:HarmonizedCode>'; }
                                            else if(pl.RMA_Line_Item__c != null && pl.RMA_Line_Item__r.SOLI__r.Product__r.Commodity_Code__c !=  null) { soapXML += '<v17:HarmonizedCode>'+ pl.RMA_Line_Item__r.SOLI__r.Product__r.Commodity_Code__c +'</v17:HarmonizedCode>'; }                                
                                            
                                            soapXML += '<v17:Weight>';
                                                if(pl.Package__r.Weight_Unit__c == 'KGS') soapXMl += '<v17:Units>KG</v17:Units>'; else soapXMl += '<v17:Units>LB</v17:Units>';
                                                soapXML += '<v17:Value>' + pl.Package__r.Weight__c + '</v17:Value>';
                                            soapXML += '</v17:Weight>';                                 
                                            soapXML += '<v17:Quantity>'+ Integer.valueOf(pl.Quantity__c) +'</v17:Quantity>';                                
                                            if(productType != null) soapXML += '<v17:QuantityUnits>'+ productType[0].Product_Code__c.escapeXml() +'</v17:QuantityUnits>';
                                             
                                            soapXML += '<v17:UnitPrice>';
                                                soapXML += '<v17:Currency>'+ CurrCode +'</v17:Currency>';
                                                if(pl.Sales_Order_Line_Item__c != null) { soapXML += '<v17:Amount>'+ pl.Sales_Order_Line_Item__r.Price_Product__c +'</v17:Amount>'; }
                                                else if(pl.Work_Order_Line_Items__c != null) { soapXML += '<v17:Amount>'+ pl.Work_Order_Line_Items__r.Unit_Price__c +'</v17:Amount>'; }
                                                else if(pl.Purchase_Line_Items__c != null) { soapXML += '<v17:Amount>'+ pl.Purchase_Line_Items__r.Unit_Price__c +'</v17:Amount>'; }
                                                else if(pl.Transfer_Order_Line_Item__c != null) { soapXML += '<v17:Amount>0</v17:Amount>'; }
                                                else if(pl.RMA_Line_Item__c != null) { soapXML += '<v17:Amount>'+ pl.RMA_Line_Item__r.Total_Deduction__c +'</v17:Amount>'; }                        
                                            soapXML += '</v17:UnitPrice>';
                                            
                                            soapXML += '<v17:CustomsValue>';
                                                soapXML += '<v17:Currency>'+ CurrCode +'</v17:Currency>';
                                                if(pl.Sales_Order_Line_Item__c != null) { soapXML += '<v17:Amount>'+ pl.Sales_Order_Line_Item__r.Product__r.Declared_Shipment_Value__c +'</v17:Amount>'; }
                                                else if(pl.Work_Order_Line_Items__c != null) { soapXML += '<v17:Amount>'+ pl.Work_Order_Line_Items__r.Product__r.Declared_Shipment_Value__c +'</v17:Amount>'; }
                                                else if(pl.Purchase_Line_Items__c != null) { soapXML += '<v17:Amount>'+ pl.Purchase_Line_Items__r.Product__r.Declared_Shipment_Value__c +'</v17:Amount>'; }
                                                else if(pl.Transfer_Order_Line_Item__c != null) { soapXML += '<v17:Amount>'+ pl.Transfer_Order_Line_Item__r.Products__r.Declared_Shipment_Value__c +'</v17:Amount>'; }
                                                else if(pl.RMA_Line_Item__c != null) { soapXML += '<v17:Amount>'+ pl.RMA_Line_Item__r.SOLI__r.Product__r.Declared_Shipment_Value__c +'</v17:Amount>'; }                                    
                                            soapXML += '</v17:CustomsValue>';                
                                        soapXML += '</v17:Commodities>';   
                                    }
                                    
                                    soapXML += '<v17:ExportDetail>';
                                        soapXML += '<v17:B13AFilingOption>NOT_REQUIRED</v17:B13AFilingOption>';
                                        soapXML += '<v17:ExportComplianceStatement>NO EEI 30.37(f)</v17:ExportComplianceStatement>';
                                    soapXML += '</v17:ExportDetail>';
                                                                          
                                soapXML += '</v17:CustomsClearanceDetail>';
                                
                            }
                            
                            /
//Working
                           // soapXML += '<v17:SpecialServicesRequested>';
                            //    soapXML += '<v17:SpecialServiceTypes>SATURDAY_DELIVERY</v17:SpecialServiceTypes>';
                            //soapXML += '</v17:SpecialServicesRequested>';
                            
                             
                            soapXML += '<v17:LabelSpecification>';
                                soapXML += '<v17:LabelFormatType>COMMON2D</v17:LabelFormatType>';
                                soapXML += '<v17:ImageType>ZPLII</v17:ImageType>';
                                soapXML += '<v17:LabelStockType>STOCK_4X6</v17:LabelStockType>';
                            soapXML += '</v17:LabelSpecification>';
                              
                            / //start mulit commment
                             * Working
                            if(OriginCountryCode != DestinationCountryCode) {
                                soapXML += '<v17:ShippingDocumentSpecification>';
                                    soapXML += '<v17:ShippingDocumentTypes>COMMERCIAL_INVOICE</v17:ShippingDocumentTypes>';
                                    //soapXML += '<CertificateOfOrigin>';
                                    //    soapXML += '<DocumentFormat>';
                                    //        soapXML += '<ImageType>PDF</ImageType>';
                                    //        soapXML += '<StockType>PAPER_LETTER</StockType>';
                                    //        soapXML += '<ProvideInstructions>true</ProvideInstructions>';
                                    //    soapXML += '</DocumentFormat>';
                                    //soapXML += '</CertificateOfOrigin>';
                                    
                                    soapXML += '<v17:CommercialInvoiceDetail>';
                                        soapXML += '<v17:Format>';
                                            soapXML += '<v17:ImageType>PDF</v17:ImageType>';
                                            soapXML += '<v17:StockType>PAPER_LETTER</v17:StockType>';
                                        soapXML += '</v17:Format>';
                                    soapXML += '</v17:CommercialInvoiceDetail>';
                                soapXML += '</v17:ShippingDocumentSpecification>';
                            }
                             //end mulit commment  
                            
                            
                            soapXML += '<v17:RateRequestTypes>LIST</v17:RateRequestTypes>';
                            
                            if(packList != null && packList.size() > 0) soapXML += '<v17:PackageCount>'+ packList.size() +'</v17:PackageCount>';
                            
                            soapXML += '<v17:RequestedPackageLineItems>';
                                soapXML += '<v17:SequenceNumber>1</v17:SequenceNumber>';
                                // Working
                                soapXML += '<v17:InsuredValue>'; 
                                    soapXML += '<v17:Currency>'+ CurrCode +'</v17:Currency>';
                                    soapXML += '<v17:Amount>100.00</v17:Amount>';    
                                soapXML += '</v17:InsuredValue>';        
                                //         
                                soapXML += '<v17:Weight>';    
                                    if(packList[0].Weight_Unit__c == 'KGS') soapXML += '<v17:Units>KG</v17:Units>';
                                    else soapXML += '<v17:Units>LB</v17:Units>';
                                    soapXML += '<v17:Value>' + packList[0].Weight__c + '</v17:Value>';
                                soapXML += '</v17:Weight>'; 
                                
                                if(packList[0].Package_Type__c != 'Pak' && packList[0].Package_Type__c != 'Box' && packList[0].Package_Type__c != '25KG Box' && packList[0].Package_Type__c != '10KG Box'){  
                                    soapXML += '<v17:Dimensions>';
                                        soapXML += '<v17:Length>'+ Integer.valueOf(packList[0].Length__c) +'</v17:Length>';
                                        soapXML += '<v17:Width>'+ Integer.valueOf(packList[0].Width__c) +'</v17:Width>';
                                        soapXML += '<v17:Height>'+ Integer.valueOf(packList[0].Height__c) +'</v17:Height>';
                                        if(packList[0].Weight_Unit__c == 'KGS') soapXML += '<v17:Units>CM</v17:Units>';
                                        else soapXML += '<v17:Units>IN</v17:Units>';
                                    soapXML += '</v17:Dimensions>';
                                }  
                                 
                                soapXML += '<v17:CustomerReferences>';
                                    soapXML += '<v17:CustomerReferenceType>CUSTOMER_REFERENCE</v17:CustomerReferenceType>';
                                    soapXML += '<v17:Value>CSP testing</v17:Value>';
                                soapXML += '</v17:CustomerReferences>';    
                                 
                                if(retValue == 'SR') { 
                                    soapXML += '<v17:CustomerReferences>';
                                        soapXML += '<v17:CustomerReferenceType>CUSTOMER_REFERENCE</v17:CustomerReferenceType>';
                                        soapXML += '<v17:Value>' + Packages[0].Return_Merchandise_Authorisation__r.Name + '</v17:Value>';
                                    soapXML += '</v17:CustomerReferences>';
                                    
                                    soapXML += '<v17:CustomerReferences>';
                                        soapXML += '<v17:CustomerReferenceType>RMA_ASSOCIATION</v17:CustomerReferenceType>';
                                        soapXML += '<v17:Value>' + Packages[0].Return_Merchandise_Authorisation__r.Name + '</v17:Value>';
                                    soapXML += '</v17:CustomerReferences>';
                                }
                                
                                // commenting for certification
                                soapXML += '<v17:SpecialServicesRequested>';
                                    soapXML += '<v17:SpecialServiceTypes>SIGNATURE_OPTION</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:SignatureOptionDetail>';
                                        if(Shipment.Signature_Services__c == '' || Shipment.Signature_Services__c == null || Shipment.Signature_Services__c == '--None--'){
                                            soapXML += '<v17:OptionType>SERVICE_DEFAULT</v17:OptionType>';
                                        } else {
                                            soapXML += '<v17:OptionType>'+ Shipment.Signature_Services__c +'</v17:OptionType>';
                                        }
                                    soapXML += '</v17:SignatureOptionDetail>';
                                soapXML += '</v17:SpecialServicesRequested>';
                                //
                                
                                * 
                                 *  //start mulit commment
                                 * Working
                                soapXML += '<v17:SpecialServicesRequested>';
                                    soapXML += '<v17:SpecialServiceTypes>PRIORITY_ALERT</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:PriorityAlertDetail>';   
                                        soapXML += '<v17:Content>TOYS</v17:Content>';
                                    soapXML += '</v17:PriorityAlertDetail>';
                                soapXML += '</v17:SpecialServicesRequested>';
                                //  //end mulit commment
                                    
                             //start mulit commment    
							* Working
                                soapXML += '<v17:SpecialServicesRequested>';
                                    soapXML += '<v17:SpecialServiceTypes>DANGEROUS_GOODS</v17:SpecialServiceTypes>';
                                    soapXML += '<v17:DangerousGoodsDetail>';
                                        soapXML += '<v17:Accessibility>ACCESSIBLE</v17:Accessibility>';
                                        soapXML += '<v17:Containers>';
                                            soapXML += '<v17:ContainerType>PLASTIC JUG</v17:ContainerType>';
                                            soapXML += '<v17:NumberOfContainers>1</v17:NumberOfContainers>';
                                            soapXML += '<v17:HazardousCommodities>';
                                                soapXML += '<v17:Description>';
                                                    soapXML += '<v17:Id>1090</v17:Id>';
                                                    soapXML += '<v17:SequenceNumber>1</v17:SequenceNumber>';
                                                    soapXML += '<v17:PackingGroup>II</v17:PackingGroup>';
                                                    soapXML += '<v17:PackingDetails>';
                                                        soapXML += '<v17:CargoAircraftOnly>0</v17:CargoAircraftOnly>';
                                                        soapXML += '<v17:PackingInstructions>Y341</v17:PackingInstructions>';     
                                                    soapXML += '</v17:PackingDetails>';
                                                    soapXML += '<v17:ProperShippingName>Acetone</v17:ProperShippingName>';
                                                    soapXML += '<v17:HazardClass>3</v17:HazardClass>'; 
                                                soapXML += '</v17:Description>';
                                                soapXML += '<v17:Quantity>';
                                                    soapXML += '<v17:Amount>1</v17:Amount>';
                                                    soapXML += '<v17:Units>L</v17:Units>'; 
                                                soapXML += '</v17:Quantity>';
                                            soapXML += '</v17:HazardousCommodities>'; 
                                        soapXML += '</v17:Containers>';
                                        soapXML += '<v17:Signatory>';
                                            soapXML += '<v17:ContactName>test name</v17:ContactName>';
                                            soapXML += '<v17:Title>tester</v17:Title>';    
                                            soapXML += '<v17:Place>test place</v17:Place>'; 
                                        soapXML += '</v17:Signatory>';
                                        soapXML += '<v17:EmergencyContactNumber>9015551234</v17:EmergencyContactNumber>'; 
                                    soapXML += '</v17:DangerousGoodsDetail>';
                                soapXML += '</v17:SpecialServicesRequested>';
                                *  //end mulit commment
                                 
                                //start mulit commment
                                 * * Working 
                                soapXML += '<v17:SpecialServicesRequested>';
                                    soapXML += '<v17:SpecialServiceTypes>DRY_ICE</v17:SpecialServiceTypes>';        
                                    soapXML += '<v17:DryIceWeight>';   
                                        soapXML += '<v17:Units>KG</v17:Units>';   
                                        soapXML += '<v17:Value>5</v17:Value>';  
                                    soapXML += '</v17:DryIceWeight>';
                                soapXML += '</v17:SpecialServicesRequested>'; 
                                 //end mulit commment
                                 
                            soapXML += '</v17:RequestedPackageLineItems>';
 
                        soapXML += '</v17:RequestedShipment>';
                    soapXML += '</v17:ProcessShipmentRequest>'; 
                soapXML += '</soapenv:Body>';
            soapXML += '</soapenv:Envelope>';
         
        
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);   
            req.setMethod('POST');
            req.setEndpoint(endpoint);
            req.setHeader('Content-length', '200');
            req.setHeader('Accept', 'image/gif'); 
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '');
            //req.setHeader('Host', 'wsbeta.fedex.com');
            
            HttpResponse res = h.send(req);            
            request_1 = soapXmL;
            response_1 = res.getBody(); 
            resStatus = res.getStatus();
            
            String TrackingIdType, CarrierCode, formId; List<String> trackingNoList = new List<String>(); List<String> shipmentImageLists = new List<String>(); List<HttpResponse> responseList = new List<HttpResponse>(); List<XmlStreamReader> xmlReaderList = new List<XmlStreamReader>();
            
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING' || msg == 'NOTE')) { XmlStreamReader reader = res.getXmlStreamReader();
                    XmlStreamReader readerCC = res.getXmlStreamReader(); CarrierCode = readXMLResponse(readerCC, 'CarrierCode');
                    
                    
                    while(reader.hasNext()) {
                         // parsing for total net charges for shipment
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ShipmentRateDetails') {                            
                            
                            while(reader.hasNext()) {
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNetCharge') { reader.next(); 
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); String curr = reader.getText();
                                        reader.next(); reader.next();
                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); amount = reader.getText(); break; } }
                                } reader.next(); }
                        }
                         // parsing master tracking number, trackingId, formId
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CompletedPackageDetails') {
                            
                            while(reader.hasNext()) {
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TrackingIdType') { reader.next(); TrackingIdType = reader.getText(); }
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'FormId') { reader.next(); formId = reader.getText(); }
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TrackingNumber') { reader.next(); MasterTrackingId = reader.getText();   trackingNoList.add(reader.getText());  }
                                 // graphic image
                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Image') { String shipmentImages = '';
                                    while(reader.hasNext()) {
                                        if(reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                                        else if(reader.getEventType() == XmlTag.CHARACTERS) { shipmentImages += reader.getText(); } reader.next();
                                    } shipmentImageLists.add(shipmentImages); }
                                if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'CompletedPackageDetails') break; else reader.next(); 
                            }  } reader.next();
                    }
                } else {
                    XmlStreamReader message = res.getXmlStreamReader(); String resMesage = readXMLResponse(message, 'Message');
                    if (resMesage == 'Minimum dimensions not met for service type.') { response_Message = 'Minimum dimensions of package do not meet for the selected service';
                    } else response_Message = resMesage;
                    Result = 'Unable to retrieve master tracking Id please try again.';
                }
            } else Result = 'Result not available';
             
            if(MasterTrackingId != null && MasterTrackingId != '') {
                 
                for(Integer i=1; i<packList.size(); i++) {
                    String soapXMLi = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:m17="http://fedex.com/ws/ship/v23">';
                        soapXMLi += '<soapenv:Body>';
                            soapXMLi += '<m17:ProcessShipmentRequest>'; 
                                soapXMLi += '<m17:WebAuthenticationDetail>';
                                    if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                        soapXMLi += '<m17:ParentCredential>';
                                            soapXMLi += '<m17:Key>' + parentkey.escapeXml() + '</m17:Key>';
                                            soapXMLi += '<m17:Password>' + parentPassword.escapeXml() + '</m17:Password>';
                                        soapXMLi += '</m17:ParentCredential>';
                                    }
                                    soapXMLi += '<m17:UserCredential>';
                                        soapXMLi += '<m17:Key>' + key.escapeXml() + '</m17:Key>';
                                        soapXMLi += '<m17:Password>' + password.escapeXml() + '</m17:Password>';
                                    soapXMLi += '</m17:UserCredential>';
                                soapXMLi += '</m17:WebAuthenticationDetail>';
                                
                                soapXMLi += '<m17:ClientDetail>';
                                    soapXMLi += '<m17:AccountNumber>' + accountNumber.escapeXml() + '</m17:AccountNumber>';
                                    soapXMLi += '<m17:MeterNumber>' + meterNumber.escapeXml() + '</m17:MeterNumber>';
                                soapXMLi += '</m17:ClientDetail>';
                                      
                                soapXMLi += '<m17:TransactionDetail>';
                                    //soapXMLi += '<m17:CustomerTransactionId>ActiveShipping</m17:CustomerTransactionId>';
                                    soapXMLi += '<m17:CustomerTransactionId>ProcessShip_Basic</m17:CustomerTransactionId>';
                                soapXMLi += '</m17:TransactionDetail>';
                                
                                soapXMLi += '<m17:Version>';
                                    soapXMLi += '<m17:ServiceId>ship</m17:ServiceId>';
                                    soapXMLi += '<m17:Major>23</m17:Major>';
                                    soapXMLi += '<m17:Intermediate>0</m17:Intermediate>';
                                    soapXMLi += '<m17:Minor>0</m17:Minor>';
                                soapXMLi += '</m17:Version>';
                                
                                soapXMLi += '<m17:RequestedShipment>';
                                    
                                    soapXMLi += '<m17:ShipTimestamp>' + ShipDateStamp + '</m17:ShipTimestamp>';
                                    soapXMLi += '<m17:DropoffType>REGULAR_PICKUP</m17:DropoffType>';
                                    soapXMLi += '<m17:ServiceType>' + Service + '</m17:ServiceType>';
                                    soapXMLi += '<m17:PackagingType>YOUR_PACKAGING</m17:PackagingType>';
                                    
                                    soapXMLi += '<m17:TotalWeight>';
                                        if(weightUnit == 'KGS') soapXMLi += '<m17:Units>KG</m17:Units>';
                                        else soapXMLi += '<m17:Units>LB</m17:Units>';                         
                                        soapXMLi += '<m17:Value>'+ toalWeightValue +'</m17:Value>';
                                    soapXMLi += '</m17:TotalWeight>';
                                    
                                    if(upsCredentials != null && upsCredentials.size() > 0) {
                                        soapXMLi += '<m17:Shipper>';
                                            soapXMLi += '<m17:Contact>';
                                                soapXMLi += '<m17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</m17:PersonName>';
                                                soapXMLi += '<m17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</m17:CompanyName>';
                                                soapXMLi += '<m17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</m17:PhoneNumber>';
                                            soapXMLi += '</m17:Contact>';
                                            soapXMLi += '<m17:Address>';
                                                soapXMLi += '<m17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</m17:StreetLines>';
                                                soapXMLi += '<m17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</m17:City>';
                                                if(shipperProvinceCode != null) soapXMLi += '<m17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</m17:StateOrProvinceCode>';
                                                soapXMLi += '<m17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</m17:PostalCode>';
                                                if(shipperCountryCode != null)  soapXMLi += '<m17:CountryCode>'+ shipperCountryCode.escapeXml() +'</m17:CountryCode>';
                                            soapXMLi += '</m17:Address>';
                                        soapXMLi += '</m17:Shipper>';
                                    }
                                    
                                    if(toAddress != null) {
                                        soapXMLi += '<m17:Recipient>';
                                            soapXMLi += '<m17:Contact>';
                                                soapXMLi += '<m17:PersonName>'+ toAddress.Contact__r.Name.escapeXml() +'</m17:PersonName>';
                                                if(toAddress.Contact__r.Company__c != null) soapXMLi += '<m17:CompanyName>'+ toAddress.Contact__r.Company__c.escapeXml() +'</m17:CompanyName>';
                                                if(toAddress.Contact__r.Phone != null) soapXMLi += '<m17:PhoneNumber>'+ toAddress.Contact__r.Phone.escapeXml() +'</m17:PhoneNumber>';
                                                if(toAddress.Contact__r.Email != null) soapXMLi += '<m17:EMailAddress>'+ toAddress.Contact__r.Email.escapeXml() +'</m17:EMailAddress>';
                                            soapXMLi += '</m17:Contact>';
                                            soapXMLi += '<m17:Address>';
                                                soapXMLi += '<m17:StreetLines>' + DestinationStreet.escapeXml() + '</m17:StreetLines>';
                                                soapXMLi += '<m17:City>' + toAddress.City__c.escapeXml() + '</m17:City>';
                                                if(DestinationProvinceCode != null) soapXMLi += '<m17:StateOrProvinceCode>' + DestinationProvinceCode.escapeXml() + '</m17:StateOrProvinceCode>';
                                                soapXMLi += '<m17:PostalCode>' + toAddress.Postal_Code__c.escapeXml() + '</m17:PostalCode>';
                                                if(DestinationCountryCode != null) soapXMLi += '<m17:CountryCode>' + DestinationCountryCode.escapeXml() + '</m17:CountryCode>';
                                            soapXMLi += '</m17:Address>';
                                        soapXMLi += '</m17:Recipient>';
                                    }
                                    
                                    soapXMLi += '<m17:ShippingChargesPayment>';
                                        soapXMLi += '<m17:PaymentType>SENDER</m17:PaymentType>';
                                        soapXMLi += '<m17:Payor>';
                                            soapXMLi += '<m17:ResponsibleParty>';
                                                soapXMLi += '<m17:AccountNumber>' + accountNumber.escapeXml() + '</m17:AccountNumber>';
                                                soapXMLi += '<m17:Contact>';
                                                    soapXMLi += '<m17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</m17:PersonName>';
                                                    soapXMLi += '<m17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</m17:CompanyName>';
                                                    soapXMLi += '<m17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</m17:PhoneNumber>';
                                                soapXMLi += '</m17:Contact>';
                                                soapXMLi += '<m17:Address>';
                                                    soapXMLi += '<m17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</m17:StreetLines>';
                                                    soapXMLi += '<m17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</m17:City>';
                                                    if(shipperProvinceCode != null) soapXMLi += '<m17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</m17:StateOrProvinceCode>';
                                                    soapXMLi += '<m17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</m17:PostalCode>';
                                                    if(shipperCountryCode != null) soapXMLi += '<m17:CountryCode>'+ shipperCountryCode.escapeXml() +'</m17:CountryCode>';
                                                soapXMLi += '</m17:Address>';
                                            soapXMLi += '</m17:ResponsibleParty>';
                                        soapXMLi += '</m17:Payor>';
                                    soapXMLi += '</m17:ShippingChargesPayment>';
                                    
 //start mulit commment                                    
* Working
                                    soapXMLi += '<m17:ExpressFreightDetail>';
                                        soapXMLi += '<m17:PackingListEnclosed>1</m17:PackingListEnclosed>';
                                        soapXMLi += '<m17:ShippersLoadAndCount>101</m17:ShippersLoadAndCount>';
                                        soapXMLi += '<m17:BookingConfirmationNumber>123456789</m17:BookingConfirmationNumber>';
                                    soapXMLi += '</m17:ExpressFreightDetail>'; 
                                     //end mulit commment
                                    
                                    soapXMLi += '<m17:CustomsClearanceDetail>';
                                        soapXMLi += '<m17:DutiesPayment>';
                                            soapXMLi += '<m17:PaymentType>SENDER</m17:PaymentType>';
                                             //start mulit commment
                                            soapXMLi += '<m17:Payor>';
                                                soapXMLi += '<m17:AccountNumber>' + accountNumber.escapeXml() + '</m17:AccountNumber>'; 
                                                if(shipperCountryCode != null) soapXMLi += '<m17:CountryCode>' + shipperCountryCode.escapeXml() + '</m17:CountryCode>';           
                                            soapXMLi += '</m17:Payor>';
                                             //end mulit commment
                                            soapXMLi += '<m17:Payor>';
                                                soapXMLi += '<m17:ResponsibleParty>';
                                                    soapXMLi += '<m17:AccountNumber>' + accountNumber.escapeXml() + '</m17:AccountNumber>';
                                                    soapXMLi += '<m17:Contact>';
                                                        soapXMLi += '<m17:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</m17:PersonName>';
                                                        soapXMLi += '<m17:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</m17:CompanyName>';
                                                        soapXMLi += '<m17:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</m17:PhoneNumber>';
                                                    soapXMLi += '</m17:Contact>';
                                                    soapXMLi += '<m17:Address>';
                                                        soapXMLi += '<m17:StreetLines>' + upsCredentials[0].Shipper_Street__c.escapeXml() + '</m17:StreetLines>';
                                                        soapXMLi += '<m17:City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</m17:City>';
                                                        if(shipperProvinceCode != null) soapXMLi += '<m17:StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</m17:StateOrProvinceCode>';
                                                        soapXMLi += '<m17:PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</m17:PostalCode>';
                                                        if(shipperCountryCode != null) soapXMLi += '<m17:CountryCode>'+ shipperCountryCode.escapeXml() +'</m17:CountryCode>';
                                                    soapXMLi += '</m17:Address>';
                                                soapXMLi += '</m17:ResponsibleParty>';
                                            soapXMLi += '</m17:Payor>';
                                        soapXMLi += '</m17:DutiesPayment>';       
                                    soapXMLi += '</m17:CustomsClearanceDetail>'; 
                                    
                                    soapXMLi += '<m17:LabelSpecification>';
                                        soapXMLi += '<m17:LabelFormatType>COMMON2D</m17:LabelFormatType>';
                                        soapXMLi += '<m17:ImageType>PNG</m17:ImageType>';
                                        soapXMLi += '<m17:LabelStockType>PAPER_7X4.75</m17:LabelStockType>';
                                    soapXMLi += '</m17:LabelSpecification>';
                                    
                                    soapXMLi += '<m17:RateRequestTypes>LIST</m17:RateRequestTypes>'; // PREFERRED, ACCOUNT
                                    soapXMLi += '<m17:MasterTrackingId>';
                                        soapXMLi += '<m17:TrackingIdType>'+ TrackingIdType +'</m17:TrackingIdType>';
                                        soapXMLi += '<m17:FormId>'+ formId +'</m17:FormId>';
                                        soapXMLi += '<m17:TrackingNumber>'+ MasterTrackingId +'</m17:TrackingNumber>';
                                    soapXMLi += '</m17:MasterTrackingId>';
                                    if(packList != null && packList.size() > 0) soapXMLi += '<m17:PackageCount>'+ packList.size() +'</m17:PackageCount>';
                                    
                                    soapXMLi += '<m17:RequestedPackageLineItems>';
                                        soapXMLi += '<m17:SequenceNumber>'+ Integer.valueof(i+1) +'</m17:SequenceNumber>';
                                        soapXMLi += '<m17:Weight>';
                                            if(packList[i].Weight_Unit__c == 'KGS') soapXMli += '<m17:Units>KG</m17:Units>';
                                            else soapXMli += '<m17:Units>LB</q0:Units>';
                                            soapXMLi += '<m17:Value>'+ packList[i].Weight__c +'</m17:Value>';
                                        soapXMLi += '</m17:Weight>';
                                        
                                        if(packList[0].Package_Type__c != 'Pak' && packList[0].Package_Type__c != 'Box' && packList[0].Package_Type__c != '25KG Box' && packList[0].Package_Type__c != '10KG Box'){  
                                            soapXMLi += '<m17:Dimensions>';
                                                soapXMLi += '<m17:Length>'+ Integer.valueOf(packList[i].Length__c) +'</m17:Length>';
                                                soapXMLi += '<m17:Width>'+ Integer.valueOf(packList[i].Width__c) +'</m17:Width>';
                                                soapXMLi += '<m17:Height>'+ Integer.valueOf(packList[i].Height__c) +'</m17:Height>';
                                                if(packList[i].Weight_Unit__c == 'KGS') soapXMLi += '<m17:Units>CM</m17:Units>';
                                                else soapXMLi += '<m17:Units>IN</m17:Units>';
                                            soapXMLi += '</m17:Dimensions>';
                                        }
                                        
                                    soapXMLi += '</m17:RequestedPackageLineItems>';
                                    
                                soapXMLi += '</m17:RequestedShipment>';
                            soapXMLi += '</m17:ProcessShipmentRequest>';
                        soapXMLi += '</soapenv:Body>';
                    soapXMLi += '</soapenv:Envelope>';
                    
                    
                    HttpRequest reqi = new HttpRequest();
                    Http hi = new Http();
                    
                    reqi.setBody(soapXMLi);
                    reqi.setMethod('POST');
                    reqi.setEndpoint(endpoint);
                    reqi.setHeader('Content-length', '2000');
                    reqi.setHeader('Accept', 'image/gif');
                    reqi.setHeader('Content-Type', 'text/xml');
                    reqi.setHeader('SOAPAction', '');
                    
                    HttpResponse resi = hi.send(reqi);
                    request_2 = soapXMLi;
                    response_2 = resi.getBody();              
                    responseList.add(resi);
                }
                
                if(responseList.size() > 0) {
                    for(HttpResponse resp: responseList) {
                        if(resp.getStatus() == 'OK') { XmlStreamReader reader1 = resp.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                            if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader reader = resp.getXmlStreamReader();
                                while(reader.hasNext()) {
                                     // parsing for total net charges for shipment
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ShipmentRateDetails') {
                                        while(reader.hasNext()) {
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNetCharge') { reader.next();
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); String curr = reader.getText();
                                                    reader.next(); reader.next();
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next();
                                                        amount = reader.getText(); break; } }
                                            } reader.next();  }                                    
                                    }
                                     // parsing tracking number & label for subsequent packages
                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CompletedPackageDetails') {
                                        while(reader.hasNext()) {
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TrackingNumber') { reader.next(); trackingNoList.add(reader.getText()); }
                                             // graphic image
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Image') { String shipmentImages = '';
                                                while(reader.hasNext()) {
                                                    if(reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                                                    else if(reader.getEventType() == XmlTag.CHARACTERS) { shipmentImages += reader.getText(); } reader.next();
                                                } shipmentImageLists.add(shipmentImages); }
                                            if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'CompletedPackageDetails') break; else reader.next(); 
                                        }
                                        
                                    } reader.next();
                                }                                
                            } else Result = 'Unable to retrieve shipment details for subsequent packages.'; break; 
                        } else Result = 'Result not available'; break;
                    }                       
                }
            }       
                        
            if(amount == '' && trackingNoList.size() > 0 ) amount = string.valueOf(0.00); 
            
            Id RTID; RTID = Schema.SObjectType.ERP7__Shipment__c.getRecordTypeInfosByDeveloperName().get('Fedex_Shipping').getRecordTypeId();              
            if(amount != Null && amount != '') {
                if(Schema.sObjectType.Shipment__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Active__c.isUpdateable()) { Shipment.Active__c = true; }                        
                if(Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isUpdateable()) { Shipment.Billing_Address__c = toAddress.Id; }                        
                if(Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Shipment.Customer__c == Null) Shipment.Customer__c = toAddress.Customer__c; 
                if(Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isUpdateable()) { Shipment.Customer_Contact__c = toAddress.Contact__c; }
                if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipment.Status__c = 'Shipped'; }                                                                       
                if(Schema.sObjectType.Shipment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment__c.fields.RecordTypeId.isUpdateable() && RTID != null) { Shipment.RecordTypeId = RTID; }
                if(Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isUpdateable()) { Shipment.Shipping_Address__c = toAddress.Id; }
                if(recordIdMap.get('LO') != null) {
                    //if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name =  'LO-Shipment' ;
                    if(Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable()) Shipment.Logistic__c = recordIdMap.get('LO'); 
                    if(packList != null && packList.size() > 0){ 
                        if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = packList[0].Logistic__r.Sales_Order__c;                             
                    }
                }
                if(recordIdMap.get('SO') != null) {
                    if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name =  'SO-Shipment' ;
                    if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = recordIdMap.get('SO'); }
                if(recordIdMap.get('WO') != null) {
                    if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'WO-Shipment' ;
                    if(Schema.sObjectType.Shipment__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isUpdateable()) Shipment.Work_Order__c = recordIdMap.get('WO'); }
                if(recordIdMap.get('PO') != null) {
                    if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'PO-Shipment' ;
                    if(Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isUpdateable()) Shipment.Purchase_Orders__c = recordIdMap.get('PO'); }
                if(recordIdMap.get('TO') != null) {
                    if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'TO-Shipment' ;
                    if(Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isUpdateable()) Shipment.Transfer_Order__c = recordIdMap.get('TO'); }
                if(recordIdMap.get('SR') != null) { 
                    if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'SR-Shipment' ;
                    if(Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable()) Shipment.Return_Merchandise_Authorisation__c = recordIdMap.get('SR'); }
                if(Schema.sObjectType.Shipment__c.fields.Fedex_Service__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Fedex_Service__c.isUpdateable()) { Shipment.Fedex_Service__c = service; }
                if(Schema.sObjectType.Shipment__c.fields.Tracking_Unique_Id__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Unique_Id__c.isUpdateable()) { if(TrackingIdType != null) Shipment.Tracking_Unique_Id__c = TrackingIdType; }
                if(Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isUpdateable()) { Shipment.Shipping_Amount__c = (amount != '') ? Decimal.valueOf(amount) : 0.00; }
                if(Schema.sObjectType.Shipment__C.fields.Number_Of_Pieces_In_Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isUpdateable()) Shipment.Number_Of_Pieces_In_Shipment__c = String.valueof(Packages.size());
                if(Schema.sObjectType.Shipment__C.fields.Carrier_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Carrier_Code__c.isUpdateable()) { if(CarrierCode != null) Shipment.Carrier_Code__c = CarrierCode;}
                if(Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isUpdateable()) { 
                    for(String s: trackingNoList) { if(Shipment.Tracking_Number__c == null) Shipment.Tracking_Number__c = s;
                                                    else Shipment.Tracking_Number__c += ',' + s; } }
                if(Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert Shipment;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                
                // Adding below code to assign tracking number in sales order.
                ERP7__Sales_Order__c SalesOrder = new ERP7__Sales_Order__c();
                SalesOrder = Database.query('select Id, Name, ERP7__Tracking_Number__c from ERP7__Sales_Order__c where (Id =\'' + packList[0].Logistic__r.Sales_Order__r.Id + '\') Limit 1');
                
                if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isUpdateable()) { 
                    for(String s: trackingNoList) { if(SalesOrder.ERP7__Tracking_Number__c == null) SalesOrder.ERP7__Tracking_Number__c = s;
                                                    else SalesOrder.ERP7__Tracking_Number__c += ', ' + s;
                    }
                } if(Schema.sObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; update SalesOrder; }
                // Additional code ends.
                
                // updating tracking number in corresponding packages.
                for(Integer i=0; i<packList.size(); i++) { packList[i].Shipment__c = Shipment.Id;
                                                           packList[i].Status__c = Shipment.Status__c;  
                                                           if(trackingNoList.size() > i) packList[i].Tracking_Number__c = trackingNoList[i]; 
                 } if(packList.size() > 0) if(Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert packList; }    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                 // creating FedEx label attachments and associating to new shipment created.
                List<attachment> attList = new List<attachment>(); 
                if(shipmentImageLists.size() > 0) {
                    for(Integer i=1; i<=shipmentImageLists.size(); i++) {
                        attachment att = new attachment(Name = 'Fedex_Label_'+i, parentId = Shipment.Id, ContentType = 'text/plain');
                        if(Schema.sObjectType.attachment.fields.body.isCreateable() && Schema.sObjectType.attachment.fields.body.isUpdateable()) { att.body = EncodingUtil.base64Decode(shipmentImageLists[i-1]); string decode = att.body.toString(); system.debug(' att.body : '+decode );} 
                        attList.add(att); }
                } if(attList.size() > 0) if(Schema.sObjectType.Attachment.isCreateable() && Schema.sObjectType.Attachment.isUpdateable()) upsert attList;
                Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Id =\'' + Shipment.Id + '\') Limit 1');                            
                attList = new List<attachment>(); shipmentImageLists = new List<String>(); Result = 'Package Shipped Successfully'; time_in_cost_tab = false;
                for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9){ showAndHideMap.put(i, false);} else {showAndHideMap.put(i, true);} }
                
            } else { Result = 'Unable to retrieve shipment amount please try later.'; }   
         
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    
    //  cancel shipping API request.
    
    public PageReference Cancel_Request() {
        try {
             time_in_cost_tab = false;
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Not Available'; } 
            else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Request To Cancel Shipment Cannot Be Processed'; } 
            else if(Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment Date Unavailable'; } 
            else if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Active Thus, Request To Cancel The Shipment Cannot Be Processed'; } 
            else { errorMsg1 = ''; DateTime dt = Shipment.Shipment_Date__c;
                   String shipmentDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
                   Cancel_Request_Reply(JSON.serialize(Shipment), JSON.serialize(packages), shipmentDate); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public PageReference Cancel_Request_Reply(String shipments1, String packList1, String TimeStamp) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            String[] s;  if(shipments.Tracking_Number__c != null) s = shipments.Tracking_Number__c.split(',');
            if(s != null && s.size() > 0) shipments.Tracking_Number__c = s[0];
            String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:q0="http://fedex.com/ws/ship/v23" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
                soapXML += '<soapenv:Body>';
                    soapXML += '<q0:DeleteShipmentRequest>';
                        soapXML += '<q0:WebAuthenticationDetail>';
                            if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                soapXML += '<q0:ParentCredential>';
                                    soapXML += '<q0:Key>' + parentkey.escapeXml() + '</q0:Key>';
                                    soapXML += '<q0:Password>' + parentPassword.escapeXml() + '</q0:Password>';
                                soapXML += '</q0:ParentCredential>';
                            }
                            soapXML += '<q0:UserCredential>';
                                soapXML += '<q0:Key>' + key.escapeXml() + '</q0:Key>';
                                soapXML += '<q0:Password>' + password.escapeXml() + '</q0:Password>';
                            soapXML += '</q0:UserCredential>';
                        soapXML += '</q0:WebAuthenticationDetail>';
            
                        soapXML += '<q0:ClientDetail>';
                            soapXML += '<q0:AccountNumber>' + accountNumber.escapeXml() + '</q0:AccountNumber>';
                            soapXML += '<q0:MeterNumber>' + meterNumber.escapeXml() + '</q0:MeterNumber>';
                        soapXML += '</q0:ClientDetail>';
                        
                        soapXML += '<q0:TransactionDetail>';
                            soapXML += '<q0:CustomerTransactionId>Delete Shipment</q0:CustomerTransactionId>';
                        soapXML += '</q0:TransactionDetail>';
            
                        soapXML += '<q0:Version>';
                            soapXML += '<q0:ServiceId>ship</q0:ServiceId>';
                            soapXML += '<q0:Major>23</q0:Major>';
                            soapXML += '<q0:Intermediate>0</q0:Intermediate>';
                            soapXML += '<q0:Minor>0</q0:Minor>';
                        soapXML += '</q0:Version>';
            
                        soapXML += '<q0:ShipTimestamp>' + TimeStamp + '</q0:ShipTimestamp>';
            
                        soapXML += '<q0:TrackingId>';
                            if(shipments.Tracking_Unique_Id__c != null) soapXML += '<q0:TrackingIdType>' + shipments.Tracking_Unique_Id__c.escapeXml() + '</q0:TrackingIdType>';
                            if(shipments.Tracking_Number__c != null) soapXML += '<q0:TrackingNumber>'+ shipments.Tracking_Number__c.escapeXml() +'</q0:TrackingNumber>';
                        soapXML += '</q0:TrackingId>';
            
                        soapXML += '<q0:DeletionControl>DELETE_ALL_PACKAGES</q0:DeletionControl>';
            
                    soapXML += '</q0:DeleteShipmentRequest>';
                soapXML += '</soapenv:Body>';
            soapXML += '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-length', '200');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '');
            //req.setHeader('Host', 'wsbeta.fedex.com');
            
            HttpResponse res = h.send(req);            
            request_1 = soapXmL;
            response_1 = res.getBody(); 
            resStatus = res.getStatus();
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader();  String msg = readXMLResponse(reader1, 'Severity');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                    if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipments.Status__c = 'Cancelled'; }
                    if(Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert Shipments; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    if(packList != null && packList.size() > 0 && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()) { for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert packList; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    Shipment = new Shipment__c();  Result = 'Shipment deleted successfully';
                    for(Integer i=1; i<=7; i++) { if(i==1) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }                
                } else { XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'Message');
                         if(mesage != Null && mesage != '') Result = 'Request to cancel shipment cannot be processed : ' + mesage;
                         else Result = 'Request to cancel shipment cannot be processed';
                }
            } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    
    //  pickup availability API request.
    
    public PageReference PickupAvailability() {
        try { 
            time_in_cost_tab = false;
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Already Active For This Package'; } 
            else if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 
            else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Shipment Status Must Be shipped To Process, Pickup Rate Request'; } 
            else if(Shipment.Package_Ready_Time__c == null) { errorMsg1 = 'Package Ready Time Unavailable'; } 
            else if(Shipment.Customer_Close_Time__c == null) { errorMsg1 = 'Customer Close Time Unavailable'; } 
            else if(Shipment.Package_Ready_Time__c < System.Now()) { errorMsg1 = 'Package Ready Time Invalid'; } 
            else if(Shipment.Customer_Close_Time__c < System.Now()) { errorMsg1 = 'Customer Close Time Invalid'; } 
            else if(Shipment.Customer_Close_Time__c.year() != Shipment.Package_Ready_Time__c.year() || Shipment.Customer_Close_Time__c.month() != Shipment.Package_Ready_Time__c
                .month() || Shipment.Customer_Close_Time__c.day() != Shipment.Package_Ready_Time__c.day()) {
                errorMsg1 = 'Package Ready Time Date And Customer Close Time Date Must Be Same'; }
            else { errorMsg1 = '';  DateTime PRT = Shipment.Package_Ready_Time__c; DateTime CCT = Shipment.Customer_Close_Time__c;  String dispatchDate = PRT.format('yyyy-MM-dd');
                   String PackageReadyTime = PRT.format('HH:mm:ss');  String CustomerCloseTime = CCT.format('HH:mm:ss');
                   //PickupAvailability_Reply(fromAddress, packages, shipment, dispatchDate, PackageReadyTime, CustomerCloseTime);
                 PickupAvailability_Reply(JSON.serialize(fromAddress), JSON.serialize(packages), JSON.serialize(shipment), dispatchDate, PackageReadyTime, CustomerCloseTime);}
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;  
    }
    //public PageReference PickupAvailability_Reply(Address__c fromAddress, List<Package__c> packList, Shipment__c shipments, String dispatchDate, String PackageReadyTime, String CustomerCloseTime) {
    public PageReference PickupAvailability_Reply(String fromAddress1, String packList1, String shipments1, String dispatchDate, String PackageReadyTime, String CustomerCloseTime) {
        try {
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v11="http://fedex.com/ws/pickup/v17">';
                soapXML += '<soapenv:Body>';  
                    soapXML += '<v11:PickupAvailabilityRequest>';
                        soapXML += '<v11:WebAuthenticationDetail>'; 
                            if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                soapXML += '<v11:ParentCredential>';
                                    soapXML += '<v11:Key>' + parentkey.escapeXml() + '</v11:Key>';
                                    soapXML += '<v11:Password>' + parentPassword.escapeXml() + '</v11:Password>';
                                soapXML += '</v11:ParentCredential>';
                            }
                            soapXML += '<v11:UserCredential>';
                                soapXML += '<v11:Key>' + key.escapeXml() + '</v11:Key>';
                                soapXML += '<v11:Password>' + password.escapeXml() + '</v11:Password>';
                            soapXML += '</v11:UserCredential>';
                        soapXML += '</v11:WebAuthenticationDetail>';
                        
                        soapXML += '<v11:ClientDetail>';
                            soapXML += '<v11:AccountNumber>' + accountNumber.escapeXml() + '</v11:AccountNumber>';
                            soapXML += '<v11:MeterNumber>' + meterNumber.escapeXml() + '</v11:MeterNumber>';
                            soapXML += '<v11:Localization>';
                                soapXML += '<v11:LanguageCode>EN</v11:LanguageCode>';
                            soapXML += '</v11:Localization>';
                        soapXML += '</v11:ClientDetail>';
                        
                        soapXML += '<v11:TransactionDetail>';
                            soapXML += '<v11:CustomerTransactionId>PICKUP AVAILABILITY</v11:CustomerTransactionId>';
                            soapXML += '<v11:Localization>';
                                soapXML += '<v11:LanguageCode>EN</v11:LanguageCode>';
                            soapXML += '</v11:Localization>';
                        soapXML += '</v11:TransactionDetail>';
                        
                        soapXML += '<v11:Version>';
                            soapXML += '<v11:ServiceId>disp</v11:ServiceId>';
                            soapXML += '<v11:Major>17</v11:Major>';
                            soapXML += '<v11:Intermediate>0</v11:Intermediate>';
                            soapXML += '<v11:Minor>0</v11:Minor>';
                        soapXML += '</v11:Version>';
                        
                        if(fromAddress != null) {
                            soapXML += '<v11:PickupAddress>';
                                if(OriginStreet != null) soapXML += '<v11:StreetLines>'+ OriginStreet.escapeXml() +'</v11:StreetLines>';
                                if(fromAddress.City__c != null) soapXML += '<v11:City>'+ fromAddress.City__c.escapeXml() +'</v11:City>';
                                if(originProvinceCode != null) soapXML += '<v11:StateOrProvinceCode>'+ originProvinceCode.escapeXml() +'</v11:StateOrProvinceCode>';
                                if(fromAddress.Postal_Code__c != null) soapXML += '<v11:PostalCode>'+ fromAddress.Postal_Code__c.escapeXml() +'</v11:PostalCode>';
                                if(OriginCountryCode != null) soapXML += '<v11:CountryCode>'+ OriginCountryCode.escapeXml() +'</v11:CountryCode>';
                                if(fromShipmentType) soapXML += '<v11:Residential>'+ fromShipmentType +'</v11:Residential>';
                                else soapXML += '<v11:Residential>'+ fromShipmentType +'</v11:Residential>';                    
                            soapXML += '</v11:PickupAddress>';
                        }
                        soapXML += '<v11:PickupRequestType>SAME_DAY</v11:PickupRequestType>';
                        soapXML += '<v11:DispatchDate>' + dispatchDate + '</v11:DispatchDate>';
                        soapXML += '<v11:NumberOfBusinessDays>1</v11:NumberOfBusinessDays>';
                        soapXML += '<v11:PackageReadyTime>' + PackageReadyTime + '</v11:PackageReadyTime>';
                        soapXML += '<v11:CustomerCloseTime>' + CustomerCloseTime + '</v11:CustomerCloseTime>';
                        soapXML += '<v11:Carriers>FDXE</v11:Carriers>';
                        
                        for(Package__c p : packList) {
                            soapXML += '<v11:ShipmentAttributes>';
                                soapXML += '<v11:ServiceType>' + Shipments.Fedex_Service__c + '</v11:ServiceType>';
                                soapXML += '<v11:PackagingType>YOUR_PACKAGING</v11:PackagingType>';
                                soapXML += '<v11:Dimensions>';
                                    soapXML += '<v11:Length>'+ Integer.valueOf(p.Length__c) +'</v11:Length>';
                                    soapXML += '<v11:Width>'+ Integer.valueOf(p.Width__c) +'</v11:Width>';
                                    soapXML += '<v11:Height>'+ Integer.valueOf(p.Height__c) +'</v11:Height>';
                                    if(p.Weight_Unit__c == 'KGS') soapXML += '<v11:Units>CM</v11:Units>'; else soapXML += '<v11:Units>IN</v11:Units>';                          
                                soapXML += '</v11:Dimensions>';
                                soapXML += '<v11:Weight>';
                                    if(p.Weight_Unit__c == 'KGS') soapXMl += '<v11:Units>KG</v11:Units>'; else soapXMl += '<v11:Units>LB</v11:Units>';                        
                                    soapXML += '<v11:Value>' + p.Weight__c + '</v11:Value>';
                                soapXML += '</v11:Weight>';
                            soapXML += '</v11:ShipmentAttributes>';
                        }
                    soapXML += '</v11:PickupAvailabilityRequest>';
                soapXML += '</soapenv:Body>';
            soapXML += '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-length', '200');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '');
            //req.setHeader('Host', 'wsbeta.fedex.com');

            HttpResponse res = h.send(req);            
            request_1 = soapXmL;
            response_1 = res.getBody();
             
            resStatus = res.getStatus();
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader();  String msg = readXMLResponse(reader1, 'Severity');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader avail = res.getXmlStreamReader();
                                                                            String availmsg = readXMLResponseFirstValue(avail, 'Available');
                                                                            if(availmsg == 'true') Result = 'Shipment Pickup for this package is available';
                                                                            else Result = 'Shipment Pickup for this package is not available';
                } else { XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'Message');
                         if(mesage != Null && mesage != '') Result = 'Request to pickup shipment cannot be processed : ' + mesage;
                         else Result = 'Request to pickup shipment cannot be processed';
                }
            } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    
    //  create pickup API request.
    
    public PageReference CreatePickup() {
        try {
            time_in_cost_tab = false;
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Already Active For This Package'; } 
            else if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 
            else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Shipment Status Must Be Shipped To Process, Create Pickup Request'; } 
            else if(Shipment.Package_Ready_Time__c == null) { errorMsg1 = 'Package Ready Time Unavailable'; } 
            else if(Shipment.Customer_Close_Time__c == null) { errorMsg1 = 'Customer Close Time Unavailable'; } 
            else if(Shipment.Package_Ready_Time__c < System.Now()) { errorMsg1 = 'Package Ready Time Invalid'; } 
            else if(Shipment.Customer_Close_Time__c < System.Now()) { errorMsg1 = 'Customer Close Time Invalid'; } 
            else if(Shipment.Customer_Close_Time__c.year() != Shipment.Package_Ready_Time__c.year() || Shipment.Customer_Close_Time__c.month() != Shipment.Package_Ready_Time__c
                .month() || Shipment.Customer_Close_Time__c.day() != Shipment.Package_Ready_Time__c.day()) {
                errorMsg1 = 'Package Ready Time Date And Customer Close Time Date Must Be Same'; }
            else {  errorMsg1 = '';  DateTime PRT = Shipment.Package_Ready_Time__c;
                    DateTime CCT = Shipment.Customer_Close_Time__c;  String dispatchDate = PRT.format('yyyy-MM-dd');
                    String PackageReadyTime = PRT.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');  String CustomerCloseTime = CCT.format('HH:mm:ss');
                    //CreatePickup_Reply(packages, shipment, dispatchDate, PackageReadyTime, CustomerCloseTime);
                 CreatePickup_Reply(JSON.serialize(packages), JSON.serialize(shipment), dispatchDate, PackageReadyTime, CustomerCloseTime);}
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference CreatePickup_Reply(List<Package__c> packList, Shipment__c shipments, String dispatchDate, String PackageReadyTime, String CustomerCloseTime) {
    public PageReference CreatePickup_Reply(String packList1, String shipments1, String dispatchDate, String PackageReadyTime, String CustomerCloseTime) {
        try {
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v11="http://fedex.com/ws/pickup/v17">';
                soapXML += '<soapenv:Body>';
                    soapXML += '<v11:CreatePickupRequest>';
                        soapXML += '<v11:WebAuthenticationDetail>';
                            if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                soapXML += '<v11:ParentCredential>';
                                    soapXML += '<v11:Key>' + parentkey.escapeXml() + '</v11:Key>';
                                    soapXML += '<v11:Password>' + parentPassword.escapeXml() + '</v11:Password>';
                                soapXML += '</v11:ParentCredential>';
                            }
                            soapXML += '<v11:UserCredential>';
                                soapXML += '<v11:Key>' + key.escapeXml() + '</v11:Key>';
                                soapXML += '<v11:Password>' + password.escapeXml() + '</v11:Password>';
                            soapXML += '</v11:UserCredential>';
                        soapXML += '</v11:WebAuthenticationDetail>';
                        
                        soapXML += '<v11:ClientDetail>';
                            soapXML += '<v11:AccountNumber>' + accountNumber.escapeXml() + '</v11:AccountNumber>';
                            soapXML += '<v11:MeterNumber>' + meterNumber.escapeXml() + '</v11:MeterNumber>';
                            soapXML += '<v11:Localization>';
                                soapXML += '<v11:LanguageCode>EN</v11:LanguageCode>';
                            soapXML += '</v11:Localization>';
                        soapXML += '</v11:ClientDetail>';
                        
                        soapXML += '<v11:TransactionDetail>';
                            soapXML += '<v11:CustomerTransactionId>CreatePickupRequest</v11:CustomerTransactionId>';
                        soapXML += '</v11:TransactionDetail>';
                        
                        soapXML += '<v11:Version>';
                            soapXML += '<v11:ServiceId>disp</v11:ServiceId>';
                            soapXML += '<v11:Major>17</v11:Major>';
                            soapXML += '<v11:Intermediate>0</v11:Intermediate>';
                            soapXML += '<v11:Minor>0</v11:Minor>';
                        soapXML += '</v11:Version>';
                        
                        soapXML += '<v11:AssociatedAccountNumber>';
                            soapXML += '<v11:Type>FEDEX_EXPRESS</v11:Type>';
                            soapXML += '<v11:AccountNumber>' + accountNumber.escapeXml() + '</v11:AccountNumber>';
                        soapXML += '</v11:AssociatedAccountNumber>';
                            
                        soapXML += '<v11:OriginDetail>';
                            soapXML += '<v11:UseAccountAddress>0</v11:UseAccountAddress>';
                            soapXML += '<v11:PickupLocation>';
                                if(upsCredentials != null && upsCredentials.size() > 0) {
                                    soapXML += '<v11:Contact>';
                                        soapXML += '<v11:PersonName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</v11:PersonName>';
                                        soapXML += '<v11:CompanyName>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</v11:CompanyName>';
                                        soapXML += '<v11:PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</v11:PhoneNumber>';
                                    soapXML += '</v11:Contact>';
                                }
                                if(fromAddress != null) {
                                    soapXML += '<v11:Address>';
                                        if(OriginStreet != null) soapXML += '<v11:StreetLines>' + OriginStreet.escapeXml() + '</v11:StreetLines>';
                                        if(fromAddress.City__c != null) soapXML += '<v11:City>' + fromAddress.City__c.escapeXml() + '</v11:City>';
                                        if(originProvinceCode != null) soapXML += '<v11:StateOrProvinceCode>' + originProvinceCode.escapeXml() + '</v11:StateOrProvinceCode>';
                                        if(fromAddress.Postal_Code__c != null) soapXML += '<v11:PostalCode>' + fromAddress.Postal_Code__c.escapeXml() + '</v11:PostalCode>';                    
                                        if(OriginCountryCode != null) soapXML += '<v11:CountryCode>' + OriginCountryCode.escapeXml() + '</v11:CountryCode>';
                                    soapXML += '</v11:Address>';
                                }
                            soapXML += '</v11:PickupLocation>';
                            soapXML += '<v11:PackageLocation>REAR</v11:PackageLocation>';
                            soapXML += '<v11:ReadyTimestamp>'+ PackageReadyTime +'</v11:ReadyTimestamp>';
                            soapXML += '<v11:CompanyCloseTime>'+ CustomerCloseTime +'</v11:CompanyCloseTime>';
                        soapXML += '</v11:OriginDetail>';
                          
                        //soapXML += '<v11:PickupServiceCategory>'+ shipments.Fedex_Service__c +'</v11:PickupServiceCategory>';
                        
                        if(packList != null && packList.size() > 0) soapXML += '<v11:PackageCount>'+ packList.size() +'</v11:PackageCount>';
                        soapXML += '<v11:TotalWeight>';
                            if(WeightUnit == 'KGS') soapXMl += '<v11:Units>KG</v11:Units>'; else soapXMl += '<v11:Units>LB</v11:Units>';                        
                            soapXML += '<v11:Value>' + toalWeightValue + '</v11:Value>';
                        soapXML += '</v11:TotalWeight>';            
                        soapXML += '<v11:CarrierCode>FDXE</v11:CarrierCode>';
                        soapXML += '<v11:Remarks>Courier Pickup Request</v11:Remarks>';
                        //soapXML += '<v11:CommodityDescription>TEST ENVIRONMENT - PLEASE DO NOT PROCESS PICKUP</v11:CommodityDescription>';
                    soapXML += '</v11:CreatePickupRequest>';            
                soapXML += '</soapenv:Body>';
            soapXML += '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-length', '200');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '');
            //req.setHeader('Host', 'wsbeta.fedex.com');

            HttpResponse res = h.send(req);            
            request_1 = soapXmL;
            response_1 = res.getBody(); 
            resStatus = res.getStatus();
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader avail = res.getXmlStreamReader();
                    String PickupConfirmNumber = readXMLResponseFirstValue(avail, 'PickupConfirmationNumber');
                    XmlStreamReader avail1 = res.getXmlStreamReader(); String pickupLocation = readXMLResponseFirstValue(avail1, 'Location');
                    if(PickupConfirmNumber != Null && pickupLocation != Null) {
                        Result = 'Shipment Pickup for this package created successfully';
                        if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Picked Up'; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isUpdateable()) { Shipments.Pickup_Confirmation_Number__c = PickupConfirmNumber; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isUpdateable()) { Shipments.Pickup_Location__c = pickupLocation; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isUpdateable()) { Shipments.Pickup_Requested__c = true; }
                        if(Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=false; upsert Shipments; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                        if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert packList; }
                        for(Integer i=1; i<=7; i++) { if(i==7 || i==2) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
                    } else Result = 'Shipment Pickup for this package is not available';
                } else { XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'Message');
                         if(mesage != Null && mesage != '') Result = 'Request to pickup shipment cannot be processed : ' + mesage;
                         else Result = 'Request to pickup shipment cannot be processed'; }
            } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    
    //  cancel pickup API request.
    
    public PageReference CancelPickup() {
        try {
            time_in_cost_tab = false;
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Delivered') errorMsg1 = 'Shipment delivered : Request cannot be processed';
            else if(Shipment.Pickup_Requested__c == false) errorMsg1 = 'Shipment Pickup unavailable to cancel';
            else if(Shipment.Pickup_Confirmation_Number__c == null || Shipment.Pickup_Confirmation_Number__c == '') errorMsg1 = 'Pickup Confirmation Number is required to cancel shipment pickup';
            else if(Shipment.Pickup_Location__c == null || Shipment.Pickup_Location__c == '') errorMsg1 = 'Pickup Location is required to cancel shipment pickup';
            else if(Shipment.Package_Ready_Time__c == null) errorMsg1 = 'Package Ready Time is required to cancel shipment pickup';
            else {  errorMsg1 = '';  DateTime PRT = Shipment.Package_Ready_Time__c; String dispatchDate = PRT.format('yyyy-MM-dd');  //CancelPickup_Reply(shipment, packages, dispatchDate);
			CancelPickup_Reply(JSON.serialize(shipment), JSON.serialize(packages), dispatchDate); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference CancelPickup_Reply(Shipment__c shipments, List<Package__c> packList, String dispatchDate) {
    public PageReference CancelPickup_Reply(String shipments1, String packList1, String dispatchDate) {
        try {
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:q0="http://fedex.com/ws/pickup/v17">';
                soapXML += '<soapenv:Body>';
                    soapXML += '<q0:CancelPickupRequest>';
                    
                        soapXML += '<q0:WebAuthenticationDetail>';
                            if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                soapXML += '<q0:ParentCredential>';
                                    soapXML += '<q0:Key>' + parentkey.escapeXml() + '</q0:Key>';
                                    soapXML += '<q0:Password>' + parentPassword.escapeXml() + '</q0:Password>';
                                soapXML += '</q0:ParentCredential>';
                            }
                            soapXML += '<q0:UserCredential>';
                                soapXML += '<q0:Key>' + key.escapeXml() + '</q0:Key>';
                                soapXML += '<q0:Password>' + password.escapeXml() + '</q0:Password>';
                            soapXML += '</q0:UserCredential>';
                        soapXML += '</q0:WebAuthenticationDetail>';
                        
                        soapXML += '<q0:ClientDetail>';
                            soapXML += '<q0:AccountNumber>' + accountNumber.escapeXml() + '</q0:AccountNumber>';
                            soapXML += '<q0:MeterNumber>' + meterNumber.escapeXml() + '</q0:MeterNumber>';
                        soapXML += '</q0:ClientDetail>';
                        
                        soapXML += '<q0:Version>';
                            soapXML += '<q0:ServiceId>disp</q0:ServiceId>';
                            soapXML += '<q0:Major>17</q0:Major>';
                            soapXML += '<q0:Intermediate>0</q0:Intermediate>';
                            soapXML += '<q0:Minor>0</q0:Minor>';
                        soapXML += '</q0:Version>';
                        
                        soapXML += '<q0:CarrierCode>FDXE</q0:CarrierCode>';
                        soapXML += '<q0:PickupConfirmationNumber>'+ Shipments.Pickup_Confirmation_Number__c +'</q0:PickupConfirmationNumber>';
                        soapXML += '<q0:ScheduledDate>'+ dispatchDate +'</q0:ScheduledDate>';
                        soapXML += '<q0:Location>'+ Shipments.Pickup_Location__c +'</q0:Location>';
                        soapXML += '<q0:Remarks>REMARKS</q0:Remarks>';
                        soapXML += '<q0:Reason>NO LONGER NEEDED</q0:Reason>';
                    
                    soapXML += '</q0:CancelPickupRequest>';
                soapXML += '</soapenv:Body>';
            soapXML += '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-length', '200');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '');
            //req.setHeader('Host', 'wsbeta.fedex.com');

            HttpResponse res = h.send(req);            
            request_1 = soapXmL;
            response_1 = res.getBody(); 
            resStatus = res.getStatus();
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader avail = res.getXmlStreamReader(); String availmsg = readXMLResponseFirstValue(avail, 'Message');
                    if(availmsg == 'SUCCESS') {
                        Result = 'Shipment Pickup for this package cancelled successfully';
                        if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Shipped'; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isUpdateable()) { Shipments.Pickup_Confirmation_Number__c = null; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Location__c.isUpdateable()) { Shipments.Pickup_Location__c = null; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isUpdateable()) { Shipments.Pickup_Requested__c = false; }
                        if(Schema.sObjectType.Shipment__c.fields.Package_Ready_Time__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Package_Ready_Time__c.isUpdateable()) { Shipments.Package_Ready_Time__c = null; }
                        if(Schema.sObjectType.Shipment__c.fields.Customer_Close_Time__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Close_Time__c.isUpdateable()) { Shipments.Customer_Close_Time__c = null; }
                        if(Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert Shipments; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                        if(packList != null && packList.size() > 0 && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()) { for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert packList; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                        for(Integer i=1; i<=7; i++) { if(i==4 || i==5) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); }
                    } else Result = 'Unable to process Pickup cancel request for this package';
                } else { XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'Message');
                         if(mesage != Null && mesage != '') Result = 'Unable to process Pickup cancel request for this package : ' + mesage;
                         else  Result = 'Unable to process Pickup cancel request for this package';
                }
            } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    
    //  shipment tracking API request.
    
    public PageReference Track_Request() {
        try {
            time_in_cost_tab = false;
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; }             
            if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Unavailable'; }            
            else { errorMsg1 = '';  Track_Request_Reply(JSON.serialize(shipment), JSON.serialize(packages)); }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public PageReference Track_Request_Reply(String shipments1, String packList1) {
        try {
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="http://fedex.com/ws/track/v16">';
                soapXML += '<soapenv:Body>';
                    soapXML += '<ns:TrackRequest>';
                    
                        soapXML += '<ns:WebAuthenticationDetail>';
                            if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                soapXML += '<ns:ParentCredential>';
                                    soapXML += '<ns:Key>' + parentkey.escapeXml() + '</ns:Key>';
                                    soapXML += '<ns:Password>' + parentPassword.escapeXml() + '</ns:Password>';
                                soapXML += '</ns:ParentCredential>';
                            }
                            soapXML += '<ns:UserCredential>';
                                soapXML += '<ns:Key>'+ key.escapeXml() +'</ns:Key>';
                                soapXML += '<ns:Password>'+ password.escapeXml() +'</ns:Password>';
                            soapXML += '</ns:UserCredential>';
                        soapXML += '</ns:WebAuthenticationDetail>';
                        
                        soapXML += '<ns:ClientDetail>';
                            soapXML += '<ns:AccountNumber>'+ accountNumber.escapeXml() +'</ns:AccountNumber>';
                            soapXML += '<ns:MeterNumber>'+ meterNumber.escapeXml() +'</ns:MeterNumber>';
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
                            //soapXML += '<ns:CarrierCode>'+ Shipment.Carrier_Code__c +'</ns:CarrierCode>';
                            soapXML += '<ns:PackageIdentifier>';
                                soapXML += '<ns:Type>TRACKING_NUMBER_OR_DOORTAG</ns:Type>'; 
                                //soapXML += '<ns:Value>122816215025810</ns:Value>'; // 231300687629630, 797806677146, 568838414941, 999999999999, 797843158299, 123456789012, 403934084723025
                                soapXML += '<ns:Value>'+ Shipment.Tracking_Number__c +'</ns:Value>'; 
                            soapXML += '</ns:PackageIdentifier>';
                        soapXML += '</ns:SelectionDetails>';
                        // commenting below two lines as not in guide for v10
                        //soapXML += '<ns:ShipmentAccountNumber>' + accountNumber.escapeXml() + '</ns:ShipmentAccountNumber>';
                        //soapXML += '<ns:IncludeDetailedScans>true</ns:IncludeDetailedScans>';
                        soapXML += '<ns:ProcessingOptions>INCLUDE_DETAILED_SCANS</ns:ProcessingOptions>';
                    soapXML += '</ns:TrackRequest>';
                soapXML += '</soapenv:Body>'; 
            soapXML += '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-length', '200');
            req.setHeader('Content-Type', 'text/xml');
            req.setHeader('SOAPAction', '');

            HttpResponse res = h.send(req);            
            request_1 = soapXmL;
            response_1 = res.getBody(); 
            resStatus = res.getStatus();
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponseOnce(reader1, 'Severity');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { readXMLResponseTrackHistory(res.getXmlStreamReader(),'Events'); 
                    List<Shipment_Flow__c> existingSFList;  Map<String, Shipment_Flow__c> sfMap = new Map<String, Shipment_Flow__c>();
                    if(Shipment != null) { 
                        for(Shipment_Flow__c sf: [select Id, Name, Shipment__c, Shipment_DateTime__c, Description__c, Shipment_Flow_Start_Date__c, 
                                                  Shipment_Flow_End_Date__c from Shipment_Flow__c where Shipment__c =: Shipment.Id Order by Name Asc]) { 
                            sfMap.put(sf.Shipment_DateTime__c, sf); }
                    }
                    for(Integer i=0; i<trackWrapperList.size(); i++) {
                        Shipment_Flow__c sf = new Shipment_Flow__c(Shipment_DateTime__c = String.valueof(trackWrapperList[i].dtValue));
                        if(!sfMap.keyset().contains(String.valueof(trackWrapperList[i].dtValue))) {
                            //sf.Name = 'Shipment Flow ' + i+1;
                            sf.Name = 'Shipment Flow ' +Shipments.Tracking_Number__c +' ' + i;
                            if(Shipments != null) sf.Shipment__c = Shipments.Id;
                            sf.Active__c = true;                            
                            if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_Start_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                            if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_End_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                            if(trackWrapperList[i].activityDesp != null) sf.Description__c = trackWrapperList[i].activityDesp;
                            if(trackWrapperList[i].activityDesp != null && trackWrapperList[i].activityDesp == 'Delivered') Shipments.Status__c = 'Delivered';
                            
                            sfMap.put(String.valueof(trackWrapperList[i].dtValue), sf);
                        } 
                    } if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Signature_Services__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isUpdateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert Shipments; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                      if(packList != null && packList.size() > 0) { for(Package__c pac : packList) { pac.Status__c = Shipments.Status__c; } PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert packList; }
                      if(sfMap.size() > 0) upsert sfMap.values(); if(Shipments.Status__c == 'Delivered') showAndHideMap.put(8, true); Result = 'Track Shipment Activities';                                                                                   
                } else { XmlStreamReader message = res.getXmlStreamReader();
                         String mesage = readXMLResponse(message, 'Message');
                         if(mesage != Null && mesage != '') Result = 'Request to track shipment cannot be processed : ' + mesage;
                         else Result = 'Request to track shipment cannot be processed'; }
            } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public void readXMLResponseTrackHistory(XmlStreamReader reader, String sxmltag) {
         try {   
              trackwrapper tw; trackwrapperlist = new List<trackwrapper>();
              while(reader.hasNext()) {
                   if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { tw = new trackwrapper();
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
                           if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next(); 
                       } trackwrapperlist.add(tw);
                   } reader.next();
              }
         } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
    }
     
    
    //  signature proof API request.
    
    public PageReference Signature_Proof() {
        try {
            time_in_cost_tab = false;
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == '' || Shipment.Status__c == Null) errorMsg1 = 'The shipment is unavailable';
            else if(Shipment.Status__c != 'Delivered') errorMsg1 = 'Request to get signature proof of delivery for this shipment cannot be processed';
            else {  errorMsg1 = ''; //DateTime dt = Shipment.Shipment_Date__c; String shipmentDate = dt.format('yyyy-MM-dd'); 
                   
                   Signature_Proof_Reply(JSON.serialize(Shipment), JSON.serialize(shippingAddress)); }            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public PageReference Signature_Proof_Reply(String Shipment1, String toAddress1) {
        
        try {
            Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);
            Shipment__c Shipment = (Shipment__c)JSON.deserialize(Shipment1, Shipment__c.class);
            String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v14="http://fedex.com/ws/track/v16">';
                    soapXML += '<soapenv:Header/>';
                        soapXML += '<soapenv:Body>';
                            soapXML += '<v14:GetTrackingDocumentsRequest>';
                                soapXML += '<v14:WebAuthenticationDetail>';
                                    if(parentkey != '' && parentkey != null && parentPassword != '' && parentPassword != null ){
                                        soapXML += '<v14:ParentCredential>';
                                            soapXML += '<v14:Key>' + parentkey.escapeXml() + '</v14:Key>';
                                            soapXML += '<v14:Password>' + parentPassword.escapeXml() + '</v14:Password>';
                                        soapXML += '</v14:ParentCredential>';
                                    }
                                    soapXML += '<v14:UserCredential>';
                                        soapXML += '<v14:Key>'+ key.escapeXml() +'</v14:Key>';
                                        soapXML += '<v14:Password>'+ password.escapeXml() +'</v14:Password>';
                                    soapXML += '</v14:UserCredential>';
                                soapXML += '</v14:WebAuthenticationDetail>';
                                
                                soapXML += '<v14:ClientDetail>';
                                    soapXML += '<v14:AccountNumber>'+ accountNumber.escapeXml() +'</v14:AccountNumber>';
                                    soapXML += '<v14:MeterNumber>'+ meterNumber.escapeXml() +'</v14:MeterNumber>';
                                soapXML += '</v14:ClientDetail>';
                                
                                soapXML += '<v14:TransactionDetail>';
                                    soapXML += '<v14:CustomerTransactionId>SPOD Email</v14:CustomerTransactionId>';
                                soapXML += '</v14:TransactionDetail>';
                                
                                soapXML += '<v14:Version>';
                                    soapXML += '<v14:ServiceId>trck</v14:ServiceId>';
                                    soapXML += '<v14:Major>16</v14:Major>'; 
                                    soapXML += '<v14:Intermediate>0</v14:Intermediate>';
                                    soapXML += '<v14:Minor>0</v14:Minor>';
                                soapXML += '</v14:Version>';
                                soapXML += '<v14:SelectionDetails>';
                                    soapXML += '<v14:CarrierCode>'+ Shipment.Carrier_Code__c +'</v14:CarrierCode>';
                                    soapXML += '<v14:PackageIdentifier>';
                                        soapXML += '<v14:Type>TRACKING_NUMBER_OR_DOORTAG</v14:Type>';
                                        soapXML += '<v14:Value>'+ Shipment.Tracking_Number__c +'</v14:Value>';
                                    soapXML += '</v14:PackageIdentifier>';
                                soapXML += '</v14:SelectionDetails>';
                                soapXML += '<v14:TrackingDocumentSpecification>';
                                    soapXML += '<v14:DocumentTypes>SIGNATURE_PROOF_OF_DELIVERY</v14:DocumentTypes>';
                                    soapXML += '<v14:SignatureProofOfDeliveryDetail>';
                                    soapXML += '<v14:DocumentFormat>';
                                        soapXML += '<v14:Dispositions>';
                                            soapXML += '<v14:DispositionType>EMAIL</v14:DispositionType>';
                                            soapXML += '<v14:EMailDetail>';
                                                soapXML += '<v14:Recipients>';
                                                    soapXML += '<v14:EmailAddress>'+ toAddress.Contact__r.Email.escapeXml() +'</v14:EmailAddress>';
                                                    //soapXML += '<v14:EmailAddress>uzair@apexcloud.com</v14:EmailAddress>';
                                                    soapXML += '<v14:Name>'+ toAddress.Contact__r.Name.escapeXml() +'</v14:Name>';
                                                soapXML += '</v14:Recipients>';
                                                soapXML += '<v14:Sender>';
                                                    soapXML += '<v14:EmailAddress>'+ upsCredentials[0].Shipper_Email__c.escapeXml() +'</v14:EmailAddress>';
                                                    //soapXML += '<v14:EmailAddress>mohammed.uzair@aqxolt.com</v14:EmailAddress>';
                                                    soapXML += '<v14:Name>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</v14:Name>';
                                                soapXML += '</v14:Sender>';
                                                soapXML += '<v14:Localization>';
                                                    soapXML += '<v14:LanguageCode>EN</v14:LanguageCode>';
                                                    soapXML += '<v14:LocaleCode>US</v14:LocaleCode>';
                                                soapXML += '</v14:Localization>';
                                            soapXML += '</v14:EMailDetail>';
                                        soapXML += '</v14:Dispositions>';
                                        soapXML += '<v14:Grouping>CONSOLIDATED_BY_DOCUMENT_TYPE</v14:Grouping>';
                                        soapXML += '<v14:ImageType>PDF</v14:ImageType>';
                                    soapXML += '</v14:DocumentFormat>';
                                    soapXML += '</v14:SignatureProofOfDeliveryDetail>';
                                soapXML += '</v14:TrackingDocumentSpecification>';
                            soapXML += '</v14:GetTrackingDocumentsRequest>';
                        soapXML += '</soapenv:Body>';
                    soapXML += '</soapenv:Envelope>';
            
            HttpRequest req = new HttpRequest();
            Http h = new Http();
            
            req.setBody(soapXML);
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-length', '200');
            req.setHeader('Content-Type', 'text/xml'); 
            req.setHeader('SOAPAction', '');
            
            HttpResponse res = h.send(req);            
            request_1 = soapXmL;
            response_1 = res.getBody();
             
            resStatus = res.getStatus();
            
            if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponseOnce(reader1, 'Severity');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader reader = res.getXmlStreamReader(); String letter = readXMLResponse(reader, 'Content');
                    if(letter != null) {
                        attachment att = new attachment(Name = 'Proof of Delivery', parentId = Shipment.Id, ContentType = 'application/pdf');
                        if(Schema.sObjectType.attachment.fields.body.isCreateable()) { att.body = EncodingUtil.base64Decode(letter); }
                        if(Schema.sObjectType.attachment.isCreateable()) insert att;
                        spodLetter = att; if(spodLetter != null) showAndHideMap.put(9, true); Result = 'Request was successfully processed';
                    }
                } else { XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'Message');
                         if(mesage != Null && mesage != '') Result = 'Request for signature proof of delivery cannot be processed : ' + mesage;
                         else Result = 'Request for signature proof of delivery cannot be processed';
                }
            } else Result = 'Result not available';
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    
    //  wrapper class definitions.
    
     // rate wrapper class
    public List<rateWrapper> rateWrapperList       { get; set; }    
    public class rateWrapper {
        public String Service                      { get; set; }
        public String serviceName                  { get; set; }                  
        public String totalCharges                 { get; set; }
        public String currencyCode                 { get; set; }   
        public String totalSurcharges              { get; set; }   
        
        public rateWrapper() {
            Service = '';
            serviceName = '';
            totalCharges = '';
            currencyCode = '';
            totalSurcharges = '';
        }
    }
     // track wrapper class
    public List<trackwrapper> trackwrapperlist                             { get; set; }    
    public class trackwrapper {                 
        public String location                                             { get; set; }  
        public DateTime dtValue                                            { get; set; } 
        public String timeStamp                                            { get; set; }
        public String activityDesp                                         { get; set; }          
        public String arrivalLocation                                      { get; set; }  
        public String dateTimeString                                       { get; set; }               
        public String SignedForByName                                      { get; set; }   
            
        public trackwrapper() {    
            location = '';
            timeStamp = '';            
            activityDesp = ''; 
            dateTimeString = ''; 
            arrivalLocation = '';          
            SignedForByName = '';
        }        
    }
    
    // ------------------------- User Defined Function Reading XMLResponse -------------------------             
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
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
    // ------------------------- User Defined Function for getting First Value -------------------------     
    public static String readXMLResponseFirstValue(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; // Read through the XML
        try {           
            Boolean resultAchieved = false; 
            while (reader.hasNext() && resultAchieved == false) {
                if (reader.getEventType() == XmlTag.START_ELEMENT) { 
                    if (sxmltag == reader.getLocalName()) {
                        while (reader.hasNext()) {
                            if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 
                            else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); resultAchieved = true; break; }
                            reader.next(); } }   
                } reader.next();                   
            }         
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return retValue; 
    }                    
    // ------------------------- User Defined Function for getting responce only once -------------------------      
    public static String readXMLResponseOnce(XmlStreamReader reader, String sxmltag) {
        String retValue = ''; // Read through the XML
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
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return retValue; 
    }*/
}