public with sharing class SalesOrderAndQuotationManagement {
    
    public ERP7__Quotes__c Quote                               { get; set; }
    public List<ERP7__Quote_Line_Items__c> QLIS                { get; set; }
    public ERP7__Sales_Order__c SalesOrder                     { get; set; }
    public List<ERP7__Sales_Order_Line_Item__c> SOLIS          { get; set; }
    public String SOFields                                          { get; set; }
    public String SOLIFields                                        { get; set; }
    public String QFields                                           { get; set; }
    public String QLIFields                                         { get; set; }
    public String exceptionMsg                                      { get; set; }
    public String orderId                                           { get; set; }
    public String quoteId                                           { get; set; }
    public List<QLine> QLines                                       { get; set; }
    public Boolean selectAll                                        { get; set; }
    public Integer countR                                           { get; set; }
    
    public String errormsg                                     { get; set; }
    public Boolean hasAccess                                   { get; set; }
    
    public SalesOrderAndQuotationManagement(ApexPages.StandardController controller) { }
    
    public SalesOrderAndQuotationManagement(){
        orderId = ApexPages.currentPage().getParameters().get('soId');
        quoteId = ApexPages.currentPage().getParameters().get('qId');
        SOLIFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order_Line_Item__c');
        SOFields = UtilClass.selectStarFromSObject('ERP7__Sales_Order__c');
        QLIFields = UtilClass.selectStarFromSObject('ERP7__Quote_Line_Items__c');
        QFields = UtilClass.selectStarFromSObject('ERP7__Quotes__c');
        selectAll = false;
        if(orderId != Null && orderId != '') SalesOrder = Database.query('select ' + String.escapeSingleQuotes(SOFields) + ' from ERP7__Sales_Order__c where ' + '(Id =\'' + String.escapeSingleQuotes(orderId) + '\') Limit 1');
        if(quoteId != Null && quoteId != '') Quote = Database.query('select ' + String.escapeSingleQuotes(QFields) + ' from ERP7__Quotes__c where ' + '(Id =\'' + String.escapeSingleQuotes(quoteId) + '\') Limit 1');
    }
    
    public PageReference SelectAllLines(){
        try{
            for (QLine ql: QLines) { if(!ql.QLI.Converted__c) ql.selectLine = selectAll; }
            return Null;
        } catch(Exception e) { exceptionMethod(e, 'Quote2SalesOrder'); return Null; }
    }
    
    public PageReference Quote2SalesOrderSave(){
        try{
            SalesOrder = new ERP7__Sales_Order__c();
                SalesOrder.ERP7__Bill_To_Address__c = Quote.ERP7__Bill_To_Address__c; 
                SalesOrder.ERP7__Contact__c = Quote.ERP7__Contact__c;
                SalesOrder.ERP7__Account__c = Quote.ERP7__Customer__c;
                SalesOrder.ERP7__Order_Profile__c = Quote.ERP7__Order_Profile__c;
                SalesOrder.ERP7__Special_Instructions__c = Quote.ERP7__Description__c;
                SalesOrder.ERP7__Employees__c = Quote.ERP7__Employees__c;
                SalesOrder.ERP7__Organisation__c = Quote.ERP7__Organisation__c;
                SalesOrder.ERP7__Organisation_Business_Unit__c = Quote.ERP7__Organisation_Business_Unit__c;
                SalesOrder.ERP7__Request_Date__c = Quote.ERP7__Request_Date__c;
                SalesOrder.ERP7__Channel__c = Quote.ERP7__Channel__c;
                SalesOrder.ERP7__Ship_To_Address__c = Quote.ERP7__Ship_To_Address__c;
                SalesOrder.ERP7__Is_Converted__c = true;
                SalesOrder.ERP7__Quotes__c = Quote.Id;
                SalesOrder.ERP7__Contact__c = Quote.ERP7__Contact__c;
                SalesOrder.ERP7__Description__c = Quote.ERP7__Description__c;
                SalesOrder.ERP7__Employees__c = Quote.ERP7__Employees__c;
                SalesOrder.ERP7__Request_Date__c = Quote.ERP7__Request_Date__c;
                SalesOrder.ERP7__Status__c = Quote.ERP7__Status__c;
                
            Boolean createOrder = false;
            for (QLine ql: QLines){ 
                if(ql.selectLine) { createOrder = true; break;}
            }  
            if(createOrder && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Description__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Description__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Is_Converted__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Is_Converted__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Ship_To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Ship_To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Channel__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Channel__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Request_Date__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Request_Date__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Organisation_Business_Unit__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Organisation__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Employees__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Employees__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Special_Instructions__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Special_Instructions__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Profile__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Profile__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Contact__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Bill_To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Bill_To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Quotes__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Quotes__c.isUpdateable()){hasAccess=true; upsert SalesOrder;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
            
            SOLIS = new List<ERP7__Sales_Order_Line_Item__c>();
            List<ERP7__Quote_Line_Items__c> qlis2upsert = new List<ERP7__Quote_Line_Items__c>();
            Map<Id, ERP7__Sales_Order_Line_Item__c> quoteSOLI = new Map<Id, ERP7__Sales_Order_Line_Item__c>();
            for (QLine ql: QLines) {
                if(!ql.qli.Converted__c){
                    ERP7__Quote_Line_Items__c item = ql.qli;
                    if(ql.selectLine){
                        item.Converted__c = true;
                        ERP7__Sales_Order_Line_Item__c lineItem = new ERP7__Sales_Order_Line_Item__c(ERP7__Discount_Plan__c = item.ERP7__Discount_Plan__c,ERP7__Discount_Amount__c = item.ERP7__Discount_Amount__c,ERP7__Product__c = item.ERP7__Product__c,ERP7__Quantity__c = item.ERP7__Quantity__c,ERP7__Sales_Order__c = SalesOrder.id,ERP7__Total_Price__c = item.ERP7__Total_Price__c,ERP7__VAT_Amount__c = item.ERP7__VAT_Amount__c,ERP7__Other_Tax__c = item.ERP7__Other_Tax__c,ERP7__Inventory_Tracked__c = item.ERP7__Inventory_Tracked__c);                                       
                        lineItem.ERP7__Base_Price__c = (item.ERP7__Base_Price__c == null)? 0 : item.ERP7__Base_Price__c; 
                        if(item.ERP7__Organisation__c != null) lineItem.ERP7__Organisation__c = item.ERP7__Organisation__c; 
                        if(item.ERP7__Organisation_Business_Unit__c != null) lineItem.ERP7__Organisation_Business_Unit__c = item.ERP7__Organisation_Business_Unit__c; 
                        SOLIS.add(lineItem);
                        quoteSOLI.put(item.Id, lineItem);
                    }
                    qlis2upsert.add(item);
                }
            }
            if(SOLIS.size() > 0 && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Organisation_Business_Unit__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Organisation_Business_Unit__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Organisation__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Discount_Plan__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__VAT_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Other_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Inventory_Tracked__c .isCreateable()){hasAccess=true; upsert SOLIS;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
             
            for (ERP7__Quote_Line_Items__c ql: qlis2upsert) {
                if(quoteSOLI.containsKey(ql.Id)){
                    ql.Sales_Order_Line_Item__c = quoteSOLI.get(ql.Id).Id;
                }
            }
            
            if(qlis2upsert.size() > 0 && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.converted__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.converted__c.isUpdateable()){hasAccess=true; upsert qlis2upsert;}    else{ hasAccess=false; errormsg='You are not allowed to create or update records'; }
            
            PageReference page = new PageReference('/'+ Quote.Id);
            page.setRedirect(true);
            return page;
            
        } catch(Exception e) { exceptionMethod(e, 'Quote2SalesOrder'); return Null; }
    }

    public PageReference Quote2SalesOrderCancel(){
        try{
            PageReference page = new PageReference('/'+ QuoteId);
            page.setRedirect(true);
            return page;
        } catch(Exception e) { exceptionMethod(e, 'Quote2SalesOrder'); return Null; }
    }
    
    
    public PageReference EditQuoteLines() {
        try{
            Quote = Database.query('select ' + String.escapeSingleQuotes(QFields) + ' from ERP7__Quotes__c where ' + '(Id =\'' + String.escapeSingleQuotes(quoteId) + '\') Limit 1');
            
            QLIS = Database.query('select ' + String.escapeSingleQuotes(QLIFields) + ' , ERP7__Product__r.Name, ERP7__Product__r.ProductCode, ERP7__Product__r.ERP7__Picture__c, Sales_Order_Line_Item__r.ERP7__Sales_Order__c from ERP7__Quote_Line_Items__c where ' +
                                                                                   '(ERP7__Quotes__c =\'' + String.escapeSingleQuotes(quoteId) + '\') order by Name ASC'); 
            QLines = new List<QLine>();
            for (ERP7__Quote_Line_Items__c qli: QLIS) QLines.add(new QLine(qli));
            
            return Null;
            
        } catch(Exception e) { exceptionMethod(e, 'EditQuoteLines'); return Null; }
    }

    public PageReference SaveQuoteLines(){
        try{
            if(QLIS.size() > 0){ if(Schema.sObjectType.ERP7__Quote_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.isUpdateable()) { upsert QLIS; } else{ /*not allwed */ } } 
            PageReference page = new PageReference('/'+ Quote.Id);
            page.setRedirect(true);
            return page;
        } catch(Exception e) { exceptionMethod(e, 'Quote2SalesOrder'); return Null; }
    }
    
    public PageReference Quote2SalesOrder(){
        try{
            Quote = Database.query('select ' + String.escapeSingleQuotes(QFields) + ' from ERP7__Quotes__c where ' + '(Id =\'' + String.escapeSingleQuotes(quoteId) + '\') Limit 1');
            
            QLIS = Database.query('select ' + String.escapeSingleQuotes(QLIFields) + ' , ERP7__Product__r.Name, ERP7__Product__r.ProductCode, ERP7__Product__r.ERP7__Picture__c, Sales_Order_Line_Item__r.ERP7__Sales_Order__c from ERP7__Quote_Line_Items__c where ' +
                                                                                   '(ERP7__Quotes__c =\'' + String.escapeSingleQuotes(quoteId) + '\') order by Name ASC'); 
            QLines = new List<QLine>();
            
            for (ERP7__Quote_Line_Items__c qli: QLIS) QLines.add(new QLine(qli));
            
            return Null;
            
        } catch(Exception e) { exceptionMethod(e, 'Quote2SalesOrder'); return Null; }
    }

    public PageReference SalesOrder2QuoteCancel(){
        try{
            PageReference page = new PageReference('/'+ SalesOrder.Id);
            page.setRedirect(true);
            return page;
        } catch(Exception e) { exceptionMethod(e, 'Quote2SalesOrder'); return Null; }
    }

    public void QuantityChange() {  
        QLine qli = QLines[countR];
        if(qli.qli.ERP7__Base_Price__c == Null) qli.qli.ERP7__Base_Price__c = 0;
        if(qli.qli.ERP7__Quantity__c == Null) qli.qli.ERP7__Quantity__c = 0;
        qli.qli.ERP7__Total_Price__c = qli.qli.ERP7__Base_Price__c * qli.qli.ERP7__Quantity__c;
    }
      
    public void exceptionMethod(Exception e, String methodName) {    
        exceptionMsg = 'Inside ' + methodName +', '+ e.getTypeName() +', '+ e.getMessage() +', Line : '+ e.getLineNumber();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,exceptionMsg));
    }
    
    public class QLine {
        public ERP7__Quote_Line_Items__c qli    { get; set; }
        public Boolean selectLine                    { get; set; }
        public Boolean selectPush                    { get; set; }
        
        public QLine(ERP7__Quote_Line_Items__c qli){
            this.qli = qli;
            selectLine = false;
            selectPush = false;
        }
    }
}