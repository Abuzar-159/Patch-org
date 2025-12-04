Global with sharing class AccountsReceivable {
    @AuraEnabled     
    public list<Account> CustomerList             {set;get;} 
    @AuraEnabled
    public list<ERP7__Invoice__c> InvoiceList     {set;get;}
    @AuraEnabled
    public list<ERP7__Payment__c> PaymentList     {set;get;}
    @AuraEnabled
    public list<ERP7__Coupon__c> CouponList       {set;get;}
    @AuraEnabled
    public list<ERP7__Credit_Note__c> CreditList  {set;get;}
    @AuraEnabled     
    public list<ERP7__Debit_Note__c> DebitList    {set;get;}
    @AuraEnabled
    public list<ERP7__Dunning__c>  DunningList    {set;get;}       
    @AuraEnabled
    public ERP7__Invoice__c  InvoiceRecord        {set;get;}    
    @AuraEnabled 
    public String  SaveErrorMsg                   {set;get;} 
    @AuraEnabled
    public ERP7__Payment__c  PaymentRecord        {set;get;}       
    @AuraEnabled
    public ERP7__Debit_Note__c  debitRecord        {set;get;}     
    @AuraEnabled
    public Boolean  Posted                        {set;get;}    
    @AuraEnabled
    public list<SelectOption>  CustomerRTList     {set;get;} 
    @AuraEnabled
    public list<SelectOption>  PaymentRTList      {set;get;}  
    @AuraEnabled
    public list<SelectOption>  CouponRTList       {set;get;}  
    @AuraEnabled
    public list<SelectOption> InvoiceRTList       {set;get;}
    @AuraEnabled
    public Date TODAY                             {set;get;}   
    @AuraEnabled public Integer recSize           {get;set;}
    @AuraEnabled     
    public list<Account> CustomerListForSearch             {set;get;}
    @AuraEnabled
    public list<ERP7__Invoice__c> InvoiceListForSearch     {set;get;}
    @AuraEnabled
    public list<ERP7__Payment__c> PaymentListForSearch     {set;get;}
    @AuraEnabled
    public list<ERP7__Credit_Note__c> CreditListForSearch  {set;get;}
    @AuraEnabled
    public list<ERP7__Debit_Note__c> DebitListForSearch  {set;get;}
  
    
    
    global  String IdValue   {
        get{ return IdValue; }
        set{ IdValue =value; }
    }
    
    public class LineItems {
        @AuraEnabled
        public String SOLIName  {set;get;} 
        @AuraEnabled
        public String SOLIId  {set;get;} 
        @AuraEnabled
        public String ProductName  {set;get;} 
        @AuraEnabled
        public String ProductId  {set;get;} 
        @AuraEnabled
        public Decimal Quantity  {set;get;}
        @AuraEnabled
        public Decimal BasePrice  {set;get;}
        @AuraEnabled
        public Decimal UnitPrice  {set;get;}
        @AuraEnabled
        public Decimal Tax  {set;get;}
        @AuraEnabled
        public Decimal Discount  {set;get;}            
    }
    @AuraEnabled 
    public static List<ERP7__Invoice_Line_Item__c> getInvoiceLineItems(String SOId){
        List<ERP7__Invoice_Line_Item__c> invliList = new List<ERP7__Invoice_Line_Item__c>();
        for(ERP7__Sales_Order_Line_Item__c soli:[SELECT Id, Name, ERP7__Active__c,ERP7__Tax__c,ERP7__Price_Book_Unit_Cost__c, ERP7__Allocate_Stock__c, ERP7__Asset__c, ERP7__Backorder_Quantity__c, ERP7__Base_Price__c, ERP7__Code__c, 
                                                 ERP7__Cost__c, ERP7__Coupon__c, ERP7__Coupon_Redemption__c, ERP7__Discount_Amount__c, ERP7__Discount_Plan__c, ERP7__Duration__c, ERP7__Invoice__c, ERP7__Detailed_Description__c, 
                                                 ERP7__Invoiced_Quantity__c, ERP7__Is_Pre_Order__c, ERP7__Is_Purchase_Order__c, ERP7__Name__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Organisation_Business_Unit__c,
                                                 ERP7__Price_Product__c, ERP7__PriceBook_Base_Price__c, ERP7__PriceBook_Total_Price__c, ERP7__PriceBookId__c, ERP7__Quantity__c, ERP7__ReturnAmount__c,
                                                 ERP7__Reserved_Date__c, ERP7__Reserved_Quantity__c,ERP7__ReturnedQuantity__c, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__Order_Line_Status__c,
                                                 ERP7__Sub_Total__c, ERP7__Total_Price__c,  ERP7__VAT_Amount__c, ERP7__VAT_Amount_Formula__c, ERP7__VAT_Percentage__c, ERP7__Product__c,
                                                 ERP7__Sort_Order__c, ERP7__Product__r.Name FROM ERP7__Sales_Order_Line_Item__c WHERE ERP7__Sales_Order__c=:SOId]){
                                                     if(soli.ERP7__Invoiced_Quantity__c ==null) soli.ERP7__Invoiced_Quantity__c=0.00;
                                                     if(soli.ERP7__Invoiced_Quantity__c < soli.ERP7__Quantity__c){
                                                         ERP7__Invoice_Line_Item__c tempinvli = new ERP7__Invoice_Line_Item__c(ERP7__Product__c=soli.ERP7__Product__c,ERP7__Base_Price__c = soli.Base_Price__c,ERP7__Sales_Order_Line_Item__c = soli.id);
                                                         tempinvli.ERP7__Sales_Order_Line_Item__r=new ERP7__Sales_Order_Line_Item__c(Id= soli.Id,ERP7__Quantity__c=soli.ERP7__Quantity__c,ERP7__Invoiced_Quantity__c=soli.ERP7__Invoiced_Quantity__c);
                                                         tempinvli.ERP7__Quantity__c= (soli.Quantity__c - soli.Invoiced_Quantity__c).setScale(2);
                                                         tempinvli.ERP7__Unit_Price__c =soli.ERP7__Price_Product__c;
                                                         tempinvli.ERP7__Tax_Rate__c=soli.ERP7__Tax__c;
                                                         //tempinvli.ERP7__Sort_Order__c = soli.ERP7__Sort_Order__c;
                                                         tempinvli.ERP7__Detailed_Description__c = soli.ERP7__Detailed_Description__c; 
                                                         tempinvli.ERP7__Discount_Amount__c=soli.ERP7__Discount_Amount__c==null?0:soli.ERP7__Discount_Amount__c;
                                                         tempinvli.ERP7__Sub_Total__c= (tempinvli.ERP7__Quantity__c * tempinvli.ERP7__Unit_Price__c).setScale(2);
                                                         tempinvli.ERP7__VAT_Amount__c = ((soli.ERP7__VAT_Amount__c !=null)?soli.ERP7__VAT_Amount__c/soli.Quantity__c*tempinvli.Quantity__c : 0).setScale(2);
                                                         tempinvli.ERP7__Other_Tax__c = ((soli.ERP7__Other_Tax__c !=null)?soli.ERP7__Other_Tax__c/soli.Quantity__c*tempinvli.Quantity__c :0).setScale(2);
                                                         tempinvli.ERP7__Total_Price__c= (tempinvli.ERP7__Sub_Total__c + tempinvli.ERP7__Other_Tax__c + tempinvli.ERP7__VAT_Amount__c ).setScale(2);
                                                         if(soli.ERP7__Discount_Amount__c==null)soli.ERP7__Discount_Amount__c=0;
                                                         tempinvli.ERP7__Total_Price__c=tempinvli.ERP7__Total_Price__c-soli.ERP7__Discount_Amount__c;
                                                         tempinvli.ERP7__Price_Book_Unit_Cost__c =(soli.ERP7__Price_Book_Unit_Cost__c!=null)? soli.ERP7__Price_Book_Unit_Cost__c:0.00;
                                                         tempinvli.ERP7__Cost_Price__c = (soli.ERP7__Cost__c!=null)? soli.ERP7__Cost__c:0.00;
                                                         invliList.add(tempinvli);
                                                     }
                                                 }
        return invliList;
    }
    @AuraEnabled 
    public static Account fetchAccountDetails(String recordId){
        return [SELECT Id, ERP7__Organisation__c FROM Account WHERE id=:recordId];
    } 
    
    @AuraEnabled 
    public static list<LineItems> getInvoiceLineItem(String SOId){ 
        list<LineItems> ILIList=new list<LineItems>();       
        list<ERP7__Sales_Order_Line_Item__c> SOLIList=new list<ERP7__Sales_Order_Line_Item__c>();
        SOLIList=[SELECT Id, Name, ERP7__Active__c, ERP7__Allocate_Stock__c, ERP7__Asset__c, ERP7__Backorder_Quantity__c, ERP7__Base_Price__c, ERP7__Code__c, ERP7__Detailed_Description__c,
                  ERP7__Cost__c, ERP7__Coupon__c, ERP7__Coupon_Redemption__c, ERP7__Discount_Amount__c, ERP7__Discount_Plan__c, ERP7__Duration__c, ERP7__Invoice__c, 
                  ERP7__Invoiced_Quantity__c, ERP7__Is_Pre_Order__c, ERP7__Is_Purchase_Order__c, ERP7__Name__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Organisation_Business_Unit__c,
                  ERP7__Price_Product__c, ERP7__PriceBook_Base_Price__c, ERP7__PriceBook_Total_Price__c, ERP7__PriceBookId__c, ERP7__Quantity__c, ERP7__ReturnAmount__c,
                  ERP7__Reserved_Date__c, ERP7__Reserved_Quantity__c,ERP7__ReturnedQuantity__c, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__Order_Line_Status__c,
                  ERP7__Sub_Total__c, ERP7__Total_Price__c,  ERP7__VAT_Amount__c, ERP7__VAT_Amount_Formula__c, ERP7__VAT_Percentage__c, ERP7__Product__c,
                  ERP7__Sort_Order__c, ERP7__Product__r.Name
                  FROM ERP7__Sales_Order_Line_Item__c
                  WHERE ERP7__Sales_Order__c=:SOId]; 
        
        for(ERP7__Sales_Order_Line_Item__c s:SOLIList){
            if((s.ERP7__Quantity__c - s.ERP7__Invoiced_Quantity__c)>0.00){
                LineItems ILI=new LineItems(); ILI.SOLIName=s.Name; ILI.SOLIId=s.Id; ILI.ProductName=s.ERP7__Product__r.Name; ILI.ProductId=s.ERP7__Product__c;  ILI.Quantity=s.ERP7__Quantity__c; ILI.BasePrice=s.ERP7__Base_Price__c; ILI.Tax=s.ERP7__Other_Tax__c+s.ERP7__VAT_Amount__c; ILI.Discount=s.ERP7__Discount_Amount__c;ILI.UnitPrice=s.ERP7__Price_Product__c; ILIList.add(ILI);
            }
        }
        if(ILIList.size()>0) return ILIList; else return null;
    }    
    
    @AuraEnabled 
    public static LineItems getInvoiceAndLineItemInstance(){ 
        return new LineItems();
    }   
    
    @AuraEnabled 
    public static void getCreateInvoiceAndLineItem(String InvoiceLineItem, String SO){
        if(SO!=null){
            try{
               ERP7__Sales_Order__c salesorder = (ERP7__Sales_Order__c)JSON.deserialize(SO, ERP7__Sales_Order__c.class);
                if(Schema.sObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()) upsert salesorder; else{ }
            }catch(Exception e){ }
        }
        List <ERP7__Invoice_Line_Item__c> InvoiceLIList = (List <ERP7__Invoice_Line_Item__c> ) JSON.deserialize(InvoiceLineItem, List <ERP7__Invoice_Line_Item__c> .class);  
        for(Integer i = 0;i<InvoiceLIList.size();i++){
            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isUpdateable()) InvoiceLIList[i].ERP7__Sort_Order__c = i+1;
        }
        
        if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.isUpdateable()){ upsert InvoiceLIList; }else{/*not allowed to update*/}
    }
    @AuraEnabled 
    public static Decimal fetchTotalDownPayment(String orderId){ 
        List<ERP7__Invoice__c> INVcs = [Select ERP7__Total_Down_Payment_Amount__c from ERP7__Invoice__c where ERP7__Order__c =:orderId AND RecordType.DeveloperName='Advance' ];
        Decimal TD=0; 
        for(ERP7__Invoice__c inv : INVcs){ TD = TD + inv.ERP7__Total_Down_Payment_Amount__c!=null?inv.ERP7__Total_Down_Payment_Amount__c:0; }
        return TD;
    }
    @AuraEnabled 
    public static ERP7__Sales_Order__c fetchOrderDetails(String orderId){ 
        return [SELECT Id,ERP7__Total_Shipping_Amount__c,ERP7__Sales_Order_Amount__c,ERP7__Contact__c,ERP7__Include_Shipping_Amount__c,ERP7__Shipping_VAT__c,ERP7__Amount_Paid__c,ERP7__Total_Tax_Amount__c,ERP7__Coupon_Discount__c,ERP7__Account__c,ERP7__Organisation__c
                FROM ERP7__Sales_Order__c WHERE Id=:orderId];
    }
    
    
    @AuraEnabled 
    public static AccountsReceivable getInvoiceRecordType(){
        try{
            AccountsReceivable ar=new AccountsReceivable();
        	ar.InvoiceRTList=new list<SelectOption>();
        
            for(Schema.RecordTypeInfo sr : Schema.SObjectType.ERP7__Invoice__c.getRecordTypeInfosByName().values()){
            	if(sr.isAvailable() && !sr.isMaster()){
                    ar.InvoiceRTList.add(new SelectOption(sr.getRecordTypeId()+'@'+sr.getName(),sr.getName()));    
                }    
            }
        	ar.InvoiceRecord=new ERP7__Invoice__c();
        	return ar;
        }catch(Exception e){ AccountsReceivable ar2=new AccountsReceivable(); return ar2;}
    }
    
    @AuraEnabled 
    public static string getInvoiceRecordType1(){
        
        return 'String Return';
    }
    
    @AuraEnabled 
    public static AccountsReceivable getInvoiceUpdate(String InvoiceId){
        AccountsReceivable ar=new AccountsReceivable();
        ERP7__Invoice__c inv=new ERP7__Invoice__c();
        ar.SaveErrorMsg='';   ar.Posted=true;  ar.InvoiceRecord=new ERP7__Invoice__c();  
        if(String.isNotEmpty(InvoiceId)){
            try{ 
                inv=[SELECT Id, Name, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c,ERP7__Status__c,RecordType.Name,RecordTypeId, ERP7__Account__c,ERP7__Type__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c
                     ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c, ERP7__Order__r.ERP7__Status__c , ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c                  
                     ,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                     FROM ERP7__Invoice__c 
                     WHERE Id=:InvoiceId];
                if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isUpdateable()){
                    if(inv.ERP7__Posted__c) inv.ERP7__Posted__c=false;  else inv.ERP7__Posted__c=true;
                }
                
               if(Schema.sObjectType.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.isUpdateable()) { upsert inv; }else {/*not allowed to upsert*/}
                ar.InvoiceRecord=inv;
                return ar;  
            }catch(Exception ex){  ar.SaveErrorMsg=ex.getMessage();  ar.InvoiceRecord=null;   return ar;  } 
        } 
        return ar;  
    }
    
    @AuraEnabled 
    public static AccountsReceivable getPaymentUpdate(String PaymentId){
        AccountsReceivable ar=new AccountsReceivable();
        ERP7__Payment__c pay=new ERP7__Payment__c();
        ar.SaveErrorMsg='';   ar.Posted=true;  ar.PaymentRecord=new ERP7__Payment__c();  
        if(String.isNotEmpty(PaymentId)){
            try{ 
                pay=[SELECT Id, Name, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__c,  ERP7__Sales_Order__r.Name, ERP7__Amount__c, ERP7__Status__c, ERP7__Type__c, ERP7__Account__c, ERP7__Account__r.Name,
                     RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c                
                     FROM ERP7__Payment__c 
                     WHERE Id=:PaymentId];
                if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()){
                    if(pay.ERP7__Posted__c){ pay.ERP7__Posted__c = false;
                                            //pay.ERP7__Posted_Date__c = date.today();
                                           } 
                    else{
                        pay.ERP7__Posted__c=true; pay.ERP7__Posted_Date__c = date.today();
                    }
                }
                 
                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){upsert pay;}else{/*not allowed to upsert*/} 
                ar.PaymentRecord=pay;
            }catch(Exception ex){  ar.SaveErrorMsg=ex.getMessage();  ar.PaymentRecord=null;   return ar;  }  
        } 
        return ar;  
    }
    
    @AuraEnabled 
    public static AccountsReceivable getDebitUpdate(String debitID){
        AccountsReceivable ar=new AccountsReceivable();
        ERP7__Debit_Note__c deb=new ERP7__Debit_Note__c();
        ar.SaveErrorMsg='';   ar.Posted=true;  ar.debitRecord=new ERP7__Debit_Note__c();  
        if(String.isNotEmpty(debitID)){
            try{ 
                deb=[SELECT Id, Name,ERP7__Account__c,ERP7__Account__r.Name, ERP7__Credit__c,ERP7__Debit__c,  ERP7__Posted__c, ERP7__Amount__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Organisation__r.ERP7__Account_Type__c FROM ERP7__Debit_Note__c 
                     WHERE Id=:debitID];
                if(Schema.sObjectType.ERP7__Debit_Note__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note__c.fields.ERP7__Posted__c.isUpdateable()){
                    if(deb.ERP7__Posted__c){
                        deb.ERP7__Posted__c=false;
                    } 
                    else{
                        deb.ERP7__Posted__c=true;
                    } 
                }
                if(Schema.sObjectType.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note__c.isUpdateable()){ upsert deb; }else{/*not allowed to update*/}       
                ar.debitRecord=deb;
            }catch(Exception ex){ ar.SaveErrorMsg=ex.getMessage(); ar.debitRecord=null; return ar; }  
        } 
        return ar;  
    }
    
    @AuraEnabled 
    public static AccountsReceivable getRecords(String orgId, String showTabs, String OrderBy, String Order, String[] selectedCustomersId,String[] selectInvoiceId,Integer Offset, Integer RecordLimit,String searchString){ 
       Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        AccountsReceivable ar=new AccountsReceivable();
        list<String> scIds=new list<String>(); scIds.addAll(selectedCustomersId);
        list<String> invIds=new list<String>(); invIds.addAll(selectInvoiceId);
        
        String OrderByQyeryFilter='';
        String SelectedCustomersQuery=''; 
        String SelectedInvoicesQuery=''; 
        
         SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Account__c IN: scIds':'';  
        SelectedInvoicesQuery = (invIds.size()>0)?' AND ERP7__Invoice__c IN: invIds':'';  
        if(String.isNotEmpty(OrderBy) && String.isNotEmpty(Order)) OrderByQyeryFilter=' Order By '+String.escapeSingleQuotes(OrderBy)+' '+String.escapeSingleQuotes(Order);   
        
        String s= '%'+searchString+'%';
        if(showTabs=='cus'){
            String query='SELECT Id, Name,ERP7__Opening_Balance__c, AccountNumber,ERP7__Payment_Terms__c,ERP7__Credit_Balance__c,ERP7__Debit_Note_Balance__c,  ERP7__Paid_Amount__c, ERP7__Available_Credit_Balance__c,ERP7__Total_Due__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Account_Type__c,ERP7__Organisation__r.ERP7__Account_Type__c FROM Account  WHERE (ERP7__Account_Type__c=\'Customer\' OR ERP7__Account_Type__c=\'Vendor\') AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) ' ;
            if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
            if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name  asc limit 2000 ';
            if(String.isEmpty(orgId))query += '  order by Name  asc limit 2000 ';
            ar.CustomerList = Database.query(query);
            ar.recSize     =  ar.CustomerList.size(); 
            ar.CustomerListForSearch  = ar.CustomerList;
            query=null;
            query='SELECT Id, Name, AccountNumber,ERP7__Opening_Balance__c,ERP7__Payment_Terms__c,  ERP7__Paid_Amount__c,ERP7__Debit_Note_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c,ERP7__Total_Due__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Account_Type__c,ERP7__Organisation__r.ERP7__Account_Type__c FROM Account  WHERE (ERP7__Account_Type__c=\'Customer\' OR ERP7__Account_Type__c=\'Vendor\') AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) ' ;
            if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
            if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name limit :ikRecordLimit Offset :ikOffset ';
            if(String.isEmpty(orgId))query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
            ar.CustomerList = Database.query(query); 
          }
        
        if(showTabs=='inv'){ 
            SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Account__c IN:scIds':'';  
            list<ERP7__Invoice__c> InvList=new list<ERP7__Invoice__c>();  
            if(String.isEmpty(orgId)){ 
                String invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                    ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+                   
                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true AND ERP7__Order__r.ERP7__Due_Amount__c >0 AND ERP7__Final_Due_Amount__c >0 AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null)'+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;                               
                if(searchString!=null && searchString!='')invoiceQuery += ' AND Name Like :s ';
                if(String.isEmpty(orgId))invoiceQuery += '  order by Name  asc limit 2000 ';
                InvList=Database.query(invoiceQuery); 
                ar.InvoiceListForSearch = InvList;
                ar.recSize     =  InvList.size();
                invoiceQuery='SELECT Id, Name, ERP7__Account__r.Name,RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                    ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+                   
                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true AND ERP7__Order__r.ERP7__Due_Amount__c >0 AND ERP7__Final_Due_Amount__c >0 AND  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null)'+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;                               
                if(searchString!=null && searchString!='')invoiceQuery += ' AND Name Like :s ';
                if(String.isEmpty(orgId))invoiceQuery += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
                InvList=Database.query(invoiceQuery); 
                ar.InvoiceList=InvList;               
            }else{          
                String invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                    ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+                   
                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true AND ERP7__Order__r.ERP7__Due_Amount__c >0 AND ERP7__Final_Due_Amount__c >0 AND ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' AND ERP7__Organisation__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' '+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;          
                if(searchString!=null && searchString!='')invoiceQuery += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))invoiceQuery += '  order by Name  asc limit 2000 ';
                InvList=Database.query(invoiceQuery); 
                ar.InvoiceListForSearch = InvList;
                ar.recSize     =  InvList.size();
                invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                    ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+                   
                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true AND ERP7__Order__r.ERP7__Due_Amount__c > 0 AND ERP7__Final_Due_Amount__c >0 AND ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' AND ERP7__Organisation__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' '+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;          
                if(searchString!=null && searchString!='')invoiceQuery += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))invoiceQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                InvList=Database.query(invoiceQuery);  
                ar.InvoiceList=InvList;             
            }       
        }
        if(showTabs=='pay'){
            
            SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Accounts__c IN: scIds':''; 
            String invStr=''; invStr=(scIds.size()>0)?' AND ERP7__Account__c IN: scIds':'';
            SelectedInvoicesQuery = (invIds.size()>0)?' AND ERP7__Invoice__c IN: invIds':''; 
        
                if(String.isEmpty(orgId)) { list<ERP7__Payment__c> PaymentList=new list<ERP7__Payment__c>();
                                           String PaymentQuery='SELECT Id, Name, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__c,  ERP7__Sales_Order__r.Name, ERP7__Amount__c, ERP7__Status__c, ERP7__Type__c, ERP7__Account__c, ERP7__Account__r.Name,'+
                                               'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Sales_Order__r.ERP7__Due_Amount__c, ERP7__Posted_Date__c, ERP7__Accounts__c, ERP7__Payment_Date__c, ERP7__Accounts__r.Name'+                
                                               ' FROM ERP7__Payment__c WHERE ERP7__Account__c=Null AND ERP7__Invoice__c!=Null AND ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 '+String.escapeSingleQuotes(invStr);//+OrderByQyeryFilter;
                                           if(searchString!=null && searchString!='')PaymentQuery += ' AND Name Like :s ';
                                           if(String.isEmpty(orgId))PaymentQuery += '  order by Name  asc limit 2000 ';
                                           PaymentList=Database.query(PaymentQuery); 
                                           ar.PaymentListForSearch = PaymentList;
                                           ar.recSize     =  ar.PaymentListForSearch.size();
                                           
                                           /* for(ERP7__Payment__c i: Database.Query(PaymentQuery)){    try{ list<ERP7__Transaction__c> TransactionList=new list<ERP7__Transaction__c>(); try{
                                            TransactionList=[SELECT Id, Name, ERP7__Invoice__c, ERP7__Payment__c, ERP7__Accounting_Period__c, ERP7__Accounting_Period__r.ERP7__Status__c FROM ERP7__Transaction__c WHERE ERP7__Payment__c=:i.Id]; }catch(Exception e){}
                                            if(TransactionList.size()==0) PaymentList.add(i);
                                            else if(TransactionList.size()>0){ for(ERP7__Transaction__c t:TransactionList){  if(t.ERP7__Accounting_Period__r.ERP7__Status__c=='Open') 
                                            PaymentList.add(i);
                                            } 
                                            
                                            } 
                                            
                                            }catch(Exception ex){ }  } 
										  */
                                           PaymentQuery='SELECT Id, Name, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__c, ERP7__Payment_Date__c, ERP7__Sales_Order__r.ERP7__Due_Amount__c, ERP7__Sales_Order__r.Name, ERP7__Amount__c, ERP7__Status__c, ERP7__Type__c, ERP7__Account__c, ERP7__Account__r.Name,'+
                                               'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Accounts__c, ERP7__Accounts__r.Name'+                
                                               ' FROM ERP7__Payment__c WHERE ERP7__Accounts__c=Null AND ERP7__Invoice__c!=Null AND ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 '+String.escapeSingleQuotes(invStr);//+OrderByQyeryFilter;
                                           if(searchString!=null && searchString!='')PaymentQuery += ' AND Name Like :s ';
                                           if(String.isEmpty(orgId))PaymentQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                                           ar.PaymentList=Database.query(PaymentQuery); //PaymentList;     
                                           
                                           
                                           
                                           
                                          }     
                else{                
                    list<ERP7__Payment__c> PaymentList=new list<ERP7__Payment__c>();
                    
                    String PaymentQuery='SELECT Id, Name, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__r.ERP7__Due_Amount__c, ERP7__Sales_Order__c, ERP7__Payment_Date__c, ERP7__Sales_Order__r.Name, ERP7__Amount__c, ERP7__Status__c, ERP7__Type__c, ERP7__Account__c, ERP7__Account__r.Name,'+
                        'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c , ERP7__Accounts__c, ERP7__Sales_Order__r.ERP7__Account__r.Name, ERP7__Accounts__r.Name'+               
                        ' FROM ERP7__Payment__c  WHERE ERP7__Accounts__c!=Null AND ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 AND ERP7__Invoice__c!=Null AND ERP7__Account__r.ERP7__Account_Type__c=\'Organisation\' AND ERP7__Account__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' '+String.escapeSingleQuotes(SelectedCustomersQuery)+String.escapeSingleQuotes(SelectedInvoicesQuery);//+OrderByQyeryFilter;
                    
                    if(searchString!=null && searchString!='')PaymentQuery += ' AND Name Like :s ';
                    if(String.isNotEmpty(orgId))PaymentQuery += '  order by Name  asc limit 2000 ';
                    PaymentList=Database.query(PaymentQuery); 
                    ar.PaymentListForSearch = PaymentList;
                    ar.recSize     =  PaymentList.size();
                    
                    /*for(ERP7__Payment__c i:Database.query(PaymentQuery)) {
                    try{  list<ERP7__Transaction__c> TransactionList=new list<ERP7__Transaction__c>();  try{      TransactionList=[SELECT Id, Name, ERP7__Invoice__c, ERP7__Payment__c, ERP7__Accounting_Period__c, ERP7__Accounting_Period__r.ERP7__Status__c  FROM ERP7__Transaction__c WHERE ERP7__Payment__c=:i.Id];  }catch(Exception e){}  if(TransactionList.size()==0) PaymentList.add(i); else if(TransactionList.size()>0){ for(ERP7__Transaction__c t:TransactionList){ if(t.ERP7__Accounting_Period__r.ERP7__Status__c=='Open') PaymentList.add(i);
                    }             
                    } 
                    }catch(Exception ex){}     
                    } */
                    // set<String> payids=new set<String>();
                    // for(ERP7__Payment__c i: Database.query(PaymentQuery))payids.add(i.Id);
                    // list<ERP7__Transaction__c> TransactionList=[SELECT Id, Name, ERP7__Invoice__c, ERP7__Payment__c, ERP7__Accounting_Period__c, ERP7__Accounting_Period__r.ERP7__Status__c  FROM ERP7__Transaction__c WHERE ERP7__Payment__c IN: payids and ERP7__Accounting_Period__r.ERP7__Status__c='Open']; 
                    
                    PaymentQuery='SELECT Id, Name, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__r.ERP7__Due_Amount__c, ERP7__Sales_Order__c,  ERP7__Sales_Order__r.Name, ERP7__Amount__c, ERP7__Status__c, ERP7__Type__c, ERP7__Account__c, ERP7__Account__r.Name,'+
                        'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c , ERP7__Payment_Date__c, ERP7__Accounts__c, ERP7__Sales_Order__r.ERP7__Account__r.Name, ERP7__Accounts__r.Name'+               
                        ' FROM ERP7__Payment__c  WHERE ERP7__Accounts__c!=Null AND ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 AND ERP7__Invoice__c!=Null AND ERP7__Account__r.ERP7__Account_Type__c=\'Organisation\' AND ERP7__Account__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' '+String.escapeSingleQuotes(SelectedCustomersQuery)+String.escapeSingleQuotes(SelectedInvoicesQuery);//+OrderByQyeryFilter;
                    if(searchString!=null && searchString!='')PaymentQuery += ' AND Name Like :s ';
                    if(String.isNotEmpty(orgId))PaymentQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                    ar.PaymentList=Database.query(PaymentQuery);     
                    
                }    
        }
        
        if(showTabs=='cre'){        
            SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Account__c IN: scIds':'';
            if(String.isEmpty(orgId)){   
                String CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null)'+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isEmpty(orgId))CreditQuery += '  order by Name  asc limit 2000 ';
                ar.CreditList=Database.query(CreditQuery); 
                ar.CreditListForSearch = ar.CreditList;
                ar.recSize     =  ar.CreditListForSearch.size();
                CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null)'+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isEmpty(orgId))CreditQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                ar.CreditList=Database.query(CreditQuery);
            }   
            else{
                String CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) AND ERP7__Organisation__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' '+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))CreditQuery += '  order by Name  asc limit 2000 ';
                ar.CreditList=Database.query(CreditQuery); 
                ar.CreditListForSearch = ar.CreditList;
                ar.recSize     =  ar.CreditList.size();
                CreditQuery='SELECT Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                    ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                    ',ERP7__Sales_Order__c, ERP7__Sales_Order__r.Name ,ERP7__Account__r.Name'+           
                    ' FROM ERP7__Credit_Note__c'+
                    ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) AND ERP7__Organisation__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' '+String.escapeSingleQuotes(SelectedCustomersQuery);//+OrderByQyeryFilter;
                if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))CreditQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                ar.CreditList=Database.query(CreditQuery);
                
            }
        }
        if(showTabs=='dun'){
            SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Customer__c IN: scIds':'';
            if(String.isEmpty(orgId)){   
                String DunningList='SELECT Id, Name, ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Invoice__r.ERP7__Due_Date__c,ERP7__Status__c, ERP7__Supplier_Used__c, ERP7__Supplier_Used__r.Name, ERP7__Customer__r.Name, ERP7__Dunning_Applied_Date__c,ERP7__Organisations__c, ERP7__Organisations__r.Name'+ 
                    ' FROM ERP7__Dunning__c'+
                    ' WHERE ERP7__Invoice__c!=Null AND ERP7__Customer__c!=Null AND (ERP7__Organisations__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisations__r.ERP7__Account_Type__c=Null)'+String.escapeSingleQuotes(SelectedCustomersQuery)+String.escapeSingleQuotes(OrderByQyeryFilter);
                ar.DunningList=Database.query(DunningList);
            }
            
            else{
                String DunningList='SELECT Id, Name, ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Invoice__r.ERP7__Due_Date__c,ERP7__Status__c, ERP7__Supplier_Used__c, ERP7__Supplier_Used__r.Name, ERP7__Customer__r.Name, ERP7__Dunning_Applied_Date__c,ERP7__Organisations__c, ERP7__Organisations__r.Name'+ 
                    ' FROM ERP7__Dunning__c'+
                    ' WHERE ERP7__Invoice__c!=Null AND ERP7__Customer__c!=Null AND (ERP7__Organisations__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisations__r.ERP7__Account_Type__c=Null) AND ERP7__Organisations__c='+'\''+String.escapeSingleQuotes(orgId)+'\''+' '+String.escapeSingleQuotes(SelectedCustomersQuery)+String.escapeSingleQuotes(OrderByQyeryFilter);
                ar.DunningList=Database.query(DunningList);
            }
        }
        
        if(showTabs=='deb'){
            String query='SELECT Id, Name,ERP7__Account__c,ERP7__Account__r.Name, ERP7__Credit__c,ERP7__Debit__c,  ERP7__Posted__c, ERP7__Amount__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Organisation__r.ERP7__Account_Type__c FROM ERP7__Debit_Note__c  WHERE  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) ' ;
            if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
            query += (scIds.size()>0)?' AND ERP7__Account__c IN:scIds':''; 
            if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name  asc limit 2000 ';
            if(String.isEmpty(orgId))query += '  order by Name  asc limit 2000 ';
            ar.DebitList = Database.query(query);
            ar.recSize     =  ar.DebitList.size(); 
            ar.DebitListForSearch  = ar.DebitList;
            query=null;
            query='SELECT Id, Name,ERP7__Account__c, ERP7__Credit__c,ERP7__Debit__c,ERP7__Account__r.Name,  ERP7__Posted__c, ERP7__Amount__c, ERP7__Organisation__c, ERP7__Organisation__r.Name ,ERP7__Organisation__r.ERP7__Account_Type__c FROM ERP7__Debit_Note__c  WHERE  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null) ' ;if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
            if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
            query += (scIds.size()>0)?' AND ERP7__Account__c IN:scIds':''; 
            if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name limit :ikRecordLimit Offset :ikOffset ';
            if(String.isEmpty(orgId))query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
            ar.DebitList = Database.query(query); 
        }
        
        
        /*FOR RECORD TYPE*/   
        list<RecordType> cusRT=new list<RecordType>(); ar.CustomerRTList=new list<SelectOption>(); cusRT=[SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType='Account'];  for(RecordType r:cusRT) ar.CustomerRTList.add(new SelectOption(r.Id,r.Name));  list<RecordType> payRT=new list<RecordType>(); ar.PaymentRTList=new list<SelectOption>();   payRT=[SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType='ERP7__Payment__c' AND  (NOT DeveloperName Like '%_Posted')];  for(RecordType r:payRT) ar.PaymentRTList.add(new SelectOption(r.Id,r.Name)); //list<RecordType> couRT=new list<RecordType>();   ar.CouponRTList=new list<SelectOption>();     couRT=[SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType='ERP7__Coupon__c'];        for(RecordType r:couRT) ar.CouponRTList.add(new SelectOption(r.Id,r.Name));     
        
        ar.TODAY=System.today(); 
        return ar;   
    }   
    
    @AuraEnabled 
    public static list<Account> getCustomerRecords(){
        return [SELECT Id, Name, AccountNumber,ERP7__Payment_Terms__c,  ERP7__Paid_Amount__c, ERP7__Available_Credit_Balance__c
                ,ERP7__Total_Due__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Account_Type__c,ERP7__Organisation__r.ERP7__Account_Type__c
                FROM Account 
                WHERE (ERP7__Account_Type__c='Customer' AND ERP7__Organisation__r.ERP7__Account_Type__c='Organisation') Order By Name];
    }
    
    @AuraEnabled 
    public static Account getDefaultOrganisation(){
        return UtilClass.getOrganisationByLogin_Employee();
        /* List<Account> accs = new List<Account>();
            accs = [SELECT Id,Name FROM Account WHERE Account_Type__c = 'Organisation' AND default__c=true];
            if(accs.size()>0) return accs[0];
            return new Account();
        */
    } 
    
    
    @AuraEnabled 
    public static Boolean getFunctionalityControl(){
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){ 
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
        }
        if(customList != null){
            return customList.ERP7__Receivable_Debit_Notes__c;
        }
        return false;
    } 
    
    public class SelectOption {
        @AuraEnabled 
        public String value { get;set; }  
        @AuraEnabled
        public String label { get;set; }
        public SelectOption(String value, String label) {
            this.value = value;
            this.label = label;     
        } 
    }
    
    /*@AuraEnabled
    public static Boolean checkMultipleCurrency(){
        Boolean currencies=Schema.getGlobalDescribe().containsKey('CurrencyType');
        return currencies;
    }*/
    
    /*@AuraEnabled
    public static String currencyIso(String SalesorderId){
        Boolean currencies=Schema.getGlobalDescribe().containsKey('CurrencyType');
        if(currencies){
            String SO_Currency = (String)Database.Query('select CurrencyIsoCode from ERP7__Sales_Order__c where Id=:SalesorderId ')[0].get('CurrencyIsoCode');
            return SO_Currency;
        } 
        else{
           return null; 
        } 
    }*/
    @AuraEnabled 
    public static List<String> getFieldsSetApiName(String sObjectName,String fieldSetApiName){
        return UtilClass.getFieldsSetApiName(sObjectName, fieldSetApiName);
    } 
    @AuraEnabled 
    public static List<String> getFieldsSetLabelName(String sObjectName,String fieldSetApiName){
        return UtilClass.getFieldsSetLabelName(sObjectName, fieldSetApiName);
    }   
    
    @AuraEnabled
    public static Boolean checkPayment(String InvId){
        Decimal paidAmount=0.00;
        try{ 
        ERP7__Invoice__c inv=new ERP7__Invoice__c();
        inv=[select id,Name,ERP7__Invoice_Amount__c,RecordType.DeveloperName,ERP7__Total_Down_Payment_Amount__c from  ERP7__Invoice__c where Id=:InvId];
        List<Payment__c> payments=new List<Payment__c>();
        payments=[select id, Name, ERP7__Total_Amount__c,ERP7__Invoice__c from Payment__c where ERP7__Invoice__c=:InvId];
        if(payments.size()>0){
        for(Payment__c p : payments){
            if(p.ERP7__Total_Amount__c>0){
                paidAmount+=p.ERP7__Total_Amount__c;
            }
        }
        }
            if(inv.RecordType.DeveloperName=='Advance'){  if(inv.ERP7__Total_Down_Payment_Amount__c>paidAmount) return true;  else return false;
            }else{
        if(inv.ERP7__Invoice_Amount__c>paidAmount) return true;
        else return false;
        }
        }catch(Exception e){ return false; }
    }
}