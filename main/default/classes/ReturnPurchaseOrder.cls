public with sharing class ReturnPurchaseOrder{  
    public ReturnPurchaseOrder(){
        Sales_Order__c so=new Sales_Order__c();
    }

    @AuraEnabled   
    public String ChannelId { get; set; } 
    @AuraEnabled
    public ERP7__Distribution_Channel__c distributionchannel { get; set; }
    
    @AuraEnabled
    public ERP7__PO__c RPO         {set;get;}
    @AuraEnabled
    public ERP7__Purchase_Line_Items__c  RPOLI         {set;get;}
    
    @AuraEnabled 
    public LIst<String> POStatusList                      { get; set; }
    
    @AuraEnabled
    public static ReturnPurchaseOrder getInstance(){
        ReturnPurchaseOrder rpo = new ReturnPurchaseOrder();
        rpo.POStatusList=getStatus();   
        
        List<ERP7__Employees__c> emp = [Select Id,Channel__C FROM ERP7__Employees__c  Where ERP7__Employee_User__c  =:userinfo.getUserId()];
        if(emp != null && emp.size()>0){  rpo.ChannelId = emp[0].Channel__c;  List<ERP7__Distribution_Channel__c> dc_list = [SELECT Id,Name,ERP7__Channel__c,ERP7__Site__c ,ERP7__Site__r.Name, ERP7__Site__r.ERP7__Address__c,ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line1__c,ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line2__c,ERP7__Site__r.ERP7__Address__r.ERP7__City__c,ERP7__Site__r.ERP7__Address__r.ERP7__State__c,ERP7__Site__r.ERP7__Address__r.ERP7__Postal_Code__c,ERP7__Site__r.ERP7__Address__r.ERP7__Country__c 
                                                          FROM ERP7__Distribution_Channel__c
                                                          Where ERP7__Channel__c =: emp[0].Channel__c AND ERP7__Active__c = true                                                         
                                                          order by ERP7__Priority__c limit 1];  if(dc_list !=null && dc_list.size()>0) rpo.distributionchannel =dc_list[0]; 
        }
        
        rpo.RPO=new ERP7__PO__c();
        rpo.RPOLI=new ERP7__Purchase_Line_Items__c();
        return rpo;   
        
    }
    
    @AuraEnabled   
    public static sObj_Wrapper fetch_RMALI(String RMA_Id){
        sObj_Wrapper obj = new sObj_Wrapper();
        if(String.isNotEmpty(RMA_Id)){
         obj.sObj=(ERP7__PO__c) [SELECT Id, Name, ERP7__Vendor__c, ERP7__Vendor__r.Name, ERP7__Vendor_Contact__c, ERP7__Vendor_Contact__r.Name, ERP7__Status__c, ERP7__Expected_Date__c, ERP7__Amount_Paid__c, ERP7__Is_Closed__c, ERP7__Ready_To_Pick_Pack__c,
                                 ERP7__Channel__c, ERP7__Distribution_Channel__c 
                  FROM ERP7__PO__c WHERE Id=:RMA_Id];
         
         /*Map<Id,ERP7__Purchase_Line_Items__c> RAMLI_Map= new  Map<Id,ERP7__Purchase_Line_Items__c>
             ([SELECT Id,Name, ERP7__Purchase_Orders__c, ERP7__Code__c, ERP7__Product__c, ERP7__Product__r.Name,ERP7__Serial_Number_Prefix__c, ERP7__Return_Quanitty__c, ERP7__Unit_Price__c, ERP7__Total_Price__c 
              FROM ERP7__Purchase_Line_Items__c WHERE  ERP7__Purchase_Orders__c=:obj.sObj.Id]);
         obj.RAMLI_List = RAMLI_Map.values();
        */ 
            String qryFilter='';
            qryFilter += ' ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__c =:RMA_Id';  
            String QueryStr='SELECT Id,Name, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.Name'+                                  
                ' FROM ERP7__Bill_Line_Item__c WHERE'+String.escapeSingleQuotes(qryFilter)+' Order By Name ASC'; //, ERP7__Master_Purchase_Orders__r.Nam
            list<ERP7__Bill_Line_Item__c> BLItems=Database.query(QueryStr);
            Set<String> PoliIds=new Set<String>();
            for(ERP7__Bill_Line_Item__c b:BLItems) PoliIds.add(b.ERP7__Purchase_Order_Line_Items__c);
            list<String> PoliIdList=new list<String>();
            PoliIdList.addAll(new list<String>(PoliIds));  //string firstelement=(new list<string>(setelements) )[0] );
             
            obj.RAMLI_List=[SELECT Id,Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name, ERP7__Code__c, ERP7__Product__c, ERP7__Product__r.Name,ERP7__Serial_Number_Prefix__c, ERP7__Return_Quanitty__c, ERP7__Unit_Price__c, ERP7__Total_Price__c,
                ERP7__Product__r.ProductCode, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name                                  
                FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c=:RMA_Id Order By Name ASC]; //Id IN:PoliIdList
      
        } 
            
        return obj; 
    }
    
    @AuraEnabled   
    public static sObj_Wrapper getEditRPOLI(String RPOLIJSON, String action){
        ERP7__Purchase_Line_Items__c RPOLIRecord= (ERP7__Purchase_Line_Items__c) JSON.deserialize(RPOLIJSON, ERP7__Purchase_Line_Items__c .class); 
        if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Purchase_Line_Items__c.isUpdateable()){ upsert RPOLIRecord; } else{ /*not alllowed*/ }
        sObj_Wrapper obj = new sObj_Wrapper();
        if(String.isNotEmpty(RPOLIRecord.Id)){       
         Map<Id,ERP7__Purchase_Line_Items__c> RAMLI_Map= new  Map<Id,ERP7__Purchase_Line_Items__c>
             ([SELECT Id,Name, ERP7__Purchase_Orders__c, ERP7__Code__c, ERP7__Product__c, ERP7__Product__r.Name,ERP7__Serial_Number_Prefix__c, ERP7__Return_Quanitty__c, ERP7__Unit_Price__c, ERP7__Total_Price__c 
              FROM ERP7__Purchase_Line_Items__c WHERE Id=:RPOLIRecord.Id LIMIT 1]);//  ERP7__Purchase_Orders__c=:RPOLIRecord.ERP7__Purchase_Orders__c
         obj.RAMLI_List = RAMLI_Map.values(); 
    }
    return obj;    
   }  
    
  @AuraEnabled
    public static RPOWrapperLI getPoliByCustomer(String CustID, String DistributeChannelId, String selPolis){ //,Integer OFF_SET,String SoI 
        /*'getPoliByCustomer CustID==>'+CustID+'  ,DistributeChannelId==>'+DistributeChannelId+'  ,selPolis==>'+selPolis); CustID='0012400000cxpFuAAI'; */
        String qryFilter ='';
       // if(String.isNotEmpty(CustID)) qryFilter += ' ERP7__Purchase_Orders__r.ERP7__Vendor__c =\''+CustID+'\'';       
        RPOWrapperLI pw=new RPOWrapperLI();
        if(String.isNotEmpty(CustID)){ 
           /* String QueryStr='SELECT Id,Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name, ERP7__Code__c, ERP7__Product__c, ERP7__Product__r.Name,ERP7__Serial_Number_Prefix__c, ERP7__Return_Quanitty__c, ERP7__Unit_Price__c, ERP7__Total_Price__c'+
                ' ,ERP7__Product__r.ProductCode, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name'+                                  
                ' FROM ERP7__Purchase_Line_Items__c WHERE'+qryFilter+' Order By Name ASC'; //, ERP7__Master_Purchase_Orders__r.Nam
           'getPoliByCustomer  QueryStr==>'+QueryStr);
            pw.PoliList=Database.query(QueryStr);
            */
            if(String.isNotEmpty(CustID)) qryFilter += ' ERP7__Purchase_Order_Line_Items__r.ERP7__Purchase_Orders__r.ERP7__Vendor__c =:CustID';  
            String QueryStr='SELECT Id,Name, ERP7__Purchase_Order_Line_Items__c, ERP7__Purchase_Order_Line_Items__r.Name'+                                  
                ' FROM ERP7__Bill_Line_Item__c WHERE'+String.escapeSingleQuotes(qryFilter)+' Order By Name ASC'; //, ERP7__Master_Purchase_Orders__r.Nam
            list<ERP7__Bill_Line_Item__c> BLItems=Database.query(QueryStr);
            Set<String> PoliIds=new Set<String>();
            for(ERP7__Bill_Line_Item__c b:BLItems) PoliIds.add(b.ERP7__Purchase_Order_Line_Items__c);
            list<String> PoliIdList=new list<String>();
            PoliIdList.addAll(new list<String>(PoliIds));  //string firstelement=(new list<string>(setelements) )[0] );
              
         
           list<String> PoliId=new list<String>();
           
           if(String.isNotEmpty(selPolis)){  String[] selPolisList=selPolis.split(',');     for(Integer i=0; i<selPolisList.size(); i++) {  for(Integer j=0; j<PoliIdList.size(); j++) {  /*'getPoliByCustomer  1==>'+selPolisList[i].trim()+'  ,2==>'+PoliIdList[j].trim());*/  if(selPolisList[i].trim()!=PoliIdList[j].trim()) PoliId.add(PoliIdList[j]);
            }
            }
           }else PoliId.addAll(PoliIdList); 
            

            
            ERP7__Distribution_Channel__c dc=new ERP7__Distribution_Channel__c();
            if(String.isNotEmpty(DistributeChannelId)) dc=[SELECT Id, Name, ERP7__Site__c FROM ERP7__Distribution_Channel__c WHERE Id=:DistributeChannelId]; 
             if(PoliIds.size()>0 && String.isNotEmpty(dc.ERP7__Site__c))   pw.PoliList=[SELECT Id,Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Orders__r.Name, ERP7__Code__c, ERP7__Product__c, ERP7__Product__r.Name,ERP7__Serial_Number_Prefix__c, ERP7__Return_Quanitty__c, ERP7__Unit_Price__c, ERP7__Total_Price__c,
                ERP7__Product__r.ProductCode, ERP7__Material_Batch_Lot__c, ERP7__Material_Batch_Lot__r.Name, ERP7__Site__c, ERP7__Site__r.Name                                  
                FROM ERP7__Purchase_Line_Items__c WHERE Id IN:PoliId AND ERP7__Site__c=:dc.ERP7__Site__c]; // PoliId PoliIdList
           
            
        }
        return pw;
    }
  
    @AuraEnabled
    public static customerInfo FetchcustomerInfo(String custId){
        customerInfo custinfo = new customerInfo();
       if(String.isNotEmpty(custId)){                                                         
        try{
         
                custinfo.Address = [SELECT Id,Name,ERP7__Address_Line1__c , ERP7__Address_Line2__c ,ERP7__City__c ,ERP7__State__c ,ERP7__Postal_Code__c,ERP7__Country__c FROM ERP7__Address__c WHERE ERP7__Customer__c=:CustId AND ERP7__Primary__c = true AND ERP7__Is_Shipping_Address__c =true limit 1];
          
        }catch(QueryException qe){
        
            custinfo.Address=(custinfo.Address == null)?null:custinfo.Address;
        }
                                                                
        try{
      
                custinfo.contact = [SELECT Id,Name,Email,Phone,Account.Name FROM Contact Where AccountId=:custId AND ERP7__Primary__c =true limit 1];
         
        }catch(QueryException qe){
            custinfo.contact=(custinfo.contact == null)?null:custinfo.contact;
         
        }
       }
    
        return custinfo;
    }
    
    @AuraEnabled
    public static ERP7__Distribution_Channel__c getDistributeChannelDetails(String dcId){
     
     ERP7__Distribution_Channel__c DC=new ERP7__Distribution_Channel__c();
    if(String.isNotEmpty(dcId))  
       return [SELECT Id,Name,ERP7__Channel__c,ERP7__Site__c ,ERP7__Site__r.Name, ERP7__Site__r.ERP7__Address__c,ERP7__Site__r.ERP7__Address__r.Name,ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line1__c,
               ERP7__Site__r.ERP7__Address__r.ERP7__Address_Line2__c,ERP7__Site__r.ERP7__Address__r.ERP7__City__c,ERP7__Site__r.ERP7__Address__r.ERP7__State__c,
               ERP7__Site__r.ERP7__Address__r.ERP7__Postal_Code__c,ERP7__Site__r.ERP7__Address__r.ERP7__Country__c 
               FROM ERP7__Distribution_Channel__c
               WHERE Id=:dcId];
      else return null;
    }
    
    @AuraEnabled
    public static ERP7__PO__c getCreateRPO(String RPO, String Polis){ 
         ERP7__PO__c po=(ERP7__PO__c)JSON.deserialize(RPO, ERP7__PO__c .class);
         
        Boolean isNewPO=false;                                                        
        if(String.isEmpty(po.Id)){
            po.Id=null; isNewPO=true;
            Id RTID; RTID = Schema.SObjectType.ERP7__PO__c.getRecordTypeInfosByDeveloperName().get('Return_to_Vendor_RTV').getRecordTypeId();
            if(Schema.sObjectType.ERP7__PO__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__PO__c.fields.RecordTypeId.isUpdateable() && RTID != null) po.RecordTypeId=RTID; }
        else isNewPO=false; 
        if(Schema.sObjectType.ERP7__PO__c.isCreateable() && Schema.sObjectType.ERP7__PO__c.isUpdateable()){upsert po;  } else{ /*no access*/ }  
         
        list<ERP7__Purchase_Line_Items__c> PoliList=(list<ERP7__Purchase_Line_Items__c>)JSON.deserialize(Polis, list<ERP7__Purchase_Line_Items__c> .class);
        list<String> PoliIds=new list<String>(); for(ERP7__Purchase_Line_Items__c r:PoliList) PoliIds.add(r.Id);  
        list<ERP7__Purchase_Line_Items__c> PList=new list<ERP7__Purchase_Line_Items__c>();
        PList=[SELECT id, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, erp7__purchase_orders__c, erp7__active__c, erp7__completion_date__c, erp7__invoiced__c, erp7__quantity_received__c, erp7__quantity__c, erp7__shipping_cost__c, erp7__special_instruction__c, erp7__tax__c, erp7__total_price__c, erp7__total_tax__c, erp7__unit_price__c, erp7__unit__c, erp7__code__c, erp7__cost_card__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__serial_number_prefix__c, erp7__unit_of_measure__c, erp7__handling_fee__c, erp7__mrp_material_requirements_planning__c, erp7__purchase_requisition_line_items__c, erp7__purchase_requisitions__c, erp7__sales_order_line_item__c, erp7__sales_order__c, erp7__setup_fee__c, erp7__reconciled__c, 
               erp7__batch_lot_code__c, erp7__barcode__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__remaining_quantity__c, erp7__product__c, erp7__explode__c, erp7__asset__c, erp7__serialise__c, erp7__stock_to_asset__c, erp7__match_type__c, erp7__material_batch_lot__c, erp7__version__c, erp7__starting_number__c, erp7__master_purchase_line_items__c, erp7__return_quanitty__c, erp7__site__c 
               FROM ERP7__Purchase_Line_Items__c WHERE Id IN:PoliIds];
        
        for(Integer i=0; i< PList.size(); i++){   
            PList[i].Id=null;  
            if(Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Purchase_Orders__c.isCreateable() && Schema.sObjectType.ERP7__Purchase_Line_Items__c.fields.ERP7__Purchase_Orders__c.isUpdateable()) PList[i].ERP7__Purchase_Orders__c=po.Id;
        }         
        
        if(isNewPO==false){  list<ERP7__Purchase_Line_Items__c> PListOld=[SELECT Id, Name, ERP7__Purchase_Orders__c FROM ERP7__Purchase_Line_Items__c WHERE ERP7__Purchase_Orders__c=:po.Id]; if(PListOld.size()>0 && ERP7__Purchase_Line_Items__c.sObjectType.getDescribe().isDeletable()){ delete PListOld; } else{ /*not allowed*/ }
        }   

        if(PList.size()>0 && Schema.sObjectType.ERP7__Purchase_Line_Items__c.isCreateable() && Schema.sObjectType.ERP7__Purchase_Line_Items__c.isUpdateable()) { upsert PList; } else{ /* not allowed*/ }  return po;
    }    
    
    
    
    @AuraEnabled
    public static List<String> getFreightType(){
        List<String> options = new List<String>(); Schema.DescribeFieldResult fieldResult = Return_Merchandise_Authorisation__c.Frieght_Type__c.getDescribe(); List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled
    public static List<String> getStatus(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = ERP7__RMA_Line_Item__c.ERP7__Return_Status__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        } return options;
    } 
    @AuraEnabled
    public static List<String> getRMAStatus(){
        List<String> options = new List<String>(); Schema.DescribeFieldResult fieldResult = ERP7__PO__c.ERP7__Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); for (Schema.PicklistEntry f: ple) options.add(f.getLabel()); return options;
    }
    @AuraEnabled
    public static String getSiteDetails(String recordId){
        List<ERP7__Site__c> siteList = new List<ERP7__Site__c>(); if(String.isNotEmpty(recordId)) siteList = [SELECT Id,ERP7__Address__c FROM ERP7__Site__c Where Id=:recordId]; return (siteList.size()>0)? siteList[0].ERP7__Address__c:'';
    }  
    @AuraEnabled
    public static ERP7__Distribution_Channel__c getSiteDetailsbyDC(String recordId){
        List<ERP7__Distribution_Channel__c> dcList = new List<ERP7__Distribution_Channel__c>(); if(String.isNotEmpty(recordId)) dcList = [SELECT Id,Name,ERP7__Channel__c,ERP7__Site__c ,ERP7__Site__r.Name FROM ERP7__Distribution_Channel__c Where Id =:recordId]; return (dcList.size()>0)? dcList[0]:null;
    }
    
    
    
    
    @AuraEnabled 
    public static ERP7__Address__c FetchAddressById(String custId,String recordId){
        List<ERP7__Address__c> addressList = new List<ERP7__Address__c>();
        String qryFilter = '';
        if(String.isNotEmpty(custId)) qryFilter +=' AND ERP7__Customer__c=:CustId';
        if(String.isNotEmpty(recordId)) qryFilter +=' AND Id =:recordId';
        if(String.isNotEmpty(qryFilter))
            addressList = Database.query('SELECT Id,Name,ERP7__Address_Line1__c , ERP7__Address_Line2__c ,ERP7__City__c ,ERP7__State__c ,ERP7__Postal_Code__c,ERP7__Country__c FROM ERP7__Address__c WHERE Name != null '+String.escapeSingleQuotes(qryFilter)+' LIMIT 1 ');        
        if(addressList.size()>0) return addressList[0];  return null;
    }
  
 
 
    @AuraEnabled
    public static void DeleteByRMALIId(String Poli){  ERP7__Purchase_Line_Items__c poliRecord = (ERP7__Purchase_Line_Items__c)JSON.deserialize(Poli, ERP7__Purchase_Line_Items__c.class); if(ERP7__Purchase_Line_Items__c.sObjectType.getDescribe().isDeletable()) { delete poliRecord;} else{/*not allowed*/} } 
    
    @AuraEnabled
    public static Map<String, Boolean> getCRUD(){
        Map<String,Boolean> crudValues = new Map<String,Boolean>();
        crudValues.put('ERP7__PO__c', Schema.sObjectType.ERP7__PO__c.isAccessible());
        crudValues.put('ERP7__WO__c', Schema.sObjectType.ERP7__WO__c.isAccessible());
        crudValues.put('ERP7__Is_Closed__c', Schema.sObjectType.ERP7__Return_Merchandise_Authorisation__c.fields.ERP7__Is_Closed__c.isAccessible());
        return crudValues;
    }
 
    public class sObj_Wrapper{ 
        @AuraEnabled 
        public sObject  sObj { get; set; }
        @AuraEnabled 
        public LIst<ERP7__Purchase_Line_Items__c> RAMLI_List { get; set; }
     
    }
       public class RPOWrapperLI{
        @AuraEnabled 
        public Boolean isSelect { get; set; }
        @AuraEnabled
        public ERP7__Purchase_Line_Items__c  POLI { get; set; }
        @AuraEnabled
        public list<ERP7__Purchase_Line_Items__c>  PoliList { get; set; }
       
        public RPOWrapperLI(){
           isSelect = false;
           POLI=new ERP7__Purchase_Line_Items__c();
           PoliList=new list<ERP7__Purchase_Line_Items__c>();  
        }   
    }
    public class customerInfo{
        @AuraEnabled 
        public Contact contact { get; set; }
        @AuraEnabled
        public Address__c Address { get; set; }
    }    
}