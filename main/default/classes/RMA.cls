public with sharing class RMA {   
    private final Sales_Order__c so;   
    @AuraEnabled public list<String> FrieghtTypeList   {get;set;}
    @AuraEnabled public list<String> StatusList        {get;set;}  
    @AuraEnabled public boolean isOrderAccess {get;set;}
    @AuraEnabled public boolean isSOAccess {get;set;} 
    @AuraEnabled public String ChannelId    { get; set; } 
    @AuraEnabled public String ObjectLabel    { get; set; } 
    @AuraEnabled public ERP7__Distribution_Channel__c distributionchannel { get; set; }
    public RMA(){
        ChannelId = '';
        ObjectLabel = SObjectType.ERP7__Return_Merchandise_Authorisation__c.getLabel();
        distributionchannel = new ERP7__Distribution_Channel__c();
        isOrderAccess = isSOAccess = false;
        FrieghtTypeList = StatusList = new List<String>();
    }
    
    @AuraEnabled
    public static RMA doInit(){
        RMA rma = new RMA();
        try{
            List<ERP7__Employees__c> emp = [Select Id,ERP7__Channel__c FROM ERP7__Employees__c  Where ERP7__Employee_User__c=:userinfo.getUserId() and ERP7__Active__c=true];
            if(emp != null && emp.size()>0){
                rma.ChannelId = emp[0].Channel__c; 
                List<ERP7__Distribution_Channel__c> dc_list = [SELECT Id,Name,ERP7__Channel__c,ERP7__Site__c ,ERP7__Site__r.Name, ERP7__Site__r.ERP7__Address__c,
                                                               ERP7__Site__r.ERP7__Address__r.Name, ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line1__c, ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line2__c,
                                                               ERP7__Site__r.ERP7__Address__r.ERP7__City__c,ERP7__Site__r.ERP7__Address__r.ERP7__State__c,ERP7__Site__r.ERP7__Address__r.ERP7__Postal_Code__c,ERP7__Site__r.ERP7__Address__r.ERP7__Country__c 
                                                               FROM ERP7__Distribution_Channel__c Where ERP7__Channel__c =: emp[0].Channel__c AND ERP7__Active__c = true AND ERP7__Returns_Handling__c = true
                                                               AND ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                if(dc_list !=null && dc_list.size()>0) rma.distributionchannel =dc_list[0]; 
            }
            
            //if(Schema.sobjectType.ERP7__Return_Merchandise_Authorisation__c.Fields.ERP7__SO__c.isAccessible()) rma.isSOAccess=true; else rma.isSOAccess=false;
            //if(Schema.sobjectType.ERP7__Return_Merchandise_Authorisation__c.Fields.ERP7__Order__c.isAccessible()) rma.isOrderAccess=true; else rma.isOrderAccess=false;
            ERP7__Functionality_Control__c FC = new ERP7__Functionality_Control__c();//The changes added on 2/5/24 by Asra to handle standard order and sales order based on FC
            FC = ERP7__Functionality_Control__c.getValues(userInfo.getuserid());
            if(FC == null){ FC = ERP7__Functionality_Control__c.getValues(userInfo.getProfileId());   if(FC==null) FC = ERP7__Functionality_Control__c.getInstance();  }
            if(FC != null){  
                if(FC.ERP7__Is_Standard_Order__c) { rma.isOrderAccess=true; rma.isSOAccess=false;
                }
                else{
                    rma.isOrderAccess=false; 
                    rma.isSOAccess=true;
                } 
            }
            List<String> options = new List<String>();
            options.add('--None--');
            Schema.DescribeFieldResult fieldResult = ERP7__Return_Merchandise_Authorisation__c.Frieght_Type__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry f: ple) options.add(f.getLabel());
            rma.FrieghtTypeList=options;
            
            List<String> StatusList = new List<String>();
            Schema.DescribeFieldResult FR = ERP7__Return_Merchandise_Authorisation__c.ERP7__Status__c.getDescribe();
            List<Schema.PicklistEntry> ple1 = FR.getPicklistValues();
            for (Schema.PicklistEntry f: ple1) StatusList.add(f.getLabel());
            rma.StatusList=StatusList;
            
            return rma;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
    }
    
    public RMA(ApexPages.StandardController controller) {
        if(ApexPages.currentPage().getParameters().get('soId') != null)
            so = [SELECT Id, Name FROM Sales_Order__c WHERE Id = :ApexPages.currentPage().getParameters().get('soId')];        
    }
    
    public Sales_Order__c getSO() { 
        return so;
    }   
    
    @AuraEnabled
    public static List<String> getFreightType(){
        List<String> options = new List<String>(); 
        options.add('--None--'); 
        Schema.DescribeFieldResult fieldResult = ERP7__Return_Merchandise_Authorisation__c.Frieght_Type__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); 
        return options;
    }
    
    @AuraEnabled
    public static List<String> getRMAStatus(){
        List<String> options = new List<String>(); 
        options.add('--None--'); 
        Schema.DescribeFieldResult fieldResult = Return_Merchandise_Authorisation__c.status__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); 
        return options;
    }
    
    @AuraEnabled
    public static ERP7__Return_Merchandise_Authorisation__c getRMAInstance(){
        return new ERP7__Return_Merchandise_Authorisation__c();
    } 
    
    @AuraEnabled
    public static List<String> getStatus(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static String getSiteDetails(String recordId){
        try{
            List<ERP7__Site__c> siteList = new List<ERP7__Site__c>(); 
            if(String.isNotEmpty(recordId)) siteList = [SELECT Id,ERP7__Address__c FROM ERP7__Site__c Where Id=:recordId]; 
            return (siteList.size()>0)? siteList[0].ERP7__Address__c:'';
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled
    public static ERP7__Distribution_Channel__c getSiteDetailsbyDC(String recordId){
        try{
            List<ERP7__Distribution_Channel__c> dcList = new List<ERP7__Distribution_Channel__c>(); 
            if(String.isNotEmpty(recordId)) dcList = [SELECT Id,Name,ERP7__Channel__c,ERP7__Site__c ,ERP7__Site__r.Name FROM ERP7__Distribution_Channel__c Where Id =:recordId]; 
            return (dcList.size()>0)? dcList[0]:null;
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled 
    public static ERP7__Address__c FetchAddressById(String custId,String recordId){
        try{
            List<ERP7__Address__c> addressList = new List<ERP7__Address__c>();
            String qryFilter = '';
            if(String.isNotEmpty(custId)) qryFilter +=' AND ERP7__Customer__c=:CustId';
            if(String.isNotEmpty(recordId)) qryFilter +=' AND Id =:recordId';
            if(String.isNotEmpty(qryFilter))
                addressList = Database.query('SELECT Id,Name,ERP7__Address_Line1__c , ERP7__Address_Line2__c ,ERP7__City__c ,ERP7__State__c ,ERP7__Postal_Code__c,ERP7__Country__c FROM ERP7__Address__c WHERE Name != null '+String.escapeSingleQuotes(qryFilter)+' LIMIT 1 ');
            if(addressList.size()>0) return addressList[0]; else return null;
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled 
    public static Contact FetchContactById(String custId,String recordId){
        try{
            List<Contact> contactList = new List<Contact>();
            if(String.isNotEmpty(custId)){
                if(String.isNotEmpty(recordId))
                    contactList = [SELECT Id,Name,Email,Phone,Account.Name FROM Contact Where AccountId=:custId AND Id =:recordId];
            }
            if(contactList.size()>0) return contactList[0]; else return null;
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled
    public static List<RMAWrapperLI> getSoliByCustomer(String CustID,Integer OFF_SET,String SoId){
        String defaultAcceptanceType;
        String defaultReturnStatus;
        for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
            if (av.isDefaultValue()) { defaultAcceptanceType = av.getValue();break;}
        for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
            if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
        
        OFF_SET = Integer.valueof(OFF_SET);
        String qryFilter ='';
        if(String.isNotEmpty(CustID))qryFilter += ' AND ERP7__Sales_Order__r.ERP7__Account__c =:CustID';
        if(String.isNotEmpty(SoId))qryFilter += ' AND ERP7__Sales_Order__c =SoId';
        List<RMAWrapperLI> RMAWrapperLIlist = new  List<RMAWrapperLI>();
        Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
        if(String.isNotEmpty(CustID) || String.isNotEmpty(SoId)){
            Map<Id,ERP7__Sales_Order_Line_Item__c> soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>((List<ERP7__Sales_Order_Line_Item__c>)Database.query('SELECT Id,ERP7__Sales_Order__r.ERP7__Amount_Paid__c,ERP7__Sales_Order__r.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,Name,ERP7__Base_Price__c,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial__c,ERP7__Discount_Amount__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Serial_Number__c ,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Organisation__c,ERP7__Sales_Order__r.Name , ERP7__Sales_Order__r.ERP7__Status__c ,ERP7__Sales_Order__r.ERP7__Account__c, ERP7__ReturnedQuantity__c, ERP7__Quantity__c, ERP7__Product__c ,ERP7__Product__r.Name, ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c,ERP7__Total_Tax__c FROM ERP7__Sales_Order_Line_Item__c WHERE ERP7__Sales_Order__r.ERP7__Status__c !=\'Cancelled\' AND ERP7__Sales_Order__r.ERP7__Order_Status__c  =\'Closed\' '+ String.escapeSingleQuotes(qryFilter)));//AND ERP7__Sales_Order__r.ERP7__Order_Status__c  ='Closed'//' limit 500 OFFSET '+OFF_SET
            
            Map<Id,Id> soliMapSerial = new Map<Id,Id>();
            for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__SOLI__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__SOLI__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                soliMapSerial.put(tempRMALI.ERP7__SOLI__c,tempRMALI.ERP7__Serial_Number__c);
            }
            
            if(soliitemsMap.keySet().size()>0){
                for(Warranty__c warranty: [Select Id,Sales_Order_Line_Item__c From Warranty__c Where Sales_Order_Line_Item__c In: soliitemsMap.keySet()
                                           And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                               soli_WarrantyMap.put(warranty.Sales_Order_Line_Item__c,true);                                                          
                                           }
                
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> batchSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                IF(soliitemsMap.keySet().SIZE()>0){
                    for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Serialise__c, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Sales_Order_Line_Item__c,ERP7__Sales_Order_Line_Item__r.Name, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Sales_Order_Line_Item__c in: soliitemsMap.keySet() and (ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Serialise__c = true or ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Lot_Tracked__c = true) and ERP7__Status__c = 'Committed']){
                        if(soli.ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Serialise__c){
                            List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c) != null)?rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                            templist.add(soli);
                            rentalSOLI_Map.put(soli.ERP7__Sales_Order_Line_Item__c,templist);
                        }
                        if(soli.ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Lot_Tracked__c){
                            List<ERP7__Stock_Outward_Line_Item__c> templist = (batchSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c) != null)?batchSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                            templist.add(soli);
                            batchSOLI_Map.put(soli.ERP7__Sales_Order_Line_Item__c,templist);
                        }
                    }
                }
                
                
                for(ERP7__Sales_Order_Line_Item__c so_Li:soliitemsMap.values()){
                    if(so_li.ERP7__ReturnedQuantity__c == null)so_li.ERP7__ReturnedQuantity__c =0.00;
                    if(so_Li.ERP7__Product__r.ERP7__Serialise__c  &&  rentalSOLI_Map.get(so_Li.Id) != null){
                        for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(so_Li.Id)){
                            if(!(soliMapSerial.get(so_Li.Id) != null)){
                                ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Sale_Price__c  = (so_li.ERP7__Base_Price__c/soli.ERP7__Quantity__c) ,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.ERP7__Product__c,ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode) , ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Return_Reason__c='');
                                if(so_li.ERP7__Total_Tax__c !=null) RMALI.ERP7__Tax__c=so_li.ERP7__Total_Tax__c/so_li.ERP7__Quantity__c;
                                RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c); 
                                RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_Number__c=soli.ERP7__Serial__r.ERP7__Serial_Number__c);
                                RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                RMAWrapperLIlist.add(temp_RMAWrapperLI);
                            }
                        }
                        
                    }else if(!so_Li.ERP7__Product__r.ERP7__Serialise__c){
                        decimal qty = double.valueof(so_li.ERP7__Quantity__c - so_li.ERP7__ReturnedQuantity__c);
                        if(qty>0.00){
                            ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.ERP7__Product__c , ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode) ,ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Sale_Price__c  = (so_li.ERP7__Base_Price__c/so_li.ERP7__Quantity__c),ERP7__Return_Reason__c='');
                            if(so_li.ERP7__Total_Tax__c !=null) RMALI.ERP7__Tax__c=so_li.ERP7__Total_Tax__c/so_li.ERP7__Quantity__c;
                            RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c); 
                            if(so_Li.ERP7__Product__r.ERP7__Lot_Tracked__c &&  batchSOLI_Map.get(so_Li.Id) != null){
                                for(ERP7__Stock_Outward_Line_Item__c soli : batchSOLI_Map.get(so_Li.Id)){
                                    RMALI.ERP7__Batch_Lot__c = soli.ERP7__Material_Batch_Lot__c;
                                    RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = soli.ERP7__Material_Batch_Lot__r.Name);
                                }
                            }
                            RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                            RMAWrapperLIlist.add(temp_RMAWrapperLI);
                        }
                    }
                } 
            }  
        }
        return RMAWrapperLIlist;
    }
    
    @AuraEnabled
    public static List<RMAWrapperLI> getSoliBykeyWord(String CustID,String keyword,String SoId){
        String defaultAcceptanceType;
        String defaultReturnStatus;
        for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
            if (av.isDefaultValue()) { defaultAcceptanceType = av.getValue();break;}
        for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
            if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
        
        String qryFilter ='';
        if(String.isNotEmpty(CustID))qryFilter += ' AND ERP7__Sales_Order__r.ERP7__Account__c =\''+String.escapeSingleQuotes(CustID)+'\'';
        if(String.isNotEmpty(SoId))qryFilter += ' AND ERP7__Sales_Order__c =\''+String.escapeSingleQuotes(SoId)+'\'';
        List<RMAWrapperLI> RMAWrapperLIlist = new  List<RMAWrapperLI>();
        Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
        Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
        Map<Id,ERP7__Sales_Order_Line_Item__c> soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>();
        List<ERP7__Stock_Outward_Line_Item__c> stock_outwardLI = new List<ERP7__Stock_Outward_Line_Item__c>();
        set<Id> soli_Ids = new Set<Id>();
        if(String.isNotEmpty(qryFilter) && String.isNotEmpty(keyword)){
            String outWardquery = 'SELECT Id,Name,ERP7__Sales_Order__c,ERP7__Sales_Order_Line_Item__c FROM ERP7__Stock_Outward_Line_Item__c Where ERP7__Status__c =\'Committed\' AND ERP7__Sales_Order__r.ERP7__Order_Status__c  =\'Closed\' '+qryFilter+' AND (ERP7__Material_Batch_Lot__r.Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' or ERP7__Serial__r.ERP7__Serial_Number__c LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' or ERP7__Product__r.Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\'  or ERP7__Product__r.ProductCode LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\' or ERP7__Sales_Order__r.Name LIKE \'%'+String.escapeSingleQuotes(keyword)+'%\')';
            for(ERP7__Stock_Outward_Line_Item__c stock_outward:Database.query(outWardquery)){
                soli_Ids.add(stock_outward.ERP7__Sales_Order_Line_Item__c);
            }
        }
        
        if(soli_Ids.size()>0){
            
            String query = 'SELECT Id,ERP7__Sales_Order__r.ERP7__Amount_Paid__c,ERP7__Sales_Order__r.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,ERP7__Base_Price__c,Name,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial_Number__c,ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Organisation__c,ERP7__Sales_Order__r.Name,ERP7__Reserved_Quantity__c , ERP7__Sales_Order__r.ERP7__Order_Date__c ,ERP7__Sales_Order__r.ERP7__Status__c ,ERP7__Sales_Order__r.ERP7__Account__c, ERP7__ReturnedQuantity__c, ERP7__Quantity__c, ERP7__Product__c ,ERP7__Product__r.Name, ERP7__Product__r.ProductCode,ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Total_Price__c FROM ERP7__Sales_Order_Line_Item__c WHERE Id IN: soli_Ids'; //(ERP7__Product__r.Barcode__c LIKE '+'\'%'+keyword+'%\'' +' or ERP7__Product__r.Name LIKE '+'\'%'+keyword+'%\'' +' or ERP7__Product__r.ProductCode LIKE '+'\'%'+keyword+'%\'' +' or ERP7__Sales_Order__r.Name LIKE '+'\'%'+keyword+'%\'' +') AND ERP7__Sales_Order__r.ERP7__Order_Status__c  =\'Closed\' AND ERP7__Sales_Order__r.ERP7__Status__c !=\'Cancelled\' '+qryFilter;
            List<ERP7__Sales_Order_Line_Item__c> solilist = database.query(query);
            soliitemsMap = new Map<Id,ERP7__Sales_Order_Line_Item__c>(solilist);
            
            set<Id> soliMapSerial = new Set<Id>();
            for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__SOLI__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__SOLI__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                soliMapSerial.add(tempRMALI.ERP7__Serial_Number__c);
            }
            
            if(soliitemsMap.keySet().size()>0){
                for(Warranty__c warranty: [Select Id,Sales_Order_Line_Item__c From Warranty__c Where Sales_Order_Line_Item__c In: soliitemsMap.keySet()
                                           And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                               soli_WarrantyMap.put(warranty.Sales_Order_Line_Item__c,true);                                                          
                                           }
                IF(soliitemsMap.keySet().SIZE()>0)
                    for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Sales_Order_Line_Item__c,ERP7__Sales_Order_Line_Item__r.Name ,ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Sales_Order_Line_Item__c in: soliitemsMap.keySet() and ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Serialise__c  = true and ERP7__Status__c = 'Committed']){
                        List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c) != null)?rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                        templist.add(soli);
                        rentalSOLI_Map.put(soli.ERP7__Sales_Order_Line_Item__c,templist);
                        
                    }
                
                for(ERP7__Sales_Order_Line_Item__c so_Li:soliitemsMap.values()){
                    if(so_li.ERP7__ReturnedQuantity__c == null)so_li.ERP7__ReturnedQuantity__c =0.00;
                    if(so_Li.ERP7__Product__r.ERP7__Serialise__c  &&  rentalSOLI_Map.get(so_Li.Id) != null){
                        for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(so_Li.Id)){
                            if(!soliMapSerial.contains(soli.ERP7__Serial__c)){
                                ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Total_Deduction__c  = so_li.ERP7__Total_Price__c ,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.ERP7__Product__c,ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode) , ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Return_Reason__c='');
                                RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_Number__c=soli.ERP7__Serial__r.ERP7__Serial_Number__c);
                                if(so_li.ERP7__Batch_Lot__c != null){
                                    RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                    RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                                }
                                
                                RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                RMAWrapperLIlist.add(temp_RMAWrapperLI);
                            }
                        }
                        
                    }else if(!so_Li.ERP7__Product__r.ERP7__Serialise__c){
                        decimal qty = double.valueof(so_li.ERP7__Quantity__c - so_li.ERP7__ReturnedQuantity__c);
                        if(qty>0.00 ){
                            ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.ERP7__Product__c , ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode) ,ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Sale_Price__c  = (so_li.ERP7__Base_Price__c*qty),ERP7__Return_Reason__c='');
                            if(so_li.ERP7__Serial__c != null){
                                RMALI.ERP7__Serial_Number__c=so_li.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=so_li.ERP7__Serial__c,Name=so_li.ERP7__Serial__r.Name,ERP7__Serial_Number__c=so_li.ERP7__Serial__r.ERP7__Serial_Number__c);
                            }
                            if(so_li.ERP7__Batch_Lot__c != null){
                                RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                            }
                            RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                            RMAWrapperLIlist.add(temp_RMAWrapperLI);
                        }
                    }
                }
            } 
        }
        return RMAWrapperLIlist;
    }
    
    @AuraEnabled
    public static List<RMAWrapperLI> getOrdItemByCustomer(String CustID,Integer OFF_SET,String SoId){
        String defaultAcceptanceType;
        String defaultReturnStatus;
        for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
            if (av.isDefaultValue()) { defaultAcceptanceType = av.getValue();break;}
        for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
            if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
        
        OFF_SET = Integer.valueof(OFF_SET);
        String qryFilter ='';
        if(String.isNotEmpty(CustID))qryFilter += ' AND Order.AccountId =:CustID';
        if(String.isNotEmpty(SoId))qryFilter += ' AND OrderId =:SoId';
        List<RMAWrapperLI> RMAWrapperLIlist = new  List<RMAWrapperLI>();
        Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
        if(String.isNotEmpty(CustID) || String.isNotEmpty(SoId)){
            Map<Id,OrderItem> soliitemsMap = new  Map<Id,OrderItem>((List<OrderItem>)Database.query('SELECT Id,ERP7__Total_Tax__c,ERP7__All_Total_Price__c,Order.ERP7__Amount_Paid__c,Order.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,ERP7__Base_Price__c,UnitPrice,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial__c,ERP7__Discount_Amount__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Serial_Number__c ,OrderId,Order.ERP7__Organisation__c,Order.Name , Order.Status ,Order.AccountId, ERP7__ReturnedQuantity__c, Quantity, Product2Id ,Product2.Name, Product2.ProductCode,Product2.ERP7__Serialise__c, Product2.ERP7__Lot_Tracked__c FROM OrderItem WHERE Order.Status !=\'Cancelled\' AND Order.ERP7__Is_Closed__c  =true '+ String.escapeSingleQuotes(qryFilter)+' Order By CreatedDate desc Limit 200'));//AND ERP7__Sales_Order__r.ERP7__Order_Status__c  ='Closed'//' limit 500 OFFSET '+OFF_SET
            
            Map<Id,Id> soliMapSerial = new Map<Id,Id>();
            for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__Ord_Item__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__Ord_Item__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                soliMapSerial.put(tempRMALI.ERP7__Ord_Item__c,tempRMALI.ERP7__Serial_Number__c);
            }
            
            if(soliitemsMap.keySet().size()>0){
                for(Warranty__c warranty: [Select Id,ERP7__Order_Product__c From Warranty__c Where ERP7__Order_Product__c In: soliitemsMap.keySet()
                                           And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                               soli_WarrantyMap.put(warranty.ERP7__Order_Product__c,true);                                                          
                                           }
                
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> batchSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                IF(soliitemsMap.keySet().SIZE()>0){
                    for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Order_Product__r.Product2.ERP7__Lot_Tracked__c, ERP7__Order_Product__r.Product2.ERP7__Serialise__c, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Order_Product__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Order_Product__c in: soliitemsMap.keySet() and (ERP7__Order_Product__r.Product2.ERP7__Serialise__c = true or ERP7__Order_Product__r.Product2.ERP7__Lot_Tracked__c = true) and ERP7__Status__c = 'Committed']){
                        if(soli.ERP7__Order_Product__r.Product2.ERP7__Serialise__c){
                            List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Order_Product__c) != null)?rentalSOLI_Map.get(soli.ERP7__Order_Product__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                            templist.add(soli);
                            rentalSOLI_Map.put(soli.ERP7__Order_Product__c,templist);
                        }
                        if(soli.ERP7__Order_Product__r.Product2.ERP7__Lot_Tracked__c){
                            List<ERP7__Stock_Outward_Line_Item__c> templist = (batchSOLI_Map.get(soli.ERP7__Order_Product__c) != null)?batchSOLI_Map.get(soli.ERP7__Order_Product__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                            templist.add(soli);
                            batchSOLI_Map.put(soli.ERP7__Order_Product__c,templist);
                        }
                    }
                }
                
                
                for(OrderItem so_Li:soliitemsMap.values()){
                    if(so_li.ERP7__ReturnedQuantity__c == null)so_li.ERP7__ReturnedQuantity__c =0.00;
                    if(so_Li.Product2.ERP7__Serialise__c  &&  rentalSOLI_Map.get(so_Li.Id) != null){
                        for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(so_Li.Id)){
                            if(!(soliMapSerial.get(so_Li.Id) != null)){
                                ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Sale_Price__c  = so_li.UnitPrice ,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.Product2Id,ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode) , ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Return_Reason__c='');
                                //RMALI.ERP7__Total_Deduction__c= so_li.ERP7__All_Total_Price__c;
                                if(so_li.ERP7__Total_Tax__c !=null) RMALI.ERP7__Tax__c=so_li.ERP7__Total_Tax__c/so_li.Quantity;
                                RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);                                
                                RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_Number__c=soli.ERP7__Serial__r.ERP7__Serial_Number__c);
                                RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                RMAWrapperLIlist.add(temp_RMAWrapperLI);
                            }
                        }
                        
                    }else if(!so_Li.Product2.ERP7__Serialise__c){
                        decimal qty = double.valueof(so_li.Quantity - so_li.ERP7__ReturnedQuantity__c);
                        if(qty>0.00){
                            ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.Product2Id , ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode) ,ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Sale_Price__c  = so_li.UnitPrice,ERP7__Return_Reason__c='');
                            if(so_li.ERP7__Total_Tax__c !=null) RMALI.ERP7__Tax__c=so_li.ERP7__Total_Tax__c/so_li.Quantity;
                            //RMALI.ERP7__Total_Deduction__c= so_li.ERP7__All_Total_Price__c;
                            RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);
                            if(so_Li.Product2.ERP7__Lot_Tracked__c &&  batchSOLI_Map.get(so_Li.Id) != null){
                                for(ERP7__Stock_Outward_Line_Item__c soli : batchSOLI_Map.get(so_Li.Id)){
                                    RMALI.ERP7__Batch_Lot__c = soli.ERP7__Material_Batch_Lot__c;
                                    RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = soli.ERP7__Material_Batch_Lot__r.Name);
                                }
                            }
                            RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                            RMAWrapperLIlist.add(temp_RMAWrapperLI);
                        }
                    }
                } 
            }  
        }
        return RMAWrapperLIlist;
    }
    
    @AuraEnabled
    public static customerInfo FetchcustomerInfo(String custId,String invId,String ordId,Boolean isSalesOrder,Boolean isOrder){
        customerInfo custinfo = new customerInfo(); 
        contact con = new contact();
        ERP7__Address__c addr = new ERP7__Address__c();
        try{
            if(String.isNotEmpty(custId)){
                con = [SELECT Id,Name,Email,Phone,Account.Name FROM Contact Where AccountId=:custId AND ERP7__Primary__c =true limit 1];
                addr = [SELECT Id,Name,ERP7__Address_Line1__c , ERP7__Address_Line2__c ,ERP7__City__c ,ERP7__State__c ,ERP7__Postal_Code__c,ERP7__Country__c FROM ERP7__Address__c WHERE ERP7__Customer__c=:custId AND ERP7__Primary__c = true AND ERP7__Is_Shipping_Address__c =true limit 1];
            } 
            if(con.Id != null) custinfo.contact = con;
            if(addr.Id != null) custinfo.Address = addr;
        }catch(QueryException qe){
            system.debug('qexcp~>'+qe.getMessage()+' at '+qe.getStackTraceString());
            if(con.Id != null) custinfo.contact = con;
            if(addr.Id != null) custinfo.Address = addr;
        }
        try{
            
            Map<Id,List<Id>> AssetsProdIds = new Map<Id,List<Id>>();
            Map<Id,String> astProdSN = new Map<Id,String>();
            
            if((String.isEmpty(ordId) || String.isBlank(ordId))){
                for(Asset ast:[Select Id,AccountId, Product2Id,ProductCode,StockKeepingUnit,PurchaseDate,SerialNumber,Status FROM Asset WHERE AccountId =: custId AND Product2Id != null AND Status = 'Installed' ]){
                    if(String.isNotEmpty(ast.SerialNumber)) astProdSN.put(ast.Product2Id, ast.SerialNumber);
                    if (AssetsProdIds.containsKey(ast.AccountId)){
                        AssetsProdIds.get(ast.AccountId).add(ast.Product2Id);
                    }else{
                        AssetsProdIds.put(ast.AccountId, new List <Id> { ast.Product2Id });
                    }
                }
            }
            
            List<String> prodIds = new List<String>();
            if(AssetsProdIds.containsKey(custId)){
                prodIds = AssetsProdIds.get(custId);
            }
            
            //if((String.isEmpty(invId) || String.isBlank(invId)) && String.isNotEmpty(custId)){
            if(String.isNotEmpty(invId) || String.isNotEmpty(ordId)){
                String defaultAcceptanceType;
                String defaultReturnStatus;
                for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
                    if (av.isDefaultValue()) { defaultAcceptanceType = av.getValue();break;}
                for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
                    if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
                
                List<RMAWrapperLI> RMAWrapperLIlist = new  List<RMAWrapperLI>();
                Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
                
                
                if(isOrder){
                    String qry = 'SELECT Id,ERP7__Total_Tax__c,ERP7__All_Total_Price__c,Order.ERP7__Amount_Paid__c,Order.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,ERP7__Base_Price__c,UnitPrice,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial__c,ERP7__Discount_Amount__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_No__c,ERP7__Serial_Number__c ,OrderId,Order.ERP7__Organisation__c,Order.Name , Order.Status ,Order.AccountId, ERP7__ReturnedQuantity__c, Quantity, Product2Id ,Product2.Name, Product2.ProductCode,Product2.ERP7__Serialise__c, Product2.ERP7__Lot_Tracked__c FROM OrderItem WHERE Order.Status !=\'Cancelled\' AND Order.ERP7__Is_Closed__c  = true AND Order.AccountId =: custId ';
                    if(String.isNotEmpty(ordId)) qry += ' AND OrderId =: ordId '; 
                    else if(prodIds.size() > 0) qry += ' AND Product2Id IN : prodIds ';
                    qry += '  Order By CreatedDate desc Limit 200 ';
                    
                    Map<Id,OrderItem> soliitemsMap = new  Map<Id,OrderItem>((List<OrderItem>)Database.query(qry));
                    if(soliitemsMap.keySet().size()>0){
                        system.debug('inside soliitemsMap.keySet().size()>0');
                        Map<Id,Id> soliMapSerial = new Map<Id,Id>();
                        for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__Ord_Item__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__Ord_Item__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                            soliMapSerial.put(tempRMALI.ERP7__Ord_Item__c,tempRMALI.ERP7__Serial_Number__c);
                        }
                        system.debug('soliMapSerial~>'+soliMapSerial);
                        
                        for(Warranty__c warranty: [Select Id,ERP7__Order_Product__c From Warranty__c Where ERP7__Order_Product__c In: soliitemsMap.keySet()
                                                   And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                                       soli_WarrantyMap.put(warranty.ERP7__Order_Product__c,true);                                                          
                                                   }
                        
                        Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                        Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> batchSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                        
                        for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Order_Product__r.Product2.ERP7__Lot_Tracked__c, ERP7__Order_Product__r.Product2.ERP7__Serialise__c, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Order_Product__c, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_No__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Order_Product__c in: soliitemsMap.keySet() and (ERP7__Order_Product__r.Product2.ERP7__Serialise__c = true or ERP7__Order_Product__r.Product2.ERP7__Lot_Tracked__c = true) and ERP7__Status__c = 'Committed']){
                            if(soli.ERP7__Order_Product__r.Product2.ERP7__Serialise__c){
                                List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Order_Product__c) != null)?rentalSOLI_Map.get(soli.ERP7__Order_Product__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                                templist.add(soli);
                                rentalSOLI_Map.put(soli.ERP7__Order_Product__c,templist);
                            }
                            if(soli.ERP7__Order_Product__r.Product2.ERP7__Lot_Tracked__c){
                                List<ERP7__Stock_Outward_Line_Item__c> templist = (batchSOLI_Map.get(soli.ERP7__Order_Product__c) != null)?batchSOLI_Map.get(soli.ERP7__Order_Product__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                                templist.add(soli);
                                batchSOLI_Map.put(soli.ERP7__Order_Product__c,templist);
                            }
                        }
                        
                        system.debug('rentalSOLI_Map~>'+rentalSOLI_Map);
                        
                        Boolean processit = false;
                        for(OrderItem so_Li:soliitemsMap.values()){
                            if(so_li.ERP7__ReturnedQuantity__c == null)so_li.ERP7__ReturnedQuantity__c =0.00;
                            if(so_Li.Product2.ERP7__Serialise__c  &&  rentalSOLI_Map.get(so_Li.Id) != null){
                                for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(so_Li.Id)){
                                    processit = false;
                                    if(soliMapSerial.containsKey(so_Li.Id)){
                                        if(soli.ERP7__Serial__c != null){
                                            if(soliMapSerial.get(so_Li.Id) != soli.ERP7__Serial__c) processit = true;
                                        }else processit = true;
                                    }else processit = true;
                                    
                                    system.debug('processit~>'+processit);
                                    
                                    if(processit){
                                        ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Sale_Price__c  = so_li.UnitPrice ,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.Product2Id,ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode) , ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Return_Reason__c='');
                                        //RMALI.ERP7__Total_Deduction__c= so_li.ERP7__All_Total_Price__c;
                                        if(so_li.ERP7__Total_Tax__c !=null) RMALI.ERP7__Tax__c=so_li.ERP7__Total_Tax__c/so_li.Quantity;
                                        RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);   
                                        if(soli.ERP7__Serial__c != null){
                                            RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                            RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_No__c=soli.ERP7__Serial__r.ERP7__Serial_No__c);
                                        }
                                        RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                        RMAWrapperLIlist.add(temp_RMAWrapperLI);
                                    }
                                }
                                
                            }else if(!so_Li.Product2.ERP7__Serialise__c){
                                decimal qty = double.valueof(so_li.Quantity - so_li.ERP7__ReturnedQuantity__c);
                                if(qty>0.00){
                                    ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.Product2Id , ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode) ,ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Sale_Price__c  = so_li.UnitPrice,ERP7__Return_Reason__c='');
                                    if(so_li.ERP7__Total_Tax__c !=null) RMALI.ERP7__Tax__c=so_li.ERP7__Total_Tax__c/so_li.Quantity;
                                    //RMALI.ERP7__Total_Deduction__c= so_li.ERP7__All_Total_Price__c;
                                    RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);
                                    if(so_Li.Product2.ERP7__Lot_Tracked__c &&  batchSOLI_Map.get(so_Li.Id) != null){
                                        for(ERP7__Stock_Outward_Line_Item__c soli : batchSOLI_Map.get(so_Li.Id)){
                                            RMALI.ERP7__Batch_Lot__c = soli.ERP7__Material_Batch_Lot__c;
                                            RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = soli.ERP7__Material_Batch_Lot__r.Name);
                                        }
                                    }
                                    RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                    RMAWrapperLIlist.add(temp_RMAWrapperLI);
                                }
                            }
                        } 
                    }else{
                        system.debug('soliitemsMap keyset not > 0');
                    }
                    
                    custinfo.RAMLI_List = RMAWrapperLIlist;                    
                }
                
            }
        }catch (Exception e){
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        }
        return custinfo;
    }
    
    @AuraEnabled 
    public static sObj_Wrapper createRMA(String RMAobj,String RMALIs,Boolean isSalesOrder,Boolean isOrder){   
        try{
            ERP7__Return_Merchandise_Authorisation__c  RMA = (ERP7__Return_Merchandise_Authorisation__c)JSON.deserialize(RMAobj,ERP7__Return_Merchandise_Authorisation__c.class);
            Boolean UpdateRMA =false;
            if(RMA.ERP7__Authorize__c && RMA.Id == null) UpdateRMA=true; 
            System.debug('UpdateRMA '+UpdateRMA);
            if(Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Active__c.isUpdateable()) RMA.ERP7__Active__c =true; 
            if(Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Status__c.isUpdateable()) RMA.ERP7__Status__c='Initiated';
            list<RMAWrapperLI> RMA2Create = (List<RMAWrapperLI>)JSON.deserialize(RMALIs, List<RMAWrapperLI>.class);        
            List<ERP7__RMA_Line_Item__c> RMA_LI_2_Insert = new List<ERP7__RMA_Line_Item__c>();
            if(Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__SO__c.isCreateable() && Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__SO__c.isUpdateable()) if(String.isEmpty(RMA.ERP7__SO__c)) RMA.ERP7__SO__c = null;
            if(Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Order__c.isCreateable() && Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Order__c.isUpdateable()) if(String.isEmpty(RMA.ERP7__Order__c)) RMA.ERP7__Order__c = null;
            if(Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.isCreateable() && Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.isUpdateable()){ upsert RMA;  } else{/*no access to upsert */}
            
            for(RMAWrapperLI temp :RMA2Create){   
                if(temp.isfinalSelect){
                    if(Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.ERP7__Return_Merchandise_Authorisation__c.isCreateable() || Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.ERP7__Return_Merchandise_Authorisation__c.isUpdateable()) if(!(temp.RMALI.ERP7__Return_Merchandise_Authorisation__c != null)) temp.RMALI.ERP7__Return_Merchandise_Authorisation__c = RMA.Id;
                    if(Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.ERP7__Amount_Paid__c.isCreateable() && Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.ERP7__Amount_Paid__c.isUpdateable()) if(temp.soli.ERP7__Sales_Order__c != null) temp.RMALI.ERP7__Amount_Paid__c = (temp.soli.ERP7__Sales_Order__r.ERP7__Amount_Paid__c >= temp.RMALI.ERP7__Total_Deduction__c)?temp.RMALI.ERP7__Total_Deduction__c:temp.soli.ERP7__Sales_Order__r.ERP7__Amount_Paid__c;
                    if(Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.ERP7__Amount_Paid__c.isCreateable() && Schema.sObjectType.ERP7__RMA_Line_Item__c.fields.ERP7__Amount_Paid__c.isUpdateable()) if(temp.OrdItem.OrderId != null) temp.RMALI.ERP7__Amount_Paid__c = (temp.OrdItem.Order.ERP7__Amount_Paid__c >= temp.RMALI.ERP7__Total_Deduction__c)?temp.RMALI.ERP7__Total_Deduction__c:temp.OrdItem.Order.ERP7__Amount_Paid__c;
                    //if(temp.RMALI.ERP7__Tax__c != null) temp.RMALI.ERP7__Tax__c = temp.RMALI.ERP7__Quantity_Return__c * temp.RMALI.ERP7__Tax__c;
                    RMA_LI_2_Insert.add(temp.RMALI);
                    temp.RMALI.ERP7__Serial_Number__r = null;
                    temp.RMALI.ERP7__Product__r = null;
                    temp.RMALI.ERP7__Batch_Lot__r = null;
                }
            }
            
            if(RMA_LI_2_Insert.size()>0){
                if(Schema.sObjectType.ERP7__RMA_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__RMA_Line_Item__c.isUpdateable()) { upsert RMA_LI_2_Insert; } else{ /* not allowed*/ }
            }
             
            if(UpdateRMA== true) {
                PreventRecursiveLedgerEntry.testCasesTransactions  =false; 
                update RMA;
            }
            //PreventRecursiveLedgerEntry.testCasesTransactions  =false;       
            if(RMA.Id != null)  return  fetch_RMALI(RMA.Id,isSalesOrder,isOrder); else return fetch_RMALI('',isSalesOrder,isOrder);
        }catch(Exception e){
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
    }
    
    @AuraEnabled   
    public static sObj_Wrapper fetch_RMALI(String RMA_Id,Boolean isSalesOrder,Boolean isOrder){
        sObj_Wrapper obj = new sObj_Wrapper();
        try{
            if(String.isNotEmpty(RMA_Id)){
                List<RMAWrapperLI> RMALI_List = new List<RMAWrapperLI>();
                Set<Id> soli_ids = new set<Id>();
                ERP7__Return_Merchandise_Authorisation__c RMA = [Select Id,ERP7__Authorize__c,ERP7__Is_Closed__c,ERP7__Channel__c,ERP7__Expected_Date__c,ERP7__Site__c,ERP7__Refund_Amount__c,ERP7__Shipping_Amount__c,ERP7__Shipping_Tax__c, ERP7__ReStock_Tax__c, ERP7__Frieght_Type__c,ERP7__Distribution_Channel__c,ERP7__Total_Quantity__c,
                                                                 ERP7__Status__c,ERP7__SO__c,ERP7__SO__r.Name,ERP7__Order__c,ERP7__Order__r.Name,Name,ERP7__Address__c,ERP7__Address__r.Name,ERP7__Account__c,ERP7__Account__r.Name,ERP7__Shipped_Quantity__c,ERP7__Received_Quantity__c,ERP7__Packed_Quantity__c,
                                                                 ERP7__Return_Contact__c,ERP7__Return_Contact__r.Name,ERP7__Invoice__c,ERP7__Invoice__r.Name, ERP7__Restock_percentage__c,ERP7__Restock_Fee__c,ERP7__Special_Instructions__c FROM ERP7__Return_Merchandise_Authorisation__c Where Id=:RMA_Id];
                Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
                
                if(isSalesOrder){ //if(RMA.ERP7__SO__c != null){
                    for(Warranty__c warranty: [Select Id,Sales_Order_Line_Item__c From Warranty__c Where Sales_Order_Line_Item__r.ERP7__Sales_Order__c =:RMA.ERP7__SO__c AND Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Is_Asset__c = false
                                               And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                                   soli_WarrantyMap.put(warranty.Sales_Order_Line_Item__c,true);                                                          
                                               }
                } else if(isOrder){ //if(RMA.ERP7__Order__c != null){
                    for(Warranty__c warranty: [Select Id,ERP7__Order_Product__c From Warranty__c Where ERP7__Order_Product__r.OrderId =:RMA.ERP7__Order__c AND ERP7__Order_Product__r.Product2.ERP7__Is_Asset__c = false
                                               And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                                   soli_WarrantyMap.put(warranty.ERP7__Order_Product__c,true);                                                          
                                               }
                }
                
                List<ERP7__RMA_Line_Item__c> RMA_LI_2_upsert = new List<ERP7__RMA_Line_Item__c>();
                Map<Id,ERP7__Sales_Order_Line_Item__c> soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>();
                Map<Id,OrderItem> orditemsMap = new  Map<Id,OrderItem>();
                RMA_LI_2_upsert = [SELECT Id,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Return_Merchandise_Authorisation__r.Name,ERP7__Return_Merchandise_Authorisation__r.ERP7__Address__c ,ERP7__Return_Merchandise_Authorisation__r.ERP7__Account__c,ERP7__Return_Merchandise_Authorisation__c,
                                   ERP7__Return_Merchandise_Authorisation__r.ERP7__Site__c ,ERP7__Return_Merchandise_Authorisation__r.ERP7__Return_Contact__c,ERP7__Serial_Number__c,ERP7__Serial_Number__r.Name ,ERP7__Acceptance_Type__c ,ERP7__Return_Status__c,ERP7__Product__c ,ERP7__Product__r.Name,
                                   ERP7__Product__r.ProductCode, ERP7__SOLI__c,ERP7__Ord_Item__c,ERP7__Organisation__c ,Name,ERP7__Quantity_Return__c,ERP7__Total_Deduction__c,ERP7__Return_Reason__c ,ERP7__Sale_Price__c,ERP7__Base_Price__c,ERP7__Is_Warranty_Exists__c,ERP7__Shipped_Quantity__c,
                                   ERP7__Packed_Quantity__c,ERP7__Received_Quantity__c,ERP7__Return_Quantity__c,ERP7__Serial_Number__r.ERP7__Serial_No__c,ERP7__Tax__c FROM ERP7__RMA_Line_Item__c Where ERP7__Return_Merchandise_Authorisation__c =:RMA_Id];
                if(isSalesOrder){  //if(RMA.ERP7__SO__c != null){
                    for(ERP7__RMA_Line_Item__c temp:RMA_LI_2_upsert){
                        soli_ids.add(temp.ERP7__SOLI__c);
                    }
                    soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>([SELECT Id,ERP7__Sales_Order__r.ERP7__Amount_Paid__c,ERP7__Sales_Order__r.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,Name,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial_Number__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Organisation__c, ERP7__Sales_Order__r.Name,ERP7__Reserved_Quantity__c ,ERP7__Sales_Order__r.ERP7__Order_Date__c ,ERP7__Sales_Order__r.ERP7__Status__c ,ERP7__Sales_Order__r.ERP7__Account__c, ERP7__ReturnedQuantity__c, ERP7__Quantity__c, ERP7__Product__c , ERP7__Product__r.Name,ERP7__Product__r.ProductCode FROM ERP7__Sales_Order_Line_Item__c WHERE  Id IN: soli_ids]);
                    for(ERP7__RMA_Line_Item__c temp:RMA_LI_2_upsert){
                        if(soliitemsMap.containsKey(temp.ERP7__SOLI__c)){
                            RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(soliitemsMap.get(temp.ERP7__SOLI__c),temp,soli_WarrantyMap.containsKey(temp.ERP7__SOLI__c));
                            RMALI_List.add(temp_RMAWrapperLI);
                        }
                    }
                }else if(isOrder){ //if(RMA.ERP7__Order__c != null){
                    for(ERP7__RMA_Line_Item__c temp:RMA_LI_2_upsert){
                        soli_ids.add(temp.ERP7__Ord_Item__c);
                    }
                    orditemsMap = new  Map<Id,OrderItem>([SELECT Id,Order.ERP7__Amount_Paid__c,Order.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial_Number__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,OrderId,Order.Organisation__c, Order.Name,ERP7__Reserved_Quantity__c ,Order.EffectiveDate ,Order.Status ,Order.AccountId, ERP7__ReturnedQuantity__c, Quantity, Product2Id , Product2.Name,Product2.ProductCode FROM OrderItem WHERE  Id IN: soli_ids]);
                    for(ERP7__RMA_Line_Item__c temp:RMA_LI_2_upsert){
                        if(orditemsMap.containsKey(temp.ERP7__Ord_Item__c)){
                            RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(orditemsMap.get(temp.ERP7__Ord_Item__c),temp,soli_WarrantyMap.containsKey(temp.ERP7__Ord_Item__c));
                            RMALI_List.add(temp_RMAWrapperLI);
                        }
                    }
                }
                
                obj.sObj = (ERP7__Return_Merchandise_Authorisation__c)RMA;
                obj.RAMLI_List = RMALI_List;
            }
        }catch(Exception e){
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+' :- '+e.getStackTraceString());
        } 
        /*'RAMLI_List=>'+obj.RAMLI_List.size()+'  ,RAMLI_List=>'+obj.RAMLI_List*/
        return obj;
    }
    
    @AuraEnabled
    public static sObj_Wrapper Build_RMALI(String So_Id){
        sObj_Wrapper obj = new sObj_Wrapper();
        try{
            String defaultAcceptanceType;
            String defaultReturnStatus;
            for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
                if (av.isDefaultValue()) { defaultAcceptanceType = av.getValue();break;}
            for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
                if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
            
            
            if(!String.isBlank(So_Id)){
                ERP7__Sales_order__c so = [SELECT Id,Name,ERP7__Account__c,ERP7__Channel__c,ERP7__Account__r.Name,ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name, ERP7__Expected_Date__c  FROM ERP7__Sales_order__c Where Id=:So_Id];
                List<RMAWrapperLI> RMAWrapperLIlist = new List<RMAWrapperLI>();
                Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
                Map<Id,ERP7__Sales_Order_Line_Item__c> soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>();
                
                for(Warranty__c warranty: [Select Id,Sales_Order_Line_Item__c From Warranty__c Where Sales_Order_Line_Item__r.ERP7__Sales_Order__c =: So_Id AND Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Is_Asset__c = false
                                           And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                               soli_WarrantyMap.put(warranty.Sales_Order_Line_Item__c,true);                                                          
                                           }
                soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>([SELECT Id,ERP7__Sales_Order__r.ERP7__Amount_Paid__c,ERP7__Sales_Order__r.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,ERP7__Other_Tax__c,Total_Price__c, ERP7__VAT_Amount__c,ERP7__Discount_Amount__c,Name,ERP7__Base_Price__c,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial_Number__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Organisation__c, ERP7__Sales_Order__r.Name,ERP7__Reserved_Quantity__c ,ERP7__Sales_Order__r.ERP7__Account__r.Name,ERP7__Sales_Order__r.ERP7__Order_Date__c ,ERP7__Sales_Order__r.ERP7__Status__c ,ERP7__Sales_Order__r.ERP7__Account__c,ERP7__Sales_Order__r.ERP7__Contact__c,ERP7__Sales_Order__r.ERP7__Ship_To_Address__c,  ERP7__ReturnedQuantity__c, ERP7__Quantity__c, ERP7__Product__c  ,ERP7__Product__r.ERP7__Serialise__c ,ERP7__Product__r.Name,ERP7__Product__r.ProductCode FROM ERP7__Sales_Order_Line_Item__c WHERE  ERP7__Sales_Order__c =:So_Id]);              
                set<Id> soliMapSerial = new Set<Id>();
                for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__SOLI__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__SOLI__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                    soliMapSerial.add(tempRMALI.ERP7__Serial_Number__c);
                }
                
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                IF(soliitemsMap.keySet().SIZE()>0)
                    for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Sales_Order_Line_Item__c,ERP7__Sales_Order_Line_Item__r.Name ,ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Sales_Order_Line_Item__c in: soliitemsMap.keySet() AND ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Serialise__c  = true AND ERP7__Status__c = 'Committed']){
                        List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c) != null)?rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                        templist.add(soli);
                        rentalSOLI_Map.put(soli.ERP7__Sales_Order_Line_Item__c,templist);
                    } 
                for(ERP7__Sales_Order_Line_Item__c so_Li:soliitemsMap.values()){
                    decimal taxAmount_perQty = ((so_Li.ERP7__Other_Tax__c + so_Li.ERP7__VAT_Amount__c)>0)?(so_Li.ERP7__Other_Tax__c + so_Li.ERP7__VAT_Amount__c)/so_Li.ERP7__Quantity__c:0.00; 
                    
                    /*Unit Price is calculated with Discount */ 
                    //decimal unitAmount_perQty = (so_Li.ERP7__Total_Price__c >0)?(so_Li.ERP7__Total_Price__c)/so_Li.ERP7__Quantity__c:0.00; 
                    decimal unitAmount_perQty = (so_Li.ERP7__Total_Price__c >0)?(so_Li.ERP7__Base_Price__c)/so_Li.ERP7__Quantity__c:0.00; 
                    unitAmount_perQty -= so_Li.ERP7__Sales_Order__r.ERP7__Coupon_Discount_Quantity__c;
                    if(so_li.ERP7__ReturnedQuantity__c == null)so_li.ERP7__ReturnedQuantity__c =0.00;
                    if(so_Li.ERP7__Product__r.ERP7__Serialise__c  &&  rentalSOLI_Map.get(so_Li.Id) != null){
                        for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(so_Li.Id)){
                            if(!soliMapSerial.contains(soli.ERP7__Serial__c)){
                                ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Total_Deduction__c   = so_li.Total_Price__c ,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus, ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Tax__c =  taxAmount_perQty, ERP7__Sale_Price__c = unitAmount_perQty,ERP7__Return_Reason__c='');
                                RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_Number__c=soli.ERP7__Serial__r.ERP7__Serial_Number__c);
                                if(so_li.ERP7__Batch_Lot__c != null){
                                    RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                    RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                                }
                                if(soli.Fixed_Asset__c != null)
                                    RMALI.Fixed_Asset__c = soli.Fixed_Asset__c;
                                else{
                                    RMALI.ERP7__Product__c = soli.ERP7__Product__c;
                                    RMALI.ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode);
                                }    
                                RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                RMAWrapperLIlist.add(temp_RMAWrapperLI);
                            }
                        }
                        
                    }else if(!so_Li.ERP7__Product__r.ERP7__Serialise__c){
                        decimal qty = double.valueof(so_li.ERP7__Quantity__c - so_li.ERP7__ReturnedQuantity__c);
                        if(qty>0.00){
                            ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.ERP7__Product__c , ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode) ,ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Total_Deduction__c   = so_li.Total_Price__c,ERP7__Tax__c = taxAmount_perQty,ERP7__Sale_Price__c = unitAmount_perQty,ERP7__Return_Reason__c='');
                            if(so_li.ERP7__Serial__c != null){
                                RMALI.ERP7__Serial_Number__c=so_li.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=so_li.ERP7__Serial__c,Name=so_li.ERP7__Serial__r.Name,ERP7__Serial_Number__c=so_li.ERP7__Serial__r.ERP7__Serial_Number__c);
                            }
                            if(so_li.ERP7__Batch_Lot__c != null){
                                RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                            }
                            RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                            RMAWrapperLIlist.add(temp_RMAWrapperLI);
                        }
                    }
                }
                obj.sObj = (ERP7__Sales_Order__c)so;
                obj.RAMLI_List = RMAWrapperLIlist;
            }
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        }
        return obj;
    }
    
    @AuraEnabled
    public static sObj_Wrapper Fetch_RMALI1(String So_Id){
        sObj_Wrapper obj = new sObj_Wrapper();
        try{
            String defaultAcceptanceType;
            String defaultReturnStatus;
            for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
                if (av.isDefaultValue()) { defaultAcceptanceType = av.getValue();break;}
            for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
                if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
            
            
            if(!String.isBlank(So_Id)){
                Order so = [SELECT Id,Name,AccountId,ERP7__Channel__c,Account.Name,ERP7__Contact__c,ERP7__Contact__r.Name,ERP7__Ship_To_Address__c,ERP7__Ship_To_Address__r.Name, ERP7__Expected_Date__c  FROM Order Where Id=:So_Id];
                List<RMAWrapperLI> RMAWrapperLIlist = new List<RMAWrapperLI>();
                Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
                Map<Id,OrderItem> soliitemsMap = new  Map<Id,OrderItem>();
                
                for(Warranty__c warranty: [Select Id,ERP7__Order_Product__c From Warranty__c Where ERP7__Order_Product__r.OrderId =: So_Id AND ERP7__Order_Product__r.Product2.ERP7__Is_Asset__c = false
                                           And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                               soli_WarrantyMap.put(warranty.ERP7__Order_Product__c,true);                                                          
                                           }
                soliitemsMap = new  Map<Id,OrderItem>([SELECT Id,Order.ERP7__Amount_Paid__c,Order.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c,ERP7__Other_Tax__c,ERP7__All_Total_Price__c, ERP7__VAT_Amount__c,ERP7__Discount_Amount__c,ERP7__Base_Price__c,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial_Number__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,OrderId,Order.Organisation__c, Order.Name,ERP7__Reserved_Quantity__c ,Order.Account.Name,Order.EffectiveDate ,Order.Status,Order.AccountId,Order.ERP7__Contact__c,Order.ERP7__Ship_To_Address__c,  ERP7__ReturnedQuantity__c, Quantity, Product2Id  ,Product2.ERP7__Serialise__c ,Product2.Name,Product2.ProductCode,UnitPrice,ERP7__Total_Price__c FROM OrderItem WHERE  OrderId =:So_Id]);               
                set<Id> soliMapSerial = new Set<Id>();
                for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__Ord_Item__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__Ord_Item__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                    soliMapSerial.add(tempRMALI.ERP7__Serial_Number__c);
                }
                
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                IF(soliitemsMap.keySet().SIZE()>0)
                    for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Order_Product__c,ERP7__Order_Product__r.Product2.Name ,ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Order_Product__c in: soliitemsMap.keySet() AND ERP7__Order_Product__r.Product2.ERP7__Serialise__c  = true AND ERP7__Status__c = 'Committed']){
                        List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Order_Product__c) != null)?rentalSOLI_Map.get(soli.ERP7__Order_Product__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                        templist.add(soli);
                        rentalSOLI_Map.put(soli.ERP7__Order_Product__c,templist);
                        
                    } 
                for(OrderItem so_Li:soliitemsMap.values()){
                    decimal taxAmount_perQty = ((so_Li.ERP7__Other_Tax__c + so_Li.ERP7__VAT_Amount__c)>0)?(so_Li.ERP7__Other_Tax__c + so_Li.ERP7__VAT_Amount__c)/so_Li.Quantity:0.00; 
                    
                    /*Unit Price is calculated with Discount */ 
                    //decimal unitAmount_perQty = (so_Li.ERP7__Total_Price__c >0)?(so_Li.ERP7__Total_Price__c)/so_Li.Quantity:0.00; 
                    decimal unitAmount_perQty = (so_Li.ERP7__Total_Price__c >0)?so_Li.UnitPrice:0.00;
                    unitAmount_perQty -= so_Li.Order.ERP7__Coupon_Discount_Quantity__c;
                    if(so_li.ERP7__ReturnedQuantity__c == null)so_li.ERP7__ReturnedQuantity__c =0.00;
                    if(so_Li.Product2.ERP7__Serialise__c  &&  rentalSOLI_Map.get(so_Li.Id) != null){
                        for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(so_Li.Id)){
                            if(!soliMapSerial.contains(soli.ERP7__Serial__c)){
                                ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Total_Deduction__c   = so_li.ERP7__All_Total_Price__c ,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus, ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Tax__c =  taxAmount_perQty, ERP7__Sale_Price__c = unitAmount_perQty,ERP7__Return_Reason__c='');
                                
                                RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_Number__c=soli.ERP7__Serial__r.ERP7__Serial_Number__c);
                                if(so_li.ERP7__Batch_Lot__c != null){
                                    RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                    RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                                }
                                if(soli.Fixed_Asset__c != null)
                                    RMALI.Fixed_Asset__c = soli.Fixed_Asset__c;
                                else{
                                    RMALI.ERP7__Product__c = soli.ERP7__Product__c;
                                    RMALI.ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode);
                                }    
                                /*'so_Li.ERP7__Serial__r '+so_Li.ERP7__Serial__r.Name*/
                                RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                RMAWrapperLIlist.add(temp_RMAWrapperLI);
                            }
                        }
                        
                    }else if(!so_Li.Product2.ERP7__Serialise__c){
                        decimal qty = double.valueof(so_li.Quantity - so_li.ERP7__ReturnedQuantity__c);
                        if(qty>0.00){
                            ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =so_li.Product2Id , ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode) ,ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = so_li.ERP7__Base_Price__c  ,ERP7__Total_Deduction__c   = so_li.ERP7__All_Total_Price__c,ERP7__Tax__c = taxAmount_perQty,ERP7__Sale_Price__c = unitAmount_perQty,ERP7__Return_Reason__c='');
                            if(so_li.ERP7__Serial__c != null){
                                RMALI.ERP7__Serial_Number__c=so_li.ERP7__Serial__c;
                                RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=so_li.ERP7__Serial__c,Name=so_li.ERP7__Serial__r.Name,ERP7__Serial_Number__c=so_li.ERP7__Serial__r.ERP7__Serial_Number__c);
                            }
                            if(so_li.ERP7__Batch_Lot__c != null){
                                RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                            }
                            RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                            RMAWrapperLIlist.add(temp_RMAWrapperLI);
                        }
                    }
                }
                obj.sObj = (Order)so;
                obj.RAMLI_List = RMAWrapperLIlist;
            }
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        }
        return obj;
    }
    
    @AuraEnabled
    public static sObj_Wrapper Build_RMALIByInvoice(String InvoiceId){
        sObj_Wrapper obj = new sObj_Wrapper();
        try{
            String defaultAcceptanceType;
            String defaultReturnStatus;
            for (Schema.PicklistEntry av1: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
                if (av1.isDefaultValue()) { defaultAcceptanceType = av1.getValue();break;}
            for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
                if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
            
            
            //try{
            if(!String.isBlank(InvoiceId)){
                ERP7__Invoice__c  Inv = [SELECT Id,Name,ERP7__Account__c,ERP7__Contact__c,ERP7__Order__c,ERP7__Order__r.ERP7__Channel__c,ERP7__Account__r.Name,ERP7__Order__r.ERP7__Contact__c,ERP7__Order__r.ERP7__Contact__r.Name,ERP7__Order__r.ERP7__Ship_To_Address__c,ERP7__Order__r.ERP7__Ship_To_Address__r.Name, ERP7__Order__r.Name,ERP7__Order__r.ERP7__Expected_Date__c  FROM ERP7__Invoice__c  Where Id=:InvoiceId Limit 1];
                List<RMAWrapperLI> RMAWrapperLIlist = new List<RMAWrapperLI>();
                Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
                Map<Id,ERP7__Sales_Order_Line_Item__c> soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>();
                List<ERP7__Invoice_Line_Item__c> invoiceLineItems = new List<ERP7__Invoice_Line_Item__c>();
                set<Id> soliIds = new set<Id>();
                for(Warranty__c warranty: [Select Id,Sales_Order_Line_Item__c From Warranty__c Where Sales_Order_Line_Item__r.ERP7__Invoice__c  =:InvoiceId
                                           And Valid_From__c <= Today And Valid_Till__c >= Today]){
                                               soli_WarrantyMap.put(warranty.Sales_Order_Line_Item__c,true);                                                          
                                           }
                invoiceLineItems = [SELECT Id,ERP7__Invoice__c,Name, ERP7__Discount_Amount__c, ERP7__Other_Tax__c, ERP7__Product__c,ERP7__Product__r.ERP7__Serialise__c, ERP7__Quantity__c, ERP7__Return_Quantity__c, ERP7__Sales_Order_Line_Item__c, ERP7__Base_Price__c, ERP7__Total_Price__c, ERP7__VAT_Amount__c,ERP7__Unit_Price__c  FROM ERP7__Invoice_Line_Item__c WHERE ERP7__Invoice__c =:InvoiceId ];
                for(ERP7__Invoice_Line_Item__c invli :invoiceLineItems){
                    if(invli.ERP7__Return_Quantity__c == null)invli.ERP7__Return_Quantity__c =0.00;
                    if((invli.ERP7__Quantity__c - invli.ERP7__Return_Quantity__c) >0.00)
                        soliIds.add(invli.ERP7__Sales_Order_Line_Item__c);
                }
                soliitemsMap = new  Map<Id,ERP7__Sales_Order_Line_Item__c>([SELECT Id,ERP7__Other_Tax__c,ERP7__Sales_Order__r.ERP7__Amount_Paid__c,ERP7__Sales_Order__r.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c, ERP7__VAT_Amount__c,ERP7__Discount_Amount__c,Name,ERP7__Base_Price__c,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial_Number__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,ERP7__Sales_Order__c,ERP7__Sales_Order__r.Organisation__c, ERP7__Sales_Order__r.Name,ERP7__Reserved_Quantity__c ,ERP7__Sales_Order__r.ERP7__Account__r.Name,ERP7__Sales_Order__r.ERP7__Order_Date__c ,ERP7__Sales_Order__r.ERP7__Status__c ,ERP7__Sales_Order__r.ERP7__Account__c,ERP7__Sales_Order__r.ERP7__Contact__c,ERP7__Sales_Order__r.ERP7__Ship_To_Address__c,  ERP7__ReturnedQuantity__c, ERP7__Quantity__c, ERP7__Product__c  ,ERP7__Product__r.ERP7__Serialise__c ,ERP7__Product__r.Name,ERP7__Product__r.ProductCode,Total_Price__c FROM ERP7__Sales_Order_Line_Item__c WHERE  Id IN: soliIds]);              
                set<Id> soliMapSerial = new Set<Id>(); 
                for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__SOLI__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__SOLI__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                    soliMapSerial.add(tempRMALI.ERP7__Serial_Number__c);
                }
                
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                If(soliitemsMap.keySet().SIZE()>0)
                    for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Sales_Order_Line_Item__c,ERP7__Sales_Order_Line_Item__r.Name ,ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Sales_Order_Line_Item__c in: soliitemsMap.keySet() AND ERP7__Sales_Order_Line_Item__r.ERP7__Product__r.ERP7__Serialise__c  = true AND ERP7__Status__c = 'Committed']){
                        List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c) != null)?rentalSOLI_Map.get(soli.ERP7__Sales_Order_Line_Item__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                        templist.add(soli);   
                        rentalSOLI_Map.put(soli.ERP7__Sales_Order_Line_Item__c,templist);
                        
                    } 
                for(ERP7__Invoice_Line_Item__c invli:invoiceLineItems){
                    
                    ERP7__Sales_Order_Line_Item__c so_li = soliitemsMap.get(invli.ERP7__Sales_Order_Line_Item__c);
                    if(so_Li != null){
                        decimal taxAmount_perQty = ((invli.ERP7__Other_Tax__c != null && invli.ERP7__VAT_Amount__c != null) && (invli.ERP7__Other_Tax__c + invli.ERP7__VAT_Amount__c)>0)?(invli.ERP7__Other_Tax__c + invli.ERP7__VAT_Amount__c)/invli.ERP7__Quantity__c:0.00; 
                        /*Product Coupon Discount is calculated */ 
                        decimal DiscountAmount_perQty = ( so_li.ERP7__Coupon__c != null && SO_li.ERP7__Quantity__c != null && so_li.ERP7__Coupon__c >0)?(so_li.ERP7__Coupon__c)/SO_li.ERP7__Quantity__c:0.00;
                        /*Unit Price is calculated with Discount */ 
                        //decimal unitAmount_perQty = (invli.ERP7__Total_Price__c >0)?(invli.ERP7__Total_Price__c)/invli.ERP7__Quantity__c:0.00;
                        decimal unitAmount_perQty = (invli.ERP7__Total_Price__c >0)?invli.ERP7__Unit_Price__c:0.00;
                        unitAmount_perQty -= DiscountAmount_perQty;
                        unitAmount_perQty -= so_Li.ERP7__Sales_Order__r.ERP7__Coupon_Discount_Quantity__c;
                        if(invli.ERP7__Return_Quantity__c == null)invli.ERP7__Return_Quantity__c =0.00;
                        if(invli.ERP7__Product__r.ERP7__Serialise__c  &&  rentalSOLI_Map.get(invli.ERP7__Sales_Order_Line_Item__c) != null){
                            for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(invli.ERP7__Sales_Order_Line_Item__c)){
                                if(!soliMapSerial.contains(soli.ERP7__Serial__c)){
                                    ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Invoice_Line_Item__c  = invli.Id,ERP7__Sale_Price__c  =unitAmount_perQty, ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = invli.ERP7__Base_Price__c  ,ERP7__Acceptance_Type__c = defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus, ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Tax__c = taxAmount_perQty,ERP7__Return_Reason__c='');
                                    RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);
                                    RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                    RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_Number__c=soli.ERP7__Serial__r.ERP7__Serial_Number__c);
                                    if(so_li.ERP7__Batch_Lot__c != null){ RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                                                         RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                                                                        }
                                    if(soli.Fixed_Asset__c != null)  RMALI.Fixed_Asset__c = soli.Fixed_Asset__c;
                                    else{
                                        RMALI.ERP7__Product__c = soli.ERP7__Product__c;
                                        RMALI.ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode);
                                    }                                  
                                    RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                    RMAWrapperLIlist.add(temp_RMAWrapperLI);
                                }
                            }
                            
                        }else if(!so_Li.ERP7__Product__r.ERP7__Serialise__c){
                            decimal qty = double.valueof(invli.ERP7__Quantity__c - invli.ERP7__Return_Quantity__c);
                            if(qty>0.00){
                                ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Invoice_Line_Item__c  = invli.Id,ERP7__Sale_Price__c  =unitAmount_perQty,ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =invli.ERP7__Product__c , ERP7__Product__r = new Product2(Name = so_li.ERP7__Product__r.Name, ProductCode = so_li.ERP7__Product__r.ProductCode) ,ERP7__SOLI__c=so_li.id,ERP7__Organisation__c = so_li.ERP7__Sales_Order__r.Organisation__c,Name=so_li.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = invli.ERP7__Base_Price__c ,ERP7__Tax__c = taxAmount_perQty,ERP7__Return_Reason__c='');
                                RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);
                                if(so_li.ERP7__Serial__c != null){ RMALI.ERP7__Serial_Number__c=so_li.ERP7__Serial__c;
                                                                  RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=so_li.ERP7__Serial__c,Name=so_li.ERP7__Serial__r.Name,ERP7__Serial_Number__c=so_li.ERP7__Serial__r.ERP7__Serial_Number__c);
                                                                 }
                                if(so_li.ERP7__Batch_Lot__c != null){ RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                                                     RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                                                                    } 
                                RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                RMAWrapperLIlist.add(temp_RMAWrapperLI);
                            }
                        }
                    }
                }
                obj.sObj = (ERP7__Invoice__c)Inv;
                obj.RAMLI_List = RMAWrapperLIlist;
            }
            /*'RAMLI_List=>'+obj.RAMLI_List.size()+'  ,RAMLI_List=>'+obj.RAMLI_List);*/
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        }
        return obj;
    }
    
    @AuraEnabled 
    public static sObj_Wrapper Fetch_RMALIByInvoice(String InvoiceId){
        sObj_Wrapper obj = new sObj_Wrapper();
        try{
            String defaultAcceptanceType;
            String defaultReturnStatus;
            for (Schema.PicklistEntry av1: ERP7__RMA_Line_Item__c.ERP7__Acceptance_Type__c.getDescribe().getPicklistValues()) 
                if (av1.isDefaultValue()) { defaultAcceptanceType = av1.getValue();break;}
            for (Schema.PicklistEntry av: ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe().getPicklistValues()) 
                if (av.isDefaultValue()) { defaultReturnStatus = av.getValue();break;}
            
            
            if(!String.isBlank(InvoiceId)){
                ERP7__Invoice__c  Inv = [SELECT Id,Name,ERP7__Account__c,ERP7__Contact__c,ERP7__Order_S__c,ERP7__Order_S__r.ERP7__Channel__c,ERP7__Account__r.Name,ERP7__Order_S__r.ERP7__Contact__c,ERP7__Order_S__r.ERP7__Contact__r.Name,ERP7__Order_S__r.ERP7__Ship_To_Address__c,ERP7__Order_S__r.ERP7__Ship_To_Address__r.Name, ERP7__Order_S__r.Name,ERP7__Order_S__r.ERP7__Expected_Date__c  FROM ERP7__Invoice__c  Where Id=:InvoiceId Limit 1];
                List<RMAWrapperLI> RMAWrapperLIlist = new List<RMAWrapperLI>();
                Map<Id,Boolean> soli_WarrantyMap = new Map<Id,Boolean>();
                Map<Id,OrderItem> soliitemsMap = new  Map<Id,OrderItem>();
                List<ERP7__Invoice_Line_Item__c> invoiceLineItems = new List<ERP7__Invoice_Line_Item__c>();
                set<Id> soliIds = new set<Id>();
                for(Warranty__c warranty: [Select Id,ERP7__Order_Product__c From ERP7__Warranty__c Where ERP7__Order_Product__r.ERP7__Invoice__c  =:InvoiceId
                                           And ERP7__Valid_From__c <= Today And ERP7__Valid_Till__c >= Today]){
                                               soli_WarrantyMap.put(warranty.ERP7__Order_Product__c,true);                                                          
                                           }
                invoiceLineItems = [SELECT Id,ERP7__Invoice__c,Name, ERP7__Discount_Amount__c, ERP7__Other_Tax__c, ERP7__Product__c,ERP7__Product__r.ERP7__Serialise__c, ERP7__Quantity__c, ERP7__Return_Quantity__c, ERP7__Order_Product__c, ERP7__Base_Price__c, ERP7__Total_Price__c, ERP7__VAT_Amount__c,ERP7__Unit_Price__c  FROM ERP7__Invoice_Line_Item__c WHERE ERP7__Invoice__c =:InvoiceId ];
                for(ERP7__Invoice_Line_Item__c invli :invoiceLineItems){
                    if(invli.ERP7__Return_Quantity__c == null){ invli.ERP7__Return_Quantity__c =0.00; }
                    if((invli.ERP7__Quantity__c - invli.ERP7__Return_Quantity__c) >0.00){ soliIds.add(invli.ERP7__Order_Product__c); }
                }
                soliitemsMap = new  Map<Id,OrderItem>([SELECT Id,ERP7__Other_Tax__c,Order.ERP7__Amount_Paid__c,Order.ERP7__Coupon_Discount_Quantity__c ,ERP7__Coupon__c, ERP7__VAT_Amount__c,ERP7__Discount_Amount__c,ERP7__Base_Price__c,ERP7__Batch_Lot__c,ERP7__Batch_Lot__r.Name,ERP7__Serial_Number__c,ERP7__Serial__c,ERP7__Serial__r.Name,ERP7__Serial__r.ERP7__Serial_Number__c,OrderId,Order.ERP7__Organisation__c, Order.Name,ERP7__Reserved_Quantity__c ,Order.Account.Name,Order.EffectiveDate ,Order.Status ,Order.AccountId,Order.ERP7__Contact__c,Order.ERP7__Ship_To_Address__c,  ERP7__ReturnedQuantity__c, Quantity, Product2Id  ,Product2.ERP7__Serialise__c ,Product2.Name,Product2.ProductCode,Total_Price__c FROM OrderItem WHERE  Id IN: soliIds]);              
                set<Id> soliMapSerial = new Set<Id>();
                for(ERP7__RMA_Line_Item__c tempRMALI:[Select Id,ERP7__Ord_Item__c, ERP7__Serial_Number__c  FROM ERP7__RMA_Line_Item__c WHERE ERP7__Ord_Item__c IN : soliitemsMap.keySet() AND ERP7__Serial_Number__c != null AND ERP7__Product__r.ERP7__Serialise__c = true]){
                    soliMapSerial.add(tempRMALI.ERP7__Serial_Number__c);
                }
                Map<Id,List<ERP7__Stock_Outward_Line_Item__c>> rentalSOLI_Map = new Map<Id,List<ERP7__Stock_Outward_Line_Item__c>>();
                if(soliitemsMap.keySet().SIZE()>0)
                    for (ERP7__Stock_Outward_Line_Item__c soli : [SELECT Id, ERP7__Fixed_Asset__c, ERP7__Product__c ,ERP7__Order_Product__c ,ERP7__Serial__c ,ERP7__Serial__r.Name, ERP7__Serial__r.ERP7__Serial_Number__c ,ERP7__Quantity__c FROM ERP7__Stock_Outward_Line_Item__c  WHERE ERP7__Order_Product__c in: soliitemsMap.keySet() AND ERP7__Order_Product__r.Product2.ERP7__Serialise__c  = true AND ERP7__Status__c = 'Committed']){
                        List<ERP7__Stock_Outward_Line_Item__c> templist = (rentalSOLI_Map.get(soli.ERP7__Order_Product__c) != null)?rentalSOLI_Map.get(soli.ERP7__Order_Product__c): new List<ERP7__Stock_Outward_Line_Item__c>();
                        templist.add(soli);   
                        rentalSOLI_Map.put(soli.ERP7__Order_Product__c,templist);
                    } 
                for(ERP7__Invoice_Line_Item__c invli:invoiceLineItems){
                    OrderItem so_li = soliitemsMap.get(invli.ERP7__Order_Product__c);
                    if(so_Li != null){
                        decimal taxAmount_perQty = ((invli.ERP7__Other_Tax__c != null && invli.ERP7__VAT_Amount__c != null) && (invli.ERP7__Other_Tax__c + invli.ERP7__VAT_Amount__c)>0)?(invli.ERP7__Other_Tax__c + invli.ERP7__VAT_Amount__c)/invli.ERP7__Quantity__c:0.00; 
                        //Product Coupon Discount is calculated
                        decimal DiscountAmount_perQty = ( so_li.ERP7__Coupon__c != null && SO_li.Quantity != null && so_li.ERP7__Coupon__c >0)?(so_li.ERP7__Coupon__c)/SO_li.Quantity:0.00;
                        //Unit Price is calculated with Discount
                        //decimal unitAmount_perQty = (invli.ERP7__Total_Price__c >0)?(invli.ERP7__Total_Price__c)/invli.ERP7__Quantity__c:0.00;
                        decimal unitAmount_perQty = (invli.ERP7__Total_Price__c >0)?invli.ERP7__Unit_Price__c:0.00;
                        unitAmount_perQty -= DiscountAmount_perQty;
                        unitAmount_perQty -= so_Li.Order.ERP7__Coupon_Discount_Quantity__c;
                        if(invli.ERP7__Return_Quantity__c == null)invli.ERP7__Return_Quantity__c =0.00;
                        if(invli.ERP7__Product__r.ERP7__Serialise__c  &&  rentalSOLI_Map.get(invli.ERP7__Order_Product__c) != null){
                            for (ERP7__Stock_Outward_Line_Item__c soli : rentalSOLI_Map.get(invli.ERP7__Order_Product__c)){
                                if(!soliMapSerial.contains(soli.ERP7__Serial__c)){
                                    ERP7__RMA_Line_Item__c RMALI = new ERP7__RMA_Line_Item__c(ERP7__Invoice_Line_Item__c  = invli.Id,ERP7__Sale_Price__c  =unitAmount_perQty, ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Base_Price__c = invli.ERP7__Base_Price__c  ,ERP7__Acceptance_Type__c = defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus, ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.ERP7__Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=soli.ERP7__Quantity__c,ERP7__Tax__c = taxAmount_perQty,ERP7__Return_Reason__c='');
                                    //RMALI.ERP7__Total_Deduction__c= invli.ERP7__Total_Price__c;
                                    RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);
                                    RMALI.ERP7__Serial_Number__c = soli.ERP7__Serial__c;
                                    RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=soli.ERP7__Serial__c,Name=soli.ERP7__Serial__r.Name,ERP7__Serial_Number__c=soli.ERP7__Serial__r.ERP7__Serial_Number__c);
                                    if(so_li.ERP7__Batch_Lot__c != null){
                                        RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                        RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                                    }
                                    if(soli.Fixed_Asset__c != null)
                                        RMALI.Fixed_Asset__c = soli.Fixed_Asset__c;
                                    else{
                                        RMALI.ERP7__Product__c = soli.ERP7__Product__c;
                                        RMALI.ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode);
                                    }                                  
                                    RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                    RMAWrapperLIlist.add(temp_RMAWrapperLI);
                                }
                            }
                            
                        }else if(!so_Li.Product2.ERP7__Serialise__c){
                            decimal qty = double.valueof(invli.ERP7__Quantity__c - invli.ERP7__Return_Quantity__c);
                            if(qty>0.00){
                                ERP7__RMA_Line_Item__c RMALI =  new ERP7__RMA_Line_Item__c(ERP7__Invoice_Line_Item__c  = invli.Id,ERP7__Sale_Price__c  =unitAmount_perQty,ERP7__Is_Warranty_Exists__c =soli_WarrantyMap.containsKey(so_Li.Id),ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c, ERP7__Serial_Number__c =so_li.ERP7__Serial__c,ERP7__Acceptance_Type__c =defaultAcceptanceType,ERP7__Return_Status__c=defaultReturnStatus,ERP7__Product__c =invli.ERP7__Product__c , ERP7__Product__r = new Product2(Name = so_li.Product2.Name, ProductCode = so_li.Product2.ProductCode) ,ERP7__Ord_Item__c=so_li.id,ERP7__Organisation__c = so_li.Order.ERP7__Organisation__c,Name=so_li.Product2.Name,ERP7__Quantity_Return__c=qty,ERP7__Base_Price__c = invli.ERP7__Base_Price__c ,ERP7__Tax__c = taxAmount_perQty,ERP7__Return_Reason__c='');
                                //RMALI.ERP7__Total_Deduction__c=invli.ERP7__Total_Price__c;
                                RMALI.ERP7__Total_Deduction__c= (RMALI.ERP7__Sale_Price__c*RMALI.ERP7__Quantity_Return__c)+(RMALI.ERP7__Tax__c*RMALI.ERP7__Quantity_Return__c);
                                if(so_li.ERP7__Serial__c != null){
                                    RMALI.ERP7__Serial_Number__c=so_li.ERP7__Serial__c;
                                    RMALI.ERP7__Serial_Number__r = new ERP7__Serial_Number__c(Id=so_li.ERP7__Serial__c,Name=so_li.ERP7__Serial__r.Name,ERP7__Serial_Number__c=so_li.ERP7__Serial__r.ERP7__Serial_Number__c);
                                }
                                if(so_li.ERP7__Batch_Lot__c != null){
                                    RMALI.ERP7__Batch_Lot__c = so_li.ERP7__Batch_Lot__c;
                                    RMALI.ERP7__Batch_Lot__r = new ERP7__Batch__c(Name = so_li.ERP7__Batch_Lot__r.Name);
                                } 
                                RMAWrapperLI temp_RMAWrapperLI = new RMAWrapperLI(so_Li,RMALI,soli_WarrantyMap.containsKey(so_Li.Id));
                                RMAWrapperLIlist.add(temp_RMAWrapperLI);
                            }
                        }
                    }
                }
                obj.sObj = (ERP7__Invoice__c)Inv;
                obj.RAMLI_List = RMAWrapperLIlist;
            }
            /*'RAMLI_List=>'+obj.RAMLI_List.size()+'  ,RAMLI_List=>'+obj.RAMLI_List*/
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        }
        return obj;
    }
    
    @AuraEnabled
    public static void DeleteByRMALIId(String recordData){
        try{
            ERP7__RMA_Line_Item__c rmali_2_Delete = (ERP7__RMA_Line_Item__c)JSON.deserialize(recordData, ERP7__RMA_Line_Item__c.class);
            if(ERP7__RMA_Line_Item__c.sObjectType.getDescribe().isDeletable()) { delete rmali_2_Delete; } else{/* no access to delete*/}
        } catch (Exception e) {
            system.debug('Exp~>'+e.getMessage()+' at '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static Map<String, Boolean> getCRUD(){
        Map<String,Boolean> crudValues = new Map<String,Boolean>();
        crudValues.put('ERP7__PO__c', Schema.sObjectType.ERP7__PO__c.isAccessible());
        crudValues.put('ERP7__WO__c', Schema.sObjectType.ERP7__WO__c.isAccessible());
        crudValues.put('ERP7__Is_Closed__c', Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Is_Closed__c.isAccessible());
        return crudValues;
    }   
    
    public class sObj_Wrapper{
        @AuraEnabled  public sObject  sObj                 { get; set; }
        @AuraEnabled  public List<RMAWrapperLI> RAMLI_List { get; set; }
        public sObj_Wrapper(){
            RAMLI_List = new List<RMAWrapperLI>();
        }
    }
    
    public class customerInfo{
        @AuraEnabled public Contact contact    { get; set; }
        @AuraEnabled public Address__c Address { get; set; }
        @AuraEnabled  public List<RMAWrapperLI> RAMLI_List { get; set; }
        public customerInfo(){
            contact = new Contact();
            Address = new Address__c();
            RAMLI_List = new List<RMAWrapperLI>();
        }
    } 
    
    public class RMAWrapperLI{
        @AuraEnabled public Boolean isSelect                     { get; set; }
        @AuraEnabled public Boolean isfinalSelect                     { get; set; }
        @AuraEnabled public ERP7__RMA_Line_Item__c  RMALI        { get; set; }
        @AuraEnabled public ERP7__Sales_Order_Line_Item__c  SOLI { get; set; }
        @AuraEnabled public OrderItem  OrdItem { get; set; }
        @AuraEnabled public Boolean  isWarranty_Exists { get; set; }
        @AuraEnabled public Decimal  returnQty { get; set; }
        @AuraEnabled public String  reasonReason { get; set; }
        @AuraEnabled public String  accepType { get; set; }
        public RMAWrapperLI(ERP7__Sales_Order_Line_Item__c SOLI,ERP7__RMA_Line_Item__c RMALI,Boolean isWarranty_Exists){
            isSelect = isfinalSelect = false;
            this.SOLI = SOLI;
            this.RMALI = RMALI;
            this.isWarranty_Exists = isWarranty_Exists;
            returnQty = 0.0;
            reasonReason = accepType = '';
        }   
        
        public RMAWrapperLI(OrderItem SOLI,ERP7__RMA_Line_Item__c RMALI,Boolean isWarranty_Exists){
            isSelect = isfinalSelect = false;
            this.OrdItem = SOLI;
            this.RMALI = RMALI;
            this.isWarranty_Exists = isWarranty_Exists;
            returnQty = 0.0;
            reasonReason = accepType = '';
        }   
    }   
}