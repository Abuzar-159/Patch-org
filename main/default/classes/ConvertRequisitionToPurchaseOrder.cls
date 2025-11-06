public With Sharing class ConvertRequisitionToPurchaseOrder {
    
    @AuraEnabled public String channel {get; set;}
    @AuraEnabled public ERP7__Distribution_Channel__c distributionChannel {get; set;}
    @AuraEnabled public List<wrapper> wrap {get; set;}
    
    @AuraEnabled
    public static ConvertRequisitionToPurchaseOrder fetchRequistionLineItems(String searchString, String DcId, Integer Offset, Integer RecordLimit,String PRId){
        ConvertRequisitionToPurchaseOrder CRTP = new ConvertRequisitionToPurchaseOrder();
        CRTP.channel = '';
        CRTP.distributionChannel = new ERP7__Distribution_Channel__c();
        
        List<wrapper> wrap = new List<wrapper>();
        try{
            Integer ikOffset = Integer.valueof(Offset);
            Integer ikRecordLimit = Integer.valueof(RecordLimit);
            ERP7__Distribution_Channel__c distributionChannel = new ERP7__Distribution_Channel__c();
            List<ERP7__Distribution_Channel__c> exdcList = new List<ERP7__Distribution_Channel__c>();
            List<ERP7__Distribution_Channel__c> dcList = new List<ERP7__Distribution_Channel__c>();
            String DcSite = '';
            if(String.isNotEmpty(DcId)) exdcList = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                    where Id=:DcId and ERP7__Active__c=true AND ERP7__Site__c != null AND ERP7__Channel__c != null order by ERP7__Priority__c limit 1];
            if(exdcList.size()>0){
                CRTP.channel = exdcList[0].ERP7__Channel__c;
                distributionChannel = exdcList[0];
                CRTP.distributionChannel = exdcList[0];
                DcId = exdcList[0].Id;
                DcSite = exdcList[0].ERP7__Site__c;
            }else{
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c where ERP7__Employee_User__c=:UserInfo.getUserId()];
                
                if(empList.size()>0 && empList[0].ERP7__Channel__c != null){
                    CRTP.channel = empList[0].ERP7__Channel__c;
                    dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                    if(dcList.size() > 0){ 
                        distributionChannel = dcList[0];
                        CRTP.distributionChannel = dcList[0];
                        DcId = dcList[0].Id;
                        DcSite = dcList[0].ERP7__Site__c;
                    }
                }
            }
            
            List<ERP7__Purchase_Requisition_Line_Items__c> reqLineList = new List<ERP7__Purchase_Requisition_Line_Items__c>();
             
            String Approved = 'Approved';
            String Incomplete = 'Incomplete';
            
            if(String.isNotEmpty(DcId)){
                String query = 'Select Id, Name, ERP7__Purchase_Requisition__c, ERP7__Is_Purchase_Order__c,ERP7__Purchase_Requisition__r.ERP7__Employee_Requester__r.Name,ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c, ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name,ERP7__Purchase_Requisition__r.ERP7__Order_S__c,ERP7__Quantity__c, ERP7__Unit__c, ERP7__Price__c, ERP7__Amount__c, ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name,ERP7__Notes__c, ERP7__Description__c, ERP7__Purchase_Requisition__r.Name, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name,ERP7__Purchase_Requisition__r.ERP7__Status__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__r.Name,ERP7__Purchase_Requisition__r.ERP7__Originating_Business_Unit__c, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__c,ERP7__Purchase_Requisition__r.ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Expected_Delivery_Date__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Vendor_Supplier_Description__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Default_Vendor__r.Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Actual_Delivery_Date__c, ERP7__Purchase_Requisition__r.ERP7__Channel__c, ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c from ERP7__Purchase_Requisition_Line_Items__c ';
                query += ' where ERP7__Purchase_Orders__c = null AND ERP7__Purchase_Requisition__r.ERP7__Active__c = true  AND ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c =: DcId AND (ERP7__Purchase_Requisition__r.ERP7__Status__c =: Approved OR ERP7__Purchase_Requisition__r.ERP7__Status__c =: Incomplete) ';
                if(String.isNotEmpty(searchString)){
                    String s= '%'+searchString+'%';
                    query += ' AND (ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name Like :s OR ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name Like :s OR  ERP7__Product__r.ERP7__Default_Vendor__r.Name Like :s OR ERP7__Product__r.Name Like :s OR ERP7__Purchase_Requisition__r.Name Like :s or ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name Like :s) ';
                }
                if(String.isNotEmpty(PRId)) query += ' AND ERP7__Purchase_Requisition__c =: PRId ';
                query += ' ORDER BY CreatedDate ASC limit :ikRecordLimit Offset :ikOffset ';
                reqLineList = Database.query(query);
                /*reqLineList = [Select Id, Name, ERP7__Purchase_Requisition__c, ERP7__Is_Purchase_Order__c, ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name,ERP7__Purchase_Requisition__r.ERP7__Order_S__c,
ERP7__Quantity__c, ERP7__Unit__c, ERP7__Price__c, ERP7__Amount__c, ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name,
ERP7__Notes__c, ERP7__Description__c, ERP7__Purchase_Requisition__r.Name, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name,
ERP7__Purchase_Requisition__r.ERP7__Status__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__r.Name,
ERP7__Purchase_Requisition__r.ERP7__Originating_Business_Unit__c, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__c,
ERP7__Purchase_Requisition__r.ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Expected_Delivery_Date__c, ERP7__Product__c, ERP7__Product__r.Name, 
ERP7__Product__r.ERP7__Vendor_Supplier_Description__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Default_Vendor__r.Name, ERP7__Purchase_Orders__c, 
ERP7__Purchase_Requisition__r.ERP7__Actual_Delivery_Date__c, ERP7__Purchase_Requisition__r.ERP7__Channel__c, ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c 
from ERP7__Purchase_Requisition_Line_Items__c where ERP7__Purchase_Orders__c=null and ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c=:distributionChannel.Id
AND ERP7__Purchase_Requisition__r.ERP7__Active__c=true AND(ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name Like :searchString OR ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name Like :searchString OR  ERP7__Product__r.ERP7__Default_Vendor__r.Name Like :searchString OR ERP7__Product__r.Name Like :searchString) ORDER BY CreatedDate DESC];*/
            }
            system.debug('reqLineList.size() : '+reqLineList.size());
            if(reqLineList.size() > 0 && String.isNotEmpty(DcSite)){
                set<Id> productIds = new set<Id>();
                for(ERP7__Purchase_Requisition_Line_Items__c pr : reqLineList){
                    productIds.add(pr.ERP7__Product__c);
                }
                if(productIds.size() > 0){
                    List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                    WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c, Number_of_Item_In_Stock__c,ERP7__No_of_Items_Requested__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__Number_of_Items_Awaiting_in_Stock__c,  Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                                    From Inventory_Stock__c  Where ERP7__Product__c IN: productIds And  Active__c = true And  Warehouse__c =: DcSite  ];
                    
                    for(ERP7__Purchase_Requisition_Line_Items__c preq : reqLineList){
                        wrapper wr = new wrapper(); Decimal myStock = 0; Decimal demand=0; Decimal AWaitingStocks = 0.0;
                        for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                            if(preq.ERP7__Product__c == WIIS.product__c)  {
                                myStock += WIIS.Number_of_Item_In_Stock__c;  
                                demand+=WIIS.ERP7__No_of_Items_Requested__c;  
                                AWaitingStocks += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                            } else{ myStock=0; demand=0; AWaitingStocks = 0; }  
                        }
                        wr.reqline = preq; wr.selected = false; wr.ItemsinStock = myStock;  wr.demand = demand;  wr.AwaitingStock = AWaitingStocks;  
                        wrap.add(wr);
                    }
                }
            }
        }catch(Exception e){ 
            System.debug('Exception ~> '+ e.getMessage()+'; at line ~> '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        }
        CRTP.wrap = wrap;
        return CRTP;
    }
    
    @AuraEnabled
    public static List<wrapper> fetchSortedRequistion(String OrderBy, String Order, String DcId, Integer Offset, Integer RecordLimit){
        List<wrapper> wrap = new List<wrapper>();
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
         String Approved = 'Approved';
            String Incomplete = 'Incomplete';
        ERP7__Distribution_Channel__c distributionChannel;
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            /*'inside empList is :'+empList*/
            List<ERP7__Distribution_Channel__c> dcList;
            if(empList.size()>0 && empList != null){
              dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                 distributionChannel = dcList[0];
            }
        List<ERP7__Purchase_Requisition_Line_Items__c> reqLineList;
        try{
            String dc = '';
            if(DcId!=null && DcId!='') dc=DcId; else dc = distributionChannel.Id;
            String query = 'Select Id, Name, ERP7__Purchase_Requisition__c, ERP7__Is_Purchase_Order__c, ERP7__Purchase_Requisition__r.ERP7__Employee_Requester__r.Name,ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c, ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name,ERP7__Purchase_Requisition__r.ERP7__Order_S__c,ERP7__Quantity__c, ERP7__Unit__c, ERP7__Price__c, ERP7__Amount__c, ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name,ERP7__Notes__c, ERP7__Description__c, ERP7__Purchase_Requisition__r.Name, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name,ERP7__Purchase_Requisition__r.ERP7__Status__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__r.Name,ERP7__Purchase_Requisition__r.ERP7__Originating_Business_Unit__c, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__c,ERP7__Purchase_Requisition__r.ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Expected_Delivery_Date__c, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Product__r.ERP7__Vendor_Supplier_Description__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Default_Vendor__r.Name, ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Actual_Delivery_Date__c, ERP7__Purchase_Requisition__r.ERP7__Channel__c, ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c from ERP7__Purchase_Requisition_Line_Items__c where ERP7__Purchase_Orders__c=null and ';
            query = query +'ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c=:dc AND ERP7__Purchase_Requisition__r.ERP7__Active__c=true AND (ERP7__Purchase_Requisition__r.ERP7__Status__c =: Approved OR ERP7__Purchase_Requisition__r.ERP7__Status__c =: Incomplete) ORDER BY ';
            query = query + String.escapeSingleQuotes(OrderBy) + ' ' + String.escapeSingleQuotes(Order);
            query = query +' limit :ikRecordLimit Offset :ikOffset';
            reqLineList = Database.query(query);
            /*reqLineList = [Select Id, Name, ERP7__Purchase_Requisition__c, ERP7__Is_Purchase_Order__c, ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name,ERP7__Purchase_Requisition__r.ERP7__Order_S__c,
                           ERP7__Quantity__c, ERP7__Unit__c, ERP7__Price__c, ERP7__Amount__c, ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name,
                           ERP7__Notes__c, ERP7__Description__c, ERP7__Purchase_Requisition__r.Name, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name,
                           ERP7__Purchase_Requisition__r.ERP7__Status__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__r.Name,
                           ERP7__Purchase_Requisition__r.ERP7__Originating_Business_Unit__c, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__c,
                           ERP7__Purchase_Requisition__r.ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Expected_Delivery_Date__c, ERP7__Product__c, ERP7__Product__r.Name, 
                           ERP7__Product__r.ERP7__Vendor_Supplier_Description__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Default_Vendor__r.Name, ERP7__Purchase_Orders__c, 
                           ERP7__Purchase_Requisition__r.ERP7__Actual_Delivery_Date__c, ERP7__Purchase_Requisition__r.ERP7__Channel__c, ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c 
                           from ERP7__Purchase_Requisition_Line_Items__c where ERP7__Purchase_Orders__c=null and ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c=:distributionChannel.Id
                           AND ERP7__Purchase_Requisition__r.ERP7__Active__c=true AND(ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name Like :searchString OR ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name Like :searchString OR  ERP7__Product__r.ERP7__Default_Vendor__r.Name Like :searchString OR ERP7__Product__r.Name Like :searchString) ORDER BY CreatedDate DESC];*/
            if(reqLineList.size() > 0){
                set<Id> productIds = new set<Id>();
                for(ERP7__Purchase_Requisition_Line_Items__c pr : reqLineList){
                    productIds.add(pr.ERP7__Product__c);
                }
                if(productIds.size() > 0){
                    List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                    WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, ERP7__Number_of_Items_Awaiting_in_Stock__c,Organisation_Business_Unit__c, Warehouse__c, product__c, Number_of_Item_In_Stock__c,ERP7__No_of_Items_Requested__c, Number_of_Item_Purchased_In__c, ERP7__Version__c, Number_of_Items_Dispatched__c, No_of_Items_Sold__c From Inventory_Stock__c Where ERP7__Product__c IN: productIds And Active__c = true And Warehouse__c =: dcList[0].ERP7__Site__c];
            
                    for(ERP7__Purchase_Requisition_Line_Items__c preq : reqLineList){
                        wrapper wr = new wrapper();
                        Decimal myStock = 0;Decimal AWaitingStocks = 0.0;  Decimal demand=0;
                        for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) { if(preq.ERP7__Product__c == WIIS.product__c) { myStock += WIIS.Number_of_Item_In_Stock__c; AWaitingStocks += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c; demand += WIIS.ERP7__No_of_Items_Requested__c;} }                        
             					wr.reqline = preq; wr.ItemsinStock = myStock;  wr.demand = demand;    wr.AwaitingStock = AWaitingStocks; wrap.add(wr);
                    }
                
                }
            }
        
          
        }Catch(Exception e){
            system.debug('Exception'+e+' '+e.getLineNumber()+' '+e.getMessage());
            return null;
        }
        return wrap;
    }
    
    @AuraEnabled
    public static ConvertRequisitionToPurchaseOrder fetchChannelandDC(){
        ConvertRequisitionToPurchaseOrder CRTP = new ConvertRequisitionToPurchaseOrder();
        CRTP.channel = '';
        CRTP.distributionChannel = new ERP7__Distribution_Channel__c();
        List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
        if(empList.size()>0 && empList[0].ERP7__Channel__c != null){
            CRTP.channel = empList[0].ERP7__Channel__c;
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
            /*'fetchChannelandDC dcList is :'+dcList.size()*/
            if(dcList.size()>0) CRTP.distributionChannel = dcList[0];

        }
        return CRTP;
    }
       
    public class reline{
        @AuraEnabled
        public List<wrapper> poli {get; set;}
        @AuraEnabled
        public Integer psize {get;set;}
        public reline(){
            poli = new List<wrapper>();
            psize = 0;
        }
    }
    
    @AuraEnabled
    public static reline getDCByChan(String recordId, Integer Offset, Integer RecordLimit){
        reline rp = new reline();
        List<wrapper> wrap = new List<wrapper>();
        Integer ikOffset = Integer.valueof(Offset);
        Integer ikRecordLimit = Integer.valueof(RecordLimit);
        List<ERP7__Purchase_Requisition_Line_Items__c> reqLineList;
        List<ERP7__Distribution_Channel__c> dcList; 
        String Approved = 'Approved';
        String Incomplete = 'Incomplete';
        
        if(String.isNotEmpty(recordId)){
            dcList = [Select Id,Name,ERP7__Site__c from ERP7__Distribution_Channel__c where Id=:recordId];
            reqLineList = [Select Id, Name, ERP7__Purchase_Requisition__c, ERP7__Is_Purchase_Order__c, 
                           ERP7__Quantity__c, ERP7__Unit__c, ERP7__Price__c, ERP7__Amount__c, ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c,ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name,
                           ERP7__Notes__c, ERP7__Description__c, ERP7__Purchase_Requisition__r.Name, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name, ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name,ERP7__Purchase_Requisition__r.ERP7__Order_S__c,
                           ERP7__Purchase_Requisition__r.ERP7__Status__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__r.Name,
                           ERP7__Purchase_Requisition__r.ERP7__Originating_Business_Unit__c, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__c,
                           ERP7__Purchase_Requisition__r.ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Expected_Delivery_Date__c, ERP7__Product__c, ERP7__Product__r.Name, 
                           ERP7__Product__r.ERP7__Vendor_Supplier_Description__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Default_Vendor__r.Name, ERP7__Purchase_Orders__c, 
                           ERP7__Purchase_Requisition__r.ERP7__Actual_Delivery_Date__c, ERP7__Purchase_Requisition__r.ERP7__Employee_Requester__r.Name, ERP7__Purchase_Requisition__r.ERP7__Channel__c, ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c 
                           from ERP7__Purchase_Requisition_Line_Items__c where ERP7__Purchase_Orders__c=null and ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c=:recordId
                           AND ERP7__Purchase_Requisition__r.ERP7__Active__c = true AND (ERP7__Purchase_Requisition__r.ERP7__Status__c =: Approved OR ERP7__Purchase_Requisition__r.ERP7__Status__c =: Incomplete) limit :ikRecordLimit Offset :ikOffset];
        }
        else{
            reqLineList = [Select Id, Name, ERP7__Purchase_Requisition__c, ERP7__Is_Purchase_Order__c, 
                           ERP7__Quantity__c, ERP7__Unit__c, ERP7__Price__c, ERP7__Amount__c, ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c,ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name,
                           ERP7__Notes__c, ERP7__Description__c, ERP7__Purchase_Requisition__r.Name, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name, ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name,ERP7__Purchase_Requisition__r.ERP7__Order_S__c,
                           ERP7__Purchase_Requisition__r.ERP7__Status__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__r.Name,
                           ERP7__Purchase_Requisition__r.ERP7__Originating_Business_Unit__c, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__c,
                           ERP7__Purchase_Requisition__r.ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Expected_Delivery_Date__c, ERP7__Product__c, ERP7__Product__r.Name, 
                           ERP7__Product__r.ERP7__Vendor_Supplier_Description__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Default_Vendor__r.Name, ERP7__Purchase_Orders__c, 
                           ERP7__Purchase_Requisition__r.ERP7__Actual_Delivery_Date__c, ERP7__Purchase_Requisition__r.ERP7__Employee_Requester__r.Name, ERP7__Purchase_Requisition__r.ERP7__Channel__c, ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c 
                           from ERP7__Purchase_Requisition_Line_Items__c where ERP7__Purchase_Orders__c=null
                           AND ERP7__Purchase_Requisition__r.ERP7__Active__c = true  AND (ERP7__Purchase_Requisition__r.ERP7__Status__c =: Approved OR ERP7__Purchase_Requisition__r.ERP7__Status__c =: Incomplete) limit :ikRecordLimit Offset :ikOffset];
        }
        if(reqLineList.size() > 0){
            set<Id> productIds = new set<Id>();
            for(ERP7__Purchase_Requisition_Line_Items__c pr : reqLineList){
                productIds.add(pr.ERP7__Product__c);
            }
            if(productIds.size() > 0){
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c, Number_of_Item_In_Stock__c, ERP7__Number_of_Items_Awaiting_in_Stock__c,ERP7__No_of_Items_Requested__c,Number_of_Item_Purchased_In__c, ERP7__Version__c, Number_of_Items_Dispatched__c, No_of_Items_Sold__c From Inventory_Stock__c Where ERP7__Product__c IN: productIds And Active__c = true And Warehouse__c =: dcList[0].ERP7__Site__c ];
                
                for(ERP7__Purchase_Requisition_Line_Items__c preq : reqLineList){
                    wrapper wr = new wrapper();
                    Decimal myStock = 0; Decimal demand=0;  Decimal AWaitingStocks = 0.0;
                    for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) { if(preq.ERP7__Product__c == WIIS.product__c)  { myStock += WIIS.Number_of_Item_In_Stock__c; demand += WIIS.ERP7__No_of_Items_Requested__c; AWaitingStocks += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;}                  
                                                                               }
                    
                    wr.reqline = preq;  wr.ItemsinStock = myStock;   wr.demand = demand;   wr.AwaitingStock = AWaitingStocks;  wrap.add(wr);
                }
                
            }
        }
        reqLineList = new List<ERP7__Purchase_Requisition_Line_Items__c>();
        reqLineList = [Select Id, Name, ERP7__Purchase_Requisition__c, ERP7__Is_Purchase_Order__c, 
                       ERP7__Quantity__c, ERP7__Unit__c, ERP7__Price__c, ERP7__Amount__c, ERP7__Purchase_Requisition__r.ERP7__Sales_Order__c,ERP7__Purchase_Requisition__r.ERP7__Sales_Order__r.Name,
                       ERP7__Notes__c, ERP7__Description__c, ERP7__Purchase_Requisition__r.Name, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__r.Name, ERP7__Purchase_Requisition__r.ERP7__Order_S__r.Name,ERP7__Purchase_Requisition__r.ERP7__Order_S__c,
                       ERP7__Purchase_Requisition__r.ERP7__Status__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__c, ERP7__Purchase_Requisition__r.ERP7__Organisation__r.Name,
                       ERP7__Purchase_Requisition__r.ERP7__Originating_Business_Unit__c, ERP7__Purchase_Requisition__r.ERP7__Requisitioned_By__c,
                       ERP7__Purchase_Requisition__r.ERP7__Purchase_Orders__c, ERP7__Purchase_Requisition__r.ERP7__Expected_Delivery_Date__c, ERP7__Product__c, ERP7__Product__r.Name, 
                       ERP7__Product__r.ERP7__Vendor_Supplier_Description__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Default_Vendor__r.Name, ERP7__Purchase_Orders__c, 
                       ERP7__Purchase_Requisition__r.ERP7__Actual_Delivery_Date__c, ERP7__Purchase_Requisition__r.ERP7__Employee_Requester__r.Name, ERP7__Purchase_Requisition__r.ERP7__Channel__c, ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c 
                       from ERP7__Purchase_Requisition_Line_Items__c where ERP7__Purchase_Orders__c=null and ERP7__Purchase_Requisition__r.ERP7__Distribution_Channel__c=:recordId
                       AND ERP7__Purchase_Requisition__r.ERP7__Active__c = true  AND (ERP7__Purchase_Requisition__r.ERP7__Status__c =: Approved OR ERP7__Purchase_Requisition__r.ERP7__Status__c =: Incomplete) limit 2000];
        rp.psize = reqLineList.size();
        rp.poli = wrap;
        return rp;
        
    }
    
    @AuraEnabled
    public static List<ERP7__Reordering_Rule__c> getReorderingRules(String SelectedSite, List<String> ProIds){    
        List<ERP7__Reordering_Rule__c> ReorderingRules = new List<ERP7__Reordering_Rule__c>();
        if(SelectedSite != '' && SelectedSite != null && ProIds != null && ProIds.size() > 0){
            List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c where Id =: SelectedSite];
            system.debug('dcList : '+dcList.size());
            if(dcList.size() > 0 && dcList[0].ERP7__Site__c != null){
                SelectedSite = dcList[0].ERP7__Site__c;
                ReorderingRules = [Select Id, Name, ERP7__Base_Quantity__c, ERP7__Channel__c, ERP7__Lead_Time__c, ERP7__Maximum_Quantity__c, ERP7__Minimum_Quantity__c, ERP7__Product__c, ERP7__Warning_Quantity__c, ERP7__Quantity_Multiple__c, ERP7__Stock_Quantity__c, ERP7__Warehouse__c, ERP7__MinimumHoldingQuantity__c, ERP7__MinimumOrderingQuantity__c From ERP7__Reordering_Rule__c Where ERP7__Product__c In :ProIds And ERP7__MinimumHoldingQuantity__c != Null And ERP7__MinimumOrderingQuantity__c != Null And ERP7__Warehouse__c = :SelectedSite Order By CreatedDate Desc];
            }   
        }
    
        return ReorderingRules;
    }
    
    public class wrapper{
        @AuraEnabled public ERP7__Purchase_Requisition_Line_Items__c reqline {get;set;}
        @AuraEnabled public Decimal ItemsinStock {get;set;}
        @AuraEnabled public Decimal demand {get;set;}
        @AuraEnabled public Decimal AwaitingStock  {get;set;}
        @AuraEnabled public String Errmsg  {get;set;}
        @AuraEnabled public Boolean selected  {get;set;}
        public wrapper(){
            reqline = new ERP7__Purchase_Requisition_Line_Items__c();
            ItemsinStock = 0.0; demand = 0.0;   AwaitingStock = 0.0; Errmsg = ''; selected = false;
        }
    }
    
}