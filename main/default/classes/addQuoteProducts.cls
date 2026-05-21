public with sharing class addQuoteProducts {

    public String orderId                               { get; set; }
    public String SOFields                              { get; set; }  
    public String SOLIFields                            { get; set; }
    public ERP7__Quotes__c SalesOrder2Insert            { get; set; }
    public ERP7__Quotes__c sOrder                       { get; set; }
    public String addressFields                         { get; set; }
    public String invoiceFields                         { get; set; }            
    public String employeeFields                        { get; set; }            
    public String salepointFields                       { get; set; } 
    public String channelFields                         { get; set; }
    public String contactFields                         { get; set; }
    public String accountFields                         { get; set; }
    public String bundleId                              { get; set; }                                
    public ERP7__Subscription__c pageSubscription       { get; set; }
    public Inventory_Stock__c sel                       { get; set; } 
    
    public Invoice__c invoice                           { get; set; } 
    public String invoiceName                           { get; set; } 
    public String SOP                                   { get; set; }
    public Account acct                                 { get; set; }        
    public Contact con                                  { get; set; }        
    public Account sAccount                             { get; set; }     
    public Contact sContact                             { get; set; }        
    
    public Product2 ps                                  { get; set; }
    public String quantityEdit                          { get; set; }
    public Decimal subTotal                             { get; set; } 
    public Decimal totalDiscount                        { get; set; }
    public Decimal TaxRate                              { get; set; } 
    public Decimal totalTax                             { get; set; } 
    public Decimal totalDue                             { get; set; }  
    public Decimal FinalDue                             { get; set; }
    public Boolean PITab                                { get; set; }
    public Boolean nextBtnShow                          { get; set; }
    public Boolean listItems                            { get; set; }
    public Boolean upperPanel                           { get; set; }
    
    public Integer productLineItemsCounter              { get; set; }
    public String exceptionMsg                          { get; set; } 
    public Integer ItemPos                              { get; set; }
    public Integer off_Set                              { get; set; }
    
    public Integer noRows                              { get; set; }
    public Id currentConId                              { get; set; } 
    public Decimal loyaltyAmount                        { get; set; }
    public Decimal loyalty_Points                       { get; set; } 
    public String orderProfile                          { get; set; }
    public String itemName                              { get; set; }
    public String prodFam                               { get; set; }  
    public String prodCat                               { get; set; }
    public String prodSubCat                            { get; set; }     
    public String empName                               { get; set; } 
    public String accountId                             { get; set; }
    public String salePointId                           { get; set; }
    public List<Id> siteIds                                             { get; set; }
    public List<ERP7__Employees__c> currentEmployees                    { get; set; }
    public List<ERP7__Address__c> billingAddressList                    { get; set; }     
    public List<ERP7__Address__c> shippingAddressList                   { get; set; }
    public List<itemWrapper> itemWrapperList                            { get; set; }
    public List < Id > lineItem2delete                                  { get; set; }
    public ERP7__Channel__c currentSP                                   { get; set; }
    public List<Distribution_Channel__c> DistributionChannels           { get; set; } 
    
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    public class customException extends Exception {}

    public addQuoteProducts(ApexPages.StandardController controller) {
    
        try{
            off_Set=0;
            noRows = 50;
            orderId = ApexPages.currentPage().getParameters().get('id');
            
            employeeFields = UtilClass.selectStarFromSObject('ERP7__Employees__c');
            accountFields = UtilClass.selectStarFromSObject('Account');
            contactFields = UtilClass.selectStarFromSObject('Contact'); 
            addressFields = UtilClass.selectStarFromSObject('ERP7__Address__c');
            SOLIFields = UtilClass.selectStarFromSObject('ERP7__Quote_Line_Items__c');
            SOFields = UtilClass.selectStarFromSObject('ERP7__Quotes__c');
            invoiceFields = UtilClass.selectStarFromSObject('ERP7__Invoice__c');
            salepointFields = UtilClass.selectStarFromSObject('ERP7__Channel__c');
            channelFields = UtilClass.selectStarFromSObject('ERP7__Distribution_Channel__c'); 
            
            con = new Contact();
            acct = new Account();
            ps = new Product2();
            sel = new Inventory_Stock__c();
            prodFam = ps.Family;
            prodCat = ps.Category__c; 
            prodSubCat = ps.Sub_Category__c;           
            pageSubscription = new ERP7__Subscription__c();
            SalesOrder2Insert = new ERP7__Quotes__c();
            invoice = new Invoice__c();
            sOrder = new ERP7__Quotes__c();
            itemWrapperList = new List < itemWrapper > ();
            lineItem2delete = new List < Id > ();
            shippingAddressList = new List<ERP7__Address__c>();
            billingAddressList = new List<ERP7__Address__c>();
            exceptionMsg = '';
            quantityEdit = '';
            empName = '';
            listItems = false;
            upperPanel = true;
            
            currentEmployees = Database.query('select ' + String.escapeSingleQuotes(employeeFields) + ' from ERP7__Employees__c  where ' +
                               '(Employee_User__c =\'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\') Order by CreatedDate Asc Limit 1');
            
            
            if(currentEmployees != null && currentEmployees.size() > 0 && (salePointId == null || salePointId == '')){
                salePointId = currentEmployees[0].Channel__c;
                
                if(salePointId != null && salePointId != '') { 
                    currentSP = Database.query('select ' + String.escapeSingleQuotes(salepointFields) + ' from ERP7__Channel__c where Id =\'' + String.escapeSingleQuotes(salePointId)+ '\' ');
                    Date myDate = system.today();
                    
                    DistributionChannels = Database.query('select ' + String.escapeSingleQuotes(channelFields) + ' from Distribution_Channel__c where '+
                                                          '(Channel__c =\'' + String.escapeSingleQuotes(salePointId) + '\' And Active__c = true)');
                    siteIds = new List<Id>();
                    if(DistributionChannels.size() > 0){
                        for(Distribution_Channel__c DC : DistributionChannels){
                            siteIds.add(DC.Site__c);
                        }
                    }
                }
                
                if(orderId != null && orderId != '') {
                    sOrder = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' from ERP7__Quotes__c where ' + 
                                            '(Id =\'' + String.escapeSingleQuotes(orderId) + '\')');
                    orderProfile = sOrder.ERP7__Order_Profile__c;
                    if(sOrder.Customer__c != null){
                        sAccount = Database.query('select ' + String.escapeSingleQuotes(accountFields) + ' from Account where ' +
                                                  '(Id =\'' + String.escapeSingleQuotes(sOrder.Customer__c) + '\')');
                    }else{
                        throw new customException('Please add a Customer Account to your Quote.');
                    }
                    if(sOrder.Contact__c != null){
                        sContact = Database.query('select ' + String.escapeSingleQuotes(contactFields) + ' from Contact where ' +
                                                  '(Id =\'' + String.escapeSingleQuotes(sOrder.Contact__c) + '\')');
                    }else{
                        throw new customException('Please add a Contact to your Quote.');
                    }
                    customerDetail();
                    fetchProduct();
                    populateLineItems();
                }
            }else{
                throw new customException('Please create/update the employee record for the logged in user.');
            }
            
        }  catch(Exception e) { exceptionMethod(e, 'constructor'); }
    }
    
    /*
method for fetching both account & contact Details
*/
    public PageReference customerDetail() {
        try { 
            billingAddressList = new List <ERP7__Address__c> ();
            shippingAddressList = new List <ERP7__Address__c> ();
            
            if(sOrder.Contact__c != null) con = Database.query('Select '+ String.escapeSingleQuotes(contactFields) + ' from Contact Where Id = \'' + String.escapeSingleQuotes(sOrder.Contact__c) + '\' limit 1');
            
            if(con.Id != null) {
                currentConId = con.Id;
                billingAddressList = Database.query('Select '+ String.escapeSingleQuotes(addressFields) + ' from ERP7__Address__c Where ' +
                                     '(Primary__c = true And Contact__c = \'' + String.escapeSingleQuotes(con.Id) + '\''+
                                     +'and Active__c = true and Is_Billing_Address__c = true) order by CreatedDate ASC');
                 
                List<Address__c> billingPrimaryAddress = Database.query('Select '+ String.escapeSingleQuotes(addressFields) + ' from ERP7__Address__c Where ' +
                                                         '(Primary__c = true And Contact__c = \'' + String.escapeSingleQuotes(con.Id) + '\''+
                                                         +'and Active__c = true and Is_Billing_Address__c = true) order by CreatedDate ASC Limit 1');
                
                if(billingPrimaryAddress.size() > 0) {
                    if(billingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line1__c+', ';
                    if(billingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line2__c+', ';
                    if(billingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line3__c+', ';
                    if(billingPrimaryAddress[0].city__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].city__c+', ';
                    if(billingPrimaryAddress[0].State__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].State__c+', ';
                    if(billingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Postal_Code__c+', ';
                    if(billingPrimaryAddress[0].Country__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Country__c;   
                }
                                     
                shippingAddressList = Database.query('Select '+ String.escapeSingleQuotes(addressFields) + ' from Address__c Where ' +
                                      '(Primary__c = true And Contact__c = \'' + String.escapeSingleQuotes(con.Id) + '\''+
                                      +'and Active__c = true and Is_Shipping_Address__c = true) order by CreatedDate ASC'); 
                                   
                List<Address__c> shippingPrimaryAddress = Database.query('Select '+ String.escapeSingleQuotes(addressFields) + ' from Address__c Where ' +
                                                          '(Primary__c = true And Contact__c = \'' + String.escapeSingleQuotes(con.Id) + '\''+
                                                          +'and Active__c = true and Is_Shipping_Address__c = true) order by CreatedDate ASC Limit 1'); 
                
                if(shippingPrimaryAddress.size() > 0) {
                    pageSubscription.Ship_To_Address__c = '';
                    if(shippingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line1__c+', ';
                    if(shippingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line2__c+', ';
                    if(shippingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line3__c+', ';
                    if(shippingPrimaryAddress[0].city__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].city__c+', ';
                    if(shippingPrimaryAddress[0].State__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].State__c+', ';
                    if(shippingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Postal_Code__c+', ';
                    if(shippingPrimaryAddress[0].Country__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Country__c;
                }
            }
        } catch(Exception e) { exceptionMethod(e, 'customerDetail'); }
        return null;
    }
    
    public pagereference fetchProduct(){
        try{
            
            //Boolean IsBackOrder = sOrder.Is_Back_Order__c;
            //Boolean IsBackOrderNeg = (!sOrder.Is_Back_Order__c)? true : true;
            //Boolean isPreOrder = sOrder.Is_Pre_Order__c;
            if(off_set == 0)    
                ProductsAndDiscountsWrapperList = new List < ProductsAndDiscounts > ();
            ERP7__Channel__c currentSalepoint = currentSP;
            Account Customer = sAccount;
            Contact Contact = sContact;
            
            
            List < Id > productIds = new List < Id > ();
            ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
            String OrgnPSA = currentSalepoint.Organisation__c;
            String OrgnBusIdPSA = currentSalepoint.Organisation_Business_Unit__c;
            String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
            //String itemNamePSA = '%' + itemName + '%';
            //String productFamily = prodFam;
            
            List < Distribution_Channel__c > DistributionChannels = new List < Distribution_Channel__c > ();
            if(Schema.sObjectType.Distribution_Channel__c.isAccessible()) {
                DistributionChannels = [Select Id, Name, Active__c,  Channel__c, Site__c From Distribution_Channel__c
                                        Where Channel__c = : currentSalepoint.Id And Active__c = true];
            }
            List < Id > siteIds = new List < Id > ();
            if(DistributionChannels.size() > 0) {
                
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
            if(sOrder.ERP7__Order_Profile__c != null){
                SOP = string.valueOf(sOrder.ERP7__Order_Profile__c);
                String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
                if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
                
            }
            else{
                throw new customException('Please add a Order Profile for your Quote.');
            }
            
            String PricebookId = Profiling.Price_Book__c;
            Date todays = system.today();
            String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
            UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
            allFieldss += ' ,Product2.Name, Product2.Family, Product2.ERP7__Category__c, Product2.ERP7__Sub_Category__c, Product2.ERP7__Allow_Pre_Orders__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Status__c, Product2.ERP7__Track_Inventory__c ';
            String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ' from PricebookEntry where IsActive = true and Pricebook2Id = :PricebookId'; //and (Product2.Name like: itemNamePSA or Product2.ProductCode like: itemNamePSA or Product2.ERP7__Barcode__c like: itemNamePSA or Product2.ERP7__ASIN_Code__c like: itemNamePSA or Product2.ERP7__SKU__c like: itemNamePSA)'; //     and ERP7__Start_Date__c <= :todays and ERP7__End_Date__c >= :todays
            //if(prodFam != null && prodFam != '') querys += ' And Product2.Family = : prodFam';
            //if(prodCat != null && prodCat != '') querys += ' And Product2.ERP7__Category__c = : prodCat';
            //if(prodSubCat != null && prodSubCat != '') querys += ' And Product2.ERP7__Sub_Category__c = : prodSubCat';
            //if(isBackOrder == false && isPreOrder == false) querys += ' And Product2.ERP7__Status__c = \'Released\'';
            //if(isBackOrder == true) querys += ' And Product2.ERP7__Allow_Back_Orders__c = true And (Product2.ERP7__Status__c = \'Certified\' Or Product2.ERP7__Status__c = \'Released\')';
            //if(isPreOrder == true) querys += ' And Product2.ERP7__Allow_Pre_Orders__c = true And (Product2.ERP7__Status__c = \'Certified\' Or Product2.ERP7__Status__c = \'In Development\')';
            querys += ' Limit 50 offSet '+off_Set;
            
            List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
            if(Schema.sObjectType.PricebookEntry.isAccessible()){ priceBookEntries = Database.query(querys); }
            Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
            
            for(PricebookEntry IPE: priceBookEntries) {
                productIds.add(IPE.Product2Id);
                productPriceBookMap.put(IPE.Product2Id, IPE);
            }
            
            string kk = String.valueof(itemWrapperList);
           
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
            
            if(productIds.size() > 0) {
                if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                     Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,
                                                     Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                     From Inventory_Stock__c
                                                     Where product__c In: productIds And
                                                     Active__c = true And
                                                   //  Organisation__c = : currentSalepoint.Organisation__c And
                                                   //  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                                                     Warehouse__c In: siteIds And
                                                     Number_of_Item_In_Stock__c > 0
                                                    ];
            }
            Map < Id, List < Inventory_Stock__c >> productWarehouses = new Map < Id, List < Inventory_Stock__c >> ();
            Map < Id, Decimal > productStock = new Map < Id, Decimal > ();
            List < Id > newProductIds = new List < Id > ();
            
            for(Id pId: productIds) {
                List < Inventory_Stock__c > myWarehouses = new List < Inventory_Stock__c > ();
                Decimal myStock = 0;
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(PId == WIIS.product__c) {
                        myWarehouses.add(WIIS);
                        myStock += WIIS.Number_of_Item_In_Stock__c;
                    }
                }
                if(!productPriceBookMap.get(pId).Product2.ERP7__Track_Inventory__c) {
                    newProductIds.add(PId);
                } else if(myStock >= 0) {
                    newProductIds.add(PId);
                    productWarehouses.put(PId, myWarehouses);
                    productStock.put(PId, myStock);
                }
            }
            
            List < product2 > allProducts = new List < product2 > ();
            String allFieldsProduct2 = UtilClass.selectStarFromSObject('Product2');
            String queryProduct2 = 'select ' + String.escapeSingleQuotes(allFieldsProduct2) + ' from Product2 where Id In: newProductIds And IsActive = true ';
           
            //if(prodFam != null && prodFam != '') queryProduct2 += ' And Family = : prodFam';
            //if(prodCat != null && prodCat != '') queryProduct2 += ' And ERP7__Category__c = : prodCat';
            //if(prodSubCat != null && prodSubCat != '') queryProduct2 += ' And ERP7__Sub_Category__c = : prodSubCat';
            queryProduct2 += ' Limit 500';
            if(Schema.sObjectType.Product2.isAccessible()) allProducts = Database.query(queryProduct2);
            Integer currentQuantity = 1; //productStock.get(product.Id);
            List < String > prodIds = new List < String > ();
            for(product2 product: allProducts) {
                prodIds.add(product.Id);
            }
            List < Tier_Discount_Allocation__c > TDAS;
            if(Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                    product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                    Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                    Discount_Plan__r.ERP7__Default_Discount_Value__c, Discount_Plan__r.ERP7__Floor_Discount_Value__c, Discount_Plan__r.ERP7__Ceiling_Discount_Value__c
                    From Tier_Discount_Allocation__c
                    Where ERP7__Order_Profile__c = : Profiling.Id And
                    //Organisation__c = : currentSalepoint.Organisation__c And
                    //Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                    product__c In: prodIds And
                    Tier__r.Floor_Unit__c <= : currentQuantity And
                    Tier__r.Ceiling_Unit__c >= : currentQuantity And
                    Tier__r.Active__c = true And
                    Discount_Plan__r.Active__c = true
                ];
            List < Id > discountPlanIds = new List < Id > ();
            Map < Id, Discount_Plan__c > discountMap = new Map < Id, Discount_Plan__c > ();
            for(Tier_Discount_Allocation__c TDA: TDAS) {
                if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
            }
            List < Discount_Plan__c > discounts = new List < Discount_Plan__c > ();
            if(Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                    Organisation__c, Organisation_Business_Unit__c, Status__c, ERP7__Default_Discount_Value__c, ERP7__Ceiling_Discount_Value__c, ERP7__Floor_Discount_Value__c
                    From Discount_Plan__c
                    Where Id In: discountPlanIds And
                    Active__c = True
                ];
            for(Discount_Plan__c dis: discounts) {
                discountMap.put(dis.id, dis);
            }
            Map < Id, List < Discount_Plan__c >> discountPlans = new Map < Id, List < Discount_Plan__c >> ();
            Map < Id, String > defaultDiscountMap = new Map < Id, String > ();
            Map < Id, Decimal > defaultDiscountPercentMap = new Map < Id, Decimal > ();
            Map < Id, Decimal > defaultDiscountPercentMapMin = new Map < Id, Decimal > ();
            Map < Id, Decimal > defaultDiscountPercentMapMax = new Map < Id, Decimal > ();
            for(product2 product: allProducts) {
                List < Discount_Plan__c > myDiscountPlans = new List < Discount_Plan__c > ();
                Boolean defaultDiscountfound = false;
                for(Tier_Discount_Allocation__c TDA: TDAS) {
                    if(product.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                        myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                        if(TDA.Default__c == true && !defaultDiscountfound) {
                            defaultDiscountMap.put(product.Id, TDA.Discount_Plan__c);
                            defaultDiscountfound = true;
                            if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c);
                            
                            if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Value__c);
                            if(TDA.Discount_Plan__r.Floor_Discount_Value__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Value__c);
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Value__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Value__c);
                        }
                    }
                }
                discountPlans.put(product.id, myDiscountPlans);
            }
            for(product2 product: allProducts) {
                ProductsAndDiscounts PDs = new ProductsAndDiscounts();
                PDs.product = product;
                List < SelectOption > options = new List < SelectOption > ();
                options.add(new SelectOption('', '--None--'));
                if(discountPlans.get(product.id) != null) {
                    for(Discount_Plan__c dis: discountPlans.get(product.id)) {
                        options.add(new SelectOption(dis.Id,dis.Name));
                    }
                }
                PDs.pricebookEntry = productPriceBookMap.get(product.id);
                PDs.quantity_s = currentQuantity;
                if(defaultDiscountMap.containsKey(product.Id)) PDs.discountName = defaultDiscountMap.get(product.Id);
                else PDs.discountName = '';
                PDs.CurrentDiscounts = options;
                if(defaultDiscountPercentMap.containsKey(product.Id)) PDs.discountPercent = defaultDiscountPercentMap.get(product.Id);
                if(defaultDiscountPercentMapMin.containsKey(product.Id)) PDs.minDiscountPercent = defaultDiscountPercentMapMin.get(product.Id);
                if(defaultDiscountPercentMapMax.containsKey(product.Id)) PDs.maxDiscountPercent = defaultDiscountPercentMapMax.get(product.Id);
                PDS.trackInventory = PDs.pricebookEntry.Product2.ERP7__Track_Inventory__c;
                PDS.checkOutProcess = PDs.pricebookEntry.ERP7__Check_Out_Process__c;
                //PDs.moq = PDs.pricebookEntry.ERP7__MOQ__c;
                //PDs.quantity_s = (PDs.moq !=null)?PDs.moq:currentQuantity;
                PDs.stock = productStock.get(product.Id);
                ProductsAndDiscountsWrapperList.add(PDs);
                
            }
        }  catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        
        return null;
    }
    
    /*
      Populate all product/services records of a particular salesorders
    */
    public PageReference populateLineItems() {
        try { 
            if(orderId != Null && orderId != '') {
                List <ERP7__Quote_Line_Items__c> orderLineItem = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Quotes__r.Name,'+
                                                                           +'Product__r.Name, Product__r.ProductCode, Product__r.Picture__c from ERP7__Quote_Line_Items__c where ' +
                                                                           '(Quotes__c =\'' + String.escapeSingleQuotes(orderId) + '\')');             
                
                ERP7__Quotes__c currentSalesOrder = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' from ERP7__Quotes__c where '+
                                                              '(Id =\'' + String.escapeSingleQuotes(orderId) + '\') Limit 1');            
               
                SalesOrder2Insert = currentSalesOrder;
                //sOrder.Is_Back_Order__c = currentSalesOrder.Is_Back_Order__c;
                //if(currentSalesOrder.Purchase_Order_Number__c != Null) sOrder.Purchase_Order_Number__c = currentSalesOrder.Purchase_Order_Number__c;            
                if(currentSalesOrder.Status__c != null) sOrder.Status__c = currentSalesOrder.Status__c;                    
                if(currentSalesOrder.ERP7__Request_Date__c != null) sOrder.ERP7__Request_Date__c = currentSalesOrder.ERP7__Request_Date__c;
                if(currentSalesOrder.ERP7__Description__c != null) sOrder.ERP7__Description__c = currentSalesOrder.ERP7__Description__c;    
                else sOrder.ERP7__Description__c = ''; 
                
                if(currentSalesOrder.Bill_To_Address__c != Null) {
                    ERP7__Address__c baddr = Database.query('select ' + String.escapeSingleQuotes(addressFields) + ' from ERP7__Address__c where '+
                                                  '(Id =\'' + String.escapeSingleQuotes(currentSalesOrder.Bill_To_Address__c) + '\') Limit 1');                                
                    if (baddr.Address_Line2__c != Null || baddr.Address_Line3__c != Null) {
                        pageSubscription.Bill_To_Address__c = baddr.ERP7__Address_Line1__c + ', ' + baddr.Address_Line2__c + ', ' + baddr.Address_Line3__c + ', ' + baddr.City__c + ', ' + baddr.State__c +
                            ', ' + baddr.Postal_Code__c + ', ' + baddr.Country__c;
                    } else  pageSubscription.Bill_To_Address__c = baddr.Address_Line1__c + ', ' + baddr.City__c + ', ' + baddr.State__c + ', ' + baddr.Postal_Code__c + ', ' + baddr.Country__c;
                }
                if (currentSalesOrder.Ship_To_Address__c != Null) {
                    ERP7__Address__c saddr = Database.query('select ' + String.escapeSingleQuotes(addressFields)+ ' from ERP7__Address__c where '+
                                                  '(Id =\'' + String.escapeSingleQuotes(currentSalesOrder.Ship_To_Address__c) + '\') Limit 1');                
                    if (saddr.Address_Line2__c != Null || saddr.Address_Line3__c != Null) {
                        pageSubscription.Ship_To_Address__c = saddr.Address_Line1__c + ', ' + saddr.Address_Line2__c + ', ' + saddr.Address_Line3__c + ', ' + saddr.City__c + ', ' + saddr.State__c +
                            ', ' + saddr.Postal_Code__c + ', ' + saddr.Country__c;
                    } else pageSubscription.Ship_To_Address__c = saddr.Address_Line1__c + ', ' + saddr.City__c + ', ' + saddr.State__c + ', ' + saddr.Postal_Code__c + ', ' + saddr.Country__c;
                }
                
                List <ERP7__Invoice__c> invoices = Database.query('select ' + String.escapeSingleQuotes(invoiceFields) + ' from ERP7__Invoice__c where '+
                                                        '(ERP7__Order__c =\'' + String.escapeSingleQuotes(currentSalesOrder.id) + '\') Limit 1');             
                if (invoices.size() > 0) {
                    invoice = invoices[0];
                    invoiceName = invoices[0].Name;
                } else { 
                    invoice = new Invoice__c();
                    invoiceName = '';
                }
                //com.Quotes__c = currentSalesOrder.id;
                
                List < String > itemIds = new List < String > ();
                for (Quote_Line_Items__c LI: orderLineItem) {
                    itemIds.add(LI.Id);
                }
                
                itemWrapperList = new List < itemWrapper > ();
                for (Quote_Line_Items__c lineItem: orderLineItem) {
                    itemWrapper item = new itemWrapper();
                    item.lineitm = lineItem;
                    
                    item.code = lineItem.Product__r.ProductCode;
                    item.itm = lineItem.Product__r.Name;
                    item.itmId = lineItem.Product__c;
                    item.ImagePreview = lineItem.Product__r.Picture__c;
                    
                    if(lineItem.Discount_Plan__c != Null) item.discountId = lineItem.Discount_Plan__c;
                    item.pricebookId = lineItem.PriceBookId__c;
                    item.programId = lineItem.Loyalty_Program__c;
                    if(lineItem.Commission_Rate_Card__c != Null) item.ratecardId = lineItem.Commission_Rate_Card__c;
                    if(lineItem.Commission__c != Null) item.commission = lineItem.Commission__c;
                    if(lineItem.Quantity__c != null) item.quantity_s = lineItem.Quantity__c;
                    if(lineItem.Quantity__c != null && lineItem.Base_Price__c != null) item.price = (lineItem.Base_Price__c * item.quantity_s).setScale(2);//item.price = ((lineItem.Base_Price__c / lineItem.quantity__c) * item.quantity_s).setScale(2);
                    if(lineItem.Quantity__c != null && lineItem.VAT_Amount__c != Null) item.vat = ((lineItem.VAT_Amount__c / lineItem.quantity__c) * item.quantity_s).setScale(2);
                    if(lineItem.Quantity__c != null && lineItem.Other_Tax__c != Null) item.tax = ((lineItem.Other_Tax__c / lineItem.quantity__c) * item.quantity_s).setScale(2);
                    if(lineItem.Quantity__c != null && lineItem.Discount_Amount__c != Null) item.discount = ((lineItem.Discount_Amount__c / lineItem.quantity__c) * item.quantity_s).setScale(2);
                    if(lineItem.Total_Price__c != null) item.priceWithVat = lineItem.Total_Price__c.setScale(2);
                    item.orderLineItemId = lineItem.Id;
                    item.prod_Desc = lineItem.ERP7__Description__c;
                    item.Summary = lineItem.Name__c;
                    item.unitprice = lineItem.ERP7__Base_Price__c;
                    //item.unitprice = lineItem.Price_Product__c;
                    if(item.quantity_s > 0) itemWrapperList.add(item);
                }
                
                subTotal = 0;
                totalDiscount = 0;
                totalDue = 0;
                totalTax = 0;
                for (itemWrapper iwrap: itemWrapperList) {
                    if(iwrap.price != null) subTotal += iwrap.price;
                    if(iwrap.discount != null) totalDiscount += iwrap.discount;
                    if(iwrap.vat != null && iwrap.tax != null) totalTax += (iwrap.vat + iwrap.tax);
                    if(iwrap.priceWithVat != null) totalDue += iwrap.priceWithVat;                
                }
                PITab = false;
                nextBtnShow = false;
                productLineItemsCounter = itemWrapperList.size();
                }            
        } catch(Exception e) { exceptionMethod(e, 'populateLineItems'); }
        return null;
    }
    
    public pagereference searchproduct(){
        try{
            
            //Boolean IsBackOrder = sOrder.Is_Back_Order__c;
            //Boolean IsBackOrderNeg = (!sOrder.Is_Back_Order__c)? true : true;
            //Boolean isPreOrder = sOrder.Is_Pre_Order__c;
            
            ProductsAndDiscountsWrapperList = new List < ProductsAndDiscounts > ();
            ERP7__Channel__c currentSalepoint = currentSP;
            Account Customer = sAccount;
            Contact Contact = sContact;
            
            List < Id > productIds = new List < Id > ();
            ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
            String OrgnPSA = currentSalepoint.Organisation__c;
            String OrgnBusIdPSA = currentSalepoint.Organisation_Business_Unit__c;
            String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
            String itemNamePSA = '%' + itemName + '%';
            //String productFamily = ps.Family;
            prodFam = ps.Family;
            prodCat = ps.ERP7__Category__c;
            prodSubCat = ps.ERP7__Sub_Category__c;
            
            List < Distribution_Channel__c > DistributionChannels = new List < Distribution_Channel__c > ();
            if(Schema.sObjectType.Distribution_Channel__c.isAccessible()) {
                
                DistributionChannels = [Select Id, Name, Active__c,  Channel__c, Site__c
                                        From Distribution_Channel__c
                                        Where 
                                        Channel__c = : currentSalepoint.Id And Active__c = true];
            }
            List < Id > siteIds = new List < Id > ();
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
            
            SOP = string.valueOf(sOrder.ERP7__Order_Profile__c);
            String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
            if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
            
            String PricebookId = Profiling.Price_Book__c;
            Date todays = system.today();
            String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
            UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
            allFieldss += ' ,Product2.Name, Product2.Family, Product2.ERP7__Category__c, Product2.ERP7__Sub_Category__c, Product2.ERP7__Allow_Pre_Orders__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Status__c, Product2.ERP7__Track_Inventory__c ';
            String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ' from PricebookEntry where IsActive = true and Pricebook2Id = :PricebookId'; // and (Product2.Name like: itemNamePSA or Product2.ProductCode like: itemNamePSA or Product2.ERP7__Barcode__c like: itemNamePSA or Product2.ERP7__ASIN_Code__c like: itemNamePSA or Product2.ERP7__SKU__c like: itemNamePSA)'; //     and ERP7__Start_Date__c <= :todays and ERP7__End_Date__c >= :todays
            if(prodFam != null && prodFam != '') querys += ' And Product2.Family = : prodFam';
            if(prodCat != null && prodCat != '') querys += ' And Product2.ERP7__Category__c = : prodCat';
            if(prodSubCat != null && prodSubCat != '') querys += ' And Product2.ERP7__Sub_Category__c = : prodSubCat';
            //if(isBackOrder == false && isPreOrder == false) querys += ' And Product2.ERP7__Status__c = \'Released\'';
            //if(isBackOrder == true) querys += ' And Product2.ERP7__Allow_Back_Orders__c = true And (Product2.ERP7__Status__c = \'Certified\' Or Product2.ERP7__Status__c = \'Released\')';
            //if(isPreOrder == true) querys += ' And Product2.ERP7__Allow_Pre_Orders__c = true And (Product2.ERP7__Status__c = \'Certified\' Or Product2.ERP7__Status__c = \'In Development\')';
            querys += ' Limit 500';
            
            
            List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
            if(Schema.sObjectType.PricebookEntry.isAccessible()){ priceBookEntries = Database.query(querys); }
            Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
            for(PricebookEntry IPE: priceBookEntries) {
                productIds.add(IPE.Product2Id);
                productPriceBookMap.put(IPE.Product2Id, IPE);
            }
            
            
            string kk = String.valueof(itemWrapperList);
       
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
            if(productIds.size() > 0) {
                if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                     Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,
                                                     Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                     From Inventory_Stock__c
                                                     Where product__c In: productIds And
                                                     Active__c = true And
                                                   //  Organisation__c = : currentSalepoint.Organisation__c And
                                                   //  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                                                     Warehouse__c In: siteIds And
                                                     Number_of_Item_In_Stock__c > 0
                                                    ];
            }
            Map < Id, List < Inventory_Stock__c >> productWarehouses = new Map < Id, List < Inventory_Stock__c >> ();
            Map < Id, Decimal > productStock = new Map < Id, Decimal > ();
            List < Id > newProductIds = new List < Id > ();
            
            for(Id pId: productIds) {
                List < Inventory_Stock__c > myWarehouses = new List < Inventory_Stock__c > ();
                Decimal myStock = 0;
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(PId == WIIS.product__c) {
                        myWarehouses.add(WIIS);
                        myStock += WIIS.Number_of_Item_In_Stock__c;
                    }
                }
                if(!productPriceBookMap.get(pId).Product2.ERP7__Track_Inventory__c) {
                    newProductIds.add(PId);
                } else if(myStock >= 0) {
                    newProductIds.add(PId);
                    productWarehouses.put(PId, myWarehouses);
                    productStock.put(PId, myStock);
                }
            }
            
            List < product2 > allProducts = new List < product2 > ();
        
            String allFieldsProduct2 = UtilClass.selectStarFromSObject('Product2');
            String queryProduct2 = 'select ' + String.escapeSingleQuotes(allFieldsProduct2) + ' from Product2 where Id In: newProductIds And IsActive = true ';
           
            if(prodFam != null && prodFam != '') queryProduct2 += ' And Family = : prodFam';
            if(prodCat != null && prodCat != '') queryProduct2 += ' And ERP7__Category__c = : prodCat';
            if(prodSubCat != null && prodSubCat != '') queryProduct2 += ' And ERP7__Sub_Category__c = : prodSubCat';
            queryProduct2 += ' Limit 500';
            if(Schema.sObjectType.Product2.isAccessible()) allProducts = Database.query(queryProduct2);
            
            Integer currentQuantity = 1; //productStock.get(product.Id);
            List < String > prodIds = new List < String > ();
            for(product2 product: allProducts) {
                prodIds.add(product.Id);
            }
            List < Tier_Discount_Allocation__c > TDAS;
            if(Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                    product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                    Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                    Discount_Plan__r.ERP7__Default_Discount_Value__c, Discount_Plan__r.ERP7__Floor_Discount_Value__c, Discount_Plan__r.ERP7__Ceiling_Discount_Value__c
                    From Tier_Discount_Allocation__c
                    Where ERP7__Order_Profile__c = : Profiling.Id And
                    //Organisation__c = : currentSalepoint.Organisation__c And
                    //Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                    product__c In: prodIds And
                    Tier__r.Floor_Unit__c <= : currentQuantity And
                    Tier__r.Ceiling_Unit__c >= : currentQuantity And
                    Tier__r.Active__c = true And
                    Discount_Plan__r.Active__c = true
                ];
            List < Id > discountPlanIds = new List < Id > ();
            Map < Id, Discount_Plan__c > discountMap = new Map < Id, Discount_Plan__c > ();
            for(Tier_Discount_Allocation__c TDA: TDAS) {
                if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
            }
            List < Discount_Plan__c > discounts = new List < Discount_Plan__c > ();
            if(Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                    Organisation__c, Organisation_Business_Unit__c, Status__c
                    From Discount_Plan__c
                    Where Id In: discountPlanIds And
                    Active__c = True
                ];
            for(Discount_Plan__c dis: discounts) {
                discountMap.put(dis.id, dis);
            }
            Map < Id, List < Discount_Plan__c >> discountPlans = new Map < Id, List < Discount_Plan__c >> ();
            Map < Id, String > defaultDiscountMap = new Map < Id, String > ();
            Map < Id, Decimal > defaultDiscountPercentMap = new Map < Id, Decimal > ();
            Map < Id, Decimal > defaultDiscountPercentMapMin = new Map < Id, Decimal > ();
            Map < Id, Decimal > defaultDiscountPercentMapMax = new Map < Id, Decimal > ();
            for(product2 product: allProducts) {
                List < Discount_Plan__c > myDiscountPlans = new List < Discount_Plan__c > ();
                Boolean defaultDiscountfound = false;
                for(Tier_Discount_Allocation__c TDA: TDAS) {
                    if(product.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                        myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                        if(TDA.Default__c == true && !defaultDiscountfound) {
                            defaultDiscountMap.put(product.Id, TDA.Discount_Plan__c);
                            defaultDiscountfound = true;
                            if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c);
                        }
                    }
                }
                discountPlans.put(product.id, myDiscountPlans);
            }
            for(product2 product: allProducts) {
                ProductsAndDiscounts PDs = new ProductsAndDiscounts();
                PDs.product = product;
                List < SelectOption > options = new List < SelectOption > ();
                options.add(new SelectOption('', '--None--'));
                if(discountPlans.get(product.id) != null) {
                    for(Discount_Plan__c dis: discountPlans.get(product.id)) {
                        options.add(new SelectOption(dis.Id,dis.Name));
                    }
                }
                PDs.pricebookEntry = productPriceBookMap.get(product.id);
                PDs.quantity_s = currentQuantity;
                if(defaultDiscountMap.containsKey(product.Id)) PDs.discountName = defaultDiscountMap.get(product.Id);
                else PDs.discountName = '';
                PDs.CurrentDiscounts = options;
                if(defaultDiscountPercentMap.containsKey(product.Id)) PDs.discountPercent = defaultDiscountPercentMap.get(product.Id);
                if(defaultDiscountPercentMapMin.containsKey(product.Id)) PDs.minDiscountPercent = defaultDiscountPercentMapMin.get(product.Id);
                if(defaultDiscountPercentMapMax.containsKey(product.Id)) PDs.maxDiscountPercent = defaultDiscountPercentMapMax.get(product.Id);
                PDS.trackInventory = PDs.pricebookEntry.Product2.ERP7__Track_Inventory__c;
                PDS.checkOutProcess = PDs.pricebookEntry.ERP7__Check_Out_Process__c;
                //PDs.moq = PDs.pricebookEntry.ERP7__MOQ__c;
                //PDs.quantity_s = (PDs.moq !=null)?PDs.moq:currentQuantity;
                PDs.stock = productStock.get(product.Id);
                
                ProductsAndDiscountsWrapperList.add(PDs);
                
            }
            
        } catch(Exception e) { exceptionMethod(e, 'searchProduct'); }
        return null;
    }
    
    /*
      Getter and setter methods 
    */
    
    public string subTotal_n{
      get { if(subTotal != null) return String.valueof(subTotal); else return '';}
      set { subTotal_n = value; }
    }
    public string totalDiscount_n {
      get { if(totalDiscount != null) return String.valueof(totalDiscount); else return '';}
      set { totalDiscount_n = value; }
    }
    public string totalTax_n{
      get { if(totalTax != null) return String.valueof(totalTax); else return '';}
      set { totalTax_n = value; }
    }
    public string totalDue_n{
      get { if(totalDue != null) return String.valueof(totalDue); else return '';}
      set { totalDue_n = value; }
    }
    
    public PageReference proQuantityChange() {
        try { 
            if(quantityEdit != '' && quantityEdit != ''){
                itemWrapperList[integer.valueof(itemPos)].quantity_s = decimal.valueOf(quantityEdit);
                itemWrapperList[integer.valueof(itemPos)].price = itemWrapperList[integer.valueof(itemPos)].unitprice * itemWrapperList[integer.valueof(itemPos)].quantity_s; 
                itemWrapperList[integer.valueof(itemPos)].PriceWithVat = itemWrapperList[integer.valueof(itemPos)].price;
            }
            subTotal = 0.00;
            totalDiscount = 0.00;
            totalDue = 0.00;
            totalTax = 0.00;
            finalDue = 0.00;
            // Amount re-calculation
                for (itemWrapper W: itemWrapperList) {
                    if(W.price != null) subTotal += (W.price).setScale(2);
                    if(W.vat!= null || W.tax != null) totalTax += (W.vat + W.tax).setScale(2);
                    if(W.discount != null) totalDiscount += (W.discount).setScale(2);
                }        
                totalDue = (subTotal + totalTax - totalDiscount).setScale(2);
        } catch(Exception e) { exceptionMethod(e, 'proQuantityChange'); return Null; }
       return null;
    }
    
    public PageReference quantityChange() {
        try{
            
            if(ProductsAndDiscountsWrapperList != null && ProductsAndDiscountsWrapperList.size() > 0) {
                ERP7__Channel__c currentSalepoint = currentSP;
                Account Customer = sAccount;
                Contact Contact = sContact;
                Id selP = sel.product__c;
                ProductsAndDiscounts Wrapper = new ProductsAndDiscounts();
                boolean found = false;
                for(ProductsAndDiscounts pd : ProductsAndDiscountsWrapperList){
                    if(sel.product__c != null && sel.product__c == pd.product.Id){
                        Wrapper = pd;
                        found = true; 
                        break;
                    }
                }
                
                
                if(found){
                    String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
                    String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
                    ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
                    if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
                    
                    String PricebookId = Profiling.Price_Book__c;
                    Date todays = system.today();
                    String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
                    UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
                    
                    String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ', Product2.ERP7__Track_Inventory__c from PricebookEntry where IsActive = true and Pricebook2Id = :PricebookId and Product2Id = :selP'; // and ERP7__Start_Date__c <= :todays and ERP7__End_Date__c >= :todays
                    PricebookEntry priceBookEntry = new PricebookEntry();
                    if(Schema.sObjectType.PricebookEntry.isAccessible()){ priceBookEntry = Database.query(querys); }
                    
                    List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                    if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c,
                                                        product__c, Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,
                                                        Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                        From Inventory_Stock__c
                                                        Where product__c = : sel.product__c And
                                                        Active__c = true And
                                                       // Organisation__c = : currentSalepoint.Organisation__c And
                                                       // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                                                        //Warehouse__c In: siteIds And
                                                        Number_of_Item_In_Stock__c > 0
                                                       ];
                    Decimal myStock = 0;
                    for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                        myStock += WIIS.Number_of_Item_In_Stock__c;
                    }
                    List < SelectOption > options = new List < SelectOption > ();
                    options.add(new SelectOption('', '--None--'));
                    
                    if(wrapper.quantity_s > myStock && priceBookEntry.Product2.ERP7__Track_Inventory__c) wrapper.quantity_s = myStock;
                    List < Tier_Discount_Allocation__c > TDAS;
                    if(Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Price_Book__c,
                            product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                            Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                            Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                              From Tier_Discount_Allocation__c
                              Where ERP7__Order_Profile__c = : Profiling.Id And
                             // Organisation__c = : currentSalepoint.Organisation__c And
                            //  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                              product__c = : sel.product__c And
                              Tier__r.Floor_Unit__c <= : wrapper.quantity_s And
                              Tier__r.Ceiling_Unit__c >= : wrapper.quantity_s And
                              Tier__r.Active__c = true And
                              Discount_Plan__r.Active__c = true];
                              
                    List < Id > discountPlanIds = new List < Id > ();
                    for(Tier_Discount_Allocation__c TDA: TDAS) {
                        if(TDA.Discount_Plan__c != Null) {
                            discountPlanIds.add(TDA.Discount_Plan__c);
                        }
                    }
                    List < Discount_Plan__c > discounts = new List < Discount_Plan__c > ();
                    if(Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c, Ceiling_Discount_Value__c, Default_Discount_Value__c, Floor_Discount_Value__c,
                                     Organisation__c, Organisation_Business_Unit__c, Status__c
                                     From Discount_Plan__c
                                     Where Id In: discountPlanIds And
                                     Active__c = True
                                    ];
                    
                    Boolean defaultDiscountfound = false;
                    for(Tier_Discount_Allocation__c TDA: TDAS) {
                        if(TDA.Discount_Plan__c != Null) {
                            discountPlanIds.add(TDA.Discount_Plan__c);
                        }
                        if(TDA.Default__c == true && !defaultDiscountfound) {
                            wrapper.discountName = TDA.Discount_Plan__c;
                            if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) wrapper.DiscountPercent = TDA.Discount_Plan__r.Default_Discount_Percentage__c;
                            if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null)wrapper.minDiscountPercent = TDA.Discount_Plan__r.Floor_Discount_Percentage__c;
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null)wrapper.maxDiscountPercent = TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c;
                            
                            if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null) wrapper.DiscountPercent = TDA.Discount_Plan__r.Default_Discount_Value__c;
                            if(TDA.Discount_Plan__r.Floor_Discount_Value__c != Null)wrapper.minDiscountPercent = TDA.Discount_Plan__r.Floor_Discount_Value__c;
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Value__c != Null)wrapper.maxDiscountPercent = TDA.Discount_Plan__r.Ceiling_Discount_Value__c;
                            defaultDiscountfound = true;
                        }
                    }
                    if(!defaultDiscountfound) {
                        wrapper.DiscountPercent = 0;
                        wrapper.minDiscountPercent = null;
                        wrapper.maxDiscountPercent = null;
                        wrapper.discountName = '';
                    }
                    for(Discount_Plan__c dis: discounts) {
                        if(wrapper.discountName != String.valueof(dis.id)) options.add(new SelectOption(dis.Id,dis.Name));
                        else options.add(new SelectOption(dis.Id,dis.Name));
                    }
                    wrapper.CurrentDiscounts = options;
                    
                    
                }
                
            }
        } catch(Exception e) { exceptionMethod(e, 'quantityChange'); }
        return null;
    }
    
    public PageReference discountChange() {
        try{
            if(ProductsAndDiscountsWrapperList != null && ProductsAndDiscountsWrapperList.size() > 0) {
                ProductsAndDiscounts myPd = new ProductsAndDiscounts();
                boolean found = false;
                for(ProductsAndDiscounts pd : ProductsAndDiscountsWrapperList){
                    if(sel.product__c != null && sel.product__c == pd.product.Id){
                        myPd = pd;
                        found = true; 
                        break;
                    }
                }
                if(found){
                    string discountName = myPd.discountName;
                    Discount_Plan__c discount;
                    if(Schema.sObjectType.Discount_Plan__c.isAccessible() && discountName instanceOf Id) discount = [Select id, Name, 
                        ERP7__Active__c, ERP7__Description__c, Organisation__c, Organisation_Business_Unit__c, 
                        ERP7__Ceiling_Discount_Percentage__c, ERP7__Default_Discount_Percentage__c, ERP7__Floor_Discount_Percentage__c, 
                        ERP7__Ceiling_Discount_Value__c, ERP7__Default_Discount_Value__c, ERP7__Floor_Discount_Value__c,
                        Status__c
                        From Discount_Plan__c
                        Where Id = : discountName And
                        Active__c = True
                        ];
                        
                    if(discount.Default_Discount_Percentage__c != Null) myPd.discountPercent    = discount.Default_Discount_Percentage__c;
                    if(discount.Floor_Discount_Percentage__c != Null)   myPd.minDiscountPercent = discount.Floor_Discount_Percentage__c;
                    if(discount.Ceiling_Discount_Percentage__c != Null) myPd.maxDiscountPercent = discount.Ceiling_Discount_Percentage__c;
                    
                    if(discount.Default_Discount_Value__c != Null) myPd.discountPercent    = discount.Default_Discount_Value__c;
                    if(discount.Floor_Discount_Value__c != Null)   myPd.minDiscountPercent = discount.Floor_Discount_Value__c;
                    if(discount.Ceiling_Discount_Value__c != Null) myPd.maxDiscountPercent = discount.Ceiling_Discount_Value__c;
                }
                
            }
        } catch(Exception e) { exceptionMethod(e, 'discountChange'); }
        return null;
    }
    
    public PageReference PercentChange() {
            try{
            if(ProductsAndDiscountsWrapperList != null && ProductsAndDiscountsWrapperList.size() > 0) {
                ProductsAndDiscounts myPd = new ProductsAndDiscounts();
                boolean found = false;
                for(ProductsAndDiscounts pd : ProductsAndDiscountsWrapperList){
                    if(sel.product__c != null && sel.product__c == pd.product.Id){
                        myPd = pd;
                        found = true; 
                        break;
                    }
                }
                if(found){
                    string discountName = myPd.discountName;
                    Discount_Plan__c discount;
                    if(Schema.sObjectType.Discount_Plan__c.isAccessible() && discountName instanceOf Id) discount = [Select id, Name, 
                        ERP7__Active__c, ERP7__Description__c, Organisation__c, Organisation_Business_Unit__c, 
                        ERP7__Ceiling_Discount_Percentage__c, ERP7__Default_Discount_Percentage__c, ERP7__Floor_Discount_Percentage__c, 
                        ERP7__Ceiling_Discount_Value__c, ERP7__Default_Discount_Value__c, ERP7__Floor_Discount_Value__c,
                        Status__c
                        From Discount_Plan__c
                        Where Id = : discountName And
                        Active__c = True
                        ];
                        
                    if(!(myPd.discountPercent >= myPd.minDiscountPercent && myPd.discountPercent <= myPd.maxDiscountPercent))
                        myPd.discountPercent = (discount.Default_Discount_Value__c != Null)? discount.Default_Discount_Value__c : discount.Default_Discount_Percentage__c;
                }
                
            }
        } catch(Exception e) { exceptionMethod(e, 'percentChange'); }
        return null;
    }
    
    public PageReference addItem() {
        try{
            
            ERP7__Channel__c currentSalepoint = currentSP;
            Account Customer = sAccount;
            Contact Contact = sContact;
    
            Id currentConId = Contact.Id;
            List < Id > myProductIds = new List < Id > ();
            Map < Id, pricebookEntry > productPricebook = new Map < Id, pricebookEntry > ();
            
            /*Decimal subTotal = 0.00;
            Decimal totalDiscount = 0.00;
            Decimal totalDue = 0.00;
            Decimal totalTax = 0.00;
            Decimal finalDue = 0.00;
            */
            Date todayDate = System.Today();
            
            List < Id > taxPlanIds = new List < Id > ();
            
            List <ProductsAndDiscounts> selectedPandDwrapperList = new List < ProductsAndDiscounts > ();
            if(ProductsAndDiscountsWrapperList != null && ProductsAndDiscountsWrapperList.size() > 0) {
            
                for (ProductsAndDiscounts currentPd: ProductsAndDiscountsWrapperList) {
                    if (currentPd.selected == true) {
                        myProductIds.add(currentPd.product.Id);
                        selectedPandDwrapperList.add(currentPd);
                        taxPlanIds.add(currentPd.pricebookentry.Tax_Plan__c);
                        //selectedProducts.add(currentPd.product.Id);
                        //if(currentPd.bundleId != null) bundleIds.add(currentPd.bundleId);
                    }
                }
                
            }
            
            String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
            String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
            ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
            if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
            Decimal profileVatRate = 0;
            
            //itemWrapperList = new List < itemWrapper > ();    
           
            //products --> taxAllocations --> taxes
            List < Product_Tax_Allocation__c > prodTaxAllocation;
            if(Schema.sObjectType.Product_Tax_Allocation__c.isAccessible()) {
                prodTaxAllocation = [Select Id, Name, Active__c, Organisation_Business_Unit__c, Organisation__c, Tax__c, Tax__r.Active__c,
                Tax__r.Effective_Date__c, Tax__r.Expiry_Date__c, Tax__r.Tax_Rate__c, Tax__r.Type__c, Tax_Plan__c
                From Product_Tax_Allocation__c
                Where Active__c = true And
                Tax_Plan__c In: taxPlanIds And
                Tax__r.Active__c = true And
                Tax__r.Effective_Date__c <= : todayDate And
                Tax__r.Expiry_Date__c >= : todayDate And
                Organisation__c = : currentSalepoint.Organisation__c //And
                //Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                                                                   ];
            }
            
            Map < Id, List < Product_Tax_Allocation__c >> productTaxAllocs = new Map < Id, List < Product_Tax_Allocation__c >> ();
            for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
                List < Product_Tax_Allocation__c > mytaxes = new List < Product_Tax_Allocation__c > ();
                for(Product_Tax_Allocation__c pta: prodTaxAllocation) { 
                    if(currentPd.pricebookentry.Tax_Plan__c != Null && currentPd.pricebookentry.Tax_Plan__c == pta.Tax_Plan__c) {
                        mytaxes.add(pta);
                    }
                }
                if(mytaxes.size() > 0) { productTaxAllocs.put(currentPd.product.Id, mytaxes);
                }
            }
            List < Contact > Conts;
            if(Schema.sObjectType.Contact.isAccessible()) {
                Conts = [Select id, Name, FirstName, LastName, Title, Email, AccountId, Phone, Contact_Numer__c From Contact Where Id = : currentConId Limit 1];
            }
            List < Loyalty_Card__c > clubCard = new List < Loyalty_Card__c > ();
            if(Conts.size() > 0) {
                if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                    clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c,
                Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                Organisation__c, Organisation_Business_Unit__c
                From Loyalty_Card__c Where
                Customer__c = : sContact.AccountId And
                Customer__c != Null And
                Active__c = true And
                Status__c = 'Active'
                And
                Start_date__c <= : todayDate And
                Expiration_Date__c >= : todayDate And
                Organisation__c = : currentSalepoint.Organisation__c //And
               // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                         ];
                }
            }
            List < Id > myAllProgs = new List < Id > ();
            if(clubCard.size() > 0) {
                for(Loyalty_Card__c lc: clubCard) {
                    if(lc.Loyalty_Program__c != Null) { myAllProgs.add(lc.Loyalty_Program__c);
                    }
                }
            }
            //products --> commissionTiers --> commissionPlan --> rateCard
            List < Tier_Commission_Allocation__c > tierCommissions;
            if(Schema.sObjectType.Tier_Commission_Allocation__c.isAccessible()) {
                tierCommissions = [Select Id, Name, Active__c, Commission_Plan__c, Organisation__c, Organisation_Business_Unit__c,
                Price_Book__c, product__c, Tier__c,
                Commission_Plan__r.Active__c, Commission_Plan__r.Status__c, Commission_Plan__r.Effective_Start_Date__c, Commission_Plan__r.Effective_End_Date__c,
                Tier__r.Active__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c
                From Tier_Commission_Allocation__c
                Where Active__c = true And
                Organisation__c = : currentSalepoint.Organisation__c And
              //  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                product__c In: myProductIds And
                Commission_Plan__r.Status__c = 'Manager Approved'
                And
                Commission_Plan__r.Active__c = true And
                Commission_Plan__r.Is_Plan_Current__c = true And
                Commission_Plan__r.Effective_Start_Date__c <= : todayDate And
                Commission_Plan__r.Effective_End_Date__c >= : todayDate And
                Tier__r.Active__c = true
                                                                     ];
            }
            Map < Id, List < Tier_Commission_Allocation__c >> productCommissions = new Map < Id, List < Tier_Commission_Allocation__c >> ();
            for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
                List < Tier_Commission_Allocation__c > mytcas = new List < Tier_Commission_Allocation__c > ();
                for(Tier_Commission_Allocation__c tca: tierCommissions) {
                    if(currentPd.product.Id == tca.product__c) {  mytcas.add(tca);
                    }
                }
                if(mytcas.size() > 0) {  productCommissions.put(currentPd.product.Id, mytcas);
                }
            }
            List < Id > tierCommissionIds = new List < Id > ();
            for(Tier_Commission_Allocation__c tca: tierCommissions) {  tierCommissionIds.add(tca.Commission_Plan__c);
            }
            List < Commission_Rate_Card__c > rateCards;
            if(tierCommissions.size() > 0) {
                if(Schema.sObjectType.Commission_Rate_Card__c.isAccessible()) {
                    rateCards = [Select Id, Name, Active__c, Commission_Plan__c, Organisation__c, Organisation_Business_Unit__c, Price_Book__c, Rate__c
                    From Commission_Rate_Card__c
                    Where Active__c = true And Organisation__c = : currentSalepoint.Organisation__c And Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And Commission_Plan__c In: tierCommissionIds
                    Order by CreatedDate Asc
                            ];
                }
            }
            Map < Tier_Commission_Allocation__c, Commission_Rate_Card__c > commissionRateCard = new Map < Tier_Commission_Allocation__c, Commission_Rate_Card__c > ();
            for(Tier_Commission_Allocation__c tca: tierCommissions) {
                for(Commission_Rate_Card__c crc: rateCards) {
                    if(tca.Price_Book__c == crc.Price_Book__c && tca.Commission_Plan__c == crc.Commission_Plan__c) {
                        commissionRateCard.put(tca, crc);
                    }
                }
            }
            //products --> loyaltyProgramAllocation --> ProgramAllocations
            List < Loyalty_Program_Allocation__c > loyaltyProgramAllocation;
            if(Schema.sObjectType.Loyalty_Program_Allocation__c.isAccessible()) {
                loyaltyProgramAllocation = [Select Id, Name, Loyalty_Programme__c, Loyalty_Programme__r.Active__c,
                Loyalty_Programme__r.Start_Date__c, Loyalty_Programme__r.End_Date__c,
                Loyalty_Programme__r.Loyalty_Setup__c, Loyalty_Programme__r.Priority__c, Loyalty_Programme__r.Tier__c, Organisation__c, Organisation_Business_Unit__c
                From Loyalty_Program_Allocation__c
                Where Organisation__c = : currentSalepoint.Organisation__c And
               // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                Loyalty_Programme__c In: myAllProgs
                                                                              ];
            }
            List < Loyalty_Point_Allocation__c > loyaltyPointAllocation;
            if(Schema.sObjectType.Loyalty_Point_Allocation__c.isAccessible()) {
                loyaltyPointAllocation = [Select Id, Name, Loyalty_Point_Per_Unit__c, Loyalty_Program__c, Loyalty_Program__r.Priority__c,
                Price_Book__c, product__c, Organisation__c, Organisation_Business_Unit__c
                From Loyalty_Point_Allocation__c
                Where product__c In: myProductIds
                Order By Loyalty_Program__r.Priority__c Asc
                                                                          ];
            }
            Map < Id, List < Loyalty_Point_Allocation__c >> loyaltyPointAllocs = new Map < Id, List < Loyalty_Point_Allocation__c >> ();
            for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
                List < Loyalty_Point_Allocation__c > mypoints = new List < Loyalty_Point_Allocation__c > ();
                for(Loyalty_Point_Allocation__c pta: loyaltyPointAllocation) {
                    if(currentPd.product.Id == pta.product__c) {
                        mypoints.add(pta);
                    }
                }if(mypoints.size() > 0) {loyaltyPointAllocs.put(currentPd.product.Id, mypoints);
                }
            }
            //products Addition
            
            for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
                if(currentPd.quantity_s > 0) {
                    itemWrapper Wrap = new itemWrapper();
                    //Wrap.lineitm.Explode__c = currentPd.explode;
                    Wrap.trackInventory = currentPd.trackInventory;
                    Wrap.checkoutprocess = currentPd.checkoutprocess;
                    Wrap.code = currentPd.product.ProductCode;
                    Wrap.itm = currentPd.product.Name;
                    Wrap.itmId = currentPd.product.id;
                    Wrap.product = currentPd.product;
                    Wrap.ImagePreview = currentPd.product.Picture__c;
                    Wrap.quantity = integer.valueOf(currentPd.quantity_s);
                    Wrap.quantity_s = integer.valueOf(currentPd.quantity_s);
                    Wrap.price = (currentPd.pricebookentry.Selling_Price__c != Null && currentPd.quantity_s != Null)? (currentPd.pricebookentry.Selling_Price__c * currentPd.quantity_s).setScale(2) : 0;
                    //Wrap.price = (currentPd.pricebookentry.Selling_Price__c).setScale(2);
                    Wrap.unitprice = (currentPd.pricebookentry.Selling_Price__c != Null)? (currentPd.pricebookentry.Selling_Price__c).setScale(2) : 0;
                    Decimal currentDiscount = 0.00;
                    if(currentPd.discountPercent > 0) {
                        currentDiscount = currentPd.discountPercent / 100;
                    }
                    if(currentPd.discountName != null && currentPd.discountName != '') { wrap.discountId = currentPd.discountName;
                    }
                    if(currentPd.discountPercent != null) { wrap.discountPercent = currentPd.discountPercent;
                    }
                    Wrap.discount = (currentDiscount * Wrap.price).setScale(2);
                    List < Tier_Commission_Allocation__c > tierCommission;
                    tierCommission = (productCommissions.get(currentPd.product.Id) != Null) ? productCommissions.get(currentPd.product.Id) : new List < Tier_Commission_Allocation__c > ();
                    for(Tier_Commission_Allocation__c tc: tierCommission) {
                        Boolean comit = true;
                        if(tc.Tier__r.Floor_Unit__c <= currentPd.quantity_s && tc.Tier__r.Ceiling_Unit__c >= currentPd.quantity_s && comit == true && tc.ERP7__Price_Book__c == currentPd.priceBookEntry.PriceBook2Id) {
                            if(commissionRateCard.get(tc) != Null) {
                                comit = false;
                                List < Commission_Rate_Card__c > rateCard = new List < Commission_Rate_Card__c > ();
                                rateCard.add(commissionRateCard.get(tc));
                                if(rateCard.size() > 0) {
                                    Wrap.commission = (rateCard[0].Rate__c * (Wrap.price - Wrap.discount)) / 100;
                                    Wrap.ratecardId = rateCard[0].Id;
                                }
                            }
                        }
                    }
                    List < Product_Tax_Allocation__c > prodTaxAllocations = (productTaxAllocs.get(currentPd.product.Id) != Null) ? productTaxAllocs.get(currentPd.product.Id) : new List < Product_Tax_Allocation__c > ();
                    Decimal vatAmount = 0;
                    
                    if(TaxRate == 0.00 && Customer.VAT__c != null) TaxRate = Customer.VAT__r.Total_Tax__c;
                    
                    if(!currentPd.pricebookentry.Tax_Exempt__c){
                        if(TaxRate != null && TaxRate > 0.00){
                            Wrap.vat = (TaxRate / 100 * (Wrap.unitprice - Wrap.discount)).setScale(2);
                        }
                        else {
                            Wrap.vat = (currentPd.pricebookentry.Tax_Rate__c / 100 * (Wrap.unitprice - Wrap.discount)).setScale(2);
                        }
                    }else{
                        Wrap.vat = 0.00;
                    }
                   // Wrap.priceWithVat = (Wrap.price - Wrap.discount + Wrap.vat + Wrap.tax).setScale(2);
                    Wrap.priceWithVat = (Wrap.unitprice - Wrap.discount + Wrap.vat).setScale(2);
                    List < Loyalty_Point_Allocation__c > loyaltyPointAllocations = (loyaltyPointAllocs.get(currentPd.product.Id) != Null) ? loyaltyPointAllocs.get(currentPd.product.Id) : new List < Loyalty_Point_Allocation__c > ();
                    Decimal points = 0;
                    Boolean proceed = true;
                    for(Loyalty_Point_Allocation__c loyaltyPoint: loyaltyPointAllocations) {
                        if(proceed && loyaltyPoint.ERP7__Price_Book__c == currentPd.priceBookEntry.PriceBook2Id) {
                            for(Loyalty_Program_Allocation__c loyaltyProgram: loyaltyProgramAllocation) {
                                if(proceed && loyaltyPoint.Loyalty_Program__c == loyaltyProgram.Loyalty_Programme__c && loyaltyProgram.Loyalty_Programme__r.Active__c == true && System.today() >= loyaltyProgram.Loyalty_Programme__r.Start_Date__c && System.today() <= loyaltyProgram.Loyalty_Programme__r.End_Date__c) {
                                    points = loyaltyPoint.Loyalty_Point_Per_Unit__c;
                                    Wrap.programId = loyaltyPoint.Loyalty_Program__c;
                                    proceed = false;
                                }
                            }
                        }
                    }
                    Wrap.pricebookId = currentPd.priceBookEntry.Id;
                    if(Wrap.quantity_s != Null && points != Null) {
                        Wrap.RewardPoints = (points * Wrap.quantity_s).setScale(2);
                    }
                    
                    if(Wrap.quantity_s > 0) {
                        if(Wrap.price != null) subTotal += Wrap.price;
                        if(Wrap.discount != null) totalDiscount += Wrap.discount;
                        if(Wrap.vat != null && Wrap.tax != null) totalTax += (Wrap.vat + Wrap.tax);
                        if(Wrap.priceWithVat != null) totalDue += Wrap.priceWithVat; 
                        itemWrapperList.add(Wrap);
                    }
                }
            }
        } catch(Exception e) { exceptionMethod(e, 'addItem'); }
        
        return null;
    }
    
    public PageReference showLines(){
        listItems = true;
        upperPanel = false;
        return null;
    }
    
    public PageReference hideLines(){
        listItems = false;
        upperPanel = true;
        return null;
    }
    
    public PageReference removeItem() {
        try { 
            if(sOrder.Contact__c != null) currentConId = sOrder.Contact__c;
            subTotal = 0.00;
            totalDiscount = 0.00;
            totalDue = 0.00;
            totalTax = 0.00;
            Integer a = 0; 
            itemWrapper item2delete;
    
            if(bundleId != null && bundleId != '') {
                while (a < itemWrapperList.size()) {
                    if(itemWrapperList.get(a).itemBundleId == bundleId) {
                        item2delete = itemWrapperList.remove(itemPos);
                        if (item2delete.orderLineItemId != '') lineItem2delete.add(item2delete.orderLineItemId);
                    } else a++;  
                } 
            } else {
                item2delete = itemWrapperList.remove(ItemPos);
                //if(item2delete.isRecommendation == true) { recommendationWrapperList.add(item2delete); }
                if (item2delete.orderLineItemId != '') lineItem2delete.add(item2delete.orderLineItemId);
            }    
            for (itemWrapper W: itemWrapperList) {
                if(W.price != null) subTotal += (W.price).setScale(2);
                if(W.vat != null) totalTax += (W.vat).setScale(2);
                if(W.discount != null) totalDiscount += (W.discount).setScale(2);
            }
            totalDue = (subTotal + totalTax - totalDiscount).setScale(2);            
        } catch(Exception e) { exceptionMethod(e, 'removeItem'); }
        
        return null;
    }
     
    public PageReference saveSalesOrder() {
        try { 
            if(sOrder.Contact__c != null) currentConId = sOrder.Contact__c;        
            
            if (lineItem2delete.size() > 0 ) {
                List <ERP7__Quote_Line_Items__c> orderLineItems2Delete = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' from ERP7__Quote_Line_Items__c where '+
                                                                                   '(Id In: lineItem2delete)'); 
                if(Quote_Line_Items__c.sObjectType.getDescribe().isDeletable()){
                    if(ERP7__Quote_Line_Items__c.sObjectType.getDescribe().isDeletable()){ delete orderLineItems2Delete; }else{ }
                }else{ }
                    
            }
            
            Quotes__c salesOrderDraft;
            if(sOrder.Id != null) {
                salesOrderDraft = Database.query('select '+ String.escapeSingleQuotes(SOFields) +' from Quotes__c where Id=\''+ String.escapeSingleQuotes(sOrder.id) +'\' Limit 1');
            }
            
            List < Quote_Line_Items__c > salesOrderLineItem = new List < Quote_Line_Items__c > ();
            List < Loyalty_Points__c > rewards = new List < Loyalty_Points__c > ();            
            for (itemWrapper item: itemWrapperList) {
                if (item.orderLineItemId == '') {
                    Quote_Line_Items__c lineItem = item.lineItm;    
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Base_Price__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Base_Price__c.isUpdateable()){
                        if(item.unitprice == null) lineItem.Base_Price__c = 0;
                        else lineItem.Base_Price__c = item.unitprice;
                    }
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Amount__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Amount__c.isUpdateable()){
                        if(item.discount == null) lineItem.Discount_Amount__c = 0;
                        else lineItem.Discount_Amount__c = item.discount;   
                    }                                             
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Commission__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Commission__c.isUpdateable()) lineItem.Commission__c = item.commission;
                   if(Schema.sObjectType.Quote_Line_Items__c.fields.Commission_Rate_Card__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Commission_Rate_Card__c.isUpdateable()) if(item.ratecardId != '') lineItem.Commission_Rate_Card__c = item.ratecardId;  
                    if(item.discountId != Null && item.discountId != '' && item.discountId != '--None--' && Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Plan__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Plan__c.isUpdateable()) lineItem.Discount_Plan__c = item.discountId; 
                    //if(item.pricebookId != null && item.pricebookId != '') lineItem.PriceBook_Entry__c = item.pricebookId; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Product__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Product__c.isUpdateable()) lineItem.Product__c = item.itmId; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.quantity__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.quantity__c.isUpdateable()) lineItem.quantity__c = item.quantity_s; 
                    /*
                    if(item.itemBundleId != null) {
                        lineItem.Product_Bundle_Group__c = item.itemBundleId;
                        lineItem.ERP7__Is_Bundle_Item__c  = false;
                    }
                    if(item.productBundleId != null) {
                        lineItem.Product_Bundle_Group__c = item.productBundleId;
                        lineItem.ERP7__Is_Bundle_Item__c  = true;
                    }*/
                    if(lineItem.Quotes__c == Null && Schema.sObjectType.Quote_Line_Items__c.fields.Quotes__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Quotes__c.isUpdateable()) lineItem.Quotes__c = salesOrderDraft.id; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Total_Price__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Total_Price__c.isUpdateable())lineItem.Total_Price__c = item.priceWithVat; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.VAT_Amount__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.VAT_Amount__c.isUpdateable()) lineItem.VAT_Amount__c = item.vat;
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Other_Tax__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Other_Tax__c.isUpdateable())lineItem.Other_Tax__c = item.tax; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Inventory_Tracked__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Inventory_Tracked__c.isUpdateable())lineItem.Inventory_Tracked__c = item.trackInventory;
                    if(item.programId != null && item.programId != '' && Schema.sObjectType.Quote_Line_Items__c.fields.Loyalty_Program__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Loyalty_Program__c.isUpdateable()) lineItem.Loyalty_Program__c = item.programId; 
                    if(currentSP.Organisation__c != null && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation__c.isUpdateable()) lineItem.Organisation__c = currentSP.Organisation__c; 
                    if(currentSP.Organisation_Business_Unit__c != null && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation_Business_Unit__c.isUpdateable()) lineItem.Organisation_Business_Unit__c = currentSP.Organisation_Business_Unit__c; 
                    //if(invoice.Id != null) lineItem.Invoice__c = invoice.Id;
                    //if(lineItem.Order_Line_Status__c == '' || lineItem.Order_Line_Status__c == Null) { lineItem.Order_Line_Status__c = (salesOrderDraft.Is_Back_Order__c)? 'Requested' : 'Reserved'; }
                    salesOrderLineItem.add(lineItem);
                            
                } else {
                    Quote_Line_Items__c lineItem = item.lineItm;
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Base_Price__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Base_Price__c.isUpdateable()){
                        if(item.unitprice == null) lineItem.Base_Price__c = 0;
                    else lineItem.Base_Price__c = item.unitprice; 
                    }
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Amount__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Amount__c.isUpdateable()){
                        if(item.discount == null) lineItem.Discount_Amount__c = 0;
                    else lineItem.Discount_Amount__c = item.discount;
                    }
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Commission__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Commission__c.isUpdateable()) lineItem.Commission__c = item.commission;
                    if(item.ratecardId != '' && Schema.sObjectType.Quote_Line_Items__c.fields.Commission_Rate_Card__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Commission_Rate_Card__c.isUpdateable()) lineItem.Commission_Rate_Card__c = item.ratecardId; 
                    if(item.discountId != Null && item.discountId != '' && item.discountId != '--None--' && Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Plan__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Discount_Plan__c.isUpdateable()) lineItem.Discount_Plan__c = item.discountId; 
                    //if(item.pricebookId != null && item.pricebookId != '') lineItem.PriceBook_Entry__c = item.pricebookId; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Product__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Product__c.isUpdateable()) lineItem.Product__c = item.itmId; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.quantity__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.quantity__c.isUpdateable()) lineItem.quantity__c = item.quantity_s; 
                    /*
                    if(item.itemBundleId != null) {
                        lineItem.Product_Bundle_Group__c = item.itemBundleId;
                        lineItem.ERP7__Is_Bundle_Item__c  = false;
                    }
                    if(item.productBundleId != null) {
                        lineItem.Product_Bundle_Group__c = item.productBundleId;
                        lineItem.ERP7__Is_Bundle_Item__c  = true;
                    }*/
                    
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Total_Price__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Total_Price__c.isUpdateable()) lineItem.Total_Price__c = item.priceWithVat; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.VAT_Amount__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.VAT_Amount__c.isUpdateable()) lineItem.VAT_Amount__c = item.vat;
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Other_Tax__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Other_Tax__c.isUpdateable()) lineItem.Other_Tax__c = item.tax; 
                    if(Schema.sObjectType.Quote_Line_Items__c.fields.Inventory_Tracked__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Inventory_Tracked__c.isUpdateable()) lineItem.Inventory_Tracked__c = item.trackInventory;
                    if(item.programId != null && item.programId != '' && Schema.sObjectType.Quote_Line_Items__c.fields.Loyalty_Program__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Loyalty_Program__c.isUpdateable()) lineItem.Loyalty_Program__c = item.programId; 
                    if(currentSP.Organisation__c != null && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation__c.isUpdateable()) lineItem.Organisation__c = currentSP.Organisation__c; 
                    if(currentSP.Organisation_Business_Unit__c != null && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.fields.Organisation_Business_Unit__c.isUpdateable()) lineItem.Organisation_Business_Unit__c = currentSP.Organisation_Business_Unit__c; 
                    //if(invoice.Id != null) lineItem.Invoice__c = invoice.Id;
                    //if(lineItem.Order_Line_Status__c == '' || lineItem.Order_Line_Status__c == Null) { lineItem.Order_Line_Status__c = (salesOrderDraft.Is_Back_Order__c)? 'Requested' : 'Reserved'; }
                    salesOrderLineItem.add(lineItem);
                }
            }
            
            if (salesOrderLineItem.size() > 0 && Schema.sObjectType.Quote_Line_Items__c.isCreateable() && Schema.sObjectType.Quote_Line_Items__c.isUpdateable()){hasAccess=true; upsert salesOrderLineItem; }
            else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
            
            //salesOrderDraft.Amount__c = totalDue; 
            //salesOrderDraft.Loyalty_Amount__c = (LoyaltyAmount == null) ? 0 : LoyaltyAmount; 
            //salesOrderDraft.Loyalty_Points__c = (loyalty_Points == null) ? 0 : loyalty_Points; 
            //if(salesOrderDraft.Order_Status__c == Null) salesOrderDraft.Order_Status__c = 'Entered';
            if(Schema.sObjectType.Quotes__c.isCreateable() && Schema.sObjectType.Quotes__c.isUpdateable()) upsert salesOrderDraft; else{ } 
            
            PageReference page = new PageReference('/'+ salesOrderDraft.Id);
            page.setRedirect(true);
            return page;
        } catch(Exception e) { exceptionMethod(e, 'saveSalesOrder'); return Null; }
    }
    
    /*
       method for catching exception messages
    */
    public void exceptionMethod(Exception e, String methodName) {    
        exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,exceptionMsg));

    }
    public pageReference fetchMoreProducts(){
        off_set += 50;
        noRows +=50;
        return fetchProduct();
    }
    public class itemWrapper {
        public product2 product                         { get; set; }
        public String code                              { get; set; }
        public String itm                               { get; set; }
        public String itmId                             { get; set; }
        public String ImagePreview                      { get; set; }
        public String productId                         { get; set; }
        public String orderLineItemId                   { get; set; }
        public String pricebookId                       { get; set; }
        public Decimal quantity_s                       { get; set; }
        public Integer quantity                         { get; set; }
        public Decimal price                            { get; set; }
        public Decimal vat                              { get; set; }
        public Decimal tax                              { get; set; }
        public Decimal priceWithVat                     { get; set; }
        public String discountName                      { get; set; }
        public String discountId                        { get; set; }
        public Decimal discountPercent                  { get; set; }
        public Decimal discount                         { get; set; }
        public Decimal rewardPoints                     { get; set; }
        public String programId                         { get; set; }
        public Decimal commission                       { get; set; }
        public String ratecardId                        { get; set; }
        public List<Product_Tax_Allocation__c> Taxes    { get; set; }
        public Boolean scanned                          { get; set; }
        public Boolean trackInventory                   { get; set; }
        public String  prod_Desc                        { get; set; }
        public String checkOutProcess                   { get; set; }
        public Quote_Line_Items__c lineitm              { get; set; }
        public Decimal moq                              { get; set; }
        public String Summary                           { get; set; } 
        public Decimal unitprice                        { get; set; }
        public Id itemBundleId                          { get; set; }  
        
        /*
            Inner Constructor For Wrapper Class
        */
        public itemWrapper() {
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
            lineitm = new Quote_Line_Items__c();
            Summary = '';
            unitprice = 0.00;
        }
    }
    
    public List <ProductsAndDiscounts> ProductsAndDiscountsWrapperList     { get; set; }
    public class ProductsAndDiscounts {
        public product2 product                           { get; set; }
        public PricebookEntry pricebookEntry              { get; set; }
        public Decimal quantity_s                         { get; set; }
        public Integer quantity                           { get; set; }
        public String discountName                        { get; set; }
        public String currentConId                        { get; set; }
        public List<SelectOption> CurrentDiscounts        { get; set; }
        public Decimal discountPercent                    { get; set; }
        public Decimal maxDiscountPercent                 { get; set; }
        public Decimal minDiscountPercent                 { get; set; }
        public List<SelectOption> CurrentDiscountPercent { get; set; }
        public Boolean selected                           { get; set; }
        public Boolean trackInventory                     { get; set; }
        public String checkOutProcess                     { get; set; }
        public Decimal moq                                { get; set; } 
        public Decimal stock                              { get; set; }
        public Boolean explode                            { get; set; }
        public String productName                         { get; set; }
        public String PreviewImage                        { get; set; }
        public String ImagePreview                        { get; set; }
        
        public ProductsAndDiscounts() {
            quantity = 1;
            quantity_s = 1;
            discountName = '';
            selected = false;
            trackInventory = false;   
            checkOutProcess = '';     
            pricebookEntry = new PricebookEntry();
            CurrentDiscounts = new List < SelectOption > ();
            CurrentDiscountPercent = new List < SelectOption > ();
            discountPercent = 0;   
            minDiscountPercent = 0;   
            maxDiscountPercent = 0;     
            stock = 0;  
            explode = false;
        }
    }
    
}