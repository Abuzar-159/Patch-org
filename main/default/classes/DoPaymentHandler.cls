global With Sharing Class DoPaymentHandler{
    global string amount                      {get; set;}
    global string firstname                   {get; set;}
    global string lastname                    {get; set;}
    global string email                       {get; set;}
    global string address                     {get; set;}
    global string city                        {get; set;}
    global string state                       {get; set;}
    global string country                     {get; set;}
    global string zip                         {get; set;}
    global string cardholder                  {get; set;}
    global string cardnumber                  {get; set;}
    global string cardyear                    {get; set;} 
    global string cardmonth                   {get; set;}
    global string cardcvv                     {get; set;}
    global string expiration                  {get; set;}
    global string selectedCardType            {get; set;}      
    global boolean isSuccess                  {get; set;}
    global Payment__c payment                 {get; set;}
    global Contact currentCon                 {get; set;}
    global Sales_Order__c currentSalesorder   {get; set;}    
    global Id paymentId                       {get; set;}
    global String CustID                      {get; set;}
    global String order                       {get; set;}
    global String comAppend                   {get; set;} 
    global Decimal actualAmount               {get; set;} global String errorMsg                    {get; set;}
    global List<Payment_Method__c> currMethod {get; set;}
    
    global DoPaymentHandler() {
        try{ } catch(Exception e) {}
    }
    global DoPaymentHandler(ApexPages.StandardController controller){
    try{
         comAppend = Community_Util.communityValue();
        if(comAppend == null || comAppend == '') { comAppend = '/apex'; } else { comAppend = '/' + comAppend + '/apex';
        }
        if(ApexPages.currentPage().getParameters().get('id') != null)  paymentId =  EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('id'),'UTF-8');
        String currmethodId;
        if( ApexPages.currentPage().getParameters().get('pm') != null)
        currmethodId =  EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('pm'),'UTF-8');
        
        if(currmethodId != Null && currmethodId != ''){
            if(Schema.sObjectType.Payment_Method__c.isAccessible())
                currMethod = [Select Id, Name, Account__c, Address__c, Reference_Number__c, Bank_Branch_Name__c, Bank_Name__c, Card_Expiration_Month__c, Card_Expiration_Year__c,
                                                        Card_Number__c, Card_Type__c, Contact__c, Loyalty_Card__c, Name_on_Card__c, Sort_Code__c, Swift_BIC_Code__c,
                                                        RecordType.Name, RecordTypeId, CardType__c
                                                        From Payment_Method__c
                                                        Where Id = :currmethodId Limit 1];
                if(currMethod.size() > 0){
                    if(Schema.sobjectType.Payment_Method__c.fields.Card_Number__c.isAccessible())cardnumber = currMethod[0].Card_Number__c;
                    if(Schema.sobjectType.Payment_Method__c.fields.CardType__c.isAccessible())selectedCardType = currMethod[0].CardType__c;
                    if(Schema.sobjectType.Payment_Method__c.fields.Card_Expiration_Month__c.isAccessible())cardmonth = currMethod[0].Card_Expiration_Month__c;
                    if(Schema.sobjectType.Payment_Method__c.fields.Card_Expiration_Year__c.isAccessible())cardyear = currMethod[0].Card_Expiration_Year__c;
                    if(Schema.sobjectType.Payment_Method__c.fields.Name_on_Card__c.isAccessible())cardholder = currMethod[0].Name_on_Card__c;
                }
           } 
            if( System.currentPageReference().getParameters().get('con') != null)
                 CustID = EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('con'),'UTF-8'); 
                 
            if(System.currentPageReference().getParameters().get('so') != null) 
                  order =  EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('so'),'UTF-8'); 
           
             if(Schema.sObjectType.Payment__c.isAccessible())       
            payment = (paymentId == null) ? new Payment__c() : [Select Id, Name, Address_Line1__c, Address_Line2__c, Amount__c, AVS_Code__c, CardType__c, 
                                                                   City__c, Correlation_ID__c, Country__c, CVV2_Code__c, Email_Address__c, Error_Message__c,
                                                                   Error_Code__c, First_Name__c, Last_Name__c, Payment_Status__c, sError__c, State__c,
                                                                   Transaction_ID__c, Transaction_Status__c, Zipcode__c, Payment_Gateway__c, Account__c, Sales_Order__c, 
                                                                   Organisation_Business_Unit__c, Payment_Method__c, Bank__c, Reference_Cheque_No__c, RecordTypeId
                                                                   From Payment__c
                                                                   Where id =: paymentId Limit 1];
           if(paymentId == null){
                if(Schema.sObjectType.Contact.isAccessible())           
                  currentCon = [Select id, Name, FirstName, LastName, Email, Phone, AccountId, Contact_Numer__c From Contact Where Contact_Numer__c =: CustID Limit 1]; 
               
               if(Schema.sObjectType.Sales_Order__c.isAccessible())
                  currentSalesorder = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c,
                                          Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, 
                                          Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                                          Bill_To_Address__r.Address_Line1__c, Bill_To_Address__r.Address_Line2__c, Bill_To_Address__r.Address_Line3__c, Bill_To_Address__r.City__c,
                                          Bill_To_Address__r.County__c, Bill_To_Address__r.Country__c, Bill_To_Address__r.Postal_Code__c, Organisation__c,Organisation_Business_Unit__c
                                          , Amount_Paid__c
                                          From Sales_Order__c Where
                                          Name =: order Limit 1];                                          
               if(Schema.sobjectType.Contact.fields.FirstName.isAccessible())payment.First_Name__c = currentCon.FirstName;
               if(Schema.sobjectType.Contact.fields.LastName.isAccessible())payment.Last_Name__c = currentCon.LastName;
               if(Schema.sobjectType.Contact.fields.Email.isAccessible())payment.Email_Address__c = currentCon.Email;
               if(Schema.sobjectType.Sales_Order__c.fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.fields.Amount_Paid__c.isAccessible())payment.Amount__c = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Sales_Order_Amount__c.isAccessible() && Schema.sobjectType.Sales_Order__c.fields.Amount_Paid__c.isAccessible())actualAmount = currentSalesorder.Sales_Order_Amount__c - currentSalesorder.Amount_Paid__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Address_Line1__c.isAccessible())payment.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Address_Line2__c.isAccessible())payment.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.City__c.isAccessible())payment.City__c = currentSalesorder.Bill_To_Address__r.City__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.County__c.isAccessible())payment.State__c = currentSalesorder.Bill_To_Address__r.County__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Country__c.isAccessible())payment.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Bill_To_Address__c.isAccessible() && Schema.sobjectType.ERP7__Address__c.fields.Postal_Code__c.isAccessible())payment.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c;  
               if(Schema.sobjectType.Sales_Order__c.fields.Organisation__c.isAccessible())payment.Account__c = currentSalesorder.Organisation__c;
               if(Schema.sobjectType.Sales_Order__c.fields.Organisation_Business_Unit__c.isAccessible())payment.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
               if(Schema.sobjectType.Sales_Order__c.isAccessible())payment.Sales_Order__c = currentSalesorder.Id;
           }
            if(Schema.sobjectType.Contact.fields.FirstName.isAccessible() && Schema.sobjectType.Contact.fields.LastName.isAccessible()) cardholder = currentCon.FirstName+' '+currentCon.LastName;   
            if(Schema.sobjectType.Payment__c.fields.Amount__c.isAccessible()) amount = String.Valueof(payment.Amount__c);
            if(Schema.sobjectType.Payment__c.fields.First_Name__c.isAccessible()) firstname = payment.First_Name__c;
            if(Schema.sobjectType.Payment__c.fields.Last_Name__c.isAccessible()) lastname = payment.Last_Name__c;
            if(Schema.sobjectType.Payment__c.fields.Email_Address__c.isAccessible()) email = payment.Email_Address__c;
            if(Schema.sobjectType.Payment__c.fields.Address_Line1__c.isAccessible() && Schema.sobjectType.Payment__c.fields.Address_Line2__c.isAccessible()) address = payment.Address_Line1__c +', '+payment.Address_Line2__c;
            if(Schema.sobjectType.Payment__c.fields.City__c.isAccessible()) city = payment.City__c;
            if(Schema.sobjectType.Payment__c.fields.State__c.isAccessible()) state = payment.State__c;
            if(Schema.sobjectType.Payment__c.fields.Country__c.isAccessible()) country = payment.Country__c;
            if(Schema.sobjectType.Payment__c.fields.Zipcode__c.isAccessible()) zip = payment.Zipcode__c;     } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'DoPaymentHandler Line Number @ : '+ e.getLineNumber())); }
    }
    
    
    global List<SelectOption> getMonths(){
    try{
       list<SelectOption> months = new list<SelectOption>();
       months.add(new selectOption('01','Jan'));
       months.add(new selectOption('02','Feb'));
       months.add(new selectOption('03','Mar'));
       months.add(new selectOption('04','Apr'));
       months.add(new selectOption('05','May'));
       months.add(new selectOption('06','Jun'));
       months.add(new selectOption('07','Jul'));
       months.add(new selectOption('08','Aug'));
       months.add(new selectOption('09','Sep'));
       months.add(new selectOption('10','Oct'));
       months.add(new selectOption('11','Nov'));
       months.add(new selectOption('12','Dec'));
       return months; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'getMonths Line Number @ : '+ e.getLineNumber())); }
       return null;
    }
    
    global List<SelectOption> getYears(){
    try{
       list<SelectOption> years = new list<SelectOption>();
       integer curMonth = system.today().year();
       for(integer i=1;i<10;i++){
           years.add(new selectOption(curMonth + '',curMonth++ + ''));
       }
       return years; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'getYears Line Number @ : '+ e.getLineNumber())); }
        return null;
    
    }
    
    global List<SelectOption> getCardTypes(){
    try{
       list<SelectOption> cardtype = new list<SelectOption>();
       cardtype.add(new selectOption('Visa','Visa'));
       cardtype.add(new selectOption('MasterCard','MasterCard'));
       cardtype.add(new selectOption('American Express','American Express'));
       cardtype.add(new selectOption('Discover','Discover'));
       return cardtype; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'getCardTypes Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    //Handling payment processing submitting by VF page button
    global void process(){
    try{
            isSuccess = false;
            expiration = cardmonth + cardyear;
            if(Schema.sobjectType.Payment__c.fields.Amount__c.isAccessible())amount = String.Valueof(payment.Amount__c);
            if(currMethod != null && currMethod.size() > 0){
                if(Schema.sobjectType.Payment_Method__c.fields.Card_Number__c.isAccessible())cardnumber = currMethod[0].Card_Number__c;
            }
            if(!validate()){isSuccess = false;return;
            }
            String paymentGatewayId;
            if(ApexPages.currentPage().getParameters().get('sg') != null)
            paymentGatewayId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('sg'),'UTF-8');
            AuthorizeDotNet ath = new AuthorizeDotNet(true,paymentGatewayId);
            ath.transaction(cardnumber, expiration, amount, cardcvv,'','');  
            ath.setParameter('x_device_type','1');  
            ath.setParameter('x_first_name',firstname);  
            ath.setParameter('x_last_name',lastname);  
            ath.setParameter('x_address',address);  
            ath.setParameter('x_state',state);  
            ath.setParameter('x_email',email); 
            ath.setParameter('x_city',city); 
            ath.setParameter('x_country',country);
            ath.setParameter('x_response_format','2');  //1
            ath.setParameter('x_zip',zip);
            
            try{ ath.process(3);
            }catch(Exception ex){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));  isSuccess = false;
                if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Failure';
                if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = 'Failure';
            }
            
            if(ath.isApproved()){
                String responsetext = ath.getResponseText(); String transactionid = ath.getTransactionID();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, responsetext + '\nTransaction Id: ' + transactionid ));   isSuccess = true;
                if(Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Transaction_ID__c.isUpdateable()) { payment.Transaction_ID__c = transactionid; }
                if(Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) { payment.Transaction_Status__c = 'Approved'; }
                if(Schema.sObjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sObjectType.Payment__c.fields.sError__c.isUpdateable()) { payment.sError__c = responsetext ; }                  
                if(Schema.sObjectType.Payment__c.fields.Status__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Status__c.isUpdateable()) { payment.Status__c = 'Paid'; }                  
            }
            else if(ath.isDeclined()){
                String reason = ath.getResponseText();  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, reason));  isSuccess = false;
                if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Declined';
                if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = reason;  
            }
            else{
                String reason = ath.getResponseText();  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, reason));  isSuccess = false;
                if(Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isCreateable() && Schema.sobjectType.Payment__c.fields.Transaction_Status__c.isUpdateable()) payment.Transaction_Status__c = 'Declined';
                if(Schema.sobjectType.Payment__c.fields.sError__c.isCreateable() && Schema.sobjectType.Payment__c.fields.sError__c.isUpdateable()) payment.sError__c = reason;
            }
            if(Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isCreateable() && Schema.sObjectType.Payment__c.fields.Payment_Gateway__c.isUpdateable()) { payment.Payment_Gateway__c = 'Authorize.Net'; }
             
              try{    DMLManager.upsertAsUser(payment); }catch(DmlException e){}
             } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'process Line Number @ : '+ e.getLineNumber())); }        
    }
    
    @TestVisible
    private boolean validate(){
    try{
        boolean isvalid = true;
        if(!isValid(amount)){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Amount'));    isvalid = false;
        }
        if(!isValid(cardnumber)){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Card Number'));   isvalid = false;
        }
        if(!isValid(expiration)){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Expiration Date'));  isvalid = false;
        }
        if(!isValid(cardcvv)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: CVV Number')); 
            isvalid = false;
        }
        if(!isValid(firstname)){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: First Name'));   isvalid = false;
        }
        if(!isValid(lastname)){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Last Name')); isvalid = false;
        }
        if(!isValid(address)){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Address'));   isvalid = false;
        }
        if(!isValid(state)){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: State'));  isvalid = false;
        }
        if(!isValid(zip)){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Required Field Missing: Zip'));   isvalid = false;
        }
        
        return isvalid; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'validate Line Number @ : '+ e.getLineNumber())); }  return null;
    
    }
    
     global PageReference goBack(){
     try{
        PageReference Page = new PageReference(comAppend + '/SelectPaymentGateway'); 
        if(CustID != Null) { Page.getParameters().put('con',CustID); }
        if(order != Null) { Page.getParameters().put('so',order); }  
        Page.getParameters().put('frm',getFormTag()); 
        Page.getParameters().put('txt',getTextBox());  
        Page.setRedirect(true);
        return Page; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'goBack Line Number @ : '+ e.getLineNumber())); }  return null;
    }  
    
    private boolean isValid(string val){
    try{
        return val == null ? false : val.trim().length() == 0 ? false: true; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
    }
    
    global string getFormTag() {
        try{
			return (System.currentPageReference().getParameters().get('frm') != null)? String.escapeSingleQuotes(EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('frm'),'UTF-8')):null; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'getFormTag Line Number @ : '+ e.getLineNumber())); }  return null;
    }
    global string getTextBox() {
    try{
        if(System.currentPageReference().getParameters().get('txt') != null) return String.escapeSingleQuotes(EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('txt'),'UTF-8')); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'getTextBox Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    global string getidlp() {
    try{
          if(System.currentPageReference().getParameters().get('idlp') != null) return String.escapeSingleQuotes(EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('idlp'),'UTF-8')); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'getidlp Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    global string getcnn() {
    try{
           if(System.currentPageReference().getParameters().get('cnn') != null) return String.escapeSingleQuotes(EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('cnn'),'UTF-8')); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'getcnn Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    global PageReference Back2Order() {
    try{
        PageReference page = new PageReference('/'+currentSalesOrder.Id);
        return page;  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Back2Order Line Number @ : '+ e.getLineNumber())); } return null;
    }
}