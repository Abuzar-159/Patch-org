/*
 * Changes made by : Syed Moin Pasha
 * Date : 19th July 2022
 * Reason : To manage the order currency based of the order profile(NWP) current code was displaying only the order
 *          profile based on the customer profile assigned on the customer account
 * Code Change : added the line item(612-617) to display all the order profile apart from the customer profile assigned 
 *               to the customer
*/

/*  Removed the with sharing part from here because the payment gatway was not showing to non admin user, Suggested by Imran*/
/* global With Sharing Class POSLightning {  */ 
    
global Without Sharing Class POSLightning {   

    
    // For DHL
    @AuraEnabled public static String DhlAccountNumber              { get; set; } 
    @AuraEnabled public static String DhlUserName                   { get; set; }
    @AuraEnabled public static String DhlPassword                   { get; set; }        

    // For FedEx     
    @AuraEnabled public static String resStatus                     { get; set; }
    @AuraEnabled public static String request_1                     { get; set; } 
    @AuraEnabled public static String response_1                    { get; set; }
    @AuraEnabled public static String Key                           { get; set; }
    @AuraEnabled public static String password                      { get; set; }        
    
    @AuraEnabled public static String SON                           { get; Set; }
    @AuraEnabled public static String CON                           { get; Set; }
    @AuraEnabled public static String CUST                          { get; Set; }
    @AuraEnabled public static List<itemWrapper> IWL                { get; Set; }
    
    @AuraEnabled
    public static comWrap getAll(String sony, String cony, String custy) {
        comWrap comW = new comWrap();
        return comW; 
    }
    
    @AuraEnabled
    public static string DeleteCreditNote(String CreditNoteId){
        try{
        if(string.isNotBlank(CreditNoteId)){
            ERP7__Credit_Note__c  creditNote = [SELECT Id,ERP7__Coupon_Redemption__c  FROM ERP7__Credit_Note__c  WHERE Id=:CreditNoteId];
           if(creditNote.ERP7__Coupon_Redemption__c != null && ERP7__Coupon_Redemption__c.sObjectType.getDescribe().isDeletable()){
                delete new ERP7__Coupon_Redemption__c (Id=creditNote.ERP7__Coupon_Redemption__c);
            }
            if(creditNote.Id != null && ERP7__Payment__c.sObjectType.getDescribe().isDeletable()){
                delete [Select Id FROM ERP7__Payment__c Where ERP7__Credit_Note__c =: creditNote.Id ];
            }
            if(ERP7__Credit_Note__c.sObjectType.getDescribe().isDeletable()) delete creditNote;
        }
        return '';
        }catch(QueryException qe){  return '';   }    
        catch(Exception e){  return e.getMessage();  }
    }
   
    //Moin added this 04th March 2024 to get gateway list
    @AuraEnabled
    public static List<String> getPaymentGateways(){
        List<String> gateways = new List<String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get('ERP7__Payment__c');
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Schema.DescribeFieldResult objFieldInfo = objDescribe.fields.getMap().get('ERP7__Payment_Gateway__c').getDescribe();
            List<Schema.PicklistEntry> picklistvalues = objFieldInfo.getPicklistValues();
            for(Schema.PicklistEntry plv: picklistvalues) {
                gateways.add(plv.getValue());
            }
        return gateways;//JSON.serialize(ERP7__Payment__c.SObjectType.getDescribe().fields.getMap().get('ERP7__Payment_Gateway__c'));
          
    }
    
    @AuraEnabled
    public static comWrap getAll2(String sony, String cony, String custy, String accf, String conf) {
        comWrap comW = new comWrap();
        son = sony;
        cust = custy;
        con = cony;
        system.debug('son - '+son +'cust - '+cust+'con - '+con);
        String exceptionError;
        Date todayDate = system.today();
        try {
            List<RecentlyViewed> recRecords = [SELECT Id, Name, Type
                                               FROM RecentlyViewed 
                                               WHERE Type IN ('Account', 'Contact', 'ERP7__Sales_Order__c')
                                               ORDER BY LastViewedDate DESC limit 5];
            Id ikId = null;
            
            //String SalesOrderFields = UtilClass.selectStarFromSObject('Sales_Order__c');
            String SalesOrderFields = 'id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__Issue_Invoice__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c, erp7__Coupon_Discount__c, erp7__Product_Coupon_Discount__c, erp7__Project__c, ERP7__Order_Discount_Description__c, ERP7__Order_Discount__c';
            String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c,ERP7__Employees__r.Name ';
            String paymentFields = UtilClass.selectStarFromSObject('ERP7__Payment__c');
            String AllPaymentFields = paymentFields + ',RecordType.Name,ERP7__Sales_Order__r.Name,ERP7__Payment_Method__r.Name '; 
            String creditNoteFields = UtilClass.selectStarFromSObject('ERP7__Credit_Note__c');
            String AllcreditNoteFields = creditNoteFields + ',ERP7__Sales_Order__r.Name, ERP7__Coupon_Redemption__r.Name, ERP7__Coupon_Redemption__r.ERP7__Coupon__c, ERP7__Coupon_Redemption__r.ERP7__Coupon__r.Name '; 
            String shipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c');
            String AllshipmentFields = shipmentFields + ',RecordType.Name,ERP7__Sales_Order__r.Name '; 
            
            //ERP7__Sales_Order__c SO = new ERP7__Sales_Order__c(ERP7__Request_Date__c=system.today(), ERP7__Expected_Date__c = system.today(),ERP7__Purchase_Order_Number__c="",ERP7__Special_Instructions__c=""); 
            ERP7__Sales_Order__c SO = (ikId != null)? Database.query('SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + 'FROM ERP7__Sales_Order__c where Id =: ikId Limit 1') : new ERP7__Sales_Order__c(ERP7__Request_Date__c=system.today(), ERP7__Expected_Date__c = system.today(),ERP7__Purchase_Order_Number__c='',ERP7__Special_Instructions__c='');
            
            ERP7__Payment__c Pay = new ERP7__Payment__c();
            Account Customer = new Account();
            Contact Contact = new Contact();
            String ContactFields = UtilClass.selectStarFromSObject('Contact');
            String AllContactFields = ContactFields + '';
            List < Employees__c > currentEmployees = new List < Employees__c > ();
            ERP7__Channel__c currentSalepoint = new ERP7__Channel__c();
            List < Distribution_Channel__c > DistributionChannels = new List < Distribution_Channel__c > ();
            List < Profiling__c > sopas = new List < Profiling__c > ();
            String salePointId = '';
            Id id = null;
            List < Address__c > billingAddresses = new List < Address__c > ();
            List < Address__c > shippingAddresses = new List < Address__c > ();
            ERP7__Invoice__c invoice = new ERP7__Invoice__c();
            ERP7__Subscription__c pageSubscription = new ERP7__Subscription__c();
            
            currentEmployees = [Select Id, Name, First_Name__c, Channel__c, Last_Name__c, Employee_User__c, Email__c, Employee_Profiling__c, Organisation__c,
                                Organisation_Business_Unit__c
                                From Employees__c
                                Where Employee_User__c = : UserInfo.getUserId()
                                Order by CreatedDate Asc Limit 1];
            salePointId = currentEmployees[0].Channel__c;
            SO.ERP7__Employees__c = currentEmployees[0].Id;
            
            if(Schema.sObjectType.Channel__c.isAccessible()) {
                currentSalepoint = [Select Id, Name, Organisation__c, Organisation_Business_Unit__c From ERP7__Channel__c where Id = : salePointId Limit 1];
            }
            if(Schema.sObjectType.Distribution_Channel__c.isAccessible()) {
                DistributionChannels = [Select Id, Name, Active__c,  Channel__c, Site__c
                                        From Distribution_Channel__c
                                        Where 
                                        Channel__c = : salePointId And Active__c = true];
            }
            Date myDate = system.today();
            List < Id > siteIds = new List < Id > ();
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
            
            comW.prodFam.add(new SelectOptions('--None--', ''));
            comW.prodCat.add(new SelectOptions('--None--', ''));
            comW.prodSubCat.add(new SelectOptions('--None--', ''));
            comW.shipmentType.add(new SelectOptions('--None--', ''));
            
            Schema.DescribeFieldResult fieldResult1 = product2.Family.getDescribe();
            List < Schema.PicklistEntry > ple1 = fieldResult1.getPicklistValues();
            for(Schema.PicklistEntry f: ple1) {
                comW.prodFam.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCat = product2.ERP7__Category__c.getDescribe();
            List < Schema.PicklistEntry > Cat = fieldResultCat.getPicklistValues();
            for(Schema.PicklistEntry f: Cat) {
                comW.prodCat.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultSubCat = product2.ERP7__Sub_Category__c.getDescribe();
            List < Schema.PicklistEntry > SubCat = fieldResultSubCat.getPicklistValues();
            for(Schema.PicklistEntry f: SubCat) {
                comW.prodSubCat.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            comW.recentRecords = recRecords;
            List < itemWrapper > itemWrapperList = new List < itemWrapper > ();
            List<ERP7__Payment__c> SO_Payments = new List<ERP7__Payment__c>();
            List< ERP7__Credit_Note__c > creditNotes = new List< ERP7__Credit_Note__c >();
            List< ERP7__Shipment__c > Shipments = new List< ERP7__Shipment__c >();
            comW.currentSalepoint = currentSalepoint;
            comW.currentEmployee = currentEmployees[0];
            comW.Payment = Pay;
            comW.subTotal = 0;
            comW.totalDiscount = 0;
            comW.totalDue = 0;
            comW.totalTax = 0;
            comW.finalDue = 0;
            comW.loyaltyAmount = 0;
            comW.loyalty_Points = 0;
            comW.CardError = '';
            Schema.DescribeFieldResult fieldResult = Sales_Order__c.Status__c.getDescribe();
            List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
            for(Schema.PicklistEntry f: ple) {
                comW.orderStatus.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            
            comW.CountyList.add(new SelectOptions('--None--', ''));
            Schema.DescribeFieldResult fieldResultCnty = ERP7__Address__c.ERP7__State__c.getDescribe();
            List < Schema.PicklistEntry > cnty = fieldResultCnty.getPicklistValues();
            for(Schema.PicklistEntry f: cnty) {
                comW.CountyList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCntry = ERP7__Address__c.ERP7__Country__c.getDescribe();
            List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
            for(Schema.PicklistEntry f: cntry) {
                comW.CountryList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCardtype= ERP7__Payment_Method__c.ERP7__CardType__c.getDescribe();
            List < Schema.PicklistEntry > cardtype = fieldResultCardtype.getPicklistValues();
            for(Schema.PicklistEntry f: cardtype) {
                comW.CardTypes.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            
            Schema.DescribeFieldResult fieldResultShipmentType = ERP7__Sales_Order__c.ERP7__Shipment_Type__c.getDescribe();
            List < Schema.PicklistEntry > shipmentTyp = fieldResultShipmentType.getPicklistValues();
            for(Schema.PicklistEntry f: shipmentTyp) {
                comW.shipmentType.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            
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
            for(integer i=1;i<10;i++){
                comW.ExpiryYear.add(new SelectOptions(curMonth + '',curMonth++ + ''));
            }
            
           //if(Schema.sObjectType.Credentials__c.isAccessible()) {  
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize' or Name = 'Stripe') ]){
                                                  comW.payType.add(new SelectOptions(crd.Name, crd.Name));
                                              }
         //   }             
            
            
            /*comW.payType.add(new SelectOptions('Authorize.net', 'Authorize.net'));
comW.payType.add(new SelectOptions('Paypal', 'Paypal'));
comW.payType.add(new SelectOptions('Stripe', 'Stripe'));*/
            
            if(son != Null && son != '') {
                system.debug('inhere son~>'+son);
                if(Schema.sObjectType.Sales_Order__c.isAccessible()) {
                    SO = Database.query('SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + 'FROM ERP7__Sales_Order__c where Name=:son or Id=:son Limit 1'); //verify escape sequence
                    CON = SO.Contact__c;
                    CUST = SO.Account__c;
                }
                if(SO.erp7__bill_to_address__c != null) {
                    comW.BillAddresses = [select ERP7__Address_Line1__c, ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Country__c, ERP7__State__c, ERP7__Postal_Code__c from ERP7__Address__c where Id=:SO.ERP7__Bill_To_Address__c];
                }
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    //if(Customer.ERP7__Is_Person_Account__c == true)
                    //Customer = Database.query('SELECT Id, FirstName, LastName, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    comw.accTaxRate = (Customer != null && customer.ERP7__Vat__c != null)?customer.ERP7__Vat__r.ERP7__Total_Tax__c : 0.00;
                    //Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c,Vat__r.Total_Tax__c, ERP7__VAT__r.Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    //Customer = [SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c,Vat__r.Total_Tax__c, ERP7__VAT__r.Tax_Rate__c FROM Account WHERE Id = : CUST Limit 1];
                    
                }
                
                
                
                
                if(String.isNOTEmpty(CON) &&  Schema.sObjectType.Contact.isAccessible() ) {
                    //Contact = Database.query('SELECT '+String.escapeSingleQuotes(ContactFields)+' FROM Contact WHERE Id = :CON Limit 1');
                    Contact = [SELECT Id, Name, Title, Email, Phone, ERP7__Contact_Numer__c FROM Contact WHERE Id = : CON Limit 1];
                }
                
                
                
                String AccProfile = Customer.ERP7__Account_Profile__c;
                String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
                /*String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where ERP7__Account_Profile__c = :AccProfile and ERP7__Active__c = true order by ERP7__Default__c DESC';
ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
if(Schema.sObjectType.Profiling__c.isAccessible()) sopas = Database.query(queryProfiling);



if(sopas.size() > 0 && !sopas[0].ERP7__Default__c) comW.SOPS.add(new SelectOptions('--None--', ''));
for(ERP7__Profiling__c SOPA: sopas) {
comW.SOPS.add(new SelectOptions(SOPA.Name, sopa.Id));
}*/
                
                if(Schema.sObjectType.Invoice__c.isAccessible()) {
                    invoice = new ERP7__Invoice__c();
                    List<ERP7__Invoice__c> invoices = [Select Id, Name, Organisation__c, Organisation__r.Id, Organisation_Business_Unit__c, Order__c From ERP7__Invoice__c Where Order__c = : SO.id Order by createdDate DESC Limit 1]; //AND ERP7__Total_Due__c > 0.0
                    if(invoices.size() > 0) invoice = invoices[0];
                    
                }
                String SalesOrderSoql = 'SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + ' FROM Sales_Order__c where Name=:son or Id=:son Limit 1'; // hande escape
                Sales_Order__c currentSalesOrder = Database.query(SalesOrderSoql);
                String ordProfileId=currentSalesOrder.ERP7__Order_Profile__c;
                
                String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id =:ordProfileId and ERP7__Active__c = true order by ERP7__Default__c DESC';
                ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
                if(Schema.sObjectType.Profiling__c.isAccessible()) sopas = Database.query(queryProfiling);
                
                if(sopas.size() > 0 && !sopas[0].ERP7__Default__c) comW.SOPS.add(new SelectOptions('--None--', ''));
                for(ERP7__Profiling__c SOPA: sopas) {
                    comW.SOPS.add(new SelectOptions(SOPA.Name, sopa.Id));
                }
                
                
                
                
                Address__c saddr;
                if(currentSalesOrder.Ship_To_Address__c != Null) {
                    
                    if(Schema.sObjectType.Address__c.isAccessible()) {
                        saddr = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                 Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,Tax__c,Tax__r.Total_Tax__c
                                 From Address__c Where id = : currentSalesOrder.Ship_To_Address__c Limit 1];
                    }
                    comW.TaxRate = (saddr != null && saddr.Tax__c != null)? saddr.Tax__r.Total_Tax__c:0.00; 
                    pageSubscription.Ship_To_Address__c = '';
                    if(saddr.Address_Line1__c != Null) pageSubscription.Ship_To_Address__c += saddr.Address_Line1__c+', ';
                    if(saddr.Address_Line2__c != Null) pageSubscription.Ship_To_Address__c += saddr.Address_Line2__c+', ';
                    if(saddr.Address_Line3__c != Null) pageSubscription.Ship_To_Address__c += saddr.Address_Line3__c+', ';
                    if(saddr.city__c != Null) pageSubscription.Ship_To_Address__c += saddr.city__c+', ';
                    if(saddr.State__c != Null) pageSubscription.Ship_To_Address__c += saddr.State__c+', ';
                    if(saddr.Postal_Code__c != Null) pageSubscription.Ship_To_Address__c += saddr.Postal_Code__c+', ';
                    if(saddr.Country__c != Null) pageSubscription.Ship_To_Address__c += saddr.Country__c;
                    comW.sAdd.add(new SelectOptions(saddr.Postal_Code__c+', '+saddr.Address_Line1__c, saddr.Id,true));
                }
                Address__c baddr;
                if(currentSalesOrder.Bill_To_Address__c != Null) {
                    
                    if(Schema.sObjectType.Address__c.isAccessible()) {
                        baddr = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                 Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,Tax__c,Tax__r.Total_Tax__c
                                 From Address__c Where id = : currentSalesOrder.Bill_To_Address__c Limit 1];
                    }
                    comW.TaxRate = (comW.TaxRate ==0.00 && baddr != null && baddr.Tax__c != null)? baddr.Tax__r.Total_Tax__c:comW.TaxRate; 
                    pageSubscription.Bill_To_Address__c = '';
                    if(baddr.Address_Line1__c != Null) pageSubscription.Bill_To_Address__c += baddr.Address_Line1__c+', ';
                    if(baddr.Address_Line2__c != Null) pageSubscription.Bill_To_Address__c += baddr.Address_Line2__c+', ';
                    if(baddr.Address_Line3__c != Null) pageSubscription.Bill_To_Address__c += baddr.Address_Line3__c+', ';
                    if(baddr.city__c != Null) pageSubscription.Bill_To_Address__c += baddr.city__c+', ';
                    if(baddr.State__c != Null) pageSubscription.Bill_To_Address__c += baddr.State__c+', ';
                    if(baddr.Postal_Code__c != Null) pageSubscription.Bill_To_Address__c += baddr.Postal_Code__c+', ';
                    if(baddr.Country__c != Null) pageSubscription.Bill_To_Address__c += baddr.Country__c;
                    comW.bAdd.add(new SelectOptions(baddr.Postal_Code__c+', '+baddr.Address_Line1__c, baddr.Id,true));
                }
                List < Address__c > billingPrimaryAddress;
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    billingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                             Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                             Organisation__c, Organisation_Business_Unit__c,Tax__c,Tax__r.Total_tax__c
                                             From Address__c
                                             Where Customer__c = : Customer.Id and Active__c = true and Is_Billing_Address__c = true
                                             order by Primary__c DESC, CreatedDate ASC limit 1];
                }
                List < Address__c > shippingPrimaryAddress;
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    shippingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                              Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                              Organisation__c, Organisation_Business_Unit__c,Tax__c,Tax__r.Total_tax__c
                                              From Address__c
                                              Where Customer__c = : Customer.Id and Active__c = true and Is_Shipping_Address__c = true
                                              order by Primary__c DESC, CreatedDate ASC limit 1];
                }
                
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    billingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                        Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,Tax__c,Tax__r.Total_tax__c,
                                        Organisation__c, Organisation_Business_Unit__c
                                        From Address__c
                                        Where Customer__c = : Customer.Id And Active__c = true And Is_Billing_Address__c = true
                                        order by Primary__c DESC, CreatedDate ASC];
                }
                if(saddr == null && shippingPrimaryAddress.size() > 0) {
                    pageSubscription.Ship_To_Address__c = '';
                    comw.TaxRate = (shippingPrimaryAddress[0].Tax__c != null)?shippingPrimaryAddress[0].Tax__r.Total_tax__c:0.00;
                    if(shippingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line1__c+', ';
                    if(shippingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line2__c+', ';
                    if(shippingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line3__c+', ';
                    if(shippingPrimaryAddress[0].city__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].city__c+', ';
                    if(shippingPrimaryAddress[0].State__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].State__c+', ';
                    if(shippingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Postal_Code__c+', ';
                    if(shippingPrimaryAddress[0].Country__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Country__c;
                    
                }
                if(baddr==null && billingPrimaryAddress.size() > 0) {
                    pageSubscription.Bill_To_Address__c = '';
                    comw.TaxRate = (comw.TaxRate == 0.00 && billingPrimaryAddress[0].Tax__c != null)?billingPrimaryAddress[0].Tax__r.Total_tax__c:comw.TaxRate;
                    if(billingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line1__c+', ';
                    if(billingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line2__c+', ';
                    if(billingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line3__c+', ';
                    if(billingPrimaryAddress[0].city__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].city__c+', ';
                    if(billingPrimaryAddress[0].State__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].State__c+', ';
                    if(billingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Postal_Code__c+', ';
                    if(billingPrimaryAddress[0].Country__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Country__c;
                }
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    shippingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                         Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                         Organisation__c, Organisation_Business_Unit__c
                                         From Address__c
                                         Where Customer__c = : Customer.Id And Active__c = true And Is_Shipping_Address__c = true
                                         order by Primary__c DESC, CreatedDate ASC];
                }
                Boolean flag = true;
                if(billingAddresses.size()>0)
                    for(Address__c add: billingAddresses) {
                        if(baddr==null && billingPrimaryAddress.size()> 0 && billingPrimaryAddress[0].id==add.Id && flag){
                            comW.bAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id,true));
                            flag = false;
                        }else
                            comW.bAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id,false));
                    }
                flag = true;
                if(shippingAddresses.size()>0)
                    for(Address__c add: shippingAddresses) {
                        if(saddr == null && shippingPrimaryAddress.size()> 0 && shippingPrimaryAddress[0].id==add.Id && flag){
                            comW.sAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id,true));
                            flag = false;    
                        }else
                            comW.sAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id,false));
                    }
                
                SO_Payments = Database.query('SELECT ' + String.escapeSingleQuotes(AllPaymentFields) + 'FROM ERP7__Payment__c where (ERP7__Sales_Order__r.Name =:son or ERP7__Sales_Order__c =:son) and ERP7__Type__c = \'Debit\' order by CreatedDate Asc');
                creditNotes = Database.query('SELECT ' + String.escapeSingleQuotes(AllCreditNoteFields) + 'FROM ERP7__Credit_Note__c where (ERP7__Sales_Order__r.Name =:son or ERP7__Sales_Order__c =:son) and ERP7__Coupon_Redemption__c != null order by CreatedDate Asc');
                Shipments = Database.query('SELECT ' + String.escapeSingleQuotes(AllShipmentFields) + 'FROM ERP7__Shipment__c where ERP7__Sales_Order__r.Name =:son or ERP7__Sales_Order__c =:son order by CreatedDate Asc');
                comW.Order = SO;
                comW.isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
                if(comW.isMultiCurrency){ comW.orderCurrency  = (String)Database.query('SELECT CurrencyIsoCode FROM ERP7__Sales_Order__c where Name=:son or Id=:son Limit 1')[0].get('CurrencyIsoCode');
                                        }
                
                comW.SO_Payments = SO_Payments;
                comW.creditNotes = creditNotes;
                comW.Shipments = Shipments;
                comW.Customer = Customer;
                comW.Contact = Contact;
                comW.invoice = invoice;
                comW.billingAddresses = billingAddresses;
                comW.shippingAddresses = shippingAddresses;
                comW.sopas = sopas;
                comW.pageSubscription = pageSubscription;
                
                // Populate Line Items
                List < Sales_Order_Line_Item__c > orderLineItem;
                if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) {
                    orderLineItem = [Select Id, Name, Base_Price__c, Description__c, ERP7__Sort_Order__c, Detailed_Description__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c,
                                     VAT_Amount__c, Loyalty_Program__c, Checked_Out_Process__c, Order_Line_Status__c, Discount_Plan__r.ERP7__Default_Discount_Percentage__c, 
                                     product__c, product__r.Name, product__r.Description, product__r.ERP7__Is_Asset__c,product__r.StockKeepingUnit, product__r.SKU__c, Quantity__c, Sales_Order__c, Discount_Plan__c, Discount_Plan__r.ERP7__Default_Discount_Value__c, 
                                     Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c,
                                     Loyalty_Points__c, Organisation__c, Organisation_Business_Unit__c, Commission_Rate_Card__c, Commission__c, Other_Tax__c, Inventory_Tracked__c,
                                     ERP7__Start_Time__c, ERP7__End_Time__c, Version__c, ERP7__Coupon__c, ERP7__Cost__c
                                     From Sales_Order_Line_Item__c 
                                     Where Sales_Order__r.Name = : son or Sales_Order__c = : son];
                }
                Map < Id, product2 > prodMapp = new Map < Id, product2 > ();
                List < Id > pIds = new List < Id > ();
                for(Sales_Order_Line_Item__c sol: orderLineItem) {
                    if(sol.product__c != Null) pIds.add(sol.product__c);
                }
                String allFieldsPS = UtilClass.selectStarFromSObject('Product2');
                String queryPS = 'select ' + String.escapeSingleQuotes(allFieldsPS) + ' from Product2 where id In: pIds Limit 5000';
                for(product2 p: Database.query(queryPS)) prodMapp.put(p.Id, p);
                
                // Check for returns
                List < String > itemIds = new List < String > ();
                for(Sales_Order_Line_Item__c LI: orderLineItem) {
                    itemIds.add(LI.Id);
                }
                List < RMA_Line_Item__c > currentRmaItems = new List < RMA_Line_Item__c > ();
                if(itemIds.size() > 0) {
                    if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) {
                        currentRmaItems = [Select Id, Name, Base_Price__c, Organisation__c, Organisation_Business_Unit__c, Discount_Amount__c, Quantity_Available__c,
                                           Quantity_Return__c, Return_Merchandise_Authorisation__c, Return_Reason__c, SOLI__c, Total_Deduction__c From RMA_Line_Item__c Where SOLI__c In:
                                           itemIds];
                    }
                }
                List<Stock_Outward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, Batch_Lot_Code__c, BoM__c, Process__c, Schedule__c, MRP_Material_Requirements_Planning__c,
                                                           Product__c, Purchase_Orders__c, Site_Product_Service_Inventory_Stock__c, Status__c, Tax__c, Total_Amount__c, Unit_Price__c, ERP7__Sales_Order_Line_Item__c, ERP7__Material_Batch_Lot__c
                                                           From Stock_Outward_Line_Item__c 
                                                           Where ERP7__Sales_Order_Line_Item__c In: itemIds];
                List<Id> serialIds = new List<Id>();
                List<Id> batchIds = new List<Id>();
                for(Stock_Outward_Line_Item__c SDLI: SDLIs) {    if(SDLI.ERP7__Serial__c != null) serialIds.add(SDLI.ERP7__Serial__c);  if(SDLI.ERP7__Material_Batch_Lot__c != null) batchIds.add(SDLI.ERP7__Material_Batch_Lot__c);
                                                            }       
                Map<Id, ERP7__Serial_Number__c> SerialNumber = new Map<Id, ERP7__Serial_Number__c>();
                Map<Id, List<ERP7__Serial_Number__c>> SerialNumbers = new Map<Id, List<ERP7__Serial_Number__c>>();
                String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
                allFields += ' , ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Product__r.Name, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';
                String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :serialIds';
                List<ERP7__Serial_Number__c> SerialNos = Database.query(query);
                
                
                Map<Id, List<ERP7__Batch__c>> lineBatches = new Map<Id, List<ERP7__Batch__c>>();
                Map<Id, ERP7__Batch__c> BatchNumber = new Map<Id, ERP7__Batch__c>();
                String allFields1 = UtilClass.selectStarFromSObject('ERP7__Batch__c');
                allFields1 += ' , ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c ';
                String query1 = 'select ' + String.escapeSingleQuotes(allFields1) + ' from ERP7__Batch__c where Id In :batchIds';
                List<ERP7__Batch__c> Batches = Database.query(query1);
                
                for(ERP7__Serial_Number__c SL : SerialNos){  SerialNumber.put(SL.Id,SL);  }
                for(ERP7__Batch__c SL : Batches){   BatchNumber.put(SL.Id,SL);  }
                
                for(Sales_Order_Line_Item__c lineItem: orderLineItem) {
                    List<ERP7__Serial_Number__c> mySerials = new List<ERP7__Serial_Number__c>();
                    for(Stock_Outward_Line_Item__c SDLI: SDLIs) {if(lineItem.Id == SDLI.ERP7__Sales_Order_Line_Item__c && SDLI.ERP7__Serial__c != null) { mySerials.add(SerialNumber.get(SDLI.ERP7__Serial__c));
                                                                                                               }
                    }   
                    SerialNumbers.put(lineItem.Id,mySerials);
                    
                    List<ERP7__Batch__c> myBatches = new List<ERP7__Batch__c>();
                    for(Stock_Outward_Line_Item__c SDLI: SDLIs) { if(lineItem.Id == SDLI.ERP7__Sales_Order_Line_Item__c && SDLI.ERP7__Serial__c == null && SDLI.ERP7__Material_Batch_Lot__c != null) {  myBatches.add(BatchNumber.get(SDLI.ERP7__Material_Batch_Lot__c));
                                                                                                                                                           }
                    }   
                    lineBatches.put(lineItem.Id,myBatches);
                }
                for(Sales_Order_Line_Item__c lineItem: orderLineItem) {
                    itemWrapper item = new itemWrapper();
                    item.trackInventory = lineItem.Inventory_Tracked__c;
                    if(lineItem.Version__c != null) item.Version = lineItem.Version__c;
                    item.lineitm = lineItem;
                    item.couponDiscount = (lineItem.ERP7__Coupon__c != Null)? lineItem.ERP7__Coupon__c : 0;
                    if((lineItem.ERP7__Cost__c != Null)) item.costprice = lineItem.ERP7__Cost__c;
                    item.checkoutprocess = lineItem.Checked_Out_Process__c;
                    item.code = lineItem.product__r.SKU__c;
                    item.product = prodMapp.get(lineItem.product__c);
                    item.itm = lineItem.product__r.Name;
                    item.itmId = lineItem.product__c;
                    if(lineItem.Discount_Plan__c != Null) {   item.discountId = lineItem.Discount_Plan__c;  }
                    if(lineItem.ERP7__Start_Time__c != Null) item.StartTime = lineItem.ERP7__Start_Time__c;
                    if(lineItem.ERP7__End_Time__c != Null) item.EndTime = lineItem.ERP7__End_Time__c;
                    item.SerialNos = SerialNumbers.get(lineItem.Id);
                    item.Batches = lineBatches.get(lineItem.Id);
                    //item.pricebookId = lineItem.PriceBook_Entry__c;
                    item.programId = lineItem.Loyalty_Program__c;
                    if(lineItem.Commission_Rate_Card__c != Null) {item.ratecardId = lineItem.Commission_Rate_Card__c;
                                                                 }
                    if(lineItem.Commission__c != Null) {
                        item.commission = lineItem.Commission__c;
                    }
                    Decimal quant = 0;
                    Decimal totalDetuct = 0;
                    for(RMA_Line_Item__c RLI: currentRmaItems) {
                        if(RLI.SOLI__c == lineItem.Id) {
                            //quant += RLI.quantity_Return__c;
                            //totalDetuct = totalDetuct.setScale(2) + RLI.Total_Deduction__c;
                        }
                    }
                    //item.prod_Desc = lineItem.Description__c;
                    item.prod_Desc = lineItem.Detailed_Description__c;
                    if(lineItem.quantity__c != null) item.quantity_s = lineItem.quantity__c - quant;
                    if(lineItem.quantity__c != null) item.rewardpoints = ((lineItem.Loyalty_Points__c) / (lineItem.quantity__c) * item.quantity_s)
                        .setScale(2);else item.rewardpoints = 0;
                    if(lineItem.quantity__c != null) item.price = ((lineItem.Base_Price__c / lineItem.quantity__c) * item.quantity_s)
                        .setScale(2);else item.price = 0;
                    if(lineItem.VAT_Amount__c != Null) {
                        if(lineItem.quantity__c != null) item.vat = ((lineItem.VAT_Amount__c / lineItem.quantity__c) * item.quantity_s)
                            .setScale(2); else item.vat = 0;} else item.vat = 0;
                    if(lineItem.Other_Tax__c != Null) {
                        if(lineItem.quantity__c != null) item.tax = ((lineItem.Other_Tax__c / lineItem.quantity__c) * item.quantity_s)
                            .setScale(2);else item.tax = 0;} else item.tax = 0;
                    if(lineItem.Discount_Amount__c != Null) {
                        if(lineItem.quantity__c != null) item.discount = ((lineItem.Discount_Amount__c / lineItem.quantity__c) * item.quantity_s)
                            .setScale(2);else item.discount = 0;} else item.discount = 0;
                    if(lineItem.Total_Price__c != null) item.priceWithVat = (lineItem.Total_Price__c - totalDetuct)
                        .setScale(2); else item.priceWithVat = 0;
                    if(lineItem.Discount_Plan__r.ERP7__Default_Discount_Percentage__c != Null) item.discountPercent = (item.price > 0)? ((item.discount / item.price) * 100).setScale(2) : (0.00).setScale(2);
                    else if(lineItem.Discount_Plan__r.ERP7__Default_Discount_Value__c != Null) item.discountPercent = (item.price > 0)? ((item.discount / lineItem.quantity__c)).setScale(2) : (0.00).setScale(2);
                    item.orderLineItemId = lineItem.Id;
                    if(item.quantity_s > 0) {
                        itemWrapperList.add(item);
                    }
                }
                
                for(itemWrapper iwrap: itemWrapperList) {
                    if(iwrap.price != null) comW.subTotal += iwrap.price;
                    if(iwrap.discount != null) comW.totalDiscount += iwrap.discount;
                    if(iwrap.priceWithVat != null) comW.totalDue += iwrap.priceWithVat;
                    if(iwrap.vat != null && iwrap.tax != null) comW.totalTax += (iwrap.vat + iwrap.tax);
                }
                if(currentSalesOrder.Loyalty_Amount__c != Null && currentSalesOrder.Loyalty_Points__c != Null) {
                    //comW.finalDue = comW.totalDue - currentSalesOrder.Loyalty_Amount__c - currentSalesOrder.Amount_Paid__c;
                    comW.finalDue = (currentSalesOrder.Amount_Paid__c != Null)? (comW.totalDue - currentSalesOrder.Amount_Paid__c).setScale(2) : (comW.totalDue).setScale(2);
                    if(currentSalesOrder.ERP7__Total_Shipping_Amount__c != Null) comW.finalDue = (comW.finalDue + currentSalesOrder.ERP7__Total_Shipping_Amount__c).setScale(2);
                    comW.loyalty_Points = currentSalesOrder.Loyalty_Points__c;
                    comW.loyaltyAmount = currentSalesOrder.Loyalty_Amount__c;
                } else {comW.finalDue = comW.totalDue - currentSalesOrder.Amount_Paid__c;
                        if(currentSalesOrder.ERP7__Total_Shipping_Amount__c != Null) comW.finalDue = (comW.finalDue + currentSalesOrder.ERP7__Total_Shipping_Amount__c).setScale(2);
                        comW.loyalty_Points = 0.00;comW.loyaltyAmount = 0.00;
                       }
                
                if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                    List<Loyalty_Card__c> clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, ERP7__Points_Per_Unit_Amount__c, Contact__c, Customer__c, Start_date__c,
                                                      Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                                                      Organisation__c, Organisation_Business_Unit__c
                                                      From Loyalty_Card__c Where
                                                      Customer__c = : Customer.Id And
                                                      Customer__c != Null And
                                                      Active__c = true And
                                                      Status__c = 'Active'
                                                      And
                                                      Start_date__c <= : todayDate And
                                                      Expiration_Date__c >= : todayDate And
                                                      Organisation__c = : currentSalepoint.Organisation__c //And
                                                      // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                                                      Limit 1];
                    if(clubCard.size() > 0){  comW.Points_Per_Unit_Amount = (clubCard[0].Active_Points__c/clubCard[0].ERP7__Points_Per_Unit_Amount__c).setScale(2);  }
                }
                comW.finalDue = currentSalesOrder.ERP7__Due_Amount__c;     
                comW.itemWrapperListCom = itemWrapperList;
                IWL = itemWrapperList;
                
            }
            else if(con != '' && con != Null){
                system.debug('inhere con~>'+con);
                if(Schema.sObjectType.Contact.isAccessible()) {
                    //Contact = Database.query('SELECT '+String.escapeSingleQuotes(ContactFields)+' FROM Contact WHERE Id = :CON Limit 1');
                    Contact = [SELECT Id, Name, Title, Email, Phone, ERP7__Contact_Numer__c, AccountId FROM Contact WHERE Id = : CON Limit 1];
                    CON = Contact.Id;
                    CUST = Contact.AccountId;
                }
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    //if(Customer.ERP7__Is_Person_Account__c == true)
                    //Customer = Database.query('SELECT Id, FirstName, LastName, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    comw.accTaxRate = (Customer != null && customer.ERP7__Vat__c != null)?customer.ERP7__Vat__r.ERP7__Total_Tax__c : 0.00;
                    //Customer = Database.query('SELECT '+String.escapeSingleQuotes(AllAccountFields)+' FROM Account WHERE Id = :CUST Limit 1');
                    //Customer = [SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website, ERP7__Account_Profile__c,  ERP7__VAT__c,Vat__r.Total_Tax__c, ERP7__VAT__r.Tax_Rate__c FROM Account WHERE Id = : CUST Limit 1];
                    CUST = SO.Account__c;
                }
                
                String AccProfile = Customer.ERP7__Account_Profile__c;
                String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
                String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where ERP7__Account_Profile__c = :AccProfile and ERP7__Active__c = true order by ERP7__Default__c DESC';
                ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
                if(Schema.sObjectType.Profiling__c.isAccessible()) sopas = Database.query(queryProfiling);
                
                if(sopas.size() > 0 && !sopas[0].ERP7__Default__c) comW.SOPS.add(new SelectOptions('--None--', ''));
                for(ERP7__Profiling__c SOPA: sopas) {
                    comW.SOPS.add(new SelectOptions(SOPA.Name, sopa.Id));
                }
                
                //Moin Code 
                queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where ERP7__Account_Profile__c != :AccProfile and ERP7__Active__c = true order by ERP7__Default__c DESC';
                if(Schema.sObjectType.Profiling__c.isAccessible()) sopas = Database.query(queryProfiling);
                for(ERP7__Profiling__c SOPA: sopas) {
                    comW.SOPS.add(new SelectOptions(SOPA.Name, sopa.Id));
                }
                
                List < Address__c > billingPrimaryAddress;
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    billingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                             Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                             Organisation__c, Organisation_Business_Unit__c,Tax__c,Tax__r.Total_tax__c
                                             From Address__c
                                             Where Customer__c = : Customer.Id and Active__c = true and Is_Billing_Address__c = true
                                             order by Primary__c DESC, CreatedDate ASC limit 1];
                }
                List < Address__c > shippingPrimaryAddress;
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    shippingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                              Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                              Organisation__c, Organisation_Business_Unit__c,Tax__c,Tax__r.Total_tax__c
                                              From Address__c
                                              Where Customer__c = : Customer.Id and Active__c = true and Is_Shipping_Address__c = true
                                              order by Primary__c DESC, CreatedDate ASC limit 1];
                }
                if(shippingPrimaryAddress.size() > 0) {
                    /*if(shippingPrimaryAddress[0].Address_Line1__c != Null && shippingPrimaryAddress[0].Address_Line2__c != Null && shippingPrimaryAddress[0].Address_Line3__c != Null) {
pageSubscription.Ship_To_Address__c = shippingPrimaryAddress[0].Address_Line1__c + ', ' + shippingPrimaryAddress[0].Address_Line2__c + ', ' + shippingPrimaryAddress[0].Address_Line3__c + ', ' + shippingPrimaryAddress[0].City__c + ', ' + shippingPrimaryAddress[0].State__c + ', ' + shippingPrimaryAddress[0].Postal_Code__c + ', ' + shippingPrimaryAddress[0].Country__c;
} else if(shippingPrimaryAddress[0].Address_Line1__c != Null && shippingPrimaryAddress[0].Address_Line2__c != Null) {
pageSubscription.Ship_To_Address__c = shippingPrimaryAddress[0].Address_Line1__c + ', ' + shippingPrimaryAddress[0].Address_Line2__c + ', ' + shippingPrimaryAddress[0].City__c + ', ' + shippingPrimaryAddress[0].State__c + ', ' + shippingPrimaryAddress[0].Postal_Code__c + ', ' + shippingPrimaryAddress[0].Country__c;
} else if(shippingPrimaryAddress[0].Address_Line1__c != Null) {pageSubscription.Ship_To_Address__c = shippingPrimaryAddress[0].Address_Line1__c + ', ' + shippingPrimaryAddress[0].City__c + ', ' + shippingPrimaryAddress[0].State__c + ', ' + shippingPrimaryAddress[0].Postal_Code__c + ', ' + shippingPrimaryAddress[0].Country__c;
}*/
                    pageSubscription.Ship_To_Address__c = '';
                    comw.TaxRate = (shippingPrimaryAddress[0].Tax__c != null)?shippingPrimaryAddress[0].Tax__r.Total_tax__c:0.00;
                    if(shippingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line1__c+', ';
                    if(shippingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line2__c+', ';
                    if(shippingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line3__c+', ';
                    if(shippingPrimaryAddress[0].city__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].city__c+', ';
                    if(shippingPrimaryAddress[0].State__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].State__c+', ';
                    if(shippingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Postal_Code__c+', ';
                    if(shippingPrimaryAddress[0].Country__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Country__c;
                    
                }
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    shippingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                         Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                         Organisation__c, Organisation_Business_Unit__c
                                         From Address__c
                                         Where Customer__c = : Customer.Id And Active__c = true And Is_Shipping_Address__c = true
                                         order by Primary__c DESC, CreatedDate ASC];
                }
                if(billingPrimaryAddress.size() > 0) {
                    /*if(billingPrimaryAddress[0].Address_Line1__c != Null && billingPrimaryAddress[0].Address_Line2__c != Null && billingPrimaryAddress[0].Address_Line3__c != Null) {
pageSubscription.Bill_To_Address__c = billingPrimaryAddress[0].Address_Line1__c + ', ' + billingPrimaryAddress[0].Address_Line2__c + ', ' + billingPrimaryAddress[0].Address_Line3__c + ', ' + billingPrimaryAddress[0].City__c + ', ' + billingPrimaryAddress[0].State__c + ', ' + billingPrimaryAddress[0].Postal_Code__c + ', ' + billingPrimaryAddress[0].Country__c;
} else if(billingPrimaryAddress[0].Address_Line1__c != Null && billingPrimaryAddress[0].Address_Line2__c != Null) {
pageSubscription.Bill_To_Address__c = billingPrimaryAddress[0].Address_Line1__c + ', ' + billingPrimaryAddress[0].Address_Line2__c + ', ' + billingPrimaryAddress[0].City__c + ', ' + billingPrimaryAddress[0].State__c + ', ' + billingPrimaryAddress[0].Postal_Code__c + ', ' + billingPrimaryAddress[0].Country__c;
} else if(billingPrimaryAddress[0].Address_Line1__c != Null) {pageSubscription.Bill_To_Address__c = billingPrimaryAddress[0].Address_Line1__c + ', ' + billingPrimaryAddress[0].City__c + ', ' + billingPrimaryAddress[0].State__c + ', ' + billingPrimaryAddress[0].Postal_Code__c + ', ' + billingPrimaryAddress[0].Country__c;
}*/
                    pageSubscription.Bill_To_Address__c = '';
                    comw.TaxRate = (comw.TaxRate == 0.00 && billingPrimaryAddress[0].Tax__c != null)?billingPrimaryAddress[0].Tax__r.Total_tax__c:comw.TaxRate;
                    if(billingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line1__c+', ';
                    if(billingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line2__c+', ';
                    if(billingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line3__c+', ';
                    if(billingPrimaryAddress[0].city__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].city__c+', ';
                    if(billingPrimaryAddress[0].State__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].State__c+', ';
                    if(billingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Postal_Code__c+', ';
                    if(billingPrimaryAddress[0].Country__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Country__c;
                }
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    billingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                        Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                        Organisation__c, Organisation_Business_Unit__c
                                        From Address__c
                                        Where Customer__c = : Customer.Id And Active__c = true And Is_Billing_Address__c = true
                                        order by Primary__c DESC, CreatedDate ASC];
                }
                
                if(billingAddresses.size()>0)
                    for(Address__c add: billingAddresses) {
                        comW.bAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id));
                    }
                if(shippingAddresses.size()>0)
                    for(Address__c add: shippingAddresses) {
                        comW.sAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id));
                    }
                SO = (son != '')? Database.query('SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + 'FROM ERP7__Sales_Order__c where Name=:son or Id=:son Limit 1') : new ERP7__Sales_Order__c(ERP7__Request_Date__c=system.today(), ERP7__Expected_Date__c = system.today(), ERP7__Employees__c = currentEmployees[0].Id, ERP7__Purchase_Order_Number__c='', ERP7__Special_Instructions__c='');
                comW.Customer = Customer;
                comW.Order = SO;
                comW.Contact = Contact;
                comW.billingAddresses = billingAddresses;
                comW.shippingAddresses = shippingAddresses;
                comW.sopas = sopas;
                comW.pageSubscription = pageSubscription;
                if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                    List<Loyalty_Card__c> clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, ERP7__Points_Per_Unit_Amount__c, Contact__c, Customer__c, Start_date__c,
                                                      Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                                                      Organisation__c, Organisation_Business_Unit__c
                                                      From Loyalty_Card__c Where
                                                      Customer__c = : Customer.Id And
                                                      Customer__c != Null And
                                                      Active__c = true And
                                                      Status__c = 'Active'
                                                      And
                                                      Start_date__c <= : todayDate And
                                                      Expiration_Date__c >= : todayDate And
                                                      Organisation__c = : currentSalepoint.Organisation__c //And
                                                      // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                                                      Limit 1];
                    if(clubCard.size() > 0){  comW.Points_Per_Unit_Amount = (clubCard[0].Active_Points__c/clubCard[0].ERP7__Points_Per_Unit_Amount__c).setScale(2);  }
                }
                
            }
            else if(cust != '' && cust != Null){
                system.debug('inhere cust~>'+cust);
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    //if(Customer.ERP7__Is_Person_Account__c == true)
                    //Customer = Database.query('SELECT Id, FirstName, LastName, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    comw.accTaxRate = (Customer != null && customer.ERP7__Vat__c != null)?customer.ERP7__Vat__r.ERP7__Total_Tax__c : 0.00;
                    //Customer = Database.query('SELECT '+String.escapeSingleQuotes(AllAccountFields)+' FROM Account WHERE Id = :CUST Limit 1');
                    //Customer = [SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website, ERP7__Account_Profile__c,  ERP7__VAT__c,Vat__r.Total_Tax__c, ERP7__VAT__r.Tax_Rate__c FROM Account WHERE Id = : CUST Limit 1];
                }
                String AccProfile = Customer.ERP7__Account_Profile__c;
                String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
                String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where ERP7__Account_Profile__c = :AccProfile and ERP7__Active__c = true order by ERP7__Default__c DESC';
                ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
                if(Schema.sObjectType.Profiling__c.isAccessible()) sopas = Database.query(queryProfiling);
                
                if(sopas.size() > 0 && !sopas[0].ERP7__Default__c) comW.SOPS.add(new SelectOptions('--None--', ''));
                for(ERP7__Profiling__c SOPA: sopas) {
                    comW.SOPS.add(new SelectOptions(SOPA.Name, sopa.Id));
                }
                
                List<Contact> conss = new List<Contact>();
                if(Schema.sObjectType.Contact.isAccessible()) {
                    //Contact = Database.query('SELECT '+String.escapeSingleQuotes(ContactFields)+' FROM Contact WHERE Id = :CON Limit 1');
                    conss = [SELECT Id, Name, Email, Title, Phone, ERP7__Contact_Numer__c, AccountId FROM Contact WHERE AccountId = : CUST Limit 1];
                }
                
                SO = (son == '')? new ERP7__Sales_Order__c(Request_Date__c=system.today(), ERP7__Expected_Date__c = system.today(),ERP7__Employees__c = currentEmployees[0].Id) : Database.query('SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + 'FROM ERP7__Sales_Order__c where Name=:son or Id=:son Limit 1');
                
                system.debug('Customer1~>'+Customer);
                comW.Customer = Customer;
                comW.Order = SO; 
                comW.Contact = (conss.size() == 0)? new Contact():conss[0];
                comW.billingAddresses = billingAddresses;
                comW.shippingAddresses = shippingAddresses;
                comW.sopas = sopas;
                comW.pageSubscription = pageSubscription;
                
                if(conss.size() == 1) {
                    system.debug('inhere conss size');

                    Contact = conss[0];
                    CON = Contact.Id;
                    comW.Contact = Contact;
                    List < Address__c > billingPrimaryAddress;
                    if(Schema.sObjectType.Address__c.isAccessible()) {
                        billingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                                 Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                                 Organisation__c, Organisation_Business_Unit__c,Tax__c,Tax__r.Total_Tax__c
                                                 From Address__c
                                                 Where Customer__c = : Customer.Id and Active__c = true and Is_Billing_Address__c = true
                                                 order by Primary__c DESC, CreatedDate ASC limit 1];
                    }
                    List < Address__c > shippingPrimaryAddress;
                    if(Schema.sObjectType.Address__c.isAccessible()) {
                        shippingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                                  Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                                  Organisation__c, Organisation_Business_Unit__c,Tax__c,Tax__r.Total_Tax__c
                                                  From Address__c
                                                  Where Customer__c = : Customer.Id and Active__c = true and Is_Shipping_Address__c = true
                                                  order by Primary__c DESC, CreatedDate ASC limit 1];
                    }
                    if(shippingPrimaryAddress.size() > 0) {
                        pageSubscription.Ship_To_Address__c = '';
                        comw.TaxRate = (shippingPrimaryAddress[0].Tax__c != null)?shippingPrimaryAddress[0].Tax__r.Total_tax__c:0.00;
                        if(shippingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line1__c+', ';
                        if(shippingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line2__c+', ';
                        if(shippingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Address_Line3__c+', ';
                        if(shippingPrimaryAddress[0].city__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].city__c+', ';
                        if(shippingPrimaryAddress[0].State__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].State__c+', ';
                        if(shippingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Postal_Code__c+', ';
                        if(shippingPrimaryAddress[0].Country__c != Null) pageSubscription.Ship_To_Address__c += shippingPrimaryAddress[0].Country__c;
                        
                    }
                    if(billingPrimaryAddress.size() > 0) {
                        pageSubscription.Bill_To_Address__c = '';
                        comw.TaxRate = (comw.TaxRate == 0.00 && billingPrimaryAddress[0].Tax__c != null)?billingPrimaryAddress[0].Tax__r.Total_tax__c:comw.TaxRate;
                        if(billingPrimaryAddress[0].Address_Line1__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line1__c+', ';
                        if(billingPrimaryAddress[0].Address_Line2__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line2__c+', ';
                        if(billingPrimaryAddress[0].Address_Line3__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Address_Line3__c+', ';
                        if(billingPrimaryAddress[0].city__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].city__c+', ';
                        if(billingPrimaryAddress[0].State__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].State__c+', ';
                        if(billingPrimaryAddress[0].Postal_Code__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Postal_Code__c+', ';
                        if(billingPrimaryAddress[0].Country__c != Null) pageSubscription.Bill_To_Address__c += billingPrimaryAddress[0].Country__c;
                        
                    }
                    if(Schema.sObjectType.Address__c.isAccessible()) {
                        billingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                            Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                            Organisation__c, Organisation_Business_Unit__c
                                            From Address__c
                                            Where Customer__c = : Customer.Id And Active__c = true And Is_Billing_Address__c = true
                                            order by Primary__c DESC, CreatedDate ASC];
                    }
                    
                    if(Schema.sObjectType.Address__c.isAccessible()) {
                        shippingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                             Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                             Organisation__c, Organisation_Business_Unit__c
                                             From Address__c
                                             Where Customer__c = : Customer.Id And Active__c = true And Is_Shipping_Address__c = true
                                             order by Primary__c DESC, CreatedDate ASC];
                    }
                    for(Address__c add: billingAddresses) {
                        comW.bAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id));
                    }
                    for(Address__c add: shippingAddresses) {
                        comW.sAdd.add(new SelectOptions(add.Postal_Code__c+', '+add.Address_Line1__c, add.Id));
                    }
                    
                    system.debug('Customer2~>'+Customer);
                    comW.Customer = Customer;
                    comW.Contact = Contact;
                    comW.currentSalepoint = currentSalepoint;
                    comW.currentEmployee = currentEmployees[0];
                    comW.invoice = invoice;
                    comW.billingAddresses = billingAddresses;
                    comW.shippingAddresses = shippingAddresses;
                    comW.sopas = sopas;
                    comW.pageSubscription = pageSubscription;
                    CUST = Customer.Id;
                    if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                        List<Loyalty_Card__c> clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, ERP7__Points_Per_Unit_Amount__c, Contact__c, Customer__c, Start_date__c,
                                                          Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                                                          Organisation__c, Organisation_Business_Unit__c
                                                          From Loyalty_Card__c Where
                                                          Customer__c = : Customer.Id And
                                                          Customer__c != Null And
                                                          Active__c = true And
                                                          Status__c = 'Active'
                                                          And
                                                          Start_date__c <= : todayDate And
                                                          Expiration_Date__c >= : todayDate And
                                                          Organisation__c = : currentSalepoint.Organisation__c //And
                                                          // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                                                          Limit 1];
                        if(clubCard.size() > 0){   comW.Points_Per_Unit_Amount = (clubCard[0].Active_Points__c/clubCard[0].ERP7__Points_Per_Unit_Amount__c).setScale(2);  }
                    }
                    
                }
            }
            
            system.debug('comW.Customer~>'+comW.Customer);
        } catch(exception ex) {  exceptionError = ex.getMessage()+' '+ex.getLineNumber(); comW.exceptionError = exceptionError;  }
        return comW;
    }
    
    public class comWrap {
        @AuraEnabled public ERP7__Sales_Order__c Order                               { get ; set; }
        @AuraEnabled public Contact Contact                                          { get ; set; }
        @AuraEnabled public Account Customer                                         { get ; set; }
        @AuraEnabled public ERP7__Channel__c currentSalepoint                        { get ; set; }
        @AuraEnabled public Employees__c currentEmployee                             { get ; set; }
        @AuraEnabled public Invoice__c invoice                                       { get ; set; }
        @AuraEnabled public List < Address__c > billingAddresses                     { get ; set; }
        @AuraEnabled public List < Address__c > shippingAddresses                    { get ; set; }
        @AuraEnabled public List < ERP7__Profiling__c > sopas                        { get ; set; }
        @AuraEnabled public ERP7__Subscription__c pageSubscription                   { get ; set; } 
        @AuraEnabled public String exceptionError                                    { get ; set; } 
        @AuraEnabled public List<itemWrapper> itemWrapperListCom                     { get ; set; }
        @AuraEnabled public Decimal subTotal                                         { get; Set; }
        @AuraEnabled public Decimal totalDiscount                                    { get; Set; }
        @AuraEnabled public Decimal totalDue                                         { get; Set; }
        @AuraEnabled public Decimal totalTax                                         { get; Set; }
        @AuraEnabled public Decimal finalDue                                         { get; Set; }
        @AuraEnabled public Decimal loyaltyAmount                                    { get; Set; }
        @AuraEnabled public Decimal loyalty_Points                                   { get; Set; }
        @AuraEnabled public List<selectOptions> SOPS                                 { get; Set; }
        @AuraEnabled public List<selectOptions> bAdd                                 { get; Set; }
        @AuraEnabled public List<selectOptions> sAdd                                 { get; Set; }
        @AuraEnabled public List<selectOptions> orderStatus                          { get; Set; }
        @AuraEnabled public List<selectOptions> CountryList                          { get; Set; }
        @AuraEnabled public List<selectOptions> CountyList                           { get; Set; }
        @AuraEnabled public List<selectOptions> CardTypes                            { get; Set; }
        @AuraEnabled public List<selectOptions> ExpiryMonth                          { get; Set; }
        @AuraEnabled public List<selectOptions> ExpiryYear                           { get; Set; }
        @AuraEnabled public List<selectOptions> payType                           { get; Set; }
        @AuraEnabled public List<selectOptions> prodFam                              { get; Set; }
        @AuraEnabled public List<selectOptions> prodCat                              { get; Set; }
        @AuraEnabled public List<selectOptions> prodSubCat                           { get; Set; }
        @AuraEnabled public List<selectOptions> shipmentType                         { get; Set; }
        @AuraEnabled public Contact NewCont                                          { get; set; }
        @AuraEnabled public Account NewCustomer                                      { get; set; }
        @AuraEnabled public Address__c NewAddresses                                  { get; set; }
        @AuraEnabled public Address__c BillAddresses                                  { get; set; }
        @AuraEnabled public List < ERP7__Payment__c > SO_Payments                    { get; set; }
        @AuraEnabled public List < ERP7__Shipment__c > Shipments                     { get; set; }
        @AuraEnabled public ERP7__Payment__c Payment                                 { get; set; }
        @AuraEnabled public ERP7__Payment_Method__c PaymentMethod                    { get; set; }
        @AuraEnabled public String CardError                                         { get; set; }
        @AuraEnabled public String logo                                              { get; set; }
        @AuraEnabled public String orderCurrency                                              { get; set; }
        @AuraEnabled public String spinner                                           { get; set; }
        @AuraEnabled public Decimal TaxRate                                          { get; set; }
        @AuraEnabled public Decimal accTaxRate                                       { get; set; }
        @AuraEnabled public List<ERP7__Credit_Note__c> creditNotes                   { get; set; }
        @AuraEnabled public Boolean Loyalty                                          { get; set; }
        @AuraEnabled public Boolean isMultiCurrency                                  { get; set; }
        @AuraEnabled public Decimal Points_Per_Unit_Amount                           { get; set; }
        @AuraEnabled public List<RecentlyViewed> recentRecords                       { get; set; } 
        @AuraEnabled public boolean ispreOrder                                       { get; set; } 
        @AuraEnabled public boolean isbackOrder                                      { get; set; } 
        
        public comWrap() {
            isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            ispreOrder = false;
            isbackOrder = false;
            Order = new ERP7__Sales_Order__c();
            Contact = new Contact();
            Customer = new Account();
            NewCont = new Contact();
            NewCustomer = new Account();
            NewAddresses = new Address__c();
            BillAddresses = new Address__c();
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
            payType = new List < selectOptions > ();
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
    public class itemWrapper {
        @AuraEnabled public product2 product                         { get; set; }
        @AuraEnabled public String code                              { get; set; }
        @AuraEnabled public String itm                               { get; set; }
        @AuraEnabled public String itmId                             { get; set; }
        @AuraEnabled public String productId                         { get; set; }
        @AuraEnabled public String orderLineItemId                   { get; set; }
        @AuraEnabled public String pricebookId                       { get; set; }
        @AuraEnabled public Decimal quantity_s                       { get; set; }
        @AuraEnabled public Integer quantity                         { get; set; }
        @AuraEnabled public Decimal price                            { get; set; }
        @AuraEnabled public Decimal vat                              { get; set; }
        @AuraEnabled public Decimal tax                              { get; set; }
        @AuraEnabled public Decimal priceWithVat                     { get; set; }
        @AuraEnabled public String discountName                      { get; set; }
        @AuraEnabled public String discountId                        { get; set; }
        @AuraEnabled public Decimal discountPercent                  { get; set; }
        @AuraEnabled public Decimal discount                         { get; set; }
        @AuraEnabled public Decimal rewardPoints                     { get; set; }
        @AuraEnabled public String programId                         { get; set; }
        @AuraEnabled public Decimal commission                       { get; set; }
        @AuraEnabled public String ratecardId                        { get; set; }
        @AuraEnabled public List<Product_Tax_Allocation__c> Taxes    { get; set; }
        @AuraEnabled public Boolean scanned                          { get; set; }
        @AuraEnabled public Boolean trackInventory                   { get; set; }
        @AuraEnabled public String  prod_Desc                        { get; set; }
        @AuraEnabled public String checkOutProcess                   { get; set; }
        @AuraEnabled public Sales_Order_Line_Item__c lineitm         { get; set; }
        @AuraEnabled public Asset__c asset                           { get; set; }
        @AuraEnabled public Decimal moq                              { get; set; } 
        @AuraEnabled public Decimal hrs                              { get; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> SerialNos   { get; set; }
        @AuraEnabled public ERP7__Serial_Number__c Serial            { get; set; }
        @AuraEnabled public List<ERP7__Batch__c> Batches             { get; set; }
        @AuraEnabled public ERP7__Batch__c Batch                     { get; set; }
        @AuraEnabled public List<selectOptions> RentalUnits          { get; Set; }
        @AuraEnabled public String RentalUnit                        { get; Set; }
        @AuraEnabled public DateTime EndTime                         { get; set; }
        @AuraEnabled public DateTime StartTime                       { get; set; }
        @AuraEnabled public boolean ispreOrder                       { get; set; } 
        @AuraEnabled public boolean isbackOrder                      { get; set; }
        @AuraEnabled public String Version                           { get; Set; }
        @AuraEnabled public Decimal couponDiscount                   { get; set; }
        @AuraEnabled public String taxId                             { get; Set; }
        @AuraEnabled public Decimal costprice                        { get; set; }
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
            lineitm = new Sales_Order_Line_Item__c();
            asset = new Asset__c();
            hrs = 0;
            SerialNos = new List<ERP7__Serial_Number__c>();
            Serial = new ERP7__Serial_Number__c();
            Batches = new List<ERP7__Batch__c>();
            Batch = new ERP7__Batch__c();
            RentalUnits = new List<SelectOptions>();
            RentalUnit = '';
            ispreOrder = false;
            isbackOrder = false;
            Version = '';
            couponDiscount = 0;
            taxId = '';
        }
    }
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab;
            value = val;
            selected = sel;
        }
    }
    @AuraEnabled
    public static String getBA(String baId) {
        List < Address__c > billingPrimaryAddress;
        String BA = '';
        if(Schema.sObjectType.Address__c.isAccessible()) {
            billingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                Organisation__c, Organisation_Business_Unit__c
                From Address__c
                Where Id = : baId limit 1];
        }
        if(billingPrimaryAddress.size() > 0) {
            
            if(billingPrimaryAddress[0].Address_Line1__c != Null) BA += billingPrimaryAddress[0].Address_Line1__c+', ';
            if(billingPrimaryAddress[0].Address_Line2__c != Null) BA += billingPrimaryAddress[0].Address_Line2__c+', ';
            if(billingPrimaryAddress[0].Address_Line3__c != Null) BA += billingPrimaryAddress[0].Address_Line3__c+', ';
            if(billingPrimaryAddress[0].city__c != Null) BA += billingPrimaryAddress[0].city__c+', ';
            if(billingPrimaryAddress[0].State__c != Null) BA += billingPrimaryAddress[0].State__c+', ';
            if(billingPrimaryAddress[0].Postal_Code__c != Null) BA += billingPrimaryAddress[0].Postal_Code__c+', ';
            if(billingPrimaryAddress[0].Country__c != Null) BA += billingPrimaryAddress[0].Country__c;
                
        }
        return BA;
    }
    @AuraEnabled
    public static String getSA(String saId) {
        List < Address__c > shippingPrimaryAddress;
        String SA = '';
        if(Schema.sObjectType.Address__c.isAccessible()) {
            shippingPrimaryAddress = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                Organisation__c, Organisation_Business_Unit__c
                From Address__c
                Where Id = : saId limit 1];
        }
        if(shippingPrimaryAddress.size() > 0) {
            
            if(shippingPrimaryAddress[0].Address_Line1__c != Null) SA += shippingPrimaryAddress[0].Address_Line1__c+', ';
            if(shippingPrimaryAddress[0].Address_Line2__c != Null) SA += shippingPrimaryAddress[0].Address_Line2__c+', ';
            if(shippingPrimaryAddress[0].Address_Line3__c != Null) SA += shippingPrimaryAddress[0].Address_Line3__c+', ';
            if(shippingPrimaryAddress[0].city__c != Null) SA += shippingPrimaryAddress[0].city__c+', ';
            if(shippingPrimaryAddress[0].State__c != Null) SA += shippingPrimaryAddress[0].State__c+', ';
            if(shippingPrimaryAddress[0].Postal_Code__c != Null) SA += shippingPrimaryAddress[0].Postal_Code__c+', ';
            if(shippingPrimaryAddress[0].Country__c != Null) SA += shippingPrimaryAddress[0].Country__c;
                
        }
        return SA;
    }
    public class ProductsAndDiscounts {
        @AuraEnabled public product2 product                           { get; set; }
        @AuraEnabled public Asset__c asset                             { get; set; }
        @AuraEnabled public PricebookEntry pricebookEntry              { get; set; }
        @AuraEnabled public Decimal quantity_s                         { get; set; }
        @AuraEnabled public Integer quantity                           { get; set; }
        @AuraEnabled public String discountName                        { get; set; }
        @AuraEnabled public String currentConId                        { get; set; }
        @AuraEnabled public List<SelectOptions> CurrentDiscounts       { get; set; }
        @AuraEnabled public List<SelectOptions> Versions               { get; set; }
        @AuraEnabled public String Version                             { get; set; }
        @AuraEnabled public Decimal discountPercent                    { get; set; }
        @AuraEnabled public Decimal maxDiscountPercent                 { get; set; }
        @AuraEnabled public Decimal minDiscountPercent                 { get; set; }
        @AuraEnabled public List<SelectOptions> CurrentDiscountPercent { get; set; }
        @AuraEnabled public List<selectOptions> RentalUnits            { get; Set; }
        @AuraEnabled public String RentalUnit                          { get; Set; }
        @AuraEnabled public Boolean selected                           { get; set; }
        @AuraEnabled public Boolean trackInventory                     { get; set; }
        @AuraEnabled public String checkOutProcess                     { get; set; }
        @AuraEnabled public Decimal moq                                { get; set; } 
        @AuraEnabled public Decimal stock                              { get; set; }
        @AuraEnabled public Boolean explode                            { get; set; }
        @AuraEnabled public Boolean isPercent                          { get; set; }
        @AuraEnabled public List<ProductsAndDiscounts> pdList          { get; set; }
        @AuraEnabled public Decimal hrs                                { get; set; }
        @AuraEnabled public List<ERP7__Serial_Number__c> SerialNos     { get; set; }
        @AuraEnabled public ERP7__Serial_Number__c Serial              { get; set; }
        @AuraEnabled public List<ERP7__Batch__c> Batches               { get; set; }
        @AuraEnabled public ERP7__Batch__c Batch                       { get; set; }
        @AuraEnabled public DateTime StartTime                         { get; set; }
        @AuraEnabled public DateTime EndTime                           { get; set; }
        @AuraEnabled public Boolean showcbox                           { get; set; }
        @AuraEnabled public String  product_status                     { get; set; }
        @AuraEnabled public String  product_Type                       { get; set; }
        @AuraEnabled public Decimal allBatchesStock                    { get; set; }
        @AuraEnabled public Decimal costprice                          { get; set; }
        
        public ProductsAndDiscounts() {
            quantity = 1;
            showcbox = false;
            product_status = '';
            product_Type = '';
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
            asset = new Asset__c();
            hrs = 1;
            pdList = new List<ProductsAndDiscounts>();
            SerialNos = new List<ERP7__Serial_Number__c>();
            Serial = new ERP7__Serial_Number__c();
            Batches = new List<ERP7__Batch__c>();
            Batch = new ERP7__Batch__c();
            RentalUnits = new List < selectOptions > ();
            RentalUnit = '';
            allBatchesStock = 0;
            //EndTime = new DateTime();
        }
    }
    
    @AuraEnabled public static List < Object > productFetch(String itemName, String ProdFam, String currentSalepoints1, String Customers1, String Contacts1, String SOP, List < itemWrapper > itemWrapperList) { 
       List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        List < ProductsAndDiscounts > PDWL = new List < ProductsAndDiscounts > (); 
        return PDWL; 
    }
    @AuraEnabled public static List < Object > productFetchs(String itemName, String ProdFam, String ProdCat, String ProdSubCat, String currentSalepoints1, String Customers1, String Contacts1, String SOP, List < itemWrapper > itemWrapperList) { 
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        List < ProductsAndDiscounts > PDWL = new List < ProductsAndDiscounts > (); 
        return PDWL; 
    }
       
    @AuraEnabled
    public static List < Object > productFetchss(String itemName, String ProdFam, String ProdCat, String ProdSubCat, String currentSalepoints1, String Customers1, String Contacts1, String SOP, String itemWrapperList, Boolean isBackOrder, Boolean isPreOrder, Date ExpectedDate, Integer productLimit) {
        
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        List < ProductsAndDiscounts > PDWL = new List < ProductsAndDiscounts > ();
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        Account Customer = Customers[0];
        Contact Contact = Contacts[0];
        
        List < Id > productIds = new List < Id > ();
        List < Id > existingProductIds = new List < Id > ();
        ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
        String OrgnPSA = currentSalepoint.Organisation__c;
        String OrgnBusIdPSA = currentSalepoint.Organisation_Business_Unit__c;
        String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
        String itemNamePSA = '%' + itemName + '%';
        String productFamily = prodFam;
        List<SelectOptions> RentalUnits = new List<SelectOptions> ();
               
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
        string kk = itemWrapperList;
        List < itemWrapper > deserializedList = (List < itemWrapper > ) JSON.deserialize(kk, List < itemWrapper > .class);
        for(itemWrapper iw : deserializedList) {
            //existingProductIds.add(iw.product.Id);
        }        
        String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
        if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
        
        String PricebookId = Profiling.Price_Book__c;
        Date todays = system.today();
        String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
        UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
        allFieldss += ' ,Product2.Name, Product2.Family, Product2.ERP7__Category__c, Product2.ERP7__Sub_Category__c, Product2.ERP7__Allow_Pre_Orders__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Status__c,Product2.Track_Inventory__c ';
        String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ' from PricebookEntry where IsActive = true AND Pricebook2Id = :PricebookId and Product2Id Not In :existingProductIds AND (Product2.ERP7__Status__c = \'Certified\' Or Product2.ERP7__Status__c = \'In Development\' Or Product2.ERP7__Status__c = \'Released\') AND (Product2.Name like: itemNamePSA or Product2.ProductCode like: itemNamePSA or Product2.ERP7__Barcode__c like: itemNamePSA or Product2.ERP7__ASIN_Code__c like: itemNamePSA or Product2.StockKeepingUnit like: itemNamePSA)'; //     and ERP7__Start_Date__c <= :todays and ERP7__End_Date__c >= :todays  
        if(prodFam != null && prodFam != '') querys += ' And Product2.Family = : prodFam';
        if(prodCat != null && prodCat != '') querys += ' And Product2.ERP7__Category__c = : prodCat';
        if(prodSubCat != null && prodSubCat != '') querys += ' And Product2.ERP7__Sub_Category__c = : prodSubCat';
        //if(isBackOrder == false && isPreOrder == false) querys += ' And Product2.ERP7__Status__c = \'Released\'';
        //if(isBackOrder == true) querys += ' And Product2.ERP7__Allow_Back_Orders__c = true And (Product2.ERP7__Status__c = \'Certified\' Or Product2.ERP7__Status__c = \'Released\')';//
        //if(isPreOrder == true) querys += ' And Product2.ERP7__Allow_Pre_Orders__c = true And (Product2.ERP7__Status__c = \'Certified\' Or Product2.ERP7__Status__c = \'In Development\')';
        querys += ' Limit '+productLimit;
        
        
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        if(Schema.sObjectType.PricebookEntry.isAccessible()){
        priceBookEntries = Database.query(querys);}
        Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
        for(PricebookEntry IPE: priceBookEntries) {
            //if(IPE.Product2.ERP7__Status__c == 'In Development' && (!IPE.Product2.ERP7__Allow_Pre_Orders__c || !IPE.Product2.ERP7__Allow_Back_Orders__c)) continue;
            productIds.add(IPE.Product2Id);
            productPriceBookMap.put(IPE.Product2Id, IPE);
        }
        Map<Id, List<ERP7__Version__c>> proVersions = new Map<Id, List<ERP7__Version__c>>();
        Map<Id, ERP7__Version__c> proDefVersion = new Map<Id, ERP7__Version__c>();
        List<ERP7__Version__c> Versions = [Select Id, Name, ERP7__Active__c, ERP7__Asset__c, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Picture__c,
                                            ERP7__Preview_Image__c, ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Ready__c, ERP7__Start_Date__c, ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c    
                                            From ERP7__Version__c
                                            Where ERP7__Active__c = true And
                                            //ERP7__Price_Book__c =: PricebookId And
                                            //Profiling.ERP7__Account_Profile__c And 
                                            ERP7__Sales_Ready__c = true And 
                                            ERP7__Product__c In : productIds
                                            Order By ERP7__Default__c Desc];
        
        for(Id pId: productIds) { 
            List<ERP7__Version__c> myVersions = new List<ERP7__Version__c>();
            for(ERP7__Version__c version : Versions){
                if(pId == version.ERP7__Product__c) {
                    if(version.ERP7__Price_Book__c == PricebookId && version.ERP7__Default__c && !proDefVersion.containsKey(pId)) proDefVersion.put(pId,version);
                    myVersions.add(version);
                }
            }
            proVersions.put(pId,myVersions);
        }
        
        
        List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
        List<ERP7__Stock_Inward_Line_Item__c>  SDLIs = new List<ERP7__Stock_Inward_Line_Item__c>();
        List<ERP7__Serial_Number__c> SerialNos = new List<ERP7__Serial_Number__c>();
        if(productIds.size() > 0) {
           
           SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Available__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                       Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.ERP7__Sales_Order__c,ERP7__Purchase_Orders__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c,ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c,
                       ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.ERP7__Sales_Order__c,ERP7__Manufacturing_Order__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c
                       From ERP7__Stock_Inward_Line_Item__c 
                       Where ERP7__Product__c = :productIds And 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds];
            Set<Id> InventoryIds = new Set<Id>();
            for(ERP7__Stock_Inward_Line_Item__c SOLI : SDLIs) { 
                if(SOLI.ERP7__Purchase_Orders__c != null && SOLI.ERP7__Purchase_Orders__r.ERP7__Sales_Order__c != null && SOLI.ERP7__Purchase_Orders__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c == true) {
                    InventoryIds.add(SOLI.ERP7__Site_ProductService_InventoryStock__c); 
                }
                system.debug('SOLI.ERP7__Manufacturing_Order__c : '+SOLI.ERP7__Manufacturing_Order__c);
                if(SOLI.ERP7__Manufacturing_Order__c != null && SOLI.ERP7__Manufacturing_Order__r.ERP7__Sales_Order__c != null && SOLI.ERP7__Manufacturing_Order__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c == true){
                    InventoryIds.add(SOLI.ERP7__Site_ProductService_InventoryStock__c);
                }
                
            }
            system.debug('InventoryIds : '+InventoryIds.size());
             WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                 Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,
                                                 Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                 From Inventory_Stock__c
                                                 Where product__c In: productIds And
                                                 Active__c = true And
                                                 Id Not IN :InventoryIds and 
                                                 //Organisation__c = : currentSalepoint.Organisation__c And
                                                 //Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                                                 Warehouse__c In: siteIds And
                                                 Number_of_Item_In_Stock__c > 0
                                                ];
            List<Id> selIds = new List<Id>();
             SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Available__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                       Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Purchase_Orders__c,ERP7__Purchase_Orders__r.ERP7__Sales_Order__c,ERP7__Purchase_Orders__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c,ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c,
                       ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.ERP7__Sales_Order__c,ERP7__Manufacturing_Order__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c
                       From ERP7__Stock_Inward_Line_Item__c 
                       Where ERP7__Fixed_Asset__r.ERP7__Product__c = :productIds And 
                       ERP7__Serial__c != Null And 
                       ERP7__Fixed_Asset__r.ERP7__Available__c = true And
                       (ERP7__Fixed_Asset__r.ERP7__Is_Reserved__c = false Or (ERP7__Fixed_Asset__r.ERP7__Is_Reserved__c = true And ERP7__Fixed_Asset__r.Account__c = :Customer.Id)) And
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds];
            for(ERP7__Stock_Inward_Line_Item__c SOLI : SDLIs) { 
                selIds.add(SOLI.ERP7__Serial__c);
            }
           
            String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
            allFields += ' , ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :selIds And ERP7__Asset__r.ERP7__Product__c In :productIds And ERP7__Asset__r.ERP7__Available__c = true And ERP7__Available__c = true '; // And ERP7__Warehouse__c In :siteIds  
            SerialNos = Database.query(query);
            
        }
        Map<Id, List<ERP7__Serial_Number__c>> productAssets = new Map<Id, List<ERP7__Serial_Number__c>>();
        for(Id pId: productIds) {
            List<ERP7__Serial_Number__c> mySerials = new List<ERP7__Serial_Number__c>();
            for(ERP7__Serial_Number__c slno : SerialNos){  if(pId == slno.ERP7__Asset__r.ERP7__Product__c) mySerials.add(slno);  }
            productAssets.put(pId,mySerials);
        }
        
        Map<Id, Decimal> assetCount = new Map<Id, Decimal>();
        for(Id pId: productIds) {
            Integer count = 0;
            for(ERP7__Serial_Number__c slno : productAssets.get(pId)){  if(pId == slno.ERP7__Asset__r.ERP7__Product__c) count++;  }
            assetCount.put(pId,count);
        }
            
        Map < Id, List < Inventory_Stock__c >> productWarehouses = new Map < Id, List < Inventory_Stock__c >> ();
        Map < Id, Decimal > productStock = new Map < Id, Decimal > ();
        List < Id > newProductIds = new List < Id > ();
        for(Id pId: productIds) {
            List < Inventory_Stock__c > myWarehouses = new List < Inventory_Stock__c > ();
            Decimal myStock = 0;
            if(assetCount.containsKey(pId) && assetCount.get(pId) > 0){  myStock = assetCount.get(pId);
            }else{
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(PId == WIIS.product__c && (!proDefVersion.containsKey(PId) || (proDefVersion.containsKey(PId) && proDefVersion.get(PId).Id == WIIS.ERP7__Version__c))) {
                        myWarehouses.add(WIIS);
                        myStock += WIIS.Number_of_Item_In_Stock__c;
                    }
                }
            }
            if(!productPriceBookMap.get(pId).Product2.Track_Inventory__c) {
                newProductIds.add(PId);  if(assetCount.containsKey(pId) && assetCount.get(pId) > 0){  productStock.put(PId, myStock);  }
            } else if(myStock >= 0) {
                newProductIds.add(PId);
                productWarehouses.put(PId, myWarehouses);
                productStock.put(PId, myStock);
            }
        }
        
        List < product2 > allProducts = new List < product2 > ();
        
        String allFieldsProduct2 = UtilClass.selectStarFromSObject('Product2');
        String queryProduct2 = 'select ' + String.escapeSingleQuotes(allFieldsProduct2) + ' from Product2 where Id In: newProductIds And IsActive = true';
       
        if(prodFam != null && prodFam != '') queryProduct2 += ' And Family = : prodFam';
        if(prodCat != null && prodCat != '') queryProduct2 += ' And ERP7__Category__c = : prodCat';
        if(prodSubCat != null && prodSubCat != '') queryProduct2 += ' And ERP7__Sub_Category__c = : prodSubCat';
        queryProduct2 += ' Order by Name Limit '+productLimit;
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
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
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
        if(Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c, Ceiling_Discount_Value__c, Default_Discount_Value__c, Floor_Discount_Value__c,
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
                        if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null){
                            if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c);
                        }
                        else if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null){    
                            if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Value__c);  if(TDA.Discount_Plan__r.Floor_Discount_Value__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Value__c);  if(TDA.Discount_Plan__r.Ceiling_Discount_Value__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Value__c);
                        }
                    }
                }
            }
            discountPlans.put(product.id, myDiscountPlans);
        }
        for(product2 product: allProducts) {
            ProductsAndDiscounts PDs = new ProductsAndDiscounts();
            PDs.product = product;
            List < SelectOptions > options = new List < SelectOptions > ();
            options.add(new SelectOptions('--None--', ''));
            if(discountPlans.get(product.id) != null) {
                for(Discount_Plan__c dis: discountPlans.get(product.id)) {
                    options.add(new SelectOptions(dis.Name,dis.Id));
                    if(defaultDiscountMap.containsKey(product.Id) && dis.Id == defaultDiscountMap.get(product.Id) && dis.ERP7__Default_Discount_Percentage__c != Null) PDs.isPercent = true;
                }
            }
            List < SelectOptions > versionOptions = new List < SelectOptions > ();
            if(proVersions.get(product.id).size() == 0 || (proVersions.get(product.id).size() > 0 && !proVersions.get(product.id)[0].ERP7__Default__c)) versionOptions.add(new SelectOptions('--None--', ''));
            for(ERP7__Version__c version: proVersions.get(product.id)) {
                versionOptions.add(new SelectOptions(version.Name,version.Id));
            }
            PDs.Versions = versionOptions;
            PDs.pricebookEntry = productPriceBookMap.get(product.id);
            //PDs.quantity_s = currentQuantity;
            if(defaultDiscountMap.containsKey(product.Id)) {
                PDs.discountName = defaultDiscountMap.get(product.Id);
            }
            else PDs.discountName = '';
            PDs.CurrentDiscounts = options;
            if(defaultDiscountPercentMap.containsKey(product.Id)) PDs.discountPercent = defaultDiscountPercentMap.get(product.Id);
            if(defaultDiscountPercentMapMin.containsKey(product.Id)) PDs.minDiscountPercent = defaultDiscountPercentMapMin.get(product.Id);
            if(defaultDiscountPercentMapMax.containsKey(product.Id)) PDs.maxDiscountPercent = defaultDiscountPercentMapMax.get(product.Id);
            PDS.trackInventory = PDs.pricebookEntry.Product2.Track_Inventory__c;
            PDS.checkOutProcess = PDs.pricebookEntry.ERP7__Check_Out_Process__c;
            PDs.moq = PDs.product.ERP7__MOQ__c;
            PDs.quantity_s = (PDs.moq !=null)?PDs.moq:currentQuantity;
            //PDs.StartTime = (salesOrderDraft.Expected_Date__c != Null)? salesOrderDraft.Expected_Date__c : system.Now();
            PDs.StartTime = system.Now();
            PDs.EndTime = PDs.StartTime + PDs.quantity_s;
            PDs.stock = productStock.get(product.Id);
            PDs.SerialNos = new List<ERP7__Serial_Number__c>();
            PDWL.add(PDs);
            
        }
        return PDWL;
    }
    
    @AuraEnabled
    public static List<ProductsAndDiscounts> getSerialNos(String currentSalepoints1, String Customers1, String objsel, String SerialNumber){
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        Account Customer = Customers[0];
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        List < Id > siteIds = new List < Id > ();
        List < Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where 
                                                                    Channel__c = : currentSalepoint.Id And Active__c = true];
        for(Distribution_Channel__c DC: DistributionChannels) siteIds.add(DC.Site__c);
        ProductsAndDiscounts pnd = (ProductsAndDiscounts) JSON.deserialize(objsel, ProductsAndDiscounts .class);
        String pvId = pnd.Version;
        String SerialNumberPat = '%'+SerialNumber+'%';
        String itemId = pnd.product.Id;
        List<Id> selIds = new List<Id>();
        for(ERP7__Serial_Number__c SN : pnd.SerialNos) selIds.add(SN.Id);
        List<ProductsAndDiscounts> Wrappers = new List<ProductsAndDiscounts>();
        List<ERP7__Serial_Number__c> SerialNos = new List<ERP7__Serial_Number__c>();
        
        if(pnd.product.ERP7__Is_Asset__c == true){
            List<ERP7__Stock_Inward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                                                               Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c,
                                                               ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c
                                                               From ERP7__Stock_Inward_Line_Item__c 
                                                               Where ERP7__Fixed_Asset__r.ERP7__Product__c = :itemId And 
                                                               ERP7__Serial__c != Null And 
                                                               ERP7__Serial__r.ERP7__Available__c = true And
                                                               ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                                                               ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds And
                                                               ERP7__Serial__r.ERP7__Serial_Number__c like :SerialNumberPat And
                                                               (ERP7__Fixed_Asset__r.ERP7__Is_Reserved__c = false Or (ERP7__Fixed_Asset__r.ERP7__Is_Reserved__c = true And ERP7__Fixed_Asset__r.Account__c = :Customer.Id)) And
                                                               ERP7__Serial__c Not In :selIds];
            selIds = new List<Id>();
            for(ERP7__Stock_Inward_Line_Item__c SOLI : SDLIs){
                if((pvId != '' && pvId == SOLI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c) || pvId == '') selIds.add(SOLI.ERP7__Serial__c); 
            }
            String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
            allFields += ', ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c, ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :selIds And ERP7__Asset__r.ERP7__Product__c = :itemId And ERP7__Serial_Number__c like :SerialNumberPat And ERP7__Asset__r.ERP7__Available__c = true And ERP7__Available__c = true And ERP7__Expired__c = false Order BY ERP7__Asset__r.ERP7__Is_Reserved__c DESC '; // And ERP7__Warehouse__c In :siteIds
            SerialNos = Database.query(query);
            
        } else {
            // check out
            List<ERP7__Stock_Inward_Line_Item__c>  SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                                                               Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c,
                                                               ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c
                                                               From ERP7__Stock_Inward_Line_Item__c 
                                                               Where Product__c = :itemId And 
                                                               ERP7__Serial__c != Null And 
                                                               ERP7__Serial__r.ERP7__Available__c = true And 
                                                               ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                                                               ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds And
                                                               ERP7__Serial__r.ERP7__Serial_Number__c like :SerialNumberPat And
                                                               ERP7__Serial__c Not In :selIds];
            selIds = new List<Id>();
            for(ERP7__Stock_Inward_Line_Item__c SOLI : SDLIs){
                if((pvId != '' && pvId == SOLI.ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c) || pvId == '') selIds.add(SOLI.ERP7__Serial__c);
            }
            String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
            allFields += ' , ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c ';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :selIds And ERP7__Product__c = :itemId And ERP7__Available__c = true And ERP7__Expired__c = false Order BY ERP7__Asset__r.ERP7__Is_Reserved__c DESC '; // And ERP7__Warehouse__c In :siteIds
            SerialNos = Database.query(query);
            
        }
        for(ERP7__Serial_Number__c SL : SerialNos){  ProductsAndDiscounts Wrapper = new ProductsAndDiscounts();
            if(pnd.product.ERP7__Is_Asset__c == true) {
                Wrapper.RentalUnit = pnd.RentalUnit;  if(SL.ERP7__Start_Date__c == Null) SL.ERP7__Start_Date__c = system.today();  if(SL.ERP7__End_Date__c == Null) SL.ERP7__End_Date__c =  system.today();  if(Wrapper.StartTime == Null) Wrapper.StartTime = system.today();  if(Wrapper.EndTime == Null) Wrapper.EndTime = system.today();
            }
            Wrapper.Serial = SL;  Wrappers.add(Wrapper);
        }
        return Wrappers;
    }
    
    @AuraEnabled
    public static List<ProductsAndDiscounts> getBatchNos(String currentSalepoints1, String Customers1, String objsel, String BatchNumber){
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        Account Customer = Customers[0];
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        List < Id > siteIds = new List < Id > ();
        List < Distribution_Channel__c > DistributionChannels = [Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where Channel__c = : currentSalepoint.Id And Active__c = true];
        for(Distribution_Channel__c DC: DistributionChannels) siteIds.add(DC.Site__c);
        ProductsAndDiscounts pnd = (ProductsAndDiscounts) JSON.deserialize(objsel, ProductsAndDiscounts .class);
        String BatchNumberPat = '%'+BatchNumber+'%';
        String itemId = pnd.product.Id;
        system.debug('itemId : '+itemId);
        system.debug('BatchNumberPat : '+BatchNumberPat);
        String pvId = pnd.Version;
        system.debug('pvId : '+pvId);
        List<Id> batchIds = new List<Id>();
        
        for(ERP7__Batch__c SN : pnd.Batches) batchIds.add(SN.Id);
        List<ProductsAndDiscounts> Wrappers = new List<ProductsAndDiscounts>();
        List< ERP7__Batch__c > BatchNos = new List< ERP7__Batch__c >();
        system.debug('batchIds : '+batchIds.size());
        String allFields = UtilClass.selectStarFromSObject('ERP7__Batch__c');
        allFields += ' , ERP7__Product__r.Name, ERP7__Product__r.ERP7__Picture__c,ERP7__Manufacturing_Order__r.ERP7__Sales_Order__c,ERP7__Manufacturing_Order__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c,ERP7__Purchase_Orders__r.ERP7__Sales_Order__c,ERP7__Purchase_Orders__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c ';
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Batch__c where ERP7__Product__c = :itemId And ERP7__Available_Quantity__c > 0'; // And ERP7__Warehouse__c In :siteIds
        if(batchIds.size() > 0) query += ' And Id Not In :batchIds';
        if(BatchNumber != null && BatchNumber != '') query += ' And Name like :BatchNumberPat';
        if(pvId != '' && pvId != null) query += ' And ERP7__Production_Version__c = :pvId';
        
        BatchNos = Database.query(query);
        system.debug('BatchNos : '+BatchNos.size());
        for(ERP7__Batch__c BT : BatchNos){ 
            if(BT.ERP7__Manufacturing_Order__c != null && BT.ERP7__Manufacturing_Order__r.ERP7__Sales_Order__c != null && BT.ERP7__Manufacturing_Order__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c){
                continue;
            }
            else if(BT.ERP7__Purchase_Orders__c != null && BT.ERP7__Purchase_Orders__r.ERP7__Sales_Order__c != null && BT.ERP7__Purchase_Orders__r.ERP7__Sales_Order__r.ERP7__Allocate_Order_Specific_Stocks__c){
                continue;
            }
            else { ProductsAndDiscounts Wrapper = new ProductsAndDiscounts();  Wrapper.Batch = BT;   Wrappers.add(Wrapper); }
        }
        return Wrappers;
    }
    
    @AuraEnabled
    public static ProductsAndDiscounts getCharge(String objsel){
        ProductsAndDiscounts pnd = (ProductsAndDiscounts) JSON.deserialize(objsel, ProductsAndDiscounts .class);
        ProductsAndDiscounts Wrapper = new ProductsAndDiscounts();
        if(pnd.product.ERP7__Is_Asset__c == true && pnd.EndTime != Null){
            //pnd.quantity_s = Decimal.valueof(pnd.EndTime.getTime() - system.Now().getTime());
            Decimal milliseconds = (pnd.StartTime != Null)? (pnd.EndTime.getTime() - pnd.StartTime.getTime()): (pnd.EndTime.getTime() - system.Now().getTime());
            Decimal seconds = milliseconds / 1000;
            Decimal minutes = seconds / 60;
            
            Decimal hours = minutes / 60;
            Decimal days = hours / 24;
            Decimal weeks = days / 7;
            Decimal months = days / 12;
            Decimal years = days / 365;
            
            if(pnd.product.ERP7__Uom__c == 'hours') pnd.quantity_s = hours.setscale(2);
            if(pnd.product.ERP7__Uom__c == 'days') pnd.quantity_s = days.setscale(2);
            if(pnd.product.ERP7__Uom__c == 'weeks') pnd.quantity_s = weeks.setscale(2);
            if(pnd.product.ERP7__Uom__c == 'months') pnd.quantity_s = months.setscale(2);
            if(pnd.product.ERP7__Uom__c == 'years') pnd.quantity_s = years.setscale(2);
            
        }
        return pnd;
    }
    
    @AuraEnabled
    public static ProductsAndDiscounts DiscountPlans(String itemId, String currentSalepoints1, Boolean isBackorder, String Customers1,String Contacts1, String SOP, Decimal quantity_s, String Version) {
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        ProductsAndDiscounts Wrapper = new ProductsAndDiscounts();
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        Account Customer = Customers[0];
        Contact Contact = Contacts[0]; 
        wrapper.quantity_s = quantity_s;
        
        String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
        String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
        ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
        if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
        
        String PricebookId = Profiling.Price_Book__c;
        Date todays = system.today();
        String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
        UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
        String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ',Product2.Track_Inventory__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Allow_Pre_Orders__c, Product2.ERP7__Is_Asset__c from PricebookEntry where IsActive = true and Pricebook2Id = :PricebookId and Product2Id = :itemId Limit 1'; // and ERP7__Start_Date__c <= :todays and ERP7__End_Date__c >= :todays
        PricebookEntry priceBookEntry = new PricebookEntry();
        if(Schema.sObjectType.PricebookEntry.isAccessible()){
        priceBookEntry = Database.query(querys);}
        List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
        List < ERP7__Stock_Inward_Line_Item__c > SDLIs = new List< ERP7__Stock_Inward_Line_Item__c > ();
        WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c,
                                            product__c, Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c, 
                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                            From Inventory_Stock__c
                                            Where product__c = : ItemId And
                                            Active__c = true And
                                           // Organisation__c = : currentSalepoint.Organisation__c And
                                           // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                                            //Warehouse__c In: siteIds And
                                            Number_of_Item_In_Stock__c > 0
                                           ];
                                           
        SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Available__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                       Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c
                       From ERP7__Stock_Inward_Line_Item__c 
                       Where ERP7__Fixed_Asset__r.ERP7__Product__c = :ItemId And 
                       ERP7__Serial__c != Null And 
                       ERP7__Fixed_Asset__r.ERP7__Available__c = true And
                       (ERP7__Fixed_Asset__r.ERP7__Is_Reserved__c = false Or (ERP7__Fixed_Asset__r.ERP7__Is_Reserved__c = true And ERP7__Fixed_Asset__r.Account__c = :Customer.Id)) And
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 
                       //ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds
                       ];
        List<Id> selIds = new List<Id>();
        for(ERP7__Stock_Inward_Line_Item__c SOLI : SDLIs) selIds.add(SOLI.ERP7__Serial__c); 
        
        String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
        allFields += ' , ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';
        String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :selIds And ERP7__Asset__r.ERP7__Product__c =: ItemId And ERP7__Asset__r.ERP7__Available__c = true And ERP7__Available__c = true '; // And ERP7__Warehouse__c In :siteIds  
        List<ERP7__Serial_Number__c> SerialNos = Database.query(query);
        Decimal myStock = 0;
        if(SerialNos.size() > 0) myStock = SerialNos.size();
        else {
            for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                if(Version == '' || (Version != '' && Version == WIIS.ERP7__Version__c)) myStock += WIIS.Number_of_Item_In_Stock__c;
            }
        }
        List < SelectOptions > options = new List < SelectOptions > ();
        options.add(new SelectOptions('--None--', ''));
        
        if(!priceBookEntry.Product2.ERP7__Is_Asset__c && wrapper.quantity_s > myStock && priceBookEntry.Product2.Track_Inventory__c && !priceBookEntry.Product2.ERP7__Allow_Back_Orders__c && !priceBookEntry.Product2.ERP7__Allow_Pre_Orders__c) wrapper.quantity_s = myStock;
        
        List < Tier_Discount_Allocation__c > TDAS;
        if(Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Price_Book__c,
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                  From Tier_Discount_Allocation__c
                  Where ERP7__Order_Profile__c = : Profiling.Id And
                 // Organisation__c = : currentSalepoint.Organisation__c And
                //  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                  product__c = : itemId And
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
                if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null){
                    if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) wrapper.DiscountPercent = TDA.Discount_Plan__r.Default_Discount_Percentage__c;
                    if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null)wrapper.minDiscountPercent = TDA.Discount_Plan__r.Floor_Discount_Percentage__c;
                    if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null)wrapper.maxDiscountPercent = TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c;
                    wrapper.isPercent = true;
                }
                else if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null){
                    if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null) wrapper.DiscountPercent = TDA.Discount_Plan__r.Default_Discount_Value__c;  if(TDA.Discount_Plan__r.Floor_Discount_Value__c != Null)wrapper.minDiscountPercent = TDA.Discount_Plan__r.Floor_Discount_Value__c;  if(TDA.Discount_Plan__r.Ceiling_Discount_Value__c != Null)wrapper.maxDiscountPercent = TDA.Discount_Plan__r.Ceiling_Discount_Value__c;
                }
                defaultDiscountfound = true;
            }
        }
        if(!defaultDiscountfound) {  wrapper.DiscountPercent = 0;  wrapper.minDiscountPercent = null;  wrapper.maxDiscountPercent = null;  wrapper.discountName = '';  }
        for(Discount_Plan__c dis: discounts) {
            if(wrapper.discountName != String.valueof(dis.id)) options.add(new SelectOptions( dis.Name,dis.Id));
            else options.add(new SelectOptions(dis.Name,dis.Id));
        }
        wrapper.CurrentDiscounts = options;
        
        return Wrapper;
    }
    @AuraEnabled
    public static Discount_Plan__c discountPercent(String discountName) {
        Discount_Plan__c discount;
        if(Schema.sObjectType.Discount_Plan__c.isAccessible() && discountName instanceOf Id) discount = [Select id, Name, ERP7__Active__c, ERP7__Ceiling_Discount_Percentage__c, ERP7__Default_Discount_Percentage__c, ERP7__Description__c, ERP7__Floor_Discount_Percentage__c, ERP7__Ceiling_Discount_Value__c, ERP7__Default_Discount_Value__c, ERP7__Floor_Discount_Value__c,
                         Organisation__c, Organisation_Business_Unit__c, Status__c
                         From Discount_Plan__c
                         Where Id = : discountName And
                         Active__c = True
                        ];
        return discount;
    }
    
    @AuraEnabled
    public static returnClass VersionsChange(String currentSalepoints1, String SOP, String Version) {
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        returnClass RC = new returnClass();
            Decimal Stock = 0;
            ERP7__Channel__c currentSalepoint = currentSalepoints[0];
            ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
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
                    
            String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
            if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
            List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c >();
            if(Version != ''){
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                 Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,
                                                 Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                 From Inventory_Stock__c
                                                 Where Active__c = true And
                                                 Warehouse__c In: siteIds And
                                                 Number_of_Item_In_Stock__c > 0 And
                                                 ERP7__Version__c = :Version
                                                ];
            } else{
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                 Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,
                                                 Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                 From Inventory_Stock__c
                                                 Where Active__c = true And
                                                 Warehouse__c In: siteIds And
                                                 Number_of_Item_In_Stock__c > 0
                                                ];
            }
            for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {   Stock += WIIS.Number_of_Item_In_Stock__c;  }
            RC.value = String.valueof(Stock);
        return RC;
    }
    
    @AuraEnabled
    public static ProductsAndDiscounts VersionsChanged(String itemId, Decimal quants, String discountId, Decimal discount, String currentSalepoints1, Boolean isBackorder,String Customers1, String Contacts1, String SOP, String Version) {
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        Account Customer = Customers[0];
        Contact Contact = Contacts[0];
        List < ProductsAndDiscounts > PDWL = new List < ProductsAndDiscounts > ();
        //try {  
        List < Id > productIds = new List < Id > ();
        
        String OrgnPSA = currentSalepoint.Organisation__c;
        String OrgnBusIdPSA = currentSalepoint.Organisation_Business_Unit__c;
        String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
        
        String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
        ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
        if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
                
        List < Distribution_Channel__c > DistributionChannels = new List < Distribution_Channel__c > ();
        if(Schema.sObjectType.Distribution_Channel__c.isAccessible()) {
            DistributionChannels = [Select Id, Name, Active__c, Channel__c, Site__c
                                        From Distribution_Channel__c
                                        Where Channel__c = : currentSalepoint.Id And Active__c = true];
        }
        List < Id > siteIds = new List < Id > ();
        if(DistributionChannels.size() > 0) {
            for(Distribution_Channel__c DC: DistributionChannels) {
                siteIds.add(DC.Site__c);
            }
        }
        String PricebookId = Profiling.Price_Book__c;
        List<ERP7__Version__c> Versions = new List<ERP7__Version__c>();
        if(Version != ''){
            Versions = [Select Id, Name, ERP7__Active__c, ERP7__Asset__c, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Picture__c,
                            ERP7__Preview_Image__c, ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Ready__c, ERP7__Start_Date__c, ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c    
                            From ERP7__Version__c
                            Where ERP7__Active__c = true And
                            ERP7__Price_Book__c != Null And
                            //Profiling.ERP7__Account_Profile__c And 
                            ERP7__Sales_Ready__c = true And 
                            ERP7__Product__c = : itemId And
                            Id =: Version];
                                            
            if(Versions.size() > 0) PricebookId = Versions[0].Price_Book__c;
        }
        Date todays = system.today();
        String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
        UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
        //allFieldss += ', Product2Id, Pricebook2Id';
        String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ',Product2.Track_Inventory__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Allow_Pre_Orders__c from PricebookEntry where IsActive = true and Pricebook2Id = :PricebookId and Product2Id = :itemId'; // and ERP7__Start_Date__c <= :todays and ERP7__End_Date__c >= :todays
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        if(Schema.sObjectType.PricebookEntry.isAccessible()){
        priceBookEntries = Database.query(querys);}
        Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
        for(PricebookEntry IPE: priceBookEntries) {
            productIds.add(IPE.Product2Id);
            productPriceBookMap.put(IPE.Product2Id, IPE);
        }
        
        
        productIds = new List < Id > ();
        productIds.add(itemId);
        List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
        if(productIds.size() > 0) {
            if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                 Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c, ERP7__Version__r.Name,
                                                 Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                 From Inventory_Stock__c
                                                 Where product__c =: itemId And
                                                 Active__c = true And
                                                 // Organisation__c = : currentSalepoint.Organisation__c And
                                                 // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                                                 Warehouse__c In: siteIds And
                                                 Number_of_Item_In_Stock__c > 0
                                                ];
        }
       
        List<ERP7__Asset__c> productAssets = [Select Id, Name, ERP7__Available__c, ERP7__Status__c, ERP7__Product__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Quantity__c From ERP7__Asset__c  Where ERP7__Product__c In :productIds And ERP7__Product__r.ERP7__Is_Asset__c = true And ERP7__Available__c = true];
        Map<Id, Decimal> assetCount = new Map<Id, Decimal>();
        for(Id pId: productIds) {
            Integer count = 0;
            for(ERP7__Asset__c Asset : productAssets){  if(pId == Asset.ERP7__Product__c) count++;  }
            assetCount.put(pId,count);
        }
            
        Map < Id, List < Inventory_Stock__c >> productWarehouses = new Map < Id, List < Inventory_Stock__c >> ();
        Map < Id, Decimal > productStock = new Map < Id, Decimal > ();
        List < Id > newProductIds = new List < Id > ();
        List <SelectOptions> verOptions = new List<SelectOptions>();
        for(Id pId: productIds) {
            List < Inventory_Stock__c > myWarehouses = new List < Inventory_Stock__c > ();
            Decimal myStock = 0;
            if(assetCount.containsKey(pId) && assetCount.get(pId) > 0){   myStock = assetCount.get(pId);
            }else{
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(Version == '' || (Version != '' && Version == WIIS.ERP7__Version__c)) {
                        myWarehouses.add(WIIS);
                        myStock += WIIS.Number_of_Item_In_Stock__c;
                        if(verOptions.size() == 0 && WIIS.ERP7__Version__c != Null) verOptions.add(new SelectOptions(WIIS.ERP7__Version__r.Name,WIIS.ERP7__Version__c));
                    }
                }
            }
            if(!productPriceBookMap.get(PId).Product2.Track_Inventory__c) { // || !productPriceBookMap.get(PId).Product2.ERP7__Allow_Back_Orders__c || !productPriceBookMap.get(PId).Product2.ERP7__Allow_Pre_Orders__c
                newProductIds.add(PId);  if(assetCount.containsKey(pId) && assetCount.get(pId) > 0){  productStock.put(PId, myStock);  }
            } else if(myStock >= 0) {
                newProductIds.add(PId);
                productWarehouses.put(PId, myWarehouses);
                productStock.put(PId, myStock);
            }
        }
        List < product2 > allProducts = new List < product2 > ();
        /*if(Schema.sObjectType.product2.isAccessible()) allProducts = [Select id, Name, IsActive, Barcode__c, Category__c, Description__c, Expiration_Date__c, Invoiceable__c, SKU__c, Item_Description__c,
                  Item_Type__c, Item_Unit__c, Item_Unit_Value__c, Picture__c, Sub_Category__c, Transactable__c, Family,
                  Organisation__c, Organisation_Business_Unit__c, Track_Inventory__c
                  From Product2
                  Where id In: newProductIds And
                  IsActive = true And
                  Organisation__c = : currentSalepoint.Organisation__c And
                  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                  Limit 1
              ];
        */
        String allFieldsProduct2 = UtilClass.selectStarFromSObject('Product2');
        //String queryProduct2 = 'select ' + allFieldsProduct2 + ' from Product2 where Id In: newProductIds And IsActive = true And Organisation__c = : OrgnPSA And Organisation_Business_Unit__c = : OrgnBusIdPSA Limit 1';
        String queryProduct2 = 'select ' + String.escapeSingleQuotes(allFieldsProduct2) + ' from Product2 where Id In: newProductIds And IsActive = true Limit 1';
     
        if(Schema.sObjectType.Product2.isAccessible()) allProducts = Database.query(queryProduct2);
        
        Decimal currentQuantity = quants;
        List < String > prodIds = new List < String > ();
        for(product2 product: allProducts) {
            prodIds.add(product.Id);
        }
        List < Tier_Discount_Allocation__c > TDAS;
        if(Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Price_Book__c,
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
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
        if(Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c, Ceiling_Discount_Value__c, Default_Discount_Value__c, Floor_Discount_Value__c,
                Organisation__c, Organisation_Business_Unit__c, Status__c
                From Discount_Plan__c
                Where Id In: discountPlanIds And
                Active__c = True
            ];
        for(Discount_Plan__c dis: discounts) {
            discountMap.put(dis.id, dis);
        }
        Map < Id, List < Discount_Plan__c >> discountPlans = new Map < Id, List < Discount_Plan__c >> ();
        Map < Id, Id > defaultDiscountMap = new Map < Id, Id > ();
        Map < Id, Decimal > defaultDiscountPercentMap = new Map < Id, Decimal > ();
        Map < Id, Decimal > defaultDiscountPercentMapMin = new Map < Id, Decimal > ();
        Map < Id, Decimal > defaultDiscountPercentMapMax = new Map < Id, Decimal > ();
        for(product2 product: allProducts) {
            List < Discount_Plan__c > myDiscountPlans = new List < Discount_Plan__c > ();
            Boolean defaultDiscountfound = false;
            for(Tier_Discount_Allocation__c TDA: TDAS) {
                if(product.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                    myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                    if(discountId instanceOf Id && discountId != '' && TDA.Discount_Plan__c == discountId && !defaultDiscountfound) {
                        defaultDiscountMap.put(product.Id, TDA.Discount_Plan__c);
                        defaultDiscountfound = true;
                        if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null){
                            if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c);
                        }
                        else if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null){
                            if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Value__c);  if(TDA.Discount_Plan__r.Floor_Discount_Value__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Value__c);  if(TDA.Discount_Plan__r.Ceiling_Discount_Value__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Value__c);
                        }
                    }
                }
            }
            discountPlans.put(product.id, myDiscountPlans);
        }
        ProductsAndDiscounts PDs = new ProductsAndDiscounts();
        for(Product2 product: allProducts) {
            PDs.product = product;
            List < SelectOptions > options = new List < SelectOptions > ();
            options.add(new SelectOptions('--None--', ''));
            if(discountPlans.get(product.id) != null) {
                for(Discount_Plan__c dis: discountPlans.get(product.id)) {
                    options.add(new SelectOptions(dis.Name, dis.id));
                    if(defaultDiscountMap.containsKey(product.Id) && dis.Id == defaultDiscountMap.get(product.Id) && dis.ERP7__Default_Discount_Percentage__c != Null) PDs.isPercent = true;
                }
            }
            
            PDs.pricebookEntry = productPriceBookMap.get(product.id);
            //(productStock.get(product.Id) < currentQuantity)? productStock.get(product.Id) : currentQuantity
            PDs.quantity_s = currentQuantity;
            if(defaultDiscountMap.containsKey(product.Id)) PDs.discountName = defaultDiscountMap.get(product.Id);
            else PDs.discountName = '';
            PDs.CurrentDiscounts = options;
            PDs.discountPercent = discount;
            if(defaultDiscountPercentMapMin.containsKey(product.Id)) PDs.minDiscountPercent = defaultDiscountPercentMapMin.get(product.Id);
            if(defaultDiscountPercentMapMax.containsKey(product.Id)) PDs.maxDiscountPercent = defaultDiscountPercentMapMax.get(product.Id);
            PDS.trackInventory = PDs.pricebookEntry.Product2.Track_Inventory__c;
            PDS.checkOutProcess = PDs.pricebookEntry.ERP7__Check_Out_Process__c;
            PDs.moq = PDs.product.ERP7__MOQ__c;
            PDs.stock = productStock.get(product.Id);
            PDs.Version = Version;
            PDs.Versions = verOptions;
            break;
            //PDWL.add(PDs);
        }
        
        return PDs;
    }
    
    @AuraEnabled
    public static List < Object > editProducts(String itemId, Decimal quants, String discountId, Decimal discount, String currentSalepoints1, Boolean isBackorder, String Customers1, String Contacts1, String SOP, String Version) {
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        Account Customer = Customers[0];
        Contact Contact = Contacts[0];
        List < ProductsAndDiscounts > PDWL = new List < ProductsAndDiscounts > ();
        //try {  
        List < Id > productIds = new List < Id > ();
        
        String OrgnPSA = currentSalepoint.Organisation__c;
        String OrgnBusIdPSA = currentSalepoint.Organisation_Business_Unit__c;
        String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
        
        String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
        ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
        if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
        
        List < Distribution_Channel__c > DistributionChannels = new List < Distribution_Channel__c > ();
        if(Schema.sObjectType.Distribution_Channel__c.isAccessible()) {
            DistributionChannels = [Select Id, Name, Active__c, Channel__c, Site__c
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
        String PricebookId = Profiling.Price_Book__c;
        List<ERP7__Version__c> Versions = new List<ERP7__Version__c>();
        if(Version != ''){
            Versions = [Select Id, Name, ERP7__Active__c, ERP7__Asset__c, ERP7__Barcode__c, ERP7__Category__c, ERP7__Default__c, ERP7__Description__c, ERP7__Inventory_Stock__c, ERP7__Picture__c,
                            ERP7__Preview_Image__c, ERP7__Price_Book__c, ERP7__Process__c, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Ready__c, ERP7__Start_Date__c, ERP7__Status__c, ERP7__Subscription__c, ERP7__To_Date__c, ERP7__Type__c, ERP7__Unit_of_Measure__c    
                            From ERP7__Version__c
                            Where ERP7__Active__c = true And
                            ERP7__Price_Book__c != Null And
                            //Profiling.ERP7__Account_Profile__c And 
                            ERP7__Sales_Ready__c = true And 
                            ERP7__Product__c = : itemId And
                            Id =: Version];
                                            
            if(Versions.size() > 0) PricebookId = Versions[0].Price_Book__c;
        }
        Date todays = system.today();
        String allFieldss = UtilClass.selectStarFromSObject('PricebookEntry');
        UtilClass.FlSCheck(allFieldss.split(',') ,'PricebookEntry');
        //allFieldss += ', Product2Id, Pricebook2Id';
        String querys = 'select ' + String.escapeSingleQuotes(allFieldss) + ',Product2.Track_Inventory__c, Product2.ERP7__Allow_Back_Orders__c, Product2.ERP7__Allow_Pre_Orders__c from PricebookEntry where IsActive = true and Pricebook2Id = :PricebookId and Product2Id = :itemId'; // and ERP7__Start_Date__c <= :todays and ERP7__End_Date__c >= :todays
        List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();
        if(Schema.sObjectType.PricebookEntry.isAccessible()){
        priceBookEntries = Database.query(querys);}
        Map < Id, PricebookEntry > productPriceBookMap = new map < Id, PricebookEntry > ();
        for(PricebookEntry IPE: priceBookEntries) {
            productIds.add(IPE.Product2Id);
            productPriceBookMap.put(IPE.Product2Id, IPE);
        }
        
        
        productIds = new List < Id > ();
        productIds.add(itemId);
        List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
        if(productIds.size() > 0) {
            if(Schema.sObjectType.Inventory_Stock__c.isAccessible()) WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                 Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c, ERP7__Version__r.Name,
                                                 Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                 From Inventory_Stock__c
                                                 Where product__c =: itemId And
                                                 Active__c = true And
                                                // Organisation__c = : currentSalepoint.Organisation__c And
                                                // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
                                                 Warehouse__c In: siteIds And
                                                 Number_of_Item_In_Stock__c > 0
                                                ];
        }
       
        List<ERP7__Asset__c> productAssets = [Select Id, Name, ERP7__Available__c, ERP7__Status__c, ERP7__Product__c, ERP7__Product__r.ERP7__Is_Asset__c, ERP7__Quantity__c From ERP7__Asset__c  Where ERP7__Product__c In :productIds And ERP7__Product__r.ERP7__Is_Asset__c = true And ERP7__Available__c = true];
        Map<Id, Decimal> assetCount = new Map<Id, Decimal>();
        for(Id pId: productIds) {
            Integer count = 0;
            for(ERP7__Asset__c Asset : productAssets){   if(pId == Asset.ERP7__Product__c) count++;  }
            assetCount.put(pId,count);
        }
            
        Map < Id, List < Inventory_Stock__c >> productWarehouses = new Map < Id, List < Inventory_Stock__c >> ();
        Map < Id, Decimal > productStock = new Map < Id, Decimal > ();
        List < Id > newProductIds = new List < Id > ();
        List <SelectOptions> verOptions = new List<SelectOptions>();
        for(Id pId: productIds) {
            List < Inventory_Stock__c > myWarehouses = new List < Inventory_Stock__c > ();
            Decimal myStock = 0;
            if(assetCount.containsKey(pId) && assetCount.get(pId) > 0){   myStock = assetCount.get(pId);
            }else{
                for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                    if(Version == '' || (Version != '' && Version == WIIS.ERP7__Version__c)) {
                        myWarehouses.add(WIIS);
                        myStock += WIIS.Number_of_Item_In_Stock__c;
                        if(verOptions.size() == 0 && WIIS.ERP7__Version__c != Null) verOptions.add(new SelectOptions(WIIS.ERP7__Version__r.Name,WIIS.ERP7__Version__c));
                    }
                }
            }
            if(!productPriceBookMap.get(PId).Product2.Track_Inventory__c) { // || !productPriceBookMap.get(PId).Product2.ERP7__Allow_Back_Orders__c || !productPriceBookMap.get(PId).Product2.ERP7__Allow_Pre_Orders__c
                newProductIds.add(PId);   if(assetCount.containsKey(pId) && assetCount.get(pId) > 0){  productStock.put(PId, myStock);  }
            } else if(myStock >= 0) {
                newProductIds.add(PId);
                productWarehouses.put(PId, myWarehouses);
                productStock.put(PId, myStock);
            }
        }
        List < product2 > allProducts = new List < product2 > ();
        /*if(Schema.sObjectType.product2.isAccessible()) allProducts = [Select id, Name, IsActive, Barcode__c, Category__c, Description__c, Expiration_Date__c, Invoiceable__c, SKU__c, Item_Description__c,
                  Item_Type__c, Item_Unit__c, Item_Unit_Value__c, Picture__c, Sub_Category__c, Transactable__c, Family,
                  Organisation__c, Organisation_Business_Unit__c, Track_Inventory__c
                  From Product2
                  Where id In: newProductIds And
                  IsActive = true And
                  Organisation__c = : currentSalepoint.Organisation__c And
                  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                  Limit 1
              ];
        */
        String allFieldsProduct2 = UtilClass.selectStarFromSObject('Product2');
     //   String queryProduct2 = 'select ' + allFieldsProduct2 + ' from Product2 where Id In: newProductIds And IsActive = true And Organisation__c = : OrgnPSA And Organisation_Business_Unit__c = : OrgnBusIdPSA Limit 1';
          String queryProduct2 = 'select ' + String.escapeSingleQuotes(allFieldsProduct2) + ' from Product2 where Id In: newProductIds And IsActive = true Limit 1';
     
        if(Schema.sObjectType.Product2.isAccessible()) allProducts = Database.query(queryProduct2);
        
        Decimal currentQuantity = quants;
        List < String > prodIds = new List < String > ();
        for(product2 product: allProducts) {
            prodIds.add(product.Id);
        }
        List < Tier_Discount_Allocation__c > TDAS;
        if(Schema.sObjectType.Tier_Discount_Allocation__c.isAccessible()) TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Price_Book__c,
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                From Tier_Discount_Allocation__c
                Where ERP7__Order_Profile__c = : Profiling.Id And
              //  Organisation__c = : currentSalepoint.Organisation__c And
              //  Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
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
        if(Schema.sObjectType.Discount_Plan__c.isAccessible()) discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c, Ceiling_Discount_Value__c, Default_Discount_Value__c, Floor_Discount_Value__c,
                Organisation__c, Organisation_Business_Unit__c, Status__c
                From Discount_Plan__c
                Where Id In: discountPlanIds And
                Active__c = True
            ];
        for(Discount_Plan__c dis: discounts) {
            discountMap.put(dis.id, dis);
        }
        Map < Id, List < Discount_Plan__c >> discountPlans = new Map < Id, List < Discount_Plan__c >> ();
        Map < Id, Id > defaultDiscountMap = new Map < Id, Id > ();
        Map < Id, Decimal > defaultDiscountPercentMap = new Map < Id, Decimal > ();
        Map < Id, Decimal > defaultDiscountPercentMapMin = new Map < Id, Decimal > ();
        Map < Id, Decimal > defaultDiscountPercentMapMax = new Map < Id, Decimal > ();
        for(product2 product: allProducts) {
            Set < Discount_Plan__c > myDiscountPlans = new Set < Discount_Plan__c > ();
            Boolean defaultDiscountfound = false;
            for(Tier_Discount_Allocation__c TDA: TDAS) {
                if(product.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                    myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                    if(discountId instanceOf Id && discountId != '' && TDA.Discount_Plan__c == discountId && !defaultDiscountfound) {
                        defaultDiscountMap.put(product.Id, TDA.Discount_Plan__c);
                        defaultDiscountfound = true;
                        if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null){
                            if(TDA.Discount_Plan__r.Default_Discount_Percentage__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Floor_Discount_Percentage__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Percentage__c);
                            if(TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Percentage__c);
                        }
                        else if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null){
                            if(TDA.Discount_Plan__r.Default_Discount_Value__c != Null) defaultDiscountPercentMap.put(product.Id, TDA.Discount_Plan__r.Default_Discount_Value__c);  if(TDA.Discount_Plan__r.Floor_Discount_Value__c != Null) defaultDiscountPercentMapMin.put(product.Id, TDA.Discount_Plan__r.Floor_Discount_Value__c);   if(TDA.Discount_Plan__r.Ceiling_Discount_Value__c != Null) defaultDiscountPercentMapMax.put(product.Id, TDA.Discount_Plan__r.Ceiling_Discount_Value__c);
                        }
                    }
                }
            }
            List<Discount_Plan__c> myDiscountPlansList = new List<Discount_Plan__c>();
            myDiscountPlansList.addAll(myDiscountPlans);
            discountPlans.put(product.id, myDiscountPlansList);
        }
        for(Product2 product: allProducts) {
            ProductsAndDiscounts PDs = new ProductsAndDiscounts();
            PDs.product = product;
            List < SelectOptions > options = new List < SelectOptions > ();
            options.add(new SelectOptions('--None--', ''));
            if(discountPlans.get(product.id) != null) {
                for(Discount_Plan__c dis: discountPlans.get(product.id)) {
                    options.add(new SelectOptions(dis.Name, dis.id));
                    if(defaultDiscountMap.containsKey(product.Id) && dis.Id == defaultDiscountMap.get(product.Id) && dis.ERP7__Default_Discount_Percentage__c != Null) PDs.isPercent = true;
                }
            }
            
            PDs.pricebookEntry = productPriceBookMap.get(product.id);
            if(PDs.pricebookEntry.ERP7__Purchase_Price__c != Null) PDs.costprice = PDs.pricebookEntry.ERP7__Purchase_Price__c * PDs.quantity_s;
            //(productStock.get(product.Id) < currentQuantity)? productStock.get(product.Id) : currentQuantity
            PDs.quantity_s = currentQuantity;
            if(defaultDiscountMap.containsKey(product.Id)) PDs.discountName = defaultDiscountMap.get(product.Id);
            else PDs.discountName = '';
            PDs.CurrentDiscounts = options;
            PDs.discountPercent = discount;
            if(defaultDiscountPercentMapMin.containsKey(product.Id)) PDs.minDiscountPercent = defaultDiscountPercentMapMin.get(product.Id);
            if(defaultDiscountPercentMapMax.containsKey(product.Id)) PDs.maxDiscountPercent = defaultDiscountPercentMapMax.get(product.Id);
            PDS.trackInventory = PDs.pricebookEntry.Product2.Track_Inventory__c;
            PDS.checkOutProcess = PDs.pricebookEntry.ERP7__Check_Out_Process__c;
            PDs.moq = PDs.product.ERP7__MOQ__c;
            PDs.stock = productStock.get(product.Id);
            PDs.Version = Version;
            PDs.Versions = verOptions;
            PDWL.add(PDs);
        }
        
        return PDWL;
    }
     @AuraEnabled
    //@Deprecated
    public static List < itemWrapper > addProducts(String selWrap, String currentSalepoints1, String Customers1, String Contacts1, String SOP) {
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        return null;
    }
    
    @AuraEnabled
    public  static returnClass deleteSerials(List<Id> Serials2Delete, String SalesOrder2Creates) {    
        returnClass RC = new returnClass();
        try{
            ERP7__Sales_Order__c SalesOrder2Create = (ERP7__Sales_Order__c) JSON.deserialize(SalesOrder2Creates, ERP7__Sales_Order__c .class);
            if(Serials2Delete.size() > 0 && SalesOrder2Create.Id != Null) {
                List < ERP7__Stock_Outward_Line_Item__c > StockOutwards2Delete = [Select Id, Name, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Fixed_Asset__c from ERP7__Stock_Outward_Line_Item__c where ERP7__Serial__c In: Serials2Delete and ERP7__Sales_Order__c =: SalesOrder2Create.Id];
                if(StockOutwards2Delete.size() > 0 && ERP7__Stock_Outward_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete StockOutwards2Delete;
                List<Id> AssetsIds = new List<Id>();
                for(ERP7__Stock_Outward_Line_Item__c SOLI : StockOutwards2Delete) {   if(SOLI.ERP7__Fixed_Asset__c != Null) AssetsIds.add(SOLI.ERP7__Fixed_Asset__c);  } 
                List<ERP7__Asset__c> assets2Update = [Select Id, Name, ERP7__Available__c, ERP7__Status__c From ERP7__Asset__c  Where Id In :AssetsIds];
                for(ERP7__Asset__c Asset : assets2Update){  Asset.ERP7__Available__c = true;   Asset.ERP7__Status__c = 'Available';  }
                if(assets2Update.size() > 0 && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isUpdateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Status__c.isUpdateable()) {update assets2Update;}else{RC.Error = true; RC.errorMsg ='Not allowed to update Asset or Assert not available';}
            }
            return RC;
        } catch(DmlException e) { RC.Error = true; RC.errorMsg = e.getdmlMessage(0); RC.Value = ''; return RC; }
    }
    
    @AuraEnabled
    public  static List < itemWrapper > addProducts2(String selWrap, String currentSalepoints1, String Customers1, String Contacts1, String SOP,Decimal TaxRate, List<Id> Serials2Delete, String SalesOrder2Creates, String BA, String SA) {    
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        ERP7__Sales_Order__c SalesOrder2Create = (ERP7__Sales_Order__c) JSON.deserialize(SalesOrder2Creates, ERP7__Sales_Order__c .class);
        Account Customer = Customers[0];
        Contact Contact = Contacts[0];
        List < ProductsAndDiscounts > deserializedList = (List < ProductsAndDiscounts > ) JSON.deserialize(selWrap, List < ProductsAndDiscounts > .class);
        Id currentConId = Contact.Id;
        List < Id > myProductIds = new List < Id > ();
        Map < Id, pricebookEntry > productPricebook = new Map < Id, pricebookEntry > ();
        Decimal subTotal = 0.00;
        Decimal totalDiscount = 0.00;
        Decimal totalDue = 0.00;
        Decimal totalTax = 0.00;
        Decimal finalDue = 0.00;
        Date todayDate = System.Today();
        List < ProductsAndDiscounts > selectedPandDwrapperList = new List < ProductsAndDiscounts > ();
        List<ERP7__Serial_Number__c> SerialNos = new List<ERP7__Serial_Number__c>();
        List < Id > AssetProdIds = new List < Id > ();
        List < Id > serProdIds = new List < Id > ();
        Map<Id, ERP7__Serial_Number__c> mySL = new Map<Id, ERP7__Serial_Number__c>();
        List < Id > siteIds = new List < Id > ();
        List < Distribution_Channel__c > DistributionChannels = new List < Distribution_Channel__c > ();
        for(ProductsAndDiscounts currentPd: deserializedList) {
            myProductIds.add(currentPd.product.Id);
            selectedPandDwrapperList.add(currentPd);
            if(currentPd.product.ERP7__Serialise__c && !currentPd.product.ERP7__Is_Asset__c && currentPd.SerialNos.size() == 0) serProdIds.add(currentPd.product.Id);
            if(currentPd.product.ERP7__Is_Asset__c == true && currentPd.stock > 0) AssetProdIds.add(currentPd.product.Id);
        }
        DistributionChannels = [Select Id, Name, Active__c,  Channel__c, Site__c
                                    From Distribution_Channel__c
                                    Where Channel__c = : currentSalepoint.Id And Active__c = true];
                                    
        if(DistributionChannels.size() > 0) {
            for(Distribution_Channel__c DC: DistributionChannels) {
                siteIds.add(DC.Site__c);
            }
        }
        if(AssetProdIds.size() > 0 && siteIds.size() > 0){
            List<ERP7__Stock_Inward_Line_Item__c> SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Available__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                       Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c
                       From ERP7__Stock_Inward_Line_Item__c 
                       Where ERP7__Fixed_Asset__r.ERP7__Product__c = :AssetProdIds And 
                       ERP7__Serial__c != Null And 
                       ERP7__Fixed_Asset__r.ERP7__Available__c = true And
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds];
            List<Id> selIds = new List<Id>();
            for(ERP7__Stock_Inward_Line_Item__c SOLI : SDLIs) selIds.add(SOLI.ERP7__Serial__c); 
            String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
            allFields += ' , ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :selIds And ERP7__Asset__r.ERP7__Product__c In :AssetProdIds And ERP7__Asset__r.ERP7__Available__c = true And ERP7__Available__c = true'; // And ERP7__Warehouse__c In :siteIds
            SerialNos = Database.query(query);
            
            for(ERP7__Serial_Number__c SN : SerialNos) mySL.put(SN.ERP7__Asset__r.ERP7__Product__c, SN);
        }
        if(serProdIds.size() > 0 && siteIds.size() > 0){
            List<ERP7__Stock_Inward_Line_Item__c> SDLIs = [Select Id, Name, Active__c, ERP7__Fixed_Asset__c, ERP7__Fixed_Asset__r.ERP7__Available__c, ERP7__Fixed_Asset__r.ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Serial__c, ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c, Batch_Lot_Code__c,
                       Product__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c, ERP7__Sales_Order_Line_Item__c
                       From ERP7__Stock_Inward_Line_Item__c 
                       Where ERP7__Product__c = :serProdIds And 
                       ERP7__Serial__c != Null And 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0 And 
                       ERP7__Site_ProductService_InventoryStock__r.ERP7__Warehouse__c In : siteIds];
            
            List<Id> selIds = new List<Id>();
            for(ERP7__Stock_Inward_Line_Item__c SOLI : SDLIs) selIds.add(SOLI.ERP7__Serial__c); 
            String allFields = UtilClass.selectStarFromSObject('ERP7__Serial_Number__c');
            allFields += ' , ERP7__Warehouse__r.Name, ERP7__Asset__r.ERP7__Product__c, ERP7__Asset__r.ERP7__Available__c, ERP7__Asset__r.ERP7__Is_Reserved__c, ERP7__Asset__r.Name, ERP7__Asset__r.ERP7__Picture__c, ERP7__Asset__r.ERP7__Status__c ';
            String query = 'select ' + String.escapeSingleQuotes(allFields) + ' from ERP7__Serial_Number__c where Id In :selIds And ERP7__Product__c In :serProdIds And ERP7__Available__c = true'; // And ERP7__Warehouse__c In :siteIds
            SerialNos = Database.query(query);
            
            for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
                if(currentPd.product.ERP7__Serialise__c && !currentPd.product.ERP7__Is_Asset__c && currentPd.SerialNos.size() == 0){
                    Integer quan = Integer.valueof(currentPd.quantity_s);
                    for(ERP7__Serial_Number__c SN : SerialNos) {
                        if(SN.ERP7__Product__c == currentPd.product.Id && quan > 0) {  currentPd.SerialNos.add(SN);  quan--;  }
                        if(quan == 0) break;
                    }
                }
            }
        }
        String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
        String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ',ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c from Profiling__c where Id = :SOP';
        ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
        if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
        
        
        Map<Id, ERP7__Tax__c> productTax = new Map<Id, ERP7__Tax__c>();
        List<ERP7__Tax__c> NormalTax = new List<ERP7__Tax__c>();
        List<ERP7__Tax__c> PostalCodeTax = new List<ERP7__Tax__c>();
        List<ERP7__Tax__c> CityTax = new List<ERP7__Tax__c>();
        List<ERP7__Tax__c> CountryAndProvinceTax = new List<ERP7__Tax__c>();
        List<ERP7__Tax__c> CountryTax = new List<ERP7__Tax__c>();
        List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
        Decimal profileVatRate = 0;
        if(Profiling.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' || Profiling.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination'){
            List< ERP7__Address__c > Baddress = [Select Id, Name, ERP7__Postal_Code__c, ERP7__City__c, ERP7__State__c, ERP7__Country__c From ERP7__Address__c Where Id =: BA];
            List< ERP7__Address__c > Saddress = [Select Id, Name, ERP7__Postal_Code__c, ERP7__City__c, ERP7__State__c, ERP7__Country__c From ERP7__Address__c Where Id =: SA];
            String accProfile = Profiling.ERP7__Account_Profile__c;
            String salestax = 'Sales Tax';
            String TaxPostalCode = '';
            String TaxCity = '';
            String TaxProvince = '';
            String TaxCountry = '';
            if(Profiling.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Origin' && Baddress.size() > 0){
                TaxPostalCode = Baddress[0].ERP7__Postal_Code__c;  TaxCity = Baddress[0].ERP7__City__c;  TaxProvince = Baddress[0].ERP7__State__c;   TaxCountry = Baddress[0].ERP7__Country__c;
            }
            if(Profiling.ERP7__Account_Profile__r.ERP7__Tax_Sourcing_Rules__c == 'Destination' && Saddress.size() > 0){
                TaxPostalCode = Saddress[0].ERP7__Postal_Code__c;
                TaxCity = Saddress[0].ERP7__City__c;
                TaxProvince = Saddress[0].ERP7__State__c;
                TaxCountry = Saddress[0].ERP7__Country__c;
            }
            
            String allFieldsTaxes = UtilClass.selectStarFromSObject('ERP7__Tax__c');
            String queryTaxes = 'select ' + String.escapeSingleQuotes(allFieldsTaxes) + ' from ERP7__Tax__c where ERP7__Account_Profile__c = :accProfile and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c = Null ';
            
            if(Schema.sObjectType.ERP7__Tax__c.isAccessible()) profileTax = Database.query(queryTaxes);
            
            if(profileTax.size() > 0 && myProductIds.size() > 0){
                //Id taxId = profileTax[0].Id;
                for(ERP7__Tax__c tax : profileTax){
                    if((TaxPostalCode != Null && TaxPostalCode != '' && TaxCity != Null && TaxCity != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (tax.ERP7__Postal_Code__c == TaxPostalCode && tax.ERP7__City__c == TaxCity && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){
                        PostalCodeTax.add(Tax);
                    } // (TaxPostalCode == Null || TaxPostalCode == '') && 
                    if((TaxCity != Null && TaxCity != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && tax.ERP7__City__c == TaxCity && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){
                        CityTax.add(Tax);
                    } // (TaxPostalCode == Null || TaxPostalCode == '') && (TaxCity == Null || TaxCity == '') && 
                    if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){
                        CountryAndProvinceTax.add(Tax);
                    } // (TaxPostalCode == Null || TaxPostalCode == '') && (TaxCity == Null || TaxCity == '') && (TaxProvince == Null || TaxProvince == '') && 
                    if((TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && tax.ERP7__Country__c == TaxCountry)){
                        CountryTax.add(Tax);
                    } 
                    if((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && (tax.ERP7__Country__c == Null || tax.ERP7__Country__c == '')){
                        NormalTax.add(Tax);
                    } 
                }
                
                String queryTaxes1 = 'select ' + String.escapeSingleQuotes(allFieldsTaxes) + ' from ERP7__Tax__c where ERP7__Account_Profile__c = :accProfile and ERP7__Effective_Date__c <= :todayDate and ERP7__Expiry_Date__c >= :todayDate and ERP7__Type__c = :salestax And ERP7__Tax_Rate__c != Null And ERP7__Product__c In :myProductIds ';
                List<ERP7__Tax__c> productTaxes = Database.query(queryTaxes1);
                
                Boolean taxFound = false;
                
                for(Tax__c tax : productTaxes){
                    if((TaxPostalCode != Null && TaxPostalCode != '' && TaxCity != Null && TaxCity != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (tax.ERP7__Postal_Code__c == TaxPostalCode && tax.ERP7__City__c == TaxCity && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){  productTax.put(Tax.ERP7__Product__c, Tax);   taxFound = true;   break;  } 
                }
                if(!taxFound){
                    for(Tax__c tax : productTaxes){
                        //(TaxPostalCode == Null || TaxPostalCode == '') && 
                        if((TaxCity != Null && TaxCity != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && tax.ERP7__City__c == TaxCity && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){  productTax.put(Tax.ERP7__Product__c, Tax);   taxFound = true;  break;  } 
                    }
                }
                if(!taxFound){
                    for(Tax__c tax : productTaxes){
                        //(TaxPostalCode == Null || TaxPostalCode == '') && (TaxCity == Null || TaxCity == '') && 
                        if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && tax.ERP7__Province__c == TaxProvince && tax.ERP7__Country__c == TaxCountry)){  productTax.put(Tax.ERP7__Product__c, Tax);  taxFound = true;  break;  } 
                    }
                }
                if(!taxFound){
                    for(Tax__c tax : productTaxes){
                        //(TaxPostalCode == Null || TaxPostalCode == '') && (TaxCity == Null || TaxCity == '') && (TaxProvince == Null || TaxProvince == '') &&
                        if((TaxCountry != Null && TaxCountry != '') && ((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && tax.ERP7__Country__c == TaxCountry)){  productTax.put(Tax.ERP7__Product__c, Tax);  taxFound = true;  break;   }
                    }
                }
                if(!taxFound){
                    for(Tax__c tax : productTaxes){
                        if((tax.ERP7__Postal_Code__c == Null || tax.ERP7__Postal_Code__c == '') && (tax.ERP7__City__c == Null || tax.ERP7__City__c == '') && (tax.ERP7__Province__c == Null || tax.ERP7__Province__c == '') && (tax.ERP7__Country__c == Null || tax.ERP7__Country__c == '')){  productTax.put(Tax.ERP7__Product__c, Tax);  taxFound = true;  break;   }
                    }
                }
                
            }
            
        }
        
        
        List < itemWrapper > itemWrapperList = new List < itemWrapper > ();  
        List < Contact > Conts;
        if(Schema.sObjectType.Contact.isAccessible()) {
            Contacts = [Select id, Name, FirstName, LastName, Title, Email, AccountId, Phone, Contact_Numer__c From Contact Where Id = : currentConId Limit 1];
        }
        List < Loyalty_Card__c > clubCard = new List < Loyalty_Card__c > ();
        if(Contacts.size() > 0) {
            if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c,
                                Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                                Organisation__c, Organisation_Business_Unit__c
                                From Loyalty_Card__c Where
                                Customer__c = : Contacts[0].AccountId And
                                Customer__c != Null And
                                Active__c = true And
                                Status__c = 'Active' And
                                Start_date__c <= : todayDate And
                                Expiration_Date__c >= : todayDate And
                                Organisation__c = : currentSalepoint.Organisation__c //And
                               // Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                             ];
            }
        }
        List < Id > myAllProgs = new List < Id > ();
        if(clubCard.size() > 0) {
            for(Loyalty_Card__c lc: clubCard) {  if(lc.Loyalty_Program__c != Null) { myAllProgs.add(lc.Loyalty_Program__c);  }  }
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
            //Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c And
            product__c In: myProductIds And
            Commission_Plan__r.Status__c = 'Manager Approved' And
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
            for(Tier_Commission_Allocation__c tca: tierCommissions) {  if(currentPd.product.Id == tca.product__c) {  mytcas.add(tca);  }  }
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
                if(tca.Price_Book__c == crc.Price_Book__c && tca.Commission_Plan__c == crc.Commission_Plan__c) {  commissionRateCard.put(tca, crc);  }
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
            Order By Loyalty_Program__r.Priority__c Asc];
        }
        Map < Id, List < Loyalty_Point_Allocation__c >> loyaltyPointAllocs = new Map < Id, List < Loyalty_Point_Allocation__c >> ();
        for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
            List < Loyalty_Point_Allocation__c > mypoints = new List < Loyalty_Point_Allocation__c > ();
            for(Loyalty_Point_Allocation__c pta: loyaltyPointAllocation) {
                if(currentPd.product.Id == pta.product__c) {  mypoints.add(pta);  }
            }if(mypoints.size() > 0) {loyaltyPointAllocs.put(currentPd.product.Id, mypoints);
            }
        }
        //products Addition
        
        for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
            if(currentPd.quantity_s > 0) {
                itemWrapper Wrap = new itemWrapper();
                Wrap.lineitm.Explode__c = currentPd.explode;
                Wrap.trackInventory = currentPd.trackInventory;
                Wrap.checkoutprocess = currentPd.checkoutprocess;
                Wrap.code = currentPd.product.ProductCode;
                Wrap.itm = currentPd.product.Name;
                Wrap.itmId = currentPd.product.id;
                if(currentPd.SerialNos.size() > 0) Wrap.SerialNos = currentPd.SerialNos;
                if(currentPd.Batches.size() > 0) Wrap.Batches = currentPd.Batches;
                else if(mySL.containskey(currentPd.product.id)) Wrap.SerialNos.add(mySL.get(currentPd.product.id));
                Wrap.RentalUnit = currentPd.RentalUnit;
                Wrap.RentalUnits = currentPd.RentalUnits;
                Wrap.product = currentPd.product;
                Wrap.quantity_s = currentPd.quantity_s;
                Wrap.EndTime = currentPd.EndTime;
                
                if(currentPd.product.ERP7__Is_Kit__c){
                   // if(currentPd.product.ERP7__Allow_Back_Orders__c) Wrap.isbackOrder=true;
                    //else if(currentPd.product.ERP7__Allow_Pre_Orders__c) Wrap.ispreOrder=true; 
                      if(currentPd.trackInventory && currentPd.product.ERP7__Allow_Back_Orders__c && (currentPd.stock == null || currentPd.stock == 0.00 || currentPd.stock < currentPd.quantity_s)){
                        Wrap.isbackOrder=true;
                    }else if(currentPd.trackInventory && currentPd.product.ERP7__Allow_Pre_Orders__c && (currentPd.stock == null || currentPd.stock == 0.00 || currentPd.stock < currentPd.quantity_s) && currentPd.product.ERP7__Status__c.equals('In Development') || currentPd.product.ERP7__Status__c.equals('Certified')){
                        Wrap.ispreOrder=true;   
                    }
                }
                else{
                    if(currentPd.trackInventory && currentPd.product.ERP7__Allow_Back_Orders__c && (currentPd.stock == null || currentPd.stock == 0.00 || currentPd.stock < currentPd.quantity_s)){
                        Wrap.isbackOrder=true;
                    }else if(currentPd.trackInventory && currentPd.product.ERP7__Allow_Pre_Orders__c && (currentPd.stock == null || currentPd.stock == 0.00 || currentPd.stock < currentPd.quantity_s) && currentPd.product.ERP7__Status__c.equals('In Development') || currentPd.product.ERP7__Status__c.equals('Certified')){
                        Wrap.ispreOrder=true;   
                    }
                }
                Wrap.price = (currentPd.pricebookentry.UnitPrice != null)? (currentPd.pricebookentry.UnitPrice * currentPd.quantity_s).setScale(2) : 0.00;
                Wrap.prod_Desc = currentPd.product.Description;
                if(currentPd.pricebookentry.ERP7__Purchase_Price__c != Null) Wrap.costprice = currentPd.pricebookentry.ERP7__Purchase_Price__c * currentPd.quantity_s;
                Decimal currentDiscount = 0.00;
                
                if(currentPd.discountPercent >= 0) {
                    currentDiscount = (currentPd.isPercent)? (currentPd.discountPercent / 100) : currentPd.discountPercent;
                }
                if(currentPd.discountName != null && currentPd.discountName != '') { wrap.discountId = currentPd.discountName; }
                if(currentPd.discountPercent != null) { wrap.discountPercent = currentPd.discountPercent; }
                if(currentPd.isPercent) Wrap.discount = (currentDiscount * Wrap.price).setScale(2);
                else Wrap.discount = (currentDiscount * Wrap.quantity_s).setScale(2);
                List < Tier_Commission_Allocation__c > tierCommission;
                tierCommission = (productCommissions.get(currentPd.product.Id) != Null) ? productCommissions.get(currentPd.product.Id) : new List < Tier_Commission_Allocation__c > ();
                for(Tier_Commission_Allocation__c tc: tierCommission) {
                    Boolean comit = true;
                    if(tc.Tier__r.Floor_Unit__c <= currentPd.quantity_s && tc.Tier__r.Ceiling_Unit__c >= currentPd.quantity_s && comit == true && tc.ERP7__Price_Book__c == currentPd.priceBookEntry.PriceBook2Id) {
                        if(commissionRateCard.get(tc) != Null) {
                            comit = false;  List < Commission_Rate_Card__c > rateCard = new List < Commission_Rate_Card__c > ();
                            rateCard.add(commissionRateCard.get(tc));
                            if(rateCard.size() > 0) {  Wrap.commission = (rateCard[0].Rate__c * (Wrap.price - Wrap.discount)) / 100;  Wrap.ratecardId = rateCard[0].Id;  }
                        }
                    } 
                }
                
                if(profileTax.size() > 0) {
                    if(productTax.containsKey(Wrap.itmId)) {  
                        Wrap.vat = (productTax.get(Wrap.itmId).ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (productTax.get(Wrap.itmId).ERP7__Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (productTax.get(Wrap.itmId).ERP7__Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                        if(productTax.get(Wrap.itmId).ERP7__Other_Tax_Rate__c != Null) Wrap.tax = (productTax.get(Wrap.itmId).ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (productTax.get(Wrap.itmId).ERP7__Other_Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (productTax.get(Wrap.itmId).ERP7__Other_Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                        Wrap.taxId = productTax.get(Wrap.itmId).Id;
                    }
                    else { 
                        if(PostalCodeTax.size() > 0){
                            Wrap.vat = (PostalCodeTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (PostalCodeTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (PostalCodeTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            if(PostalCodeTax[0].ERP7__Other_Tax_Rate__c != Null) Wrap.tax = (PostalCodeTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (PostalCodeTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (PostalCodeTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            Wrap.taxId = PostalCodeTax[0].Id;
                        } else if(CityTax.size() > 0){
                            Wrap.vat = (CityTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (CityTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (CityTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            if(CityTax[0].ERP7__Other_Tax_Rate__c != Null) Wrap.tax = (CityTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (CityTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (CityTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            Wrap.taxId = CityTax[0].Id;
                        } else if(CountryAndProvinceTax.size() > 0){
                            Wrap.vat = (CountryAndProvinceTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (CountryAndProvinceTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (CountryAndProvinceTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            if(CountryAndProvinceTax[0].ERP7__Other_Tax_Rate__c != Null) Wrap.tax = (CountryAndProvinceTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (CountryAndProvinceTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (CountryAndProvinceTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            Wrap.taxId = CountryAndProvinceTax[0].Id;
                        } else if(CountryTax.size() > 0){
                            Wrap.vat = (CountryTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (CountryTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (CountryTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            if(CountryTax[0].ERP7__Other_Tax_Rate__c != Null)  Wrap.tax = (CountryTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (CountryTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (CountryTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            Wrap.taxId = CountryTax[0].Id;
                        } else if(NormalTax.size() > 0){
                            Wrap.vat = (NormalTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (NormalTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (NormalTax[0].ERP7__Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            if(NormalTax[0].ERP7__Other_Tax_Rate__c != Null) Wrap.tax = (NormalTax[0].ERP7__Apply_Tax_On__c == 'Cost Price' && Wrap.costprice != Null)? (NormalTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.costprice)).setScale(2) : (NormalTax[0].ERP7__Other_Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                            Wrap.taxId = NormalTax[0].Id;
                        }
                    }
                }
                
                //Wrap.priceWithVat = (Wrap.price - Wrap.discount + Wrap.vat).setScale(2); 
                Wrap.priceWithVat = (Wrap.price - Wrap.discount + Wrap.vat + Wrap.tax).setScale(2);
                List < Loyalty_Point_Allocation__c > loyaltyPointAllocations = (loyaltyPointAllocs.get(currentPd.product.Id) != Null) ? loyaltyPointAllocs.get(currentPd.product.Id) : new List < Loyalty_Point_Allocation__c > ();
                Decimal points = 0;
                Boolean proceed = true;
                for(Loyalty_Point_Allocation__c loyaltyPoint: loyaltyPointAllocations) {
                    if(proceed && loyaltyPoint.ERP7__Price_Book__c == currentPd.priceBookEntry.PriceBook2Id) {
                        for(Loyalty_Program_Allocation__c loyaltyProgram: loyaltyProgramAllocation) {
                            if(proceed && loyaltyPoint.Loyalty_Program__c == loyaltyProgram.Loyalty_Programme__c && loyaltyProgram.Loyalty_Programme__r.Active__c == true && System.today() >= loyaltyProgram.Loyalty_Programme__r.Start_Date__c && System.today() <= loyaltyProgram.Loyalty_Programme__r.End_Date__c) {  points = loyaltyPoint.Loyalty_Point_Per_Unit__c;  Wrap.programId = loyaltyPoint.Loyalty_Program__c;  proceed = false;  }
                        }
                    }
                }
                Wrap.pricebookId = currentPd.priceBookEntry.Id;
                Wrap.Version = currentPd.Version;
                if(Wrap.quantity_s != Null && points != Null) {
                    Wrap.RewardPoints = (points * Wrap.quantity_s).setScale(2);
                }
                
                if(Wrap.quantity_s > 0) {
                    itemWrapperList.add(Wrap);
                }
            }
        }
        
        return itemWrapperList;
    }
    @AuraEnabled
    public  static List < itemWrapper > addAssets() {    
        
        List < itemWrapper > itemWrapperList = new List < itemWrapper > (); 
        return itemWrapperList;
    }
    
    @AuraEnabled
    public  static List < itemWrapper > Assignment(String selWrap,String currentSalepoints1, String Customers1, String Contacts1, String SOP, Decimal TaxRate) {    
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        Account Customer = Customers[0];
        Contact Contact = Contacts[0];
        List < ProductsAndDiscounts > deserializedList = (List < ProductsAndDiscounts > ) JSON.deserialize(selWrap, List < ProductsAndDiscounts > .class);
        
        Id currentConId = Contact.Id;
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
        
        for(ProductsAndDiscounts currentPd: deserializedList) {
            myProductIds.add(currentPd.product.Id);
            selectedPandDwrapperList.add(currentPd);
            taxPlanIds.add(currentPd.pricebookentry.Tax_Plan__c);
        }
        
        String allFieldsProfiling = UtilClass.selectStarFromSObject('ERP7__Profiling__c');
        String queryProfiling = 'select ' + String.escapeSingleQuotes(allFieldsProfiling) + ' from Profiling__c where Id = :SOP';
        ERP7__Profiling__c Profiling = new ERP7__Profiling__c();
        if(Schema.sObjectType.Profiling__c.isAccessible()) Profiling = Database.query(queryProfiling);
        Decimal profileVatRate = 0;
        
        List < itemWrapper > itemWrapperList = new List < itemWrapper > ();    
       
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
            Contacts = [Select id, Name, FirstName, LastName, Title, Email, AccountId, Phone, Contact_Numer__c From Contact Where Id = : currentConId Limit 1];
        }
        List < Loyalty_Card__c > clubCard = new List < Loyalty_Card__c > ();
        if(Contacts.size() > 0) {
            if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c,
            Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
            Organisation__c, Organisation_Business_Unit__c
            From Loyalty_Card__c Where
            Customer__c = : Contacts[0].AccountId And
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
            for(Loyalty_Card__c lc: clubCard) {  if(lc.Loyalty_Program__c != Null) { myAllProgs.add(lc.Loyalty_Program__c);  }  }
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
                if(currentPd.product.Id == tca.product__c) {  mytcas.add(tca);  }
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
            for(Commission_Rate_Card__c crc: rateCards) {  if(tca.Price_Book__c == crc.Price_Book__c && tca.Commission_Plan__c == crc.Commission_Plan__c) {  commissionRateCard.put(tca, crc);  }  }
        }
        //products --> loyaltyProgramAllocation --> ProgramAllocations
        List < Loyalty_Program_Allocation__c > loyaltyProgramAllocation;
        if(Schema.sObjectType.Loyalty_Program_Allocation__c.isAccessible()) {
            loyaltyProgramAllocation = [Select Id, Name, Loyalty_Programme__c, Loyalty_Programme__r.Active__c,
            Loyalty_Programme__r.Start_Date__c, Loyalty_Programme__r.End_Date__c,
            Loyalty_Programme__r.Loyalty_Setup__c, Loyalty_Programme__r.Priority__c, Loyalty_Programme__r.Tier__c, Organisation__c, Organisation_Business_Unit__c
            From Loyalty_Program_Allocation__c
            Where 
            //Organisation__c = : currentSalepoint.Organisation__c And
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
            Order By Loyalty_Program__r.Priority__c Asc];
        }
        Map < Id, List < Loyalty_Point_Allocation__c >> loyaltyPointAllocs = new Map < Id, List < Loyalty_Point_Allocation__c >> ();
        for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
            List < Loyalty_Point_Allocation__c > mypoints = new List < Loyalty_Point_Allocation__c > ();
            for(Loyalty_Point_Allocation__c pta: loyaltyPointAllocation) {
                if(currentPd.product.Id == pta.product__c) {  mypoints.add(pta);  }
            }if(mypoints.size() > 0) {loyaltyPointAllocs.put(currentPd.product.Id, mypoints);
            }
        }
        //products Addition
        
        for(ProductsAndDiscounts currentPd: selectedPandDwrapperList) {
            if(currentPd.quantity_s > 0) {
                itemWrapper Wrap = new itemWrapper();
                Wrap.lineitm.Explode__c = currentPd.explode;
                Wrap.trackInventory = currentPd.trackInventory;
                Wrap.checkoutprocess = currentPd.checkoutprocess;
                Wrap.Serial = currentPd.Serial;
                Wrap.code = currentPd.product.ProductCode;
                Wrap.itm = currentPd.product.Name;
                Wrap.itmId = currentPd.product.id;
                Wrap.product = currentPd.product;
                Wrap.asset = currentPd.asset;
                Wrap.quantity_s = currentPd.quantity_s;
                Wrap.RentalUnit = currentPd.RentalUnit;
                
                Wrap.price = (currentPd.pricebookentry.UnitPrice != null)? (currentPd.pricebookentry.UnitPrice * 1).setScale(2) : 0.00;
                Decimal currentDiscount = 0.00;
                if(currentPd.discountPercent >= 0) {
                    currentDiscount = (currentPd.isPercent)? (currentPd.discountPercent / 100) : currentPd.discountPercent;
                }
                if(currentPd.discountName != null && currentPd.discountName != '') { wrap.discountId = currentPd.discountName;
                }
                if(currentPd.discountPercent != null) { wrap.discountPercent = currentPd.discountPercent;
                }
                if(currentPd.isPercent) Wrap.discount = (currentDiscount * Wrap.price).setScale(2);
                else Wrap.discount = (currentDiscount * Wrap.quantity_s).setScale(2);
                
                List < Product_Tax_Allocation__c > prodTaxAllocations = (productTaxAllocs.get(currentPd.product.Id) != Null) ? productTaxAllocs.get(currentPd.product.Id) : new List < Product_Tax_Allocation__c > ();
                Decimal vatAmount = 0;
                if(!currentPd.pricebookentry.Tax_Exempt__c){
                    if(TaxRate != null && TaxRate > 0.00){
                        Wrap.vat = (TaxRate / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                    }
                    else if(Customer.Vat__c != Null){   profileVatRate = Customer.Vat__r.Total_Tax__c;  Wrap.vat = (profileVatRate / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                    }else {
                        Wrap.vat = (currentPd.pricebookentry.Tax_Rate__c / 100 * (Wrap.price - Wrap.discount)).setScale(2);
                    }
                }else{
                    Wrap.vat = 0.00;
                }
                Wrap.priceWithVat = (Wrap.price - Wrap.discount + Wrap.vat + Wrap.tax).setScale(2);
                //Wrap.priceWithVat = (Wrap.price - Wrap.discount + Wrap.vat).setScale(2);
                List < Loyalty_Point_Allocation__c > loyaltyPointAllocations = (loyaltyPointAllocs.get(currentPd.product.Id) != Null) ? loyaltyPointAllocs.get(currentPd.product.Id) : new List < Loyalty_Point_Allocation__c > ();
                Decimal points = 0;
                Boolean proceed = true;
                for(Loyalty_Point_Allocation__c loyaltyPoint: loyaltyPointAllocations) {
                    if(proceed && loyaltyPoint.ERP7__Price_Book__c == currentPd.priceBookEntry.PriceBook2Id) {
                        for(Loyalty_Program_Allocation__c loyaltyProgram: loyaltyProgramAllocation) {
                            if(proceed && loyaltyPoint.Loyalty_Program__c == loyaltyProgram.Loyalty_Programme__c && loyaltyProgram.Loyalty_Programme__r.Active__c == true && System.today() >= loyaltyProgram.Loyalty_Programme__r.Start_Date__c && System.today() <= loyaltyProgram.Loyalty_Programme__r.End_Date__c) {   points = loyaltyPoint.Loyalty_Point_Per_Unit__c;  Wrap.programId = loyaltyPoint.Loyalty_Program__c;  proceed = false;  }
                        }
                    }
                }
                Wrap.pricebookId = currentPd.priceBookEntry.Id;
                if(Wrap.quantity_s != Null && points != Null) {
                    Wrap.RewardPoints = (points * Wrap.quantity_s)
                        .setScale(2);
                }
                
                if(Wrap.quantity_s > 0) {
                    itemWrapperList.add(Wrap);
                }
            }
        }
        return itemWrapperList;
    }
    
    @AuraEnabled
    public static Decimal getTaxRateByAddressId(String AddId){
        Decimal TaxRate = -1;  List<Address__c> AddList =  [Select Id,Tax__c,Tax__r.Total_Tax__c FROM Address__c Where Id=:AddId];
        if(AddList!=null && AddList.size()>0 && AddList[0].Tax__c !=null)
            TaxRate = AddList[0].Tax__r.Total_Tax__c;
        return TaxRate;
    }
 
    @AuraEnabled  
    public static List<itemWrapper> updateTax_OnAddressChange(String selWrap,Decimal TaxRate){
        List < itemWrapper > itemWrapperList = (List < itemWrapper > ) JSON.deserialize(selWrap, List < itemWrapper > .class);
        for(Integer i = 0; i < itemWrapperList.size(); i++) {
            itemWrapperList[i].vat = ((TaxRate) / 100 * (itemWrapperList[i].price - itemWrapperList[i].discount)).setScale(2);  itemWrapperList[i].priceWithVat = (itemWrapperList[i].price - itemWrapperList[i].discount + itemWrapperList[i].vat).setScale(2);
        }
        return itemWrapperList;
    }
        
    @AuraEnabled
    public static String saveDraft(String selWrap, String currentSalepoints1, String SalesOrder2Creates, String Customers1, String Contacts1, String SOP, List < String > lineItem2delete, String invoiceName, Decimal loyaltyPoints, Decimal loyaltyAmount) {
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        return '';   
    }
    @AuraEnabled
    public static String deleteSoliById(String SoliId){
        try{
            Sales_Order_Line_Item__c soli2Delete = new Sales_Order_Line_Item__c(Id=SoliId);
            if(Sales_Order_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete soli2Delete;
            return '';
        }catch(Exception e){  return e.getMessage();  }     
        
    }
    @AuraEnabled
    public static returnClass saveDrafts(String selWrap, String currentSalepoints1, String SalesOrder2Creates,String Customers1, String Contacts1, String SOP, List < String > lineItem2delete, String invoiceName, Decimal loyaltyPoints, Decimal loyaltyAmount, List<Id> Serials2Delete) {
        ////Moin added below one line code on 1st march 2024 so that user inputed tax amount should not override with actual 
        PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false;
        List < ERP7__Channel__c > currentSalepoints = (List < ERP7__Channel__c > ) JSON.deserialize(currentSalepoints1, List < ERP7__Channel__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        
        ERP7__Channel__c currentSalepoint = currentSalepoints[0];
        
        returnClass RC = new returnClass();
        ERP7__Sales_Order__c SalesOrder2Create = (ERP7__Sales_Order__c) JSON.deserialize(SalesOrder2Creates, ERP7__Sales_Order__c .class);
        Account Customer = Customers[0];
        Contact Contact = Contacts[0];
        try {
            if(Customer.ERP7__Is_Person_Account__c == true) {
                Map<String, Schema.SObjectType> m_objects = Schema.getglobalDescribe();
                sObject accObject = m_objects.get('account').newSObject();
                accObject = Customer;
                String jsonString = JSON.serialize(accObject);
                jsonString = jsonString.replace('"Name":"'+Customer.Name+'",', '');            
                Customer = (Account) JSON.deserialize(jsonString, Account .class);
                if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()) upsert Customer;
            } else{
                if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()) upsert Customer;
                if(Customer.ERP7__Is_Person_Account__c != true && Schema.SObjectType.Contact.isCreateable() && Schema.SObjectType.Contact.isUpdateable()){ upsert Contact; } else{ /* no access*/ }
            }
            String currentConId = Contact.Id;
            if(lineItem2delete.size() > 0) {
                List < Sales_Order_Line_Item__c > orderLineItems2Delete;
                if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) {
                    orderLineItems2Delete = [Select Id, Name, Sales_Order__c, Sales_Order__r.Account__c, Organisation__c,
                    Organisation_Business_Unit__c from Sales_Order_Line_Item__c where id In: lineItem2delete
                    ];
                } if(Sales_Order_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete orderLineItems2Delete;
            }
            
            if(SalesOrder2Create.Account__c == Null) { SalesOrder2Create.Account__c = Customer.Id;
            }
            SalesOrder2Create.Contact__c = Contact.Id;
            SalesOrder2Create.Customer_Email__c = Contact.Email;
           
            if(SOP != Null && SOP != '') {
                SalesOrder2Create.ERP7__Order_Profile__c = SOP;
            }
            SalesOrder2Create.Organisation__c = currentSalepoint.Organisation__c;
            SalesOrder2Create.Organisation_Business_Unit__c = currentSalepoint.Organisation_Business_Unit__c;
            SalesOrder2Create.Channel__c = currentSalepoint.Id;
            DMLManager.upsertAsUser(SalesOrder2Create);
            
            String SalesOrder2CreateId = SalesOrder2Create.Id;
           
            Sales_Order__c salesOrderDraft = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                                  ERP7__Loyalty_Points__c, Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email, Expected_Date__c, 
                                                  Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c, Is_Back_Order__c, Is_Pre_Order__c,
                                                  Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Status__c,
                                                  Bill_To_Address__r.County__c, ERP7__Authorised__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c, ERP7__Issue_Invoice__c 
                                                  From Sales_Order__c 
                                                  Where Id =: SalesOrder2CreateId Limit 1];
                                      
            Date cardDate = system.today();
            List < Loyalty_Card__c > clubCard;
            if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c,
                Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                Organisation__c, Organisation_Business_Unit__c
                From Loyalty_Card__c Where
                Customer__c = : Customer.Id And
                Active__c = true And
                Status__c = 'Active' And
                Start_date__c <= : cardDate And
                Expiration_Date__c >= : cardDate And
                Organisation__c = : currentSalepoint.Organisation__c And
                Organisation_Business_Unit__c = : currentSalepoint.Organisation_Business_Unit__c
                ];
            }
           
            List < Sales_Order_Line_Item__c > salesOrderLineItem = new List < Sales_Order_Line_Item__c > ();
            
            List < Loyalty_Points__c > rewards = new List < Loyalty_Points__c > ();
            List < itemWrapper > itemWrapperList = (List < itemWrapper > ) JSON.deserialize(selWrap, List < itemWrapper > .class);
            List < itemWrapper > itemWrapperLists = new List < itemWrapper > ();
            List <Id> serialIds = new List<Id>();
            Map<Id, ERP7__Stock_Inward_Line_Item__c> serialInwardMap = new Map<Id, ERP7__Stock_Inward_Line_Item__c>();
            Map<Id, Sales_Order_Line_Item__c> serialLineItem = new Map<Id, Sales_Order_Line_Item__c>();
            List<ERP7__Stock_Outward_Line_Item__c> soliOutwards = new List<ERP7__Stock_Outward_Line_Item__c>();
            List<ERP7__Asset__c> assets2Update = new List<ERP7__Asset__c>();
            List<ERP7__Serial_Number__c> serials2Update = new List<ERP7__Serial_Number__c>();
            List <Id> AssetsIds = new List<Id>();
            List <Id> BatchIds = new List<Id>();
            Map<Id, ERP7__Inventory_Stock__c > BatchesStocks = new Map<Id, ERP7__Inventory_Stock__c >();
            List<Id> LineItemIds = new List<Id>();
            
            for(Integer i = 0; i < itemWrapperList.size(); i++) { 
                if(itemWrapperList[i].orderLineItemId != '') LineItemIds.add(itemWrapperList[i].orderLineItemId);
                itemWrapperLists.add(itemWrapperList[i]);
                for(ERP7__Serial_Number__c Serial : itemWrapperLists[i].SerialNos){ if(Serial.Id != Null) serialIds.add(Serial.Id);
                }
                for(ERP7__Batch__c Batch : itemWrapperLists[i].Batches){  if(Batch.Id != Null) BatchIds.add(Batch.Id);
                }
            }
            String StockFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');       
            utilClass.FLSCheck(StockFields.split(','),'ERP7__Inventory_Stock__c');
            String query2 = 'select ' + String.escapeSingleQuotes(StockFields) + ' from ERP7__Inventory_Stock__c where ERP7__Active__c = true and ERP7__Batch_Lot__c In :batchIds and ERP7__Number_of_Item_In_Stock__c > 0 order by CreatedDate ASC';
            List<ERP7__Inventory_Stock__c> BatchStocks = Database.query(query2); 
            
            String StockOutwardsFields = UtilClass.selectStarFromSObject('ERP7__Stock_Outward_Line_Item__c');       
            utilClass.FLSCheck(StockOutwardsFields.split(','),'ERP7__Stock_Outward_Line_Item__c');
            String queryO = 'select ' + String.escapeSingleQuotes(StockOutwardsFields) + ' from ERP7__Stock_Outward_Line_Item__c where ERP7__Sales_Order_Line_Item__c In : LineItemIds';
            List<ERP7__Stock_Outward_Line_Item__c> StockOutLines = Database.query(queryO); 
            List<ERP7__Stock_Outward_Line_Item__c> StockOutLines2Delete = new List<ERP7__Stock_Outward_Line_Item__c>(); 
            
            for(ERP7__Inventory_Stock__c BS : BatchStocks){  BatchesStocks.put(BS.ERP7__Batch_Lot__c,BS);  }
            
            List<ERP7__Stock_Inward_Line_Item__c> SILIs = [Select Id, Name, ERP7__Active__c, ERP7__Site_ProductService_InventoryStock__c, ERP7__Serial__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c, ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c From ERP7__Stock_Inward_Line_Item__c Where ERP7__Serial__c In :serialIds And ERP7__Site_ProductService_InventoryStock__r.ERP7__Number_of_Item_In_Stock__c > 0];
            for(ERP7__Stock_Inward_Line_Item__c SILI : SILIS){  serialInwardMap.put(SILI.ERP7__Serial__c,SILI); }
            
            /*Set<Id> SOLIIds=new Set<Id>();
            if(itemWrapperLists.size() > 0){ for(integer i = 0; i < itemWrapperLists.size(); i++){ if(itemWrapperLists[i].orderLineItemId != '') { SOLIIds.add(itemWrapperLists[i].orderLineItemId); } } }
            
            Map<Id,Sales_Order_Line_Item__c> SOLIList=new Map<Id,Sales_Order_Line_Item__c>([Select Id, Name, Base_Price__c, Description__c, ERP7__Detailed_Description__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c,
                            VAT_Amount__c, Organisation__c, Organisation_Business_Unit__c, Commission__c, Commission_Rate_Card__c, Commission_Rate_Card__r.Commission_Plan__c, ERP7__End_Time__c, ERP7__Tax__c, 
                            product__c, product__r.Name,product__r.Description,product__r.StockKeepingUnit, product__r.SKU__c, product__r.QuantityUnitOfMeasure,product__r.ERP7__UoM__c, Quantity__c, Sales_Order__c, Loyalty_Points__c, Order_Line_Status__c, Explode__c, ERP7__Allocate_Stock__c, 
                            ERP7__Sort_Order__c, Loyalty_Program__c, Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c, ERP7__Start_Time__c, ERP7__Cost__c, ERP7__Asset__c
                            From Sales_Order_Line_Item__c Where Id In: SOLIIds]);*/
            
            if(itemWrapperLists.size() > 0){
                // --------new code added by abubakar on 15-02-2026 --------- for linking the kit products with their versions

                // 1. Collect Product IDs for Kit items that need a Version
                Set<Id> productIdsForVersions = new Set<Id>();
                // Assuming 'itemWrapperLists' is your list variable
                for (Integer i = 0; i < itemWrapperLists.size(); i++) {
                    if (!itemWrapperLists[i].trackInventory && itemWrapperLists[i].product.Is_Kit__c) {
                        // Use the correct product ID reference from your wrapper or line item logic
                        productIdsForVersions.add(itemWrapperLists[i].product.Id); 
                    }
                }

                // 2. Query Versions and Build Map (Product Id -> Version Id)
                Map<Id, Id> productToVersionMap = new Map<Id, Id>();
                if (!productIdsForVersions.isEmpty()) {
                    // Query Active and Certified versions. 
                    // ORDER BY ERP7__Default__c DESC ensures the 'Default' version appears first in the list for each product.
                    List<ERP7__Version__c> versions = [SELECT Id, ERP7__Product__c 
                                                    FROM ERP7__Version__c 
                                                    WHERE ERP7__Product__c IN :productIdsForVersions 
                                                    AND ERP7__Active__c = TRUE 
                                                    AND ERP7__Status__c = 'Certified' 
                                                    ORDER BY ERP7__Default__c DESC];
                                                    
                    for (ERP7__Version__c v : versions) {
                        // Since we ordered by Default DESC, the first time we see a Product ID, 
                        // it corresponds to the Default version (if one exists).
                        if (!productToVersionMap.containsKey(v.ERP7__Product__c)) {
                            productToVersionMap.put(v.ERP7__Product__c, v.Id);
                        }
                    }
                }
                // --------- Abubakar code ends here ---------

                for(integer i = 0; i < itemWrapperLists.size(); i++){
                    if(itemWrapperLists[i].orderLineItemId == '') {
                        
                        Sales_Order_Line_Item__c lineItem;
                        if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) {
                            lineItem = (itemWrapperLists[i].scanned && itemWrapperLists[i].orderLineItemId != '') ? [Select Id, Name, Base_Price__c, Description__c, ERP7__Detailed_Description__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c,
                            VAT_Amount__c, Organisation__c, Organisation_Business_Unit__c, Commission__c, Commission_Rate_Card__c, Commission_Rate_Card__r.Commission_Plan__c, ERP7__End_Time__c, ERP7__Tax__c, 
                            product__c, product__r.Name,product__r.Description,product__r.StockKeepingUnit, product__r.SKU__c, product__r.QuantityUnitOfMeasure,product__r.ERP7__UoM__c, Quantity__c, Sales_Order__c, Loyalty_Points__c, Order_Line_Status__c, Explode__c, ERP7__Allocate_Stock__c, 
                            ERP7__Sort_Order__c, Loyalty_Program__c, Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c, ERP7__Start_Time__c, ERP7__Cost__c, ERP7__Asset__c,
                            ERP7__Version__c
                            From Sales_Order_Line_Item__c Where Id = : itemWrapperLists[i].orderLineItemId] : new Sales_Order_Line_Item__c();
                            //lineItem = (itemWrapperLists[i].scanned && itemWrapperLists[i].orderLineItemId != '') ? SOLIList.get(itemWrapperLists[i].orderLineItemId) : new Sales_Order_Line_Item__c();
                        }
                        if(clubCard.size() > 0) {  boolean proceed = true;
                            for(Loyalty_Card__c lc: clubCard) {
                                if(String.valueof(lc.Loyalty_Program__c) == itemWrapperLists[i].programId && proceed == true) {  proceed = false;  lineItem.Loyalty_Points__c = itemWrapperLists[i].RewardPoints;  }
                            }
                        }
                        lineItem.Base_Price__c = itemWrapperLists[i].price; lineItem.Detailed_Description__c = itemWrapperLists[i].prod_Desc;  lineItem.Checked_Out_Process__c = itemWrapperLists[i].CheckOutProcess;  lineItem.Explode__c = itemWrapperLists[i].lineitm.Explode__c;  lineItem.Commission__c = itemWrapperLists[i].commission;
                        if(itemWrapperLists[i].ratecardId != '') {  lineItem.Commission_Rate_Card__c = itemWrapperLists[i].ratecardId;  }
                        lineItem.Discount_Amount__c = itemWrapperLists[i].discount;
                        if(itemWrapperLists[i].discountId != Null && itemWrapperLists[i].discountId != '' && itemWrapperLists[i].discountId != '--None--') {
                            lineItem.Discount_Plan__c = itemWrapperLists[i].discountId;
                        }
                        lineItem.ERP7__Sort_Order__c = i+1;
                        lineItem.product__c = itemWrapperLists[i].itmId;  lineItem.Inventory_Tracked__c = itemWrapperLists[i].trackInventory;  lineItem.quantity__c = itemWrapperLists[i].quantity_s;
                        if(lineItem.Sales_Order__c == Null) lineItem.Sales_Order__c = salesOrderDraft.id;
                        lineItem.Total_Price__c = itemWrapperLists[i].priceWithVat;
                        if(itemWrapperLists[i].costprice != Null) lineItem.ERP7__Cost__c = itemWrapperLists[i].costprice;
                        lineItem.VAT_Amount__c = itemWrapperLists[i].vat;  lineItem.Other_Tax__c = itemWrapperLists[i].tax;
                        if(itemWrapperLists[i].taxId != '') lineItem.ERP7__Tax__c = itemWrapperLists[i].taxId;
                        lineItem.ERP7__Is_Back_Order__c  = itemWrapperLists[i].isbackOrder;   lineItem.ERP7__Is_Pre_Order__c = itemWrapperLists[i].ispreOrder;
                        lineItem.Version__c = (itemWrapperLists[i].Version != '')? itemWrapperLists[i].Version : null;
                        
                        if(itemWrapperLists[i].programId != null && itemWrapperLists[i].programId != '') {
                            lineItem.Loyalty_Program__c = itemWrapperLists[i].programId;
                        }
                        if(Schema.sobjectType.Channel__c.fields.Organisation__c.isAccessible()) lineItem.Organisation__c = currentSalepoint.Organisation__c;
                        if(Schema.sobjectType.Channel__c.fields.Organisation_Business_Unit__c.isAccessible()) lineItem.Organisation_Business_Unit__c = currentSalepoint.Organisation_Business_Unit__c;
                        if(Schema.sobjectType.ERP7__Sales_Order__c.fields.Is_Back_Order__c.isAccessible())
                            if(lineItem.Order_Line_Status__c == '' || lineItem.Order_Line_Status__c == Null) { 
                                if(SalesOrder2Create.Is_Back_Order__c && itemWrapperLists[i].trackInventory) lineItem.Order_Line_Status__c = 'Requested'; 
                                else if(SalesOrder2Create.Is_Back_Order__c && !itemWrapperLists[i].trackInventory && itemWrapperLists[i].product.Is_Kit__c) lineItem.Order_Line_Status__c = 'Requested';
                                else if(!SalesOrder2Create.Is_Back_Order__c && !itemWrapperLists[i].trackInventory && itemWrapperLists[i].product.Is_Kit__c) lineItem.Order_Line_Status__c = 'Requested';
                                else if(SalesOrder2Create.Is_Pre_Order__c) lineItem.Order_Line_Status__c = 'Requested';
                                else lineItem.Order_Line_Status__c = 'Requested';                        
                            }
                        
                        if(itemWrapperLists[i].product.Is_Asset__c == true){
                            for(ERP7__Serial_Number__c Serial : itemWrapperLists[i].SerialNos){
                            Integer quanVal = Integer.valueof(lineItem.quantity__c);
                            if(salesOrderDraft.Expected_Date__c != Null && lineItem.ERP7__Start_Time__c == Null) lineItem.ERP7__Start_Time__c = salesOrderDraft.Expected_Date__c;
                            else if(lineItem.ERP7__Start_Time__c == Null) lineItem.ERP7__Start_Time__c = system.now();
                            if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Hours') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addHours(quanVal);
                            if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Days') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addDays(quanVal);
                            if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Weeks') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addDays(quanVal*7);
                            if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Months') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addMonths(quanVal);
                            if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Years') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addYears(quanVal);
                            lineItem.ERP7__Asset__c = Serial.ERP7__Asset__c;
                            }
                         }

                        // below if block added by abubakar on 15-02-2026
                        if(!itemWrapperLists[i].trackInventory && itemWrapperLists[i].product.Is_Kit__c && lineItem.Version__c == null){
                            // Check if we found a valid Certified/Default version for this product
                            if (productToVersionMap.containsKey(lineItem.product__c)) {
                                lineItem.ERP7__Version__c = productToVersionMap.get(lineItem.product__c);
                            }
                        }

                        salesOrderLineItem.add(lineItem);
                        
                        for(ERP7__Serial_Number__c Serial : itemWrapperLists[i].SerialNos){
                            
                            if(itemWrapperLists[i].product.Is_Asset__c == true && Serial.Id != Null  && Serial.ERP7__Asset__c != Null && serialInwardMap.containsKey(Serial.Id)) { 
                                
                                serialIds.add(Serial.Id);
                                ERP7__Stock_Outward_Line_Item__c soliOutward = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c = true, ERP7__Fixed_Asset__c=Serial.ERP7__Asset__c, ERP7__Quantity__c=1, ERP7__Sales_Order__c = salesOrderDraft.Id, ERP7__Serial__c=Serial.Id, ERP7__Status__c ='Reserved');
                                    soliOutward.ERP7__Site_Product_Service_Inventory_Stock__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__c;
                                    soliOutward.ERP7__Material_Batch_Lot__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c;
                                    soliOutward.ERP7__Version__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c;
                                
                                serialLineItem.put(Serial.Id,LineItem);  AssetsIds.add(Serial.ERP7__Asset__c);
                                
                                if(salesOrderDraft.ERP7__Authorised__c){  soliOutwards.add(soliOutward); serials2Update.add(Serial);  }
                            }
                            else if(itemWrapperLists[i].product.Is_Asset__c == false && Serial.Id != Null  && Serial.ERP7__Product__c != Null && serialInwardMap.containsKey(Serial.Id)) { 
                                
                                serialIds.add(Serial.Id);
                                ERP7__Stock_Outward_Line_Item__c soliOutward = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c = true, ERP7__Product__c=Serial.ERP7__Product__c, ERP7__Quantity__c=1, ERP7__Sales_Order__c = salesOrderDraft.Id, ERP7__Serial__c=Serial.Id, ERP7__Status__c ='Reserved');
                                    soliOutward.ERP7__Site_Product_Service_Inventory_Stock__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__c;
                                    soliOutward.ERP7__Material_Batch_Lot__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c;
                                    soliOutward.ERP7__Version__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c;
                                serialLineItem.put(Serial.Id,LineItem);
                                if(salesOrderDraft.ERP7__Authorised__c){  soliOutwards.add(soliOutward);  serials2Update.add(Serial);  }
                            }
                        }
                        Decimal BatchQuan = lineItem.quantity__c;
                        
                        for(ERP7__Batch__c Batch : itemWrapperLists[i].Batches){
                            if(Batch.Id != Null && BatchesStocks.containsKey(Batch.Id) && BatchQuan > 0) {
                                
                                ERP7__Stock_Outward_Line_Item__c soliOutward = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c = true, ERP7__Product__c=Batch.ERP7__Product__c, ERP7__Sales_Order__c = salesOrderDraft.Id, ERP7__Material_Batch_Lot__c=Batch.Id, ERP7__Status__c ='Reserved');
                                    if(BatchQuan <= BatchesStocks.get(Batch.Id).ERP7__Number_of_Item_In_Stock__c){
                                        soliOutward.ERP7__Quantity__c=BatchQuan;   BatchQuan = 0;
                                    }else{
                                        soliOutward.ERP7__Quantity__c=BatchesStocks.get(Batch.Id).ERP7__Number_of_Item_In_Stock__c;  BatchQuan = BatchQuan - BatchesStocks.get(Batch.Id).ERP7__Number_of_Item_In_Stock__c;
                                    }
                                    soliOutward.ERP7__Site_Product_Service_Inventory_Stock__c = BatchesStocks.get(Batch.Id).Id;  soliOutward.ERP7__Material_Batch_Lot__c = BatchesStocks.get(Batch.Id).ERP7__Batch_Lot__c;  soliOutward.ERP7__Version__c = BatchesStocks.get(Batch.Id).ERP7__Version__c;
                                serialLineItem.put(Batch.Id,LineItem);
                                if(salesOrderDraft.ERP7__Authorised__c){ soliOutwards.add(soliOutward); }
                            }
                        }
                        
                    } else {
                        Sales_Order_Line_Item__c lineItem = new Sales_Order_Line_Item__c(id = itemWrapperLists[i].orderLineItemId);
                        lineItem.Base_Price__c = itemWrapperLists[i].price;
                        //lineItem.Description__c = itemWrapperLists[i].product.Description;
                        //lineItem.Description__c = itemWrapperLists[i].prod_desc;
                        lineItem.ERP7__Sort_Order__c = i+1;
                        lineItem.ERP7__Detailed_Description__c = itemWrapperLists[i].prod_desc;
                        lineItem.Commission__c = itemWrapperLists[i].commission;
                        lineItem.Explode__c = itemWrapperLists[i].lineitm.Explode__c;
                        
                        if(itemWrapperLists[i].ratecardId != '') {
                            lineItem.Commission_Rate_Card__c = itemWrapperLists[i].ratecardId;
                        }
                        lineItem.Discount_Amount__c = itemWrapperLists[i].discount;
                        if(itemWrapperLists[i].discountId != Null && itemWrapperLists[i].discountId != '' && itemWrapperLists[i].discountId != '--None--') { lineItem.Discount_Plan__c = itemWrapperLists[i].discountId;  }
                        
                        lineItem.product__c = itemWrapperLists[i].itmId;
                        lineItem.quantity__c = itemWrapperLists[i].quantity_s;
                        lineItem.Inventory_Tracked__c = itemWrapperLists[i].trackInventory;
                        lineItem.Version__c = (itemWrapperLists[i].Version != '')? itemWrapperLists[i].Version : null;
                        lineItem.Total_Price__c = itemWrapperLists[i].priceWithVat;
                        if(itemWrapperLists[i].costprice != Null) lineItem.ERP7__Cost__c = itemWrapperLists[i].costprice;
                        lineItem.VAT_Amount__c = itemWrapperLists[i].vat;
                        lineItem.Other_Tax__c = itemWrapperLists[i].tax;
                        
                        if(itemWrapperLists[i].programId != null && itemWrapperLists[i].programId != '') {  lineItem.Loyalty_Program__c = itemWrapperLists[i].programId;  }
                        if(itemWrapperLists[i].product.Is_Asset__c == true){
                            for(ERP7__Serial_Number__c Serial : itemWrapperLists[i].SerialNos){
                            Integer quanVal = Integer.valueof(lineItem.quantity__c);
                            if(lineItem.ERP7__Start_Time__c == Null) lineItem.ERP7__Start_Time__c = system.now();  if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Hours') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addHours(quanVal);  if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Days') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addDays(quanVal);  if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Weeks') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addDays(quanVal*7);  if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Months') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addMonths(quanVal);  if(itemWrapperLists[i].product.QuantityUnitOfMeasure  == 'Years') lineItem.ERP7__End_Time__c = lineItem.ERP7__Start_Time__c.addYears(quanVal);
                            lineItem.ERP7__Asset__c = Serial.ERP7__Asset__c;
                         }
                        }
                        if(Schema.sobjectType.Channel__c.fields.Organisation__c.isAccessible()) lineItem.Organisation__c = currentSalepoint.Organisation__c;
                        if(Schema.sobjectType.Channel__c.fields.Organisation_Business_Unit__c.isAccessible()) lineItem.Organisation_Business_Unit__c = currentSalepoint.Organisation_Business_Unit__c;
                        if(Schema.sobjectType.ERP7__Sales_Order__c.fields.Is_Back_Order__c.isAccessible())
                        if(lineItem.Order_Line_Status__c == '' || lineItem.Order_Line_Status__c == Null) { lineItem.Order_Line_Status__c = (SalesOrder2Create.Is_Back_Order__c || SalesOrder2Create.Is_Pre_Order__c) ? 'Requested' : 'Reserved'; }
                        
                        // below code added by abubakar on 15-02-2026 for linking the kit products with their versions
                        if(!itemWrapperLists[i].trackInventory && itemWrapperLists[i].product.Is_Kit__c && lineItem.Version__c == null){
                            // Check if we found a valid Certified/Default version for this product
                            if (productToVersionMap.containsKey(lineItem.product__c)) {
                                lineItem.ERP7__Version__c = productToVersionMap.get(lineItem.product__c);
                            }
                        }
                        
                        salesOrderLineItem.add(lineItem);                        
                        
                        for(ERP7__Serial_Number__c Serial : itemWrapperLists[i].SerialNos){                            
                            if(itemWrapperLists[i].product.Is_Asset__c == true && Serial.Id != Null  && Serial.ERP7__Asset__c != Null && serialInwardMap.containsKey(Serial.Id)) { 
                                
                                serialIds.add(Serial.Id);
                                ERP7__Stock_Outward_Line_Item__c soliOutward = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c = true, ERP7__Fixed_Asset__c=Serial.ERP7__Asset__c, ERP7__Quantity__c=1, ERP7__Sales_Order__c = salesOrderDraft.Id, ERP7__Sales_Order_Line_Item__c = LineItem.Id, ERP7__Serial__c=Serial.Id, ERP7__Status__c ='Reserved');
                                    soliOutward.ERP7__Site_Product_Service_Inventory_Stock__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__c;
                                    soliOutward.ERP7__Material_Batch_Lot__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c;
                                    soliOutward.ERP7__Version__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c;
                                serialLineItem.put(Serial.Id,LineItem);
                                AssetsIds.add(Serial.ERP7__Asset__c);
                                if(salesOrderDraft.ERP7__Authorised__c){  soliOutwards.add(soliOutward); serials2Update.add(Serial);  }
                            }
                            else if(itemWrapperLists[i].product.Is_Asset__c == false && Serial.Id != Null  && Serial.ERP7__Product__c != Null && serialInwardMap.containsKey(Serial.Id)) { 
                                
                                serialIds.add(Serial.Id);
                                ERP7__Stock_Outward_Line_Item__c soliOutward = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c = true, ERP7__Product__c=Serial.ERP7__Product__c, ERP7__Quantity__c=1, ERP7__Sales_Order__c = salesOrderDraft.Id, ERP7__Sales_Order_Line_Item__c = LineItem.Id, ERP7__Serial__c=Serial.Id, ERP7__Status__c ='Reserved');
                                    soliOutward.ERP7__Site_Product_Service_Inventory_Stock__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__c;
                                    soliOutward.ERP7__Material_Batch_Lot__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Batch_Lot__c;
                                    soliOutward.ERP7__Version__c = serialInwardMap.get(Serial.Id).ERP7__Site_ProductService_InventoryStock__r.ERP7__Version__c;
                                serialLineItem.put(Serial.Id,LineItem);
                                if(salesOrderDraft.ERP7__Authorised__c){  soliOutwards.add(soliOutward);  serials2Update.add(Serial);  }
                            }
                        }
                        
                        Decimal BatchQuan = lineItem.quantity__c;
                        for(ERP7__Batch__c Batch : itemWrapperLists[i].Batches){
                            if(Batch.Id != Null && BatchesStocks.containsKey(Batch.Id) && BatchQuan > 0) {
                                String SOLIId = '';
                                for(ERP7__Stock_Outward_Line_Item__c  SOL : StockOutLines){
                                    if(SOL.ERP7__Sales_Order_Line_Item__c == LineItem.Id && SOL.ERP7__Material_Batch_Lot__c == Batch.Id) {  SOLIId = SOL.Id;   break;  }
                                }
                                ERP7__Stock_Outward_Line_Item__c soliOutward = new ERP7__Stock_Outward_Line_Item__c(ERP7__Active__c = true, ERP7__Product__c=Batch.ERP7__Product__c, ERP7__Sales_Order__c = salesOrderDraft.Id, ERP7__Sales_Order_Line_Item__c = LineItem.Id, ERP7__Material_Batch_Lot__c=Batch.Id, ERP7__Status__c ='Reserved');
                                    if(SOLIId != '') soliOutward.Id = SOLIId;
                                    if(BatchQuan <= BatchesStocks.get(Batch.Id).ERP7__Number_of_Item_In_Stock__c){  soliOutward.ERP7__Quantity__c=BatchQuan;  BatchQuan = 0;
                                    }else{
                                        soliOutward.ERP7__Quantity__c=BatchesStocks.get(Batch.Id).ERP7__Number_of_Item_In_Stock__c;  BatchQuan = BatchQuan - BatchesStocks.get(Batch.Id).ERP7__Number_of_Item_In_Stock__c;
                                    }
                                    soliOutward.ERP7__Site_Product_Service_Inventory_Stock__c = BatchesStocks.get(Batch.Id).Id;  soliOutward.ERP7__Material_Batch_Lot__c = BatchesStocks.get(Batch.Id).ERP7__Batch_Lot__c;  soliOutward.ERP7__Version__c = BatchesStocks.get(Batch.Id).ERP7__Version__c;
                                serialLineItem.put(Batch.Id,LineItem);
                                if(salesOrderDraft.ERP7__Authorised__c){  soliOutwards.add(soliOutward);  lineItem.ERP7__Allocate_Stock__c = false;  }
                            }
                        }
                        if(itemWrapperLists[i].Batches.size() > 0 && !lineItem.ERP7__Allocate_Stock__c){
                            for(ERP7__Stock_Outward_Line_Item__c  SOL : StockOutLines){
                                Boolean exist = false;
                                for(ERP7__Batch__c Batch : itemWrapperLists[i].Batches){
                                    if(SOL.ERP7__Sales_Order_Line_Item__c == LineItem.Id && SOL.ERP7__Material_Batch_Lot__c == Batch.Id) {  exist = true;  break;  }
                                }
                                if(!exist) StockOutLines2Delete.add(SOL);
                            }
                        }
                        
                    }
                }
            }
            
            
            if(salesOrderLineItem.size() > 0) { 
                //PreventRecursiveLedgerEntry.testCasesTransactions = false;
                PreventRecursiveLedgerEntry.IsFromPOS = true;
                if(Schema.sObjectType.Sales_Order__c.fields.ERP7__Authorised__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Authorised__c.isUpdateable() && Schema.SObjectType.Sales_Order__c.isCreateable() && Schema.SObjectType.Sales_Order__c.isUpdateable()){upsert salesOrderDraft;}else{RC.Error = true; RC.errorMsg ='Not allowed to upsert Sales Order';}
                PreventRecursiveLedgerEntry.testCasesTransactions = false;
                if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Base_Price__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Base_Price__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Sort_Order__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Detailed_Description__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Detailed_Description__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Commission__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Commission__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Explode__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Explode__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Commission_Rate_Card__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Commission_Rate_Card__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Discount_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Discount_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Discount_Plan__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Discount_Plan__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.product__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.product__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.quantity__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.quantity__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Inventory_Tracked__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Inventory_Tracked__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Version__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Version__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Total_Price__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Total_Price__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Cost__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Cost__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.VAT_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.VAT_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Other_Tax__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Other_Tax__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Loyalty_Program__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Loyalty_Program__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__End_Time__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__End_Time__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Start_Time__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Start_Time__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Asset__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.ERP7__Asset__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Organisation__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Organisation_Business_Unit__c.isUpdateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Order_Line_Status__c.isCreateable() && Schema.sObjectType.Sales_Order_Line_Item__c.fields.Order_Line_Status__c.isUpdateable() && Schema.SObjectType.Sales_Order_Line_Item__c.isCreateable() && Schema.SObjectType.Sales_Order_Line_Item__c.isUpdateable()){upsert salesOrderLineItem;}else{RC.Error = true; RC.errorMsg ='Not allowed to upsert Sales Order';}
                //PreventRecursiveLedgerEntry.SOLI_SufficientStockCheck = false; 
                //PreventRecursiveLedgerEntry.SOLI_ApplyTaxes = false; 
                //PreventRecursiveLedgerEntry.SOLI_CalculateLogisticQuantity = false; 
                //PreventRecursiveLedgerEntry.SOLI_AllocateStock = false; 
                //PreventRecursiveLedgerEntry.SOLI_CreateMrpsOnExplode = false;
            }
            
            
            for(ERP7__Stock_Outward_Line_Item__c soliOutward : soliOutwards){
                if(soliOutward.ERP7__Serial__c != Null) {   soliOutward.ERP7__Sales_Order_Line_Item__c = serialLineItem.get(soliOutward.ERP7__Serial__c).Id;  }
                if(soliOutward.ERP7__Material_Batch_Lot__c != Null) {  if(soliOutward.ERP7__Sales_Order_Line_Item__c == Null) soliOutward.ERP7__Sales_Order_Line_Item__c = serialLineItem.get(soliOutward.ERP7__Material_Batch_Lot__c).Id;  }
                if(salesOrderDraft.ERP7__Status__c == 'Cancelled') soliOutward.ERP7__Status__c = 'Rejected';
            }
            if(soliOutwards.size() > 0) { 
                //upsert soliOutwards;
            }
            
            if(StockOutLines2Delete.size() > 0 && Schema.SObjectType.ERP7__Stock_Outward_Line_Item__c.isDeletable()) { 
                //delete StockOutLines2Delete;
            }
            
            assets2Update = [Select Id, Name, ERP7__Available__c, ERP7__Status__c From ERP7__Asset__c  Where Id In :AssetsIds];
            for(ERP7__Asset__c Asset : assets2Update){   Asset.ERP7__Available__c = false;  }
            if(assets2Update.size() > 0 && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isCreateable() && Schema.sObjectType.ERP7__Asset__c.fields.ERP7__Available__c.isUpdateable()) {upsert assets2Update;}else{RC.Error = true; RC.errorMsg ='Not allowed to upsert Asset or Asset not available';}
            /*
            if(serials2Update.size() > 0) { 
                for(ERP7__Serial_Number__c Serial : serials2Update) Serial.ERP7__Available__c = false;
                upsert serials2Update;
            }*/
            //PreventRecursiveLedgerEntry.testCasesTransactions = true;
            List < Loyalty_Setup__c > Loyaltysetup;    
            if(Schema.sObjectType.Loyalty_Setup__c.isAccessible()){    
                Loyaltysetup = [Select Id, Name, Points_Per_Unit_Amount__c, Organisation__c, Organisation_Business_Unit__c
                From Loyalty_Setup__c
                Where Organisation_Business_Unit__c = : SalesOrder2Create.Organisation_Business_Unit__c And
                Organisation__c = : SalesOrder2Create.Organisation__c
                order by CreatedDate Asc Limit 1];
            }
           
            if(Loyaltysetup.size() > 0 && clubCard.size() > 0 && loyaltyPoints != Null && loyaltyPoints != 0 && (salesOrderDraft.Loyalty_Points__c == Null || loyaltyPoints > salesOrderDraft.Loyalty_Points__c)) {
                Loyalty_Points__c debitReward = new Loyalty_Points__c(Loyalty_Card__c = clubCard[0].id, Credit_Debit_Date__c = System.today(), Order__c = salesOrderDraft.id,
                Points__c = (salesOrderDraft.Loyalty_Points__c != Null) ? loyaltyPoints - salesOrderDraft.Loyalty_Points__c : loyaltyPoints, Transaction_Status__c ='Debit', 
                Valid_Date__c = System.Today() + 30,Organisation__c = currentSalepoint.Organisation__c, Organisation_Business_Unit__c = currentSalepoint.Organisation_Business_Unit__c);
                if(Schema.sObjectType.Loyalty_Points__c.fields.Loyalty_Card__c.isCreateable()  && Schema.sObjectType.Loyalty_Points__c.fields.Loyalty_Card__c.isUpdateable() && Schema.sObjectType.Loyalty_Points__c.fields.Credit_Debit_Date__c.isCreateable() && Schema.sObjectType.Loyalty_Points__c.fields.Credit_Debit_Date__c.isUpdateable() && Schema.sObjectType.Loyalty_Points__c.fields.Order__c.isCreateable() && Schema.sObjectType.Loyalty_Points__c.fields.Order__c.isUpdateable() && Schema.sObjectType.Loyalty_Points__c.fields.Points__c.isCreateable() && Schema.sObjectType.Loyalty_Points__c.fields.Points__c.isUpdateable() && Schema.sObjectType.Loyalty_Points__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Loyalty_Points__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.Loyalty_Points__c.fields.Valid_Date__c.isCreateable() && Schema.sObjectType.Loyalty_Points__c.fields.Valid_Date__c.isUpdateable() && Schema.sObjectType.Loyalty_Points__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Loyalty_Points__c.fields.Organisation__c.isUpdateable() && Schema.sObjectType.Loyalty_Points__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.Loyalty_Points__c.fields.Organisation_Business_Unit__c.isUpdateable()){upsert debitReward;}else{RC.Error = true; RC.errorMsg ='Not allowed to upsert Loyality Point';}
                
                Decimal pointsPerUnit = Loyaltysetup[0].Points_Per_Unit_Amount__c;  Decimal curAmount = (pointsPerUnit == 0) ? 0 : (debitReward.Points__c / pointsPerUnit).setScale(2);
                
                ERP7__Credit_Note__c newCN = new ERP7__Credit_Note__c();
                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Active__c.isCreateable()) {newCN.ERP7__Active__c = true;} else{ /*no acccess*/ }   if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Sales_Order__c.isCreateable()){newCN.ERP7__Sales_Order__c = salesOrderDraft.Id;} else{ /* no access*/}
                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Amount__c.isCreateable()){ newCN.ERP7__Amount__c = curAmount;} else{ /*no acccess*/ }
                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Applied_Date__c.isCreateable()){newCN.ERP7__Applied_Date__c = system.Today(); }else{ /*no acccess*/ }  if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isCreateable()){newCN.ERP7__Account__c = Customer.Id;} else{ /* no access*/} 
                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Contact__c.isCreateable()){newCN.ERP7__Contact__c = contact.Id; } else{ /*no acccess*/ } if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Loyalty_Points__c.isCreateable()){newCN.ERP7__Loyalty_Points__c = debitReward.Id;} else{ /* no access*/} 
                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Paid__c.isCreateable()){newCN.ERP7__Paid__c = true;} else{ /* no access*/}   if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Organisation__c.isCreateable()){newCN.ERP7__Organisation__c = salesOrderDraft.ERP7__Organisation__c;} else{ /* no access*/} 
                if(Schema.SObjectType.ERP7__Credit_Note__c.isCreateable()){insert newCN;}else{RC.Error = true; RC.errorMsg ='Not allowed to insert credit notes';}
                salesOrderDraft = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                                  ERP7__Loyalty_Points__c, Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                                  Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                                  Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Issue_Invoice__c,
                                                  Bill_To_Address__r.County__c,ERP7__Total_Shipping_Amount__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c
                                                  From Sales_Order__c 
                                                  Where Id =: SalesOrder2CreateId Limit 1];
                ERP7__Sales_Order__c currentSalesorder = salesOrderDraft;
                ERP7__Payment__c Payment = new ERP7__Payment__c();   payment.Sales_Order__c = currentSalesorder.Id;  payment.Accounts__c = currentSalesorder.Account__c;
                if(currentSalesorder.Contact__r.FirstName != Null) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
                if(currentSalesorder.Contact__r.LastName != Null) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
                if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
                if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                if(currentSalesorder.Bill_To_Address__r.City__c != Null) payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                if(currentSalesorder.Bill_To_Address__r.State__c != Null) payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                if(currentSalesorder.Bill_To_Address__r.Country__c != Null) payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                payment.Account__c = currentSalesorder.Organisation__c;
                payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                payment.ERP7__Credit_Note__c = newCN.Id;  payment.ERP7__Type__c = 'Debit'; Payment.ERP7__Payment_Type__c = 'Loyalty';  payment.ERP7__Total_Amount__c = newCN.ERP7__Amount__c;  payment.ERP7__Status__c = 'Paid';
                String rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                if(String.isNotEmpty(rTypeP)){  payment.RecordTypeId = rTypeP;   }
                List<ERP7__Payment__c> pays = new List<ERP7__Payment__c>();
                pays.add(payment);
                ERP7__Payment__c Payment1 = new ERP7__Payment__c(); 
                Payment1.Sales_Order__c = currentSalesorder.Id;
                Payment1.Accounts__c = currentSalesorder.Account__c;
                if(currentSalesorder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                if(currentSalesorder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                if(currentSalesorder.Contact__r.Email != Null) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                if(currentSalesorder.Bill_To_Address__r.City__c != Null) Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                if(currentSalesorder.Bill_To_Address__r.State__c != Null) Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                if(currentSalesorder.Bill_To_Address__r.Country__c != Null) Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                Payment1.Account__c = currentSalesorder.Organisation__c;  Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;  Payment1.ERP7__Credit_Note__c = newCN.Id;  Payment1.ERP7__Type__c = 'Credit';  Payment1.ERP7__Payment_Type__c = 'Loyalty';  Payment1.ERP7__Status__c = 'Paid';  payment1.ERP7__Total_Amount__c = newCN.ERP7__Amount__c;
                String rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                if(String.isNotEmpty(rTypeP1)){  Payment1.RecordTypeId = rTypeP1;   }
                Payment1.ERP7__Posted__c = true;  Payment1.ERP7__Posted_Date__c = system.Today(); pays.add(payment1);
                if(Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Accounts__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Accounts__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable()){upsert pays;}else{RC.Error = true; RC.errorMsg ='Not allowed to upsert payment';} 
                salesOrderDraft.ERP7__Amount_Paid__c = (salesOrderDraft.ERP7__Amount_Paid__c == null) ? 0 : salesOrderDraft.ERP7__Amount_Paid__c + newCN.ERP7__Amount__c;
            }
            if(Schema.sObjectType.Sales_Order__c.fields.Loyalty_Amount__c.isAccessible())  salesOrderDraft.Loyalty_Amount__c = (LoyaltyAmount == null) ? 0 : LoyaltyAmount;
            if(Schema.sObjectType.Sales_Order__c.fields.Loyalty_Points__c.isAccessible())  salesOrderDraft.Loyalty_Points__c = (loyaltyPoints == null) ? 0 : loyaltyPoints;
            if (salesOrderDraft.Order_Status__c == Null) if(Schema.sObjectType.Sales_Order__c.fields.Order_Status__c.isAccessible()) salesOrderDraft.Order_Status__c = 'Entered';
            if(Schema.sObjectType.Sales_Order__c.fields.ERP7__Amount_Paid__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Amount_Paid__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.Loyalty_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Loyalty_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.Loyalty_Points__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Loyalty_Points__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.Order_Status__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Order_Status__c.isUpdateable() && Schema.SObjectType.Sales_Order__c.isCreateable() && Schema.SObjectType.Sales_Order__c.isUpdateable()){upsert salesOrderDraft;}else{RC.Error = true; RC.errorMsg ='Not allowed to upsert Sales Order';}
            RC.Error = false; 
            RC.errorMsg = '';
            RC.Value = salesOrderDraft.Name;
            
            //ak
            /*
            if(salesOrderDraft.ERP7__Authorised__c){
                List<ERP7__Stock_Outward_Line_Item__c> STOLI_solo = new List<ERP7__Stock_Outward_Line_Item__c>();
                STOLI_solo = [SELECT Id, Name, ERP7__Serial__c, ERP7__Sales_Order_Line_Item__c, ERP7__Product__c, ERP7__Product__r.Name FROM ERP7__Stock_Outward_Line_Item__c WHERE ERP7__Sales_Order__c =: salesOrderDraft.Id AND ERP7__Product__r.ERP7__Serialise__c = true AND ERP7__Logistic_Line_Item__c != NULL AND ERP7__Serial__c = null LIMIT 9999];
                Boolean breakItem = false;
                List<ERP7__Serial_Number__c> updateSerials = new List<ERP7__Serial_Number__c>();
                List<ERP7__Stock_Outward_Line_Item__c> updateSTOLIS = new List<ERP7__Stock_Outward_Line_Item__c>();
                for(ERP7__Stock_Outward_Line_Item__c stoliItem : STOLI_solo){
                    for(itemWrapper item: itemWrapperLists) {
                        for(Integer i=0; i<item.SerialNos.size(); i++){
                            if(stoliItem.ERP7__Sales_Order_Line_Item__c == serialLineItem.get(item.SerialNos[i].Id).Id){
                                stoliItem.ERP7__Serial__c = item.SerialNos[i].Id;
                                updateSTOLIS.add(stoliItem);
                                updateSerials.add(item.SerialNos[i]);
                                item.SerialNos.remove(i);
                                breakItem = true;
                                break;
                            }
                        }
                        if(breakItem) { breakItem = false; break; }
                    }
                }
                if(updateSTOLIS.size() > 0) update updateSTOLIS;
                if(updateSerials.size() > 0) { 
                    for(ERP7__Serial_Number__c Serial : updateSerials) Serial.ERP7__Available__c = false;
                    update updateSerials;
                }
            }
            */
            //end
            return RC;
            
         } catch(Exception e) { RC.Error = true; RC.errorMsg = e.getMessage()+' Line Number'+e.getLineNumber(); RC.Value = ''; return RC; }
        
    }
    @AuraEnabled
    public static returnClass ApplyCoupons(String SalesOrder2Creates, String Customers1,String Contacts1, String Coupon) {
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        List < Contact > Contacts = (List < Contact > ) JSON.deserialize(Contacts1, List < Contact > .class);
        ERP7__Sales_Order__c SalesOrder2Create = (ERP7__Sales_Order__c) JSON.deserialize(SalesOrder2Creates, ERP7__Sales_Order__c .class);
        String SalesOrder2CreateId = SalesOrder2Create.Id;
        
        SalesOrder2Create = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                      ERP7__Loyalty_Points__c, Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email, ERP7__Due_Amount__c,
                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c, Total_Shipping_Amount__c, ERP7__Coupon_Discount__c,
                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Shipping_Discount__c,
                                      Bill_To_Address__r.County__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c, ERP7__Issue_Invoice__c
                                      From Sales_Order__c 
                                      Where Id =: SalesOrder2CreateId Limit 1];
        
        List<ERP7__Sales_Order_Line_Item__c> SOLIs = [Select Id, Name, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Price_Product__c, ERP7__Base_Price__c, ERP7__Coupon__c, ERP7__Total_Price__c From ERP7__Sales_Order_Line_Item__c Where ERP7__Sales_Order__c =: SalesOrder2CreateId];
        List<ERP7__Sales_Order_Line_Item__c> SOLIs2upsert = new List<ERP7__Sales_Order_Line_Item__c>();
        Map<Id, ERP7__Sales_Order_Line_Item__c> proSoli = new Map<Id, ERP7__Sales_Order_Line_Item__c>(); 
        for(ERP7__Sales_Order_Line_Item__c soli : SOLIs){
            proSoli.put(soli.ERP7__Product__c,soli);
        }
        Account Customer = Customers[0];
        Contact Contact = Contacts[0];
        returnClass RC = new returnClass();
        try {
            
            List<ERP7__Coupon_Issued__c> CI = [Select Id, Name, ERP7__Product__c, ERP7__Account__c, ERP7__Coupon__c, ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c, ERP7__Coupon__r.Name, ERP7__Coupon__r.ERP7__Start_Date__c, ERP7__Coupon__r.ERP7__End_Date__c, ERP7__Issued_Date__c, ERP7__Value__c, ERP7__Voucher_Amount__c, ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c, ERP7__Coupon__r.RecordType.Name, ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c
                                                From ERP7__Coupon_Issued__c 
                                                Where ERP7__Coupon__r.Name =:Coupon And 
                                                ERP7__Coupon__r.ERP7__Start_Date__c <= Today And 
                                                ERP7__Coupon__r.ERP7__End_Date__c >= Today And 
                                                (ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c = Null Or ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c <= :SalesOrder2Create.ERP7__Sales_Order_Amount__c) 
                                                Limit 1];
            
            if(CI.size() > 0){
                List< ERP7__Coupon_Redemption__c > CR = [Select Id, Name, ERP7__Account__c, ERP7__Coupon__c From ERP7__Coupon_Redemption__c Where ERP7__Account__c =:Customer.Id And ERP7__Coupon__c =: CI[0].ERP7__Coupon__c Limit 1];
                if(SalesOrder2Create.ERP7__Due_Amount__c <= 0){   RC.Error = true;  RC.errorMsg = 'Invalid Sales Order Amount';  RC.Value = SalesOrder2Create.Name;  }
                else if(CR.size() > 0 || CI[CI.size()-1].ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c == [Select Id, Name, ERP7__Account__c, ERP7__Coupon__c From ERP7__Coupon_Redemption__c Where ERP7__Coupon__c =: CI[0].ERP7__Coupon__c].size() || (CI[CI.size()-1].ERP7__Product__c != Null && !proSoli.containsKey(CI[0].ERP7__Product__c)) || (CI[CI.size()-1].ERP7__Account__c != Null && !(CI[CI.size()-1].ERP7__Account__c == SalesOrder2Create.Account__c))){
                    RC.Error = true;   RC.errorMsg = 'Coupon Already Redeemed/Invalid';   RC.Value = SalesOrder2Create.Name;
                }else{
                    ERP7__Coupon_Redemption__c newCR = new ERP7__Coupon_Redemption__c();
                    if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.Name.isCreateable()){ newCR.Name = (proSoli.containsKey(CI[0].ERP7__Product__c))? proSoli.get(CI[0].ERP7__Product__c).Name : SalesOrder2Create.Name; } else {/*no access*/}
                    if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Account__c.isCreateable()){newCR.ERP7__Account__c = Customer.Id;} else {/*no access*/}
                    if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon__c.isCreateable()){newCR.ERP7__Coupon__c = CI[0].ERP7__Coupon__c;} else {/*no access*/}
                    if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon_Issued__c.isCreateable()){newCR.ERP7__Coupon_Issued__c = CI[0].Id;} else {/*no access*/}
                    if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Redemption_Date__c.isCreateable()){newCR.ERP7__Redemption_Date__c = system.Today();} else {/*no access*/}
                    if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isCreateable()){newCR.ERP7__Sales_Order__c = SalesOrder2Create.Id;} else {/*no access*/}
                    if(CI[0].ERP7__Voucher_Amount__c > 0) { 
                        if(proSoli.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){  newCR.ERP7__Sales_Order_Line_Item__c = proSoli.get(CI[0].ERP7__Product__c).Id;
                            if(CI[0].ERP7__Voucher_Amount__c <= proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                            else newCR.ERP7__Value__c = proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c;
                        }
                        else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Order'){
                            if(CI[0].ERP7__Voucher_Amount__c <= SalesOrder2Create.ERP7__Sales_Order_Amount__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                            else newCR.ERP7__Value__c = SalesOrder2Create.ERP7__Sales_Order_Amount__c;
                        }
                        else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Shipping'){
                            if(CI[0].ERP7__Voucher_Amount__c <= SalesOrder2Create.ERP7__Total_Shipping_Amount__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                            else newCR.ERP7__Value__c = SalesOrder2Create.ERP7__Total_Shipping_Amount__c;
                        }
                    }
                    else if(CI[0].ERP7__Value__c > 0){ 
                        if(proSoli.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){  newCR.ERP7__Value__c =  (proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c == 0)? 0 : (CI[0].ERP7__Value__c * proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c)/100;  newCR.ERP7__Sales_Order_Line_Item__c = proSoli.get(CI[0].ERP7__Product__c).Id;  }
                        else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Order') newCR.ERP7__Value__c =  (SalesOrder2Create.ERP7__Sales_Order_Amount__c == 0)? 0 : (CI[0].ERP7__Value__c * SalesOrder2Create.ERP7__Sales_Order_Amount__c)/100;
                        else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Shipping') newCR.ERP7__Value__c =  (SalesOrder2Create.ERP7__Total_Shipping_Amount__c == Null || SalesOrder2Create.ERP7__Total_Shipping_Amount__c == 0)? 0 : (CI[0].ERP7__Value__c * SalesOrder2Create.ERP7__Total_Shipping_Amount__c)/100;
                    }
                    if(newCR.ERP7__Value__c > 0){
                        if(newCR.ERP7__Value__c > SalesOrder2Create.ERP7__Due_Amount__c && Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable()){ newCR.ERP7__Value__c = SalesOrder2Create.ERP7__Due_Amount__c; } else{ /* no access*/ }
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.isCreateable()){insert newCR;}else{RC.Error = true;   RC.errorMsg ='Not Allowed to insert Coupne redemption';}
                        
                        if(CI[0].ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c){
                            //New Logic
                            if(proSoli.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){
                                proSoli.get(CI[0].ERP7__Product__c).ERP7__Coupon__c = newCR.ERP7__Value__c;
                                if(proSoli.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c != Null)   proSoli.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c = proSoli.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c - newCR.ERP7__Value__c;
                                SOLIs2upsert.add(proSoli.get(CI[0].ERP7__Product__c));
                            }
                            else{
                                SalesOrder2Create.ERP7__Coupon_Discount__c = newCR.ERP7__Value__c;
                            }
                            if(SOLIs2upsert.size() > 0 && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()) upsert SOLIs2upsert;
                            if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Coupon_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Coupon_Discount__c.isUpdateable() && Schema.SObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.SObjectType.ERP7__Sales_Order__c.isUpdateable()){upsert SalesOrder2Create;}else{RC.Error = true; RC.errorMsg ='Not allowed to upsert Sales Order';}
                            RC.Error = false; 
                            RC.errorMsg = '';
                            RC.Value = SalesOrder2Create.Name;
                        }
                        else{
                            ERP7__Credit_Note__c newCN = new ERP7__Credit_Note__c();
                            if(Schema.sObjectType.ERP7__Credit_Note__c.fields.Name.isCreateable()){newCN.Name = newCR.Name;} else{ /*no access*/ }  if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Active__c.isCreateable()){newCN.ERP7__Active__c = true;} else{/*no access*/} if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Sales_Order__c.isCreateable()){newCN.ERP7__Sales_Order__c = SalesOrder2Create.Id;} else{ /* no access*/} 
                            if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Amount__c.isCreateable()){newCN.ERP7__Amount__c = newCR.ERP7__Value__c;} else{/* no access*/}  if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Credit__c.isCreateable()){newCN.ERP7__Credit__c = newCR.ERP7__Value__c;} else {/* no access*/ }  if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Applied_Date__c.isCreateable()){ newCN.ERP7__Applied_Date__c = system.Today();} else {/* no access*/ } if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isCreateable()){ newCN.ERP7__Account__c = Customer.Id;}else { /*no access*/ }
                            if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Contact__c.isCreateable()){newCN.ERP7__Contact__c = contact.Id;} else{/* no access*/} 
                            if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Coupon_Redemption__c.isCreateable()){newCN.ERP7__Coupon_Redemption__c = newCR.Id; } else{/* no access*/}   if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Paid__c.isCreateable()){newCN.ERP7__Paid__c = true;}else{/* no access*/}   if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Organisation__c.isCreateable()){newCN.ERP7__Organisation__c = SalesOrder2Create.ERP7__Organisation__c;} else{/* no access*/} 
     
                            if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable()){insert newCN;}else{RC.Error = true;   RC.errorMsg ='Not allowed to insert credit notes';}
                            
                            ERP7__Sales_Order__c currentSalesorder = SalesOrder2Create;   ERP7__Payment__c Payment = new ERP7__Payment__c();   payment.Sales_Order__c = currentSalesorder.Id;  payment.Accounts__c = currentSalesorder.Account__c;
                            if(currentSalesorder.Contact__r.FirstName != Null) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
                            if(currentSalesorder.Contact__r.LastName != Null) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
                            if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
                            if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                            if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                            if(currentSalesorder.Bill_To_Address__r.City__c != Null) payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                            if(currentSalesorder.Bill_To_Address__r.State__c != Null) payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                            if(currentSalesorder.Bill_To_Address__r.Country__c != Null) payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                            if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                            payment.Account__c = currentSalesorder.Organisation__c;  payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;  payment.ERP7__Credit_Note__c = newCN.Id;  payment.ERP7__Type__c = 'Debit';  Payment.ERP7__Payment_Type__c = 'Coupon';  payment.ERP7__Total_Amount__c = newCN.ERP7__Amount__c;  payment.ERP7__Status__c = 'Paid';
                            String rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                            if(String.isNotEmpty(rTypeP)){  payment.RecordTypeId = rTypeP;   }
                            //DMLManager.upsertAsUser(payment); 
                            List<ERP7__Payment__c> pays = new List<ERP7__Payment__c>();
                            pays.add(payment);
                            ERP7__Payment__c Payment1 = new ERP7__Payment__c(); 
                            Payment1.Sales_Order__c = currentSalesorder.Id;  Payment1.Accounts__c = currentSalesorder.Account__c;
                            if(currentSalesorder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                            if(currentSalesorder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                            if(currentSalesorder.Contact__r.Email != Null) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                            if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                            if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                            if(currentSalesorder.Bill_To_Address__r.City__c != Null) Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                            if(currentSalesorder.Bill_To_Address__r.State__c != Null) Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                            if(currentSalesorder.Bill_To_Address__r.Country__c != Null) Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                            if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                            Payment1.Account__c = currentSalesorder.Organisation__c;  Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;  Payment1.ERP7__Credit_Note__c = newCN.Id;  Payment1.ERP7__Type__c = 'Credit';  Payment1.ERP7__Payment_Type__c = 'Coupon';  Payment1.ERP7__Status__c = 'Paid';  payment1.ERP7__Total_Amount__c = newCN.ERP7__Amount__c;
                            String rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                            if(String.isNotEmpty(rTypeP1)){  Payment1.RecordTypeId = rTypeP1;   }
                            Payment1.ERP7__Posted__c = true;  Payment1.ERP7__Posted_Date__c = system.Today();
                            //DMLManager.upsertAsUser(Payment1); 
                            //pays.add(payment1);
                            DMLManager.upsertAsUser(pays);   RC.Error = false;   RC.errorMsg = '';  RC.Value = SalesOrder2Create.Name;
                        }
                    } else{
                        RC.Error = true;   RC.errorMsg = 'Invalid Coupon Amount';  RC.Value = SalesOrder2Create.Name;
                        
                    }
                }
            }else{
                RC.Error = true;   RC.errorMsg = 'Invalid Coupon';  RC.Value = SalesOrder2Create.Name;
            }
         } catch(Exception e) { RC.Error = true; RC.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); RC.Value = SalesOrder2Create.Name; }
         return RC;
    }
    
    @AuraEnabled
    public static List<RecentlyViewed> CreateNewCustomer(List < Account > Customers) { 
        List<RecentlyViewed> recRecords = [SELECT Id, Name, Type
        FROM RecentlyViewed 
        WHERE Type IN ('Account', 'Contact', 'ERP7__Sales_Order__c')
        ORDER BY LastViewedDate DESC limit 5];
        return recRecords;
    }
    
    @AuraEnabled
    public static returnClass CreateNewCustomers(String Customers1) {
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        returnClass RC = new returnClass();
        Account Customer = Customers[0];
        Customer.Active__c = 'Yes';
        List<RecordType> rTypes = [Select Id, Name from RecordType Where SobjectType = 'Account' And (Name = 'Person Account' Or Name = 'PersonAccount')];
        if(rTypes.size() > 0 && Customer.ERP7__Is_Person_Account__c == true){
           
               Customer.RecordTypeId = rTypes[0].Id;
            Map<String, Schema.SObjectType> m_objects = Schema.getglobalDescribe();
            sObject accObject = m_objects.get('account').newSObject();
            accObject = Customer;
            if(Customer.Name.contains(' ')){
                accObject.put('FirstName',Customer.Name.Substring(0,Customer.Name.indexOf(' ')));  accObject.put('LastName',Customer.Name.Substring(Customer.Name.indexOf(' '),Customer.Name.length()));
            } else accObject.put('LastName',Customer.Name);
            String jsonString = JSON.serialize(accObject);
            jsonString = jsonString.replace('"Name":"'+Customer.Name+'",', '');            
            Account personAcc = (Account) JSON.deserialize(jsonString, Account .class);
            try {
                if(Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()) {upsert personAcc;  RC.Error = false;RC.value = personAcc.Id; } else{/* no acess*/}
            } catch(exception ex) {  RC.Error = true; RC.errorMsg = ex.getMessage(); }
            return RC;
        }
        try {
            if(Schema.sObjectType.Account.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Account.fields.RecordTypeId.isUpdateable() && Schema.sObjectType.Account.fields.Active__c.isCreateable() && Schema.sObjectType.Account.fields.Active__c.isUpdateable() && Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){upsert Customer;}else{RC.Error = true;   RC.errorMsg ='Not allowed to upsert Account';}
            RC.Error = false;
            RC.value = Customer.Id;
        } catch(exception ex) {  RC.Error = true;   RC.errorMsg = ex.getMessage(); }
        return RC;
    }
    
    @AuraEnabled
    public static List<RecentlyViewed> CreateNewCont(List<Contact> Cons) {
        List<RecentlyViewed> recRecords = [SELECT Id, Name, Type
        FROM RecentlyViewed 
        WHERE Type IN ('Account', 'Contact', 'ERP7__Sales_Order__c')
        ORDER BY LastViewedDate DESC limit 5];
        return recRecords;
    }
    
    @AuraEnabled
    public static returnClass CreateNewConts(String Cons1) {
        List < Contact > Cons = (List < Contact > ) JSON.deserialize(Cons1, List < Contact > .class);
        returnClass RC = new returnClass();
        Contact Cont = Cons[0];
        
        try {
            if(Schema.SObjectType.Contact.isCreateable() && Schema.SObjectType.Contact.isUpdateable()){ upsert Cont; } else{ /* no access*/ }
            RC.Error = false;
            RC.value = Cont.Id;
        } 
        catch(exception ex) {   RC.Error = true;   RC.errorMsg = ex.getMessage();  }
        return RC;
    }
    
    @AuraEnabled
    public static List<RecentlyViewed> CreateNewAddress(String NewAddres1, String County, String Country) {
         List < ERP7__Address__c > NewAddres = (List < ERP7__Address__c > ) JSON.deserialize(NewAddres1, List < ERP7__Address__c > .class);
        ERP7__Address__c Address = NewAddres[0];
        Address.ERP7__Active__c = true;
        Address.ERP7__State__c = County;
        Address.ERP7__Country__c = Country;
        if(Address.ERP7__Postal_Code__c != Null && Address.ERP7__Postal_Code__c != '') Address.Name = Address.ERP7__Postal_Code__c;
        try {
            if(Schema.sObjectType.ERP7__Address__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isUpdateable() && Schema.SObjectType.ERP7__Address__c.isCreateable() && Schema.SObjectType.ERP7__Address__c.isUpdateable()){upsert Address;}else{/*not allowed to insert address*/}
        } catch(exception ex) {
            
        }
        List<RecentlyViewed> recRecords = [SELECT Id, Name, Type
        FROM RecentlyViewed 
        WHERE Type IN ('Account', 'Contact', 'ERP7__Sales_Order__c')
        ORDER BY LastViewedDate DESC limit 5];
        return recRecords;
    }
    
    
    @AuraEnabled
    public static ERP7__Address__c SaveNewAddress(String NewAddres1, String State, String Country) {
        List < ERP7__Address__c > NewAddres = (List < ERP7__Address__c > ) JSON.deserialize(NewAddres1, List < ERP7__Address__c > .class);
        returnClass RC = new returnClass();
        ERP7__Address__c Address = NewAddres[0];
        Address.ERP7__Active__c = true;
        Address.ERP7__State__c = State;
        Address.ERP7__Country__c = Country;
        if(Address.ERP7__Postal_Code__c != Null && Address.ERP7__Postal_Code__c != '') Address.Name = Address.ERP7__Postal_Code__c;
        try {
            if(Schema.sObjectType.ERP7__Address__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Active__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isUpdateable() && Schema.SObjectType.ERP7__Address__c.isCreateable() && Schema.SObjectType.ERP7__Address__c.isUpdateable()){upsert Address;}else{/*not allowed to insert address*/}
            
            RC.Error = false;
            RC.value = Address.Id;
        } catch(exception ex) {   RC.Error = true;  RC.errorMsg = ex.getMessage(); }
        return Address;
    }
     
    @AuraEnabled
    public static loyaltyWrap loyaltyProcessing(String SalesOrder2Creates1,String Customers1, Decimal FinalDues, Decimal TotalDues, Decimal LoyaltyAmounts, Decimal LoyaltyPoint_s, Decimal customerCreditLimit) {
         
        List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        ERP7__Sales_Order__c SalesOrder2Create = SalesOrder2Creates[0];
        Account Customer = Customers[0];
        Decimal FinalDue = FinalDues;
        Decimal TotalDue = TotalDues;
        Decimal LoyaltyAmount = LoyaltyAmounts;
        Decimal Loyalty_Points = LoyaltyPoint_s;
        loyaltyWrap lWrap = new loyaltyWrap();
         
        try {
            List < Loyalty_Setup__c > Loyaltysetup;    
            if(Schema.sObjectType.Loyalty_Setup__c.isAccessible()){    
                Loyaltysetup = [Select Id, Name, Points_Per_Unit_Amount__c, Organisation__c, Organisation_Business_Unit__c
                From Loyalty_Setup__c
                Where Organisation_Business_Unit__c = : SalesOrder2Create.Organisation_Business_Unit__c And
                Organisation__c = : SalesOrder2Create.Organisation__c
                order by CreatedDate Asc Limit 1];
            }
            if (Loyaltysetup.size() > 0) {
                Decimal pointsPerUnit;
                if(Schema.sobjectType.Loyalty_Setup__c.fields.Points_Per_Unit_Amount__c.isAccessible())  pointsPerUnit = Loyaltysetup[0].Points_Per_Unit_Amount__c;
                Decimal curCreditlimit = customerCreditLimit;
                Decimal curAmount = (pointsPerUnit == 0) ? 0 : curCreditlimit / pointsPerUnit;
                if (curAmount <= finalDue && finalDue > 0 && curAmount > 0) {
                    if (loyaltyAmount != null && loyalty_Points != null) {
                        finalDue = finalDue - curAmount;
                        loyaltyAmount = (curAmount + loyaltyAmount).setScale(2);
                        loyalty_Points = curCreditlimit + loyalty_Points;
                        customerCreditLimit = 0;
                    } else { 
                        finalDue = finalDue - curAmount;  loyaltyAmount = curAmount; loyalty_Points = curCreditlimit;  customerCreditLimit = 0;
                    } 
                } else if (curAmount > finalDue && finalDue > 0 && curAmount > 0) {
                    customerCreditLimit = (curCreditlimit - (pointsPerUnit * (totalDue - ((SalesOrder2Create.Amount_Paid__c != Null) ? SalesOrder2Create.Amount_Paid__c : 0) - ((loyaltyAmount != null) ? loyaltyAmount : 0))).setScale(2));
                    loyaltyAmount = ((loyaltyAmount != null) ? loyaltyAmount : 0) + finalDue;
                    finalDue = 0; 
                    if(Schema.sobjectType.ERP7__Sales_Order__c.fields.Amount_Paid__c.isAccessible()) loyalty_Points = (pointsPerUnit * (totalDue - ((SalesOrder2Create.Amount_Paid__c != Null) ? SalesOrder2Create.Amount_Paid__c : 0))).setScale(2);
                }
            }
            lWrap.customerCreditLimit = String.valueof(customerCreditLimit);
            lWrap.FinalDue = FinalDue.setScale(2);
            lWrap.TotalDue = TotalDue;
            lWrap.loyaltyAmount = loyaltyAmount;
            lWrap.loyaltyPoints = loyalty_Points;
            
            
        } catch(exception ex){ }
        //process
        //save order and others
        //get All
        return lWrap;
    }
    
    @AuraEnabled
    public static returnClass CreditProcessing(String SalesOrder2Creates1, String Invoices1, String Customers1, Decimal FinalDues, Decimal TotalDues, Decimal CreditAmounts, Decimal CreditAmount2Uses) {
          
        List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
        List < ERP7__Invoice__c > Invoices = (List < ERP7__Invoice__c > ) JSON.deserialize(Invoices1, List < ERP7__Invoice__c > .class);
        List < Account > Customers = (List < Account > ) JSON.deserialize(Customers1, List < Account > .class);
        ERP7__Sales_Order__c SalesOrder2Create = SalesOrder2Creates[0];
        ERP7__Invoice__c Invoice = Invoices[0];
        Account Customer = Customers[0];
        Decimal FinalDue = FinalDues;
        Decimal TotalDue = TotalDues;
        Decimal CreditAmount = CreditAmounts;
        Decimal CreditAmount2Use = CreditAmount2Uses;
        returnClass RC = new returnClass();
        Sales_Order__c currentSalesorder; 
        
        currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                  Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                  Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                  Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c,
                                  Bill_To_Address__r.County__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c, ERP7__Issue_Invoice__c
                                  From Sales_Order__c 
                                  Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
        
        List<ERP7__Payment__c> Payments = new List<ERP7__Payment__c>();
        
        ERP7__Payment__c Payment = new ERP7__Payment__c();
            if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
            if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())payment.Accounts__c = currentSalesorder.Account__c;
            if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
            if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
            if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
            if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible()) payment.Total_Amount__c = CreditAmount2Use;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible())payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible())payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible())payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.County__c.isAccessible())payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible())payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible())payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
            payment.ERP7__Type__c = 'Debit';
            Payment.ERP7__Payment_Type__c = 'Credit';
            payment.ERP7__Invoice__c = Invoice.Id;
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            payment.Status__c = 'Paid'; 
        //Payments.add(payment);
        
        Decimal creditBalance = CreditAmount2Use;
        Decimal finalBalance = 0;
        
        List<ERP7__Credit_Note__c> creditNotes = [SELECT Id, Name, ERP7__Amount__c , ERP7__Credit__c , ERP7__Debit__c, ERP7__Balance__c FROM ERP7__Credit_Note__c where ERP7__Account__c =:Customer.Id and ERP7__Balance__c > 0 order by CreatedDate Asc];
        List< ERP7__PrePayment__c > prePayments = [SELECT Id, Name, ERP7__Amount__c , ERP7__Credit__c , ERP7__Debit__c, ERP7__Balance__c FROM ERP7__PrePayment__c where ERP7__Account__c =:Customer.Id and ERP7__Balance__c > 0 order by CreatedDate Asc];
        
        for(ERP7__Credit_Note__c CN : creditNotes){
            if(creditBalance > 0){
                ERP7__Payment__c Payment1 = new ERP7__Payment__c();
                    if(Schema.sobjectType.Sales_Order__c.isAccessible())Payment1.Sales_Order__c = currentSalesorder.Id;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())Payment1.Accounts__c = currentSalesorder.Account__c;
                    if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                    if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                    if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible())Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible())Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible())Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.County__c.isAccessible())Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible())Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible())Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                    if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())Payment1.Account__c = currentSalesorder.Organisation__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                    Payment1.ERP7__Type__c = 'Debit';  Payment1.ERP7__Payment_Type__c = 'Credit';  Payment1.ERP7__Invoice__c = Invoice.Id;
                    String rTypeP1;
                    if(Schema.sobjectType.RecordType.isAccessible()) rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                    if(String.isNotEmpty(rTypeP1)){   Payment1.RecordTypeId = rTypeP1;   }
                    Payment1.Status__c = 'Paid';   Payment1.ERP7__Posted__c = true;  Payment1.ERP7__Posted_Date__c = system.Today();  Payment1.ERP7__Credit_Note__c = CN.Id;
                    if(CN.ERP7__Balance__c >= creditBalance) {
                        Payment1.Amount__c = creditBalance;  finalBalance += Payment1.Amount__c;  creditBalance = 0;
                    } else {
                        Payment1.Amount__c = CN.ERP7__Balance__c;  creditBalance = creditBalance - CN.ERP7__Balance__c;  finalBalance += Payment1.Amount__c;
                    }
                Payments.add(Payment1);
                
            } else break;
        }
        
        Decimal finalBalance1 = 0;
        for(ERP7__PrePayment__c CN : prePayments){
            if(creditBalance > 0){
                ERP7__Payment__c Payment1 = new ERP7__Payment__c();
                    if(Schema.sobjectType.Sales_Order__c.isAccessible())Payment1.Sales_Order__c = currentSalesorder.Id;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())Payment1.Accounts__c = currentSalesorder.Account__c;
                    if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                    if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                    if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible())Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible())Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible())Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.County__c.isAccessible())Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible())Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible())Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                    if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())Payment1.Account__c = currentSalesorder.Organisation__c;
                    if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                    Payment1.ERP7__Type__c = 'Debit';  Payment1.ERP7__Payment_Type__c = 'Credit';  Payment1.ERP7__Invoice__c = Invoice.Id;
                    String rTypeP1;
                    if(Schema.sobjectType.RecordType.isAccessible()) rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                    if(String.isNotEmpty(rTypeP1)){  Payment1.RecordTypeId = rTypeP1;   }
                    Payment1.Status__c = 'Paid';   Payment1.ERP7__Posted__c = true;  Payment1.ERP7__Posted_Date__c = system.Today();  Payment1.ERP7__PrePayment__c = CN.Id;
                    if(CN.ERP7__Balance__c >= creditBalance) {
                        Payment1.Amount__c = creditBalance;   creditBalance = 0;  finalBalance1 += Payment1.Amount__c;
                    } else {
                        Payment1.Amount__c = CN.ERP7__Balance__c; creditBalance = creditBalance - CN.ERP7__Balance__c;  finalBalance1 += Payment1.Amount__c;
                    }
                Payments.add(Payment1);
                
            } else break;
        }
        
        if(finalBalance > 0) Customer.ERP7__Debit_Balance__c = finalBalance;
        if(finalBalance1 > 0) Customer.ERP7__Debit_Balance__c = finalBalance1;
        if(Schema.sObjectType.Account.fields.ERP7__Debit_Balance__c.isCreateable() && Schema.sObjectType.Account.fields.ERP7__Debit_Balance__c.isUpdateable() && Schema.SObjectType.Account.isCreateable() && Schema.SObjectType.Account.isUpdateable()){upsert Customer;}else{/*not allowed to upsert Account*/}
        //try {
        
        DMLManager.upsertAsUser(Payments); 
        
        
        
        RC.Error = false; 
        RC.errorMsg = '';
        RC.Value = currentSalesorder.Name;
            
        /*} catch(exception ex){ 
            RC.Error = true; 
            RC.errorMsg = '';
            RC.Value = currentSalesorder.Name;
        }*/
        
        return RC;
    }
    
    @AuraEnabled
    public static Boolean CreateCashPayment(String SalesOrder2Creates1, String Payments) {
        List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
        ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
        
        Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                  Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                  Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                  Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c,
                                  Bill_To_Address__r.County__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c, ERP7__Issue_Invoice__c
                                  From Sales_Order__c 
                                  Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
        
        if(Schema.sobjectType.Sales_Order__c.isAccessible()) payment.Sales_Order__c = currentSalesorder.Id;
        if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible()) payment.Accounts__c = currentSalesorder.Account__c;
        if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
        if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
        if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
        //if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible())payment.Total_Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible())payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible())payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible())payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.County__c.isAccessible())payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible())payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible())payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
        if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
        payment.ERP7__Type__c = 'Debit';
        Payment.ERP7__Payment_Type__c = 'Cash';
        String rTypeP;
        if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Cash_Payments');
        if(String.isNotEmpty(rTypeP)){
            payment.RecordTypeId = rTypeP; 
        }
        
        payment.Status__c = 'Paid'; 
        DMLManager.upsertAsUser(payment); 
      
        return true;
    }
    
    @AuraEnabled
    public static Boolean CreateBankPayment(String SalesOrder2Creates1, String Payments) {
        List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
        ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
        
        Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                  Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                  Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                  Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c,
                                  Bill_To_Address__r.County__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c, ERP7__Issue_Invoice__c
                                  From Sales_Order__c 
                                  Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
        
        if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
        if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())payment.Accounts__c = currentSalesorder.Account__c;
        if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
        if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
        if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
        //if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible())payment.Total_Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible())payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible())payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible())payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.County__c.isAccessible())payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible())payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible())payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
        if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
        if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
        payment.ERP7__Type__c = 'Debit';
        Payment.ERP7__Payment_Type__c = 'Bank';
        String rTypeP;
        if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Bank_Payments');
        if(String.isNotEmpty(rTypeP)){
            payment.RecordTypeId = rTypeP; 
        }
        
        payment.Status__c = 'Paid'; 
        DMLManager.upsertAsUser(payment); 
      
        return true;
        
    }
    
    @AuraEnabled
    global static Credentials__c getMerchantId(){
        Credentials__c cred = [Select Id, Name, Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c, ERP7__Account_Id__c, ERP7__Bank_COA_ID__c  
                               From Credentials__c
                               Where Active__c =: true And
                               Name = 'Paypal'
                               Limit 1];
        
        return cred;
    }   
    
    @AuraEnabled
    global static Account getCustomerDetails(String AccountId) {
       /*String AccId=null;
       AccId=ApexPages.currentPage().getParameters().get('AccountId');// ApexPages.currentPage().getParameters().get('AccountId'); //'0011o00001TzfeK'; 
       
        */
      if(String.isNotEmpty(AccountId))  
       return Database.query('SELECT Id, Name, Phone, ERP7__Email__c, BillingStreet,BillingCity,BillingState,BillingPostalCode,ShippingStreet,ShippingCity'+
                              ' FROM Account WHERE Id='+'\''+String.escapeSingleQuotes(AccountId)+'\''); //ApexPages.currentPage().getParameters().get('AccountId')
      else return null;                                    
    }
    
    @AuraEnabled
    global static String CreateAccountCardPayment(String accId1, String Payments, String PaymentMethods, String CVV) {
        String ErrorMsgPayment = '';
        try{
            
            String cvvs = CVV;
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethods, ERP7__Payment_Method__c .class);
            Account acc=[Select Id,Name,ERP7__Account_Profile__c,ERP7__Organisation__c,ERP7__Account_Profile__r.ERP7__Channel__c from Account where Id =:accId1 Limit 1];
            
            List<ERP7__Invoice__c> currentInvoices = [Select Id, Name, ERP7__Total_Due__c, ERP7__Organisation__c ,ERP7__Order__c,ERP7__Order__r.ERP7__Channel__c,ERP7__Order__r.ERP7__Organisation__c,ERP7__Account__c,ERP7__Order_S__c,ERP7__Order_S__r.ERP7__Channel__c,ERP7__Order_S__r.ERP7__Organisation__c
                                               from ERP7__Invoice__c 
                                               Where ERP7__Account__c =:accId1 AND ERP7__Total_Due__c > 0];
            Decimal TotalDueAmount=0;
            for(ERP7__Invoice__c inv1:currentInvoices) TotalDueAmount+=inv1.ERP7__Total_Due__c;
            if(TotalDueAmount == 0) return 'Payment already had been made'; if(Payment.ERP7__Total_Amount__c != TotalDueAmount) return 'Security Alert : Total Due Mismatched';
            
            if(Schema.sobjectType.ERP7__Invoice__c.Fields.ERP7__Account__c.isAccessible()){ payment.ERP7__Account__c = acc.Id;}
                       
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            
            Credentials__c paypalSetup;
            
            if(Schema.sObjectType.Credentials__c.isAccessible()) {  //Here ERP7__Channel_Id__c used for taking Organization Id
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize') AND //
                                              ERP7__Channel_Id__c =: acc.ERP7__Organisation__c
                                              Limit 1])
                    paypalSetup=crd;
                /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal') AND //
                               ERP7__Channel_Id__c =: acc.ERP7__Organisation__c
                               Limit 1];*/
                if(paypalSetup == null){
                    paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];
                }
            }
            
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.Payment__c.Fields.First_Name__c.isAccessible() && payment.First_Name__c != Null) FirstName = payment.First_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Last_Name__c.isAccessible() && payment.Last_Name__c != Null) LastName = payment.Last_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Email_Address__c.isAccessible() && payment.Email_Address__c != Null) Email = payment.Email_Address__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line1__c.isAccessible() && payment.Address_Line1__c != Null) Address_Line1 = payment.Address_Line1__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line2__c.isAccessible() && payment.Address_Line2__c != Null) Address_Line2 = payment.Address_Line2__c;        
            if(Schema.sObjectType.Payment__c.Fields.City__c.isAccessible() && payment.City__c != Null) City = payment.City__c;
            if(Schema.sObjectType.Payment__c.Fields.State__c.isAccessible() &&  payment.State__c != Null) State = payment.State__c;
            if(Schema.sObjectType.Payment__c.Fields.Country__c.isAccessible() && payment.Country__c != Null) Country = payment.Country__c;
            if(Schema.sObjectType.Payment__c.Fields.Zipcode__c.isAccessible() && payment.Zipcode__c != Null) Zipcode = payment.Zipcode__c;
            if(paypalSetup.ERP7__Bank_COA_ID__c != null ){ if(Schema.sObjectType.Payment__c.Fields.ERP7__Payment_Account__c.isAccessible()) payment.ERP7__Payment_Account__c  = paypalSetup.ERP7__Bank_COA_ID__c; }

            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(isMultiCurrency){ String Currency_Code = (String)Database.Query('select CurrencyIsoCode from ERP7__Payment__c ')[0].get('CurrencyIsoCode'); myCur = Currency_Code;
            }else{ myCur = UserInfo.getDefaultCurrency();}
            
            myCurrency = myCur;  
            if(payment.Total_Amount__c != Null) Amount = String.valueof(payment.Total_Amount__c);
            AccId = acc.ERP7__Organisation__c;
            
            ipstring = '';
                
            if(paypalSetup.Name == 'Paypal'){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                String url = String.valueof(paypalSetup.URL__c);
                String soapXML;
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                        
                soapXML =  Label.PayPalAPI;
                soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
                soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
                soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
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
                XmlStreamReader reader = res.getXmlStreamReader(); Status = readXMLResponse(reader,'Ack');
                reader = res.getXmlStreamReader(); CorrID = readXMLResponse(reader, 'CorrelationID');   reader = res.getXmlStreamReader(); CVV2 = readXMLResponse(reader, 'CVV2Code');   reader = res.getXmlStreamReader(); AVSCode = readXMLResponse(reader, 'AVSCode');         
                rawResponse = xml;        
                reader = res.getXmlStreamReader(); ErrMsg = readXMLResponse(reader, 'LongMessage');  reader = res.getXmlStreamReader(); sErrMsg = readXMLResponse(reader, 'ShortMessage');  reader = res.getXmlStreamReader(); ErrCode= readXMLResponse(reader, 'ErrorCode');   reader = res.getXmlStreamReader(); transid = readXMLResponse(reader, 'TransactionID');              
               
                payment.AVS_Code__c = AVSCode; payment.CVV2_Code__c = CVV2; payment.Transaction_Status__c = Status; payment.Error_Code__c = ErrCode; payment.Transaction_ID__c = transid; payment.sError__c = sErrMsg; payment.Correlation_ID__c = CorrID; payment.Error_Message__c = ErrMsg;
                if(Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
                
            } 
            else if(paypalSetup.Name == 'Authorize.Net' || paypalSetup.Name == 'Authorize'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                string url = paypalSetup.ERP7__URL__c; String Expiration = Expiry_Month + Expiry_Year; String Address = Address_Line1 +' '+ Address_Line2; string expiryDate = Expiry_Year + '-' + Expiry_Month;
                                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                    soapXML += '<merchantAuthentication>';
                        soapXML += '<name>' + paypalSetup.Username_Login__c.escapeXml() + '</name>';
                        soapXML += '<transactionKey>' + paypalSetup.Password_Transkey__c.escapeXml() + '</transactionKey>';
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
                            soapXML += '<city>' + city.escapeXml() + '</city>';
                            soapXML += '<state>' + State.escapeXml() + '</state>';
                            soapXML += '<zip>' + Zipcode.escapeXml() + '</zip>';
                            soapXML += '<country>' + country.escapeXml() + '</country>';
                        soapXML += '</billTo>';
                    soapXML += '</transactionRequest>';
                soapXML += '</createTransactionRequest>';
                
                HttpRequest reqr = new HttpRequest();
                Http hr = new Http(); reqr.setBody(soapXML);    reqr.setMethod('POST'); reqr.setEndpoint(url); reqr.setHeader('Content-length', '2000');  reqr.setHeader('Content-Type', 'text/xml');
                
                if(Test.isRunningTest()){
                    response_1 = '<createTransactionResponse xmlns:xsi="'+Label.POSLightningLabel2+'-instance" xmlns:xsd="'+Label.POSLightningLabel2+'" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                } else{
                    HttpResponse resr = hr.send(reqr); response_1 = soapXML; response_1 = resr.getBody(); resStatus = resr.getStatus();
                    
                }
                
                if (response_1 != null) {
                    string resultCode = response_1.substringBetween('<resultCode>', '</resultCode>');
                    string responseCode = response_1.substringBetween('<responseCode>', '</responseCode>');
                
                    if (resultCode == 'Ok') {
                        if (responseCode == '1'){
                            string description = response_1.substringBetween('<description>', '</description>');
                            transId = response_1.substringBetween('<transId>', '</transId>');
                            string transHash = response_1.substringBetween('<transHash>', '</transHash>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Approved'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = description; }
                            if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) { payment.Status__c = 'Paid'; }    
                        }
                
                        if (responseCode == '2'){
                            /*'--- Inside Declined.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Declined'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = errorMessage; }
                        }
                
                        if (responseCode == '4'){
                            /*'--- Inside Held for Review.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Held for Review'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = description; }
                        }
                
                    }else {
                        if (responseCode == '3'){
                            /*'--- Inside Error.'*/
                            string description = response_1.substringBetween('<description>', '</description>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Error'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = errorMessage; }
                        }
                    } 
                } else payment.sError__c = 'Null Response.';  
                
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                
            } 
            else {
                ErrorMsgPayment = 'Please setup the payment terminal';
            }
            if(payment.Transaction_Status__c == 'Completed' || payment.Transaction_Status__c == 'SuccessWithWarning' || payment.Transaction_Status__c == 'Success' || payment.Transaction_Status__c == 'Approved'){
                payment.ERP7__Type__c = 'Debit';
                payment.ERP7__Payment_Type__c = 'Card';
                payment.ERP7__Transaction_Type__c = 'CreditPayment';
                payment.ERP7__Posted__c = true;
                payment.ERP7__Posted_Date__c = system.today();
                //upsert payment; 
                
                List<ERP7__Payment__c> paymentList=new List<ERP7__Payment__c>();
                for(ERP7__Invoice__c inv:currentInvoices){
                    ERP7__Payment__c newPayment=new ERP7__Payment__c();
                    newPayment=payment.clone();
                    newPayment.ERP7__Total_Amount__c=inv.ERP7__Total_Due__c;
                    newPayment.ERP7__Invoice__c=inv.Id;
                    if(inv.ERP7__Order__c != null) newPayment.ERP7__Sales_Order__c=inv.ERP7__Order__c;
                    else if(inv.ERP7__Order_S__c != null) newPayment.ERP7__Order__c=inv.ERP7__Order_S__c;
                    if(inv.ERP7__Order__r.ERP7__Organisation__c != null) newPayment.ERP7__Account__c = inv.ERP7__Order__r.ERP7__Organisation__c;
                    else if(inv.ERP7__Order_S__r.ERP7__Organisation__c != null) newPayment.ERP7__Account__c = inv.ERP7__Order_S__r.ERP7__Organisation__c;
                    paymentList.add(newPayment);
                    
                }
                if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable() && Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isUpdateable()){upsert paymentList;}else{ErrorMsgPayment ='Not Allowed to upsert payment';}
                /*List<ERP7__Payment_Applied_on_Invoice__c> paoiList=new List<ERP7__Payment_Applied_on_Invoice__c>();
                for(ERP7__Invoice__c inv:currentInvoices){
                    ERP7__Payment_Applied_on_Invoice__c paoi=new ERP7__Payment_Applied_on_Invoice__c();
                    paoi.ERP7__Invoice__c=inv.Id;
                    paoi.ERP7__Payment__c=payment.Id;
                    paoi.Name=inv.Name+' : '+payment.Name;
                    paoi.ERP7__Amount__c=payment.ERP7__Total_Amount__c;
                    paoi.ERP7__Type__c='Debit';
                    paoi.ERP7__Applied_Date__c=System.today();
                    paoiList.add(paoi);
                }
                 paoiList;*/
            } else {
                if(payment.sError__c != Null) ErrorMsgPayment = payment.sError__c;
            }
            return ErrorMsgPayment;   
        }catch(exception ex){ ErrorMsgPayment = ex.getMessage(); ErrorMsgPayment += ' Line No: '+ex.getLineNumber(); ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString();  return ErrorMsgPayment;
        }
    }
    
    @AuraEnabled
    global static String CreateInvoiceCardPayment(String invId, String Payments, String PaymentMethods, String CVV) {
        
        String ErrorMsgPayment = '';
        try{
            String cvvs = CVV;
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethods, ERP7__Payment_Method__c .class);
            
            ERP7__Invoice__c currentInvoice = [Select Id, Name, ERP7__Total_Due__c, ERP7__Organisation__c ,ERP7__Order__c,ERP7__Order__r.ERP7__Channel__c,ERP7__Order_S__c,ERP7__Order_S__r.ERP7__Channel__c
                                               from ERP7__Invoice__c 
                                               Where Id =: invId Limit 1];
            
            if(Schema.sobjectType.ERP7__Invoice__c.Fields.ERP7__Organisation__c.isAccessible())payment.Account__c = currentInvoice.ERP7__Organisation__c;
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            
            Credentials__c paypalSetup;
            /*if(Schema.sObjectType.Credentials__c.isAccessible()) {
                paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c, ERP7__Bank_COA_ID__c 
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal')  // 
                               Limit 1];
            }*/
            if(Schema.sObjectType.Credentials__c.isAccessible()) {
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize') AND
                                              ERP7__Channel_Id__c =: currentInvoice.ERP7__Organisation__c
                                              Limit 1])
                    paypalSetup=crd;
                /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal') AND //
                               ERP7__Channel_Id__c =: currentInvoice.ERP7__Organisation__c
                               Limit 1];*/
                if(paypalSetup == null){
                    paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];
                }
            }
            
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.Payment__c.Fields.First_Name__c.isAccessible() && payment.First_Name__c != Null) FirstName = payment.First_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Last_Name__c.isAccessible() && payment.Last_Name__c != Null) LastName = payment.Last_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Email_Address__c.isAccessible() && payment.Email_Address__c != Null) Email = payment.Email_Address__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line1__c.isAccessible() && payment.Address_Line1__c != Null) Address_Line1 = payment.Address_Line1__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line2__c.isAccessible() && payment.Address_Line2__c != Null) Address_Line2 = payment.Address_Line2__c;        
            if(Schema.sObjectType.Payment__c.Fields.City__c.isAccessible() && payment.City__c != Null) City = payment.City__c;
            if(Schema.sObjectType.Payment__c.Fields.State__c.isAccessible() &&  payment.State__c != Null) State = payment.State__c;
            if(Schema.sObjectType.Payment__c.Fields.Country__c.isAccessible() && payment.Country__c != Null) Country = payment.Country__c;
            if(Schema.sObjectType.Payment__c.Fields.Zipcode__c.isAccessible() && payment.Zipcode__c != Null) Zipcode = payment.Zipcode__c;
            if(paypalSetup.ERP7__Bank_COA_ID__c != null ){ if(Schema.sObjectType.Payment__c.Fields.ERP7__Payment_Account__c.isAccessible()) payment.ERP7__Payment_Account__c  = paypalSetup.ERP7__Bank_COA_ID__c; }

            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(isMultiCurrency){String INVIdd=currentInvoice.Id; String Currency_Code = (String)Database.Query('select CurrencyIsoCode from ERP7__Invoice__c where Id =:INVIdd')[0].get('CurrencyIsoCode'); myCur = Currency_Code;
                //String Currency_Code = (String)Database.Query('select CurrencyIsoCode from ERP7__Payment__c ')[0].get('CurrencyIsoCode'); myCur = Currency_Code;
            }else{ myCur = UserInfo.getDefaultCurrency();}
            
            myCurrency = myCur;  
            if(payment.Total_Amount__c != Null) Amount = String.valueof(payment.Total_Amount__c);
            AccId = currentInvoice.ERP7__Organisation__c;
            
            ipstring = '';
                
            if(paypalSetup.Name == 'Paypal'){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                String url = String.valueof(paypalSetup.URL__c);
                String soapXML;
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                        
                soapXML =  Label.PayPalAPI;
                soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
                soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
                soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
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
                XmlStreamReader reader = res.getXmlStreamReader(); Status = readXMLResponse(reader,'Ack');
                reader = res.getXmlStreamReader(); CorrID = readXMLResponse(reader, 'CorrelationID');   reader = res.getXmlStreamReader(); CVV2 = readXMLResponse(reader, 'CVV2Code');   reader = res.getXmlStreamReader(); AVSCode = readXMLResponse(reader, 'AVSCode');         
                rawResponse = xml;        
                reader = res.getXmlStreamReader(); ErrMsg = readXMLResponse(reader, 'LongMessage');  reader = res.getXmlStreamReader(); sErrMsg = readXMLResponse(reader, 'ShortMessage');  reader = res.getXmlStreamReader(); ErrCode= readXMLResponse(reader, 'ErrorCode');   reader = res.getXmlStreamReader(); transid = readXMLResponse(reader, 'TransactionID');              
               
                payment.AVS_Code__c = AVSCode; payment.CVV2_Code__c = CVV2; payment.Transaction_Status__c = Status; payment.Error_Code__c = ErrCode; payment.Transaction_ID__c = transid; payment.sError__c = sErrMsg; payment.Correlation_ID__c = CorrID; payment.Error_Message__c = ErrMsg;
                if(Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
                
            } 
            else if(paypalSetup.Name == 'Authorize.Net' || paypalSetup.Name == 'Authorize'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                string url = paypalSetup.ERP7__URL__c;
                String Expiration = Expiry_Month + Expiry_Year;
                String Address = Address_Line1 +' '+ Address_Line2;
                string expiryDate = Expiry_Year + '-' + Expiry_Month;
                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                    soapXML += '<merchantAuthentication>';
                        soapXML += '<name>' + paypalSetup.Username_Login__c.escapeXml() + '</name>';
                        soapXML += '<transactionKey>' + paypalSetup.Password_Transkey__c.escapeXml() + '</transactionKey>';
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
                            soapXML += '<city>' + city.escapeXml() + '</city>';
                            soapXML += '<state>' + State.escapeXml() + '</state>';
                            soapXML += '<zip>' + Zipcode.escapeXml() + '</zip>';
                            soapXML += '<country>' + country.escapeXml() + '</country>';
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
                    response_1 = '<createTransactionResponse xmlns:xsi="'+Label.POSLightningLabel2+'-instance" xmlns:xsd="'+Label.POSLightningLabel2+'" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                } else{
                    HttpResponse resr = hr.send(reqr); response_1 = soapXML; response_1 = resr.getBody(); resStatus = resr.getStatus();
                    
                }
                
                if (response_1 != null) {
                    string resultCode = response_1.substringBetween('<resultCode>', '</resultCode>');
                    string responseCode = response_1.substringBetween('<responseCode>', '</responseCode>');
                
                    if (resultCode == 'Ok') {
                        if (responseCode == '1'){
                            /*'--- Inside Approved.'*/
                            string description = response_1.substringBetween('<description>', '</description>');
                            transId = response_1.substringBetween('<transId>', '</transId>');
                            string transHash = response_1.substringBetween('<transHash>', '</transHash>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Approved'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = description; }
                            if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) { payment.Status__c = 'Paid'; }    
                        }
                
                        if (responseCode == '2'){
                            /*--- Inside Declined.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Declined'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = errorMessage; }
                        }
                
                        if (responseCode == '4'){
                            /*'--- Inside Held for Review.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Held for Review'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = description; }
                        }
                
                    }else {
                        if (responseCode == '3'){
                            /*'--- Inside Error.'*/
                            string description = response_1.substringBetween('<description>', '</description>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Error'; }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = errorMessage; }
                        }
                    } 
                } else payment.sError__c = 'Null Response.';  
                
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                
            } 
            else {
                ErrorMsgPayment = 'Please setup the payment terminal';
            }
            if(payment.Transaction_Status__c == 'Completed' || payment.Transaction_Status__c == 'SuccessWithWarning' || payment.Transaction_Status__c == 'Success' || payment.Transaction_Status__c == 'Approved'){
                payment.ERP7__Type__c = 'Debit';
                Payment.ERP7__Payment_Type__c = 'Card';
                Payment.ERP7__Transaction_Type__c = 'CreditPayment';
                Payment.ERP7__Posted__c = true;
                Payment.ERP7__Posted_Date__c = system.today();
                if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable() && Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isUpdateable()){upsert payment;}else{ErrorMsgPayment ='Not allowed to upsert Payment';} 
            } else { 
                if(payment.sError__c != Null) ErrorMsgPayment = payment.sError__c;
            }
            return ErrorMsgPayment;   
        }catch(exception ex){
            ErrorMsgPayment = ex.getMessage(); ErrorMsgPayment += ' Line No: '+ex.getLineNumber(); ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString();
            return ErrorMsgPayment;
        }
    }
    
    @AuraEnabled
    global static String CreateCardPayment(List < ERP7__Sales_Order__c > SalesOrder2Creates, String Payments, String PaymentMethods, String CVV) {
        /*return null;*/
        // List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
        String ErrorMsgPayment = '';
        try{
            
            String cvvs = CVV;
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethods, ERP7__Payment_Method__c .class);
            
            Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Issue_Invoice__c,
                                      Bill_To_Address__r.County__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c
                                      From Sales_Order__c 
                                      Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
            
            if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
            if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())payment.Accounts__c = currentSalesorder.Account__c;
            if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null && !(payment.First_Name__c != Null && payment.First_Name__c != '')) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
            if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null && !(payment.Last_Name__c != Null && payment.Last_Name__c != '')) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
            if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
            //if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible())payment.Total_Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible() && !(payment.Address_Line1__c != Null && payment.Address_Line1__c != ''))payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible() && !(payment.Address_Line2__c != Null && payment.Address_Line2__c != ''))payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible() && !(payment.City__c != Null && payment.City__c != ''))payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.State__c.isAccessible() && !(payment.State__c != Null && payment.State__c != ''))payment.State__c = currentSalesorder.Bill_To_Address__r.State__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible() && !(payment.Country__c != Null && payment.Country__c != ''))payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible() && !(payment.Zipcode__c != Null && payment.Zipcode__c != ''))payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
            if(Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('ERP7__Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            
            
            ERP7__Credentials__c paypalSetup;
            if(Schema.sObjectType.Credentials__c.isAccessible()) {
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize') AND //
                                              ERP7__Channel_Id__c =: currentSalesorder.ERP7__Channel__c
                                              Limit 1])
                    paypalSetup=crd;
                /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal') AND //
                               ERP7__Channel_Id__c =: currentSalesorder.ERP7__Channel__c
                               Limit 1];*/
                if(paypalSetup == null){
                    paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];
                }
            }
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.ERP7__Payment__c.Fields.First_Name__c.isAccessible() && payment.First_Name__c != Null) FirstName = payment.First_Name__c;
            if(Schema.sObjectType.ERP7__Payment__c.Fields.Last_Name__c.isAccessible() && payment.Last_Name__c != Null) LastName = payment.Last_Name__c;
            if(Schema.sObjectType.ERP7__Payment__c.Fields.Email_Address__c.isAccessible() && payment.Email_Address__c != Null) Email = payment.Email_Address__c;
            if(Schema.sObjectType.ERP7__Payment__c.Fields.Address_Line1__c.isAccessible() && payment.Address_Line1__c != Null) Address_Line1 = payment.Address_Line1__c;
            if(Schema.sObjectType.ERP7__Payment__c.Fields.Address_Line2__c.isAccessible() && payment.Address_Line2__c != Null) Address_Line2 = payment.Address_Line2__c;        
            if(Schema.sObjectType.ERP7__Payment__c.Fields.City__c.isAccessible() && payment.City__c != Null) City = payment.City__c;
            if(Schema.sObjectType.ERP7__Payment__c.Fields.State__c.isAccessible() &&  payment.State__c != Null) State = payment.State__c;
            if(Schema.sObjectType.ERP7__Payment__c.Fields.Country__c.isAccessible() && payment.Country__c != Null) Country = payment.Country__c;
            if(Schema.sObjectType.ERP7__Payment__c.Fields.Zipcode__c.isAccessible() && payment.Zipcode__c != Null) Zipcode = payment.Zipcode__c;    
            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(isMultiCurrency){ String Currency_Code = (String)Database.Query('select CurrencyIsoCode from ERP7__Payment__c ')[0].get('CurrencyIsoCode'); myCur = Currency_Code;
            }else{ myCur = UserInfo.getDefaultCurrency();}
                        
            myCurrency = myCur;  
            if(payment.Total_Amount__c != Null) Amount = String.valueof(payment.Total_Amount__c);
            AccId = currentSalesorder.Organisation__c;
            obuId = currentSalesorder.Organisation_Business_Unit__c;
            orderId = currentSalesorder.Id;
            ipstring = '';
                
            if(paypalSetup.Name == 'Paypal'){
                // Instantiate a new http object
                Http h = new Http();
                    
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                
                // The webservice url -  Pass in the endpoint to be used using the string url
                String url = String.valueof(paypalSetup.URL__c);
                String soapXML;
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                        
                soapXML =  Label.PayPalAPI;
                soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
                soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
                soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
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
                XmlStreamReader reader = res.getXmlStreamReader(); Status = readXMLResponse(reader,'Ack');  reader = res.getXmlStreamReader();  CorrID = readXMLResponse(reader, 'CorrelationID');   reader = res.getXmlStreamReader();  CVV2 = readXMLResponse(reader, 'CVV2Code');   reader = res.getXmlStreamReader();  AVSCode = readXMLResponse(reader, 'AVSCode');   rawResponse = xml;   reader = res.getXmlStreamReader();  ErrMsg = readXMLResponse(reader, 'LongMessage');  reader = res.getXmlStreamReader();  sErrMsg = readXMLResponse(reader, 'ShortMessage');  reader = res.getXmlStreamReader();  ErrCode= readXMLResponse(reader, 'ErrorCode');   reader = res.getXmlStreamReader();  transid = readXMLResponse(reader, 'TransactionID');   payment.AVS_Code__c = AVSCode; payment.CVV2_Code__c = CVV2; payment.Transaction_Status__c = Status; payment.Error_Code__c = ErrCode; payment.Transaction_ID__c = transid; payment.sError__c = sErrMsg; payment.Correlation_ID__c = CorrID; payment.Error_Message__c = ErrMsg;
                
            } 
            else if(paypalSetup.Name == 'Authorize.Net'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                string url = paypalSetup.ERP7__URL__c;
                String Expiration = Expiry_Month + Expiry_Year;
                String Address = Address_Line1 +' '+ Address_Line2; //' '+ City +' '+ Country;
                string expiryDate = Expiry_Year + '-' + Expiry_Month;
                                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                    soapXML += '<merchantAuthentication>';
                        soapXML += '<name>' + paypalSetup.Username_Login__c.escapeXml() + '</name>';
                        soapXML += '<transactionKey>' + paypalSetup.Password_Transkey__c.escapeXml() + '</transactionKey>';
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
                            soapXML += '<city>' + city.escapeXml() + '</city>';
                            soapXML += '<state>' + State.escapeXml() + '</state>';
                            soapXML += '<zip>' + Zipcode.escapeXml() + '</zip>';
                            soapXML += '<country>' + country.escapeXml() + '</country>';
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
                    response_1 = '<createTransactionResponse xmlns:xsi="'+Label.POSLightningLabel2+'-instance" xmlns:xsd="'+Label.POSLightningLabel2+'" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                } else{
                    HttpResponse resr = hr.send(reqr);   response_1 = soapXML;  response_1 = resr.getBody();  resStatus = resr.getStatus();
                    
                }
                
                if (response_1 != null) {
                    string resultCode = response_1.substringBetween('<resultCode>', '</resultCode>');
                    string responseCode = response_1.substringBetween('<responseCode>', '</responseCode>');
                
                    if (resultCode == 'Ok') {
                        if (responseCode == '1'){
                            /*--- Inside Approved.'*/
                            string description = response_1.substringBetween('<description>', '</description>');
                            transId = response_1.substringBetween('<transId>', '</transId>');
                            string transHash = response_1.substringBetween('<transHash>', '</transHash>');
                            
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Approved';
                            }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = description;
                            }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Status__c.isUpdateable()) {
                                payment.Status__c = 'Paid';
                            }else{payment.Status__c='Under Process';}   
                        }
                
                        if (responseCode == '2'){
                            /*'--- Inside Declined.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText; else errorMessage += Text;
                
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Declined'; }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = errorMessage; }
                        }
                
                        if (responseCode == '4'){
                            /*'--- Inside Held for Review.'*/
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transId; }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Held for Review'; }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = description; }
                        }
                
                    }else {
                        if (responseCode == '3'){
                            /*'--- Inside Error.'*/
                            string description = response_1.substringBetween('<description>', '</description>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;  else errorMessage += Text;
                                            
                            if (Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Error';  }
                            if (Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = errorMessage; }
                        }
                    } 
                } else payment.sError__c = 'Null Response.';  
                
                if(Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.ERP7__Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                
            } 
            else {
                ErrorMsgPayment = 'Please setup the payment terminal';
            } 
            if(payment.Transaction_Status__c == 'Completed' || payment.Transaction_Status__c == 'SuccessWithWarning' || payment.Transaction_Status__c == 'Success' || payment.Transaction_Status__c == 'Approved'){
                payment.ERP7__Type__c = 'Debit';
                Payment.ERP7__Payment_Type__c = 'Card';
                payment.ERP7__Payment_Date__c=System.today();
                
                if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable() && Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isUpdateable()){upsert payment;}else{ErrorMsgPayment ='Not allowed to upsert payment';} 
            } else { 
                if(payment.sError__c != Null) ErrorMsgPayment = payment.sError__c;
            }
            return ErrorMsgPayment;   
        }catch(exception ex){
            ErrorMsgPayment = ex.getMessage();
            ErrorMsgPayment += ' Line No: '+ex.getLineNumber();
            ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString();
            return ErrorMsgPayment;
        }
    }
    
    /*@AuraEnabled
    public static String multiInvCardPayment(List < ERP7__Sales_Order__c > SalesOrder2Creates, String Payments, String PaymentMethods, String CVV, Address__c billingAddress, String orgId,List<String> selInvList) {
        String ErrorMsgPayment = '';
        try{
            
            String cvvs = CVV;
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethods, ERP7__Payment_Method__c .class);
            Payment.ERP7__Account_Holder_Name__c = PaymentMethod.ERP7__Name_on_Card__c;
            Payment.ERP7__Transaction_Type__c = 'InvoicePayment';
            Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Issue_Invoice__c,
                                      Bill_To_Address__r.County__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, ERP7__Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c
                                      From Sales_Order__c 
                                      Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
            
            if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
            if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())payment.Accounts__c = currentSalesorder.Account__c;
            if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null && !(payment.First_Name__c != Null && payment.First_Name__c != '')) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
            if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null && !(payment.Last_Name__c != Null && payment.Last_Name__c != '')) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
            if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
            //if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible())payment.Total_Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible() && !(payment.Address_Line1__c != Null && payment.Address_Line1__c != ''))payment.Address_Line1__c = billingAddress.ERP7__Address_Line1__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible() && !(payment.Address_Line2__c != Null && payment.Address_Line2__c != ''))payment.Address_Line2__c = billingAddress.Address_Line2__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible() && !(payment.City__c != Null && payment.City__c != ''))payment.City__c = billingAddress.City__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.State__c.isAccessible() && !(payment.State__c != Null && payment.State__c != ''))payment.State__c = billingAddress.State__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible() && !(payment.Country__c != Null && payment.Country__c != ''))payment.Country__c = billingAddress.Country__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible() && !(payment.Zipcode__c != Null && payment.Zipcode__c != ''))payment.Zipcode__c = billingAddress.Postal_Code__c; 
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
            if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
            
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            
            
            ERP7__Credentials__c paypalSetup;
            if(Schema.sObjectType.Credentials__c.isAccessible()) {
                if(orgId != '' && orgId != null){
                    for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize') AND //
                                              ERP7__Channel_Id__c =: orgId
                                              Limit 1])
                    paypalSetup=crd;
                }else{
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize') AND //
                                              ERP7__Channel_Id__c =: currentSalesorder.ERP7__Organisation__c
                                              Limit 1])
                    paypalSetup=crd;
                }
                
                if(paypalSetup == null){
                    paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];
                }
            }
            if(paypalSetup.ERP7__Bank_COA_ID__c != null ){ if(Schema.sObjectType.Payment__c.Fields.ERP7__Payment_Account__c.isAccessible()) payment.ERP7__Payment_Account__c  = paypalSetup.ERP7__Bank_COA_ID__c; }
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.Payment__c.Fields.First_Name__c.isAccessible() && payment.First_Name__c != Null) FirstName = payment.First_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Last_Name__c.isAccessible() && payment.Last_Name__c != Null) LastName = payment.Last_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Email_Address__c.isAccessible() && payment.Email_Address__c != Null) Email = payment.Email_Address__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line1__c.isAccessible() && payment.Address_Line1__c != Null) Address_Line1 = payment.Address_Line1__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line2__c.isAccessible() && payment.Address_Line2__c != Null) Address_Line2 = payment.Address_Line2__c;        
            if(Schema.sObjectType.Payment__c.Fields.City__c.isAccessible() && payment.City__c != Null) City = payment.City__c;
            if(Schema.sObjectType.Payment__c.Fields.State__c.isAccessible() &&  payment.State__c != Null) State = payment.State__c;
            if(Schema.sObjectType.Payment__c.Fields.Country__c.isAccessible() && payment.Country__c != Null) Country = payment.Country__c;
            if(Schema.sObjectType.Payment__c.Fields.Zipcode__c.isAccessible() && payment.Zipcode__c != Null) Zipcode = payment.Zipcode__c;    
            
            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            
            if(isMultiCurrency){ 
                String SOId=currentSalesorder.Id;String inv='Select CurrencyIsoCode from ERP7__Invoice__c '; inv+='where ERP7__Order__c=:SOId';String Currency_Code=(String)Database.Query(inv)[0].get('CurrencyIsoCode');  myCur = Currency_Code;
                //ERP7__Invoice__c inv1=new ERP7__Invoice__c();
                //inv1=Database.Query(inv);                
                //inv=[Select Id,CurrencyIsoCode from ERP7__Invoice__c where ERP7__Order__c=:currentSalesorder.Id];
                //String Currency_Code = (String)Database.Query('select CurrencyIsoCode from ERP7__Payment__c ')[0].get('CurrencyIsoCode'); myCur = Currency_Code;
            }else{ myCur = UserInfo.getDefaultCurrency();}
                        
            myCurrency = myCur;  
            
            if(payment.Total_Amount__c != Null) Amount = String.valueof(payment.Total_Amount__c);
            AccId = currentSalesorder.Organisation__c;
            obuId = currentSalesorder.Organisation_Business_Unit__c;
            orderId = currentSalesorder.Id;
            ipstring = '';
                
            if(paypalSetup.Name == 'Paypal'){
                // Instantiate a new http object
                Http h = new Http();
                    
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                
                // The webservice url -  Pass in the endpoint to be used using the string url
                String url = String.valueof(paypalSetup.URL__c);
                String soapXML;
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                        
                soapXML =  '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi= " https://www.w3.org/2001/XMLSchema-instance"xmlns:SOAP-ENC="https://schemas.xmlsoap.org/soap/encoding/"xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"xmlns:xsd="https://www.w3.org/2001/XMLSchema"SOAP-ENV:encodingStyle="https://schemas.xmlsoap.org/soap/encoding/">';
                soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
                soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
                soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
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
                Status = readXMLResponse(reader,'Ack');  reader = res.getXmlStreamReader();  CorrID = readXMLResponse(reader, 'CorrelationID');   reader = res.getXmlStreamReader();  CVV2 = readXMLResponse(reader, 'CVV2Code');   reader = res.getXmlStreamReader();  AVSCode = readXMLResponse(reader, 'AVSCode');   rawResponse = xml;   reader = res.getXmlStreamReader();  ErrMsg = readXMLResponse(reader, 'LongMessage');  reader = res.getXmlStreamReader();  sErrMsg = readXMLResponse(reader, 'ShortMessage');  reader = res.getXmlStreamReader();  ErrCode= readXMLResponse(reader, 'ErrorCode');   reader = res.getXmlStreamReader();  transid = readXMLResponse(reader, 'TransactionID');              
               
                payment.AVS_Code__c = AVSCode; payment.CVV2_Code__c = CVV2; payment.Transaction_Status__c = Status; payment.Error_Code__c = ErrCode; payment.Transaction_ID__c = transid; payment.sError__c = sErrMsg; payment.Correlation_ID__c = CorrID; payment.Error_Message__c = ErrMsg;
                
            } 
            else if(paypalSetup.Name == 'Authorize.Net' || paypalSetup.Name == 'Authorize'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                string url = paypalSetup.ERP7__URL__c;
                String Expiration = Expiry_Month + Expiry_Year;
                
                String Address = billingAddress.ERP7__Address_Line1__c +' '+ billingAddress.ERP7__Address_Line2__c; //' '+ City +' '+ Country;
                string expiryDate = Expiry_Year + '-' + Expiry_Month;
                                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                    soapXML += '<merchantAuthentication>';
                        soapXML += '<name>' + paypalSetup.Username_Login__c.escapeXml() + '</name>';
                        soapXML += '<transactionKey>' + paypalSetup.Password_Transkey__c.escapeXml() + '</transactionKey>';
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
                    response_1 = '<createTransactionResponse xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="https://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                } else{
                    HttpResponse resr = hr.send(reqr);   response_1 = soapXML;  response_1 = resr.getBody();  resStatus = resr.getStatus();
                    
                }
                
                if (response_1 != null) {
                    string resultCode = response_1.substringBetween('<resultCode>', '</resultCode>');
                    string responseCode = response_1.substringBetween('<responseCode>', '</responseCode>');
                
                    if (resultCode == 'Ok') {
                        if (responseCode == '1'){
                            //--- Inside Approved.');
                            string description = response_1.substringBetween('<description>', '</description>');
                            transId = response_1.substringBetween('<transId>', '</transId>');
                            string transHash = response_1.substringBetween('<transHash>', '</transHash>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Approved';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = description;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                                payment.Status__c = 'Paid';
                            }    
                        }
                
                        if (responseCode == '2'){
                            //'--- Inside Declined.');
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Declined';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = errorMessage;
                            }
                        }
                
                        if (responseCode == '4'){
                            //'--- Inside Held for Review.');
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Held for Review';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = description;
                            }
                        }
                
                    }else {
                        if (responseCode == '3'){
                            //'--- Inside Error.');
                            string description = response_1.substringBetween('<description>', '</description>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Error';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = errorMessage;
                            }
                        }
                    } 
                } else payment.sError__c = 'Null Response.';  
                
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                
            } 
            else {
                ErrorMsgPayment = 'Please setup the payment terminal';
            }
            if(payment.Transaction_Status__c == 'Completed' || payment.Transaction_Status__c == 'SuccessWithWarning' || payment.Transaction_Status__c == 'Success' || payment.Transaction_Status__c == 'Approved'){
                payment.ERP7__Type__c = 'Debit';
                Payment.ERP7__Payment_Type__c = 'Card';
                payment.ERP7__Payment_Date__c=System.today();
                if(selInvList.size() > 1) payment.ERP7__Invoice__c=null;
                upsert payment; 
                
                if(selInvList.size() > 1){
                    List<ERP7__Invoice__c> invList=[Select Id,Name,ERP7__Total_Due__c from ERP7__Invoice__c where Id In:selInvList];
                    Map<String,Decimal> invAmt=new Map<String,Decimal>();
                    for(ERP7__Invoice__c inv:invList) invAmt.put(inv.Id,inv.ERP7__Total_Due__c);
                    payment.ERP7__Invoice__c=null;
                    List<ERP7__Payment_Applied_on_Invoice__c> PAList=new List<ERP7__Payment_Applied_on_Invoice__c>();
                    for(String invIds:selInvList){
                        ERP7__Payment_Applied_on_Invoice__c PA=new ERP7__Payment_Applied_on_Invoice__c();
                        PA.ERP7__Amount__c=invAmt.get(invIds);
                        PA.ERP7__Applied_Date__c=System.today();
                        PA.ERP7__Invoice__c=invIds;
                        PA.ERP7__Payment__c=payment.Id;
                        PA.ERP7__Type__c='Debit';
                        PAList.add(PA);
                    }
                    if(PAList.size() > 0) upsert PAList;
                }
                
                
            } else { 
                if(payment.sError__c != Null) ErrorMsgPayment = payment.sError__c;
            }
            return ErrorMsgPayment;  
           
        }catch(Exception ex){ErrorMsgPayment='Exception :';ErrorMsgPayment += ex.getMessage(); ErrorMsgPayment += ' Line No: '+ex.getLineNumber(); ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString(); return ErrorMsgPayment;}
    }
    */
    
    @AuraEnabled
    public static String CreateCardPaymentUpdat(String SalesOrder2Creates1, String Payments, String PaymentMethods, String CVV, String billingAddress1, String orgId, String payGate) {     //,List<String> selInvList  (Multiple Invoice payment)
        String ErrorMsgPayment = '';
        List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
        Address__c billingAddress = (Address__c) JSON.deserialize(billingAddress1, Address__c.class);
        try{
            
            String cvvs = CVV;
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethods, ERP7__Payment_Method__c .class);
            
            Payment.ERP7__Account_Holder_Name__c = PaymentMethod.ERP7__Name_on_Card__c;
            Payment.ERP7__Transaction_Type__c = 'InvoicePayment';
            Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Issue_Invoice__c,
                                      Bill_To_Address__r.County__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, ERP7__Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c
                                      From Sales_Order__c 
                                      Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
            
            if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
            if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())payment.Accounts__c = currentSalesorder.Account__c;
            if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null && !(payment.First_Name__c != Null && payment.First_Name__c != '')) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
            if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null && !(payment.Last_Name__c != Null && payment.Last_Name__c != '')) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
            if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
            //if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible())payment.Total_Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible() && !(payment.Address_Line1__c != Null && payment.Address_Line1__c != ''))payment.Address_Line1__c = billingAddress.ERP7__Address_Line1__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible() && !(payment.Address_Line2__c != Null && payment.Address_Line2__c != ''))payment.Address_Line2__c = billingAddress.Address_Line2__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible() && !(payment.City__c != Null && payment.City__c != ''))payment.City__c = billingAddress.City__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.State__c.isAccessible() && !(payment.State__c != Null && payment.State__c != ''))payment.State__c = billingAddress.State__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible() && !(payment.Country__c != Null && payment.Country__c != ''))payment.Country__c = billingAddress.Country__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible() && !(payment.Zipcode__c != Null && payment.Zipcode__c != ''))payment.Zipcode__c = billingAddress.Postal_Code__c; 
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
            if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
            
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            
            
            ERP7__Credentials__c paypalSetup;
            String paymentGate = '%'+payGate+'%';
            system.debug('paymentGate-->'+paymentGate);
            if(Schema.sObjectType.Credentials__c.isAccessible()) {
                if(orgId != '' && orgId != null){
                    for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name Like :paymentGate) AND //
                                              ERP7__Channel_Id__c =: orgId
                                              Limit 1])
                    paypalSetup=crd;
                }else{
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name Like :paymentGate) AND //
                                              ERP7__Channel_Id__c =: currentSalesorder.ERP7__Organisation__c
                                              Limit 1])
                    paypalSetup=crd;
                }
                /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal') AND //
                               ERP7__Channel_Id__c =: currentSalesorder.ERP7__Channel__c
                               Limit 1];*/
                
                if(paypalSetup == null){
                    for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                                  From ERP7__Credentials__c
                                                  Where ERP7__Active__c =: true And
                                                  (Name Like :paymentGate)
                                                  Limit 1])
                    paypalSetup=crd;
                    /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];*/
                }
                if(paypalSetup == null){ ErrorMsgPayment='Paymnet Credential Setup is not completed.';return ErrorMsgPayment;}
                
            }
            if(paypalSetup.ERP7__Bank_COA_ID__c != null ){ if(Schema.sObjectType.Payment__c.Fields.ERP7__Payment_Account__c.isAccessible()) payment.ERP7__Payment_Account__c  = paypalSetup.ERP7__Bank_COA_ID__c; }
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.Payment__c.Fields.First_Name__c.isAccessible() && payment.First_Name__c != Null) FirstName = payment.First_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Last_Name__c.isAccessible() && payment.Last_Name__c != Null) LastName = payment.Last_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Email_Address__c.isAccessible() && payment.Email_Address__c != Null) Email = payment.Email_Address__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line1__c.isAccessible() && payment.Address_Line1__c != Null) Address_Line1 = payment.Address_Line1__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line2__c.isAccessible() && payment.Address_Line2__c != Null) Address_Line2 = payment.Address_Line2__c;        
            if(Schema.sObjectType.Payment__c.Fields.City__c.isAccessible() && payment.City__c != Null) City = payment.City__c;
            if(Schema.sObjectType.Payment__c.Fields.State__c.isAccessible() &&  payment.State__c != Null) State = payment.State__c;
            if(Schema.sObjectType.Payment__c.Fields.Country__c.isAccessible() && payment.Country__c != Null) Country = payment.Country__c;
            if(Schema.sObjectType.Payment__c.Fields.Zipcode__c.isAccessible() && payment.Zipcode__c != Null) Zipcode = payment.Zipcode__c;    
            
            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(isMultiCurrency){  
                //Moin commented this 26th April 2024 to get the currency based of invoice instead of account currency
                //String acc='Select CurrencyIsoCode from Account '; acc+='where Id=:orgId'; String Currency_Code=(String)Database.Query(acc)[0].get('CurrencyIsoCode'); myCur = Currency_Code;
                String SOId=currentSalesorder.Id;String inv='Select CurrencyIsoCode from ERP7__Invoice__c '; inv+='where ERP7__Order__c=:SOId';String Currency_Code=(String)Database.Query(inv)[0].get('CurrencyIsoCode');  myCur = Currency_Code;                
            }else{ myCur = UserInfo.getDefaultCurrency();}
                        
            myCurrency = myCur; 
            if(payment.Total_Amount__c != Null) {
                if(Schema.sObjectType.Payment__c.Fields.Amount__c.isCreateable() && Schema.sObjectType.Payment__c.Fields.Amount__c.isUpdateable()) {payment.Amount__c = payment.Total_Amount__c; } else{ /* no access*/}
                Amount = String.valueof(payment.Total_Amount__c);
            }
            
            
            
            /*
            String surl = 'amount='+Integer.valueOf(Amount)*100+'&currency='+myCurrency;
            system.debug('surl-->'+surl);
            //String url = 'card[exp_month]=12&card[exp_year]=2024&card[number]=4242424242424242&card[cvc]=222&card[name]=Sam Jaba&amount=20&currency=USD&payment_method_types=[card]&description=Test&message=testing';
            String requestEndPoint = 'https://api.stripe.com/v1/payment_intents'; 
            HttpRequest Sreq = new HttpRequest(); 
            Sreq.setEndpoint(requestEndPoint);  
            Sreq.setMethod('POST');    
            Sreq.setTimeout(2000); 
            Sreq.setHeader('Content-Type','application/x-www-form-urlencoded'); 
            String strToken = System.label.Stripe_Token;
            String token = 'Bearer '+ strToken;
            Sreq.setHeader('Authorization',token);  
            Sreq.setBody(surl);
            Http http = new Http(); 
            httpResponse response=http.send(Sreq); 
            String response_1 = response.getBody(); 
            Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
            system.debug('results-->'+results);
            */
            
            AccId = currentSalesorder.Organisation__c;
            obuId = currentSalesorder.Organisation_Business_Unit__c;
            orderId = currentSalesorder.Id;
            ipstring = '';
                
            if(paypalSetup.Name == 'Paypal'){
                // Instantiate a new http object
                Http h = new Http();
                    
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                
                // The webservice url -  Pass in the endpoint to be used using the string url
                String url = String.valueof(paypalSetup.URL__c);
                String soapXML;
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                        
                soapXML =  System.label.PayPalAPI;
                soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
                soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
                soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
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
                Status = readXMLResponse(reader,'Ack');  reader = res.getXmlStreamReader();  CorrID = readXMLResponse(reader, 'CorrelationID');   reader = res.getXmlStreamReader();  CVV2 = readXMLResponse(reader, 'CVV2Code');   reader = res.getXmlStreamReader();  AVSCode = readXMLResponse(reader, 'AVSCode');   rawResponse = xml;   reader = res.getXmlStreamReader();  ErrMsg = readXMLResponse(reader, 'LongMessage');  reader = res.getXmlStreamReader();  sErrMsg = readXMLResponse(reader, 'ShortMessage');  reader = res.getXmlStreamReader();  ErrCode= readXMLResponse(reader, 'ErrorCode');   reader = res.getXmlStreamReader();  transid = readXMLResponse(reader, 'TransactionID');              
               
                payment.AVS_Code__c = AVSCode; payment.CVV2_Code__c = CVV2; payment.Transaction_Status__c = Status; payment.Error_Code__c = ErrCode; payment.Transaction_ID__c = transid; payment.sError__c = sErrMsg; payment.Correlation_ID__c = CorrID; payment.Error_Message__c = ErrMsg;
                
            } else if(paypalSetup.Name.contains('Stripe')){
                system.debug('Stripe Called');
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Stripe'; }
                String surl = 'type=card&billing_details[email]='+payment.Email_Address__c+'&billing_details[address][city]='+billingAddress.ERP7__City__c+'&billing_details[address][line1]='+billingAddress.ERP7__Address_Line1__c+'&billing_details[address][line2]='+billingAddress.ERP7__Address_Line2__c+'&billing_details[address][postal_code]='+billingAddress.ERP7__Postal_Code__c+'&billing_details[address][state]='+billingAddress.ERP7__State__c+'&card[exp_month]='+Expiry_Month+'&card[exp_year]='+Expiry_Year+'&card[number]='+Card_Number+'&card[cvc]='+CVV;
                String srequestEndPoint = 'https://api.stripe.com/v1/payment_methods'; 
                HttpRequest sreq = new HttpRequest(); 
                sreq.setEndpoint(srequestEndPoint);  
                sreq.setMethod('POST');    
                sreq.setTimeout(2000); 
                sreq.setHeader('Content-Type','application/x-www-form-urlencoded');
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                system.debug('paypalSetup.Username_Login__c-->'+paypalSetup.Username_Login__c);
                system.debug('paypalSetup.Password_Transkey__c-->'+paypalSetup.Password_Transkey__c);
                String strToken = paypalSetup.Username_Login__c + paypalSetup.Password_Transkey__c;
                String token = 'Bearer '+ strToken;
                sreq.setHeader('Authorization',token);  
                sreq.setBody(surl);
                Http shttp = new Http(); 
                httpResponse sresponse=shttp.send(sreq); 
                String response_1 = sresponse.getBody(); 
                system.debug('Code-->'+sresponse.getStatus());
                if (sresponse.getStatus() == 'Ok') {
                    Map<String,Object> results=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
                    system.debug('results-->'+results);
                    system.debug('Payment Id-->'+results.get('id'));
                    String s1url = 'confirm=true&amount='+Integer.valueOf(payment.Total_Amount__c*100)+'&currency='+myCurrency+'&payment_method='+results.get('id');
                    system.debug('surl-->'+s1url);
                    //String url = 'card[exp_month]=12&card[exp_year]=2024&card[number]=4242424242424242&card[cvc]=222&card[name]=Sam Jaba&amount=20&currency=USD&payment_method_types=[card]&description=Test&message=testing';
                    String s1requestEndPoint = 'https://api.stripe.com/v1/payment_intents'; 
                    HttpRequest S1req = new HttpRequest(); 
                    S1req.setEndpoint(s1requestEndPoint);  
                    S1req.setMethod('POST');    
                    S1req.setTimeout(20000); 
                    S1req.setHeader('Content-Type','application/x-www-form-urlencoded'); 
                    String str1Token = System.label.Stripe_Token;
                    system.debug('str1Token-->'+str1Token);
                    String strToken2 = paypalSetup.Username_Login__c + paypalSetup.Password_Transkey__c;
                    system.debug('strToken2-->'+strToken2);
                    String token1 = 'Bearer '+ strToken2;
                    S1req.setHeader('Authorization',token1);  
                    S1req.setBody(s1url);
                    Http http1 = new Http(); 
                    httpResponse response1=http1.send(S1req); 
                    String response_12 = response1.getBody(); 
                    Map<String,Object> results1=(Map<String,Object>)JSON.deserializeUntyped(response_12); 
                    system.debug('results-->'+results1);
                    if(results1.get('status') == 'succeeded'){
                    if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                        payment.Transaction_Status__c = 'Approved';
                    }
                    if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                        payment.Status__c = 'Paid';
                    } 
                    if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                        payment.Transaction_ID__c = String.valueOf(results1.get('id'));
                    }
                    }else{
                        //Map<String,Object> failedResponse=(Map<String,Object>)JSON.deserializeUntyped(response_12); 
                        payment.sError__c = response_12;//String.valueOf(failedResponse.get('message'));
                    }
                }else{
                    //Map<String,Object> failedResp=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
                    payment.sError__c = response_1;//String.valueOf(failedResp.get('message'));
                }
            }
            else if(paypalSetup.Name == 'Authorize.Net' || paypalSetup.Name == 'Authorize'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                string url = paypalSetup.ERP7__URL__c;
                String Expiration = Expiry_Month + Expiry_Year;
                
                String Address = billingAddress.ERP7__Address_Line1__c +' '+ billingAddress.ERP7__Address_Line2__c; //' '+ City +' '+ Country;
                string expiryDate = Expiry_Year + '-' + Expiry_Month;
                                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                    soapXML += '<merchantAuthentication>';
                        soapXML += '<name>' + paypalSetup.Username_Login__c.escapeXml() + '</name>';
                        soapXML += '<transactionKey>' + paypalSetup.Password_Transkey__c.escapeXml() + '</transactionKey>';
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
                    response_1 = '<createTransactionResponse xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="https://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                    //response_1 = '<createTransactionResponse xmlns:xsi="'+Label.POSLightningLabel2+'-instance" xmlns:xsd="'+Label.POSLightningLabel2+'" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                } else{
                    HttpResponse resr = hr.send(reqr);   response_1 = soapXML;  response_1 = resr.getBody();  resStatus = resr.getStatus();
                    
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
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Approved';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = description;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                                payment.Status__c = 'Paid';
                            }    
                        }
                
                        if (responseCode == '2'){
                            //'--- Inside Declined.'
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Declined';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = errorMessage;
                            }
                        }
                
                        if (responseCode == '4'){
                            //'--- Inside Held for Review.'
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                           
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Held for Review';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = description;
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
                                payment.Transaction_Status__c = 'Error';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = errorMessage;
                            }
                        }
                    } 
                } else payment.sError__c = 'Null Response.';  
                
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                
                /* Commented as using the new code
                AuthorizeDotNet ath = new AuthorizeDotNet(true,paypalSetup.Id);
                ath.transaction(Card_Number, Expiration, Amount, CVVV,'','');  
                ath.setParameter('x_device_type','1');  
                ath.setParameter('x_first_name',FirstName);  
                ath.setParameter('x_last_name',LastName);  
                ath.setParameter('x_address',address);  
                ath.setParameter('x_state',State);  
                ath.setParameter('x_email',email); 
                ath.setParameter('x_city',city); 
                ath.setParameter('x_country',country);
                ath.setParameter('x_response_format','2');  //1
                ath.setParameter('x_zip',Zipcode);
                
                ath.process(3);
                
                if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Failure';
                if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = 'Failure';
                
                if(ath.isApproved()){
                    String responsetext = ath.getResponseText();
                    String transactionid = ath.getTransactionID();
                    if(Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transactionid; }
                    if(Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Approved'; }
                    if(Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = responsetext ; }                  
                    if(Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) { payment.Status__c = 'Paid'; }                  
                }
                else if(ath.isDeclined()){
                    String reason = ath.getResponseText();
                    if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Declined';
                    if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = reason;  
                }
                else{
                    String reason = ath.getResponseText();
                    if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Declined';
                    if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = reason;
                }
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                
                */
            } 
            else {
                ErrorMsgPayment = 'Please setup the payment terminal';
            }
            if(payment.Transaction_Status__c == 'Completed' || payment.Transaction_Status__c == 'SuccessWithWarning' || payment.Transaction_Status__c == 'Success' || payment.Transaction_Status__c == 'Approved'){
                payment.ERP7__Type__c = 'Debit';
                Payment.ERP7__Payment_Type__c = 'Card';
                payment.ERP7__Payment_Date__c=System.today();
                //if(selInvList.size() > 1) payment.ERP7__Invoice__c=null;
                if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable() && Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isUpdateable()){upsert payment;}else{ErrorMsgPayment ='Not allowed to upsert payment';}  
                
                //if(selInvList.size() > 1){  List<ERP7__Invoice__c> invList=[Select Id,Name,ERP7__Total_Due__c from ERP7__Invoice__c where Id In:selInvList];  Map<String,Decimal> invAmt=new Map<String,Decimal>(); for(ERP7__Invoice__c inv:invList) invAmt.put(inv.Id,inv.ERP7__Total_Due__c); payment.ERP7__Invoice__c=null;  List<ERP7__Payment_Applied_on_Invoice__c> PAList=new List<ERP7__Payment_Applied_on_Invoice__c>();  for(String invIds:selInvList){ ERP7__Payment_Applied_on_Invoice__c PA=new ERP7__Payment_Applied_on_Invoice__c(); PA.ERP7__Amount__c=invAmt.get(invIds); PA.ERP7__Applied_Date__c=System.today(); PA.ERP7__Invoice__c=invIds; PA.ERP7__Payment__c=payment.Id; PA.ERP7__Type__c='Debit'; PAList.add(PA); } if(PAList.size() > 0) upsert PAList;}
                
            } else { 
                if(payment.sError__c != Null) ErrorMsgPayment = payment.sError__c;
            }
            return ErrorMsgPayment;   
        }catch(exception ex){
            ErrorMsgPayment = ex.getMessage();
            ErrorMsgPayment += ' Line No: '+ex.getLineNumber();
            ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString();
            return ErrorMsgPayment;
        }
        
    }
    
     @AuraEnabled
    public static StripeWrapper CreateCardPaymentStripe(String SalesOrder2Creates1, String Payments, String PaymentMethods, String CVV, String billingAddress1, String orgId, String payGate) {     //,List<String> selInvList  (Multiple Invoice payment)
        String ErrorMsgPayment = '';
        String Url = '';
        StripeWrapper swrap = new StripeWrapper();
        List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
        Address__c billingAddress = (Address__c) JSON.deserialize(billingAddress1, Address__c.class);
        try{
            
            String cvvs = CVV;
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethods, ERP7__Payment_Method__c .class);
            
            Payment.ERP7__Account_Holder_Name__c = PaymentMethod.ERP7__Name_on_Card__c;
            Payment.ERP7__Transaction_Type__c = 'InvoicePayment';
            Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Issue_Invoice__c,
                                      Bill_To_Address__r.County__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, ERP7__Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c
                                      From Sales_Order__c 
                                      Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
            
            if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
            if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())payment.Accounts__c = currentSalesorder.Account__c;
            if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null && !(payment.First_Name__c != Null && payment.First_Name__c != '')) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
            if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null && !(payment.Last_Name__c != Null && payment.Last_Name__c != '')) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
            if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
            //if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible())payment.Total_Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible() && !(payment.Address_Line1__c != Null && payment.Address_Line1__c != ''))payment.Address_Line1__c = billingAddress.ERP7__Address_Line1__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible() && !(payment.Address_Line2__c != Null && payment.Address_Line2__c != ''))payment.Address_Line2__c = billingAddress.Address_Line2__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible() && !(payment.City__c != Null && payment.City__c != ''))payment.City__c = billingAddress.City__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.State__c.isAccessible() && !(payment.State__c != Null && payment.State__c != ''))payment.State__c = billingAddress.State__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible() && !(payment.Country__c != Null && payment.Country__c != ''))payment.Country__c = billingAddress.Country__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible() && !(payment.Zipcode__c != Null && payment.Zipcode__c != ''))payment.Zipcode__c = billingAddress.Postal_Code__c; 
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
            if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
            
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            
            
            ERP7__Credentials__c paypalSetup;
            String paymentGate = '%'+payGate+'%';
            system.debug('paymentGate-->'+paymentGate);
            if(Schema.sObjectType.Credentials__c.isAccessible()) {
                if(orgId != '' && orgId != null){
                    for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name Like :paymentGate) AND //
                                              ERP7__Channel_Id__c =: orgId
                                              Limit 1])
                    paypalSetup=crd;
                }else{
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name Like :paymentGate) AND //
                                              ERP7__Channel_Id__c =: currentSalesorder.ERP7__Organisation__c
                                              Limit 1])
                    paypalSetup=crd;
                }
                /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal') AND //
                               ERP7__Channel_Id__c =: currentSalesorder.ERP7__Channel__c
                               Limit 1];*/
                if(paypalSetup == null){
                    for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                                  From ERP7__Credentials__c
                                                  Where ERP7__Active__c =: true And
                                                  (Name Like :paymentGate)
                                                  Limit 1])
                    paypalSetup=crd;
                    /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];*/
                }
                if(paypalSetup == null){ ErrorMsgPayment='Paymnet Credential Setup is not completed.';swrap.errorMessage = ErrorMsgPayment;
                return swrap;}
                
            }
            if(paypalSetup.ERP7__Bank_COA_ID__c != null ){ if(Schema.sObjectType.Payment__c.Fields.ERP7__Payment_Account__c.isAccessible()) payment.ERP7__Payment_Account__c  = paypalSetup.ERP7__Bank_COA_ID__c; }
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.Payment__c.Fields.First_Name__c.isAccessible() && payment.First_Name__c != Null) FirstName = payment.First_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Last_Name__c.isAccessible() && payment.Last_Name__c != Null) LastName = payment.Last_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Email_Address__c.isAccessible() && payment.Email_Address__c != Null) Email = payment.Email_Address__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line1__c.isAccessible() && payment.Address_Line1__c != Null) Address_Line1 = payment.Address_Line1__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line2__c.isAccessible() && payment.Address_Line2__c != Null) Address_Line2 = payment.Address_Line2__c;        
            if(Schema.sObjectType.Payment__c.Fields.City__c.isAccessible() && payment.City__c != Null) City = payment.City__c;
            if(Schema.sObjectType.Payment__c.Fields.State__c.isAccessible() &&  payment.State__c != Null) State = payment.State__c;
            if(Schema.sObjectType.Payment__c.Fields.Country__c.isAccessible() && payment.Country__c != Null) Country = payment.Country__c;
            if(Schema.sObjectType.Payment__c.Fields.Zipcode__c.isAccessible() && payment.Zipcode__c != Null) Zipcode = payment.Zipcode__c;    
            
            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(isMultiCurrency){  String acc='Select CurrencyIsoCode from Account '; acc+='where Id=:orgId'; String Currency_Code=(String)Database.Query(acc)[0].get('CurrencyIsoCode'); myCur = Currency_Code;
                //String SOId=currentSalesorder.Id;String inv='Select CurrencyIsoCode from ERP7__Invoice__c '; inv+='where ERP7__Order__c=:SOId';String Currency_Code=(String)Database.Query(inv)[0].get('CurrencyIsoCode');  myCur = Currency_Code;                
            }else{ myCur = UserInfo.getDefaultCurrency();}
                        
            myCurrency = myCur; 
            if(payment.Total_Amount__c != Null) {
                if(Schema.sObjectType.Payment__c.Fields.Amount__c.isCreateable() && Schema.sObjectType.Payment__c.Fields.Amount__c.isUpdateable()) {payment.Amount__c = payment.Total_Amount__c; } else{ /* no access*/}
                Amount = String.valueof(payment.Total_Amount__c);
            }
            
            
            AccId = currentSalesorder.Organisation__c;
            obuId = currentSalesorder.Organisation_Business_Unit__c;
            orderId = currentSalesorder.Id;
            ipstring = '';
                
            if(paypalSetup.Name.contains('Stripe')){
                system.debug('Stripe Called');
                String navigateUrl = '';
                if(paypalSetup.ERP7__URL__c != null) navigateUrl = String.valueOf(paypalSetup.ERP7__URL__c);
                else navigateUrl = System.Label.NavigateToEpos;
                navigateUrl = navigateUrl + 'SON='+currentSalesorder.Name;
                String surl = 'type=card'+'&billing_details[address][city]='+billingAddress.ERP7__City__c+'&billing_details[address][country]='+'CA'+'&billing_details[address][line1]='+billingAddress.ERP7__Address_Line1__c+'&billing_details[address][line2]='+billingAddress.ERP7__Address_Line2__c+'&billing_details[address][postal_code]='+billingAddress.ERP7__Postal_Code__c+'&billing_details[address][state]='+billingAddress.ERP7__State__c+'&card[exp_month]='+Expiry_Month+'&card[exp_year]='+Expiry_Year+'&card[number]='+Card_Number+'&card[cvc]='+CVV;
                String url2 = 'cancel_url='+ navigateUrl+'&success_url='+navigateUrl+'&line_items[0][price_data][currency]='+myCurrency+'&line_items[0][price_data][product_data][name]='+'Aqxolt ERP'+'&line_items[0][price_data][unit_amount]='+Integer.valueOf(payment.Total_Amount__c*100)+'&line_items[0][quantity]='+1+'&mode='+'payment';
                String srequestEndPoint = 'https://api.stripe.com/v1/checkout/sessions'; 
                HttpRequest sreq = new HttpRequest(); 
                sreq.setEndpoint(srequestEndPoint);  
                sreq.setMethod('POST');    
                sreq.setTimeout(2000); 
                sreq.setHeader('Content-Type','application/x-www-form-urlencoded');
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                system.debug('paypalSetup.Username_Login__c-->'+paypalSetup.Username_Login__c);
                system.debug('paypalSetup.Password_Transkey__c-->'+paypalSetup.Password_Transkey__c);
                String strToken = paypalSetup.Username_Login__c + paypalSetup.Password_Transkey__c;
                String token = 'Bearer '+ strToken;
                sreq.setHeader('Authorization',token);  
                sreq.setBody(url2);
                Http shttp = new Http(); 
                httpResponse sresponse=shttp.send(sreq); 
                String response_1 = sresponse.getBody(); 
                system.debug('Code-->'+sresponse.getStatus());
                if (sresponse.getStatus() == 'Ok') {
                    Map<String,Object> results1=(Map<String,Object>)JSON.deserializeUntyped(response_1); 
                    if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                        payment.Transaction_Status__c = 'Approved';
                    }
                    if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                        payment.Status__c = 'Paid';
                    } 
                    if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                        payment.ERP7__Stripe_Payment_Link__c= String.valueOf(results1.get('url'));
                        Url = String.valueOf(results1.get('url'));
                    }
                }else{
                    payment.sError__c = 'Transaction Failed';
                }
            }else {
                ErrorMsgPayment = 'Please setup the payment terminal';
            }
            if(payment.Transaction_Status__c == 'Completed' || payment.Transaction_Status__c == 'SuccessWithWarning' || payment.Transaction_Status__c == 'Success' || payment.Transaction_Status__c == 'Approved'){
                payment.ERP7__Type__c = 'Debit';
                Payment.ERP7__Payment_Type__c = 'Card';
                payment.ERP7__Payment_Date__c=System.today();
                //if(selInvList.size() > 1) payment.ERP7__Invoice__c=null;
                if(Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.sError__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_ID__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Transaction_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Transaction_Type__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Total_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable() && Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isUpdateable()){upsert payment;}else{ErrorMsgPayment ='Not allowed to upsert payment';}  
                
                //if(selInvList.size() > 1){  List<ERP7__Invoice__c> invList=[Select Id,Name,ERP7__Total_Due__c from ERP7__Invoice__c where Id In:selInvList];  Map<String,Decimal> invAmt=new Map<String,Decimal>(); for(ERP7__Invoice__c inv:invList) invAmt.put(inv.Id,inv.ERP7__Total_Due__c); payment.ERP7__Invoice__c=null;  List<ERP7__Payment_Applied_on_Invoice__c> PAList=new List<ERP7__Payment_Applied_on_Invoice__c>();  for(String invIds:selInvList){ ERP7__Payment_Applied_on_Invoice__c PA=new ERP7__Payment_Applied_on_Invoice__c(); PA.ERP7__Amount__c=invAmt.get(invIds); PA.ERP7__Applied_Date__c=System.today(); PA.ERP7__Invoice__c=invIds; PA.ERP7__Payment__c=payment.Id; PA.ERP7__Type__c='Debit'; PAList.add(PA); } if(PAList.size() > 0) upsert PAList;}
                
            } else { 
                if(payment.sError__c != Null) ErrorMsgPayment = payment.sError__c;
            }
            if(ErrorMsgPayment == '') {
            swrap.errorMessage = ErrorMsgPayment;
            swrap.Url = Url;
            return swrap;
            }else{
                swrap.errorMessage = ErrorMsgPayment;
                return swrap;
            }  
        }catch(exception ex){
            ErrorMsgPayment = ex.getMessage();
            ErrorMsgPayment += ' Line No: '+ex.getLineNumber();
            ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString();
            swrap.errorMessage = ErrorMsgPayment;
            return swrap;
        }
        
    }
    
    public class StripeWrapper{
    @AuraEnabled
    public String errorMessage {get;set;}
    @AuraEnabled
    public String Url {get;set;}
    public StripeWrapper(){
        errorMessage = '';
        Url = '';
    }
    }
    
     @AuraEnabled
    global static String CreateCardPaymentUpdated(List < ERP7__Sales_Order__c > SalesOrder2Creates, String Payments, String PaymentMethods, String CVV, Address__c billingAddress) {
        String ErrorMsgPayment = '';
       //  List < ERP7__Sales_Order__c > SalesOrder2Creates = (List < ERP7__Sales_Order__c > ) JSON.deserialize(SalesOrder2Creates1, List < ERP7__Sales_Order__c > .class);
      //  Address__c billingAddress = (Address__c) JSON.deserialize(billingAddress1, Address__c.class);
        /*try{
            
            String cvvs = CVV;
            ERP7__Payment__c Payment = (ERP7__Payment__c) JSON.deserialize(Payments, ERP7__Payment__c .class);
            ERP7__Payment_Method__c PaymentMethod = (ERP7__Payment_Method__c) JSON.deserialize(PaymentMethods, ERP7__Payment_Method__c .class);
            Payment.ERP7__Account_Holder_Name__c = PaymentMethod.ERP7__Name_on_Card__c;
            Payment.ERP7__Transaction_Type__c = 'InvoicePayment';
            Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, ERP7__Issue_Invoice__c,
                                      Bill_To_Address__r.County__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, ERP7__Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c
                                      From Sales_Order__c 
                                      Where Id =: SalesOrder2Creates[0].Id Limit 1]; 
            
            if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
            if(Schema.sobjectType.Sales_Order__c.Fields.Account__c.isAccessible())payment.Accounts__c = currentSalesorder.Account__c;
            if(Schema.sobjectType.Contact.Fields.FirstName.isAccessible()) if(currentSalesorder.Contact__r.FirstName != Null && !(payment.First_Name__c != Null && payment.First_Name__c != '')) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
            if(Schema.sobjectType.Contact.Fields.LastName.isAccessible()) if(currentSalesorder.Contact__r.LastName != Null && !(payment.Last_Name__c != Null && payment.Last_Name__c != '')) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
            if(Schema.sobjectType.Contact.Fields.Email.isAccessible())if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
            //if(Schema.sobjectType.Sales_Order__c.Fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.Fields.Amount_Paid__c.isAccessible())payment.Total_Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line1__c.isAccessible() && !(payment.Address_Line1__c != Null && payment.Address_Line1__c != ''))payment.Address_Line1__c = billingAddress.ERP7__Address_Line1__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Address_Line2__c.isAccessible() && !(payment.Address_Line2__c != Null && payment.Address_Line2__c != ''))payment.Address_Line2__c = billingAddress.Address_Line2__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.City__c.isAccessible() && !(payment.City__c != Null && payment.City__c != ''))payment.City__c = billingAddress.City__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.State__c.isAccessible() && !(payment.State__c != Null && payment.State__c != ''))payment.State__c = billingAddress.State__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Country__c.isAccessible() && !(payment.Country__c != Null && payment.Country__c != ''))payment.Country__c = billingAddress.Country__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.Address__c.Fields.Postal_Code__c.isAccessible() && !(payment.Zipcode__c != Null && payment.Zipcode__c != ''))payment.Zipcode__c = billingAddress.Postal_Code__c; 
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
            if(Schema.sobjectType.Sales_Order__c.Fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
            if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'PayPal'; }
            
            
            String rTypeP;
            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Card_Payments');
            if(String.isNotEmpty(rTypeP)){
                payment.RecordTypeId = rTypeP; 
            }
            
            
            ERP7__Credentials__c paypalSetup;
            if(Schema.sObjectType.Credentials__c.isAccessible()) {
                for(ERP7__Credentials__c crd:[Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                                              From ERP7__Credentials__c
                                              Where ERP7__Active__c =: true And
                                              (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize') AND //
                                              ERP7__Channel_Id__c =: currentSalesorder.ERP7__Organisation__c
                                              Limit 1])
                    paypalSetup=crd;
                
                /*paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal') AND //
                               ERP7__Channel_Id__c =: currentSalesorder.ERP7__Channel__c
                               Limit 1];*
                if(paypalSetup == null){
                    paypalSetup = [Select Id, Name, ERP7__Active__c, ERP7__Password_Transkey__c, ERP7__Signature__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Encrypted_Key__c,ERP7__Channel_Id__c,ERP7__Bank_COA_ID__c
                               From ERP7__Credentials__c
                               Where ERP7__Active__c =: true And
                               (Name = 'Authorize.Net' or Name = 'Paypal' or Name = 'Authorize')
                               Limit 1];
                }
            }
            if(paypalSetup.ERP7__Bank_COA_ID__c != null ){ if(Schema.sObjectType.Payment__c.Fields.ERP7__Payment_Account__c.isAccessible()) payment.ERP7__Payment_Account__c  = paypalSetup.ERP7__Bank_COA_ID__c; }
            String TransId = '', Status = '', AVSCode = '', CVV2 = '', sErrMsg = '', ErrMsg = '', ErrCode = '', rawResponse = '', CorrID  = '', Id  = '', pgId  = '', userAgent = '', FirstName = '', LastName = '', Email = '', City = '', State = '', Country = '', Zipcode = '', CardType = '', Expiry_Month = '', Card_Number = '', Expiry_Year = '', Amount = '', Card_Type = '', CVVV = '', myCurrency = '', Address_Line1 = '', Address_Line2 = '', AccId = '', ObuId = '', Orderid = '', methodId = '', comAppend = '', ipstring = '';
            if(Schema.sObjectType.Payment__c.Fields.First_Name__c.isAccessible() && payment.First_Name__c != Null) FirstName = payment.First_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Last_Name__c.isAccessible() && payment.Last_Name__c != Null) LastName = payment.Last_Name__c;
            if(Schema.sObjectType.Payment__c.Fields.Email_Address__c.isAccessible() && payment.Email_Address__c != Null) Email = payment.Email_Address__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line1__c.isAccessible() && payment.Address_Line1__c != Null) Address_Line1 = payment.Address_Line1__c;
            if(Schema.sObjectType.Payment__c.Fields.Address_Line2__c.isAccessible() && payment.Address_Line2__c != Null) Address_Line2 = payment.Address_Line2__c;        
            if(Schema.sObjectType.Payment__c.Fields.City__c.isAccessible() && payment.City__c != Null) City = payment.City__c;
            if(Schema.sObjectType.Payment__c.Fields.State__c.isAccessible() &&  payment.State__c != Null) State = payment.State__c;
            if(Schema.sObjectType.Payment__c.Fields.Country__c.isAccessible() && payment.Country__c != Null) Country = payment.Country__c;
            if(Schema.sObjectType.Payment__c.Fields.Zipcode__c.isAccessible() && payment.Zipcode__c != Null) Zipcode = payment.Zipcode__c;    
            
            Card_Number = PaymentMethod.Card_Number__c;
            Card_Type  = PaymentMethod.CardType__c;
            Expiry_Month = PaymentMethod.Card_Expiration_Month__c;
            Expiry_Year  = PaymentMethod.Card_Expiration_Year__c;
            CVVV = cvvs;
            String myCur;// = UserInfo.getDefaultCurrency();
            Boolean isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');
            if(isMultiCurrency){ 
                String SOId=currentSalesorder.Id;String inv='Select CurrencyIsoCode from ERP7__Invoice__c '; inv+='where ERP7__Order__c=:SOId';String Currency_Code=(String)Database.Query(inv)[0].get('CurrencyIsoCode');  myCur = Currency_Code;
                //ERP7__Invoice__c inv1=new ERP7__Invoice__c();
                //inv1=Database.Query(inv);                
                //inv=[Select Id,CurrencyIsoCode from ERP7__Invoice__c where ERP7__Order__c=:currentSalesorder.Id];
                //String Currency_Code = (String)Database.Query('select CurrencyIsoCode from ERP7__Payment__c ')[0].get('CurrencyIsoCode'); myCur = Currency_Code;
            }else{ myCur = UserInfo.getDefaultCurrency();}
                        
            myCurrency = myCur;  
            if(payment.Total_Amount__c != Null) Amount = String.valueof(payment.Total_Amount__c);
            AccId = currentSalesorder.Organisation__c;
            obuId = currentSalesorder.Organisation_Business_Unit__c;
            orderId = currentSalesorder.Id;
            ipstring = '';
                
            if(paypalSetup.Name == 'Paypal'){
                // Instantiate a new http object
                Http h = new Http();
                    
                // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
                HttpRequest req = new HttpRequest();
                
                // The webservice url -  Pass in the endpoint to be used using the string url
                String url = String.valueof(paypalSetup.URL__c);
                String soapXML;
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                        
                soapXML =  '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:xsi= " https://www.w3.org/2001/XMLSchema-instance"xmlns:SOAP-ENC="https://schemas.xmlsoap.org/soap/encoding/"xmlns:SOAP-ENV="https://schemas.xmlsoap.org/soap/envelope/"xmlns:xsd="https://www.w3.org/2001/XMLSchema"SOAP-ENV:encodingStyle="https://schemas.xmlsoap.org/soap/encoding/">';
                soapXML += '<SOAP-ENV:Header><RequesterCredentials xmlns="urn:ebay:api:PayPalAPI"><Credentials xmlns="urn:ebay:apis:eBLBaseComponents">';
                soapXML += '<Username>' + paypalSetup.Username_Login__c.escapeXml() + '</Username>';
                soapXML += '<Password>' + paypalSetup.Password_Transkey__c.escapeXml() + '</Password>';
                soapXML += '<Signature>' + paypalSetup.Signature__c.escapeXml() + '</Signature>';
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
                Status = readXMLResponse(reader,'Ack');  reader = res.getXmlStreamReader();  CorrID = readXMLResponse(reader, 'CorrelationID');   reader = res.getXmlStreamReader();  CVV2 = readXMLResponse(reader, 'CVV2Code');   reader = res.getXmlStreamReader();  AVSCode = readXMLResponse(reader, 'AVSCode');   rawResponse = xml;   reader = res.getXmlStreamReader();  ErrMsg = readXMLResponse(reader, 'LongMessage');  reader = res.getXmlStreamReader();  sErrMsg = readXMLResponse(reader, 'ShortMessage');  reader = res.getXmlStreamReader();  ErrCode= readXMLResponse(reader, 'ErrorCode');   reader = res.getXmlStreamReader();  transid = readXMLResponse(reader, 'TransactionID');              
               
                payment.AVS_Code__c = AVSCode; payment.CVV2_Code__c = CVV2; payment.Transaction_Status__c = Status; payment.Error_Code__c = ErrCode; payment.Transaction_ID__c = transid; payment.sError__c = sErrMsg; payment.Correlation_ID__c = CorrID; payment.Error_Message__c = ErrMsg;
                
            } 
            else if(paypalSetup.Name == 'Authorize.Net' || paypalSetup.Name == 'Authorize'){
                Blob cryptoKey, userData, passwordData;
                cryptoKey = encodingUtil.convertFromHex(paypalSetup.Encrypted_Key__c);
                userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Username_Login__c));
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(paypalSetup.Password_Transkey__c));
                if(userData != null) paypalSetup.Username_Login__c = userData.toString();
                if(passwordData != null) paypalSetup.Password_Transkey__c = passwordData.toString();
                string url = paypalSetup.ERP7__URL__c;
                String Expiration = Expiry_Month + Expiry_Year;
                
                String Address = billingAddress.ERP7__Address_Line1__c +' '+ billingAddress.ERP7__Address_Line2__c; //' '+ City +' '+ Country;
                string expiryDate = Expiry_Year + '-' + Expiry_Month;
                                
                String soapXML  = '<?xml version="1.0" encoding="UTF-8"?>';
                soapXML += '<createTransactionRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">';
                    soapXML += '<merchantAuthentication>';
                        soapXML += '<name>' + paypalSetup.Username_Login__c.escapeXml() + '</name>';
                        soapXML += '<transactionKey>' + paypalSetup.Password_Transkey__c.escapeXml() + '</transactionKey>';
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
                    response_1 = '<createTransactionResponse xmlns:xsi="https://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="https://www.w3.org/2001/XMLSchema" xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd"><messages><resultCode>Ok</resultCode><message><code>I00001</code><text>Successful.</text></message></messages><transactionResponse><responseCode>1</responseCode><authCode>9C9UEO</authCode><avsResultCode>Y</avsResultCode><cvvResultCode>P</cvvResultCode><cavvResultCode>2</cavvResultCode><transId>40017242270</transId><refTransID /><transHash>03A19FEF24F26163F4182D4B1BD7281D</transHash><testRequest>0</testRequest><accountNumber>XXXX4242</accountNumber><accountType>Visa</accountType><messages><message><code>1</code><description>This transaction has been approved.</description></message></messages><transHashSha2/></transactionResponse></createTransactionResponse>';
                } else{
                    HttpResponse resr = hr.send(reqr);   response_1 = soapXML;  response_1 = resr.getBody();  resStatus = resr.getStatus();
                    
                }
                
                if (response_1 != null) {
                    string resultCode = response_1.substringBetween('<resultCode>', '</resultCode>');
                    string responseCode = response_1.substringBetween('<responseCode>', '</responseCode>');
                
                    if (resultCode == 'Ok') {
                        if (responseCode == '1'){
                            //'--- Inside Approved.');
                            string description = response_1.substringBetween('<description>', '</description>');
                            transId = response_1.substringBetween('<transId>', '</transId>');
                            string transHash = response_1.substringBetween('<transHash>', '</transHash>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Approved';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = description;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) {
                                payment.Status__c = 'Paid';
                            }    
                        }
                
                        if (responseCode == '2'){
                            //'--- Inside Declined.'
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                                                        string errorMessage = 'Transaction Failed. ';  string Text = response_1.substringBetween('<text>', '</text>');  string errors = response_1.substringBetween('<errors>', '</errors>');  string errorText = response_1.substringBetween('<errorText>', '</errorText>');
                
                            if (errors != null) errorMessage += errorText;
                            else errorMessage += Text;
                
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Declined';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = errorMessage;
                            }
                        }
                
                        if (responseCode == '4'){
                            //'--- Inside Held for Review.'
                            string description = response_1.substringBetween('<description>', '</description>');  transId = response_1.substringBetween('<transId>', '</transId>');
                            
                            if (Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) {
                                payment.Transaction_ID__c = transId;
                            }
                            if (Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) {
                                payment.Transaction_Status__c = 'Held for Review';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = description;
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
                                payment.Transaction_Status__c = 'Error';
                            }
                            if (Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() || Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) {
                                payment.sError__c = errorMessage;
                            }
                        }
                    } 
                } else payment.sError__c = 'Null Response.';  
                
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() || Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                                
                /* Commented as using the new code
                AuthorizeDotNet ath = new AuthorizeDotNet(true,paypalSetup.Id);
                ath.transaction(Card_Number, Expiration, Amount, CVVV,'','');  
                ath.setParameter('x_device_type','1');  
                ath.setParameter('x_first_name',FirstName);  
                ath.setParameter('x_last_name',LastName);  
                ath.setParameter('x_address',address);  
                ath.setParameter('x_state',State);  
                ath.setParameter('x_email',email); 
                ath.setParameter('x_city',city); 
                ath.setParameter('x_country',country);
                ath.setParameter('x_response_format','2');  //1
                ath.setParameter('x_zip',Zipcode);
                
                ath.process(3);
                
                if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Failure';
                if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = 'Failure';
                
                if(ath.isApproved()){
                    String responsetext = ath.getResponseText();
                    String transactionid = ath.getTransactionID();
                    if(Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transactionid; }
                    if(Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Approved'; }
                    if(Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = responsetext ; }                  
                    if(Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) { payment.Status__c = 'Paid'; }                  
                }
                else if(ath.isDeclined()){
                    String reason = ath.getResponseText();
                    if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Declined';
                    if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = reason;  
                }
                else{
                    String reason = ath.getResponseText();
                    if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Declined';
                    if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = reason;
                }
                if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
                
                *
            } 
            else {
                ErrorMsgPayment = 'Please setup the payment terminal';
            }
            if(payment.Transaction_Status__c == 'Completed' || payment.Transaction_Status__c == 'SuccessWithWarning' || payment.Transaction_Status__c == 'Success' || payment.Transaction_Status__c == 'Approved'){
                payment.ERP7__Type__c = 'Debit';
                Payment.ERP7__Payment_Type__c = 'Card';
                payment.ERP7__Payment_Date__c=System.today();
                upsert payment; 
            } else { 
                if(payment.sError__c != Null) ErrorMsgPayment = payment.sError__c;
            }
            return ErrorMsgPayment;   
        }catch(exception ex){
            ErrorMsgPayment = ex.getMessage();
            ErrorMsgPayment += ' Line No: '+ex.getLineNumber();
            ErrorMsgPayment += ' getStackTraceString: '+ex.getStackTraceString();
            return ErrorMsgPayment;
        }*/
        return null;
        
    }

    @AuraEnabled
    public static upsWrap DHLServices(String soId, String packType, Decimal packNo, String shipDate) {
        upsWrap upsWrapp = new upsWrap();
        
        String salesorderId = soId;   
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
        
        if(salesorderId != null) {                                        
            ERP7__Sales_Order__c currentSalesOrder = [select Id, Name, ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, 
                                 ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Country__c, 
                                 ERP7__Bill_To_Address__r.ERP7__Postal_Code__c, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                 ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, 
                                 ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c, ERP7__Issue_Invoice__c,
                                 ERP7__Contact__r.Name, ERP7__Contact__r.Company__c , ERP7__Contact__r.Phone from ERP7__Sales_Order__c where Id =: salesorderId];
            
            ERP7__Channel__c currentSalepoint = [Select Id, Name, ERP7__Active__c, ERP7__City__c, ERP7__Country__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Site__c,
                                ERP7__State_Province__c, ERP7__Street__c, ERP7__Tax__c, ERP7__Zip_Postal_Code__c, ERP7__Shipper_Name__c, ERP7__Company__c, 
                                ERP7__Phone__c From ERP7__Channel__c Where Id = : currentSalesorder.ERP7__Channel__c Limit 1];
            
            for(ERP7__Sales_Order_Line_Item__c soli : [select Id, Name, ERP7__product__c, ERP7__product__r.ERP7__Length__c, ERP7__product__r.ERP7__Width__c, ERP7__product__r.ERP7__Height__c, ERP7__product__r.ERP7__Weight__c, 
                                                       ERP7__product__r.ERP7__Description__c, ERP7__Quantity__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__r.Id =: currentSalesorder.Id]) {
                
                if(soli.ERP7__product__r.ERP7__Length__c != Null && soli.ERP7__product__r.ERP7__Width__c != Null && soli.ERP7__product__r.ERP7__Height__c != Null) soVolume += soli.ERP7__product__r.ERP7__Length__c * soli.ERP7__product__r.ERP7__Width__c * soli.ERP7__product__r.ERP7__Height__c * soli.ERP7__Quantity__c;    
                if(soli.ERP7__product__r.ERP7__Weight__c != Null) soWeight += soli.ERP7__product__r.ERP7__Weight__c * soli.ERP7__Quantity__c;
                lstSoli.add(soli);
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
                DhlPassword = dhlCre.Password_Transkey__c; 
                DhlUserName = dhlCre.Username_Login__c;
                DhlAccountNumber = dhlCre.UPS_Account_Number__c;
            
                List<ERP7__Province_Codes__c> lstProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : dhlCre.ERP7__Shipper_Province__c Limit 1];  
                if(lstProvinceCodes.Size() > 0) shipperProvinceCode = lstProvinceCodes[0].ERP7__Code__c;
                
                List<ERP7__Country_Codes__c> lstcountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: dhlCre.ERP7__Shipper_Country__c Limit 1];            
                if(lstcountryCodes.size() > 0) shipperCountryCode = lstcountryCodes[0].ERP7__Code__c;
                else errorMsg = 'DHL Shipping Service Unavailable : Shipper Country Code not found';
            } else errorMsg = 'DHL Shipping Service Unavailable : Please setup DHL credentials';
            
            if(currentSalesOrder != null){
                if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != '') {              
                    shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c; 
                } else if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != '') { 
                    shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c; 
                } else { shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c; }
            
                List<ERP7__Province_Codes__c> lstToProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];  
                if(lstToProvinceCodes.Size() > 0) shipAddress_ProvinceCode = lstToProvinceCodes[0].ERP7__Code__c; 
                
                List<ERP7__Country_Codes__c> lstTocountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Limit 1];            
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
                                            xmlBody += '<wsse:Username>' + DhlUserName + '</wsse:Username>';
                                            xmlBody += '<wsse:Password Type="wsse:PasswordText">' + DhlPassword + '</wsse:Password>';
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
                                                if(currentSalesOrder != null) {
                                                    xmlBody += '<Recipient>';
                                                        xmlBody += '<StreetLines>' + shipAddress_Street.escapeXml() + '</StreetLines>';
                                                        xmlBody += '<City>' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__City__c.escapeXml() + '</City>';
                                                        xmlBody += '<PostalCode>' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c .escapeXml() + '</PostalCode>';
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
                                            xmlBody += '<Account>' + DhlAccountNumber.escapeXml() + '</Account>';
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
                            resStatus = res.getStatus();  response_1 = res.getBody();
                            
                            if(resStatus == 'OK') {
                                XmlStreamReader reader1 = res.getXmlStreamReader(); string msg  = readXMLResponseWithAtt(reader1, 'Notification', 'code');
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

    @AuraEnabled
    public static String DhlServicesSave(String soId, String rateWrapperSelected, Decimal additionalPercent) {
        if(additionalPercent == null) additionalPercent = 0.00;
        rateWrapper rateWrap = (rateWrapper) JSON.deserialize(rateWrapperSelected, rateWrapper .class);
        
        String SalesOrderFields = 'id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c, erp7__Coupon_Discount__c, erp7__Product_Coupon_Discount__c';
        String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c ';
        String SalesOrderSoql = 'SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + ' FROM Sales_Order__c where Name=:soId or Id=:soId Limit 1'; 
        Sales_Order__c currentSalesOrder = Database.query(SalesOrderSoql);
        
        if(rateWrap.totalCharges != null && rateWrap.totalCharges != '' && rateWrap.totalCharges != '-') { 
            Decimal totalCharge = (Decimal.valueof(rateWrap.totalCharges) + ((Decimal.valueof(rateWrap.totalCharges) * additionalPercent) / 100));  currentSalesOrder.Estimated_Shipping_Amount__c = totalCharge.setscale(2);  currentSalesOrder.ERP7__Total_Shipping_Amount__c = totalCharge.setscale(2); 
        }
        
        currentSalesOrder.ERP7__Shipment_Type__c = 'DHL';
        if(rateWrap.service != null && rateWrap.service != '') { 
            currentSalesOrder.ERP7__UPS_Service__c = rateWrap.service;
        }
        if(Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isUpdateable() && Schema.SObjectType.Sales_Order__c.isCreateable() && Schema.SObjectType.Sales_Order__c.isUpdateable()){upsert currentSalesOrder; }else{/*not allowed to upsert SO*/}       
        return soId;
    }
    
    @AuraEnabled
    public static upsWrap FedServices(String soId, String packType, Decimal packNo, String shipDate) {
        
        upsWrap upsWrapp = new upsWrap();
        
        String salesorderId = soId;   
        String pkgType;                
        if(packType != null && packType != '--None--') pkgType = packType; else pkgType = 'YOUR_PACKAGING';
        String shipperProvinceCode = '', errorMsg = '', shipAddress_Street = '', shipAddress_ProvinceCode = '', shipAddress_CountryCode = '', shipperCountryCode = '', sp_ProvinceCode = '', sp_CountryCode = '';
        Decimal soVolume = 0, soWeight = 0; 
        Decimal pkgLength = 0, totalWeight = 0, pkgWidth = 0, pkgHeight = 0, pkgWeight = 0, additionalPercent = 0, totalPkgVolume = 0;
        Decimal totalWeightperPackage = 0;
        Decimal noOfPackages = 0;                    
        ERP7__Package__c pkg = new ERP7__Package__c();
        ERP7__Sales_Order__c so = new ERP7__Sales_Order__c();
        List<Selectoptions> packTypeListOption = new List<Selectoptions>();
        List<ERP7__Sales_Order_Line_Item__c> lstSoli = new List<ERP7__Sales_Order_Line_Item__c>();
        
        if(salesorderId != null) {                                        
            ERP7__Sales_Order__c currentSalesOrder = [select Id, Name, ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, 
                                 ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Country__c, 
                                 ERP7__Bill_To_Address__r.ERP7__Postal_Code__c, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                 ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, 
                                 ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c, ERP7__Issue_Invoice__c,
                                 ERP7__Contact__r.Name, ERP7__Contact__r.Company__c , ERP7__Contact__r.Phone from ERP7__Sales_Order__c where Id =: salesorderId];
            
            ERP7__Channel__c currentSalepoint = [Select Id, Name, ERP7__Active__c, ERP7__City__c, ERP7__Country__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Site__c,
                                ERP7__State_Province__c, ERP7__Street__c, ERP7__Tax__c, ERP7__Zip_Postal_Code__c, ERP7__Shipper_Name__c, ERP7__Company__c, 
                                ERP7__Phone__c From ERP7__Channel__c Where Id = : currentSalesorder.ERP7__Channel__c Limit 1];
            
            for(ERP7__Sales_Order_Line_Item__c soli : [select Id, Name, ERP7__product__c, ERP7__product__r.ERP7__Length__c, ERP7__product__r.ERP7__Width__c, ERP7__product__r.ERP7__Height__c, ERP7__product__r.ERP7__Weight__c, 
                                                       ERP7__product__r.ERP7__Description__c, ERP7__Quantity__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__r.Id =: currentSalesorder.Id]) {
                
                if(soli.ERP7__product__r.ERP7__Length__c != Null && soli.ERP7__product__r.ERP7__Width__c != Null && soli.ERP7__product__r.ERP7__Height__c != Null) soVolume += soli.ERP7__product__r.ERP7__Length__c * soli.ERP7__product__r.ERP7__Width__c * soli.ERP7__product__r.ERP7__Height__c * soli.ERP7__Quantity__c;    
                if(soli.ERP7__product__r.ERP7__Weight__c != Null) soWeight += soli.ERP7__product__r.ERP7__Weight__c * soli.ERP7__Quantity__c;
                lstSoli.add(soli);
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
            
            if(currentSalesOrder != null){
                if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != '') {              
                    shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c; 
                } else if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != '') { 
                    shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c; 
                } else { shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c; }
            
                List<ERP7__Province_Codes__c> lstToProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];  
                if(lstToProvinceCodes.Size() > 0) shipAddress_ProvinceCode = lstToProvinceCodes[0].ERP7__Code__c; 
                //else errorMsg = 'FedEx Shipping Service Unavailable : Shipping Address Province Code not found';
                
                List<ERP7__Country_Codes__c> lstTocountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Limit 1];            
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
                                    if(currentSalesOrder != null) {
                                        soapXML += '<Recipient>';
                                            soapXML += '<Contact>';
                                                soapXML += '<PersonName>'+ currentSalesOrder.ERP7__Contact__r.Name.escapeXml() +'</PersonName>';
                                                if(currentSalesOrder.ERP7__Contact__r.Company__c != null) soapXML += '<CompanyName>'+ currentSalesOrder.ERP7__Contact__r.Company__c.escapeXml() +'</CompanyName>';
                                                if(currentSalesOrder.ERP7__Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ currentSalesOrder.ERP7__Contact__r.Phone.escapeXml() +'</PhoneNumber>';
                                            soapXML += '</Contact>'; 
                                            soapXML += '<Address>';
                                                soapXML += '<StreetLines>' + shipAddress_Street.escapeXml() + '</StreetLines>';
                                                soapXML += '<City>' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__City__c.escapeXml() + '</City>';
                                                if(shipAddress_ProvinceCode != null) soapXML += '<StateOrProvinceCode>' + shipAddress_ProvinceCode.escapeXml() + '</StateOrProvinceCode>';
                                                soapXML += '<PostalCode>' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c .escapeXml() + '</PostalCode>';
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
                                            
                                            /*
                                            soapXML += '<ContentRecords>';
                                                if(lstSoli.size()>0){
                                                    soapXML += '<PartNumber>'+ lstSoli[i].Name +'</PartNumber>';
                                                    soapXML += '<ItemNumber>'+ lstSoli[i].Name +'</ItemNumber>'; 
                                                    soapXML += '<ReceivedQuantity>'+ Integer.valueof(lstSoli[i].ERP7__Quantity__c) +'</ReceivedQuantity>';
                                                    soapXML += '<Description>'+ lstSoli[i].ERP7__product__r.ERP7__Description__c +'</Description>';
                                                }
                                            soapXML += '</ContentRecords>';
                                            */
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
                            request_1 = soapXML;  response_1 = res.getBody();   resStatus = res.getStatus();
                            
                            if(res.getStatus() == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                                if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') {
                                    XmlStreamReader reader2 = res.getXmlStreamReader();   String resMesage = readXMLResponse(reader2, 'Code');
                                    if (resMesage == '556') {
                                        upsWrapp.UPSErrorMsg = 'There are no valid services available.';
                                    }else{
                                        XmlStreamReader reader = res.getXmlStreamReader();
                                        rateWrapper rw; List<rateWrapper> rateWrapperLst = new List<rateWrapper>(); 
                                        while(reader.hasNext()) {
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'RateReplyDetails') {  rw = new rateWrapper();
                                                while(reader.hasNext()) {
                                                    // service type
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceType') { reader.next();
                                                        rw.service = reader.getText(); }
                                                    // sur charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalSurcharges') { reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); 
                                                            if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); 
                                                            if(reader.hasText() && rw.totalSurcharges == '') rw.totalSurcharges = reader.getText(); /*+' '+ rw.currencyCode;*/ } }
                                                    // total charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNetCharge') { reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); 
                                                            if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); 
                                                            if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText(); /* +' '+ rw.currencyCode;*/ } }    
                                                    if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'RateReplyDetails') break; else reader.next();
                                                } rateWrapperLst.add(rw);
                                            } reader.next();
                                        }
                                          
                                          upsWrapp.Services = rateWrapperLst;
                                          upsWrapp.UPSErrorMsg = 'Available Services For The Selected Location';
                                          //time_in_cost_tab = true;
                                    }                                
                                } else { XmlStreamReader reader3 = res.getXmlStreamReader();
                                         String msg2 = readXMLResponse(reader3, 'Message');
                                         upsWrapp.UPSErrorMsg = 'Shipping Rate Service Is Not Available : ' + msg2;
                                }  
                            } else upsWrapp.UPSErrorMsg = 'Result not available';
                            
                        } catch(Exception e) { upsWrapp.UPSErrorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
                    } 
                }  
            }
        }
        return upsWrapp;
    }
    
    @AuraEnabled
    public static String FedServicesSave(String soId, String rateWrapperSelected, Decimal additionalPercent) {
        
        if(additionalPercent == null) additionalPercent = 0.00;
        
        rateWrapper rateWrap = (rateWrapper) JSON.deserialize(rateWrapperSelected, rateWrapper .class);
        String SalesOrderFields = 'id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c, erp7__Coupon_Discount__c, erp7__Product_Coupon_Discount__c';
        String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c ';
        String SalesOrderSoql = 'SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + ' FROM Sales_Order__c where Name=:soId or Id=:soId Limit 1'; // hande escape
        Sales_Order__c currentSalesOrder = Database.query(SalesOrderSoql);
        
        if(rateWrap.totalCharges != null && rateWrap.totalCharges != '' && rateWrap.totalCharges != '-') { 
            Decimal totalCharge = (Decimal.valueof(rateWrap.totalCharges) + ((Decimal.valueof(rateWrap.totalCharges) * additionalPercent) / 100));  currentSalesOrder.Estimated_Shipping_Amount__c = totalCharge.setscale(2);  currentSalesOrder.ERP7__Total_Shipping_Amount__c = totalCharge.setscale(2); 
        }
        
        currentSalesOrder.ERP7__Shipment_Type__c = 'FedEx';
        if(rateWrap.service != null && rateWrap.service != '') { 
            currentSalesOrder.ERP7__UPS_Service__c = rateWrap.service;
        }
        if(Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isUpdateable() && Schema.SObjectType.Sales_Order__c.isCreateable() && Schema.SObjectType.Sales_Order__c.isUpdateable()){upsert currentSalesOrder; }else{/*not allowed to upsert SO*/}   
        return soId;
    }    
    
    @AuraEnabled
    public static upsWrap UPSServices(String soId, String packType, Decimal packNo, String shipDate) {
            upsWrap upsWrapp = new upsWrap();
            
            String salesorderId = soId;   
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
            
            if(salesorderId != null) {                                        
                ERP7__Sales_Order__c currentSalesOrder = [select Id, Name, ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, 
                                     ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Country__c, 
                                     ERP7__Bill_To_Address__r.ERP7__Postal_Code__c, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                     ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Issue_Invoice__c,
                                     ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c from ERP7__Sales_Order__c where Id =: salesorderId];
                
                ERP7__Channel__c currentSalepoint = [Select Id, Name, ERP7__Active__c, ERP7__City__c, ERP7__Country__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Site__c,
                                    ERP7__State_Province__c, ERP7__Street__c, ERP7__Tax__c, ERP7__Zip_Postal_Code__c, ERP7__Shipper_Name__c, ERP7__Company__c, 
                                    ERP7__Phone__c From ERP7__Channel__c Where Id = : currentSalesorder.ERP7__Channel__c Limit 1];
                
                for(ERP7__Sales_Order_Line_Item__c soli : [select Id, Name, ERP7__product__c, ERP7__product__r.ERP7__Length__c, ERP7__product__r.ERP7__Width__c, ERP7__product__r.ERP7__Height__c, ERP7__product__r.ERP7__Weight__c, 
                                                                ERP7__Quantity__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__r.Id =: currentSalesorder.Id]) {
                    
                    if(soli.ERP7__product__r.ERP7__Length__c != Null && soli.ERP7__product__r.ERP7__Width__c != Null && soli.ERP7__product__r.ERP7__Height__c != Null) soVolume += soli.ERP7__product__r.ERP7__Length__c * soli.ERP7__product__r.ERP7__Width__c * soli.ERP7__product__r.ERP7__Height__c * soli.ERP7__Quantity__c;    
                    if(soli.ERP7__product__r.ERP7__Weight__c != Null) soWeight += soli.ERP7__product__r.ERP7__Weight__c * soli.ERP7__Quantity__c;
                }                                                            
                          
                ERP7__Credentials__c credentials = [Select Id, Name, ERP7__Active__c, ERP7__UPS_Account_Number__c, ERP7__Encrypted_Key__c, ERP7__End_Point__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Key__c, ERP7__Password_Transkey__c, //ERP7__Meter_Number__c, 
                               ERP7__Shipper_Name__c, ERP7__Shipper_Company_Name__c, ERP7__Shipper_Email__c, ERP7__Shipper_Phone_Number__c, ERP7__Shipper_Street__c, 
                               ERP7__Shipper_City__c, ERP7__Shipper_Postal_Code__c, ERP7__Shipper_Country__c, ERP7__Shipper_Province__c 
                               From ERP7__Credentials__c 
                               Where Name = 'UPS' And ERP7__Active__c = true And ERP7__UPS_Account_Number__c != null And ERP7__UPS_Account_Number__c != '' And //ERP7__End_Point__c != null And ERP7__End_Point__c != '' And
                               ERP7__Key__c != null And ERP7__Key__c != '' Limit 1];                       
                if(credentials != null) {
                    Blob cryptoKey, userData, passwordData;
                    cryptoKey = encodingUtil.convertFromHex(credentials.ERP7__Encrypted_Key__c);
                    userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials.ERP7__Username_Login__c));
                    passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials.ERP7__Password_Transkey__c));
                    if(userData != null) credentials.ERP7__Username_Login__c = userData.toString();
                    if(passwordData != null) credentials.ERP7__Password_Transkey__c = passwordData.toString();
                    
                    List<ERP7__Province_Codes__c> recProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : credentials.ERP7__Shipper_Province__c Limit 1];  
                if(recProvinceCodes.Size() > 0) shipperProvinceCode = recProvinceCodes[0].ERP7__Code__c; 
                else errorMsg = 'UPS Shipping Service Unavailable : Shipper Province Code not found';} else errorMsg = 'UPS Shipping Service Unavailable : Please setup UPS credentials';
                            
                if(credentials != null && currentSalesOrder != null) { 
                    List<ERP7__Country_Codes__c> countryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Or 
                                                                                                                          ERP7__Country__c =: currentSalepoint.ERP7__Country__c Or ERP7__Country__c =: credentials.ERP7__Shipper_Country__c Limit 3];            
                    if(countryCodes != null && countryCodes.size() == 0) errorMsg = 'UPS Shipping Service Unavailable : Country Code not found'; 
                    else { 
                        if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != '') {              
                                                 shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c + ', ' + 
                                                     currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c; } else{ shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c; }  
                        
                        List<ERP7__Province_Codes__c> shipProvinceCode = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];                     
                        if(shipProvinceCode != null && shipProvinceCode.Size() > 0) shipAddress_ProvinceCode = shipProvinceCode[0].ERP7__Code__c;
                        else errorMsg = 'UPS Shipping Service Unavailable : Shipping Address Province Code not found';
                        
                        if(countryCodes != null && countryCodes.size() > 0){
                            for(ERP7__Country_Codes__c c : countryCodes){
                                if(c.ERP7__Country__c == currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Country__c) shipAddress_CountryCode = c.ERP7__Code__c;
                                if(c.ERP7__Country__c == credentials.ERP7__Shipper_Country__c) shipperCountryCode = c.ERP7__Code__c;
                            }
                        }
                        if(shipAddress_CountryCode == null || shipAddress_CountryCode == '') errorMsg = 'UPS Shipping Service Unavailable : Shipping Address Country Code not found';
                        
                        List<ERP7__Province_Codes__c> recProvinceCode = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentSalepoint.ERP7__State_Province__c Limit 1]; 
                        if(recProvinceCode != null && recProvinceCode.Size() > 0) sp_ProvinceCode = recProvinceCode[0].ERP7__Code__c;
                        else errorMsg = 'UPS Shipping Service Unavailable : Salepoint Province Code not found';
                                 
                        if(countryCodes != null && countryCodes.size() > 0) {
                            for(ERP7__Country_Codes__c c :countryCodes) { if(c.ERP7__Country__c == currentSalepoint.ERP7__Country__c) sp_CountryCode = c.ERP7__Code__c; }
                        } 
                        if(sp_CountryCode == null || sp_CountryCode == ''){ errorMsg = 'UPS Shipping Service Unavailable : Salepoint Country Code not found'; } 
                        
                        List<ERP7__Package_Details__c> pkgDetailLists = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Weight__c, ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c Where ERP7__Type__c = 'UPS']; 
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
                                if(math.mod(Integer.valueof(soVolume),Integer.valueof(totalPkgVolume)) > 0) noOfPackages++;
                                //if(packNo != Null && packNo > noOfPackages) noOfPackages = packNo;
                                soVolume = soVolume.setscale(2);
                                soWeight = soWeight.setscale(2);
                                totalWeight = (soWeight + (noOfPackages * pkg.ERP7__Weight__c)).setscale(2);
                                totalWeightperPackage = (noOfPackages > 0)? (totalWeight / noOfPackages).setscale(2) : totalWeight;
                                
                                upsWrapp.PackageType  = pkgType;                    
                                upsWrapp.PackageTypes = packTypeListOption;    
                                if(shipDate != Null && shipDate != '') 
                                    upsWrapp.ShipmentDate = Date.valueOf(shipDate);
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
                                        if(currentSalesOrder != null) soapXML += '<City>'+ currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__City__c +'</City>';
                                        if(currentSalesOrder != null) soapXML += '<PostalCode>'+ currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c +'</PostalCode>';
                                        soapXML += '<CountryCode>'+ shipAddress_CountryCode +'</CountryCode>';
                                        soapXML += '</Address>';
                                        soapXML += '</ShipTo>';
                                        
                                        soapXML += '<ShipFrom>';
                                        soapXML += '<Address>';
                                        if(currentSalepoint != null) {
                                            soapXML += '<AddressLine1>'+ currentSalepoint.ERP7__Street__c +'</AddressLine1>';
                                            soapXML += '<City>'+ currentSalepoint.ERP7__City__c +'</City>';
                                            soapXML += '<StateProvinceCode>'+ sp_ProvinceCode +'</StateProvinceCode>';
                                            soapXML += '<PostalCode>'+ currentSalepoint.ERP7__Zip_Postal_Code__c +'</PostalCode>';
                                            soapXML += '<CountryCode>'+ sp_CountryCode +'</CountryCode>';
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
                                            soapXML += '<Package>';  soapXML += '<PackagingType>';  soapXML += '<Code>'+ packageTypeMap.get('Package').ERP7__Package_Code__c +'</Code>';  soapXML += '</PackagingType>';  soapXML += '<Dimensions>';   soapXML += '<UnitOfMeasurement>';
                                            if(pkg.ERP7__Weight_Unit__c == 'KGS')  soapXMl += '<Code>CM</Code>';
                                            else soapXMl += '<Code>IN</Code>';
                                                         
                                            soapXML += '</UnitOfMeasurement>';   soapXMl += '<Length>'+ pkg.ERP7__Length__c +'</Length>';  soapXML += '<Width>'+ pkg.ERP7__Width__c +'</Width>';  soapXML += '<Height>'+ pkg.ERP7__Height__c +'</Height>'; soapXML += '</Dimensions>';  soapXML += '<PackageWeight>';  soapXML += '<UnitOfMeasurement>';  soapXML += '<Code>'+ pkg.ERP7__Weight_Unit__c +'</Code>';   soapXML += '</UnitOfMeasurement>';  soapXML += '<Weight>'+ totalWeightperPackage +'</Weight>';  soapXML += '</PackageWeight>';  soapXML += '</Package>';
                                        }                            
                                    soapXML += '</Shipment>';
                                    soapXML += '</RatingServiceSelectionRequest>';                                    
                                    HttpRequest req = new HttpRequest(); Http h = new Http();
                                    
                                    req.setBody(soapXML); 
                                    req.setMethod('POST');
                                    //req.setEndpoint('https://onlinetools.ups.com/ups.app/xml/Rate');
                                    String myEndPoint = credentials.ERP7__URL__c + '/ups.app/xml/Rate'; 
                                    req.setEndpoint(myEndPoint);
                                    HttpResponse res = new HttpResponse();
                                    if(!Test.isRunningTest()) res = h.send(req);
                                    String Result = '';
                                    
                                    if(res.getStatus() == 'OK') {
                                        
                                        XmlStreamReader reader1 = res.getXmlStreamReader();  String msg = readXMLResponse(reader1, 'ResponseStatusDescription');
                                        if (msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                                            XmlStreamReader reader = res.getXmlStreamReader();
                                            
                                            String sxmltag = 'RatedShipment';
                                            rateWrapper rw; List<rateWrapper> rateWrapperList = new List<rateWrapper>();            
                                            while(reader.hasNext()) {
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { rw = new rateWrapper();                    
                                                    while(reader.hasNext()) {
                                                        //ups service
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Service') {
                                                            reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Code') { reader.next(); rw.ServiceCode = reader.getText(); }
                                
                                                            List <ERP7__UPS_Service_Codes__c> serviceCodes = [select Id, Name, ERP7__Service__c, ERP7__ServiceCode__c, ERP7__Service_Code_With_Trade_Mark__c, ERP7__Service_Asia_International__c,
                                                                                                                    ERP7__Service_Canada_Domestic__c, ERP7__Service_Canada_International__c, ERP7__Service_Europe__c, ERP7__Service_Mexico_Domestic__c,
                                                                                                                    ERP7__Service_Mexico_International__c, ERP7__Service_USA_Domestic__c from ERP7__UPS_Service_Codes__c limit 22];
                                                            if(sp_CountryCode == 'CA' && shipAddress_CountryCode == 'CA') { 
                                                                for(Integer i=0;i<serviceCodes.size();i++) {
                                                                    if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Canada_Domestic__c; }
                                                                }
                                                            } else if(sp_CountryCode == 'CA' && shipAddress_CountryCode != 'CA') {                                
                                                                for(Integer i=0;i<serviceCodes.size();i++) {
                                                                    if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Canada_International__c; }                                                       
                                                                }
                                                            } else if(sp_CountryCode == 'MX' && shipAddress_CountryCode == 'MX') {            
                                                                for(Integer i=0;i<serviceCodes.size();i++) {
                                                                    if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Mexico_Domestic__c; }                                                       
                                                                }
                                                            } else if(sp_CountryCode == 'MX' && shipAddress_CountryCode != 'MX') {  
                                                                for(Integer i=0;i<serviceCodes.size();i++) {
                                                                    if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Mexico_International__c; }                                                       
                                                                }
                                                            } else { for(Integer i=0;i<serviceCodes.size();i++) {
                                                                         if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Code_With_Trade_Mark__c; }   
                                                                     }
                                                            }
                                                        }
                                                        // transport charges
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TransportationCharges') {  reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();
                                                                if(reader.hasText() && rw.TransportationCharges == '') rw.TransportationCharges = reader.getText(); }          
                                                        }
                                                        // services charges
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceOptionsCharges') { reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 
                                                                if(reader.hasText() && rw.ServiceOptionsCharges == '') rw.ServiceOptionsCharges = reader.getText(); } 
                                                        }
                                                        // total charges
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalCharges') { reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 
                                                                if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText(); }
                                                        }
                                                        // days to deliver
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'GuaranteedDaysToDelivery') { reader.next();
                                                            if(reader.hasText()) {  rw.GuaranteedDaysToDelivery = reader.getText(); 
                                                                                    rw.DeliveryDate = upsWrapp.ShipmentDate + Integer.valueof(rw.GuaranteedDaysToDelivery);
                                                            } else { rw.GuaranteedDaysToDelivery = '-'; rw.DeliveryDateS = '-'; }
                                                        }                        
                                                        // time to deliver           
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ScheduledDeliveryTime') { reader.next();                        
                                                            if(reader.hasText()) { rw.ScheduledDeliveryTime = reader.getText(); }
                                                            else { rw.ScheduledDeliveryTime = '-'; }
                                                        }          
                                                        // negotiated charges                                       
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'NegotiatedRates') { reader.next(); reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();  
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 
                                                                if(reader.hasText() && rw.negotiatedCharges == '') rw.negotiatedCharges = reader.getText(); }    
                                                        }                        
                                                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();
                                                    } rateWrapperList.add(rw);               
                                                } reader.next();
                                            }            
                                            Integer n = rateWrapperList.size();            
                                            for(Integer c = 0 ; c < ( n - 1 ); c++) {
                                                for (Integer d = 0 ; d < n - c - 1; d++) {
                                                    if(Decimal.valueof(rateWrapperList[d].totalCharges) > Decimal.valueof(rateWrapperList[d+1].totalCharges)) { // For decreasing order use < 
                                                        rateWrapper swap = rateWrapperList[d]; rateWrapperList[d] = rateWrapperList[d+1]; rateWrapperList[d+1] = swap;
                                                    }
                                                }
                                            }       
                                            upsWrapp.Services = rateWrapperList;  upsWrapp.UPSErrorMsg = 'Available Services For The Selected Location';
                                        } else { XmlStreamReader reader3 = res.getXmlStreamReader();
                                            String msg1 = readXMLResponse(reader3, 'ErrorDescription');
                                            if (msg1 != Null && msg1 != '') upsWrapp.UPSErrorMsg = 'Shipping Rate Service Is Not Available : ' + msg1;
                                            else upsWrapp.UPSErrorMsg = 'Request To Rate Shipment Cannot Be Processed';
                                        }    
                                    } else upsWrapp.UPSErrorMsg = 'Result not available';            
                                } catch(Exception E) { upsWrapp.UPSErrorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); } 
                            }
                        }
                    } 
                }
            }                                    
        }
        return upsWrapp;
    }
    
    @AuraEnabled
    public static String UPSServiceSave(String soId, String rateWrapperSelected, String shipDate, Decimal additionalPercent) {
        
        rateWrapper rateWrap = (rateWrapper) JSON.deserialize(rateWrapperSelected, rateWrapper .class);
        //String SalesOrderFields = UtilClass.selectStarFromSObject('Sales_Order__c');
        String SalesOrderFields = 'id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c';
        String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c ';
        String SalesOrderSoql = 'SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + ' FROM Sales_Order__c where Name=:soId or Id=:soId Limit 1'; // hande escape
        Sales_Order__c currentSalesOrder = Database.query(SalesOrderSoql);
        if(rateWrap.negotiatedCharges != null && rateWrap.negotiatedCharges != '' && rateWrap.negotiatedCharges != '-') {
            Decimal negotiatedCharge = (Decimal.valueof(rateWrap.negotiatedCharges) + ((Decimal.valueof(rateWrap.negotiatedCharges) * additionalPercent) / 100));  currentSalesOrder.Estimated_Shipping_Amount__c = negotiatedCharge.setscale(2);   currentSalesOrder.ERP7__Total_Shipping_Amount__c = negotiatedCharge.setscale(2); 
        
        } else if(rateWrap.totalCharges != null && rateWrap.totalCharges != '' && rateWrap.totalCharges != '-') { 
            Decimal totalCharge = (Decimal.valueof(rateWrap.totalCharges) + ((Decimal.valueof(rateWrap.totalCharges) * additionalPercent) / 100)); currentSalesOrder.Estimated_Shipping_Amount__c = totalCharge.setscale(2);  currentSalesOrder.ERP7__Total_Shipping_Amount__c = totalCharge.setscale(2); 
        }
        
        currentSalesOrder.ERP7__Shipment_Type__c = 'UPS';
        if(rateWrap.ServiceManual != null) currentSalesOrder.UPS_Service__c = rateWrap.ServiceManual;
        if(rateWrap.GuaranteedDaysToDelivery != null && rateWrap.GuaranteedDaysToDelivery != '' && rateWrap.GuaranteedDaysToDelivery != '-') 
            currentSalesOrder.ERP7__Estimated_Delivery_Date__c = Date.valueOf(shipDate) + Integer.valueof(rateWrap.GuaranteedDaysToDelivery); 
        else currentSalesOrder.ERP7__Estimated_Delivery_Date__c = null;
        if(Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isUpdateable() && Schema.SObjectType.Sales_Order__c.isCreateable() && Schema.SObjectType.Sales_Order__c.isUpdateable()){upsert currentSalesOrder; }else{/*not allowed to upsert SO*/}  
        return soId;
    }  
    
    @AuraEnabled
    //@Deprecated
    public static comWrap getAllPayDetails(String sony) {
        comWrap comW = new comWrap();
        return comW;
    }
    
    @AuraEnabled
    public static comWrap getAccountPayDetails(String CUST){
        
        comWrap comW = new comWrap();
        String exceptionError;        
        try{
            List< ERP7__Module__c > logo = [Select Id, Name, ERP7__Run__c, ERP7__Description__c From ERP7__Module__c Where Name = 'LOGO' Limit 1];
            comW.logo = (logo.size() > 0)? logo[0].ERP7__Description__c : '';
            List< ERP7__Module__c > spinner = [Select Id, Name, ERP7__Run__c, ERP7__Description__c From ERP7__Module__c Where Name = 'Spinner' Limit 1];
            comW.spinner = (spinner.size() > 0)? spinner[0].ERP7__Description__c : '';
            //ERP7__Invoice__c invoice = new ERP7__Invoice__c();
            ERP7__Payment__c Pay = new ERP7__Payment__c();
            Account Customer = new Account();
            Contact Contact = new Contact();
            String AccountFields = UtilClass.selectStarFromSObject('Account');
            String AllAccountFields = AccountFields +', ERP7__VAT__r.Tax_Rate__c,Vat__r.Total_Tax__c ';
            String ContactFields = UtilClass.selectStarFromSObject('Contact');
            String AllContactFields = ContactFields + '';
            String paymentFields = UtilClass.selectStarFromSObject('ERP7__Payment__c');
            String AllPaymentFields = paymentFields + ',RecordType.Name,ERP7__Sales_Order__r.Name,ERP7__Payment_Method__r.Name '; 
            List < ERP7__Address__c > billingAddresses = new List < ERP7__Address__c > ();
            
            comW.CardError = '';
            comW.CountyList.add(new SelectOptions('--None--', ''));
            Schema.DescribeFieldResult fieldResultCnty = ERP7__Address__c.ERP7__State__c.getDescribe();
            List < Schema.PicklistEntry > cnty = fieldResultCnty.getPicklistValues();
            for(Schema.PicklistEntry f: cnty) {
                comW.CountyList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCntry = ERP7__Address__c.ERP7__Country__c.getDescribe();
            List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
            for(Schema.PicklistEntry f: cntry) {
                comW.CountryList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCardtype= ERP7__Payment_Method__c.ERP7__CardType__c.getDescribe();
            List < Schema.PicklistEntry > cardtype = fieldResultCardtype.getPicklistValues();
            for(Schema.PicklistEntry f: cardtype) {
                comW.CardTypes.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
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
            for(integer i=1;i<10;i++){
               comW.ExpiryYear.add(new SelectOptions(curMonth + '',curMonth++ + ''));
            }
            if(CUST != Null && CUST != '') {
                Map<Id, Contact> accContact = new Map<Id, Contact>();
                Map<Id, ERP7__Address__c> accBillingAddress = new Map<Id, ERP7__Address__c>();
                
                /*if(Schema.sObjectType.Invoice__c.isAccessible()) {
                    //invoice = Database.query('SELECT ' + AllInvoiceFields + ' FROM ERP7__Invoice__c where Name=:ivn or Id=:ivn Limit 1');
                    invoice = Database.query('SELECT Id,Name,ERP7__Account__c,ERP7__Active__c,ERP7__Amount_Paid__c,ERP7__Billing__c,ERP7__Code__c,ERP7__Contact__c,ERP7__Credit_Note__c,ERP7__Credit_Note_Issued__c,ERP7__Customer_Id__c,ERP7__Customer_Purchase_Order_No__c,ERP7__Discount__c,ERP7__Discount_Amount__c,ERP7__Total_Discount__c,ERP7__Down_Payment__c,ERP7__Total_Due__c,ERP7__Due_Date__c,ERP7__Final_Due_Amount__c,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Invoice_Shipping_Amount__c,ERP7__Is_Payment_Synced__c,ERP7__Loyalty_Amount__c,ERP7__Loyalty_Points__c,ERP7__Name_Link__c,ERP7__Name__c,ERP7__No_of_Line_Items__c,ERP7__Order__c,ERP7__Order_Number__c,ERP7__Organisation__c,ERP7__Organisation_Business_Unit__c,ERP7__Other_Tax__c,ERP7__Paid__c,ERP7__Paid_Amount__c,ERP7__Posted__c,ERP7__Posted_Date__c,ERP7__Prepayment__c,RecordTypeId,ERP7__Record_Type_Name__c,ERP7__Return_Amount__c,ERP7__Sales_Order_Amount__c,ERP7__Shipping_Amount__c,ERP7__Source__c,ERP7__Status__c,ERP7__Sub_Total__c,ERP7__Sub_Total_Amount__c,ERP7__Tax__c,ERP7__Tax_Amount__c,ERP7__Total_Tax__c,ERP7__Tax_Receipt__c,ERP7__Total_Down_Payment_Amount__c,ERP7__Total_Number_of_Items__c,ERP7__Type__c FROM ERP7__Invoice__c where Name=:ivn or Id=:ivn Limit 1');
                    CUST = invoice.ERP7__Account__c ;
                    
                }*/
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c FROM Account WHERE id =: CUST Limit 1');
                }
                if(Schema.sObjectType.Contact.isAccessible()) {
                    Contact = [SELECT Id, Name, FirstName, LastName, AccountID, Title, Email, Phone, ERP7__Contact_Numer__c, ERP7__Primary__c, Account.ERP7__Organisation__c 
                               FROM Contact 
                               WHERE AccountID =: CUST 
                               order by ERP7__Primary__c DESC Limit 1];
                    
                }
                
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    billingAddresses = [Select id, Name, ERP7__Customer__c, ERP7__Contact__c, ERP7__Active__c, ERP7__Primary__c, ERP7__Is_Billing_Address__c, ERP7__Is_Shipping_Address__c, ERP7__Address_Line1__c,
                                        ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__Country__c, ERP7__City__c, ERP7__State__c, ERP7__Postal_Code__c 
                                        From ERP7__Address__c
                                        Where ERP7__Customer__c = : CUST and 
                                        ERP7__Active__c = true and 
                                        ERP7__Is_Billing_Address__c = true and 
                                        ERP7__Primary__c = true 
                                        order by ERP7__Primary__c DESC, CreatedDate ASC limit 1];
                }
                
                //comW.invoice = invoice;
                comW.Customer = Customer; 
                comW.Contact = Contact;
                if(billingAddresses.size() == 0) billingAddresses.add(new Address__c());
                comW.billingAddresses = billingAddresses;
            }
            
        } catch(exception ex) { exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString(); comW.exceptionError = exceptionError;
            
        }
        
        return comW;
    }
    
    @AuraEnabled
    public static comWrap getInvoicePayDetails(String invId) {
        comWrap comW = new comWrap();
        string ivn = invId;
        String exceptionError;        
        try{
            List< ERP7__Module__c > logo = [Select Id, Name, ERP7__Run__c, ERP7__Description__c From ERP7__Module__c Where Name = 'LOGO' Limit 1];
            comW.logo = (logo.size() > 0)? logo[0].ERP7__Description__c : '';
            ERP7__Invoice__c invoice = new ERP7__Invoice__c();
            ERP7__Payment__c Pay = new ERP7__Payment__c();
            Account Customer = new Account();
            Contact Contact = new Contact();
            //String InvoiceFields = UtilClass.selectStarFromSObject('ERP7__Invoice__c');
            //String AllInvoiceFields = InvoiceFields + '';
            String AccountFields = UtilClass.selectStarFromSObject('Account');
            String AllAccountFields = AccountFields +', ERP7__VAT__r.Tax_Rate__c,Vat__r.Total_Tax__c ';
            String ContactFields = UtilClass.selectStarFromSObject('Contact');
            String AllContactFields = ContactFields + '';
            String paymentFields = UtilClass.selectStarFromSObject('ERP7__Payment__c');
            String AllPaymentFields = paymentFields + ',RecordType.Name,ERP7__Sales_Order__r.Name,ERP7__Payment_Method__r.Name '; 
            List < ERP7__Address__c > billingAddresses = new List < ERP7__Address__c > ();
            
            comW.CardError = '';
            comW.CountyList.add(new SelectOptions('--None--', ''));
            Schema.DescribeFieldResult fieldResultCnty = ERP7__Address__c.ERP7__State__c.getDescribe();
            List < Schema.PicklistEntry > cnty = fieldResultCnty.getPicklistValues();
            for(Schema.PicklistEntry f: cnty) {
                comW.CountyList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCntry = ERP7__Address__c.ERP7__Country__c.getDescribe();
            List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
            for(Schema.PicklistEntry f: cntry) {
                comW.CountryList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCardtype= ERP7__Payment_Method__c.ERP7__CardType__c.getDescribe();
            List < Schema.PicklistEntry > cardtype = fieldResultCardtype.getPicklistValues();
            for(Schema.PicklistEntry f: cardtype) {
                comW.CardTypes.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
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
            for(integer i=1;i<10;i++){
               comW.ExpiryYear.add(new SelectOptions(curMonth + '',curMonth++ + ''));
            }
            if(ivn != Null && ivn != '') {
                Map<Id, Contact> accContact = new Map<Id, Contact>();
                Map<Id, ERP7__Address__c> accBillingAddress = new Map<Id, ERP7__Address__c>();
                
                if(Schema.sObjectType.Invoice__c.isAccessible()) {
                    //invoice = Database.query('SELECT ' + AllInvoiceFields + ' FROM ERP7__Invoice__c where Name=:ivn or Id=:ivn Limit 1');
                    invoice = Database.query('SELECT Id,Name,ERP7__Account__c,ERP7__Active__c,ERP7__Amount_Paid__c,ERP7__Billing__c,ERP7__Code__c,ERP7__Contact__c,ERP7__Credit_Note__c,ERP7__Credit_Note_Issued__c,ERP7__Customer_Id__c,ERP7__Customer_Purchase_Order_No__c,ERP7__Discount__c,ERP7__Discount_Amount__c,ERP7__Total_Discount__c,ERP7__Down_Payment__c,ERP7__Total_Due__c,ERP7__Due_Date__c,ERP7__Final_Due_Amount__c,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Invoice_Shipping_Amount__c,ERP7__Is_Payment_Synced__c,ERP7__Loyalty_Amount__c,ERP7__Loyalty_Points__c,ERP7__Name_Link__c,ERP7__Name__c,ERP7__No_of_Line_Items__c,ERP7__Order__c,ERP7__Order_Number__c,ERP7__Organisation__c,ERP7__Organisation_Business_Unit__c,ERP7__Other_Tax__c,ERP7__Paid__c,ERP7__Paid_Amount__c,ERP7__Posted__c,ERP7__Posted_Date__c,ERP7__Prepayment__c,RecordTypeId,ERP7__Record_Type_Name__c,ERP7__Return_Amount__c,ERP7__Sales_Order_Amount__c,ERP7__Shipping_Amount__c,ERP7__Source__c,ERP7__Status__c,ERP7__Sub_Total__c,ERP7__Sub_Total_Amount__c,ERP7__Tax__c,ERP7__Tax_Amount__c,ERP7__Total_Tax__c,ERP7__Tax_Receipt__c,ERP7__Total_Down_Payment_Amount__c,ERP7__Total_Number_of_Items__c,ERP7__Type__c FROM ERP7__Invoice__c where Name=:ivn or Id=:ivn Limit 1');
                    CUST = invoice.ERP7__Account__c ;
                }
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c FROM Account WHERE id =: CUST Limit 1');
                }
                if(Schema.sObjectType.Contact.isAccessible()) {
                    Contact = [SELECT Id, Name, FirstName, LastName, AccountID, Title, Email, Phone, ERP7__Contact_Numer__c, ERP7__Primary__c, Account.ERP7__Organisation__c 
                               FROM Contact 
                               WHERE AccountID =: CUST 
                               order by ERP7__Primary__c DESC Limit 1];
                }
                
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    billingAddresses = [Select id, Name, ERP7__Customer__c, ERP7__Contact__c, ERP7__Active__c, ERP7__Primary__c, ERP7__Is_Billing_Address__c, ERP7__Is_Shipping_Address__c, ERP7__Address_Line1__c,
                                        ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__Country__c, ERP7__City__c, ERP7__State__c, ERP7__Postal_Code__c 
                                        From ERP7__Address__c
                                        Where ERP7__Customer__c = : CUST and 
                                        ERP7__Active__c = true and 
                                        ERP7__Is_Billing_Address__c = true and 
                                        ERP7__Primary__c = true 
                                        order by ERP7__Primary__c DESC, CreatedDate ASC limit 1];
                }
                
                comW.invoice = invoice;
                comW.Customer = Customer; 
                comW.Contact = Contact;
                if(billingAddresses.size() == 0) billingAddresses.add(new Address__c());
                comW.billingAddresses = billingAddresses;
            }
            
        } catch(exception ex) { exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString(); comW.exceptionError = exceptionError;
            
        }
        
        return comW;
    }
    
    @AuraEnabled
    public static comWrap getAllPayDetails2(String sony, String accf, String conf) {
        comWrap comW = new comWrap();
        son = sony;
        String exceptionError;
        try {
            List< ERP7__Module__c > logo = [Select Id, Name, ERP7__Run__c, ERP7__Description__c From ERP7__Module__c Where Name = 'LOGO' Limit 1];
            comW.logo = (logo.size() > 0)? logo[0].ERP7__Description__c : '';
            ERP7__Sales_Order__c SO = new ERP7__Sales_Order__c(Request_Date__c=system.today(), ERP7__Expected_Date__c = system.today());
            ERP7__Invoice__c invoice = new ERP7__Invoice__c();  
            ERP7__Payment__c Pay = new ERP7__Payment__c();
            //String SalesOrderFields = UtilClass.selectStarFromSObject('Sales_Order__c');
            //String SalesOrderFields = 'id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c';
            //String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c ';
            Account Customer = new Account();
            String AccountFields = UtilClass.selectStarFromSObject('Account');
            String AllAccountFields = AccountFields +', ERP7__VAT__r.Tax_Rate__c,Vat__r.Total_Tax__c ';
            Contact Contact = new Contact();
            String ContactFields = UtilClass.selectStarFromSObject('Contact');
            String AllContactFields = ContactFields + '';
            String paymentFields = UtilClass.selectStarFromSObject('ERP7__Payment__c');
            String AllPaymentFields = paymentFields + ',RecordType.Name,ERP7__Sales_Order__r.Name,ERP7__Payment_Method__r.Name '; 
            List < ERP7__Address__c > billingAddresses = new List < ERP7__Address__c > ();
            comW.CardError = '';
            
            comW.CountyList.add(new SelectOptions('--None--', ''));
            Schema.DescribeFieldResult fieldResultCnty = ERP7__Address__c.ERP7__State__c.getDescribe();
            List < Schema.PicklistEntry > cnty = fieldResultCnty.getPicklistValues();
            for(Schema.PicklistEntry f: cnty) {
                comW.CountyList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCntry = ERP7__Address__c.ERP7__Country__c.getDescribe();
            List < Schema.PicklistEntry > cntry = fieldResultCntry.getPicklistValues();
            for(Schema.PicklistEntry f: cntry) {
                comW.CountryList.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
            Schema.DescribeFieldResult fieldResultCardtype= ERP7__Payment_Method__c.ERP7__CardType__c.getDescribe();
            List < Schema.PicklistEntry > cardtype = fieldResultCardtype.getPicklistValues();
            for(Schema.PicklistEntry f: cardtype) {
                comW.CardTypes.add(new SelectOptions(f.getLabel(), f.getValue()));
            }
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
            for(integer i=1;i<10;i++){
               comW.ExpiryYear.add(new SelectOptions(curMonth + '',curMonth++ + ''));
            }
                
            if(son != Null && son != '') {
                if(Schema.sObjectType.Sales_Order__c.isAccessible()) {
                    SO = Database.query('SELECT Id ,erp7__Contact__r.Email,erp7__Account__r.Name,erp7__Channel__r.Name,erp7__Employees__r.erp7__Email__c, Name, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c FROM ERP7__Sales_Order__c where Name=:son or Id=:son Limit 1'); //verify escape sequence
                    CON = SO.Contact__c;
                    CUST = SO.Account__c;
                }
                if(Schema.sObjectType.Invoice__c.isAccessible()) {
                    invoice = new ERP7__Invoice__c();
                    List<ERP7__Invoice__c> invoices = [Select Id, Name, Organisation__c, Organisation_Business_Unit__c, Order__c From ERP7__Invoice__c Where Order__c = : SO.id Limit 1];
                    if(invoices.size() > 0) invoice = invoices[0];
                }
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    //if(Customer.ERP7__Is_Person_Account__c == true)
                    //Customer = Database.query('SELECT Id, Name, FirstName, LastName, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__Account_Profile__r.Name, ERP7__VAT__r.Name, ERP7__VAT__r.ERP7__Total_Tax__c, ERP7__VAT__r.ERP7__Tax_Rate__c '+String.escapeSingleQuotes(accf)+' FROM Account WHERE id = :CUST Limit 1');
                    //Customer = Database.query('SELECT '+String.escapeSingleQuotes(AllAccountFields)+' FROM Account WHERE Id = :CUST Limit 1');
                    //Customer = [SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c, ERP7__VAT__r.Total_Tax__c,Vat__r.Tax_Rate__c FROM Account WHERE Id = : CUST Limit 1];
                }
                if(Schema.sObjectType.Contact.isAccessible()) {
                    //Contact = Database.query('SELECT '+String.escapeSingleQuotes(ContactFields)+' FROM Contact WHERE Id = :CON Limit 1');
                    Contact = [SELECT Id, Name, FirstName, LastName, Title, Email, Phone, ERP7__Contact_Numer__c FROM Contact WHERE Id = : CON Limit 1];
                }
                
                if(Schema.sObjectType.Address__c.isAccessible()) {
                    billingAddresses = [Select id, Name, Active__c, Address_Line1__c, Address_Line2__c, Address_Line3__c, City__c, Contact__c, Country__c, Customer__c,
                                        Is_Billing_Address__c, Is_Shipping_Address__c, Primary__c, State__c, Postal_Code__c,
                                        Organisation__c, Organisation_Business_Unit__c
                                        From Address__c
                                        Where Id = : SO.ERP7__Bill_To_Address__c];
                }
                comW.Order = SO;
                comW.invoice = invoice;
                comW.Customer = Customer; 
                comW.Contact = Contact;
                if(billingAddresses.size() == 0) billingAddresses.add(new Address__c());
                comW.billingAddresses = billingAddresses;
            } 
            
        } catch(exception ex) {
            exceptionError = ex.getMessage();
            exceptionError += ' Line No: ' + ex.getLineNumber();
            exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();
            comW.exceptionError = exceptionError;
        }
        return comW;
    } 
    
    @AuraEnabled
    public static List<String> getPaymentType(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = ERP7__Payment__c.ERP7__Account_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    } 
    
    @AuraEnabled
    public static Map<String, Boolean> getCRUD(){
        Map<String,Boolean> crudValues = new Map<String,Boolean>();
        crudValues.put('ERP7__PO__c', Schema.sObjectType.ERP7__PO__c.isAccessible());
        crudValues.put('ERP7__Requisition__c', Schema.sObjectType.ERP7__Requisition__c.isAccessible());
        crudValues.put('ERP7__Manufacturing_Order__c', Schema.sObjectType.ERP7__Manufacturing_Order__c.isAccessible());
        crudValues.put('ERP7__WO__c', Schema.sObjectType.ERP7__WO__c.isAccessible());
        crudValues.put('ERP7__Authorised__c', Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Authorised__c.isAccessible());
        crudValues.put('ERP7__Issue_Invoice__c', Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Issue_Invoice__c.isAccessible());
        return crudValues;
    }
    
    //public void readXMLResponseRateTransitDetails(XmlStreamReader reader, String sxmltag) { }
    
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
    }

    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        string retValue;    // Read through the XML
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == sxmltag) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.characters) { 
                        retValue = reader.getText();
                    }
                }
            } 
            reader.next();
        }
        return retValue;//retValue.escapeXml();
    }
    
    @AuraEnabled 
    public static eposFlsWrap eposCheckFLS(){
        eposFlsWrap flsWRAP = new eposFlsWrap();  if (Schema.sObjectType.Account.fields.ERP7__Is_Person_Account__c.isAccessible()){flsWRAP.isPersonAccountBox = true;}  if (Schema.sObjectType.Account.fields.ERP7__VAT_registration_number__c.isAccessible()){flsWRAP.taxRegNoInput = true;} if (Schema.sObjectType.Account.fields.ERP7__VAT__c.isAccessible()){flsWRAP.taxInput = true;}
        return flsWRAP;
    }
       
    public class loyaltyWrap {
        @AuraEnabled public String customerCreditLimit              { get; Set; } 
        @AuraEnabled public Decimal FinalDue                        { get; Set; } 
        @AuraEnabled public Decimal TotalDue                        { get; Set; } 
        @AuraEnabled public Decimal loyaltyAmount                   { get; Set; } 
        @AuraEnabled public Decimal loyaltyPoints                   { get; Set; } 
        public loyaltyWrap() {}
    } 
    
    public class upsWrap {
        @AuraEnabled public String PackageType                      { get; Set; } 
        @AuraEnabled public List<selectOptions> PackageTypes        { get; Set; }
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
     
    @AuraEnabled public List<rateWrapper> rateWrapperList       { get; set; }
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
      
    public class returnClass {
        @AuraEnabled public String errorMsg                      { get; set; }                   
        @AuraEnabled public Boolean Error                        { get; set; }
        @AuraEnabled public String Value                         { get; set; }              
        
        public returnClass() { 
            errorMsg = '';
            Value = ''; 
            Error = false;
        }        
    }
    
    public class eposFlsWrap{                   
        @AuraEnabled public Boolean isPersonAccountBox            { get; set; }
        @AuraEnabled public Boolean taxRegNoInput                 { get; set; }
        @AuraEnabled public Boolean taxInput                  { get; set; }
        public eposFlsWrap(){
            isPersonAccountBox = false;  taxRegNoInput = false;  taxInput = false;
        }
    }
    
     @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){  return objResults; }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){  return objResults;   }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);  Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();  List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());  List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();  objResults.put(label, new List<String>());  controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;  String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {  objResults.get(controllingValues.get(i)).add(label);   }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);  val = Integer.valueOf(Math.floor(val / 2));  bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);  Integer val = base64Chars.indexOf(thisChar); String bits = decimalToBinary(val).leftPad(6, '0');  validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {        return (List<PicklistEntryWrapper>)            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}  public String defaultValue {get;set;}  public String label {get;set;}  public String value {get;set;}  public String validFor {get;set;}        public PicklistEntryWrapper(){   }
        
    }
    
    //========================Product Configuration start=====================
    @AuraEnabled
    public static OptionProd getOptionProd(String proforConfig, String customer){
        OptionProd optPr=new OptionProd();
        try{
            String pricebookId='';
            Set<Id> siteIds = new Set<Id>();
            Set<Id> prodIds=new Set<Id>();
            optPr.product=[Select Id,Name from Product2 where Id =:proforConfig Limit 1];
            List<ERP7__Product_Feature__c> pfList=[Select Id,Name,ERP7__Product__c from ERP7__Product_Feature__c where ERP7__Product__c =:proforConfig];
            List<ERP7__Product_Option__c> optprodsList=[Select Id,Name,ERP7__Product_Feature__r.Name,ERP7__Configured_SKU__c,ERP7__Optional_SKU__r.Name,ERP7__Optional_SKU__r.ProductCode,ERP7__Optional_SKU__r.ERP7__Picture__c,ERP7__Optional_SKU__c from ERP7__Product_Option__c where ERP7__Configured_SKU__c =:proforConfig];
            
            if(optprodsList.size() >0){
                for(ERP7__Product_Option__c po:optprodsList){
                    prodIds.add(po.ERP7__Optional_SKU__c);
                }
            }
            
            Account acc=[Select Id,Name,ERP7__Order_Profile__c from Account where Id =:customer Limit 1];
            if(acc.ERP7__Order_Profile__c != null){
                ERP7__Profiling__c profile=[Select Id,Name,ERP7__Channel__c, ERP7__Default__c,ERP7__Price_Book__c from ERP7__Profiling__c where Id =:acc.ERP7__Order_Profile__c Limit 1];
                pricebookId = profile.ERP7__Price_Book__c;
                ERP7__Channel__c channel=[Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true];
                List<Distribution_Channel__c> distChannel=[Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];
                if(distChannel.size() > 0) {
                    for(Distribution_Channel__c DC: distChannel) {
                        siteIds.add(DC.Site__c);
                    }
                }
                
                List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
                if(prodIds.size() > 0) {
                    WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                    Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,
                                                    Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                    From Inventory_Stock__c
                                                    Where product__c In: prodIds And
                                                    Active__c = true And
                                                    Warehouse__c In: siteIds And                                                 
                                                    Number_of_Item_In_Stock__c > 0
                                                   ];
                }
                
                for(Id prId:prodIds){
                    Stock st=new Stock();
                    Decimal stock=0;
                    for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                        if(prId == inven.product__c){
                            stock += inven.Number_of_Item_In_Stock__c;
                        }
                    }
                    st.ProId=prId;
                    st.stockAvlb=stock;
                    optPr.totalStock.add(st);
                }
            }  
            
            
            List<PricebookEntry> pbe1= [Select Product2Id,UnitPrice,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Id In :prodIds) AND IsActive=TRUE];
            
            //Set<Id> proFeatureIds=new Set<Id>();        
            for(ERP7__Product_Feature__c pf : pfList){      
                FeatureWrapper fw=new FeatureWrapper();
                for(ERP7__Product_Option__c po : optprodsList){
                    if(pf.Name == po.ERP7__Product_Feature__r.Name){
                        //proFeatureIds.add(pf.Id);                  
                        fw.feature = pf;
                        fw.featOpt.add(po);
                        for(PricebookEntry pb: pbe1){
                            if(po.ERP7__Optional_SKU__c == pb.Product2Id){ fw.pbe.add(pb);
                            }                            
                        }
                    }
                }
                if(fw.featOpt.size() > 0)
                    optPr.featrWrapper.add(fw);
            }    
            /*FeatureWrapper fw1=new FeatureWrapper();
            List<ERP7__Product_Option__c> otherOpt=[Select Id,Name,ERP7__Product_Feature__r.Name,ERP7__Configured_SKU__c,ERP7__Optional_SKU__r.Name,ERP7__Optional_SKU__r.ProductCode from ERP7__Product_Option__c where ERP7__Configured_SKU__c =:proforConfig AND ERP7__Product_Feature__c NOT IN :proFeatureIds];
            if(otherOpt.size() > 0){
                fw1.othersPro.addAll(otherOpt);
                //optPr.othersPro = otherOpt;
                optPr.featrWrapper.add(fw1);
            }*/
            
                      
        }catch(Exception e){ optPr.errorMsg=e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
         
        return optPr;
    }
    
    @AuraEnabled
    public static OptionProd getAllOptionRules(String proId){
        OptionProd optRule=new OptionProd();
        optRule.optionRules = [Select Id,Name,ERP7__Configured_SKU__c,ERP7__Active__c,ERP7__Parent_Option__c,ERP7__Parent_Option__r.ERP7__Optional_SKU__r.Name,ERP7__Child_Option__c,ERP7__Type__c from ERP7__Rule__c where ERP7__Configured_SKU__c =:proId AND ERP7__Active__c =true];
        return optRule;
    }
    
    @AuraEnabled
    public static List<ERP7__Invoice__c> SOInvoiceList(String SOId){
        return [Select Id,Name,ERP7__Total_Due__c from ERP7__Invoice__c Where ERP7__Order__c =:SOId AND ERP7__Paid__c= false  AND ERP7__Total_Due__c > 0.00];
    }
    
    //====================================================================
    //===============Product Configurator start=================
   /* @AuraEnabled 
    public static comWrap ConfigureMO(String RId){  
        comWrap comW = new comWrap();   
        try{
            if(RId != '' && RId != Null){
                String VId = '';
                String pFields = UtilClass.selectStarFromSObject('ERP7__Routing__c');
                pFields += ', ERP7__Address__r.ERP7__Address_Line1__c, ERP7__Address__r.ERP7__Address_Line2__c, ERP7__Address__r.ERP7__Address_Line3__c, ERP7__Address__r.ERP7__City__c, ERP7__Address__r.ERP7__State__c, ERP7__Address__r.ERP7__Country__c, ERP7__Address__r.ERP7__Postal_Code__c, ERP7__BOM_Version__r.Name, ERP7__Product__r.Name, ERP7__Process__r.Name, ERP7__Process__r.RecordType.Name, ERP7__Product__r.ERP7__MOQ__c, ERP7__Product__r.ERP7__Configure__c ';
                utilClass.FLSCheck(pFields.split(','),'ERP7__Routing__c');  
                String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Routing__c Where ERP7__Status__c = \'Certified\' ';
                query1 += ' And Id = : RId ';
                List<ERP7__Routing__c> Routings = Database.query(query1);
                if(Routings.size() > 0){
                    comW.Routing = Routings[0];
                    comW.SelectedRouting = comW.Routing.clone(false, false, false, false);
                    VId = comW.Routing.ERP7__BOM_Version__c;
                }
                else VId = RId;
               
                pFields = UtilClass.selectStarFromSObject('ERP7__Version__c');
                utilClass.FLSCheck(pFields.split(','),'ERP7__Version__c');  
                query1 = 'select ' + String.escapeSingleQuotes(pFields) + ',ERP7__Product__r.Name from ERP7__Version__c Where ERP7__Status__c = \'Certified\' And ERP7__Active__c = true And ERP7__To_Date__c >= TODAY';
                if(VId != '' && VId != Null) query1 += ' And Id = : VId ';
                comW.Version = Database.query(query1);
                comW.SelectedVersion = comW.Version.clone(false, false, false, false);
                
                List < ERP7__BOM__c > BOMS = [Select Id, Name, ERP7__Active__c, BOM_Product__c, BOM_Version__c, ERP7__Routing_Link__c, ERP7__BOM_Component__c, ERP7__BOM_Component__r.Name, ERP7__BOM_Component__r.Picture__c, ERP7__BOM_Component__r.Preview_Image__c, ERP7__Quantity__c, RecordType.Name, ERP7__For_Multiples__c,
                                                BOM_Version__r.Active__c, BOM_Version__r.Category__c, BOM_Version__r.Default__c, BOM_Version__r.Start_Date__c, BOM_Version__r.To_Date__c, BOM_Version__r.Type__c, BOM_Version__r.Status__c, ERP7__Type__c, ERP7__Process_Cycle__c, ERP7__Minimum_Variance__c, ERP7__Maximum_Variance__c,
                                                ERP7__Product_Feature__c, ERP7__Product_Feature__r.Name, ERP7__Cost_Price__c, ERP7__Description__c, ERP7__Unit_of_Measure__c, ERP7__Exact_Quantity__c
                                                From ERP7__BOM__c
                                                Where ERP7__Active__c = true And
                                                ERP7__BOM_Version__c =: comW.Version.Id And
                                                ERP7__BOM_Product__c =: comW.Version.ERP7__Product__c And
                                                ERP7__Type__c = 'Primary' And
                                                BOM_Version__r.Active__c = true And
                                                BOM_Version__r.Start_Date__c <= Today And
                                                (BOM_Version__r.To_Date__c = Null Or BOM_Version__r.To_Date__c >= Today) And
                                                RecordType.Name = 'Manufacturing BOM'
                                                Order by BOM_Version__r.Default__c DESC
                                            ];
                
                List < ERP7__Variance__c > Variances = [Select Id, Name, ERP7__Bill_Of_Material__c, ERP7__BOM_Variance__c, ERP7__Product__c, ERP7__Product_Feature__c, ERP7__Product_Feature__r.Name, ERP7__Type__c, ERP7__BOM_Variance__r.ERP7__BOM_Component__r.Name,
                                                            ERP7__BOM_Variance__r.ERP7__BOM_Component__c, ERP7__BOM_Variance__r.RecordType.Name, ERP7__BOM_Variance__r.RecordTypeId, ERP7__BOM_Variance__r.ERP7__BOM_Version__c, ERP7__BOM_Variance__r.ERP7__BOM_Component__r.ERP7__Picture__c,
                                                            ERP7__Active__c, ERP7__BOM_Variance__r.ERP7__Unit_of_Measure__c, ERP7__BOM_Variance__r.ERP7__Quantity__c, ERP7__BOM_Variance__r.ERP7__Cost_Price__c, ERP7__BOM_Variance__r.ERP7__Description__c, ERP7__BOM_Variance__r.ERP7__Exact_Quantity__c
                                                            From ERP7__Variance__c 
                                                            Where ERP7__Type__c = 'Alternative' And
                                                            ERP7__BOM_Variance__r.ERP7__BOM_Version__c =: comW.Version.Id And
                                                            ERP7__Bill_Of_Material__c IN :BOMS And
                                                            ERP7__Active__c = true
                                                       ];
                                         
               for(ERP7__BOM__c BOM : BOMS){
                   BOMWrapper BOMW = new BOMWrapper();
                   //BOM.ERP7__Active__c = false;
                   BOMW.BOM = BOM;
                   for(ERP7__Variance__c Variance : Variances){
                       if(Variance.ERP7__Bill_Of_Material__c == BOM.Id) {
                           Variance.ERP7__Active__c = false;
                           BOMW.Variances.add(Variance);
                       }
                   }
                   comW.BOMWrapperList.add(BOMW);
               } 
            }
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
    
    @AuraEnabled
    public static comWrap SaveConfiguration(String BOMWrapperList, String RoutingId, String NewRouting, String NewVersion){   
        List<BOMWrapper> BOMWrapperLists = (List<BOMWrapper>) JSON.deserialize(BOMWrapperList, List<BOMWrapper> .class);
        ERP7__Routing__c nRouting = (ERP7__Routing__c) JSON.deserialize(NewRouting, ERP7__Routing__c .class);
        ERP7__Version__c nVersion = (ERP7__Version__c) JSON.deserialize(NewVersion, ERP7__Version__c .class);
        //List<ERP7__Routing__c> rt=[Select Id, Name from ERP7__Routing__c where Name =:'Customer Portal Routing']; if(rt.size() > 0)   delete rt;
        //List<ERP7__Version__c> vr=[Select Id, Name from ERP7__Version__c where Name =:'Customer Portal Version']; if(vr.size() > 0)   delete vr;
        
        comWrap comW = new comWrap();
        try{
            upsert nVersion;
            nRouting.ERP7__BOM_Version__c = nVersion.Id;
            upsert nRouting;
            Set<Id> bomIds = new Set<Id>();
            for(BOMWrapper BOMW : BOMWrapperLists){
                if(BOMW.BOM.ERP7__Active__c == true){
                    bomIds.add(BOMW.BOM.Id);
                } else {
                    for(ERP7__Variance__c Variance : BOMW.Variances){
                        if(Variance.ERP7__Active__c == true) {
                            bomIds.add(Variance.ERP7__BOM_Variance__c);
                        }
                    }
                }
            }
            String pFields = UtilClass.selectStarFromSObject('ERP7__BOM__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__BOM__c');  
            String query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__BOM__c Where Id In : bomIds ';
            List<ERP7__BOM__c> BOMS = Database.query(query1);
            
            Map<Id, ERP7__BOM__c> bomMap = new Map<Id, ERP7__BOM__c>();
            for(ERP7__BOM__c BOM : BOMS) bomMap.put(BOM.Id, BOM);
            List<ERP7__BOM__c> BOMS2Upsert = new List<ERP7__BOM__c>();
            
            for(BOMWrapper BOMW : BOMWrapperLists){
                if(BOMW.BOM.ERP7__Active__c == true){
                    ERP7__BOM__c BOM = bomMap.get(BOMW.BOM.Id).clone(false, false, false, false);
                    BOM.ERP7__BOM_Version__c = nVersion.Id;
                    BOM.ERP7__Quantity__c = BOMW.BOM.ERP7__Quantity__c;
                    BOM.ERP7__Cost_Price__c = BOMW.BOM.ERP7__Cost_Price__c;
                    BOMS2Upsert.add(BOM);
                } else {
                    for(ERP7__Variance__c Variance : BOMW.Variances){
                        if(Variance.ERP7__Active__c == true) {
                            ERP7__BOM__c BOM = bomMap.get(Variance.ERP7__BOM_Variance__c).clone(false, false, false, false);
                            BOM.ERP7__BOM_Version__c = nVersion.Id;
                            BOM.ERP7__Quantity__c = Variance.ERP7__BOM_Variance__r.ERP7__Quantity__c;
                            BOM.ERP7__Cost_Price__c = Variance.ERP7__BOM_Variance__r.ERP7__Cost_Price__c;
                            BOMS2Upsert.add(BOM);
                        }
                    }
                }
            }
            if(BOMS2Upsert.size() > 0) upsert BOMS2Upsert;
            
            pFields = UtilClass.selectStarFromSObject('ERP7__Operation__c');
            utilClass.FLSCheck(pFields.split(','),'ERP7__Operation__c');  
            query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Operation__c Where ERP7__Routing__c = : RoutingId ';
            List< ERP7__Operation__c > Operations = Database.query(query1);
            
            List<ERP7__Operation__c> Operations2Upsert = new List<ERP7__Operation__c>();
            for(ERP7__Operation__c Operation : Operations){
                ERP7__Operation__c Oprn = Operation.clone(false, false, false, false);
                Oprn.ERP7__Routing__c = nRouting.Id;
                Operations2Upsert.add(Oprn);
            }
            if(Operations2Upsert.size() > 0) upsert Operations2Upsert;
            comW.SelectedVersion = nVersion;
            comW.SelectedRouting = nRouting;
            
        } catch(Exception e) { comW.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return comW;
    }
        
    public class comWrap {
        @AuraEnabled public String errorMsg                                         { get ; set; }
        @AuraEnabled public ERP7__Routing__c Routing                                { get ; set; }
        @AuraEnabled public ERP7__Version__c Version                                { get ; set; }
        @AuraEnabled public ERP7__Routing__c SelectedRouting                        { get ; set; }
        @AuraEnabled public ERP7__Version__c SelectedVersion                        { get ; set; }  
        @AuraEnabled public List< ERP7__BOM__c > BOMS                               { get ; set; } 
        @AuraEnabled public List< BOMWrapper > BOMWrapperList                       { get ; set; }  
        
        public comWrap() {
            errorMsg = ''; 
            BOMWrapperList = new List< BOMWrapper >();
            BOMS = new List<ERP7__BOM__c>();
            Routing = new ERP7__Routing__c();
            Version = new ERP7__Version__c();
            SelectedRouting = new ERP7__Routing__c();
            SelectedVersion = new ERP7__Version__c();                    
        }
    }  
    
    public class BOMWrapper{
        @AuraEnabled public List < ERP7__Variance__c > Variances           { get ; set; }
        @AuraEnabled public ERP7__BOM__c BOM                               { get ; set; }
        @AuraEnabled public ERP7__BOM__c SelectedBOM                       { get ; set; }
        
        public BOMWrapper(){
            Variances = new List < ERP7__Variance__c >();
            BOM = new ERP7__BOM__c(); 
            SelectedBOM = new ERP7__BOM__c();
        }
    }*/
    
    //=====================================================================
    
    
    @AuraEnabled
    public static String createVersion(String selectedProds,String prodId,String proFeatureMap){  //Map<String, Object> selectedProds , String proOptions
        try{
            Map<String, Integer> selectedProds1=new Map<String, Integer>();
            Map<String, Decimal> proOptions1=(Map<String, Decimal>) JSON.deserialize(selectedProds, Map<String, Decimal> .class);
            
            for(String objVar : proOptions1.keySet()){
                selectedProds1.put(objVar,(Integer)proOptions1.get(objVar));            
            }
            //List<FeatureWrapper> proOptions1=(List<FeatureWrapper>) JSON.deserialize(proOptions, List<FeatureWrapper> .class);
            Date dToday = Date.today();
            Date toDate = Date.today()+30;
            String dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
            String toDateStr = toDate.day() + '/' + toDate.month() + '/' + toDate.year();
            Product2 mainPro=[Select Id,Name,ERP7__Issue_Manufacturing_Order__c from Product2 where Id =:prodId];

            Id RT; RT = Schema.SObjectType.ERP7__Version__c.getRecordTypeInfosByDeveloperName().get('Manufacturing').getRecordTypeId();
            Id BOMRt; BOMRt = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_BOM').getRecordTypeId();

            Boolean isVersAvailable=false;
            Boolean isRoutAvailable=false;
            String existingVersion='';
            //========Search for version with available with related BOM============
            List<ERP7__Version__c> verList=[Select Id,Name from ERP7__Version__c where RecordTypeId =:RT AND ERP7__Product__c =:prodId AND ERP7__Active__c=true
                                            AND ERP7__Start_Date__c <= Today AND ERP7__To_Date__c >= Today];
            if(verList.size() > 0){
                for(ERP7__Version__c vr:verList){
                    List<ERP7__BOM__c> bomList=[Select Id,Name,ERP7__BOM_Product__c,ERP7__BOM_Component__c,RecordTypeId,ERP7__BOM_Version__c,ERP7__Type__c,ERP7__Status__c,ERP7__Quantity__c from ERP7__BOM__c where 
                                                ERP7__BOM_Product__c =:mainPro.Id AND
                                                RecordTypeId =:BOMRt AND
                                                ERP7__BOM_Version__c =:vr.Id AND
                                                ERP7__Type__c ='Primary' AND 
                                                ERP7__Active__c=true AND
                                                ERP7__Status__c ='Certified'];
                    if(bomList.size() > 0){
                        Map<String, Decimal> selectedProdsexist=new Map<String, Decimal>();
                        for(ERP7__BOM__c bom1:bomList){
                            selectedProdsexist.put(bom1.ERP7__BOM_Component__c, (Integer)bom1.ERP7__Quantity__c);
                        }
                        
                        if(selectedProdsexist.equals(proOptions1)){ isVersAvailable=true; existingVersion = vr.Id;}
                        
                    }
                    
                }
            }
            //========/Search for version with available with related BOM===========
            //========Search for routing with available with related version===========
            /*if(existingVersion != '' && mainPro.ERP7__Issue_Manufacturing_Order__c){
                ERP7__Routing__c rtng=new ERP7__Routing__c();
                rtng=[Select Id,Name from ERP7__Routing__c where ERP7__BOM_Version__c =:existingVersion Limit 1];
                
                if(rtng != null) isRoutAvailable=true;
                else{
                    ERP7__Routing__c rtngForClone=new ERP7__Routing__c();
                    rtngForClone=[Select Id,Name,ERP7__Channel__c,ERP7__Product__c,ERP7__Status__c,ERP7__Process__c,ERP7__Raw_Materials_Site__c,ERP7__Finished_Products_Site__c,ERP7__Work_Center__c,ERP7__Auto_Stock_Allocation__c,ERP7__Project__c,ERP7__Address__c,ERP7__Minimum_Lot_Size__c,ERP7__Maximum_Lot_Size__c from ERP7__Routing__c where ERP7__Product__c =:mainPro.Id Limit 1];
                    
                    Id RTRouting; RTRouting = Schema.SObjectType.ERP7__Routing__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_Routing').getRecordTypeId();

                    List<ERP7__Routing__c> rtngList=new List<ERP7__Routing__c>();
                    ERP7__Routing__c newRtng=new ERP7__Routing__c();
                    newRtng.Name='ePos Routing';
                    newRtng.RecordTypeId=RTRouting;
                    if(rtngForClone.ERP7__Channel__c != null) newRtng.ERP7__Channel__c=rtngForClone.ERP7__Channel__c;
                    if(rtngForClone.ERP7__Product__c != null) newRtng.ERP7__Product__c=rtngForClone.ERP7__Product__c;
                    if(rtngForClone.ERP7__Status__c != null) newRtng.ERP7__Status__c=rtngForClone.ERP7__Status__c;
                    newRtng.ERP7__BOM_Version__c=existingVersion;
                    if(rtngForClone.ERP7__Process__c != null) newRtng.ERP7__Process__c=rtngForClone.ERP7__Process__c;
                    if(rtngForClone.ERP7__Raw_Materials_Site__c != null) newRtng.ERP7__Raw_Materials_Site__c=rtngForClone.ERP7__Raw_Materials_Site__c;
                    if(rtngForClone.ERP7__Finished_Products_Site__c != null) newRtng.ERP7__Finished_Products_Site__c=rtngForClone.ERP7__Finished_Products_Site__c;
                    if(rtngForClone.ERP7__Work_Center__c != null) newRtng.ERP7__Work_Center__c=rtngForClone.ERP7__Work_Center__c;
                    if(rtngForClone.ERP7__Auto_Stock_Allocation__c != null) newRtng.ERP7__Auto_Stock_Allocation__c=rtngForClone.ERP7__Auto_Stock_Allocation__c;
                    if(rtngForClone.ERP7__Address__c != null) newRtng.ERP7__Address__c=rtngForClone.ERP7__Address__c;
                    if(rtngForClone.ERP7__Minimum_Lot_Size__c != null) newRtng.ERP7__Minimum_Lot_Size__c=rtngForClone.ERP7__Minimum_Lot_Size__c;
                    if(rtngForClone.ERP7__Maximum_Lot_Size__c != null) newRtng.ERP7__Maximum_Lot_Size__c=rtngForClone.ERP7__Maximum_Lot_Size__c;
                    rtngList.add(newRtng);
                    if(rtngList.size() > 0)  rtngList;
                    
                    //==========creating Operation==============
                    ERP7__Routing__c rtng1=[Select Id,Name from ERP7__Routing__c where ERP7__BOM_Version__c =:existingVersion Limit 1];
                    String rtng1Id=rtngForClone.Id;
                    String pFields = UtilClass.selectStarFromSObject('ERP7__Operation__c');
                    utilClass.FLSCheck(pFields.split(','),'ERP7__Operation__c');  
                    String  query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Operation__c Where ERP7__Routing__c =: rtng1Id ';
                    List< ERP7__Operation__c > Operations = Database.query(query1);
                    
                    List<ERP7__Operation__c> Operations2Upsert = new List<ERP7__Operation__c>();
                    for(ERP7__Operation__c Operation : Operations){
                        ERP7__Operation__c Oprn = Operation.clone(false, false, false, false);
                        Oprn.ERP7__Routing__c = rtng1.Id;
                        Operations2Upsert.add(Oprn);
                    }
                    if(Operations2Upsert.size() > 0) upsert Operations2Upsert;                
                }   
            }      */  
            //========Search for routing with available with related versionend===========
            if(isVersAvailable) return existingVersion;
            else{
                //'create new version and routing'
                //=========create version and BOM start================
                ERP7__Version__c version=new ERP7__Version__c(RecordTypeId = RT,Name='ePos Version',ERP7__Product__c=prodId,
                                                              ERP7__Active__c=true,ERP7__Type__c='Assembly',ERP7__Status__c='Certified',
                                                              ERP7__Quantity__c=1,ERP7__Start_Date__c=Date.parse(dateStr),ERP7__To_Date__c=Date.parse(toDateStr),ERP7__Unit_of_Measure__c='Each',
                                                              ERP7__Sales_Ready__c=true);
                if(Schema.sObjectType.ERP7__Version__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__To_Date__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Sales_Ready__c.isCreateable()){insert version;}else{/*not allowed to insert version*/}
                Map<String, String> proFeatureMap1=(Map<String, String>) JSON.deserialize(proFeatureMap, Map<String, String> .class);
                for(String sp : proOptions1.keySet()){
                    Product2 pro=[Select Id,Name from Product2 where Id=:sp];                
                    ERP7__Product_Feature__c pfeat=[Select Id,Name,ERP7__Process_Cycle__c,ERP7__Routing_Link__c from ERP7__Product_Feature__c where Id =:proFeatureMap1.get(sp)];
                    
                    ERP7__BOM__c bom=new ERP7__BOM__c(RecordTypeId=BOMRt,Name=pro.Name,ERP7__BOM_Product__c=mainPro.Id,ERP7__Active__c=true,
                                                      ERP7__BOM_Version__c=version.Id,ERP7__Type__c='Primary',ERP7__Status__c='Certified',
                                                      ERP7__Unit_of_Measure__c='Each',ERP7__BOM_Component__c=pro.Id,ERP7__Quantity__c=proOptions1.get(sp),
                                                      ERP7__Process_Cycle__c=pfeat.ERP7__Process_Cycle__c,ERP7__Routing_Link__c=pfeat.ERP7__Routing_Link__c);
                    if(Schema.sObjectType.ERP7__BOM__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isCreateable()){insert bom;}else{/*Not allowed to insert BOM*/}                
                }
                //=========create version and BOM end================
                
                //=========create Routing=============
                if(mainPro.ERP7__Issue_Manufacturing_Order__c){
                    ERP7__Routing__c rtngForClone=new ERP7__Routing__c();
                    rtngForClone=[Select Id,Name,ERP7__Channel__c,ERP7__Product__c,ERP7__Status__c,ERP7__Process__c,ERP7__Raw_Materials_Site__c,ERP7__Finished_Products_Site__c,ERP7__Work_Center__c,ERP7__Auto_Stock_Allocation__c,ERP7__Project__c,ERP7__Address__c,ERP7__Minimum_Lot_Size__c,ERP7__Maximum_Lot_Size__c from ERP7__Routing__c where ERP7__Product__c =:mainPro.Id Limit 1];
                    
                    Id RTRouting; RTRouting = Schema.SObjectType.ERP7__Routing__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_Routing').getRecordTypeId();

                    List<ERP7__Routing__c> rtngList=new List<ERP7__Routing__c>();
                    ERP7__Routing__c newRtng=new ERP7__Routing__c();
                    if(Schema.sObjectType.ERP7__Routing__c.fields.Name.isCreateable()){newRtng.Name='ePos Routing'; } else{ /*no access*/ }
                    if(Schema.sObjectType.ERP7__Routing__c.fields.RecordTypeId.isCreateable()){newRtng.RecordTypeId=RTRouting; } else { /*no access*/ }
                    if(rtngForClone.ERP7__Channel__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Channel__c.isCreateable()) {newRtng.ERP7__Channel__c=rtngForClone.ERP7__Channel__c; } else { /* no access*/}
                    if(rtngForClone.ERP7__Product__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Product__c.isCreateable()) {newRtng.ERP7__Product__c=rtngForClone.ERP7__Product__c;} else { /* no access*/}
                    if(rtngForClone.ERP7__Status__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Status__c.isCreateable()){ newRtng.ERP7__Status__c=rtngForClone.ERP7__Status__c;} else { /* no access*/}
                    if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__BOM_Version__c.isCreateable()){newRtng.ERP7__BOM_Version__c=version.Id;} else { /* no access*/}
                    if(rtngForClone.ERP7__Process__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Process__c.isCreateable()) {newRtng.ERP7__Process__c=rtngForClone.ERP7__Process__c; } else{ /* no access*/}
                    if(rtngForClone.ERP7__Raw_Materials_Site__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Raw_Materials_Site__c.isCreateable()) {newRtng.ERP7__Raw_Materials_Site__c=rtngForClone.ERP7__Raw_Materials_Site__c; } else{ /* no access*/ }
                    if(rtngForClone.ERP7__Finished_Products_Site__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Finished_Products_Site__c.isCreateable()){ newRtng.ERP7__Finished_Products_Site__c=rtngForClone.ERP7__Finished_Products_Site__c;} else{ /* no access*/ }
                    if(rtngForClone.ERP7__Work_Center__c != null&& Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Work_Center__c.isCreateable()) {newRtng.ERP7__Work_Center__c=rtngForClone.ERP7__Work_Center__c;} else{ /* no access*/ }
                    if(rtngForClone.ERP7__Auto_Stock_Allocation__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Auto_Stock_Allocation__c.isCreateable()) {newRtng.ERP7__Auto_Stock_Allocation__c=rtngForClone.ERP7__Auto_Stock_Allocation__c;} else{ /* no access*/ }
                    if(rtngForClone.ERP7__Address__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Address__c.isCreateable()) {newRtng.ERP7__Address__c=rtngForClone.ERP7__Address__c;} else{ /* no access*/ }
                    if(rtngForClone.ERP7__Minimum_Lot_Size__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Minimum_Lot_Size__c.isCreateable() ) {newRtng.ERP7__Minimum_Lot_Size__c=rtngForClone.ERP7__Minimum_Lot_Size__c;} else{ /* no access*/ }
                    if(rtngForClone.ERP7__Maximum_Lot_Size__c != null && Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Maximum_Lot_Size__c.isCreateable() ) {newRtng.ERP7__Maximum_Lot_Size__c=rtngForClone.ERP7__Maximum_Lot_Size__c;} else{ /* no access*/ }
                    rtngList.add(newRtng);
                    
                    //DML Operation
                    if(rtngList.size() > 0 && Schema.sObjectType.ERP7__Routing__c.isCreateable()){insert rtngList;}else{/*not allowed to insert*/}
                    
                    //==========creating Operation==============
                    ERP7__Routing__c rtng1=[Select Id,Name from ERP7__Routing__c where ERP7__BOM_Version__c =:version.Id Limit 1];
                    String rtng1Id=rtngForClone.Id;
                    String pFields = UtilClass.selectStarFromSObject('ERP7__Operation__c');
                    utilClass.FLSCheck(pFields.split(','),'ERP7__Operation__c');  
                    String  query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Operation__c Where ERP7__Routing__c =: rtng1Id ';
                    List< ERP7__Operation__c > Operations = Database.query(query1);
                    
                    List<ERP7__Operation__c> Operations2Upsert = new List<ERP7__Operation__c>();
                    for(ERP7__Operation__c Operation : Operations){
                        ERP7__Operation__c Oprn = Operation.clone(false, false, false, false);
                        Oprn.ERP7__Routing__c = rtng1.Id;
                        Operations2Upsert.add(Oprn);
                    }
                    //DML Operation
                    if(Operations2Upsert.size() > 0 && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isUpdateable() && Schema.SObjectType.ERP7__Operation__c.isCreateable() && Schema.SObjectType.ERP7__Operation__c.isUpdateable()) upsert Operations2Upsert;
                    //==========/creating Operation==============
                    
                }            
                //=========create Routing=============
                
                return version.Id;
            }
        }catch(Exception ex){        }
        return null;
    }
    
    
    
    public class Stock{
        @AuraEnabled public String ProId                { get ; set ; }
        @AuraEnabled public Decimal stockAvlb           { get ; set ; }
        public Stock(){
            ProId='';
            stockAvlb=0;
        }
    }
    
    public class FeatureWrapper{
        @AuraEnabled public ERP7__Product_Feature__c feature                { get ; set ; }
        @AuraEnabled public List<ERP7__Product_Option__c> featOpt           { get ; set ; }
        @AuraEnabled public List<ERP7__Product_Option__c> othersPro         { get ; set ; }
        @AuraEnabled public List<PricebookEntry> pbe                        { get ; set ; }
        @AuraEnabled public Decimal quantity                                { get ; set ; }
        public FeatureWrapper(){
            feature = new ERP7__Product_Feature__c();
            featOpt = new List<ERP7__Product_Option__c>();
            othersPro = new List<ERP7__Product_Option__c>();
            pbe=new List<PricebookEntry>();
            quantity=1;
        }
    }
    
    public class OptionProd{
        @AuraEnabled public List<FeatureWrapper> featrWrapper               { get ; set ; }
        @AuraEnabled public List<ERP7__Rule__c> optionRules                 { get ; set ; }
        @AuraEnabled public Product2 product                                { get ; set ; }
        @AuraEnabled public List<Stock> totalStock                          { get ; set ; } 
        @AuraEnabled public String errorMsg                                 { get ; set ; }  
                
        public OptionProd(){
            featrWrapper=new List<FeatureWrapper>();
            optionRules = new List<ERP7__Rule__c>();
            product = new Product2();
            totalStock=new List<Stock>();
            errorMsg='';
        }
    }
    //========================Product Configuration end=====================
    
    
  @AuraEnabled
public static Boolean isInvoicePosted(Id invoiceId){
    System.debug('isInvoicePosted called with invoiceId: ' + invoiceId);

    if(invoiceId == null){
        System.debug('InvoiceId is null. Returning TRUE (bypass validation).');
        return true;
    }

    ERP7__Invoice__c inv = [
        SELECT Id, ERP7__Posted__c, RecordType.DeveloperName
        FROM ERP7__Invoice__c 
        WHERE Id = :invoiceId 
        LIMIT 1
    ];

    System.debug('Fetched Invoice: ' + inv);
    System.debug('RecordType: ' + inv.RecordType.DeveloperName);
    System.debug('Posted Status: ' + inv.ERP7__Posted__c);

    if(inv.RecordType.DeveloperName == 'Sale'){
        System.debug('Invoice is SALES type');

        if(inv.ERP7__Posted__c){
            System.debug('Invoice is POSTED → returning TRUE');
        } else {
            System.debug('Invoice is NOT POSTED → returning FALSE');
        }

        return inv.ERP7__Posted__c;
    } else {
        System.debug('Invoice is NOT Sales type → bypassing check, returning TRUE');
        return true;
    }
}
 
}