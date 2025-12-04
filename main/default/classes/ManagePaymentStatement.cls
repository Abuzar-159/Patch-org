public with sharing class ManagePaymentStatement {
    public Id contactId                                       {get; set;}
    public Contact currentCon                                 {get; set;}
    public List<Sales_Order__c> currentSalesorders            {get; set;}
    public String errorMsg                                    {get; set;}
    public String description                                 {get; set;}
    public Id paymentMethodId                                 {get; set;}
    public String paymentType                                 {get; set;}
    public List<orderWrapper> orderWrapperList                {get; set;}
    public Boolean selAll                                     {get; set;}
    public Payment_Statements__c paymentStatement             {get; set;} 
    public List<Payment_Method__c> payMethods                 {get; set;} 
    public List<paymentMethodWrapper> paymentMethodWrapperList{get; set;} 
    public Payment__c tempPayment                             {get; set;}
    
    public class orderWrapper{
        public Sales_Order__c currentSalesorder               {get; set;}
        public Boolean sel                                    {get; set;}
        public Payment__c payment                             {get; set;}
        public orderWrapper(Sales_Order__c s, Contact currentCon){
            currentSalesorder = s; 
            sel = false;
            payment = new Payment__c();
            if(Schema.sObjectType.Sales_Order__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Sales_Order__c.isCreateable()) payment.Sales_Order__c = currentSalesorder.Id;
            if(Schema.sobjectType.Sales_Order__c.fields.Account__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Account__c.isCreateable()) payment.Account__c = currentSalesorder.Account__c;
            if(Schema.sobjectType.Contact.fields.FirstName.isAccessible() && Schema.sObjectType.Payment__c.fields.First_Name__c.isCreateable()) if(currentCon.FirstName != Null) payment.First_Name__c = currentCon.FirstName;
            if(Schema.sobjectType.Contact.fields.LastName.isAccessible() && Schema.sObjectType.Payment__c.fields.Last_Name__c.isCreateable()) payment.Last_Name__c = currentCon.LastName;
            if(currentCon.Email != Null) if(Schema.sobjectType.Contact.fields.Email.isAccessible() && Schema.sObjectType.Payment__c.fields.Email_Address__c.isCreateable()) payment.Email_Address__c = currentCon.Email;
            if(Schema.sobjectType.Sales_Order__c.fields.Due_Amount__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Amount__c.isCreateable()) payment.Amount__c = currentSalesorder.Due_Amount__c;
            if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Address_Line1__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Address_Line1__c.isCreateable()) payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
            if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Address_Line2__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Address_Line2__c.isCreateable()) payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
            if(currentSalesorder.Bill_To_Address__r.City__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.City__c.isAccessible() && Schema.sObjectType.Payment__c.fields.City__c.isCreateable()) payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
            if(currentSalesorder.Bill_To_Address__r.County__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.County__c.isAccessible() && Schema.sObjectType.Payment__c.fields.State__c.isCreateable()) payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
            if(currentSalesorder.Bill_To_Address__r.Country__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Country__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Country__c.isCreateable()) payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
            if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Postal_Code__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Zipcode__c.isCreateable()) payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
            if(currentSalesorder.Organisation__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Organisation__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Account__c.isCreateable()) payment.Account__c = currentSalesorder.Organisation__c;
            if(currentSalesorder.Organisation_Business_Unit__c != Null) if(Schema.sobjectType.Sales_Order__c.fields.Organisation_Business_Unit__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Organisation_Business_Unit__c.isCreateable()) payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
        }
    }
    
    public class paymentMethodWrapper{
        public Payment_Method__c paymentmethod        {get; set;}
        public Boolean sel                            {get; set;}
        
        public paymentMethodWrapper(Payment_Method__c pm, Contact currentCon){
            paymentmethod = pm; 
            sel = false;
        }
    }
    
    public ManagePaymentStatement(ApexPages.StandardController controller) {
    try{
        customFlexibleConstructor();
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    }
    
    public Void customFlexibleConstructor(){
    try{
        if(ApexPages.currentPage().getParameters().get('id') != null)
        contactId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('id'),'UTF-8');
        currentSalesorders = new List<Sales_Order__c>();
        errorMsg = '';
        paymentType = '';
        totalAmount = 0;
        description = '';
        orderWrapperList = new List<orderWrapper>();
        paymentMethodWrapperList = new List<paymentMethodWrapper>();
        tempPayment = new Payment__c();
        if(Schema.sObjectType.Contact.isAccessible())
        currentCon = [Select id, Name, FirstName, LastName, Email, Phone, AccountId, Account.Name, Contact_Numer__c From Contact Where Id =: contactId Limit 1]; /* Where Contact_Numer__c =: CustID Limit 1 */
        if(Schema.sObjectType.Sales_Order__c.isAccessible())
        currentSalesorders = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Contact__c, Hold_Status__c, Order_Date__c, Order_Status__c,
                                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, 
                                      Sub_Total__c, Total_Discount__c, Total_Due__c, Due_Amount__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                      Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c,
                                      Bill_To_Address__r.County__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c, Organisation_Business_Unit__c
                                      , Amount_Paid__c
                                      From Sales_Order__c Where
                                      Contact__c =: contactId And 
                                      Due_Amount__c > 0]; 
        
        for(Sales_Order__c SO : currentSalesorders){
           orderWrapper orderWrap = new orderWrapper(SO,currentCon);
           orderWrapperList.add(orderWrap);
        }  
        if(Schema.sObjectType.Payment_Method__c.isAccessible())
        payMethods = [Select Id, Name, Account__c, Address__c, Reference_Number__c, Bank_Branch_Name__c, Bank_Name__c, Card_Expiration_Month__c, Card_Expiration_Year__c,
                        Card_Number__c, Card_Type__c, Contact__c, Loyalty_Card__c, Name_on_Card__c, Sort_Code__c, Swift_BIC_Code__c,
                        RecordType.Name, RecordTypeId, CardType__c
                    From Payment_Method__c
                        Where Contact__c = :currentCon.Id And
                        RecordType.Name = 'Bank Payment Method']; 
        
        for(Payment_Method__c PM : payMethods){
           paymentMethodWrapper pmWrap = new paymentMethodWrapper(PM,currentCon);
           paymentMethodWrapperList.add(pmWrap);
        } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }  
    }
    
    public PageReference selectAllOrders(){
    try{
        if(selAll == true){
           for(orderWrapper OW : orderWrapperList){
               OW.sel = true;
           } 
        }
        else{
            for(orderWrapper OW : orderWrapperList){
               OW.sel = false;
            } 
        }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    } 
    
    public PageReference selectPaymentMethod(){
        try{
        for(paymentMethodWrapper PMW : paymentMethodWrapperList){
           if(PMW.paymentMethod.Id != paymentMethodId){
               PMW.sel = false;
           }
           else if(PMW.sel){
               if(Schema.sobjectType.ERP7__Payment_Method__c.fields.Bank_Name__c.isAccessible()) tempPayment.Bank__c = PMW.paymentMethod.Bank_Name__c;                    
                if(Schema.sObjectType.Payment_Method__c.isAccessible()) tempPayment.Payment_Method__c = PMW.paymentMethod.Id;
           }
           else{
               tempPayment = new Payment__c();
           }
        } 
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    } 
    
    public Decimal totalAmount{
        get { 
            totalAmount = 0 ; 
            for(orderWrapper OW : orderWrapperList){
                if(OW.sel == true) if(Schema.sobjectType.ERP7__Sales_Order__c.fields.Due_Amount__c.isAccessible()) totalAmount += OW.currentSalesorder.Due_Amount__c;
            } 
            return totalAmount;
        }
        set { 
            totalAmount = value; 
        }
    }
    
    public string TotalDueStr{
        get { if(totalAmount != null) return String.valueof(totalAmount); else return ''; }
        set { TotalDueStr = value; }
        
    }
       
    public PageReference Pay(){
    try{
        paymentStatement = new Payment_Statements__c();
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Payment_Statements__c.fields.Contact__c.isCreateable()){ paymentStatement.Contact__c = currentCon.Id; }else{/*No access*/}
        if(Schema.sObjectType.Payment_Statements__c.fields.Description__c.isAccessible() && Schema.sObjectType.Payment_Statements__c.fields.Description__c.isCreateable()){ paymentStatement.Description__c = Description; }else{/*No access*/}
        if(Schema.sObjectType.Payment_Statements__c.fields.Payment_Amount__c.isAccessible() && Schema.sObjectType.Payment_Statements__c.fields.Payment_Amount__c.isCreateable()){ paymentStatement.Payment_Amount__c = totalAmount; }else{/*No access*/}
        if(Schema.sObjectType.Payment_Statements__c.fields.Payment_Date__c.isAccessible() && Schema.sObjectType.Payment_Statements__c.fields.Payment_Date__c.isCreateable()){ paymentStatement.Payment_Date__c = system.Today();}else{/*No access*/}
        if(Schema.sObjectType.Payment_Statements__c.isCreateable()){DMLManager.insertAsUser(paymentStatement);}else{/*No access*/}
        List<Payment__c> payments = new List<Payment__c>();
        if(paymentType == 'Cash'){
           String rTypeP = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Cash_Payments'); 
            for(orderWrapper OW : orderWrapperList){
                if(OW.sel == true) { 
                    if(Schema.sObjectType.Payment_Statements__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Payment_Statements__c.isCreateable()){ OW.payment.Payment_Statements__c = paymentStatement.Id; }else{/*No access*/}
                    if(String.isNotEmpty(rTypeP) && Schema.sObjectType.Payment__c.fields.RecordTypeId.isCreateable()){ OW.payment.RecordTypeId = rTypeP; }else{/*No access*/}
                    if(Schema.sObjectType.Payment__c.fields.Status__c.isAccessible() && Schema.sObjectType.Payment__c.fields.Status__c.isCreateable()){ OW.payment.Status__c = 'Paid'; }else{/*No access*/}
                    payments.add(OW.payment);
                }
            } 
            if(Schema.SObjectType.Payment__c.isCreateable()){DMLManager.insertAsUser(payments);}else{/*No access*/}
        }
        else if(paymentType == 'Bank'){
            String rTypeB = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Bank_Payments'); 
            for(orderWrapper OW : orderWrapperList){
                if(OW.sel == true) { 
                    if(Schema.sObjectType.Payment_Statements__c.isAccessible() && Schema.SObjectType.Payment__c.fields.Payment_Statements__c.isCreateable()){ OW.payment.Payment_Statements__c = paymentStatement.Id;}else{/*No access*/}
                    if(String.isNotEmpty(rTypeB) && Schema.SObjectType.Payment__c.fields.RecordTypeId.isCreateable()){ OW.payment.RecordTypeId = rTypeB;}else{/*No access*/}
                    if(Schema.sObjectType.Payment__c.fields.Status__c.isAccessible() && Schema.SObjectType.Payment__c.fields.Status__c.isCreateable()){ OW.payment.Status__c = 'Paid'; }else{/*No access*/}
                    if(Schema.sobjectType.ERP7__Payment__c.fields.Bank__c.isAccessible() && Schema.SObjectType.Payment__c.fields.Bank__c.isCreateable()){ OW.payment.Bank__c = tempPayment.Bank__c;  }else{/*No access*/}                  
                    if(Schema.sObjectType.Payment_Method__c.isAccessible() && Schema.SObjectType.Payment__c.fields.Payment_Method__c.isCreateable()){ OW.payment.Payment_Method__c = tempPayment.Payment_Method__c; }else{/*No access*/}
                    if(Schema.sobjectType.ERP7__Payment__c.fields.Reference_Cheque_No__c.isAccessible() && Schema.SObjectType.Payment__c.fields.Reference_Cheque_No__c.isCreateable()){ OW.payment.Reference_Cheque_No__c = tempPayment.Reference_Cheque_No__c;}else{/*No access*/}
                    payments.add(OW.payment);
                }
            } 
            if(Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isUpdateable()){DMLManager.upsertAsUser(payments);}else{/*No access*/}
        }
        customFlexibleConstructor();
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    } 
    
    public PageReference close(){
    try{
        PageReference Page = new PageReference('/'+currentCon.Id);
        Page.setRedirect(true);
        return Page;
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    return null;
    } 
}