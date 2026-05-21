public With Sharing Class TaxSummaryUtils { 
    
    /* 
        Method to create tax summaries for insert and undelete of Line Items.
    */    
    
    public static void createTaxSummaries(List<Sales_Order_Line_Item__c> lineItems){
        Set<Id> lineItemIds = new Set<Id>();
        Set<Id> taxPlanIds = new Set<Id>();
        Date todayDate = System.Today();
        List<Tax_Summary__c> taxSummaries = new List<Tax_Summary__c>();
        Id TaxSumRType; TaxSumRType = Schema.SObjectType.ERP7__Tax_Summary__c.getRecordTypeInfosByDeveloperName().get('Sales_Tax_Summary').getRecordTypeId();    
    
        for(Sales_Order_Line_Item__c lineItem : lineItems){            
            if(Schema.sobjectType.Sales_Order_Line_Item__c.isAccessible()) lineItemIds.add(lineItem.Id);
        }  
        
        List<Sales_Order_Line_Item__c> currentLineItems ;
        if(Schema.sObjectType.Sales_Order_Line_Item__c .isAccessible()){
            UtilClass.FlsCheck(new String[]{'ERP7__Base_Price__c','ERP7__Discount_Amount__c','ERP7__Invoice__c','ERP7__Price_Product__c','ERP7__Total_Price__c','ERP7__VAT_Amount__c','ERP7__Organisation__c','ERP7__Organisation_Business_Unit__c','ERP7__Inventory_Tracked__c','ERP7__Product__c','ERP7__Quantity__c','ERP7__Sales_Order__c','ERP7__Loyalty_Points__c','ERP7__Loyalty_Program__c','ERP7__Checked_Out_Process__c','ERP7__Commission__c','ERP7__Commission_Rate_Card__c','ERP7__Status__c'},'ERP7__Sales_Order_Line_Item__c');
            UtilClass.FlsCheck(new String[]{'ERP7__Sub_Total__c','ERP7__Total_Discount__c','ERP7__Total_Due__c','ERP7__Total_Tax_Amount__c','ERP7__Channel__c','ERP7__Order_Status__c','ERP7__Is_Back_Order__c'},'ERP7__Sales_Order__c');
            UtilClass.FlsCheck(new String[]{'ERP7__SKU__c','ERP7__Track_Inventory__c'},'ERP7__Product__c');
            if(!Schema.sObjectType.ERP7__Commission_Rate_Card__c.fields.Commission_Plan__c.isAccessible()) return ;
            
        currentLineItems = [Select Id, Name, Base_Price__c, Discount_Amount__c, Invoice__c, Price_Product__c, Total_Price__c, VAT_Amount__c,Organisation__c, Organisation_Business_Unit__c,
                                                          Product__c, Product__r.Name, Product__r.SKU__c, Quantity__c, Sales_Order__c, Loyalty_Points__c, Loyalty_Program__c,
                                                          Sales_Order__r.Name, Sales_Order__r.Sub_Total__c, Sales_Order__r.Total_Discount__c, Sales_Order__r.Total_Due__c, Sales_Order__r.Total_Tax_Amount__c, Commission__c, Commission_Rate_Card__c,
                                                          Commission_Rate_Card__r.Commission_Plan__c, Status__c 
                                                          From Sales_Order_Line_Item__c 
                                                          Where Id In: lineItemIds];
        }
        for(Sales_Order_Line_Item__c lineItem : currentLineItems ){  
            //if(lineItem.PriceBook_Entry__r.Tax_Plan__c != Null)              
            //taxPlanIds.add(lineItem.PriceBook_Entry__r.Tax_Plan__c);
        } 
        
        List<Product_Tax_Allocation__c> prodTaxAllocations ;
        if(Schema.sObjectType.Product_Tax_Allocation__c.isAccessible()){
            UtilClass.FlsCheck(new String[]{'ERP7__Active__c', 'ERP7__Organisation_Business_Unit__c', 'ERP7__Organisation__c', 'ERP7__Tax_Plan__c', 'ERP7__Tax__c'},'ERP7__Product_Tax_Allocation__c');
            UtilClass.FlsCheck(new String[]{'ERP7__Active__c', 'ERP7__Effective_Date__c', 'ERP7__Expiry_Date__c', 'ERP7__Tax_Rate__c', 'ERP7__Type__c'},'ERP7__Tax__c');                       
            prodTaxAllocations = [Select Id, Name, Active__c, Organisation_Business_Unit__c, Organisation__c, Tax_Plan__c, Tax__c, Tax__r.Active__c, Tax__r.Effective_Date__c, Tax__r.Expiry_Date__c, Tax__r.Tax_Rate__c, Tax__r.Type__c
                                                               From Product_Tax_Allocation__c
                                                               Where Active__c = true And
                                                               Tax_Plan__c In: taxPlanIds And
                                                               Tax__r.Active__c = true And 
                                                               Tax__r.Effective_Date__c <=: todayDate And  
                                                               Tax__r.Expiry_Date__c >=: todayDate ]; 
        }
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType TAXSUM_OBJECT = globalDescribe.get('ERP7__Tax_Summary__c');
        Map<String, Schema.SObjectField> TAXSUMFields = Schema.SObjectType.Tax_Summary__c.fields.getMap();
        
        for(Sales_Order_Line_Item__c lineItem : currentLineItems){
            for(Product_Tax_Allocation__c pta : prodTaxAllocations){
                if( lineItem.Organisation__c == pta.Organisation__c && lineItem.Organisation_Business_Unit__c == pta.Organisation_Business_Unit__c){
                    Tax_Summary__c taxSummary = new Tax_Summary__c();                        
                    if(TAXSUMFields.get('Active__c').getDescribe().isCreateable()) taxSummary.Active__c = true; 
                    if(TaxSumRType != null) taxSummary.RecordTypeId = TaxSumRType;
                    if(TAXSUMFields.get('Organisation__c').getDescribe().isCreateable())  taxSummary.Organisation__c = lineItem.Organisation__c; 
                    if(TAXSUMFields.get('Organisation_Business_Unit__c').getDescribe().isCreateable()) taxSummary.Organisation_Business_Unit__c = lineItem.Organisation_Business_Unit__c; 
                    if(TAXSUMFields.get('Sales_Order__c').getDescribe().isCreateable()) taxSummary.Sales_Order__c = lineItem.Sales_Order__c; 
                    if(TAXSUMFields.get('Sales_Order_Line_Item__c').getDescribe().isCreateable()) taxSummary.Sales_Order_Line_Item__c = lineItem.Id; 
                    if(TAXSUMFields.get('Tax_Code__c').getDescribe().isCreateable()) taxSummary.Tax_Code__c = pta.Tax__c;
                    if(lineItem.Status__c == 'Closed'){
                        if(TAXSUMFields.get('Received__c').getDescribe().isCreateable()) taxSummary.Received__c = true;
                    }
                    if(lineItem.Invoice__c != Null){
                        if(TAXSUMFields.get('Invoice__c').getDescribe().isCreateable()) taxSummary.Invoice__c = lineItem.Invoice__c;
                    }
                    if(TAXSUM_OBJECT.getDescribe().isCreateable()) taxSummaries.add(taxSummary);
                }
            }
        }
        if(taxSummaries.size() > 0){  try { if(Tax_Summary__c.sObjectType.getDescribe().isCreateable()) DMLManager.InsertAsUser(taxSummaries); }catch(Exception e){}
        }
    }    
    
    /* 
        Method to update tax summaries for update of Line Items.
    */    
    
    public static void updateTaxSummaries(List<Sales_Order_Line_Item__c> lineItems){
        List<Id> LineItemIds = new List<Id>();
        List<Tax_Summary__c> taxSummaries2Update = new List<Tax_Summary__c>();          
        for(Sales_Order_Line_Item__c lineItem : lineItems){
            //if(lineItem.PriceBook_Entry__c != Null){                    
                LineItemIds.add(lineItem.Id);
            //}
        }      
        List<Tax_Summary__c> existingTaxSummaries;
        if(Schema.sObjectType.Tax_Summary__c.isAccessible()){
        UtilClass.FlsCheck(new String[]{'ERP7__Active__c', 'ERP7__Organisation__c', 'ERP7__Organisation_Business_Unit__c', 'ERP7__Sales_Order__c', 'ERP7__Sales_Order_Line_Item__c', 'ERP7__Tax_Code__c', 'ERP7__Received__c'}, 'ERP7__Tax_Summary__c');
        existingTaxSummaries  = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Sales_Order__c,
                                                    Sales_Order_Line_Item__c, Tax_Code__c, Received__c
                                                    From Tax_Summary__c
                                                    Where Active__c = true And
                                                    Sales_Order_Line_Item__c In: LineItemIds];
        }                                                    
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType TAXSUM_OBJECT = globalDescribe.get('ERP7__Tax_Summary__c');
        Map<String, Schema.SObjectField> TAXSUMFields = Schema.SObjectType.Tax_Summary__c.fields.getMap();
        
        for(Sales_Order_Line_Item__c lineItem : lineItems){
            for(Tax_Summary__c existingTaxSummary : existingTaxSummaries){
                if(existingTaxSummary.Sales_Order_Line_Item__c == lineItem.Id && lineItem.Organisation__c == existingTaxSummary.Organisation__c && lineItem.Organisation_Business_Unit__c == existingTaxSummary.Organisation_Business_Unit__c && lineItem.Status__c == 'Closed'){
                    if(TAXSUMFields.get('Received__c').getDescribe().isUpdateable())  existingTaxSummary.Received__c = true;
                    if(TAXSUM_OBJECT.getDescribe().isUpdateable()) taxSummaries2Update.add(existingTaxSummary); 
                }
            }
        }
        if(taxSummaries2Update.size() > 0){   try { if(Tax_Summary__c.sObjectType.getDescribe().isUpdateable())  DMLManager.UpdateAsUser(taxSummaries2Update);  } catch(Exception e){}
        }
    }   
    
    /* 
        Method to delete tax summaries for delete of Line Items.
    */
    
    public static void deleteTaxSummaries(List<Sales_Order_Line_Item__c> lineItems){
        List<Id> LineItemIds2Delete = new List<Id>();           
        for(Sales_Order_Line_Item__c lineItem : lineItems){
            LineItemIds2Delete.add(lineItem.Id);
        }
        List<Tax_Summary__c> taxSummaries2Delete ;
         if(Schema.sObjectType.Tax_Summary__c.isAccessible()){
        UtilClass.FlsCheck(new String[]{'ERP7__Active__c', 'ERP7__Organisation__c', 'ERP7__Organisation_Business_Unit__c', 'ERP7__Sales_Order__c', 'ERP7__Sales_Order_Line_Item__c', 'ERP7__Tax_Code__c', 'ERP7__Received__c'}, 'ERP7__Tax_Summary__c');
        taxSummaries2Delete = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Sales_Order__c,
                                                        Sales_Order_Line_Item__c, Tax_Code__c, Received__c
                                                        From Tax_Summary__c  
                                                        Where Sales_Order_Line_Item__c In: LineItemIds2Delete];
         }                                                    
        if(taxSummaries2Delete.size() > 0 && Tax_Summary__c.sObjectType.getDescribe().isDeletable()){
            try {if(Schema.sObjectType.Tax_Summary__c.isDeletable()) DMLManager.DeleteAsUser(taxSummaries2Delete); } catch(Exception e){}
        }
    }
}