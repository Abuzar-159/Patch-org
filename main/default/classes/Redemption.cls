public with sharing class Redemption {
    public String redeemProcess                        { get; set; }
    public String Id                                   { get; set; }
    public Invoice__c Invoice                          { get; set; }
    public Sales_Order__c SO                           { get; set; }
    public Account Customer                            { get; set; }
    public Contact Contact                             { get; set; }
    public List<Loyalty_Card__c> clubCard              { get; set; }
    public Decimal Points_Per_Unit_Amount              { get; set; }
    public Decimal redeemPoints                        { get; set; }
    public Decimal redeemCredit                        { get; set; }
    public String couponCode                           { get; set; }
    public String errMsg                               { get; set; }
    public List< ERP7__Credit_Note__c > creditNotes    { get; set; }
    public List<ERP7__Coupon_Redemption__c> Redemptions{ get; set; }
    
    public String errormsg                             { get; set; }
    public Boolean hasAccess                           { get; set; }
    
    public Redemption(){
        redeemProcess = ApexPages.CurrentPage().getParameters().get('rp');
        Id = ApexPages.CurrentPage().getParameters().get('id'); 
        errMsg = '';
        RedemptionCon();
    }
    
    public void RedemptionCon(){
        String CON, CUST = '';
        Date todayDate = system.Today();
        creditNotes = new List< ERP7__Credit_Note__c >();
        String son = '';
        String SalesOrderFields = UtilClass.selectStarFromSObject('Sales_Order__c');
        String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c,Contact__r.FirstName,Contact__r.LastName,Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c, Bill_To_Address__r.County__c, Bill_To_Address__r.State__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c ';
        String paymentFields = UtilClass.selectStarFromSObject('ERP7__Payment__c');
        String AllPaymentFields = paymentFields + ',RecordType.Name,ERP7__Sales_Order__r.Name,ERP7__Payment_Method__r.Name '; 
        String creditNoteFields = UtilClass.selectStarFromSObject('ERP7__Credit_Note__c');
        String AllcreditNoteFields = creditNoteFields + ',ERP7__Sales_Order__r.Name, ERP7__Coupon_Redemption__r.Name, ERP7__Coupon_Redemption__r.ERP7__Coupon__c, ERP7__Coupon_Redemption__r.ERP7__Coupon__r.Name '; 
        String shipmentFields = UtilClass.selectStarFromSObject('ERP7__Shipment__c');
        String AllshipmentFields = shipmentFields + ',RecordType.Name,ERP7__Sales_Order__r.Name ';
        String RedemptionFields = UtilClass.selectStarFromSObject('ERP7__Coupon_Redemption__c');
        String AllRedemptionFields = RedemptionFields + ' '; 
       
        if(redeemProcess == 'INV'){
             if(Id != Null && Id != '') {
                Invoice = [Select Id, Name, Organisation__c, Organisation_Business_Unit__c, Order__c From ERP7__Invoice__c Where Id =: Id Limit 1];
                if(Schema.sObjectType.Sales_Order__c.isAccessible()) {
                    String InvoiceOrder = Invoice.Order__c;
                    SO = Database.query('SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + 'FROM ERP7__Sales_Order__c where Id =: InvoiceOrder Limit 1'); //verify escape sequence
                    son = SO.Id;
                    CON = SO.Contact__c;
                    CUST = SO.Account__c;
                }
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c,Vat__r.Total_Tax__c, Vat__r.Tax_Rate__c, ERP7__Available_Credit_Balance__c FROM Account WHERE id = :CUST Limit 1');
                }
                if(String.isNOTEmpty(CON) &&  Schema.sObjectType.Contact.isAccessible() ) {
                    //Contact = Database.query('SELECT '+String.escapeSingleQuotes(ContactFields)+' FROM Contact WHERE Id = :CON Limit 1');
                    Contact = [SELECT Id, Name, Title, Email, FirstName, LastName, Phone, ERP7__Contact_Numer__c FROM Contact WHERE Id = : CON Limit 1];
                }
                if(Schema.sObjectType.ERP7__Credit_Note__c.isAccessible() ) {
                    CreditNotes = Database.query('SELECT '+String.escapeSingleQuotes(creditNoteFields)+ ', ERP7__Coupon_Redemption__r.ERP7__Coupon__c, ERP7__Coupon_Redemption__r.ERP7__Coupon__r.Name FROM ERP7__Credit_Note__c where (ERP7__Sales_Order__r.Name =:son or ERP7__Sales_Order__c =:son) and ERP7__Coupon_Redemption__c != null order by CreatedDate Asc');
                }
                if(Schema.sObjectType.ERP7__Coupon_Redemption__c.isAccessible() ) {
                    Redemptions = Database.query('SELECT '+String.escapeSingleQuotes(RedemptionFields)+ ' FROM ERP7__Coupon_Redemption__c where (ERP7__Sales_Order__r.Name =:son or ERP7__Sales_Order__c =:son) order by CreatedDate Asc');
                }
                
                if(Schema.sObjectType.Loyalty_Card__c.isAccessible()) {
                    clubCard = [Select id, Name, Active__c, Active_Points__c, Loyalty_Program__c, ERP7__Points_Per_Unit_Amount__c, Contact__c, Customer__c, Start_date__c,
                                        Expiration_Date__c, Status__c, Total_Points_Credited__c, Total_Points_Debited__c,
                                        Organisation__c, Organisation_Business_Unit__c
                                        From Loyalty_Card__c Where
                                        Customer__c = : Customer.Id And
                                        Customer__c != Null And
                                        Active__c = true And
                                        Status__c = 'Active'
                                        And
                                        Start_date__c <= : todayDate And
                                        Expiration_Date__c >= : todayDate
                                        Limit 1];
                    if(clubCard.size() > 0){
                        Points_Per_Unit_Amount = (clubCard[0].ERP7__Points_Per_Unit_Amount__c > 0)? (clubCard[0].Active_Points__c/clubCard[0].ERP7__Points_Per_Unit_Amount__c).setScale(2) : 0;
                    }
                }
                
                redeemPoints = Null;
                redeemCredit = Null;
                couponCode = '';
            }  
        } 
        
        if(redeemProcess == 'ACC'){
             if(Id != Null && Id != '') {
                if(Schema.sObjectType.Account.isAccessible()) {
                    Customer = Database.query('SELECT Id, Name, ERP7__total_points__c, ERP7__VAT_registration_number__c, ERP7__Company__c, Fax, Phone, AccountNumber, Website,  ERP7__Account_Profile__c, ERP7__VAT__c,Vat__r.Total_Tax__c, Vat__r.Tax_Rate__c, ERP7__Available_Credit_Balance__c FROM Account WHERE id = :Id Limit 1');
                }
                
                redeemPoints = Null;
                redeemCredit = Null;
                couponCode = '';
            }  
        } 
    }
     
    public PageReference ProcessLoyalty(){
        if(Customer.total_points__c > 0 && SO.Due_Amount__c > 0 && redeemPoints > 0 && redeemPoints <= Customer.total_points__c){
            errMsg = '';
            try {
                List < Loyalty_Setup__c > Loyaltysetup;    
                if(Schema.sObjectType.Loyalty_Setup__c.isAccessible()){    
                    Loyaltysetup = [Select Id, Name, Points_Per_Unit_Amount__c, Organisation__c, Organisation_Business_Unit__c
                    From Loyalty_Setup__c
                    Where Organisation_Business_Unit__c = : SO.Organisation_Business_Unit__c And
                    Organisation__c = : SO.Organisation__c
                    order by CreatedDate Asc Limit 1];
                }
                Decimal finalDue = SO.Due_Amount__c;
                Decimal loyaltyAmount = SO.ERP7__Loyalty_Amount__c;
                Decimal loyalty_Points = SO.ERP7__Loyalty_Points__c;
                Decimal loyaltyPoints = redeemPoints;
                if (Loyaltysetup.size() > 0) {
                    Decimal pointsPerUnit = Loyaltysetup[0].Points_Per_Unit_Amount__c;
                    Decimal curCreditlimit = redeemPoints;
                    Decimal curAmount = (pointsPerUnit == 0) ? 0 : curCreditlimit / pointsPerUnit;
                    if (curAmount <= finalDue && finalDue > 0 && curAmount > 0) {
                        if (loyaltyAmount != null && loyalty_Points != null) {
                            finalDue = finalDue - curAmount;
                            loyaltyAmount = (curAmount + loyaltyAmount).setScale(2);
                            loyalty_Points = curCreditlimit + loyalty_Points;
                        } else { 
                            finalDue = finalDue - curAmount;
                            loyaltyAmount = curAmount;
                            loyalty_Points = curCreditlimit;
                        } 
                    } else if (curAmount > finalDue && finalDue > 0 && curAmount > 0) {
                        loyaltyAmount = ((loyaltyAmount != null) ? loyaltyAmount : 0) + finalDue;
                        finalDue = 0; 
                        loyalty_Points = (pointsPerUnit * (finalDue - ((SO.Amount_Paid__c != Null) ? SO.Amount_Paid__c : 0))).setScale(2);
                    }
                }
                ERP7__Sales_Order__c salesOrderDraft = SO;
                   Loyalty_Points__c debitReward = new Loyalty_Points__c();
                       if(Schema.sObjectType.Loyalty_Points__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Name.isUpdateable()) debitReward.Name = SO.Name;
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Loyalty_Card__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Loyalty_Card__c.isUpdateable()) debitReward.Loyalty_Card__c = clubCard[0].id;
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Credit_Debit_Date__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Credit_Debit_Date__c.isUpdateable()) debitReward.Credit_Debit_Date__c = System.today();
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Order__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Order__c.isUpdateable()) debitReward.Order__c = SO.id;
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Points__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Points__c.isUpdateable()) debitReward.Points__c = redeemPoints;
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Transaction_Status__c.isUpdateable()) debitReward.Transaction_Status__c ='Debit';
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Valid_Date__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Valid_Date__c.isUpdateable()) debitReward.Valid_Date__c = System.Today() + 30;
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Organisation__c.isUpdateable()) debitReward.Organisation__c = SO.Organisation__c;
                       if(Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.fields.Organisation_Business_Unit__c.isUpdateable()) debitReward.Organisation_Business_Unit__c = SO.Organisation_Business_Unit__c;
                if(Schema.sObjectType.ERP7__Loyalty_Points__c.isCreateable() && Schema.sObjectType.ERP7__Loyalty_Points__c.isUpdateable()){ DMLManager.upsertAsUser(debitReward);} else{ errMsg = 'User is not allowed to upsert'; }
                    
                    Decimal pointsPerUnit = Loyaltysetup[0].Points_Per_Unit_Amount__c;
                    Decimal curAmount = (pointsPerUnit == 0) ? 0 : (debitReward.Points__c / pointsPerUnit).setScale(2);
                    
                    ERP7__Credit_Note__c newCN = new ERP7__Credit_Note__c();
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.Name.isCreateable()) newCN.Name = SO.Name;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Active__c.isCreateable()) newCN.ERP7__Active__c = true;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Sales_Order__c.isCreateable()) newCN.ERP7__Sales_Order__c = salesOrderDraft.Id;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Amount__c.isCreateable()) newCN.ERP7__Amount__c = curAmount;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Applied_Date__c.isCreateable()) newCN.ERP7__Applied_Date__c = system.Today();
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isCreateable()) newCN.ERP7__Account__c = Customer.Id;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Contact__c.isCreateable()) newCN.ERP7__Contact__c = contact.Id;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Loyalty_Points__c.isCreateable()) newCN.ERP7__Loyalty_Points__c = debitReward.Id;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Paid__c.isCreateable()) newCN.ERP7__Paid__c = true;
                        if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Organisation__c.isCreateable()) newCN.ERP7__Organisation__c = salesOrderDraft.ERP7__Organisation__c;
                    if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable()){ insert newCN;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                    ERP7__Sales_Order__c currentSalesorder = salesOrderDraft;
                    ERP7__Payment__c Payment = new ERP7__Payment__c(); 
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isUpdateable()) payment.Sales_Order__c = currentSalesorder.Id;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()) payment.Account__c = currentSalesorder.Account__c;
                    if(currentSalesorder.Contact__r.FirstName != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable()) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
                    if(currentSalesorder.Contact__r.LastName != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isUpdateable()) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
                    if(currentSalesorder.Contact__r.Email != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isUpdateable()) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
                    if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable()) payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                    if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable()) payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                    if(currentSalesorder.Bill_To_Address__r.City__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable()) payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                    if(currentSalesorder.Bill_To_Address__r.State__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable()) payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                    if(currentSalesorder.Bill_To_Address__r.Country__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable()) payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                    if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable()) payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable()) payment.Account__c = currentSalesorder.Organisation__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isUpdateable()) payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isUpdateable()) payment.ERP7__Credit_Note__c = newCN.Id;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payment.ERP7__Type__c = 'Debit';
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) Payment.ERP7__Payment_Type__c = 'Loyalty';
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payment.ERP7__Amount__c = newCN.ERP7__Amount__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payment.ERP7__Status__c = 'Paid';
                    String rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                    if(String.isNotEmpty(rTypeP)){
                        if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable()) payment.RecordTypeId = rTypeP; 
                    }
                    //DMLManager.upsertAsUser(payment); 
                    List<ERP7__Payment__c> pays = new List<ERP7__Payment__c>();
                    pays.add(payment);
                    ERP7__Payment__c Payment1 = new ERP7__Payment__c(); 
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isUpdateable()) Payment1.Sales_Order__c = currentSalesorder.Id;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable()) Payment1.Account__c = currentSalesorder.Account__c;
                    if(currentSalesorder.Contact__r.FirstName != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable()) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                    if(currentSalesorder.Contact__r.LastName != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isUpdateable()) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                    if(currentSalesorder.Contact__r.Email != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isUpdateable()) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                    if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable()) Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                    if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable()) Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                    if(currentSalesorder.Bill_To_Address__r.City__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable()) Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                    if(currentSalesorder.Bill_To_Address__r.State__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable()) Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                    if(currentSalesorder.Bill_To_Address__r.Country__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable()) Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                    if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) if(Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable()) Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable()) Payment1.Account__c = currentSalesorder.Organisation__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isUpdateable()) Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isUpdateable()) Payment1.ERP7__Credit_Note__c = newCN.Id;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) Payment1.ERP7__Type__c = 'Credit';
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) Payment1.ERP7__Payment_Type__c = 'Loyalty';
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) Payment1.ERP7__Status__c = 'Paid';
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payment1.ERP7__Amount__c = newCN.ERP7__Amount__c;
                    String rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                    if(String.isNotEmpty(rTypeP1)){
                        if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable()) Payment1.RecordTypeId = rTypeP1; 
                    }
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) Payment1.ERP7__Posted__c = true;
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable()) Payment1.ERP7__Posted_Date__c = system.Today();
                    pays.add(payment1);
                    if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ DMLManager.upsertAsUser(pays); }else{ errMsg = 'User Not allowed to update';} 
                   
                    if(Schema.sObjectType.Sales_Order__c.fields.ERP7__Amount_Paid__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Amount_Paid__c.isUpdateable()) salesOrderDraft.ERP7__Amount_Paid__c = (salesOrderDraft.ERP7__Amount_Paid__c == null) ? 0 : salesOrderDraft.ERP7__Amount_Paid__c + newCN.ERP7__Amount__c;
                    if(Schema.sObjectType.Sales_Order__c.fields.Loyalty_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Loyalty_Amount__c.isUpdateable()) salesOrderDraft.Loyalty_Amount__c = (LoyaltyAmount == null) ? 0 : LoyaltyAmount;
                    if(Schema.sObjectType.Sales_Order__c.fields.Loyalty_Points__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Loyalty_Points__c.isUpdateable()) salesOrderDraft.Loyalty_Points__c = (loyaltyPoints == null) ? 0 : loyaltyPoints;
                    if(salesOrderDraft.Order_Status__c == Null) if(Schema.sObjectType.Sales_Order__c.fields.Order_Status__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Order_Status__c.isUpdateable()) salesOrderDraft.Order_Status__c = 'Entered';
                    if(Schema.sObjectType.Sales_Order__c.isCreateable() && Schema.sObjectType.Sales_Order__c.isUpdateable()){ DMLManager.upsertAsUser(salesOrderDraft);} else{ errMsg = 'not allowed to update';}
                    RedemptionCon();
             } catch(Exception e) { errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
            
             
        } else {
             errMsg = 'Invalid Details';   
        }
        return Null;
    }
    
    public PageReference ApplyCredits(){
        if(Customer.Available_Credit_Balance__c > 0 && SO.Due_Amount__c > 0 && redeemCredit > 0 && redeemCredit <= Customer.Available_Credit_Balance__c && redeemCredit <= SO.Due_Amount__c){
            errMsg = '';
            try {
                Decimal FinalDue = SO.Due_Amount__c;
                Decimal CreditAmount = Customer.Available_Credit_Balance__c;
                Decimal CreditAmount2Use = redeemCredit;
                Sales_Order__c currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.FirstName, Contact__r.LastName,
                                                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Contact__r.Email,
                                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c,
                                                      Bill_To_Address__r.County__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c, Amount_Paid__c
                                                      From Sales_Order__c 
                                                      Where Id =: SO.Id Limit 1]; 
                
                List<ERP7__Payment__c> Payments = new List<ERP7__Payment__c>();
                Decimal creditBalance = CreditAmount2Use;
                
                List<ERP7__Credit_Note__c> creditNotes = [SELECT Id, Name, ERP7__Amount__c , ERP7__Credit__c , ERP7__Debit__c, ERP7__Balance__c FROM ERP7__Credit_Note__c where ERP7__Account__c =:Customer.Id and ERP7__Balance__c > 0 order by CreatedDate Asc];
                List< ERP7__PrePayment__c > prePayments = [SELECT Id, Name, ERP7__Amount__c , ERP7__Credit__c , ERP7__Debit__c, ERP7__Balance__c FROM ERP7__PrePayment__c where ERP7__Account__c =:Customer.Id and ERP7__Balance__c > 0 order by CreatedDate Asc];
                
                for(ERP7__Credit_Note__c CN : creditNotes){
                    if(creditBalance > 0){
                        ERP7__Payment__c Payment1 = new ERP7__Payment__c();
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isUpdateable()) Payment1.Sales_Order__c = currentSalesorder.Id;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable()) Payment1.Account__c = currentSalesorder.Account__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable()) if(currentSalesorder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isUpdateable()) if(currentSalesorder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isUpdateable()) if(currentSalesorder.Contact__r.Email != Null) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable()) Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable()) Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable()) Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable()) Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable()) Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable()) Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable()) Payment1.Account__c = currentSalesorder.Organisation__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isUpdateable()) Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) Payment1.ERP7__Type__c = 'Debit';
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) Payment1.ERP7__Payment_Type__c = 'Credit';
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable()) Payment1.ERP7__Invoice__c = Invoice.Id;
                            String rTypeP1;
                            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                            if(String.isNotEmpty(rTypeP1)){
                               if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable()) Payment1.RecordTypeId = rTypeP1; 
                            }
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Status__c.isUpdateable()) Payment1.Status__c = 'Paid'; 
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) Payment1.ERP7__Posted__c = true;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable()) Payment1.ERP7__Posted_Date__c = system.Today();
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isUpdateable()) Payment1.ERP7__Credit_Note__c = CN.Id;
                            if(CN.ERP7__Balance__c >= creditBalance) {
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isUpdateable()) Payment1.Amount__c = creditBalance;
                                creditBalance = 0;
                            } else {
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isUpdateable()) Payment1.Amount__c = CN.ERP7__Balance__c;
                                creditBalance = creditBalance - CN.ERP7__Balance__c;
                            }
                        Payments.add(Payment1);
                        
                    } else break;
                }
                
                for(ERP7__PrePayment__c CN : prePayments){
                    if(creditBalance > 0){
                        ERP7__Payment__c Payment1 = new ERP7__Payment__c();
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isUpdateable()) Payment1.Sales_Order__c = currentSalesorder.Id;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable()) Payment1.Account__c = currentSalesorder.Account__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable())  if(currentSalesorder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isUpdateable())  if(currentSalesorder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isUpdateable()) if(currentSalesorder.Contact__r.Email != Null) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable()) Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable()) Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable()) Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable()) Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable()) Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable()) Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Account__c.isUpdateable()) Payment1.Account__c = currentSalesorder.Organisation__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isUpdateable()) Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) Payment1.ERP7__Type__c = 'Debit';
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) Payment1.ERP7__Payment_Type__c = 'Credit';
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Invoice__c.isUpdateable()) Payment1.ERP7__Invoice__c = Invoice.Id;
                            String rTypeP1;
                            if(Schema.sobjectType.RecordType.isAccessible()) rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                            if(String.isNotEmpty(rTypeP1)){
                                if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable()) Payment1.RecordTypeId = rTypeP1; 
                            }
                            if(Schema.sObjectType.ERP7__Payment__c.fields.Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Status__c.isUpdateable()) Payment1.Status__c = 'Paid'; 
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()) Payment1.ERP7__Posted__c = true;
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable()) Payment1.ERP7__Posted_Date__c = system.Today();
                            if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__PrePayment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__PrePayment__c.isUpdateable()) Payment1.ERP7__PrePayment__c = CN.Id;
                            if(CN.ERP7__Balance__c >= creditBalance) {
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isUpdateable()) Payment1.Amount__c = creditBalance;
                                creditBalance = 0;
                            } else {
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Amount__c.isUpdateable()) Payment1.Amount__c = CN.ERP7__Balance__c;
                                creditBalance = creditBalance - CN.ERP7__Balance__c;
                            }
                        Payments.add(Payment1);
                    } else break;
                }
                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ DMLManager.upsertAsUser(Payments); } else{ errMsg = 'Not allowed to update';} 
                RedemptionCon();
            } catch(Exception e) { errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        } else {
             errMsg = 'Invalid Details';   
        }
        return Null;
    }
    
    public PageReference RedeemCoupon(){
         try {
            errMsg = '';
            ERP7__Sales_Order__c SalesOrder2Create = SO;
            List<ERP7__Sales_Order_Line_Item__c> SOLIs = [Select Id, Name, ERP7__Product__c, ERP7__Quantity__c, ERP7__Sales_Order__c, ERP7__Price_Product__c, ERP7__Base_Price__c, ERP7__Coupon__c, ERP7__Total_Price__c From ERP7__Sales_Order_Line_Item__c Where ERP7__Sales_Order__c =: SalesOrder2Create.Id];
            List<ERP7__Sales_Order_Line_Item__c> SOLIs2upsert = new List<ERP7__Sales_Order_Line_Item__c>();
            Map<Id, ERP7__Sales_Order_Line_Item__c> proSoli = new Map<Id, ERP7__Sales_Order_Line_Item__c>(); 
            for(ERP7__Sales_Order_Line_Item__c soli : SOLIs){
                proSoli.put(soli.ERP7__Product__c,soli);
            }
            if(couponCode != Null && couponCode != ''){
                List<ERP7__Coupon_Issued__c> CI = [Select Id, Name, ERP7__Product__c, ERP7__Account__c, ERP7__Coupon__c, ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c, ERP7__Coupon__r.Name, ERP7__Coupon__r.ERP7__Start_Date__c, ERP7__Coupon__r.ERP7__End_Date__c, ERP7__Issued_Date__c, ERP7__Value__c, ERP7__Voucher_Amount__c, ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c, ERP7__Coupon__r.RecordType.Name, ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c
                                                    From ERP7__Coupon_Issued__c 
                                                    Where ERP7__Coupon__r.Name =:couponCode And 
                                                    ERP7__Coupon__r.ERP7__Start_Date__c <= Today And 
                                                    ERP7__Coupon__r.ERP7__End_Date__c >= Today And 
                                                    (ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c = Null Or ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c <= :SO.ERP7__Sales_Order_Amount__c) 
                                                    Limit 1];
                if(CI.size() > 0){
                    List< ERP7__Coupon_Redemption__c > CR = [Select Id, Name, ERP7__Account__c, ERP7__Coupon__c From ERP7__Coupon_Redemption__c Where ERP7__Account__c =:Customer.Id And ERP7__Coupon__c =: CI[0].ERP7__Coupon__c Limit 1];
                    if(SO.ERP7__Due_Amount__c <= 0){
                        errMsg = 'Invalid Sales Order Amount';
                    }
                    else if(CR.size() > 0){
                        errMsg = 'Coupon Already Redeemed';
                    } else{
                        ERP7__Coupon_Redemption__c newCR = new ERP7__Coupon_Redemption__c();
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.Name.isCreateable()) newCR.Name = (proSoli.containsKey(CI[0].ERP7__Product__c))? proSoli.get(CI[0].ERP7__Product__c).Name : SalesOrder2Create.Name;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Account__c.isCreateable()) newCR.ERP7__Account__c = Customer.Id;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon__c.isCreateable()) newCR.ERP7__Coupon__c = CI[0].ERP7__Coupon__c;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon_Issued__c.isCreateable()) newCR.ERP7__Coupon_Issued__c = CI[0].Id;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Redemption_Date__c.isCreateable()) newCR.ERP7__Redemption_Date__c = system.Today();
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isCreateable()) newCR.ERP7__Sales_Order__c = SalesOrder2Create.Id;
                        if(CI[0].ERP7__Voucher_Amount__c > 0) { 
                            if(proSoli.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){
                                if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable())  newCR.ERP7__Sales_Order_Line_Item__c = proSoli.get(CI[0].ERP7__Product__c).Id;
                                if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable()) {
                                if(CI[0].ERP7__Voucher_Amount__c <= proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                                else newCR.ERP7__Value__c = proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c;
                                }
                            }
                            else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Order'){
                                if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable()){
                                if(CI[0].ERP7__Voucher_Amount__c <= SalesOrder2Create.ERP7__Sales_Order_Amount__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                                else newCR.ERP7__Value__c = SalesOrder2Create.ERP7__Sales_Order_Amount__c;
                                }
                            }
                            else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Shipping'){
                                if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable()){
                                if(CI[0].ERP7__Voucher_Amount__c <= SalesOrder2Create.ERP7__Total_Shipping_Amount__c) newCR.ERP7__Value__c =  CI[0].ERP7__Voucher_Amount__c;
                                else newCR.ERP7__Value__c = SalesOrder2Create.ERP7__Total_Shipping_Amount__c;
                                }
                            }
                        }
                        else if(CI[0].ERP7__Value__c > 0){ 
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable()){
                                if(proSoli.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){
                                    newCR.ERP7__Value__c =  (proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c == 0)? 0 : (CI[0].ERP7__Value__c * proSoli.get(CI[0].ERP7__Product__c).ERP7__Base_Price__c)/100;
                                    newCR.ERP7__Sales_Order_Line_Item__c = proSoli.get(CI[0].ERP7__Product__c).Id;
                                }
                                else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Order') newCR.ERP7__Value__c =  (SalesOrder2Create.ERP7__Sales_Order_Amount__c == 0)? 0 : (CI[0].ERP7__Value__c * SalesOrder2Create.ERP7__Sales_Order_Amount__c)/100;
                                else if(CI[0].ERP7__Coupon__r.RecordType.Name == 'Shipping') newCR.ERP7__Value__c =  (SalesOrder2Create.ERP7__Total_Shipping_Amount__c == Null || SalesOrder2Create.ERP7__Total_Shipping_Amount__c == 0)? 0 : (CI[0].ERP7__Value__c * SalesOrder2Create.ERP7__Total_Shipping_Amount__c)/100;
                            }
                        }
                        if(newCR.ERP7__Value__c > 0){
                            if(newCR.ERP7__Value__c > SalesOrder2Create.ERP7__Due_Amount__c && Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable()) newCR.ERP7__Value__c = SalesOrder2Create.ERP7__Due_Amount__c;
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.isCreateable()){ insert newCR;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                            
                            if(CI[0].ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c){
                                //New Logic
                                if(proSoli.containsKey(CI[0].ERP7__Product__c) && CI[0].ERP7__Coupon__r.RecordType.Name == 'Product'){
                                    proSoli.get(CI[0].ERP7__Product__c).ERP7__Coupon__c = newCR.ERP7__Value__c;
                                    if(proSoli.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c != Null) 
                                        proSoli.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c = proSoli.get(CI[0].ERP7__Product__c).ERP7__Total_Price__c - newCR.ERP7__Value__c;
                                    SOLIs2upsert.add(proSoli.get(CI[0].ERP7__Product__c));
                                }
                                else{
                                    if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Coupon_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Coupon_Discount__c.isUpdateable()) SalesOrder2Create.ERP7__Coupon_Discount__c = newCR.ERP7__Value__c;
                                }
                                if(SOLIs2upsert.size() > 0 && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Coupon__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Coupon__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isUpdateable()) { upsert SOLIs2upsert; } else{errormsg='You are not allowed to update'; } 
                                if(Schema.sObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()){hasAccess=true; upsert SalesOrder2Create;} else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                                RedemptionCon();
                            }
                            else{
                                ERP7__Credit_Note__c newCN = new ERP7__Credit_Note__c();
                                    if(Schema.sObjectType.ERP7__Credit_Note__c.fields.Name.isCreateable()) newCN.Name = newCR.Name;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Active__c.isCreateable()) newCN.ERP7__Active__c = true;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Sales_Order__c.isCreateable()) newCN.ERP7__Sales_Order__c = SalesOrder2Create.Id;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Amount__c.isCreateable()) newCN.ERP7__Amount__c = newCR.ERP7__Value__c;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Credit__c.isCreateable()) newCN.ERP7__Credit__c = newCR.ERP7__Value__c;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Applied_Date__c.isCreateable()) newCN.ERP7__Applied_Date__c = system.Today();
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isCreateable()) newCN.ERP7__Account__c = Customer.Id;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Contact__c.isCreateable()) newCN.ERP7__Contact__c = contact.Id;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Coupon_Redemption__c.isCreateable()) newCN.ERP7__Coupon_Redemption__c = newCR.Id;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Paid__c.isCreateable()) newCN.ERP7__Paid__c = true;
                                     if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Organisation__c.isCreateable()) newCN.ERP7__Organisation__c = SalesOrder2Create.ERP7__Organisation__c;
                                if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable()){ insert newCN;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                                
                                ERP7__Sales_Order__c currentSalesorder = SalesOrder2Create;
                                ERP7__Payment__c Payment = new ERP7__Payment__c(); 
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Sales_Order__c.isUpdateable()) payment.Sales_Order__c = currentSalesorder.Id;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()) payment.Account__c = currentSalesorder.Account__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.First_Name__c.isUpdateable()) if(currentSalesorder.Contact__r.FirstName != Null) payment.First_Name__c = currentSalesorder.Contact__r.FirstName;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Last_Name__c.isUpdateable()) if(currentSalesorder.Contact__r.LastName != Null) payment.Last_Name__c = currentSalesorder.Contact__r.LastName;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Email_Address__c.isUpdateable()) if(currentSalesorder.Contact__r.Email != Null) payment.Email_Address__c = currentSalesorder.Contact__r.Email;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line1__c.isUpdateable()) if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Address_Line2__c.isUpdateable()) if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.City__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.City__c.isUpdateable()) if(currentSalesorder.Bill_To_Address__r.City__c != Null) payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.State__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.State__c.isUpdateable()) if(currentSalesorder.Bill_To_Address__r.State__c != Null) payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Country__c.isUpdateable()) if(currentSalesorder.Bill_To_Address__r.Country__c != Null) payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Zipcode__c.isUpdateable()) if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Account__c.isUpdateable()) payment.Account__c = currentSalesorder.Organisation__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.Organisation_Business_Unit__c.isUpdateable()) payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Credit_Note__c.isUpdateable()) payment.ERP7__Credit_Note__c = newCN.Id;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Type__c.isUpdateable()) payment.ERP7__Type__c = 'Debit';
                                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) Payment.ERP7__Payment_Type__c = 'Coupon';
                                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Amount__c.isUpdateable()) payment.ERP7__Amount__c = newCN.ERP7__Amount__c;
                                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()) payment.ERP7__Status__c = 'Paid';
                                String rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                                if(String.isNotEmpty(rTypeP)){
                                    if(Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.RecordTypeId.isUpdateable()) payment.RecordTypeId = rTypeP; 
                                }
                                //DMLManager.upsertAsUser(payment); 
                                List<ERP7__Payment__c> pays = new List<ERP7__Payment__c>();
                                pays.add(payment);
                                
                                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ DMLManager.upsertAsUser(pays);} else{errMsg = 'Invalid Access';}
                            RedemptionCon();
                         }   
                    }
                }
            } else {
                errMsg = 'Invalid Coupon';
            }
            } else {
                 errMsg = 'Invalid Coupon';
            }
        } catch(Exception e) { errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return Null;
    }
    
    public PageReference RedeemAccountCoupon(){
         try {
            errMsg = '';
            if(couponCode != Null && couponCode != ''){
                List<ERP7__Coupon_Issued__c> CI = [Select Id, Name, ERP7__Product__c, ERP7__Account__c, ERP7__Coupon__c, ERP7__Coupon__r.ERP7__Account__c, ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c, ERP7__Coupon__r.Name, ERP7__Coupon__r.ERP7__Start_Date__c, ERP7__Coupon__r.ERP7__End_Date__c, ERP7__Issued_Date__c, ERP7__Value__c, ERP7__Voucher_Amount__c, ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c, ERP7__Coupon__r.RecordType.Name, ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c
                                                    From ERP7__Coupon_Issued__c 
                                                    Where ERP7__Coupon__r.Name =:couponCode And 
                                                    ERP7__Coupon__r.ERP7__Start_Date__c <= Today And 
                                                    ERP7__Coupon__r.ERP7__End_Date__c >= Today And 
                                                    ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c = false And
                                                    ERP7__Coupon__r.ERP7__Account__c =: Customer.Id
                                                    Limit 1];
                if(CI.size() > 0){
                    List< ERP7__Coupon_Redemption__c > CR = [Select Id, Name, ERP7__Account__c, ERP7__Coupon__c From ERP7__Coupon_Redemption__c Where ERP7__Account__c =:Customer.Id And ERP7__Coupon__c =: CI[0].ERP7__Coupon__c Limit 1];
                    if(CR.size() > 0){
                        errMsg = 'Coupon Already Redeemed';
                    } else{
                        ERP7__Coupon_Redemption__c newCR = new ERP7__Coupon_Redemption__c();
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.Name.isCreateable()) newCR.Name = CI[0].ERP7__Coupon__r.Name;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Account__c.isCreateable()) newCR.ERP7__Account__c = Customer.Id;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon__c.isCreateable()) newCR.ERP7__Coupon__c = CI[0].ERP7__Coupon__c;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Coupon_Issued__c.isCreateable()) newCR.ERP7__Coupon_Issued__c = CI[0].Id;
                        if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Redemption_Date__c.isCreateable()) newCR.ERP7__Redemption_Date__c = system.Today();
                        
                        if(CI[0].ERP7__Voucher_Amount__c > 0) { 
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Value__c.isCreateable()) newCR.ERP7__Value__c = CI[0].ERP7__Voucher_Amount__c;
                        }
                        if(newCR.ERP7__Value__c > 0){
                            if(Schema.sObjectType.ERP7__Coupon_Redemption__c.isCreateable()){ insert newCR;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                            
                            ERP7__Credit_Note__c newCN = new ERP7__Credit_Note__c();
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.Name.isCreateable()) newCN.Name = newCR.Name;
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Active__c.isCreateable()) newCN.ERP7__Active__c = true;
                                //newCN.ERP7__Sales_Order__c = SalesOrder2Create.Id;
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Amount__c.isCreateable()) newCN.ERP7__Amount__c = newCR.ERP7__Value__c;
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Applied_Date__c.isCreateable()) newCN.ERP7__Applied_Date__c = system.Today();
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Account__c.isCreateable()) newCN.ERP7__Account__c = Customer.Id;
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Credit__c.isCreateable()) newCN.ERP7__Credit__c = newCR.ERP7__Value__c;
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Coupon_Redemption__c.isCreateable()) newCN.ERP7__Coupon_Redemption__c = newCR.Id;
                                if(Schema.sObjectType.ERP7__Credit_Note__c.fields.ERP7__Paid__c.isCreateable()) newCN.ERP7__Paid__c = true;
                                //newCN.ERP7__Organisation__c = SalesOrder2Create.ERP7__Organisation__c;
                            if(Schema.sObjectType.ERP7__Credit_Note__c.isCreateable()){insert newCN;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
                        RedemptionCon();
                    }
                }
            } else {
                errMsg = 'Invalid Coupon';
            }
            } else {
                 errMsg = 'Invalid Coupon';
            }
        } catch(Exception e) { errMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return Null;
    }
}