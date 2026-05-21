Public with sharing class SupplierInvoice {
    @AuraEnabled
    public list<Account> CustomerList             {set;get;}
    //variable start for MultiOrderSingleInvoice
    @AuraEnabled
    public list<Order> OrderList     {set;get;}
    @AuraEnabled
    public list<ERP7__Sales_Order__c> SalesOrderList     {set;get;}
    @AuraEnabled
    public Boolean  is_StandardOrder                        {set;get;}
    //end
    @AuraEnabled
    public list<ERP7__Invoice__c> InvoiceList     {set;get;}
    @AuraEnabled
    public list<ERP7__Payment__c> PaymentList     {set;get;}
    @AuraEnabled
    public list<ERP7__Coupon__c> CouponList       {set;get;}
    @AuraEnabled
    public list<ERP7__Credit_Note__c> CreditList  {set;get;}
    @AuraEnabled
    public list<ERP7__Debit_Note__c>    DebitList             {set;get;}
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
    @AuraEnabled
    public list<ERP7__Invoice_Line_Item__c> InvoiceLines  {set;get;}



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
    public static List<ERP7__Invoice_Line_Item__c> getInvoiceLineItems2(String SOId,String Std_Id){
        List<ERP7__Invoice_Line_Item__c> invliList = new List<ERP7__Invoice_Line_Item__c>();
        if(String.isNotEmpty(SOId)){
            for(ERP7__Sales_Order_Line_Item__c soli:[SELECT Id, Name, ERP7__Active__c,ERP7__Tax__c,ERP7__Price_Book_Unit_Cost__c, ERP7__Allocate_Stock__c, ERP7__Asset__c, ERP7__Backorder_Quantity__c, ERP7__Base_Price__c, ERP7__Code__c,
                                                     ERP7__Cost__c, ERP7__Coupon__c, ERP7__Coupon_Redemption__c, ERP7__Discount_Amount__c, ERP7__Discount_Plan__c, ERP7__Duration__c, ERP7__Invoice__c, ERP7__Detailed_Description__c,
                                                     ERP7__Invoiced_Quantity__c, ERP7__Is_Pre_Order__c, ERP7__Is_Purchase_Order__c, ERP7__Name__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Organisation_Business_Unit__c,
                                                     ERP7__Price_Product__c, ERP7__PriceBook_Base_Price__c, ERP7__PriceBook_Total_Price__c, ERP7__PriceBookId__c, ERP7__Quantity__c, ERP7__ReturnAmount__c,
                                                     ERP7__Reserved_Date__c, ERP7__Reserved_Quantity__c,ERP7__ReturnedQuantity__c, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__Order_Line_Status__c,
                                                     ERP7__Sub_Total__c, ERP7__Total_Price__c,  ERP7__VAT_Amount__c, ERP7__VAT_Amount_Formula__c, ERP7__VAT_Percentage__c, ERP7__Product__c,
                                                     ERP7__Sort_Order__c, ERP7__Product__r.Name, ERP7__Description__c FROM ERP7__Sales_Order_Line_Item__c WHERE ERP7__Sales_Order__c=:SOId]){

                                                         if(soli.ERP7__Invoiced_Quantity__c ==null) soli.ERP7__Invoiced_Quantity__c=0.00;
                                                         if(soli.ERP7__Invoiced_Quantity__c < soli.ERP7__Quantity__c){
                                                             ERP7__Invoice_Line_Item__c tempinvli = new ERP7__Invoice_Line_Item__c(ERP7__Product__c=soli.ERP7__Product__c,ERP7__Base_Price__c = soli.Base_Price__c,ERP7__Sales_Order_Line_Item__c = soli.id);
                                                             tempinvli.ERP7__Sales_Order_Line_Item__r=new ERP7__Sales_Order_Line_Item__c(Id= soli.Id,ERP7__Quantity__c=soli.ERP7__Quantity__c,ERP7__Invoiced_Quantity__c=soli.ERP7__Invoiced_Quantity__c);
                                                             tempinvli.ERP7__Quantity__c= (soli.Quantity__c - soli.Invoiced_Quantity__c).setScale(2);
                                                             tempinvli.ERP7__Unit_Price__c =soli.ERP7__Price_Product__c;
                                                             tempinvli.ERP7__Tax_Rate__c=soli.ERP7__Tax__c;
                                                             tempinvli.ERP7__Description__c = soli.ERP7__Description__c;
                                                             tempinvli.ERP7__Account_COGS__c = true;
                                                             //tempinvli.ERP7__Sort_Order__c = soli.ERP7__Sort_Order__c;
                                                             tempinvli.ERP7__Detailed_Description__c = soli.ERP7__Detailed_Description__c;
                                                             tempinvli.ERP7__Discount_Amount__c=soli.ERP7__Discount_Amount__c==null?0:soli.ERP7__Discount_Amount__c;
                                                             tempinvli.ERP7__Sub_Total__c= (tempinvli.ERP7__Quantity__c * tempinvli.ERP7__Unit_Price__c).setScale(2);
                                                             tempinvli.ERP7__Base_Price__c= (tempinvli.ERP7__Quantity__c * tempinvli.ERP7__Unit_Price__c).setScale(2);
                                                             tempinvli.ERP7__VAT_Amount__c = ((soli.ERP7__VAT_Amount__c !=null)?soli.ERP7__VAT_Amount__c/soli.Quantity__c*tempinvli.Quantity__c : 0).setScale(2);
                                                             tempinvli.ERP7__Other_Tax__c = ((soli.ERP7__Other_Tax__c !=null)?soli.ERP7__Other_Tax__c/soli.Quantity__c*tempinvli.Quantity__c :0).setScale(2);
                                                             tempinvli.ERP7__Total_Price__c= (tempinvli.ERP7__Sub_Total__c + tempinvli.ERP7__Other_Tax__c + tempinvli.ERP7__VAT_Amount__c ).setScale(2);
                                                             if(soli.ERP7__Discount_Amount__c==null)soli.ERP7__Discount_Amount__c=0;
                                                             tempinvli.ERP7__Total_Price__c=tempinvli.ERP7__Total_Price__c-soli.ERP7__Discount_Amount__c;
                                                             tempinvli.ERP7__Price_Book_Unit_Cost__c =(soli.ERP7__Price_Book_Unit_Cost__c!=null)? soli.ERP7__Price_Book_Unit_Cost__c:0.00;
                                                             //tempinvli.ERP7__Cost_Price__c = (soli.ERP7__Cost__c!=null)? soli.ERP7__Cost__c:0.00;
                                                             invliList.add(tempinvli);
                                                         }
                                                     }

        }
        else if(String.isNotEmpty(Std_Id)){
            for(OrderItem soli:[SELECT Id, ERP7__Active__c,ERP7__Tax__c,ERP7__Price_Book_Unit_Cost__c, ERP7__Allocate_Stock__c, ERP7__Asset__c, ERP7__Base_Price__c,
                                ERP7__Cost__c, ERP7__Coupon__c, ERP7__Coupon_Redemption__c, ERP7__Discount_Amount__c, ERP7__Discount_Plan__c, ERP7__Invoice__c, ERP7__Detailed_Description__c,
                                ERP7__Invoiced_Quantity__c, ERP7__Is_Pre_Order__c, ERP7__Issue_Purchase_Order__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Organisation_Business_Unit__c,
                                ERP7__PriceBook_Base_Price__c, ERP7__PriceBook_Total_Price__c, ERP7__PriceBookId__c, Quantity, ERP7__ReturnAmount__c,
                                ERP7__Reserved_Date__c, ERP7__Reserved_Quantity__c,ERP7__ReturnedQuantity__c, OrderId, ERP7__Status__c, ERP7__Order_Line_Status__c,
                                ERP7__Sub_Total__c, ERP7__Total_Price__c,  Description, ERP7__VAT_Amount__c, ERP7__VAT_Amount_Formula__c, ERP7__VAT_Percentage__c, Product2Id,
                                ERP7__Sort_Order__c, Product2.Name,UnitPrice FROM OrderItem WHERE OrderId=:Std_Id]){

                                    if(soli.ERP7__Invoiced_Quantity__c ==null) soli.ERP7__Invoiced_Quantity__c=0.00;
                                    if(soli.ERP7__Invoiced_Quantity__c < soli.Quantity){
                                        ERP7__Invoice_Line_Item__c tempinvli = new ERP7__Invoice_Line_Item__c(ERP7__Product__c=soli.Product2Id,ERP7__Base_Price__c = soli.UnitPrice,ERP7__Order_Product__c = soli.id);
                                        tempinvli.ERP7__Order_Product__r=new OrderItem(Id= soli.Id,Quantity=soli.Quantity,ERP7__Invoiced_Quantity__c=soli.ERP7__Invoiced_Quantity__c);
                                        tempinvli.ERP7__Quantity__c= (soli.Quantity - soli.Invoiced_Quantity__c).setScale(2);
                                        tempinvli.ERP7__Unit_Price__c =soli.UnitPrice;
                                        tempinvli.ERP7__Tax_Rate__c=soli.ERP7__Tax__c;
                                        tempinvli.ERP7__Description__c = soli.Description;
                                        tempinvli.ERP7__Account_COGS__c = true;
                                        //tempinvli.ERP7__Sort_Order__c = soli.ERP7__Sort_Order__c;
                                        tempinvli.ERP7__Detailed_Description__c = soli.ERP7__Detailed_Description__c;
                                        tempinvli.ERP7__Discount_Amount__c=soli.ERP7__Discount_Amount__c==null?0:soli.ERP7__Discount_Amount__c;
                                        tempinvli.ERP7__Sub_Total__c= (tempinvli.ERP7__Quantity__c * tempinvli.ERP7__Unit_Price__c).setScale(2);
                                        tempinvli.ERP7__VAT_Amount__c = ((soli.ERP7__VAT_Amount__c !=null)?soli.ERP7__VAT_Amount__c/soli.Quantity*tempinvli.Quantity__c : 0).setScale(2);
                                        tempinvli.ERP7__Other_Tax__c = ((soli.ERP7__Other_Tax__c !=null)?soli.ERP7__Other_Tax__c/soli.Quantity*tempinvli.Quantity__c :0).setScale(2);
                                        tempinvli.ERP7__Total_Price__c= (tempinvli.ERP7__Sub_Total__c + tempinvli.ERP7__Other_Tax__c + tempinvli.ERP7__VAT_Amount__c ).setScale(2);
                                        if(soli.ERP7__Discount_Amount__c==null)soli.ERP7__Discount_Amount__c=0;
                                        tempinvli.ERP7__Total_Price__c=tempinvli.ERP7__Total_Price__c-soli.ERP7__Discount_Amount__c;
                                        tempinvli.ERP7__Price_Book_Unit_Cost__c =(soli.ERP7__Price_Book_Unit_Cost__c!=null)? soli.ERP7__Price_Book_Unit_Cost__c:0.00;
                                        //tempinvli.ERP7__Cost_Price__c = (soli.ERP7__Cost__c!=null)? soli.ERP7__Cost__c:0.00;
                                        invliList.add(tempinvli);
                                    }
                                }
        }

        return invliList;
    }

    //Method for MultiOrderSingleInvoice
    @AuraEnabled
    public static List<ERP7__Invoice_Line_Item__c> getMultiInvoiceLineItems(List<Id> SOIds,List<Id> Std_Ids){
        List<ERP7__Invoice_Line_Item__c> invliList = new List<ERP7__Invoice_Line_Item__c>();
        System.debug('SOIds'+SOIds.size());
        System.debug('Std_Ids'+Std_Ids.size());
        if(SOIds.size() >0){
            for(ERP7__Sales_Order_Line_Item__c soli:[SELECT Id, Name, ERP7__Active__c,ERP7__Tax__c,ERP7__Price_Book_Unit_Cost__c, ERP7__Allocate_Stock__c, ERP7__Asset__c, ERP7__Backorder_Quantity__c, ERP7__Base_Price__c, ERP7__Code__c,
                                                     ERP7__Cost__c, ERP7__Coupon__c, ERP7__Coupon_Redemption__c, ERP7__Discount_Amount__c, ERP7__Discount_Plan__c, ERP7__Duration__c, ERP7__Invoice__c, ERP7__Detailed_Description__c,
                                                     ERP7__Invoiced_Quantity__c, ERP7__Is_Pre_Order__c, ERP7__Is_Purchase_Order__c, ERP7__Name__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Organisation_Business_Unit__c,
                                                     ERP7__Price_Product__c, ERP7__PriceBook_Base_Price__c, ERP7__PriceBook_Total_Price__c, ERP7__PriceBookId__c, ERP7__Quantity__c, ERP7__ReturnAmount__c,
                                                     ERP7__Reserved_Date__c, ERP7__Reserved_Quantity__c,ERP7__ReturnedQuantity__c, ERP7__Sales_Order__c, ERP7__Status__c, ERP7__Order_Line_Status__c,
                                                     ERP7__Sub_Total__c, ERP7__Total_Price__c,  ERP7__VAT_Amount__c, ERP7__VAT_Amount_Formula__c, ERP7__VAT_Percentage__c, ERP7__Product__c,
                                                     ERP7__Sort_Order__c, ERP7__Product__r.Name, ERP7__Description__c FROM ERP7__Sales_Order_Line_Item__c WHERE ERP7__Sales_Order__c IN :SOIds]){

                                                         if(soli.ERP7__Invoiced_Quantity__c ==null) soli.ERP7__Invoiced_Quantity__c=0.00;
                                                         if(soli.ERP7__Invoiced_Quantity__c < soli.ERP7__Quantity__c){
                                                             ERP7__Invoice_Line_Item__c tempinvli = new ERP7__Invoice_Line_Item__c(ERP7__Product__c=soli.ERP7__Product__c,ERP7__Base_Price__c = soli.Base_Price__c,ERP7__Sales_Order_Line_Item__c = soli.id);
                                                             tempinvli.ERP7__Sales_Order_Line_Item__r=new ERP7__Sales_Order_Line_Item__c(Id= soli.Id,ERP7__Sales_Order__c=soli.ERP7__Sales_Order__c,ERP7__Quantity__c=soli.ERP7__Quantity__c,ERP7__Invoiced_Quantity__c=soli.ERP7__Invoiced_Quantity__c);
                                                             tempinvli.ERP7__Quantity__c= (soli.Quantity__c - soli.Invoiced_Quantity__c).setScale(2);
                                                             tempinvli.ERP7__Unit_Price__c =soli.ERP7__Price_Product__c;
                                                             tempinvli.ERP7__Tax_Rate__c=soli.ERP7__Tax__c;
                                                             tempinvli.ERP7__Description__c = soli.ERP7__Description__c;
                                                             //tempinvli.ERP7__Sort_Order__c = soli.ERP7__Sort_Order__c;
                                                             tempinvli.ERP7__Detailed_Description__c = soli.ERP7__Detailed_Description__c;
                                                             tempinvli.ERP7__Discount_Amount__c=soli.ERP7__Discount_Amount__c==null?0:soli.ERP7__Discount_Amount__c;
                                                             tempinvli.ERP7__Sub_Total__c= (tempinvli.ERP7__Quantity__c * tempinvli.ERP7__Unit_Price__c).setScale(2);
                                                             tempinvli.ERP7__Base_Price__c= (tempinvli.ERP7__Quantity__c * tempinvli.ERP7__Unit_Price__c).setScale(2);
                                                             tempinvli.ERP7__VAT_Amount__c = ((soli.ERP7__VAT_Amount__c !=null)?soli.ERP7__VAT_Amount__c/soli.Quantity__c*tempinvli.Quantity__c : 0).setScale(2);
                                                             tempinvli.ERP7__Other_Tax__c = ((soli.ERP7__Other_Tax__c !=null)?soli.ERP7__Other_Tax__c/soli.Quantity__c*tempinvli.Quantity__c :0).setScale(2);
                                                             tempinvli.ERP7__Total_Price__c= (tempinvli.ERP7__Sub_Total__c + tempinvli.ERP7__Other_Tax__c + tempinvli.ERP7__VAT_Amount__c ).setScale(2);
                                                             if(soli.ERP7__Discount_Amount__c==null)soli.ERP7__Discount_Amount__c=0;
                                                             tempinvli.ERP7__Total_Price__c=tempinvli.ERP7__Total_Price__c-soli.ERP7__Discount_Amount__c;
                                                             tempinvli.ERP7__Price_Book_Unit_Cost__c =(soli.ERP7__Price_Book_Unit_Cost__c!=null)? soli.ERP7__Price_Book_Unit_Cost__c:0.00;
                                                             //tempinvli.ERP7__Cost_Price__c = (soli.ERP7__Cost__c!=null)? soli.ERP7__Cost__c:0.00;
                                                             invliList.add(tempinvli);
                                                         }
                                                     }

        }
        else if(Std_Ids.size() >0){
            for(OrderItem soli:[SELECT Id, ERP7__Active__c,ERP7__Tax__c,ERP7__Price_Book_Unit_Cost__c, ERP7__Allocate_Stock__c, ERP7__Asset__c, ERP7__Base_Price__c,
                                ERP7__Cost__c, ERP7__Coupon__c, ERP7__Coupon_Redemption__c, ERP7__Discount_Amount__c, ERP7__Discount_Plan__c, ERP7__Invoice__c, ERP7__Detailed_Description__c,
                                ERP7__Invoiced_Quantity__c, ERP7__Is_Pre_Order__c, ERP7__Issue_Purchase_Order__c, ERP7__Organisation__c, ERP7__Other_Tax__c, ERP7__Organisation_Business_Unit__c,
                                ERP7__PriceBook_Base_Price__c, ERP7__PriceBook_Total_Price__c, ERP7__PriceBookId__c, Quantity, ERP7__ReturnAmount__c,
                                ERP7__Reserved_Date__c, ERP7__Reserved_Quantity__c,ERP7__ReturnedQuantity__c, OrderId, ERP7__Status__c, ERP7__Order_Line_Status__c,
                                ERP7__Sub_Total__c, ERP7__Total_Price__c,  Description, ERP7__VAT_Amount__c, ERP7__VAT_Amount_Formula__c, ERP7__VAT_Percentage__c, Product2Id,
                                ERP7__Sort_Order__c, Product2.Name,UnitPrice FROM OrderItem WHERE OrderId IN :Std_Ids]){

                                    if(soli.ERP7__Invoiced_Quantity__c ==null) soli.ERP7__Invoiced_Quantity__c=0.00;
                                    if(soli.ERP7__Invoiced_Quantity__c < soli.Quantity){
                                        ERP7__Invoice_Line_Item__c tempinvli = new ERP7__Invoice_Line_Item__c(ERP7__Product__c=soli.Product2Id,ERP7__Base_Price__c = soli.UnitPrice,ERP7__Order_Product__c = soli.id);
                                        tempinvli.ERP7__Order_Product__r=new OrderItem(Id= soli.Id,OrderId=soli.OrderId,Quantity=soli.Quantity,ERP7__Invoiced_Quantity__c=soli.ERP7__Invoiced_Quantity__c);
                                        tempinvli.ERP7__Quantity__c= (soli.Quantity - soli.Invoiced_Quantity__c).setScale(2);
                                        tempinvli.ERP7__Unit_Price__c =soli.UnitPrice;
                                        tempinvli.ERP7__Tax_Rate__c=soli.ERP7__Tax__c;
                                        tempinvli.ERP7__Description__c = soli.Description;
                                        //tempinvli.ERP7__Sort_Order__c = soli.ERP7__Sort_Order__c;
                                        tempinvli.ERP7__Detailed_Description__c = soli.ERP7__Detailed_Description__c;
                                        tempinvli.ERP7__Discount_Amount__c=soli.ERP7__Discount_Amount__c==null?0:soli.ERP7__Discount_Amount__c;
                                        tempinvli.ERP7__Sub_Total__c= (tempinvli.ERP7__Quantity__c * tempinvli.ERP7__Unit_Price__c).setScale(2);
                                        tempinvli.ERP7__VAT_Amount__c = ((soli.ERP7__VAT_Amount__c !=null)?soli.ERP7__VAT_Amount__c/soli.Quantity*tempinvli.Quantity__c : 0).setScale(2);
                                        tempinvli.ERP7__Other_Tax__c = ((soli.ERP7__Other_Tax__c !=null)?soli.ERP7__Other_Tax__c/soli.Quantity*tempinvli.Quantity__c :0).setScale(2);
                                        tempinvli.ERP7__Total_Price__c= (tempinvli.ERP7__Sub_Total__c + tempinvli.ERP7__Other_Tax__c + tempinvli.ERP7__VAT_Amount__c ).setScale(2);
                                        if(soli.ERP7__Discount_Amount__c==null)soli.ERP7__Discount_Amount__c=0;
                                        tempinvli.ERP7__Total_Price__c=tempinvli.ERP7__Total_Price__c-soli.ERP7__Discount_Amount__c;
                                        tempinvli.ERP7__Price_Book_Unit_Cost__c =(soli.ERP7__Price_Book_Unit_Cost__c!=null)? soli.ERP7__Price_Book_Unit_Cost__c:0.00;
                                        //tempinvli.ERP7__Cost_Price__c = (soli.ERP7__Cost__c!=null)? soli.ERP7__Cost__c:0.00;
                                        invliList.add(tempinvli);
                                    }
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
    public static String getCreateInvoiceAndLineItemUpdated(String Invoice, String InvoiceLineItem, String SO,String SOId,String StdId, String invType){
        ERP7__Invoice__c invs = new ERP7__Invoice__c();
        if(SO!=null && String.isNotEmpty(SOId)){
            try{ ERP7__Sales_Order__c salesorder = (ERP7__Sales_Order__c)JSON.deserialize(SO, ERP7__Sales_Order__c.class); if(Schema.sObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()){ upsert salesorder; } else{ /* no access */ } }catch(Exception e){ /*'Exception =>'*/ }
        }else if(SO!=null && String.isNotEmpty(StdId)){
            try{  Order salesorder = (Order)JSON.deserialize(SO, Order.class);  if(Schema.sObjectType.Order.isCreateable() && Schema.sObjectType.Order.isUpdateable()){ PreventRecursiveLedgerEntry.Loged = true;
                                                                                                                                                                       PreventRecursiveLedgerEntry.OrderTrigger = false;  upsert salesorder;} else{ /* no access*/} }catch(Exception e){ /*'Exception =>'*/  }
        }
        try{ invs  = (ERP7__Invoice__c)JSON.deserialize(Invoice, ERP7__Invoice__c.class); if(Schema.sObjectType.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.isUpdateable()){ upsert invs; } else{ /* no access */ } }catch(Exception e){ /*'Exception =>'*/ }

        List <ERP7__Invoice_Line_Item__c> InvoiceLIList = (List <ERP7__Invoice_Line_Item__c> ) JSON.deserialize(InvoiceLineItem, List <ERP7__Invoice_Line_Item__c> .class);
        for(Integer i = 0;i<InvoiceLIList.size();i++) {
            InvoiceLIList[i].ERP7__Invoice__c = invs.Id;
            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isUpdateable()){
                InvoiceLIList[i].ERP7__Sort_Order__c = i+1;

            } else{
                /* no access */
            }
        }

        if(InvoiceLIList.size() > 0 && Schema.sObjectType.ERP7__Invoice_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.isUpdateable()){ Upsert InvoiceLIList; } else{ /* no access */ }
        List<ERP7__Sales_Order_Line_Item__c> SOLIToUpdate=new List<ERP7__Sales_Order_Line_Item__c>();
        List<OrderItem> OrdItemToUpdate=new List<OrderItem>();
        for(ERP7__Invoice_Line_Item__c inv: InvoiceLIList){
            if(String.isNotEmpty(SOId) && invType != 'Advance') SOLIToUpdate.add(inv.ERP7__Sales_Order_Line_Item__r);
            if(String.isNotEmpty(StdId) && invType != 'Advance') OrdItemToUpdate.add(inv.ERP7__Order_Product__r);
            System.debug('inv.ERP7__Order_Product__r::~>'+inv.ERP7__Order_Product__r);
        }
        if(SOLIToUpdate.size()>0 && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()) { update SOLIToUpdate;}else{ /* no access*/ }
        if(OrdItemToUpdate.size()>0 && Schema.sObjectType.OrderItem.isUpdateable()) { PreventRecursiveLedgerEntry.testCasesTransactions = true; update OrdItemToUpdate; } else{/*no access*/ }
        return invs.Id;
    }
    //Method for MultiOrderSingleInvoice
    @AuraEnabled
    public static String getInvoiceName(String InvId){
        List<ERP7__Invoice__c> invlist = [Select Id, Name from ERP7__Invoice__c where Id=:InvId limit 1];
        return invlist[0].Name;
    }

    @AuraEnabled
    public static void getCreateInvoiceAndLineItem(String InvoiceLineItem, String SO,String SOId,String StdId, String invType){
        if(SO!=null && String.isNotEmpty(SOId)){
            try{ ERP7__Sales_Order__c salesorder = (ERP7__Sales_Order__c)JSON.deserialize(SO, ERP7__Sales_Order__c.class); if(Schema.sObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.isUpdateable()){ upsert salesorder; } else{ /* no access */ } }catch(Exception e){ /*'Exception =>'*/ }
        }else if(SO!=null && String.isNotEmpty(StdId)){
            try{  Order salesorder = (Order)JSON.deserialize(SO, Order.class);  if(Schema.sObjectType.Order.isCreateable() && Schema.sObjectType.Order.isUpdateable()){ upsert salesorder;} else{ /* no access*/} }catch(Exception e){ /*'Exception =>'*/  }
        }
        List <ERP7__Invoice_Line_Item__c> InvoiceLIList = (List <ERP7__Invoice_Line_Item__c> ) JSON.deserialize(InvoiceLineItem, List <ERP7__Invoice_Line_Item__c> .class);
        for(Integer i = 0;i<InvoiceLIList.size();i++) {if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sort_Order__c.isUpdateable()){InvoiceLIList[i].ERP7__Sort_Order__c = i+1; } else{/* no access */ } }

        if(InvoiceLIList.size() > 0 && Schema.sObjectType.ERP7__Invoice_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.isUpdateable()){ Upsert InvoiceLIList; } else{ /* no access */ }
        List<ERP7__Sales_Order_Line_Item__c> SOLIToUpdate=new List<ERP7__Sales_Order_Line_Item__c>();
        List<OrderItem> OrdItemToUpdate=new List<OrderItem>();
        for(ERP7__Invoice_Line_Item__c inv: InvoiceLIList){
            if(String.isNotEmpty(SOId) && invType != 'Advance') SOLIToUpdate.add(inv.ERP7__Sales_Order_Line_Item__r);
            if(String.isNotEmpty(StdId) && invType != 'Advance') OrdItemToUpdate.add(inv.ERP7__Order_Product__r);
            System.debug('inv.ERP7__Order_Product__r::~>'+inv.ERP7__Order_Product__r);
        }
        if(SOLIToUpdate.size()>0 && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()) { update SOLIToUpdate;}else{ /* no access*/ }  if(OrdItemToUpdate.size()>0 && Schema.sObjectType.OrderItem.isUpdateable()) { update OrdItemToUpdate; } else{/* no access*/ }
    }
    public class InvoiceWrap{
        @AuraEnabled  public List<ERP7__Invoice__c> schlst {get;set;}
        @AuraEnabled  public List<ERP7__Invoice__c> advlst {get;set;}
        @AuraEnabled  public List<ERP7__Invoice__c> saleslst {get;set;}
        public InvoiceWrap(){
            schlst = new List<ERP7__Invoice__c>();
            advlst = new List<ERP7__Invoice__c>();
            saleslst = new List<ERP7__Invoice__c>();
        }
    }
    @AuraEnabled
    public static InvoiceWrap scheduleInvoices(String orderId,String SorderId){
        InvoiceWrap inwrap = new InvoiceWrap();
        List<ERP7__Invoice__c> InvList =new List<ERP7__Invoice__c>();
        if(String.isNotEmpty(orderId)) InvList = [Select Id, ERP7__Paid_Amount_Returned__c, ERP7__Down_Payment__c,ERP7__Amount_Paid__c,ERP7__Total_Down_Payment_Amount__c,ERP7__Paid_Amount_Applied__c, ERP7__Credit_Note__c, Name, ERP7__Invoice_Amount__c, ERP7__Tax_Amount__c, ERP7__Sales_Invoice_Percentage__c, ERP7__Sales_Invoice_Tax_Percentage__c, ERP7__Sales_Order_Amount__c,RecordType.DeveloperName     from ERP7__Invoice__c where ERP7__Active__c = true and ERP7__Order__c =:orderId AND (RecordType.DeveloperName='Schedule_Invoice' OR  RecordType.DeveloperName='Advance' OR  RecordType.DeveloperName='Sale')];
        else if(String.isNotEmpty(SorderId)) InvList = [Select Id, ERP7__Paid_Amount_Returned__c, ERP7__Down_Payment__c,ERP7__Amount_Paid__c,ERP7__Total_Down_Payment_Amount__c,ERP7__Paid_Amount_Applied__c, ERP7__Credit_Note__c, Name, ERP7__Invoice_Amount__c, ERP7__Tax_Amount__c, ERP7__Sales_Invoice_Percentage__c, ERP7__Sales_Invoice_Tax_Percentage__c, ERP7__Sales_Order_Amount__c,RecordType.DeveloperName from ERP7__Invoice__c where ERP7__Active__c = true and ERP7__Order_S__c =:SorderId AND (RecordType.DeveloperName='Schedule_Invoice' OR  RecordType.DeveloperName='Advance'  OR  RecordType.DeveloperName='Sale')];
        if(InvList.size() > 0){
            for(ERP7__Invoice__c inv : InvList){
                if(inv.RecordType.DeveloperName == 'Schedule_Invoice'){
                    inwrap.schlst.add(inv);
                }else if(inv.RecordType.DeveloperName == 'Advance'){
                    inwrap.advlst.add(inv);
                }
                else if(inv.RecordType.DeveloperName == 'Sale'){
                    inwrap.saleslst.add(inv);
                }
            }
        }
        return inwrap;
    }

    @AuraEnabled
    public static Decimal fetchTotalDownPayment1(String orderId,String SorderId){

        List<ERP7__Invoice__c> INVcs =new List<ERP7__Invoice__c>();
        List<ERP7__Credit_Note__c> creditnotes =new List<ERP7__Credit_Note__c>();
        Decimal TD=0;

        try{
            if(String.isNotEmpty(orderId)) INVcs = [Select ERP7__Total_Down_Payment_Amount__c from ERP7__Invoice__c where ERP7__Active__c = true and ERP7__Order__c =:orderId AND RecordType.DeveloperName='Advance' ];
            else if(String.isNotEmpty(SorderId)) INVcs = [Select ERP7__Total_Down_Payment_Amount__c from ERP7__Invoice__c where ERP7__Active__c = true and ERP7__Order_S__c =:SorderId AND RecordType.DeveloperName='Advance' ];

            system.debug('INVcs-->'+INVcs.size());

            for(ERP7__Invoice__c inv : INVcs){
                system.debug('down-->'+inv.ERP7__Total_Down_Payment_Amount__c);
                if(inv.ERP7__Total_Down_Payment_Amount__c != null) TD = TD + inv.ERP7__Total_Down_Payment_Amount__c;
                //TD = TD + inv.ERP7__Total_Down_Payment_Amount__c!=null?inv.ERP7__Total_Down_Payment_Amount__c:0;
            }

            //(order related Adv INVc's totaldownpayment - all its related creditnotes) // for repligen 18-10-2022 Changes by Arshad
            Decimal TotalCreditAmt = 0;
            Boolean deductCreditAmt = false;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){  deductCreditAmt = FC.ERP7__Control_Total_Down_Payment__c; }

            if(deductCreditAmt && INVcs.size() > 0){
                creditnotes = [SELECT Id, ERP7__Credit__c,ERP7__Active__c,ERP7__Invoice__c FROM ERP7__Credit_Note__c Where ERP7__Invoice__c In: INVcs AND ERP7__Active__c = true AND ERP7__Credit__c > 0];
                for(ERP7__Credit_Note__c cr : creditnotes){
                    TotalCreditAmt =  TotalCreditAmt +  cr.ERP7__Credit__c;
                }
                if(TD > 0 && TotalCreditAmt > 0){
                    TD = TD - TotalCreditAmt;
                }
            }
            //

        }catch(Exception ex){
            system.debug('fetchTotalDownPayment1 Exception~>'+ex.getMessage()+' atline'+ex.getStackTraceString());
        }
        system.debug('TD-->'+TD);
        return TD;
    }

    @AuraEnabled
    public static ERP7__Sales_Order__c fetchOrderDetails(String orderId){
        return [SELECT Id,ERP7__Total_Shipping_Amount__c,ERP7__Sales_Order_Amount__c,ERP7__Contact__c,ERP7__Include_Shipping_Amount__c,ERP7__Shipping_VAT__c,ERP7__Amount_Paid__c,ERP7__Total_Tax_Amount__c,ERP7__Coupon_Discount__c,ERP7__Account__c,ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Organisation__c
                FROM ERP7__Sales_Order__c WHERE Id=:orderId];
    }
    @AuraEnabled
    public static Order fetchStndOrdDetails(String Std_Id){
        return [SELECT Id,ERP7__Total_Shipping_Amount__c,ERP7__Order_Amount__c,ERP7__Contact__c,ERP7__Include_Shipping_Amount__c,ERP7__Shipping_VAT__c,ERP7__Amount_Paid__c,ERP7__Total_Tax_Amount__c,ERP7__Coupon_Discount__c,AccountId,Account.ERP7__Payment_Terms__c, ERP7__Organisation__c
                FROM Order WHERE Id=:Std_Id];
    }
    //Method for MultiOrderSingleInvoice
    @AuraEnabled
    public static List<ERP7__Sales_Order__c> fetchMultiOrderDetails(List<Id> orderIds){
        return [SELECT Id,Name, ERP7__Total_Shipping_Amount__c,ERP7__Sales_Order_Amount__c,ERP7__Contact__c,ERP7__Include_Shipping_Amount__c,ERP7__Shipping_VAT__c,ERP7__Amount_Paid__c,ERP7__Total_Tax_Amount__c,ERP7__Coupon_Discount__c,ERP7__Account__c,ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Organisation__c
                FROM ERP7__Sales_Order__c WHERE Id IN :orderIds];
    }
    //Method for MultiOrderSingleInvoice
    @AuraEnabled
    public static List<Order> fetchMultiStndOrdDetails(List<Id> Std_Ids){
        return [SELECT Id,Name,ERP7__Total_Shipping_Amount__c,ERP7__Order_Amount__c,ERP7__Contact__c,ERP7__Include_Shipping_Amount__c,ERP7__Shipping_VAT__c,ERP7__Amount_Paid__c,ERP7__Total_Tax_Amount__c,ERP7__Coupon_Discount__c,AccountId,Account.ERP7__Payment_Terms__c, ERP7__Organisation__c
                FROM Order WHERE Id IN :Std_Ids];
    }

    @AuraEnabled
    public static SupplierInvoice getInvoiceRecordType(){
        try{
            SupplierInvoice ar=new SupplierInvoice();
            ar.InvoiceRTList=new list<SelectOption>();

            for(Schema.RecordTypeInfo sr : Schema.SObjectType.ERP7__Invoice__c.getRecordTypeInfosByName().values()){
                if(sr.isAvailable() && !sr.isMaster()){
                    ar.InvoiceRTList.add(new SelectOption(sr.getRecordTypeId()+'@'+sr.getDeveloperName(),sr.getName()));
                    //ar.InvoiceRTList.add(new SelectOption(sr.getRecordTypeId()+'@'+sr.getName(),sr.getName()));  commented as the name will get label that will be overiden by shaguftha on 20/2/23
                }
            }
            ar.InvoiceRecord=new ERP7__Invoice__c();
            return ar;
        }catch(Exception e){  /*'Exception e'+e+'Line Number'+e.getLineNumber()+'Cause'+e.getCause()*/ SupplierInvoice ar2=new SupplierInvoice();  return ar2; }
    }

    @AuraEnabled
    public static SupplierInvoice getInvoiceRecordTypeWithRecord(String InvoiceId){
        //try{
        SupplierInvoice ar=new SupplierInvoice();
        ar.InvoiceRTList=new list<SelectOption>();
        List<ERP7__Invoice__c> Invoices = [SELECT Id, Name, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c,ERP7__Status__c,RecordType.Name, RecordType.DeveloperName, RecordTypeId, ERP7__Account__c,ERP7__Account__r.Name,ERP7__Type__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c
                                           ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order_S__r.Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c , ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c
                                           ,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                                           FROM ERP7__Invoice__c
                                           WHERE Id =: InvoiceId];
        ar.InvoiceRecord = (Invoices.size() > 0)? Invoices[0] : new ERP7__Invoice__c();
        ar.InvoiceLines = (ar.InvoiceRecord.Id != Null)? getInvoiceLineItems(ar.InvoiceRecord.Id) : new List<ERP7__Invoice_Line_Item__c>();
        for(Schema.RecordTypeInfo sr : Schema.SObjectType.ERP7__Invoice__c.getRecordTypeInfosByName().values()){
            if(sr.isAvailable() && !sr.isMaster()){
                ar.InvoiceRTList.add(new SelectOption(sr.getRecordTypeId()+'@'+sr.getDeveloperName(),sr.getName()));
                //ar.InvoiceRTList.add(new SelectOption(sr.getRecordTypeId()+'@'+sr.getName(),sr.getName()));  commented as the name will get label that will be overiden by shaguftha on 20/2/23
            }
        }

        return ar;
        //}catch(Exception e){  /*'Exception e'+e+'Line Number'+e.getLineNumber()+'Cause'+e.getCause()*/ SupplierInvoice ar2=new SupplierInvoice();  return ar2; }
    }

    @AuraEnabled
    public static List<ERP7__Invoice_Line_Item__c> getInvoiceLineItems(String InvoiceId){
        //System.debug([SELECT Id, Name FROM ERP7__Invoice_Line_Item__c WHERE ERP7__Invoice__c=:SOId]);
        return [SELECT Id, Name, ERP7__Sales_Order_Line_Item__c, ERP7__Product__r.Name, ERP7__Quantity__c,ERP7__Order_Product__c,
                ERP7__Unit_Price__c, ERP7__Sub_Total__c, ERP7__Tax_Rate__c, ERP7__Discount_Amount__c,ERP7__VAT_Amount__c,
                ERP7__Total_Price__c, ERP7__Description__c, ERP7__Total_Tax__c FROM ERP7__Invoice_Line_Item__c WHERE ERP7__Invoice__c=:InvoiceId];
    }

    @AuraEnabled
    public static string getInvoiceRecordType1(){
        return 'String Return';
    }

    @AuraEnabled
    public static SupplierInvoice getInvoiceUpdate(String InvoiceId){
        SupplierInvoice ar=new SupplierInvoice();
        ERP7__Invoice__c inv=new ERP7__Invoice__c();
        ar.SaveErrorMsg='';   ar.Posted=true;  ar.InvoiceRecord=new ERP7__Invoice__c();
        if(String.isNotEmpty(InvoiceId)){
            try{
                inv=[SELECT Id, Name, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c,ERP7__Status__c,RecordType.Name,RecordTypeId, ERP7__Account__c,ERP7__Account__r.Name,ERP7__Type__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c
                     ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order_S__r.Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c , ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c
                     ,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                     FROM ERP7__Invoice__c
                     WHERE Id=:InvoiceId];
                if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isUpdateable()){ if(inv.ERP7__Posted__c) inv.ERP7__Posted__c=false;  else inv.ERP7__Posted__c=true; } else{ /* no access*/ }
                //Moin added this on 29th november
                if(inv.ERP7__Posted__c) inv.ERP7__Posted_Date__c = system.today();
                if(Schema.sObjectType.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.isUpdateable()){ upsert inv; } else{ /* no access*/ }
                ar.InvoiceRecord=inv;
                return ar;
            }catch(Exception ex){  ar.SaveErrorMsg=ex.getMessage();  ar.InvoiceRecord=null;   return ar;  }
        }
        return ar;
    }

    @AuraEnabled
    public static SupplierInvoice getPaymentUpdate(String PaymentId){
        SupplierInvoice ar=new SupplierInvoice();
        ERP7__Payment__c pay=new ERP7__Payment__c();
        ar.SaveErrorMsg='';   ar.Posted=true;  ar.PaymentRecord=new ERP7__Payment__c();
        if(String.isNotEmpty(PaymentId)){
            try{
                pay=[SELECT Id, Name, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name,ERP7__Order__r.Name, ERP7__Amount__c, ERP7__Status__c, ERP7__Type__c, ERP7__Account__c, ERP7__Account__r.Name,
                     RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c,ERP7__Sales_Order__r.ERP7__Account__r.Name,ERP7__Order__r.Account.Name
                     FROM ERP7__Payment__c
                     WHERE Id=:PaymentId];
                if(pay.ERP7__Posted__c){ if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() ){pay.ERP7__Posted__c = false;} else{ /* no access*/}
                                        //pay.ERP7__Posted_Date__c = date.today();
                                       }
                else{
                    if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable() ){pay.ERP7__Posted__c=true;} else{ /* no access*/} if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted_Date__c.isUpdateable()){pay.ERP7__Posted_Date__c = date.today();} else{ /*no acc*/}
                }
                if(Schema.sObjectType.ERP7__Payment__c.isCreateable() && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){ upsert pay;  } else{ /* no access */ }
                ar.PaymentRecord=pay;
            }catch(Exception ex){  ar.SaveErrorMsg=ex.getMessage();  ar.PaymentRecord=null;   return ar;  }
        }
        return ar;
    }

    @AuraEnabled
    public static SupplierInvoice getDebitUpdate(String debitID){
        SupplierInvoice ar=new SupplierInvoice();
        ERP7__Debit_Note__c deb=new ERP7__Debit_Note__c();
        ar.SaveErrorMsg='';   ar.Posted=true;  ar.debitRecord=new ERP7__Debit_Note__c();
        if(String.isNotEmpty(debitID)){
            try{
                deb=[SELECT Id, Name,ERP7__Account__c,ERP7__Account__r.Name, ERP7__Credit__c,ERP7__Debit__c,  ERP7__Posted__c, ERP7__Amount__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Organisation__r.ERP7__Account_Type__c FROM ERP7__Debit_Note__c
                     WHERE Id=:debitID];
                if(Schema.sObjectType.ERP7__Debit_Note__c.fields.ERP7__Posted__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note__c.fields.ERP7__Posted__c.isUpdateable()){
                    if(deb.ERP7__Posted__c){ deb.ERP7__Posted__c=false;
                                           }
                    else{
                        deb.ERP7__Posted__c=true;
                    }
                }else{ /*no acc */}
                if(Schema.sObjectType.ERP7__Debit_Note__c.isCreateable() && Schema.sObjectType.ERP7__Debit_Note__c.isUpdateable()){ upsert deb;  } else{ /* no access */}
                ar.debitRecord=deb;
            }catch(Exception ex){  ar.SaveErrorMsg=ex.getMessage();  ar.debitRecord=null;   return ar;  }
        }
        return ar;
    }

    @AuraEnabled
    public static SupplierInvoice getRecords(String orgId, String showTabs, String OrderBy, String Order, String[] selectedCustomersId,String[] selectInvoiceId,Integer Offset, Integer RecordLimit,String searchString, Integer Aging){
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        Integer Age = Integer.valueof(Aging);
        Integer StartAge = 0;
        system.debug('Age-->'+Age);
        if(Age == 30) StartAge = 0;
        else if(Age == 60) StartAge = 31;
        else if(Age == 90) StartAge = 61;
        else if(Age == 2000) StartAge = 91;
        else if(Age == -30) StartAge = 0;
        else if(Age == -60) StartAge = -31;
        else if(Age == -90) StartAge = -61;
        else if(Age == -2000) StartAge = -91;
        system.debug('StartAge-->'+StartAge);
        SupplierInvoice ar=new SupplierInvoice();
        try{
            list<String> scIds=new list<String>(); scIds.addAll(selectedCustomersId);
            list<String> invIds=new list<String>(); invIds.addAll(selectInvoiceId);

            String OrderByQyeryFilter='';
            String SelectedCustomersQuery='';
            String SelectedInvoicesQuery='';

            SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Account__c IN: scIds':'';
            SelectedInvoicesQuery = (invIds.size()>0)?' AND ERP7__Invoice__c IN: invIds':'';
            if(String.isNotEmpty(OrderBy) && String.isNotEmpty(Order)) OrderByQyeryFilter=' Order By '+OrderBy+' '+Order;

            String s= '%'+searchString+'%';
            if(showTabs=='cus'){
                String query='SELECT Id, Name,ERP7__Opening_Balance__c, AccountNumber,ERP7__Payment_Terms__c,ERP7__Credit_Balance__c,ERP7__Debit_Note_Balance__c,  ERP7__Paid_Amount__c, ERP7__Available_Credit_Balance__c,ERP7__Total_Due__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Account_Type__c,ERP7__Organisation__r.ERP7__Account_Type__c FROM Account  WHERE (ERP7__Account_Type__c=\'Customer\' OR ERP7__Account_Type__c=\'Customer / Vendor\') AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') ' ;
                if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name  asc limit 2000 ';
                if(String.isEmpty(orgId))query += '  order by Name  asc limit 2000 ';
                ar.CustomerList = Database.query(query);
                ar.recSize     =  ar.CustomerList.size();
                ar.CustomerListForSearch  = ar.CustomerList;
                query=null;
                query='SELECT Id, Name, AccountNumber,ERP7__Opening_Balance__c,ERP7__Payment_Terms__c,  ERP7__Paid_Amount__c,ERP7__Debit_Note_Balance__c,ERP7__Credit_Balance__c, ERP7__Available_Credit_Balance__c,ERP7__Total_Due__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Account_Type__c,ERP7__Organisation__r.ERP7__Account_Type__c FROM Account  WHERE (ERP7__Account_Type__c=\'Customer\' OR ERP7__Account_Type__c=\'Customer / Vendor\') AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') ' ;
                if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
                if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name limit :ikRecordLimit Offset :ikOffset ';
                if(String.isEmpty(orgId))query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
                ar.CustomerList = Database.query(query);
            }
            //code for MultiOrderSingleInvoice
            if(showTabs=='ord'){
                ar.is_StandardOrder = false;
                ar.is_StandardOrder = getFunctionalityControlOrderProcess();
                System.debug('OrderBy '+OrderBy);
                if(ar.is_StandardOrder){
                    SelectedCustomersQuery = (scIds.size()>0)?' AND AccountId IN: scIds':'';
                    list<Order> OrdList = new list<Order>();
                    String Orderquery = 'SELECT Id, OwnerId, ContractId, AccountId, Account.Name, Pricebook2Id, EffectiveDate, Status, Description, Type, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude, ShippingLongitude'
                        +',ShippingAddress, Name, PoDate, PoNumber, OrderReferenceNumber, BillToContactId, ShipToContactId, ActivatedDate, ActivatedById, StatusCode, OrderNumber, TotalAmount, CreatedDate, CreatedById, IsDeleted, ERP7__Active__c, ERP7__Barcode__c, ERP7__Bill_To_Address__c, ERP7__Contact__c, ERP7__Customer_Name__c, ERP7__Customer_Purchase_Order_Reference__c, ERP7__Expected_Date__c, ERP7__Is_Back_Order__c, ERP7__Is_Closed__c, ERP7__Logistic__c, ERP7__Order_Profile__c, ERP7__Ready_To_Pick_Pack__c, ERP7__Ship_To_Address__c'
                        +',ERP7__Ship_From_Address__c, ERP7__UPS_Service__c, ERP7__Shipment_Type__c, ERP7__Special_Instructions__c, ERP7__Stage__c, ERP7__Tax_Exempted__c, ERP7__Total_Quantity__c, ERP7__Tracking_Number__c, ERP7__Issue_Invoice__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Total_Shipping_Amount__c, ERP7__Total_Due__c, ERP7__Shipping_VAT__c, ERP7__Shipping_Discount__c, ERP7__ReturnAmount__c, ERP7__Coupon_Discount__c, ERP7__Product_Coupon_Discount__c, ERP7__Order_Amount__c, ERP7__Is_Invoice_Sent__c, ERP7__Issue_Warranty__c, ERP7__Channel__c, ERP7__Shipping_Tax__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c'
                        +',ERP7__Total_Other_Tax__c, ERP7__Total_Vat__c, ERP7__Total_Tax_Amount__c, ERP7__Is_Pre_Order__c, ERP7__Cost_Price__c, ERP7__Logistic_Cost__c, ERP7__Amount__c, ERP7__Amount_Paid__c, ERP7__Authorised__c, ERP7__Autocomplete__c, ERP7__Book_Date__c, ERP7__Back_Order_Items__c, ERP7__Booked__c, ERP7__Cancelled_Date__c, ERP7__Cancelled_Reason__c, ERP7__Code__c, ERP7__Customer_Email__c, ERP7__Customer_Purchase_Order_Date__c, ERP7__Due_Amount__c, ERP7__E_Order_Id__c, ERP7__Employee__c, ERP7__Employee_Email__c, ERP7__Estimated_Delivery_Date__c, ERP7__Estimated_Delivery_Month__c, ERP7__Estimated_Shipping_Amount__c, ERP7__Fulfilled__c'
                        +',ERP7__Fulfilled_Date__c, ERP7__Include_Shipping_Amount__c, ERP7__Loyalty_Amount__c, ERP7__Loyalty_Points__c, ERP7__Name__c, ERP7__Name_Link__c, ERP7__Number_of_Back_Order_Items__c, ERP7__Number_of_Fulfilled_Items__c, ERP7__Total_Logistic_Quantity_U__c, ERP7__Quotes__c, ERP7__Source__c, ERP7__Pre_Order_Items__c, ERP7__Project__c, ERP7__Tasks__c, ERP7__Picked_Quantity__c, ERP7__Shipped_Quantity__c, ERP7__Payments_Status__c, ERP7__Payment_Method__c, ERP7__Payment_Mode__c, ERP7__Redeem_Voucher_Amount__c, ERP7__Total_Number_of_Items__c, ERP7__Payment_Terms__c, ERP7__Type__c, ERP7__Subscription__c'
                        +',ERP7__Ready_To_Receive__c, ERP7__Ready_To_Ship__c, ERP7__Packed_Quantity__c, ERP7__Request_Date__c, ERP7__Tax_Percent__c, ERP7__TotalDiscount__c, ERP7__Customer_Id__c, ERP7__Coupon_Discount_Quantity__c, ERP7__MarketplaceId__c, ERP7__SalesChannel__c, ERP7__Unique_Id__c, ERP7__Sync_Status__c, ERP7__Is_Status_Equal__c, ERP7__Order_Discount__c, ERP7__Order_Discount_Description__c, ERP7__Sync_Currency__c, ERP7__Sync_Total_Tax__c, ERP7__Shipment_Preference_Speed__c, ERP7__Return_Tracking_Number__c, ERP7__Bill_To_Return__c FROM Order WHERE ERP7__Active__c=true AND Status!=\'Cancelled\' And ERP7__Due_Amount__c>0 And (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')';
                    if(searchString!=null && searchString!='')Orderquery += ' AND (Name Like :s OR Account.Name Like :s) ';
                    if(String.isNotEmpty(orgId))Orderquery += ' AND ERP7__Organisation__c=:orgId ';
                    if(String.isNotEmpty(SelectedCustomersQuery))Orderquery +=SelectedCustomersQuery;
                    if(String.isEmpty(OrderBy))Orderquery += ' order by CreatedDate desc ';
                    if(String.isNotEmpty(OrderBy))Orderquery += '  order by '+OrderBy+' '+Order;
                    String Order2query = Orderquery;
                    Orderquery+=' limit 2000 ';
                    OrdList = Database.query(Orderquery);
                    ar.recSize = OrdList.size();
                    Order2query += ' limit :ikRecordLimit Offset :ikOffset';
                    OrdList = Database.query(Order2query);
                    ar.OrderList = OrdList;
                }else{
                    SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Account__c IN: scIds':'';
                    list<ERP7__Sales_Order__c> SalesList=new list<ERP7__Sales_Order__c>();
                    String Salesquery = 'SELECT Id, Name, ERP7__Account__r.Id, ERP7__Account__r.Name, ERP7__Expected_Date__c, ERP7__Active__c, ERP7__Amount__c, ERP7__Barcode__c, ERP7__Customer_Email__c, ERP7__Customer_Purchase_Order_Date__c, ERP7__Employee_Email__c, ERP7__Hold_Status__c, ERP7__Is_Back_Order__c, ERP7__Is_Invoice_Sent__c, ERP7__Loyalty_Amount__c, ERP7__Loyalty_Points__c, ERP7__Name_Link__c, ERP7__Name__c, ERP7__Order_Date__c, ERP7__Order_Status__c, ERP7__Payment_Mode__c, ERP7__Purchase_Order_Number__c'
                        +', ERP7__Request_Date__c, ERP7__Special_Instructions__c, ERP7__Status_TimeStamp__c, ERP7__Status__c, ERP7__Code__c, ERP7__Bill_To_Address__c, ERP7__Contact__c, ERP7__Customer_Name__c, ERP7__Organisation_Business_Unit__c, ERP7__Organisation__c, ERP7__Payment_Method__c, ERP7__Channel__c, ERP7__Ship_To_Address__c, ERP7__Status_Duration__c, ERP7__Total_Tax_Amount__c, ERP7__Authorised__c, ERP7__Sub_Total__c, ERP7__Total_Discount__c, ERP7__Total_Due__c, ERP7__Total_Other_Tax__c, ERP7__Total_Vat__c, ERP7__Ready_To_Receive__c, ERP7__Employee_Name__c, ERP7__Employees__c, ERP7__Shipment_Type__c, ERP7__Ready_To_Pick_Pack__c'
                        +', ERP7__Subscription__c, ERP7__Customer_Id__c, ERP7__Due_Amount__c, ERP7__Payments_Status__c, ERP7__Sales_Order_Amount__c, ERP7__Fulfilled__c, ERP7__Ready_To_Ship__c, ERP7__Number_of_Back_Order_Items__c, ERP7__Total_Shipping_Amount__c, ERP7__Redeem_Voucher_Amount__c, ERP7__Amount_Paid__c, ERP7__Is_Pre_Order__c, ERP7__Number_of_Fulfilled_Items__c, ERP7__Total_Number_of_Items__c, ERP7__Estimated_Delivery_Date__c, ERP7__Fulfilled_Date__c, ERP7__Estimated_Delivery_Month__c, ERP7__Is_Converted__c, ERP7__Is_Closed__c, ERP7__Account__c, ERP7__ReturnAmount__c, ERP7__RMALines_to_Process__c, ERP7__Total_Quantity__c, ERP7__Picked_Quantity__c'
                        +', ERP7__Packed_Quantity__c, ERP7__Quotes__c, ERP7__Shipped_Quantity__c, ERP7__Shipping_VAT__c, ERP7__Estimated_Shipping_Amount__c, ERP7__UPS_Service__c, ERP7__Order_Profile__c, ERP7__Description__c, ERP7__Coupon_Discount__c, ERP7__Source__c, ERP7__EOrder_Id__c, ERP7__Shipping_Discount__c, ERP7__Cancelled_Reason__c, ERP7__Ship_From_Address__c, ERP7__Cost_Price__c, ERP7__Logistic_Cost__c, ERP7__Back_Order_Items__c, ERP7__Pre_Order_Items__c, ERP7__Product_Coupon_Discount__c, ERP7__Issue_Invoice__c, ERP7__TotalDiscount__c, ERP7__Coupon_Discount_Quantity__c, ERP7__Shipping_Tax__c, ERP7__Logistic__c'
                        +', ERP7__Autocomplete__c, ERP7__Issue_Warranty__c, ERP7__Booked__c, ERP7__Payment_Terms__c, ERP7__Type__c, ERP7__Shipped_QuantityR__c, ERP7__Include_Shipping_Amount__c, ERP7__Project__c, ERP7__Total_Logistic_Quantity__c, ERP7__Tasks__c, ERP7__Cancelled_Date__c, ERP7__Tax_Percent__c, ERP7__Order_Discount__c, ERP7__Order_Discount_Description__c, ERP7__Refund_Amount__c, ERP7__Allocate_Order_Specific_Stocks__c, ERP7__Tax_Exempted__c FROM ERP7__Sales_Order__c WHERE ERP7__Active__c=true AND ERP7__Total_Due__c !=0 AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')';
                    if(searchString!=null && searchString!='')Salesquery += ' AND (Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                    if(String.isNotEmpty(orgId))Salesquery += ' AND ERP7__Organisation__c=:orgId ';
                    if(String.isNotEmpty(SelectedCustomersQuery))Salesquery +=SelectedCustomersQuery;
                    if(String.isEmpty(OrderBy))Salesquery += ' order by CreatedDate desc ';
                    if(String.isNotEmpty(OrderBy))Salesquery += '  order by '+OrderBy+' '+Order;
                    String Sales2query = Salesquery;
                    Salesquery+=' limit 2000 ';
                    SalesList = Database.query(Salesquery);
                    ar.recSize = SalesList.size();
                    Sales2query += ' limit :ikRecordLimit Offset :ikOffset';
                    SalesList = Database.query(Sales2query);
                    ar.SalesOrderList = SalesList;
                }
            }
            //end

            if(showTabs=='inv'){
                SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Account__c IN:scIds':'';
                list<ERP7__Invoice__c> InvList=new list<ERP7__Invoice__c>();
                if(Age>0){
                    if(String.isEmpty(orgId)){
                        String invoiceQuery='SELECT Id, ERP7__Paid__c, CreatedDate,Name,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Order_S__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                            ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                            ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false AND ERP7__Total_Due__c !=0  AND ERP7__Due_date_days__c<=:Age AND ERP7__Due_date_days__c>=:StartAge AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                        if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                        if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                        InvList=Database.query(invoiceQuery);
                        ar.InvoiceListForSearch = InvList;
                        ar.recSize     =  InvList.size();
                        invoiceQuery='SELECT Id, Name, CreatedDate, ERP7__Account__r.Name,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                            ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                            ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<=:Age  AND ERP7__Due_date_days__c>=:StartAge  AND ERP7__Total_Due__c !=0  AND  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                        if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                        if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                        InvList=Database.query(invoiceQuery);
                        ar.InvoiceList=InvList;
                    }else{
                        if(String.isEmpty(OrderBy)){
                            String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<=:Age  AND ERP7__Due_date_days__c>=:StartAge AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isNotEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceListForSearch = InvList;
                            ar.recSize     =  InvList.size();
                            invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<=:Age  AND ERP7__Due_date_days__c>=:StartAge AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\'OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isNotEmpty(orgId))invoiceQuery += ' order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceList=InvList;
                        }else{
                            String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<=:Age  AND ERP7__Due_date_days__c>=:StartAge  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' Or  ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                            if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit 2000';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceListForSearch = InvList;
                            ar.recSize     =  InvList.size();
                            invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Due_date_days__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<=:Age  AND ERP7__Due_date_days__c>=:StartAge AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit :ikRecordLimit Offset :ikOffset';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceList=InvList;
                        }
                    }
                }else if(Age<0){
                    if(Age != -1){
                        if(String.isEmpty(orgId)){
                            String invoiceQuery='SELECT Id, ERP7__Paid__c, CreatedDate,Name,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Order_S__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false AND ERP7__Total_Due__c !=0  AND ERP7__Due_date_days__c>=:Age AND ERP7__Due_date_days__c<=:StartAge AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceListForSearch = InvList;
                            ar.recSize     =  InvList.size();
                            invoiceQuery='SELECT Id, Name, CreatedDate, ERP7__Account__r.Name,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c>=:Age  AND ERP7__Due_date_days__c<=:StartAge  AND ERP7__Total_Due__c !=0  AND  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                            if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceList=InvList;
                        }else{
                            if(String.isEmpty(OrderBy)){
                                String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c>=:Age  AND ERP7__Due_date_days__c<=:StartAge AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                                if(String.isNotEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceListForSearch = InvList;
                                ar.recSize     =  InvList.size();
                                invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c>=:Age  AND ERP7__Due_date_days__c<=:StartAge AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\'OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                                if(String.isNotEmpty(orgId))invoiceQuery += ' order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceList=InvList;
                            }else{
                                String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c>=:Age  AND ERP7__Due_date_days__c<=:StartAge  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' Or  ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                                if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit 2000';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceListForSearch = InvList;
                                ar.recSize     =  InvList.size();
                                invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Due_date_days__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c>=:Age  AND ERP7__Due_date_days__c<=:StartAge AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                                if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit :ikRecordLimit Offset :ikOffset';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceList=InvList;
                            }
                        }
                    }else{
                        if(String.isEmpty(orgId)){
                            String invoiceQuery='SELECT Id, CreatedDate,Name,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Order_S__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceListForSearch = InvList;
                            ar.recSize     =  InvList.size();
                            invoiceQuery='SELECT Id, Name, CreatedDate, ERP7__Account__r.Name,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Total_Due__c !=0  AND  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                            if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceList=InvList;
                        }else{
                            if(String.isEmpty(OrderBy)){
                                String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                                if(String.isNotEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceListForSearch = InvList;
                                ar.recSize     =  InvList.size();
                                invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true AND ERP7__Paid__c=false  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                                if(String.isNotEmpty(orgId))invoiceQuery += ' order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceList=InvList;
                            }else{
                                String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\' ) AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                                if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit 2000';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceListForSearch = InvList;
                                ar.recSize     =  InvList.size();
                                invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                    ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Due_date_days__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                    ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                                if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                                if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit :ikRecordLimit Offset :ikOffset';
                                InvList=Database.query(invoiceQuery);
                                ar.InvoiceList=InvList;
                            }
                        }
                    }
                }else{
                    if(String.isEmpty(orgId)){
                        String invoiceQuery='SELECT Id, CreatedDate,Name,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Order_S__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                            ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                            ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Total_Due__c !=0  AND ERP7__Due_date_days__c<:Age AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                        if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                        if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                        InvList=Database.query(invoiceQuery);
                        ar.InvoiceListForSearch = InvList;
                        ar.recSize     =  InvList.size();
                        invoiceQuery='SELECT Id, Name, CreatedDate, ERP7__Account__r.Name,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                            ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                            ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<:Age AND ERP7__Total_Due__c !=0  AND  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                        if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                        if(String.isEmpty(orgId))invoiceQuery += '  order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                        InvList=Database.query(invoiceQuery);
                        ar.InvoiceList=InvList;
                    }else{
                        if(String.isEmpty(OrderBy)){
                            String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,ERP7__Status__c, ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false AND ERP7__Due_date_days__c<:Age  AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isNotEmpty(orgId))invoiceQuery += '  order by CreatedDate  desc limit 2000 ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceListForSearch = InvList;
                            ar.recSize     =  InvList.size();
                            invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<:Age   AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isNotEmpty(orgId))invoiceQuery += ' order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceList=InvList;
                        }else{
                            String invoiceQuery='SELECT Id, Name,CreatedDate,ERP7__Account__r.Name, RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Due_date_days__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Invoice_Date__c, ERP7__Name__c,ERP7__Order_S__c, ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true   AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<:Age AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                            if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit 2000';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceListForSearch = InvList;
                            ar.recSize     =  InvList.size();
                            invoiceQuery='SELECT Id, Name,ERP7__Account__r.Name, CreatedDate,RecordType.Name,RecordType.DeveloperName,toLabel(ERP7__Status__c), ERP7__Active__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c,ERP7__Order_S__r.ERP7__Due_Amount__c, ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Total_Discount__c'+
                                ' ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Due_date_days__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order_S__c,ERP7__Order__c,ERP7__Order_S__r.Status, ERP7__Order__r.ERP7__Status__c, ERP7__Account__r.ERP7__Payment_Terms__c,ERP7__Order_S__r.EffectiveDate, ERP7__Order__r.ERP7__Order_Date__c, ERP7__Due_Date__c'+
                                ',ERP7__Order_Number__c, ERP7__Organisation__c,ERP7__Order_S__r.Name, ERP7__Order__r.Name, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c FROM ERP7__Invoice__c  WHERE ERP7__Active__c=true  AND ERP7__Paid__c=false  AND ERP7__Due_date_days__c<:Age   AND ERP7__Total_Due__c !=0  AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                            if(searchString!=null && searchString!='')invoiceQuery += ' AND (Name Like :s OR ERP7__Order__r.Name Like :s OR ERP7__Account__r.Name Like :s)  ';
                            if(String.isNotEmpty(orgId))invoiceQuery += '  order by '+OrderBy+' '+Order + ' limit :ikRecordLimit Offset :ikOffset';
                            InvList=Database.query(invoiceQuery);
                            ar.InvoiceList=InvList;
                        }
                    }
                }
            }
            if(showTabs=='pay'){

                SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Accounts__c IN: scIds':'';
                String invStr=''; invStr=(scIds.size()>0)?' AND ERP7__Account__c IN: scIds':'';
                SelectedInvoicesQuery = (invIds.size()>0)?' AND ERP7__Invoice__c IN: invIds':'';

                if(String.isEmpty(orgId)) {
                    list<ERP7__Payment__c> PaymentList=new list<ERP7__Payment__c>();

                    String PaymentQuery='SELECT Id, Name, CreatedDate, ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name, ERP7__Order__r.Name, ERP7__Amount__c, toLabel(ERP7__Status__c), toLabel(ERP7__Type__c), ERP7__Account__c, ERP7__Account__r.Name,'+
                        'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Sales_Order__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Posted_Date__c, ERP7__Accounts__c, ERP7__Payment_Date__c, ERP7__Accounts__r.Name'+
                        ' FROM ERP7__Payment__c WHERE ERP7__Account__c=Null AND  ERP7__Invoice__c!=Null AND (ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 OR ERP7__Order__r.ERP7__Due_Amount__c>0)   '+invStr;//+OrderByQyeryFilter;
                    if(searchString!=null && searchString!='')PaymentQuery += ' AND (Name Like :s OR ERP7__Invoice__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                    if(String.isEmpty(orgId))PaymentQuery += '  order by CreatedDate  desc limit 2000 ';
                    PaymentList=Database.query(PaymentQuery);
                    ar.PaymentListForSearch = PaymentList;
                    ar.recSize     =  ar.PaymentListForSearch.size();
                    PaymentQuery='SELECT Id, Name, ERP7__Invoice__c,CreatedDate,ERP7__Invoice__r.Name, ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Payment_Date__c, ERP7__Sales_Order__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Sales_Order__r.Name, ERP7__Order__r.Name, ERP7__Amount__c, toLabel(ERP7__Status__c), toLabel(ERP7__Type__c), ERP7__Account__c, ERP7__Account__r.Name,'+
                        'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Accounts__c, ERP7__Accounts__r.Name'+
                        ' FROM ERP7__Payment__c WHERE  ERP7__Accounts__c=Null AND ERP7__Invoice__c!=Null AND (ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 OR ERP7__Order__r.ERP7__Due_Amount__c>0) '+invStr;//+OrderByQyeryFilter;
                    if(searchString!=null && searchString!='')PaymentQuery += ' AND (Name Like :s OR ERP7__Invoice__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                    if(String.isEmpty(orgId))PaymentQuery += ' order by CreatedDate desc limit :ikRecordLimit Offset :ikOffset ';
                    ar.PaymentList=Database.query(PaymentQuery);
                }
                else{
                    list<ERP7__Payment__c> PaymentList=new list<ERP7__Payment__c>();

                    String PaymentQuery='SELECT Id, Name, ERP7__Invoice__c,CreatedDate,ERP7__Invoice__r.Name, ERP7__Sales_Order__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Payment_Date__c, ERP7__Sales_Order__r.Name,ERP7__Order__r.Name, ERP7__Amount__c, toLabel(ERP7__Status__c), toLabel(ERP7__Type__c), ERP7__Account__c, ERP7__Account__r.Name,'+
                        'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c , ERP7__Accounts__c, ERP7__Sales_Order__r.ERP7__Account__r.Name,ERP7__Order__r.Account.Name, ERP7__Accounts__r.Name'+
                        ' FROM ERP7__Payment__c  WHERE ERP7__Accounts__c!=Null  AND ERP7__Invoice__c!=Null AND (ERP7__Account__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Account__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Account__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery+SelectedInvoicesQuery;//+OrderByQyeryFilter;  //AND (ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 OR ERP7__Order__r.ERP7__Due_Amount__c>0)
                    if(searchString!=null && searchString!='')PaymentQuery += ' AND (Name Like :s OR ERP7__Invoice__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                    if(String.isNotEmpty(orgId))PaymentQuery += '  order by CreatedDate  desc limit 2000 ';
                    PaymentList=Database.query(PaymentQuery);
                    ar.PaymentListForSearch = PaymentList;
                    ar.recSize     =  PaymentList.size();

                    PaymentQuery='SELECT Id, Name, ERP7__Invoice__c,CreatedDate,ERP7__Invoice__r.Name, ERP7__Sales_Order__r.ERP7__Due_Amount__c,ERP7__Order__r.ERP7__Due_Amount__c, ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name,ERP7__Order__r.Name, ERP7__Amount__c, toLabel(ERP7__Status__c), toLabel(ERP7__Type__c), ERP7__Account__c, ERP7__Account__r.Name,'+
                        'RecordTypeId, RecordType.Name,RecordType.DeveloperName, ERP7__Posted__c, ERP7__Posted_Date__c , ERP7__Payment_Date__c, ERP7__Accounts__c, ERP7__Sales_Order__r.ERP7__Account__r.Name,ERP7__Order__r.Account.Name, ERP7__Accounts__r.Name'+
                        ' FROM ERP7__Payment__c  WHERE ERP7__Accounts__c!=Null AND ERP7__Invoice__c!=Null AND (ERP7__Account__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Account__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Account__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery+SelectedInvoicesQuery;//+OrderByQyeryFilter;  // AND (ERP7__Sales_Order__r.ERP7__Due_Amount__c>0 OR ERP7__Order__r.ERP7__Due_Amount__c>0)
                    if(searchString!=null && searchString!='')PaymentQuery += ' AND (Name Like :s OR ERP7__Invoice__r.Name Like :s OR ERP7__Account__r.Name Like :s) ';
                    if(String.isNotEmpty(orgId))PaymentQuery += '  order by '+OrderBy+' '+Order + ' limit :ikRecordLimit Offset :ikOffset';
                    ar.PaymentList=Database.query(PaymentQuery);
                }


            }

            if(showTabs=='cre'){
                SelectedCustomersQuery = (scIds.size()>0)?' AND ERP7__Account__c IN: scIds':'';
                if(String.isEmpty(orgId)){
                    String CreditQuery='SELECT ERP7__Date__c,Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                        ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                        ',ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name ,ERP7__Order__r.Name,ERP7__Account__r.Name'+
                        ' FROM ERP7__Credit_Note__c'+
                        ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                    if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                    if(String.isEmpty(orgId))CreditQuery += '  order by Name  asc limit 2000 ';
                    ar.CreditList=Database.query(CreditQuery);
                    ar.CreditListForSearch = ar.CreditList;
                    ar.recSize     =  ar.CreditListForSearch.size();
                    CreditQuery='SELECT ERP7__Date__c, Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                        ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                        ',ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name ,ERP7__Order__r.Name,ERP7__Account__r.Name'+
                        ' FROM ERP7__Credit_Note__c'+
                        ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery;//+OrderByQyeryFilter;
                    if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                    if(String.isEmpty(orgId))CreditQuery += ' order by Name limit :ikRecordLimit Offset :ikOffset ';
                    ar.CreditList=Database.query(CreditQuery);
                }
                else{
                    String CreditQuery='SELECT ERP7__Date__c, Id, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                        ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                        ',ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name ,ERP7__Order__r.Name,ERP7__Account__r.Name'+
                        ' FROM ERP7__Credit_Note__c'+
                        ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
                    if(searchString!=null && searchString!='')CreditQuery += ' AND Name Like :s ';
                    if(String.isNotEmpty(orgId))CreditQuery += '  order by Name  asc limit 2000 ';
                    ar.CreditList=Database.query(CreditQuery);
                    ar.CreditListForSearch = ar.CreditList;
                    ar.recSize     =  ar.CreditList.size();
                    CreditQuery='SELECT Id, ERP7__Date__c, Name, ERP7__Account__c, ERP7__Active__c,  ERP7__Credit__c, ERP7__Debit__c, ERP7__Applied_Date__c, ERP7__Coupon_Redemption__c, ERP7__Coupon_Redemption__r.Name'+
                        ',ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Payment__c, ERP7__Payment__r.Name, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name'+
                        ',ERP7__Sales_Order__c,ERP7__Order__c, ERP7__Sales_Order__r.Name ,ERP7__Order__r.Name,ERP7__Account__r.Name'+
                        ' FROM ERP7__Credit_Note__c'+
                        ' WHERE ERP7__Active__c=true AND (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisation__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery;//+OrderByQyeryFilter;
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
                        ' WHERE ERP7__Invoice__c!=Null AND ERP7__Customer__c!=Null AND (ERP7__Organisations__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisations__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\')'+SelectedCustomersQuery+OrderByQyeryFilter;
                    ar.DunningList=Database.query(DunningList);
                }

                else{
                    String DunningList='SELECT Id, Name, ERP7__Invoice__c, ERP7__Invoice__r.Name, ERP7__Invoice__r.ERP7__Due_Date__c,ERP7__Status__c, ERP7__Supplier_Used__c, ERP7__Supplier_Used__r.Name, ERP7__Customer__r.Name, ERP7__Dunning_Applied_Date__c,ERP7__Organisations__c, ERP7__Organisations__r.Name'+
                        ' FROM ERP7__Dunning__c'+
                        ' WHERE ERP7__Invoice__c!=Null AND ERP7__Customer__c!=Null AND (ERP7__Organisations__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisations__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') AND ERP7__Organisations__c='+'\''+orgId+'\''+' '+SelectedCustomersQuery+OrderByQyeryFilter;
                    ar.DunningList=Database.query(DunningList);
                }
            }

            if(showTabs=='deb'){
                String query='SELECT Id, Name,ERP7__Account__c,ERP7__Account__r.Name, ERP7__Credit__c,ERP7__Debit__c,  ERP7__Posted__c, ERP7__Amount__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Organisation__r.ERP7__Account_Type__c FROM ERP7__Debit_Note__c  WHERE  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') ' ;
                if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
                query += (scIds.size()>0)?' AND ERP7__Account__c IN:scIds':'';
                if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name  asc limit 2000 ';
                if(String.isEmpty(orgId))query += '  order by Name  asc limit 2000 ';
                ar.DebitList = Database.query(query);
                ar.recSize     =  ar.DebitList.size();
                ar.DebitListForSearch  = ar.DebitList;
                query=null;
                query='SELECT Id, Name,ERP7__Account__c, ERP7__Credit__c,ERP7__Debit__c,ERP7__Account__r.Name,  ERP7__Posted__c, ERP7__Amount__c, ERP7__Organisation__c, ERP7__Organisation__r.Name ,ERP7__Organisation__r.ERP7__Account_Type__c FROM ERP7__Debit_Note__c  WHERE  (ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation\' OR ERP7__Organisation__r.ERP7__Account_Type__c=Null OR ERP7__Organisation__r.ERP7__Account_Type__c=\'Organisation/Vendor\') ' ;if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
                if(searchString!=null && searchString!='')query += ' AND Name Like :s ';
                query += (scIds.size()>0)?' AND ERP7__Account__c IN:scIds':'';
                if(String.isNotEmpty(orgId))query += ' AND ERP7__Organisation__c=:orgId order by Name limit :ikRecordLimit Offset :ikOffset ';
                if(String.isEmpty(orgId))query += '  order by Name limit :ikRecordLimit Offset :ikOffset ';
                ar.DebitList = Database.query(query);
            }

        }catch(Exception e){
            system.debug('Exception-->'+e+'Line Number-->'+e.getLineNumber());
            return ar;
        }
        /*FOR RECORD TYPE*/
        list<RecordType> cusRT=new list<RecordType>(); ar.CustomerRTList=new list<SelectOption>(); cusRT=[SELECT Id, toLabel(Name), DeveloperName FROM RecordType WHERE sObjectType='Account'];  for(RecordType r:cusRT) ar.CustomerRTList.add(new SelectOption(r.Id,r.Name));  list<RecordType> payRT=new list<RecordType>(); ar.PaymentRTList=new list<SelectOption>();   payRT=[SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType='ERP7__Payment__c' AND  (NOT DeveloperName Like '%_Posted')];  for(RecordType r:payRT) ar.PaymentRTList.add(new SelectOption(r.Id,r.Name)); //list<RecordType> couRT=new list<RecordType>();   ar.CouponRTList=new list<SelectOption>();     couRT=[SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType='ERP7__Coupon__c'];        for(RecordType r:couRT) ar.CouponRTList.add(new SelectOption(r.Id,r.Name));

        ar.TODAY=System.today();
        return ar;
    }

    @AuraEnabled
    public static list<Account> getCustomerRecords(){
        return [SELECT Id, Name, AccountNumber,ERP7__Payment_Terms__c,  ERP7__Paid_Amount__c, ERP7__Available_Credit_Balance__c
                ,ERP7__Total_Due__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Account_Type__c,ERP7__Organisation__r.ERP7__Account_Type__c
                FROM Account
                WHERE (ERP7__Account_Type__c='Customer' AND (ERP7__Organisation__r.ERP7__Account_Type__c='Organisation/Vendor' OR ERP7__Organisation__r.ERP7__Account_Type__c='Organisation')) Order By Name];
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

    @AuraEnabled
    public static Boolean getFunctionalityControlApproval(){
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();
        }
        if(customList != null){
            return customList.ERP7__AR_Approval_Process__c ;
        }
        return false;
    }

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
            inv=[select id,Name,ERP7__Invoice_Amount__c,RecordType.DeveloperName,ERP7__Total_Down_Payment_Amount__c, ERP7__Total_Due__c from  ERP7__Invoice__c where Id=:InvId];
            if(inv.ERP7__Total_Due__c>0){
                List<Payment__c> payments=new List<Payment__c>();
                payments=[select id, Name, ERP7__Total_Amount__c,ERP7__Invoice__c from Payment__c where ERP7__Invoice__c=:InvId];
                if(payments.size()>0){
                    for(Payment__c p : payments){
                        if(p.ERP7__Total_Amount__c>0){
                            paidAmount+=p.ERP7__Total_Amount__c;
                        }
                    }
                }
                if(inv.RecordType.DeveloperName=='Advance'){ if(inv.ERP7__Total_Down_Payment_Amount__c>paidAmount) return true;  else return false;
                                                           }else{
                                                               if(inv.ERP7__Invoice_Amount__c>paidAmount) return true;
                                                               else return false;
                                                           }
            }else{
                return true;
            }
        }catch(Exception e){
            /* Exception occured */
            return false;
        }
    }


    @AuraEnabled
    public static Boolean getFunctionalityControlOrderProcess(){
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();
        }
        if(customList != null){
            return customList.ERP7__Standard_Order_Process__c;
        }
        return false;
    }


    @AuraEnabled
    public static ERP7__Functionality_Control__c getFuntionalityControl(){
        ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
        customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
        if(customList == null){
            customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
            if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();
        }
        if(customList != null){
            return customList;
        }
        return customList;
    }
}