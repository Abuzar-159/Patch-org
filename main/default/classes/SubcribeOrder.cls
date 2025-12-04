Global With Sharing Class SubcribeOrder implements Database.Batchable<sObject> , Schedulable{
  Date myDate = System.Today() + 1; 
  String query = 'SELECT Id, Active__c, Days__c, Next_Order_On__c, Sales_Order__c, Subscription_Date__c, Subscription_End_Date__c, SubscriptionPlan__c FROM Subscription__c WHERE Active__c = true AND Next_Order_On__c =: myDate AND Subscription_Date__c <= :myDate AND Subscription_End_Date__c >= :myDate';

  global SubcribeOrder() {
  }
 
  global void execute(SchedulableContext SC) {   
      SubcribeOrder SubcribeOrders = new SubcribeOrder();
      //String cronStr =  '0 30 * * * ?';
      //System.schedule('Process Contacts', cronStr, SubcribeOrders);      
      ID batchprocessid = Database.executeBatch(SubcribeOrders);
  } 
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    if(Schema.SObjectType.Subscription__c.isAccessible())
    return Database.getQueryLocator(this.query);
    return null;
  }
  
  global void execute(Database.BatchableContext BC, List<Subscription__c> scope) {  
    Map<Id, List<Sales_Order_Line_Item__c>> orderAndItems = new Map<Id, List<Sales_Order_Line_Item__c>>();
    Map<Id, Sales_Order__c> subAndOrder = new Map<Id, Sales_Order__c>();
    List<Id> orderIds = new List<Id>();
    
    for(Integer i = 0; i < scope.size(); i++) {
      Subscription__c sub = (Subscription__c) scope[i];       
      orderIds.add(sub.Sales_Order__c);
    }    
    
    List<Sales_Order__c> salesOrders;
    if(Schema.SObjectType.Sales_Order__c.isAccessible())
    salesOrders = [Select Id, Name, Amount__c, Bill_To_Address__c, Book_Date__c, Account__c, Hold_Status__c, Order_Date__c, Order_Status__c, Contact__c, Contact__r.Email,Active__c,
                                              Purchase_Order_Number__c, Request_Date__c, Channel__c, Ship_To_Address__c, Special_Instructions__c, Organisation__c, Organisation_Business_Unit__c,  
                                              Sub_Total__c, Total_Discount__c, Total_Due__c, Total_Tax_Amount__c, Account__r.Name, Channel__r.Name, Employees__c, Employees__r.Email__c, Customer_Email__c, Employee_Email__c, 
                                              Loyalty_Points__c, Loyalty_Amount__c, Payments_Status__c, Payment_Method__c, Payment_Mode__c, Status__c, Amount_Paid__c
                                              From Sales_Order__c 
                                              Where Id In : orderIds];    
    for(Integer i = 0; i < scope.size(); i++) {
      Subscription__c sub = (Subscription__c) scope[i];  
      for(Sales_Order__c so : salesOrders){
          if(sub.Sales_Order__c == so.Id){
              subAndOrder.put(sub.Id, so);
          }
      }           
    }
    
    List<Sales_Order_Line_Item__c> LineItems;
    if(Schema.SObjectType.Sales_Order_Line_Item__c.isAccessible())
    LineItems = [Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c, Loyalty_Program__c,Active__c,
                                                  Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Discount_Plan__c,
                                                  Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c,
                                                  Loyalty_Points__c, Organisation__c, Organisation_Business_Unit__c, Commission_Rate_Card__c, Commission__c, Other_Tax__c, ReturnedQuantity__c
                                                  From Sales_Order_Line_Item__c  
                                                  Where Sales_Order__c In : orderIds];       
    for(Sales_Order__c so : salesOrders){
        List<Sales_Order_Line_Item__c> tempItems = new List<Sales_Order_Line_Item__c>();
        for(Sales_Order_Line_Item__c li : LineItems){
            if(so.Id == li.Sales_Order__c){
                tempItems.add(li);
            }
        }
        orderAndItems.put(so.Id,tempItems);
    }
   
    
    //Creation Process
    List<Subscription__c> allSubs = new List<Subscription__c>();
    Map<String, Schema.SObjectField> SOFields = Schema.SObjectType.Sales_Order__c.fields.getMap();
    Map<String, Schema.SObjectField> SOLIFields = Schema.SObjectType.Sales_Order_Line_Item__c.fields.getMap();
    Map<String, Schema.SObjectField> SUBFields = Schema.SObjectType.Subscription__c.fields.getMap();
    
    Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    Schema.SObjectType SO_OBJECT = globalDescribe.get('Sales_Order__c');
    Schema.SObjectType SOLI_OBJECT = globalDescribe.get('Sales_Order_Line_Item__c');
    Schema.SObjectType SUB_OBJECT = globalDescribe.get('Subscription__c');
    
    for(Integer i = 0; i < scope.size(); i++) {
      Subscription__c sub = (Subscription__c) scope[i];       
      Sales_Order__c baseOrder = subAndOrder.get(sub.Id);
      Sales_Order__c newOrder = new Sales_Order__c();
          if(SOFields.get('ERP7__Active__c').getDescribe().isCreateable()) { newOrder.ERP7__Active__c = baseOrder.ERP7__Active__c; }
          if(SOFields.get('ERP7__Organisation__c').getDescribe().isCreateable()) { newOrder.ERP7__Organisation__c = baseOrder.ERP7__Organisation__c; }
          if(SOFields.get('ERP7__Organisation_Business_Unit__c').getDescribe().isCreateable()) { newOrder.ERP7__Organisation_Business_Unit__c = baseOrder.ERP7__Organisation_Business_Unit__c; }
          if(baseOrder.ERP7__Employees__c != Null){
              if(SOFields.get('ERP7__Employees__c').getDescribe().isCreateable()) { newOrder.ERP7__Employees__c = baseOrder.ERP7__Employees__c; }
          }          
          if(baseOrder.ERP7__Customer_Email__c != Null){
              if(SOFields.get('ERP7__Customer_Email__c').getDescribe().isCreateable()) { newOrder.ERP7__Customer_Email__c = baseOrder.ERP7__Customer_Email__c; }
          }
          if(baseOrder.ERP7__Employee_Email__c != Null){
              if(SOFields.get('ERP7__Employee_Email__c').getDescribe().isCreateable()) { newOrder.ERP7__Employee_Email__c = baseOrder.ERP7__Employee_Email__c; }
          }
          if(SOFields.get('ERP7__ERP7__Account__c').getDescribe().isCreateable()) { newOrder.ERP7__Account__c = baseOrder.ERP7__Account__c; }
          if(SOFields.get('ERP7__Channel__c').getDescribe().isCreateable()) { newOrder.ERP7__Channel__c = baseOrder.ERP7__Channel__c; }
          if(SOFields.get('ERP7__Order_Status__c').getDescribe().isCreateable()) { newOrder.ERP7__Order_Status__c = 'Entered'; }
          if(SOFields.get('ERP7__Subscription__c').getDescribe().isCreateable()) { newOrder.ERP7__Subscription__c = sub.id; }
          if(SOFields.get('ERP7__Bill_To_Address__c').getDescribe().isCreateable()) { newOrder.ERP7__Bill_To_Address__c = baseOrder.ERP7__Bill_To_Address__c; }
          if(SOFields.get('ERP7__Ship_To_Address__c').getDescribe().isCreateable()) { newOrder.ERP7__Ship_To_Address__c = baseOrder.ERP7__Ship_To_Address__c; }
          if(SOFields.get('ERP7__Request_Date__c').getDescribe().isCreateable()) { newOrder.ERP7__Request_Date__c = System.Today(); }
          if(SOFields.get('ERP7__Hold_Status__c').getDescribe().isCreateable()) { newOrder.ERP7__Hold_Status__c = baseOrder.ERP7__Hold_Status__c; }
          if(SOFields.get('ERP7__Special_Instructions__c').getDescribe().isCreateable()) { newOrder.ERP7__Special_Instructions__c = baseOrder.ERP7__Special_Instructions__c; }    
        try { if(SO_OBJECT.getDescribe().isCreateable()) {Insert newOrder;} else{/* Not allowed */ } }catch(exception ex){}
      List<Sales_Order_Line_Item__c> baseItems = orderAndItems.get(baseOrder.Id);
      List<Sales_Order_Line_Item__c> newItems = new List<Sales_Order_Line_Item__c>();
      for(Sales_Order_Line_Item__c bItem : baseItems){
          Sales_Order_Line_Item__c currentItem = new Sales_Order_Line_Item__c();
          if(SOLIFields.get('ERP7__Active__c').getDescribe().isCreateable()) { currentItem.Active__c = bItem.Active__c; }
          if(SOLIFields.get('ERP7__Organisation__c').getDescribe().isCreateable()) { currentItem.Organisation__c = bItem.Organisation__c; }
          if(SOLIFields.get('ERP7__Organisation_Business_Unit__c').getDescribe().isCreateable()) { currentItem.Organisation_Business_Unit__c = bItem.Organisation_Business_Unit__c; }
          //if(SOLIFields.get('ERP7__PriceBook_Entry__c').getDescribe().isCreateable()) { currentItem.PriceBook_Entry__c = bItem.PriceBook_Entry__c; }
          if(SOLIFields.get('ERP7__Sales_Order__c').getDescribe().isCreateable()) { currentItem.Sales_Order__c = newOrder.Id; }
          if(SOLIFields.get('ERP7__Product__c').getDescribe().isCreateable()) { currentItem.Product__c = bItem.Product__c; }             
          if(SOLIFields.get('ERP7__Quantity__c').getDescribe().isCreateable()) { currentItem.Quantity__c = bItem.Quantity__c - bItem.ReturnedQuantity__c; }
          if(SOLIFields.get('ERP7__Base_Price__c').getDescribe().isCreateable()) { currentItem.Base_Price__c = (bItem.Base_Price__c / integer.valueof(bItem.Quantity__c)) * currentItem.Quantity__c; }          
          if(SOLIFields.get('ERP7__Discount_Amount__c').getDescribe().isCreateable()) { currentItem.Discount_Amount__c = (bItem.Discount_Amount__c / integer.valueof(bItem.Quantity__c)) * currentItem.Quantity__c; }  
          if(SOLIFields.get('ERP7__Total_Price__c').getDescribe().isCreateable()) { currentItem.Total_Price__c = (bItem.Total_Price__c / integer.valueof(bItem.Quantity__c)) * currentItem.Quantity__c; }
          if(SOLIFields.get('ERP7__Other_Tax__c').getDescribe().isCreateable()) { currentItem.Other_Tax__c = (bItem.Other_Tax__c / integer.valueof(bItem.Quantity__c)) * currentItem.Quantity__c; }
          if(SOLIFields.get('ERP7__VAT_Amount__c').getDescribe().isCreateable()) { currentItem.VAT_Amount__c = (bItem.VAT_Amount__c / integer.valueof(bItem.Quantity__c)) * currentItem.Quantity__c; }
          if(SOLIFields.get('ERP7__Commission__c').getDescribe().isCreateable()) { currentItem.Commission__c = (bItem.Commission__c / integer.valueof(bItem.Quantity__c)) * currentItem.Quantity__c; }         
          //points allocation should be re-calculated
          if(bItem.Loyalty_Program__c != null){
              if(SOLIFields.get('ERP7__Loyalty_Program__c').getDescribe().isCreateable()) { currentItem.Loyalty_Program__c = bItem.Loyalty_Program__c; } 
          }
          if(bItem.Commission_Rate_Card__c != null){
              if(SOLIFields.get('ERP7__Commission_Rate_Card__c').getDescribe().isCreateable()) { currentItem.Commission_Rate_Card__c = bItem.Commission_Rate_Card__c; } 
          }
          if(SOLIFields.get('ERP7__Loyalty_Points__c').getDescribe().isCreateable()) { currentItem.Loyalty_Points__c = (bItem.Loyalty_Points__c / integer.valueof(bItem.Quantity__c)) * currentItem.Quantity__c; }
          
          newItems.add(currentItem);       
      }
        try { if(SOLI_OBJECT.getDescribe().isCreateable()) { Insert newItems;} else{ /* no access*/ } }catch(exception ex){}      
      Date nextOrderOn = sub.Next_Order_On__c;            
      if(SUBFields.get('ERP7__Next_Order_On__c').getDescribe().isUpdateable()) { sub.Next_Order_On__c = nextOrderOn.addDays(Integer.valueof(sub.Days__c)); }      
      allSubs.add(sub);
      
    }    
    if(allSubs.size() > 0){        
        try { if(Schema.sObjectType.Subscription__c.isUpdateable()) { DMLManager.updateAsUser(allSubs);} else{ /* no access*/ } }catch(exception ex){}  
    }    
  }
    
  global void finish(Database.BatchableContext BC) {  
  }
}