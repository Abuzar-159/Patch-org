public with sharing class UPSHandler {

    public UPSHandler(PickPackShipController controller) {}

 
    public String Key                                         { get; set; }
    public Boolean flag                                       { get; set; }
    public String result                                      { get; set; }
    public String shipId;
    public String retValue;
    public String endPoint                                    { get; set; }
    public String errorMsg                                    { get; set; } 
    public String userName                                    { get; set; }
    public String password                                    { get; set; }
    public String resStatus                                   { get; set; }
    public String errorMsg1                                   { get; set; } public String PSAFields                                   { get; set; }
    public List<Id> packIds;
    
    public String request_1                                   { get; set; }  public String request_2                                   { get; set; } 
    public String response_1                                  { get; set; }   public String response_2                                  { get; set; }    
      
   
    public String service_code                                { get; set; }   public Attachment upsLabel                                { get; set; }      					public String originStreet                                { get; set; }   public Date shipmentDate                                  { get; set; }  						public String customerEmail                               { get; set; }     public String addressNotice                               { get; set; } 
    public String Fservice_code                               { get; set; }
    public Shipment__c Shipment                               { get; set; } public String delivery_date                               { get; set; }     
    public String addressFields                               { get; set; } 
    public String packageFields                               { get; set; }    
    public String shipmentFields                              { get; set; } public Attachment spodLetter                              { get; set; }
    public String interFormValue                              { get; set; } 
    public Sales_Order__c toAddr                              { get; set; } 
    public Order toAddrOr                                     { get; set; } 
    public Address__c fromAddress                             { get; set; }public Boolean toShipmentType                             { get; set; } 
    public Sales_Order__c fromAddr                            { get; set; }  public Order fromAddrOr                                   { get; set; } 
    public String upsAccountNumber                            { get; set; }
    public String credentialFields                            { get; set; }            public Boolean address_val_tab                            { get; set; }
    public Boolean time_in_cost_tab                           { get; set; }public Boolean fromShipmentType                           { get; set; }
    public String destinationStreet                           { get; set; } public String originCountryCode                           { get; set; }
    public String packageListFields                           { get; set; }public String originProvinceCode                          { get; set; }
    public String shipperCountryCode                          { get; set; }    
    public List<Package__c> Packages                          { get; set; }    public String shipperProvinceCode                         { get; set; }    
    public Address__c shippingAddress                         { get; set; } public String service_description                         { get; set; }                
    public Boolean isUPSPaperlessInvoice                      { get; set; }
    public String destinationCountryCode                      { get; set; }
    public String destinationProvinceCode                     { get; set; }
    public Map<String, String> recordIdMap                    { get; set; }    public Boolean pickup_pendingstatus_Tab                   { get; set; }					public Boolean pickup_servicecenter_Tab                   { get; set; }
    public List<Credentials__c> upsCredentials                { get; set; }
    public Map<Integer, Boolean> showAndHideMap               { get; set; }     
    public Map<String, UPS_Package_Type__c> packageTypeMap    { get; set; }public String sfdcBaseURL                                 { get; set; }					public EmailTemplate upsInvoiceTemplate                   { get; set; }
    public String LabelWidth                                  { get; set; } public Boolean hasAccess                                  { get; set; }
    public String LabelHeight                                 { get; set; } public String errormsg2                                   { get; set; }public List<String> shipmentImageLists                    { get; set; } public String serializedList                              { get; set; }
    public EmailTemplate paidReturnTemplate                         { get; set; } public String templateHtmlBody                                  { get; set; }   public List<Attachment> attachList                    { get; set; }    public String templateEmailSubject                              { get; set; } 
    
    
    /*
      Constructor.
    */
    public UPSHandler() {  
        try {
            addressFields = UtilClass.selectStarFromSObject('ERP7__Address__c');
            packageFields = UtilClass.selectStarFromSObject('ERP7__Package__c');
            shipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c'); 
            credentialFields = UtilClass.selectStarFromSObject('ERP7__Credentials__c');
            packageListFields = UtilClass.selectStarFromSObject('ERP7__Package_List__c'); 
            flag = false;    
            errorMsg = '';
            Fservice_code = '96';
            packIds = new List<Id>();
            time_in_cost_tab = false;
            Shipment = new Shipment__c();
            toAddr = new Sales_Order__c();
            fromAddress = new Address__c();
            fromAddr = new Sales_Order__c(); 
            shippingAddress = new Address__c();            
            recordIdMap = new Map<String, String>();            
            if(Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Product_Unit_Code__c.isUpdateable()) Shipment.Product_Unit_Code__c = 'Piece';
            if(Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Reason_For_Export__c.isUpdateable()) Shipment.Reason_For_Export__c = 'Sale'; 
            if(Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Date__c.isUpdateable()) Shipment.Shipment_Date__c = System.Today();
            showAndHideMap = new Map<Integer, Boolean>();  
            packageTypeMap = new Map<String, UPS_Package_Type__c>();   
            for(Integer i=1; i<=12; i++) { if(i==1 || i==10) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); } 
            //Commenting the below as using description from package object
            //List<Package_Details__c> pkgs = new List<Package_Details__c> ([select Id, Name, Shipment_Description__c from Package_Details__c where Shipment_Description__c != null limit 1]);
            //if(pkgs.size() > 0 && pkgs[0].Shipment_Description__c != null) shipment.Description__c = pkgs[0].Shipment_Description__c;
                                
            List <UPS_Package_Type__c> packageType = [select Id, Name, Package_Code__c, Package_Description__c from UPS_Package_Type__c limit 12];                                                                      
            for(UPS_Package_Type__c upt : packageType) { packageTypeMap.put(upt.Package_Description__c, upt); }
            upsCredentials = Database.query('select ' + String.escapeSingleQuotes(credentialFields) + ' from Credentials__c where (Name = \'UPS\' And Active__c = true) Limit 1');
            if(upsCredentials != null && upsCredentials.size() > 0) {
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(upsCredentials[0].Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsCredentials[0].Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(upsCredentials[0].Password_Transkey__c));
                if(userData != null) upsCredentials[0].Username_Login__c = userData.toString();
                if(passwordData != null) upsCredentials[0].Password_Transkey__c = passwordData.toString();
                
                Key = upsCredentials[0].Key__c; 
                password = upsCredentials[0].Password_Transkey__c; 
                userName = upsCredentials[0].Username_Login__c;
                endPoint = upsCredentials[0].URL__c;      
                upsAccountNumber = upsCredentials[0].UPS_Account_Number__c;
                if(upsCredentials[0].Label_Height__c != null) LabelHeight = string.valueOf(upsCredentials[0].Label_Height__c); else LabelHeight = '4';
                if(upsCredentials[0].Label_Width__c != null) LabelWidth = string.valueOf(upsCredentials[0].Label_Width__c); else LabelWidth = '6';
                if(getProvinceCode(upsCredentials[0].Shipper_Province__c) != '') shipperProvinceCode = getProvinceCode(upsCredentials[0].Shipper_Province__c);
                else errorMsg = 'UPS Shipping Service Unavailable : Shipper Province Code not found';
                if(getCountryCode(upsCredentials[0].Shipper_Country__c) != '') shipperCountryCode = getCountryCode(upsCredentials[0].Shipper_Country__c); else errorMsg = 'UPS Shipping Service Unavailable : Shipper Country Code not found';                 } else errorMsg = 'UPS Shipping Service Unavailable : Please setup UPS credentials';             } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
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
        } if(countryList != null && countryList.size() > 0) return countryList[0].Code__c; else return ''; 
    }
    public String getStreet(String AddressLine1, String AddressLine2, String AddressLine3) {
        if((AddressLine1 != Null && AddressLine1 != '') && (AddressLine2 != Null && AddressLine2 != '') && (AddressLine3 != Null && AddressLine3 != '')) {
            return AddressLine1 +', '+ AddressLine2 +', '+ AddressLine3; } 
        else if((AddressLine1 != Null && AddressLine1 != '') && (AddressLine2 != Null && AddressLine2 != '')) { return AddressLine1 +', '+ AddressLine2; }
        else if(AddressLine1 != Null && AddressLine1 != '') { return AddressLine1; } else return '';
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
    
    /*
      Init method called after setting the package Id / shipment Id.
    */
    public void init() { try { if(packIds.size() > 0) { String bFilter, sFilter; Packages = new List<Package__c>(); packListWrapper = new List<plWrapper>(); for(Package__c p : Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, ERP7__Order__r.Channel__c ,ERP7__Order__r.Channel__r.Ship_From_Address__c, ERP7__Order__r.Bill_To_Address__c, ERP7__Order__r.Ship_To_Address__c, Sales_Order__r.Channel__c, Sales_Order__r.Channel__r.Ship_From_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, '+ +' Purchase_Order__r.Channel__r.Ship_From_Address__c, Purchase_Order__r.Invoice_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Vendor_Address__c, Transfer_Order__r.From_Address__c, Transfer_Order__r.To_Address__c, ERP7__Order__r.Contact__r.Email ,Sales_Order__r.Contact__r.Email, Logistic__r.Sales_Order__c, Logistic__r.Sales_Order__r.Contact__c, Logistic__r.Sales_Order__r.Contact__r.Name, Logistic__r.Sales_Order__r.Contact__r.Phone, Logistic__r.Sales_Order__r.Contact__r.Email, Logistic__r.Sales_Order__r.Contact__r.ERP7__Company__c, '+ +' Logistic__r.ERP7__Order_S__r ,Logistic__r.ERP7__Order_S__r.Contact__c, Logistic__r.ERP7__Order_S__r.Contact__r.Name, Logistic__r.ERP7__Order_S__r.Contact__r.Phone, Logistic__r.ERP7__Order_S__r.Contact__r.Email, Logistic__r.ERP7__Order_S__r.Contact__r.ERP7__Company__c,Return_Merchandise_Authorisation__r.SO__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, '+ +' Return_Merchandise_Authorisation__r.Order__r.Channel__r.Ship_From_Address__c, Return_Merchandise_Authorisation__r.Order__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.ERP7__Order__r.Ship_To_Address__c, Transfer_Order__r.Contact__r.Email,Return_Merchandise_Authorisation__r.Order_r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, (select ' + String.escapeSingleQuotes(packageListFields) + ' ,Package__r.Name, Package__r.Description__c, Package__r.Weight_Unit__c, Package__r.Weight__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Base_Price__c, '+ +' Package__r.ERP7__Order__c, ERP7__Order_Product__r.Base_Price__c, ERP7__Order_Product__r.Product2.SKU__c, ERP7__Order_Product__r.Product2.Name, Sales_Order_Line_Item__r.Product__r.SKU__c, Sales_Order_Line_Item__r.Product__r.Name, Work_Order_Line_Items__r.Product__r.Name, Purchase_Line_Items__r.Product__r.Name, Transfer_Order_Line_Item__r.Products__r.Name, RMA_Line_Item__r.SOLI__r.Product__r.Name,RMA_Line_Item__r.ERP7__Ord_Item__c.Product2.Name, '+ +' Work_Order_Line_Items__r.Total_Cost__c, Work_Order_Line_Items__r.Unit_Price__c, Purchase_Line_Items__r.Total_Price__c, Purchase_Line_Items__r.Unit_Price__c, RMA_Line_Item__r.Total_Deduction__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.ReturnedQuantity__c,ERP7__Order_Product__r.Total_Price__c, ERP7__Order_Product__r.ReturnedQuantity__c, '+ +' Sales_Order_Line_Item__r.Sales_Order__r.Name, Sales_Order_Line_Item__r.Price_Product__c, Sales_Order_Line_Item__r.Product__r.Goods_Description__c, Sales_Order_Line_Item__r.Product__r.Commodity_Code__c ,ERP7__Order_Product__r.Order.Name, ERP7__Order_Product__r.UnitPrice, ERP7__Order_Product__r.Product2.Goods_Description__c, ERP7__Order_Product__r.Product2.Commodity_Code__c From Package_Lists__r) from Package__c where Id In: packIds And Active__c = true')) { for(sObject c : p.Package_Lists__r) { plWrapper wr = new plWrapper(); wr.pl = (Package_List__c)c; packListWrapper.add(wr); } Packages.add(p); } if(packListWrapper.size() > 0) { for(plWrapper plw: packListWrapper) { if(plw.pl.Sales_Order_Line_Item__c != null) { plw.declaredValue = (plw.pl.Sales_Order_Line_Item__r.Price_Product__c * plw.pl.Quantity__c).setScale(2); plw.goodsDescription = (plw.pl.Sales_Order_Line_Item__r.Product__r.Goods_Description__c != Null)? plw.pl.Sales_Order_Line_Item__r.Product__r.Goods_Description__c : ''; plw.commodityCode = (plw.pl.Sales_Order_Line_Item__r.Product__r.Commodity_Code__c != Null)? plw.pl.Sales_Order_Line_Item__r.Product__r.Commodity_Code__c : ''; } else if(plw.pl.ERP7__Order_Product__c != null) { plw.declaredValue = (plw.pl.ERP7__Order_Product__r.UnitPrice * plw.pl.Quantity__c).setScale(2); plw.goodsDescription = (plw.pl.ERP7__Order_Product__r.Product2.Goods_Description__c != Null)? plw.pl.ERP7__Order_Product__r.Product2.Goods_Description__c : ''; plw.commodityCode = (plw.pl.ERP7__Order_Product__r.Product2.Commodity_Code__c != Null)? plw.pl.ERP7__Order_Product__r.Product2.Commodity_Code__c : ''; } else if(plw.pl.Work_Order_Line_Items__c != null) { plw.declaredValue = (plw.pl.Work_Order_Line_Items__r.Unit_Price__c * plw.pl.Quantity__c).setScale(2); } else if(plw.pl.Purchase_Line_Items__c != null) { plw.declaredValue = (plw.pl.Purchase_Line_Items__r.Unit_Price__c * plw.pl.Quantity__c).setScale(2); } else if(plw.pl.RMA_Line_Item__c != null) { plw.declaredValue = (plw.pl.RMA_Line_Item__r.Total_Deduction__c * plw.pl.Quantity__c).setScale(2); } } } if(Packages[0].Logistic__c != null) recordIdMap.put('LO', Packages[0].Logistic__c); if(Packages[0].Sales_Order__c != null) recordIdMap.put('SO', Packages[0].Sales_Order__c);   if(Packages[0].ERP7__Order__c != null) recordIdMap.put('Ord', Packages[0].ERP7__Order__c); else if(Packages[0].Work_Order__c != null) recordIdMap.put('WO', Packages[0].Work_Order__c); else if(Packages[0].Purchase_Order__c != null) recordIdMap.put('PO', Packages[0].Purchase_Order__c); else if(Packages[0].Transfer_Order__c != null) recordIdMap.put('TO', Packages[0].Transfer_Order__c); else if(Packages[0].Return_Merchandise_Authorisation__c != null) recordIdMap.put('SR', Packages[0].Return_Merchandise_Authorisation__c); if(Packages[0].Logistic__r.From_Address__c != null) { if(fromAddr.Bill_To_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Logistic__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Logistic__r.From_Address__c + '\''; } else if(fromAddrOr.Bill_To_Address__c != null) { fromAddrOr.Bill_To_Address__c = Packages[0].Logistic__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Logistic__r.From_Address__c + '\'';  } } else if(Packages[0].Work_Order__r.Billing_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Work_Order__r.Billing_Address__c; bFilter = 'Id =\'' + Packages[0].Work_Order__r.Billing_Address__c + '\''; } else if(Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c; bFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Channel__r.Ship_From_Address__c + '\''; } else if(Packages[0].Transfer_Order__r.From_Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Transfer_Order__r.From_Address__c; bFilter = 'Id =\'' + Packages[0].Transfer_Order__r.From_Address__c + '\''; } else if(Packages[0].Return_Merchandise_Authorisation__r.Address__c != null) { fromAddr.Bill_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.Address__c; bFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.Address__c + '\''; } if(Packages[0].Logistic__r.To_Address__c != null) { if(toAddr.Ship_To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Logistic__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Logistic__r.To_Address__c + '\''; } else if(toAddrOr.Ship_To_Address__c != null) { toAddrOr.Ship_To_Address__c = Packages[0].Logistic__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Logistic__r.To_Address__c + '\''; } } else if(Packages[0].Work_Order__r.Shipping_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Work_Order__r.Shipping_Address__c; sFilter = 'Id =\'' + Packages[0].Work_Order__r.Shipping_Address__c + '\''; } else if(Packages[0].Purchase_Order__r.Vendor_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Purchase_Order__r.Vendor_Address__c; sFilter = 'Id =\'' + Packages[0].Purchase_Order__r.Vendor_Address__c + '\''; } else if(Packages[0].Transfer_Order__r.To_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Transfer_Order__r.To_Address__c; sFilter = 'Id =\'' + Packages[0].Transfer_Order__r.To_Address__c + '\''; } else if(Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c != null) { toAddr.Ship_To_Address__c = Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c; sFilter = 'Id =\'' + Packages[0].Return_Merchandise_Authorisation__r.Channel__r.Ship_From_Address__c + '\''; } if(bFilter != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ String.escapeSingleQuotes(bFilter) +' Limit 1'); if(sFilter != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where '+ String.escapeSingleQuotes(sFilter) +' Limit 1'); if(fromAddress != null) { if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c); else errorMsg = 'UPS Shipping Service Unavailable : Origin Province Code not found'; if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c); else errorMsg = 'UPS Shipping Service Unavailable : Origin Country Code not found'; if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c); fromAddr.Bill_To_Address__c = fromAddress.Id; } if(shippingAddress != null) { if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c); else errorMsg = 'UPS Shipping Service Unavailable : Destination Province Code not found'; if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'UPS Shipping Service Unavailable : Destination Country Code not found'; if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c); if(getIsUPSPaperlessInvoice(shippingAddress.Country__c) != false) isUPSPaperlessInvoice = getIsUPSPaperlessInvoice(shippingAddress.Country__c); toAddr.Ship_To_Address__c = shippingAddress.Id; } shipment.Description__c = ''; if(Packages[0].PO_Reference__c != null && Packages[0].PO_Reference__c != '') shipment.Description__c += Packages[0].PO_Reference__c + ' '; if(Packages[0].Description__c != null && Packages[0].Description__c != '') shipment.Description__c += Packages[0].Description__c; } else if(shipId != null && shipId  != '') { Packages = Database.query('select ' + String.escapeSingleQuotes(packageFields) + ' , Logistic__r.Order__c, Logistic__r.From_Address__c, Logistic__r.To_Address__c, ERP7__Order__r.Bill_To_Address__c, ERP7__Order__r.Ship_To_Address__c, Sales_Order__r.Bill_To_Address__c, Sales_Order__r.Ship_To_Address__c, Work_Order__r.Billing_Address__c, Work_Order__r.Shipping_Address__c, Purchase_Order__r.Delivery_Address__c, Purchase_Order__r.Invoice_Address__c,ERP7__Order__r.Contact__r.Email, '+ +' Transfer_Order__r.From_Address__c, Transfer_Order__r.To_Address__c, ERP7__Order__r.Channel__c ,Sales_Order__r.Channel__c, Return_Merchandise_Authorisation__r.SO__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.SO__r.Ship_To_Address__c,Return_Merchandise_Authorisation__r.Order__r.Bill_To_Address__c, Return_Merchandise_Authorisation__r.Order__r.Ship_To_Address__c, Sales_Order__r.Contact__r.Email, Logistic__r.Sales_Order__c, Logistic__r.Sales_Order__r.Contact__c, Logistic__r.Sales_Order__r.Contact__r.Phone, Logistic__r.Sales_Order__r.Contact__r.Email, Logistic__r.Sales_Order__r.Contact__r.ERP7__Company__c, '+ +' Logistic__r.ERP7__Order_S__r ,Logistic__r.ERP7__Order_S__r.Contact__c, Logistic__r.ERP7__Order_S__r.Contact__r.Name, Logistic__r.ERP7__Order_S__r.Contact__r.Phone, Logistic__r.ERP7__Order_S__r.Contact__r.Email, Logistic__r.ERP7__Order_S__r.Contact__r.ERP7__Company__c, Work_Order__r.Contact__r.Email, Purchase_Order__r.Vendor_Contact__r.Email, Transfer_Order__r.Contact__r.Email, Return_Merchandise_Authorisation__r.SO__r.Contact__r.Email, Return_Merchandise_Authorisation__r.Order_r.Contact__r.Email from Package__c where Shipment__c =\'' + String.escapeSingleQuotes(shipId) + '\' And Active__c = true'); String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping'); Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1'); Shipment = (Shipment != null) ? Shipment : new Shipment__c(); if(Shipment.Billing_Address__c != null) { if(fromAddr.Bill_To_Address__c !=null) {fromAddr.Bill_To_Address__c = Shipment.Billing_Address__c; fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Billing_Address__c) + '\' Limit 1'); } else if(fromAddrOr.Bill_To_Address__c !=null) { fromAddrOr.Bill_To_Address__c = Shipment.Billing_Address__c; fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Billing_Address__c) + '\' Limit 1'); } } if(Shipment.Shipping_Address__c != null) { if(toAddr.Ship_To_Address__c !=null) { toAddr.Ship_To_Address__c = Shipment.Shipping_Address__c; shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Shipping_Address__c) + '\' Limit 1'); } else if(toAddrOr.Ship_To_Address__c !=null) { toAddrOr.Ship_To_Address__c = Shipment.Shipping_Address__c; shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(Shipment.Shipping_Address__c) + '\' Limit 1'); } } if(fromAddress != null) { if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c); else errorMsg = 'UPS Shipping Service Unavailable : Origin Province Code not found'; if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c); else errorMsg = 'UPS Shipping Service Unavailable : Origin Country Code not found'; if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c); if(fromAddr.Bill_To_Address__c !=null)  fromAddr.Bill_To_Address__c = fromAddress.Id; else if(fromAddrOr.Bill_To_Address__c !=null)  fromAddrOr.Bill_To_Address__c = fromAddress.Id; } if(shippingAddress != null) { if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c); else errorMsg = 'UPS Shipping Service Unavailable : Destination Province Code not found'; if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'UPS Shipping Service Unavailable : Destination Country Code not found'; if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c); if(getIsUPSPaperlessInvoice(shippingAddress.Country__c) != false) isUPSPaperlessInvoice = getIsUPSPaperlessInvoice(shippingAddress.Country__c); if(toAddr.Ship_To_Address__c !=null) toAddr.Ship_To_Address__c = shippingAddress.Id; else if(toAddrOr.Ship_To_Address__c !=null) toAddrOr.Ship_To_Address__c = shippingAddress.Id; } List<Attachment> myAttachment = new List<Attachment>(); if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%UPS_Label%' order by CreatedDate DESC]; for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9) showAndHideMap.put(i, false); else showAndHideMap.put(i, true); } } upsLabel = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment(); myAttachment = new List<Attachment>(); if(Shipment != null) { myAttachment = [Select Id, Name, body, ParentId, CreatedDate From Attachment where ParentId = : Shipment.Id And Name like '%Proof of Delivery.doc%' order by CreatedDate DESC Limit 1]; showAndHideMap.put(8, false); showAndHideMap.put(9, true); } spodLetter = (myAttachment.size() > 0) ? myAttachment[0] : new Attachment(); } flag = true; } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); } }  
    
    /*
      method for displaying iternational form panels (CN22/Invoice).
    */
    public PageReference displayForms() {
        try {
            if(interFormValue == 'Invoice') { errorMsg1 = ''; showAndHideMap.put(11, true); showAndHideMap.put(12, true); }
            else if(interFormValue == 'CN22 Forms') {
                if(isUPSPaperlessInvoice != null && isUPSPaperlessInvoice) { showAndHideMap.put(12, true); showAndHideMap.put(11, false); }
                else { showAndHideMap.put(12, false); showAndHideMap.put(11, false);                
                       errorMsg1 = 'Paperless invoice is not supported for the shipTo country, Please print 3 copies of invoice and attach to the shipment.'; }
            } else { errorMsg1 = ''; showAndHideMap.put(11, false); showAndHideMap.put(12, false); } } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for getting from and to address upon change.
    */
    public PageReference fetchAddress() {
        try { 
            if(toAddr.Ship_To_Address__c != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(toAddr.Ship_To_Address__c) + '\' Limit 1'); else if(toAddrOr.Ship_To_Address__c != null) shippingAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ', Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(toAddrOr.Ship_To_Address__c) + '\' Limit 1');
            if(fromAddr.Bill_To_Address__c != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(fromAddr.Bill_To_Address__c) + '\' Limit 1'); else if(fromAddrOr.Bill_To_Address__c != null) fromAddress = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' ,Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Company__c from Address__c where Id =\'' + String.escapeSingleQuotes(fromAddrOr.Bill_To_Address__c) + '\' Limit 1'); if(fromAddress != null) { errorMsg = ''; if(getProvinceCode(fromAddress.State__c) != '') originProvinceCode = getProvinceCode(fromAddress.State__c); else errorMsg = 'UPS Shipping Service Unavailable : Origin Province Code not found'; if(getCountryCode(fromAddress.Country__c) != '') originCountryCode = getCountryCode(fromAddress.Country__c); else errorMsg = 'UPS Shipping Service Unavailable : Origin Country Code not found'; if(getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c) != '') originStreet = getStreet(fromAddress.Address_Line1__c, fromAddress.Address_Line2__c, fromAddress.Address_Line3__c); if(fromAddr.Bill_To_Address__c != null) fromAddr.Bill_To_Address__c = fromAddress.Id; else if(fromAddrOr.Bill_To_Address__c != null) fromAddrOr.Bill_To_Address__c = fromAddress.Id; } if(shippingAddress != null) { errorMsg = ''; if(getProvinceCode(shippingAddress.State__c) != '') destinationProvinceCode = getProvinceCode(shippingAddress.State__c); else errorMsg = 'UPS Shipping Service Unavailable : Destination Province Code not found'; if(getCountryCode(shippingAddress.Country__c) != '') destinationCountryCode = getCountryCode(shippingAddress.Country__c); else errorMsg = 'UPS Shipping Service Unavailable : Destination Country Code not found'; if(getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c) != '') destinationStreet = getStreet(shippingAddress.Address_Line1__c, shippingAddress.Address_Line2__c, shippingAddress.Address_Line3__c); if(getIsUPSPaperlessInvoice(shippingAddress.Country__c) != false) isUPSPaperlessInvoice = getIsUPSPaperlessInvoice(shippingAddress.Country__c); if(toAddr.Ship_To_Address__c != null) toAddr.Bill_To_Address__c = shippingAddress.Id; else if(toAddrOr.Ship_To_Address__c != null)  toAddrOr.Bill_To_Address__c = shippingAddress.Id; }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      method for generating ups label as pdf to print.
    */
    public PageReference CreateUPSLabel() {
        //PageReference pg = page.Pickpackship_PrintUPSLabel;
        PageReference pg = page.PrintUPSLabel; 
        pg.getParameters().put('shipmentsId',Shipment.Id);
        pg.getParameters().put('fileName','UPS_Label');
        pg.getParameters().put('val','pdf');
        return pg;        
    }
    
    /*
      method for generating commercial invoice as pdf to print
    */
    public PageReference CreateCommInvoice() {                
        PageReference pg = page.UPSCommercialInvoice;
        pg.getParameters().put('shipmentsId',Shipment.Id);
        return pg;
    }

	//commmented by khaleeq due to an issue of commercial invoice. used other approach
    /*public PageReference fetchUPSInvoice() {
        sfdcBaseURL = System.URL.getOrgDomainUrl().toExternalForm();
        //sfdcBaseURL = URL.getSalesforceBaseUrl().getHost();  // edited now
        //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
        //sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.content.force.com');
           String initurl = Label.initURL;
           String DestinationURL = Label.DestURL;
            //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('.visual.force.com');
           sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL);
       system.debug('bfr sfdcBaseURL :'+sfdcBaseURL);
        sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
        //added below 2 line for sandbox
        if(sfdcBaseURL.contains('sandbox')){
            sfdcBaseURL = sfdcBaseURL.replace('--c','');
        }
        sfdcBaseURL = 'erp-mark-7-dev-ed.file.force.com';
        system.debug('after sfdcBaseURL :'+sfdcBaseURL);
        String shipId = ApexPages.CurrentPage().getParameters().get('shipmentsId');
        String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping'); 
        if(shipId != null) Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1');
        Shipment = (Shipment != null) ? Shipment : new Shipment__c();
        
        List<SetEmailTemplates__c> EmailTemplates_uniqueName = new List<SetEmailTemplates__c>([Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c From SetEmailTemplates__c where Name ='UPS_Commercial_Invoice' limit 1]);
        if(EmailTemplates_uniqueName.size() > 0) {
            upsInvoiceTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: EmailTemplates_uniqueName[EmailTemplates_uniqueName.size()-1].Template_Unique_Name__c];
            system.debug('upsInvoiceTemplate if==='+upsInvoiceTemplate.Id);
                }else {
                    upsInvoiceTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName =: 'UPS_Invoice'];
                    system.debug('upsInvoiceTemplate else==='+upsInvoiceTemplate.Id);
                }            
        return null;
    }*/
    
      //New method added on behalf of fetchUPSInvoice method for and also changed email template i,e., 'UPS_Commercial_Invo' .                                                 
    public void Email_Details(){    
            /*To get Email Content Before Sending Email For Preview*/
        	String shipId = ApexPages.CurrentPage().getParameters().get('shipmentsId');
            String ShipmentRecTypeId = RecordTypeUtil.getObjectRecordTypeIds('Shipment__c','UPS_Shipping'); 
            if(shipId != null) Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Active__c = true And Id=\'' + String.escapeSingleQuotes(shipId) + '\' And Status__c != \'Cancelled\' And RecordTypeId =\'' + String.escapeSingleQuotes(ShipmentRecTypeId) + '\') Limit 1');
            paidReturnTemplate = [select Id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName ='UPS_Commercial_Invo'];
            Messaging.SingleEmailMessage email_Attach = new Messaging.SingleEmailMessage();
            String [] toAddresses_test = new String[] {'test@test.com'}; 
            	email_Attach.setToAddresses(toAddresses_test);
            	email_Attach.setTemplateId(paidReturnTemplate.id);
            	email_Attach.setSaveAsActivity(false);  
                email_Attach.setWhatId(shipId);
        		email_Attach.setTargetObjectId(Shipment.ERP7__Customer_Contact__c);
                Savepoint sp = Database.setSavepoint();
                Messaging.SendemailResult [] email_Attach_Result = Messaging.sendemail(new Messaging.SingleEmailMessage[] {email_Attach}); 
                templateEmailSubject = email_Attach.getSubject();				templateHtmlBody = email_Attach.getHtmlBody();					Database.rollback(sp); 
    }
                                                       
    
    /*
      method for returning back to respective flows (SO, WO, PO, TO, SR)
    */
    public PageReference back() {					pageReference pg;						if(retValue == 'SR') { pg = new pageReference('/apex/ERP7__RMAPackage?id='+recordIdMap.get('SR')); pg.setRedirect(true); }					else { pg = new pageReference('/apex/ERP7__OutboundLogistics'); pg.setRedirect(true); }				return pg;
    }
    
    /*
      Address validation API request.
    */
    public PageReference Address_Validation() {				try {				time_in_cost_tab = false;				addressNotice = 'Any request to the UPS Address Validation API must be solely for the purpose of validating an address in connection with tendering a shipment intended for delivery via services offered by UPS and its Affiliates. Use of the UPS Address Validation API to validate an address in connection with a shipment that will not be delivered via UPS is prohibited.';					if(errorMsg != '') { return null; }						resStatus = Result = '';				if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This Package Has Already Been ' + Shipment.Status__c; } 					else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Postal Code Unavailable'; } else if(shippingAddress.Country__c != 'United States' && shippingAddress.Country__c != 'Puerto Rico') { errorMsg1 = 'UPS Shipping Service Unavailable : Origin and Destination country should be United States'; }  else { errorMsg1 = ''; Address_Validation_Request(JSON.serialize(shippingAddress)); } } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }				return null;
    }
    public PageReference Address_Validation_Request(String toAddress1) {
        try {
            Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);
            String soapXML = '<?xml version="1.0" ?>';
            soapXML += '<AccessRequest>';
            soapXML += '<AccessLicenseNumber>'+ Key.escapeXml() +'</AccessLicenseNumber>';
            soapXML += '<UserId>'+ userName.escapeXml() +'</UserId>';
            soapXML += '<Password>'+ password.escapeXml() +'</Password>';
            soapXML += '</AccessRequest>';
            
            soapXML += '<?xml version="1.0" ?>';
            soapXML += '<AddressValidationRequest xml:lang="en-US">';
                soapXML += '<Request>';
                    soapXML += '<RequestAction>AV</RequestAction>';
                soapXML += '</Request>';
                
                soapXML += '<Address>';
                    soapXML += '<PostalCode>'+ toAddress.Postal_Code__c.escapeXml() +'</PostalCode>';
                    soapXML += '<CountryCode>'+ destinationCountryCode.escapeXml() +'</CountryCode>';
                soapXML += '</Address>';
            soapXML += '</AddressValidationRequest>';
            
            HttpRequest req = new HttpRequest(); 
            Http h = new Http(); req.setBody(soapXML); req.setMethod('POST'); String myEndPoint = endpoint + '/ups.app/xml/AV'; req.setEndpoint(myEndPoint);
            HttpResponse res = h.send(req); request_1 = req.getBody(); response_1 = res.getBody(); resStatus = res.getStatus();           
            /*
              The quality factor, which describes the accuracy of the result compared to the request. 
              1.0 = Exact match.
              95-.99 = Very close match.
              90-.94 = Close match.
              70-.89 = Possible match.
              00-.69 = Poor match
            */
            if(resStatus == 'OK') {  XmlStreamReader reader = res.getXmlStreamReader(); String msg = readXMLResponse(reader, 'ResponseStatusDescription'); if (msg != Null && msg == 'SUCCESS') {XmlStreamReader reader1 = res.getXmlStreamReader(); readXMLResponseAddressValidationDetails(reader1,'AddressValidationResult'); address_val_tab = true;Result = 'Shipping Service Is Available'; } else { XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'ErrorDescription'); if (mesage != Null && mesage != '') Result = 'Shipping Service Is Not Available : ' + mesage; else Result = 'Shipping Service Cannot Be Processed'; }                
            } else Result = 'Result Not Available';     } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;        
    }
    public void readXMLResponseAddressValidationDetails(XmlStreamReader reader, String sxmltag) {					try {					addressValidationWrapper tw; addressValidationWrapperList = new List<addressValidationWrapper>();        				while(reader.hasNext()) {					if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { tw = new addressValidationWrapper();                        
                    // Rank
                    reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Rank') { reader.next();                        				if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 				else if (reader.getEventType() == XmlTag.CHARACTERS) { tw.Rank = reader.getText(); }                                                                                
                    }                
                    // Quality
                    reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Quality') { reader.next();					if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 						else if (reader.getEventType() == XmlTag.CHARACTERS) { tw.Quality = reader.getText(); }                        
                    }                
                    // City
                    reader.next(); reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'City') { reader.next();				if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 				else if (reader.getEventType() == XmlTag.CHARACTERS) { tw.City = reader.getText(); }
                    }                
                    // State Province Code
                    reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'StateProvinceCode') { reader.next();				if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 				else if (reader.getEventType() == XmlTag.CHARACTERS) { tw.StateProvinceCode = reader.getText(); }
                    }                
                    // Postal Code Low End
                    reader.next(); reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PostalCodeLowEnd') { reader.next();					if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 					else if (reader.getEventType() == XmlTag.CHARACTERS) { tw.PostalCodeLowEnd = reader.getText(); }
                    }                
                    // Postal Code High End
                    reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PostalCodeHighEnd') { reader.next();					if (reader.getEventType() == XmlTag.END_ELEMENT) { break; }					else if (reader.getEventType() == XmlTag.CHARACTERS) { tw.PostalCodeHighEnd = reader.getText(); }					} addressValidationWrapperList.add(tw);						} reader.next(); }   } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      Service & rate API request.
    */
    public PageReference Rate_Request() {				try { 					address_val_tab = false;   				if(errorMsg != '') { return null; }				resStatus = Result = '';				if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This Package Has Already Been ' + Shipment.Status__c; } 					else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; }								else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; } else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; } else if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'CA' && destinationCountryCode == 'US')) && Shipment.COD__c == 'Yes') errorMsg1 = 'Package Level COD Is Not Allowed For Selected Locations'; else if(Shipment.COD__c == 'Yes' && (Shipment.Delivery_Confirmation__c != null && Shipment.Delivery_Confirmation__c != '')) errorMsg1 = 'COD And Delivery Confirmation Cannot Co-Exists On A Single package'; else if((Shipment.Verbal_Confirmation__c == 'Yes') && (Shipment.Delivery_Confirmation__c != null && Shipment.Delivery_Confirmation__c != '')) errorMsg1 = 'Delivery Confirmation option cannot be combined with the Verbal Confirmation option'; else if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) && Shipment.Delivery_Confirmation__c == 'No Signature') errorMsg1 = 'This Delivery Confirmation Type Is Not Allowed For Selected Location'; else if((Shipment.Saturday_Delivery__c == 'Yes') && (!(service_code == '01' || service_code == '02' || service_code == '14' || service_code == '54' || service_code == '07'))) errorMsg1 = 'Saturday Delivery Is Not Allowed For This Service'; else {   errorMsg1 = ''; Date dt = Shipment.Shipment_Date__c; String saturdayDelivery, DeliveryConfirmation; if(Shipment.Saturday_Delivery__c == 'Yes') saturdayDelivery = '1'; else if(Shipment.Saturday_Delivery__c == 'No') saturdayDelivery = '0'; if((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) { if(Shipment.Delivery_Confirmation__c == 'No Signature') { DeliveryConfirmation = '1'; } else if(Shipment.Delivery_Confirmation__c == 'Signature Required'){ DeliveryConfirmation = '2'; } else if(Shipment.Delivery_Confirmation__c == 'Adult Signature Required') { DeliveryConfirmation = '3'; } } else if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US'))) { if(Shipment.Delivery_Confirmation__c == 'Signature Required') { DeliveryConfirmation = '1'; } else if(Shipment.Delivery_Confirmation__c == 'Adult Signature Required') { DeliveryConfirmation = '2'; } } String shipmentDate = dt.Year() + '' + dt.Month() + '' + dt.Day(); Service_And_Rate_Request(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), DeliveryConfirmation, saturdayDelivery); } } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return null;
    }
    //public PageReference Service_And_Rate_Request(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String DeliveryConfirmation, String saturdayDelivery) {
    public PageReference Service_And_Rate_Request(String fromAddress1, String toAddress1, String packList1, String DeliveryConfirmation, String saturdayDelivery) {
        
        try {    				Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);				Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);				List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);					string soapXML = '<?xml version="1.0"?>';					soapXML += '<AccessRequest xml:lang="en-US">';				soapXML += '<AccessLicenseNumber>'+ Key.escapeXml() +'</AccessLicenseNumber>';					soapXML += '<UserId>'+ userName.escapeXml() +'</UserId>';				soapXML += '<Password>'+ password.escapeXml() +'</Password>';					soapXML += '</AccessRequest>';
            
            soapXML += '<?xml version="1.0"?>';				soapXML += '<RatingServiceSelectionRequest>';				soapXML += '<Request>';			soapXML += '<RequestAction>Rate</RequestAction>';				soapXML += '<RequestOption>Shop</RequestOption>';				soapXML += '</Request>';
            
            soapXML += '<Shipment>';				if(upsCredentials != null && upsCredentials.size() > 0) {			soapXML += '<Shipper>';				soapXML += '<ShipperNumber>'+ upsAccountNumber.escapeXml() +'</ShipperNumber>';					soapXML += '<Address>';			soapXML += '<AddressLine1>'+ upsCredentials[0].Shipper_Street__c.escapeXml() +'</AddressLine1>';				soapXML += '<City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</City>';				soapXML += '<StateProvinceCode>'+ shipperProvinceCode.escapeXml() +'</StateProvinceCode>';				soapXML += '<PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';					soapXML += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';				soapXML += '</Address>';				soapXML += '</Shipper>';                                    
                }
                if(toAddress != null) {				soapXML += '<ShipTo>';				soapXML += '<Address>';				soapXML += '<AddressLine1>'+ destinationStreet.escapeXml() +'</AddressLine1>';				soapXML += '<City>'+ toAddress.City__c.escapeXml() +'</City>';				soapXML += '<PostalCode>'+ toAddress.Postal_Code__c.escapeXml() +'</PostalCode>';				soapXML += '<CountryCode>'+ destinationCountryCode.escapeXml() +'</CountryCode>';				soapXML += '</Address>';					soapXML += '</ShipTo>';
                }
                if(fromAddress != null) {				soapXML += '<ShipFrom>'; soapXML += '<Address>'; soapXML += '<AddressLine1>'+ originStreet.escapeXml() +'</AddressLine1>'; soapXML += '<City>'+ fromAddress.City__c.escapeXml() +'</City>'; if(originProvinceCode != null) soapXML += '<StateProvinceCode>'+ originProvinceCode.escapeXml() +'</StateProvinceCode>'; soapXML += '<PostalCode>'+ fromAddress.Postal_Code__c.escapeXml() +'</PostalCode>'; soapXML += '<CountryCode>'+ originCountryCode.escapeXml() +'</CountryCode>'; soapXML += '</Address>'; soapXML += '</ShipFrom>';
                }
                soapXml += '<RateInformation>'; soapXml += '<NegotiatedRatesIndicator>Y</NegotiatedRatesIndicator>'; soapXml += '</RateInformation>';					if(packList != null && packList.size() > 0) soapXML += '<NumOfPieces>'+ packList.size() +'</NumOfPieces>';					for(Package__c p : packList) {						soapXML += '<Package>'; soapXML += '<PackagingType>';					soapXML += '<Code>'+ packageTypeMap.get('Package').Package_Code__c.escapeXml() +'</Code>';				soapXML += '</PackagingType>'; soapXML += '<Dimensions>'; 					soapXML += '<UnitOfMeasurement>'; if(p.Weight_Unit__c == 'KGS') soapXML += '<Code>CM</Code>';				else soapXML += '<Code>IN</Code>'; soapXML += '</UnitOfMeasurement>'; soapXMl += '<Length>'+ p.Length__c +'</Length>';				soapXML += '<Width>'+ p.Width__c +'</Width>'; soapXML += '<Height>'+ p.Height__c +'</Height>'; soapXML += '</Dimensions>';   				soapXML += '<PackageWeight>'; soapXML += '<UnitOfMeasurement>'; soapXML += '<Code>'+ p.Weight_Unit__c.escapeXml() +'</Code>';            				soapXML += '</UnitOfMeasurement>'; soapXML += '<Weight>'+ p.Weight__c +'</Weight>'; soapXML += '</PackageWeight>';                   
                    
                    soapXML += '<PackageServiceOptions>';				soapXML += '<InsuredValue>'; soapXML += '<CurrencyCode>'+ getCurrencyIsoCode(p).escapeXml() +'</CurrencyCode>'; soapXML += '<MonetaryValue>'+ p.Declared_Value__c +'</MonetaryValue>';  soapXML += '</InsuredValue>';
                        
                        if(((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'CA' && destinationCountryCode == 'US')) && (Shipment.COD__c != null && Shipment.COD__c == 'Yes')) {             				soapXML += '<COD>'; soapXML += '<CODFundsCode>8</CODFundsCode>'; soapXML += '<CODAmount>';					if(destinationCountryCode == 'CA') { soapXML += '<CurrencyCode>CAD</CurrencyCode>';  } 				else if(destinationCountryCode == 'US') { soapXML += '<CurrencyCode>USD</CurrencyCode>'; }				soapXML += '<MonetaryValue>'+ p.Declared_Value__c +'</MonetaryValue>'; soapXML += '</CODAmount>'; soapXML += '</COD>';                              
                        }                    
                        if(Shipment.Verbal_Confirmation__c != null && Shipment.Verbal_Confirmation__c == 'Yes') {               					soapXML += '<VerbalConfirmation>'; soapXML += '<Name>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</Name>'; soapXML += '<PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c +'</PhoneNumber>'; soapXML += '</VerbalConfirmation>';
                        }      
                        if(((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) && deliveryConfirmation != null) {					soapXML += '<DeliveryConfirmation>'; soapXML += '<DCISType>'+ deliveryConfirmation.escapeXml() +'</DCISType>'; soapXML += '</DeliveryConfirmation>';       
                        }                
                    soapXML += '</PackageServiceOptions>';                                       
                    
                    if(Shipment.Additional_Handling__c != null && Shipment.Additional_Handling__c == 'Yes') soapXML += '<AdditionalHandling>'+ Shipment.Additional_Handling__c.escapeXml() +'</AdditionalHandling>';                            				soapXML += '</Package>'; 
                }    
                soapXML += '<ShipmentServiceOptions>'; 				if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) && deliveryConfirmation != null) { soapXML += '<DeliveryConfirmation>'; soapXML += '<DCISType>'+ deliveryConfirmation.escapeXml() +'</DCISType>'; soapXML += '</DeliveryConfirmation>';
                    }
                    if(Shipment.Carbon_Neutral__c != null && Shipment.Carbon_Neutral__c == 'Yes') soapXML += '<UPScarbonneutralIndicator>'+ Shipment.Carbon_Neutral__c.escapeXml() +'</UPScarbonneutralIndicator>';            				if(saturdayDelivery != null) soapXML += '<SaturdayDelivery>'+ saturdayDelivery.escapeXml() +'</SaturdayDelivery>';                                        					soapXML += '</ShipmentServiceOptions>'; 				soapXML += '</Shipment>';					soapXML += '</RatingServiceSelectionRequest>';

            HttpRequest req = new HttpRequest(); Http h = new Http(); req.setBody(soapXML); req.setMethod('POST'); String myEndPoint = endpoint + '/ups.app/xml/Rate'; req.setEndpoint(myEndPoint);				HttpResponse res = h.send(req); request_1 = soapXmL; response_1 = res.getBody(); resStatus = res.getStatus();			if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'ResponseStatusDescription'); if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader reader = res.getXmlStreamReader(); readXMLResponseRateTransitDetails(reader,'RatedShipment'); Result = 'Available UPS Services For The Selected Location'; time_in_cost_tab = true; } else { XmlStreamReader reader3 = res.getXmlStreamReader(); String msg1 = readXMLResponse(reader3, 'ErrorDescription'); if(msg1 != Null && msg1 != '') Result = 'Service & Rate Request Is Not Available : ' + msg1; else Result = 'Request To Service & Rate Shipment Cannot Be Processed'; } } else Result = 'Result not available'; } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }			return null;
    }
    public void readXMLResponseRateTransitDetails(XmlStreamReader reader, String sxmltag) {					try {					rateWrapper rw; rateWrapperList = new List<rateWrapper>();				while(reader.hasNext()) {				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) {  rw = new rateWrapper();				while(reader.hasNext()) {
                        //ups service
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Service') { reader.next();				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Code') { reader.next(); rw.ServiceCode = reader.getText(); }

                            List <UPS_Service_Codes__c> serviceCodes = [select Id, Name, Service__c, ServiceCode__c, Service_Code_With_Trade_Mark__c, Service_Asia_International__c, Service_Canada_Domestic__c, Service_USA_Domestic__c, 
                                                                        Service_Canada_International__c, Service_Europe__c, Service_Mexico_Domestic__c, Service_Mexico_International__c from UPS_Service_Codes__c limit 22];
                            if(originCountryCode == 'CA' && destinationCountryCode == 'CA') {  for(Integer i=0;i<serviceCodes.size();i++) if(rw.ServiceCode == serviceCodes[i].ServiceCode__c) { rw.ServiceManual = serviceCodes[i].Service_Canada_Domestic__c; }
                                
                            } else if(originCountryCode == 'CA' && destinationCountryCode != 'CA') {                                 for(Integer i=0;i<serviceCodes.size();i++) if(rw.ServiceCode == serviceCodes[i].ServiceCode__c) { rw.ServiceManual = serviceCodes[i].Service_Canada_International__c; }  			} else if(originCountryCode == 'MX' && destinationCountryCode == 'MX') {             for(Integer i=0;i<serviceCodes.size();i++) if(rw.ServiceCode == serviceCodes[i].ServiceCode__c) { rw.ServiceManual = serviceCodes[i].Service_Mexico_Domestic__c; }  			} else if(originCountryCode == 'MX' && destinationCountryCode != 'MX') {   for(Integer i=0;i<serviceCodes.size();i++)if(rw.ServiceCode == serviceCodes[i].ServiceCode__c) { rw.ServiceManual = serviceCodes[i].Service_Mexico_International__c; }                                                       				} else { for(Integer i=0;i<serviceCodes.size();i++) if(rw.ServiceCode == serviceCodes[i].ServiceCode__c) { rw.ServiceManual = serviceCodes[i].Service_Code_With_Trade_Mark__c; } }
                        }
                        // transport charges
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TransportationCharges') {  reader.next();				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 				if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();			if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();						if(reader.hasText() && rw.TransportationCharges == '') rw.TransportationCharges = reader.getText(); }          
                        }
                        // services charges
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceOptionsCharges') { reader.next();			if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 				if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 				if(reader.hasText() && rw.ServiceOptionsCharges == '') rw.ServiceOptionsCharges = reader.getText(); } 
                        }
                        // total charges
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalCharges') { reader.next();				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 				if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 				if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText() +' '+ rw.currencyCode; }
                        }
                        // days to deliver
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'GuaranteedDaysToDelivery') { reader.next();					if(reader.hasText()) {  rw.GuaranteedDaysToDelivery = reader.getText(); 				rw.DeliveryDate = Shipment.Shipment_Date__c + Integer.valueof(rw.GuaranteedDaysToDelivery); } else { rw.GuaranteedDaysToDelivery = '-'; rw.DeliveryDateS = '-'; }
                        }                        
                        // time to deliver           
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ScheduledDeliveryTime') { reader.next();                        				if(reader.hasText()) { rw.ScheduledDeliveryTime = reader.getText(); } else { rw.ScheduledDeliveryTime = '-'; }
                        }          
                        // negotiated charges                                       
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'NegotiatedRates') { reader.next(); reader.next(); reader.next();				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 				if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();  				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();  if(reader.hasText() && rw.negotiatedCharges == '') rw.negotiatedCharges = reader.getText(); }    
                        }                        
                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();				} rateWrapperList.add(rw);				} reader.next(); }  } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      process shipment & generate UPS label API request.
    */ 
    public PageReference Shipping_Request() {				try { 				address_val_tab = false;				time_in_cost_tab = false;				pickup_pendingstatus_Tab = false; 				pickup_servicecenter_Tab = false;         
            
            if(errorMsg != '') { return null; }					resStatus = Result = '';				if(Shipment.Status__c == 'Shipped' || Shipment.Status__c == 'Delivered') { errorMsg1 = 'This Package Has Already Been ' + Shipment.Status__c; } 				else if(fromAddress.Postal_Code__c == null || fromAddress.Postal_Code__c == '') { errorMsg1 = 'From Address Postal Code Unavailable'; } 				else if(fromAddress.Country__c == null || fromAddress.Country__c == '') { errorMsg1 = 'From Address Country Unavailable'; } 				else if(shippingAddress.Postal_Code__c == null || shippingAddress.Postal_Code__c == '') { errorMsg1 = 'Shipping Address Postal Code Unavailable'; } 					else if(shippingAddress.Country__c == null || shippingAddress.Country__c == '') { errorMsg1 = 'Shipping Address Country Unavailable'; } else if(Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment Date Unavailable'; } else if(service_code == null || service_code == '') { errorMsg1 = 'Service Is Unavailable, Please Select At Least One Service From Shipping Service And Cost' ; } else if(Shipment.International_Forms__c == 'Packing List' && (Shipment.Product_Unit_Code__c == null || Shipment.Product_Unit_Code__c == '')) errorMsg1 = 'Product Unit Code Unavailable'; else if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'CA' && destinationCountryCode == 'US')) && Shipment.COD__c == 'Yes' ) errorMsg1 = 'Package Level COD Is Not Allowed For Selected Locations'; else if(Shipment.COD__c == 'Yes' && (Shipment.Delivery_Confirmation__c != null && Shipment.Delivery_Confirmation__c != '')) errorMsg1 = 'COD And Delivery Confirmation Cannot Co-Exists On A Single package'; else if((Shipment.Return_Service__c != null && Shipment.Return_Service__c != '') && (Shipment.Verbal_Confirmation__c == 'Yes')) errorMsg1 = 'Verbal Confirmation Cannot Be Combined With Return Service Option'; else if(Shipment.Return_Service__c != null && Shipment.Delivery_Confirmation__c != null) errorMsg1 = 'Delivery Confirmation And Return Service Cannot Co-Exists On A Single package'; else if(Shipment.Return_Service__c != null && Shipment.COD__c == 'Yes') errorMsg1 = 'COD And Return Service Cannot Co-Exists On A Single package'; else if(Shipment.COD__c == 'Yes' && (Shipment.Delivery_Confirmation__c != null && Shipment.Delivery_Confirmation__c != '') && (Shipment.Return_Service__c != null && Shipment.Return_Service__c != '')) errorMsg1 = 'Delivery Confirmation / COD option cannot be combined with the Return Services option'; else if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) && Shipment.Delivery_Confirmation__c == 'No Signature') errorMsg1 = 'This Delivery Confirmation Type Is Not Allowed For Selected Location'; else if((Shipment.Saturday_Delivery__c == 'Yes') && (!(service_code == '01' || service_code == '02' || service_code == '14' || service_code == '54' || service_code == '07'))) errorMsg1 = 'Saturday Delivery Is Not Allowed For This Service'; else {  errorMsg1 = ''; Date dt = Shipment.Shipment_Date__c; String shipmentDate, saturdayDelivery, DeliveryConfirmation; if(Shipment.Saturday_Delivery__c == 'Yes') saturdayDelivery = '1'; else if(Shipment.Saturday_Delivery__c == 'No') saturdayDelivery = '0'; if((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) { if(Shipment.Delivery_Confirmation__c == 'No Signature') { DeliveryConfirmation = '1'; } else if(Shipment.Delivery_Confirmation__c == 'Signature Required') { DeliveryConfirmation = '2'; } else if(Shipment.Delivery_Confirmation__c == 'Adult Signature Required') { DeliveryConfirmation = '3'; } } else if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US'))) { if(Shipment.Delivery_Confirmation__c == 'Signature Required') { DeliveryConfirmation = '1'; } else if(Shipment.Delivery_Confirmation__c == 'Adult Signature Required') { DeliveryConfirmation = '2'; } } shipmentDate = dt.Year() + '' + dt.Month() + '' + dt.Day(); Process_Shipment_Request_Reply(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), service_code, DeliveryConfirmation, saturdayDelivery, shipmentDate); } } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return null;
    }
    //public pageReference Process_Shipment_Request_Reply(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, String serviceCode, String DeliveryConfirmation, String saturdayDelivery, String shipmentDate) {
    public pageReference Process_Shipment_Request_Reply(String fromAddress1, String toAddress1, String packList1, String serviceCode, String DeliveryConfirmation, String saturdayDelivery, String shipmentDate) {			try {				Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);				Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);					List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);				string soapXML = '<?xml version="1.0"?>';				soapXML += '<AccessRequest xml:lang="en-US">';				soapXML += '<AccessLicenseNumber>'+ Key.escapeXml() +'</AccessLicenseNumber>';				soapXML += '<UserId>'+ userName.escapeXml() +'</UserId>';			soapXML += '<Password>'+ password.escapeXml() +'</Password>';				soapXML += '</AccessRequest>';
            
            soapXML += '<?xml version="1.0" ?>';				soapXML += '<ShipmentConfirmRequest>';					soapXML += '<Request>';					soapXML += '<RequestAction>ShipConfirm</RequestAction>';					soapXML += '<RequestOption>nonvalidate</RequestOption>';				soapXML += '</Request>';
            
            soapXML += '<Shipment>';			if(shipment.Description__c != null) soapXML += '<Description>'+ shipment.Description__c.escapeXml() +'</Description>'; 				if(upsCredentials != null && upsCredentials.size() > 0) {					soapXML += '<Shipper>';					soapXML += '<Name>'+ upsCredentials[0].Shipper_Company_Name__c.escapeXml() +'</Name>';					soapXML += '<AttentionName>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</AttentionName>';					soapXML += '<PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</PhoneNumber>';                					soapXML += '<ShipperNumber>'+ upsAccountNumber.escapeXml() +'</ShipperNumber>';					soapXML += '<Address>';						soapXML += '<AddressLine1>'+ upsCredentials[0].Shipper_Street__c.escapeXml() +'</AddressLine1>';				soapXML += '<City>'+ upsCredentials[0].Shipper_City__c.escapeXml() +'</City>';				soapXML += '<StateProvinceCode>'+ shipperProvinceCode.escapeXml() +'</StateProvinceCode>';				soapXML += '<PostalCode>'+ upsCredentials[0].Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';				soapXML += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';				soapXML += '</Address>';					soapXML += '</Shipper>';                                    
                }
                if(toAddress != null) {				soapXML += '<ShipTo>';
                    
                    
                    if(packList[0].Logistic__r.Sales_Order__r.Contact__r.Company__c != null) soapXML += '<CompanyName>'+ packList[0].Logistic__r.Sales_Order__r.Contact__r.Company__c.escapeXml() +'</CompanyName>';				else if(packList[0].Logistic__r.ERP7__Order_S__r.Contact__r.Company__c != null) soapXML += '<CompanyName>'+ packList[0].Logistic__r.ERP7__Order_S__r.Contact__r.Company__c.escapeXml() +'</CompanyName>';				if(packList[0].Logistic__r.Sales_Order__r.Contact__r.Name != null) soapXML += '<AttentionName>'+ packList[0].Logistic__r.Sales_Order__r.Contact__r.Name.escapeXml() +'</AttentionName>';				else if(packList[0].Logistic__r.ERP7__Order_S__r.Contact__r.Name != null) soapXML += '<AttentionName>'+ packList[0].Logistic__r.ERP7__Order_S__r.Contact__r.Name.escapeXml() +'</AttentionName>';					if(packList[0].Logistic__r.Sales_Order__r.Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ packList[0].Logistic__r.Sales_Order__r.Contact__r.Phone.escapeXml() +'</PhoneNumber>';				else if(packList[0].Logistic__r.ERP7__Order_S__r.Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ packList[0].Logistic__r.ERP7__Order_S__r.Contact__r.Phone.escapeXml() +'</PhoneNumber>';
                                        
                    /*
                    if(toAddress.Contact__r.Company__c != null) soapXML += '<CompanyName>'+ toAddress.Contact__r.Company__c.escapeXml() +'</CompanyName>';
                    soapXML += '<AttentionName>'+ toAddress.Contact__r.Name.escapeXml() +'</AttentionName>';            
                    if(toAddress.Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ toAddress.Contact__r.Phone.escapeXml() +'</PhoneNumber>'; 
                    */
                    soapXML += '<Address>';					soapXML += '<AddressLine1>'+ destinationStreet.escapeXml() +'</AddressLine1>';					soapXML += '<City>'+ toAddress.City__c.escapeXml() +'</City>';							soapXML += '<StateProvinceCode>'+ destinationProvinceCode.escapeXml() +'</StateProvinceCode>';					soapXML += '<PostalCode>'+ toAddress.Postal_Code__c.escapeXml() +'</PostalCode>';			soapXML += '<CountryCode>'+ destinationCountryCode.escapeXml() +'</CountryCode>';					if(toShipmentType != null && toShipmentType) soapXML += '<ResidentialAddress>Residential</ResidentialAddress>';            				else soapXML += '<ResidentialAddress>Commercial</ResidentialAddress>'; 					soapXML += '</Address>';				soapXML += '</ShipTo>';
                }
                if(fromAddress != null) {				soapXML += '<ShipFrom>';				if(fromAddress.Contact__r.Company__c != null) soapXML += '<CompanyName>'+ fromAddress.Contact__r.Company__c.escapeXml() +'</CompanyName>';				soapXML += '<AttentionName>'+ fromAddress.Contact__r.Name.escapeXml() +'</AttentionName>';			if(fromAddress.Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ fromAddress.Contact__r.Phone.escapeXml() +'</PhoneNumber>';			soapXML += '<Address>';					soapXML += '<AddressLine1>'+ originStreet.escapeXml() +'</AddressLine1>';				soapXML += '<City>'+ fromAddress.City__c.escapeXml() +'</City>';				if(originProvinceCode != null) soapXML += '<StateProvinceCode>'+ originProvinceCode.escapeXml() +'</StateProvinceCode>';			soapXML += '<PostalCode>'+ fromAddress.Postal_Code__c.escapeXml() +'</PostalCode>';					soapXML += '<CountryCode>'+ originCountryCode.escapeXml() +'</CountryCode>';				if(fromShipmentType != null && fromShipmentType) soapXML += '<ResidentialAddress>Residential</ResidentialAddress>';            			else soapXML += '<ResidentialAddress>Commercial</ResidentialAddress>';					soapXML += '</Address>';					soapXML += '</ShipFrom>';
                }
                soapXml += '<RateInformation>'; soapXml += '<NegotiatedRatesIndicator>Y</NegotiatedRatesIndicator>'; soapXml += '</RateInformation>';				soapXML += '<Service>'; soapXML += '<Code>'+ serviceCode.escapeXml() +'</Code>'; soapXML += '</Service>'; soapXML += '<PaymentInformation>'; soapXML += '<Prepaid>'; soapXML += '<BillShipper>';				soapXML += '<PaymentType>SENDER</PaymentType>'; soapXML += '<AccountNumber>'+ upsAccountNumber.escapeXml() +'</AccountNumber>'; soapXML += '</BillShipper>'; soapXML += '</Prepaid>'; soapXML += '</PaymentInformation>';
                                
                String weightUnit; Integer weightValue1 = 0; Integer declaredValue1 = 0; List<QV_Notification__c> notificationType;					if(Shipment.QV_Notification__c != null) notificationType = [select Id, Name, Notification_Code__c, Notification_Description__c from QV_Notification__c where Notification_Description__c =: Shipment.QV_Notification__c limit 1];				for(Package__c p : packList) { 					soapXML += '<Package>';					if(p.Description__c != null) soapXML += '<Description>'+ p.Description__c.escapeXml() +'</Description>';					soapXML += '<PackagingType>';							soapXML += '<Code>'+ packageTypeMap.get('Package').Package_Code__c.escapeXml() +'</Code>';					soapXML += '</PackagingType>';
                        
                        soapXML += '<PackageWeight>';				soapXML += '<UnitOfMeasurement>'; soapXML += '<Code>'+ p.Weight_Unit__c.escapeXml() +'</Code>'; soapXML += '</UnitOfMeasurement>';				soapXML += '<Weight>'+ p.Weight__c +'</Weight>';				soapXML += '</PackageWeight>';
                        
                        soapXML += '<Dimensions>';				soapXML += '<UnitOfMeasurement>';				if(p.Weight_Unit__c == 'KGS') soapXMl += '<Code>CM</Code>';					else soapXMl += '<Code>IN</Code>'; soapXML += '</UnitOfMeasurement>';				soapXML += '<Length>'+ p.Length__c +'</Length>'; soapXML += '<Width>'+ p.Width__c +'</Width>'; soapXML += '<Height>'+ p.Height__c +'</Height>'; soapXML += '</Dimensions>';
                        
                        soapXML += '<PackageServiceOptions>';				soapXML += '<InsuredValue>'; soapXML += '<MonetaryValue>'+ p.Declared_Value__c +'</MonetaryValue>';  soapXML += '</InsuredValue>';                   
                                                        
                            if(Shipment.QV_Notification__c != null && notificationType != null) {  					soapXML += '<Notification>'; soapXML += '<NotificationCode>'+ notificationType[0].Notification_Code__c.escapeXml() +'</NotificationCode>'; 				soapXML += '<EMailMessage>';				if(customerEmail != null) soapXML += '<EMailAddress>'+ customerEmail.escapeXml() +'</EMailAddress>';			if(upsCredentials != null) soapXML += '<FromEMailAddress>'+ upsCredentials[0].Shipper_Email__c.escapeXml() +'</FromEMailAddress>';					soapXML += '</EMailMessage>'; soapXML += '</Notification>';
                            }
                            if(Shipment.Dry_Ice__c != null && Shipment.Dry_Ice__c == 'Yes') {				soapXML += '<DryIce>'; soapXML += '<RegulationSet>IATA</RegulationSet>'; soapXML += '<DryIceWeight>'; soapXML += '<UnitOfMeasurement>'; soapXML += '<Code>'+ p.Weight_Unit__c.escapeXml() +'</Code>'; soapXML += '</UnitOfMeasurement>'; soapXML += '<Weight>'+ p.Weight__c +'</Weight>'; soapXML += '</DryIceWeight>'; soapXML += '</DryIce>';
                            }
                            if(serviceCode == '14' && Shipment.Verbal_Confirmation__c == 'Yes') {               			soapXML += '<VerbalConfirmation>'; soapXML += '<Name>'+ upsCredentials[0].Shipper_Name__c.escapeXml() +'</Name>'; soapXML += '<PhoneNumber>'+ upsCredentials[0].Shipper_Phone_Number__c.escapeXml() +'</PhoneNumber>'; soapXML += '</VerbalConfirmation>';
                            }
                            if(((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) && (DeliveryConfirmation != null)) {				soapXML += '<DeliveryConfirmation>'; soapXML += '<DCISType>'+ DeliveryConfirmation.escapeXml() +'</DCISType>'; soapXML += '</DeliveryConfirmation>';       
                            }                
                        soapXML += '</PackageServiceOptions>';			if(Shipment.Additional_Handling__c != null && Shipment.Additional_Handling__c == 'Yes' && serviceCode != Fservice_code) soapXML += '<AdditionalHandling>'+ Shipment.Additional_Handling__c.escapeXml() +'</AdditionalHandling>';                 			soapXML += '</Package>';
                        
                    if(p.Weight_Unit__c != null) weightUnit = p.Weight_Unit__c;				if(p.Weight__c != null) weightValue1 += Integer.valueof(p.Weight__c);                 				if(p.Declared_Value__c != null) declaredValue1 += Integer.valueof(p.Declared_Value__c);                
                }
                if((originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'CA')) {					soapXML += '<InvoiceLineTotal>'; soapXML += '<CurrencyCode>USD</CurrencyCode>'; soapXML += '<MonetaryValue>'+ declaredValue1 +'</MonetaryValue>'; soapXML += '</InvoiceLineTotal>';
                }            
                if(packList != null && packList.size() > 0) soapXML += '<NumOfPiecesInShipment>'+ packList.size() +'</NumOfPiecesInShipment>';						soapXML += '<ShipmentServiceOptions>';					if(!((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'US' && destinationCountryCode == 'PR') || (originCountryCode == 'PR' && destinationCountryCode == 'US')) && (DeliveryConfirmation != null)) {					soapXML += '<DeliveryConfirmation>'; soapXML += '<DCISType>'+ DeliveryConfirmation.escapeXml() +'</DCISType>'; soapXML += '</DeliveryConfirmation>';
                    }
                    /* if(((originCountryCode == 'US' && destinationCountryCode == 'US') || (originCountryCode == 'CA' && destinationCountryCode == 'CA') || (originCountryCode == 'PR' && destinationCountryCode == 'PR') || (originCountryCode == 'CA' && destinationCountryCode == 'US')) && (optionalValues.get('cod') == 'Yes')) {             
                        soapXML += '<COD>';
                        soapXML += '<CODCode>3</CODCode>';
                        soapXML += '<CODFundsCode>9</CODFundsCode>';                
                        soapXML += '<CODAmount>';
                        if(Destination_CountryCode == 'CA') { soapXML += '<CurrencyCode>CAD</CurrencyCode>'; }
                        else if(Destination_CountryCode == 'US') { soapXML += '<CurrencyCode>USD</CurrencyCode>'; }
        
                        soapXML += '<MonetaryValue>'+ declaredValue +'</MonetaryValue>';
                        soapXML += '</CODAmount>';
                        soapXML += '</COD>';                              
                    }*/ 
                    List<Product_Unit_Code__c> productType;						List<International_Forms__c> internationalFormType;						if(Shipment.International_Forms__c != null) internationalFormType = [select Id, Name, International_Form_Code__c, International_Form_Description__c from International_Forms__c where International_Form_Description__c =: Shipment.International_Forms__c limit 1];                                                                      					if(Shipment.Product_Unit_Code__c != null) productType = [select Id, Name, Product_Code__c, Product_Description__c from Product_Unit_Code__c where Product_Description__c =: Shipment.Product_Unit_Code__c limit 1];                    					if(Shipment.International_Forms__c != null && internationalFormType != null) {			soapXML += '<InternationalForms>';				soapXML += '<FormType>'+ internationalFormType[0].International_Form_Code__c.escapeXml() +'</FormType>';
                            
                            // Form Type 07
                            if(Shipment.International_Forms__c == 'Customer Generated Form') {					soapXML += '<UserCreatedForm>'; 				soapXML += '<DocumentID></DocumentID>';						soapXML += '</UserCreatedForm>';
                            }
                            // Form Type 08
                            if(Shipment.International_Forms__c == 'Air Freight Packing List' || Shipment.International_Forms__c == 'Packing List') {					for(plWrapper plw: packListWrapper) { soapXML += '<Product>'; soapXML += '<Description>'+ plw.goodsDescription.escapeXml() +'</Description>'; soapXML += '<Unit>'; soapXML += '<Number></Number>'; soapXML += '<Value>'+ plw.declaredValue +'</Value>'; soapXML += '<UnitOfMeasurement>';  soapXML += '<Code>'+ productType[0].Product_Code__c.escapeXml() +'</Code>'; soapXML += '</UnitOfMeasurement>'; soapXML += '</Unit>'; soapXML += '<CommodityCode>'+ plw.commodityCode.escapeXml() +'</CommodityCode>'; if(Shipment.International_Forms__c == 'Packing List') { soapXML += '<PackingListInfo>'; soapXML += '<PackageAssociated>'; soapXML += '<PackageNumber>'+ plw.pl.Package__r.Name.escapeXml() +'</PackageNumber>'; soapXML += '<ProductAmount>'+ plw.declaredValue +'</ProductAmount>'; soapXML += '</PackageAssociated>'; soapXML += '</PackingListInfo>'; } soapXML += '</Product>'; }
                            }
                            // Form Type 01
                            String currCode;
                            if(Shipment.International_Forms__c == 'Invoice') {                            
                                for(plWrapper plw: packListWrapper) { soapXML += '<Product>'; soapXML += '<Description>'+ plw.goodsDescription.escapeXml() +'</Description>'; soapXML += '<Unit>'; soapXML += '<Number>'+ Integer.valueof(plw.pl.Quantity__c) +'</Number>'; soapXML += '<Value>'+ plw.declaredValue +'</Value>'; soapXML += '<UnitOfMeasurement>'; soapXML += '<Code>'+ productType[0].Product_Code__c.escapeXml() +'</Code>'; soapXML += '</UnitOfMeasurement>'; soapXML += '</Unit>'; soapXML += '<CommodityCode>'+ plw.commodityCode.escapeXml() +'</CommodityCode>'; soapXML += '<OriginCountryCode>'+ originCountryCode.escapeXml() +'</OriginCountryCode>'; soapXML += '</Product>'; currCode = getCurrencyIsoCode(plw.pl); }                                
                                DateTime dt = Shipment.Invoice_Date__c;
                                String invDate = dt.format('yyyyMMdd') ; //dt.Year() + '' + dt.Month() + '' + dt.Day();
                                List<Terms_Of_Shipment__c> termsOfShipmentList;
                                if(Shipment.Terms_Of_Shipment__c != null) termsOfShipmentList = [select Id, Name, Terms_Of_Shipment_Value__c, Terms_Of_Shipment_Code__c from Terms_Of_Shipment__c where Terms_Of_Shipment_Value__c =: Shipment.Terms_Of_Shipment__c Limit 1];
                                soapXML += '<InvoiceDate>'+ invDate +'</InvoiceDate>'; // invoice date
                                soapXML += '<InvoiceNumber>'+ Shipment.Invoice_Number__c.escapeXml() +'</InvoiceNumber>'; // invoice number
                                soapXML += '<PurchaseOrderNumber>'+ Shipment.Purchase_Order_Number__c.escapeXml() +'</PurchaseOrderNumber>'; // purchase order number
                                if(termsOfShipmentList != null) soapXML += '<TermsOfShipment>'+ termsOfShipmentList[0].Terms_Of_Shipment_Code__c.escapeXml() +'</TermsOfShipment>'; //terms of shipment
                                soapXML += '<ReasonForExport>'+ Shipment.Reason_For_Export__c.escapeXml() +'</ReasonForExport>'; // reason of export
                                soapXML += '<DeclarationStatement>'+ Shipment.Declaration_Statement__c.escapeXml() +'</DeclarationStatement>'; // declaration stmt
                                soapXML += '<CurrencyCode>'+ currCode.escapeXml() +'</CurrencyCode>';
                            }
                            // Form Type 09
                            if(Shipment.International_Forms__c == 'CN22 Forms') {					soapXML += '<CN22Form>'; 				soapXML += '<LabelSize>6</LabelSize>';				soapXML += '<PrintsPerPage>1</PrintsPerPage>';				soapXML += '<LabelPrintType>PDF</LabelPrintType>';				soapXML += '<CN22Type>2</CN22Type>';			if(packList != null && packList.size() > 0) soapXML += '<CN22OtherDescription>'+ packList[0].Description__c.escapeXml() +'</CN22OtherDescription>';
                                
                                for(plWrapper plw: packListWrapper) { soapXML += '<CN22Content>'; soapXML += '<CN22ContentQuantity>'+ plw.pl.Quantity__c +'</CN22ContentQuantity>'; soapXML += '<CN22ContentDescription>'+ plw.goodsDescription.escapeXml() +'</CN22ContentDescription>'; soapXML += '<CN22ContentWeight>'; soapXML += '<UnitOfMeasurement>'; soapXML += '<Code>'+ plw.pl.Package__r.Weight_Unit__c.escapeXml() +'</Code>'; soapXML += '</UnitOfMeasurement>'; soapXML += '<Weight>'+ plw.pl.Package__r.Weight__c +'</Weight>'; soapXML += '</CN22ContentWeight>'; soapXML += '<CN22ContentTotalValue>'+ plw.declaredValue +'</CN22ContentTotalValue>'; soapXML += '<CN22ContentCurrencyCode>'+ getCurrencyIsoCode(plw.pl).escapeXml() +'</CN22ContentCurrencyCode>'; soapXML += '<CN22ContentCountryOfOrigin>'+ originCountryCode.escapeXml() +'</CN22ContentCountryOfOrigin>'; soapXML += '</CN22Content>'; }				soapXML += '</CN22Form>';                       
                            }
                            // Form Type 10     
                            if(originCountryCode == 'CA' && destinationCountryCode == 'CA' && Shipment.International_Forms__c == 'UPS Premium Care') {    				soapXML += '<UPSPremiumCareForm>'; soapXML += '<ShipmentDate>'+ shipmentDate.escapeXml() +'</ShipmentDate>'; soapXML += '<PageSize>01</PageSize>'; soapXML += '<PrintType>PDF</PrintType>'; soapXML += '<NumOfCopies>02</NumOfCopies>'; soapXML += '<LanguageForUPSPremiumCare>'; soapXML += '<Language>ENG</Language>'; soapXML += '</LanguageForUPSPremiumCare>'; soapXML += '</UPSPremiumCareForm>';
                            }
                        soapXML += '</InternationalForms>';
                    } 
                    if(Shipment.Carbon_Neutral__c != null && Shipment.Carbon_Neutral__c == 'Yes') soapXML += '<UPScarbonneutralIndicator>'+ Shipment.Carbon_Neutral__c.escapeXml() +'</UPScarbonneutralIndicator>';            				if((saturdayDelivery == '1') && (serviceCode == '01' || serviceCode == '02' || serviceCode == '14' || serviceCode == '54' || serviceCode == '07')) soapXML += '<SaturdayDelivery>'+ saturdayDelivery.escapeXml() +'</SaturdayDelivery>';				soapXML += '</ShipmentServiceOptions>';
                
                List<Return_Services__c> returnType;						if(Shipment.Return_Service__c != null) returnType = [select Id, Name, Return_Service_Code__c, Return_Service_Description__c from Return_Services__c where Return_Service_Description__c =: Shipment.Return_Service__c limit 1];					if(Shipment.Return_Service__c != null && returnType != null) {  					soapXML += '<ReturnService>';					soapXML += '<Code>'+ returnType[0].Return_Service_Code__c.escapeXml() +'</Code>';				soapXML += '</ReturnService>';
                } 
            soapXML += '</Shipment>'; 
            
            soapXML += '<LabelSpecification>';            					soapXML += '<LabelPrintMethod>'; soapXML += '<Code>GIF</Code>'; soapXML += '</LabelPrintMethod>'; 						soapXML += '<HTTPUserAgent>Mozilla/4.5</HTTPUserAgent>';					soapXML += '<LabelStockSize>';					soapXML += '<Height>' + LabelHeight.escapeXml() + '</Height>';					soapXML += '<Width>' + LabelWidth.escapeXml() + '</Width>';				soapXML += '</LabelStockSize>';				soapXML += '<LabelImageFormat>'; soapXML += '<Code>GIF</Code>'; soapXML += '</LabelImageFormat>';					soapXML += '</LabelSpecification>';
            
            soapXML += '</ShipmentConfirmRequest>';
            
            
            HttpRequest req1 = new HttpRequest(); Http h1 = new Http(); req1.setBody(soapXML); req1.setMethod('POST'); String myEndPoint = endpoint + '/ups.app/xml/ShipConfirm'; req1.setEndpoint(myEndPoint);
            
            HttpResponse res1 = h1.send(req1);            					string shipment_digest = ''; request_1 = req1.getBody(); response_1 = res1.getBody(); resStatus = res1.getStatus();
            
            if(resStatus == 'OK') {					XmlStreamReader Response_reader1 = res1.getXmlStreamReader(); String Response_Msg = Digest_Reader(Response_reader1,'ResponseStatusDescription'); if(Response_Msg != null && Response_Msg == 'Success') { XmlStreamReader digest_reader = res1.getXmlStreamReader(); shipment_digest = Digest_Reader(digest_reader, 'ShipmentDigest'); } else { XmlStreamReader Response_reader2 = res1.getXmlStreamReader(); String Error_Msg = Digest_Reader(Response_reader2,'ErrorDescription'); Result = 'Request For Shipping Cannot be Processed : '+ Error_Msg; }

            } else Result = 'Result not available';
            
            /* ------  Code for Shipment Accept (For Getting label from UPS) ----------- */        
            string soapXML1 = '<?xml version="1.0" ?>';					soapXML1 += '<AccessRequest xml:lang="en-US">';					soapXML1 += '<AccessLicenseNumber>'+ Key.escapeXml() +'</AccessLicenseNumber>';					soapXML1 += '<UserId>'+ userName.escapeXml() +'</UserId>';					soapXML1 += '<Password>'+ password.escapeXml() +'</Password>';					soapXML1 += '</AccessRequest>';
            
            soapXML1 += '<?xml version="1.0" ?>';				soapXML1 += '<ShipmentAcceptRequest>';				soapXML1 += '<Request>';				soapXML1 += '<RequestAction>ShipAccept</RequestAction>';				soapXML1 += '</Request>';
                
                if(shipment_digest != '') soapXML1 += '<ShipmentDigest>'+ shipment_digest +'</ShipmentDigest>';				soapXML1 += '</ShipmentAcceptRequest>';
            
            HttpRequest req2 = new HttpRequest(); Http h2 = new Http(); req2.setBody(soapXML1);				req2.setMethod('POST'); String myEndPoint1 = endpoint + '/ups.app/xml/ShipAccept'; req2.setEndpoint(myEndPoint1);				HttpResponse res2 = h2.send(req2); resStatus = res2.getStatus(); List<String> trackingNoList = new List<String>(); shipmentImageLists = new List<String>();				String curr, total_amount, TrackingNumber, ShipmentNumber, shipmentImage ; curr = total_amount = TrackingNumber = ShipmentNumber = shipmentImage = '';
                        
           if(resStatus == 'OK') { XmlStreamReader reader1 = res2.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'ResponseStatusDescription'); if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader reader = res2.getXmlStreamReader(); while(reader.hasNext()) { if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalCharges') { reader.next(); if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); curr = reader.getText(); reader.next(); reader.next(); if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); total_amount = reader.getText(); break; } } } reader.next(); } if(total_amount != Null && total_amount != '') { XmlStreamReader readerShipmentNo = res2.getXmlStreamReader(); ShipmentNumber = readXMLResponse(readerShipmentNo, 'ShipmentIdentificationNumber'); XmlStreamReader readerImage = res2.getXmlStreamReader(); String labelImgs = ''; while(readerImage.hasNext()) { if(readerImage.getEventType() == XmlTag.START_ELEMENT && readerImage.getLocalName() == 'PackageResults') { while(readerImage.hasNext()) { if(readerImage.getEventType() == XmlTag.START_ELEMENT && readerImage.getLocalName() == 'TrackingNumber') { readerImage.next(); trackingNoList.add(readerImage.getText()); } if(readerImage.getEventType() == XmlTag.START_ELEMENT && readerImage.getLocalName() == 'GraphicImage') { String shipmentImages = ''; String labelImg = ''; while(readerImage.hasNext()) { if(readerImage.getEventType() == XmlTag.END_ELEMENT) { break; } else if(readerImage.getEventType() == XmlTag.CHARACTERS) { shipmentImages += readerImage.getText(); labelImg += readerImage.getText();  } readerImage.next(); } labelImgs = (labelImgs == '')? labelImg : (labelImgs + ';;;;' + labelImg); shipmentImageLists.add(shipmentImages); serializedList = 'ShippingLabel;;;;' + LabelHeight + ':' + LabelWidth + ';;;;' + labelImgs;  } if(readerImage.getEventType() == XmlTag.END_ELEMENT && readerImage.getLocalName() == 'PackageResults') break; else readerImage.next(); } } readerImage.next(); } Id RTID; RTID = Schema.SObjectType.ERP7__Shipment__c.getRecordTypeInfosByDeveloperName().get('UPS_Shipping').getRecordTypeId(); if(Schema.sObjectType.Shipment__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Active__c.isUpdateable()) { Shipment.Active__c = true; } if(Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Billing_Address__c.isUpdateable()) { Shipment.Billing_Address__c = toAddress.Id; } if(Schema.sObjectType.Shipment__c.fields.Customer__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer__c.isUpdateable() && Shipment.Customer__c == Null) Shipment.Customer__c = toAddress.Customer__c; if(Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Contact__c.isUpdateable()) { Shipment.Customer_Contact__c = toAddress.Contact__c; } if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { Shipment.Status__c = 'Shipped'; } if(Schema.sObjectType.Shipment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Shipment__c.fields.RecordTypeId.isUpdateable() && RTID != null) { Shipment.RecordTypeId = RTID; } if(Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Address__c.isUpdateable()) { Shipment.Shipping_Address__c = toAddress.Id; } if(recordIdMap.get('SO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'SO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = recordIdMap.get('SO'); } if(recordIdMap.get('Ord') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'SO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.ERP7__Order__c.isUpdateable()) Shipment.ERP7__Order__c = recordIdMap.get('Ord'); } if(recordIdMap.get('WO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'WO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Work_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Work_Order__c.isUpdateable()) Shipment.Work_Order__c = recordIdMap.get('WO'); } if(recordIdMap.get('PO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'PO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Purchase_Orders__c.isUpdateable()) Shipment.Purchase_Orders__c = recordIdMap.get('PO'); } if(recordIdMap.get('TO') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'TO-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Transfer_Order__c.isUpdateable()) Shipment.Transfer_Order__c = recordIdMap.get('TO'); } if(recordIdMap.get('SR') != null) { if(Schema.sObjectType.Shipment__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment__c.fields.Name.isUpdateable()) Shipment.Name = 'SR-Shipment' ; if(Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Return_Merchandise_Authorisation__c.isUpdateable()) Shipment.Return_Merchandise_Authorisation__c = recordIdMap.get('SR'); } if(recordIdMap.get('LO') != null) { if(Schema.sObjectType.Shipment__c.fields.Logistic__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Logistic__c.isUpdateable()) Shipment.Logistic__c = recordIdMap.get('LO'); if(packList != null && packList.size() > 0){ if(Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Sales_Order__c.isUpdateable()) Shipment.Sales_Order__c = packList[0].Logistic__r.Sales_Order__c; } } if(Schema.sObjectType.Shipment__c.fields.Shipment_Identification_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Identification_Number__c.isUpdateable()) { Shipment.Shipment_Identification_Number__c = ShipmentNumber; } String[] dts; Date deliveryDate; if(delivery_date != null && delivery_date != '') dts = delivery_date.split('-'); if(dts != null) deliveryDate = date.newinstance(Integer.valueOf(dts[0]), Integer.valueOf(dts[1]), Integer.valueOf(dts[2])); if(Schema.sObjectType.Shipment__c.fields.Shipment_Delivery_Date__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipment_Delivery_Date__c.isUpdateable()) { Shipment.Shipment_Delivery_Date__c = deliveryDate; } if(Schema.sObjectType.Shipment__c.fields.UPS_Services__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.UPS_Services__c.isUpdateable()) { Shipment.UPS_Services__c = service_description; } if(Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Shipping_Amount__c.isUpdateable()) { Shipment.Shipping_Amount__c = Decimal.valueOf(total_amount); } if(Schema.sObjectType.Shipment__C.fields.UPS_Service_Code__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.UPS_Service_Code__c.isUpdateable()) { shipment.UPS_Service_Code__c = serviceCode; } PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert Shipment; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } for(Integer i=0; i<packList.size(); i++) { if(Schema.sObjectType.Package__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Package__c.fields.Shipment__c.isUpdateable()) packList[i].Shipment__c = Shipment.Id; if(Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) packList[i].Status__c = Shipment.Status__c; if(trackingNoList.size() > i){if(Schema.sObjectType.Package__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Package__c.fields.Tracking_Number__c.isUpdateable()) packList[i].Tracking_Number__c = trackingNoList[i]; } } if(packList.size() > 0 && Schema.SObjectType.Package__c.isCreateable() && Schema.SObjectType.Package__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert packList; } else{ } List<attachment> attList = new List<attachment>(); if(shipmentImageLists.size() > 0) { for(Integer i=1; i<=shipmentImageLists.size(); i++) { attachment att = new attachment(); if(Schema.sObjectType.attachment.fields.Name.isCreateable() && Schema.sObjectType.attachment.fields.Name.isUpdateable()) att.Name = 'UPS_Label'; if(Schema.sObjectType.attachment.fields.parentId.isCreateable() && Schema.sObjectType.attachment.fields.parentId.isUpdateable()) att.parentId = Shipment.Id; if(Schema.sObjectType.attachment.fields.ContentType.isCreateable() && Schema.sObjectType.attachment.fields.ContentType.isUpdateable()) att.ContentType = 'image/gif'; if(Schema.sObjectType.attachment.fields.body.isCreateable() && Schema.sObjectType.attachment.fields.body.isUpdateable()) { att.body = EncodingUtil.base64Decode(shipmentImageLists[i-1]); } attList.add(att); } } if(attList.size() > 0 && Schema.sObjectType.Attachment.isCreateable() && Schema.sObjectType.Attachment.isUpdateable()){hasAccess=true; upsert attList;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; } if(Schema.sObjectType.Shipment__C.fields.Number_Of_Pieces_In_Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Number_Of_Pieces_In_Shipment__c.isUpdateable()) Shipment.Number_Of_Pieces_In_Shipment__c = String.valueof(packList.size()); if(Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isUpdateable()) { for(String s: trackingNoList) { if(Shipment.Tracking_Number__c == null) Shipment.Tracking_Number__c = s; else Shipment.Tracking_Number__c += ', ' + s; } } if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Shipment; } else{ } ERP7__Sales_Order__c SalesOrder = new ERP7__Sales_Order__c(); Order ord = new Order(); SalesOrder = Database.query('select Id, Name, ERP7__Tracking_Number__c from ERP7__Sales_Order__c where (Id =\'' + String.escapeSingleQuotes(packList[0].Logistic__r.Sales_Order__r.Id) + '\') Limit 1'); ord =  Database.query('select Id, Name, ERP7__Tracking_Number__c from Order where (Id =\'' + String.escapeSingleQuotes(packList[0].Logistic__r.ERP7__Order_S__r.Id) + '\') Limit 1'); if(SalesOrder != null){ if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Tracking_Number__c.isUpdateable()) { for(String s: trackingNoList) { if(SalesOrder.ERP7__Tracking_Number__c == null) SalesOrder.ERP7__Tracking_Number__c = s; else SalesOrder.ERP7__Tracking_Number__c += ', ' + s; } } if(Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; update SalesOrder; } } if(ord != null){ if(Schema.sObjectType.Order.fields.ERP7__Tracking_Number__c.isUpdateable()) { for(String s: trackingNoList) { if(ord.ERP7__Tracking_Number__c == null) ord.ERP7__Tracking_Number__c = s; else ord.ERP7__Tracking_Number__c += ', ' + s; } } if(Schema.sObjectType.Order.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; update ord; } } Shipment = Database.query('select ' + String.escapeSingleQuotes(shipmentFields) + ' from Shipment__c where (Id =\'' + String.escapeSingleQuotes(Shipment.Id) + '\') Limit 1'); attList = new List<attachment>(); shipmentImageLists = new List<String>(); Result = 'Package Shipped Successfully'; time_in_cost_tab = false; for(Integer i=1; i<=9; i++) { if(i==1 || i==7 || i==9){ showAndHideMap.put(i, false);} else {showAndHideMap.put(i, true);} } } } } 				else Result = 'Result Not Available';            						} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }					return null;
    }
    
    public PageReference CommercialInvoice() { return Page.CommercialInvoice; }
    
    /*
      cancel shipment API request.
    */
    public PageReference Cancel_Request() {				try { 				address_val_tab = false; 			time_in_cost_tab = false;				pickup_pendingstatus_Tab = false; 			pickup_servicecenter_Tab = false;
            
            if(errorMsg != '') { return null; }					resStatus = Result = '';				if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Unavailable'; } 					else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Request To Cancel Shipment Cannot Be Processed'; } 					else if(Shipment.Shipment_Date__c == null) { errorMsg1 = 'Shipment Date Unavailable'; } 					else if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Active Thus, Request To Cancel The Shipment Cannot Be Processed'; } 					else {  errorMsg1 = ''; /*Cancel_Shipment_Request(Shipment, packages);*/Cancel_Shipment_Request(JSON.serialize(Shipment), JSON.serialize(packages)); } } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }			return null;
    }
    //public PageReference Cancel_Shipment_Request(Shipment__c shipments, List<Package__c> packList) {   
    public PageReference Cancel_Shipment_Request(String shipments1, String packList1) {          				try {				Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);				List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);					string soapXML = '<?xml version="1.0"?>';				soapXML += '<AccessRequest xml:lang="en-US">';				soapXML += '<AccessLicenseNumber>'+ Key.escapeXml() +'</AccessLicenseNumber>';				soapXML += '<UserId>'+ userName.escapeXml() +'</UserId>';				soapXML += '<Password>'+ password.escapeXml() +'</Password>';					soapXML += '</AccessRequest>';
            
            soapXML += '<?xml version="1.0" encoding="UTF-8"?>';					soapXML += '<VoidShipmentRequest>';					soapXML += '<Request>';					soapXML += '<RequestAction>Void</RequestAction>';				soapXML += '<RequestOption/>';				soapXML += '</Request>';
            
            soapXML += '<ExpandedVoidShipment>';           				if(shipments != null && shipments.Shipment_Identification_Number__c != null) soapXML += '<ShipmentIdentificationNumber>'+ shipments.Shipment_Identification_Number__c.escapeXml() +'</ShipmentIdentificationNumber>';			soapXML += '</ExpandedVoidShipment>';					soapXML += '</VoidShipmentRequest>';
            
            HttpRequest req = new HttpRequest();					Http h = new Http();        
            
            req.setBody(soapXML);				req.setMethod('POST');				String myEndPoint = endpoint + '/ups.app/xml/Void';					req.setEndpoint(myEndPoint);            
            
            HttpResponse res = h.send(req);
            
            response_1 = res.getBody();				request_1 = req.getBody();				resStatus = res.getStatus();				if(resStatus == 'OK') {				XmlStreamReader reader1 = res.getXmlStreamReader();				String msg = readXMLResponse(reader1, 'ResponseStatusDescription');				if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {				if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Cancelled'; }				if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert shipments; } else{ }				if(packList != null && packList.size() > 0) { 					if(Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()){					for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } 
                        }
                        if(Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()){				PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; 				upsert packList; 
                        }else{ }
                    }else{ }
                    Shipment = new Shipment__c();  Result = 'Shipment Cancelled Successfully';				for(Integer i=1; i<=7; i++) { if(i==1) showAndHideMap.put(i, true); else showAndHideMap.put(i, false); } 
                } else {
                    XmlStreamReader message = res.getXmlStreamReader();				String mesage = readXMLResponse(message, 'ErrorDescription');					if(mesage != Null && mesage != '') Result = 'Request To Cancel Shipment Cannot Be Processed : ' + mesage;				else Result = 'Request To Cancel Shipment Cannot Be Processed';
                }
            } else Result = 'Result Not Available';           			} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return null;
    }
    
    /*
      Pickup rate API request.
    */
    public PageReference PickupRate() {					try {				address_val_tab = false;				time_in_cost_tab = false;				pickup_pendingstatus_Tab = false; 				pickup_servicecenter_Tab = false;
            
            if(errorMsg != '') { return null; }					resStatus = Result = '';					if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Already Active For This Package'; } 						else if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 				else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Shipment Status Must Be shipped To Process, Pickup Rate Request'; } 					else if(Shipment.Package_Ready_Time__c == null) { errorMsg1 = 'Package Ready Time Unavailable'; } 					else if(Shipment.Customer_Close_Time__c == null) { errorMsg1 = 'Customer Close Time Unavailable'; } 				else if(Shipment.Package_Ready_Time__c < System.Now()) { errorMsg1 = 'Package Ready Time Invalid'; } 				else if(Shipment.Customer_Close_Time__c < System.Now()) { errorMsg1 = 'Customer Close Time Invalid'; } 				else if(Shipment.Customer_Close_Time__c.year() != Shipment.Package_Ready_Time__c.year() || Shipment.Customer_Close_Time__c.month() != Shipment.Package_Ready_Time__c							.month() || Shipment.Customer_Close_Time__c.day() != Shipment.Package_Ready_Time__c.day()) {				errorMsg1 = 'Package Ready Time Date And Customer Close Time Date Must Be Same'; }					else { errorMsg1 = '';                        					DateTime PRT = Shipment.Package_Ready_Time__c;				DateTime CCT = Shipment.Customer_Close_Time__c;				String dispatchDate = PRT.format('yyyyMMdd');				String PackageReadyTime = PRT.format('HHmm');				String CustomerCloseTime = CCT.format('HHmm');				Pickup_Rate_Request(JSON.serialize(fromAddress), dispatchDate, PackageReadyTime, CustomerCloseTime); }						} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return null;
    }
    public PageReference Pickup_Rate_Request(String fromAddress1, String dispatchDate, String PackageReadyTime, String CustomerCloseTime) {        				try {   				Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);							String soapXML = System.label.upsHandler1;				soapXML += '<SOAP-ENV:Header>';					soapXML += '<ns3:UPSSecurity>';
            
            soapXML += '<ns3:UsernameToken>';				soapXML += '<ns3:Username>'+ userName.escapeXml() +'</ns3:Username>';				soapXML += '<ns3:Password>'+ password.escapeXml() +'</ns3:Password>';					soapXML += '</ns3:UsernameToken>';
            
            soapXML += '<ns3:ServiceAccessToken>';					soapXML += '<ns3:AccessLicenseNumber>'+ Key.escapeXml() +'</ns3:AccessLicenseNumber>';				soapXML += '</ns3:ServiceAccessToken>';
            
            soapXML += '</ns3:UPSSecurity>';				soapXML += '</SOAP-ENV:Header>';				soapXML += '<SOAP-ENV:Body>';					soapXML += '<ns2:PickupRateRequest>';				soapXML += '<ns1:Request/>';				if(fromAddress != null) {					soapXML += '<ns2:PickupAddress>';						if(fromAddress.Contact__r.Company__c != null) soapXML += '<ns2:CompanyName>'+ fromAddress.Contact__r.Company__c.escapeXml() +'</ns2:CompanyName>';					if(fromAddress.Contact__r != null) soapXML += '<ns2:ContactName>'+ fromAddress.Contact__r.Name.escapeXml() +'</ns2:ContactName>';				soapXML += '<ns2:AddressLine>'+ originStreet.escapeXml() +'</ns2:AddressLine>';					soapXML += '<ns2:City>'+ fromAddress.City__c.escapeXml() +'</ns2:City>';				if(originProvinceCode != null) soapXML += '<ns2:StateProvince>'+ originProvinceCode.escapeXml() +'</ns2:StateProvince>';				soapXML += '<ns2:PostalCode>'+ fromAddress.Postal_Code__c.escapeXml() +'</ns2:PostalCode>';					soapXML += '<ns2:CountryCode>'+ originCountryCode.escapeXml() +'</ns2:CountryCode>';					soapXML += '<ns2:ResidentialIndicator>N</ns2:ResidentialIndicator>';								soapXML += '</ns2:PickupAddress>'; 
                    }
                    soapXML += '<ns2:AlternateAddressIndicator>N</ns2:AlternateAddressIndicator>';				soapXML += '<ns2:ServiceDateOption>03</ns2:ServiceDateOption>';
                    
                    soapXML += '<ns2:PickupDateInfo>';					soapXML += '<ns2:CloseTime>'+ CustomerCloseTime.escapeXml() +'</ns2:CloseTime>';					soapXML += '<ns2:ReadyTime>'+ PackageReadyTime.escapeXml() +'</ns2:ReadyTime>';						soapXML += '<ns2:PickupDate>'+ dispatchDate.escapeXml() +'</ns2:PickupDate>';					soapXML += '</ns2:PickupDateInfo>';                           				soapXML += '</ns2:PickupRateRequest>';
            
            soapXML += '</SOAP-ENV:Body>';					soapXML += '</SOAP-ENV:Envelope>';
            
            Http h = new Http();				HttpRequest req = new HttpRequest();
                    
            req.setBody(soapXML);				req.setMethod('POST');					String myEndPoint = endpoint + '/webservices/Pickup';					req.setEndpoint(myEndPoint);					req.setHeader('Content-length', '175');						req.setHeader('Content-Type', 'charset=utf-8');					req.setHeader('SOAPAction', '');       
                    
            HttpResponse res = h.send(req);
            
            String currency_code = '';				String pickup_amount = '';					request_1 = req.getBody();            				response_1 = res.getBody();					resStatus = res.getStatus();					if(resStatus == 'OK') {						XmlStreamReader reader1 = res.getXmlStreamReader();						String msg = readXMLResponse(reader1, 'Description');					if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {							XmlStreamReader reader = res.getXmlStreamReader();						while(reader.hasNext()) {							if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'RateResult') {					reader.next(); reader.next(); reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 				currency_code = reader.getText();					if(originCountryCode.escapeXml() == 'US' && destinationCountryCode.escapeXml() == 'US') { for(Integer i=0;i<44;i++) { reader.next(); } } 				else { for(Integer i=0;i<30;i++) { reader.next(); } }						if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'GrandTotalOfAllCharge') { reader.next(); 					pickup_amount = reader.getText(); break; }
                            }
                        } reader.next();				} Result = 'Total Net Charge To Pickup This Package Is : ' + pickup_amount + ' ' + currency_code;
                    
                } else {
                    XmlStreamReader reader3 = res.getXmlStreamReader();				String msg1 = readXMLResponse(reader3, 'Description');					if (msg1 != Null && msg1 != '') Result = 'Pickup Rate Is Not Available : ' + msg1;					else Result = 'Request To Pickup Rate Cannot Be Processed';
                }
            } else Result = 'Result not available';        				} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }					return null;
    }
    
    /*
      Create pickup API request.
    */    
    public PageReference CreatePickup() {					try {				address_val_tab = false;				time_in_cost_tab = false;					pickup_pendingstatus_Tab = false; 					pickup_servicecenter_Tab = false;
            
            if(errorMsg != '') { return null; }						resStatus = Result = '';							if(Shipment.Pickup_Requested__c == true) { errorMsg1 = 'Shipment Pickup Is Already Active For This Package'; } 							else if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 							else if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Shipment Status Must Be Shipped To Process, Create Pickup Request'; } 						else if(Shipment.Package_Ready_Time__c == null) { errorMsg1 = 'Package Ready Time Unavailable'; } 						else if(Shipment.Customer_Close_Time__c == null) { errorMsg1 = 'Customer Close Time Unavailable'; } 					else if(Shipment.Package_Ready_Time__c < System.Now()) { errorMsg1 = 'Package Ready Time Invalid'; } 					else if(Shipment.Customer_Close_Time__c < System.Now()) { errorMsg1 = 'Customer Close Time Invalid'; } 						else if(Shipment.Customer_Close_Time__c.year() != Shipment.Package_Ready_Time__c.year() || Shipment.Customer_Close_Time__c.month() != Shipment.Package_Ready_Time__c				.month() || Shipment.Customer_Close_Time__c.day() != Shipment.Package_Ready_Time__c.day()) {				errorMsg1 = 'Package Ready Time Date And Customer Close Time Date Must Be Same'; }				else {  errorMsg1 = ''; String contCode;					DateTime PRT = Shipment.Package_Ready_Time__c;							DateTime CCT = Shipment.Customer_Close_Time__c;						String dispatchDate = PRT.format('yyyyMMdd');					String PackageReadyTime = PRT.format('HHmm');					String CustomerCloseTime = CCT.format('HHmm');                  					String serviceCode = '0' + Shipment.UPS_Service_Code__c;
                                                   
                    if(Shipment.UPS_Service_Code__c == Fservice_code) { contCode = '03';                               
                        /*CreatePickupFreightRequest(fromAddress, shippingAddress, packages, shipment, dispatchDate, contCode, PackageReadyTime, CustomerCloseTime);*/
                          CreatePickupFreightRequest(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), JSON.serialize(shipment), dispatchDate, contCode, PackageReadyTime, CustomerCloseTime);				} else { contCode = '01';
                        /*CreatePickupRequest(fromAddress, shippingAddress, packages, shipment, dispatchDate, contCode, PackageReadyTime, CustomerCloseTime);*/
                            CreatePickupRequest(JSON.serialize(fromAddress), JSON.serialize(shippingAddress), JSON.serialize(packages), JSON.serialize(shipment), dispatchDate, contCode, PackageReadyTime, CustomerCloseTime);
                           }
            }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return null;
    }
    //public PageReference CreatePickupRequest(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, Shipment__c shipments, String dispatchDate, String contCode, String PackageReadyTime, String CustomerCloseTime) {
    public PageReference CreatePickupRequest(String fromAddress1, String toAddress1, String packList1, String shipments1, String dispatchDate, String contCode, String PackageReadyTime, String CustomerCloseTime) {				try {				Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);					Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);					Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);					List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);					String soapXML = System.label.upsHandler1;					soapXML += '<SOAP-ENV:Header>';					soapXML += '<ns3:UPSSecurity>';
            
            soapXML += '<ns3:UsernameToken>';				soapXML += '<ns3:Username>'+ userName.escapeXml() +'</ns3:Username>';					soapXML += '<ns3:Password>'+ password.escapeXml() +'</ns3:Password>';					soapXML += '</ns3:UsernameToken>';
            
            soapXML += '<ns3:ServiceAccessToken>';				soapXML += '<ns3:AccessLicenseNumber>'+ Key.escapeXml() +'</ns3:AccessLicenseNumber>';					soapXML += '</ns3:ServiceAccessToken>';
            
            soapXML += '</ns3:UPSSecurity>';				soapXML += '</SOAP-ENV:Header>';				soapXML += '<SOAP-ENV:Body>';					soapXML += '<ns2:PickupCreationRequest>';						soapXML += '<ns1:Request/>';					soapXML += '<ns2:RatePickupIndicator>Y</ns2:RatePickupIndicator>';
                    
			soapXML += '<ns2:Shipper>';				soapXML += '<ns2:Account>';						soapXML += '<ns2:AccountNumber>'+ upsAccountNumber.escapeXml() +'</ns2:AccountNumber>';					soapXML += '<ns2:AccountCountryCode>'+ shipperCountryCode.escapeXml() +'</ns2:AccountCountryCode>';					soapXML += '</ns2:Account>';					soapXML += '</ns2:Shipper>';
                    
                    soapXML += '<ns2:PickupDateInfo>';            					soapXML += '<ns2:ReadyTime>'+ PackageReadyTime.escapeXml() +'</ns2:ReadyTime>';					soapXML += '<ns2:CloseTime>'+ CustomerCloseTime.escapeXml() +'</ns2:CloseTime>';					soapXML += '<ns2:PickupDate>'+ dispatchDate.escapeXml() +'</ns2:PickupDate>';				soapXML += '</ns2:PickupDateInfo>';                                    
                    
                    if(fromAddress != null) {					soapXML += '<ns2:PickupAddress>';					if(fromAddress.Contact__r.Company__c != null) soapXML += '<ns2:CompanyName>'+ fromAddress.Contact__r.Company__c.escapeXml() +'</ns2:CompanyName>';						if(fromAddress.Contact__r.Name != null) soapXML += '<ns2:ContactName>'+ fromAddress.Contact__r.Name.escapeXml() +'</ns2:ContactName>';						if(originStreet != null) soapXML += '<ns2:AddressLine>'+ originStreet.escapeXml() +'</ns2:AddressLine>';					soapXML += '<ns2:City>'+ fromAddress.City__c.escapeXml() +'</ns2:City>';						if(originProvinceCode != null) soapXML += '<ns2:StateProvince>'+ originProvinceCode.escapeXml() +'</ns2:StateProvince>';						soapXML += '<ns2:PostalCode>'+ fromAddress.Postal_Code__c.escapeXml() +'</ns2:PostalCode>';						soapXML += '<ns2:CountryCode>'+ originCountryCode.escapeXml() +'</ns2:CountryCode>';					soapXML += '<ns2:ResidentialIndicator>N</ns2:ResidentialIndicator>';					soapXML += '<ns2:Phone>';					soapXML += '<ns2:Number>'+ fromAddress.Contact__r.Phone.escapeXml() +'</ns2:Number>';					soapXML += '</ns2:Phone>';						soapXML += '</ns2:PickupAddress>';
                    }
                    soapXML += '<ns2:AlternateAddressIndicator>N</ns2:AlternateAddressIndicator>';
                    
                    soapXML += '<ns2:PickupPiece>';							if(shipments.UPS_Service_Code__c != null) soapXML += '<ns2:ServiceCode>'+ '0' + shipments.UPS_Service_Code__c.escapeXml() +'</ns2:ServiceCode>';  					if(packList != null && packList.size() > 0) soapXML += '<ns2:Quantity>'+ packList.size() +'</ns2:Quantity>';                        					soapXML += '<ns2:DestinationCountryCode>'+ destinationCountryCode.escapeXml() +'</ns2:DestinationCountryCode>';							soapXML += '<ns2:ContainerCode>'+ contCode.escapeXml() +'</ns2:ContainerCode>';			soapXML += '</ns2:PickupPiece>';
                    
                    Integer totalWeight = 0;					for(Package__c p : packList) { if(p.Weight__c != null) totalWeight += Integer.valueof(p.Weight__c); }						soapXML += '<ns2:TotalWeight>';							soapXML += '<ns2:Weight>'+ totalWeight +'</ns2:Weight>';						if(packList != null && packList.size() > 0) soapXML += '<ns2:UnitOfMeasurement>'+ packList[0].Weight_Unit__c.escapeXml() +'</ns2:UnitOfMeasurement>';						soapXML += '</ns2:TotalWeight>';                    							soapXML += '<ns2:PaymentMethod>01</ns2:PaymentMethod>';                    						soapXML += '</ns2:PickupCreationRequest>';            					soapXML += '</SOAP-ENV:Body>';							soapXML += '</SOAP-ENV:Envelope>';  
            
            HttpRequest req = new HttpRequest(); 					Http h = new Http();
            
            req.setBody(soapXML);					req.setMethod('POST');				String myEndPoint = endpoint + '/webservices/Pickup';					req.setEndpoint(myEndPoint);					req.setHeader('Content-length', '175');					req.setHeader('Content-Type', 'charset=utf-8');					req.setHeader('SOAPAction', '');               
                             
            HttpResponse res = h.send(req);
            
            request_1 = req.getBody();				response_1 = res.getBody();						resStatus = res.getStatus();					if(resStatus == 'OK') {						XmlStreamReader reader1 = res.getXmlStreamReader();					String msg = readXMLResponseFirstValue(reader1, 'Description');					if(msg != Null && (msg == 'Success' || msg == 'WARNING')) {						XmlStreamReader avail = res.getXmlStreamReader();					String PickupConfirmNumber = readXMLResponseFirstValue(avail, 'PRN');						String pickupAmount = readXMLResponseFirstValue(avail, 'GrandTotalOfAllCharge');						if(PickupConfirmNumber != Null) {					Result = 'Shipment Pickup For This Package Created Successfully';					if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Picked Up'; }					if(Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isUpdateable()) { shipments.Pickup_Confirmation_Number__c = PickupConfirmNumber; }					if(Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isUpdateable()) { shipments.Pickup_Requested__c = true; }					if(Schema.sObjectType.Shipment__c.fields.Pickup_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Amount__c.isUpdateable()) { shipments.Pickup_Amount__c = Decimal.valueOf(pickupAmount); }
                        
                        if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert shipments; }else{ }				if(packList != null && packList.size() > 0) {							for(Package__c pac : packList) {if(Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) pac.Status__c = shipments.Status__c; } 				if(Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable()){ PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert packList; } else{}
                        }
                    } else Result = 'Shipment Pickup For This Package Is Not Available';
               
                } else {
                    XmlStreamReader message = res.getXmlStreamReader();String mesage = readXMLResponse(message, 'Description');
                    if(mesage != Null && mesage != '') Result = 'Request To Pickup Create Shipment Cannot Be Processed : ' + mesage;
                    else Result = 'Request To Pickup Create Shipment Cannot Be Processed';
                }
            } else Result = 'Result Not Available';      
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }    
    //public PageReference CreatePickupFreightRequest(Address__c fromAddress, Address__c toAddress, List<Package__c> packList, Shipment__c shipments, String dispatchDate, String contCode, String PackageReadyTime, String CustomerCloseTime) {
    public PageReference CreatePickupFreightRequest(String fromAddress1, String toAddress1, String packList1, String shipments1, String dispatchDate, String contCode, String PackageReadyTime, String CustomerCloseTime) {
        try {
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);String soapXML = System.label.upsHandler1;
            soapXML += '<SOAP-ENV:Header>';soapXML += '<ns3:UPSSecurity>';
            
            soapXML += '<ns3:UsernameToken>';soapXML += '<ns3:Username>'+ userName.escapeXml() +'</ns3:Username>';soapXML += '<ns3:Password>'+ password.escapeXml() +'</ns3:Password>';soapXML += '</ns3:UsernameToken>';
            
            soapXML += '<ns3:ServiceAccessToken>';soapXML += '<ns3:AccessLicenseNumber>'+ Key.escapeXml() +'</ns3:AccessLicenseNumber>';soapXML += '</ns3:ServiceAccessToken>';soapXML += '</ns3:UPSSecurity>';soapXML += '</SOAP-ENV:Header>';
            soapXML += '<SOAP-ENV:Body>';
                soapXML += '<ns2:PickupCreationRequest>';
                    soapXML += '<ns1:Request/>';soapXML += '<ns2:RatePickupIndicator>Y</ns2:RatePickupIndicator>';
                    
                    soapXML += '<ns2:Shipper>';
                        soapXML += '<ns2:Account>';soapXML += '<ns2:AccountNumber>'+ upsAccountNumber.escapeXml() +'</ns2:AccountNumber>';soapXML += '<ns2:AccountCountryCode>'+ shipperCountryCode.escapeXml() +'</ns2:AccountCountryCode>';soapXML += '</ns2:Account>';
                    soapXML += '</ns2:Shipper>';
                    
                    soapXML += '<ns2:PickupDateInfo>';            
                        soapXML += '<ns2:ReadyTime>'+ PackageReadyTime.escapeXml() +'</ns2:ReadyTime>';soapXML += '<ns2:CloseTime>'+ CustomerCloseTime.escapeXml() +'</ns2:CloseTime>';soapXML += '<ns2:PickupDate>'+ dispatchDate.escapeXml() +'</ns2:PickupDate>';
                    soapXML += '</ns2:PickupDateInfo>';                                    
                                
                    if(fromAddress != null) {
                        soapXML += '<ns2:PickupAddress>';
                            if(fromAddress.Contact__r.Company__c != null) soapXML += '<ns2:CompanyName>'+ fromAddress.Contact__r.Company__c.escapeXml() +'</ns2:CompanyName>';
                            if(fromAddress.Contact__r.Name != null) soapXML += '<ns2:ContactName>'+ fromAddress.Contact__r.Name.escapeXml() +'</ns2:ContactName>';
                            soapXML += '<ns2:AddressLine>'+ originStreet.escapeXml() +'</ns2:AddressLine>';
                            soapXML += '<ns2:City>'+ fromAddress.City__c.escapeXml() +'</ns2:City>';
                            if(originProvinceCode != null) soapXML += '<ns2:StateProvince>'+ originProvinceCode.escapeXml() +'</ns2:StateProvince>';
                            soapXML += '<ns2:PostalCode>'+ fromAddress.Postal_Code__c.escapeXml() +'</ns2:PostalCode>';soapXML += '<ns2:CountryCode>'+ originCountryCode.escapeXml() +'</ns2:CountryCode>';soapXML += '<ns2:ResidentialIndicator>N</ns2:ResidentialIndicator>';soapXML += '<ns2:Phone>';soapXML += '<ns2:Number>'+ fromAddress.Contact__r.Phone.escapeXml() +'</ns2:Number>';soapXML += '</ns2:Phone>';
                        soapXML += '</ns2:PickupAddress>';
                    }
                    soapXML += '<ns2:AlternateAddressIndicator>N</ns2:AlternateAddressIndicator>';
                    
                    soapXML += '<ns2:PickupPiece>';
                        soapXML += '<ns2:ServiceCode>'+ shipments.UPS_Service_Code__c.escapeXml() +'</ns2:ServiceCode>';  
                        if(packList != null && packList.size() > 0) soapXML += '<ns2:Quantity>'+ packList.size() +'</ns2:Quantity>';                        
                        soapXML += '<ns2:DestinationCountryCode>'+ destinationCountryCode.escapeXml() +'</ns2:DestinationCountryCode>';soapXML += '<ns2:ContainerCode>'+ contCode +'</ns2:ContainerCode>';
                    soapXML += '</ns2:PickupPiece>';
                    
                    Integer totalWeight = 0;
                    for(Package__c p : packList) { if(p.Weight__c != null) totalWeight += Integer.valueof(p.Weight__c); }
                    soapXML += '<ns2:TotalWeight>';
                        soapXML += '<ns2:Weight>'+ totalWeight +'</ns2:Weight>';
                        if(packList != null && packList.size() > 0) soapXML += '<ns2:UnitOfMeasurement>'+ packList[0].Weight_Unit__c.escapeXml() +'</ns2:UnitOfMeasurement>';
                    soapXML += '</ns2:TotalWeight>';                    soapXML += '<ns2:PaymentMethod>01</ns2:PaymentMethod>';
                    
                    soapXML += '<ns2:FreightOptions>'; 
                        soapXML += '<ns2:ShipmentDetail>';
                            for(Package__c p : packList) {
                                soapXML += '<ns2:PalletInformation>';            soapXML += '<ns2:Dimensions>';            soapXML += '<ns2:UnitOfMeasurement>';
                                if(p.Weight_Unit__c == 'KGS') soapXMl += '<ns2:Code>CM</ns2:Code>';
                                else soapXMl += '<ns2:Code>IN</ns2:Code>';
                                soapXML += '</ns2:UnitOfMeasurement>';             soapXML += '<ns2:Length>'+ p.Length__c +'</ns2:Length>';soapXML += '<ns2:Width>'+ p.Width__c +'</ns2:Width>';soapXML += '<ns2:Height>'+ p.Height__c +'</ns2:Height>';soapXML += '</ns2:Dimensions>';soapXML += '</ns2:PalletInformation>';
                            }            
                        soapXML += '</ns2:ShipmentDetail>';
                    soapXML += '</ns2:FreightOptions>';                    
                soapXML += '</ns2:PickupCreationRequest>';            
            soapXML += '</SOAP-ENV:Body>';
            soapXML += '</SOAP-ENV:Envelope>';
            
            HttpRequest req = new HttpRequest(); 
            Http h = new Http();req.setBody(soapXML);req.setMethod('POST');String myEndPoint = endpoint + '/webservices/Pickup';req.setEndpoint(myEndPoint);req.setHeader('Content-length', '175');req.setHeader('Content-Type', 'charset=utf-8');req.setHeader('SOAPAction', '');               
                             
            HttpResponse res = h.send(req);
            
            request_1 = req.getBody();response_1 = res.getBody();resStatus = res.getStatus();
            if(resStatus == 'OK') {
                XmlStreamReader reader1 = res.getXmlStreamReader();
                String msg = readXMLResponseFirstValue(reader1, 'Description');
                if(msg != Null && (msg == 'Success' || msg == 'WARNING')) {
                    XmlStreamReader avail = res.getXmlStreamReader();String PickupConfirmNumber = readXMLResponseFirstValue(avail, 'PRN');String pickupAmount = readXMLResponseFirstValue(avail, 'GrandTotalOfAllCharge');
                    if(PickupConfirmNumber != Null) {
                        Result = 'Shipment Pickup For This Package Created Successfully';
                        if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Picked Up'; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isUpdateable()) { Shipments.Pickup_Confirmation_Number__c = PickupConfirmNumber; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isUpdateable()) { Shipments.Pickup_Requested__c = true; }
                        if(Schema.sObjectType.Shipment__c.fields.Pickup_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Amount__c.isUpdateable()) { Shipments.Pickup_Amount__c = Decimal.valueOf(pickupAmount); }
                        if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Shipments; }else{ }
                        
                        if(packList != null && packList.size() > 0 && Schema.sObjectType.Package__c.isCreateable() && Schema.sObjectType.Package__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) {
                            for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; }
                            PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; hasAccess=true; upsert packList; 
                        }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
                    } else Result = 'Shipment Pickup For This Package Is Not Available';
                
                } else {
                    XmlStreamReader message = res.getXmlStreamReader();String mesage = readXMLResponse(message, 'Description');
                    if (mesage != Null && mesage != '') Result = 'Request To Pickup Create Shipment Cannot Be Processed : ' + mesage;
                    else Result = 'Request To Pickup Create Shipment Cannot Be Processed';
                }
            } else Result = 'Result Not Available';
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      Cancel pickup API request
    */
    public PageReference CancelPickup() {
        try {
            address_val_tab = false;time_in_cost_tab = false;pickup_pendingstatus_Tab = false; pickup_servicecenter_Tab = false;
            
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 
            else if(Shipment.Pickup_Requested__c == false) { errorMsg1 = 'Shipment Pickup Unavailable To Cancel'; } 
            else { errorMsg1 = ''; /*CancelPickupRequest(shipment, packages);*/CancelPickupRequest(JSON.serialize(shipment), JSON.serialize(packages)); }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    //public PageReference CancelPickupRequest(Shipment__c shipments, List<Package__c> packList) {
    public PageReference CancelPickupRequest(String shipments1, String packList1) {
        try {
            Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);
            List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);
            String soapXML =  System.label.upsHandler1;
            soapXML += '<SOAP-ENV:Header>';soapXML += '<ns3:UPSSecurity>';
            
            soapXML += '<ns3:UsernameToken>';soapXML += '<ns3:Username>'+ userName.escapeXml() +'</ns3:Username>';soapXML += '<ns3:Password>'+ password.escapeXml() +'</ns3:Password>';soapXML += '</ns3:UsernameToken>';
            
            soapXML += '<ns3:ServiceAccessToken>';soapXML += '<ns3:AccessLicenseNumber>'+ Key.escapeXml() +'</ns3:AccessLicenseNumber>';soapXML += '</ns3:ServiceAccessToken>';
            
            soapXML += '</ns3:UPSSecurity>';soapXML += '</SOAP-ENV:Header>';soapXML += '<SOAP-ENV:Body>';soapXML += '<ns2:PickupCancelRequest>';soapXML += '<ns1:Request/>';soapXML += '<ns2:CancelBy>02</ns2:CancelBy>';
                    if(shipments != null && shipments.Pickup_Confirmation_Number__c != null) soapXML += '<ns2:PRN>'+ shipments.Pickup_Confirmation_Number__c.escapeXml() +'</ns2:PRN>';
                soapXML += '</ns2:PickupCancelRequest>';soapXML += '</SOAP-ENV:Body>';soapXML += '</SOAP-ENV:Envelope>';
            
            Http h = new Http();HttpRequest req = new HttpRequest();req.setBody(soapXML);        req.setMethod('POST');String myEndPoint = endpoint + '/webservices/Pickup';req.setEndpoint(myEndPoint);        req.setHeader('Content-length', '175');req.setHeader('Content-Type', 'charset=utf-8');req.setHeader('SOAPAction', '');
            
            HttpResponse res = h.send(req);        
            
            request_1 = req.getBody();response_1 = res.getBody();resStatus = res.getStatus();
            if(resStatus == 'OK') {
                XmlStreamReader reader1 = res.getXmlStreamReader();String msg = readXMLResponse(reader1, 'Description');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                    Result = 'Shipment Pickup For This Package Cancelled Successfully';
                    if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) { shipments.Status__c = 'Shipped'; }if(Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Confirmation_Number__c.isUpdateable()) { Shipments.Pickup_Confirmation_Number__c = null; }if(Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Requested__c.isUpdateable()) { Shipments.Pickup_Requested__c = false; }if(Schema.sObjectType.Shipment__c.fields.Package_Ready_Time__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Package_Ready_Time__c.isUpdateable()) { Shipments.Package_Ready_Time__c = null; }if(Schema.sObjectType.Shipment__c.fields.Customer_Close_Time__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Customer_Close_Time__c.isUpdateable()) { Shipments.Customer_Close_Time__c = null; }if(Schema.sObjectType.Shipment__c.fields.Pickup_Amount__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Pickup_Amount__c.isUpdateable()) { Shipments.Pickup_Amount__c = null; }
                    if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Shipments; }else{ }
                    
                    if(packList != null && packList.size() > 0 && Schema.SObjectType.Package__c.isCreateable() && Schema.SObjectType.Package__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) {
                        for(Package__c pac : packList) { pac.Status__c = shipments.Status__c; } 
                        PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert packList; 
                    }else{ }
                } else {
                    XmlStreamReader message = res.getXmlStreamReader();String mesage = readXMLResponse(message, 'Description');
                    if(mesage != Null && mesage != '') Result = 'Unable To Process Pickup Cancel Request For This Package : ' + mesage;
                    else Result = 'Unable To Process Pickup Cancel Request For This Package';
                }
            } else Result = 'Result Not Available';
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    /*
      Pickup pending status API request.
    */
    public PageReference PickupPendingStatus() {         
        try {             
            address_val_tab = false;time_in_cost_tab = false;pickup_servicecenter_Tab = false;         
            
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 
            else if(Shipment.Pickup_Requested__c == false) { errorMsg1 = 'Shipment Pickup Pending Status Is Unavailable'; } 
            else { errorMsg1 = ''; PickupPendingStatusRequest(); }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return null;
    }
    public PageReference PickupPendingStatusRequest() {    
        try { 
            String soapXML =  System.label.upsHandler1;
            soapXML += '<SOAP-ENV:Header>';
            soapXML += '<ns3:UPSSecurity>';
            
            soapXML += '<ns3:UsernameToken>';
            soapXML += '<ns3:Username>'+ userName.escapeXml() +'</ns3:Username>';
            soapXML += '<ns3:Password>'+ password.escapeXml() +'</ns3:Password>';
            soapXML += '</ns3:UsernameToken>';
            
            soapXML += '<ns3:ServiceAccessToken>';
            soapXML += '<ns3:AccessLicenseNumber>'+ Key.escapeXml() +'</ns3:AccessLicenseNumber>';
            soapXML += '</ns3:ServiceAccessToken>';
            
            soapXML += '</ns3:UPSSecurity>';
            soapXML += '</SOAP-ENV:Header>';
            soapXML += '<SOAP-ENV:Body>';
                soapXML += '<ns2:PickupPendingStatusRequest>';
                    soapXML += '<ns1:Request/>';
                    soapXML += '<ns2:PickupType>01</ns2:PickupType>';
                    soapXML += '<ns2:AccountNumber>'+ upsAccountNumber.escapeXml() +'</ns2:AccountNumber>';
                soapXML += '</ns2:PickupPendingStatusRequest>';            
            soapXML += '</SOAP-ENV:Body>';
            soapXML += '</SOAP-ENV:Envelope>';
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setBody(soapXML);            
            req.setMethod('POST');
            String myEndPoint = Endpoint + '/webservices/Pickup';
            req.setEndpoint(myEndPoint);                   
            req.setHeader('Content-length', '175');
            req.setHeader('Content-Type', 'charset=utf-8');
            req.setHeader('SOAPAction', '');
            
            HttpResponse res = h.send(req);
            
            request_1 = req.getBody();
            response_1 = res.getBody();
            resStatus = res.getStatus();
            if(resStatus == 'OK') {
                XmlStreamReader reader1 = res.getXmlStreamReader();
                String msg = readXMLResponse(reader1, 'Description');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                    Result = 'Shipment Pickup Pending Status For This Package.';XmlStreamReader reader = res.getXmlStreamReader();readXMLResponsePendingStatus(reader,'PendingStatus');              pickup_pendingstatus_Tab = true;                 
                } else {
                    XmlStreamReader message = res.getXmlStreamReader();String mesage = readXMLResponse(message, 'Description');
                    if(mesage != Null && mesage != '') Result = 'Unable To Process Pickup Pending Status Request For This Package : ' + mesage;
                    else Result = 'Unable To Process Pickup Pending Status Request For This Package';
                }
            } else Result = 'Result Not Available';
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    public void readXMLResponsePendingStatus(XmlStreamReader reader, String sxmltag) {
        try {
            pickuppendingWrapper ppw; pickuppendingWrapperList = new List<pickuppendingWrapper>();            
            while(reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { ppw = new pickuppendingWrapper ();                    
                    // Pick Type
                    reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PickupType') { reader.next(); ppw.PickupType = reader.getText(); }                 
                    // Service Date
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceDate') { reader.next(); ppw.ServiceDate = reader.getText(); }                
                    // PRN Number
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PRN') { reader.next(); ppw.pickupReferenceNo = reader.getText(); }                
                    // On Call Status Code
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OnCallStatusCode') { reader.next(); ppw.oncallStatusCode = reader.getText(); }                
                    // status Message
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PickupStatusMessage') { reader.next(); ppw.PickupStatusMsg = reader.getText(); }                
                    // Billing Code
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'BillingCode') { reader.next(); ppw.billCode = reader.getText(); }                 
                    // Contact Name
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ContactName') { reader.next(); ppw.contactName = reader.getText(); }                
                    // Reference Number
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ReferenceNumber') { reader.next(); ppw.referenceNo = reader.getText(); }                                                                                
                    pickuppendingWrapperList.add(ppw);
                } reader.next();                
            }            
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      Pickup service center API request.
    */
    public PageReference PickupServiceCenterFacilities() {                
        try {             
            address_val_tab = false;
            time_in_cost_tab = false;
            pickup_pendingstatus_Tab = false; 
            
            if(errorMsg != '') { return null; }
            resStatus = Result = '';
            if(Shipment.Status__c == 'Delivered') { errorMsg1 = 'Shipment Delivered : Request Cannot Be Processed'; } 
            else if(Shipment.Pickup_Requested__c != true) { errorMsg1 = 'Shipment Pickup Unavailable'; } 
            else { errorMsg1 = ''; PickupServiceCenterFacilitiesRequest(JSON.serialize(fromAddress), JSON.serialize(shippingAddress)); }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }        
        return null;
     }
    public PageReference PickupServiceCenterFacilitiesRequest(String fromAddress1, String toAddress1) {           
        try {
            Address__c fromAddress = (Address__c)JSON.deserialize(fromAddress1, Address__c.class);
            Address__c toAddress = (Address__c)JSON.deserialize(toAddress1, Address__c.class);
            String soapXML =  System.label.upsHandler1;
            soapXML += '<SOAP-ENV:Header>';
            soapXML += '<ns3:UPSSecurity>';
            
            soapXML += '<ns3:UsernameToken>';
            soapXML += '<ns3:Username>'+ userName.escapeXml() +'</ns3:Username>';
            soapXML += '<ns3:Password>'+ password.escapeXml() +'</ns3:Password>';
            soapXML += '</ns3:UsernameToken>';
            
            soapXML += '<ns3:ServiceAccessToken>';
            soapXML += '<ns3:AccessLicenseNumber>'+ Key.escapeXml() +'</ns3:AccessLicenseNumber>';
            soapXML += '</ns3:ServiceAccessToken>';
            
            soapXML += '</ns3:UPSSecurity>';
            soapXML += '</SOAP-ENV:Header>';
            soapXML += '<SOAP-ENV:Body>';            
                soapXML += '<ns2:PickupGetServiceCenterFacilitiesRequest>';
                    soapXML += '<ns2:PickupPiece>';
                    soapXML += '<ns2:ServiceCode>96</ns2:ServiceCode>';
                    soapXML += '<ns2:ContainerCode>03</ns2:ContainerCode>';
                    soapXML += '</ns2:PickupPiece>';
                    
                    if(fromAddress != null) {
                        soapXML += '<ns2:OriginAddress>';      
                        soapXML += '<ns2:StreetAddress>'+ originStreet.escapeXml() +'</ns2:StreetAddress>';soapXML += '<ns2:City>'+ fromAddress.City__c.escapeXml() +'</ns2:City>';soapXML += '<ns2:PostalCode>'+ fromAddress.Postal_Code__c.escapeXml() +'</ns2:PostalCode>';
                        if(originProvinceCode != null) soapXML += '<ns2:StateProvince>'+ originProvinceCode.escapeXml() +'</ns2:StateProvince>';
                        soapXML += '<ns2:CountryCode>'+ originCountryCode.escapeXml() +'</ns2:CountryCode>';            soapXML += '</ns2:OriginAddress>';
                    }
                    if(toAddress != null) {
                        soapXML += '<ns2:DestinationAddress>';soapXML += '<ns2:StreetAddress>'+ destinationStreet.escapeXml() +'</ns2:StreetAddress>';soapXML += '<ns2:City>'+ toAddress.City__c.escapeXml() +'</ns2:City>';soapXML += '<ns2:PostalCode>'+ toAddress.Postal_Code__c.escapeXml() +'</ns2:PostalCode>';soapXML += '<ns2:StateProvince>'+ destinationProvinceCode.escapeXml() +'</ns2:StateProvince>';soapXML += '<ns2:CountryCode>'+ destinationCountryCode.escapeXml() +'</ns2:CountryCode>';soapXML += '</ns2:DestinationAddress>';
                    }soapXML += '</ns2:PickupGetServiceCenterFacilitiesRequest>';            soapXML += '</SOAP-ENV:Body>';soapXML += '</SOAP-ENV:Envelope>';
            
            HttpRequest req = new HttpRequest();                        Http h = new Http();req.setBody(soapXML);req.setMethod('POST');                    String myEndPoint = Endpoint + '/webservices/Pickup';      req.setEndpoint(myEndPoint);                       req.setHeader('Content-length', '175');req.setHeader('Content-Type', 'charset=utf-8');            req.setHeader('SOAPAction', '');
            HttpResponse res = h.send(req);request_1 = req.getBody();response_1 = res.getBody();resStatus = res.getStatus();
            if(resStatus == 'OK') {
                XmlStreamReader reader1 = res.getXmlStreamReader();String msg = readXMLResponse(reader1, 'Description');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                    Result = 'Shipment Pickup Service Center Facilities For This Package.';XmlStreamReader reader = res.getXmlStreamReader();readXMLResponsePickupServiceCenter(reader,'DropOffFacilities');                                        pickup_servicecenter_Tab = true;        
                } else {XmlStreamReader message = res.getXmlStreamReader();String mesage = readXMLResponse(message, 'Description');
                    if(mesage != Null && mesage != '') Result = 'Unable To Process Pickup Service Center Request For This Package : ' + mesage;
                    else Result = 'Unable To Process Pickup Service Center Request For This Package';
                }
            } else Result = 'Result Not Available';
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    public void readXMLResponsePickupServiceCenter(XmlStreamReader reader, String sxmltag) {
        try {
            pickupservicecenterWrapper pscw; pickupservicecenterWrapperList = new List<pickupservicecenterWrapper>();            
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { pscw = new pickupservicecenterWrapper ();                    
                    reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Name') { reader.next(); pscw.pickupName= reader.getText(); }                 
                    reader.next(); reader.next(); reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'AddressLine') { reader.next(); pscw.addressLine= reader.getText(); }                
                    
                    reader.next(); reader.next();
                    if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'City') { reader.next(); pscw.cityName = reader.getText(); }                reader.next(); reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'StateProvince') { reader.next(); pscw.stateProvinceCode = reader.getText(); reader.next(); reader.next();}                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PostalCode') { reader.next(); pscw.postalCode = reader.getText(); }                reader.next(); reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CountryCode') { reader.next(); pscw.countryCode = reader.getText(); }                reader.next(); reader.next(); reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SLIC') { reader.next(); pscw.SLICNo = reader.getText(); }                reader.next(); reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Type') { reader.next(); pscw.pickupType = reader.getText(); }                 reader.next(); reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Timezone') { reader.next(); pscw.timeZone = reader.getText(); }                  reader.next(); reader.next();if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Phone') { reader.next(); pscw.phoneNo = reader.getText(); reader.next(); reader.next();} reader.next(); reader.next();                                                                              
                    
                    boolean alloc = false;
                    while(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Day') { reader.next();
                        if(reader.getText() == 'Sunday') { reader.next(); reader.next();
                            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OpenHours') { reader.next(); pscw.sun.openHours = reader.getText(); reader.next(); reader.next();                                    }   if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CloseHours') { reader.next(); pscw.sun.closeHours = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PrepTime') { reader.next(); pscw.sun.prepTime = reader.getText(); reader.next(); reader.next();}                                                                if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'LastDrop') { reader.next(); pscw.sun.lastDrop = reader.getText(); reader.next(); reader.next();} reader.next(); reader.next(); alloc = true;
                            
                        } else if(reader.getText() == 'Monday') { reader.next(); reader.next();
                            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OpenHours') { reader.next(); pscw.mon.openHours = reader.getText(); reader.next(); reader.next();}   if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CloseHours') { reader.next(); 				pscw.mon.closeHours = reader.getText(); reader.next(); reader.next();}                                                                 if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PrepTime') { reader.next(); 				pscw.mon.prepTime = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'LastDrop') { reader.next(); 			pscw.mon.lastDrop = reader.getText(); reader.next(); reader.next();				} reader.next(); reader.next(); alloc = true;
                            
                        } else if(reader.getText() == 'Tuesday') { reader.next(); reader.next();			if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OpenHours') { reader.next(); 				pscw.tue.openHours = reader.getText(); reader.next(); reader.next();}   
                            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CloseHours') { reader.next();				pscw.tue.closeHours = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PrepTime') { reader.next(); 				pscw.tue.prepTime = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'LastDrop') { reader.next(); 				pscw.tue.lastDrop = reader.getText(); reader.next(); reader.next();				} reader.next(); reader.next(); alloc = true;
                            
                        } else if(reader.getText() == 'Wednesday') { reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OpenHours') { reader.next(); 				pscw.wed.openHours = reader.getText(); reader.next(); reader.next();}   
                            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CloseHours') { reader.next(); 			pscw.wed.closeHours = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PrepTime') { reader.next(); 				pscw.wed.prepTime = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'LastDrop') { reader.next(); 			pscw.wed.lastDrop = reader.getText(); reader.next(); reader.next();				} reader.next(); reader.next(); alloc = true;
                            
                        } else if(reader.getText() == 'Thursday') { reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OpenHours') { reader.next(); 				pscw.thu.openHours = reader.getText(); reader.next(); reader.next();}   
                            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CloseHours') { reader.next(); 				pscw.thu.closeHours = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PrepTime') { reader.next(); 				pscw.thu.prepTime = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'LastDrop') { reader.next(); 				pscw.thu.lastDrop = reader.getText(); reader.next(); reader.next();				} reader.next(); reader.next(); alloc = true;
                            
                        } else if(reader.getText() == 'Friday') { reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OpenHours') { reader.next(); 			pscw.fri.openHours = reader.getText(); reader.next(); reader.next();}   
                            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CloseHours') { reader.next(); 			pscw.fri.closeHours = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PrepTime') { reader.next(); 				pscw.fri.prepTime = reader.getText(); reader.next(); reader.next();}                                                                  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'LastDrop') { reader.next(); 				pscw.fri.lastDrop = reader.getText(); reader.next(); reader.next();				} reader.next(); reader.next(); alloc = true;
                            
                        } else if(reader.getText() == 'Saturday') { reader.next(); reader.next();				if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'OpenHours') { reader.next(); 				pscw.sat.openHours = reader.getText(); reader.next(); reader.next();
                            }   
                            if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CloseHours') { reader.next(); 			pscw.sat.closeHours = reader.getText(); reader.next(); reader.next();}  if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'PrepTime') { reader.next(); 				pscw.sat.prepTime = reader.getText(); reader.next(); reader.next();} if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'LastDrop') { reader.next(); 			pscw.sat.lastDrop = reader.getText(); reader.next(); reader.next();				} reader.next(); reader.next(); alloc = true;
                        }                        
                    } pickupservicecenterWrapperList.add(pscw);					} reader.next();                
            }            
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      Track shipment API request.
    */
    public PageReference acceptTrackNotice() {				try { 				time_in_cost_tab = false;            			if(errorMsg != '') { return null; }					Result = resStatus = '';            				if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The Shipment Is Unavailable'; }				if(Shipment.Status__c != 'Shipped') { errorMsg1 = 'Request To Track The Shipment Cannot Be Processed'; } 				else if(showAndHideMap.get(10)) { errorMsg1 = ''; /*Track_Request_Reply(shipment, packages);*/Track_Request_Reply(JSON.serialize(shipment), JSON.serialize(packages)); }				} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return null;
    }
    //public PageReference Track_Request_Reply(Shipment__c shipments, List<Package__c> packList) {
    public PageReference Track_Request_Reply(String shipments1, String packList1) {        			try {				Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);			List<Package__c> packList = (List<Package__c>)JSON.deserialize(packList1, List<Package__c>.class);				String[] s;				if(shipments.Tracking_Number__c != null) s = shipments.Tracking_Number__c.split(',');				if(s != null && s.size() > 0){if(Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Tracking_Number__c.isUpdateable()) shipments.Tracking_Number__c = s[0];}				string soapXML = '<?xml version="1.0"?>';				soapXML += '<AccessRequest xml:lang="en-US">';				soapXML += '<AccessLicenseNumber>'+ Key.escapeXml() +'</AccessLicenseNumber>';				soapXML += '<UserId>'+ userName.escapeXml() +'</UserId>';					soapXML += '<Password>'+ password.escapeXml() +'</Password>';				soapXML += '</AccessRequest>';
            
            soapXML += '<?xml version="1.0"?>';				soapXML += '<TrackRequest>';				soapXML += '<Request>'; 				soapXML += '<RequestAction>Track</RequestAction>';					soapXML += '<RequestOption>03</RequestOption>';					soapXML += '</Request>';                				if(shipments != null && shipments.Tracking_Number__c != null) soapXML += '<TrackingNumber>'+ shipments.Tracking_Number__c.escapeXml() +'</TrackingNumber>';			soapXML += '</TrackRequest>';
            
            Http h = new Http();			HttpRequest req = new HttpRequest();
                        
            req.setBody(soapXML);				req.setMethod('POST');			String myEndPoint = Endpoint + '/ups.app/xml/Track';				req.setEndpoint(myEndPoint);
                
            HttpResponse res = h.send(req);
            
            request_1 = req.getBody();            
            response_1 = res.getBody();
            resStatus = res.getStatus();
            if(resStatus == 'OK') {
                XmlStreamReader reader1 = res.getXmlStreamReader();String msg = readXMLResponseOnce(reader1, 'ResponseStatusDescription');
                if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                    readXMLResponseTrackHistory(res.getXmlStreamReader(),'Activity'); List<Shipment_Flow__c> existingSFList; Map<String, Shipment_Flow__c> sfMap = new Map<String, Shipment_Flow__c>();
                    if(Shipment != null) { existingSFList = [select Id, Name, Shipment__c, Shipment_DateTime__c, Description__c, Shipment_Flow_Start_Date__c, 
                                                             Shipment_Flow_End_Date__c from Shipment_Flow__c where Shipment__c =: Shipment.Id Order by Name Asc]; }  
                    for(Shipment_Flow__c sf: existingSFList) { sfMap.put(sf.Shipment_DateTime__c, sf); }
                    for(Integer i=0; i<trackWrapperList.size(); i++) {
                        Shipment_Flow__c sf = new Shipment_Flow__c(Shipment_DateTime__c = String.valueof(trackWrapperList[i].dtValue));
                        if(!sfMap.keyset().contains(String.valueof(trackWrapperList[i].dtValue))) {
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Name.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Name.isUpdateable()) sf.Name = 'Shipment Flow ' + i+1;
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment__c.isUpdateable()) if(Shipments != null) sf.Shipment__c = Shipments.Id;
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Active__c.isUpdateable()) sf.Active__c = true;                            
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_Start_Date__c.isUpdateable()) if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_Start_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Shipment_Flow_End_Date__c.isUpdateable()) if(trackWrapperList[i].dtValue != null) sf.Shipment_Flow_End_Date__c = Datetime.valueof(trackWrapperList[i].dtValue);
                            if(Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isCreateable() && Schema.sObjectType.Shipment_Flow__c.fields.Description__c.isUpdateable()) if(trackWrapperList[i].activityDesp != null) sf.Description__c = trackWrapperList[i].activityDesp;
                            if(trackWrapperList[i].activityDesp != null && trackWrapperList[i].activityDesp == 'Delivered'){  if(Schema.sObjectType.Shipment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Shipment__c.fields.Status__c.isUpdateable()) Shipments.Status__c = 'Delivered'; }
                            
                            sfMap.put(String.valueof(trackWrapperList[i].dtValue), sf);
                        } 
                    }
                    if(Schema.sObjectType.Shipment__c.isCreateable() && Schema.sObjectType.Shipment__c.isUpdateable()) { PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert Shipments; }else{ }				if(packList != null && packList.size() > 0 && Schema.SObjectType.Package__c.isCreateable() && Schema.SObjectType.Package__c.isUpdateable() && Schema.sObjectType.Package__c.fields.Status__c.isCreateable() && Schema.sObjectType.Package__c.fields.Status__c.isUpdateable()) {				for(Package__c pac : packList) { pac.Status__c = Shipments.Status__c; } 				PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false; upsert packList; 
                    }else{ }
                    if(sfMap.size() > 0 && Schema.SObjectType.Shipment_Flow__c.isCreateable() && Schema.SObjectType.Shipment_Flow__c.isUpdateable()) upsert sfMap.values(); else{}			Result = 'Track Shipment Activities';                                                                 				} else { XmlStreamReader message = res.getXmlStreamReader();				String mesage = readXMLResponse(message, 'ErrorDescription');				if(mesage != Null && mesage != '') Result = 'Request To Track Shipment Cannot Be Processed : ' + mesage;				else Result = 'Request To Track Shipment Cannot Be Processed';
               }
            } else Result = 'Result Not Available';			} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return null;
    }
    public void readXMLResponseTrackHistory(XmlStreamReader reader, String sxmltag) {				try {    				trackwrapper tw; trackwrapperlist = new List<trackwrapper>();				while (reader.hasNext()) {				if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { tw = new trackwrapper();				while(reader.hasNext()) {        
                        //city
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'City') { reader.next(); tw.location = reader.getText(); }                        
                        //CountryCode
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CountryCode') { reader.next();				if(tw.location != null && tw.location != '') tw.location = tw.location +', '+ reader.getText(); else tw.location = reader.getText();
                        } 
                        //SignedForByName
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'SignedForByName') { reader.next(); tw.SignedForByName = reader.getText(); }                        
                        //StatusType
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'StatusType') { reader.next(); reader.next(); reader.next(); reader.next(); reader.next(); tw.activityDesp = reader.getText(); }                        
                        //Date
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Date') { reader.next();				tw.tDate = reader.getText(); String yys, mms, dds;				if(tw.tDate != null) { yys = tw.tDate.substring(0,4);				mms = tw.tDate.substring(4,6);				dds = tw.tDate.substring(6,8);				tw.dateTimeString = yys +'-'+ mms +'-'+ dds; }                         
                        }                        
                        //Time
                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Time') { reader.next();					tw.tTime = reader.getText(); String hhs, mins, secs;				if(tw.tTime != null) { hhs = tw.tTime.substring(0,2);					mins = tw.tTime.substring(2,4);					secs = tw.tTime.substring(4,6);			if(tw.dateTimeString != null) tw.dateTimeString += ' '+ hhs +':'+ mins +':'+ secs;                            				tw.dtValue = Datetime.valueOf(tw.dateTimeString); }
                        }                        
                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next(); 					} trackwrapperlist.add(tw);					} reader.next();
            }        
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    /*
      Signature proof of delivery API request.
    */
    public PageReference Signature_Proof_Request() {				try {				address_val_tab = false;			time_in_cost_tab = false;				pickup_pendingstatus_Tab = false; 				pickup_servicecenter_Tab = false;
            
            if(errorMsg != '') { return null; }				resStatus = Result = '';				if(Shipment.Status__c == '' || Shipment.Status__c == Null) { errorMsg1 = 'The shipment is unavailable'; }				else if(Shipment.Status__c != 'Delivered') { errorMsg1 = 'Request To Get Signature Proof Of Delivery For This Shipment Cannot Be Processed'; } 				else { errorMsg1 = ''; SignatureProofOfDeliveryLetterRequest(JSON.serialize(shipment)); }					} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }					return null;
    }
    public PageReference SignatureProofOfDeliveryLetterRequest(String shipments1) {      				try {				Shipment__c shipments = (Shipment__c)JSON.deserialize(shipments1, Shipment__c.class);				String[] s;					if(shipments.Tracking_Number__c != null) s = shipments.Tracking_Number__c.split(',');				if(s != null && s.size() > 0) shipments.Tracking_Number__c = s[0];				string soapXML = '<?xml version="1.0"?>';				soapXML += '<AccessRequest xml:lang="en-US">';				soapXML += '<AccessLicenseNumber>'+ Key.escapeXml() +'</AccessLicenseNumber>';				soapXML += '<UserId>'+ userName.escapeXml() +'</UserId>';				soapXML += '<Password>'+ password.escapeXml() +'</Password>';				soapXML += '</AccessRequest>';
            
            soapXML += '<?xml version="1.0"?>';				soapXML += '<TrackRequest>';				soapXML += '<Request>';				soapXML += '<RequestAction>Track</RequestAction>';					soapXML += '<RequestOption>10</RequestOption>';					soapXML += '</Request>';                				if(shipments != null && shipments.Tracking_Number__c != null) soapXML += '<TrackingNumber>'+ shipments.Tracking_Number__c.escapeXml() +'</TrackingNumber>';				soapXML += '</TrackRequest>';
            
            HttpRequest req = new HttpRequest();				Http h = new Http();
            
            req.setBody(soapXML);				req.setMethod('POST');					String myEndPoint = Endpoint + '/ups.app/xml/Track';				req.setEndpoint(myEndPoint);
            
            HttpResponse res = h.send(req);
            
            request_1 = req.getBody(); response_1 = res.getBody(); resStatus = res.getStatus(); if(resStatus == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponseOnce(reader1, 'ResponseStatusDescription'); if(msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) { XmlStreamReader reader = res.getXmlStreamReader(); String letter = readXMLResponse(reader, 'HTMLImage'); if(letter != null){ attachment att = new attachment(); if(Schema.sObjectType.attachment.fields.Name.isCreateable()) att.Name = 'Proof of Delivery.doc'; if(Schema.sObjectType.attachment.fields.parentId.isCreateable()) att.parentId = Shipments.Id; if(Schema.sObjectType.attachment.fields.ContentType.isCreateable()) att.ContentType = 'application/msWord'; if(Schema.sObjectType.attachment.fields.body.isCreateable()) { att.body = EncodingUtil.base64Decode(letter); } if(Schema.SObjectType.Attachment.isCreateable()){ insert att;} else{/*Not allowed to insert*/} spodLetter = att; if(spodLetter != null) showAndHideMap.put(9, true); Result = 'Request For Signature Proof Of Delivery Processed Successfully'; } } else { XmlStreamReader message = res.getXmlStreamReader(); String mesage = readXMLResponse(message, 'ErrorDescription'); if (mesage != Null && mesage != '') Result = 'Request For Signature Proof Of Delivery Cannot Be Processed : ' + mesage; else Result = 'Request For Signature Proof Of Delivery Cannot Be Processed'; } } else Result = 'Result Not Available';			} catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }					return  null;
    }
    
    /*
      wrapper class definitions
    */
    // address validation wrapper class
    public List<addressValidationWrapper> addressValidationWrapperList { get; set; }    
    public class addressValidationWrapper {
        public String Rank                                             { get; set; }        
        public String city                                             { get; set; }
        public String Quality                                          { get; set; }
        public String StateProvinceCode                                { get; set; }
        public String PostalCodeLowEnd                                 { get; set; }
        public String PostalCodeHighEnd                                { get; set; }        
        
        public addressValidationWrapper(){
            Rank = '';            
            City = '';
            Quality = '';
            StateProvinceCode = '';
            PostalCodeLowEnd = '';
            PostalCodeHighEnd = '';
        }
    }    
    // rate wrapper class
    public List<rateWrapper> rateWrapperList       { get; set; }    
    public class rateWrapper {
        public Date DeliveryDate                   { get; set; }
        public String ServiceCode                  { get; set; }
        public String totalCharges                 { get; set; }
        public String currencyCode                 { get; set; }   
        public String DeliveryDateS                { get; set; }
        public String ServiceManual                { get; set; }
        public String negotiatedCharges            { get; set; }   
        public String TransportationCharges        { get; set; }   
        public String ServiceOptionsCharges        { get; set; } 
        public String ScheduledDeliveryTime        { get; set; }
        public String GuaranteedDaysToDelivery     { get; set; }                
        
        public rateWrapper() {
            ServiceManual = '';
            ServiceCode = '';
            totalCharges = '';
            currencyCode = '';
            DeliveryDate = null;
            DeliveryDateS = '';
            negotiatedCharges = '';
            TransportationCharges = '';
            ServiceOptionsCharges = '';            
            ScheduledDeliveryTime = '';
            GuaranteedDaysToDelivery = '';
        }
    }    
    // pickup pending status wrapper class
    public List<pickuppendingWrapper> pickuppendingWrapperList { get; set; }    
    public class pickuppendingWrapper {
        public String billCode                                 { get; set; }
        public String pickupType                               { get; set; }
        public String contactName                              { get; set; }
        public String referenceNo                              { get; set; }        
        public String serviceDate                              { get; set; }        
        public String oncallStatusCode                         { get; set; }
        public String PickupStatusMsg                          { get; set; }
        public String pickupReferenceNo                        { get; set; }
        
        public pickuppendingWrapper() {
            billCode = '';
            contactName = ''; 
            referenceNo = '';
            pickupType = '';
            serviceDate = '';
            pickupReferenceNo = '';
            oncallStatusCode = '';
            PickupStatusMsg = '';            
        }            
    }
    // pickup service center wrapper class
    public List<pickupservicecenterWrapper> pickupservicecenterWrapperList { get; set; }    
    public class pickupservicecenterWrapper {                
        public String SLICNo                                               { get; set; }
        public String phoneNo                                              { get; set; }
        public String timeZone                                             { get; set; }
        public String condition                                            { get; set; } 
        public String cityName                                             { get; set; }        
        public String pickupType                                           { get; set; }        
        public String pickupName                                           { get; set; }
        public String addressLine                                          { get; set; }                
        public String postalCode                                           { get; set; }
        public String countryCode                                          { get; set; }
        public String stateProvinceCode                                    { get; set; }
        
        public dayWrapper sun                                              { get; set; }
        public dayWrapper mon                                              { get; set; }
        public dayWrapper tue                                              { get; set; }
        public dayWrapper wed                                              { get; set; }
        public dayWrapper thu                                              { get; set; }
        public dayWrapper fri                                              { get; set; }
        public dayWrapper sat                                              { get; set; }        
                
        public pickupservicecenterWrapper() {
            SLICNo = '';
            cityName = '';
            pickupName = '';
            addressLine = '';                       
            postalCode = '';
            CountryCode = '';            
            pickupType = '';
            timeZone = '';
            phoneNo = '-';
            condition = '';
            stateProvinceCode = '-';
            
            sun = new dayWrapper('Sunday');
            mon = new dayWrapper('Monday');
            tue = new dayWrapper('Tuesday');
            wed = new dayWrapper('Wednesday');
            thu = new dayWrapper('Thursday');
            fri = new dayWrapper('Friday');
            sat = new dayWrapper('Saturday');
        }                   
    }
    public class dayWrapper {
       public String day                 { get; set; }
       public String openHours           { get; set; }
       public String closeHours          { get; set; }
       public String prepTime            { get; set; }
       public String lastDrop            { get; set; }
       
       public dayWrapper(string s){
            day = s;
            openHours = '-';
            closeHours = '-';
            prepTime = '-';
            lastDrop = '-';
       }      
    }
    // track wrapper class
    public List<trackwrapper> trackwrapperlist  { get; set; }    
    public class trackwrapper {         
        public String tDate                     { get;set; }
        public String tTime                     { get;set; }
        public String location                  { get;set; }  
        public DateTime dtValue                 { get;set; } 
        public String activityDesp              { get;set; }          
        public String dateTimeString            { get;set; }               
        public String SignedForByName           { get;set; }   
            
        public trackwrapper() {    
            tDate = '';
            tTime = '';
            location = '';
            activityDesp = ''; 
            dateTimeString = '';           
            SignedForByName = '';
        }        
    }
    // package list & product service wrapper class
    public List<plWrapper> packListWrapper          { get; set; }
    public class plWrapper {        
        public Package_List__c pl                   { get; set; }  
        public String commodityCode                 { get; set; }
        public Decimal declaredValue                { get; set; }        
        public String goodsDescription              { get; set; } 
        public Product2 psa    { get; set; }
        
        public plWrapper() {
            declaredValue = 0;
            commodityCode = '';
            goodsDescription = '';
            pl = new Package_List__c();
            psa = new Product2();
        }    
    }
    
    /* ------------------------- User Defined Function Reading XMLResponse -------------------------*/                
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {				String retValue = '';		try {           					while (reader.hasNext()) {					if (reader.getEventType() == XmlTag.START_ELEMENT) {				if (sxmltag == reader.getLocalName()) {					while (reader.hasNext()) {				if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 					else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); }				reader.next();
                        }
                    }
                } reader.next();
            }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }			return retValue;
    }
    /* ------------------------- User Defined Function for getting First Value -------------------------*/        
    public static String readXMLResponseFirstValue(XmlStreamReader reader, String sxmltag) {				String retValue = ''; 					try {           				Boolean resultAchieved = false;				while (reader.hasNext() && resultAchieved == false) {				if (reader.getEventType() == XmlTag.START_ELEMENT) {				if (sxmltag == reader.getLocalName()) {					while (reader.hasNext()) {				if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 				else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); resultAchieved = true; break; }					reader.next();
                        }
                    }
                } reader.next();
            }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }					return retValue;
    }   
    /* ------------------------- User Defined Function for getting responce only once -------------------------*/      
    public static String readXMLResponseOnce(XmlStreamReader reader, String sxmltag) {					String retValue = ''; 			try {           					while (reader.hasNext()) {					if (reader.getEventType() == XmlTag.START_ELEMENT) {					if (sxmltag == reader.getLocalName()) {						while (reader.hasNext()) {							if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 							else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue = reader.getText(); }						reader.next();
                        }
                    }
                } reader.next(); 
            }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }						return retValue;
    }    
    
     /* ------------------------- User Defined Function Reading XMLResponse For Shipment Digest -------------------------*/    
    public Static String Digest_Reader(XmlStreamReader reader,String sxmlTag) {					String retValue = '';					try {           					while (reader.hasNext()) {					if (reader.getEventType() == XmlTag.START_ELEMENT) {					if (sxmltag == reader.getLocalName()) {						while (reader.hasNext()) {					if (reader.getEventType() == XmlTag.END_ELEMENT) { break; } 					else if (reader.getEventType() == XmlTag.CHARACTERS) { retValue += reader.getText(); }					reader.next();
                        }
                    }
                } reader.next();
            }
        } catch(Exception e)  { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }				return retValue;
    }  
}