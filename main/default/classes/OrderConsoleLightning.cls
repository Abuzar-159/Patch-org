global With Sharing Class OrderConsoleLightning {
    
    // For FedEx   
    @AuraEnabled public static String resStatus                     { get; set; }
    @AuraEnabled public static String request_1                     { get; set; } 
    @AuraEnabled public static String response_1                    { get; set; }        
    
    @AuraEnabled global static String SON                           { get; Set; }
    @AuraEnabled global static String CON                           { get; Set; }
    @AuraEnabled global static String CUST                          { get; Set; }
    @AuraEnabled global static List<itemWrapper> IWL                { get; Set; }
    
    
    @AuraEnabled
    global static comWrap getAll(String sony, String cony, String custy) {
        return null;
    }
    @AuraEnabled
    global static Decimal getTaxRateByAddressId(String AddId){
        return null;
    }
    //@AuraEnabled
    @Deprecated
    global static comWrap getAll(String sony, String cony, String custy, String accf, String conf) {
        return null;
    }
    global class comWrap {
        @AuraEnabled global ERP7__Sales_Order__c Order                               { get ; set; }
        @AuraEnabled global Contact Contact                                          { get ; set; }
        @AuraEnabled global Account Customer                                         { get ; set; }
        @AuraEnabled global ERP7__Channel__c currentSalepoint                        { get ; set; }
        @AuraEnabled global Employees__c currentEmployee                             { get ; set; }
        @AuraEnabled global Invoice__c invoice                                       { get ; set; }
        @AuraEnabled global List < Address__c > billingAddresses                     { get ; set; }
        @AuraEnabled global List < Address__c > shippingAddresses                    { get ; set; }
        @AuraEnabled global List < ERP7__Profiling__c > sopas                        { get ; set; }
        @AuraEnabled global ERP7__Subscription__c pageSubscription                   { get ; set; }  @AuraEnabled global String exceptionError                                    { get ; set; } 
        @AuraEnabled global List<itemWrapper> itemWrapperListCom                     { get ; set; } @AuraEnabled global Decimal subTotal                                         { get; Set; } @AuraEnabled global Decimal totalDiscount                                    { get; Set; } @AuraEnabled global Decimal totalDue                                         { get; Set; } @AuraEnabled global Decimal totalTax                                         { get; Set; } @AuraEnabled global Decimal finalDue                                         { get; Set; } @AuraEnabled global Decimal loyaltyAmount                                    { get; Set; } @AuraEnabled global Decimal loyalty_Points                                   { get; Set; }
        @AuraEnabled global List<selectOptions> SOPS                                 { get; Set; }
        @AuraEnabled global List<selectOptions> bAdd                                 { get; Set; }
        @AuraEnabled global List<selectOptions> sAdd                                 { get; Set; }
        @AuraEnabled global List<selectOptions> orderStatus                          { get; Set; }
        @AuraEnabled global List<selectOptions> CountryList                          { get; Set; }
        @AuraEnabled global List<selectOptions> CountyList                           { get; Set; }
        @AuraEnabled global List<selectOptions> CardTypes                            { get; Set; }
        @AuraEnabled global List<selectOptions> ExpiryMonth                          { get; Set; }
        @AuraEnabled global List<selectOptions> ExpiryYear                           { get; Set; }
        @AuraEnabled global List<selectOptions> prodFam                              { get; Set; }
        @AuraEnabled global List<selectOptions> prodCat                              { get; Set; }
        @AuraEnabled global List<selectOptions> prodSubCat                           { get; Set; }
        @AuraEnabled global List<selectOptions> shipmentType                         { get; Set; }
        @AuraEnabled global List<RecentlyViewed> recentRecords                       { get; Set; }
        @AuraEnabled global Contact NewCont                                          { get; set; }
        @AuraEnabled global Account NewCustomer                                      { get; set; }
        @AuraEnabled global Address__c NewAddresses                                  { get; set; }
        @AuraEnabled global List < ERP7__Payment__c > SO_Payments                    { get; set; }
        @AuraEnabled global List < ERP7__Shipment__c > Shipments                     { get; set; }
        @AuraEnabled global ERP7__Payment__c Payment                                 { get; set; }
        @AuraEnabled global ERP7__Payment_Method__c PaymentMethod                    { get; set; }
        @AuraEnabled global String CardError                                         { get; set; } @AuraEnabled global String logo                                              { get; set; }
        @AuraEnabled global Decimal TaxRate                                          { get; set; }
        @AuraEnabled global Decimal accTaxRate                                       { get; set; }
        @AuraEnabled global List<ERP7__Credit_Note__c> creditNotes                   { get; set; }
        @AuraEnabled global Boolean Loyalty                                          { get; set; }
        @AuraEnabled global Decimal Points_Per_Unit_Amount                           { get; set; } @AuraEnabled global Account AccountRecord                                    { get; set; }
        
        global comWrap() {
            Order = new ERP7__Sales_Order__c();
            Contact = new Contact();
            Customer = new Account();
            NewCont = new Contact();
            NewCustomer = new Account();
            NewAddresses = new Address__c();
            currentSalepoint = new ERP7__Channel__c();
            currentEmployee = new Employees__c();
            invoice = new ERP7__Invoice__c();
            billingAddresses = new List < Address__c > ();
            shippingAddresses = new List < Address__c > ();
            sopas = new List < ERP7__Profiling__c > ();
            pageSubscription = new ERP7__Subscription__c();
            itemWrapperListCom = new List < itemWrapper > ();
            SOPS = new List < selectOptions > ();
            bAdd = new List < selectOptions > ();
            sAdd = new List < selectOptions > ();
            orderStatus = new List < selectOptions > ();
            CountryList = new List < selectOptions > ();
            CountyList = new List < selectOptions > ();
            CardTypes = new List < selectOptions > ();
            ExpiryMonth = new List < selectOptions > ();
            ExpiryYear = new List < selectOptions > ();
            prodFam = new List < selectOptions > ();
            prodCat = new List < selectOptions > ();
            prodSubCat = new List < selectOptions > ();
            shipmentType = new List < selectOptions > ();
            recentRecords = new List<RecentlyViewed>();
            SO_Payments = new List < ERP7__Payment__c >();
            Payment = new ERP7__Payment__c();
            Shipments = new List< ERP7__Shipment__c >();
            PaymentMethod = new ERP7__Payment_Method__c();
            CardError = '';
            TaxRate=0.000;
            accTaxRate = 0.000;
            Points_Per_Unit_Amount = 0;
            creditNotes = new List<ERP7__Credit_Note__c>();
            Loyalty = false;
        }
    }
    global class itemWrapper {
        @AuraEnabled global String code                              { get; set; } @AuraEnabled global product2 product                           { get; set; }
        @AuraEnabled global String itm                               { get; set; }
        @AuraEnabled global String itmId                             { get; set; } @AuraEnabled global String productId                         { get; set; }
        @AuraEnabled global String orderLineItemId                   { get; set; }
        @AuraEnabled global String pricebookId                       { get; set; } @AuraEnabled global Decimal quantity_s                       { get; set; } @AuraEnabled global Integer quantity                         { get; set; } @AuraEnabled global Decimal price                            { get; set; }
        @AuraEnabled global Decimal vat                              { get; set; }
        @AuraEnabled global Decimal tax                              { get; set; } @AuraEnabled global Decimal priceWithVat                     { get; set; }
        @AuraEnabled global String discountName                      { get; set; }
        @AuraEnabled global String discountId                        { get; set; }
        @AuraEnabled global Decimal discountPercent                  { get; set; }
        @AuraEnabled global Decimal discount                         { get; set; }
        @AuraEnabled global Decimal rewardPoints                     { get; set; }
        @AuraEnabled global String programId                         { get; set; }
        @AuraEnabled global Decimal commission                       { get; set; }
        @AuraEnabled global String ratecardId                        { get; set; }
        @AuraEnabled global List<Product_Tax_Allocation__c> Taxes    { get; set; }
        @AuraEnabled global Boolean scanned                          { get; set; }
        @AuraEnabled global Boolean trackInventory                   { get; set; }
        @AuraEnabled global String  prod_Desc                        { get; set; }
        @AuraEnabled global String checkOutProcess                   { get; set; }
        @AuraEnabled global Sales_Order_Line_Item__c lineitm         { get; set; }
        @AuraEnabled global Decimal moq                              { get; set; } 
        @AuraEnabled public boolean ispreOrder                       { get; set; } 
        @AuraEnabled public boolean isbackOrder                       { get; set; } 
        /*
            Inner Constructor For Wrapper Class
        */
        global itemWrapper() {
            code = '';
            itm = 'test';
            itmId = '';
            pricebookId = '';
            orderLineItemId = '';
            programId = '';
            rewardPoints = 0;
            commission = 0;
            discountPercent = 0;
            discount = 0;
            ratecardId = '';
            discountId = '';
            tax = 0;
            vat = 0;
            moq = 1;
            scanned = false;
            trackInventory = false;
            checkOutProcess = '';
            prod_Desc = '';
            discountName = '';
            Taxes = new List < Product_Tax_Allocation__c > ();
            lineitm = new Sales_Order_Line_Item__c();
            ispreOrder = false;
            isbackOrder = false;
        }
    }
    global class selectOptions {
        @AuraEnabled global String label     { get; set; }
        @AuraEnabled global String value     { get; set; }
        @AuraEnabled global Boolean selected { get; set; }
        
        global selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
        global selectOptions(String lab, string val, Boolean sel) {
            label = lab;
            value = val;
            selected = sel;
        }
    }
    @AuraEnabled
    global static String getBA(String baId) {
        return null;
    }
    @AuraEnabled
    global static String getSA(String saId) {
        return null;
    }
    global class ProductsAndDiscounts {
        @AuraEnabled global PricebookEntry pricebookEntry              { get; set; } @AuraEnabled global product2 product                           { get; set; }
        @AuraEnabled global Decimal quantity_s                         { get; set; }
        @AuraEnabled global Integer quantity                           { get; set; }
        @AuraEnabled global String discountName                        { get; set; } @AuraEnabled global String currentConId                        { get; set; }
        @AuraEnabled global List<SelectOptions> CurrentDiscounts       { get; set; }
        @AuraEnabled global Decimal discountPercent                    { get; set; }
        @AuraEnabled global Decimal maxDiscountPercent                 { get; set; }
        @AuraEnabled global Decimal minDiscountPercent                 { get; set; }
        @AuraEnabled global List<SelectOptions> CurrentDiscountPercent { get; set; }
        @AuraEnabled global Boolean selected                           { get; set; }
        @AuraEnabled global Boolean trackInventory                     { get; set; }
        @AuraEnabled global String checkOutProcess                     { get; set; } @AuraEnabled global Decimal moq                                { get; set; } 
        @AuraEnabled global Decimal stock                              { get; set; }
        @AuraEnabled global Boolean explode                            { get; set; }
        @AuraEnabled global Boolean isPercent                          { get; set; }
        @AuraEnabled public Boolean showcbox                           { get; set; }
        @AuraEnabled public String  product_status                      { get; set; }
        global ProductsAndDiscounts() {
            quantity = 1;
            showcbox = false;
            product_status = '';
            quantity_s = 1;
            discountName = '';
            selected = false;
            trackInventory = false;
            checkOutProcess = '';
            pricebookEntry = new PricebookEntry();
            CurrentDiscounts = new List < SelectOptions > ();
            CurrentDiscountPercent = new List < SelectOptions > ();
            discountPercent = 0;
            minDiscountPercent = 0;
            maxDiscountPercent = 0;
            stock = 0;
            explode = false;
            isPercent = false;
        }
    }
    
    @AuraEnabled
    global static List < Object > productFetch(String itemName, String ProdFam, List < ERP7__Channel__c > currentSalepoints, List < Account > Customers, List < Contact > Contacts, String SOP, List < itemWrapper > itemWrapperList) {
        return null;
    }
    @AuraEnabled
    global static List < Object > productFetchs(String itemName, String ProdFam, String ProdCat, String ProdSubCat, List < ERP7__Channel__c > currentSalepoints, List < Account > Customers, List < Contact > Contacts, String SOP, List < itemWrapper > itemWrapperList) {
        return null;
    }
       
    @AuraEnabled
    global static List < Object > productFetchss(String itemName, String ProdFam, String ProdCat, String ProdSubCat, List < ERP7__Channel__c > currentSalepoints, List < Account > Customers, List < Contact > Contacts, String SOP, List < itemWrapper > itemWrapperList, Boolean isBackOrder, Boolean isPreOrder) {
        return null;
    }
    
    @AuraEnabled
    global static ProductsAndDiscounts DiscountPlans(String itemId, List < ERP7__Channel__c > currentSalepoints, Boolean isBackorder, List < Account > Customers, List < Contact > Contacts, String SOP, Decimal quantity_s) {
        return null;
    }
    @AuraEnabled
    global static Discount_Plan__c discountPercent(String discountName) {
        return null;
    }
    @AuraEnabled
    global static List < Object > editProducts(String itemId, Decimal quants, String discountId, Decimal discount, List < ERP7__Channel__c > currentSalepoints, Boolean isBackorder, List < Account > Customers, List < Contact > Contacts, String SOP) {
        return null;
    }
    @AuraEnabled
    global static List < itemWrapper > addProducts(String selWrap, List < ERP7__Channel__c > currentSalepoints, List < Account > Customers, List < Contact > Contacts, String SOP) { return null;}
    //@AuraEnabled
    @Deprecated
    global  static List < itemWrapper > addProducts(String selWrap, List < ERP7__Channel__c > currentSalepoints, List < Account > Customers, List < Contact > Contacts, String SOP,Decimal TaxRate) {
        return null;
    }
    @AuraEnabled
    global static String saveDraft(String selWrap, List < ERP7__Channel__c > currentSalepoints, String SalesOrder2Creates, List < Account > Customers, List < Contact > Contacts, String SOP, List < String > lineItem2delete, String invoiceName, Decimal loyaltyPoints, Decimal loyaltyAmount) {
        return '';   
    }
    @AuraEnabled
    global static returnClass saveDrafts(String selWrap, List < ERP7__Channel__c > currentSalepoints, String SalesOrder2Creates, List < Account > Customers, List < Contact > Contacts, String SOP, List < String > lineItem2delete, String invoiceName, Decimal loyaltyPoints, Decimal loyaltyAmount) {
        return null;
    }
    @AuraEnabled
    global static returnClass ApplyCoupons(String SalesOrder2Creates, List < Account > Customers, List < Contact > Contacts, String Coupon) {
        return null;
    }
    
    @AuraEnabled
    global static List<RecentlyViewed> CreateNewCustomer(List < Account > Customers) {
        return null;
    }
    
    @AuraEnabled
    global static Id CreateNewCustomers(List < Account > Customers) {
        return null;
    }
    
   
    @AuraEnabled
    global static Id CreateNewConts(List<Contact> Cons) {
        return null;
    }
    
    @AuraEnabled
    global static List<RecentlyViewed> CreateNewCont(List<Contact> Cons) {
        return null;
    }
    
    @AuraEnabled
    global static List<RecentlyViewed> CreateNewAddress(List < ERP7__Address__c > NewAddres, String County, String Country) {
        return null;
    }
    
    @AuraEnabled
    global static ERP7__Address__c SaveNewAddress(List < ERP7__Address__c > NewAddres, String County, String Country) {
        return null;
    }
     
    @AuraEnabled
    global static loyaltyWrap loyaltyProcessing(List < ERP7__Sales_Order__c > SalesOrder2Creates, List < Account > Customers, Decimal FinalDues, Decimal TotalDues, Decimal LoyaltyAmounts, Decimal LoyaltyPoint_s, Decimal customerCreditLimit) {
        return null;
    }
    
    @AuraEnabled
    global static returnClass CreditProcessing(List < ERP7__Sales_Order__c > SalesOrder2Creates, List < ERP7__Invoice__c > Invoices, List < Account > Customers, Decimal FinalDues, Decimal TotalDues, Decimal CreditAmounts, Decimal CreditAmount2Uses) {
        return null;
    }
    
    @AuraEnabled
    global static Boolean CreateCashPayment(List < ERP7__Sales_Order__c > SalesOrder2Creates, String Payments) {
        return null;
    }
    
    @AuraEnabled
    global static Boolean CreateBankPayment(List < ERP7__Sales_Order__c > SalesOrder2Creates, String Payments) {
        return null;
    }
    
    @AuraEnabled
    global static String CreateCardPayment(List < ERP7__Sales_Order__c > SalesOrder2Creates, String Payments, String PaymentMethods, String CVV) {
        return null;
    }
    
    @AuraEnabled
    global static upsWrap FedServices(String soId, String packType, Decimal packNo, String shipDate) {
        return null;
    }
    
    @AuraEnabled
    global static String FedServicesSave(String soId, String rateWrapperSelected, String shipDate, Decimal additionalPercent) {
        return '';
    }
    
    
    @AuraEnabled
    global static upsWrap UPSServices(String soId, String packType, Decimal packNo, String shipDate) {
        return null;
    }
    
    @AuraEnabled
    global static String UPSServiceSave(String soId, String rateWrapperSelected, String shipDate, Decimal additionalPercent) {
        return null;
    }
    
    
    // @AuraEnabled
    @Deprecated
    global static comWrap getAllPayDetails(String sony) {
        return null;
    }
    
    @AuraEnabled
    global static Account getCustomerDetails(String AccountId) {
       return null;
    }
    
    @AuraEnabled
    global static comWrap getAllPayDetails(String sony, String accf, String conf) {
        return null; } global void readXMLResponseRateTransitDetails(XmlStreamReader reader, String sxmltag) { } global static String readXMLResponse(XmlStreamReader reader, String sxmltag) { return null; }
       
    global class loyaltyWrap {
        @AuraEnabled global String customerCreditLimit              { get; Set; } 
        @AuraEnabled global Decimal FinalDue                        { get; Set; } 
        @AuraEnabled global Decimal TotalDue                        { get; Set; } 
        @AuraEnabled global Decimal loyaltyAmount                   { get; Set; } 
        @AuraEnabled global Decimal loyaltyPoints                   { get; Set; } 
        global loyaltyWrap() {
            customerCreditLimit = '';
            FinalDue = TotalDue = loyaltyAmount = loyaltyPoints = 0;
        }
    }
    
    global class upsWrap {
        @AuraEnabled global String PackageType                      { get; Set; }  @AuraEnabled global List<selectOptions> PackageTypes        { get; Set; }
        @AuraEnabled global Date ShipmentDate                       { get; Set; } 
        @AuraEnabled global Decimal Length                          { get; Set; } 
        @AuraEnabled global Decimal Width                           { get; Set; } 
        @AuraEnabled global Decimal Height                          { get; Set; } 
        @AuraEnabled global Decimal Weight                          { get; Set; } 
        @AuraEnabled global Decimal NoofPackage                     { get; Set; } 
        @AuraEnabled global Decimal Additional                      { get; Set; } 
        @AuraEnabled global Decimal PackageVolume                   { get; Set; } 
        @AuraEnabled global Decimal SOVolume                        { get; Set; } 
        @AuraEnabled global Decimal SOWeight                        { get; Set; }  @AuraEnabled global Decimal TotalWeight                     { get; Set; } 
        @AuraEnabled global Decimal WeightPerPack                   { get; Set; }
        @AuraEnabled global String UPSErrorMsg                      { get; Set; }
        @AuraEnabled global String Result                           { get; Set; }
        @AuraEnabled global List<rateWrapper> Services              { get; Set; }
        global upsWrap() {
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
            Services = new List<rateWrapper>(); }}@AuraEnabled global List<rateWrapper> rateWrapperList       { get; set; }
    
    global class rateWrapper {
        @AuraEnabled global String Service                      { get; set; }                   
        @AuraEnabled global Date DeliveryDate                   { get; set; }
        @AuraEnabled global String ServiceCode                  { get; set; }
        @AuraEnabled global String totalCharges                 { get; set; }
        @AuraEnabled global String totalSurcharges              { get; set; }
        @AuraEnabled global String currencyCode                 { get; set; }   
        @AuraEnabled global String DeliveryDateS                { get; set; }
        @AuraEnabled global String ServiceManual                { get; set; }
        @AuraEnabled global String negotiatedCharges            { get; set; }   
        @AuraEnabled global String TransportationCharges        { get; set; }   
        @AuraEnabled global String ServiceOptionsCharges        { get; set; } 
        @AuraEnabled global String ScheduledDeliveryTime        { get; set; }
        @AuraEnabled global String GuaranteedDaysToDelivery     { get; set; }  
        @AuraEnabled global Boolean Selected                    { get; set; }                
        
        global rateWrapper() { 
            Service = '';
            currencyCode = '';
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
    
    global class returnClass {
        @AuraEnabled global String errorMsg                      { get; set; }                   
        @AuraEnabled global Boolean Error                        { get; set; }
        @AuraEnabled global String Value                         { get; set; }              
        
        global returnClass() { 
            errorMsg = '';
            Value = ''; 
            Error = false;
        }        
    }
}