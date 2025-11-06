public with sharing class CreateTO {
    
    @AuraEnabled public String channel {get; set;}
    @AuraEnabled public ERP7__Distribution_Channel__c distributionChannel {get; set;}
    @AuraEnabled public Boolean showToChannel   {get; set;}
    @AuraEnabled public Boolean showDCbelow   {get; set;}
    @AuraEnabled public Boolean dontdefaultDC   {get; set;}
    @AuraEnabled public Boolean showTOName   {get; set;}
    @AuraEnabled public Boolean showReadyPickPickTO   {get; set;}
    @AuraEnabled public Boolean processSNBatch   {get; set;}
    
    public class CustomException extends Exception {}
    
    public CreateTO(){
        channel = '';
        distributionChannel = new ERP7__Distribution_Channel__c();
        showToChannel = showDCbelow = false;
    }
    /* 
@AuraEnabled
public static List < String > getTOStatuspickval() {
List < String > options = new List < String > ();
//options.add('--None--');
Schema.DescribeFieldResult fieldResult = Transfer_Order__c.Status__c.getDescribe();

List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();

for (Schema.PicklistEntry f: ple) {
System.debug('label~>'+f.getLabel()+' Picklist API Name:' + f.getValue()); 
options.add(f.getLabel());
}
return options;
}
*/
    
    public class OptionWrap{
        @AuraEnabled Public String value   { get; set;}
        @AuraEnabled Public String label   { get; set;}
        
        public OptionWrap(String Id, String lab){
            value = Id;
            label = lab;
        }
    }
    
    @AuraEnabled
    public static List<OptionWrap> getTOStatuspickval(){
        List<OptionWrap> options = new List<OptionWrap>();
        Schema.DescribeFieldResult fieldResult = ERP7__Transfer_Order__c.ERP7__Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(new OptionWrap(f.getValue(), f.getLabel()));
        }
        return options;
    }
    
    @AuraEnabled
    public static List <String> getTOshipmenttype() {
        List < String > options = new List < String > ();
        //options.add('--None--');
        Schema.DescribeFieldResult fieldResult = ERP7__Transfer_Order__c.ERP7__Shipment_type__c.getDescribe();
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static CreateTO fetchChannelandDC(){
        CreateTO CT = new CreateTO();
        try{
            List<ERP7__Employees__c> empList = new List<ERP7__Employees__c>();
            empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c where ERP7__Employee_User__c=:UserInfo.getUserId()];
            if(empList.size()>0){
                Integer a = 0;
                CT.channel = empList[a].ERP7__Channel__c;
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c, ERP7__Active__c from ERP7__Distribution_Channel__c where ERP7__Channel__c=:empList[a].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                if(dcList.size()>0 && dcList != null) CT.distributionChannel = dcList[a];
            }
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            
            if(FC == null){
                FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   
                if(FC == null) FC = ERP7__Functionality_Control__c.getInstance();  
            }
            
            if(FC != null){
                CT.showToChannel = FC.ERP7__show_TO_tochannel__c; 
                CT.showDCbelow = FC.ERP7__Show_DC_below__c;
                CT.dontdefaultDC = FC.ERP7__dont_default_dc__c;
                CT.showTOName = FC.ERP7__showTOName__c;
                CT.showReadyPickPickTO = FC.ERP7__showReadyPickPackTO__c;
                CT.processSNBatch = FC.ERP7__processSNorBatchTO__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        } 
        
        return CT;
    }
    
    @AuraEnabled
    public static CreateTO getSitefromDC(String DChannel){
        CreateTO CT = new CreateTO();
        try{
            // List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c where ERP7__Employee_User__c=:UserInfo.getUserId()];
            if(DChannel != '' && DChannel != null){
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c, ERP7__Active__c from ERP7__Distribution_Channel__c where Id=:DChannel and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                
                if(dcList.size()>0 && dcList != null){
                    CT.channel = dcList[0].ERP7__Channel__c;
                    CT.distributionChannel = dcList[0];
                } 
                
            }
            return CT; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber()); } 
        
        
    }
    
    @AuraEnabled
    public static Product2 fetchProductDetails(String currProdId){
        try{
            Product2 currProduct = new Product2();
            if(String.isNotEmpty(currProdId)){
                currProduct = [SELECT Id, Name, ERP7__Lot_Tracked__c, ERP7__Serialise__c FROM Product2 WHERE Id =: currProdId LIMIT 1];
            }
            return currProduct; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber()); } 
        
    }
    
    @AuraEnabled
    public static Decimal fetchProductInventoryStock(String currProdId, String siteId){
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
        dc = [select Id, ERP7__Site__c from ERP7__Distribution_Channel__c where Id = :siteId];
        if(dc.Id != null){
            if(dc.ERP7__Site__c != null){
                List<ERP7__Inventory_Stock__c> productInventories = [Select Id, Name, ERP7__product__c, ERP7__Warehouse__c, ERP7__Number_of_Item_In_Stock__c From ERP7__Inventory_Stock__c Where ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 And ERP7__Warehouse__c =: dc.ERP7__Site__c];
                if (productInventories != null && productInventories.size()>0) {
                    Decimal totalQuantity = 0;
                    for(ERP7__Inventory_Stock__c IS : productInventories) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c; 
                    return totalQuantity;
                }
            }
        }
        
        return 0;
    }
    
    @AuraEnabled
    public static Decimal fetchBatchProductInventoryStock(String currProdId, String currBatchLot, String siteId){
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
        dc = [select Id, ERP7__Site__c from ERP7__Distribution_Channel__c where Id = :siteId];
        
        List<ERP7__Inventory_Stock__c> productInventories = [Select Id, Name, ERP7__product__c, ERP7__Number_of_Item_In_Stock__c, ERP7__Warehouse__c From ERP7__Inventory_Stock__c Where ERP7__Batch_Lot__c =: currBatchLot AND ERP7__Product__c =: currProdId And ERP7__Active__c = true And ERP7__Number_of_Item_In_Stock__c > 0 And ERP7__Warehouse__c =: dc.ERP7__Site__c];
        
        if (productInventories != null && productInventories.size()>0) {
            Decimal totalQuantity = 0;
            for(ERP7__Inventory_Stock__c IS : productInventories) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c; 
            return totalQuantity;
        }
        return 0;
    }
    
    @AuraEnabled
    public static ERP7__Transfer_Order__c save_TO(String newTO, String toliList){
        try{
            ERP7__Transfer_Order__c to = new ERP7__Transfer_Order__c();
            List<ERP7__Transfer_Order_Line_Items__c> tolis = new List<ERP7__Transfer_Order_Line_Items__c>();
            ERP7__Channel__c fromchn = new ERP7__Channel__c();
            if(String.isNotEmpty(newTO) && String.isNotEmpty(toliList)){
                to = (ERP7__Transfer_Order__c) JSON.deserialize(newTO, ERP7__Transfer_Order__c.class);
                if(to.ERP7__Channel__c != null){
                    fromchn = [Select Id,Name,ERP7__Active__c,ERP7__Organisation__c from ERP7__Channel__c where Id =: to.ERP7__Channel__c];
                }
                Id inventoryTO; inventoryTO = Schema.SObjectType.ERP7__Transfer_Order__c.getRecordTypeInfosByDeveloperName().get('Inventory').getRecordTypeId();
                tolis = (List<ERP7__Transfer_Order_Line_Items__c>) JSON.deserialize(toliList, List<ERP7__Transfer_Order_Line_Items__c>.class);
                if(tolis.size() > 0){
                    if(Schema.sObjectType.ERP7__Transfer_Order__c.fields.ERP7__Requested_Date__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order__c.fields.ERP7__Requested_Date__c.isUpdateable()) to.ERP7__Requested_Date__c = system.today();
                    ERP7__Distribution_Channel__c dc = [Select Id, Name, ERP7__Site__c, ERP7__Site__r.ERP7__Address__c, ERP7__Active__c from ERP7__Distribution_Channel__c where Id =: to.ERP7__To_Distribution_Channel__c limit 1];
                    if(Schema.sObjectType.ERP7__Transfer_Order__c.fields.ERP7__To_Site__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order__c.fields.ERP7__To_Site__c.isUpdateable()) to.ERP7__To_Site__c = dc.ERP7__Site__c;
                    if(Schema.sObjectType.ERP7__Transfer_Order__c.fields.ERP7__To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order__c.fields.ERP7__To_Address__c.isUpdateable()) to.ERP7__To_Address__c = dc.ERP7__Site__r.ERP7__Address__c;
                    to.ERP7__Barcode__c = to.Name;
                    if(inventoryTO != null) to.recordTypeId = inventoryTO;
                    if(fromchn.Id != null){
                        if(fromchn.ERP7__Organisation__c != null){ to.ERP7__Organisation__c = fromchn.ERP7__Organisation__c; }
                    }
                    Boolean readytopick = to.ERP7__Ready_To_Pick_Pack__c;
                    system.debug('readytopick~>'+readytopick);
                    if(to.ERP7__Ready_To_Pick_Pack__c){ to.ERP7__Ready_To_Pick_Pack__c = false; }  
                    if(Schema.sObjectType.ERP7__Transfer_Order__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order__c.isUpdateable()) { upsert to; } else { }
                    for(Integer i = 0;i<tolis.size();i++){
                        if(Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.isUpdateable()) tolis[i].ERP7__Transfer_Order__c = to.Id;
                        if(Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.fields.ERP7__From_Site__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.fields.ERP7__From_Site__c.isUpdateable()) tolis[i].ERP7__From_Site__c = to.ERP7__From_Site__c;
                        if(Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.fields.ERP7__To_Site__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.fields.ERP7__To_Site__c.isUpdateable()) tolis[i].ERP7__To_Site__c = to.ERP7__To_Site__c;
                        if(fromchn.Id != null){
                            if(fromchn.ERP7__Organisation__c != null){ tolis[i].ERP7__Organisation__c = fromchn.ERP7__Organisation__c; }
                        }
                    }
                    if(Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Transfer_Order_Line_Items__c.isUpdateable()) {upsert tolis;} else { }
                    if(readytopick){ system.debug('updating TO'); to.ERP7__Ready_To_Pick_Pack__c = true; update to; }  //UpdateReadyPickPackTO(to.Id);
                    return to; 
                }else{ throw new customException('Error Occured'); } 
            }else{ throw new customException('Error Occured'); } 
        } catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } 
    }
    
    /*
@future
public static void UpdateReadyPickPackTO(String ToId){
if(String.isNotEmpty(ToId)){
try{
ERP7__Transfer_Order__c TO = [select Id, Name, ERP7__Ready_To_Pick_Pack__c from ERP7__Transfer_Order__c Where Id =: ToId];
if(TO.Id != null){ TO.ERP7__Ready_To_Pick_Pack__c = true; update TO; }
} catch (Exception e) { System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString()); throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString()); } 
}
}
*/
    
    @AuraEnabled
    public static Boolean checkInventories(String siteId, String ProductId, Integer quan){
        ERP7__Distribution_Channel__c dc = new ERP7__Distribution_Channel__c();
        dc = [select Id, ERP7__Site__c from ERP7__Distribution_Channel__c where Id = :siteId];
        if(dc.ERP7__Site__c !=null){ List<Inventory_Stock__c> invList = new List<Inventory_Stock__c>(); invList = [Select Id, Name, Active__c, Warehouse__c, Fixed_Asset__c, ERP7__Batch_Lot__c, ERP7__Version__c, Product__c, Number_of_Item_In_Stock__c, Checked_In_Date__c From Inventory_Stock__c Where (Product__c = :ProductId Or Fixed_Asset__c =: ProductId) And ERP7__Active__c = true And ERP7__Warehouse__c =: dc.ERP7__Site__c And ERP7__Number_of_Item_In_Stock__c > 0 Order By Checked_In_Date__c ASC]; Decimal totalQuantity = 0; if (invList != null && invList.size()>0) { for(ERP7__Inventory_Stock__c IS : invList) totalQuantity += IS.ERP7__Number_of_Item_In_Stock__c; } if(quan>totalQuantity) return false; else return true; }
        else{ return false; }
    }
    // For dependent Picklist
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    @AuraEnabled 
    public static PicklistWrapper getDependentPicklistMap(String ObjectName, string parentField, string childField) {
        System.debug('ObjectName : '+ObjectName);
        System.debug('parentField: '+parentField);
        System.debug('childField: '+childField);
        Map<String,List<String>> pickListMap = new Map<String,List<String>>();
        PicklistWrapper pw = new PicklistWrapper();
        pw.pickListMap = pickListMap;
        
        if (Schema.getGlobalDescribe().get(ObjectName) ==null || String.isBlank(parentField) || String.isBlank(ChildField)){ return pw; }
        
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(ObjectName).newSObject().getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(parentField) || !objFieldMap.containsKey(childField)){ return pw;      }
        
        List<PicklistEntryWrapper> depEntries = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(objFieldMap.get(ChildField).getDescribe().getPicklistValues()), List<PicklistEntryWrapper>.class);
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : objFieldMap.get(parentField).getDescribe().getPicklistValues()) {
            pickListMap.put(ple.getLabel(), new List<String>());
            controllingValues.add(ple.getLabel());
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    pickListMap.get(controllingValues.get(i)).add(plew.label);
                }
            }
        }
        
        pw.pickListMap = pickListMap;
        pw.parentFieldLabel = objFieldMap.get(parentField).getDescribe().getLabel();
        pw.childFieldLabel = objFieldMap.get(childField).getDescribe().getLabel();
        return pw;
    }
    @AuraEnabled
    public static wrapProd getProdDetails(String prodId,String DCId){
        if(prodId != null && prodId != ''){
            wrapProd result = new wrapProd();
            Product2 prod = [Select Id,Name,ERP7__Vendor_product_Name__c,Description,ProductCode,ERP7__Purchase_Lead_Time_days__c,ERP7__Serialise__c,ERP7__Lot_Tracked__c from Product2 where Id =:prodId limit 1];
            String selectedSite = '';
            if(String.isNotEmpty(DCId)){
                List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where 
                                                                    Id=:DCId And Active__c = true order by ERP7__Priority__c ASC Limit 1];
                
                if(DistributionChannels.size() > 0) selectedSite= DistributionChannels[0].Site__c;
            }
            else{
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                    where ERP7__Employee_User__c=:UserInfo.getUserId()];
                if(empList.size()>0 && empList != null){
                    String channel = empList[0].ERP7__Channel__c;
                    List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                        From Distribution_Channel__c
                                                                        Where 
                                                                        Channel__c=:channel And Active__c = true order by ERP7__Priority__c ASC Limit 1];
                    
                    if(DistributionChannels.size() > 0) selectedSite= DistributionChannels[0].Site__c;
                }
            }
            List<AggregateResult> WIISLists = [Select ERP7__Product__c,SUM(ERP7__Number_of_Item_In_Stock__c) totalStock, SUM(ERP7__Number_of_Items_Awaiting_in_Stock__c) awaitingStock,SUM(ERP7__No_of_Items_Requested__c)requestedStocks FROM ERP7__Inventory_Stock__c   WHERE ERP7__Active__c = true   And ERP7__Warehouse__c =: selectedSite And (ERP7__Number_of_Item_In_Stock__c > 0 OR ERP7__No_of_Items_Requested__c > 0 OR ERP7__Number_of_Items_Awaiting_in_Stock__c > 0 ) AND ERP7__Product__c =: prodId GROUP BY ERP7__Product__c];   
            system.debug('WIISLists : '+WIISLists);
            result.product = prod;
            result.prodName = prod.Name;
            result.description = prod.Description;
            if(WIISLists.size() > 0) {
                result.stock = (Decimal) WIISLists[0].get('totalStock');
            }
            return  result;           
        }
        else return null;
    }
    public class wrapProd{
        @AuraEnabled public Product2 product            {get;set;}
        @AuraEnabled public String prodName            {get;set;}
        @AuraEnabled public String  VendorPartNumber {get;set;}
        @AuraEnabled public String ProductCode       {get;set;}
        @AuraEnabled public String description              {get;set;}
        @AuraEnabled public String venId             {get;set;}
        @AuraEnabled public String errMsg            {get;set;}
        @AuraEnabled public Decimal stock            {get;set;}
        @AuraEnabled public Decimal demand           {get;set;}
        @AuraEnabled public Decimal AwaitStock       {get;set;}
        @AuraEnabled public String selCostCardId     {get;set;}
        @AuraEnabled public Decimal LeadTime         {get;set;} 
        @AuraEnabled public Decimal cost             {get;set;}
        public wrapProd(){
            product     = new Product2();
            prodName            = '';
            VendorPartNumber = '';
            ProductCode      = '';
            description            = '';
            venId            = '';
            errMsg            = '';
            stock           =0; 
            demand            =0; 
            AwaitStock       =0; 
            selCostCardId   = '';
            LeadTime         =0; 
            cost             =0;
        }
    }
    
    //Refer from here https://salesforce.stackexchange.com/questions/4462/get-lists-of-dependent-picklist-options-in-apex
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    public class PicklistWrapper{
        @AuraEnabled
        public Map<String, List<String>> pickListMap;
        @AuraEnabled
        public String parentFieldLabel;
        @AuraEnabled
        public String childFieldLabel;      
    }
    
    public class PicklistEntryWrapper{
        public String active;
        public String defaultValue;
        public String label;
        public String value;
        public String validFor;
        
    }
    
}