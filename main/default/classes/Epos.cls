public with sharing class Epos {
    
    @AuraEnabled(cacheable=true) 
    public static Wrapper fetchInitailDetails(){
        Wrapper wr=new Wrapper(); 
        try{ 
            ERP7__Employees__c currEmp;
            for(ERP7__Employees__c record:[Select Id,Name,ERP7__Employee_User__c from ERP7__Employees__c where ERP7__Employee_User__c =:Userinfo.getUserId() AND ERP7__Active__c=true Order by CreatedDate Asc Limit 1])
                currEmp=record;
            if(currEmp ==null) wr.error.add('Employee not found for current user, please select Employee'); else wr.currEmp=currEmp;
            
            Schema.DescribeFieldResult fieldResultOrdStatus = Order.Status.getDescribe();
            List < Schema.PicklistEntry > ordStatus = fieldResultOrdStatus.getPicklistValues();
            for(Schema.PicklistEntry f: ordStatus) wr.ordStatus.add(new SelectOptions(f.getValue(), f.getLabel()));
            
            Schema.DescribeFieldResult fieldResultShipmentType = Order.ERP7__Shipment_Type__c.getDescribe();
            List < Schema.PicklistEntry > ordShipType = fieldResultShipmentType.getPicklistValues();
            for(Schema.PicklistEntry f: ordShipType) wr.ShipmentType.add(new SelectOptions(f.getValue(), f.getLabel()));            
        }catch(Exception e){wr.error.add(e.getMessage()+'   Line:'+e.getLineNumber());}        
        return wr;
    }
    
    @AuraEnabled(cacheable=true)
    public static Wrapper fetchAccDetails(String accId){
        Wrapper wr=new Wrapper();
        try{
            Contact con;
            ERP7__Address__c billToAdd;
            ERP7__Address__c shipToAdd;        
            ERP7__Profiling__c custProfile;
            for(Account record:[Select Id,Name,ERP7__Account_Profile__c,ERP7__Account_Profile__r.Name,ERP7__Order_Profile__c,ERP7__Order_Profile__r.Name,ERP7__Order_Profile__r.ERP7__Channel__c,ERP7__Order_Profile__r.ERP7__Price_Book__c, ERP7__Order_Profile__r.ERP7__Account_Profile__c,ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c , AccountNumber,ERP7__Organisation__c,ERP7__Organisation_Business_Unit__c,ERP7__Available_Credit_Balance__c,ERP7__total_points__c,ERP7__Company__c,Website,Phone,Fax,ERP7__VAT_registration_number__c from Account where Id =:accId Limit 1])
                wr.acc=record;
            for(Contact record:[Select Id,Name,MobilePhone,Email,Phone,Title from Contact where AccountId =:accId Order By ERP7__Primary__c DESC, CreatedDate ASC Limit 1])
                con=record;
            if(con==null) wr.error.add('Contact Not Found'); else wr.con=con;
            for(ERP7__Address__c record:[Select id, Name, ERP7__Address_Line1__c, ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c, ERP7__State__c, ERP7__Postal_Code__c from ERP7__Address__c Where ERP7__Customer__c =:accId AND ERP7__Active__c = true AND ERP7__Is_Billing_Address__c = true order by ERP7__Primary__c DESC, CreatedDate ASC Limit 1])
                billToAdd=record;
            if(billToAdd == null) wr.error.add('Bill To Address Not Found'); else wr.billToAdd=billToAdd;
            for(ERP7__Address__c record:[Select id, Name, ERP7__Address_Line1__c, ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c, ERP7__State__c, ERP7__Postal_Code__c from ERP7__Address__c Where ERP7__Customer__c =:accId AND ERP7__Active__c = true AND ERP7__Is_Shipping_Address__c = true order by ERP7__Primary__c DESC, CreatedDate ASC Limit 1])
                shipToAdd=record;
            if(shipToAdd == null) wr.error.add('Ship To Address Not Found'); else wr.shipToAdd=shipToAdd;        
            for(ERP7__Profiling__c record:[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Account_Profile__c,ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where Id =:wr.acc.ERP7__Order_Profile__c AND ERP7__Active__c = True order by ERP7__Default__c DESC Limit 1])
                custProfile=record;
            if(custProfile != null) wr.custProfile=custProfile;
            
            wr.isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(wr.isMultiCurrency) wr.orderCurrency = (String) Database.Query('select CurrencyIsoCode from Account where Id=:accId Limit 1')[0].get('CurrencyIsoCode');
            wr.allCurrencies.add(new SelectOptions(wr.orderCurrency, wr.orderCurrency));        
            if(wr.isMultiCurrency) wr.allCurrencies=Epos.getCurrenyList('Account','CurrencyIsoCode');//Object and picklist_Field
        }catch(Exception e){wr.error.add(e.getMessage()+'   Line:'+e.getLineNumber());} 
        return wr;
    }
    
    public static List<SelectOptions> getCurrenyList(String Object_Name1,String Field_name){        
        List<SelectOptions> allCurrencies=new List<SelectOptions>();        
        //String Field_name='CurrencyIsoCode';
        Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(Object_Name1);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetObject.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            allCurrencies.add(new SelectOptions(a.getValue(), a.getLabel()));
        }
        return allCurrencies;
    }
    
    public class Wrapper{
        @AuraEnabled public List<String> error { get; set; }
        @AuraEnabled public Account acc { get; set; }
        @AuraEnabled public Contact con { get; set; }
        @AuraEnabled public ERP7__Address__c billToAdd { get; set; }
        @AuraEnabled public ERP7__Address__c shipToAdd { get; set; }  
        @AuraEnabled public ERP7__Employees__c currEmp { get; set; }
        @AuraEnabled public Date todayDate { get; set; }   
        @AuraEnabled public List<SelectOptions> ordStatus { get; set; }
        @AuraEnabled public List<SelectOptions> ShipmentType { get; set; }        
        @AuraEnabled public ERP7__Profiling__c custProfile { get; set; }
        @AuraEnabled public String orderCurrency { get; set; }
        @AuraEnabled public List<SelectOptions> allCurrencies { get; set; }
        @AuraEnabled public boolean isMultiCurrency { get; set; }
        public Wrapper(){
            error=new List<String>();
            acc=new Account();
            con=new Contact();
            billToAdd=new ERP7__Address__c();
            shipToAdd=new ERP7__Address__c();     
            currEmp=new ERP7__Employees__c();
            todayDate=date.today();  
            ordStatus=new List<SelectOptions>();
            ShipmentType=new List<SelectOptions>();
            custProfile=new ERP7__Profiling__c();
            orderCurrency=UserInfo.getDefaultCurrency();
            allCurrencies=new List<SelectOptions>();
            isMultiCurrency=false;
        }
    }
    
    Public class SelectOptions{
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        public SelectOptions(String value, String label){
            this.value=value;
            this.label=label;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact fetchContactDetails(String contId){
        return [Select Id,Name,MobilePhone,Email,Phone,Title from Contact where Id =:contId Limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static ERP7__Address__c billToAddress(String addId){
        return [Select id, Name, ERP7__Address_Line1__c, ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c, ERP7__State__c, ERP7__Postal_Code__c from ERP7__Address__c Where Id =:addId AND ERP7__Active__c = true AND ERP7__Is_Billing_Address__c = true Limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static ERP7__Address__c shipToAddress(String addId){
        return [Select id, Name, ERP7__Address_Line1__c, ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c, ERP7__State__c, ERP7__Postal_Code__c from ERP7__Address__c Where Id =:addId AND ERP7__Active__c = true AND ERP7__Is_Shipping_Address__c = true Limit 1]; 
    }
    
    @AuraEnabled(cacheable=true)
    public static ERP7__Profiling__c OrderProfile(String ordProfileId){
        return [Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Account_Profile__c,ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where Id =:ordProfileId AND ERP7__Active__c =true Limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static ERP7__Employees__c currentEmp(String empId){
        return [Select Id,Name,ERP7__Employee_User__c from ERP7__Employees__c where Id =:empId Limit 1];
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<ProductWrapper> initialProducts(String currProfile, String billToAddId, String shipToAddId,String searchItem,String OrderCurrency){
        
        //try{
        ERP7__Profiling__c profile = (ERP7__Profiling__c) JSON.deserialize(currProfile, ERP7__Profiling__c.class);
        if(profile.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == null) profile.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c='Destination';
        //ERP7__Profiling__c profile[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where Id =:ord.ERP7__Order_Profile__c Limit 1];
        Set<Id> siteIds=new Set<Id>();
        
        //ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
        List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                              where ERP7__Channel__c=:profile.ERP7__Channel__c and ERP7__Active__c=true];                
        if(DistributionChannels.size() > 0) {
            for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
            }
        }
        Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
        String searchProductBy='%'+searchItem+'%';
        List<Product2> searchProdList=[Select Id,Name from Product2 where (Name like: searchProductBy OR ProductCode like: searchProductBy) Limit 50];
        Set<Id> searchProdIds=new Set<Id>();
        for(Product2 pr:searchProdList)
            searchProdIds.add(pr.Id);
        List<PricebookEntry> pbe=new List<PricebookEntry>();
        Id Pricebook = profile.ERP7__Price_Book__c;
        if(searchProdIds.size() > 0){
            if(isMultiCurrency) pbe = Database.Query('Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Issue_Manufacturing_Order__c,Product2.ERP7__Is_Kit__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.QuantityUnitOfMeasure from PricebookEntry where Pricebook2Id =:Pricebook AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Id In: searchProdIds) AND IsActive=TRUE Limit 12');//AND CurrencyIsoCode =: OrderCurrency
        	if(!isMultiCurrency)pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Issue_Manufacturing_Order__c,Product2.ERP7__Is_Kit__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.QuantityUnitOfMeasure from PricebookEntry where Pricebook2Id =:profile.ERP7__Price_Book__c AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Id In: searchProdIds) AND IsActive=TRUE Limit 12];
        }
        if(searchItem == '') {
            if(isMultiCurrency) pbe = Database.Query('Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,CurrencyIsoCode,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Issue_Manufacturing_Order__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.QuantityUnitOfMeasure,Product2.ERP7__Subscribe__c from PricebookEntry where Pricebook2Id =:Pricebook AND Product2Id IN (Select Id From Product2 where IsActive=TRUE) AND IsActive=TRUE Limit 12');//AND CurrencyIsoCode =: OrderCurrency
            if(!isMultiCurrency) pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Issue_Manufacturing_Order__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.QuantityUnitOfMeasure,Product2.ERP7__Subscribe__c from PricebookEntry where Pricebook2Id =:profile.ERP7__Price_Book__c AND Product2Id IN (Select Id From Product2 where IsActive=TRUE) AND IsActive=TRUE Limit 12];
        }
        //List<PricebookEntry> pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.QuantityUnitOfMeasure from PricebookEntry where Pricebook2Id =:profile.ERP7__Price_Book__c AND Product2Id IN (Select Id From Product2 where IsActive=TRUE) AND IsActive=TRUE Limit 12];
        Set<Id> productIds=new Set<Id>();            
        for(PricebookEntry pb1 : pbe) productIds.add(pb1.Product2.Id);
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(productIds.size() > 0) {
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                            ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                            Where product__c In: productIds And
                                            Active__c = true And
                                            Warehouse__c In: siteIds And                                                 
                                            (ERP7__Number_of_Item_In_Stock__c > 0 or (ERP7__Number_of_Item_In_Stock__c < 0 AND Name = 'Serial Stock Holder'))
                                           ];
        }   
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        for(Id prId:productIds){
            Decimal stock=0;
            for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                if(prId == inven.product__c){
                    stock += inven.ERP7__Number_of_Item_In_Stock__c;
                }
            }
            stockView.put(prId,stock);                
        }
        
        //=========Discount Plan==============
        Integer currentQuantity=1;
        List <Tier_Discount_Allocation__c> TDAS= new List <Tier_Discount_Allocation__c>();
        TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                From Tier_Discount_Allocation__c
                Where Order_Profile__c = : profile.Id And
                ERP7__Price_Book__c =:profile.ERP7__Price_Book__c AND
                product__c In: productIds And
                Tier__r.Floor_Unit__c <= : currentQuantity And
                Tier__r.Ceiling_Unit__c >= : currentQuantity And
                Tier__r.Active__c = true And
                Discount_Plan__r.Active__c = true And
                Active__c = true
               ];
        
        List <Id> discountPlanIds = new List <Id>();
        for(Tier_Discount_Allocation__c TDA: TDAS) {
            if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
        }
        List <Discount_Plan__c> discounts = new List <Discount_Plan__c>();
        discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                     Status__c, Default_Discount_Value__c, Ceiling_Discount_Value__c, Floor_Discount_Value__c
                     From Discount_Plan__c
                     Where Id In: discountPlanIds And
                     Active__c = True
                    ];
        
        Map <Id,Discount_Plan__c> discountMap = new Map <Id,Discount_Plan__c>();
        for(Discount_Plan__c dis: discounts) {
            discountMap.put(dis.id, dis);
        }
        
        Map <Id,List <Discount_Plan__c>> discountPlans = new Map <Id,List <Discount_Plan__c>>();
        Map <Id,List <Tier_Discount_Allocation__c>> tierDiscAllocation = new Map <Id,List <Tier_Discount_Allocation__c>>();
        for(PricebookEntry pbPro: pbe) {           
            List <Discount_Plan__c> myDiscountPlans = new List <Discount_Plan__c>();
            List <Tier_Discount_Allocation__c> myTierDiscAlc = new List <Tier_Discount_Allocation__c>();
            for(Tier_Discount_Allocation__c TDA: TDAS) {
                if(pbPro.Product2.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                    myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                    myTierDiscAlc.add(TDA);
                }
            }
            discountPlans.put(pbPro.Product2.Id, myDiscountPlans);  
            tierDiscAllocation.put(pbPro.Product2.Id, myTierDiscAlc);
        }
        
        //==============/Discount Plan===========================
        
        //=============Taxex Calculation start=====================
        Date todayDate = system.today();
        List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
        profileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:profile.Id AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c = Null AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
        
        List<ERP7__Tax__c> productprofileTax = new List<ERP7__Tax__c>();
        productprofileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:profile.Id AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c != Null AND ERP7__Product__c In : productIds AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
        
        ERP7__Address__c ordBillToAdd;
        ERP7__Address__c ordShipToAdd;
        if(billToAddId != '' && billToAddId != null) ordBillToAdd=[Select Id,Name,ERP7__Active__c,ERP7__City__c,ERP7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:billToAddId AND ERP7__Active__c=true Limit 1];
        if(shipToAddId != '' && shipToAddId != null) ordShipToAdd=[Select Id,Name,ERP7__Active__c,ERP7__City__c,ERP7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:shipToAddId AND ERP7__Active__c=true Limit 1];
        
        String TaxPostalCode = '';
        String TaxCity = '';
        String TaxProvince = '';
        String TaxCountry = '';
        if(ordBillToAdd != Null){
            if(profile.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c =='Origin'){
                if(ordBillToAdd.ERP7__Postal_Code__c != Null && ordBillToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = ordBillToAdd.ERP7__Postal_Code__c;
                if(ordBillToAdd.ERP7__City__c != Null && ordBillToAdd.ERP7__City__c != '') TaxCity = ordBillToAdd.ERP7__City__c;
                if(ordBillToAdd.ERP7__State__c != Null && ordBillToAdd.ERP7__State__c != '') TaxProvince = ordBillToAdd.ERP7__State__c;
                if(ordBillToAdd.ERP7__Country__c != Null && ordBillToAdd.ERP7__Country__c != '') TaxCountry = ordBillToAdd.ERP7__Country__c;
            }
        }        
        
        if(ordShipToAdd != Null){
            if(profile.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c =='Destination'){    if(ordShipToAdd.ERP7__Postal_Code__c != Null && ordShipToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = ordShipToAdd.ERP7__Postal_Code__c;                if(ordShipToAdd.ERP7__City__c != Null && ordShipToAdd.ERP7__City__c != '') TaxCity = ordShipToAdd.ERP7__City__c;                if(ordShipToAdd.ERP7__State__c != Null && ordShipToAdd.ERP7__State__c != '') TaxProvince = ordShipToAdd.ERP7__State__c;                if(ordShipToAdd.ERP7__Country__c != Null && ordShipToAdd.ERP7__Country__c != '') TaxCountry = ordShipToAdd.ERP7__Country__c;
            }
        }        
        
        //=============Taxex Calculation end=====================
        
        List<ProductWrapper> prodWrap=new List<ProductWrapper>();
        for(PricebookEntry pb : pbe){         
            
            List<SelectOptions> options = new List<SelectOptions>();
            options.add(new SelectOptions('','--None--'));
            if(discountPlans.get(pb.Product2.Id) != null) {
                for(Discount_Plan__c dis: discountPlans.get(pb.Product2.Id)) {
                    options.add(new SelectOptions(dis.Id,dis.Name));
                }
            }            
            
            //=============taxes start==================
            ERP7__Tax__c tax;//=new ERP7__Tax__c();            
            Boolean taxFound = false;
            Decimal vatAmount=0;
            Decimal anotherTax=0;
            String taxId='';
            
            //Product Taxes
            if(productprofileTax.size() > 0){
                for(ERP7__Tax__c ProductTax : productprofileTax){                    
                    if(pb.Product2.Id == ProductTax.ERP7__Product__c){
                        
                        if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == TaxPostalCode && ProductTax.ERP7__Province__c == TaxProvince && ProductTax.ERP7__Country__c == TaxCountry)){
                            tax=ProductTax; taxId=ProductTax.Id; taxFound = true; break;                                                         
                        }
                        if(!taxFound){
                            if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__Province__c == TaxProvince && ProductTax.ERP7__Country__c == TaxCountry)){  tax=ProductTax; taxId=ProductTax.Id; taxFound = true; break; }
                        }
                        if(!taxFound){
                            if((TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__City__c == Null && ProductTax.ERP7__Province__c == Null && ProductTax.ERP7__Country__c == TaxCountry)){ tax=ProductTax; taxId=ProductTax.Id; taxFound = true; break; }
                        }
                        if(!taxFound){
                            if(ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__City__c == Null && ProductTax.ERP7__Province__c == Null && ProductTax.ERP7__Country__c == Null){   tax=ProductTax; taxId=ProductTax.Id;  taxFound = true;  break;  }
                        }
                    }
                }
            }
            //Profile Taxes
            if(!taxFound){                                      //When ProductTax will not available                
                if(profileTax.size() > 0){
                    for(ERP7__Tax__c profileTax1 : profileTax){
                        
                        if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == TaxPostalCode && profileTax1.ERP7__Province__c == TaxProvince && profileTax1.ERP7__Country__c == TaxCountry)){ tax=profileTax1; taxId=profileTax1.Id; taxFound = true; break;  }
                        if(!taxFound){
                            if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__Province__c == TaxProvince && profileTax1.ERP7__Country__c == TaxCountry)){ tax=profileTax1; taxId=profileTax1.Id;  taxFound = true; break; }
                        }
                        if(!taxFound){
                            if((TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__City__c == Null && profileTax1.ERP7__Province__c == Null && profileTax1.ERP7__Country__c == TaxCountry)){  tax=profileTax1; taxId=profileTax1.Id; taxFound = true;  break; }
                        }
                        if(!taxFound){
                            if(profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__City__c == Null && profileTax1.ERP7__Province__c == Null && profileTax1.ERP7__Country__c == Null){  tax=profileTax1;  taxId=profileTax1.Id; taxFound = true; break; }
                        }
                    }
                }                
            }
            //=============taxes end==================
            
            ProductWrapper pw=new ProductWrapper();
            pw.pbe=pb;
            if(pb.Product2.ERP7__Version__c != null) pw.version=pb.Product2.ERP7__Version__c;
            pw.CurrentDiscounts=options;
            pw.stock= stockView.get(pb.Product2.Id) != null ? stockView.get(pb.Product2.Id) : 0.00;
            pw.disPlans= discountPlans.get(pb.Product2.Id) != null ? discountPlans.get(pb.Product2.Id) : new List<Discount_Plan__c>();
            pw.tierDists= tierDiscAllocation.get(pb.Product2.Id)!= null ? tierDiscAllocation.get(pb.Product2.Id) : new List<Tier_Discount_Allocation__c>();
            pw.tax= tax != null ? tax : new ERP7__Tax__c();
            pw.vatAmount=vatAmount;
            pw.otherTax=anotherTax;
            pw.totalTaxAmount=vatAmount+anotherTax;
            prodWrap.add(pw);            
        }
        
        
        return prodWrap;
    }
    
    @AuraEnabled
    public static List<ProductWrapper> getDiscountPlan(String profileId,String prodId, Integer quantity){
        Set<Id> productIds=new Set<Id>();            
        productIds.add(prodId);
        
        List <Tier_Discount_Allocation__c> TDAS= new List <Tier_Discount_Allocation__c>();
        TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                From Tier_Discount_Allocation__c
                Where Order_Profile__c = : profileId And
                product__c In: productIds And
                Tier__r.Floor_Unit__c <= : quantity And
                Tier__r.Ceiling_Unit__c >= : quantity And
                Tier__r.Active__c = true And
                Discount_Plan__r.Active__c = true And
                Active__c = true
               ];
        
        List <Id> discountPlanIds = new List <Id>();
        for(Tier_Discount_Allocation__c TDA: TDAS) {
            if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
        }
        List <Discount_Plan__c> discounts = new List <Discount_Plan__c>();
        discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                     Status__c, Default_Discount_Value__c, Ceiling_Discount_Value__c, Floor_Discount_Value__c
                     From Discount_Plan__c
                     Where Id In: discountPlanIds And
                     Active__c = True
                    ];
        
        Map <Id,Discount_Plan__c> discountMap = new Map <Id,Discount_Plan__c>();
        for(Discount_Plan__c dis: discounts) {
            discountMap.put(dis.id, dis);
        }
        
        Map <Id,List <Discount_Plan__c>> discountPlans = new Map <Id,List <Discount_Plan__c>>();
        Map <Id,List <Tier_Discount_Allocation__c>> tierDiscAllocation = new Map <Id,List <Tier_Discount_Allocation__c>>();
        //for(PricebookEntry pbPro: pbe) {
        List <Discount_Plan__c> myDiscountPlans = new List <Discount_Plan__c>();
        List <Tier_Discount_Allocation__c> myTierDiscAlc = new List <Tier_Discount_Allocation__c>();
        for(Tier_Discount_Allocation__c TDA: TDAS) {
            if(prodId == TDA.product__c && TDA.Discount_Plan__c != Null) {
                myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                myTierDiscAlc.add(TDA);
            }
        }
        discountPlans.put(prodId, myDiscountPlans);  
        tierDiscAllocation.put(prodId, myTierDiscAlc);
        //}
        List<ProductWrapper> prWrapperList=new List<ProductWrapper>();
        //for(PricebookEntry pb : pbe){
        List<SelectOptions> options = new List<SelectOptions>();
        options.add(new SelectOptions('','--None--'));
        if(discountPlans.get(prodId) != null) {
            for(Discount_Plan__c dis: discountPlans.get(prodId)) {
                options.add(new SelectOptions(dis.Id,dis.Name));
            }
        }
        
        ProductWrapper prWrapper=new ProductWrapper();
        prWrapper.CurrentDiscounts=options;
        prWrapper.disPlans=(discountPlans.get(prodId)!= null)? discountPlans.get(prodId):new List<ERP7__Discount_Plan__c>();
        prWrapper.tierDists=(tierDiscAllocation.get(prodId)!= null)? tierDiscAllocation.get(prodId):new List<ERP7__Tier_Discount_Allocation__c>();
        
        prWrapperList.add(prWrapper);
        //pbe1.add(new pbeWrapper(new PricebookEntry(),'',new ERP7__Site__c(),'',options,0.00,(discountPlans.get(prodId)!= null)? discountPlans.get(prodId):new List<ERP7__Discount_Plan__c>(),(tierDiscAllocation.get(prodId)!= null)? tierDiscAllocation.get(prodId):new List<ERP7__Tier_Discount_Allocation__c>(),new ERP7__Tax__c(),'',0,0));    //      ,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):discountPlans.get(pb.Product2.Id),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):tierDiscAllocation.get(pb.Product2.Id)         
        
        //}
        return prWrapperList;
    }
    
    public class ProductWrapper{
        @AuraEnabled public PricebookEntry pbe                          { get; set; }
        @AuraEnabled public String version                              { get; set; }
        @AuraEnabled public List<SelectOptions> CurrentDiscounts       { get; set; }
        @AuraEnabled public Decimal stock                               { get; set; }
        @AuraEnabled public List<Discount_Plan__c> disPlans             { get; set; }
        @AuraEnabled public List<Tier_Discount_Allocation__c> tierDists { get; set; }
        @AuraEnabled public ERP7__Tax__c tax                            { get; set; }
        //@AuraEnabled public String taxId                              { get; set; }
        @AuraEnabled public Decimal vatAmount                           { get; set; }
        @AuraEnabled public Decimal otherTax                            { get; set; }
        @AuraEnabled public Decimal totalTaxAmount                          { get; set; }
        
        @AuraEnabled public Decimal quantity                            { get; set; }
        @AuraEnabled public Decimal minDiscount                         { get; set; }
        @AuraEnabled public Decimal maxDiscount                         { get; set; }
        @AuraEnabled public Decimal discountPercent                     { get; set; }
        @AuraEnabled public Decimal totalDiscount                       { get; set; }
        @AuraEnabled public Boolean isPercent                           { get; set; }
        @AuraEnabled public String discountPlan                         { get; set; }
        
        public ProductWrapper(){    
            pbe=new PricebookEntry();
            version='';
            quantity=1;
            minDiscount=0;
            maxDiscount=0;           
            stock=0;
            CurrentDiscounts=new List<SelectOptions>();
            discountPercent=0;
            totalDiscount=0;
            disPlans=new List<Discount_Plan__c>();
            tierDists= new List<Tier_Discount_Allocation__c>();
            tax=new ERP7__Tax__c();
            //taxId='';
            vatAmount=0;
            otherTax=0;
            totalTaxAmount=0;
            isPercent=true;
            discountPlan='';
        }
    }
    
    @AuraEnabled
    public static Decimal latestStock(String channelId, String prodId){        
        Set<Id> siteIds=new Set<Id>();        
        List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                              where ERP7__Channel__c=:channelId and ERP7__Active__c=true];                
        if(DistributionChannels.size() > 0) {
            for(Distribution_Channel__c DC: DistributionChannels) {
                siteIds.add(DC.Site__c);
            }
        }
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();        
        WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                        ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                        Where product__c =: prodId And
                                        Active__c = true And
                                        Warehouse__c In: siteIds And                                                 
                                        ERP7__Number_of_Item_In_Stock__c > 0
                                       ];        
        Decimal stock=0;
        for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){            
            stock += inven.ERP7__Number_of_Item_In_Stock__c;            
        }
        return stock;
    }
    
    @AuraEnabled
    public static OrderAndLinesWrapper saveOrderAndLines(String ord, String ordItems,String prodList, List<String> itemsToDel){
        system.debug('ord value'+ord);
        OrderAndLinesWrapper wr=new OrderAndLinesWrapper();
        try{
            Set<String> itemsToDel1= new Set<String>();
            itemsToDel1.addAll(itemsToDel);
            List<OrderItem> ordItemToDel=[Select Id from OrderItem where Id In:itemsToDel1];
            
            //DML Operation
            if(ordItemToDel.size() > 0 && Schema.sObjectType.OrderItem.isDeletable()) delete ordItemToDel;
            
            
            Order order2Upsert= (Order) JSON.deserialize(ord, Order.class);
            
            //DML Operation
            
            if (Schema.sObjectType.Order.isUpdateable() && Schema.sObjectType.Order.isCreateable()) {
                if(order2Upsert.ERP7__Shipment_Type__c == null || order2Upsert.ERP7__Shipment_Type__c == '' || order2Upsert.ERP7__Shipment_Type__c == '--None--') { order2Upsert.ERP7__Shipment_Type__c = 'UPS'; order2Upsert.ERP7__Shipment_Preference_Speed__c = '--None--';}
                System.debug('Oder Details to Upsert~>'+order2Upsert);
                upsert order2Upsert;
                
            }
            
            List<OrderItem> orderItem2Upsert= (List<OrderItem>) JSON.deserialize(ordItems, List<OrderItem>.class);
            
            Set<Id> prodIds= (Set<Id>) JSON.deserialize(prodList, Set<Id>.class);
            /*Set<Id> prodIds=new Set<Id>();
            for(OrderItem ordItem:orderItem2Upsert){
            prodIds.add(ordItem.Product2Id);
            }*/
            List<PricebookEntry> pbeList=[Select Id,Name,Product2Id from PricebookEntry where Pricebook2Id =: order2Upsert.Pricebook2Id AND Product2Id =:prodIds];
            Map<Id,Id> proPbeMap=new Map<Id,Id>();
            for(PricebookEntry pb:pbeList) proPbeMap.put(pb.Product2Id,pb.Id);
            
            for(OrderItem ordItem:orderItem2Upsert){
                if(ordItem.Id == null && Schema.sObjectType.OrderItem.fields.OrderId.isCreateable()) ordItem.OrderId=order2Upsert.Id; else system.debug('no access to order in orditem~> updateable~>'+Schema.sObjectType.OrderItem.fields.OrderId.isUpdateable()+' createable~~>'+Schema.sObjectType.OrderItem.fields.OrderId.isCreateable());
                if(ordItem.Id == null && Schema.sObjectType.OrderItem.fields.PricebookEntryId.isCreateable()) ordItem.PricebookEntryId=proPbeMap.get(ordItem.Product2Id);
            }
            
             //DML Operation
            if(orderItem2Upsert.size() > 0 && Schema.sObjectType.OrderItem.isUpdateable() && Schema.sObjectType.OrderItem.isCreateable())
                upsert orderItem2Upsert;
                wr.ord=order2Upsert;
            //wr.ordItems=orderItem2Upsert;
            
            /*wr.ord=[Select Id,Name,ERP7__Active__c,EffectiveDate,ERP7__Payments_Status__c,OrderReferenceNumber,ERP7__Expected_Date__c,ERP7__Shipment_Type__c,Status,Description,ERP7__Is_Back_Order__c,ERP7__Is_Pre_Order__c,ERP7__Issue_Invoice__c,ERP7__Is_Closed__c,
            AccountId,Account.Name,Account.ERP7__Account_Profile__c,Account.ERP7__Order_Profile__c,Account.ERP7__Order_Profile__r.Name,Account.ERP7__Order_Profile__r.ERP7__Channel__c,Account.ERP7__Order_Profile__r.ERP7__Price_Book__c, 
            Account.ERP7__Order_Profile__r.ERP7__Account_Profile__c,Account.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c , Account.AccountNumber,Account.ERP7__Organisation__c,Account.ERP7__Organisation_Business_Unit__c,Account.ERP7__Available_Credit_Balance__c,Account.ERP7__total_points__c,ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__Employee__r.ERP7__Employee_User__c,
            ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Email,ERP7__Contact__r.Phone,ERP7__Bill_To_Address__c,ERP7__Bill_To_Address__r.Name,ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, 
            ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Bill_To_Address__r.ERP7__Country__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Postal_Code__c,
            ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c,
            ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c,ERP7__Order_Profile__c,ERP7__Order_Profile__r.Name,ERP7__Order_Profile__r.ERP7__Channel__c,ERP7__Order_Profile__r.ERP7__Price_Book__c,
            ERP7__Order_Profile__r.ERP7__Account_Profile__c,ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c,ERP7__Project__c,ERP7__Project__r.Name,ERP7__Order_Discount__c,ERP7__Order_Discount_Description__c,ERP7__Order_Amount__c,ERP7__Amount_Paid__c,ERP7__Due_Amount__c
            from Order where Id=:order2Upsert.Id];
            
            wr.ordItems=[Select Id,Product2Id,UnitPrice,Product2.QuantityUnitOfMeasure,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,
            ERP7__Version__c,Quantity,ERP7__Discount_Plan__c,ERP7__Discount_Plan__r.Name,ERP7__Discount_Plan__r.ERP7__Active__c,ERP7__Discount_Plan__r.ERP7__Floor_Discount_Percentage__c,ERP7__Discount_Plan__r.ERP7__Ceiling_Discount_Percentage__c,
            ERP7__Discount_Plan__r.ERP7__Default_Discount_Percentage__c,ERP7__Discount_Plan__r.ERP7__Floor_Discount_Value__c,ERP7__Discount_Plan__r.ERP7__Ceiling_Discount_Value__c,ERP7__Discount_Plan__r.ERP7__Default_Discount_Value__c,
            ERP7__VAT_Amount__c,ERP7__Other_Tax__c,ERP7__Tax__c,ERP7__Tax__r.Name,ERP7__Tax__r.ERP7__Active__c,ERP7__Tax__r.ERP7__Apply_Tax_On__c,ERP7__Tax__r.ERP7__City__c,ERP7__Tax__r.ERP7__Country__c,ERP7__Tax__r.ERP7__Effective_Date__c,
            ERP7__Tax__r.ERP7__Expiry_Date__c,ERP7__Tax__r.ERP7__Other_Tax_Rate__c,ERP7__Tax__r.ERP7__Other_Tax_Type__c,ERP7__Tax__r.ERP7__Postal_Code__c,ERP7__Tax__r.ERP7__Product__c,ERP7__Tax__r.ERP7__Province__c,ERP7__Tax__r.ERP7__Tax_Rate__c,ERP7__Tax__r.ERP7__Type__c,
            ERP7__Discount_Amount__c,ERP7__Discount_Percent__c
            from OrderItem where Id In:orderItem2Upsert];*/        
        }catch(Exception e){wr.error.add(e.getMessage()+'   Line:'+e.getLineNumber());}
        return wr;
    }
    
    @AuraEnabled
    public static OrderAndLinesWrapper fetchOrderDetails(String OrderId){
        OrderAndLinesWrapper wr=new OrderAndLinesWrapper();
        if(String.isNotEmpty(OrderId)){
        
        wr.ord=[Select Id,Name,ERP7__Active__c,EffectiveDate,ERP7__Payments_Status__c,OrderReferenceNumber,ERP7__Expected_Date__c,ERP7__Shipment_Type__c,Status,Description,ERP7__Is_Back_Order__c,ERP7__Is_Pre_Order__c,ERP7__Issue_Invoice__c,ERP7__Is_Closed__c,
                AccountId,Account.Name,Account.ERP7__Account_Profile__c,Account.ERP7__Account_Profile__r.Name,Account.ERP7__Order_Profile__c,Account.ERP7__Order_Profile__r.Name,Account.ERP7__Order_Profile__r.ERP7__Channel__c,Account.ERP7__Order_Profile__r.ERP7__Price_Book__c, 
                Account.ERP7__Order_Profile__r.ERP7__Account_Profile__c,Account.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c , Account.AccountNumber,Account.ERP7__Organisation__c,Account.ERP7__Organisation_Business_Unit__c,Account.ERP7__Available_Credit_Balance__c,Account.ERP7__total_points__c,Account.ERP7__Company__c,Account.Website,Account.Phone,Account.Fax,Account.ERP7__VAT_registration_number__c,
                ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Email,ERP7__Contact__r.Phone,ERP7__Bill_To_Address__c,ERP7__Bill_To_Address__r.Name,ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, 
                ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Bill_To_Address__r.ERP7__Country__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Postal_Code__c,
                ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c,
                ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c,ERP7__Order_Profile__c,ERP7__Order_Profile__r.Name,ERP7__Order_Profile__r.ERP7__Channel__c,ERP7__Order_Profile__r.ERP7__Price_Book__c,
                ERP7__Order_Profile__r.ERP7__Account_Profile__c,ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c,ERP7__Project__c,ERP7__Project__r.Name,ERP7__Order_Discount__c,ERP7__Order_Discount_Description__c,ERP7__Order_Amount__c,ERP7__Amount_Paid__c,ERP7__Due_Amount__c,ERP7__Organisation__c,ERP7__Organisation__r.Name,ERP7__Organisation_Business_Unit__c,
                ERP7__Total_Quantity__c,ERP7__Picked_Quantity__c,ERP7__Packed_Quantity__c,ERP7__Shipped_Quantity__c,ERP7__UPS_Service__c,ERP7__Estimated_Delivery_Date__c,ERP7__Tracking_Number__c,ERP7__Estimated_Shipping_Amount__c,ERP7__Shipping_VAT__c,ERP7__Total_Shipping_Amount__c,ERP7__Total_Tax_Amount__c,ERP7__TotalDiscount__c,ERP7__Shipping_Discount__c,ERP7__Sub_Total__c,TotalAmount
                from Order where Id=:OrderId];
        
        wr.ordItems=[Select Id,Product2Id,UnitPrice,Product2.QuantityUnitOfMeasure,Product2.Name,Product2.ProductCode,Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,
                     ERP7__Version__c,Quantity,ERP7__Discount_Plan__c,ERP7__Discount_Plan__r.Name,ERP7__Discount_Plan__r.ERP7__Active__c,ERP7__Discount_Plan__r.ERP7__Floor_Discount_Percentage__c,ERP7__Discount_Plan__r.ERP7__Ceiling_Discount_Percentage__c,Product2.ERP7__Is_Kit__c,
                     ERP7__Discount_Plan__r.ERP7__Default_Discount_Percentage__c,ERP7__Discount_Plan__r.ERP7__Floor_Discount_Value__c,ERP7__Discount_Plan__r.ERP7__Ceiling_Discount_Value__c,ERP7__Discount_Plan__r.ERP7__Default_Discount_Value__c,
                     ERP7__VAT_Amount__c,ERP7__Other_Tax__c,ERP7__Tax__c,ERP7__Tax__r.Name,ERP7__Tax__r.ERP7__Active__c,ERP7__Tax__r.ERP7__Apply_Tax_On__c,ERP7__Tax__r.ERP7__City__c,ERP7__Tax__r.ERP7__Country__c,ERP7__Tax__r.ERP7__Effective_Date__c,
                     ERP7__Tax__r.ERP7__Expiry_Date__c,ERP7__Tax__r.ERP7__Other_Tax_Rate__c,ERP7__Tax__r.ERP7__Other_Tax_Type__c,ERP7__Tax__r.ERP7__Postal_Code__c,ERP7__Tax__r.ERP7__Product__c,ERP7__Tax__r.ERP7__Province__c,ERP7__Tax__r.ERP7__Tax_Rate__c,ERP7__Tax__r.ERP7__Type__c,
                     ERP7__Discount_Amount__c,ERP7__Discount_Percent__c,ERP7__Product_Subscription_Plan_Allocation__c,ERP7__Product_Subscription_Plan_Allocation__r.Name,ERP7__Start_Date__c,ERP7__Month_Duration__c,ERP7__Order_Delivery_Frequency__c
                     from OrderItem where OrderId =:OrderId Order By ERP7__Sort_Order__c];
        
        wr.invoiceList=[Select Id,Name,RecordTypeId,RecordType.DeveloperName,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Total_Due__c,ERP7__Final_Due_Amount__c,ERP7__Posted__c,ERP7__Posted_Date__c,
                        ERP7__Amount_Paid__c,ERP7__Paid_Amount__c,ERP7__Paid__c,ERP7__Contact__c,ERP7__Credit_Note__c,ERP7__Credit_Note_Issued__c,ERP7__Order_S__c,ERP7__Account__c from ERP7__Invoice__c where ERP7__Order_S__c =:OrderId Order By CreatedDate Desc];
        
        wr.paymentList=[Select Id,Name,ERP7__Payment_Type__c,ERP7__Payment_Date__c,ERP7__Total_Amount__c from ERP7__Payment__c where ERP7__Order__c =:OrderId Order By CreatedDate Desc];
        
        Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(isMultiCurrency) wr.orderCurrency = (String) Database.Query('select CurrencyIsoCode from Order where Id=:OrderId Limit 1')[0].get('CurrencyIsoCode');
        wr.allCurrencies.add(new SelectOptions(wr.orderCurrency, wr.orderCurrency));
        if(wr.isMultiCurrency) wr.allCurrencies=Epos.getCurrenyList('Order','CurrencyIsoCode');//Object and picklist_Field
        
        wr.CRList=[Select Id,Name,ERP7__Coupon__c,ERP7__Coupon__r.Name,ERP7__Redemption_Date__c,ERP7__Coupon_Issued__c,ERP7__Coupon_Issued__r.Name,ERP7__Value__c from ERP7__Coupon_Redemption__c where ERP7__Order__c =:OrderId];

        wr.shipments=[Select Id,Name,RecordTypeId,RecordType.Name,RecordType.DeveloperName,ERP7__Tracking_Number__c,ERP7__Shipment_Delivery_Date__c,ERP7__Status__c from ERP7__Shipment__c where ERP7__Order__c =:OrderId];
        }
        return wr;        
    }
    
    public class OrderAndLinesWrapper{
        @AuraEnabled public List<String> error                          { get; set; }
        @AuraEnabled public Order ord                                   { get; set; }
        @AuraEnabled public List<OrderItem> ordItems                    { get; set; }
        @AuraEnabled public List<ERP7__Invoice__c> invoiceList          { get; set; }
        @AuraEnabled public List<ERP7__Payment__c> paymentList          { get; set; }
        @AuraEnabled public String orderCurrency                        { get; set; }
        @AuraEnabled public List<SelectOptions> allCurrencies           { get; set; }
        @AuraEnabled public boolean isMultiCurrency                     { get; set; }
        @AuraEnabled public List<ERP7__Coupon_Redemption__c> CRList     { get; set; }
        @AuraEnabled public List<ERP7__Shipment__c> shipments           { get; set; }
        public OrderAndLinesWrapper(){
            error=new List<String>();
            ord=new Order();
            ordItems=new List<OrderItem>();
            invoiceList=new List<ERP7__Invoice__c>();
            paymentList=new List<ERP7__Payment__c>();
            orderCurrency=UserInfo.getDefaultCurrency();
            allCurrencies=new List<SelectOptions>();
            isMultiCurrency=false;
            CRList=new List<ERP7__Coupon_Redemption__c>();
            shipments = new List<ERP7__Shipment__c>();
        }
    }
    
    @AuraEnabled
    public static cardDetails fetchInitialCardDetails(){
        cardDetails comW=new cardDetails();
        //comW.CountyList.add(new SelectOptions('--None--', ''));
        Schema.DescribeFieldResult fieldResultCnty = ERP7__Address__c.ERP7__State__c.getDescribe();
        List < Schema.PicklistEntry > cnty = fieldResultCnty.getPicklistValues();
        for(Schema.PicklistEntry f: cnty) comW.CountyList.add(new SelectOptions(f.getValue(), f.getLabel()));
        
        Schema.DescribeFieldResult fieldResultCntry = ERP7__Address__c.ERP7__Country__c.getDescribe();
        List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
        for(Schema.PicklistEntry f: cntry) comW.CountryList.add(new SelectOptions(f.getValue(), f.getLabel()));
        
        Schema.DescribeFieldResult fieldResultCardtype= ERP7__Payment_Method__c.ERP7__CardType__c.getDescribe();
        List < Schema.PicklistEntry > cardtype = fieldResultCardtype.getPicklistValues();
        for(Schema.PicklistEntry f: cardtype)  comW.CardTypes.add(new SelectOptions(f.getValue(), f.getLabel()));
        
        comW.ExpiryMonth.add(new SelectOptions('01','01'));
        comW.ExpiryMonth.add(new SelectOptions('02','02'));
        comW.ExpiryMonth.add(new SelectOptions('03','03'));
        comW.ExpiryMonth.add(new SelectOptions('04','04'));
        comW.ExpiryMonth.add(new SelectOptions('05','05'));
        comW.ExpiryMonth.add(new SelectOptions('06','06'));
        comW.ExpiryMonth.add(new SelectOptions('07','07'));
        comW.ExpiryMonth.add(new SelectOptions('08','08'));
        comW.ExpiryMonth.add(new SelectOptions('09','09'));
        comW.ExpiryMonth.add(new SelectOptions('10','10'));
        comW.ExpiryMonth.add(new SelectOptions('11','11'));
        comW.ExpiryMonth.add(new SelectOptions('12','12'));
        Integer curMonth = system.today().year();
        for(integer i=1;i<10;i++) comW.ExpiryYear.add(new SelectOptions(curMonth + '',curMonth++ + ''));
        
        List<ERP7__Credentials__c> paymentSetup=[Select Id,Name from ERP7__Credentials__c Where ERP7__Active__c =: true AND ERP7__Type__c='Payment'];
        for(ERP7__Credentials__c cr:paymentSetup) comW.paymentGateways.add(new SelectOptions(cr.Id,cr.Name));
        
        return comW;
    }
    
    public class cardDetails{
        @AuraEnabled public List<SelectOptions> CountyList { get; set; }
        @AuraEnabled public List<SelectOptions> CountryList { get; set; }
        @AuraEnabled public List<SelectOptions> CardTypes { get; set; }
        @AuraEnabled public List<SelectOptions> ExpiryMonth { get; set; }
        @AuraEnabled public List<SelectOptions> ExpiryYear { get; set; }
        @AuraEnabled public List<SelectOptions> paymentGateways { get; set; }
        @AuraEnabled public List<SelectOptions> accountsType { get; set; }
        public cardDetails(){
            CountyList=new List<SelectOptions>();
            CountryList=new List<SelectOptions>();
            CardTypes=new List<SelectOptions>();
            ExpiryMonth=new List<SelectOptions>();
            ExpiryYear=new List<SelectOptions>();
            paymentGateways=new List<SelectOptions>();
            accountsType=new List<SelectOptions>();
        }
    }
    
    @AuraEnabled
    public static OrderAndLinesWrapper fetchOrdDetailsForClone(String OrderId){
        OrderAndLinesWrapper wr=new OrderAndLinesWrapper();
        try{            
            wr.ord=[Select ERP7__Active__c,EffectiveDate,ERP7__Payments_Status__c,OrderReferenceNumber,ERP7__Expected_Date__c,ERP7__Shipment_Type__c,Status,Description,ERP7__Is_Back_Order__c,ERP7__Is_Pre_Order__c,ERP7__Issue_Invoice__c,ERP7__Is_Closed__c,
                    AccountId,Account.Name,Account.ERP7__Account_Profile__c,Account.ERP7__Account_Profile__r.Name,Account.ERP7__Order_Profile__c,Account.ERP7__Order_Profile__r.Name,Account.ERP7__Order_Profile__r.ERP7__Channel__c,Account.ERP7__Order_Profile__r.ERP7__Price_Book__c, 
                    Account.ERP7__Order_Profile__r.ERP7__Account_Profile__c,Account.ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c , Account.AccountNumber,Account.ERP7__Organisation__c,Account.ERP7__Organisation_Business_Unit__c,Account.ERP7__Available_Credit_Balance__c,Account.ERP7__total_points__c,Account.ERP7__Company__c,Account.Website,Account.Phone,Account.Fax,Account.ERP7__VAT_registration_number__c,
                    ERP7__Employee__c,ERP7__Employee__r.Name,ERP7__Employee__r.ERP7__Employee_User__c, ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Email,ERP7__Contact__r.Phone,ERP7__Bill_To_Address__c,ERP7__Bill_To_Address__r.Name,ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, 
                    ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Bill_To_Address__r.ERP7__Country__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Postal_Code__c,
                    ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name,ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c,
                    ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c,ERP7__Order_Profile__c,ERP7__Order_Profile__r.Name,ERP7__Order_Profile__r.ERP7__Channel__c,ERP7__Order_Profile__r.ERP7__Price_Book__c,
                    ERP7__Order_Profile__r.ERP7__Account_Profile__c,ERP7__Order_Profile__r.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c,ERP7__Project__c,ERP7__Project__r.Name,ERP7__Order_Amount__c,ERP7__Due_Amount__c,ERP7__Organisation__c,ERP7__Organisation__r.Name,ERP7__Organisation_Business_Unit__c,
                    ERP7__Total_Quantity__c
                    from Order where Id=:OrderId];
            
            system.debug('Order Details~>::'+wr.ord);
            
            wr.ordItems=[Select Id,Product2Id,UnitPrice,Product2.QuantityUnitOfMeasure,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,
                         ERP7__Version__c,Quantity,ERP7__Discount_Plan__c,ERP7__Discount_Plan__r.Name,ERP7__Discount_Plan__r.ERP7__Active__c,ERP7__Discount_Plan__r.ERP7__Floor_Discount_Percentage__c,ERP7__Discount_Plan__r.ERP7__Ceiling_Discount_Percentage__c,
                         ERP7__Discount_Plan__r.ERP7__Default_Discount_Percentage__c,ERP7__Discount_Plan__r.ERP7__Floor_Discount_Value__c,ERP7__Discount_Plan__r.ERP7__Ceiling_Discount_Value__c,ERP7__Discount_Plan__r.ERP7__Default_Discount_Value__c,
                         ERP7__VAT_Amount__c,ERP7__Other_Tax__c,ERP7__Tax__c,ERP7__Tax__r.Name,ERP7__Tax__r.ERP7__Active__c,ERP7__Tax__r.ERP7__Apply_Tax_On__c,ERP7__Tax__r.ERP7__City__c,ERP7__Tax__r.ERP7__Country__c,ERP7__Tax__r.ERP7__Effective_Date__c,
                         ERP7__Tax__r.ERP7__Expiry_Date__c,ERP7__Tax__r.ERP7__Other_Tax_Rate__c,ERP7__Tax__r.ERP7__Other_Tax_Type__c,ERP7__Tax__r.ERP7__Postal_Code__c,ERP7__Tax__r.ERP7__Product__c,ERP7__Tax__r.ERP7__Province__c,ERP7__Tax__r.ERP7__Tax_Rate__c,ERP7__Tax__r.ERP7__Type__c,
                         ERP7__Discount_Amount__c,ERP7__Discount_Percent__c
                         from OrderItem where OrderId =:OrderId Order By ERP7__Sort_Order__c];
            
            system.debug('Order Items~>::'+wr.ordItems);
            
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(isMultiCurrency) wr.orderCurrency = (String) Database.Query('select CurrencyIsoCode from Order where Id=:OrderId Limit 1')[0].get('CurrencyIsoCode');
            wr.allCurrencies.add(new SelectOptions(wr.orderCurrency, wr.orderCurrency));
            if(wr.isMultiCurrency) wr.allCurrencies=Epos.getCurrenyList('Order','CurrencyIsoCode');//Object and picklist_Field
            
            
        }catch(Exception e){wr.error.add(e.getMessage()+'   Line No:'+e.getLineNumber());}
        return wr;
    }

    @AuraEnabled
    public static ERP7__Invoice__c updateInvoice(String invId, boolean postedValue){
        ERP7__Invoice__c inv=[Select Id,Name,RecordTypeId,RecordType.DeveloperName,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Total_Due__c,ERP7__Final_Due_Amount__c,ERP7__Posted__c,ERP7__Posted_Date__c,
                        ERP7__Amount_Paid__c,ERP7__Paid_Amount__c,ERP7__Paid__c,ERP7__Contact__c,ERP7__Credit_Note__c,ERP7__Credit_Note_Issued__c,ERP7__Order_S__c,ERP7__Account__c from ERP7__Invoice__c where Id=:invId];
        
        inv.Id=invId;
        if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isUpdateable()) inv.ERP7__Posted__c=postedValue;
        if(postedValue && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted_Date__c.isCreateable()) inv.ERP7__Posted_Date__c=System.today();
        else if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted_Date__c.isCreateable()) inv.ERP7__Posted_Date__c=null;
        
        //DML Operation.
        if(Schema.sObjectType.ERP7__Invoice__c.isUpdateable()) update inv;
        return inv;
    }
    
    @AuraEnabled
    public static String createCardPayment(String payments, String paymentMethods, String CVV, String billAddress, String selectedGateway, String myCur, String invAndAmount,Integer resCode) {     //String invList,List<String> selInvList  (Multiple Invoice payment)
        String ErrorMsgPayment = '';
        Address__c billingAddress = (Address__c) JSON.deserialize(billAddress, Address__c.class);
        List<ERP7__Invoice__c> invIdList = (List<ERP7__Invoice__c>) JSON.deserialize(invAndAmount, List<ERP7__Invoice__c>.class);
        
        try{
            
            
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(paymentMethods, ERP7__Payment_Method__c .class);
            
            
            String rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP)) payment.RecordTypeId = rTypeP;                 
            
            ERP7__Credentials__c credentialSetup;
            for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                          From ERP7__Credentials__c Where ERP7__Active__c =: true AND Id =:selectedGateway Limit 1])
                credentialSetup=crd;
            
            
            if(credentialSetup == null){ ErrorMsgPayment='Paymnet Credential Setup is not completed.';return ErrorMsgPayment;}
            
            if(credentialSetup.ERP7__Bank_COA_ID__c != null ){ payment.ERP7__Payment_Account__c  = credentialSetup.ERP7__Bank_COA_ID__c; }
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', methodId = '', comAppend = '', ipstring = '';
            if(payment.ERP7__First_Name__c != Null) FirstName = payment.ERP7__First_Name__c;
            if(payment.Last_Name__c != Null) LastName = payment.ERP7__Last_Name__c;
            if(payment.Email_Address__c != Null) Email = payment.ERP7__Email_Address__c;
            if(payment.Address_Line1__c != Null) Address_Line1 = payment.ERP7__Address_Line1__c;
            if(payment.Address_Line2__c != Null) Address_Line2 = payment.ERP7__Address_Line2__c;        
            if(payment.City__c != Null) City = payment.ERP7__City__c;
            if(payment.State__c != Null) State = payment.ERP7__State__c;
            if(payment.Country__c != Null) Country = payment.ERP7__Country__c;
            if(payment.Zipcode__c != Null) Zipcode = payment.ERP7__Zipcode__c;    
            
            Card_Number = PaymentMethod.ERP7__Card_Number__c;
            Card_Type  = PaymentMethod.ERP7__CardType__c;
            Expiry_Month = PaymentMethod.ERP7__Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.ERP7__Card_Expiration_Year__c;
                      
            myCurrency = myCur; 
            Amount = String.valueof(payment.ERP7__Total_Amount__c);
            
            ipstring = '';
            String response_1;
            String resStatus;
            if(credentialSetup.Name.containsIgnoreCase('Paypal')){
            //if(credentialSetup.Name == 'Paypal'){containsIgnoreCase
                // Instantiate a new http object
                Http h = new Http();
                
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                
                // The webservice url -  Pass in the endpoint to be used using the string url
                String url = String.valueof(credentialSetup.ERP7__URL__c);
                String soapXML;
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(credentialSetup.ERP7__Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentialSetup.ERP7__Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentialSetup.ERP7__Password_Transkey__c));
                if(userData != null) credentialSetup.ERP7__Username_Login__c = userData.toString();
                if(passwordData != null) credentialSetup.ERP7__Password_Transkey__c = passwordData.toString();
                
                soapXML =  System.label.PayPalAPI;
                soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<Username>' + credentialSetup.ERP7__Username_Login__c.escapeXml() + '</Username>';
                soapXML += '<Password>' + credentialSetup.ERP7__Password_Transkey__c.escapeXml() + '</Password>';
                soapXML += '<Signature>' + credentialSetup.ERP7__Signature__c.escapeXml() + '</Signature>';
                soapXML += '<Subject/>';
                soapXML += '</Credentials></RequesterCredentials></SOAP-ENV:Header><SOAP-ENV:Body><DoDirectPaymentReq xmlns="urn:ebay:api:PayPalAPI">';
                soapXML += '<DoDirectPaymentRequest><Version xmlns=urn:ebay:apis:eBLBaseComponents">84.00</Version>';
                soapXML += '<DoDirectPaymentRequestDetails xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<PaymentAction>Sale</PaymentAction><PaymentDetails><OrderTotal currencyID=' + myCurrency.escapeXml()+ '>' + Amount.escapeXml() + '</OrderTotal></PaymentDetails>';
                soapXML += '<IPAddress>' + ipstring.escapeXml() + '</IPAddress><CreditCard><CreditCardType>' + Card_Type.escapeXml() + '</CreditCardType><CreditCardNumber>' + Card_Number.escapeXml() + '</CreditCardNumber>';
                soapXML += '<ExpMonth>' + Expiry_Month.escapeXml() + '</ExpMonth><ExpYear>' + Expiry_Year.escapeXml() + '</ExpYear><CVV2>' + CVV.escapeXml() + '</CVV2>';
                soapXML += '<CardOwner><Payer>' + Email.escapeXml() + '</Payer><PayerStatus></PayerStatus><PayerName><FirstName>' + FirstName.escapeXml() + '</FirstName><LastName>' + LastName.escapeXml() + '</LastName></PayerName>';
                soapXML += '<Address><Street1>' + Address_Line1.escapeXml() + '</Street1><Street2>' + Address_Line2.escapeXml() + '</Street2><CityName>' + City.escapeXml() + '</CityName>';
                soapXML += '<StateOrProvince>' + State.escapeXml() + '</StateOrProvince><Country>' + Country.escapeXml() + '</Country><PostalCode>' + Zipcode.escapeXml() + '</PostalCode><Phone></Phone></Address></CardOwner></CreditCard>';
                soapXML += '</DoDirectPaymentRequestDetails></DoDirectPaymentRequest></DoDirectPaymentReq></SOAP-ENV:Body></SOAP-ENV:Envelope>';
                
                req.setBody(soapXML);
                req.setEndpoint(url);
                req.setMethod('POST');
                req.setHeader('Content-length', '1753' );
                req.setHeader('Content-Type', 'text/xml;charset=UTF-8'); 
                req.setHeader('SOAPAction','');
                req.setHeader('Host','api-3t.sandbox.paypal.com');
                req.setTimeout(20000);
                HttpResponse res = new HttpResponse();
                if(!Test.isRunningTest()) res = h.send(req);
                String xml = res.getBody();
                XmlStreamReader reader = res.getXmlStreamReader();
                Status = readXMLResponse(reader,'Ack');   reader = res.getXmlStreamReader();     CorrID = readXMLResponse(reader, 'CorrelationID');    reader = res.getXmlStreamReader();    CVV2 = readXMLResponse(reader, 'CVV2Code');    reader = res.getXmlStreamReader();  AVSCode = readXMLResponse(reader, 'AVSCode'); rawResponse = xml;     reader = res.getXmlStreamReader();   ErrMsg = readXMLResponse(reader, 'LongMessage');    reader = res.getXmlStreamReader();    sErrMsg = readXMLResponse(reader, 'ShortMessage');   reader = res.getXmlStreamReader();  ErrCode= readXMLResponse(reader, 'ErrorCode'); reader = res.getXmlStreamReader();   transid = readXMLResponse(reader, 'TransactionID');              
                
                payment.ERP7__AVS_Code__c = AVSCode;  payment.ERP7__CVV2_Code__c = CVV2; payment.ERP7__Transaction_Status__c = Status;  payment.ERP7__Error_Code__c = ErrCode;   payment.ERP7__Transaction_ID__c = transid;  payment.ERP7__sError__c = sErrMsg;   payment.ERP7__Correlation_ID__c = CorrID;   payment.ERP7__Error_Message__c = ErrMsg;
                
            } 
            else if(credentialSetup.Name.containsIgnoreCase('Authorize')){   // if(credentialSetup.Name == 'Authorize.Net' || credentialSetup.Name == 'Authorize'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(credentialSetup.ERP7__Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentialSetup.ERP7__Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentialSetup.ERP7__Password_Transkey__c));
                if(userData != null) credentialSetup.ERP7__Username_Login__c = userData.toString();
                if(passwordData != null) credentialSetup.ERP7__Password_Transkey__c = passwordData.toString();
                string url = credentialSetup.ERP7__URL__c;
                
                String Address = billingAddress.ERP7__Address_Line1__c +' '+ billingAddress.ERP7__Address_Line2__c; //' '+ City +' '+ Country;
                string expiryDate = Expiry_Year + '-' + Expiry_Month;
                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                soapXML += '<merchantAuthentication>';
                soapXML += '<name>' + credentialSetup.ERP7__Username_Login__c.escapeXml() + '</name>';
                soapXML += '<transactionKey>' + credentialSetup.ERP7__Password_Transkey__c.escapeXml() + '</transactionKey>';
                soapXML += '</merchantAuthentication>';
                soapXML += '<transactionRequest>'; 
                soapXML += '<transactionType>authCaptureTransaction</transactionType>';
                soapXML += '<amount>' + Amount.escapeXml() + '</amount>';
                soapXML += '<payment>';
                soapXML += '<creditCard>';
                soapXML += '<cardNumber>' + Card_Number.escapeXml() + '</cardNumber>';
                soapXML += '<expirationDate>' + expiryDate.escapeXml() + '</expirationDate>';
                soapXML += '<cardCode>' + CVV.escapeXml() + '</cardCode>';
                soapXML += '</creditCard>';
                soapXML += '</payment>';
                soapXML += '<billTo>';
                soapXML += '<firstName>' + FirstName.escapeXml() + '</firstName>';
                soapXML += '<lastName>' + LastName.escapeXml() + '</lastName>';
                soapXML += '<address>' + address.escapeXml() + '</address>';
                soapXML += '<city>' + billingAddress.ERP7__City__c.escapeXml() + '</city>';
                soapXML += '<state>' + billingAddress.ERP7__State__c.escapeXml() + '</state>';
                soapXML += '<zip>' + billingAddress.ERP7__Postal_Code__c.escapeXml() + '</zip>';
                soapXML += '<country>' + billingAddress.ERP7__Country__c.escapeXml() + '</country>';
                soapXML += '</billTo>';
                soapXML += '</transactionRequest>';
                soapXML += '</createTransactionRequest>';
                
                HttpRequest reqr = new HttpRequest();
                Http hr = new Http();
                
                reqr.setBody(soapXML);   
                reqr.setMethod('POST');
                reqr.setEndpoint(url);
                reqr.setHeader('Content-length', '2000');
                reqr.setHeader('Content-Type', 'text/xml');
                
                if(Test.isRunningTest()){
                    if(resCode == 3) response_1 = '<createTransactionResponse xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="https://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Error</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>'+resCode+'</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                    else response_1 = '<createTransactionResponse xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="https://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>'+resCode+'</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                    //response_1 = '<createTransactionResponse xmlns:xsi="'+Label.POSLightningLabel2+'-instance" xmlns:xsd="'+Label.POSLightningLabel2+'" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                } else{
                    HttpResponse resr = hr.send(reqr);     response_1 = soapXML;    response_1 = resr.getBody();   resStatus = resr.getStatus();                        
                }
                System.debug('response_1:'+response_1);
                if (response_1 != null) {
                    string resultCode = response_1.substringBetween('<resultCode>', '</resultCode>');
                    string responseCode = response_1.substringBetween('<responseCode>', '</responseCode>');
                    System.debug('resultCode:'+resultCode);
                    System.debug('responseCode:'+responseCode);
                    if (resultCode == 'Ok') {
                        if (responseCode == '1'){
                            //'--- Inside Approved.'
                            string description = response_1.substringBetween('<description>', '</description>');
                            transId = response_1.substringBetween('<transId>', '</transId>');
                            string transHash = response_1.substringBetween('<transHash>', '</transHash>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.ERP7__Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.ERP7__Transaction_Status__c = 'Approved';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.ERP7__sError__c = description;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                                payment.ERP7__Status__c = 'Paid';
                            }    
                        }
                        
                        if (responseCode == '2'){
                            //'--- Inside Declined.'
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                            
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.ERP7__Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.ERP7__Transaction_Status__c = 'Declined';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.ERP7__sError__c = errorMessage;
                            }
                        }
                        
                        if (responseCode == '4'){
                            //'--- Inside Held for Review.'
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.ERP7__Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.ERP7__Transaction_Status__c = 'Held for Review';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.ERP7__sError__c = description;
                            }
                        }
                        
                    }else {
                        if (responseCode == '3'){
                            //'--- Inside Error.'
                            string description = response_1.substringBetween('<description>', '</description>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                            
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.ERP7__Transaction_Status__c = 'Error';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.ERP7__sError__c = errorMessage;
                            }
                        }
                    } 
                } else payment.ERP7__sError__c = 'Null Response.';  
                
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.ERP7__Payment_Gateway__c = 'Authorize.Net'; }
                
                
            } 
            else if(credentialSetup.Name.containsIgnoreCase('Stripe')){
                
                //String surl = 'amount='+Integer.valueOf(Amount)*100+'&currency='+myCurrency;
                //system.debug('surl-->'+surl);
                
                String body = 'card[exp_month]='+Expiry_Month+'&card[exp_year]='+Expiry_Year+'&card[number]='+Card_Number.escapeXml()+'&card[cvc]='+CVV.escapeXml()+'&card[name]='+FirstName.escapeXml()+' '+LastName.escapeXml()+'&amount='+Integer.valueOf(Amount)+'&currency='+myCurrency+'&payment_method_types=[card]';
                //String requestEndPoint = 'https://api.stripe.com/v1/payment_intents';
                string requestEndPoint = credentialSetup.ERP7__URL__c;
                HttpRequest Sreq = new HttpRequest(); 
                Sreq.setEndpoint(requestEndPoint);  
                Sreq.setMethod('POST');    
                Sreq.setTimeout(2000); 
                Sreq.setHeader('Content-Type','application/x-www-form-urlencoded');  
                //system.label.Stripe;
                String token = 'Bearer '+ system.label.Stripe;//'sk_test_51KEDeNSCjruNLUAtn6dU2NkHn1JmwUCSqU42MILpmvTcYFPUTVNnv3sHR9k0cl6k7pG2RcKGcXK0rH0ct1GayLYD00CGjCpnjn';
                Sreq.setHeader('Authorization',token);  
                Sreq.setBody(body);
                Http http = new Http(); 
                httpResponse response=http.send(Sreq);   
                String response_2 = response.getBody(); 
                Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_2); 
                system.debug('results-->'+results);
                if(results!=null) payment.ERP7__Transaction_Status__c = 'Approved';
                
            }
            else   return ErrorMsgPayment = 'Please select correct payment gateway';
            
            if(Schema.sObjectType.Payment__c.fields.ERP7__Transaction_Status__c.isCreateable() && Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable() && (payment.ERP7__Transaction_Status__c == 'Completed' || payment.ERP7__Transaction_Status__c == 'SuccessWithWarning' || payment.ERP7__Transaction_Status__c == 'Success' || payment.ERP7__Transaction_Status__c == 'Approved')){
            if(Schema.sObjectType.Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable())payment.ERP7__Type__c = 'Debit';
            if(Schema.sObjectType.Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable())Payment.ERP7__Payment_Type__c = 'Card';
            if(Schema.sObjectType.Payment__c.fields.ERP7__Payment_Date__c.isCreateable() && Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable())payment.ERP7__Payment_Date__c=System.today();
                
               System.debug('Is Payment cmng or not::~>'+payment);
                   
                //DML Operation
                
                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable())upsert payment;
                
                
                if(payment.Id != null)ErrorMsgPayment='Payment Created Successfully';
                System.debug('invIdList.size():'+invIdList.size());
                if(payment.Id != null && invIdList.size() >= 1){
                    List<ERP7__Payment_Applied_on_Invoice__c> PAIList=new List<ERP7__Payment_Applied_on_Invoice__c>();
                    for(ERP7__Invoice__c inv:invIdList){
                        System.debug('inv:'+inv);
                        ERP7__Payment_Applied_on_Invoice__c pai=new ERP7__Payment_Applied_on_Invoice__c();
                        
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Amount__c.isCreateable())pai.ERP7__Amount__c=inv.ERP7__Invoice_Amount__c;
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Applied_Date__c.isCreateable())pai.ERP7__Applied_Date__c=payment.ERP7__Payment_Date__c;
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Invoice__c.isCreateable())pai.ERP7__Invoice__c=inv.Id;//Master detailed 
                        if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isCreateable())pai.ERP7__Payment__c=payment.Id;//Master detailed 
                        if( Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Type__c.isCreateable())pai.ERP7__Type__c='Debit';
                        PAIList.add(pai);
                    }
                     //DML Operation
                    if(PAIList.size() > 0 && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable())
                    insert PAIList;
                    
                } 
                //if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Order.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Order.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable() && Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isUpdateable()){upsert payment;}else{ErrorMsgPayment ='Not allowed to upsert payment';}  
            } else { 
                if(payment.ERP7__sError__c != Null) ErrorMsgPayment = payment.ERP7__sError__c;
            }
            return ErrorMsgPayment;   
        }catch(exception ex){
            ErrorMsgPayment = ex.getMessage();
            ErrorMsgPayment += ' Line No: '+ex.getLineNumber();
            ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString();
            System.debug('ErrorMsgPayment:'+ErrorMsgPayment);
            return ErrorMsgPayment;
        }
    }
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        string retValue;    // Read through the XML
        while(reader.hasNext()) { if (reader.getEventType() == XmlTag.START_ELEMENT) { if (reader.getLocalName() == sxmltag) { reader.next(); if (reader.getEventType() == XmlTag.characters) {  retValue = reader.getText(); }  }  }  reader.next(); } return retValue;//retValue.escapeXml();
    }

    @AuraEnabled
    public static cardDetails fetchInitialBankDetails(){
        cardDetails cd=new cardDetails();
        cd.accountsType.add(new SelectOptions('', '--None--'));
        Schema.DescribeFieldResult fieldResultCardtype= ERP7__Payment__c.ERP7__Account_Type__c.getDescribe();
        List < Schema.PicklistEntry > cardtype = fieldResultCardtype.getPicklistValues();
        for(Schema.PicklistEntry f: cardtype)  cd.accountsType.add(new SelectOptions(f.getValue(), f.getLabel()));
        return cd;
    }

    @AuraEnabled
    public static String createBankOrCashPayment(String payments,String invAndAmount,String paymentType){
        String errorMsg='';
        List<ERP7__Invoice__c> invIdList = (List<ERP7__Invoice__c>) JSON.deserialize(invAndAmount, List<ERP7__Invoice__c>.class);
        ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(payments, ERP7__Payment__c .class);
        
        if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Date__c.isCreateable()) payment.ERP7__Payment_Date__c=System.today();
        String rTypeP;
        if(paymentType == 'Bank') rTypeP= RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Bank_Payments');
        if(paymentType == 'Cash') rTypeP= RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Cash_Payments');
        if(String.isNotEmpty(rTypeP)) Payment.RecordTypeId = rTypeP; 
        
        //DML Operation
         System.debug('Payment Details to insert ::~>'+Payment);
         if(Schema.sObjectType.ERP7__Payment__c.isCreateable()) insert Payment;
        
        if(Payment.Id != null) errorMsg='Payment Created Successfully';
        System.debug('invIdList.size():'+invIdList.size());
        System.debug('Payment.Id:'+Payment.Id);
        if(Payment.Id != null && invIdList.size() > 1){
            List<ERP7__Payment_Applied_on_Invoice__c> PAIList=new List<ERP7__Payment_Applied_on_Invoice__c>();
            for(ERP7__Invoice__c inv:invIdList){
                ERP7__Payment_Applied_on_Invoice__c pai=new ERP7__Payment_Applied_on_Invoice__c();
                
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Amount__c.isCreateable())pai.ERP7__Amount__c=inv.ERP7__Invoice_Amount__c;
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Applied_Date__c.isCreateable())pai.ERP7__Applied_Date__c=payment.ERP7__Payment_Date__c;
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Invoice__c.isCreateable())pai.ERP7__Invoice__c=inv.Id;//Master detailed field
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Payment__c.isCreateable())pai.ERP7__Payment__c=payment.Id;//Master detailed Field
                if(Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.fields.ERP7__Type__c.isCreateable())pai.ERP7__Type__c='Debit';
                PAIList.add(pai);
            }
            
            //DML Operations
            if(PAIList.size() > 0 && Schema.sObjectType.ERP7__Payment_Applied_on_Invoice__c.isCreateable())insert PAIList;   
        } 

        return errorMsg;
    }

    @AuraEnabled
    public static Decimal initialLoyalityPayment(String custId, String currOrg){
        Decimal Points_Per_Unit_Amount=0;
        List<Loyalty_Card__c> clubCard = [Select id, Name, ERP7__Active__c, ERP7__Active_Points__c, ERP7__Loyalty_Program__c, ERP7__Points_Per_Unit_Amount__c, ERP7__Contact__c, ERP7__Customer__c, ERP7__Start_date__c,
                                        ERP7__Expiration_Date__c, ERP7__Status__c, ERP7__Total_Points_Credited__c, ERP7__Total_Points_Debited__c,
                                        ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c
                                        From ERP7__Loyalty_Card__c Where
                                        ERP7__Customer__c = : custId And ERP7__Active__c = true And ERP7__Status__c = 'Active' And ERP7__Start_date__c <= : System.today() And Expiration_Date__c >= : System.today() And ERP7__Organisation__c = : currOrg Limit 1];
        if(clubCard.size() > 0){ Points_Per_Unit_Amount = (clubCard[0].ERP7__Active_Points__c/clubCard[0].ERP7__Points_Per_Unit_Amount__c).setScale(2);  }
        return Points_Per_Unit_Amount;
    }
    
    @AuraEnabled
    public static List<CNWrapper> applyCreditInitial(String accId){
        List<CNWrapper> cnWrList=new List<CNWrapper>();
        if(String.isNotEmpty(accId)){
            List<ERP7__Credit_Note__c> cnList =[select id, Name, ERP7__Credit__c, ERP7__Debit__c,  ERP7__Order__c,ERP7__Order__r.Name, ERP7__Account__c, ERP7__Balance__c from ERP7__Credit_Note__c where ERP7__Balance__c>0 and ERP7__Account__c= :accId order by CreatedDate DESC];
            for(ERP7__Credit_Note__c cn:cnList){
                CNWrapper cnWr=new CNWrapper();
                cnWr.credNote=cn;
                cnWrList.add(cnWr);
            }
        }        
        return cnWrList;     
    }
    public class CNWrapper{
        @AuraEnabled public ERP7__Credit_Note__c credNote {get;set;}
        @AuraEnabled public Decimal debitAmount {get;set;}
        public CNWrapper(){
            debitAmount = 0;
            credNote = new ERP7__Credit_Note__c();
        }
    }
    
    @Auraenabled
    public static String applyCreditToInvoice(String inv, String creditNotes,Decimal totalDebitAmount){
        String message='';
        try{
            List<CNWrapper> cnList=(List<CNWrapper>)JSON.deserialize(creditNotes, List<CNWrapper>.class);
            ERP7__Invoice__c invoices = (ERP7__Invoice__c)JSON.deserialize(inv, ERP7__Invoice__c.class);
            
            
            PreventRecursiveLedgerEntry.proceed = false;
            
            //DML Operation
            if(Schema.SObjectType.ERP7__Invoice__c.isUpdateable())update invoices;
            
            List<ERP7__Credit_Note_Applied_on_Invoice__c> appliedNotes = new List<ERP7__Credit_Note_Applied_on_Invoice__c>();
            List<ERP7__Credit_Note__c> cn2Update = new List<ERP7__Credit_Note__c>();
            List<Account> account2Update = new List<Account>();
            
            //Update Order
            if(invoices.ERP7__Order_S__c != null){
                Order ord = [select Id, Name, ERP7__Amount_Paid__c from Order where Id=:invoices.ERP7__Order_S__c];
                if(ord.ERP7__Amount_Paid__c==null)
                    if(Schema.sObjectType.Order.fields.ERP7__Amount_Paid__c.isUpdateable())ord.ERP7__Amount_Paid__c = totalDebitAmount;
                else 
                    if(Schema.sObjectType.Order.fields.ERP7__Amount_Paid__c.isUpdateable())ord.ERP7__Amount_Paid__c = ord.ERP7__Amount_Paid__c + totalDebitAmount;
              //DML Operation.
              if(Schema.sObjectType.Order.isUpdateable())
                update ord;
            }              
            
            if(cnList!=null && cnList.size()>0) {
                for(CNWrapper cwrap : cnList){
                    if(cwrap!=null){
                        if(cwrap.debitAmount > 0){
                            ERP7__Credit_Note_Applied_on_Invoice__c capplied = new ERP7__Credit_Note_Applied_on_Invoice__c();
                            
                            if(Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.fields.ERP7__Amount__c.isCreateable()
                               && Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.fields.ERP7__Amount__c.isUpdateable())
                            capplied.ERP7__Amount__c = cwrap.debitAmount;
                            
                            if(Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.fields.ERP7__Credit_Note__c.isCreateable())//Master Detail
                            capplied.ERP7__Credit_Note__c = cwrap.credNote.Id;//Master detail 
                            
                            if(Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.fields.ERP7__Invoice__c.isCreateable() 
                             && Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.fields.ERP7__Invoice__c.isUpdateable())
                            capplied.ERP7__Invoice__c = invoices.Id;
                            
                            if(Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.fields.Name.isCreateable() 
                              && Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.fields.Name.isUpdateable())
                            capplied.Name = invoices.Name + ' ' + cwrap.credNote.Name;
                            
                            appliedNotes.add(capplied);
                            
                            if(cwrap.credNote.ERP7__Debit__c!=null && Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Debit__c.isUpdateable()) cwrap.credNote.ERP7__Debit__c = cwrap.credNote.ERP7__Debit__c + cwrap.debitAmount;
                            else 
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Debit__c.isUpdateable())
                                cwrap.credNote.ERP7__Debit__c = cwrap.debitAmount;
                            cn2Update.add(cwrap.credNote);
                        }
                    }
                }
            }
              //DML Operation.
            if(appliedNotes.size()>0 && Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Credit_Note_Applied_on_Invoice__c.isUpdateable())
              upsert appliedNotes;
            
            
            if(cn2Update.size()>0 )  {
                PreventRecursiveLedgerEntry.testCasesTransactions = true;
                //DML Operation. 
                if(Schema.sObjectType.ERP7__Credit_Note__c.isUpdateable())
                update cn2Update;
            }
            //Update Account
            if(invoices!=null){
                if(invoices.ERP7__Account__c!=null){
                    Account acc2update = [select Id, Name, ERP7__Debit_Balance__c from Account where Id =:invoices.ERP7__Account__c];
                    if(acc2update.ERP7__Debit_Balance__c==null && Schema.sObjectType.Account.fields.ERP7__Debit_Balance__c.isUpdateable()) acc2update.ERP7__Debit_Balance__c = totalDebitAmount;
                    else 
                        if(Schema.sObjectType.Account.fields.ERP7__Debit_Balance__c.isUpdateable())acc2update.ERP7__Debit_Balance__c = acc2update.ERP7__Debit_Balance__c + totalDebitAmount;
                    system.debug('acc2update'+acc2update);
                    ERP7.PreventRecursiveLedgerEntry.proceed = false;
                    
                    //DML Operation.
                    if(Schema.sObjectType.Account.isUpdateable())
                    update acc2update;
                }
            }
            message='Credit Applied Successfully';
        }catch(Exception e){ message=e.getMessage()+' '+e.getLineNumber(); }
        
        return message;
    }
    
    @AuraEnabled
    public static String ApplyCoupons(String ord, String custId, String Coupon) {
        String message='';
        
        Order order2Update = (Order) JSON.deserialize(ord, Order .class);
        
        List<OrderItem> ordItems = [Select Id, Product2Id, Quantity, OrderId, UnitPrice, ERP7__Coupon__c, ERP7__Total_Price__c,ERP7__Base_Price__c From OrderItem Where OrderId =: order2Update.id];
        List<OrderItem> ordItems2upsert = new List<OrderItem>();
        Map<Id, OrderItem> proOrdItem = new Map<Id, OrderItem>(); 
        for(OrderItem ordItm : ordItems){
            proOrdItem.put(ordItm.Product2Id,ordItm);
        }        
        
        try {            
            List<ERP7__Coupon_Issued__c> CI = [Select Id, Name, ERP7__Product__c, ERP7__Account__c, ERP7__Coupon__c, ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c, ERP7__Coupon__r.Name, ERP7__Coupon__r.ERP7__Start_Date__c, ERP7__Coupon__r.ERP7__End_Date__c, ERP7__Issued_Date__c, ERP7__Value__c, ERP7__Voucher_Amount__c, ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c, ERP7__Coupon__r.RecordType.Name, ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c
                                               From ERP7__Coupon_Issued__c 
                                               Where ERP7__Coupon__r.Name =:Coupon And 
                                               ERP7__Coupon__r.ERP7__Start_Date__c <= Today And 
                                               ERP7__Coupon__r.ERP7__End_Date__c >= Today And 
                                               (ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c = Null Or ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c <= :order2Update.ERP7__Order_Amount__c) 
                                               Limit 1];
            
            if(CI.size() > 0){
                //Particular custom redeems the coupon or not
                List< ERP7__Coupon_Redemption__c > CR = [Select Id, Name, ERP7__Account__c, ERP7__Coupon__c From ERP7__Coupon_Redemption__c Where ERP7__Account__c =:custId And ERP7__Coupon__c =: CI[0].ERP7__Coupon__c];
                
                if(order2Update.ERP7__Due_Amount__c <= 0){  message= 'Invalid Order Amount'; }
                else if(CR.size() > 0 || 
                         CI[0].ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c == [Select Id, Name, ERP7__Account__c, ERP7__Coupon__c From ERP7__Coupon_Redemption__c Where ERP7__Coupon__c =: CI[0].ERP7__Coupon__c].size() ||
                         (CI[0].ERP7__Product__c != Null && !proOrdItem.containsKey(CI[0].ERP7__Product__c)) || 
                         (CI[0].ERP7__Account__c != Null && !(CI[0].ERP7__Account__c == order2Update.AccountId))){ message = 'Coupon Already Redeemed/Invalid';
                        }else{
                            ERP7__Coupon_Redemption__c newCR = new ERP7__Coupon_Redemption__c();
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.Name.isCreateable()) newCR.Name = (proOrdItem.containsKey(CI[0].ERP7__Product__c))? proOrdItem.get(CI[0].ERP7__Product__c).Id : order2Update.Name; 
                            System.debug('custId:'+custId);
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Account__c.isCreateable()) newCR.ERP7__Account__c = custId;
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon__c.isCreateable()) newCR.ERP7__Coupon__c = CI[0].ERP7__Coupon__c;
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon_Issued__c.isCreateable()) newCR.ERP7__Coupon_Issued__c = CI[0].Id;
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Redemption_Date__c.isCreateable()) newCR.ERP7__Redemption_Date__c = system.Today();
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Order__c.isCreateable()) newCR.ERP7__Order__c = order2Update.Id;
                            
                            if(CI[0].ERP7__Voucher_Amount__c > 0) 
                            { 
                                if(proOrdItem.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product')
                                {  
                                    newCR.ERP7__Order_Product__c = proOrdItem.get(CI[0].ERP7__Product__c).Id;
                                    
                                    if(CI[0].ERP7__Voucher_Amount__c <= proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c)   
                                    newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                                    
                                    else  newCR.ERP7__Value__c = proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c;
                                }
                                else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Order')
                                {
                                    if(CI[0].ERP7__Voucher_Amount__c <= order2Update.ERP7__Order_Amount__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                                    else newCR.ERP7__Value__c = order2Update.ERP7__Order_Amount__c;
                                }
                                else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Shipping')
                                {
                                    if(CI[0].ERP7__Voucher_Amount__c <= order2Update.ERP7__Total_Shipping_Amount__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                                    else newCR.ERP7__Value__c = order2Update.ERP7__Total_Shipping_Amount__c;
                                }
                            }
                            else if(CI[0].ERP7__Value__c > 0)
                            {
                                if(proOrdItem.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){  
                                    newCR.ERP7__Value__c =  (proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c == 0)? 0 : (CI[0].ERP7__Value__c * proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c)/100;    newCR.ERP7__Order_Product__c = proOrdItem.get(CI[0].ERP7__Product__c).Id;  
                                }
                                else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Order')   newCR.ERP7__Value__c =  (order2Update.ERP7__Order_Amount__c == 0)? 0 : (CI[0].ERP7__Value__c * order2Update.ERP7__Order_Amount__c)/100;
                                else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Shipping') newCR.ERP7__Value__c =  (order2Update.ERP7__Total_Shipping_Amount__c == Null || order2Update.ERP7__Total_Shipping_Amount__c == 0)? 0 : (CI[0].ERP7__Value__c * order2Update.ERP7__Total_Shipping_Amount__c)/100;
                            }
                            
                            if(newCR.ERP7__Value__c > 0){
                                if(newCR.ERP7__Value__c > order2Update.ERP7__Due_Amount__c)   newCR.ERP7__Value__c = order2Update.ERP7__Due_Amount__c; 
                                
                                //DML Operation
                                
                                if(Schema.SObjectType.ERP7__Coupon_Redemption__c.isCreateable() && Schema.SObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable())insert newCR;
                                
                                if(newCR.Id != null)  message='Coupon Redeemed Successfully';
                                if(CI[0].ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c){
                                    //New Logic
                                    if(proOrdItem.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){
                                        if(Schema.sObjectType.OrderItem.fields.ERP7__Coupon__c.isUpdateable() && Schema.sObjectType.OrderItem.fields.ERP7__Coupon__c.isCreateable())
                                        {
                                          
                                            proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Coupon__c = newCR.ERP7__Value__c; if(proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c != Null)   proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c = proOrdItem.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c - newCR.ERP7__Value__c;
                                            ordItems2upsert.add(proOrdItem.get(CI[0].ERP7__Product__c));
                                        }
                                    }
                                    else 
                                        if( Schema.sObjectType.Order.fields.ERP7__Coupon_Discount__c.isCreateable() &&  Schema.sObjectType.Order.fields.ERP7__Coupon_Discount__c.isUpdateable())
                                        
                                            order2Update.ERP7__Coupon_Discount__c = newCR.ERP7__Value__c;
                                     
                                    
                                    //DML Operation.
                                    if(Schema.sObjectType.Order.isUpdateable() && Schema.sObjectType.Order.isCreateable())
                                    upsert order2Update;
                                    
                                    
                                    
                                    //DML Operation.
                                    if(ordItems2upsert.size() > 0 && Schema.sObjectType.OrderItem.isUpdateable() && Schema.sObjectType.OrderItem.isCreateable())  
                                    upsert ordItems2upsert;
                                    
                                   
                                    
                                }
                                //Why are we creating Credit Note here
                                /*else{
                                    ERP7__Credit_Note__c newCN = new ERP7__Credit_Note__c();
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.Name.isCreateable()){newCN.Name = newCR.Name;} 
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Active__c.isCreateable()){newCN.ERP7__Active__c = true;} 
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Order__c.isCreateable()){newCN.ERP7__Order__c = order2Update.Id;} 
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Amount__c.isCreateable()){newCN.ERP7__Amount__c = newCR.ERP7__Value__c;} 
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Credit__c.isCreateable()){newCN.ERP7__Credit__c = newCR.ERP7__Value__c;} 
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Applied_Date__c.isCreateable()){ newCN.ERP7__Applied_Date__c = system.Today();}
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isCreateable()){ newCN.ERP7__Account__c = custId;}
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Contact__c.isCreateable()){newCN.ERP7__Contact__c = order2Update.ERP7__Contact__c;} 
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Coupon_Redemption__c.isCreateable()){newCN.ERP7__Coupon_Redemption__c = newCR.Id; } 
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Paid__c.isCreateable()){newCN.ERP7__Paid__c = true;}
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Organisation__c.isCreateable()){newCN.ERP7__Organisation__c = order2Update.ERP7__Organisation__c;} 
                                    
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable()){insert newCN;}else{message ='Not allowed to insert credit notes';}
                                    
                                    Order currentOrder = order2Update;   
                                    ERP7__Payment__c Payment = new ERP7__Payment__c();   
                                    payment.ERP7__Order__c = currentOrder.Id;  
                                    payment.ERP7__Accounts__c = currentOrder.AccountId;
                                    if(currentOrder.Contact__r.FirstName != Null) payment.First_Name__c = currentOrder.Contact__r.FirstName;
                                    if(currentOrder.Contact__r.LastName != Null) payment.Last_Name__c = currentOrder.Contact__r.LastName;
                                    if(currentOrder.Contact__r.Email != Null) payment.Email_Address__c = currentOrder.Contact__r.Email;
                                    if(currentOrder.Bill_To_Address__r.Address_Line1__c != Null) payment.Address_Line1__c = currentOrder.Bill_To_Address__r.Address_Line1__c;
                                    if(currentOrder.Bill_To_Address__r.Address_Line2__c != Null) payment.Address_Line2__c = currentOrder.Bill_To_Address__r.Address_Line2__c;
                                    if(currentOrder.Bill_To_Address__r.City__c != Null) payment.City__c = currentOrder.Bill_To_Address__r.City__c;
                                    if(currentOrder.Bill_To_Address__r.State__c != Null) payment.State__c = currentOrder.Bill_To_Address__r.County__c;
                                    if(currentOrder.Bill_To_Address__r.Country__c != Null) payment.Country__c = currentOrder.Bill_To_Address__r.Country__c;
                                    if(currentOrder.Bill_To_Address__r.Postal_Code__c != Null) payment.Zipcode__c = currentOrder.Bill_To_Address__r.Postal_Code__c; 
                                    payment.Account__c = currentOrder.Organisation__c;  
                                    payment.Organisation_Business_Unit__c = currentOrder.Organisation_Business_Unit__c;  
                                    payment.ERP7__Credit_Note__c = newCN.Id;  
                                    payment.ERP7__Type__c = 'Debit';  
                                    Payment.ERP7__Payment_Type__c = 'Coupon';  
                                    payment.ERP7__Total_Amount__c = newCN.ERP7__Amount__c;  
                                    payment.ERP7__Status__c = 'Paid';
                                    String rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                                    if(String.isNotEmpty(rTypeP)){  payment.RecordTypeId = rTypeP;   }
                                    //DMLManager.upsertAsUser(payment); 
                                    List<ERP7__Payment__c> pays = new List<ERP7__Payment__c>();
                                    pays.add(payment);
                                    
                                    ERP7__Payment__c Payment1 = new ERP7__Payment__c(); 
                                    Payment1.ERP7__Order__c = currentOrder.Id;  
                                    Payment1.Accounts__c = currentOrder.AccountId;
                                    if(currentOrder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentOrder.Contact__r.FirstName;
                                    if(currentOrder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentOrder.Contact__r.LastName;
                                    if(currentOrder.Contact__r.Email != Null) Payment1.Email_Address__c = currentOrder.Contact__r.Email;
                                    if(currentOrder.Bill_To_Address__r.Address_Line1__c != Null) Payment1.Address_Line1__c = currentOrder.Bill_To_Address__r.Address_Line1__c;
                                    if(currentOrder.Bill_To_Address__r.Address_Line2__c != Null) Payment1.Address_Line2__c = currentOrder.Bill_To_Address__r.Address_Line2__c;
                                    if(currentOrder.Bill_To_Address__r.City__c != Null) Payment1.City__c = currentOrder.Bill_To_Address__r.City__c;
                                    if(currentOrder.Bill_To_Address__r.State__c != Null) Payment1.State__c = currentOrder.Bill_To_Address__r.County__c;
                                    if(currentOrder.Bill_To_Address__r.Country__c != Null) Payment1.Country__c = currentOrder.Bill_To_Address__r.Country__c;
                                    if(currentOrder.Bill_To_Address__r.Postal_Code__c != Null) Payment1.Zipcode__c = currentOrder.Bill_To_Address__r.Postal_Code__c; 
                                    Payment1.Account__c = currentOrder.Organisation__c; 
                                    Payment1.Organisation_Business_Unit__c = currentOrder.Organisation_Business_Unit__c;  
                                    Payment1.ERP7__Credit_Note__c = newCN.Id;  
                                    Payment1.ERP7__Type__c = 'Credit';  
                                    Payment1.ERP7__Payment_Type__c = 'Coupon';  
                                    Payment1.ERP7__Status__c = 'Paid';  
                                    payment1.ERP7__Total_Amount__c = newCN.ERP7__Amount__c;
                                    String rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                                    if(String.isNotEmpty(rTypeP1)){  Payment1.RecordTypeId = rTypeP1;   }
                                    Payment1.ERP7__Posted__c = true;  Payment1.ERP7__Posted_Date__c = system.Today();
                                    
                                    DMLManager.upsertAsUser(pays);   
                                    message='';
                                }*/
                            } else{
                                message= 'Invalid Coupon Amount';
                            }
                        }
            }else{
                message= 'Invalid Coupon';  
            }
            
        } catch(Exception e) { message = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); System.debug('message:'+message);}
        return message;
    }
    
    @AuraEnabled
    public static List<ERP7__Loyalty_Card__c> applyLoyaltyInitial(String accId, String org){        
        List<ERP7__Loyalty_Card__c> LC=[Select id, Name, ERP7__Active__c, ERP7__Active_Points__c, ERP7__Loyalty_Program__c, ERP7__Points_Per_Unit_Amount__c, ERP7__Contact__c, ERP7__Customer__c, ERP7__Start_date__c,
                                        ERP7__Expiration_Date__c, ERP7__Status__c, ERP7__Total_Points_Credited__c, ERP7__Total_Points_Debited__c,
                                        ERP7__Organisation__c From ERP7__Loyalty_Card__c Where
                                        ERP7__Customer__c = : accId And
                                        ERP7__Active__c = true And
                                        ERP7__Status__c = 'Active' And
                                        ERP7__Start_date__c <= : System.today() And
                                        ERP7__Expiration_Date__c >= : System.today() And
                                        ERP7__Organisation__c = : org
                                        Limit 1];
        
        return LC;
    }
    
    @AuraEnabled
    public static String applyLoyalty(String loyalityCards,String ordId,Decimal loyaltyPoints){
        String message='';
        List<ERP7__Loyalty_Card__c> loyalityCard = (List<ERP7__Loyalty_Card__c>) JSON.deserialize(loyalityCards, List<ERP7__Loyalty_Card__c>.class);
        ERP7__Loyalty_Points__c debitReward = new ERP7__Loyalty_Points__c();
        
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Loyalty_Card__c.isCreateable())debitReward.ERP7__Loyalty_Card__c = loyalityCard[0].id;//Master detail
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Credit_Debit_Date__c.isCreateable())debitReward.ERP7__Credit_Debit_Date__c = System.today();
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Order_s__c.isCreateable())debitReward.ERP7__Order_s__c = ordId;
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Points__c.isCreateable())debitReward.ERP7__Points__c = loyaltyPoints;
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Transaction_Status__c.isCreateable())debitReward.ERP7__Transaction_Status__c ='Debit'; 
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Valid_Date__c.isCreateable())debitReward.ERP7__Valid_Date__c = System.Today() + 30;
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Organisation__c.isCreateable())debitReward.ERP7__Organisation__c = loyalityCard[0].ERP7__Organisation__c; 
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.ERP7__Organisation_Business_Unit__c.isCreateable())debitReward.ERP7__Organisation_Business_Unit__c = loyalityCard[0].ERP7__Organisation_Business_Unit__c;
       
        //DML Operation.
        if(Schema.sObjectType.ERP7__Loyalty_Points__c.isCreateable())insert debitReward;
     
        
        if(debitReward.Id != null){
            message='Loyalty Apply Successfully';
            Order ord=new Order(Id=ordId);
            if(Schema.sObjectType.Order.fields.ERP7__Loyalty_Points__c.isUpdateable())ord.ERP7__Loyalty_Points__c=loyaltyPoints;
            if(Schema.sObjectType.Order.fields.ERP7__Loyalty_Amount__c.isUpdateable())ord.ERP7__Loyalty_Amount__c=loyaltyPoints/loyalityCard[0].ERP7__Points_Per_Unit_Amount__c;
            
            //DML Operation.
            if(Schema.sObjectType.Order.isUpdateable())update ord;
            
        }
        return message;
    }
    
    
    @AuraEnabled
    public static upsWrap UPSServices(String OrdId, String packType, String shipDate) {
        
        System.debug('OrdId::~>'+OrdId);
        System.debug('packType::~>'+packType);
        System.debug('shipDate::~>'+shipDate);
        upsWrap upsWrapp = new upsWrap();
        String pkgType;                
        if(packType != null && packType != '--None--') pkgType = packType; else pkgType = 'Package';
        String shipperProvinceCode = '', errorMsg = '',fromAddress_Street='', shipAddress_Street = '', shipAddress_ProvinceCode = '', shipAddress_CountryCode = '', shipperCountryCode = '', shipFrom_ProvinceCode = '', shipFrom_CountryCode = '';
        Decimal soVolume = 0, soWeight = 0; 
        Decimal pkgLength = 0, totalWeight = 0, pkgWidth = 0, pkgHeight = 0, pkgWeight = 0, additionalPercent = 0, totalPkgVolume = 0;
        Decimal totalWeightperPackage = 0;
        Decimal noOfPackages = 0;                   
        ERP7__Package__c pkg = new ERP7__Package__c();
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c();
        List<Selectoptions> packTypeListOption = new List<Selectoptions>();
        
        if(OrdId != null || OrdId != '') {                                        
            Order currentOrder = [select Id, Name, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                  ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Issue_Invoice__c,
                                  ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line1__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line2__c, 
                                  ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line3__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__State__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Country__c, 
                                  ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Postal_Code__c from Order where Id =: OrdId];
            
            
            for(OrderItem ordItm:[select Id, Product2Id, Product2.ERP7__Length__c, Product2.ERP7__Width__c, Product2.ERP7__Height__c, Product2.ERP7__Weight__c, 
                                  Quantity from OrderItem where OrderId =: currentOrder.Id]){
                                      if(ordItm.Product2.ERP7__Length__c != Null && ordItm.Product2.ERP7__Width__c != Null && ordItm.Product2.ERP7__Height__c != Null) 
                                          soVolume += ordItm.Product2.ERP7__Length__c * ordItm.Product2.ERP7__Width__c * ordItm.Product2.ERP7__Height__c * ordItm.Quantity;    
                                      if(ordItm.Product2.ERP7__Weight__c != Null) 
                                          soWeight += ordItm.Product2.ERP7__Weight__c * ordItm.Quantity;
                                  }
            
            ERP7__Credentials__c credentials;
            for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__UPS_Account_Number__c, ERP7__Encrypted_Key__c, ERP7__End_Point__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Key__c, ERP7__Password_Transkey__c, //ERP7__Meter_Number__c, 
                                          ERP7__Shipper_Name__c, ERP7__Shipper_Company_Name__c, ERP7__Shipper_Email__c, ERP7__Shipper_Phone_Number__c, ERP7__Shipper_Street__c, 
                                          ERP7__Shipper_City__c, ERP7__Shipper_Postal_Code__c, ERP7__Shipper_Country__c, ERP7__Shipper_Province__c 
                                          From ERP7__Credentials__c 
                                          Where Name = 'UPS' And ERP7__Active__c = true And ERP7__UPS_Account_Number__c != null And ERP7__UPS_Account_Number__c != '' And
                                          ERP7__Key__c != null And ERP7__Key__c != '' Limit 1])
                credentials=crd;
            
            
            if(credentials != null) {
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(credentials.ERP7__Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials.ERP7__Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials.ERP7__Password_Transkey__c));
                if(userData != null) credentials.ERP7__Username_Login__c = userData.toString();
                if(passwordData != null) credentials.ERP7__Password_Transkey__c = passwordData.toString();
                
                List<ERP7__Province_Codes__c> recProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : credentials.ERP7__Shipper_Province__c Limit 1];  
                if(recProvinceCodes.Size() > 0) shipperProvinceCode = recProvinceCodes[0].ERP7__Code__c; 
                else errorMsg = 'UPS Shipping Service Unavailable : Shipper Province Code not found';
                
                List<Country_Codes__c> shipperCountry=[Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: credentials.ERP7__Shipper_Country__c Limit 1];
                if(shipperCountry.size() > 0) shipperCountryCode = shipperCountry[0].ERP7__Code__c;
                if(shipperCountryCode == null || shipperCountryCode == '') errorMsg = 'UPS Shipping Service Unavailable : Shipper Country Code not found';
                
                
            } else errorMsg = 'UPS Shipping Service Unavailable : Please setup UPS credentials';
            System.debug('credentials:'+credentials);
            
            if(credentials != null) { 
                
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c !='') shipAddress_Street=currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c;
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c !='') shipAddress_Street+= ', '+ currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c;
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c !='') shipAddress_Street+= ', '+ currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c;
                System.debug('shipAddress_Street:'+shipAddress_Street);
                
                if(currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line1__c != null) fromAddress_Street=currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line1__c;
                if(currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line2__c != null) fromAddress_Street+=', '+currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line2__c;
                if(currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line2__c != null) fromAddress_Street+=', '+currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line3__c;
                System.debug('fromAddress_Street:'+fromAddress_Street);
               
                List<ERP7__Province_Codes__c> shipProvinceCode = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];                     
                if(shipProvinceCode != null && shipProvinceCode.Size() > 0) shipAddress_ProvinceCode = shipProvinceCode[0].ERP7__Code__c;
                else errorMsg = 'UPS Shipping Service Unavailable : Shipping Address Province Code not found';
                System.debug('shipAddress_ProvinceCode:'+shipAddress_ProvinceCode);
                
                List<Country_Codes__c> countryCodes=[Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: currentOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Limit 1];
                if(countryCodes.size() > 0) shipAddress_CountryCode = countryCodes[0].ERP7__Code__c;
                if(shipAddress_CountryCode == null || shipAddress_CountryCode == '') errorMsg = 'UPS Shipping Service Unavailable : Shipping Address Country Code not found';
                
                
                List<ERP7__Province_Codes__c> recProvinceCode = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__State__c Limit 1]; 
                if(recProvinceCode != null && recProvinceCode.Size() > 0) shipFrom_ProvinceCode = recProvinceCode[0].ERP7__Code__c;
                else errorMsg = 'UPS Shipping Service Unavailable : Salepoint Province Code not found';
                System.debug('shipFrom_ProvinceCode:'+shipFrom_ProvinceCode);
                
                List<Country_Codes__c> countryCodes1=[Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Country__c Limit 1];
                if(countryCodes1.size() > 0) shipFrom_CountryCode = countryCodes1[0].ERP7__Code__c;
                if(shipFrom_CountryCode == null || shipFrom_CountryCode == '') errorMsg = 'UPS Shipping Service Unavailable : Salepoint Country Code not found';
                
                List<ERP7__Package_Details__c> pkgDetailLists = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Weight__c, ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c Where ERP7__Type__c = 'UPS']; 
                boolean packageExist = false;
                for(ERP7__Package_Details__c pkgDetailListt : pkgDetailLists) {  packageExist = true;  
                    packTypeListOption.add(new selectOptions(pkgDetailListt.ERP7__Package_Type__c, pkgDetailListt.ERP7__Package_Type__c)); 
                } 
                if(!packageExist) errorMsg = 'Package Details not found'; 
                upsWrapp.UPSErrorMsg = errorMsg;
                
                if(errorMsg == '' || Test.isRunningTest()){
                    
                    if(pkgType != null && pkgType != '--None--') { 
                        List<ERP7__Package_Details__c> pkgDetailList = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Additional_Percentage__c, Weight__c, 
                                                                        ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c where ERP7__Package_Type__c =: pkgType limit 1];                                             
                        
                        if(pkgDetailList.size() > 0) {
                            pkg.ERP7__Length__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Length__c;
                            pkg.ERP7__Width__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Width__c;            
                            pkg.ERP7__Height__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Height__c;
                            pkg.ERP7__Weight__c = pkgDetailList[pkgDetailList.size() - 1].Weight__c;
                            pkg.ERP7__Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Weight_Unit__c;
                            pkgLength = pkg.ERP7__Length__c;                                 
                            pkgWidth = pkg.ERP7__Width__c;                                      
                            pkgHeight = pkg.ERP7__Height__c;                                     
                            pkgWeight = pkg.ERP7__Weight__c;                                    
                            additionalPercent = Integer.valueof(pkgDetailList[pkgDetailList.size() - 1].Additional_Percentage__c);
                            totalPkgVolume = (pkg.ERP7__Length__c * pkg.ERP7__Width__c * pkg.ERP7__Height__c).setscale(2);
                            noOfPackages = Integer.valueof(soVolume / totalPkgVolume);
                            System.debug('soVolume:'+soVolume);
                            System.debug('totalPkgVolume:'+totalPkgVolume);
                            System.debug('noOfPackages:'+noOfPackages);
                            if(math.mod(Integer.valueof(soVolume),Integer.valueof(totalPkgVolume)) > 0) noOfPackages++;
                            soVolume = soVolume.setscale(2);
                            soWeight = soWeight.setscale(2);
                            totalWeight = (soWeight + (noOfPackages * pkg.ERP7__Weight__c)).setscale(2);
                            totalWeightperPackage = (noOfPackages > 0)? (totalWeight / noOfPackages).setscale(2) : totalWeight;
                            
                            upsWrapp.PackageType  = pkgType;                    
                            upsWrapp.PackageTypes = packTypeListOption;    
                            if(shipDate != Null && shipDate != '') upsWrapp.ShipmentDate = Date.valueOf(shipDate);
                            else upsWrapp.ShipmentDate = System.Today();                     
                            upsWrapp.Length = pkgLength;                      
                            upsWrapp.Width = pkgWidth;                          
                            upsWrapp.Height = pkgHeight;                         
                            upsWrapp.Weight = pkgWeight;                          
                            upsWrapp.NoofPackage = noOfPackages;                    
                            upsWrapp.Additional = additionalPercent;                      
                            upsWrapp.PackageVolume = totalPkgVolume;                  
                            upsWrapp.SOVolume = soVolume;                       
                            upsWrapp.SOWeight = soWeight;                        
                            upsWrapp.TotalWeight = totalWeight;                    
                            upsWrapp.WeightPerPack = totalWeightperPackage;                 
                            //serviceRequest();                    
                            
                            
                            try {
                                string soapXML = '<?xml version="1.0"?>';
                                soapXML += '<AccessRequest xml:lang="en-US">';
                                soapXML += '<AccessLicenseNumber>'+ credentials.ERP7__Key__c +'</AccessLicenseNumber>';
                                soapXML += '<UserId>'+ credentials.ERP7__Username_Login__c +'</UserId>';
                                soapXML += '<Password>'+ credentials.ERP7__Password_Transkey__c +'</Password>';
                                soapXML += '</AccessRequest>';
                                
                                soapXML += '<?xml version="1.0"?>';
                                soapXML += '<RatingServiceSelectionRequest>';
                                soapXML += '<Request>';
                                soapXML += '<RequestAction>Rate</RequestAction>';
                                soapXML += '<RequestOption>Shop</RequestOption>';
                                soapXML += '</Request>';
                                
                                soapXML += '<Shipment>';
                                soapXML += '<Shipper>';
                                soapXML += '<ShipperNumber>'+ credentials.ERP7__UPS_Account_Number__c +'</ShipperNumber>';
                                soapXML += '<Address>';
                                soapXML += '<AddressLine1>'+ credentials.ERP7__Shipper_Street__c +'</AddressLine1>';
                                soapXML += '<City>'+ credentials.ERP7__Shipper_City__c +'</City>';
                                soapXML += '<StateProvinceCode>'+ shipperProvinceCode +'</StateProvinceCode>';
                                soapXML += '<PostalCode>'+ credentials.ERP7__Shipper_Postal_Code__c +'</PostalCode>';
                                soapXML += '<CountryCode>'+ shipperCountryCode +'</CountryCode>';
                                soapXML += '</Address>';
                                soapXML += '</Shipper>';                                    
                                
                                soapXML += '<ShipTo>';
                                soapXML += '<Address>';
                                soapXML += '<AddressLine1>'+ shipAddress_Street +'</AddressLine1>';
                                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__City__c != null) soapXML += '<City>'+ currentOrder.ERP7__Ship_To_Address__r.ERP7__City__c +'</City>';
                                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c != null) soapXML += '<PostalCode>'+ currentOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c +'</PostalCode>';
                                soapXML += '<CountryCode>'+ shipAddress_CountryCode +'</CountryCode>';
                                soapXML += '</Address>';
                                soapXML += '</ShipTo>';
                                
                                soapXML += '<ShipFrom>';
                                soapXML += '<Address>';
                                if(currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__c != null) {
                                    soapXML += '<AddressLine1>'+ fromAddress_Street +'</AddressLine1>';
                                    if(currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__City__c != null) soapXML += '<City>'+ currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__City__c +'</City>';
                                    soapXML += '<StateProvinceCode>'+ shipFrom_ProvinceCode +'</StateProvinceCode>';
                                    if(currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.Postal_Code__c != null) soapXML += '<PostalCode>'+ currentOrder.ERP7__Channel__r.ERP7__Ship_From_Address__r.Postal_Code__c +'</PostalCode>';
                                    soapXML += '<CountryCode>'+ shipFrom_CountryCode +'</CountryCode>';
                                }
                                soapXML += '</Address>';
                                soapXML += '</ShipFrom>';
                                
                                soapXmL += '<RateInformation>';
                                soapXmL += '<NegotiatedRatesIndicator>Y</NegotiatedRatesIndicator>';
                                soapXmL += '</RateInformation>'; 
                                
                                Map<String, ERP7__UPS_Package_Type__c> packageTypeMap = new Map<String, ERP7__UPS_Package_Type__c>();              
                                List <ERP7__UPS_Package_Type__c> packageType = [select Id, Name, ERP7__Package_Code__c, ERP7__Package_Description__c from ERP7__UPS_Package_Type__c limit 12];                                                                      
                                for(ERP7__UPS_Package_Type__c upt : packageType) { packageTypeMap.put(upt.ERP7__Package_Description__c, upt); }
                                
                                for(Integer i=0; i<noOfPackages; i++) {
                                    soapXML += '<Package>';  
                                    soapXML += '<PackagingType>';  
                                    soapXML += '<Code>'+ packageTypeMap.get('Package').ERP7__Package_Code__c +'</Code>';  
                                    soapXML += '</PackagingType>';  soapXML += '<Dimensions>';   
                                    soapXML += '<UnitOfMeasurement>';
                                    if(pkg.ERP7__Weight_Unit__c == 'KGS')  soapXMl += '<Code>CM</Code>';
                                    else soapXMl += '<Code>IN</Code>';
                                    
                                    soapXML += '</UnitOfMeasurement>';   
                                    soapXMl += '<Length>'+ pkg.ERP7__Length__c +'</Length>';  
                                    soapXML += '<Width>'+ pkg.ERP7__Width__c +'</Width>';  
                                    soapXML += '<Height>'+ pkg.ERP7__Height__c +'</Height>'; 
                                    soapXML += '</Dimensions>';  
                                    soapXML += '<PackageWeight>';  
                                    soapXML += '<UnitOfMeasurement>';  
                                    soapXML += '<Code>'+ pkg.ERP7__Weight_Unit__c +'</Code>';   
                                    soapXML += '</UnitOfMeasurement>';  
                                    soapXML += '<Weight>'+ totalWeightperPackage +'</Weight>';  
                                    soapXML += '</PackageWeight>';  soapXML += '</Package>';
                                }                            
                                soapXML += '</Shipment>';
                                soapXML += '</RatingServiceSelectionRequest>';   
                                System.debug('soapXML:'+soapXML);
                                HttpRequest req = new HttpRequest(); Http h = new Http();
                                
                                req.setBody(soapXML); 
                                req.setMethod('POST');
                                //req.setEndpoint('https://onlinetools.ups.com/ups.app/xml/Rate');
                                String myEndPoint = credentials.ERP7__URL__c + '/ups.app/xml/Rate'; 
                                req.setEndpoint(myEndPoint);
                                HttpResponse res = new HttpResponse();
                                if(!Test.isRunningTest()) res = h.send(req);
                                
                                System.Debug('res of UPS:'+res);
                                System.Debug('res of getXmlStreamReader:'+res.getXmlStreamReader());
                                String Result = '';
                                System.debug('res:'+res.getBody());
                                System.debug('res:'+res.getStatus());
                                
                                if(res.getStatus() == 'OK') {
                                    
                                    XmlStreamReader reader1 = res.getXmlStreamReader();  String msg = readXMLResponse(reader1, 'ResponseStatusDescription');
                                    if (msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                                        XmlStreamReader reader = res.getXmlStreamReader();  String sxmltag = 'RatedShipment';    rateWrapper rw; List<rateWrapper> rateWrapperList = new List<rateWrapper>();            
                                        while(reader.hasNext()) {
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) {  rw = new rateWrapper();                    
                                                while(reader.hasNext()) {
                                                    //ups service
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Service') {
                                                        reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Code') { reader.next(); rw.ServiceCode = reader.getText(); }
                                                        
                                                        List <ERP7__UPS_Service_Codes__c> serviceCodes = [select Id, Name, ERP7__Service__c, ERP7__ServiceCode__c, ERP7__Service_Code_With_Trade_Mark__c, ERP7__Service_Asia_International__c,
                                                                                                          ERP7__Service_Canada_Domestic__c, ERP7__Service_Canada_International__c, ERP7__Service_Europe__c, ERP7__Service_Mexico_Domestic__c,
                                                                                                          ERP7__Service_Mexico_International__c, ERP7__Service_USA_Domestic__c from ERP7__UPS_Service_Codes__c limit 22];
                                                        if(shipFrom_CountryCode == 'CA' && shipAddress_CountryCode == 'CA') {   for(Integer i=0;i<serviceCodes.size();i++) {   if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Canada_Domestic__c; }
                                                            }
                                                        } else if(shipFrom_CountryCode == 'CA' && shipAddress_CountryCode != 'CA') {     for(Integer i=0;i<serviceCodes.size();i++) {  if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Canada_International__c; }                                                       
                                                            }
                                                        } else if(shipFrom_CountryCode == 'MX' && shipAddress_CountryCode == 'MX') {            for(Integer i=0;i<serviceCodes.size();i++) {  if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Mexico_Domestic__c; }                                                       
                                                            }
                                                        } else if(shipFrom_CountryCode == 'MX' && shipAddress_CountryCode != 'MX') {      for(Integer i=0;i<serviceCodes.size();i++) {   if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Mexico_International__c; }                                                       
                                                            }
                                                        } else { for(Integer i=0;i<serviceCodes.size();i++) {  if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Code_With_Trade_Mark__c; }   
                                                        }
                                                               }
                                                    }
                                                    // transport charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TransportationCharges') {  reader.next();            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next();   if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();   if(reader.hasText() && rw.TransportationCharges == '') rw.TransportationCharges = reader.getText(); }                            }
                                                    // services charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceOptionsCharges') { reader.next();      if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next();   if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();   if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();  if(reader.hasText() && rw.ServiceOptionsCharges == '') rw.ServiceOptionsCharges = reader.getText(); }     }
                                                    // total charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalCharges') { reader.next();  if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next();    if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();      if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText(); }     }
                                                    // days to deliver
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'GuaranteedDaysToDelivery') { reader.next();     if(reader.hasText()) {  rw.GuaranteedDaysToDelivery = reader.getText();   rw.DeliveryDate = upsWrapp.ShipmentDate + Integer.valueof(rw.GuaranteedDaysToDelivery); } else { rw.GuaranteedDaysToDelivery = '-'; rw.DeliveryDateS = '-'; }                   }                        
                                                    // time to deliver           
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ScheduledDeliveryTime') { reader.next();                  if(reader.hasText()) { rw.ScheduledDeliveryTime = reader.getText(); }  else { rw.ScheduledDeliveryTime = '-'; }
                                                                                                                                                          }          
                                                    // negotiated charges                                       
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'NegotiatedRates') { reader.next(); reader.next(); reader.next(); if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next();    if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();     if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();    if(reader.hasText() && rw.negotiatedCharges == '') rw.negotiatedCharges = reader.getText(); }    
                                                                                                                                                    }                        
                                                    if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();  } rateWrapperList.add(rw);     } reader.next();
                                        }            
                                        Integer n = rateWrapperList.size();            
                                        for(Integer c = 0 ; c < ( n - 1 ); c++) {
                                            for (Integer d = 0 ; d < n - c - 1; d++) { if(Decimal.valueof(rateWrapperList[d].totalCharges) > Decimal.valueof(rateWrapperList[d+1].totalCharges)) {  rateWrapper swap = rateWrapperList[d]; rateWrapperList[d] = rateWrapperList[d+1]; rateWrapperList[d+1] = swap;  }   }
                                        }       
                                        upsWrapp.Services = rateWrapperList;  upsWrapp.UPSErrorMsg = 'Available Services For The Selected Location';
                                    } else { XmlStreamReader reader3 = res.getXmlStreamReader();  String msg1 = readXMLResponse(reader3, 'ErrorDescription');   if (msg1 != Null && msg1 != '') upsWrapp.UPSErrorMsg = 'Shipping Rate Service Is Not Available : ' + msg1;   else upsWrapp.UPSErrorMsg = 'Request To Rate Shipment Cannot Be Processed';  }    
                                } else upsWrapp.UPSErrorMsg = 'Result not available';            
                            } catch(Exception E) { upsWrapp.UPSErrorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); } 
                        }
                    }
                } 
                
            }                                    
        }
        return upsWrapp;
    }
    
    @AuraEnabled
    public static upsWrap FedServices(String OrdId, String packType, String shipDate) {        
        upsWrap upsWrapp = new upsWrap();
        
        //String salesorderId = soId;   
        String pkgType;                
        if(packType != null && packType != '--None--') pkgType = packType; else pkgType = 'YOUR_PACKAGING';
        String shipperProvinceCode = '', errorMsg = '', shipAddress_Street = '', shipAddress_ProvinceCode = '', shipAddress_CountryCode = '', shipperCountryCode = '', sp_ProvinceCode = '', sp_CountryCode = '';
        Decimal soVolume = 0, soWeight = 0; 
        Decimal pkgLength = 0, totalWeight = 0, pkgWidth = 0, pkgHeight = 0, pkgWeight = 0, additionalPercent = 0, totalPkgVolume = 0;
        Decimal totalWeightperPackage = 0;
        Decimal noOfPackages = 0;                    
        ERP7__Package__c pkg = new ERP7__Package__c();
        //ERP7__Sales_Order__c so = new ERP7__Sales_Order__c();
        List<Selectoptions> packTypeListOption = new List<Selectoptions>();
        //List<ERP7__Sales_Order_Line_Item__c> lstSoli = new List<ERP7__Sales_Order_Line_Item__c>();
        
        if(OrdId != null && OrdId != '') {                                        
            Order currentOrder = [select Id, Name, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                  ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Issue_Invoice__c,
                                  ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line1__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line2__c, 
                                  ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line3__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__State__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Country__c, 
                                  ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Postal_Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Company__c,ERP7__Contact__r.Phone from Order where Id =: OrdId];
            
            
            for(OrderItem ordItm:[select Id, Product2Id, Product2.ERP7__Length__c, Product2.ERP7__Width__c, Product2.ERP7__Height__c, Product2.ERP7__Weight__c, 
                                  Quantity from OrderItem where OrderId =: currentOrder.Id]){
                                      if(ordItm.Product2.ERP7__Length__c != Null && ordItm.Product2.ERP7__Width__c != Null && ordItm.Product2.ERP7__Height__c != Null) 
                                          soVolume += ordItm.Product2.ERP7__Length__c * ordItm.Product2.ERP7__Width__c * ordItm.Product2.ERP7__Height__c * ordItm.Quantity;    
                                      if(ordItm.Product2.ERP7__Weight__c != Null) 
                                          soWeight += ordItm.Product2.ERP7__Weight__c * ordItm.Quantity;
                                  }
             
            
            ERP7__Credentials__c fedExCre = [Select Id, Name, ERP7__Active__c, ERP7__Parent_Key__c, ERP7__Parent_Password__c, ERP7__Key__c, ERP7__Password_Transkey__c, 
                                              ERP7__Meter_Number__c, ERP7__URL__c, ERP7__UPS_Account_Number__c, ERP7__Shipper_Name__c, ERP7__Shipper_Company_Name__c, 
                                              ERP7__Shipper_Street__c, ERP7__Shipper_Postal_Code__c,  ERP7__Shipper_City__c, ERP7__Shipper_Province__c, ERP7__Shipper_Country__c,
                                              ERP7__Encrypted_Key__c, ERP7__Shipper_Email__c, ERP7__Shipper_Phone_Number__c
                                              From ERP7__Credentials__c     
                                              Where Name = 'FedEx' And ERP7__Active__c = true Limit 1]; 
            
            
            if(fedExCre != null){
                Blob cryptoKey, passwordData;
                cryptoKey = encodingUtil.convertFromHex(fedExCre.Encrypted_Key__c);
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(fedExCre.Password_Transkey__c));
                if(passwordData != null) fedExCre.Password_Transkey__c = passwordData.toString();
                
                List<ERP7__Province_Codes__c> lstProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : fedExCre.ERP7__Shipper_Province__c Limit 1];  
                if(lstProvinceCodes.Size() > 0) shipperProvinceCode = lstProvinceCodes[0].ERP7__Code__c; 
                //else errorMsg = 'FedEx Shipping Service Unavailable : Shipper Province Code not found';
                
                List<ERP7__Country_Codes__c> lstcountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: fedExCre.ERP7__Shipper_Country__c Limit 1];            
                if(lstcountryCodes.size() > 0) shipperCountryCode = lstcountryCodes[0].ERP7__Code__c;
                else errorMsg = 'FedEx Shipping Service Unavailable : Shipper Country Code not found';
            } else errorMsg = 'FedEx Shipping Service Unavailable : Please setup FedEx credentials';
            
            if(currentOrder != null){
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c !='') shipAddress_Street=currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c;
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c !='') shipAddress_Street+= ', '+ currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c;
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c !='') shipAddress_Street+= ', '+ currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c;
                System.debug('shipAddress_Street:'+shipAddress_Street);
                
                /*if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != Null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != '') {              
                    shipAddress_Street = currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c + ', ' + currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c; 
                } else if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != Null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != '') { 
                    shipAddress_Street = currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c; 
                } else { shipAddress_Street = currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c; }*/
            
                List<ERP7__Province_Codes__c> lstToProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];  
                if(lstToProvinceCodes.Size() > 0) shipAddress_ProvinceCode = lstToProvinceCodes[0].ERP7__Code__c; 
                //else errorMsg = 'FedEx Shipping Service Unavailable : Shipping Address Province Code not found';
                
                List<ERP7__Country_Codes__c> lstTocountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: currentOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Limit 1];            
                if(lstTocountryCodes.size() > 0) shipAddress_CountryCode = lstTocountryCodes[0].ERP7__Code__c;
                else errorMsg = 'FedEx Shipping Service Unavailable : Shipping Address Country Code not found';
            } 
                
            List<ERP7__Package_Details__c> pkgDetailLists = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Weight__c, ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c Where ERP7__Type__c = 'FEDEX' Order by CreatedDate Asc]; 
            boolean packageExist = false;
            
            for(ERP7__Package_Details__c pkgDetailListt : pkgDetailLists) {
                packageExist = true;  packTypeListOption.add(new selectOptions(pkgDetailListt.ERP7__Package_Type__c, pkgDetailListt.ERP7__Package_Type__c)); 
            }
             
            if(!packageExist) errorMsg = 'Package Details not found'; 
            upsWrapp.UPSErrorMsg = errorMsg;
            
            if(errorMsg == '' || Test.isRunningTest()){
                
                if(pkgType != null && pkgType != '--None--') { 
                    List<ERP7__Package_Details__c> pkgDetailList = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Additional_Percentage__c, Weight__c, 
                                                               ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c where ERP7__Package_Type__c =: pkgType limit 1]; 
                                                               
                    if(pkgDetailList.size() > 0) {
                        pkg.ERP7__Length__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Length__c;
                        pkg.ERP7__Width__c  = pkgDetailList[pkgDetailList.size() - 1].ERP7__Width__c;            
                        pkg.ERP7__Height__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Height__c;
                        pkg.ERP7__Weight__c = pkgDetailList[pkgDetailList.size() - 1].Weight__c;
                        pkg.ERP7__Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Weight_Unit__c;
                        pkgLength = pkg.ERP7__Length__c;                                 
                        pkgWidth  = pkg.ERP7__Width__c;                                      
                        pkgHeight = pkg.ERP7__Height__c;                                     
                        pkgWeight = pkg.ERP7__Weight__c;                                    
                        additionalPercent = Integer.valueof(pkgDetailList[pkgDetailList.size() - 1].Additional_Percentage__c);
                        totalPkgVolume = (pkg.ERP7__Length__c * pkg.ERP7__Width__c * pkg.ERP7__Height__c).setscale(2);
                        noOfPackages = Integer.valueof(soVolume / totalPkgVolume);
                        if(math.mod(Integer.valueof(soVolume),Integer.valueof(totalPkgVolume)) > 0) noOfPackages++;
                        soVolume = soVolume.setscale(2);
                        soWeight = soWeight.setscale(2);
                        totalWeight = (soWeight + (noOfPackages * pkg.ERP7__Weight__c)).setscale(2);
                        totalWeightperPackage = (noOfPackages > 0)? (totalWeight / noOfPackages).setscale(2) : totalWeight;
                        
                        upsWrapp.PackageType  = pkgType;                    
                        upsWrapp.PackageTypes = packTypeListOption;    
                        if(shipDate != Null && shipDate != '') { upsWrapp.ShipmentDate = Date.valueOf(shipDate); DateTime dt = upsWrapp.ShipmentDate; shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'); }
                        else {  DateTime dt = System.now(); shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'); upsWrapp.ShipmentDate = System.Today(); }
                        upsWrapp.Length = pkgLength;                      
                        upsWrapp.Width = pkgWidth;                          
                        upsWrapp.Height = pkgHeight;                         
                        upsWrapp.Weight = pkgWeight;                          
                        upsWrapp.NoofPackage = noOfPackages;                    
                        upsWrapp.Additional = additionalPercent;                      
                        upsWrapp.PackageVolume = totalPkgVolume;                  
                        upsWrapp.SOVolume = soVolume;                       
                        upsWrapp.SOWeight = soWeight;                        
                        upsWrapp.TotalWeight = totalWeight;                    
                        upsWrapp.WeightPerPack = totalWeightperPackage;
                        
                        try {
                            String soapXML = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="'+Label.POSLightningLabel3+'/soap/envelope/" xmlns:SOAP-ENC="'+Label.POSLightningLabel3+'/soap/encoding/" xmlns:xsi="'+Label.POSLightningLabel2+'-instance" xmlns:xsd="'+Label.POSLightningLabel2+'" xmlns="'+Label.POSLightningLabel4+'/ws/rate/v20">';
                            soapXML += '<SOAP-ENV:Body>';
                            soapXML += '<RateRequest>';
                                
                                soapXML += '<WebAuthenticationDetail>';
                                    soapXML += '<UserCredential>';  
                                        soapXML += '<Key>' + fedExCre.key__c + '</Key>';
                                        soapXML += '<Password>'+ fedExCre.Password_Transkey__c +'</Password>';
                                        //soapXML += '<Password>STlrFA84EzdzSOWfrW35xEIlE</Password>';
                                    soapXML += '</UserCredential>';
                                soapXML += '</WebAuthenticationDetail>';
                                
                                soapXML += '<ClientDetail>';
                                    soapXML += '<AccountNumber>'+ fedExCre.ERP7__UPS_Account_Number__c +'</AccountNumber>';
                                    soapXML += '<MeterNumber>'+ fedExCre.ERP7__Meter_Number__c +'</MeterNumber>';
                                soapXML += '</ClientDetail>';
                                
                                soapXML += '<TransactionDetail>';
                                    soapXML += '<CustomerTransactionId>Rate Request</CustomerTransactionId>';
                                soapXML += '</TransactionDetail>';
                                
                                soapXML += '<Version>';
                                    soapXML += '<ServiceId>crs</ServiceId>';
                                    soapXML += '<Major>20</Major>';
                                    soapXML += '<Intermediate>0</Intermediate>';
                                    soapXML += '<Minor>0</Minor>';
                                soapXML += '</Version>';
                                 
                                soapXML += '<RequestedShipment>';
                                    soapXML += '<ShipTimestamp>'+ shipDate +'</ShipTimestamp>';
                                    soapXML += '<DropoffType>REGULAR_PICKUP</DropoffType>';
                                    soapXML += '<PackagingType>'+ pkgType +'</PackagingType>';
                                    
                                    soapXML+= '<TotalWeight>';
                                        if(pkg.ERP7__Weight_Unit__c == 'KGS') soapXMl += '<Units>KG</Units>';
                                        else soapXMl += '<Units>LB</Units>';                         
                                        soapXML += '<Value>'+ totalWeight +'</Value>';
                                    soapXML += '</TotalWeight>';
                                    
                                    if(fedExCre != null) {   
                                        soapXML += '<Shipper>';                        
                                            soapXML += '<Contact>';
                                                soapXML += '<PersonName>'+ fedExCre.ERP7__Shipper_Name__c.escapeXml() +'</PersonName>';
                                                soapXML += '<CompanyName>'+ fedExCre.ERP7__Shipper_Company_Name__c.escapeXml() +'</CompanyName>';
                                                soapXML += '<PhoneNumber>'+ fedExCre.ERP7__Shipper_Phone_Number__c.escapeXml() +'</PhoneNumber>';
                                            soapXML += '</Contact>';
                                            soapXML += '<Address>';
                                                soapXML += '<StreetLines>' + fedExCre.ERP7__Shipper_Street__c.escapeXml() + '</StreetLines>';
                                                soapXML += '<City>'+ fedExCre.ERP7__Shipper_City__c.escapeXml() +'</City>';
                                                if(shipperProvinceCode != null) soapXML += '<StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</StateOrProvinceCode>';
                                                soapXML += '<PostalCode>'+ fedExCre.ERP7__Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';
                                                if(shipperCountryCode != null) soapXML += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';
                                            soapXML += '</Address>';
                                        soapXML += '</Shipper>';
                                    }
                                    if(currentOrder != null) {
                                        soapXML += '<Recipient>';
                                            soapXML += '<Contact>';
                                                soapXML += '<PersonName>'+ currentOrder.ERP7__Contact__r.Name.escapeXml() +'</PersonName>';
                                                if(currentOrder.ERP7__Contact__r.Company__c != null) soapXML += '<CompanyName>'+ currentOrder.ERP7__Contact__r.Company__c.escapeXml() +'</CompanyName>';
                                                if(currentOrder.ERP7__Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ currentOrder.ERP7__Contact__r.Phone.escapeXml() +'</PhoneNumber>';
                                            soapXML += '</Contact>'; 
                                            soapXML += '<Address>';
                                                soapXML += '<StreetLines>' + shipAddress_Street.escapeXml() + '</StreetLines>';
                                                soapXML += '<City>' + currentOrder.ERP7__Ship_To_Address__r.ERP7__City__c.escapeXml() + '</City>';
                                                if(shipAddress_ProvinceCode != null) soapXML += '<StateOrProvinceCode>' + shipAddress_ProvinceCode.escapeXml() + '</StateOrProvinceCode>';
                                                soapXML += '<PostalCode>' + currentOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c .escapeXml() + '</PostalCode>';
                                                if(shipAddress_CountryCode != null)  soapXML += '<CountryCode>' + shipAddress_CountryCode.escapeXml() + '</CountryCode>';
                                            soapXML += '</Address>';
                                        soapXML += '</Recipient>';
                                    }
                                    soapXML += '<ShippingChargesPayment>';
                                        soapXML += '<PaymentType>SENDER</PaymentType>';
                                        soapXML += '<Payor>';
                                            soapXML += '<ResponsibleParty>';
                                                if(fedExCre != null) soapXML += '<AccountNumber>'+ fedExCre.ERP7__UPS_Account_Number__c +'</AccountNumber>';
                                            soapXML += '</ResponsibleParty>';
                                        soapXML += '</Payor>';                         
                                    soapXML += '</ShippingChargesPayment>';
                                    
                                    soapXML += '<RateRequestTypes>LIST</RateRequestTypes>';
                                    soapXML += '<PackageCount>'+ noOfPackages +'</PackageCount>';
                                    
                                    for(Integer i=0; i<=noOfPackages; i++) {
                                        
                                        soapXML += '<RequestedPackageLineItems>';
                                            soapXML += '<SequenceNumber>'+ i+1 +'</SequenceNumber>';
                                            soapXML += '<GroupNumber>1</GroupNumber>';
                                            soapXML += '<GroupPackageCount>1</GroupPackageCount>';
                                            
                                            soapXML += '<Weight>';
                                                if(pkg.ERP7__Weight_Unit__c == 'KGS') soapXMl += '<Units>KG</Units>';
                                                else soapXMl += '<Units>LB</Units>';    
                                                soapXML += '<Value>' + totalWeightperPackage + '</Value>';                        
                                            soapXML += '</Weight>';
                                            
                                            
                                        soapXML += '</RequestedPackageLineItems>';
                                    }         
                                soapXML += '</RequestedShipment>';                
                            soapXML += '</RateRequest>';
                            soapXML += '</SOAP-ENV:Body>';
                            soapXML += '</SOAP-ENV:Envelope>';
                            HttpRequest req = new HttpRequest();
                            Http h = new Http();
                            
                            req.setBody(soapXML);
                            req.setMethod('POST');
                            String myEndPoint = fedExCre.ERP7__URL__c; 
                            req.setEndpoint(myEndPoint);
                            req.setHeader('Content-length', '175');
                            req.setHeader('Content-Type', 'text/xml');
                            req.setHeader('SOAPAction', '');
                            req.setHeader('Host', 'wsbeta.fedex.com');
                            
                            HttpResponse res = h.send(req);            
                            //request_1 = soapXML;  
                            //response_1 = res.getBody();   
                            //resStatus = res.getStatus();
                            
                            if(res.getStatus() == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                                if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') {
                                    XmlStreamReader reader2 = res.getXmlStreamReader();   String resMesage = readXMLResponse(reader2, 'Code');
                                    if (resMesage == '556') { upsWrapp.UPSErrorMsg = 'There are no valid services available.';
                                    }else{
                                        XmlStreamReader reader = res.getXmlStreamReader();
                                        rateWrapper rw; List<rateWrapper> rateWrapperLst = new List<rateWrapper>(); 
                                        while(reader.hasNext()) {
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'RateReplyDetails') {  rw = new rateWrapper();
                                                while(reader.hasNext()) {
                                                    // service type
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceType') { reader.next(); rw.service = reader.getText(); }
                                                    // sur charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalSurcharges') { reader.next(); if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next();   if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();   if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next();    if(reader.hasText() && rw.totalSurcharges == '') rw.totalSurcharges = reader.getText(); /*+' '+ rw.currencyCode;*/ } }
                                                    // total charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNetCharge') { reader.next();    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next();   if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();  if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next();    if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText(); /* +' '+ rw.currencyCode;*/ } }        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'RateReplyDetails') break; else reader.next();   } rateWrapperLst.add(rw);  } reader.next();
                                        }
                                          
                                          upsWrapp.Services = rateWrapperLst;  upsWrapp.UPSErrorMsg = 'Available Services For The Selected Location';
                                          //time_in_cost_tab = true;
                                    }                                
                                } else { XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message');  upsWrapp.UPSErrorMsg = 'Shipping Rate Service Is Not Available : ' + msg2;
                                }  
                            } else upsWrapp.UPSErrorMsg = 'Result not available';
                            
                        } catch(Exception e) { upsWrapp.UPSErrorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
                    } 
                }  
            }
        }
        return upsWrapp;
    }
    
    /*@AuraEnabled
    public static upsWrap DHLServices(String OrdId, String packType, String shipDate) {
        upsWrap upsWrapp = new upsWrap();
        
           
        String pkgType;                
        if(packType != null && packType != '--None--') pkgType = packType; else pkgType = 'Package';
        String shipperProvinceCode = '', errorMsg = '', shipAddress_Street = '', shipAddress_ProvinceCode = '', shipAddress_CountryCode = '', shipperCountryCode = '', sp_ProvinceCode = '', sp_CountryCode = '';
        Decimal soVolume = 0, soWeight = 0; 
        Decimal pkgLength = 0, totalWeight = 0, pkgWidth = 0, pkgHeight = 0, pkgWeight = 0, additionalPercent = 0, totalPkgVolume = 0;
        Decimal totalWeightperPackage = 0;
        Decimal noOfPackages = 0;                    
        ERP7__Package__c pkg = new ERP7__Package__c();
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c();
        List<Selectoptions> packTypeListOption = new List<Selectoptions>();
        List<ERP7__Sales_Order_Line_Item__c> lstSoli = new List<ERP7__Sales_Order_Line_Item__c>();
        
        if(OrdId != null && OrdId != '') {                                        
            Order currentOrder = [select Id, Name, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                  ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Issue_Invoice__c,
                                  ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line1__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line2__c, 
                                  ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Address_Line3__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__State__c, ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Country__c, 
                                  ERP7__Channel__r.ERP7__Ship_From_Address__r.ERP7__Postal_Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Company__c,ERP7__Contact__r.Phone from Order where Id =: OrdId];
            
            
            for(OrderItem ordItm:[select Id, Product2Id, Product2.ERP7__Length__c, Product2.ERP7__Width__c, Product2.ERP7__Height__c, Product2.ERP7__Weight__c, 
                                  Quantity from OrderItem where OrderId =: currentOrder.Id]){
                                      if(ordItm.Product2.ERP7__Length__c != Null && ordItm.Product2.ERP7__Width__c != Null && ordItm.Product2.ERP7__Height__c != Null) 
                                          soVolume += ordItm.Product2.ERP7__Length__c * ordItm.Product2.ERP7__Width__c * ordItm.Product2.ERP7__Height__c * ordItm.Quantity;    
                                      if(ordItm.Product2.ERP7__Weight__c != Null) 
                                          soWeight += ordItm.Product2.ERP7__Weight__c * ordItm.Quantity;
                                  }
            
            ERP7__Credentials__c dhlCre = [Select Id, Name, ERP7__Active__c, ERP7__Key__c, ERP7__Password_Transkey__c, Username_Login__c,
                                            ERP7__URL__c, ERP7__UPS_Account_Number__c, ERP7__Shipper_Name__c, ERP7__Shipper_Company_Name__c, ERP7__Shipper_Street__c, ERP7__Shipper_Postal_Code__c,  ERP7__Shipper_City__c, ERP7__Shipper_Province__c, ERP7__Shipper_Country__c,
                                            ERP7__Encrypted_Key__c, ERP7__Shipper_Email__c, ERP7__Shipper_Phone_Number__c
                                            From ERP7__Credentials__c     
                                            Where Name = 'DHL' And ERP7__Active__c = true Limit 1]; 
            
            
            if(dhlCre != null){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(dhlCre.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(dhlCre.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(dhlCre.Password_Transkey__c));
                if(userData != null) dhlCre.Username_Login__c = userData.toString();
                if(passwordData != null) dhlCre.Password_Transkey__c = passwordData.toString();
                //DhlPassword = dhlCre.Password_Transkey__c; 
                //DhlUserName = dhlCre.Username_Login__c;
                //DhlAccountNumber = dhlCre.UPS_Account_Number__c;
            
                List<ERP7__Province_Codes__c> lstProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : dhlCre.ERP7__Shipper_Province__c Limit 1];  
                if(lstProvinceCodes.Size() > 0) shipperProvinceCode = lstProvinceCodes[0].ERP7__Code__c;
                
                List<ERP7__Country_Codes__c> lstcountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: dhlCre.ERP7__Shipper_Country__c Limit 1];            
                if(lstcountryCodes.size() > 0) shipperCountryCode = lstcountryCodes[0].ERP7__Code__c;
                else errorMsg = 'DHL Shipping Service Unavailable : Shipper Country Code not found';
            } else errorMsg = 'DHL Shipping Service Unavailable : Please setup DHL credentials';
            
            if(currentOrder != null){
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c !='') shipAddress_Street=currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c;
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c !='') shipAddress_Street+= ', '+ currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c;
                if(currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != null && currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c !='') shipAddress_Street+= ', '+ currentOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c;
                System.debug('shipAddress_Street:'+shipAddress_Street);
                
                List<ERP7__Province_Codes__c> lstToProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];  
                if(lstToProvinceCodes.Size() > 0) shipAddress_ProvinceCode = lstToProvinceCodes[0].ERP7__Code__c; 
                
                List<ERP7__Country_Codes__c> lstTocountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: currentOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Limit 1];            
                if(lstTocountryCodes.size() > 0) shipAddress_CountryCode = lstTocountryCodes[0].ERP7__Code__c;
                else errorMsg = 'DHL Shipping Service Unavailable : Shipping Address Country Code not found';
            } 
                
            List<ERP7__Package_Details__c> pkgDetailLists = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Weight__c, ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c Where ERP7__Type__c = 'DHL' Order by CreatedDate Asc]; 
            boolean packageExist = false;
            
            for(ERP7__Package_Details__c pkgDetailListt : pkgDetailLists) {
                packageExist = true;
                packTypeListOption.add(new selectOptions(pkgDetailListt.ERP7__Package_Type__c, pkgDetailListt.ERP7__Package_Type__c)); 
            }
             
            if(!packageExist) errorMsg = 'Package Details not found'; 
            upsWrapp.UPSErrorMsg = errorMsg;
            
            if(errorMsg == '' || Test.isRunningTest()){
                
                if(pkgType != null && pkgType != '--None--') { 
                    List<ERP7__Package_Details__c> pkgDetailList = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Additional_Percentage__c, Weight__c, 
                                                               ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c where ERP7__Package_Type__c =: pkgType limit 1]; 
                                                               
                    if(pkgDetailList.size() > 0) {
                        pkg.ERP7__Length__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Length__c;
                        pkg.ERP7__Width__c  = pkgDetailList[pkgDetailList.size() - 1].ERP7__Width__c;            
                        pkg.ERP7__Height__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Height__c;
                        pkg.ERP7__Weight__c = pkgDetailList[pkgDetailList.size() - 1].Weight__c;
                        pkg.ERP7__Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Weight_Unit__c;
                        pkgLength = pkg.ERP7__Length__c;                                 
                        pkgWidth  = pkg.ERP7__Width__c;                                      
                        pkgHeight = pkg.ERP7__Height__c;                                     
                        pkgWeight = pkg.ERP7__Weight__c;                                    
                        additionalPercent = Integer.valueof(pkgDetailList[pkgDetailList.size() - 1].Additional_Percentage__c);
                        totalPkgVolume = (pkg.ERP7__Length__c * pkg.ERP7__Width__c * pkg.ERP7__Height__c).setscale(2);
                        noOfPackages = Integer.valueof(soVolume / totalPkgVolume);
                        if(math.mod(Integer.valueof(soVolume),Integer.valueof(totalPkgVolume)) > 0) noOfPackages++;
                        soVolume = soVolume.setscale(2);
                        soWeight = soWeight.setscale(2);
                        totalWeight = (soWeight + (noOfPackages * pkg.ERP7__Weight__c)).setscale(2);
                        totalWeightperPackage = (noOfPackages > 0)? (totalWeight / noOfPackages).setscale(2) : totalWeight;
                        
                        upsWrapp.PackageType  = pkgType;                    
                        upsWrapp.PackageTypes = packTypeListOption;  
                        String createdSec;
                        if(shipDate != Null && shipDate != '') { 
                            upsWrapp.ShipmentDate = Date.valueOf(shipDate); 
                            DateTime dt = upsWrapp.ShipmentDate;
                            shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'GMT\'') + '+01:00';
                            createdSec = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                            //shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'); 
                        }
                        else {
                            DateTime dt = System.now(); shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'GMT\'') + '+01:00';  createdSec = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); upsWrapp.ShipmentDate = System.Today(); 
                            //shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT');
                        }
                        upsWrapp.Length = pkgLength;                      
                        upsWrapp.Width = pkgWidth;                          
                        upsWrapp.Height = pkgHeight;                         
                        upsWrapp.Weight = pkgWeight;                          
                        upsWrapp.NoofPackage = noOfPackages;                    
                        upsWrapp.Additional = additionalPercent;                      
                        upsWrapp.PackageVolume = totalPkgVolume;                  
                        upsWrapp.SOVolume = soVolume;                       
                        upsWrapp.SOWeight = soWeight;                        
                        upsWrapp.TotalWeight = totalWeight;                    
                        upsWrapp.WeightPerPack = totalWeightperPackage;
                        
                        
                        try {
                            String xmlBody = '<?xml version="1.0" encoding="utf-8" ?>';
                            xmlBody += '<soap:Envelope xmlns:soap="'+Label.POSLightningLabel3+'/soap/envelope/">';
                                xmlBody += '<soap:Header>';
                                    xmlBody += '<wsse:Security xmlns:wsse="'+Label.POSLightningLabel3+'/ws/2003/06/secext">';
                                        xmlBody += '<wsse:UsernameToken wsu:Id="sample" xmlns:wsu="'+Label.POSLightningLabel3+'/ws/2003/06/utility">';
                                            xmlBody += '<wsse:Username>' + dhlCre.Username_Login__c + '</wsse:Username>';
                                            xmlBody += '<wsse:Password Type="wsse:PasswordText">' + dhlCre.Password_Transkey__c + '</wsse:Password>';
                                            xmlBody += '<wsu:Created>'+ createdSec +'</wsu:Created>';
                                        xmlBody += '</wsse:UsernameToken>';
                                    xmlBody += '</wsse:Security>';
                                xmlBody += '</soap:Header>';
                                xmlBody += '<soap:Body>';
                                    xmlBody += '<RateRequest>';
                                        xmlBody += '<RequestedShipment>';
                                            xmlBody += '<DropOffType>REQUEST_COURIER</DropOffType>';
                                            xmlBody += '<Ship>';
                                                if(dhlCre != null) {   
                                                    xmlBody += '<Shipper>';
                                                        xmlBody += '<StreetLines>' + dhlCre.Shipper_Street__c.escapeXml() + '</StreetLines>';
                                                        xmlBody += '<City>'+ dhlCre.Shipper_City__c.escapeXml() +'</City>';
                                                        xmlBody += '<PostalCode>'+ dhlCre.Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';
                                                        if(shipperCountryCode != null) xmlBody += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';
                                                    xmlBody += '</Shipper>';
                                                }
                                                if(currentOrder != null) {
                                                    xmlBody += '<Recipient>';
                                                        xmlBody += '<StreetLines>' + shipAddress_Street.escapeXml() + '</StreetLines>';
                                                        xmlBody += '<City>' + currentOrder.ERP7__Ship_To_Address__r.ERP7__City__c.escapeXml() + '</City>';
                                                        xmlBody += '<PostalCode>' + currentOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c .escapeXml() + '</PostalCode>';
                                                        if(shipAddress_CountryCode != null) xmlBody += '<CountryCode>' + shipAddress_CountryCode.escapeXml() + '</CountryCode>';
                                                    xmlBody += '</Recipient>';
                                                }
                                            xmlBody += '</Ship>';
                                            for(Integer i=0; i<=noOfPackages; i++) {
                                                xmlBody += '<Packages>';
                                                    xmlBody += '<RequestedPackages number="'+ i+1 +'">';
                                                    xmlBody += '<Weight>';
                                                        xmlBody += '<Value>'+ pkgWeight +'</Value>';
                                                    xmlBody += '</Weight>';
                                                    xmlBody += '<Dimensions>';
                                                        xmlBody += '<Length>'+ pkgLength +'</Length>';
                                                        xmlBody += '<Width>'+ pkgWidth +'</Width>';
                                                        xmlBody += '<Height>'+ pkgHeight +'</Height>';
                                                    xmlBody += '</Dimensions>';
                                                    xmlBody += '</RequestedPackages>';
                                                xmlBody += '</Packages>';
                                            }
                                            xmlBody += '<ShipTimestamp>'+ shipDate +'</ShipTimestamp>';
                                            xmlBody += '<UnitOfMeasurement>SU</UnitOfMeasurement>';
                                            xmlBody += '<Content>NON_DOCUMENTS</Content>';
                                            xmlBody += '<PaymentInfo>DDP</PaymentInfo>';
                                            xmlBody += '<Account>' + dhlCre.UPS_Account_Number__c.escapeXml() + '</Account>';
                                        xmlBody += '</RequestedShipment>';
                                    xmlBody += '</RateRequest>';
                                xmlBody += '</soap:Body>';
                            xmlBody += '</soap:Envelope>';

                            HttpRequest req = new HttpRequest();
                            req.setEndpoint('https://wsbexpress.dhl.com/sndpt/expressRateBook');
                            req.setMethod('POST');
                            req.setHeader('Content-Type', 'text/xml'); 
                            req.setBody(xmlBody);
                            //request_1 = xmlBody; 
                             
                            Http http = new Http();
                            HttpResponse res = http.send(req);
                            String resStatus = res.getStatus();  
                            //response_1 = res.getBody();
                            
                            if(resStatus == 'OK') {
                                XmlStreamReader reader1 = res.getXmlStreamReader(); 
                                string msg  = readXMLResponseWithAtt(reader1, 'Notification', 'code');
                                if(integer.ValueOf(msg) == 0) {
                                    XmlStreamReader reader = res.getXmlStreamReader();
                                    rateWrapper rw; List<rateWrapper> rateWrapperLst = new List<rateWrapper>();
                                    while(reader.hasNext()) {
                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Provider'){
                                            while(reader.hasNext()) { rw = new rateWrapper();
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Service') {
                                                    rw.service = reader.getAttributeValue(reader.getNamespace(),'type'); reader.next();reader.next();
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNet') { reader.next();reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next();
                                                            if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); reader.next();reader.next();reader.next();
                                                        }
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); 
                                                            if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText();   
                                                        }
                                                    } reader.next();
                                                    Boolean nameFound = false;
                                                    while(!nameFound){
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ChargeType') {
                                                            reader.next(); rw.serviceName = reader.getText(); break;
                                                        }
                                                        reader.next();
                                                    }
                                                    Boolean found = false;
                                                    while(!found){
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'DeliveryTime') {
                                                            reader.next(); rw.CommitmentDate = reader.getText(); break;
                                                        }
                                                        reader.next();
                                                    }
                                                    rateWrapperLst.add(rw);
                                                }
                                                if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'Provider') break; else reader.next();
                                            }
                                        } reader.next();
                                    }
                                    upsWrapp.Services = rateWrapperLst; upsWrapp.UPSErrorMsg = 'Available Services For The Selected Location'; 
                                }
                                else{
                                    XmlStreamReader reader3 = res.getXmlStreamReader(); String msg2 = readXMLResponse(reader3, 'Message'); upsWrapp.UPSErrorMsg = 'Shipping Rate is not available : ' + msg2;
                                }
                            } else upsWrapp.UPSErrorMsg = 'Result not available';

                        } catch(Exception e) { upsWrapp.UPSErrorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
                    } 
                }  
            }
        }
        return upsWrapp;
    } 

    public static String readXMLResponseWithAtt(XmlStreamReader reader, String sxmltag, string attLocalName) {
        String retValue = ''; // Read through the XML
        try {                                                                        
            while (reader.hasNext()) {              
                if (reader.getEventType() == XmlTag.START_ELEMENT) { 
                    if (sxmltag == reader.getLocalName()) {   retValue = reader.getAttributeValue(reader.getNamespace(),attLocalName);   }
                } reader.next(); 
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
        return retValue;
    }*/
    
    public class upsWrap {
        @AuraEnabled public String PackageType                      { get; Set; } 
        @AuraEnabled public List<SelectOptions> PackageTypes        { get; Set; }
        @AuraEnabled public Date ShipmentDate                       { get; Set; } 
        @AuraEnabled public Decimal Length                          { get; Set; } 
        @AuraEnabled public Decimal Width                           { get; Set; } 
        @AuraEnabled public Decimal Height                          { get; Set; } 
        @AuraEnabled public Decimal Weight                          { get; Set; } 
        @AuraEnabled public Decimal NoofPackage                     { get; Set; } 
        @AuraEnabled public Decimal Additional                      { get; Set; } 
        @AuraEnabled public Decimal PackageVolume                   { get; Set; } 
        @AuraEnabled public Decimal SOVolume                        { get; Set; } 
        @AuraEnabled public Decimal SOWeight                        { get; Set; } 
        @AuraEnabled public Decimal TotalWeight                     { get; Set; } 
        @AuraEnabled public Decimal WeightPerPack                   { get; Set; }
        @AuraEnabled public String UPSErrorMsg                      { get; Set; }
        @AuraEnabled public String Result                           { get; Set; }
        @AuraEnabled public List<rateWrapper> Services              { get; Set; }
        public upsWrap() {
            PackageType = Null;
            UPSErrorMsg = Null;
            Result = Null;
            WeightPerPack = Null; 
            SOWeight = Null; SOVolume = Null;
            PackageVolume = Null;
            Additional = Null;
            NoofPackage = Null;
            Weight = Null;
            Height = Null;
            Width = Null;
            Length = Null;
            ShipmentDate  = Null;   
            Services = new List<rateWrapper>(); 
        }
    } 
     
    //@AuraEnabled public List<rateWrapper> rateWrapperList       { get; set; }
    public class rateWrapper {
        @AuraEnabled public String Service                      { get; set; }                   
        @AuraEnabled public String ServiceName                  { get; set; }                   
        @AuraEnabled public Date DeliveryDate                   { get; set; }
        @AuraEnabled public String ServiceCode                  { get; set; }
        @AuraEnabled public String totalCharges                 { get; set; }
        @AuraEnabled public String totalSurcharges              { get; set; }
        @AuraEnabled public String currencyCode                 { get; set; }
        @AuraEnabled public String CommitmentDate               { get; set; }   
        @AuraEnabled public String DeliveryDateS                { get; set; }
        @AuraEnabled public String ServiceManual                { get; set; }
        @AuraEnabled public String negotiatedCharges            { get; set; }   
        @AuraEnabled public String TransportationCharges        { get; set; }   
        @AuraEnabled public String ServiceOptionsCharges        { get; set; } 
        @AuraEnabled public String ScheduledDeliveryTime        { get; set; }
        @AuraEnabled public String GuaranteedDaysToDelivery     { get; set; }  
        @AuraEnabled public Boolean Selected                    { get; set; }                 
        
        public rateWrapper() {  
            Service = '';
            ServiceName = '';
            currencyCode = '';
            CommitmentDate = '';
            DeliveryDate = null;
            DeliveryDateS = '';            
            ServiceManual = '';
            ServiceCode = '';
            totalCharges = '';
            totalSurcharges = ''; 
            negotiatedCharges = '';
            TransportationCharges = '';
            ServiceOptionsCharges = '';            
            GuaranteedDaysToDelivery = '';
            ScheduledDeliveryTime = '';  
            Selected = false;      
        }           
    }  
    
    
    @AuraEnabled 
    public static String saveEstimateService(String ord){
        String message='';
        try{
            Order currentOrder = (Order) JSON.deserialize(ord, Order.class);
            
            //DML Operation
            
             if(Schema.sObjectType.Order.isUpdateable())
            update currentOrder;
            
            if(currentOrder.Id != null)
                message='Shipping estimate save successfully.';
        }catch(Exception e){ message=e.getMessage()+'   Line:'+e.getLineNumber(); }        
        return message;
    }
    
    @AuraEnabled
    public static String updateAccInfo(String acc){
        String message='';
        try{
            Account acc2Update= (Account) JSON.deserialize(acc, Account.class); 
            
            //DML Operation
            
            if(Schema.sObjectType.Account.isUpdateable())
            update acc2Update;
            
            message='Account updated successfully';
        }catch(Exception e){message=e.getMessage()+'    Line:'+e.getLineNumber();}
        return message;
    }
    
    @AuraEnabled
    public static String insertNewAcc(String acc){
        System.debug('Accounts Details From Js side::~>'+acc);
        String message='';
        try{
            Account acc2Upsert= (Account) JSON.deserialize(acc, Account.class);
            System.debug('Accounts Details After Deserialization::~>'+acc2Upsert);
            if(acc2Upsert.Id == null){
                if(Schema.SObjectType.Account.fields.ERP7__Active__c.isCreateable())acc2Upsert.ERP7__Active__c = 'Yes';
                List<RecordType> rTypes = [Select Id, Name from RecordType Where SobjectType = 'Account' And (Name = 'Person Account' Or Name = 'PersonAccount')];
                if(rTypes.size() > 0) acc2Upsert.RecordTypeId = rTypes[0].Id;
                System.debug('RecordTypeId::~>'+acc2Upsert.RecordTypeId);
            }
            
            //DML Operation
            if(Schema.SObjectType.Account.isCreateable())
            insert acc2Upsert;
            
            if(acc2Upsert.Id != null){
                message=acc2Upsert.Id;
            }            
        }catch(Exception e){message=e.getMessage()+'    Line No:'+e.getLineNumber();}
        return message;
    }
    
    @AuraEnabled
    public static String insertContact(String con){
        String message='';
        try{
            Contact con2Upsert= (Contact) JSON.deserialize(con, Contact.class);
            
            //DML Operation 
            
            if(Schema.SObjectType.Contact.isCreateable())
            insert con2Upsert;
            
            if(con2Upsert.Id != null){
                message=con2Upsert.Id;
            }            
        }catch(Exception e){message=e.getMessage()+'    Line No:'+e.getLineNumber();}
        return message;
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(string contrfieldApiName,string depfieldApiName) {  //sObject objDetail,
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = ERP7__Address__c.getSObjectType();
        //Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){  return objResults; }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){   return objResults;    }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);  
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();  
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());  
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();  objResults.put(label, new List<String>());  controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {  String label = plew.label;  String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) { String bit = validForBits.mid(i, 1);
                if (bit == '1') {  objResults.get(controllingValues.get(i)).add(label);   }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);  
            val = Integer.valueOf(Math.floor(val / 2));  
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);  
            Integer val = base64Chars.indexOf(thisChar); 
            String bits = decimalToBinary(val).leftPad(6, '0');  
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {        
        return (List<PicklistEntryWrapper>) JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    public class PicklistEntryWrapper{
        public String active {get;set;}  
        public String defaultValue {get;set;}  
        public String label {get;set;}  
        public String value {get;set;}  
        public String validFor {get;set;}        
        public PicklistEntryWrapper(){   }
        
    }
    
    @AuraEnabled
    public static String createNewAddress(String addrs){
        String message='';
        try{
            ERP7__Address__c address = (ERP7__Address__c) JSON.deserialize(addrs, ERP7__Address__c.class);
            
            //DML Operation
            
            if(Schema.SObjectType.ERP7__Address__c.isCreateable())
            insert address;
            
            if(address.Id != null){
                message=address.Id;
            }
        }catch(Exception e){message=e.getMessage()+'    Line No:'+e.getLineNumber();}
        return message;
    }  

    @AuraEnabled
    public static SubPlanWrapper getselectedplanDetails (string selectedPlan_Id){
        SubPlanWrapper selectedplanwrap = new SubPlanWrapper(); 
        try{            
            if(String.isNotEmpty(SelectedPlan_Id))
            selectedplanwrap.SelectedsubPlan  = [select Id,Name,ERP7__Subscription_Plan__r.ERP7__Duration__c,ERP7__Subscription_Plan__r.ERP7__Order_Delivery_Frequency__c from ERP7__Product_Subscription_Plan_Allocation__c where Id =: selectedPlan_Id and ERP7__Active__c =:true];
       	    System.debug('SelectedPlan Details::'+selectedplanwrap.SelectedsubPlan);
        }
        catch(Exception e){selectedplanwrap.errorMsg=e.getMessage() +' Line Number @ : '+ e.getLineNumber();}        
        return selectedplanwrap;
    }
    public class SubPlanWrapper{
        @AuraEnabled public String errorMsg									                { get; set; }
        @AuraEnabled public ERP7__Product_Subscription_Plan_Allocation__c  SelectedsubPlan	{ get; set; }
        public SubPlanWrapper(){
            errorMsg = '';
            SelectedsubPlan = new ERP7__Product_Subscription_Plan_Allocation__c ();
        }
    }
}