public with sharing class ProductList {    
                   
    @AuraEnabled
    public static productDisplayWrapper fetchProducts(String accID, String profileID, String family)//String channelID,
    { 
        
        productDisplayWrapper prod = new productDisplayWrapper();
        prod.acc = [Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accID and ERP7__Order_Profile__c=:profileID];
        
        //RecordType rec = [Select Id From RecordType where sobjecttype = 'ERP7__Profiling__c' and name in ('Order Profile')];
        
        prod.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:prod.acc.ERP7__Order_Profile__c];
        Set<Id> pricebookIds = new Set<Id>();
        for(ERP7__Profiling__c profile: prod.profiling){
            pricebookIds.add(profile.ERP7__Price_Book__c);
        }
        
        prod.pricebook = [Select Id, Name, isActive from PriceBook2 where isActive=true and Id in: pricebookIds];
        
        List<PricebookEntry> priceBookList;
        if(family != null)
        priceBookList = [Select Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id in: pricebookIds and Product2.family=:family];        else  priceBookList = [Select Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id in: pricebookIds];
        
        Set<Id> productIds = new Set<Id>();
        for(PricebookEntry pbe: priceBookList)
            productIds.add(pbe.Product2Id);
        
        prod.channel = [Select Id, Name, ERP7__Ship_From_Address__c, ERP7__Shipper_Name__c, ERP7__Company__c, ERP7__Phone__c,
                   ERP7__Active__c, ERP7__City__c, ERP7__Street__c, ERP7__State_Province__c, ERP7__Country__c, ERP7__Zip_Postal_Code__c
                   from ERP7__Channel__c where Id=:prod.profiling[0].ERP7__Channel__c and ERP7__Active__c=true];
        
        prod.DistributionChannels = [Select Id, Name, ERP7__Active__c, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                     where ERP7__Channel__c=:prod.channel.Id and ERP7__Active__c=true];
        
        List < Id > siteIds = new List < Id > ();
                if(prod.DistributionChannels.size() > 0) {                    for(Distribution_Channel__c DC: prod.DistributionChannels) {  siteIds.add(DC.Site__c); }
                }
        
        if(productIds.size() > 0) {
            prod.WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                 Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,
                                                 Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                 From Inventory_Stock__c
                                                 Where product__c In: productIds And
                                                 Active__c = true And
                                                 Warehouse__c In: siteIds And
                                                 Number_of_Item_In_Stock__c > 0];
            
            prod.SILIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Available__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                       Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c
                       From ERP7__Stock_Inward_Line_Item__c 
                       Where ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds];
            
        }
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        for(Inventory_Stock__c inven : prod.WarehouseItemInventoryStocks){  stockView.put(inven.product__c, inven.Number_of_Item_In_Stock__c);
        }
        
        prod.cartList = [Select Id, Name, ERP7__Account__c, ERP7__Account__r.ERP7__Order_Profile__c,ERP7__Account__r.ERP7__Order_Profile__r.ERP7__Price_Book__c, ERP7__Channel__c, 
                                        ERP7__Site__c from ERP7__Cart__c where ERP7__Account__c=:accID];
        
        for(PricebookEntry pbe: priceBookList){
            PriceBookEntryWrapper wrapper = new PriceBookEntryWrapper();
            wrapper.pbe = pbe;
            wrapper.stock = (stockView.get(pbe.Product2Id)!= null)? stockView.get(pbe.Product2Id):0.00;
            
            wrapper.versionList = [Select Id, Name, ERP7__Active__c, ERP7__Category__c, ERP7__Inventory_Stock__c, ERP7__Status__c,
                                ERP7__Start_Date__c, ERP7__To_Date__c, ERP7__Sales_Ready__c from ERP7__Version__c 
                                where ERP7__Product__c =: pbe.Product2Id];
                
                prod.pbeList.add(wrapper);
            
        }
        return prod; 
    }
    
    @AuraEnabled
    public static productDisplayWrapper saveCarts(String accID, String profileID)
    {
        
        productDisplayWrapper cartSave = new productDisplayWrapper();
        cartSave.acc = [Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accID and ERP7__Order_Profile__c=:profileID];
        
        //RecordType rec = [Select Id From RecordType where sobjecttype = 'ERP7__Profiling__c' and name in ('Order Profile')];
        
        cartSave.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:cartSave.acc.ERP7__Order_Profile__c];
        Set<Id> pricebookIds = new Set<Id>();
        for(ERP7__Profiling__c profile: cartSave.profiling){
            pricebookIds.add(profile.ERP7__Price_Book__c);
        }
        cartSave.cartList = [Select Id, Name, ERP7__Account__c, ERP7__Account__r.ERP7__Order_Profile__c,ERP7__Account__r.ERP7__Order_Profile__r.ERP7__Price_Book__c, ERP7__Channel__c, 
                                        ERP7__Site__c from ERP7__Cart__c where ERP7__Account__c=:accID];
        
        cartSave.pricebook = [Select Id, Name, isActive from PriceBook2 where isActive=true and Id in: pricebookIds];//cartSave.cartList[0].ERP7__Account__r.ERP7__Order_Profile__r.ERP7__Price_Book__c
        
        List<PricebookEntry> priceBookList = [Select Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c from PricebookEntry where Pricebook2Id in: pricebookIds];//=:cartSave.pricebook[0].Id];
        
        ERP7__Cart_Picked_Item__c cpi;
        List<ERP7__Cart_Picked_Item__c> cpiList;
        for(PricebookEntry pbe: priceBookList){        
            PriceBookEntryWrapper wrapper = new PriceBookEntryWrapper(); 
            wrapper.pbe = pbe;
                cpi = new ERP7__Cart_Picked_Item__c();
                cpi.Name= pbe.Product2.Name;
                cpi.ERP7__Cart__c = cartSave.cartList[0].Id;
                cpi.ERP7__Product__c = wrapper.pbe.Product2ID;
                //cpiList.add(cpi);            
        }
        if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isUpdateable()){ upsert cpi;}else{ }
        return cartSave;
    }
    
    @AuraEnabled
    public static ERP7__Coupon_Redemption__c applyCoupons(String Coupon, Decimal totalPrice, String accID){
        
        List<ERP7__Coupon_Issued__c> CI = [Select Id, Name, ERP7__Product__c, ERP7__Account__c, ERP7__Coupon__c, ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c, ERP7__Coupon__r.Name, ERP7__Coupon__r.ERP7__Value__c, ERP7__Coupon__r.ERP7__Value_In_Percent__c, ERP7__Coupon__r.ERP7__Start_Date__c, ERP7__Coupon__r.ERP7__End_Date__c, ERP7__Coupon__r.ERP7__Account__c, ERP7__Issued_Date__c, ERP7__Value__c, ERP7__Voucher_Amount__c, ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c, ERP7__Coupon__r.RecordType.Name, ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c
                                                From ERP7__Coupon_Issued__c 
                                                Where ERP7__Coupon__r.Name =:Coupon And ERP7__Coupon__r.ERP7__Account__c=:accID And
                                                ERP7__Coupon__r.ERP7__Start_Date__c <= Today And 
                                                ERP7__Coupon__r.ERP7__End_Date__c >= Today 
                                                Limit 1];//And (ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c = Null Or ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c <= :totalPrice) 
        
        if(CI.size()>0){ ERP7__Coupon_Issued__c cissued = CI[0];    ERP7__Coupon_Redemption__c cr = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =cissued.ERP7__Coupon__c, ERP7__Coupon_Issued__c=cissued.Id, ERP7__Account__c=accID, ERP7__Redemption_Date__c=cissued.ERP7__Issued_Date__c,  ERP7__Value__c= totalPrice * (cissued.ERP7__Coupon__r.ERP7__Value_In_Percent__c/100)); return cr;  
        }
        return null;
    }   
    
    @AuraEnabled
    public static ERP7__Sales_Order__c saveSO(String cartProducts, String accID, String profileID,String coupon1){ List<ERP7__Coupon_Redemption__c> coupon =( List<ERP7__Coupon_Redemption__c>) JSON.deserialize(coupon1,  List<ERP7__Coupon_Redemption__c>.class); List<PriceBookEntryWrapper> selectedProducts = (List<PriceBookEntryWrapper>) JSON.deserialize(cartProducts, List<PriceBookEntryWrapper>.class);        List<Contact> contactList = [Select Id, Name, AccountId, Email, ERP7__Primary__c from Contact where AccountId=:accID order by ERP7__Primary__c Desc Limit 1];        
        Contact con = contactList[0];        List <Address__c> billingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c, Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c, Organisation__c, Organisation_Business_Unit__c From Address__c Where Contact__c = : con.ID];        Address__c add = billingAddresses[0];  ERP7__Profiling__c profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:profileID];        
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c(Name='', ERP7__Status__c='Booked', ERP7__Order_Status__c='Entered',ERP7__Channel__c=profiling.ERP7__Channel__c, ERP7__Account__c=accID, ERP7__Order_Profile__c=profileID, ERP7__Contact__c=con.Id, ERP7__Authorised__c=true,  ERP7__Customer_Email__c=con.Email, ERP7__Bill_To_Address__c=add.Id, ERP7__Ship_To_Address__c=add.Id);        if(Schema.sObjectType.ERP7__Sales_Order__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Channel__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Profile__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Authorised__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Customer_Email__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Bill_To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Ship_To_Address__c.isCreateable()){upsert so;}else{ }
        List<ERP7__Sales_Order_Line_Item__c> soli2Insert = new List<ERP7__Sales_Order_Line_Item__c>(); for(PriceBookEntryWrapper pdw : selectedProducts){            ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(ERP7__Sales_Order__c=so.Id);            soli.ERP7__Product__c = pdw.pbe.Product2.Id;  soli.ERP7__Quantity__c = pdw.pbe.Product2.ERP7__MOQ__c;            soli.ERP7__Base_Price__c = pdw.pbe.UnitPrice;  soli.ERP7__Order_Line_Status__c = 'Reserved';            soli.ERP7__Total_Price__c = pdw.pbe.UnitPrice * pdw.pbe.Product2.ERP7__MOQ__c;   soli.ERP7__Inventory_Tracked__c = true;  soli2Insert.add(soli);  }
        if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Inventory_Tracked__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Inventory_Tracked__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isUpdateable()){ upsert soli2Insert;} else{ } List<ERP7__Coupon_Redemption__c> CRList =(List<ERP7__Coupon_Redemption__c>)coupon; if(CRList != null && CRList.size()>0){  for(Integer i=0;i<CRList.size();i++) CRList[i].ERP7__Sales_Order__c=so.Id; if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isUpdateable()){ upsert CRList;} else{ } }        return so;
    }
    
    @AuraEnabled
    public static String getDeleteProducts()
    {
        return '';
    }
    
    @AuraEnabled
    public static List<AggregateResult> getPickList(){
        List<AggregateResult> productList = [Select Count(Id) total,Family type FROM Product2  Group by Family limit 10000];
        return productList;
    }
    
    public class PriceBookEntryWrapper{ 
        @AuraEnabled
        public List<ERP7__Version__c> versionList {get; set;}
        @AuraEnabled 
        Public PriceBookEntry pbe { get; set; }    
        @AuraEnabled 
        Public Decimal stock { get; set; }
        public PriceBookEntryWrapper(){ 
            pbe = new PriceBookEntry();
            stock = 0.00;
        }
    }
    public class productDisplayWrapper{ 
        @AuraEnabled public List<ERP7__Cart__c> cartList {get; set;}
        @AuraEnabled public List<ERP7__Cart_Picked_Item__c> cartpickitemList {get; set;}
        @AuraEnabled public List<PriceBookEntryWrapper> pbeList {get; set;}
        @AuraEnabled public List<PriceBook2> pricebook {get; set;}
        @AuraEnabled public Account acc {get; set;}
        @AuraEnabled public List<ERP7__Profiling__c> profiling {get; set;}
        @AuraEnabled public ERP7__Channel__c channel {get; set;}
        @AuraEnabled public List < Distribution_Channel__c > DistributionChannels {get; set;}
        @AuraEnabled public List < Inventory_Stock__c > WarehouseItemInventoryStocks {get; set;}
        @AuraEnabled public List<ERP7__Stock_Inward_Line_Item__c>  SILIs {get; set;} 
        @AuraEnabled public ERP7__Sales_Order__c so {get; set;}
        @AuraEnabled public List<ERP7__Sales_Order_Line_Item__c> soli {get; set;}        @AuraEnabled public Decimal stock {get; set;}
        public productDisplayWrapper(){
            pbeList = new List<PriceBookEntryWrapper>();     
            pricebook = new List<PriceBook2>();
            profiling = new List<ERP7__Profiling__c>();    
            channel = new ERP7__Channel__c();
            DistributionChannels = new List < Distribution_Channel__c >();
            WarehouseItemInventoryStocks = new List < Inventory_Stock__c >();     
            SILIs = new List<ERP7__Stock_Inward_Line_Item__c>();  
            so = new ERP7__Sales_Order__c();
            soli = new List<ERP7__Sales_Order_Line_Item__c>();
        }
    }
    public class returnClass {          
        @AuraEnabled public String errorMsg                      { get; set; }  @AuraEnabled public Boolean Error                        { get; set; } @AuraEnabled public String Value                         { get; set; }               public returnClass() {              errorMsg = '';            Value = '';             Error = false;   }        
    }
}