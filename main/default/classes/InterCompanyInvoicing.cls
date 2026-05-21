public with sharing class InterCompanyInvoicing {
    @AuraEnabled    
    public static Account DefaultOrganisation(){
         return UtilClass.getOrganisationByLogin_Employee();
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchInvoices(String orgId, String prodOrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Invoice__c> invoices = new List<ERP7__Invoice__c>();
        Set<Id> invoiceIds = new Set<Id>();
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Customer_Id__c , ERP7__Organisation__r.Name, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Total_Due__c   from ERP7__Invoice__c where ERP7__Organisation__c=:orgId and ERP7__Account__c=:prodOrgId and ERP7__Invoice_Amount__c>0 order by CreatedDate DESC];
        if(invoices.size()>0){
            tw.invoices.addall(invoices);
        }
        
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchOrders(String orgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<Order> orders = new List<Order>();
        orders = [select Id, Name, EffectiveDate , ERP7__Order_Amount__c, ERP7__Amount_Paid__c , ERP7__Due_Amount__c , CreatedDate, ERP7__Estimated_Delivery_Date__c , ERP7__Expected_Date__c, ERP7__Organisation__r.Name from Order where ERP7__Is_Closed__c=false and ERP7__Organisation__c=:orgId and ERP7__Total_Number_of_Items__c>0 and ERP7__Order_Amount__c>0 order by CreatedDate DESC];
        if(orders.size()>0){
            tw.orders.addall(orders);
        }
        return tw;
    }
    
    
    @AuraEnabled
    public static TransactionWrapper fetchInterCompanyOrders(String orgId, String prodOrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<Order> orders = new List<Order>();
        orders = [select Id, Name, EffectiveDate , ERP7__Order_Amount__c, ERP7__Amount_Paid__c , ERP7__Due_Amount__c , CreatedDate, ERP7__Estimated_Delivery_Date__c , ERP7__Expected_Date__c, ERP7__Organisation__r.Name from Order where ERP7__Organisation__c=:orgId and AccountId=:prodOrgId and ERP7__Total_Number_of_Items__c>0 and ERP7__Order_Amount__c>0  order by CreatedDate DESC];
        if(orders.size()>0){
            tw.procorders.addall(orders);
        }
        return tw;
    }
    
    
    @AuraEnabled
    public static TransactionWrapper fetchBills(String orgId, String prodOrgId, Date StartDate, Date EndDate){
        TransactionWrapper tw= new TransactionWrapper();
        List<ERP7__Bill__c> bills = new List<ERP7__Bill__c>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Vendor_Bill_Date__c, ERP7__Total_Amount__c, ERP7__Amount_Due__c   from ERP7__Bill__c where ERP7__Vendor__c=:prodOrgId and ERP7__Organisation__c=:orgId order by CreatedDate DESC];
        if(bills.size()>0){
            tw.bills.addall(bills);
        }
        return tw;
    }
    
    @AuraEnabled
    public static TransactionWrapper fetchPurchaseOrders(String orgId, String prodOrgId, Date StartDate, Date EndDate){
        System.debug('Fetching purchase orders...');
        System.debug('orgId: ' + orgId);
        System.debug('prodOrgId: ' + prodOrgId);
        System.debug('StartDate: ' + StartDate);
        System.debug('EndDate: ' + EndDate);
        
        TransactionWrapper tw = new TransactionWrapper();
        List<ERP7__PO__c> pos = [SELECT Id, Name, CreatedDate, ERP7__Organisation__r.Name, ERP7__Order_Date__c, ERP7__Total_Amount__c, ERP7__Total_Due__c
                                 FROM ERP7__PO__c 
                                 WHERE ERP7__Vendor__c = :prodOrgId 
                                 AND ERP7__Organisation__c = :orgId
                                 ORDER BY CreatedDate DESC];
        if (pos.size() > 0) {
            tw.pos.addAll(pos);
        }
        System.debug('Fetched purchase orders: ' + tw.pos);
        return tw;
    }
	
    @AuraEnabled
    public static TransactionAmountWrapper fetchAmounts(String customerVendorId, Date StartDate, Date EndDate){
        TransactionAmountWrapper taWrap = new TransactionAmountWrapper();
        List<ERP7__Invoice__c> invoices = new List<ERP7__Invoice__c>();
        Set<Id> invoiceIds = new Set<Id>();
        invoices = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Invoice_Amount__c, ERP7__Total_Due__c  from ERP7__Invoice__c where ERP7__Invoice_Amount__c!=null and ERP7__Total_Due__c!=null and ERP7__Account__c=:customerVendorId order by CreatedDate DESC];
        if(invoices.size()>0){
            Decimal invAmount = 0;
            Decimal recievableAmount = 0;
            for(ERP7__Invoice__c inv : invoices){
                invAmount = invAmount + inv.ERP7__Invoice_Amount__c;
                recievableAmount = recievableAmount + inv.ERP7__Total_Due__c;
            }
            taWrap.invoiceAmount = invAmount.setScale(2);
            taWrap.recievableAmount = recievableAmount.setScale(2);
        }
        List<ERP7__Bill__c> bills = new List<ERP7__Bill__c>();
        bills = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Total_Amount__c, ERP7__Amount_Due__c  from ERP7__Bill__c where ERP7__Vendor__c=:customerVendorId and ERP7__Total_Amount__c!=null and ERP7__Amount_Due__c!=null order by CreatedDate DESC];
        if(bills.size()>0){
            Decimal billAmount = 0;
            Decimal payableAmount = 0;
            for(ERP7__Bill__c bill : bills){
                billAmount = billAmount + bill.ERP7__Total_Amount__c;
                payableAmount = payableAmount + bill.ERP7__Amount_Due__c;
            }
            taWrap.billAmount = billAmount.setScale(2);
            taWrap.payableAmount = payableAmount.setScale(2);
        }
        List<ERP7__Payment__c> payments = new List<ERP7__Payment__c>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Account__r.Name, ERP7__Total_Amount__c  from ERP7__Payment__c where ERP7__Accounts__c=:customerVendorId and ERP7__Invoice__c!= null and ERP7__Total_Amount__c!=null order by CreatedDate DESC];
        if(payments.size()>0){
            Decimal invPayAmount = 0;
            for(ERP7__Payment__c pay : payments){
                invPayAmount = invPayAmount + pay.ERP7__Total_Amount__c;
            }
            taWrap.invPaymentAmount = invPayAmount.setScale(2);
        }
        payments = new List<ERP7__Payment__c>();
        payments = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Account__r.Name, ERP7__Total_Amount__c from ERP7__Payment__c where ERP7__Accounts__c=:customerVendorId and ERP7__Bill__c!= null and ERP7__Total_Amount__c!=null order by CreatedDate DESC];
        if(payments.size()>0){
            Decimal billPayAmount = 0;
            for(ERP7__Payment__c pay : payments){
                billPayAmount = billPayAmount + pay.ERP7__Total_Amount__c;
            }
            taWrap.billPaymentAmount = billPayAmount.setScale(2);
        }
        List<ERP7__Credit_Note__c> creditnotes = new List<ERP7__Credit_Note__c>();
        creditnotes = [select Id, Name, ERP7__Posted__c, CreatedDate, ERP7__Organisation__r.Name, ERP7__Balance__c  from ERP7__Credit_Note__c where ERP7__Account__c =:customerVendorId and ERP7__Balance__c>0 order by CreatedDate DESC];
        if(creditnotes.size()>0){
            Decimal creditAmount = 0;
            for(ERP7__Credit_Note__c cred : creditnotes){
                creditAmount = creditAmount + cred.ERP7__Balance__c;
            }
            taWrap.availableCredit = creditAmount.setScale(2);
        }
        return taWrap;
    }
    
    @AuraEnabled
    public static List<SelectOptions> getStatus(){
        List<SelectOptions> options = new List<SelectOptions>(); 
        options.add(new SelectOptions('--None--','--None--'));
        Schema.DescribeFieldResult fieldResult = Order.Status.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple){
            options.add(new SelectOptions(f.getLabel(),f.getValue()));
            system.debug('f : '+f);
        }  
        return options;
    }
    
    @AuraEnabled
    public static List<OrderItem> populateOrderItems(List<String> poIds){
        system.debug('called');
        List<OrderItem> ordItemList=new List<OrderItem>();
        //ERP7__Sales_Order_Line_Item__c SOLI;
        List<ERP7__Purchase_Line_Items__c> prliList=new List<ERP7__Purchase_Line_Items__c>();
        Decimal Qty = 0;
        system.debug('poIds Before-->'+poIds);
        if(!poIds.isEmpty()){
            system.debug('poIds-->'+poIds);
            List<ERP7__Purchase_Line_Items__c> polis= new List<ERP7__Purchase_Line_Items__c>();
            polis = [SELECT  Id,ERP7__Lead_Time_Days__c,ERP7__Account_Category__c, ERP7__Chart_of_Account__c, ERP7__Vendor_product_Name__c, Name, ERP7__Product__c,ERP7__Product__r.ProductCode, ERP7__Cost_Card__c, ERP7__Quantity__c, ERP7__Sort_Order__c, ERP7__Unit_Price__c, ERP7__Total_Price__c, ERP7__Description__c, ERP7__Purchase_Orders__c,ERP7__Version__c, ERP7__Tax_Rate__c, ERP7__Tax__c FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c IN  :poIds Order by ERP7__Sort_Order__c];
            system.debug('polis-->'+polis.size());
            for(ERP7__Purchase_Line_Items__c poli:polis){
                OrderItem ordItem=new OrderItem();
                ordItem.Product2Id=poli.ERP7__Product__c;
                //ordItem.ERP7__Product__r=new Product2(Id=poli.ERP7__Product__c,Name=poli.Product2.Name,ERP7__Vendor_product_Name__c=ordItem.Product2.ERP7__Vendor_product_Name__c);
                ordItem.Quantity = poli.ERP7__Quantity__c;
                ordItem.UnitPrice = poli.ERP7__Unit_Price__c;
                ordItem.ERP7__Discount_Percent__c = 0;
                ordItem.ERP7__VAT_Amount__c = poli.ERP7__Tax__c;
                ordItem.ERP7__Discount_Percent__c = poli.ERP7__Tax_Rate__c;
                ordItem.ERP7__Purchase_Line_Items__c =poli.Id;  
                ordItem.ERP7__Purchase_Orders__c=poli.ERP7__Purchase_Orders__c;
                ordItem.ERP7__Detailed_Description__c = poli.ERP7__Description__c;
                ordItem.Description = poli.ERP7__Product__r.ProductCode;
                ordItemList.add(ordItem);
            }
            system.debug('ordItemList-->'+ordItemList);
            return ordItemList;
        }else{
            system.debug('ordItemList-->'+ordItemList);
            return ordItemList;
        }
        
    }
    @AuraEnabled
    public static Map<String,Object> createOrder(String Order, String ordItems){
        Map<String,Object> returnval = new Map<String,Object>();
        try{
            List<String> returnList = new List<String>();
            Order orderObj = (Order)JSON.deserialize(Order, Order.class);
            ERP7__Profiling__c  profile = [select id,Name, ERP7__Price_Book__c  from ERP7__Profiling__c where Id=:orderObj.ERP7__Order_Profile__c];
            orderObj.Pricebook2Id  = profile.ERP7__Price_Book__c;
            if(Schema.sObjectType.Order.isCreateable() && Schema.sObjectType.Order.isUpdateable()) { upsert orderObj; } else { }
            
            Order createdOrder=[select id,Name, Pricebook2Id, ERP7__Order_Profile__c, ERP7__Order_Profile__r.ERP7__Price_Book__c  from Order where Id=:orderObj.Id];
            List<OrderItem> ordItemsList = (List<OrderItem>)JSON.deserialize(ordItems, List<OrderItem>.class);
            
            /*for(Integer i=0;i<ordItemsList.size();i++){
                if(ordItemsList[i].OrderId == null) ordItemsList[i].OrderId  = createdOrder.id; 
                if(ordItemsList[i].Product2Id!=null){
                    PricebookEntry pbe = [SELECT Id, Name FROM PricebookEntry WHERE Pricebook2Id =:createdOrder.ERP7__Order_Profile__r.ERP7__Price_Book__c  AND Product2Id = :ordItemsList[i].Product2Id limit 1];
                    ordItemsList[i].PricebookEntryId = pbe.Id;
				}
            }*/
            for (OrderItem oi : ordItemsList) {
                if (oi.Product2Id != null) {
                    List<PricebookEntry> pbeList = [
                        SELECT Id 
                        FROM PricebookEntry 
                        WHERE Pricebook2Id = :profile.Price_Book__c  
                        AND Product2Id = :oi.Product2Id 
                        AND IsActive = true
                        LIMIT 1
                    ];
                    if (pbeList.isEmpty() && !Test.isRunningTest()) {
                        throw new AuraHandledException(
                            'No PricebookEntry found for Product: ' +  [SELECT Name FROM Product2 WHERE Id = :oi.Product2Id LIMIT 1].Name
                        );
                    }
                    oi.OrderId  = createdOrder.id; 
                    oi.PricebookEntryId = pbeList[0].Id;
                }
            }
            
            if(ordItemsList.size()>0) {
                if(Schema.sObjectType.OrderItem.isCreateable() && Schema.sObjectType.OrderItem.isUpdateable()){upsert ordItemsList;} else { }
            }
            returnList.add(JSON.serialize(orderObj)); returnList.add(JSON.serialize(ordItemsList)); //return billObj;
            returnval.put('bill',orderObj);
            returnval.put('bill2',createdOrder);
            
        }catch (AuraHandledException ahe) {
            throw ahe;            
        }catch(Exception e){   
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        }
        return returnval;
    }
    
    @AuraEnabled
    public static AccountDetailsWrapper fetchAccDetails(String customerId){
        AccountDetailsWrapper accwrap = new AccountDetailsWrapper();
        if(customerId!='' && customerId!=null){
            Account acc = new Account();
            acc = [select Id, Name, ERP7__Order_Profile__c  from Account where Id=:customerId];
            if(acc!=null && acc.ERP7__Order_Profile__c!=null){
                accwrap.orderProfileId = acc.ERP7__Order_Profile__c;
            }
            Contact con = new Contact();
            con = [select Id, Name from Contact where AccountId=:customerId order by CreatedDate DESC limit 1];
            if(con!=null){
                accwrap.conId = con.Id;
            }
            ERP7__Address__c  billAddress = new ERP7__Address__c();
            billAddress = [select Id, Name from ERP7__Address__c where ERP7__Customer__c=:customerId and ERP7__Is_Billing_Address__c =true order by CreatedDate DESC limit 1];
            if(billAddress!=null){
                accwrap.billAddId = billAddress.Id;
            }
            ERP7__Address__c  shipAddress = new ERP7__Address__c();
            shipAddress = [select Id, Name from ERP7__Address__c where ERP7__Customer__c=:customerId and ERP7__Is_Shipping_Address__c =true order by CreatedDate DESC limit 1];
            if(shipAddress!=null){
                accwrap.shipAddId = shipAddress.Id;
            }
            return accwrap;
        }else{
            return accwrap;
        }
    }
    
    @AuraEnabled
    public static ERP7__Employees__c fetchEmployeeRequester(){  
        List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
        empList = [SELECT Id, Name FROM ERP7__Employees__c WHERE ERP7__Employee_User__c=:UserInfo.getUserId() limit 1];  
        if(empList.size()>0) return empList[0];
        else return null;                                          
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        public selectOptions(String lab, string val) {
            label = lab; value = val; 
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab; value = val; selected = sel;
        }
    }
    
    public class AccountDetailsWrapper{
        @AuraEnabled public String conId {get;set;}
        @AuraEnabled public String orderProfileId {get;set;}
        @AuraEnabled public String billAddId {get;set;}
        @AuraEnabled public String shipAddId {get;set;}
        public AccountDetailsWrapper(){
            conId = billAddId = shipAddId = orderProfileId = '';
        }
    }
        
    
    public class TransactionAmountWrapper{
        @AuraEnabled public Decimal invoiceAmount {get;set;}
        @AuraEnabled public Decimal invPaymentAmount {get;set;}
        @AuraEnabled public Decimal billAmount {get;set;}
        @AuraEnabled public Decimal billPaymentAmount {get;set;}
        @AuraEnabled public Decimal availableCredit {get;set;}
        @AuraEnabled public Decimal returnedAmount {get;set;}
        @AuraEnabled public Decimal recievableAmount {get;set;}
        @AuraEnabled public Decimal payableAmount {get;set;}
        public TransactionAmountWrapper(){
            invoiceAmount = invPaymentAmount = billAmount = billPaymentAmount = availableCredit = returnedAmount = recievableAmount = payableAmount = 0;
        }
    }
    // Wrapper Class
    public class TransactionWrapper{
        @AuraEnabled public Date StartDate {get;set;}
        @AuraEnabled public Date EndDate {get;set;}
        @AuraEnabled public List<Order> orders {get;set;}
        @AuraEnabled public List<Order> procorders {get;set;}
        @AuraEnabled public List<ERP7__Invoice__c> invoices {get;set;}
        @AuraEnabled public List<ERP7__Bill__c> bills {get;set;}
        @AuraEnabled public List<ERP7__PO__c> pos {get;set;} 
        
        public TransactionWrapper(){
            orders = new List<Order>();
            procorders = new List<Order>();
            invoices = new List<ERP7__Invoice__c>();
            bills = new List<ERP7__Bill__c>();
            pos = new List<ERP7__PO__c>();
        }
        
    }
}