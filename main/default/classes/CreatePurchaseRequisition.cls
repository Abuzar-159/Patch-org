public with sharing class CreatePurchaseRequisition {
    
    
    @AuraEnabled
    public String channel {get; set;}
    @AuraEnabled
    public ERP7__Distribution_Channel__c distributionChannel {get; set;}
    @AuraEnabled
    public Account OrgAcc {get; set;}
    @AuraEnabled
    public ERP7__Employees__c emplRequester {get; set;}
    @AuraEnabled
    public ERP7__Business_Unit__c BusinessUnit {get; set;}
    @AuraEnabled
    public Contact DeliveryCon {get; set;}
    @AuraEnabled
    public ERP7__Address__c DeliveryAdd {get; set;}
    @AuraEnabled
    public Boolean salesAccess {get; set;}
    @AuraEnabled
    public String SOID1 {get; set;} 
    
    /* @AuraEnabled
public static Order fetchdetails(String OrderId){
Order ord = [Select Id , Name,BillToContactId ,ERP7__Bill_To_Address__c ,AccountId, ERP7__Organisation__c ,ERP7__Contact__c From Order where Id=:OrderId];
return ord;
}*/
    
    @AuraEnabled
    public static CreatePurchaseRequisition fetchChannelandDC(String OId,String SOLIId){
        
        CreatePurchaseRequisition CPR = new CreatePurchaseRequisition();
        try{
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c ,ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            if(empList.size()>0 && empList != null){
                CPR.emplRequester = empList[0];
                CPR.channel = empList[0].ERP7__Channel__c;
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null order by ERP7__Priority__c limit 1];
                if(dcList.size()>0 && dcList != null) CPR.distributionChannel = dcList[0];
                
            }
            if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Active__c.isAccessible())  { CPR.salesAccess = true; } else { CPR.salesAccess = false; }
            
            if(OId != ''){
                Order ord = [Select Id , Name , ERP7__Organisation__c , ERP7__Bill_To_Address__c ,ERP7__Contact__c,ERP7__Organisation_Business_Unit__c from Order where Id=:OId Limit 1];
                Account acc = [Select Id , Name   from Account Where Id = :ord.ERP7__Organisation__c limit 1];
                CPR.OrgAcc=acc;
                List<Contact> con = [Select Id , Name ,  AccountId ,ERP7__Primary__c from Contact Where Id=:ord.ERP7__Contact__c limit 1];
                CPR.DeliveryCon=con[0];
                List<ERP7__Address__c> add = [Select Name ,  ERP7__Contact__c ,ERP7__Is_Billing_Address__c from ERP7__Address__c Where Id=:ord.ERP7__Bill_To_Address__c limit 1];
                CPR.DeliveryAdd=add[0];
            }
            else{
                Account acc = [Select Id , Name,ERP7__Organisation_Business_Unit__c   from Account Where Id=:empList[0].ERP7__Channel__r.ERP7__Organisation__c  limit 1];
                CPR.OrgAcc = acc;
                ERP7__Business_Unit__c bus = new ERP7__Business_Unit__c();
                if(acc!= null) if(acc.ERP7__Organisation_Business_Unit__c != null) bus =    [Select Id , Name   from ERP7__Business_Unit__c Where id=:acc.ERP7__Organisation_Business_Unit__c   limit 1];
                else bus =    [Select Id , Name   from ERP7__Business_Unit__c Where ERP7__Organisation__c=:empList[0].ERP7__Channel__r.ERP7__Organisation__c  limit 1];
                if(bus != null) CPR.BusinessUnit = bus;
                List<Contact> con = [Select Id , Name ,  AccountId ,ERP7__Primary__c from Contact Where AccountId=:acc.Id limit 1];
                CPR.DeliveryCon=con[0];
                List<ERP7__Address__c> add = [Select Name ,  ERP7__Customer__c,ERP7__Contact__c ,ERP7__Is_Billing_Address__c from ERP7__Address__c Where (ERP7__Customer__c=:acc.Id AND ERP7__Is_Billing_Address__c = TRUE) limit 1];
                CPR.DeliveryAdd=add[0];
            }
            if(SOLIId != '' && SOLIId != null){
                ERP7__Sales_Order_Line_Item__c solilist = [Select Id,ERP7__Sales_Order__c ,Name From ERP7__Sales_Order_Line_Item__c where Id=:SOLIId];
                if(solilist != null ) CPR.SOID1 = solilist.ERP7__Sales_Order__c;
            }
        }catch(Exception e){ /*'Error : '+e.getLineNumber()+' Message : '+e.getMessage() */ }
        return CPR;
    }
    
    @AuraEnabled
    public static WrapperClass getStatus(){
        WrapperClass wrap = new WrapperClass();
        List<String> options = new List<String>(); 
        Schema.DescribeFieldResult fieldResult = ERP7__Requisition__c.ERP7__Status__c.getDescribe(); 
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
        for (Schema.PicklistEntry f: ple) options.add(f.getLabel());  wrap.StatusList =options;
        if(Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Originating_Business_Unit__c.isAccessible()) wrap.isAccessible =true;
        return wrap;
    }
    
    @AuraEnabled
    public static ERP7__Requisition__c save_PurchaseRequisition(String purchaseRequisition,String PRLI_List,String orderId,String SOId){
        ERP7__Requisition__c prequisitions = (ERP7__Requisition__c) JSON.deserialize(purchaseRequisition, ERP7__Requisition__c.class);
        if(Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Active__c.isUpdateable()) prequisitions.ERP7__Active__c = true;
        if(Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Status__c.isUpdateable() && (prequisitions.ERP7__Status__c == null || prequisitions.ERP7__Status__c == '')) prequisitions.ERP7__Status__c = 'In Process';
        if(orderId !=null && orderId !=''){ if(Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Order_S__c.isCreateable() && Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Order_S__c.isUpdateable()) prequisitions.ERP7__Order_S__c = orderId;}
        if(SOId !=null && SOId !=''){ if(Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Requisition__c.fields.ERP7__Sales_Order__c.isUpdateable()) prequisitions.ERP7__Sales_Order__c = SOId;}
        if(prequisitions != null && Schema.sObjectType.ERP7__Requisition__c.isCreateable() && Schema.sObjectType.ERP7__Requisition__c.isUpdateable()){ upsert prequisitions;} else{ }
        
        List<ERP7__Purchase_Requisition_Line_Items__c> pr_List = (List<ERP7__Purchase_Requisition_Line_Items__c>) JSON.deserialize(PRLI_List, List<ERP7__Purchase_Requisition_Line_Items__c>.class);
        for(Integer i = 0;i<pr_List.size();i++){
            if(Schema.sObjectType.ERP7__Purchase_Requisition_Line_Items__c.fields.ERP7__Purchase_Requisition__c.isCreateable() || Schema.sObjectType.ERP7__Purchase_Requisition_Line_Items__c.fields.ERP7__Purchase_Requisition__c.isUpdateable()) pr_List[i].ERP7__Purchase_Requisition__c = prequisitions.id;
        }
        
        if(pr_List.size()>0 && (Schema.sObjectType.ERP7__Purchase_Requisition_Line_Items__c.isCreateable() || Schema.sObjectType.ERP7__Purchase_Requisition_Line_Items__c.isUpdateable())){ upsert pr_List;} else{ }
        return prequisitions; 
    }
    
    @AuraEnabled
    public static ERP7__Purchase_Requisition_Line_Items__c populateSOLI(String soliID)
    {
        ERP7__Sales_Order_Line_Item__c SOLI;
        ERP7__Purchase_Requisition_Line_Items__c prli;
        if(soliID != null && soliID != ''){
            SOLI = [Select Name, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Sales_Order__c,
                    ERP7__Total_Price__c, ERP7__PriceBook_Base_Price__c, ERP7__Description__c, ERP7__Base_Price__c from ERP7__Sales_Order_Line_Item__c where Id=:soliID];
            prli = new ERP7__Purchase_Requisition_Line_Items__c(Name = SOLI.Name,ERP7__Product__c = SOLI.ERP7__Product__c,ERP7__Product__r=new Product2(Id=SOLI.ERP7__Product__c,Name=SOLI.ERP7__Product__r.Name),Quantity__c = SOLI.ERP7__Quantity__c);//,ERP7__Price__c = SOLI.ERP7__PriceBook_Base_Price__c,ERP7__Amount__c = SOLI.ERP7__Total_Price__c
        }    
        return prli;
    }
    
    
    @AuraEnabled
    public static POWrapper populateOrdItems(String orderId1, String SalesId)
    {
        POWrapper poWrap = new POWrapper();
        List<OrderItem> ordItemList=new List<OrderItem>();
        List<ERP7__Sales_Order_Line_Item__c> SOLIList = new  List<ERP7__Sales_Order_Line_Item__c>();
        Decimal OrdQty = 0;
        List<ERP7__Purchase_Requisition_Line_Items__c> prliList=new List<ERP7__Purchase_Requisition_Line_Items__c>();
        try{
            if(orderId1 != null && orderId1 != ''){
                ordItemList = [Select Id, Product2Id, Product2.Name, Quantity, OrderId,UnitPrice,
                               ERP7__Total_Price__c, ERP7__PriceBook_Base_Price__c, Description, ERP7__Base_Price__c from OrderItem where OrderId=:orderId1 and ERP7__Is_Back_Order__c = true];
                for(OrderItem ordItem:ordItemList){
                    ERP7__Purchase_Requisition_Line_Items__c prli=new ERP7__Purchase_Requisition_Line_Items__c();
                    prli.Name=ordItem.Id;
                    prli.ERP7__Product__c=ordItem.Product2Id;
                    prli.ERP7__Product__r=new Product2(Id=ordItem.Product2Id,Name=ordItem.Product2.Name);
                    prli.Quantity__c = ordItem.Quantity;
                    // OrdQty = ordItem.Quantity;
                    prliList.add(prli);
                }
                list<ERP7__Requisition__c> reqList=new list<ERP7__Requisition__c>();  
                reqList=[SELECT Id, Name, ERP7__Order_S__c, ERP7__Active__c FROM ERP7__Requisition__c
                         WHERE ERP7__Order_S__c=:orderId1 AND ERP7__Active__c=true];
                set<String> reqIds=new set<String>();
                
                for(ERP7__Requisition__c s:reqList) reqIds.add(s.Id);
                
                list<ERP7__Purchase_Requisition_Line_Items__c> ReqLIList=new list<ERP7__Purchase_Requisition_Line_Items__c>();  
                ReqLIList=[SELECT Id, Name, ERP7__Order_Product__c,ERP7__Quantity__c,ERP7__Product__c FROM ERP7__Purchase_Requisition_Line_Items__c
                           WHERE ERP7__Purchase_Requisition__c IN:reqIds AND ERP7__Product__c!=Null]; //ERP7__Sales_Order_Line_Item__c IN:SoliIds  
                // Map < Id, decimal > Prod_Quantity = new Map < Id, decimal > ();
                //for(ERP7__Purchase_Requisition_Line_Items__c pr :ReqLIList ) Prod_Quantity.put(pr.ERP7__Product__c,pr.ERP7__Quantity__c);
                Set<Id> proIds=new Set<Id>();
                for(ERP7__Purchase_Requisition_Line_Items__c pr :ReqLIList ){
                    proIds.add(pr.ERP7__Product__c);
                }
                
                Map<String,Decimal> proQuanMap=new Map<String,Decimal>();
                for(Id pro:proIds){
                    Decimal quantity=0;
                    for(ERP7__Purchase_Requisition_Line_Items__c pr :ReqLIList ){
                        if(pro == pr.ERP7__Product__c){
                            quantity+=pr.ERP7__Quantity__c;
                            
                        }
                    }
                    proQuanMap.put(pro,quantity);
                }
                Map<String,Decimal> OrdproQuanMap=new Map<String,Decimal>();
                for(Id prod:proIds){
                    Decimal quantityOrd=0;
                    for(OrderItem orp :ordItemList ){
                        if(prod == orp.Product2Id){
                            quantityOrd+=orp.Quantity;
                            
                        }
                    }
                    OrdproQuanMap.put(prod,quantityOrd);
                }
                Map<String,Decimal> ReqproQuanMap=new Map<String,Decimal>();
                for(String OrdMap : OrdproQuanMap.keySet()){
                    Decimal finalQty = 0 ;
                    for(String Req :  proQuanMap.keySet()){
                        if(OrdMap == Req) {
                            finalQty= OrdproQuanMap.get(OrdMap) - proQuanMap.get(Req);
                        }
                    } ReqproQuanMap.put(OrdMap,finalQty);  
                }
                for(Integer i=0; i<prliList.size(); i++){
                    for(String finalQ : ReqproQuanMap.keySet()){
                        if((finalQ == prliList[i].ERP7__Product__c) && (ReqproQuanMap.get(finalQ) != prliList[i].ERP7__Quantity__c) && (prliList[i].ERP7__Quantity__c != 0)){
                            prliList[i].ERP7__Quantity__c = ReqproQuanMap.get(finalQ);
                        }
                        if((finalQ == prliList[i].ERP7__Product__c) && (prliList[i].ERP7__Quantity__c == 0)) prliList.remove(i); 
                    }
                }
            }    
            if(SalesId != null && SalesId != ''){
                SOLIList = [Select Id, ERP7__Product__c, ERP7__Product__r.Name, ERP7__Quantity__c, ERP7__Sales_Order__c,
                            ERP7__Total_Price__c, ERP7__PriceBook_Base_Price__c, ERP7__Description__c, ERP7__Base_Price__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c=:SalesId and ERP7__Is_Back_Order__c = true];
                for(ERP7__Sales_Order_Line_Item__c SOLItem : SOLIList){
                    ERP7__Purchase_Requisition_Line_Items__c prli=new ERP7__Purchase_Requisition_Line_Items__c();
                    prli.Name=SOLItem.Id;
                    prli.ERP7__Product__c=SOLItem.ERP7__Product__c;
                    prli.ERP7__Product__r=new Product2(Id=SOLItem.ERP7__Product__c,Name=SOLItem.ERP7__Product__r.Name);
                    prli.Quantity__c = SOLItem.ERP7__Quantity__c;
                    // OrdQty = SOLItem.Quantity;
                    prliList.add(prli);
                }
                list<ERP7__Requisition__c> reqList=new list<ERP7__Requisition__c>();  
                reqList=[SELECT Id, Name, ERP7__Sales_Order__c, ERP7__Active__c FROM ERP7__Requisition__c
                         WHERE ERP7__Sales_Order__c=:SalesId AND ERP7__Active__c=true];
                set<String> reqIds=new set<String>();
                
                for(ERP7__Requisition__c s:reqList) reqIds.add(s.Id);
                
                list<ERP7__Purchase_Requisition_Line_Items__c> ReqLIList=new list<ERP7__Purchase_Requisition_Line_Items__c>();  
                ReqLIList=[SELECT Id, Name, ERP7__Sales_Order_Line_Item__c,ERP7__Quantity__c,ERP7__Product__c FROM ERP7__Purchase_Requisition_Line_Items__c
                           WHERE ERP7__Purchase_Requisition__c IN:reqIds AND ERP7__Product__c!=Null]; //ERP7__Sales_Order_Line_Item__c IN:SoliIds  
                // Map < Id, decimal > Prod_Quantity = new Map < Id, decimal > ();
                //for(ERP7__Purchase_Requisition_Line_Items__c pr :ReqLIList ) Prod_Quantity.put(pr.ERP7__Product__c,pr.ERP7__Quantity__c);
                Set<Id> proIds=new Set<Id>();
                for(ERP7__Purchase_Requisition_Line_Items__c pr :ReqLIList ){
                    proIds.add(pr.ERP7__Product__c);
                }
                Map<String,Decimal> proQuanMap=new Map<String,Decimal>();
                for(Id pro:proIds){
                    Decimal quantity=0;
                    for(ERP7__Purchase_Requisition_Line_Items__c pr :ReqLIList ){
                        if(pro == pr.ERP7__Product__c){
                            quantity+=pr.ERP7__Quantity__c;
                            
                        }
                    }
                    proQuanMap.put(pro,quantity);
                }
                Map<String,Decimal> OrdproQuanMap=new Map<String,Decimal>();
                for(Id prod:proIds){
                    Decimal quantityOrd=0;
                    for(ERP7__Sales_Order_Line_Item__c orp :SOLIList ){
                        if(prod == orp.ERP7__Product__c){
                            quantityOrd+=orp.ERP7__Quantity__c;
                            
                        }
                    }
                    OrdproQuanMap.put(prod,quantityOrd);
                }
                Map<String,Decimal> ReqproQuanMap=new Map<String,Decimal>();
                for(String OrdMap : OrdproQuanMap.keySet()){
                    Decimal finalQty = 0 ;
                    for(String Req :  proQuanMap.keySet()){
                        if(OrdMap == Req) {
                            finalQty= OrdproQuanMap.get(OrdMap) - proQuanMap.get(Req);
                        }
                    } ReqproQuanMap.put(OrdMap,finalQty);  
                }
                for(Integer i=0; i<prliList.size(); i++){
                    for(String finalQ : ReqproQuanMap.keySet()){
                        if((finalQ == prliList[i].ERP7__Product__c) && (ReqproQuanMap.get(finalQ) != prliList[i].ERP7__Quantity__c) && (prliList[i].ERP7__Quantity__c != 0)){
                            prliList[i].ERP7__Quantity__c = ReqproQuanMap.get(finalQ);
                        }
                        if((finalQ == prliList[i].ERP7__Product__c) && (prliList[i].ERP7__Quantity__c == 0)) prliList.remove(i); 
                    }
                }
                
            }  
            if(prliList.size() > 0){
                poWrap.wPOLIs =  prliList;
                set <Id> siteIds = new set <Id>(); 
                set <Id> prodIds = new set <Id>(); 
                List<ProductStock> prodlst = new List<ProductStock>();
                for(ERP7__Purchase_Requisition_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
                List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                    where ERP7__Employee_User__c=:UserInfo.getUserId()];
                String DCId = '';
                if(empList.size()>0 && empList != null){
                    List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                                  where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                    if(dcList.size() > 0) DCId = dcList[0].Id;
                }
                if(String.isNotEmpty(DCId)) {
                    for(ERP7__Purchase_Requisition_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
                    List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                        From Distribution_Channel__c
                                                                        Where 
                                                                        Id=:DCId And Active__c = true order by ERP7__Priority__c ASC];
                    
                    for(Distribution_Channel__c DC: DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                    List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                    WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                    Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                    Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                    From Inventory_Stock__c
                                                    Where product__c In: prodIds And
                                                    Active__c = true And
                                                    Warehouse__c In: siteIds 
                                                   ];
                    for(Id ProductId : prodIds){
                        Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                        ProductStock pr = new ProductStock();
                        
                        for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                            if(ProductId == WIIS.product__c){
                                myStock += WIIS.Number_of_Item_In_Stock__c;  
                                demand+=WIIS.ERP7__No_of_Items_Requested__c;
                                Awaitingstock += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                            }
                                
                        }
                        
                        pr.Product = ProductId;
                        pr.Demand = demand;
                        pr.Stock = myStock;
                        pr.AwaitingStocks=Awaitingstock;
                        prodlst.add(pr);
                    }
                }
                poWrap.productStocks = prodlst;   
            }
            else{ return null;}
        }catch(Exception e){ /*'Error at : '+e.getLineNumber()+'Message : '+e.getMessage() */}
        return poWrap; 
    }
      public class poliVenWrap{
        @AuraEnabled public ERP7__Purchase_Requisition_Line_Items__c  poli {get;set;}
        @AuraEnabled public String  MOId {get;set;}
    }
    @AuraEnabled
    public static poliVenWrap populateMrpline(String mrplineId)
    {
        poliVenWrap wrap = new poliVenWrap();
        ERP7__Purchase_Requisition_Line_Items__c prli;
        if(mrplineId != null && mrplineId != ''){
            String mrpFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(mrpFields.split(','),'ERP7__MRP__c');
            String query = 'select ' + String.escapeSingleQuotes(mrpFields) + ', ERP7__MRP_Product__r.Name from ERP7__MRP__c where Id =: mrplineId ';
            List<ERP7__MRP__c> MRPS = Database.query(query);
            if(MRPS.size() > 0){
                wrap.MOId = MRPS[0].ERP7__MO__c;
                prli = new ERP7__Purchase_Requisition_Line_Items__c();
                prli.Name = MRPS[0].ERP7__MRP_Product__r.Name;
                prli.ERP7__Quantity__c = MRPS[0].ERP7__Total_Amount_Required__c;
                prli.ERP7__Product__c = MRPS[0].ERP7__MRP_Product__c;
                prli.ERP7__Product__r = new Product2(Id=MRPS[0].ERP7__MRP_Product__c,Name=MRPS[0].ERP7__MRP_Product__r.Name);
                prli.ERP7__Price__c = MRPS[0].ERP7__Amount_Required__c; 
                prli.ERP7__Amount__c = MRPS[0].ERP7__Total_Amount_Required__c;
                prli.ERP7__MRP__c = MRPS[0].id;
                wrap.poli = prli;
            }
        }    
        return wrap;
    }
    
    @AuraEnabled
    public static POWrapper populateMOlines(String MOId)
    {
        List<ERP7__Purchase_Requisition_Line_Items__c> prlis = new List<ERP7__Purchase_Requisition_Line_Items__c>();
        POWrapper poWrap = new POWrapper();
        if(MOId != null && MOId != ''){
            String MOFields = UtilClass.selectStarFromSObject('ERP7__Manufacturing_Order__c');
            String AllMOFields = MOFields + ', ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.Name, ERP7__Product__r.QuantityUnitOfMeasure, ERP7__Version__r.Name, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Manufacturing_Order__r.Name, ERP7__Routing__r.ERP7__Finished_Products_Site__c ';
            ERP7__Manufacturing_Order__c MO = Database.query('SELECT '+String.escapeSingleQuotes(AllMOFields)+' FROM ERP7__Manufacturing_Order__c WHERE Id = :MOId Limit 1');
            String selectedSite = MO.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            
            String mrpFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(mrpFields.split(','),'ERP7__MRP__c');
            String query = 'select ' + String.escapeSingleQuotes(mrpFields) + ', ERP7__MRP_Product__r.Name from ERP7__MRP__c where ERP7__MO__c =: MOId ';
            List<ERP7__MRP__c> MRPS = Database.query(query);
            
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null ) proIds.add(mrp.ERP7__MRP_Product__c);
            }
            
            if(selectedSite != Null && selectedSite != ''){
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + ''; 
                List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                    +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){
                        if(proId == stock.Product__c){
                            myStock += stock.Number_of_Item_In_Stock__c;
                        }
                    }
                    stockMap.put(proId,myStock);
                }
            }
            
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null && stockMap.containsKey(mrp.ERP7__MRP_Product__c) && mrp.ERP7__Fulfilled_Amount__c != mrp.ERP7__Total_Amount_Required__c){
                    Decimal FA = (mrp.ERP7__Fulfilled_Amount__c != Null)? mrp.ERP7__Fulfilled_Amount__c : 0;
                    if(stockMap.get(mrp.ERP7__MRP_Product__c) < (mrp.ERP7__Total_Amount_Required__c - FA)){
                        ERP7__Purchase_Requisition_Line_Items__c prli = new ERP7__Purchase_Requisition_Line_Items__c();
                        prli.Name = mrp.ERP7__MRP_Product__r.Name;
                        prli.ERP7__Quantity__c = mrp.ERP7__Total_Amount_Required__c - FA - stockMap.get(mrp.ERP7__MRP_Product__c);
                        prli.ERP7__Product__c = mrp.ERP7__MRP_Product__c;
                        prli.ERP7__Product__r = new Product2(Id=mrp.ERP7__MRP_Product__c,Name=mrp.ERP7__MRP_Product__r.Name);
                        prli.ERP7__MRP__c = mrp.id;
                        prlis.add(prli);
                    }
                }
            }
        }  
        if(prlis.size() > 0){
            poWrap.wPOLIs =  prlis;
            set <Id> siteIds = new set <Id>(); 
            set <Id> prodIds = new set <Id>(); 
            List<ProductStock> prodlst = new List<ProductStock>();
            for(ERP7__Purchase_Requisition_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
            List<ERP7__Employees__c> empList = [Select Id, Name, ERP7__Employee_User__c, ERP7__Channel__c , ERP7__Channel__r.ERP7__Organisation__c from ERP7__Employees__c
                                                where ERP7__Employee_User__c=:UserInfo.getUserId()];
            String DCId = '';
            if(empList.size()>0 && empList != null){
                List<ERP7__Distribution_Channel__c> dcList = [Select Id, Name, ERP7__Channel__c, ERP7__Channel__r.Name, ERP7__Site__c, ERP7__Active__c from ERP7__Distribution_Channel__c
                                                              where ERP7__Channel__c=:empList[0].ERP7__Channel__c and ERP7__Active__c=true and ERP7__Site__c != null and ERP7__Priority__c != null order by ERP7__Priority__c ASC limit 1];
                if(dcList.size() > 0) DCId = dcList[0].Id;
            }
            if(String.isNotEmpty(DCId)) {
                for(ERP7__Purchase_Requisition_Line_Items__c pp : poWrap.wPOLIs) prodIds.add(pp.ERP7__Product__c);
                List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                    From Distribution_Channel__c
                                                                    Where 
                                                                    Id=:DCId And Active__c = true order by ERP7__Priority__c ASC];
                
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
                List<ERP7__Stock_Inward_Line_Item__c> SILIList=new List<ERP7__Stock_Inward_Line_Item__c>();
                List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                                Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                                From Inventory_Stock__c
                                                Where product__c In: prodIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds
                                               ];
                for(Id ProductId : prodIds){
                    Decimal demand = 0.0;  Decimal myStock = 0.0;  Decimal Awaitingstock = 0.0;
                    ProductStock pr = new ProductStock();
                    
                    for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
                        if(ProductId == WIIS.product__c)
                            myStock += WIIS.Number_of_Item_In_Stock__c;  
                        demand+=WIIS.ERP7__No_of_Items_Requested__c;
                        Awaitingstock += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
                    }
                    
                    pr.Product = ProductId;
                    pr.Demand = demand;
                    pr.Stock = myStock;
                    pr.AwaitingStocks=Awaitingstock;
                    prodlst.add(pr);
                }
            }
            poWrap.productStocks = prodlst;
        }
        return poWrap;
    }
    
    @AuraEnabled
    public static List<ERP7__Purchase_Requisition_Line_Items__c> populateWOlines(String WOId)
    {
        List<ERP7__Purchase_Requisition_Line_Items__c> prlis = new List<ERP7__Purchase_Requisition_Line_Items__c>();
        if(WOId != null && WOId != ''){
            String WOFields = UtilClass.selectStarFromSObject('ERP7__WO__c');
            String AllWOFields = WOFields + ', ERP7__Product__r.ERP7__Serialise__c, ERP7__Product__r.ERP7__Lot_Tracked__c, ERP7__Product__r.Name, ERP7__Product__r.QuantityUnitOfMeasure, ERP7__Version__r.Name, ERP7__Routing__r.ERP7__Raw_Materials_Site__c, ERP7__Routing__r.ERP7__Finished_Products_Site__c ';
            ERP7__WO__c WO = Database.query('SELECT '+String.escapeSingleQuotes(AllWOFields)+' FROM ERP7__WO__c WHERE Id = :WOId Limit 1');
            String selectedSite = WO.ERP7__Routing__r.ERP7__Raw_Materials_Site__c;
            
            
            String mrpFields = UtilClass.selectStarFromSObject('ERP7__MRP__c');
            utilClass.FLSCheck(mrpFields.split(','),'ERP7__MRP__c');
            String query = 'select ' + String.escapeSingleQuotes(mrpFields) + ', ERP7__MRP_Product__r.Name from ERP7__MRP__c where ERP7__Work_Order__c =: WOId ';
            List<ERP7__MRP__c> MRPS = Database.query(query);
            
            Set<Id> proIds = new Set<Id>();
            Map<Id, Decimal> stockMap = new Map<Id, Decimal>();
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null ) proIds.add(mrp.ERP7__MRP_Product__c);
            }
            
            if(selectedSite != Null && selectedSite != ''){
                String WarehouseFields = UtilClass.selectStarFromSObject('ERP7__Inventory_Stock__c');
                String AllWarehouseFields = WarehouseFields + ''; 
                List<Inventory_Stock__c> WIISLists = Database.query('select ' + String.escapeSingleQuotes(AllWarehouseFields) + ', Warehouse__r.Name, Location__r.Name, StorageContainer__r.Name, Warehouse__r.Barcode__c, Location__r.Barcode__c, '+
                                                                    +' StorageContainer__r.Barcode__c from Inventory_Stock__c where (Warehouse__c =: selectedSite And (Product__c In: proIds And Number_of_Item_In_Stock__c > 0) And Active__c = true) Order By ERP7__Expiry_Date__c ASC'); 
                for(Id proId : proIds){
                    Decimal myStock = 0;
                    for(Inventory_Stock__c stock : WIISLists){
                        if(proId == stock.Product__c){
                            myStock += stock.Number_of_Item_In_Stock__c;
                        }
                    }
                    stockMap.put(proId,myStock);
                }
            }
            
            for(MRP__c mrp : MRPS){
                if(mrp.ERP7__MRP_Product__c != Null && stockMap.containsKey(mrp.ERP7__MRP_Product__c) && mrp.ERP7__Fulfilled_Amount__c != mrp.ERP7__Total_Amount_Required__c){
                    Decimal FA = (mrp.ERP7__Fulfilled_Amount__c != Null)? mrp.ERP7__Fulfilled_Amount__c : 0;
                    if(stockMap.get(mrp.ERP7__MRP_Product__c) < (mrp.ERP7__Total_Amount_Required__c - FA)){
                        ERP7__Purchase_Requisition_Line_Items__c prli = new ERP7__Purchase_Requisition_Line_Items__c();
                        prli.Name = mrp.ERP7__MRP_Product__r.Name;
                        prli.ERP7__Quantity__c = mrp.ERP7__Total_Amount_Required__c - FA - stockMap.get(mrp.ERP7__MRP_Product__c);
                        prli.ERP7__Product__c = mrp.ERP7__MRP_Product__c;
                        prli.ERP7__Product__r = new Product2(Id=mrp.ERP7__MRP_Product__c,Name=mrp.ERP7__MRP_Product__r.Name);
                        prli.ERP7__MRP__c = mrp.id;
                        prlis.add(prli);
                    }
                }
            }
        }    
        return prlis;
    }
    @AuraEnabled
    Public Static list<PRWrap> getExistingPReq(String SOId,String OrderId){ 
        list<PRWrap> ReqList=new list<PRWrap>(); 
        /*'getLOLIExisting SOId==>'+SOId+'      getLOLIExisting OrderId==>'+OrderId */
        if(String.isNotEmpty(SOId)){  
            list<ERP7__Requisition__c>  RList=[SELECT Id, Name, ERP7__Sales_Order__c ,ERP7__Sales_Order__r.Name ,ERP7__Active__c,ERP7__Status__c, ERP7__Delivery_Contact__c, ERP7__Delivery_Contact__r.Name, ERP7__Delivery_Address__c, ERP7__Delivery_Address__r.Name
                                               FROM ERP7__Requisition__c 
                                               WHERE ERP7__Sales_Order__c=:SOId AND ERP7__Active__c=true Order By createdDate ASC];
            
            
            for(ERP7__Requisition__c log:RList) {  PRWrap w=new PRWrap();  w.Id=log.Id; w.Name=log.Name;  w.Order=log.ERP7__Sales_Order__r.Name;  w.Contact=log.ERP7__Delivery_Contact__r.Name;  w.ToAddress=log.ERP7__Delivery_Address__r.Name; w.Status=log.ERP7__Status__c;  ReqList.add(w); 
                                                }
            return ReqList;   
        }
        else if(String.isNotEmpty(OrderId)){
            list<ERP7__Requisition__c>  RList=[SELECT Id, Name, ERP7__Active__c,ERP7__Order_S__c,ERP7__Order_S__r.OrderNumber, ERP7__Delivery_Contact__c, ERP7__Delivery_Contact__r.Name, ERP7__Delivery_Address__c, ERP7__Delivery_Address__r.Name, ERP7__Status__c
                                               FROM ERP7__Requisition__c 
                                               WHERE ERP7__Order_S__c=:OrderId AND ERP7__Active__c=true Order By createdDate ASC];
            
            
            for(ERP7__Requisition__c log:RList) {  PRWrap w=new PRWrap();  w.Id=log.Id; w.Name=log.Name;  w.Order=log.ERP7__Order_S__r.OrderNumber;  w.Contact=log.ERP7__Delivery_Contact__r.Name;  w.ToAddress=log.ERP7__Delivery_Address__r.Name; w.Status=log.ERP7__Status__c;  ReqList.add(w); 
                                                 
                                                }
            return ReqList;  
            
        } else return null;                                                           
        
    } 
    @AuraEnabled
    Public Static ProductStock getstocks(String DCId,String ProductId){
        ProductStock pr = new ProductStock();
        Decimal myStock = 0.0;
        Decimal demand=0.0;
        Decimal Awaitingstock = 0.0;
        List <Id> siteIds = new List <Id>(); 
        if(String.isNotEmpty(DCId) && String.isNotEmpty(ProductId)) {
            List<Distribution_Channel__c> DistributionChannels=[Select Id, Name, Active__c,  Channel__c, Site__c
                                                                From Distribution_Channel__c
                                                                Where 
                                                                Id=:DCId And Active__c = true order by ERP7__Priority__c ASC];
            
            for(Distribution_Channel__c DC: DistributionChannels) {
                siteIds.add(DC.Site__c);
            }
        }
        
        
        List < Inventory_Stock__c > WarehouseItemInventoryStocks = new List < Inventory_Stock__c > ();
        WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                        Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,ERP7__No_of_Items_Requested__c,
                                        Number_of_Items_Dispatched__c, No_of_Items_Sold__c,ERP7__Number_of_Items_Awaiting_in_Stock__c
                                        From Inventory_Stock__c
                                        Where product__c =: ProductId And
                                        Active__c = true And
                                        Warehouse__c In: siteIds 
                                       ];
        
        for(Inventory_Stock__c WIIS: WarehouseItemInventoryStocks) {
            if(ProductId == WIIS.product__c){
                myStock += WIIS.Number_of_Item_In_Stock__c; 
                demand+=WIIS.ERP7__No_of_Items_Requested__c;
                Awaitingstock += WIIS.ERP7__Number_of_Items_Awaiting_in_Stock__c;
            }
            
        }
        
        
        pr.Product = ProductId;
        pr.Demand = demand;
        pr.Stock = myStock;
        pr.AwaitingStocks=Awaitingstock;
        return pr;
        
    }
    public class ProductStock{
        @AuraEnabled public Decimal Demand                                  {get; set;}
        @AuraEnabled public Decimal Stock                                   {get; set;}
        @AuraEnabled public Decimal AwaitingStocks                          {get; set;}
        @AuraEnabled public String Product                                  {get; set;}
        public ProductStock(){
            Demand = 0.0;Stock = 0.0; AwaitingStocks = 0.0;
            Product = '';
        }
        
    }
    Public class WrapperClass{
        @AuraEnabled
        public List<String> StatusList {get;set;} 
        @AuraEnabled
        public Boolean isAccessible =false;
    }
    
    Public class PRWrap{
        @AuraEnabled
        public String Id {get;set;} 
        @AuraEnabled
        public String Name {get;set;} 
        @AuraEnabled
        public String Order {get;set;} 
        @AuraEnabled
        public String Contact {get;set;} 
        @AuraEnabled
        public String ToAddress {get;set;} 
        @AuraEnabled
        public String  Status {get;set;} 
        
        
        public PRWrap(){
            Name=Order=Contact=ToAddress=Status='';    
        }    
        
    }
    
    @AuraEnabled
    public static Product2 fetchProductDesc(String productId){  
        if(String.isNotEmpty(productId)) return [Select Id, Name, ERP7__Vendor_Supplier_Description__c from Product2 where Id =: productId Limit 1];
        else return null;
    }
    public class POWrapper{
        @AuraEnabled public List<ERP7__Purchase_Requisition_Line_Items__c> wPOLIs               { get; set; }
        @AuraEnabled public List<ProductStock> productStocks                        { get; set; }
        
    }
    
}