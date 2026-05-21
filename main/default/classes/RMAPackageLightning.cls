public with sharing class RMAPackageLightning {
    
    public class CustomException extends Exception {}
     
    @AuraEnabled
    public static String getobjName(){
        String ObjectLabel = SObjectType.ERP7__Return_Merchandise_Authorisation__c.getLabel();
        return ObjectLabel;
    }    
    
    public class InitWrapper{
        @AuraEnabled public ERP7__Return_Merchandise_Authorisation__c RMA {get; set;}
        @AuraEnabled public String defaultShipmentType {get; set;}
        @AuraEnabled public String defaultShipmentSpeed {get; set;}
        @AuraEnabled public Boolean showSSType                                       { get; set; }
        @AuraEnabled public Boolean disablePackName                                       { get; set; }
        @AuraEnabled public Boolean disablePackDeclaredValue                                       { get; set; }
        @AuraEnabled public Boolean allowZerodeclaredValue   	{ get; set; }
        @AuraEnabled public Boolean disableShipType				{ get; set; }
        public InitWrapper(){
            RMA = new ERP7__Return_Merchandise_Authorisation__c();
            defaultShipmentType = defaultShipmentSpeed = '';
            showSSType = disablePackName = disablePackDeclaredValue = allowZerodeclaredValue = disableShipType = false;
        }
    }
    
    @AuraEnabled
    public static InitWrapper displayRMA(String returnId){
        try{
            if(String.isNotEmpty(returnId)){
                InitWrapper wrap = new InitWrapper();
                ERP7__Return_Merchandise_Authorisation__c returnRMA = [Select Id, Name,ERP7__Order__c,ERP7__Order__r.Name,ERP7__Order__r.ERP7__Shipment_Type__c,ERP7__Order__r.ERP7__Shipment_Preference_Speed__c from ERP7__Return_Merchandise_Authorisation__c where Id=:returnId];
                wrap.RMA = returnRMA;
                if(returnRMA.ERP7__Order__c != null){ if(String.isNotEmpty(returnRMA.ERP7__Order__r.ERP7__Shipment_Type__c)) wrap.defaultShipmentType = returnRMA.ERP7__Order__r.ERP7__Shipment_Type__c; if(String.isNotEmpty(returnRMA.ERP7__Order__r.ERP7__Shipment_Preference_Speed__c)) wrap.defaultShipmentSpeed = returnRMA.ERP7__Order__r.ERP7__Shipment_Preference_Speed__c;
                }
                
                ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
                customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
                if(customList == null){ 
                    customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
                    if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
                }
                if(customList != null){
                    wrap.showSSType = customList.ERP7__Pack_Shipment_Service_Type_Display__c;
                    wrap.disablePackName = customList.ERP7__disablePackName__c;
                    wrap.disablePackDeclaredValue = customList.ERP7__disablePackDeclaredValue__c;
                    wrap.allowZerodeclaredValue = customList.ERP7__Allow_zero_declared_value_in_Pack__c;
                    wrap.disableShipType = customList.ERP7__Disable_Shipment_type_in_Pack__c;
                }
                
                return wrap; }else return null; } catch (Exception e){ throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
    }
    
    @AuraEnabled
    public static List<String> getWeightUnits(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = ERP7__Package__c.ERP7__Weight_Unit__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<String> getPackageType(){
        List<String> options = new List<String>(); Schema.DescribeFieldResult fieldResult = ERP7__Package__c.ERP7__Package_Type__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(f.getLabel());} return options;
    }
    
    @AuraEnabled
    public static List<String> getShipmentType(){
        List<String> options = new List<String>(); Schema.DescribeFieldResult fieldResult = ERP7__Package__c.ERP7__Shipment_Type__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {options.add(f.getLabel());} return options;
    }
    
    @AuraEnabled
    public static ERP7__Package__c populatePackDetails(String Package2Create1, String pkgTypeValue){
        ERP7__Package__c Package2Create = (ERP7__Package__c) JSON.deserialize(Package2Create1, ERP7__Package__c.class);
        try { 
            String PackageCustomSettingFields = UtilClass.selectStarFromSObject('ERP7__Package_Details__c');
            utilClass.FLSCheck(PackageCustomSettingFields.split(','),'ERP7__Package_Details__c');  
            List<Package_Details__c> pkgDetailList = new List<Package_Details__c>();
            if(String.isNotEmpty(pkgTypeValue) && pkgTypeValue != '--None--') {
                pkgDetailList = Database.query('select ' + String.escapeSingleQuotes(PackageCustomSettingFields) + ' from ERP7__Package_Details__c where (Package_Type__c =\'' + String.escapeSingleQuotes(pkgTypeValue) + '\') Limit 1');                             
                if(pkgDetailList.size() > 0) { 
                    //Package2Create.Shipment_Type__c = 'UPS';   
                    Package2Create.ERP7__Length__c = pkgDetailList[0].ERP7__Length__c;
                    Package2Create.ERP7__Width__c = pkgDetailList[0].ERP7__Width__c;
                    Package2Create.ERP7__Height__c = pkgDetailList[0].ERP7__Height__c;
                    Package2Create.ERP7__Weight__c = pkgDetailList[0].ERP7__Weight__c;
                    Package2Create.ERP7__Weight_Unit__c = pkgDetailList[0].ERP7__Weight_Unit__c;
                    Package2Create.ERP7__Description__c = pkgDetailList[0].ERP7__Shipment_Description__c;
                    return Package2Create; } else throw new customException('Sorry, selected package type not available.'); } else return null; /* else throw new customException('Sorry, selected package type not available.'); */ } catch(Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); }
        
    }
   /* @AuraEnabled
    public static ERP7__Package__c fetchPackageDetails(String packType){
        ERP7__Package__c packages = new ERP7__Package__c();
        try{
            String packtypestr = '';
            if(String.isNotEmpty(packType)) packtypestr = packType;
            List<ERP7__Package_Details__c> packDetails = new List<ERP7__Package_Details__c>();
            packDetails = [Select Id, Name, ERP7__Additional_Percentage__c, ERP7__Height__c, ERP7__Length__c,
                           ERP7__Package_Type__c, ERP7__Shipment_Description__c, ERP7__Type__c, ERP7__Weight__c,
                           ERP7__Weight_Unit__c, ERP7__Width__c from ERP7__Package_Details__c where 
                           ERP7__Package_Type__c=:packType Limit 1];
            if(packDetails.size()>0) {
                packages.ERP7__Length__c = packDetails[0].ERP7__Length__c;
                packages.ERP7__Width__c = packDetails[0].ERP7__Width__c;
                packages.ERP7__Height__c = packDetails[0].ERP7__Height__c;
                packages.ERP7__Weight__c = packDetails[0].ERP7__Weight__c;
                packages.ERP7__Weight_Unit__c = packDetails[0].ERP7__Weight_Unit__c;
                packages.ERP7__Description__c = packDetails[0].ERP7__Shipment_Description__c;
            }
            return packages;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
    }
    */
    @AuraEnabled
    public static List<RMAPackageWrapper> fetchRMALineItems(String returnId){
        List<RMAPackageWrapper> rmaWrapperList = new List<RMAPackageWrapper>();
        try{
            if(String.isNotEmpty(returnId)) {
                for(ERP7__RMA_Line_Item__c rmaLi: [Select Id, Name, ERP7__Product__c, ERP7__Product__r.Name,ERP7__Product__r.ERP7__Serialise__c,ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Return_Merchandise_Authorisation__c,ERP7__Return_Merchandise_Authorisation__r.Name,ERP7__Site_Item_Inventory_Stock__c, ERP7__Ord_Item__c,
                                                   ERP7__Return_Merchandise_Authorisation__r.ERP7__SO__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__SO__r.Name,
                                                   ERP7__Return_Merchandise_Authorisation__r.ERP7__Order__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Order__r.Name,
                                                   ERP7__Serial_Number__r.ERP7__Serial_No__c, ERP7__Batch_Lot__r.Name,ERP7__Acceptance_Type__c,
                                                   ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__r.Name, ERP7__Quantity_Return__c from ERP7__RMA_Line_Item__c
                                                   where ERP7__Return_Merchandise_Authorisation__c=:returnID]) {
                                                       RMAPackageWrapper rmaWrap = new RMAPackageWrapper();
                                                       rmaWrap.rma = rmaLi;
                                                       rmaWrapperList.add(rmaWrap);
                                                   }
            }
            return rmaWrapperList; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
    }
    
    @AuraEnabled
    public static List<ERP7__Package__c> savePackageDetails(string pkg1, String rmaLiWrapList, String rmaId, String SOLIs){
        try{
            List<ERP7__Package_List__c> packList = new List<ERP7__Package_List__c>();
            
            if(String.isNotEmpty(rmaId)){
                ERP7__Package__c pkg = (ERP7__Package__c) JSON.deserialize(pkg1, ERP7__Package__c .class);
                
                ERP7__Return_Merchandise_Authorisation__c rma = [Select Id, Name from ERP7__Return_Merchandise_Authorisation__c where ID=:rmaId];
                if(Schema.sObjectType.ERP7__Package__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Package__c.fields.Name.isUpdateable()) pkg.Name = 'PKG-'+rma.Name;
                if(Schema.sObjectType.ERP7__Package__c.fields.ERP7__Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.ERP7__Package__c.fields.ERP7__Return_Merchandise_Authorisation__c.isUpdateable()) pkg.ERP7__Return_Merchandise_Authorisation__c = rmaId;
                if(Schema.sObjectType.ERP7__Package__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Package__c.fields.ERP7__Active__c.isUpdateable()) pkg.ERP7__Active__c = true;
                if(pkg != null && Schema.sObjectType.ERP7__Package__c.isCreateable() && Schema.sObjectType.ERP7__Package__c.isUpdateable()){ upsert pkg;}else{/* not allowed*/ }
                
                if(String.isNotEmpty(rmaLiWrapList)){
                    List<RMAPackageWrapper> rmaWrapperList = (List<RMAPackageWrapper>) JSON.deserialize(rmaLiWrapList, List<RMAPackageWrapper>.class);
                    
                    for(RMAPackageWrapper wr: rmaWrapperList) {
                        ERP7__Package_List__c pl = new ERP7__Package_List__c();
                        
                        if(Schema.sObjectType.ERP7__Package_List__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Package_List__c.fields.Name.isUpdateable()) pl.Name = 'pkli-'+wr.rma.Name;
                        if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Package__c.isCreateable() && Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Package__c.isUpdateable() ) pl.ERP7__Package__c = pkg.Id;
                        if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Return_Merchandise_Authorisation__c.isUpdateable()) pl.ERP7__Return_Merchandise_Authorisation__c = rmaId;
                        if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__RMA_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__RMA_Line_Item__c.isUpdateable()) pl.ERP7__RMA_Line_Item__c = wr.rma.Id;
                        if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Quantity__c.isUpdateable()) pl.ERP7__Quantity__c = wr.rma.ERP7__Quantity_Return__c;
                        if(Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Package_List__c.fields.ERP7__Active__c.isUpdateable()) pl.ERP7__Active__c = true;
                        packList.add(pl); 
                    }
                    if(packList.size()>0){ if(Schema.sObjectType.ERP7__Package_List__c.isCreateable() && Schema.sObjectType.ERP7__Package_List__c.isUpdateable()){ upsert packList; }else{ /*not Allowed*/ } }
                }
                
                //Code Added by Parveez on 16-May-24 to Create Stock Outward Records for Replacement Items from RMA.
                list<ERP7__Stock_Outward_Line_Item__c> StockOutward2Insert = new list<ERP7__Stock_Outward_Line_Item__c>();
                if(String.isNotEmpty(SOLIs))StockOutward2Insert = (list<ERP7__Stock_Outward_Line_Item__c>) JSON.deserialize(SOLIs, list<ERP7__Stock_Outward_Line_Item__c> .class); 
                
                if(StockOutward2Insert.size()>0) {
                    
                    if(Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Stock_Outward_Line_Item__c.isUpdateable()){ 
                        insert StockOutward2Insert; 
                    }
                    else{ /*not Allowed*/ }  
                }
                
                return fetchingPackages(rmaId).packageslist; }else return null; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); }          
    }
    
    @AuraEnabled
    public static PackagesWrapper fetchingPackages(String returnID){
        PackagesWrapper pkgwrap = new PackagesWrapper();
        List<Package__c> packList = new List<Package__c>();
        try{
            if(String.isNotEmpty(returnID)){ 
                packList =  [Select Id, Name, ERP7__Weight__c, ERP7__Length__c, ERP7__Width__c,
                             ERP7__Height__c, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name,
                             ERP7__Active__c, ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__r.Name,
                             ERP7__Package_Type__c, ERP7__Shipment_Type__c,ERP7__Shipment_Service_Type__c, ERP7__Weight_Unit__c, ERP7__Status__c,
                             ERP7__Declared_Value__c, ERP7__Package_Quantity__c, ERP7__DropoffType__c, ERP7__Shipment__c, 
                             ERP7__Shipment__r.Name from ERP7__Package__c where ERP7__Return_Merchandise_Authorisation__c=:returnID];
                pkgwrap.packageslist = packList;
            }
            return pkgwrap; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
    }
    
    @AuraEnabled
    public static ERP7__Package__c editPackages(String packageID){
        try{
            if(String.isNotEmpty(packageID)){
                ERP7__Package__c editPackage = [Select Id, Name, ERP7__Weight__c, ERP7__Length__c, ERP7__Width__c,
                                                ERP7__Height__c, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name,
                                                ERP7__Active__c, ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__r.Name,
                                                ERP7__Package_Type__c, ERP7__Shipment_Type__c,ERP7__Shipment_Service_Type__c, ERP7__Weight_Unit__c, ERP7__Status__c,
                                                ERP7__Declared_Value__c, ERP7__Package_Quantity__c, ERP7__DropoffType__c, ERP7__Shipment__c, 
                                                ERP7__Shipment__r.Name from ERP7__Package__c where Id=:packageID];
                return editPackage; }else return null; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
        
    }
    
    @AuraEnabled
    public static List<ERP7__Package_List__c> fetchPackageListEdit(String packageID){
        try{
            List<ERP7__Package_List__c> packageList = new List<ERP7__Package_List__c>();
            if(String.isNotEmpty(packageID)){
                packageList = [Select Id, Name, ERP7__Package__c, ERP7__Package__r.Name, ERP7__Return_Merchandise_Authorisation__c,
                               ERP7__RMA_Line_Item__c, ERP7__RMA_Line_Item__r.Name, ERP7__Return_Merchandise_Authorisation__r.Name,
                               ERP7__Quantity__c from ERP7__Package_List__c where ERP7__Package__c=:packageID];
            }
            return packageList; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
    }
    
    @AuraEnabled
    public static List<ERP7__Package__c> deletePackages(String packID, String returnId){
        
        Package__c packList = new Package__c();
        List<ERP7__Package__c> packLists = new  List<ERP7__Package__c>();
        try{
            if(String.isNotEmpty(packID)){
                packList =  [Select Id, Name, ERP7__Weight__c, ERP7__Length__c, ERP7__Width__c,
                             ERP7__Height__c, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name,
                             ERP7__Active__c, ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__r.Name,
                             ERP7__Package_Type__c, ERP7__Shipment_Type__c,ERP7__Shipment_Service_Type__c, ERP7__Weight_Unit__c, ERP7__Status__c,
                             ERP7__Declared_Value__c, ERP7__Package_Quantity__c, ERP7__DropoffType__c, ERP7__Shipment__c, 
                             ERP7__Shipment__r.Name from ERP7__Package__c where Id=:packID];
                if(ERP7__Package__c.sObjectType.getDescribe().isDeletable()){ delete packList; } else{/*not allwoed*/}
            }
            if(String.isNotEmpty(returnId)){
                packLists = [Select Id, Name, ERP7__Weight__c, ERP7__Length__c, ERP7__Width__c,
                             ERP7__Height__c, ERP7__Return_Merchandise_Authorisation__c, ERP7__Return_Merchandise_Authorisation__r.Name,
                             ERP7__Active__c, ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__r.Name,
                             ERP7__Package_Type__c, ERP7__Shipment_Type__c, ERP7__Weight_Unit__c, ERP7__Status__c,
                             ERP7__Declared_Value__c, ERP7__Package_Quantity__c, ERP7__DropoffType__c, ERP7__Shipment__c, 
                             ERP7__Shipment__r.Name from ERP7__Package__c where ERP7__Return_Merchandise_Authorisation__c=:returnId];
            }
            return packLists; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
    }
    
    @AuraEnabled
    public static List<ERP7__Shipment__c> fetchShipments(String returnId){
        try{
            List<ERP7__Shipment__c> shipList = new List<ERP7__Shipment__c>();
            if(String.isNotEmpty(returnId)){
                shipList = [Select Id, Name, ERP7__Status_Duration__c, ERP7__Shipping_Address__c, ERP7__Billing_Address__c,
                            ERP7__Shipment_Date__c, ERP7__Tracking_Number__c,ERP7__TrackingNumber__c, ERP7__Shipping_Amount__c, ERP7__Status__c,RecordType.Name,
                            ERP7__Tracking_Unique_Id__c, ERP7__Customer_Contact__c, ERP7__Fedex_Service__c, ERP7__Active__c, 
                            ERP7__Description__c, ERP7__Unit__c, ERP7__Reason_For_Export__c, ERP7__Signature_Services__c, ERP7__Package__c,
                            ERP7__Return_Merchandise_Authorisation__r.Name, ERP7__Package__r.Name, ERP7__Customer__c, ERP7__Customer__r.Name
                            from ERP7__Shipment__c where ERP7__Return_Merchandise_Authorisation__c=:returnId AND ERP7__Active__c=true ]; //AND ERP7__Package__c != null
            }
            return shipList; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
    }
    
    @AuraEnabled
    public static List<ERP7__Shipment__c> deleteShipments(String shipId, String returnId){
        ERP7__Shipment__c shipment = new ERP7__Shipment__c();
        List<ERP7__Shipment__c> shipments = new List<ERP7__Shipment__c>();
        try{
            if(String.isNotEmpty(shipId)){
                shipment = [Select Id, Name, ERP7__Status_Duration__c, ERP7__Shipping_Address__c, ERP7__Billing_Address__c,
                            ERP7__Shipment_Date__c, ERP7__Tracking_Number__c,ERP7__TrackingNumber__c, ERP7__Shipping_Amount__c, ERP7__Status__c,RecordType.Name,
                            ERP7__Tracking_Unique_Id__c, ERP7__Customer_Contact__c, ERP7__Fedex_Service__c, ERP7__Active__c, 
                            ERP7__Description__c, ERP7__Unit__c, ERP7__Reason_For_Export__c, ERP7__Signature_Services__c, ERP7__Package__c,
                            ERP7__Return_Merchandise_Authorisation__r.Name, ERP7__Package__r.Name, ERP7__Customer__c, ERP7__Customer__r.Name
                            from ERP7__Shipment__c where Id=:shipId];
                if(ERP7__Shipment__c.sObjectType.getDescribe().isDeletable()){ delete shipment; } else{ /*not allowed*/}
            }
            if(String.isNotEmpty(returnId)){
                shipments = [Select Id, Name, ERP7__Status_Duration__c, ERP7__Shipping_Address__c, ERP7__Billing_Address__c,
                             ERP7__Shipment_Date__c, ERP7__Tracking_Number__c,ERP7__TrackingNumber__c, ERP7__Shipping_Amount__c, ERP7__Status__c,
                             ERP7__Tracking_Unique_Id__c, ERP7__Customer_Contact__c, ERP7__Fedex_Service__c, ERP7__Active__c, 
                             ERP7__Description__c, ERP7__Unit__c, ERP7__Reason_For_Export__c, ERP7__Signature_Services__c, ERP7__Package__c,
                             ERP7__Return_Merchandise_Authorisation__r.Name, ERP7__Package__r.Name, ERP7__Customer__c, ERP7__Customer__r.Name
                             from ERP7__Shipment__c where ERP7__Return_Merchandise_Authorisation__c=:returnId and ERP7__Active__c=true];
            }
            return shipments; } catch (Exception e) { throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString()); } 
    }
    
    public class RMAPackageWrapper{
        @AuraEnabled
        public Boolean isSelected {get; set;}
        @AuraEnabled
        public ERP7__RMA_Line_Item__c rma {get; set;}
        public RMAPackageWrapper(){
            isSelected = false;
            rma = new ERP7__RMA_Line_Item__c();
        }
    }
    
    public class PackagesWrapper{
        @AuraEnabled public List<ERP7__Package__c> packageslist {get; set;}
        @AuraEnabled public ERP7__Package__c packg {get; set;}
        public PackagesWrapper(){
            packageslist = new List<ERP7__Package__c>();
            packg = new ERP7__Package__c();
        }
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
    
    //Code Added by Parveez on 16-May-24 to get the Serial numbers Available for replacing Items on RMA  line 403 - line 526.
    
    public class SerialWrapper{
        @AuraEnabled public ERP7__Serial_Number__c SerialNo           { get; set; }
        @AuraEnabled public Boolean isSelected                        { get; set; }
        @AuraEnabled public String ProductsiteInventory                        	  { get; set; }
        
        public SerialWrapper(){ 
            SerialNo = new ERP7__Serial_Number__c();
            isSelected = false;
            ProductsiteInventory = '';
        }
    }
    
    public class comWrap {

        @AuraEnabled public Transient List<SerialWrapper> PickSelectedSerialNos               { get; set; }
        @AuraEnabled public Transient List<SerialWrapper> PickSerialNos                       { get; set; }
        @AuraEnabled public String exceptionError                                    { get; set; } 
        
        public comWrap() {
            
            exceptionError = '';
            PickSelectedSerialNos = new List<SerialWrapper>();
            PickSerialNos = new List<SerialWrapper>();
        }
    }
    
    @AuraEnabled
    public static comWrap PreparePickSerialNos(String RMALineId, String searchString){
        comWrap comW = new comWrap();
        try {
            List<SerialWrapper> SWL = new List<SerialWrapper>();
            List<SerialWrapper> ASWL = new List<SerialWrapper>();
            
            if(RMALineId != Null && RMALineId != ''){
                List<ERP7__RMA_Line_Item__c> RMAline = [SELECT Id,Name,ERP7__Return_Merchandise_Authorisation__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Distribution_Channel__r.ERP7__Site__c,ERP7__Quantity_Return__c,ERP7__Return_Merchandise_Authorisation__r.ERP7__Order__c, ERP7__Return_Reason__c, ERP7__Return_Status__c,ERP7__Added_Back_to_Inventory__c, ERP7__Site_Item_Inventory_Stock__c, ERP7__Number_of_Items_In_Quality_Check__c, ERP7__Batch_Lot_Code__c, ERP7__SOLI__c, ERP7__Product__c,ERP7__Acceptance_Type__c, ERP7__Serial_Number__c, ERP7__Batch_Lot__c,ERP7__Ord_Item__c  FROM ERP7__RMA_Line_Item__c where Id=:RMALineId limit 1];
                if(RMAline.size() > 0){
                    String siteId = (RMAline[0].ERP7__Return_Merchandise_Authorisation__r.ERP7__Distribution_Channel__r.ERP7__Site__c != Null) ? RMAline[0].ERP7__Return_Merchandise_Authorisation__r.ERP7__Distribution_Channel__r.ERP7__Site__c : '';
                    
                    
                    
                        set<Id> MoIds = new set<Id>();
                        set<Id> PoIds = new set<Id>();
                        List<ERP7__Manufacturing_Order__c> SOMOs = new List<ERP7__Manufacturing_Order__c>();
                        List<ERP7__PO__c> SOPOs = new List<ERP7__PO__c>();
                        
                        Id OrderId = RMAline[0].ERP7__Return_Merchandise_Authorisation__r.ERP7__Order__c;
                        Id OrderProdIds = RMAline[0].ERP7__Ord_Item__c;
                        if(OrderId != null && OrderProdIds != null){
                            SOMOs = [Select Id,Name from ERP7__Manufacturing_Order__c where (ERP7__Order_Product__c =:OrderProdIds and ERP7__Order__c =:orderId) and ERP7__Product__c =:RMAline[0].ERP7__Product__c];
                            System.debug('SOMOs : '+SOMOs.size());    
                        }
                        if(OrderId != null){
                            SOPOs = [Select Id,Name from ERP7__PO__c where ERP7__Order__c =:orderId and ERP7__Order__c != null and ERP7__Ready_To_Receive__c =:true];
                            System.debug('SOPOs : '+SOPOs.size());
                            
                        }
                        if(SOMOs.size() > 0 || SOPOs.size() > 0){ 
                            for(ERP7__Manufacturing_Order__c MO : SOMOs) MoIds.add(MO.Id);
                            for(ERP7__PO__c PO : SOPOs) PoIds.add(PO.Id);
                            system.debug('MoIds ~>'+MoIds);
                            
                            List<ERP7__Stock_Inward_Line_Item__c> stinlist = [Select Id,Name,Product__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Site_ProductService_InventoryStock__c from ERP7__Stock_Inward_Line_Item__c 
                                                                              where ERP7__Active__c = true and Product__c =:RMAline[0].ERP7__Product__c and ERP7__Scrap__c = false AND (ERP7__Purchase_Orders__c IN:PoIds or ERP7__Manufacturing_Order__c IN: MoIds) 
                                                                              AND ERP7__Quantity__c > 0 AND ERP7__Status__c != 'Awaiting Stock' and ERP7__Site_ProductService_InventoryStock__r.Number_of_Item_In_Stock__c > 0 and ERP7__Site_ProductService_InventoryStock__r.Warehouse__c =: siteId limit 500 ];   //:Integer.valueOf(remainingQty)                          
                            for(ERP7__Stock_Inward_Line_Item__c sin : stinlist){
                                if(sin.ERP7__Serial__c != null) {
                                    SerialWrapper SW = new SerialWrapper();
                                    SW.SerialNo = new ERP7__Serial_Number__c(Id=sin.ERP7__Serial__c, Name=sin.ERP7__Serial__r.Name);
                                    SW.ProductsiteInventory= sin.ERP7__Site_ProductService_InventoryStock__c;
                                    SWL.add(SW);
                                }
                            }
                        }
                    
                    comW.PickSelectedSerialNos = SWL;
                    searchString = '%'+searchString+'%';
                    List<ERP7__Inventory_Stock__c> inverntoryStocklst = new List<ERP7__Inventory_Stock__c>();
                    List<ERP7__Serial_Number__c> serlst = [Select Id,Name,ERP7__Available__c,ERP7__Product__c,ERP7__Barcode__c from ERP7__Serial_Number__c where (Name like :searchString or ERP7__Barcode__c like :searchString) And ERP7__Product__c=:RMAline[0].ERP7__Product__c and ERP7__Warehouse__c=:siteId  and ERP7__Available__c = true and ERP7__Scrap__c = false Limit 1000];
                    if(serlst.size() == 1){
                        	inverntoryStocklst = [Select Id,Name,ERP7__Serial__c from ERP7__Inventory_Stock__c where ERP7__Product__c=:serlst[0].ERP7__Product__c And ERP7__Warehouse__c=:siteId  and ERP7__Serial__c =:serlst[0].Id and ERP7__Number_of_Item_In_Stock__c > 0 Limit 1000];
                            SerialWrapper SW = new SerialWrapper();
                            SW.SerialNo = new ERP7__Serial_Number__c(Id=serlst[0].Id, Name=serlst[0].Name,ERP7__Barcode__c = serlst[0].ERP7__Barcode__c);
                        	SW.ProductsiteInventory = !inverntoryStocklst.isEmpty() ? inverntoryStocklst[0].Id : '';
                            SW.isSelected = true;
                            ASWL.add(SW);
                    }
                    else{
                        set<Id> SerialIds = new set<Id>();
                        set<Id> ProductIds = new set<Id>();
                        for(ERP7__Serial_Number__c ser : serlst){ 
                            SerialIds.add(ser.Id);
                            ProductIds.add(ser.ERP7__Product__c);
                        }
                        inverntoryStocklst = [Select Id,Name,ERP7__Serial__c from ERP7__Inventory_Stock__c where ERP7__Product__c IN : ProductIds And ERP7__Warehouse__c=:siteId  and ERP7__Serial__c IN : SerialIds and ERP7__Number_of_Item_In_Stock__c > 0 Limit 1000];
                        for(ERP7__Serial_Number__c ser : serlst){
                            SerialWrapper SW = new SerialWrapper();
                            Boolean inventoryFound = false;
                            
                            for (ERP7__Inventory_Stock__c InvStock : inverntoryStocklst) {
                                if (ser.Id == InvStock.ERP7__Serial__c) {
                                    SW.ProductsiteInventory = InvStock.Id;
                                    inventoryFound = true;
                                    break;
                                }
                            }
                            if (!inventoryFound) {
                                SW.ProductsiteInventory = '';
                            }

                            SW.SerialNo = new ERP7__Serial_Number__c(Id=ser.Id, Name=ser.Name,ERP7__Barcode__c = ser.ERP7__Barcode__c);
                            ASWL.add(SW);
                        }
                    }
                     comW.PickSerialNos = ASWL;
                     if(ASWL.size() == 0 && SWL.size() == 0) comW.exceptionError = 'Serial Number not available'; 
                }
            }
        } catch(exception e){
            comW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber();
        }
        return comW;
    }
    
    @AuraEnabled
    public static List<String> getAvailableBatches(String currProdId,String site){
        try{
            //New Code added by parveeez 13/05/2024
            Product2 prod = new Product2();
            
            String iSFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
            utilClass.FLSCheck(iSFields.split(','),'ERP7__Inventory_Stock__c');
            List<ERP7__Inventory_Stock__c> productInventories = new List<ERP7__Inventory_Stock__c>();
            
            List<ERP7__Inventory_Stock__c> AllProductInventories = new List<ERP7__Inventory_Stock__c>();
            List<ERP7__Inventory_Stock__c> SingleProductInventories = new List<ERP7__Inventory_Stock__c>();
            List<String> availBatchIds = new List<String>();
            
            
            if(String.isNotEmpty(currProdId)){
                List<Product2> prolist = [Select Id, Name, ERP7__Lot_Tracked__c, ERP7__Serialise__c from product2 where Id =:currProdId Limit 1];
                if(prolist.size() > 0){
                    prod = prolist[0];
                    String prodId = prod.Id;
                    boolean isBatch = false;
                    if(prod.ERP7__Lot_Tracked__c) isBatch = true;
                    
                    system.debug('prodId~>'+prodId);
                    system.debug('site~>'+site);
                    
                    
                    system.debug('isBatch~>'+isBatch);
                    
                    
                    String invqry = 'select ' + String.escapeSingleQuotes(iSFields) + '  from ERP7__Inventory_Stock__c where ERP7__Number_of_Item_In_Stock__c > 0 AND ERP7__Active__c = true AND ERP7__Warehouse__c != null AND ERP7__Product__c != null AND ERP7__Product__r.IsActive = true And ERP7__Product__r.ERP7__Track_Inventory__c = true AND ERP7__Product__c =: prodId ';
                    if(String.isNotEmpty(site)) invqry += ' AND ERP7__Warehouse__c =: site ';
                    if(isBatch) invqry += ' AND ERP7__Batch_Lot__c != null AND ERP7__Batch_Lot__r.ERP7__Expired__c = false AND ERP7__Batch_Lot__r.ERP7__Available_Quantity__c > 0 AND ERP7__Batch_Lot__r.ERP7__Product__c =: prodId ';
                    invqry += 'Order By ERP7__Number_of_Item_In_Stock__c,CreatedDate DESC ';
                    
                    invqry += ' LIMIT 9000 ';
                    AllProductInventories = Database.query(invqry);
                }
            }
            
            
            system.debug('AllProductInventories.size()~>'+AllProductInventories.size());
            
            if(AllProductInventories.size() > 0){
                for(ERP7__Inventory_Stock__c IS : AllProductInventories) {   if(IS.ERP7__Batch_Lot__c != null){ availBatchIds.add(IS.ERP7__Batch_Lot__c); } }
            }
            
            system.debug('No issue till here?');   
            return availBatchIds; } catch (Exception ex){ system.debug('Exception ~> '+ ex.getMessage()+'; at line ~> '+ex.getStackTraceString());   throw new AuraHandledException(ex.getMessage()+'; at line ~> '+ex.getStackTraceString());  }
    }
}