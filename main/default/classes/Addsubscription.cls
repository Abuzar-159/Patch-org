public With Sharing Class Addsubscription {
    public Subscription__c subscription                        { get; set; }    
    public String  customers                                   { get; set; }
    public String  profile                                     { get; set; }
    public Sales_Order__c currentSalesOrder                    { get; set; }  
    public List<Subscription_Plan__c> subscriptionPlans        { get; set; }
    public String Plan                                         { get; set; }
    public String currentSubscriptionPlan                      { get; set; }
    public Boolean subscribe                                   { get; set; }
    public List<Product2> allProducts                          { get; set; }    
    public List<Discount_Plan__c> discounts                    { get; set; }
    public Inventory_Stock__c sel                              { get; set; } 
    public Decimal subTotal                                    { get; set; } 
    public Decimal totalDiscount                               { get; set; } 
    public Decimal totalTax                                    { get; set; } 
    public Decimal totalDue                                    { get; set; } 
    public List<itemWrapper> itemWrapperList                   { get; set; }  
    public List<Employees__c> currentEmployee                  { get; set; }  
    public List<Employees__c> currentEmployees                 { get; set; }  
    public List<Contact> Contact                               { get; set; }
    public String currentDuration                              { get; set; }
    public String contactName                                  { get; set; }
    public String errorMsg                                     { get; set; }
    public Decimal subTotal1                                   { get; set; } 
    public Decimal totalDiscount1                              { get; set; } 
    public Decimal totalTax1                                   { get; set; } 
    public Decimal totalDue1                                   { get; set; }  
    public Integer ItemPos                                     { get; set; }  
    public String itemName                                     { get; set; }
    public Product2 pageFls                                    { get; set; }
    public Map<String, Schema.SObjectField> SOLIFields         { get; set; }
    public boolean tabresultpnl                                { get; set; }
    public String tabdispresult                                { get; set; }
    public Boolean IphonePrdLtms                               { get; set; }
    public String comAppend                                    { get; set; }
    public Id currentConId                                     { get; set; }   
    public String billToAddress                                { get; set; }   
    public String shipToAddress                                { get; set; }
    public Subscription__c pageSubscription                    { get; set; }  
    public String billAddressName                              { get; set; }
    public String shipAddressName                              { get; set; }
    public Map<String, String> billId                          { get; set; } 
    public Map<String, String> shipId                          { get; set; } 
    public List<Address__c> billingAddresses                   { get; set; }
    public List<Address__c> shippingAddresses                  { get; set; }
    public Account Customer                                    { get; set; }
    public ERP7__Channel__c currentSalepoint                   { get; set; }
    public Id sId                                              { get; set; }
    public String userAgent;
    
    /*
        Constructors 
    */
    public Addsubscription() {
        tabresultpnl = false;
        tabdispresult = 'none';
    }
    public Addsubscription(ApexPages.StandardController controller) {
        try{
        comAppend = Community_Util.communityValue();
        if (comAppend == null || comAppend == '') {
            comAppend = '/apex';
        } else {comAppend = '/' + comAppend + '/apex';
        }
        subscribe = true;
        tabdispresult = 'none';
        pageFls = new Product2();
        tabresultpnl = false;
        pageFls.Name = '';
        IphonePrdLtms = false;
        Customer = new Account();
        userAgent = System.currentPageReference().getHeaders().get('User-Agent');
        pageSubscription = new Subscription__c();
        currentSubscriptionPlan = '';
        itemWrapperList = new List < itemWrapper > ();
        ProductsAndDiscountsWrapperList = new List < ProductsAndDiscounts > ();
        productWrapperList = new List < productWrapper > ();
        subscribe = true;
        sId = (ApexPages.currentPage().getParameters().get('sid') != Null) ? EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('sid'), 'UTF-8') : Null;
        Id oId = (ApexPages.currentPage().getParameters().get('oid') != Null) ? EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('oid'), 'UTF-8') : Null;
        Id Id = Null;
        customers = ApexPages.currentPage().getParameters().get('cust');
        if (String.isNotEmpty(customers))
            if (Schema.sObjectType.Contact.isAccessible()) Contact = [Select id, Name, FirstName, LastName, Email, AccountId, Phone, Contact_Numer__c From Contact Where Contact_Numer__c = : customers Limit 1];
        contactName = '';
        billingAddresses = new List < Address__c > ();
        shippingAddresses = new List < Address__c > ();
        if (Contact.size() > 0) {
            String CustId = Contact[0].AccountId;
            Customer = [SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, Vat__r.Tax_Rate__c FROM Account WHERE Id = :CustID Limit 1];
            contactName = Contact[0].Name;
            billingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c, Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c
                From Address__c
                Where Customer__c = : Contact[0].AccountId And Active__c = true And Is_Billing_Address__c = true 
                order by Primary__c DESC, CreatedDate ASC
            ];
            shippingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c, Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c
                From Address__c
                Where Customer__c = : Contact[0].AccountId And Active__c = true And Is_Shipping_Address__c = true 
                order by Primary__c DESC, CreatedDate ASC 
            ];
        }
        profile = (ApexPages.currentPage().getParameters().get('profile') != null) ? EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('profile'), 'UTF-8') : null;
        if (Schema.sObjectType.Employees__c.isAccessible()) currentEmployees = [Select Id, Name, First_Name__c, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c, Organisation_Business_Unit__c
            From Employees__c
            Where Employee_User__c = : UserInfo.getUserId()
            order by CreatedDate Asc Limit 1
        ];
        if (Schema.sObjectType.Inventory_Stock__c.isAccessible()) sel = (id == null) ? new Inventory_Stock__c() : [Select id, Name, Product__c From Inventory_Stock__c where Id = : id Limit 1];
        List < Id > subIds = new List < Id > ();
        if (Schema.sObjectType.Subscription_Plan__c.isAccessible()) subscriptionPlans = [Select Id, Name, Active__c, Description__c, Number_of_Days__c, Subscription_Plan__c, ERP7__Order_Profile__c From Subscription_Plan__c Where ERP7__Order_Profile__c = : profile];
        //if(subscriptionPlans.size() > 0) currentSubscriptionPlan = subscriptionPlans[0].Id;
        if (Schema.sObjectType.Subscription__c.isAccessible()) subscription = (sid == null) ? new Subscription__c() : [Select Id, Name, Active__c, Days__c, Next_Order_On__c, Status__c, Sales_Order__c, Subscription_End_Date__c, Duration_In_Months__c, SubscriptionPlan__c, SubscriptionPlan__r.Name, Subscription_Date__c, Description__c, Send_Email_Notication__c From Subscription__c Where id = : sid];
        subscription.Subscription_Date__c = system.today();
        List < Address__c > billingPrimaryAddress;
        if (Schema.sObjectType.Address__c.isAccessible()) 
            billingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
            Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c
            From Address__c
            Where Customer__c = : Contact[0].AccountId  and Active__c = true and Is_Billing_Address__c = true
            Order by Primary__c DESC, CreatedDate ASC Limit 1
        ];
        List < Address__c > shippingPrimaryAddress;
        if (Schema.sObjectType.Address__c.isAccessible()) shippingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
            Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c
            From Address__c
            Where Customer__c = : Contact[0].AccountId  and Active__c = true and Is_Shipping_Address__c = true
            order by Primary__c DESC, CreatedDate ASC Limit 1
        ];
        if (billingPrimaryAddress.size() > 0) {
            pageSubscription.Bill_To_Address__c = '';
                if(billingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line1__c;
                if(billingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line2__c+', ';
                if(billingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line3__c+', ';
                if(billingPrimaryAddress[0].city__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].city__c+', ';
                if(billingPrimaryAddress[0].State__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].State__c+', ';
                if(billingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Postal_Code__c+', ';
                if(billingPrimaryAddress[0].Country__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Country__c;
        }
        if (shippingPrimaryAddress.size() > 0) {
            pageSubscription.Ship_To_Address__c = '';
                    if(shippingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line1__c;
                    if(shippingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line2__c+', ';
                    if(shippingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line3__c+', ';
                    if(shippingPrimaryAddress[0].city__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].city__c+', ';
                    if(shippingPrimaryAddress[0].State__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].State__c+', ';
                    if(shippingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Postal_Code__c+', ';
                    if(shippingPrimaryAddress[0].Country__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Country__c;}
        }catch(Exception e){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
        }
        //populateLineItems();
    }
   
    public List<productWrapper> productWrapperList { get; set; }
    
    public class productWrapper{
        public Product2 product                       { get; set; }
        public String price                           { get; set; }
        public Boolean action                         { get; set; }
        public String prodcode                        { get; set; }
        public productWrapper(){
            product = new Product2();
            price = '';
            action = false;
            prodcode = '';
        }
    }
    
    public List<ProductsAndDiscounts> ProductsAndDiscountsWrapperList     { get; set; }

    
    public class ProductsAndDiscounts {
        public Product2 product                           { get; set; }
        public PricebookEntry pricebookEntry              { get; set; }
        public Integer quantity                           { get; set; }
        public Decimal quantity_s                         { get; set; }
        public String discountName                        { get; set; }
        public String currentConId                        { get; set; }
        public List<SelectOption> CurrentDiscounts        { get; set; }
        public Decimal discountPercent                    { get; set; }  
        public Decimal maxDiscountPercent                 { get; set; }
        public Decimal minDiscountPercent                 { get; set; }     
        public List<SelectOption> CurrentDiscountPercent  { get; set; }        
        public Boolean selected                           { get; set; }
        public Boolean trackInventory                     { get; set; }
        public String checkOutProcess                     { get; set; }
        public Decimal moq                                { get; set; } 
        public Decimal stock                              { get; set; }
        public Boolean explode                            { get; set; }
        
        public ProductsAndDiscounts(){
        try{                   
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
            explode = false; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        }
    }
    
    public class itemWrapper {
        public product2 product                         { get; set; }
        public String code                              { get; set; }
        public String itm                               { get; set; }
        public String itmId                             { get; set; }
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
        public Sales_Order_Line_Item__c lineitm         { get; set; }
        public Decimal moq                              { get; set; }   
        
        /*
            Inner Constructor For Wrapper Class 
        */
        
        public itemWrapper(){
            try{
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
            lineitm = new Sales_Order_Line_Item__c();  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        }
    } 
    
    /*
        Populate Sales Order
    */
    public PageReference populateLineItems() {
        try{
        List < Sales_Order_Line_Item__c > orderLineItem;
        if (Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) orderLineItem = [Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c, Loyalty_Program__c,
            Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Discount_Plan__c,
            Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c,
            Loyalty_Points__c,  Commission_Rate_Card__c, Commission__c, Other_Tax__c
            From Sales_Order_Line_Item__c
            Where Sales_Order__c = : ApexPages.currentPage().getParameters().get('oid')
        ];
        Sales_Order__c currentSalesOrder;
        if (Schema.sObjectType.Sales_Order__c.isAccessible()) currentSalesOrder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.Email,
            Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, 
            Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Employees__c, Employees__r.Email__c, Customer_Email__c, Employee_Email__c, Loyalty_Points__c, Loyalty_Amount__c
            From Sales_Order__c Where
            id = : ApexPages.currentPage().getParameters().get('oid') Limit 1
        ];
        if (currentSalesOrder.Bill_To_Address__c != Null) {
            Address__c baddr;
            if (Schema.sObjectType.Address__c.isAccessible()) baddr = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c, Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c
                From Address__c
                Where id = : currentSalesOrder.Bill_To_Address__c Limit 1
            ];
            
                if (baddr.Address_Line1__c != Null) pageSubscription.Bill_To_Address__c = (Schema.sobjectType.Address__c.fields.Address_Line1__c.isAccessible()) ? baddr.Address_Line1__c + ', ' : '';
                if (baddr.Address_Line2__c != Null) pageSubscription.Bill_To_Address__c += (Schema.sobjectType.Address__c.fields.Address_Line2__c.isAccessible()) ? baddr.Address_Line2__c + ', ' : '';
                if (baddr.Address_Line3__c != Null) pageSubscription.Bill_To_Address__c += (Schema.sobjectType.Address__c.fields.Address_Line3__c.isAccessible()) ? baddr.Address_Line3__c + ', ' : '';
                if (baddr.City__c != Null) pageSubscription.Bill_To_Address__c += (Schema.sobjectType.Address__c.fields.City__c.isAccessible()) ? baddr.City__c + ', ' : '';
                if (baddr.State__c != Null) pageSubscription.Bill_To_Address__c += (Schema.sobjectType.Address__c.fields.State__c.isAccessible()) ? baddr.State__c + ', ' : '';
                if (baddr.Postal_Code__c != Null) pageSubscription.Bill_To_Address__c += (Schema.sobjectType.Address__c.fields.Postal_Code__c.isAccessible()) ? baddr.Postal_Code__c + ', ' : '';
                if (baddr.Country__c != Null) pageSubscription.Bill_To_Address__c += (Schema.sobjectType.Address__c.fields.Country__c.isAccessible()) ? baddr.Country__c + ', ' : '';
           
        }
        if (currentSalesOrder.Ship_To_Address__c != Null) {
            Address__c saddr;
            if (Schema.sObjectType.Address__c.isAccessible()) saddr = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c, Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c
                From Address__c
                Where id = : currentSalesOrder.Ship_To_Address__c Limit 1
            ];
            if (saddr.Address_Line1__c != Null) pageSubscription.Ship_To_Address__c = (Schema.sobjectType.Address__c.fields.Address_Line1__c.isAccessible()) ? saddr.Address_Line1__c + ', ' : '';
            if (saddr.Address_Line2__c != Null) pageSubscription.Ship_To_Address__c += (Schema.sobjectType.Address__c.fields.Address_Line2__c.isAccessible()) ? saddr.Address_Line2__c + ', ' : '';
            if (saddr.Address_Line3__c != Null) pageSubscription.Ship_To_Address__c += (Schema.sobjectType.Address__c.fields.Address_Line3__c.isAccessible()) ? saddr.Address_Line3__c + ', ' : '';
            if (saddr.City__c != Null) pageSubscription.Ship_To_Address__c += (Schema.sobjectType.Address__c.fields.City__c.isAccessible()) ? saddr.City__c + ', ' : '';
            if (saddr.State__c != Null) pageSubscription.Ship_To_Address__c += (Schema.sobjectType.Address__c.fields.State__c.isAccessible()) ? saddr.State__c + ', ' : '';
            if (saddr.Postal_Code__c != Null) pageSubscription.Ship_To_Address__c += (Schema.sobjectType.Address__c.fields.Postal_Code__c.isAccessible()) ? saddr.Postal_Code__c + ', ' : '';
            if (saddr.Country__c != Null) pageSubscription.Ship_To_Address__c += (Schema.sobjectType.Address__c.fields.Country__c.isAccessible()) ? saddr.Country__c + ', ' : '';
            
        }
        itemWrapperList = new List < itemWrapper > ();
        for (Sales_Order_Line_Item__c lineItem: orderLineItem) {
            itemWrapper item = new itemWrapper();
            if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.ERP7__Product__c.isAccessible() && Schema.sobjectType.Product2.fields.SKU__c.isAccessible()) item.code = lineItem.Product__r.SKU__c;
            if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.ERP7__Product__c.isAccessible() && Schema.sobjectType.Product2.fields.Name.isAccessible()) item.itm = lineItem.Product__r.Name;
            if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.ERP7__Product__c.isAccessible()) item.itmId = lineItem.Product__c;
            if (lineItem.Discount_Plan__c != Null) {if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Discount_Plan__c.isAccessible()) item.discountId = lineItem.Discount_Plan__c;
            }
            if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Loyalty_Program__c.isAccessible()) item.programId = lineItem.Loyalty_Program__c;
            if (lineItem.Commission_Rate_Card__c != Null) {if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Commission_Rate_Card__c.isAccessible()) item.ratecardId = lineItem.Commission_Rate_Card__c;
            }
            if (lineItem.Commission__c != Null) {
                if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Commission__c.isAccessible()) item.commission = lineItem.Commission__c;
            }
            Integer quant = 0;
            Decimal totalDetuct = 0;
            if (lineItem.Quantity__c != Null) item.quantity = Integer.valueof(lineItem.Quantity__c) - quant; else item.quantity = 0;
            if (lineItem.Quantity__c != Null) item.rewardpoints = (lineItem.Loyalty_Points__c) / (lineItem.Quantity__c) * item.quantity;
            if (lineItem.Quantity__c != Null) item.price = (lineItem.Base_Price__c / Integer.valueof(lineItem.Quantity__c)) * item.quantity; else item.price = 0;
            if (lineItem.VAT_Amount__c != Null && lineItem.Quantity__c != Null) {
                if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.VAT_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order_Line_Item__c.fields.Quantity__c.isAccessible()) item.vat = (lineItem.VAT_Amount__c / Integer.valueof(lineItem.Quantity__c)) * item.quantity;
            }
            if (lineItem.Other_Tax__c != Null && lineItem.Quantity__c != Null) {
                if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Other_Tax__c.isAccessible() && Schema.sobjectType.Sales_Order_Line_Item__c.fields.Quantity__c.isAccessible()) item.tax = (lineItem.Other_Tax__c / Integer.valueof(lineItem.Quantity__c)) * item.quantity;
            }
            if (lineItem.Discount_Amount__c != Null && lineItem.Quantity__c != Null) {
                if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Discount_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order_Line_Item__c.fields.Quantity__c.isAccessible()) item.discount = (lineItem.Discount_Amount__c / Integer.valueof(lineItem.Quantity__c)) * item.quantity;
            }
            if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Total_Price__c.isAccessible()) item.priceWithVat = lineItem.Total_Price__c - totalDetuct;
            item.orderLineItemId = lineItem.Id;
            itemWrapperList.add(item);
        }
        subTotal = 0;
        totalDiscount = 0;
        totalDue = 0;
        totalTax = 0;
        for (itemWrapper iwrap: itemWrapperList) {
            subTotal += iwrap.price;
            totalDiscount += iwrap.discount;
            totalDue += iwrap.priceWithVat;
            totalTax += (iwrap.vat + iwrap.tax);
        }
        return null;}catch(Exception e){return null;
        }
    }
    /*
        Fetch Products of Particular order profile
    */
    public void processIphoneProducts() {
        IphonePrdLtms = true;
    }
    
    public void processProducts() {
        tabdispresult = 'visible';   
        tabresultpnl = true;
        if(plan == Null || plan == '--None--'){errorMsg = 'Please select subscription plan';
        }
        else{
            errorMsg = '';
        }
        Map<Id, Decimal> productPricebook = new Map<Id, Decimal>();
        List<Id> productIds = new List<Id>();
       
                
        List<Product_subscription_Plan_Allocation__c> PSA = [Select Id, Name, Active__c,  Product__c, Subscription_Plan__c
                                                                From Product_subscription_Plan_Allocation__c
                                                                Where Subscription_Plan__c =: currentSubscriptionPlan And
                                                                Subscription_Plan__c != Null And
                                                                Active__c = true
                                                                Limit 40000];            
        for(Product_subscription_Plan_Allocation__c pa : PSA){
            boolean add = true;
            for(ProductsAndDiscounts pd : ProductsAndDiscountsWrapperList){if(pa.Product__c == pd.product.Id){add = false;}
            }
            if(add){
                productIds.add(pa.Product__c);
            }
        }
             
        if(pageFls.Name == Null) pageFls.Name = '';
        allProducts = [Select id, Name, Barcode__c, ProductCode, ERP7__MOQ__c,Category__c, ERP7__SKU__c, Special_Instructions__c, Expiration_Date__c, Item_Description__c,  Item_Type__c, Item_Unit__c, Item_Unit_Value__c, Picture__c, Sub_Category__c
                          From Product2
                          Where id In : productIds And
                          Name like : '%'+pageFls.Name+'%' Limit 100];
       
        
        List<Profiling__c> Profiling = [Select Id, Name, Active__c, Price_Book__c 
          From Profiling__c 
          Where Id =: profile 
        ];         
        
      
      List < PricebookEntry > priceBookEntries = new List < PricebookEntry >();
      
      if(Profiling.size() > 0){
        String PricebookId = Profiling[0].Price_Book__c;
        priceBookEntries = [Select id, Name, Barcode__c, End_Date__c, Product2Id, Pricebook2Id, Product2.ERP7__MOQ__c, Purchase_Price__c, Product2.Track_Inventory__c,
            Selling_Price__c, Start_Date__c
            From PricebookEntry
            Where Product2Id In: ProductIds And 
            Pricebook2Id = :PricebookId
            Order by CreatedDate Asc
        ];
      }
        for(PricebookEntry pbe : priceBookEntries ){
             if(pbe.Selling_Price__c != null) productPricebook.put(pbe.product2Id, pbe.Selling_Price__c.setScale(2));
        }
                                                             
        
        productWrapperList = new List<productWrapper>();        
        for(Product2 product : allProducts){            
            productWrapper wrap = new productWrapper();
            wrap.product = product;
            wrap.prodcode = string.valueof(product.ProductCode);
            wrap.price = (productPricebook.get(product.Id) != Null)? string.valueof(productPricebook.get(product.Id)) : '';
            productWrapperList.add(wrap);
           
        }
        
      //  return Null;
    
    }
    
    public void processChangeProducts() {
        errorMsg = '';
        productWrapperList = new List < productWrapper > ();
        ProductsAndDiscountsWrapperList = new List < ProductsAndDiscounts > ();
    }
    /*
        Add Selected Products
    */
    public pageReference addProducts() {
        try{
            IphonePrdLtms = false;
            List < Id > myProdIds = new List < Id > ();
            List < Product2 > mySelectedProducts = new List < Product2 > ();
            tabresultpnl = true;
            for (productWrapper wrap: productWrapperList) {
                boolean proceed = true;
                for (ProductsAndDiscounts pd: ProductsAndDiscountsWrapperList) {if (pd.product.Id == wrap.product.Id) {proceed = false;}
                }
                if (wrap.action == true && proceed == true) {
                    myProdIds.add(wrap.product.Id);
                    mySelectedProducts.add(wrap.product);
                }
            }
            Integer j = 0;
            while (j < productWrapperList.size()) {
                if (productWrapperList.get(j).action == true) {
                    productWrapperList.remove(j);} else {j++;
                }
            }
            List < Id > productIds = new List < Id > ();
            ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
            String OrgnPSA = currentSalepoint.Organisation__c;
            String OrgnBusIdPSA = currentSalepoint.Organisation_Business_Unit__c;
            String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
            
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
            String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :profile';
            if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
            
            
            String PricebookId = Profiling.Price_Book__c;
            Date todays = system.today(); 
            String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
            UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
            allFieldss += ' ,Product2.Name, Product2.ERP7__MOQ__c, Product2.Family, Product2.ERP7__Category__c, Product2.ERP7__Sub_Category__c, Product2.Track_Inventory__c ';
            String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ' from PricebookEntry where IsActive = true and Pricebook2Id = :PricebookId and Product2Id In :myProdIds';
            
            
            
            List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
            if(Schema.sObjectType.PricebookEntry.isAccessible()){
            priceBookEntries = Database.query(querys);}
            
            Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
            for(PricebookEntry IPE: priceBookEntries) {
                productIds.add(IPE.Product2Id);
                productPriceBookMap.put(IPE.Product2Id, IPE);
            }
            
            string kk = String.valueof(itemWrapperList);
           
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
            if(productIds.size() > 0) {
                if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c,  Warehouse__c, product__c,
                                                     Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c,
                                                     Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                     From Inventory_Stock__c
                                                     Where product__c In: myProdIds And
                                                     Active__c = true And
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
                if(!productPriceBookMap.get(pId).Product2.Track_Inventory__c) {newProductIds.add(PId);
                } else if(myStock >= 0) {
                    newProductIds.add(PId);
                    productWarehouses.put(PId, myWarehouses);
                    productStock.put(PId, myStock);
                }
            }
                        
            Integer currentQuantity = 1;
            List < Tier_Discount_Allocation__c > TDAS;
            if (Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c,  
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c
                From Tier_Discount_Allocation__c
                Where Product__c In: myProdIds And
                Tier__r.Floor_Unit__c <= : currentQuantity And
                Tier__r.Ceiling_Unit__c >= : currentQuantity And
                Tier__r.Active__c = true And
                Discount_Plan__r.Active__c = true
            ];
            List < Id > discountPlanIds = new List < Id > ();
            Map < Id, Discount_Plan__c > discountMap = new Map < Id, Discount_Plan__c > ();
            for (Tier_Discount_Allocation__c TDA: TDAS) {
                if (TDA.Discount_Plan__c != Null)
                    if (Schema.sobjectType.Tier_Discount_Allocation__c.fields.Discount_Plan__c.isAccessible()) discountPlanIds.add(TDA.Discount_Plan__c);
            }
            if (Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c, Status__c
                From Discount_Plan__c
                Where Id In: discountPlanIds And
                Active__c = True
            ];
            for (Discount_Plan__c dis: discounts) {
                discountMap.put(dis.id, dis);
            }
            
            
            Map < Id, List < Discount_Plan__c >> discountPlans = new Map < Id, List < Discount_Plan__c >> ();
            Map < Id, String > defaultDiscountMap = new Map < Id, String > ();
            Map < Id, Decimal > defaultDiscountPercentMap = new Map < Id, Decimal > ();
            Map < Id, Decimal > defaultDiscountPercentMapMin = new Map < Id, Decimal > ();
            Map < Id, Decimal > defaultDiscountPercentMapMax = new Map < Id, Decimal > ();
            
            for(product2 product: mySelectedProducts) {
                List < Discount_Plan__c > myDiscountPlans = new List < Discount_Plan__c > ();
                Boolean defaultDiscountfound = false;
                for(Tier_Discount_Allocation__c TDA: TDAS) {
                    if(product.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                        myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                        if(TDA.Default__c == true && !defaultDiscountfound) {defaultDiscountMap.put(product.Id, TDA.Discount_Plan__c); defaultDiscountfound = true; if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Percentage__c); if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Percentage__c); if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c);
                        }
                    }
                }
                discountPlans.put(product.id, myDiscountPlans);
            }
            
            for (Product2 product: mySelectedProducts) {
                ProductsAndDiscounts PDs = new ProductsAndDiscounts();
                PDs.product = product;
                List < SelectOption > options = new List < SelectOption > ();
                options.add(new SelectOption('', '--None--'));
                if(discountPlans.get(product.id) != null) {
                    for(Discount_Plan__c dis: discountPlans.get(product.id)) {
                        options.add(new SelectOption(dis.id,dis.Name));
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
                PDS.trackInventory = PDs.pricebookEntry.Product2.Track_Inventory__c;
                PDS.checkOutProcess = PDs.pricebookEntry.ERP7__Check_Out_Process__c;
                PDs.moq = PDs.product.ERP7__MOQ__c;
                if(productStock.containsKey(product.Id)) PDs.stock = productStock.get(product.Id);
                ProductsAndDiscountsWrapperList.add(PDs);
                }
            
         }catch(Exception e){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber()));
             system.debug('error : '+e.getMessage() +'Line Number @ : '+ e.getLineNumber());
         }
         return null;
    }
    /*
        Remove Selected Products 
    */
    public PageReference removeProduct() {
        try {
            Integer j = 0;
            while (j < ProductsAndDiscountsWrapperList.size()) {
                if (ProductsAndDiscountsWrapperList.get(j).selected == true) { ProductsAndDiscountsWrapperList.remove(j); } else { j++; }
            }
            processProducts();
            return Null;} Catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber())); return Null; }
    }
   
    public void clearResults() {
        try {
            productWrapperList.clear();
            IphonePrdLtms = false;} catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber()));
        }
    }
    /*
        Process Discounts
    */
    public PageReference addDiscount() {
        try {
            List < SelectOption > options = new List < SelectOption > ();
            options.add(new SelectOption('--None--', '--None--'));
            for (ProductsAndDiscounts wrapper: ProductsAndDiscountsWrapperList) {
                if (wrapper.product.Id == sel.Product__c && wrapper.quantity > 0) {
                    List < Tier_Discount_Allocation__c > TDAS;
                    if (Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c,  Price_Book__c, Product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Active__c From Tier_Discount_Allocation__c Where Product__c = : wrapper.product.Id And Tier__r.Floor_Unit__c <= : wrapper.quantity And Tier__r.Ceiling_Unit__c >= : wrapper.quantity And Tier__r.Active__c = true And Discount_Plan__r.Active__c = true];
                    List < Id > discountPlanIds = new List < Id > ();
                    for (Tier_Discount_Allocation__c TDA: TDAS) {
                        if (TDA.Discount_Plan__c != Null)
                            if (Schema.sobjectType.Tier_Discount_Allocation__c.fields.Discount_Plan__c.isAccessible()) discountPlanIds.add(TDA.Discount_Plan__c);
                    }
                    if (Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c, Status__c From Discount_Plan__c Where Id In: discountPlanIds And Active__c = True];
                    for (Discount_Plan__c dis: discounts) {
                        if (Schema.sobjectType.Discount_Plan__c.isAccessible()) options.add(new SelectOption(dis.id, dis.Name));
                    }
                    wrapper.DiscountName = null;
                    wrapper.CurrentDiscounts = options;} else if (wrapper.quantity <= 0) { wrapper.CurrentDiscounts = new List < SelectOption > ();
                }
                wrapper.CurrentDiscountPercent = new List < SelectOption > ();
                wrapper.DiscountPercent = 0;
                wrapper.minDiscountPercent = null;
                wrapper.maxDiscountPercent = null;
            }
            sel.Product__c = null;
            return null;} catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber())); return null;
        }
    }
    /*
        Process Discounts Percent
    */
    public pageReference DiscountPercent() {
        //try {
            List < SelectOption > options = new List < SelectOption > ();
            Discount_Plan__c currentDiscount;
            for (ProductsAndDiscounts wrapper: ProductsAndDiscountsWrapperList) {  if (wrapper.product.Id == sel.Product__c) { if (wrapper.discountname != '--None--' && wrapper.discountname != Null) {  if (Schema.sObjectType.Discount_Plan__c.isAccessible()) currentDiscount = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,  Status__c From Discount_Plan__c Where Id = : wrapper.discountName Limit 1];  options.add(new SelectOption(string.Valueof(currentDiscount.Default_Discount_Percentage__c), string.Valueof(currentDiscount.Default_Discount_Percentage__c)));
                        if (currentDiscount.Ceiling_Discount_Percentage__c != Null && currentDiscount.Floor_Discount_Percentage__c != Null) {  Decimal lm;
                            if (Schema.sobjectType.Discount_Plan__c.fields.Floor_Discount_Percentage__c.isAccessible()) lm = currentDiscount.Floor_Discount_Percentage__c;
                            if (Schema.sobjectType.Discount_Plan__c.fields.Floor_Discount_Percentage__c.isAccessible()) while (lm <= currentDiscount.Ceiling_Discount_Percentage__c) { options.add(new SelectOption(string.Valueof(lm), string.Valueof(lm))); lm++;
                                }
                        }
                        wrapper.CurrentDiscountPercent = options; if (wrapper.DiscountPercent == Null || !(wrapper.DiscountPercent >= wrapper.minDiscountPercent && wrapper.DiscountPercent <= wrapper.maxDiscountPercent)) { if (Schema.sobjectType.Discount_Plan__c.fields.Default_Discount_Percentage__c.isAccessible()) wrapper.DiscountPercent = currentDiscount.Default_Discount_Percentage__c;
                        }
                        if (Schema.sobjectType.Discount_Plan__c.fields.Floor_Discount_Percentage__c.isAccessible()) wrapper.minDiscountPercent = currentDiscount.Floor_Discount_Percentage__c;if (Schema.sobjectType.Discount_Plan__c.fields.Ceiling_Discount_Percentage__c.isAccessible()) wrapper.maxDiscountPercent = currentDiscount.Ceiling_Discount_Percentage__c;
                    } else {
                        wrapper.CurrentDiscountPercent = options;  wrapper.DiscountPercent = 0; wrapper.minDiscountPercent = null; wrapper.maxDiscountPercent = null;
                    }
                }
            }
            sel.Product__c = null;
            return null;
       /* } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber()));
            return null;
        }*/
    }
    /*
        Add all the selected products to wrapper List
    */
    public List < itemWrapper > getCurrentWrapperList() {
        //try{
        String OID = ApexPages.currentPage().getParameters().get('oid');
        currentSalesOrder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.Email,
                                                Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, 
                                                Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Employees__c, Employees__r.Email__c, Customer_Email__c, Employee_Email__c, Loyalty_Points__c, Loyalty_Amount__c
                                                From Sales_Order__c Where
                                                id = : ApexPages.currentPage().getParameters().get('oid') Limit 1];
                                            
        currentSalepoint = [Select Id, Name, Organisation__c,Organisation_Business_Unit__c,ERP7__Active__c, ERP7__City__c, ERP7__Country__c,  ERP7__Site__c,
                                                ERP7__State_Province__c, ERP7__Street__c, ERP7__Tax__c, ERP7__Zip_Postal_Code__c, ERP7__Shipper_Name__c, ERP7__Company__c, 
                                                ERP7__Phone__c From ERP7__Channel__c Where Id = : currentSalesorder.ERP7__Channel__c Limit 1];
        
        List < ProductsAndDiscounts > deserializedList = ProductsAndDiscountsWrapperList;
        Id currentConId = Contact[0].Id;
        List < Id > myProductIds = new List < Id > ();
        Map < Id, pricebookEntry > productPricebook = new Map < Id, pricebookEntry > ();
        Decimal subTotal = 0.00;
        Decimal totalDiscount = 0.00;
        Decimal totalDue = 0.00;
        Decimal totalTax = 0.00;
        Decimal finalDue = 0.00;
        Date todayDate = System.Today();
        List < ProductsAndDiscounts > selectedPandDwrapperList = new List < ProductsAndDiscounts > ();
        List < Id > taxPlanIds = new List < Id > ();
        
        for(ProductsAndDiscounts currentPd: deserializedList) { myProductIds.add(currentPd.product.Id);  selectedPandDwrapperList.add(currentPd);  taxPlanIds.add(currentPd.pricebookentry.Tax_Plan__c);
        }
        
        String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
        String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :profile';
        ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
        if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
        Decimal profileVatRate = 0;
        if(Customer.Vat__c != Null && Customer.Vat__r.Tax_Rate__c != Null) profileVatRate = Customer.Vat__r.Tax_Rate__c;
        List < itemWrapper > itemWrapperList = new List < itemWrapper > ();    
       
        //products --> taxAllocations --> taxes
        List < Product_Tax_Allocation__c > prodTaxAllocation;
        if(Schema.sObjectType.Product_Tax_Allocation__c.isAccessible()) {
            prodTaxAllocation = [Select Id, Name, Active__c, Tax__c, Tax__r.Active__c,
            Tax__r.Effective_Date__c, Tax__r.Expiry_Date__c, Tax__r.Tax_Rate__c, Tax__r.Type__c, Tax_Plan__c
            From Product_Tax_Allocation__c
            Where Active__c = true And
            Tax_Plan__c In: taxPlanIds And
            Tax__r.Active__c = true And
            Tax__r.Effective_Date__c <= : todayDate And
            Tax__r.Expiry_Date__c >= : todayDate ];
        }
        
        Map < Id, List < Product_Tax_Allocation__c >> productTaxAllocs = new Map < Id, List < Product_Tax_Allocation__c >> ();
        for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
            List < Product_Tax_Allocation__c > mytaxes = new List < Product_Tax_Allocation__c > ();  for(Product_Tax_Allocation__c pta: prodTaxAllocation) { if(currentPd.pricebookentry.Tax_Plan__c != Null && currentPd.pricebookentry.Tax_Plan__c == pta.Tax_Plan__c) {mytaxes.add(pta);
                }
            }
            if(mytaxes.size() > 0) { productTaxAllocs.put(currentPd.product.Id, mytaxes);
            }
        }
        List < Contact > Contacts;
        
            Contacts = [Select id, Name, FirstName, LastName, Title, Email, AccountId, Phone, Contact_Numer__c From Contact Where Id = : currentConId Limit 1];
        
        List < Loyalty_Card__c > clubCard = new List < Loyalty_Card__c > ();
        if(Contacts.size() > 0) {
            if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c,
            Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c
            From Loyalty_Card__c Where
            Customer__c = : Contacts[0].AccountId And
            Customer__c != Null And
            Active__c = true And
            Status__c = 'Active'
            And
            Start_date__c <= : todayDate And
            Expiration_Date__c >= : todayDate 
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
            tierCommissions = [Select Id, Name, Active__c, Commission_Plan__c,
            Price_Book__c, product__c, Tier__c,
            Commission_Plan__r.Active__c, Commission_Plan__r.Status__c, Commission_Plan__r.Effective_Start_Date__c, Commission_Plan__r.Effective_End_Date__c,
            Tier__r.Active__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c
            From Tier_Commission_Allocation__c
            Where Active__c = true  And
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
            List < Tier_Commission_Allocation__c > mytcas = new List < Tier_Commission_Allocation__c > (); for(Tier_Commission_Allocation__c tca: tierCommissions) {if(currentPd.product.Id == tca.product__c) {  mytcas.add(tca);
                }
            }
            if(mytcas.size() > 0) {  productCommissions.put(currentPd.product.Id, mytcas);
            }
        }
        List < Id > tierCommissionIds = new List < Id > ();
        for(Tier_Commission_Allocation__c tca: tierCommissions) {  tierCommissionIds.add(tca.Commission_Plan__c);
        }
        List < Commission_Rate_Card__c > rateCards;
        if(tierCommissions.size() > 0) { if(Schema.sObjectType.Commission_Rate_Card__c.isAccessible()) { rateCards = [Select Id, Name, Active__c, Commission_Plan__c,  Price_Book__c, Rate__c From Commission_Rate_Card__c Where Active__c = true And Commission_Plan__c In: tierCommissionIds Order by CreatedDate Asc];
            }
        }
        Map < Tier_Commission_Allocation__c, Commission_Rate_Card__c > commissionRateCard = new Map < Tier_Commission_Allocation__c, Commission_Rate_Card__c > ();
        for(Tier_Commission_Allocation__c tca: tierCommissions) {for(Commission_Rate_Card__c crc: rateCards) { if(tca.Price_Book__c == crc.Price_Book__c && tca.Commission_Plan__c == crc.Commission_Plan__c) { commissionRateCard.put(tca, crc);}
            }
        }
        //products --> loyaltyProgramAllocation --> ProgramAllocations
        List < Loyalty_Program_Allocation__c > loyaltyProgramAllocation;
        if(Schema.sObjectType.Loyalty_Program_Allocation__c.isAccessible()) {
            loyaltyProgramAllocation = [Select Id, Name, Loyalty_Programme__c, Loyalty_Programme__r.Active__c,
            Loyalty_Programme__r.Start_Date__c, Loyalty_Programme__r.End_Date__c,
            Loyalty_Programme__r.Loyalty_Setup__c, Loyalty_Programme__r.Priority__c, Loyalty_Programme__r.Tier__c
            From Loyalty_Program_Allocation__c
            Where 
            Loyalty_Programme__c In: myAllProgs
                                                                          ];
        }
        List < Loyalty_Point_Allocation__c > loyaltyPointAllocation;
        if(Schema.sObjectType.Loyalty_Point_Allocation__c.isAccessible()) {
            loyaltyPointAllocation = [Select Id, Name, Loyalty_Point_Per_Unit__c, Loyalty_Program__c, Loyalty_Program__r.Priority__c,
            Price_Book__c, product__c
            From Loyalty_Point_Allocation__c
            Where product__c In: myProductIds
            Order By Loyalty_Program__r.Priority__c Asc
                                                                      ];
        }
        Map < Id, List < Loyalty_Point_Allocation__c >> loyaltyPointAllocs = new Map < Id, List < Loyalty_Point_Allocation__c >> ();
        for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
            List < Loyalty_Point_Allocation__c > mypoints = new List < Loyalty_Point_Allocation__c > ();
            for(Loyalty_Point_Allocation__c pta: loyaltyPointAllocation) { if(currentPd.product.Id == pta.product__c) { mypoints.add(pta);}
            }if(mypoints.size() > 0) {loyaltyPointAllocs.put(currentPd.product.Id, mypoints);
            }
        }
        //products Addition
        
        for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
            if(currentPd.quantity_s > 0) {  itemWrapper Wrap = new itemWrapper(); Wrap.lineitm.Explode__c = currentPd.explode;  Wrap.trackInventory = currentPd.trackInventory;  Wrap.checkoutprocess = currentPd.checkoutprocess;  Wrap.code = currentPd.product.ProductCode; Wrap.itm = currentPd.product.Name; Wrap.itmId = currentPd.product.id;  Wrap.product = currentPd.product;  Wrap.quantity_s = currentPd.quantity_s; Wrap.price = (currentPd.pricebookentry.Selling_Price__c == Null || currentPd.quantity_s == Null)? 0 :(currentPd.pricebookentry.Selling_Price__c * currentPd.quantity_s).setScale(2);
                Decimal currentDiscount = 0.00;  if(currentPd.discountPercent > 0) { currentDiscount = currentPd.discountPercent / 100;
                }
                if(currentPd.discountName != null && currentPd.discountName != '') { wrap.discountId = currentPd.discountName;
                }
                if(currentPd.discountPercent != null) { wrap.discountPercent = currentPd.discountPercent;
                }
                Wrap.discount = (currentDiscount * Wrap.price).setScale(2); List < Tier_Commission_Allocation__c > tierCommission; tierCommission = (productCommissions.get(currentPd.product.Id) != Null) ? productCommissions.get(currentPd.product.Id) : new List < Tier_Commission_Allocation__c > ();
                for(Tier_Commission_Allocation__c tc: tierCommission) { Boolean comit = true; if(tc.Tier__r.Floor_Unit__c <= currentPd.quantity_s && tc.Tier__r.Ceiling_Unit__c >= currentPd.quantity_s && comit == true && tc.ERP7__Price_Book__c == currentPd.priceBookEntry.PriceBook2Id) { if(commissionRateCard.get(tc) != Null) { comit = false; List < Commission_Rate_Card__c > rateCard = new List < Commission_Rate_Card__c > ();  rateCard.add(commissionRateCard.get(tc));  if(rateCard.size() > 0) { Wrap.commission = (rateCard[0].Rate__c * (Wrap.price - Wrap.discount)) / 100; Wrap.ratecardId = rateCard[0].Id;}
                        }
                    }
                }
                List < Product_Tax_Allocation__c > prodTaxAllocations = (productTaxAllocs.get(currentPd.product.Id) != Null) ? productTaxAllocs.get(currentPd.product.Id) : new List < Product_Tax_Allocation__c > ();  Decimal vatAmount = 0;
                for(Product_Tax_Allocation__c pta: prodTaxAllocations) { if(pta.Tax__r.Type__c == 'VAT') { Wrap.Taxes.add(pta);  vatAmount += (pta.Tax__r.Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                    }
                }
                Wrap.vat = vatAmount + (profileVatRate / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                Decimal taxAmount = 0;
                for(Product_Tax_Allocation__c pta: prodTaxAllocations) { if(pta.Tax__r.Type__c != 'VAT') { Wrap.Taxes.add(pta); taxAmount += (pta.Tax__r.Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                    }
                }
                Wrap.tax = taxAmount;  Wrap.priceWithVat = (Wrap.price - Wrap.discount + Wrap.vat + Wrap.tax)
                    .setScale(2);
                List < Loyalty_Point_Allocation__c > loyaltyPointAllocations = (loyaltyPointAllocs.get(currentPd.product.Id) != Null) ? loyaltyPointAllocs.get(currentPd.product.Id) : new List < Loyalty_Point_Allocation__c > ();
                Decimal points = 0;  Boolean proceed = true;
                for(Loyalty_Point_Allocation__c loyaltyPoint: loyaltyPointAllocations) {if(proceed && loyaltyPoint.ERP7__Price_Book__c == currentPd.priceBookEntry.PriceBook2Id) { for(Loyalty_Program_Allocation__c loyaltyProgram: loyaltyProgramAllocation) { if(proceed && loyaltyPoint.Loyalty_Program__c == loyaltyProgram.Loyalty_Programme__c && loyaltyProgram.Loyalty_Programme__r.Active__c == true && System.today() >= loyaltyProgram.Loyalty_Programme__r.Start_Date__c && System.today() <= loyaltyProgram.Loyalty_Programme__r.End_Date__c) { points = loyaltyPoint.Loyalty_Point_Per_Unit__c; Wrap.programId = loyaltyPoint.Loyalty_Program__c; proceed = false;
                            }
                        }
                    }
                }
                Wrap.pricebookId = currentPd.priceBookEntry.Id; if(Wrap.quantity_s != Null && points != Null) { Wrap.RewardPoints = (points * Wrap.quantity_s)
                        .setScale(2);
                }
                
                if(Wrap.quantity_s > 0) {  itemWrapperList.add(Wrap);
                }
            }
        }
        //}catch(exception e){}
        return itemWrapperList;
    }
    /*
        Subcribe order
    */
    public PageReference subscribe() {
        try {
            itemWrapperList = getCurrentWrapperList();
            if (subscription.Subscription_Date__c == Null || plan == Null || plan == '--None--' || billAddressName == Null || billAddressName == '' || shipAddressName == Null || shipAddressName == '') { errorMsg = 'Please enter all the * required fields'; return Null;
            } else if (!(itemWrapperList.size() > 0)) { errorMsg = 'Please add product line items'; return Null;
            } else {
                currentSalesOrder = new Sales_Order__c();
                if (currentSalesOrder.Account__c == Null) {
                    currentSalesOrder.Account__c = Contact[0].AccountId;
                }
                currentSalesOrder.Contact__c = Contact[0].Id;
                if (Schema.sobjectType.Contact.fields.Email.isAccessible()) currentSalesOrder.Customer_Email__c = Contact[0].Email;
                if (currentEmployees.size() > 0 && currentSalesOrder.Employees__c == Null) {
                    if (Schema.sobjectType.ERP7__Employees__c.isAccessible()) currentSalesOrder.Employees__c = currentEmployees[0].Id;
                    if (Schema.sobjectType.ERP7__Employees__c.fields.ERP7__Email__c.isAccessible()) currentSalesOrder.Employee_Email__c = currentEmployees[0].Email__c;
                }
                DMLManager.upsertAsUser(currentSalesOrder);
                Sales_Order__c salesOrderDraft;
                if (Schema.sObjectType.Sales_Order__c.isAccessible()) salesOrderDraft = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.Email, Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Employees__c, Employees__r.Email__c, Customer_Email__c, Employee_Email__c, Loyalty_Points__c, Loyalty_Amount__c From Sales_Order__c Where Id = : currentSalesOrder.id Limit 1];
                Date cardDate = system.today();
                List < Loyalty_Card__c > clubCard;
                if (Schema.sObjectType.Loyalty_Card__c.isAccessible()) clubCard = [Select id, Name, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c, Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c From Loyalty_Card__c Where Customer__c = : Contact[0].AccountId And Contact__c = : Contact[0].Id And Status__c = 'Active'
                    And Start_date__c <= : cardDate And Expiration_Date__c >= : cardDate 
                ];
                List < Sales_Order_Line_Item__c > salesOrderLineItem = new List < Sales_Order_Line_Item__c > ();
                List < Loyalty_Points__c > rewards = new List < Loyalty_Points__c > ();
                for (itemWrapper item: itemWrapperList) {
                    if (item.orderLineItemId == '') {
                        Sales_Order_Line_Item__c lineItem = new Sales_Order_Line_Item__c();
                        if (clubCard.size() > 0) {
                            boolean proceed = true;
                            for (Loyalty_Card__c lc: clubCard) {
                                if (String.valueof(lc.Loyalty_Program__c) == item.programId && proceed == true) { proceed = false; if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Loyalty_Points__c.isAccessible()) lineItem.Loyalty_Points__c = item.RewardPoints;
                                }
                            }
                        }
                        if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Base_Price__c.isAccessible()) lineItem.Base_Price__c = item.price;
                        if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Commission__c.isAccessible()) lineItem.Commission__c = item.commission;
                        if (item.ratecardId != '') { if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Commission_Rate_Card__c.isAccessible()) lineItem.Commission_Rate_Card__c = item.ratecardId;
                        }
                        lineItem.Discount_Amount__c = item.discount;
                        if (item.discountId != Null && item.discountId != '' && item.discountId != '--None--') {
                            if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Discount_Plan__c.isAccessible()) lineItem.Discount_Plan__c = item.discountId;
                        }
                        if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) lineItem.Product__c = item.itmId;
                        if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Quantity__c.isAccessible()) lineItem.Quantity__c = item.quantity_s;
                        if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) lineItem.Sales_Order__c = salesOrderDraft.id;
                        if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Total_Price__c.isAccessible()) lineItem.Total_Price__c = item.priceWithVat;
                        if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.VAT_Amount__c.isAccessible()) lineItem.VAT_Amount__c = item.vat;
                        lineItem.Other_Tax__c = item.tax;
                        if (item.programId != null && item.programId != '') {if (Schema.sobjectType.Sales_Order_Line_Item__c.fields.Loyalty_Program__c.isAccessible()) lineItem.Loyalty_Program__c = item.programId;
                        }
                        salesOrderLineItem.add(lineItem);
                    }
                }
                if (salesOrderLineItem.size() > 0) {
                    DMLManager.upsertAsUser(salesOrderLineItem);
                }
                if (subscription.Subscription_Date__c != Null && subscription.Subscription_Date__c == System.Today()) {
                    subscription.Next_Order_On__c = System.Today() + 1;} else { subscription.Next_Order_On__c = subscription.Subscription_Date__c;
                }
                if (Schema.sObjectType.Subscription__c.fields.SubscriptionPlan__c.isAccessible()) subscription.SubscriptionPlan__c = Plan;
                if (Schema.sObjectType.Subscription__c.fields.Active__c.isAccessible()) subscription.Active__c = true;
                if (Schema.sObjectType.Subscription__c.fields.Duration_In_Months__c.isAccessible()) subscription.Duration_In_Months__c = Decimal.valueof(currentDuration);
                if (Schema.sObjectType.Sales_Order__c.isAccessible()) subscription.Sales_Order__c = currentSalesOrder.Id;
                if (Schema.sObjectType.Subscription__c.fields.Status__c.isAccessible()) subscription.Status__c = 'Active';
                Date subStartDate;
                if (Schema.sObjectType.Subscription__c.fields.Subscription_Date__c.isAccessible()) subStartDate = subscription.Subscription_Date__c;
                if (Schema.sObjectType.Subscription__c.fields.Subscription_End_Date__c.isAccessible()) subscription.Subscription_End_Date__c = subStartDate.addMonths(Integer.valueof(currentDuration));
                DMLManager.upsertAsUser(subscription);
                if (Schema.sObjectType.Subscription__c.isAccessible()) salesOrderDraft.Subscription__c = subscription.Id;
                if (Schema.sObjectType.Sales_Order__c.fields.Amount__c.isAccessible()) salesOrderDraft.Amount__c = totalDue;
                if (Schema.sObjectType.Subscription__c.fields.Bill_To_Address__c.isAccessible()) salesOrderDraft.Bill_To_Address__c = billId.get(pageSubscription.Bill_To_Address__c);
                if (Schema.sObjectType.Subscription__c.fields.Ship_To_Address__c.isAccessible()) salesOrderDraft.Ship_To_Address__c = shipId.get(pageSubscription.Ship_To_Address__c);
                if (Schema.sObjectType.Sales_Order__c.fields.Order_Status__c.isAccessible()) salesOrderDraft.Order_Status__c = 'Subscribed';
                DMLManager.updateAsUser(salesOrderDraft);
                
                PageReference Page = new PageReference(comAppend + '/show_subscription'); Page.getParameters().put('cust', customers); Page.getParameters().put('profile', profile);Page.getParameters().put('oid', salesOrderDraft.Id); Page.getParameters().put('sid', subscription.Id);  Page.setRedirect(true);
                return Page; 
            } 
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber()));
           // return null; 
                }
        return null;
    }
    /*
        Get Plans for a particular order profile
    */
    public List < SelectOption > getSubPlans() {
        try {
            List < SelectOption > options = new List < SelectOption > ();
            options.add(new SelectOption('--None--', '--None--'));
            for (Subscription_Plan__c subPlan: subscriptionPlans) {
                options.add(new SelectOption(subPlan.Id, subPlan.Name + ' Every :' + subPlan.Number_of_Days__c + ' Day(s)'));
            }
            return options;} catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber())); } return null;
    }
    /*
        Get Durations for a particular Plan
    */
    public List < SelectOption > getSubDuration() {
        try {
            List < Subscription_Plan__c > subPlans;
            if (Schema.sObjectType.Subscription_Plan__c.isAccessible()) subPlans = [Select Id, Name, Active__c, Description__c, Duration_in_Months__c, Number_of_Days__c, Subscription_Plan__c
                From Subscription_Plan__c
                Where Id = : currentSubscriptionPlan Limit 1
            ];
            List < SelectOption > options = new List < SelectOption > ();
            for (Subscription_Plan__c subPlan: subPlans) {
                String duration = subPlan.Duration_in_Months__c;
                List < String > durations = duration.split(';');
                for (String s: durations) {
                    options.add(new SelectOption(s, s));
                }
            }
            return options; } catch (Exception e) {  ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber())); return null;}
    }
    /*
        Get Billing Address of a Particular Customer
    */
    public List < SelectOption > getmyBillingAddress() {
        try {
            billId = new Map < String, String > ();
            List < SelectOption > options = new List < SelectOption > ();
            
            for (Address__c addr: billingAddresses) {
                if (addr.Address_Line1__c != Null && addr.Address_Line2__c != Null && addr.Address_Line3__c != Null && addr.Postal_Code__c != Null) {
                    options.add(new SelectOption(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.Address_Line3__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Postal_Code__c));
                    billId.put(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.Address_Line3__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Id);
                } else if (addr.Address_Line1__c != Null && addr.Address_Line2__c != Null && addr.Postal_Code__c != Null) { options.add(new SelectOption(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Postal_Code__c)); billId.put(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Id);
                } else if (addr.Address_Line1__c != Null && addr.Postal_Code__c != Null) {
                    options.add(new SelectOption(addr.Address_Line1__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Postal_Code__c));
                    billId.put(addr.Address_Line1__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Id);
                }
            }
            
            return options;} catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber())); return null;}
    }
    /*
        Get Shipping Address of a Particular Customer
    */
    public List < SelectOption > getmyShippingAddress() {
        try {
            shipId = new Map < String, String > ();
            List < SelectOption > options = new List < SelectOption > ();
            for (Address__c addr: shippingAddresses) {
                if (addr.Address_Line1__c != Null && addr.Address_Line2__c != Null && addr.Address_Line3__c != Null && addr.Postal_Code__c != Null) {
                    options.add(new SelectOption(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.Address_Line3__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Postal_Code__c));
                    shipId.put(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.Address_Line3__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Id);
                } else if (addr.Address_Line1__c != Null && addr.Address_Line2__c != Null && addr.Postal_Code__c != Null) { options.add(new SelectOption(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Postal_Code__c)); shipId.put(addr.Address_Line1__c + ', ' + addr.Address_Line2__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Id);
                } else if (addr.Address_Line1__c != Null && addr.Postal_Code__c != Null) {
                    options.add(new SelectOption(addr.Address_Line1__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Postal_Code__c));
                    shipId.put(addr.Address_Line1__c + ', ' + addr.City__c + ', ' + addr.State__c + ', ' + addr.Postal_Code__c + ', ' + addr.Country__c, addr.Id);
                }
            }
            
            return options;} catch (Exception e) {ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage() + 'Line Number @ : ' + e.getLineNumber()));return null;
        }
    }
}