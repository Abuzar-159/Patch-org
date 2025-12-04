global with sharing Class ProcessReturn { 

    public Id Item2DeleteId                            { get; set; } 
    public Boolean orderDisplay                        { get; set; } 
    public Boolean itemDisplay                         { get; set; } 
    public Integer itemQuantity                        { get; set; }    
    public Sales_Order__c currentSalesOrder            { get; set; }   
    public Sales_Order_Line_Item__c newCurrentItems    { get; set; }     
    public List<Sales_Order_Line_Item__c> currentItems { get; set; }  
    public Inventory_Stock__c sel                      { get; set; } 
    public Map<Id, Coupon__c> mapDis                   { get; set; }
    public List<Coupon__c> discounts                   { get; set; }
    public String discountName                         { get; set; }
    public String salesOrderName                       { get; set; }
    public List<itemWrapper> itemWrapperList           { get; set; }     
    public String customerId                           { get; set; }
    public Contact Contact                             { get; set; }
    public String returnMethod                         { get; set; }    
    public List<SelectOption> returnMethods            { get; set; }
    public List<Loyalty_Card__c> clubCard              { get; set; }
    public Map<Id, Warranty__c> lineWarranty           { get; set; }
    public Return_Merchandise_Authorisation__c RMA     { get; set; }
    public Payment__c payment                          { get; set; }
    
    global class itemWrapper {
        global String code                             { get; set; }   
        global String itm                              { get; set; }                             
        global String orderLineItemId                  { get; set; }                    
        global Integer quantity                        { get; set; } 
        global Decimal quantity_s                      { get; set; } 
        global Decimal baseprice                       { get; set; } 
        global Decimal discount                        { get; set; }
        global Decimal vat                             { get; set; }        
        global Decimal totalPrice                      { get; set; }
        global Decimal totalDeduction                  { get; set; }
        global Integer quantityReturn                  { get; set; }
        global Decimal quantity_Return                 { get; set; } 
        global Integer currentQuantity                 { get; set; } 
        global Decimal current_Quantity                { get; set; } 
        global String returnReason                     { get; set; }
        global Decimal rewardPoints                    { get; set; }
        global RMA_Line_Item__c  rmaLI                 { get; set; }
        global Warranty__c warranty                    { get; set; }
        global Boolean isWarrantyExist                 { get; set; }
        
        /*
          Inner Constructor For Wrapper Class 
        */        
        global itemWrapper(){
            code = '';
            itm = ''; 
            orderLineItemId = ''; 
            returnReason = '';  
            quantityReturn = 0;
            quantity_Return = 0; 
            totalDeduction = 0; 
            current_Quantity = 0;
            currentQuantity = 0;
            rmaLI = new RMA_Line_Item__c();
            warranty = new Warranty__c();
            isWarrantyExist = false;
        }
    }  
    
    global pageReference processItemQuantity() {
        try {  
            for(itemWrapper w :itemWrapperList){
                if(w.orderLineItemId == Item2DeleteId){
                    if(w.quantity_Return <= w.quantity_s) {
                        w.current_Quantity = w.quantity_s - w.quantity_Return;
                        w.totalDeduction = (w.totalPrice / w.quantity_s) * w.quantity_Return;} else { w.quantity_Return = 0;w.current_Quantity = 0;w.totalDeduction = 0; }           
                } 
            }
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } 
        return null;
    }
    
    global processReturn() {}
    global processReturn(ApexPages.StandardController controller){  
        try {
            if(ApexPages.currentPage().getParameters().get('oid') != null)
            salesOrderName = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('oid'),'UTF-8'); 
            if(ApexPages.currentPage().getParameters().get('con') != null) customerId = EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('con'),'UTF-8');
            newCurrentItems = new Sales_Order_Line_Item__c();      
            customCon();} catch(Exception e) { 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); 
            } 
    }    
    public void customCon() {
        try {
            if(Schema.sObjectType.Contact.isAccessible())
            Contact = [Select id, Name, FirstName, LastName ,Email, AccountId, Phone, Contact_Numer__c From Contact Limit 1]; 
            if(salesOrderName != null) currentSalesOrder = getCurrentOrder(salesOrderName);
            if(currentSalesOrder != null) newCurrentItems.Sales_Order__c = currentSalesOrder.Id;
            Date cardDate = system.today();
            lineWarranty = new Map<Id, Warranty__c>();
            if(currentSalesOrder != null && Schema.sObjectType.Loyalty_Card__c.isAccessible()){
            UtilClass.FLSCheck(new string[]{'id','Name','ERP7__Active_Points__c','ERP7__Loyalty_Program__c','ERP7__Contact__c','ERP7__Customer__c','ERP7__Start_date__c','ERP7__Expiration_Date__c','ERP7__Status__c','ERP7__Total_Points_Credited__c','ERP7__Total_Points_Debited__c','ERP7__Organisation__c'},'Loyalty_Card__c');
            clubCard = [Select id, Name, Active_Points__c, Loyalty_Program__c, Contact__c, Customer__c, Start_date__c, Expiration_Date__c,  Status__c,
                        Total_Points_Credited__c, Total_Points_Debited__c, Organisation__c From Loyalty_Card__c Where 
                        Customer__c =: Contact.AccountId And Contact__c =:  Contact.Id And Status__c = 'Active' And Start_date__c <= :cardDate And
                        Expiration_Date__c >= :cardDate And Organisation__c =: currentSalesOrder.Organisation__c Order by Active_Points__c Desc];       
            }                       
            returnMethods = new List<SelectOption>();
            returnMethods.add(new SelectOption('Credit Note','Credit Note'));
            if(clubCard != null && clubCard.size() > 0) { returnMethods.add(new SelectOption('Loyalty Points','Loyalty Points')); }                              
            if(currentSalesOrder != null) currentItems = getCurrentOrderItems(currentSalesOrder.Id);
            sel = new Inventory_Stock__c();
            discounts = new List<Coupon__c>(); 
            itemDisplay = false;
            orderDisplay = true;
            payment = new Payment__c();
            List<Payment__c> opayments = [Select Id, Name, ERP7__Payment_Type__c, Sales_Order__c from Payment__c Where Sales_Order__c =: currentSalesOrder.Id Order by createdDate DESC Limit 1];
            if(opayments.size() > 0 && opayments[0].ERP7__Payment_Type__c != Null) payment.ERP7__Payment_Type__c = opayments[0].ERP7__Payment_Type__c; 
            RMA = new Return_Merchandise_Authorisation__c(Name = 'RMA-'+currentSalesOrder.Name, SO__c = currentSalesOrder.id, Organisation__c = currentSalesOrder.Organisation__c);
            } catch(Exception e) { 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); 
            } 
    }
    
    global string getFormTag() { if(System.currentPageReference().getParameters().get('frm') != null) return String.escapeSingleQuotes(EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('txt'),'UTF-8')); return null;}
    global string getTextBox() {if(System.currentPageReference().getParameters().get('txt') != null) return String.escapeSingleQuotes(EncodingUtil.urlEncode(System.currentPageReference().getParameters().get('txt'),'UTF-8'));return null;}
    
    global Sales_Order__c getCurrentOrder(String Ord) {
        Sales_Order__c order;
        try {            
            if(Schema.sObjectType.Sales_Order__c.isAccessible()){
            UtilClass.FLSCheck(new String []{'Id','Name','ERP7__Amount__c','ERP7__Bill_To_Address__c','ERP7__Book_Date__c','ERP7__Account__c','ERP7__Hold_Status__c','ERP7__Order_Date__c','ERP7__Order_Status__c','ERP7__Payment_Mode__c','ERP7__Purchase_Order_Number__c','ERP7__Request_Date__c','ERP7__Channel__c','ERP7__Ship_To_Address__c','ERP7__Special_Instructions__c','ERP7__Sub_Total__c','ERP7__Total_Discount__c','ERP7__Total_Due__c','ERP7__Total_Tax_Amount__c','ERP7__Sales_Order_Amount__c','ERP7__Loyalty_Points__c','ERP7__Loyalty_Amount__c','ERP7__ReturnAmount__c','ERP7__Organisation__c'}, 'Sales_Order__c');
            order = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Payment_Mode__c, 
                      Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, 
                      Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Sales_Order_Amount__c,
                      Loyalty_Points__c, Loyalty_Amount__c, ReturnAmount__c, Organisation__c
                      From Sales_Order__c Where Name =: Ord Limit 1];    
            } } catch(Exception e) { 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); 
            } 
        return order;
    }
    
    global List<Sales_Order_Line_Item__c> getCurrentOrderItems(Id Ord) {
        List<Sales_Order_Line_Item__c> LineItems;
        try {                
            if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible())
            LineItems = [Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c, Organisation__c,
                           Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Product__r.ProductCode,
                          Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c,
                          Sales_Order__r.Total_Tax_Amount__c, Loyalty_Points__c, Loyalty_Program__c From Sales_Order_Line_Item__c Where Sales_Order__c =: Ord];
            List<String> itemIds = new List<String>();
            for(Sales_Order_Line_Item__c LI :LineItems) { itemIds.add(LI.Id); }            
            List<Warranty__c> WS;
            if(Schema.sObjectType.Warranty__c.isAccessible())
            WS  = [Select Id, Name, Organisation__c, Product__c, Quantity__c, Sales_Order_Line_Item__c, Type__c,
                    Valid_From__c, Valid_Till__c, Warranty_Return_Policy__c From Warranty__c Where Sales_Order_Line_Item__c In: itemIds
                    And Valid_From__c <= Today And Valid_Till__c >= Today];            
            for(Warranty__c W : WS){ lineWarranty.put(W.Sales_Order_Line_Item__c, W); }
                        
            List<RMA_Line_Item__c> currentRmaItems = new List<RMA_Line_Item__c>();
            if(itemIds.size() > 0){
                if(Schema.sObjectType.RMA_Line_Item__c.isAccessible()) currentRmaItems = [Select Id, Name, Base_Price__c, Discount_Amount__c, Quantity_Available__c, Quantity_Return__c, Return_Merchandise_Authorisation__c, Return_Reason__c, SOLI__c, Total_Deduction__c, Organisation__c From RMA_Line_Item__c Where SOLI__c In : itemIds];  
            }
            
            itemWrapperList = new List<itemWrapper>();
            for(Sales_Order_Line_Item__c LI :LineItems){
                itemWrapper Wrap = new itemWrapper();
                if(Schema.SObjectType.Sales_Order_line_Item__c.Fields.Product__c.isAccessible() && Schema.SObjectType.Product2.Fields.SKU__c.isAccessible())Wrap.code = LI.Product__r.ProductCode;
                if(Schema.SObjectType.Sales_Order_line_Item__c.Fields.Product__c.isAccessible() && Schema.SObjectType.Product2.isAccessible())Wrap.itm = LI.Product__r.Name;
                if(Schema.SObjectType.Sales_Order_line_Item__c.isAccessible()) Wrap.orderLineItemId = LI.Id;
                Decimal quant = 0;
                Decimal totalDetuct = 0;
                for(RMA_Line_Item__c RLI : currentRmaItems ){if(RLI.SOLI__c == LI.Id){if(Schema.SObjectType.RMA_Line_Item__c.Fields.Quantity_Return__c.isAccessible())  quant += RLI.Quantity_Return__c;if(Schema.SObjectType.RMA_Line_Item__c.Fields.Total_Deduction__c.isAccessible()) totalDetuct = totalDetuct.setScale(2) + RLI.Total_Deduction__c;   
                    }      
                }
                if(Schema.SObjectType.Sales_Order_line_Item__c.Fields.Quantity__c.isAccessible())Wrap.quantity_s = LI.Quantity__c - quant;            
                if( Schema.SObjectType.Sales_Order_line_Item__c.Fields.Base_Price__c.isAccessible() && Schema.SObjectType.Sales_Order_line_Item__c.Fields.Quantity__c.isAccessible())Wrap.baseprice = (LI.Base_Price__c / LI.Quantity__c) * Wrap.quantity_s;
                if( Schema.SObjectType.Sales_Order_line_Item__c.Fields.Discount_Amount__c.isAccessible() && Schema.SObjectType.Sales_Order_line_Item__c.Fields.Quantity__c.isAccessible())Wrap.discount = (LI.Discount_Amount__c / LI.Quantity__c) * Wrap.quantity_s;
                if( Schema.SObjectType.Sales_Order_line_Item__c.Fields.VAT_Amount__c.isAccessible() && Schema.SObjectType.Sales_Order_line_Item__c.Fields.Quantity__c.isAccessible())Wrap.vat = (LI.VAT_Amount__c / LI.Quantity__c) * Wrap.quantity_s;
                if( Schema.SObjectType.Sales_Order_line_Item__c.Fields.Total_Price__c.isAccessible())Wrap.totalPrice = LI.Total_Price__c - totalDetuct;
                 if( Schema.SObjectType.Sales_Order_line_Item__c.Fields.Loyalty_Points__c.isAccessible() && Schema.SObjectType.Sales_Order_line_Item__c.Fields.Quantity__c.isAccessible())Wrap.rewardPoints = LI.Loyalty_Points__c / LI.Quantity__c;           
                
                if(lineWarranty.containsKey(LI.Id)) { Wrap.isWarrantyExist = true; Wrap.Warranty = lineWarranty.get(LI.Id); }
                if(Wrap.quantity_s > 0) { itemWrapperList.add(Wrap); }
            }} catch(Exception e) { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); 
            } 
        return LineItems;
    }
    
    global pageReference Save() {     
        PageReference page;
        try {        
            DMLManager.UpsertAsUser(currentSalesOrder);
                                                  
            List<RMA_Line_Item__c> RMA_LineItems = new List<RMA_Line_Item__c>();
            List<Loyalty_Points__c> RMA_Rewards = new List<Loyalty_Points__c>();
            Decimal sum2Detect = 0;
            Map<String, Schema.SObjectField> RMAFields = Schema.SObjectType.RMA_Line_Item__c.fields.getMap();
            boolean createRMA = false; 
            for(itemWrapper item : itemWrapperList) { if(item.quantity_Return > 0) { createRMA = true; break; } }
            if(createRMA) if(Schema.sObjectType.Return_Merchandise_Authorisation__c.isCreateable()) {DMLManager.insertAsUser(RMA); } else{ /* no access*/} 
            
            for(itemWrapper item : itemWrapperList){             
                if(item.quantity_Return > 0){RMA_Line_Item__c RMA_Item = new RMA_Line_Item__c(Organisation__c = currentSalesOrder.Organisation__c);RMA_Item.Name = 'RMALI-'+item.itm; RMA_Item.Quantity_Return__c = item.quantity_Return;   RMA_Item.Return_Merchandise_Authorisation__c = RMA.Id; RMA_Item.Return_Reason__c = item.returnReason; RMA_Item.SOLI__c = item.orderLineItemId;   RMA_Item.Total_Deduction__c = item.totalDeduction; RMA_Item.Return_Status__c = item.rmaLI.Return_Status__c;  RMA_LineItems.add(RMA_Item); sum2Detect += item.totalDeduction; if(clubCard.size() > 0){ Loyalty_Points__c RMA_Reward = new Loyalty_Points__c(Loyalty_Card__c = clubCard[0].id, Credit_Debit_Date__c = System.today(), Order__c = currentSalesOrder.id, Points__c = item.RewardPoints * item.quantity_Return, Transaction_Status__c = 'Debit', Valid_Date__c = System.Today()+30, Organisation__c = currentSalesOrder.Organisation__c);  RMA_Rewards.add(RMA_Reward);
                    }
                }
            }
            if(RMA_LineItems.size() > 0){ if(Schema.sObjectType.RMA_Line_Item__c.isCreateable()&& Schema.sObjectType.RMA_Line_Item__c.isUpdateable()) {DMLManager.upsertAsUser(RMA_LineItems);} else { /* no access*/} } 
            if(RMA_Rewards.size() > 0){ if(Schema.sObjectType.Loyalty_Points__c.isCreateable()&& Schema.sObjectType.Loyalty_Points__c.isUpdateable()) {DMLManager.upsertAsUser(RMA_Rewards);} else { /* no access*/} }     
            List<Invoice__c> invoice;
            if(Schema.sObjectType.Invoice__c.isAccessible())
            invoice = [Select Id, Name, Order__c From Invoice__c Where Order__c =: currentSalesOrder.id Limit 1];
            Payment__c pay, pay1;
            List<Payment__c> pays = new List<Payment__c>();
            if(returnMethod == 'Credit Note' && sum2Detect > 0) { 
                Credit_Note__c creditNote = new Credit_Note__c(Organisation__c = currentSalesOrder.Organisation__c);creditNote.Amount__c = sum2Detect;  creditNote.Contact__c = Contact.Id; creditNote.Paid_Date__c = system.today(); creditNote.Applied_Date__c = System.today(); creditNote.Account__c = currentSalesOrder.Account__c;  if(invoice.size() > 0) { creditNote.Invoice__c = invoice[0].Id; }creditNote.Return_Merchandise_Authorisation__c = RMA.Id; creditNote.Sales_Order__c = currentSalesOrder.Id; if(Schema.sObjectType.Credit_Note__c.isCreateable()){ DMLManager.insertAsUser(creditNote);} else { /* no access*/}
                pay = new Payment__c(Name = 'RMA-'+currentSalesOrder.Name, Amount__c= sum2Detect, Sales_Order__c=currentSalesOrder.Id, Status__c='Paid',Account__c=currentSalesOrder.Account__c); 
                if(Schema.SObjectType.Payment__c.fields.ERP7__Credit_Note__c.isCreateable() && Schema.SObjectType.Payment__c.fields.ERP7__Credit_Note__c.isUpdateable()) { pay.ERP7__Credit_Note__c = creditNote.Id;} else{ /* no access*/}
                   if(Schema.SObjectType.Payment__c.fields.ERP7__Type__c.isCreateable() && Schema.SObjectType.Payment__c.fields.ERP7__Type__c.isUpdateable()) { pay.ERP7__Type__c = 'Credit';} else{ /* no access*/}
                   if(Schema.SObjectType.Payment__c.fields.ERP7__Payment_Type__c.isCreateable() && Schema.SObjectType.Payment__c.fields.ERP7__Payment_Type__c.isUpdateable()) { pay.ERP7__Payment_Type__c = payment.Payment_Type__c;} else{ /* no access*/}
                    String rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                    if(String.isNotEmpty(rTypeP1)){
                        if(Schema.SObjectType.Payment__c.fields.RecordTypeId.isCreateable() && Schema.SObjectType.Payment__c.fields.RecordTypeId.isUpdateable()) {pay.RecordTypeId = rTypeP1; } else{ /* no access*/}
                    }
                pays.add(pay);
                /*ERP7__Payment__c Payment1 = new ERP7__Payment__c(); 
                //Payment1.Sales_Order__c = currentSalesorder.Id;
                Payment1.Account__c = currentSalesorder.Account__c;
                if(currentSalesorder.Contact__r.FirstName != Null) Payment1.First_Name__c = currentSalesorder.Contact__r.FirstName;
                if(currentSalesorder.Contact__r.LastName != Null) Payment1.Last_Name__c = currentSalesorder.Contact__r.LastName;
                if(currentSalesorder.Contact__r.Email != Null) Payment1.Email_Address__c = currentSalesorder.Contact__r.Email;
                if(currentSalesorder.Bill_To_Address__r.Address_Line1__c != Null) Payment1.Address_Line1__c = currentSalesorder.Bill_To_Address__r.Address_Line1__c;
                if(currentSalesorder.Bill_To_Address__r.Address_Line2__c != Null) Payment1.Address_Line2__c = currentSalesorder.Bill_To_Address__r.Address_Line2__c;
                if(currentSalesorder.Bill_To_Address__r.City__c != Null) Payment1.City__c = currentSalesorder.Bill_To_Address__r.City__c;
                if(currentSalesorder.Bill_To_Address__r.State__c != Null) Payment1.State__c = currentSalesorder.Bill_To_Address__r.County__c;
                if(currentSalesorder.Bill_To_Address__r.Country__c != Null) Payment1.Country__c = currentSalesorder.Bill_To_Address__r.Country__c;
                if(currentSalesorder.Bill_To_Address__r.Postal_Code__c != Null) Payment1.Zipcode__c = currentSalesorder.Bill_To_Address__r.Postal_Code__c; 
                Payment1.Account__c = currentSalesorder.Organisation__c;
                Payment1.Organisation_Business_Unit__c = currentSalesorder.Organisation_Business_Unit__c;
                Payment1.ERP7__Credit_Note__c = creditNote.Id;
                Payment1.ERP7__Type__c = 'Credit';
                Payment1.ERP7__Payment_Type__c = 'Refund';
                Payment1.ERP7__Status__c = 'Paid';
                payment1.ERP7__Amount__c = creditNote.ERP7__Amount__c;
                String rTypeP1 = RecordTypeUtil.getObjectRecordTypeIds('Payment__c','Credit_Note_Payments');
                if(String.isNotEmpty(rTypeP1)){
                    Payment1.RecordTypeId = rTypeP1; 
                }
                Payment1.ERP7__Posted__c = true;
                Payment1.ERP7__Posted_Date__c = system.Today();
                pays.add(payment1);*/
                
                if(Schema.SObjectType.ERP7__Payment__c.isCreateable() && Schema.SObjectType.ERP7__Payment__c.isupdateable()){ DMLManager.upsertAsUser(pays); }else { /* no access*/}
            } else if(returnMethod == 'Loyalty Points' && clubCard.size() > 0 && sum2Detect > 0) {  List<Loyalty_Setup__c> Loyaltysetup; if(Schema.sObjectType.Loyalty_Setup__c.isAccessible()) Loyaltysetup = [Select Id, Name, Points_Per_Unit_Amount__c, Organisation__c From Loyalty_Setup__c  Where  Organisation__c =: currentSalesOrder.Organisation__c order by CreatedDate Asc Limit 1];if(Loyaltysetup.size() > 0) {Decimal points = Loyaltysetup[0].Points_Per_Unit_Amount__c * sum2Detect ;Loyalty_Points__c returnReward = new Loyalty_Points__c(Active__c=true,Loyalty_Card__c = clubCard[0].id, Credit_Debit_Date__c = System.today(), Order__c = currentSalesOrder.id, Points__c = points, Transaction_Status__c = 'Credit', Valid_Date__c = System.Today()+30, Organisation__c = currentSalesOrder.Organisation__c); if(Schema.sObjectType.Loyalty_Points__c.isCreateable()){ DMLManager.insertAsUser(returnReward);} else{ /*no access*/ } pay = new Payment__c(Amount__c= sum2Detect, Sales_Order__c=currentSalesOrder.Id, Status__c='Paid', Account__c=currentSalesOrder.Organisation__c); if(Schema.sObjectType.Payment__c.isCreateable()){DMLManager.insertAsUser(pay);} else{/* no access*/ }                           
                }
            }  
            if(ApexPages.currentPage().getParameters().get('sId') != null) page = new PageReference('/'+currentSalesOrder.Id); 
            else if(ApexPages.currentPage().getParameters().get('red') != null) page = new PageReference('/apex/StockReceiving');
            customCon();    
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } 
        //return Page;
        
        return Null;
        
    }
     
    global PageReference editItem() {
        itemDisplay = true;
        orderDisplay = false;
        return null;
    } 
    
    global List<SelectOption> getCurrentDiscounts() {
        List<SelectOption> options = new List<SelectOption>();
        try {
            mapDis = new Map<Id, Coupon__c>();
            List<Coupon__c> defaultDiscount;
            if(Schema.sObjectType.Coupon__c.isAccessible())
                defaultDiscount  = [Select id, Name, Product__c,  End_Date__c, Start_Date__c, Value__c, Value_In_Percent__c
                                      From Coupon__c Where Product__c =: sel.Product__c  And End_Date__c >= Today  Limit 1];
            if(defaultDiscount.size() > 0) {options.add(new SelectOption(defaultDiscount[0].id,defaultDiscount[0].Name));mapDis.put(defaultDiscount[0].id, defaultDiscount[0]);
            } else { options.add(new SelectOption('--None--','--None--')); }
            for(Coupon__c dis : discounts) { options.add(new SelectOption(dis.id,dis.Name)); mapDis.put(dis.id, dis); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } 
        return options;
    }
    
    global PageReference addDiscount() {
        try {
            if(Schema.sObjectType.Coupon__c.isAccessible())
                discounts = [Select id, Name, Product__c, End_Date__c,  Start_Date__c, Value__c, Value_In_Percent__c
                             From Coupon__c where Product__c =: sel.Product__c And End_Date__c >= Today];  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }    
        return null;  
    } 
    
    global PageReference Back2Order() { PageReference page;try {if(ApexPages.currentPage().getParameters().get('sId') != null || ApexPages.currentPage().getParameters().get('sId') != '') page = new PageReference('/'+currentSalesOrder.Id);  else page = new PageReference('/apex/StockReceiving');   } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }       return page;  
    }   
    
    global PageReference fetchSalesOrder() { PageReference page;try {Sales_Order__c sod;  if(newCurrentItems.Sales_Order__c != null) sod = [select Id, Name, Customer_Id__c from Sales_Order__c where Id=: newCurrentItems.Sales_Order__c];if(sod != null) {page = new PageReference('/apex/ProcessReturnPage'); page.getParameters().put('con',sod.Customer_Id__c);page.getParameters().put('oid',sod.Name);  page.getParameters().put('red','false'); if(ApexPages.currentPage().getParameters().get('sId') != null) page.getParameters().put('sId',ApexPages.currentPage().getParameters().get('sId'));  page.setRedirect(true);  }} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }return page;
    }    
}