public With Sharing class Receiving_Label {
    public String loIds                                             { get; set; }
    public String MOIds                                             { get; set; }
    public String LotIds                                             { get; set; }
    public String sfdcBaseURL                                       { get; set; }
    public Map<ERP7__Logistic_Line_Item__c,List<ERP7__Stock_Inward_Line_Item__c>> logstockList { get; set; }
    public wrapper wrap   { get; set; }
    public Receiving_Label() {
        try {
          wrap = new wrapper();
            logstockList = new Map<ERP7__Logistic_Line_Item__c,List<ERP7__Stock_Inward_Line_Item__c>>();
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            
            String initurl = Label.initURL;
            String DestinationURL = Label.DestURL;
            
            sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL);
            sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');  //need to be uncommented
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            loIds = '';
            if(ApexPages.CurrentPage().getParameters().get('loIds') != Null) loIds = ApexPages.CurrentPage().getParameters().get('loIds');
            
            MOIds = '';
            if(ApexPages.CurrentPage().getParameters().get('MOId') != Null) MOIds = ApexPages.CurrentPage().getParameters().get('MOId');
            
            LotIds = '';
            
            if(ApexPages.CurrentPage().getParameters().get('LotId') != Null) LotIds = ApexPages.CurrentPage().getParameters().get('LotId');
            system.debug('LotIds : '+LotIds);
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +' Line Number @ : '+ e.getLineNumber())); }
    }
    
    public PageReference createLabel(){
         //wrap = new wrapper();
        if(loIds != '' && loIds != null){
            String prodFields = UtilClass.selectStarFromSObject('Product2');
            utilClass.FLSCheck(prodFields.split(','),'Product2');
            List<String> LogisticIds = loIds.split(',');
            Set<Id> lineIds = new Set<Id>();
            wrap.Logistics = [Select Id,Name,ERP7__Purchase_Order__c from ERP7__Logistic__c where Id In:LogisticIds];
            wrap.logline = [Select Id,Name ,ERP7__Product__c,ERP7__Logistic__r.ERP7__Purchase_Order__c,(Select Id,Name,ERP7__Product__c,ERP7__Material_Batch_Lot__c,ERP7__Serial__c,ERP7__Material_Batch_Lot__r.ERP7__Shelf_Life_Expiration_Date__c,ERP7__Material_Batch_Lot__r.Name,createdDate  from Stock_Inward_Line_Items__r) from ERP7__Logistic_Line_Item__c where ERP7__Logistic__c In : LogisticIds];
            for(ERP7__Logistic_Line_Item__c log : wrap.logline)  lineIds.add(log.Id);   
            wrap.stcklist = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Name,ERP7__Product__r.ProductCode,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Material_Batch_Lot__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Shelf_Life_Expiration_Date__c,ERP7__Material_Batch_Lot__r.ERP7__Shelf_Life_Expiration_Date__c,ERP7__Material_Batch_Lot__r.Name,CreatedDate,ERP7__Logistic__r.ERP7__Purchase_Order__c , ERP7__Logistic__r.ERP7__Purchase_Order__r.Name,ERP7__Quantity__c from ERP7__Stock_Inward_Line_Item__c where (ERP7__Logistic_Line_Item__c In: lineIds OR ERP7__Logistic__c IN :LogisticIds)  and ERP7__Quantity__c > 0 and ERP7__Status__c != 'Awaiting Stock'];
        }
        else if(MOIds != null && MOIds != ''){
            wrap.stcklist = [Select Id,Name,ERP7__Product__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Product__r.ProductCode,ERP7__Product__r.Name,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Vendor_product_Name__c,ERP7__Material_Batch_Lot__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Shelf_Life_Expiration_Date__c,ERP7__Material_Batch_Lot__r.ERP7__Shelf_Life_Expiration_Date__c,ERP7__Material_Batch_Lot__r.Name,CreatedDate,ERP7__Logistic__r.ERP7__Purchase_Order__c , ERP7__Logistic__r.ERP7__Purchase_Order__r.Name,ERP7__Manufacturing_Order__c,ERP7__Manufacturing_Order__r.Name,ERP7__Quantity__c from ERP7__Stock_Inward_Line_Item__c where (ERP7__Manufacturing_Order__c =: MOIds and ERP7__Quantity__c > 0 and ERP7__Status__c != 'Awaiting Stock')];
        }
         if(LotIds != null && LotIds != ''){
            List<batchWrap> batchwrp = new List<batchWrap>();
            batchWrap lotwrp = new batchWrap();
            ERP7__Batch__c batch = [Select Id,Name,ERP7__Available_Quantity__c,ERP7__Product__r.QuantityUnitOfMeasure,ERP7__Shelf_Life_Expiration_Date__c,CreatedDate,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Product__r.ProductCode,ERP7__Barcode__c from ERP7__Batch__c where Id = :LotIds limit 1];
        	lotwrp.lot =batch;
            system.debug('batch : '+batch);
            List<ERP7__Inventory_Stock__c> invlist = [Select Id,Name,ERP7__Batch_Lot__c,ERP7__Warehouse__c,ERP7__Warehouse__r.Name,ERP7__Location__c,ERP7__Location__r.Name,ERP7__Number_of_Item_In_Stock__c from ERP7__Inventory_Stock__c where ERP7__Number_of_Item_In_Stock__c > 0 and ERP7__Batch_Lot__c != null and ERP7__Batch_Lot__c = :LotIds];
            system.debug('invlist : '+invlist.size());
            string availableSites = '';
            for(ERP7__Inventory_Stock__c inv : invlist){
                system.debug('availableSites : '+availableSites);
                if(inv.ERP7__Warehouse__c != null && !availableSites.contains(inv.ERP7__Warehouse__r.Name)) availableSites =  (availableSites == '') ? inv.ERP7__Warehouse__r.Name : (availableSites + ',' + inv.ERP7__Warehouse__r.Name);
                if(inv.ERP7__Location__c != null && !availableSites.contains(inv.ERP7__Location__r.Name)) availableSites += '->'+inv.ERP7__Location__r.Name;
            }
            lotwrp.availableLocations =availableSites; 
            batchwrp.add(lotwrp);
            wrap.Lotlist = batchwrp;
        }
        /*for(ERP7__Logistic_Line_Item__c stk : wrap.logline){
            if(logstockList.containsKey(stk)){
               logstockList.get(stk).add(stk.Stock_Inward_Line_Items__r); 
            }
            else{
               logstockList.put(stk,stk.Stock_Inward_Line_Items__r); 
            }
        }*/
        return Null;
    }
    public class wrapper{
        public List<ERP7__Logistic_Line_Item__c> logline                                  {get;set;}
        public List<ERP7__Logistic__c> Logistics                                                  {get;set;}
        public PrintBarcodes PB                                         {get; set;}
        public List<ERP7__Stock_Inward_Line_Item__c>      stcklist                {get; set;}
        public List<batchWrap>      Lotlist                {get; set;}
        
        public wrapper(){
           logline = new  List<ERP7__Logistic_Line_Item__c>();
           Logistics = new List<ERP7__Logistic__c>();
           PB = new  PrintBarcodes();
           stcklist = new List<ERP7__Stock_Inward_Line_Item__c> ();
            Lotlist = new List<batchWrap>();
        }
    }
    public class batchWrap{
        public ERP7__Batch__c lot        { get; set; }
        public string availableLocations { get; set; }
        public batchWrap(){
            lot = new ERP7__Batch__c();
            availableLocations = '';
        }
    }
}