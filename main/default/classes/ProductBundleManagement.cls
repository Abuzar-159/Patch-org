global with sharing class ProductBundleManagement {

    
   // public Product_Bundle_Group_Profile_Allocation__c addProductBundleProfileAlloc       { get; set; }
    
    public Product2 addProductBundle                                      { get; set; } public Product2 addNewProductBundle                                   { get; set; }
   
    public BOM__c addProductBundleAlloc                      { get; set; }     public List<Schema.FieldSetMember> ProductBundleAllocFieldsets                       { get; set; } 
    public String ProductBunldeFields                                                    { get; set; }    
    public String productserviceFields                                                   { get; set; }public String PBGPAFields                                                            { get; set; } 
    public String PBGAFields                                                             { get; set; }   public String CustProfileFields                                                      { get; set; }   
    public String bundleId                                                               { get; set; }   
  //  public List<Product_Bundle_Group_Profile_Allocation__c> availableProfileList         { get; set; } 
    public List<Id> availableProfileListIds                                              { get; set; }
    public List<BOM__c> availableProductList                 { get; set; } public List<Schema.FieldSetMember> ProductBundleFieldsets                            { get; set; }
    public List<Id> availableProductListIds                                              { get; set; }  
    public List<BOM__c> availableRemAccList                  { get; set; } public List<Schema.FieldSetMember> ProductBundleProfileAllocFieldsets                { get; set; }
    public List<itemWrapper> itemWrapperList                                             { get; set; }   public List<itemWrapper> AitemWrapperList                                            { get; set; }    
    public List<itemWrapper> SitemWrapperList                                            { get; set; }    
    public List<itemWrapper> ARemitemWrapperList                                         { get; set; }
    public List<itemWrapper> AAccitemWrapperList                                         { get; set; }
    public List<itemWrapper> SRemitemWrapperList                                         { get; set; }
    public List<itemWrapper> SAccitemWrapperList                                         { get; set; }
    public List<Id> selectedProducts                                                     { get; set; }
    public List<Product2> allProducts                                          { get; set; }  public List<Product2> recommendationProducts                               { get; set; }  
    public Set <Id> custProfileIds                                                       { get; set; }  public List<Product2> accessoryProducts                                    { get; set; }    
          
    public Product2 ps                                                         { get; set; }   public Integer ItemPos                                                               { get; set; }                                                  
    public String CurrentTab                                                             { get; set; }
    public Boolean PBGtab                                                                { get; set; }
    public Boolean PBGAtab                                                               { get; set; }
    public Boolean PBGPAtab                                                              { get; set; }
    public Boolean PBGUCtab                                                              { get; set; }
    public String removalValue                                                           { get; set; } 
    public String errorMsg                                                               { get; set; }     public Integer profileListSize                                                       { get; set; }
    
     
    public Boolean showProfileTextBox                                                    { get; set; }  public Integer upAndCrossSellListSize                                                { get; set; }  
    public Boolean showProductTextBox                                                    { get; set; }  public Integer productListSize                                                       { get; set; }  
    public Boolean showRecommendationTextBox                                             { get; set; }  public Boolean hasAccess                           { get; set; } 
    public Boolean showAccessoryTextBox                                                  { get; set; }   public Boolean displayPanel                                                          { get; set; }
    public Boolean showSaveBtn                                                           { get; set; }  public String errormsg2                             { get; set; }      
    
    
    
    
    global ProductBundleManagement () {
     addProductBundle = new Product2(); addProductBundleAlloc = new BOM__c(); ProductBunldeFields = UtilClass.selectStarFromSObject('Product2');  UtilClass.FlSCheck(ProductBunldeFields.split(',') ,'Product2');
     PBGAFields =  UtilClass.selectStarFromSObject('ERP7__BOM__c');UtilClass.FlSCheck(PBGAFields.split(',') ,'ERP7__BOM__c');productserviceFields = UtilClass.selectStarFromSObject('Product2'); UtilClass.FlSCheck(productserviceFields.split(',') ,'Product2');
       SitemWrapperList = new List < itemWrapper > ();allProducts = new List <Product2> ();itemWrapperList = new List<itemWrapper>();
        SRemitemWrapperList = new List<itemWrapper>(); SAccitemWrapperList = new List<itemWrapper>(); ps = new Product2();
        selectedProducts = new List<Id>();custProfileIds = new Set<Id>();availableProfileListIds = new List<Id>();
        availableProductList = new List<BOM__c>(); availableProductListIds = new List<Id>();availableRemAccList = new List<BOM__c>(); 
        SCustomerProfileWrapperList = new List < ProductsAndDiscounts > (); this.CurrentTab='tab1';
        PBGtab = false;PBGAtab = true; PBGPAtab = true; PBGUCtab = true;
        showProfileTextBox = false;   showProductTextBox = false; showRecommendationTextBox = false;
        showAccessoryTextBox = false; showSaveBtn = false;
        if(ApexPages.CurrentPage().getParameters().get('id') != null)bundleId = String.escapeSingleQuotes(EncodingUtil.urlEncode(ApexPages.CurrentPage().getParameters().get('id'),'UTF-8'));
        if(bundleId != null) {
            if(Schema.sObjectType.Product2.isAccessible())
            addProductBundle = Database.query('select ' + String.escapeSingleQuotes(ProductBunldeFields) + ' from Product2 where ' +
                        '(Id = \'' + String.escapeSingleQuotes(bundleId) + '\')');                                
                       
            if(Schema.SObjectType.BOM__c.isAccessible())
            availableProductList = Database.query('select ' + String.escapeSingleQuotes(PBGAFields) + ' from BOM__c where ' +
                        '(Active__c = true And BOM_Product__r.Is_Kit__c = True AND Type__c = \'Kit\')');
            productListSize = availableProductList.size();
            for(BOM__c pbga : availableProductList) {availableProductListIds.add(pbga.BOM_Product__c); }
            
            // fetch available Recommended & Accessory list 
            if(Schema.SObjectType.BOM__c.isAccessible())
            availableRemAccList = Database.query('select ' + String.escapeSingleQuotes(PBGAFields) + ', BOM_Component__r.SKU__c, BOM_Component__r.Name, BOM_Component__r.Picture__c from BOM__c where ' +                              
                        '(Active__c = true )');   upAndCrossSellListSize = availableRemAccList.size(); if(profileListSize > 0 || productListSize > 0) displayPanel = true;
        }
    }
    
    /*
      Method For Getting Products List Based On Name & Cateogry
    */
    global PageReference searchProduct() {
       return null;
    }                      
    
    /*
      Method For Adding Item To Wrapper List
    */
    global PageReference addItem() {
        return null;
    }
    
    /*
      Method For Fetching Available Customer Profile
    */
    global PageReference searchProfiles() {
        return null;
       
    }
    
    
    /*
      Method For Adding Customer Profile To Wrapper List
    */
    global PageReference addCustProfiles() {
        return null;
    }
    
    /*
      Method For Adding Recommendation 2 Products
    */
    global PageReference addRecommedation() {
        
        List <itemWrapper> selecteditemWrapperList = new List <itemWrapper> ();
        if(ARemitemWrapperList != null) { for (itemWrapper currentPd: ARemitemWrapperList) {if (currentPd.selected == true) {selecteditemWrapperList.add(currentPd);
                }
            }
        }
        //products Addition
        for (itemWrapper currentPd: selecteditemWrapperList) {itemWrapper Wrap = new itemWrapper(); Wrap.product = currentPd.product; Wrap.code = currentPd.product.SKU__c; Wrap.itm = currentPd.product.Name; Wrap.itmId = currentPd.product.id;  Wrap.ImagePreview = currentPd.product.Picture__c; Wrap.Price = currentPd.price; Wrap.Quantity = currentPd.Quantity; SRemitemWrapperList.add(Wrap);              
        }
        Integer a = 0;
        if(ARemitemWrapperList != null) { while (a < ARemitemWrapperList.size()) { if(ARemitemWrapperList.get(a).selected == true) { ARemitemWrapperList.remove(a);} else {a++;
                }
            }     
        }
        showRecommendationTextBox = true;
        return null;
    }
    
    /*
      Method For Adding Accessory 2 Products
    */
    global PageReference addAccessory() {
        
        List <itemWrapper> selecteditemWrapperList = new List <itemWrapper> ();
        if(AAccitemWrapperList != null) { for (itemWrapper currentPd: AAccitemWrapperList) { if (currentPd.selected == true) { selecteditemWrapperList.add(currentPd);
                }
            }
        }
        
        //products Addition
        for (itemWrapper currentPd: selecteditemWrapperList) { itemWrapper Wrap = new itemWrapper(); Wrap.product = currentPd.product; Wrap.code = currentPd.product.SKU__c; Wrap.itm = currentPd.product.Name; Wrap.itmId = currentPd.product.id;  Wrap.ImagePreview = currentPd.product.Picture__c; Wrap.Price = currentPd.price; Wrap.Quantity = currentPd.Quantity; SAccitemWrapperList.add(Wrap);              
        }
         Integer a = 0;
        if(AAccitemWrapperList != null) {while (a < AAccitemWrapperList.size()) { if(AAccitemWrapperList.get(a).selected == true) {  AAccitemWrapperList.remove(a); } else { a++;
                }
            }
        }
        showAccessoryTextBox = true;
        return null;
    }
    
    /*
      Method For Removing Items From ItemWrapperList
    */
    global PageReference removeItem() {
        
        if(removalValue == 'removeProfile') {  ACustomerProfileWrapperList.add(SCustomerProfileWrapperList.get(ItemPos)); SCustomerProfileWrapperList.remove(ItemPos); } 
        else if(removalValue == 'removeProduct') { AitemWrapperList.add(SitemWrapperList.get(ItemPos)); SitemWrapperList.remove(ItemPos); }
        else if(removalValue == 'removeRecommendation') { ARemitemWrapperList.add(SRemitemWrapperList.get(ItemPos)); SRemitemWrapperList.remove(ItemPos); }
        else if(removalValue == 'removeAccessory') { AAccitemWrapperList.add(SAccitemWrapperList.get(ItemPos)); SAccitemWrapperList.remove(ItemPos); }
        return null;
    }
    
    /*
      Method For Saving Bundle Record
    */
    global PageReference saveAll() {
        
        if(CurrentTab == 'tab1') { 
             
            if(addProductBundle.Name == null) { addProductBundle.Name.addError(System.Label.ProductBundleManagement_Name_Error); 
            } else { 
                CurrentTab = 'tab2'; PBGPAtab = false; PBGAtab = true;  PBGUCtab = true; showProfileTextBox = true;
                
               if(Schema.sObjectType.BOM__c.isCreateable()&& Schema.sObjectType.BOM__c.isUpdateable()) upsert addProductBundle; } } else if(CurrentTab == 'tab2') { CurrentTab = 'tab3'; PBGAtab = false;  PBGUCtab = true;showProductTextBox = true;for(ProductsAndDiscounts p : SCustomerProfileWrapperList) { } } else if(CurrentTab == 'tab3') { CurrentTab = 'tab4'; PBGUCtab = false; showRecommendationTextBox = true;showAccessoryTextBox = true;showSaveBtn = true; List<BOM__c> BOMList = new List<BOM__c>();for(itemWrapper item : SitemWrapperList) { BOM__c BOM = new BOM__c();BOM.Name = item.product.Name; BOM.BOM_Product__c = item.product.Id;BOM.Type__c = 'Kit';  BOMList.add(BOM); }if(BOMList.size() > 0 && Schema.sObjectType.BOM__c.fields.Name.isCreateable() && Schema.sObjectType.BOM__c.fields.Name.isUpdateable() && Schema.sObjectType.BOM__c.fields.BOM_Product__c.isCreateable() && Schema.sObjectType.BOM__c.fields.BOM_Product__c.isUpdateable() && Schema.sObjectType.BOM__c.fields.Type__c.isCreateable()&& Schema.sObjectType.BOM__c.fields.Type__c.isUpdateable()){hasAccess=true; upsert BOMList;}    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
            if(Schema.sObjectType.Product2.isAccessible()) recommendationProducts = Database.query('select ' + String.escapeSingleQuotes(productserviceFields) + ' from Product2 where ' +
                '(Id Not In : SelectedProducts And isActive = true And Family = \''+ String.escapeSingleQuotes(ps.Family) +'\' And isAccessory__c = false) limit 10');  List < Id > RproductIds = new List < Id > (); for(Product2 p : recommendationProducts) {RproductIds.add(p.Id);}     RAWrapperDetails(recommendationProducts, RproductIds, 'Recommendation');
            if(Schema.sObjectType.Product2.isAccessible()) accessoryProducts = Database.query('select ' + String.escapeSingleQuotes(productserviceFields) + ' from Product2 where ' +
                '(isActive = true And isAccessory__c = true And Tag_Name__c = \'' + String.escapeSingleQuotes(ps.Family) + '\') limit 10');   List < Id > AproductIds = new List < Id > (); for(Product2 p : accessoryProducts) {AproductIds.add(p.Id);}  RAWrapperDetails(accessoryProducts, AproductIds, 'Accessory'); } else if(CurrentTab == 'tab4') {showSaveBtn = true;List<BOM__c> RpbgaList = new List<BOM__c>(); for(itemWrapper item : SRemitemWrapperList) { BOM__c Rpbga = new BOM__c();Rpbga.Name = item.product.Name; Rpbga.BOM_Product__c = item.product.Id;Rpbga.Type__c = 'Kit';RpbgaList.add(Rpbga);} if(RpbgaList.size() > 0 && Schema.sObjectType.BOM__c.fields.Name.isCreateable() && Schema.sObjectType.BOM__c.fields.Name.isUpdateable() && Schema.sObjectType.BOM__c.fields.BOM_Product__c.isCreateable() && Schema.sObjectType.BOM__c.fields.BOM_Product__c.isUpdateable() && Schema.sObjectType.BOM__c.fields.Type__c.isCreateable() && Schema.sObjectType.BOM__c.fields.Type__c.isUpdateable()){hasAccess=true; upsert RpbgaList;}else{hasAccess=false; errormsg2='You are not allowed to create or update records'; }List<BOM__c> ApbgaList = new List<BOM__c>(); for(itemWrapper item : SAccitemWrapperList) { BOM__c Apbga = new BOM__c();Apbga.Name = item.product.Name; Apbga.BOM_Product__c = item.product.Id;Apbga.Type__c = 'Kit'; ApbgaList.add(Apbga);} if(ApbgaList.size() > 0 && Schema.sObjectType.BOM__c.fields.Name.isCreateable() && Schema.sObjectType.BOM__c.fields.Name.isUpdateable() && Schema.sObjectType.BOM__c.fields.BOM_Product__c.isCreateable() && Schema.sObjectType.BOM__c.fields.BOM_Product__c.isUpdateable() && Schema.sObjectType.BOM__c.fields.Type__c.isCreateable() && Schema.sObjectType.BOM__c.fields.Type__c.isUpdateable()){hasAccess=true; upsert ApbgaList; }    else{ hasAccess=false; errormsg2='You are not allowed to create or update records'; }
        }
        return null;
    }
    global void RAWrapperDetails(List<Product2> R_AProducts, List<Id> R_AProdutIds, String value) {
        
     }
    
    
    /*
       go Get Discounts of a Particular Product/Services for a Particular Sales Orders
    */
    
    public List < ProductsAndDiscounts > SCustomerProfileWrapperList { get; set; } public List < ProductsAndDiscounts > ACustomerProfileWrapperList { get; set; }
    
    global class ProductsAndDiscounts {
       
        global Decimal price                              { get; set; }  global Product2 product                 { get; set; }
        global Boolean selected                           { get; set; }
        global String ImagePreview                        { get; set; }
        //public Customer_Profile__c custProfile            { get; set; }
        global String Organisation                        { get; set; }
        global String Businessunit                        { get; set; }
        global String profileName                         { get; set; }
                        
        global ProductsAndDiscounts() {
            price = 0;
            selected = false;
            ImagePreview = '';
            Organisation = '';
            BusinessUnit = '';
            profileName = '';
        }
    }
    
    /*
        Wrapper Class For Product/Services --> Items
    */
    global class itemWrapper {
        
        global String code                                { get; set; }  global Product2 product                 { get; set; }
        global String itm                                 { get; set; } 
        global String itmId                               { get; set; }
        global String ImagePreview                        { get; set; }
        global Decimal price                              { get; set; } 
        //public Customer_Profile__c custProfile            { get; set; }
        global String Organisation                        { get; set; }
        global String Businessunit                        { get; set; }
        global String profileName                         { get; set; }
        global Boolean Selected                           { get; set; } 
        global Decimal Quantity                           { get; set; } 
        
        /*
            Inner Constructor For Wrapper Class 
        */
        global itemWrapper() {
            code = '';
            itm = '';
            itmId = '';
            ImagePreview = '';
            price = 0;
            Organisation = '';
            BusinessUnit = '';
            profileName = '';
            Selected =false;
            Quantity = 0;
        }
    }
}